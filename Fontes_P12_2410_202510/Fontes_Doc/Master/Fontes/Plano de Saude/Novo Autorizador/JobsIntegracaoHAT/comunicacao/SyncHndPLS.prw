#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"
#INCLUDE "PLSMGER.CH"

#Define PROCESSED '1'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SyncHndPLS
    Classe Handle

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class SyncHndPLS From SyncHandler

    Data cCodOpe as String
	Data cSusep as String
    Data cCodTrans as String
    Data cAlias as String
    Data cPedido as String
    Data cChaveBNV as String
    Data _StSuccess as String
    Data _StError as String
    Data nIDINT as Integer
    Data lFindBNV as Boolean
    Data lFindBNN as Boolean
    Data cRandomKey as String

	 //Atributos Comunicacao PLS > HAT
    Data cVersao as String
    Data cAPI as String
    Data cJson as String
    Data cResponse as String
    Data cErrorAPI as String
    Data lLogPlsHat as Boolean
	Data cToken as String
	Data cActionGet as String
	Data cExpand as String
	Data lAuto as Boolean
    Data cJsAutPost as String
    Data cJsAutGet as String
    
    Method New()
    Method procPedido()
	Method procGetTok()
    Method grvPedido()
    Method grvGetPed()
    Method freeArr(aArray)
    Method setDadBNV(cPedido,cAlias,cChaveBNV,nIDINT)
    Method setDadBNN(cCodTrans)
    Method retDadArr()
    Method errorCriPed(cAlias,cCodigo)
    Method ajustType(aRet)
    Method posicBA0()
    
	//Metodos Comunicacao PLS > HAT
    Method setupPost()
	Method setupGet()
    Method logPlsToHat(cMsg,lDateTime)
    Method getTimeLog()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class SyncHndPLS

    _Super:new()
    self:cCodOpe    := ''
	self:cSusep     := ''
    self:cCodTrans  := ''
    self:cAlias     := ''
    self:cPedido    := ''
    self:cChaveBNV  := ''
    self:_StSuccess := '3'
    self:_StError   := '2'
    self:nIDINT     := 0
    self:lFindBNV   := .F.
    self:lFindBNN   := .F.

	//Atributos Comunicacao PLS > HAT
    self:cJson      := ""
    self:cVersao    := ""
    self:cAPI       := ""
    self:cResponse  := ""
    self:cErrorAPI  := ""
    self:lLogPlsHat := GetNewPar("MV_PHATLOG","0") == "1"
	self:cToken     := ""
	self:cActionGet := ""
	self:cExpand    := ""
    self:cRandomKey := UUIDRandom()
    self:lAuto      := .F.
    self:cJsAutPost := ""
    self:cJsAutGet  := ""

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} procPedido

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method procPedido() Class SyncHndPLS

    if self:lFindBNN
        self:mntJson()
        if !empty(self:cJson)
            self:setupPost()
            self:grvPedido()
        endIf
    else
        self:grvPedido()
    endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} procGetStat

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method procGetTok() Class SyncHndPLS

	self:cActionGet := "/integration/"
	self:setupGet()
	self:grvGetPed()
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} grvPedido
Grava o resultado da comunicacao de um pedido

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method grvPedido() Class SyncHndPLS

    Local nTry      := 0
    Local cToken    := ""
    Local aCampos   := {}  
    Local lFindBWB  := .F.
    Local oResponse := JsonObject():New()
    Local cResponse := ''
    Local cStatus   := ""
    
    if self:lFindBNN
        cResponse := iif(self:lAuto, self:cJsAutPost, self:oClient:GetResult() )
        oResponse:fromJSON(cResponse)
    endIf

    if self:lSuccess .And. oResponse['serviceResponse']
        
        cToken := oResponse['tokenProcess']
		BWB->(DbSetOrder(1)) //BWB_FILIAL+BWB_CODIGO
		//Se ja existia arquivo de erro, devo atualiza-lo com o sucesso
		if BWB->(MsSeek(xFilial("BWB")+self:cPedido))
			aadd( aCampos,{ "BWB_CODIGO", self:cPedido })
			aadd( aCampos,{ "BWB_RETORN", oResponse['detailedMessage'] })
			aadd( aCampos,{ "BWB_DATATU", Date() })
			aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
			PLS277GRV( K_Alterar, aCampos )
		endIf

    elseIf !self:lSuccess
        BWB->(DbSetOrder(1)) //BWB_FILIAL+BWB_CODIGO
		lFindBWB := BWB->(MsSeek(xFilial("BWB")+self:cPedido))
		aadd( aCampos,{ "BWB_CODIGO", self:cPedido })
		aadd( aCampos,{ "BWB_RETORN", self:cErrorAPI })
		aadd( aCampos,{ "BWB_DATATU", Date() })
		aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
		PLS277GRV( iif(lFindBWB,K_Alterar,K_Incluir), aCampos )
    endIf

    //Atualiza o pedido
	BNV->(DbSetOrder(1)) //BNV_FILIAL+BNV_CODIGO
	if BNV->(MsSeek(xFilial("BNV")+self:cPedido))
		aCampos := {}
        nTry := iif(self:lSuccess,1,BNV->BNV_QTDTRY + 1) //Se sucesso, retorno para 1 para resetar o Try do Get
        cStatus := iif(self:lSuccess,self:_StSuccess,self:_StError)
        cStatus := iif(!self:lFindBNN,'5',cStatus) //Se nao achou BNN vamos forcar status 5 para remover da fila

        //Essa requisicao de cancelamento realiza a operacao direto e nao devolve token, 
        //entao deve ter o status de processado para nao ser pego pelo schedule e ficar em looping gerando erros
        if self:cCodTrans == _cancel_BEA_atu .And. self:lSuccess
            if Len(oResponse["msgError"]) == 0 .AND. oResponse["canceledAuthorizationReceipt"] <> nil
                cStatus := self:_StSuccess
                self:logPlsToHat("Cancelamento realizado com sucesso.")
            else
                cStatus := "5"
                self:logPlsToHat("Nao foi possivel realizar o cancelamento, pedido sera encerrado.")
            endIf
        endif

        self:logPlsToHat("Numero de tentativas atualizado: " + cValToChar(nTry))
        self:logPlsToHat("Status atualizado: " + cStatus + iif(cStatus=="5"," - Apresentado erro controlado, encerrando pedido","") )

		aadd( aCampos,{ "BNV_TOKEN", cToken })
        aadd( aCampos,{ "BNV_QTDTRY", nTry })
        aadd( aCampos,{ "BNV_JSON", self:cJson })
		aadd( aCampos,{ "BNV_STATUS", cStatus })
		PLS274GRV( K_Alterar, aCampos )
	endIf

	FreeObj(oResponse)
    oResponse := nil

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} grvGetPed
Grava o resultado da comunicacao de um get de statsu de processamento

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method grvGetPed() Class SyncHndPLS

    Local nI        := 0
    Local aCampos   := {}  
    Local lFindBWB  := .F.
    Local oResponse := JsonObject():New()
    Local cResponse := iif(self:lAuto, self:cJsAutGet, self:oClient:GetResult() )

    oResponse:fromJSON(cResponse)
    if !self:lSuccess .Or. (self:lSuccess .And. oResponse['code'] == 404)

		BWB->(DbSetOrder(1)) //BWB_FILIAL+BWB_CODIGO
		if BWB->(MsSeek(xFilial("BWB")+self:cPedido))
			lFindBWB := .T. //Se ja existe o registro de retorno, atualizarei
		endIf
		aadd( aCampos,{ "BWB_CODIGO", self:cPedido })

		if self:lSuccess //Quando a resposta e um 404, gravo o retorno do json
			aadd( aCampos,{ "BWB_CODRET", cValtoChar(oResponse['code']) })
			aadd( aCampos,{ "BWB_RETORN", oResponse['message'] })
		else //Em caso de erro, gravo o retorno do FwRest
			aadd( aCampos,{ "BWB_RETORN", self:cErrorAPI })
		endIf

		aadd( aCampos,{ "BWB_DATATU", Date() })
		aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
		PLS277GRV( iif(lFindBWB,K_Alterar,K_Incluir), aCampos )

	//-----------------------------------------------
	// Tratativa para token processado com sucesso
	//-----------------------------------------------
	else
		//Quando retornar algum dado no token, armazenar a mensagem
		//"0=Pend.Envio;1=Erro Cri.Pedido;2=Pend.Recomun;3=Pend.Process;4=Proc.Erro;5=Proc.Sucesso;9=Ped.Subst."
		Do Case
			case oResponse['code'] == 0 //'Aguardando finalizacao da validacao e processamento.'
				cStatusCode := "3" //3=Pend.Process

			case oResponse['code'] == 1 //'Validacao OK. Aguardando processamento.'
				cStatusCode := "3" //3=Pend.Process

			case oResponse['code'] == 2 //'Erros encontrados em alguns itens durante a validacao. Aguardando processamento dos demais itens.'
				cStatusCode := "3" //3=Pend.Process

			case oResponse['code'] == 3 //'Erros encontrados na validacao de todos os itens. Verifique os dados enviados e tente novamente.'
				cStatusCode := "4" //4=Proc.Erro

			case oResponse['code'] == 4 //'Processamento finalizado com sucesso.'
				cStatusCode := "5" //5=Proc.Sucesso

			case oResponse['code'] == 5 //'Alguns erros foram encontrados durante o processamento.'
				cStatusCode := "4" //4=Proc.Erro

			case oResponse['code'] == 6 //'Erros encontrados durante o processamento. Verifique os dados enviados e tente novamente.'
				cStatusCode := "4" //4=Proc.Erro

		EndCase

		aCampos := {}
		cDetails := ""
		for nI := 1 to Len(oResponse['detailedMessage'])
			cDetails += oResponse['detailedMessage'][nI]
		next nI

		//Atualiza tabela com detalhes da mensagem
		BWB->(DbSetOrder(1))//BWB_FILIAL+BWB_CODIGO
		lFindBWB := BWB->(MsSeek(xFilial("BWB")+self:cPedido))

		aadd( aCampos,{ "BWB_CODIGO", self:cPedido })
		aadd( aCampos,{ "BWB_CODRET", cValtoChar(oResponse['code']) })
		aadd( aCampos,{ "BWB_RETORN", cDetails })
		aadd( aCampos,{ "BWB_DATATU", Date() })
		aadd( aCampos,{ "BWB_HORATU", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
		PLS277GRV( iif(lFindBWB,K_Alterar,K_Incluir), aCampos )

		//Atualiza o pedido
		BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
		if BNV->(MsSeek(xFilial("BNV")+self:cPedido))
			aCampos := {}
			aadd( aCampos,{ "BNV_STATUS", cStatusCode })
			PLS274GRV( K_Alterar, aCampos )
		endIf

	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} freeArr

@version P12
@since    11.10.18
/*/
//-------------------------------------------------------------------
Method freeArr(aArray) Class SyncHndPLS
	
    aSize(aArray,0)
	aArray := Nil
	aArray := {}

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} setDadBNV
Seta atributos da BNV sem necessidade de posicinar no registro
(utilizar com uma Query posicionada )

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method setDadBNV(cPedido,cAlias,cChaveBNV,nIDINT,cToken) Class SyncHndPLS

    Default cPedido   := ""
    Default cAlias    := ""
    Default cChaveBNV := ""
    Default nIDINT    := 0

    self:cPedido   := cPedido
    self:cAlias    := cAlias
    self:cChaveBNV := cChaveBNV
    self:nIDINT    := nIDINT
	self:cToken    := cToken
    self:lFindBNV  := .T.

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} setDadBNV
Seta atributos da BNV sem necessidade de posicinar no registro
(utilizar com uma Query posicionada )

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method setDadBNN(cCodTrans) Class SyncHndPLS
    
    BNN->(DbSetOrder(1)) //BNN_FILIAL+BNN_CODTRA
    if BNN->(DbSeek(xFilial("BNN")+cCodTrans))
        self:cCodTrans := Alltrim(BNN->BNN_CODTRA)
        self:cVersao   := Alltrim(BNN->BNN_VERSAO)
        self:cAPI      := Alltrim(BNN->BNN_ENDPOI)
        self:lFindBNN  := .T.
    else 
        self:lFindBNN  := .F.
        self:lSuccess  := .F.
        self:cErrorAPI := "Nao foi encontrado o cadastro da API na tabela BNN. Codigo API: " + cCodTrans + ". Alias: " +self:cAlias
        self:logPlsToHat("----- Nao foi encontrado o cadastro da API na tabela BNN.")
        self:logPlsToHat( "Pedido: " + self:cPedido + " | Codigo API: " + cCodTrans + " | Alias: " +self:cAlias)
    endIf 

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadArr

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Method retDadArr(aDados,cTag) Class SyncHndPLS

	Local cRet := ""
	Local nPos := 0

	nPos := Ascan(aDados,{|x|x[1] == cTag})
	If nPos > 0
		cRet := aDados[nPos][3]
	EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} errorCriPed
Funcao para atribuir status de erro na criacao do pedido (status 1)
@author  Rodrigo.Morgon
@since   2019-01-09
/*/
//-------------------------------------------------------------------
Method errorCriPed(cAlias,cCodigo) Class SyncHndPLS

	local aCampos := {}

	default cAlias := ''
	default cCodigo := ''

	if !empty(cAlias) .and. !empty(cCodigo)
		//Atualiza o pedido com status 1 - erro na criacao do pedido
		BNV->(DbSetOrder(1))//BNV_FILIAL+BNV_CODIGO
		if BNV->(MsSeek(xFilial("BNV")+cCodigo))
			aCampos := {}
			aadd( aCampos, { "BNV_STATUS", "1" })
			PLS274GRV( K_Alterar, aCampos )
		endIf
	endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ajustType
Realiza ajuste nos dados baseado no tipo da variavel

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method ajustType(aRet) Class SyncHndPLS

	Local nX := 1

	for nX := 1 to len(aRet)
		if ValType(aRet[nX][3]) == "C"
			aRet[nX][3] := Alltrim(aRet[nX][3])
		elseif ValType(aRet[nX][3]) == "D"
			if empty(DtoS(aRet[nX][3]))
				aRet[nX][3] := ""
			else
				aRet[nX][3] := SubStr(DtoS(aRet[nX][3]),1,4) + '-' + SubStr(DtoS(aRet[nX][3]),5,2) + '-' + SubStr(DtoS(aRet[nX][3]),7,2)
			endif
		endif
	next

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} posicBA0
Posiciona na Operadora BA0

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method posicBA0() Class SyncHndPLS

	BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	BA0->(MsSeek(xFilial("BA0")+PlsIntPad()))

    self:cCodOpe := BA0->(BA0_CODIDE+BA0_CODINT)
	self:cSusep  := Alltrim(BA0->BA0_SUSEP)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} setupPost
