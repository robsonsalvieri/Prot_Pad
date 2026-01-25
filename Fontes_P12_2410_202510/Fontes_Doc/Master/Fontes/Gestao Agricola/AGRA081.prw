#include 'protheus.ch'
#include 'fileio.ch'

//-----------------------------------------------------------------
/*{Protheus.doc} AGRAIntegrAgro()
Classe criada para comunicacao com Beneficiamento

@author Gilson Venturi
@since 22/03/2024
@version 1.0
*/
//--------------------------------------------------------------------
CLASS AGRAIntegrAgro

    //-- ESTRUTURA INFORMA€åES TOKEN
    DATA url_autent     As Character
    DATA url_integr     AS Character
    DATA client_id      As Character
    DATA client_secret  As Character
    DATA username       As Character
    DATA password       As Character
    DATA tipo_integra   As Character
    DATA access_token   As Character
    DATA access_error   As Character
        
    METHOD New()            // Constructor
    METHOD GetDadosND7()    // METODO BUSCA DADOS TABELA ND7 - CONFIGURADOR

    METHOD GetAccessToken() // Buscar Token 

    METHOD GetTokenApiBen() // Buscar Token API BENEFICIAMENTO

END CLASS

//-----------------------------------------------------------------
/*{Protheus.doc} New()
Metodo construtor da classe

@author Gilson Venturi
@since 22/03/2024
@version 1.0
*/
//--------------------------------------------------------------------
METHOD New(cTipo) CLASS AGRAIntegrAgro
    Default cTipo := ""
    //-- token
    ::url_autent    := ""
    ::url_integr    := ""
    ::client_id     := ""
    ::client_secret := ""
    ::username      := ""
    ::password      := ""    
    ::tipo_integra  := cTipo
    ::access_token  := ""
    ::access_error  := ""

    ::GetDadosND7()

Return

//-----------------------------------------------------------------
/*{Protheus.doc} GetDadosND7()
Obtém dados da ND7

@author Gilson Venturi
@since 13/03/2024
@version 1.0
*/
//--------------------------------------------------------------------
METHOD GetDadosND7() CLASS AGRAIntegrAgro
    Local aArea     := GetArea()

    ::url_autent    := ""
    ::url_integr    := ""
    ::client_id     := ""
    ::client_secret := ""
    ::username      := ""
    ::password      := ""

    ND7->(dbSetOrder(2))    //-- ND7_FILIAL+ND7_BLOQU+ND7_TPINTE
    If ND7->(dbSeek(xFilial("ND7") + "2" + ::tipo_integra))
        ::url_autent    := RTrim( Lower(ND7->ND7_URLAUT) )
        ::url_integr    := RTrim( Lower(ND7->ND7_URLINT) )
        ::client_id     := RTrim(ND7->ND7_IDCLIE)
        ::client_secret := RTrim(ND7->ND7_IDSECR)
        ::username      := RTrim(ND7->ND7_USER)
        ::password      := RTrim(ND7->ND7_SENHA)
        ::tipo_integra  := RTrim(ND7->ND7_TPINTE)
    EndIf

    RestArea(aArea)
Return

/*{Protheus.doc} GetAccessToken
    Metodo responsavel por pegar o token de acesso ao RAC

    @type       Method
    @author     Gilson Venturi
    @since      18/03/2024
    @version    1.0
    @Return     Character, Resultado do metodo.
*/
Method GetAccessToken() Class AGRAIntegrAgro
    Local aHeadStr   As Array

    Local cParams    As Character
    Local cResult    As Character

    Local oRestClien As Object
    Local oJson      As Object 

    aHeadStr   := {}
    cParams    := ''
    cResult    := ''
    oRestClien := FwRest():New(::url_autent)

    If !Empty(::client_id) .and. !Empty(::client_secret)

        AAdd(aHeadStr, "Content-Type: application/x-www-form-urlencoded")
        AAdd(aHeadStr, "charset: UTF-8")
        AAdd(aHeadStr, "User-Agent: Protheus " + GetBuild() )

        cParams := "grant_type=client_credentials"
        cParams += "&username=" + ::username
        cParams += "&password=" + ::password
        cParams += "&client_id="+ ::client_id
        cParams += "&client_secret="+ ::client_secret
        cParams += "&scope=authorization_api"

        oRestClien:SetPath("/totvs.rac/connect/token")
        oRestClien:SetPostParams(cParams)
        oRestClien:Post(aHeadStr)
    EndIf

    If (oRestClien:GetResult() == Nil)
        If !Empty(oRestClien:cInternalError)
            cResult := oRestClien:cInternalError
            ::access_error := cResult
        Endif
    Else
        cResult := oRestClien:GetResult()
        oJson := JsonObject():New()  
        oJson:fromJson( cResult )  

        If !( Empty( oJson[ "access_token" ] ) )
            ::access_token := oJson[ "access_token" ] //token via rac
            ::access_error := ""
        Else
            ::access_token := ""
            ::access_error := cResult
        Endif

    Endif

return cResult

Method GetTokenApiBen() Class AGRAIntegrAgro
    Local aHeadStr   As Array

    Local cParams    As Character
    Local cResult    As Character

    Local oRestClien As Object
    Local oJson      As Object 

    cResult := ::GetAccessToken() //token rac

    If Empty(::access_error) 
        cResult := ""
        aHeadStr   := {}
        cParams    := ''
        oRestClien := FwRest():New(::url_integr)

        Aadd(aHeadStr, "Accept: application/json" )
        Aadd(aHeadStr, "Content-Type: application/json" )
        AAdd(aHeadStr, "charset: UTF-8")
        AAdd(aHeadStr, "User-Agent: Protheus " + GetBuild() )
        AAdd(aHeadStr, "Authorization: " + ::access_token )

        cParams := "{"
        cParams += '"username": "' + ::username + '",'
        cParams += '"password": "' + ::password + '"'       
        cParams += "}"
        
        oRestClien:SetPath("/v1/login/rac/token")
        oRestClien:SetPostParams(cParams)
        oRestClien:Post(aHeadStr)

        If (oRestClien:GetResult() == Nil)
            If !Empty(oRestClien:cInternalError)
                ::access_token := ""
                cResult := oRestClien:cInternalError
                ::access_error := cResult
            Endif
        Else
            cResult := oRestClien:GetResult()
            oJson := JsonObject():New()  
            oJson:fromJson( cResult )    
            If !( Empty( oJson[ "token" ] ) )
                ::access_token := oJson[ "token" ] //seta token recebido via beneficiamento
                ::access_error := ""
            Else
                ::access_token := ""
                ::access_error := cResult
            Endif
        Endif
    EndIf

return cResult

