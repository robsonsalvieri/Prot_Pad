#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPRCP.CH"

#DEFINE MB_ICONHAND 16
#DEFINE SINTETICO 1,1
#DEFINE ANALITICO 2,1
#DEFINE PROCESSOS 3,1
#DEFINE DELETSINT 1,2
#DEFINE DELETANAL 2,2
#DEFINE DELETPROC 3,2
#DEFINE EMPRESA 1
#DEFINE UNIDADE 2
#DEFINE FILIAL  3

static oModel478 as Object
static oModel486 as Object

static __TmSerPfx := 0 as Numeric

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPRCP
Rotinas de apuração da Contribuição Previdenciária serviços tomados e prestados 
Registros R-2010 e R-2020 da Reinf

@author Henrique Pereira; Anieli Rodrigues; Denis Naves
@since 14/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFAPRCP(cReg ,cPerApu,dtIni ,dtFin , cIdApReinf, aFil, oProcess, lValid, lSucesso, cCNPJC1H)

	Local lProc As logical
	Default lValid := .F.
	Default lSucesso	:=	.t.

	lProc := oProcess <> nil

	oModel478 := FWLoadModel("TAFA478")
	oModel486 := FWLoadModel("TAFA486")

	If lProc
		oProcess:IncRegua2(STR0008 + cReg ) //"Processando apuração "
	EndIf
	TAFR20XX( cReg, cPerApu, dtIni, dtFin, @cIdApReinf, aFil, oProcess, lValid, @lSucesso, cCNPJC1H )

	oModel478:Destroy()
	oModel478 := Nil

	oModel486:Destroy()
	oModel486 := Nil

Return Nil

Static Function TAFR20XX( cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, lSucesso, cCNPJC1H)

	Local aLog 		As Array
	Local aApurac	As Array
	Local aAreaSM0 	As Array
	Local aInfoC1E	As Array
	Local aInfoEUF	As Array
	Local cIDFil	As Character
	Local cStatReg 	As Character
	Local cNrInsc	As Character
	Local lExecApr	As Logical
	Local lProc		As Logical
	Local lErroCon  as logical
	Local nContApur	As Numeric
	Local nMatriz 	As Numeric
	Local nTotReg	As Numeric
	Local nContLog	As Numeric
	LocaL nTNrInsc	As Numeric
	Local nC1EArray	As Numeric
	Local nX		As Numeric
	Local nY		As Numeric
	Local nTamFil   As Numeric
	Local nContReg  as Numeric

	Default lValid := .F.

	aAreaSM0	:= {}
	aLog  		:= {}
	aApurac		:= {}
	aInfoC1E	:= {}
	aInfoEUF	:= {}
	cIDFil		:= ""
	cStatReg 	:= "Z"
	cNrInsc		:= ""
	lExecApr	:= .F.
	lOk			:= .t.
	lErroCon    := .f.
	lProc 		:= oProcess <> nil
	nContApur	:= 1
	nContLog	:= 0
	nMatriz		:= 0
	nX			:= 0
	nY			:= 0
	nTamFil		:= 0
	nTNrInsc	:= TamSX3( "CMN_NRINSC" )[1]
	nTotReg		:= 0
	nC1EArray	:= ASCAN(aFil,{|x|x[7]})

	cPerApuGrv 	:= cPerApu
	cPerApu 	:= SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)
	aAreaSM0 	:= SM0->(GetArea())

	nMatriz := aScan(aFil,{|x| x[07]})
	nTamFil := len( aFil )
	nContReg:= 1

	//CIE MATRIZ
	If nC1EArray > 0
		AADD(aInfoC1E,aFil[nC1EArray][1])
		AADD(aInfoC1E,aFil[nC1EArray][4])
	elseif nTamFil > 0
		AADD(aInfoC1E,aFil[nTamFil][1])
		AADD(aInfoC1E,aFil[nTamFil][4])
	EndIf

	If cReg == 'R-2020'
		DbselectArea("CMN")
		CMN->(DbSetOrder(7))
	Else
		DbselectArea("T95")
		T95->(DbSetOrder(7)) //T95_FILIAL, T95_PERAPU, T95_TPINSC, T95_NRINSC, T95_CNPJPR, T95_ATIVO
	EndIf

	If !Empty(cPerApu)
		If lProc
			oProcess:IncRegua2(STR0009) // "Selecionando dados a serem apurados"
		EndIf

		if nMatriz > 0
			cIDFil := aFil[nMatriz][01]
		elseif nTamFil > 0
			cIDFil := aFil[nTamFil][01]
		endif

		aDadosUtil := {}
		AAdd(aDadosUtil, {cIDFil, cPerApuGrv})

		If FindFunction("ReinfRules")
			cErro := ReinfRules("T9U", "REGRA_EXISTE_INFO_CONTRIBUINTE", , aDadosUtil)
		EndIf

		If !Empty(cErro)
			lErroCon := .t.
			cErro    := "REGRA_EXISTE_INFO_CONTRIBUINTE: " + CRLF + CRLF + cErro
			TafXLog(cIdApReinf, cReg, Iif(lValid, "ERRO", "ALERTA"), cErro ,cPerApuGrv )

			If lValid
				lExecApr := .F.
			Else
				lExecApr := .T.
			EndIf

		Else
			lExecApr := .T.
		EndIf

		If lExecApr
			aInfoEUF 	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
			aApurac		:= Apur1020(cPerApu, cReg, aFil, aInfoEUF,,cCNPJC1H)
			lExecApr 	:= aApurac[4]
		EndIf
	EndIf
	RestArea(aAreaSM0)
	//--------------------------------------------
	// alimento a lSucesso para retorno a API
	//--------------------------------------------
	lSucesso	:=	lExecApr
	If lExecApr
		If !(aApurac[SINTETICO])->(Eof())

			(aApurac[SINTETICO])->(DbSetOrder(1))
			(aApurac[SINTETICO])->(DbEval({|| ++nTotReg }))
			(aApurac[SINTETICO])->(DbGoTop())

			If lProc
				oProcess:IncRegua2(STR0010) //"Gravando registros"
				oProcess:SetRegua2(nTotReg)
			EndIf

			While !(aApurac[SINTETICO])->(Eof())

				Begin Transaction

					//Controla numeração do _PROCID
					if nContReg > 1
						cIdApReinf := TafXLogIni( , cReg )
						if lErroCon
							cErro := "REGRA_EXISTE_INFO_CONTRIBUINTE: " + CRLF + CRLF + cErro
							TafXLog(cIdApReinf, cReg, Iif(lValid, "ERRO", "ALERTA"), cErro ,cPerApuGrv )
						endif
					endif

					If cReg == 'R-2020'
						cNrInsc := (aApurac[SINTETICO])->CNRINDC
						cStatus := StatsReg(cReg, cPerApuGrv, "1", cNrInsc, (aApurac[SINTETICO])->CTPINSCTOM, (aApurac[SINTETICO])->CCNPJTMPR, (aApurac[SINTETICO])->CNPJ)
					Else
						cNrInsc := (aApurac[SINTETICO])->CNRINDC
						cStatus := 	StatsReg(cReg, cPerApuGrv, (aApurac[SINTETICO])->CTPINSC, cNrInsc, ""/*cTpInsT*/, ""/*cNrInst*/, (aApurac[SINTETICO])->CNPJ)
					EndIf

					If lProc
						oProcess:IncRegua2(STR0011 + cValTochar(nContApur++) + "/" + cValTochar(nTotReg)) //Gravando
					EndIf

					Do Case
						//Alteração direta na base, e retono do CMN_STATUS / T95_STATUS para branco
					Case cStatus $ ' |0|1|3|7'

						If ExcluiReg(cIdApReinf, cReg, @aLog)
							If cReg == 'R-2020'
								lOk := Grava2020(MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, CMN->CMN_VERANT, CMN->CMN_PROTPN, cIdApReinf, @aLog, CMN->CMN_ID, lValid, cStatus )
							Else
								lOk := Grava2010( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, T95->T95_VERANT, T95->T95_PROTPN, cIdApReinf, @aLog, T95->T95_ID, lValid, cStatus )
							EndIf
						Else
							lOk := .f.
						EndIf

						//Registro transmitido ao governão e sem retorno, não deve ser alaterado
					Case cStatus $ '2|6'
						cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "

						If cReg == "R-2010"
							cErro 	+= "tpInscEstab: " + (aApurac[SINTETICO])->CTPINSC + CRLF
							cErro 	+= "nrInscEstab: " + cNrInsc + CRLF
							cErro  	+= "cnpjPrestador: " + (aApurac[SINTETICO])->CNPJ + CRLF
						Else
							cErro 	+= "tpInscEstab: " + "1"
							cErro 	+= "nrInscEstab: " + cNrInsc + CRLF
							cErro  	+= "tpInscTomador: " +  (aApurac[SINTETICO])->CTPINSC + CRLF
							cErro  	+= "nrInscTomador: " +	(aApurac[SINTETICO])->CNPJ + CRLF
						EndIf

						cErro 	+= STR0007 + CRLF //"A apuração foi cancelada pois este registro já foi transmitido e está aguardando retorno do RET, portanto não pode ser modificado."
						Aadd(aLog, {cReg, "ERRO", cErro})
						lOk := .f.

					Case cStatus == '4'
						If cReg == 'R-2020'
							cVerAnt := CMN->CMN_VERSAO
							cProTpn := CMN->CMN_PROTUL
							FAltRegAnt( 'CMN', '2', .F. )
							lOk := Grava2020( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, @aLog, CMN->CMN_ID, lValid, cStatus )
						Else
							cVerAnt := T95->T95_VERSAO
							cProTpn := T95->T95_PROTUL
							FAltRegAnt( 'T95', '2', .F. )
							lOk := Grava2010( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, @aLog, T95->T95_ID, lValid, cStatus )
						EndIf

					Case cStatus == "Z" // Commit do modelo em modo de inclusão
						if Upper(cReg) == "R-2020"
							lOk := Grava2020( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, , , cIdApReinf, @aLog, , lValid, cStatus )
						else
							lOk := Grava2010( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, , , cIdApReinf, @aLog, , lValid, cStatus )
						EndIf

					EndCase

					if lOk
						TafXLog(cIdApReinf, cReg, "MSG", "Processamento realizado com sucesso" ,cPerApuGrv )
					else
						for nContLog := 1 to Len (aLog)
							TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3],cPerApuGrv )
						next
						lSucesso := .f.
						aLog := {}
						lOk  := .t.
					endif

					(aApurac[SINTETICO])->(DbSkip())
					if (aApurac[SINTETICO])->(!eof()); TafXLogFim( cIdApReinf, cReg ); endif

					End Transaction

					nContReg++

				EndDo

			EndIf
			//Destruo as tabelas temporárias
			aApurac[DELETSINT]:Delete()
			aApurac[DELETANAL]:Delete()
			aApurac[DELETPROC]:Delete()
		EndIf

		Return(aLog)

//-------------------------------------------------------------------
/*/{Protheus.doc} 2020Stat
Verifica a existência ou não do registro que será apurado

@author Henrique Pereira
@since 14/02/2018
@version 1.0
@return Retorna o status do registro encontrado, caso contrário retorna status "Z", indicando que ainda não existe o registro no cadastro espelho

/*/ 
//-------------------------------------------------------------------

Static Function StatsReg(cReg, cPerApu, cTpInsc, cNrInsc, cTpInsT, cNrInst, cCNPJPr)

	Local cRetStat as Character //retorno do status do registro
	cRetStat := "Z"
	Default cPerApu := ""

	If cReg == 'R-2020'
		If CMN->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + cTpInsT + cNrInst + '1'))
			cRetStat := CMN->CMN_STATUS
		Else
			cRetStat := "Z"
		EndIf

	ElseIf cReg == 'R-2010'
		If T95->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + cCNPJPr + '1'))
			cRetStat := T95->T95_STATUS
		Else
			cRetStat := "Z"
		EndIf
	EndIf

Return cRetStat

//-------------------------------------------------------------------
/*/{Protheus.doc} 2020Stat
Executa a apuração

@author Henrique Pereira
@since 14/02/2018
@version 1.0
@return Retorna o alias da consulta com a apuração.

/*/ 
//-------------------------------------------------------------------

