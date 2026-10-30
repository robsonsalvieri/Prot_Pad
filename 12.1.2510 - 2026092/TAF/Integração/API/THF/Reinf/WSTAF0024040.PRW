#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry4040()
Query dos pendentes de apuração do eventos R-4040

@author Rafael de Paula Leme
@since 17/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry4040(cPerApu, aFil, nPage, nSize, lAll)

Local cQuery     as Character
Local cQryTot    as Character
Local cAlias     as Character
Local cAliasTot  as Character
Local cFilsV4K   as Character
Local cDataIni   as Character
Local cDataFim   as Character
Local nV4KPRID40 as Numeric
Local nTotReg    as Numeric
Local lHasNext   as Logical

Default cPerApu := ""
Default aFil    := {}
Default nPage   := 0
Default nSize   := 0

cQuery     := ""
cQryTot    := ""
cAlias	   := ""
cAliasTot  := ""
cFilsV4K   := TafRetFilC("V4K", aFil)
cDataIni   := cPerApu + "01"
cDataFim   := DtoS(LastDay(StoD(cDataIni)))
nV4KPRID40 := TamSX3("V4K_PRID40")[1]
nTotReg    := 0
lHasNext   := .F.

cQuery += " SELECT TBGER.FILIAL FILIAL, "
cQuery += "	CASE WHEN (SELECT COUNT(V4K_PRID40) FROM " + RetSqlName("V4K") + " WHERE V4K_FILIAL = TBGER.FILIAL AND V4K_INDNAT = '0' AND "
cQuery += " V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += " V4K_PRID40 = '" + Space(nV4KPRID40) + "' AND "
cQuery += " D_E_L_E_T_ = ' ') > 0 THEN 'notValidated' ELSE 'validated' END STATUS, "
cQuery += "	SUM(TBGER.VALLIQ) VALLIQ, "
cQuery += " SUM(TBGER.BASEIR) BASEIR, "
cQuery += " SUM(TBGER.VALIR)  VALIR "
cQuery += " FROM "
cQuery += " (SELECT V4K.V4K_FILIAL FILIAL, V4K.V4K_PRID40 PROCID, V4K.V4K_VLRLIQ VALLIQ, V4K.V4K_BASEIR BASEIR, V4K.V4K_VLRIR VALIR "
cQuery += " FROM " + RetSqlName("V4K") + " V4K "
cQuery += "	WHERE "
cQuery += "	V4K.V4K_FILIAL IN " + cFilsV4K + " AND "
cQuery += "	V4K.V4K_INDNAT = '0' AND "
cQuery += "	V4K.V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
cQuery += "	V4K.D_E_L_E_T_ = ' ' "
cQuery += "	) TBGER "
cQuery += " GROUP BY TBGER.FILIAL "

If lAll .Or. (nPage > 0 .And. nSize > 0) //paginacao e contagem considerando os dados ja agrupados
	cAliasTot := GetNextAlias()
	cQryTot := " SELECT COUNT(TBTOT.FILIAL) QTDREG FROM  ( " + cQuery + " ) TBTOT "
	cQryTot := ChangeQuery(cQryTot)
	TCQuery cQryTot New Alias (cAliasTot)
	nTotReg := (cAliasTot)->QTDREG
	(cAliasTot)->(DBCloseArea())
	If lAll
		lHasNext := .F.
	Else
		lHasNext := Iif((nPage * nSize) >= nTotReg, .F., .T.)
	Endif
EndIf

cQuery += " ORDER BY 2,1 "

cQuery := ChangeQuery(cQuery)
cAlias := GetNextAlias()
TCQuery cQuery New Alias (cAlias)

Return {cAlias, nTotReg, lHasNext}

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0024040()
Monta Json de acordo com a query

@author Rafael de Paula Leme
@since 04/11/2022
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Function WS0024040(aApurac, oEstruct, cPeriodo, cEvent, aFiliais, oValidationError)

Local cAlias     as Character
Local cStatus	 as Character
Local cCNPJ		 as Character
Local cNome      as Character
Local nTSintetic as Numeric
Local nPos       as Numeric
Local nX         as Numeric
Local lhasNext   as Logical

