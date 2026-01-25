#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIITEMCHECK.CH"

Static lChkAtiv	:= .F.

//------------------------------------------------------------------------------
/*{Protheus.doc} STIItemCheck
Função para montar tela para conferencia de item
@param   	SL2     
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/21018
@return     lRet
/*/
//------------------------------------------------------------------------------
Function STIItemChk( aSL2, lZeraPay )
Local lRet 			:= .T.
Local aMVLJITOP 	:= StrToKarr(SuperGetMv("MV_LJITOP", ,"*,-,%,?"), ",") // Parametro com os codigos dos caracteres de atalho de operacoes do item no registro do item
Local cAtalhosItem 	:= ""
Local cGetCodProd	:= Space(TamSX3("L1_PRODUTO")[1]) // utiliza tamanho do campo do cabeçalho, pode utilizar código de barras e esse campo ser maior que o L2_PRODUTO e impossibilitar a pesquisa
Local aListItem		:= {}
Local oGetCodProd	:= Nil
Local oLblCodProd	:= Nil
Local oMsgErro		:= Nil
Local oDlgCheck		:= Nil
Local oListCheck	:= Nil
Local oBtnOk		:= Nil
Local oBtnPesq		:= Nil
Local oBtnDelIt		:= Nil
Local oBtnCancel	:= Nil
Local aFontes		:= STFDefFont()
Local nX			:= 0

Default lZeraPay	:= .F.


aListItem	:= STBItLstCk(aSL2)

//Somente abre a tela se tiver item pendente para bipar
For nX := 1 to Len(aListItem)
	If aListItem[nX][6]
		lRet := .F.
		Exit
	EndIf
Next nX

