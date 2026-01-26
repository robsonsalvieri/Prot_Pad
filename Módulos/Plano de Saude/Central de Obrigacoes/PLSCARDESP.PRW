#include 'totvs.ch'
#include 'FWMVCDEF.CH'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQ_LOG_DES		"job_eventodespesa.log"
#DEFINE DESP_SEM_RE		"despesas_sem_resumo.log"
#DEFINE EXP_ARQ_LOG		"job_benef_expostos.log"
#DEFINE DEBUG_EXP		"debug_expostos.log"
#DEFINE EXP_SEM_COB		"benef_exp_sem_cobertura.log"
#DEFINE testes   		"testes.log"
#DEFINE BANCO			Alltrim(Upper(TCGetDb()))
#DEFINE NAT_CODIGO 		1
#DEFINE NAT_DIAS 		2
#DEFINE NAT_DATCAR		3
#DEFINE NAT_IDADE		4
#DEFINE NAT_IDADE2		5
#DEFINE NAT_SEXO		6
#DEFINE NAT_NIVEL		7
#DEFINE NAT_CODSUP		8
#DEFINE TERAPIAS		"'20104243','20104251','20104278','20104286','20104294','20104308','20104430','30909031','30909139','30909147','31303269','31303293','40401014','41203070','41203089','41203097'"//TODO Levar essa configuracao para a terminologia TUSS
#DEFINE MV_PLCENDB		GetNewPar("MV_PLCENDB",.F.)
#DEFINE MV_STATISS		GetNewPar("MV_STATISS",.F.)
#DEFINE nMV_QTANSIP		GetNewPar("MV_QTANSIP",0)//Quantidade de anos para olhar no historico
#DEFINE cMV_DTCOSIP		GetNewPar("MV_DTCOSIP","")//Data de corte para nao olha no historico
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

#DEFINE PROCEDIME	01
#DEFINE ISCONSULT	02
#DEFINE CLASIPSER	03
#DEFINE CLASIPESP	04
#DEFINE CLASIPINT	05
#DEFINE QTDEREAL	06
#DEFINE DATAPROC	07
#DEFINE TIPOPROC	08
#DEFINE VLRDESP		09
#DEFINE TRIMOCOR	10
#DEFINE GRUPOINT	11
#DEFINE REGIMEINT	12
#DEFINE CHVGUIGRV	13
#DEFINE __MATRIC	14
#DEFINE __UF		15
#DEFINE __CID		16
#DEFINE __IDADE		17
#DEFINE __DATINT	18
#DEFINE __HORAINT	19
#DEFINE DATALTA		20
#DEFINE HORAALTA	21
#DEFINE TRIMRECO	22
#DEFINE QTDNASVIV	23
#DEFINE __DENTE		24
#DEFINE CHVGUIINT	25
#DEFINE CHVRESUMO	26
#DEFINE CLASHDESC   27
#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02/13"
#DEFINE G_SOL_INTER "03"
#DEFINE G_REEMBOLSO "04"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"

#DEFINE TP_PROCEDIM "0"
#DEFINE TP_MATERIAL "1"
#DEFINE TP_MEDICAME "2"
#DEFINE TP_TAXAS 	"3"
#DEFINE TP_DIARIAS 	"4"
#DEFINE TP_ORTESE 	"5"
#DEFINE TP_PACOTE 	"6"
#DEFINE TP_GASES 	"7"
#DEFINE TP_ALUGUEIS "8"
#DEFINE TP_OUTROS 	"9"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCARDESP

Funcao criada para carregar os eventos x despesas referente ao SIP para a central de obrigacoes (B3L)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCARDESP()
	Local aSay    	:= {}
	Local aButton 	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importacao de Eventos x Despesas - SIP'
	Local cDesc1	:= 'Esta rotina fará a importação de eventos x despesas referente ao SIP para o '
	Local cDesc2	:= 'núcleo de informações e obrigações.'
	Local cDesc3	:= ""
	Local lOk		:= .T.
	Local cDataRef	:= "" //Data informada pelo usuaio
	Local cTipData	:= "" //1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cTipProc	:= "" //Tipo de processamento 1=Evento x Desp;2=Calc ben exp;3=Ambos
	Local cLocDigIgn:= "" //Tipo de processamento 1=Evento x Desp;2=Calc ben exp;3=Ambos
	Local lGerRepas	:= .F. //Indica se gera T. ou nao .F. para beneficiario de reciprocidade
	Local oObj      := FWSX1Util():New()
	Local aPergunte :={}
	Local lPergNew     := .F.

	oObj:AddGroup("PLSCARDESN")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSCARDESN")

	If len(apergunte) > 1
		lPergNew:=len(apergunte[2]) > 0
	endif

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 1, Iif (!lPergNew,Pergunte('PLSCARDESP',.T.,Titulo,.F.),Pergunte('PLSCARDESN',.T.,Titulo,.F.)) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton, , 200, 450 )

	If MV_PLCENDB
		MsgInfo("Parametro MV_PLCENDB definido como .T. Somente um JOB sera iniciado")
	EndIf

	If nOpc == 2

		If lPergNew .And. Valtype(mv_par01) == "D"
			lPergNew:=.F. //está usando o novo pergunte, mas não atualizou os JOBS no configurador.
		endif

		cDataRef	:= IIF (!lPergNew,DTOS(mv_par01),"")
		cTipData	:= iif (!lPergNew,AllTrim(Str(mv_par02)),AllTrim(Str(mv_par01)))
		cRegANS		:= iif (!lPergNew,mv_par03,mv_par02)
		cTipProc	:= iif (!lPergNew,AllTrim(mv_par04),AllTrim(mv_par03))
		lGerRepas	:= iif (!lPergNew,mv_par05 == 1,IIF(Valtype(mv_par04) == "N",mv_par04 == 1,.F.))
		cLocDigIgn	:= RetLocIgn()

		If !Empty(cDataRef) .Or. !Empty(cTipData) .Or. !Empty(cRegANS) .Or. !Empty(cTipProc)
			Processa( { || lOk := PLSJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn) },'Aguarde','Processando...',.F.)
		Else
			MsgInfo("Para confirmar o processamento informe todos os parâmetros.","TOTVS")
			Pergunte('PLSCARDESP',.T.,Titulo,.F.)
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', CENDTHRL("E") + " PLSJOBSIP NAO FOI INICIADO!" , 0, 0, {})
		EndIf

	EndIf
	FreeObj(oObj)
	oObj := Nil

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se todas perguntas foram respondidas

@return lRet	Verdadeiro (.T.) se todas as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta(lPergNew)
	Local lRet	     := .T.
	Local cMsg	     := ""
	Default lPergNew := .F.

	If Empty(mv_par01)
		lRet := .F.
		IIF (!lPergNew,cMsg += "Qual a data de referencia ?" + CRLF,cMsg += "Considerar a data de ?" + CRLF)
	EndIf

	If Empty(mv_par02)
		lRet := .F.
		IIF (!lPergNew,cMsg += "Considerar a data de ?" + CRLF,cMsg += "Qual a operadora padrao ?" + CRLF)
	EndIf

	If Empty(mv_par03)
		lRet := .F.
		IIF (!lPergNew,cMsg += "Qual a operadora padrao ?" + CRLF,cMsg += "Tipo de processamento ?" + CRLF)
	EndIf

	If Empty(mv_par04)
		lRet := .F.
		cMsg += "Tipo de processamento ?" + CRLF
	EndIf

	If Empty(mv_par05) .And. !lPergNew
		lRet := .F.
		cMsg += "Gerar para benef. de reciprocidade ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSJOBSIP

Funcao criada para disparar os JOBs de importacao de dados para as tabelas do SIP na Central de Obrigacoes
JOB PLSIPDES - job de eventos x despesas (SADT e GHI)
JOB PLSIPACU - job de alto custo
JOB PLSIPREE - job de reembolso
JOB PLSIPEXP - job de beneficiarios expostos
JOB PLSSIPTOT- job de totalizacao

@param cDataRef	Data de referencia para limite da pesquisa
@param cTipData	Tipo de data 1=Digitacao; 2=Pagamento; 3=Procedimento
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProc	Tipo de processamento: 1-Despesa, 2-Alto custo
@param lGerRepas	Indica se ira (.T.) importar registros referentes a beneficiarios de reciprocidade
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn,lPriCom,lAuto)
	Local nFor			:= 0
	Local nTo			:= 3
	Local nQuinzena		:= 1
	Local nThread		:= 0
	Local lContinua		:= .T. //Indica se deve .T. ou nao .F. continuar
	Local lDadosHist	:= !(nMV_QTANSIP == 0)//Indica se .T. vou olhar dados historicos ou nao .F.
	Local lQryInter		:= .F. //Query de SADT BD5 .F. ou internacao BE4 .T.
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cCodComp		:= ""
	Local lMV_PLCENDB	:= MV_PLCENDB
	Local lSipEmp       := GetNewPar("MV_PLSSIPE",.F.)	
	Local nTot          := 1
	Local nSip          := 1
	Local aEmpresas     := {}
	Local nCt           := 1
	Local nQtdReg       := 1
	Local nThead        := 10
	Local cEmInici      := "" 
	Local cEmFinal      := ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cTipData	:= '1'
	Default cRegANS		:= '000000'
	Default cTipProc	:= '1,2,3,4'
	Default lGerRepas	:= .F.
	Default cLocDigIgn	:= ""
	Default lPriCom     := .f.
	Default lAuto       := .F.
	Private oTmpTable   := Nil

	cTriRec := DataTrimestre(cDataRef)
	PlsLogFil("[" + cTrirec + "]PLSJOBSIP:" + CENDTHRL("I") + " Inicio cria??o dos jobs PLSJOBSIP ",ARQ_LOG_DES)
	If lMV_PLCENDB
		nTo := 1
	EndIf

	If lSipEmp
		nQtd:= PlsBG9Tem(cRegANS,"1",,@oTmpTable)          //crio um temporário com as empresas. Também vejo quantos registros fora selecionados.
		nQtdReg:= nQtd / nThead                               // esta será a quatidade processada em cada JOB

		If (nQtdReg % 10) <> 0
			nQtdReg:= Int(nQtdReg) + 1
		EndIf 
	Else
		nThead:= 1
	EndIf 

	//Processamento de SADT+Internacao
	If lContinua .And. '1' $ cTipProc

		For nFor := 1 TO nTo //Um job para cada mes do trimestre
			For nSip:=1 To nThead

				If lSipEmp
					PlsBG9Tem(cRegANS,"2",nQtdReg,@oTmpTable,nSip,@cEmInici,@cEmFinal)
				EndIf 

				nThread := nFor
				nQuinzena := 1
				lQryInter := .F.

				If !lAuto
					PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
					StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,,,cEmInici,cEmFinal)//JOB para guias BD5
					Sleep(2000)
				Else
					PLSIPDES(cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)//para guias BD5

				Endif
				If cTipData == "3" //Procediento
					nQuinzena := 2
				Else //Digitacao,Procedimento
					lQryInter := .T.
				EndIf
				If !lAuto
					PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
					StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,,,cEmInici,cEmFinal)
					Sleep(2000)
				Else
					PLSIPDES(cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter)

				Endif

				If cTipData == "3"
					nQuinzena:=1
					lQryInter:=.T.
					PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
					StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,,,cEmInici,cEmFinal)
					Sleep(2000)

					nQuinzena:=2
					PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
					StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,,,cEmInici,cEmFinal)
					Sleep(2000)

				EndIf

			Next nSip

			If lSipEmp //Limpo o campo OK para ser utilizado novamento no prox nFor nTo
				PlsBG9Tem(cRegANS,"4",nQtdReg,@oTmpTable)
			EndIf 

		Next nFor

		If lSipEmp
			PlsBG9Tem(cRegANS,"4",nQtdReg,@oTmpTable)
		EndIf 

		If lDadosHist
			If !lPriCom
				lDadosHist:=.F.
			Endif
		Endif

		If lDadosHist
			lQryInter := .F.
			nQuinzena := 1
			nThread := 1
			For nSip:=1 To nThead

				If lSipEmp
					PlsBG9Tem(cRegANS,"2",nQtdReg,@oTmpTable,nSip,@cEmInici,@cEmFinal)
				EndIf 

				PlsLogFil("[" + cTrirec + "]TRBDES " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,lDadosHist,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,,,cEmInici,cEmFinal)
				Sleep(2000)
			Next
		EndIf
		
	EndIf

	If lSipEmp //Limpo o campo OK para ser utilizado novamento no prox nFor nTo
		PlsBG9Tem(cRegANS,"4",nQtdReg,@oTmpTable)
	EndIf 

	//Processamento de Guias de captation
	If lContinua .And. '1' $ cTipProc .And. cTipData $ "2/4" .And. !lAuto

		For nFor := 1 TO nTo //Um job para cada mes do trimestre
			For nSip:=1 To nThead
				If lSipEmp
					PlsBG9Tem(cRegANS,"2",nQtdReg,@oTmpTable,nSip,@cEmInici,@cEmFinal)
				EndIf 
				nThread := nFor
				nQuinzena := 1
				lQryInter := .F.

				PlsLogFil("[" + cTrirec + "]TRBCAP " + NomeJob(lQryInter,.F.) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F.,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,.T.,"TRBCAP",cEmInici,cEmFinal)
				Sleep(2000)

				lQryInter := .T.

				PlsLogFil("[" + cTrirec + "]TRBCAP " + NomeJob(lQryInter,.F./*lDadosHist*/) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(1)) + "):"+CENDTHRL("I")+" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPDES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,.F./*lDadosHist*/,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,,.T.,"TRBCAP",cEmInici,cEmFinal)
				Sleep(2000)
			Next
		Next nFor

	EndIf

	If lSipEmp //Limpo o campo OK para ser utilizado novamento no prox nFor nTo
		PlsBG9Tem(cRegANS,"4",nQtdReg,@oTmpTable)
	EndIf 

	//Processamento de de alto custo
	If lContinua .And. '2' $ cTipProc
		For nSip:=1 To nThead
			If lSipEmp
				PlsBG9Tem(cRegANS,"2",nQtdReg,@oTmpTable,nSip,@cEmInici,@cEmFinal)
			EndIf 
			StartJob("PLSIPACU",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,cEmInici,cEmFinal)
			Sleep(2000)
		Next
	EndIf

	If lSipEmp //Limpo o campo OK para ser utilizado novamento no prox nFor nTo
		PlsBG9Tem(cRegANS,"4",nQtdReg,@oTmpTable)
	EndIf 

	//Processamento de reembolso
	If lContinua .And. '3' $  cTipProc

		If cTipData $ "1,3"//Digitacao,Procedimento

			For nFor := 1 TO nTo //Um job para cada mes do trimestre
				For nSip:=1 To nThead
					If lSipEmp
						PlsBG9Tem(cRegANS,"2",nQtdReg,@oTmpTable,nSip,@cEmInici,@cEmFinal)
					EndIf 
					PlsLogFil("[" + cTrirec + "] PLSIPREE " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nFor)) + AllTrim(Str(1)) + "):"+ CENDTHRL("I") +" StartJob",ARQ_LOG_DES)
					StartJob("PLSIPREE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,cEmInici,cEmFinal)
					Sleep(2000)
				Next

			Next nFor

		ElseIf cTipData $ "2/4"//Pagamento ou Data do Pagamento
			For nSip:=1 To nThead
				If lSipEmp
					PlsBG9Tem(cRegANS,"2",nQtdReg,@oTmpTable,nSip,@cEmInici,@cEmFinal)
				EndIf 
				PlsLogFil("[" + cTrirec + "] PLSIPREE " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(0)) + AllTrim(Str(1)) + "):"+ CENDTHRL("I") +" StartJob",ARQ_LOG_DES)
				StartJob("PLSIPREE",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,cEmInici,cEmFinal)
				Sleep(2000)
			Next
		EndIf

	EndIf

	If lSipEmp
		PlsBG9Tem(cRegANS,"3",nQtdReg,@oTmpTable)
	EndIf 

	//Processamento de beneficiarios expostos
	If lContinua .And. '4' $ cTipProc

		cTriRec := DataTrimestre(cDataRef)

		If LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,"",@cCodComp,cRegANS)

			PlsAtuMonitor("Limpeza de expostos")
			PlsLogFil("[" + cTrirec + "] PLSIPEXP"+CENDTHRL("I")+" Limpeza - Inicio",ARQ_LOG_DES)
			LimpaExpostos(cRegANS,cCodObri,cAnoComp,cCodComp)
			PlsLogFil("[" + cTrirec + "] PLSIPEXP"+CENDTHRL("I")+" Limpeza - Termino",ARQ_LOG_DES)

		EndIf

		aBenef := ListaBenef(cDataRef)
		nLen := IIf(lMV_PLCENDB,1, Len(aBenef))
		For nFor := 1 TO nLen//Um Job para cada range de recnos BA1
			PlsLogFil("[" + cTrirec + "] PLSIPEXP (" + AllTrim(Str(nFor)) + "):"+CENDTHRL("I")+" StartJob - Inicio",ARQ_LOG_DES)
			StartJob("PLSIPEXP",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cDataRef,cTipData,cRegANS,lGerRepas,aBenef[nFor],nFor,cLocDigIgn)
			PlsLogFil("[" + cTrirec + "] PLSIPEXP (" + AllTrim(Str(nFor)) + "):"+CENDTHRL("I")+" StartJob - Termino",ARQ_LOG_DES)
			Sleep(2000)
		Next nFor

	EndIf

	//Job de finalizacao - migra os dados de despesas  da B3Q para B3L totalizando os itens
	If lContinua .And. '5' $  cTipProc

		cTriRec := DataTrimestre(cDataRef)

		If LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,"",@cCodComp,cRegANS)
			CENDELTOT(cRegANS,cCodObri,cAnoComp,cCodComp)
		EndIf
		If !lAuto
			StartJob("PLSSIPTOT",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cRegANS,cDataRef,.F.)
		Else
			PLSSIPTOT(cEmpAnt,cFilAnt,cRegANS,cDataRef,.F.)
		Endif

	EndIf

	PlsLogFil("[" + cTrirec + "]PLSJOBSIP:"+ CENDTHRL("I") + " Jobs criados PLSJOBSIP",ARQ_LOG_DES)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENDELTOT

Funcao criada para deletar os totais antigos

@author everton.mateus
@since 10/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function CENDELTOT(cCodOpe,cCodObri,cAnoComp,cCodComp,cItem,cTrioco,cUF)
	Local cSql := ""
	Local nRet := 0
	Local cTrim := cAnoComp + SubStr(cCodComp,2,2)
	Default cItem		:= ""
	Default cTrioco	:= ""
	Default cUF	:= ""

	PlsLogFil("["+cTrim+"]CENDELTOT" + CENDTHRL("I") + "Inicio",ARQ_LOG_DES)
	PlsAtuMonitor("Limpando despesas " + cAnoComp +"-"+ cCodComp)

	cSql := " DELETE FROM " + RetSqlName('B3L')
	cSql += " WHERE "
	cSql += "	B3L_FILIAL = '" + xFilial('B3L') + "' "
	cSql += "	AND B3L_CODOPE = '" + cCodOpe + "' "
	cSql += "	AND B3L_CODOBR = '" + cCodObri + "' "
	cSql += "	AND B3L_ANOCMP = '" + cAnoComp + "' "
	cSql += "	AND B3L_CDCOMP = '" + cCodComp + "' "
	cSql += "	AND B3L_EVEDES = B3L_MATRIC "
	If !Empty(cItem)
		cSql += "	AND B3L_CLAINT = '" + cItem + "' "
		cSql += "	AND B3L_TRIOCO = '" + cTrioco + "' "
		cSql += "	AND B3L_UF = '" + cUF + "' "
	EndIf
	PlsLogFil("["+cTrim+"]CENDELTOT" + CENDTHRL("I") + " Limpa totalizadores: " + cSql,ARQ_LOG_DES)

	nRet := TCSQLEXEC(cSql)
	If nRet >= 0
		If SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
			nRet := TCSQLEXEC("COMMIT")
		EndIf
	Else
		PlsLogFil("["+cTrim+"]CENDELTOT"+ CENDTHRL("E") + " - " + TCSQLError(),ARQ_LOG_DES)
	Endif

	PlsLogFil("["+cTrim+"]CENDELTOT" + CENDTHRL("I") + " Termino",ARQ_LOG_DES)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPDES

Funcao criada para carregar eventos x despesas na tabela temporaria do SIP - B3Q

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
@param nThread		Numero da thread
@param nQuinzena	Indica se 1 - primeira ou 2 - segunda quinzena do mes a ser processada
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPDES(cEmp,cFil,lDadosHist,cDataRef,cTipData,cRegANS,lGerRepas,nThread,nQuinzena,cLocDigIgn,lQryInter,lJob,lCapit,cAlias,cEmInici,cEmFinal)
	Local lRetorno		:= .T.
	Local lPacote		:= .F.
	Local lProSemCla	:= .F.//.T. - procedimento tem classificacao; .F. - procedimento NAO tem classificacao
	Local lIncDesp		:= .F.
	Local cChaveGuia	:= ""
	Local cChaveProd	:= ""
	Local cMatric		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cGuiInt		:= ""
	Local cChvRes		:= ""
	Local cClaHDesc     := ""
	Local cChvGuiGrv	:= ""
	Local nRecnoBD7		:= 0
	Local nQtdRegPro	:= 0 //Quantidade de registros processados
	Local nQtdRegLid	:= 0 //Quantidade de registros lidos
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local aProSemCla	:= {}
	Local aClasEspe		:= {}
	Local aProduto		:= {}
	Local aForSeg		:= {}
	Local nPulaRepa		:= 0
	Local nPulaProd		:= 0
	Local nPulaEstor	:= 0
	Local nPulaSolic	:= 0
	Local nSemClass		:= 0
	Local nPacote		:= 0
	Local nRegSel		:= 0
	Local nQtdPacote	:= 0 //Quantidade de registros procesados pelo pacote
	Local nIdade		:= 0 //Idade do beneficiario
	Local nTerminal		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cMotivo 		:= ""
	Local cCabLog		:= ""
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.
	Local lVincIntVld	:= .F.
	Local cSerBr8       := ""
	Local aAreaBR8      := {}
	Local lDtPag        := .F.
	Local cClasPr       := ""
	Local lBscB19       := .F.
	Local nTotRat		:= 0
	Private lB3Q_EVDRES	:= .F.//B3Q->(FieldPos("B3Q_EVDRES")) > 0
	Private lB3L_EVDRES	:= .F.//B3L->(FieldPos("B3L_EVDRES")) > 0
	Private lB3Q_CLASSH := .F.//B3Q->(fieldpos("B3Q_CLASSH")) > 0
	Default lDadosHist	:= .F.
	Default nThread		:= 0
	Default nQuinzena	:= 1
	Default cLocDigIgn	:= ""
	Default lQryInter	:= .F.
	Default lJob	    := .T.
	Default cAlias	 	:= 'TRBDES'
	Default lCapit      := .F.
	Default cEmInici    := ""
	Default cEmFinal    := ""

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	PlsAtuMonitor(cAlias+" " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + ")")

	lB3Q_EVDRES	:= B3Q->(FieldPos("B3Q_EVDRES")) > 0
	lB3L_EVDRES	:= B3L->(FieldPos("B3L_EVDRES")) > 0
	lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0
	If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
		PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
		lRetorno := .F.
	EndIf

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	If lRetorno .And. Empty(cLocDigIgn)
		cLocDigIgn := RetLocIgn()
	EndIf

	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,nQuinzena,"PLSIPDES") } )
	BEGIN SEQUENCE

		Inicializa()

		lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},nQuinzena,.T.,cLocDigIgn,lQryInter,"",lDadosHist,cEmInici,cEmFinal)
		nRegSel := (cAlias)->Total
		CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		(cAlias)->(dbCloseArea())

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},nQuinzena,.F.,cLocDigIgn,lQryInter,cChvGuiGrv,lDadosHist,cEmInici,cEmFinal)
			If lRetorno

				//busca a quantidade de registros para ratear o valor do contrato capitation
				If lCapit
					CarregaDados("TRB2CAP",cDataRef,cTipData,cRegANS,nThread,{},nQuinzena,.T.,cLocDigIgn,lQryInter,cChvGuiGrv,lDadosHist,cEmInici,cEmFinal)
					nTotRat := TRB2CAP->Total
					TRB2CAP->(dbCloseArea())
				EndIf

				aClasEspe := IniciaEspecialidade()
				aProduto := IniciaProduto()
				lBscB19:= PLSBSCB19(cChaveGuia,.T.)
				While !(cAlias)->(Eof())
					cClasPr    := ""
					cTxt 	   := ""
					cMotivo    := ""
					lProSemCla := .T.
					lIncDesp   := .F.
					nQtdRegLid++
					nTerminal++
					LimpaArray(@aClasEven)
					nRecnoBD7	:= (cAlias)->RECNOBD7
					cChaveGuia	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
					lPacote		:= (cAlias)->BR8_TPPROC == TP_PACOTE
					lPacote     :=.F.
					cSexo       := (cAlias)->BA1_SEXO

					If lQryInter
						cGuiInt := AllTrim((cAlias)->BE4_GUIINT)
					Else
						cGuiInt := AllTrim((cAlias)->BD5_GUIINT)

					EndIf

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						PlsAtuMonitor("PLSSIPDES " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "): " + AllTrim(Str(nQtdRegPro)) + " processados de " + AllTrim(Str(nQtdRegLid)) + " lidos. Total de Selecionados " + AllTrim(Str(nRegSel)) )
						PlsLogFil(cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nQtdRegPro)) + " processados de " + AllTrim(Str(nQtdRegLid)) + " lidos. Total de Selecionados " + AllTrim(Str(nRegSel)) ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nQtdRegLid)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					/*		ALGUNS DESCARTES JA FACO AQUI		*/

					If !lGerRepas .And. PulaRepasse(cAlias,@cChaveGuia)//Despreza usuario de grupo empresa de reciprocidade
						nPulaRepa++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Usuario pertence a contrato de reciprocidade"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias) //Vou pegar o produto na familia ou beneficiario

					If PulaProduto(cAlias,cChaveProd,aProduto,cChaveGuia)//Despreza produto nao informado a ANS
						nPulaProd++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					If lBscB19 .And. PLSBSCB19(cChaveGuia)      //retiro guias que tem nota.
						(cAlias)->(DbSkip())
						Loop
					EndIf

					If  (cAlias)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON + "," + G_RES_INTER .And. PulaEstorno(cAlias,@cChaveGuia)//Despreza guias de consulta e servico estornadas
						nPulaEstor++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Guia estornada"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					If (cAlias)->BD7_TIPGUI == G_SOL_INTER
						nPulaSolic++
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + "Guia de solicitacao de internacao"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						ProximaGuia(cAlias,cChaveGuia)
						Loop

					EndIf

					iF cTipData == "4"
						lDtPag := .T.
					EndIf

					lVincIntVld := (cAlias)->BD7_TIPGUI $ G_SADT_ODON + ',' + G_HONORARIO + ',' + G_RES_INTER .AND. !Empty(cGuiInt) .AND. RetDadInt(cGuiInt,cChaveGuia,(cAlias)->BD7_TIPGUI,,,lMV_STATISS,lDtPag,(cAlias)->BD7_NUMLOT)[1]

					nIdade := Calc_Idade(STOD(Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )),STOD((cAlias)->BA1_DATNAS))

					If !lVincIntVld .And. Empty(cGuiInt) .And. ((cAlias)->BD7_TIPGUI == G_CONSULTA .OR. ((cAlias)->BD7_TIPGUI $ G_SADT_ODON)) .And. !((cAlias)->BR8_TPPROC $ TP_MATERIAL+","+TP_MEDICAME+","+TP_TAXAS)
						cClasPr:= PLSVERCON(AllTrim((cAlias)->BD7_CODPRO),AllTrim((cAlias)->BD7_TIPGUI),nIdade,IIF(!EMPTY((cAlias)->BD7_CODESP),(cAlias)->(BD7_CODOPE+BD7_CODESP),(cAlias)->(BD6_CODOPE+BD6_CODESP)),(cAlias)->BD7_DATPRO,cSexo)
					EndIf

					/*		VOU CHAMAR AS CLASSIFICACOES		*/
					//Para procedimentos sem classificacao como mat/med por exemplo eu somo o valor e atribuo ao evento principal
					If Empty(cClasPr) .And. !lPacote .And. Empty((cAlias)->BR8_TPCONS) .And. Empty((cAlias)->BR8_CLASIP) .And. Empty((cAlias)->BR8_CLASP2);
							.AND. ( (cAlias)->BD7_TIPGUI $ G_SADT_ODON .And. !( (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS ) );
							.AND. ( Empty(cGuiInt) .OR. lVincIntVld )

						cCodPro := AllTrim((cAlias)->BD7_CODPAD) + AllTrim((cAlias)->BD7_CODPRO)
						lConsulta := PlsIsCon((cAlias)->BD7_CODPAD,(cAlias)->BD7_CODPRO)
						cDataProc := Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
						cTipoProc := (cAlias)->BR8_TPPROC
						nVlrDesp := Iif(lCapit, (cAlias)->BD7_VLRPAG / nTotRat, (cAlias)->BD7_VLRPAG)
						cTrimOcor := DataTrimestre(cDataProc,"3")
						cChvGuiGrv := (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
						cMatric := (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
						cUF     := BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE),(cAlias)->(BD7_CODOPE+BD7_CODLOC+BD7_LOCAL))
						nIdade := Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))
						dDatInt := CTOD("")
						dDatAlta := CTOD("")
						cHoraAlta := ""
						cTrimReco := DataTrimestre(DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit),"3")
						nQtdNasViv := 0
						cDente := ""
						cGuiInt := ""
						cClaHDesc := ""
						lIncDesp := .T.

						aClasEven := {/*1*/cCodPro,/*2*/lConsulta,/*3 cClaSIPSer*/"",/*4 cClaSIPEsp*/"",/*5 cClaSIPInt*/"",/*6 nQtdeReal*/0,/*7*/cDataProc,/*8*/cTipoProc,/*9*/nVlrDesp,/*10*/cTrimOcor,;
							/*11 cGrupoInt*/"",/*12 cRegimeInt*/"",/*13*/cChvGuiGrv,/*14*/cMatric,/*15*/cUF,/*16 cCID*/"",/*17*/nIdade,/*18*/dDatInt,/*19 cHoraInt*/"",/*20*/dDatAlta,;
							/*21*/cHoraAlta,/*22*/cTrimReco,/*23*/nQtdNasViv,/*24*/cDente,/*25*/cGuiInt,/*26*/cChvRes,/*27*/cClaHDesc}

						aAdd(aProSemCla,{cRegANS,cCodObri,cAnoComp,cCodComp,cChvGuiGrv,cMatric,Iif(lCapit, (cAlias)->BD7_VLRPAG / nTotRat, (cAlias)->BD7_VLRPAG),aClone(aClasEven)})
						(cAlias)->(dbSkip())
						nSemClass++
						lProSemCla	:= .F.
						lIncDesp	:= .F.

					ElseIf lPacote .And. !lMV_STATISS//Pacote

						cChvGuiGrv := (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)
						nQtdPacote := TrataPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,{}/*aBenef*/,nQuinzena,.F./*lCount*/,cLocDigIgn,lQryInter,cChvGuiGrv,lMV_STATISS)//TODO VALIDAR ANTES DE LIBERAR
						nQtdRegPro += nQtdPacote//Isso pode fazer com que os processados sejam mais do que os lidos
						nPacote++
						lIncDesp	:= .F.

					ElseIf (cAlias)->BD7_TIPGUI == G_CONSULTA .OR.; //guias de consulta
						((cAlias)->BD7_TIPGUI $ G_SADT_ODON .And. Empty(cGuiInt)) //guias de sadt sem vinculo com internacao

						lIncDesp := .T.
						aClasEven := ClassSADT(cAlias,cChaveGuia,cTipData,.f.,@nIdade,@aClasEspe,cDataRef,lMV_STATISS,lCapit,cClasPr,nTotRat)

					ElseIf lVincIntVld .And. ((cAlias)->BD7_TIPGUI $ G_SADT_ODON .OR.;//guias de sadt com vinculo com internacao
						(cAlias)->BD7_TIPGUI == G_RES_INTER .OR.; //guias de resumo de internacao
						(cAlias)->BD7_TIPGUI == G_HONORARIO ) //guias de honorario individual

						lIncDesp := .T.
						aClasEven := ClassInternacao(cAlias,cChaveGuia,cTipData,.f.,@nIdade,@aClasEspe,cDataRef,lMV_STATISS,lCapit,nTotRat)

					Else
						cTxt := ""
						cMotivo := ""
						If !Empty(cGuiInt)
							cMotivo := "Chave de solicitacao de internacao nao encontrada"
						Else
							cMotivo := "Chave de solicitacao de internacao nao informada"
							cGuiInt := "nao informada"
						EndIf
						cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";" + cGuiInt + ";" + cMotivo
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						ProximaGuia(cAlias,cChaveGuia)
						lIncDesp := .F.
						Loop

					EndIf

					/*		GRAVACAO DO EVENTO X DESPESA		*/
					If lIncDesp

						cSerBr8:= ""
						BR8->(DbSetOrder(1))
						aAreaBR8   := BR8->(GetArea())

						If BR8->(msSeek(xFilial("BR8")+AllTrim(aClasEven[PROCEDIME])))
							cSerBr8:= Alltrim(BR8->BR8_CLASIP)
						EndIf

						/*		IMPLEMENTACAO DE EXCECOES		*/
						If (AllTrim(aClasEven[PROCEDIME]) $ '/40601137/40601323/' .Or. AllTrim(SubStr(aClasEven[PROCEDIME],3)) $ '/40601137/40601323/') .Or.  "C3" $ cSerBr8
							If ( nIdade >= 25 .And. nIdade <= 59 )
								aClasEven[CLASIPSER] := 'C3'
								aClasEven[CLASIPESP] := 'C3'
								aClasEven[CLASIPINT] := IIF(lVincIntVld,aClasEven[CLASIPINT],'C3')
							Else
								aClasEven[CLASIPSER] := 'C'
								aClasEven[CLASIPESP] := 'C'
								aClasEven[CLASIPINT] := IIF(lVincIntVld,aClasEven[CLASIPINT],'C')
							EndIf
						Endif

						If AllTrim(SubStr(aClasEven[PROCEDIME],3)) $ '40808033,40808041,40808173'  .Or.  "C10" $ cSerBr8
							If  nIdade >= 50 .And. nIdade <= 69 .And. AllTrim(cSexo) == "2"
								aClasEven[CLASIPSER] := 'C101'
								aClasEven[CLASIPESP] := 'C101'
								aClasEven[CLASIPINT] := IIF(lVincIntVld,aClasEven[CLASIPINT],'C101')
							Else
								aClasEven[CLASIPSER] := 'C10'
								aClasEven[CLASIPESP] := 'C10'
								aClasEven[CLASIPINT] := IIF(lVincIntVld,aClasEven[CLASIPINT],'C10')
							EndIf
						EndIf

						If AllTrim(aClasEven[PROCEDIME]) $ '40303136,40303250' .Or. AllTrim(SubStr(aClasEven[PROCEDIME],3)) $ '40303136,40303250' .Or. "C14" $ cSerBr8
							If ( nIdade >= 50 .And. nIdade <= 69 )
								aClasEven[CLASIPSER] := 'C14'
								aClasEven[CLASIPESP] := 'C14'
								aClasEven[CLASIPINT] := IIF(lVincIntVld,aClasEven[CLASIPINT],'C14')
							else
								aClasEven[CLASIPSER] := 'C'
								aClasEven[CLASIPESP] := 'C'
								aClasEven[CLASIPINT] := IIF(lVincIntVld,aClasEven[CLASIPINT],'C')
							endIf
						EndIf

						RestArea(aAreaBR8)

						If TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven,@aForSeg,lProSemCla,lCapit,,.T.)

							nQtdRegPro++

						Endif

					EndIf

					/*		EVENTO PRINCIPAL RECEBE DEMAIS VALORES		*/
					If SubStr(cChaveGuia,1,Len(cChaveGuia)-3) <> (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)//Se mudei de guia

						If Len(aProSemCla) > 0 //Tenho eventos da guia sem classificacao

							AtuPrinc(aProSemCla,@nQtdRegPro,cCabLog,lCapit)//Atribuo os valores sem classificacao ao evento principal

						EndIf

					EndIf

					/*		PROXIMO EVENTO X DESPESA		*/
					If nRecnoBD7 == (cAlias)->RECNOBD7
						(cAlias)->(dbSkip())

					EndIf

				EndDo //!(cAlias)->(Eof())

			EndIf //CarregaDados()
		EndIf
		//Caso o ultimo registro tenha sido um evento sem classificacao
		If Len(aProSemCla) > 0

			AtuPrinc(aProSemCla,@nQtdRegPro,cCabLog)

		EndIf

		LimpaArray(@aProSemCla)

		/*cStr :=  CRLF + "Pulou " + Alltrim(Str(nPulaRepa)) + " reciprocidade " + CRLF + ;
			"Pulou " + Alltrim(Str(nPulaProd)) + " produtos " + CRLF +;
			"Pulou " +  Alltrim(Str(nPulaEstor)) + " estornos " + CRLF +;
			"Pulou " +  Alltrim(Str(nPulaSolic)) + " solicitações " + CRLF +;
			"Total de Itens sem classificação " +  Alltrim(Str(nSemClass)) + " " + CRLF +;
			"Total de Processados " +  Alltrim(Str(nQtdRegPro)) + " " + CRLF +;
			"Total de Lidos " +  Alltrim(Str(nQtdRegLid)) + " " + CRLF +;
			"Total de Selecionados " +  Alltrim(Str(nRegSel)) + " " + CRLF +;
				"Total de Pacotes " +  Alltrim(Str(nPacote)) + " " + CRLF*/

		//PlsLogFil(cCabLog + CENDTHRL("I") + " Resultado " + cStr,ARQ_LOG_DES)

	END SEQUENCE
	ErrorBlock(bBlock)

	If lRetorno .And. Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	PlsLogFil(cCabLog + CENDTHRL("I") + " Termino " ,ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno
//--------------------------------------------------------------------------------------------------
		/*/{Protheus.doc} PLSIPACU

		Funcao criada para carregar despesa de alto custo na tabela temporaria do SIP - B3Q

		@param cEmp			Empresa do sistema
		@param cFil			Filial do sistema
		@param cDataRef	Data de referencia
		@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
		@param cRegANS		Numero de registro da operadora na ANS
		@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
		@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

		@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

		@author timoteo.bega
		@since 26/01/2016
		/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPACU(cEmp,cFil,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,cEmInici,cEmFinal)
	Local lRetorno		:= .T.
	Local cChaveGuia	:= ""
	Local cChaveProd	:= ""
	Local cMatric		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= 'TRBACU'
	Local nRecnoBD7		:= 0
	Local nTerminal		:= 0
	Local nIncluidos	:= 0
	Local nRegSel		:= 0
	Local nThread		:= 0
	Local nQuinzena		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cCabLog		:= ""
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local aClasEspe		:= {}
	Local aProduto		:= {}
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.
	Local cClasPr       := ""
	Local cSexo         := ""
	Local nIdade        := 0
	Default cEmInici    := ""
	Default cEmFinal    := ""
	Private lB3Q_EVDRES	:= .F.
	Private lB3L_EVDRES	:= .F.
	Private lB3Q_CLASSH := .f. //B3Q->(fieldpos("B3Q_CLASSH")) > 0


	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')
	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob() + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	PlsAtuMonitor("PLSIPACU: importando alto custo" )

	lB3Q_EVDRES	:= B3Q->(FieldPos("B3Q_EVDRES")) > 0
	lB3L_EVDRES	:= B3L->(FieldPos("B3L_EVDRES")) > 0
	lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0

	If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
		PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
		lRetorno := .F.
	EndIf

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	If Empty(cLocDigIgn)
		cLocDigIgn := RetLocIgn()
	EndIf

	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,nQuinzena,"PLSIPACU") } )
	BEGIN SEQUENCE

		aClasEspe := IniciaEspecialidade()
		aProduto := IniciaProduto()

		lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,0,{},1,.T.,cLocDigIgn,,,,cEmInici,cEmFinal)
		nRegSel := (cAlias)->Total
		CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		(cAlias)->(dbCloseArea())

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,0,{},1,.F.,cLocDigIgn,,,,cEmInici,cEmFinal)
			If lRetorno

				While !(cAlias)->(Eof())

					nRecnoBD7	:= (cAlias)->RECNOBD7
					cChaveGuia	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
					cSexo       := (cAlias)->(BA1_SEXO)

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						cTxt := cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nIncluidos)) + " registros incluídos. Total de Selecionados " + AllTrim(Str(nRegSel))
						PlsAtuMonitor(cTxt)
						PlsLogFil( cTxt ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nTerminal)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					/*		ALGUNS DESCARTES JA FACO AQUI		*/
					If !lGerRepas .And. PulaRepasse(cAlias,@cChaveGuia)//Despreza usuario de grupo empresa de reciprocidade

						cTxt := "Alto Custo;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Usuario pertence a contrato de reciprocidade"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias) //Vou pegar o produto na familia ou beneficiario

					If PulaProduto(cAlias,cChaveProd,@aProduto,cChaveGuia)//Despreza produto nao informado a ANS

						cTxt := "Alto Custo;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					If PulaEstorno(cAlias,@cChaveGuia)//Despreza guias de consulta e servico estornadas

						cTxt := "Alto Custo;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Guia estornada"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					/*		VOU CHAMAR AS CLASSIFICACOES		*/

					If (cAlias)->BD7_TIPGUI == G_SOL_INTER

						ProximaGuia(cAlias,cChaveGuia)
						Loop

					ElseIf (cAlias)->BD7_TIPGUI $ G_RES_INTER + ',' + G_HONORARIO .OR. !Empty((cAlias)->BD5_GUIINT)

						aClasEven := ClassInternacao(cAlias,cChaveGuia,cTipData,.f.,/*@nIdade*/,@aClasEspe,cDataRef,lMV_STATISS)

					ElseIf (cAlias)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON
						nIdade := Calc_Idade(STOD(Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )),STOD((cAlias)->BA1_DATNAS))
						cClasPr:= PLSVERCON(AllTrim((cAlias)->BD7_CODPRO),AllTrim((cAlias)->BD7_TIPGUI),nIdade,IIF(!EMPTY((cAlias)->BD7_CODESP),(cAlias)->(BD7_CODOPE+BD7_CODESP),(cAlias)->(BD6_CODOPE+BD6_CODESP)),(cAlias)->BD7_DATPRO,cSexo)
						aClasEven := ClassSADT(cAlias,cChaveGuia,cTipData,.f.,/*@nIdade*/,@aClasEspe,cDataRef,lMV_STATISS,.F.,cClasPr)

					Else

						ProximaGuia(cAlias,cChaveGuia)
						Loop

					EndIf

					/*		GRAVACAO DO EVENTO X DESPESA		*/
					If LocalizaCompromisso(aClasEven[TRIMOCOR],@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS) .And.;
							!ExisteDespesa(cRegANS,cCodObri,cAnoComp,cCodComp,cChaveGuia,cMatric,cAlias,"",aClasEven,,,,"",aClasEven[__UF])

						If TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven,,,,.f.)
							nIncluidos++
						EndIf

					EndIf

					/*		PROXIMO EVENTO X DESPESA ALTO CUSTO		*/
					If nRecnoBD7 == (cAlias)->RECNOBD7

						(cAlias)->(dbSkip())

					EndIf
					nTerminal++

				EndDo //!(cAlias)->(Eof())

			EndIf //CarregaDados()
		EndIf

	END SEQUENCE
	ErrorBlock(bBlock)

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	PlsLogFil(cCabLog + CENDTHRL("I") +" Termino ",ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPREE

Funcao criada para carregar reembolsos na tabela temporaria do SIP - B3Q

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPREE(cEmp,cFil,cDataRef,cTipData,cRegANS,lGerRepas,cLocDigIgn,cEmInici,cEmFinal)
	Local lRetorno		:= .T.
	Local cChaveGuia	:= ""
	Local cChaveProd	:= ""
	Local cMatric		:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= 'TRBREE'
	Local nRecnoBD7		:= 0
	Local nTerminal		:= 0
	Local nIncluidos	:= 0
	Local nQuinzena		:= 0
	Local nRegSel		:= 0
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cCabLog		:= ""
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local aClasEspe		:= {}
	Local aProduto		:= {}
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.
	Local cClasPr       := ""
	Local cSexo         := ""
	Local nIdade        := 0
	Default cEmInici    := ""
	Default cEmFinal    := ""
	Default nThread		:= 1
	Private lB3Q_EVDRES	:= .f.//B3Q->(FieldPos("B3Q_EVDRES")) > 0
	Private lB3L_EVDRES	:= .f.//B3L->(FieldPos("B3L_EVDRES")) > 0
	Private lB3Q_CLASSH := .f. //B3Q->(fieldpos("B3Q_CLASSH")) > 0

	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,'PLS')
	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias,.F.)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob() + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"

	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	aClasEspe := IniciaEspecialidade()
	aProduto := IniciaProduto()

	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	PlsAtuMonitor("PLSIPREE [" + AllTrim(Str(nThread)) + "] importando reembolso" )

	If Empty(cLocDigIgn)
		cLocDigIgn := RetLocIgn()
	EndIf

	lB3Q_EVDRES	:= B3Q->(FieldPos("B3Q_EVDRES")) > 0
	lB3L_EVDRES	:= B3L->(FieldPos("B3L_EVDRES")) > 0
	lB3Q_CLASSH := B3Q->(fieldpos("B3Q_CLASSH")) > 0
	If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
		PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
		lRetorno := .F.
	EndIf

	cDatExe := DTOS(dDataBase)
	cHorExe	:= Time()
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,nQuinzena,"PLSIPREE") } )
	BEGIN SEQUENCE

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},0,.T.,cLocDigIgn,.F.,,,cEmInici,cEmFinal)
			nRegSel := (cAlias)->Total
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
			(cAlias)->(dbCloseArea())
		EndIf

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,{},0,.F.,cLocDigIgn,.F.,,,cEmInici,cEmFinal)
			If lRetorno

				While !(cAlias)->(Eof())

					nRecnoBD7	:= (cAlias)->RECNOBD7
					cChaveGuia	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
					cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
					nTerminal++
					/*		ALGUNS DESCARTES JA FACO AQUI		*/

					If !lGerRepas .And. PulaRepasse(cAlias,@cChaveGuia)//Despreza usuario de grupo empresa de reciprocidade

						cTxt := "Reembolso;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Usuario pertence a contrato de reciprocidade"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias) //Vou pegar o produto na familia ou beneficiario

					If PulaProduto(cAlias,cChaveProd,aProduto,cChaveGuia)//Despreza produto nao informado a ANS

						cTxt := "Reembolso;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						Loop

					EndIf

					/*		VOU CHAMAR A CLASSIFICACAO		*/

					If (cAlias)->BD7_TIPGUI == G_REEMBOLSO
						nIdade := Calc_Idade(STOD(Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )),STOD((cAlias)->BA1_DATNAS))
						cClasPr:= PLSVERCON(AllTrim((cAlias)->BD7_CODPRO),AllTrim((cAlias)->BD7_TIPGUI),nIdade,IIF(!EMPTY((cAlias)->BD7_CODESP),(cAlias)->(BD7_CODOPE+BD7_CODESP),(cAlias)->(BD6_CODOPE+BD6_CODESP)),(cAlias)->BD7_DATPRO,cSexo)
						aClasEven := ClassSADT(cAlias,cChaveGuia,cTipData,.f.,/*@nIdade*/,/*@aClasEspe*/,cDataRef,lMV_STATISS,.F.,cClasPr)

					Else

						cTxt := "Reembolso;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Tentativa de processar despesa que nao e reembolso"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						ProximaGuia(cAlias,cChaveGuia)
						Loop

					EndIf

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						cTxt := cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nIncluidos)) + " registros incluídos. Total de Selecionados " + AllTrim(Str(nRegSel))
						PlsAtuMonitor(cTxt)
						PlsLogFil( cTxt ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nTerminal)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					/*		GRAVACAO DO REEMBOLSO		*/
					If TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven)
						nIncluidos++
					EndIf

					/*		PROXIMO REEMBOLSO		*/
					If nRecnoBD7 == (cAlias)->RECNOBD7
						(cAlias)->(dbSkip())
					EndIf

				EndDo //!(cAlias)->(Eof())

			EndIf //CarregaDados()

		EndIf //lRetorno

	END SEQUENCE
	ErrorBlock(bBlock)

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	PlsLogFil( cCabLog + CENDTHRL("I") + " Termino ",ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIPEXP

Funcao criada para carregar beneficiarios expostos na tabela temporaria do SIP - B3Q

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param lGerRepass	Indica se gera .T. ou nao .F. grupo empresa de reciprocidade
@param aBenef		Informacoes do beneficiario
@param nThread		Numero da thread
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Retorna Verdadeiro (.T.) para processamento ok e (.F.) para problema

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIPEXP(cEmp,cFil,cDataRef,cTipData,cRegANS,lGerRepas,aBenef,nThread,cLocDigIgn,lJob)
	Local lRetorno		:= .T.
	Local lAtenOdon		:= .F.
	Local lPodeBR8		:= .F.
	Local cSexo			:= ""
	Local cCodSeg		:= ""
	Local cAlias		:= "TRBEXP"
	Local cChaveProd	:= ""
	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cDatCar		:= ""
	Local cForCon		:= ""
	Local cDataBlo		:= ""
	Local cMatBen		:= ""
	Local cNomJob		:= ""
	Local cDesJob		:= ""
	Local cObs			:= ""
	Local cDatExe		:= ""
	Local cHorExe		:= ""
	Local cCabLog		:= ""
	Local aNatSaude		:= {}
	Local aNatSaBkp		:= {}
	Local nIdade		:= 0
	Local nTerminal		:= 0
	Local nIncluidos	:= 0
	Local nQuinzena		:= 0
	Local lMV_PLCENDB	:= .F.
	Local lMV_STATISS	:= .F.

	Private aBAN		:= {}
	Private aBDL		:= {}
	Default nThread		:= 0
	Default aBenef		:= {}
	Default lJob		:= .T.

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	cNomJob := CENNOMJOB(nThread,nQuinzena,cAlias)[1]
	cDesJob := CENNOMJOB(nThread,nQuinzena,cAlias)[2]
	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob() + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio ",ARQ_LOG_DES)

	PlsAtuMonitor("PLSIPEXP(" + AllTrim(Str(nThread)) + ") beneficiarios expostos" )
	lMV_PLCENDB	:= MV_PLCENDB
	lMV_STATISS	:= MV_STATISS
	bBlock := ErrorBlock( { |e| ChecErro(e,nThread,0,"PLSIPEXP") } )
	BEGIN SEQUENCE

		If !LocalizaCompromisso(cTriRec,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)
			PlsLogFil(cCabLog + CENDTHRL("W") + " nao foi possivel localizar o compromisso",ARQ_LOG_DES)
			lRetorno := .F.
		EndIf

		cDatExe := DTOS(dDataBase)
		cHorExe	:= Time()
		CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_AGUARD,,lMV_PLCENDB)

		aNatSaude := PegaNatSaude()//carrego as naturezas de saude no formato {Codigo,0, / / ,Idade Ini,Idade Fin,Sexo,Nivel}
		If Len(aNatSaude) == 0
			PlsLogFil(cCabLog + CENDTHRL("W") + " Nao foram encontradas as naturezas de saúde na tabela BF0",ARQ_LOG_DES)
		EndIf
		aNatSaBkp := aClone(aNatSaude)

		Inicializa()

		If lRetorno .And. CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,0,.T.)
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,0,.T.)
			nRegSel := (cAlias)->Total
			PlsLogFil(cCabLog + CENDTHRL("I") + " Total de registros encontrados: " + AllTrim(Str((cAlias)->Total)),ARQ_LOG_DES)
			(cAlias)->(dbCloseArea())
			CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
		EndIf

		If lRetorno
			lRetorno := CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef)
			If lRetorno

				aBAN := BANInicia()
				aBDL := BDLInicia()

				While !(cAlias)->(Eof())//Beneficiarios

					nTerminal++
					cMatBen := (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)

					If !lGerRepas .And. (cAlias)->BG9_REPASS == '1'
						(cAlias)->(dbSkip())
						Loop
					EndIf

					If (cAlias)->BA1_DATINC > cDataRef//Ignora beneficiario incluidos apos o periodo

						cTxt := "Expostos;" + cMatBen + ";;; Beneficiario desconsiderado por inclusao depois de " + cDataRef
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						(cAlias)->(dbSkip())
						Loop

					EndIf

					If  BenefBloqueio(cAlias,cDataRef,@cDataBlo)//Ignora beneficiario bloqueados no periodo

						cTxt := "Expostos;" + cMatBen + ";;; Beneficiario bloqueado em " + cDataBlo
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						(cAlias)->(dbSkip())
						Loop

					EndIf

					cChaveProd := PegaProduto(cAlias,@lPodeBR8,@cCodSeg,@lAtenOdon,@cForCon)//Vou pegar o produto na familia ou beneficiario, segmentacao, forma de contratacao e se atende odonto

					If PulaProduto(cAlias,cChaveProd)//Despreza produto nao informado a ANS

						cTxt := "Expostos;" + cMatBen + ";;; Produto/Plano nao deve ser informado a ANS"
						CenWrLogJb(cTriRec,cTxt,,cNomJob)
						(cAlias)->(dbSkip())
						Loop

					EndIf

					aNatSaude := {}
					aNatSaude := aClone(aNatSaBkp)
					dDatNas := STOD((cAlias)->BA1_DATNAS)
					nIdade	:= Calc_Idade(dDataBase,dDatNas)
					cSexo	:= (cAlias)->BA1_SEXO
					cDatCar	:= (cAlias)->BA1_DATCAR

					PlCenCarCob(cAlias,(cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),(cAlias)->(BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB),cChaveProd,cDatCar,;
						@nIncluidos,lAtenOdon,aNatSaude,lPodeBR8,(cAlias)->BA1_CODINT,cDataRef,cRegANS,cCodObri,cAnoComp,cCodComp,.T.,cSexo,dDatNas,cCodSeg,cForCon,STOD(cDataBlo))

					(cAlias)->(dbSkip())

					If nTerminal % 2000 == 0 .Or. nTerminal == 1
						cTxt := cCabLog + CENDTHRL("I") + " " + AllTrim(Str(nIncluidos)) + " registros incluídos. Total de Selecionados " + AllTrim(Str(nRegSel))
						PlsAtuMonitor(cTxt)
						PlsLogFil( cTxt ,ARQ_LOG_DES)
						cObs := AllTrim(Str(nTerminal)) + " registros processados de " + AllTrim(Str(nRegSel)) + " lidos"
						CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_PROCES,,lMV_PLCENDB)
					EndIf

					cDataBlo := ""
				EndDo //!(cAlias)->(Eof()) - Beneficiarios

			EndIf //CarregaDados()
		EndIf
	END SEQUENCE
	ErrorBlock(bBlock)

	PlsLogFil(cCabLog + CENDTHRL("I") + " Termino ",ARQ_LOG_DES)
	cObs := cNomJob + " concluído!"
	CENMANTB3V(cRegANS,cCodObri,cAnoComp,cCodComp,cTrirec,"1",cNomJob,cDesJob,cObs,cDatExe,cHorExe,JOB_CONCLU,,lMV_PLCENDB)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro as variáveis __cError e __cCallStk sao private e precisam ser criadas
