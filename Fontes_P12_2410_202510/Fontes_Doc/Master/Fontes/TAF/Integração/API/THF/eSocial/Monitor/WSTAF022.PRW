#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "WSTAF022.CH"

#DEFINE API_CODE "WSTAF022"

Static __aRetComp := {}

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WSRESTFUL

/*/
//-------------------------------------------------------------------------------------------------------------
WSRESTFUL TAFEsocialMonitorTransmission DESCRIPTION "Transmissão de eventos do eSocial" //FORMAT APPLICATION_JSON

    WSMETHOD POST TRANSMISSION  DESCRIPTION "Realiza a transmissão dos eventos do eSocial" WSSYNTAX "api/rh/esocial/v1/TAFEsocialMonitorTransmission" PATH "api/rh/esocial/v1/TAFEsocialMonitorTransmission"

END WSRESTFUL

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodo POST
Realiza a transmissão dos eventos do eSocial
S-1202 – Remuneração de servidor vinculado a Regime Próprio de Previd. Social

@params

@author José Mauro Dourado Lopes
@since 06/05/2020
@version 1.0
/*/

WSMETHOD POST TRANSMISSION WSREST TAFEsocialMonitorTransmission

    Local cBody             as character
    Local cMsgRet           as character
    Local cValid            as character
    Local cEmpRequest       as character
    Local cFilRequest       as character
    Local cRecnos           as character
    Local cId               as character
    Local cPeriod           as character
    Local cUser             as character
    Local cStatus           as character
    Local cUserId           as Character
    Local lNoErro           as logical
    local lGlbVarFunctions  as logical
    Local nX                as numeric
    Local nZ                as numeric
    Local nSize             as numeric
    Local nAchou            as numeric
    Local nIds              as numeric
    Local oJson             as object
    Local aFiliais          as array
    Local aFilTss           as array
    lOCAL aCompany          as array
    Local aEvtsESoc         as array
    Local aEventos          as array
    Local aVersoes          as array
    Local aRecnos           as array
    Local aKeys             as array
    Local aErrosJob         as array
    Local aMotiveCode       as array
    Local aRetErro          as array
    Local aFilC1E           as array
    Local dDataIni          as date
    Local dDataFim          as date

    lGlbVarFunctions    := FindFunction("hasUKeyByUID")
    cBody               := ''
    cRecnos             := ''
    cValid              := ''
    cStatus             := "' ','1','0'"
    oJson               := JsonObject():New()
    cBody               := self:GetContent()
    cUserId             := IIf(lGlbVarFunctions,;
                               getIdUserFromRequest(self:GetHeader("Authorization")),;
                               "000000")
    aEvtsESoc           := {}
    aEventos            := {}
    aFiliais            := {}
    aFilC1E             := {}
    aRecnos             := {}
    aKeys               := {}
    aVersoes            := {}
    aRetErro            := {}
    lNoErro             := .T.
    nIds                := 0

    oJson:fromJSON( cBody )
    oResponse := JsonObject():New()
    ::SetContentType("application/json")

    cValid    := FPREVALID(oJson)
    cId       := TAFGERAID("TAF")

    If Empty(cValid)
        aCompany  := StrTokArr( oJson["companyId"], "|" )
        cEmpRequest := aCompany[1]
        cFilRequest := aCompany[2]

        cUser       := oJson["user"]

        If PrepEnv( cEmpRequest, cFilRequest )

            If TAFALSINDIC("V5N")
            
                aFiliais    := IIf(lGlbVarFunctions,;
                                   getFilFromRequestOrCached(oJson["branches"], cUserId, cEmpRequest, cFilRequest, API_CODE),;
                                   oJson["branches"])
                cPeriod     := StrTran( oJson["period"] , "/" )

                If oJson["periodFrom"] <> nil
                    dDataIni    := StoD(StrTran(oJson["periodFrom"], "-"))
                EndIf

                If oJson["periodTo"] <> nil
                    dDataFim    := StoD(StrTran(oJson["periodTo"], "-"))
                EndIf

                aEvtsESoc   := TafRotinas(,,.T.,2)
                nSize       := len(oJson["events"])

                If oJson["motiveCode"] <> nil
                    aMotiveCode := aClone(oJson["motiveCode"])
                EndIf

                CRIALOG( cId , oJson["keys"] )
                oResponse['id'] := cId

                For nX := 1 to nSize
                    nAchou := aScan(aEvtsESoc,{|x| x[4] == oJson["events"][nX]})
                    IF nAchou > 0
                        aadd(aEventos,aEvtsESoc[nAchou])
                    EndIf
                Next nX

                If oJson["keys"] <> nil .And. Len(oJson["keys"]) > 0
                    cStatus :=  "' ','1','0','3','6'"
                    For nZ := 1 to Len(oJson["keys"])
                        aIds := StrTokArr( oJson["keys"][nZ], "|" )
                        nIds := Len(aIds)

                        aadd(aVersoes, Iif(nIds >= 4, aIds[4], ""))                    
                        aadd(aKeys, Iif(nIds >= 3, aIds[3], ""))

                        If nIds >= 2
                            If aIds[2] == "S1000" .AND. !Empty(aIds[1])
                                aadd(aFilC1E, aIds[1])
                            EndIf
                        EndIf
                    Next nZ
                    aRecnos := RETRECNO(aEventos,aKeys,aFiliais,aVersoes,aFilC1E)
                    cRecnos := RETINSQL(aRecnos, .T.)
                ElseIf oJson["sendRejected"] <> nil .And. oJson["sendRejected"] == .T.
                    cStatus  += ",'3'"                         
                EndIf

                aFilTss     := RETINFEMP(cEmpRequest, aFiliais)
                aErrosJob   := TAFProc4Tss(.T.,aEventos,cStatus,,,cRecnos, @lNoErro, @cMsgRet,.T.,aFilTss,dDataIni,dDataFim,,,,,,.T.,cPeriod,,cUser,aMotiveCode,@aRetErro)
                TAFMErrT0X(aErrosJob,.T.)

                If lNoErro
                    oResponse['success'] := .T.
                    oResponse['message'] := ENCODEUTF8(cMsgRet)
                    ::SetStatus(200)
                Else
                    oResponse['success'] := .F.
                    oResponse['message'] := ENCODEUTF8(RETMSG(cMsgRet))
                    oResponse['type']    := RetType(aRetErro)
                    ::SetStatus(200)
                EndIf

            Else

                oResponse['success'] := .F.
                oResponse['message'] := EncodeUTF8(STR0005)

                ::SetStatus(200)

            EndIf

        else
            oResponse['success'] := .F.
            oResponse['message'] := STR0004
            ::SetStatus(200)
        Endif
    else
        oResponse['success'] :=.F.
        oResponse['message'] := ENCODEUTF8(cValid)
        ::SetStatus(200)
    EndIf
    ::SetResponse(oResponse:toJSON())