If !lRet	

	//desabilita controles da tela principal. Motivo: Se o usuário utilizar uma tecla de atalho, pode dar erro na tela de conferência de item
	STIBtnDeActivate()
	
	lChkAtiv := .T.
	
	DEFINE MSDIALOG oDlgCheck TITLE STR0001 STYLE DS_MODALFRAME FROM 0,0 TO 650,670 PIXEL OF oMainWnd	//"Conferência de Item"
	@ 08,08 LISTBOX oListCheck FIELDS HEADER "",STR0002, STR0003, STR0004, STR0005,  STR0006  FIELDSIZES 14,15,140,43,43,25 SIZE 320,260 PIXEL FONT aFontes[3] OF oDlgCheck  //"Item" //"Descrição" //"Qtd Orcamento" //"Qtd Conferida" //"Entrega"
	
	oDlgCheck:lEscClose     := .F. //Nao permite sair ao pressionar a tecla ESC.

	oListCheck:SetArray(aListItem)
	oListCheck:bLDblClick := {|| BrwLegenda(STR0007,STR0008,STIItCkLeg()) }	//"Status Conferência"  //"Legenda"
	oListCheck:bLine := {|| {;
			STIItCkCor(aListItem[oListCheck:nAt][6],aListItem[oListCheck:nAt][3]-aListItem[oListCheck:nAt][4],aListItem[oListCheck:nAt][8]),;
			aListItem[oListCheck:nAt][1],;
			aListItem[oListCheck:nAt][2],;
			aListItem[oListCheck:nAt][3],;
			aListItem[oListCheck:nAt][4],;
			aListItem[oListCheck:nAt][5];
	     }}		
	oListCheck:Refresh()
	
	If Len(aMVLJITOP) > 0 .AND. !Empty(aMVLJITOP[1])
		cAtalhosItem	:= STR0009 + " ( "+AllTrim(aMVLJITOP[1])+" ) / " + STR0010		//"Quantidade" //"Código do Produto"
		oLblHelpGet 	:= TSay():New(270,009,{||cAtalhosItem},oDlgCheck,,,,,,.T.,,,,) 
		oLblHelpGet:SetCSS( POSCSS (GetClassName(oLblHelpGet), CSS_LABEL_NORMAL )) 
	EndIf
	
	oLblCodProd := TSay():New(283,009,{|| STR0010 },oDlgCheck,,,,,,.T.,,,,) //"Código do Produto"
	oLblCodProd:SetCSS( POSCSS (GetClassName(oLblCodProd), CSS_LABEL_FOCAL )) 
	
	oMsgErro	:= TSay():New(295,120,{|| Space(50) },oDlgCheck,,,,,,.T.,,,,) 
	oMsgErro:SetCSS( POSCSS (GetClassName(oMsgErro), CSS_LABEL_FOCAL ))
	oMsgErro:lVisible := .F. 
	
	oGetCodProd	:= TGet():New( 292, 009, { | u | If( PCount() == 0, cGetCodProd, cGetCodProd := u ) },oDlgCheck, 110, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGetCodProd",,,,/*lHasButton*/ .T.  )
	oGetCodProd:cF3 := "SB1"
	oGetCodProd:bLostFocus := { ||  IIF(!Empty(cGetCodProd),STBItPesq(@cGetCodProd, @oGetCodProd, @oListCheck, @oMsgErro, @oBtnOk),.T.) }
	oGetCodProd:SetCSS( POSCSS (GetClassName(oGetCodProd), CSS_GET_NORMAL )) 
	oGetCodProd:SetFocus()
	
	oBtnPesq	:= TButton():New( 310,118, STR0012, oDlgCheck,{|| PosSB1(aListItem[oListCheck:nAt][7]), cGetCodProd := IIF(ConPad1(,,,"SB1"),SB1->B1_COD,"") },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Pesquisar" 
	oBtnPesq:SetCSS(  POSCSS (GetClassName(oBtnPesq)    , CSS_BTN_FOCAL ))
	
	oBtnDelIt	:= TButton():New( 310,173, STR0013, oDlgCheck,{|| STBItCkDel(@oListCheck, @oMsgErro) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Cancelar Item"  
	oBtnDelIt:SetCSS(  POSCSS (GetClassName(oBtnDelIt)    , CSS_BTN_FOCAL ))

	oBtnOk		:= TButton():New( 310,225, STR0011, oDlgCheck,{|| lRet := STBItCkOk( oListCheck, oMsgErro, @aSL2, @lZeraPay ), IIF(lRet,Iif(Empty(aSL2),(oDlgCheck:End(),lChkAtiv := .T.,lRet := .F.),(oDlgCheck:End(),lChkAtiv := .F.)),lChkAtiv := .F.) },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Confirmar" 
	oBtnOk:SetCSS(  POSCSS (GetClassName(oBtnOk)    , CSS_BTN_FOCAL ))
	
	oBtnCancel	:= TButton():New( 310,280, STR0014, oDlgCheck, {|| IIf( ApMsgYesNo( STR0015 + Chr(13) + Chr(10)+ STR0016),oDlgCheck:End(),Nil), lChkAtiv := .T. },50,15,,,.F.,.T.,.F.,,.F.,,,.F. )	//"Cancelar" //"Deseja cancelar a conferência de Itens?"	//"(Se confirmado, a importação do orçamento será cancelada)"  
	oBtnCancel:SetCSS(  POSCSS (GetClassName(oBtnOk)    , CSS_BTN_FOCAL ))
	
	ACTIVATE MSDIALOG oDlgCheck CENTERED   
	
	//Habilita controles da tela principal
	STIBtnActivate()
		
EndIf

Return lRet


//------------------------------------------------------------------------------
/*{Protheus.doc} STIItCkLeg
Função para montar legenda de status dos itens
@param   	     
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/2018
@return     aRet
/*/
//------------------------------------------------------------------------------
Static Function STIItCkLeg(  )
Local aRet := {} 

aAdd( aRet,{"BR_VERMELHO"	,STR0017})	//"Pendente conferência"
aAdd( aRet,{"BR_VERDE"		,STR0018})	//"Conferência realizada"
aAdd( aRet,{"BR_AMARELO"	,STR0019})	//"Sem controle de conferência"
aAdd( aRet,{"BR_PRETO"		,STR0020})	//"Cancelado"

Return aRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STIItCkCor
Função para retornar cores da legenda de status dos itens
@param   	lCheck, nQtdPend, lAtivo
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/2018
@return     aRet
/*/
//------------------------------------------------------------------------------
Static Function STIItCkCor( lCheck, nQtdPend, lAtivo )
Local oRet

If !lAtivo
	oRet := LoadBitmap(GetResources(), "BR_PRETO") 		//Cancelado
ElseIf !lCheck 
	oRet := LoadBitmap(GetResources(), "BR_AMARELO")  	//Sem controle de conferência
ElseIf nQtdPend > 0 
	oRet := LoadBitmap(GetResources(), "BR_VERMELHO") 	//Pendente conferência
Else
	oRet := LoadBitmap(GetResources(), "BR_VERDE")	  	//Conferência realizada
EndIf

Return oRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STIItCkAct
Retorna a variável lChkAtiv
@param   	
@author     Fábio S. dos Santos
@version    P12
@since      26/04/2018
@return     lChkAtiv
/*/
//------------------------------------------------------------------------------
Function STIItCkAct()

Return lChkAtiv

//------------------------------------------------------------------------------
/*{Protheus.doc} PosSB1
De acordo com o item posicionado na grid, posiciona na SB1
@param   	
@author     Fábio S. dos Santos
@version    P12
@since      26/04/2018
@return     .T.
/*/
//------------------------------------------------------------------------------
Function PosSB1(cCodProd)
Default cCodProd := ""

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cCodProd))

Return .T.