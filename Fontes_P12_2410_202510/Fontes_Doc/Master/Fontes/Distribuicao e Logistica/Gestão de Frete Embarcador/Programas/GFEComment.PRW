#INCLUDE 'PROTHEUS.CH'
Function GFEComment()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEComment()

@author Leandro Conradi Zmovirzynski
@since 30/05/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFEComment FROM LongNameClass 

	DATA cTitleWindow
	DATA cTitleMemo
	DATA cText
	DATA cBtnConfirm
	DATA cBtnCancel
	DATA lStatus
	
	METHOD new() CONSTRUCTOR
	METHOD clearData()
	METHOD destroy(oObject)
	METHOD createWindow()
	METHOD closeWindow()
	METHOD setTextMemo()
	
	METHOD setTitleWindow(cTitleWindow)
	METHOD setTitleMemo(cTitleMemo)
	METHOD setText(cText)
	METHOD setBtnConfirm(cBtnConfirm)
	METHOD setBtnCancel(cBtnCancel)
	METHOD setStatus(lStatus)
	
	METHOD getTitleWindow()
	METHOD getTitleMemo()
	METHOD getText()
	METHOD getBtnConfirm()
	METHOD getBtnCancel()
	METHOD getStatus()

ENDCLASS

METHOD new() Class GFEComment
   Self:clearData()
Return

METHOD destroy(oObject) CLASS GFEComment
   FreeObj(oObject)
Return

METHOD clearData() Class GFEComment
	Self:setTitleWindow("")
	Self:setTitleMemo("")
	Self:setText("")
	Self:setBtnConfirm("Salvar")
	Self:setBtnCancel("Cancelar")
	Self:setStatus(.F.)
Return

METHOD createWindow() Class GFEComment

Local cText

  
   	DEFINE MSDIALOG oDlg TITLE Self:getTitleWindow() FROM 000,000 TO 260,400 PIXEL
   		If(Self:getTitleMemo() != "")
			@ 4, 006  SAY Self:getTitleMemo() SIZE 200,7 PIXEL OF oDlg
		EndIf 
		@ 012, 005 GET oMemo VAR cText MEMO SIZE 193, 100 OF oDlg PIXEL 
		@ 115, 5  BUTTON Self:getBtnConfirm() SIZE 27 , 012 PIXEL OF oDlg ACTION(Self:setTextMemo(cText,oDlg))
		@ 115, 35  BUTTON Self:getBtnCancel() SIZE 27, 012 PIXEL OF oDlg ACTION(Self:closeWindow(oDlg))
		 
	ACTIVATE MSDIALOG oDlg CENTERED
   
Return

METHOD setTextMemo(cText,oDlg) Class GFEComment
	Self:setStatus(.T.)
	Self:setText(cText)
	oDlg:End()   
Return

METHOD closeWindow(oDlg) Class GFEComment
   oDlg:End()
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setTitleWindow(cTitleWindow) CLASS GFEComment
   Self:cTitleWindow := cTitleWindow
Return
METHOD setTitleMemo(cTitleMemo) CLASS GFEComment
   Self:cTitleMemo := cTitleMemo
Return
METHOD setText(cText) CLASS GFEComment
   Self:cText := cText
Return
METHOD setBtnConfirm(cBtnConfirm) CLASS GFEComment
   Self:cBtnConfirm := cBtnConfirm
Return
METHOD setBtnCancel(cBtnCancel) CLASS GFEComment
   Self:cBtnCancel := cBtnCancel
Return
METHOD setStatus(lStatus) CLASS GFEComment
   Self:lStatus := lStatus
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getTitleWindow() CLASS GFEComment
Return Self:cTitleWindow

METHOD getTitleMemo() CLASS GFEComment
Return Self:cTitleMemo

METHOD getText() CLASS GFEComment
Return Self:cText

METHOD getBtnConfirm() CLASS GFEComment
Return Self:cBtnConfirm

METHOD getBtnCancel() CLASS GFEComment
Return Self:cBtnCancel

METHOD getStatus() CLASS GFEComment
Return Self:lStatus