Function Apur1020(cPerApu, cReg, aFil, aInfEUF, lApiTHF, cCNPJC1H, nLevel, cFilDoc)

	Local cAliasApr as	Character
	Local cSelect	as	Character
	Local cSelect2  as	Character
	Local cWhere	as	Character
	Local cWhere2	as	Character
	Local cCmpQry	as 	Character
	Local cFiliais	as  Character
	Local cCompC1H  as  Character
	Local cDataIni  as  Character
	Local cDataFim  as  Character
	//-----NF
	Local cFromC20	as	Character
	Local cIJoinC30	as Character
	Local cIJoinC35	as Character
	Local cLJoinC1L	as Character
	Local cLJoinT9Q	as Character
	Local cIJoinC1H	as Character
	Local cIJoinC8C	as Character
	//-----FATURA
	Local cFromLEM	as Character
	Local cJoinT5M	as Character
	Local cJoinT9E	as Character
	Local cJoinT9C	as Character
	Local cJoinC1H	as Character
	Local cJoinC8C	as Character
	Local cBd		as Character

	Local aRegApur	as Array

	Default cPerApu  := ""
	Default cReg 	 := ""
	Default lApiTHF  := .f.
	Default cCNPJC1H := ''
	Default nLevel   := 0 
	Default cFilDoc  := cFilAnt

	cDataIni := cPerApu + "01" //ex: 20220201
	cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

	aRegApur			:= {}

	cAliasApr			:=	GetNextAlias()
	cSelect				:=	""
	cSelect2			:=	""
	cWhere				:=	""
	cWhere2				:=	""
	cCmpQry				:=	""
	cCompC1H			:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	//-----NF
	cFromC20			:=	""
	cIJoinC30			:=	""
	cIJoinC35			:=	""
	cLJoinC1L			:= 	""
	cLJoinT9Q			:=	""
	cIJoinC1H			:=  ""
	cIJoinC8C			:=  ""
	cBd					:= TcGetDb()
	//-----FATURA
	cFromLEM			:= ""
	cJoinT5M			:= ""
	cJoinT9E			:= ""
	cJoinT9C			:= ""
	cJoinC1H			:= ""
	cJoinC8C			:= ""
	cFiliais			:= TafRetFilC("C20", aFil) 

	//-----NF
	cSelect	:= " 'NFS' AS ROTINA, '0' AS ID, C20.C20_FILIAL AS FIL, C20.C20_NUMDOC AS NUMDOCTO, C20.C20_SERIE AS SERIE, C20.C20_DTDOC AS DTEMISSAONF, "
	cSelect	+= " C20.C20_VLDOC AS VLRBRUTO, 'OBSERVACAO' AS OBS, C20.R_E_C_N_O_ AS RECNO, T9C.T9C_TPINSC AS TPINSC, T9C.T9C_NRINSC AS NRINSC, T9C.T9C_ID AS IDOBRA, T9C.T9C_DSCOBR AS DSCOBRA, "
	cSelect	+= " T9C.T9C_INDOBR AS INDOBRA,	C1H.C1H_CNPJ AS CNPJ, C20.C20_CODPAR AS CODPAR,	C20.C20_IDOBR AS CODOBR, C30.C30_IDTSER AS CODSER, "
	cSelect	+= " C35.C35_BASE AS VLRBASERET, C35.C35_VALOR AS VLRRETENCAO, C35.C35_VLSCON AS VLRRETSUB, C35.C35_VLRNPG AS VLRNRETPRINC, "
	cSelect	+= " C35.C35_VLCE15 AS VLR15SERVICOS, C35.C35_VLCE20 AS VLR20SERVICOS, C35.C35_VLCE25 AS VLR25SERVICOS, C35.C35_VLRADI AS VLRADICIONAL, "
	cSelect	+= " C35.C35_VLRANP AS VLRNRETADIC, C20.C20_CHVNF AS CHVNF, C35.C35_ALIQ AS ALIQ, "

	If TAFColumnPos( "T9C_CPRB" )
		cSelect	+= " CASE WHEN C20.C20_IDOBR = '' OR T9C.T9C_CPRB IS NULL OR T9C.T9C_CPRB = '' THEN C1H.C1H_CPRB ELSE T9C.T9C_CPRB END AS CPRB,"
	Else
		cSelect	+= " C1H.C1H_CPRB AS CPRB,"
	EndIf
	cSelect	+= " C1H.C1H_ID AS IDPART, C1H.C1H_CODPAR AS C1HCODPAR, C1H.C1H_NOME AS C1HNOME, C8C.C8C_CREINF AS CODSERVIC, C8C.C8C_DESCRI AS C8CDESCRI, C20.C20_PROCID AS PROCID "

	cFromC20  += RetSqlName("C20") + " C20"
	cIJoinC30 := RetSqlName("C30") + " C30 ON C20.C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ = ' ' AND C20.C20_CHVNF = C30.C30_CHVNF AND C30.C30_IDTSER <> ' ' AND C30.C30_TPREPA = ' ' "
	cIJoinC35 := RetSqlName("C35") + " C35 ON C30.C30_FILIAL = C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND C30.C30_NUMITE = C35.C35_NUMITE AND "
	cIJoinC35 += " C30.C30_CODITE = C35.C35_CODITE AND C35.C35_CODTRI = '000013' AND C35.D_E_L_E_T_ = ' ' "

	cIJoinC8C := RetSqlName("C8C") + " C8C ON C8C.C8C_ID = C30.C30_IDTSER AND C8C.D_E_L_E_T_ = ' ' "

	cLJoinT9C := RetSqlName("T9C") + " T9C ON T9C.T9C_ID = C20.C20_IDOBR AND T9C.D_E_L_E_T_ = ' ' "
	cIJoinC1H := RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

	If cCompC1H == "EEE"
		cIJoinC1H += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cIJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cIJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfEUF[1]) + ") "
		EndIf
	EndIf
    
	If nLevel == 2
		cWhere := " C20.C20_FILIAL = '" + cFilDoc + "' AND " 
	Else
		cWhere := " C20.C20_FILIAL IN " + cFiliais + " AND "
	EndIf

	cWhere += " C20.D_E_L_E_T_ = ' ' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND "
	
	If cReg == "R-2010"
		cWhere += " C20.C20_INDOPE = '0' AND "
	ElseIf cReg == "R-2020"
		cWhere += " C20.C20_INDOPE = '1' AND "
	EndIf

	cWhere += " C20.C20_DTDOC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
	
	if !empty(cCNPJC1H)
		cWhere += PrepWhere(cCNPJC1H)
	endif

	//-----FATURA
	cSelect2 := " 'FAT' AS ROTINA, LEM.LEM_ID AS ID, LEM.LEM_FILIAL AS FIL, LEM.LEM_NUMERO AS NUMDOCTO, LEM.LEM_PREFIX AS SERIE, "
	cSelect2 += " LEM.LEM_DTEMIS AS DTEMISSAONF, LEM.LEM_VLBRUT AS VLRBRUTO, LEM.LEM_OBSERV AS OBS, LEM.R_E_C_N_O_ AS RECNO, T9C.T9C_TPINSC AS TPINSC, T9C.T9C_NRINSC AS NRINSC, "
	cSelect2 += " T9C.T9C_ID AS IDOBRA, T9C.T9C_DSCOBR AS DSCOBRA, T9C.T9C_INDOBR AS INDOBRA, C1H.C1H_CNPJ AS CNPJ, LEM_IDPART AS CODPAR, "
	cSelect2 += " '0' AS CODOBR, T5M.T5M_IDTSER AS CODSER, T5M.T5M_BSINSS AS VLRBASERET, T5M.T5M_VLINSS AS VLRRETENCAO, T5M.T5M_VLRETS AS VLRRETSUB, "
	cSelect2 += " T5M.T5M_VLRETP AS VLRNRETPRINC, T5M.T5M_VLSV15 AS VLR15SERVICOS, T5M.T5M_VLSV20 AS VLR20SERVICOS, T5M.T5M_VLSV25 AS VLR25SERVICOS, "
	cSelect2 += " T5M.T5M_VLADIC AS VLRADICIONAL, T5M.T5M_VLADNE AS VLRNRETADIC, '0' AS CHVNF, 0 AS ALIQ, "

	If TAFColumnPos( "T9C_CPRB" )
		cSelect2 += " CASE WHEN T9C.T9C_INDOBR = '' OR T9C.T9C_CPRB IS NULL OR T9C.T9C_CPRB = '' THEN C1H.C1H_CPRB ELSE T9C.T9C_CPRB END AS CPRB,"
	Else
		cSelect2 += " C1H.C1H_CPRB AS CPRB,"
	EndIf
	cSelect2 += " C1H.C1H_ID AS IDPART, C1H.C1H_CODPAR AS C1HCODPAR, C1H.C1H_NOME AS C1HNOME, C8C.C8C_CREINF AS CODSERVIC, C8C.C8C_DESCRI AS C8CDESCRI, LEM.LEM_PROCID AS PROCID "

	cFromLEM += RetSqlName("LEM") + " LEM"
	cJoinT5M := RetSqlName("T5M") + " T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID = LEM.LEM_ID AND T5M.T5M_IDPART = LEM.LEM_IDPART AND T5M.T5M_IDTSER <> ' ' AND T5M.T5M_TPREPA = ' ' AND "
	cJoinT5M += " T5M.T5M_NUMFAT = LEM.LEM_NUMERO AND T5M.T5M_BSINSS > 0 AND T5M.D_E_L_E_T_ = ' ' "

	cJoinC8C := RetSqlName("C8C") + " C8C ON C8C.C8C_ID = T5M.T5M_IDTSER AND C8C.D_E_L_E_T_ = ' ' "

	cJoinT9C := RetSqlName("T9C") + " T9C ON T9C.T9C_FILIAL = LEM.LEM_FILIAL AND T9C.T9C_ID = LEM.LEM_IDOBRA AND T9C.D_E_L_E_T_ = ' ' "
	cJoinC1H := RetSqlName("C1H") + " C1H ON C1H.C1H_ID = LEM.LEM_IDPART AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

	If cCompC1H == "EEE"
		cJoinC1H += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cJoinC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		EndIf
	EndIf

	If nLevel == 2
		cWhere2 := " LEM.LEM_FILIAL = '" + cFilDoc + "' AND " 
	Else
		cWhere2 := " LEM.LEM_FILIAL IN " + cFiliais + " AND "
	EndIf

	cWhere2	+= " LEM.LEM_DOCORI = ' ' AND LEM.D_E_L_E_T_ = ' ' AND "

	If cReg == "R-2010"
		cWhere2 += " LEM.LEM_NATTIT = '0' AND "
	ElseIf cReg == "R-2020"
		cWhere2 += " LEM.LEM_NATTIT = '1' AND "
	EndIf

	cWhere2 += " LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "

	if !empty(cCNPJC1H)
		cWhere2 += PrepWhere(cCNPJC1H)
	endif

	//----NF
	cSelect		:= "%" + cSelect 	+ 	"%"
	cFromC20	:= "%" + cFromC20	+ 	"%"
	cIJoinC30	:= "%" + cIJoinC30	+	"%"
	cIJoinC35	:= "%" + cIJoinC35	+	"%"
	cIJoinC8C	:= "%" + cIJoinC8C	+	"%"
	cLJoinT9C	:= "%" + cLJoinT9C	+	"%"
	cIJoinC1H	:= "%" + cIJoinC1H	+	"%"
	cWhere		:= "%" + cWhere		+	"%"

	//-----FATURA
	cSelect2	:= "%" + cSelect2	+ 	"%"
	cFromLEM	:= "%" + cFromLEM	+	"%"
	cJoinT5M	:= "%" + cJoinT5M	+	"%"
	cJoinC8C	:= "%" + cJoinC8C	+	"%"
	cJoinT9C	:= "%" + cJoinT9C	+	"%"
	cJoinC1H	:= "%" + cJoinC1H	+	"%"
	cWhere2		:= "%" + cWhere2	+	"%"

	BeginSql Alias cAliasApr

		COLUMN DTEMISSAONF AS DATE

		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFromC20%
		INNER JOIN
		%Exp:cIJoinC30%
		INNER JOIN
		%Exp:cIJoinC35%
		INNER JOIN
		%Exp:cIJoinC8C%		
		LEFT JOIN
		%Exp:cLJoinT9C%
		INNER JOIN
		%Exp:cIJoinC1H%
		WHERE
		%Exp:cWhere%

		UNION ALL

		SELECT
		%Exp:cSelect2%
		FROM
		%Exp:cFromLEM%
		INNER JOIN
		%Exp:cJoinT5M%
		INNER JOIN
		%Exp:cJoinC8C%
		LEFT JOIN
		%Exp:cJoinT9C%
		INNER JOIN
		%Exp:cJoinC1H%
		WHERE
		%Exp:cWhere2%
		ORDER BY 1,3,4,5,6
	EndSql

	aRegApur := RegPrinc( cAliasApr, cPerApu, cCmpQry, cReg, aInfEUF, lApiTHF)

Return aRegApur

//-------------------------------------------------------------------
/*/{Protheus.doc} RegPrinc
Monta a Tabela Temporária Com As Dimensoes PreEstabelecidas

@author Denis Naves
@since 19/02/2018
@version 1.0
@return Retorna os alias das TTs

/*/ 
//-------------------------------------------------------------------

