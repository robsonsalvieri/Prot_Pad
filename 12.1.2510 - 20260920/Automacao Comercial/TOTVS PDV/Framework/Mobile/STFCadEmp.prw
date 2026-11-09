#INCLUDE 'Protheus.ch'
#INCLUDE 'POSCSS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "STFCADEMP.CH"

Static oDlg				:= Nil // Dialog Principal
Static cNomeEmp			:=	"" // Nome da empresa
Static cNFantasia			:=	"" // Nome fantasia
Static cCNPJ				:=	"" // Cnpj
Static cIE					:=	"" // Inscricao estadual
Static cIM					:=	"" // Inscricao municipal
Static cCodMun			:=	"" // codigo do municipio
Static cEndereco			:=	"" // Endereço
Static cComplemento		:=	"" // Complemento do endereço
Static cBairro			:=	"" // Bairro
Static cCep				:=	"" // CEP
Static cCidade			:=	"" // Cidade
Static cEstado			:=	"" // Estado
Static cCNAE				:=	"" // CNAE 
Static oGetCNAE			:= Nil	// CNAE
Static oGetEmp			:= Nil // Nome da empresa
Static oGetNFant			:= Nil // Nome fantasia
Static oGetCnpj			:= Nil // Cnpj
Static oGetIE				:= Nil // Inscricao estadual
Static oGetIM				:= Nil // Inscricao municipal
Static oGetCodMun			:= Nil // codigo do municipio
Static oGetEnd			:= Nil // Endereço
Static oGetComp			:= Nil // Complemento do endereço
Static oGetBairro			:= Nil // Bairro
Static oGetCep			:= Nil // CEP
Static oGetCid			:= Nil // Cidade
Static oGetEstado			:= Nil // Estado


