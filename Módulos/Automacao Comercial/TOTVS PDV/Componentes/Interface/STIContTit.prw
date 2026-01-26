#Include "PROTHEUS.CH"
#Include "FWEVENTVIEWCONSTS.CH" 
#Include "FWADAPTEREAI.CH"
#Include "FWMVCDEF.CH"
#Include "POSCSS.CH"
#Include "STPOS.CH"
#Include "STICONTTIT.CH"

Static oWFReceipt	:= STIRetObjTit()	//Objeto classe do recebimento
Static nGetVal	:= 0				//Valor a ser pago
Static lIsCont	:= .F.				//E recebimento em contingencia?

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIPanelCont
Chama o painel de recebimento de titulos em contingencia

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIPanelCont()

STIChangeCssBtn()
nGetVal	 := 0 //Zera a vari·vel de recebimento
STIExchangePanel( { ||  STIContTit() } )

Return 


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIContTit

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIContTit()

Local oPanelMVC	:= STIGetPanel()		//Painel principal
Local oPanGetCont	:= Nil					//Objeto do painel

Local cTitulo := STR0004 + STR0005//"TÌtulo: "##"<< N√O INFORMADO >>"


If ValType(oWFReceipt) <> "O"
	oWFReceipt	:= STIRetObjTit()

EndIf
If !Empty(oWFReceipt:cPrefix) .OR. !Empty(oWFReceipt:cNumber) .OR. !Empty(oWFReceipt:cParcel)
	cTitulo := STR0004 + oWFReceipt:cPrefix+"/"+;//"TÌtulo: "
				oWFReceipt:cNumber+"/"+;				// Numero do titulo
				oWFReceipt:cParcel  				// Parcela do titulo
	
EndIf


/* Panel */
oPanGetCont := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)

/* oSay1 - Recebimentos de tÌtulos > Contingencia */
oSay1 := TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanGetCont,,,,,,.T.,,,,) //"Recebimentos de tÌtulos > ContingÍncia"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 

/* oSay2 - TÌtulo */
oSay2 := TSay():New(POSVERT_LABEL1,POSHOR_1,{|| cTitulo},oPanGetCont,,,,,,.T.,,,,)  //"TÌtulo"
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL)) 


/* oSay3 - Valor */
oSay3 := TSay():New(POSVERT_LABEL2,POSHOR_1,{||STR0002},oPanGetCont,,,,,,.T.,,,,)  //"Valor"
oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL )) 

/* Get Valor */
oVal := TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,nGetVal:=u,nGetVal)},oPanGetCont,(oPanelMVC:nWidth / 2) * 0.20,ALTURAGET,"@E 99,999.99",,,,,,,.T.,,,,,,,,,,"nGetVal")
oVal:SetCSS( POSCSS (GetClassName(oVal), CSS_GET_FOCAL )) 

oVal:SetFocus()

/* Efetuar Pagamento */
oButton := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0003,oPanGetCont,{ || STIRecCont() },LARGBTN,ALTURABTN,,,,.T.) //"Efetuar Pagamento"
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL )) 

Return oPanGetCont

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIRecCont
Funcao responsavel gravar em contingencia o recebimento de titulo
@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIRecCont()

Local nValue	:= nGetVal	//Valor do recebimento
Local lRet		:= .F.		//Variavel de retorno da funcao

If ValType(oWFReceipt) <> "O"
	oWFReceipt	:= STIRetObjTit()
EndIf

oWFReceipt:SetContingencyMode(.T.)
oWFReceipt:SetValueContingency(nValue)
STFSetTot( 'L1_VLRTOT', nValue )
STISetRecTit(.T.)
lIsCont := .T.
STIChangeCssBtn()
STIExchangePanel( { || STIPayment() } )

Return lRet

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STIGetIsCont
Retorna a variavel logica dizendo se e ou nao contingencia
@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	lIsCont
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STIGetIsCont()
Return lIsCont

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
/*/{Protheus.doc} STISetIsCont
Seta a variavel lIsCont como .T. ou .F.
@param   	lCont
@author  	Varejo
@version 	P12
@since   	30/03/2012
@return  	.T.
@obs     
@sample
/*/
//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
Function STISetIsCont(lCont)
lIsCont := lCont
Return .T.
