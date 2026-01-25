#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
  
/*{Protheus.doc} GFEX003

Função que cria uma tela aonde se pode ser incluidos ou alterados os parametros que existem na base
Baseado GFEX003
@author Siegklense.Beulke
@since 21/07/2015
@version 1.0

*/

Function GFEX003()
	FWExecView("Frete Embarcador", 'GFEX003', 3, , {|| .T. } )
Return NIL

//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel  := Nil
	Local oStruct := FWFormModelStruct():New()
	Local aCampos
	Local nCont


	aCampos:= { ;
	{"MV_CPLINT" , "Integração Cockpit Logístico?"							, "C",	01	, 0,,{"1=Sim","2=Não"}	,{|| SuperGetMv("MV_CPLINT",.F.,"2") }, },;
	{"MV_CPLURL" , "URL WebService Regras de Frete"							, "C",	255	, 0,,					,{|| SuperGetMv("MV_CPLURL",.F.,"") }, },;
	{"MV_CPLUAUT", "Endereço do webservice de autenticação"                 , "C",  255 , 0,,                   ,{|| SuperGetMv("MV_CPLUAUT",.F.," ")}, },;  
	{"MV_USRCPL" , "Usuário de autenticação do webservice"                  , "C",  255 , 0,,                   ,{|| SuperGetMv("MV_USRCPL" ,.F.," ")}, },; 
	{"MV_PSWCPL" , "Senha de autenticação do webservice"                    , "C",  255 , 0,,                   ,{|| SuperGetMv("MV_PSWCPL" ,.F.," ")}, },; 
	{"MV_EXPTOK" , "Qtde de horas para considerar que um token expirou"     , "N",  2   , 0,,                   ,{|| SuperGetMv("MV_EXPTOK" ,.F.,24 )}, },; // default 24
	{"MV_CPLEMB" , "Embarcador"												, "C",	255	, 0,,						,{|| SuperGetMv("MV_CPLEMB",.F.,"") }, },;
	{"MV_CPLREG" , "Regional"												, "C",	255	, 0,,					,{|| SuperGetMv("MV_CPLREG",.F.,"") }, },;
	{"MV_CPLTVF" , "Tipo Veículo Fracionado"								, "C",	255	, 0,,					,{|| SuperGetMv("MV_CPLTVF",.F.,"") }, },;
	{"MV_CPLZTO", "Zona de transporte para rotas com origem não informada"	, "C",	255	, 0,,					,{|| SuperGetMv("MV_CPLZTO",.F.,"") }, },;
	{"MV_CPLZTD", "Zona de transporte para rotas com destino não informado" , "C",	255	, 0,,					,{|| SuperGetMv("MV_CPLZTD",.F.,"") }, };
}

	For nCont := 1 To Len(aCampos)
		oStruct:AddField(aCampos[nCont][2], aCampos[nCont][2], aCampos[nCont][1],aCampos[nCont][3],aCampos[nCont][4],aCampos[nCont][5],aCampos[nCont][6],aCampos[nCont][9],aCampos[nCont][7]/*@aVALUES*/,.F./*lOBRIG*/,aCampos[nCont][8]/*bINIT*/,/*lKEY*/,/*lNOUPD*/,/*lVIRTUAL*/)
	Next

	oModel := MPFormModel():New("GFEX003", /*bPre*/, {|oModel| GFEX003VLD(oModel)}/*bPost*/, {|oModel|GFEX003COM(oModel)} /*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEX003_01", Nil,oStruct , /*bPre*/, /*bPost*/, /*bLoad*/)
	oModel:SetDescription("Parâmetros Cockpit")
	oModel:GetModel("GFEX003_01"):SetDescription("Parâmetros Cockpit")
	oModel:SetPrimaryKey({"MV_CPLINT"})

Return oModel

