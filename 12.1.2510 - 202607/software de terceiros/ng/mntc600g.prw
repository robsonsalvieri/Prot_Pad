#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC600E
Monta um browse ocorrÃƒÂªncias da ordem

@author Caue Girardi Petri  
@since 30/03/26
@return Nil
/*/
//--------------------------------------------------
Function MNTC600G()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC600G' )

    MNTCETAP2( aMenu )

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

    Local aReturn := {{STR0011,"AxVisual", 0, 2},; //"Visualizar"
					{STR0019,"MNTCOPCA", 0, 4, 0}} //"Opcoes"

Return aReturn
