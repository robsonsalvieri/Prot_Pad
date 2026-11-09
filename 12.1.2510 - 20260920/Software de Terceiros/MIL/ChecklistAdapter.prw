#include 'totvs.ch'
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
	Local aParams   := {}
	Local cSGBD     := TcGetDb()
	Local cPattern  := ""
	Local cWhere    AS CHAR
	Local lRet      := .F.
	aArea   := FwGetArea()

	ChecklistAddMapFields( self )
	::SetQuery( GetQueryChecklist() )

	if empty(cType)
		cWhere := " VRX_FILIAL = '"+ FWxFilial('VRX') +"' AND VRX.D_E_L_E_T_ = ' ' AND VRX_ATUAL <> '0'"
	else
		cWhere := " VRX_FILIAL = '"+ FWxFilial('VRX') +"' AND VRX.D_E_L_E_T_ = ' ' AND VRX_ATUAL = '1' AND VRX_AGRUP = ?"
		aAdd(aParams, AllTrim(cType))
	endif

	If !Empty(cSearch)
		cPattern := "%" + AllTrim(cSearch) + "%"
		cWhere += " AND ("
		cWhere += "VRX_CODIGO LIKE ?"
		cWhere += " OR VRX_CODUSR LIKE ?"
		cWhere += " OR VRX_AGRUP LIKE ?"
		If 'POSTGRES' $ cSGBD
			cWhere += " OR (COALESCE(CONVERT_FROM(DECODE(REGEXP_REPLACE(ENCODE(VRX_DADOS, 'hex'), '(00)+$', ''), 'hex'), 'WIN1252')::JSON ->> 'Name', '') LIKE ?) "
		Else
			cWhere += " OR JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name') LIKE ?"
		endif
		cWhere += ")"
		aAdd(aParams, cPattern)
		aAdd(aParams, cPattern)
		aAdd(aParams, cPattern)
		aAdd(aParams, cPattern)
	EndIf

	if !Empty(cFilter)
		cPattern := "%" + AllTrim(cFilter) + "%"
		cWhere += " AND ("
		cWhere += "VRX_CODIGO LIKE ?"
		If 'POSTGRES' $ cSGBD
			cWhere += " OR COALESCE(CONVERT_FROM(DECODE(REGEXP_REPLACE(ENCODE(VRX_DADOS, 'hex'), '(00)+$', ''), 'hex'), 'WIN1252')::JSON ->> 'Name', '') LIKE ?"
		Else
			cWhere += " OR JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name') LIKE ?"
		endif

		cWhere += ")"
		aAdd(aParams, cPattern)
		aAdd(aParams, cPattern)
	EndIf

	If Len(aParams) > 0
		cWhere := ChkPrepSql(cWhere, aParams)
	EndIf

	::SetWhere( cWhere )
	::SetOrder( "VRX_CODIGO" )

	lRet := ::Execute()
	If lRet
		::FillGetResponse()
	EndIf

	FwrestArea(aArea)
Return lRet

Method GetListResponse(cSearch, cVRZ_CodInt) CLASS ChecklistAdapter
	Local aArea     AS ARRAY
	Local aParams   := {}
	Local cPattern  := ""
	Local cWhere    AS CHAR
	Local lRet      := .F.
	default cVRZ_CodInt := ""

	if empty(cVRZ_CodInt) .OR. Valtype(cVRZ_CodInt) != "C"
		return .f.
	endif

	aArea   := FwGetArea()
	ResponseAddMapFields( self )
	::SetQuery( GetQueryResponse() )
	cWhere := " VRZ_FILIAL = '"+ FWxFilial('VRZ') +"' AND VRZ.D_E_L_E_T_ = ' '"
	cWhere += " AND VRZ_CODINT = ?"
	aAdd(aParams, AllTrim(cVRZ_CodInt))

	If !Empty(cSearch)
		cPattern := "%" + AllTrim(cSearch) + "%"
		cWhere += " AND (VRZ_CODIGO LIKE ? OR VRZ_CODUSR LIKE ?)"
		aAdd(aParams, cPattern)
		aAdd(aParams, cPattern)
	EndIf

	cWhere := ChkPrepSql(cWhere, aParams)

	::SetWhere( cWhere )
	::SetOrder( "VRZ_CODIGO" )

	lRet := ::Execute()
	If lRet
		::FillGetResponse()
	EndIf

	FwrestArea(aArea)
Return lRet