//------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oView   := Nil
	Local oStruct := FWFormViewStruct():New()
	Local oModel  := FWLoadModel("GFEX003")
	Local aCampos
	Local aFolder
	Local nCont

    aCampos :=  {;
	{"MV_CPLINT" , "Integração Cockpit Logístico?"							, "C",           ,           , "Integ"  , "GpGeral"     , {"1=Sim","2=Não"}	, .T.},;
	{"MV_CPLURL" , "URL WebService Regras de Frete"							, "C",           ,           , "Integ"  , "GpCom"     	, 					, .T.},;
	{"MV_CPLUAUT",'Endereço do webservice de autenticação'                  , "C",           ,           , "Integ"  , "GpCom"       ,                   , .T.},;  
	{"MV_USRCPL", 'Usuário de autenticação do webservice'                   , "C",           ,           , "Integ"  , "GpCom"       ,                   , .T.},;  
	{"MV_PSWCPL", 'Senha de autenticação do webservice'                     , "C", "@*"      ,           , "Integ"  , "GpCom"       ,                   , .T.},;  
	{"MV_EXPTOK", 'Qtde de horas para considerar que um token expirou'      , "N",           ,           , "Integ"  , "GpCom"       ,                   , .T.},; //  default 24
	{"MV_CPLREG" , "Regional"												, "C",           ,           , "Integ"  , "GpInf"     	,                   , .T.},;
	{"MV_CPLEMB" , "Embarcador"												, "C",           ,           , "Integ"  , "GpInf"     	,					, .T.},;
	{"MV_CPLTVF" , "Tipo Veículo Fracionado"								, "C",           ,           , "Integ"  , "GpInf"     	,                   , .T.},;
	{"MV_CPLZTO", "Zona de transporte para rotas com origem não informada"	, "C",           ,           , "Integ"  , "GpInf"     	,                   , .T.},;
	{"MV_CPLZTD", "Zona de transporte para rotas com destino não informado"	, "C",           ,           , "Integ"  , "GpInf"     	,                   , .T.};
	}

	For nCont := 1 To Len(aCampos)
		AAdd(aCampos[nCont], GFEX003GTT(aCampos[nCont][1]))

	Next nCont


	aFolder := {{"Integ" ,"Integração"  }}

	For nCont := 1 to Len(aFolder)
		oStruct:AddFolder(aFolder[nCont][1],aFolder[nCont][2])
	Next nCont


	oStruct:AddGroup("GpGeral"  , "Geral" 			 		, "Integ", 2)
	oStruct:AddGroup("GpCom"   	, "Comunicação" 			, "Integ", 2)
	oStruct:AddGroup("GpInf" 	, "Informações Padrão"	, "Integ", 2)

	For nCont := 1 to len(aCampos)
		oStruct:AddField(aCampos[nCont][1], NTOC(nCont,32,2), aCampos[nCont][2] ,aCampos[nCont][10] , , aCampos[nCont][3], aCampos[nCont][4],/*bPICTVAR*/,aCampos[nCont][5], aCampos[nCont][9] /*lCANCHANGE*/,aCampos[nCont][6]/*cFOLDER*/,aCampos[nCont][7]/*cGRUP*/,aCampos[nCont][8]/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/," ",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/)
	Next nCont

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEX003_01" , oStruct, /*cLinkID*/ )
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:AddUserButton("Testar Webservice", "MAGIC_BMP", {|oView| GFEX003WST(FwFldGet("MV_CPLURL"),,FwFldGet("MV_CPLUAUT"),FwFldGet("MV_USRCPL"),FwFldGet("MV_PSWCPL") )}, ) // "Email"
	oView:SetOwnerView("GFEX003_01","MASTER")

Return oView

//------------------------------------------------------------------------------------------------