Return .T.

/*/{Protheus.doc} function FPREVALID
Realiza validação dos dados enviados no payload.
@author  José Mauro - Cópia da do fonte WSMIDPROC.PRW
@since   06/05/2020
@version 12.1.25
/*/
Static Function FPREVALID(oJson)

    Local cMessage	:= ""

    If oJson["branches"] == Nil

        cMessage := STR0001

    ElseIf Empty(oJson["events"]) .OR. oJson["events"] == Nil

        cMessage := STR0002

    ElseIf Empty(oJson["companyId"]) .OR. oJson["companyId"] == Nil

        cMessage := STR0003

    EndIf

Return cMessage

/*/{Protheus.doc} RETRECNO
    (long_description)
    @type  Function
    @author José Mauro
    @since 08/05/2020
    @version 1.0
    @param 
        aEventos -> Array com os eventos enviados na requisição.
        aKeys    -> Array com os ID's enviados na requisição.
        aFiliais -> Array com as filiasi enviadas na requisição.
    @return 
        aRecnos -> Array de recnos em formato de STRING.
    /*/
Function RETRECNO(aEventos, aKeys, aFiliais, aVersao, aFilC1E)

    Local cTab          as character
    Local cSelect       as character
    Local cAlias        as character
    Local cIds          as character
    Local cVersao       as character
    Local cFilC1E       as character
    Local aRecnos       as array
    Local nX            as numeric
    Local cAliasRegs    := GetNextAlias()

    Default aEventos    := {}
    Default aFiliais    := {}
    Default aKeys       := {}
    Default aVersao     := {}
    Default aFilC1E     := {}

    aRecnos             := {}
    cSelect             := ''
    nX                  := 0
    cAlias              := GetNextAlias()
    cFiliais            := TAFCacheFil(Nil, aFiliais, .T.)
    cIds                := RETINSQL(aKeys)
    cVersao             := RETINSQL(aVersao)
    cFilC1E             := TAFCacheFil(Nil, aFilC1E, .T.)

    For nX := 1 to len(aEventos)
        cTab := aEventos[nX][3]

        If nX == 1
            cSelect +=  " SELECT R_E_C_N_O_ AS RECNO FROM "+ RetSqlName( cTab )+ " WHERE "
            
            If aEventos[nX][4] == "S-1000"
                cSelect +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC1E + " FILIAIS ) "
                cSelect +=  " AND " + cTab + "_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            Else
                cFiliais    := RETCOMP(aFiliais, cTab)
                cSelect     +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            EndIf

            cSelect +=  " AND "+ cTab + "_ID IN ("+cIds+")"
            cSelect +=  " AND "+ cTab + "_VERSAO IN ("+cVersao+")"
            cSelect +=  " AND "+ cTab + "_ATIVO= '1' AND D_E_L_E_T_ = '' "
        Else
            cSelect +=  "UNION ALL "
            cSelect +=  " SELECT R_E_C_N_O_ AS RECNO FROM "+ RetSqlName( cTab )+ " WHERE "

            If aEventos[nX][4] == "S-1000"
                cSelect +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC1E + " FILIAIS ) "
                cSelect +=  " AND "+ cTab + "_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            Else
                cSelect +=  cTab + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFiliais + " FILIAIS ) "
            EndIf

            cSelect +=  " AND "+ cTab + "_ID IN ("+cIds+")"
            cSelect +=  " AND "+ cTab + "_VERSAO IN ("+cVersao+")"
            cSelect +=  " AND "+ cTab + "_ATIVO= '1' AND D_E_L_E_T_ = '' "
        EndIf
    Next nX

    cSelect := ChangeQuery(cSelect)

    TcQuery cSelect New Alias (cAliasRegs)


    (cAliasRegs)->(dbGoTop())

    While (cAliasRegs)->(!Eof())
        AADD(aRecnos,cvaltochar((cAliasRegs )->RECNO))
        (cAliasRegs)->(dbSkip())
    EndDo