Static Function RegPrinc( cAlias , cPeriod, cCmpQry, cReg, aQtdEUF, lApiTHF)

	Local aAnalitic		as Array	
	Local aProcesso		as Array
	Local aCampNfs		as Array
	Local aCampCabc		as Array
	Local aCampProc		as Array
	Local cCNPJTmPr		as Character
	Local cChvReg		as Character
	Local cTpInsc		as Character
	Local cTpInscTom	as Character
	Local cNrIndc		as Character
	Local cIndObra		as Character
	Local cIdObra		as Character
	Local cDsObra		as Character
	Local cAlsTTCabc	as Character
	Local cAlsTTNfs		as Character
	Local cAlsTTProc	as Character
	Local cCompart		as Character
	Local cFil			as Character
	Local cId			as Character
	Local cChave		as Character
	Local oTTCabc		as Object
	Local oTTNfs		as Object
	Local oTTProc		as Object
	Local nContLaco		as Numeric
	Local nPos			as Numeric
	Local nVlTlRtPc		as Numeric
	Local lAvanc		as Logical
	Local nNewDoc		as Numeric
	Local cProcID		as Character		
	Local lInvoiCall	as Character
	Local cCnpjPart		as Character
	Local cPfxSer  		as Character
	Local cPartChv      as Character
	Local cFmtPfxSer    as Character

	Default lApiTHF	:=	.f.

	aAnalitic	:= {}	
	aProcesso	:= {}
	aCampNfs	:= {}
	aCampCabc	:= {}
	aCampProc	:= {}
	nContLaco	:= 1
	nPos 		:= 0
	cAlsTTCabc	:= ""
	cAlsTTNfs	:= ""
	cAlsTTProc	:= ""
	cChvReg		:= ""
	cCNPJTmPr	:= ""
	cTpInsc		:= ""
	cTpInscTom	:= " "
	cNrIndc		:= ""
	cIndObra	:= ""
	cIdObra 	:= ""
	cDsObra 	:= ""
	cCompart	:= ""
	cFil		:= ""
	cId			:= ""
	cChave		:= ""
	lAvanc		:= .T.
	oTTCabc		:= Nil
	oTTNfs		:= Nil
	oTTProc		:= Nil
	cProcID		:= ""
	nNewDoc		:= 0
	lInvoiCall  := FwisInCallStack("GET_INVOICEDETAIL") .or. fwisInCallStack("GET_EVENTDETAIL")
	cCnpjPart	:= ''
	cPfxSer  	:= ''
	cPartChv    := ''
	if __TmSerPfx == 0
		__TmSerPfx := GetSx3Cache('LEM_PREFIX','X3_TAMANHO')
	endif
	cFmtPfxSer  := PadR("0",__TmSerPfx)

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())
		cCompart := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3))) // 1=Empresa, 2=Unidade de Negócio e 3=Filial

		cAlsTTCabc	:= getNextAlias()
		cAlsTTNfs	:= getNextAlias()

		if !lApiTHF
			cAlsTTProc	:= getNextAlias()
		endif

		// Cria a estrutura (array) das temporary table
		PopArray(@aCampCabc, @aCampNfs,@aCampProc, cPeriod)

		// Instancia o objeto Temporary Table
		oTTCabc	:= FWTemporaryTable():New(cAlsTTCabc, aCampCabc)
		oTTNfs	:= FWTemporaryTable():New(cAlsTTNfs	, aCampNfs)
		if !lApiTHF
			oTTProc	:= FWTemporaryTable():New(cAlsTTProc, aCampProc)
		endif

		// Seta os devidos indices
		PopIdxObj(@oTTCabc,@oTTNfs,@oTTProc, cPeriod, lApiTHF)

		//cNmTTCabc := oTTCabc:GetRealName()
		//cNmTTProc := oTTProc:GetRealName()
		//cNmTTNfs	:= oTTNfs:GetRealName()

		//INSERTTMP(cNmTTNfs, cCmpQry, aCampNfs )

		DbSelectArea(cAlsTTCabc)
		(cAlsTTCabc)->(DbSetOrder(3)) //"CPERIODO", "CTPINSC", "CNRINDC", "CCNPJTMPR", "CTPINSCTOM"
		
		DbSelectArea(cAlsTTNfs)
		(cAlsTTNfs)->(DbSetOrder(2)) //"CPERIODO", "CTPINSC", "CNRINDC"

		(cAlias)->(DbGoTop())
		While (cAlias)->(!EOF())

			cFil	:=	(cAlias)->FIL //SALVA A FILIAL DO REGISTRO PARA NÃO CLONAR A OBSERVAÇÃO NA FUNÇÃO ObsNtC21()

			If cReg == "R-2010"
				cNrIndc 	:= IIF(lApiTHF,Posicione("SM0", 1, cEmpAnt + (cAlias)->FIL, "M0_CGC"), "")
				If !Empty((cAlias)->NRINSC)	.And. AllTrim(Upper((cAlias)->NRINSC)) <> "SEM CODIGO" .And. (cAlias)->INDOBRA <> '0' //T9C - OBRA
					cTpInsc		:=	(cAlias)->TPINSC
					cNrIndc		:=	 IIF(lApiTHF, cNrIndc, Substr((cAlias)->NRINSC,1,14))
					cIndObra	:= 	(cAlias)->INDOBRA
					cIdObra 	:=	(cAlias)->IDOBRA
					cDsObra 	:=	(cAlias)->DSCOBRA
					cCNPJTmPr	:=   IIF(lApiTHF, Substr((cAlias)->NRINSC,1,14),(cAlias)->CNPJ)
				Else //C1H - PARTICIPANTE
					cTpInsc		:=	'1'
					cNrIndc		:=	Posicione("SM0", 1, cEmpAnt + (cAlias)->FIL, "M0_CGC")
					cIndObra	:=	'0'
					cIdObra 	:=	""
					cDsObra 	:=	""
					cCNPJTmPr	:= (cAlias)->CNPJ
				EndIf
			ElseIf cReg == "R-2020"
				cTpInsc		:= "1"
				cNrIndc 	:= Posicione("SM0", 1, cEmpAnt + (cAlias)->FIL, "M0_CGC")
				If !Empty((cAlias)->NRINSC)	.And. AllTrim(Upper((cAlias)->NRINSC)) <> "SEM CODIGO" //T9C - OBRA
					cTpInscTom	:=	(cAlias)->TPINSC
					cCNPJTmPr	:=	Substr((cAlias)->NRINSC,1,14)
					cIndObra	:= 	(cAlias)->INDOBRA
					cIdObra 	:=	(cAlias)->IDOBRA
					cDsObra 	:=	(cAlias)->DSCOBRA
				Else //C1H - PARTICIPANTE
					cTpInscTom	:= "1"
					cCNPJTmPr	:=	(cAlias)->CNPJ
					cIndObra	:=	'0'
					cIdObra 	:=	""
					cDsObra 	:=	""
				EndIf
			EndIf
			nNewDoc := 0
			If (nContLaco == 1 .Or. cChvReg <> (cAlias)->ROTINA + IIf ((cAlias)->ROTINA == "NFS", (cAlias)->CHVNF, (cAlias)->NUMDOCTO)) 
				cChvReg := (cAlias)->ROTINA + IIf ((cAlias)->ROTINA == "NFS", (cAlias)->CHVNF, (cAlias)->NUMDOCTO)
				nNewDoc := 1
				If !lApiTHF
					RetProc(cAlsTTProc, cAlias, aCampProc, cPeriod + cTpInsc + cNrIndc + cCNPJTmPr + cTpInscTom, cCompart, aQtdEUF)
				EndIf
			EndIf
	
			nVlTlRtPc := ((cAlias)->VLRRETENCAO - (cAlias)->VLRRETSUB)
			cId := cPeriod + cTpInsc + cNrIndc + cCNPJTmPr + cTpInscTom

			If !lApiTHF .or. (lApiTHF .and. lInvoiCall)
				cPfxSer := Substr((cAlias)->SERIE,1,__TmSerPfx)
				if Empty(cPfxSer)
					cPfxSer := cFmtPfxSer
				endif
				cPartChv := (cAlias)->ROTINA
				cPartChv += Substr((cAlias)->NUMDOCTO,1,15)
				cPartChv += cPfxSer
				cPartChv += (cAlias)->CODSER
				cPartChv += (cAlias)->CNPJ

				(cAlsTTNfs)->(DbSetOrder(3)) //ID(36),ROTINA(3),NUMDOCTO(15),SERIE(5),TPSERVICO(6),CNPJ(14)
				If !(cAlsTTNfs)->(DbSeek(cId + cPartChv))
					RecLock(cAlsTTNfs,.T.)
					(cAlsTTNfs)->FIL		:= cFil
					(cAlsTTNfs)->ID			:= cId
					(cAlsTTNfs)->ROTINA		:= (cAlias)->ROTINA
					(cAlsTTNfs)->NUMDOCTO	:= (cAlias)->NUMDOCTO
					(cAlsTTNfs)->SERIE		:= cPfxSer
					(cAlsTTNfs)->TPSERVICO	:= (cAlias)->CODSER
					(cAlsTTNfs)->CNPJ		:= (cAlias)->CNPJ
					(cAlsTTNfs)->DTEMISSNF	:= (cAlias)->DTEMISSAONF
					(cAlsTTNfs)->VLRBRUTO	:= (cAlias)->VLRBRUTO
					(cAlsTTNfs)->OBS		:= (cAlias)->OBS
					(cAlsTTNfs)->C8CDESCRI	:= (cAlias)->C8CDESCRI
					(cAlsTTNfs)->CODSERVIC	:= (cAlias)->CODSERVIC
					(cAlsTTNfs)->VLRBASERET	:= (cAlias)->VLRBASERET
					(cAlsTTNfs)->VLRRETENC	:= (cAlias)->VLRRETENCAO
					(cAlsTTNfs)->VLRRETSUB	:= (cAlias)->VLRRETSUB
					(cAlsTTNfs)->VLRNRETPRI	:= (cAlias)->VLRNRETPRINC
					(cAlsTTNfs)->VLRSERV15	:= (cAlias)->VLR15SERVICOS
					(cAlsTTNfs)->VLRSERV20	:= (cAlias)->VLR20SERVICOS
					(cAlsTTNfs)->VLRSERV25	:= (cAlias)->VLR25SERVICOS
					(cAlsTTNfs)->VLRADICC	:= (cAlias)->VLRADICIONAL
					(cAlsTTNfs)->VLRNRTADIC	:= (cAlias)->VLRNRETADIC
					(cAlsTTNfs)->CHVNF		:= (cAlias)->CHVNF
					(cAlsTTNfs)->IDPART		:= (cAlias)->IDPART
					(cAlsTTNfs)->CPRB		:= (cAlias)->CPRB
					(cAlsTTNfs)->RECNO 		:= (cAlias)->RECNO
					(cAlsTTNfs)->ALIQ 		:= (cAlias)->ALIQ
					(cAlsTTNfs)->(MsUnlock())
				Else

					RecLock(cAlsTTNfs,.F.)

					(cAlsTTNfs)->VLRBASERET	+= (cAlias)->VLRBASERET
					(cAlsTTNfs)->VLRRETENC	+= (cAlias)->VLRRETENCAO
					(cAlsTTNfs)->VLRRETSUB	+= (cAlias)->VLRRETSUB
					(cAlsTTNfs)->VLRNRETPRI	+= (cAlias)->VLRNRETPRINC
					(cAlsTTNfs)->VLRSERV15	+= (cAlias)->VLR15SERVICOS
					(cAlsTTNfs)->VLRSERV20	+= (cAlias)->VLR20SERVICOS
					(cAlsTTNfs)->VLRSERV25	+= (cAlias)->VLR25SERVICOS
					(cAlsTTNfs)->VLRADICC	+= (cAlias)->VLRADICIONAL
					(cAlsTTNfs)->VLRNRTADIC	+= (cAlias)->VLRNRETADIC

					(cAlsTTNfs)->(MsUnlock())
				EndIf
			EndIf

			cProcID := (cAlias)->PROCID

			If !(cAlsTTCabc)->(DbSeek( cId ))
				cChave := cFil + cId + (cAlias)->ROTINA + (cAlias)->NUMDOCTO
				
				RecLock(cAlsTTCabc,.T.)
				(cAlsTTCabc)->ID			:= cId
				(cAlsTTCabc)->ROTINA		:= (cAlias)->ROTINA
				(cAlsTTCabc)->cTpInsc 		:= cTpInsc
				(cAlsTTCabc)->cNrIndc		:= cNrIndc
				(cAlsTTCabc)->cTpInscTom	:= cTpInscTom
				(cAlsTTCabc)->cCNPJTmPr		:= cCNPJTmPr
				(cAlsTTCabc)->cIndObra		:= cIndObra
				(cAlsTTCabc)->cIdObra		:= cIdObra
				(cAlsTTCabc)->cDsObra		:= cDsObra
				(cAlsTTCabc)->vlrTBruto		:= (cAlias)->VLRBRUTO
				(cAlsTTCabc)->vlrTBRet		:= (cAlias)->VLRBASERET
				(cAlsTTCabc)->nVlTlRtPc		:= nVlTlRtPc
				(cAlsTTCabc)->vlrTRAdic		:= (cAlias)->VLRADICIONAL
				(cAlsTTCabc)->vlrTNRPrnc	:= (cAlias)->VLRNRETPRINC
				(cAlsTTCabc)->vlrTNRAdic	:= (cAlias)->VLRNRETADIC
				(cAlsTTCabc)->IDPART		:= (cAlias)->IDPART
				(cAlsTTCabc)->CPRB			:= (cAlias)->CPRB
				(cAlsTTCabc)->CNPJ			:= (cAlias)->CNPJ
				(cAlsTTCabc)->cPeriodo		:= cPeriod
				(cAlsTTCabc)->CODPAR		:= (cAlias)->C1HCODPAR
				(cAlsTTCabc)->C1HNOME		:= (cAlias)->C1HNOME
				(cAlsTTCabc)->FIL			:= cFil
				(cAlsTTCabc)->TOTDOC		:= nNewDoc
				If Empty(cProcID)
					(cAlsTTCabc)->PROCID		:= "1" // 1 - notValidated
				EndIf

				(cAlsTTCabc)->(MsUnlock())
			Else
				RecLock(cAlsTTCabc,.F.)
				/*O Valor bruto nao deve ser somado a cada item, ou seja apenas acumula o valor para cada documento ou fatura diferente x servico, 
				o item nao e utilizado em tags para apuracao (assim como o codigo do produto nao consta), portanto sera retirado da tela do po-ui. */
				if cChave <> cFil + cId + (cAlias)->ROTINA + (cAlias)->NUMDOCTO
					(cAlsTTCabc)->vlrTBruto	+= (cAlias)->VLRBRUTO
					cChave := cFil + cId + (cAlias)->ROTINA + (cAlias)->NUMDOCTO
				endif
				(cAlsTTCabc)->vlrTBRet		+= (cAlias)->VLRBASERET
				(cAlsTTCabc)->nVlTlRtPc		+= nVlTlRtPc//((cAlias)->VLRRETENCAO - (cAlias)->VLRRETSUB)
				(cAlsTTCabc)->vlrTRAdic		+= (cAlias)->VLRADICIONAL
				(cAlsTTCabc)->vlrTNRPrnc	+= (cAlias)->VLRNRETPRINC
				(cAlsTTCabc)->vlrTNRAdic	+= (cAlias)->VLRNRETADIC
				(cAlsTTCabc)->TOTDOC		:= (cAlsTTCabc)->TOTDOC + nNewDoc
				If Empty(cProcID)
					(cAlsTTCabc)->PROCID		:= "1" // 1 - notValidated
				EndIf
				(cAlsTTCabc)->(MsUnlock())
				
			EndIf
			
			nContLaco++

			(cAlias)->(DbSkip())
		EndDo
	Else
		lAvanc := .F.
	EndIf
	(cAlias)->(DbCloseArea())

Return {{cAlsTTCabc,oTTCabc}, {cAlsTTNfs,oTTNfs}, {cAlsTTProc,oTTProc}, lAvanc}

