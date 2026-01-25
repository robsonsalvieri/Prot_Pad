#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR2060.CH"

#DEFINE MB_ICONHAND 16
#DEFINE SINTETICO 	1,1
#DEFINE ATIVIDADE 	2,1
#DEFINE COMPLEMENTO	3,1
#DEFINE PROCESSOS 	4,1
#DEFINE AJUSTE		5,1
#DEFINE DELETSINT 	1,2
#DEFINE DELETATIV 	2,2
#DEFINE DELETCMPT 	3,2
#DEFINE DELETPROC 	4,2
#DEFINE DELETAJST 	5,2
#DEFINE DEFEMP	 	1
#DEFINE DEFUND 		2
#DEFINE DEFFIL  	3

Static _cQry1MD5 	:= ""
Static _cQry2MD5 	:= ""
Static _cQry3MD5 	:= ""

Static _lHasC5O  	:= Nil
Static _lHasT9T  	:= Nil
Static _TafBindQry 	:= Nil
Static _aFils		:= Nil
Static _cFiliais    := Nil
Static _cBd			:= Nil
Static _nTmAtiv     := Nil
Static _nTmC1GFl	:= Nil
Static _nTmIdSus    := Nil
Static _nTmC1GPro   := Nil
Static _cCompT9C    := Nil
Static _cFilC5V    	:= Nil
Static _cFilT9C    	:= Nil
Static _TmV48Fil	:= Nil
Static _TmV48Proc	:= Nil
Static _TmT9CNr		:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2060

@description Rotina de apuração do evento R-2060 - Contrib Previdenciária Receita Bruta CPRB 
@description LayOut Unico T082 (CPRB) / Legado CPRB TAFA097 / Espelho TAFA499 
				
@author Denis Souza
@since  02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFAPR2060(cReg,cPerApu,dtIni,dtFin,cIdApReinf,aFil,oProcess, lValid, cKey, lSucesso)

	Local lProc As Logical

	Default cReg 		:= "R-2060"
	Default cPerApu 	:= ""
	Default dtIni 		:= ""
	Default dtFin 		:= ""
	Default cIdApReinf 	:= ""
	Default aFil 		:= {}
	Default oProcess 	:= Nil
	Default lValid 		:= .F.
	Default cKey 		:= ""
	Default lSucesso 	:= .F.

	lProc := oProcess <> Nil

	If lProc
		oProcess:IncRegua2(STR0001 + cReg ) //"Processando apuração "
	EndIf

	TAFR2060( cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, cKey, @lSucesso)

Return Nil

Static Function TAFR2060( cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, cKey, lSucesso)

	Local aLog 		 As Array
	Local aMovs		 As Array
	Local aApurac	 As Array
	Local aAreaSM0 	 As Array
	Local aInfoC1E	 As Array
	Local aInfoEUF	 As Array
	Local cStatReg 	 As Character
	Local cNrInsc	 As Character
	Local cPerApuGrv As Character
	Local lExecApr	 As Logical
	Local lProc		 As Logical
	Local lDsarm	 As Logical
	Local nContApur	 As Numeric
	Local nTotReg	 As Numeric	
	Local nContLog	 As Numeric
	Local cFilT9V	 As Character

	Default cKey 		:= ""
	Default cReg		:= ""
	Default cPerApu		:= ""
	Default dtIni		:= ""
	Default dtFin		:= ""
	Default cIdApReinf	:= ""
	Default aFil		:= {}
	Default oProcess	:= Nil
	Default lValid		:= .F.
	Default cKey		:= ""
	Default lSucesso	:= .F.

	aLog  		:= {}
	aApurac		:= {}
	aAreaSM0 	:= SM0->(GetArea())
	aInfoC1E	:= {}
	aInfoEUF	:= {}
	cStatReg 	:= "Z"
	cNrInsc		:= ""
	cPerApuGrv 	:= cPerApu
	cPerApu 	:= SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)
	lExecApr	:= .F.
	lProc 		:= oProcess <> nil
	lDsarm		:= .F.
	nContApur	:= 1
	nTotReg		:= 0
	nContLog	:= 0
	cFilT9V 	:= xFilial("T9V")

	DbSelectArea("V0S")
	V0S->(DbSetOrder(2)) //V0S_FILIAL, V0S_PERAPU, V0S_TPINSC, V0S_NRINSC, V0S_ATIVO

	If !Empty(cPerApu)
		If lProc 
			oProcess:IncRegua2(STR0002) // "Selecionando dados a serem apurados"
		EndIf
		aInfoEUF := TamEUF(Upper(AllTrim( FWSM0Util( ):GetSM0Data(cEmpAnt ,cFilAnt , { 'M0_LEIAUTE' } )[1][2] )))
		aApurac	 := Qury2060(cPerApu,.T.,.F., aFil,aInfoEUF,@aMovs, cKey)
		lExecApr := iif( len(aApurac) >= 6 , aApurac[6], .F.)
	EndIf

	If lExecApr
		If !(aApurac[SINTETICO])->(Eof())		
			
			(aApurac[SINTETICO])->(DbSetOrder(1))
			(aApurac[SINTETICO])->(DbEval({|| ++nTotReg }))
			(aApurac[SINTETICO])->(DbGoTop())
			
			If lProc
				oProcess:IncRegua2(STR0003) //"Gravando registros"
				oProcess:SetRegua2(nTotReg)
			EndIf
	
			Begin Transaction
				While !(aApurac[SINTETICO])->(Eof())
				
					if (AllTrim((aApurac[SINTETICO])->CHAVE) $ cKey .or. Empty(cKey))
						cNrInsc := (aApurac[SINTETICO])->CNRINSC
						
						cStatus := StatsReg( cPerApuGrv , (aApurac[SINTETICO])->CTPINSC , cNrInsc )

						If lProc
							oProcess:IncRegua2(STR0004 + cValTochar(nContApur++) + "/" + cValTochar(nTotReg)) //Gravando
						EndIf

						Do Case
						//Alteração direta na base, e retorno do V0S_STATUS para branco
						Case cStatus $ ' |0|1|3|7'
							If ExcluiReg(cIdApReinf, cReg, @aLog)
								If !Grava2060(MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, V0S->V0S_VERANT, V0S->V0S_PROTPN, cIdApReinf, @aLog, V0S->V0S_ID, lValid, cStatus, cFilT9V )							
									lDsarm := .T.
									lSucesso := .F.
								Else
									lSucesso := .T.
								EndIf 
							Else
								lDsarm := .T.
								lSucesso := .F.
							EndIf 
		
						//Registro transmitido ao governo e sem retorno, não deve ser alterado
						Case cStatus $ '2|6'
							cErro	:= STR0006 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
		
							cErro 	+= "tpInsc: " + (aApurac[SINTETICO])->CTPINSC + CRLF
							cErro 	+= "nrInsc: " + cNrInsc + CRLF
		
							cErro 	+= STR0007 + CRLF //"A apuração foi cancelada pois este registro já foi transmitido e está aguardando retorno do RET, portanto não pode ser modificado."
							Aadd(aLog, {cReg, "ERRO", cErro}) //
							lDsarm := .T.
							lSucesso := .F.
			
						Case cStatus == '4'
		
							cVerAnt := V0S->V0S_VERSAO
							cProTpn := V0S->V0S_PROTUL
			
							FAltRegAnt( 'V0S', '2', .F. )
			
							If !Grava2060( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, @aLog, V0S->V0S_ID,/*10*/,/*11*/,cFilT9V)
								lDsarm := .T.
								lSucesso := .F.
							Else
								lSucesso := .T.
							EndIf
		
						Case cStatus == "Z" // Commit do modelo em modo de inclusão

							if !Grava2060( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, /*5*/ , /*6*/, cIdApReinf, @aLog, /*9*/ , lValid, cStatus, cFilT9V ) 
								lDsarm := .T.
								lSucesso := .F.
							Else
								lSucesso := .T.
							EndIf
						
						EndCase
					EndIf
					 
					(aApurac[SINTETICO])->(DbSkip())
				EndDo

				If lDsarm
					DisarmTransaction()
				Else 
					GravaId(aMovs,cIdApReinf)
				EndIf
			End Transaction

			For nContLog := 1 to Len(aLog)
				TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3] )
			Next nContLog
		EndIf

		//Destroi as tabelas temporárias
		aApurac[DELETSINT]:Delete()
		aApurac[DELETATIV]:Delete()
		aApurac[DELETCMPT]:Delete()		
		aApurac[DELETPROC]:Delete()
		aApurac[DELETAJST]:Delete()	
	Else
		//Alimenta aLog com Informação de que a Data Inicial está vazia
		TafXLog(cIdApReinf, cReg, "ALERTA", STR0005) //"Não foram localizados registros que atendam os parâmetros selecionados para processamento da apuração."
	EndIf
	
	RestArea(aAreaSM0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} StatsReg
Verifica a existência ou não do registro que será apurado

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna o status do registro encontrado, caso contrário retorna status "Z", indicando que ainda não existe o registro no cadastro espelho

/*/ 
//-------------------------------------------------------------------
Static Function StatsReg( cPerApu, cTpInsc, cNrInsc )

	Local 	cRetStat As Character

	Default cPerApu	:= ""
	Default cTpInsc := ""
	Default cNrInsc := ""

	cRetStat := "Z"

	If V0S->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + '1'))
		cRetStat := V0S->V0S_STATUS
	EndIf
	
Return cRetStat

//-------------------------------------------------------------------
/*/{Protheus.doc} Qury2060
Rotina de apuração da CPRB
Registro R-2060 da Reinf

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna a string da query