na rotina que ira ter o controle SEQUENCE que chama esta funcao

@param e			Referencia ao erro
@param nThread	Numero da thread em execucao

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ChecErro(e,nThread,nQuinzena,cDesc)
	Local cMsg			:= CENDTHRL("E")
	Default nThread 	:= 0
	Default nQuinzena	:= 0
	Default cDesc		:= ""

	PlsLogFil(e:Description + chr(13) + e:ErrorStack,ARQ_LOG_DES)

	If !Empty(cDesc)
		cMsg += cDesc
	EndIf

	If nThread > 0 .Or. nQuinzena > 0

		cMsg += " ("

		If nThread > 0
			cMsg += AllTrim(Str(nThread))
		EndIf

		If nQuinzena > 0
			cMsg += AllTrim(Str(nQuinzena))
		EndIf

		cMsg += ") " + Chr(13)

	EndIf

	If !Empty(e:Description)
		cMsg += "Descrição" + e:Description + Chr(13)
	EndIf

	cMsg += "Callstack: " + e:ErrorStack

	PlsLogFil(cMsg,ARQ_LOG_DES)

	BREAK

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClassSADT

Funcao criada para classificar os eventos de guias de consulta e SADT

@param cAlias		Area de trabalho corrente
@param cChaveGuia	Chave da guia no PLS
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param lPacote		Indica com Verdadeiro (.T.) se estiver classificando pacote

@return aRetorno	Matriz com as informacoes para o SIP do evento classificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ClassSADT(cAlias,cChaveGuia,cTipData,lPacote,nIdade,aClasEspe,cDataRef,lMV_STATISS,lCapit,cClasPr,nTotRat)
	Local lConsulta		:= .F.
	Local lPacInter		:= .F.
	Local cCodEspMed	:= ""
	Local cCodProc		:= ""
	Local cClaSIPSer	:= ""
	Local cClaSIPEsp	:= ""
	Local cClaSIPInt	:= ""
	Local cClaHDesc     := ""
	Local cTrimOcor		:= ""
	Local cTipoProc		:= ""
	Local cTrimReco		:= ""
	Local cDataProc		:= ""
	//Deixar gravar NC para UF gera a crítica: Em uma mesma forma de contratação e segmentação, quando existir um quadro nacional, ele deve ser único, não podendo existir outros
	//quadros para mesma segmentação, contratação e data de ocorrência
	Local cUF			:= "ZZ"
	Local cCID			:= ""
	Local cHoraInt		:= ""
	Local cHoraAlta		:= ""
	Local cGrupoInt		:= ""
	Local cRegimeInt	:= ""
	Local cChvGuiGrv	:= ""
	Local cGuiInt		:= ""
	Local cChvRes		:= ""
	Local cDente		:= ""
	Local cPadInt		:= ""
	Local dDatInt		:= STOD("")
	Local dDatAlta		:= STOD("")
	Local dDatPro		:= Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
	Local cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
	Local nVlrDesp		:= 0
	Local nQtdeReal		:= 0
	Local nQtdNasViv	:= 0
	Local aRetorno		:= {}
	Local aPacInter		:= {}
	Default aClasEspe	:= {}
	Default cAlias		:= 'TRBDES'
	Default cChaveGuia	:= ""
	Default cTipData	:= '1'
	Default lPacote		:= .F.
	Default nIdade		:= 0
	Default cDataRef	:= dDatPro
	Default lMV_STATISS	:= MV_STATISS
	Default lCapit      := .F.
	Default cClasPr     := ""
	Default nTotRat		:= 0

	lPacote:=.F.

	If cAlias == "TRBPCT" .And. lPacote
		cCodProc	:= AllTrim((cAlias)->(BLE_CPADOC+BLE_CODOPC))
		lConsulta	:= (cAlias)->BD7_TIPGUI == G_CONSULTA .Or. PlsIsCon((cAlias)->BLE_CPADOC,(cAlias)->BLE_CODOPC)
	Else
		cCodProc	:= AllTrim((cAlias)->(BD7_CODPAD+BD7_CODPRO))
		lConsulta	:= (cAlias)->BD7_TIPGUI == G_CONSULTA .Or. PlsIsCon((cAlias)->BD7_CODPAD,(cAlias)->BD7_CODPRO)
	EndIf

	cClaSIPSer	:= IIF(!Empty(cClasPr),cClasPr,(cAlias)->BR8_CLASIP)
	
	//Tratamento de procedimentos relacionados
	If (!Empty((cAlias)->(BD6_PROREL)) .And. (cAlias)->(BR8_TPPROC) == TP_PROCEDIM) .Or. lPacote

		If BR8->(msSeek(xFilial("BR8")+Iif(lPacote,(cAlias)->(BD7_CODPRO+BD7_CODPAD),(cAlias)->(BD6_PROREL)))) .And. !Empty(BR8->BR8_CLASIP)
			cClaSIPSer := BR8->BR8_CLASIP
		EndIf

	EndIf
	If !Empty((cAlias)->(BD7_CODESP))
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD7_CODESP)
	Else
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD6_CODESP)
	EndIf

	If lConsulta .And. (cAlias)->BR8_TPCONS == '1' //1=Ambulatorial; 2= Pronto Socorro
		cClaSIPEsp := ClassificaEspecialidade(cCodEspMed,@aClasEspe)
	EndIf

	If lPacote
		cClaSIPInt	:= BR8->BR8_CLASP2
	Else
		cClaSIPInt	:= (cAlias)->BR8_CLASP2
	EndIf

	if alltrim(cClaSIPSer) $ "hH" .or. alltrim(cClaSIPInt) $ "hH" .or. alltrim(cClaSIPEsp) $ "hH"
		cClaHDesc := "Este procedimento teve a classificação H, devido a parametrização em seu sistema de gestão."
	endif

	If nMV_QTANSIP > 0 .Or. (cAlias)->BD7_TIPGUI == G_REEMBOLSO .Or. lCapit .Or. (cTipData $ '2/4' .And. Empty((cAlias)->BD7_NUMLOT))
		cTrimReco := DataTrimestre(cDataRef)
	Else
		cTrimReco	:= DataTrimestre(DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit),"3")//O trimestre de reconhecimento refere-se ao trimestre dentro do qual a operadora reconheceu a prestação de serviços 1-digitacao, 2-procedimento e 3-pagamento
	EndIf

	cTrimOcor	:= DataTrimestre(dDatPro,"3")//O trimestre de ocorrência refere-se ao trimestre dentro do qual ocorreu a prestação dos serviços
	cDataProc   := dDatPro
	cTipoProc 	:= Iif(!lPacote,(cAlias)->BR8_TPPROC,BR8->BR8_TPPROC)
	nQtdeReal	:= (cAlias)->BD6_QTDPRO
	cUF         := BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE),(cAlias)->(BD7_CODOPE+BD7_CODLOC+BD7_LOCAL))
	cCID		:= (cAlias)->BD6_CID
	cChvGuiGrv	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)

	If lConsulta
		cGuiInt	:= ""
	Else
		cGuiInt := (cAlias)->BD5_GUIINT
		If !Empty(cGuiInt)
			aDadInt := RetDadInt( cGuiInt,cChvGuiGrv,(cAlias)->BD7_TIPGUI,cTipData,cTrimReco,lMV_STATISS)

			If aDadInt[1]

				lPacInter	:= .T.
				cGuiInt		:= aDadInt[2]//Chave da solicitação de internação - BE4_SOLINT = BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
				cGrupoInt	:= aDadInt[3]//Grupo de Internação
				cRegimeInt	:= aDadInt[4]//Regime de Internação
				cHoraInt	:= aDadInt[5]//Hora de Internação
				cHoraAlta	:= aDadInt[6]//Hora de Alta
				dDatInt		:= aDadInt[7]//Data de Internação
				dDatAlta	:= aDadInt[8]//Data de Alta
				nQtdNasViv	:= aDadInt[9]+aDadInt[10]//Nascido Vivo+Nascido Prematuro
				cPadInt		:= aDadInt[12]//Tipo de acomodação
				cChvRes		:= aDadInt[13]//Chave do resumo de internacao

				If !Empty(dDatInt)
					cTrimOcor := DataTrimestre(dDatInt,"3")
				EndIf

			Else

				lPacInter	:= .F.
				cGuiInt		:= ""
				cGrupoInt	:= ""
				cRegimeInt	:= ""
				cHoraInt	:= ""
				cHoraAlta	:= ""
				dDatInt		:= STOD("")
				dDatAlta	:= STOD("")
				nQtdNasViv	:= 0
				cPadInt		:= ""
				cChvRes		:= ""
				cClaSIPInt	:= "H"
				cClaSIPSer	:= "H"
				cClaSIPEsp	:= "H"
				cClaHDesc   := "Guia de SADT sem os dados da guia de internação vinculada." //TODO

			EndIf
		EndIf

	EndIf

	LimpaArray(@aPacInter)

	If !lPacInter .OR. !Empty(cGuiInt) .OR. (cAlias)->BD7_TIPGUI == G_REEMBOLSO
		//Item B - excessao - Procedimentos de vasectomia (item E) realizados em ambulatorio em paciente nao internado devem ser classificados em B - Outros atendimentos ambulatoriais
		If Alltrim((cAlias)->BD7_CODPRO) $ '31205046/31205070'
			cClaSIPSer := 'B'
			cClaSIPEsp := 'B'
			cClaSIPInt := 'B'
		EndIf
	EndIf

	If AllTrim(cClaSIPSer) $ "I33,I4,I5,I6,I7,I8,I9" .Or. AllTrim(cClaSIPInt) $ "I33,I4,I5,I6,I7,I8,I9"
		cDente	:=  BuscaDente((cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV))
	EndIf

	//Para procedimentos de consulta a classificacao vem da especialidade medica
	If lConsulta .And. !Empty(cClaSIPEsp)
		cClaSIPSer := cClaSIPEsp
	EndIf

	//Se um exame do item C foi feito dentro de uma terapia ele deve ser considerado no item D - Terapia
	//1-Material, 2-Medicamento, 3-Taxa e 9-Outros tambem acompanham a terapia
	If (SubStr(cClaSIPSer,1,1)=="C".Or.(Empty(cClaSIPSer) .And. (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS)) .And. ExisteTerapia(cChaveGuia,cAlias,lMV_STATISS)
		If (cAlias)->BD7_TIPGUI <> G_REEMBOLSO
			nQtdeReal := 0
		EndIf
		cClaSIPSer := "D"
	EndIf

	//Materiais, Medicamentos, Taxas e Outros serao classificados como outros atendimentos ambulatoriais
	If Empty(cClaSIPSer) .And. (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS
		cClaExm := ExisteExame(cChaveGuia,lMV_STATISS)
		If !Empty(cClaExm)
			cClaSIPSer := cClaExm
			nQtdeReal := 0
		EndIf
	EndIf

	nIdade := Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))

	If (cAlias)->BD7_TIPGUI == G_REEMBOLSO
		IF EMPTY(cClaSIPSer) .OR. EMPTY(cClaSIPInt)
			IF lPacInter
				cClaSIPSer := 'H'
				cClaSIPEsp := 'H'
				cClaSIPInt := 'H'
				cClaHDesc := "Guia de reembolso" //TODO
			ENDIF
		ENDIF
	ENDIF

	If Alltrim(cClaSIPSer) == "" .And. !Empty(cClasPr)
		cClaSIPSer:= cClasPr
	EndIf

	While !(cAlias)->(Eof()) .And. (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) ==  cChaveGuia

		nVlrDesp += Iif(lCapit, (cAlias)->BD7_VLRPAG / nTotRat, (cAlias)->BD7_VLRPAG)

		(cAlias)->(dbSkip())
	EndDo

	//Só vou contar frequência de guias que fiz algum pagamento
	If nVlrDesp == 0 .And. !lCapit
		nQtdeReal := 0
	EndIf

	aRetorno := {/*1*/cCodProc,/*2*/lConsulta,/*3*/cClaSIPSer,/*4*/cClaSIPEsp,/*5*/cClaSIPInt,/*6*/nQtdeReal,/*7*/cDataProc,/*8*/cTipoProc,/*9*/nVlrDesp,/*10*/cTrimOcor,;
		/*11*/cGrupoInt,/*12*/cRegimeInt,/*13*/cChvGuiGrv,/*14*/cMatric,/*15*/cUF,/*16*/cCID,/*17*/nIdade,/*18*/dDatInt,/*19*/cHoraInt,/*20*/dDatAlta,;
		/*21*/cHoraAlta,/*22*/cTrimReco,/*23*/nQtdNasViv,/*24*/cDente,/*25*/cGuiInt,/*26*/cChvRes,/*27*/cClaHDesc}

Return aRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ClassInternacao

Funcao criada para classificar os eventos de guias de internacao

@param cAlias		Area de trabalho corrente
@param cChaveGuia	Chave da guia no PLS
@param cTipData		1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param lPacote		Indica com Verdadeiro (.T.) se estiver classificando pacote

@return aRetorno	Matriz com as informacoes para o SIP do evento classificado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ClassInternacao(cAlias,cChaveGuia,cTipData,lPacote,nIdade,aClasEspe,cDataRef,lMV_STATISS,lCapit,nTotRat)
	Local lConsulta		:= .F.
	Local cCodEspMed	:= ""
	Local cCodProc		:= ""
	Local cClaSIPSer	:= ""
	Local cClaSIPEsp	:= ""
	Local cClaSIPInt	:= ""
	Local cClaHDesc     := ""
	Local cDataProc		:= ""
	Local cTipoProc		:= ""
	Local cTrimReco		:= ""
	Local cTrimOcor		:= ""
	Local cGrupoInt		:= ""
	Local cRegimeInt	:= ""
	Local cMatric		:= (cAlias)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO)
	Local cUF			:= "ZZ"
	Local cCID			:= ""
	Local cChvGuiGrv	:= ""
	Local cDente		:= ""
	Local nVlrDesp		:= 0
	Local nQtdeReal		:= 0
	Local nQtdNasViv	:= 0
	Local cHoraInt		:= ""
	Local cHoraAlta		:= ""
	Local cGuiInt		:= ""
	Local cChvRes		:= ""
	Local cPadInt		:= ""
	Local dDatInt		:= STOD("")
	Local dDatAlta		:= STOD("")
	Local dDatPro		:= Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
	Local aRetorno		:= {}
	Local aClaIteE		:= {}
	Local lPacInter		:= .F.
	Default aClasEspe	:= {}
	Default cAlias		:= 'TRBDES'
	Default cChaveGuia	:= ""
	Default cTipData	:= '1'
	Default lPacote		:= .F.
	Default nIdade		:= 0
	Default cDataRef	:= dDatPro
	Default lMV_STATISS	:= MV_STATISS
	Default lCapit      := .f.
	Default nTotRat		:= 0

	IniciaE1(@aClaIteE)

	lPacote:=.F.

	If cAlias == "TRBPCT" .And. lPacote
		cCodProc	:= AllTrim((cAlias)->(BLE_CPADOC+BLE_CODOPC))
	Else
		cCodProc	:= AllTrim((cAlias)->(BD7_CODPAD+BD7_CODPRO))
	EndIf

	If !lPacote
		cClaSIPSer	:= Iif(!Empty((cAlias)->BR8_CLASP2),(cAlias)->BR8_CLASP2,(cAlias)->BR8_CLASIP)
	Else
		cClaSIPSer	:= IIf(!Empty(BR8->BR8_CLASP2),BR8->BR8_CLASP2,BR8->BR8_CLASIP)
	EndIf
	//Tratamento de procedimentos relacionados
	If (!Empty((cAlias)->(BD6_PROREL)) .And. (cAlias)->(BR8_TPPROC) == TP_PROCEDIM) .Or. lPacote

		If BR8->(msSeek(xFilial("BR8")+Iif( lPacote, (cAlias)->(BD7_CODPRO+BD7_CODPAD) , (cAlias)->(BD6_PROREL) )))
			cClaSIPSer := IIf(!Empty(BR8->BR8_CLASP2),BR8->BR8_CLASP2,BR8->BR8_CLASIP)
		EndIf

	EndIf
	If !Empty((cAlias)->(BD7_CODESP))
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD7_CODESP)
	Else
		cCodEspMed	:= (cAlias)->(BD6_CODOPE+BD6_CODESP)
	EndIf

	If (cAlias)->BR8_TPCONS == '1'
		cClaSIPEsp := ClassificaEspecialidade(cCodEspMed,@aClasEspe)
	EndIf

	If !lPacote
		cClaSIPInt	:= (cAlias)->BR8_CLASP2
	Else
		cClaSIPInt	:= BR8->BR8_CLASP2
	EndIf

	if alltrim(cClaSIPSer) $ "hH" .or. alltrim(cClaSIPInt) $ "hH" .or. alltrim(cClaSIPEsp) $ "hH"
		cClaHDesc := "Este procedimento teve a classificação H, devido a parametrização em seu sistema de gestão."
	endif

	If nMV_QTANSIP > 0 .Or. lCapit
		cTrimReco := DataTrimestre(cDataRef)
	Else
		cTrimReco	:= DataTrimestre(DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit),"3")//O trimestre de reconhecimento refere-se ao trimestre dentro do qual a operadora reconheceu a prestação de serviços 1-digitacao, 2-procedimento e 3-pagamento
	EndIf
	cTrimOcor	:= DataTrimestre(dDatPro,"3")//O trimestre de ocorrÃªncia refere-se ao trimestre dentro do qual ocorreu a prestaÃ§Ã£o dos serviÃ§os
	cDataProc	:= dDatPro
	cTipoProc 	:= (cAlias)->(BR8_TPPROC)
	nQtdeReal	:= (cAlias)->BD6_QTDPRO
	cUF         := BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE))
	cCID		:= PegaCIDInt((cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SITUAC+BD7_FASE))
	cChvGuiGrv	:= (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV)

	//Se for guia de resumo
	If (cAlias)->BD7_TIPGUI == G_RES_INTER
		cGuiInt := (cAlias)->BE4_GUIINT
	Else
		cGuiInt := (cAlias)->BD5_GUIINT
	EndIf

	If (cAlias)->BD7_TIPGUI == "06"
		cUF:= BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE),(cAlias)->(BD7_CODOPE+BD7_CODLOC+BD7_LOCAL),cGuiInt,Alltrim((cAlias)->(BD7_TIPGUI)))
	Else
		cUF:= BscPrfExe((cAlias)->(BD7_REGPRE),(cAlias)->(BD7_CDPFPR),(cAlias)->(BD7_CODRDA),(cAlias)->(BD7_ESTPRE),(cAlias)->(BD7_CODOPE+BD7_CODLOC+BD7_LOCAL))
	EndIf

	If !Empty(cGuiInt)

		aDadInt := RetDadInt(cGuiInt,cChvGuiGrv,(cAlias)->BD7_TIPGUI,cTipData,cTrimReco,lMV_STATISS,,(cAlias)->BD7_NUMLOT)

		If aDadInt[1]

			lPacInter	:= .T.
			cGuiInt		:= aDadInt[2]//Chave da solicitação de internação - BE4_GUIINT
			cGrupoInt	:= aDadInt[3]//Grupo de Internação
			cRegimeInt	:= aDadInt[4]//Regime de Internação
			cHoraInt	:= aDadInt[5]//Hora de Internação
			cHoraAlta	:= aDadInt[6]//Hora de Alta
			dDatInt		:= STOD(aDadInt[7])//Data de Internação
			dDatAlta	:= STOD(aDadInt[8])//Data de Alta
			nQtdNasViv	:= aDadInt[9]+aDadInt[10]//Nascido Vivo+Nascido Prematuro
			cPadInt		:= aDadInt[12]//Tipo de acomodação
			cChvRes		:= aDadInt[13]//Chave do resumo

			If !Empty(dDatInt)
				cTrimOcor := DataTrimestre(DTOS(dDatInt),"3")
			EndIf

		Else//Nao conseguiu encontrar o resumo de internacao

			lPacInter	:= .F.
			cGuiInt		:= ""
			cGrupoInt	:= ""
			cRegimeInt	:= ""
			cHoraInt	:= ""
			cHoraAlta	:= ""
			dDatInt		:= STOD("")
			dDatAlta	:= STOD("")
			nQtdNasViv	:= 0
			cPadInt		:= ""
			cChvRes		:= ""
			cClaSIPInt	:= "H"
			cClaSIPSer	:= "H"
			cClaSIPEsp	:= "H"
			cClaHDesc   := "Guia de resumo de internação não encontrada." //TODO

		EndIf

	EndIf

	//Para procedimentos de consulta a classificacao vem da especialidade medica
	If !Empty(cClaSIPEsp)
		cClaSIPSer := cClaSIPEsp
	EndIf

	nIdade := Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))

	//Materiais, Medicamentos, Taxas e Outros serao classificados como outros atendimentos ambulatoriais
	If (cAlias)->BR8_TPPROC $ TP_MATERIAL + "," + TP_MEDICAME + "," + TP_TAXAS + "," + TP_OUTROS
	nQtdeReal := 0
	EndIf

	//Classificacao ITEM E
	If lPacInter
		cCdPrc := AllTrim(SubStr(cCodProc,3))
		cItemE := "E1"+AllTrim(cGrupoInt)+AllTrim(cRegimeInt)//Estou montando o grupo / tipo de internacao
		If AllTrim(cGrupoInt) == "4" //1=Clinica;2=Cirurgica;3=Obstetrica;4=Pediatrica;5=Psiquiatrica
			cClaSIPInt := ClsItemE14(cCID,cPadInt,cHoraInt,cHoraAlta,dDatInt,dDatAlta,STOD((cAlias)->BA1_DATNAS),nIdade)
		Else
			cClaSIPInt := ClasItemE(aClaIteE,cItemE,cCdPrc,cClaSIPInt,nIdade)
		EndIf
		LimpaArray(@aClaIteE)

		cClaSIPInt := AllTrim(cClaSIPInt)
		cClaSIPSer := AllTrim(cClaSIPSer)

		If cGrupoInt <> "4"
			//Parto
			If cClaSIPInt $ "E131,E132,E133"
				cClaSIPSer := cClaSIPInt
			ElseIf cClaSIPSer $ "E131,E132,E133"
				cClaSIPInt := cClaSIPSer
			EndIf
		Else
			cClaSIPSer := cClaSIPInt
		EndIf

		If cClaSIPInt == "E11XX"
			cClaSIPInt := SUbstr(AllTrim(cClaSIPInt),1,3)
			cClaSIPSer := SUbstr(AllTrim(cClaSIPInt),1,3)
		EndIf

	EndIf

	//Se tenho motivo de bloqueio , o valor de pagamento deve estar na guia de honorario
	//Encontrar o valor de pagamento da guia que nao tem bd7_blopag=1 mas tem bd7_motblo <> de vazio
	If !lPacote .And. (cAlias)->BD7_BLOPAG <> "1" .And. !Empty((cAlias)->BD7_MOTBLO)

		If nVlrDesp <= 0
			nVlrDesp := Iif(lCapit, (cAlias)->BD7_VLRPAG / nTotRat, (cAlias)->BD7_VLRPAG)
		EndIf

	Else

		While !(cAlias)->(Eof()) .And. (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) ==  cChaveGuia

			If cAlias == "TRBPCT" .And. lPacote
				nVlrDesp += (cAlias)->BLE_VALFIX
			Else
				nVlrDesp += Iif(lCapit, (cAlias)->BD7_VLRPAG / nTotRat, (cAlias)->BD7_VLRPAG)
			EndIf

			(cAlias)->(dbSkip())
		EndDo

	EndIf

	//Só vou contar frequência de guias que fiz algum pagamento
	If nVlrDesp == 0 .And. !lCapit
		nQtdeReal := 0
	EndIf

	aRetorno := {/*1*/cCodProc,/*2*/lConsulta,/*3*/cClaSIPSer,/*4*/cClaSIPEsp,/*5*/cClaSIPInt,/*6*/nQtdeReal,/*7*/cDataProc,/*8*/cTipoProc,/*9*/nVlrDesp,/*10*/cTrimOcor,;
		/*11*/cGrupoInt,/*12*/cRegimeInt,/*13*/cChvGuiGrv,/*14*/cMatric,/*15*/cUF,/*16*/cCID,/*17*/nIdade,/*18*/dDatInt,/*19*/cHoraInt,/*20*/dDatAlta,;
		/*21*/cHoraAlta,/*22*/cTrimReco,/*23*/nQtdNasViv,/*24*/cDente,/*25*/cGuiInt,/*26*/cChvRes,/*27*/cClaHDesc}

