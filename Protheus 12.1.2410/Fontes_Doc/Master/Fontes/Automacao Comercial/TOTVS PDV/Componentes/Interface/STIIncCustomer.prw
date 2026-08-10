#Include 'Protheus.ch'
#INCLUDE "STPOS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STIINCCUSTOMER.CH"

Static aIBGE 		:= STDUF()					//Array com informações de Estados e suas cidades
Static cSpaceMun	:= space(10)				//Numero de espaços reservado para a descrição do municipio (Municipio em branco)
Static cSpaceCod	:= space(5)					//Numero de espaços reservado para Codigo do IBGE
Static aCities	   	:= {cSpaceMun}				//Array com informações sobre as cidades
Static aCitiesComp  := {{cSpaceCod,cSpaceMun}}	//Array com informações sobre cidades contendo Codigo do IBGE e nome da cidade
Static aSelectCit	:= {cSpaceCod,cSpaceMun}	//Array com a informação sobre o texto selecionado no TEXTBOX
Static oMunicipio	:= Nil						//Objeto com TextBox

//-------------------------------------------------------------------
/*{Protheus.doc} STIIncCustomer
Chama a tela de cadastro de clientes

@param
@author  Varejo
@version P11.8
@since   17/07/2013
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STIIncCustomer()

STFCleanInterfaceMessage()
STIExchangePanel({|| STIPanIncCustomer() })

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanIncCustomer
Cria o painel de cadastro de clientes

@param
@author  Varejo
@version P11.8
@since   23/07/2012
@return  lRet			Retorno se executou corretamente a funcao
@obs
@sample
/*/
//-------------------------------------------------------------------

Static Function STIPanIncCustomer()
Local oPanelMVC		:= STIGetDlg()		//Painel principal do dialog
Local oMainPanel 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,(oPanelMVC:nWidth/2),(oPanelMVC:nHeight/2)) //Painel Cadastro de Cliente
Local oScrlPanel 	:= TScrollArea():New(oMainPanel,025,00,(oPanelMVC:nHeight/2)-70,(oPanelMVC:nWidth/2)-5 )
Local oFieldPanel 	:= TPanel():New(00,00,"",oScrlPanel,,,,,,(oPanelMVC:nWidth/2)-5,350)

Local nLargGets		:= 90
Local nLargGets2	:= POSHOR_2+90-POSHOR_1

Local oCab			:= Nil

Local oLblCodCLiente:= Nil
Local oCodCliente	:= Nil
Local cCodCliente 	:= CriaVar("A1_COD", .F.)				//Alteracao do conteudo do get

Local oLblLojCLiente:= Nil
Local oLojCliente	:= Nil
Local cLojCliente	:= CriaVar("A1_LOJA")

Local oLblNome		:= Nil
Local oNome			:= Nil
Local cNome 		:= CriaVar("A1_NOME")				//Alteracao do conteudo do get

Local oLblEndereco	:= Nil
Local oEndereco		:= Nil
Local cEndereco 	:= CriaVar("A1_END")				//Alteracao do conteudo do get

Local oLblTpCli		:= Nil
Local oTpCliente	:= Nil
Local cTpCliente 	:= CriaVar("A1_TIPO")				//Alteracao do conteudo do get
Local aItCliente    := StrTokArr( AllTrim( GetSx3Cache("A1_TIPO","X3_CBOX") ),';') // Itens do Combo Tipo Cliente

Local oLblEstado	:= Nil
Local oEstado		:= Nil
Local cEstado 		:= CriaVar("A1_EST")				//Alteracao do conteudo do get

Local aEstados     := {}								// Itens do Combo Estado 

Local oLblMunicipio	:= Nil
Local cMunicipio 	:= CriaVar("A1_MUN")				//Alteracao do conteudo do get

Local oLblTpPessoa	:= Nil
Local oTpPessoa		:= Nil
Local cTpPessoa 	:= CriaVar("A1_PESSOA")				//Alteracao do conteudo do get
Local aItPessoa     := StrTokArr( AllTrim( GetSx3Cache("A1_PESSOA","X3_CBOX") ),';')   // Itens do Combo Pessoa 

Local oLblCGC		:= Nil
Local oCGC			:= Nil
Local cCGC			:= CriaVar("A1_CGC")				//Alteracao do conteudo do get

Local oLblTel		:= Nil
Local oTelefone		:= Nil
Local cTelefone		:= CriaVar("A1_TEL")				//Alteracao do conteudo do get

Local oLblEmail		:= Nil
Local oEmail		:= Nil
Local cEmail		:= CriaVar("A1_EMAIL")				//Alteracao do conteudo do get

Local oBairro		:= Nil								//Armazena Get com o bairro
Local cBairro		:= CriaVar("A1_BAIRRO")				//Conteudo digitado no Get bairro
Local oLblBairro	:= Nil								//objeto Label 

Local oLblNascim 	:= Nil
Local dDtNascim		:= dDatabase
Local oDtNascim 	:= Nil

Local oLblCEP		:= Nil
Local cCep			:= space(9)
Local oCep			:= Nil

Local oInscr		:= Nil								
Local cInscr		:= CriaVar("A1_INSCR")				
Local oLblInscr		:= Nil								

Local oPais   		:= Nil								
Local cPais			:= CriaVar("A1_PAIS")				
Local oLblPais		:= Nil								

Local oCompl 		:= Nil								
Local cCompl		:= CriaVar("A1_COMPLEM")				
Local oLblCompl		:= Nil								

Local oGrTrib 		:= Nil								
Local cGrTrib		:= CriaVar("A1_GRPTRIB")
Local cF3GrTrib		:= GetSx3Cache("A1_GRPTRIB","X3_F3")			
Local oLblGrTrib	:= Nil

Local oLblFisTpPes	:= Nil
Local oFisTpPes		:= Nil
Local cFisTpPes 	:= CriaVar("A1_TPESSOA")				//Alteracao do conteudo do get
Local aFisTpPes     := StrTokArr( " ;"+AllTrim( GetSx3Cache("A1_TPESSOA","X3_CBOX") ),';')   // Itens do Combo Pessoa 
Local cGrpVen		:= AllTrim(GetSx3Cache("A1_GRPVEN","X3_RELACAO")) //Grupo de venda do cadastro de vendedores

Local oBtnConfirm	:= Nil
Local oBtnCancel	:= Nil

Local nVertCab		:= 010 	// Posicao vertical do cabecalho 

Local nVertLbl1		:= 005  // Posicao vertical dos label da linha 1
Local nVertGet1		:= 015  // Posicao vertical dos get da linha 1

Local nVertLbl2		:= nVertLbl1 + 30				// Posicao vertical dos label da linha 2
Local nVertGet2		:= nVertGet1 + 30				// Posicao vertical dos get da linha 2

