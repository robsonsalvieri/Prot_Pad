#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Classe Componente.
 
@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCComponent
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Tipo de componente C - Combo, F - Field e B - Button
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cTp	 		AS STRING       
DATA cType	 		AS STRING       
DATA cName 			AS STRING
DATA cTitle	 		AS STRING
DATA cSize	 		AS STRING
DATA lNumber     AS BOOLEAN
DATA nMinValue     AS INTEGER
DATA nMaxValue     AS INTEGER
DATA lData     	AS BOOLEAN
DATA lAltGrid    AS BOOLEAN
DATA lDelGrid    AS BOOLEAN
DATA lCboxPes     AS BOOLEAN
DATA lMultiple    AS BOOLEAN
DATA cXS			AS STRING
DATA cSM			AS STRING
DATA cMD			AS STRING
DATA cLG			AS STRING
DATA cHelpBtn		AS STRING HIDDEN	//Help Btn Img 	
DATA cImg			AS STRING HIDDEN 	//Caminho, nome e extensao da img Ex.:"/chk.gif"
DATA lOb			AS BOOLEAN HIDDEN	//Obrigatorio
DATA lDi			AS BOOLEAN HIDDEN	//Disabled
DATA lRO			AS BOOLEAN HIDDEN	//ReadOnly
DATA cCssDiv		AS STRING HIDDEN //CLASSE CSS DA DIV QUE FICA EM VOLTA DE ALGUNS COMPONENTES 
DATA cJSKeyPre		AS STRING HIDDEN	//(Combo e Field)
DATA cJSKeyDown		AS STRING HIDDEN	//(Combo e Field)
DATA cJSBlur		AS STRING HIDDEN	//(Combo e Field)
DATA cJSFocOut		AS STRING HIDDEN	//(Combo e Field)
DATA cJSFocus		AS STRING HIDDEN	//(Combo e Field)
DATA cJSChange		AS STRING HIDDEN	//(Combo e Field)   
DATA cToolTip		AS STRING HIDDEN	//(Combo e Field)
DATA lNewLine		AS BOOLEAN HIDDEN	//Se este componente sera criado em uma linha nova
DATA lDisplay		AS BOOLEAN HIDDEN //Se ativo, mostra o componente (utilizado no popover do botao interrogacao).
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Alinhamento no top ou bottom
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA lTop			AS STRING HIDDEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do Browse Grid
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cWidthBrw		AS STRING HIDDEN 	//Largura do Conteiner DIV do browse
DATA cHeightBrw		AS STRING HIDDEN 	//Altura do Conteiner DIV do browse
DATA cSpaceBrw		AS STRING HIDDEN 	//Espace referente ao obj acima posicionado
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do FieldSet
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cTitLegen	AS STRING HIDDEN 	//Titulo da legenda fieldset
DATA cWidth		AS STRING HIDDEN 	//Largura do fieldset
DATA cPx			AS STRING HIDDEN 	//Padding do fieldset
DATA cPxLeft		AS STRING HIDDEN	//Padding-Left do FieldSet
DATA cFormatF		AS STRING HIDDEN	//Field em formulario
DATA cIdLegend   	AS STRING HIDDEN //id do fieldset
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do Combo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA xSession	 	AS STRING HIDDEN    //HttpSession com dados do combo
DATA lDig			AS BOOLEAN HIDDEN	//Digitacao com pesquisa no combo box

DATA lBoxTxtInf	AS BOOLEAN HIDDEN	//Imprime box ao redor do texto informação

