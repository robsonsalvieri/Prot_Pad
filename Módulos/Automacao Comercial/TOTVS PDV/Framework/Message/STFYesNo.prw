#INCLUDE 'PROTHEUS.CH'
#INCLUDE "POSCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STFYESNO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFYesNo
Tela de confirmacao de processos (Sim/Nao)

@param		cMsg			Mensagem da tela
@param		cTitleYes		Titulo do botao de confirmacao
@param		cTitleNo		Titulo do botao de nao confirmacao
@param		bActionYes		Acao do botao de confirmacao
@param		bActionNo		Acao do botao de nao confirmacao
@param		lButYesDef		Foco do botao
@author  	Varejo
@version 	P11.8
@since   	29/06/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFYesNo(cMsg,cTitleYes,cTitleNo,bActionYes,bActionNo,lButYesDef)

Local oPanelMVC 	:= STIGetPanel()	//Painel principal
Local oLblMsg		:= Nil				//Label da mensagem
Local oPanMsg	 	:= TPanel():New(00,00,"",oPanelMVC,,,,,,oPanelMVC:nWidth/2,(oPanelMVC:nHeight)/2) //Criacao do painel da mensagem

Default cMsg 			:= ''
Default cTitleYes		:= ''
Default cTitleNo		:= ''
Default bActionYes	:= {||}
Default bActionNo		:= {||}
Default lButYesDef	:= .F.

oLblMsg := TSay():New(POSVERT_CAB,POSHOR_1,{||cMsg},oPanMsg,,,,,,.T.,,,,) 
oLblMsg:SetCSS( POSCSS(GetClassName(oLblMsg), CSS_BREADCUMB) )

//Button Yes
oButYes := TButton():New(POSVERT_BTNFOCAL,POSHOR_BTNFOCAL,UPPER(cTitleYes),oPanMsg,bActionYes, ;
							LARGBTN,ALTURABTN,,,,.T.)
oButYes:SetCSS( POSCSS (GetClassName(oButYes), CSS_BTN_FOCAL ))

//Button No
oButNo := TButton():New(POSVERT_BTNFOCAL,POSHOR_1,UPPER(cTitleNo),oPanMsg,bActionNo,;
							LARGBTN,ALTURABTN,,,,.T.)
oButNo:SetCSS( POSCSS (GetClassName(oButNo), CSS_BTN_FOCAL )) 

If lButYesDef
	oButYes:SetFocus()
Else
	oButNo:SetFocus()
EndIf

Return oPanMsg



//-------------------------------------------------------------------
/*/{Protheus.doc} STFMsgYesNo
Tela de confirmacao de processos (Sim/Nao)

@param		cMsg			Mensagem da tela
@param		lButYesFocos	Se .T. Foco do botao Yes se .F. foca no Botão No
@author  	Varejo
@version 	P11.8
@since   	29/06/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFMsgYesNo( cMsg , lButYesFocos )

Local oBtnYes               :=  Nil             	//Obj botao sair
Local oBtnNo          		:=  Nil             	//Obj botao opcoes Copiar colar recortar
Local oLstMsg               :=  Nil             	//Obj say mensagem
Local oDlg                  :=  Nil             	//Obj tela
Local oEdit            		:= 	Nil              	//Objeto para texto apresentada na tela
Local lRet						:= .F.					//Retorno da funcao
Local lPermitExit				:= .F.					//Valida se permite sair apenas se clicar nos botoes Sim ou Não

Default cMsg        		:= ""
Default lButYesFocos		:= .F.


DEFINE FONT oFont NAME "Courier New" SIZE 09,20

DEFINE MSDIALOG oDlg TITLE "" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)  //Grafico Radar

oEdit := TSimpleEditor():New(   000     			,000    ,oDlg   ,oDlg:nWidth    ,;
                                oDlg:nHeight     ,       ,.T.    ,   	,;
                                oFont   			,.T.    )

oEdit:TextFormat(2)
oEdit:Load(cMsg)    
oEdit:Align := CONTROL_ALIGN_ALLCLIENT

oBtnYes  	:= TButton():New( 275/2	,300/2	, STR0001 ,oDlg	,{|| lRet := .T. , lPermitExit:= .T. , oDlg:End()  	},45,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Sim"
oBtnYes:SetCSS(  	POSCSS (GetClassName(oBtnYes)    	, CSS_BTN_FOCAL ))

oBtnNo  	:= TButton():New( 275/2	,400/2	, STR0002 ,oDlg	,{|| lRet := .F. , lPermitExit:= .T. , oDlg:End()  	},45,20,,,.F.,.T.,.F.,,.F.,,,.F. )//"Não"
oBtnNo:SetCSS(    POSCSS (GetClassName(oBtnNo) 	 	, CSS_BTN_NORMAL )) 

If lButYesFocos
	oBtnYes:SetFocus()
Else
	oBtnNo:SetFocus()
EndIf

ACTIVATE MSDIALOG oDlg CENTERED VALID lPermitExit

Return lRet


