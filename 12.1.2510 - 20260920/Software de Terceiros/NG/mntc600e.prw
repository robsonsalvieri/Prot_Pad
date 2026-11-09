#INCLUDE 'MNTC600.CH'
#INCLUDE 'PROTHEUS.CH'

//--------------------------------------------------
/*/{Protheus.doc} MNTC600E
Monta um browse ocorrências da ordem

@author Caue Girardi Petri  
@since 30/03/26
@return Nil
/*/
//--------------------------------------------------
Function MNTC600E()
	
    Local cFuncBkp := FunName()
    Local aMenu    := MenuDef()
    
    SetFunName( 'MNTC600E' )

    MNTCTARE2( aMenu )

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

    Local aReturn := {{STR0011,"AxVisual"  , 0, 2},;    //"Visualizar"
					 {STR0003,"MNTCDEMA" , 0, 3, 0},;  //"Detalhe"
					 {STR0015,"MNC600DEP", 0, 4, 0},;  //"depeNdencia"
					 {STR0016,"MNTCETAP" , 0, 4, 0}}   //"Etapas" 

Return aReturn
