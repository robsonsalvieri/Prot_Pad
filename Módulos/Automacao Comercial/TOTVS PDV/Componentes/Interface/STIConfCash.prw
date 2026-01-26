#Include 'Protheus.ch'
#include "fwbrowse.ch"
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH" 
#INCLUDE "STICONFCASH.CH" 

Static aBrwContent	:= {}		// Conteudo do Browse
Static oBrwContent	:= Nil
Static aPaym		:= {}
Static nListPos		:= 0
Static lListWhen	:= .T.
Static oViewBkp		:= Nil
Static cPicTotal	:= PesqPict("SL1","L1_VLRTOT")
Static oSayTotal	:= Nil
Static oPayList		:= Nil
Static aNumerario	:= {}		//Variavel responsavel por armazenar as formas de pagamento e seu respectivo valor

Static oValCaixa	:= Nil
Static oValEstac	:= Nil
Static oValPDV		:= Nil
Static oValDtAbert	:= Nil
Static oValAbHora	:= Nil
Static oValDtFech	:= Nil
Static oValFcHora	:= Nil

#DEFINE POS_DESCFP		2
#DEFINE POS_QTDE	 	5
#DEFINE POS_VALDIG		7
#DEFINE POS_VALAPU		8 

//-------------------------------------------------------------------
/*{Protheus.doc} STIConfCash
Relaiza a conferencia de caixa
@param 	cTpOpCl - 1 para abertura de caixa, 2 para fechamento de caixa
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIConfCash()

STIExchangePanel( { || STIPanConfCash() } )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STWConfCash
Relaiza a conferencia de caixa
@param 	cTpOpCl - 1 para abertura de caixa, 2 para fechamento de caixa
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STIPanConfCash()

Local oPanelMVC  		:= STIGetDlg()				// Objeto do Panel onde a interface de selecao de clientes sera criada
Local oMainPanel 		:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) // Painel de Get de Consulta
Local oLblCab			:= Nil
Local oLblPayList		:= NIl
Local oLblValue			:= Nil	
Local oGetValue			:= Nil	
Local nGetValue			:= 0
Local oGroupInf			:= Nil
Local oLblInf			:= Nil
Local oBtnAddPay		:= Nil
Local oBtnConfirm		:= Nil
Local oBtnCa			:= Nil
Local oBtnCancela		:= Nil
Local aPaymOpt			:= {}
Local nX				:= 0
Local lReduZ			:= .F.
Local oReduZ			:= Nil
Local lLeitX			:= .F.
Local oLeitX			:= Nil

oPayList	:= Nil	
aPaym := STDCreatGd()
aNumerario := aClone(aPaym) 

STIBtnDeActivate()

oMainPanel:SetCSS( POSCSS (GetClassName(oMainPanel), CSS_PANEL_CONTEXT ))

For nX := 1 To Len(aPaym)
	Aadd(aPaymOpt,AllTrim(Str(nX))+" - "+aPaym[nX,POS_DESCFP])
Next nX

oLblCab:= TSay():New(POSVERT_CAB,POSHOR_1,{||STR0001},oMainPanel,,,,,,.T.,,,,)  //"Conferência de Caixa"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

oLblPayList := TSay():New(POSVERT_LABEL1,POSHOR_1, {||STR0002}, oMainPanel,,,,,,.T.) //'Selecione a forma de pagamento'
oLblPayList:SetCSS( POSCSS (GetClassName(oLblPayList), CSS_LABEL_FOCAL )) 

oPayList := TListBox():Create(oMainPanel, POSVERT_GET1, POSHOR_1, Nil,aPaymOpt , LARG_LIST_CONSULT , oMainPanel:nHeight/10 ,,,,,.T.,,{|| STIListAction(oGetValue)},,,,{|| lListWhen})
oPayList:SetCSS( POSCSS (GetClassName(oPayList), CSS_LISTBOX )) 

oLblValue := TSay():New(oPanelMVC:nHeight/4.78235,POSHOR_1, {||STR0003}, oMainPanel,,,,,,.T.)  //'Valor'
oLblValue:SetCSS( POSCSS (GetClassName(oLblValue), CSS_LABEL_FOCAL )) 

oGetValue:= TGet():New(	oPanelMVC:nHeight/4.278947,POSHOR_1,{|u| If(PCount()>0,nGetValue:=u,nGetValue)}, ;
							oMainPanel,oPanelMVC:nWidth/6 ,18,cPicTotal,,,,,,,.T.,,,{|| !lListWhen},,,;
							,,,,"nGetValue")
oGetValue:SetCSS( POSCSS (GetClassName(oGetValue), CSS_GET_NORMAL )) 

// Botao Adicionar Pagamento
oBtnAddPay	:= TButton():New(	oPanelMVC:nHeight/4.278947,oPanelMVC:nWidth/5,STR0004,oMainPanel,{ || STIAddListPay(@nGetValue)}, ;
							LARGBTN,20,,,,.T.,,,,{|| !lListWhen}) //"Adicionar Pagamento"
oBtnAddPay:SetCSS( POSCSS (GetClassName(oBtnAddPay), CSS_BTN_NORMAL )) 

oBtnAddPay:bLostFocus := { ||  oPayList:GoTop(), oPayList:SetFocus()}

// Botao Cancelar 
oBtnCa	:= TButton():New(	(oPanelMVC:nHeight/4.278947),oPanelMVC:nWidth/3,STR0023,oMainPanel,{ || STICancAction(@nGetValue) }, ;
							LARGBTN,20,,,,.T.,,,,{|| !lListWhen}) //"Cancelar"
oBtnCa:SetCSS(POSCSS(GetClassName(oBtnCa), CSS_BTN_NORMAL))

oBtnCa:bLostFocus := { ||  oPayList:GoTop(), oPayList:SetFocus()}

oGroupInf := TGroup():New(oPanelMVC:nHeight/3.12692,POSHOR_1,oPanelMVC:nHeight/2.71,oPanelMVC:nWidth/2.0645,'',oMainPanel,,5,.T.)

oLblInf := TSay():New(oPanelMVC:nHeight/3.011111,POSHOR_1+50, {||STR0005+CRLF+; //'Para alterar um valor já incluido na conferência, selecione a'
										'        '+STR0006}, oGroupInf,,,,,,.T.,,,,80)  //'mesma forma de pagamento e altere o valor'
oLblInf:SetCSS( POSCSS (GetClassName(oLblInf), CSS_LABEL_FOCAL )) 

//Valido se é NFCE ou SAT e não apresento as opções
If !(STFGetCfg("lUseSAT",.F.) .Or. STFGetCfg("lUseNFCE",.F.))
	//Leitura X
	oLeitX := TCheckBox():New(POSVERT_BTNFOCAL+5,POSHOR_1,STR0026,{|| lLeitX },oGroupInf,80,,,{|| (lLeitX := VldLeitX(lLeitX),oLeitX:Refresh())}) //Leitura X

	//Redução Z
	oReduZ := TCheckBox():New(POSVERT_BTNFOCAL+5,POSHOR_1+60,STR0027,{|| lReduZ} ,oGroupInf,80,,,{|| (lReduZ := STVldRedZ(lReduZ),oReduZ:Refresh())}) //Redução Z

EndIf

//Botao Cancelar Conferencia
oBtnCancela	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL-90,STR0023,oMainPanel,{||STICancelConference(oMainPanel)}, ; //"Cancelar"
							LARGBTN,ALTURABTN,,,,.T.)							
oBtnCancela:SetCSS(POSCSS(GetClassName(oBtnCancela), CSS_BTN_FOCAL))

//Botao Confirmar Conferencia
oBtnConfirm	:= TButton():New(	POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,STR0007,oMainPanel,{||STIConfirmConference(lLeitX,lReduZ,oMainPanel)}, ; //"Confirmar"
							LARGBTN,ALTURABTN,,,,.T.)
oBtnConfirm:SetCSS( POSCSS (GetClassName(oBtnConfirm), CSS_BTN_FOCAL )) 
	
STIRightPanel()

oPayList:GoTop()
oPayList:SetFocus()


Return oMainPanel

//-------------------------------------------------------------------
/*{Protheus.doc} STIRightPanel
Relaiza a conferencia de caixa
@param 	cTpOpCl - 1 para abertura de caixa, 2 para fechamento de caixa
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIRightPanel()

Local oViewRight:= STIGetRDlg()
Local oTop		:= Nil //Objeto para cabecalho
Local oContent	:= Nil //Objeto para itens
Local oBottom	:= Nil //Objeto para rodape

oViewBkp := oViewRight

oViewRight:FreeChildren()

@ 000,000 BITMAP oTop RESOURCE "x.png" NOBORDER SIZE 000,130 OF oViewRight ADJUST PIXEL
oTop:Align := CONTROL_ALIGN_TOP
oTop:SetCSS( POSCSS (GetClassName(oTop), CSS_PANEL_HEADER )) 
oTop:ReadClientCoors(.T.,.T.)

STICab( oTop )
	
@ 000,000 BITMAP oBottom RESOURCE "x.png" NOBORDER SIZE 000,055 OF oViewRight ADJUST PIXEL
oBottom:Align := CONTROL_ALIGN_BOTTOM
oBottom:SetCSS( POSCSS (GetClassName(oBottom), CSS_PANEL_FOOTER )) 
oBottom:ReadClientCoors(.T.,.T.)

STIRodape( oBottom )

@ 000,000 BITMAP oContent RESOURCE "x.png" NOBORDER SIZE 000,000 OF oViewRight ADJUST PIXEL
oContent:Align := CONTROL_ALIGN_ALLCLIENT
oContent:ReadClientCoors(.T.,.T.)		

STIItens( oContent ) 

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STICab
Cabeçalho da tela

@param   	
@author  Varejo
@version P11.8
@since   25/04/2013
@return  
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STICab( o )

Local oLblCab		:= Nil			//Objeto label
Local oLblCaixa		:= Nil
Local oLblEstac		:= Nil
Local oLblPDV		:= Nil
Local oLblCxGeral	:= Nil
Local oValCxGeral	:= Nil
Local oLblEmp		:= Nil
Local oValEmp		:= Nil
Local oLblCab2		:= Nil
Local oLblCab3		:= Nil
Local oLblDtAbert	:= Nil
Local oLblAbHora	:= Nil
Local oLblDtFech	:= Nil
Local oLblFcHora	:= Nil
Local aDtConf		:= STDDtAbCx() //Informacoes de abertura e fechamento do caixa
Local oFontTxt 		:= TFont():New('Arial',,-20,.T.)
Local aStation		:= STBInfoEst(	1, .T. ) 

oLblCab := TSay():New(10, 10, {||STR0008}, o,,oFontTxt,,,,.T.,,,100,)  //"Dados da Estação"
oLblCab:SetCSS( POSCSS (GetClassName(oLblCab), CSS_BREADCUMB )) 

/* Caixa */