Return aRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaDados

Funcao cria a area de trabalho TRBXXX com as informacoes de todos os beneficarios (BA1) ou despesa (BD7,...)

@param cAlias		Nome da area de trabalho a ser criada
@param cDataRef	Data de referencia
@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento,4-Data Pgto
@param cRegANS		Numero de registro da operadora na ANS
@param nThread		Numero da thread / job sendo executada
@param aBenef		Matriz com o range de recnos a ser utilizado em cada consulta
@param nQuinzena	Indica se 1 - primeira ou 2 - segunda quinzena do mes a ser processada
@param lCount		Incica se ira .T. ou nao .F. retornar a quantidade de registros a serem processados
@param cLocDigIgn	Lista de locais de digitacao a serem ignorados

@return lRetorno	Indica se foi .T. ou nao .F. encontrado registros para a consulta

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaDados(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv,lDadosHist,cEmInici,cEmFinal)
	Local cSql			:= ""
	Local cCount		:= ""
	Local cSelect		:= ""
	Local lRetorno		:= .F.
	Local cDataIni		:= ""
	Local cDataFin		:= ""
	Local cCompIni		:= ""
	Local cCabLog		:= ""
	Local cLisReps		:= GetNewPar("MV_PLSGEIN ","0050")
	Local cOpePadr		:= PlsIntPad()
	Local cTriRec		:= ""
	Local lMV_STATISS	:= MV_STATISS
	Local cDb           := Alltrim(Upper(TcGetDb()) )
	Local lSipEmp       := GetNewPar("MV_PLSSIPE",.F.)	
	Default cAlias		:= ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cTipData	:= '1'
	Default cRegANS		:= '000000'
	Default nThread		:= 0
	Default nQuinzena	:= 1
	Default aBenef		:= {}
	Default lCount		:= .F.
	Default cLocDigIgn	:= ""
	Default lQryInter	:= .F.
	Default cChvGuiGrv	:= ""//Quando eu tenho a chave da guia grava e porque vou tratar pacote e quero so os itens do pacote
	Default lDadosHist	:= .F.
	Default cEmInici    := ""
	Default cEmFinal    := ""

	cTriRec := DataTrimestre(cDataRef)
	cCabLog += "[" + cTrirec + "]" + cAlias + " " + NomeJob(lQryInter,lDadosHist) + " (" + AllTrim(Str(nThread)) + AllTrim(Str(nQuinzena)) + "):"
	PlsLogFil(cCabLog + CENDTHRL("I") + " Inicio Carrega despesas",ARQ_LOG_DES)
	If (lCount .And. !(cAlias $ "TRB2CAP"))

		cSelect += " SELECT Count(1) Total "
		cCount	:= "[CONTA REGISTROS]"

	ElseIf (lCount .And. cAlias $ "TRB2CAP")

		cSelect += " SELECT SUM(BD6_QTDPRO) Total "
		cCount	:= "[SOMA REGISTROS CAPITATION]"

	Else

		cSelect += "SELECT BD7_NUMLOT, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_CODRDA, BD7_CODPAD, BD7_CODPRO, BD7_DATPRO, BD7_SEQUEN,BD7_REGPRE,BD7_CDPFPR,BD7_ESTPRE, "
		cSelect += "BD7_CODLOC, BD7_LOCAL, BD7_BLOPAG, BD7_MOTBLO, BD7_TIPGUI, BD7_LIBERA, BD7_CODESP, BD7_FASE, BD7_SITUAC, BD7_RECSIP, BD7_DTPAGT, BD7_DTDIGI, BD7.R_E_C_N_O_ RECNOBD7, BD6_DTDIGI, BD6_TABDES, BD6_CID, BD6_QTDPRO, "
		cSelect += "BD6_REGSOL,BD6_ESTSOL,BD6_SIGLA,BD6_REGEXE,BD6_ESTEXE,BD6_SIGEXE, "
		cSelect += "BD6_DATPRO, BD6_CODOPE, BD6_PROREL, BD6_OPEUSR, BD6_CODEMP, BD6_MATRIC, BD6_TIPREG, BD6_DIGITO, BD6_CODESP, BR8_CLASP2, BR8_CLASIP,BR8_FCAREN, "
		cSelect += "BR8_TPPROC, BR8_TPCONS, '" + cRegANS + "' BA0_SUSEP, '" + SubStr(cOpePadr,1,1) + "' BA0_CODIDE, '" + SubStr(cOpePadr,2,3) + "' BA0_CODINT, BA1_CODPLA, BA1_VERSAO, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, "
		cSelect += "BA1_DIGITO, BA1_DATNAS, BA1_SEXO, BA3_CODPLA, BA3_VERSAO, "

		If cAlias $ "TRBCAP"
			cSelect += " CASE "
			cSelect +=  	" WHEN BD7_VLRPAG = 0 THEN BGQ_VALOR "
			cSelect += 		" ELSE BD7_VLRPAG "
			cSelect += " END BD7_VLRPAG, "
		Else
			cSelect += "BD7_VLRPAG, "
		EndIf

		If !Empty(cChvGuiGrv)
			cSelect += " BLE_VALFIX, BLE_CPADOC, BLE_CODOPC, "
		EndIf

	EndIf

	If cAlias $ "TRBDES,TRBPCT"

		If !lCount

			If lQryInter
				cSelect += " BE4_GUIINT, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT "
			Else
				cSelect += " BD5_GUIINT "
			EndIf

			If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
				cSelect += ", BCI_DTHRLB "
			EndIf

		EndIf

		cSql := cSelect + "FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif

		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, "
		cSql += " " + RetSqlName("BR8") + " BR8, "
		If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
			cSql += " " + RetSqlName("BCI") + " BCI, "
		EndIf
		If lQryInter
			cSql += RetSqlName("BE4") + " BE4 "
		Else
			cSql += RetSqlName("BD5") + " BD5 "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += ", " + RetSqlName("BLE") + " BLE "
		EndIf

		cSql += "WHERE "
		If lQryInter
			cSql += " BE4_FILIAL = '" + xFilial("BE4") + "' "
		Else
			cSql += " BD5_FILIAL = '" + xFilial("BD5") + "' "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += "AND BLE_FILIAL = '" + xFilial("BLE") + "' "
		EndIf

		cSql += " AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' "
		If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
			cSql += " AND BCI_FILIAL = '" + xFilial("BCI") + "' "
		EndIf

		If lQryInter
			cSql += " AND BE4_CODOPE = BD6_CODOPE AND BE4_CODLDP = BD6_CODLDP "
			cSql += " AND BE4_CODPEG = BD6_CODPEG AND BE4_NUMERO = BD6_NUMERO "
			If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
				cSql += " AND BE4_CODOPE = BCI_CODOPE AND BE4_CODLDP = BCI_CODLDP AND BE4_CODPEG = BCI_CODPEG "
			EndIf
		Else
			cSql += " AND BD5_CODOPE = BD6_CODOPE AND BD5_CODLDP = BD6_CODLDP "
			cSql += " AND BD5_CODPEG = BD6_CODPEG AND BD5_NUMERO = BD6_NUMERO "
			If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
				cSql += " AND BD5_CODOPE = BCI_CODOPE AND BD5_CODLDP = BCI_CODLDP AND BD5_CODPEG = BCI_CODPEG "
			EndIf
		EndIf

		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP "
		cSql += " AND BD7_CODPEG = BD6_CODPEG AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		If !lQryInter
			cSql += " AND BD5_OPEUSR = BA3_CODINT AND BD5_CODEMP = BA3_CODEMP AND BD5_MATRIC = BA3_MATRIC "
			If lSipEmp
				cSql +=  " AND BD5_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
			EndIf 
		Else
			cSql += " AND BE4_OPEUSR = BA3_CODINT AND BE4_CODEMP = BA3_CODEMP AND BE4_MATRIC = BA3_MATRIC "
			If lSipEmp
				cSql +=  " AND BE4_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
			EndIf 
		EndIf
		cSql += " AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "

		If lSipEmp
			cSql +=  " AND BD6_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
		EndIf 

		cSql += " AND BD7_CODOPE = '" + cOpePadr + "' "
		cSql += " AND BD7_TIPGUI NOT IN ('03','04') "
		cSql += " AND BD7_LIBERA <>'1' AND BD7_FASE = '" + GetNewPar("MV_PLFSSIP","4") + "' "
		cSql += " AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
		cSql += " AND BD7_CODEMP NOT IN ('" + StrTran(cLisReps,",","','") + "') "

		If lSipEmp
			cSql +=  " AND BD7_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
		EndIf 

		If !Empty(cLocDigIgn)//Locais de digiticao a serem ignorados
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += " AND BR8_CODPAD = BLE_CODPAD AND BR8_CODPSA = BLE_CODPRO "
			cSql += " AND BD7_CODOPE = '" + SubStr(cChvGuiGrv,1,4) + "' "
			cSql += " AND BD7_CODLDP = '" + SubStr(cChvGuiGrv,5,4) + "' "
			cSql += " AND BD7_CODPEG = '" + SubStr(cChvGuiGrv,9,8) + "' "
			cSql += " AND BD7_NUMERO = '" + SubStr(cChvGuiGrv,17,8) + "' "
		EndIf

		If lDadosHist
			//Dados historicos so busca despesas vinculadas a internacao
			//Guias de servico ou honorario que nos trimestre anteriores a operadora ainda nao tinha recebido o resumo
			If lQryInter
				cSql += "AND BE4_GUIINT <> ' ' "
			Else
				cSql += "AND BD5_GUIINT <> ' ' "
			EndIf

		EndIf

		cSql += "AND BD7_RECSIP = ' ' AND BD7_BLOPAG <>'1' "

		Do case

			case cTipData == '1'//Data de digitacao

				If lMV_STATISS
					AtualizaDatas(@cDataIni,@cDataFin,cDataRef,Iif(nThread==0,1,nThread))
					If lDadosHist
						cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
						cSql += " AND BCI_DTHRLB <> ' ' AND SUBSTRING(BCI_DTHRLB,1,8) >= '" + cDataCor + "' AND SUBSTRING(BCI_DTHRLB,1,8) < '" + cDataIni + "' "
					Else
						cSql += " AND BCI_DTHRLB <> ' ' AND SUBSTRING(BCI_DTHRLB,1,8) BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
					EndIf
				Else
					AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
					If lDadosHist
						cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
						cSql += "AND BD7_DTDIGI >= '" + cDataCor + "' AND BD7_DTDIGI < '" + cDataIni + "' "
					Else
						cSql += "AND BD7_DTDIGI BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
					EndIf
				EndIf

			case cTipData == '2'//Lote de pagamento

				AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
				If lDadosHist
					cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
					cCompIni := SubStr(cDataCor,1,6) + "0000"
					cCompFin := SubStr(cDataIni,1,6) + "0000"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_NUMLOT >= '" + cCompIni + "' AND BD7_NUMLOT < '" + cCompFin + "' "
				Else
					cCompIni := SubStr(cDataFin,1,6) + "0000"
					cCompFin := SubStr(cDataFin,1,6) + "9999"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_NUMLOT BETWEEN '" + cCompIni + "' AND '" + cCompFin + "' "
				EndIf

			case cTipData == '3'//Procedimento

				AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
				If lDadosHist
					cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
					cSql += "AND BD7_DATPRO >= '" + cDataCor + "' AND BD7_DATPRO <'" + cDataIni + "' "
				Else
					cSql += "AND BD7_DATPRO BETWEEN '" + Iif(nQuinzena == 1,cDataIni,SubStr(cDataIni,1,6)+'16') + "' AND '" + Iif(nQuinzena == 1,SubStr(cDataFin,1,6)+'15',cDataFin) + "' "
				EndIf

			OtherWise //4-Data do Pagamento

				AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
				If lDadosHist
					cDataCor := DTOS( STOD(cDataIni) - (nMV_QTANSIP * 365) )
					cCompIni := SubStr(cDataCor,1,6) + "00"
					cCompFin := SubStr(cDataIni,1,6) + "00"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_DTPAGT >= '" + cCompIni + "' AND BD7_DTPAGT < '" + cCompFin + "' "
				Else
					cCompIni := SubStr(cDataFin,1,6) + "00"
					cCompFin := SubStr(cDataFin,1,6) + "99"
					cSql += "AND BD6_TABDES <> 'B8O' AND BD7_OPELOT = '" + cOpePadr + "' AND BD7_DTPAGT BETWEEN '" + cCompIni + "' AND '" + cCompFin + "' "
				EndIf

		EndCase//cTipData == '1'

		cSql += " AND BA1_INFANS = '1' "

		If !lQryInter
			cSql += "AND BD5.D_E_L_E_T_ = ' ' "
		Else
			cSql += "AND BE4.D_E_L_E_T_ = ' ' "
		EndIf

		If !Empty(cChvGuiGrv)
			cSql += "AND BLE.D_E_L_E_T_ = ' ' "
		EndIf

		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' "
		cSql += " AND BA3.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' ' "
		If lMV_STATISS .AND. cTipData == '1'//Data de digitacao
			cSql += " AND BCI.D_E_L_E_T_ = ' ' "
		EndIf
		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias $ "TRBCAP/TRB2CAP"

		If !lCount

			If lQryInter
				cSelect += " BE4_GUIINT, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT "
			Else
				cSelect += " BD5_GUIINT "
			EndIf

		EndIf

		cSql := cSelect + "FROM "
		cSql += " " + RetSqlName("BD7") + " BD7 "
		cSql += " INNER JOIN " + RetSqlName("BGQ") + " BGQ ON "
		cSql += 	" BGQ_FILIAL = BD7_FILIAL"
		cSql += 	" AND BGQ_CODIGO = BD7_CODRDA"
		cSql += 	" AND BGQ_ANO    = BD7_ANOPAG"
		cSql += 	" AND BGQ_MES    = BD7_MESPAG"
		cSql += 	" AND BGQ_CODOPE = BD7_CODOPE"
		cSql += 	" AND BGQ_OPELOT = BD7_OPELOT"
		cSql += 	" AND BGQ_NUMLOT = BD7_NUMLOT"
		cSql += 	" AND BGQ.D_E_L_E_T_ = ' ', "

		cSql += " " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BA1") + " BA1 "

		If lSipEmp
			cSql += " LEFT JOIN " + RetSqlName("BG9") + " BG9 ON "
			cSql += "         BG9_FILIAL = BA1_FILIAL "
			cSql += "     AND BG9_CODINT = BA1_CODINT "
			cSql += "     AND BG9_CODIGO = BA1_CODEMP "
			cSql += "     AND BG9.D_E_L_E_T_ = ' ' "
		EndIf 

		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif

		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, "
		cSql += " " + RetSqlName("BR8") + " BR8, "

		If lQryInter
			cSql += RetSqlName("BE4") + " BE4 "
		Else
			cSql += RetSqlName("BD5") + " BD5 "
		EndIf

		cSql += "WHERE "
		If lQryInter
			cSql += " BE4_FILIAL = '" + xFilial("BE4") + "' "
		Else
			cSql += " BD5_FILIAL = '" + xFilial("BD5") + "' "
		EndIf

		cSql += " AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' "

		If lQryInter
			cSql += " AND BE4_CODOPE = BD6_CODOPE AND BE4_CODLDP = BD6_CODLDP "
			cSql += " AND BE4_CODPEG = BD6_CODPEG AND BE4_NUMERO = BD6_NUMERO "
		Else
			cSql += " AND BD5_CODOPE = BD6_CODOPE AND BD5_CODLDP = BD6_CODLDP "
			cSql += " AND BD5_CODPEG = BD6_CODPEG AND BD5_NUMERO = BD6_NUMERO "
		EndIf

		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP "
		cSql += " AND BD7_CODPEG = BD6_CODPEG AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		If !lQryInter
			cSql += " AND BD5_OPEUSR = BA3_CODINT AND BD5_CODEMP = BA3_CODEMP AND BD5_MATRIC = BA3_MATRIC "
		Else
			cSql += " AND BE4_OPEUSR = BA3_CODINT AND BE4_CODEMP = BA3_CODEMP AND BE4_MATRIC = BA3_MATRIC "
		EndIf
		cSql += " AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "

		If lSipEmp
			cSql +=  " AND BD6_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
			cSql +=  " AND BD7_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
		EndIf 

		cSql += " AND BD7_CODOPE = '" + cOpePadr + "' "
		cSql += " AND BD7_LIBERA <>'1' AND BD7_TIPGUI NOT IN ('03','04') "
		cSql += " AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
		cSql += " AND BD7_CODEMP NOT IN ('" + StrTran(cLisReps,",","','") + "') "

		If !Empty(cLocDigIgn)//Locais de digiticao a serem ignorados
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		If cAlias $ "TRBCAP"
			cSql += "AND BD7_RECSIP = ' '  "
		EndIf

		AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)
		cCompIni := SubStr(cDataFin,1,6) + "00"
		cCompFin := SubStr(cDataFin,1,6) + "99"
		cSql += "AND BD6_TABDES = 'B8O' AND BD7_DTDIGI BETWEEN '" + cCompIni + "' AND '" + cCompFin + "' "

		cSql += " AND BA1_INFANS = '1' "

		If !lQryInter
			If lSipEmp
				cSql +=  " AND BD5_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
			EndIf 		
			cSql += "AND BD5.D_E_L_E_T_ = ' ' "
		Else
			If lSipEmp
				cSql +=  " AND BE4_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
			EndIf 
			cSql += "AND BE4.D_E_L_E_T_ = ' ' "
		EndIf

		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' "
		cSql += " AND BA3.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' ' "

		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias == "TRBREE"

		If !lCount

			cSelect += " ' ' BD5_GUIINT "

			If lMV_STATISS
				cSelect += ", B44_DTLBFN "
			EndIf

		EndIf

		cSql := cSelect + " FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, "
		cSql += " " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BA1") + " BA1 "

		If lSipEmp
			cSql += " LEFT JOIN " + RetSqlName("BG9") + " BG9 ON "
			cSql += "         BG9_FILIAL = BA1_FILIAL "
			cSql += "     AND BG9_CODINT = BA1_CODINT "
			cSql += "     AND BG9_CODIGO = BA1_CODEMP "
			cSql += "     AND BG9.D_E_L_E_T_ = ' ' "
		EndIf 

		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif
		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, "
		cSql += " " + RetSqlName("BR8") + " BR8, "
		cSql += " " + RetSqlName("B44") + " B44 "

		If !lMV_STATISS
			cSql += ", " + RetSqlName("SE1") + " SE1 "
		EndIf

		cSql += "WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
		cSql += " AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' "
		cSql += " AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' "
		cSql += " AND B44_FILIAL = '" + xFilial("B44") + "' "

		If !lMV_STATISS
			cSql += " AND E1_FILIAL = '" +	xFilial("SE1") + "' "
		EndIf

		cSql += " AND BD7_RECSIP = ' ' "
		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP AND BD7_CODPEG = BD6_CODPEG "
		cSql += " AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		If lSipEmp
			cSql +=  " AND BD6_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
		EndIf 

		cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
		cSql += " AND B44_OPEUSR = BD6_CODOPE AND B44_CODLDP = BD6_CODLDP AND B44_CODPEG = BD6_CODPEG "
		cSql += " AND B44_NUMGUI = BD6_NUMERO "
		If !lMV_STATISS
			cSql += "AND E1_PREFIXO = B44_PREFIX AND E1_NUM = B44_NUM "
		EndIf
		cSql += "AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "
		cSql += "AND BD7_LIBERA <>'1' AND BD7_FASE = '" + GetNewPar("MV_PLFSSIP","4") + "' "
		cSql += "AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
		If !Empty(cLocDigIgn)
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		If lSipEmp
			cSql +=  " AND BD7_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
		EndIf 

		AtualizaDatas(@cDataIni,@cDataFin,cDataRef,nThread)

		Do case

			case cTipData == '1'

				If lMV_STATISS
					cSql += " AND B44_DTLBFN BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
				Else
					cSql += "AND BD6_DTDIGI BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "
				EndIf

			case (cTipData == '2' .Or. cTipData == '4') .And. !lMV_STATISS

				cDataIni := DataTrimestre(cDataRef,"1")
				cDataFin := DataTrimestre(cDataRef,"2")
				cSql += "AND E1_EMIS1 BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "

			OtherWise

				cSql += "AND BD7_DATPRO BETWEEN '" + cDataIni + "' AND '" + cDataFin + "' "

		EndCase

		cSql += " AND BA1_INFANS = '1' "
		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' "
		cSql += " AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' ' "
		cSql += " AND B44.D_E_L_E_T_ = ' ' "
		If !lMV_STATISS
			cSql += "AND SE1.D_E_L_E_T_ = ' ' "
		EndIf

		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias == "TRBACU"

		If !lCount
			cSelect += " B19_GUIA, BD5_GUIINT "
		EndIf

		cSql := cSelect + " "
		cSql += " FROM "
		cSql += " " + RetSqlName("BD7") + " BD7, " + RetSqlName("BD6") + " BD6, "
		cSql += " " + RetSqlName("BD5") + " BD5, "
		cSql += " " + RetSqlName("BA1") + " BA1 "

		If lSipEmp
			cSql += " LEFT JOIN " + RetSqlName("BG9") + " BG9 ON "
			cSql += "         BG9_FILIAL = BA1_FILIAL "
			cSql += "     AND BG9_CODINT = BA1_CODINT "
			cSql += "     AND BG9_CODIGO = BA1_CODEMP "
			cSql += "     AND BG9.D_E_L_E_T_ = ' ' "
		EndIf 

		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "

		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif

		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, " + RetSqlName("BR8") + " BR8, " + RetSqlName("B19") + " B19, "
		cSql += " " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF1") + " SF1 "

		cSql += " WHERE "

		cSql += " BD5_FILIAL = '" + xFilial("BD5") + "' "
		cSql += " AND BD7_FILIAL = '" + xFilial("BD7") + "' AND BD6_FILIAL = '" + xFilial("BD6") + "' "
		cSql += " AND BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BR8_FILIAL = '" + xFilial("BR8") + "' AND B19_FILIAL = '" + xFilial("B19") + "' "
		cSql += " AND D1_FILIAL = '" + xFilial("SD1") + "' AND F1_FILIAL = '" + xFilial("SF1") + "' "

		cSql += " AND BD5_CODOPE = BD6_CODOPE AND BD5_CODLDP = BD6_CODLDP "
		cSql += " AND BD5_CODPEG = BD6_CODPEG AND BD5_NUMERO = BD6_NUMERO "
		cSql += " AND BD7_CODOPE = BD6_CODOPE AND BD7_CODLDP = BD6_CODLDP AND BD7_CODPEG = BD6_CODPEG "
		cSql += " AND BD7_NUMERO = BD6_NUMERO AND BD7_SEQUEN = BD6_SEQUEN "
		cSql += " AND BD6_OPEUSR = BA1_CODINT AND BD6_CODEMP = BA1_CODEMP AND BD6_MATRIC = BA1_MATRIC "
		cSql += " AND BD6_TIPREG = BA1_TIPREG AND BD6_DIGITO = BA1_DIGITO "
		cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
		cSql += " AND BD7_CODOPE = SUBSTRING(B19_GUIA, 1, 4) AND BD7_CODLDP = SUBSTRING(B19_GUIA, 5, 4) "
		cSql += " AND BD7_CODPEG = SUBSTRING(B19_GUIA, 9, 8) AND BD7_NUMERO = SUBSTRING(B19_GUIA, 17, 8) "
		cSql += " AND BD7_ORIMOV = SUBSTRING(B19_GUIA, 25, 1) AND BD7_SEQUEN = SUBSTRING(B19_GUIA, 26, 3) "
		cSql += " AND BD5_OPEUSR = BA3_CODINT AND BD5_CODEMP = BA3_CODEMP AND BD5_MATRIC = BA3_MATRIC "
		cSql += " AND D1_DOC = B19_DOC AND D1_SERIE = B19_SERIE AND D1_FORNECE = B19_FORNEC AND D1_LOJA = B19_LOJA "
		cSql += " AND D1_ITEM = B19_ITEM AND D1_COD = B19_COD "
		cSql += " AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND F1_LOJA = D1_LOJA "
		cSql += " AND BD6_CODPAD = BR8_CODPAD AND BD6_CODPRO = BR8_CODPSA "
		cSql += " AND BD7_FASE IN ('3','4') AND BD7_SITUAC = '1' AND BD6_TABDES <> 'B8O' "
		
		If lSipEmp
			cSql +=  " AND BD7_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
			cSql +=  " AND BD6_CODEMP BETWEEN  '" + cEmInici+ "' AND '" + cEmFinal + "' "			
		EndIf 

		If !Empty(cLocDigIgn)
			cSql += " AND BD7_CODLDP NOT IN " + cLocDigIgn + " "
		EndIf

		Do case
			case cTipData == '1'
				cSql += "AND BD6_DTDIGI BETWEEN '" + DataTrimestre(cDataRef,"1") + "' AND '" + DataTrimestre(cDataRef,"2") + "' "
			case cTipData == '2' .Or. cTipData == '4'
				cSql += "AND D1_DTDIGIT BETWEEN '" + DataTrimestre(cDataRef,"1") + "' AND '" + DataTrimestre(cDataRef,"2") + "' "
			OtherWise
				cSql += "AND BD7_DATPRO BETWEEN '" + DataTrimestre(cDataRef,"1") + "' AND '" + DataTrimestre(cDataRef,"2") + "' "
		EndCase

		cSql += " AND BA1_INFANS = '1' AND BD7_BLOPAG <>'1' "
		cSql += " AND BD7_RECSIP = ' ' "
		cSql += " AND BD7.D_E_L_E_T_ = ' ' AND BD6.D_E_L_E_T_ = ' ' AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' "
		cSql += " AND BR8.D_E_L_E_T_ = ' ' AND B19.D_E_L_E_T_ = ' ' AND SD1.D_E_L_E_T_ = ' ' AND SF1.D_E_L_E_T_ = ' ' "
		cSql += "AND BD5.D_E_L_E_T_ = ' ' "

		If !lCount
			cSql += "ORDER BY BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BR8_TPPROC"
		EndIf

	ElseIf cAlias == "TRBEXP"

		cDatBlo := DataTrimestre(cDataRef,"1")

		If lCount
			cSql := cSelect
		Else
			cSql := " SELECT "
			cSql += " '" + SubStr(cOpePadr,1,1) + "' BA0_CODIDE, '" + SubStr(cOpePadr,2,3) + "' BA0_CODINT, "
			cSql += " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DATCAR, BA1_DATINC, BA1_DATNAS, "
			cSql += " BA1_DATBLO, BA1_SEXO, BA1_NOMUSR, BA3_CODPLA, BA3_VERSAO, BA1_CODPLA, BA1_VERSAO, "
			cSql += " BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_DIGITO, BG9_TIPO, BG9_REPASS "

		EndIf

		cSql += " FROM "
		cSql += " " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif
		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
		cSql += " " + RetSqlName("BA3") + " BA3, " + RetSqlName("BG9") + " BG9 "
		cSql += " WHERE "
		cSql += " BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
		cSql += " AND BG9_FILIAL = '" + xFilial("BG9") + "' "
		cSql += " AND BA1_CODINT = '" + cOpePadr + "' AND BA1_OPEORI = '" + cOpePadr + "' "
		cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
		cSql += " AND BA1_CODINT = BG9_CODINT AND BA1_CODEMP = BG9_CODIGO "
		If Len(aBenef) > 0
			cSql += " AND BA1.R_E_C_N_O_ BETWEEN " + Alltrim(Str(aBenef[1])) + " AND " + Alltrim(Str(aBenef[2])) + " "
		EndIf
		cSql += " AND ( BA1_DATBLO = ' ' OR BA1_DATBLO >= '" + cDatBlo + "' ) "
		cSql += " AND BA1_DATINC <= '" + DataTrimestre(cDataRef,"2") + "' "
		cSql += " AND BA1_INFANS = '1' "
		cSql += " AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' AND BG9.D_E_L_E_T_ = ' ' "

	Endif

	cSql := ChangeQuery(cSql)

	If cAlias != "TRBPCT"
		PlsLogFil(cCabLog + CENDTHRL("I") + " " + cSql,ARQ_LOG_DES)
	EndIf

	If select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql), cAlias,.F.,.T.)
	If cAlias != "TRBPCT"
		PlsLogFil(cCabLog + CENDTHRL("I") + " " + cCount + " Fim da query" ,ARQ_LOG_DES)
	EndIf

	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "[" + Time() + "] Termino Carregadados" , 0, 0, {})

	PlsLogFil(cCabLog + CENDTHRL("I") + " Termino carregadados.",ARQ_LOG_DES)
	If Empty(cAlias) .Or. (cAlias)->(Eof()) .Or. (lCount .And. (cAlias)->Total == 0 )
		lRetorno := .F.
		PlsLogFil(cCabLog + CENDTHRL("I") + " Nao encontrou dados.",ARQ_LOG_DES)
	Else
		lRetorno := .T.
		PlsLogFil(cCabLog + CENDTHRL("I") + " Encontrou dados.",ARQ_LOG_DES)
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmpIncDesp

Funcao criada para incluir despesas na tabela temporaria B3Q da Central de Obrigacoes

@param cRegANS		Numero de registro da operadora na ANS
@param cCodObri	Chave da obrigacao
@param cAnoComp	Ano do compromisso
@param cCodComp	Chave do compromisso
@param aClasEven	Informacoes do evento classificado a ser incluido

@return lRetorno	Indica Verdadeiro (.T.) se inclui o registro ou Falso (.F.) para erro

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function TmpIncDesp(cRegANS,cCodObri,cAnoComp,cCodComp,aClasEven,aForSeg,lProSemCla,lCapit,lFase,lDesp)
	Local lRetorno		:= .T. //Indica se incluiu .T. ou nao .F. a despesa
	Local cForCon		:= "" //Forma de contratacao do plano
	Local cSegmen		:= "" //Segmentacao do plano
	Local cUF			:= Upper(aClasEven[__UF])
	Local nForSeg		:= 0
	Default cCodObri	:= "" //Chave da obrigacao
	Default cAnoComp	:= "" //Ano do compromisso
	Default cCodComp	:= "" //Codigo do compromisso
	Default cRegANS	    := '00000'
	Default aForSeg	    := {}
	Default lProSemCla	:= Empty(aClasEven[CLASIPSER]) .And. Empty(aClasEven[CLASIPINT])
	Default lCapit      := .F.
	Default lFase       := .T.
	Default lDesp       := .F.

	If !Empty(aClasEven[__MATRIC]) //Vou recuperar forma de contratacao e segmentacao do plano do beneficiario

		If B3K->(B3K_FILIAL+B3K_CODOPE+B3K_MATRIC) == xFilial("B3K")+cRegANS+aClasEven[__MATRIC] ;
				.OR. B3K->(msSeek(xFilial("B3K")+cRegANS+aClasEven[__MATRIC]))//B3K_FILIAL||B3K_CODOPE||B3K_MATRIC

			nForSeg := aScan(aForSeg,{ |x| x[1] == cRegANS+B3K->B3K_CODPRO })

			If nForSeg > 0
				cForCon := aForSeg[nForSeg,2]
				cSegmen := aForSeg[nForSeg,3]
			EndIf

			If nForSeg == 0 .And. B3J->(msSeek(xFilial("B3J")+cRegANS+B3K->B3K_CODPRO))
				cForCon := B3J->B3J_FORCON
				cSegmen := B3J->B3J_SEGMEN
				aAdd(aForSeg,{cRegANS+B3K->B3K_CODPRO,cForCon,cSegmen})
			EndIf

			If cUF == "ZZ"
				BA0->(DbSetOrder(5))
				If BA0->(dbSeek(xFilial("BA0")+B3K->B3K_CODOPE))
					cEstado:= BA0->BA0_EST
				EndIf
			EndIf

		EndIf

	EndIf
	cSegmen := AjustaSeg(IIf(Empty(alltrim(aClasEven[CLASIPSER])),aClasEven[CLASIPINT],aClasEven[CLASIPSER]),cSegmen)

	RecLock("B3Q",.T.)
	B3Q->B3Q_FILIAL := xFilial('B3Q')
	B3Q->B3Q_CODOPE := cRegANS
	B3Q->B3Q_CODOBR := cCodObri
	B3Q->B3Q_ANOCMP := cAnoComp
	B3Q->B3Q_CDCOMP := cCodComp
	B3Q->B3Q_MATRIC := aClasEven[__MATRIC]
	B3Q->B3Q_EVEDES := aClasEven[CHVGUIGRV]
	B3Q->B3Q_EVDEIN := aClasEven[CHVGUIINT]
	B3Q->B3Q_UF		:= Upper(aClasEven[__UF])
	B3Q->B3Q_TRIREC := aClasEven[TRIMRECO]
	B3Q->B3Q_TRIOCO := aClasEven[TRIMOCOR]
	B3Q->B3Q_CDTPTB := Left(aClasEven[PROCEDIME],2)
	B3Q->B3Q_CODEVE := Right(aClasEven[PROCEDIME],Len(aClasEven[PROCEDIME])-2)
	B3Q->B3Q_DATEVE := STOD(aClasEven[DATAPROC])
	B3Q->B3Q_QTDEVE := aClasEven[QTDEREAL]
	B3Q->B3Q_VLREVE := aClasEven[VLRDESP]
	B3Q->B3Q_CLAAMB := aClasEven[CLASIPSER]
	B3Q->B3Q_CLAINT := aClasEven[CLASIPINT]
	B3Q->B3Q_GRPINT := aClasEven[GRUPOINT]
	B3Q->B3Q_REGINT := aClasEven[REGIMEINT]
	B3Q->B3Q_CID	:= Upper(aClasEven[__CID])
	B3Q->B3Q_DATINT := Iif( ValType(aClasEven[__DATINT]) == "D", aClasEven[__DATINT], STOD("") )
	B3Q->B3Q_HORINT := aClasEven[__HORAINT]
	B3Q->B3Q_DATALT := Iif( ValType(aClasEven[DATALTA]) == "D", aClasEven[DATALTA], STOD("") )
	B3Q->B3Q_HORALT := aClasEven[HORAALTA]
	B3Q->B3Q_NASVIV := aClasEven[QTDNASVIV]
	B3Q->B3Q_DENREG := aClasEven[__DENTE]
	B3Q->B3Q_FORCON := cForCon
	B3Q->B3Q_SEGMEN := cSegmen
	B3Q->B3Q_STATUS := Iif(lProSemCla,'1','Z')
	If lB3Q_EVDRES
		B3Q->B3Q_EVDRES := aClasEven[CHVRESUMO]
	EndIf

	B3Q->(msUnLock())

	MarcaBD7(aClasEven[CHVGUIGRV],aClasEven[TRIMRECO],lCapit,lFase,Left(aClasEven[PROCEDIME],2)+Right(aClasEven[PROCEDIME],Len(aClasEven[PROCEDIME])-2),lProSemCla,lDesp)

