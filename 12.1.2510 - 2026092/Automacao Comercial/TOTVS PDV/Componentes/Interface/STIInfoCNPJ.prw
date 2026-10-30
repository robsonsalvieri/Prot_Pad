#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWInfoCNPJ.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} STICustomerSelection
Funcao responsavel por chamar a troca do painel atual pelo painel de selecao de clientes.

@author Vendas CRM
@since 26/04/2013
@version 11.80

*/
//-------------------------------------------------------------------

Function STIInfoCNPJ(	cCgcCli, cNome, cEnd, lInfoEnd,;
						lTelaFimVnd)

STIExchangePanel( { || STIPanInfoCNPJ(	cCgcCli, cNome, cEnd, lInfoEnd,;
										lTelaFimVnd) } )

STIChangeCssBtn()

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STIPanInfoCNPJ
Funcao responsavel pela criacao do Painel de selecao de clientes.

@author Vendas CRM
@since 26/04/2013
@version 11.80
@return oMainPanel - Objeto contendo o painel principal de selecao de clientes.
*/
//-------------------------------------------------------------------

Static Function STIPanInfoCNPJ(cCgcCli, cNome, cEnd, lInfoEnd,;
								lTelaFimVnd)

Local oPanelMVC  		:= STIGetPanel()				// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta

Local oLblCab			:= Nil								// Objeto do label "Seleção de Cliente"
Local nVertCab			:= oMainPanel:nHeight/100

Local oLblCGC			:= Nil
Local nPosAlt1			:= oMainPanel:nHeight/16.8

Local oCgc				:= Nil								// Objeto para digitar o CGC
Local nPosAlt2			:= oMainPanel:nHeight/12

Local oLblNome			:= Nil
Local nPosAlt3			:= oMainPanel:nHeight/8.4

Local oNome				:= Nil								// Objeto para digitar o Nome do Cliente
Local nPosAlt4			:= oMainPanel:nHeight/7.08

Local oLblEnd				:= Nil
Local nPosAlt5			:= oMainPanel:nHeight/4.4  

Local oEnd				:= Nil								// Objeto para digitar o Endereço do Cli
Local nPosAlt6			:= oMainPanel:nHeight/4	

Local oBtnOk			:= Nil
Local oBtnCPF			:= Nil								// Boão para acionamento do PinPad para digitação

Local nPosHor2			:= oMainPanel:nWidth/2.8

Local oTEF20			:= Nil

Local nOpcDigCPF		:= SuperGetMV("MV_LJDGCPF",,1)		// Forma de digitação do CPF - 1 - Pela tela, 2 - Opção Pelo PinPad

Local bActionOk			:={|| }								//Bloco a ser executado ao clicar no botão 'OK'

Default cCgcCli  	:= SPACE(TamSX3("A1_CGC")[1])
Default cNome    	:= SPACE(TamSX3("A1_NOME")[1])
Default cEnd     	:= SPACE(TamSX3("A1_ENDENT")[1])
Default lInfoEnd	:= .F.
Default lTelaFimVnd	:= .F.

ParamType 0 var  cCgcCli		As Character	Default ""
ParamType 1 var  cNome			As Character	Default ""
ParamType 2 var  cEnd			As Character	Default ""
ParamType 3 var  lInfoEnd		As Logical		Default .F.

// Ativa teclas de atalho
STIBtnActivate()

// Como é a primeira tela , sempre seta que não é recebimento
STISetRecTit(.F.)

//Abre tela para digitar
DEFINE FONT oBold	BOLD
DEFINE FONT oFontText NAME "Courier New" SIZE 09,20

STIChangeCssBtn()

If !STFGetCfg("lUseSat")  	 
	oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0027},oMainPanel,,,,,,.T.,,,,) // "Deseja informar: CPF/CNPJ/PASSAPORTE/RNE no Comprovante de Venda ?"
Else
	oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0008},oMainPanel,,,,,,.T.,,,,) // "Deseja informar o CPF/CNPJ para impressão do Comprovante de Venda?"
EndIf

oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

If !STFGetCfg("lUseSat")
	oLblCGC := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0028},oMainPanel,,,,,,.T.,,,,) // "CPF/CNPJ/PASSAPORTE/RNE"
Else
	oLblCGC := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0002},oMainPanel,,,,,,.T.,,,,) // CPF/CNPJ	
EndIf
oCgc := TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cCgcCli:=u,cCgcCli)},oMainPanel,120,ALTURAGET,"@!",,,,,,,.T.,,,,,,,,,,"cCgcCli")

oLblCGC:SetCSS( POSCSS (GetClassName(oLblCGC), CSS_LABEL_FOCAL )) 
oCgc:SetCSS( POSCSS (GetClassName(oCgc), CSS_GET_FOCAL )) 		

