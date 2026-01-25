#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"


#DEFINE CODE_DEF	200
#DEFINE API_CODE	"WSTAF023"

Static __aSocRot := Nil
Static lLayAtivo := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} WSRESTFUL EsocialMonitorHomeCards
API para obter os dados sintéticos dos cards do Monitor do esocial

@author Leticia Campos
@since 06/05/2020
/*/
//-------------------------------------------------------------------
WSRESTFUL TAFEsocialMonitorHomeCards DESCRIPTION "Dados sintéticos dos cards de eventos do Monitor eSocial" FORMAT APPLICATION_JSON

    WSDATA companyId    AS STRING
    WSDATA branches	    AS ARRAY OF STRING
    WSDATA events	    AS ARRAY OF STRING
    WSDATA period	    AS STRING OPTIONAL
    WSDATA periodFrom	AS STRING OPTIONAL
    WSDATA periodTo	    AS STRING OPTIONAL
    WSDATA filterStatus AS STRING OPTIONAL

    WSMETHOD POST;
        DESCRIPTION "Retorna os dados para os cards de eventos do Monitor eSocial";
        WSSYNTAX "api/rh/esocial/v1/TAFEsocialMonitorHomeCards/?{companyId}&{branches}&{period}&{events}";
        PATH "api/rh/esocial/v1/TAFEsocialMonitorHomeCards";
        TTALK "v1";
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} POST

@description Método para retornar os dados de acordo com os parâmetros informados
no Body. Está sendo utilizado o método POST, pois o guia de API TOTVS não permite
que seja passados parâmetros no Body da Request no método GET
@author Leticia Campos
@since 06/05/2020
/*/
//-------------------------------------------------------------------
WSMETHOD POST WSSERVICE TAFEsocialMonitorHomeCards

    Local cRequest      := self:GetContent()
    Local cAuth         := self:GetHeader("Authorization")
    Local cErrors       := ""
    Local cEmpRequest   := ""
    Local cFilRequest   := ""
    Local lRet          := .T.
    Local aCompany      := {}
    Local oRequest      := Nil
    Local oResponse     := Nil

    If Empty( cRequest )

        lRet    := .F.
        SetRestFault( CODE_DEF, EncodeUTF8( "Requisição não possui parâmetros no corpo da mensagem." ) )

    Else

        oResponse     := JsonObject():New()
        oRequest      := JsonObject():New()
        oRequest:FromJson( cRequest )

        cErrors := checkRequest( oRequest )

        If Empty(cErrors)

            aCompany := StrTokArr( oRequest["companyId"], "|" )

            cEmpRequest := aCompany[1]
            cFilRequest := aCompany[2]

            If PrepEnv( cEmpRequest, cFilRequest )

                InitStatic()

                oResponse   := WS023Resp(oRequest, cEmpRequest, cFilRequest, cAuth)

                ::SetContentType("application/json")
                ::SetStatus(200)
                ::SetResponse( oResponse:ToJson() )
            Else
                lRet    := .F.
                SetRestFault( CODE_DEF, EncodeUTF8( "Falha na preparação do ambiente para a Empresa '" + cEmpRequest + "' e Filial '" + cFilRequest + "'." ) )
            EndIf

        Else

            lRet    := .F.
            SetRestFault( CODE_DEF, EncodeUTF8( cErrors ) )

        EndIf

    EndIf

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} WS023Resp
Utilizado para montar o objeto com a response