DATA cJsFBtn		AS STRING HIDDEN 	//Inclui um botao ao lado do combo
DATA cJsFBtL		AS STRING HIDDEN 	//Inclui um botao ao lado do combo
DATA cJsHelp		AS STRING HIDDEN 	//Inclui um botao ao lado do combo
DATA cHelp			AS STRING HIDDEN 	//Inclui um help para o combo
DATA lNoIte			AS BOOLEAN HIDDEN	//Se exibe a opcao selecione um item quando disabled
DATA cDefault		AS STRING HIDDEN	//Valor default para o combo
DATA lName			AS STRING HIDDEN	//Se a propriedade para montar o combo pela session sera cName ou cDescription
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do Campo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cMLength		AS STRING HIDDEN
DATA cValue			AS STRING HIDDEN
DATA cJsFF3			AS STRING HIDDEN	//Inclui um F3 ao lado do campo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do Botao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cJsFunc		AS STRING HIDDEN
DATA cAlign			AS STRING HIDDEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do TextInfo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cCss			AS STRING HIDDEN
DATA cText			AS STRING HIDDEN
DATA cWidthTI		AS STRING HIDDEN 	//Largura do Texto informativo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do TextArea
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA cColsArea	AS STRING HIDDEN
DATA cRowsArea	AS STRING HIDDEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Propriedade do Array da Combo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DATA aArrCombo	AS ARRAY HIDDEN

DATA lTagTDIE			AS STRING HIDDEN	//Se a propriedade para montar o combo pela session sera cName ou cDescription
DATA cImgWidth	AS STRING HIDDEN
DATA cImgHeight	AS STRING HIDDEN

DATA lOpenGrp	AS BOOLEAN HIDDEN //Informa se o componente deve abrir um grupo
DATA lCloseGrp	AS BOOLEAN HIDDEN //Informa se o componente deve fechar um grupo
DATA aHeader	AS ARRAY HIDDEN // aHeader para o componente browse
DATA aCols 	AS ARRAY HIDDEN // aCols para o componente browse
DATA cPlaceHolder AS STRING HIDDEN

DATA aArrRadio	AS ARRAY HIDDEN

DATA lInlineB   AS BOOLEAN HIDDEN //INFORMA SE O BOTÃO FICA NA MESMA LINHA DOS CAMPOS
DATA lCustom    AS BOOLEAN HIDDEN //informa se é um componente customizado (fábrica)

DATA aListOpt	AS ARRAY HIDDEN //lista de opções no botão 

DATA lTagInput	AS BOOLEAN HIDDEN //indica se é campo tag input 

DATA lNaoVrRep	AS BOOLEAN HIDDEN //indica se é campo tag input 

METHOD New() Constructor

METHOD setType()
METHOD getType()

METHOD setJSKeyPre()
METHOD getJSKeyPre()

METHOD setJSKeyDown()
METHOD getJSKeyDown()

METHOD setJSBlur()
METHOD getJSBlur()

METHOD setJSFocOut()
METHOD getJSFocOut()


METHOD setJSHelp()
METHOD getJSHelp()

METHOD setJSFocus()
METHOD getJSFocus()
                
METHOD setJsFBtL()
METHOD getJsFBtL()

METHOD setJSChange()
METHOD getJSChange()

METHOD setSession()
METHOD getSession()

METHOD setDig()
METHOD getDig()

METHOD setNoIte()
METHOD getNoIte()

METHOD setJsFBtn()
METHOD getJsFBtn()

METHOD setHelp()
METHOD getHelp()

METHOD setMLength()
METHOD getMLength()

METHOD setValue()
METHOD getValue()

METHOD setDefCB()
METHOD getDefCB()

METHOD setJsFF3()
METHOD getJsFF3()

METHOD setJsFunc()
METHOD getJsFunc()

METHOD setNewLine()
METHOD getNewLine()

METHOD setObrigat()
METHOD getObrigat()

METHOD setDisable()
METHOD getDisable()

METHOD setReadOnly()
METHOD getReadOnly()

METHOD getToolTip()
METHOD setToolTip()

METHOD setHelpBtn()
METHOD getHelpBtn()

METHOD setImgBtn()
METHOD getImgBtn()

METHOD setBrWidth()
METHOD getBrWidth()

METHOD setBrHeight()
METHOD getBrHeight()

METHOD getIsFieldSet()
METHOD setIsFieldSet()

METHOD getBoxTxtInf()
METHOD setNoBoxInf()

METHOD setTop()
METHOD getTop()

METHOD getTitLegend()
METHOD getFSWidth()
METHOD getFSPx()
METHOD getFSPxLeft()
METHOD getIdLegend()
METHOD setIdLegend() 

METHOD getFormatF()