Return aRecnos


/*/{Protheus.doc} RETINSQL
    (long_description)
    @type  Static Function
    @author user
    @since 11/05/2020
    @version version
    @param 
        aArray -> Recebe um array para que seja transformado em string.
    @return 
        Retorna o array separado por vírgula para montade de cláusula IN dentro da query.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETINSQL(aArray as array, lRetVazio as logical)

    Local cRetIn	as character
    Local nX		as numeric

    Default aArray := {}
    Default lRetVazio := .F.

    cRetIn	:= ""
    nX		:= 0

    If !Empty(aArray)
        For nX := 1 to Len(aArray)
            If nX > 1
                cRetIn += " , '" + aArray[nX] + "'"
            Else
                cRetIn += "'" + aArray[nX] + "'"
            EndIf
        Next nX
    Else
        cRetIn += IIf(lRetVazio,"","''")
    EndIf

Return cRetIn

/*/{Protheus.doc} RETINFEMP
    (long_description)
    @type  Static Function
    @author user
    @since 11/05/2020
    @version version
    @param 
        cEmp -> Empresa para processamento.
        aFiliais -> Filiais para processamento.
    @return 
        aRetFils -> Array com as informações necessárias para a função de montagem do XML.
    
    /*/
Function RETINFEMP(cEmp, aFiliais)

    Local nQ        as numeric
    Local aRetFils  as array
    Local aSM0      as array

    aRetFils := {}
    aSM0     := {}

    For nQ := 1 to len(aFiliais)
        aSM0 := FWSM0Util():GetSM0Data( cEmp , aFiliais[nQ] ,  { "M0_CODFIL", "M0_FILIAL" , "M0_CGC","M0_INSC" } )
        aadd(aRetFils,{.T.,aSM0[1][2],aSM0[2][2],aSM0[3][2],aSM0[4][2],""})
    Next nQ
Return aRetFils


/*/{Protheus.doc} function CRIALOG
Realiza a gravação do ID macro na tabela de controle de Transações
@author  José Mauro  - Cópia da do fonte WSMIDPROC.PRW
@since   13/05/2020
@version 1.0
/*/
Static Function CRIALOG( cId, aKeys )
    Local cHEnv      as character
    Local dDtEnv
    Local nX		:= 1
    Local cKeys	:= ""
    Local lRet		:= .F.

    Default aKeys := {}

    // Preenchimento de String de Inputs a serem gravadas na V5N
    For nX := 1 To LEN( aKeys )
        cKeys += "|" + aKeys[nX]
    Next nX

    dDtEnv 	:= DATE()
    cHEnv 	:= TIME()

    // Gravação na tabela
    DbSelectArea("V5N")
    V5N->(DbSetOrder(1)) // V5N_FILIAL, V5N_ID
    V5N->(DbGoTop())

    Begin Transaction
        Reclock( "V5N", .T.)
        V5N_FILIAL      := xFilial("V5N")
        V5N->V5N_ID 	:= cId
        V5N->V5N_DTREQ	:= dDtEnv
        V5N->V5N_HRREQ	:= cHEnv
        V5N->V5N_METODO	:= "POST"
        V5N->V5N_PARAMS	:= cKeys
        lRet := .T.
        V5N->(MsUnLock())
    End Transaction
Return lRet

/*/{Protheus.doc} RETMSG
    (long_description)
    @type  Static Function
    @author José Mauro
    @since 24/06/2020
    @version 1.0
    @param cMsg -> Mensagem recebida do TSS para ser tratada.
    @return cMsg -> Mensagem tratada para ser exibida no frontend.
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RETMSG(cMsg)

    Default cMsg := 'Não foi possível concluir o processamento'

    if "WSCERR044" $ cMsg
        cMsg := 'O serviço do TSS não está disponível ou não foi localizado.'
    EndIf