Static Function ChecklistAddMapFields( oSelf )
	Local cNameExpression := ChkNameExp()

	oSelf:AddMapFields( 'id'         , 'VRX_CODIGO', .T., .T., { 'VRX_CODIGO', 'C', TamSX3( 'VRX_CODIGO' )[1], 0 } )
	oSelf:AddMapFields( 'checklistId', 'VRX_CODINT', .T., .T., { 'VRX_CODINT', 'C', TamSX3( 'VRX_CODINT' )[1], 0 } )
	oSelf:AddMapFields( 'data'       , 'VRX_DADOS' , .T., .F., { 'VRX_DADOS', 'M', TamSX3( 'VRX_DADOS' )[1], 0 } )
	oSelf:AddMapFields( 'userId'     , 'VRX_CODUSR', .T., .F., { 'VRX_CODUSR', 'C', TamSX3( 'VRX_CODUSR' )[1], 0 } )
	oSelf:AddMapFields( 'dateCreate' , 'VRX_DATINC', .T., .F., { 'VRX_DATINC', 'C', TamSX3( 'VRX_DATINC' )[1], 0 } )
	oSelf:AddMapFields( 'type'       , 'VRX_AGRUP' , .T., .F., { 'VRX_AGRUP', 'C', TamSX3( 'VRX_AGRUP' )[1], 0 } )
	oSelf:AddMapFields( 'status'     , 'VRX_ATUAL' , .T., .F., { 'VRX_ATUAL', 'C', TamSX3( 'VRX_ATUAL' )[1], 0 } )
	oSelf:AddMapFields( 'statusName' , 'VRX_ATUAL_NAME' , .T., .F., { 'VRX_ATUAL_NAME', 'C',20, 0 }, "CASE WHEN VRX_ATUAL = '1' THEN '"+ STR0001 +"' ELSE '"+ STR0002 +"' END")  // Status ativo + Status inativo
	oSelf:AddMapFields( 'name'       , "VRX_NAME", .T., .F.,   { 'VRX_NAME', 'C', 20, 0 }, cNameExpression )

Return

Static Function ResponseAddMapFields( oSelf )
	Local cNameExpression := ChkNameExp()

	oSelf:AddMapFields( 'id'           , 'VRZ_CODIGO', .T., .T., { 'VRZ_CODIGO', 'C', TamSX3( 'VRZ_CODIGO' )[1], 0 } )
	oSelf:AddMapFields( 'checklistId'  , 'VRZ_CODVRX', .T., .T., { 'VRZ_CODVRX', 'C', TamSX3( 'VRZ_CODVRX' )[1], 0 } )
	oSelf:AddMapFields( 'responsedata' , 'VRZ_DADOS' , .T., .F., { 'VRZ_DADOS', 'M', TamSX3( 'VRZ_DADOS' )[1], 0 } )
	oSelf:AddMapFields( 'userId'       , 'VRZ_CODUSR', .T., .F., { 'VRZ_CODUSR', 'C', TamSX3( 'VRZ_CODUSR' )[1], 0 } )
	oSelf:AddMapFields( 'checklistdata', 'VRX_DADOS' , .T., .F., { 'VRX_DADOS', 'M', TamSX3( 'VRX_DADOS' )[1], 0 } )
	oSelf:AddMapFields( 'dateCreate'   , 'VRZ_DATINC', .T., .F., { 'VRZ_DATINC', 'C', TamSX3( 'VRZ_DATINC' )[1], 0 } )
	oSelf:AddMapFields( 'type'         , 'VRX_AGRUP' , .T., .F., { 'VRX_AGRUP', 'C', TamSX3( 'VRX_AGRUP' )[1], 0 } )
	oSelf:AddMapFields( 'status'       , 'VRX_ATUAL' , .T., .F., { 'VRX_ATUAL', 'C', TamSX3( 'VRX_ATUAL' )[1], 0 } )
	oSelf:AddMapFields( 'name'         , "VRX_NAME"  , .T., .F., { 'VRX_NAME', 'C', 20, 0 }, cNameExpression )

Return

Static Function GetQueryChecklist()
	Local cQuery AS CHARACTER
	Local oSqlHelper := DMS_SqlHelper():New()

	cQuery := " SELECT #QueryFields#"
	cQuery +=   " FROM " + oSqlHelper:NoLock('VRX', 'VRX')
	cQuery += " WHERE #QueryWhere#"
	oSqlHelper := Nil
Return cQuery

Static Function GetQueryResponse()
	Local cQuery AS CHARACTER
	Local oSqlHelper := DMS_SqlHelper():New()

	cQuery := " SELECT #QueryFields#"
	cQuery +=   " FROM " + oSqlHelper:NoLock('VRZ', 'VRZ')
	cQuery +=   " JOIN " + oSqlHelper:NoLock('VRX', 'VRX')
	cQuery +=   " ON VRZ.VRZ_CODVRX = VRX.VRX_CODIGO "
	cQuery +=   " AND VRZ.VRZ_FILIAL = VRX.VRX_FILIAL "
	cQuery +=   " AND VRX.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE #QueryWhere#"
	oSqlHelper := Nil
Return cQuery

/*/{Protheus.doc} ChkPrepSql
	Aplica bind seguro aos parametros recebidos pela API.

	@type function
	@author Bruno Forcato
	@since 28/07/2026
/*/
Static Function ChkPrepSql(cSql, aParams)
	Local oStatement := FWPreparedStatement():New(cSql)

	oStatement:SetParams(aParams)
	cSql := oStatement:GetFixQuery()
	oStatement:Destroy()
	oStatement := Nil
Return cSql

/*/{Protheus.doc} ChkNameExp
	Retorna a expressao SQL para extrair o nome do JSON armazenado no memo.

	@type function
	@author Bruno Forcato
	@since 28/07/2026
/*/
Static Function ChkNameExp(cSGBD)
	Local cExpression := ""
	default cSGBD := TcGetDb()

	If 'POSTGRES' $ cSGBD
		cExpression := "COALESCE(CONVERT_FROM(DECODE(REGEXP_REPLACE(ENCODE(VRX_DADOS, 'hex'), '(00)+$', ''), 'hex'), 'WIN1252')::JSON ->> 'Name', '')"
	Else
		cExpression := "JSON_VALUE(ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), VRX_DADOS)),''), '$.Name')"
	EndIf
Return cExpression
