STATIC __PASTAWEB := ""

#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AP5MAIL.CH"  
//#DEFINE __PASTAWEB Iif( Empty( GetPrtSkin() ),'imagens-pls',GetPrtSkin() ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Classe Form.
 
@author Alexander Santos
@since 14/02/2012
@version P11
/*/
//-------------------------------------------------------------------
CLASS WCHtml

DATA lLibJs	AS STRING
DATA oObj	AS OBJECT HIDDEN
DATA cCustom AS STRING
DATA cFunction AS STRING

METHOD New() Constructor

METHOD setObj()
METHOD getObj()
METHOD getDType()
METHOD loadWC()
METHOD setFunction()
METHOD getFunction()

ENDCLASS
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD new(lAutoma) CLASS WCHtml
DEFAULT lAutoma := .F.

::lLibJs := .T.
cCustom := ""
::oObj	 := NIL
::cFunction := ""

If lAutoma
	__PASTAWEB := 'imagens-pls'
Else
	__PASTAWEB := Iif( Empty( GetPrtSkin() ),'imagens-pls',GetPrtSkin() ) 
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim do Methodo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return Self                
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Seta a objeto no html

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD setObj(oObj) CLASS WCHtml
::oObj := oObj
Return            
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Retorna DOCType do Html

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getDType(lLibJs,lLibUser,cJsLib, cJsCode, cDtJs) CLASS WCHtml
DEFAULT lLibJs 	:= .T.
DEFAULT lLibUser 	:= .F.
DEFAULT cJsLib 	:= ""
DEFAULT cJsCode 	:= ""
DEFAULT cDtJs 	:= ""

Return( WCHtmHead(lLibJs,lLibUser, cJsLib, cJsCode, cDtJs) )
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Retorna a lista de objetos do html

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD getObj() CLASS WCHtml
Return(::oObj)
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Carrega html e seus obj

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD loadWC() CLASS WCHtml
Return( montWC(Self) )
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Seta o nome da webfunction que chamou o wchtml para verificação de campos customizados

@author Karine Riquena Limp
@since 31/03/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD setFunction(cFunction) CLASS WCHtml
DEFAULT cFunction := ""
::cFunction := cFunction
Return 
//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} WCHtml
Retorna o nome da webfunction que chamou o wchtml para verificação de campos customizados

@author Karine Riquena Limp
@since 31/03/2016
@version P12
/*/
//-------------------------------------------------------------------
METHOD getFunction() CLASS WCHtml
Return(::cFunction)
//-------------------------------------------------------------------

STATIC cCustom := "" //variavel criada para armazenar os campos customizados e criar um hidden para identificá-los na pagina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³montWC  	³ Autor ³ Totvs				    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Monta formulario											  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function montWC(oObj)
LOCAL cHTML 		:= ""    
LOCAL nI			:= 1
LOCAL lMenuFolder 	:= .f.
LOCAL aMatH 		:= {}   
LOCAL cFunction := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Pega os componentes do html
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cFunction := oObj:getFunction()
oObj := oObj:getObj()

if existblock("PLRDWCHTML")
	oObj := execBlock("PLRDWCHTML",.F.,.F.,{ oObj, cFunction })
endIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³MOnta componentes
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
do case 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Formulario
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	case GetClassName(oObj) == "WCFORM"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Se foi informado nome ao formulario inicia a con
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		if !empty(oObj:cName)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Html,Body e Form
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			cHTML += WCForm("A",;
							oObj:cName,;
							oObj:getAction(),;
							oObj:getMethod(),;
							oObj:getWidth(),;
							oObj:getTitle(),;
							/*oObj:getJsFClick()*/,;
							/*oObj:getJsFImp()*/,;
							/*oObj:getFBack()*/,;
							/*oObj:getNLinBtn()*/,;
							/*oObj:getAlignBtn()*/)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Monta campos hidden
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			aMatH := oObj:getListFieldHidden()
			
			if len(aMatH)>0             
				for nI:=1 to len(aMatH)
					cHTML += WCFHidden( aMatH[nI,1],aMatH[nI,2] )
				next	
			endIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Se existe tabela a ser montada
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			if len(oObj:getListTables()) > 0 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Criacao das tabelas
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				for nI:=1 to len(oObj:getListTables())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³se vai criar o menu folder
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					if nI == 1 .and. oObj:getIsFolder()
						lMenuFolder := .t.
					endIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Cria tabela
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					cHTML += WCFormTab( "A",;
										oObj:getIsFolder(),;
										nI,;
										lMenuFolder,;
										oObj:getListTables())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Criacao da Linha e seus componentes
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					if len(oObj:aTables[nI]:aLines) > 0 
						cHTML += montLine(oObj:getListTables()[nI]:getListLine())
					endIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³se vai criar o menu folder
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					lMenuFolder := .f.
					if nI == len(oObj:getListTables()) .and. oObj:getIsFolder()
						lMenuFolder := .t.
					endIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Fechamento da tabela
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					cHTML += WCFormTab( "F",;
										oObj:getIsFolder(),;
										/*nI*/,;
										lMenuFolder,;
										/*oObj:getListTables()*/)
				next
			endIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Form,Body e Html
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			cHTML += WCForm("F",;
							oObj:cName,;
							oObj:getAction(),;
							oObj:getMethod(),;
							oObj:getWidth(),;
							oObj:getTitle(),;
							oObj:getJsFClick(),;
							oObj:getJsFImp(),;
							oObj:getFBack(),;
							oObj:getNLinBtn(),;
							oObj:getAlignBtn(),;
							oObj:getFuncLoad(),;
							oObj:getGlobalVar(),;
							oObj:getObrigat(),;
							nil,; // oObj:getFAgain()
							oObj:getACustomBtn())
		
			//hidden com os campos customizados
			cCustom := substr(cCustom, 1, (len(cCustom)-1))
			cHTML += WCFHidden("custom_fields",cCustom)
		endIf	  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Print
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	case GetClassName(oObj) == "WCPRINT"
		cHTML += WCPrint(oObj:cTitle,oObj:cLabel,oObj:cName,oObj:cFileName,oObj:cFuncJs,oObj:cWidth,oObj:cMsgPlug)
