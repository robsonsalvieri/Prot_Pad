#Include 'Protheus.ch'
#Include 'TMSAC30.ch'

Static lTMC30Pst := ExistBlock("TMC30PST")
Static lTMC30RGT := ExistBlock("TMC30RGT")
Static _oDN5     := Nil
Static _oSttsDN5 := Nil

/*{Protheus.doc} TMSAC30()
Função Dummy. Utilizada na verificação da existencia de fonte

@author Carlos Alberto Gomes Junior
@since 14/07/2022
*/
Function TMSAC30()
Return

/*{Protheus.doc} TMSBCACOLENT()
Classe para integração SIGATMS x Coleta/Entrega

@author Valdemar Roberto Mognon
@since 09/03/2022
*/
CLASS TMSBCACOLENT

    DATA alias_config  AS CHARACTER
    DATA cCod_Fon      AS CHARACTER
    DATA last_error    AS CHARACTER
    DATA all_error     AS CHARACTER
    DATA desc_error    AS CHARACTER
    DATA access_token  AS CHARACTER
    DATA time_token    AS CHARACTER
    DATA data_token    AS DATA
    DATA time_expire   AS NUMERIC
    DATA url_token     AS CHARACTER
    DATA client_id     AS CHARACTER
    DATA client_secret AS CHARACTER
    DATA acr_values    AS CHARACTER
    DATA username      AS CHARACTER
    DATA password      AS CHARACTER
    DATA config_recno  AS NUMERIC
    DATA url_app       AS CHARACTER
    DATA type_file     AS CHARACTER
    DATA result_ok     AS CHARACTER
    DATA codfon        AS CHARACTER
    DATA filext        AS CHARACTER
	DATA cTipAut       AS CHARACTER
    DATA LocMap        AS CHARACTER
    DATA QtVgMap       AS NUMERIC
	DATA cTipPla       AS CHARACTER
    DATA cRetSucesso   AS CHARACTER
    DATA cRetInsucesso AS CHARACTER
    
	
    METHOD New() Constructor
    METHOD IsTokenActive()
    METHOD DbGetToken()
    METHOD GetToken()
    METHOD GetActiveToken()
    METHOD Post()
    METHOD Put()
    METHOD Get()
    METHOD Delete()
    
END CLASS

/*{Protheus.doc} New()
Método construtor da classe

@author Valdemar Roberto Mognon
@since 09/03/2022
@version 1.0
*/
METHOD New( cAliasConf, cCodFon ) CLASS TMSBCACOLENT

    DEFAULT cAliasConf := ""
    DEFAULT cCodFon    := ""

    ::Alias_Config  := cAliasConf
    ::cCod_Fon      := cCodFon
    ::last_error    := ""
    ::all_error     := ""
    ::desc_error    := ""
    ::access_token  := ""
    ::data_token    := CtoD("")
    ::time_token    := ""
    ::time_expire   := 0
    ::url_token     := ""
    ::client_id     := ""
    ::client_secret := ""
    ::acr_values    := ""
    ::username      := ""
    ::password      := ""
    ::config_recno  := 0
    ::type_file     := ""
    ::cTipAut       := ""
    ::LocMap        := ""
    ::QtVgMap       := 0
    ::cTipPla       := ""
    ::cRetSucesso   := ""
    ::cRetInsucesso := ""

Return

/*{Protheus.doc} IsTokenActive()
Busca se existe configuração e token Ativo

@author Carlos A. Gomes Jr.
@since 16/03/22
*/
METHOD IsTokenActive() CLASS TMSBCACOLENT
Local lRet := .F.

    If !Empty(::access_token)
        lRet := CalcVldDt(::data_token,::time_token,::time_expire)
    EndIf

    If !lRet .And. ::DbGetToken() .And. !Empty(::data_token)
        lRet := CalcVldDt(::data_token,::time_token,::time_expire)
    EndIf

Return lRet

/*{Protheus.doc} CalcVldDt()
Calcula se o Token ainda é valido

@author Carlos A. Gomes Jr.
@since 16/03/22
*/
Static Function CalcVldDt(dDtToken,cHrToken,nExpire)

    Local lRet  := .F.
    Local cTime := ""
    Local nSecs := 0

    DEFAULT dDtToken := CtoD("")
    DEFAULT cHrToken := ""
    DEFAULT nExpire  := 0

    If Date() == dDtToken //Deve ser utilizado Date() para garantir a data real e não a digitada no sistema
        cTime := ElapTime( cHrToken, Time() ) 
        nSecs := Hrs2Min( cTime ) * 60 + Val( SubStr( cTime, 7, 2 ) )
        lRet  := ( nExpire - 5 > nSecs ) //Para garantir o token testamos 5 segundos antes do fim da validade
    EndIf

Return lRet

/*{Protheus.doc} DbGetToken()
Busca configuração de Token na base

@author Carlos A. Gomes Jr.
@since 16/03/22
*/
METHOD DbGetToken() CLASS TMSBCACOLENT

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local lRet      := .F.
Local cPrefix   := ::Alias_Config
Local aArea
Local lDefEsp   := DN1->(ColumnPos("DN1_DEFESP")) > 0

    If !Empty(cPrefix)
        aAreas := { GetArea("DN6"), GetArea(cPrefix), GetArea() }
        cQuery  := "SELECT "
        cQuery  += cPrefix + "." + cPrefix + "_DTTOKE DTTOKE, "
        cQuery  += cPrefix + "." + cPrefix + "_HRTOKE HRTOKE, "
        cQuery  += cPrefix + "." + cPrefix + "_EXPIRE EXPIRE, "
        cQuery  += cPrefix + "." + cPrefix + "_URLTOK URLTOK, "
		If cPrefix != "DNM"
           cQuery  += cPrefix + "." + cPrefix + "_ID     ID, "
           cQuery  += cPrefix + "." + cPrefix + "_SECRET SECRET, "
           cQuery  += cPrefix + "." + cPrefix + "_TENANT TENANT, "
        EndIf
        cQuery  += cPrefix + "." + cPrefix + "_USER   USUAR, "
        cQuery  += cPrefix + "." + cPrefix + "_PASSW  PASSW, "
        cQuery  += cPrefix + "." + cPrefix + "_URLAPP URLAPP, "
        If AliasInDic("DNM") .And. cPrefix == "DNM"
            If DNM->(ColumnPos("DNM_LOCMAP")) > 0
                cQuery  += cPrefix + "." + cPrefix + "_LOCMAP LOCMAP, "
            EndIf
            If DNM->(ColumnPos("DNM_QTVGMP")) > 0
                cQuery  += cPrefix + "." + cPrefix + "_QTVGMP QTVGMP, "
            EndIf
            If DNM->(ColumnPos("DNM_TIPPLA")) > 0
                cQuery  += cPrefix + "." + cPrefix + "_TIPPLA TIPPLA, "
            EndIf
        EndIf
        cQuery  += cPrefix + ".R_E_C_N_O_  RECNO "
        cQuery  += "FROM " + RetSQLName(cPrefix) + " " + cPrefix + " "
        cQuery  += "INNER JOIN " + RetSQLName("DN0") + " DN0 ON "
        cQuery  += "     DN0.DN0_FILIAL = '" + xFilial("DN0") + "' "
        cQuery  += " AND DN0.DN0_CODIGO = " + cPrefix + "." + cPrefix + "_CODCON "
        cQuery  += " AND DN0.DN0_ATIVO  = '1' "
        cQuery  += " AND DN0.DN0_CODMOD = " + StrZer(nModulo,2) + " "
        cQuery  += " AND DN0.D_E_L_E_T_ = '' "
        cQuery  += "WHERE " + cPrefix + "." + cPrefix + "_FILIAL = '" + xFilial(cPrefix) + "' "
        cQuery  += "  AND " + cPrefix + "." + cPrefix + "_MSBLQL = '2' "
        If cPrefix == "DN1" .And. lDefEsp .And. !Empty(::cCod_Fon)
            cQuery += "AND DN1.DN1_CODFON = '" + ::cCod_Fon + "' "
        EndIf
        cQuery  += "  AND " + cPrefix + "." + "D_E_L_E_T_ = '' "

        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
        TcSetField(cAliasQry,"DTTOKE", "D", 8, 0)

        If (cAliasQry)->(Eof())
            ::result_ok := ""
            ::all_error += ( ::last_error := STR0001 + cPrefix + STR0002 ) + CRLF	//-- "Configuração " # " não encontrada."

        Else
            DbSelectArea(cPrefix)
            DbGoTo((cAliasQry)->RECNO)
            ::access_token  := (cPrefix)->(FieldGet(FieldPos(cPrefix+"_TOKEN")))
            ::data_token    := (cAliasQry)->DTTOKE
            ::time_token    := AllTrim((cAliasQry)->HRTOKE)
            ::time_expire   := (cAliasQry)->EXPIRE
            ::url_token     := AllTrim((cAliasQry)->URLTOK) + Iif(Right(AllTrim((cAliasQry)->URLTOK),1) != "/","/","")
			If cPrefix != "DNM"
               ::client_id     := AllTrim((cAliasQry)->ID)
               ::client_secret := AllTrim((cAliasQry)->SECRET)
               ::acr_values    := AllTrim((cAliasQry)->TENANT)
            EndIf
            ::username      := Lower(AllTrim((cAliasQry)->USUAR))
            ::password      := AllTrim((cAliasQry)->PASSW)
            ::url_app       := AllTrim((cAliasQry)->URLAPP) + Iif(Right(AllTrim((cAliasQry)->URLAPP),1) != "/","/","")
            ::config_recno  := (cAliasQry)->RECNO
            ::codfon        := (cPrefix)->(FieldGet(FieldPos(cPrefix+"_CODFON")))
            ::filext        := AllTrim(Posicione("DN8",1,xFilial("DN8")+::codfon+cFilAnt,"DN8_FILEXT"))
            ::last_error    := ""
            If cPrefix == "DN1"
                ::cRetSucesso   := DN1->DN1_BEREAL
                ::cRetInsucesso := DN1->DN1_BENREA
            EndIf
            If DN6->(ColumnPos("DN6_TIPAUT"))>0
                ::cTipAut       := Posicione("DN6",1,xFilial("DN6") + ::CodFon,"DN6_TIPAUT")
            Endif
            If AliasInDic("DNM") .And. cPrefix == "DNM"
                If DNM->(ColumnPos("DNM_LOCMAP")) > 0
                    ::LocMap        := AllTrim((cAliasQry)->LOCMAP)
                EndIf
                If DNM->(ColumnPos("DNM_QTVGMP")) > 0
                    ::QtVgMap       := (cAliasQry)->QTVGMP
                EndIf
                If DNM->(ColumnPos("DNM_TIPPLA")) > 0
                    ::cTipPla       := (cAliasQry)->TIPPLA
                EndIf
            Endif
            lRet := .T.

        EndIf
        (cAliasQry)->(DbCloseArea())
        AEval( aAreas, {|aArea| RestArea(aArea) } )

    Else
        ::result_ok := ""
        ::all_error += ( ::last_error := STR0003 ) + CRLF	//-- "Configuração de Token não informada."

    EndIf

Return lRet

/*{Protheus.doc} GetToken()
Busca se Novo Token ativo no colant

@author Carlos A. Gomes Jr.
@since 17/03/22
*/
METHOD GetToken(cClientID,cSecret,cACRval,cUserName,cPass,cUrlToke,lGrava) CLASS TMSBCACOLENT
Local lRet       := .F.
Local cParams    := ""
Local cResult    := ""
Local oResult AS OBJECT
Local oClient AS OBJECT

DEFAULT lGrava    := .T.

    If Empty(cClientID) .Or. Empty(cSecret) .Or. Empty(cACRval) .Or. Empty(cUserName) .Or. Empty(cPass) .Or. Empty(cUrlToke) .Or. (Self:Alias_Config == "DNM" .And. Empty(Self:cTipAut))
        If ::DbGetToken()
            DEFAULT cClientID := Iif(::cTipAut == "1",DNM->DNM_USER,::client_id)
            DEFAULT cSecret   := Iif(::cTipAut == "1",DNM->DNM_URLTOK,::client_secret)
            DEFAULT cACRval   := Iif(::cTipAut == "1",DNM->DNM_URLTOK,::acr_values)
            DEFAULT cUserName := ::username
            DEFAULT cPass     := ::password
            DEFAULT cUrlToke  := ::url_token

        EndIf
    EndIf

    If !Empty(cClientID) .And. !Empty(cSecret) .And. !Empty(cACRval) .And. !Empty(cUserName) .And. !Empty(cPass) .And. !Empty(cUrlToke)
        If ::cTipAut == "1"
			aheaders := HereToken(AllTrim(DNM->DNM_URLTOK),AllTrim(DNM->DNM_USER),AllTrim(DNM->DNM_PASSW))
			cParams  := "grant_type=client_credentials"
        Else
	        cParams := "grant_type=password"
	        cParams += "&client_id=" + cClientID
	        cParams += "&client_secret=" + cSecret
	        cParams += "&acr_values=" + cACRval
	        cParams += "&scope=authorization_api"
	        cParams += "&username=" + cUserName
	        cParams += "&password=" + cPass
	        aheaders := {"Content-Type: application/x-www-form-urlencoded"}
    	EndIf
    	
        oClient := FwRest():New(cUrlToke)
        oClient:SetPath("token")
        oClient:SetPostParams( EncodeUTF8(cParams) )
        ::data_token := dDataBase
        ::time_token := Time()
        lRet := oClient:Post(aheaders) // header

        If lRet
            cResult := oClient:GetResult()
            If FWJsonDeserialize(cResult,@oResult)
                If AttIsMemberOf(oResult,"access_token")
                    ::access_token := oResult:access_token
                    If AttIsMemberOf(oResult,"expires_in")
                        ::time_expire := oResult:expires_in
                        If lGrava
                            DbGrvToken(Self)
                        EndIf
                    EndIf
                    lRet := .T.
                    ::last_error := ""
                EndIf 
            EndIf

        Else
            ::result_ok := ""
            ::all_error += ( ::last_error := AllTrim( oClient:GetLastError() ) ) + CRLF
            cResult := oClient:GetResult()
            If FWJsonDeserialize(cResult,@oResult)
                If AttIsMemberOf(oResult,"error")
                    ::desc_error += oResult:error + CRLF
                EndIf
                If AttIsMemberOf(oResult,"error_description")
                    ::desc_error += oResult:error_description
                EndIf
            EndIf

        EndIf
    Else
        ::result_ok := ""
        ::all_error += ( ::last_error := STR0011 ) + CRLF
    EndIf

    FWFreeObj(oClient)
    FWFreeObj(oResult)