Return lRetorno

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} AjustaSeg

		Funcao criada para realizar o ajuste da segmentacao da despesa que esta sendo processada

		@param cItem	Item do SIP que esta sendo procesado
		@param cSegmen	Codigo da Segmentacao encontrado

		@return cSeg	Novo codigo de segmentacao ajustado

		@author timoteo.bega
		@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function AjustaSeg(cItem,cSegmen)
	Local cSeg := ""
	Local  lMV_PLQDOBS := GetNewPar("MV_PLQDOBS",.T.)
	Default cSegmen := "1"
	//Ajusta a Segmentação
	If cItem $ 'E13,E131,E132'
		cSeg := '3' //3=Hospitalar obstetrico
	ElseIf cItem >= 'A' .AND. cItem <= 'A999' .OR. ;
			cItem >= 'B' .AND. cItem <= 'B999' .OR. ;
			cItem >= 'C' .AND. cItem <= 'C999' .OR. ;
			cItem >= 'D' .AND. cItem <= 'D999' .OR. ;
			cItem >= 'H' .AND. cItem <= 'H999'
		cSeg := '1' //1=Ambulatorial
	ElseIf cItem >= 'E' .AND. cItem <= 'E999' .OR. ;
			cItem >= 'F' .AND. cItem <= 'F999' .OR. ;
			cItem >= 'G' .AND. cItem <= 'G999'
		If lMV_PLQDOBS
			cSeg := '3' //3=Hospitalar obstetrico
		Else
			cSeg := '2' //2=Hospitalar
		EndIf
	ElseIf cItem >= 'I' .AND. cItem <= 'I999'
		cSeg := '4' //4=Odontologico
	Else
		cSeg := cSegmen
	EndIf

Return cSeg
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExisteDespesa

	Funcao criada para verificar se ja existe a despesa / carencia cadastrada na central de obrigacaoes

	@param cRegANS		Numero de registro da operadora  na ANS
	@param cCodObri	Chave da obrigacao
	@param cAnoComp	Ano do compromisso
	@param cCodComp	Chave do compromisso
	@param cChaveGuia	Chave da guia
	@param cMatric		Matricula do beneficiario
	@param cAlias		Area de trabalho corrente
	@param cItem		Codigo do item assistencial
	@param aClasEven	Matria com informacoes do evento classificado
	@param nRecB3L		Numero do recno encontrado na tabela B3L
	@param cForCon		Forma de contratacao do plano
	@param cSegmen 	Segmentacao do plano
	@param cDatEve		Data de realizacao do evento

	@return lRetorno	Indica Verdadeiro (.T.) se encontrou registro ou Falso (.F.) caso nao encontre

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteDespesa(cRegANS,cCodObri,cAnoComp,cCodComp,cChaveGuia,cMatric,cAlias,cItem,aClasEven,nRecB3L,cForCon,cSegmen,cDatEve,cUF,cEvDeIn)
	Local lRetorno		:= .F.
	Local cSql			:= ""
	Default cRegANS		:= ""
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default cChaveGuia	:= ""
	Default cMatric		:= ""
	Default cItem		:= ""
	Default aClasEven	:= array(26)
	Default nRecB3L		:= 0
	Default cForCon		:= ""
	Default cSegmen		:= ""
	Default cDatEve		:= ""
	Default cUF			:= "ZZ"
	Default cEvDeIn		:= ""

	If cAlias != "TRBEXP"

		cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B3L") + " "
		If BANCO == "MSSQL7"
			cSql += "WITH (NOLOCK) "
		EndIf
		cSql += "WHERE B3L_FILIAL = '" + xFilial("B3L") + "' "
		cSql += "AND B3L_CODOPE = '" + cRegANS + "' "
		cSql += "AND B3L_CODOBR = '" + cCodObri + "' "
		cSql += "AND B3L_ANOCMP = '" + cAnoComp + "' "
		cSql += "AND B3L_CDCOMP = '" + cCodComp + "' "
		cSql += "AND B3L_EVEDES = '" + cChaveGuia + "' "
		cSql += "AND B3L_MATRIC = '" + cMatric + "' "
		If Empty(cItem)//Item
			cSql += "AND B3L_CDTPTB = '" + SubStr(aClasEven[PROCEDIME],1,2) + "' "
			cSql += "AND B3L_CODEVE = '" + SubStr(aClasEven[PROCEDIME],3,Len(aClasEven[PROCEDIME])) + "' "
			cSql += "AND B3L_CLAAMB = '" + aClasEven[CLASIPSER] + "' "
			cSql += "AND B3L_CLAINT = '" + aClasEven[CLASIPINT] + "' "
			cSql += "AND B3L_UF = '" + cUF + "' "//UF so tem aqui mesmo pois nao coube na chave unica
		Else//Totalizador
			cSql += "AND B3L_CDTPTB = ' ' "
			cSql += "AND B3L_CODEVE = ' ' "
			cSql += "AND B3L_CLAAMB = '" + cItem + "' "
			cSql += "AND B3L_CLAINT = '" + cItem + "' "
		EndIf
		If !Empty(cForCon)
			cSql += "AND B3L_FORCON = '" + cForCon + "' "
		Else
			cSql += "AND B3L_FORCON = ' ' "
		EndIf
		If !Empty(cSegmen)
			cSql += "AND B3L_SEGMEN = '" + cSegmen + "' "
		Else
			cSql += "AND B3L_SEGMEN = ' ' "
		EndIf
		If !Empty(cDatEve)
			cSql += "AND B3L_DATEVE = '" + cDatEve + "' "
		Else
			cSql += "AND B3L_DATEVE = ' ' "
		EndIf
		cSql += "AND D_E_L_E_T_ = ' ' "

	Else
		//B3O_FILIAL+B3O_CODOPE+B3O_CDOBRI+B3O_ANO+B3O_CDCOMP+B3O_MATRIC+B3O_ITEM
		cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("B3O") + " "
		If BANCO == "MSSQL7"
			cSql += "WITH (NOLOCK) "
		EndIf
		cSql += "WHERE B3O_FILIAL = '" + xFilial("B3O") + "' "
		If !Empty(cRegANS)
			cSql += "AND B3O_CODOPE = '" + cRegANS + "' "
		EndIf
		If !Empty(cCodObri)
			cSql += "AND B3O_CDOBRI = '" + cCodObri + "' "
		EndIf
		If !Empty(cAnoComp)
			cSql += "AND B3O_ANO = '" + cAnoComp + "' "
		EndIf
		If !Empty(cCodComp)
			cSql += "AND B3O_CDCOMP = '" + cCodComp + "' "
		EndIf
		If !Empty(cMatric)
			cSql += "AND B3O_MATRIC = '" + cMatric + "' "
		EndIf
		If !Empty(cItem)
			cSql += "AND B3O_ITEM = '" + cItem + "' "
		EndIf
		cSql += "AND D_E_L_E_T_ = ' ' "

	EndIf

	cSql := ChangeQuery(cSql)
	cSql := InsereNoLock(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBEXI",.F.,.T.)

	If !TRBEXI->(Eof())
		lRetorno := .T.
		nRecB3L := TRBEXI->R_E_C_N_O_
	EndIf

	TRBEXI->(dbCloseArea())

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} LocalizaCompromisso

	Funcao criada para alimetar as variaveis referente a chave do compromisso se este for encontrado

	@param cDataReal	Data de realizacao ou database
	@param cCodObri	Chave do obrigacao
	@param cAnoComp	Ano do compromisso
	@param cSazComp	Chave da sazonalidade
	@param cCodComp	Codigo do compromisso
	@param cRegANS		Numero de registro da operadora na ANS

	@return lRetorno	Retorna Verdadeiro (.T.) se localizou ou Falso (.F.) caso nao encontre

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function LocalizaCompromisso(cDataReal,cCodObri,cAnoComp,cSazComp,cCodComp,cRegANS)
	Local lRetorno		:= .T.
	Default cDataReal:= DTOS(dDataBase)
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cSazComp	:= ""
	Default cCodComp	:= ""
	Default cRegANS	:= '000000'

	B3A->(dbSetOrder(2))//B3A_FILIAL + B3A_CODOPE + B3A_TIPO
	If B3A->(msSeek(xFilial("B3A")+cRegANS+'1')) .And. B3A->B3A_ATIVO = '1'
		cCodObri := B3A->B3A_CODIGO
		cSazComp := B3A->B3A_SZNLDD
	Else
		lRetorno := .F.
	EndIf
	B3D->(dbSetOrder(1))//B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO
	If lRetorno .And. B3D->(msSeek(xFilial('B3D')+cRegANS+cCodObri+Left(cDataReal,4)+"0"+Right(cDataReal,2)))
		cAnoComp := B3D->B3D_ANO
		cCodComp := B3D->B3D_CODIGO
	Else
		lRetorno := .F.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ProximaGuia

	Funcao criada para movimentar a area de trabalho para a proxima guia a ser processada

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave da guia posicionada (BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ProximaGuia(cAlias,cChaveGuia)
	Default cChaveGuia	:= ""

	While (cAlias)->(!Eof()) .And. cChaveGuia == (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
		(cAlias)->(dbSkip())
	End

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} DataReconhece

	Funcao criada para retornar a data de ocorrencia do procedimento

	@param cAlias		Area de trabalho ou tabela que esta sendo movimentada
	@param cTipData		Tipo de data que sera retornada como data de ocorrencia

	@return cDatReco	Data de reconhecimento identificada

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function DataReconhece(cAlias,cTipData,lMV_STATISS,lCapit)
	Local cDatReco		:= ""
	Default cAlias	:= 'TRBDES'
	Default cTipData	:= '1'
	Default lMV_STATISS	:= MV_STATISS
	Default lCapit      := .f.

	If lCapit
		cDatReco := (cAlias)->BD7_DTDIGI
	Else
		If cTipData == '2' //2-Pagamento
			cDatReco := SubStr((cAlias)->BD7_NUMLOT,1,6) + "01"
		ElseIf cTipData == '3' //3-Procedimento
			cDatReco := (cAlias)->BD7_DATPRO
		ElseIf cTipData == '4' //4- Data de Pagamento
			cDatReco := SubStr((cAlias)->BD7_DTPAGT,1,6) + "01"
		Else //1-Digitacao
			If lMV_STATISS
				cDatReco := AllTrim(DataReconPeg(cAlias,lMV_STATISS))
				If Len(cDatReco) < 6
					cDatReco := (cAlias)->BD6_DTDIGI
				EndIf
			Else
				cDatReco := (cAlias)->BD6_DTDIGI
			EndIf
		EndIf
	EndIf

Return cDatReco
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} DataTrimestre

	Funcao criada para transformar a data em trimestre valido para o SIP

	@param cData	Data (AAAAMMDD) que sera transformata em trimestre (AAAAMM) ou AAAAMMDD inicial ou final do trimestre
	@param nOpc		Tipo de retorno
	1 - monto o retorno da data AAAAMMDD inicial
	2 - monto o retorno da data AAAAMMDD final
	3 - default - monto o retorno do trimestre AAAAMM

	@return cTrimestre	Retorno o trimestre identificado

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function DataTrimestre(cData,cOpc)
	Local nTrimestre	:= 1
	Local nAscan		:= 0
	Local cTrimestre	:= ""
	Local aPeriodos	:= {}
	Default cData		:= DTOS(dDataBase)
	Default cOpc		:= ""// "" - AAAADD, "1" - AAAAMMDD inicial, "2" - AAAAMMDD final

	aAdd(aPeriodos,{"01","02","03"})
	aAdd(aPeriodos,{"04","05","06"})
	aAdd(aPeriodos,{"07","08","09"})
	aAdd(aPeriodos,{"10","11","12"})

	//Identifico o trimestre que pertence a data
	nAscan := Ascan( aPeriodos,{|x| x[1] == Substr(cData,5,2) .Or. x[2] == Substr(cData,5,2) .Or. x[3] == Substr(cData,5,2)})
	If nAscan > 0//Devo proteger nTrimestre de receber zero
		nTrimestre := nAscan
	EndIf

	If cOpc == "1"//monto o retorno da data AAAAMMDD inicial

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,1]
		cTrimestre += "01"

	ElseIf cOpc == "2"//monto o retorno da data AAAAMMDD final

		cTrimestre := SubStr(cData,1,4)
		cTrimestre += aPeriodos[nTrimestre,3]
		If nTrimestre == 1
			If SubStr(cTrimestre,5,2) == "02"
				If Val(SubStr(cTrimestre,1,4)) % 4 == 0
					cTrimestre += "29"
				Else
					cTrimestre += "28"
				EndIf
			Else
				cTrimestre += "31"
			EndIf
		Else
			If SubStr(cTrimestre,5,2) $ "04,06,09,10"
				cTrimestre += "30"
			Else
				cTrimestre += "31"
			EndIf
		EndIf

	Else//monto o retorno do trimestre AAAAMM
		cTrimestre := Substr(cData,1,4)+PADL(Alltrim(Str(nTrimestre)),2,"0")
	EndIf

Return cTrimestre

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PegaProduto

	Funcao criado para retornar a chave do produto do beneficiario

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param lPodeBR		Indica que deverá as regras estabelecidas na tabela padrão deverão ser consideradas para este produto
	@param cCodSeg		Codigo da segmentacao do produto
	@param lAtenOdon	Indica se o produto permite .T. ou nao .F. atendimento odontologico
	@param cForCon		Forma de contratacao do produto / plano

	@return cChaveProd	Chave do produto do beneficiario operadora+codigo+versao

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PegaProduto(cAlias,lPodeBR8,cCodSeg,lAtenOdon,cForCon)
	Local cChaveProd	:= ""
	Default cCodSeg	:= "1"
	Default cForCon	:= "1"
	Default lPodeBR8	:= .F.
	Default lAtenOdon:= .F.

	If !Empty((cAlias)->(BA3_CODPLA+BA3_VERSAO))
		cChaveProd := (cAlias)->(BA0_CODIDE+BA0_CODINT+BA3_CODPLA+BA3_VERSAO)
	Else
		cChaveProd := (cAlias)->(BA0_CODIDE+BA0_CODINT+BA1_CODPLA+BA1_VERSAO)
	EndIf

	If cAlias == "TRBEXP"

		If BI3->(msSeek(xFilial("BI3")+cChaveProd))

			lPodeBR8	:= BI3->BI3_TODOS == "1"

			If BI6->(msSeek(xFilial("BI6")+BI3->BI3_CODSEG))
				lAtenOdon	:= BI6->BI6_ODONTO == "1"
				cCodSeg		:= BI6->BI6_SEGSIP
			EndIf

			If BII->(msSeek(xFilial("BII")+BI3->BI3_TIPCON))
				cForCon := BII->BII_TIPPLA
			EndIf

		EndIf

	EndIf

Return cChaveProd
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaRepasse

	Funcao criada para descartar / pular beneficiarios pertencentes a contrato de reciprocidade

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave da guia posicionada (BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

	@return lRetorno	Indica se pulou .T. ou nao .F. o grupo empresa considerado como reciprocidade

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PulaRepasse(cAlias,cChave)
	Local lRetorno	:= .F.
	Default cAlias	:= ""
	Default cChave	:= ""

	If !Empty(cAlias) .And. !Empty(cChave) .And. ;
			( ;
			BG9->(BG9_FILIAL+BG9_CODINT+BG9_CODIGO) == xFilial("BG9")+(cAlias)->(BA0_CODIDE+BA0_CODINT+BA1_CODEMP) ;
			.OR. BG9->(msSeek(xFilial("BG9")+(cAlias)->(BA0_CODIDE+BA0_CODINT+BA1_CODEMP) )) ;
			) .And. BG9->BG9_REPASS == '1'

		If cAlias != "TRBEXP"//Proxima guia somente quando nao estiver contando beneficiarios expostos
			ProximaGuia(cAlias,@cChave)
		EndIf
		lRetorno := .T.

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaEstorno

	Funcao criara para descartar / pular as despesas estornadas que nao devem ser consideradas=

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave da guia posicionada (BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

	@return lRetorno	Indica se pulou .T. ou nao .F. despesa

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PulaEstorno(cAliEst,cChaveGuia)
	Local lRetorno			:= .F.
	Default cAliEst		:= ""
	Default cChaveGuia	:= ""

	//Despreza guias de consulta e servico estornadas | Esta do Indice 1 da BD5
	If !Empty(cAliEst) .And. !Empty(cChaveGuia) .And. ExisteEstorno(cChaveGuia)

		ProximaGuia(cAliEst,cChaveGuia)
		lRetorno := .T.

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaProduto

	Funcao criara para descartar / pular os produtos que nao sao informados para ANS

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cChaveGuia	Chave do produto que sera testado

	@return lRetorno	Indica se pulou .T. ou nao .F. produto

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PulaProduto(cAliPrd,cChaveProd,aProduto,cChGu)
	Local lRetorno			:= .F.
	Local nProduto			:= 0

	Default cAliPrd		    := ""
	Default cChaveProd	    := ""
	Default aProduto		:= {}
	Default cChGu           := ""

	nProduto := aScan(aProduto,{|x| x[1] == cChaveProd})

	If nProduto == 0 .And. !Empty(cAliPrd) .And. InformaProduto(cChaveProd,aProduto)

		If cAliPrd != 'TRBEXP'
			ProximaGuia(cAliPrd,cChaveProd)
		EndIf
		lRetorno := .T.

	Else

		If nProduto > 0 .And. cAliPrd != 'TRBEXP' .And. Len(aProduto[nProduto])>=2 .And. aProduto[nProduto,2] == '0'
			ProximaGuia(cAliPrd,cChGu)
			lRetorno := .T.
		EndIf

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PegaNatSaude

	Funcao criada para retornar a matriz de natureza de saude BF0

	@param cClasip	opicional - quando informado retorna apenas os itens pertencetees ao grupo cClaSip

	@return aNatSaude	Matriz de natureza de saude
	@description
	[1] - BF0_CODIGO	-	codigo da naturea de saude
	[2] - 0				-	zero
	[3] - data vazia	-	data vazia
	[4] - BF0_IDADE1	-	idade de
	[5] - BF0_IDADE2	-	idade ate
	[6] - BF0_SEXO		-	sexo
	[7] - BF0_NIVEL	-	1-grupo; 2-subgrupo; 3-item
	[7] - BF0_CODSUP	-	1-grupo; 2-subgrupo; 3-item

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PegaNatSaude()
	Local aNatSaude	:= {}
	Local cSql			:= ""

	BF0->(dbSetOrder(3))//BF0_FILIAL+BF0_GRUGEN+BF0_CODSUP+BF0_CODIGO

	cSql := "SELECT BF0_CODSUP, BF0_CODIGO, BF0_NIVEL, BF0_IDADE1, BF0_IDADE2, BF0_SEXO "
	cSql += "FROM " + RetSqlName("BF0") + " BF0 "
	cSql += "WHERE BF0_FILIAL = '" + xFilial("BF0") + "' AND BF0_GRUGEN = '" + GetNewPar("MV_PLGRSIP","0001") + "' AND BF0_BENEF = '1' AND SUBSTRING(BF0_CODSUP,1,1) <> 'F' "
	cSql += "AND BF0.D_E_L_E_T_ = ' '  "
	cSql += "ORDER BY BF0_CODIGO"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBF0",.F.,.T.)
	// PlsLogFil("query natsaude"+ CENDTHRL("I") + cSql,DEBUG_EXP)

	While !TRBBF0->(Eof())

		If BF0->(msSeek(xFilial("BF0")+GetNewPar("MV_PLGRSIP","0001")+TRBBF0->BF0_CODIGO))

			While !BF0->(Eof()) .And. BF0->BF0_CODSUP == TRBBF0->BF0_CODIGO

				If aScan(aNatSaude,{|x| x[1] == BF0->BF0_CODIGO}) == 0

					aAdd(aNatSaude,{BF0->BF0_CODIGO,0,CTOD("19990101"),BF0->BF0_IDADE1, BF0->BF0_IDADE2,BF0->BF0_SEXO, BF0->BF0_NIVEL,TRBBF0->BF0_CODSUP})
					// PlsLogFil(TRBBF0->BF0_NIVEL + " aAdd(aNatSaude,{"+ BF0->BF0_CODIGO+",0,01/01/1999,"+AllTrim(Str(BF0->BF0_IDADE1))+","+AllTrim(Str(BF0->BF0_IDADE2))+","+BF0->BF0_SEXO+","+BF0->BF0_NIVEL+","+TRBBF0->BF0_CODSUP+"}) " ,DEBUG_EXP)
				EndIf

				BF0->(DbSkip())

			EndDo

		EndIf//BF0->(msSeek(xFilial("BF0")+GetNewPar("MV_PLGRSIP","0001")+TRBBF0->BF0_CODIGO))

		If aScan(aNatSaude,{|x| x[1] == TRBBF0->BF0_CODIGO}) == 0

			aAdd(aNatSaude,{TRBBF0->BF0_CODIGO,0,CTOD("19990101"),TRBBF0->BF0_IDADE1, TRBBF0->BF0_IDADE2, TRBBF0->BF0_SEXO, TRBBF0->BF0_NIVEL,TRBBF0->BF0_CODSUP})
			// PlsLogFil(TRBBF0->BF0_NIVEL + " aAdd(aNatSaude,{"+ BF0->BF0_CODIGO+",0,01/01/1999,"+AllTrim(Str(BF0->BF0_IDADE1))+","+AllTrim(Str(BF0->BF0_IDADE2))+","+BF0->BF0_SEXO+","+BF0->BF0_NIVEL+","+TRBBF0->BF0_CODSUP+"}) " ,DEBUG_EXP)
		EndIf

		TRBBF0->(dbSkip())

	EndDo

	If Len(aNatSaude) > 0
		aSort(aNatSaude,,,{|x,y| x[1] < y[1]})
	EndIf

	BF0->(dbCloseArea())
	TRBBF0->(dbCloseArea())

Return aNatSaude
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} BenefBloqueio

	Funcao criada para verificar se o beneficiario esta bloqueado no periodo do envio do SIP

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cDataRef	Data de referencia
	@param cDataBlo	Data de bloqueio do beneficiario

	@return lRetorno	Indica se o beneficiario estava .T. ou nao .F. bloqueado no periodo

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefBloqueio(cAlias,cDataRef,cDataBlo)
	Local lRetorno	:= .F.
	Local lBlqANS	:= .F.
	Local cSql		:= ""
	Local cDataIni	:= DataTrimestre(cDataRef)+"00"
	Local cDataFin	:= Left(cDataIni,4)+Soma1(SubStr(cDataIni,5,2),2)+"99"

	cDataBlo	:= (cAlias)->BA1_DATBLO

	cSql := "SELECT BCA_TIPO, BCA_DATA, BCA_MOTBLO, BCA_NIVBLQ "
	cSql += "FROM " + RetSqlName("BCA") +" BCA "
	cSql += "WHERE BCA_FILIAL = '"+ xFilial("BCA") +"' AND BCA_MATRIC = '" + (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) + "' AND BCA_TIPREG = '" + (cAlias)->BA1_TIPREG + "' "
	cSql += "AND BCA_DATA >= '" + cDataIni + "' AND BCA_DATA <= '" + cDataFin + "' AND BCA_TIPO = '0' AND BCA.D_E_L_E_T_ = ' '  "
	cSql += "ORDER BY BCA_DATA, R_E_C_N_O_"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBCA",.F.,.T.)

	While !TRBBCA->(Eof())

		lBlqANS := .F.

		Do Case

		Case TRBBCA->BCA_NIVBLQ == "U" // Nivel de Usuario

			If  BG3->(msSeek(xFilial("BG3")+TRBBCA->BCA_MOTBLO))
				If  !Empty(BG3->BG3_BLQANS)
					lBlqANS := .T.
				EndIf
			EndIf

		Case TRBBCA->BCA_NIVBLQ == "F" // Nivel de Familia

			If  BG1->(MsSeek(xFilial("BG1")+TRBBCA->BCA_MOTBLO))
				If  !Empty(BG1->BG1_BLQANS)
					lBlqANS := .T.
				EndIf
			EndIf

		Case TRBBCA->BCA_NIVBLQ == "S" // Nivel de Sub-Contrato

			If  BQU->(MsSeek(xFilial("BQU")+TRBBCA->BCA_MOTBLO))
				If  !Empty(BQU->BQU_BLQANS)
					lBlqANS := .T.
				EndIf
			EndIf

		EndCase

		If  lBlqANS
			cDataBlo := TRBBCA->BCA_DATA
		EndIf

		TRBBCA->(dbSkip())

	EndDo

	TRBBCA->(dbCloseArea())

	If !Empty(cDataBlo) .And. cDataBlo < cDataIni
		lRetorno := .T.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CarregaCarencia

	Funcao criada para carregar informacoes de carencia do beneficiario

	@param cAlias		Alias / area de trabalho que esta sendo movimentado
	@param cMatric		Matricula do beneficiario
	@param cContrato	Chave completa do contrato do beneficiario
	@param cProduto	Chave completa do produto do beneficiario

	@return lRetorno	Indica se foi .T. ou nao .F. encontrado carencia para o beneficiario no PLS

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaCarencia(cAlias,cMatUsu,cContrato,cProduto)
	Local lRetorno	:= .F.
	Local cSql		:= ""
	Local cOpeUsr	:= SubStr(cMatUsu,1,4)
	Local cCodEmp	:= SubStr(cMatUsu,5,4)
	Local cMatric	:= SubStr(cMatUsu,9,6)
	Local cTipReg	:= SubStr(cMatUsu,15,2)
	Local cNumCon	:= SubStr(cContrato,5,12)
	Local cVerCon	:= SubStr(cContrato,17,3)
	Local cSubCon	:= SubStr(cContrato,20,9)
	Local cVerSub	:= SubStr(cContrato,29,3)
	Local cCodPro	:= SubStr(cProduto,5,4)
	Local cVerPro	:= SubStr(cProduto,9,3)
	Local lPodeBR8  := .F.

	BI3->(dbSetOrder(1))
	If BI3->(msSeek(xFilial("BI3")+cProduto))
		lPodeBR8	:= BI3->BI3_TODOS == "1"
	EndIf

	If lPodeBR8 //considera tabela padrão?

		//Consulta para obter os dados de cobertura/carencia, otimizado para o Exposto.
		cSql := " SELECT BR8_CODPAD, MAX(BR8_CODPSA) BR8_CODPSA, BR8_CLASIP, BR8_CLASP2, '' BG8_CODGRU, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,  BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " '' BFE_CODGRU, ''BFE_DATCAR, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " '' BFC_CODGRU, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " '' BT7_CARENC, '' BT7_UNCAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " '' BRV_CODGRU, '' BG8_CARENC, '' BG8_UNCAR, '' BG8_CLACAR, '' BG8_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "

		cSql += " FROM " + RetSqlName("BR8") + " BR8 "

		//COBERTURA NO USUARIO - CLasse de carência no beneficiário
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFO") + " BFO "
		cSql += " ON BFO_FILIAL = '" + xFilial("BFO") + "' "
		cSql += " AND BFO_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFO_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFO_MATRIC = '"+cMatric+"' "
		cSql += " AND BFO_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFO_CLACAR = BR8_CLACAR "
		cSql += " AND BFO.D_E_L_E_T_ = ' '  "

		//COBERTURA NO USUARIO - PROCEDIMENTOS EXCLUSIVOS PARA O BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFG") + " BFG "
		cSql += " ON BFG_FILIAL = '" + xFilial("BFG") + "' "
		cSql += " AND BFG_CODPAD = BR8_CODPAD "
		cSql += " AND BFG_CODPSA = BR8_CODPSA "
		cSql += " AND BFG_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFG_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFG_MATRIC = '"+cMatric+"' "
		cSql += " AND BFG_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFG.D_E_L_E_T_ = ' '  "

		//COBERTURA FAMILIA - EXCLUSIVOS DE PROCEDIMENTOS NA FAMILIA...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFD") + " BFD "
		cSql += " ON BFD_FILIAL = '" + xFilial("BFD") + "' "
		cSql += " AND BFD_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFD_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFD_MATRIC = '" + cMatric + "' "
		cSql += " AND BFD_CODPAD = BR8_CODPAD "
		cSql += " AND BFD_CODPSA = BR8_CODPSA "
		cSql += " AND BFD.D_E_L_E_T_ = ' '  "

		//OBTEM PROCEDIMENTOS PARAMETRIZADOS EXCLUSIVOS NO CONTRATO/SUBCONTRATO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BT8") + " BT8 "
		cSql += " ON BT8_FILIAL = '" + xFilial("BT8") + "' "
		cSql += " AND BT8_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BT8_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BT8_NUMCON = '" + cNumCon + "' "
		cSql += " AND BT8_VERCON = '" + cVerCon + "' "
		cSql += " AND BT8_SUBCON = '" + cSubCon + "' "
		cSql += " AND BT8_VERSUB = '" + cVerSub + "' "
		cSql += " AND BT8_CODPRO = '" + cCodPro + "' "
		cSql += " AND BT8_VERPRO = '" + cVerPro + "' "
		cSql += " AND BT8_CODPAD = BR8_CODPAD "
		cSql += " AND BT8_CODPSA = BR8_CODPSA "
		cSql += " AND BT8.D_E_L_E_T_ = ' '  "

		cSql += " LEFT OUTER JOIN " + RetSqlName("BA6") + " BA6 "
		cSql += " ON BA6_FILIAL = '" + xFilial("BA6") + "' "
		cSql += " AND BA6_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BA6_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BA6_NUMCON = '" + cNumCon + "' "
		cSql += " AND BA6_VERCON = '" + cVerCon + "' "
		cSql += " AND BA6_SUBCON = '" + cSubCon + "' "
		cSql += " AND BA6_VERSUB = '" + cVerSub + "' "
		cSql += " AND BA6_CODPRO = '" + cCodPro + "' "
		cSql += " AND BA6_VERPRO = '" + cVerPro + "' "
		cSql += " AND BA6_CLACAR = BR8_CLACAR "
		cSql += " AND BA6.D_E_L_E_T_ = ' '  "

		//OBTEM CARENCIAS POR PROCEDIMENTO NO PRODUTO DO BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BB2") + " BB2 "
		cSql += " ON BB2_FILIAL = '" + xFilial("BB2") + "' "
		cSql += " AND BB2_CODIGO = '" + cOpeUsr + cCodPro + "' " //OPERADORA E PRODUTO
		cSql += " AND BB2_VERSAO = '" + cVerPro + "' "
		cSql += " AND BB2_CODPAD = BR8_CODPAD "
		cSql += " AND BB2_CODPSA = BR8_CODPSA "
		cSql += " AND BB2_BENUTL = '1' " //SOMENTE OS ATIVOS
		cSql += " AND BB2.D_E_L_E_T_ = ' '  "

		//LEMBRETE CASO O PRODUTO SEJA CONSIDERA PADRAO = SIM, DEVE-SE PEGAR TAMBEM COMO COBERTURA/CARENCIA OS DADOS DA BR8
		cSql += " WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
		cSql += " AND (BR8_CLASIP <> ' ' OR BR8_CLASP2 <> ' ') "
		cSql += " AND BR8_BENUTL = '1' "

		//CASO SEJA PARAMETRIZADO SOMENTE COM PROCEDIMENTOS, HABILITAR O PARAMETRO ABAIXO (MAIOR DESEMPENHO).
		If GetNewPar("MV_PLFCSOP","0") == "1"
			cSql += " AND BR8_TPPROC = '"+TP_PROCEDIM+"' "
		EndIf

		//CAMPO CRIADO PARA CONFIGURAR SE CONSIDERA OU NAO NO CALCULO DE BENEF EXPOSTOS
		cSql += " AND BR8_FCAREN = '1' "
		cSql += " AND BR8.D_E_L_E_T_ = ' '  "
		//GROUP BY PARA REDUZIR CLASSIFICACOES REPETIDAS
		cSql += " GROUP BY BR8_CODPAD, BR8_CLASIP, BR8_CLASP2, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "

	else

		//Consulta para obter os dados de cobertura/carencia, otimizado para o Exposto.
		cSql := " SELECT BR8_CODPAD, MAX(BR8_CODPSA) BR8_CODPSA, BR8_CLASIP, BR8_CLASP2, BG8_CODGRU, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,  BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " BFE_CODGRU, BFE_DATCAR, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " BFC_CODGRU, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " BT7_CARENC, BT7_UNCAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " BRV_CODGRU,BG8_CARENC, BG8_UNCAR, BG8_CLACAR, BG8_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "

		cSql += " FROM " + RetSqlName("BR8") + " BR8 "
		//LIGAR DIRETAMENTE NO PROCEDIMENTO PARA OBTER OS GRUPOS DE COBERTURA DE CADA UM...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BG8") + " BG8 "
		cSql += " ON BG8_FILIAL = '" + xFilial("BG8") + "' "
		cSql += " AND BG8_CODPAD = BR8_CODPAD "
		cSql += " AND BG8_CODPSA = BR8_CODPSA "
		cSql += " AND BG8.D_E_L_E_T_ = ' '  "


		//COBERTURA NO USUARIO - CLasse de carência no beneficiário
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFO") + " BFO "
		cSql += " ON BFO_FILIAL = '" + xFilial("BFO") + "' "
		cSql += " AND BFO_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFO_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFO_MATRIC = '"+cMatric+"' "
		cSql += " AND BFO_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFO_CLACAR = BR8_CLACAR "
		cSql += " AND BFO.D_E_L_E_T_ = ' '  "

		//COBERTURA NO USUARIO - PROCEDIMENTOS EXCLUSIVOS PARA O BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFG") + " BFG "
		cSql += " ON BFG_FILIAL = '" + xFilial("BFG") + "' "
		cSql += " AND BFG_CODPAD = BR8_CODPAD "
		cSql += " AND BFG_CODPSA = BR8_CODPSA "
		cSql += " AND BFG_CODINT = '"+cOpeUsr+"' "
		cSql += " AND BFG_CODEMP = '"+cCodEmp+"' "
		cSql += " AND BFG_MATRIC = '"+cMatric+"' "
		cSql += " AND BFG_TIPREG = '"+cTipReg+"' "
		cSql += " AND BFG.D_E_L_E_T_ = ' '  "

		//GRUPO DE COBERTURA NO USUARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFE") + " BFE "
		cSql += " ON BFE_FILIAL = '" + xFilial("BFE") + "' "
		cSql += " AND BFE_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFE_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFE_MATRIC = '" + cMatric + "' "
		cSql += " AND BFE_TIPREG = '" + cTipReg + "' "
		cSql += " AND BFE_CODGRU = BG8_CODGRU "
		cSql += " AND BFE.D_E_L_E_T_ = ' '  "

		//COBERTURA FAMILIA - EXCLUSIVOS DE PROCEDIMENTOS NA FAMILIA...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFD") + " BFD "
		cSql += " ON BFD_FILIAL = '" + xFilial("BFD") + "' "
		cSql += " AND BFD_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFD_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFD_MATRIC = '" + cMatric + "' "
		cSql += " AND BFD_CODPAD = BR8_CODPAD "
		cSql += " AND BFD_CODPSA = BR8_CODPSA "
		cSql += " AND BFD.D_E_L_E_T_ = ' '  "

		//GRUPOS DE COBERTURA CONTIDOS NA FAMILIA...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BFC") + " BFC "
		cSql += " ON BFC_FILIAL = '" + xFilial("BFC") + "' "
		cSql += " AND BFC_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BFC_CODEMP = '" + cCodEmp + "' "
		cSql += " AND BFC_MATRIC = '" + cMatric + "' "
		cSql += " AND BFC_CODGRU = BG8_CODGRU "
		cSql += " AND BFC.D_E_L_E_T_ = ' '  "

		//OBTEM PROCEDIMENTOS PARAMETRIZADOS EXCLUSIVOS NO CONTRATO/SUBCONTRATO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BT8") + " BT8 "
		cSql += " ON BT8_FILIAL = '" + xFilial("BT8") + "' "
		cSql += " AND BT8_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BT8_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BT8_NUMCON = '" + cNumCon + "' "
		cSql += " AND BT8_VERCON = '" + cVerCon + "' "
		cSql += " AND BT8_SUBCON = '" + cSubCon + "' "
		cSql += " AND BT8_VERSUB = '" + cVerSub + "' "
		cSql += " AND BT8_CODPRO = '" + cCodPro + "' "
		cSql += " AND BT8_VERPRO = '" + cVerPro + "' "
		cSql += " AND BT8_CODPAD = BR8_CODPAD "
		cSql += " AND BT8_CODPSA = BR8_CODPSA "
		cSql += " AND BT8.D_E_L_E_T_ = ' '  "

		cSql += " LEFT OUTER JOIN " + RetSqlName("BA6") + " BA6 "
		cSql += " ON BA6_FILIAL = '" + xFilial("BA6") + "' "
		cSql += " AND BA6_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BA6_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BA6_NUMCON = '" + cNumCon + "' "
		cSql += " AND BA6_VERCON = '" + cVerCon + "' "
		cSql += " AND BA6_SUBCON = '" + cSubCon + "' "
		cSql += " AND BA6_VERSUB = '" + cVerSub + "' "
		cSql += " AND BA6_CODPRO = '" + cCodPro + "' "
		cSql += " AND BA6_VERPRO = '" + cVerPro + "' "
		cSql += " AND BA6_CLACAR = BR8_CLACAR "
		cSql += " AND BA6.D_E_L_E_T_ = ' '  "

		//OBTEM GRUPOS DE COBERTURA EXCLUSIVOS DO CONTRATO/SUBCONTRATO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BT7") + " BT7 "
		cSql += " ON BT7_FILIAL = '" + xFilial("BT7") + "' "
		cSql += " AND BT7_CODINT = '" + cOpeUsr + "' "
		cSql += " AND BT7_CODIGO = '" + cCodEmp + "' "
		cSql += " AND BT7_NUMCON = '" + cNumCon + "' "
		cSql += " AND BT7_VERCON = '" + cVerCon + "' "
		cSql += " AND BT7_SUBCON = '" + cSubCon + "' "
		cSql += " AND BT7_VERSUB = '" + cVerSub + "' "
		cSql += " AND BT7_CODPRO = '" + cCodPro + "' "
		cSql += " AND BT7_VERPRO = '" + cVerPro + "' "
		cSql += " AND BT7_CODGRU = BG8_CODGRU "
		cSql += " AND BT7.D_E_L_E_T_ = ' '  "

		//OBTEM CARENCIAS POR PROCEDIMENTO NO PRODUTO DO BENEFICIARIO
		cSql += " LEFT OUTER JOIN " + RetSqlName("BB2") + " BB2 "
		cSql += " ON BB2_FILIAL = '" + xFilial("BB2") + "' "
		cSql += " AND BB2_CODIGO = '" + cOpeUsr + cCodPro + "' " //OPERADORA E PRODUTO
		cSql += " AND BB2_VERSAO = '" + cVerPro + "' "
		cSql += " AND BB2_CODPAD = BR8_CODPAD "
		cSql += " AND BB2_CODPSA = BR8_CODPSA "
		cSql += " AND BB2_BENUTL = '1' " //SOMENTE OS ATIVOS
		cSql += " AND BB2.D_E_L_E_T_ = ' '  "

		//GRUPOS DE COBERTURA DO PRODUTO DO BENEFICIARIO...
		cSql += " LEFT OUTER JOIN " + RetSqlName("BRV") + " BRV "
		cSql += " ON BRV_FILIAL = '" + xFilial("BRV") + "' "
		cSql += " AND BRV_CODPLA = '" + cOpeUsr + cCodPro + "' " //OPERADORA + PRODUTO
		cSql += " AND BRV_VERSAO = '" + cVerPro + "' "
		cSql += " AND BRV_CODGRU = BG8_CODGRU "
		cSql += " AND BRV.D_E_L_E_T_ = ' '  "

		//LEMBRETE CASO O PRODUTO SEJA CONSIDERA PADRAO = SIM, DEVE-SE PEGAR TAMBEM COMO COBERTURA/CARENCIA OS DADOS DA BR8
		cSql += " WHERE BR8_FILIAL = '" + xFilial("BR8") + "' "
		cSql += " AND (BR8_CLASIP <> ' ' OR BR8_CLASP2 <> ' ') "
		cSql += " AND BR8_BENUTL = '1' "

		//CASO SEJA PARAMETRIZADO SOMENTE COM PROCEDIMENTOS, HABILITAR O PARAMETRO ABAIXO (MAIOR DESEMPENHO).
		If GetNewPar("MV_PLFCSOP","0") == "1"
			cSql += " AND BR8_TPPROC = '"+TP_PROCEDIM+"' "
		EndIf

		//CAMPO CRIADO PARA CONFIGURAR SE CONSIDERA OU NAO NO CALCULO DE BENEF EXPOSTOS
		cSql += " AND BR8_FCAREN = '1' "
		cSql += " AND BR8.D_E_L_E_T_ = ' '  "
		//GROUP BY PARA REDUZIR CLASSIFICACOES REPETIDAS
		cSql += " GROUP BY BR8_CODPAD, BR8_CLASIP, BR8_CLASP2, BG8_CODGRU, BR8_REGATD, "
		cSql += " BFO_CARENC, BFO_UNICAR,BFO_CLACAR, BFO_DATCAR, "
		cSql += " BFG_CARENC, BFG_UNCAR,  BFG_CLACAR, BFG_DATCAR, BFG_BENUTL, "
		cSql += " BFE_CODGRU, BFE_DATCAR, "
		cSql += " BFD_CARENC, BFD_UNCAR, BFD_CLACAR, BFD_BENUTL, "
		cSql += " BFC_CODGRU, "
		cSql += " BT8_CARENC, BT8_UNCAR, BT8_CLACAR, BT8_BENUTL, "
		cSql += " BA6_CARENC, BA6_UNICAR, BA6_CLACAR, "
		cSql += " BT7_CARENC, BT7_UNCAR, "
		cSql += " BB2_CARENC, BB2_UNCAR, BB2_CLACAR, BB2_BENUTL, "
		cSql += " BRV_CODGRU,BG8_CARENC, BG8_UNCAR, BG8_CLACAR, BG8_BENUTL, "
		cSql += " BR8_CARENC, BR8_UNCAR, BR8_CLACAR "
	Endif

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCAR",.F.,.T.)

	//PlsLogFil("query CarregaCarencia"+ CENDTHRL("I") + cSql,DEBUG_EXP)

	If TRBCAR->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PLSNioInCo

	Funcao criada para alimentar a tabela de carencia x beneficiario B3O

	@param cRegANS		Numero de registro da operadora na ANS
	@param cMatric		Matricula do beneficiario na operadora
	@param cItem		Codigo do item assistencial
	@param nDiasCob	Quantidade de dias coberto
	@param cCodObri	Chave da obrigacao
	@param cCodComp	Chave do compromisso
	@param cAno			Ano do compromisso
	@param nOpe			Codigo da operacao 3-Inclui ou 4-Altera

	@return lRetorno	Indica se .T. inclui ou nao .F. carencia para o beneficiario

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PLSNioInCo(cRegANS,cMatric,cItem,nDiasCob,cCodObri,cCodComp,cAno,nOpe)
	Local lRetorno		:= .T.
	Default cRegANS		:= ""
	Default cMatric		:= ""
	Default cItem		:= ""
	Default cCodObri	:= ""
	Default cCodComp	:= ""
	Default cAno		:= ""
	Default nDiasCob	:= 0
	Default nOpe		:= MODEL_OPERATION_INSERT

	RecLock("B3O",.T.)
	B3O->B3O_FILIAL := xFilial('B3O')
	B3O->B3O_CODOPE := cRegANS
	B3O->B3O_MATRIC := cMatric
	B3O->B3O_ITEM := cItem
	B3O->B3O_DIACOB := nDiasCob
	B3O->B3O_CDOBRI := cCodObri
	B3O->B3O_CDCOMP := cCodComp
	B3O->B3O_ANO := cAno
	B3O->(msUnLock())

Return lRetorno

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} SomaExpTot

	Funcao criada para somar o total de dias dos beneficiarios expostos

	@param aExpTot		Matriz com [1] classificacao, [2] dias coberto, [3] tipo de plano, [4] segmentacao, [5] matricula
	@param cClaSip		Classificacao do SIP
	@param nDiasCob	Quantidade de dias coberto
	@param cTpPlan		Tipo de plano / forma de contratacao
	@param cCodSeg		Segmentacao do plano
	@param cMatric		Matricula do beneficiario

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function SomaExpTot(aExpTot,cClaSip,nDiasCob,cTpPlan,cCodSeg,cMatric)
	Local nPos := 0

	nPos := aScan(aExpTot,{|x| x[1]+x[3]+x[4]+x[5] == cClaSip+cTpPlan+cCodSeg+cMatric})

	If nPos > 0
		aExpTot[nPos,2] += nDiasCob
	Else
		aAdd(aExpTot,{cClaSip,nDiasCob,cTpPlan,cCodSeg,cMatric})
	EndIf

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PlsAtuMonitor

	Funcao criada para atualizar mensagem de observacao no servidor

	@param nQtdeReg		Quantidade de registros processados
	@param cMsg			Mensagem informativa

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PlsAtuMonitor(cMsg)
	Default cMsg		:= ""

	PtInternal(1,AllTrim(cMsg))