Local nVertLbl3		:= nVertLbl2 + 30				// Posicao vertical dos label da linha 3
Local nVertGet3		:= nVertGet2 + 30				// Posicao vertical dos get da linha 3

Local nVertLbl4		:= nVertLbl3 + 30				// Posicao vertical dos label da linha 4
Local nVertGet4		:= nVertGet3 + 30				// Posicao vertical dos get da linha 4

Local nVertLbl5		:= nVertLbl4 + 30 				// Posicao vertical dos label da linha 5
Local nVertGet5		:= nVertGet4 + 30				// Posicao vertical dos get da linha 5+6

Local nVertLbl6		:= nVertLbl5 + 30				// Posicao vertical dos label da linha 6
Local nVertGet6		:= nVertGet5 + 30				// Posicao vertical dos get da linha 6

Local nVertLbl7		:= nVertLbl6 + 30				// Posicao vertical dos label da linha 7
Local nVertGet7		:= nVertGet6 + 30				// Posicao vertical dos get da linha 7

Local nVertLbl8		:= nVertLbl7 + 30				// Posicao vertical dos label da linha 8
Local nVertGet8		:= nVertGet7 + 30				// Posicao vertical dos get da linha 8

Local nVertLbl9		:= nVertLbl8 + 30				// Posicao vertical dos label da linha 9
Local nVertGet9		:= nVertGet8 + 30				// Posicao vertical dos get da linha 9

Local nVertLbl10	:= nVertLbl9 + 30				// Posicao vertical dos label da linha 10
Local nVertGet10	:= nVertGet9 + 30				// Posicao vertical dos get da linha 10

Local nVertLbl11	:= nVertLbl10 + 30				// Posicao vertical dos label da linha 11
Local nVertGet11	:= nVertGet10 + 30				// Posicao vertical dos get da linha 11

Local oFontCod		:= TFont():New('Arial',,-16,.T.)

Local lAutoGenCod	:= .T. 							// Geracao automatica de codigo // TO DO: Colocar parametro pra atribuir valor a esta variavel
Local nX											// Variavel para For				

For nX := 1 To Len(aIBGE)
	aAdd(aEstados,aIBGE[nX][1])
Next

If Empty(cLojCliente)
	cLojCliente := Soma1(cLojCliente)		
EndIf 

oScrlPanel:SetFrame( oFieldPanel )
oMainPanel:SetCSS(POSCSS(GetClassName(oMainPanel),CSS_PANEL_CONTEXT))
oScrlPanel:SetCSS("TScrollArea{ background-color: transparent; }")

oCab	:= TSay():New(nVertCab,POSHOR_1,{||STR0001},oMainPanel,,,,,,.T.,,,,) //"Cadastro de Clientes"
oCab:SetCSS( POSCSS(GetClassName(oCab),CSS_BREADCUMB)) 


oLblCodCLiente:= TSay():New(nVertLbl1,POSHOR_1,{||STR0002},oFieldPanel,,,,,,.T.,,,,)  //"Código do Cliente"
oLblCodCLiente:SetCSS( POSCSS(GetClassName(oLblCodCLiente),CSS_LABEL_FOCAL)) 

@ nVertGet1,POSHOR_1 MSGET oCodCliente VAR cCodCliente SIZE nLargGets,ALTURAGET VALID IIF(Empty(cLojCliente),.T.,STDExistChav("SA1",cCodCliente+cLojCliente,,STR0003)) PICTURE "@!" When {||!lAutoGenCod} FONT oFontCod OF oFieldPanel PIXEL  //"Já existe cliente cadastrado com o mesmo código e loja, favor alterar."

oLblLojCLiente:= TSay():New(nVertLbl1,POSHOR_2,{||STR0004},oFieldPanel,,,,,,.T.,,,,)  //"Loja do Cliente"
oLblLojCLiente:SetCSS( POSCSS (GetClassName(oLblLojCLiente), CSS_LABEL_FOCAL )) 


@ nVertGet1,POSHOR_2 MSGET oLojCliente VAR cLojCliente SIZE nLargGets,ALTURAGET VALID IIF(GetNewPar("MV_RMCLASS",.F.),.T.,STDExistChav("SA1",cCodCliente+cLojCliente,,STR0003)) WHEN &(AllTrim(GetSx3Cache("A1_LOJA","X3_WHEN"))) PICTURE "@!" OF oFieldPanel PIXEL  //"Já existe cliente cadastrado com o mesmo código e loja, favor alterar."
oLojCliente:SetCSS(POSCSS(GetClassName(oLojCliente),CSS_GET_FOCAL)) 


oLblNome:= TSay():New(nVertLbl2,POSHOR_1,{||STR0005},oFieldPanel,,,,,,.T.,,,,)  // "Nome"
oLblNome:SetCSS( POSCSS (GetClassName(oLblNome), CSS_LABEL_FOCAL )) 

@ nVertGet2,POSHOR_1 MSGET oNome  VAR cNome  SIZE nLargGets2,ALTURAGET PICTURE "@!" OF oFieldPanel PIXEL
oNome:SetCSS(POSCSS(GetClassName(oNome),CSS_GET_NORMAL)) 


oLblTpPessoa:= TSay():New(nVertLbl3,POSHOR_1,{||STR0007},oFieldPanel,,,,,,.T.,,,,)   //"Tipo Pessoa" 
oLblTpPessoa:SetCSS( POSCSS (GetClassName(oLblTpPessoa), CSS_LABEL_FOCAL )) 

oTpPessoa := TComboBox():Create(oFieldPanel, {|u| if( Pcount( )>0, cTpPessoa := u, cTpPessoa) }, nVertGet3, POSHOR_1, aItPessoa, nLargGets, ALTURAGET,,,,,,.T.,,,,,,,,,cTpPessoa) 
oTpPessoa:SetCSS( POSCSS (GetClassName(oTpPessoa), CSS_COMBOBOX ))

oLblTpCli:= TSay():New(nVertLbl3,POSHOR_2,{||STR0008},oFieldPanel,,,,,,.T.,,,,)  //"Tipo do Cliente"
oLblTpCli:SetCSS( POSCSS (GetClassName(oLblTpCli), CSS_LABEL_FOCAL)) 

oTpCliente := TComboBox():Create(oFieldPanel, {|u| if( Pcount( )>0, cTpCliente := u, cTpCliente) }, nVertGet3, POSHOR_2, aItCliente, nLargGets, ALTURAGET,,,,,,.T.,,,,,,,,,cTpCliente) 
oTpCliente:SetCSS( POSCSS (GetClassName(oTpCliente), CSS_COMBOBOX )) 


oLblNascim:= TSay():New(nVertLbl4,POSHOR_1,{||STR0039},oFieldPanel,,,,,,.T.,,,,) //"Data de Nascimento"
oLblNascim:SetCSS( POSCSS (GetClassName(oLblNascim), CSS_LABEL_FOCAL )) 

