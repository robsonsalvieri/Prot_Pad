// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Calend - Define o objeto TCalend (Tabela temporal)
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 10.01.06 | 0548-Alan Candido | Versão 3
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "Calend.ch"

/*
--------------------------------------------------------------------------------------
Classe: TCalend
Uso   : Objeto para gerenciamento da Tabela Temporal
--------------------------------------------------------------------------------------
*/
class TCalend from TDWObject

	method New(aoOwner) constructor
	method Free()
	method NewCalend(aoOwner)
	method FreeCalend()

	method DataInicial()          // Data inicial
	method DataFinal()            // Data final

	method StartProc(adtInic, adtFinal, alJob)              // Processa a geração do calendário
	method Table()                       // Tabela de calendários
	method TableName() 
endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(aoOwner) class TCalend

	::NewCalend(aoOwner)

return

method Free() class TCalend

	::FreeCalend()
	
return

method NewCalend(aoOwner) class TCalend

	::NewObject(aoOwner)

return

method FreeCalend() class TCalend

	::FreeObject()

return                                          
                                     
/*
--------------------------------------------------------------------------------------
Propriedade DataInicial
Ret: dRet -> date, data inicial da tabela temporal
--------------------------------------------------------------------------------------
*/
method DataInicial() class TCalend
	local dRet := ctod("  /  /  ")
	local qAux := TQuery():New(DWMakeName("TRA"))
  
	qAux:FieldList("min(DT)")
	qAux:FromList(::Table():tableName())
	qAux:Open()   
	if !qAux:eof()
		dRet := stod(qAux:value(1))
	endif
	qAux:close()

return dRet

/*
--------------------------------------------------------------------------------------
Propriedade DataFinal
Ret: dRet -> date, data final da tabela temporal
--------------------------------------------------------------------------------------
*/
method DataFinal() class TCalend
	local dRet := ctod("  /  /  ")
	local qAux := TQuery():New(DWMakeName("TRA"))
   
	qAux:FieldList("max(DT)")
	qAux:FromList(::Table():tableName())
	qAux:Open()   
	if !qAux:eof()
		dRet := stod(qAux:value(1))
	endif
	qAux:close()

return dRet

/*
--------------------------------------------------------------------------------------
Salva os parâmetros e inicia o processo de geração
Args: alJob -> lógico, indica que o processo é um Job
Ret: lRet -> lógico, status do processo gerado
--------------------------------------------------------------------------------------
*/
method StartProc(adInicial, adFinal, alJob) class TCalend
	local lRet := .T.
	
	default alJob := .f.
	if empty(adInicial) 
		adInicial := date()
	endif			
	if empty(adFinal) 
		adFinal := date()
	endif			
	if valType(adInicial) != "D"
		adInicial := stod(adInicial)
	endif
	if valType(adFinal) != "D"
		adFinal := stod(adFinal)
	endif			
                
	if alJob        
		if !empty(::DataInicial()) .and. ::DataInicial() < adInicial
			adInicial := ::DataInicial()
		endif
		if adFinal < ::DataFinal()
			adFinal := ::DataFinal()
		endif

		DWBuildCalend(::Table(), adInicial, adFinal)
		DWLOG(STR0001) //"Geração da dimensão temporal concluída"
		oSigaDW:Log(STR0001) //"Geração da dimensão temporal concluída"
	else
		lRet := DWStartJob(JOB_INITCALEND, { dtos(adInicial), dtos(adFinal) },,.t.)
	endif
	
return lRet

/*
--------------------------------------------------------------------------------------
Recupera a tabela de calendário
Args: 
Ret: oRet -> objeto, tabela de acesso ao calendário
--------------------------------------------------------------------------------------
*/
method Table() class TCalend

return InitTable(TAB_CALEND)

/*
--------------------------------------------------------------------------------------
Recupera o nome da tabela de calendário
Args: 
Ret: cRet -> string, nome da tabela de calendário
--------------------------------------------------------------------------------------
*/
method TableName() class TCalend

return ::Table():Tablename()

