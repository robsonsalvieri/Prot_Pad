#INCLUDE 'MNTC605.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC605B
Monta um browse ocorrÃªncias da ordem

@author Caue Girardi Petri  
@since 29/04/26
@return Nil
/*/
//--------------------------------------------------
Function MNTC605B()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC605B' )

    MNTCDEPE2( aMenu )

    SetFunName( cFuncBkp )

Return 

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author Caue Girardi Petri  
@since 29/04/26
@return array
/*/
//--------------------------------------------------
Static Function MenuDef()

    Local aReturn := {{STR0001,"AXPesqui" , 0, 1},; //"Pesquisar"
					  {STR0002,"AxVisual", 0, 2} }  //"Visualizar"

Return aReturn