//-------------------------------------------------------------------
/*/{Protheus.doc} RetProc

@author Henrique Pereira
@since 20/02/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function RetProc(cAlsTTProc, Alias, aCampProc, cChavProc, cCompC1G, aSM0EUF)

	Local aRet			As Array
	Local cSelect		AS Character
	Local cFrom			AS Character
	Local cJoin			AS Character
	Local cJoinC1G		AS Character
	Local cWhere		AS Character
	Local cChave		AS Character
	Local cAliasT9Q		AS Character
	Local cChavSeek		AS Character
	Local cFilC1G		AS Character
	Local cBd			As Character
	Local nTam			As Numeric
	Local nTamIDSUSP	As Numeric
	Local lFormat		As Logical
	Local lProcessa		As Logical

	aRet		:= {}
	cSelect		:= ''
	cFrom		:= ''
	cJoin		:= ''
	cJoinC1G	:= ''
	cWhere		:= ''
	cChave		:= ''
	cChavSeek	:= ''
	cFilC1G		:= xFilial("C1G")
	cAliasT9Q	:= GetNextAlias()
	cBd			:= TcGetDb()
	nTam		:= 0
	nTamIDSUSP	:= 0
	lProcessa	:= .F.
	lFormat		:= .F.

	If 'NFS' $ ALLTRIM((Alias)->ROTINA)

		cSelect 	:= "'" + cChavProc + "' AS ID,  '"+ (Alias)->CHVNF + "' AS CCHAVE, 'NFS' AS ROTINA, T9Q.T9Q_TPPROC AS CTPPROC , T9Q.T9Q_NUMPRO AS NUMPRO, T5L.T5L_CODSUS AS CODSUS, T9Q.T9Q_VALSUS AS VALSUS, C1G.C1G_TPPROC AS C1GTPPROC, C1G.C1G_NUMPRO AS C1GNUMPRO, C1G.C1G_ID AS C1GID, C1G.C1G_VERSAO AS C1GVERSAO, C1G.C1G_FILIAL AS C1GFILIAL "

		cFrom		:= RetSqlName("T9Q") + " T9Q"

		cJoinC1G	:=  RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL AND "
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				Iif(nTam > 0, lFormat := .T., lFormat := .F.)
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA]
				Iif(nTam > 0, lFormat := .T., lFormat := .F.)
			EndIf
			if lFormat
				If cBd $ "ORACLE|POSTGRES|DB2"
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTR(T9Q.T9Q_FILIAL,1," + cValToChar(nTam) + " ) AND "
				ElseIf cBd $ "INFORMIX"
					cJoinC1G += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL[1," + cValToChar(nTam) + "] AND "
				Else //MSSQL,MYSQL,PROGRESS
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTRING(T9Q.T9Q_FILIAL,1," + cValToChar(nTam) + " ) AND "
				EndIf
			EndIf
		EndIf

		cJoinC1G += " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "

		If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
			if  cBd $ "POSTGRES"
				nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
				cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = SUBSTR(T5L_ID || T5L_VERSAO || T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND  T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
			else
				cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L_ID || T5L_VERSAO || T5L_CODSUS AND  T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
			Endif
		Else
			cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L_ID+T5L_VERSAO+T5L_CODSUS AND  T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
		EndIf
		cJoin += " T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere := "  T9Q.D_E_L_E_T_ = ' ' AND T9Q.T9Q_CHVNF = '" + (Alias)->CHVNF +  "' AND T9Q.T9Q_CODTRI = '000013' "

		//cSelect := 'SELECT ' + cSelect + ' FROM ' + cFrom + ' INNER JOIN ' + cJoinC1G + ' INNER JOIN ' + cJoin + ' Where ' + cWhere

		cSelect 	:= "%" +	cSelect 	+ 	"%"
		cFrom		:= "%" +	cFrom	 	+ 	"%"
		cJoinC1G	:= "%" +	cJoinC1G	+ 	"%"
		cJoin 		:= "%" +	cJoin 		+ 	"%"
		cWhere 		:= "%" +	cWhere 		+ 	"%"

	Elseif 'FAT' $ ALLTRIM((Alias)->ROTINA)

		cSelect 	:= "'" + cChavProc + "' AS ID, '"+ (Alias)->NUMDOCTO + "' AS CCHAVE, 'FAT' AS ROTINA, T9E.T9E_TPPROC AS CTPPROC , T9E.T9E_NUMPRO AS NUMPRO, T5L.T5L_CODSUS AS CODSUS, T9E.T9E_VALSUS AS VALSUS, C1G.C1G_TPPROC AS C1GTPPROC, C1G.C1G_NUMPRO AS C1GNUMPRO, C1G.C1G_ID AS C1GID, C1G.C1G_VERSAO AS C1GVERSAO, C1G.C1G_FILIAL AS C1GFILIAL "

		cFrom		:= RetSqlName("T9E") + " T9E"

		cJoinC1G 	:=  RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = T9E.T9E_FILIAL AND "
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				Iif(nTam > 0, lFormat := .T., lFormat := .F.)
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA]
				Iif(nTam > 0, lFormat := .T., lFormat := .F.)
			EndIf

			if lFormat
				If cBd $ "ORACLE|POSTGRES|DB2"
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTR(T9E.T9E_FILIAL,1," + cValToChar(nTam) + " ) AND "
				ElseIf cBd $ "INFORMIX"
					cJoinC1G += " C1G.C1G_FILIAL = T9E.T9E_FILIAL[1," + cValToChar(nTam) + "] AND "
				Else //MSSQL,MYSQL,PROGRESS
					cJoinC1G += " C1G.C1G_FILIAL = SUBSTRING(T9E.T9E_FILIAL,1," + cValToChar(nTam) + " ) AND "
				EndIf
			EndIf
		EndIf

		cJoinC1G	+= " C1G.C1G_ID = T9E.T9E_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "

		If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
			if  cBd $ "POSTGRES"
				nTamIDSUSP	:= TamSX3("T9E_IDSUSP")[1]
				cJoin :=  RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = SUBSTR(T5L_ID || T5L_VERSAO || T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND  T9E.T9E_FILIAL = '" +  (Alias)->FIL + "' AND "
			Else
				cJoin :=  RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = T5L_ID || T5L_VERSAO || T5L_CODSUS AND  T9E.T9E_FILIAL = '" +  (Alias)->FIL + "' AND "
			Endif
		Else
			cJoin :=  RetSqlName("T5L") + " T5L ON T9E.T9E_IDSUSP = T5L_ID+T5L_VERSAO+T5L_CODSUS AND  T9E.T9E_FILIAL = '" +  (Alias)->FIL + "' AND "
		EndIf
		cJoin += " T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere		:= " T9E.D_E_L_E_T_ = ' ' AND T9E.T9E_ID = '" + (Alias)->ID +  "' AND T9E.T9E_CODTRI = '000013' "
		//cSelect := 'SELECT ' + cSelect + ' FROM ' + cFrom + ' INNER JOIN ' + cJoinC1G + ' INNER JOIN ' + cJoin+ ' Where ' + cWhere

		cSelect 	:= "%" +	cSelect 	+ 	"%"
		cFrom		:= "%" +	cFrom	 	+ 	"%"
		cJoinC1G	:= "%" +	cJoinC1G	+ 	"%"
		cJoin 		:= "%" +	cJoin 		+ 	"%"
		cWhere		:= "%" +	cWhere 		+ 	"%"

	EndIf

	BeginSql Alias cAliasT9Q
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		INNER JOIN
		%Exp:cJoinC1G%
		INNER JOIN
		%Exp:cJoin%
		Where
		%Exp:cWhere%
	EndSql

	//INSERTTMP(cNmTTProc, cSelect, aCampProc)
	If!(cAliasT9Q)->(EOF())
		cChavSeek := Iif((cAliasT9Q)->C1GTPPROC == "1", "2", "1") + (cAliasT9Q)->CTPPROC+(cAliasT9Q)->C1GNUMPRO+(cAliasT9Q)->CODSUS + (cAliasT9Q)->ID
		lProcessa	:= .T.
	EndIf

	DbSelectArea(cAlsTTProc)

	(cAlsTTProc)->(DbSetOrder(3)) //"C1GTPPROC", "CTPPROC","C1GNUMPRO", "CODSUS"
	(cAliasT9Q)->(DbGoTop())
	If lProcessa
		If !(cAliasT9Q)->(EOF())
			While !(cAliasT9Q)->(EOF())
				If !(cAlsTTProc)->(MsSeek(cChavSeek))
					RecLock(cAlsTTProc, .T.)
					(cAlsTTProc)->ID		:= (cAliasT9Q)->ID
					(cAlsTTProc)->CCHAVE	:= (cAliasT9Q)->CCHAVE
					(cAlsTTProc)->ROTINA	:= (cAliasT9Q)->ROTINA
					(cAlsTTProc)->CTPPROC	:= (cAliasT9Q)->CTPPROC
					(cAlsTTProc)->NUMPRO	:= (cAliasT9Q)->NUMPRO
					(cAlsTTProc)->CODSUS	:= (cAliasT9Q)->CODSUS
					(cAlsTTProc)->VALSUS	:= (cAliasT9Q)->VALSUS
					(cAlsTTProc)->C1GTPPROC	:= Iif((cAliasT9Q)->C1GTPPROC == "1", "2", "1")
					(cAlsTTProc)->C1GNUMPRO	:= (cAliasT9Q)->C1GNUMPRO
					(cAlsTTProc)->C1GID		:= (cAliasT9Q)->C1GID
					(cAlsTTProc)->C1GVERSAO	:= (cAliasT9Q)->C1GVERSAO
					(cAlsTTProc)->C1GFILIAL	:= (cAliasT9Q)->C1GFILIAL

				Else
					RecLock(cAlsTTProc, .F.)
					(cAlsTTProc)->VALSUS += (cAliasT9Q)->VALSUS
				EndIf
				(cAliasT9Q)->(DbSkip())
				cChavSeek := Iif((cAliasT9Q)->C1GTPPROC == "1", "2", "1") + (cAliasT9Q)->CTPPROC+(cAliasT9Q)->C1GNUMPRO+(cAliasT9Q)->CODSUS + (cAliasT9Q)->ID
			EndDo
			(cAliasT9Q)->(MsUnlock())
		Endif
	EndIf
	(cAliasT9Q)->(DbCloseArea())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2020

Efetua gravação no modelo da tabela espelho do evento R-2020 (Serviços Prestados)

@author Denis Naves
@since 20/02/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2020( nOpc, cPerApu, aApuracao, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, aErro, cId, lValid, cStatus )

	Local oModelCMN 	As Object
	Local oModelCRO 	As Object
	Local oModelT9Y 	As Object
	Local oModelT9Z		As Object
	Local oModelV0A		As Object
	Local nTotBrut		As Numeric
	Local nQtdT9Z		As Numeric
	Local nQtdV0A		As Numeric
	Local nErro			As Numeric
	Local nContLaco		As Numeric
	Local nContNfFt		As Numeric
	Local nPNRetAdic	As Numeric
	Local nPNRetPrin	As Numeric
	Local nTNRetAdic	As Numeric
	Local nTNRetPrin	As Numeric
	Local lMostraDet	As Logical
	Local lRollBack		As Logical
	Local cNumDoc		As Character
	Local cSerie		As Character
	Local cEvento		As Character
	Local cTpInscEst	As Character
	Local cNrInscEst	As Character
	Local cChaveReg		As Character
	Local cCabErro 		As Character
	Local cErro			As Character
	Local cTagErro 		As Character
	Local aMovs			As Array
	Local aDadosUtil	As Array
	Local aDocsErro		As Array
	Local aProcErro		As Array
	Local aNFFat		As Array

	Default nOpc 	:= 3
	Default cVerAnt := ''
	Default	cProTpn	:= ''
	Default	cID		:= ''
	Default lValid 	:= .F.

	nTotBrut	:= 0
	nQtdT9Z	:= 0
	nQtdV0A	:= 0
	nErro		:= 0
	nContLaco	:= 1
	nContNfFt	:= 1
	nPNRetAdic	:= 0
	nPNRetPrin	:= 0
	nTNRetAdic	:= 0
	nTNRetPrin	:= 0

	aMovs		:= {}
	aDadosUtil	:= {}
	aDocsErro	:= {}
	aProcErro	:= {}
	aNFFat		:= {}
	oModelCMN 	:= Nil
	oModelCRO 	:= Nil
	oModelT9Y 	:= Nil
	oModelT9Z	:= Nil
	oModelV0A 	:= Nil

	cNumDoc		:= ""
	cSerie		:= ""
	cNrInscEst	:= ""
	cTpInscEst	:= ""
	cChaveReg	:= ""
	cEvento		:= "I"
	cCabErro	:= ""
	cErro		:= ""
	cTagErro	:= ""

	lRollBack 	:= .T.
	lMostraDet	:= .F.

	oModelCMN 	:= oModel478:GetModel( "MODEL_CMN" )
	oModelCRO 	:= oModel478:GetModel( "MODEL_CRO" )
	oModelT9Y 	:= oModel478:GetModel( "MODEL_T9Y" )
	oModelT9Z 	:= oModel478:GetModel( "MODEL_T9Z" )
	oModelV0A 	:= oModel478:GetModel( "MODEL_V0A" )

	oModel478:SetOperation(nOpc)
	oModel478:Activate()

	If !Empty(cVerAnt)
		oModel478:LoadValue('MODEL_CMN', 'CMN_VERANT', cVerAnt)
		oModel478:LoadValue('MODEL_CMN', 'CMN_PROTPN', cProTpn)
		oModel478:LoadValue('MODEL_CMN', 'CMN_ID', cId)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel478:LoadValue('MODEL_CMN', 'CMN_VERSAO' , xFunGetVer())
	oModel478:LoadValue('MODEL_CMN', 'CMN_STATUS' , '')
	oModel478:LoadValue('MODEL_CMN', 'CMN_EVENTO' , cEvento)
	oModel478:LoadValue('MODEL_CMN', 'CMN_ATIVO'  , '1')

	oModel478:LoadValue('MODEL_CMN', 'CMN_PERAPU' , cPerApu)
	oModel478:LoadValue('MODEL_CMN', 'CMN_IDESTA' , aInfoC1E[1])
	oModel478:LoadValue('MODEL_CMN', 'CMN_DESTAB' , aInfoC1E[2])

	cTpInscEst := "1"
	cNrInscEst := (aApuracao[SINTETICO])->CNRINDC

	oModel478:LoadValue('MODEL_CMN', 'CMN_TPINSC' , cTpInscEst)							//tpInscEstabPrest
	oModel478:LoadValue('MODEL_CMN', 'CMN_NRINSC' , cNrInscEst)							//nrInscEstabPrest
	oModel478:LoadValue('MODEL_CMN', 'CMN_TPINST' , (aApuracao[SINTETICO])->CTPINSCTOM)	//tpInscTomador
	oModel478:LoadValue('MODEL_CMN', 'CMN_NRINST' , (aApuracao[SINTETICO])->CCNPJTMPR)		//nrInscTomador
	oModel478:LoadValue('MODEL_CMN', 'CMN_INDOBR' , (aApuracao[SINTETICO])->CINDOBRA) 		//indObra

	if TAFColumnPos( "CMN_CODPAR" ) .and. TAFColumnPos( "CMN_IDPART" ) .and. TAFColumnPos( "CMN_DPARTI" ) .and. TAFColumnPos( "CMN_CNPJPR" )
		oModel478:LoadValue('MODEL_CMN', 'CMN_CODPAR' , (aApuracao[SINTETICO])->CODPAR)
		oModel478:LoadValue('MODEL_CMN', 'CMN_IDPART' , (aApuracao[SINTETICO])->IDPART)
		oModel478:LoadValue('MODEL_CMN', 'CMN_DPARTI' , (aApuracao[SINTETICO])->C1HNOME)
		oModel478:LoadValue('MODEL_CMN', 'CMN_CNPJPR' , (aApuracao[SINTETICO])->CNPJ) 												//cnpjPrestador
	endif

	If !Empty((aApuracao[SINTETICO])->CIDOBRA)
		oModel478:LoadValue('MODEL_CMN', 'CMN_TPNUOB' 	, (aApuracao[SINTETICO])->CTPINSCTOM + (aApuracao[SINTETICO])->CCNPJTMPR)
		oModel478:LoadValue('MODEL_CMN', 'CMN_DOBRA'	, (aApuracao[SINTETICO])->CDSOBRA)
		oModel478:LoadValue('MODEL_CMN', 'CMN_IDOBRA' 	, (aApuracao[SINTETICO])->CIDOBRA)
	EndIf

	oModel478:LoadValue('MODEL_CMN', 'CMN_VLRBRE' , (aApuracao[SINTETICO])->VLRTBRET) 			//vlrTotalBaseRet

	nTNRetPrin := (aApuracao[SINTETICO])->VLRTNRPRNC
	nTNRetAdic := (aApuracao[SINTETICO])->VLRTNRADIC
	oModel478:LoadValue('MODEL_CMN', 'CMN_VLRPRI' , (aApuracao[SINTETICO])->NVLTLRTPC)			//vlrTotalRetPrinc
	oModel478:LoadValue('MODEL_CMN', 'CMN_VLRADI' , (aApuracao[SINTETICO])->VLRTRADIC)			//vlrTotalRetAdic
	oModel478:LoadValue('MODEL_CMN', 'CMN_VLRNPR' , (aApuracao[SINTETICO])->VLRTNRPRNC)		//vlrTotalNRetPrinc
	oModel478:LoadValue('MODEL_CMN', 'CMN_VLRNAD' , (aApuracao[SINTETICO])->VLRTNRADIC)		//vlrTotalNRetAdic

	cCabErro := MontCabErr("R-2020", cTpInscEst, cNrInscEst, "", (aApuracao[SINTETICO])->CTPINSCTOM, (aApuracao[SINTETICO])->CCNPJTMPR)

	If !VldObrigat(aApuracao, "ideTomador", @cTagErro)
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
	EndIf

	If !VldTags(aApuracao, "ideTomador", @cTagErro)
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
		lMostraDet := .T.
	EndIf

	(aApuracao[ANALITICO])->(DbSetOrder(1))
	(aApuracao[ANALITICO])->(DbSeek((aApuracao[SINTETICO])->ID))

	While !(aApuracao[ANALITICO])->(Eof()) .And. (aApuracao[SINTETICO])->ID == (aApuracao[ANALITICO])->ID

		If nContNFFt++ == 1 .Or. cNumDoc + cSerie <> (aApuracao[ANALITICO])->NUMDOCTO + (aApuracao[ANALITICO])->SERIE

			oModelCRO:lValid:= .T.
			iif( nOpc == MODEL_OPERATION_INSERT, oModelCRO:AddLine(), .F.)

			cNumDoc 	:= (aApuracao[ANALITICO])->NUMDOCTO
			cSerie		:= (aApuracao[ANALITICO])->SERIE
			nTotBrut	+= (aApuracao[ANALITICO])->VLRBRUTO

			oModel478:LoadValue('MODEL_CMN', 'CMN_VLRBRU' , nTotBrut) //vlrTotalBruto

			If Alltrim((aApuracao[ANALITICO])->ROTINA) == "NFS"
				oModel478:LoadValue('MODEL_CRO', 'CRO_CHVNF'	, (aApuracao[ANALITICO])->CHVNF)
				oModel478:LoadValue('MODEL_CRO', 'CRO_NUMDOC'	, Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) 	//numDocto
				oModel478:LoadValue('MODEL_CRO', 'CRO_OBSERV'	, ObsNtC21((aApuracao[ANALITICO])->FIL, (aApuracao[ANALITICO])->CHVNF))	//obs
			Else
				oModel478:LoadValue('MODEL_CRO', 'CRO_NUMFAT'	, Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) 	//numDocto
				oModel478:LoadValue('MODEL_CRO', 'CRO_OBSERV'	, (aApuracao[ANALITICO])->OBS)					 	//obs
			EndIf

			oModel478:LoadValue('MODEL_CRO', 'CRO_SERIE'	, Substr((aApuracao[ANALITICO])->SERIE,1,5))			//serie
			oModel478:LoadValue('MODEL_CRO', 'CRO_DTEMIS'	, (aApuracao[ANALITICO])->DTEMISSNF)					//dtEmissaoNF
			oModel478:LoadValue('MODEL_CRO', 'CRO_VLRBRU'	, (aApuracao[ANALITICO])->VLRBRUTO)						//vlrBruto

			If !VldObrigat(aApuracao, "nfs", @cTagErro)
				cErro += cTagErro
				cTagErro := ""
				If lValid
					lRollBack := .F.
				EndIf
			EndIf

			If !VldTags(aApuracao, "nfs", @cTagErro)
				cErro += cTagErro
				cTagErro := ""
				If lValid
					lRollBack := .F.
				EndIf
			EndIf

			aadd(aMovs, {(aApuracao[ANALITICO])->ROTINA, (aApuracao[ANALITICO])->RECNO})
			AAdd(aNFFat, {Alltrim((aApuracao[ANALITICO])->ROTINA), cNumDoc, cSerie})
		EndIf

		If nContLaco++ > 1
			oModelT9Y:lValid := .T.
			oModelT9Y:AddLine()
		EndIf

		oModel478:LoadValue('MODEL_T9Y', 'T9Y_TPSERV', (aApuracao[ANALITICO])->TPSERVICO)	//tpServico
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_CODSER', (aApuracao[ANALITICO])->CODSERVIC) 	//CodServico
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_DTPSER', (aApuracao[ANALITICO])->C8CDESCRI)
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRBAS', (aApuracao[ANALITICO])->VLRBASERET)	//vlrBaseRet
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRRET', (aApuracao[ANALITICO])->VLRRETENC)	//vlrRetencao
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRRSU', (aApuracao[ANALITICO])->VLRRETSUB)	//vlrRetSub
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRNPR', (aApuracao[ANALITICO])->VLRNRETPRI)	//vlrNRetPrinc
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRS15', (aApuracao[ANALITICO])->VLRSERV15) 	//vlrServicos15
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRS20', (aApuracao[ANALITICO])->VLRSERV20) 	//vlrServicos20
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRS25', (aApuracao[ANALITICO])->VLRSERV25)	//vlrServicos25
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRADI', (aApuracao[ANALITICO])->VLRADICC)	//vlrAdicional
		oModel478:LoadValue('MODEL_T9Y', 'T9Y_VLRNRE', (aApuracao[ANALITICO])->VLRNRTADIC)	//vlrNRetAdic

		If !VldObrigat(aApuracao, "infoTpServ", @cTagErro)
			cErro += cTagErro
			cTagErro := ""
			If lValid
				lRollBack := .F.
			EndIf
		EndIf

		If !VldTags(aApuracao, "infoTpServ", @cTagErro)
			cErro += cTagErro
			cTagErro := ""
			If lValid
				lRollBack := .F.
			EndIf
		EndIf

		(aApuracao[ANALITICO])->(DbSkip())
	EndDo

	//VALOR BRUTO DO CABECALHO
	oModel478:LoadValue('MODEL_CMN', 'CMN_VLRBRU' , nTotBrut) //vlrTotalBruto

	nContLaco := 1

	(aApuracao[PROCESSOS])->(DbSetOrder(1))
	(aApuracao[PROCESSOS])->(DbSeek((aApuracao[SINTETICO])->ID))

	While !(aApuracao[PROCESSOS])->(Eof()) .And. (aApuracao[SINTETICO])->ID == (aApuracao[PROCESSOS])->ID

		//1=Processo sobre a contribuição previdenciária PRINCIPAL
		If (aApuracao[PROCESSOS])->CTPPROC == "1"
			oModelT9Z:lValid:= .T.
			iif(++nQtdT9Z > 1 .And. nOpc == MODEL_OPERATION_INSERT, oModelT9Z:AddLine(), .F.)
			nPNRetPrin += (aApuracao[PROCESSOS])->VALSUS

			oModel478:LoadValue('MODEL_T9Z', 'T9Z_IDPROC', (aApuracao[PROCESSOS])->NUMPRO)
			oModel478:LoadValue('MODEL_T9Z', 'T9Z_NUMPRO', (aApuracao[PROCESSOS])->C1GNUMPRO)
			oModel478:LoadValue('MODEL_T9Z', 'T9Z_TPPROC', (aApuracao[PROCESSOS])->C1GTPPROC)	//tpProcRetPrinc
			oModel478:LoadValue('MODEL_T9Z', 'T9Z_CODSUS', (aApuracao[PROCESSOS])->CODSUS)		//codSuspPrinc
			oModel478:LoadValue('MODEL_T9Z', 'T9Z_VLRPRI', (aApuracao[PROCESSOS])->VALSUS)		//valorPrinc
			oModel478:LoadValue('MODEL_T9Z', 'T9Z_IDSUSP', (aApuracao[PROCESSOS])->C1GID + (aApuracao[PROCESSOS])->C1GVERSAO + (aApuracao[PROCESSOS])->CODSUS)

			//2=Processo sobre a contribuição previdenciária ADICIONAL
		ElseIf (aApuracao[PROCESSOS])->CTPPROC == "2"
			oModelV0A:lValid:= .T.
			iif(++nQtdV0A > 1 .And. nOpc == MODEL_OPERATION_INSERT, oModelV0A:AddLine(), .F.)

			nPNRetAdic += (aApuracao[PROCESSOS])->VALSUS

			oModel478:LoadValue('MODEL_V0A', 'V0A_IDPROC', (aApuracao[PROCESSOS])->NUMPRO)
			oModel478:LoadValue('MODEL_V0A', 'V0A_NUMPRO', (aApuracao[PROCESSOS])->C1GNUMPRO)
			oModel478:LoadValue('MODEL_V0A', 'V0A_TPPROC', (aApuracao[PROCESSOS])->C1GTPPROC)	//tpProcRetAdic
			oModel478:LoadValue('MODEL_V0A', 'V0A_CODSUS', (aApuracao[PROCESSOS])->CODSUS)		//codSuspAdic
			oModel478:LoadValue('MODEL_V0A', 'V0A_VLRADI', (aApuracao[PROCESSOS])->VALSUS)		//valorAdic
			oModel478:LoadValue('MODEL_V0A', 'V0A_IDSUSP', (aApuracao[PROCESSOS])->C1GID + (aApuracao[PROCESSOS])->C1GVERSAO + (aApuracao[PROCESSOS])->CODSUS)

		EndIf

		nContLaco++

		If !VldTags(aApuracao, "infoProc", @cTagErro)
			cErro += cTagErro
			cTagErro := ""
			If lValid
				lRollBack := .F.
			EndIf
		EndIf

		(aApuracao[PROCESSOS])->(DbSkip())
	EndDo

	AAdd(aDadosUtil, {nTNRetPrin, nPNRetPrin, nQtdT9Z})
	If !ValidGrp(aApuracao, "infoProcRetPr", @cTagErro, aDadosUtil)
		aDadosUtil := {}
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
		lMostraDet := .T.
	EndIf

	AAdd(aDadosUtil, {nTNRetAdic, nPNRetAdic, nQtdV0A})

	If !ValidGrp(aApuracao, "infoProcRetAd", @cTagErro, aDadosUtil)
		aDadosUtil := {}
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
		lMostraDet := .T.
	EndIf

	If lMostraDet
		cErro += MontNFFErr(aNFFat)
	EndIf

	If lRollBack
		If oModel478:VldData()
			FwFormCommit(oModel478)
			TafEndGRV( "CMN","CMN_PROCID", cIdApReinf, CMN->(Recno()))
			//Grava IDs
			GravaId(aMovs,cIdApReinf)
			lRollBack := .T.
		Else
			cErro 		+= "Detalhes técnicos do erro: " + CRLF + CRLF
			cErro		+= TafRetEMsg(oModel478)
			lRollBack 	:= .F.
		EndIf
	EndIf

	If !Empty(cErro)
		Aadd(aErro, {"R-2020", Iif(lValid, "ERRO", "ALERTA"), cCabErro + cErro})
	EndIf

	oModel478:DeActivate()

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2010
Efetua gravação no modelo da tabela espelho do evento R-2010 (Serviços Tomados)

@author anieli.rodrigues
@since 20/02/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2010(nOpc, cPerApu, aApuracao, aInfoC1E,  cVerAnt, cProTpn, cIdApReinf, aErro, cId, lValid, cStatus )

	Local aDadosUtil	As Array
	Local aNFFat		As Array
	Local cCabErro 		As Character
	Local cErro			As Character
	Local cNumDoc		As Character
	Local cNrInscEst	As Character
	Local cSerie		As Character
	Local cTagErro 		As Character
	Local cTpInscEst    As Character
	Local cEvento		As Character
	Local cChaveReg		As Character
	Local lMostraDet	As Logical
	Local lRollBack		As Logical
	Local nContLaco		As Numeric
	Local nContNfFat	As Numeric
	Local nContT98 	 	As Numeric
	Local nContT99  	As Numeric
	Local nPNRetAdic	As Numeric
	Local nPNRetPrin	As Numeric
	Local nTNRetAdic	As Numeric
	Local nTNRetPrin	As Numeric
	Local nTotBrut		As Numeric
	Local nX			As Numeric
	Local nY			As Numeric
	Local nErro			As Numeric
	Local oModelT96		As Object
	Local oModelT97		As Object
	Local oModelT98		As Object
	Local oModelT99		As Object
	Local aMovs			As Array
	Local aDocsErro		As Array

	Default lValid 	:=  .F.

	aDadosUtil	:= {}
	aNFFat		:= {}
	cCabErro	:= ""
	cErro		:= ""
	cNumDoc 	:= ""
	cNrInscEst	:= ""
	cTagErro	:= ""
	cTpInscEst	:= ""
	cSerie		:= ""
	cChaveReg	:= ""
	cEvento		:= "I"
	lMostraDet	:= .F.
	lRollBack	:= .T.
	nContLaco	:= 1
	nContNfFat	:= 1
	nContT98	:= 1
	nContT99	:= 1
	nPNRetAdic	:= 0
	nPNRetPrin	:= 0
	nTNRetAdic	:= 0
	nTNRetPrin	:= 0
	nTotBrut	:= 0
	nX			:= 0
	nY			:= 0
	nErro		:= 0
	aMovs		:= {}
	aDocsErro	:= {}

	Default	cVerAnt	:= ''
	Default cProTpn	:= ''
	Default cId		:= ''

	oModelT96 	:= oModel486:GetModel("MODEL_T96")
	oModelT97 	:= oModel486:GetModel("MODEL_T97")
	oModelT98 	:= oModel486:GetModel("MODEL_T98")
	oModelT99 	:= oModel486:GetModel("MODEL_T99")

	oModel486:SetOperation(nOpc)
	oModel486:Activate()

	If !Empty(cVerAnt)
		oModel486:LoadValue('MODEL_T95', 'T95_VERANT', cVerAnt)
		oModel486:LoadValue('MODEL_T95', 'T95_PROTPN', cProTpn)
		oModel486:LoadValue('MODEL_T95', 'T95_ID', cId)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel486:LoadValue('MODEL_T95', 'T95_VERSAO'  , xFunGetVer())
	oModel486:LoadValue('MODEL_T95', 'T95_STATUS'  , '')
	oModel486:LoadValue('MODEL_T95', 'T95_EVENTO'  , cEvento)
	oModel486:LoadValue('MODEL_T95', 'T95_ATIVO'   , '1')

	oModel486:LoadValue('MODEL_T95', 'T95_PERAPU', cPerApu)
	oModel486:LoadValue('MODEL_T95', 'T95_IDESTA', aInfoC1E[1])
	oModel486:LoadValue('MODEL_T95', 'T95_DESTAB', aInfoC1E[2])
	oModel486:LoadValue('MODEL_T95', 'T95_INDOBR', (aApuracao[SINTETICO])->CINDOBRA)	//indObra
	If (aApuracao[SINTETICO])->CINDOBRA == "0"										// não é obra
		cTpInscEst := "1"
		cNrInscEst := (aApuracao[SINTETICO])->CNRINDC
		oModel486:LoadValue('MODEL_T95', 'T95_TPINSC', cTpInscEst)						//tpInscEstab - CNPJ
		oModel486:LoadValue('MODEL_T95', 'T95_NRINSC', cNrInscEst) 					//nrInscEstab
	Else
		cTpInscEst := (aApuracao[SINTETICO])->CTPINSC
		cNrInscEst := (aApuracao[SINTETICO])->CNRINDC
		oModel486:LoadValue('MODEL_T95', 'T95_TPINSC', cTpInscEst)						//tpInscEstab - CNO
		oModel486:LoadValue('MODEL_T95', 'T95_NRINSC', cNrInscEst)						//nrInscEstab
		oModel486:LoadValue('MODEL_T95', 'T95_TPNUOB', cTpInscEst + cNrInscEst)
		oModel486:LoadValue('MODEL_T95', 'T95_DOBRA' , (aApuracao[SINTETICO])->CDSOBRA)
	EndIf

	nTNRetAdic := (aApuracao[SINTETICO])->VLRTNRADIC
	nTNRetPrin := (aApuracao[SINTETICO])->VLRTNRPRNC

	oModel486:LoadValue('MODEL_T95', 'T95_IDPART', (aApuracao[SINTETICO])->IDPART)
	oModel486:LoadValue('MODEL_T95', 'T95_DPARTI', (aApuracao[SINTETICO])->C1HNOME)
	oModel486:LoadValue('MODEL_T95', 'T95_CNPJPR', (aApuracao[SINTETICO])->CNPJ) 												//cnpjPrestador
	oModel486:LoadValue('MODEL_T95', 'T95_VLRBRE', (aApuracao[SINTETICO])->VLRTBRET)											// vlrTotalBaseRet
	oModel486:LoadValue('MODEL_T95', 'T95_VLRPRI', (aApuracao[SINTETICO])->NVLTLRTPC)											// vlrTotalRetPrinc
	oModel486:LoadValue('MODEL_T95', 'T95_VLRADI', (aApuracao[SINTETICO])->VLRTRADIC)											// vlrTotalRetAdic
	oModel486:LoadValue('MODEL_T95', 'T95_VLRNPR', (aApuracao[SINTETICO])->VLRTNRPRNC)											// vlrTotalNRetPrinc
	oModel486:LoadValue('MODEL_T95', 'T95_VLRNAD', (aApuracao[SINTETICO])->VLRTNRADIC) 										// vlrTotalNRetAdic
	oModel486:LoadValue('MODEL_T95', 'T95_INDCPR', If (Empty((aApuracao[SINTETICO])->CPRB),"0", (aApuracao[SINTETICO])->CPRB))	// indCPRB
	oModel486:LoadValue('MODEL_T95', 'T95_CODPAR', (aApuracao[SINTETICO])->CODPAR)

	cCabErro := MontCabErr("R-2010", cTpInscEst, cNrInscEst, (aApuracao[SINTETICO])->CNPJ, , )

	If !VldTags(aApuracao, "idePrestServ", @cTagErro)
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
	EndIf

	(aApuracao[ANALITICO])->(DbSetOrder(1))
	(aApuracao[ANALITICO])->(DbSeek((aApuracao[SINTETICO])->ID))

	While !(aApuracao[ANALITICO])->(Eof()) .And. (aApuracao[SINTETICO])->ID == (aApuracao[ANALITICO])->ID

		If nContNFFat == 1 .Or. cNumDoc + cSerie <> (aApuracao[ANALITICO])->NUMDOCTO + (aApuracao[ANALITICO])->SERIE

			oModelT96:lValid:= .T.
			If nOpc == MODEL_OPERATION_INSERT
				oModelT96:AddLine()
			EndIf

			cNumDoc 	:= (aApuracao[ANALITICO])->NUMDOCTO
			cSerie		:= (aApuracao[ANALITICO])->SERIE
			nTotBrut	+= (aApuracao[ANALITICO])->VLRBRUTO

			If Alltrim((aApuracao[ANALITICO])->ROTINA) == "NFS"
				oModel486:LoadValue('MODEL_T96', 'T96_CHVNF',  (aApuracao[ANALITICO])->CHVNF)
				oModel486:LoadValue('MODEL_T96', 'T96_NUMDOC', Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15))		//numDocto
				oModel486:LoadValue('MODEL_T96', 'T96_OBSERV', ObsNtC21((aApuracao[ANALITICO])->FIL, (aApuracao[ANALITICO])->CHVNF))	//obs
			Else
				oModel486:LoadValue('MODEL_T96', 'T96_NUMFAT', Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15))		//numDocto
				oModel486:LoadValue('MODEL_T96', 'T96_OBSERV', (aApuracao[ANALITICO])->OBS)						//obs
			EndIf

			oModel486:LoadValue('MODEL_T96', 'T96_SERIE', Substr((aApuracao[ANALITICO])->SERIE,1,5))			//serie
			oModel486:LoadValue('MODEL_T96', 'T96_DTEMIS', (aApuracao[ANALITICO])->DTEMISSNF)					//dtEmissaoNF
			oModel486:LoadValue('MODEL_T96', 'T96_VLBRUT', (aApuracao[ANALITICO])->VLRBRUTO)					//vlrBruto

			If !VldObrigat(aApuracao, "nfs", @cTagErro)
				cErro += cTagErro
				cTagErro := ""
				If lValid
					lRollBack := .F.
				EndIf
			EndIf

			If !VldTags(aApuracao, "nfs", @cTagErro)
				cErro += cTagErro
				cTagErro := ""
				If lValid
					lRollBack := .F.
				EndIf
			EndIf

			aadd(aMovs, {(aApuracao[ANALITICO])->ROTINA, (aApuracao[ANALITICO])->RECNO})
			AAdd(aNFFat, {Alltrim((aApuracao[ANALITICO])->ROTINA), cNumDoc, cSerie})

		EndIf

		oModelT97:lValid:= .T.
		If nContLaco > 1 .And. nOpc == MODEL_OPERATION_INSERT
			oModelT97:AddLine()
		EndIf

		oModel486:LoadValue('MODEL_T97', 'T97_TPSERV', (aApuracao[ANALITICO])->TPSERVICO)	//tpServico
		oModel486:LoadValue('MODEL_T97', 'T97_CODSER', (aApuracao[ANALITICO])->CODSERVIC) 	//codServico
		oModel486:LoadValue('MODEL_T97', 'T97_DTPSER', (aApuracao[ANALITICO])->C8CDESCRI)
		oModel486:LoadValue('MODEL_T97', 'T97_VLRBAS', (aApuracao[ANALITICO])->VLRBASERET)	//vlrBaseRet
		oModel486:LoadValue('MODEL_T97', 'T97_VLRRET', (aApuracao[ANALITICO])->VLRRETENC)	//vlrRetencao
		oModel486:LoadValue('MODEL_T97', 'T97_VLRRSU', (aApuracao[ANALITICO])->VLRRETSUB)	//vlrRetSub
		oModel486:LoadValue('MODEL_T97', 'T97_VLRNPR', (aApuracao[ANALITICO])->VLRNRETPRI)	//vlrNRetPrinc
		oModel486:LoadValue('MODEL_T97', 'T97_VLRS15', (aApuracao[ANALITICO])->VLRSERV15)	//vlrServicos15
		oModel486:LoadValue('MODEL_T97', 'T97_VLRS20', (aApuracao[ANALITICO])->VLRSERV20)	//vlrServicos20
		oModel486:LoadValue('MODEL_T97', 'T97_VLRS25', (aApuracao[ANALITICO])->VLRSERV25 )	//vlrServicos25
		oModel486:LoadValue('MODEL_T97', 'T97_VLRADI', (aApuracao[ANALITICO])->VLRADICC)	//vlrAdicional
		oModel486:LoadValue('MODEL_T97', 'T97_VLRNRE', (aApuracao[ANALITICO])->VLRNRTADIC)	//vlrNRetAdic

		nContNFFat++
		nContLaco++

		If !VldObrigat(aApuracao, "infoTpServ", @cTagErro)
			cErro += cTagErro
			cTagErro := ""
			If lValid
				lRollBack := .F.
			EndIf
		EndIf

		If !VldTags(aApuracao, "infoTpServ", @cTagErro)
			cErro += cTagErro
			cTagErro := ""
			If lValid
				lRollBack := .F.
			EndIf
		EndIf

		(aApuracao[ANALITICO])->(DbSkip())

	EndDo

	oModel486:LoadValue('MODEL_T95', 'T95_VLRBRU', nTotBrut) 					// vlrTotalBruto

	nContLaco := 1

	(aApuracao[PROCESSOS])->(DbSetOrder(1))
	(aApuracao[PROCESSOS])->(DbSeek((aApuracao[SINTETICO])->ID))

	While !(aApuracao[PROCESSOS])->(Eof()) .And. (aApuracao[SINTETICO])->ID == (aApuracao[PROCESSOS])->ID

		If (aApuracao[PROCESSOS])->CTPPROC == "1"

			oModelT98:lValid:= .T.
			If nContT98 > 1 .And. nOpc == MODEL_OPERATION_INSERT
				oModelT98:AddLine()
			EndIf

			nPNRetPrin += (aApuracao[PROCESSOS])->VALSUS

			oModel486:LoadValue('MODEL_T98', 'T98_IDPROC', (aApuracao[PROCESSOS])->NUMPRO)
			oModel486:LoadValue('MODEL_T98', 'T98_NUMPRO', (aApuracao[PROCESSOS])->C1GNUMPRO)
			oModel486:LoadValue('MODEL_T98', 'T98_TPPROC', (aApuracao[PROCESSOS])->C1GTPPROC)	//tpProcRetPrinc
			oModel486:LoadValue('MODEL_T98', 'T98_CODSUS', (aApuracao[PROCESSOS])->CODSUS)		//codSuspPrinc
			oModel486:LoadValue('MODEL_T98', 'T98_VLRPRI', (aApuracao[PROCESSOS])->VALSUS)		//valorPrinc
			oModel486:LoadValue('MODEL_T98', 'T98_IDSUSP', (aApuracao[PROCESSOS])->C1GID + (aApuracao[PROCESSOS])->C1GVERSAO + (aApuracao[PROCESSOS])->CODSUS)
			nContT98++
		Else
			oModelT99:lValid:= .T.
			If nContT99 > 1 .And. nOpc == MODEL_OPERATION_INSERT
				oModelT99:AddLine()
			EndIf
			nPNRetAdic += (aApuracao[PROCESSOS])->VALSUS
			nContT99++
			oModel486:LoadValue('MODEL_T99', 'T99_IDPROC', (aApuracao[PROCESSOS])->NUMPRO)
			oModel486:LoadValue('MODEL_T99', 'T99_NUMPRO', (aApuracao[PROCESSOS])->C1GNUMPRO)
			oModel486:LoadValue('MODEL_T99', 'T99_TPPROC', (aApuracao[PROCESSOS])->C1GTPPROC)//tpProcRetAdic
			oModel486:LoadValue('MODEL_T99', 'T99_CODSUS', (aApuracao[PROCESSOS])->CODSUS)	//codSuspAdic
			oModel486:LoadValue('MODEL_T99', 'T99_VLRADI', (aApuracao[PROCESSOS])->VALSUS)	//valorAdic
			oModel486:LoadValue('MODEL_T99', 'T99_IDSUSP', (aApuracao[PROCESSOS])->C1GID + (aApuracao[PROCESSOS])->C1GVERSAO + (aApuracao[PROCESSOS])->CODSUS)
		EndIf

		nContLaco++

		If !VldTags(aApuracao, "infoProc", @cTagErro)
			cErro += cTagErro
			cTagErro := ""
			If lValid
				lRollBack := .F.
			EndIf
		EndIf

		(aApuracao[PROCESSOS])->(DbSkip())
	EndDo

	AAdd(aDadosUtil, {nTNRetPrin, nPNRetPrin, nContT98})
	If !ValidGrp(aApuracao, "infoProcRetPr", @cTagErro, aDadosUtil)
		aDadosUtil := {}
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
		lMostraDet := .T.
	EndIf

	AAdd(aDadosUtil, {nTNRetAdic, nPNRetAdic, nContT99})

	If !ValidGrp(aApuracao, "infoProcRetAd", @cTagErro, aDadosUtil)
		aDadosUtil := {}
		cErro += cTagErro
		cTagErro := ""
		If lValid
			lRollBack := .F.
		EndIf
		lMostraDet := .T.
	EndIf

	If lMostraDet
		cErro += MontNFFErr(aNFFat)
	EndIf

	If lRollBack
		If oModel486:VldData()
			FwFormCommit(oModel486)
			TafEndGRV( "T95","T95_PROCID", cIdApReinf, T95->(Recno()))
			//Grava IDs
			GravaId(aMovs,cIdApReinf)
			lRollBack := .T.
		Else
			cErro 		+= "Detalhes técnicos do erro: " + CRLF + CRLF
			cErro		+= TafRetEMsg(oModel486)
			lRollBack 	:= .F.
		EndIf
	Else
		lRollBack := .F.
	EndIf

	If !Empty(cErro)
		Aadd(aErro, {"R-2010", Iif(lValid, "ERRO", "ALERTA"), cCabErro + cErro})
	EndIf

	oModel486:DeActivate()

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} ObsNtC21()

Por se tratar de um campo Memo, deve-se retornar na query o RECNO e atraves
do Goto posicionar na tabela fisica para obter a informacao. Mesma ocorrencia
no fonte TAFXSPDA.

@author denis.souza
@since 20/02/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ObsNtC21(clFilial, clChvNota)

	Local cObs 		As Character
	Local cAliasC21	AS Character
	Local cSelect	As Character
	Local cFrom		As Character
	Local cWhere	As Character

	cObs 		:= ""
	cAliasC21	:= GetNextAlias()

	DbSelectArea("C21")

	cSelect 	:= " C21.C21_CODINF AS CODINF, C21.R_E_C_N_O_ AS C21RECNO "

	cFrom		:= RetSqlName("C21") + " C21"

	cWhere		:= " C21.C21_CHVNF = '" + clChvNota +  "' AND C21.C21_FILIAL = '"  + clFilial + "' AND C21.D_E_L_E_T_ = ' ' "

	cSelect 	:= "%" +	cSelect	+ 	"%"
	cFrom		:= "%" +	cFrom	+ 	"%"
	cWhere 		:= "%" +	cWhere 	+	"%"

	BeginSql Alias cAliasC21
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		Where
		%Exp:cWhere%
		Order By 1
	EndSql

	DbSelectArea(cAliasC21)
	(cAliasC21)->(DbGoTop())

	While (cAliasC21)->(!EOF())
		C21->(MsGoto((cAliasC21)->C21RECNO))
		if len(cObs) < 250
			cObs += SubStr(AllTrim(C21->C21_DESCRI) + " ",1,250)
		endif
		(cAliasC21)->(DbSkip())
	EndDo
	(cAliasC21)->(DbCloseArea())

Return SubStr(cObs,1,250)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()


@author Henrique Pereira
@since 22/02/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function GravaId(aMovs, cIdApur)

	Local	nX	as numeric

	Default aMovs 	:= {}
	Default cIdApur	:= ''

	For nX := 1 to Len(aMovs)
		Do case
		case Alltrim(aMovs[nX][1]) == 'NFS'
			TafEndGRV( "C20","C20_PROCID", cIdApur, aMovs[nX][2]  )
		case Alltrim(aMovs[nX][1]) == 'FAT'
			TafEndGRV( "LEM","LEM_PROCID", cIdApur, aMovs[nX][2]  )
		EndCase
	Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PopArray()
Popula as estrutas das 3 temporary tables utilizadas na apuração 

@author Henrique Pereira; Denis Naves
@since 07/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static function PopArray(aCampCabc, aCampNfs, aCampProc, cPeriodo )

Local nTamFil	:= TamSX3("C20_FILIAL")[1]
Local nTamChvNf	:= GetSx3Cache('C20_CHVNF','X3_TAMANHO')

aCampCabc:={{'ID'			,'C', 36 ,0},;
			{'ROTINA'		,'C', 03 ,0},;
			{'CTPINSC'		,'C', 01 ,0},; 	//CTPINSC
			{'CNRINDC'		,'C', 14 ,0},; 	//NRINSCTOMADOR
			{'CINDOBRA'		,'C', 01 ,0},; 	//INDOBRA
			{'CIDOBRA'		,'C', 36 ,0},; 	//CIDOBRA
			{'CDSOBRA'		,'C', 30 ,0},; 	//CDSOBRA
			{'VLRTBRUTO'	,'N', 14 ,2},; 	//-VLRTOTALBRUTO 	CALCULO = SOMA DE (VLRBRUTO)
			{'VLRTBRET'		,'N', 14 ,2},; 	//VLRTOTALBASERET	CALCULO = SOMA DE (VLRBASERET)
			{'NVLTLRTPC'	,'N', 14 ,2},; 	//VLRTOTALRETPRINC	CALCULO (VLRRETENCAO - VLRRETSUB)
			{'VLRTRADIC'	,'N', 14 ,2},; 	//VLRTOTALRETADIC 	CALCULO = SOMA DE (VLRADICIONAL)
			{'VLRTNRPRNC'	,'N', 14 ,2},; 	//VLRTOTALNRETPRINC	CALCULO = SOMA DE (VLRNRETPRINC)
			{'VLRTNRADIC'	,'N', 14 ,2},; 	//VLRTOTALNRETADIC	CALCULO = SOMA DE (VLRNRETADIC)
			{'IDPART'	 	,'C', 36 ,0},; 	//ID PARTICIPANTE
			{'CPRB'			,'C', 01 ,0},; 	//CPRB
			{'CNPJ'			,'C', 14 ,0},; 	//CNPJ PARTICIPANTE
			{'C1HNOME'		,'C', 220 ,0},; //Nome PARTICIPANTE
			{'CPERIODO'		,'C', 06 ,0},;
			{'CODPAR'		,'C', 60 ,0},;	//CODIGO PARTICIPANTE
			{'CCNPJTMPR'	,'C', 14 ,0},;	//CNPJ TOMADOR/PRESTADOR
			{'CTPINSCTOM'	,'C', 01 ,0},;  //CTPINSCTOMADOR
			{'FIL'			,'C', nTamFil ,0},;  //FILIAL USADO PARA NAO CLORAR A OBSERVACAO
			{'PROCID'		,'C', 1 ,0},;   //PROCID
			{'TOTDOC'		,'N', 14,0} }  //TOTAL DOCTOS

aCampNfs:= {{'ID'			,'C', 36 	   ,0},;
			{'ROTINA'		,'C', 03 	   ,0},;
			{'NUMDOCTO'		,'C', 15 	   ,0},;
			{'SERIE'		,'C', __TmSerPfx,0},;
			{'DTEMISSNF'	,'D', 08	   ,0},;
			{'VLRBRUTO'		,'N', 14 	   ,2},;
			{'OBS'			,'C', 250	   ,0},;
			{'TPSERVICO'	,'C', 06 	   ,0},;
			{'CODSERVIC'	,'C', 09 	   ,0},;
			{'C8CDESCRI'	,'C', 220 	   ,0},;
			{'VLRBASERET'	,'N', 14 	   ,2},;	//VLRBASERET
			{'VLRRETENC'	,'N', 14 	   ,2},; 	//VLRRETENCAO
			{'VLRRETSUB'	,'N', 14 	   ,2},; 	//VLRRETSUB
			{'VLRNRETPRI'	,'N', 14 	   ,2},; 	//VLRNRETPRINC
			{'VLRSERV15'	,'N', 14 	   ,2},; 	//VLR15SERVICOS
			{'VLRSERV20'	,'N', 14 	   ,2},; 	//VLR20SERVICOS
			{'VLRSERV25'	,'N', 14 	   ,2},; 	//VLR25SERVICOS
			{'VLRADICC'		,'N', 14 	   ,2},; 	//VLRADICIONALC
			{'VLRNRTADIC'	,'N', 14 	   ,2},; 	//VLRNRETADIC
			{'CHVNF'		,'C', nTamChvNf,0},; 	//CHAVE DA NOTA
			{'IDPART'		,'C', 36 	   ,0},; 	//ID PARTICIPANTE
			{'CPRB'			,'C', 01 	   ,0},; 	//CPRB
			{'CNPJ'			,'C', 14 	   ,0},; 	//CNPJ PARTICIPANTE
			{'RECNO'		,'N', 10 	   ,0},;	//RECNO DA NOTA/ FATURA
			{'ALIQ'			,'N', 08 	   ,4},; 	//Aliquota da nota/ fatura não tem
			{'FIL'			,'C', nTamFil  ,0}}		//FILIAL USADO PARA NAO CLORAR A OBSERVACAO

aCampProc:={{'ID'			,'C', 36 ,0},;
			{'CCHAVE'		,'C', 15 ,0},;
			{'ROTINA'		,'C', 03 ,0},;
			{'CTPPROC'		,'C', 01 ,0},; 	//TPPROCRETPRINC OU TPPROCRETADIC
			{'NUMPRO'		,'C', 06 ,2},; 	//NRPROCRETPRINC OU NRPROCRETADIC
			{'CODSUS'		,'C', 14 ,0},; 	//CODSUSPPRINC OU CODSUSPADIC
			{'VALSUS'		,'N', 14 ,2},; 	//VALORPRINC OU VALORADIC
			{'C1GTPPROC'	,'C', 01 ,0},; 	//TPPROCRETPRINC OU TPPROCRETADIC
			{'C1GNUMPRO'	,'C', TamSx3("C1G_NUMPRO")[1] ,0},;	//NRPROCRETPRINC OU NRPROCRETADIC
			{'C1GID'		,'C', 06 ,0},;
			{'C1GVERSAO'	,'C', 14 ,0},;
			{'C1GFILIAL'	,'C', nTamFil ,0}}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Seta o indice das temporary table

@author Henrique Pereira; Denis Naves
@since 07/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static function PopIdxObj(oTTCabc, oTTNfs, oTTProc, cPeriodo, lApiTHF )
	Default lApiTHF	:= .f.

	oTTCabc:AddIndex("1", {"ID"})
	oTTCabc:AddIndex("2", { "CPERIODO", "CTPINSC", "CNRINDC"})
	oTTCabc:AddIndex("3", { "CPERIODO", "CTPINSC", "CNRINDC", "CCNPJTMPR", "CTPINSCTOM"})
	oTTCabc:AddIndex("4", { "CPERIODO", "CNPJ"})

	oTTNfs:AddIndex("1", {"ID"})
	oTTNfs:AddIndex("2", {"NUMDOCTO", "SERIE", "DTEMISSNF"})
	oTTNfs:AddIndex("3", {"ID", "ROTINA", "NUMDOCTO", "SERIE", "TPSERVICO", "CNPJ" })
	oTTNfs:AddIndex("4", {"CNPJ"})

	if !lApiTHF
		oTTProc:AddIndex("1", {"ID"})
		oTTProc:AddIndex("2", {"CTPPROC", "NUMPRO", "CODSUS"})
		oTTProc:AddIndex("3", {"C1GTPPROC", "CTPPROC","C1GNUMPRO", "CODSUS", "ID"})
		oTTProc:Create()
	endif

	oTTCabc:Create()
	oTTNfs:Create()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} INSERTTMP()
Seta o indice das temporary table
Executa o Insert InTo na tabela temporária com as informações analíticas das movimentações
@author Henrique Pereira; Denis Naves
@since 07/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function INSERTTMP(cTTable, cSelect, aCamp )

	Local cSqlInto	AS Character
	Local nX		AS Numeric
	Local lVirg		As Logical

	Default cSelect		:= ''
	Default aCamp		:= {}

	cSqlInto			:= ''
	nX					:= 0
	lVirg				:= .F.

	cSqlInto 	:= "INSERT INTO " +  cTTable
	cSqlInto 	+= "("

	For nX := 1 To Len(aCamp)
		IIf (lVirg , cSqlInto += "," , lVirg := .T.)
		cSqlInto += aCamp[nX][1]
	Next nX
	cSqlInto += ") "

	cSqlInto += cSelect

	If TCSQLExec (cSqlInto) < 0
		MessageBox(TCSQLError(),"",MB_ICONHAND)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CMPQRY()
Monta a string para execução do Insert To da visão analitica das movimentações 
Esta string será passada para INSERTTMP() executar o Insert To na tabela temporária

@author Henrique Pereira; Denis Naves
@since 07/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function CMPQRY( alStrNFS, alStrFAT )

	Local clQryA	as Character
	Local clQryB	as Character
	Local clQryC	as Character
	Local cBd		as Character

	cBd := TcGetDb()
	clQryA := clQryB := clQryC := ""


	//NOTA
	If cBd $ "ORACLE|POSTGRES|DB2"
		clQryA := " SELECT SUBSTR(C20.C20_DTDOC,1,6) || "

		clQryA += " CASE "
		clQryA += " WHEN T9C.T9C_NRINSC Is NULL "
		clQryA += " THEN '1' || C1H.C1H_CNPJ "
		clQryA += " ElSE T9C.T9C_TPINSC || T9C.T9C_NRINSC "
		clQryA += " END  AS ID  ,

		clQryA += " SUBSTR(C20.C20_NUMDOC,1,15) AS NUMDOCTO, SUBSTR(C20.C20_SERIE,1,5) AS SERIE, "
		clQryA += " SUBSTR(C20.C20_DTDOC,1,6) AS DTEMISSAONF, "

	ElseIf cBd $ "INFORMIX"
		clQryA := " SELECT C20.C20_DTDOC[1,6] + "

		clQryA += " CASE "
		clQryA += " WHEN T9C.T9C_NRINSC = '' OR  T9C.T9C_NRINSC IS NULL "
		clQryA += " THEN '1' + C1H.C1H_CNPJ "
		clQryA += " ElSE T9C.T9C_TPINSC + T9C.T9C_NRINSC "
		clQryA += " END  AS ID  ,

		clQryA += " C20.C20_NUMDOC AS NUMDOCTO, C20.C20_SERIE AS SERIE, "
		clQryA	+= " C20.C20_DTDOC[1,6] = AS DTEMISSAONF, "

	Else
		clQryA := " SELECT SUBSTRING(C20.C20_DTDOC,1,6) +  "

		clQryA += " CASE "
		clQryA += " WHEN T9C.T9C_NRINSC = '' OR  T9C.T9C_NRINSC IS NULL "
		clQryA += " THEN '1' + C1H.C1H_CNPJ "
		clQryA += " ElSE T9C.T9C_TPINSC + T9C.T9C_NRINSC "
		clQryA += " END  AS ID  ,

		clQryA += " C20.C20_NUMDOC AS NUMDOCTO, C20.C20_SERIE AS SERIE, "
		clQryA += " SUBSTRING(C20.C20_DTDOC,1,6) AS DTEMISSAONF, "
	EndIf

	clQryA += " C20.C20_VLDOC AS VLRBRUTO, 'OBSERVACAO' AS OBS, C30.C30_IDTSER AS CODSER, C8C.C8C_CREINF AS CODSERVIC, "
	clQryA += " C35.C35_BASE AS VLRBASERET,	C35.C35_VALOR AS VLRRETENCAO, C35.C35_VLSCON AS VLRRETSUB, C35.C35_VLRNPG AS VLRNRETPRINC, C35.C35_VLCE15 AS VLR15SERVICOS, C35.C35_VLCE20 AS VLR20SERVICOS, "
	clQryA += " C35.C35_VLCE25 AS VLR25SERVICOS, C35.C35_VLRADI AS VLRADICIONAL,C35.C35_VLRANP AS VLRNRETADIC, C20.C20_CHVNF AS CHVNF,  C1H.C1H_ID AS IDPART,C1H.C1H_CPRB AS CPRB, C1H.C1H_CNPJ AS CNPJ, "
	clQryA += " C20.R_E_C_N_O_ AS RECNO "

	//FATURA
	If cBd $ "ORACLE|POSTGRES|DB2"
		clQryC := " SELECT SUBSTR(LEM.LEM_DTEMIS,1,6) || "

		clQryC += " CASE "
		clQryC += " WHEN T9C.T9C_NRINSC is NULL " // OR  T9C.T9C_NRINSC IS NULL " Is Null não funciona para oracle
		clQryC += " THEN '1' || C1H.C1H_CNPJ "
		clQryC += " ElSE T9C.T9C_TPINSC || T9C.T9C_NRINSC "
		clQryC += " END  AS ID , "

		clQryC += " SUBSTR(LEM.LEM_NUMERO,1,15) AS NUMDOCTO, SUBSTR(LEM.LEM_PREFIX,1,5) AS SERIE, "
		clQryC += " SUBSTR(LEM.LEM_DTEMIS,1,6) AS DTEMISSAONF, "

	ElseIf cBd $ "INFORMIX"
		clQryC := " SELECT LEM.LEM_DTEMIS[1,6] + "

		clQryC += " CASE "
		clQryC += " WHEN T9C.T9C_NRINSC = '' OR  T9C.T9C_NRINSC IS NULL "
		clQryC += " THEN '1' + C1H.C1H_CNPJ "
		clQryC += " ElSE T9C.T9C_TPINSC + T9C.T9C_NRINSC "
		clQryC += " END  AS ID , " "

		clQryC += " LEM.LEM_NUMERO AS NUMDOCTO, LEM.LEM_PREFIX AS SERIE, "
		clQryC += " LEM.LEM_DTEMIS[1,6] AS DTEMISSAONF, "
	Else

		clQryC := " SELECT SUBSTRING(LEM.LEM_DTEMIS,1,6) + "

		clQryC += " CASE "
		clQryC += " WHEN T9C.T9C_NRINSC = '' OR  T9C.T9C_NRINSC IS NULL "
		clQryC += " THEN '1' + C1H.C1H_CNPJ "
		clQryC += " ElSE T9C.T9C_TPINSC + T9C.T9C_NRINSC "
		clQryC += " END  AS ID , "

		clQryC += " LEM.LEM_NUMERO AS NUMDOCTO, LEM.LEM_PREFIX AS SERIE, "
		clQryC += " SUBSTRING(LEM.LEM_DTEMIS,1,6) AS DTEMISSAONF, "

	EndIf

	clQryC += " LEM.LEM_VLBRUT AS VLRBRUTO, LEM.LEM_OBSERV AS OBS, "
	clQryC += " T5M.T5M_IDTSER AS CODSER, C8C.C8C_CREINF AS CODSERVIC, T5M.T5M_BSINSS AS VLRBASERET, T5M.T5M_VLINSS AS VLRRETENCAO, T5M.T5M_VLRETS AS VLRRETSUB, T5M.T5M_VLRETP AS VLRNRETPRINC, T5M.T5M_VLSV15 AS VLR15SERVICOS, "
	clQryC += " T5M.T5M_VLSV20 AS VLR20SERVICOS, T5M.T5M_VLSV25 AS VLR25SERVICOS, T5M.T5M_VLADIC AS VLRADICIONAL,  T5M.T5M_VLADNE AS VLRNRETADIC, '0' AS CHVNF, LEM_IDPART AS CODPAR, C1H.C1H_CPRB AS CPRB, C1H.C1H_CNPJ AS CNPJ, "
	clQryC += " LEM.R_E_C_N_O_ AS RECNO "

	clQryB := clQryA + " FROM " + alStrNFS[1]	//C20
	clQryB += " INNER JOIN " + alStrNFS[2] 		//C30
	clQryB += " INNER JOIN "+ alStrNFS[3]		//C35
	clQryB += " INNER JOIN "+ alStrNFS[4]		//C8C
	clQryB += " LEFT JOIN "+  alStrNFS[5]		//T9C
	clQryB += " INNER JOIN "+ alStrNFS[6]		//C1H
	clQryB += " WHERE " + alStrNFS[7]

	clQryB += " UNION ALL "

	clQryB += clQryC + " FROM " + alStrFAT[1]	//LEM
	clQryB += " INNER JOIN " + alStrFAT[2] 		//T5M
	clQryB += " LEFT JOIN " + alStrFAT[3]		//T9C
	clQryB += " INNER JOIN " + alStrFAT[4] 		//C8C
	clQryB += " INNER JOIN " +  alStrFAT[5]		//C1H
	clQryB += " WHERE " + alStrFAT[6]

	clQryB += " ORDER BY 1,3,4,5,6 "

Return clQryB

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author anieli.rodrigues
@since 05/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ExcluiReg(cIdApReinf, cReg, aErro)

	Local cCNPJPrest	As Character
	Local cErro		As Character
	Local cNrInscEst	As Character
	Local cTpInscEst	As Character
	Local lExcluiu	As Logical
	Local oModel 	As Object

	cErro := ""
	cTpInscEst := ""
	lExcluiu := .F.

	If cReg == "R-2010"
		oModel 		:= oModel486 //FWLoadModel("TAFA486")
		cNrInscEst	:= T95->T95_NRINSC
		cTpInscEst	:= T95->T95_TPINSC
		cCNPJPrest	:= T95->T95_CNPJPR
	Else
		oModel 		:= oModel478 //FWLoadModel("TAFA478")
		cNrInscEst	:= CMN->CMN_NRINSC
		cTpInscEst	:= CMN->CMN_TPINSC
		cTpInscTom	:= CMN->CMN_TPINST
		cNrInscTom	:= CMN->CMN_NRINST
	EndIf

	oModel:SetOperation(5)
	oModel:Activate()

	If FwFormCommit(oModel)
		lExcluiu := .T.
	Else
		cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "

		If cReg == "R-2010"
			cErro 	+= "tpInscEstab: " + cTpInscEst + CRLF
			cErro 	+= "nrInscEstab: " + cNrInscEst + CRLF
			cErro  	+= "cnpjPrestador: " + cCNPJPrest + CRLF
		Else
			cErro 	+= "tpInscEstabPrest: " + cTpInscEst + CRLF
			cErro  	+= "nrInscEstabPrest: " + cNrInscEst + CRLF
			cErro  	+= "tpInscTomador: " + cTpInscTom + CRLF
			cErro  	+= "nrInscTomador: " + cNrInscTom + CRLF
		EndIf

		cErro  	+= STR0006 + CRLF
		cErro 	+= TafRetEMsg(oModel)
		Aadd(aErro, {"R-2010", "ERRO", cErro})
		lExcluiu := .F.
	EndIf

	oModel:DeActivate()

Return lExcluiu


//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function TamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

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
/*/{Protheus.doc} MontCabErr