@author Victor A. Barbosa
@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function WS023Resp(oRequest, cEmpRequest, cFilRequest, cAuth)

    Local aInFilC1E         := {}
    Local aInFiliais        := {}
    Local aBranches         := {}
    Local aEvents           := {}
    Local aStatus           := {}
	Local aMotives          := {}
    Local aFilCache         := {}
    Local cPeriod           := ""
    Local cEvent            := ""
    Local cTableEvent       := ""
    Local cTypeEvent        := ""
    Local cPeriodFrom       := ""
    Local cPeriodTo         := ""
    Local cCampoTable       := ""
    Local cUserId           := ""
    Local lFilInCache       := .F.
    Local lGlbVarFunctions	:= FindFunction("hasUKeyByUID")
    Local nPosEvent         := 0
    Local nX                := 0
    Local nY                := 0
    Local nPosFil           := 0
    Local nDel              := 0
    Local oResponse         := JsonObject():New()

    Default cAuth     := ""

    aEvents     := validEventTable(oRequest["events"], oRequest["eventGroups"])
    cUserId     := IIf(lGlbVarFunctions,;
                       getIdUserFromRequest(cAuth),;
                       "000000")
    aBranches   := IIf(lGlbVarFunctions,;
                       getFilFromRequestOrCached(oRequest["branches"], cUserId, cEmpRequest, cFilRequest, API_CODE),;
                       aClone(oRequest["branches"]))

    APILogAccess("EsocialMonitorHomeCards")

    If oRequest["filterStatus"] <> NIL
        aStatus := aClone(oRequest["filterStatus"])
    EndIf

	If oRequest["motiveCode"] <> NIL
        aMotives := aClone(oRequest["motiveCode"])
    EndIf

    If oRequest["period"] <> NIL
        cPeriod := oRequest["period"]
    EndIf

    oResponse["items"] := {}

    For nX := 1 To Len( aEvents )
    
        ASORT(aEvents)

        cEvent      := aEvents[nX]
        nPosEvent   := aScan(__aSocRot, {|x| x[4] == cEvent })
        cTableEvent := __aSocRot[nPosEvent][3]
        cTypeEvent  := __aSocRot[nPosEvent][12]
        cCampoTable := __aSocRot[nPosEvent][6]

        cPeriodFrom := oRequest["periodFrom"]
        cPeriodTo   := oRequest["periodTo"]
		
        lFilInCache := .F.

        If FindFunction( "VldTabTAF" )

            cFilComp    := VldTabTAF( cTableEvent )

            // Verifica se já existe cache de filial para o tipo de compartilhamento da tabela/evento
            If Len(aFilCache) > 0
                
                nPosFil     := aScan(aFilCache,{|x|x[1] == cFilComp})

                If nPosFil > 0
                    cInFiliais := aFilCache[nPosFil][2]
                    cInFilC1E := aFilCache[nPosFil][3]

                    lFilInCache := .T.
                EndIf

            EndIf

        EndIf

        If !lFilInCache

			For nY := 1 To Len(aBranches)

				AAdd(aInFiliais, xFilial(cTableEvent, aBranches[nY]))
				AAdd(aInFilC1E, aBranches[nY])

			Next nY

			cInFiliais  := TAFCacheFil(cTableEvent, aInFiliais, .T.)
			cInFilC1E   := TAFCacheFil(cTableEvent, aInFilC1E, .T.)

			aAdd(aFilCache, {cFilComp,cInFiliais,cInFilC1E})

        EndIf

        aAdd(oResponse["items"], JsonObject():New())

        WS023Event(@oResponse["items"], nX, cPeriod, cInFiliais, cTableEvent, cEvent, cTypeEvent, cCampoTable, cPeriodFrom, cPeriodTo, aMotives, cInFilC1E, aStatus)

    Next nX

    nX := aScan(oResponse["items"], "delete")
    While nX > 0
        aDel(oResponse["items"], nX)
        nX := aScan(oResponse["items"], "delete")
        nDel ++
    EndDo

    aSize(oResponse["items"], Len(oResponse["items"]) - nDel)

    OrderCards(@oResponse)

Return( oResponse )