/*/ 
//-------------------------------------------------------------------
Function Qury2060(cPerApu,lApur,lIdProc,aFil,aInfEUF,aMovs,cKey)

	Local cQuery 	 As Character
	Local cAliasApr  As	Character
	Local cSelect	 As	Character
	Local cSelV48	 As Character
	Local cWhere	 As	Character
	Local cWhereV48	 As	Character
	Local cLeftV48	 As	Character
	Local cGroupC5M  As Character
	Local cOrder 	 As	Character
	Local cCmpQry	 As Character
	Local cFromC5M	 As	Character
	Local cFromV48	 As	Character
	Local cIJoinC5V	 As Character
	Local cIJoinC5M  As	Character
	Local cLJoinV48  As	Character
	Local cLJoinT9T  As	Character
	Local cLJoinSUM  As	Character
	Local cLJSUMT9T  As	Character
	Local cLJoinT9C  As	Character
	Local ciJoinT9C	 As	Character
	Local aRegApur	 As Array
	Local cNull		 As Character
	Local cDataIni   As Character
	Local cDataFim   As Character
	Local cQry 		 As Character
	Local cSubStr	 As Character
	Local cPosSub	 As Character
	Local oPrepare 	 As Object
	Local aBind 	 As Array
	Local nI    	 As Numeric
	Local lTmpFil    As Logical
	Local aBranch    As Array

	Default cPerApu  := ""
	Default lApur	 := .F.
	Default lIdProc  := .F.
	Default aFil	 := {}
	Default aInfEUF  := {}
	Default aMovs    := {}
	Default cKey	 := ""

	cQuery		:= ""
	cSelect		:= ""
	cSelV48		:= ""
	ciJoinT9C	:= ""
	cGroupC5M	:= ""
	cWhere		:= ""
	cWhereV48	:= ""
	cLeftV48	:= ""
	cOrder		:= ""
	cCmpQry		:= ""
	cFromC5M	:= ""
	cFromV48	:= ""
	cIJoinC5V	:= ""
	cLJoinV48	:= ""
	cLJoinT9T	:= ""
	cIJoinC5M	:= ""
	cLJoinT9C	:= ""
	aRegApur	:= {}
	lTmpFil    	:= .F.
	aBranch    	:= {}

	if _cFiliais == Nil
		_cFiliais := TafRetFilC("C5M", aFil) //ex: "('0101')" ou (SELECT TMPFIL FROM ##TMPSC00_52 )
	endif

	if "TMPFIL" $ _cFiliais //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
		lTmpFil := .T. //nao manipula o _cFiliais e utiliza a temporaria
	else
		if "(" $ _cFiliais
			_cFiliais := SUBSTR(_cFiliais, 2, Len(_cFiliais)) //retira os parenteses
		endif
		if ")" $ _cFiliais
			_cFiliais := SUBSTR(_cFiliais, 1, (Len(_cFiliais) - 1)) //retira os parenteses
		endif
		aBranch := Separa(StrTran(_cFiliais,"'",""),",")
	endif
	if _cBd == Nil
		_cBd := Upper(AllTrim(TcGetDb()))
	endif
	if _TafBindQry == Nil
		_TafBindQry := FindFunction("TafBindQry")
	endif
	if _nTmAtiv == Nil
		_nTmAtiv := GetSX3Cache("C5M_CODATI", "X3_TAMANHO")
	endif
	if _nTmC1GFl == Nil
		_nTmC1GFl := GetSX3Cache("C1G_FILIAL", "X3_TAMANHO")
	endif
	if _nTmIdSus == Nil
		_nTmIdSus := GetSX3Cache("C5O_IDSUSP", "X3_TAMANHO")
	endif
	if _nTmC1GPro == Nil
		_nTmC1GPro := GetSX3Cache("C1G_NUMPRO", "X3_TAMANHO")
	endif
	if _cCompT9C == Nil
		_cCompT9C := Upper(AllTrim(FWModeAccess("T9C",1)+FWModeAccess("T9C",2)+FWModeAccess("T9C",3)))
	endif
	if _cFilC5V == Nil
		_cFilC5V := xFilial("C5V")
	endif
	if _cFilT9C == Nil
		_cFilT9C := xFilial("T9C")
	endif
	if _TmV48Fil == Nil
		_TmV48Fil := GetSX3Cache("V48_FILIAL", "X3_TAMANHO")
	endif
	if _TmT9CNr == Nil
		_TmT9CNr := GetSX3Cache("T9C_NRINSC", "X3_TAMANHO")
	endif
	if _TmV48Proc == Nil
		_TmV48Proc := GetSX3Cache("V48_PROCID", "X3_TAMANHO")
	endif

	cDataIni   := cPerApu + "01" //ex: 20220201
	cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
	cQry 	   := ""
	oPrepare   := Nil
	aBind 	   := {}
	nI    	   := 0

	cNull   := "NVL"
	cSubStr := ""
	cPosSub := "[1,6]"

	If !(_cBd $ "INFORMIX")
		cNull 	:= "COALESCE"
		//Utilização de SUBSTR: Caso utilizada, deve ser codificada na query chamando a função SUBSTRING, e a Changequery fará a troca para a função adequada de acordo com o Banco de Dados em uso.
		cSubStr := "SUBSTRING("
		cPosSub := ",1,6)"
	endif

	//Verifica se existe processo no periodo
	if _TafBindQry .And. _lHasC5O == Nil
		cSelect	:= "SELECT COUNT(C5M.C5M_FILIAL) QTDC5O FROM " + RetSqlName("C5M") + " C5M INNER JOIN " + RetSqlName("C5O") + " C5O ON "
		cSelect	+= "C5O.C5O_FILIAL = C5M.C5M_FILIAL AND C5O.C5O_ID = C5M.C5M_ID "
		cSelect += "WHERE "
		if lTmpFil //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
			cSelect	+= "C5M.C5M_FILIAL IN " + _cFiliais
		else //faz bind com aBranch
			cSelect	+= "C5M.C5M_FILIAL IN (?) "
			aadd(aBind,aBranch)
		endif
		cSelect	+= "AND C5M.C5M_DTINI >= ? AND C5M.C5M_DTFIM <= ? AND C5M.D_E_L_E_T_ = ? "
		aadd(aBind,cDataIni)
		aadd(aBind,cDataFim)
		aadd(aBind,space(1))

		TafBindQry(cSelect,@oPrepare,@aBind,@cAliasApr)
		if (cAliasApr)->QTDC5O > 0
			_lHasC5O := .T.
		else
			_lHasC5O := .F.
		endif
		(cAliasApr)->(DbCloseArea())
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
		EndIf
	endif

	//Verifica se existe ajustes no periodo
	if _TafBindQry .And. _lHasT9T == Nil
		cSelect	:= "SELECT COUNT(T9T.T9T_FILIAL) QTDT9T FROM " + RetSqlName("C5M") + " C5M INNER JOIN " + RetSqlName("T9T") + " T9T ON "
		cSelect	+= "T9T.T9T_FILIAL = C5M.C5M_FILIAL AND T9T.T9T_ID = C5M.C5M_ID "
		cSelect	+= "WHERE "
		if lTmpFil //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
			cSelect	+= "C5M.C5M_FILIAL IN " + _cFiliais
		else //faz bind com aBranch
			cSelect	+= "C5M.C5M_FILIAL IN (?) "
			aadd(aBind,aBranch)
		endif
		cSelect	+= "AND C5M.C5M_DTINI >= ? AND C5M.C5M_DTFIM <= ? AND C5M.D_E_L_E_T_ = ? "
		aadd(aBind,cDataIni)
		aadd(aBind,cDataFim)
		aadd(aBind,space(1))

		TafBindQry(cSelect,@oPrepare,@aBind,@cAliasApr)
		if (cAliasApr)->QTDT9T > 0
			_lHasT9T := .T.
		else
			_lHasT9T := .F.
		endif
		(cAliasApr)->(DbCloseArea())
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
		EndIf
	endif

	cAliasApr := ''
	If lApur
		cSelect	:= " DISTINCT C5M.C5M_FILIAL FL "
		cSelect	+= ",C5M.C5M_ID C5MID "
		cSelect	+= ",C5M.C5M_STATUS STATUS "
		cSelect	+= ",C5M.R_E_C_N_O_ C5MRECNO "
		cSelect	+= ",C5M.C5M_DTINI DTINI "
		cSelect	+= ",C5M.C5M_DTFIM DTFIM "
		cSelect	+= ",C5M.C5M_VTOT VTOT "
		cSelect	+= ",C5M.C5M_CODATI IDATIV "

		if _lHasT9T
			cSelect	+= ",T9TSUM.VLRAJU T9TVLRAJU "
		else
			cSelect	+= "," + cNull + "(0, 0) T9TVLRAJU "
		endif

		cSelect	+= "," + cNull + "(V48SUM.BASE,0) V48BASE "
		cSelect += "," + cNull + "((C5M.C5M_VATIV - V48SUM.BASE),C5M.C5M_VATIV) VLRATIV "
		cSelect += ",C5M.C5M_VEXC VEXC "
		cSelect	+= ",C5M.C5M_BASE BASE "
		cSelect	+= ",C5M.C5M_ALQCON ALQCON "

		if _lHasT9T
			cSelect += ",CASE WHEN V48SUM.BASE > ? OR T9TSUM.VLRAJU <> ? "
			cSelect += "THEN C5M.C5M_ALQCON / ? * (C5M.C5M_VATIV - (" + cNull + "(V48SUM.BASE,0) + T9TSUM.VLRAJU)) "
			cSelect += "ELSE C5M.C5M_VCON END VCON "
		else
			cSelect += ",CASE WHEN V48SUM.BASE > ? "
			cSelect += "THEN C5M.C5M_ALQCON / ? * (C5M.C5M_VATIV - (" + cNull + "(V48SUM.BASE,0))) "
			cSelect += "ELSE C5M.C5M_VCON END VCON "
		endif

		cSelect += ",C5M.C5M_CODCTA CODCTA "
		cSelect += ",C5M.C5M_INFCOM INFCOM "
		cSelect += ",C5M.C5M_VCPEXS VCPEXS "
		cSelect	+= ",C5V.C5V_CODIGO CODATIV "
		cSelect	+= ",C5V.C5V_ALQNCM C5VALQNCM "
		cSelect	+= ",C5V.C5V_DESCRI C5VDESCRI "
		cSelect += ",V48.V48_VATIV V48VATIV "
		cSelect += ",V48.V48_VCON V48VCON "
		cSelect += ",V48.V48_VEXC V48VEXC "
		cSelect += ",V48.V48_ALQCON V48ALQ "
		cSelect += ",T9C.T9C_NRINSC T9CNRINSC "
		cSelect += ",V48.R_E_C_N_O_ V48RECNO "
		cSelect += ",CASE WHEN V48.R_E_C_N_O_ IS NULL THEN C5M.C5M_PROCID ELSE V48.V48_PROCID END PROCID "
	Else
		cSelect   := " C5M.C5M_FILIAL FILIAL, C5M.C5M_VATIV - " + cNull + "(V48SUM.BASE, 0 ) VALOR, C5M.C5M_PROCID PROCID, "
		cSelect   += " ? V48FILIAL, " + cNull + "(0, 0) V48VATIV, ? V48PROCID, ? NRINSC "

		cSelV48	  := " ? FILIAL, " + cNull + "(0, 0) VALOR, ? PROCID, "
		cSelV48	  += "V48.V48_FILIAL V48FILIAL, V48.V48_VATIV V48VATIV, V48.V48_PROCID V48PROCID, T9C.T9C_NRINSC NRINSC "

		cFromV48  := RetSqlName("V48") + " V48 "

		cIJoinC5M := RetSqlName("C5M") + " C5M ON C5M.C5M_FILIAL = V48.V48_FILIAL AND C5M.C5M_ID = V48.V48_ID AND C5M.D_E_L_E_T_ = ? "

		cLeftV48  := " (SELECT V48A.V48_FILIAL FILIAL, V48A.V48_ID ID, SUM(V48A.V48_BASE) BASE FROM " + RetSqlName("V48") + " V48A WHERE V48A.D_E_L_E_T_= ? GROUP BY V48A.V48_FILIAL, V48A.V48_ID) V48SUM "
		cLeftV48  += " ON V48SUM.FILIAL = C5M.C5M_FILIAL AND V48SUM.ID = C5M.C5M_ID "

		cGroupC5M := " C5M.C5M_FILIAL, C5M.C5M_VATIV, V48SUM.BASE, C5M.C5M_PROCID "

		ciJoinT9C := RetSqlName("T9C") + " T9C ON "
		if _cCompT9C == "CCC" .Or. (_cCompT9C == "EEC" .And. aInfEUF[1]+aInfEUF[2] == 0)
			ciJoinT9C += " T9C.T9C_FILIAL = ? "
		else
			ciJoinT9C += FwJoinFilial("T9C","V48")
		endif
		ciJoinT9C += " AND T9C.T9C_ID = V48.V48_IDCNO AND T9C.D_E_L_E_T_= ? "
	EndIf

	cFromC5M := RetSqlName("C5M") + " C5M "

	cIJoinC5V := RetSqlName("C5V") + " C5V ON C5V.C5V_FILIAL = ? AND " + cSubStr + " C5V.C5V_ID" + cPosSub + " = " + cSubStr + "C5M.C5M_CODATI" + cPosSub + " AND C5V.D_E_L_E_T_ = ? "

	cLJoinV48 := RetSqlName("V48") + " V48 ON V48.V48_FILIAL = C5M.C5M_FILIAL AND V48.V48_ID = C5M.C5M_ID AND V48.D_E_L_E_T_ = ? "

	If _lHasT9T .And. lApur
		cLJoinT9T := RetSqlName("T9T") + " T9T ON T9T.T9T_FILIAL = C5M.C5M_FILIAL AND T9T.T9T_ID = C5M.C5M_ID AND T9T.D_E_L_E_T_ = ? "
	EndIf

	cLJoinT9C := RetSqlName("T9C") + " T9C ON "
	if _cCompT9C == "CCC" .Or. (_cCompT9C == "EEC" .And. aInfEUF[1]+aInfEUF[2] == 0)
		cLJoinT9C += " T9C.T9C_FILIAL = ? "
	else
		cLJoinT9C += FwJoinFilial("T9C","V48")
	endif
	cLJoinT9C += " AND T9C.T9C_ID = V48.V48_IDCNO AND T9C.D_E_L_E_T_ = ? "

	cLJoinSUM := " ( SELECT V48A.V48_FILIAL FILIAL, V48A.V48_ID ID, SUM(V48A.V48_BASE) BASE FROM " + RetSqlName("V48") + " V48A WHERE V48A.D_E_L_E_T_ = ? GROUP BY V48A.V48_FILIAL, V48A.V48_ID ) V48SUM "
	cLJoinSUM += "ON V48SUM.FILIAL = C5M.C5M_FILIAL AND V48SUM.ID = C5M.C5M_ID "

	If _lHasT9T .and. lApur
		cLJSUMT9T := " ( SELECT T9TA.T9T_FILIAL FILIAL, T9TA.T9T_ID ID, SUM(CASE WHEN T9TA.T9T_TPAJUS = ? THEN T9TA.T9T_VLRAJU * ? ELSE T9TA.T9T_VLRAJU END) VLRAJU "
		cLJSUMT9T += " FROM "+ RetSqlName("T9T") + " T9TA WHERE T9TA.D_E_L_E_T_ = ? GROUP BY T9TA.T9T_FILIAL, T9TA.T9T_ID) T9TSUM "
		cLJSUMT9T += " ON T9TSUM.FILIAL = C5M.C5M_FILIAL AND T9TSUM.ID = C5M.C5M_ID "
	EndIf

	if lTmpFil //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
		cWhere := " C5M.C5M_FILIAL IN " + _cFiliais
	else //faz bind com aBranch
		cWhere := " C5M.C5M_FILIAL IN (?) "
	endif
	cWhere += " AND C5M.C5M_DTINI >= ? AND C5M.C5M_DTFIM <= ? "
	If !lApur
		If !lIdProc
			cWhere += " AND C5M.C5M_PROCID = ? "
		EndIf
	EndiF
	cWhere += " AND C5M.D_E_L_E_T_ = ? "

	If !lApur
		if lTmpFil //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
			cWhereV48 := " C5M.C5M_FILIAL IN " + _cFiliais
		else
			cWhereV48 := " C5M.C5M_FILIAL IN (?) "
		endif
		cWhereV48 += " AND C5M.C5M_DTINI >= ? AND C5M.C5M_DTFIM <= ? AND V48.D_E_L_E_T_ = ? "
	EndIf

	cOrder := " C5M.C5M_FILIAL, C5M.C5M_CODATI, PROCID "

	If lApur
		cQry := " SELECT " + cSelect
		cQry += " FROM " + cFromC5M
		cQry += " INNER JOIN " + cIJoinC5V
		cQry += " LEFT JOIN " + cLJoinV48
		if _lHasT9T
			cQry += " LEFT JOIN " + cLJoinT9T
		endif
		cQry += " LEFT JOIN " + cLJoinT9C
		cQry += " LEFT JOIN " + cLJoinSUM
		if _lHasT9T
			cQry += " LEFT JOIN " + cLJSUMT9T
		endif
		cQry += " WHERE " + cWhere + " ORDER BY " + cOrder

		if _lHasT9T //Select
			aadd(aBind,0)
			aadd(aBind,0)
			aadd(aBind,100)
		else
			aadd(aBind,0)
			aadd(aBind,100)
		endif

		aadd(aBind,_cFilC5V) //cIJoinC5V Autocontidas não precisa amarrar com outra tabela e nao muda compartilhamento
		aadd(aBind,space(1))

		aadd(aBind,space(1)) //cLJoinV48

		if _lHasT9T //cLJoinT9T
			aadd(aBind,space(1))
		endif

		if _cCompT9C == "CCC" .Or. (_cCompT9C == "EEC" .And. aInfEUF[1]+aInfEUF[2] == 0) //cLJoinT9C
			aadd(aBind,_cFilT9C) //Cadastro pode mudar compartilhamento se for totalmente compartilhado utiliza o xFilial
		endif
		aadd(aBind,space(1))

		aadd(aBind,space(1)) //cLJoinSUM

		if _lHasT9T //cLJSUMT9T
			aadd(aBind,'1')
			aadd(aBind,-1)
			aadd(aBind,space(1))
		endif

		//cWhere Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
		if !lTmpFil //faz bind com aBranch
			aadd(aBind,aBranch)
		endif
		aadd(aBind,cDataIni) //cWhere
		aadd(aBind,cDataFim)
		aadd(aBind,space(1))

		if _TafBindQry

			TafBindQry(cQry, @oPrepare, @aBind, @cAliasApr) //query para apuracao

			aRegApur := RegPrinc( cAliasApr, @aRegApur, cPerApu, cCmpQry, aInfEUF, @aMovs, cKey, @oPrepare ) //percorre e realiza o close
		endif

	Else //!lApur Contagem para o RetSt2060 ( ok e nOk )

		cQuery := cSelect + ' FROM ' + cFromC5M
		cQuery += ' INNER JOIN ' + cIJoinC5V
		cQuery += ' LEFT JOIN ' + cLeftV48
		cQuery += ' WHERE ' + cWhere + ' GROUP BY ' + cGroupC5M

		cQuery += ' UNION '

		cQuery += ' SELECT ' + cSelV48 + ' FROM ' + cFromV48
		cQuery += ' INNER JOIN ' + cIJoinC5M
		cQuery += ' INNER JOIN ' + cIJoinC5V
		cQuery += ' INNER JOIN ' + ciJoinT9C
		cQuery += ' WHERE ' + cWhereV48

		aadd(aBind,space(_TmV48Fil)) 	//cSelect V48_FILIAL
		aadd(aBind,space(_TmV48Proc)) 	//cSelect V48_PROCID
		aadd(aBind,space(_TmT9CNr)) 	//cSelect T9C_NRINSC

		aadd(aBind,_cFilC5V) //cIJoinC5V Autocontidas não precisa amarrar com outra tabela e nao muda compartilhamento
		aadd(aBind,space(1))

		aadd(aBind,space(1)) //cLeftV48

		if !lTmpFil //cWhere
			aadd(aBind,aBranch)
		endif
		aadd(aBind,cDataIni)
		aadd(aBind,cDataFim)
		If !lIdProc
			aadd(aBind,space(1))
		endif
		aadd(aBind,space(1))

		//Union		
		aadd(aBind,space(_TmV48Fil))  //cSelV48 union com C5M_FILIAL
		aadd(aBind,space(_TmV48Proc)) //cSelV48 union com C5M_PROCID

		aadd(aBind,space(1)) //Union cIJoinC5M

		aadd(aBind,_cFilC5V) //cIJoinC5V Autocontidas não precisa amarrar com outra tabela e nao muda compartilhamento
		aadd(aBind,space(1))

		if _cCompT9C == "CCC" .Or. (_cCompT9C == "EEC" .And. aInfEUF[1]+aInfEUF[2] == 0) //ciJoinT9C
			aadd(aBind,_cFilT9C) //Cadastro pode mudar compartilhamento se for totalmente compartilhado utiliza o xFilial
		endif
		aadd(aBind,space(1))

		if !lTmpFil //cWhereV48 faz bind com aBranch
			aadd(aBind,aBranch)
		endif
		aadd(aBind,cDataIni) //cWhereV48
		aadd(aBind,cDataFim)
		aadd(aBind,space(1))

		//Nao limpar o aBind abaixo desse ponto, pois o aRegApur perde a referencia, os binds são limpos na TafBindQry
		aadd(aRegApur, {cQuery, aBind} ) 
	EndIf
Return aRegApur

//-------------------------------------------------------------------
/*/{Protheus.doc} RegPrinc
Monta a Tabela Temporária

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna os alias das TTs