function DWBuildCalend(aoTable, adInicial, adFinal)
	local lRet := .T., oTb, dtAux, aValues, dtDiaUm
	local nSemana 
	local nQuinzena := 0, nBimestre := 0, nTrimestre := 0, nQuadmestre := 0, nSemestre := 0
	local nSeqDia := 0, nSeqSemana := 0, nSeqQuinzena := 0, nSeqMes := 0, nSeqBimestre := 0
	local nSeqTrimestre := 0, nSeqQuadmestre := 0, nSeqSemestre := 0, nSeqAno := 0
	local nEstacao := 0
	local oldQuinzena := -1, oldMes := -1, oldBimestre := -1, oldTrimestre := -1
	local oldQuadmestre := -1, oldSemestre := -1, oldAno := -1, cAux
	
	if valType(adInicial) == "C"
		adInicial := stod(adInicial)
	endif
	if valType(adFinal) == "C"
		adFinal := stod(adFinal)
	endif
	
	nSemana := iif(dow(adInicial) == 1, 0, 1)
	
	oTb := aoTable
	
	oTb:Open()
	
	if day(adInicial) <> 1
		nSemana := 0
		for dtAux := ctod("01/"+dwStr(month(adInicial)) + "/" + dwStr(year(adInicial))) to adInicial - 1
			iif(dow(dtAux) == 1, nSemana++, nSemana)
		next
	endif
	
	for dtAux := adInicial to adFinal
		aValues := {}
		
		if year(dtAux) <> oldAno
			oldAno := year(dtAux)
			dtDiaUm := ctod("01/01/" + str(oldAno))
			nSeqAno++
			nSeqSemana := iif(dow(dtAux) == 1, 0, 1)
		endif
		
		nSeqDia++
		nQuinzena := iif(day(dtAux) < 16, 1, 2)
		nBimestre := int((month(dtAux)+1)/2)
		nTrimestre := iif(mod(month(dtAux),3) <> 0, int(month(dtAux)/3) + 1, int(month(dtAux)/3))
		nQuadmestre := iif(mod(month(dtAux),4) <> 0, int(month(dtAux)/4) + 1, int(month(dtAux)/4))
		nSemestre := iif(month(dtAux) < 7, 1, 2)
		
		if dow(dtAux) == 1
			nSemana++
			nSeqSemana++
		endif
		if oldMes <> month(dtAux)
			nSeqMes++
			oldMes := month(dtAux)
			nSemana := 1
		endif
		if oldQuinzena <> nQuinzena
			nSeqQuinzena++
			oldQuinzena := nQuinzena
		endif
		if oldBimestre <> nBimestre
			nSeqBimestre++
			oldBimestre := nBimestre
		endif
		if oldTrimestre <> nTrimestre
			nSeqTrimestre++
			oldTrimestre := nTrimestre
		endif
		if oldQuadmestre <> nQuadmestre
			nSeqQuadmestre++
			oldQuadmestre := nQuadmestre
		endif
		if oldSemestre <> nSemestre
			nSeqSemestre++
			oldSemestre := nSemestre
		endif
		
		cAux := StrZero(month(dtAux),2) + StrZero(day(dtAux),2)
		if .t. //oSigaDW:Hemisferio() == 1 - ##TODO: colocar hemisferio no oSigaDW
			if cAux < "0222"
	  		nEstacao := VERAO_R
			elseif cAux < "0522"
				nEstacao := OUTONO_R
			elseif cAux < "0822"
				nEstacao := INVERNO_R
			else
				nEstacao := PRIMAVERA_R
			endif
		else
			if cAux < "0222"
				nEstacao := INVERNO_R
			elseif cAux < "0522"         		
				nEstacao := PRIMAVERA_R
			elseif cAux < "0822"
				nEstacao := VERAO_R
			else
				nEstacao := OUTONO_R
			endif
		endif
		aAdd(aValues, { "dt"        , dtAux } )
		aAdd(aValues, { "s_dia"     , nSeqDia} )
		aAdd(aValues, { "s_mes"     , nSeqMes} )
		aAdd(aValues, { "s_ano"     , nSeqAno} )
		aAdd(aValues, { "s_semana"  , nSeqSemana} )
		aAdd(aValues, { "s_quinzena", nSeqQuinzena} )
		aAdd(aValues, { "s_bimestre", nSeqBimestre} )
		aAdd(aValues, { "s_trimestr", nSeqTrimestre} )
		aAdd(aValues, { "s_quadmest", nSeqQuadmestre} )
		aAdd(aValues, { "s_semestre", nSeqSemestre})
		aAdd(aValues, { "dow"       , dow(dtAux)} )
		aAdd(aValues, { "doy"       , dtAux - dtDiaUm + 1} )
		aAdd(aValues, { "dia"       , day(dtAux)} )
		aAdd(aValues, { "mes"       , month(dtAux)} )
		aAdd(aValues, { "ano"       , year(dtAux)} )
		aAdd(aValues, { "semana"    , nSemana} )
		aAdd(aValues, { "quinzena"  , nQuinzena} )
		aAdd(aValues, { "bimestre"  , nBimestre} )
		aAdd(aValues, { "trimestre" , nTrimestre} )
		aAdd(aValues, { "quadmestre", nQuadmestre} )
		aAdd(aValues, { "semestre"  , nSemestre} )
		aAdd(aValues, { "estacao"   , nEstacao} )
		if !oTb:Seek(2, { DToS( dtAux ) })
			if !oTb:Append(aValues)
				lRet := .f.
				exit
			endif
		else
			if !oTb:Update(aValues)
				lRet := .f.
				exit
			endif
		endif
		if DWKillApp()
			exit
		endif
	next

return

