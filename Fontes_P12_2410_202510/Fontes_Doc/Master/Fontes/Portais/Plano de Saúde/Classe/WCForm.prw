#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Classe Form.

@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCForm

DATA cName 	 	AS STRING
DATA cAction		AS STRING  HIDDEN
DATA cMethod		AS STRING  HIDDEN
DATA cJsFClick 	AS STRING  HIDDEN
DATA cJsFImp		AS STRING  HIDDEN
DATA cFBack		AS STRING  HIDDEN
DATA cNLinBtn		AS STRING  HIDDEN 
DATA cTitle	 	AS STRING  HIDDEN 
DATA cWidth		AS STRING  HIDDEN 
DATA cAlign		AS STRING  HIDDEN 
DATA lFolder		AS BOOLEAN HIDDEN
DATA aTables		AS ARRAY   HIDDEN
DATA aFieldHidden	AS ARRAY   HIDDEN
DATA cFunc			AS STRING  HIDDEN
DATA aVar			AS ARRAY   HIDDEN
DATA aObrigat		AS ARRAY   HIDDEN
DATA cJsFAgain	AS STRING  HIDDEN
DATA aCustomBtn	AS ARRAY   HIDDEN

METHOD New() Constructor

METHOD setAction()
METHOD getAction()

METHOD setMethod()
METHOD getMethod()

METHOD setWidth()
METHOD getWidth()

METHOD setAlignBtn()
METHOD getAlignBtn()

METHOD setTitle()
METHOD getTitle()

METHOD setAddTables()
METHOD getListTables()

METHOD setAddFieldHidden()
METHOD getListFieldHidden()

METHOD setJsFClick()
METHOD getJsFClick()

METHOD setJsFImp()
METHOD getJsFImp()

METHOD setFBack()
METHOD getFBack()

METHOD setNLinBtn()
METHOD getNLinBtn()

METHOD setIsFolder()
METHOD getIsFolder()

METHOD setFuncLoad()
METHOD getFuncLoad()

METHOD setGlobalVar()
METHOD getGlobalVar()

METHOD setObrigat()
METHOD getObrigat()

METHOD setFAgain()
METHOD getFAgain()

METHOD setACustomBtn()
METHOD getACustomBtn()

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD new(cName) CLASS WCForm
DEFAULT cName := ""

::cName 		:= cName
::cWidth		:= ""
::cAlign		:= ""
::cTitle		:= ""
::cAction		:= ""
::cMethod		:= "post"
::cJsFClick 	:= ""
::cJsFImp 		:= ""
::cFBack 		:= ""
::cNLinBtn		:= ""
::aTables		:= {}
::aFieldHidden  := {}
::cFunc		    := ""
::aVar			:= {}
::aObrigat		:= {}
::aCustomBtn    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Self                
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta a acao do formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAction(cAction) CLASS WCForm
::cAction := cAction
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna a acao do formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD getAction() CLASS WCForm
Return(::cAction) 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta o metodo de envio do formulario POST ou GET

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setMethod(cMethod) CLASS WCForm
::cMethod := cMethod
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna o metodo de envio do formulario POST ou GET

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getMethod() CLASS WCForm
return(::cMethod)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta a lista de tabelas do formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAddTables(oObj) CLASS WCForm
aadd(::aTables,oObj)
return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna a lista de tabelas do formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getListTables() CLASS WCForm
Return(::aTables)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta lista de campos hidden no formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAddFieldHidden(cName,cValue) CLASS WCForm
AaDd(::aFieldHidden,{cName,cValue})
Return                  
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna lista de campos hidden

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getListFieldHidden() CLASS WCForm
Return(::aFieldHidden)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta funcao no onclick para botao de confirmacao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsFClick(cFunc) CLASS WCForm
::cJsFClick := cFunc
Return              
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna funcao no onclick para botao de confirmacao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsFClick() CLASS WCForm
Return(::cJsFClick)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta funcao para botao de impressao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsFImp(cFunc) CLASS WCForm
::cJsFImp := cFunc
Return              
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna funcao para botao de impressao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsFImp() CLASS WCForm
Return(::cJsFImp)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta funcao para botao de voltar (back)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setFBack(cFunc) CLASS WCForm
::cFBack := cFunc
Return         
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna funcao para botao de voltar (back)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getFBack() CLASS WCForm
Return(::cFBack)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta funcao para botao de voltar (back)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setNLinBtn(cNLinBtn) CLASS WCForm
::cNLinBtn := cNLinBtn
Return         
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna funcao para botao de voltar (back)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getNLinBtn() CLASS WCForm
Return(::cNLinBtn)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta que as tabelas do form seram colocadas em folders

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setIsFolder() CLASS WCForm
::lFolder := .t.
return()
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna se as tabelas do form seram colocadas em folder

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getIsFolder() CLASS WCForm
return(::lFolder)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta a tamanho da tabela principal do form

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setWidth(cWidth) CLASS WCForm
::cWidth := cWidth
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna o tamanho da tabela principal

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD getWidth() CLASS WCForm
Return(::cWidth) 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
seta Alinhamento de botoes do form

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAlignBtn(cAlign) CLASS WCForm
::cAlign := cAlign
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna alinhamento de botoes do form

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD getAlignBtn() CLASS WCForm
Return(::cAlign)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta o titulo do formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setTitle(cTitle) CLASS WCForm
::cTitle := cTitle
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
retorna o titulo do formulario

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD getTitle() CLASS WCForm
Return(::cTitle)  

//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta a função de load do form

@author Everton Mateus Fernandes
@since 14/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD setFuncLoad(cFunc) CLASS WCForm
::cFunc := cFunc
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna a função de load do form

@author Everton Mateus Fernandes
@since 14/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD getFuncLoad() CLASS WCForm
Return ::cFunc         
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta  as variáveis globais do form

@author Everton Mateus Fernandes
@since 14/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD setGlobalVar(cVar) CLASS WCForm
aAdd(::aVar,cVar)
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna as variáveis globais do form

@author Everton Mateus Fernandes
@since 14/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD getGlobalVar() CLASS WCForm
Return ::aVar         
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta os campos obrigatórios do form

@author Everton Mateus Fernandes
@since 14/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD setObrigat(cNome,cKeyPress) CLASS WCForm
aAdd(::aObrigat,{cNome,cKeyPress})
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna os campos obrigatórios do form

@author Everton Mateus Fernandes
@since 14/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD getObrigat() CLASS WCForm
Return ::aObrigat         
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta funcao no onclick para botao de Confirmar e Criar Novo
@author Oscar Zanin
@since 14/04/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setFAgain(cFunc) CLASS WCForm
::cJsFAgain := cFunc
Return 
             
//-------------------------------------------------------------------
/*/{Protheus.doc} getFAgain
Retorna funcao no onclick para botao de Confirmar e Criar Novo
@author Oscar Zanin
@since 14/04/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD getFAgain() CLASS WCForm
Return(::cJsFAgain)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Seta botões customizados

@author Karine Riquena Limp
@since 26/12/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setACustomBtn(aCustomBtn) CLASS WCForm
::aCustomBtn := aCustomBtn
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCForm
Retorna botões customizados

@author Karine Riquena Limp
@since 26/12/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD getACustomBtn() CLASS WCForm
Return ::aCustomBtn    
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³__WCForm	    ³ Autor ³ Totvs			    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function __WCForm
Return