oLblCaixa := TSay():New(30, 10, {||STR0009}, o,,oFontTxt,,,,.T.,,,100,)  //"Caixa"
oLblCaixa:SetCSS( POSCSS (GetClassName(oLblCaixa), CSS_LABEL_NORMAL )) 

oValCaixa := TSay():New(40, 10, {|| aStation[1]}, o,,oFontTxt,,,,.T.,,,100,)
oValCaixa:SetCSS( POSCSS (GetClassName(oValCaixa), CSS_LABEL_FOCAL )) 

/* Estação */

oLblEstac := TSay():New(30, 50, {||STR0010}, o,,oFontTxt,,,,.T.,,,100,)  //"Estação"
oLblEstac:SetCSS( POSCSS (GetClassName(oLblEstac), CSS_LABEL_NORMAL )) 

oValEstac := TSay():New(40, 50, {|| aStation[2]}, o,,oFontTxt,,,,.T.,,,100,)
oValEstac:SetCSS( POSCSS (GetClassName(oValEstac), CSS_LABEL_FOCAL )) 

/* PDV */

oLblPDV := TSay():New(30, 90, {||STR0011}, o,,oFontTxt,,,,.T.,,,100,)  //"PDV"
oLblPDV:SetCSS( POSCSS (GetClassName(oLblPDV), CSS_LABEL_NORMAL )) 