endCase	                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Destroy da memoria
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
freeObj(oObj)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return cHTML
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³montLine  ³ Autor ³ Totvs				    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Monta Linha												  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function montLine(oObj)
LOCAL nY 			:= 1
LOCAL nX 			:= 1
LOCAL cHTML 		:= ""
LOCAL cOldGroup	:= ""         
LOCAL cOldTitLeg	:= ""
LOCAL cOldIdLeg  	:= ""
LOCAL cTitle		:= ""
LOCAL lOpenGroup	:= .f.
LOCAL lOpenTitLeg:= .f.
LOCAL cFormatF	:= ''
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Criacao da Linha
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nY:=1 To Len(oObj)        
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Verifica se o grupo ja foi criado
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If cOldGroup <> oObj[nY]:GetGroup() 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Fechamento do grupo
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        If lOpenGroup
			cHTML += WCFTabGrou("F",cTitle,cOldGroup)
			lOpenGroup := .F.
        EndIf
		
		If !Empty( oObj[nY]:GetGroup() )
	        cTitle		:= oObj[nY]:GetTitle()
			cOldGroup 	:= oObj[nY]:GetGroup()
			lOpenGroup	:= .T.
			
			cHTML += WCFTabGrou("A",cTitle,cOldGroup)
		EndIf	
	EndIf           
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Linha e seus componentes
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cHTML += WCFTabLin("A")									
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Se tem componente a ser criado
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If Len(oObj[nY]:getListComp()) > 0 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Cria componente da linha
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		For nX:=1 To Len(oObj[nY]:getListComp())     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Verifica se e para fechar a linha anterior e criar uma nova
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If oObj[nY]:getListComp()[nX]:getNewLine()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Fecha linha anterior
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				cHTML += WCFTabLin("F")									
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Abre linha nova
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				cHTML += WCFTabLin("A", oObj[nY]:getHGroup())									
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Agrupamento de componente
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If (!empty(oObj[nY]:getListComp()[nX]:getIdLegend()) .and. cOldIdLeg <> oObj[nY]:getListComp()[nX]:getIdLegend());
			.OR.(empty(oObj[nY]:getListComp()[nX]:getIdLegend()) .and. cOldTitLeg <> oObj[nY]:getListComp()[nX]:getTitLegend())
			
			    If lOpenTitLeg
					cHTML += WCFLegGrou("F",cFormatF,,,,,oObj[nY]:getHGroup())
					lOpenTitLeg 	:= .f.
					cFormatF		:= ''
			    EndIf
                                       
				If !Empty(oObj[nY]:getListComp()[nX]:getIdLegend()) .OR. !Empty(oObj[nY]:getListComp()[nX]:getTitLegend())
					lOpenTitLeg 	:= .t.
					cOldTitLeg		:= oObj[nY]:getListComp()[nX]:getTitLegend()
					cOldIdLeg     := oObj[nY]:getListComp()[nX]:getIdLegend()
					cFormatF		:= oObj[nY]:getListComp()[nX]:getFormatF()

					cHTML += WCFLegGrou("A",; 
										cFormatF,;
										oObj[nY]:getListComp()[nX]:getTitLegend(),;
										oObj[nY]:getListComp()[nX]:getFSWidth(),;
										oObj[nY]:getListComp()[nX]:getFSPx(),;
										oObj[nY]:getListComp()[nX]:getFSPxLeft(),;
										oObj[nY]:getHGroup(),;
										oObj[nY]:getNomeHGr(),;
										oObj[nY]:getListComp()[nX]:getIdLegend())
				EndIf    
				
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Componente
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			Do Case          
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Botao ImG
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'BI'
				
					cHTML += WCButImg(oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:getJsFunc(),; 
										oObj[nY]:getListComp()[nX]:getHelpBtn(),;
										oObj[nY]:getListComp()[nX]:getImgBtn(),;
										oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getImgWidth(),;
										oObj[nY]:getListComp()[nX]:getImgHeight())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Botao
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'B'
					
					cHTML += WCButton(oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:cTitle,;
										oObj[nY]:getListComp()[nX]:getJsFunc(),;
										oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getAlign(),;
										oObj[nY]:getListComp()[nX]:getCSS(),;
										oObj[nY]:getListComp()[nX]:getTagTDIE(),;
										oObj[nY]:getListComp()[nX]:getOpenGrp(),;
										oObj[nY]:getListComp()[nX]:getCloseGrp(),;
										oObj[nY]:getListComp()[nX]:getXS(),;
										oObj[nY]:getListComp()[nX]:getSM(),;
										oObj[nY]:getListComp()[nX]:getMD(),;
										oObj[nY]:getListComp()[nX]:getLG(),;
										oObj[nY]:getListComp()[nX]:getInlineB(),;
										oObj[nY]:getListComp()[nX]:getListOpt())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Campo
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'F'
				
					cHTML += WCField(	oObj[nY]:getListComp()[nX]:cName,;
									 	oObj[nY]:getListComp()[nX]:cTitle,;
									 	oObj[nY]:getListComp()[nX]:cSize,;
									 	oObj[nY]:getListComp()[nX]:getType(),;
									 	oObj[nY]:getListComp()[nX]:getTop(),;
									 	oObj[nY]:getListComp()[nX]:getMLength(),;
									 	oObj[nY]:getListComp()[nX]:getValue(),;
									 	oObj[nY]:getListComp()[nX]:getObrigat(),;
									 	oObj[nY]:getListComp()[nX]:getReadOnly(),;
									 	oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getJSKeyDown(),;
									 	oObj[nY]:getListComp()[nX]:getJSKeyPre(),;
									 	oObj[nY]:getListComp()[nX]:getJSBlur(),;
									 	oObj[nY]:getListComp()[nX]:getJSFocOut(),;
									 	oObj[nY]:getListComp()[nX]:getJsFF3(),;
										oObj[nY]:getListComp()[nX]:getJSChange(),;
									 	oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getCss(),;
										oObj[nY]:getListComp()[nX]:getJsFBtn(),;
										oObj[nY]:getListComp()[nX]:getOpenGrp(),;
										oObj[nY]:getListComp()[nX]:getCloseGrp(),;
										oObj[nY]:getListComp()[nX]:getJSFocus(),;
										oObj[nY]:getListComp()[nX]:getJsFBtL(),;
										oObj[nY]:getListComp()[nX]:getJsHelp(),;
										oObj[nY]:getListComp()[nX]:getToolTip(),;
										oObj[nY]:getListComp()[nX]:lNumber,;
                                   	oObj[nY]:getListComp()[nX]:lData,;
										oObj[nY]:getListComp()[nX]:getXS(),;
									 	oObj[nY]:getListComp()[nX]:getSM(),;
									 	oObj[nY]:getListComp()[nX]:getMD(),;
									 	oObj[nY]:getListComp()[nX]:getLG(),;
									 	oObj[nY]:getListComp()[nX]:getCssDiv(),;
									 	oObj[nY]:getListComp()[nX]:getPlaceHolder(),;
									 	oObj[nY]:getListComp()[nX]:getMinValue(),;
									 	oObj[nY]:getListComp()[nX]:getMaxValue(),;
									 	oObj[nY]:getListComp()[nX]:getCustom(),;
									 	oObj[nY]:getListComp()[nX]:getTagInput())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Combo
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'C'

					cHTML += WCCombo(	oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:cTitle,;
									 	oObj[nY]:getListComp()[nX]:cSize,;
									 	oObj[nY]:getListComp()[nX]:getTop(),;
										oObj[nY]:getListComp()[nX]:getSession(),;
									 	oObj[nY]:getListComp()[nX]:getObrigat(),;
										oObj[nY]:getListComp()[nX]:getDig(),;    
									 	oObj[nY]:getListComp()[nX]:getDisable(),;
										oObj[nY]:getListComp()[nX]:getJSChange(),;
										oObj[nY]:getListComp()[nX]:getJSKeyDown(),;
										oObj[nY]:getListComp()[nX]:getJSKeyPre(),;
										oObj[nY]:getListComp()[nX]:getJsFBtn(),;
										oObj[nY]:getListComp()[nX]:getHelp(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getNoIte(),;
										oObj[nY]:getListComp()[nX]:getDefCB(),;
										oObj[nY]:getListComp()[nX]:getIsName(),;
										oObj[nY]:getListComp()[nX]:getArrCombo(),;
										oObj[nY]:getListComp()[nX]:getOpenGrp(),;
										oObj[nY]:getListComp()[nX]:getCloseGrp(),;
										oObj[nY]:getListComp()[nX]:getJsHelp(),;
										oObj[nY]:getListComp()[nX]:getXS(),;
									 	oObj[nY]:getListComp()[nX]:getSM(),;
									 	oObj[nY]:getListComp()[nX]:getMD(),;
									 	oObj[nY]:getListComp()[nX]:getLG(),;
									 	oObj[nY]:getListComp()[nX]:getCboxPes(),;
									 	oObj[nY]:getListComp()[nX]:getCssDiv(),;
									 	oObj[nY]:getListComp()[nX]:getMultiple(),;
									 	oObj[nY]:getListComp()[nX]:getPlaceHolder(),;
									 	oObj[nY]:getListComp()[nX]:getCss(),;
									 	oObj[nY]:getListComp()[nX]:getJSFocus(),;
									 	oObj[nY]:getListComp()[nX]:getJSBlur(),;
										oObj[nY]:getListComp()[nX]:getCustom(),;
										oObj[nY]:getListComp()[nX]:getNaoVrRep())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Bw
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'BW'
					cHTML += WCBrwGrid(	oObj[nY]:getListComp()[nX]:cName,;
										oObj[nY]:getListComp()[nX]:cTitle,;
										oObj[nY]:getListComp()[nX]:getBrWidth(),;
										oObj[nY]:getListComp()[nX]:getBrHeight(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getJsFunc(),;
										oObj[nY]:getListComp()[nX]:getAHeader(),;
										oObj[nY]:getListComp()[nX]:getACols(),;
										oObj[nY]:getListComp()[nX]:getAltGrid(),;
										oObj[nY]:getListComp()[nX]:getDelGrid())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³TextInfo
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'T'
					cHTML += WCTextInf(	oObj[nY]:getListComp()[nX]:getText(),;
										oObj[nY]:getListComp()[nX]:getWidthTI(),;
										oObj[nY]:getListComp()[nX]:getCss(),;
										oObj[nY]:getListComp()[nX]:getIsFieldSet())
										
				Case oObj[nY]:getListComp()[nX]:cTp == 'LEG'
					  cHTML += WcLeg( oObj[nY]:getListComp()[nX]:cName,;
					  				    oObj[nY]:getListComp()[nX]:getCss(),;
					  				    oObj[nY]:getListComp()[nX]:cTitle )									
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³TextArea
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				Case oObj[nY]:getListComp()[nX]:cTp == 'TA'

					cHTML += WCTextArea(	oObj[nY]:getListComp()[nX]:cName,;
									 	oObj[nY]:getListComp()[nX]:cTitle,;
									 	oObj[nY]:getListComp()[nX]:cSize,;
									 	oObj[nY]:getListComp()[nX]:getColsArea(),;
										oObj[nY]:getListComp()[nX]:getRowsArea(),;									 										 	
									 	oObj[nY]:getListComp()[nX]:getValue(),;
									 	oObj[nY]:getListComp()[nX]:getObrigat(),;
									 	oObj[nY]:getListComp()[nX]:getReadOnly(),;
									 	oObj[nY]:getListComp()[nX]:getDisable(),;									 	
									 	oObj[nY]:getListComp()[nX]:getJSKeyDown(),;
									 	oObj[nY]:getListComp()[nX]:getJSFocOut(),;
									 	oObj[nY]:getListComp()[nX]:getIsFieldSet(),;
										oObj[nY]:getListComp()[nX]:getCss(),;
										oObj[nY]:getListComp()[nX]:getJSBlur(),;
										oObj[nY]:getListComp()[nX]:getXS(),;
									 	oObj[nY]:getListComp()[nX]:getSM(),;
									 	oObj[nY]:getListComp()[nX]:getMD(),;
									 	oObj[nY]:getListComp()[nX]:getLG(),;
									 	oObj[nY]:getListComp()[nX]:getCustom())

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Codigo HTML
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ										
				Case oObj[nY]:getListComp()[nX]:cTp == 'CHTM'
					cHTML += oObj[nY]:getListComp()[nX]:getValue()				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Radio Button
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		
				Case oObj[nY]:getListComp()[nX]:cTp == 'RADIO'
					  cHTML += WCRadio( 	oObj[nY]:getListComp()[nX]:cName,;
					  						oObj[nY]:getListComp()[nX]:cTitle,;
					  				    	oObj[nY]:getListComp()[nX]:getArrRadio(),;
					  				    	oObj[nY]:getListComp()[nX]:cType,;
					  				    	oObj[nY]:getListComp()[nX]:getXS(),;
									 		oObj[nY]:getListComp()[nX]:getSM(),;
									 		oObj[nY]:getListComp()[nX]:getMD(),;
									 		oObj[nY]:getListComp()[nX]:getLG(),;
									 		oObj[nY]:getListComp()[nX]:getCss(),;
									 		oObj[nY]:getListComp()[nX]:getCustom())	
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			  //³Alert Bootstrap
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		
			   Case oObj[nY]:getListComp()[nX]:cTp == 'ABS'				
					cHTML += WCAlertBS(oObj[nY]:getListComp()[nX]:cName,;
							  oObj[nY]:getListComp()[nX]:getCss(),;
							  oObj[nY]:getListComp()[nX]:getText(),;
							  oObj[nY]:getListComp()[nX]:getDisplay())
							  
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			  //³Help popover Bootstrap
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ				  
			  Case oObj[nY]:getListComp()[nX]:cTp == 'HPOPOVER'
			  		cHTML += WCPopOver(	oObj[nY]:getListComp()[nX]:cName,;
			  								oObj[nY]:getListComp()[nX]:cTitle,;
			  								oObj[nY]:getListComp()[nX]:getValue(),;
											oObj[nY]:getListComp()[nX]:getDisplay(),;			  											  								
					  				    		oObj[nY]:getListComp()[nX]:getXS(),;
									 		oObj[nY]:getListComp()[nX]:getSM(),;
									 		oObj[nY]:getListComp()[nX]:getMD(),;
									 		oObj[nY]:getListComp()[nX]:getLG())
			  						  			
			EndCase

	    Next
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Fechamento do agrupamento de componentes da linha
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If lOpenTitLeg
			cHTML += WCFLegGrou("F",,,,,,oObj[nY]:getHGroup())
			lOpenTitLeg	:= .f. 
			cFormatF	 	:= ''
		EndIf	
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Fechamento da linha
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cHTML += WCFTabLin("F")									
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fechamento do grupo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lOpenGroup
	cHTML += WCFTabGrou("F",cTitle,cOldGroup)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCHtmHead	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abertura de html											   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                         
Static Function WCHtmHead(lLibJs, lUserJs,cCsLib,cJsCode, cDtJs)
LOCAL cHTML 	:= ""       
LOCAL cDtJspls := ""
LOCAL cDtJsuser := ""
LOCAL aDtJs := {}
LOCAL nPos := 0
DEFAULT lLibJs 	:= .T.
DEFAULT lUserJs 	:= .F.  
DEFAULT cJsCode	:= ""
DEFAULT cDtJs		:= ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Abertura da tag
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHTML += "<!DOCTYPE html>"
cHTML += "<html>"
cHTML += "<head>"
cHTML += "<title>Portal do Plano de Saude</title>"
cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
cHTML += "<meta http-equiv='X-UA-Compatible' content='IE=Edge' > "
cHTML += "<meta name='viewport' content='width=device-width, initial-scale=1' >"
cHTML += "<meta name='description' content='' >"
cHTML += "<meta name='author' content='' >"
cHTML += "<link href='" + __PASTAWEB + "/estilo.css' rel='stylesheet' type='text/css'>"
cHTML += "<script type='text/javascript' src='pplanguage.js'></script>"
cHTML += "<script type='text/javascript' src='criaobj.js'></script>"

cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap/dist/css/bootstrap.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap-tour/bootstrap-tour.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap-tagsinput/bootstrap-tagsinput.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/metisMenu/css/metisMenu.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/datatables-plugins/css/dataTables.bootstrap.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/datatables-responsive/css/dataTables.responsive.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/layout-responsivo/css/layout-responsivo.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/font-awesome/css/font-awesome.css' rel='stylesheet' type='text/css'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/jquery-ui/jquery-ui.css' rel='stylesheet' type='text/css'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/bootstrap/select2/css/select2.css' rel='stylesheet'>"
cHTML += "<link href='" + __PASTAWEB + "/componentes/spinner/spinner.css' type='text/css'>"
cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery/jquery.js'></script>"
cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-ui/jquery-ui.js'></script>"
cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-base64/jquery.base64.js'></script>"

if !empty(cDtJs)
	aDtJs := Separa(cDtJs,'|',.t.)
	nPos := AScan( aDtJs , { |x| "jspls" $ x }  )
	cDtJspls :=  iif(nPos > 0,Separa(aDtJs[nPos],'@',.t.)[2], "" ) 
	nPos := AScan( aDtJs , { |x| "jsuser" $ x }  )
	cDtJsuser := iif(nPos > 0,Separa(aDtJs[nPos],'@',.t.)[2], "" ) 
endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Se usa lib js
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lUserJs
	cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/jsuser.js?"+cDtJsuser+"1'></script>"
EndIf

If lLibJs
	cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/jspls.js?"+cDtJspls+"1'></script>"
EndIf

If !Empty(cCsLib)
	cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/" + cCsLib + "'></script>"
EndIf
If !Empty(cJsCode)	
	cHTML += cJsCode		
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCForm	ºAutor  ³Alexander            º Data ³  11/02/12      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre/Fecha Formulario principal					  		     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                         
Static Function WCForm(cTp,cName,cAction,cMethod,cWidth,;
							cTitle,cJsFClick,cJsFImp,cFBack,;
							cNLinBtn,cAlign,cFuncLoad,aVar,aObrigat,;
							cJsFAgain, aCustomBtn)
LOCAL cHTML 		:= ""
LOCAL nI			:= 1 
LOCAL aBtnProp	:= {}   
DEFAULT cName		:= ""
DEFAULT cAction		:= ""
DEFAULT cMethod		:= "post"            
DEFAULT cWidth	 	:= ""
DEFAULT cTitle   	:= ""                 
DEFAULT cJsFClick	:= ""
DEFAULT cJsFImp  	:= ""
DEFAULT cFBack	 	:= ""                                        
DEFAULT cNLinBtn 	:= ""  
DEFAULT cAlign		:= ""
DEFAULT cFuncLoad		:= "" 
DEFAULT aObrigat		:= {}
DEFAULT aVar			:= {}
DEFAULT aCustomBtn	:= {}
Default cJsFAgain		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Ajuste aspas simples para dupla
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cJsFClick := StrTran(cJsFClick,"'",'"')
cJsFImp   := StrTran(cJsFImp,"'",'"')
cFBack 	  := StrTran(cFBack,"'",'"')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta form e body
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case
	Case cTp == 'A'
		cHTML += "</head>"
		cHTML += "<body class='space bodyResize'>"
		cHTML += "<form name='" + cName + "' action='" + cAction + "' method='" + cMethod + "'>"

		cHTML += "<div id='ModalPage'>"
		cHTML += "<div class='ModalBackground'></div>"
		cHTML += "<div id='ModalContainer' class='ModalContainer'></div>"
		cHTML += "</div>

		cHTML += "<div class='row'>"
		cHTML +=	"<div class='col-lg-12'>"
		cHTML +=		"<h3 class='page-header'>" + cTitle + "</h3>"
		cHTML +=	"</div>"
       cHTML += "</div>"
	Case cTp == 'F'		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Botoes no final da tela
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If !Empty(cJsFClick) .Or. !Empty(cJsFImp) .Or. !Empty(cFBack) .OR. !(Empty(cJsFAgain))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Faz o alinhamento do objeto
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ		   
				cHTML += "<div class='row'>"
					cHTML += "<div class='col-xs-12 col-sm-12' col-md-12 col-lg-12>"
			   
		   if upper(cAlign) == 'LEFT'
				cHTML += "<div class='posicaoLeft'>"
			elseIf upper(cAlign) == 'RIGHT'
				cHTML += "<div class='posicaoRight'>"
	   		endIf 
			
			If !Empty(cJsFClick)
				cHTML += "<button name='bconfirma' id='bconfirma' type='button' class='btn btn-default btn-end-scr' onclick='" + cJsFClick + "return false;'>Confirmar</button>"
			EndIf	        
			
			If !(Empty(cJsFAgain))
				cHTML += "<button name='bconfirmanovo' id='bconfirmanovo' type='button' class='btn btn-default btn-end-scr' onclick='" + cJsFAgain + "location.reload();'>Confirmar e Criar Novo</button>"
			EndIF
			
			If !Empty(cJsFImp)
				cHTML += "<button name='bimprimir' id='bimprimir' type='button' class='btn btn-default btn-end-scr disabled' onclick='" + cJsFImp + "'>imprimir</button>"
				cHTML += "<script>"
				cHTML += "// <![CDATA["
				cHTML += "	setDisable('bimprimir',true);"
				cHTML += "// ]]>"
				cHTML += "</script>"
			EndIf	
			
			If !Empty(aCustomBtn)
				for nI := 1 to len(aCustomBtn)
					aBtnProp := Separa(aCustomBtn[nI], "~")
					cHTML += "<button name='" + aBtnProp[1] + "' id='" + aBtnProp[1] + "' type='button' class='btn btn-default btn-end-scr' onclick='" + aBtnProp[3] + "'>" + aBtnProp[2] + "</button>"
				next nI
			EndIf
			
			If !Empty(cFBack)
				cHTML += "<button name='bVoltar' id='bVoltar' type='button' class='btn btn-default btn-end-scr' onclick='" + cFBack + "'>voltar</button>"
			EndIf	
						
			if upper(cAlign)  == 'LEFT' .OR. upper(cAlign) == 'RIGHT'
				cHTML += "</div>"
			endif
																																		
			cHTML += "</div>"
			cHTML += "</div>"
		EndIf

		cHTML += "</form>"
		
		
		//SCRIPTS NECESSÁRIOS PARA O FUNCIONAMENTO DO BOOTSTRAP E DA GRID RESPONSIVA
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery/jquery.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap/dist/js/bootstrap.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap-tour/bootstrap-tour.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/metisMenu/js/metisMenu.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/dataTables/js/jquery.dataTables.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/dataTables/js/moment.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/dataTables/js/datetime-moment.js'></script>"	
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/datatables-plugins/js/dataTables.bootstrap.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/layout-responsivo/js/layout-responsivo.js'></script>"
	    cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/componentes/iframeResizer/js/iframeResizer.contentWindow.js'></script>"
	    cHTML += "<script type='text/javascript' src='" + __PASTAWEB + "/schemeColor.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-ui/jquery-ui.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-mask/jquery.mask.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap/select2/js/select2.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-maskMoney/jquery.maskMoney.min.js'></script>"		
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/jquery-base64/jquery.base64.js'></script>"
	    cHTML += "<script src='" + __PASTAWEB + "/componentes/bootstrap-tagsinput/bootstrap-tagsinput.js'></script>"
		cHTML += "</body>"
		
		cHTML += "<script>"
				
		//script adicionado para telas que não são chamadas dentro do portal
		cHTML += " $(function() { "
		cHTML += "if (!isObject(parent.window.frames[0])){ "
		cHTML += "document.getElementsByTagName('body')[0].className = 'space'; }"
		cHTML += "}); "
		//********************************************************************//
		
		cHTML += " $(function() { "
		cHTML += "			$( '.datepicker' ).datepicker({ "         
		cHTML += "	    		dateFormat: 'dd/mm/yy', "
		cHTML += "	    		dayNames: ['Domingo','Segunda','Terça','Quarta','Quinta','Sexta','Sábado'], "
		cHTML += "	    		dayNamesMin: ['D','S','T','Q','Q','S','S','D'], "
		cHTML += "	    		dayNamesShort: ['Dom','Seg','Ter','Qua','Qui','Sex','Sáb','Dom'], "
		cHTML += "	    		monthNames: ['Janeiro','Fevereiro','Março','Abril','Maio','Junho','Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'], "
		cHTML += "	    		monthNamesShort: ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'], "
		cHTML += "	    		nextText: 'Próximo', "
		cHTML += "	    		prevText: 'Anterior' "   
		cHTML += "			});	 "  
		cHTML += " 		$( '.tooltipPad' ).tooltip({ "		
       cHTML += "				content: function () { "
       cHTML += "    			return $(this).data('title').replace('|', '<br />'); "
		cHTML += "	      		} "
		cHTML += " 		}); "
		cHTML += " 		$('.compSelect2').select2({ "
		cHTML += "				language: {"
       cHTML += "					noResults: function(){"
       cHTML += "   					return 'Sem resultados para a busca...';"
       cHTML += "					}"
   		cHTML += "				}"
		cHTML += "			}); "
		
		cHTML += "		$('.dropdown-toggle').dropdown();"
		
		
		cHTML += "}); "	
					
		cHTML += "</script>"
		cHTML += "</html>"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Insere a chamada de um JS no load da página
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If !Empty(cFuncLoad)
			cHTML += WCFuncLoad(cFuncLoad)
		EndIf
		If !Empty(aObrigat)
			cHTML += WCObrigat(aObrigat)
		else
			cHtml += " <script language='JavaScript'> "  + CRLF
				//Seta os campos obrigatórios para a validação no botão confirmar.
				cHTML += "var oForm = new xform( document.forms[0]) ;"  + CRLF
			cHtml += " </script> "
		EndIf
		If len(aVar) > 0
			cHTML += WCCriarVar(aVar)
		EndIf
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCPrint   ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Frame de impressao										   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function WCPrint(cTitle,cLabel,cName,cFileName,cFuncJs,cWidth,cMsgPlug)
LOCAL cHTML	:= ""              
LOCAL lPDF	:= At( 'PDF',Upper(cFileName) ) > 0
LOCAL nI := 1
LOCAL nLines := 1
LOCAL cMsgAux := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Impressao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If Empty(cFileName)
	cHTML += "</head>"
	cHTML += "<script>"
	
	If !EMPTY(cMsgPlug) 
		cHTML += "alert('" + cMsgPlug + "');"
	Else
		cHTML += "alert('Nenhuma informação foi encontrada para esta Consulta');"
	EndIf 
	
	cHTML += "window.close();"
	cHTML += "</script>"
Else
	cHTML += "</head>"
	cHTML += "<body style='overflow:hidden' leftmargin='0' topmargin='0' marginwidth='0' marginheight='0' class='space'>"
	cHTML += "<div class='conteiner' style='width:100%;'>"
	
	cHTML += "<table width='100%' height='100%' border='0' cellpadding='0' cellspacing='0'>"
	cHTML += "<tr><td height='30' class='TituloCab'>&raquo; " + cTitle + "</td>"
	
	If !lPDF
		cHTML += "<td align='right'><input type='button' name='button' value='" + cLabel + "' class='Botoes' onClick='" + cFuncJS + "'></td></tr>"
		cHTML += "</table>"
		cHTML += "<table style='width:100%>"
	EndIf	
	
	cHTML += "<tr><td align='center' valign='top'>"
	
	cHTML += " <div class='pdf'> "
	
	if !lPDF 
		cHTML += " 	<iframe align='left' id='" + cName + "' frameborder='0' width='100%' height='100%' src='" + __PASTAWEB + "/relatorios/" + cFileName + "'></iframe>"
	else	                    
	   
	    if(!empty(cMsgPlug))
		    nLines := MLCount( cMsgPlug )
	
			For nI := 1 to nLines
				if !(empty(memoLine(cMsgPlug,,nI)))
					cMsgAux += alltrim(strTran(strTran(memoLine(cMsgPlug,,nI), chr(10), ""), chr(13),"")) + " "
				endIf
			next nI 
			
			cMsgPlug := cMsgAux 
		endIf  
		         
		cHTML += " <script> "
		cHTML += " 	if (BrowserId.browser == 'IE' || BrowserId.browser == 'CH') { "
		cHTML += ' 		document.write("'
		cHTML += "  		<span class='TextoEnvEmail'></br>Caso não esteja visualizando este relatório : </span><a href='"  + __PASTAWEB + "/relatorios/" + lower(cFileName) + "' class='TextoCourierGreen' style='font-size: 15px;font-weight: bold'>Clique aqui.</a> </br> "  
		cHTML += 			iif(empty(cMsgPlug), "", cMsgPlug)
  		cHTML += "    		<embed type='application/pdf' src='" + __PASTAWEB + "/relatorios/" + lower(cFileName) + "' width='100%' height='100%'><noembed></noembed></embed> "
		cHTML += ' 		") '
		cHTML += " } else { "
		cHTML += ' 		document.write( "
		cHTML += " 			<object data='" + __PASTAWEB + "/relatorios/" + lower(cFileName) + "#view=fitH' type='application/pdf' width='100%' height='100%'><span class='TextoEnvEmail'></br>Não foi possível exibir o relatório, por favor, click no link para abrir.: </span><a href='"  + __PASTAWEB + "/relatorios/" + lower(cFileName) + "' class='TextoCourierGreen' style='font-size: 15px;font-weight: bold'>Exibir</a></object> "
		cHTML += ' 		") '
		cHTML += " } "
		cHTML += " </script> "
	endIf
	
	cHTML += " </div> "
	
	cHTML += "</td></tr>"
	cHTML += "</table> "                   
	
	cHTML += "</div>"
	cHTML += "</body>"  
	cHTML += "<script>"
    cHTML += "  parent.focus();"
  	cHTML += "</script>"	
	
	cHTML += "</html>"
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCFormTab	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre/Fecha Tabela do formulario principal				   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Static Function WCFormTab(cTp,lFolder,nId,lMenuFolder,aMenuFolder)
LOCAL nI			:= 0
LOCAL nJ			:= 0
LOCAL cHTML 	 	:= ""
LOCAL liClass          := "" 
LOCAL divClass   := ""    
DEFAULT lFolder	 	:= .f.
DEFAULT lMenuFolder	:= .f.
DEFAULT nId		 	:= 0
DEFAULT aMenuFolder	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Abre e fecha TAG INICAL DA PAGINA
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case  
	Case cTp == 'A' 		
		if lFolder
			if lMenuFolder
				cHTML += "<ul id='tabs' class='nav nav-tabs'>"
			
				for nI:=1 to len(aMenuFolder)
					liClass := IIf(nI == 1,"class='active'","")
					cHTML += "<li " + liClass + " ><a href='#id"+allTrim(cValToChar(nI))+aMenuFolder[nI]:cName+"' data-toggle='tab'>"+aMenuFolder[nI]:getTitFolder()+"</a></li>"
				next	
				
				cHTML += "</ul>"
				cHTML += "<div class='tab-content'>"	
          endIf
          
          divClass := IIf(nId == 1,"tabFC tab-pane fade in active","tabFC tab-pane fade")
			cHTML += "<div class='" + divClass + "' id='id"+allTrim(cValToChar(nId))+aMenuFolder[nId]:cName+"'>"
		endIf	
		
		cHTML += "<div class='row'>"
		
		//AQUI EU CRIO ABAS DENTRO DA TABLE
			if len(aMenuFolder[nId]:getListTables()) > 0 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Criacao das tabelas
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					for nI:=1 to len(aMenuFolder[nId]:getListTables())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³se vai criar o menu folder
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						if nI == 1 .and. aMenuFolder[nId]:getIsFolder()
							lMenuFolder := .t.
						endIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³Cria tabela
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						cHTML += WCFormTab( "A",;
											aMenuFolder[nId]:getIsFolder(),;
											nI,;
											lMenuFolder,;
											aMenuFolder[nId]:getListTables())
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³Criacao da Linha e seus componentes
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						if len(aMenuFolder[nId]:aTables[nI]:aLines) > 0 
							cHTML += montLine(aMenuFolder[nId]:getListTables()[nI]:getListLine())
						endIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³se vai criar o menu folder
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						lMenuFolder := .f.
						if nI == len(aMenuFolder[nId]:getListTables()) .and. aMenuFolder[nId]:getIsFolder()
							lMenuFolder := .t.
						endIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						//³Fechamento da tabela
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
						cHTML += WCFormTab( "F",;
											aMenuFolder[nId]:getIsFolder(),;
											/*nI*/,;
											lMenuFolder,;
											/*oObj:getListTables()*/)
					next
			endIf			
				
	Case cTp == 'F'                  
	
		cHTML += "</div>"     
		
		if lFolder
			cHTML += "</div>"	
			
			if lMenuFolder
				cHTML += "</div>"
			endIf	
		endIf	
EndCase		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCFTabLin	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre/Fecha TR de tabela e linha							   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function WCFTabLin(cTp, lProperties)
LOCAL cHTML 			:= ""
Default lProperties	:= .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Abre e fecha TAG TR de botoes de confirmacao da tela
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
do case  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Abre
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	case cTp == 'A' 
		 cHTML += "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Fecha
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	case cTp == 'F'       
		cHTML += "</div>"         
endCase	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCFTabGrouºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre/Fecha TR de grupo campos agrupados					   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCFTabGrou(cTp,cTitle,cNameGroup)
LOCAL cHTML 		:= "" 
DEFAULT cTitle		:= ""
DEFAULT cNameGroup 	:= ""                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta bloco
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case
	Case cTp == 'A'
		  cHTML += "<div class='panel panel-default'>"
		   cHTML += "<div class='panel-heading' style='cursor:pointer !important;' onclick="
		    	cHTML += "toggleDiv('I" + cNameGroup + "')>"
		      cHTML += "<h4 class='panel-title'>"
		           cHTML += cTitle
		      cHTML += "</h4>"
		    cHTML += "</div>"
		    
		    cHTML += "<div id='I" + cNameGroup + "' class='panel-collapse collapse in'>"
				cHTML += "<div class='panel-body'>"
	Case cTp == 'F'   
		  cHTML += "</div>"
		  cHTML += "</div>"
		  cHTML += "</div>"   
	EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCFLegGrouºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre/Fecha Grupo formatado								   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCFLegGrou(cTp,cFormatF,cTitle,cWidth,cPx,cPxLeft, lMaxMin,cNomeHGroup, cId)
LOCAL cHTML 			:= "" 
LOCAL cTdId			:= ""
LOCAL cHref          := ""
LOCAL cIde           := ""
                       
DEFAULT cFormatF		:= 'H'
DEFAULT cTitle		:= ""
DEFAULT lMaxMin		:= .F.
DEFAULT cNomeHGroup 	:= ""
DEFAULT cId          := ""

If Empty(cNomeHGroup)
	cNomeHGroup := SubStr( StrTran(cTitle," ","")  , 1, 12  )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Define agrupamento com possibilidade de ocultar
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lMaxMin .AND. cTp == 'A'
	cTdId		:= "'" + cNomeHGroup + "'"
	 cHTML += "<div class='panel panel-default'>"
		    cHTML += "<div class='panel-heading' style='cursor:pointer !important;' onclick="
		    	cHTML += "toggleDiv(" + cTdId + ")>"
		      cHTML += "<h4 class='panel-title'>"
		           cHTML += cTitle
		      cHTML += "</h4>"
		    cHTML += "</div>"
		    
		    cHTML += "<div id=" + cNomeHGroup + ">"
				cHTML += "<div class='panel-body'>"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Define agrupamento
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Do Case 
	Case cTp == 'A'
			cHTML	+= "<fieldset" + iif(!Empty(cId), " id='" + cId + "'", "") + ">"
			cHTML	+= iif(!Empty(cTitle),"<legend" + iif(!Empty(cId), " id='" + cId+"Legend" + "'", "") + ">" + cTitle + "</legend>" , "")
	Case cTp == 'F'
		cHTML	+= "</fieldset>"
		If lMaxMin
			 cHTML	+= "</div>"
    		 cHTML	+= "</div>"
    		 cHTML	+= "</div>"
		EndIf
EndCase		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCCombo	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria combobox											   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Static Function WCCombo(cName,cTitle,cSize,lTop,xSession,lOb,lDig,lDisabled,cJSChange,;
							cJSKeyDown,cJSKeyPre,cJsFBtn,cHelp,lGrupFS,lNoIte,cDefault,lName,;
							aVetOpcoes,lOpenGrp,lCloseGrp,cJsHelp,cXS,cSM,cMD,cLG,lPesquisa,cCssDiv,;
							lMultiple,cPlaceHolder,cCss,cJSFocus,cJSBlur, lCustom, lNaoVrRep)
LOCAL nI		 	:= 0
LOCAL cHTML		 	:= ""
LOCAL cIndObri       := ""
LOCAL cRequired      := ""
LOCAL cClassOBOP     := ""
LOCAL cClassPesq     := ""
LOCAL cMultiple      := ""
LOCAL xObjSes 	 	:= ""
LOCAL lPreTiss		:= .F.
LOCAL lAttr
DEFAULT xSession	:= ""
DEFAULT cJSChange 	:= ""
DEFAULT cJSKeyDown 	:= ""
DEFAULT cJSKeyPre	:= ""
DEFAULT cJsFBtn	 	:= ""
DEFAULT cHelp	 	:= ""
DEFAULT lTop		:= .f.
DEFAULT cDefault	:= ""
DEFAULT cJsHelp		:= ""
DEFAULT lOb		 	:= .f.                                                              
DEFAULT lDig	 	:= .f.
DEFAULT lDisabled	:= .f.
DEFAULT lGrupFS		:= .f.          
DEFAULT lNoIte		:= .f.
DEFAULT lName		:= .f.
DEFAULT lPesquisa := .F.
DEFAULT lMultiple := .F.
DEFAULT aVetOpcoes := {}
DEFAULT lOpenGrp		:= .F.
DEFAULT lCloseGrp := .F.
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "6"
DEFAULT cMD    		:= "6"
DEFAULT cLG    		:= "4"
DEFAULT cCssDiv      := ""
DEFAULT cPlaceHolder      := ""
DEFAULT cCss         := ""
DEFAULT cJSFocus		:= ""
DEFAULT cJSBlur		:= ""
DEFAULT lCustom      := .F.
DEFAULT lNaoVrRep      := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³HttpPost atribuido ao cDefault
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cCustom += iif(lCustom,"combo~"+cName+"|","")
lAttr := ((!Empty(cJsFBtn)).OR.(!Empty(cJsHelp)))
If  ValType( &('HttpPost->' + cName) ) != 'U' 
	cDefault := &('HttpPost->' + cName)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta variavel de sessao se informada ou utiliza o array de opções
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(aVetOpcoes)
	xObjSes := aVetOpcoes
ElseIf !Empty(xSession)
	xObjSes := &(xSession)
EndIf	

//Verifica se o combo do prestador irá concatenar os dados "Prestador, Local de Atendimento e Regime de Atendimento" (TISS)
lPreTiss :=  Type("lPrestTiss") <> "U" .And. xSession == "HttpSession->RDAVIEW"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Se obrigatorio ou opcional
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lOb
	cIndObri   := "<span style='color:red'>*</span>"
	cRequired  := " required"
	cClassOBOP := " TextoInputOB"
Else
	cIndObri   := ""
	cRequired  := ""
	cClassOBOP := " TextoInputOP"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Se é combo pesquisa
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cClassPesq := IIF(lPesquisa .OR. lMultiple, " compSelect2", " ")
cMultiple := IIF(lMultiple, " multiple='multiple'", " ")
cPlaceHolder := IIF(!Empty(cPlaceHolder), iif(lPesquisa .OR. lMultiple, "data-placeholder", "placeholder")+"='" + cPlaceHolder + "' ", " ")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Ajusta funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cJsFBtn 		:= StrTran(cJsFBtn		,"'",'"')
cJSChange 		:= StrTran(cJSChange	,"'",'"')
cJSKeyDown  	:= StrTran(cJSKeyDown	,"'",'"')
cJSKeyPre   	:= StrTran(cJSKeyPre	,"'",'"')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Definicao do obj
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + cCssDiv + "'>"	
cHTML += "<div class='form-group'>"
cHTML += "<label>" + cTitle + cIndObri + "</label>"

if lAttr
	cHTML += "<div class='input-group'>"
endif

cHTML += "	<select name='" + cName + "' id='" + cName + "' "

IF lDisabled
	cHTML += " disabled "
EndIf
If !Empty(cJSChange)
	cHTML +=  "onchange='" + cJSChange + "' "
EndIf
 
If !Empty(cJSKeyDown)
	cHTML +=  "onkeydown='" + cJSKeyDown + "' "
EndIf	

If !Empty(cJSKeyPre)
	cHTML +=  "onkeypress='" + cJSKeyPre + "' "
EndIf              

If !Empty(cJSFocus)
	cHTML += "onfocus='" + cJSFocus + "' "
EndIf

If !Empty(cJSBlur)
	cHTML += "onblur='" + cJSBlur + "' "
EndIf

cHTML += "class='form-control " + cClassOBOP + cClassPesq + " "  + cCss + "' " + cMultiple + cPlaceholder + iif(lDisabled, " disabled", "") + " >"

if lDisabled
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('" + cName + "',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf
	
If ValType(xObjSes) <> "U" .AND. !Empty(xObjSes)
	If ValType(xObjSes[1]) == "O" .And. !Empty(xSession) .And. !lPreTiss // Veio uma session
		If lDisabled .And. !lNoIte
			For nI := 1 To Len( xObjSes )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Nao inclui registro duplicado
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				if at(allTrim(iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription)),cHTML) == 0
					cHTML += "<option value='" + xObjSes[nI]:cCode + "' " + Iif( &('HttpPost->' + cName)  ==  xObjSes[nI]:cCode, "SELECTED", "" ) + "> " + iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription) + " </option>"
				endIf	
			Next nI
			
		ElseIf Len( xObjSes ) >= 1
			cHTML += iif(lMultiple, "", "<option value=''>-- Selecione um Item --</option>")
					
			For nI := 1 To Len( xObjSes )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				//³Nao inclui registro duplicado
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
				if at(allTrim(iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription)),cHTML) == 0 .or. lNaoVrRep

					cHTML += "<option value='" + xObjSes[nI]:cCode + "' " + Iif( cDefault  ==  xObjSes[nI]:cCode, "SELECTED", "") + "> " + iIf(lName,xObjSes[nI]:cName,xObjSes[nI]:cDescription) + " </option>"
				endIf	
			Next nI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Quando esta habilitado a digitacao e pesquisa no combo.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		ElseIf Empty( xObjSes ) .And. lDig
			cHTML += iif(lMultiple, "", "<option value=''>-- Selecione um Item --</option>")
			
		ElseIf Len( xObjSes ) > 0
			cHTML += "<option value='" + xObjSes[1]:cCode + "' SELECTED> " + iIf(lName,xObjSes[1]:cName,xObjSes[1]:cDescription) + "</option>"
			If !Empty(cJSChange)
				cHTML += "<script>"
				cHTML += "// <![CDATA["
				cHTML += cJSChange
				cHTML += "// ]]>"
				cHTML += "</script>"
			EndIf	
		EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Criada opcao de envio de array para tratamento nas novas guias TISS
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	ElseIf ValType(xObjSes) == "A" // Veio um array de opcoes
		If !lPreTiss	
			If lDisabled .And. !lNoIte .and. empty(cDefault)
				For nI := 1 To Len( xObjSes )
					cGetCode := Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1))
					cGetName := Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) ))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Nao inclui registro duplicado
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					if At("value='"+cGetCode+"'",cHTML) == 0 .AND. At("> " + cGetName + " <",cHTML)== 0
						cHTML += "<option value='" + cGetCode + "' SELECTED> " + cGetName + " </option>"
					endIf	
				Next nI
				
			ElseIf Len( xObjSes ) > 1 .and. !Empty(cDefault)
				cHTML += iif(lMultiple,"","<option value=''>-- Selecione um Item --</option>")
							
				For nI := 1 To Len( xObjSes )
					cGetCode := Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1))
					If Alltrim(cGetCode) == cDefault
						cHTML += "<option value='" + Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1)) + "' SELECTED	> " + Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) )) + "</option>"
					Else		
						cHTML += "<option value='" + Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1)) + "'> " + Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) )) + "</option>"									
					EndIf	
				Next nI
				
			ElseIf Len( xObjSes ) > 1 .and. Empty(cDefault)
				cHTML += iif(lMultiple,"", "<option value='SELECTED'>-- Selecione um Item --</option>")				
				
				For nI := 1 To Len( xObjSes )
					cGetCode := Alltrim(SubStr(xObjSes[nI], 1, At("=",xObjSes[nI])-1))
					cGetName := Alltrim(SubStr(xObjSes[nI], At("=",xObjSes[nI])+1, Len(xObjSes[nI]) ))
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Nao inclui registro duplicado
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					if At("value='"+cGetCode+"'",cHTML) == 0 .AND. At("> " + cGetName + " <",cHTML)== 0
						cHTML += "<option value='" + cGetCode + "'" + Iif( cDefault  ==  cGetCode, "SELECTED", "") + "> " + cGetName + " </option>"					
					endIf	
				Next nI					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Quando esta habilitado a digitacao e pesquisa no combo.
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		ElseIf Empty( xObjSes ) .And. lDig
			cHTML += iif(lMultiple, "", "<option value=''>-- Selecione um Item --</option>")
			
			ElseIf Len( xObjSes ) > 0
				cGetCode := Alltrim(SubStr(xObjSes[1], 1, At("=",xObjSes[1])-1))
				cGetName := Alltrim(SubStr(xObjSes[1], At("=",xObjSes[1])+1, Len(xObjSes[1]) ))
				
				cHTML += "<option value='" + cGetCode + "' SELECTED	> " + cGetName + "</option>"
				If !Empty(cJSChange)
					cHTML += "<script>"
					cHTML += "// <![CDATA["
					cHTML += cJSChange
					cHTML += "// ]]>"
					cHTML += "</script>"
				EndIf	
			EndIf	
		Else
			//Padrão de item no combo prestador: "PRESTADOR, LOCAL DE ATENDIMENTO e REGIME DE ATENDIMENTO"
			If lDisabled .And. !lNoIte
				For nI := 1 To Len( xObjSes )
					cCode 		:= Alltrim(xObjSes[nI]:cCode)
					cCodLoc 	:= AllTrim(xObjSes[nI]:cCodLoc)
					cPrest		:= Alltrim(xObjSes[nI]:cName) + " - " + Alltrim(xObjSes[nI]:cDesLoc) + " - " + Alltrim(xObjSes[nI]:cRegAtend)
					//Verifica duplicidade
					if At("value='"+cCode+"|"+cCodLoc+"'",cHTML) == 0
						cHTML += "<option value='"+cCode+"|"+cCodLoc+"' SELECTED> " + cPrest + " </option>"
					endIf	
				Next nI				
			ElseIf Len( xObjSes ) >= 1
				cHTML += iif(lMultiple,"","<option value=''>-- Selecione um Item --</option>")
				For nI := 1 To Len( xObjSes )
					cCode 		:= Alltrim(xObjSes[nI]:cCode)
					cCodLoc 	:= AllTrim(xObjSes[nI]:cCodLoc)
					cPrest		:= Alltrim(xObjSes[nI]:cName) + " - " + Alltrim(xObjSes[nI]:cDesLoc) + " - " + Alltrim(xObjSes[nI]:cRegAtend)
					//Verifica duplicidade
					if At("value='"+cCode+"|"+cCodLoc+"'",cHTML) == 0
						cHTML += "<option value='"+cCode+"|"+cCodLoc+"'" + Iif( cDefault  ==  cCode, "SELECTED", "") + "> " + cPrest + " </option>"					
					endIf
				Next nI			
			EndIf	
		EndIf		
	EndIF         
