#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} WCPrint
Classe Print.

@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCPrint

DATA cTitle	 	AS STRING
DATA cName	 	AS STRING
DATA cWidth		AS STRING
DATA cLabel		AS STRING
DATA cFileName	AS STRING
DATA cFuncJs		AS STRING
DATA cMsgPlug		AS STRING

METHOD New() Constructor

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(cTitle,cLabel,cName,cFileName,cFuncJs,cWidth, cMsgPlug) CLASS WCPrint
DEFAULT cTitle 		:= ""
DEFAULT cName 		:= ""
DEFAULT cLabel		:= ""
DEFAULT cFileName	:= ""
DEFAULT cFuncJs		:= ""
DEFAULT cWidth		:= ""
DEFAULT cMsgPlug		:= ""

::cTitle	:= cTitle
::cLabel	:= cLabel
::cName		:= cName
::cFileName	:= cFileName
::cFuncJs	:= cFuncJs
::cWidth	:= cWidth
::cMsgPlug := cMsgPlug
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Self   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³__WCPrint ³ Autor ³ Totvs				    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function __WCPrint
Return