Return { lRet, Iif(lRet,::access_token,"") }

/*{Protheus.doc} DbGrvToken()
Atualiza Token

@author Carlos A. Gomes Jr.
@since 17/03/22
*/
Static Function DbGrvToken(oSelf)
Local aAreas := { GetArea(oSelf:Alias_Config), GetArea() }

    DbSelectArea(oSelf:Alias_Config)
    DbGoTo(oSelf:config_recno)
    RecLock(oSelf:Alias_Config,.F.)
    FieldPut( FieldPos( oSelf:Alias_Config+"_TOKEN"  ), oSelf:access_token )
    FieldPut( FieldPos( oSelf:Alias_Config+"_DTTOKE" ), oSelf:data_token )
    FieldPut( FieldPos( oSelf:Alias_Config+"_HRTOKE" ), oSelf:time_token )
    FieldPut( FieldPos( oSelf:Alias_Config+"_EXPIRE" ), oSelf:time_expire  )
    MsUnLock()
    AEval( aAreas, { |aArea| RestArea(aArea) } )

Return

/*{Protheus.doc} GetActiveToken()
Busca o token atual e se expirado busca o novo.

@author Carlos A. Gomes Jr.
@since 17/03/22
*/
METHOD GetActiveToken() CLASS TMSBCACOLENT
Local lRet := .F.

    If ! ( lRet := ::IsTokenActive() )
        lRet := ::GetToken()[1]
    EndIf

Return { lRet, Iif(lRet,::access_token,"") }

/*{Protheus.doc} Post()
Efetua o post no sistema externo
@author     Carlos A. Gomes Jr.
@since      22/03/2022
*/
METHOD Post(cApiRun,cBody,cChangeURL,cProcesso) CLASS TMSBCACOLENT
    Local lRet     := .F.
    Local aHeader  := {}
    Local cResErro := ""
    Local nPosCpo  := 0
    Local cTempID  := ""
    Local xTmpBody := ""
    Local cApiRun2 := ""
    Local oClient As object
    Local aStrApi  := {}
    Local oHere   As object
    Local cHttpCode := ""

    DEFAULT cApiRun    := "" // Exemplo "core/api/v1/localidades"
    DEFAULT cBody      := ""
    DEFAULT cChangeURL := ""
    DEFAULT cProcesso  := ""

    If ::GetActiveToken()[1]
        If lTMC30Pst
            xTmpBody := ExecBlock("TMC30PST",.F.,.F.,{cApiRun,cBody,cChangeURL,"POST"})
            If ValType(xTmpBody) == "C"
                cBody := xTmpBody
            ElseIf ValType(xTmpBody) == "A" .And. Len(xTmpBody) == 3
                cApiRun    := xTmpBody[1]
                cBody      := xTmpBody[2]
                cChangeURL := xTmpBody[3]
            EndIf
        EndIf
		If Empty(cChangeURL)
	        oClient	:= FwRest():New( ::url_app )
		Else
			oClient	:= FwRest():New( cChangeURL )
		EndIf
        oClient:SetPath( cApiRun )
        oClient:SetPostParams(EncodeUTF8(cBody))

   		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + ::access_token)

		If ::Alias_Config == "DNM"
			::cTipPla := TMSGetVar("cTipoPlan")
		EndIf

        If oClient:Post(aHeader) .Or. (::Alias_Config == "DNM" .And. ::cTipPla == "2" .And. "202" $ oClient:GetLastError())
            ::result_ok := oClient:GetResult()
            If Empty(::result_ok) .And. AttIsMemberOf( oClient, "oResponseH" ) .And. AttIsMemberOf( oClient:oResponseH, "aHeaderFields" )
                For nPosCpo := 1 To Len(oClient:oResponseH:aHeaderFields)
                    If oClient:oResponseH:aHeaderFields[nPosCpo][1] == "Location"
                        If "agendamento" $ ::url_app
                            cApiRun2 := StrTran( cApiRun, "core","agendamento/query")   // Ajusto a api de core para query devido retorno "errado?" do agendamento
                        EndIf
                        cTempID := oClient:oResponseH:aHeaderFields[nPosCpo][2] //Location = URL redirecionamento para pagina de resultado da inclusão
                        cTempID := StrTran(cTempID,Chr(13),"")      //Remove Chr(13) do fim da linha
                        cTempID := StrTran(cTempID,::url_app,"")    //Remove inicio da URL do aplicativo
                        cTempID := StrTran(cTempID,cApiRun,"")      //Remove o EndePoint da URL
                        cTempID := StrTran(cTempID,cApiRun2,"")     //Remove retorno 
                        aStrApi := StrTokArr( cApiRun, "/" )        //Devido a variação de formato de endereço separa cada trecho da API pra remover na linha abaixo
                        AEval( aStrApi, { |x| cTempID := StrTran( cTempID, x, "" ) } ) //Remove os trechos da API caso não removida inteira
                        cTempID := AllTrim(StrTran(cTempID,"/","")) //Remove a barra invertida se não tiver retirado no EndPoint
                        cTempID := StrTran(cTempID,"portallogistico","")//Remove a nomenclatura do portallogistico
                        cTempID := StrTran(cTempID,'"',"")          // Remove aspas duplas que no retorno de alguns endpoint estavam sendo enviados sem necessidade
                        ::result_ok := cTempID                      //O que sobra é o ID
                        Exit
                    EndIf
                Next
            EndIf
            If "agendamento" $ ::url_app .OR. "yms" $ ::url_app
                ::result_ok := StrTran( ::result_ok, '"', "" )          // Remove aspas duplas que no retorno de alguns endpoint estavam sendo enviados sem necessidade
                ::result_ok := StrTran( ::result_ok, '{', "" )
                ::result_ok := StrTran( ::result_ok, '}', "" )
                ::result_ok := StrTran( ::result_ok, 'id:', "" )
            EndIf
			If !Empty(::result_ok)
				If ::Alias_Config == "DNM"
					If ::cTipPla == "2" .And. "202" $ oClient:GetLastError()
                        oHere := JsonObject():New()
                        oHere:FromJson(::result_ok)
                        If oHere:hasProperty("statusId")
                            ::result_ok := oHere["statusId"]
							TMSAF94Atu(SubStr(cProcesso,8,TamSx3("DNP_CODIGO")[1]),"1")
                        EndIf
					Else
			            If FindFunction("AtuPlaHere")  //-- Atualização do planejamento vindo da Here
							AtuPlaHere(::result_ok,cProcesso,::Alias_Config)
                            ::result_ok := ""
						EndIf
					EndIf
				EndIf
			EndIf

            ::last_error := ""
            lRet := .T.
            
        ElseIf ::cCod_Fon == "12" .And. HTTPGetStatus(@cHttpCode) == 201
            ::result_ok := "201-Created. UUID uninformed."
            lRet := .T.

        Else
            ::result_ok  := ""
            ::all_error  += ( ::last_error := oClient:GetLastError() )
            ::desc_error := STR0015 //-- "Erro sem descrição."
            cResErro := oClient:GetResult()
            If !Empty(cResErro)
                ::desc_error := DeCodeUTF8(cResErro)
            EndIf

        EndIf

    EndIf
    
    FWFreeObj(oClient)

Return { lRet, ::result_ok }

/*{Protheus.doc} Put()
Efetua o put no sistema externo
@author     Carlos A. Gomes Jr.
@since      11/06/2025
*/
METHOD Put(cApiRun,cBody) CLASS TMSBCACOLENT
    Local lRet     := .F.
    Local aHeader  := {}
    Local cResErro := ""
    Local xTmpBody := ""
    Local oClient AS OBJECT

    DEFAULT cApiRun    := "" // Exemplo "core/api/v1/localidades"
    DEFAULT cBody      := ""
    DEFAULT cChangeURL := ""
    
    If ::GetActiveToken()[1]
        If lTMC30Pst
            xTmpBody := ExecBlock("TMC30PST",.F.,.F.,{cApiRun,cBody,"","PUT"})
            If ValType(xTmpBody) == "C"
                cBody := xTmpBody
            ElseIf ValType(xTmpBody) == "A" .And. Len(xTmpBody) == 3
                cApiRun    := xTmpBody[1]
                cBody      := xTmpBody[2]
            EndIf
        EndIf
        oClient	:= FwRest():New( ::url_app )
        oClient:SetPath( cApiRun )

   		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + ::access_token)

        If oClient:Put(aHeader,EncodeUTF8(cBody))
            ::result_ok := oClient:GetResult()
            ::last_error := ""
            lRet := .T.

        Else
            ::result_ok  := ""
            ::all_error  += ( ::last_error := oClient:GetLastError() )
            ::desc_error := STR0015 //-- "Erro sem descrição."
            cResErro := oClient:GetResult()
            If !Empty(cResErro)
                ::desc_error := DeCodeUTF8(cResErro)
            EndIf

        EndIf

    EndIf
    
    FWFreeObj(oClient)

Return { lRet, ::result_ok }

/*{Protheus.doc} Get()
Busca dados em API

@author     Carlos A. Gomes Jr.
@since      23/03/2022
*/
METHOD Get(cApiRun,cQueryParam,cChangeURL,cProces,cSubPrc) CLASS TMSBCACOLENT
Local lRet     := .F.
Local aHeader  := {}
Local cResErro := ""
Local oClient AS OBJECT

DEFAULT cApiRun     := "" // Exemplo "query/api/v1/localidades"
DEFAULT cQueryParam := ""
DEFAULT cChangeURL  := ""
DEFAULT cProces     := ""
DEFAULT cSubPrc     := ""

    If ::GetActiveToken()[1]
        If lTMC30Pst
            xTmpBody := ExecBlock("TMC30PST",.F.,.F.,{cApiRun,"",cChangeURL,"GET"})
            If ValType(xTmpBody) == "A" .And. Len(xTmpBody) == 3
                cApiRun    := xTmpBody[1]
                cChangeURL := xTmpBody[3]
            EndIf
        EndIf

        If Empty(cChangeURL)
            oClient	:= FwRest():New( ::url_app )
        Else
            oClient	:= FwRest():New( cChangeURL )
        EndIf

        oClient:SetPath( cApiRun + EncodeUTF8(cQueryParam) )

   		Aadd(aHeader, 'Content-Type: application/json')
        Aadd(aHeader, 'Authorization: Bearer ' + ::access_token)

        If oClient:Get(aHeader)
            ::last_error := ""
            ::result_ok  := DecodeUtf8(oClient:GetResult())
            If lTMC30RGT
                ExecBlock("TMC30RGT",.F.,.F.,{::result_ok})
            EndIf
            If ::Alias_Config == "DNM"
                If FindFunction("AtuSeqHere")
                	If cSubPrc == "0001"   //-- Atualização da ordenação da programação pela Here
	    				AtuSeqHere(::result_ok,"DF8")
	    			ElseIf cSubPrc == "0004"	//-- Atualização da ordenação da viagem pela Here
	    				AtuSeqHere(::result_ok,"DTQ")
					EndIf
		        EndIf
            EndIf
            lRet := .T.

        Else
            ::result_ok  := ""
            ::all_error  += ( ::last_error := oClient:GetLastError() )
            ::desc_error := STR0015 //-- "Erro sem descrição."
            cResErro := oClient:GetResult()
            If !Empty(cResErro)
                ::desc_error := DeCodeUTF8(cResErro)
            EndIf

        EndIf
    EndIf

    FWFreeObj(oClient)

Return { lRet, ::result_ok }