//-------------------------------------------------------------------
/*/{Protheus.doc} WS023Event

@description Faz a query agrupando um determinado evento por status 
e retorna por referência. 
@author Leticia Campos
@since 07/05/2020
/*/
//-------------------------------------------------------------------
Static Function WS023Event(oResponse, nNewPos, cPeriod, cInFiliais, cTableEvent, cEvent, cTypeEvent, cCampoTable, cPeriodFrom, cPeriodTo, aMotives, cInFilC1E, aFilterStatus)

    Local aEvento       := {}
    Local aTypeStatus   := {}
    Local aDtRefEve     := {}
    Local aStatus       := Array(5)
    Local cQuery        := ""
	Local cMotives      := ""
    Local cEventsTab    := "S-1005|S-1010|S-1020|S-1030|S-1035|S-1040|S-1050|S-1060|S-1070|S-1080|"
    Local cFieldStatus  := cTableEvent + "_STATUS "
    Local cWorkAlias    := GetNextAlias()
    Local cEventDesc    := Posicione("C8E", 2, xFilial("C8E") + cEvent, "C8E_DESPRT")
    Local cFilterStatus := "('" + StrTran(StrTran(StrTran(ArrTokStr(aFilterStatus), "1", " |0|1"), "5", "7"),"|", "','") + "')"
    Local lCmpEvento    := TafColumnPos(cTableEvent + "_EVENTO")
    Local lHasFilPeriod := !(Empty(cPeriodFrom) .And. Empty(cPeriodTo) .And. Empty(cPeriod))
    Local lHasFilStatus := Len(aFilterStatus) > 0
    Local nTotEvent     := 0
    Local nQtd1         := 0
    Local nQtd3         := 0
    Local nQtd4         := 0
    Local nQtd5         := 0
    Local nZ		    := 1
	Local nW		    := 1
    Local nPosStatus    := 1
    Local oStatus 		:= JsonObject():new()

    aEvento := AdjustEventDate( TAFRotinas(cEvent, 4, .F., 2, lLayAtivo) )

    If cTypeEvent == "T"

        If !(lHasFilStatus == .T. .And. aScan(aFilterStatus, "4") == 0) .AND. TafColumnPos( cTableEvent + "_PERAPU" )        

            If Select(cWorkAlias) > 0
                (cWorkAlias)->( dbCloseArea() )
            EndIf

            cQuery := " SELECT COUNT(" + cTableEvent + "_PERAPU) QTD "
            cQuery += " FROM " + RetSQLName(cTableEvent)
            cQuery += " WHERE " + cTableEvent + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cInFiliais + " FILIAIS ) "
            cQuery += " AND " + cTableEvent + "_ATIVO = '1' "

            If !Empty(cPeriod)

                If cEvent $ "S-5003|S-5013"
                    cQuery += " AND " + cTableEvent + "_PERAPU = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' "
                Else
                    cQuery += " AND " + cTableEvent + "_PERAPU = '" + cPeriod + "' "
                EndIf

            EndIf

            cQuery += " AND D_E_L_E_T_ = ' ' "

            TCQuery cQuery New Alias (cWorkAlias)

            If (cWorkAlias)->QTD == 0 .And. (lHasFilStatus == .T. .And. aScan(aFilterStatus, "4") > 0)
                oResponse[nNewPos]  := "delete"
            Else
                buildEventInfo(@oResponse[nNewPos], cEvent, cEventDesc, aStatus, (cWorkAlias)->QTD)
            EndIf

            (cWorkAlias)->( dbCloseArea() )

        Else 
            oResponse[nNewPos]  := "delete"
        EndIf

    Else

        If Select(cWorkAlias) > 0
            (cWorkAlias)->( dbCloseArea() )
        EndIf

        cQuery := ""
        cQuery += " SELECT COUNT( A." + cTableEvent + "_STATUS) QTD, "
        cQuery += " A." + cFieldStatus + " STATUS "

        If cEvent $ cEventsTab .And. lCmpEvento
            cQuery += ", A." + cTableEvent + "_EVENTO AS EVENTO "
        Else    
            cQuery += ", '' AS EVENTO "
        EndIf

        cQuery += " , 0 ALERTS "
        cQuery += " FROM " + RetSQLName(cTableEvent) + " A "

        If cEvent == "S-2200" 

            cQuery += " INNER JOIN " + RetSqlName("CUP") + " CUP "
            cQuery += " ON A.C9V_FILIAL = CUP.CUP_FILIAL "
            cQuery += " AND A.C9V_ID = CUP.CUP_ID "
            cQuery += " AND A.C9V_VERSAO = CUP.CUP_VERSAO "
            cQuery += " AND CUP.D_E_L_E_T_ = ' ' "

        EndIf

        cQuery += " WHERE A.R_E_C_N_O_ IN ( SELECT  B.R_E_C_N_O_ "
        
        cQuery += " FROM " + RetSQLName(cTableEvent) + " B "
        cQuery += " WHERE B." + cTableEvent + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cInFiliais + " FILIAIS ) "
        
        If TafColumnPos( cTableEvent + "_STASEC" ) .AND. cEvent $ "S-2205|S-2206"
            cQuery += " AND ( B." + cTableEvent + "_ATIVO = '1' OR ( B." + cTableEvent + "_ATIVO = '2' AND B." + cTableEvent + "_STATUS = '7' ) ) "
        ElseIf TafColumnPos( cTableEvent + "_STASEC" )
            cQuery += " AND ( B." + cTableEvent + "_ATIVO = '1' OR B." + cTableEvent + "_STASEC = 'E'  OR ( B." + cTableEvent + "_ATIVO = '2' AND B." + cTableEvent + "_STATUS = '7' ) ) "
        ElseIf cEvent $ cEventsTab .And. lCmpEvento
            cQuery += " AND ( B." + cTableEvent + "_ATIVO = '1' OR ( B." + cTableEvent + "_EVENTO = 'E' AND B." + cTableEvent + "_ATIVO = '2' AND B." + cTableEvent + "_STATUS = '4' )) "        
        Else
            cQuery += " AND ( B." + cTableEvent + "_ATIVO = '1' OR ( B." + cTableEvent + "_ATIVO = '2' AND B." + cTableEvent + "_STATUS = '7' )) "
        EndIf

        If cEvent $ "S-1200|S-1202|S-2200|S-2300|S-2400|S-2405"
            cQuery += " AND B." + cTableEvent + "_NOMEVE = '"+ StrTran(cEvent,"-","") +"' "
        EndIf

        If cEvent <> "S-3000" .AND. cTypeEvent <> "C"

            If aEvento[12] == "E" .And. (!Empty(cPeriodFrom) .OR. !Empty(cPeriodTo))

                If cEvent == "S-2230" 

                    cQuery += " AND ( B.CM6_DTAFAS BETWEEN '" + cPeriodFrom + "' AND '"  + cPeriodTo + "' OR "
                    cQuery +=       " B.CM6_DTFAFA BETWEEN '" + cPeriodFrom + "' AND '"  + cPeriodTo + "' ) "
                
                ElseIf !Empty(aEvento[6]) .And. lHasFilPeriod

                    aDtRefEve   := StrTokArr(aEvento[6], "|")
                    cQuery      += " AND ("

                    For nZ := 1 To Len(aDtRefEve)

                        If cEvent $ "S-2200" 
                            cQuery += " CUP." + aDtRefEve[nZ] + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                        Else
                            cQuery += " B." + aDtRefEve[nZ] + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                        EndIf
                        cQuery  += Iif(nZ != Len(aDtRefEve), " OR ", ")")        

                    Next nZ 

                EndIf

            ElseIf !Empty(cPeriod) 

                aDtRefEve   := StrTokArr(aEvento[6], "|")
                cQuery      += " AND ( "
                    
                For nZ := 1 To Len(aDtRefEve)

                    If !Empty(aEvento[6])
                        If cEvent $ "S-2200" 
                            cQuery += " CUP." + aDtRefEve[nZ] + " = '" + cPeriod + "' OR CUP." + aDtRefEve[nZ] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' "
                        Else
                            cQuery += " B." + aDtRefEve[nZ] + " = '" + cPeriod + "' OR B." + aDtRefEve[nZ] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' "      
                        EndIf
                    EndIf

                    cQuery  += Iif(nZ != Len(aDtRefEve), " OR ", ")")    

                Next nZ 

            EndIf

        EndIf 

		If cEvent == "S-2230"

            If Len(aMotives) > 0

                For nW := 1 To Len(aMotives)

                    If nW == Len(aMotives)
                        cMotives += Posicione("C8N", 2, xFilial("C8N") + aMotives[nW], "C8N_ID")
                    Else
                        cMotives += Posicione("C8N", 2, xFilial("C8N") + aMotives[nW], "C8N_ID") + ","
                    EndIf

                Next nW

                cMotives := FormatIn(cMotives, ",")
                cQuery += " AND B.CM6_MOTVAF IN " + cMotives

            EndIf

        EndIf

        cQuery += "AND B." + cFieldStatus + IIF(lHasFilStatus, "IN " + cFilterStatus + " ", "<> '6' ")

        If cEvent $ "S-1200|S-1202|S-2200|S-2300|S-2400|S-2405"
            cQuery += " AND B." + cTableEvent + "_NOMEVE = '" + StrTran(cEvent, "-") + "' "
        EndIf

        cQuery +=  " AND B.D_E_L_E_T_ = ' ') "
        
        cQuery += " AND A." + cTableEvent + "_FILIAL IN "
        cQuery += " ( SELECT FILIAIS.FILIAL FROM " + cInFiliais + " FILIAIS ) "

        If cEvent == "S-1000"
            cQuery += " AND A." + cTableEvent + "_MATRIZ = 'T' AND A." + cTableEvent + "_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cInFilC1E + " FILIAIS ) "
        EndIf
        
        If TafColumnPos( cTableEvent + "_STASEC" ) .AND. cEvent $ "S-2205|S-2206"
            cQuery += " AND ( A." + cTableEvent + "_ATIVO = '1' OR ( A." + cTableEvent + "_ATIVO = '2' AND A." + cTableEvent + "_STATUS = '7' ) ) "
        ElseIf TafColumnPos( cTableEvent + "_STASEC" )
            cQuery += " AND ( A." + cTableEvent + "_ATIVO = '1' OR A." + cTableEvent + "_STASEC = 'E'  OR ( A." + cTableEvent + "_ATIVO = '2' AND A." + cTableEvent + "_STATUS = '7' ) ) "
        ElseIf cEvent $ cEventsTab .And. lCmpEvento
            cQuery += " AND ( A." + cTableEvent + "_ATIVO = '1' OR ( A." + cTableEvent + "_EVENTO = 'E' AND A." + cTableEvent + "_ATIVO = '2' AND A." + cTableEvent + "_STATUS = '4' )) "        
        Else
            cQuery += " AND ( A." + cTableEvent + "_ATIVO = '1' OR ( A." + cTableEvent + "_ATIVO = '2' AND A." + cTableEvent + "_STATUS = '7' )) "
        EndIf
        
        If cEvent $ "S-1200|S-1202|S-2200|S-2300|S-2400|S-2405"
            cQuery += " AND A." + cTableEvent + "_NOMEVE = '" + StrTran(cEvent, "-") + "' "
        EndIf

        If cEvent == "S-1070"
            cQuery += " AND A." + cTableEvent + "_ESOCIA = '1' "
        EndIf 

        If aEvento[12] == "E" .And. (!Empty(cPeriodFrom) .OR. !Empty(cPeriodTo)) .AND. cEvent != "S-3000"

            If cEvent == "S-2230"
            
                cQuery += " AND ( A.CM6_DTAFAS BETWEEN '" + cPeriodFrom + "' AND '"  + cPeriodTo + "' OR "
                cQuery +=       " A.CM6_DTFAFA BETWEEN '" + cPeriodFrom + "' AND '"  + cPeriodTo + "' ) "
             
            ElseIf !Empty(aEvento[6]) .And. lHasFilPeriod 

                aDtRefEve   := StrTokArr(aEvento[6], "|")
                cQuery      += " AND ("
                
                For nZ := 1 To Len(aDtRefEve)

                    If cEvent $ "S-2200" 
                        cQuery += " CUP." + aDtRefEve[nZ] + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                    Else
                        cQuery += " A." + aDtRefEve[nZ] + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                    EndIf

                    cQuery  += Iif(nZ != Len(aDtRefEve), " OR ", ")")    

                Next nZ               

            EndIf

        ElseIf !Empty(cPeriod) .AND. aEvento[12] != "E" 

            aDtRefEve   := StrTokArr(aEvento[6], "|")
            cQuery      += " AND ( "
                
            For nZ := 1 To Len(aDtRefEve)

                If !Empty(aEvento[6]) 

                    If len(cPeriod) > 5
                    
                        cQuery += " A." + aDtRefEve[nZ] + " = '" + cPeriod + "' OR A." + aDtRefEve[nZ] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' "      
                    
                    Else

                        If aEvento[12] == "M" .And. cEvent != "S-2501"
                        
                            cQuery += " A." + cTableEvent + "_INDAPU = '2' AND "
                        
                        EndIf
                        
                        cQuery += " SUBSTRING(A." + aDtRefEve[nZ] + ",1, 4) = '" + cPeriod + "' OR SUBSTRING(A." + aDtRefEve[nZ] + ",3, 4) = '" + cPeriod + "' "     
                             
                    EndIf
                    
                EndIf

                cQuery  += Iif(nZ != Len(aDtRefEve), " OR ", ")")  

            Next nZ

        ElseIf (!Empty(cPeriod) .OR. !Empty(cPeriodFrom) .OR. !Empty(cPeriodTo)) .AND. cEvent == "S-3000"

            aDtRefEve   := StrTokArr(aEvento[6], "|")
            cQuery      += " AND ( "
                
            For nZ := 1 To Len(aDtRefEve)

                If !Empty(aEvento[6])
                    If !Empty(cPeriod) .AND. ( Empty(cPeriodFrom) .OR. Empty(cPeriodTo) )
                        cQuery += " A." + aDtRefEve[nZ] + " = '" + cPeriod + "' OR A." + aDtRefEve[nZ] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' "      
                    ElseIf ( !Empty(cPeriodFrom) .AND. !Empty(cPeriodTo) ) .AND. Empty(cPeriod) 
                        cQuery += " A.CMJ_PERAPU = '' AND A.CMJ_DINSIS BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                    Else
                        cQuery += " ( A.CMJ_PERAPU = '' AND A.CMJ_DINSIS BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "')"
                        cQuery += " OR ( A." + aDtRefEve[nZ] + " = '" + cPeriod + "' OR A." + aDtRefEve[nZ] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "')"
                    EndIf
                EndIf

                cQuery  += Iif(nZ != Len(aDtRefEve), " OR ", ")")    

            Next nZ 

        EndIf
        
        cQuery += " AND A.D_E_L_E_T_ = ' ' " 
        cQuery += " GROUP BY A." + cTableEvent + "_EVENTO , A." + cTableEvent + "_STATUS "
        
        cQuery := ChangeQuery( cQuery )
        
        TCQuery cQuery New Alias (cWorkAlias)

        If (cWorkAlias)->( !Eof() )

            While (cWorkAlias)->( !Eof() )

                oStatus     := JsonObject():new()

                If !(cWorkAlias)->STATUS $ "2|6"
                    nTotEvent   += (cWorkAlias)->QTD
                EndIf
                        
                // Retorna a descrição do status encontrado com a quantidade e tipo
                Do Case
                    Case (cWorkAlias)->STATUS $ " |0|1"
                        oStatus["title"] 	:= "Pendente de Envio"
                        nPosStatus          := 1
                        nQtd1               += (cWorkAlias)->QTD

                    Case (cWorkAlias)->STATUS $ "2|6"
                        oStatus["title"] 	:= "Aguardando Governo"
                        nPosStatus          := 2

                    Case (cWorkAlias)->STATUS $ "3"
                        oStatus["title"] 	:= "Rejeitado"
                        nPosStatus          := 3
                        nQtd3               += (cWorkAlias)->QTD

                    Case (cWorkAlias)->STATUS $ "4" .And. (cWorkAlias)->EVENTO <> "E"
                        oStatus["title"] 	:= "Sucesso"
                        nPosStatus          := 4
                        nQtd4               += (cWorkAlias)->QTD
                    
                    Case (cWorkAlias)->STATUS $ "7" .Or. ((cWorkAlias)->STATUS == "4" .And. (cWorkAlias)->EVENTO == "E") // retirado status 6 para que os eventos excluídos pendente de tranmissão sejam visualizados apenas no S-3000
                        oStatus["title"] 	:= "Excluido"
                        nPosStatus          := 5
                        nQtd5               += (cWorkAlias)->QTD
                EndCase

                IIf( (cWorkAlias)->STATUS $ " |0", "1", IIf((cWorkAlias)->STATUS $ "7" .Or. ((cWorkAlias)->STATUS == "4" .And. (cWorkAlias)->EVENTO == "E"), "5", (cWorkAlias)->STATUS ) )
                
                oStatus["type"]     := IIf( (cWorkAlias)->STATUS $ " |0", "1", IIf((cWorkAlias)->STATUS $ "7" .Or. ((cWorkAlias)->STATUS == "4" .And. (cWorkAlias)->EVENTO == "E"), "5", (cWorkAlias)->STATUS ) )
                oStatus["value"]    := IIf( (cWorkAlias)->STATUS $ " |0|1", nQtd1, IIF((cWorkAlias)->STATUS $ "3", nQtd3, IIF((cWorkAlias)->STATUS == "4" .And. (cWorkAlias)->EVENTO <> "E", nQtd4, IIf( (cWorkAlias)->STATUS $ "7" .Or. ((cWorkAlias)->STATUS == "4" .And. (cWorkAlias)->EVENTO == "E"), nQtd5, (cWorkAlias)->QTD ))) )
                oStatus["warning"]  := IIf( (cWorkAlias)->STATUS $ " |0|1|3", .T., .F. )
                oStatus["alert"]    := IIf( (cWorkAlias)->STATUS == "4" .And. (cWorkAlias)->ALERTS > 0, .T. , .F. )

                aStatus[nPosStatus] := oStatus

                AADD( aTypeStatus, oStatus["type"] )
                FreeObj( oStatus )

                (cWorkAlias)->( dbSkip() )

            EndDo

            // Adiciona os status vazios
            For nZ := 1 To 5

                If ASCAN( aTypeStatus, ALLTRIM( STR( nZ ) ) ) == 0

                    oStatus := JsonObject():new()

                    oStatus["title"]   := RETNAME(nZ)
                    oStatus["type"]    := cValToChar(nZ)
                    oStatus["value"]   := 0 // Quantidade com Status analisado
                    oStatus["warning"] := .F.
                    oStatus["alert"]   := .F.
                    aStatus[nZ]        := oStatus

                    FreeObj( oStatus )

                EndIf

            Next nZ

            buildEventInfo(@oResponse[nNewPos], cEvent, cEventDesc, aStatus, nTotEvent)

        Else

            // Evento(s) não encontrado(s)
            If lHasFilStatus

                oResponse[nNewPos]  := "delete"

            Else

                buildEventInfo(@oResponse[nNewPos], cEvent, cEventDesc, aStatus, nTotEvent)
                
                For nZ := 1 To 5

                    oStatus := JsonObject():new()

                    oStatus["title"]   := RETNAME(nZ)
                    oStatus["type"]    := cValToChar(nZ)
                    oStatus["value"]   := 0 // Quantidade do status analisado
                    oStatus["warning"] := .F.
                    aStatus[nZ]        := oStatus

                    FreeObj( oStatus )

                Next nZ

            EndIf

        EndIf

        (cWorkAlias)->( dbCloseArea() )

    EndIf