@ nVertGet4,POSHOR_1 MSGET oDtNascim VAR dDtNascim SIZE nLargGets,ALTURAGET PICTURE "@D" OF oFieldPanel PIXEL HASBUTTON
oDtNascim:SetCSS(POSCSS(GetClassName(oDtNascim),CSS_GET_NORMAL)) 

oLblCGC:= TSay():New(nVertLbl4,POSHOR_2,{||STR0009},oFieldPanel,,,,,,.T.,,,,)  //"CPF/CNPJ"
oLblCGC:SetCSS( POSCSS (GetClassName(oLblCGC), CSS_LABEL_FOCAL )) 

@ nVertGet4,POSHOR_2 MSGET oCGC VAR cCGC SIZE nLargGets,ALTURAGET VALID Empty(cCGC) .Or.;
 	IIF( SubStr(cTpCliente,1,1) == "X", .T., STICGCVld(cCGC,SubStr(cTpPessoa,1,1),@cCodCliente,oLojCliente,lAutoGenCod,@cLojCliente)[3]);
 	PICTURE "@R 99999999999999" OF oFieldPanel PIXEL
oCGC:SetCSS(POSCSS(GetClassName(oCGC),CSS_GET_NORMAL)) 


oLblEndereco:= TSay():New(nVertLbl5,POSHOR_1,{||STR0010},oFieldPanel,,,,,,.T.,,,,)  //"Endereço"
oLblEndereco:SetCSS( POSCSS (GetClassName(oLblEndereco), CSS_LABEL_FOCAL )) 

@ nVertGet5,POSHOR_1 MSGET oEndereco VAR cEndereco SIZE nLargGets,ALTURAGET PICTURE "@!" OF oFieldPanel PIXEL
oEndereco:SetCSS(POSCSS(GetClassName(oEndereco),CSS_GET_NORMAL))  

oLblBairro:= TSay():New(nVertLbl5,POSHOR_2,{||STR0038},oFieldPanel,,,,,,.T.,,,,)  //"Bairro"
oLblBairro:SetCSS( POSCSS (GetClassName(oLblBairro), CSS_LABEL_FOCAL )) 

@ nVertGet5,POSHOR_2 MSGET oBairro VAR cBairro SIZE nLargGets,ALTURAGET PICTURE "@!" OF oFieldPanel PIXEL
oBairro:SetCSS(POSCSS(GetClassName(oBairro),CSS_GET_NORMAL)) 

oLblEstado:= TSay():New(nVertLbl6,POSHOR_1,{||STR0011},oFieldPanel,,,,,,.T.,,,,)  //"Estado"
oLblEstado:SetCSS( POSCSS (GetClassName(oLblEstado), CSS_LABEL_FOCAL ))

oEstado := TComboBox():Create(oFieldPanel, {|u| if( Pcount( )>0, cEstado := u, cEstado) }, nVertGet6, POSHOR_1, aEstados, nLargGets, ALTURAGET,,,{|| STIGetMun(cEstado)},,,.T.,,,,,,,,,cEstado) 
oEstado:SetCSS( POSCSS (GetClassName(oEstado), CSS_COMBOBOX )) 

oLblMunicipio:= TSay():New(nVertLbl6,POSHOR_2,{||STR0012},oFieldPanel,,,,,,.T.,,,,)  //"Município"
oLblMunicipio:SetCSS( POSCSS (GetClassName(oLblMunicipio), CSS_LABEL_FOCAL )) 

oMunicipio := TComboBox():Create(oFieldPanel, {|u| if( Pcount( )>0, cMunicipio := u, cMunicipio) }, nVertGet6, POSHOR_2, aCities, nLargGets, ALTURAGET,,,{|| STIFillCit()},,,.T.,,,,,,,,,cMunicipio) 
oMunicipio:SetCSS( POSCSS (GetClassName(oMunicipio), CSS_COMBOBOX )) 

oLblCEP:= TSay():New(nVertLbl7,POSHOR_1,{||STR0040},oFieldPanel,,,,,,.T.,,,,) //"CEP"
oLblCEP:SetCSS( POSCSS (GetClassName(oLblCEP), CSS_LABEL_FOCAL )) 

@ nVertGet7,POSHOR_1 MSGET oCep VAR cCep SIZE nLargGets,ALTURAGET PICTURE "99999-999" OF oFieldPanel PIXEL
oCep:SetCSS(POSCSS(GetClassName(oCep),CSS_GET_NORMAL))  

oLblPais:= TSay():New(nVertLbl7,POSHOR_2,{|| STR0042},oFieldPanel,,,,,,.T.,,,,)  //"País"
oLblPais:SetCSS( POSCSS (GetClassName(oLblPais), CSS_LABEL_FOCAL )) 

@ nVertGet7,POSHOR_2 MSGET oPais VAR cPais SIZE nLargGets,ALTURAGET PICTURE "@!" F3 'SYA' OF oFieldPanel PIXEL HASBUTTON
oPais:SetCSS(POSCSS(GetClassName(oPais),CSS_GET_NORMAL))  

oLblCompl:= TSay():New(nVertLbl8,POSHOR_1,{|| STR0043},oFieldPanel,,,,,,.T.,,,,) //"Complemento"
oLblCompl:SetCSS( POSCSS (GetClassName(oLblCompl), CSS_LABEL_FOCAL )) 

@ nVertGet8,POSHOR_1 MSGET oCompl VAR cCompl SIZE nLargGets2,ALTURAGET PICTURE "@!" OF oFieldPanel PIXEL
oCompl:SetCSS(POSCSS(GetClassName(oCompl),CSS_GET_NORMAL))

oLblTel := TSay():New(nVertLbl9,POSHOR_1,{||STR0033},oFieldPanel,,,,,,.T.,,,,)  //"(DDD) + Telefone"
oLblTel:SetCSS( POSCSS (GetClassName(oLblTel), CSS_LABEL_FOCAL ))

@ nVertGet9,POSHOR_1 MSGET oTelefone  VAR cTelefone  SIZE nLargGets,ALTURAGET PICTURE "(999) 9999999999" OF oFieldPanel PIXEL
oTelefone:SetCSS(POSCSS(GetClassName(oTelefone),CSS_GET_NORMAL)) 

oLblEmail:= TSay():New(nVertLbl9,POSHOR_2,{||STR0034},oFieldPanel,,,,,,.T.,,,,)  //"E-mail"
oLblEmail:SetCSS( POSCSS (GetClassName(oLblEmail), CSS_LABEL_FOCAL )) 

