#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"       
#INCLUDE "STIPAYGIFTV.CH"
#INCLUDE "STPOS.CH"

Static oModel		:= Nil	//Carrega o model
Static aVps		:= {}	//Array de vales presentes
Static nSaldoVP 	:= 0	//Saldo Vale Presente

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPayGiftV
Selecao de vale presente

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	18/03/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPayGiftV(oPnlAdconal)
Local oPanelMVC		:= STIGetPanel() // Objeto do Panel onde a interface de selecao de clientes sera criada
Local oLblCodigo 	:= Nil           //Objeto de label codigo
Local oGetCodigo 	:= Nil           //Objeto de get codigo
Local nMddCodigo	:= TamSX3('MDD_CODIGO')[1] //Tamanho do campo MDD_CODIGO 
Local cGetCod		:= Space(nMddCodigo)		    //Codigo

Local oLstBGiftV 	:= Nil           //Objeto list box
Local nLstGifTA		:= oPnlAdconal:nHeight/7 //Tamanho: Altura do listbox

Local oMdl			:= Nil           //Model detalhes

Local oBtnOk		:= Nil           //Objeto de button OK
Local oBtnCa		:= Nil           //Objeto de button Cancel

/* Label e Get: Codigo */
oLblCodigo := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0001}, oPnlAdconal,,,,,,.T.,,,,8) //CODIGO
oGetCodigo := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetCod:=u,cGetCod)},oPnlAdconal,100,ALTURAGET,,,,,,,,.T.,,,,,,,,,,"cGetCod")
oLblCodigo:SetCSS( POSCSS (GetClassName(oLblCodigo), CSS_LABEL_FOCAL )) 
oGetCodigo:SetCSS( POSCSS (GetClassName(oGetCodigo), CSS_GET_FOCAL )) 

/* Perdendo o foco do get executa a funcao STIRetVP()  */
oGetCodigo:bLostFocus := { ||  IIF( !Empty(cGetCod) , EVal( { || STIRetVP(oGetCodigo, oLstBGiftV) , cGetCod := Space(nMddCodigo) , oGetCodigo:SetFocus() } ) , ) }

oLstBGiftV := TListBox():Create(oPnlAdconal, POSVERT_PAYLABEL2, POSHOR_PAYCOL1, Nil, /*aPaym*/, LARG_LIST_CONSULT, nLstGifTA,,,,,.T.,,{|| .T. })
oLstBGiftV:SetCSS( POSCSS (GetClassName(oLstBGiftV), CSS_LISTBOX )) 

/* Button: OK */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0002,oPnlAdconal,{|| STIVPConfPay(oPnlAdconal, oGetCodigo) },LARGBTN,ALTURABTN,,,,.T.) //'Efetuar Pagamento'

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,000,STR0003,oPnlAdconal,{|| STIPayCancel(oPnlAdconal) },LARGBTN,ALTURABTN,,,,.T.) //'Cancelar'
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

oGetCodigo:SetFocus()
If GetFocus() <> oGetCodigo:HWND
    oGetCodigo:SetFocus()    
Endif

/* Cria a estrutura do model */
ModelGiftV()
oMdl := oModel:GetModel('GIFTDTL')
oMdl:DeActivate()
oMdl:Activate()

/* Limpa array dos VPs */
aVps := {}

Return .T.

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} ModelDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	18/03/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function ModelGiftV()

Local oStruMst 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela
Local oStruDtl 	:= FWFormModelStruct():New()//Variavel para criar a estrutura da tabela

oModel := MPFormModel():New("STIPayGiftV")
oModel:SetDescription("Vale Presente")

oStruDtl:AddTable("SL4",{"L4_FILIAL"},STR0004) //"Vale Presente"

oStruMst := STIStruMod(oStruMst, "Mst")
oModel:AddFields( 'GIFTMST', Nil, oStruMst)
oModel:GetModel ( 'GIFTMST' ):SetDescription(STR0004) //"Vale Presente"
oModel:SetPrimaryKey({})

oStruDtl := STIStruMod(oStruDtl)
oModel:AddGrid('GIFTDTL','GIFTMST',oStruDtl, Nil, Nil, Nil, Nil, Nil)
oModel:GetModel( 'GIFTDTL' ):SetDescription(STR0004) //"Vale Presente"
oModel:GetModel( 'GIFTDTL' ):SetOptional(.T.)