Else
	cHTML += iif(lMultiple,"", "<option value=''>-- Selecione um Item --</option>")
EndIf
	
cHTML += "</select>"

if lAttr
	cHTML += "<span class='input-group-btn'>"
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botão de plus
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJsFBtn)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='" + cJsFBtn + "'><i class='fa fa-plus'></i></button>"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botão de help que chama pop
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cHelp)	
		cHTML += "<button type ='button' name='" + cHelp + "' id='" + cHelp + "' class='btn btn-default' title='Ajuda' onclick='fAbre(" + '"W_PPLSHELP.APW"' + ")'><i class='fa fa-question-circle'></i></button>"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botão de help
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJsHelp)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='" + strtran(cJsHelp,"'",'"') + "'><i class='fa fa-question-circle'></i></button>"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fecha o input-group
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lAttr
	cHTML += "</span>"
	cHTML += "</div>"
endif

cHTML += "</div>"
cHTML += "</div>"     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCField	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria campo												   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCField(cName,cTitle,cSize,cTp,lTop,cMLength,cValue,lOb,lRO,lDi,;
							cJSKeyDown,cJSKeyPre,cJSBlur,cJSFocOut,cJsFF3,cJSChange,;
							lGrupFS,cCss,cJsFBtn,lOpenGrp,lCloseGrp, cJSFocus,cJsFBtL,;
							cJsHelp,cToolTip ,lNumber,lData, cXS,cSM,cMD,cLG, cCssDiv,;
							cPlaceHolder, nMinValue, nMaxValue, lCustom, lTagInput)
							
