#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSTAF018.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSRESTFUL

/*/
//-------------------------------------------------------------------------------------------------------------
WSRESTFUL WSTAF018 DESCRIPTION "Central de Notificações" //FORMAT APPLICATION_JSON

    WSDATA user 	 AS STRING
    WSDATA titulo    AS STRING
    WSDATA texto     AS STRING
    WSDATA tipo      AS STRING
    WSDATA companyId AS STRING
    WSDATA type 	 AS INTEGER

    WSMETHOD GET ALLNOTIFICATIONS             DESCRIPTION "Retorna todas notificações" ;
        WSSYNTAX "/api/centralNotification/v1/allnotifications";
        PATH "/api/centralNotification/v1/allnotifications"

    WSMETHOD GET NOTREADNOTIFICATIONS      DESCRIPTION "Retorna as notificações não lidas para montagem do toolbar" ;
        WSSYNTAX "/api/centralNotification/v1/notreadnotifications";
        PATH "/api/centralNotification/v1/notreadnotifications"

    WSMETHOD GET SIZEOFFOLDER                 DESCRIPTION "Retorna o espaço no disco consumido pelo usuário";
        WSSYNTAX "/api/centralNotification/v1/sizeoffolder";
        PATH "/api/centralNotification/v1/sizeoffolder"

    WSMETHOD GET NUMBEROFNOTIFICATIONS        DESCRIPTION "Retorna a quantidade total de notificações";
        WSSYNTAX "/api/centralNotification/v1/numberofnotifications";
        PATH "/api/centralNotification/v1/numberofnotifications"

    WSMETHOD GET CHECKTABLE                   DESCRIPTION "Retorna se a tabela V49 existe na base.";
        WSSYNTAX "/api/centralNotification/v1/checktable";
        PATH "/api/centralNotification/v1/checktable"

    WSMETHOD POST CREATEANOTIFICATION         DESCRIPTION "Cria uma notificação" ;
        WSSYNTAX "/api/centralNotification/v1/createanotification";
        PATH "/api/centralNotification/v1/createanotification"

    WSMETHOD POST MARKASREAD                  DESCRIPTION "Marca as mensagens como lida";
        WSSYNTAX "/api/centralNotification/v1/markasread/";
        PATH "/api/centralNotification/v1/markasread"

    WSMETHOD POST DELETENOTIFICATIONS         DESCRIPTION "Deleta uma notificações";
        WSSYNTAX "/api/centralNotification/v1/deletenotifications/";
        PATH "/api/centralNotification/v1/deletenotifications"

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Retorna se a tabela V49 existe na base.

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET CHECKTABLE WSREST WSTAF018

Local oNotifications    as object
Local hasCentral        := TAFALSINDIC("V49")

oNotifications := JsonObject():New()
oNotifications['hastable']      := hasCentral

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Retorna um percentual de espaço utilizado na pasta downloads. O percentual é calculado em cima de 1GB.
@params user - Código do usuário (Nome da pasta)

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET SIZEOFFOLDER QUERYPARAM user WSREST WSTAF018

Local cUser             as character
Local nX                as numeric
Local nSize             as numeric
Local oNotifications    as object
Local aFiles            as array
Local aNotifications    as array

aFiles := {}
aNotifications  := {}
nSize := 0

self:SetContentType("application/json")
cUser := cValtoChar(self:user)

aFiles := Directory("\http-root\downloads\" +cUser+ "\*.*")

nCount := Len( aFiles )

For nX := 1 to nCount
    nSize += aFiles[nX,2]
Next nX

nSize := Round((nSize/1024)/1024, 2 )

Aadd(aNotifications,JsonObject():new())
nPos := Len(aNotifications)

aNotifications[nPos]['size']      := nSize

oNotifications := JsonObject():New()
oNotifications['items'] := aNotifications

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Marca as notificações recebidas no body como lidas.

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST MARKASREAD WSREST WSTAF018
Local nX             as numeric
Local nSize          as numeric
Local cBody          as character
Local oJson          as object
Local oNotifications as object

cBody           := ''
oJson           := JsonObject():New()
cBody           := self:GetContent()

oJson:fromJSON( cBody )

DBSelectArea("V49")
V49->(DBSetOrder( 1 ))
nSize := len(oJson["idsMessages"])

For nX := 1 to nSize
    If V49->(DBSeek(xFilial("V49") + oJson["idsMessages"][nX]))
        RecLock("V49", .F.)
        V49_LIDA   := .T.
        V49->(MsUnlock())
    EndIf
Next nX

V49->( DbCloseArea() )

oNotifications := JsonObject():New()
oNotifications['retorno'] := "Sucesso"

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Deleta as notificações solicitadas pelo usuário através do body da requisição.
@params user - Código do usuário (Nome da pasta) - Utilizado para deletar os arquivos que o usuário possui.

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD POST DELETENOTIFICATIONS QUERYPARAM user WSREST WSTAF018

Local cBody         as character
Local cUser         as character
Local nX            as numeric
Local nSize         as numeric
Local oJson         as object

cBody           := ''
oJson           := JsonObject():New()
cBody           := self:GetContent()

oJson:fromJSON( cBody )

DBSelectArea("V49")
V49->(DBSetOrder( 1 ))
nSize := len(oJson["idsMessages"])

cUser := cValtoChar(self:user)

For nX := 1 to nSize
    If V49->(DBSeek(xFilial("V49") + oJson["idsMessages"][nX]))
        RecLock("V49", .F.)
        DBDelete()
        FERASE("\http-root\downloads\"+ cUser +"\" + oJson["idsMessages"][nX] + ".csv")
        V49->(MsUnlock())
    EndIf
Next nX

V49->( DbCloseArea() )

oNotifications := JsonObject():New()
oNotifications['retorno'] := "Sucesso"

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Retorna as notificações que o usuário possui.
@params user - Código do usuário - Utilizado para montagem da query.

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET ALLNOTIFICATIONS QUERYPARAM user WSREST WSTAF018

Local nPos              as numeric
Local oNotifications    as object
Local aNotifications    as array
Local cQuery            as character
Local cUser             as character
Local cPath             as character
Local cAdress           := GETMV("MV_GCTPURL")

self:SetContentType("application/json")
cUser := cValtoChar(self:user)

nPos            := 1
aNotifications  := {}
cQuery          := RetMsgs(2,1, cUser )

(cQuery)->(dbGoTop())

while (cQuery)->(!Eof())

    Aadd(aNotifications,JsonObject():new())
    nPos := Len(aNotifications)
    cPath := "/downloads/" + Alltrim((cQuery)->USUARIO) + "/" + Alltrim((cQuery)->ID)+".csv"

    aNotifications[nPos]['status']    := Alltrim((cQuery)->LIDA)
    aNotifications[nPos]['id']        := Alltrim((cQuery)->ID)
    aNotifications[nPos]['message']   := Alltrim((cQuery)->TEXTO)
    aNotifications[nPos]['date']      := SUBSTR((cQuery)->DATA,1,4)  + "-" +SUBSTR((cQuery)->DATA,5,2) + "-" + SUBSTR((cQuery)->DATA,7,2)
    aNotifications[nPos]['label']     := Alltrim((cQuery)->TITULO)
    if FILE("http-root"+cPath)
        aNotifications[nPos]['url'] := cAdress+cPath
    else
        aNotifications[nPos]['url'] := ""
    EndIf
    aNotifications[nPos]['delete']    := 'delete'
    (cQuery)->(DbSkip())
enddo

oNotifications := JsonObject():New()
oNotifications['items'] := aNotifications

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Retorna os títulos das notificações não lidas.
@params user - Código do usuário - Utilizado para montagem da query.

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET NOTREADNOTIFICATIONS QUERYPARAM user WSREST WSTAF018

Local nPos              as numeric
Local oNotifications    as object
Local aNotifications    as array
Local cQuery            as character
Local cUser             as character

self:SetContentType("application/json")
cUser := cValtoChar(self:user)

nPos            := 1
aNotifications  := {}
cQuery          := RetMsgs(2,2, cUser )

(cQuery)->(dbGoTop())

while (cQuery)->(!Eof())
    Aadd(aNotifications,JsonObject():new())
    nPos := Len(aNotifications)
    aNotifications[nPos]['label']     := Alltrim((cQuery)->TITULO)
    (cQuery)->(DbSkip())
enddo

oNotifications := JsonObject():New()
oNotifications['items'] := aNotifications

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Retorna o número total de notificações que o usuário possui.
@params user - Código do usuário - Utilizado para montagem da query.
        type - Informa que tipo de notificação deseja receber:
             1 - Todas
             2 - Somente não lidas 
             3 - Somente lidas
@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
WSMETHOD GET NUMBEROFNOTIFICATIONS QUERYPARAM user, type WSREST WSTAF018

Local nPos              as numeric
Local oNotifications    as object
Local aNotifications    as array
Local cQuery            as character
Local cUser             as character

self:SetContentType("application/json")
cUser := cValtoChar(self:user)

nPos            := 1
cQuery          := RetMsgs(1,self:type,cUser )
aNotifications  := {}

Aadd(aNotifications,JsonObject():new())
nPos := Len(aNotifications)
aNotifications[nPos]['total']    := cvaltochar((cQuery)->TOTAL)

oNotifications := JsonObject():New()
oNotifications['items'] := aNotifications

::SetContentType("application/json")
::SetStatus(200)
::SetResponse(oNotifications:toJSON())

Return .T.

/*/{Protheus.doc} RetMsgs
    (long_description)
    @type  Function
    @author José Mauro Dourado Lopes
    @since 02/04/2020
    @version version
    @param 
        nSelect: Posição do array de onde pegarei a STRING do select.
        nWhere:  Posição do array de onde pegarei a STRING do where.
        cUser:   Usuário que desejo saber as mensagens.
    @return Retorna a query das mensagens para ser usada na montagem do JSON.
