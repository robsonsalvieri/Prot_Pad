#INCLUDE "PROTHEUS.CH"


/*/
{Protheus.doc} RU73XFUN01_GetMenuItem 
    function responsible for creating menu items for CRMA290, with correct coding for RUS localization
    @type Function 
    @author Dmitry Borisov 
    @since 27/05/2024 
    @version R14 
    @param aItens , Array , array of xml menuitems 
    @param oMenu , object , Object from the routine menu 
    @param oXML , object , Object from XML parse 
    @return cMenuItem , Character, menuitem decoded 
/*/
Function RU73XFUN01_GetMenuItem(aItens As Array, oMenu As Object, oXML As Object)
    Local nItens    As Numeric
    Local cMenuItem As Character

    nItens    := 0
    cMenuItem := ""

    For nItens := 1 To Len(aItens)
        // search item with description, for correct menuitem creation
        // fix encoding for RUS locale
        If Rat('/Description', aItens[nItens]) > 0
            cMenuItem := oMenu:AddFolder( DecodeUTF8(oXML:XPathGetNodeValue(aItens[nItens], .F.), "cp1252"), "E" ) //Description main menu
            Exit
        EndIf
    Next nItens

Return cMenuItem
//Merge Russia R14                   