Return

//-------------------------------------------------------------------
/*/
{Protheus.doc} AdjustEventDate
    Ajusta Campos de Período de Eventos que por Particularidade tem mais de um campo data
    ou que o campo data não esta na tabela principal (Ex: S-2200, campo data é o CUP_DTADMI,
    porém a tabela principal do evento é a C9V)
    
    @author Fabio Mendonça
    @since 16/12/2021
    @version 1.0
    @param aEvento, Array de String, Vetor com informações do evento na TAFRotinas
    @return aEvento, Array de String, Vetor com datas preenchidas, quando necessário
/*/
//-------------------------------------------------------------------
Function AdjustEventDate( aEvento )

    If (Empty(aEvento[6]))

        If aEvento[4] == "S-2200" 
            aEvento[6] := "CUP_DTADMI|CUP_DTINVI"
        ElseIf aEvento[4] == "S-2230" 
            aEvento[6] := "CM6_DTAFAS|CM6_DTFAFA"
        ElseIf aEvento[4] == "S-2231"
            aEvento[6] := "V72_DTINIC|V72_DTTERM"
        EndIf

    EndIf   

    If aEvento[4] == 'S-2501' //Esse evento se comporta como um Mensal, porém é eventual .. Não mexer no TAFROTINAS para não quebrar o monitor antigo
        aEvento[12] := 'M'
    EndIf 
    