@ nVertGet9,POSHOR_2 MSGET oEmail VAR cEmail SIZE nLargGets,ALTURAGET OF oFieldPanel PIXEL
oEmail:SetCSS(POSCSS(GetClassName(oEmail),CSS_GET_NORMAL))

oLblInscr:= TSay():New(nVertLbl10,POSHOR_1,{|| STR0044},oFieldPanel,,,,,,.T.,,,,)  //"Insc. Estad."
oLblInscr:SetCSS( POSCSS (GetClassName(oLblInscr), CSS_LABEL_FOCAL )) 

@ nVertGet10,POSHOR_1 MSGET oInscr VAR cInscr SIZE nLargGets,ALTURAGET VALID Empty(cInscr) .Or. STIIEVld(cInscr,SubStr(cEstado,1,2)) PICTURE "@!" OF oFieldPanel PIXEL
oInscr:SetCSS(POSCSS(GetClassName(oInscr),CSS_GET_NORMAL))  

oLblGrTrib:= TSay():New(nVertLbl10,POSHOR_2,{|| STR0045},oFieldPanel,,,,,,.T.,,,,)  //"Grp.Tribut."
oLblGrTrib:SetCSS( POSCSS (GetClassName(oLblGrTrib), CSS_LABEL_FOCAL )) 

@ nVertGet10,POSHOR_2 MSGET oGrTrib VAR cGrTrib SIZE nLargGets,ALTURAGET PICTURE "@!" OF oFieldPanel PIXEL HASBUTTON
if !empty(cF3GrTrib)
	oGrTrib:cF3 := cF3GrTrib
endif
oGrTrib:SetCSS(POSCSS(GetClassName(oGrTrib),CSS_GET_NORMAL))

oLblFisTpPes:= TSay():New(nVertLbl11,POSHOR_1,{||STR0007},oFieldPanel,,,,,,.T.,,,,)   //"Tipo Pessoa" 
oLblFisTpPes:SetCSS( POSCSS (GetClassName(oLblFisTpPes), CSS_LABEL_FOCAL )) 

oFisTpPes := TComboBox():Create(oFieldPanel, {|u| if( Pcount( )>0, cFisTpPes := u, cFisTpPes) }, nVertGet11, POSHOR_1, aFisTpPes, nLargGets, ALTURAGET,,,,,,.T.,,,,,,,,,cFisTpPes) 
oFisTpPes:SetCSS( POSCSS (GetClassName(oFisTpPes), CSS_COMBOBOX )) 


oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0013,oMainPanel,; //"Cadastrar Cliente"
							{ || STIConfCustomer(cCodCliente, cLojCliente, cNome, Iif(!Empty(cNome),StrTokArr(cNome," ")[1]," "),;
												SubStr(cTpPessoa,1,1), cCGC, SubStr(cTpCliente,1,1), cEndereco ,;
												SubStr(cEstado,1,2), aSelectCit[2], lAutoGenCod	, /*lOpenRegItem*/,;
												cBairro, SubStr(cTelefone,At("(",cTelefone)+1,3), SubStr(cTelefone,At(")",cTelefone)+1),;
												{"A1_FILIAL","A1_COD","A1_LOJA","A1_NOME","A1_NREDUZ","A1_END","A1_TIPO","A1_EST","A1_MUN",;
												"A1_PESSOA","A1_CGC","A1_DDD","A1_TEL","A1_EMAIL","A1_BAIRRO","A1_COD_MUN",;
												"A1_DTNASC","A1_CEP","A1_INSCR","A1_PAIS","A1_COMPLEM","A1_GRPTRIB","A1_TPESSOA","A1_GRPVEN"},;
												{{xFilial("SA1"),cCodCliente,cLojCliente,cNome,Iif(!Empty(cNome),StrTokArr(cNome," ")[1]," "),cEndereco,;
												SubStr(cTpCliente,1,1),SubStr(cEstado,1,2),aSelectCit[2],;
												SubStr(cTpPessoa,1,1),cCGC,SubStr(cTelefone,At("(",cTelefone)+1,3),SubStr(cTelefone,At(")",cTelefone)+1),;
												cEmail,cBairro,aSelectCit[1],dDtNascim,STRTRAN(cCep,"-",""),;
												cInscr , cPais , cCompl, cGrTrib ,SubStr(cFisTpPes,1,2),cGrpVen}} ,;
												/*lValidFields*/, /*cSitua*/, aSelectCit[1], cEmail	, STRTRAN(cCep,"-",""), dDtNascim,;
												 cInscr , cPais , cCompl, cGrTrib ,SubStr(cFisTpPes,1,2),oMainPanel) },; 
							LARGBTN,ALTURABTN,,,,.T.)

oBtnCancel := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0014,oMainPanel,{ || Iif(ExistFunc("StiMataObj"),StiMataObj(oMainPanel),Nil),STIRegItemInterface() }, ; //"Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)

oBtnConfirm:SetCSS(POSCSS(GetClassName(oBtnConfirm),CSS_BTN_FOCAL))							
oBtnCancel:SetCSS(POSCSS(GetClassName(oBtnCancel),CSS_BTN_NORMAL))

oNome:SetFocus()

Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STICGCVld
Realiza a confirmacao da inclusao do cliente

@param
@author  Varejo
@version P11.8
@since   18/07/2013
@return  
/*/
//-------------------------------------------------------------------
Function STICGCVld( cCGC,cTpPessoa,cCodCliente,oLojCliente,lAutoGenCod,cLojCliente )
Local lRet := .F.
Local aRet := Array(3)

IF STBCGCDigVerificador(cCGC)

	lRet := .T.

	If nModulo = 23		
		STFCleanInterfaceMessage()
	EndIf

	If lAutoGenCod
		If ExistBlock("STCodCli")
		    LjGrvLog("STIIncCustomer","Antes do ponto de entrada STCodCli")
			aRetPe := ExecBlock("STCodCli",.F.,.F.,{cCGC,cTpPessoa})
			LjGrvLog("STIIncCustomer","Retorno do ponto de entrada STCodCli", aRetPe)
			If (ValType(aRetPe) <> "A") .OR. (Len(aRetPe) < 2) .OR. (ValType(aRetPe[1]) <> TamSx3("A1_COD")[3]) .OR. (ValType(aRetPe[2]) <> TamSx3("A1_LOJA")[3])
				aRetPe := {}
				MsgStop(STR0049,STR0029)   //"Retorno do ponto de entrada STCodCli inválido.","Atenção!"
			Else
				cCodCliente := aRetPe[1] 
				cLojCliente := aRetPe[2]
			EndIf
			LjGrvLog("STIIncCustomer","Depois do ponto de entrada STCodCli")			
		Else			
			STICodeGenerator(cCGC,cTpPessoa,@cCodCliente,oLojCliente,@cLojCliente)
		EndIf
	EndIf
	
EndIf

aRet[1] := cCodCliente
aRet[2] := cLojCliente
aRet[3] := lRet

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIIEVld
Realiza a confirmacao da inclusao do cliente

@param
@author  Varejo
@version P11.8
@since   13/03/2020
@return  
/*/
//-------------------------------------------------------------------
Static Function STIIEVld(cInscr,cEstado) 
Local lRet := .F.