/*/
//-------------------------------------------------------------------
Static Function RegPrinc( cAlias , aSintetic, cPeriod, cCmpQry, aQtdEUF,aMovs, cKey, oPrepare )

	Local aAreaSM0 		As Array
	Local aCampCabc		As Array
	Local aCmpAtiv		As Array
	Local aCmpCmpt		As Array
	Local aCampProc		As Array
	Local aCmpAjst		As Array
	Local oTTCabc		As Object
	Local oTTAtiv		As Object
	Local oTTCmpt		As Object
	Local oTTProc		As Object
	Local oTTAjst		As Object
	Local cAlsTTCabc	As Character
	Local cAlsTTAtiv	As Character
	Local cAlsTTCmpt	As Character
	Local cAlsTTProc	As Character
	Local cAlsTTAjst	As Character
	Local cChvReg		As Character
	Local cTpInsc		As Character
	Local cNrInsc		As Character
	Local cCompart		As Character

	Local cIdPai		As Character
	Local nContLaco		As Numeric
	Local nPos			As Numeric
	Local nVlrSusp		As Numeric
	Local nVlrAdc 		As Numeric
	Local nVlrExc 		As Numeric
	Local nVlrCmpt		As Numeric
	Local nX			As Numeric
	Local lAvanc		As Logical
	Local lCNO			As Logical
	Local aSM0 			as array

	Default cAlias 		:= ""
	Default aSintetic 	:= {}
	Default cPeriod 	:= ""
	Default cCmpQry 	:= ""
	Default aQtdEUF 	:= {}
	Default aMovs 		:= {}
	Default cKey 	 	:= ""
	Default oPrepare 	:= Nil

	aAreaSM0 	:= SM0->(GetArea())
	aCampCabc	:= {}
	aCmpAtiv	:= {}
	aCmpCmpt	:= {}
	aCampProc	:= {}
	aCmpAjst	:= {}
	oTTCabc		:= Nil
	oTTAtiv		:= Nil
	oTTCmpt		:= Nil
	oTTProc		:= Nil
	oTTAjst		:= Nil
	cAlsTTCabc	:= ""
	cAlsTTAtiv	:= ""
	cAlsTTCmpt	:= ""
	cAlsTTProc	:= ""
	cAlsTTAjst	:= ""	
	cChvReg		:= ""
	cTpInsc		:= ""
	cNrInsc		:= ""
	cCompart	:= ""	

	cIdPai		:= ""
	nContLaco	:= 1
	nPos 		:= 0
	nVlrSusp	:= 0
	nVlrAdc 	:= 0
	nVlrExc 	:= 0
	nVlrCmpt	:= 0
	nX			:= 0
	lAvanc		:= .T.
	lCNO		:= .F.
	aSM0		:= {}

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())

		cCompart := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3))) // 1=Empresa, 2=Unidade de Negócio e 3=Filial

		cAlsTTCabc	:= GetNextAlias() //CAB		
		cAlsTTAtiv	:= GetNextAlias() //ATIV
		cAlsTTCmpt	:= GetNextAlias() //COMPLEMENTO
		cAlsTTProc	:= GetNextAlias() //PROCESSO
		cAlsTTAjst 	:= GetNextAlias() //AJUSTE

		// Cria a estrutura (array) das temporary table
		PopArray(@aCampCabc,@aCmpAtiv,@aCmpCmpt,@aCampProc,@aCmpAjst,cPeriod)

		// Instancia o objeto Temporary Table
		oTTCabc	:= FWTemporaryTable():New(cAlsTTCabc, aCampCabc)
		oTTAtiv	:= FWTemporaryTable():New(cAlsTTAtiv, aCmpAtiv)
		oTTCmpt	:= FWTemporaryTable():New(cAlsTTCmpt, aCmpCmpt)
		oTTProc	:= FWTemporaryTable():New(cAlsTTProc, aCampProc)			
		oTTAjst	:= FWTemporaryTable():New(cAlsTTAjst, aCmpAjst)

		// Seta os devidos indices 
		PopIdxObj(@oTTCabc,@oTTAtiv,@oTTProc,@oTTAjst,@oTTCmpt,cPeriod)

		DbSelectArea(cAlsTTCabc)
		(cAlsTTCabc)->(DbSetOrder(2)) //"CPERIODO","CTPINSC","CNRINSC"

		DbSelectArea(cAlsTTAtiv)
		(cAlsTTAtiv)->(DbSetOrder(2)) //"CPERIODO","CTPINSC","CNRINSC","IDATIV"

		DbSelectArea(cAlsTTCmpt)
		(cAlsTTCmpt)->(DbSetOrder(2)) //"CHAVE","C5NID"

		DbSelectArea(cAlsTTProc)
		(cAlsTTProc)->(DbSetOrder(2)) //"CHAVE","C1GTPPROC","C1GNUMPRO","CODSUS"

		DbSelectArea(cAlsTTAjst)
		(cAlsTTAjst)->(DbSetOrder(2)) //"CHAVE","DTAJUS","CTPAJST","CCODAJST"

		(cAlias)->(DbGoTop())
		While (cAlias)->(!EOF())

			If (cAlias)->(VLRATIV) == 0 .OR. lCNO
				cTpInsc	:= '4'
				cNrInsc	:= (cAlias)->(T9CNRINSC)
				lCNO	:= .F.
			Else
				aSM0 := FWSM0Util( ):GetSM0Data(cEmpAnt ,(cAlias)->FL , { 'M0_CGC','M0_TPINSC' } )
				cNrInsc	:= aSM0[1][2]
				cTpInsc := aSM0[2][2]
				If cValToChar(cTpInsc) == "2" .Or. cValToChar(cTpInsc) == "0"
					cTpInsc	:=	'1'
				Endif
			EndIf

			If (Empty(cKey) .or. cPeriod + cTpInsc + AllTrim(cNrInsc) $ cKey)
				If cTpInsc == '4'
					if _aFils == Nil
				    	_aFils := wsLoadFil()
					endif
					aRet := RetFilId(cNrInsc)
					For nX := 1 to Len(aRet)
						if aScan(aMovs, { |x| x[2] == aRet[nX] .and. x[3] == "V48"}) == 0
							AADD(aMovs,{"CPRB", aRet[nX], "V48" })
						EndIf
					Next nX
				Else
					AADD(aMovs,{"CPRB", (cAlias)->C5MRECNO, "C5M" })
				EndIf
			ElseIf Empty(cKey)
				AADD(aMovs,{"CPRB", (cAlias)->C5MRECNO, "C5M" })
			EndIf

			If cIDPai != (cAlias)->(C5MID) .AND. (cAlias)->(VLRATIV) == 0
				AADD(aMovs,{"CPRB", (cAlias)->C5MRECNO, "C5M" })
			EndIf

			cNrInsc:= SubStr(cNrInsc, 1, 14)

			If nContLaco++ == 1 .Or. cChvReg <> cPeriod + cTpInsc + cNrInsc + Substr( (cAlias)->IDATIV,1,6 )				
				cChvReg := cPeriod + cTpInsc + cNrInsc + Substr( (cAlias)->IDATIV,1,6 )
				nVlrSusp := nVlrExc := nVlrAdc := 0 
			EndIf

			if _lHasC5O //PROCESSO
				RetProc(cAlsTTProc, cAlias, aCampProc,	cChvReg, (cAlias)->C5MID, (cAlias)->IDATIV, cCompart, aQtdEUF, @nVlrSusp)
			endif

			if _lHasT9T //AJUSTE
				RetAjst(cAlsTTAjst, cAlias, aCmpAjst, cChvReg, (cAlias)->C5MID, (cAlias)->IDATIV, @nVlrExc, @nVlrAdc)
			endif

			If cIDPai != (cAlias)->(C5MID)
				lCNO	:= .F.
				cIDPai	:= (cAlias)->(FL) + (cAlias)->(C5MID)
			EndIf

			If !(cAlsTTAtiv)->(DbSeek( cPeriod + cTpInsc + cNrInsc + Substr( (cAlias)->IDATIV,1,6 )))

				If (cAlias)->(VLRATIV) > 0 .AND. cTpInsc == '1'  //Se estiver zerado, entende que apenas os valores dos filhos (V48) deve ser levado

					RecLock(cAlsTTAtiv,.T.)
						(cAlsTTAtiv)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTAtiv)->CPERIODO	:= cPeriod
						(cAlsTTAtiv)->CTPINSC	:= cTpInsc 
						(cAlsTTAtiv)->CNRINSC	:= cNrInsc
						(cAlsTTAtiv)->RECNO 	:= (cAlias)->C5MRECNO					
						(cAlsTTAtiv)->IDATIV	:= (cAlias)->IDATIV
						(cAlsTTAtiv)->CODATIV	:= (cAlias)->CODATIV
						(cAlsTTAtiv)->CDSATIV	:= (cAlias)->C5VDESCRI
						(cAlsTTAtiv)->ALQATIV	:= (cAlias)->ALQCON
						(cAlsTTAtiv)->T9TVEXC	:= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	:= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	:= (cAlias)->VLRATIV
						(cAlsTTAtiv)->VLRCPRBAP := (cAlias)->VCON					
						(cAlsTTAtiv)->C5MVEXC	:= (cAlias)->VEXC
						(cAlsTTAtiv)->ID		:= (cAlias)->C5MID
						(cAlsTTAtiv)->FILIAL	:= (cAlias)->FL
						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->VLRATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->VLRATIV + nVlrAdc) - (cAlias)->VEXC 
						endif
					(cAlsTTAtiv)->(MsUnlock())
					lCNO:= Iif( !Empty((cAlias)->(T9CNRINSC)),.T. ,.F. )

				ElseIf cIDPai != (cAlias)->(C5MID) .AND. (cAlias)->(VLRATIV) == 0
					RecLock(cAlsTTAtiv,.T.)
						(cAlsTTAtiv)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTAtiv)->CPERIODO	:= cPeriod
						(cAlsTTAtiv)->CTPINSC	:= cTpInsc
						(cAlsTTAtiv)->CNRINSC	:= cNrInsc
						(cAlsTTAtiv)->RECNO 	:= (cAlias)->C5MRECNO					
						(cAlsTTAtiv)->IDATIV	:= (cAlias)->IDATIV
						(cAlsTTAtiv)->CODATIV	:= (cAlias)->CODATIV
						(cAlsTTAtiv)->CDSATIV	:= (cAlias)->C5VDESCRI
						(cAlsTTAtiv)->ALQATIV	:= (cAlias)->V48ALQ
						(cAlsTTAtiv)->T9TVEXC	:= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	:= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	:= (cAlias)->V48VATIV
						(cAlsTTAtiv)->VLRCPRBAP := (cAlias)->V48VCON					
						(cAlsTTAtiv)->C5MVEXC	:= (cAlias)->V48VEXC
						(cAlsTTAtiv)->ID		:= (cAlias)->C5MID
						(cAlsTTAtiv)->FILIAL	:= (cAlias)->FL
						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - (cAlias)->VEXC 
						endif
					(cAlsTTAtiv)->(MsUnlock())
				ElseIf cTpInsc == '4' 
					RecLock(cAlsTTAtiv,.T.)
						(cAlsTTAtiv)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTAtiv)->CPERIODO	:= cPeriod
						(cAlsTTAtiv)->CTPINSC	:= cTpInsc
						(cAlsTTAtiv)->CNRINSC	:= cNrInsc
						(cAlsTTAtiv)->RECNO 	:= (cAlias)->C5MRECNO					
						(cAlsTTAtiv)->IDATIV	:= (cAlias)->IDATIV
						(cAlsTTAtiv)->CODATIV	:= (cAlias)->CODATIV
						(cAlsTTAtiv)->CDSATIV	:= (cAlias)->C5VDESCRI
						(cAlsTTAtiv)->ALQATIV	:= (cAlias)->ALQCON
						(cAlsTTAtiv)->T9TVEXC	:= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	:= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	:= (cAlias)->V48VATIV
						(cAlsTTAtiv)->VLRCPRBAP := (cAlias)->V48VCON					
						(cAlsTTAtiv)->C5MVEXC	:= (cAlias)->VEXC
						(cAlsTTAtiv)->ID		:= (cAlias)->C5MID
						(cAlsTTAtiv)->FILIAL	:= (cAlias)->FL
						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - (cAlias)->VEXC 
						endif
					(cAlsTTAtiv)->(MsUnlock())					
				EndIf
			Else
				If cTpInsc == "1" 
					RecLock(cAlsTTAtiv,.F.)
						(cAlsTTAtiv)->T9TVEXC	+= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	+= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	+= (cAlias)->VLRATIV
						(cAlsTTAtiv)->VLRCPRBAP += (cAlias)->VCON
						(cAlsTTAtiv)->C5MVEXC	+= (cAlias)->VEXC
						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	+= ((cAlias)->VLRATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	+= ((cAlias)->VLRATIV + nVlrAdc) - (cAlias)->VEXC
						endif
					(cAlsTTAtiv)->(MsUnlock())
					lCNO := Iif( !Empty((cAlias)->(T9CNRINSC)),.T. ,.F. )
				Else
					RecLock(cAlsTTAtiv,.F.)
						(cAlsTTAtiv)->T9TVEXC	+= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	+= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	+= (cAlias)->V48VATIV
						(cAlsTTAtiv)->VLRCPRBAP += (cAlias)->V48VCON
						(cAlsTTAtiv)->C5MVEXC	+= (cAlias)->V48VEXC

						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - (cAlias)->VEXC 
						endif
					(cAlsTTAtiv)->(MsUnlock())
				EndIf
			EndIf

			//CABEÇALHO
			If !(cAlsTTCabc)->(DbSeek(cPeriod + cTpInsc + cNrInsc))
				If cTpInsc == '1' .AND. (cAlias)->(VLRATIV) > 0
					RecLock(cAlsTTCabc,.T.)
						(cAlsTTCabc)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTCabc)->CPERIODO	:= cPeriod
						(cAlsTTCabc)->CTPINSC 	:= cTpInsc
						(cAlsTTCabc)->CNRINSC	:= cNrInsc
						(cAlsTTCabc)->VLRECBTT	:= (cAlias)->VLRATIV
						(cAlsTTCabc)->VLCPAPUT	:= (cAlias)->VCON
						(cAlsTTCabc)->VLCSUSPT	:= nVlrSusp
						(cAlsTTCabc)->ID		:= (cAlias)->C5MID
						(cAlsTTCabc)->FILIAL	:= (cAlias)->FL
						(cAlsTTCabc)->PROCID	:= (cAlias)->PROCID
					(cAlsTTCabc)->(MsUnlock())
				Else
					RecLock(cAlsTTCabc,.T.)
						(cAlsTTCabc)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTCabc)->CPERIODO	:= cPeriod
						(cAlsTTCabc)->CTPINSC 	:= cTpInsc
						(cAlsTTCabc)->CNRINSC	:= cNrInsc
						(cAlsTTCabc)->VLRECBTT	:= (cAlias)->V48VATIV
						(cAlsTTCabc)->VLCPAPUT	:= (cAlias)->V48VCON
						(cAlsTTCabc)->VLCSUSPT	:= nVlrSusp
						(cAlsTTCabc)->ID		:= (cAlias)->C5MID
						(cAlsTTCabc)->FILIAL	:= (cAlias)->FL
						(cAlsTTCabc)->PROCID	:= (cAlias)->PROCID
					(cAlsTTCabc)->(MsUnlock())
					lCNO	:= .F.
				EndIf
			Else
				RecLock(cAlsTTCabc,.F.)
				If cTpInsc == '1'
					(cAlsTTCabc)->VLRECBTT += (cAlias)->VLRATIV
					(cAlsTTCabc)->VLCPAPUT += (cAlias)->VCON
					(cAlsTTCabc)->VLCSUSPT += nVlrSusp
				Else
					(cAlsTTCabc)->VLRECBTT	+= (cAlias)->V48VATIV
					(cAlsTTCabc)->VLCPAPUT	+= (cAlias)->V48VCON
					(cAlsTTCabc)->VLCSUSPT	+= nVlrSusp
					lCNO	:= .F.
				EndIf
				(cAlsTTCabc)->(MsUnlock())
			EndIf
			//Identificou que aquela linha do pai possui um filho então não deve dar DbSkip()
			if !lCNO	
				(cAlias)->(DbSkip())
			endif
		EndDo
	Else
		lAvanc := .F.
	EndIf

	(cAlias)->(DbCloseArea())

	If oPrepare != Nil
		oPrepare:Destroy()
		oPrepare := nil
	EndIf

	RestArea(aAreaSM0)

Return	{	{cAlsTTCabc	,oTTCabc},;
 			{cAlsTTAtiv	,oTTAtiv},;
 			{cAlsTTCmpt	,oTTCmpt},;
 			{cAlsTTProc	,oTTProc},;
 			{cAlsTTAjst	,oTTAjst},;
 			lAvanc }

//-------------------------------------------------------------------
/*/{Protheus.doc} RetAjst

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Nil

