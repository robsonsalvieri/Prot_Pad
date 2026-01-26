#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "RU44XFUN.CH"

/*/{Protheus.doc} RU44XFUN01_AddMenuItems(aRotina)
    This function add menu items to array aRotina

    @type Function
    @param aRotina = Array, with menu items

    @return aRotina

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example RU44XFUN01_AddMenuItems(aRotina)
*/
Function RU44XFUN01_AddMenuItems(aRotina)
    Aadd( aRotina, {STR0002 ,"RU34XREP01('PMSA410', .T.)" , 0 , 2, 0, nil    } ) 
Return aRotina

/*/{Protheus.doc} RU44XFUN02_AddUserButton(oView)
    This function add user buttons to oView

    @type Function
    @param oView = view object from MVC

    @return aRotina

    @author Dmitry Borisov
    @since 2023/10/11
    @version 12.1.33
    @example RU44XFUN02_AddUserButton(oView)
*/
Function RU44XFUN02_AddUserButton(oView)
    oView:AddUserButton(STR0001, '', {|| RU34XREP01("PMSA410", .F.)},,,{MODEL_OPERATION_VIEW}) 
Return oView

/*/{Protheus.doc} RU44XFUN03_FillUpMemoOnCommit 
    function responsible for assign values for memo fields
    @type Function 
    @author Dmitry Borisov 
    @since 28/05/2024 
    @version R14 
    @param oModel , object , Object with model
    @param cModelName , character , name of model
    @param cFieldMemo , character , code of memo field from SX3 (X3_CAMPO)
    @param cFieldCode , character , code of field from SX3 (X3_CAMPO)
    @param cTab , character , code of table from SX2 (X2_CHAVE)
    @return lRet , logical 
/*/
Function RU44XFUN03_FillUpMemoOnCommit(oModel, cModelName, cFieldMemo, cFieldCode, cTab)
    Local lRet  := .T.
    Local aArea := {}
    Local cCode := ""

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
        If !Empty(AllTrim(oModel:GetValue(cModelName, cFieldMemo)))
            
            aArea := (cTab)->(GetArea())
            cCode := MSMM(&((cTab)->(cFieldCode)),TamSx3(cFieldMemo)[1],,oModel:GetValue(cModelName, cFieldMemo),1,,,cTab,cFieldCode)
            RestArea(aArea)

            lRet := (cCode != Nil .And. !Empty(cCode))
        EndIf
    EndIf
Return (lRet)
                   
//Merge Russia R14 
                   