oValPDV := TSay():New(40, 90, {|| aStation[4]}, o,,oFontTxt,,,,.T.,,,100,)
oValPDV:SetCSS( POSCSS (GetClassName(oValPDV), CSS_LABEL_FOCAL )) 

/* Caixa Geral */

oLblCxGeral := TSay():New(30, 120, {||STR0012}, o,,oFontTxt,,,,.T.,,,100,)  //"Caixa Geral"
oLblCxGeral:SetCSS( POSCSS (GetClassName(oLblCxGeral), CSS_LABEL_NORMAL )) 

oValCxGeral := TSay():New(40, 120, {|| aStation[1]}, o,,oFontTxt,,,,.T.,,,100,)
oValCxGeral:SetCSS( POSCSS (GetClassName(oValCxGeral), CSS_LABEL_FOCAL )) 

/* Emp Filial */

oLblEmp := TSay():New(30, 170, {||STR0013}, o,,oFontTxt,,,,.T.,,,100,)  //"Empresa / Filial"
oLblEmp:SetCSS( POSCSS (GetClassName(oLblEmp), CSS_LABEL_NORMAL )) 

oValEmp := TSay():New(40, 170, {|| cEmpAnt+" / "+cFilAnt}, o,,oFontTxt,,,,.T.,,,100,)
oValEmp:SetCSS( POSCSS (GetClassName(oValEmp), CSS_LABEL_FOCAL )) 