/*/ 
//-------------------------------------------------------------------
Static Function RetAjst(cAlsTTAjst, cAlias, aCampProc, cChavAjst, cC5MId, cIdAtiv, nVlrExc, nVlrAdc)

	Local cSelect	AS Character
	Local cFrom		AS Character
	Local cWhere	AS Character
	Local cAliasT9T	AS Character
	Local cChavSeek	AS Character
	Local cQry		As Character
	Local oPrepT9T 	As Object
	Local aBind 	As Array
	Local nI    	As Numeric

	Default cAlsTTAjst 	:= ''
 	Default cAlias		:= ''
 	Default aCampProc	:= {}
 	Default cChavAjst	:= ''
 	Default cC5MId		:= ''
 	Default cIdAtiv		:= ''
 	Default nVlrExc		:= 0
 	Default nVlrAdc		:= 0

	cSelect		:= ''
	cFrom		:= ''
	cWhere		:= ''
	cChavSeek	:= ''

	cQry        := ''
	oPrepT9T 	:= nil
	aBind 		:= {}
	nI    		:= 0

	cQry := "SELECT ? CHAVE "
	cQry += ",T9T.T9T_TPAJUS TPAJUS "
	cQry += ",T9T.T9T_CODAJU CODAJU "
	cQry += ",T9T.T9T_VLRAJU VLRAJU "
	cQry += ",T9T.T9T_DESCAJ DESCAJ "
	cQry += ",T9T.T9T_DTAJUS DTAJUS "
	cQry += ",T9T.T9T_CODSEQ CODSEQ "
	cQry += "FROM " + RetSqlName("T9T") + " T9T "
	cQry += "WHERE T9T.T9T_FILIAL = ? AND T9T.T9T_ID = ? AND T9T.D_E_L_E_T_ = ? "

	aadd(aBind,cChavAjst)
	aadd(aBind,(cAlias)->FL)
	aadd(aBind,(cAlias)->C5MID)
	aadd(aBind,space(1))

	If !Md5(cQry) == _cQry2MD5
		cQry := ChangeQuery(cQry)
		_cQry2MD5 := Md5(cQry)
	endif

	if _TafBindQry
		TafBindQry(cQry,@oPrepT9T,@aBind,@cAliasT9T)

		If !(cAliasT9T)->(EOF())
			While !(cAliasT9T)->(EOF())
				cChavSeek := PADR((cAliasT9T)->CHAVE, 21 + _nTmAtiv) + (cAliasT9T)->DTAJUS + (cAliasT9T)->TPAJUS + (cAliasT9T)->CODAJU
				If !(cAlsTTAjst)->(MsSeek(cChavSeek))
					RecLock(cAlsTTAjst, .T.)
						(cAlsTTAjst)->CHAVE		:= (cAliasT9T)->CHAVE
						(cAlsTTAjst)->DTAJUS	:= (cAliasT9T)->DTAJUS
						(cAlsTTAjst)->IDATIV	:= cIdAtiv
						(cAlsTTAjst)->CTPAJST	:= (cAliasT9T)->TPAJUS
						(cAlsTTAjst)->CCODAJST	:= (cAliasT9T)->CODAJU
						(cAlsTTAjst)->VLRAJST	:= (cAliasT9T)->VLRAJU
						(cAlsTTAjst)->DSCAJST	:= (cAliasT9T)->DESCAJ
					(cAlsTTAjst)->(MsUnlock())
				Else
					RecLock(cAlsTTAjst, .F.)
						(cAlsTTAjst)->VLRAJST += (cAliasT9T)->VLRAJU
					(cAlsTTAjst)->(MsUnlock())
				EndIf

				If (cAliasT9T)->TPAJUS == "0"
					nVlrExc += (cAliasT9T)->VLRAJU
				ElseIf (cAliasT9T)->TPAJUS == "1"
					nVlrAdc += (cAliasT9T)->VLRAJU	
				Endif

				(cAliasT9T)->(DbSkip())
			EndDo
		EndIf

		If oPrepT9T != Nil
			oPrepT9T:Destroy()
			freeObj(oPrepT9T)
			oPrepT9T := Nil
		EndIf

		(cAliasT9T)->(DbCloseArea())
	endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetProc

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Nil

/*/
//-------------------------------------------------------------------
Static Function RetProc(cAlsTTProc, cAlias, aCampProc, cChavProc, cIdCPRB, cIdAtiv, cCompC1G, aSM0EUF, nVlrSusp)
	
	Local aRet		As Array
	Local cChave	AS Character
	Local cAliasC5O	AS Character
	Local cChavSeek	AS Character
	Local nTam		As Numeric
	Local lFormat	As Logical
	Local lProcessa	As Logical
	Local cQry		As Character
	Local oPrepG1G 	As Object
	Local aBind 	As Array
	Local nI    	As Numeric
	Local cTInscri	AS Character
	Local cJoinC1G  AS Character

	Default cAlsTTProc 	:= ''
	Default cAlias 		:= ''
	Default aCampProc 	:= {}
	Default cChavProc 	:= ''
	Default cIdCPRB 	:= ''
	Default cIdAtiv 	:= ''
	Default cCompC1G 	:= ''
	Default aSM0EUF 	:= {}
	Default nVlrSusp 	:= 0

	aRet		:= {}
	cChave		:= ''
	cChavSeek	:= ''
	nTam		:= 0
	lFormat		:= .F.
	lProcessa	:= .F.
	cQry        := ''
	oPrepG1G 	:= Nil
	aBind 		:= {}
	nI    		:= 0
	cTInscri	:= ''
	cJoinC1G	:= ''

	cQry := "SELECT ? CHAVE "
	cQry += ",C5O.C5O_FILIAL C5OFILIAL "
	cQry += ",C5O.C5O_NUMPRO NUMPRO "
	cQry += ",C5O.C5O_IDSUSP IDSUSP "
	cQry += ",T5L.T5L_CODSUS CODSUS "
	cQry += ",C5O.C5O_VLEXSU VALSUS "
	cQry += ",C1G.C1G_TPPROC C1GTPPROC "
	cQry += ",C1G.C1G_NUMPRO C1GNUMPRO "
	cQry += ",C1G.C1G_ID C1GID "
	cQry += ",C1G.C1G_VERSAO C1GVERSAO "
	cQry += ",C1G.C1G_FILIAL C1GFILIAL "

	cQry += " FROM " + RetSqlName("C5O") + " C5O "

	cQry += " INNER JOIN " + RetSqlName("C1G") + " C1G ON "

	cJoinC1G := ''
	If cCompC1G == 'EEE'
		cJoinC1G += " C1G.C1G_FILIAL = C5O.C5O_FILIAL AND "	 
	Else
		If cCompC1G == 'EEC'
			nTam := aSM0EUF[DEFEMP] + aSM0EUF[DEFUND]
			nTam += iif(nTam == 0, aSM0EUF[DEFFIL], 0)
			lFormat := .T.
		ElseIf cCompC1G == 'ECC'
			nTam := aSM0EUF[DEFEMP]
			nTam += iif(nTam == 0, aSM0EUF[DEFFIL], 0)
			lFormat := .T.
		EndIf
		if lFormat
			If _cBd $ "ORACLE|POSTGRES|DB2"
				cJoinC1G += " C1G.C1G_FILIAL = SUBSTR(C5O.C5O_FILIAL,1," + cValToChar(nTam) + " ) AND "
			ElseIf _cBd $ "INFORMIX"
				cJoinC1G += " C1G.C1G_FILIAL = C5O.C5O_FILIAL[1," + cValToChar(nTam) + "] AND "
			Else //MSSQL,MYSQL,PROGRESS
				cJoinC1G += " C1G.C1G_FILIAL = SUBSTRING(C5O.C5O_FILIAL,1," + cValToChar(nTam) + " ) AND "
			EndIf
		EndIf		
	EndIf
	cJoinC1G += " C1G.C1G_ID = C5O.C5O_NUMPRO AND C1G.D_E_L_E_T_ = ? "
	cQry += cJoinC1G

	if  _cBd $ "POSTGRES" //problema com espacamento no postgres
		cQry += " INNER JOIN " + RetSqlName("T5L") + " T5L ON T5L.T5L_FILIAL = C1G.C1G_FILIAL AND SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(_nTmIdSus)+") = C5O.C5O_IDSUSP "
	Else
		cQry += " INNER JOIN " + RetSqlName("T5L") + " T5L ON T5L.T5L_FILIAL = C1G.C1G_FILIAL AND T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS = C5O.C5O_IDSUSP "
	Endif

	cQry += " AND T5L.D_E_L_E_T_ = ? "

	cQry += " WHERE C5O.C5O_FILIAL = ? AND C5O.C5O_ID = ? AND C5O.D_E_L_E_T_ = ? "

	cQry += " ORDER BY C5O.C5O_FILIAL, C5O.C5O_NUMPRO, C5O.C5O_IDSUSP "

	aadd(aBind,cChavProc)
	aadd(aBind,space(1))
	aadd(aBind,space(1))
	aadd(aBind,(cAlias)->FL)
	aadd(aBind,(cAlias)->C5MID)
	aadd(aBind,space(1))

	If !Md5(cQry) == _cQry1MD5
		cQry := ChangeQuery(cQry)
		_cQry1MD5 := Md5(cQry)
	endif

	if _TafBindQry
		TafBindQry(cQry,@oPrepG1G,@aBind,@cAliasC5O)

		nVlrSusp := 0
		If !(cAliasC5O)->(EOF())
			While !(cAliasC5O)->(EOF())
				cTInscri := '1'
				if (cAliasC5O)->C1GTPPROC == '1'
					cTInscri := '2'
				endif
				cChavSeek := (cAliasC5O)->CHAVE + cTInscri + (cAliasC5O)->C1GNUMPRO + (cAliasC5O)->CODSUS
				If !(cAlsTTProc)->(MsSeek(cChavSeek))
					RecLock(cAlsTTProc, .T.)
					(cAlsTTProc)->CHAVE		:= (cAliasC5O)->CHAVE
					(cAlsTTProc)->IDATIV	:= cIdAtiv
					(cAlsTTProc)->C1GTPPROC	:= cTInscri
					(cAlsTTProc)->C1GNUMPRO	:= (cAliasC5O)->C1GNUMPRO
					(cAlsTTProc)->IDSUSP	:= (cAliasC5O)->IDSUSP
					(cAlsTTProc)->CODSUS	:= (cAliasC5O)->CODSUS
					(cAlsTTProc)->NUMPRO	:= (cAliasC5O)->NUMPRO				
					(cAlsTTProc)->VALSUS	:= (cAliasC5O)->VALSUS				
					(cAlsTTProc)->C1GID		:= (cAliasC5O)->C1GID
					(cAlsTTProc)->C1GVERSAO	:= (cAliasC5O)->C1GVERSAO
					(cAlsTTProc)->C1GFILIAL	:= (cAliasC5O)->C1GFILIAL
					(cAlsTTProc)->(MsUnlock())
				Else
					RecLock(cAlsTTProc, .F.)
					(cAlsTTProc)->VALSUS 	+= (cAliasC5O)->VALSUS
					(cAlsTTProc)->(MsUnlock())
				EndIf
				nVlrSusp += (cAliasC5O)->VALSUS
				(cAliasC5O)->(DbSkip())
			EndDo
		EndIf

		If oPrepG1G != Nil
			oPrepG1G:Destroy()
			freeObj(oPrepG1G)
			oPrepG1G := nil
		EndIf
		(cAliasC5O)->(DbCloseArea())
	endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2060
