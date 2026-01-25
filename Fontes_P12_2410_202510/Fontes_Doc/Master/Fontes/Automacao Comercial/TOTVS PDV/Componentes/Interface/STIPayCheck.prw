#Include 'Protheus.ch'
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"   
#INCLUDE "STIPAYCHECK.CH"
#INCLUDE "STPOS.CH"


Static lEdit 		:= !(Len(STBGetParc()) > 0)
Static oModel 	:= Nil 								//Utilizada para carregar o model
Static cGetCpf := Space(11) //Cpf

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIPayCheck

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/01/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIPayCheck(oPnlAdconal, bCreatePan)
Local oLblData 		:= Nil //Objeto de Label Data
Local oGetData 		:= Nil //Objeto de Get Data

Local oLblValor		:= Nil //Objeto de Label Valor
Local oGetValor		:= Nil //Objeto de Get Valor

Local oLblParcels	:= Nil //Objeto de Label Parcelas
Local oGetParcels	:= Nil //Objeto de Get Parcelas

Local oBtnOk		:= Nil	//Objeto button
Local oBtnCa		:= Nil	//Objeto button

Local oLblCpf := Nil //Objeto de Label Cpf 
Local oGetCpf := Nil //Objeto de Get Cpf

Local cGetData		:= dDataBase			//DataBase

Local cGetVal		:= STBCalcSald("1")	//Saldo restante do pagamento

Local cGetParc		:= 1					//Parcela

Local lRMS := SuperGetMv('MV_LJRMS',,.F.) .AND. FindFunction('STFCrmRms') //CRM da Rms 

 /* Label e Get: Data */
oLblData := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL1, {||STR0006}, oPnlAdconal,,,,,,.T.,,,,8) //'Data'
oGetData := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetData:=u,cGetData)},oPnlAdconal,LARG_GET_DATE,ALTURAGET,,,,,,,,.T.,,,,,,,,,,,,,,,.T.)

oLblData:SetCSS( POSCSS (GetClassName(oLblData), CSS_LABEL_FOCAL )) 
oGetData:SetCSS( POSCSS (GetClassName(oGetData), CSS_GET_FOCAL )) 

 /* Label e Get: Valor */
oLblValor := TSay():New(POSVERT_PAYLABEL1, POSHOR_PAYCOL2, {||STR0001}, oPnlAdconal,, ,,,,.T.,,,,8) //'Valor'
oGetValor := TGet():New(POSVERT_PAYGET1,POSHOR_PAYCOL2,{|u| If(PCount()>0,cGetVal:=u,cGetVal)},oPnlAdconal,LARG_GET_VALOR,ALTURAGET,"@E 99,999,999.99",,,,,,,.T.,,,,,,,,,,,,,,,.T.)
oLblValor:SetCSS( POSCSS (GetClassName(oLblValor), CSS_LABEL_FOCAL )) 
oGetValor:SetCSS( POSCSS (GetClassName(oGetValor), CSS_GET_FOCAL )) 

/* Label e Get: Parcelas */
oLblParcels := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL1, {||STR0002}, oPnlAdconal,, ,,,,.T.,,,,8) //'Parcelas'
oGetParcels := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL1,{|u| If(PCount()>0,cGetParc:=u,cGetParc)},oPnlAdconal,50,ALTURAGET,"@E 9999",,,,,,,.T.,,,,,,,,,,,,,,,.T.)
oLblParcels:SetCSS( POSCSS (GetClassName(oLblParcels), CSS_LABEL_FOCAL )) 
oGetParcels:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_FOCAL )) 

/* Label e Get: CPF */
If lRMS
	cGetCpf := STFCpfCli()
	oLblCpf := TSay():New(POSVERT_PAYLABEL2, POSHOR_PAYCOL2, {||STR0010}, oPnlAdconal,, ,,,,.T.,,,,8) //'Cpf'
	oGetCpf := TGet():New(POSVERT_PAYGET2,POSHOR_PAYCOL2,{|u| If(PCount()>0,cGetCpf:=u,cGetCpf)},oPnlAdconal,100,ALTURAGET,"@E 99999999999",,,,,,,.T.)
	oLblCpf:SetCSS( POSCSS (GetClassName(oLblParcels), CSS_LABEL_FOCAL )) 
	oGetCpf:SetCSS( POSCSS (GetClassName(oGetParcels), CSS_GET_FOCAL ))