/*{Protheus.doc} Delete()
Executa API de Exclusão com método DELETE
@author     Carlos A. Gomes Jr.
@since      16/06/2025
*/
METHOD Delete(cApiRun,cBody) CLASS TMSBCACOLENT
    Local lRet     := .F.
    Local aHeader  := {}
    Local cResErro := ""
    Local xTmpBody := ""
    Local oClient AS OBJECT

    DEFAULT cApiRun    := "" // Exemplo "core/api/v1/localidades"
    DEFAULT cBody      := ""
    DEFAULT cChangeURL := ""
    
    If ::GetActiveToken()[1]
        If lTMC30Pst
            xTmpBody := ExecBlock("TMC30PST",.F.,.F.,{cApiRun,cBody,"","DELETE"})
            If ValType(xTmpBody) == "C"
                cBody := xTmpBody
            ElseIf ValType(xTmpBody) == "A" .And. Len(xTmpBody) == 3
                cApiRun    := xTmpBody[1]
                cBody      := xTmpBody[2]
            EndIf
        EndIf
        oClient	:= FwRest():New( ::url_app )
        oClient:SetPath( cApiRun )

   		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + ::access_token)

        If oClient:Delete(aHeader,EncodeUTF8(cBody))
            ::result_ok := oClient:GetResult()
            ::last_error := ""
            lRet := .T.
        Else
            ::result_ok  := ""
            ::all_error  += ( ::last_error := oClient:GetLastError() )
            ::desc_error := STR0015 //-- "Erro sem descrição."
            cResErro := oClient:GetResult()
            If !Empty(cResErro)
                ::desc_error := DeCodeUTF8(cResErro)
            EndIf
        EndIf
    EndIf
    FWFreeObj(oClient)

Return { lRet, ::result_ok }

