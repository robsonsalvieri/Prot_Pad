#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU01D04.CH"

/*/{Protheus.doc} RU01D04()
    This function needed for maintaince OKTMO records

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example RU01D04()
*/
Function RU01D04()
    Local lRet as Logical
    Local oBrowse as Object

    Private aRotina as Array

    lRet := .T.

    oBrowse := BrowseDef()
    oBrowse:Activate()
Return(lRet)

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse as Object
    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F55")
    oBrowse:SetSeeAll(.T.)
    oBrowse:SetDescription(STR0001) // OKTMO Maintaining
    oBrowse:DisableDetails()

Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aAdd( aRet, {STR0003, "VIEWDEF.RU01D04", 0, MODEL_OPERATION_INSERT, 0, Nil} ) // Add
    aAdd( aRet, {STR0002, "VIEWDEF.RU01D04", 0, MODEL_OPERATION_VIEW  , 0, Nil} ) // View
    aAdd( aRet, {STR0005, "VIEWDEF.RU01D04", 0, MODEL_OPERATION_DELETE, 0, Nil} ) // Delete

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel as Object
    Local oStrF55 := FWFormStruct(1, 'F55')

    oModel := MPFormModel():New('RU01D04',,{|oMdl| RU01XFUN06(oMdl,IIf(oMdl:GetOperation() == MODEL_OPERATION_DELETE,STR0007,STR0008),IIf(oMdl:GetOperation() == MODEL_OPERATION_DELETE,STR0006,STR0009),'RU01D04','F55')},,)
    oModel:AddFields('F55MASTER', Nil, oStrF55)
    oModel:SetPrimaryKey({'F55_FILIAL','F55_OKTMO1', 'F55_OKTMO2', 'F55_OKTMO3', 'F55_OKTMO4'})

Return(oModel)

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/07/10
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView As Object
    Local oModel  := FwLoadModel("RU01D04")
    Local oStrF55 := FWFormStruct(2, "F55")

    oStrF55:RemoveField('F55_FILIAL')

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("F55_M", oStrF55, "F55MASTER")
Return(oView)

/*/{Protheus.doc} RU01D04001_Editable()
    This function checks when user can edit fields, calls from SX3 table
	field X3_WHEN

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/09/25
    @version 12.1.33
    @example RU01D04001_Editable()
*/
Function RU01D04001_Editable()
    Local lRet 		:= .T.
    Local cRuPrf 	:= ""
    Local cFieldInd := ""
    Local oModel	:= FwModelActive()

    If AllTrim(ReadVar()) != ''
        cRuPrf:=StrTokArr(ReadVar(), "->")[2]
    EndIf

    cFieldInd := Right(cRuPrf,1)

    If INCLUI
        Do Case
            Case cFieldInd == "2"
                lRet := AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"1")) <> '00' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"1")))
            Case cFieldInd == "3"
                lRet := AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"1")) <> '00' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"1")));
                    .And. AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"2")) <> '000' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"2")))
            Case cFieldInd == "4"
                lRet := AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"1")) <> '00' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"1")));
                    .And. AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"2")) <> '000' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"2")));
                    .And. AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"3")) <> '000' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER",Left(cRuPrf,Len(cRuPrf)-1)+"3")))
            Case cFieldInd == "R"
                lRet := AllTrim(oModel:GetValue("F55MASTER","F55_OKTMO1")) <> '00' .And. !Empty(AllTrim(oModel:GetValue("F55MASTER","F55_OKTMO1")))
        End Do
    EndIf
Return (lRet)
