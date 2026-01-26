#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} WCFieldSet
Classe Linha.

@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCFieldSet

DATA cTitLegen		AS STRING 	//Titulo da legenda de grupo
DATA cWidth			AS STRING 	//Largura do fieldset
DATA cPx			AS STRING 	//Padding do fieldset
DATA cPxLeft		AS STRING 	//Padding-Left do FieldSet
DATA cFormatF		AS STRING 	//Formulario de campos ou nao FORMATADO na horizontal, vertical ou default
DATA aFSComp		AS ARRAY HIDDEN
DATA cIdLegend         AS STRING

METHOD New() Constructor

METHOD setAddCFS()
METHOD setInForm()

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(cTitLegen,cWidth,cPx,cPxLeft,cIdLegend) CLASS WCFieldSet
DEFAULT cTitLegen	:= ""
DEFAULT cWidth		:= ""
DEFAULT cPx			:= ""
DEFAULT cPxLeft		:= ""
DEFAULT cIdLegend          := ""

::cTitLegen	:= cTitLegen
::cWidth	:= cWidth
::cPx		:= cPx
::cPxLeft	:= cPxLeft    
::cFormatF	:= 'H'
::cIdLegend         := cIdLegend

::aFSComp := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Self                
//-------------------------------------------------------------------
/*/{Protheus.doc} WCFieldSet
Seta componente ao FieldSet

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAddCFS(oObj) CLASS WCFieldSet
AaDd(::aFSComp,oObj)
Return           
//-------------------------------------------------------------------
/*/{Protheus.doc} WCFieldSet
Seta se o fieldset sera formatado para formulario de campos

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setInForm(cFormatF) CLASS WCFieldSet
::cFormatF := cFormatF
Return   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³__WCFieldSet³ Autor ³ Totvs			    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function __WCFieldSet
Return