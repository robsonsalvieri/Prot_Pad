#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC600E
Monta um browse ocorrÃªncias da ordem

@author Caue Girardi Petri  
@since 30/03/26
@return Nil
/*/
//--------------------------------------------------
Function MNTC600F()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC600F' )

    MNTCDEMA2( aMenu )

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Caue Girardi Petri  
@since 30/03/26
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := {{STR0011,"AxVisual", 0, 2}} //"Visualizar"

Return aReturn