// Verifica se apresenta o botão do PinPad
If nOpcDigCPF == 2
    oTEF20 := STBGetTEF()
	If oTEF20 <> Nil 
		If (ValType(oTef20:oConfig:oComSitef) == "O" .AND. oTef20:oConfig:oComSitef:verPinPad() == 1) .OR. (oTEF20:oConfig:ISCCCD()) .OR. (ExistFunc("LjUsePayHub") .And. LjUsePayHub() .And. oTEF20:oConfig:ISPayHub())
			
			bActionOk := {|| oBtnCPF:Disable() ,cCgcCli := STWDitaCPF(), oMainPanel:Refresh(), IIf(!Empty(cCgcCli) .AND. !lInfoEnd,oBtnOk:SetFocus(),IIF(lInfoEnd .AND. !Empty(cCgcCli),oNome:SetFocus(),Nil)), oBtnCPF:Enable() }
			oBtnCPF := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0022,oMainPanel, bActionOk, LARGBTN,ALTURABTN,,,,.T.) //"CPF via PinPad"
			oBtnCPF:SetCSS( POSCSS (GetClassName(oBtnCPF), CSS_BTN_FOCAL )) 

		EndIf
	EndIf 
Endif

If lInfoEnd
	@ POSVERT_LABEL2,POSHOR_1 SAY   oLblNome VAR STR0009 OF oMainPanel PIXEL //"Nome do Cliente"
	@ POSVERT_GET2,POSHOR_1 MSGET oNome   VAR  cNome    SIZE 120,ALTURAGET FONT oFontText  OF oMainPanel PIXEL

	@ nPosAlt5,POSHOR_1 SAY   oLblEnd VAR STR0004  			   	OF oMainPanel PIXEL //"Endereco"
	@ nPosAlt6,POSHOR_1 MSGET oEnd    VAR cEnd     SIZE 120,ALTURAGET FONT oFontText   OF oMainPanel PIXEL

	oLblNome:SetCSS( POSCSS (GetClassName(oLblNome), CSS_LABEL_FOCAL )) 	
	oNome:SetCSS( POSCSS (GetClassName(oNome), CSS_GET_FOCAL )) 

	oLblEnd:SetCSS( POSCSS (GetClassName(oLblEnd), CSS_LABEL_FOCAL )) 
	oEnd:SetCSS( POSCSS (GetClassName(oEnd), CSS_GET_FOCAL )) 
	//to do: Quando template de Posto deve imprimir Placa/Km no Cupom Fiscal

EndIf

/* parametrizacao para que mostre a Tela de CPF no final do lançamento dos itens*/
oBtnOk := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0014,oMainPanel,;
							{|| Iif(ExistFunc("StiMataObj"),StiMataObj(),Nil), IIF(STICGCConfirm(CCGCCLI, CNOME, CEND, lInfoEnd,Iif(lTelaFimVnd,.F.,)),;
															IIF(lTelaFimVnd, STICallPayment(), .T.), Nil) }, ;
															LARGBTN,ALTURABTN,,,,.T.) //"Informar CPF"

oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 

oCgc:SetFocus()
If GetFocus() <> oCgc:HWND
    oCgc:SetFocus()    
Endif	

Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STIValCGC
Valida Documento do cliente
@param   	ExpC1 - CGC do cliente
@param   	lShowRgIt - exibe tela de registro do item

@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	ExpL1 - Retorno da funcao T ou F
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STICGCConfirm(		CCGCCLI	, CNOME, CEND, lInfoEnd ,;
						lShowRgIt, oCgc)
Local lRet 		:= .T.
Local nCallCPF	:= SuperGetMV("MV_LJDCCLI",,0)	//O momento onde será mostrado o CPF na tela

Default lShowRgIt	:= .T.
Default oCgc = Nil

IF STIValCGC(@CCGCCLI, oCgc) .AND. STIVaCamp(CCGCCLI, CNOME, CEND, lInfoEnd)
	STI7InfCPF(.T.) // Seta para o componente de registro de item que a tela de CPF ja foi chamada
	If Len(Alltrim(cCGCCli)) > 9 
		STDSPBasket("SL1","L1_CGCCLI",cCGCCli)
	Else
		STDSPBasket("SL1","L1_PFISICA",cCGCCli) //Cliente estrangeiro
	EndIf
	If (nCallCPF = 0 .OR. nCallCPF = 1) .OR. (!lShowRgIt .AND. (nCallCPF = 2 .OR. nCallCPF = 3))
		STD7CPFOverReceipt(Alltrim(CCGCCLI),Alltrim(cNome),Alltrim(cEnd))	// Guarda as informacoes digitadas, que serao utilizadas posteriormente, na abertura do cupom
	EndIf
	
	If lShowRgIt
		STIRegItemInterface(.T.) // Chama a tela de registro de item
	EndIf	
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIValCGC
Valida Documento do cliente
@param1   	ExpC1 - CGC do cliente
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	ExpL1 - Retorno da funcao T ou F
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIValCGC(cCgc, oCgc)

