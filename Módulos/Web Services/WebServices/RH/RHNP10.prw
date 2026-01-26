#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP10.CH"

Function RHNP10()
Return .T.

WSRESTFUL benefaction DESCRIPTION STR0001 //"Serviço responsável pelo tratamento de beneficiários e dependentes."

WSDATA page              		As String Optional
WSDATA pageSize          		As String Optional

//****************************** GETs ***********************************

	WSMETHOD GET dependents ;
		DESCRIPTION EncodeUTF8(STR0002) ; //"Retorna os dependentes do usuário."
		PATH "/benefaction/dependents/{employeeId}" ;
		PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET detDependent ;
		DESCRIPTION EncodeUTF8(STR0024) ; //"Retorna os detalhes do dependente usuário."
		PATH "/benefaction/dependent/{dependentId}" ;
		PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET beneficiaries ;
		DESCRIPTION EncodeUTF8(STR0015) ; //"Retorna os beneficiários do usuário."
		PATH "/benefaction/beneficiaries/{employeeId}" ;
		PRODUCES 'application/json;charset=utf-8'

	WSMETHOD GET detBeneficiary ;
		DESCRIPTION EncodeUTF8(STR0025) ; //"Retorna os detalhes do beneficiário usuário."
		PATH "/benefaction/beneficiary/{beneficiaryId}" ;
		PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL

// -------------------------------------------------------------------
// - Retorna os dependentes
// -------------------------------------------------------------------

WSMETHOD GET dependents WSSERVICE benefaction

	Local oDependente := JsonObject():New()

	Local aDataLogin := {}

	Local lHabil	 := .F.

	Local cCodRD0	 := ""
	Local cRD0Login  := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cToken	 := ""
	Local cKeyId	 := ""
	Local cJson		 := ""

	DEFAULT Self:page              := "1"
	DEFAULT Self:pageSize          := "10"

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken      := Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]
	EndIf

	//Busca a permissão
	fPermission(cBranchVld, cRD0Login, cCodRD0, "dependents", @lHabil)
	If !lHabil
		SetRestFault(400, EncodeUTF8( STR0003 )) //"Permissão negada ao serviço de dependentes."
		Return (.F.)
	EndIf

	oDependente["items"] := fDependents( cBranchVld, cMatSRA )
	oDependente["hasNext"] := .F.

	cJson := oDependente:toJson()
	::SetResponse(cJson)

Return (.T.)

// -------------------------------------------------------------------
// - Retorna os detalhes do dependentes
// -------------------------------------------------------------------

WSMETHOD GET detDependent WSRECEIVE dependentId WSSERVICE benefaction

	Local oDetail := JsonObject():New()

	Local aDataLogin := {}
	Local cId		 := self:aUrlParms[2]

	Local lHabil	 := .F.

	Local cCodRD0	 := ""
	Local cRD0Login  := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cToken	 := ""
	Local cKeyId	 := ""
	Local cJson		 := ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken      := Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]
	EndIf

	//Busca a permissão
	fPermission(cBranchVld, cRD0Login, cCodRD0, "dependents", @lHabil)
	If !lHabil
		SetRestFault(400, EncodeUTF8( STR0003 )) //"Permissão negada ao serviço de dependentes."
		Return (.F.)
	EndIf

	detailDependent( cBranchVld, cMatSRA, cId, @oDetail )

	cJson := oDetail:toJson()
	::SetResponse(cJson)

Return (.T.)

// -------------------------------------------------------------------
// - Retorna os beneficiários
// -------------------------------------------------------------------

WSMETHOD GET beneficiaries WSSERVICE benefaction

	Local oBenef := JsonObject():New()

	Local aDataLogin := {}

	Local lHabil	 := .F.

	Local cCodRD0	 := ""
	Local cRD0Login  := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cToken	 := ""
	Local cKeyId	 := ""
	Local cJson		 := ""

	DEFAULT Self:page              := "1"
	DEFAULT Self:pageSize          := "10"

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken      := Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]
	EndIf

	//Busca a permissão
	fPermission(cBranchVld, cRD0Login, cCodRD0, "beneficiaries", @lHabil)
	If !lHabil
		SetRestFault(400, EncodeUTF8( STR0026 )) //"Permissão negada ao serviço de beneficiários."
		Return (.F.)
	EndIf

	oBenef["items"] := fBeneficiaries( cBranchVld, cMatSRA )
	oBenef["hasNext"] := .F.

	cJson := oBenef:toJson()
	::SetResponse(cJson)

Return (.T.)

// -------------------------------------------------------------------
// - Retorna os detalhes do beneficiário
// -------------------------------------------------------------------

WSMETHOD GET detBeneficiary WSRECEIVE beneficiaryId WSSERVICE benefaction

	Local oDetail := JsonObject():New()

	Local aDataLogin := {}
	Local cId		 := self:aUrlParms[2]

	Local lHabil	 := .F.

	Local cCodRD0	 := ""
	Local cRD0Login  := ""
	Local cBranchVld := ""
	Local cMatSRA    := ""
	Local cToken	 := ""
	Local cJson		 := ""

	::SetHeader('Access-Control-Allow-Credentials' , "true")

	cToken      := Self:GetHeader('Authorization')
	cKeyId  	:= Self:GetHeader('keyId')

	aDataLogin := GetDataLogin(cToken,,cKeyId)
	If Len(aDataLogin) > 0
		cCodRD0	    := aDataLogin[3]
		cRD0Login	:= aDataLogin[2]
		cBranchVld	:= aDataLogin[5]
		cMatSRA	    := aDataLogin[1]
	EndIf

	//Busca a permissão
	fPermission(cBranchVld, cRD0Login, cCodRD0, "beneficiaries", @lHabil)
	If !lHabil
		SetRestFault(400, EncodeUTF8( STR0026 )) //"Permissão negada ao serviço de beneficiários."
		Return (.F.)
	EndIf

	detailBeneficiary( cBranchVld, cMatSRA, StrTokArr( cId, "|" ) , @oDetail )

	cJson := oDetail:toJson()
	::SetResponse(cJson)

Return (.T.)