Return Nil
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ListaBenef

	Funcao criada para criar os ranges de beneficiarios a serem processados em cada job de expostos

	@param cDataRef		Data de inicio do periodo a ser apurado

	@return aBenef		Matriz com os 6 (seis) ranges de beneficiarios

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ListaBenef(cDataRef)
	Local aBenef 	:= {}
	Local cSql		:= ""
	Local cWhere	:= ""//" AND BA1_CODINT = '0001' AND BA1_CODEMP = '0001' AND BA1_MATRIC = '009681' AND BA1_TIPREG = '00' AND BA1_DIGITO = '3' "
	Local nProcAux	:= 0
	Local nJ		:= 0
	Local cDb       := Alltrim(Upper(TCGetDb()))

	cSql := "SELECT "
	cSql += " COUNT(1) QTDE "
	cSql += " FROM "
	cSql += " " + RetSqlName("BA1") + " BA1 "
	cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
	cSql += "     BT5_FILIAL = BA1_FILIAL "
	cSql += "     AND BT5_CODINT = BA1_CODINT "
	cSql += "     AND BT5_CODIGO = BA1_CODEMP "
	cSql += "     AND BT5_NUMCON = BA1_CONEMP "
	cSql += "     AND BT5_VERSAO = BA1_VERCON "
	cSql += "     AND BT5_INFANS = '1' "
	cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
	cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
	cSql += "     BQC_FILIAL = BT5_FILIAL "
	if cDb $ "ORACLE/POSTGRES"
		cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
	Else
		cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
	Endif
	cSql += "     AND BQC_NUMCON = BT5_NUMCON "
	cSql += "     AND BQC_VERCON = BT5_VERSAO "
	cSql += "     AND BQC_SUBCON = BA1_SUBCON "
	cSql += "     AND BQC_VERSUB = BA1_VERSUB "
	cSql += "     AND BQC_INFANS = '1' "
	cSql += "     AND BQC.D_E_L_E_T_ = ' ' "
	cWhere += " WHERE "
	cWhere += " BA1_FILIAL = '" + xFilial("BA1") + "' "
	cWhere += " AND BA1_INFANS = '1' "
	cWhere += " AND (BA1_DATBLO = '"+ Space(8) +"' OR BA1_DATBLO >= '" + DataTrimestre(cDataRef) + "') "
	cWhere += " AND BA1.D_E_L_E_T_ = ' '  "
	cSql += cWhere

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TEMP",.F.,.T.)

	If !TEMP->(Eof())
		nQtd := TEMP->QTDE
		TEMP->(dbCloseArea())

		cSql := " SELECT BA1.R_E_C_N_O_ RECNO "
		cSql += " FROM " + RetSqlName("BA1") + " BA1 "
		cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
		cSql += "     BT5_FILIAL = BA1_FILIAL "
		cSql += "     AND BT5_CODINT = BA1_CODINT "
		cSql += "     AND BT5_CODIGO = BA1_CODEMP "
		cSql += "     AND BT5_NUMCON = BA1_CONEMP "
		cSql += "     AND BT5_VERSAO = BA1_VERCON "
		cSql += "     AND BT5_INFANS = '1' "
		cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
		cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
		cSql += "     BQC_FILIAL = BT5_FILIAL "
		if cDb $ "ORACLE/POSTGRES"
			cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO "
		Else
			cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO "
		Endif
		cSql += "     AND BQC_NUMCON = BT5_NUMCON "
		cSql += "     AND BQC_VERCON = BT5_VERSAO "
		cSql += "     AND BQC_SUBCON = BA1_SUBCON "
		cSql += "     AND BQC_VERSUB = BA1_VERSUB "
		cSql += "     AND BQC_INFANS = '1' "
		cSql += "     AND BQC.D_E_L_E_T_ = ' ' "
		cSql += cWhere
		cSql += " ORDER BY BA1.R_E_C_N_O_ "
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TEMP",.F.,.T.)

		If !TEMP->(Eof())

			nQtdRng := nQtd / 6
			If nQtdRng > int(nQtdRng)
				nQtdRng := Int(nQtdRng) + 1
			EndIf

			nProc := 1
			nVolta := 1
			While !TEMP->(Eof()) .AND. nVolta <= 6

				aAdd(aBenef,{})

				//Guardo o primeiro Recno do range
				TEMP->(DbGoto(nProc))
				aAdd(aBenef[nVolta],TEMP->RECNO)
				//Guardo o ultimo rencno do range

				nProcAux := nProc //Somo a qtd de itens que haverá no range
				nProc += nQtdRng - 1 //Somo a qtd de itens que haverá no range
				//Por ser uma query, não consigo dar um DbGoto, então vou avançando até o registro que eu quero
				For nJ := nProcAux to nProc
					If TEMP->(Eof())
						Exit
					Else
						nRecnoAux := TEMP->RECNO
						TEMP->(dbSkip())
					EndIf

				Next nJ

				aAdd(aBenef[nVolta],nRecnoAux)

				nProc++
				nVolta++

			EndDo

		EndIf
	EndIf

	TEMP->(dbCloseArea())

Return aBenef
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PegaCIDInt

	Funcao criada para retornar o CID informado na guia de internacao

	@param cChvGuia		Chave da guia //(cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_SITUAC+BD7_FASE)

	@return cCID		Codigo do CID encontrado

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PegaCIDInt(cChvGuia)
	Local cCID			:= ""
	Default cChvGuia	:= ""
	If !Empty(cChvGuia)
		cCID := RetornaCID(cChvGuia)
	EndIf
Return AllTrim(cCID)

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} BuscaDente

	Funcao criada para retorna em qual dente foi realizado o evento do grupo I

	@param cChaveGuia	(cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO)

	@return cDente		Identificacao do dente

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function BuscaDente(cChaveGuia)
	Local cSql				:= ""
	Local cDente			:= ""
	Default cChaveGuia	:= ""

	cSql := "SELECT BE2_DENREG FROM " + RetSqlName("BE2") + " BE2, " + RetSqlName("BEA") + " BEA "
	cSql += "WHERE BE2_FILIAL = '" + xFilial("BE2") + "' AND BE2_FILIAL = '" + xFilial("BE2") + "' AND BE2_OPEMOV = BEA_OPEMOV AND BE2_ANOAUT = BEA_ANOAUT AND BE2_MESAUT = BEA_MESAUT AND BE2_NUMAUT = BEA_NUMAUT "
	cSql += "AND BEA_OPEMOV = '" + SubStr(cChaveGuia,1,4) + "' AND BEA_CODLDP = '" + SubStr(cChaveGuia,5,4) + "' AND BEA_CODPEG = '" + SubStr(cChaveGuia,9,8) + "' AND BEA_NUMGUI = '" + SubStr(cChaveGuia,17,8) + "' "
	cSql += "AND BEA_ORIMOV = '" + SubStr(cChaveGuia,25,1) + "' AND BE2.D_E_L_E_T_ = ' '  AND BEA.D_E_L_E_T_ = ' '  "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"DENT",.F.,.T.)

	If !DENT->(Eof())
		cDente := DENT->BE2_DENREG
	EndIf

	DENT->(dbCloseArea())

Return cDente
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} AtuPrinc

	Funcao criada para atualizar o evento principal da guia com os valores de eventos sem classificacao

	@param aProSemCla	Matriz com informacoes dos procedimentos nao classificados

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function AtuPrinc(aProSemCla,nQtdRegPro,cCabLog,lCapit)
	Local cSql			:= ""
	Local aGuia			:= {}
	Local nFor			:= 0
	Local nVlrEve		:= 0
	Local lDesp 		:= IsInCallStack("PLSIPDES")
	Default aProSemCla	:= {}
	Default nQtdRegPro	:= 0
	Default cCabLog	    := " "
	Default lCapit      := .F.
	Default lDesp       := .F.

	//B3L_FILIAL+B3L_CODOPE+B3L_CODOBR+B3L_ANOCMP+[B3L_CDCOMP]+B3L_EVEDES+B3L_MATRIC+B3L_CDTPTB+B3L_CODEVE+B3L_CLAAMB+B3L_CLAINT+B3L_FORCON+B3L_SEGMEN+DTOS(B3L_DATEVE)
	//Vou filtrar a guia para montrar a matriz aGuia
	cSql := " SELECT R_E_C_N_O_ RECNO, B3Q_CLAAMB, B3Q_CLAINT, B3Q_GRPINT, B3Q_REGINT "
	cSql += " FROM " + RetSqlName("B3Q") + " "
	If BANCO == "MSSQL7"
		cSql += " WITH (NOLOCK) "
	EndIf
	cSql += " WHERE B3Q_FILIAL = '" + xFilial("B3Q") + "' "
	cSql += " 	AND B3Q_CODOPE = '" + aProSemCla[1,1] + "' "
	cSql += " 	AND B3Q_CODOBR = '" + aProSemCla[1,2] + "' "
	cSql += " 	AND B3Q_ANOCMP = '" + aProSemCla[1,3] + "' "
	cSql += " 	AND B3Q_CDCOMP = '" + aProSemCla[1,4] + "' "
	cSql += " 	AND B3Q_EVEDES = '" + aProSemCla[1,5] + "' "
	cSql += " 	AND B3Q_MATRIC = '" + aProSemCla[1,6] + "' "
	cSql += " 	AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	cSql := InsereNoLock(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TPRI",.F.,.T.)

	If !TPRI->(Eof())

		While !TPRI->(Eof())

			If Empty(TPRI->B3Q_GRPINT) .And. Empty(TPRI->B3Q_REGINT) //Nao tem como ser internacao
				aAdd(aGuia,{Iif(!Empty(TPRI->B3Q_CLAAMB),TPRI->B3Q_CLAAMB,TPRI->B3Q_CLAINT),TPRI->RECNO})
			Else
				aAdd(aGuia,{Iif(!Empty(TPRI->B3Q_CLAINT),TPRI->B3Q_CLAINT,TPRI->B3Q_CLAAMB),TPRI->RECNO})
			EndIf

			TPRI->(dbSkip())

		EndDo

		//Ordeno pelas classificacoes encontradas na guia
		aSort(aGuia,,,{ |x,y| x[1] > y[1]})

		For nFor := 1 TO Len(aProSemCla)

			nVlrEve += aProSemCla[nFor,7]//somo todos os valores dos itens sem classificacao

		Next nFor

		B3Q->(dbGoTo(aGuia[1,2]))//Posiciono no primeiro/principal item da guia
		B3Q->(RecLock("B3Q",.F.))
		B3Q->B3Q_VLREVE	+= nVlrEve//acrescento o valor somado ao item principal
		B3Q->B3Q_STATUS := '1'
		B3Q->(msUnLock())
		MarcaBD7(B3Q->B3Q_EVEDES,B3Q->B3Q_TRIREC,lCapit,lDesp)

	Else

		For nFor := 1 TO Len(aProSemCla)

			If TmpIncDesp(aProSemCla[1,1],aProSemCla[1,2],aProSemCla[1,3],aProSemCla[1,4],aProSemCla[nFor,8],,,lCapit)
				nQtdRegPro++
			Else
				PlsLogFil(cCabLog + CENDTHRL("W") + " Despesa não integrada [" + aProSemCla[1,5] + "]",ARQ_LOG_DES)
			EndIf

		Next nFor

	EndIf

	LimpaArray(aProSemCla)
	TPRI->(dbCloseArea())

Return

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PlCenCarCob

	Funcao que encapsula o carregamento de coberturas

	@description
	Sera utilizado aqui e nas funcoese do PLS que alteram o cadastro de beneficiarios

	@param cAlias		Area de trabalho corrente
	@param cMatUsu		Matricula do beneficiario na operadora
	@param cContrato	Chave completa do contrato para beneficiarios nao PF
	@param cProduto		Chave completa do produto
	@param cDatCarBen	Data de carencia encontrada para o beneficiario
	@param nIncluidos	Quantidade de registros incluidos
	@param lAtenOdon	Indicase se o produto atende .T. oun nao .F. odonto
	@param aNatSaude	Matriz de natureza de saude carregadas da tabela BF0
	@param lPodeBR8		Indica se o produto permite considerar cobertura na tabela padrao
	@param cCodIntBen	Codigo da operadora do beneficiario - BA1_CODINT
	@param cDataRef		Data de referencia do processamento do trimestre
	@param cRegANS		Numero de registro da operadora na ANS
	@param cCodObri		Codigo da obrigacao encontrada
	@param cAnoComp		Ano da competencia
	@param cCodComp		Codigo da competencia
	@param lImport		Indica se e .T. ou nao .F. importacao de uma carga inicial
	@param cSexo		Sexo do beneficiario
	@param dDatNas		Data de nascimento do beneficiario
	@param cCodSeg		Codigo da segmentacao do produto
	@param cForCon		Forma de contratacao do produto
	@param dDataBlo		Data de bloqueio do beneficiario

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Function PlCenCarCob(cAlias,cMatUsu,cContrato,cProduto,cDatCarBen,nIncluidos,lAtenOdon,aNatSaude,lPodeBR8,cCodIntBen,;
		cDataRef,cRegANS,cCodObri,cAnoComp,cCodComp,lImport,cSexo,dDatNas,cCodSeg,cForCon,dDataBlo)

	Local cClaSIP		:= ""
	Local cDatCar		:= ""
	Local cUnCar		:= ""
	Local cClaCar 		:= ""
	Local nCarenc		:= 0
	Local nPosCar		:= 0
	Local nFor			:= 0
	Local lTemCob		:= .F.
	Local lIdade		:= .F.
	Local lSexo			:= .F.
	Local dDtIniTri		:= STOD(DataTrimestre(cDataRef,"1"))
	Local dDtFinTri		:= STOD(DataTrimestre(cDataRef,"2"))
	Local aSomaTotal	:= {}
	Local aDadCob		:= {}
	Local aNatSauBkp	:= {}
	Local lMV_PLCENDB	:= MV_PLCENDB
	Local aNatSaIte		:= {}
	Local nPosIte		:= 0
	Local lAchou        := .F.

	Default lAtenOdon	:= .F.
	Default lPodeBR8	:= .F.
	Default aNatSaude	:= {}
	Default cRegANS		:= '000000'
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cCodComp	:= ""
	Default lImport		:= .T.
	Default dDataBlo	:= StoD("")

	cDatCar	:= cDatCarBen
	nIdade	:= Calc_Idade(dDataBase,dDatNas)

	If Len(aNatSaude) == 0
		aNatSaude := PegaNatSaude()//carrego as naturezas de saude no formato {Codigo,0, / / ,Idade Ini,Idade Fin,Sexo,Nivel}
	EndIf
	aNatSauBkp := aClone(aNatSaude)
	//Vou criar a area de trabalho TRBCAR com as carencias do beneficiario se houver
	If CarregaCarencia(cAlias,cMatUsu,cContrato,cProduto)

		While !TRBCAR->(Eof())

			cClaSIP		:= Iif(TRBCAR->BR8_REGATD <> '2', TRBCAR->BR8_CLASIP, TRBCAR->BR8_CLASP2)
			nPosCar		:= aScan(aNatSaude,{|x| x[1] == cClaSIP})
			//PlsLogFil("Procurando cobertura para o procedimento " + TRBCAR->(BR8_CODPAD+BR8_CODPSA) + CENDTHRL("I"),DEBUG_EXP)
			If (Left(cClaSIP,1) == "I" .And. !lAtenOdon) .Or. nPosCar <= 0//Devo despresar itens I que o produto nao atende odonto ou se nao encontrou a classificacao no aNatSaude
				TRBCAR->(dbSkip())
				Loop
			EndIf

			//Caso a classificacao seja subgrupo, deve-se verificar se o item sera mais adequado por tratar-se de idade e sexo...
			If nPosCar > 0
				If aNatSaude[nPosCar,NAT_NIVEL] == '2'//Nivel - 1=Grupo;2=Subgrupo;3=Item

					aNatSaIte	:= NatSaudeItem(aNatSaude,cClaSIP)
					nPosIte		:= aScan(aNatSaIte,{|x| x[1] == cClaSIP})

					If nPosIte > 0

						lIdade	:= (aNatSaude[nPosIte,NAT_IDADE]+aNatSaude[nPosIte,NAT_IDADE2] == 0) .Or. (nIdade >= aNatSaude[nPosIte,NAT_IDADE] .And. nIdade <= aNatSaude[nPosIte,NAT_IDADE2])
						lSexo	:= Empty(cSexo) .Or. (cSexo == aNatSaIte[nPosIte,6])

						If lIdade .And. lSexo//Atualizao cClaSIP e nPosCar se achei um item que trata sexo e idade
							cClaSIP	:= aNatSaIte[nPosIte,NAT_CODIGO]
							aNatSaude[nPosCar,NAT_DATCAR] := STOD("19990101")
							nPosCar	:= nPosIte
						EndIf

					Else

						lIdade	:= (aNatSaude[nPosCar,NAT_IDADE]+aNatSaude[nPosCar,NAT_IDADE2] == 0) .Or. (nIdade >= aNatSaude[nPosCar,NAT_IDADE] .And. nIdade <= aNatSaude[nPosCar,NAT_IDADE2])
						lSexo	:= Empty(aNatSaude[nPosCar,NAT_SEXO]) .Or. (cSexo == aNatSaude[nPosCar,NAT_SEXO])

						If !lIdade .Or. !lSexo
							aNatSaude[nPosCar,NAT_DATCAR] := STOD("")
							//PlsLogFil("Nao tem cobertura para o item. Regra de idade e sexo " + cClaSIP + CENDTHRL("I"),DEBUG_EXP)
							nPosCar := 0
						EndIf

					EndIf

				Else

					lIdade	:= (aNatSaude[nPosCar,NAT_IDADE]+aNatSaude[nPosCar,NAT_IDADE2] == 0) .Or. (nIdade >= aNatSaude[nPosCar,NAT_IDADE] .And. nIdade <= aNatSaude[nPosCar,NAT_IDADE2])
					lSexo	:= Empty(aNatSaude[nPosCar,NAT_SEXO]) .Or. (cSexo == aNatSaude[nPosCar,NAT_SEXO])

					If !lIdade .Or. !lSexo
						aNatSaude[nPosCar,NAT_DATCAR] := STOD("")
						//PlsLogFil("Nao tem cobertura para o item. Regra de idade e sexo 2" + cClaSIP + CENDTHRL("I"),DEBUG_EXP)
						nPosCar := 0
					EndIf

				EndIf
			Else
				//PlsLogFil("Nao tem cobertura para o item " + cClaSIP + CENDTHRL("I"),DEBUG_EXP)
			EndIf

			If nPosCar == 0
				lTemCob		:= .F.
				cDatCar	:= cDatCarBen
				nCarenc		:= 0
				cUnCar		:= ""
				cClaCar		:= ""
			Else

				nCarenc := 0
				cUnCar  := ""
				cClaCar := ""
				lAchou  := .F.
				lTemCob	:= .F.

				If !Empty(TRBCAR->BFO_UNICAR) .And. !Empty(TRBCAR->BFO_CLACAR) .And. !Empty(TRBCAR->BFO_DATCAR)
					nCarenc := TRBCAR->BFO_CARENC
					cUnCar  := TRBCAR->BFO_UNICAR
					cClaCar := TRBCAR->BFO_CLACAR
					lAchou  := .T.
					lTemCob	:= .T.
				EndIf

				Do Case
					//Se encontrar parametrizacao para o procedimento, tem cobertura e ve a carencia...
				Case TRBCAR->BFD_BENUTL == "1" .And. !lTemCob
					If !Empty(TRBCAR->BFD_UNCAR) .Or. !Empty(TRBCAR->BFD_CLACAR)
						nCarenc := TRBCAR->BFD_CARENC
						cUnCar  := TRBCAR->BFD_UNCAR
						cClaCar := TRBCAR->BFD_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BFD",DEBUG_EXP)
					Else
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBFD",DEBUG_EXP)
					EndIf
					lTemCob	:= .T.
					//Se encontrar o grupo de cobertura na familia, tem cobertura.
				Case !Empty(TRBCAR->BFC_CODGRU) .And. !lTemCob
					lTemCob := .T.
					//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BFC",DEBUG_EXP)
					//Se encontrar o procedimentos no contrato/sub, tem cobertura...
				Case TRBCAR->BT8_BENUTL == "1" .And. !lTemCob
					If !Empty(TRBCAR->BT8_UNCAR) .Or. !Empty(TRBCAR->BT8_CLACAR)
						nCarenc := TRBCAR->BT8_CARENC
						cUnCar  := TRBCAR->BT8_UNCAR
						cClaCar := TRBCAR->BT8_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BT8",DEBUG_EXP)
					Else
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBT8",DEBUG_EXP)
					EndIf
					lTemCob	:= .T.
					//Se encontrar o grupo de cobertura no contrato/sub, tem cobertura...

				Case !lTemCob .And. (!Empty(TRBCAR->BA6_UNICAR) .Or. !Empty(TRBCAR->BA6_CLACAR))
					nCarenc := TRBCAR->BA6_CARENC
					cUnCar  := TRBCAR->BA6_UNICAR
					cClaCar := TRBCAR->BA6_CLACAR

					lTemCob	:= .T.
					lAchou  := .T.

				Case !Empty(TRBCAR->BT7_UNCAR) .And. !lTemCob
					nCarenc := TRBCAR->BT7_CARENC
					cUnCar  := TRBCAR->BT7_UNCAR
					lTemCob	:= .T.
					lAchou  := .T.

					//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BT7",DEBUG_EXP)
					//Se encontrar parametrizacao diretamente no produto do usuario, tem cobertura e ve a carencia...
				Case TRBCAR->BB2_BENUTL == "1" .And. !lTemCob

					If !Empty(TRBCAR->BB2_UNCAR) .Or. !Empty(TRBCAR->BB2_CLACAR)
						nCarenc := TRBCAR->BB2_CARENC
						cUnCar  := TRBCAR->BB2_UNCAR
						cClaCar := TRBCAR->BB2_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BB2",DEBUG_EXP)
					Else
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBB2",DEBUG_EXP)
					EndIf
					lTemCob	:= .T.

					//Se encontrar o grupo de cobertura no produto, tem cobertura.
				Case TRBCAR->BG8_BENUTL == "1" .And. !lTemCob
					If !Empty(TRBCAR->BG8_UNCAR) .Or. !Empty(TRBCAR->BG8_CLACAR)//TODO aqui talvez seja And pois esta vindo UNCAR vazio
						nCarenc := TRBCAR->BG8_CARENC
						cUnCar  := TRBCAR->BG8_UNCAR
						cClaCar := TRBCAR->BG8_CLACAR
						lAchou  := .T.
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BG8",DEBUG_EXP)
					Else
						//If !Empty(TRBCAR->BRV_CODGRU)
						nCarenc := 0
						cUnCar  := "2"
						cClaCar := ""
						//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "NBG8",DEBUG_EXP)
						//Else
						//nCarenc := 0
						//cUnCar  := "2"
						//cClaCar := ""
						//EndIf
					EndIf
					lTemCob	:= .T.

					//Se encontrar o grupo de cobertura no produto, tem cobertura.
				Case (!Empty(TRBCAR->BR8_UNCAR) .Or. !Empty(TRBCAR->BR8_CLACAR)) .And. lPodeBR8  .And. !lTemCob
					nCarenc := TRBCAR->BR8_CARENC
					cUnCar  := TRBCAR->BR8_UNCAR
					cClaCar := TRBCAR->BR8_CLACAR
					//PlsLogFil("Data;" + DTOS(Date()) + ";Hora;" + Time() + ";Tab;" + "BR8",DEBUG_EXP)
					lTemCob	:= .T.

				EndCase

				//Caso tenha cobertura, calcular os dias em carencia...
				If lTemCob
					//PlsLogFil("Tem cobertura, vai calcular os dias " + CENDTHRL("I"),DEBUG_EXP)
					//Se encontrar o grupo de cobertura no usuario, tem cobertura.
					If !Empty(TRBCAR->BFE_CODGRU) .And. !Empty(TRBCAR->BFE_DATCAR) .And. !lAchou
						cDatCar := TRBCAR->BFE_DATCAR
					Endif
					If !lAchou .And. (Empty(cUnCar) .Or. (! Empty(cClaCar) .And. lPodeBR8))
						//classe de carencia dentro do protudo
						nFor := aScan(aBAN,{|x| x[1] == cProduto+cClaCar})
						If nFor > 0
							nCarenc := aBAN[nFor,2]
							cUnCar := aBAN[nFor,3]
						Else//classe de carencia
							nFor := aScan(aBDL,{|x| x[1] == cCodIntBen+cClaCar})
							If nFor > 0
								nCarenc := aBDL[nFor,2]
								cUnCar := aBDL[nFor,3]
							Else
								nCarenc := 0
								cUnCar := "2"
							EndIf
						EndIf
					EndIf

					If cUnCar $ "2,3,4" // Dias,Meses,Anos
						nDiasAux := PLSCarDias(nCarenc,cUnCar) // Calcula em dias
					Else
						nDiasAux := 1
					EndIf

					If Empty(aNatSaude[nPosCar,NAT_DATCAR])
						aNatSaude[nPosCar,NAT_DIAS] := nDiasAux
						aNatSaude[nPosCar,NAT_DATCAR] := STOD(cDatCar)
					Else
						If STOD(cDatCar)+nDiasAux > aNatSaude[nPosCar,NAT_DATCAR]+aNatSaude[nPosCar,NAT_DIAS]
							aNatSaude[nPosCar,NAT_DIAS] := nDiasAux
							aNatSaude[nPosCar,NAT_DATCAR] := STOD(cDatCar)
						EndIf
					EndIf

				Else
					If lMV_PLCENDB
						PlsLogFil(cClaSIP + ";" + cMatUsu,DEBUG_EXP)
					EndIf
				EndIf//If lTemCob

			EndIf

			TRBCAR->(dbSkip())

		EndDo//!TRBCAR->(Eof())

		For nFor := 1 To Len(aNatSaude)

			nDiasCob	:= 0//Quantidade de dias que usuario esta coberto
			if dDataBlo >= dDtIniTri .AND. dDataBlo < dDtFinTri
				dDtFinTri := dDataBlo
			Else
				dDtFinTri := dDtFinTri
			EndIf
			nDiasPer	:= dDtFinTri - dDtIniTri + 1 //Quantidade de dias do periodo / trimestre
			If !Empty(aNatSaude[nFor,NAT_DATCAR]) //Data de carencia
				If aNatSaude[nFor,NAT_DATCAR] <= STOD(cDataRef) //A data e inferior a data de referencia
					nDiasCob := dDtFinTri-(aNatSaude[nFor,NAT_DATCAR]+aNatSaude[nFor,NAT_DIAS])//Data final do trimestre - data de carencia mais quantidade de dias
				Else
					nDiasCob := nDiasPer//Como a data de carencia e posterior a data de referencia o beneficiario esta coberto durante todo o periodo
				EndIf
				If nDiasCob > nDiasPer
					nDiasCob := (dDtFinTri-dDtIniTri) + 1
				EndIf
				nDiasCob := Iif(nDiasCob > 0,nDiasCob, 0)
				SomaExpTot(@aSomaTotal,aNatSaude[nFor,NAT_CODIGO],nDiasCob,cForCon,cCodSeg,cMatUsu)
			EndIf

		Next nFor
	Else
		//PlsLogFil("Nao encontrou config de cobertura " + CENDTHRL("I"),DEBUG_EXP)
	EndIf//If CarregaCarencia()

	TRBCAR->(dbCloseArea())

	For nFor := 1 To Len(aSomaTotal)

		cItem	:= aSomaTotal[nFor,1]
		nQtdBen	:= aSomaTotal[nFor,2]
		cForCon	:= aSomaTotal[nFor,3]
		cCodSeg	:= aSomaTotal[nFor,4]
		cMatric	:= aSomaTotal[nFor,5]

		If lImport
			If !ExisteDespesa(cRegANS,cCodObri,cAnoComp,cCodComp,"",cMatric,"TRBEXP",cItem,{})
				If PLSNioInCo(cRegANS,cMatric,cItem,nQtdBen,cCodObri,cCodComp,SubStr(cTriRec,1,4),MODEL_OPERATION_INSERT)
					nIncluidos++
				Else
					PlsLogFil("PLSIPEXP" + CENDTHRL("W") + " nao foi possivel incluir carencia para: " + cMatric,ARQ_LOG_DES)
				EndIf
			EndIf
		Else
			aAdd(aDadCob,{cRegANS,cMatric,cItem,nQtdBen})
		EndIf

	Next nFor

	LimpaArray(@aSomaTotal)
	aNatSaude := aClone(aNatSauBkp)