LOCAL cHTML			:= ""
LOCAL cReadOnly		:= ""
LOCAL cIndObri       := ""
LOCAL cRequired      := ""
LOCAL cClassOBOP     := ""
LOCAL cClassData     := ""
LOCAL cClassHint     := ""
LOCAL lAttr          := .F.
LOCAL cMinValue      := ""
LOCAL cMaxValue      := ""
DEFAULT cTitle 		:= "&nbsp;"
DEFAULT cSize    		:= ""
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "6"
DEFAULT cMD    		:= "6"
DEFAULT cLG    		:= "4"
DEFAULT cTp			:= "text"
DEFAULT cValue		:= ""
DEFAULT cMLength  	:= "0"
DEFAULT lRO   		:= .F.
DEFAULT lDi			:= .F.                                
DEFAULT lOb			:= .F.                                                 
DEFAULT cJSKeyPre		:= ""   
DEFAULT cJSKeyDown	:= ""
DEFAULT cJSBlur		:= ""             
DEFAULT cJSFocOut		:= ""       
DEFAULT cJSChange		:= ""
DEFAULT cJsFF3		:= ""
DEFAULT cJsFBtL		:= ""
DEFAULT cJsHelp		:= ""
DEFAULT lGrupFS		:= .F.     
DEFAULT lTop			:= .f.
DEFAULT cJsFBtn		:= ""
DEFAULT lOpenGrp		:= .F.
DEFAULT lCloseGrp		:= .F.
DEFAULT cToolTip		:= ''
DEFAULT lNumber		:= SubStr(cName,1,1) == "n"	
DEFAULT lData  		:=  .F.
DEFAULT cCssDiv      := ""	
DEFAULT cPlaceHolder := ""
DEFAULT cCss			:= ""
DEFAULT lCustom      := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ReadOnly, Disabled, Css, FocusOut e JsFunc
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cCustom += iif(lCustom,"text~"+cName+"|","")
cReadOnly 	:= Iif(lRO,"READONLY","")
cClassData := Iif(lData," datepicker","")
cClassHint := Iif(!Empty(cToolTip), " tooltipPad", "")
cPlaceHolder := IIF(!Empty(cPlaceHolder), " placeholder='" + cPlaceHolder + "' ", " ")
If lOb
	cIndObri   := "<span style='color:red'>*</span>"
	cRequired  := " required"
	cClassOBOP := " TextoInputOB"
