#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'JURA304.CH'


Static lHasConfig := .F.

//------------------------------------------------------------------------------
/* /{Protheus.doc} JURA304
Wizard de configuração de ocorrência
@since 14/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JURA304()
Local lExistMV := FWSX6Util():ExistsParam('MV_JCFGOCO')

	If lExistMV
		FWMsgRun( ,{|| checkConfig(),CallWizard() },STR0001, STR0002)//"Verificando configuração"##"Aguarde, estamos verificando a sua configuração..."

	Else
		JurMsgError(STR0003,,; //'Para correto funcionamento desta configuração, deverá possuir o cadastro do parametro "MV_JCLIOCO"'
			+STR0004+Chr(13)+Chr(10);//"Para mais informações, acesse o link da nossa documentação:"
			+ "https://tdn.totvs.com/pages/viewpage.action?pageId=718422818")

	Endif

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} CallWizard
Responsavel pela montagem do wizard de configuração
@since 14/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function CallWizard()
Local aSizeD       := FWGetDialogSize( oMainWnd )
Local aCoord       := { aSizeD[1]*0.50, aSizeD[2]*0.50, aSizeD[3]*0.70, aSizeD[4]*0.50 }
Local oWizard      := nil
Local oPanel       := nil
Local oFontTit     := TFont():New( "Arial"/*cName*/, /*uPar2*/, 14/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/)
Local oFontTxt     := TFont():New( "Arial"/*cName*/, /*uPar2*/, 12/*nHeight*/, /*uPar4*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/)
Local oBody        := JsonObject():New()
Local oGetChave    := nil
Local oGetDominio  := nil
Local oGetCNPJ     := nil
Local nLine        := 0
Local cInfoCfg     := STR0014 + "https://api.totvsjuridico.totvs.com.br" + STR0017 // "*Para o correto funcionamento desta funcionalidade é necessário comunicação com o endereço https://api.totvsjuridico.totvs.com.br, protocolo seguro"
Local cCodT        := SuperGetMv('MV_JCFGOCO',, '')
Local cChave       := ""

	If !Empty(cCodT)
		cChave := cCodT
	Else
		cChave := FwGetIdLSV()
	EndIf

	oBody["codigoT"]  := JOcoGetChave('1')
	oBody["chave"]    := JOcoGetChave('2')
	oBody["dominio"]  := GetDominio()
	oBody["cnpj"]     := FWArrFilAtu( cEmpAnt , cFilAnt )[18]

	oWizard := APWizard():New(	STR0006/*<chTitle>*/,;	//"Atenção"
								STR0007/*<chMsg>*/,;	//"Este assistente o auxiliará na confirguração de faturamento de ocorrências com dados do módulo jurídico"
								STR0008/*<cTitle>*/,;	//"Confirguração de faturamento de ocorrências com dados do módulo jurídico"
								STR0009/*<cText>*/,;	//"Neste assistente nós criaremos uma chave de segurança para integração e prepararemos o ambiente para que a integração com o módulo jurídico funcione."
								{|| .T.}/*<bNext*/, ;
								{|| .F.}/*<bFinish>*/,;
								/*<lPanel>*/,;
								/*<cResHead> */,;
								/*<bExecute>*/,;
								/*<lNoFirst>*/,;
								aCoord/*<aCoord>*/ )


	oWizard:NewPanel(	STR0006/*<chTitle>*/,;	//"Atenção"
						STR0007/*<cTitle>*/,; //"Este assistente o auxiliará na confirguração de faturamento de ocorrências com dados do módulo jurídico"
						{|| .T.}/*<bBack>*/, ;
						{|| .T.}/*<bNext>*/,;
						{|| GravarConfig(oBody)}/*<bFinish>*/,;
						/*<lPanel> */,;
						/*<bExecute>*/)
	
	oPanel := oWizard:GetPanel(2)

	If lHasConfig
		@ nLine+005,05 Say STR0010 COLOR CLR_RED Font oFontTit PIXEL OF oPanel // "Configuração já cadastrada, apenas para fins de conferência!"
		nLine += 10
	Endif

	//'Chave de Segurança' 
	@ nLine+005,05 Say STR0011 Font oFontTit PIXEL OF oPanel //'Chave de Segurança'
	@ nLine+015,05 MsGet oGetChave   Var cChave Size 120,009 PIXEL OF oPanel NO MODIFY
	@ nLine+027,05 Say STR0012 Font oFontTxt PIXEL OF oPanel //'*Esta chave de segurança deve ser informada no módulo juridico para que a integração funcione corretamente'

	//Dominio
	nLine += 30
	@ nLine+005,05 Say STR0013 Font oFontTit PIXEL OF oPanel // 'Dominio do email'
	If !lHasConfig .AND. Empty(cCodT)
		@ nLine+015,05 MsGet oGetDominio Var oBody["dominio"] Size 120,009 PIXEL OF oPanel
	Else
		@ nLine+015,05 MsGet oGetDominio Var oBody["dominio"] Size 120,009 PIXEL OF oPanel NO MODIFY
	EndIf

	//CNPJ
	nLine += 25
	@ nLine+005,05 Say 'CNPJ' Font oFontTit PIXEL OF oPanel
	If !lHasConfig .AND. Empty(cCodT)
		@ nLine+015,05 MsGet oGetCNPJ    Var oBody["cnpj"] Size 120,009 PICTURE  Alltrim(GetSx3Cache("A1_CGC","X3_PICTURE")) PIXEL OF oPanel
	Else
		@ nLine+015,05 MsGet oGetCNPJ    Var oBody["cnpj"] Size 120,009 PICTURE  Alltrim(GetSx3Cache("A1_CGC","X3_PICTURE")) PIXEL OF oPanel NO MODIFY
	EndIf

	//Rodapé
	nLine := 125
	@ nLine+005,05 Say cInfoCfg Font oFontTxt PIXEL OF oPanel //"*Para o correto funcionamento desta funcionalidade é necessário comunicação com o endereço https://api.totvsjuridico.totvs.com.br, protocolo seguro"

	oWizard:Activate()
Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} checkConfig
Responsavel pela verificação se existe a configuração cadastrada
@since 14/10/2022
@version 1.0
@return AllwaysTrue
/*/
//------------------------------------------------------------------------------
Static Function checkConfig()
Local cCodT        := SuperGetMv('MV_JCFGOCO',, '')
Local oRest        := nil
Local aHeader      := {}
Local cEndPoint    := ""
Default lHasConfig := .F.

	If !Empty(cCodT)
		cEndPoint := 'ocorrencia/config/'+Encode64(cCodT)
		oRest := JRestOcor(cEndPoint,@aHeader)
		If oRest:Get(aHeader)
			lHasConfig := .T.
		Endif
		FwFreeObj(oRest)
	Endif

Return .T.


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDominio
Responsavel por pegar o dominio do email do usuário logado
@since 14/10/2022
@version 1.0
@return cRet, dominio de email do usuario
/*/
//------------------------------------------------------------------------------
Static Function GetDominio()
Local cRet   := ''
Local cEmail := UsrRetMail(__cUserID)

	If !Empty(cEmail)
		cRet := AllTrim(SubStr(cEmail,At('@',cEmail)+1))
	Endif

