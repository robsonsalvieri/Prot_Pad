#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
{Protheus.doc} RU07T11RUS
    HR Referencies File

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project MA3 - Russia
/*/
Function RU07T11RUS()
    Local oBrowse As Object

    oBrowse := BrowseDef()
    oBrowse:Activate()

Return BrowseDef()

/*/
{Protheus.doc} BrowseDef
    Browse definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function BrowseDef
Return FwLoadBrw("RU07T11")

/*/
{Protheus.doc} MenuDef
    Menu definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function MenuDef()
Return FWLoadMenuDef("RU07T11")

/*/
{Protheus.doc} ModelDef
    Model definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
/*/
Static Function ModelDef()
Return FWLoadModel("RU07T11")

/*
{Protheus.doc} ViewDef
    View definition

    @author Fedorova Anna
    @since 30/09/2019
    @version 1.0
    @project DMA3 - Russia
*/
Static Function ViewDef()
    Local oView As Object
    Local bBlockAsk := {|oView| RunAskMethod(oView)}
    
    oView := FWLoadView("RU07T11")   
    oView:AddUserButton("Ask (F12)", "MAGIC_BMP", bBlockAsk, "Comentário do botão", VK_F12)
Return oView


/*
{Protheus.doc} RunAskMethod()
    By the type of reference, it will determine which pergunta is used and launch it.

    @type Method
    @params oView, Object, Active View
    @return NIL
    @author vselyakov
    @since 2020/09/14
    @version 12.1.23
    @example RunAskMethod()
*/
Static Function RunAskMethod(oView As Object)
    Local oModel     As Object
    Local cRefType   As Character
    Local oRefObj    As Object
    Local cMat       As Character
    Local cForm      As Character
    Local cRccConteo As Character
    
    oModel := oView:GetModel()
    cRefType := Trim(oModel:GetModel("F6HMASTER"):GetValue("F6H_REFTYP"))
    cRccConteo := fRUGetRccConteo("S203", cRefType)
    cForm := Trim(Substr(cRccConteo, 218, 10))

    If (oModel != NIL .AND. Str(oModel:GetOperation(),1) $ '3|4|5' .AND. !Empty(cForm))
        cMat := oModel:GetModel("F6HMASTER"):GetValue("F6H_MAT")        
        oRefObj := RUHRReference():New(cRefType, oModel)
        oRefObj:LoadLastUnique(cMat)
        oRefObj:Ask(cForm)
    EndIf

Return NIL