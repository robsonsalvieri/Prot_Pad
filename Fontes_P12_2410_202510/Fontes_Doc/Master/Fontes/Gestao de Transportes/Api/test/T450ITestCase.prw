#INCLUDE "PROTHEUS.CH"

Class T450ITestCase FROM FWDefaultTestCase
    DATA oHelper
    DATA aHeader
    DATA cURL
    DATA cParam
    DATA cAddress
    DATA oClient
    DATA cResponse
    DATA oResponse
    DATA cRequest
    DATA oRequest
    DATA lSucess

    METHOD SetUpClass()
    METHOD T450ITestCase() Constructor

    METHOD GetAPIResponse()
    METHOD TestResult()

    METHOD Get()
    METHOD GetFilter()
    METHOD GetFilterIncorrect()
    METHOD GetPage()
    METHOD GetPageSize()
    METHOD GetFields()
    METHOD GetCodeIncorrect()
    METHOD GetCode()

    METHOD PostJsonIncorrect()
    METHOD PostJson()
    METHOD PostJsonFields()

    METHOD PutCodeIncorrect()
    METHOD PutJsonIncorrect()
    METHOD PutJson()
    METHOD PutJsonFields()

    METHOD DeleteCodeIncorrect()
    METHOD DelTest1()
    METHOD DelTest2()

EndClass

METHOD T450ITestCase() Class T450ITestCase
    _Super:FWDefaultTestSuite()

    Self:AddTestMethod( "Get"                  , , "Get Lista Todos os Endereço de Solicitante"    )
    Self:AddTestMethod( "GetFilter"            , , "Get com cParam correto"                        )
    Self:AddTestMethod( "GetFilterIncorrect"   , , "Get com cParam incorreto"                      )
    Self:AddTestMethod( "GetPage"              , , "Get com filtro Page"                           )
    Self:AddTestMethod( "GetPageSize"          , , "Get com filtro PageSize"                       )
    Self:AddTestMethod( "GetFields"            , , "Get com filtro Fields"                         )
    Self:AddTestMethod( "GetCodeIncorrect"     , , "Get com um Endereço de Solicitante incorreto"  )
    Self:AddTestMethod( "GetCode"              , , "Get com um Endereço de Solicitante específico" )

    Self:AddTestMethod( "PostJsonIncorrect"    , , "Post Json Inválido "                           )
    Self:AddTestMethod( "PostJson"             , , "Post Json Válido "                             )
    Self:AddTestMethod( "PostJsonFields"       , , "Post Json Válido com Fields "                  )

    Self:AddTestMethod( "PutCodeIncorrect"     , , "Put Endereço de Solicitante Inválido "         )
    Self:AddTestMethod( "PutJsonIncorrect"     , , "Put Json Inválido "                            )
    Self:AddTestMethod( "PutJson"              , , "Put Json Válido "                              )
    Self:AddTestMethod( "PutJsonFields"        , , "Put Json Válido com Fields "                   )

    Self:AddTestMethod( "DeleteCodeIncorrect"  , , "Delete com Endereço de Solicitante inválido "  )
    Self:AddTestMethod( "DelTest1"             , , "Delete com Json válido "                       )
    Self:AddTestMethod( "DelTest2"             , , "Delete com Json válido - Remove TESTE"         )

Return

METHOD SetUpClass() CLASS T450ITestCase
    ::aHeader  := {}
    ::cURL     := "/api/tms/v1/CustomerShippingAddress"
    ::cAddress := "http://localhost:8091/rest"
    ::oHelper  := FWTestHelper():New()
    ::oRequest := JsonObject():New()

Return ::oHelper

METHOD Get() CLASS T450ITestCase

    ::cParam  := ""
    ::lSucess := ::GetAPIResponse("GET")

Return ::TestResult()

METHOD GetFilter() CLASS T450ITestCase
    Local cCode := ""
    ::cParam  := ""

    // Obtenho um código válido com o "GetAll" e utilizo
    If ::GetAPIResponse("GET")
        cCode := AllTrim( ::oResponse['item'][1]['code'] )
        ::cParam  := "?code=" + cCode

        If ::GetAPIResponse("GET")
            ::lSucess := AllTrim( ::oResponse['item'][1]['code'] ) == cCode
        EndIf
    EndIf