Return ( aEvento )

//-------------------------------------------------------------------
/*/{Protheus.doc} InitStatic
Inicializa as variáveis státics

@author Victor A. Barbosa
@since 13/08/2019
/*/
//-------------------------------------------------------------------
Static Function InitStatic()

    lLayAtivo := TafLayESoc(,.T.)

    If __aSocRot == Nil
       __aSocRot := TAFRotinas(,, .T., 2, lLayAtivo)
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} checkRequest
Validação dos parâmetros recebidos.

@author Leticia Campos
@since 13/05/2020
/*/
//-------------------------------------------------------------------
Static Function checkRequest(oRequest)

    Local cMessage := ""

    If Empty(oRequest["companyId"])
        cMessage += " Empresa|Filial não informado no parâmetro 'companyId'. "
    EndIf

    If oRequest["branches"] == Nil
        cMessage += " Parâmetro 'branches' é obrigatório e não pode estar ausente do corpo da requisição."
    EndIf

    If Empty(oRequest["eventGroups"]) .And. Empty(oRequest["events"])
        cMessage += " Evento não informado no parâmetro 'events'. "           
    EndIf

Return cMessage

//-------------------------------------------------------------------
/*/{Protheus.doc} RETNAME
Monta Array com os nomes dos status.

@author Leticia Campos
@since 13/05/2020
/*/
//-------------------------------------------------------------------
Static Function RETNAME(nX)

    Local aRet as array

    aRet :={}

    aadd(aRet,"Pendente de Envio")
    aadd(aRet,"Aguardando Governo")
    aadd(aRet,"Rejeitado")
    aadd(aRet,"Sucesso")
    aadd(aRet,"Excluido")

return aRet[nX]

//---------------------------------------------------------------------
/*/{Protheus.doc} validEventTable
Valida a existência da tabela do respectivo evento. 
Caso não exista na base de dados, retira o evento da listagem

