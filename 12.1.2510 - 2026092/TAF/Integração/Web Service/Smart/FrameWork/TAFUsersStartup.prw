#include 'protheus.ch'


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFUsersStartup
Classe responsável pela criação de usuários no startup do TAF Cloud

Baseada na especificação http://tdn.totvs.com/display/TAF/Web+Service+REST+-+TAFSETUP

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
CLASS TAFUsersStartup FROM LongNameClass
    DATA oResult

    METHOD New()
    METHOD AlterPswAndEmail()
    METHOD CreateUsers()
    METHOD CreateUser()
    METHOD GetUserID()
    METHOD GetSCIMJsonText()
    METHOD GetResult()
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor

@since   13/04/2018
/*/
//-------------------------------------------------------------------
METHOD New() CLASS TAFUsersStartup
    self:oResult := JsonObject():New()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateUser
Efetua a criação de um usuário

@param oUserData Objeto Json com dados do usuário (JsonObject)

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD CreateUser( oUserData ) CLASS TAFUsersStartup
Local oUserInfo
Local cUserJson AS CHARACTER
Local cEmail AS CHARACTER
Local aRet AS ARRAY
Local oResult

oUserInfo := JsonObject():New()
oResult := JsonObject():New()
cEmail := oUserData['email']

oUserInfo['email'] := cEmail
oUserInfo['password'] := SubStr(Md5(cValToChar(Randomize(10,9999999)) + cEmail,2),1,10)
oUserInfo['name'] := oUserData['name']
oUserInfo['manager'] := oUserData['manager']
oUserInfo['group'] := '000003'

cUserJson := self:GetSCIMJsonText( oUserInfo )

aRet := FWSCIMUsrCreate( cUserJson )

If aRet[1]
    oResult['usuario'] := oUserInfo['name']
    oResult['senha'] := oUserInfo['password']
Else
    oResult['usuario'] := "erro"
    oResult['senha'] := aRet[3]

   	Conout(FWTimeStamp(3) + "   - [TAFUsersStartup|CreateUser] - ERRO|" + aRet[3] )	
EndIf

self:oResult['usuarios'][oUserData['index']] := oResult

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateUsers
Efetua a criação de usuários

@param aUsers Array de objetos json com usuários (JsonObject)

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD CreateUsers( aUsers ) CLASS TAFUsersStartup
Local nFor AS NUMERIC
Local nOldOrder AS NUMERIC
Local cCodUsr AS CHARACTER
Local cUserID AS CHARACTER
Local cManagerID AS CHARACTER
Local oResult

If Len(aUsers) > 0
    self:oResult["usuarios"] := Array( Len(aUsers) )

    For nFor := 1 To Len(aUsers)
        cCodUsr := "TAF" + cValToChar(nFor)
        cUserID := self:GetUserID( cCodUsr )

        If Empty(cUserID)
            If nFor > 1
                aUsers[nFor]['manager'] := cManagerID
            EndIf
            aUsers[nFor]['index'] := nFor
            aUsers[nFor]['name'] := cCodUsr
            self:CreateUser(aUsers[nFor])
            If nFor == 1
                cManagerID := self:GetUserID(cCodUsr)
            EndIf
        Else
            oResult := JsonObject():New()
            oResult['usuario'] := "erro"
            oResult['senha'] := "usuario já informado anteriormente, processo ignorado."//"duplicado"

            self:oResult['usuarios'][nFor] := oResult
            If nFor == 1
                cManagerID := cUserID
            EndIf

            Conout(FwTimeStamp(3) + " - [TAFUsersStartup|CreateUsers] - Aviso|usuario ja informado anteriormente, processo ignorado." )
        EndIf
    Next
Else
    Conout(FwTimeStamp(3) + " - [TAFUsersStartup|CreateUsers] - Aviso|Informacoes de usuario não recebido para processamento." )
EndIf
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AlterPswAndEmail
Altera a senha e e-mail de um usuário

@param cUserId ID do usuário a ser alterado
@param cEmail E-mail a ser colocado no usuário

@return oResult JsonObject com id do usuário e nova senha/ou erro

@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD AlterPswAndEmail( cUserId, cEmail, cNome, cPssW ) CLASS TAFUsersStartup
Local oUserInfo
Local cUserJson
Local aRet
Local oResult

Default cPssW := SubStr(Md5(cValToChar(Randomize(10,9999999)) + cEmail,2),1,10)

oResult := JsonObject():New()
oUserInfo := JsonObject():New()

oUserInfo['email'] := cEmail
oUserInfo['password'] := cPssW

cUserJson := self:GetSCIMJsonText(oUserInfo)

aRet := FWScimUsrUpdate( cUserJson, cUserID )

If aRet[1]
    oResult['usuario'] := cNome
    oResult['senha'] := oUserInfo['password']
Else
    oResult['usuario'] := "erro"
    oResult['senha'] := aRet[3]

   	Conout(FWTimeStamp(3) + "   - [TAFUsersStartup|AlterPswAndEmail] - ERRO|" + aRet[3] )	
EndIf

Return oResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUserID
Retorna o id do usuário baseado no código

@param cCodUsr Código do usuário
@return cUserId ID do usuário, caso não ache volta string vazia
@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD GetUserID( cCodUsr ) CLASS TAFUsersStartup
Local cUserID AS CHARACTER
Local nOldOrder AS NUMERIC

cUserID := ""
nOldOrder := PswOrder(2)

If PswSeek( cCodUsr )
    cUserID := PswID()
EndIf
PswOrder(nOldOrder)

Return cUserID

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSCIMJsonText
Retorna o string json no padrão SCIM

@param oUserInfo Objeto json com informações do usuário
@return cJson String no padrão SCIM para inclusão de usuário
@since   13/04/2018
@protected
/*/
//-------------------------------------------------------------------
METHOD GetSCIMJsonText( oUserInfo ) CLASS TAFUsersStartup
Local cJson := ''

