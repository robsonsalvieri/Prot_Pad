#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP.CH"

/*/{Protheus.doc} MrhLogin
Faz requisição para a API de Token do Framework na URL /api/oauth2/v1/token
@author:	Marcelo Silveira
@since:		28/10/2022
@param:		cRestURL - URL do servico REST
            cUser - Usuário do Protheus incluindo o dominio caso a integracao AD esteja habilitada
            cPassword - Senha do usuário Protheus ou da rede caso a integracao AD esteja habilitada
            cToken - Token gerado pela API do Framework
            cKeyId - Chave gerada com os dados do funcionario/participante vinculado ao usuario Protheus
            cErr - Mensagens de erros na execução da rotina caso existam
            cFilUser - Filial do funcionario vinculado ao usuario Protheus
            cMatUser - Matricula do funcionario vinculado ao usuario Protheus
@return:	lRet - Verdadeiro caso todas as consultas e validações tenham sido realizadas com sucesso
/*/
Function MrhLogin(cRestURL, cUser, cPassword, cToken, cKeyId, cFilUser, cMatUser, cErr)

    Local nX            := 0
    Local cCodUser      := ""
    Local aKeyUser      := {}

    DEFAULT cRestURL    := ""
    DEFAULT cUser       := ""
    DEFAULT cPassword   := ""
    DEFAULT cToken      := ""
    DEFAULT ckeyId      := ""
    DEFAULT cFilUser    := ""
    DEFAULT cMatUser    := ""
    DEFAULT cErr        := ""

    //Geracao do Token via API do Framework
    If !Empty(cRestURL) .And. !Empty(cUser) .And. !Empty(cPassword)
        cToken := JwtByOauth2(cRestURL, cUser, cPassword, @cErr)
    EndIf

    //Obtem o cUserId do Protheus retornado pelo Token
    If Empty(cErr) .And. !Empty(cToken)

        aKeyUser := JWTClaims(cToken)

        For nX := 1 To Len(aKeyUser)
            If UPPER(aKeyUser[nX][1]) == "USERID"
                cCodUser := aKeyUser[nX][2]
                Exit
            EndIf
        Next nX

        cErr := If( Empty(cCodUser), EncodeUTF8(STR0123), "" ) //"O código não foi identificado no cadastro de Usuários!"
    EndIf

    //Obtem os dados do funcionario a partir do usuario Protheus e gera da keyId
    If Empty(cErr) .And. !Empty(cCodUser)
        ckeyId := GetKeyIdByUser( cCodUser, @cFilUser, @cMatUser, @cErr )
    EndIf

Return( Empty(cErr) )

/*/{Protheus.doc} JwtByOauth2
Faz requisição para a API de Token do Framework
@author:	Marcelo Silveira
@since:		28/10/2022
@param:		cRestURL - URL do servico REST
            cLogin - Usuário do Protheus incluindo o dominio caso a integracao AD esteje habilitada ;
            cPWD - Senha do usuário Protheus ou da rede caso a integracao AD esteje habilitada
            cErr - Mensagens de erros na execução da rotina caso existam
@return:	cToken - Token gerado pela API do Framework
/*/
Function JwtByOauth2(cRestURL, cUser, cPassword, cErr)

    Local oRest         := Nil
    Local oToken        := Nil
    Local aHeader       := {}
    Local cToken        := ""
    Local cRet          := ""
    Local cResource     := "/api/oauth2/v1/token"

    DEFAULT cRestURL    := ""
    DEFAULT cUser       := ""
    DEFAULT cPassword   := ""
    DEFAULT cErr        := ""

    If !Empty(cRestURL) .And. !Empty(cUser) .And. !Empty(cPassword)
        
        AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
        AAdd(aHeader, "Accept: application/json")
        AAdd(aHeader, "grant_type: password")
        AAdd(aHeader, "username:" + cUser )
        AAdd(aHeader, "password:" + cPassword)

        oRest:= FwRest():New(cRestURL)
        oRest:SetPath(cResource)
        oRest:SetPostParams()
        oRest:Post(aHeader)

        //Avalia retorno da API de Token
        If !Empty( cRet := oRest:GetResult() )
            oToken := JsonObject():New()
            oToken:FromJson(cRet)
           
            If (oToken:hasProperty("access_token"))
                cToken := oToken["access_token"]
            Else
                cErr := If( oToken:hasProperty("message"), oToken["message"], EncodeUTF8(STR0124) ) //"Falha na autenticação do usuário!"
            EndIf

            FreeObj(oToken)
        EndIf

        FreeObj(oRest)

    EndIf

Return(cToken)

/*/{Protheus.doc} GetKeyIdByUser
Retorna a chave de identificação (keyId) do funcionário a partir do usuário Protheus 
@author:	Marcelo Silveira
@since:		26/09/2022
@param:		cCodUser - Código do usuário Protheus;
            cFilUser - Filial do funcionario vinculado ao usuario Protheus
            cFilUser - Matricula do funcionario vinculado ao usuario Protheus
            cErr - Retorna os erros de validação da rotina (por referência)
@return:	cKeyId - Chave de identificação do funcionário
/*/