@author Fabio Mendonça
@since 10/09/2021
@version 1.0
@param aEvents, array, Eventos para validar existência da respectiva tabela
@return aValidEvents, array, Eventos validados existência de respectiva tabela
/*/
//---------------------------------------------------------------------
Static Function validEventTable(aEvents, aGroups)

    Local aValidEvents  := {}
    Local nIndex        := 0

    Default aEvents     := {}
    Default aGroups     := {}

    aValidEvents := GroupFilter(aGroups)

    For nIndex := 1 To Len(aEvents)

        If AScan(aValidEvents, aEvents[nIndex]) == 0 

            If TAFAlsInDic(TAFRotinas(aEvents[nIndex], 4, .F., 2, lLayAtivo )[3])  
                AAdd(aValidEvents, aEvents[nIndex])
            EndIf

        EndIf

    Next

Return aValidEvents

//---------------------------------------------------------------------
/*/{Protheus.doc} buildEventInfo
    Constrói bloco de informações referentes aos itens dos eventos pro retorno JSON
   
    @author Fabio Mendonça
    @since 25/03/2022
    @version 1.0
    @param oResponse, Array de Objetos, Objeto JSON de retorno da API
    @param cEventCode, String, Código do Evento
    @param cEventDesc, String, Descrição do Evento
    @param aStatus, Array de Objetos, Sub-Itens da propriedade Status
    @param nTotal, Numérico, Quantidade de Eventos
    @return void