if IE(cInscr,cEstado, .F.)
	lRet := .T.
	STFCleanInterfaceMessage()
else
	STFMessage("STIIEVld","STOP", STR0041) //"A Inscrição Estadual informada está inválida para esta unidade federativa."
	STFShowMessage("STIIEVld")
endif

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIConfCustomer
Realiza a confirmacao da inclusao do cliente

@param	 lOpenRegItem para exibir ou não a tela de registro de item após a ação
@param	 lValidFields valida campos
@param	 cSitua - Situa para gravacao do cliente
@author  Varejo
@version P11.8
@since   18/07/2013
@return  
/*/
//-------------------------------------------------------------------
Function STIConfCustomer(	cCodCliente		,cLojCliente	,cNome			,cNFantasia		,;
							cTpPessoa	  	,cCGC			,cTpCliente		,cEndereco		,;
							cEstado    		,cMunicipio		,lAutoGenCod	,lOpenRegItem	,;
							cBairro    		,cDDD			,cTel			,aCampos		,;
							aDados			,lValidFields 	,cSitua			,cCodMun 		,;
							cEmail			,cCep			,dDtNascim		,cInscr			,;
							cPais			,cCompl			,cGrTrib 		,cFisTpPes		,;
							oMainPanel)

Local lRet			:= .T.
Local aSA1			:= {}
Local lSendCli		:= .F.                                 
Local nSendOn		:= SuperGetMV("MV_LJSENDO",,0) //Retorno como sera a integracao do cliente - 0 - via job - 1 online - 2 startjob
Local nI			:= 1
Local IncErro		:= .F.
Local lTabAI0		:= .F.							//Busca campos da tabela AI0
Local aCamposAI0	:= {}	
Local nX 			:= 0  //contador de campos
Local lA1_FILIAL	:= .F. //Existe campo Filial?
Local lEstadEstr 	:= cEstado == "EX"     // Estado estrangeiro
Local lTpCliEstr 	:= cTpCliente == "X"   // Tipo Cliente Estrangeiro
Local nAtuCliVda	:= SuperGetMv("MV_LJATCLI",,2) // Força a atualização do cliente
Local lRegNovo		:= .F.  //Verifica se deve incluir ou alterar o cliente

Default lOpenRegItem	:= .T. //define se após executar a rotina irá mudar para o registro de item
Default cBairro			:= ""
Default cDDD			:= ""	
Default cTel			:= ""
Default aCampos			:= {}
Default aDados			:= {}
Default lValidFields	:= .T. //Valida campos
Default cSitua			:= "00"
Default cCodMun			:= ""
Default cEmail			:= ""
Default cCep			:= ""
Default dDtNascim		:= dDataBase
Default cInscr			:= ""
Default cPais			:= ""
Default cCompl			:= ""
Default cGrTrib			:= ""
Default cFisTpPes		:= ""
Default oMainPanel		:= Nil

lRet := STDExistChav("SA1",cCodCliente+cLojCliente,,STR0003,nAtuCliVda)  //"Já existe cliente cadastrado com o mesmo código e loja, favor alterar."

//Se o lRet Retornar .F. indica que o cliente já ecxiste na base conforme a função STDExistChav
If lRet
	lRegNovo := .T.
Endif

For nX := 1 to Len(aCampos)
	If !lA1_FILIAL
		lA1_FILIAL := aCampos[nX] == "A1_FILIAL"
	EndIf
	If nX <= Len(aCampos) .AND. "AI0_" $ aCampos[nX]
		aAdd(aCamposAI0, { aCampos[nX], aDados[1][nX] } )
		aDel(aCampos, nX)
		aSize(aCampos, len(aCampos) - 1)
		aDel(aDados[1], nX)
		aSize(aDados[1], len(aDados[1]) - 1)
	EndIf
Next

lTabAI0 :=  Len(aCamposAI0) > 0


If lRet .AND. lValidFields 	
	lRet := STIChkFields(cCodCliente,cLojCliente,cNome		,cNFantasia	,;
						 cTpPessoa	,cCGC		,cTpCliente	,cEndereco	,;
						 cEstado	,cMunicipio	,lAutoGenCod, cPais, cInscr)
EndIf

If lRet .AND. lValidFields .AND. ( !lEstadEstr .OR. !lTpCliEstr )						
	lRet := STBVldCGC(cCodCliente,cLojCliente,cTpPessoa, cCGC)
	If !lRet
		Conout(STR0031) //"CPF do cliente a ser cadastrado é inválido. "
	EndIf 	
EndIf			

If lRet .OR. nAtuCliVda == 1
	If Len(aCampos) > 0 .AND. Len(aDados) > 0 
		If !lA1_FILIAL
			aAdd(aSA1, {"A1_FILIAL"	,xFilial("SA1"), Nil	})
		EndIf
		For nI := 1 To Len(aCampos)
			aAdd(aSA1, {aCampos[nI]	,aDados[1][nI], Nil	})
		Next nI	
		
	Else
		Aadd(aSA1,{"A1_FILIAL"	, xFilial("SA1"), Nil })
		Aadd(aSA1,{"A1_COD"		, cCodCliente	, Nil })
		Aadd(aSA1,{"A1_LOJA"	, cLojCliente	, Nil })
		Aadd(aSA1,{"A1_NOME"	, cNome			, Nil })
		Aadd(aSA1,{"A1_NREDUZ" 	, cNFantasia	, Nil })
		Aadd(aSA1,{"A1_CGC" 	, cCGC			, Nil })
		Aadd(aSA1,{"A1_END"  	, cEndereco		, Nil })
		Aadd(aSA1,{"A1_EST"  	, cEstado		, Nil })
		Aadd(aSA1,{"A1_MUN"  	, cMunicipio	, Nil })
		Aadd(aSA1,{"A1_COD_MUN"	, cCodMun		, Nil })
		Aadd(aSA1,{"A1_TIPO"  	, cTpCliente	, Nil })   
		Aadd(aSA1,{"A1_PESSOA"	, cTpPessoa		, Nil })
		Aadd(aSA1,{"A1_BAIRRO"	, cBairro		, Nil })
		Aadd(aSA1,{"A1_DDD"  	, cDDD			, Nil })
		Aadd(aSA1,{"A1_TEL"  	, cTel			, Nil })
		Aadd(aSA1,{"A1_EMAIL"  	, cEmail		, Nil })
		Aadd(aSA1,{"A1_CEP"  	, cCep			, Nil })
		Aadd(aSA1,{"A1_DTNASC" 	, dDtNascim		, Nil })
		Aadd(aSA1,{"A1_INSCR"  	, cInscr		, Nil })
		Aadd(aSA1,{"A1_PAIS"  	, cPais			, Nil })
		Aadd(aSA1,{"A1_COMPLEM"	, cCompl		, Nil })
		Aadd(aSA1,{"A1_GRPTRIB"	, cGrTrib		, Nil })
		Aadd(aSA1,{"A1_TPESSOA"	, cFisTpPes		, Nil })
	EndIf   

	Aadd(aSA1,{"A1_SITUA", cSitua , Nil }) // Grava o A1_SITUA local 
	
	//Foi removido tratamento de execAuto, pois não ha a necessidade de se chamar a rotina
	//pois são gravados campos basicos para o cliente ser utilizado no PDV.
	//Alem disso, para a versão 12 foram incluidas funções que utilizam comandos SQL, que nao são executados no PDV (em DBF). 
	Conout("Gravando cliente...")
	
	If SA1->(RecLock("SA1",lRegNovo))
		For nI := 1 To Len(aSA1)
			SA1->&(aSA1[nI,1]) := aSA1[nI,2]
		Next
		SA1->(MSUnlock())
	Else
		IncErro := .T.
	EndIf	
	
	If lTabAI0 
		AI0->(DbSetOrder(1)) //AI0_FILIAL + AI0_CODCLI + AI0_LOJA
		If !AI0->(DbSeek(xFilial("AI0")+ SA1->A1_COD+SA1->A1_LOJA))
			SA1->(RecLock("AI0",.T.))
			AI0->AI0_FILIAL := xFilial("AI0")
			AI0->AI0_CODCLI := cCodCliente
			AI0->AI0_LOJA 	:= cLojCliente
			For nI := 1 To Len(aCamposAI0)
				AI0->&(aCamposAI0[nI,1]) := aCamposAI0[nI,2]
			Next			
			AI0->(MSUnlock())
		EndIf
	EndIf
	Conout("Fim da gravacao do cliente")

	If IncErro
		STFMessage(ProcName(),"STOP",STR0016)  //"Houve erro na gravação do cliente."
		STFShowMessage(ProcName())
		Conout(STR0016) //"Houve erro na gravação do cliente."
		lRet := .F.
	Else
		If nAtuCliVda == 1
			STFMessage(ProcName(),"STOP",STR0048)  // "O cliente foi atualizado com sucesso."
		Else
			STFMessage(ProcName(),"STOP",STR0017)  //"O cliente foi incluido com sucesso."
		EndIf
		STFShowMessage(ProcName())
		Conout(STR0017 + " Recno:" +  AllTrim(Str(SA1->(RecNo())))) //"O cliente foi incluido com sucesso."
	EndIf
Else
    Conout(STR0035 + " Recno:" +  AllTrim(Str(SA1->(RecNo())))) //"O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
    LjGrvLog(STR0001 + " STIConfCustomer",cCodCliente+cLojCliente,STR0035) // STR0001 -> "Cadastro de Clientes" || STR0035 -> "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."	
EndIf

//Transmite o cliente para retaguarda  - gorgulho
If lRet .AND. nSendOn == 1            
	MsgRun(STR0032,'Aguarde...',{||STDSendCli(aSA1,@lSendCli)}) //"Transmitindo cliente"
ElseIf lRet .AND. nSendOn == 2
	StartJob("STDSendCli", GetEnvServer(), .F., aSA1,@lSendCli,.T.,cEmpAnt,cFilAnt)
EndIf
 
If lRet .AND. !lSendCli .AND. cSitua == "00"
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If DbSeek(xFilial("SA1")+cCodCliente+cLojCliente)
	
		STFSLICreate(     Nil   , "UP"            , "UP"      , "NOVO"         , ;
                            Nil   , Nil             , Nil       , Nil             , ;
                           "SA1"  , SA1->(RecNo()), Nil       )		
	
	Else
	
		Conout(STR0030 + cCodCliente+cLojCliente )         //"Não achou"
	
	EndIf
EndIf

If lRet .AND. lOpenRegItem
	Iif(ExistFunc("StiMataObj"),StiMataObj(oMainPanel),Nil)
	STIRegItemInterface()
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STIChkFields
Verifica se os campos obrigatorios foram preenchidos e informa o usuario caso nao tenha sido.

@param
@author  Varejo
@version P11.8
@since   18/07/2013
@return  lRet - Retorna True se todos os campos obrigatorios foram preenchidos
/*/
//-------------------------------------------------------------------
Static Function STIChkFields(	cCodCliente,cLojCliente,cNome,cNFantasia,;
								cTpPessoa,cCGC,cTpCliente,cEndereco,;
								cEstado,cMunicipio, lAutoGenCod, cPais,;
								cInscr)
