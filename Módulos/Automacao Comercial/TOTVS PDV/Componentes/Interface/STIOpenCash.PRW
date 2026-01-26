#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH" 
#INCLUDE "STIOPENCASH.CH"
#INCLUDE "STPOS.CH"

Static oChange

//-------------------------------------------------------------------
/*/{Protheus.doc} STIOpenCash
Contexto Abertura de Caixa

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIOpenCash()

Local lOpenCash := STBOpenCash()

If !lOpenCash
	STIExchangePanel( { || STIPanOpenCash(lOpenCash) } )
Else	
	STIBtnActivate()
	STFMessage(ProcName(),"STOP",STR0004) //"Caixa já esta aberto!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	STFShowMessage(ProcName())
	STIRegItemInterface()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STIPanOpenCash
Contexto Abertura de Caixa

@param   	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIPanOpenCash(lOpenCash)
			
Local oPanelMVC		:= STIGetPanel()		//Painel principal do dialog
Local oPanOpenCash 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) //Painel Abertura de Caixa
Local nChange 		:= 0					//Alteracao do conteudo do get
Local nGetVal		:= 0
Local aStation		:= STBInfoEst(	1, .T. )
Local aCaixas		:= STIGetSA6(aStation[1])
Local aAuxCaixas	:= {}
Local nTamSA6		:= 0	
Local cComboCx		:= "" 
Local oSay2			:= NIL
Local oOrigem		:= NIL
Local lAlterCx		:= !(SuperGetMv( "MV_LJALTCX",,.T.)) 
Local oButCan		:= Nil 	//Botao cancelar 
Local lMobile		:= STFGetCfg( "lMobile" , .F. )//Versao Mobile	

Local nCaixas		:= 0
Default lOpenCash := .F.	

lMobile := ValType(lMobile) == "L" .AND. lMobile

If Findfunction( 'STBCashList' ) 
   aAuxCaixas := STBCashList()  
Else
	nTamSA6 :=  At("/", "MV_CXLOJA") -1 
	If nTamSA6 <= 0
		nTamSA6 := SA6->(TamSx3("A6_COD"))[1]
	EndIf
	
	cComboCx := Left(GetMv("MV_CXLOJA"),nTamSA6 )
	
	For nCaixas := 1 to len(aCaixas)
		AADD(aAuxCaixas,aCaixas[nCaixas][1][1])
	Next
EndIf

STIBtnDeActivate()
STIChangeCssBtn()

oSay1	:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001 + " - " + aStation[1]},oPanOpenCash,,,,,,.T.,,,,) //"Abertura de Caixa"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_BREADCUMB ))  


oSay2:= TSay():New(POSVERT_LABEL1,POSHOR_1,{||"Caixa Origem"},oPanOpenCash,,,,,,.T.,,,,)  //"Caixa Origem"
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_FOCAL)) 

oOrigem := TComboBox():Create(oPanOpenCash, {|u| if( Pcount( )>0, cComboCx := u, cComboCx) },  POSVERT_GET1, POSHOR_1, ;
									aAuxCaixas, 160, ALTURAGET,,;
									,,,,;
									.T.,,,,;
									,,,,;
									,cComboCx)
oOrigem:SetCSS( POSCSS (GetClassName(oOrigem), IIF(lMobile ,CSS_COMBOBOX ,CSS_LISTBOX) ))  
oOrigem:lReadOnly := lAlterCx

oSay3	:= TSay():New(POSVERT_LABEL2,POSHOR_1,{||STR0002},oPanOpenCash,,,,,,.T.,,,,) //"Informe o Troco"
oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_FOCAL ))  

oChange := TGet():New(POSVERT_GET2,POSHOR_1,{|u| If(PCount()>0,nGetVal:=u,nGetVal)},oPanOpenCash,90,ALTURAGET,"@E 99,999,999.99",{|| (nGetVal >= 0) },,,,,,.T.,,,,,,,,,,"nGetVal",,,,,.T.)
oChange:SetCSS( POSCSS (GetClassName(oChange), CSS_GET_FOCAL )) 
								
oButton	:= TButton():New(	POSVERT_BTNFOCAL,;
							POSHOR_BTNFOCAL	,;
							STR0003,;
							oPanOpenCash	,;
							{ || IIF( STWOpenSupply(nGetVal, cComboCx, aStation[1],aCaixas,.T.) ,;
							Eval({||STIRegItemInterface(.T.)}),;
							Nil ) },;
							LARGBTN			,;
							ALTURABTN		,;
							,,,.T.,;
							,,,{|| !Empty(cComboCx)})	// Abrir Caixa																																	
							
oButton:SetCSS( POSCSS (GetClassName(oButton), CSS_BTN_FOCAL ))  

If lOpenCash .Or. lMobile  //Somente se o caixa já estiver aberto (???) ou se for Mobile
    oBtnCa := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,STR0005,oPanOpenCash,{|| STIRegItemInterface()}, ; //"Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)

    oBtnCa:SetCSS( POSCSS (GetClassName(oBtnCa), CSS_BTN_NORMAL ))
EndIf 

STIChangeCssBtn()

oChange:SetFocus()

Return(oPanOpenCash)          

//-------------------------------------------------------------------
/*/{Protheus.doc} STIGetCash
Get no objeto text da abertura de caixa

@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetCash()
Return oChange