/*
O cCodUser é o código do usuário que retornado pela API de Token do Protheus.
A partir desse código de usuário serão obtidos os dados do funcionário por meio da pesquisa aos dados:
- Identificação e validação do Funcionário vinculado ao usuário do Protheus (Tabela SRA)
- Identificação e validação do Participante vinculado ao funcionário (Tabela RD0)
- Identificação e validação das permissões do Usuário do Portal vinculado ao Participante (Tabela RJD)
*/
Function GetKeyIdByUser( cCodUser, cFilUser, cMatUser, cErr )

    Local lOkRD0        := .F.   
    Local aRetFun       := {}
    Local cKey          := ""
    Local cCodLogin     := ""
    Local cCodEMP       := ""
    Local cCodFIL       := ""
    Local cCodMAT       := ""
    Local cFilRJD       := ""
    Local cFilAI3       := ""
    Local cCodAI3       := ""
    Local cAliasSRA     := ""
    Local cAliasRJD     := ""
    Local __cWhere      := ""    
    Local __cSRAtab     := ""
    Local __cRD0tab     := ""
    Local __cRJDtab     := ""
    Local __cDelete     := ""
    Local cNoVinc       := STR0120 //"Esse usuário não possui Vinculo Funcional cadastrado!"
    Local cNoRD0        := STR0121 //"Não foi possível obter os dados do Participante vinculado a este funcionário!"
    Local cNoRJD        := STR0122 //"Este usuário nÃo possui registro vinculado na tabela de Permissões do Meu RH (RJD)"

	DEFAULT cCodUser	:= ""
    DEFAULT cFilUser	:= ""
    DEFAULT cMatUser	:= ""
    DEFAULT cErr        := ""

    If !Empty( cCodUser )

        //Obtem os dados do funcionario vinculado ao usuario se houver
        aRetFun := FWSFALLUSERS({cCodUser},{"USR_GRPEMP", "USR_FILIAL", "USR_CODFUNC"}) //Empresa, Filial, Matricula
        cErr    := If( Len(aRetFun) > 0 .And. Len(aRetFun[1]) == 5, "", cNoVinc )

        If Empty(cErr)

            //Atribui os valores de Empresa, Filial e Matricula
            cCodEMP := If( !Empty(aRetFun[1,3]), aRetFun[1,3], "")
            cCodFIL := If( !Empty(aRetFun[1,4]), PADR(aRetFun[1,4], FWSizeFilial()), "")
            cCodMAT := If( !Empty(aRetFun[1,5]), aRetFun[1,5], "")

            If Empty(cCodEMP) .Or. Empty(cCodFIL) .Or. Empty(cCodMAT)
                cErr := cNoVinc
            Else
                __cSRAtab   := "%" + RetFullName("SRA", cCodEMP) + "%"
                __cRD0tab   := "%" + RetFullName("RD0", cCodEMP) + "%"   
                __cDelete   := "% SRA.D_E_L_E_T_ = ' ' AND RD0.D_E_L_E_T_ = ' ' %"

                __cWhere      := "% RA_FILIAL = '" + cCodFIL + "'"
                __cWhere      += " AND RA_MAT = '" + cCodMAT + "' %"

                cAliasSRA  := GetNextAlias()

                BeginSql ALIAS cAliasSRA
                    SELECT 
                        RA_FILIAL, RA_MAT, RA_SITFOLH, RD0_CODIGO, RD0_LOGIN, RD0_PORTAL, RD0_FILRH, RA_CIC 
                    FROM %exp:__cSRAtab% SRA
                    INNER JOIN %exp:__cRD0tab% RD0 ON
                        SRA.RA_CIC = RD0.RD0_CIC
                    WHERE 	
                        %Exp:__cWhere% AND
                        %Exp:__cDelete%
                EndSql

                While !(cAliasSRA)->(Eof())
                    lOkRD0    := .T.
                    cFilAI3   := (cAliasSRA)->RD0_FILRH
                    cCodAI3   := (cAliasSRA)->RD0_PORTAL
                    cFilUser  := (cAliasSRA)->RA_FILIAL
                    cMatUser  := (cAliasSRA)->RA_MAT
                    cCodLogin := If( Empty(AllTrim((cAliasSRA)->RD0_LOGIN)), AllTrim((cAliasSRA)->RA_CIC), AllTrim((cAliasSRA)->RD0_LOGIN) )

                    cKey := (cAliasSRA)->RA_MAT + "|" + ;
                            cCodLogin + "|" + ;
                            (cAliasSRA)->RD0_CODIGO + "|" + ;
                            DtoS(dDataBase) + "|" + ;
                            (cAliasSRA)->RA_FILIAL + "|" + ;
                            cValToChar((cAliasSRA)->RA_SITFOLH == "D") + "|" + ;
                            cCodEMP
                    (cAliasSRA)->(dbSkip())
                EndDo

                (cAliasSRA)->( DBCloseArea() )

                //Verifica se o usuario do Portal vinculado ao Participante possui permissão na tabela RDJ 
                If !Empty(cFilAI3) .Or. !Empty(cCodAI3)

                    cFilRJD   := xFilial("RJD", cFilAI3)
                    
                    __cRJDtab := "%" + RetFullName("RJD", cCodEMP) + "%"
                    __cDelete := "% RJD.D_E_L_E_T_ = ' ' %"
                    __cWhere  := "% RJD_FILIAL = '" + cFilRJD + "'"
                    __cWhere  += " AND RJD_CODUSU = '" + cCodAI3 + "' %"

                    cAliasRJD := GetNextAlias()
                    
                    BeginSql ALIAS cAliasRJD
                        SELECT 
                            COUNT(*) QTD
                        FROM %exp:__cRJDtab% RJD
                        WHERE 	
                            %Exp:__cWhere% AND %Exp:__cDelete%
                    EndSql
                    
                    cErr   := If( (cAliasRJD)->(!Eof()) .and. (cAliasRJD)->QTD > 0, "", cNoRJD)

                    (cAliasRJD)->( DBCloseArea() )
                Else 
                    cErr := If(lOkRD0, cNoRJD, cNoRD0)
                EndIf
            EndIf
        EndIf
    EndIf

