#include "protheus.ch"
#INCLUDE 'TOPCONN.CH'
#include 'fwmvcdef.ch'
#include 'ru09t14.ch'

/*/{Protheus.doc} ru09t1401()
     The function displays the standard MVC for the tables F8A 

     @type Function
     @return Nil

     @author mpopenker
     @since 2024/06/13
     @version 12.1.2310
*/
function ru09t1401() 
    Local oBrowse as object
    Local aArea := GetArea()
    Private aRotina := {}

    DbSelectArea('F8A')
    DbSetOrder(1)
 
    oBrowse := BrowseDef()
    
    aRotina := MenuDef() 
    oBrowse:Activate()
    
    RestArea(aArea)
RETURN

static function BrowseDef()
    Local oBrowse as object
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('F8A')
    oBrowse:SetDescription(STR0001) //'EDE settings'
    oBrowse:DisableDetails() 
return oBrowse

/*/{Protheus.doc} ModelDef()
     The function defines the data model for the tables F8A & Z02 

     @type Function
     @return Nil

     @author mpopenker
     @since 2024/06/13
     @version 12.1.2310
*/
Static function ModelDef 
    Local oStruF8A := FWFormStruct( 1, 'F8A' ) // Dcument headers
    Local oModel := MPFormModel():New( 'ZKONTUR00' )

    oModel:AddFields( 'F8AMASTER', /*cOwner*/, oStruF8A ) // header fields

    oModel:SetPrimarykey({'F8A_FILIAL,F8A_EDESYS,F8A_EDEPAR,F8A_EDEINN,F8A_EDEKPP'})

    oModel:GetModel("ZKONTUR00"):SetFldNoCopy({'F8A_EDEPAR','F8A_EDEVAL'})

RETURN oModel


/*/{Protheus.doc} ViewDef()
     The function defines the client dislay view for the tables F8A & Z02 

     @type Function
     @return Nil

     @author mpopenker
     @since 2024/06/13
     @version 12.1.2310
*/
Static Function ViewDef()
    // prepare view objects
    Local oModel := FWLoadModel( 'ZKONTUR00' )
    Local oStruF8A := FWFormStruct( 2, 'F8A' ) // 

    Local oView := FWFormView():New()

    oView:SetModel( oModel )

    // prepare header part
    oView:AddField( 'VIEW_F8A', oStruF8A, 'F8AMASTER' )
    oView:CreateHorizontalBox( 'SCREEN' , 100 )
    oView:SetOwnerView( 'VIEW_F8A', 'SCREEN' )

    
RETURN oView

/*/{Protheus.doc} MenuDef()
     The function defines the standard menu for the view above 

     @type Function
     @return Nil

     @author mpopenker
     @since 2024/06/13
     @version 12.1.2310
*/
Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.ZKONTUR00' OPERATION 2 ACCESS 0 //STR0002 'Show'
    ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.ZKONTUR00' OPERATION 3 ACCESS 0 //STR0003 'Add' 
    ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.ZKONTUR00' OPERATION 4 ACCESS 0 // STR0004 'Edit'
    ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.ZKONTUR00' OPERATION 5 ACCESS 0 //STR0005 'Delete'    
    ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.ZKONTUR00' OPERATION 9 ACCESS 0 //STR0005 'Copy'

Return aRotina



                   
//Merge Russia R14 
                   