Return aDadCob
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} TrataPacote

	Funcao criada para abrir os pacotes e chamar as funcoes de classificacao

	@param cAliPct		Alias de trabalho corrente
	@param cRegANS		Numero de registro da operadora na ANS
	@param cChaveGuia	Chave da guia
	@param cTipData	1-Digitacao,2-Pagamento,3-Procedimento
	@param nQtdRegPro	Quantidade de registros processados a ser atualizado
	@param cCodObri	Chave da obrigacao
	@param cAnoComp	Ano do compromisso
	@param cCodComp 	Chave do compromisso

	@return VarRetorno Descriacao do retorno

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function TrataPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv,lMV_STATISS)
	Local aClasEven		:= {} //Matriz com dados da classificacao do evento
	Local nQtdPacote	:= 0
	Local cDataProc		:= Iif( !Empty((cAlias)->BD7_DATPRO),(cAlias)->BD7_DATPRO,(cAlias)->BD6_DATPRO )
	Local nIdade 		:= Calc_Idade(STOD(cDataProc),STOD((cAlias)->BA1_DATNAS))
	Local cAliPct		:= "TRBPCT"
	Local cChaveGuia	:= ""
	Local lIncDesp		:= .F.
	Default cAlias		:= "TRBDES"
	Default cDataRef	:= ""
	Default cTipData	:= "1"
	Default cRegANS		:= ""
	Default nThread		:= 0
	Default aBenef		:= {}
	Default nQuinzena	:= {}
	Default lCount		:= .F.
	Default cLocDigIgn	:= ""
	Default lQryInter	:= .F.
	Default	cChvGuiGrv	:= ""
	Default	lMV_STATISS	:= MV_STATISS

	If !Empty(cChvGuiGrv)
		If CarregaPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv)

			cChaveGuia := (cAlias)->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
			aClasEspe := IniciaEspecialidade()

			While !TRBPCT->(Eof())

				If (cAliPct)->BD7_TIPGUI $ G_RES_INTER + ',' + G_HONORARIO .OR. !Empty((cAliPct)->BD5_GUIINT)

					lIncDesp := .T.
					aClasEven := ClassInternacao(cAliPct,cChaveGuia,cTipData,.T.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

				ElseIf (cAliPct)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON

					lIncDesp := .T.
					aClasEven := ClassSADT(cAliPct,cChaveGuia,cTipData,.T.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

				EndIf

				If lIncDesp

					If TmpIncDesp(cRegANS,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,aClasEven)

						nQtdPacote++

					EndIf

				Else
					cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Despesa de pacote sem classificacao"
					CenWrLogJb(cTriRec,cTxt,,CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[1])
				EndIf

				TRBPCT->(dbSkip())

			EndDo

		Else
			If (cAlias)->BD7_TIPGUI $ G_RES_INTER + ',' + G_HONORARIO .OR. !Empty((cAlias)->BD5_GUIINT)

				lIncDesp := .T.
				aClasEven := ClassInternacao(cAlias,cChvGuiGrv,cTipData,.F.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

			ElseIf (cAlias)->BD7_TIPGUI $ G_CONSULTA + ',' + G_SADT_ODON

				lIncDesp := .T.
				aClasEven := ClassSADT(cAlias,cChvGuiGrv,cTipData,.F.,nIdade,aClasEspe,cDataRef,lMV_STATISS)

			EndIf
			If lIncDesp
				If TmpIncDesp(cRegANS,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,aClasEven)
					nQtdPacote++
				EndIf
			Else
				cTxt := "Despesa;" + cChaveGuia + ";" + (cAlias)->BD7_TIPGUI + ";;Despesa sem item de pacote cadastrado e Tipo de guia invalido"
				CenWrLogJb(cTriRec,cTxt,,CENNOMJOB(nThread,nQuinzena,cAlias,lQryInter)[1])
			EndIf

		EndIf
		TRBPCT->(dbCloseArea())
	EndIf

Return nQtdPacote
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CarregaPacote

	Funcao criada para carregar os dados do pacote aberto

	@param cAlias		Area de trabalho corrente
	@param cRegANS		Numero de registro da operadora na ANS

	@return lRetorno	Retorna .T. se encontrou dados senao retorna .F.

	@author timoteo.bega
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaPacote(cAlias,cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv)
	Local lRetorno 	:= .F.

	lRetorno := CarregaDados("TRBPCT",cDataRef,cTipData,cRegANS,nThread,aBenef,nQuinzena,lCount,cLocDigIgn,lQryInter,cChvGuiGrv)

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} MesPorThread

	Funcao criada para atualizar os parametros de data inicial e final da quinzena a ser utilizado na query

	@param pDataIni	Data inicial a ser atualizada
	@param pDataFin	Data final a ser atualizada
	@param pDataRef	Data de referencia a ser utilizada para encontrar as datas anteriores
	@param pThread	Thread que esta sendo executada

	@author timoteo.bega
	@since 07/06/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function AtualizaDatas(pDataIni,pDataFin,pDataRef,pThread)
	Default pDataIni	:= DTOS(dDataBase)
	Default pDataFin	:= DTOS(dDataBase)
	Default pDataRef	:= DTOS(dDataBase)
	Default pThread		:= 1

	If pThread == 0

		If SubStr(pDataRef,5,2) $ "01,04,07,10"
			pThread := 1
		ElseIf SubStr(pDataRef,5,2) $ "02,05,08,11"
			pThread := 2
		Else
			pThread := 3
		EndIf

	EndIf

	If SubStr(pDataRef,5,2) $ "01,02,03"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "0101"
			pDataFin := SubStr(pDataRef,1,4) + "0131"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "0201"
			If Val(SubStr(pDataRef,1,4)) % 4 == 0//29
				pDataFin := SubStr(pDataRef,1,4) + "0229"
			Else
				pDataFin := SubStr(pDataRef,1,4) + "0228"
			EndIf
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "0301"
			pDataFin := SubStr(pDataRef,1,4) + "0331"
		EndIf
	ElseIf SubStr(pDataRef,5,2) $ "04,05,06"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "0401"
			pDataFin := SubStr(pDataRef,1,4) + "0430"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "0501"
			pDataFin := SubStr(pDataRef,1,4) + "0531"
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "0601"
			pDataFin := SubStr(pDataRef,1,4) + "0630"
		EndIf
	ElseIf SubStr(pDataRef,5,2) $ "07,08,09"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "0701"
			pDataFin := SubStr(pDataRef,1,4) + "0731"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "0801"
			pDataFin := SubStr(pDataRef,1,4) + "0831"
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "0901"
			pDataFin := SubStr(pDataRef,1,4) + "0930"
		EndIf
	ElseIf SubStr(pDataRef,5,2) $ "10,11,12"
		If pThread == 1
			pDataIni := SubStr(pDataRef,1,4) + "1001"
			pDataFin := SubStr(pDataRef,1,4) + "1031"
		ElseIf pThread == 2
			pDataIni := SubStr(pDataRef,1,4) + "1101"
			pDataFin := SubStr(pDataRef,1,4) + "1130"
		ElseIf pThread == 3
			pDataIni := SubStr(pDataRef,1,4) + "1201"
			pDataFin := SubStr(pDataRef,1,4) + "1231"
		EndIf
	EndIf

Return

Static Function Inicializa()

//Inicio - Tabelas utilizadas durante o processamento
	dbSelectArea("BG9")
	BG9->(dbSetOrder(1))
	dbSelectArea("BG3")
	BG3->(dbSetOrder(1))
	dbSelectArea("BG1")
	BG1->(dbSetOrder(1))
	dbSelectArea("BQU")
	BQU->(dbSetOrder(1))
	dbSelectArea("BI3")
	BI3->(dbSetOrder(1))
	dbSelectArea("BI6")
	BI6->(dbSetOrder(1))
	dbSelectArea("BII")
	BII->(dbSetOrder(1))
	dbSelectArea("BE4")
	BE4->(dbSetOrder(1))//1 - BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
	dbSelectArea("BD5")
	BD5->(dbSetOrder(1))
	dbSelectArea("BR8")
	BR8->(dbSetorder(3))
	dbSelectArea("BAQ")
	BAQ->(dbSetOrder(1))//BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
	dbSelectArea("B3K")
	B3K->(dbSetOrder(1))
	dbSelectArea("B3J")//Produtos /Planos
	B3J->(dbSetOrder(1))//B3K_FILIAL||B3K_CODOPE||B3K_MATRIC
	dbSelectArea("B3L")

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} SchedDef

	Funcao criada para definir o pergunte do schedule

	@return aParam		Parametros para a pergunta do schedule

	@author TOTVS PLS Team
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}
	Local oObj      := FWSX1Util():New()
	Local aPergunte :={}
	Local lPergNew     := .F.

	oObj:AddGroup("PLSCARDESN")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("PLSCARDESN")

	If len(apergunte) > 1
		lPergNew:=len(apergunte[2]) > 0
	endif

	IIF(!lPergNew,aParam := { "P","PLSCARDESP",,aOrdem,""},aParam := { "P","PLSCARDESN",,aOrdem,""})

	FreeObj(oObj)
	oObj := Nil

Return aParam
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} PulaBenCober

	Funcao criada para desprezar beneficiarios ja encontrados na tabela de coberturas

	@param cAlias		Nome da area de trabalho corrente
	@param cRegANS		Numero de registro da operadora na ANS

	@return lRetorno	Retorna .T. se encontrou dados senao retorna .F.

	@author TOTVS PLS Team
	@since 26/01/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function PulaBenCober(cAlias,cRegANS)
	Local lRetorno	:= .T.
	Local cSql		:= ""
	Default cAlias	:= ""
	Default cRegANS	:= ""

	If Empty(cAlias) .Or. Empty(cRegANS)
		lRetorno := .F.
	EndIf

	If lRetorno

		cSql := "SELECT B3O_MATRIC FROM " + RetSqlName("B3O") + " WHERE B3O_FILIAL = '" + xFilial("B3O") + "' AND B3O_CODOPE = '" + cRegANS + "' AND B3O_MATRIC = '" + (cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO) + "' AND D_E_L_E_T_=' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"CORBEN",.F.,.T.)

		If !CORBEN->(Eof())

			While (cAlias)->(!Eof()) .And. AllTrim((cAlias)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)) == AllTrim(CORBEN->B3O_MATRIC)
				(cAlias)->(dbSkip())
			EndDo

		EndIf

		CORBEN->(dbCloseArea())

	EndIf

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} MarcaBD7

	Funcao criada para marcar com '999999' ou desmarcar com vazio os registros BD7 importados para a central

	@return cChaveGuia	Chave da guia: BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN
	@return cMarca			Marca a ser grava no campo BD7_RECSIP

	@author timoteob.bega
	@since 05/07/2016
	/*/
//--------------------------------------------------------------------------------------------------
Static Function MarcaBD7(cChaveGuia,cMarca,lCapit, lFase,cProc,lProSemCla,lDesp)
	Local cUpdate		:= ""
	Local nRet			:= ""
	Default cChaveGuia	:= ""
	Default cMarca		:= ""
	Default lCapit      := .f.
	Default lFase       := .T.
	Default cProc       := ""
	Default lProSemCla  := .F.
	Default lDesp       := .F.

	If !Empty(cChaveGuia)

		BEGIN TRANSACTION

			cUpdate := "UPDATE " + RetSqlName("BD7") + " SET BD7_RECSIP = '" + cMarca + "' WHERE BD7_FILIAL = '" + xFilial("BD7") + "' "
			cUpdate += "AND BD7_CODOPE = '" + SubStr(cChaveGuia,1,4) + "' "
			cUpdate += "AND BD7_CODLDP = '" + SubStr(cChaveGuia,5,4) + "' "
			cUpdate += "AND BD7_CODPEG = '" + SubStr(cChaveGuia,9,8) + "' "
			cUpdate += "AND BD7_NUMERO = '" + SubStr(cChaveGuia,17,8) + "' "
			cUpdate += "AND BD7_ORIMOV = '" + SubStr(cChaveGuia,25,1) + "' "

			If lDesp
				cUpdate += "AND BD7_NFE = ' ' "
			EndIf

			If !Empty(cProc) .And. !lProSemCla
				cUpdate += "AND BD7_CODPAD = '" + SubStr(cProc,1,2) + "' "
				cUpdate += "AND BD7_CODPRO = '" + SubStr(cProc,3,Len(Alltrim(cProc))) + "' "
			else
				cUpdate += "AND BD7_SITUAC = '" + GetNewPar("MV_PLSTSIP","1") + "' "
				cUpdate += "AND BD7_BLOPAG <> '1' "

				If !lCapit .And. lFase
					cUpdate += "AND BD7_FASE = '" + GetNewPar("MV_PLFSSIP","4") + "' "
				EndIf

			EndIf

			cUpdate += "AND D_E_L_E_T_ = ' '"
			nRet := TcSQLExec(cUpdate)
			If nRet < 0
				PlsLogFil(CENDTHRL("E") + " MarcaBD7 - " + TCSQLError(),ARQ_LOG_DES)
			Else
				TcSQLExec("COMMIT")
				//PlsLogFil(CENDTHRL("I") + " Marcou a BD7 - " + cUpdate,ARQ_LOG_DES)
			EndIf

		END TRANSACTION

	EndIf

Return


//Chamadas de funcoes para retirar os warnings de compilacao
	PulaBenCober("","")
	SchedDef()

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExisteTerapia

	Funcao criada para retornar se existe algum procedimento de terapia na guia

	@param	cChaveGuia	Chave da guia para buscar o procedimento

	@return	lRetorno		Retorna .T. quando existir algum exame do item C acompanhando uma terapia

	@author timoteob.bega
	@since 06/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteTerapia(cChaveGuia,cAlias,lMV_STATISS)
	Local cSql		:= ""
	Local cCodOpe	:= SubStr(cChaveGuia,1,4)
	Local cCodLdp	:= SubStr(cChaveGuia,5,4)
	Local cCodPeg	:= SubStr(cChaveGuia,9,8)
	Local cNumero	:= SubStr(cChaveGuia,17,8)
	Local cOrimov	:= SubStr(cChaveGuia,25,1)
	Local lRetorno	:= .F.
	Local cAliSql	:= GetNextAlias()
	Default cAlias	:= ""
	Default lMV_STATISS	:= MV_STATISS


	If !Empty(cAlias) .And. SubStr((cAlias)->BR8_CLASIP,1,1) == 'D'
		lRetorno := .T.
	EndIf

	cSql := "SELECT R_E_C_N_O_ FROM " + RetSqlName("BD6") + " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
	If !Empty(cCodOpe)
		cSql += "AND BD6_CODOPE = '" + cCodOpe + "' "
	EndIf
	If !Empty(cCodLdp)
		cSql += "AND BD6_CODLDP = '" + cCodLdp + "' "
	EndIf
	If !Empty(cCodPeg)
		cSql += "AND BD6_CODPEG = '" + cCodPeg + "' "
	EndIf
	If !Empty(cNumero)
		cSql += "AND BD6_NUMERO = '" + cNumero + "' "
	EndIf
	If !Empty(cOrimov)
		cSql += "AND BD6_ORIMOV = '" + cOrimov + "' "
	EndIf
	cSql += "AND BD6_CODPRO IN (" + TERAPIAS + ") "
	cSql += "AND BD6_FASE = '4' AND BD6_LIBERA <> '1'  AND BD6_SITUAC = '1' "

	cSql += "AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliSql,.F.,.T.)

	If !(cAliSql)->(Eof()) .Or. lRetorno
		lRetorno := .T.
	EndIf

	(cAliSql)->(dbCloseArea())

Return lRetorno
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ExisteExame

	Funcao criada para retornar se existe algum procedimento de EXAME na guia

	@param	cChaveGuia	Chave da guia para buscar o procedimento

	@return	cClaExm		Classificacao de exame encontrada na guia

	@author timoteob.bega
	@since 19/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteExame(cChaveGuia,lMV_STATISS)
	Local cSql		:= ""
	Local cCodOpe	:= SubStr(cChaveGuia,1,4)
	Local cCodLdp	:= SubStr(cChaveGuia,5,4)
	Local cCodPeg	:= SubStr(cChaveGuia,9,8)
	Local cNumero	:= SubStr(cChaveGuia,17,8)
	Local cOrimov	:= SubStr(cChaveGuia,25,1)
	Local cClaExm := ""
	Local cAliSql	:= GetNextAlias()
	Default lMV_STATISS := MV_STATISS

	cSql := "SELECT MAX(BR8_CLASIP) BR8_CLASIP FROM " + RetSqlName("BD6") + " BD6, " + RetSqlName("BR8") + " BR8 "
	cSql += "WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BR8_FILIAL = '" + xFilial("BR8") + "' "
	cSql += "AND BD6_CODPAD = BR8_CODPAD AND BR8_CODPSA = BD6_CODPRO "
	If !Empty(cCodOpe)
		cSql += "AND BD6_CODOPE = '" + cCodOpe + "' "
	EndIf
	If !Empty(cCodLdp)
		cSql += "AND BD6_CODLDP = '" + cCodLdp + "' "
	EndIf
	If !Empty(cCodPeg)
		cSql += "AND BD6_CODPEG = '" + cCodPeg + "' "
	EndIf
	If !Empty(cNumero)
		cSql += "AND BD6_NUMERO = '" + cNumero + "' "
	EndIf
	If !Empty(cOrimov)
		cSql += "AND BD6_ORIMOV = '" + cOrimov + "' "
	EndIf
	cSql += "AND BD6_FASE = '4' AND BD6_LIBERA <> '1'  AND BD6_SITUAC = '1' "

	cSql += "AND BR8_CLASIP BETWEEN 'C' AND 'C999' "
	cSql += "AND BD6.D_E_L_E_T_ = ' ' AND BR8.D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliSql,.F.,.T.)

	If !(cAliSql)->(Eof())
		cClaExm := (cAliSql)->BR8_CLASIP
	EndIf

	(cAliSql)->(dbCloseArea())

Return cClaExm
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} IniciaE1

	Funcao inicializa a matriz de eventos e classificacoes para os itens E11 ate E15
	Regras definidas baseadas na planilha da ANS de de-para SIP x TUSS de 20/06/2016

	@param	aClaIteE	Matriz a ser atualizada com os procedimentos e suas respectivas classificacoes

	@author timoteob.bega
	@since 31/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaE1(aClaIteE)
	Default aClaIteE := {}

	aAdd(aClaIteE,{"E11",{}})
	aAdd(aClaIteE,{"E121",{"31002218","31002390"}})//Cirurgia Bariatrica
	aAdd(aClaIteE,{"E122",{"31304010","31304052"}})//Laqueadura Tubaria
	aAdd(aClaIteE,{"E123",{"31205046","31205070"}})//Vasectomia
	aAdd(aClaIteE,{"E124",{"30725127","30725135","30725160","30725100","30725119","30725194","30724058","30724066","30724074","30724082","30724171","30724180"}})//Fratura de femur > 60 anos
	aAdd(aClaIteE,{"E125",{"30724279","30726255","30717159"}})//Revisao de artroplastia
	aAdd(aClaIteE,{"E126",{"30904021","30904161",}})//Implante de CDI
	aAdd(aClaIteE,{"E127",{"30904145","30904137","30904099","30904080","30904064"}})//Implantacao de marcapasso
	aAdd(aClaIteE,{"E131",{"31309127","31309135"}})//Parto normal
	aAdd(aClaIteE,{"E132",{"31309054","31309208"}})//Parto cesareo
	aAdd(aClaIteE,{"E14",{}})
	aAdd(aClaIteE,{"E15",{}})

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ClasItemE

	Funcao criada para retornar a classificacoes dos itens E11 ate E15

	@param	aClaIteE	Matriz com os procedimentos e suas respectivas classificacoes
	@param	cItemE		Item que sera classificado
	@param	cCdPrc		Codigo do procedimento
	@param	cClaSIPInt	Classificacao de internacao e retorno da funcao

	@return	cClaSIPInt	Classificacao de internacao e retorno da funcao

	@author timoteob.bega
	@since 31/07/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ClasItemE(aClaIteE,cItemE,cCdPrc,cClaSIPInt,nIdade)
	Local nPosIte		:= 0
	Local nFor			:= 0
	Default aClaIteE	:= {}
	Default cItemE		:= ""
	Default cCdPrc		:= ""
	Default cClaSIPInt	:= ""
	Default nIdade		:= 0

	For nFor := 1 TO Len(aClaIteE)

		nPosIte := aScan(aClaIteE[nFor,2],{|x| x == cCdPrc})

		If nPosIte > 0
			cClaSIPInt := aClaIteE[nFor,1]
			Exit
		EndIf

	Next nFor

	If Empty(cClaSIPInt) .Or. Alltrim(cClaSIPInt) == "E141"
		If Alltrim(cClaSIPInt) == "E141"
			cClaSIPInt := "E11XX"
		Else
			cClaSIPInt := SubStr(cItemE,1,3)
		EndIf
	EndIf

	If cClaSIPInt == "E124" .And. nIdade < 60
		cClaSIPInt := "E12"
	EndIf

Return cClaSIPInt
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} LimpaArray

	Funcao criada para limpar array

	@param	aTemp	Array a ser limpo

	@author timoteob.bega
	@since 09/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function LimpaArray(aTemp)
	Local nForArr	:= 0

	If Len(aTemp) > 0

		For nForArr := 1 TO Len(aTemp)
			aDel(aTemp,nForArr)
		Next nForArr

		ASize(aTemp,0)
		aTemp := {}

	EndIf

Return
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} InsereNoLock

	Funcao criada para inserir clausula na query de consulta

	@param	cSql	Query a ser atualizada

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function InsereNoLock(cSql)
	Default cSql := ""

	cSql := StrTran(cSql,"WITH"," WITH (NOLOCK) ")

Return cSql
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ClassificaEspecialidade

	Funcao criada para classificar a especialidade baseada na matriz de especialidade

	@param	cCodEspMed	Chave da especialidade
	@param	aClasEspe	Matriz de especialidade

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ClassificaEspecialidade(cCodEspMed,aClasEspe)
	Local nEspe				:= 0
	Local cClaSIPEsp		:= ""
	Default cCodEspMed	:= ""
	Default aClasEspe	:= {}

	nEspe := aScan(aClasEspe,{|x| x[1] == cCodEspMed})

	If nEspe == 0 .And. BAQ->(msSeek(xFilial("BAQ")+cCodEspMed)) .And. !Empty(BAQ->BAQ_ESPSP2)
		cClaSIPEsp := BAQ->BAQ_ESPSP2
		aAdd(aClasEspe,{BAQ->(BAQ_CODINT+BAQ_CODESP),BAQ->BAQ_ESPSP2})
	ElseIf  nEspe > 0
		cClaSIPEsp := aClasEspe[nEspe,2]
	Else
		cClaSIPEsp := ""
	EndIf

Return cClaSIPEsp
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} IniciaEspecialidade

	Funcao criada para inserir a especialidade na matriz de especialidade para classificacao de consultas

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaEspecialidade()
	Local aClasEspe	:= {}
	Local cSql			:= "SELECT BAQ_CODINT, BAQ_CODESP, BAQ_ESPSP2 FROM " + RetSqlName("BAQ") + " WHERE BAQ_FILIAL = '" + xFilial("BAQ") + "' AND BAQ_CODINT = '" + PlsIntPad() + "' AND BAQ_ESPSP2 <> ' ' AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBAQ",.F.,.T.)

	While !TBAQ->(Eof())

		aAdd(aClasEspe,{TBAQ->(BAQ_CODINT+BAQ_CODESP),TBAQ->BAQ_ESPSP2})
		TBAQ->(dbSkip())

	EndDo

	TBAQ->(dbCloseArea())

Return aClasEspe
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} IniciaProduto

	Funcao criada para inserir o produto na matriz de produtos para descartes de produtos nao informados a ANS

	@author timoteob.bega
	@since 16/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function IniciaProduto()
	Local aProduto		:= {}
	Local cSql			:= "SELECT BI3_CODINT, BI3_CODIGO, BI3_VERSAO, BI3_INFANS FROM " + RetSqlName("BI3") + " WHERE BI3_FILIAL = '" + xFilial("BI3") + "' AND BI3_CODINT = '" + PlsIntPad() + "' AND D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TBI3",.F.,.T.)

	While !TBI3->(Eof())

		aAdd(aProduto,{TBI3->(BI3_CODINT+BI3_CODIGO+BI3_VERSAO),TBI3->BI3_INFANS})
		TBI3->(dbSkip())

	EndDo

	TBI3->(dbCloseArea())

Return aProduto

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} DataReconPeg

	Funcao criada para retornar a data de reconhecimento da despesa quando MV_STATISS = .T.

	@author timoteob.bega
	@since 22/08/2017
	/*/
//--------------------------------------------------------------------------------------------------
Static Function DataReconPeg(cAlias,lMV_STATISS)
	Local cDatReco		:= ""
	Default cAlias	:= ""
	Default lMV_STATISS	:= MV_STATISS

	If lMV_STATISS .And. cAlias == 'TRBREE' .And. !Empty((cAlias)->B44_DTLBFN)
		cDatReco := (cAlias)->B44_DTLBFN
	Else

		BCI->(dbSetOrder(14))
		If (cAlias)->BD7_TIPGUI <> G_REEMBOLSO .And. BCI->(dbSeek(xFilial("BCI")+(cAlias)->BD7_CODPEG))
			cDatReco := SubStr(BCI->BCI_DTHRLB,1,8)
		Else
			cDatReco := Iif( !Empty((cAlias)->BD6_DTDIGI) , (cAlias)->BD6_DTDIGI , (cAlias)->BD7_DATPRO )
		EndIf

	EndIf

Return cDatReco

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} RetDadInt

	Funcao criada para retorna a chave de internação da despesa

	@param	cChvPsq	Chave da internacao proveniente de BD5_GUIINT de SADT, BE4_GUIINT de Resumo com vinculo, BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT de Resumo sem vinculo

	@author timoteob.bega
	@since 11/05/2018
	/*/
//--------------------------------------------------------------------------------------------------
Static Function RetDadInt(cGuiInt,cChaveGuia,cTipGui,cTipData,cTriRec,lMV_STATISS,lDtPag,cBd7)
	Local aDadInt		:= {.F.,"","","","","",STOD(""),STOD(""),0,0,"","",""}
	Local cSql			:= ""
	Local cNAlias		:= GetNextAlias()
	Local cFilBE4		:= xFilial("BE4")
	Default cGuiInt		:= ""//BE4_CODOPE, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO
	Default cChaveGuia	:= ""
	Default cTipGui		:= ""
	Default cTipData	:= ""
	Default cTriRec		:= ""
	Default lMV_STATISS	:= MV_STATISS
	Default lDtPag      := .F.
	Default cBd7        := ""

	If cTipData == "4"
		lDtPag:= .T.
	EndIF

	cSql := " SELECT "
	cSql += " BE4_GRPINT, BE4_REGINT, BE4_HORPRO, BE4_HRALTA, BE4_DATPRO, BE4_DTALTA, "
	cSql += " BE4_NASVIV, BE4_NASVPR, BE4_PADINT, BE4_GUIINT, BE4_CODOPE, BE4_CODLDP, "
	cSql += " BE4_CODPEG, BE4_NUMERO, BE4_NUMLOT, BE4_DTPAGT "
	If lMV_STATISS
		cSql += " , BCI_DTHRLB "
	EndIf
	cSql += " FROM " + RetSqlName("BE4") + " BE4 "
	If lMV_STATISS
		cSql += " , " + RetSqlName("BCI") + " BCI "
	EndIf
	cSql += " WHERE "
	cSql += " BE4_FILIAL='" + cFilBE4 + "' "
	If lMV_STATISS
		cSql += " AND BCI_FILIAL='" + xFilial("BCI") + "'  "
		cSql += " AND BE4_FILIAL = BCI_FILIAL "
		cSql += " AND BE4_CODOPE = BCI_CODOPE "
		cSql += " AND BE4_CODLDP = BCI_CODLDP "
		cSql += " AND BE4_CODPEG = BCI_CODPEG "
		cSql += " AND BCI_DTHRLB <> ' ' "
	EndIf
	cSql += " AND BE4_GUIINT='" + cGuiInt + "' AND BE4_TIPGUI='05' AND BE4.D_E_L_E_T_=' ' "
	If lMV_STATISS
		cSql += " AND BCI.D_E_L_E_T_=' ' "
		cSql += " ORDER BY BCI_DTHRLB "
	Else
		If !lDtPag
			cSql += " ORDER BY BE4_NUMLOT "
		Else
			cSql += " ORDER BY BE4_DTPAGT "
		EndIf
	EndIf


	cSql := ChangeQuery(cSql)

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cNAlias,.F.,.T.)

	If !(cNAlias)->(Eof())
		If Empty(cTipData) .Or. ConsFreqInter(cNAlias,cTipData,cTriRec,lMV_STATISS,cBd7)//Considera frequencia de internacao ?
			SetDadInt(aDadInt,cNAlias)
		EndIf
	Else

		If !Empty(cTriRec)//Resumo de Internacao nao encontrado para a despesa pela
			cMsg := CENDTHRL("W")  + "Tipo de Guia; " + cTipGui + "; Chave Despesa; " + cChaveGuia + "; Sol. Internacao; " + cGuiInt
			PlsLogFil(cMsg,DESP_SEM_RE)
			//PlsLogFil(CENDTHRL("I") + " " + cSql,DESP_SEM_RE)
		EndIf

	EndIf

	(cNAlias)->(dbCloseArea())

Return aDadInt
//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} SetDadInt

	Funcao criada para preencher a matriz de internação da despesa

	@param	aDatInt	matriz a receber os dados da internação
	@param	cChvPsq	Chave da internacao proveniente de BD5_GUIINT de SADT, BE4_GUIINT de Resumo com vinculo, BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT de Resumo sem vinculo

	@author timoteob.bega
	@since 11/05/2018
	/*/
//--------------------------------------------------------------------------------------------------
Static Function SetDadInt(aDadInt,cAliTr)

	aDadInt[1] := .T.
	aDadInt[2] := AllTrim((cAliTr)->BE4_GUIINT)//Chave da solicitação de internação - BE4_GUIINT
	aDadInt[3] := Iif( !Empty((cAliTr)->BE4_GRPINT),(cAliTr)->BE4_GRPINT,"1")//Grupo de Internação - default 1
	aDadInt[4] := Iif( !Empty((cAliTr)->BE4_REGINT),(cAliTr)->BE4_REGINT,"1")//Regime de Internação - default 1
	aDadInt[5] := (cAliTr)->BE4_HORPRO//Hora de Internação
	aDadInt[6] := (cAliTr)->BE4_HRALTA//Hora de Alta
	aDadInt[7] := (cAliTr)->BE4_DATPRO//Data de Internação
	aDadInt[8] := (cAliTr)->BE4_DTALTA//Data de Alta
	aDadInt[9] := (cAliTr)->BE4_NASVIV//Nascido Vivo
	aDadInt[10] := (cAliTr)->BE4_NASVPR//Nascido Prematuro
	aDadInt[11] := AllTrim((cAliTr)->BE4_GUIINT)//Chave da solicitação de internação - BE4_GUIINT
	aDadInt[12] := (cAliTr)->BE4_PADINT//Tipo de acomodação
	aDadInt[13]	:= (cAliTr)->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)//Chave do resumo de internacao

Return aDadInt

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} RetLocIgn

	Retorna a lista de locais de atendimento que a operadora deseja ignorar na integração PLS x Central

	@author timoteo.bega
	@since 10/05/2018
	/*/
//--------------------------------------------------------------------------------------------------
Function RetLocIgn()
	Local cLocais	:= ""
	Local cLista	:= GetNewPar("MV_LLDPIGN","")

	If !Empty(cLista)
		cLocais := "('"
		cLocais += StrTran(cLista,",","','")
		cLocais += "')"
	EndIf

Return cLocais


Static Function ClsItemE14(cCID,cPadInt,cHoraInt,cHoraAlta,dDatInt,dDatAlta,dNasc,nIdade)
	Local cClaItem		:= "E14"
	//Local aCID142		:= {"P250","P251","P252","P253","P258","P260","P261","P268","P269","P271","P278","P279","P298","P2999","P398","P399","P780","P781","P968","P969","Z876"}
	Local aGrp16		:= {{'P00', 'P04'},{'P05', 'P08'},{'P10', 'P15'},{'P20', 'P29'},{'P35', 'P39'},{'P50', 'P61'},{'P70', 'P74'},{'P75', 'P78'},{'P80', 'P83'},{'P90', 'P96'}}
	Local lUtiNeoNatal	:= cPadInt == "53" //53-UTI NEONATAL
	Local cGrpCID		:= SubStr(cCID,1,2)
	Default cCID		:= ""
	Default cPadInt		:= ""
	Default cHoraInt    := ""
	Default cHoraAlta   := ""
	Default dDatInt     := STOD("")
	Default dDatAlta    := STOD("")
	Default dNasc       := STOD("")
	Default nIdade      := 0

	If nIdade <=5 .And. ( (cGrpCID >= "J00" .And. cGrpCID <= "J22") .Or. (cGrpCID $ "J45,J46")  .Or. (cCID >= "J00" .And. cCID <= "J22"))
		cClaItem := "E141"
	EndIf

	If lUtiNeoNatal .Or. aScan(aGrp16,{ |x| x[1] >= AllTrim(cGrpCID) .AND. x[2] <= AllTrim(cGrpCID) }) > 0
		cClaItem := "E142"

		If !Empty(dNasc) .And. !Empty(dDatAlta) .And. !Empty(dDatInt) .And. !Empty(cHoraAlta) .And. !Empty(cHoraInt)

			If (dDatInt - dNasc) <= 6
				If (dDatAlta - dDatInt) < 2
					cClaItem := "E1421"
				ElseIf (dDatAlta - dDatInt) = 2
					iF Val(SUbstr(cHoraAlta,1,4)) <= Val(Substr(cHoraInt,1,4))
						cClaItem := "E1421"
					EndIf
				Endif
			EndIf
		EndIf
	EndIf

Return cClaItem

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} ConsFreqInter

	Essa funcao verifica se o resumo de internacao encontrado e reconhecido em outro trimestre, caso tenha
	reconhecimento em outro trimestre, vou enviar somente a despesa e nao envio a frequencia da internacao

	@author timoteo.bega
	@since 28/08/2018
	/*/
//--------------------------------------------------------------------------------------------------
Static Function ConsFreqInter(cNAlias,cTipData,cTriRec,lMV_STATISS,cBd7)
	Local lRet			:= .T.//A principio vou considerar a frequencia, se eu conseguir identificar tri de reconhecimento diferente desconsidero
	Local cSql			:= ""
	Local cAliInt		:= GetNextAlias()
	Default cNAlias		:= ""
	Default cTipData	:= ""
	Default cTriRec		:= ""
	Default lMV_STATISS	:= MV_STATISS
	Default cBd7        := ""

	If !Empty(cNAlias) .And. !Empty(cTriRec)

		If cTipData = "1"//data de digitacao

			If lMV_STATISS
				cSql := "SELECT SUBSTRING(BCI_DTHRLB,1,8) DATA FROM " + RetSqlName("BCI") + " WHERE BCI_FILIAL = '" + xFilial("BCI") + "' AND BCI_CODPEG = '" + (cNAlias)->BE4_CODPEG + "' AND D_E_L_E_T_ = ' '"
			Else
				cSql := "SELECT MAX(BD7_DTDIGI) DATA FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + (cNAlias)->BE4_CODOPE + "' AND BD7_CODLDP = '" + (cNAlias)->BE4_CODLDP + "' AND BD7_CODPEG = '" + (cNAlias)->BE4_CODPEG + "' AND BD7_NUMERO = '" + (cNAlias)->BE4_NUMERO + "' AND D_E_L_E_T_ = ' '"
			EndIf

		ElseIf cTipData = "2"//data de pagamento
			cSql := "SELECT MAX(SUBSTRING(BD7_NUMLOT,1,6)) DATA FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + (cNAlias)->BE4_CODOPE + "' AND BD7_CODLDP = '" + (cNAlias)->BE4_CODLDP + "' AND BD7_CODPEG = '" + (cNAlias)->BE4_CODPEG + "' AND BD7_NUMERO = '" + (cNAlias)->BE4_NUMERO + "' AND D_E_L_E_T_ = ' '"
		ElseIf cTipData = "3"//data do procedimento
			cSql := "SELECT MAX(BD6_DATPRO) DATA FROM " + RetSqlName("BD6") + " WHERE BD6_FILIAL = '" + xFilial("BD6") + "' AND BD6_CODOPE = '" + (cNAlias)->BE4_CODOPE + "' AND BD6_CODLDP = '" + (cNAlias)->BE4_CODLDP + "' AND BD6_CODPEG = '" + (cNAlias)->BE4_CODPEG + "' AND BD6_NUMERO = '" + (cNAlias)->BE4_NUMERO + "' AND D_E_L_E_T_ = ' '"
		Else
			cSql := "SELECT MAX(SUBSTRING(BD7_DTPAGT,1,6)) DATA FROM " + RetSqlName("BD7") + " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_CODOPE = '" + (cNAlias)->BE4_CODOPE + "' AND BD7_CODLDP = '" + (cNAlias)->BE4_CODLDP + "' AND BD7_CODPEG = '" + (cNAlias)->BE4_CODPEG + "' AND BD7_NUMERO = '" + (cNAlias)->BE4_NUMERO + "' AND D_E_L_E_T_ = ' '"
		Endif

		If CENCRIAALI(cSql,cAliInt)
			cData := (cAliInt)->DATA + Iif(cTipData $ "2/4","01","")
			IIf(Empty((cAliInt)->DATA),cData:="","")
			cTriAux:= IIF(Empty(cData),cBd7,cData)
			cTriAux := SubStr(DataTrimestre(cTriAux,"3"),1,6)

			If cTriAux <> cTriRec
				lRet := .F.
			EndIf
		EndIf

		(cAliInt)->(dbCloseArea())

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CENCRIAALI

	Funcao criada para criar e abrir uma area de trabalho baseada em consulta ao BD

	@param cConsulta		Consulta a ser executada
	@param cNomeArea		Nome do alias a ser criado

	@return lRetorno		Indica se a area foi criada ou nao

	@author timoteo.bega
	@since 14/09/2017
	/*/
//--------------------------------------------------------------------------------------------------
Function CENCRIAALI(cConsulta,cNomeArea)
	Local lRetorno			:= .F.
	Default cConsulta	:= ""
	Default cNomeArea	:= ""

	If !Empty(cConsulta) .And. !Empty(cNomeArea)

		cConsulta := ChangeQuery(cConsulta)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cNomeArea,.F.,.T.)

		If !(cNomeArea)->(Eof())
			lRetorno := .T.
		EndIf

	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} NomeJob

	Funcao criada para retornar o nome do job para o log

	@author timoteo.bega
	@since
	/*/
//--------------------------------------------------------------------------------------------------
Static Function NomeJob(lQryInter,lDadosHist)
	Local cNome := ""
	Default lQryInter	:= .F.
	Default lDadosHist	:= .F.

	If lDadosHist
		cNome += "HIS "
	EndIf

	If lQryInter
		cNome += "BE4"
	Else
		cNome += "BD5"
	EndIf