Else
	cIndObri   := ""
	cRequired  := ""
	cClassOBOP := " TextoInputOP"
EndIf
cJSKeyPre	:= StrTran(cJSKeyPre,"'",'"')
cJSKeyDown	:= StrTran(cJSKeyDown,"'",'"')
cJSBlur		:= StrTran(cJSBlur,"'",'"')
cJSFocOut	:= StrTran(cJSFocOut,"'",'"')
cJSFF3		:= StrTran(cJsFF3,"'",'"')
cJSChange	:= StrTran(cJSChange,"'",'"')
cJsFBtn 		:= StrTran(cJsFBtn		,"'",'"')
lAttr      := ((!Empty(cJsFF3)).OR.(!Empty(cJsFBtn)).OR.(!Empty(cJsFBtl)).OR.(!Empty(cJsHelp)))

cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "


cHTML += "<div class='" + cXS + cSM + cMD + cLG + " " + cCssDiv + "'>"	
cHTML += "<div class='form-group'>"

//If cName <> "cProExe"
	cHTML += Iif(cName == "cProExe" ,"", "<label>" + cTitle + cIndObri + "</label>")
//EndIf

if lAttr .OR. lNumber
	cHTML += "<div class='input-group'>"
endif

If lNumber
	cHTML += "<span class='input-group-btn'>"
	If nMinValue+nMaxValue <> 0 
		cMinValue += "controlNumberVal(this," + ALLTRIM(STR(nMinValue)) + ", " + ALLTRIM(STR(nMaxValue)) + ")"
	Else
		cMinValue += "controlNumberVal(this, 0, 0)"
	EndIf
	cHTML += 	"<button type ='button' name='sub" + cName + "' onclick='" + cMinValue + "' class='btn btn-default'><i class='fa fa-minus'></i></button>"
	cHTML += "</span>"
