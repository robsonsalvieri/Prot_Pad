#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPIRJ003.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPIRJ003

Adapter REST da rotina de TARIFAS

@type 		function
@sample 	GTPIRJ003(lJob)
@param 	 	lJob, logical - indica se a chamada foi realizada através de JOB (.T.) ou não (.F.)
@return		Logical - informa se o processo foi finalizado com sucesso (.T.) ou não (.F.)	 	
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPIRJ003(lJob,lAuto,aParams,lMonit)

	Local aArea := GetArea()
	Local lRet  := .T.

	Default lJob := .F.
	Default aParams := {}

	If !lJob

		If ( Len(aParams) > 0 )
			MV_PAR01	:= aParams[01]
		Else
			If !Pergunte("GTPIRJ003", .T.)
				Return
			EndIf
		EndIf

		FwMsgRun( , {|oSelf| lRet := GI003Receb(lJob, oSelf, MV_PAR01, lAuto, @lMonit, MV_PAR02)}, , STR0001)		// "Processando registros de Tarifas... Aguarde!"

		Pergunte("GTPIRJ003", .F.)

	Else
		Pergunte("GTPIRJ003", .F.)
		lRet := GI003Receb(lJob, nil, MV_PAR01, lAuto)
	EndIf

	RestArea(aArea)
	GTPDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI003Receb

Função utilizada para executar o recebimento da integração e atualizar o registro

@type 		function
@sample 	GI003Receb(lJob, oMessage)
@param 		lJob, logical    - informa se a chamada foi realizada através de job (.T.) ou não (.F.) 
			oMessage, objeto - trata a mensagem apresentada em tela