Return cMsg

/*/{Protheus.doc} RetType
    Retorna o tipo de erro que foi apresentado no TAFProc9.
    @type  Function
    @author José Mauro
    @since 14/07/2020
    @version version
    @param Recebe o array que vem do TAFProc9.
    @return Retorna o tipo de erro.
        0 - Erro genérico 
        1 - Erro de schema
        2 - Erro para se conectar no TSS
        3 - Erro de predecessão
        4 - Erro de TOKEN/Autenticação TAF X TSS.
/*/
Static Function RetType(aRetorno)

    Local nType         := 0
    Local nX            := 0

    Default aRetorno    := {}

    If !Empty(aRetorno)
        For nX := 1 to Len(aRetorno)
            If aRetorno[nX]
                nType :=  nX
            EndIf
        Next nX
    EndIf

Return nType

/*/{Protheus.doc} RETCOMP
    (long_description)
    @type  Static Function
    @author Alexandre .L
    @since 04/10/2021
    @version version
    @param 
        aArray -> Recebe um array para que seja transformado em string.
    @return 
        Retorna o array separado por vírgula para montade de cláusula IN dentro da query.
    @example
    Criação da função para que seja retornado a filial de acordo com o compartilhamento na SX2.
    (examples)
    @see (links_or_references)
    /*/
Static Function RETCOMP(aArray as array, cTable as character)

    Local aRetIn    as array
    Local cRetIn	as character
    Local cIDChFil  as character
    Local cVldTab   as character
    Local lForce    as logical
    Local nX		as numeric
    Local nFilCache as numeric

    Default aArray  := {}

    aRetIn      := {}
    cRetIn	    := ""
    cIDChFil    := ""
    cVldTab     := VldTabTAF(cTable)
    lForce      := .F.
    nX		    := 0
    nFilCache   := AScan(__aRetComp, {|x| x[1] == cVldTab})

	If nFilCache > 0
		cIDChFil := __aRetComp[nFilCache][2]
    ElseIf !Empty(aArray)
        For nX := 1 To Len(aArray)
            AAdd(aRetIn, xFilial(cTable, aArray[nX]))
        Next

        AAdd(__aRetComp, {cVldTab, UUIDRandom()})

        lForce := .T.
	EndIf

    cRetIn := TAFCacheFil(cTable, aRetIn, lForce,, cIDChFil)

Return cRetIn