/*Abertura */

oLblCab2:= TSay():New(70, 10, {||STR0014}, o,,oFontTxt,,,,.T.,,,100,)  //"Abertura"
oLblCab2:SetCSS( POSCSS (GetClassName(oLblCab2), CSS_BREADCUMB )) 

oLblDtAbert := TSay():New(90, 10, {||STR0015}, o,,oFontTxt,,,,.T.,,,100,)  //"Data"
oLblDtAbert:SetCSS( POSCSS (GetClassName(oLblDtAbert), CSS_LABEL_NORMAL )) 

oValDtAbert := TSay():New(100, 10, {||aDtConf[1]}, o,,oFontTxt,,,,.T.,,,100,)
oValDtAbert:SetCSS( POSCSS (GetClassName(oValDtAbert), CSS_LABEL_FOCAL )) 

oLblAbHora := TSay():New(90, 60, {||STR0016}, o,,oFontTxt,,,,.T.,,,100,)  //"Hora"
oLblAbHora:SetCSS( POSCSS (GetClassName(oLblAbHora), CSS_LABEL_NORMAL )) 

oValAbHora := TSay():New(100, 60, {||aDtConf[2]}, o,,oFontTxt,,,,.T.,,,100,)
oValAbHora:SetCSS( POSCSS (GetClassName(oValAbHora), CSS_LABEL_FOCAL )) 

/* Fechamento */

oLblCab3:= TSay():New(70, 170, {||STR0017}, o,,oFontTxt,,,,.T.,,,100,)  //"Fechamento"
oLblCab3:SetCSS( POSCSS (GetClassName(oLblCab3), CSS_BREADCUMB )) 

oLblDtFech := TSay():New(90, 170, {||STR0015}, o,,oFontTxt,,,,.T.,,,100,)  //"Data"
oLblDtFech:SetCSS( POSCSS (GetClassName(oLblDtFech), CSS_LABEL_NORMAL )) 

oValDtFech := TSay():New(100, 170, {|| dDataBase }, o,,oFontTxt,,,,.T.,,,100,)
oValDtFech:SetCSS( POSCSS (GetClassName(oValDtFech), CSS_LABEL_FOCAL )) 

oLblFcHora := TSay():New(90, 220, {||STR0016}, o,,oFontTxt,,,,.T.,,,100,)  //"Hora"
oLblFcHora:SetCSS( POSCSS (GetClassName(oLblFcHora), CSS_LABEL_NORMAL )) 

oValFcHora := TSay():New(100, 220, {||AllTrim(Left(Time(),5))}, o,,oFontTxt,,,,.T.,,,100,)
oValFcHora:SetCSS( POSCSS (GetClassName(oValFcHora), CSS_LABEL_FOCAL )) 

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STIItens
Criação do grid dos itens

@param   	
@author  Varejo
@version P11.8
@since   25/04/2013
@return  
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STIItens( o )

Local oContent	//Conteudo do css
Local oView			:= FwLoadView("STIPosMain")
Local oColumn		:= Nil
Local nX			:= 0
Local lConfCega		:= SuperGetMV("MV_LJEXAPU",.T.,.F.) == .F.

aBrwContent := {} // zera a matriz para evitar duplicidade de informações
For nX := 1 To Len(aPaym)
	aAdd(aBrwContent,{aPaym[nX,POS_DESCFP],aPaym[nX,POS_QTDE],AllTrim(Transform(aPaym[nX,POS_VALAPU],cPicTotal)),AllTrim(Transform(0,cPicTotal))})
Next nX

oContent := POSBrwContainer(o)

oView:oModel:SetOperation(4)
oView:oModel:Activate()

