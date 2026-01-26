#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PMSA200.CH"
#INCLUDE "pmsicons.ch"

#DEFINE SOURCEFATHER "PMSA200"

/*/{Protheus.doc} PMSA200RUS()
    Localization for PMSA200

    @type Function
    @return lRet

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example PMSA200RUS()
*/
Function PMSA200RUS()
    Local oBrowse As Object

    Private cCadastro := STR0001
    Private aRotina := MenuDef()
    Private aCores  := PmsAF8Color()
    Private nDlgPln	:= PMS_VIEW_TREE

    Set Key VK_F12 To FAtiva()
    dbSelectArea('AF8')
    oBrowse := BrowseDef()
    oBrowse:Activate()
Return

/*/{Protheus.doc} BrowseDef()
    This function activate MVC

    @type Static Function
    @return oBrowse

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example BrowseDef()
*/
Static Function BrowseDef()
    Local oBrowse As Object
    Local nX            := 0
    Local cFilUser	    := ""
    Local lPM200BFIL	:= ExistBlock("PM200BFIL")

    If lPM200BFIL
        cFilUser := ExecBlock("PM200BFIL",.F.,.F.)
        If ValType(cFilUser) <> "C"
            cFilUser := ""
        EndIf
    EndIf
    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias( 'AF8' )
    oBrowse:SetDescription( cCadastro ) // 'Cadastro de Projetos'
    If !Empty(cFilUser)
        oBrowse:SetFilterDefault(cFilUser)
    EndIf
    oBrowse:SetUseFilter(.T.)
    
    For nX := 1 To Len(aCores)
        oBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3]  )
    Next nX
Return oBrowse

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC,
    by defult menu from PMSA200

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRotina as Array

    aRotina := FwLoadMenuDef(SOURCEFATHER)
    aRotina := RU44XFUN01(aRotina)
Return aRotina

/*{Protheus.doc} ViewDef
    This function prepare View object from MVC,
    by defult view from PMSA200

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView      As Object 
    oView := FWLoadView(SOURCEFATHER)
    oView := RU44XFUN02(oView)
Return oView

/*{Protheus.doc} ModelDef
    This function prepare oModel object from MVC,
    by defult oModel from PMSA200

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example ModelDef()
*/
Static Function ModelDef()
    Local oModel As Object
    oModel := FWLoadModel(SOURCEFATHER)
    oModel:InstallEvent("PMSA200Ev"	,/*cOwner*/,PMSA200EventRUS():New())
Return oModel
                   
//Merge Russia R14 
                   
