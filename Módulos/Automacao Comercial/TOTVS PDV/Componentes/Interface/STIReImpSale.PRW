#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIREIMPSALE.CH"

Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

//-------------------------------------------------------------------
/*/{Protheus.doc} STIReimpSale
Chamada Interface Reimpressão de Venda
@param   cGetSale - Numero da Venda
@param   cGetSerie - Série da Venda	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIReimpSale(cGetSale, cGetSerie)

Local nTamDoc := TamSx3("L1_DOC")[1] //Total do documento
Local lUseSat	:= STFGetCfg("lUseSAT",.F.) //utiliza SAT

Default cGetSale := ""
Default cGetSerie := ""

If lUseSat
	nTamDoc := 6
EndIf

//Verifica se não tem  NFCe em aberto

If !Empty(cGetSale) .AND. !Len(AllTrim(cGetSale)) > 6
	cGetSale := Strzero( Val(cGetSale),nTamDoc)
EndIf	

If !Empty(cGetSale)
	STIReSale(cGetSale, cGetSerie)
EndIf
			



Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanReimpSale
Contexto para Reimpressao de Venda

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanReimpSale()

Local oPanSaleRemp	:= Nil 				// Painel Reimpressão de Venda
Local oPanelMVC		:= STIGetPanel() 	// Painel Principal
Local oBtnConfirm	:= Nil				// Botao de confirmação 
Local oBtnCancel	:= Nil
Local oGetDoc		:= Nil				// Get do Doc a ser Reimpresso
Local oLblSerie 	:= NIl
Local oGetSerie		:= NIL
Local lEmitNfce		:= Iif(ExistFunc("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e
Local nGetHeiPerc	:= 90										// Percentual da Altura do Get de Busca	
Local oLblCancel	:= Nil										// Objeto Label do cancelamento
Local cGetSale		:= Space(TamSX3("L1_DOC")[1])			// Conteudo inserido no Get de Cancelamento.
Local cGetSerie		:= STFGetStation("SERIE")
Local lUseSat		:= STFGetCfg("lUseSAT",.F.) //utiliza SAT
Local cTextBtn		:= STR0004 //"Reimprimir NFCe"

If lUseSat
	cTextBtn := StrTran(STR0006,"SAT",cSiglaSat) //"Reimprimir SAT"
EndIf

//Captura o último documento emitido somente se a nfce estiver emitida
If STWPrinterStatus("5") <> 7
//Caputa o numero do ultimo documento emitido
	STWNFCEInfo("2", @cGetSale)
EndIf

If Val(cGetSale) > 0
	cGetSale := PadL(AllTrim(cGetSale), SL1->(TamSX3("L1_DOC")[1]), "0")
Else
	//Caputa o numero do ultimo documento emitido na ultima venda emitida
	cGetSale := STDCSLastSale("L1_DOC", @cGetSerie)
EndIf
/*/
	Panel Abertura de Caixa                  	
/*/
oPanSaleRemp := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)

oSay1	:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanSaleRemp,,,,,,.T.,,,,) //"Confirma a reimpressão do documento?"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 

If lEmitNfce .AND. STFSaleTotal() == 0

	oLblCancel := TSay():New(POSVERT_LABEL1,POSHOR_1,{||STR0002},oPanSaleRemp,,,,,,.T.,,,,) //"Número do documento"
	oLblCancel:SetCSS( POSCSS (GetClassName(oLblCancel), CSS_LABEL_FOCAL )) 	
	
	oGetDoc	:= TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetSale:=u,cGetSale)}, oPanSaleRemp,nGetHeiPerc,,,/*bValid*/,,,,,,.T.,,,,,,,,,,"cGetSale")
	oGetDoc:SetCSS( POSCSS (GetClassName(oGetDoc), CSS_GET_FOCAL ))


	oLblSerie := TSay():New(POSVERT_LABEL1,POSHOR_2,{||STR0003},oPanSaleRemp,,,,,,.T.,,,,) //"Série do documento"
	oLblSerie:SetCSS( POSCSS (GetClassName(oLblCancel), CSS_LABEL_FOCAL )) 	
	
	
	oGetSerie	:= TGet():New(POSVERT_GET1,POSHOR_2,{|u| If(PCount()>0,cGetSerie:=u,cGetSerie)}, oPanSaleRemp,;
							nGetHeiPerc,,,/*bValid*/,;
							,,,,;
							,.T.,,,;
							,,,,;
							/*.F.*/,,,"cGetSerie")
	oGetSerie:SetCSS( POSCSS (GetClassName(oGetDoc), CSS_GET_FOCAL ))
	
	iif (!lUseSat, oGetSerie:Disable(), nil)

EndIf                                                                 

oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,cTextBtn,oPanSaleRemp,{ || STIReimpSale(cGetSale, cGetSerie), STIRegItemInterface()  }, ; //"Reimprimir NFCe" ou "Reimprimir SAT"
							LARGBTN,ALTURABTN,,,,.T.)

oBtnCancel := TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0005,oPanSaleRemp,{ || STIRegItemInterface() }, ; //"Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)
							
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL )) 							
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_ATIVO ))
								
Return oPanSaleRemp



