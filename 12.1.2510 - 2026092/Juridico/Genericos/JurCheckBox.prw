#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCheckBox
CLASS TJurCheckBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function __JurCheckBox() // Function Dummy
ApMsgInfo( 'JurCheckBox -> Utilizar Classe ao inves da funcao' )
Return NIL 

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCheckBox
CLASS TJurCheckBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurCheckBox FROM TCHECKBOX

 DATA lCheckJur

 METHOD New (nRow, nCol, cCaption, bSetGet, oDlg, ;
  					  nWidth, nHeight, uParam8, bChange, ;
  					  oFont, bValid, nClrText, nClrPane, uParam14, ;
  					  lPixel, cMsg, uParam17, bWhen) CONSTRUCTOR

METHOD Checked()
METHOD SetCheck(lCheck)
	
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} JurCheckBox
CLASS TJurCheckBox

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (nRow, nCol, cCaption, bSetGet, oDlg, ;
  					  nWidth, nHeight, uParam8, bChange, ;
  					  oFont, bValid, nClrText, nClrPane, uParam14, ;
  					  lPixel, cMsg, uParam17, bWhen) CLASS TJurCheckBox
        :New (nRow, nCol, cCaption, bSetGet, oDlg, nWidth, nHeight, uParam8, bChange, oFont, bValid, nClrText, nClrPane, uParam14, lPixel, cMsg, uParam17, bWhen)

	Self:lCheckJur := .T.
	Self:bSetGet := {|u|if( pcount()>0,::lCheckJur := u, ::lCheckJur)}

	If !Empty(bChange) .And. ValType(bChange) == "B"
		Self:bLClicked := bChange
		Self:bChange := {|| }
	EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Checked()
Classe para retornar o a variavel lCheckJur

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Checked() CLASS TJurCheckBox
Return Self:lCheckJur


//-------------------------------------------------------------------
/*/{Protheus.doc} Checked()
Classe para setar a variavel lCheckJur

@author Felipe Bonvicini Conti
@since 16/09/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetCheck(lCheck) CLASS TJurCheckBox

If ValType(lCheck) == "L"
	Self:lCheckJur := lCheck
EndIf

Return Self:lCheckJur