Monta cabeçalho da mensagem de erro a ser impressa no log de apuração do evento

@Param:
cReg	- Apuração que está sendo processada (R-2010/R-2020)
cRegra     - Regra do layout a ser veriricada
aLogErro   - Array com log de erros
aDadosUtil - Array com informacoes(conteudo) adicionais caso necessitem ser comparadas

@Return:

@author anieli.rodrigues
@since 07/05/2018
@version 1.0

/*/

Static Function MontCabErr(cReg, cTpInscEst, cNrInscEst, cCNPJPrest, cTpInscTom, cNrInscTom)

	Local cErro as Character

	cErro 	:= ""

	cErro	:= "Regra de validação não atendida na gravação do registro contendo a chave (Impeditivo para Apuração):" + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	cErro 	+= CRLF

	If cReg == "R-2010"
		cErro 	+= "tpInscEstab: " + cTpInscEst + CRLF
		cErro 	+= "nrInscEstab: " + cNrInscEst + CRLF
		cErro  	+= "cnpjPrestador: " + cCNPJPrest + CRLF
	Else
		cErro 	+= "tpInscEstabPrest: " + cTpInscEst + CRLF
		cErro  	+= "nrInscEstabPrest: " + cNrInscEst + CRLF
		cErro  	+= "tpInscTomador: " + cTpInscTom + CRLF
		cErro  	+= "nrInscTomador: " + cNrInscTom + CRLF
	EndIf

	cErro += CRLF

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} MontNFFErr

Monta informações das notas fiscais consideradas para apuração do registro

@Param:
aNFFat	- Array contendo as notas fiscais/faturas que compõe o registro
cErro	- String de erro na qual as informações serão adicionadas

@Return: 
cErro	- String contendo as informações das notas fiscais/faturas utilizadas na composição do registro

@author anieli.rodrigues
@since 07/05/2018
@version 1.0

/*/