EndIf

//Adiciona as máscaras nos campos BA1_CPFUSR, BA1_CEPUSR, BA1_TELEFO no portal. 
Do Case

	Case cName == "cBA1_CPFUSR" .Or. cName == "cBA1_CEPUSR" 
		cValue := Trans(cValue, PesqPict("BA1", SubStr(cName,2,len(cName)))) 

	Case cName == "cBA1_TELEFO"  
		cValue := Transform(cValue, "@E 9999-99999")

EndCase

cHTML += "<input name='" + cName + "' id='" + cName + "' type='" + Iif(cName == "cProExe", "Hidden", cTp) + "' class='form-control " + cClassOBOP + cClassData + cClassHint + " " + cCss+ "'" + cPlaceHolder + " value='" + cValue + "' size='" + cSize + "' maxlength='" + cMLength +"' " + cReadOnly + cRequired + iif(lDi, " " + cReadOnly, "") + iif(lTagInput, " data-role='tagsinput'", "")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³KeyPress
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSKeyPre)     
	cHTML	+= " onKeyPress='" + cJSKeyPre + "'" 
EndIf	                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³KeyDown
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSKeyDown)
	cHTML +=  "onkeydown='" + cJSKeyDown + "' "
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Blur
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSBlur) 
	cHTML	+= " onblur='" + cJSBlur + "'"
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Change
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSChange)
	cHTML	+= " onchange='" + cJSChange + "'"
EndIf          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Focus
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSFocus)
	cHTML	+= " onfocus='" + cJSFocus + "'"
EndIf 

//quando tem a lupa e a funcao de validacao eh a fChKBTQ, eu faco tooltip. (essa funcao eh responsavel por mexer no atributo da descricao	                                          
If !Empty(cJsFF3) .and. cToolTip == '1'
	cHTML +=  " placeholder='Selecione uma opção' "
ElseIf Empty(cJsFF3) .and. cToolTip <> '1' .and. !Empty(cToolTip) 
	cHTML +=  " title=' " + cTooltip + " ' " 
ElseIf !Empty(cTooltip)
	cHTML +=  " title=' " + cTooltip + " ' " 
Endif    

cHTML += "/>"
//BOTAO MAIS

If lNumber
	cHTML += "<span class='input-group-btn'>"
	If nMinValue+nMaxValue <> 0 
		cMaxValue += "controlNumberVal(this, " + ALLTRIM(STR(nMinValue)) + ", " + ALLTRIM(STR(nMaxValue)) + ")"
	Else
		cMaxValue += "controlNumberVal(this, 0, 0)"
	EndIf
	cHTML += 	"<button type ='button' name='add" + cName + "' onclick='"+ cMaxValue +"' class='btn btn-default'><i class='fa fa-plus'></i></button>"
EndIf

if lAttr .AND. !lNumber //se for lnumber, já abri o grupo span acima no BOTÃO MAIS
	cHTML += "<span class='input-group-btn'>"
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Disable
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lDi
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('"+cName+"',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botao de F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJsFF3)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='if(!this.disabled)" + cJsFF3 + "'><i class='fa fa-search'></i></button>"
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botão de plus
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJsFBtn)
	cHTML += "<button type ='button' name='B" + cName + "' id='Ba" + cName + "' class='btn btn-default' onclick='" + cJsFBtn + "'><i class='fa fa-plus'></i></button>"
EndIf
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botao de refresh
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJsFBtL)
	cHTML += "<button  type ='button' name='B" + cName + "' id='Br" + cName + "' class='btn btn-default' onclick='" + cJsFBtL + "'><i class='fa fa-refresh'></i></button>"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria botão de help
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJsHelp)
	cHTML += "<button type ='button' name='B" + cName + "' id='B" + cName + "' class='btn btn-default' onclick='" + cJsHelp + "'><i class='fa fa-question-circle'></i></button>"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fecha o input-group
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lAttr .OR. lNumber
	cHTML += "</span>"
	cHTML += "</div>"
endif
cHTML += "</div>"
cHTML += "</div>"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCButton	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria botao												   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCButton(cName,cTitle,cJsFunc,lDi,cAlign,cCssClass, lTdIE,lOpenGrp,lCloseGrp,cXS,cSM,cMD,cLG,lInline,aListOpt)
LOCAL cHTML		:= ""
LOCAL cNameD		:= ""
Local nCont	:= 0
DEFAULT lDi	    := .F.                     
DEFAULT cAlign		:= ""
DEFAULT cCssClass		:= ""
DEFAULT lTdIE			:= .T.
DEFAULT lOpenGrp			:= .F.
DEFAULT lCloseGrp			:= .F.
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "12"
DEFAULT cMD    		:= "12"
DEFAULT cLG    		:= "12"
DEFAULT lInline       	:= .F.
DEFAULT aListOpt       := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Para controle o disabled deve ter um asterisco no nome
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lDi
	cNameD 	:= "*"                
else
	cNameD 	:= cName
endIf

cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "


If lOpenGrp
	cHTML += "<div class='" + cXS + cSM + cMD + cLG + iif(lInline, "buttons-inline'", "'") + ">"	
	cHTML += iif(lInline, "<div class='buttons-inline-2'>", '')	
EndIf
	                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Ajustes nos parametros enviados para jsFunc
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cJsFunc := strTran(cJsFunc,"'",'"')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Alinhamento do componente
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if upper(cAlign) == 'LEFT'
	cHTML += "<div class='posicaoLeft'>"
elseIf upper(cAlign) == 'RIGHT'
	cHTML += "<div class='posicaoRight'>"