/*/
//---------------------------------------------------------------------
Static Function buildEventInfo(oResponse, cEventCode, cEventDesc, aStatus, nTotal)

    oResponse["eventCode"]        := cEventCode
    oResponse["eventDescription"] := EncodeUTF8(AllTrim(cEventDesc))
    oResponse["status"]           := aStatus
    oResponse["total"]            := nTotal
    
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} GroupFilter
Retorna os eventos filtrados por grupo

@author Melkz Siqueira
@since 04/05/2022
@version 1.0
@param aGroups - Array de grupos de eventos
/*/
//---------------------------------------------------------------------
Static Function GroupFilter(aGroups)

    Local aFilEvents := {}
    Local aEvents    := {}
    Local cSSTEvt    := ""
    Local cOrgPubEvt := ""
    Local cBenOrgPEv := ""
    Local cTpSST     := "S"
    Local cTpOrgPub  := "O"
    Local lAdd       := .F.
    Local lFilSST    := .F.
    Local lFilOrgPub := .F.
    Local nX         := 0

    Default aGroups  := {}

    If !Empty(aGroups)

        aEvents    := TAFRotinas(Nil, Nil, .T., 2, lLayAtivo)
        cSSTEvt    := SSTEvt()
        cOrgPubEvt := OrgPubEvt()
        cBenOrgPEv := BenOrgPEvt()
        lFilSST    := AScan(aGroups, cTpSST) > 0
        lFilOrgPub := AScan(aGroups, cTpOrgPub) > 0

        C8E->(DBSetOrder(2))

        For nX := 1 To Len(aEvents)

            If AccessEvt(aEvents[nX])

                lAdd := .F.

                If AScan(aGroups, aEvents[nX][12]) > 0 .OR. ( AScan(aGroups, 'M') > 0 .AND. aEvents[nX][4] == 'S-3000' )

                    lAdd := .T.

                    If !lFilOrgPub .And. aEvents[nX][4] $ cBenOrgPEv
                        lAdd := .F.
                    EndIf

                Else

                    If lFilSST
                        If aEvents[nX][4] $ cSSTEvt
                            lAdd := .T.
                        EndIf
                    EndIf

                    If lFilOrgPub
                        If aEvents[nX][4] $ cOrgPubEvt .Or. aEvents[nX][4] $ cBenOrgPEv
                            lAdd := .T.
                        EndIf
                    EndIf

                EndIf

                If lAdd .And. TAFAlsInDic(aEvents[nX][3]) 
                    AAdd(aFilEvents, aEvents[nX][4])
                EndIf

            EndIf  

        Next

    EndIf
      