/*/
Static Function RetMsgs(nSelect,nWhere,cUser)

    Local cAlias    as character
    Local cSelect   as character
    Local cFrom     as character
    Local cWhere    as character
    Local aRetSql   as array
    Local aRetWhe   as array

    aRetSql := {}
    aRetWhe := {}

    cFrom  := RetSqlName( "V49" ) + " V49 "
    cAlias := GetNextAlias()

    //Desenvolvi a forma de montagem de query abaixo para evitar o uso de If.

    aadd(aRetSql, " COUNT(*) AS TOTAL  ")
    aadd(aRetSql, " V49.V49_ID AS ID, V49.V49_TEXTO AS TEXTO, V49.V49_ID AS ID, V49.V49_DATA AS DATA,V49.V49_USER AS USUARIO,V49.V49_TITULO AS TITULO,V49.V49_LIDA AS LIDA")

    aadd(aRetWhe, " V49.V49_USER = '" + cUser + "' AND V49.D_E_L_E_T_ = ' ' ")
    aadd(aRetWhe, " V49.V49_USER = '" + cUser + "' AND V49.D_E_L_E_T_ = ' '  AND V49.V49_LIDA = 'F' ")
    aadd(aRetWhe, " V49.V49_USER = '" + cUser + "' AND V49.D_E_L_E_T_ = ' '  AND V49.V49_LIDA = 'T' ")


    cSelect	:= "%" + aRetSql[nSelect]  + "%"
    cFrom  	:= "%" + cFrom             + "%"
    cWhere 	:= "%" + aRetWhe[nWhere]   + "%"

    BeginSql Alias cAlias
    	SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
    EndSql

Return cAlias



//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo GET
Deleta as notificações solicitadas pelo usuário através do body da requisição.
@params user - Código do usuário (Nome da pasta) - Utilizado para deletar os arquivos que o usuário possui.

@author José Mauro Dourado Lopes
@since 01/04/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
    WSMETHOD POST CREATEANOTIFICATION QUERYPARAM companyId,user,titulo,texto WSREST WSTAF018

    Local cEmpRequest	    as character
    Local cFilRequest	    as character
    Local cBody             as character
    Local nPos              as numeric
    Local nX                as numeric
    Local oNotifications    as object
    Local oJson             as object
    Local aNotifications    as array
    Local aCompany		    as array
    Local aRetCampos        as array

    cBody           := ''
    oJson           := JsonObject():New()
    cBody           := self:GetContent()
    aRetCampos      := {}
    aNotifications  := {}

    oJson:fromJSON( cBody )

    VLDDADO(oJson, @aRetCampos)

    If Len(aRetCampos) > 0
        For nX := 1 to len(aRetCampos)
            Aadd(aNotifications,JsonObject():new())
            nPos := Len(aNotifications)
            aNotifications[nPos]['mensagem']    := EncodeUTF8(aRetCampos[nX])
        Next nX
    else
        aCompany := StrTokArr( oJson["companyId"], "|" )

        cEmpRequest := aCompany[1]
        cFilRequest := aCompany[2]

        Aadd(aNotifications,JsonObject():new())

        If PrepEnv( cEmpRequest, cFilRequest )
            if UsrExist(oJson["user"]) 
                IF WSCENTRAL(oJson["user"],oJson["titulo"],oJson["texto"])
                    aNotifications[1]['mensagem']    := "Mensagem criada com sucesso."
                EndIF
            else
                aNotifications[1]['mensagem']   := STR0008 //"Este código de usuário não existe no sistema."
            Endif
        else
            aNotifications[1]['mensagem']    := "Filial inexistente."
        EndIf
    Endif

    oNotifications := JsonObject():New()
    oNotifications['items'] := aNotifications

    ::SetContentType("application/json")
    ::SetStatus(200)
    ::SetResponse(oNotifications:toJSON())

Return .T.


/*/{Protheus.doc} Função que faz a validação dos dados.
    (long_description)
    @type  Static Function
    @author user
    @since 18/09/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function VLDDADO(oJson,aRetCampos )

    if Empty(oJson["companyId"])
        AADD(aRetCampos, STR0001 )//"Campo filial obrigatório."
    EndIf

    If Empty(oJson["user"])
        AADD(aRetCampos, "Campo código de usuário obrigatório.")
    EndIf

    if Empty(oJson["titulo"])
        AADD(aRetCampos, STR0004)//"Campo título obrigatório."
    EndIf

    if(len(oJson["titulo"]) > 20)
        AADD(aRetCampos, STR0005)//"Campo título deve conter no máximo 20 caracteres."
    EndIf

    if Empty(oJson["texto"])
        AADD(aRetCampos, STR0006)//"Campo mensagem obrigatório."
    EndIf

    if(len(oJson["texto"]) > 200)
        AADD(aRetCampos, STR0007)//"Campo mensagem deve conter no máximo 200 caracteres."
    EndIf