Local lRet      := .T.  
Local cEnter    := CHR(13)+CHR(10)
Local cAlert    := ''

Do Case
    Case ( cTpCliente == "X" .AND. cEstado <> "EX")
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0036 + cEnter + STR0035)  //"Campo 'Tipo de cliente' informado como 'X' (Estrangeiro) e campo 'Estado' difente de 'EX'." || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())    
        cAlert := STR0036
    Case ( cTpCliente <> "X" .AND. cEstado == "EX")
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0037 + cEnter + STR0035  )  // "Campo 'Estado' informado como 'EX' (Estrangeiro) e campo 'Tipo de Cliente' diferente de 'X'." || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0037
    Case lAutoGenCod .AND. Empty(cCGC) .AND. ( cTpCliente <> "X" .AND. cEstado <> "EX")
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0018 + cEnter + STR0035 )  //"Preencha o CPF para gerar o código do cliente!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0018
    Case Empty(cCodCliente)
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0019 + cEnter + STR0035 )  //"O campo Código do Cliente deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0019
    Case Empty(cLojCliente) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0020 + cEnter + STR0035 )  //"O campo Loja do Cliente deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0020
    Case Empty(cNome) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0021 + cEnter + STR0035 )  //"O campo Nome deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0021
    Case Empty(cNFantasia) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0022 + cEnter + STR0035)  //"O campo Nome Fantasia deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0022
    Case Empty(cTpPessoa) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0023 + cEnter + STR0035)  //"O campo Tipo Pessoa deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0023
    Case Empty(cTpCliente) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0024 + cEnter + STR0035)  //"O campo Tipo do Cliente deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0024
    Case Empty(cEndereco) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0025 + cEnter + STR0035)  //"O campo Endereço deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0025
    Case Empty(cEstado) 
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0026 + cEnter + STR0035)  //"O campo Estado deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0026
    Case Empty(cMunicipio)
        lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0027 + cEnter + STR0035)  //"O campo Município deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0027
	Case ( empty(cInscr) .AND. cTpPessoa == "J" )
		lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP", STR0046 + cEnter + STR0035  )  // "Pessoa Jurídica. O campo Inscrição Estadual deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0046
	Case ( empty(cPais) .AND. cEstado == "EX" )
		lRet := .F.
        STFMessage(ProcName(),"STOPPOPUP",STR0047 + cEnter + STR0035  )  // "O campo País deve ser preenchido!" || "O Cliente não será cadastrado no PDV, regularize o cadastro na Retaguarda."
        STFShowMessage(ProcName())
        cAlert := STR0047