/*{Protheus.doc} TMSAC30Cli()
Busca pelo cliente e Endereço 

Retrona IDExterno do cliente ou do endereço conforme parâmetro informado
@author     Carlos A. Gomes Jr.
@since      29/03/2022
*/
Function TMSAC30Cli( oColEnt, aLayout, aCliDados, lExecAlt )
    Local aResGet    := {}
    Local cRetId     := ""
    Local lHasNext   := .T.
    Local nPage      := 1
    Local nPosCod    := 0
    Local cComplemen := ""
    Local nPosComp   := 0
    Local nPosNum    := 0
    Local nPosTel    := 0
    Local nPosIdLoc  := 0
    Local aCompDados := 0

    Local oResult AS Object

    Local aItems     := {}
    Local aEnderecos := {}
    Local aLocais    := {}
    Local nCntFor1   := 0
    Local nCntFor2   := 0
    Local cIdLocal   := ""
    Local cNumero    := ""
    Local cTelefone  := ""

    DEFAULT lExecAlt := .T.

    If (nPosCod := AScan(aLayout,{|x| AllTrim(x[3]) == "CODIGO" }) ) > 0
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/clientes","?documentoIdentificacaoIgual=" + AllTrim(aCliDados[nPosCod]) + "&page=" + AllTrim(Str(nPage)) ) )[1]
                oResult := JsonObject():New()
                oResult:FromJson(aResGet[2])
                
                If ValType(oResult["hasNext"]) == "L"
                    lHasNext := oResult["hasNext"]
                    nPage ++
                EndIf
               
                If ValType(oResult["items"]) == "A"
                    aItems := oResult["items"]
                    cRetId := ""

                    For nCntFor1 := 1 To Len(aItems)
                        If Empty(cRetId)
                            //No vetor :itens estamos tratando apenas a posição 1 pois a Regra do Portal é que
                            //não deve existir mais de um cliente com o mesmo documento de identificação
                            cRetId := aItems[nCntFor1,"id"]
                        EndIf
                        If ValType(aItems[nCntFor1,"enderecos"]) == "A"
                            aEnderecos := aItems[nCntFor1,"enderecos"]

                            If (nPosComp  := AScan(aLayout,{|x| AllTrim(x[3]) == "COMPLEMENT"})) > 0 .And. ;
                               (nPosNum   := AScan(aLayout,{|x| AllTrim(x[3]) == "NUMERO"}))     > 0 .And. ;
                               (nPosTel   := AScan(aLayout,{|x| AllTrim(x[3]) == "FONE"}))       > 0 .And. ;
                               (nPosIDLoc := AScan(aLayout,{|x| AllTrim(x[3]) == "IDLOCAL"}))    > 0
                                cComplemen := ""
                                aLocais := {}

                                For nCntFor2 := 1 To Len(aEnderecos)
                                    If ValType(aEnderecos[nCntFor2,"complemento"]) == "C"
                                        cComplemen := aEnderecos[nCntFor2,"complemento"]
                                    EndIf

                                    If ValType(aEnderecos[nCntFor2,"numero"]) == "C"
                                        cNumero := aEnderecos[nCntFor2,"numero"]
                                    EndIf

                                    If ValType(aEnderecos[nCntFor2,"telefone"]) == "C"
                                        cTelefone := aEnderecos[nCntFor2,"telefone"]
                                    EndIf

                                    If ValType(aEnderecos[nCntFor2,"localidade"]) == "J"
                                        aLocais  := aEnderecos[nCntFor2,"localidade"]
                                        cIdLocal := aLocais["id"]
                                    EndIf

                                    If AllTrim(aCliDados[nPosIDLoc]) == cIdLocal .And. ;
                                       AllTrim(aCliDados[nPosNum])   == cNumero .And. ;
                                       AllTrim(aCliDados[nPosTel])   == cTelefone .And. ;
                                       AllTrim(aCliDados[nPosComp])  == cComplemen
                                        lExecAlt  := .F.
                                        Exit
                                    EndIf
                                Next
                                If !lExecAlt
                                    Exit
                                EndIf
                            Else
                                TMSAC30Err( "TMSAC30026", STR0012 , STR0013 )
                            EndIf
                        EndIf
                    Next nCntFor1
                EndIf
            Else
                TMSAC30Err( "TMSAC30004", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
    Else
        TMSAC30Err( "TMSAC30024", STR0012 , STR0013 )
    EndIf

    FwFreeArray(aCompDados)
    FwFreeArray(aResGet)
    FWFreeObj(oResult)

Return cRetId

/*{Protheus.doc} TMSAC30GDC()
Busca pelo Documento

@author     Carlos A. Gomes Jr.
@since      30/03/2022
*/
Function TMSAC30GDC( oColEnt, aLayout, aDocDados, lExecAlt )
Local cRetId   := ""
Local aResGet  := {}
Local nItem    := 0
Local nPosKey  := 0
Local lHasNext := .T.
Local nPage    := 1
Local oResult As Object

DEFAULT lExecAlt := .F.

    If (nPosKey := AScan(aLayout,{|x| AllTrim(x[3]) == "CHAVEDOC" }) ) > 0
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/coletasEntregas", "?externalId="+FWURLEncode(RTrim(aDocDados[nPosKey])) + "&situacaoDiferenteDe=EXCLUIDA" + "&page=" + AllTrim(Str(nPage)) ) )[1]
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If AttIsMemberOf( oResult, "hasNext" )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nItem := 1 To Len( oResult:items )
                            If !Empty(oResult:items[nItem]:externalId) .And. oResult:items[nItem]:externalId == RTrim(aDocDados[nPosKey]) .And. oResult:items[nItem]:situacao != "EXCLUIDA"
                                lExecAlt := oResult:items[nItem]:situacao == "FINALIZADA_COM_INSUCESSO"
                                cRetId   := oResult:items[nItem]:id
                                lHasNext := .F.
                                Exit
                            EndIf
                        Next
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30008", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
    Else
        TMSAC30Err( "TMSAC30024", STR0012 , STR0014 )
    EndIf

    FWFreeObj(oResult)
    FwFreeArray(aResGet)

Return cRetId

/*{Protheus.doc} TMSAC30GDV()
Busca Documentos de uma Viagem ou Apenas o Status da Viagem

@author     Carlos A. Gomes Jr.
@since      06/04/2022
*/
Function TMSAC30GDV(cIDVia,cDocInVia,lTarefas,cAlias)
    Local aDocVia   := {.F.,{}}
    Local aResGet   := {}
    Local nItem     := 0
    Local nPage     := 1
    Local lHasNext  := .T.
    Local aDocTemp  := {}
    Local aDocsOrd  := {}
    Local oColEnt As Object
    Local oResult As Object

    Local oHere      As Object
    Local oObjResult As Object

    DEFAULT cDocInVia := ""
    DEFAULT lTarefas  := .T.
    DEFAULT cAlias    := "DN1"

    If cAlias == "DN1"
        oColEnt := TMSBCACOLENT():New("DN1")
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/viagens", "/" + AllTrim(cIDVia) + If( lTarefas, "/tarefas", "") + "?page=" + AllTrim( Str(nPage) ) ) )[1]
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If lTarefas
                        If AttIsMemberOf( oResult, "hasNext" )
                            lHasNext := oResult:hasNext
                            nPage++
                        EndIf
                        If AttIsMemberOf( oResult, "items" )
                            For nItem := 1 To Len( oResult:items )
                                If !Empty(oResult:items[nItem]:coletaEntregaId)
                                    aDocTemp := {}
                                    AAdd( aDocTemp, oResult:items[nItem]:coletaEntregaId )            //01
                                    AAdd( aDocTemp, oResult:items[nItem]:tipo )                       //02
                                    AAdd( aDocTemp, oResult:items[nItem]:externalId )                 //03
                                    AAdd( aDocTemp, oResult:items[nItem]:situacao )                   //04
                                    AAdd( aDocTemp, oResult:items[nItem]:sequencia )                  //05
                                    AAdd( aDocTemp, {} )                                              //06
                                    AAdd( aDocTemp, Iif(oResult:items[nItem]:situacaoDocumentacaoTarefa != Nil,oResult:items[nItem]:situacaoDocumentacaoTarefa,"") ) //07
                                    AAdd( aDocsOrd, aDocTemp )
                                    If Empty(cDocInVia) .Or. oResult:items[nItem]:coletaEntregaId == cDocInVia
                                        aDocVia[1] := .T.
                                    EndIf
                                EndIf
                            Next 
                            If !Empty(aDocsOrd)
                                ASort( aDocsOrd, ,, {|x,y| x[5] < y[5] } )
                            EndIf
                            aDocVia[2] := AClone(aDocsOrd)
                        EndIf
                    Else
                        If AttIsMemberOf( oResult, "situacao" )
                            aDocVia[1] := .T.
                            aDocVia[2] := oResult:situacao
                        EndIf
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30011", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
        FWFreeObj(oColEnt)
	ElseIf cAlias == "DNM"
		If FWAliasInDic("DNM",.F.)
        	oHere := TMSBCACOLENT():New("DNM")
        	If (aResGet := oHere:Get("tourplanning.hereapi.com/v3/status","/" + cIDVia))[1]	//-- Busca status
            	oObjResult := JSonObject():New()
            	oObjResult:FromJSon(aResGet[2])
            	If ValType(oObjResult["status"]) == "C" .And. oObjResult["status"] == "success"
                	If (aResGet := oHere:Get("tourplanning.hereapi.com/v3/problems","/" + cIDVia + "/solution"))[1]	//-- Busca planejamento
                    	aDocVia[1] := .T.
                    	aDocVia[2] := aResGet[2]
                	EndIf
            	EndIf
        	EndIf
    	EndIf
	EndIf

Return aDocVia

/*{Protheus.doc} TMSAC30ExV()
Exclui a Viagem

@author     Carlos A. Gomes Jr.
@since      06/04/2022
*/
Function TMSAC30ExV(cIDVia)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    If !( lRet := oColEnt:Post( "coletaentrega/core/api/v1/viagens/"+AllTrim(cIDVia)+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMSAC30ExA()
Exclui a Viagem e os Documentos que nela estavam.

@author     Carlos A. Gomes Jr.
@since      07/04/2022
*/
Function TMSAC30ExA(cIDVia)
Local lRet     := .F.
Local aDocsVia := {}

    aDocsVia := TMSAC30GDV(cIDVia)
    If ( nDocs := AScan(aDocsVia[2],{|aDoc| aDoc[4] != "CRIADA" .And. aDoc[4] != "AGUARDANDO_INICIO" }) ) > 0
        TMSAC30Err( "TMSAC30015", STR0006 + aDocsVia[2][nDocs][3] + STR0007, STR0008 )
    Else
        lRet := TMSAC30ExV(cIDVia)
/*
        If TMSAC30ExV(cIDVia)
            lRet := .T.
            For nDocs := 1 To Len(aDocsVia[2])
                If !TMSAC30ExD(aDocsVia[2][nDocs][1],aDocsVia[2][nDocs][2])
                    lRet := .F.
                    Exit
                EndIf
            Next
        EndIf
*/
    EndIf

Return lRet

/*{Protheus.doc} TMSAC30GEv()
Busca Evidencias do  Documento

@author     Carlos A. Gomes Jr.
@since      28/04/2022
*/
Function TMSAC30GEv(cDocId)
    Local aEvidencia := {.F.,{}}
    Local aResGet    := {}
    Local nItem      := 0
    Local aDTTarefa  := SToD("")
    Local cUltData   := ""
    Local oResult As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/coletasEntregas","/"+cDocId+"/evidencias" ) )[1]
        If FWJsonDeserialize( aResGet[2], @oResult )
            If AttIsMemberOf( oResult, "items" ) .And. Len( oResult:items ) > 0
                For nItem := 1 To Len( oResult:items )
                    aEvidencia[1] := .T.
                    aDTTarefa := UTCToLocal( StrTran(Left(oResult:items[nItem]:dataSituacao,10),"-",""), Substr(oResult:items[nItem]:dataSituacao,12,8) )
                    If Empty(cUltData) .Or. cUltData < aDTTarefa[1] + aDTTarefa[2]
                        cUltData := aDTTarefa[1] + aDTTarefa[2]
                        aEvidencia[2] := { StoD(aDTTarefa[1]), StrTran(Left(aDTTarefa[2],5),":","") } //01 e 02
                        If AttIsMemberOf( oResult:items[nItem], "fotos" )
                            If ValType(oResult:items[nItem]:fotos) != "A"
                                AAdd(aEvidencia[2], { oResult:items[nItem]:fotos } ) //03
                            ElseIf Len(oResult:items[nItem]:fotos) >= 1
                                AAdd(aEvidencia[2], aClone(oResult:items[nItem]:fotos) ) //03
                            Else
                                AAdd(aEvidencia[2], {""} ) //03
                            EndIf
                        Else
                            AAdd(aEvidencia[2], {""} ) //03
                        EndIf
                        If AttIsMemberOf( oResult:items[nItem], "recebedor" ) .And. oResult:items[nItem]:recebedor != Nil
                            If AttIsMemberOf( oResult:items[nItem]:recebedor, "nome" ) .And. oResult:items[nItem]:recebedor:nome != Nil
                                AAdd(aEvidencia[2], oResult:items[nItem]:recebedor:nome ) //04
                            Else
                                AAdd(aEvidencia[2], "" ) //04
                            EndIf
                            If AttIsMemberOf( oResult:items[nItem]:recebedor, "documento" ) .And. oResult:items[nItem]:recebedor:documento != Nil
                                AAdd(aEvidencia[2], oResult:items[nItem]:recebedor:documento ) //05
                            Else
                                AAdd(aEvidencia[2], "" ) //05
                            EndIf
                        Else
                            AAdd(aEvidencia[2], "" ) //04
                            AAdd(aEvidencia[2], "" ) //05
                        EndIf
                        AAdd(aEvidencia[2], oResult:items[nItem]:situacao ) //06
                        AAdd(aEvidencia[2], oResult:items[nItem]:motivo ) //07
                        AAdd(aEvidencia[2], oResult:items[nItem]:relato ) //08
                        If !Empty(oResult:items[nItem]:localizacao:latitude)
                            AAdd(aEvidencia[2], cValToChar(oResult:items[nItem]:localizacao:latitude) ) //09
                        Else
                            AAdd(aEvidencia[2], "-23.5085783" ) //09 TOTVS SP
                        EndIf
                        If !Empty(oResult:items[nItem]:localizacao:longitude)
                            AAdd(aEvidencia[2], cValToChar(oResult:items[nItem]:localizacao:longitude) ) //10
                        Else
                            AAdd(aEvidencia[2], "-46.6518496" ) //10 TOTVS SP
                        EndIf
                        If AttIsMemberOf( oResult:items[nItem], "situacaoDocumentacaoTarefa" ) .And. oResult:items[nItem]:situacaoDocumentacaoTarefa != Nil
                            AAdd(aEvidencia[2], oResult:items[nItem]:situacaoDocumentacaoTarefa ) //11
                        Else
                            AAdd(aEvidencia[2], "PENDENTE_ANALISE" ) //11
                        EndIf
                    EndIf
                Next
            Else
                TMSAC30Err( "TMSAC30022", STR0017, STR0018 + " coletaentrega/query/api/v1/coletasEntregas/"+cDocId+"/evidencias" + CRLF + aResGet[2] )
            EndIf
        EndIf
    Else
        TMSAC30Err( "TMSAC30020", oColEnt:last_error, oColEnt:desc_error )
    EndIf

    FWFreeObj(oResult)

Return aEvidencia

/*{Protheus.doc} TMSAC30Img()
Busca Imagem da Evidencia no Storage do Rac

@author     Carlos A. Gomes Jr.
@since      28/04/2022
*/
Function TMSAC30Img(aIdImg)
Local aDadosEvid := {.F., Array(5) }
Local aResGet    := {}
Local nImg       := 0
Local oResult As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    For nImg := 1 To Len(aIdImg)
        If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/arquivos", "/" + aIdImg[nImg] ) )[1]
            If FWJsonDeserialize( aResGet[2], @oResult ) .And. ( Empty(aDadosEvid[2][3]) .Or. aDadosEvid[2][3] > AllTrim(oResult:nome) )
                aDadosEvid[2][1] := AllTrim(oResult:id)                                            //01 - Id da Imagem
                aDadosEvid[2][2] := AllTrim(oResult:url)                                           //02 - Url da Imagem
                aDadosEvid[2][3] := AllTrim(oResult:nome)                                          //03 - Nome da Imagem
                aDadosEvid[2][4] := AllTrim(Substr(oResult:nome,At(".", AllTrim(oResult:nome))))   //04 - Tipo da Imagem
                aDadosEvid[2][5] := HttpGet(AllTrim(oResult:url))                                  //05 - Imagem
                aDadosEvid[1]    := .T.
            EndIf
        EndIf
    Next
    FWFreeObj(oResult)

Return aDadosEvid

/*{Protheus.doc} TMSAC30Err()
Registra / Apresenta Erro de Integração

@author     Carlos A. Gomes Jr.
@since      16/05/2022
*/
Static cLogErro := ""
Function TMSAC30Err( cFuncao, cMensagem, cDetalhe, lJson )
Local cMsgTrat := ""
Local nDetErr  := 0
Local oErro As Object

DEFAULT cFuncao   := ""
DEFAULT cMensagem := ""
DEFAULT cDetalhe  := ""
DEFAULT lJson     := .T.

    cMsgTrat := cDetalhe
    If lJson
        If FWJsonDeserialize( cDetalhe, @oErro )
            If AttIsMemberOf( oErro, "message" )
                cMsgTrat := oErro:message + CRLF
            EndIf
            If AttIsMemberOf( oErro, "detailedMessage" )
                cMsgTrat += oErro:detailedMessage
            EndIf
            If AttIsMemberOf( oErro, "details" )
                For nDetErr := 1 To Len(oErro:details)
                    cMsgTrat += CRLF
                    cMsgTrat += "* "+oErro:details[nDetErr]:message + CRLF
                    cMsgTrat += " -"+oErro:details[nDetErr]:detailedMessage
                Next
            EndIf
        EndIf
    EndIf

    cLogErro += DtoC(dDataBase) + "-" + Time() + CRLF
    cLogErro += cFuncao + " - " + cMensagem + CRLF
    cLogErro += cMsgTrat + CRLF + CRLF

    If !IsBlind() .And. !FwIsInCallStack("PrcDemoHe")
        If "I86002" $ cFuncao .And. "COORDINAT" $ Upper(cMsgTrat) .And. "NULL" $ Upper(cMsgTrat) //-- Erro de retorno em coordenadas endereço não encontrado Here
            cLogErro := STR0019 + CRLF + cLogErro //"Verificar endereço da viagem desta sequência"
        Else
            Help(" ", , cFuncao + "-" + cMensagem, , cMsgTrat, 2, 1)
        EndIf
    EndIf
    
    FWFreeObj(oErro)

Return

/*{Protheus.doc} TMSAC30GEr()
Retorna Erros de Integração e Limpa o Buffer de Erro

@author     Carlos A. Gomes Jr.
@since      16/05/2022
*/
Function TMSAC30GEr
Local cErro := cLogErro
    cLogErro := ""
Return cErro

/*{Protheus.doc} TMSAC30PEr()
Adiciona mensagens no Buffer de Erros de Integração.
@author     Carlos A. Gomes Jr.
@since      16/05/2022
*/
Function TMSAC30PEr(cMensagem)
Default cMensagem := ""
    cLogErro += cMensagem
Return

/*{Protheus.doc} TMSAC30VIA()
Busca Status da Viagem para Inserir documento em andamento
@author     Carlos Alberto Gomes Jr.
@since      19/08/2022
*/
Function TMSAC30VIA( oColEnt, aLayout, aViaDados, lExecAlt )
Local cRetIdVia := ""
Local nPosKey   := 0

    If (nPosKey := AScan(aLayout,{|x| AllTrim(x[3]) == "IDVIAGEM" }) ) > 0 .And. !Empty(aViaDados[nPosKey])
        If ( aViagem := TMSAC30GDV(aViaDados[nPosKey],,.F.) )[1]
            If aViagem[2] == "DESPACHO_CONFIRMADO"
                lExecAlt  := .T.
                cRetIdVia := AllTrim(aViaDados[nPosKey])
            Else
                lExecAlt := .F.
            EndIf
        EndIf
    EndIf

Return cRetIdVia
/*{Protheus.doc} TMC30CanCol()
Cancela Documento Coleta no Portal Logístico 
@author     Carlos A. Gomes Jr.
@Changed    Rafael Souza
@since      14/09/2022
*/
Function TMC30CanCol(cIdExt)
Local lRet      := .F.
Local cJson     := '{"statusDocumento": "CANCELADA"}'
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object
    
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosColeta/"+cIdExt+"/alterarStatusDocumento", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TM30StsDoc()
Atualiza Status Operacional no Portal Logístico 
@author     Carlos A. Gomes Jr.
@Changed    Rafael Souza
@since      15/09/2022
*/
Function TM30StsDoc(cIdExt, cStatus)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

Default cIdExt  := ""
Default cStatus := ""
    
    If cStatus == '1' //- Coleta em aberto
        cJson := '{"statusOperacional": "NAO_INICIADA"}'
    ElseIf cStatus == '3' //-- Coleta em trânsito
        cJson := '{"statusOperacional": "EM_EXECUCAO"}'
    ElseIf cStatus == '4' // Coleta encerrada
        cJson := '{"statusOperacional": "COLETA_FINALIZADA"}'
    EndIf    
    
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosColeta/"+cIdExt+"/alterarStatusOperacional", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMC30ExFat()
Exclui Fatura no Portal Logístico
API responsável por deletar um documento financeiro. 
@Changed    Rafael Souza
@since      03/10/2022
*/
Function TMC30ExFat(cIdExt)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object
        
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosFinanceiros/"+cIdExt+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TM30EnStt
Atualiza Status Operacional do Documento de Carga no Portal Logístico
@author     Rodrigo Pirolo
@since      04/10/2022
@version    12.1.27
@return     Logico
@param 
@type       function
*/
//-------------------------------------------------------------------

Function TM30AltStt( aDUDStatus, nEndPoint, cText, cProces )

	Local oColEnt	    := Nil
	Local aToken	    := {}
    Local cCodFonDTC    := ""
	Local nX		    := 0

    Default aDUDStatus  := {}
    Default nEndPoint   := 0
    Default cText       := ""
    Default cProces     := ""
	
    oColEnt  := TMSBCACOLENT():New("DND")

    oColEnt:DbGetToken()
    aToken := oColEnt:GetToken( , , , , , , .T. )

    If aToken[1]
        
        DND->( DbGoTo( oColEnt:config_recno ) )
        DN5->( DbSetOrder(3) )
        
        cCodFonDTC := DND->DND_CODFON

        If !Empty(cProces)
            cProcesDTC := PadR( cProces, Len(DN5->DN5_PROCES) )
            MntQryDn5( cCodFonDTC, nEndPoint, cProcesDTC, cText )
        Else
            For nX := 1 To Len(aDUDStatus)
                
                cProcesDTC := PadR( aDUDStatus[nX][1], Len(DN5->DN5_PROCES) )

                MntQryDn5( cCodFonDTC, nEndPoint, cProcesDTC, cText, aDUDStatus[nX][2] )

            Next nX
        EndIf
    EndIf

    FwFreeArray( aToken )
    FWFreeObj( oColEnt )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} TM30EnStt
Atualiza Status Operacional do Documento de Carga no Portal Logístico
@author     Rodrigo Pirolo
@since      04/10/2022
@version    12.1.27
@return     Logico
@param 
@type       function
*/
//-------------------------------------------------------------------

Static Function MntQryDn5( cCodFonDTC, nEndPoint, cProcesDTC, cText, cStatus )
    
Local cAliasDN5 := ""
Local cQuery    := ""

Default cCodFonDTC  := ""
Default nEndPoint   := 1
Default cProcesDTC  := ""
Default cStatus     := ""

    cAliasDN5 := GetNextAlias()

    cQuery := " SELECT DN5.DN5_CODFON, DN5.DN5_CODREG, DN5.DN5_IDEXT, DN5.R_E_C_N_O_ REGISTRO "
    cQuery += " FROM " + RetSqlName("DN5") + " DN5 "
    cQuery += " WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
    cQuery += 	" AND DN5.DN5_CODFON = '" + cCodFonDTC + "' "

    If nEndPoint <= 3
        cQuery += 	" AND DN5.DN5_CODREG = '1000' "
    Else
        cQuery += 	" AND DN5.DN5_CODREG = '2000' "
    EndIf

    cQuery += 	" AND DN5.DN5_PROCES = '" + cProcesDTC + "' "
    cQuery += 	" AND DN5.DN5_STATUS = '1' "
    cQuery += 	" AND DN5.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAliasDN5, .F., .T. )

    While (cAliasDN5)->(!Eof())

        If !Empty( AllTrim( (cAliasDN5)->(DN5_IDEXT) ) )
            TM30EnvPL( nEndPoint, AllTrim((cAliasDN5)->(DN5_IDEXT)), cStatus, cText )
        EndIf

        (cAliasDN5)->( DbSkip() )

    EndDo

    (cAliasDN5)->( DbCloseArea() )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} TM30EnStt
Atualiza Status Operacional do Documento de Carga no Portal Logístico
@author     Rodrigo Pirolo
@since      04/10/2022
@version    12.1.27
@return     Logico
@param      nEndPoint   - qual endpoint usará
@param      cIdExt      - Id Externo do Portal Logistico
@param      cText       - Texto do 
@type       function
*/
//-------------------------------------------------------------------

Function TM30EnvPL( nEndPoint, cIdExt, cStatus, cText )

    Local lRet      := .F.
    Local cJson     := ""
    Local cEndPoint := ""
    Local nConex    := 0
    Local cHttpCode := ""
    Local oColEnt As Object

    Default nEndPoint   := 0
    Default cIdExt      := ""
    Default cStatus     := ""
    Default cText       := ""

    If nEndPoint == 1
        cEndPoint   := "core/api/v1/documentosCarga/" + cIdExt +"/alterarStatusComprovantePendente"
        cJson       := '{"comprovanteEntregaPendente":"' + cText + '"}'
    ElseIf nEndPoint == 2 .OR. nEndPoint == 5
        If nEndPoint == 2
            cEndPoint   := "core/api/v1/documentosCarga/" + cIdExt +"/informarDataHoraEntrega"
            cJson       := '{"dataHoraEntrega": "' + cText + '"}'
        Else
            cEndPoint   := "core/api/v1/documentosTransporte/" + cIdExt +"/informarDataHoraEntrega"
            cJson       := '{"dataHoraEntrega": "' + cText + '"}'
        EndIf
    ElseIf nEndPoint == 3 .OR. nEndPoint == 4
        
        If nEndPoint == 3
            cEndPoint   := "core/api/v1/documentosCarga/" + cIdExt +"/alterarStatusOperacional"
        Else
            cEndPoint   := "core/api/v1/documentosTransporte/" + cIdExt +"/alterarStatusOperacional"
        EndIf

        If cStatus $ '1/9' //- 1=Em Aberto;9=Cancelado
            cJson := '{"statusOperacional": "NAO_INICIADO"}'
        ElseIf cStatus $ '3' //-- 3=Carregado
            cJson := '{"statusOperacional": "EM_CROSSDOCKING"}'
        ElseIf cStatus $ '2' //-- 2=Em Transito
            cJson := '{"statusOperacional": "EM_TRANSITO"}'
        ElseIf cStatus == '4' // 4=Encerrado
            cJson := '{"statusOperacional": "ENTREGUE"}'
        EndIf
    EndIf
    
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( cEndPoint, cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMC30FtVen()
Altera Status da Fatura no Portal Logístico para vencido.
@Changed    Rafael Souza
@since      02/01/2023
*/
Function TMC30FtVen(cIdExt)
Local lRet      := .F.
Local cJson     := '{"statusDocumento": "VENCIDO"}'
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object
        
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v1/documentosFinanceiros/"+cIdExt+"/alterarStatusDocumento", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMSAC30GDD()
Busca Situação do Documento
@author     Carlos Alberto Gomes Junior
@since      13/01/2023
*/
Function TMSAC30GDD( oColEnt, cIdExt )
Local aSituac  := {.F.,{""}}
Local aResGet  := {}
Local oResult As Object

    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/coletasEntregas/"+cIdExt ) )[1]
        If FWJsonDeserialize( aResGet[2], @oResult )
            aSituac[2][1] := oResult:situacao
            aSituac[1]    := .T.
        EndIf
    Else
        TMSAC30Err( "TMSAC30016", oColEnt:last_error, oColEnt:desc_error )
    EndIf

    FWFreeObj(oResult)
    FwFreeArray(aResGet)

Return aSituac

/*{Protheus.doc} TMSAC30ExN()
Exclui a Nota Fiscal (tarefa entrega)
@author     Carlos Alberto Gomes Junior
@since      06/04/2022
*/
Function TMSAC30ExN(cIDNFiscal)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

    oColEnt := TMSBCACOLENT():New("DN1")
    If !( lRet := oColEnt:Post( "coletaentrega/core/api/v1/entregas/"+cIDNFiscal+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30017", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMC30GHist
Rotina de geração da tabela histórico de integração
@author Carlos Alberto Gomes Junior
@Since 20/01/2023
*/
Function TMC30GHist( cProces, cCodFonStr )

Local lRet     := .F.
Local nPosStru := 1
Local cCodReg  := ""
Local aStruct  := {}
Local aLayout  := {}
Local aAreaReg := {}
Local aAreas   := { DN5->(GetArea()) , GetArea() }
Local cAlias   := ""
Local cIndice  := ""
Local nIndice  := 0
Local cPosDep  := ""
Local oColEnt

DEFAULT cProces    := ""
DEFAULT cCodFonStr := ""

	If !Empty(cProces)
        oColEnt := TMSBCACOLENT():New( "DN1", cCodFonStr )
        If oColEnt:DbGetToken()
            DN1->(DbGoTo(oColEnt:config_recno))
            If Empty(cCodFonStr)
                cCodFonStr := DN1->DN1_CODFON
            EndIf
            //-- Inicializa a estrutura
            aStruct := TMSMntStru( cCodFonStr, .T. )
            TMSSetVar("aStruct",aStruct)
            
            //-- Define o processo
            TMSSetVar("cProcesso",cProces)

            //-- Inicializa o localizador
            TMSSetVar("aLocaliza",{})

            //-- Inicializa Chave da NotaFiscal
            TMSSetVar("aChaveNFC",{})

            For nPosStru := 1 To Len(aStruct)
                Aadd(aAreaReg,(aStruct[nPosStru,3])->(GetArea()))
                //Verifica se não depende de outro registro ou se sim se esse registro ja foi processado
                If Empty(aStruct[nPosStru,6]) .Or. AScan(aStruct,{|x| x[1]+x[2] == aStruct[nPosStru][1]+aStruct[nPosStru][6] .And. x[10] == "2" }) == 0
                    //-- Não é adicional de ninguém e ainda não foi processado
                    If (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nPosStru,1] +  aStruct[nPosStru,2]}) == 0) .And. aStruct[nPosStru,10] == "2"
                        cPosDep := AllTrim(aStruct[nPosStru,7])
                        If !Empty(cPosDep)
                            cAlias  := aStruct[nPosStru,3]
                            cIndice := aStruct[nPosStru,4]
                            nIndice := Val(Iif(Asc(cIndice) < 65,cIndice,AllTrim(Str(Asc(cIndice) - 55))))
                            //-- Seta índice
                            (cAlias)->(DbSetOrder(nIndice))
                        EndIf
                        //-- Posiciona registro
                        If Empty(cPosDep) .Or. (cAlias)->(MsSeek(&(cPosDep)))
                            //Verifica se a condição do registro do layout não foi informada ou foi atendida
                            If Empty(aStruct[nPosStru][9]) .Or. &(aStruct[nPosStru][9])
                                aLayout := BscLayout(aStruct[nPosStru,1],aStruct[nPosStru,2])
                                //Verifica se encontrou o layout
                                If !Empty(aLayout)
                                    //-- Inicia a gravação dos registros e guarda qual o primeiro registro (principal)
                                    If Empty(cCodReg)
                                        cCodReg := aStruct[nPosStru][2]
                                    EndIf
                                    MontaReg( Aclone(aLayout), nPosStru, , ,.T.)
                                    TMSCtrLoop( Aclone(aLayout), nPosStru )
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf
                aStruct := TMSGetVar("aStruct")
            Next nPosStru
            AEval(aAreaReg,{|x,y| RestArea(x),FwFreeArray(x)})

            DN5->(DbSetOrder(3))
            DN5->(DbSeek(xFilial("DN5")+cCodFonStr+cCodReg+cProces))
            Do While !DN5->(Eof()) .And. DN5->(DN5_FILIAL+DN5_CODFON+DN5_CODREG+DN5_PROCES) == xFilial("DN5")+cCodFonStr+cCodReg+Padr(cProces,Len(DN5->DN5_PROCES))
                If ( lRet := ( DN5->DN5_STATUS == "2" ) )
                    Exit
                EndIf
                DN5->(DbSkip())
            EndDo

        EndIf

        AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

        FwFreeArray(aAreaReg)
        FwFreeArray(aAreas)
		FwFreeArray(aStruct)
		FwFreeArray(aLayout)
		FwFreeArray(aAreaReg)
        TMSSetVar("aStruct", {} )
        TMSSetVar("cProcesso", "" )
        TMSSetVar("aLocaliza",{})
        TMSSetVar("aChaveNFC",{})

    EndIf
    FWFreeObj(oColEnt)

Return lRet

/*{Protheus.doc} TMSAC30GCh()
Busca chaves de DANFE de uma coleta realizada.

@author     Carlos A. Gomes Jr.
@since      06/04/2022
*/
Function TMSAC30GCh( cIDCol )
Local aChvCol  := {.F.,{}}
Local aResGet  := {}
Local nItem    := 0
Local aChaves  := {}
Local oColEnt As Object
Local oResult As Object

DEFAULT cIDCol  := ""

    oColEnt := TMSBCACOLENT():New("DN1")
    If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/documentocarga/coletasEntregas/" + cIDCol ) )[1]
        If FWJsonDeserialize( aResGet[2], @oResult )
            If AttIsMemberOf( oResult, "items" )
                For nItem := 1 To Len( oResult:items )
                    If AttIsMemberOf( oResult:items[nItem], "chave" ) .And. !Empty(oResult:items[nItem]:chave)
                        AAdd( aChaves, oResult:items[nItem]:chave )
                        aChvCol[1] := .T.
                    EndIf
                Next
                aChvCol[2] := AClone(aChaves)
            EndIf
        EndIf
    Else
        TMSAC30Err( "TMSAC30011", oColEnt:last_error, oColEnt:desc_error )
    EndIf
    FwFreeArray(aChaves)
    FWFreeObj(oColEnt)

Return aChvCol

/*{Protheus.doc} TMSAC30DAC()
Gera arquivo DACTE em PDF para anexar no COLENT

@author     Carlos A. Gomes Jr.
@since      13/06/2023
*/
Function TMSAC30DAC( oColEnt, aLayout, aConteudo, lExecAlt )

Local cIDRet     := ""
Local aAreas     := { DT6->(GetArea()), GetArea() }
Local cBarra     := If( IsSrvUnix(), "/", "\" )
Local cPath      := cBarra + "dactetemp" + cBarra
Local cFileName  := ""
Local aDir       := {}
Local nHdlFile   := ""
Local aRetPost   := {}
Local nTamFile   := 0
Local cData      := ""
Local cFilDoc    := ""
Local cDoc       := ""
Local cSerie     := ""
Local cIDColEnt  := ""
Local aResGet    := {}
Local oResult  As Object
Local cHttpCode  := ""

DEFAULT aLayout   := {}
DEFAULT aConteudo := {}
DEFAULT lExecAlt  := .F.

    If Len(aLayout) > 0 .And. Len(aConteudo) > 0
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DT6_FILDOC" }) ) > 0
            cFilDoc := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DT6_DOC" }) ) > 0
            cDoc := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DT6_SERIE" }) ) > 0
            cSerie := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "IDDOC" }) ) > 0
            cIDColEnt := aConteudo[nPos]
        EndIf
    EndIf

    DT6->(DbSetOrder(1))
    If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie) .And. !Empty(cIDColEnt) .And. DT6->(MsSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ))
        If ( aResGet := TMSAC30GAn( oColEnt, cIDColEnt ) )[1] //Busca se Anexo já foi enviado
            If AScan(aResGet[2], {|x| x == AllTrim(DT6->DT6_CHVCTE) }) == 0 //Somente se o anexo ainda não foi enviado
                cPath += cEmpAnt + AllTrim(cFilDoc) + cBarra
                cFileName := DT6->DT6_CHVCTE + '.pdf'
                If FwMakeDir(cPath)
                    If !File( cPath + cFileName ) .And. ExistBlock("RTMSR35", , .T. )
                        ExecBlock("RTMSR35",.F.,.F., {cPath, cFilDoc, cDoc, cSerie, DT6->DT6_CHVCTE})
                    EndIf

                    aDir := Directory(cPath + cFileName)
                    If Len(aDir) > 0 .And. Len(aDir[1]) > 1
                        nTamFile := aDir[1][2]
                    EndIf

                EndIf

                If nTamFile > 0 .And. (nHdlFile := FOpen( cPath + cFileName )) > 0

                    FRead(nHdlFile,cData,nTamFile)
                    FClose(nHdlFile)

                    cJson := '{"nomeArquivo": "' + cFileName + '","tipoConteudo": "application/pdf","tamanho": ' + AllTrim(Str(nTamFile)) + '}'
                    aRetPost := oColEnt:Post( "coletaentrega/core/api/v1/arquivos/upload", cJson )
                    If !aRetPost[1]
                        nConex := HTTPGetStatus(@cHttpCode)
                        If nConex != 200 .And. nConex != 201 .And. nConex != 204
                            TMSAC30Err( "TMSAC30014", oColEnt:last_error, oColEnt:desc_error )
                        EndIf

                    ElseIf FWJsonDeserialize( DecodeUTF8(aRetPost[2]), @oResult ) .And. AttIsMemberOf( oResult, "id" ) .And. AttIsMemberOf( oResult, "url" )
                        cIDRet := oResult:id
                        lExecAlt := TMC30SndFl( oResult:url, cFileName, cData )
                        
                    EndIf

                EndIf
            EndIf
        EndIf
    EndIf

    AEval( aAreas, { |aArea| RestArea(aArea), FwFreeArray(aArea) } )
    FwFreeArray(aAreas)
    FwFreeArray(aDir)
    FWFreeObj(oResult)