Return
/*/{Protheus.doc} WSCENTRAL
    Cria uma nova notificação na central de notificações.

    @type  Static Function
    @author José Mauro Dourado Lopes
    @since 02/04/2020
    @param 
            cUser   - Destinatário da mensagem.
            cTitulo - Título da mensagem
            cTexto  - Texto
            cTipo   - Tipo
    @return lRet - Retorna se a mensagem foi gravada corretamente.
/*/
Function WSCENTRAL(cUser,cTitulo,cTexto)

    Local lRet 		 as logical
    Local oModelV49  as object

    Local oModel554  := FWLoadModel("TAFA555")
    Local cID        := TAFGERAID("TAF")

    lRet  := .F.

    Default cUser   := ""
    Default cTitulo := ""
    Default cTexto  := ""

    oModelV49 := oModel554:GetModel( "MODEL_V49" )

    oModel554:SetOperation(3)
    oModel554:Activate()

    oModel554:LoadValue( 'MODEL_V49', 'V49_FILIAL'	, cFilant  )
    oModel554:LoadValue( 'MODEL_V49', 'V49_ID'  	, cID  	   )
    oModel554:LoadValue( 'MODEL_V49', 'V49_USER'	, cUser    )
    oModel554:LoadValue( 'MODEL_V49', 'V49_DATA'	, DATE()   )
    oModel554:LoadValue( 'MODEL_V49', 'V49_TITULO'  , cTitulo  )
    oModel554:LoadValue( 'MODEL_V49', 'V49_TEXTO'	, cTexto   )


    If oModel554:VldData()
        FwFormCommit(oModel554)
        lRet := .T.
        oModel554:Destroy()
        oModel554 := Nil
    EndIf

Return lRet