Efetua gravação no modelo da tabela espelho do evento R-2060 (CPRB)

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------
Static Function Grava2060(nOpc, cPerApu, aApuracao, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, aErro, cIdV0S, lValid, cStatus, cFilT9V )

	Local cId 			As Character
	Local cAtiv			As Character
	Local cEvento		As Character
	Local cChaveReg		As Character
	Local cTipo 		As Character
	Local lVldData		As Logical
	Local lVldProc		As Logical
	Local lRollBack		As Logical
	Local nContLaco		As Numeric
	Local nContV0U 	 	As Numeric
	Local nContV0V  	As Numeric
	Local nContV0T		As Numeric
	Local nErro			As Numeric
	Local nAdic			As Numeric
	Local nExcl			As Numeric
	Local nBase			As Numeric	
	Local nSomaCPRB		As Numeric
	Local oModel		As Object
	Local oModelV0S		As Object
	Local oModelV0T		As Object
	Local oModelV0U		As Object
	Local oModelV0V		As Object	
	Local aListErro		As Array
	Local aProcErro		As Array

	Default nOpc		:= 0
	Default cPerApu 	:= ''
	Default aApuracao	:= {}
	Default aInfoC1E	:= {}
	Default cVerAnt		:= ''
	Default cProTpn		:= ''
	Default cIdApReinf	:= ''
	Default aErro		:= {}
	Default cIdV0S		:= ''
	Default lValid		:= .F.
	Default cStatus		:= ''
	Default cFilT9V		:= ''

	cId			:= ""
	cAtiv		:= ""
	cEvento		:= "I"
	cChaveReg	:= ""
	cTipo		:= ""
	lVldData	:= .T.
	lVldProc	:= .T.
	lRollBack	:= .T.
	nContLaco	:= 1 
	nContV0U	:= 1
	nContV0V	:= 1
	nContV0T	:= 1
	nErro		:= 0
	nAdic		:= 0
	nExcl		:= 0
	nBase		:= 0
	nSomaCPRB 	:= 0 		
	oModel		:= Nil
	oModelV0S	:= Nil
	oModelV0T	:= Nil
	oModelV0U	:= Nil
	oModelV0V	:= Nil
	aListErro	:= {}
	aProcErro 	:= {}

	T9V->(DbSetOrder(1))

	(aApuracao[ATIVIDADE])->(DbSetOrder(1)) //CHAVE
	(aApuracao[ATIVIDADE])->(DbGoTop())

	(aApuracao[PROCESSOS])->(DbSetOrder(1)) //CHAVE
	(aApuracao[PROCESSOS])->(DbGoTop())

	(aApuracao[AJUSTE])->(DbSetOrder(1)) 	//CHAVE
	(aApuracao[AJUSTE])->(DbGoTop())

	oModel 		:= FWLoadModel("TAFA499")
	oModelV0S 	:= oModel:GetModel("MODEL_V0S")
	oModelV0T 	:= oModel:GetModel("MODEL_V0T")
	oModelV0U 	:= oModel:GetModel("MODEL_V0U")
	oModelV0V 	:= oModel:GetModel("MODEL_V0V")
		
	oModel:SetOperation(nOpc)
	oModel:Activate()

	If !Empty(cVerAnt)
		oModel:LoadValue('MODEL_V0S', 'V0S_VERANT'	, cVerAnt)
		oModel:LoadValue('MODEL_V0S', 'V0S_PROTPN'	, cProTpn)
		oModel:LoadValue('MODEL_V0S', 'V0S_ID'		, cIdV0S)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'		
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel:LoadValue('MODEL_V0S', 'V0S_PERAPU'	, cPerApu) //MMAAAA 042018 
	oModel:LoadValue('MODEL_V0S', 'V0S_EVENTO'	, cEvento)
	oModel:LoadValue('MODEL_V0S', 'V0S_VERSAO'  , xFunGetVer())
	oModel:LoadValue('MODEL_V0S', 'V0S_TPINSC'	, (aApuracao[SINTETICO])->CTPINSC)
	oModel:LoadValue('MODEL_V0S', 'V0S_NRINSC'	, (aApuracao[SINTETICO])->CNRINSC)
	oModel:LoadValue('MODEL_V0S', 'V0S_VLRBRT'	, (aApuracao[SINTETICO])->VLRECBTT)
	oModel:LoadValue('MODEL_V0S', 'V0S_VLCPAP'	, (aApuracao[SINTETICO])->VLCPAPUT)
	oModel:LoadValue('MODEL_V0S', 'V0S_VLSCPR'	, (aApuracao[SINTETICO])->VLCSUSPT)

	If !oModelV0S:VldData()
		lVldData := .F.
	EndIf

	//ATIVIDADE
	If (aApuracao[ATIVIDADE])->(DbSeek((aApuracao[SINTETICO])->CHAVE))

		While !(aApuracao[ATIVIDADE])->(Eof()) .And. (aApuracao[SINTETICO])->CHAVE == (aApuracao[ATIVIDADE])->CHAVE

			nContV0U := nContV0V := 1
			nAdic := nExcl := nBase := 0

			If nContLaco++ > 1 .And. (!oModelV0T:VldData())
				lVldData := .F.
			EndIf

			If nContV0T++ == 1 .Or. cId + cAtiv <> (aApuracao[ATIVIDADE])->CHAVE + (aApuracao[ATIVIDADE])->IDATIV
				cId 	:= (aApuracao[ATIVIDADE])->CHAVE
				cAtiv 	:= (aApuracao[ATIVIDADE])->IDATIV
				
				if nOpc == MODEL_OPERATION_INSERT 
					oModelV0T:AddLine()
				endif

				oModel:LoadValue('MODEL_V0T','V0T_IDATIV', SubStr(AllTrim((aApuracao[ATIVIDADE])->IDATIV),1,6))
				oModel:LoadValue('MODEL_V0T','V0T_CDATIV', (aApuracao[ATIVIDADE])->CODATIV)					
				oModel:LoadValue('MODEL_V0T','V0T_DESATV', (aApuracao[ATIVIDADE])->CDSATIV)
				oModel:LoadValue('MODEL_V0T','V0T_ALQCON', (aApuracao[ATIVIDADE])->ALQATIV)
				oModel:LoadValue('MODEL_V0T','V0T_VLBTAT', (aApuracao[ATIVIDADE])->C5MVATIV)

					//AJUSTE
					If lVldData
						If (aApuracao[AJUSTE])->(DbSeek((aApuracao[ATIVIDADE])->CHAVE+(aApuracao[ATIVIDADE])->IDATIV))
							While !(aApuracao[AJUSTE])->(Eof()) .And. ((aApuracao[AJUSTE])->CHAVE == (aApuracao[ATIVIDADE])->CHAVE + (aApuracao[ATIVIDADE])->IDATIV)
								if ++nContV0U > 2 .And. nOpc == MODEL_OPERATION_INSERT
									oModelV0U:AddLine()
								endif
								If nContV0U > 1 .And. (!oModelV0U:VldData())
									lVldData := .F.
								EndIf
								
								if (aApuracao[AJUSTE])->CTPAJST == "0"
									nExcl += (aApuracao[AJUSTE])->VLRAJST
								else
									nAdic += (aApuracao[AJUSTE])->VLRAJST
								endif
								oModel:LoadValue('MODEL_V0U','V0U_IDATIV', SubStr(AllTrim((aApuracao[AJUSTE])->IDATIV),1,6))
								oModel:LoadValue('MODEL_V0U','V0U_DTAJUS',  (aApuracao[AJUSTE])->DTAJUS)
								oModel:LoadValue('MODEL_V0U','V0U_TPAJUS', (aApuracao[AJUSTE])->CTPAJST)
								oModel:LoadValue('MODEL_V0U','V0U_CODAJU', (aApuracao[AJUSTE])->CCODAJST)
								oModel:LoadValue('MODEL_V0U','V0U_VLRAJU', (aApuracao[AJUSTE])->VLRAJST)
								oModel:LoadValue('MODEL_V0U','V0U_DESAJU', (aApuracao[AJUSTE])->DSCAJST)
								(aApuracao[AJUSTE])->(DbSkip())
							EndDo
						EndIf
					EndIf

				oModel:LoadValue('MODEL_V0T','V0T_VLARBT', nAdic )

				if nExcl > 0
					oModel:LoadValue('MODEL_V0T','V0T_VLERBT', nExcl )				
					nBase += ((aApuracao[ATIVIDADE])->C5MVATIV + nAdic) - nExcl
				else
					oModel:LoadValue('MODEL_V0T','V0T_VLERBT', (aApuracao[ATIVIDADE])->C5MVEXC )
					nBase += ((aApuracao[ATIVIDADE])->C5MVATIV + nAdic) - (aApuracao[ATIVIDADE])->C5MVEXC
				endif
				oModel:LoadValue('MODEL_V0T','V0T_VLBCPR', nBase )
				oModel:LoadValue('MODEL_V0T','V0T_CPRBAP', Round(((aApuracao[ATIVIDADE])->ALQATIV / 100) * nBase, 2))

				nSomaCPRB += Round(((aApuracao[ATIVIDADE])->ALQATIV / 100) * nBase, 2)

				//PROCESSO
				If lVldData .And. lVldProc
					if (aApuracao[PROCESSOS])->(DbSeek((aApuracao[ATIVIDADE])->CHAVE+(aApuracao[ATIVIDADE])->IDATIV))
						While !(aApuracao[PROCESSOS])->(Eof()) .And. (aApuracao[PROCESSOS])->CHAVE == (aApuracao[ATIVIDADE])->CHAVE + (aApuracao[ATIVIDADE])->IDATIV
							if ++nContV0V > 2 .And. nOpc == MODEL_OPERATION_INSERT
								oModelV0V:AddLine()
							endif
							If nContV0V > 1 .And. (!oModelV0V:VldData())
								lVldData := .F.
							EndIf
							oModel:LoadValue('MODEL_V0V','V0V_IDPROC', (aApuracao[PROCESSOS])->NUMPRO)
							oModel:LoadValue('MODEL_V0V','V0V_TPPROC', (aApuracao[PROCESSOS])->C1GTPPROC)
							oModel:LoadValue('MODEL_V0V','V0V_NRPROC', (aApuracao[PROCESSOS])->C1GNUMPRO)
							oModel:LoadValue('MODEL_V0V','V0V_CODSUS', (aApuracao[PROCESSOS])->CODSUS)
							oModel:LoadValue('MODEL_V0V','V0V_IDSUSP', (aApuracao[PROCESSOS])->IDSUSP)
							oModel:LoadValue('MODEL_V0V','V0V_VALSUS', (aApuracao[PROCESSOS])->VALSUS)

							//Verifica Processo
							T9V->(DbSetOrder(5)) //cFIlAnt, T9V_ID, T9V_ATIVO
							If !T9V->(DbSeek( cFilT9V + (aApuracao[PROCESSOS])->C1GID + "1" ))
								lVldProc := .F.
								Aadd(aProcErro,{Nil ,Alltrim((aApuracao[PROCESSOS])->C1GNUMPRO), NIl, oModel:GetErrorMessage() } )
							EndIf
							(aApuracao[PROCESSOS])->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
			(aApuracao[ATIVIDADE])->(DbSkip())
		EndDo
	EndIf

	//Atualiza valor total da CPRB conforme valores calculados
	oModel:LoadValue('MODEL_V0S', 'V0S_VLCPAP', nSomaCPRB)

	If lVldData .And. oModel:VldData() .And. lVldProc
		FwFormCommit(oModel)
		TafEndGRV( "V0S","V0S_PROCID", cIdApReinf, V0S->(Recno()), "R2060")
		TafXLog( cIdApReinf, "R-2060", "MSG", "Registro Gravado com sucesso." + CRLF + (aApuracao[SINTETICO])->CTPINSC + '|' + (aApuracao[SINTETICO])->CNRINSC )
	    lRollBack := .T.
	Else
		cErro := "Inconsistência na gravação do registro contendo a chave: " + CRLF
		cErro += "tpInsc: " + (aApuracao[SINTETICO])->CTPINSC + CRLF
		cErro += "nrInsc: " + (aApuracao[SINTETICO])->CNRINSC + CRLF

		If !lVldProc
			For nErro := 1 to Len(aProcErro)
				cErro	+= '----------------------------------------------' + CRLF
				cErro	+= "Existe o seguinte impedimento: " + CRLF
				cErro	+= "Processo número " + Alltrim(aProcErro[nErro][2]) + " não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."  + CRLF				
			Next nErro	
		EndIf
		cErro  	+= "Detalhes do Erro: " + CRLF + CRLF //"Detalhes do Erro: "
		cErro 	+= TafRetEMsg(oModel)		
		Aadd(aErro, {"R-2060", "ERRO", cErro})
		lRollBack := .F.
	EndIf

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()