Return cRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} GravarConfig
Responsavel por gravar a configuração
@since 14/10/2022
@version 1.0
@param oBody, oJson, body da requisição em Json
@return lRet, informa se a configuração foi realizada com sucesso
/*/
//------------------------------------------------------------------------------
Static Function GravarConfig(oBody)
Local lRet := .T.

	If !lHasConfig
		lRet := validConfig(oBody)
		if lRet .and. callPostConfig(oBody)
			PutMv("MV_JCFGOCO", oBody["codigoT"])
		Endif
	Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} callPostConfig
Responsavel por gravar a configuração na azure
@since 14/10/2022
@version 1.0
@param oBody, oJson, body da requisição em Json
@return lRet, informa se a configuração foi realizada com sucesso
/*/
//------------------------------------------------------------------------------
Static Function callPostConfig(oBody)
Local lRet         := .T.
Local cCodT        := oBody["codigoT"]
Local oRest        := nil
Local aHeader      := {}
Local cEndPoint    := 'ocorrencia/config/'+Encode64(cCodT)
Default lHasConfig := .F.

	oRest := JRestOcor(cEndPoint,@aHeader)
	oRest:SetPostParams(oBody:toJson())

	If !oRest:Post(aHeader)
		If "409" $ oRest:oResponseH:cStatusCode
			FWAlertWarning(STR0018) // "Este ambiente já possui configuração para a funcionalidade de Faturamento por ocorrencias! As informações apresentadas são somente para conferência."
		Else
			lRet := .F.
			JurMsgErro(STR0015 +oRest:GetLastError()) //'Falha na gravação:'
		EndIf
	Else
		FWAlertSuccess(STR0019) // "Configuração gravada com sucesso!"
	Endif

	FwFreeObj(oRest)
Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} validConfig
Responsavel por validar as informações necessárias para configuração
@since 14/10/2022
@version 1.0
@param oBody, oJson, body da requisição em Json
@return lRet, informa se a configuração foi realizada com sucesso
/*/
//------------------------------------------------------------------------------
Static Function validConfig(oBody)
Local lRet := .T.

	If Empty(oBody['dominio'])
		lRet := .F.
		JurMsgError(STR0016)//"Para fins de identificação, necessário informar o dominio de email. Ex: 'dominio.com.br'"
	Endif

Return lRet