Return cIDRet

/*{Protheus.doc} TMSAC30QCD()
Retorna o QRCode do CTE

@author     Carlos A. Gomes Jr.
@since      13/06/2023
*/
Function TMSAC30QCD( cFilDoc, cDoc, cSerie, lManife )
Local cQRCode     := STR0016 //"Sem link no TSS"
Local cIdEnt      := ""
Local cModalidade := ""
Local aNotas      := {}
Local cVersaoCTE  := ""
Local cAviso      := ""
Local cErro       := ""
Local aAreas      := { DT6->( GetArea() ),DTP->( GetArea() ), DTC->( GetArea() ), DTX->( GetArea() ), GetArea() }
Local oNfe As Object

DEFAULT cFilDoc := ""
DEFAULT cDoc    := ""
DEFAULT cSerie  := ""
DEFAULT lManife := .F.

Private lUsaColab := UsaColaboracao("2")

    If ! ( !lUsaColab .And. !TMSSpedNFe( @cIdEnt, @cModalidade, @cVersaoCTE, lUsaColab, Iif( lManife, "58", ) ) )
        If !lManife
            If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
                DT6->( DbSetOrder(1) ) // DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE
                DTC->( DbSetOrder(3) ) // DTC_FILIAL, DTC_FILDOC, DTC_DOC, DTC_SERIE, DTC_SERVIC, DTC_CODPRO
                DTP->( DbSetOrder(2) ) // DTP_FILIAL, DTP_FILORI, DTP_LOTNFC
                If  DT6->(MsSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie )) .AND. ;
                    DTC->(MsSeek( xFilial("DTC") + DT6->( DT6_FILDOC + DT6_DOC + DT6_SERIE ) )) .AND. ;
                    DTP->(MsSeek( xFilial("DTP") + DTC->( DTC_FILORI + DTC_LOTNFC ) ) ) .AND. DTP->DTP_TIPLOT $ "3|4"
                    
                    AAdd(aNotas,{})
                    AAdd(Atail(aNotas),.F.)
                    AAdd(Atail(aNotas),"S")
                    AAdd(Atail(aNotas),"")
                    AAdd(Atail(aNotas),DT6->DT6_SERIE) //SERIE
                    AAdd(Atail(aNotas),DT6->DT6_DOC) //Documento
                    AAdd(Atail(aNotas),"")
                    AAdd(Atail(aNotas),"")

                    aXml := TMSGetXML(cIdEnt,aNotas,@cModalidade)

                    oNfe := XmlParser( aXML[1][2], "_", @cAviso, @cErro )
                    If ValType(oNfe) == "O" .And. AttIsMemberOf( oNfe, "_CTE" ) .And. AttIsMemberOf( oNfe:_CTE, "_INFCTESUPL" )
                        If AttIsMemberOf( oNfe:_CTE:_INFCTESUPL,'_QRCODCTE' ) .And. AttIsMemberOf( oNfe:_CTE:_INFCTESUPL:_QRCODCTE,'TEXT' )
                            If !Empty( oNFE:_CTE:_INFCTESUPL:_QRCODCTE:TEXT )
                                cQrCode := oNfe:_CTE:_INFCTESUPL:_QRCODCTE:TEXT
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        Else
            DTX->(DbSetOrder(2))
            If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie) .And. DTX->(MsSeek( xFilial("DTX") + cFilDoc + cDoc + cSerie ))

                aadd(aNotas,{})
                aAdd(Atail(aNotas),.F.)
                aadd(Atail(aNotas),"")
                aAdd(Atail(aNotas),"")

                If( lUsaColab, aAdd(Atail(aNotas),cSerie), aAdd(Atail(aNotas),'58'+cSerie) )

                aAdd(Atail(aNotas),DTX->DTX_MANIFE) //Documento
                aadd(Atail(aNotas),"")
                aadd(Atail(aNotas),"")

                If( lUsaColab, aXml := TMSColXML(aNotas,@cModalidade,lUsaColab,"58"), aXml := TMSGetXML(cIdEnt,aNotas,@cModalidade,"58") )
                
                oNfe := XmlParser( aXML[1][2], "_", @cAviso, @cErro )
                If ValType(oNfe) == "O" .And. AttIsMemberOf( oNfe, "_MDFE" ) .And. AttIsMemberOf( oNfe:_MDFE, "_INFMDFESUPL" ) .And. AttIsMemberOf( oNfe:_MDFE:_INFMDFESUPL, "_QRCODMDFE" ) 
                    If !Empty(oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT  )
                        cQrCode := oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT
                    EndIf
                EndIf
            EndIf	
        EndIf
    EndIf

    FwFreeObj( oNfe )
    FwFreeArray( aNotas )
    AEval( aAreas, { |aArea| RestArea( aArea ), FwFreeArray( aArea ) } )
    FwFreeArray( aAreas )