@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function GravaId(aMovs, cIdApur)

	Local nX As numeric

	Default aMovs 	:= {}
	Default cIdApur	:= ''

	For nX := 1 to Len(aMovs)
		TafEndGRV( aMovs[nX][3], aMovs[nX][3]+"_PROCID", cIdApur, aMovs[nX][2], "R2060"  )
	Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopArray()
Popula as estrutas das 3 temporary tables utilisadas na apuração 

@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static function PopArray(aCampCabc,aCmpAtiv,aCmpCmpt,aCampProc,aCampAjst,cPeriodo)

	//T082 - CPRB - LEGADO C5M - ESPELHO V0S
	aCampCabc := {	{'CHAVE'	,'C', 21 				,0} ,;	//CPERIODO+CTPINSC+CNRINSC
					{'CPERIODO'	,'C', 06 				,0} ,;
					{'CTPINSC'	,'C', 01 				,0} ,;	//CTPINSC
					{'CNRINSC'	,'C', 14 				,0} ,;	//CNRINSC
					{'VLRECBTT'	,'N', 14 				,2} ,;	//vlrRecBrutaTotal
					{'VLCPAPUT'	,'N', 14 				,2} ,;	//vlrCPApurTotal
					{'VLCSUSPT'	,'N', 14 				,2} ,;	//vlrCPRBSuspTotal
					{'ID'		,'C', 06				,0} ,; 	//ID				
					{'FILIAL'	,'C',_nTmC1GFl			,0}	,;  //FILIAL
					{'PROCID'	,'C', 06     			,0}	}	//PROCID

	aCmpAtiv  := {	{'CHAVE'	,'C', 21 				,0}	,; 	//CPERIODO+CTPINSC+CNRINSC
					{'CPERIODO'	,'C', 06 				,0}	,;
					{'CTPINSC'	,'C', 01 				,0}	,; 	//CTPINSC
					{'CNRINSC'	,'C', 14 				,0}	,; 	//CNRINSC
					{'IDATIV'	,'C', _nTmAtiv			,0}	,;	//IdAtiv
					{'CODATIV'	,'C', 08 				,0}	,;	//CodAtiv
					{'CDSATIV'	,'C', 220 				,0}	,;	//DscAtiv
					{'ALQATIV'	,'N', 08 				,4}	,;	//AliqCodAtiv					
					{'C5MVATIV'	,'N', 14 				,2}	,;	//vlrRecBrutaAtiv
					{'C5MVEXC'	,'N', 14 				,2}	,; 	//vlrExcRecBruta
					{'T9TVEXC'	,'N', 14 				,2}	,; 	//vlrExcRecBruta
					{'T9TVAJU'	,'N', 14 				,2}	,; 	//vlrAdicRecBruta					
					{'VBCCPRB'	,'N', 14 				,2}	,; 	//vlrBcCPRB (vlrRecBrutaAtiv + vlrAdicRecBruta ) - vlrExcRecBruta 
					{'VLRCPRBAP','N', 14 				,2}	,; 	//
					{'ID'		,'C', 06				,0} ,; 	//ID				
					{'FILIAL'	,'C',_nTmC1GFl			,0}	,;	//FILIAL
				 	{'RECNO'	,'N', 10 				,0} }	//RECNO

    //T082AA - COMPLEMENTO - LEGADO C5N - ESPELHO V0T 
	aCmpCmpt := {	{'CHAVE'	,'C', (21 + _nTmAtiv)	,0}	,; //Period(6) + tpInsc(1) + nrInsc(14) + IdAtiv(10)
					{'C5NID'	,'C', 06 				,0}	,;
					{'IDATIV'	,'C', _nTmAtiv			,0}	,;
					{'DETVAL'	,'N', 14 				,2}	}
    
    //T082AB - PROCESSO - LEGADO C5O - ESPELHO V0V  
	aCampProc := {	{'CHAVE'	,'C', (21 + _nTmAtiv)	,0}	,;	//Period(6) + tpInsc(1) + nrInsc(14) + IdAtiv(10)
					{'IDATIV'	,'C', _nTmAtiv 			,0}	,;	//IdAtiv
					{'C1GTPPROC','C', 01 				,0}	,; 	//TPPROCRETPRINC OU TPPROCRETADIC
					{'C1GNUMPRO','C', _nTmC1GPro		,0} ,;	//NRPROCRETPRINC OU NRPROCRETADIC
					{'IDSUSP'	,'C', _nTmIdSus			,0}	,; 	//ID+VERSAO+CODSUSP
					{'CODSUS'	,'C', 14 				,0}	,; 	//CODSUSPPRINC OU CODSUSPADIC
					{'NUMPRO'	,'C', 06 				,2}	,; 	//NRPROCRETPRINC OU NRPROCRETADIC
					{'VALSUS'	,'N', 14 				,2}	,; 	//VALORPRINC OU VALORADIC
					{'C1GID'	,'C', 06 				,0}	,;
					{'C1GVERSAO','C', 14 				,0}	,;
					{'C1GFILIAL','C', _nTmC1GFl			,0}}

    //T082AC - AJUSTE - LEGADO T9T - ESPELHO VOU				
	aCampAjst := {	{'CHAVE'	,'C', (21 + _nTmAtiv)	,0}	,;
					{'IDATIV'	,'C', _nTmAtiv 			,0}	,;
					{'DTAJUS'	,'C', 06 				,0}	,;
					{'CTPAJST'	,'C', 01 				,0}	,;	//TIPO AJUST
					{'CCODAJST'	,'C', 02 				,0}	,; 	//COD AJUST
					{'VLRAJST'	,'N', 14 				,2}	,;
					{'DSCAJST'	,'C', 20 				,0}	}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Seta o indice das temporary table