METHOD setCss()
METHOD getCss()

METHOD setCssDiv()
METHOD getCssDiv()

METHOD setPlaceHolder()
METHOD getPlaceHolder()

METHOD setText()
METHOD getText()   

METHOD setWidthTI()
METHOD getWidthTI()

METHOD setAlign()
METHOD getAlign()

METHOD setPosicao()
METHOD getPosicao()
METHOD setIsName()
METHOD getIsName()
METHOD setColsArea()
METHOD getColsArea()

METHOD setRowsArea()
METHOD getRowsArea()

METHOD setArrCombo()
METHOD getArrCombo()

METHOD getTagTDIE()
METHOD setNoTagTDIE()

METHOD setImgWidth()
METHOD getImgWidth()

METHOD setImgHeight()
METHOD getImgHeight()

METHOD setOpenGrp()
METHOD getOpenGrp()

METHOD setCloseGrp()
METHOD getCloseGrp()

METHOD setNumber()
METHOD getNumber()

METHOD setMinValue()
METHOD getMinValue()

METHOD setMaxValue()
METHOD getMaxValue()

METHOD setData()
METHOD getData()

METHOD setCboxPes()
METHOD getCboxPes()

METHOD setAHeader()
METHOD getAHeader()

METHOD setACols()
METHOD getACols()

METHOD setAltGrid()
METHOD getAltGrid()

METHOD setDelGrid()
METHOD getDelGrid()

METHOD setArrRadio()
METHOD getArrRadio()

METHOD setMultiple()
METHOD getMultiple()

METHOD setXS()
METHOD getXS()
METHOD setSM()
METHOD getSM()
METHOD setMD()
METHOD getMD()
METHOD setLG()
METHOD getLG()

METHOD setDisplay()
METHOD getDisplay()

METHOD setInlineB()
METHOD getInlineB()

METHOD setCustom()
METHOD getCustom()

METHOD setListOpt()
METHOD getListOpt()

METHOD setTagInput()
METHOD getTagInput()

METHOD setNaoVrRep()
METHOD getNaoVrRep()

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(cTp,cName,cTitle,cSize,cMLength,lOb,lDi,lRO,lNumber,cXS,cSM,cMD,cLG, lData, lCboxPes, aHeader,aCols,lAltGrid,lDelGrid, cCssDiv, lMultiple, cPlaceHolder, nMinValue, nMaxValue, lInlineB) CLASS WCComponent
DEFAULT cTitle	:= "&nbsp;"
DEFAULT cSize	:= ""
DEFAULT cMLength:= "0"
DEFAULT lOb		:= .F.
DEFAULT lDi		:= .F.
DEFAULT lRO		:= .F.
DEFAULT cCssDiv	:= ""
DEFAULT cPlaceHolder := ""