Realiza Post com o HAT

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method setupPost() Class SyncHndPLS

	Local cEndPoint   := GetNewPar("MV_PHATURL","")
    Local lSerialized := .F.
    Local cStatusCode := ""
    Local oJson       := nil
    Local nX          := 0
    Local aDadHeader  := {}
    Local cResponse   := ""
    Local cPath       := ""

    //Verifica dados do header no arquivo plshat.ini
    aDadHeader := PLGDadHead()

    if !empty(cEndPoint)
        if Substr(cEndPoint,len(cEndPoint),1) <> "/"
	        cEndPoint += "/"
        endIf
        self:oClient := FWRest():New(cEndPoint)
        
        cPath := self:cVersao+"/"+self:cAPI
        cPath += iif(self:cCodTrans == _cancel_BEA_atu,"/"+self:cChaveBNV+"/"+"cancel","")
        self:oClient:setPath(cPath)
        self:oClient:setPostParams(self:cJson)

        aAdd(self:aHeader,'Content-Type: application/json')
        for nX := 1 to len(aDadHeader)
			aAdd(self:aHeader,aDadHeader[nX,1]+": "+aDadHeader[nX,2])
		next
        self:logPlsToHat("INICIO DE COMUNICACAO COM O AUTORIZADOR POST") 
        self:logPlsToHat("URL API: "+cEndPoint+cPath)
		self:logPlsToHat("Json de envio: " + self:cJson)

        if !self:lAuto
            self:oClient:Post(self:aHeader)
        endif

        if self:lAuto .OR. ((empty(self:oClient:cInternalError) .and. (!empty(self:oClient:oResponseH:cStatusCode) .and. self:oClient:oResponseH:cStatusCode $ "200/201/202")))
            self:lSuccess := .T.
            oJson := JsonObject():New()
            lSerialized := iif(self:lAuto,.T.,empty(oJson:fromJson( self:oClient:GetResult() )))
            cResponse   := iif(self:lAuto,self:cJsAutPost,self:oClient:GetResult())

            if lSerialized
                self:logPlsToHat("COMUNICACAO OK - HAT devolveu a resposta: " + cResponse)
            else
                cParseError := oJson:fromJSON(cResponse)
                self:logPlsToHat("COMUNICACAO OK - Erro ao processar resposta: " + cResponse + " - " + cParseError)
                self:cErrorAPI := "Erro no HAT: " + cResponse + " - " + cParseError
            endif
            
            FreeObj(oJson)
            oJson := nil
        else
            self:lSuccess := .F.
            if empty(self:oClient:oResponseH:cStatusCode)
                cStatusCode := "500"
            else
                cStatusCode := self:oClient:oResponseH:cStatusCode
            endif

            cStatusCode := IIF(empty(self:oClient:oResponseH:cStatusCode),"500",self:oClient:oResponseH:cStatusCode)
            self:cErrorAPI := "Post realizado no servidor do HAT retornou StatusCode:" + cStatusCode
            self:logPlsToHat("COMUNICACAO FALHOU - PEDIDO: " + self:cPedido + ". " + self:cErrorAPI )
			self:logPlsToHat("COMUNICACAO FALHOU - PEDIDO: " + self:cPedido + ". " + self:oClient:getLastError() )
        endif
    endif