Default aApurac          := {'',0,.F.}
Default oEstruct         := Nil
Default cPeriodo         := '' 
Default cEvent 	         := ''
Default aFiliais         := {}
Default oValidationError := Nil

cAlias     := aApurac[1]
lhasNext   := aApurac[3]
nTSintetic := 0
nPos       := 0
nX         := 1
cStatus    := ""
cCNPJ      := ""
cNome      := ""
aRetAlias  := {}

If oValidationError == Nil .Or. oValidationError["registryKey"] == Nil
	oValidationError := JsonObject():New()
	oValidationError["registryKey"] := {}
Endif

If !(cAlias)->(EOF())
	(cAlias)->(DbGoTop())
	While !(cAlias)->(EOF())

		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])
		
		If SM0->(dbSeek(cEmpAnt + (cAlias)->FILIAL))
			cCNPJ := SM0->M0_CGC
			cNome := SM0->M0_NOME
		EndIf
		
		cStatus := Iif(Lower(Alltrim((cAlias)->STATUS))=="notvalidated","notValidated","validated")
				
		oEstruct["eventDetail"][nTSintetic]["status"]      := cStatus
		oEstruct["eventDetail"][nTSintetic]["branchId"]    := (cAlias)->FILIAL
		oEstruct["eventDetail"][nTSintetic]["numInsc"]     := cCNPJ
		oEstruct["eventDetail"][nTSintetic]["key"]		   := cCNPJ
		oEstruct["eventDetail"][nTSintetic]["company"]	   := AllTrim(EncodeUTF8(cNome)) 
		oEstruct["eventDetail"][nTSintetic]["liquidValue"] := (cAlias)->VALLIQ
		oEstruct["eventDetail"][nTSintetic]["irBaseValue"] := (cAlias)->BASEIR
		oEstruct["eventDetail"][nTSintetic]["irValue"]     := (cAlias)->VALIR
		oEstruct["eventDetail"][nTSintetic]["errors"]      := 'errors'
		
		If Len(oValidationError["registryKey"]) > 0 		
			oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"] := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
		EndIf

		(cAlias)->(dbSkip())
	EndDo		
Else
	aadd(oEstruct["eventDetail"],JsonObject():New())
	oEstruct["eventDetail"] := {}
Endif

oEstruct['hasNext'] := lhasNext

Return oEstruct

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Denis Souza /Jose Felipe
@since 04/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)

Local cKeyError as Character
Local nX        as Numeric

cKeyError := ""
nX        := 1

For nX := 1 to Len(oValidationError["registryKey"])
	if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
		if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
			cKeyError := oValidationError["registryKey"][nX]["error"]
		endif
	endif
Next nX

Return (cKeyError)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WsRel40E80
Função responsável por retornar a query para geração da planilha.

R-4040 - Pagamentos/créditos a beneficiários não identificados
R-4080 - Retenção no recebimento

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
function WsRel40E80( cPeriod, cCompC1H, aInfEUF, cFilsV4K, cBanco, cEvent )

local cQry 		as character
local cDataIni  as Character
local cDataFim  as Character

default cPeriod  := ''
default cCompC1H := ''
default aInfEUF  := {}
default cFilsV4K := ''
default cBanco   := ''

cDataIni := cPeriod + "01" //ex: 20220201
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

cQry := "SELECT "
cQry += "V4K.V4K_FILIAL FILIAL"	 					//Filial/CNPJ da Filial/Nome da Filial
cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(C1H.C1H_CODPAR,' ') CODPAR" 		//Código Participante

if "4080" $ cEvent //R-4080 - Retenção no recebimento
	cQry += ",V4K.V4K_CGCFON CGCFON" 				//CNPJ Fonte Pagadora
	cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(C1H.C1H_NOME,' ') NOMEFON" 	//Nome Fonte Pagadora
endif