//-------------------------------------------------------------------
/*/{Protheus.doc} STFCadEmp
Cadastro empresa

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFCadEmp()

Local oPnHeader			:= Nil				// Painel Superior
Local oPnBody 			:= Nil				// Painel Principal
Local nPanelWidth 		:= 600				// Largura
local nHeightBody 		:= 300				// Altura
Local nHeightFooter 		:= 40 				// Altura
Local nHeightHeader 		:= 25				// Altura
Local nMarginLeft 		:= 15				// Margem Esqueda
Local nMarginTop	 		:= 8				// Margem direita
Local aRes					:= GetScreenRes()	// Recupera Resolução atual
Local nWidth				:= aRes[1]			// Largura 
Local nHeight				:= aRes[2]			// Altura  
Local nWidthUtil 			:= 0				// Largura
Local nWidthField 		:= 0				// Largura
Local nTop 				:= 0				// Superior
Local nLeft 				:= 0				// Esquerda
Local nLine 				:= 0				// Linha
Local nRigth2column 		:= 0				// Coluna Direita
Local aFontLogin 			:= {'15' ,.T.}	// Fonte
Local aFontAccount 		:= {'16' ,.F.}	// Fonte
Local nHeightField 		:= 16				// Largura 
Local oPnRegister		   	:= Nil				// Panel 
Local oTitle			   	:= Nil				// Objeto titulo
Local oSayEmp			   	:= Nil				// Say Empresa
Local oSayEmail			:= Nil				// Say email
Local oSayCnpj			:= Nil				// Say CNPJ
Local oSayIE			   	:= Nil				// Say IE
Local oSayIM			   	:= Nil				// Say IM
Local oSayCodMun			:= Nil				// Say Codigo do municipio
Local oSayCNAE			:= Nil				// Say CNAE
Local oSayEnd			   	:= Nil				// Say Endereco
Local oSayComp			:= Nil				// Say Complemento
Local oSayBairro			:= Nil				// Say Bairro
Local oSayCep			   	:= Nil				// Say Cep
Local oSayCid			   	:= Nil				// Say Cidade
Local oSayEst			   	:= Nil				// Say Estado
Local oPnFooter		   	:= Nil				// Painel inferior
Local oBtnCad		   		:= Nil				// Botao Cadastrar

//Inicializa variaveis dos Gets
IniFields()

DEFINE DIALOG oDlg Pixel Of GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP) 

oDlg:nWidth 		:= nWidth 
oDlg:nHeight 		:= nHeight 
nWidthUtil 		:= nPanelWIdth - nMarginLeft 
nWidthField 		:= (nPanelWidth - (3 * nMarginLeft))/2
nTop 				:= (oDlg:nClientHeight/2-(nHeightBody+nHeightHeader+nHeightFooter))/2
nLeft 				:= (oDlg:nWidth/2-nPanelWIdth)/2
nLine 				:= 7.5
nRigth2column 	:= nMarginLeft*2+nWidthField

oPnRegister:= tPanel():New(nTop,nLeft,"",oDlg,,,,,,nPanelWIdth,nHeightBody+nHeightHeader+nHeightFooter)

oPnHeader:= tPanel():New(0,0,"",oPnRegister,,,,,,nPanelWIdth,nHeightHeader)
oPnHeader:SetCss(POSCSS (GetClassName(oPnHeader), CSS_PANEL_LOGINGHEADER ))

//Titulo do cadastro
@ nLine,nMarginLeft SAY oTitle PROMPT STR0001 SIZE nWidthUtil,nHeightHeader OF oPnHeader PIXEL //"Dados Cadastrais da Empresa"
oTitle:SetCss(POSCSS (GetClassName(oTitle), CSS_BREADCUMB ))

oPnBody := tPanel():New(nHeightHeader,0,"",oPnRegister,,,,,,nPanelWIdth,nHeightBody)
oPnBody:SetCss(POSCSS (GetClassName(oPnBody), CSS_PANEL_LOGINMAIN ))

//------------------------------------ Linha 1
nLine += 5
@ nLine,nMarginLeft SAY oSayEmp PROMPT STR0002 SIZE nWidthField,020 OF oPnBody PIXEL //"Nome Comercial"
oSayEmp:SetCss(POSCSS (GetClassName(oSayEmp), CSS_LABEL_FOCAL, aFontLogin ))

@ nLine,nRigth2column SAY oSayEmail PROMPT STR0003 SIZE nWidthField,020 OF oPnBody PIXEL //"Nome Fantasia"
oSayEmail:SetCss(POSCSS (GetClassName(oSayEmail), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//Nome da Empresa
@ nLine,nMarginLeft GET oGetEmp VAR cNomeEmp WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL
oGetEmp:SetCss(POSCSS (GetClassName(oGetEmp), CSS_GET_FOCAL ))


//Nome Fantasia
@ nLine, nRigth2column GET oGetNFant VAR cNFantasia WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL 
oGetNFant:SetCss(POSCSS (GetClassName(oGetNFant), CSS_GET_FOCAL ))




//------------------------------------ Linha 2
nLine += 30
@ nLine,nMarginLeft SAY oSayCnpj PROMPT STR0004 SIZE nWidthField,020 OF oPnBody PIXEL //"CNPJ"
oSayCnpj:SetCss(POSCSS (GetClassName(oSayCnpj), CSS_LABEL_FOCAL, aFontLogin ))

@ nLine,nRigth2column SAY oSayIE PROMPT STR0005 SIZE nWidthField,020 OF oPnBody PIXEL //"Inscrição Estadual"
oSayIE:SetCss(POSCSS (GetClassName(oSayIE), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//CNPJ
@ nLine, nMarginLeft GET oGetCnpj VAR cCNPJ WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL   Picture "@E " + Replicate("9",Len(cCNPJ) )
oGetCnpj:SetCss(POSCSS (GetClassName(oGetCnpj), CSS_GET_FOCAL ))

//Inscrição Estadual
@ nLine,nRigth2column GET oGetIE VAR cIE WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL  Picture "@E " + Replicate("9",Len(cIE) )
oGetIE:SetCss(POSCSS (GetClassName(oGetIE), CSS_GET_FOCAL ))


//------------------------------------ Linha 3
nLine += 30

@ nLine,nMarginLeft SAY oSayIM PROMPT STR0006 SIZE nWidthField,020 OF oPnBody PIXEL //"Inscrição Municipal"
oSayIM:SetCss(POSCSS (GetClassName(oSayIM), CSS_LABEL_FOCAL, aFontLogin ))

@ nLine,nRigth2column SAY oSayCodMun PROMPT STR0007 SIZE nWidthField,020 OF oPnBody PIXEL //"Código Município IBGE"
oSayCodMun:SetCss(POSCSS (GetClassName(oSayCodMun), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//Inscrição Municipal
@ nLine,nMarginLeft GET oGetIM VAR cIM WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL Picture "@E " + Replicate("9",Len(cIM) )
oGetIM:SetCss(POSCSS (GetClassName(oGetIM), CSS_GET_FOCAL ))

//Código Municipio
@ nLine,nRigth2column GET oGetCodMun VAR cCodMun WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL Picture "@E " + Replicate("9",Len(cCodMun) )
oGetCodMun:SetCss(POSCSS (GetClassName(oGetCodMun), CSS_GET_FOCAL ))


//------------------------------------ Linha 4
nLine += 30

@ nLine,nMarginLeft  SAY oSayCNAE PROMPT STR0008 SIZE nWidthField,020 OF oPnBody PIXEL //"CNAE"
oSayCNAE:SetCss(POSCSS (GetClassName(oSayCNAE), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//CNAE
@ nLine,nMarginLeft GET oGetCNAE VAR cCNAE WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL 
oGetCNAE:SetCss(POSCSS (GetClassName(oGetCNAE), CSS_GET_FOCAL ))


//------------------------------------ Linha 5
nLine += 30

@ nLine,nMarginLeft SAY oSayEnd PROMPT STR0009 SIZE nWidthField,020 OF oPnBody PIXEL //"Endereço"
oSayEnd:SetCss(POSCSS (GetClassName(oSayEnd), CSS_LABEL_FOCAL, aFontLogin ))

@ nLine,nRigth2column SAY oSayComp PROMPT STR0010 SIZE nWidthField,020 OF oPnBody PIXEL //"Complemento"
oSayComp:SetCss(POSCSS (GetClassName(oSayComp), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//Endereco
@ nLine,nMarginLeft GET oGetEnd VAR cEndereco WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL
oGetEnd:SetCss(POSCSS (GetClassName(oGetEnd), CSS_GET_FOCAL ))


//Complemento
@ nLine,nRigth2column GET oGetComp VAR cComplemento WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL
oGetComp:SetCss(POSCSS (GetClassName(oGetComp), CSS_GET_FOCAL ))



//------------------------------------ Linha 6
nLine += 30

@ nLine,nMarginLeft SAY oSayBairro PROMPT STR0011 SIZE nWidthField,020 OF oPnBody PIXEL //"Bairro"
oSayBairro:SetCss(POSCSS (GetClassName(oSayBairro), CSS_LABEL_FOCAL, aFontLogin ))

@ nLine,nRigth2column SAY oSayCep PROMPT STR0012 SIZE nWidthField,020 OF oPnBody PIXEL //"CEP"
oSayCep:SetCss(POSCSS (GetClassName(oSayCep), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//Bairro
@ nLine,nMarginLeft GET oGetBairro VAR cBairro WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL
oGetBairro:SetCss(POSCSS (GetClassName(oGetBairro), CSS_GET_FOCAL ))


//CEP
@ nLine,nRigth2column GET oGetCep VAR cCep WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL Picture "@E " + Replicate("9",Len(cCep) )
oGetCep:SetCss(POSCSS (GetClassName(oGetCep), CSS_GET_FOCAL ))


//------------------------------------ Linha 7
nLine += 30

@ nLine,nMarginLeft SAY oSayCid PROMPT STR0013 SIZE nWidthField,020 OF oPnBody PIXEL //"Cidade"
oSayCid:SetCss(POSCSS (GetClassName(oSayCid), CSS_LABEL_FOCAL, aFontLogin ))

@ nLine,nRigth2column SAY oSayEst PROMPT STR0014 SIZE nWidthField,020 OF oPnBody PIXEL //"Estado"
oSayEst:SetCss(POSCSS (GetClassName(oSayEst), CSS_LABEL_FOCAL, aFontLogin ))

nLine += 12

//Cidade
@ nLine,nMarginLeft GET oGetCid VAR cCidade WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL 
oGetCid:SetCss(POSCSS (GetClassName(oGetCid), CSS_GET_FOCAL ))

//Estado
@ nLine,nRigth2column GET oGetEstado VAR cEstado WHEN {|| .T. } SIZE nWidthField,nHeightField OF oPnBody PIXEL Picture "@!"
oGetEstado:SetCss(POSCSS (GetClassName(oGetEstado), CSS_GET_FOCAL ))



//------------------------------------  Rodape

oPnFooter := tPanel():New(nHeightHeader+nHeightBody,0,"",oPnRegister,,,,,,nPanelWIdth,nHeightFooter)
oPnFooter:SetCss(POSCSS (GetClassName(oPnFooter), CSS_PANEL_LOGINFOOTER ))

@ 10, nPanelWidth/2 - nWidthField/2 BUTTON oBtnCad PROMPT STR0015 SIZE nWidthField,nHeightField+4  ACTION {|| IIF( ValidCadastro()  , (STFUpdEmp(),oDlg:End() ) , ) } OF oPnFooter PIXEL  //"CADASTRAR"
oBtnCad:SetCss(POSCSS( GetClassName(oBtnCad), CSS_BTN_FOCAL) )


//Foco inicial
oGetEmp:SetFocus()


ACTIVATE DIALOG oDlg CENTER 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ValidCadastro
Valida o Cadastro antes da gravacao do dados

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function ValidCadastro()

Local lRet := .T. //Controle de Validacao 

lRet := lRet .AND. !Empty(cNomeEmp	)
IIF(!Empty(cNomeEmp	), oGetEmp:SetCss(POSCSS (GetClassName(oGetEmp), CSS_GET_FOCAL )) , oGetEmp:SetCss(POSCSS (GetClassName(oGetEmp), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cNFantasia)
IIF(!Empty(cNFantasia), oGetNFant:SetCss(POSCSS (GetClassName(oGetNFant), CSS_GET_FOCAL )) , oGetNFant:SetCss(POSCSS (GetClassName(oGetNFant), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cCNPJ	)
IIF(!Empty(cCNPJ	), oGetCnpj:SetCss(POSCSS (GetClassName(oGetCnpj), CSS_GET_FOCAL )) , oGetCnpj:SetCss(POSCSS (GetClassName(oGetCnpj), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cCodMun)
IIF(!Empty(cCodMun), oGetCodMun:SetCss(POSCSS (GetClassName(oGetCodMun), CSS_GET_FOCAL )) , oGetCodMun:SetCss(POSCSS (GetClassName(oGetCodMun), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cEndereco)
IIF(!Empty(cEndereco), oGetEnd:SetCss(POSCSS (GetClassName(oGetEnd), CSS_GET_FOCAL )) , oGetEnd:SetCss(POSCSS (GetClassName(oGetEnd), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cBairro)
IIF(!Empty(cBairro), oGetBairro:SetCss(POSCSS (GetClassName(oGetBairro), CSS_GET_FOCAL )) , oGetBairro:SetCss(POSCSS (GetClassName(oGetBairro), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cCep	)
IIF( !Empty(cCep	), oGetCep:SetCss(POSCSS (GetClassName(oGetCep), CSS_GET_FOCAL )) , oGetCep:SetCss(POSCSS (GetClassName(oGetCep), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cCidade)	
IIF(!Empty(cCidade)	, oGetCid:SetCss(POSCSS (GetClassName(oGetCid), CSS_GET_FOCAL )) , oGetCid:SetCss(POSCSS (GetClassName(oGetCid), CSS_GET_ERROR )) )

lRet := lRet .AND. !Empty(cEstado)	
IIF(!Empty(cEstado)	, oGetEstado:SetCss(POSCSS (GetClassName(oGetEstado), CSS_GET_FOCAL )) , oGetEstado:SetCss(POSCSS (GetClassName(oGetEstado), CSS_GET_ERROR )) )

If !lRet
	FWAlertError(STR0016)//"Campos obrigatórios não informados!"
EndIf	
	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IniFields
Inicializa Campos com tamanhos corretos de acordo com Sigamat

@param   	
@author  	Varejo
@version 	P11.8
@since   	09/06/2015
@return  	  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function IniFields()

Local aArea		:= GetArea() 				//Salva area

DbSelectArea( "SM0" )                                      

cNomeEmp			:=	SM0->M0_NOMECOM
cNFantasia			:=	SM0->M0_NOME
cCNPJ				:=	SM0->M0_CGC 
cIE					:=	SM0->M0_INSC 
cIM					:=	SM0->M0_INSCM 
cCodMun			:=	SM0->M0_CODMUN
cEndereco			:=	SM0->M0_ENDENT 
cComplemento		:=	SM0->M0_COMPENT 
cBairro			:=	SM0->M0_BAIRENT 
cCep				:=	SM0->M0_CEPENT 
cCidade			:=	SM0->M0_CIDENT  
cEstado			:=	SM0->M0_ESTENT
cCNAE				:=	SM0->M0_CNAE

RestArea(aArea)	

Return Nil

//--------------------------------------------------------
/*/{Protheus.doc} STFUpdEmp
Atualiza informações da empresa