Return(cKey)

Function fLogoutRest(oSelf)

Local cMsg          := ""
Local cRestURL      := ""
Local oBody         := NIL
Local oRest         := NIL
Local cBody         := NIL
Local cToken        := NIL
Local aHeader       := NIL
Local cSource       := NIL
Local oResult       := NIL
Local nPosPorta     := 0
Local cRestPort     := ""
Local cRestFull     := ""
Local cPrefix       := "https://"
Local cIpFixo       := "localhost:"
Local nPosContext   := 0
Local cContext      := ""

DEFAULT oSelf := NIL

If !Empty( cToken := oSelf:GetHeader('Authorization') )
    If ( !Empty(cBody := oSelf:GetContent()) )

        oResult  := JsonObject():New()
        oBody    := JsonObject():New()
        oBody:FromJson(cBody)
        If(oBody:hasProperty('restUrl'))
            cRestURL  := oBody["restUrl"]
            cRestFull := cRestURL

            // Monta a API do frame que será consumida.
            cSource   := "/api/framework/v1/invalidateToken"
            //Busca a porta do REST conforme tag padrão HTTPREST existente no appserver.
            cRestPort := GetConfig("HTTPREST","port", "") 

            If !Empty(cRestPort)
                // Verifica se o cliente usa https ou http.
                cPrefix := if( cPrefix $ cRestURL, cPrefix, "http://" )
                // Remove o prefixo da URL. 
                // Neste trecho, a URL ficará assim: spon010125021.sp01.local:8103/restT1
                cRestFull  := StrTran(cRestURL, cPrefix)
                // Verifica onde se encontra os : da URL.
                If ( nPosPorta := At(":", cRestFull) ) > 0
                    // Verifica a posiçã onde inicia o rootContext da URL. Ex: ...../restT1
                    If ( nPosContext := At("/", cRestFull) ) > 0
                        // Inicia a montagem da URL utilizando a porta do rest presente na tag HTTPREST.
                        cContext  := SubStr(cRestFull, nPosContext, (Len(cRestFull)-nPosContext)+1)
                        cRestFull := cPrefix + SubStr(cRestFull,1,nPosPorta-1)
                        // Como a requisiçao é interna, pode-se usar localhost, pois já está dentro do contexto do appserver.
                        cRestFull := cPrefix + cIpFixo + cRestPort + cContext
                        cRestURL := cRestFull
                    EndIf
                EndIF
            EndIf

            // Monta o header da requisição
            aHeader := {}
            AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
            AAdd(aHeader, "Accept: application/json")
            AAdd(aHeader, "Authorization: " + cToken)


            oRest := FwRest():New(cRestURL)
            oRest:SetPath(cSource)
            oRest:Post(aHeader)
            oResult:FromJson(oRest:GetResult())

            // Bearer Token invalidado com sucesso.
            If oResult:hasProperty("message")
                cMsg := oResult["message"]
                Conout(">>>>> " + DecodeUTF8( cMsg ) + " <<<<<")
            ElseIf oResult:hasProperty("errorMessage")
                cMsg := oResult["errorMessage"]
                Conout(">>>>> " + DecodeUTF8( cMsg ) + " <<<<<")
            Else
                cMsg := oRest:GetLastError()
                Conout(">>>>> " + DecodeUTF8( cMsg ) + " <<<<<")
            EndIf

            FreeObj( oResult )
            FreeObj( oRest )
            FreeObj( oBody )
        EndIf
    EndIf
EndIf

Return .T.