Local lRet 		:= .F.									// Retorno da funcao
Local cVerCgc 	:= AllTrim(cCgc)						// CGC do cliente
Local cNumCNPJ  := Space(TamSX3("A1_CGC")[1]) 			// Varivel para armazenar o retorno da funcao CGC
Local nObrigaCPF:= 0									// Qual item obriga informar o CPF

Default cCgc 	:= ""

ParamType 0 var  cCgc 	As Character	Default ""

If !Empty(cVerCgc)
	
	//Retira caracteres que nao sao usados
	cVerCgc := StrTran(cVerCgc,".","")
	cVerCgc := StrTran(cVerCgc,"-","")
	cVerCgc := StrTran(cVerCgc,"/","")
	cVerCgc := StrTran(cVerCgc,"*","")
	cVerCgc := Alltrim(cVerCgc)

	//Valida se o CGC digitado eh valido	
	If CGC(cVerCgc, @cNumCNPJ,.F.) .And. !STWVldNRep(cVerCgc)
		lRet := .T.
		cCgc := cVerCgc
		STFCleanInterfaceMessage()
	ElseIf (!IsNumeric(cVerCgc) .And. Len(cVerCgc) >=5 .And. Len(cVerCgc)<= 9) .And. !STFGetCfg("lUseSat")
		lRet := .T.
		cCgc := cVerCgc
		STFCleanInterfaceMessage()
	Else
		STFMessage("STIValCGC","STOP", STR0029 ) //"CPF/CNPJ/Documento inválido!"
		STFShowMessage("STIValCGC")
		lRet := .F.
		cCgc := Space(18)
		If ValType(oCgc) == 'O'
			oCgc:SetFocus()
		EndIf
	EndIf

Else
	If ExistFunc("Lj950ImpCpf") .And.  Lj950ImpCpf(STDGPBasket("SL1","L1_VLRTOT"),@nObrigaCPF)

		If nObrigaCPF == 1
			STFMessage("STIValCGC_1","POPUP", STR0024 ) // "Segundo legislação é obrigatório informar documento do cliente (CPF/CNPJ)."
		ElseIf nObrigaCPF == 2
			STFMessage("STIValCGC_1","POPUP",STR0025 ) // "É obrigatório informar o CPF/CNPJ devido a venda estar sendo transmitida em contigência, conforme configuração do parâmetro MV_NFCECON"
		ElseIf nObrigaCPF == 3
			STFMessage("STIValCGC_1","POPUP", STR0026 ) // "Conforme configuração no parâmetro MV_LJVLCID é obrigatório informar documento do cliente (CPF/CNPJ)"
		EndIf	

		STFShowMessage("STIValCGC_1")
		cCgc := Space(18)
		lRet := .F.
	Else
		//Se estiver em branco, valida a insercao
		lRet := .T.
		STFCleanInterfaceMessage()
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STIVaCamp
Valida campos
@param1   	ExpC1 - CGC do Cliente
@param2		ExpC2 - Nome do Cliente
@param3		ExpC3 - Endereco
@param4		ExpL1 - Informa Endereco
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	ExpL1 - Retorno da funcao T ou F
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STIVaCamp(cCgc, cNome, cEnd, lInfoEnd)

Local lRet := .T. // Retorno da Função

Default cCgc  := ""
Default cNome := ""
Default cEnd  := ""
Default lInfoEnd := .F.

ParamType 0 var  cCgc 			As Character	Default ""
ParamType 1 var  cNome			As Character	Default ""
ParamType 2 var  cEnd			As Character	Default ""
ParamType 3 var  lInfoEnd		As Logical		Default .F.

STFMessage("STIVaCamp","STOP", STR0007 ) //"Nome/Endereço não informado"

//Quando PAF, verifica Nome e/ou Endereço infomado, obriga informar o CPF/CNPJ
If lInfoEnd
	lRet := !( Empty(cCgc) .AND. (!Empty(cNome) .OR. !Empty(cEnd)) )

	If !lRet
		STFShowMessage("STIVaCamp") 		// "CPF/CNPJ inválido!"
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetCGC
Captura da tela dados do cliente  
@param1   	ExpC1 - CGC do Cliente
@param2		ExpC2 -Nome do Cliente
@param3		ExpC3 - Endereco
@param4		ExpL1 - Informa Endereco			
@author  	Varejo 
@version 	P11.8
@since   	13/06/2012
@return  	ExpC1 - CGC do Cliente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWGetCGC( cCgcCli, cNome, cEnd, lInfoEnd ) 