Return ::TestResult()

METHOD GetFilterIncorrect() CLASS T450ITestCase
    ::cParam  := "?code=XXXXXXXXXXXXXXXXXXXXXXXX"

    If ::GetAPIResponse("GET")
        ::lSucess := ::oResponse['code'] == 404
    EndIf

Return ::TestResult()

METHOD GetPage() CLASS T450ITestCase
    Local cResponse1 := ''
    ::cParam := "?Page=1"

    If ::GetAPIResponse("GET")
        cResponse1 := ::cResponse
        ::cParam := "?Page=2"

        If ::GetAPIResponse("GET")
            ::lSucess := cResponse1 != ::cResponse
        EndIf
    EndIf

Return ::TestResult()

METHOD GetPageSize() CLASS T450ITestCase
    ::cParam := "?PageSize=2"

    If ::GetAPIResponse("GET")
        ::lSucess := Len( ::oResponse['item'] ) <= 2
    EndIf

Return ::TestResult()

METHOD GetFields() CLASS T450ITestCase
    ::cParam := "?fields=RequesterCode"

    If ::GetAPIResponse("GET")
        ::lSucess := ::oResponse['item'][1]['code'] == Nil .And.;
                     ::oResponse['item'][1]['RequesterCode'] != Nil
    EndIf

Return ::TestResult()

METHOD GetCodeIncorrect() CLASS T450ITestCase
    ::cParam := "/XXXXXXXXXXXXXXXXXXXXXXXX"

    If ::GetAPIResponse("GET") .And. ::oResponse['code'] <> Nil
        ::lSucess := ::oResponse['code'] == 404
    EndIf

Return ::TestResult()

METHOD GetCode() CLASS T450ITestCase
    Local cCode := ""
    ::cParam  := ""

    // Obtenho um código válido com o "GetAll" e utilizo
    If ::GetAPIResponse("GET")
        cCode := AllTrim( ::oResponse['item'][1]['code'] )
        ::cParam  := "/" + cCode

        If ::GetAPIResponse("GET")
            ::lSucess := AllTrim( ::oResponse['code'] ) == cCode
        EndIf
    EndIf

Return ::TestResult()


METHOD PostJsonIncorrect() CLASS T450ITestCase
    ::cParam   := ""

    ::oRequest := JsonObject():New()
    ::oRequest["TESTE"] := "TESTE"

    ::lSucess := ::GetAPIResponse("POST") .And. ::oResponse['code'] >= 400

Return ::TestResult()

METHOD PostJson() CLASS T450ITestCase
    ::cParam  := ""

    // insiro um novo objeto com base em um existente.
    If ::GetAPIResponse("GET")
        ::oRequest := ::oResponse['item'][1]
        ::oRequest["code"] := "TESTE"
        ::oRequest["ShippingAddress"]["address"] := "Endereço"

        ::lSucess := ::GetAPIResponse("POST") .And. AllTrim( ::oResponse['code'] ) == "TESTE"
    EndIf

Return ::TestResult()

METHOD PostJsonFields() CLASS T450ITestCase
    ::cParam  := ""

    // insiro um novo objeto com base em um existente.
    If ::GetAPIResponse("GET")
        ::oRequest := ::oResponse['item'][1]
        ::oRequest["code"] := "TESTE2"
        ::oRequest["ShippingAddress"]["address"] := "Endereço"

        ::cParam  := "?fields=code"
        ::lSucess := ::GetAPIResponse("POST") .And. ;
                     AllTrim( ::oResponse['code'] ) == "TESTE2" .And. ;
                     ::oResponse['code'] != Nil .And. ;
                     ::oResponse['code'] == Nil
    EndIf


Return ::TestResult()

