#INCLUDE "PROTHEUS.CH"

Class T440ITestCase FROM FWDefaultTestCase
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
    METHOD T440ITestCase() Constructor

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

METHOD T440ITestCase() Class T440ITestCase
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

METHOD SetUpClass() CLASS T440ITestCase
    ::aHeader  := {}
    ::cURL     := "/api/tms/v1/Requesters"
    ::cAddress := "http://localhost:8091/rest"
    ::oHelper  := FWTestHelper():New()
    ::oRequest := JsonObject():New()

Return ::oHelper

METHOD Get() CLASS T440ITestCase

    ::cParam  := ""
    ::lSucess := ::GetAPIResponse("GET")

Return ::TestResult()

METHOD GetFilter() CLASS T440ITestCase
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

METHOD GetFilterIncorrect() CLASS T440ITestCase
    ::cParam  := "?code=XXXXXXXXXXXXXXXXXXXXXXXX"

    If ::GetAPIResponse("GET")
        ::lSucess := ::oResponse['code'] == 404
    EndIf

Return ::TestResult()

METHOD GetPage() CLASS T440ITestCase
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

METHOD GetPageSize() CLASS T440ITestCase
    ::cParam := "?PageSize=2"

    If ::GetAPIResponse("GET")
        ::lSucess := Len( ::oResponse['item'] ) <= 2
    EndIf

Return ::TestResult()

METHOD GetFields() CLASS T440ITestCase
    ::cParam := "?fields=Name"

    If ::GetAPIResponse("GET")
        ::lSucess := ::oResponse['item'][1]['code'] == Nil .And.;
                     ::oResponse['item'][1]['Name'] != Nil
    EndIf

Return ::TestResult()

METHOD GetCodeIncorrect() CLASS T440ITestCase
    ::cParam := "/XXXXXXXXXXXXXXXXXXXXXXXX"

    If ::GetAPIResponse("GET") .And. ::oResponse['code'] <> Nil
        ::lSucess := ::oResponse['code'] == 404
    EndIf

Return ::TestResult()

METHOD GetCode() CLASS T440ITestCase
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


METHOD PostJsonIncorrect() CLASS T440ITestCase
    ::cParam   := ""

    ::oRequest := JsonObject():New()
    ::oRequest["TESTE"] := "TESTE"

    ::lSucess := ::GetAPIResponse("POST") .And. ::oResponse['code'] >= 400

Return ::TestResult()

METHOD PostJson() CLASS T440ITestCase
    ::cParam  := ""

    // insiro um novo objeto com base em um existente.
    If ::GetAPIResponse("GET")
        ::oRequest := ::oResponse['item'][1]
        ::oRequest["code"] := "TESTE"
        ::oRequest["Name"] := "TESTE"

        ::lSucess := ::GetAPIResponse("POST") .And. AllTrim( ::oResponse['code'] ) == "TESTE"
    EndIf

Return ::TestResult()

METHOD PostJsonFields() CLASS T440ITestCase
    ::cParam  := ""

    // insiro um novo objeto com base em um existente.
    If ::GetAPIResponse("GET")
        ::oRequest := ::oResponse['item'][1]
        ::oRequest["code"] := "TESTE2"
        ::oRequest["Name"] := "TESTE2"

        ::cParam  := "?fields=code"
        ::lSucess := ::GetAPIResponse("POST") .And. ;
                     AllTrim( ::oResponse['code'] ) == "TESTE2" .And. ;
                     ::oResponse['code'] != Nil .And. ;
                     ::oResponse['Name'] == Nil
    EndIf


Return ::TestResult()

METHOD PutCodeIncorrect() CLASS T440ITestCase

    ::cParam := ""

    // pego um objeto válido como base
    If ::GetAPIResponse("GET")
        ::oRequest := ::oResponse['item'][1]
        ::oRequest["Name"] := "Alterado"

        ::cParam := "/XXXXXXXXXXXXXXXXXXXXXXXX"

        ::lSucess := ::GetAPIResponse("PUT") .And. ;
                     ::oResponse['code'] == 404
    EndIf

Return ::TestResult()

METHOD PutJsonIncorrect() CLASS T440ITestCase

    ::cParam := "/TESTE"

    ::oRequest := JsonObject():New()
    ::oRequest["TESTE"] := "TESTE"

    ::lSucess := ::GetAPIResponse("PUT") .And. ;
                 ::oResponse['code'] >= 400

Return ::TestResult()

METHOD PutJson() CLASS T440ITestCase

    ::cParam := "/TESTE2"

    ::oRequest := JsonObject():New()
    ::oRequest["Name"] := "ALTERADO"

    ::lSucess := ::GetAPIResponse("PUT") .And. ;
                 AllTrim( ::oResponse['Name'] ) == 'ALTERADO'

Return ::TestResult()

METHOD PutJsonFields() CLASS T440ITestCase

    ::cParam := "/TESTE?fields=Name"

    ::oRequest := JsonObject():New()
    ::oRequest["Name"] := "ALTERADO"

    ::lSucess := ::GetAPIResponse("PUT") .And. ;
                 AllTrim( ::oResponse['Name'] ) == 'ALTERADO' ;
                 .And. ::oResponse['code'] == Nil

Return ::TestResult()

METHOD DeleteCodeIncorrect() CLASS T440ITestCase
    ::cParam := "/XXXXXXXXXXXXXXXXXXXXXXXX"
    ::lSucess := ::GetAPIResponse("DELETE") .And. ;
                    ::oResponse['code'] >= 400

Return ::TestResult()

METHOD DelTest1() CLASS T440ITestCase
    ::cParam := "/TESTE"
    ::lSucess := ::GetAPIResponse("DELETE") .And. ;
                 IsEmptyObject( ::oResponse )

Return ::TestResult()

METHOD DelTest2() CLASS T440ITestCase
    ::cParam := "/TESTE2"
    ::lSucess := ::GetAPIResponse("DELETE") .And. ;
                 IsEmptyObject( ::oResponse )

Return ::TestResult()

METHOD GetAPIResponse( cVerb ) CLASS T440ITestCase
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

METHOD TestResult( ) CLASS T440ITestCase
    ::oHelper:lOk := ::lSucess
    ::oHelper:AssertTrue(   ::oHelper:lOk )

Return ::oHelper