cQry += ",V4K.V4K_ID ID"		 					//ID Documento
cQry += ",V4K.V4K_CODDOC CODDOC" 					//Número do documento
cQry += ",V4K.V4K_DTPAG DTPAG"	 					//Data Fato Gerador
cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(V3O.V3O_CODIGO,' ') CODNAT" 		//Natureza de Rendimento

If "4080" $ cEvent //R-4080 - Retenção no recebimento
	cQry += ",V4K.V4K_VLREAJ VALLIQ"					//Valor Bruto
Else
	cQry += ",V4K.V4K_VLRLIQ VALLIQ" 					//Valor Líquido
EndIf

cQry += ",V4K.V4K_BASEIR BASEIR" 					//Base de Cálculo IR
cQry += ",V4K.V4K_VLRIR VALIR"	 					//Valor Imposto IR
cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(V9B.V9B_NRPROC,' ') NRPROC" 		//Número do Processo Referenciado
cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(SUM(V9B.V9B_BSUSIR),0) BSUSIR"	//Base Suspensa IR
cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(SUM(V9B.V9B_VSUSIR),0) VSUSIR"	//Valor Retenção Suspenso IR
cQry += ","+ iif (!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(SUM(V9B.V9B_VLRDEP),0) VLRDEP"	//Valor depósito Judicial IR
cQry += ",V4K.V4K_DESCRI DESCRI "					//Observação

cQry += "FROM " + RetSqlName("V4K") + " V4K " //Pag. benef. não identificados

cQry += "LEFT JOIN " + RetSqlName("C1H") + " C1H ON " //Cadastro Participantes
If cCompC1H == "EEE"
	cQry += "C1H.C1H_FILIAL = V4K.V4K_FILIAL "
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V4K.V4K_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
	Else
		cQry += "C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf
cQry += "AND C1H.C1H_ID = V4K.V4K_IDPART AND C1H.D_E_L_E_T_ = ' ' "

cQry += "LEFT JOIN " + RetSqlName("V3O") + " V3O ON " //Natureza de rendimento
cQry += "V3O.V3O_FILIAL = '" + xFilial("V3O") + "' "
cQry += "AND V3O.V3O_ID = V4K.V4K_IDNATR AND V3O.D_E_L_E_T_ = ' ' "

cQry += "LEFT JOIN " + RetSqlName("V9B") + " V9B ON " //Info Proc Ret
cQry += "V9B.V9B_FILIAL = '" + xFilial("V9B") + "' AND V9B.V9B_ID = V4K.V4K_ID AND V9B.D_E_L_E_T_ = ' ' "

cQry += "WHERE V4K.V4K_FILIAL IN " + cFilsV4K

if "4040" $ cEvent //R-4040 - Pagamentos/créditos a beneficiários não identificados
	cQry += " AND V4K.V4K_INDNAT = '0' " //0=A Pagar
else //R-4080 - Retenção no recebimento
	cQry += " AND V4K.V4K_INDNAT = '1' " //1=A Receber
endif

cQry += "AND V4K.V4K_DTPAG BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND V4K.D_E_L_E_T_ = ' ' "

cQry += "GROUP BY V4K.V4K_FILIAL,C1H.C1H_CODPAR"

if "4080" $ cEvent //R-4080 - Retenção no recebimento
	cQry += ",V4K.V4K_CGCFON, C1H.C1H_NOME "
endif


If "4080" $ cEvent //R-4080 - Retenção no recebimento
	cQry += ",V4K.V4K_ID,V4K.V4K_CODDOC,V4K.V4K_DTPAG,V3O.V3O_CODIGO,V4K.V4K_VLREAJ "	//Valor Bruto
Else
	cQry += ",V4K.V4K_ID,V4K.V4K_CODDOC,V4K.V4K_DTPAG,V3O.V3O_CODIGO,V4K.V4K_VLRLIQ "
EndIf

cQry += ",V4K.V4K_BASEIR,V4K.V4K_VLRIR,V9B.V9B_NRPROC,V4K.V4K_DESCRI "

cQry += "ORDER BY V4K.V4K_FILIAL,C1H.C1H_CODPAR,V4K.V4K_DTPAG,V4K.V4K_CODDOC,V3O.V3O_CODIGO "

Return cQry