Static Function GFEX003COM(oModel)
	Local oModelPF  := oModel:GetModel('GFEX003_01')
	Local nCont
	Local aCamposPF := oModelPF:GetStruct():GetFields()
	Local cLink := oModelPF:GetValue("MV_CPLURL")
	
	cLink := AllTrim(StrTran(AllTrim(cLink),"?wsdl",""))
	
	If Rat("/",cLink) == Len(cLink)
		cLink := SubStr(cLink,1,Len(cLink)-1)
	EndIf
	
	oModelPF:LoadValue("MV_CPLURL",cLink)

	For nCont := 1 To Len(aCamposPF)
		PUTMV(aCamposPF[nCont][3] , oModel:GetValue("GFEX003_01",aCamposPF[nCont][3]))
	Next nCont


Return .T.

Static Function GFEX003GTT(cPar)

Return AllTrim( Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESCRIC") + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC1")   + ;
			    Posicione("SX6",1,xFilial("SX6")+cPar,"X6_DESC2"))   + ;
			    " | " + Alltrim(Posicione("SX6",1,xFilial("SX6")+cPar,"X6_VAR") )

//-----------------------------------------------------

Function GFEX003VLD(oModel)
Return .T.

//-----------------------------------------------------

Function GFEX003WST(cUrl,lAvisoOK,cUrlAuth,cUsrAut,cPswAut)
		Local lRet := .F.
	Local nRetry := 4
	Local lBlind := IsBlind()
	Local cToken
	Private cLink := StrTran(AllTrim(cUrl),"?wsdl","")
	Private cRet
	Private cRetHtml := ""
	cRetCPLWST := "" // Uso externo
	
	Default lAvisoOK := .T.
	Default cUrlAuth := SuperGetMv("MV_CPLUAUT",,"")
	Default cUsrAut := SuperGetMv("MV_USRCPL",.F.,"")
	Default cPswAut := SuperGetMv("MV_PSWCPL",.F.,"")
	
	cUsrAut := StrTran(cUsrAut," ","")
	cPswAut := AllTrim(cPswAut)
	
	If Rat("/",cLink) == Len(cLink)
		cLink := SubStr(cLink,1,Len(cLink)-1)
	EndIf

	If !Empty(cUrlAuth) .And. !Empty(cUsrAut) .And. !Empty(cPswAut)
		If lAvisoOK
			cToken := GFECPLGetToken(cUrlAuth,cUsrAut,cPswAut)
		Else
			cToken := GFGETTOKEN()
		EndIf
		If Empty(cToken)
			Return .F.
		EndIf
	EndIf
	
	MsgRun("Testando WebService...", "Aguarde", {|| cRetHtml:= Iif( Empty(cToken),;
												               HttpGet(cLink,,20,,@cRet),;
												               HttpsGet(cLink, "", "", "", "", 20, {'user.token: ' + cToken}, @cRet));
							               		})  
	While Empty(cRetHtml) .And. nRetry > 0
		If !lBlind
			If MsgYesNo("Não foi possível conectar no WebService. Tentar novamente?")  
				MsgRun("Testando WebService...", "Aguarde", {|| cRetHtml:= Iif( Empty(cToken),;
																	HttpGet(cLink,,20,,@cRet),;
																	HttpsGet(cLink, "", "", "", "", 20, {'user.token: ' + cToken}, @cRet));
																	}) 
			Else
				Exit
			EndIf
		Else
			cRetHtml:= Iif( Empty(cToken),;
							HttpGet(cLink,,20,,@cRet),;
							HttpsGet(cLink, "", "", "", "", 20, {'user.token: ' + cToken}, @cRet))
		EndIf
		nRetry--
	EndDo
	If Empty(cRetHtml)
		cRetCPLWST := "Não foi possível conectar no WebService." + CRLF + "HTTPGET:" + cValToChar(cRet)  
		MsgInfo("Não foi possível conectar no WebService.") 
	Else
		If lAvisoOK
			MsgInfo("Conexão OK.")  
		EndIf
		lRet := .T.
	EndIf
	cRetHtml:= ""
Return lRet