endIf    

If Len(aListOpt) > 0
	cHtml += "<div class='btn-group'>"
	cHTML += "<button name='" + cNameD + "' id='" + cName + "' class='btn btn-default dropdown-toggle " + cCssClass + "' type='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>" + cTitle + "</button>"
    
	cHTML += "<ul class='dropdown-menu' role='menu'>"
	For nCont := 1 To Len(aListOpt)
		cHTML += "  <li role='presentation'><a class='dropdown-item' href=javascript:" + aListOpt[nCont,2] + ">" + aListOpt[nCont,1] + "</a></li>"   
	Next nCont
	cHTML += " </ul>"
	
	cHtml += "</div>"
Else
	cHtml += "<button name='" + cNameD + "' id='" + cName + "' type='button' class='btn btn-default " + cCssClass + "' onclick='" + cJsFunc + "' style='margin-right:10px;' >" + cTitle + "</button>"
EndIf

if !(empty(cAlign))
	cHTML += "</div>"
endIf

if lDi
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('"+cName+"',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf

If lCloseGrp
	cHTML += iif(lInline, "</div>", '')	
	cHTML += "</div>"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML                  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCButImg	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria botao com img										   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCButImg(cName,cJsFunc,cHelp,cImg,lDi,lGrupFS, cWidth, cHeight)
LOCAL cHTML		:= ""
DEFAULT cImg 		:= "/chk.gif"
DEFAULT cHelp 		:= "Pesquisa"
DEFAULT lDi	    := .F.                     
DEFAULT lGrupFS 	:= .F.
DEFAULT cWidth	:= "18"
DEFAULT cHeight	:= "18"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Ajustes nos parametros enviados para jsFunc
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cJsFunc := StrTran(cJsFunc,"'",'"')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria campo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !lGrupFS
	cHTML += "<td><img src='" + __PASTAWEB + cImg +"' id='" + cName + "' name='" + cName + "'  title='" + cHelp + "' width='" + cWidth + "' height='" + cHeight + "' border='0' align='top' class='img' onClick='" + cJsFunc + "' /></td>"
Else
	cHTML += "<img src='" + __PASTAWEB + cImg +"' id='" + cName + "' name='" + cName + "'  title='" + cHelp + "' width='" + cWidth + "' height='" + cHeight + "' border='0' class='img' onClick='" + cJsFunc + "' />"
EndIf	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Disabled
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
if lDi
	cHTML += "<script>"
	cHTML += "// <![CDATA["
	cHTML += "	setDisable('"+cName+"',true);"
	cHTML += "// ]]>"
	cHTML += "</script>"
endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCTextInf	ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Texto informtivo											   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCTextInf(cText,cWidth,cCss,lGrupFS)
LOCAL cHTML	:= ""
LOCAL cCssFS	:= "box"
LOCAL cCssDiv	:= cCss
LOCAL aCSS		:= {}

If "|" $ cCss // pode ser passado com pipe para determinar o CSS da FieldSet junto
	aCSS := StrToArray(cCss, "|")
	cCssFS := aCSS[1]
	cCssDiv := aCSS[2]
EndIf

cHTML += "<fieldset class='" + cCssFS + "' style='width: " + cWidth + "px;'>"
cHTML += "<div class= '" + cCssDiv + "' style='display: inline-block;white-space: normal;border:none;' >" + cText + "</div>"
cHTML += "</fieldset>"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³WCBrwGrid ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Grid de dados - trabalha em conjunto com a gridData (JS)	  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCBrwGrid(cName,cTitulo,cWidth,cHeight,lGrupFS,cJsFunc, aHeader, aCols, lAltGrid, lDelGrid)
LOCAL cHTML			:= ""
LOCAL nI := 0
LOCAL nJ := 0
DEFAULT lGrupFS 	:= .F.
DEFAULT aHeader  := {}
DEFAULT aCols  := {}
DEFAULT lAltGrid := .T.
DEFAULT lDelGrid := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Conteiner para o Brw
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cName := alltrim(cName)
cHTML += "<div class='row'>"
cHTML += "<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12' style='overflow-x:auto; width:98%; /*margin-left:20px;*/'>"            
cHTML += "<div id='"+ cName +"' class='dataTable_wrapper'>"

	If  len(aHeader) > 0 .AND. len(aCols) > 0
		cHTML += "<table id='tab" + cName + "' class='table table-striped table-bordered table-hover dt-responsive' cellspacing='0' cellpadding='0' style='width: 100%;'>"
		cHTML += "		<thead class='cabacalho'>"
		cHTML += "				<tr>"
		cHTML += "					<th>Item</th>"
		If lAltGrid
			cHTML += "					<th>Alterar</th>"
		EndIf
		If lDelGrid	
			cHTML += "					<th>Excluir</th>"
		EndIf
		
									For nI := 1 to len(aHeader)
			if "CMPSEQ" $ aHeader[nI]
				cHTML += "<th style='display: none'>" + aHeader[nI] + "</th>"
			else
										cHTML += "<th>" + aHeader[nI] + "</th>"
			EndIf
									Next nI
		
		cHTML += "				</tr>"
		cHTML += "		</thead>"
		cHTML += "		<tbody class='conteudo'>"    //para cada registro
		
						For nI := 1 to len(aCols)
		cHTML += "				<tr id='Linha" + cName + alltrim(str(nI)) + "' bgcolor='#FFFFFF'>"
		cHTML += "					<th id='Cont" + cName + alltrim(str(nI)) + "'>" + alltrim(str(nI)) + "</th>"
		If lAltGrid
			cHTML += "					<td>"																																	
			cHTML += "						<center><img id='btn" + cName + alltrim(str(nI - 1)) +  "' class='colBtn' src='imagens-pls/refresh.gif' onclick='fVisRecGen(" + alltrim(str(nI))/*alltrim(STR(aCols[nI][len(aCols[nI])]))*/ + "," + cName + ".id,4)' alt='Alterar'></center>"
			cHTML += "					</td>"
		EndIf
		
		If lDelGrid
			cHTML += "					<td>"																																	
			cHTML += "						<center><img id='btn" + cName + alltrim(str(nI - 1)) +  "' class='colBtn' src='imagens-pls/004.gif' onclick='fGetDadGen(" + alltrim(str(nI))/*alltrim(STR(aCols[nI][len(aCols[nI])]))*/  + "," + cName + ".id,5,true,&quot;&quot; ,&quot;&quot; ,cCampoDefault)' alt='Excluir'></center>"
			cHTML += "					</td>"
		EndIf							
								
			For nJ := 1 to (len(aCols[nI]))
				if "CMPSEQ" $ aHeader[nJ]
					cHTML += "<td style='display: none !important'>" + aCols[nI][nJ] + '<mark class="markInv"> *CMPSEQ </mark>' + "</td>"
				else
					cHTML += "<td>" + aCols[nI][nJ] + "</td>"
				EndIf
										Next nJ
			
		cHTML += "				</tr>"
						Next nI
		cHTML += "		</tbody>"
		cHTML += "	</table>" 
	EndIf

cHTML += "</div>"
cHTML += "<div id='Rodape"+ cName +"' class='row'>"

If  len(aHeader) > 0 .AND. len(aCols) > 0
	cHTML += "				<div id='" + cName + "Pagination' class='infoBarBottom left col-xs-12 col-sm-12 col-md-12 col-lg-12'>"
	cHTML += "					<div id='" + cName + "DivGroupPage' class='input-group'>"
	cHTML += "						<span id='" + cName + "SpanGroupPage1' class='input-group-btn'>"
	cHTML += "							<button id='" + cName + "first' type='button' class='btn btn-default' disabled='' onclick=" + "navGridDat('" + cName + "','','first')>Primeiro</button>"
	cHTML += "							<button id='" + cName + "prev' type='button' class='btn btn-default' disabled='' onclick=" + "navGridDat('" + cName + "','','prev')>Anterior</button>"
	cHTML += "							<button id='" + cName + "next' type='button' class='btn btn-default' onclick=" + "navGridDat('" + cName + "','','next')>Próximo</button>"
	cHTML += "							<button id='" + cName + "last' type='button' class='btn btn-default' onclick=" + "navGridDat('" + cName + "','','last')>Último</button>"
	cHTML += "						</span>"
	cHTML += "						<input id='" + cName + "pageNum' type='text' class='form-control' placeholder='Nº' style='max-width: 100px; min-width: 70px;'>"
	cHTML += "						<span id='" + cName + "SpanGroupPage2' class='input-group-page-ok'>"
	cHTML += "							<button id='" + cName + "SetPage' type='button' class='btn btn-default' onclick=" + "navGridDat('" + cName + "','','pageNum')>OK</button>"
	cHTML += "						</span>"
	cHTML += "					</div>"
	cHTML += "				</div>"
	cHTML += "				<div id='" + cName + "Page' class='infoBarBottom left col-xs-12 col-sm-12 col-md-12 col-lg-12'>Página: 1 de </div>"
	cHTML += "				<div id='" + cName + "RegTot' class='infoBarBottom right col-xs-12 col-sm-12 col-md-12 col-lg-12'>Total de Registro(s) : </div>"
	cHTML += "				<input id='" + cName + "nPagina' type='hidden' value='1'>"
	cHTML += "				<input id='" + cName + "nQtdPag' type='hidden' value=''>"
	cHTML += "				<input id='" + cName + "nQtdReg' type='hidden' value=''>"
EndIf



cHTML += "</div>"
cHTML += "</div>"
cHTML += "</div>"   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCFHidden ºAutor  ³Alexander            º Data ³  11/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria botao												   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function WCFHidden(cName,cValue)
LOCAL cHTML		:= ""     
DEFAULT cValue	:= ""

If ValType(cValue) == "C"
	cHTML += "<input type='hidden' name='" + cName + "' id='" + cName + "' value='" + cValue + "'>"
ElseIf ValType(cValue) == "N"
	cHTML += "<input type='hidden' name='" + cName + "' id='" + cName + "' value='" + cValToChar(cValue) + "'>"
ElseIf ValType(cValue) == "D"
	cHTML += "<input type='hidden' name='" + cName + "' id='" + cName + "' value='" + DToS(cValue) + "'>"
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WCArrPost   ³Autor  ³ Alexander             ³ Data ³16.06.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de recuperacao do header das estruturas 				 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                
Function WCArrPost(oObj)
LOCAL nI := 0                           
LOCAL nX := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Monta Estrutura iniciar do obj de dados genericos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oObj := PLSXINC_ARRAYOFSDADFIELD():New()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Enviados via post
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
For nI:=1 To Len(HttpPost->aPost)

	If At( 'field', Lower(HttpPost->aPost[nI]) ) > 0                   
	
		AaDd( oObj:oWSSDADFIELD, PLSXINC_SDADFIELD():New() )
		
		nX := Len(oObj:oWSSDADFIELD)
		
		oObj:OWSSDADFIELD[nX]:cFIELD := HttpPost->aPost[nI]
		oObj:oWSSDADFIELD[nX]:cVALUE := &("HttpPost->" + HttpPost->aPost[nI])
		
	EndIf	
	
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return oObj
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCTextArea	ºAutor  ³Saude                º Data ³  18/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria TEXTAREA (Memo)   										     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/

Static Function WCTextArea(cName,cTitle,cSize,cCols, cRows,cValue,lOb,lRO,lDi,cJSKeyDown,cJSFocOut,lGrupFS,cCss,cJSBlur,cXS,cSM,cMD,cLG, lCustom)
LOCAL cHTML			:= ""
LOCAL cIndObri       := ""
LOCAL cClassOBOP     := ""
//LOCAL cReadOnly		:= ""
LOCAL cDisabled 		:= ""
LOCAL cCssObri		:= ""  
DEFAULT cSize    		:= ""
DEFAULT cXS    		:= "12"
DEFAULT cSM    		:= "6"
DEFAULT cMD    		:= "6"
DEFAULT cLG    		:= "4"
DEFAULT cValue		:= ""
DEFAULT lRO   		:= .F.
DEFAULT lDi			:= .F.                                
DEFAULT lOb			:= .F.                                                 
DEFAULT cJSKeyDown	:= ""
DEFAULT cJSFocOut		:= ""       
DEFAULT lGrupFS		:= .F.     
//DEFAULT cWidth		:= ""
DEFAULT cCols			:= "50"
DEFAULT cRows			:= "4" 
DEFAULT cJSBlur			:= ""
DEFAULT lCustom      := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ReadOnly, Disabled, Css, FocusOut e JsFunc
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cCustom += iif(lCustom,"textarea~"+cName+"|","")
cDisabled 	:= Iif(lDi,"DISABLED","")
If lOb
	cIndObri   := "<span style='color:red'>*</span>"
	cClassOBOP := " TextoInputOB"
Else
	cIndObri   := ""
	cClassOBOP := " TextoInputOP"
EndIf
cJSKeyDown	:= StrTran(cJSKeyDown,"'",'"')
cJSFocOut	:= StrTran(cJSFocOut,"'",'"')        
cJSBlur		:= StrTran(cJSBlur,"'",'"')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Cria campo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + "'>"	
cHTML += "<div class='form-group'>"
cHTML += "<label>" + cTitle + cIndObri + "</label>"
cHTML	+= "<textarea class='form-control" + cClassOBOP + '" name=' + cName + "' id='" + cName  + "' cols='" + cCols + "' rows='" + cRows + "'  value='" + cValue + "' size='" + cSize + "' " + cDisabled + " maxlength='"+ cSize +"'"  //></textarea>
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³KeyDown
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lRO
	cHTML +=  " readonly='Yes' "
EndIf	
                      
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³KeyDown
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSKeyDown)
	cHTML +=  " onkeydown='" + cJSKeyDown + "' "
