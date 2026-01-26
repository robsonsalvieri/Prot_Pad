#Include "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"         
#INCLUDE "STIPAYNCCBC.CH"
#INCLUDE "STPOS.CH"

Static oModel		:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPayNCCBC
NCC com codigo de barras
@param   	
@author  	Vendas & CRM
@version 	P12
@since   	06/11/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPayNCCBC(oPnlAdconal)

Local oLbl 			:= Nil              //Objeto do label 
Local oGet 			:= Nil              //Objeto do get 
Local cGetVal		:= Space(40)	 		 //Tamanho do Get Inicial ~ //LOBO 28

Local oBtnOk		:= Nil              //Objeto do botao Ok
Local oBtnCa		:= Nil              //Objeto do botao Cancelar

Default oPnlAdconal := Nil

/* Label: 'NCC Código de Barras' */
oLbl := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0001}, oPnlAdconal,,,,,,.T.,,,,8) //"Nota de Crédito Cod. Barras"

/* Get: NCC Código de Barras */
oGet := TGet():New(POSVERT_PAYGET1 ,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,150,ALTURAGET,"@E "+Replicate("9",Len(cGetVal)) ,,,,,,,.T.)
oGet:SetFocus()
oLbl:SetCSS( POSCSS (GetClassName(oLbl), CSS_LABEL_FOCAL ))
oGet:SetCSS( POSCSS (GetClassName(oGet), CSS_GET_FOCAL )) 

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0002,oPnlAdconal,{|| STINBFind(oGet, oPnlAdconal)},LARGBTN,ALTURABTN,,,,.T.) //'Confirmar'

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,00,STR0003,oPnlAdconal,{|| STIPayCancel(oPnlAdconal) },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar'
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function ModelNCCBC()

Local oStruMst 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela

oModel := MPFormModel():New('STIPayNCCBC')
oModel:SetDescription(STR0004) //"Pagamento Nota de Crédito Cod. Barras"

oStruMst:AddTable("SL4",StrTokArr("L4_FILIAL",""),STR0005) //"Pagamento"

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'NCCBCMASTER', Nil, oStruMst)
oModel:GetModel ( 'NCCBCMASTER' ):SetDescription(STR0006) //"Selecionar Pagamento"

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} STIStruMod

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIStruMod(oStruMst)

Default oStruMst 	:= Nil

oStruMst:AddField(	STR0007		,; // [01] Titulo do campo // "Filial"
						STR0007		,; //[02] Desc do campo // "Filial"
						"L4_FILIAL"	,; //[03] Id do Field
						"C"				,; //[04] Tipo do campo
						8				,; //[05] Tamanho do campo
						0				,; //[06] Decimal do campo
						Nil				,; //[07] Code-block de validacao do campo
						Nil				,; //[08] Code-block de validacao When do campo
						Nil				,; //[09] Lista de valores permitido do campo
						Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil				,; //[11] Code-block de inicializacao do campo
						Nil				,; //[12] Indica se trata-se de um campo chave
						Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
						.T.				)  //[14] Indica se o campo e virtual
						
oStruMst:AddField(	STR0008		,; //[01] Titulo do campo // "Data"
						STR0008		,; //[02] Desc do campo // "Data"
						"L4_DATA"	,; //[03] Id do Field
						"D"			,; //[04] Tipo do campo
						8			,; //[05] Tamanho do campo
						0			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						.T.			,; //[10] Indica se o campo tem preenchimento obrigatorio
						FwBuildFeature( STRUCT_FEATURE_INIPAD,"dDataBase" )			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.F.			)  //[14] Indica se o campo e virtual								


oStruMst:AddField(	STR0009	,; //[01] Titulo do campo   // "Valor"
						STR0009	,; //[02] Desc do campo   // "Valor"
						"L4_VALOR",; //[03] Id do Field
						"N"			,; //[04] Tipo do campo
						16			,; //[05] Tamanho do campo
						2			,; //[06] Decimal do campo
						Nil			,; //[07] Code-block de validacao do campo
						Nil			,; //[08] Code-block de validacao When do campo
						Nil			,; //[09] Lista de valores permitido do campo
						Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
						Nil			,; //[11] Code-block de inicializacao do campo
						Nil			,; //[12] Indica se trata-se de um campo chave
						Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
						.T.			)  //[14] Indica se o campo e virtual
														
Return oStruMst

