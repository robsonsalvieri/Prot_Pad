#Include "Protheus.ch"
#Include "FwMVCDef.ch"

Function RU09T04RUS()
Return RU09T04()

/*/{Protheus.doc} ModelDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 13/10/2022
    @version version
    @return oModel, Object
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
    Local oModel     As Object 
    oModel := FwLoadModel("RU09T04")
Return oModel

/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 13/10/2022
    @version version
    @return oView, Object, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
    Local oView       As Object
    oView := FWLoadView("RU09T04")
Return oView

/*/{Protheus.doc} BrowseDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 13/10/2022
    @version version
    @return oBrowse, Object
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function BrowseDef()
    Local oBrowse    As OBJECT
    oBrowse := FWLoadBrw("RU09T04")
Return oBrowse

/*/{Protheus.doc} MenuDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 13/10/2022
    @version version
    @return aRotina, Array, Menu Items
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()
    aRotina :=  FWLoadMenuDef("RU09T04")
Return aRotina
                   
//Merge Russia R14 
                   
