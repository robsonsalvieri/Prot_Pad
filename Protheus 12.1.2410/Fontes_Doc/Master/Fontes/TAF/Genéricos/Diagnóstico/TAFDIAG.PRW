#Include "Protheus.ch"
#Include "FwMvcDef.CH"
#include "TafDiag.ch"
#include "APWIZARD.CH"
#INCLUDE "TOPCONN.CH" 

#Define _CRLF	Chr(13) + Chr(10)

Static lFindClass := FindFunction("TAFFindClass") .And. TAFFindClass( "FWCSSTools" ) // Por causa de atualização de Lib, verifica se existe a função FindClass e com a função verifica se existe a classe FWCSSTools

//------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafDiag 

Diagnóstico do TAF para demonstrar aos usuários os possíveis problemas de ambiente, facilitando a 
identificação e correção dos problemas

@Author  Rodrigo Aguilar
@Since   03/04/2018
@Version 2.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Function TafDiag(lMain)
Local cUserAc	:= ""
Local cVerWeb   := ""
Local aSizeMain	:= FWGetDialogSize( oMainWnd )

Default lMain := .F.

If !lMain
	cUserAc	:=	AllTrim(FWSFUser( __cUserId, "DATAUSER", "USR_CODIGO" ))
	cVerWeb   := GetRemoteType(@cVerWeb)

	//Para ambiente Smart, o acesso somente eh permitido para o usuario Supervisor (fixo TAF1)
	If cVerWeb ==  5 // WebAPP
		If !( cUserAc == "TAF1" .OR. FWIsAdmin( __cUserId ) )
			MsgStop(' O usuário [' + cUserAc + '] não é o supervisor, portanto não possui o acesso desejado!')
			Return()
		EndIf
	Endif

	// Controle para tamanho de tela
	If aSizeMain[4] < 1260
		MsgAlert( "Para correto funcionamento desta ferramenta a resolução minima do monitor deve ser 1280 x 768. Algumas informações podem não ser apresentadas corretamente!")
	EndIf
		
	dbSelectArea('C1E')
	C1E->( dbSetOrder(3))
	If C1E->( mSSeek(xfilial('C1E')+cFilAnt))
		If C1E->C1E_MATRIZ
			MsgRun( "Realizando a análise do ambiente.... Aguarde...", "Diagnóstico do TAF", {|| MontaTela() } )
		Else
			MsgAlert("Esta funcionalidade somente pode ser acessada pela filial indicada como matriz no cadastro de complemento de empresas")
		EndIf
	Else
		MsgAlert("Esta funcionalidade somente pode ser acessada pela filial indicada como matriz no cadastro de complemento de empresas")
	EndIf
Else
	MontaTela()
Endif

Return

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} MontaTela 

Monta a tela de exibição do diagnóstico realizado

@Author  Rodrigo Aguilar
@Since   03/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function MontaTela()

	Local oDlg         as object
	Local oLayer       as object
	Local oBrowse      as object
	Local oHabilitado  as object
	Local oNHabilitado as object
	Local oCheck       as object
	Local oFontNeg     as object
	Local oFont        as object
	Local aSizeMain    as array
	Local aButtons     as array
	Local aControl     as array
	Local lHTML        as logical

	oDlg         := Nil
	oLayer       := Nil
	oBrowse      := Nil
	oHabilitado  := LoadBitmap( GetResources(), 'br_verde' )
	oNHabilitado := LoadBitmap( GetResources(), 'br_vermelho' )
	oCheck       := LoadBitmap( GetResources(), 'br_amarelo' )
	oFontNeg     := TFont():New('Arial', , -12, , .T.)
	oFont        := TFont():New('Arial', , -13, , .F.)
	aSizeMain    := FWGetDialogSize( oMainWnd )
	aButtons     := {}
	aControl     := {.T., .T., .T., .T.} //[1]VldDicion e [2]VldRPO [3]VldSMTP [4] ValidEmail
	lHTML        := Iif(lFindClass,FWCSSTools():GetInterfaceCSSType() == 5,.F.)

	//----------------------------------------------------
	//Monta os botões que existirão na tela de diagnóstico
	//----------------------------------------------------
	Aadd( aButtons, { "Gerar Extrato (.ZIP)",  			{|| Processa( {|| TafWizard(Nil,5) }, "Aguarde!", "Inicio do Processamento...")},"Gerar Extrato (.ZIP)","Gerar Extrato (.ZIP)", {|| .T.}} )
	
	If !lHTML
		Aadd( aButtons, { "Abrir Log do TAF", 			{|| TafGeraLog( "TAF" ) }, "Abrir Log do TAF", "Abrir Log do TAF" , { || .T. } } )
		Aadd( aButtons, { "Abrir Log do WS",  			{|| TafGeraLog( "WS" )  }, "Abrir Log do WS", "Abrir Log do WS" , { || .T. } } )
	EndIf

	Aadd( aButtons, { "Lista de Fontes",  				{|| MsgRun( "Realizando a análise do repositório de dados.... Aguarde...", "Listagem de Fontes do TAF", {|| TafListaFontes(.F.) } ) }, "Lista de Fontes", "Lista de Fontes" , {|| .T.}} )
	Aadd( aButtons, { "Valida Campo Filial",		 	{|| Processa( {|| TafCheckFil(.F.) }, "Aguarde!", "Inicio do Processamento...")},"Valida Campo Filial","Valida Campo Filial", {|| .T.}} )
	Aadd( aButtons, { "Valida Relac. Tabelas",  		{|| Processa( {|| TafTabValid(1,.F.) }, "Aguarde!", "Inicio do Processamento...")},"Valida Relac. Tabelas","Valida Relac. Tabelas", {|| .T.}} )
	Aadd( aButtons, { "Lista Tabelas dos Cadastros",  	{|| Processa( {|| TafTabValid(2,.F.) }, "Aguarde!", "Inicio do Processamento...")},"Lista Tabelas dos Cadastros","Lista Tabelas dos Cadastros", {|| .T.}} )
	Aadd( aButtons, { "Histórico de Atualizações",  	{|| Processa( {|| TafAplPat(.F.) }, "Aguarde!", "Inicio do Processamento...")},"Histórico de Atualizações","Histórico de Atualizações", {|| .T.}} )
	Aadd( aButtons, { "Gerar Histórico Protocolos",  	{|| TafWizard(Nil,6)  }, "Gerar Histórico Protocolos", "Gerar Histórico Protocolos" , { || .T. } } )
	Aadd( aButtons, { "Analisar numeração de Ids",  	{|| FWMsgRun(,{|oMsg|TfCheckIdDup()},,"Analisando Numeração dos eventos. " ) }, "Analisar numeração de Ids", "Analisar numeração de Ids" , { || .T. } } )		
	
	//Aadd( aButtons, { "Copiar Dados (Suporte TOTVS)",  	{|| TafClone01() },"Copiar Dados (Suporte TOTVS)","Copiar Dados (Suporte TOTVS)", {|| .T.}} )
	
	//-------------------------------------
	//Montando a tela de Diagnóstico do TAF
	//-------------------------------------
	oDlg := MsDialog():New( aSizeMain[1], aSizeMain[2], aSizeMain[3], aSizeMain[4], "Diagnóstico de ambiente", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T. , , , , .F. )

	oDlg:bInit := {|| EnchoiceBar( oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons,,,.F.,.F.,.F.,.F.,.F. ) }

	oLayer := FWLayer():New()

	oLayer:Init( oDlg, .T. )

	oLayer:AddLine   ( "LinUp", 30 )
	oLayer:AddLine   ( "LinMiddle", 28 )
	oLayer:AddLine   ( "LinDown", 44 )

	oLayer:AddCollumn( "Col01", 33, , "LinUp"  )
	oLayer:AddWindow ( "Col01", "Window01", "Informações da Versão corrente no ambiente do TAF", 100, .F., , , "LinUp" )

	oLayer:AddCollumn( "Col02", 33, , "LinUp"  )
	oLayer:AddWindow ( "Col02", "Window02", "Informações da última atualização realizada no ambiente do TAF", 100, .F., , , "LinUp" )

	oLayer:AddCollumn( "Col03", 34, , "LinUp"  )
	oLayer:AddWindow ( "Col03", "Window03", "Link para o portal do cliente - Atualizações do TAF", 100, .F., , , "LinUp" )

	oLayer:AddCollumn( "Col01", 33, , "LinMiddle"  )
	oLayer:AddWindow ( "Col01", "Window01", "Informações do WebService (Integração do ERP com o TAF)", 100, .F., , , "LinMiddle" )

	oLayer:AddCollumn( "Col02", 33, , "LinMiddle"  )
	oLayer:AddWindow ( "Col02", "Window02", "Informações do TSS", 100, .F., , , "LinMiddle" )

	oLayer:AddCollumn( "Col03", 34, , "LinMiddle"  )
	oLayer:AddWindow ( "Col03", "Window03", "Procedimentos para atualização do TAF", 100, .F., , , "LinMiddle" )

	oLayer:AddCollumn( "Col01", 100, , "LinDown"  )
	oLayer:AddWindow ( "Col01", "Window01", "Resultado da análise do ambiente (Duplo clique na linha para mais informações)", 100, .F., , , "LinDown" )

	TAFPrtRls( oLayer:GetWinPanel( "Col01", "Window01", "LinUp" ), oFontNeg, oFont, @aControl )

	TAFPrtAcm( oLayer:GetWinPanel( "Col02", "Window02", "LinUp" ), oFontNeg, oFont, aControl )

	TafPrtDic( oLayer:GetWinPanel( "Col03", "Window03", "LinUp" ),oFontNeg, oFont )

	TafPrtWs( oLayer:GetWinPanel( "Col01", "Window01", "LinMiddle" ),oFontNeg, oFont )

	TafPrtTss( oLayer:GetWinPanel( "Col02", "Window02", "LinMiddle" ),oFontNeg, oFont )

	TafPrtRep( oLayer:GetWinPanel( "Col03", "Window03", "LinMiddle" ),oFontNeg, oFont )

	TafStatAtu( oLayer:GetWinPanel( "Col01", "Window01", "LinDown" ), { oHabilitado, oNHabilitado, oCheck }, oBrowse, oFont )

	oDlg:Activate()

	//---------------------------------------------------------------
	//Liberando os objetos criados durante o processamento da memória
	//---------------------------------------------------------------
	Freeobj( oBrowse )   ; Freeobj( oDlg )      ; Freeobj( oLayer )
	Freeobj( oLayer )    ; Freeobj( oFontNeg )  ; Freeobj( oHabilitado ) ; Freeobj( oNHabilitado )
	Freeobj( oCheck )    ; Freeobj( oFont )

	//-----------------------------------------------------
	//Zerando os arrays utilizados durante o processamento
	//-----------------------------------------------------
	aSize( aSizeMain, 0 )
	aSizeMain := Nil
	
Return

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafPrtTss
Printa as informações do TSS na Tela

@Param	
oPanel 	 - Objeto da area de trabalho da tela
oFontNeg - Fonte Negrita a ser usada
oFont    - Fonte de texto comum a ser usada

@author    Ronaldo Tapia
@version   12.1.17
@since     13/04/2018
@protected

@Return	aDiag
[1] - URL de configuração do TSS
[2] - Status da conexão com o TSS
[3] - Validade do certificado digital
[4] - Versão do TSS
*/
//------------------------------------------------------------------------------------------
Static Function TafPrtTss( oPanel, oFontNeg, oFont )

	Local aDiag	   	  := {}
	Local aSizeDialog := {}
	Local aRetorno    := {}
	Local cEndTSS     := ""
	Local oFont11Neg  := TFont():New( 'Arial', , -11, , .T. )
	Local ni
	Local nLin		  := 40 // Controle de linha para impressão do certificado
	Local lHTML		:= Iif(lFindClass,FWCSSTools():GetInterfaceCSSType() == 5,.F.)

	aSizeDialog	:=	FWGetDialogSize( oPanel )

	// 1 - URL de configuração do TSS
	aAdd(aDiag, VldURLTSS())

	// 2 - Status de comunicação com o TSS
	aRetorno := VldConTSS()
	aAdd(aDiag, aRetorno[1])

	// 3 - Validade do certificado digital
	If Empty( aRetorno[2] )
		aAdd(aDiag, VldDtCert(aRetorno[1]))
	Else
		aAdd(aDiag, aRetorno[2])
	Endif
	
	// 4 - Versão do TSS
	aAdd(aDiag, VldVerTSS(aRetorno[1]))
	
	// URL de configuração do TSS
	If Empty( aRetorno[2] )
		TSay():New( aSizeDialog[1] + 5, aSizeDialog[2], { || "URL TSS: " }, oPanel,,oFontNeg,,,, .T.,CLR_BLACK,, 110, 010 ) //"URL TSS"
		If aDiag[1][1][1]
			cEndTSS := aDiag[1][1][2]
			
			@aSizeDialog[1] + 15,aSizeDialog[2] Say oLinkWs PROMPT  cEndTSS Size 150,010 Font oFont OF oPanel Html Pixel
			oLinkWs:bLClicked := {|| MsgRun( "Abrindo o link do TSS.... Aguarde...", "TSS", {|| ShellExecute("open",cEndTSS,"","",1) } ) }

			If lHTML
				oLinkWs:LTRANSPARENT := .T.
			EndIf
		Else
			TSay():New( aSizeDialog[1] + 15, aSizeDialog[2], { || "Não Configurado" }, oPanel,,oFont,,,, .T.,CLR_RED,, 150, 010 ) //"NÃO CONFIGURADO"
		EndIf
	EndIf

	// Comunicação com o TSS
	If Empty( aRetorno[2] )
		TSay():New( aSizeDialog[1] + 5, aSizeDialog[2] + 140, { || "Status TSS: " }, oPanel,,oFontNeg,,,, .T.,CLR_BLACK,, 110, 010 ) //"Status TSS"
		If aDiag[2]
			TSay():New( aSizeDialog[1] + 15, aSizeDialog[2] + 140, { || "Conectado" }, oPanel,,oFontNeg,,,, .T.,CLR_GREEN,, 150, 010 ) //"CONECTADO"
		Else
			TSay():New( aSizeDialog[1] + 15, aSizeDialog[2] + 140, { || "Não Conectado" }, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 150, 010 ) //"NÃO CONECTADO"
		EndIf
	EndIf

	// Validade certificado TSS
	If !Empty( aRetorno[2] )
		TSay():New( aSizeDialog[1] + 5, aSizeDialog[2] , { || aDiag[3] }, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 205, 050 )
	Else
		TSay():New( aSizeDialog[1] + 29, aSizeDialog[2], { || "Validade Certificado: " }, oPanel,,oFontNeg,,,, .T.,    ,, 110, 010 ) //""Validade Certificado: ""
		If len(aDiag[3]) > 0
			For ni := 1 to Len(aDiag[3])
				TSay():New( aSizeDialog[1] + nLin, aSizeDialog[2] , { || cValToChar(aDiag[3][1]) }, oPanel,,oFont,,,, .T.,CLR_BLACK,, 150, 010 )
				nLin := nLin + 10
			Next ni
		else
			If aSizeDialog[4] > 1800 // Aumenta tamanho da fonte em monitores maiores
				TSay():New( aSizeDialog[1] + 40, aSizeDialog[2] , { || "Certificado digital não encontrado no TSS."}, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 205, 040 )
				TSay():New( aSizeDialog[1] + 48, aSizeDialog[2] , { || "Utilize a Wizard de comunicação do TAF"}, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 205, 040 )
				TSay():New( aSizeDialog[1] + 55, aSizeDialog[2] , { || "com o TSS para envio do certificado digital"}, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 205, 040 )
			Else
				TSay():New( aSizeDialog[1] + 39, aSizeDialog[2] , { || "Certificado digital não encontrado no TSS."}, oPanel,,oFont11Neg,,,, .T.,CLR_RED,, 205, 040 )
				TSay():New( aSizeDialog[1] + 46, aSizeDialog[2] , { || "Utilize a Wizard de comunicação do TAF"}, oPanel,,oFont11Neg,,,, .T.,CLR_RED,, 205, 040 )
				TSay():New( aSizeDialog[1] + 53, aSizeDialog[2] , { || "com o TSS para envio do certificado digital"}, oPanel,,oFont11Neg,,,, .T.,CLR_RED,, 205, 040 )
			EndIf
		EndIf
	EndIf

	// Versão do TSS
	If Empty( aRetorno[2] )
		TSay():New( aSizeDialog[1] + 30, aSizeDialog[2] + 140, { || "Versão do TSS: " }, oPanel,,oFontNeg,,,, .T.,    ,, 110, 010 ) //"Versão do TSS"
		TSay():New( aSizeDialog[1] + 40, aSizeDialog[2] + 140, { || aDiag[4] }, oPanel,,oFont,,,, .T.,CLR_BLACK,, 150, 010 )
	EndIf
	
Return(aDiag)

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafPrtWs

Printa as informações de WS na tela

@Param	oPanel 	 - Objeto da area de trabalho da tela
oFontNeg - Fonte Negrita a ser usada
oFont    - Fonte de texto comum a ser usada

@Author  Rodrigo Aguilar
@Since   10/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TafPrtWs( oPanel, oFontNeg, oFont )

	Local cEndWbs       := ""
	Local lExisWbs      := .F.
	Local lRet          := .F.
	Local xPort         := 0
	Local aSizeDialog   := {}
	Local oLinkWs       := Nil
	Local oLinkOutras   := Nil
	Local cOutrasURL	:= ""
	Local oFont11  		:= TFont():New( 'Arial', , -11, , .F. )
	Local nAux			:= 0
	Local lHTML			:= Iif(lFindClass,FWCSSTools():GetInterfaceCSSType() == 5,.F.)
	Local cTafRest		:= alltrim(SuperGetMv("MV_TAFREST",.T.,""))

	//-----------------------------------
	//Busca o tamanho da area de trabalho
	//-----------------------------------
	aSizeDialog	:=	FWGetDialogSize( oPanel )

	//-----------------------------------------------------
	//Busca o endereço de configuração do WebService do TAF
	//-----------------------------------------------------
	cEndWbs := IF(EMPTY(cTafRest),alltrim( VldWS(.T.)),cTafRest)
	
	If (";"$cEndWbs)
		cOutrasURL	:= Right(cEndWbs, Len(cEndWbs) - At(";", cEndWbs) - 1)
		cEndWbs		:= Left(cEndWbs, At(";", cEndWbs)-2)
	EndIf

	If !Empty( cEndWbs )

		//----------------------------------------------
		//Verifico se existe porta configurada para o WS
		//----------------------------------------------
		xPort := Substr( SubStr( cEndWbs, 6, Len(cEndWbs) ), AT( ":", SubStr( cEndWbs, 6, Len(cEndWbs) ) ) + 1, 4 )

		If AT( "/", SubStr( xPort, 1, Len(xPort) ) ) > 0
			xPort := SubStr( xPort, 1, AT( "/", SubStr( xPort, 1, Len(xPort) ) ) -1 )
		EndIf

		//---------------------------------
		//Verifico se a porta existe no INI
		//---------------------------------
		If IsNumeric( xPort )
			lExisWbs := !Empty( SubStr( cEndWbs, AT( ":", SubStr( cEndWbs, 6, Len(cEndWbs) ) ) + 6, Len( cEndWbs ) )  )

			If lExisWbs
				//------------------------------------------
				//Verifico o Status do serviço WS no momento
				//------------------------------------------
				lRet := .F.
				lRet := TAFCheckConn( cEndWbs )

				oLinkWs := Nil
				
				If !Empty(cOutrasURL)
					TSay():New( aSizeDialog[1] + 40, aSizeDialog[2], { || 'Checar Manualmente*:' }, oPanel,,oFontNeg,,,, .T.,CLR_BLACK,, 150, 010 )
					nAux	:= -5
				EndIf

				TSay():New( aSizeDialog[1] + 5, aSizeDialog[2], { || 'Web Service Configurado corretamente para integração com o ERP' }, oPanel,,oFontNeg,,,, .T.,CLR_BLACK,, 170, 020 )
				TSay():New( aSizeDialog[1] + 25 + nAux, aSizeDialog[2], { || 'Endereço do WS:' }, oPanel,,oFontNeg,,,, .T.,CLR_BLACK,, 150, 010 )

				@aSizeDialog[1] + 25 + nAux,aSizeDialog[2] + 70 Say oLinkWs PROMPT "<u>" + cEndWbs + "</u>" Size 150,010 Font oFont OF oPanel Html Pixel
				oLinkWs:bLClicked := {|| MsgRun( "Abrindo o link do WS.... Aguarde...", "WS", {|| ShellExecute("open",cEndWbs,"","",1) } ) }
				
				If lHTML
					oLinkWs:LTRANSPARENT := .T.
				EndIf

				TSay():New( aSizeDialog[1] + 40 + nAux*2, aSizeDialog[2], { || "Status do Serviço:" }, oPanel,,oFontNeg,,,, .T.,CLR_BLACK,, 150, 010 )

				If !lRet
					TSay():New( aSizeDialog[1] + 40 + nAux*2, aSizeDialog[2] + 70, { || "Parado" }, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 150, 010 )
				Else
					TSay():New( aSizeDialog[1] + 40 + nAux*2, aSizeDialog[2] + 70, { || "Em Execução" }, oPanel,,oFontNeg,,,, .T.,CLR_GREEN,, 150, 010 )
				Endif

				If !Empty(cOutrasURL)
					@aSizeDialog[1] + 40,aSizeDialog[2] + 70 Say oLinkOutras PROMPT "<u>" + Iif(";"$cOutrasURL,Left(cOutrasURL, At(";", cOutrasURL) -1)+"...",cOutrasURL) + "</u>" Size 150,010 Font oFont OF oPanel Html Pixel
					oLinkOutras:bLClicked := {|| MsgRun( "Abrindo o link do WS.... Aguarde...", "WS", {|| OpenURLOut(cOutrasURL) } ) }
					TSay():New( aSizeDialog[1] + 50, aSizeDialog[2] , { || "*Clique no link para checar manualmente as outras URL não validadas." }, oPanel,,oFont11,,,, .T.,CLR_RED,, 180, 010 )
				EndIf
			Else
				TSay():New( aSizeDialog[1] + 5, aSizeDialog[2], { || 'Web Service de Integração não Encontrado - Esta ocorrência pode acontecer caso você tenha alterado o caminho padrão da instalação do TAF alterando o ip e porta do Web Service, sendo isso pode ignorar essa mensagem, caso contrário verifique se o serviço está em execução no seu sistema operacional' }, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 190, 070 )
			Endif
		Else
			TSay():New( aSizeDialog[1] + 5, aSizeDialog[2], { || 'Porta do Web Service não encontrada no appserver.ini, verifique a seção [HTTPREST]' }, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 205, 070 )
		EndIf
	Else
		TSay():New( aSizeDialog[1] + 5, aSizeDialog[2], { || 'Web Service não Encontrado/Configurado para integração com o ERP' }, oPanel,,oFontNeg,,,, .T.,CLR_RED,, 205, 070 )
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TAFPrtRls 