@return 	lRet, logical    - resultado do processamento da rotina (.T. / .F.)
@author 	thiago.tavares
@since 		03/04/2019
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Static Function GI003Receb(lJob, oMessage, dDtVigencia, lAuto, lMonit, cEmpRJ)

	Local aArea       := GetArea()
	Local oRJIntegra  := GtpRjIntegra():New()
	Local aFldDePara  := {}
	Local aDeParaXXF  := {}
	Local cErro       := ""
	Local cResultAuto := ""
	Local cFilBkp     := cFilAnt
	Local nTotReg     := 0
	Local lRet        := .T.
	Local lMessage    := ValType(oMessage) == 'O'
	Local cRotina     := "GTPIRJ003"
	Local aDados      := {}
	Local nThread     := GTPGetRules("NRTHIRJ003")
	Local oGrid       := Nil
	Local cError      := ''
	Local nX          := 0
	Local cFilRJ      := ""
	Local cIdEmpresa  := ""
	Local cUrl        := ""
	Local cPath       := ""
	Local cParam      := ""
	Local lError      := .F.

	Default cEmpRJ := ""
	Default dDtVigencia := dDataBase-1

	If !Empty(cEmpRJ)
		oRJIntegra:SetPath("/preco/porLinha")
		oRJIntegra:SetParam('empresa', Alltrim(cEmpRJ))
	Else 
		oRJIntegra:SetPath("/preco")
	EndIf 		

	oRJIntegra:SetParam('dataVigencia', DtoS(dDtVigencia))

	oRJIntegra:SetServico("Tarifa")

	// Para garantir a informação correta do parâmetro
	nThread:= Iif(nThread==0,1,nThread)

	// Limitar a quantidade threads a 40
	If nThread > 40
		nThread := 40
	EndIf 

	aFldDePara := oRJIntegra:GetFieldDePara()
	aDeParaXXF := oRJIntegra:GetFldXXF()
	cUrl       := oRJIntegra:cUrl
	cPath      := oRJIntegra:cPath
	cParam     := oRJIntegra:cParam	

	If oRJIntegra:Get(cResultAuto)

		oRJIntegra:GetJsonArray( oRJIntegra:cResult, 'preco', cEmpRJ )
		aDados  := oRJIntegra:aJsonDados
		nTotReg := Len(aDados)

		nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)
		
		If ( nTotReg > 0 )

			//Para garantir a quantidade necessaria para processamento
			If nTotReg < nThread
				nThread := nTotReg
			EndIf 

			//Objeto do Controlador de Threads (Instancia para Exec das Threads)
			oGrid := FWIPCWait():New("GTPIRJ003"+cEmpAnt)

			//Inicia as Threads
			oGrid:SetThreads(nThread)

			//Informa o Ambiente Para Exec da Thread
			oGrid:SetEnvironment( cEmpAnt , cFilAnt )

			//Funcao para ser executada na Thread
			oGrid:Start("GTPIRJ003A")

			//Se der erro em alguma Thread sai imediatamente.	
			oGrid:SetNoErrorStop(.T.)

			For nX := 1 to nTotReg				
				cIdEmpresa := oRJIntegra:GetJRetValue(aDados[nX]['idEmpresa'], 'idEmpresa', 'C')
				cFilRJ     := oRJIntegra:GetEmpRJ(cEmpAnt, cFilAnt, cIdEmpresa, , "2")
				oGrid:Go( aDados[nX], aFldDePara, aDeParaXXF, oRJIntegra:cUrl, oRJIntegra:cPath, cRotina, oRJIntegra:cParam, cFilRJ )
				If lMessage .And. !lJob
					oMessage:SetText(I18N(STR0002, {cValtoChar(nX + 1), nTotReg + 1}))		// "Processando registros de Tarifas - #1/#2... Aguarde!"
					ProcessMessages()					
				EndIf				
			Next nX			

			//Fechamento das Threads Iniciadas (O metodo aguarda o encerramentos de todas as Threads antes de retornar ao controle)
			oGrid:Stop()

			cError := oGrid:GetError()
			lError := Iif( !Empty(cError), GtpGrvLgRj(STR0010, cUrl, cPath, cRotina, cParam, cErro) ,.F. )

			FreeObj(oGrid)
			oGrid := Nil

		Else			
			lMonit := .F.
			If !lJob
				If lMessage
					FwAlertHelp("Não há dados a serem processados com a parametrização utilizada.")
				endif
			Endif
			
		EndIf

	Else

		cError := I18N( STR0008, {oRJIntegra:GetLastError(),oRJIntegra:cUrl}) //"Falha ao processar o retorno do serviço #2 (#1)."
		If !Empty(cError)
			GtpGrvLgRj(STR0010,	cUrl,cPath,cRotina,cParam,cErro) //"Trechos da Linha"
		EndIf 

	EndIf

	If !lJob
		If lMessage
			oMessage:SetText(STR0009) // "Processo finalizado."
			ProcessMessages()
		EndIf
	EndIf

	RestArea(aArea)

	oRJIntegra:Destroy()
	GTPDestroy(aFldDePara)
	GTPDestroy(aDeParaXXF)
	cFilAnt := cFilBkp
	lError  := Nil

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GI003JOB

Função utilizada para consumir o serviço através de um JOB

@type 		function
@sample 	GI003JOB(aParams)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	João Pires
@since 		31/03/2025
@version 	1.0
/*/
//GI003JOB('20200326','10)
//------------------------------------------------------------------------------------------
Function GI003JOB(aParam, lAuto)
Local nPosEmp := 0
Local nPosFil := 0
Local lJob 	  := .T.

Default lAuto := .F.

nPosEmp := IF(Len(aParam) == 6, 3, IF(Len(aParam) == 5, 2, 1))
nPosFil := IF(Len(aParam) == 6, 4, IF(Len(aParam) == 2, 3, 2))

If ValType(aParam[1]) == 'C'
	aParam[1] := STOD(aParam[1])
Endif

//---Inicio Ambiente
RPCSetType(3)
RpcSetEnv(aParam[nPosEmp],aParam[nPosFil])

If Len(aParam) > 4
	GI003Receb(lJob, , aParam[1], lAuto, .F., aParam[2])
EndIf

RpcClearEnv()

Return