Return oModel

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIStruMod

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	11/01/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Static Function STIStruMod(oStruMst, cType)

Default oStruMst 	:= Nil
Default cType		:= ""

If cType == 'MST'

	oStruMst:AddField(	STR0005		,; //[01] Titulo do campo
							STR0005		,; //[02] Desc do campo
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
							
Else
	
	oStruMst:AddField(	STR0006		,; //[01] Titulo do campo
							STR0006		,; //[02] Desc do campo
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
	
	oStruMst:AddField(	STR0007	,; //[01] Titulo do campo
							STR0007	,; //[02] Desc do campo
							"L4_COD"	,; //[03] Id do Field
							"C"			,; //[04] Tipo do campo
							15			,; //[05] Tamanho do campo
							0			,; //[06] Decimal do campo
							Nil			,; //[07] Code-block de validacao do campo
							Nil			,; //[08] Code-block de validacao When do campo
							Nil			,; //[09] Lista de valores permitido do campo
							Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
							Nil			,; //[11] Code-block de inicializacao do campo
							Nil			,; //[12] Indica se trata-se de um campo chave
							Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update
							.T.			)  //[14] Indica se o campo e virtual
	
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
EndIf
														
Return oStruMst


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIVPConfPay
Funcao responsavel por confirmar o pagamento do vale presente

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIVPConfPay(oPnlAdconal, oGetCodigo)

Local oMdl 	:= oModel						//Recupera o model ativo
Local oMdlDtl	:= oMdl:GetModel("GIFTDTL")	//Seta o model do master
Local lRet		:= .T.							//Retorno da funcao

If STBVldValVp(oMdlDtl)
	STIAddPay('VP', oMdlDtl, 1, .F., oMdlDtl:GetValue('L4_COD'))
	oPnlAdconal:Hide()
	STIEnblPaymentOptions()
Else
	lRet := .F.
	oGetCodigo:SetFocus()
EndIf

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIRetVP
Adiciona o valor do vale presente

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	18/03/2013
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIRetVP(oGetCodigo, oLstBGiftV)

Local oMdl 	:= oModel						//Recupera o model ativo
Local oMdlDtl	:= oMdl:GetModel("GIFTDTL")	//Seta o model do master
Local nValor	:= 0							//Valor do vale presente
Local lRet		:= .T.							//Variavel de retorno

nValor := STWPayGiftV(oGetCodigo:cText, oMdlDtl)
nSaldoVP := nValor - STBCalcSald("1")

If nSaldoVP <= 0
	nSaldoVP := 0
EndIf 

If nValor > 0
	IIF(oMdlDtl:Length() == 1 .AND. Empty(oMdlDtl:GetValue('L4_DATA')),Nil,oMdlDtl:AddLine(.T.))

	oMdlDtl:LoadValue('L4_COD', oGetCodigo:cText)
	
	//Baixa parcial do vale presente
	If SuperGetMv("MV_LJBXPAR",,.F.)
		If STBCalcSald("1") >= nValor 
			oMdlDtl:LoadValue('L4_VALOR', nValor)
		Else
			oMdlDtl:LoadValue('L4_VALOR', STBCalcSald("1"))	
		EndIf
	Else
		oMdlDtl:LoadValue('L4_VALOR', nValor)
	EndIf	
	
	oMdlDtl:LoadValue('L4_DATA', dDataBase)
	
	Aadd(aVps, AllTrim(oGetCodigo:cText) + '  -  ' + AllTrim(Str(nValor,12,2)))

	oLstBGiftV:SetArray( aVps )
Else
	lRet := .F.	
EndIf


oGetCodigo:SetFocus()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetVPSaldo
Retorna o saldo restante do vale presente

@param   	
@author  	Varejo
@version 	P11.8
@since   	06/01/2015
@return  	nSaldoVP - Retorna o saldo restante do vale presente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetVPSaldo()
If ValType(nSaldoVP) <> "N"
	nSaldoVP := 0
EndIf
Return nSaldoVP

//-------------------------------------------------------------------
/*/{Protheus.doc} STISetVPSaldo
Definir o saldo do vale presente

@param   	
@author  	Varejo
@version 	P11.8
@since   	06/01/2015
@return  	nSaldoVP - Retorna o saldo definido do vale presente
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STISetVPSaldo(nValor)

Default nValor := 0

nSaldoVP := nValor

Return nSaldoVP