Printa as informações do Release do TAF na tela

@Param	oPanel 	 - Objeto da area de trabalho da tela
oFontNeg - Fonte Negrita a ser usada
oFont    - Fonte de texto comum a ser usada

@Author  Rodrigo Aguilar
@Since   10/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TAFPrtRls( oPanel as object, oFontNeg as object, oFont as object, aRet as array )

	Local aSizeDialog as array
	Local cLabelDic   as character
	Local cLabelRpo   as character
	Local cLabelSMTP  as character
	Local cLabelEmail as character

	Default aRet := {.T., .T., .T., .T.}

	aSizeDialog  := FWGetDialogSize( oPanel )
	cLabelDic    := VldDicion( @aRet )
	cLabelRpo    := VldRPO( @aRet )
	cLabelSMTP   := TafConfigSMTP( @aRet )
	cLabelEmail  := ValidEmail( @aRet )

	TSay():New( aSizeDialog[1] + 5,  aSizeDialog[2], { || STR0049 	}, oPanel,, oFontNeg,,,, .T.,,, 120, 010 ) //"Versão do Dicionário de Dados do TAF: "
	TSay():New( aSizeDialog[1] + 14, aSizeDialog[2], { || cLabelDic }, oPanel,, oFont,,,, .T., Iif( aRet[1], CLR_BLACK, CLR_RED ),, 120, 040 )

	TSay():New( aSizeDialog[1] + 24, aSizeDialog[2], { || STR0050 	}, oPanel,, oFontNeg,,,, .T.,,, 120, 010 ) //"Versão do Repositório de Fontes do TAF: " 
	TSay():New( aSizeDialog[1] + 33, aSizeDialog[2], { || cLabelRpo }, oPanel,, oFont,,,, .T., Iif( aRet[2], CLR_BLACK, CLR_RED ),, 120, 040 )

	TSay():New( aSizeDialog[1] + 43, aSizeDialog[2], { || STR0051 	}, oPanel,, oFontNeg,,,, .T.,,, 120, 010 ) //"Servidor de e-mail: "
	TSay():New( aSizeDialog[1] + 52, aSizeDialog[2], { || cLabelSMTP }, oPanel,, oFont,,,, .T., Iif( aRet[3], CLR_GREEN, CLR_RED ),, 120, 040 )
	TSay():New( aSizeDialog[1] + 61, aSizeDialog[2], { || cLabelEmail }, oPanel,, oFont,,,, .T., Iif( aRet[4], CLR_GREEN, CLR_RED ),, 150, 040 )

Return()

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TAFPrtAcm 

Printa as informações do acumulado do TAF na tela

@Param	oPanel 	 - Objeto da area de trabalho da tela
oFontNeg - Fonte Negrita a ser usada
oFont    - Fonte de texto comum a ser usada

@Author  Rodrigo Aguilar
@Since   10/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TAFPrtAcm( oPanel, oFontNeg, oFont, aCtrl )

	Local aRet			:=	{}
	Local aSizeDialog	:=	FWGetDialogSize( oPanel )
	Local cMsgAtualiz	:=	""

	Default aCtrl	:=	{ .T., .T. }

	If FindFunction( "xTafSmtERP" ) .and. xTafSmtERP()
		TSay():New( aSizeDialog[1] + 10, aSizeDialog[2] + 3, { || "Ambiente Atualizado" }, oPanel,, oFontNeg,,,, .T., CLR_RED,, 190, 090 )

	//----------------------------------------
	//Verifico a versão do acumulado do TAF
	//----------------------------------------
	ElseIf FindFunction( "EngRefTAF" )
		aRet := EngRefTAF()

		TSay():New( aSizeDialog[1] + 5, aSizeDialog[2], { || "Release: " }, oPanel,, oFontNeg,,,, .T.,,, 120, 010 )
		TSay():New( aSizeDialog[1] + 5, aSizeDialog[2] + 32, { || aRet[1] }, oPanel,, oFont,,,, .T., CLR_BLACK,, 150, 010 )
		TSay():New( aSizeDialog[1] + 20, aSizeDialog[2], { || "Data: " }, oPanel,, oFontNeg,,,, .T.,,, 120, 010 )
		TSay():New( aSizeDialog[1] + 20, aSizeDialog[2] + 32, { || DToC( aRet[3] ) }, oPanel,, oFont,,,, .T., CLR_BLACK,, 150, 010 )
		TSay():New( aSizeDialog[1] + 35, aSizeDialog[2], { || "Este ambiente possui todas as correções liberadas no TAF até o dia: " }, oPanel,, oFontNeg,,,, .T.,,, 170, 020 )
		TSay():New( aSizeDialog[1] + 43, aSizeDialog[2] + 32, { || DToC( aRet[2] ) }, oPanel,, oFont,,,, .T., CLR_BLACK,, 150, 010 )
	Else
		cMsgAtualiz += "Ambiente operando com artefatos expedidos para o Release " + GetRPORelease()

		If !aCtrl[1]
			cMsgAtualiz += Chr( 13 ) + Chr( 10 )
			cMsgAtualiz += Chr( 13 ) + Chr( 10 )
			cMsgAtualiz += "Dicionário aplicado é anterior ao pacote expedido em 05/2021."
		EndIf

		If !aCtrl[2]
			cMsgAtualiz += Chr( 13 ) + Chr( 10 )
			cMsgAtualiz += Chr( 13 ) + Chr( 10 )
			cMsgAtualiz += "Repositório não possui pacote de Expedição Contínua do módulo SIGATAF aplicado."
		EndIf

		TSay():New( aSizeDialog[1] + 10, aSizeDialog[2] + 3, { || cMsgAtualiz }, oPanel,, oFontNeg,,,, .T.,,, 240, 090 )
	EndIf

Return()

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafPrtDic 

Printa as informações de Download do Dicionário do TAF na tela

@Param	oPanel 	 - Objeto da area de trabalho da tela
oFontNeg - Fonte Negrita a ser usada
oFont    - Fonte de texto comum a ser usada

@Author  Rodrigo Aguilar
@Since   10/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TafPrtDic( oPanel , oFontNeg, oFont )

	Local cLinkTAF    := ""
	Local aSizeDialog := {}
	Local oLinkTaf    := Nil
	Local oSayTaf    := Nil

	aSizeDialog	:=	FWGetDialogSize( oPanel )

	cLinkTAF := "https://suporte.totvs.com/portal/p/10098/download#000052"

	@aSizeDialog[1] + 5  ,aSizeDialog[2] Say oSayTaf PROMPT "Link para atualizações do TAF:" Size 185,010 Font oFontNeg OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.

	@aSizeDialog[1] + 15 ,aSizeDialog[2] Say oLinkTaf PROMPT  cLinkTAF Size 185,030 Font oFont OF oPanel Html Pixel
	oLinkTaf:LTRANSPARENT := .T.

	@aSizeDialog[1] + 50  ,aSizeDialog[2] Say oSayTaf PROMPT "Após abrir o link selecione a versão do seu release e siga os procedimentos citados no quadro abaixo" Size 195,030 Font oFont OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.

	oLinkTaf:bLClicked := { || MsgAlert( "Atenção, você precisa estar logado no portal do cliente da TOTVS em seu navegador padrão para que o link seja aberto corretamente!", "Atenção" ), ShellExecute( "open", cLinkTAF, "", "", 1 ) }
	oLinkTaf:LTRANSPARENT := .T.

Return

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafPrtRep 

Printa as informações de Download do acumulado de fontes do TAF na tela

@Param	oPanel 	 - Objeto da area de trabalho da tela
oFontNeg - Fonte Negrita a ser usada
oFont    - Fonte de texto comum a ser usada

@Author  Rodrigo Aguilar
@Since   10/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TafPrtRep( oPanel , oFontNeg, oFont )

	Local aSizeDialog := {}
	Local oSayTaf    := Nil

	aSizeDialog	:=	FWGetDialogSize( oPanel )

	@aSizeDialog[1] + 5  ,aSizeDialog[2] Say oSayTaf PROMPT "Dicionário:" Size 205,030 Font oFontNeg OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 5  ,aSizeDialog[2] + 45 Say oSayTaf PROMPT "Selecione a opção 'Dicionário de Dados'" Size 205,030 Font oFont OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 20  ,aSizeDialog[2] Say oSayTaf PROMPT "Repositório:" Size 205,030 Font oFontNeg OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 20  ,aSizeDialog[2] + 45 Say oSayTaf PROMPT "Selecione a opção 'Atualizações Periódicas'" Size 205,030 Font oFont OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 35  ,aSizeDialog[2] Say oSayTaf PROMPT "Help:" Size 205,030 Font oFontNeg OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 35  ,aSizeDialog[2] +45 Say oSayTaf PROMPT "Help: Selecione a opção 'Help de Campos'" Size 205,030 Font oFont OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 50  ,aSizeDialog[2] Say oSayTaf PROMPT "Menu:" Size 205,030 Font oFontNeg OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
	@aSizeDialog[1] + 50  ,aSizeDialog[2] + 45 Say oSayTaf PROMPT "Selecione a opção 'Menus'" Size 205,030 Font oFont OF oPanel Html Pixel
	oSayTaf:LTRANSPARENT := .T.
Return


//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafStatAtu 

Monta tela inferior com as principais informações do ambiente do cliente

@Param   oPanel  - Dialog onde serão criados os objetos
aObjs   - Objetos a serem criados na tela
oBrowse - Objetos a serem criados na tela
oFont   - Objeto referente a fonte utilizada

@Author  Rodrigo Aguilar
@Since   03/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TafStatAtu( oPanel, aObjs, oBrowse, oFont )
	Local aArea			:= GetArea()
	Local cDataLib      := ""
	Local cVereSoc      := VldLayeSo()

	Local lVldTopCOnn   := .F.

	Local aBrowse       := {}
	Local aSizeDialog   := {}
	Local aWebApp       := VldWebApp()
	Local aInfoDb       := VldDbATAF()
	Local aInfoWs       := VldDbAWS()
	Local aRetFils		:= VldChkFils(,,,.T.,)

	//-----------------------------------
	//Busca o tamanho da area de trabalho
	//-----------------------------------
	aSizeDialog	:=	FWGetDialogSize( oPanel )

	//---------------------------------------------------------------
	//Validação do DbAccess, quando o banco é Oracle o cliente deve 
	//verificar manualmente se a configuração esta correta
	//---------------------------------------------------------------
	lVldTopConn := VldTopConn()

	//--------------------------
	//Validação de versão da LIB     
	//--------------------------
	If FindFunction( "FWLibVersion" )
		cDataLib := FWLibVersion()
	Else
		//---------------------------------------------------------------------
		//Verifica data de um fonte da LIB que foi alterado na release 12.1.005
		//---------------------------------------------------------------------
		cDataLib := DToS( GetAPOInfo( "PROTHEUSFUNCTIONMVC.PRX" )[4] )
	EndIf

	//------------------------------------------------------
	//Monta a GRID com as informações do ambiente do cliente
	//------------------------------------------------------
	aBrowse := {;
		{ Iif( Empty( cVereSoc ), "Red", "Yellow" ), "Versão do Layout do e-Social na base do TAF", cVereSoc },;
		{ Iif( VldAutoCon(), "Green", "Red" ), "Tabelas Auto-Contidas", GetMV("MV_VAUTCON"), "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-autocontidas.taf" },;
		{ Iif( VldBinario() = .T., "Green", "Red" ), 'Totvs Application Server', GetBuild(), "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-TotvsApplicationServer" },;
		{ Iif( lVldTopConn .and. "ORACLE" $ Upper( TcGetDB() ) , "Yellow", Iif( lVldTopConn, "Green", "Red") ), 'Totvs DbAccess - TAF', TCGetBuild() + Iif( !Empty( aInfoDb[1,1] ), " - Configurado no IP: " + Alltrim(aInfoDb[1,1]) + " - Porta: " + Alltrim(aInfoDb[1,2]), "Configurações do DbAccess do TAF não encontradas no appserver.ini" ), "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-TotvsDbAccess" },;
		{ Iif( lVldTopConn .and. "ORACLE" $ Upper( TcGetDB() ) , "Yellow", Iif( lVldTopConn, "Green", "Red") ), 'Totvs DbAccess - WS', TCGetBuild() + Iif( !Empty( aInfoWs[1,1] ), " - Configurado no IP: " + Alltrim(aInfoWs[1,1]) + " - Porta: " + Alltrim(aInfoWs[1,2]), "Configurações do DbAccess do WS não encontradas no appserver.ini" ), "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-TotvsDbAccess" },;
		{ Iif( VldLib(), "Green", "Red" ), "Lib", cDataLib, "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-LIB" },;
		{ Iif( VldMemoMega(), "Green", "Red" ), "TopMemoMega", "Não se Aplica", "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-TopMemoMega" },;
		{ Iif( Empty( VldAutoRec() ), "Green", "Red" ), "Auto Recno", "Não se Aplica", "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-AutoRecno" },;
		{ "Yellow", 'Clob', "Não se Aplica", "http://tdn.totvs.com/pages/viewpage.action?pageId=198934697#DiagnósticodeAmbienteeSistema-CLOB" },;
		{ Iif( aWebApp[2], "Green", "Red" ), "WebApp(SmartClient Web)", Iif( !Empty( aWebApp[1] ), "Configurado no IP: " + retServerIP( .T. ) + " - Porta:" + aWebApp[1], "Configuração não encontrada"  ) },;
		{ Iif( aRetFils[1], "Green", "" ), "Amarração Empresas", Iif( aRetFils[1], aRetFils[2], Iif( Len(aRetFils) > 2, aRetFils[2] + aRetFils[3], aRetFils[2] ) ) } }


	If aSizeDialog[4] < 1270 // Ajustes para tamanho de tela (Resolução do Vídeo)
		oBrowse := TWBrowse():New( aSizeDialog[1], aSizeDialog[2], aSizeDialog[3] + 16, aSizeDialog[4] - 1180, , { "", "Status", "Nome do Serviço", "Versão / Detalhes" }, { 10, 65, 120, 50 }, oPanel,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,.T.,.F. )
	Else
		oBrowse := TWBrowse():New( aSizeDialog[1], aSizeDialog[2], aSizeDialog[3] + 55, aSizeDialog[4] - 1257, , { "", "Status", "Nome do Serviço", "Versão / Detalhes" }, { 10, 65, 120, 50 }, oPanel,,,,,{||},,oFont,,,,,.F.,,.T.,,.F.,,.T.,.F. )
	EndIf
	
	oBrowse:SetArray( aBrowse )
	oBrowse:bLine := { || { Iif( aBrowse[oBrowse:nAt,01] == "Green", aObjs[1], iif( aBrowse[oBrowse:nAt,01] == "Red", aObjs[2], aObjs[3] ) ),Iif( aBrowse[oBrowse:nAt,01] == "Green", "Atualizado(a)", Iif( aBrowse[oBrowse:nAt,01] == "Red", "Desatualizado(a)", "Verificar Manualmente" ) ),;
		aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03] } }

	//-------------------------------------------------
	// Abre a página do TDN com o duplo clique do Mouse
	//-------------------------------------------------
	oBrowse:bLDblClick := { || MsgRun( "Abrindo página WEB... Aguarde", "Diagnóstico do TAF", {|| TafExecShell( oBrowse ) } ) }

	RestArea(aArea)
Return

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafGeraLog

Função para abrir o LOG em tela ao cliente

@Param 	cLog - Informa qual LOG deve ser aberto