Static Function MontNFFErr(aNFFat)

	Local cErro   As Character
	Local nContNf As Numeric
	Local nLenNF  As Numeric

	cErro 	:= ""
	nContNf := 0
	nLenNF 	:= Len(aNFFat)

	cErro	+= "Notas fiscais/Faturas utilizadas para composição do registro: " + CRLF
	cErro 	+= CRLF

	For nContNf := 1  to nLenNF

		If aNFFat[nContNF][1] == "NFS"
			cErro 	+= "Documento Fiscal Número " + Alltrim(aNFFat[nContNF][2]) + " Série " + Alltrim(aNFFat[nContNF][3]) + CRLF
		Else
			cErro 	+= "Fatura Número " + Alltrim(aNFFat[nContNF][2]) + " Prefixo " + Alltrim(aNFFat[nContNF][3]) + CRLF
		EndIf

	Next nContNF

	cErro 	+= CRLF

Return cErro

//-------------------------------------------------------------------
/*/{Protheus.doc} VldObrigat

Valida informações obrigatórias de cada um dos grupos do XML. 
Valores não são validados, pois apesar de obrigatórios podem estar zerados. 

@Param:
aApuracao	- Registro da apuração posicionado para validação
cGrupo		- Grupo de tags para validação
cTagErro	- String que retorna como referência os campos obrigatórios não preenchidos para o grupo 

@Return: 
lRetorno	- Indica se existem campos obrigatórios que não foram preenchidos

@author anieli.rodrigues
@since 07/05/2018
@version 1.0

/*/