EndCase                             

If !lRet
    LjGrvLog(STR0001 + " STIChkFields",cCodCliente+cLojCliente,cAlert) // STR0001 -> "Cadastro de Clientes"
EndIf						

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STICodeGenerator
Gera o codigo do cliente a partir do CPF/CNPJ.

@param
@author  Varejo
@version P11.8
@since   18/07/2013
@return  lRet - Retorna True se todos os campos obrigatorios foram preenchidos
/*/
//-------------------------------------------------------------------
Function STICodeGenerator(cCGC,cTpPessoa,cCodCliente,oLojCliente,cLojCliente)

Local aArea	   		:= GetArea()           						//Area atual
Local aAreaSA1 		:= SA1->(GetArea())    						//Area do SA1
Local nTamCod		:= TamSx3("A1_COD")[1]						//Tamanho do campo
Local nDiv			:= 0                    					//Numero utilizado para geracao do A1_COD
Local nResto		:= 0                    					//Guarda o resto da divisao
Local cNumero		:= Space(nTamCod)							//Numero gerado
Local lSTGenCli 	:= ExistBlock("STGenCli")
Local aRetPe		:= {}										//Retorno do ponto de entrada
Local cCodConut 	:= ""										//codigo do contador
Local cLimit		:= ""										//Numero maximo de tentativas
Local aCodCliLoj 	:= {"",""}									// Codigo gerado
Local cLjTpGCC		:= SuperGetMV("MV_LJTPGCC",,"0") 			// Opções de geração de código de cliente: 0 ou nil-legado; 1- 9 digitos numéricos; 2- algoritmo Base 36.
Local nTXGCodCli  	:= TamSXG("001")[1]							// Tamanho do grupo de Cliente
Local cQuerySA1		:= ""
Local cAliasSA1		:= ""
Local cCGCEmbrlh	:= AllTrim(Embaralha(SubStr(cCGC,1,9),0)) 	// 9 primeiros digitos embaralhados
Local nTamA1CGC		:= TamSx3("A1_CGC")[1]						//Tamanho do campo

Default cLojCliente := "01" 

LjGrvLog("STICodeGenerator", "MV_LJTPGCC - " + cLjTpGCC)

If !Empty(cCGC)   

	If cLjTpGCC == "1" .AND. nTXGCodCli >= 9 // Gera codigo com 9 digitos
		
		If SA1->(dbSeek( xFilial("SA1") + cCGCEmbrlh ) ) 
			// Se o CPF ou CNPJ ja esta cadastrado mantem o codigo e soma a filial
			cQuerySA1 += " SELECT MAX(A1_LOJA) AS MAXLOJA "
			cQuerySA1 += " FROM " + RetSqlName("SA1") + ""
			cQuerySA1 += " WHERE A1_COD = '" + cCGCEmbrlh + "' "

			cAliasSA1 := MPSysOpenQuery(cQuerySA1)

			cCodCliente	:= SA1->A1_COD
			cLojCliente := Soma1((cAliasSA1)->MAXLOJA)
		Else
			cCodCliente	:= cCGCEmbrlh
			cLojCliente := "01"
		EndIf

	Elseif cLjTpGCC == "2" // Geração do Codcli usando algoritmo Base36.
		
		If lSTGenCli
		
			aRetPe := ExecBlock("STGenCli",.F.,.F.,{cCGC,cTpPessoa})
			If ValType(aRetPe) <> "A"
				aRetPe := {}
				MsgStop(STR0028,STR0029)   //"Retorno do STGenCli tem tipo inválido.","Atenção!"
			Else
				cCodCliente := aRetPe[1] 
				cLojCliente := aRetPe[2]
			EndIf

		Else 
			
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) 
			cCodCliente:= STIGerCliB36(cCGC)

			If SA1->(dbSeek( xFilial("SA1") + cCodCliente + cLojCliente) )
		
				cQuerySA1 += " SELECT MAX(A1_LOJA) AS MAXLOJA "
				cQuerySA1 += " FROM " + RetSqlName("SA1") + ""
				cQuerySA1 += " WHERE A1_COD = '" + cCodCliente + "' "
				cQuerySA1 += " AND A1_CGC = '" + PadR(Alltrim(cCGC),nTamA1CGC) + "' "
				
				cAliasSA1 := MPSysOpenQuery(cQuerySA1)
				cLojCliente := Soma1((cAliasSA1)->MAXLOJA)
				
			Endif
			 
		Endif 

		LjGrvLog("STICodeGenerator", "CodCli - "+cCodCliente+" gerado através do algoritmo base 36")
	Else

		If lSTGenCli
			aRetPe := ExecBlock("STGenCli",.F.,.F.,{cCGC,cTpPessoa})
			If ValType(aRetPe) <> "A"
				aRetPe := {}
				MsgStop(STR0028,STR0029)   //"Retorno do STGenCli tem tipo inválido.","Atenção!"
			Else
				cCodCliente := aRetPe[1] 
				cLojCliente := aRetPe[2]
			EndIf
		Else
		
			If Len(AllTrim(cCGC)) > 11
				//Pessoa Juridica
				nDiv := Val(cCGC)
			Else
				//Pessoa Fisica
				nDiv := Val(SubStr(cCGC,1,9))
			EndIf
		
			//Calcula codigo
			While nDiv >= 35 .AND. Len(AllTrim(cNumero)) < 6
				//Pega o inteiro do resto da divisao
				nResto := int(nDiv % 35)
				//Pega o valor inteiro da divisao
				nDiv := int(nDiv / 35)
				cNumero:= AllTrim(IIf(nResto < 10, Str(nResto), Chr(nResto + 55))) + AllTrim(cNumero)
			End
		
			//Quando codigo gerado for diferente do tamanho do campo A1_COD, realizado ajuste
			If Len(AllTrim(cNumero)) <> nTamCod
				cNumero := AllTrim(IIf(nResto < 10, Str(nResto), Chr(nResto + 55))) + AllTrim(cNumero)
			EndIf
		
			cCodCliente := Replicate("0", nTamCod - Len(AllTrim(cNumero))) + AllTrim(cNumero)
		EndIf
		
		If Empty(cLojCliente)
			cLojCliente := Soma1(cLojCliente)
		EndIf 

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) 
		SA1->(dbSeek(xFilial("SA1") + cCodCliente + cLojCliente) )

		If Len(AllTrim(cCGC)) <=11 .And. Alltrim(cCGC) == AllTrim(SA1->A1_CGC)
			cLimit := Replicate("Z" , TamSx3("A1_LOJA")[1] )
		Else
			cLimit := Replicate("Z" , TamSx3("A1_COD")[1] )
		EndIf	
		//No caso do codigo duplicado, soma posições ate que o codigo seja valido e contador dentro do limite
		While ( SA1->(dbSeek(xFilial("SA1") + cCodCliente + cLojCliente) ) )  .And. cCodConut <> cLimit	

			// Se for o mesmo cpf incrementamos a loja
			If Len(AllTrim(cCGC)) <=11 .And. Alltrim(cCGC) == AllTrim(SA1->A1_CGC)
				cLojCliente := cCodConut := Soma1(cLojCliente)
			Else	
				cCodCliente := cCodConut := Soma1(cCodCliente)
			EndIf
					
		EndDo
	EndIf
EndIf

//Restaura a area atual e do arquivo SA1
RestArea(aAreaSA1)
RestArea(aArea)

aCodCliLoj[01] := cCodCliente
aCodCliLoj[02] := cLojCliente
	
Return aCodCliLoj

//-------------------------------------------------------------------
/*{Protheus.doc} STIGerCliB36
//Gera Código de cliente alfanumérica para CPF e CNPJ utilizando Base 36

@param cNumero, Caracter, Numero do CPF ou CNPJ
@author  caio.okamoto
@version P12
@since   22/04/2024
@return  cCodB36, caracter, Código do cliente
/*/
//-------------------------------------------------------------------
Function STIGerCliB36(cNumero)
Local aNumero 	:= {}
Local nNumero	:= 0
Local nNumPos   := 0
Local cCodB36	:= ""
DEFAULT cNumero := ""