EndIf 

/* Button: Efetuar Pagamento */
oBtnOk := TButton():New(POSVERT_BTNPAY,POSHOR_BTNCONFPAY,STR0003,oPnlAdconal,{|| STICHConfPay(oGetData, oGetValor, oGetParcels, bCreatePan, oPnlAdconal) },LARGBTN,ALTURABTN,,,,.T.) //'Efetuar Pagamento'

/* Button: Cancelar */
oBtnCa	:= TButton():New(POSVERT_BTNPAY,000,STR0004 ,oPnlAdconal,{|| Iif( ExistFunc("STBCancPay"), IIF(STBCancPay(),STIPayCancel(oPnlAdconal),NIL),STIPayCancel(oPnlAdconal)) },LARGBTN,ALTURABTN,,,,.T.)//'Cancelar'
oBtnOk:SetCSS( POSCSS (GetClassName(oBtnOk), CSS_BTN_FOCAL )) 
oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_ATIVO )) 

oGetData:SetFocus()

Return .T.

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} ModelDef

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	01/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function ModelCheck()

Local oStruMst 	:= FWFormModelStruct():New() //Variavel para criar a estrutura da tabela

If ValType(oModel) == 'O'
	oModel:DeActivate()
	oModel := Nil
EndIf

oModel := MPFormModel():New('STIDataCheck')
oModel:SetDescription("Cheque")

oStruMst:AddTable("SL4",{"L4_FILIAL"},STR0008) //"Cheque"

oStruMst := STIStruMod(oStruMst)
oModel:AddFields( 'CHECKMASTER', Nil, oStruMst)

Return oModel

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIStruMod
Estrutura do Model

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	01/03/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function STIStruMod(oStru)

Default oStru := Nil

oStru:AddField(	STR0005		,; //[01] Titulo do campo
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

oStru:AddField(	STR0006		,; //[01] Titulo do campo
					STR0006		,; //[02] Desc do campo
					"L4_DATA"	,; //[03] Id do Field
					"D"			,; //[04] Tipo do campo
					8			,; //[05] Tamanho do campo
					0			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					FwBuildFeature( STRUCT_FEATURE_INIPAD,"dDataBase" ),; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0007		,; //[01] Titulo do campo
					STR0007		,; //[02] Desc do campo
					"L4_PARCELAS"	,; //[03] Id do Field
					"N"				,; //[04] Tipo do campo
					10				,; //[05] Tamanho do campo
					0				,; //[06] Decimal do campo
					Nil				,; //[07] Code-block de validacao do campo
					Nil				,; //[08] Code-block de validacao When do campo
					Nil				,; //[09] Lista de valores permitido do campo
					Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil				,; //[11] Code-block de inicializacao do campo
					Nil				,; //[12] Indica se trata-se de um campo chave
					Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.				)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0001	,; //[01] Titulo do campo
					STR0001	,; //[02] Desc do campo
					"L4_VALOR"	,; //[03] Id do Field
					"N"			,; //[04] Tipo do campo
					16			,; //[05] Tamanho do campo
					2			,; //[06] Decimal do campo
					Nil			,; //[07] Code-block de validacao do campo
					Nil			,; //[08] Code-block de validacao When do campo
					Nil			,; //[09] Lista de valores permitido do campo
					Nil			,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil			,; //[11] Code-block de inicializacao do campo
					Nil			,; //[12] Indica se trata-se de um campo chave
					Nil			,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.			)  //[14] Indica se o campo e virtual

oStru:AddField(	STR0009	,; //[01] Titulo do campo
					STR0009	,; //[02] Desc do campo
					"L4_CODCRM"	,; //[03] Id do Field
					"N"				,; //[04] Tipo do campo
					16				,; //[05] Tamanho do campo
					0				,; //[06] Decimal do campo
					Nil				,; //[07] Code-block de validacao do campo
					Nil				,; //[08] Code-block de validacao When do campo
					Nil				,; //[09] Lista de valores permitido do campo
					Nil				,; //[10] Indica se o campo tem preenchimento obrigatorio
					Nil				,; //[11] Code-block de inicializacao do campo
					Nil				,; //[12] Indica se trata-se de um campo chave
					Nil				,; //[13] Indica se o campo pode receber valor em uma operacao de update.
					.T.				)  //[14] Indica se o campo e virtual