Static Function VldObrigat(aApuracao, cGrupo, cTagErro)

	Local lRetorno as Logical

	lRetorno := .T.

	If cGrupo == "ideTomador"

		//tpInscEstabPrest não validado, pois é preenchido pela própria apuração

		If Empty((aApuracao[SINTETICO])->CNRINDC)
			lRetorno 	:= .F.
			cTagErro 	+= "nrInscEstabPrest" + CRLF
		EndIf

		If Empty((aApuracao[SINTETICO])->CTPINSCTOM)
			lRetorno 	:= .F.
			cTagErro 	+= "tpInscTomador" + CRLF
		EndIf

		If Empty((aApuracao[SINTETICO])->CCNPJTMPR)
			lRetorno 	:= .F.
			cTagErro 	+= "nrInscTomador" + CRLF
		EndIf

		If Empty((aApuracao[SINTETICO])->CINDOBRA)
			lRetorno 	:= .F.
			cTagErro 	+= "indObra" + CRLF
		EndIf

		If !lRetorno
			cTagErro := "Registro "  + cGrupo + CRLF + "Campos Obrigatórios não preenchidos: " + CRLF + CRLF + cTagErro + CRLF
		EndIf

	ElseIf cGrupo == "nfs"

		If Empty(Substr((aApuracao[ANALITICO])->SERIE,1,5))
			lRetorno 	:= .F.
			cTagErro 	+= "serie" + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro += "Verifique o preenchimento do campo C20_SERIE" + CRLF
			Else
				cTagErro += "Verifique o preenchimento do campo LEM_PREFIX" + CRLF
			EndIf
		EndIf

		If Empty(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15))
			lRetorno 	:= .F.
			cTagErro 	+= "numDocto" + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro += "Verifique o preenchimento do campo C20_NUMDOC" + CRLF
			Else
				cTagErro += "Verifique o preenchimento do campo LEM_NUMERO" + CRLF
			EndIf
		EndIf

		If Empty((aApuracao[ANALITICO])->DTEMISSNF)
			lRetorno 	:= .F.
			cTagErro 	+= "dtEmissaoNF" + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro += "Verifique o preenchimento do campo C20_DTDOC" + CRLF
			Else
				cTagErro += "Verifique o preenchimento do campo LEM_DTEMIS" + CRLF
			EndIf
		EndIf

		If !lRetorno
			cTagErro := "Registro " + cGrupo + CRLF + "Campos Obrigatórios não preenchidos: " + CRLF + CRLF + cTagErro
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro += "Documento fiscal Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) + " Série: " + Alltrim(Substr((aApuracao[ANALITICO])->SERIE,1,5)) + CRLF + CRLF
			Else
				cTagErro += "Fatura Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) + "Prefixo: " + Alltrim(Substr((aApuracao[ANALITICO])->SERIE,1,5)) + CRLF + CRLF
			EndIf
		EndIf
	ElseIf cGrupo == "infoTpServ"
		If Empty((aApuracao[ANALITICO])->TPSERVICO)
			lRetorno 	:= .F.
			cTagErro 	+= "tpServico" + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro += "Verifique o preenchimento do campo C30_IDTSER" + CRLF
			Else
				cTagErro += "Verifique o preenchimento do campo LEM_IDTSER" + CRLF
			EndIf
		EndIf

		If !lRetorno
			cTagErro := "Registro " + cGrupo + CRLF + "Campos Obrigatórios não preenchidos: " + CRLF + CRLF + cTagErro
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro += "Documento fiscal Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15))+ " Série: " + Substr((aApuracao[ANALITICO])->SERIE,1,5) + CRLF + CRLF
			Else
				cTagErro += "Fatura Número: " +  Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15) + "Prefixo: " + Substr((aApuracao[ANALITICO])->SERIE,1,5) + CRLF + CRLF
			EndIf
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldTags

Executa validações das tags do grupo indicado

@Param:
aApuracao	- Registro da apuração posicionado para validação
cGrupo		- Grupo de tags para validação
cTagErro	- String que retorna como referência os erros identificados na validação 

@Return: 
lRetorno	- Indica se existem tags não validadas

@author anieli.rodrigues
@since 07/05/2018
@version 1.0

/*/

Static Function VldTags(aApuracao, cGrupo, cTagErro)

	Local aDadosUtil	as Array
	Local cDados 		as Character
	Local cErroRules	as Character
	Local lRetorno 		as Logical

	aDadosUtil	:= {}
	cDados 		:= ""
	cErroRules	:= ""
	lRetorno 	:= .T.

	If cGrupo == "ideTomador"

		//vlrTotalBruto não validado, pois a soma dos valores já é realizada pela própria apuração
		//vlrTotalBaseRet não validado, pois a soma dos valores já é realizada pela própria apuração
		//vlrTotalRetPrinc não validado, pois a soma dos valores já é realizada pela própria apuração
		//vlrTotalRetAdic não validado, pois a soma dos valores já é realizada pela própria apuração

		If (aApuracao[SINTETICO])->VLRTBRET <= 0
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrTotalBaseRet} deve ser maior que 0 (zero)." + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo dos campos C35_BASE (vlrBaseRet)" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo dos campos T5M_BSINSS (vlrBaseRet)" + CRLF + CRLF
			EndIf
		EndIf

		If (aApuracao[SINTETICO])->VLRTNRPRNC > (aApuracao[SINTETICO])->NVLTLRTPC
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrTotalNRetPrinc} não pode ser maior que {vlrTotalRetPrinc}." + CRLF
		EndIf

		If (aApuracao[SINTETICO])->VLRTNRADIC > (aApuracao[SINTETICO])->VLRTRADIC
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrTotalNRetAdic} não pode ser maior que {vlrTotalRetAdic}." + CRLF
		EndIf

		If !lRetorno
			cTagErro := "Registro " + cGrupo + CRLF + cTagErro + CRLF
		EndIf

	ElseIf cGrupo == "nfs"
		If (aApuracao[ANALITICO])->VLRBRUTO <= 0
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrBruto} deve ser maior que 0 (zero)." + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo do campo C20_VLDOC" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo do campo LEM_VLBRUT" + CRLF + CRLF
			EndIf

		EndIf

		If !lRetorno
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cDados += "Documento fiscal Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) + " Série: " + Alltrim(Substr((aApuracao[ANALITICO])->SERIE,1,5)) + CRLF
			Else
				cDados += "Fatura Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) + "Prefixo: " + Alltrim(Substr((aApuracao[ANALITICO])->SERIE,1,5)) + CRLF
			EndIf

			cTagErro := "Registro " + cGrupo + CRLF + cDados + cTagErro
		EndIf
	ElseIf cGrupo == "infoTpServ"
		If (aApuracao[ANALITICO])->VLRRETENC > Round(((aApuracao[ANALITICO])->VLRBASERET / 100) * 11,2)
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrRetencao} não pode ser maior que 11% de {vlrBaseRet}." + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo dos campos C35_VALOR (vlrRetencao) e C35_BASE (vlrBaseRet)" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo dos campos T5M_VLINSS (vlrBaseRet) e T5M_BSINSS (vlrBaseRet)" + CRLF + CRLF
			EndIf

		EndIf

		If (aApuracao[ANALITICO])->VLRRETSUB > (aApuracao[ANALITICO])->VLRRETENC
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrRetSub} não pode ser superior ao {vlrRetencao}." + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo dos campos C35_VLSCON (vlrRetSub) e C35_VALOR (vlrRetencao)" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo dos campos T5M_VLRETS (vlrRetSub) e T5M_VLINSS (vlrBaseRet)" + CRLF + CRLF
			EndIf
		EndIf

		If (aApuracao[ANALITICO])->VLRNRETPRI > (aApuracao[ANALITICO])->VLRRETENC
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrNRetPrinc} não pode ser maior que {vlrRetencao}." + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo dos campos C35_VLRNPG (vlrNRetPrinc) e C35_VALOR (vlrRetencao)" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo dos campos T5M_VLRETP (vlrNRetPrinc) e T5M_VLINSS (vlrRetencao)" + CRLF + CRLF
			EndIf
		EndIf

		If ((aApuracao[ANALITICO])->VLRSERV15 + (aApuracao[ANALITICO])->VLRSERV20 + (aApuracao[ANALITICO])->VLRSERV25) > (aApuracao[ANALITICO])->VLRBASERET
			lRetorno 	:= .F.
			cTagErro 	+= "O somatório dos campos {vlrServicos15}, {vlrServicos20} e {vlrServicos25} não pode ser superior ao {vlrBaseRet} indicado na nota fiscal." + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo dos campos C35_VLCE15 (vlrServicos15), C35_VLCE20 (vlrServicos20), "
				cTagErro 	+= "C35_VLCE25 (vlrServicos25) e C35_BASE (vlrBaseRet)" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo dos campos T5M_VLSV15 (vlrServicos15), T5M_VLSV20 (vlrServicos20), "
				cTagErro 	+= "T5M_VLSV25 (vlrServicos25) e T5M_BSINSS (vlrBaseRet)" + CRLF + CRLF
			EndIf
		EndIf

		If (aApuracao[ANALITICO])->VLRNRTADIC > (aApuracao[ANALITICO])->VLRADICC
			lRetorno 	:= .F.
			cTagErro 	+= "{vlrNRetAdic} não pode ser maior que {vlrAdicional}" + CRLF
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cTagErro 	+= "Verifique o conteúdo dos campos C35_VLRANP (vlrNRetAdic) e C35_VLRADI (vlrAdicional)" + CRLF + CRLF
			Else
				cTagErro 	+= "Verifique o conteúdo dos campos T5M_VLADNE (vlrNRetAdic) e T5M_VLADIC (vlrAdicional)" + CRLF + CRLF
			EndIf
		EndIf

		If !lRetorno
			If (aApuracao[ANALITICO])->ROTINA == "NFS"
				cDados += "Documento fiscal Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) + " Série: " + Alltrim(Substr((aApuracao[ANALITICO])->SERIE,1,5)) + CRLF + CRLF
			Else
				cDados += "Fatura Número: " +  Alltrim(Substr((aApuracao[ANALITICO])->NUMDOCTO,1,15)) + "Prefixo: " + Alltrim(Substr((aApuracao[ANALITICO])->SERIE,1,5)) + CRLF + CRLF
				cDados += " Tipo de Serviço: " + (aApuracao[ANALITICO])->CODSERVIC + CRLF + CRLF
			EndIf
			cTagErro := "Registro " + cGrupo + CRLF + cDados + cTagErro
		EndIf

	ElseIf cGrupo == "infoProc"
		aDadosUtil := {}
		AAdd(aDadosUtil, {(aApuracao[PROCESSOS])->C1GFILIAL, (aApuracao[PROCESSOS])->C1GID, (aApuracao[PROCESSOS])->CODSUS})
		If FindFunction("ReinfRules")
			cErroRules := ReinfRules("T9U", "REGRA_TAF_EXISTE_PROCESSO", , aDadosUtil)
			If !Empty(cErroRules)
				lRetorno := .F.
			EndIf
		EndIf

		If !lRetorno
			cDados := "Processo Número: " +  Alltrim((aApuracao[PROCESSOS])->C1GNUMPRO) + " Suspensão: " + (aApuracao[PROCESSOS])->CODSUS + CRLF
			cTagErro := "Registro " + cGrupo + CRLF + cDados + cTagErro + cErroRules + CRLF + CRLF
		EndIf

	ElseIf cGrupo == "idePrestServ"
		If !CGC((aApuracao[SINTETICO])->CNPJ, , .F.)
			lRetorno 	:= .F.
			cTagErro 	+= "{cnpjPrestador} Deve ser um CNPJ válido." + CRLF
			cTagErro 	+= "Verifique o conteúdo do campo C1H_CNPJ do cadastro do participante " + Alltrim((aApuracao[SINTETICO])->CODPAR) + CRLF
		EndIf

		If !lRetorno
			cTagErro := "Registro " + cGrupo + CRLF + cTagErro + CRLF
		EndIf
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidGrp

Executa validações do grupo indicado

@Param:
aApuracao	- Registro da apuração posicionado para validação
cGrupo		- Grupo de tags para validação
cTagErro	- String que retorna como referência os erros identificados na validação 

@Return: 
lRetorno	- Indica se existem tags não validadas

@author anieli.rodrigues
@since 07/05/2018
@version 1.0

/*/

Static Function ValidGrp(aApuracao, cGrupo, cTagErro, aDadosUtil)

	Local lRetorno 	as Logical

	lRetorno := .T.

	If cGrupo == "infoProcRetPr"
		//aDadosUtil[1][1] - vlrTotalNRetPrinc
		//aDadosUtil[1][2] - valorPrinc
		//aDadosUtil[1][3] - nQtdProc

		If aDadosUtil[1][1]  > 0 .And. aDadosUtil[1][3] == 0
			lRetorno := .F.
			cTagErro += "Se {vlrTotalNRetPrinc} > 0, infoProcRetPr é obrigatório; não obrigatório nas demais situações, exceto se {indSusp}= [92])" + CRLF
		EndIf

		If !(aDadosUtil[1][1] == aDadosUtil[1][2])
			lRetorno := .F.
			cTagErro += "A soma dos valores informados no campo {valorPrinc} deste grupo, com exceção dos valores informados para {indSusp} = [92], deve ser igual a {vlrTotalNRetPrinc}." + CRLF
		EndIf

		If !lRetorno
			cTagErro := "Registro " + cGrupo + CRLF + cTagErro + CRLF
		EndIf

	ElseIf cGrupo == "infoProcRetAd"
		//aDadosUtil[1][1] - vlrTotalNRetAdic
		//aDadosUtil[1][2] - valorAdic
		//aDadosUtil[1][3] - nQtdProc

		If aDadosUtil[1][1]  > 0 .And. aDadosUtil[1][3] == 0
			lRetorno := .F.
			cErro += "Se {vlrTotalNRetAdic}} > 0, infoProcRetAd é obrigatório; não obrigatório nas demais situações, exceto se {indSusp}= [92])" + CRLF
		EndIf

		If !(aDadosUtil[1][1] == aDadosUtil[1][2])
			lRetorno := .F.
			cTagErro += "A soma dos valores informados no campo {valorPrinc} deste grupo, com exceção dos valores informados para {indSusp} = [92], deve ser igual a {vlrTotalNRetPrinc}." + CRLF
		EndIf

		If !lRetorno
			cTagErro := "Registro " + cGrupo + CRLF + cTagErro +  CRLF
		EndIf
	EndIf
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PrepWhere

Prepara o Where da query com os CNOs e CNPJs

@Param:
cCNPJC1H	- String com os CNOSs e CNPJs que vem do frontend

@Return: 
cWhere		-  Where com os filtros necessários

@author Katielly Feitosa
@since 27/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PrepWhere(cCNPJC1H)

	local cCno 		as Character
	local cCnpj 	as Character
	local cWhere 	as Character

	cCNO 	:= ""
	cCnpj	:= ""
	cWhere	:= ""

	PrepIn(cCNPJC1H, @cCNO, @cCnpj)

	if !empty(cCNO)  .and. !empty(cCnpj)
		cWhere	+= " AND ((T9C.T9C_NRINSC IN ("+ cCNO +"))"
		cWhere	+= " OR C1H.C1H_CNPJ IN ("+ cCnpj +")"
		cWhere	+= " AND T9C.T9C_TPINSC IS NULL)"
	else
		if  !empty(cCNO)
			cWhere	+= " AND T9C.T9C_NRINSC IN ("+ cCNO +")"
		endIf

		if !empty(cCnpj)
			cWhere	+= " AND C1H.C1H_CNPJ IN ("+ cCnpj +")"
			cWhere	+= " AND (T9C.T9C_TPINSC IS NULL OR (T9C.T9C_INDOBR = '0') OR (T9C.T9C_INDOBR IN ('1','2') AND T9C.T9C_NRINSC LIKE '%SEM CODIGO%')) "
		endIf
	endIf

return cWhere
//-------------------------------------------------------------------
/*/{Protheus.doc} PrepIn

Prepara uma string com CNO e/ou uma com CNPJ,
para o IN da query

@Param:
cCNPJC1H	- String com os CNOSs e CNPJs que vem do frontend
cCNO		- String com os CNOSs
cCnpj   	- String com os CNPJs 

@author Katielly Feitosa
@since 27/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PrepIn(cCNPJC1H, cCNO, cCnpj)

	local nI as numeric
	local aDoc as array

	nI := 0
	aDoc := {}

	default cCNO  := ""
	default cCnpj := ""

	aDoc :=  StrTokArr( cCNPJC1H, "," )
	For nI := 1 to Len( aDoc )

		aDoc[nI]  :=  Alltrim(StrTran(aDoc[nI] , "'", ""))

		if len(aDoc[nI]) == 14
			cCnpj	+=		"'" + aDoc[nI] + "', "
		else
			cCNO	+=		"'" + aDoc[nI] + "', "
		endif
	next

	if !empty(cCNO)
		cCNO := substr(cCNO,1,len(cCNO)-2)
	endif

	if !empty(cCnpj)
		cCnpj := substr(cCnpj,1,len(cCnpj)-2)
	endif

return