DEFINE FWBROWSE oBrwContent DATA ARRAY ARRAY aBrwContent NO LOCATE NO CONFIG NO REPORT OF oContent
	
	oBrwContent:nRowHeight := 30
	oBrwContent:SetVScroll(.F.)

	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][1] } 	TITLE STR0018 	SIZE 015 OF oBrwContent  //"Forma de Pagamento"
	
	If !lConfCega
		ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt][2] } 	TITLE STR0019	SIZE 005 OF oBrwContent  //"Qtd."  
		ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt,3] } TITLE STR0020	SIZE 005 OF oBrwContent  //"Valor Apurado"
	EndIf
	ADD COLUMN oColumn DATA {|| aBrwContent[oBrwContent:nAt,4] } 	TITLE STR0021	SIZE 005 OF oBrwContent  //"Valor Informado"

ACTIVATE FWBROWSE oBrwContent

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} STIRodape
Criação das barra dos totalizadores

@param   	
@author  Varejo
@version P11.8
@since   25/04/2013
@return  
@obs     
@sample
*/
//-------------------------------------------------------------------
Static Function STIRodape( o )

Local nTop := 005
Local oSay

nTop := 006

@ nTop,o:nWidth/2-75 SAY oSay PROMPT STR0022 SIZE o:nWidth/2-35,40 OF o PIXEL HTML  //"Total"
oSay:SetCSS( POSCSS (GetClassName(oSay), CSS_LABEL_NORMAL )) 

nTop += 10

@ nTop,o:nWidth/2-120 SAY oSayTotal PROMPT AllTrim(Str(0,12,2)) SIZE 100,40 RIGHT OF o PIXEL HTML
oSayTotal:SetCSS( POSCSS (GetClassName(oSayTotal), CSS_LABEL_TOTAL )) 

Return .T.


//-------------------------------------------------------------------
/*{Protheus.doc} STIListAction
Indica a opcao selecionada no listbox e o desativa e habilita o get e o botao para adicionar pagamentos.

@param 	oGetValue - Get do valor de pagamento.
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIListAction(oGetValue)

lListWhen := .F.
oGetValue:SetFocus()
nListPos := oPayList:nAt

Return


//-------------------------------------------------------------------
/*{Protheus.doc} STICancAction
Cancela a insercao do pagamento e foca no list

@param 	oGetValue - Get do valor de pagamento.
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STICancAction(oGetValue)

Default oGetValue := Nil

lListWhen := .T.
oPayList:GoTop()
oPayList:SetFocus()

Return


//-------------------------------------------------------------------
/*{Protheus.doc} STIListAction
Indica a opcao selecionada no listbox e o desativa e habilita o get e o botao para adicionar pagamentos.

@param 	oGetValue - Get do valor de pagamento.
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIAddListPay(nGetValue)
Local nX 		:= 0
Local nTotal	:= 0

If !(AllTrim(aBrwContent[nListPos,1]) == AllTrim(aPaym[nListPos,2]))
	nListPos:= aScan(aBrwContent, {|x| AllTrim(x[1])== AllTrim(aPaym[nListPos,2]) })
Endif 

aBrwContent[nListPos,4] := AllTrim(Transform(nGetValue,cPicTotal))


oBrwContent:SetArray(aBrwContent)
oBrwContent:Refresh(.T.)

nGetValue := 0
nListPos  := 0
lListWhen := .T.

oPayList:SetFocus()

For nX := 1 To Len(aBrwContent)
	nTotal += Val(StrTran(SubStr(aBrwContent[nX,4], 1, Len(aBrwContent[nX,4]) - 3),'.','') + '.' + SubStr(aBrwContent[nX,4],Len(aBrwContent[nX,4]) - 1, 2)) 	
Next nX

oSayTotal:SetText(AllTrim(Transform(nTotal,cPicTotal)))

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STIConfirmConference
Indica a opcao selecionada no listbox e o desativa e habilita o get e o botao para adicionar pagamentos.

@param 		oGetValue - Get do valor de pagamento.
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	lRet - Retorna se realizou a conferencia
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIConfirmConference(lLeitX, lReduZ,oMainPanel)
Local nX 			:= 0
Local cTexto		:= ''
Local lStiRelApu	:= ExistBlock("STRECFCX") 		//PE para impressão de relatorio
Local lStFiCfCx		:= ExistBlock("STFICFCX")		//PE para execução após finalização do processo de conferencia
Local nPosaPaym		:= 0 							

Default lLeitX		:= .F.
Default lReduZ		:= .F.
Default oMainPanel 	:= Nil

If ApMsgYesNo(STR0031) //#"Deseja realmente processar a conferência de caixa?" 
	If STWPOSCloseCash() 
		/* Passo os valores digitados que estao contidos no Browse para o Array de pagamentos para posteriormente gravar as informacoes */
		For nX := 1 To Len(aPaym)
			nPosaPaym:= aScan(aBrwContent, {|x| AllTrim(x[1]) == AllTrim(aPaym[nX][2]) })
			aPaym[nX,POS_VALDIG] := StrTran(SubStr(aBrwContent[nPosaPaym,4], 1, Len(aBrwContent[nPosaPaym,4]) - 3),'.','') + ;
										'.' + SubStr(aBrwContent[nPosaPaym,4],Len(aBrwContent[nPosaPaym,4]) - 1, 2)
		Next
		
		STDGrvSLT(aPaym,dDataBase,.F.)
		
		If lStiRelApu
			cTexto := ExecBlock("STRECFCX", .F., .F., {aPaym,;
														oValCaixa:cCaption,;
														oValEstac:cCaption,;
														oValPDV:cCaption,;
														oValDtAbert:cCaption,;
														oValAbHora:cCaption,;
														oValDtFech:cCaption,;	
														oValFcHora:cCaption,;
														STDGLstNumMov()})														 
		Else
			cTexto := STIRelConf(aPaym) 
		EndIf

		aBrwContent := {}
		aPaym := {}
		
		//Relatorio da conferencia de caixa
		STWManagReportPrint( cTexto ,1 )
		
		//Emite a Leitura X
		If lLeitX
			STBReadingX()
		EndIf
		
		//Emite a Redução Z
		If lReduZ
			STWZReduction(.F.)
		EndIf
		
		STIExchangePanel( { || Iif(ExistFunc("STIMataObj"),STIMataObj(oMainPanel),Nil) ,STIPanOpenCash() } )
		STISetRDlg()
		
		//Seta variavel statica para permitir sair do sistema apos conferencia
		If ExistFunc("STFSetPerExit")
			STFSetPerExit(.T.)
		EndIf	

		If lStFiCfCx
			ExecBlock("STFICFCX", .F., .F.) 
		Endif 

	Else
		STFMessage(ProcName(),"STOP",STR0034) //"O correu um erro ao realizar o fechamento do Caixa!"
		STFShowMessage(ProcName())	
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.doc} STIRelConf
Imprime relatorio gerencial da conferencia de caixa