Return cNome

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CENDTHRL

	Funcao criada para retornar date e hora para log

	@author timoteo.bega
	@since
	/*/
//--------------------------------------------------------------------------------------------------
Function CENDTHRL(cTp)
	Local cMsg := "[" + DTOS(Date()) + " " + Time() + "]"
	Default cTp	:= "I"

	If cTp == "E"
		cMsg += "[ERRO]"
	ElseIf cTp == "W"
		cMsg += "[WARN]"
	Else
		cMsg += "[INFO]"
	EndIf

Return cMsg

Static Function RetornaCID(cChaveGuia)
	Local cCID	:= ""

	cCID := BE4RetornaCID(cChaveGuia)

	If Empty(cCID)

		cCID := BA9RetornaCID(cChaveGuia)

	EndIf

Return cCID

Static Function BE4RetornaCID(cChaveGuia)
	Local cCID		:= ""
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()

	cConsulta := RetQueryCID("1",cChaveGuia)

	If CENCRIAALI(cConsulta,cNomeArea)

		cCID := (cNomeArea)->CID

	EndIf

	(cNomeArea)->(dbCloseArea())

Return cCID

Static Function BA9RetornaCID(cChaveGuia)
	Local cCID		:= ""
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()

	cConsulta := RetQueryCID("2",cChaveGuia)

	If CENCRIAALI(cConsulta,cNomeArea)

		cCID := (cNomeArea)->CID

		If !Empty(cCID)

			cCID := GetCIDBA9(cCID)

		EndIf

	EndIf

	(cNomeArea)->(dbCloseArea())

Return cCID

Static Function RetQueryCID(cTp,cChaveGuia)
	Local cConsulta	:= ""
	Local cCampo	:= ""
	Local cWhere	:= ""
	Default cTp		:= "1"

	cCodOpe := SubStr(cChaveGuia,1,4)
	cCodLdp := SubStr(cChaveGuia,5,4)
	cCodPeg := SubStr(cChaveGuia,9,8)
	cNumero := SubStr(cChaveGuia,17,8)
	cSituac := SubStr(cChaveGuia,25,1)
	cFase := SubStr(cChaveGuia,26,1)

	If cTp == "1"

		cCampo	:= " BE4_CID "
		cWhere	:= " AND BE4_CIDREA=' ' "

	Else

		cCampo := " BE4_CIDREA "
		cWhere	:= " AND BE4_CIDREA<>' ' "

	EndIf

	cConsulta := "SELECT " + cCampo + " CID FROM " + RetSqlName("BE4") + " WHERE BE4_FILIAL='" + xFilial("BE4") + "' AND BE4_CODOPE='" + cCodOpe + "' AND BE4_CODLDP='" + cCodldp + "' AND BE4_CODPEG='" + cCodPeg + "' AND BE4_NUMERO='" + cNumero + "' "
	cConsulta += " AND BE4_SITUAC='" + cSituac + "' AND BE4_FASE='" + cFase + "' " + cWhere + " AND D_E_L_E_T_=' '"

Return cConsulta

Static Function GetCIDBA9(cCID)
	Local cConsulta		:= ""
	Local cNomeArea		:= GetNextAlias()
	Default cCID		:= ""

	cConsulta := "SELECT BA9_CODDOE FROM " + RetSqlName("BA9") + " WHERE BA9_FILIAL='" + xFilial("BA9") + "' AND BA9_CODDOE='" + cCID + "' AND D_E_L_E_T_=' '"

	If CENCRIAALI(cConsulta,cNomeArea)

		cCID := AllTrim((cNomeArea)->BA9_CODDOE)

	EndIf

	(cNomeArea)->(dbCloseArea())

Return cCID

Static Function ExisteEstorno(cChaveGuia)
	Local cConsulta	:= ""
	Local lRetorno	:= .F.
	Local cCodOpe	:= SubStr(cChaveGuia,1,4)
	Local cCodLdp	:= SubStr(cChaveGuia,5,4)
	Local cCodPeg	:= SubStr(cChaveGuia,9,8)
	Local cNumero	:= SubStr(cChaveGuia,17,8)
	Local cOrimov	:= SubStr(cChaveGuia,25,1)
	Local cNomeArea	:= GetNextAlias()

	cConsulta := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("BD5") + " WHERE BD5_FILIAL='" + xFilial("BD5") + "' "
	If !Empty(cCodOpe)
		cConsulta += "AND BD5_CODOPE = '" + cCodOpe + "' "
	EndIf
	If !Empty(cCodLdp)
		cConsulta += "AND BD5_CODLDP = '" + cCodLdp + "' "
	EndIf
	If !Empty(cCodPeg)
		cConsulta += "AND BD5_CODPEG = '" + cCodPeg + "' "
	EndIf
	If !Empty(cNumero)
		cConsulta += "AND BD5_NUMERO = '" + cNumero + "' "
	EndIf
	If !Empty(cOrimov)
		cConsulta += "AND BD5_ORIMOV = '" + cOrimov + "' "
	Endif

	cConsulta += " AND BD5_GUESTO='1' AND D_E_L_E_T_=' ' "

	If CENCRIAALI(cConsulta,cNomeArea)
		lRetorno := .T.
	EndIf

	(cNomeArea)->(dbCloseArea())

Return lRetorno

Static Function InformaProduto(cChaveProd,aProduto)
	Local lRetorno	:= .F.
	Local cConsulta	:= ""
	Local cNomeArea	:= GetNextAlias()
	Default aProduto:= {}

	cCodInt := Substr(cChaveProd,1,4)
	cCodigo := Substr(cChaveProd,5,4)
	cVersao := Substr(cChaveProd,9,3)

	cConsulta := "SELECT R_E_C_N_O_ REC,BI3_INFANS FROM " + RetSqlName("BI3") + " WHERE BI3_FILIAL='" + xFilial("BI3") + "' AND BI3_CODINT='" + cCodInt + "' AND BI3_CODIGO='" + cCodigo + "' AND BI3_VERSAO='" + cVersao + "' AND BI3_INFANS='0' AND D_E_L_E_T_=' '"

	If CENCRIAALI(cConsulta,cNomeArea)

		lRetorno := .T.
		aAdd(aProduto,{cChaveProd,(cNomeArea)->BI3_INFANS})

	EndIf

	(cNomeArea)->(dbCloseArea())

Return lRetorno

Static Function BANInicia()
	Local aBAN	:= {}
	Local cConsulta	:= "SELECT BAN_CODIGO, BAN_VERSAO, BAN_CLACAR, BAN_QTDCAR, BAN_UNCAR FROM " + RetSqlName("BAN") + " WHERE BAN_FILIAL='" + xFilial("BAN") + "' AND D_E_L_E_T_=' '"
	Local cNomeArea	:= GetNextAlias()

	If CENCRIAALI(cConsulta,cNomeArea)

		While !(cNomeArea)->(Eof())

			aAdd(aBAN,{ (cNomeArea)->(BAN_CODIGO+BAN_VERSAO+BAN_CLACAR), (cNomeArea)->BAN_QTDCAR, (cNomeArea)->BAN_UNCAR })
			(cNomeArea)->(DbSkip())

		EndDo

	EndIf

	(cNomeArea)->(dbCloseArea())

Return aBAN

Static Function BDLInicia()
	Local aBDL	:= {}
	Local cConsulta	:= "SELECT BDL_CODINT, BDL_CODIGO, BDL_CARENC, BDL_UNCAR FROM " + RetSqlName("BDL") + " WHERE BDL_FILIAL='" + xFilial("BDL") + "' AND D_E_L_E_T_=' '"
	Local cNomeArea	:= GetNextAlias()

	If CENCRIAALI(cConsulta,cNomeArea)

		While !(cNomeArea)->(Eof())

			aAdd(aBDL,{ (cNomeArea)->(+BDL_CODINT+BDL_CODIGO), (cNomeArea)->BDL_CARENC, (cNomeArea)->BDL_UNCAR })
			(cNomeArea)->(DbSkip())

		EndDo

	EndIf

	(cNomeArea)->(dbCloseArea())

Return aBDL

Static Function NatSaudeItem(aNatSaude,cClaSIP)
	Local aRet			:= {}
	Local nFor			:= 0
	Default	aNatSaude	:= {}
	Default cClaSip		:= ""

	If !Empty(cClaSIP) .And. Len(aNatSaude) > 0

		For nFor := 1 TO Len(aNatSaude)

			If aNatSaude[nFor,7] == '3' .And. aNatSaude[nFor,8] == cClaSIP .And. ( (aNatSaude[nFor,4]+aNatSaude[nFor,5] > 0) .Or. !Empty(aNatSaude[nFor,6]) )

				aAdd(aRet,{aNatSaude[nFor,1],aNatSaude[nFor,2],aNatSaude[nFor,3],aNatSaude[nFor,4],aNatSaude[nFor,5],aNatSaude[nFor,6],aNatSaude[nFor,7],aNatSaude[nFor,8]})

			EndIf

		Next nFor

	EndIf

Return aRet

Static Function LimpaExpostos(cCodOpe,cCodObr,cAno,cCdComp)
	Local cSql		:= ""
	Local nRet		:= 0
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAno	:= ""
	Default cCdComp	:= ""

	BEGIN TRANSACTION

		cSql := "DELETE FROM " + RetSqlName("B3O") + " WHERE B3O_FILIAL='" + xFilial("B3O") + "' AND B3O_CODOPE='" + cCodOpe + "' AND B3O_CDOBRI='" + cCodObr + "' AND B3O_ANO='" + cAno + "' AND B3O_CDCOMP='" + cCdComp + "' AND D_E_L_E_T_=' ' "
		nRet := TCSQLEXEC(cSql)
		If nRet >= 0
			TCSQLEXEC("COMMIT")
		Else
			PlsLogFil("LimpaExpostos" + CENDTHRL("E") + " " + cSql,ARQ_LOG_DES)
		EndIf

	END TRANSACTION

Return



Function BscPrfExe(cRegPre,cCdPfPr,cCodRda,cUF,cCodLoc,cGuiInt,cTipGui)
	Local cValPes   := ""
	Default cTipGui := ""
	Default cRegPre := ""
	Default cCdPfPr := ""
	Default cCodRda := ""
	Default cUF     := ""
	Default cCodLoc := ""
	Default cGuiInt := ""

	If !Empty(cCodRda)      //BD7_CODRDA
		cValPes:=cCodRda
	ElseIf !Empty(cRegPre)  //BD7_REGPRE
		cValPes:=cRegPre
	ElseIf !Empty(cCdPfPr)  //BD7_CDPFPR
		cValPes:=cCdPfPr
	EndIf

	If !Empty(cGuiInt) .And. cTipGui == "06" //honorários vinculados a internação. Busco dados da RDA do Resumo.
		cValPes:= PlsRdaRes(cGuiInt,@cCodLoc)
	EndIf

	If !Empty(cValPes)
		BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
		If BAU->(DbSeek(xFilial("BAU")+cValPes))
			cUf:=BAU->BAU_EST
			BB8->(DbSetOrder(1))//BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
			If !Empty(cCodLoc) .And. BB8->(DbSeek(xFilial("BB8")+cValPes+cCodLoc))
				If !Empty(BB8->BB8_EST)
					cUf:=BB8->BB8_EST
				EndIf
			EndIf
		Endif
	EndIf

	If Empty(cUf)
		cUf:="ZZ"
	Endif

return cUF

//--------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} CENDTHRL

	Função criada para retornar dados da RDA baseado no resumo de internação e também avaliar se há um resumo baseado na internação que vem no honorário.

	@author jose.paulo
	@since 01/11/2022
	/*/
//--------------------------------------------------------------------------------------------------
Function PlsRdaRes(cGuiInt,cCodLoc)
	Local cSql 	    := ""
	Local cValPes   := ""
	Default cGuiInt := ""
	Default cCodLoc := ""

	cSql := "SELECT BE4_CODRDA, BE4_TIPGUI,BE4_CODOPE||BE4_CODLOC||BE4_LOCAL LOCAL "
	cSql += "FROM " + RetSqlName("BE4") + "  "
	cSql += "	WHERE BE4_FILIAL = '" + xFilial("BE4") + "' AND BE4_GUIINT = '" + cGuiInt + "' AND BE4_TIPGUI = '05' AND BE4_NUMLOT <> '' AND D_E_L_E_T_ = ' '  "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBE4",.F.,.T.)

	While !TRBBE4->(Eof())
		If !Empty(TRBBE4->BE4_CODRDA)
			cValPes:= TRBBE4->BE4_CODRDA
			cCodLoc:= TRBBE4->LOCAL
			Exit
		EndIf
		TRBBE4->(dbSkip())
	EndDo

	TRBBE4->(dbCloseArea())

Return cValPes

//--------------------------------------------------------------------------------------------------
	/*/
	Fun??o criada para classificar procedimentos nos Itens de acordo com  a atualiza??o SIP 11/2023

	@author jose.paulo
	@since 23/08/2023
	/*/
//--------------------------------------------------------------------------------------------------
Function PLSVERCON(cProc,cTipGui,nIdade,cCodEsp,cDatPro,cSexo)
	Local cTxt      := ""
	Local cRet      := ""
	Default cProc   := ""
	Default cTipGui := ""
	Default cCodEsp := ""
	Default cDatPro := ""
	Default cSexo   := ""
	DEFAULT nIdade  := 0

	If Empty(cRet)
		cTxt:= "10101012,10106014,10106030,10106049,10106146,10106154,20101015,20101023,20101074,20101082,20101090,20101171,20101201,20101210,"
		cTxt+= "20101228,20101236,20101244,20101309,20101317,20101341,20101406,20101414,20101430,20101449,20101457,20201133,10105034,10105042"
		cTxt+= "10105050,10105069,10106065,10106073,10106090,10106103,10106111,10106120,10106138,20101155,20101465"

		If AllTrim(cProc) $ cTxt
			cRet:= "A1"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "10101039"
		If AllTrim(cProc) $ cTxt
			cRet:= "A2"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "50000144,50000160,50000195,50000209,50000217,50000233,50000241,50000250,50000268,50000276,50000284,50000292,50000306,50000314,
		cTxt+= "50000322,50000330,50000446,50000713,50000730,50000748,50000756,50000764,50000772,50000780,50000837,50000845,50000853,50000861,"
		cTxt+= "50000870,50001078,"
		If AllTrim(cProc) $ cTxt
			cRet:= "B1"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "50000586,50000594,50000616,50000624,50000640,50000659,50000667,50000675"
		If AllTrim(cProc) $ cTxt
			cRet:= "B2"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:= "50000560,50000578"
		If AllTrim(cProc) $ cTxt
			cRet:= "B3"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "50000012,50000020,50000055,50000063,50000080,50000098,50000110,50000128,50000136"
		If AllTrim(cProc) $ cTxt
			cRet:= "B4"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="50000039,50000047,50001213"

		If AllTrim(cProc) $ cTxt
			BAQ->(dbSeek(xFilial("BAQ")+cCodEsp))

			If !Empty(BAQ->BAQ_CBOS)
				If Alltrim(BAQ->BAQ_CBOS) $ "223810"
					cRet:= "B2"
				ElseIf Alltrim(BAQ->BAQ_CBOS) $ "223905"
					cRet:= "B4"
				ElseIf Alltrim(BAQ->BAQ_CBOS) $ "251510"
					cRet:= "B5"
				ENDIF
			ENDIF
		EndIF
	EndIf

	If Empty(cRet)

		cTxt:= "50001221,50001248,50000470,50000489,50000497,50000500,50000519,50001183,50001191"
		If AllTrim(cProc) $ cTxt
			cRet:= "B5"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "41101014,41101022,41101030,41101049,41101057,41101065,41101073,41101081,41101090,41101103,41101111,41101120,41101138,"
		cTxt+= "41101146,41101154,41101170,41101189,41101197,41101200,41101219,41101227,41101235,41101243,41101251,41101260,41101278,"
		cTxt+= "41101286,41101294,41101308,41101316,41101332,41101340,41101359,41101375,41101383,41101430,41101448,41101456,41101464,"
		cTxt+= "41101472,41101480,41101499,41101502,41101510,41101529,41101537,41101545,41101553,41101561,41101570,41101588,41101596,"
		cTxt+= "41101600,41101618,41101626,41101634,41101642,41101650,41101669,41102010"
		If AllTrim(cProc) $ cTxt
			cRet:= "C1"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "41001010,41001028,41001036,41001044,41001052,41001060,41001079,41001087,41001095,41001109,41001117,41001125,41001133,"
		cTxt+= "41001141,41001150,41001176,41001184,41001192,41001206,41001214,41001222,41001230,41001249,41001257,41001265,41001273,"
		cTxt+= "41001281,41001290,41001303,41001311,41001320,41001338,41001346,41001354,41001362,41001370,41001389,41001397,41001400,"
		cTxt+= "41001419,41001427,41001435,41001443,41001451,41001460,41001478,41001486,41001494,41001508,41001516,41001524,41001532,"
		cTxt+= "41002016,41002040,41002059"
		If AllTrim(cProc) $ cTxt
			cRet:= "C2"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="40601137,40601323,"

		If AllTrim(cProc) $ cTxt
			If (nIdade >= 25 .And. nIdade <= 59) .And. Alltrim(cSexo) == "2"
				cRet:= "C3"
			Else
				cRet:= "C"
			EndIf
		EndIF
	EndIf

	If Empty(cRet)

		cTxt:="40808122,40808130,40808149"
		If AllTrim(cProc) $ cTxt
			cRet:= "C4"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "40901092,40901106"
		If AllTrim(cProc) $ cTxt
			cRet:= "C5"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "40201031,40201058"
		If AllTrim(cProc) $ cTxt
			cRet:= "C6"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:= "40201120,40201139,40201333,40202038,40202615,40202747"
		If AllTrim(cProc) $ cTxt
			cRet:= "C7"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "40201082,40201090,40201350,40202135,40202666"
		If AllTrim(cProc) $ cTxt
			cRet:= "C8"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:= "20102011,20102020,20102100"
		If AllTrim(cProc) $ cTxt
			cRet:= "C9"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="40808033,40808041,40808173,"

		If AllTrim(cProc) $ cTxt
			If (nIdade >= 50 .And.  nIdade <= 69) .And. Alltrim(cSexo) == "2"
				cRet:= "C101"
			Else
				cRet:= "C10"
			EndIf
		EndIF
	EndIf

	If Empty(cRet)

		cTxt:= "40701034,40701042,40701050,40701069,40701131,40701140"
		If AllTrim(cProc) $ cTxt
			cRet:= "C11"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40704017,40704025"
		If AllTrim(cProc) $ cTxt
			cRet:= "C12"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40302075,40302733"
		If AllTrim(cProc) $ cTxt
			cRet:= "C13"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="40303136,40303250"

		If AllTrim(cProc) $ cTxt
			If nIdade >= 50 .And.  nIdade <= 69
				cRet:= "C14"
			Else
				cRet:= "C"
			EndIf
		EndIF
	EndIf

	If Empty(cRet)

		cTxt:= "40801012,40801020,40801039,40801047,40801055,40801063,40801071,40801080,40801098,40801101,40801195,40801209,40802019"
		cTxt+= "40802027,40802035,40802043,40802051,40802060,40814130"
		cTxt+= "40802078,40802086,40802094,40802108,40802116,40803015,40803023,40803031,40803040,40803058,40803066,40803074,40803082,"
		cTxt+= "40803090,40803104,40803112,40803120,40803139,40803147,40803155,40804011,40804020,40804038,40804046,40804054,40804062,"
		cTxt+= "40804070,40804089,40804097,40804100,40804119,40804127,40804135,40805018,40805026,40805034,40805042,40805050,40805069,"
		cTxt+= "40805077,40805085,40805093,40806014,40806022,40806030,40806049,40806057,40806065,40806073,40806081,40806090,40806103,"
		cTxt+= "40806111,40806120,40806138,40806146,40806154,40806162,40806170,40806189,40806197,40806200,40806219,40807010,40807029,"
		cTxt+= "40807037,40807045,40807053,40807061,40807070,40807088,40807096,40807100,40808017,40808025,40808050,40808114,40808157,"
		cTxt+= "40808165,40809021,40809030,40809048,40809056,40809064,40809072,40809080,40809110,40809129,40809137,40810011,40811018,"
		cTxt+= "40811026,40812022,40812030,40812049,40812057,40812073,40812081,40812090,40812103,40812111,40812120,40812138,40812146,"
		If AllTrim(cProc) $ cTxt
			cRet:= "C15"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40101037,40101045,40101061,41401158,41401166,41401174,41401182,41401190,41401204"
		If AllTrim(cProc) $ cTxt
			cRet:= "C16"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40901122,40901572"
		If AllTrim(cProc) $ cTxt
			cRet:= "C17"
		EndIF

	ENDIF

	If Empty(cRet)

		cTxt:="40901173,40901181"
		If AllTrim(cProc) $ cTxt
			cRet:= "C18"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40901130"
		If AllTrim(cProc) $ cTxt
			cRet:= "C19"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40901262"
		If AllTrim(cProc) $ cTxt
			cRet:= "C20"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40401014,40401022"
		If AllTrim(cProc) $ cTxt
			cRet:= "D1"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="20104243,20104251,20104278,20104286,20104294,20104308,20104383,20104430"
		If AllTrim(cProc) $ cTxt
			cRet:= "D2"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="41203070,41203089,41203097"
		If AllTrim(cProc) $ cTxt
			cRet:= "D3"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="30909139,30909147"
		If AllTrim(cProc) $ cTxt
			cRet:= "D4"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="30909031,30909155"
		If AllTrim(cProc) $ cTxt
			cRet:= "D5"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="31303269,31303293"
		If AllTrim(cProc) $ cTxt
			cRet:= "D6"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="81000065"
		If AllTrim(cProc) $ cTxt
			cRet:= "I1"
		EndIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="81000294,81000340,81000375,81000405,81000413,81000421,81000456,81000480,81000510,81000529,81000537,81000570"
		If AllTrim(cProc) $ cTxt
			cRet:= "I2"
		EndIF
	ENDIF

	If Empty(cRet)
		cTxt:="40801110,40801128,40801136,40801144,40801152,40801160,40801179,40801187,81000324,81000367,81000430,81000472,81000561,"

		If AllTrim(cProc) $ cTxt
			If cTipGui == "13"
				cRet:= "I2"
			else
				cRet:= "C15"
			EndIf
		EndIF

	EndIf

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="84000031,84000112,84000163,84000171,84000198,84000201,84000228,84000236,"
		cTxt+="84000252,85300055"
		If AllTrim(cProc) $ cTxt
			cRet:= "I3"
		EndIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="84000139,87000016,87000024"
		If AllTrim(cProc) $ cTxt
			cRet:= "I31"
		EndIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="84000090"
		If AllTrim(cProc) $ cTxt
			cRet:= "I32"
		EndIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="84000058,84000074,"
		If AllTrim(cProc) $ cTxt
			If nIdade < 12
				cRet:= "I33"
			else
				cRet:="I3"
			EndIf
		EndIF
	EndIf

	If Empty(cRet)
		cTxt:="41401654"

		If AllTrim(cProc) $ cTxt
			If cTipGui == "13"
				cRet:= "I3"
			else
				cRet:= "C"
			EndIf
		EndIF

	EndIf

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="85300047"

		If AllTrim(cProc) $ cTxt .And. nIdade >= 12
			cRet:= "I4"
		EndIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="83000135"

		If AllTrim(cProc) $ cTxt
			If nIdade < 12
				cRet:= "I5"
			EndIf
		EndIF
	EndIf

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="85100048,85100064,85100099,85100102,85100110,85100129,85100137,85100145,85100153,85100161,85100196,85100200,85100218,85100226,"

		If AllTrim(cProc) $ cTxt
			If nIdade >= 12
				cRet:= "I6"
			Else
				cRet:= "I5"
			EndIf
		EndIF
	EndIf

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="82000875"

		If AllTrim(cProc) $ cTxt
			If nIdade >= 12
				cRet:= "I7"
			EndIf
		EndIF
	EndIf

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="83000151"

		If AllTrim(cProc) $ cTxt
			If nIdade < 12
				cRet:= "I8"
			EndIf
		EndIF
	EndIf

	If Empty(cRet) .And. cTipGui == "13"
		cTxt:="85200093,85200107,85200115,85200131,85200140,85200158,85200166,"

		If AllTrim(cProc) $ cTxt
			If nIdade >= 12
				cRet:= "I9"
			EndIf
		EndIF
	EndIf

	If Empty(cRet) .And. cTipGui == "13"

		cTxt:="85400262,85400297,85400300,85400319,85400327,85400335,85400343,85400351,85400378,85400386,85400408,85400416,85400424,"
		cTxt+="85400564,85400610,85500097,85500100,85500119,85500127"
		If AllTrim(cProc) $ cTxt
			cRet:= "I10"
		EndIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"

		cTxt:="83000020,83000046,83000062,85400092,85400106,85400114,85400122,85400130,85400149,85400157,85400165,85400173,85400181,"
		cTxt+="85400190,85400238,85400513,85400521,85400530,85400548,85400556,85400572,85500038,85500046,85500054,87000040,87000059,"
		cTxt+="87000067"

		If AllTrim(cProc) $ cTxt
			cRet:= "I11"
		EndIF
	ENDIF