EndIf	

If !Empty(cJSBlur) 
	cHTML	+= " onblur='" + cJSBlur + "'"
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³FocusOut
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cJSFocOut)
	cHTML	+= " onfocusout='" + cJSFocOut + "'"
EndIf          

cHTML	+= " />"

cHTML	+= cValue // Atribuindo valor DEFAULT.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fecha lebal pois o input vai ficar abaixo do label
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cHTML	+= "</textarea>"
cHTML  += "</div>"
cHTML  += "</div>"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCTextArea	ºAutor  ³Saude                º Data ³  18/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria TEXTAREA (Memo)   										     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/

Static Function WCFuncLoad(cFuncLoad)
LOCAL cHTML			:= ""

cHtml += " <script language='JavaScript'> "
cHtml +=  cFuncLoad
cHtml += " </script> "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCTextArea	ºAutor  ³Saude                º Data ³  18/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria TEXTAREA (Memo)   										     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/

Static Function WCObrigat(aObrigat)
LOCAL cHTML			:= ""
LOCAL nI				:= 0
LOCAL nLen				:= 0
DEFAULT aObrigat 		:= {}

cHtml += " <script language='JavaScript'> "  + CRLF
//Seta os campos obrigatórios para a validação no botão confirmar.
cHTML += "var oForm = new xform( document.forms[0]) ;"  + CRLF

nLen := len(aObrigat)

If nLen > 0
	For nI := 1 to nLen
		If Len(aObrigat[nI]) > 1
			If Empty(aObrigat[nI][2])	
				cHTML += "oForm.add( document.forms[0]." +aObrigat[nI][1] + ",'tudo', false , false);"	+ CRLF		
			Else
				cHTML += "oForm.add( document.forms[0]." +aObrigat[nI][1] + ",'onkeypress', false , false);"	+ CRLF		
			Endif
		Else
			cHTML += "oForm.add( document.forms[0]." +aObrigat[nI] + ",'tudo', false , false);"	+ CRLF
		EndIf
	Next nI
EndIf

cHtml += " </script> "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCTextArea	ºAutor  ³Saude                º Data ³  18/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria TEXTAREA (Memo)   										     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/

Static Function WCCriarVar(aVar)
LOCAL cHTML			:= ""
LOCAL nI				:= 0
LOCAL nLen				:= 0
cHtml += " <script language='JavaScript'> "
nLen := len(aVar)
For nI := 1 to nLen
	cHtml += aVar[nI] + " = '';" + CRLF
next nI
cHtml += " </script> "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return cHTML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCLeg	ºAutor  ³Karine Riquena Limp     º Data ³  11/05/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria Legenda                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
   		cCSS é o nome da class css que vai representar a cor da legenda     º±±
   		Cores disponiveis:                                                  º±±
      |    Class    |   Cor     |                                          º±±
      ---------------------------                                          º±±
      | icon-white  | branco    |                                          º±±
      | icon-yellow | amarelo   |                                          º±±
      | icon-orange | laranja   |                                          º±±
      | icon-green  | verde     |                                          º±±
      | icon-black  | preto     |                                          º±±
      | icon-red    | vermelho  |                                          º±±
   		                                                                    º±±
   		Para adicionar uma nova cor, basta criar outra classe no arquivo    º±± 
   		estilo.css, e nesta, usar a propriedade color do css                º±±
   		                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function WCLeg(cName, cCSS, cTitle)
LOCAL cHTML 	 := "" 
DEFAULT cName  := ""
DEFAULT cCSS   := ""
DEFAULT cTitle := ""
					cHTML += "<label name='" + cName + "'>"
					cHTML += "<i class='fa fa-circle graph-captions " + cCSS + "'></i>
					cHTML += "&nbsp;&nbsp;&nbsp;" + cTitle + "&nbsp;&nbsp;&nbsp;</label>"
Return cHTML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCRadio	ºAutor  ³Rodrigo Morgon      º Data ³  17/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria radiobutton		     							            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       
Static Function WCRadio(cName,cTitle,aOpcoes,cInLine, cXS, cSM, cMD, cLG, cCss, lCustom)

LOCAL nI		 	:= 0
LOCAL cHTML		:= ""

DEFAULT cName		:= ""
DEFAULT cTitle	:= ""
DEFAULT cInLine	:= ""
DEFAULT aOpcoes 	:= {}
DEFAULT cXS    	:= "12"
DEFAULT cSM    	:= "6"
DEFAULT cMD    	:= "6"
DEFAULT cLG    	:= "4"
DEFAULT cCss 		:= ""
DEFAULT lCustom      := .F.

cCustom += iif(lCustom,"radiobutton~"+cCss+"|","")
cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + "'>"	
cHTML += "<div class='form-group'>"
cHTML += "<label>" + cTitle + "</label>"
cHTML += "<div class='input-group'>"

if cInLine == "inline"		
	//Disposicao inline
	For nI := 1 to Len(aOpcoes)
		cHTML += "<label class='radio-inline'>"
		cHTML += "<input type='radio' " + iif(empty(cCss), "" ," class='" + cCss + "'" ) + " name='" + cName + "' value='" + alltrim(Str(nI)) + "' "
		cHTML += IIf( nI == 1, "checked='checked'", "") + ">" + aOpcoes[nI] + "</label>"
	Next	
else
	//Disposicao vertical
	For nI := 1 to Len(aOpcoes)
		cHTML += "<div class='radio'>"
	  	cHTML += "<label><input type='radio' class='" + cCss + "' name='" + cName + "' value='" + alltrim(Str(nI)) + "' "
	  	cHTML += IIf( nI == 1, "checked='checked'", "") + ">" + aOpcoes[nI] + "</label>"
	  	cHTML += "</div>"
	Next
endif

cHTML += "</div>"
cHTML += "</div>"
cHTML += "</div>" 
  
Return cHTML   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WCAlertBS	ºAutor  ³Karine Riquena Limp      º Data ³  11/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria alert do bootstrap	     							            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/       

Static Function WCAlertBS(cName,cCss,cText,lDisplay) 
LOCAL cHTML		:= ""
LOCAL cDisplay	:= ""

DEFAULT lDisplay  := .F.

cDisplay := IIF(lDisplay == .T., 'style="display:block;margin-top:10px;"' , 'style="display:none;margin-top:10px;"')

cHTML += '<div class="alert alert-' +cCss+ ' alert-dismissible" id="' + cName + '" role="alert" ' + cDisplay + '>'
cHTML +=' <button type="button" class="close" aria-label="Close" onclick='"
cHTML += "$('#" + cName + "').hide()><span aria-hidden='true'>&times;</span></button>"
cHTML += cText
cHTML += '</div>'

Return cHTML  
    
//-------------------------------------------------------------------
/*/{Protheus.doc} WCPopOver
Função que cria o componente popover do bootstrap.
Para customização via javascript, ver documentação em: http://getbootstrap.com/javascript/#popovers

@author Rodrigo Morgon
@since 13/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function WCPopOver(cName,cTitle,cValue,lDisplay,cXS,cSM,cMD,cLG)

LOCAL cHTML		:= ""
LOCAL cDisplay 	:= ""
DEFAULT cXS    	:= "1"
DEFAULT cSM    	:= "1"
DEFAULT cMD    	:= "1"
DEFAULT cLG    	:= "1"
DEFAULT lDisplay  := .T.

cDisplay := IIF(lDisplay == .T., "style='display:block'" , "style='display:none'")	

cXS := "col-xs-" + cXS + " " 
cSM := "col-sm-" + cSM + " "
cMD := "col-md-" + cMD + " "
cLG := "col-lg-" + cLG + " "

cHTML += "<div class='" + cXS + cSM + cMD + cLG + "' >"
cHTML += '<br><span id="' + cName + '" class="glyphicon glyphicon-question-sign" data-original-title="' + cTitle + '"
cHTML += ' data-toggle="popover" data-trigger="hover" data-html="true" data-content="'
cHTML += cValue
cHTML += '" ' + cDisplay + '></span></div>'

Return cHTML 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³__WCHtml	    ³ Autor ³ Totvs			    ³ Data ³ 30/03/10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Somente para compilar a class							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function __WCHtml
Return
