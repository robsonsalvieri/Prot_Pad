#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "tbiconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "eventconsummer.ch"


/*/{Protheus.doc} InsightModelMessageReader
Exemplo de classe de processamento de mensagens
@type class
@author DANILO SANTOS
/*/
Class InsightModelMessageReader from LongNameClass
 
    method New()
    method Read()
 
EndClass
 
/*/{Protheus.doc} InsightModelMessageReader::New
construtor
@type method
@author DANILO SANTOS
/*/
method New() Class InsightModelMessageReader
 
return self
 
/*/{Protheus.doc} InsightModelMessageReader::Read
Responsável pela leitura e processamento da mensagem.
@type method
@author DANILO SANTOS
@param oLinkMessage, object, Instância de FwTotvsLinkMesage da mensagem
@return logical, sucesso ou falha. Determina se deve ou não retirar a mensagem da fila.
/*/
method Read( oLinkMessage ) Class InsightModelMessageReader    
    Local cAliasDB := "I14"
    Local aCompanies := {}
    Local nOrderDB := 1
    Local aGrvI14 := {}
    Local lInclui := .F.
    Local cRawMsg := ""
    Local cParseRes := ""
    Local cAlertRaw := ""
    Local oJsonA
    Local lGrvI14Chamada := .F.  
    Local cCompGroup := ''  
    local aGRPcp := {}
    Local aDicSX2 := {}
    local nX := 1
    local lGrava := .T.
    local lforecast := .F.
    local cMsgid := ""

    cRawMsg := oLinkMessage:RawMessage()
    // ConOut("Consumer_rabbit: " + cRawMsg)

    oJsonA := JsonObject():new()
    cParseRes := oJsonA:fromJson(cRawMsg) 

    If !Empty(oJsonA["transactionid"])
        aadd(aGrvI14 , oJsonA["transactionid"]) 
        aadd(aGrvI14 , oJsonA["tenantid"]) 
        cMsgid := iif(oJsonA['data']['insight'] == "RuptureAlert" .or. oJsonA['data']['insight'] == "DemandAlert" .Or. "FinForecastAlert" $ oJsonA['data']['insight'], oJsonA["data"]["messageId"], "")
        aadd(aGrvI14, cMsgid)
        aadd(aGrvI14 , oJsonA['data']['modulo']) 
        aadd(aGrvI14 , oJsonA['data']['insight'])
        If (oJsonA['data']['insight'] == "FinancialForecast")
            SendMrtTime(oJsonA) //SendMrtTime envia metrica do tempo de retorno para o smartlink
            If oJsonA['data']['reqType'] <> "ERR"
                aadd(aGrvI14 , oJsonA['data']['data']:toJSON( ))
            else
                aadd(aGrvI14 ,"{'Code': '" + cvaltochar(oJsonA['data']['statusCode']) + "', 'Description':'" + DecodeUTF8(oJsonA['data']['messageError']) + "'}" )
            Endif  
            lforecast := .T.     
        ElseIf (oJsonA['data']['insight'] == "FinancialAlert")
            SendMrtTime(oJsonA) //SendMrtTime envia metrica do tempo de retorno para o smartlink
            cAlertRaw := FormatRaw(oJsonA,"False")
            aadd(aGrvI14 , cAlertRaw)
            lInclui := .F.
            InsightsEvent( STR0001 + Alltrim(Str(len(oJsonA['data']['data']['alerts']))) + STR0002,STR0003,"080")
        ElseIf oJsonA['data']['insight'] == "ALL" .And. oJsonA['data']['reqType'] == "PER"
            SendMrtTime(oJsonA) //SendMrtTime envia metrica do tempo de retorno para o smartlink
            aadd(aGrvI14 , oJsonA['data']['data'])
            lInclui := .F.  

            SndMtrPerm()

        ElseIf oJsonA['data']['insight'] ==  "AccoutingForecast" 
            aadd(aGrvI14 , oJsonA['data']:toJSON( )) 
        ElseIf oJsonA['data']['insight'] ==  "RuptureAlert"
            SendMrtTime(oJsonA) //SendMrtTime envia metrica do tempo de retorno para o smartlink
            aadd(aGrvI14 , oJsonA['data']['data']:toJSON( )) 
            InsightsEvent(STR0001 + Alltrim(Str(len(oJsonA['data']['data']['alerts']))) + STR0004, STR0005,"082")
        ElseIf oJsonA['data']['insight'] ==  "DemandAlert"
            SendMrtTime(oJsonA) //SendMrtTime envia metrica do tempo de retorno para o smartlink
            If  oJsonA['data']['reqType'] <> "ERR"
                aadd(aGrvI14 , oJsonA['data']['data']:toJSON( ))
                InsightsEvent(STR0001  + Alltrim(Str(len(oJsonA['data']['data']['alerts']))) + STR0006, STR0007,"081")
            else
                aadd(aGrvI14 , "")
            Endif
        Else
            aadd(aGrvI14 , oJsonA['data']:toJSON( ))
        Endif        
        aadd(aGrvI14 , Date())
        aadd(aGrvI14 , FWGrpCompany())
        aadd(aGrvI14 , FWCodFil())
        aadd(aGrvI14 , oJsonA['data']['cUserid'])
        aadd(aGrvI14 , oJsonA['data']['cUserName'])
        aadd(aGrvI14 , .F.)
        aadd(aGrvI14 , Ctod("")) 
        aadd(aGrvI14 , "")
        aadd(aGrvI14 ,oJsonA['data']['reqType'])
        If oJsonA['data']['insight'] == "ALL" .And. oJsonA['data']['reqType'] == "PER"
            aadd(aGrvI14 , "200")
        else
            aadd(aGrvI14 , IIF(oJsonA['data']['reqType'] == "ERR",cvaltochar(oJsonA['data']['statusCode']) ,"200"))
        Endif    
    
    Endif

    cParseRes := oJsonA:fromJson(cRawMsg)
    // ConOut( oLinkMessage:Header():toJson())
    // ConOut( oLinkMessage:Content():toJson())

    cCompGroup := oJsonA['data']['companyGroup']

    // Se for diferente, limpa o ambiente e seta o novo company group
    If valtype(cCompGroup) <> "U" .And. FindFunction( "totvs.protheus.backoffice.ba.insights.util.settingEnvironment", .T. )
        totvs.protheus.backoffice.ba.insights.util.settingEnvironment(cCompGroup, "" ,"" ,  {"I14"})
    Endif

    If LOWER(oJsonA['data']['insight']) <> "metricdata"
    
        // Verifica se o company group atual é diferente do 'cCompGroup'
        If  !EMPTY( cCompGroup ) .And. oJsonA['data']['reqType'] <> "PER"
            aCompanies = FWAllGrpCompany()
            
            If cCompGroup $ ArrTokStr(aCompanies, "|")
                aDicSX2 := FwSX2Util():GetSX2Data('I14', {"X2_ARQUIVO"}, .T.)
                If len(aDicSX2) > 0
                    AGRVI14[8] := oJsonA['data']['companyGroup']
                    AGRVI14[9] := IIf( "FinForecastAlert" $ oJsonA['data']['insight'] ,oJsonA['data']['branch'] , "" ) //branch
                Else
				    FwLogMsg( "ERROR",, "BusinessObject", "Consummer_rabbit", "", "01",I18N( STR0008, { cCompGroup } ) )   //"Empresa: #1 não possui a tabela I14 no dicionário (SX2)"
                    Return .T.
                Endif
            Else
                // conout("A empresa " + cCompGroup + " Nao existe no banco de dados")
                Return .T.
            EndIf

        Endif

        // Verifica se a função GrvI14Fin ainda não foi chamada
        If !lGrvI14Chamada
            // Chama a função 'GrvI14Fin' com os parâmetros apropriados

            If oJsonA['data']['insight'] == "ALL" .And. oJsonA['data']['reqType'] == "PER"
                aGRPcp:= FWAllGrpCompany()
                For nX := 1 To Len(aGRPcp)
                    //Se for diferente, limpa o ambiente e seta o novo company group
                    If FindFunction( "totvs.protheus.backoffice.ba.insights.util.settingEnvironment", .T. )
                        totvs.protheus.backoffice.ba.insights.util.settingEnvironment(aGRPcp[nX], "" ,"" , {"I14"})
                    Endif
                    aDicSX2 := FwSX2Util():GetSX2Data('I14', {"X2_ARQUIVO"}, .T.)
                    If Len(aDicSX2) > 0
                        cAlias  := Alltrim(aDicSX2[1][2])
                        AGRVI14[8] := aGRPcp[nX] 
                        AGRVI14[9] := ""
                        AGRVI14[1] := ""
                        If TCCanOpen( cAlias )
                            GrvI14Fin(cAliasDB, nOrderDB, aGrvI14, lInclui)
                        Endif
                    Endif
                Next nX
                lGrvI14Chamada := .T. 

			elseif oJsonA['data']['insight'] ==  "AccoutingForecast" 
                GrvI16(oJsonA["data"]["data"],oJsonA["data"])
            else
                IF lGrava .And. IIF(lforecast, .T.,!FilterTrID(oJsonA)) 
                    GrvI14Fin(cAliasDB, nOrderDB, aGrvI14, lInclui)
                    lGrvI14Chamada := .T. 
                EndIf
            Endif 
        Endif
    Endif