Return cQRCode

/*{Protheus.doc} TMSAC30GAn()
Busca anexos pelo Documento

@author     Carlos A. Gomes Jr.
@since      30/06/2023
*/
Function TMSAC30GAn( oColEnt, cIDColEnt )
Local aResGet  := {}
Local aRetGet  := {.F.,{}}
Local nItem    := 0
Local lHasNext := .T.
Local nPage    := 1
Local oResult As Object

DEFAULT cIDColEnt := ""

    If !Empty(cIDColEnt)
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/anexos/coletasEntregas/"+AllTrim(cIDColEnt),"?page=" + AllTrim(Str(nPage)) ) )[1]
                aRetGet[1] := .T.
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If AttIsMemberOf( oResult, "hasNext" )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nItem := 1 To Len( oResult:items )
                            If AttIsMemberOf( oResult:items[nItem], "chaveAcesso" ) .And. !Empty( oResult:items[nItem]:chaveAcesso ) 
                                AAdd(aRetGet[2], AllTrim(oResult:items[nItem]:chaveAcesso) )
                            EndIf
                        Next
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30018", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
    Else
        TMSAC30Err( "TMSAC30019", STR0012 , STR0014 )
    EndIf

    FWFreeObj(oResult)
    FwFreeArray(aResGet)

Return aRetGet