/*PROPRIEDADES DEFINIDAS NO METODO EM CADA COMPONENTE NO WCHTML*/
DEFAULT cXS := "12"
DEFAULT cSM := "6"
DEFAULT cMD := "6"
DEFAULT cLG := "4"  
DEFAULT lNumber 	:= .F.
DEFAULT nMinValue := 0
DEFAULT nMaxValue := 0
DEFAULT lData	 	:= .F.
DEFAULT lCboxPes	:= .F.
DEFAULT lMultiple := .F.
DEFAULT lAltGrid	:= .T.
DEFAULT lDelGrid	:= .T.
DEFAULT aHeader	:= {}
DEFAULT aCols		:= {}
DEFAULT lInlineB   := .F.
::cTp			:= cTp
::cName 		:= cName
::cTitle	 	:= cTitle               
::cSize	 	:= cSize
::lNumber     := lNumber
::nMinValue   := nMinValue
::nMaxValue   := nMaxValue 
::lData     	:= lData
::lAltGrid		:= lAltGrid
::lDelGrid		:= lDelGrid
::lCboxPes		:= lCboxPes
::lInlineB      := lInlineB
::lMultiple   := lMultiple
::aHeader     := aHeader
::aCols       := aCols
::cXS         := cXS
::cSM			:= cSM
::cMD			:= cMD
::cLG			:= cLG
::cMLength		:= cMLength
::lOb			:= lOb
::lDi			:= lDi
::lRO			:= lRO
::cCssDiv		:= cCssDiv
::cPlaceHolder := cPlaceHolder
::cType			:= "text"
::cImg 			:= "/chk.gif"
::cHelpBtn 		:= "Pesquisa"
::cJSKeyPre		:= ""
::cJSKeyDown	:= ""
::cJSBlur		:= ""
::cJSFocOut		:= ""
::cJSFocus		:= ""
::cJSChange		:= ""
::lNewLine		:= .f.
::cTitLegen		:= ""
::cIdLegend   := ""
::lDig			:= .F.
::lNoIte		:= .F.
::xSession	 	:= ""
::cJsFBtn		:= ""
::cJsFBtL		:= ""
::cHelp			:= ""
::cValue		:= ""
::cJsFF3		:= ""
::cJsFunc		:= ""
::cAlign		:= ""
::cWidth		:= ""
::cWidthBrw		:= ""
::cHeightBrw	:= ""
::cPx			:= ""
::cPxLeft		:= ""
::lTop			:= .f.
::cFormatF		:= 'H'
::cCss			:= ""
::cText			:= ""
::cWidthTI		:= ""
::cJsHelp		:= ""
::cToolTip		:= ""
::cSpaceBrw		:= ""
::lBoxTxtInf		:= .T.
::aArrCombo		:= {}
::lTagTDIE			:= .T.
::cImgWidth		:= ""
::cImgHeight		:= ""
::lOpenGrp			:= .F.
::lCloseGrp		:= .F.
::aArrRadio		:= {}
::lCustom      := .F.
::aListOpt		:= {}
::lTagInput		:= .F.
::lNaoVrRep		:= .f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Self       
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta o type do componente input

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setType(cType) CLASS WCComponent
::cType := cType
Return   
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o type do componente input

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getType() CLASS WCComponent
Return(::cType)   
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a funcao OnKeyPress (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJSKeyPre(cJSKeyPre) CLASS WCComponent
::cJSKeyPre := cJSKeyPre
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a funcao OnKeyPress (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJSKeyPre() CLASS WCComponent
Return(::cJSKeyPre)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a funcao OnKeyDown (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJSKeyDown(cJSKeyDown) CLASS WCComponent
::cJSKeyDown := cJSKeyDown
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a funcao OnKeyDown (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJSKeyDown() CLASS WCComponent
Return(::cJSKeyDown)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a funcao OnBlur (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJSBlur(cJSBlur) CLASS WCComponent
::cJSBlur := cJSBlur
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a funcao OnBlur (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJSBlur() CLASS WCComponent
Return(::cJSBlur)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a funcao OnFocus (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJSFocOut(cJSFocOut) CLASS WCComponent
::cJSFocOut := cJSFocOut
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a funcao OnFocus (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJSFocOut() CLASS WCComponent
Return(::cJSFocOut)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a funcao OnChange (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJSChange(cJSChange) CLASS WCComponent
::cJSChange := cJSChange
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a funcao OnChange (ComboBox ou Field)

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJSChange() CLASS WCComponent
Return(::cJSChange)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a HttpSession para carga do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setSession(xSession) CLASS WCComponent
::xSession := xSession
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a HttpSession para carga do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getSession() CLASS WCComponent
Return(::xSession)

/*/{Protheus.doc} WCComponent
Seta a HttpSession para carga do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setToolTip(cTool) CLASS WCComponent
::cToolTip := cTool
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a HttpSession para carga do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getToolTip() CLASS WCComponent
Return(::cToolTip)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta O combobox tsera o recurso de digitacao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setDig() CLASS WCComponent
::lDig := .T.
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna se o combobox tera o recurso de digitacao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getDig() CLASS WCComponent
Return(::lDig)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se a opcao "selecione um item" sera mostrada quando disable = tru

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setNoIte() CLASS WCComponent
::lNoIte := .T.
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna se a opcao "selecione um item" sera mostrada quando disable = tru

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getNoIte() CLASS WCComponent
Return(::lNoIte)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Inclui botao ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsFBtn(cJsFBtn) CLASS WCComponent
::cJsFBtn := cJsFBtn
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna inclui botao ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsFBtn() CLASS WCComponent
Return(::cJsFBtn)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Inclui botao ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsFBtL(cJsFBtL) CLASS WCComponent
::cJsFBtL := cJsFBtL
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna inclui botao ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsFBtL() CLASS WCComponent
Return(::cJsFBtL)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Inclui botao ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsHelp(cJsFHelp) CLASS WCComponent
::cJsHelp := cJsFHelp
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna inclui botao ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsHelp() CLASS WCComponent
Return(::cJsHelp)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Inclui botao de help ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setHelp(cHelp) CLASS WCComponent
::cHelp := cHelp
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna se inclui botao de help ao lado do combobox

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getHelp() CLASS WCComponent
Return(::cHelp)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
MaxLength do campo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setMLength(cMLength) CLASS WCComponent
::cMLength := cMLength
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna MaxLength do campo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getMLength() CLASS WCComponent
Return(::cMLength)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Valor default do combo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setDefCB(cDefault) CLASS WCComponent
::cDefault := cDefault
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna default do combo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getDefCB() CLASS WCComponent
Return(::cDefault)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Valor padrao do campo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setValue(cValue) CLASS WCComponent
::cValue := cValue
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna Valor padrao do campo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getValue() CLASS WCComponent
Return(::cValue)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Botao de F3 ao lado do campo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsFF3(cJsFF3) CLASS WCComponent
::cJsFF3 := cJsFF3
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna botao de F3 ao lado do campo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsFF3() CLASS WCComponent
Return(::cJsFF3)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Funcao a ser executado pelo botao de navegacao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setJsFunc(cJsFunc) CLASS WCComponent
::cJsFunc := cJsFunc
Return          
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna Funcao a ser executado pelo botao

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getJsFunc() CLASS WCComponent
Return(::cJsFunc)   
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se este componente e os proximos serao criados em uma linha nova

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setNewLine() CLASS WCComponent
::lNewLine := .T.
Return          
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna se esta componenete deve ser criado em uma nova linha

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getNewLine() CLASS WCComponent
Return(::lNewLine)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta componente como obrigatorio

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setObrigat() CLASS WCComponent
::lOb := .T.
Return  
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna componente como obrigatorio

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getObrigat() CLASS WCComponent
Return(::lOb)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta componente como Disabled

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setDisable(lDi) CLASS WCComponent
Default lDi := .T.
::lDi := lDi
Return          
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna componente como Disabled

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getDisable() CLASS WCComponent
Return(::lDi)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta componente como ReadOnly

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setReadOnly() CLASS WCComponent
::lRO := .T.
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna componente como ReadOnly

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getReadOnly() CLASS WCComponent
Return(::lRO)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta help do button de img

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setHelpBtn(cHelpBtn) CLASS WCComponent
::cHelpBtn := cHelpBtn
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna help do button de img

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getHelpBtn() CLASS WCComponent
Return(::cHelpBtn)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta nome da img do button de img

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setImgBtn(cImg) CLASS WCComponent
::cImg := cImg
Return                 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna nome da img do button de img

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getImgBtn() CLASS WCComponent
Return(::cImg) 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta lagura do Browse Grid

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setBrWidth(cWidthBrw) CLASS WCComponent
::cWidthBrw := cWidthBrw
Return                 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna lagura do BrowseGrid

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getBrWidth() CLASS WCComponent
Return(::cWidthBrw)       
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta altura do Browse Grid

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setBrHeight(cHeightBrw) CLASS WCComponent
::cHeightBrw := cHeightBrw
Return                 
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna Altura do BrowseGrid

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getBrHeight() CLASS WCComponent
Return(::cHeightBrw)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se e alinhamento bottom ou top

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setTop() CLASS WCComponent
::lTop := .t.
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna se e alinhamento bottom ou top

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getTop() CLASS WCComponent
Return(::lTop)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o nome do groupo do componente

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
METHOD getIsFieldSet() CLASS WCComponent
Return( !Empty(::cTitLegen) )
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta o nome do groupo do componente

@author Everton Mateus Fernandes
@since 07/11/2013
@version P11
/*/
METHOD setIsFieldSet(cTitLegen) CLASS WCComponent
::cTitLegen := cTitLegen
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o nome do groupo do componente

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getTitLegend() CLASS WCComponent
Return ::cTitLegen
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna lagura do fieldset

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getFSWidth() CLASS WCComponent
Return(::cWidth)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna padding do fieldset

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getFSPx() CLASS WCComponent
Return(::cPx)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna Padding-Left do fieldSet

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getFSPxLeft() CLASS WCComponent
Return(::cPxLeft)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna cFormatF do fieldSet

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getFormatF() CLASS WCComponent
Return(::cFormatF)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta o css d div de texto informativo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setCss(cCss) CLASS WCComponent
::cCss := cCss
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o css da div de texto informativo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getCss() CLASS WCComponent
Return(::cCss)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta o texto da div de texto informativo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setText(cText) CLASS WCComponent
::cText := cText
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o Texto div de texto informativo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getText() CLASS WCComponent
Return(::cText)    
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta largura da div do texto informativo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setWidthTI(cWidthTI) CLASS WCComponent
::cWidthTI := cWidthTI
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna largura da div de texto informativo

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getWidthTI() CLASS WCComponent
Return(::cWidthTI)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se o botao vai posiconal no bottom

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setAlign(cAlign) CLASS WCComponent
::cAlign := cAlign
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna se o posicionamento do botao sera no bottom

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getAlign() CLASS WCComponent
Return(::cAlign)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta o espacamento referente ao obj acima posicionado

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setPosicao(cSpaceBrw) CLASS WCComponent
::cSpaceBrw := cSpaceBrw
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o espacamento para posicionamento do browse

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getPosicao() CLASS WCComponent
Return(::cSpaceBrw)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se pega na session para montar o combo sera pela coluna cName

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setIsName() CLASS WCComponent
::lName := .t.
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna se pega na session para montar o combo pelo cName ou cDescription

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getIsName() CLASS WCComponent
Return(::lName)


//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a quantidade de colunas do TextArea

@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD setColsArea(cColsArea) CLASS WCComponent
::cColsArea := cColsArea
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a quantidade de colunas do TextArea

@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD getColsArea() CLASS WCComponent
Return(::cColsArea)


//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta a quantidade de linhas do TextArea

@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD setRowsArea(cRowsArea) CLASS WCComponent
::cRowsArea := cRowsArea
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a quantidade de linhas do TextArea

@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD getRowsArea() CLASS WCComponent
Return(::cRowsArea)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna se o TextInf tera o box na pagina

@author Rogerio Tabosa
@since 26/03/2013
@version P118
/*/
//-------------------------------------------------------------------
METHOD getBoxTxtInf() CLASS WCComponent
Return(::lBoxTxtInf)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
atribui que o textinf nao tera o box ao redor

@author Rogerio Tabosa
@since 26/03/2013
@version P118
/*/
//-------------------------------------------------------------------
METHOD setNoBoxInf() CLASS WCComponent
::lBoxTxtInf := .F.
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Atribui o array de uma Combo (quando nao utilizado Session)

@author Rogerio Tabosa
@since 18/01/2014
@version P11
/*/
//-------------------------------------------------------------------
METHOD setArrCombo(aArray) CLASS WCComponent
::aArrCombo := aArray
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna a quantidade de linhas do TextArea

@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD getArrCombo() CLASS WCComponent
Return(::aArrCombo)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Desabilita a TAG de compatibilidade com versoes anteriores do IE
/*/
//-------------------------------------------------------------------
METHOD getTagTDIE() CLASS WCComponent
Return(::lTagTDIE)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
atribui que o textinf nao tera o box ao redor

@author Rogerio Tabosa
@since 26/03/2013
@version P118
/*/
//-------------------------------------------------------------------
METHOD setNoTagTDIE() CLASS WCComponent
::lTagTDIE := .F.
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Define o tamanho da imagem a ser inserida

@author Rogerio Tabosa
@since 26/03/2013
@version P118
/*/
//-------------------------------------------------------------------
METHOD setImgWidth(cWidth) CLASS WCComponent
::cImgWidth := cWidth
Return

METHOD getImgWidth() CLASS WCComponent
Return(::cImgWidth)

METHOD setImgHeight(cHeight) CLASS WCComponent
::cImgHeight := cHeight
Return

METHOD getImgHeight() CLASS WCComponent
Return(::cImgHeight)
//------------------ FIM IMAGEM -------------------------------------


METHOD setOpenGrp(lOpenGrp) CLASS WCComponent
DEFAULT lOpenGrp := .F.
::lOpenGrp := lOpenGrp
Return

METHOD getOpenGrp() CLASS WCComponent
Return(::lOpenGrp)

METHOD setCloseGrp(lCloseGrp) CLASS WCComponent
DEFAULT lCloseGrp := .F.
::lCloseGrp := lCloseGrp
Return

METHOD getCloseGrp() CLASS WCComponent
Return(::lCloseGrp)

//-------------------------------------------------------------------
METHOD setJSFocus(cJSFocus) CLASS WCComponent
::cJSFocus := cJSFocus
Return     
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD getJSFocus() CLASS WCComponent
Return(::cJSFocus)
//-------------------------------------------------------------------

//------------------ FIM Open group -------------------------------------

METHOD setNumber(lNumber) CLASS WCComponent
DEFAULT lNumber := .F.
	::lNumber := lNumber
Return

METHOD getNumber() CLASS WCComponent
Return(::lNumber)

METHOD setMinValue(nMinValue) CLASS WCComponent
DEFAULT nMinValue := 0
	::nMinValue := nMinValue
Return

METHOD getMinValue() CLASS WCComponent
Return (::nMinValue)

METHOD setMaxValue(nMaxValue) CLASS WCComponent
DEFAULT nMaxValue := 0
	::nMaxValue := nMaxValue
Return

METHOD getMaxValue() CLASS WCComponent
Return (::nMaxValue)
//-------------------------------------------------------------------
METHOD setData(lData) CLASS WCComponent
DEFAULT lData := .F.
::lData := lData
Return

METHOD getData() CLASS WCComponent
Return(::lData)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setCboxPes(lCboxPes) CLASS WCComponent
DEFAULT lCboxPes := .F.
::lCboxPes := lCboxPes
Return

METHOD getCboxPes() CLASS WCComponent
Return(::lCboxPes)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se o botão deverá ser alinhado aos campos
@author Karine Riquena Limp
@since 10/12/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setInlineB(lInlineB) CLASS WCComponent
DEFAULT lInlineB := .F.
::lInlineB := lInlineB
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna se o botão deverá ser alinhado aos campos
@author Karine Riquena Limp
@since 10/12/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getInlineB() CLASS WCComponent
Return(::lInlineB)
METHOD setMultiple(lMultiple) CLASS WCComponent
DEFAULT lMultiple := .F.
::lMultiple := lMultiple
Return

METHOD getMultiple() CLASS WCComponent
Return(::lMultiple)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setAHeader(aHeader) CLASS WCComponent
DEFAULT aHeader := {}
::aHeader := aHeader
Return

METHOD getAHeader() CLASS WCComponent
Return(::aHeader)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setACols(aCols) CLASS WCComponent
DEFAULT aCols := {}
::aCols := aCols
Return

METHOD getACols() CLASS WCComponent
Return(::aCols)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setAltGrid(lAltGrid) CLASS WCComponent
DEFAULT lAltGrid := .T.
::lAltGrid := lAltGrid
Return

METHOD getAltGrid() CLASS WCComponent
Return(::lAltGrid)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setDelGrid(lDelGrid) CLASS WCComponent
DEFAULT lDelGrid := .T.
::lDelGrid := lDelGrid
Return

METHOD getDelGrid() CLASS WCComponent
Return(::lDelGrid)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setCssDiv(cCssDiv) CLASS WCComponent
DEFAULT cCssDiv := ""
::cCssDiv := cCssDiv
Return

METHOD getCssDiv() CLASS WCComponent
Return(::cCssDiv)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
METHOD setPlaceHolder(cPlaceHolder) CLASS WCComponent
DEFAULT cPlaceHolder := ""
::cPlaceHolder := cPlaceHolder
Return

METHOD getPlaceHolder() CLASS WCComponent
Return(::cPlaceHolder)
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} setArrRadio
Atribui o array de um radio
@author Rodrigo Morgon
@since 17/08/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setArrRadio(aArray) CLASS WCComponent
::aArrRadio := aArray
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getArrRadio
Retorna o array de dados de um radio
@author Rogerio Tabosa
@since 18/03/2013
@version P11
/*/
//-------------------------------------------------------------------
METHOD getArrRadio() CLASS WCComponent
Return(::aArrRadio)
//-------------------------------------------------------------------
/*/{Protheus.doc} getIdLegend
Pega o id do fieldset

@author Karine Riquena
@since 02/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getIdLegend() CLASS WCComponent
Return(::cIdLegend) 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIdLegend
Pega o id do fieldset

@author Karine Riquena
@since 02/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setIdLegend(cIdLegend) CLASS WCComponent
::cIdLegend := cIdLegend 
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta tamanho XS 

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setXS(cXS) CLASS WCComponent
::cXS := cXS
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o tamanho XS

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getXS() CLASS WCComponent
Return(::cXS)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta tamanho SM 

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setSM(cSM) CLASS WCComponent
::cSM := cSM
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o tamanho SM

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getSM() CLASS WCComponent
Return(::cSM)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta tamanho MD 

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setMD(cMD) CLASS WCComponent
::cMD := cMD
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o tamanho MD

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getMD() CLASS WCComponent
Return(::cMD)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta tamanho LG

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setLG(cLG) CLASS WCComponent
::cLG := cLG
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Retorna o tamanho LG

@author Karine Limp
@since 05/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getLG() CLASS WCComponent
Return(::cLG)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDisplay
Define o estado display inicial (.T. ou .F.) de um componente.

@author Rodrigo Morgon
@since 08/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD setDisplay(lDisplay) CLASS WCComponent
::lDisplay := lDisplay
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getDisplay
Obtém o estado inicial display de um componente

@author Rodrigo Morgon
@since 08/10/2015
@version P12
/*/
//-------------------------------------------------------------------
METHOD getDisplay() CLASS WCComponent
Return (::lDisplay)

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Seta se é um componente customizado

@author Karine Riquena Limp
@since 31/03/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setCustom() CLASS WCComponent
::lCustom := .T.
Return     
//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna se é um componente customizado

@author Karine Riquena Limp
@since 31/03/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD getCustom() CLASS WCComponent
Return(::lCustom)

//-------------------------------------------------------------------
/*/{Protheus.doc} setListOpt
Atribui o array de um radio
@author Fábio Siqueira dos Santos
@since 20/04/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setListOpt(aArray) CLASS WCComponent
::aListOpt := aArray
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getListOpt
Retorna o array de dados de um radio
@author Fábio Siqueira dos Santos
@since 20/04/2016
@version P11
/*/
//-------------------------------------------------------------------
METHOD getListOpt() CLASS WCComponent
Return(::aListOpt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTagInput
Indica se é tag input
@author Fábio Siqueira dos Santos
@since 18/10/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setTagInput(lTagInput) CLASS WCComponent
::lTagInput := lTagInput
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getListOpt
Retorna tag input
@author Fábio Siqueira dos Santos
@since 18/10/2016
@version P11
/*/
//-------------------------------------------------------------------
METHOD getTagInput() CLASS WCComponent
Return(::lTagInput)


//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
Indica se deve verificar repetidos no listbox
@since 08/2019
/*/
//-------------------------------------------------------------------
METHOD setNaoVrRep() CLASS WCComponent
::lNaoVrRep := .T.
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} WCComponent
retorna se é um componente customizado
@since 31/03/2016
/*/
//-------------------------------------------------------------------
METHOD getNaoVrRep() CLASS WCComponent
Return(::lNaoVrRep)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³__WCComponent³ Autor ³ Totvs			    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function __WCComponent
Return