Return aFilEvents

//---------------------------------------------------------------------
/*/{Protheus.doc} AccessEvt
Verifica se o ususário possui acesso ao evento

@author Melkz Siqueira
@since 04/05/2022
@version 1.0
@param aEvent - Array com as informações do evento
@return lAccess - Booleano que informa se o acesso ao evento é permitido
/*/
//---------------------------------------------------------------------
Static Function AccessEvt(aEvent)

    Local cEvtsNT  := IIf(ExistFunc("TAFEvtsNT"), TAFEvtsNT(), "")
    Local lAccess  := .F.

    Default aEvent := {}

    If !Empty(aEvent)

        If !Empty(aEvent[4]) .And. !aEvent[4] $ cEvtsNT

            C8E->(DBSetOrder(2))

            If C8E->(MsSeek(xFilial("C8E") + aEvent[4])) .And. MPUserHasAccess(aEvent[20],, __cUserId)
                lAccess := .T.
            EndIf

        EndIf

    EndIf

Return lAccess

//---------------------------------------------------------------------
/*/{Protheus.doc} SSTEvt
Retorna os eventos de SST/SESMT

@author Melkz Siqueira
@since 04/05/2022
@version 1.0
@return cEvtSST - String com eventos de SST/SESMT
/*/
//---------------------------------------------------------------------
Static Function SSTEvt()

    Local cSSTEvt := "S-2210/S-2220/S-2240/S-2221"
      
Return cSSTEvt

//---------------------------------------------------------------------
/*/{Protheus.doc} OrgPubEvt
Retorna os eventos de Orgãos Públicos

@author Melkz Siqueira
@since 04/05/2022
@version 1.0
@return cOrgPubEvt - String com eventos de Orgãos Públicos
/*/
//---------------------------------------------------------------------
Static Function OrgPubEvt()

    Local cOrgPubEvt := "S-1202/S-1207"
      
Return cOrgPubEvt

//---------------------------------------------------------------------
/*/{Protheus.doc} BenOrgPEvt
Retorna os eventos de Benefícios de Orgãos Públicos

@author Melkz Siqueira
@since 04/05/2022
@version 1.0
@return cBenOrgPEv - String com eventos de Benefícios de Orgãos Públicos
/*/
//---------------------------------------------------------------------
Static Function BenOrgPEvt()

    Local cBenOrgPEv := "S-2400/S-2405/S-2410/S-2416/S-2418/S-2420"
      
Return cBenOrgPEv

//---------------------------------------------------------------------
/*/{Protheus.doc} OrderCards
    Funçao Criada para ordenação dos Cards de eventos.
    @type  Static Function
    @author Silas Gomes
    @since 21/06/2022
    @1.0
/*/
//---------------------------------------------------------------------
Static Function OrderCards(oResponse)

    Local nI        as numeric
    Local aPendente as array
    Local aItems    as array
    Local aValItem  as array

    Default oResponse   := NIL

    nI          := 0
    aPendente   := {}
    aItems      := {}
    aValItem    := {}

    If oResponse <> NIL
    
        For nI := 1 To Len(oResponse["items"])

            If ValType(oResponse["items"][nI]["status"][1]) <> 'U' .AND. oResponse["items"][nI]["status"][1]["value"] > 0
                Aadd(aPendente, oResponse["items"][nI])
            ElseIf ValType(oResponse["items"][nI]["status"][1]) <> 'U' .AND.;
                          (oResponse["items"][nI]["status"][2]["value"] > 0 .OR.;
                           oResponse["items"][nI]["status"][3]["value"] > 0 .OR.; 
                           oResponse["items"][nI]["status"][4]["value"] > 0 .OR.;
                           oResponse["items"][nI]["status"][5]["value"] > 0)
                    
                    Aadd(aValItem, oResponse["items"][nI])
            Else
                Aadd(aItems, oResponse["items"][nI])
            EndIf

        Next

        aSORT(aPendente,,, {|x, y|x["eventCode"] < y["eventCode"]})
        aSORT(aValItem,,, {|x, y|x["eventCode"] < y["eventCode"]})
        aSORT(aItems,,, {|x, y|x["eventCode"] < y["eventCode"]})

        aEval(aItems,{|x|Aadd(aValItem, x)})
        aEval(aValItem,{|x|Aadd(aPendente, x)})

        oResponse["items"] := aPendente
        
    EndIf
    
Return
