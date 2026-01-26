
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE  PROGRAM "RU09T09"

Function RU09T09RUS()
    Local oBrowse As Object
    oBrowse := BrowseDef()
	oBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
    Return Menu
    @type  Static Function
    @author astepanov
    @since 09/11/2022
    @version version
    @return aRet, Array, Menu items in array
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()
    Local aRet As Array
    aRet := FWLoadMenuDef(PROGRAM)
Return aRet

/*/{Protheus.doc} BrowseDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 09/11/2022
    @version version
    @return oBrowse, Object, Browse object
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function BrowseDef()
    Local oBrowse As Object
    oBrowse := FWLoadBrw(PROGRAM)
Return oBrowse

/*/{Protheus.doc} ModelDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 09/11/2022
    @version version
    @return oModel, Object, Model for PROGRAM
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
    Local oModel As Object
    oModel := FWLoadModel(PROGRAM)
Return oModel

/*/{Protheus.doc} ViewDef
    (long_description)
    @type  Static Function
    @author astepanov
    @since 09/11/2022
    @version version
    @return oView, Object, oView for PROGRAM
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
    Local oView As Object
    oView := FWLoadView(PROGRAM)
Return oView
                   
//Merge Russia R14 
                   