@param 	aPaym - Parametro das formas de pagto e seus respectivos valores
@author  	Vearejo
@version 	P11.8
@since   	04/04/2012
@return  	.T.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STIRelConf(aPaym)

Local nX 			:= 0								// Variavel de loop
Local cTexto 		:= ''								// Conteudo do relatorio
Local cTotal		:= ''								// Total da Conferência de Caixa
Local lConfApu		:= SuperGetMV("MV_LJEXAPU",.T.,.F.) //exibe a coluna do valor apurado
Local nTotApu		:= 0								// total apurado
Local nTotDig		:= 0								// total digitdo

cTexto := CRLF + CRLF 
cTexto += STR0009 + '.....: ' 	+ oValCaixa:cCaption	+ CRLF  //Caixa
cTexto += STR0010 + '...: '    	+ oValEstac:cCaption	+ CRLF  //Estação
cTexto += STR0011 + '.......: '	+ oValPDV:cCaption		+ CRLF  //PDV
cTexto += STR0014 + '..: ' 		+ oValDtAbert:cCaption	+ ' - ' + STR0016 + ': ' + AllTrim(oValAbHora:cCaption) + CRLF //Abertura //Hora
cTexto += STR0017 + ': ' 		+ oValDtFech:cCaption	+ ' - ' + STR0016 + ': ' + AllTrim(oValFcHora:cCaption) + CRLF //Fechamento //Hora
cTexto += STR0029 + '.: '		+ STDGLstNumMov()		+ CRLF //Movimento
cTexto += CRLF + CRLF
if lConfApu
	cTexto += STR0024 + '!'+ STR0025 + '     !' + STR0036 +'!'+ STR0035 + CRLF //Forma //Desc. Forma //Vl. Digitado/Vl. Apurado
