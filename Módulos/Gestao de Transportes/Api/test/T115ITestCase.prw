#INCLUDE "PROTHEUS.CH"

Class T115ITestCase FROM FWDefaultTestCase
    DATA oHelper

    METHOD  SetUpClass()
    METHOD  T115ITestCase() Constructor

    METHOD  T115I_001()
    METHOD  T115I_002()
    METHOD  T115I_003()
    METHOD  T115I_004()
    METHOD  T115I_005()
    METHOD  T115I_006()
    METHOD  T115I_007()
    METHOD  T115I_008()
    METHOD  T115I_009()
    METHOD  T115I_010()
    METHOD  T115I_011()
    METHOD  T115I_012()
    METHOD  T115I_013()
    METHOD  T115I_014()
    METHOD  T115I_015()
    METHOD  T115I_016()
    METHOD  T115I_017()
    METHOD  T115I_018()

EndClass

METHOD T115ITestCase() Class T115ITestCase
    _Super:FWDefaultTestSuite()

    Self:AddTestMethod("T115I_001",,"Get Lista Todos os Grupos de Região  ")
    Self:AddTestMethod("T115I_002",,"Get com cParam correto               ")
    Self:AddTestMethod("T115I_003",,"Get com cParam incorreto             ")
    Self:AddTestMethod("T115I_004",,"Get com filtro Page                  ")
    Self:AddTestMethod("T115I_005",,"Get com filtro PageSize              ")
    Self:AddTestMethod("T115I_006",,"Get com filtro Fields                ")
    Self:AddTestMethod("T115I_007",,"Get com um Grupo de Região incorreto ")
    Self:AddTestMethod("T115I_008",,"Get com um Grupo de Região específico")

    Self:AddTestMethod("T115I_009",,"Post Json Inválido           ")
    Self:AddTestMethod("T115I_010",,"Post Json Válido             ")
    Self:AddTestMethod("T115I_011",,"Post Json Válido com Fields  ")

    Self:AddTestMethod("T115I_012",,"Put Grupo de Região Inválido ")
    Self:AddTestMethod("T115I_013",,"Put Json Inválido            ")
    Self:AddTestMethod("T115I_014",,"Put Json Válido              ")
    Self:AddTestMethod("T115I_015",,"Put Json Válido com Fields   ")

    Self:AddTestMethod("T115I_016",,"Delete com Grupo de Região inválido ")
    Self:AddTestMethod("T115I_017",,"Delete com Json válido              ")
    Self:AddTestMethod("T115I_018",,"Delete com Json válido - Remove TESTE")

Return

METHOD SetUpClass() CLASS T115ITestCase
    Local oHelper		:= FWTestHelper():New()
    Static aRetAuto := {}

Return oHelper