// Planilha 2 -> Grandes Grupos

	If Empty(cRet)

		cTxt:="20101104,20101112,20101120,20101139,20101279,20101287,20101325,20101333,20101368,20101376,20101384,20101392,20101422,"
		cTxt+="20102011,20102020,20102038,20102062,20102070,20102089,20102097,20102100,20102119,20102127,20102135,20102143,20102160,"
		cTxt+="20103751,20105010,20105029,20202016,20202024,30101085,30101590,30205077,30212120,30213010,30214017,"
		cTxt+="30301025,30303028,30308011,30311012,30401011,30402026,30402042,30501059,30502195,30601266,30602017,30602181,"
		cTxt+="30602335,30713021,30713030,30715040,30715253,30730023,30731020,30803241,30804019,30805023,30911176,30914124,"
		cTxt+="30918014,30918022,30918030,31005071,31005675,31005691,31007015,31101402,31102026,31103030,31104029,31202012,"
		cTxt+="31203027,31204015,31206034,31301029,31302017,31303021,31303030,31403018,31602231,31602258,31602266,31602274,"
		cTxt+="31602282,31602304,31602312,31602320,40101010,40101029,40101037,40101045,40101053,40101061,40102025,40102033,"
		cTxt+="40102041,40102050,40102068,40102076,40102084,40102092,40102106,40102114,40102122,40102130,40102149,40103013,"
		cTxt+="40103021,40103030,40103048,40103056,40103064,40103072,40103080,40103099,40103102,40103110,40103137,40103145,"
		cTxt+="40103153,40103161,40103170,40103196,40103234,40103242,40103250,40103269,40103285,40103307,40103315,40103323,"
		cTxt+="40103331,40103340,40103358,40103366,40103374,40103382,40103390,40103404,40103412,40103420,40103439,40103447,"
		cTxt+="40103455,40103463,40103471,40103480,40103498,40103501,40103510,40103528,40103536,40103544,40103552,40103560,"
		cTxt+="40103579,40103587,40103595,40103609,40103617,40103625,40103633,40103641,40103650,40103668,40103676,40103684,"
		cTxt+="40103714,40103722,40103730,40103749,40103757,40103765,40103781,40103790,40103803,40103811,40103820,40103838,"
		cTxt+="40103846,40103854,40103862,40103870,40103889,40103897,40103927,40104010,40104028,40104036,40104044,40104125,"
		cTxt+="40105016,40105024,40105032,40105040,40105059,40105067,40105075,40105083,40105091,40105105,40105113,40105121,"
		cTxt+="40105130,40105148,40201015,40201023,40201031,40201058,40201066,40201074,40201082,40201090,40201104,40201112,"
		cTxt+="40201120,40201139,40201147,40201155,40201163,40201171,40201180,40201198,40201201,40201210,40201228,40201236,"
		cTxt+="40201244,40201252,40201260,40201309,40201317,40201333,40201341,40201350,40202038,40202046,40202135,40202240,"
		cTxt+="40202429,40202437,40202488,40202615,40202666,40202690,40202720,40202747,40202780,40202798,40301010,40301028,"
		cTxt+="40301036,40301044,40301052,40301060,40301079,40301087,40301095,40301109,40301117,40301125,40301133,40301141,"
		cTxt+="40301150,40301168,40301176,40301184,40301192,40301206,40301214,40301222,40301230,40301249,40301257,40301265,"
		cTxt+="40301273,40301281,40301290,40301303,40301311,40301320,40301338,40301346,40301354,40301362,40301370,40301389,"
		cTxt+="40301397,40301400,40301419,40301427,40301435,40301443,40301451,40301460,40301478,40301486,40301494,40301508,"
		cTxt+="40301516,40301524,40301532,40301540,40301559,40301567,40301575,40301583,40301591,40301605,40301613,40301621,"
		cTxt+="40301630,40301648,40301656,40301664,40301672,40301680,40301699,40301702,40301710,40301729,40301737,40301745,"
		cTxt+="40301753,40301761,40301770,40301788,40301796,40301800,40301818,40301826,40301834,40301842,40301850,40301869,"
		cTxt+="40301877,40301885,40301893,40301907,40301915,40301923,40301931,40301940,40301958,40301966,40301974,40301982,"
		cTxt+="40301990,40302016,40302024,40302032,40302040,40302059,40302067,40302075,40302083,40302091,40302105,40302113,"
		cTxt+="40302121,40302130,40302148,40302156,40302164,40302172,40302180,40302199,40302202,40302210,40302229,40302237,"
		cTxt+="40302245,40302253,40302261,40302270,40302288,40302296,40302300,40302318,40302326,40302334,40302342,40302350,"
		cTxt+="40302369,40302377,40302385,40302393,40302407,40302415,40302423,40302431,40302440,40302458,40302466,40302474,"
		cTxt+="40302482,40302490,40302504,40302512,40302520,40302539,40302547,40302555,40302563,40302571,40302580,40302598,"
		cTxt+="40302601,40302610,40302628,40302636,40302644,40302652,40302679,40302687,40302695,40302709,40302717,"
		cTxt+="40302725,40302733,40302741,40302750,40302768,40302776,40302784,40302792,40302806,40302814,40302822,40302830,"
		cTxt+="40302849,40302857,40302865,40302873,40302881,40302890,40302903,40302911,40302920,40302938,40302946,40302954,"
		cTxt+="40302962,40302989,40302997,40303012,40303020,40303039,40303047,40303055,40303063,40303071,40303080,40303098,"
		cTxt+="40303101,40303110,40303128,40303136,40303144,40303152,40303160,40303179,40303187,40303195,40303209,40303217,"
		cTxt+="40303225,40303241,40303250,40303268,40303276,40303284,40303292,40303306,40303314,40303322,40303330,40304019,"
		cTxt+="40304027,40304035,40304043,40304051,40304060,40304078,40304086,40304094,40304108,40304116,40304132,40304140,"
		cTxt+="40304159,40304167,40304175,40304183,40304191,40304205,40304213,40304221,40304230,40304248,40304256,40304264,"
		cTxt+="40304272,40304280,40304299,40304302,40304310,40304329,40304337,40304345,40304353,40304361,40304370,40304388,"
		cTxt+="40304396,40304400,40304418,40304434,40304450,40304469,40304477,40304485,40304493,40304507,40304515,40304523,"
		cTxt+="40304531,40304540,40304558,40304566,40304574,40304582,40304590,40304604,40304612,40304620,40304639,40304647,"
		cTxt+="40304655,40304663,40304671,40304680,40304698,40304701,40304710,40304728,40304736,40304744,40304752,40304760,"
		cTxt+="40304779,40304787,40304809,40304817,40304825,40304833,40304841,40304850,40304868,40304876,40304884,40304892,"
		cTxt+="40304906,40304914,40304922,40304930,40304949,40304957,40304965,40304973,40304981,40305015,40305040,40305058,"
		cTxt+="40305066,40305074,40305082,40305090,40305112,40305120,40305163,40305210,40305228,40305236,40305279,40305287,"
		cTxt+="40305295,40305341,40305368,40305384,40305406,40305422,40305449,40305465,40305490,40305503,40305511,40305546,"
		cTxt+="40305554,40305562,40305570,40305589,40305597,40305600,40305619,40305627,40305635,40305740,40305759,40305767,"
		cTxt+="40305775,40305783,40306011,40306020,40306046,40306054,40306062,40306070,40306089,40306097,40306100,40306119,"
		cTxt+="40306127,40306135,40306143,40306151,40306160,40306178,40306186,40306194,40306208,40306216,40306224,40306232,"
		cTxt+="40306240,40306259,40306267,40306275,40306283,40306291,40306305,40306313,40306321,40306330,40306348,40306356,"
		cTxt+="40306364,40306372,40306380,40306399,40306402,40306410,40306429,40306437,40306445,40306453,40306461,40306470,"
		cTxt+="40306488,40306496,40306500,40306518,40306526,40306534,40306542,40306550,40306569,40306577,40306585,40306593,"
		cTxt+="40306607,40306615,40306623,40306631,40306640,40306658,40306666,40306674,40306682,40306690,40306704,40306712,"
		cTxt+="40306720,40306739,40306747,40306755,40306763,40306771,40306780,40306798,40306801,40306810,40306828,40306836,"
		cTxt+="40306844,40306852,40306860,40306879,40306887,40306895,40306909,40306917,40306925,40306933,40306941,40306950,"
		cTxt+="40306968,40306976,40306984,40306992,40307018,40307026,40307034,40307042,40307050,40307069,40307077,40307085,"
		cTxt+="40307093,40307107,40307115,40307123,40307131,40307140,40307158,40307166,40307174,40307182,40307190,40307204,"
		cTxt+="40307212,40307220,40307239,40307247,40307255,40307263,40307271,40307280,40307298,40307301,40307310,40307328,"
		cTxt+="40307336,40307344,40307352,40307360,40307379,40307387,40307395,40307409,40307417,40307425,40307433,40307441,"
		cTxt+="40307450,40307468,40307476,40307484,40307492,40307506,40307514,40307522,40307530,40307565,40307573,40307581,"
		cTxt+="40307590,40307603,40307611,40307620,40307638,40307654,40307662,40307689,40307697,40307700,40307719,40307727,"
		cTxt+="40307735,40307743,40307751,40307760,40307778,40307786,40307794,40307808,40307816,40307824,40307832,40307840,"
		cTxt+="40307859,40307867,40307875,40307883,40307891,40307905,40307913,40307921,40307930,40307948,40307956,40307964,"
		cTxt+="40307972,40307999,40308014,40308022,40308030,40308049,40308065,40308081,40308090,40308120,40308138,40308154,"
		cTxt+="40308162,40308170,40308197,40308200,40308219,40308235,40308243,40308251,40308278,40308286,40308294,40308308,"
		cTxt+="40308316,40308324,40308332,40308340,40308359,40308367,40308375,40308383,40308391,40308405,40308413,40308421,"
		cTxt+="40308430,40308448,40308456,40308464,40308472,40308480,40308499,40308502,40308510,40308529,40308537,40308545,"
		cTxt+="40308553,40308561,40308570,40308588,40308596,40308618,40308626,40308634,40308642,40308650,40308669,40308677,"
		cTxt+="40308685,40308693,40308707,40308723,40308731,40308740,40308758,40308766,40308774,40308782,40308790,40308804,"
		cTxt+="40308812,40308820,40308839,40308847,40308855,40308863,40308871,40308880,40308898,40308901,40308910,40308928,"
		cTxt+="40308936,40308944,40308952,40308960,40308979,40308987,40308995,40309010,40309029,40309037,40309045,40309053,"
		cTxt+="40309061,40309070,40309088,40309096,40309100,40309118,40309126,40309134,40309142,40309150,40309169,40309177,"
		cTxt+="40309185,40309193,40309207,40309215,40309231,40309240,40309258,40309266,40309304,40309312,40309320,"
		cTxt+="40309401,40309410,40309428,40309436,40309444,40309452,40309509,40309517,40309525,40310019,40310035,40310043,"
		cTxt+="40310051,40310060,40310078,40310086,40310094,40310108,40310116,40310124,40310132,40310140,40310159,40310167,"
		cTxt+="40310175,40310183,40310191,40310205,40310213,40310221,40310230,40310248,40310256,40310264,40310272,40310280,"
		cTxt+="40310299,40310302,40310310,40310329,40310337,40310345,40310353,40310361,40310370,40310388,40310400,40310418,"
		cTxt+="40310426,40310434,40310442,40310450,40310469,40310477,40310485,40310493,40310515,40310523,40310531,40310540,"
		cTxt+="40310558,40310566,40310574,40310582,40310590,40310604,40310612,40310620,40310639,40310647,40310655,40310663,"
		cTxt+="40310671,40310680,40310698,40310701,40310710,40310728,40310736,40311015,40311023,40311031,40311040,40311058,"
		cTxt+="40311066,40311074,40311082,40311090,40311104,40311112,40311120,40311139,40311147,40311155,40311163,40311171,"
		cTxt+="40311180,40311198,40311201,40311210,40311228,40311236,40311244,40311252,40311260,40311279,40311287,40311295,"
		cTxt+="40311309,40311317,40311325,40311333,40311341,40311350,40311368,40311376,40311384,40311392,40311406,40311414,"
		cTxt+="40311422,40311430,40311449,40311457,40311465,40311473,40311481,40311490,40311503,40312011,40312020,40312046,"
		cTxt+="40312054,40312062,40312070,40312089,40312097,40312100,40312119,40312127,40312135,40312143,40312151,40312160,"
		cTxt+="40312178,40312186,40312194,40312208,40312216,40312224,40312232,40312240,40312259,40312267,40312275,40312283,"
		cTxt+="40312291,40312305,40312313,40312321,40312330,40312364,40312372,40312380,40312399,40312402,40312410,40312429,"
		cTxt+="40312437,40312445,40312453,40312461,40312470,40313018,40313026,40313034,40313042,40313050,40313069,40313077,"
		cTxt+="40313085,40313093,40313107,40313115,40313123,40313131,40313140,40313158,40313166,40313182,40313190,40313204,"
		cTxt+="40313212,40313220,40313239,40313247,40313255,40313263,40313271,40313280,40313298,40313301,40313310,40313328,"
		cTxt+="40313336,40313344,40313352,40313360,40314014,40314022,40314030,40314049,40314057,40314065,40314073,40314081,"
		cTxt+="40314090,40314103,40314111,40314120,40314138,40314146,40314154,40314162,40314170,40314189,40314197,40314200,"
		cTxt+="40314219,40314227,40314235,40314243,40314251,40314260,40314278,40314286,40314294,40314308,40314316,40314324,"
		cTxt+="40314332,40314340,40314359,40314367,40314375,40314383,40314391,40314405,40314413,40314421,40314430,40314448,"
		cTxt+="40314456,40314472,40314480,40314499,40314502,40314510,40314529,40314537,40314545,40314561,40314570,40314588,"
		cTxt+="40314596,40314600,40314618,40314626,40314642,40314650,40314669,40316017,40316025,40316033,40316041,40316050,"
		cTxt+="40316068,40316076,40316084,40316092,40316106,40316114,40316122,40316130,40316149,40316157,40316165,40316173,"
		cTxt+="40316181,40316190,40316203,40316211,40316220,40316238,40316246,40316254,40316262,40316270,40316289,40316297,"
		cTxt+="40316300,40316319,40316327,40316335,40316343,40316351,40316360,40316378,40316386,40316394,40316408,40316416,"
		cTxt+="40316424,40316432,40316440,40316459,40316467,40316475,40316483,40316491,40316505,40316513,40316521,40316530,"
		cTxt+="40316548,40316556,40316564,40316572,40316580,40316599,40316602,40316610,40316629,40316637,40316645,40316653,"
		cTxt+="40316661,40316670,40316688,40316696,40316718,40316726,40316734,40316742,40316750,40316769,40316777,40316785,"
		cTxt+="40316793,40316807,40316815,40316823,40316831,40316840,40316858,40316866,40316874,40316882,40316890,40316904,"
		cTxt+="40316912,40316920,40316939,40316947,40316955,40316963,40316971,40316998,40317013,40317021,40317030,40317056,"
		cTxt+="40317064,40317072,40317080,40317099,40317102,40317110,40317129,40317137,40317145,40317153,40317161,40317170,"
		cTxt+="40317188,40317196,40317200,40317218,40317226,40317234,40317242,40317250,40317269,40317277,40317285,40317293,"
		cTxt+="40317307,40317315,40317323,40317331,40317340,40317366,40317374,40317382,40317390,40317404,40317412,40317420,"
		cTxt+="40317439,40317447,40317455,40317463,40317471,40317480,40317498,40319016,40319024,40319032,40319040,40319059,"
		cTxt+="40319067,40319075,40319083,40319091,40319105,40319113,40319121,40319130,40319148,40319156,40319164,40319172,"
		cTxt+="40319180,40319199,40319202,40319210,40319229,40319237,40319245,40319253,40319261,40319270,40319288,40319296,"
		cTxt+="40319300,40319318,40319326,40319334,40319342,40319350,40319369,40319377,40319385,40319393,40319407,40319415,"
		cTxt+="40319423,40319431,40319440,40319458,40319466,40319474,40319482,40321010,40321029,40321037,40321045,40321053,"
		cTxt+="40321061,40321070,40321088,40321096,40321100,40321118,40321126,40321134,40321142,40321169,40321193,40321207,"
		cTxt+="40321223,40321231,40321240,40321258,40321266,40321274,40321282,40321290,40321304,40321312,40321320,40321339,"
		cTxt+="40321347,40321355,40321363,40321371,40321380,40321398,40321401,40321410,40321428,40321436,40321444,40321452,"
		cTxt+="40321460,40321479,40321487,40321495,40321509,40321517,40321525,40321533,40321541,40321550,40321568,40321576,"
		cTxt+="40321584,40321592,40321606,40321614,40321622,40321630,40321657,40321665,40321673,40321681,40321690,40321703,"
		cTxt+="40321711,40321720,40321738,40321746,40321754,40321762,40321770,40321789,40321797,40321800,40321819,40321827,"
		cTxt+="40321835,40321843,40321851,40321860,40321878,40321886,40321894,40321908,40321916,40321924,40321932,40321940,"
		cTxt+="40321959,40321967,40321975,40321983,40321991,40322017,40322025,40322033,40322041,40322050,40322068,40322076,"
		cTxt+="40322084,40322092,40322106,40322114,40322122,40322130,40322149,40322157,40322165,40322173,40322181,40322190,"
		cTxt+="40322203,40322211,40322220,40322238,40322246,40322254,40322262,40322270,40322289,40322297,40322300,40322319,"
		cTxt+="40322327,40322335,40322343,40322351,40322360,40322378,40322386,40322394,40322408,40322416,40322424,40322432,"
		cTxt+="40322440,40322459,40322467,40322475,40322483,40322491,40322505,40322513,40322521,40322530,40322548,40322556,"
		cTxt+="40322564,40322572,40323013,40323021,40323030,40323048,40323056,40323064,40323080,40323099,40323102,40323110,"
		cTxt+="40323129,40323137,40323145,40323153,40323161,40323170,40323188,40323196,40323200,40323218,40323234,40323242,"
		cTxt+="40323250,40323269,40323307,40323315,40323323,40323331,40323340,40323358,40323366,40323374,40323382,40323404,"
		cTxt+="40323412,40323420,40323439,40323447,40323455,40323471,40323480,40323498,40323501,40323510,40323528,40323536,"
		cTxt+="40323552,40323579,40323587,40323595,40323609,40323617,40323625,40323641,40323650,40323668,40323676,"
		cTxt+="40323684,40323692,40323706,40323714,40323722,40323730,40323749,40323757,40323765,40323773,40323781,40323790,"
		cTxt+="40323803,40323811,40323846,40323854,40323862,40323870,40323889,40323897,40323900,40323919,40323927,40323935,"
		cTxt+="40323943,40323951,40323960,40323978,40323986,40323994,40324010,40324028,40324036,40324044,40324052,40324060,"
		cTxt+="40324079,40324087,40324095,40324109,40324117,40324125,40324141,40324150,40324168,40324176,40324184,40324192,"
		cTxt+="40324206,40324214,40324222,40324230,40324249,40324257,40324265,40324273,40324290,40324303,40324311,40324320,"
		cTxt+="40324338,40324346,40324354,40324362,40324370,40324389,40324397,40324400,40324419,40324427,40324435,40324443,"
		cTxt+="40324451,40324460,40324478,40324486,40324494,40324508,40324516,40324524,40324532,40324559,40324567,40324575,"
		cTxt+="40324583,40324591,40324605,40324613,40324621,40324630,40324648,40324656,40324664,40324672,40324680,40324699,"
		cTxt+="40324702,40324710,40324729,40324737,40324745,40324753,40324761,40324770,40324788,40324796,40324800,40325016,"
		cTxt+="40325024,40325040,40403025,40403041,40403068,40403084,40403092,40403106,40403130,40403149,40403157,40403165,"
		cTxt+="40403173,40403181,40403190,40403203,40403211,40403220,40403238,40403246,40403254,40403262,40403289,40403327,"
		cTxt+="40403335,40403343,40403351,40403360,40403378,40403386,40403408,40403416,40403424,40403440,40403467,40403483,"
		cTxt+="40403505,40403521,40403548,40403564,40403580,40403602,40403629,40403645,40403661,40403688,40403696,40403700,"
		cTxt+="40403718,40403750,40403769,40403777,40403785,40403793,40403840,40403890,40403920,40403963,40403971,40403980,"
		cTxt+="40403998,40404013,40404030,40404048,40404056,40404064,40404110,40404129,40404137,40404145,40404153,40404161,"
		cTxt+="40404170,40404188,40404196,40404200,40404218,40404226,40404234,40404242,40404269,40404277,40404285,40404293,"
		cTxt+="40404307,40404315,40404323,40404331,40404340,40404358,40404366,40404374,40404382,40404404,40404420,40404439,"
		cTxt+="40404447,40404455,40404463,40404471,40404498,40404501,40404536,40404544,40404552,40404560,40404579,40501019,"
		cTxt+="40501035,40501043,40501051,40501060,40501078,40501086,40501094,40501108,40501116,40501124,40501132,40501140,"
		cTxt+="40501159,40501167,40501175,40501183,40501191,40501205,40501213,40501221,40501230,40501248,40501256,40501264,"
		cTxt+="40501272,40501280,40502015,40502040,40502058,40502066,40502074,40502082,40502090,40502104,40502112,40502120,"
		cTxt+="40502139,40502147,40502155,40502163,40502171,40502180,40502198,40502201,40502210,40502228,40502236,40502244,"
		cTxt+="40503011,40503020,40503038,40503046,40503054,40503062,40503070,40503089,40503097,40503100,40503119,40503127,"
		cTxt+="40503135,40503143,40503151,40503160,40503178,40503186,40503194,40503208,40503216,40503224,40503232,40503240,"
		cTxt+="40503259,40503267,40503275,40503283,40503291,40503305,40503313,40503321,40503330,40503348,40503356,40503364,"
		cTxt+="40503372,40503380,40503399,40503402,40503410,40503429,40503437,40503445,40503453,40503461,40503470,40503488,"
		cTxt+="40503496,40503500,40503518,40503526,40503534,40503542,40503550,40503569,40503577,40503585,40503593,40503607,"
		cTxt+="40503615,40503623,40503631,40503640,40503658,40503666,40503674,40503682,40503690,40503704,40503712,40503720,"
		cTxt+="40503739,40503747,40503755,40503763,40503771,40503780,40503798,40503801,40503810,40503828,40503836,40503844,"
		cTxt+="40503852,40503860,40503879,40503887,40503895,40503909,40503917,40503925,40503933,40503941,40503950,40601048,"
		cTxt+="40601056,40601064,40601072,40601080,40601099,40601102,40601110,40601129,40601145,40601153,40601161,"
		cTxt+="40601170,40601188,40601196,40601200,40601218,40601226,40601234,40601242,40601250,40601269,40601277,40601285,"
		cTxt+="40601293,40601307,40601315,40601331,40601340,40601358,40601366,40601374,40601382,40601390,40601404,"
		cTxt+="40601412,40601420,40601439,40602010,40701018,40701026,40701034,40701042,40701050,40701069,40701077,40701085,"
		cTxt+="40701093,40701107,40701115,40701123,40701131,40701140,40701158,40702014,40702022,40702030,40702049,40702057,"
		cTxt+="40702065,40702073,40702081,40702090,40702103,40702111,40702120,40702138,40702146,40703010,40703029,40703037,"
		cTxt+="40703045,40703053,40703061,40703070,40703088,40703096,40703100,40704017,40704025,40704033,40704041,40704050,"
		cTxt+="40704068,40704076,40704084,40704092,40705013,40705021,40705030,40705048,40705056,40705064,40706010,40706028,"
		cTxt+="40707016,40707024,40707032,40707040,40707059,40707067,40707075,40707083,40707091,40708012,40708020,40708039,"
		cTxt+="40708047,40708055,40708063,40708071,40708080,40708098,40708101,40708110,40708128,40708136,40708144,40708152,"
		cTxt+="40709019,40709027,40709035,40711013,40711021,40801012,40801020,40801039,40801047,40801055,40801063,40801071,"
		cTxt+="40801080,40801098,40801101,40801195,40801209,40802019,40802027,40802035,40802043,40802051,40802060,40802078,"
		cTxt+="40802086,40802094,40802108,40802116,40803015,40803023,40803031,40803040,40803058,40803066,40803074,40803082,"
		cTxt+="40803090,40803104,40803112,40803120,40803139,40803147,40803155,40804011,40804020,40804038,40804046,40804054,"
		cTxt+="40804062,40804070,40804089,40804097,40804100,40804119,40804127,40804135,40805018,40805026,40805034,40805042,"
		cTxt+="40805050,40805069,40805077,40805085,40805093,40806014,40806022,40806030,40806049,40806057,40806065,40806073,"
		cTxt+="40806081,40806090,40806103,40806111,40806120,40806138,40806146,40806154,40806162,40806170,40806189,40806197,"
		cTxt+="40806200,40806219,40807010,40807029,40807037,40807045,40807053,40807061,40807070,40807088,40807096,40807100,"
		cTxt+="40808017,40808025,40808050,40808114,40808122,40808130,40808149,40808157,40808165,"
		cTxt+="40808181,40808190,40808203,40808211,40808220,40808238,40808246,40808254,40808262,40808270,40808319,40808327,"
		cTxt+="40808335,40808343,40808351,40808360,40808378,40808386,40809021,40809030,40809048,40809056,40809064,40809072,"
		cTxt+="40809080,40809110,40809129,40809137,40809145,40809153,40809161,40809170,40809188,40809196,40809200,40809218,"
		cTxt+="40809226,40810011,40810038,40810046,40811018,40811026,40812022,40812030,40812049,40812057,40812073,40812081,"
		cTxt+="40812090,40812103,40812111,40812120,40812138,40812146,40812154,40814130,40901017,40901025,40901033,40901041,"
		cTxt+="40901050,40901068,40901076,40901084,40901092,40901106,40901114,40901122,40901130,40901149,40901173,40901181,"
		cTxt+="40901190,40901203,40901211,40901220,40901238,40901246,40901254,40901262,40901270,40901289,40901297,40901300,"
		cTxt+="40901319,40901327,40901335,40901351,40901360,40901378,40901386,40901394,40901408,40901416,40901424,40901432,"
		cTxt+="40901440,40901459,40901467,40901475,40901483,40901491,40901505,40901513,40901521,40901530,40901548,40901556,"
		cTxt+="40901564,40901572,40901580,40901599,40901602,40901610,40901629,40901637,40901645,40901653,40901661,40901670,"
		cTxt+="40901688,40901696,40901700,40901718,40901726,40901734,40901742,40901750,40901769,40901777,40901785,40901793,"
		cTxt+="40901807,40901815,40901823,40901831,40901840,40901858,40902013,40902021,40902030,40902048,40902137,40902145,"
		cTxt+="40903010,41001010,41001028,41001036,41001044,41001052,41001060,41001079,41001087,41001095,41001109,41001117,"
		cTxt+="41001125,41001133,41001141,41001150,41001176,41001184,41001192,41001206,41001214,41001222,41001230,41001249,"
		cTxt+="41001257,41001265,41001273,41001281,41001290,41001303,41001311,41001320,41001338,41001346,41001354,41001362,"
		cTxt+="41001370,41001389,41001397,41001400,41001419,41001427,41001435,41001443,41001451,41001460,41001478,41001486,"
		cTxt+="41001494,41001508,41001516,41001524,41001532,41002016,41002040,41002059,41003012,41003020,41101014,41101022,"
		cTxt+="41101030,41101049,41101057,41101065,41101073,41101081,41101090,41101103,41101111,41101120,41101138,41101146,"
		cTxt+="41101154,41101170,41101189,41101197,41101200,41101219,41101227,41101235,41101243,41101251,41101260,41101278,"
		cTxt+="41101286,41101294,41101308,41101316,41101332,41101340,41101359,41101375,41101383,41101430,41101448,41101456,"
		cTxt+="41101464,41101472,41101480,41101499,41101502,41101510,41101529,41101537,41101545,41101553,41101561,41101570,"
		cTxt+="41101588,41101596,41101600,41101618,41101626,41101634,41101642,41101650,41101669,41102010,41103017,41103025,"
		cTxt+="41301013,41301021,41301030,41301048,41301056,41301064,41301072,41301080,41301102,41301110,41301129,41301137,"
		cTxt+="41301145,41301153,41301161,41301170,41301188,41301200,41301218,41301226,41301234,41301242,41301250,41301269,"
		cTxt+="41301277,41301285,41301307,41301315,41301323,41301331,41301340,41301358,41301366,41301374,41301382,41301390,"
		cTxt+="41301404,41301412,41301420,41301439,41301447,41301455,41301463,41301471,41301480,41301498,41301510,41301536,"
		cTxt+="41301544,41301552,41301560,41301579,41301587,41301595,41401018,41401026,41401042,41401050,41401069,41401077,"
		cTxt+="41401085,41401093,41401107,41401115,41401123,41401131,41401140,41401158,41401166,41401174,41401182,41401190,"
		cTxt+="41401204,41401212,41401220,41401239,41401247,41401255,41401263,41401271,41401280,41401298,41401301,41401310,"
		cTxt+="41401328,41401336,41401344,41401352,41401360,41401379,41401387,41401395,41401409,41401417,41401425,41401433,"
		cTxt+="41401441,41401450,41401468,41401476,41401484,41401492,41401514,41401522,41401530,41401549,41401557,41401573,"
		cTxt+="41401581,41401590,41401603,41401611,41401620,41401638,41401646,41401662,41401670,41401689,41401697,41401700,"
		cTxt+="41401719,41401743,41401751,41401760,41401778,41401786,41401794,41401808,41501012,41501020,41501047,41501063,"
		cTxt+="41501071,41501080,41501098,41501101,41501110,41501128,41501136,41501144,41501179,41501187,41501195,41501209,"
		cTxt+="41501217,41501225,41501233,41501241,41501250,41501268,41501276,41501284,41501292,41501306,41501314,41501322,"
		cTxt+="41501330,41501349,40501027,30102022,30102030,30102049,30102057,31602347,31602355,40311511,40314677,40314685,"

		If AllTrim(cProc) $ cTxt
			cRet:= "C"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="20101198,20101252,20101260,20101295,20101350,20102151,20102178,20103018,20103026,20103034,20103050,20103069,20103077,20103093,
		cTxt+="20103107,20103115,20103123,20103131,20103140,20103158,20103166,20103174,20103182,20103190,20103204,20103212,20103220,20103239,"
		cTxt+="20103247,20103255,20103263,20103271,20103280,20103298,20103301,20103310,20103328,20103336,20103344,20103360,20103379,20103387,"
		cTxt+="20103395,20103409,20103417,20103425,20103433,20103441,20103450,20103468,20103476,20103484,20103492,20103506,20103514,20103522,"
		cTxt+="20103530,20103549,20103557,20103565,20103573,20103581,20103590,20103603,20103611,20103620,20103638,20103646,20103654,20103662,"
		cTxt+="20103670,20103689,20103697,20103700,20103719,20103727,20103743,20104014,20104022,20104049,20104057,20104065,20104073,20104081,"
		cTxt+="20104090,20104103,20104111,20104120,20104138,20104146,20104154,20104189,20104197,20104200,20104219,20104227,20104235,20104243,"
		cTxt+="20104251,20104278,20104286,20104294,20104308,20104316,20104324,20104332,20104340,20104359,20104367,20104375,20104383,20104391,"
		cTxt+="20104405,20104413,20104421,20104430,20104448,20104456,20104464,20104472,20104480,20104499,20104502,20104510,20104529,20104545,"
		cTxt+="20104561,20105037,20201052,20201087,20203020,20204027,20204035,20204043,20204256,30101018,30101026,30101034,30101042,30101050,"
		cTxt+="30101093,30101107,30101204,30101212,30101247,30101255,30101263,30101280,30101298,30101352,30101387,30101395,30101409,30101417,"
		cTxt+="30101441,30101450,30101468,30101476,30101484,30101492,30101506,30101603,30101611,30101620,30101646,30101654,30101662,30101670,"
		cTxt+="30101697,30101700,30101719,30101735,30101743,30101751,30101760,30101778,30101808,30101824,30101840,30101859,30101891,30101905,"
		cTxt+="30101913,30101921,30101930,30101948,30101956,30101964,30201039,30201047,30201055,30201128,30202159,30205018,30205093,30205107,"
		cTxt+="30207215,30207223,30210119,30212103,30301017,30301033,30301041,30301050,30301068,30301076,30301084,30301092,30301106,30301114,"
		cTxt+="30301122,30301130,30301149,30301157,30301190,30301203,30301238,30301246,30301254,30301262,30301270,30303044,30303052,30303060,"
		cTxt+="30303087,30303117,30304016,30304032,30304040,30304059,30304083,30304091,30304105,30304156,30305012,30306019,30306027,30306035,"
		cTxt+="30306043,30306060,30306078,30306086,30306116,30307082,30307139,30307147,30310016,30310024,30310067,30310075,30310083,30310105,"
		cTxt+="30310113,30310130,30310172,30311055,30312043,30312124,30312132,30312140,30312159,30313040,30313066,30401038,30401046,30401054,"
		cTxt+="30401100,30402018,30402034,30402077,30402093,30403014,30403103,30403162,30404070,30404142,30501016,30501024,30501067,30501075,"
		cTxt+="30501083,30501113,30501121,30501130,30501156,30501164,30501172,30501199,30501237,30501288,30501377,30501440,30501482,30501512,"
		cTxt+="30501520,30501539,30501547,30502160,30502179,30502292,30502306,30502349,30502357,30502365,30601223,30601231,30601304,30601312,"
		cTxt+="30602025,30602050,30602068,30710057,30711010,30711029,30711037,30712017,30712025,30712033,30712041,30712050,30712068,30712076,"
		cTxt+="30712084,30712092,30712106,30712114,30712122,30712130,30712149,30713137,30713145,30714028,30715121,30715130,30715156,30715237,"
		cTxt+="30715342,30717043,30717086,30717094,30717175,30718023,30718040,30718066,30718104,30719054,30719070,30719097,30719119,30720044,"
		cTxt+="30720087,30720109,30721091,30721105,30721130,30721156,30721172,30721180,30722012,30722039,30722160,30722241,30722292,30722349,"
		cTxt+="30722357,30722365,30722373,30722381,30722403,30722446,30722497,30722527,30722535,30722551,30722586,30722632,30722640,30722691,"
		cTxt+="30722713,30722764,30722900,30722918,30723019,30723035,30723060,30723094,30723108,30723116,30724112,30724163,30725046,30725062,"
		cTxt+="30725100,30725119,30725178,30725186,30725194,30725208,30726050,30726085,30726093,30726115,30726174,30727057,30727103,30727120,"
		cTxt+="30727146,30727197,30728088,30728096,30728118,30728134,30729068,30729114,30729130,30729149,30729165,30729262,30729343,30730112,"
		cTxt+="30730120,30730139,30730163,30730171,30731011,30731046,30731089,30731186,30731194,30731259,30732050,30732069,30801044,30801184,"
		cTxt+="30804086,30804116,30904013,30904170,30907063,30907071,30908027,30908078,30909031,30909139,30909147,30909155,30912016,30912334,"
		cTxt+="30913012,30913071,30913080,30913098,30913101,30913128,30913144,30913152,30914019,30918057,31003362,31004016,31004024,31004032,"
		cTxt+="31004040,31004059,31004075,31004172,31004180,31004199,31004202,31004210,31004229,31004253,31004261,31004318,31008011,31008020,"
		cTxt+="31008038,31008046,31008119,31009018,31009026,31009352,31101089,31101313,31102018,31103057,31103189,31103197,31103235,31103391,"
		cTxt+="31103405,31103430,31103448,31103596,31104010,31104045,31104061,31104142,31104169,31202020,31202047,31203086,31204023,31204066,"
		cTxt+="31205011,31205046,31205070,31206174,31206204,31206212,31206220,31301010,31301045,31301070,31301088,31301096,31301100,31301118,"
		cTxt+="31301142,31302076,31302084,31302114,31303064,31303072,31303170,31303196,31303269,31303293,31303307,31303331,31303340,31303366,"
		cTxt+="31303374,31303382,31306047,31308040,31309240,31401350,31402038,31403026,31403301,31403328,31404030,31405010,31601014,31602010,"
		cTxt+="31602029,31602070,31602118,31602126,31602185,31602207,31602215,31602223,31602240,31602290,31602339,40201325,40201376,40201384,"
		cTxt+="40201392,40201406,40202011,40202062,40202070,40202089,40202097,40202143,40202186,40202194,40202224,40202232,40202259,40202267,"
		cTxt+="40202283,40202330,40202348,40202356,40202364,40202372,40202399,40202410,40202445,40202453,40202470,40202496,40202518,40202534,"
		cTxt+="40202542,40202550,40202569,40202577,40202585,40202593,40202607,40202623,40202658,40202674,40202682,40202704,40202712,40202739,"
		cTxt+="40202755,40202763,40202771,40401014,40401022,40401057,40402029,40402037,40402045,40402053,40402061,40402070,40402088,40402096,"
		cTxt+="40402100,40402118,40402126,40402134,40402142,40402150,40402169,40402177,40402185,40402193,40402207,40402223,40402231,40403033,"
		cTxt+="40403939,40403947,40403955,40404390,40404412,40404480,40404510,40404528,40710017,40710025,40710033,40710041,40710050,40710068,"
		cTxt+="40710076,40710084,40710092,40710106,40710114,40710122,40808289,40808297,40808300,40809102,40813053,40813363,40813410,40813428,"
		cTxt+="40813436,40813444,40813452,40813460,40813479,40813487,40813495,40813509,40813517,40813525,40813533,40813860,40814114,40814149,"
		cTxt+="40902110,40902129,41002032,41203011,41203020,41203038,41203046,41203054,41203062,41203070,41203089,41203097,41203100,41203119,"
		cTxt+="41203127,41203135,41203143,41203151,41203208,41204018,41204050,41204069,41204077,41204085,41204093,41204107,41205014,41205022,"
		cTxt+="41205030,41205073,41205120,41206010,41206037,41206045,41206053,41206061,41206070,20104588"

		If AllTrim(cProc) $ cTxt
			cRet:= "D"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="50000012,50000020,50000039,50000047,50000055,50000063,50000080,50000098,50000110,50000128,50000136,50000144,50000160,50000195,50000209,"
		cTxt+="50000217,50000233,50000241,50000250,50000268,50000276,50000284,50000292,50000306,50000314,50000322,50000330,50000446,50000470,"
		cTxt+="50000489,50000497,50000500,50000519,50000535,50000543,50000551,50000560,50000578,50000586,50000594,50000616,50000624,50000640,50000659,"
		cTxt+="50000667,50000675,50000683,50000705,50000713,50000730,50000748,50000756,50000764,50000772,50000780,50000837,50000845,50000853,50000861,"
		cTxt+="50000870,50000888,50000896,50000900,50000918,50000926,50000934,50001078,50001167,50001183,50001191,50001205,50001213,50001221,50001248"

		If AllTrim(cProc) $ cTxt
			cRet:= "B"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="30202027,30203031,30211018,40801110,40801160,40801179,40801187,81000324,"
		cTxt+="81000367,81000430,81000472,81000510,81000529,81000561,82000280"

		If AllTrim(cProc) $ cTxt
			If cTipGui == "13"
				cRet:= "I"
			else
				cRet:= "C"
			EndIF
		ENDIF

	ENDIF

	If Empty(cRet)

		cTxt:="30101638,30101786,30101794,30201012,30201063,30203015,30204011,30204038,30204097,30207231,30208041,82000298,82000301,"
		cTxt+="82000581,82000603,82000743,82000778,82000786,82000794,82000808,82000883,82000891,82000905,82000913,82001006,82001022,"
		cTxt+="82001030,82001197,82001219,82001235,82001367,82001375,82001391,82001413,82001430,82001499,82001510,82001529,82001545,"
		cTxt+="82001553,82001588,82001596,82001618,82001634,82001642,82001758"

		If AllTrim(cProc) $ cTxt
			If cTipGui == "13"
				cRet:= "I"
			else
				cRet:= "D"
			EndIF
		ENDIF
	ENDIF

	If Empty(cRet) .And. cTipGui == "13"

		cTxt:="81000014,81000030,81000049,81000057,81000065,81000073,81000090,81000111,81000138,81000154,81000170,81000189,81000197,81000200,81000219,81000235,"
		cTxt+="81000243,81000260,81000278,81000294,81000308,81000340,81000375,81000405,81000413,81000421,81000456,81000480,81000537,81000545,81000553,"
		cTxt+="81000570,82000026,82000034,82000050,82000069,82000077,82000085,82000158,82000166,82000174,82000182,82000190,82000212,82000336,82000344,82000352,"
		cTxt+="82000360,82000387,82000395,82000417,82000441,82000468,82000484,82000506,82000522,82000549,82000557,82000620,82000646,82000662,82000689,82000700,"
		cTxt+="82000816,82000832,82000859,82000875,82000921,82000948,82000964,82000980,82001049,82001057,82001065,82001073,82001103,82001120,82001138,82001170,"
		cTxt+="82001189,82001243,82001251,82001286,82001294,82001308,82001316,82001324,82001332,82001448,82001456,82001464,82001502,82001650,82001669,82001685,"
		cTxt+="82001707,82001715,82001723,82001731,82001740,82001766,83000020,83000046,83000062,83000089,83000097,83000100,83000127,83000135,83000151,84000015,"
		cTxt+="84000031,84000058,84000074,84000090,84000112,84000139,84000163,84000171,84000198,84000201,84000228,84000236,84000252,85000787,85100013,85100021,"
		cTxt+="85100030,85100048,85100056,85100064,85100072,85100080,85100099,85100102,85100110,85100129,85100137,85100145,85100153,85100161,85100170,85100196,"
		cTxt+="85100200,85100218,85100226,85100234,85100242,85100250,85100269,85200018,85200026,85200034,85200042,85200050,85200069,85200077,85200085,85200093,"
		cTxt+="85200107,85200115,85200123,85200131,85200140,85200158,85200166,85200174,85200182,85300012,85300020,85300039,85300047,85300055,85300063,85300071,"
		cTxt+="85300080,85300098,85300101,85400017,85400025,85400033,85400041,85400050,85400068,85400076,85400084,85400092,85400106,85400114,85400122,85400130,"
		cTxt+="85400149,85400157,85400165,85400173,85400181,85400190,85400203,85400211,85400220,85400238,85400246,85400254,85400262,85400270,85400289,85400297,"
		cTxt+="85400300,85400319,85400327,85400335,85400343,85400351,85400360,85400378,85400386,85400394,85400408,85400416,85400424,85400432,85400440,85400459,"
		cTxt+="85400467,85400475,85400483,85400491,85400505,85400513,85400521,85400530,85400548,85400556,85400564,85400572,85400580,85400599,85400602,85400610,"
		cTxt+="85500011,85500020,85500038,85500046,85500054,85500062,85500070,85500089,85500097,85500100,85500119,85500127,85500135,85500143,85500151,85500160,"
		cTxt+="85500178,85500186,85500194,85500208,85500216,85500224,86000012,86000020,86000039,86000047,86000055,86000063,86000080,86000098,86000110,86000128,"
		cTxt+="86000144,86000152,86000160,86000179,86000187,86000195,86000209,86000225,86000233,86000241,86000250,86000268,86000276,86000284,86000292,86000306,"
		cTxt+="86000314,86000322,86000330,86000357,86000365,86000373,86000381,86000390,86000403,86000411,86000420,86000438,86000446,86000454,86000462,86000470,"
		cTxt+="86000489,86000497,86000500,86000519,86000527,86000535,86000543,86000551,86000560,86000578,86000586,86000594,86000608,86000616,87000016,87000024,"
		cTxt+="87000032,87000040,87000059,87000067,87000148,87000164,87000180,87000199"

		If AllTrim(cProc) $ cTxt
			cRet:= "I"
		EndIF
	ENDIF

	If Empty(cRet)

		cTxt:="40708144,40708152,40808335,40808343,40808351,40808360,40808378,40808386,40903010,41003012,41003020,41103017,41103025,41204026,41204034,41204042,41301099"

		If AllTrim(cProc) $ cTxt
			cRet:= "H"
		EndIF
	ENDIF

Return cRet

Function PLSBSCB19(cChave,lBscB19)
	Local cSql      := ""
	Local lRet      := .F.
	Default cChave  := ""
	Default lBscB19  := .F.

	cSql := " SELECT COUNT(*) TOTAL FROM " + RetSqlName("B19") +""
	cSql += " WHERE B19_FILIAL = '"+Xfilial("BD7")+"' "

	If !lBscB19
		cSql += " AND B19_GUIA = '"+cChave+"' "
	EndIf

	cSql += " AND D_E_L_E_T_='' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql), "TRBB19",.F.,.T.)

	cSql := ChangeQuery(cSql)

	lRet:= TRBB19->TOTAL >= 1
	TRBB19->(dbCloseArea())

Return lRet

Function PlsBG9Tem(cRegANS, cTipo, nQtdReg, oTmpTable, nThead,cEmInici,cEmFinal)
	Local cSql      := ""
	Local aColumns  := {}
	Local nQtd      := 0
	Local lSql      := Alltrim(Upper(TCGetDb())) $ "MSSQL"
	Local lPOSTGRES := SubStr(Alltrim(Upper(TCGetDb())), 1, 8) $ "POSTGRES"
	Local nCont     := 1
	Local nRet      := 0
	Default cTipo   := ""
	Default nQtdReg := 0
	Default nThead  := 1
	Default cEmFinal:= ""
	Default cEmInici:= ""

    If cTipo == "1"   
        // Define os campos da tabela temporária
        aAdd(aColumns, { "BG9_CODIGO", "C", 04, 0 })
        aAdd(aColumns, { "OK", "C", 1, 0 })

        // Cria a tabela temporária
        oTmpTable := FWTemporaryTable():New("TMPBG9")
        oTmpTable:SetFields(aColumns)
        oTmpTable:Create()

        // Define a query para buscar os dados da tabela BG9 e inserir na tabela temporária
        cSql := " INSERT INTO " + oTmpTable:GetRealName() + " (BG9_CODIGO, OK) "
        cSql += " SELECT BG9.BG9_CODIGO,' ' FROM " + RetSqlName("BG9") + " BG9, " + RetSqlName("BA0") + " BA0 "
        cSql += "   WHERE BG9.BG9_FILIAL = '" + xFilial("BG9") + "' "
        cSql += "   	AND BG9.BG9_FILIAL = BA0.BA0_FILIAL "
        iif(!lSql,cSql += "   	AND BG9.BG9_CODINT = BA0.BA0_CODIDE || BA0.BA0_CODINT ",cSql += "   	AND BG9.BG9_CODINT = BA0.BA0_CODIDE + BA0.BA0_CODINT ")
        cSql += "   	AND BA0.BA0_SUSEP = '" + cRegANS + "' "
        cSql += "   	AND BG9.BG9_REPASS <> '1' "
        cSql += "   	AND BG9.D_E_L_E_T_ = ' ' "
        cSql += "   	AND BA0.D_E_L_E_T_ = ' ' "
        cSql += "   	ORDER BY BG9.BG9_CODIGO  "

        nRet := TCSQLEXEC(cSql)
        IIf(nRet >= 0 .AND. !lSql, nRet := TCSQLEXEC("COMMIT"), "")

        // Conta o número de registros inseridos
        cSql := "SELECT COUNT(*) AS TOTAL FROM " + oTmpTable:GetRealName() +" "
        DbUseArea(.T., "TOPCONN", TCGENQRY(,,cSql), "TRBBG9", .F., .T.)
        nQtd := TRBBG9->TOTAL
        TRBBG9->(DbCloseArea())

	ElseIf cTipo == "2"

		If nThead < 10
			cSql := IIF(lSql, "SELECT TOP " + cvaltochar(nQtdReg) + " BG9_CODIGO FROM " + oTmpTable:GetRealName() + " WHERE OK = ' ' ",;
			" SELECT BG9_CODIGO FROM " + oTmpTable:getrealName() + " WHERE OK = ' ' " + IIF(lPostGres, " LIMIT  ", " AND ROWNUM <= ") + cvaltochar(nQtdReg) + "")
		Else
			cSql := IIF(lSql, "SELECT BG9_CODIGO FROM " + oTmpTable:GetRealName() + " WHERE OK = ' ' ",;
			" SELECT BG9_CODIGO FROM " + oTmpTable:getrealName() + " WHERE OK = ' ' ")
		EndIf
		cSql := ChangeQuery(cSql)

		DbUseArea(.T., "TOPCONN", TCGENQRY(,,cSql), "TRBTEMP", .F., .T.)

		nCont := 1

		While !TRBTEMP->(Eof())
			cReserv := TRBTEMP->BG9_CODIGO
			If nCont == 1
				cEmInici := TRBTEMP->BG9_CODIGO
				nCont++
			Else
				nCont++
			EndIf

			TRBTEMP->(DbSkip())

			If TRBTEMP->(Eof())
				cEmFinal := cReserv
			EndIf
		EndDo

		IIF(SELECT("TRBTEMP") > 0, TRBTEMP->(DbCloseArea()), "")

		If nThead < 10
			cSql := IIF(lSql, "UPDATE TOP(" + cvaltochar(nQtdReg) + ")" + oTmpTable:getrealName() + " SET OK = 'S' WHERE OK = ' ' ",;
			" UPDATE " + oTmpTable:getrealName() + " SET OK = 'S' WHERE OK = ' ' " + IIF(lPostGres, " LIMIT  ", " AND ROWNUM <= ") + cvaltochar(Int(nQtdReg)) + "")
		Else
			cSql := IIF(lSql, "UPDATE " + oTmpTable:getrealName() + " SET OK = 'S' WHERE OK = ' ' ",;
			" UPDATE " + oTmpTable:getrealName() + " SET OK = 'S' WHERE OK = ' ' ")
		EndIf

		nRet := TCSQLEXEC(cSql)
		IIf(nRet >= 0 .AND. !lSql,nRet := TCSQLEXEC("COMMIT"),"")

	ElseIf cTipo == "3"
		oTmpTable:Delete()
		oTmpTable := Nil

	ElseIf cTipo == "4"
		cSql := IIF(lSql, "UPDATE " + oTmpTable:getrealName() + " SET OK = '' WHERE OK <> '' ",;
		" UPDATE " + oTmpTable:getrealName() + " SET OK = '' WHERE OK <> '' ")

		nRet := TCSQLEXEC(cSql)
		IIf(nRet >= 0 .AND. !lSql,nRet := TCSQLEXEC("COMMIT"),"")
		
	EndIf

Return nQtd