Return .T.

/*/{Protheus.doc} FormatRaw
Inclui no json o status de leitura e a data em que foi lida a mensagem.
@type
@author DANILO SANTOS
@ojson  object, objeto com as informações retornadas pelo smartlink
@cRead  string , String com as informações de status e data de leitura
@return string. Retorna o status e da data de leitura do alerta.
/*/

Function FormatRaw(oJson,cRead)
Local cTextJson := ""
Local nTam := 0
Local cText := oJson['data']['data']:toJSON( )  
Local cTimeAlert := oJson['time']
Default oJson := Nil
Default cRead := ""

nTam := Len(cText)
If nTam > 0
    cTextJson := SubStr(cText,1 , nTam-1)
Endif

cTextJson += ',"readStatus": ' + '"' + cRead  +'",'
cTextJson += '"receivedDate":'+ '"'  + cTimeAlert +'"}'
            
Return cTextJson

/*/{Protheus.doc} FilterTrID
Faz um filtro na tabela para verificar se o TransactionID ja existe 
evitando a duplicidade do registro.
@type
@author DANILO SANTOS
@ojson  object, objeto com as informações retornadas pelo smartlink
@return logic. Retorno logico para saber se o registro ja existe na tabela.
/*/

Function FilterTrID(oJson)

	Local cQuery 		As Character
 	Local cNextFil	As Character 
    Local lExist As Logical 
    Local oQuery := Nil
    
    Default oJson := Nil
  
    lExist := .F.
    If Len(RetSqlName("I14")) > 0
        cQuery := "SELECT I14.R_E_C_N_O_  "
        cQuery += " FROM ? I14 " 
        cQuery += " WHERE I14.I14_FILIAL = ? "
        cQuery += " AND I14.I14_TRANID = ? "
        cQuery += " AND I14.D_E_L_E_T_ = ? "
      
        cQuery := ChangeQuery(cQuery)
        oQuery := FWExecStatement():New(cQuery)
        oQuery:SetUnsafe( 1, RetSqlName( "I14" ))
        oQuery:SetString( 2, Space( FWSizeFilial() ) )
        oQuery:SetString( 3, oJson["transactionid"] )
        oQuery:SetString( 4, " " )
        cNextFil := oQuery:OpenAlias()

        If (cNextFil)->R_E_C_N_O_ > 0
            lExist := .T.
            FwLogMsg( "WARN",, "BusinessObject", "Consummer_rabbit", "", "02", I18N( STR0010, { oJson["transactionid"] } ) )   //"Mensagem será excluida da fila. O transctionId: #1 já existe e está gravado na tabela I14."
        Endif
        (cNextFil)->(dbCloseArea())
        FreeObj( oQuery )
    Else
        // ConOut( "Tabela I14 da Empresa " + oJson['data']['companyGroup']  +  " -  Nao existe fisicamente no banco de dados")
        lExist := .T.
    Endif            
Return lExist



Function InsightsEvent(cMensagem, cTitulo, cEventID)
Default cEventID	:= "084"
Default cMensagem 	:= ""
Default cTitulo 	:= STR0009 //"Alerta de Insight"

EventInsert(FW_EV_CHANEL_ENVIRONMENT /*"002"   */,;
            FW_EV_CATEGORY_MODULES   /*"001"   */,;
            cEventID                 /*cEventID*/,;
            FW_EV_LEVEL_INFO         /*1       */,;
            ""                       /*cCargo  */,;
            cTitulo                  /*cTitle  */,;
            cMensagem                /*cMessage*/,;
            .T.                      /*lPublic */)

Return Nil

