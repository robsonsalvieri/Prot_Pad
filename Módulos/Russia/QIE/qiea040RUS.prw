#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "QIEA040.CH"

/*/{Protheus.doc} QIEA040RUS()
    This function needs for maintaince Non-Conformances records

    @type Function
    @return Nil

    @author Dmitry Borisov
    @since 2024/02/05
    @example QIEA040RUS()
*/
Function QIEA040RUS() 
    Local oBrowse  
    Private aRotina := MenuDef()
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SAG")                                          
    oBrowse:SetDescription(STR0006)  //"Non-Conformances"
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef()
    This function prepare Menu options from MVC

    @type Static Function
    @return aRet

    @author Dmitry Borisov
    @since 2024/02/05
    @example MenuDef()
*/
Static Function MenuDef()
    Local aRet := {}

    aRet := FWLoadMenuDef("QIEA040")

Return aRet

/*/{Protheus.doc} ModelDef()
    This function prepare Model object from MVC

    @type Static Function
    @return oModel

    @author Dmitry Borisov
    @since 2024/02/05
    @example ModelDef()
*/
Static Function ModelDef()  
    Local oModel := FWLoadModel('QIEA040')
Return oModel 

/*/{Protheus.doc} ViewDef()
    This function prepare View object from MVC

    @type Static Function
    @return oView

    @author Dmitry Borisov
    @since 2024/02/05
    @example ViewDef()
*/
Static Function ViewDef()
    Local oView := FWLoadView('QIEA040')
    oView:GetViewStruct('MASTER_SAG'):RemoveField('AG_DESCES')
    oView:GetViewStruct('MASTER_SAG'):RemoveField('AG_DESCIN')

Return oView
                   
//Merge Russia R14 

