#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Classe Linha.

@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCLine

DATA aComponents	AS ARRAY HIDDEN
DATA cNameGroup		AS STRING HIDDEN //Grupo
DATA cTitle			AS STRING HIDDEN //Indicador do titulo do grupo
DATA lHGroup	AS BOOLEAN HIDDEN// Criar Agrupamento com opçao de ocultar
DATA cNomeHGroup		AS STRING HIDDEN //Indicador do titulo do grupo '+' '-'

METHOD New() Constructor

METHOD setAddComp()
METHOD getListComp()

METHOD setGroup()
METHOD getGroup()

METHOD getTitle()

METHOD setHGroup()
METHOD getHGroup()

METHOD setNomeHGr()
METHOD getNomeHGr()


ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New() CLASS WCLine

::aComponents 	:= {}
::cNameGroup	:= ""
::cTitle		:= ""
::lHGroup	:= .F.
::cNomeHGroup := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Self                
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Seta componentes da linha

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAddComp(oObj) CLASS WCLine
LOCAL nI:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Verifica se foi informado componente em Fieldset
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If GetClassName(oObj) == "WCFIELDSET"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Componentes do fiesdset
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nI:=1 To Len(oObj:aFSComp)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Transfere as propriedades do fiedset para o componente
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		oObj:aFSComp[nI]:cTitLegen	:= oObj:cTitLegen
		oObj:aFSComp[nI]:cWidth 	:= oObj:cWidth
		oObj:aFSComp[nI]:cPx		:= oObj:cPx
		oObj:aFSComp[nI]:cPxLeft	:= oObj:cPxLeft
		oObj:aFSComp[nI]:cFormatF	:= oObj:cFormatF
		oObj:aFSComp[nI]:cIdLegend	:= oObj:cIdLegend
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Cria o componente na linha
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		AaDd(::aComponents,oObj:aFSComp[nI])
	Next	
Else
	AaDd(::aComponents,oObj)
EndIf                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return           
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
retorna lista componentes da linha

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getListComp() CLASS WCLine
Return(::aComponents) 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Seta o grupo de linhas com componentes

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setGroup(cNameGroup,cTitle) CLASS WCLine

::cNameGroup := cNameGroup
::cTitle	 := cTitle
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Retorna nome do grupo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getGroup() CLASS WCLine
Return(::cNameGroup)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Retorna titulo do grupo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getTitle() CLASS WCLine
Return(::cTitle)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Define se sera incluido o agrupamento com a opção de Maximinizar ou Min.

@author Rogerio Tabosa
@since 05/02/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD setHGroup() CLASS WCLine
::lHGroup := .T.
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Retorna a flag de agrupamento com opçao de ocultar

@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD getHGroup() CLASS WCLine
Return(::lHGroup)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Define o nome do HiddeGroup

@author Everton Mateus Fernandes
@since 05/02/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD setNomeHGr(cNomeHGroup) CLASS WCLine
DEFAULT cNomeHGroup := ""
::cNomeHGroup := cNomeHGroup
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCLine
Retorna o nome do HiddeGroup

@author Everton Mateus Fernandes
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD getNomeHGr() CLASS WCLine
Return(::cNomeHGroup)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³__WCLine  ³ Autor ³ Totvs				    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function __WCLine
Return