@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static function PopIdxObj(oTTCabc,oTTAtiv,oTTProc,oTTAjst,oTTCmpt,cPeriodo)
	
	//T082 - CPRB - LEGADO C5M - ESPELHO V0S
	oTTCabc:AddIndex("1",{"CHAVE"})
	oTTCabc:AddIndex("2",{"CPERIODO","CTPINSC","CNRINSC"})
	oTTCabc:AddIndex("3",{"PROCID","CPERIODO","CTPINSC","CNRINSC"})

	oTTAtiv:AddIndex("1",{"CHAVE"})
	oTTAtiv:AddIndex("2",{"CPERIODO","CTPINSC","CNRINSC","IDATIV"})
	
	//T082AA - COMPLEMENTO - LEGADO C5N - ESPELHO V0T
	oTTCmpt:AddIndex("1",{"CHAVE"})
	oTTCmpt:AddIndex("2",{"CHAVE","C5NID"})

	//T082AB - PROCESSO - LEGADO C5O - ESPELHO V0V  		
	oTTProc:AddIndex("1",{"CHAVE"})
	oTTProc:AddIndex("2",{"CHAVE","C1GTPPROC","C1GNUMPRO","CODSUS"})

	//T082AC - AJUSTE - LEGADO T9T - ESPELHO VOU
	oTTAjst:AddIndex("1",{"CHAVE"})
	oTTAjst:AddIndex("2",{"CHAVE","DTAJUS","CTPAJST","CCODAJST"})

	oTTCabc:Create()
	oTTAtiv:Create()
	oTTCmpt:Create()
	oTTProc:Create()
	oTTAjst:Create()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function ExcluiReg(cIdApReinf, cReg, aErro)

	Local cErro		As Character	
	Local cTpInsc	As Character
	Local cNrInsc	As Character
	Local lExcluiu	As Logical 
	Local oModel 	As Object
	
	cErro 		:= "" 
	cTpInsc 	:= ""
	cNrInsc 	:= ""
	lExcluiu 	:= .F.

	oModel 	:= FWLoadModel("TAFA499")
	cNrInsc	:= V0S->V0S_NRINSC
	cTpInsc	:= V0S->V0S_TPINSC

	oModel:SetOperation(5)
	oModel:Activate()
	
	If FwFormCommit(oModel)
	    lExcluiu := .T.
	Else
		cErro	:= STR0006 + CRLF //"Inconsistência na gravação do registro contendo a chave: "

		cErro 	+= "tpInsc: " + cTpInsc + CRLF
		cErro 	+= "nrInsc: " + cNrInsc + CRLF

		//cErro  	+= STR0006 + CRLF
		cErro 	+= TafRetEMsg(oModel)
		Aadd(aErro, {"R-2060", "ERRO", cErro})
		lExcluiu := .F.
	EndIf

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author Denis Souza
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function TamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric

	Default cLayout := ''

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F"
			++aTam[3]
		endif
	Next nlA