@param   	
@author  	Varejo
@version 	P11.8
@since   	12/06/2015
@return  	lRet - Retorna se atualizou 
@obs     
@sample
/*/
//--------------------------------------------------------
Static Function STFUpdEmp()  
Local lRet			:= .T.						//Retorno 
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} STFVldCadEmp
Valida se o cadastro de empresas ja foi preenchido

@param   	
@author  	Varejo
@version 	P11.8
@since   	19/06/2015
@return  	lRet - 	Retorna se o cadastro de empresas ja foi preenchido
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFVldCadEmp()

Local aArea		:= GetArea() 				//Salva area
Local lRet := .T. //Controle de Validacao 

DbSelectArea( "SM0" )                                      

lRet := lRet .AND. !Empty(SM0->M0_NOMECOM	)
lRet := lRet .AND. !Empty(SM0->M0_NOME	)
lRet := lRet .AND. !Empty(SM0->M0_CGC 	)
lRet := lRet .AND. !Empty(SM0->M0_CODMUN	)
lRet := lRet .AND. !Empty(SM0->M0_ENDENT 	)
lRet := lRet .AND. !Empty(SM0->M0_BAIRENT	)
lRet := lRet .AND. !Empty(SM0->M0_CEPENT 	)
lRet := lRet .AND. !Empty(SM0->M0_CIDENT 	)
lRet := lRet .AND. !Empty(SM0->M0_ESTENT	)

RestArea(aArea)	

Return lRet


