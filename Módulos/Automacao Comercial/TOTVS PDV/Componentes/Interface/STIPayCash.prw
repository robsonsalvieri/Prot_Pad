#Include "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "POSCSS.CH"         
#INCLUDE "STIPAYCASH.CH"
#INCLUDE "STPOS.CH"

Static oModel	:= Nil
Static nVlOrc	:= 0

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPayCash

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPayCash(oPnlAdconal)
Local oLblValor 	:= Nil              //Objeto do label 'Valor do Pagamento'
Local oGetValor 	:= Nil              //Objeto do get 'Valor do Pagamento'
Local cGetVal		:= IIF(nVlOrc == 0,STBCalcSald("1"),nVlOrc)	//Apresenta o saldo restante do pagamento e recebe valor de oGetValor

Local oBtnOk		:= Nil              //Objeto do botao Ok
Local oBtnCa		:= Nil              //Objeto do botao Cancelar

Local lReadOnly		:= FindFunction("STIGetPayRO") .AND. STIGetPayRO()	//indica se os campos de pagamento estão como Somente Leitura (permissão Alterar Parcelas do caixa)

Default oPnlAdconal := Nil

/* Label: 'Valor do Pagamento' */
oLblValor := TSay():New(POSVERT_PAYLABEL1+1, POSHOR_PAYCOL1+5,;
							 {||STR0001}, oPnlAdconal,,,;
							 ,,,.T.,;
							 ,,,8) //'Valor do Pagamento em Dinheiro'

/* Get: Valor */
oGetValor := TGet():New(POSVERT_PAYGET1+1 ,POSHOR_PAYCOL1+5,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,;
									LARG_GET_VALOR,ALTURAGET,"@E 99,999,999,999.99",,,;
									,,,,;
									.T.,,,,,,,lReadOnly,,,,,,,,.T.)									
oGetValor:SetFocus()

oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 
oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_FOCAL )) 

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0002,oPnlAdconal,;
					{|| STICSConfPay(oGetValor, oPnlAdconal)},LARGBTN,ALTURABTN,,;
					,,.T.) //'Efetuar Pagamento'

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,00,STR0003,oPnlAdconal,;
						{|| IIF(ExistFunc("STBCancPay"),IIF(STBCancPay(),STIPayCancel(oPnlAdconal),Nil),STIPayCancel(oPnlAdconal))},LARGBTN,ALTURABTN,,;
						,,.T.) //'Cancelar'

oBtnOk:SetCSS( POSCSS(GetClassName(oBtnOk), CSS_BTN_FOCAL) )
oBtnCa:SetCSS( POSCSS(GetClassName(oBtnCa), CSS_BTN_ATIVO) )

nVlOrc := 0

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelCash

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function ModelCash()

Local oStruMst 	:= FWFormModelStruct():New()

If ValType(oModel) == 'O'
	oModel:DeActivate()
	oModel := Nil
EndIf

oModel := MPFormModel():New('STIPayCash')
oModel:SetDescription(STR0009) //"Pagamento Dinheiro"

oStruMst:AddTable("SL4",{"L4_FILIAL"},STR0004) //"Pagamento"

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'CASHMASTER', Nil, oStruMst)
oModel:GetModel ( 'CASHMASTER' ):SetDescription(STR0005) //"Selecionar Pagamento"

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

oStruMst:AddField(	STR0006		,; //[01] Titulo do campo
						STR0006		,; //[02] Desc do campo
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
						
oStruMst:AddField(	STR0007		,; //[01] Titulo do campo
						STR0007		,; //[02] Desc do campo
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


oStruMst:AddField(	STR0008	,; //[01] Titulo do campo
						STR0008	,; //[02] Desc do campo
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
/*/{Protheus.doc} STICSConfPay
Funcao responsavel por confirmar o pagamento em dinheiro 

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STICSConfPay(oGetValor, oPnlAdconal)

Local oMdl			:= Nil 			//Model do cash
Local oListBox 	:= Nil 	//Objeto list box da tela principal do pagamento 
Local aPgto     := {}
Local lMobile 	:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile

lMobile := ValType(lMobile) == "L" .AND. lMobile

/* Cria estrutura do model */
ModelCash()
oMdl := oModel:GetModel("CASHMASTER")

/* Desativa e ativa o model */
oMdl:DeActivate()
oMdl:Activate()

/* Inclui o valor no model */
oMdl:LoadValue("L4_DATA", dDataBase)
oMdl:LoadValue("L4_VALOR", oGetValor:cText)

/* Adiciona o  */
STIAddPay("R$", oMdl, 1,,,oGetValor:cText, @aPgto)

oPnlAdconal:Hide()

If !lMobile
	oListBox 	:= STIGetLstB()
	oListBox:SetFocus()
EndIf	

STIEnblPaymentOptions()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STICSOrc
Chamada somente quando for importacao de orcamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STICSOrc(dDate, nValor)

Local oObjPanPay := NIL
Local oRaas      := Nil
Local oFidelityC := Nil

nVlOrc		:= nValor

If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
	oRaas := STBGetRaas()
	
	If Valtype(oRaas) == "O" .AND. oRaas:ServiceIsActive("TFC")
		
		oFidelityC := oRaas:GetFidelityCore()
		
		If oFidelityC:ChoseToUse() 
			nVlOrc -= oFidelityC:GetBonus()
		EndIf

	EndIf 
EndIf 

oObjPanPay	:= STIGetPan()

If oObjPanPay == NIL
	STIPayment(.F.)
	oObjPanPay := STIGetPan()
EndIf

STIAddNewPan( oObjPanPay , ,"R$")

Return .T.