METHOD PutCodeIncorrect() CLASS T450ITestCase

    ::cParam := ""

    // pego um objeto válido como base
    If ::GetAPIResponse("GET")
        ::oRequest := ::oResponse['item'][1]
        ::oRequest["ShippingAddress"]["address"] := "Alterado"

        ::cParam := "/XXXXXXXXXXXXXXXXXXXXXXXX"

        ::lSucess := ::GetAPIResponse("PUT") .And. ;
                     ::oResponse['code'] == 404
    EndIf

Return ::TestResult()

METHOD PutJsonIncorrect() CLASS T450ITestCase

    ::cParam := "/TESTE"

    ::oRequest := JsonObject():New()
    ::oRequest["TESTE"] := "TESTE"

    ::lSucess := ::GetAPIResponse("PUT") .And. ;
                 ::oResponse['code'] >= 400

Return ::TestResult()

METHOD PutJson() CLASS T450ITestCase

    ::cParam := "/TESTE2"

    ::oRequest := JsonObject():New()
    ::oRequest["ShippingAddress"]:= JsonObject():New()
    ::oRequest["ShippingAddress"]["address"] := "ALTERADO"

    ::lSucess := ::GetAPIResponse("PUT") .And. ;
                 AllTrim( ::oResponse["ShippingAddress"]["address"] ) == 'ALTERADO'

Return ::TestResult()

METHOD PutJsonFields() CLASS T450ITestCase

    ::cParam := "/TESTE?fields=ShippingAddress.address"

    ::oRequest := JsonObject():New()
    ::oRequest["ShippingAddress"]:= JsonObject():New()
    ::oRequest["ShippingAddress"]["address"] := "ALTERADO"

    ::lSucess := ::GetAPIResponse("PUT") .And. ;
                 AllTrim( ::oResponse["ShippingAddress"]["address"] ) == 'ALTERADO' ;
                 .And. ::oResponse['code'] == Nil

Return ::TestResult()

METHOD DeleteCodeIncorrect() CLASS T450ITestCase
    ::cParam := "/XXXXXXXXXXXXXXXXXXXXXXXX"
    ::lSucess := ::GetAPIResponse("DELETE") .And. ;
                    ::oResponse['code'] >= 400

Return ::TestResult()

METHOD DelTest1() CLASS T450ITestCase
    ::cParam := "/TESTE"
    ::lSucess := ::GetAPIResponse("DELETE") .And. ;
                 IsEmptyObject( ::oResponse )

Return ::TestResult()

METHOD DelTest2() CLASS T450ITestCase
    ::cParam := "/TESTE2"
    ::lSucess := ::GetAPIResponse("DELETE") .And. ;
                 IsEmptyObject( ::oResponse )

Return ::TestResult()

METHOD GetAPIResponse( cVerb ) CLASS T450ITestCase
    Local lOk := .F.

    ::oResponse := JsonObject():New()
    ::oHelper   := FWTestHelper():New()
    ::cResponse := ''
    ::lSucess   := .F.

    ::oHelper:Activate()

    ::cRequest := ::oRequest:toJson()
    ::oClient := FwRest():New( ::cAddress )
    ::oClient:SetPath( ::cURL + ::cParam )

    Do Case
        Case cVerb == "GET"
            ::oClient:Get( ::aHeader )
        Case cVerb == "POST
            ::oClient:SetPostParams( EncodeUTF8( ::cRequest ) )
            ::oClient:Post( ::aHeader )
        Case cVerb == "PUT"
            ::oClient:Put( ::aHeader, EncodeUTF8( ::cRequest ) )
        Case cVerb == "DELETE
            ::oClient:Delete( ::aHeader )
    EndCase

    ::cResponse := ::oClient:GetResult()

    lOk := !Empty( ::cResponse ) .And. ::oResponse:fromJson( DecodeUTF8( ::cResponse ) ) == Nil

Return lOk
Static Function IsEmptyObject( oObject)

Return Len( oObject:GetProperties() ) == 0

METHOD TestResult( ) CLASS T450ITestCase
    ::oHelper:lOk := ::lSucess
    ::oHelper:AssertTrue(   ::oHelper:lOk )

Return ::oHelper