/*{Protheus.doc} TMSAC30Man()
Gera PDF do manifesto
//TMSAC30Man( "M SP 01 ", "000000008", "745" )
@author     Carlos A. Gomes Jr.
@since      07/04/2022
*/
Function TMSAC30Man( oColEnt, aLayout, aConteudo, lExecAlt )
Local cFilMan   := ""
Local cManife   := ""
Local cSerMan   := ""
Local cFilOri   := ""
Local cViagem   := ""
Local cQRCode   := ""
Local aRetVia   := {}
Local aAreas    := { DTX->(GetArea()), GetArea() }
Local cBarra    := If( IsSrvUnix(), "/", "\" )
Local cPath     := cBarra + "damdfetemp" + cBarra
Local cFileName := ""
Local aDir      := {}
Local nTamFile  := 0
Local nHdlFile  := 0
Local cData     := ""
Local cJson     := ""
Local cHttpCode := ""
Local cIDAnex   := ""
Local oResult As Object

DEFAULT aLayout   := {}
DEFAULT aConteudo := {}
DEFAULT lExecAlt  := .F.

    If Len(aLayout) > 0 .And. Len(aConteudo) > 0
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DTX_FILMAN" }) ) > 0
            cFilMan := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DTX_MANIFE" }) ) > 0
            cManife := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DTX_SERMAN" }) ) > 0
            cSerMan := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DTX_FILORI" }) ) > 0
            cFilOri := aConteudo[nPos]
        EndIf
        If (nPos := AScan(aLayout,{|x| AllTrim(x[3]) == "DTX_VIAGEM" }) ) > 0
            cViagem := aConteudo[nPos]
        EndIf

        If !Empty(cFilOri) .And. !Empty(cViagem)
            aRetVia := TMSAC30GVi( oColEnt, cFilOri + cViagem )
        EndIf

    EndIf

    DTX->(DbSetOrder(2))
    If aRetVia[1] .And. !Empty( cFilMan ) .And. !Empty( cManife ) .And. !Empty( cSerMan ) .And. DTX->( MsSeek( xFilial( "DTX" ) + cFilMan + cManife + cSerMan ) )
        
        cQRCode := DTX->( TMSAC30QCD( cFilMan, cManife, cSerMan, .T. ) )

        cPath += cEmpAnt + AllTrim(cFilMan) + cBarra
        cFileName := DTX->DTX_CHVMDF + '.pdf'
        If FwMakeDir(cPath)
            If !File( cPath + cFileName ) .And. ExistBlock("RTMSR34", , .T. )
                ExecBlock("RTMSR34",.F.,.F., DTX->( { { DTX_FILMAN, DTX_MANIFE, DTX_MANIFE, DTX_SERMAN, DTX_VIAGEM, , .T., DTX_FILORI, DTX_CHVMDF, cPath } } ) )
            EndIf
            aDir := Directory(cPath + cFileName)
            If Len(aDir) > 0 .And. Len(aDir[1]) > 1
                nTamFile := aDir[1][2]
            EndIf

            If nTamFile > 0 .And. (nHdlFile := FOpen( cPath + cFileName )) > 0

                FRead(nHdlFile,cData,nTamFile)
                FClose(nHdlFile)

                cJson := '{"nomeArquivo": "' + cFileName + '","tipoConteudo": "application/pdf","tamanho": ' + AllTrim(Str(nTamFile)) + '}'
                aRetPost := oColEnt:Post( "coletaentrega/core/api/v1/arquivos/upload", cJson )
                If !aRetPost[1]
                    nConex := HTTPGetStatus(@cHttpCode)
                    If nConex != 200 .And. nConex != 201 .And. nConex != 204
                        TMSAC30Err( "TMSAC30014", oColEnt:last_error, oColEnt:desc_error )
                    EndIf

                ElseIf FWJsonDeserialize( DecodeUTF8(aRetPost[2]), @oResult ) .And. AttIsMemberOf( oResult, "id" ) .And. AttIsMemberOf( oResult, "url" )
                    cIDAnex := oResult:id
                    If ( lExecAlt := TMC30SndFl( oResult:url, cFileName, cData ) )
                        cJson := '[ { "id": "' + cIDAnex + '",'
                        cJson += '"descricao": "DAMDFE",'
                        cJson += '"barCode": "' + DTX->DTX_CHVMDF + '",'
                        cJson += '"chaveAcesso": "' + DTX->DTX_CHVMDF + '",'
                        cJSon += '"qrCode": "' + cQRCode + '" } ] '
                        If aRetVia[2][2] == "AGUARDANDO_DESPACHO" .Or. aRetVia[2][2] == "AGUARDANDO_CONFIRMACAO_DESPACHO"
                            aRetPost := oColEnt:Post( "coletaentrega/core/api/v1/anexos/viagens/" + aRetVia[2][1] + "/incluir", cJson )
                        Else
                            aRetPost := oColEnt:Post( "coletaentrega/core/api/v1/anexos/viagens/" + aRetVia[2][1] + "/incluirEmAndamento", cJson )
                        EndIf
                        If !aRetPost[1]
                            nConex := HTTPGetStatus(@cHttpCode)
                            If nConex != 200 .And. nConex != 201 .And. nConex != 204
                                TMSAC30Err( "TMSAC30014", oColEnt:last_error, oColEnt:desc_error )
                            EndIf
                        EndIf
                    EndIf
                   
                EndIf
            EndIf
        EndIf
    EndIf

    FwFreeArray( aDir )
    FwFreeArray( aRetVia )
    FwFreeObj( oResult )
    AEval( aAreas, { | aArea | RestArea(aArea), FwFreeArray(aArea) } )
    FwFreeArray( aAreas )

Return cIDAnex

/*{Protheus.doc} TMC30SndFl()
Envio de arquivo PDF para Storage utilizado no Portal SaaS

@author     Carlos A. Gomes Jr.
@since      13/07/23
*/
Function TMC30SndFl( cUrl, cFileName, cData, lContType )
Local lRet       := .F.
Local aHeadOut   := {}
Local cPostParms := ""
Local cResErro   := ""
Local oStorage As Object

DEFAULT cUrl      := ""
DEFAULT cFileName := ""
DEFAULT cData     := ""
DEFAULT lContType := .T. 

    If !Empty(cUrl) .And. !Empty(cFileName) .And. !Empty(cData)
        If lContType
            aHeadOut   := {'Content-Type: application/pdf; boundary=TotvsBoundaryTest'}
            cPostParms := '--TotvsBoundaryTest' + CRLF + CRLF
            cPostParms += 'Content-Disposition: form-data; name="file"; filename="' + cFileName + '"' + CRLF
            cPostParms += 'Content-Type: application/pdf' + CRLF + CRLF
            cPostParms += cData + CRLF
            cPostParms += '--TotvsBoundaryTest' 
        Else
            AAdd( aHeadOut, 'Content-Type: application/octet-stream') //--Envio de Imagem sem o boundary.
            cPostParms := cData
        EndIf 
        oStorage := FwRest():New( cUrl )
        oStorage:SetPath("")
        If !( lRet := oStorage:Put(aHeadOut,cPostParms) )
            cResErro := oStorage:GetResult()
            cResErro := Iif( !Empty(cResErro), DeCodeUTF8(cResErro), STR0015 )//-- "Erro sem descrição."
            TMSAC30Err( "TMSAC30015", oStorage:GetLastError(), cResErro )
        EndIf
    EndIf

    FwFreeArray( aHeadOut )
    FwFreeObj( oStorage )

Return lRet

/*{Protheus.doc} TMSAC30GVi()
Busca anexos pelo Documento

@author     Carlos A. Gomes Jr.
@since      30/06/2023
*/
Function TMSAC30GVi( oColEnt, cChaveVia )
Local aResGet  := {}
Local aRetGet  := {.F.,{}}
Local nItem    := 0
Local lHasNext := .T.
Local nPage    := 1
Local oResult As Object

DEFAULT cChaveVia := ""

    If !Empty(cChaveVia)
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/viagens","?page=" + AllTrim(Str(nPage)) + "&externalIdViagem=" + FWURLEncode(AllTrim(cChaveVia)) ) )[1]
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If AttIsMemberOf( oResult, "hasNext" )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nItem := 1 To Len( oResult:items )
                            If AttIsMemberOf( oResult:items[nItem], "situacao" ) .And. !Empty( oResult:items[nItem]:situacao ) 
                                If oResult:items[nItem]:situacao != "EXCLUIDA"
                                    aRetGet[1] := .T.
                                    aRetGet[2] := { AllTrim(oResult:items[nItem]:id) , AllTrim(oResult:items[nItem]:situacao) }
                                    Exit
                                EndIf
                            EndIf
                        Next
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30018", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo
    EndIf

    FWFreeObj(oResult)
    FwFreeArray(aResGet)

Return aRetGet

/*{Protheus.doc} TMSAC30ExD()
Exclui Documentos

@author     Carlos A. Gomes Jr.
@since      07/04/2022
*//*
Function TMSAC30ExD(cIDDoc,cColEnt)
Local lRet      := .F.
Local cTipDoc   := "entregas"
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

    If cColEnt == "COLETA"
        cTipDoc := "coletas"
    EndIf

    oColEnt := TMSBCACOLENT():New("DN1")
    If !( lRet := oColEnt:Post( "coletaentrega/core/api/v1/"+cTipDoc+"/"+cIDDoc+"/excluir", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        If nConex == 200 .Or. nConex == 201 .Or. nConex == 204
            lRet := .T.
        Else
            TMSAC30Err( "TMSAC30014", oColEnt:last_error, oColEnt:desc_error )
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet
*/
/*{Protheus.doc} TMS30ANEXO()
Gera arquivo DACTE em PDF e Imagem Comprovante de Entrega
para anexar no Portal Logístico
@author     Rafael Souza
@since      12/02/2024
*/
Function TMS30ANEXO( cFilDoc, cDoc, cSerie, lDacte )

Local cIDRet     := ""
Local cIdExt     := ""
Local aAreas     := { DT6->(GetArea()), GetArea() }
Local cBarra     := If( IsSrvUnix(), "/", "\" )
Local cPath      := cBarra + "dactetemp" + cBarra
Local cFileName  := ""
Local aDir       := {}
Local nHdlFile   := ""
Local aRetPost   := {}
Local nTamFile   := 0
Local cData      := ""
Local oResult  As Object
Local cHttpCode  := ""
Local oColEnt As Object
Local cBuffer    := ""
Local cStartPath := GetSrvProfString("Startpath","")

DEFAULT cFilDoc     := ""
DEFAULT cDoc        := ""
DEFAULT cSerie      := ""
DEFAULT lDacte      := .F. 

    oColEnt := TMSBCACOLENT():New("DND")    
    DT6->(DbSetOrder(1))
    If Empty(cFilDoc)
        cFilDoc := DT6->DT6_FILDOC 
        cDoc    := DT6->DT6_DOC 
        cSerie  := DT6->DT6_SERIE 
    EndIf  
    If DT6->(MsSeek( xFilial("DT6") + cFilDoc + cDoc + cSerie ))    
        If lDacte
            If DT6->DT6_SITCTE = '2' 
                cPath += cEmpAnt + AllTrim(cFilDoc) + cBarra
                cFileName := DT6->DT6_CHVCTE + '.pdf'
                If FwMakeDir(cPath)
                    If !File( cPath + cFileName ) .And. ExistBlock("RTMSR35", , .T. )
                        ExecBlock("RTMSR35",.F.,.F., {cPath, cFilDoc, cDoc, cSerie, DT6->DT6_CHVCTE})
                    EndIf

                    aDir := Directory(cPath + cFileName)
                    If Len(aDir) > 0 .And. Len(aDir[1]) > 1
                        nTamFile := aDir[1][2]
                    EndIf

                EndIf
            EndIf 
        Else //--Imagem Comprovante de Entrega

            //-- Pega a imagem do banco
            DM0->(DbSetOrder(1))
            If DM0->(DbSeek(xFilial("DM0") + cFilDoc + cDoc + cSerie)) .And. !Empty(DM0->DM0_IMAGEM)
            
                //-- Decodifica 64
                cBuffer := Decode64(DM0->DM0_IMAGEM)
                
                //-- Gera Arquivo temporário
                cFileName := "CMPENT_" + AllTrim(cFilDoc + cDoc + cSerie) + DM0->DM0_EXTENS
                
                //-- Grava a imagem no arquivo
                nHeader := FCreate(cFileName)
                FWrite(nHeader,cBuffer)
                FClose(nHeader)

                cPath   := cStartPath
                aDir    := Directory(cPath + cFileName)
                If Len(aDir) > 0 .And. Len(aDir[1]) > 1
                    nTamFile := aDir[1][2]
                EndIf
            EndIf     
        EndIf
        
        If nTamFile > 0 .And. (nHdlFile := FOpen( cPath + cFileName)) > 0
            FRead(nHdlFile,cData,nTamFile)
            FClose(nHdlFile)
            If oColEnt:DbGetToken() 
                DND->(DbGoTo(oColEnt:config_recno))

                If lDacte
                    cJson := '{"nome": "' + cFileName + '","tipoConteudo": "application/pdf"}'
                Else 
                    cJson := '{"nome": "' + cFileName + '","tipoConteudo": "image/jpeg"}'
                EndIf 
                
                aRetPost := oColEnt:Post( "core/api/v1/storage/upload", cJson )
                If !aRetPost[1]
                    nConex := HTTPGetStatus(@cHttpCode)
                    If nConex != 200 .And. nConex != 201 .And. nConex != 204
                        TMSAC30Err( "TMSAC30014", oColEnt:last_error, oColEnt:desc_error )
                    EndIf

                ElseIf FWJsonDeserialize( DecodeUTF8(aRetPost[2]), @oResult ) .And. AttIsMemberOf( oResult, "id" ) .And. AttIsMemberOf( oResult, "url" )
                    cIDRet := oResult:id
                    //--Realiza o PUT - Upload do arquivo no Storage do Google
                    lExecAlt := TMC30SndFl( oResult:url, cFileName, cData, lDacte )

                    //--Realiza vinculo da imagem com o Portal  
                    If lExecAlt .And. !lDacte
                        cIdExt := AllTrim(BscIDExtDc("04","2000",FwxFilial("DT6")+ DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))                   
                        TM30AnexDc(cIdRet, cIdExt)

                        //--Apaga o arquivo de imagem temporário
                        FErase(cFileName)
                    EndIf     
                EndIf
            EndIf 
        EndIf 

    EndIf

    AEval( aAreas, { |aArea| RestArea(aArea), FwFreeArray(aArea) } )
    FwFreeArray(aAreas)
    FwFreeArray(aDir)
    FWFreeObj(oResult)

Return cIDRet


/*{Protheus.doc} TM30AnexDc()
Adiciona vinculo do Arquivo no Storage com o Documento
no Portal Logístico.
@author     Rafael Souza
@since      02/02/2024
*/
Function TM30AnexDc(cIdRet, cIdExt)
Local lRet      := .F.
Local cJson     := ""
Local nConex    := 0
Local cHttpCode := ""
Local oColEnt As Object

Default cIdRet  := ""
Default cIdExt := ""
    
    cJson := '{"arquivoId": "'+cIdRet+'"}'
     
    oColEnt := TMSBCACOLENT():New("DND")
    If !( lRet := oColEnt:Post( "core/api/v2/documentosTransporte/"+cIdExt+"/adicionarArquivo/COMPROVANTE_ENTREGA", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30013", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} TM30AReg6
Estorna registros de integração do manifesto
@author Rodrigo Pirolo
@since 04/04/2024
@version 12.1.2410
/*/
//-----------------------------------------------------------

Function TM30AReg6( cFILORI, cVIAGEM, aMdfes )

Local lPrimeiro := .F.
Local cQuery    := ""
Local cAliasDN5 := ""
Local nX        := 0

Default cFILORI := ""
Default cVIAGEM := ""
Default aMdfes  := {}

    If Len(aMdfes) > 0
        DN4->( DbSetOrder(1) )
        lPrimeiro := .T.
        //DN5_FILIAL, DN5_CODFON, DN5_CODREG, DN5_PROCES, R_E_C_N_O_, D_E_L_E_T_
        cAliasDN5 := GetNextAlias()

        If _oDN5 == Nil
            cQuery := " SELECT DN5.DN5_CODFON DN5_CODFON, DN5.DN5_CODREG DN5_CODREG,DN5.R_E_C_N_O_ REGISTRO "
            cQuery += " FROM " + RetSqlName("DN5") + " DN5 "
            cQuery += " WHERE DN5.DN5_FILIAL = ? "//'" + xFilial("DN5") + "' "
            cQuery +=	" AND DN5.DN5_CODFON = ? "//'" + aStruct[nCntFor2,1] + "' "
            cQuery += 	" AND DN5.DN5_PROCES = ? "//'" + PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES)) + "' "
            cQuery +=	" AND DN5.DN5_STATUS NOT IN ('5','6') "
            cQuery +=	" AND DN5.D_E_L_E_T_ = ' ' "

            cQuery := ChangeQuery(cQuery)

            _oDN5 := FWPreparedStatement():New()
            _oDN5:SetQuery(cQuery)

        EndIf

        For nX := 1 To Len(aMdfes)

            _oDN5:SetString( 1, xFilial("DN5")	)
            _oDN5:SetString( 2, "06"			)
            _oDN5:SetString( 3, PadR( aMdfes[nX,1], Len(DN5->DN5_PROCES) )	)
            
            cQuery  := _oDN5:GetFixQuery()

            DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDN5, .F., .T. )

            While (cAliasDN5)->(!Eof())
                //-- Estorna registro na DN5
                DN5->(DbGoTo((cAliasDN5)->REGISTRO))
                RecLock("DN5",.F.)
                DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"6","5")	//-- Estornado Envio ou Estornado
                DN5->DN5_SITUAC := StrZero(3,Len(DN5->DN5_SITUAC))	//-- Estornado
                DN5->(MsUnLock())

                //-- Estorna registro na DN4
                DN4->(MsSeek(xFilial("DN4")+DN5->(DN5_CODFON+DN5_CODREG+DN5_CHAVE)))
                RecLock("DN4",.F.)
                DN4->DN4_IDEXT  := ""
                DN4->DN4_STATUS := '2'
                DN4->(MsUnLock())

                If lPrimeiro
                    DNC->(DbSetOrder(1))
                    If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
                        Reclock("DNC",.F.)
                        DNC->DNC_STATUS := DN5->DN5_STATUS	//-- Estornado Envio ou Estornado
                        DNC->DNC_SITUAC := DN5->DN5_SITUAC	//-- Estornado
                        DNC->DNC_DATULT := dDataBase
                        DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
                        DNC->(MsUnlock())
                    EndIf
                    lPrimeiro := .F.
                EndIf

                (cAliasDN5)->(DbSkip())
            EndDo

            (cAliasDN5)->(DbCloseArea())

        Next nX
    EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} TMSC30DN5S
Verifica se não existem registros na DN5 com Status passado via parametro
@author Rodrigo Pirolo
@since 04/04/2024
@version 12.1.2410
/*/
//-----------------------------------------------------------

Function TMSC30DN5S( cCodFon, cStatus, cProc )

Local cQuery    := ""
Local cAliasDN5 := ""
Local lRet      := .T.
Local lDN5      := AliasInDic("DN5", .F.)

Default cCodFon := ""
Default cStatus := ""
Default cProc   := ""

If lDN5 
    //DN5_FILIAL, DN5_CODFON, DN5_CODREG, DN5_PROCES, R_E_C_N_O_, D_E_L_E_T_
    cAliasDN5 := GetNextAlias()

    If _oSttsDN5 == Nil
        cQuery := " SELECT DN5.DN5_CODFON DN5_CODFON "
        cQuery += " FROM " + RetSqlName("DN5") + " DN5 "
        cQuery += " WHERE DN5.DN5_FILIAL = ? "//'" + xFilial("DN5") + "' "
        cQuery +=	" AND DN5.DN5_CODFON = ? "//'" + aStruct[nCntFor2,1] + "' "
        cQuery += 	" AND DN5.DN5_PROCES = ? "//'" + PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES)) + "' "
        cQuery +=	" AND DN5.DN5_STATUS IN (?) "
        cQuery +=	" AND DN5.D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)

        _oSttsDN5 := FWPreparedStatement():New()
        _oSttsDN5:SetQuery(cQuery)

    EndIf

    _oSttsDN5:SetString( 1, xFilial("DN5")	)
    _oSttsDN5:SetString( 2, cCodFon			)
    _oSttsDN5:SetString( 3, PadR( cProc, Len(DN5->DN5_PROCES) )	)
    _oSttsDN5:SetString( 4, cStatus         )
    
    cQuery  := _oSttsDN5:GetFixQuery()

    DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasDN5, .F., .T. )
    //Se já existir um registro com status "2 não integrado" 
    If (cAliasDN5)->(!Eof())
        lRet := .F.
    EndIf

    (cAliasDN5)->(DbCloseArea())
Else 
    lRet := .F. 
EndIf 

Return lRet

/*{Protheus.doc} TMSAC30AcV()
Busca Documentos durante o acompanhamento de uma Viagem

@author     Carlos A. Gomes Jr.
@since      26/08/2024
*/
Function TMSAC30AcV(cChaveVia)
    Local aDocVia  := {.F.,{}}
    Local aResGet  := {}
    Local aDocTemp := {}
    Local aDocsOrd := {}
    Local oColEnt As Object
    Local oResult As Object
    Local lHasNext := .T.
    Local nPage    := 1
    Local nItem    := 0
    Local nTarefa  := 0

    If !Empty(cChaveVia)
        oColEnt := TMSBCACOLENT():New("DN1")
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "coletaentrega/query/api/v1/viagens/acompanhamento","?page=" + AllTrim(Str(nPage)) + "&externalIdViagem=" + FWURLEncode(AllTrim(cChaveVia)) ) )[1]
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If AttIsMemberOf( oResult, "hasNext" )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nItem := 1 To Len( oResult:items )
                            For nTarefa := 1 To Len( oResult:items[nItem]:tarefas )
                                If !Empty(oResult:items[nItem]:tarefas[nTarefa]:coletaEntregaId)
                                    aDocTemp := {}
                                    AAdd( aDocTemp, oResult:items[nItem]:tarefas[nTarefa]:coletaEntregaId )            //01
                                    AAdd( aDocTemp, oResult:items[nItem]:tarefas[nTarefa]:tipo )                       //02
                                    AAdd( aDocTemp, oResult:items[nItem]:tarefas[nTarefa]:externalId )                 //03
                                    AAdd( aDocTemp, oResult:items[nItem]:tarefas[nTarefa]:situacaoAtual:situacao )                   //04
                                    AAdd( aDocTemp, oResult:items[nItem]:tarefas[nTarefa]:sequencia )                  //05
                                    AAdd( aDocsOrd, aDocTemp )
                                EndIf
                            Next
                        Next
                    EndIf
                EndIf
            Else
                TMSAC30Err( "TMSAC30021", oColEnt:last_error, oColEnt:desc_error )
            EndIf
        EndDo

        If !Empty(aDocsOrd)
            ASort( aDocsOrd, ,, {|x,y| x[5] < y[5] } )
            aDocVia[1] := .T.
            aDocVia[2] := AClone(aDocsOrd)
        EndIf

    EndIf
    
    FwFreeArray(aResGet)
    FwFreeArray(aDocTemp)
    FwFreeArray(aDocsOrd)
    FWFreeObj(oColEnt)
    FWFreeObj(oResult)

Return aDocVia


/*{Protheus.doc} TMSAC30Cl2()
TMS Operacional (Automação de Terminais) Busca pelo cliente e Endereço 
Retrona IDExterno do cliente ou do endereço conforme parâmetro informado
@author     Carlos A. Gomes Jr.
@since      29/03/2022
*/
Function TMSAC30Cl2( oColEnt, aLayout, aCliDados, lExecAlt, lPutEnd )
    Local aResGet    := {}
    Local cRetId     := ""
    Local nPosCod    := AScan( aLayout, { |x| AllTrim(x[3]) == "CODIGO" } )
    Local oResult AS Object

    DEFAULT lPutEnd := .T.

    //Para o TMS Operacional adicionar endereço já acontece nesta rotina
    //portanto nunca executa alternativa de layout
    lExecAlt := .F.
    If nPosCod > 0
        //Apesar de o JSon retorno ter um hasNext só pode haver um cliente para por documento
        //sendo assim no vetor :items estamos tratando apenas a posição 1
        If ( aResGet := oColEnt:Get( "tmsoperacional/query/api/v1/atores","?documentoIdentificacao=" + AllTrim(aCliDados[nPosCod]) ) )[1]
            oResult := JsonObject():New()
            oResult:FromJson(aResGet[2])
            If ValType(oResult["items"]) == "A" .And. Len(oResult["items"]) > 0
                cRetId := oResult["items"][1]["id"]
                If lPutEnd
                    PutAtuEnd( oColEnt, cRetId, aLayout, aCliDados )
                EndIf
            EndIf
        Else
            TMSAC30Err( "TMSAC30004", oColEnt:last_error, oColEnt:desc_error )
        EndIf
    Else
        TMSAC30Err( "TMSAC30024", STR0012 , STR0013 )
    EndIf
    FwFreeArray(aResGet)
    FWFreeObj(oResult)
Return cRetId

/*{Protheus.doc} PutAtuEnd()
Atualiza endereço do cliente
@author     Carlos A. Gomes Jr.
@since      17/06/2025
*/
Static Function PutAtuEnd( oColEnt, cCliId, aLayout, aCliDados )
    Local nEnd       := 0
    Local lHasNext   := .T.
    Local nPage      := 1
    Local aResGet    := {}
    Local lTemEnd    := .F.
    Local nPosIDLoc  := AScan( aLayout, { |x| AllTrim(x[3]) == "IDLOCAL" } )
    Local nPosNome   := AScan( aLayout, { |x| AllTrim(x[3]) == "NOME" } )
    Local nPosFantas := AScan( aLayout, { |x| AllTrim(x[3]) == "FANTASIA" } )
    Local cBody      := ""
    Local nEnds      := 0
    Local oResult AS Object
    Local oBody   AS Object

    Do While lHasNext
        lHasNext := .F.
        If ( aResGet := oColEnt:Get( "tmsoperacional/query/api/v1/atores","/" + AllTrim(cCliId) + "/enderecos"+"?page=" + AllTrim(Str(nPage)) ) )[1]
            oResult := JsonObject():New()
            oResult:FromJson(aResGet[2])
            If oResult:hasProperty("hasNext") .And. ValType(oResult["hasNext"]) == "L"
                lHasNext := oResult["hasNext"]
                nPage ++
            EndIf
            If oResult:hasProperty("items") .And. ValType(oResult["items"]) == "A"
                For nEnd := 1 To Len(oResult["items"])
                    If oResult["items"][nEnd]["localidadeId"] == AllTrim(aCliDados[nPosIDLoc])
                        lTemEnd := .T.
                        Exit
                    EndIf
                Next
            EndIf
            If !lTemEnd
                oBody := JsonObject():New()
                oBody["nome"]         := AllTrim(aCliDados[nPosNome])
                oBody["nomeFantasia"] := AllTrim(aCliDados[nPosFantas])
                oBody["enderecos"]    := oResult["items"]
                AAdd( oBody["enderecos"],  JsonObject():New() )
                nEnds := Len(oBody["enderecos"])
                oBody["enderecos"][nEnds]["tipoEndereco"] := "PORTARIA"
                oBody["enderecos"][nEnds]["descricao"]    := "Endereço de Entrega"
                oBody["enderecos"][nEnds]["localidadeId"] := AllTrim(aCliDados[nPosIDLoc])
                cBody := oBody:toJson()
                If !( aResGet := oColEnt:Put( "tmsoperacional/core/api/v1/atores/" + AllTrim(cCliId), cBody ) )[1]
                    TMSAC30Err( "TMSAC30026", oColEnt:last_error, oColEnt:desc_error )
                EndIf
            EndIf
        Else
            TMSAC30Err( "TMSAC30025", oColEnt:last_error, oColEnt:desc_error )
        EndIf
    EndDo

Return

/*{Protheus.doc} TMSAC30GDT()
Busca documento
@author     Carlos A. Gomes Jr.
@since      17/06/25
*/
Function TMSAC30GDT( oColEnt, aLayout, aNFDados, lExecAlt, cNFeId )
    Local cRet := ""
    Local nPosNFeId := 0
    Local oResult

    DEFAULT cNFeId  := ""

    If Empty(cNFeId)
        If ( nPosNFeId := AScan( aLayout, { |x| AllTrim(x[3]) == "DTC_NFEID" } ) ) > 0
            cNFeId := aNFDados[nPosNFeId]
        EndIf
    EndIf
    If !Empty(cNFeId) 
        If ( aResGet := oColEnt:Get( "tmsoperacional/query/api/v1/documentosCarga","?chave="+cNFeId ) )[1]
            oResult := JsonObject():New()
            oResult:FromJson(aResGet[2])
            //Tratado apenas o primeiro documento encontrado pois não deveria existir outro com a mesma chave
            If oResult:hasProperty("items") .And. ValType(oResult["items"]) == "A" .And. Len(oResult["items"]) > 0
                cRet := oResult["items"][1]["id"]
                lExecAlt := .T.
            EndIf
        Else
            TMSAC30Err( "TMSAC30025", oColEnt:last_error, oColEnt:desc_error )
        EndIf
    EndIf
Return cRet

/*{Protheus.doc} TMSAC30DDT()
Deleta documento
@author     Carlos A. Gomes Jr.
@since      17/06/25
*/
Function TMSAC30DDT( oColEnt, cIntId )
    If !Empty(cIntId) 
        If !( oColEnt:Delete( "tmsoperacional/core/api/v1/documentosCarga/"+cIntId+"/externo") )[1]
            TMSAC30Err( "TMSAC30025", oColEnt:last_error, oColEnt:desc_error )
        EndIf
    EndIf
Return

/*{Protheus.doc} TMSAC30Cl3()
TMS Operacional (Automação de Terminais) Busca pelo cliente
Retrona IDExterno do cliente
@author     Carlos A. Gomes Jr.
@since      24/07/2025
*/
Function TMSAC30Cl3( oColEnt, aLayout, aCliDados, lExecAlt )
Return TMSAC30Cl2( oColEnt, aLayout, aCliDados, lExecAlt, .F. )

/*{Protheus.doc} TMSAC30GD2()
Busca documento
@author     Carlos A. Gomes Jr.
@since      12/08/25
*/
Function TMSAC30GD2( oColEnt, aLayout, aNFDados, lExecAlt )
    lExecAlt := .F.
Return TMSAC30GDT( oColEnt, aLayout, aNFDados, lExecAlt )

/*{Protheus.doc} TMC30EstOpe()
Estorna operação de Carga/Descarga do Automação de Terminais
@author     Carlos A. Gomes Jr.
@since      09/09/2025
*/
Function TMC30EstOpe( cViagem, cJson )
    Local lRet      := .F.
    Local nConex    := 0
    Local cHttpCode := ""
    Local oColEnt As Object
    
    oColEnt := TMSBCACOLENT():New( "DN1", "12" )
    If !( lRet := oColEnt:Post( "automacaoterminais/api/v1/externo/embarques/"+cViagem+"/removerDocumentos", cJson )[1] )
        nConex := HTTPGetStatus(@cHttpCode)
        lRet := .T.
        If nConex != 200 .And. nConex != 201 .And. nConex != 204
            TMSAC30Err( "TMSAC30027", oColEnt:last_error, oColEnt:desc_error )
            lRet := .F.
        EndIf
    EndIf
    FWFreeObj(oColEnt)
Return lRet