Else 
	cTexto += STR0024 + ' !'+ STR0025 + '              !     ' + STR0003 + CRLF //Forma //Desc. Forma //Valor
EndIf
cTexto += CRLF

For nX := 1 To Len(aPaym)
	if lConfApu
		cTexto += SubStr(aPaym[nX][1],1,5) + '!' + SubStr(aPaym[nX][2],1,17) + '!' + Str(Val(aPaym[nX][7]),9,2) +'!' + Str(aPaym[nX][8],9,2) + CRLF
		nTotApu := nTotApu + aPaym[nX][8]
		nTotDig := nTotDig + Val(aPaym[nX][7])
	Else 
		cTexto += aPaym[nX][1] + '!' + SubStr(aPaym[nX][2],1,22) + Space(3) + '!' + Str(Val(aPaym[nX][7]),10,2) + CRLF
	Endif 
Next nX

cTotal := AllTrim(oSayTotal:cCaption)

cTexto += CRLF + CRLF

If lConfApu
	cTexto += STR0037 + ' :' + Str(nTotApu ,9,2) + CRLF  		//Tot. Apurado
	cTexto += STR0038 + ':' + Str(nTotDig ,9,2) + CRLF + CRLF 	//Tot. Digitado
Else  
	cTexto += STR0022 + '.....: ' + cTotal + Replic("- ",Int((32-Len(cTotal))/2))+Replic(CRLF,2) //Total + Tracejado
Endif 

cTexto += STR0032 + " " + Replic("_",28) + Replic(CRLF,2) //"Ass. Caixa   :"
cTexto += STR0033 + " " + Replic("_",28) + Replic(CRLF,6) //"Ass. Superior:"

Return cTexto

//-------------------------------------------------------------------
/*{Protheus.doc} STVldRedZ
Validador da opcao de processamento da reducao Z

@param		lReduZ - Variavel que indica se será processada a redução Z no final
			do fechamento de caixa
@author  	Vearejo
@version 	P11.8
@since   	25/08/2015
@return  	lReduZ
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STVldRedZ(lReduZ)

// A solicitação da senha do superior ja esta contida na função que realiza a redução Z
lReduz := !lReduz
If lReduZ
	If !ApMsgYesNo(STR0028) //"Deseja realmente processar a Redução Z após a conferência de caixa?"  
		lReduz := .F.
	Endif
Endif

Return lReduz

//-------------------------------------------------------------------
/*{Protheus.doc} VldLeitX
Validador da opcao de processamento da leitura X

@param		lLeitX - Validador que indica se será processada a leitura X no final
			do fechamento de caixa
@author  	Vearejo
@version 	P11.8
@since   	25/08/2015
@return  	lLeitX
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function VldLeitX(lLeitX)

lLeitX := !lLeitX
If lLeitX
	If !STFProFile(21)[1] //Leitura X?
		lLeitX := .F.
	Endif
Endif

Return lLeitX

//-------------------------------------------------------------------
/*{Protheus.doc} STICancelConference
Tela para cancelamento de conferencia de caixa.

@param 		oMainPanel, Objeto, contem a tela de conferencia de caixa. 
@author  	Varejo
@version 	P11.8
@since   	14/11/2016
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STICancelConference(oMainPanel)

Local lConfirm 		:= .F.
Local lObgFecha		:= SuperGetMv("MV_LJOBGCF",,.T.)	// Obrigatorio o fechamento de caixa.

Default oMainPanel 	:= Nil // objeto da tela quando for WebAgent precisamos matar ele ao cancelar a operação 

If ApMsgYesNo(STR0030) //#"Deseja realmente cancelar a conferência de caixa?" 
	lConfirm := .T.
EndIf

If lConfirm	
	Iif(ExistFunc("STIMataObj"),STIMataObj(oMainPanel),Nil)
	STIRegItemInterface()
	STISetRDlg()
	
	//Seta variavel statica para permitir sair do sistema apos cancelamento da conferencia, caso o parametro MV_LJOBGCF esteja .T. não permite sair do sistema sem realizar a conferencia
	If FindFunction("STFSetPerExit") .AND. !lObgFecha
		STFSetPerExit(.T.)
	EndIf	
EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STICancelConference
Retorna numerario atual armazena na variavel aNumerario


@author  	Lucas Novais (lnovias)
@version 	P12.1.17
@since   	07/11/2018
@return  	aNumerario
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIGetNume()
Return aNumerario