@Author  Rodrigo Aguilar
@Since   03/04/2018
@Version 1.0  

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TafGeraLog( cLog )

	Local cTafAppServer	:= ""
	Local cBarra        := Iif( IsSrvUnix(), "/", "\" )
	Local cRemotePath	:= GetRemoteIniName()
	Local nAt 	 	    := At(cBarra+'BIN',Upper(cRemotePath))	

	If !Empty( cRemotePath )
		If cLog == "TAF"
			cTafAppServer :=  Substr(cRemotePath,1,nAt) + 'bin'+cBarra+'appserver'+cBarra
		ElseIf cLog == "WS"
			cTafAppServer :=  Substr(cRemotePath,1,nAt) + 'bin'+cBarra+'app'+cBarra
		Endif

		If File( cTafAppServer + "console.log" )
			MsgRun( "Abrindo arquivo de Log do " + cLog + ".... Aguarde...", "Arquivo de Log", {|| ShellExecute( "open", "console.log", "", cTafAppServer, 3) } )
		Else
			MsgAlert( "O arquivo console.log não foi localizado no caminho padrão da instalação." )
		EndIf
	Else
		MsgAlert( "Não foi possível localizar o arquivo appserver.ini do ambiente do TAF no caminho padrão da instalação" )
	Endif

Return

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafExecShell 

Abre a página WEB do TDN

@Param 	oObj - Objeto para saber qual a linha da GRID de onde foi acionado o duplo clique

@Author  Rodrigo Aguilar
@Since   03/04/2018
@Version 1.0  

@Return ( .T. )
*/  
//--------------------------------------------------------------------------------------------------
Function TafExecShell( oObj )
	
	ShellExecute( "open", "http://tdn.totvs.com/pages/viewpage.action?pageId=357597285#Diagn%C3%B3sticodeAmbiente-TAF-Resultadodaan%C3%A1lisedoambiente", "", "", 1 )

Return .T.

//--------------------------------------------------------------------------------------------------
/*{Protheus.doc} TafListaFontes 

Cria Nova tela para exibição dos fontes do taf no repositório

@Param	
lExpFon  - Variavel para chamada da rotina de exportação ZIP

@author    Ronaldo Tapia
@version   12.1.17
@since     05/04/2018

@Return ( Nil )
*/  
//--------------------------------------------------------------------------------------------------
Static Function TafListaFontes( lExpFon )

	Local oListEnd		:=	Nil
	Local aArea			:=	GetArea()
	Local aGetFontes	:=	{}
	Local aRetFontes	:=	{}
	Local aRemove		:=	{}
	Local aFontes		:=	{}
	Local nI			:=	0

	Default lExpFon		:=	.F.

	//Carrega todos os fontes com a sigla TAF do repositório
	aGetFontes := GetSrcArray( "*TAF*" )

	//Lista de fontes que não possuem relacionamento com o módulo TAF, mas que estão listado no GetSrcArray( "*TAF*" )
	aAdd( aRemove, "BANOTAFISCAL.PRW" )
	aAdd( aRemove, "FWCANUSETAF.PRW" )
	aAdd( aRemove, "FWDATAFINAL.PRW" )
	aAdd( aRemove, "FWODATAFILTERPARSER.PRW" )
	aAdd( aRemove, "FWODATAFUNCTIONS.PRW" )
	aAdd( aRemove, "KPI020_METAFORM.PRW" )

	For nI := 1 to Len( aRemove )
		nPos := aScan( aGetFontes, aRemove[nI] )
		If nPos > 0
			aDel( aGetFontes, nPos )
			aSize( aGetFontes, Len( aGetFontes ) - 1 )
		EndIf
	Next nI

	//Adiciona manualmente fontes que estão na pasta do TAF no TFS e que não foram captados pelo GetSrcArray( "*TAF*" )
	aAdd( aGetFontes, "AJUSTID.PRW" )
	aAdd( aGetFontes, "UPDFIL1200.PRW" )
	aAdd( aGetFontes, "TSIXFUN.PRW" )
	aAdd( aGetFontes, "FWHEALTHCHECK.PRW" )
	aAdd( aGetFontes, "WSREINF.PRW" )
	aAdd( aGetFontes, "WSSOCIAL.PRW" )
	aAdd( aGetFontes, "WSESOCIAL.PRW" )
	aAdd( aGetFontes, "WSTSSSETUP.PRW" )

	//Adiciona manualmente fontes que possuem vínculo ao TAF que não estão na pasta do TAF no TFS e que não foram captados pelo GetSrcArray( "*TAF*" )
	aAdd( aGetFontes, "FWDLEXLIST.PRW" )

	//Adiciona manualmente arquivos de extensão APP e que não foram captados pelo GetSrcArray( "*TAF*" )
	aAdd( aGetFontes, "TAFA552.APP" )

	//Adiciona manualmente arquivos de extensão PNG que estão na pasta do TAF no TFS e que não foram captados pelo GetSrcArray( "*TAF*" )
	aAdd( aGetFontes, "IMGTAFR120.PNG" )
	aAdd( aGetFontes, "TAF_CHECK_OFF.PNG" )
	aAdd( aGetFontes, "TAF_CHECK_ON.PNG" )
	aAdd( aGetFontes, "TAF_FILIAL.PNG" )
	aAdd( aGetFontes, "TAF_GRP_EMPRESAS.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BG_MENU.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BG_PANELCENTER.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BG_SEARCH.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BG_SUBMENU.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BG_TITLE.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BG_USER.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BOTTOM_BG.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_BOTTOM_IMG.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_CSSBTN.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_CSSBTNCLICK.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_CSSBTNCONFIRM.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_CSSBTNOVER.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_CSSCOMBOBOX.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_CSSGET.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_DARKBORDERBL.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_DARKBORDERBLFOCUS.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_DARKBORDERBLK.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_DARKBORDERBLKFOCUS.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_DARKBORDERBLKOVER.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_DROPDOWN_SETA.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_H_LINE.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_HEADER_BARRA.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_LOGO_MINI.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_LOGO_TOTVS.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_MENU_DIR.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_MENU_ESQ.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SEPARADOR_SUBMENU.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SETA.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SETASCROLL.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SMALLBG_TITLE.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SMALLCSSBTN.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SMALLCSSGET.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SMALLLINE.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_SPACE.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_TITLE_DIR.PNG" )
	aAdd( aGetFontes, "TAFSMALLAPP_TITLE_ESQ.PNG" )

	//Adiciona manualmente fontes do Extrator que não estão na pasta do TAF no TFS e que não foram captados pelo GetSrcArray( "*TAF*" )
	aAdd( aGetFontes, "EXTSLCLAY.PRW" )
	aAdd( aGetFontes, "EXTT013.PRW" )
	aAdd( aGetFontes, "EXTT013XX.PRW" )
	aAdd( aGetFontes, "EXTT015.PRW" )
	aAdd( aGetFontes, "EXTT045.PRW" )
	aAdd( aGetFontes, "EXTT046.PRW" )
	aAdd( aGetFontes, "EXTT050.PRW" )
	aAdd( aGetFontes, "EXTT066.PRW" )
	aAdd( aGetFontes, "EXTT067.PRW" )
	aAdd( aGetFontes, "EXTT080.PRW" )
	aAdd( aGetFontes, "EXTT096.PRW" )
	aAdd( aGetFontes, "EXTT097.PRW" )
	aAdd( aGetFontes, "EXTT098.PRW" )
	aAdd( aGetFontes, "EXTT105.PRW" )
	aAdd( aGetFontes, "EXTT106.PRW" )
	aAdd( aGetFontes, "EXTT107.PRW" )
	aAdd( aGetFontes, "EXTT108.PRW" )
	aAdd( aGetFontes, "EXTT118.PRW" )
	aAdd( aGetFontes, "EXTXCLASS.PRW" )
	aAdd( aGetFontes, "EXTXDEF.PRW" )
	aAdd( aGetFontes, "FISAEXTFUN.PRW" )
	aAdd( aGetFontes, "FISAEXTSX_CLASS.PRW" )
	aAdd( aGetFontes, "FISAEXTWIZ.PRW" )
	aAdd( aGetFontes, "FISAEXTWIZ_CLASS.PRW" )

	//Adiciona manualmente fontes do Atualizador que não estão na pasta do TAF no TFS e que não foram captados pelo GetSrcArray( "*TAF*" )
	aAdd( aGetFontes, "SEQSTART.PRW" )

	For nI := 1 to Len( aGetFontes )
		aRetFontes := GetApoInfo( aGetFontes[nI] )
		If !Empty( aRetFontes )
			aAdd( aFontes, { aRetFontes[1], aRetFontes[4], aRetFontes[5] } )
		EndIf
	Next nI

	aSort( aFontes,,, { |x,y| x[1] < y[1] } )

	If lExpFon
		TAFExpFon( Nil, "Fontes", GetSrvProfString( "StartPath", "" ) + Iif( Right( GetSrvProfString( "StartPath", "" ), 1 ) == If( ISSrvUnix(), "/", "\" ), "", If( ISSrvUnix(), "/", "\" ) ), aFontes, lExpFon )
	Else
		If Empty( aFontes )
			MsgInfo( "Não foram localizados arquivos do TAF no repositório." )
		Else
			oListEnd := TAFLisInfo( .T., { "Fonte", "Data", "Hora" }, aFontes, { 60, 50, 20 }, "Análise de Ambiente" )
		EndIf
	EndIf

	RestArea( aArea )

Return()

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TAFLisInfo
Lista todos os fontes compilados no RPO

@Param	
lSrcFonte - Pesquisar Fonte ou Tabela
aHeader   - aHeader do Grid
aCols     - aCols do Grid
aColSizes - Tamanho do Grid
cTitulo   - Titulo da Tela
lRelac    - Se .T. identifica que a tela foi chamada para exibição do relacionamento entre tabelas
lTodos    - Se .T. identifica que a tela foi chamada para exibição de todos os registros referente os relacionamento entre tabelas
lApliPath - Se .T. identifica que a tela foi chamada para exibição do histórico de atualizações

@author    Ronaldo Tapia
@version   12.1.17
@since     05/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static function TAFLisInfo( lSrcFonte, aHeader, aCols, aColSizes, cTitulo, lRelac, lTodos, lApliPath )
	Local aArea			:= GetArea()
	Local bLine			:= ""
	Local cDesc			:= ""

	Local Nx 			:= 0
	Local oListBox		:= nil
	Local lAllClient	:= .F.
	Local oArea			:= Nil
	Local oFont			:= Nil
	Local oButt1		:= Nil
	Local oButt2		:= Nil
	Local cSearch		:= Space(20)
	Local aCoord    	:= {}
	Local aWindow   	:= {}
	Local aColumn   	:= {}
	Local oValorN		:=	TFont():New( "Courier new",, -14,, .T. )
	Local lWebApp			:= Iif(lFindClass,GetRemoteType() == REMOTE_HTML .or. (FWCSSTools():GetInterfaceCSSType() == 5),.F.)

	Default aColSizes	:= {}
	Default cTitulo		:= "Analise de Ambiente"
	Default lRelac		:= .F.
	Default lTodos		:= .F.
	Default lApliPath	:= .F.

	If lSrcFonte
		cDesc := "Pesquisar Fonte"
	Else
		cDesc := "Pesquisar Tabela"
	EndIf

	aCoord 		:= { 000, 000, 400, 800 }
	lAllClient 	:= .T.

	oFont	:= TFont():New( "Arial", 08, 14, , .T., , , , .T. )

	If lWebApp
		aWindow := { 040, 060 }
	Else
		aWindow := { 030, 070 }
	EndIf

	aColumn := { 100, 012 }

	oArea := FWLayer():New()

	oFather := tDialog():New( aCoord[1], aCoord[2], aCoord[3], aCoord[4], cTitulo, , , , , CLR_BLACK, CLR_WHITE, , , .T. )

	oArea:Init(oFather,.F., .F. )

	oArea:AddLine("L01",100,.T.)

	oArea:AddCollumn("L01C01",aColumn[01],.F.,"L01")
	oArea:AddCollumn("L01C02",aColumn[02],.F.,"L01")

	oArea:AddWindow("L01C01","TEXT","Funções",aWindow[01],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oText	:= oArea:GetWinPanel("L01C01","TEXT","L01")

	If lRelac .And. !lTodos // Mostra semente os registros divergentes do relacionamento entre tabelas
		TSay():New( 001, 002, { || "Foram encontradas divergências nos compartilhamentos."}, oText,,oValorN,,,, .T.,CLR_RED,, 350, 020 )
			
		@010,002 SAY oBtlinks PROMPT "<u>"+ 'Clique aqui para obter informações sobre como realizar a correção' +"</u>" SIZE 300,010 OF oText HTML PIXEL
		oBtlinks:bLClicked := {|| ShellExecute("open","https://tdn.totvs.com/x/vxpnF","","",1) } 

		If lWebApp
			oBtlinks:LTRANSPARENT := .T.
		EndIf
		
	ElseIf lRelac .And. lTodos // Mostra todos os registros do relacionamento entre tabelas
		TSay():New( 001, 002, { || "Relacionamento entre tabelas do TAF!"}, oText,,oValorN,,,, .T.,CLR_BLACK,, 350, 020 )
	ElseIf lApliPath // Mostra tela com dados do histórico de atualizações
		TSay():New( 001, 002, { || "Histórico de Atualizações"}, oText,,oValorN,,,, .T.,CLR_BLACK,, 350, 020 )
		TSay():New( 010, 002, { || "Total de patchs aplicados: " + cValtoChar(Len(aCols)) }, oText,,oValorN,,,, .T.,CLR_GREEN,, 350, 020 )
	Else // Mostra todos os fontes do repositório
		TSay():New(003,002,{|| cDesc },oText,,,,,,.T.,,,30,20)
		TGet():New(003,050,{|u| if( PCount() > 0, cSearch := u, cSearch ) },oText,120,009,"@!",,,,,,,.T.,,,,.T.,,,.F.,,"","cSearch",,,,.T.,.T.)
		TButton():New(003, 185, "Pesquisar" ,oText,{|| Iif( lSrcFonte, TafFilFon( oListBox, cSearch ), oListBox:nAt := Taffiltab(cSearch, aCols, oListBox:nAt)  )}, 45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	EndIf
	
	oArea:AddWindow("L01C01","LIST","Fontes",aWindow[02],.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oList	:= oArea:GetWinPanel("L01C01","LIST","L01")

	If lRelac
		oButt2 := tButton():New(003,243,"&Exportar",oText,{|| TafWizard( oListBox,1) },45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	ElseIf lApliPath
		oButt2 := tButton():New(003,243,"&Exportar",oText,{|| TafWizard( oListBox,2) },45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	Else
		oButt2 := tButton():New(003,243,"&Exportar",oText,{|| Iif( !lSrcFonte, TafWizard( oListBox,3), TafWizard( oListBox,4) ) },45,11,,,.F.,.T.,.F.,,.F.,,,.F. )
	EndIf

	oButt1 := tButton():New(003,301,"&Sair",oText,{|| oFather:End() },45,11,,,.F.,.T.,.F.,,.F.,,,.F. )

	nTamCol := Len(aCols[01])
	bLine 	:= "{|| {"
	For Nx := 1 To nTamCol
		bLine += "aCols[oListBox:nAt]["+StrZero(Nx,3)+"]"
		If Nx < nTamCol
			bLine += ","
		EndIf
	Next
	bLine += "} }"

	oListBox := TCBrowse():New(0,0,100,100,,aHeader,,oList,'Fonte')
	oListBox:SetArray( aCols )
	oListBox:bLine := &bLine

	If !Empty( aColSizes )
		oListBox:aColSizes := aColSizes
	EndIf

	If lAllClient
		oListBox:Align := CONTROL_ALIGN_ALLCLIENT
	EndIf
	oListBox:SetFocus()
	
	oFather:Activate(,,,.T.,/*valid*/,,/*On Init*/)

	RestArea(aArea)
Return()

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafFilFon
Pesquisa um fonte na tela

@Param	
oListBox - Objeto da area de trabalho da tela
cFonte   - Fonte para pesquisa

@author    Ronaldo Tapia
@version   12.1.17
@since     06/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TAFFilFon( oListBox, cFonte )

	Local nPos	:=	0

	Default oListBox	:=	Nil
	Default cFonte		:=	""

	cFonte := AllTrim( cFonte )

	//Faz um scan no objeto para encontrar a posição e posicionar no browser
	If ValType( cFonte ) == "C" .and. !Empty( cFonte )
		nPos := aScan( oListBox:aArray, { |x| x[1] = cFonte } )

		If nPos > 0
			oListBox:GoPosition( nPos )
			oListBox:Refresh()
		EndIf
	EndIf

	If nPos == 0
		MsgAlert( "Não foi possível encontrar o fonte " + cFonte + " na pesquisa." )
	EndIf

Return()

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TAFExpFon
Exporta a data dos fontes para um arquivo texto

@Param	
oListBox  - Objeto da area de trabalho da tela
cNomeArq  - Nome do arquivo para gravação
cCaminho  - Diretório para gravação

lExpFon   - Define que foi chamado através da rotina de exportação ZIP

@author    Ronaldo Tapia
@version   12.1.17
@since     06/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TAFExpFon( oListBox, cNomeArq, cCaminho, aInFontes, lExpFon )

	Local cTexto	:=	""
	Local cFileTxt	:=	""
	Local cFile		:=	""
	Local nHandle	:=	0
	Local nX		:=	0
	Local nTamFonte	:=	38
	Local nTamData	:=	14
	Local lRetorno	:=	.T.

	Default oListBox	:=	Nil
	Default cNomeArq	:=	""
	Default cCaminho	:=	""
	Default aInFontes	:=	{}
	Default lExpFon		:=	.F.

	If oListBox <> Nil
		aInFontes := oListBox:aArray
	EndIf

	If Empty( cNomeArq ) .and. Empty( cCaminho )
		Aviso( "GeraArquivo", "Parâmetros em branco, verifique!", { "Fechar" } )
		lRetorno := .F.
	EndIf

	If Len( aInFontes ) <= 0
		lRetorno := .F.
	EndIf

	If lRetorno
		cTexto := "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF
		cTexto += "                                         TAF - Diagnóstico de Fontes"
		cTexto += _CRLF
		cTexto += "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF + _CRLF

		cTexto += PadR( "Fonte", nTamFonte ) + PadR( "Data", nTamData ) + "Hora"
		cTexto += _CRLF

		For nX := 1 to Len( aInFontes )
			cTexto += PadR( aInFontes[nX,1], nTamFonte ) + PadR( cValToChar( aInFontes[nX,2] ), nTamData ) + aInFontes[nX,3]
			cTexto += _CRLF
		Next nX

		cFile := AllTrim( cNomeArq ) + ".txt"
		cFileTxt := AllTrim( cCaminho ) + cFile

		//Cria arquivo texto
		nHandle := MsFCreate( cFileTxt )

		If nHandle < 0
			Aviso( "Geração de Arquivo Texto", "Não foi possível criar o arquivo: " + cFile + ". Erro: " + IIf( cValToChar( FError() ) == "13", "Sem permissão de acesso ao diretório, verifique!", cValToChar( FError() ) ), { "Fechar" }, 3 )
		Else
			WrtStrTxt( nHandle, cTexto )

			If !lExpFon
				Aviso( "Geração de Arquivo Texto", "Arquivo: " + cFile + " gerado com sucesso no diretório: " + AllTrim( cCaminho ) + ".", { "Fechar" }, 3 )
			EndIf
		EndIf

		FClose( nHandle )
	EndIf

Return()

/*---------------------------------------------------------------------
{Protheus.doc} VldBinario

Valida versão do Binário (AppServer)

@Author	Anderson Costa / Rodrigo Aguilar
@Since		04/04/2018
@Version	1.0

@Return ( Nil )
//---------------------------------------------------------------------/*/
Static Function VldBinario()

	Local lRet := .F.
	Local cVerBinario := GetBuild()

	// Versão binário - AppServer
	lRet := Substr( Trim( cVerBinario ), 1, 12 ) >= "7.00.131227A"

Return lRet

//---------------------------------------------------------------------
/*{Protheus.doc} VldTopConn

Valida versão do DbAccess (TopConnect)

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return ( Nil )
*/
//---------------------------------------------------------------------
Static Function VldTopConn()

	Local lRet := .F.

	// Versão Build DbAccess
	lRet :=  Trim(TCGetBuild()) >= "20141119"

Return(lRet)

//---------------------------------------------------------------------
/*{Protheus.doc} VldLIB

Valida a LIB

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return ( Nil )
*/
//---------------------------------------------------------------------
Static Function VldLIB()

	Local cData	 :=	""

	If FindFunction( "FWLibVersion" ) //Disponével somente a partir da label 20151008
		cData := FWLibVersion()
	Else
		//Verifica data de um fonte da LIB que foi alterado na release 12.1.005
		cData := DToS( GetAPOInfo( "PROTHEUSFUNCTIONMVC.PRX" )[4] )
	EndIf

Return( cData >= "20150424" )

//---------------------------------------------------------------------
/*{Protheus.doc} VldMemoMega

Valida a chave TopMemoMega no .INI

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return ( Nil )
*/
//---------------------------------------------------------------------
Static Function VldMemoMega()

	Local lRet		:=	.F.
	Local cBuildBin	:=	AllTrim( GetBuild() )
	Local cBuildTOP	:=	AllTrim( TCGetBuild() )

	//Chave TopMemoMega no .INI
	If GetSrvProfString( "TOPMEMOMEGA", "" ) >= "1"
		lRet := .T.
	ElseIf Val(GetSrvProfString( "TOPMEMOMEGA", "" )) > val("1")
		//http://tdn.totvs.com/display/tec/TOPMemoMega
		//Validações executadas:
		//- A atualização do TOTVS | Application Server - build 7.00.131227A com data de geração igual ou superior a 07/10/2016.
		//- No TOTVS | Application Server, o aumento explícito do comprimento máximo de uma cadeia de caracteres em memória através da chave maxStringSize - utilize valor superior ao informado na chave MemoMega.
		//- A atualização do TOTVS | DBAccess - build 42.20161016 com data de geração igual ou superior a 07/10/2016.
		//Validações não executadas:
		//- No TOTVS | DBAccess, o aumento explícito do comprimento máximo de uma cadeia de caracteres em memória através da chave maxStringSize - utilize valor superior ao informado na chave MemoMega.
		//Verificado em consulta a equipe de Tecnologia que não há comando AdvPL para capturar chave do .ini do DBAccess
		If SubStr( cBuildBin, 1, 12 ) >= "7.00.131227A" .and. SubStr( cBuildBin, 14, 8 ) >= "20161007";
				.and. Val( GetPvProfString( "GENERAL", "MAXSTRINGSIZE", "", GetAdv97() ) ) >= Val( GetSrvProfString( "TOPMEMOMEGA", "" ) );
				.and. cBuildTOP >= "20161007"
			lRet := .T.
		EndIf
	EndIf

Return( lRet )

//---------------------------------------------------------------------
/*{Protheus.doc} VldAutoRec

Valida se as tabelas possuem Auto Recno controlado pelo SGBD

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return	cRet - String com as tabelas sem auto recno

*/
//---------------------------------------------------------------------
Static Function VldAutoRec()
	Local aArea			:= GetArea()
	Local cRet		:= ""
	Local cBancoDB	:= tcGetDb()


	If !(cBancoDB $ "OPENEDGE")
		If Substr(Tcinternal(28,"TAFST1"),2,1) == "N"
			cRet := "TAFST1"
		EndIf

		If Substr(Tcinternal(28,"TAFST2"),2,1) == "N"
			cRet += Iif(!Empty(cRet),", TAFST2","TAFST2")
		EndIf

		If Substr(Tcinternal(28,"TAFECF_" + cEmpAnt),2,1) == "N"
			cRet += Iif(!Empty(cRet),", TAFECF_" + cEmpAnt,"TAFECF_" + cEmpAnt)
		EndIf

		If Substr(Tcinternal(28,"TAFSPED_" + cEmpAnt),2,1) == "N"
			cRet += Iif(!Empty(cRet),", TAFSPED_" + cEmpAnt,"TAFSPED_" + cEmpAnt)
		EndIf

		If Substr(Tcinternal(28,"TAFGERCTL"),2,1) == "N"
			cRet += Iif(!Empty(cRet),", TAFGERCTL","TAFGERCTL")
		EndIf
	EndIf

	RestArea(aArea)
Return(cRet)

//---------------------------------------------------------------------
/*{Protheus.doc} VldCLOB

Valida o CLOB

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return	
.F. - Habilitado
.T. - Desabilitado

*/
//---------------------------------------------------------------------
Static Function VldCLOB()

	Local lRet := .F.

Return(lRet)

//---------------------------------------------------------------------
/*{Protheus.doc} VldDicion

Valida o Dicionário

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return cRet - Release do dicionário de dados
*/
//---------------------------------------------------------------------
Static Function VldDicion( aRet as Array )

	Local cRet	   		 as Character
	Local cRelease 		 as Character
	Local cCodDic  		 as Character
	Local oVldDic  		 as Object 

	Default aRet	:=	{ .T., .T. }
	
	cRet	      := ""
	cRelease      := GetRPORelease()
	oVldDic       := Nil

	If cRelease == "12.1.2410"
		cCodDic := "014461"
	ElseIf cRelease == "12.1.2310"
		cCodDic := "012901"
	ElseIf cRelease == "12.1.2210"
		cCodDic := "011221"
	ElseIf cRelease == "12.1.033"
		cCodDic := "009711"
	EndIf
		
	oVldDic := MPUpLogHdl():New(cCodDic) 
	oVldDic:LoadMetadata()
	aMeta := oVldDic:GetMetadata()

	If FindFunction( "xTafSmtERP" ) .and. xTafSmtERP()
		cRet := "Última versão disponível"

	ElseIf len(aMeta) > 0 .and. cRelease $ "12.1.2210|12.1.033" 
		cRet := SubStr(aMeta[Len(aMeta)][6][2][4], 5,2) +"/"+ SubStr(aMeta[Len(aMeta)][6][2][4], 1,4)

	ElseIf cRelease $ "12.1.2410"

		If len(aMeta) > 0
			cRet := SubStr(aMeta[Len(aMeta)][6][3][4], 5,2) +"/"+ SubStr(aMeta[Len(aMeta)][6][3][4], 1,4)

		Else 
			oVldDic := MPUpLogHdl():New("014462") // Dic SEM MARCA
			oVldDic:LoadMetadata()
			aMeta := oVldDic:GetMetadata()

			If len(aMeta) > 0
				cRet := SubStr(aMeta[Len(aMeta)][6][3][4], 5,2) +"/"+ SubStr(aMeta[Len(aMeta)][6][3][4], 1,4)
			EndIf 
		EndIf

	ElseIf cRelease $ "12.1.2310"
		If len(aMeta) > 0
			cRet := SubStr(aMeta[Len(aMeta)][6][3][4], 5,2) +"/"+ SubStr(aMeta[Len(aMeta)][6][3][4], 1,4)

		Else 
			oVldDic := MPUpLogHdl():New("012971") // Dic SEM MARCA
			oVldDic:LoadMetadata()
			aMeta := oVldDic:GetMetadata()

			If len(aMeta) > 0
				cRet := SubStr(aMeta[Len(aMeta)][6][3][4], 5,2) +"/"+ SubStr(aMeta[Len(aMeta)][6][3][4], 1,4)
			EndIf 
		EndIf

	ElseIf !TAFColumnPos( "T1M_TPGUIA" )
		cRet := "Desatualizado - Anterior a 05/2021"
		aRet[1] := .F.
	EndIf

Return( cRet )

//---------------------------------------------------------------------
/*{Protheus.doc} VldRPO

Valida o RPO

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return cRet - Release do dicionário de dados
*/
//---------------------------------------------------------------------
Static Function VldRPO( aRet )

	Local aRetAtu	:=	{}

	Default aRet	:=	{ .T., .T. }

	If FindFunction( "xTafSmtERP" ) .and. xTafSmtERP()
		cRet := "Última versão disponível"
	ElseIf FindFunction( "EngRefTaf" )
		aRetAtu := EngRefTAF()
		cRet := SubStr( DToC( aRetAtu[3] ), 4, 3 ) + cValToChar( Year( aRetAtu[3] ) )
	Else
		cRet := "Desatualizado - Anterior a 05/2021"
		aRet[2] := .F.
	EndIf

Return( cRet )

//---------------------------------------------------------------------
/*{Protheus.doc} VldLayout

Valida o layout.def

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return	0 - Atualizado
1 - Desatualizado
2 - Editado
3 - Não encontrado

*/
//---------------------------------------------------------------------
Static Function VldLayout()
	Local aDate         := {}                // Array que armazenara as datas
	Local aTime         := {}                // Array que armazenara as horas
	Local nRet          := 3
	Local cDataArq := ""				// Data do arquivo no ambiente (utilizada na validação)
	Local cHoraArq := ""				// Hora do arquivo no ambiente (utilizada na validação)

	GetFuncArray( "taflayout", , , , @aDate, @aTime )

	If len(aDate) > 0
		cDataArq := cValToChar(aDate[1])
		cHoraArq := cValToChar(aTime[1])
		nRet := 0
	EndIf

Return({nRet,cDataArq,cHoraArq})

//---------------------------------------------------------------------
/*{Protheus.doc} VldAutoCon

Valida o layout.def

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return	.F. - Desatualizado
.T. - Atualizado

*/
//---------------------------------------------------------------------
Static Function VldAutoCon( nVerAtu )

	Local nVerBase	as numeric
	Local lRet		as logical
    Local aRotinas  := TAFRotinas( "" , 0, .T., 4 )
    Local lNoDiff   := .T.

	Default nVerAtu	:=	GetMV("MV_VAUTCON") //GetNewPar( "MV_VAUTCON", 1000 ) //Parâmetro que indica qual a versão atual das autocontidas na base do cliente

	nVerBase	:=	FTafVAutoC()

    lNoDiff     := AutConVld(aRotinas, nVerAtu)

	lRet		:=	( nVerAtu >= nVerBase ) .And. lNoDiff

Return( lRet )


//---------------------------------------------------------------------
/*{Protheus.doc} ExecDiag

Executa diagnóstico e retorna as informações em um array

@Author	Anderson Costa
@Since		22/07/2015
@Version	1.0

@Return	aDiag
[1] - Totvs Application Server
[2] - Totvs DbAccess (TopConnect)
[3] - LIB
[4] - Chave TopMemoMega no .INI
[5] - Auto Recno
[6] - CLOB
[7] - Dicionário
[8] - RPO
[9] - layout.def
[10] - autocontidas.taf
[11] - TAF no SGBD

*/
//---------------------------------------------------------------------
Static Function ExecDiag()

	Local aDiag	as array

	aDiag	:=	{}

	// 1 - Totvs Application Server (Binário)
	aAdd(aDiag, VldBinario())

	// 2 - Totvs DbAccess (TopConnect)
	aAdd(aDiag, VldTopConn())

	// 3 - LIB
	aAdd(aDiag, VldLIB())

	// 4 - Chave TopMemoMega no .INI
	aAdd(aDiag, VldMemoMega())

	// 5 - Auto Recno ativo 
	aAdd(aDiag, VldAutoRec())

	// 6 - CLOB ativo
	aAdd(aDiag, VldCLOB())

	// 7 - Dicionário
	aAdd(aDiag, VldDicion())

	// 8 - RPO
	aAdd(aDiag, VldRPO())

	// 9 - Layout.def
	aAdd(aDiag, VldLayout())

	// 10 - Autocontidas.taf
	aAdd(aDiag, VldAutoCon())

	// 11 - Valida se o TAF está configurado para acessar o TOP
	aAdd( aDiag, TAFDGTop() )

	// 12 - Status ECF
	aAdd(aDiag, VldDicECF())

	// 13 - Web Service
	aAdd(aDiag, VldWS())

	// 14 - Web Service TSS
	aAdd(aDiag, VldWSTss())

Return( aDiag )

//---------------------------------------------------------------------
/*{Protheus.doc} TAFVldStart

Retorna status de atualização das autocontidas para todos os Grupos de Empresas.

@Return	Array
[1] - Status por Grupo de Empresas
[2] - Status Geral, se uma estiver incorreta, retorna .F.

@Author	Gustavo G. Rueda
@Since		12/08/2016
@Version	1.0
*/
//---------------------------------------------------------------------
Function TAFVldAC()

	Local nX	as numeric
	Local aSM0	as array
	Local aEmp	as array
	Local lRet	as logical
	Local lSXs	as logical

	nX		:=	0
	aSM0	:=	FWLoadSM0()
	aEmp	:=	{}
	lRet	:=	.T.
	lSXs	:=	.F.

	For nX := 1 to Len( aSM0 )
		lSXs := .F.

		If aSM0[nX,SM0_USEROK] .and. ( ValType( aSM0[nX,SM0_EMPOK] ) == "U" .or. aSM0[nX,SM0_EMPOK] ) .and. aSM0[nX,SM0_GRPEMP] == cEmpAnt
			If aScan( aEmp, { |aX| aX[1] == aSM0[nX,SM0_GRPEMP] } ) == 0
				If aSM0[nX,SM0_GRPEMP] == cEmpAnt
					aAdd( aEmp, { aSM0[nX,SM0_GRPEMP], VldAutoCon() } )
					lSXs := .T.
				Else
					OpenSxs( ,,,, aSM0[nX,SM0_GRPEMP], "SX6TAF", "SX6",, .F.,, .T., .F. )
					If Select( "SX6TAF" ) > 0 .and. MsSeek( Space( Len( X6_FIL ) ) + "MV_VAUTCON" )
						aAdd( aEmp, { aSM0[nX,SM0_GRPEMP], VldAutoCon( Val( X6_CONTEUDO ) ) } )
						SX6TAF->( DBCloseArea() )
						lSXs := .T.
					EndIf
				EndIf

				If lSXs .and. !aEmp[ Len( aEmp ), 2]
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Next nX

Return{ aEmp, lRet }

//---------------------------------------------------------------------
/*{Protheus.doc} TAFDGTop

Função que valida se o TAF está sendo executado em TOP ou não.

@Author	Gustavo G. Rueda
@Since		12/08/2016
@Version	1.0

@Return	lOK	- .T. para ambiente em TOP, .F. para não
*/
//---------------------------------------------------------------------
Static Function TAFDGTop()

	Local cDataBase	as	character
	Local cIniFile	as	character
	Local aItens1	as	array
	Local lOK	:=	.F.

	cDataBase	:=	""
	cIniFile	:=	GetAdv97()
	aItens1	:=	{}

	aAdd( aItens1, "MSSQL" )
	aAdd( aItens1, "MSSQL7" )
	aAdd( aItens1, "ORACLE" )
	aAdd( aItens1, "DB2" )
	aAdd( aItens1, "INFORMIX" )
	aAdd( aItens1, "SYBASE" )
	aAdd( aItens1, "POSTGRES" )
	aAdd( aItens1, "MYSQL" )
	aAdd( aItens1, "OPENEDGE" )

	//+--------------------------------------------------------------------+
	//|Busca as configurações de: Server, DataBase e Alias do TOP utilizado|
	//|na Retaguarda. Considera tanto a chave prefixada com "TOP" como     |
	//|também prefixada com "DB", pois ambos podem ser utilizados.         |
	//+--------------------------------------------------------------------+
	//1o. Busca na Seção [DBAccess]
	cDataBase := GetPvProfString( "DBAccess"	, "DataBase", cDataBase, cIniFile )

	//2o. Busca na Seção [TopConnect]
	cDataBase := GetPvProfString( "TopConnect"	, "DataBase", cDataBase, cIniFile )

	//3o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "DB"
	cDataBase := GetSrvProfString( "DBDataBase"	, cDataBase )

	//4o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "Top"
	cDataBase := GetSrvProfString( "TopDataBase", cDataBase )

	If aScan( aItens1, { |aX| aX == Upper(cDataBase) } ) > 0
		lOk := .T.
	EndIf

Return( lOk )

//---------------------------------------------------------------------
/*{Protheus.doc} TAFVldStart

Função que publica da ExecDiag

@Return	Array	-	Resultado da função ExecDiag()
[1]		-	Totvs Application Server
[2]		-	Totvs DBAccess ( TopConnect )
[3]		-	LIB
[4]		-	Chave TopMemoMega no .INI
[5]		-	Auto Recno
[6]		-	CLOB
[7]		-	Dicionário
[8]		-	RPO
[9]		-	Layout.def
[10]	-	autocontidas.taf
[11]	-	TAF no SGBD

@Author	Gustavo G. Rueda
@Since		12/08/2016
@Version	1.0
*/
//---------------------------------------------------------------------
Function TAFVldStart()
Return( ExecDiag() )

//---------------------------------------------------------------------
/*{Protheus.doc} VldDICECF

Valida o Dicionário para o ECF 2017

@Author	Ronaldo Tapia
@Since		06/07/2017
@Version	1.0

@Return lRet - Valida pacote do ECF 2017
*/
//---------------------------------------------------------------------
Function VldDICECF()

	Local	lVldECF2017 := TAFAlsInDic("T67")//Validação para a garantia do pacote de 2017
	Local	lRet		:=	.T.

	If !lVldECF2017 .And. Len(GetAPOInfo("TAFA471.PRW")) == 0
		lRet :=	.F.
	EndIf

Return lRet

//---------------------------------------------------------------------
/*{Protheus.doc} VldWS

Valida se o WebService foi criado

@Author	Fabio V Santana
@Since		12/07/2017
@Version	1.0

@Return cString - HTTP do WebService
*/
//---------------------------------------------------------------------
Function VldWS(lTodosIPs)

	local	cString		as	char
	local 	cPorta		as	char
	local  cSocket   	as	char
	local 	cURL		as	char
	local 	cURI		as	char
	local	cIniFile	as	char
	local 	cIp			as	char
	Local 	cRestPath	as 	char
	Local 	cSocketREST	as  char
	Local	aIPs		as	array
	Local 	nInd		as	numeric

	DEFAULT lTodosIPs := .F.

	cString	:=	''
	cPorta		:=	''
	cSocket	:=	''
	cURL 		:= ''
	cURI 		:= ''
	cIniFile	:=	getAdv97()
	cIp			:=	retServerIP(lTodosIPs)
	cRestPath 	:= GetSrvProfString( "RootPath" , "" )+"\bin\app\"+cIniFile
	cSocketREST	:= 'HTTPREST'

	cSocket	:= getPvProfString( 'HTTPV11' , 'SOCKETS' , '' , If (File(cRestPath),cRestPath,getAdv97())  )
	
	If at( cSocket , ',' ) > 0
		cSocket := subStr( cSocket , 1 , at( cSocket , ',' ) )
	EndIf

	cSocket := IIf(Empty(cSocket),cSocketREST,cSocket)

	If !Empty(AllTrim(cSocket))
 		cPorta :=	getPvProfString( cSocket , 'PORT' , '' , If (File(cRestPath),cRestPath,getAdv97()) , Nil, Nil   )
		cURI	:= 	getPvProfString( cSocket , 'URIs' , '' , If (File(cRestPath),cRestPath,getAdv97()) , Nil, Nil  )

		If !Empty(AllTrim(cURI))
			cURL	:= getPvProfString( cURI , 'URL' , '' , If (File(cRestPath),cRestPath,getAdv97()) , Nil, Nil )
		EndIf

		If (";"$cIp)
			aIPs	:= StrTokArr( cIp, "; " )
			For nInd := 1 to Len(aIPs)
				If !("Múlt.Redes*"$aIPs[nInd])
					If ('http://'$cString)
						cString += " ; "
					Endif
					cString += 'http://' + AllTrim(aIPs[nInd]) + ':' + cPorta + cURL
				EndIf
			Next nInd
		Else
			cString := 'http://' + cIp + ':' + cPorta + cURL
		EndIf
	EndIf

Return cString

//---------------------------------------------------------------------
/*{Protheus.doc} VldWSTss

Valida se o WebService foi criado

@Author	Ricardo Lovrenovic
@Since		15/08/2017
@Version	1.0

@Return lRet - Retorne se o WebService foi criado
*/
//---------------------------------------------------------------------
Function VldWSTss()

	Local cUrl 		as Char
	Local cCheckURL as Char

	If FindFunction("TafGetUrlTSS")
		cURL := PadR(TafGetUrlTSS(),250)
	Else
		cURL := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	EndIf 
	cURL := AllTrim(cURL)

	cCheckURL := ""

	If !EMPTY(cUrl)
		If !("TSSWSSOCIAL.APW" $ Upper(cUrl)) 
			cCheckURL := cUrl
			cUrl += "/TSSWSSOCIAL.apw"
		Else
			cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
		EndIf	
		lRet := TAFCTSpd(cCheckURL)
	Else
		lRet := .F.
	EndIf	

Return(lRet)

//---------------------------------------------------------------------
/*{Protheus.doc} VldTab

Valida se as tabelas C1E e T3M são completamente compartilhadas

@Author	Paulo Duque
@Since		12/03/2017
@Version	1.0

@Return lRet - Retorne .T. se as tabelas C1E e T3M são completamente compartilhadas
*/
//---------------------------------------------------------------------
Function VldTab()
	Local cTabC1E := ''
	Local cTabT3M := ''
	Local cArea   := GETAREA()

	cTabC1E := Upper(AllTrim(FWModeAccess("C1E",3)+FWModeAccess("C1E",2)+FWModeAccess("C1E",1)))
	
	cTabT3M := Upper(AllTrim(FWModeAccess("T3M",3)+FWModeAccess("T3M",2)+FWModeAccess("T3M",1)))

	If alltrim(cTabC1E) == 'CCC' .and. alltrim(cTabT3M) == 'CCC'
		lRet := .T.
	Else
		lRet := .F.
	EndIf

	RESTAREA(cArea)

Return(lRet)

//---------------------------------------------------------------------
/*{Protheus.doc} VldTabTAF

Valida o compartilhamento de tabelas no protheus

@Author	Alexandre de Lima Santos
@Since		04/02/2022
@Version	1.0

@Param	cTab, caracter, Alias da tabela para ver o compartilhamento
		nTipo, numerico, Tipo de Compartilhamento
			0-Todos (Default)
			1-Compartilhamento de Filial
			2-Compartilhamento de Unidade de Negocio
			3-Compartilhamento de Empresa

@Return cRet, caracter, Retorna o tipo de compartilhamento da tabela utilizada
*/
//---------------------------------------------------------------------
Function VldTabTAF( cTab, nTipo )

	Local cRet		:= ""
	Local cArea   	:= GETAREA()

	Default cTab := 'T3M'
	Default nTipo	:= 0

	cRet := Upper( AllTrim( FWModeAccess( cTab, 3 ) + FWModeAccess( cTab, 2 ) + FWModeAccess( cTab, 1 ) ) )
	cRet := Substr(cRet, nTipo, IIF(nTipo == 0, 3, 1))

	RESTAREA( cArea )

Return( cRet )


//---------------------------------------------------------------------
/*{Protheus.doc} VldLayeSo

Valida a versão do layout do eSocial

@Author	Ronaldo Tapia
@Since		05/04/2018
@Version	1.0

@Return cVerSchema - Versão do layout do eSocial
[1]
*/
//---------------------------------------------------------------------
Static Function VldLayeSo()

	// Retorna a versão do layout
	Local cVerSchema	:= SuperGetMv('MV_TAFVLES',.F.,"02_04_02")

Return (cVerSchema)

//---------------------------------------------------------------------
/*{Protheus.doc} VldWEBAPP

Verifica se possui a TAG WEBAPP

@Author	Ronaldo Tapia
@Since		05/04/2018
@Version	1.0

@Return aRet
[1] - Porta de conexão com WebAPP
[2] - Verifica se existe configuração para WebAPP
*/
//---------------------------------------------------------------------
Static Function VldWebApp()
	Local aArea			:= GetArea()
	Local cWebAPP		:= ""
	Local aRet	   		:= { "", .F. }
	Local cPath         := ""
	Local nRet          := 0

	// Retorna o caminho do appserver.ini
	nRet := getAppPath(@cPath)
		
	// Busca a seção WEBAPP no ini do server
	cWebAPP	:= GetPvProfString( "WEBAPP" , "PORT", "", cPath + "\" + GetSrvIniName() )

	aRet[1] := cWebAPP

	If !Empty(cWebAPP)
		aRet[2] := .T.
	EndIf

	RestArea(aArea)

Return ( aRet )

//---------------------------------------------------------------------
/*{Protheus.doc} VldDbATAF

Verifica IP e Porta do DBAccess do TAF

@Author	Ronaldo Tapia
@Since		05/04/2018
@Version	1.0

@Return aDbAccess
[1] - Endereço de configuração do DBAccess do TAF
[2] - Porta de configuração do DBAccess do TAF
*/
//---------------------------------------------------------------------
Static Function VldDbATAF()

	Local cBinPath		:= ""
	Local cDBServer     := ""
	Local cDBPort       := ""
	Local nRet          := 0
	Local aDbAccess		:= {}

	// Retorna o caminho do appserver.ini
	nRet := getAppPath(@cBinPath)
	
	// Workaroud do DbAccess
	//1o. Busca na Seção [DBAccess]
	cDBServer   := GetPvProfString( "DBAccess", "Server"    , cDBServer	, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort	    := GetPvProfString( "DBAccess", "Port" 	    , cDBPort	, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	
	//2o. Busca na Seção [TopConnect]
	cDBServer 	:= GetPvProfString( "TopConnect", "Server"	, cDBServer	, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort 	:= GetPvProfString( "TopConnect", "Port"	, cDBPort	, cBinPath + "\" + GetSrvIniName(), Nil, Nil)

	//3o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "DB"
	cDBServer 	:= GetSrvProfString( "DBServer"				, cDBServer, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort 	:= GetSrvProfString( "DBPort"				, cDBPort  , cBinPath + "\" + GetSrvIniName(), Nil, Nil)

	//4o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "Top"
	cDBServer 	:= GetSrvProfString( "TopServer"			, cDBServer, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort 	:= GetSrvProfString( "TopPort"				, cDBPort  , cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	
	If Empty(cDBPort)
		cDBPort := "7890"
	EndIf

	aAdd( aDbAccess, {cDBServer	,cDBPort})

Return ( aDbAccess )

//---------------------------------------------------------------------
/*{Protheus.doc} VldDbAWS

Verifica IP e Porta do DBAccess do WS

@Author	Ronaldo Tapia
@Since		05/04/2018
@Version	1.0

@Return aDbAccess
[1] - Endereço de configuração do DBAccess do WS
[2] - Porta de configuração do DBAccess do WS
*/
//---------------------------------------------------------------------
Static Function VldDbAWS()

	Local cBinPath		:= ""
	Local cDBServer     := ""
	Local cDBPort       := ""
	Local nRet          := 0
	Local aDbAccess		:= {}

	// Retorna o caminho do appserver.ini
	nRet := getAppPath(@cBinPath)

	// Workaroud do DbAccess
	//1o. Busca na Seção [DBAccess]
	cDBServer   := GetPvProfString( "DBAccess", "Server"    , cDBServer	, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort	    := GetPvProfString( "DBAccess", "Port"    	, cDBPort	, cBinPath + "\" + GetSrvIniName(), Nil, Nil)

	//2o. Busca na Seção [TopConnect]
	cDBServer 	:= GetPvProfString( "TopConnect", "Server"	, cDBServer		, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort 	:= GetPvProfString( "TopConnect", "Port"	, cDBPort		, cBinPath + "\" + GetSrvIniName(), Nil, Nil)

	//3o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "DB"
	cDBServer 	:= GetSrvProfString( "DBServer"				, cDBServer, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort 	:= GetSrvProfString( "DBPort"				, cDBPort  , cBinPath + "\" + GetSrvIniName(), Nil, Nil)

	//4o. Busca na Seção do ENVIRONMENT considerando a chave prefixada com "Top"
	cDBServer 	:= GetSrvProfString( "TopServer"			, cDBServer, cBinPath + "\" + GetSrvIniName(), Nil, Nil)
	cDBPort 	:= GetSrvProfString( "TopPort"				, cDBPort  , cBinPath + "\" + GetSrvIniName(), Nil, Nil)

	If Empty(cDBPort)
		cDBPort := "7890"
	EndIf

	aAdd( aDbAccess, {cDBServer	,cDBPort})

Return (aDbAccess)

//-------------------------------------------------------------------
/*{Protheus.doc} TafCheckFil

Função para comparar campo Filial do Dicionario x Banco de Dados
retorna array com as tabelas divergentes. 

@Param
lExpTab - Variavel que define se a chamada foi realizada pela rotina de exportação ZIP

@author  Lucas Gasparoni
Wagner Soares
@since   04/04/2018
@version 1.0

@Return - array com as tabelas divergentes. 
*/
//-------------------------------------------------------------------
Function TafCheckFil(lExpTab)
	Local aArea		:= GetArea()
	Local cSX3      := ""
	Local cFiltro   := "X2_MODULO == 84"
	Local nTamanho  := 0
	Local nNx       := 0
	Local aDifer    := {}
	Local aTabela   := {}
	Local aEstrut   := {}
	Local oListEnd  := Nil
	Local cBarra    := If(issrvunix(), "/", "\")
	Local cPath	    := GetSrvProfString("StartPath", "") + If( Right( GetSrvProfString("StartPath",""), 1 ) == cBarra, "", cBarra )
	Local cExpTab   := "dif_filial"
	Local cCampo	:= ""

	Default lExpTab := .F.

	DBSelectArea( "SX3" )
	SX3->( DbSetOrder(1) )

	DbSelectArea( "SX2" )
	SX2->( DbSetOrder(1) )
	SX2->( DbSetFilter( { || &cFiltro }, cFiltro ) )

	SX2->( DbGoTop() )
	While SX2->( !Eof() )
		Aadd( aTabela, FWX2CHAVE() )
		SX2->( DbSkip() )
	EndDo
	
	ProcRegua(Len(aTabela))

	For nNx := 1 To Len( aTabela )
		
		IncProc( "Verificando tabela: " + aTabela[ nNx ]) //"Verificando tabela: "
		cSX3 := aTabela[ nNx ]

		If !(cSX3 $ "V10|V11|V12|V13|V59")
			If SX3->( DbSeek( cSX3 ) )

				aEstrut  := (cSX3)->( DbStruct() )
				nTamanho := aEstrut[1][3]
				cCampo	 := aEstrut[1][1]

				If nTamanho <> GetSx3Cache(cCampo,"X3_TAMANHO")
					Aadd( aDifer,{ cSX3, aEstrut[1][1], aEstrut[1][3], GetSx3Cache(cCampo,"X3_TAMANHO") } )
				EndIf
			EndIf

			If Select(cSX3) > 0
				(cSX3)->(DbCloseArea())
			EndIf
		EndIf
	Next

	If Len( aDifer ) > 0
		If !lExpTab
			oListEnd := TAFLisInfo(	.F.,;
				{ "Tabela","Campo","Tamanho no Banco de Dados", "Tamanho no Dicionário" },;
				aDifer,;
				{ 60, 50, 50, 50},;
				"Análise de Ambiente - Comparativo do Campo _Filial")
		Else
			TafExp_Fil(Nil,cExpTab,cPath,aDifer,lExpTab)
		EndIf
	Else
		If !lExpTab
			MsgInfo( "Não foram encontradas divergências no dicionário do TAF" )
		EndIf
	EndIf
	RestArea(aArea)

Return ( aDifer )

//-------------------------------------------------------------------
/*{Protheus.doc} TafExp_Fil

Gera TXT com as diferenças encontradas 

@Param
oListBox - Array com as tabelas divergentes.
cNomeArq - Nome do arquivo
cCaminho - Caminho do arquivo
aInfTab  - Array com os dados
lExpTab  - Identifica chamada pela rotina de exportação ZIP

@author  Lucas Gasparoni
Wagner Soares
Ronaldo Tapia

@since   04/04/2018
@version 1.0

@Return ( Nil )
*/
//-------------------------------------------------------------------
Static Function TafExp_Fil(oListBox,cNomeArq,cCaminho,aInfTab,lExpTab)

	Local cLinTxt	:= ""
	Local nHandle	:= 0
	Local cFileTxt	:= ""
	Local lRetorno	:= .T.
	Local cFile		:= ""
	Local nx

	Default oListBox := Nil
	Default cNomeArq := ""
	Default cCaminho := ""
	Default aInfTab  := {}
	Default lExpTab  := .F.

	cCaminho := AllTrim(cCaminho)
	
	If oListBox <> Nil
		aInfTab := oListBox:aArray
	EndIf

	If Empty(cNomeArq) .And. Empty(cCaminho)
		Aviso("GeraArquivo", "Parametros em Branco, verifique!", {"Ok"}) // "GeraArquivo" ## "Parametros em Branco, verifique!" ## "Ok"
		lRetorno := .F.
	EndIf

	If Len(aInfTab) < 0
		lRetorno := .F.
	EndIf

	If lRetorno
		cLinTxt := Replicate("*",10)+" L O G  D E  P R O C E S S O - T A F ( VERIFICAR CAMPO _FILIAL) "+Replicate("*",10)
		cLinTxt += _CRLF + _CRLF
	
		cLinTxt += "TABELA  CAMPO          TAMANHO - BD   TAMANHO - DICIONARIO"
		cLinTxt += _CRLF
	
		For nX := 1 to len(aInfTab)
			cLinTxt += PADR(aInfTab[nX,1],8)
			cLinTxt += PADR(aInfTab[nX,2],15)
			cLinTxt += PADR(StrZero(aInfTab[nX,3],4),15)
			cLinTxt += PADR(StrZero(aInfTab[nX,4],4),4)
			cLinTxt += _CRLF
		Next nX
	
		cFile    := Alltrim(cNomeArq) + ".txt"
		cFileTxt := cCaminho + cFile
	
		// Cria arquivo texto
		nHandle := MsFCreate(cFileTxt)
	
		If nHandle < 0
			Aviso("Geração de Arquivo Texto","Não foi possível criar o arquivo: " + cFile + "." + " Erro: " + IIf(cValToChar( FError() ) == "13", "Sem permissão de acesso ao diretório, verifique!",cValToChar( FError() )),{"Ok"},3) // "Geração de Arquivo Texto" ## "Não foi possível criar o arquivo: " ## "Erro: " ## "Ok"
		Else
			WrtStrTxt(nHandle,cLinTxt)
			If !lExpTab
				Aviso("Geração de Arquivo Texto","Arquivo: " + cFile + " " + "gerado com sucesso no Diretório: " + Alltrim(cCaminho) + ".",{"Ok"},3) // "Geração de Arquivo Texto" ## "Arquivo: " ## "gerado com sucesso no Diretório: " ## "Ok"
			EndIf
		EndIf
	
		FClose(nHandle)
	EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Taffiltab

Pesquisa uma tabela da tela

@Param
cTarget - Tabela a ser pesquisa
aSearch - aCols 
nPos    - Posição

@author  Lucas Gasparoni
Wagner Soares

@since   04/04/2018
@version 1.0

@Return ( nPes ) - Posição encontrada
*/
//-------------------------------------------------------------------

Static Function Taffiltab( cTarget, aSearch, nPos )

	Local nPes := 0

	nPes := aScan( aSearch, { |x| x[ 1 ] == Alltrim(cTarget) } )

	If nPes == 0
		nPes := nPos
	EndIf

Return ( nPes )

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafWizard
Monta um wizard para exportar os dados

@Param	
oListBox - Objeto da area de trabalho da tela
nOpc	 - 1(Relac. entre Tabelas); 2(Hist. Atualizações); 3(Diver. Tabelas) ;4(Data Fontes) ;5(Exporta ZIP); 6(Exporta Tabela LOG (_PROTUL))

@author    Ronaldo Tapia
@version   12.1.17
@since     06/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TafWizard(oListBox,nOpc)
	Local aArea			:= GetArea()
	Local oWizard 		:= Nil
	Local aPWiz 		:= {}
	Local aRetWiz		:= {}
	Local nOpcRot		:= 0
	Local cTexto1		:= "Essa rotina irá exportar os dados para um arquivo texto."
	Local cTexto2		:= "Essa rotina irá exportar os dados da tabela de Log (TAF x RET)."
	Local lRet			:= .T.

	Default oListBox    := Nil
	Default nOpc		:= 0
	
	If nOpc == 6 .And. !TAFAlsInDic( "V1V" ) // Valida se a tabela existe no dicionário
		cMsg := "O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados UPDTAF."
		MsgInfo( cMsg, "Ambiente Desatualizado!" )
		lRet := .F.	
	EndIf

	If lRet
		aAdd(aPWiz,{ 1,"Nome do arquivo",Space(50),"","","","",50,	.T.}) //"Nome do arquivo"
		aAdd(aPWiz,{ 6,"Diretorio de Gravacao",Space(100),"","","",100,.T.,"", "",GETF_LOCALHARD + GETF_RETDIRECTORY }) //"Diretorio de Gravacao"
		aAdd(aRetWiz,Space(50))
		aAdd(aRetWiz,Space(50))
		aAdd(aRetWiz,.F.)
	
		DEFINE WIZARD oWizard TITLE "Exportar Dados" HEADER "Geração de Arquivo Texto" 	MESSAGE "Parâmetros Iniciais..." TEXT Iif( nOpc == 6, cTexto2, cTexto1 ) NEXT {||.T.} FINISH {|| .F. } PANEL
	
		CREATE PANEL oWizard HEADER "Dados do Arquivo" MESSAGE "" BACK {|| .T. } NEXT {|| .T. } FINISH {|| nOpcRot := 1 , .T. } PANEL
	
		ParamBox(aPWiz,"Parâmetros...",@aRetWiz,,,,,,oWizard:GetPanel(2))
	
		ACTIVATE WIZARD oWizard CENTERED

		If nOpcRot == 1
			Do Case
			Case nOpc == 1
				FWMsgRun( , { || CursorWait(),TafExpRelac( oListBox, aRetWiz[1], aRetWiz[2] ) }, , "Aguarde! Gerando arquivo..." )
			Case nOpc == 2
				FWMsgRun( , { || CursorWait(),TAFExpPatc( oListBox, aRetWiz[1], aRetWiz[2] ) }, , "Aguarde! Gerando arquivo..." )
			Case nOpc == 3
				FWMsgRun( , { || CursorWait(),TafExp_Fil( oListBox, aRetWiz[1], aRetWiz[2] ) }, , "Aguarde! Gerando arquivo..." )
			Case nOpc == 4
				FWMsgRun( , { || CursorWait(),TafExpFon( oListBox, aRetWiz[1], aRetWiz[2] ) }, , "Aguarde! Gerando arquivo..." )
			Case nOpc == 5
				Processa( {|| TAFGerZIP( Nil, aRetWiz[1], aRetWiz[2] ) }, "Aguarde!", "Inicio do Processamento...")
			Case nOpc == 6
				FWMsgRun( , { || CursorWait(),TafTabLog(aRetWiz[1], aRetWiz[2] ) }, , "Aguarde! Gerando arquivo..." )
			EndCase
		EndIf
	EndIf

	RestArea(aArea)

Return()

//---------------------------------------------------------------------
/*{Protheus.doc} VldURLTSS

Valida URL de configuração do TSS

@Author	Ronaldo Tapia
@Since		05/04/2018
@Version	1.0

@Return aRet
[1] - TSS configurado
[2] - Endereço do TSS
*/
//---------------------------------------------------------------------
Static Function VldURLTSS()

	Local cUrlTSS	:= Alltrim( SuperGetMv('MV_TAFSURL',.F.,"") )
	Local aRet		:= {}
	Local lRet		:= .F.

	If !Empty(cUrlTSS)
		If Upper( Substr( cUrlTSS, 1, 4 ) ) <> "HTTP"
			cUrlTSS := lower( "HTTP://" + cUrlTSS )
		Endif
		lret := .T.
	EndIf

	// Retorna se a URL do TSS esta configurada
	aAdd(aRet,{lRet,cUrlTSS})

Return (aRet)

//---------------------------------------------------------------------
/*{Protheus.doc} VldConTSS

Tela de processamento da chamada da função VldSttTSS

@Author	Ronaldo Tapia
@Since		11/04/2018
@Version	1.0

@Return lRetorno
Conexão com TSS

*/
//---------------------------------------------------------------------
Static Function VldConTSS()
	Local aArea	:= GetArea()
	Local aRetorno  := { .F., "" }
	//FWMsgRun(,{|| CursorWait(),aRetorno := VldSttTSS(),CursorArrow()},,"Aguarde! Verificando conexão com TSS..." )
	Processa( {|| aRetorno := VldSttTSS() }, "Aguarde!", "Verificando conexão com TSS...")
	
	RestArea(aArea)
Return(aRetorno)


//---------------------------------------------------------------------
/*{Protheus.doc} VldSttTSS

Valida status de comunicação com o TSS

@Author	Ronaldo Tapia
@Since		11/04/2018
@Version	1.0

@Return lRetorno
Conexão com TSS
*/
//---------------------------------------------------------------------

Static Function VldSttTSS()

	Local cURL      := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	Local oWS
	Local aRetorno  := { .F., "" }

	If !( Empty( SM0->M0_NOMECOM ) .Or. Empty( SM0->M0_ENDENT ) .Or. Empty( SM0->M0_CIDENT ) .Or. Empty( SM0->M0_ESTENT ) .Or. Empty( SM0->M0_CEPENT ) .Or. Empty( SM0->M0_CGC ) )
			
		//Verifica se o servidor da Totvs esta no ar
		oWs := WsSpedCfgNFe():New()
		oWs:cUserToken := "TOTVS"
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CFGCONNECT()
			aRetorno[1] := .T.
		EndIf
	Else
		aRetorno[2] := "Existe(m) campos no cadastro da filial matriz do TAF que não estão preenchidos e são obrigatórios para a correta conexão com o TSS, são eles: Nome Comercial, CNPJ ou CPF, Cidade Fiscal/Entrega, Estado Fiscal/Entrega, CEP Fiscal/Entrega e Código Municipio.  "
	EndIf

Return(aRetorno)

//---------------------------------------------------------------------
/*{Protheus.doc} VldDtCert

Verifica validade do certificado digital

@aParam lConTSS - Verifica se TSS foi conectado com sucesso

@Author	Ronaldo Tapia
@Since		11/04/2018
@Version	1.0

@Return aDataValid - Data validade dos certificados do TSS
*/
//---------------------------------------------------------------------
Static Function VldDtCert(lConTSS)
	Local aArea			:= GetArea()
	Local cURL      := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	Local oWS
	Local lRetorno  := .F.
	Local aDataValid:= {}
	Local nX
	Local cIdEnt 	:= ""

	Default lConTSS := .T.

	If lConTSS
		// Verifica código da entidade
		cIdEnt 	:= AllTrim(TAFRIdEnt(,,,,,.T.))

		//Verifica se o servidor da Totvs esta no ar
		oWs := WsSpedCfgNFe():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CFGCONNECT()
			lRetorno := .T.
		EndIf

		If lRetorno
			// Verifica os certificados
			If oWs:CFGStatusCertificate()
				If Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE) > 0
					For nX := 1 To Len(oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE)
						// Verifica a data de validade de todos os certificados
						aAdd(aDataValid,oWs:oWSCFGSTATUSCERTIFICATERESULT:OWSDIGITALCERTIFICATE[nx]:DVALIDTO)
					Next nX
				EndIf
			EndIf
		Else
			aAdd(aDataValid,"TSS não conectado")
		EndIf
	Else
		aAdd(aDataValid,"TSS não conectado")
	EndIf

	RestArea(aArea)
Return(aDataValid)

//---------------------------------------------------------------------
/*{Protheus.doc} VldVerTSS

Verifica versão do TSS

@aParam lConTSS - Verifica se TSS foi conectado com sucesso

@Author	Ronaldo Tapia
@Since		11/04/2018
@Version	1.0

@Return cVersao - Versão do TSS
*/
//---------------------------------------------------------------------
Static Function VldVerTSS(lConTSS)
	Local aArea			:= GetArea()
	Local cURL      := PadR(GetNewPar("MV_TAFSURL","http://"),250)
	Local oWS
	Local cIdEnt 	:= ""
	Local cVersao	:= ""
	Local lRetorno  := .F.

	Default lConTSS := .T.

	If lConTSS
		// Verifica código da entidade
		cIdEnt 	:= AllTrim(TAFRIdEnt(,,,,,.T.))

		//Verifica se o servidor da Totvs esta no ar
		oWs := WsSpedCfgNFe():New()
		oWs:cUserToken := "TOTVS"
		oWs:cID_ENT    := cIdEnt
		oWS:cVersao    := "0.00"
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"

		If oWs:CFGCONNECT()
			lRetorno := .T.
		EndIf

		If lRetorno
			// Verifica a versão
			//lOk := oWS:CFGVersao()
			//cVersao        := oWS:cCfgVersaoResult
			lOk := oWS:CFGTSSVERSAO()
			cVersao        := oWS:cCfgTSSVersaoResult
		Else
			cVersao:= "TSS não conectado"
		EndIf
	Else
		cVersao:= "TSS não conectado"
	EndIf

	RestArea(aArea)
Return(cVersao)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafTabValid
Verifica quais tabelas tem a chave forte e se o compartilhamento está igual da tabela PAI 
em todos os níveis

@aParam 
nOpc 1 - Integridade das Tabelas ; 2 - Relacionamento entre Tabelas
lExpRelTab - Define que função foi chamada pela rotina de exportação ZIP

@author    Ronaldo Tapia
@version   12.1.17
@since     06/04/2018
@protected

@return aRetFim
array com as divergencias encontrados ou todos os relacioamentos entre tabelas
*/
//------------------------------------------------------------------------------------------
Static Function TafTabValid( nOpc as Numeric, lExpRelTab as Logical)

	Local aArea       as Array
	Local aDependency as Array
	Local aDiferenca  as Array
	Local aEsocial    as Array
	Local aGetFunc    as Array
	Local aModel      as Array
	Local aRetFim     as Array
	Local aRetorno    as Array
	Local aRetTRot    as Array
	Local aTodos      as Array
	Local cBarra      as Character
	Local cExpRelac   as Character
	Local cMsg        as Character
	Local cPath       as Character
	Local cTpModel    as Character
	Local lFound      as Logical
	Local lImpTodos   as Logical
	Local lTabPai     as Logical
	Local na          as Numeric
	Local ni          as Numeric
	Local nj          as Numeric
	Local nPos        as Numeric
	Local nw          as Numeric
	Local nx          as Numeric
	Local ny          as Numeric
	
	Default lExpRelTab := .F.

	aArea       := GetArea()
	aDependency := {}
	aDiferenca  := {}
	aEsocial    := {}
	aGetFunc    := {}
	aModel      := {}
	aRetFim     := {}
	aRetorno    := {}
	aRetTRot    := {}
	aTodos      := {}
	cBarra      := If(issrvunix(), "/", "\")
	cExpRelac   := "relac_tabelas"
	cMsg        := ""
	cPath       := GetSrvProfString("StartPath", "") + If( Right( GetSrvProfString("StartPath",""), 1 ) == cBarra, "", cBarra )
	cTpModel    := type( 'oModel' )
	lFound      := .T.
	lImpTodos   := .T.
	lTabPai     := .T.

	// Verifico se o TAF esta atualizado
	If TafAtualizado(.F.) .And. TAFAlsInDic( "V1O" )

		// Relação  das roti n as x Tabel as do  TAF para o eSocial - Necessirio validar se as tabelas existem no dicionário de dados
		Aadd( aEsocial, { "TAFA050", "C1E", "C1F", "CR9", "CRM", "CUW", "CZR", "V81" 																				})
		Aadd( aEsocial, { "TAFA253", "C92", "T0Z"                                    																				})
		Aadd( aEsocial, { "TAFA232", "C8R", "T5N"                                    																				})
		Aadd( aEsocial, { "TAFA246", "C99", "T03"                                    																				})
		Aadd( aEsocial, { "TAFA235", "C8V", "T10", "T11"                             																				})
		Aadd( aEsocial, { "TAFA467", "T5K"                                           																				})
		Aadd( aEsocial, { "TAFA236", "C8X"                                           																				})
		Aadd( aEsocial, { "TAFA238", "C90", "CRL"                                    																				})
		Aadd( aEsocial, { "TAFA389", "T04", "T09"                                    																				})
		Aadd( aEsocial, { "TAFA051", "C1G", "T5L"                                    																				})
		Aadd( aEsocial, { "TAFA248", "C8W"                                           																				})
		Aadd( aEsocial, { "TAFA250", "C91", "T6W", "C9K", "C9L", "C9M", "C9N", "C9O", "C9P", "C9Q", "C9R", "CRN", "T14", "T6Y", "T6Z", "V6K", "V9K", "V1B", "V1C" 	})
		Aadd( aEsocial, { "TAFA413", "C91", "T6C", "T6D", "T6E", "T14", "T61", "T6H", "T6I", "T6J", "T6K", "V9L"													})
		Aadd( aEsocial, { "TAFA470", "T62", "T63", "T6O", "V6V", "V6W", "V6X", "V6Y", "V9M"																			})
		Aadd( aEsocial, { "TAFA407", "T3P", "T3Q", "T3R", "LE2", "LE3", "LE4", "T5V", "T5U", "T5Y", "T5Z", "T5X", "T6P", "T6Q", "T6R", "V7S", "V7T", "V7U", "V7V", "V7X", "V7W", "V7Y", "V7Z", "V8A", "V8B", "V8C", "V8D", "V8E", "V8F", "V8G", "V6M", "V9I", "V9J" })
		Aadd( aEsocial, { "TAFA272", "CMR", "CMT", "CMU", "T1Z", "V2O"             																					})
		Aadd( aEsocial, { "TAFA414", "T1M", "T1N", "T1O", "T1P", "T6B"             																					})
		Aadd( aEsocial, { "TAFA408", "T2A", "T1Y"             																										})
		Aadd( aEsocial, { "TAFA410", "T3V", "T3X"             																										})
		Aadd( aEsocial, { "TAFA477", "T72"              																											})
		Aadd( aEsocial, { "TAFA416", "T1S"              																											})
		Aadd( aEsocial, { "TAFA303", "CU0"              																											})
		Aadd( aEsocial, { "TAFA412", "T3Z", "T2L"             																										})
		Aadd( aEsocial, { "TAFA403", "T3A"             																												})
		Aadd( aEsocial, { "TAFA278", "C9V", "C9Y", "CUP", "CRQ", "T3L", "T80", "T90"             																	})
		Aadd( aEsocial, { "TAFA275", "T1U", "T3T"      																												})
		Aadd( aEsocial, { "TAFA276", "T1V", "T3U", "T79", "T91", "V91"      																						})
		Aadd( aEsocial, { "TAFA257", "CM0", "CM1", "CM2"																											})
		Aadd( aEsocial, { "TAFA258", "C8B", "C9W"																													})
		Aadd( aEsocial, { "TAFA261", "CM6", "T6M"																													})
		Aadd( aEsocial, { "TAFA587", "V72" 																															})
		Aadd( aEsocial, { "TAFA264", "CM9", "T3S", "T0Q", "CMA", "LEA", "CMB", "V3E"																				})
		Aadd( aEsocial, { "TAFA404", "T3B", "T3C", "T3D", "T3N", "T3O"																								})
		Aadd( aEsocial, { "TAFA263", "CM8" 																															})
		Aadd( aEsocial, { "TAFA267", "CMF" 																															})
		Aadd( aEsocial, { "TAFA266", "CMD", "T06" , "T3G" , "T05" , "T15" , "T16" , "T5I" , "T5J" , "T5Q" , "T5S" , "T88" , "C9J" , "T3H", "V1M", "V1N", "V6D" 		})		
		Aadd( aEsocial, { "TAFA279", "C9V", "T2F" , "CUU"																											})
		Aadd( aEsocial, { "TAFA277", "T0F"																															})
		Aadd( aEsocial, { "TAFA280", "T92", "C9J", "CMK", "T3I", "T3J", "T3H", "T15", "T16", "V9O"																	})
		Aadd( aEsocial, { "TAFA589", "V73", "V74"																													})
		Aadd( aEsocial, { "TAFA592", "V75" 																															})
		Aadd( aEsocial, { "TAFA593", "V76" 																															})
		Aadd( aEsocial, { "TAFA594", "V77" 																															})
		Aadd( aEsocial, { "TAFA595", "V78" 																															})
		Aadd( aEsocial, { "TAFA608", "V9U", "V9V", "V9W", "V9Y", "V9X", "V9Z", "V7A", "V7B", "V7H", "V7I", "V7Q"													})
		Aadd( aEsocial, { "TAFA609", "V7C", "V7D", "V7E", "V7F", "V7G", "V8K", "V8L", "V8M", "V8N", "V8O", "V8Q", "V8S", "V8X", "V8Y"								})
		Aadd( aEsocial, { "TAFA269", "CMJ" 																															})
		Aadd( aEsocial, { "TAFA610", "V7J" 																															})
		Aadd( aEsocial, { "TAFA423", "T2M", "T2N", "T2O", "T2P", "T2Q", "T2R", "T2S", "V5J", "V5K", "V6F", "V6G", "V6H", "V6I"										})
		Aadd( aEsocial, { "TAFA422", "T2G", "T2H", "T2I", "T2J", "V6J", "V7M", "V7N", "V8H", "V8J", "V8T", "V8V", "V60", "V61", "V62", "V64", "V63", "V65", "V66", "V67", "V68", "V69", "V6A", "V54", "V50", "V51", "V52", "V53" })
		Aadd( aEsocial, { "TAFA520", "V2P", "V2Q", "V2R", "V2S", "V2T", "V2U", "V2V", "V2W", "V2X", "V2Y", "V6L", "V6P", "V6Q"										})
		Aadd( aEsocial, { "TAFA425", "T2V", "T2X", "T70", "T2Y", "T2Z", "T0A", "T0B", "T0C", "T0D", "T0E", "V79"													})
		Aadd( aEsocial, { "TAFA426", "T0G", "T0H", "V9S"																											})
		Aadd( aEsocial, { "TAFA521", "V2Z", "V20", "V21", "V22", "V23", "V24", "V25", "V6N", "V6O" 																	})
		Aadd( aEsocial, { "TAFA611", "V7K", "V7L", "V7O", "V7P" 																									})

		// Carrega todas as rotinas e tabelas pais
		aRetTRot := TafRotinas()
		
		// Algumas funções vem duplicadas do TafRotinas(), sendo assim, não incluo as funções duplicadas
		For npos := 1 to Len(aRetTRot)

			If aScan( aGetFunc, {|x| x[1] == aRetTRot[npos][1] } ) == 0
				aAdd(aGetFunc,aRetTRot[npos])
			EndIf

		Next npos

		// Posiciono no SX2 para buscar o compartilhamento da tabela Pai
		dbSelectArea("SX2")
		SX2->(dbSetOrder(1))
		
		ProcRegua(Len(aGetFunc))

		// Busco as tabelas filhas através das dependencias
		For nx := 1 To Len(aGetFunc)
		
			If len(aGetFunc[nx]) <> Nil
		
				IncProc( "Verificando rotina: " + aGetFunc[nx][1]) //"Verificando rotina: "
				
				lFound := .T. // Variável de controle de busca
	
				// Procuro a mesma rotina no array aEsocial
				nPos := aScan( aEsocial, {|x| x[1] == aGetFunc[nx][1] } )

				If nPos > 0

					For ni := 2 to Len(aEsocial[nPos])

						If !TAFAlsInDic( aEsocial[nPos][ni] ) //Verifico se a tabela existe

							lFound := .F.

							If Select(aEsocial[nPos][ni])  > 0
								( aEsocial[nPos][ni])->(DbCloseArea())
							EndIf

						EndIf

					Next ni

				EndIf
				
				// Validação para remover as funções em MVC sem model declarado
				If aGetFunc[nx][1] == "TAFA420" .Or. aGetFunc[nx][1] == "TAFA421" .Or. aGetFunc[nx][1] == "TAFA496" .Or. aGetFunc[nx][1] == "TAFA493";
						.Or. aGetFunc[nx][1] == "TAFA497" .Or. aGetFunc[nx][1] == "TAFA588" .Or. aGetFunc[nx][1] == "TAFA591"

					lFound := .F.

				EndIf

				// Validação para remover as funções sem dicionário aplicado e não são impeditivas para utilização do TAF (Órgãos Públicos)
				If lFound .And. (aGetFunc[nx][1] == "TAFA587" .Or. aGetFunc[nx][1] == "TAFA589" .Or. aGetFunc[nx][1] == "TAFA590" .Or. aGetFunc[nx][1] == "TAFA592" .Or. aGetFunc[nx][1] == "TAFA593";
						.Or. aGetFunc[nx][1] == "TAFA594" .Or. aGetFunc[nx][1] == "TAFA595")

						lFound := TAFAlsInDic( aGetFunc[nx][3]  )

				EndIf

				// Se encontrei a tabela, carrego o model para buscar as dependencias
				If lFound .and. FindFunction( aGetFunc[nx][1] )
					
					oModel   := FWLoadModel( aGetFunc[nx][1] )

					If ValType(oModel) == "O"

						aModel   := oModel:GetDependency()
						aDependency := {}

						If Len(aModel) > 0

							For ny := 1 To Len(aModel[1][4])

								// Busco os compartilhamentos das tabelas filhas
								If SX2->(DBSeek(SubStr(aModel[1][4][ny][2],7,3)))
									aAdd(aDependency,{SubStr(aModel[1][4][ny][2],7,3),FWModeAccess(SubStr(aModel[1][4][ny][2],7,3),3),FWModeAccess(SubStr(aModel[1][4][ny][2],7,3),2),FWModeAccess(SubStr(aModel[1][4][ny][2],7,3),1)})
								EndIf

								If Len(aModel[1][4][ny][4]) > 0

									For na := 1 to Len(aModel[1][4][ny][4])

										If SX2->(DBSeek(SubStr(aModel[1][4][ny][4][na][2],7,3)))
											aAdd(aDependency,{SubStr(aModel[1][4][ny][4][na][2],7,3),FWModeAccess(SubStr(aModel[1][4][ny][4][na][2],7,3),3),FWModeAccess(SubStr(aModel[1][4][ny][4][na][2],7,3),2),FWModeAccess(SubStr(aModel[1][4][ny][4][na][2],7,3),1)})
										EndIf

									Next na

								EndIf

							Next ny

							// Posiciono na X2 para buscar o compartilhamento das tabelas
							If SX2->(DBSeek(SubStr(aModel[1][2],7,3)))
								aAdd(aRetorno,{{aGetFunc[nx][3],FwX2Nome(SubStr(aModel[1][2],7,3),3),FwModeAccess(SubStr(aModel[1][2],7,3),3),FwModeAccess(SubStr(aModel[1][2],7,3),2),FwModeAccess(SubStr(aModel[1][2],7,3),1)},aDependency})
							EndIf
						
							// Destruo o model
							If cTpModel <> 'U'
								oModel:Destroy()
							Endif
							
						EndIf

						freeobj(oModel)

					EndIf

				EndIf

			EndIf

		Next nx

		// Percorro todo o array aRetono validando a diferença nos compartilhamentos
		For nj := 1 to Len(aRetorno)

			lTabPai   := .T.
			lImpTodos := .T.

			For nw := 1 to Len(aRetorno[nj][2])

				If Len(aRetorno[nj][2]) > 0 .And. aRetorno[nj][1][3] + aRetorno[nj][1][4] + aRetorno[nj][1][5] <> aRetorno[nj][2][nw][2] + aRetorno[nj][2][nw][3] + aRetorno[nj][2][nw][4]
					
					If lTabPai

						// Adiciono as diferenças
						aAdd(aDiferenca,{aRetorno[nj][1][1] + " - " + Alltrim(aRetorno[nj][1][2]),aRetorno[nj][1][3], aRetorno[nj][1][4], aRetorno[nj][1][5]})
						
						If lImpTodos
							// Adiciono todos os registros
							aAdd(aTodos,{aRetorno[nj][1][1] + " - " + Alltrim(aRetorno[nj][1][2]),aRetorno[nj][1][3], aRetorno[nj][1][4], aRetorno[nj][1][5]})
						EndIf

						lTabPai := .F.

					EndIf

					aAdd(aDiferenca,{aRetorno[nj][2][nw][1],aRetorno[nj][2][nw][2], aRetorno[nj][2][nw][3], aRetorno[nj][2][nw][4]})

				ElseIf lImpTodos

					aAdd(aTodos,{aRetorno[nj][1][1] + " - " + Alltrim(aRetorno[nj][1][2]),aRetorno[nj][1][3], aRetorno[nj][1][4], aRetorno[nj][1][5]})
					lImpTodos := .F.

				EndIf

				If Len(aRetorno[nj][2]) > 0
					aAdd(aTodos,{aRetorno[nj][2][nw][1],aRetorno[nj][2][nw][2], aRetorno[nj][2][nw][3], aRetorno[nj][2][nw][4]})
				EndIf

			Next nw

		Next nj

		If !lExpRelTab

			If nOpc == 1

				If Len(aDiferenca) > 0

					// Monta tela com as divergências				
					oListEnd := TAFLisInfo( .T., {'Tabela','Empresa','Unidade de Negócio','Filial'}, aDiferenca, {100,35,60,25}, "Analise de Dados - Compartilhamento entre Tabelas", .T., .F. )
				
				ElseIf Len(aDiferenca) == 0 .And. Len(aTodos) > 0

					If MsgYesNo( "Relacionamento entre tabelas validados com sucesso, não foram encontradas divergências. Deseja visualizar todos os relacionamentos entre tabelas?", "Atenção" )
						// Monta tela com todos os relacionamentos
						oListEnd := TAFLisInfo( .T., {'Tabela','Empresa','Unidade de Negócio','Filial'}, aTodos, {100,35,60,25}, "Analise de Dados - Compartilhamento entre Tabelas", .T., .T.)
					EndIf

				EndIf

			ElseIf Len(aTodos) > 0

				// Monta tela com todos os relacionamentos
				oListEnd := TAFLisInfo( .T., {'Tabela','Empresa','Unidade de Negócio','Filial'}, aTodos, {100,35,60,25}, "Analise de Dados - Compartilhamento entre Tabelas", .T., .T.,)
			
			EndIf

		ElseIf Len(aDiferenca) > 0

			TafExpRelac(Nil,cExpRelac,cPath,aDiferenca,lExpRelTab)

		EndIf

	Else

		cMsg := "O ambiente do TAF encontra-se desatualizado. Para utilização desta funcionalidade, será necessário executar o compatibilizador de dicionário de dados UPDTAF."
		MsgInfo( cMsg, "Ambiente Desatualizado!" )

	EndIf

	// Defino qual o retorno da função (Mostrar só as diferenças ou todos os registros)
	If nOpc == 1
		aRetFim := aClone( aDiferenca )
	Else
		aRetFim := aClone( aTodos )
	EndIf

	RestArea(aArea)

Return(aRetFim)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafExpRelac
Exporta as diferenças no compartilhamento das tabelas

@Param	
oListBox  - Objeto da area de trabalho da tela
cNomeArq  - Nome do arquivo para gravação
cCaminho  - Diretório para gravação
aInfRelT  - Array com os dados
lExpRelT  - Define que foi chamada pela rotina de exportação ZIP 

@author    Ronaldo Tapia
@version   12.1.17
@since     06/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TafExpRelac(oListBox,cNomeArq,cCaminho,aInfRelT,lExpRelT)

	Local cTexto	:= ""
	Local nHandle	:= 0
	Local cFileTxt	:= ""
	Local lRetorno	:= .T.
	Local cFile		:= ""
	Local nx
	
	Default oListBox := Nil
	Default cNomeArq := ""
	Default cCaminho := ""
	Default aInfRelT := {}
	Default lExpRelT := .F.

	cCaminho := AllTrim(cCaminho)
	
	If oListBox <> Nil
		aInfRelT := oListBox:aArray
	EndIf

	If Empty(cNomeArq) .And. Empty(cCaminho)
		Aviso("GeraArquivo", "Parametros em Branco, verifique!", {"Ok"}) // "GeraArquivo" ## "Parametros em Branco, verifique!" ## "Ok"
		lRetorno := .F.
	EndIf

	If Len(aInfRelT) < 0
		lRetorno := .F.
	EndIf

	If lRetorno
		cTexto := "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF
		cTexto += "                         				TAF - Relacionamento entre Tabelas" // "                         TAF - Relacionamento entre Tabelas"
		cTexto += _CRLF
		cTexto += "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF + _CRLF

		cTexto += "Tabela                                                 Empresa     Unidade de Negocio     Filial"
		cTexto += _CRLF
		For nx := 1 To Len(aInfRelT)
			cTexto += OEMToANSI(PADR((aInfRelT[nx][1]),45)) + "            " + cValtoChar(aInfRelT[nx][2]) + "                 " + (aInfRelT[nx][3]) + "                " + (aInfRelT[nx][4])
			cTexto += _CRLF
		Next nx

		cFile    := Alltrim(cNomeArq) + ".txt"
		cFileTxt := cCaminho + cFile

		// Cria arquivo texto
		nHandle := MsFCreate(cFileTxt)

		If nHandle < 0
			Aviso("Geração de Arquivo Texto","Não foi possível criar o arquivo: " + cFile + "." + " Erro: " + IIf(cValToChar( FError() ) == "13", "Sem permissão de acesso ao diretório, verifique!",cValToChar( FError() )),{"Ok"},3) // "Geração de Arquivo Texto" ## "Não foi possível criar o arquivo: " ## "Erro: " ## "Ok"
		Else
			WrtStrTxt(nHandle,cTexto)
			If !lExpRelT
				Aviso("Geração de Arquivo Texto","Arquivo: " + cFile + " " + "gerado com sucesso no Diretório: " + Alltrim(cCaminho) + ".",{"Ok"},3) // "Geração de Arquivo Texto" ## "Arquivo: " ## "gerado com sucesso no Diretório: " ## "Ok"
			EndIf
		EndIf

		FClose(nHandle)
	EndIf

Return()

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafAplPat
Retorna o histórico de atualizações aplicadas no RPO

@Param	
lExpPatc  - Identifica que foi chamada pela rotina de exportação de fontes

@author    Ronaldo Tapia
@version   12.1.17
@since     16/04/2018
@protected

@Return aDados - Array com dados dos pacotes aplicados no RPO
*/
//------------------------------------------------------------------------------------------
Static Function TafAplPat(lExpPatc)

	Local aArea	:= GetArea()
	Local aData  := {}
	Local aDados := {}
	Local nx
	Local cBarra     := If(issrvunix(), "/", "\")
	Local cPath	     := GetSrvProfString("StartPath", "") + If( Right( GetSrvProfString("StartPath",""), 1 ) == cBarra, "", cBarra )
	Local cExpAtAmb := "atualiza_ambiente"
	
	Default lExpPatc := .F.
	
	// Proteção para macroexecutar a função GetRpoLog pois o Robo de compilação não possui a função
	If FindFunction("GetRpoLog")
		aData := &("GetRpoLog()")
	EndIf
	
	ProcRegua(Len(aData))

	If len(aData) > 2
		For nx := 3 To Len(aData)
			IncProc( "Verificando atualização: " + aData[nx][1]) //"Verificando atualização: "
			aAdd(aDados,{cValtoChar(aData[nx][1]),cValtoChar(aData[nx][2]),cValtoChar(aData[nx][4]),cValtoChar(aData[nx][6]),aData[nx]})
		Next nx
	EndIf
	
	// Monta tela para exibir os dados dos fontes
	If !lExpPatc
		If Len(aDados) > 0
			oListEnd := TAFLisInfo( .T., {'Nome do patch','Data de geração do patch','Data de aplicação do patch','Número de programas'}, aDados, {75,75,75,75}, "Analise de Dados - Histórico de Atualizações", .F., .F. , .T.)
		Else
			MsgInfo("Não foram aplicadas patchs neste ambiente!")
		EndIf
	Else
		TAFExpPatc(Nil,cExpAtAmb,cPath,aDados,lExpPatc)
	EndIf

	RestArea(aArea)

Return (aDados)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TAFExpPatc
Exporta o histórico de atualizações

@Param	
oListBox  - Objeto da area de trabalho da tela
cNomeArq  - Nome do arquivo para gravação
cCaminho  - Diretório para gravação
aInfPatc  - Array com os dados
lExpPatc  - Define se a rotina foi chamada pela rotina de exportação ZIP

@author    Ronaldo Tapia
@version   12.1.17
@since     16/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TAFExpPatc(oListBox,cNomeArq,cCaminho,aInfPatc,lExpPatc)

	Local cTexto	:= ""
	Local aTexto	:= {}
	Local nHandle	:= 0
	Local cFileTxt	:= ""
	Local lRetorno	:= .T.
	Local cFile		:= ""
	Local nx
	Local ny

	Default oListBox := Nil
	Default cNomeArq := ""
	Default cCaminho := ""
	Default aInfPatc := {}
	Default lExpPatc := .F.

	cCaminho := AllTrim(cCaminho)
	
	If oListBox <> Nil
		aInfPatc := oListBox:aArray
	EndIf

	If Empty(cNomeArq) .And. Empty(cCaminho)
		Aviso("GeraArquivo", "Parametros em Branco, verifique!", {"Ok"}) // "GeraArquivo" ## "Parametros em Branco, verifique!" ## "Ok"
		lRetorno := .F.
	EndIf

	If lRetorno

		cTexto := "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF
		cTexto += "                         				RPO - Histórico de Atualizações" // "                         RPO - Histórico de Atualizações"
		cTexto += _CRLF
		cTexto += "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF + _CRLF

		cTexto += "Quantidade de paths aplicados: " + cValtoChar(Len(aInfPatc))
		cTexto += _CRLF + _CRLF
		For nx := 1 To Len(aInfPatc)
			cTexto += "Nome do patch                 Data de geração do patch         Data de aplicação do patch          Número de programas"
			cTexto += _CRLF
			cTexto += aInfPatc[nx][1] + "                  " + aInfPatc[nx][2] + "                       " + aInfPatc[nx][3] + "                          " + aInfPatc[nx][4]
			cTexto += _CRLF + _CRLF
			cTexto += "Fonte                          Data"
			cTexto += _CRLF
			For ny := 7 to Len(aInfPatc[nx][5])
				If ValType(aInfPatc[nx][5][ny]) == "A"
					cTexto += PADR(aInfPatc[nx][5][ny][1],20) + "             " + cValtoChar(aInfPatc[nx][5][ny][2])
					cTexto += _CRLF
				EndIf
			Next ny
			cTexto += _CRLF + _CRLF
			aAdd(aTexto, cTexto)
			cTexto := ""
		Next nx

		cFile    := Alltrim(cNomeArq) + ".txt"
		cFileTxt := cCaminho + cFile

		// Cria arquivo texto
		nHandle := MsFCreate(cFileTxt)

		If nHandle < 0
			Aviso("Geração de Arquivo Texto","Não foi possível criar o arquivo: " + cFile + "." + " Erro: " + IIf(cValToChar( FError() ) == "13", "Sem permissão de acesso ao diretório, verifique!",cValToChar( FError() )),{"Ok"},3) // "Geração de Arquivo Texto" ## "Não foi possível criar o arquivo: " ## "Erro: " ## "Ok"
		Else
			For nX := 1 to Len(aTexto)
				WrtStrTxt(nHandle, aTexto[nX])
			Next nX
			If !lExpPatc
				Aviso("Geração de Arquivo Texto","Arquivo: " + cFile + " " + "gerado com sucesso no Diretório: " + Alltrim(cCaminho) + ".",{"Ok"},3) // "Geração de Arquivo Texto" ## "Arquivo: " ## "gerado com sucesso no Diretório: " ## "Ok"
			EndIf
		EndIf

		FClose(nHandle)
	EndIf

Return()

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TAFGerZIP
Exporta todas as informações da tela para um arquivo ZIP

@author    Ronaldo Tapia
@version   12.1.17
@since     17/04/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TAFGerZIP(oListBox,cNome,cCaminho)

	Local cTexto	:= ""
	Local nHandle	:= 0
	Local cFileTxt	:= ""
	Local ni		:= 0
	Local nx		:= 0
	Local cBarra    := If(issrvunix(), "/", "\")
	Local cRootPatch:= GetSrvProfString("RootPath", "") + If( Right( GetSrvProfString("RootPath",""), 1 ) == cBarra, "", cBarra )
	Local cPath	    := GetSrvProfString("StartPath", "") + If( Right( GetSrvProfString("StartPath",""), 1 ) == cBarra, "", cBarra )
	Local cRemotePath := GetRemoteIniName()
	Local nAt 	 	:= At(cBarra+'BIN',Upper(cRemotePath))
	Local cNomeArq	:= "diagnostico_taf.txt"
	Local aURLTSS	:= {}
	Local aValCert  := {}
	Local cVerTSS	:= ""
	Local aRetAtu	:= {}
	Local cEndWbs   := ""
	Local lExisWbs  := .F.
	Local xPort     := 0
	Local cVerESoc	:= ""
	Local cAutoCon	:= GetMV("MV_VAUTCON")
	Local aInfDbTa  := VldDbATAF()
	Local aInfDbWs  := VldDbAWS()
	Local lTopMemo	:= VldMemoMega()
	Local aDifer_Fil:= {}
	Local aAtuAmbi  := {}
	Local aArquivos	:= {}
	Local nRet		:= 0
	Local cDirFile	:= Alltrim(cNome)+".zip"
	Local lRetorno	:= .T.
	Local cAutoRec	:= ""
	Local aWebApp   := ""
	Local aRetTSS   := {}
	Local bOk
	
	Default oListBox := Nil
	Default cNome    := ""
	Default cCaminho := ""
	
	cCaminho := AllTrim(cCaminho)
		
	If Empty(cNome) .And. Empty(cCaminho)
		Aviso("GeraArquivo", "Parametros em Branco, verifique!", {"Ok"}) // "GeraArquivo" ## "Parametros em Branco, verifique!" ## "Ok"
		lRetorno := .F.
	EndIf
	
	If lRetorno
		cTexto := "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF
		cTexto += "                         				TAF - Diagnóstico de Ambiente" // "                         TAF - Diagnóstico de Ambiente"
		cTexto += _CRLF
		cTexto += "----------------------------------------------------------------------------------------------------------------------"
		cTexto += _CRLF + _CRLF
	
		IncProc("Gravando informações do ambiente") //"Gravando informações do ambiente"

		/********************************************************************/
		cTexto += "   Informações da Release corrente no ambiente do TAF"
		cTexto += _CRLF
		cTexto += "------------------------------------------------------------"
		/********************************************************************/
		cTexto += _CRLF
		cTexto += "Versão do Dicionário de Dados do TAF: " + VldDicion()
		cTexto += _CRLF
		cTexto += "Versão do Repositório de fontes do TAF: " + VldRPO()
		cTexto += _CRLF
		cTexto += "Versão do Framework: Release "+ GetRpoRelease()

		cTexto += _CRLF + _CRLF + _CRLF
		/********************************************************************/
		cTexto += "   Informações da última atualização realizada no ambiente do TAF"
		cTexto += _CRLF
		cTexto += "------------------------------------------------------------"
		/********************************************************************/
		cTexto += _CRLF
		If FindFunction( "EngRefTaf" )

			aRetAtu := EngRefTaf()
			
			cTexto += "Release: " + aRetAtu[1]
			cTexto += _CRLF
			cTexto += "Data: " + DToC( aRetAtu[3])
			cTexto += _CRLF
			cTexto += "Este ambiente possui todas as correções liberadas no TAF até o dia: " + DToC( aRetAtu[2] )
		
		Else
			cTexto += "Ambiente Desatualizado"
		EndIf

		cTexto += _CRLF + _CRLF + _CRLF
		/********************************************************************/
		cTexto += "   Informações do WebService(Integração do ERP com o TAF)"
		cTexto += _CRLF
		cTexto += "------------------------------------------------------------"
		/********************************************************************/
		cTexto += _CRLF
		cEndWbs := alltrim( VldWS())
		If !Empty( cEndWbs )
			xPort := Substr( SubStr( cEndWbs, 6, Len(cEndWbs) ), AT( ":", SubStr( cEndWbs, 6, Len(cEndWbs) ) ) + 1, 4 )
			If IsNumeric( xPort )
				lExisWbs := !Empty( SubStr( cEndWbs, AT( ":", SubStr( cEndWbs, 6, Len(cEndWbs) ) ) + 6, Len( cEndWbs ) )  )
				If lExisWbs
					cTexto += "Web Service Configurado corretamente para integração com o ERP"
					cTexto += _CRLF
					cTexto += "Endereço do WS:" + cEndWbs
					cTexto += _CRLF
					If lRetorno
						cTexto += "Status do Serviço: Em execução"
					Else
						cTexto += "Status do Serviço: Parado"
					EndIf
				Else
					cTexto += "Web Service não Encontrado - O serviço pode estar em outro ip e porta diferentes da instalação padrão"
				EndIf
			Else
				cTexto += "Porta do Web Service não encontrada no appserver.ini, verifique a seção [HTTPREST]"
			EndIf
		Else
			cTexto += "Web Service não Encontrado/Configurado para integração com o ERP"
		EndIf
	
		cTexto += _CRLF + _CRLF + _CRLF
		/********************************************************************/
		cTexto += "   Informações do TSS"
		cTexto += _CRLF
		cTexto += "------------------------------------------------------------"
		/********************************************************************/
		cTexto += _CRLF
		
		aRetTSS := VldConTSS()
		If aRetTSS[1]
			cTexto += "Status TSS: Conectado"
			cTexto += _CRLF
		Else
			cTexto += "Status TSS: Não Conectado"
			cTexto += _CRLF
		EndIf
			
		aURLTSS := VldURLTSS()
		Iif( len(aURLTSS) > 0, cTexto += "URL de configuração do TSS: " + aURLTSS[1][2], cTexto += "URL de configuração do TSS não configurada" )
		cTexto += _CRLF
			
		aValCert := VldDtCert(aRetTSS[1])
		If len(aValCert) >= 3
			For ni := 1 to Len(aValCert[3])
				cTexto += "Validade do certificado digital: " + cValToChar(aValCert[3][1])
				cTexto += _CRLF
			Next ni
		Else
			cTexto += "Validade do certificado digital: Certificado digital não encontrado no TSS. Utilize a Wizard de comunicação do TAF com o TSS para o envio do certificado digital"
			cTexto += _CRLF
		EndIf
	
		If aRetTSS[1]
			cVerTSS := VldVerTSS(aRetTSS[1])
			cTexto += "Versão do TSS: " + cVerTSS
		Else
			cTexto += "Status TSS: Não Conectado"
			cTexto += _CRLF
		EndIf
		
		If !Empty( aRetTSS[2] )
			cTexto += "Existe(m) campos no cadastro da filial matriz do TAF que não estão preenchidos e são obrigatórios para a correta conexão com o TSS,"
			cTexto += _CRLF
			cTexto += "são eles: Nome Comercial, CNPJ ou CPF, Cidade Fiscal/Entrega, Estado Fiscal/Entrega, CEP Fiscal/Entrega e Códogp do Município."
		EndIf
			
		cTexto += _CRLF + _CRLF + _CRLF
		/********************************************************************/
		cTexto += "Resultado da análise do ambiente"
		cTexto += _CRLF
		cTexto += "------------------------------------------------------------"
		/********************************************************************/
		cTexto += _CRLF
	
		cVerESoc := VldLayeSo()
		cTexto += "Versão do layout do e-Social na base TAF: " + cVerESoc
		cTexto += _CRLF
	
		cTexto += "Tabelas Auto-Contidas: " + cValtoChar(cAutoCon)
		cTexto += _CRLF
	
		cTexto += "Totvs Application Server: " + GetBuild()
		cTexto += _CRLF
	
		Iif( !Empty( aInfDbTa[1,1] ), cTexto += "Totvs DbAccess - TAF: Configurado no IP: " + Alltrim(aInfDbTa[1,1]) + " - Porta: " + Alltrim(aInfDbTa[1,2]),"Não localizado")
		cTexto += _CRLF
	
		Iif( !Empty( aInfDbWs[1,1] ), cTexto += "Totvs DbAccess - WS: Configurado no IP: " + Alltrim(aInfDbWs[1,1]) + " - Porta: " + Alltrim(aInfDbWs[1,2]),"Não localizado")
		cTexto += _CRLF
				
		If FindFunction( "FWLibVersion" ) //Disponével somente a partir da label 20151008
			cData := FWLibVersion()
			cTexto += "LIB:" + cData
		Else
		//Verifica data de um fonte da LIB que foi alterado na release 12.1.005
			cData := DToS( GetAPOInfo( "PROTHEUSFUNCTIONMVC.PRX" )[4] )
			cTexto += "LIB:" + cData
		EndIf
		cTexto += _CRLF
	
		If lTopMemo
			cTexto += "TopMemoMega Habilitado"
		Else
			cTexto += "TopMemoMega Desabilitado"
		EndIf
		
		cTexto += _CRLF
		Iif( Empty( cAutoRec := VldAutoRec() ), cTexto += "Auto Recno: Não se Aplica", cTexto += "Auto Recno: " + cAutoRec)
		
		cTexto += _CRLF
		aWebApp := VldWebApp()
		Iif( !Empty( aWebApp[1] ), cTexto +="WebApp Configurado no IP: " + retServerIP() + " - Porta:" + aWebApp[1], cTexto += "Configuração não encontrada"  )
	
		IncProc("Gravando dados dos fontes") //"Gravando dados dos fontes"
	
	// Cria arquivo com diagnóstico dos Fontes
		TafListaFontes(.T.)
		If File(cRootPatch + 'system' + cBarra + "fontes.txt")
			aAdd(aArquivos,cPath+"fontes.txt")
		EndIf	
	
	// Cria arquivo caso haja divergências entre campos de _FILIAL
		aDifer_Fil := TafCheckFil(.T.)
		If Len(aDifer_Fil) == 0
			cTexto += _CRLF + _CRLF + _CRLF
			cTexto += "Resultado da análise dos campos _FILIAL"
			cTexto += _CRLF
			cTexto += "------------------------------------------------------------"
			cTexto += _CRLF
			cTexto += "Não foram encontradas diferenças de tamanho dos campos de Filial"
		Else
			If File(cRootPatch + 'system' + cBarra + "dif_filial.txt")
				aAdd(aArquivos,cPath+"dif_filial.txt")		
			EndIf	
		EndIf
	
	// Cria arquivo caso haja divergências entre compartilhamentos de tabelas
	// Verifico se o TAF esta atualizado
		If TafAtualizado(.F.) .And. TAFAlsInDic( "V1O" )
			TafTabValid(1,.T.)
			If File(cRootPatch + 'system' + cBarra + "relac_tabelas.txt")
				aAdd(aArquivos,cPath+"relac_tabelas.txt")
			EndIf
		Else
			cTexto += _CRLF + _CRLF + _CRLF
			cTexto += "Resultado da análise dos relacionamentos entre tabelas do TAF"
			cTexto += _CRLF
			cTexto += "------------------------------------------------------------"
			cTexto += _CRLF
			cTexto += "Não foi possível avaliar, uma vez que, o ambiente encontra-se desatualizado"
		EndIf
	
		aAtuAmbi := TafAplPat(.T.)
		If Len(aAtuAmbi) == 0
			cTexto += _CRLF + _CRLF + _CRLF
			cTexto += "Resultado da análise do histórico do RPO"
			cTexto += _CRLF
			cTexto += "------------------------------------------------------------"
			cTexto += _CRLF
			cTexto += "Não foram aplicados patchs neste ambiente"
		Else
			If File(cRootPatch + 'system' + cBarra + "atualiza_ambiente.txt")
				aAdd(aArquivos,cPath+"atualiza_ambiente.txt")
			EndIf
		EndIf
		cTexto += _CRLF + _CRLF + _CRLF
		
		// Copia o console.log se estiver configurado na pasta padrão de instalação
		If !Empty( cRemotePath )
			cTafAppServer :=  Substr(cRemotePath,1,nAt) + 'bin'+cBarra+'appserver'+cBarra
			cWsAppServer :=  Substr(cRemotePath,1,nAt) + 'bin'+cBarra+'app'+cBarra
			
			If File( cTafAppServer + "console.log" )
				__CopyFile( cTafAppServer + "console.log", cPath + "consoletaf.log" )
				If File(cRootPatch + 'system' + cBarra + "consoletaf.log")
					aAdd(aArquivos,cPath+"consoletaf.log")
				EndIf
			Else
				cTexto += "Console.log do TAF não encontrado no diretório padrão de instalação"
				cTexto += _CRLF
			EndIf
		
			If File( cWsAppServer + "console.log" )
				__CopyFile( cWsAppServer + "console.log", cPath + "consolews.log" )
				If File(cRootPatch + 'system' + cBarra + "consolews.log")
					aAdd(aArquivos,cPath+"consolews.log")
				EndIf
			Else
				cTexto += "Console.log do WS não encontrado no diretório padrão de instalação"
				cTexto += _CRLF
			EndIf
		Else
			cTexto += "Console.log"
			cTexto += _CRLF
			cTexto += "------------------------------------------------------------"
			cTexto += "Console.log não copiado pois o caminho não foi encontrado"
		EndIf
		
		IncProc("Finalizando geração do arquivo") //"Finalizando geração do arquivo"
	
	// Cria arquivo texto
		cFileTxt := cPath + cNomeArq
		nHandle := MsFCreate(cFileTxt)

		If nHandle < 0
			Aviso("Geração de Arquivo Texto","Não foi possível criar o arquivo: " + cNomeArq + "." + " Erro: " + IIf(cValToChar( FError() ) == "13", "Sem permissão de acesso ao diretório, verifique!",cValToChar( FError() )),{"Ok"},3) // "Geração de Arquivo Texto" ## "Não foi possível criar o arquivo: " ## "Erro: " ## "Ok"
		Else
			WrtStrTxt(nHandle,cTexto)
			aAdd(aArquivos,cPath+cNomeArq)	
		EndIf

		FClose(nHandle)
	
	// Gera arquivo ZIP
		nRet := &("FZip(cPath+cDirFile,aArquivos,cPath)")

	// Move o arquivo para o diretório especificado pelo usuário
		__CopyFile( cPath+cDirFile, cCaminho + '\' + cDirFile  )
		
		bOk := File(cCaminho + '\' +cDirFile )

		If nRet!=0 .Or. !bOk
			MsgStop("Não foi possível criar o arquivo zip. Verifique permissões de usuário no diretório escolhido!")
		Else
			Aviso("Geração de Arquivo ZIP","Arquivo: " + cDirFile + " " + "gerado com sucesso no Diretório: " + cCaminho + ".",{"Ok"},3) // "Geração de Arquivo Texto" ## "Arquivo: " ## "gerado com sucesso no Diretório: " ## "Ok"
		EndIf
		
		// Apaga arquivos
		For nx := 1 to Len(aArquivos)
			If File(aArquivos[nx])
				FERASE(aArquivos[nx])
			EndIf
		Next nx
		If File(cDirFile)
			FERASE(cDirFile)
		EndIf
	EndIf

Return()

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafTabLog
Copia tabela de log de alteração manual de protocolo (campo _PROTUL)

@Param	
cNomeArq  - Nome do arquivo para gravação
cCaminho  - Diretório para gravação

@author    Ronaldo Tapia
@version   12.1.17
@since     10/05/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TafTabLog(cNomeArq,cCaminho)

	Local lRetorno  := .T.
	Local cBarra    := If(issrvunix(), "/", "\")
	Local cPath	    := GetSrvProfString("StartPath", "") + If( Right( GetSrvProfString("StartPath",""), 1 ) == cBarra, "", cBarra )
	Local cArquivo  :=  "Log_PROTUL" + GetdbExtension()
	Local cArqZip   := Alltrim(cNomeArq)+".zip"
	Local cFile     := cPath + cArquivo
	Local aZip		:= {}
	Local bOk

	Default cNomeArq := ""
	Default cCaminho := ""

	cCaminho := AllTrim(cCaminho)

	If Empty(cNomeArq) .And. Empty(cCaminho)
		Aviso("GeraArquivo", "Parametros em Branco, verifique!", {"Ok"}) // "GeraArquivo" ## "Parametros em Branco, verifique!" ## "Ok"
		lRetorno := .F.
	EndIf
	
	If lRetorno
		// Apago arquivo caso já exista
		If File(cFile)
			If FERASE(cFile) == -1
				MsgStop('Falha na deleção do Arquivo ( FError'+str(ferror(),4)+             ') ' + cFile)
				Return .T.
			EndIf
		EndIf
	
		dbSelectArea("V1V")
		V1V->(dbSetOrder(1))
		V1V->(dbGoTop())

		// Copio os registros
		COPY TO &cArquivo delimited
		
		// Gera arquivo ZIP
		aAdd(aZip,cPath+cArquivo)
		nRet := &("FZip(cPath+cArqZip,aZip,cPath,'Totvs@85347')")

		// Move o arquivo para o diretório especificado pelo usuário
		__CopyFile( cPath+cArqZip, cCaminho + '\' +cArqZip )
		bOk := File(cCaminho + '\' +cArqZip )
	
		If !bOk
			MsgStop("Não foi possível criar o arquivo zip. Verifique permissões de usuário no diretório escolhido!")
		Else
			Aviso("Tabela de LOG","Arquivo gerado com sucesso no Diretório: " + cCaminho + ".",{"Ok"},3) // "Arquivo gerado com sucesso no Diretório: " ## "Ok"
		EndIf
	EndIf
	
	// Apaga arquivos do cPath
	If File(cArquivo)
		FERASE(cArquivo)
	EndIf
	If File(cArqZip)
		FERASE(cArqZip)
	EndIf

Return

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TfCheckIdDup
Verifica a existencia de registros com o numerador (Id) duplicado.

@author    Evandro dos Santos Oliveira 
@version   1.0
@since     01/08/2018
@protected

@Return ( Nil )
*/
//------------------------------------------------------------------------------------------
Static Function TfCheckIdDup()
	Local aArea	:= GetArea()
	Local cOut := ""
	Local cDir := ""
	Local cPathFile := ""
	Local cNameFile := ""
	Local cLastFil := ""
	Local cLastId := ""
	Local cFil := ""
	Local cId := ""
	Local cVersao := ""
	Local cSpecialKey := ""
	Local cLogOpe := ""
	Local cNomEve := ""
	Local nX := 0
	Local nY := 0
	Local aIdsDuplicados := {}
	Local aRet := {}
	Local nTamFilial := FWSizeFilial() + 10
	Local nTamId := 50
	Local nTamData := 20
	Local nTamQtd := 20
	Local nTamLog := 15
	Local nTamNmEvt := 15
	Local nQtd := 0

	aIdsDuplicados := TafListIdDup() 

	cOut := "Análise de Ids duplicados."
	cOut += CRLF 
	cNameFile := "diagIds_grupo_empresa_" + AllTrim(SM0->M0_CODIGO) + ".txt"
	
	For nX := 1 To Len(aIdsDuplicados)

		cOut += CRLF 
		cOut += "Tabela: " + aIdsDuplicados[nX][1] + " - " + FWX2Nome(aIdsDuplicados[nX][1])
		cOut += CRLF 
		cOut += Replicate("-",nTamFilial+nTamId+nTamData+nTamQtd+nTamLog+nTamNmEvt)
		cOut += CRLF

		cOut += formatStr("Filial",nTamFilial)
		cOut += formatStr("Id",nTamId)
		cOut += formatStr("Quantidade",nTamQtd,1)
		cOut += formatStr("Data de Inclusão",nTamData,1)
		cOut += formatStr("Log de Operação",nTamLog,1)

		If aIdsDuplicados[nX][1] == "C9V"
			cOut += formatStr("Nome Evento",nTamNmEvt,1)
		EndIf 

		cOut += CRLF
		cOut += Replicate("-",nTamFilial+nTamId+nTamData+nTamQtd+nTamLog+nTamNmEvt)
		cOut += CRLF


		For nY := 1 To Len(aIdsDuplicados[nX][2])

			cFil 	:= aIdsDuplicados[nX][2][nY][1]
			cId  	:= aIdsDuplicados[nX][2][nY][2]
			nQtd 	:= aIdsDuplicados[nX][2][nY][3]
			cVersao := aIdsDuplicados[nX][2][nY][4]
			cLogOpe := aIdsDuplicados[nX][2][nY][5]
			cNomEve := aIdsDuplicados[nX][2][nY][6]

			If !(cLastFil == cFil .And. cLastId == cId)
			
				cOut += CRLF
				cOut += formatStr(cFil,nTamFilial)
				cOut += formatStr(cId,nTamId)
				cOut += formatStr(cValToChar(nQtd),nTamQtd,1)
				cLastFil := cFil
				cLastId := cId
			Else

				cOut += formatStr(cFil,nTamFilial)
				cOut += formatStr(cId,nTamId)
				cOut += formatStr("",nTamQtd)
			EndIf 

			cOut += formatStr(versionToDate(cVersao),nTamData,1)
			cOut += formatStr(cLogOpe,nTamLog,1)

			If aIdsDuplicados[nX][1] == "C9V"
				cOut += formatStr(cNomEve,nTamNmEvt,1)
			EndIf 

			cOut += CRLF + CRLF 
		Next nY 
	Next nX 

	If Len(aIdsDuplicados) == 0
		cOut += "Não há ocorrências de Ids Duplicados nos eventos cadastrais para o grupo de empresas" + AllTrim(SM0->M0_CODIGO) + "."
	EndIf 

	cOut += CRLF
	cOut += "Informações do Ambiente: " + CRLF 
	cOut += "Ambiente: " + GetEnvServer() + CRLF 

	If FindFunction("EngRefTaf")
		aRet := EngRefTaf()
		cOut += "Release: " + aRet[1] + CRLF 
		cOut += "Data: " 	+ DToC(aRet[3]) + CRLF 
		cOut += "Este ambiente possui todas as correções liberadas no TAF até o dia: " + DToC( aRet[2] )+ CRLF 
	Endif

	cSpecialKey := getPvProfString(GetEnvServer(),'SpecialKey','',getAdv97())

	If Empty(cSpecialKey)
		cOut += "Não há configuração da chave SpecialKey. "
	Else
		cOut += "SpecialKey: " + cSpecialKey
	EndIf 

	cDir := cGetFile( "Diretorio|*.*", OemToAnsi( "Selecione um diretorio para gravação do arquivo." ), 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )

	cPathFile := cDir + cNameFile

	MemoWrite(cPathFile,cOut)

	MsgInfo("Processo Finalizado. Envie o arquivo " + cNameFile + " gerado em " + cDir + " para o suporte Totvs.","TAFDIAG")
	
	RestArea(aArea)
 Return Nil 

//------------------------------------------------------------------------------------------
/* {Protheus.doc} formatStr
Realiza a formatação dos campos de acordo com o alinhamento e tamanho especificados.

@author    Evandro dos Santos Oliveira 
@version   1.0
@since     01/08/2018

@param cString 	- Texto a ser formatado
@param nTamanho - Tamanho da coluna que será inserido o texto
@param nAlign 	- nAling - Alinhamento do texto (0-esquerda,1-cento,2-direita)

@return cData - Data no formato dd/mm/aa

*/
//------------------------------------------------------------------------------------------
 Static Function formatStr(cString,nTamanho,nAlign)

	Default nAlign := 0

	Do Case 
		Case nAlign == 0 // Esquerda
			cString := PADR(cString,nTamanho)
		Case nAlign == 1 // Centro
			cString := PADC(cString,nTamanho)
		Case nAlign == 2 // Direita
			cString := PADL(cString,nTamanho)
	End Case 

 Return cString

//------------------------------------------------------------------------------------------
/* {Protheus.doc} versionToDate
Extrai a data contida no código de versão 

@author    Evandro dos Santos Oliveira 
@version   1.0
@since     01/08/2018

@param cVersao - Informação do campo Versão

@return cData - Data no formato dd/mm/aa

*/
//------------------------------------------------------------------------------------------
 Static Function versionToDate(cVersao)

	Local cData := ""
	Local cAno := ""
	Local cAnoDataBase := ""

	cAnoDataBase := Substr(DTOS(dDataBase),3,2)

	If Substr(cVersao,5,2) == "20" .And. cAnoDataBase != "20"
		cData := Substr(cVersao,1,8)
		cAno  := Substr(cData,7,2) 
	Else
		cData := Substr(cVersao,1,6)
		cAno  := Substr(cData,5,2) 
	EndIf 

	cData := Substr(cData,1,2) + "/" + Substr(cData,3,2) + "/" + cAno

 Return (cData)

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafGetIdDup
Retorna Array Multidimensional com os eventos que possuem Ids duplicados na base de dados

@author    Evandro dos Santos Oliveira 
@version   1.0
@since     01/08/2018
@protected

@Return aIdsDuplicados - Array de Itens com Ids duplicados
[n][1] - Alias do Evento
[n][2] - Array com Ids+Filiais Duplicados
[n][2][y][1] - Filial
[n][2][y][2] - Id Duplicado
[n][2][y][3] - Quantidade de Ids Duplicados para o Item
[n][3] - Tipo do Evento (C-carga, M-Mensal, E-Eventual etc..)

*/
//------------------------------------------------------------------------------------------
 Function TafGetIdDup(cParamTpEvt)
 
	Local aRotinas := {}
	Local aIdsDuplicados := {}
	Local cLayoutEvento := ""
	Local cTipoEvento := ""
	Local cAliasEvento := ""
	Local nX := 0

	Default cParamTpEvt := "|C|M|E|T|"

 	aRotinas := TAFRotinas(,,.T.,2)

	For nX := 1 To Len(aRotinas)

		cLayoutEvento := aRotinas[nX][4]
		cAliasEvento := aRotinas[nX][3]
		cTipoEvento := AllTrim(aRotinas[nX][12])

		//Incluo o S-2200 como evento de carga por que é utilizado em consultas padroes de outros eventos
		If cTipoEvento $ cParamTpEvt .And. cAliasEvento != "C1E" .Or. (cParamTpEvt == "C" .And. cLayoutEvento == "S-2200" .And. cAliasEvento != "C1E")

			If (cLayoutEvento != "S-2300" .And. cLayoutEvento != "TAUTO") .And. !Empty(AllTrim(cLayoutEvento))

				cSql := " SELECT COUNT(*) QTD , " + cAliasEvento + "_FILIAL FILIAL, " + cAliasEvento + "_ID ID "
				cSql += " FROM " + RetSqlName(cAliasEvento)
				cSql += " WHERE D_E_L_E_T_ = ' ' "
				cSql += " AND " + cAliasEvento + "_ATIVO = '1' "

				cSql += " GROUP BY " + cAliasEvento + "_FILIAL, " + cAliasEvento + "_ID "
				cSql += " HAVING Count(*) > 1 "

				TCQuery cSql New Alias 'rsEvento'

				While rsEvento->(!Eof())

					If !(cAliasEvento $ "T1V|T1U|T0F|CM6")
						If Len(aIdsDuplicados) == 0 
							aAdd(aIdsDuplicados,{cAliasEvento,{{AllTrim(rsEvento->FILIAL),AllTrim(rsEvento->ID),rsEvento->QTD}},cTipoEvento})
						Else
							nPosLayout := aScan(aIdsDuplicados,{|alias|alias[1] == cAliasEvento})

							If nPosLayout > 0
								aAdd(aIdsDuplicados[nPosLayout][2],{AllTrim(rsEvento->FILIAL),AllTrim(rsEvento->ID),rsEvento->QTD})
							Else
								aAdd(aIdsDuplicados,{cAliasEvento;
													,{{AllTrim(rsEvento->FILIAL),AllTrim(rsEvento->ID),rsEvento->QTD}};
													,cTipoEvento})
							EndIf 
						EndIf 
					EndIf

					rsEvento->(dbSkip())
				EndDo
				rsEvento->(dbCloseArea())
			EndIf 
        EndIf 
	Next nX

 Return (aIdsDuplicados) 

//------------------------------------------------------------------------------------------
/* {Protheus.doc} TafListIdDup
Retorna Array Multidimensional com os registros que possuem Ids duplicados na base de dados
(somente eventos de cadastro)
obs: A diferente desta função para TafGetIdDup é que o retorno são incluidos todos os ids
individualmente, na TafGetIdDup é realizado um agrupamento por filial+id.

@author    Evandro dos Santos Oliveira 
@version   1.0
@since     16/01/2019
@protected

@Return aIdsDuplicados - Array de Itens com Ids duplicados
[n][1] - Alias do Evento
[n][2] - Array com Ids+Filiais Duplicados
[n][2][y][1] - Filial
[n][2][y][2] - Id Duplicado
[n][2][y][3] - Quantidade de Ids Duplicados para o Item
[n][2][y][4] - Versão do registro
[n][3] - Tipo do Evento (C-carga, M-Mensal, E-Eventual etc..)

*/
//------------------------------------------------------------------------------------------
Function TafListIdDup()
 
	Local aRotinas := {}
	Local aIdsDuplicados := {}
	Local cLayoutEvento := ""
	Local cTipoEvento := ""
	Local cAliasEvento := ""
	Local nX := 0
	Local cSql := ""

 	aRotinas := TAFRotinas(,,.T.,2)

	For nX := 1 To Len(aRotinas)

		cLayoutEvento := aRotinas[nX][4]
		cAliasEvento := aRotinas[nX][3]
		cTipoEvento := AllTrim(aRotinas[nX][12])

		If (cTipoEvento == "C" .Or. cLayoutEvento == "S-2200") .And. cAliasEvento != "C1E" //O 2200 ja engloba os  S-2300 e os TAUTO

			cSql := " SELECT " 	+ cAliasEvento + "." + cAliasEvento + "_FILIAL FILIAL "
			cSql += ","			+ cAliasEvento + "." + cAliasEvento + "_ID  ID "
			cSql += "," 		+ cAliasEvento + "." + cAliasEvento + "_VERSAO VERSAO "
			cSql += ", IDDUP.QTD QTD "

			If TAFColumnPos(cAliasEvento+"_LOGOPE")
				cSql += ", " + cAliasEvento + "." + cAliasEvento + "_LOGOPE  LOGOPE "
			Else
				cSql += ", ' ' LOGOPE "
			EndIf 

			If cAliasEvento == "C9V"
				cSql += ", C9V_NOMEVE NOMEVE "
			Else
				cSql += ", ' ' NOMEVE "
			EndIf 

			cSql += " FROM " + RetSqlName(cAliasEvento) + " " + cAliasEvento
			cSql += " INNER JOIN " 
			cSql += " ( "

			cSql += " SELECT COUNT(*) QTD , " + cAliasEvento + "_FILIAL FILIAL, " + cAliasEvento + "_ID ID "
			cSql += " FROM " + RetSqlName(cAliasEvento)
			cSql += " WHERE D_E_L_E_T_ = ' ' "
			cSql += " AND " + cAliasEvento + "_ATIVO = '1' "

			cSql += " GROUP BY " + cAliasEvento + "_FILIAL, " + cAliasEvento + "_ID "
			cSql += " HAVING Count(*) > 1 "

			cSql += " ) "
			cSql += " IDDUP ON " + cAliasEvento + "." + cAliasEvento + "_FILIAL = IDDUP.FILIAL " 
			cSql += " AND " + cAliasEvento + "." + cAliasEvento + "_ID = IDDUP.ID " 
			cSql += " AND " + cAliasEvento + "." + cAliasEvento + "_ATIVO = '1' "
			cSql += " AND " + cAliasEvento + ".D_E_L_E_T_ = ' ' "

			TCQuery cSql New Alias 'rsEvento'

			While rsEvento->(!Eof())

				If !(cAliasEvento $ "T1V|T1U|T0F|CM6")
					If Len(aIdsDuplicados) == 0 
						aAdd(aIdsDuplicados,{cAliasEvento,	{{	AllTrim(rsEvento->FILIAL);
																,AllTrim(rsEvento->ID);
																,rsEvento->QTD;
																,AllTrim(rsEvento->VERSAO);
																,AllTrim(rsEvento->LOGOPE);
																,AllTrim(rsEvento->NOMEVE);
															}},cTipoEvento})
					Else
						nPosLayout := aScan(aIdsDuplicados,{|alias|alias[1] == cAliasEvento})

						If nPosLayout > 0
							aAdd(aIdsDuplicados[nPosLayout][2],	{AllTrim(rsEvento->FILIAL);
																,AllTrim(rsEvento->ID);
																,rsEvento->QTD;
																,AllTrim(rsEvento->VERSAO);
																,AllTrim(rsEvento->LOGOPE);
																,AllTrim(rsEvento->NOMEVE);
																})
						Else
							aAdd(aIdsDuplicados,{cAliasEvento;
												,	{{	AllTrim(rsEvento->FILIAL);
														,AllTrim(rsEvento->ID);
														,rsEvento->QTD;
														,AllTrim(rsEvento->VERSAO);
														,AllTrim(rsEvento->LOGOPE);
														,AllTrim(rsEvento->NOMEVE);
													}};
												,cTipoEvento})
						EndIf 
					EndIf 
				EndIf

				rsEvento->(dbSkip())
			EndDo
			rsEvento->(dbCloseArea())
        EndIf 
	Next nX

Return (aIdsDuplicados) 

//------------------------------------------------------------------------------------------
/* {Protheus.doc} retServerIP
Retorna o IP do Servidor pela GetServerIP ou quando houver mais de um, retorna todos os IP's
do Servidor separados por ponto e virgula (;)

@author    brunno.costa
@version   1.0
@since     19/09/2018
@protected

@Return cReturn - IP do Servidor

*/
//------------------------------------------------------------------------------------------
Static Function retServerIP(lTodosIPs) 

	Local cReturn 	:= ""
	Local nInd		:= 0
	Local aIPs		:= getServerIP( .T. )

	DEFAULT lTodosIPs := .F.

	If lTodosIPs .and. ValType(aIPs) == "A" .and. Len(aIPs) > 1
		For nInd := 1 to Len(aIPs)
			If .t. //!(aIPs[nInd][4] $ cReturn)
				If !Empty(cReturn)
					cReturn 	+= "; "
				EndIf
				cReturn 	+= aIPs[nInd][4]
			EndIf
		Next nInd
		If "; " $ cReturn
			cReturn 	+= "; (Múlt.Redes*)"
		EndIf
	Else
		cReturn 	:= getServerIP( .F. )
	EndIf

Return cReturn

//------------------------------------------------------------------------------------------
/* {Protheus.doc} OpenURLOut
Chama uma ou várias vezes a ShellExecute com as URL a serem abertas

@author    brunno.costa
@version   1.0
@since     19/09/2018
@protected

@Param cOutrasURL - URL's a serem abertas separadas por ponto e virgula (;)

*/
//------------------------------------------------------------------------------------------
Static Function OpenURLOut(cOutrasURL)
	Local aURI	:= StrTokArr( cOutrasURL, ";" )
	Local nInd	:= 0
	For nInd := 1 to Len(aURI)
		ShellExecute("open",AllTrim(aURI[nInd]),"","",1)
	Next nInd
Return

/*/{Protheus.doc} VldChkFils
Rotina para verificar as estruturas do 
complemento de cadastro TAF
C1E x CR9

A regra para verificação deste problema é a seguinte:
Existe na CR9 e existe na C1E em um registro com ids diferentes = OK ( Cenário E-Social por um complemento e REINF por outro ).
Existe na CR9 e existe na C1E em mais de um registro. = NOK.
Existe em mais de uma C1E. = NOK.

@type  	 Static Function
@author  Diego Santos
@since   08-01-2018
@version 1.0
/*/
Function VldChkFils( cId, aChkC1EFils, aChkCR9Fils, lValidAll, aDuplic, cXVersao )

	Local aArea 	:= GetArea()
	Local aRet		:= {}

	Local lRet  := .T.
	Local cMsg  := "Complemento de Empresas"

	Default aDuplic		:= {}
	Default aChkC1EFils := {}
	Default aChkCR9Fils := {}
	Default cId			:= ""
	Default cXVersao	:= ""


	lRet := !VerDuplC1E( aChkC1EFils, cId, @aDuplic, cXVersao )

	If !lRet
		aAdd ( aRet, lRet )
		If VerDuplCR9( aChkCR9Fils, cId, lValidAll, @aDuplic, cXVersao )
			aAdd( aRet, cMsg + " com 2 registros na C1E duplicados")
			aAdd( aRet, " e 2 ocorrências na CR9 em registros da C1E distintos. Acesse o Wizard do TAF para efetuar o ajuste.")
		Else
			aAdd ( aRet, cMsg + " com 2 registros na C1E duplicados. Acesse o Wizard do TAF para efetuar o ajuste.")
		EndIf
	Else
		If VerDuplCR9( aChkCR9Fils, cId, lValidAll, @aDuplic, cXVersao )
			lRet := .F.
			aAdd( aRet, lRet )
			aAdd( aRet, cMsg + " com 2 ocorrências na CR9 em registros da C1E distintos.  Acesse o Wizard do TAF para efetuar o ajuste." )
		Else
			aAdd( aRet, lRet )
			aAdd( aRet, cMsg + " OK." )
		EndIf
	EndIf

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VerDuplC1E
Valida se existem registros duplicados na C1E
@author  Victor A. Barbosa
@since   08/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VerDuplC1E( aChkFils, cId, aDuplic, cXVersao )

	Local cC1EAlias := GetNextAlias()
	Local lRet		:= .F.
	Local cQuery    := ""
	Local cChkFils	:= ""
	Local nZ

	Default cId 		:= ""
	Default aChkFils 	:= {}
	Default aDuplic		:= {}
	Default cXVersao	:= ""

	cQuery := "SELECT C1E_CODFIL, C1E_ID, C1E_VERSAO, COUNT(C1E_CODFIL) QTDCODFIL "
	cQuery += " FROM " + RetSqlName("C1E")
	cQuery += " WHERE C1E_ATIVO = '1' AND "

	If Len( aChkFils ) > 0
		For nZ := 1 To Len( aChkFils )
			If nZ <> Len( aChkFils )
				cChkFils += AllTrim(aChkFils[nZ]) + ";"
			Else
				cChkFils += AllTrim(aChkFils[nZ])
			EndIf
		Next nZ
		cQuery += " C1E_CODFIL IN " + FormatIn( cChkFils, ";" ) + " AND "
		cQuery += " C1E_CODFIL <> '<NPI>' AND " 
	EndIf

	If !Empty(cId)
		cQuery += " C1E_ID <> '"+AllTrim(cId)+"' AND "
		cQuery += " C1E_VERSAO <> '"+AllTrim(cXVersao)+"' AND "
	EndIf

	cQuery += " D_E_L_E_T_ = '' "
	cQuery += " GROUP BY C1E_CODFIL, C1E_ID, C1E_VERSAO "

	If Empty(cId)
		cQuery += " HAVING COUNT(C1E_CODFIL) > 1 "
	EndIf

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cC1EAlias)

	(cC1EAlias)->( dbGoTop() )

	If (cC1EAlias)->( !Eof() )

		While (cC1EAlias)->( !Eof() )
			aAdd( aDuplic, AllTrim( (cC1EAlias)->C1E_CODFIL ) )
			(cC1EAlias)->( dbSkip() )
		EndDo

		lRet := .T.
	EndIf

	(cC1EAlias)->( dbCloseArea() )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VerDuplCR9
Valida se existem registros duplicados na C1E
@author  Victor A. Barbosa
@since   08/01/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function VerDuplCR9( aChkFils, cId, lValidAll, aDuplic, cXVersao )

	Local cCR9Alias := GetNextAlias()
	Local lRet		:= .F.
	Local cQryFils	:= ""
	Local cChkFils	:= ""
	Local nZ
	
	Default aChkFils 	:= {}
	Default cId 		:= ""
	Default aDuplic		:= {}
	Default cXVersao	:= ""
	
	If lValidAll .Or. Len(aChkFils) > 0
	
	
		cQryFils := " SELECT CODFIL, QUANTIDADE FROM "
		cQryFils += " ( "
		cQryFils += " SELECT CR9_CODFIL CODFIL, CR9_ID, CR9_VERSAO, COUNT(CR9_CODFIL) QUANTIDADE "
		cQryFils += " FROM " + RetSqlName("CR9")
		cQryFils += " WHERE "
		cQryFils += " CR9_ATIVO = '1' AND "
	
		If Len(aChkFils) > 0
			For nZ := 1 To Len( aChkFils )
				If nZ <> Len( aChkFils )
					cChkFils += AllTrim(aChkFils[nZ]) + ";"
				Else
					cChkFils += AllTrim(aChkFils[nZ])
				EndIf
			Next nZ
			cQryFils += " CR9_CODFIL IN " + FormatIn(cChkFils, ";") + " AND "
		EndIf
	
		If !Empty(cId)
			cQryFils += " CR9_ID <> '"+AllTrim(cId)+"' AND "
			cQryFils += " CR9_VERSAO <> '"+AllTrim(cXVersao)+"' AND "
		EndIf
	
		cQryFils += " D_E_L_E_T_ = '' "
		cQryFils += " GROUP BY CR9_CODFIL, CR9_ID, CR9_VERSAO "
	
		If Empty(cId)
			cQryFils += " HAVING COUNT(CR9_CODFIL) > 1 "
		EndIf
	
		cQryFils += " ) TAB "
	
		cQryFils := ChangeQuery( cQryFils )
	
		TCQuery cQryFils New Alias (cCR9Alias)
	
		(cCR9Alias)->( dbGoTop() )
	
		If (cCR9Alias)->( !Eof() )
			
			While (cCR9Alias)->( !Eof() )
				aAdd( aDuplic, AllTrim( (cCR9Alias)->CODFIL ) )
				(cCR9Alias)->( dbSkip() )
			EndDo
	
			lRet := .T.
	
		EndIf
	
		(cCR9Alias)->( dbCloseArea() )
	
	EndIf

Return(lRet)

Function AutConVld(aRotinas, nVerEmp)

	Local lRet      := .T.
	Local aContidas := {}

	Local cAlias    
	Local cRotina   := ""
	Local nI

	Private nVerTab	:=	0

	For nI := 1 to Len( aRotinas )

		cAlias    := aRotinas[nI,3]
		cRotina   := aRotinas[nI,1]

	    aContidas := &( "StaticCall( " + aRotinas[nI,1] + ", FAtuCont, nVerEmp, @nVerTab )" )
	    lRet := CheckT2U(nVerTab, cAlias, ,cRotina)
	
	    If !lRet
	        Exit
	    EndIf

	Next nI

	Asize(aContidas,0)
	aContidas := nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafConfigSMTP
Valida se o servidor SMTP está configurado corretamente.
@author  Silas G. da Silva
@since   12/05/2023
@version 1
@param aRet, array, Array de controle
@return cLabelSMTP, character, retorna frase conforme validação
do servidor SMTP.
/*/
//-------------------------------------------------------------------
Static Function TafConfigSMTP( aRet as array)

	Local cServer    as character
	Local cEmail     as character
	Local cPass      as character
	Local cLabelSMTP as character

	Default aRet := {.T., .T., .T.}

	cServer      := AllTrim( SuperGetMV( 'MV_RELSERV' ,, '' ) )
	cEmail       := AllTrim( SuperGetMV( 'MV_RELACNT' ,, '' ) )
	cPass        := AllTrim( SuperGetMV( 'MV_RELPSW' ,, '' ) )

	If !Empty( cServer ) .and. !Empty( cEmail ) .and. !Empty( cPass )
		cLabelSMTP  := STR0052 //"Servidor SMTP configurado" 
	Else
		cLabelSMTP  := STR0053 //"Servidor SMTP não configurado" 
		aRet[3]     := .F.
	EndIf
	
Return cLabelSMTP

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidEmail
Valida se o usuário administrador está com o campo de e-mail preenchido
@author  Silas G. da Silva
@since   12/05/2023
@version 1
@param aRet, array, Array de controle
@return cLabelEmail, character, retorna frase conforme validação do e-mail
/*/
//-------------------------------------------------------------------
Static Function ValidEmail( aRet as array)

	Local cLabelEmail as character
	Local cEmail      as character

	Default aRet := {.T., .T., .T., .T.}

	cEmail       := AllTrim(FWSFUser( "000000", "DATAUSER", "USR_EMAIL" ))

	If !Empty( cEmail )
		If ISEMAIL( cEmail )
			cLabelEmail  := STR0054 //"E-mail do usuário administrador cadastrado" 
		Else
			cLabelEmail  := STR0055 //"E-mail do usuário administrador fora do padrão." 
			aRet[4]      := .F.
		EndIf

	Else
		cLabelEmail  := STR0056 //"Usuário administrador sem e-mail cadastrado" 
		aRet[4]      := .F.
	EndIf
	
Return cLabelEmail