Local oDlg		:= Nil						// Objeto da Tela
Local oCgc		:= Nil						// Objeto para digitar o CGC
Local oNome		:= Nil						// Objeto para digitar o Nome do Cliente
Local oEnd		:= Nil						// Objeto para digitar o Endereço do Cliente
Local oTPanel		:= Nil                // Cria o Panel para digitacao dos dados
Local oFontText	:= Nil						// Fonte do texto
Local nTamTela	:= 420						// Tamanho padrão da tela
Local nAltBotao	:= 35						// Altura padrão do botão
Local lCont		:= .F.						// Continua apos digitar CGC

Default cCgcCli  	:= SPACE(TamSX3("A1_CGC")[1])
Default cNome    	:= SPACE(TamSX3("A1_NOME")[1])
Default cEnd     	:= SPACE(TamSX3("A1_ENDENT")[1])  
Default lInfoEnd		:= .F.

ParamType 0 var  cCgcCli			As Character	Default ""				
ParamType 1 var  cNome			As Character	Default ""
ParamType 2 var  cEnd			As Character	Default ""
ParamType 3 var  lInfoEnd		As Logical		Default .F.


//Abre tela para digitar
DEFINE FONT oBold	BOLD
DEFINE FONT oFontText NAME "Courier New" SIZE 09,20


//Ajusta Tamanho da Tela e posicao do botao
If lInfoEnd
	nTamTela 	:= 540
	nAltBotao	:= 97
EndIf

	//"INFORME O CPF / CNPJ PARA IMPRESSÃO"
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 323,412 TO nTamTela,738 PIXEL STYLE DS_MODALFRAME STATUS //"INFORME O CPF / CNPJ PARA IMPRESSÃO"
	
	oTPanel := TPanel():New(0,0,"",oDlg,NIL,.T.,.F.,NIL,NIL,170,060,.T.,.F.)
	oTPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	//"Digite abaixo:"
	@ 003,007 SAY   STR0002             SIZE 050, 007 OF oTPanel PIXEL //"CPF/CNPJ"            
	@ 010,007 MSGET oCgc  VAR cCgcCli  SIZE 150,10 FONT oFontText OF oTPanel PIXEL
              
	If lInfoEnd
		@ 023,007 SAY   STR0003            SIZE 050, 007 OF oTPanel PIXEL //"Cliente"
		@ 030,007 MSGET oNome VAR cNome    SIZE 150,10 FONT oFontText OF oTPanel PIXEL
		
		@ 043,007 SAY   STR0004             SIZE 050, 007 OF oTPanel PIXEL //"Endereco" 	
		@ 051,007 MSGET oEnd  VAR cEnd     SIZE 150,10 FONT oFontText OF oTPanel PIXEL
		
		//to do: Quando template de Posto deve imprimir Placa/Km no Cupom Fiscal 
		
		@ 085,007 SAY   STR0005  SIZE 150, 007 COLOR CLR_RED FONT oBold OF oTPanel PIXEL //"Imprime dados no cupom fiscal?"			
	
	EndIf

DEFINE SBUTTON FROM nAltBotao, 104 TYPE 1 ENABLE OF OTPANEL ACTION (LCONT := .T. , IIF( STICGCConfirm(@CCGCCLI, CNOME, CEND, lInfoEnd) ,ODLG:END(),NIL))
DEFINE SBUTTON FROM nAltBotao, 134 TYPE 2 ENABLE OF OTPANEL ACTION (LCONT := .F. ,  ODLG:END() , STI7InfCPF(.T.), STIRegItemInterface(.T.) )						

ACTIVATE MSDIALOG oDlg CENTERED

If !lCont
	cCgcCli  := ""
	cNome := ""
	cEnd  := ""
	//Caso seja Venda Assistida, alimenta variavel de memoria
EndIf 

Return cCgcCli 

//-------------------------------------------------------------------
/*/{Protheus.doc} STWVldNRep
Validar se o usuario esta digitando os mesmos numeros na informacao CPF ou CNPJ
@param1   	ExpC1 - CGC do Cliente
@param2		
@param3		
@param4				
@author  	Varejo 
@version 	P12.1.14
@since   	24/11/2016
@return  	Valor Logico 
@obs     
@sample
/*/
//-------------------------------------------------------------------		
Function STWVldNRep(cCNPJCPF)
Local lRet := .F.
	
	If !(Len(cCNPJCPF)=11 .Or. Len(cCNPJCPF)=14)
		lRet := .T.
	EndIf
	
	// Se repetir todos os numeros informados o retorno sera invalido
	If Repl(Substr(cCNPJCPF,1,1), If(Len(cCNPJCPF) == 11, 11, 14)) == cCNPJCPF
		lRet := .T.       
	Endif

Return(lRet)