Return aTam

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFilId()

Retorna a query necessária para conseguir os recnos dos campos de acordo com
o tipo e o numero de inscrição

@author Matheus Prada
@since	20/01/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function RetFilId(cNrInsc)

	Local cQry 	   as character
	Local cAlQry   as character
	Local aRECNOS  as array
	Local oPrepV48 as Object
	Local aBind    as Array
	Local nI       as Numeric
	Local aBranch  as Array
	Local lTmpFil  as Logical

	Default cNrInsc  := ""

	oPrepV48 := nil
	aBind    := {}
	nI       := 0
	aRECNOS	 := {}
	aBranch  := {}
	lTmpFil  := .F.

	if "TMPFIL" $ _cFiliais //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
		lTmpFil := .T. //nao manipula o _cFiliais
	else //_cFiliais ja tratado no cache do QURY2060
		aBranch := Separa(StrTran(_cFiliais,"'",""),",")
	endif

	cQry := "SELECT V48.V48_FILIAL FILIAL, V48.R_E_C_N_O_ RECNO "
	cQry += "FROM " + RetSqlName( "V48" ) + " V48 "
	cQry += "INNER JOIN " + RetSqlName( "T9C" ) + " T9C ON "
	if _cCompT9C == "CCC" .Or. (_cCompT9C == "EEC" .And. aInfEUF[1]+aInfEUF[2] == 0)
	 	cQry += " T9C.T9C_FILIAL = ? "
		aadd(aBind,_cFilT9C)
	else
		cQry += FwJoinFilial("T9C","V48")
	endif
	cQry += " AND T9C.T9C_ID = V48.V48_IDCNO "

	cQry += "AND T9C.T9C_NRINSC = ? "
	aadd(aBind,cNrInsc)

	cQry += "AND T9C.D_E_L_E_T_ = ? "
	aadd(aBind,space(1))

	cQry += "WHERE "
	if lTmpFil //Para clientes com mais de 50 filiais, cFiliais armazena um select de temporaria, nao se trata de um filtro para BIND, ex conteudo variavel: (SELECT TMPFIL FROM ##TMPSC00_52 )
		cQry += "V48.V48_FILIAL IN " + _cFiliais
	else //faz bind com aBranch
		cQry += "V48.V48_FILIAL IN (?) "
		aadd(aBind, aBranch)
	endif
	cQry += " AND V48.D_E_L_E_T_ = ? "
	aadd(aBind,space(1))

	If !Md5(cQry) == _cQry3MD5
		cQry := ChangeQuery(cQry)
		_cQry3MD5 := Md5(cQry)
	endif

	if _TafBindQry
		TafBindQry(cQry,@oPrepV48,@aBind,@cAlQry)
		While (cAlQry)->(!EOF())
			If aScan(_aFils, {|x| AllTrim(x[3]) == Alltrim((cAlQry)->FILIAL) }) > 0
				AADD(aRECNOS, (cAlQry)->RECNO)
			EndIf			
			(cAlQry)->(DbSkip())
		EndDo
		If oPrepV48 != Nil
			oPrepV48:Destroy()
			freeObj(oPrepV48)
			oPrepV48 := Nil
		EndIf
		(cAlQry)->(DbCloseArea())
	endif
	aSize(aBranch,0)
	aBranch := {}
Return aRECNOS