//-------------------------------------------------------------------
/*/{Protheus.doc} STINBFind
Funcao responsavel por buscar as NCC no server ou armezar a contingencia
caso nao tenha conexao.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STINBFind(oGet, oPnlAdconal)

Local oMdl          := Nil              				// Model do cash
Local oListBox      := STIGetLstB()     				// Objeto list box da tela principal do pagamento
Local oTotal  		:= STFGetTot() 						// Recebe o Objeto totalizador
Local nTotalVend	:= oTotal:GetValue("L1_VLRTOT") 	// Valor total da venda
Local nTamPrefix    := TamSx3("E1_PREFIXO")[1]
Local nTamNumSE1    := TamSx3("E1_NUM")[1]
Local nTamPrfCB 	:= nTamPrefix * 2 					// Mutiplica por 2 o tamanho do prefixo, pois cada caracter do prefixo foi convertido em codigo da tabela ASCII com 2 digitos cada
Local nValNCC       := 0
Local nCount        := 0
Local nNCCUsado   	:= STDGetNCCs("2") 
Local nValorUsado   := 0
Local nPosNCC       := 0
Local aNCCsCli      := {}
Local aNCCsUsadas   := STDGetNCCs("1")
Local cCodBar       := Embaralha(AllTrim(oGet:cText),1)	// Desembaralha
Local cPrefixInf    := ""
Local cNum          := ""
Local cPrefixo      := ""
Local cChaveSE1     := ""
Local lRet          := .F.
Local nSaldoAPag	:= STBCalcSald("1") 				// Valor a pagar
Local nCodASC 		:= 0 								// Codigo da tabela ASCII

STFCleanInterfaceMessage() //Limpa mensagem do rodape

cPrefixInf    := SubStr(cCodBar,1,nTamPrfCB)
cNum          := PadR(SubStr(cCodBar,nTamPrfCB+1,nTamNumSE1),nTamNumSE1)

//Converte o prefixo do titulo, de Codigo ASCII para caracter
For nCount:=1 To Len(cPrefixInf) Step 2
	nCodASC 	:= Val(SubStr(cPrefixInf,nCount,2))
	cPrefixo 	+= CHR(nCodASC)
Next nCount

cChaveSE1 := cPrefixo + cNum + PadR("A",TamSx3("E1_PARCELA")[1]) + "NCC"

nPosNCC := aScan( aNCCsUsadas,{|x| x[9]+x[3]+x[10]+x[11] == cChaveSE1 })

If nPosNCC > 0
	If aNCCsUsadas[nPosNCC,1]
		STFMessage( ProcName(), "STOP", STR0010 ) // "Nota de Crédito já utilizada na venda!"
		STFShowMessage(ProcName())
		lRet := .F.
	Else
		aNCCsUsadas[nPosNCC][1] := .T. //Marca a NCC a ser utilizada
		nValNCC := aNCCsUsadas[nPosNCC][2]
		lRet := .T.
	EndIf
Else
	
	//Busca a NCC na Retaguarda
	lRet := STBRemoteExecute( "STDNBFIND", { cChaveSE1 }, Nil, .F. , @aNCCsCli )
	
	If lRet
		If ValType( aNCCsCli ) == "A" .AND. Len( aNCCsCli ) > 0
		
			/* 
			Posicoes de aNCCs
		
			aNCCs[x,1]  = .F.	// Caso a NCC seja selecionada, este campo recebe TRUE		 
			aNCCs[x,2]  = SE1->E1_SALDO  
			aNCCs[x,3]  = SE1->E1_NUM		
			aNCCs[x,4]  = SE1->E1_EMISSAO
			aNCCs[x,5]  = SE1->(Recno()) 
			aNCCs[x,6]  = SE1->E1_SALDO
			aNCCs[x,7]  = SuperGetMV("MV_MOEDA1")
			aNCCs[x,8]  = SE1->E1_MOEDA
			aNCCs[x,9]  = SE1->E1_PREFIXO	
			aNCCs[x,10] = SE1->E1_PARCELA	 
			aNCCs[x,11] = SE1->E1_TIPO
		
			*/

			nValNCC := aNCCsCli[2]

			Aadd(aNCCsUsadas,aNCCsCli)
			
		Else
		
			STFMessage( ProcName(), "STOP", STR0011 ) // "Nota de Crédito não encontrada ou já utilizada!"
			STFShowMessage(ProcName())
			lRet := .F.
			
		EndIf
	Else
	
		STFMessage( ProcName(), "STOP", STR0011 ) // "Nota de Crédito não encontrada ou já utilizada!"
		STFShowMessage(ProcName())
		lRet := .F.
	
	EndIf

EndIf

If lRet

	If nValNCC > nSaldoAPag // Caso o valor total da NCC selecionada seja maior que o valor a pagar
		nValorUsado := nSaldoAPag
	Else
		nValorUsado := nValNCC
	EndIf
	
	STDSetNCCs("1",aNCCsUsadas)
	
	STDSetNCCs("2",nValorUsado)

	nNCCUsado := nNCCUsado + nValorUsado

	/* Cria estrutura do model */
	ModelNCCBC()
	oMdl := oModel:GetModel("NCCBCMASTER")
	
	/* Desativa e ativa o model */
	oMdl:DeActivate()
	oMdl:Activate()
	
	/* Inclui o valor no model */
	oMdl:LoadValue("L4_DATA", dDataBase)
	oMdl:LoadValue("L4_VALOR", nNCCUsado)
	
	/* Adiciona o pagamento em NCC */
	STIAddPay("CR", oMdl, 1, Nil, Nil, nNCCUsado)
	
	oPnlAdconal:Hide()
	oListBox:SetFocus()
	STIEnblPaymentOptions()
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STDNBFind
Funcao responsavel por buscar as NCC no server ou armezar a contingencia
caso nao tenha conexao.

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDNBFind( cKey )
Local aArea := GetArea()
Local aRet  := {}

DbSelectArea("SE1")
SE1->(DbSetOrder(1))
If DbSeek(xFilial("SE1")+cKey) .AND. SE1->E1_SALDO > 0
	AADD( aRet , .T.)
	AADD( aRet , SE1->E1_SALDO	)
	AADD( aRet , SE1->E1_NUM	)
	AADD( aRet , SE1->E1_EMISSAO)
	AADD( aRet , SE1->(Recno())	)
	AADD( aRet , SE1->E1_SALDO	)
	AADD( aRet , SuperGetMV("MV_MOEDA1"))
	AADD( aRet , SE1->E1_MOEDA	)
	AADD( aRet , SE1->E1_PREFIXO)
	AADD( aRet , SE1->E1_PARCELA)
	AADD( aRet , SE1->E1_TIPO	)
EndIf

RestArea( aArea )

Return aRet


