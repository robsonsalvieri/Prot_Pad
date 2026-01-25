#include 'totvs.ch'
#include 'parmtype.ch'
#include "CHECKLISTADAPTER.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} ChecklistAdapter
Classe Adapter para o serviço
@author  Bruno Forcato
/*/
//-------------------------------------------------------------------
CLASS ChecklistAdapter FROM FWAdapterBaseV2
    METHOD New()
    METHOD GetListChecklist()
    METHOD GetListResponse()
EndClass
 
Method New( cVerb ) CLASS ChecklistAdapter
    _Super:New( cVerb, .T. )
return
 
Method GetListChecklist(cSearch, cFilter, cType) CLASS ChecklistAdapter
    Local aArea     AS ARRAY
    Local cWhere    AS CHAR
    aArea   := FwGetArea()

    ChecklistAddMapFields( self )
    ::SetQuery( GetQueryChecklist() )

    if empty(cType)
        cWhere := " VRX_FILIAL = '"+ FWxFilial('VRX') +"' AND VRX.D_E_L_E_T_ = ' ' AND VRX_ATUAL <> 0"
    else
        cWhere := " VRX_FILIAL = '"+ FWxFilial('VRX') +"' AND VRX.D_E_L_E_T_ = ' ' AND VRX_ATUAL = 1 AND VRX_AGRUP = " + cType
    endif



    If !Empty(cSearch)
        cWhere += " AND ("
        cWhere += "VRX_CODIGO LIKE '%" + cSearch + "%'"
        cWhere += "OR VRX_CODUSR LIKE '%" + cSearch + "%'"
        cWhere += "OR VRX_AGRUP LIKE '%" + cSearch + "%'"
        cWhere += "OR JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name') LIKE '%" + cSearch + "%'"
        cWhere += ")"
    EndIf

    if !Empty(cFilter)
        cWhere += " AND ("
        cWhere += "VRX_CODIGO LIKE '%" + cFilter + "%'"
        cWhere += "OR JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name') LIKE '%" + cFilter + "%'"
        cWhere += ")"
    EndIf

    ::SetWhere( cWhere )
    ::SetOrder( "VRX_CODIGO" )

    If ::Execute()
        ::FillGetResponse()
    EndIf
    FwrestArea(aArea)
Return

Method GetListResponse(cSearch, cVRZ_CodInt) CLASS ChecklistAdapter
    Local aArea     AS ARRAY
    Local cWhere    AS CHAR
    default cVRZ_CodInt := ""
    aArea   := FwGetArea()

    if empty(cVRZ_CodInt) .OR. Valtype(cVRZ_CodInt) != "C"
        return .f.
    endif

    ResponseAddMapFields( self )
    ::SetQuery( GetQueryResponse() )
    cWhere := " VRZ_FILIAL = '"+ FWxFilial('VRZ') +"' AND VRZ.D_E_L_E_T_ = ' '"
    cWhere += " AND VRZ_CODINT = '" + cVRZ_CodInt + "'";

    ::SetWhere( cWhere )
    ::SetOrder( "VRZ_CODIGO" )

    If ::Execute()
        ::FillGetResponse()
    EndIf
    FwrestArea(aArea)
Return
 
Static Function ChecklistAddMapFields( oSelf )
     
    oSelf:AddMapFields( 'id'         , 'VRX_CODIGO', .T., .T., { 'VRX_CODIGO', 'C', TamSX3( 'VRX_CODIGO' )[1], 0 } )
    oSelf:AddMapFields( 'checklistId', 'VRX_CODINT', .T., .T., { 'VRX_CODINT', 'C', TamSX3( 'VRX_CODINT' )[1], 0 } )
    oSelf:AddMapFields( 'data'       , 'VRX_DADOS' , .T., .F., { 'VRX_DADOS', 'M', TamSX3( 'VRX_DADOS' )[1], 0 } )
    oSelf:AddMapFields( 'userId'     , 'VRX_CODUSR', .T., .F., { 'VRX_CODUSR', 'C', TamSX3( 'VRX_CODUSR' )[1], 0 } )
    oSelf:AddMapFields( 'dateCreate' , 'VRX_DATINC', .T., .F., { 'VRX_DATINC', 'D', TamSX3( 'VRX_DATINC' )[1], 0 } )
    oSelf:AddMapFields( 'type'       , 'VRX_AGRUP' , .T., .F., { 'VRX_AGRUP', 'C', TamSX3( 'VRX_AGRUP' )[1], 0 } )
    oSelf:AddMapFields( 'status'     , 'VRX_ATUAL' , .T., .F., { 'VRX_ATUAL', 'C', TamSX3( 'VRX_ATUAL' )[1], 0 } )
    oSelf:AddMapFields( 'statusName' , 'VRX_ATUAL_NAME' , .T., .F., { 'VRX_ATUAL_NAME', 'C',20, 0 }, "CASE WHEN VRX_ATUAL = 1 THEN '"+ STR0001 +"' ELSE '"+ STR0002 +"' END")
    oSelf:AddMapFields( 'name'       , "VRX_NAME", .T., .F.,   { 'VRX_NAME', 'C', 20, 0 }, "JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name')" )

Return

Static Function ResponseAddMapFields( oSelf )
     
    oSelf:AddMapFields( 'id'           , 'VRZ_CODIGO', .T., .T., { 'VRZ_CODIGO', 'C', TamSX3( 'VRZ_CODIGO' )[1], 0 } )
    oSelf:AddMapFields( 'checklistId'  , 'VRZ_CODVRX', .T., .T., { 'VRZ_CODVRX', 'C', TamSX3( 'VRZ_CODVRX' )[1], 0 } )
    oSelf:AddMapFields( 'responsedata' , 'VRZ_DADOS' , .T., .F., { 'VRZ_DADOS', 'M', TamSX3( 'VRZ_DADOS' )[1], 0 } )
    oSelf:AddMapFields( 'userId'       , 'VRZ_CODUSR', .T., .F., { 'VRZ_CODUSR', 'C', TamSX3( 'VRZ_CODUSR' )[1], 0 } )
    oSelf:AddMapFields( 'checklistdata', 'VRX_DADOS' , .T., .F., { 'VRX_DADOS', 'M', TamSX3( 'VRX_DADOS' )[1], 0 } )
    oSelf:AddMapFields( 'dateCreate'   , 'VRZ_DATINC', .T., .F., { 'VRZ_DATINC', 'D', TamSX3( 'VRZ_DATINC' )[1], 0 } )
    oSelf:AddMapFields( 'type'         , 'VRX_AGRUP' , .T., .F., { 'VRX_AGRUP', 'C', TamSX3( 'VRX_AGRUP' )[1], 0 } )
    oSelf:AddMapFields( 'status'       , 'VRX_ATUAL' , .T., .F., { 'VRX_ATUAL', 'C', TamSX3( 'VRX_ATUAL' )[1], 0 } )
    oSelf:AddMapFields( 'name'         , "VRX_NAME"  , .T., .F.,   { 'VRX_NAME', 'C', 20, 0 }, "JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name')" )

Return
 
Static Function GetQueryChecklist()
    Local cQuery AS CHARACTER
     
    cQuery := " SELECT #QueryFields#"
    cQuery +=   " FROM " + RetSqlName( 'VRX' ) + " VRX "
    cQuery += " WHERE #QueryWhere#"
Return cQuery

Static Function GetQueryResponse()
    Local cQuery AS CHARACTER
     
    cQuery := " SELECT #QueryFields#"
    cQuery +=   " FROM " + RetSqlName( 'VRZ' ) + " VRZ "
    cQuery +=   " JOIN " + RetSqlName( 'VRX' ) + " VRX "
    cQuery +=   " ON VRZ.VRZ_CODVRX = VRX.VRX_CODIGO "
    cQuery += " WHERE #QueryWhere#"
Return cQuery