Return self:lSuccess


//-------------------------------------------------------------------
/*/{Protheus.doc} setupGet
Realiza Get com o HAT

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method setupGet() Class SyncHndPLS

	Local cEndPoint   := GetNewPar("MV_PHATURL","")
    Local lSerialized := .F.
    Local cStatusCode := ""
    Local oJson       := nil
    Local nX          := 0
    Local aDadHeader  := {}
    Local cResponse   := ""

    //Verifica dados do header no arquivo plshat.ini
    aDadHeader := PLGDadHead()

    if !empty(cEndPoint)
        if Substr(cEndPoint,len(cEndPoint),1) <> "/"
	        cEndPoint += "/"
        endIf
        self:oClient := FWRest():New(cEndPoint)
		self:oClient:setPath(self:cVersao+self:cActionGet+self:cToken+self:cExpand)  

        aAdd(self:aHeader,'Content-Type: application/json')
        for nX := 1 to len(aDadHeader)
			aAdd(self:aHeader,aDadHeader[nX,1]+": "+aDadHeader[nX,2])
		next

        self:logPlsToHat("INICIO DE COMUNICACAO COM O AUTORIZADOR GET - Codigo BNV: " + self:cPedido)
        self:logPlsToHat("URL API: "+cEndPoint+self:cVersao+self:cActionGet+self:cToken+self:cExpand)
		
        self:lSuccess := iif(self:lAuto,.T.,self:oClient:Get(self:aHeader))

        if self:lSuccess
            oJson := JsonObject():New()
            lSerialized := iif(self:lAuto,.T.,empty(oJson:fromJson( self:oClient:GetResult() )))
            cResponse   := iif(self:lAuto,self:cJsAutGet,self:oClient:GetResult())

            if lSerialized
                self:logPlsToHat("COMUNICACAO OK - HAT devolveu a resposta: " + cResponse)
            else
                cParseError := oJson:fromJSON(cResponse)
                self:logPlsToHat("COMUNICACAO OK - Erro ao processar resposta: " + cResponse + " - " + cParseError)
                self:cErrorAPI := "Erro no HAT: " + cResponse + " - " + cParseError
            endif
            
            FreeObj(oJson)
            oJson := nil
        else
            if empty(self:oClient:oResponseH:cStatusCode)
                cStatusCode := "500"
            else
                cStatusCode := self:oClient:oResponseH:cStatusCode
            endif

            cStatusCode := IIF(empty(self:oClient:oResponseH:cStatusCode),"500",self:oClient:oResponseH:cStatusCode)
            self:cErrorAPI := "Post realizado no servidor do HAT retornou StatusCode:" + cStatusCode
            self:logPlsToHat("COMUNICACAO FALHOU - PEDIDO: " + self:cPedido + ". " + self:cErrorAPI)
			self:logPlsToHat("COMUNICACAO FALHOU - PEDIDO: " + self:cPedido + ". " + self:oClient:getLastError() )
        endif
    endif

Return self:lSuccess


//-------------------------------------------------------------------
/*/{Protheus.doc} logPlsToHat
Gera log da integracao PLS > HAT

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method logPlsToHat(cMsg) Class SyncHndPLS

    Local cCharCSV  := ";"
	Default cMsg    := ""
	
	if self:lLogPlsHat
        PlsPtuLog(self:cRandomKey +cCharCSV+;
                  self:cPedido +cCharCSV+;
                  AllTrim(Str(ThreadID())) +cCharCSV+;
                  self:getTimeLog()+cCharCSV+;
                  cMsg, ;
                  "plshat.log")
    endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getTimeLog
Loga os 

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method getTimeLog() Class SyncHndPLS

    Local nHH, nMM , nSS, nMS := seconds()

    nHH := int(nMS/3600)
    nMS -= (nHH*3600)
    nMM := int(nMS/60)
    nMS -= (nMM*60)
    nSS := int(nMS)
    nMS := (nMs - nSS)*1000

Return strzero(nHH,2)+":"+strzero(nMM,2)+":"+strzero(nSS,2)+"."+strzero(nMS,3)