Return oStru

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STICHConfPay
Confirma o pagamento em cheque

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	29/01/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STICHConfPay(oGetData		, oGetValor	, oGetParcels	, bCreatePan	,;
						 oPnlAdconal	)

Local oMdl := Nil //Recupera o model ativo
Local aRetRms := {} //Retorno da integracao de crm da rms 
Local lRMS := SuperGetMv('MV_LJRMS',,.F.) //CRM da Rms 
Local lMobile 	:= STFGetCfg("lMobile" , .F. ) 	//Verifica se e versao Mobile 
Local lShowPnlAdconal	:= .T. //Verifica se exibe painel adicional do cheque

Default oGetData 		:= Nil
Default oGetValor		:= Nil
Default oGetParcels	:= Nil

lMobile := ValType(lMobile) == "L" .AND. lMobile

lShowPnlAdconal	:= !lMobile

If lRMS .AND. FindFunction('STFCrmRms')
	aRetRms := STFCrmRms('CH',IIF(VaÃlType(oGetValor) == 'O', oGetValor:cText, STBCalcSald("1")),,AllTrim(cGetCpf))
Else
	aRetRms := Array(1)
	aRetRms[1] := .T. 
EndIf

If aRetRms[1]

	ModelCheck()
	oMdl := oModel:GetModel("CHECKMASTER")
	 
	oMdl:DeActivate()
	oMdl:Activate()
	
	oMdl:LoadValue("L4_FILIAL", xFilial("SL1"))
	oMdl:LoadValue("L4_DATA", IIF(ValType(oGetData) == 'O', oGetData:cText, dDataBase))
	oMdl:LoadValue("L4_VALOR", IIF(ValType(oGetValor) == 'O', oGetValor:cText, STBCalcSald("1") ) )
	oMdl:LoadValue("L4_PARCELAS", IIF(ValType(oGetParcels) == 'O', oGetParcels:cText, Len(STBGetParc()) ))

	If Len(aRetRms) > 1
		oMdl:LoadValue("L4_CODCRM", aRetRms[3])
	Else
		oMdl:LoadValue("L4_CODCRM", '')
	EndIf
	
	//Verifica se exibe painel adcional do cheque
	If lShowPnlAdconal											    
		STWPayCheck(.T., bCreatePan)
	Else
		//Add o pagamento em cheque sem dados adicionais
		STBInsCheck()
		STIEnblPaymentOptions()
	EndIf	
	
Else
	If ValType(aRetRms[2]) == 'N'
		Alert(STR0011 + ' ' + AllTrim(Str(aRetRms[2],12,2)))
	EndIf
	STIPayCancel()
EndIf

oPnlAdconal:Hide()

Return .T.


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STIGetModel
Get do model de Data, Valor e Parcelas do cheque

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	29/01/2013
@return  	oModel
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STIGetMdl()
Return oModel

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STICheckOrc
Chamada somente quando for importacao de orcamento

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	08/02/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STICheckOrc(dDate, nValor, nParcels)

Local oMdl := Nil //Recupera o model ativo

Default dDate 	:= ''
Default nValor	:= 0
Default nParcels	:= 0

If !Empty(dDate) .AND. nValor > 0 .AND. nParcels > 0

	ModelCheck()
	oMdl := oModel:GetModel("CHECKMASTER")
	 
	oMdl:DeActivate()
	oMdl:Activate()
	
	oMdl:LoadValue("L4_FILIAL", xFilial("SL1"))
	oMdl:LoadValue("L4_DATA", dDate )
	oMdl:LoadValue("L4_VALOR", nValor )
	oMdl:LoadValue("L4_PARCELAS", nParcels )
	
	STWPayCheck(.T., STIGetBlCod())

EndIf

Return .T.