cJSon += '{ '
cJSon += '   "schemas":[ '
cJSon += '      "urn:scim:schemas:core:2.0:User",'
cJSon += '      "urn:scim:schemas:extension:enterprise:2.0:User"'
cJSon += '   ],'

If oUserInfo['name'] <> Nil
    cJSon += '   "userName":"'+oUserInfo['name']+'",'
EndIf

cJSon += '   "emails":[ '
cJSon += '      { '
cJSon += '         "value":"'+oUserInfo['email']+'",'
cJSon += '         "primary":true'
cJSon += '      }'
cJSon += '   ],'
cJSon += '   "active":true,'

If oUserInfo['group'] <> Nil
    cJSon += '   "groups":[ '
    cJSon += '      { '
    cJSon += '         "value":"'+oUserInfo['group']+'"'
    cJSon += '      }'
    cJSon += '   ],'
EndIf

cJSon += '   "password":"'+oUserInfo['password']+'",'

If oUserInfo['name'] <> Nil
    cJSon += '   "ext/sAMAccountName":"'+oUserInfo['name']+'",'
EndIf

cJSon += '   "urn:scim:schemas:extension:totvs:2.0:User/forceChangePassword":true'

If oUserInfo['manager'] <> Nil
    cJson += ','
    cJSon += '   "urn:scim:schemas:extension:enterprise:2.0:User":{ '
    cJSon += '      "manager":[ '
    cJSon += '         { '
    cJSon += '            "managerid":"'+oUserInfo['manager']+'"'
    cJSon += '         }'
    cJSon += '      ]'
    cJSon += '   }'
EndIf

cJSon += '}'

Return cJSon

//-------------------------------------------------------------------
/*/{Protheus.doc} GetResult
Retorna o resultado do método CreateUsers

@param aResult Array com padrão definido de resultado das inclusões

@since   13/04/2018
/*/
//-------------------------------------------------------------------
METHOD GetResult() CLASS TAFUsersStartup
Return self:oResult

// Dummy
Function __TAFUsers()
Return