//Get Lista Todos os Grupos de Região
METHOD T115I_001() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            lSucess := .T.
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com cParam correto
METHOD T115I_002() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups?topGroup=SP"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['item'] <> Nil
                lSucess := AllTrim(oRet['item'][1]['topGroup']) == 'SP'
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com cParam incorreto
METHOD T115I_003() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups?code=XXXXX"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['code'] <> Nil
                lSucess := oRet['code'] == 404
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com filtro Page
METHOD T115I_004() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups?Page=3"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['item'] <> Nil
                lSucess := Len(oRet['item']) > 0
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com filtro PageSize
METHOD T115I_005() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups?PageSize=2"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['item'] <> Nil
                lSucess := Len(oRet['item']) <= 2
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com filtro Fields
METHOD T115I_006() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups?fields=topGroup"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['item'] <> Nil
                lSucess := oRet['item'][1]['code'] == Nil .And. oRet['item'][1]['topGroup'] != Nil
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com um Grupo de Região incorreto
METHOD T115I_007() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups/ABCDEZ"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['code'] <> Nil
                lSucess := oRet['code'] == 404
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Get com um Grupo de Região específico
METHOD T115I_008() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody         := ''
    Local cURL          := "/api/tms/v1/regiongroups/SP"
    Local oRet          := JsonObject():New()
    Local oHelper	    := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cBody := oHelper:UTGetWS(aHeader,/*cFile*/,/*cGetParms*/,"http://localhost:8091/rest")
        If !Empty(cBody) .And. oRet:fromJson(cBody) == Nil
            If oRet['code'] <> Nil
                lSucess := AllTrim(oRet['code']) == 'SP'
            EndIf
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Post Json Inválido
METHOD T115I_009() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups"
    Local oRet      := JsonObject():New()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.
    Local oClient := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody := '{ "TESTE": "TESTE" }'
    oClient:SetPostParams(cBody)
    oClient:Post(aHeader)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil .And. oRet['code'] <> Nil
        lSucess := .T.
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Post Json Válido
METHOD T115I_010() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups"
    Local oRet      := JsonObject():New()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.
    Local oClient := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody += '{'
    cBody += '    "regionExemptTaxes": "2",'
    cBody += '    "regionCategory": "1",'
    cBody += '    "companyId": "99",'
    cBody += '    "associatedCompanyRegionCode": "100013",'
    cBody += '    "internalId": "  100013",'
    cBody += '    "associatedCompanyRegion": "TESTE",'
    cBody += '    "branchId": "01",'
    cBody += '    "code": "TESTE",'
    cBody += '    "ISSRate": 10.85,'
    cBody += '    "state": {'
    cBody += '        "stateCode": "AC",'
    cBody += '        "stateInternalId": "AC",'
    cBody += '        "stateDescription": "ACRE"'
    cBody += '    },'
    cBody += '    "groupCategory": "3",'
    cBody += '    "companyInternalId": "9901",'
    cBody += '    "city": {'
    cBody += '        "cityCode": "00013",'
    cBody += '        "cityInternalId": "00013",'
    cBody += '        "cityDescription": "TESTE"'
    cBody += '    },'
    cBody += '    "description": "TESTE"'
    cBody += '}'

    oClient:SetPostParams(cBody)
    oClient:Post(aHeader)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil .And. AllTrim(oRet['code']) == "TESTE"
        lSucess := .T.
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Post Json Válido com Fields
METHOD T115I_011() CLASS T115ITestCase
    Local aHeader   := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups?fields=code"
    Local oRet      := JsonObject():new()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess   := .F.
    Local oClient   := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody += '{'
    cBody += '    "regionExemptTaxes": "2",'
    cBody += '    "regionCategory": "1",'
    cBody += '    "companyId": "99",'
    cBody += '    "associatedCompanyRegionCode": "100013",'
    cBody += '    "internalId": "  100013",'
    cBody += '    "associatedCompanyRegion": "TESTE2",'
    cBody += '    "branchId": "01",'
    cBody += '    "code": "TESTE2",'
    cBody += '    "ISSRate": 10.85,'
    cBody += '    "state": {'
    cBody += '        "stateCode": "AC",'
    cBody += '        "stateInternalId": "AC",'
    cBody += '        "stateDescription": "ACRE"'
    cBody += '    },'
    cBody += '    "groupCategory": "3",'
    cBody += '    "companyInternalId": "9901",'
    cBody += '    "city": {'
    cBody += '        "cityCode": "00013",'
    cBody += '        "cityInternalId": "00013",'
    cBody += '        "cityDescription": "TESTE2"'
    cBody += '    },'
    cBody += '    "description": "TESTE2"'
    cBody += '}'
    oClient:SetPostParams(cBody)
    oClient:Post(aHeader)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil
        lSucess:= oRet['code'] != Nil .And. oRet['topGroup'] == Nil
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Put Grupo de Região Inválido
METHOD T115I_012() CLASS T115ITestCase
    Local aHeader   := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/ABCDEFZZ"
    Local oRet      := JsonObject():New()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.
    Local oClient   := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody += '{'
    cBody += '    "regionExemptTaxes": "2",'
    cBody += '    "regionCategory": "1",'
    cBody += '    "companyId": "99",'
    cBody += '    "associatedCompanyRegionCode": "100013",'
    cBody += '    "internalId": "  100013",'
    cBody += '    "associatedCompanyRegion": "TESTE2",'
    cBody += '    "branchId": "01",'
    cBody += '    "code": "TESTE2",'
    cBody += '    "ISSRate": 10.85,'
    cBody += '    "state": {'
    cBody += '        "stateCode": "AC",'
    cBody += '        "stateInternalId": "AC",'
    cBody += '        "stateDescription": "ACRE"'
    cBody += '    },'
    cBody += '    "groupCategory": "3",'
    cBody += '    "companyInternalId": "9901",'
    cBody += '    "city": {'
    cBody += '        "cityCode": "00013",'
    cBody += '        "cityInternalId": "00013",'
    cBody += '        "cityDescription": "TESTE2"'
    cBody += '    },'
    cBody += '    "description": "TESTE2"'
    cBody += '}'
    oClient:SetPostParams(cBody)
    oClient:Put(aHeader, cBody)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil .And. oRet['code'] <> Nil
        lSucess:= oRet['code'] == 404
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Put Json Inválido
METHOD T115I_013() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/TESTE"
    Local oRet      := JsonObject():new()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.
    Local oClient   := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody := '{"TESTE" : "oi" }'

    oClient:SetPostParams(cBody)
    oClient:Put(aHeader, cBody)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil .And.  oRet['code'] <> Nil
        lSucess := oRet['code'] == 400
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Put Json Válido
METHOD T115I_014() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/TESTE2"
    Local oRet      := JsonObject():New()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.
    Local oClient   := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody := '{ "description": "ALTERADO" }'

    oClient:SetPostParams(cBody)
    oClient:Put(aHeader, cBody)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil
        lSucess := oRet['code'] != Nil .And. AllTrim(oRet['description']) == 'ALTERADO'
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Put Json Válido com Fields
METHOD T115I_015() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/TESTE?fields=description"
    Local oRet      := JsonObject():New()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.
    Local oClient   := FwRest():New("http://localhost:8091/rest")

    oHelper:Activate()

    oClient:SetPath(cURL)
    cBody := '{ "description": "ALTERADO" }'

    oClient:SetPostParams(cBody)
    oClient:Put(aHeader, cBody)
    cRet := oClient:GetResult()

    If oRet:fromJson(cRet) == Nil
        lSucess := AllTrim(oRet['description']) == 'ALTERADO' .And. oRet['code'] == Nil
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Delete com Grupo de Região inválido
METHOD T115I_016() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/ABCDEFZZ"
    Local oRet      := JsonObject():New()
    Local oHelper	:= FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cRet := oHelper:UTDeleteWS(cBody,aHeader,/*cFile*/,"http://localhost:8091/rest")
        If oRet:fromJson(cRet) == Nil .And. oRet['code'] <> Nil
            lSucess := oRet['code'] == 404
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Delete de uma região válida
METHOD T115I_017() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/TESTE"
    Local oRet      := JsonObject():New()
    Local oHelper   := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cRet := oHelper:UTDeleteWS(cBody,aHeader,/*cFile*/,"http://localhost:8091/rest")
        If oRet:fromJson(cRet) == Nil
            lSucess:= Len(oRet:GetProperties()) == 0
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper

//Delete de uma região válida
METHOD T115I_018() CLASS T115ITestCase
    Local aHeader       := {}
    Local cBody     := ''
    Local cRet      := ''
    Local cURL      := "/api/tms/v1/regiongroups/TESTE2"
    Local oRet      := JsonObject():New()
    Local oHelper   := FWTestHelper():New()
    Local lSucess       := .F.

    oHelper:Activate()

    If oHelper:UTSetAPI(cURL,"REST")
        cRet := oHelper:UTDeleteWS(cBody,aHeader,/*cFile*/,"http://localhost:8091/rest")
        If oRet:fromJson(cRet) == Nil
            lSucess:= Len(oRet:GetProperties()) == 0
        EndIf
    EndIf

    oHelper:lOk := lSucess
    oHelper:AssertTrue( oHelper:lOk )
Return oHelper