If ValType(cNumero) == TamSx3("A1_COD")[3] 

	If cNumero <> ""
		cNumero:= AllTrim(cNumero)

		If Len(cNumero) == 14 		//CNPJ
			aNumero	:= { Val(Left(cNumero,2))+1196, Val(SubStr(cNumero,3,3)), Val(SubStr(cNumero,6,3)) }
		ElseIf Len(cNumero) == 11 	//CPF
			aNumero	:= { Val(Left(cNumero,3)), 		Val(SubStr(cNumero,4,3)), Val(SubStr(cNumero,7,3)) }
		EndIf

		For nNumPos := 1 To 3
			nNumero := Int(aNumero[nNumPos] / 36)
			cCodB36 += IIf(nNumero < 10, Str(nNumero, 1), Chr(nNumero + 55))
			nNumero := aNumero[nNumPos] - (nNumero * 36) 
			cCodB36 += IIf(nNumero < 10, Str(nNumero, 1), Chr(nNumero + 55))
		Next 
	Endif
Endif

Return cCodB36




/*/{Protheus.doc} STIGetMun

Alimenta o array aCitiesComp com o codigo do IBGE + Nome da cidade e o array aCities com a descrição das cidades 

@type function
@author Lucas Novais (lnovais@)
@since 09/09/2019
@version P12.1.25
@param cState, caracter, Estado base para buscar as informações das cidades e codigo do IBGE
@return Nil

/*/

Static Function STIGetMun(cState)
Local nX																			// Variavel para  For
Local nPosSta 	:= aScan(aIBGE,{|x| x[1] == cState})								// Localiza o estado no array matriz com as informações dos estados
Local lEndFis   := SuperGetMv("MV_SPEDEND",, .F.)									// Se estiver como F refere-se ao endereço de Cobrança se estiver T ao endereço de Entrega.
Local cCitSM0	:= Alltrim(UPPER(IIf(!lEndFis, SM0->M0_CIDCOB, SM0->M0_CIDENT)))	// Indica qual cidade sera considerada, se a de entrega ou cobrança

If nPosSta > 0

	//Zero o conteudo das variaveis estaticas prevendo a possivel troca de estado, não acumulando com as cidades anteriormente carregadas.
	//Obs: o Array deverá sempre nascer com o esqueleto moldado, fazendo com que a primeira posição do TextBox sempre esteja em branco forçando a alteração 
	//desta forma o valid é chamado dando sequência a algumas ações em cadeia. 
	aCities 	:= {cSpaceMun}
	aCitiesComp	:= {{cSpaceCod,cSpaceMun}}
	aSelectCit	:= {cSpaceCod,cSpaceMun}

	//Caso encontre a cidade da SM0 coloco ela em primeiro lugar para facilitar a navegação.
	If nPosCitSM0 := aScan(aIBGE[nPosSta][2],{|x| Alltrim(x[2]) == cCitSM0}) 
		Aadd(aCitiesComp,{aIBGE[nPosSta][2][nPosCitSM0][1],aIBGE[nPosSta][2][nPosCitSM0][2]})
		Aadd(aCities,aIBGE[nPosSta][2][nPosCitSM0][2])
	EndIf

	For nX := 1 To Len(aIBGE[nPosSta][2]) 
		If !(nPosCitSM0 <> 0 .And. cCitSM0 == AllTrim(aIBGE[nPosSta][2][nX][2]))
			Aadd(aCitiesComp,{aIBGE[nPosSta][2][nX][1],aIBGE[nPosSta][2][nX][2]})
			Aadd(aCities,aIBGE[nPosSta][2][nX][2])
		EndIf 
	Next

EndIf

//Caso não tenha selecionado nenhum estado limpo o TextBox com os municipios
If Empty(cState)
	oMunicipio:SetItems({cSpaceMun})
Else
	oMunicipio:SetItems(aCities)
EndIf 

Return 

/*/{Protheus.doc} STIFillCit

Função responsavel por preencher o array aSelectCit com as informações de Codigo do IBGE da cidade e cidade selecionada.

@type function
@author Lucas Novais (lnovais@)
@since 09/09/2019
@version P12.1.25
@return Nil

/*/

Static Function STIFillCit()

Local nPosSelect 	:= Iif(oMunicipio:nAt == 0, 1, oMunicipio:nAt)						//Retorna a posição selecionada no objeto
Local nPosCitComp 	:= aScan(aCitiesComp,{|x| x[2] == oMunicipio:aItems[nPosSelect]}) 	//Retorna a posição da cidade seleciona no array de "cidades completo" 

//Reinicio a variavel estatica
aSelectCit := {}

aAdd(aSelectCit,aCitiesComp[nPosCitComp][1]) // Codigo do IBGE
aAdd(aSelectCit,aCitiesComp[nPosCitComp][2]) // Descrição da Cidade	

Return