//-------------------------------------------------------------------
/*/{Protheus.doc} STIReSale
Acionado Cancelamento de Venda

@param   
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIReSale(cGetSale, cGetSerie)

Local lUseSat		:= STFGetCfg("lUseSAT",.F.) //utiliza SAT

Default cGetSale 	:= ""
Default cGetSerie	:= ""


If lUseSat
	LJSatReImp( cGetSale, cGetSerie )
Else
	// Função STWNFCEReImp() descontinuada
EndIf	

STIGridCupRefresh() // Sincroniza a Cesta com a interface

STIRegItemInterface()

Return Nil


/*/{Protheus.doc} STIPANRINFCE
	Tela para seleção de cupom nfc-e para reimprimir. Se não informar nada, por default imprime o último
	@type  Function
	@author caio.okamoto
	@since 28/11/2022
	@version 12.1.33
	/*/
Function STIPANRINFCE()

Local oPanReimp		:= Nil 				
Local oPanelMVC		:= STIGetPanel() 	
Local oBtnConfirm	:= Nil				
Local oBtnCancel	:= Nil
Local oLblReImp		:= Nil					
Local oGetDoc		:= Nil				
Local nGetHeiPerc	:= 90							
Local cGetDOC		:= Space(TamSX3("L1_DOC")[1])	
Local cGetSerie		:= STFGetStation("SERIE")
Local oSay1			:= NIL	
Local aInfCupom		:= {} 


cGetDOC := STDCSLastSale("L1_DOC")

oPanReimp := TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2)
oPanReimp:bGotFocus := { ||  STWReaderFocus(.T.) }

oSay1:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oPanReimp,,,,,,.T.,,,,)
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB )) 

oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0004,oPanReimp,{ || IF( STIValNDoc(cGetDOC, cGetSerie, @aInfCupom ),(LjNFCeReImp(aInfCupom),STIEXIT()),oGetDoc:SetFocus())},LARGBTN,ALTURABTN,,,,.T.)
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL ))

oBtnConfirm:SetFocus()

oBtnCancel := TButton():New(	POSVERT_BTNFOCAL,POSHOR_1,STR0005,oPanReimp,{ ||STIEXIT()}, LARGBTN,ALTURABTN,,,,.T.)
oBtnCancel:SetCSS( POSCSS (GetClassName(oBtnCancel), CSS_BTN_NORMAL ))

oBtnCancel:bLostFocus := {|| oBtnConfirm:SetFocus() }

oLblReImp := TSay():New(POSVERT_LABEL1,POSHOR_1,{|| STR0003+Space(10)+STR0002 },oPanReimp,,,,,,.T.,,,,)
oLblReImp:SetCSS( POSCSS (GetClassName(oLblReImp), CSS_LABEL_FOCAL )) 	
	
oGetSerie:= TGet():New(POSVERT_GET1,POSHOR_1,{|u| If(PCount()>0,cGetSerie:=u,cGetSerie)},oPanReimp,nGetHeiPerc-70,,,/*bValid*/,,,,,,.T.,,,,,,,,,,"cGetSerie")
oGetSerie:SetCSS( POSCSS (GetClassName(oGetSerie), CSS_GET_FOCAL ))

oGetDoc	:= TGet():New(POSVERT_GET1,POSHOR_1 + 80,{|u| If(PCount()>0,cGetDOC:=u,cGetDOC)},oPanReimp,nGetHeiPerc,,,/*bValid*/ ,,,,,,.T.,,,,,,,,,,"cGetDOC")
oGetDoc:SetCSS( POSCSS (GetClassName(oGetDoc), CSS_GET_FOCAL ))

oGetDoc:bLostFocus := { || IF( STIValNDoc(cGetDOC, cGetSerie, @aInfCupom ),oBtnConfirm:SetFocus(),oGetDoc:SetFocus()) }

Return oPanReimp

/*/{Protheus.doc} STIREIMPNFCE()
	REIMPRESSÃO DO CUPOM NFC-E PELO TOTVS PDV.
	@type  Function
	@author caio.okamoto
	@since 29/11/2022
	@version 12.1.2210
	/*/
Function STIREIMPNFCE()


STIExchangePanel( { || STIPANRINFCE() } )
	
Return 

/*/{Protheus.doc} STIEXIT()
	SAIDA DA INTERFACE DA REIMPRESSAO
	@type  Function
	@author user
	@since 29/11/2022
	@version 12.1.2210
/*/
Function STIEXIT()

STIExchangePanel( { || STIPanItemRegister() } )

Return 

/*/{Protheus.doc} STIValNDoc
	FAZ DBSEEK NA SL1 PARA VER SE O CUPOM PODE SER REIMPRESSO
	@type  Static Function
	@author caio.okamoto
	@since 29/11/2022
	@version 12.1.33
	@param cDOC, caracter , numero do documento a ser reimpresso
	@param cSerie, caracter , número de série do cupom a ser reimpresso
	@param aInfCupom, array , Retorna array com dados do cupom a ser reimpresso
	@return lRet, lógico, .T. se conseguiu encontrar o cupom a ser reimpresso
/*/
Static Function STIValNDoc(cDOC, cSerie, aInfCupom)
Local aAreaSL1 	:= SL1->(GetArea())	
Local lRet 		:= .F. 

DbSelectArea("SL1")
SL1->(DbSetOrder(2))// L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
SL1->(DbSeek(xFilial("SL1")+PadR(AllTrim(cSerie),TamSX3("L1_SERIE")[1])+PadR(AllTrim(cDOC),TamSX3("L1_DOC")[1])))

lRet:= !SL1->(EOF())  .AND.  !Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_KEYNFCE)

aInfCupom:={}
STFCleanInterfaceMessage()

If lRet
	AADD(aInfCupom, SL1->L1_FILIAL)
	AADD(aInfCupom, SL1->L1_NUM)
	AADD(aInfCupom, SL1->L1_SITUA)
	AADD(aInfCupom, SL1->L1_KEYNFCE)
	AADD(aInfCupom, SL1->L1_DOC)
Else 
	STFMessage(ProcName(), "STOP", STR0007) 
	STFShowMessage(ProcName())
Endif 

RestArea(aAreaSL1)

Return lRet
