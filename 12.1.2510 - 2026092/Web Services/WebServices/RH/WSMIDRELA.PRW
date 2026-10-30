#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "WSMIDRELA.CH"

Static __oSt01 // Query com as deduções do governo
Static __oSt02 // Query com plano de saúde e reembolso médico do governo
Static __oSt03 // Query com dados de previdência complementar do governo

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  GPEreportEsocialIrrfRevenueCodes
@type			method
@description	Serviços do Relatórios de Conferência do IRRF - Dados Complementares
@author			lidio.oliveira
@since			20/10/2025
/*/
//-------------------------------------------------------------------------------------------------
WSRESTFUL GPEreportEsocialIrrfRevenueCodes DESCRIPTION STR0001 FORMAT "application/json"

WSDATA companyId			AS STRING
WSDATA period       		AS STRING
WSDATA revenueCode			AS STRING OPTIONAL
WSDATA cpf      			AS STRING OPTIONAL
WSDATA name      			AS STRING OPTIONAL
WSDATA differencesOnly		AS BOOLEAN OPTIONAL
WSDATA requestId       		AS STRING
WSDATA page       		    AS INTEGER OPTIONAL
WSDATA pageSize       		AS INTEGER OPTIONAL

WSMETHOD POST;
	DESCRIPTION STR0002; //"Serviços do Relatório de Conferência IRRF - Dados complementares"
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/?{companyId}&{period}&{revenueCode}&{cpf}&{name}&{differencesOnly}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET Status;
	DESCRIPTION STR0012; //"Método para consultar o percentual de execução do relatório";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/Status/?{companyId}&{requestId}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/Status/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET Totalizers;
	DESCRIPTION STR0015; //"Método para retonar os valores totais de IR apurado";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/Totalizers/?{companyId}&{period}&{requestId}&{differencesOnly}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/Totalizers/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET RevenueCodes;
	DESCRIPTION STR0016; //"Método para retonar a Consulta Geral dos códigos de receita";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/RevenueCodes/?{companyId}&{period}&{requestId}&{differencesOnly}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/RevenueCodes/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET EmployeesByRevenueCode;
	DESCRIPTION STR0017; //"Método para retonar a Lista dos Funcionários no código de receita";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/employeesByRevenueCode/?{companyId}&{period}&{requestId}&{differencesOnly}&{revenueCode}%{page}%{pageSize}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/employeesByRevenueCode/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET DetailsOfEmployee;
	DESCRIPTION STR0018; //"Método para retonar o detalhe dos rendimento do funcionário para o código de receita solicitado";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/detailsOfEmployee/?{companyId}&{period}&{requestId}&{differencesOnly}&{revenueCode}%{cpf}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/detailsOfEmployee/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

WSMETHOD GET ExportEmployeeDetails;
	DESCRIPTION STR0019; //"Método para retonar o detalhe dos rendimento dos funcionários (Sem Código de Receita)";
	WSSYNTAX "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/exportEmployeeDetails/?{companyId}&{period}&{requestId}&{differencesOnly}&{cpf}";
	PATH "api/rh/esocial/v1/GPEreportEsocialIrrfRevenueCodes/exportEmployeeDetails/";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} POST
@type			method
@description	Responsável por recepcionar os parâmetros e iniciar o processamento do relatório
@author			lidio.oliveira
@since			20/10/2025
@return			Id. da resuisição: requestId (string)
/*/
//-------------------------------------------------------------------------------------------------
WSMETHOD POST WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oParams   	:= JsonObject():New()
    Local oResp     	:= JsonObject():New()
    Local cBody	    	:= self:GetContent()
    Local aAmb			:= {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local cTicket   	:= ""
    Local lRet      	:= .T.
    Local lAtuDic       := .F.

    Private bError      := { |e| oError := e, Break(e) }
    Private bErrorBlock := ErrorBlock( bError )
    Private oError

    oParams:FromJSON( cBody )

    BEGIN SEQUENCE

        If fChkParam(oParams["companyId"], oParams["period"])
            fResetErrorHandler()
            fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

            //Inicialização de Ambiente
            aAmb := StrTokArr( oParams["companyId"], "|")
            If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
                fTrGrpGPE( aAmb[1], aAmb[2], "RJE", "GPE" )
            EndIf

            lAtuDic := fCkhDic()

            If lAtuDic
                //-- Gera o ticket
                cTicket := GeraTicket(cBody)

                fResetErrorHandler()
                fSetErrorHandler(EncodeUTF8(STR0009)) //"Não foi possível gerar o ticket de processamento no Protheus. "
                If !Empty(cTicket)
                    //-- inicia o processamento antes de retornar
                    fResetErrorHandler()
                    fSetErrorHandler(EncodeUTF8(STR0010)) //"Não foi possível iniciar processamento do relatório." 
                    If StartProc(cTicket)
                        oResp["requestId"] := cTicket
                        //-- faz a resposta para o frontend
                        self:SetResponse( oResp:ToJson() )
                    EndIf
                EndIf
            Else
                fSendMess(400, OemToAnsi(STR0005), .T., 400, OemToAnsi(STR0020),,)
            EndIf
        Else
            lRet := .F.
        EndIf
    
    //RECOVER
    //    lRet := .F.
    //    ErrorBlock( bErrorBlock )
    //    SetRestFault( 500, EncodeUTF8(STR0011) + CHR(13) + CHR(10) + oError:Description ) // STR0011: "Ocorreu uma falha no retorno da informação."
    END SEQUENCE

    FreeObj( oResp)
    oResp := Nil
    DelClassIntF()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fChkParam
@type           function
@description    Validação dos parâmetros obrigatórios.
@author         lidio.oliveira
@since          20/10/2025
/*/
//-------------------------------------------------------------------
Static Function fChkParam(cCompanyId, cPeriod, cRequestId, cRevenueCode, cCPF)

    Local lRet      :=	.T.
    Local cMessage  := OemToAnsi(STR0004) //"Parâmetro(s) não informado(s): "
    Local aAmb      := {}
    Local lChkPer   := IsInCallStack("POST") .Or. IsInCallStack("GET_TOTALIZERS")
    Local lChkTkt   := !IsInCallStack("POST")
    Local lChkRevC  := IsInCallStack("GET_EMPLOYEESBYREVENUECODE") .Or. IsInCallStack("GET_DETAILSOFEMPLOYEE")
    Local lChkCPF   := IsInCallStack("GET_DETAILSOFEMPLOYEE")

    Default cCompanyId      := ""
    Default cPeriod         := ""
    Default cRequestId      := ""
    Default cRevenueCode    := ""
    Default cCPF            := ""

    If Empty( cCompanyId )
        lRet := .F.
        cMessage += "companyId "
    EndIf

    If lChkPer .And. Empty( cPeriod )
        lRet := .F.
        cMessage += "period "
    EndIf

    If lChkTkt .And. Empty( cRequestId )
        lRet := .F.
        cMessage += "requestId "
    EndIf

    If lChkRevC .And. Empty( cRevenueCode )
        lRet := .F.
        cMessage += "revenueCode "
    EndIf

    If lChkCPF .And. Empty( cCPF )
        lRet := .F.
        cMessage += "cpf "
    EndIf

	If lRet
        aAmb := StrTokArr( cCompanyId, "|")
        If Len(aAmb) == 2
            If !FWFilExist(aAmb[1],aAmb[2])
		        cMessage := OemToAnsi(STR0007) + "companyId" //"Falha ao validar as informações básicas da assinatura. Informação: "
                lRet     := .F.
            EndIf
        Else
	        cMessage := OemToAnsi(STR0008) //"O parâmetro companyId deve ser informado na seguinte estrutura: EMPRESA|FILIAL Exemplo: T1|D MG 01 "
            lRet     := .F.
        EndIf
	EndIf

	If !lRet
		fSendMess(400, OemToAnsi(STR0005), .T., 400, cMessage,,)
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fCkhDic
@type           function
@description    Validação de atualizações de dicionário.
@author         lidio.oliveira
@since          20/10/2025
/*/
//-------------------------------------------------------------------
Static Function fCkhDic()

    Local lRet  := .F.

    If ChkFile("RUQ")
        lRet := .T.
    EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fSendMess
@type           function
@description    Gera as mensagens para o retorno REST/JSON
@author         lidio.oliveira
@since          20/10/2025
/*/
//-------------------------------------------------------------------
Static Function fSendMess(nCode, cMessage, lJson, nStatus, cDetailMsg, cHelpUrl, adetails)

    Local lRet		:=	.T.

	DEFAULT nCode      := 500
	DEFAULT cMessage   := STR0006 //"Erro desconhecido no processo!"
	DEFAULT lJson      := .T.
	DEFAULT nStatus    := 500
	Default cDetailMsg := STR0006 //"Erro desconhecido no processo!"
	Default cHelpUrl   := ""
	DEFAULT adetails   := {}

	SetRestFault(nCode, EncodeUTF8(OemToAnsi(cMessage)), lJson, nStatus, EncodeUTF8(OemToAnsi(cDetailMsg)), cHelpUrl, adetails)

Return lRet


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraTicket
@type			function
@description	Cria e armazena ticket para a requisição.
@author			lidio.oliveira
@since			20/10/2025
@param			cTicket		-	Ticket da requisição
/*/
//-------------------------------------------------------------------------------------------------
Static Function GeraTicket(cReqJSon)

    Local cTicket	:= FWuuId( "WSMIDRELA" )
    Local cServ		:= ""
    Local cMetodo	:= ""

    Default cReqJSon    := ""

    cServ 	:= "GPEreportEsocialIrrfRevenueCodes/IRRFInfoComplem"
    cMetodo	:= "POST"

    fGrvRU4(cTicket, cServ, cMetodo, Date(), StrTran( Time(), ":", "" ), "1", cReqJSon)

Return cTicket


//-------------------------------------------------------------------
/*/{Protheus.doc} StartProc
@type			function
@description	Inicia o processamento da requisição em um job secundário.
@author			lidio.oliveira
@since			20/10/2025
@param			cTicket		-	Ticket da requisição
/*/
//-------------------------------------------------------------------
Static Function StartProc( cTicket )

    Local lRet		:=	.T.

    Default cTicket := ""

    StartJob("MidIRComp", GetEnvServer(), .F., cEmpAnt, cFilAnt, "000000", cTicket)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MidIRComp
@type			function
@description	Processa a parte assincrona da requisição.
@author			lidio.oliveira
@since			20/10/2025
/*/
//-------------------------------------------------------------------
Function MidIRComp( xEmp, xFil, xUser, cTicket )

    Local oRequest	:= Nil
    Local lRet		:= .F.

    Default xEmp    := ""
    Default xFil    := ""
    Default xUser   := ""
    Default cTicket := ""

    //Prepara ambiente
    RPCSetType(3)
    RpcSetEnv(xEmp, xFil,,,"GPE")
    SetsDefault()

    oRequest := JsonObject():New()

    DbSelectArea("RU4")
    RU4->(DbSetOrder(1))
    If RU4->( dbSeek( xFilial( "RU4" ) + PadR( cTicket, TamSX3( "RU4_ID" )[1] ) ) )
        oRequest:FromJson( RU4->RU4_PARAMS )
        //Chama a função responsável pelo processamento do relatório
        GetIRComp( oRequest, cTicket, xEmp, xFil )
        lRet := .T.
    EndIf

    oRequest := Nil

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GetIRComp
Escopo:         IRRF - Dados Complementares
@type			function
@description	Prepara os dados filtrados no formato JSON para retornar ao front.
@author         lidio.oliveira
@since          20/10/2025
/*/
//-------------------------------------------------------------------
Static Function GetIRComp( oReq, cTicket, xEmp, xFil )

	Local aArea			:= GetArea()
    Local oTotalizers   := JsonObject():New()
    Local oTpsCRRel     := JsonObject():New()
    Local oDetCR        := JsonObject():New()
    Local oDetItem      := JsonObject():New()
    Local oTotFunc      := JsonObject():New()
    Local oFuncCR       := JsonObject():New()
    Local oFuncDet      := JsonObject():New()
    Local oIfComplDet   := JsonObject():New()
    Local oIfNoCont     := JsonObject():New()
    Local oHolders      := JsonObject():New()
    Local oReimburs     := JsonObject():New()
    Local cCodCR        := ""
    Local cCampo        := "" 
	Local nQtdItens		:= 1
    Local nSeqN3        := 1
    Local nX            := 0
    Local nY            := 0
    Local nZ            := 0
    Local lDiverg       := .F.
    Local aArqTrab		:= {}
    Local aFiliais      := {}
    Local aItensCR      := {}

	Default oReq	    := Nil
	Default cTicket	    := ""
    Default xEmp        := ""
    Default xFil        := ""
	
    Private lGrvTab     := .T.
    Private aSM0        := FWLoadSM0(.T.)   //Carrega a SM0

    If oReq:HasProperty("differencesOnly")
        lDiverg := oReq["differencesOnly"]
    EndIf

    //Carrega todas as filiais com a mesma raiz da filial solicitada:
    aFiliais := fSM0BsCNPJ(xEmp, xFil)

	//Executa função que irá buscar os dados das tabelas
	fDtIRComp(cTicket, oReq, aFiliais, @aArqTrab)

    //Os valores Totais de Desconto de IR já estão no arquivo de trabalho
    If Len(aArqTrab) > 0
        //Ajusta arquivo de trabalho se for necessário visualizar apenas os divergentes
        If lDiverg .And. !Empty(aArqTrab[2])
            fAltTrab(@aArqTrab)
        EndIf

        oTotalizers["totalIRRFCompany"] := aArqTrab[1]
        //lDiverg := oTotalizers["totalIRRFCompany"]["totalIrrfErp"] <> oTotalizers["totalIRRFCompany"]["totalIrrfRet"] 
        
        //Chama a gravação do json na tabela RU5 - totalizers 
        GrvItRes(oTotalizers:ToJson(), "000001", lDiverg, "1", "", cTicket, "0")

        oTpsCRRel["TOTALIRRFCR"]            := "totalIrrf"              //Total IR Retido - Folha + 13 Salario
        oTpsCRRel["VLRRENDTRIB"]            := "taxableIncome"          //Redimento Tributável
        oTpsCRRel["VLRRENDTRIB13"]          := "taxableIncome13"        //Rendimento Tributável 13 Salario
        oTpsCRRel["VLRPREVOFICIAL"]         := "officialPension"        //Previdência Oficial
        oTpsCRRel["VLRPREVOFICIAL13"]       := "officialPension13"      //Previdência Oficial 13 Salario
        oTpsCRRel["VLRCRMEN"]               := "withheldIncomeTax"      //IR retido
        oTpsCRRel["VLRCR13MEN"]             := "withheldIncomeTax13"    //IR Retido 13 Salario
        oTpsCRRel["VLRPARCISENTA65"]        := "exemptPortionOver65"    //Parcela Isenta 65 anos
        oTpsCRRel["VLRPARCISENTA65DEC"]     := "exemptPortionOver6513"  //Parcela Isenta 65 anos 13 Salario
        oTpsCRRel["VLRDIARIAS"]             := "dailyAllowances"        //Diárias
        oTpsCRRel["VLRAJUDACUSTO"]          := "costAid"                //Ajuda de Custo
        oTpsCRRel["VLRINDRESCONTRATO"]      := "terminationIndemnity"   //Indenização Rescisão Contrato
        oTpsCRRel["VLRABONOPEC"]            := "vacationBonus"          //Abono Pecuniário
        oTpsCRRel["VLRRENDMOLEGRAVE"]       := "seriousIllness"         //Moléstia Grave ou Acidente em Serviço
        oTpsCRRel["VLRRENDMOLEGRAVE13"]     := "seriousIllness13"       //Moléstia Grave ou Acidente em Serviço 13 Salario
        oTpsCRRel["VLRAUXMORADIA"]          := "housingAllowance"       //Auxílio Moradia
        oTpsCRRel["VLRBOLSAMEDICO"]         := "doctorScholarship"      //Bolsa Médico Residente
        oTpsCRRel["VLRBOLSAMEDICO13"]       := "doctorScholarship13"    //Bolsa Médico Residente 13 Salario
        oTpsCRRel["VLRJUROSMORA"]           := "interestOnLatePayment"  //Juros de Mora
        oTpsCRRel["VLRISENOUTROS"]          := "taxExempt"              //Rendimentos Isentos - Outros

        aItensCR    :=  oTpsCRRel:GetNames()
        nQtdItens   :=  Len(aArqTrab[2])
        
        If !Empty(aArqTrab[2])
            //Varre cada um dos CR
            For nX := 1 To Len(aArqTrab[2])
                cCodCR  := aArqTrab[2][nX]["CR"]
                oDetCR["revenueCode"] := cCodCR
                For nY := 1 To Len(aItensCR)
                    FreeObj( oDetItem )
                    oDetItem := JsonObject():New()

                    If aArqTrab[2][nX]:HasProperty(aItensCR[nY])
                        oDetItem["retValue"]    := aArqTrab[2][nX][aItensCR[nY]]["NVLRRET"]
                        oDetItem["erpValue"]    := aArqTrab[2][nX][aItensCR[nY]]["NVLRERP"]
                        oDetItem["divergent"]   := oDetItem["retValue"] <> oDetItem["erpValue"] 
                    Else
                        oDetItem["retValue"]    := 0
                        oDetItem["erpValue"]    := 0
                        oDetItem["divergent"]   := .F.
                    EndIf    
                    
                    cCampo          := oTpsCRRel[aItensCR[nY]]
                    oDetCR[cCampo]  := oDetItem
                Next nY 

                //Chama a gravação do json na tabela RU5 - revenues 
                GrvItRes(oDetCR:ToJson(), StrZero( nX, 6 ), lDiverg, "2", "", cTicket, "1", cCodCR)

                FreeObj( oDetCR )
                oDetCR := JsonObject():New()

                //Percorre a lista de funcionários do CR
                For nY := 1 To Len(aArqTrab[2][nX]["FUNCIONARIOS"])
                    FreeObj( oFuncCR )
                    FreeObj( oDetItem )
                    FreeObj( oTotFunc )
                    FreeObj( oFuncDet )
                    FreeObj( oIfComplDet )
                    FreeObj( oIfNoCont )
                    FreeObj( oHolders )
                    FreeObj( oReimburs )

                    oFuncCR     := JsonObject():New()
                    oDetItem    := JsonObject():New()
                    oTotFunc    := JsonObject():New()
                    oFuncDet    := JsonObject():New()
                    oIfComplDet := JsonObject():New()
                    oIfNoCont   := JsonObject():New()
                    oHolders    := JsonObject():New()
                    oReimburs   := JsonObject():New()

                    oFuncCR := aArqTrab[2][nX]["FUNCIONARIOS"][nY]

                    oTotFunc["cpf"]         := oFuncCR["CPF"]
                    oTotFunc["name"]        := oFuncCR["NOME"]
                    oDetItem["totalIrRet"]  := oFuncCR["NVLRRET"]
                    oDetItem["totalIrErp"]  := oFuncCR["NVLRERP"]              
                    oTotFunc["totalIr"]     := oDetItem
                    oTotFunc["divergent"]   := oDetItem["totalIrRet"] <> oDetItem["totalIrErp"]

                    //Chama a gravação do json na tabela RU5 - employeesByRevenueCode 
                    GrvItRes(oTotFunc:ToJson(), cValToChar(nX) + StrZero( nY, 5 ), lDiverg, "2", oTotFunc["cpf"], cTicket, "2", cCodCR)                

                    //Cria objeto com o detalhamento do funcionário no código de receita
                    oFuncDet["period"]          := Substr(oReq["period"], 1, 4) + "-"+ Substr(oReq["period"], 5, 2)
                    oFuncDet["name"]            := oFuncCR["NOME"]
                    oFuncDet["cpf"]             := oFuncCR["CPF"]
                    oFuncDet["divergent"]       := oFuncCR["NVLRRET"] <> oFuncCR["NVLRERP"]
                    oFuncDet["revenueCodes"]    := oFuncCR["CRS"]
                    
                    //Cria Objeto com as informações complementares
                    If oFuncCR:HasProperty("INFOCOMPLEM")
                        oIfComplDet["revenueCode"]  := cCodCR

                        //Cria o objeto "dependentDeductions" das informações complementares
                        If oFuncCR["INFOCOMPLEM"]:HasProperty("DEDDEP")
                            oIfComplDet["dependentDeductions"]  := fDeduDep(oFuncCR["INFOCOMPLEM"]["DEDDEP"])
                        EndIf

                        //Cria o objeto "alimony" das informações complementares
                        If oFuncCR["INFOCOMPLEM"]:HasProperty("PENSALIM")
                            oIfComplDet["alimony"]  := fAlimony(oFuncCR["INFOCOMPLEM"]["PENSALIM"])
                        EndIf

                        //Cria o objeto "privatePension" das informações complementares
                        If oFuncCR["INFOCOMPLEM"]:HasProperty("PREVCOMP")
                            oIfComplDet["privatePension"]  := fPrivPen(oFuncCR["INFOCOMPLEM"]["PREVCOMP"])
                        EndIf

                        oFuncDet["infoComplem"]  := oIfComplDet
                    EndIf

                    //Cria objeto healthPlan
                    If oFuncCR:HasProperty("PLANOSAUDE")
                        oHolders["holders"]     := fHolders(oFuncCR["PLANOSAUDE"])
                        oIfNoCont["healthPlan"] := oHolders 
                    EndIf

                    //Cria objeto medicalReimbursement
                    If oFuncCR:HasProperty("REEMBMEDICO")
                        oReimburs["reimbursements"]         := fReimburs(oFuncCR["REEMBMEDICO"])
                        oIfNoCont["medicalReimbursement"]   := oReimburs 
                    EndIf


                    //Cria objeto de detalhes da monthlySummary
                    For nZ := 1 To Len(aItensCR)
                        FreeObj( oDetItem )
                        oDetItem := JsonObject():New()

                        If oFuncCR:HasProperty(aItensCR[nZ])
                            oDetItem["retValue"]    := oFuncCR[aItensCR[nZ]]["NVLRRET"]
                            oDetItem["erpValue"]    := oFuncCR[aItensCR[nZ]]["NVLRERP"]
                            oDetItem["divergent"]   := oDetItem["retValue"] <> oDetItem["erpValue"] 
                        Else
                            oDetItem["retValue"]    := 0
                            oDetItem["erpValue"]    := 0
                            oDetItem["divergent"]   := .F.
                        EndIf    
                        
                        cCampo          := oTpsCRRel[aItensCR[nZ]]
                        oDetCR[cCampo]  := oDetItem
                    Next nZ
                    oIfNoCont["monthlySummary"]        := oDetCR

                    //Grava os dados do objeto infoComplemNoContract
                    oFuncDet["infoComplemNoContract"]  := oIfNoCont

                    //Chama a gravação do json na tabela RU5 - detailsOfEmployee 
                    GrvItRes(oFuncDet:ToJson(), StrZero( nSeqN3, 6 ), oTotFunc["divergent"], "2", oFuncDet["cpf"], cTicket, "3", cCodCR)
                    nSeqN3++   
                Next nY

                FreeObj( oDetCR )
                oDetCR := JsonObject():New()

                If Findfunction("SetPercent")
                    SetPercent( cTicket, nX, nQtdItens )
                EndIf            
            Next nX
        Else
            SetPercent( cTicket, 1, 1 )
        EndIf
        //Finaliza a execução do relatório
        SetFinish( cTicket )
    EndIf

	//Função utilizada para ir gravando o percentual de processamento 
	//Será executado dentro de um laço a partir do retorno de fDtIRComp()
	//Possue 50% do peso (Processamento)
    If Findfunction("SetPercent") .And. Len(aArqTrab) == 0
        SetPercent( cTicket, 1, 1 )

        //Finaliza a execução do relatório
        SetFinish( cTicket )
    EndIf

	RestArea( aArea )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} fDtIRComp
@type			function
@description	Filtra os dados de acordo com os parametros recebidos.
@author         lidio.oliveira
@since          20/10/2025
/*/
//-------------------------------------------------------------------
Static Function fDtIRComp(cTicket, oReq, aFiliais, aArqTrab)

    Local aArea		    := GetArea()
    Local oTotIRComp    := JsonObject():New()           // Armazena o total de IR Descontado (sem filtro de CR ou Funcionário)
    Local oObjCR        := JsonObject():New()           // Armazena a lista dos objetos por Código de Receita
    Local oObjCRDet     := JsonObject():New()           // Valores no código de receita
    Local oCPFDetCR     := Nil                          // Dados do CPF para o CR
    Local oTotIRCPF     := Nil                          // Total de IR para o CPF
    Local oObjPensA     := Nil                          // Objeto com os dados de pensão alimentícia
    Local oObjPrevC     := Nil                          // Objeto com os dados de previdência complementar
    Local cTSV		    := fCatTrabEFD("TSV")           // Carrega lista de categorias TSV
    Local cCNPJ         := ""                           // CNPJ em Processamento
    Local cAlias        := ""                           // Tabela temporária com dados da folha
    Local cAliasGov     := ""                           // Tabela temporária com dados da folha
    Local cCNPJAnt      := ""                           // CNPJ Processando no registro anterior
    Local cFilProc      := ""                           // Filial em Processamento
    Local cTpIRRF       := ""                           // Tipo de IRRF
    Local cCRMen        := ""                           // Código de Receita
    Local cCRMenAnt     := ""                           // Código de Receita executado
    Local cIncIRF       := ""                           // Incidência IR para o eSocial
    Local cTipoVb       := ""                           // Indentifica o tipo da verba (1-Provento,2-Desconto,3-Base Provente,4-Base Desconto)
    Local cDescontos    := ""                           // String com a lista de tipo de item que devem considerar os descontos como soma 
	Local cCPFAnt       := ""                           // CPF anterior executado
    Local cChvPosFun    := ""                           // Chave do último nPosFunc processado para não repetir o aScan
    Local cReqCR        := ""                           // String para filtro do código CR 
    Local cCodVerba     := ""                           // Código da Verba
    Local cCodNat       := ""                           // Código de Natureza
    Local cObjPl        := ""                           // Objeto para gravação dos dados de Plano de Saúde
    Local cIncIRFCP     := ""                           // Incidência IR da verba de contrapartida
    Local cCodNatCP     := ""                           // Incidência da Natureza da verba de contrapartida
    Local cTipoVbCP     := ""                           // Tipo da verba de contrapartida
    Local cFerSub       := ""                           // Código da Verba de Substituição
    Local nItem		    := 0                            // Item processado
	Local nQtdItens	    := 0                            // Quantidade Total de itens
	Local nQtdItensFOL  := 0                            // Quantidade de itens FOL
    Local nQtdItensGov  := 0                            // Quantidade de itens GOV
    Local nQtdProc      := 0                            // Quatidade de vezes que deve processar (> 1 em caso de contrapartida)
    Local nTotIRERP     := 0                            // Valor descontado de IR no ERP
    Local nTotIRGov     := 0                            // Valor descontado de IR no GOV
    Local nVlrERP       := 0                            // Valor no ERP
    Local nVlrRET       := 0                            // Valor no RET
    Local nX            := 0                            // Contador
    Local nA            := 0                            // Contador 
    Local nPosFuncPl    := 0                            // Posição do CPF no array de funcionários para o Plano de Saúde
    Local nPosFunc      := 0                            // Posição do CPF no array de funcionários
    Local aRegRendT     := {}                           // Regras para classificação como rendimento tributável
    Local aRegRendT13   := {}                           // Regras para classificação como rendimento tributável 13 Salário
    Local aRegPrev      := {}                           // Regras para classificação como previdência Oficial
    Local aRegPrev13    := {}                           // Regras para classificação como previdência Oficial 13 Salário
    Local aRegCRMen     := {}                           // Regras para classificação como previdência Oficial 13 Salário
    Local aRegCRMen13   := {}                           // Regras para classificação como previdência Oficial 13 Salário
    Local aRegIsen65    := {}                           // Regras para classificação como parcela isenta 65 anos
    Local aRegVlDia     := {}                           // Regras para classificação como valor de diárias
    Local aRegVlAjCus   := {}                           // Regras para classificação como ajuda de custo
    Local aRegIndResC   := {}                           // Regras para classificação como indenização e rescisão de contrato
    Local aRegAbonoP    := {}                           // Regras para classificação como abono pecuniário
    Local aRegMoleG     := {}                           // Regras para classificação como moléstia grave ou acidente em serviço
    Local aRegAuxMor    := {}                           // Regras para classificação como auxílio moradia
    Local aRegBolM      := {}                           // Regras para classificação como bolsa médica    
    Local aRegBolM13    := {}                           // Regras para classificação como bolsa médica - 13º salário 
    Local aRegJurosM    := {}                           // Regras para classificação como juros de mora 
    Local aRegIsenOu    := {}                           // Regras para classificação como rendimentos isentos - outros                       
    Local aInfos        := {}                           // Array com os dados do empreador (RJ9)
    Local aTotCRDet     := {}                           // Armazena os totais de IR por Código de Receita
    Local aTotCR        := {}                           // Armazena os totais de IR
    Local aCPFDetCR     := {}                           // Armazena Dados do CPF para o CR
    Local aAllCR        := {}                           // Array com todos os objetos dos código de receita encontrado
    Local aLstObj       := {}                           // Array com os objetos dos código de receita que possuem valor
    Local aReqCPF       := {}                           // Array com filtro por CPF da requisição
    Local aReqCR        := {}                           // Array com filtro por Codigo de Receita da requisição
    Local aCRsCPF       := {}                           // Array com os Códigos de Receita do CPF em processamento
    Local aIfPenAli     := {}                           // Array com os dados de pensão alimentícia
    Local adadosRHS     := {}                           // Array com os dados de plano de saúde (Origem 36B)
    Local adadosRHP     := {}                           // Array com os dados de reembolso médico (Origem 36B)
    Local aIfPlSau      := {}                           // Array com os dados de plano de saúde (Formato relatório)
    Local aIfReembM     := {}                           // Array com os dados de reembolso médico (Formato relatório)
    Local lDeduz		:= .F.                          // Indica se deve subtrair um valor
    Local lGetDed       := .T.                          // Variável que indica de deve buscar as deduções de dependentes
    Local lChkRet       := CHKFILE("RUQ")               // Verifique a existencia das tabelas do RET
    Local lTSV          := .F.                          // Identifica se o funcionário é um TSV

    Private oCR056107   := Nil                          // Objeto com os valores do código de receita 056107
    Private oCR056111   := Nil                          // Objeto com os valores do código de receita 056111
    Private oCR056112   := Nil                          // Objeto com os valores do código de receita 056112
    Private oCR056113   := Nil                          // Objeto com os valores do código de receita 056113
    Private oCR058806   := Nil                          // Objeto com os valores do código de receita 058806
    Private oCR356201   := Nil                          // Objeto com os valores do código de receita 356201
    Private oCR188901   := Nil                          // Objeto com os valores do código de receita 188901
    Private oIncIR      := JsonObject():New()           // Objeto com a Ccnsolidação dos tipos de valores de IRRF
    Private cCatEFD     := ""                           // Categoria eSocial
    Private cCat        := ""                           // Categoria eSocial (Usado pela fCodRece no GPEM036B)
    Private cClassTrib  := ""                           // Classificação tributária no S-1200
    Private cTpInfoIR   := ""                           // Consolidação dos tipos de valores relativos ao IRRF
    Private cIndApurIR  := "0"                          // Indicativo de apuração de IR
    Private cIndRRA     := "N"                          // Indicativo de apuração de RRA
    Private lResidExt   := .F.                          // Residente no exterior (Usado pela fCodRece no GPEM036B)
    Private cResidExt   := "N"                          // Residente no exterior
    Private aDedDep     := {}                           // Array com as informações de dedução de dependentes (Usado pela fCodRece no GPEM036B)
    Private cLogDep     := ""                           // Log com as informações de dependentes (Usado pela fGetRCop1210 no GPEM036B)
    Private cOrigEve    := ""                           // Identifica qual é o evento de origem
    Private aRetPensao  := {}                           // Array com dados de pensão (Utilizada ao chamar fBenefic)
    Private aInfoPrev   := {}                           // Array com dados de pensão (Utilizada ao chamar fGetPrev)

   	Default cTicket     := ""
	Default oReq        := Nil
    Default aFiliais    := {}
    Default aArqTrab    := {}
    
    //Verifica se há filtro por CPF
    If !Empty(oReq["cpf"])
        aReqCPF := StrTokArr(oReq["cpf"], "|")
    EndIf

    If !Empty(oReq["revenueCode"])
        aReqCR := StrTokArr(oReq["revenueCode"], "|")
        cReqCR := oReq["revenueCode"]
    EndIf

    //Crias Alias com os dados da folha
    cAlias := fTmpFOL(oReq, aFiliais, aReqCPF) 

    //Crias Alias com os dados do governo
    If lChkRet
        cAliasGov := fTmpGOV(oReq, aFiliais, aReqCPF, aReqCR) 
    EndIf

    //Apura a quantidade de itens para serem processados da Folha
    (cAlias)->(DbGoTop())
    If (cAlias)->( !Eof() )
	    ( cAlias )->( DBEval( { || nQtdItensFOL ++ } ) )
    EndIf

    //Apura a quantidade de itens para serem processados do Governo
    If lChkRet
        (cAliasGov)->(DbGoTop())
        If (cAliasGov)->( !Eof() )
            ( cAliasGov )->( DBEval( { || nQtdItensGov ++ } ) )
        EndIf
    EndIf

    nQtdItens := nQtdItensFOL + nQtdItensGov

    //Processa os itens da Folha
    If nQtdItensFOL > 1
        // Carrega a consolidação dos tipos de valores relativos ao IRRF
        fCarIfIR()

        //Json com os nomes dos ojetos por código de Receita
        oObjCR["056107"] := "oCR056107"
        oObjCR["056111"] := "oCR056111"
        oObjCR["056112"] := "oCR056112"
        oObjCR["056113"] := "oCR056113"
        oObjCR["058806"] := "oCR058806"
        oObjCR["356201"] := "oCR356201"
        oObjCR["188901"] := "oCR188901"
        
        // Carrega regras para classificação da verba e identificação do código de receita
        aRegRendT   := fRgRendT()
        aRegRendT13 := fRgRendT13()
        aRegPrev    := fRgPrev()
        aRegPrev13  := fRgPrev13()
        aRegCRMen   := fRgCRMen()
        aRegCRMen13 := fRgCRMen13()
        aRegIsen65  := fRgIsen65()
        aRegVlDia   := fRgVlDia()
        aRegVlAjCus := fRgVlAjCus()
        aRegIndResC := fRgIndResC()
        aRegAbonoP  := fRgAbonoP()
        aRegMoleG   := fRgMoleG()
        aRegAuxMor  := fRgAuxMor()
        aRegBolM    := fRgBolM()
        aRegBolM13  := fRgBolM13()
        aRegJurosM  := fRgJurosM()
        aRegIsenOu  := fRgIsenOu()

        //Indica os tipos onde as verbas são de desconto devem ser somadas, desta forma soma os tipos 2(Desconto) e 4(Base Desconto) 
        //e subtrai os códigos 1(Provento) e 3(Base Provento)
        cDescontos := "VLRPREVOFICIAL|VLRPREVOFICIAL13|VLRCRMEN|VLRCRMEN13|"

        (cAlias)->( dbGoTop() )

        //Varre a tabela temporária com os registros encontrados
        While (!(cAlias)->(EOF()))

            //Carrega a classificação tributária do evento S-1000
            If cFilProc <> (cAlias)->RC_FILIAL
                fPosFil(cEmpAnt, (cAlias)->RC_FILIAL)
                cCNPJ := fGetCGC(cEmpAnt, (cAlias)->RC_FILIAL, .T.)
                If cCNPJ <> cCNPJAnt
                    aInfos := fXMLInfos()
                    If Len(aInfos) > 0 
                        cClassTrib := aInfos[5]
                    EndIf
                    cCNPJAnt := cCNPJ
                EndIf
            EndIf

            //Reinicializa variáveis
            cCRMen          := ""
            cTpIRRF         := ""
            cOrigEve        := "S-1200"
            cCat            := cCatEFD
            cCodVerba       := (cAlias)->RC_PD
            cFilProc        := (cAlias)->RC_FILIAL            
            cCatEFD         := (cAlias)->RA_CATEFD
            cFerSub         := (cAlias)->RC_FERSUB
            cTipoVb         := Iif(Empty(cFerSub), (cAlias)->RV_TIPOCOD, RetValSrv(cFerSub, cFilProc, 'RV_TIPOCOD') )
            cIncIRF         := Iif(Empty(cFerSub), AllTrim((cAlias)->RV_INCIRF), AllTrim(RetValSrv(cFerSub, cFilProc, 'RV_INCIRF')))
            cCodNat         := Iif(Empty(cFerSub), AllTrim((cAlias)->RV_NATUREZ), AllTrim(RetValSrv(cFerSub, cFilProc, 'RV_NATUREZ')))
            lResidExt	    := (cAlias)->RA_CODRET == "0473"
            cResidExt       := Iif(lResidExt, "S", "N")
            aTotCRDet       := {}
            aTotCR          := {}
            lTSV            := (cCatEFD $ cTSV)
            lContinua       := .T.
            nQtdProc        := 1
            nItem++

            //Valida origem do evento
            If Substr((cAlias)->RA_DEMISSA,1 , 6) <= oReq["period"] .And. Substr((cAlias)->RA_DEMISSA,1 , 6) == (cAlias)->RC_PERIODO .And. ;
            !((cAlias)->RA_RESCRAI $ "30|31") .And. (cAlias)->TABELA == "SRR" .And. (cAlias)->RC_ROTEIR == "RES" 
                If cCatEFD == "721"
                    cOrigEve    := "S-2399"
                Else
                    cOrigEve    := "S-2299"
                EndIf
            EndIf

            //Verifica se deve considerar a verba de contrapartida das verbas que circulam na folha
            If !Empty((cAlias)->RV_CONTRAP) .And. (cAlias)->RC_ROTEIR $ "FOL|AUT" .And. Empty(cFerSub)
                nQtdProc    := 2
                cIncIRFCP   := RetValSrv((cAlias)->RV_CONTRAP, cFilProc, 'RV_INCIRF')
                cCodNatCP   := RetValSrv((cAlias)->RV_CONTRAP, cFilProc, 'RV_NATUREZ')
                cTipoVbCP   := RetValSrv((cAlias)->RV_CONTRAP, cFilProc, 'RV_TIPOCOD')                
            EndIf

            //Busca as deduções de dependente do funcionário
            If lGetDed 
                aDedDep := fDedDep(cFilProc, (cAlias)->RC_MAT, oReq["period"], .F., (cAlias)->RA_CIC)
                lGetDed := .F.
            EndIf

            //Busca as deduções de pensão alimentícia
            If nQtdProc == 1 .And. ((Val(cIncIRF ) >= 51 .And. Val(cIncIRF ) <= 55) .Or. (Val(cIncIRF ) >= 9051 .And. Val(cIncIRF ) <= 9054))
				fBenefic(cFilProc, (cAlias)->RC_MAT, (cAlias)->RC_DATA, cCodVerba, (cAlias)->RC_VALOR, /*cId*/, oReq["period"], cIncIRF, lTSV, (cAlias)->RA_CIC, cFerSub)
            EndIf

            //Busca as deduções de previdência complementar
            If (Val(cIncIRF) >= 46 .And. Val(cIncIRF) <= 48) .Or. (Val(cIncIRF) >= 61 .And. Val(cIncIRF) <= 66) .Or. (Val(cIncIRF) >= 9046 .And. Val(cIncIRF) <= 9048) .Or. ; 
             (Val(cIncIRF) >= 9061 .And. Val(cIncIRF) <= 9066) .Or. (VAL(cIncIRF ) == 9 .And. !Empty(cFerSub))
                SRA->(dbseek(cFilProc + (cAlias)->RC_MAT))
                fGetPrev( cCodVerba, oReq["period"], cIncIRF, (cAlias)->RC_VALOR, lTSV, cFerSub, cFilProc  )
            EndIf

            //Pode processar duas vezes devido possibilidade de verba de contrapartida
            For nA := 1 To nQtdProc

                //Se for a segunda execução obtém a incidência da verba de contrapartida
                If nA == 2
                    cIncIRF := RetValSrv((cAlias)->RV_CONTRAP, cFilProc, 'RV_INCIRF')
                    cCodNat := RetValSrv((cAlias)->RV_CONTRAP, cFilProc, 'RV_NATUREZ')
                    cTipoVb := RetValSrv((cAlias)->RV_CONTRAP, cFilProc, 'RV_TIPOCOD')
                EndIf

                //Carrega os dados de Plano de Saúde
                If cCodNat == '9219' .And. Empty(aDadosRHS)
                    adadosRHS := fGetPLS1210( cFilProc, (cAlias)->RC_MAT, "1", oReq["period"] + "01", oReq["period"] + "31", (cAlias)->RC_PERIODO, /*lRes*/, /*MesAno(dDtRes)*/, (cAlias)->RA_CIC )
                EndIf

                //Carrega os dados de Reembolso Médico
                If cCodNat == '1405' .And. Empty(aDadosRHP)
                    adadosRHP := fGetRCop1210( cFilProc, (cAlias)->RC_MAT , "1", oReq["period"] + "01", oReq["period"] + "31", (cAlias)->RC_PERIODO, /*lRes*/, /*MesAno(dDtRes)*/, (cAlias)->RA_CIC )
                EndIf

                //Identifica o tpInfoIR da verba
                If oIncIR:HasProperty(cIncIRF)
                    cTpInfoIR       := oIncIR[cIncIRF]
                Else
                    cTpInfoIR       := cIncIRF
                EndIf

                // Aplica as regras do rendimento tributável para encontrar o código de receita do registro
                If cTpInfoIR $ "11*12*14" //Rendimento tributável
                    If fVldRegIR(aRegRendT, @cCRMen)
                        cTpIRRF     := "VLRRENDTRIB"     
                    ElseIf fVldRegIR(aRegRendT13, @cCRMen)
                        cTpIRRF     := "VLRRENDTRIB13"
                    EndIf
                ElseIf cTpInfoIR $ "41*42" //Valor de Previdência
                    If fVldRegIR(aRegPrev, @cCRMen)
                        cTpIRRF     := "VLRPREVOFICIAL"
                    ElseIf fVldRegIR(aRegPrev13, @cCRMen)
                        cTpIRRF     := "VLRPREVOFICIAL13"
                    EndIf
                ElseIf cTpInfoIR $ "31*32*34" //Desconto de IR
                    If fVldRegIR(aRegCRMen, @cCRMen)
                        cTpIRRF     := "VLRCRMEN"
                    ElseIf fVldRegIR(aRegCRMen13, @cCRMen)
                        cTpIRRF     := "VLRCRMEN13"
                    EndIf
                ElseIf cTpInfoIR $ "70*71" //Isenção 65 anos
                    If fVldRegIR(aRegIsen65, @cCRMen)
                        cTpIRRF     := "VLRPARCISENTA65"
                    EndIf
                ElseIf cTpInfoIR == "72" //Valor relativo a diárias
                    If fVldRegIR(aRegVlDia, @cCRMen)
                        cTpIRRF     := "VLRDIARIAS"
                    EndIf
                ElseIf cTpInfoIR == "73" //Valor relativo a Ajuda de Custos
                    If fVldRegIR(aRegVlAjCus, @cCRMen)
                        cTpIRRF     := "VLRAJUDACUSTO"
                    EndIf
                ElseIf cTpInfoIR == "74" //Valor relativo a Indenização e Rescisão de Contrato
                    If fVldRegIR(aRegIndResC, @cCRMen)
                        cTpIRRF     := "VLRINDRESCONTRATO"
                    EndIf
                ElseIf cTpInfoIR == "75" //Valor relativo ao Abono Pecuniário
                    If fVldRegIR(aRegAbonoP, @cCRMen)
                        cTpIRRF     := "VLRABONOPEC"
                    EndIf   
                ElseIf cTpInfoIR $ "76*77" //Valor relativo a moléstia grave ou acidente em serviço
                    If fVldRegIR(aRegMoleG, @cCRMen)
                        cTpIRRF     := "VLRRENDMOLEGRAVE"
                    EndIf
                ElseIf cTpInfoIR == "700" //Valor relativo ao auxílio moradia
                    If fVldRegIR(aRegAuxMor, @cCRMen)
                        cTpIRRF     := "VLRAUXMORADIA"
                    EndIf 
                ElseIf cTpInfoIR == "702" //Valor relativo a bolsa médico residente
                    If fVldRegIR(aRegBolM, @cCRMen)
                        cTpIRRF     := "VLRBOLSAMEDICO"
                    EndIf 
                ElseIf cTpInfoIR == "703" //Valor relativo a bolsa médico residente - 13º salário
                    If fVldRegIR(aRegBolM13, @cCRMen)
                        cTpIRRF     := "VLRBOLSAMEDICO13"
                    EndIf
                ElseIf cTpInfoIR == "704" //Valor relativo a juros de mora
                    If fVldRegIR(aRegJurosM, @cCRMen)
                        cTpIRRF     := "VLRJUROSMORA"
                    EndIf
                ElseIf cTpInfoIR == "79" //Valor relativo aos rendimentos isentos - outros
                    If fVldRegIR(aRegIsenOu, @cCRMen)
                        cTpIRRF     := "VLRISENOUTROS"
                    EndIf                         
                EndIf

                //Descarta registro que não pertence ao código de receita processado quando há filtro
                If !Empty(cReqCR) .And. !(cCRMen $ cReqCR)
                    lContinua := .F.
                EndIF

                //Descarta verbas da rescisão que estão na folha de pagamento
                If !Empty((cAlias)->RA_DEMISSA) .And. !((cAlias)->RA_RESCRAI $ "30|31") .And. Substr((cAlias)->RA_DEMISSA,1 , 6) == (cAlias)->RC_PERIODO .And. (cAlias)->RC_ROTEIR $ "FOL|AUT"
                    lContinua := .F.
                EndIf

                If lContinua
                    
                    //Encontra o valor total de IR descontado
                    If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                        nTotIRERP += If(cTipoVb $ "1*3", (cAlias)->RC_VALOR * -1, (cAlias)->RC_VALOR)
                    EndIf

                    //Objeto com os totais do código de receita
                    If oObjCR:HasProperty(cCRMen)
                        //Verifica se deve deduzir o Valor
                        If (cTpIRRF $ cDescontos .And. cTipoVb $ "1*3") .Or. (!(cTpIRRF $ cDescontos) .And. cTipoVb $ "2*4")
                            lDeduz := .T.
                        Else
                            lDeduz := .F.
                        EndIf
                
                        nVlrERP := Iif(lDeduz, (cAlias)->RC_VALOR * -1, (cAlias)->RC_VALOR)
                        cCPFAnt := (cAlias)->RA_CIC

                        //Identifica qual objeto se refere ao código de receita encontrado e inicializa se for Nil
                        cObjCR := oObjCR[cCRMen]
                        iF &cObjCR == Nil 
                            &cObjCR := JsonObject():New() 
                        EndIf

                        //Se o tipo de rendimento já estiver carregado no objeto referente ao código de receita encontrado
                        If &cObjCR:HasProperty(cTpIRRF)
                            &cObjCR[cTpIRRF]["NVLRERP"] += nVlrERP
                                
                            //Total de dedução do IRRF por código de receita e do Funcionário
                            If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                                &cObjCR["TOTALIRRFCR"]["NVLRERP"] += nVlrERP
                            EndIf

                            //Identifica a posição do funcionário no objeto do código de receita
                            If &cObjCR:HasProperty("FUNCIONARIOS") .And. (nPosFunc == 0 .Or. ( nPosFunc > 0 .And. cChvPosFun <> (cCRMen + (cAlias)->RA_CIC)))
                                nPosFunc    := aScan(&cObjCR["FUNCIONARIOS"], { |x| x["CPF"] == (cAlias)->RA_CIC })
                                cChvPosFun  := cCRMen + (cAlias)->RA_CIC
                            EndIf

                            //Ajuste valor do IR para o CR Processado
                            If nPosFunc > 0
                                If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                                    &cObjCR["FUNCIONARIOS"][nPosFunc]["NVLRERP"] += nVlrERP
                                EndIf
                                If !(&cObjCR["FUNCIONARIOS"][nPosFunc]:HasProperty(cTpIRRF))
                                    oObjCRDet["NVLRERP"] := nVlrERP
                                    oObjCRDet["NVLRRET"] := 0
                                    aAdd(aTotCRDet, oObjCRDet)

                                    &cObjCR["FUNCIONARIOS"][nPosFunc][cTpIRRF] := aClone(aTotCRDet)[1]
                                Else
                                    &cObjCR["FUNCIONARIOS"][nPosFunc][cTpIRRF]["NVLRERP"] += nVlrERP
                                EndIf
                            Else
                                FreeObj( oCPFDetCR )
                                oCPFDetCR := JsonObject():New()

                                oCPFDetCR["CPF"]   := (cAlias)->RA_CIC

                                //Nome do Funcionário
                                If !Empty((cAlias)->RA_NSOCIAL)
                                    oCPFDetCR["NOME"]   := AllTrim((cAlias)->RA_NSOCIAL)
                                ElseIf !Empty((cAlias)->RA_NOMECMP)
                                    oCPFDetCR["NOME"]   := AllTrim((cAlias)->RA_NOMECMP)
                                Else
                                    oCPFDetCR["NOME"]   := AllTrim((cAlias)->RA_NOME)
                                EndIf
                                
                                If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                                    oCPFDetCR["NVLRERP"] := nVlrERP
                                    oCPFDetCR["NVLRRET"] := 0
                                Else
                                    oCPFDetCR["NVLRERP"] := 0
                                    oCPFDetCR["NVLRRET"] := 0                            
                                EndIf

                                oObjCRDet["NVLRERP"] := nVlrERP
                                oObjCRDet["NVLRRET"] := 0
                                aAdd(aTotCRDet, oObjCRDet)

                                //Inclui a informação do tipo de rendimento para o Funcionário
                                oCPFDetCR[cTpIRRF] := aClone(aTotCRDet)[1] 

                                //Inclui a dedução de dependente se houver
                                If Len(aDedDep) > 0
                                    aIfDedDep := fIfDedDep(aDedDep, cCRMen)
                                    If Len(aIfDedDep) > 0
                                        oCPFDetCR["INFOCOMPLEM"] := aClone(aIfDedDep)[1]
                                    EndIf
                                EndIf    

                                aAdd(&cObjCR["FUNCIONARIOS"], oCPFDetCR)

                                FreeObj( oObjCRDet )
                                oObjCRDet := JsonObject():New()

                                //Adiciona no array qual é a código de receita do funcionário
                                //Array possui - Nome do Objeto, Código de Receita, posição do funcionário no array FUNCIONARIOS            
                                aAdd(aCRsCPF, {cObjCR, cCRMen, Len(&cObjCR["FUNCIONARIOS"])})                            
                            EndIf
                        Else
                            oObjCRDet["NVLRERP"] := nVlrERP
                            oObjCRDet["NVLRRET"] := 0

                            aAdd(aTotCRDet, oObjCRDet)

                            &cObjCR["CR"]       := cCRMen
                            &cObjCR[cTpIRRF]    := aClone(aTotCRDet)[1]

                            aTotCR := aClone(aTotCRDet)

                            //Total de dedução do IRRF por código de receita
                            If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                                &cObjCR["TOTALIRRFCR"] := aTotCR[1]
                            EndIf
                        
                            FreeObj( oObjCRDet )
                            oObjCRDet := JsonObject():New()

                            //-- Dados dos CPF nos cógigos de receita
                            If cCPFAnt <> (cAlias)->RA_CIC .Or. (cCRMenAnt <> cCRMen .And. !(&cObjCR:HasProperty("FUNCIONARIOS")))
                                FreeObj( oCPFDetCR )
                                FreeObj( oTotIRCPF )
                                oCPFDetCR := JsonObject():New()
                                oTotIRCPF := JsonObject():New()
                                
                                cCPFAnt     := (cAlias)->RA_CIC
                                cCRMenAnt   := cCRMen
                                aCPFDetCR   := {}

                                oCPFDetCR["CPF"]   := (cAlias)->RA_CIC

                                //Nome do Funcionário
                                If !Empty((cAlias)->RA_NSOCIAL)
                                    oCPFDetCR["NOME"]   := AllTrim((cAlias)->RA_NSOCIAL)
                                ElseIf !Empty((cAlias)->RA_NOMECMP)
                                    oCPFDetCR["NOME"]   := AllTrim((cAlias)->RA_NOMECMP)
                                Else
                                    oCPFDetCR["NOME"]   := AllTrim((cAlias)->RA_NOMECMP)
                                EndIf
                                
                                If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                                    oCPFDetCR["NVLRERP"] := nVlrERP
                                    oCPFDetCR["NVLRRET"] := 0
                                Else
                                    oCPFDetCR["NVLRERP"] := 0
                                    oCPFDetCR["NVLRRET"] := 0
                                EndIf

                                //Inclui a informação do tipo de rendimento para o Funcionário
                                oCPFDetCR[cTpIRRF] := aClone(aTotCRDet)[1]

                                //Inclui a dedução de dependente se houver
                                If Len(aDedDep) > 0
                                    aIfDedDep := fIfDedDep(aDedDep, cCRMen)
                                    If Len(aIfDedDep) > 0
                                        oCPFDetCR["INFOCOMPLEM"] := aClone(aIfDedDep)[1]
                                    EndIf
                                EndIf                      

                                aAdd(aCPFDetCR, oCPFDetCR)

                                //Cria um array no objeto do código de receita com os dados do funcionário
                                If !(&cObjCR:HasProperty("FUNCIONARIOS")) 
                                    &cObjCR["FUNCIONARIOS"] := aClone(aCPFDetCR)
                                Else
                                    aAdd(&cObjCR["FUNCIONARIOS"], aClone(aCPFDetCR)[1])
                                EndIf

                                //Adiciona no array qual é a código de receita do funcionário
                                //Array possui - Nome do Objeto, Código de Receita, posição do funcionário no array FUNCIONARIOS            
                                aAdd(aCRsCPF, {cObjCR, cCRMen, Len(&cObjCR["FUNCIONARIOS"])})
                            Else
                                If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                                    &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["NVLRERP"] += nVlrERP
                                EndIf
                                If !(&cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]:HasProperty(cTpIRRF))
                                    &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])][cTpIRRF] := aClone(aTotCRDet)[1] 
                                EndIf
                            EndIf
                        EndIf
                    EndIf          
                EndIf

            Next nA

            (cAlias)->(dbSkip())

            //Se não for o mesmo CPF inclui para cada CPF todos os códigos de receita existente e informações complementares
            If cCPFAnt <> (cAlias)->RA_CIC
                cCRsCPF := ""
                lGetDed := .T.

                //Aglutina todos os CR's numa string
                For nX := 1 To Len(aCRsCPF)
                    cCRsCPF += aCRsCPF[nX][2] + "|"
                Next nX

                //Varre novamente o array para incluir os CR em cada objeto do funcionário
                For nX := 1 To Len(aCRsCPF)
                    cObjCR := aCRsCPF[nX,1]
                    &cObjCR["FUNCIONARIOS"][aCRsCPF[nX,3]]["CRS"] := StrTokArr(cCRsCPF, "|")
                Next nX

                //Inclui os dados de pensão alimentícia
                If Len(aRetPensao) > 0
                    aIfPenAli := fIfPenAli(aRetPensao, oReq["revenueCode"]) //Retorna array onde {{356201,oPen},{056207,oPen}}

                    //Varre o array para incluir as informações de pensão em cada objeto do funcionário
                    For nX := 1 To Len(aIfPenAli)
                        cObjCR := oObjCR[aIfPenAli[nX,1]] 
                        If &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]:HasProperty("INFOCOMPLEM") 
                            &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["INFOCOMPLEM"]["PENSALIM"] := aIfPenAli[nX,2]
                        Else
                            oObjPensA               := JsonObject():New()
                            oObjPensA["PENSALIM"]   := aIfPenAli[nX,2]
                            
                            &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["INFOCOMPLEM"] := oObjPensA
                            
                            FreeObj( oObjPensA )
                        EndIf
                    Next nX
                EndIf

                //Varre o array com dados de Plano de Saúde
                If Len(adadosRHS) > 0
                    //Fixa os dados de Plano de Saúde no CR056107 se houver
                    If "056107" $ cCRsCPF
                        cObjCR := "oCR056107"
                    EndIf
                    
                    //Retorna Array separando os dados em Titular/Dependente em objetos
                    aIfPlSau := fIfPlSau(adadosRHS)
                    
                    //Acrescenta a informação do Plano de Saúde no objeto do funcionário
                    If Len(aIfPlSau) > 0
                        &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["PLANOSAUDE"] := aIfPlSau                      
                    EndIf
                EndIf 

                //Varre o array com dados de Reembolso
                If Len(aDadosRHP) > 0
                    //Fixa os dados de Plano de Saúde no CR056107 se houver
                    If "056107" $ cCRsCPF
                        cObjCR := "oCR056107"
                    EndIf
                    
                    //Retorna Array separando os dados em Titular/Dependente em objetos
                    aIfReembM := fIfReembM(aDadosRHP)
                    
                    //Acrescenta a informação do Plano de Saúde no objeto do funcionário
                    If Len(aIfReembM) > 0
                        &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["REEMBMEDICO"] := aIfReembM                      
                    EndIf
                EndIf 

                //Varre o array com dados de previdência complementar
                If Len(aInfoPrev) > 0
                    aInfoPrev := fIfPrev(aInfoPrev, oReq["revenueCode"]) //Retorna array onde {{356201,oPen},{056207,oPen}}

                    //Varre o array para incluir as informações de pensão em cada objeto do funcionário
                    For nX := 1 To Len(aInfoPrev)
                        cObjCR := oObjCR[aInfoPrev[nX,1]] 
                        If &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]:HasProperty("INFOCOMPLEM") 
                            &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["INFOCOMPLEM"]["PREVCOMP"] := aInfoPrev[nX,2]
                        Else
                            oObjPrevC               := JsonObject():New()
                            oObjPrevC["PREVCOMP"]   := aInfoPrev[nX,2]
                            
                            &cObjCR["FUNCIONARIOS"][Len(&cObjCR["FUNCIONARIOS"])]["INFOCOMPLEM"] := oObjPrevC
                            
                            FreeObj( oObjPrevC )
                        EndIf
                    Next nX
                EndIf

                aCRsCPF     := {}
                aRetPensao  := {}
                aIfPenAli   := {}
                adadosRHS   := {}
                adadosRHP   := {}
                aIfPlSau    := {}
                aIfReembM   := {}
                aInfoPrev   := {}
            EndIf

            //Grava os primeiro 50% de peso do relatório (Preparação dos dados)
            If Findfunction("SetPercent")
                SetPercent( cTicket, nItem, nQtdItens )
            EndIf
        EndDo

        // Fecha a tabela temporária
        (cAlias)->(DBCloseArea())
    EndIf

    //Processa os itens GOV
    If nQtdItensGov > 0

        (cAliasGov)->( dbGoTop() )
        cChvPosFun := ""

        //Varre a tabela temporária com os registros encontrados
        While (!(cAliasGov)->(EOF()))

            nItem++

            //Inicializa variáveis
            cCRMen      := (cAliasGov)->RUQ_CODREC
            cTpIRRF     := AllTrim((cAliasGov)->RUQ_TPIRRF)
            nVlrRet     := (cAliasGov)->RUQ_VALOR
            cCPFAnt     := (cAliasGov)->RUQ_CPF
            aTotCRDet   := {}
            aTotCR      := {}

            //Ajusta os objetos do código de receita incluindo o valor do RET
            If oObjCR:HasProperty(cCRMen)

                cObjCR := oObjCR[cCRMen]
                iF &cObjCR == Nil 
                    &cObjCR := JsonObject():New() 
                EndIf

                //Identifica a posição do funcionário no objeto do código de receita
                If &cObjCR:HasProperty("FUNCIONARIOS") .And. (nPosFunc == 0 .Or. ( nPosFunc > 0 .And. cChvPosFun <> (cCRMen + (cAliasGov)->RUQ_CPF)))
                    nPosFunc := aScan(&cObjCR["FUNCIONARIOS"], { |x| x["CPF"] == (cAliasGov)->RUQ_CPF })
                    cChvPosFun  := cCRMen + (cAliasGov)->RUQ_CPF
                EndIf

                //Guarda os dados de qual objeto e posição do funcionário para os dados de plano de saúde
                If cObjCR $ "oCR056107|oCR058806"
                    cObjPl      := cObjCR
                    nPosFuncPl  := nPosFunc
                EndIf

                //Encontra o valor total de IR descontado
                If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                    nTotIRGov += (cAliasGov)->RUQ_VALOR
                EndIf                

                If &cObjCR:HasProperty(cTpIRRF)
                    &cObjCR[cTpIRRF]["NVLRRET"] += nVlrRet

                    //Total de dedução do IRRF por código de receita
                    If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                        &cObjCR["TOTALIRRFCR"]["NVLRRET"] += nVlrRet
                        If nPosFunc > 0
                            &cObjCR["FUNCIONARIOS"][nPosFunc]["NVLRRET"] += nVlrRet                         
                        EndIf
                    EndIf

                    //Adiciona o valor RET para o cTpIRRRF processado no objeto do Funcionário
                    If nPosFunc > 0
                        If &cObjCR["FUNCIONARIOS"][nPosFunc]:HasProperty(cTpIRRF)
                            &cObjCR["FUNCIONARIOS"][nPosFunc][cTpIRRF]["NVLRRET"] += nVlrRet
                        Else
                            oObjCRDet["NVLRERP"] := 0
                            oObjCRDet["NVLRRET"] := nVlrRet

                            &cObjCR["FUNCIONARIOS"][nPosFunc][cTpIRRF] := oObjCRDet

                            FreeObj( oObjCRDet )
                            oObjCRDet := JsonObject():New()
                        EndIf 
                    EndIf
                Else
                    oObjCRDet["NVLRERP"] := 0
                    oObjCRDet["NVLRRET"] := nVlrRet

                    aAdd(aTotCRDet, oObjCRDet)

                    &cObjCR["CR"]       := cCRMen
                    &cObjCR[cTpIRRF]    := aClone(aTotCRDet)[1]

                    aTotCR := aClone(aTotCRDet)

                    //Total de dedução do IRRF por código de receita
                    If cTpIRRF $ "VLRCRMEN|VLRCRMEN13"
                        &cObjCR["TOTALIRRFCR"] := aTotCR[1]
                    EndIf

                    //Inclui o valor RET para o cTpIRRRF processado no objeto do Funcionário
                    If nPosFunc > 0
                        &cObjCR["FUNCIONARIOS"][nPosFunc][cTpIRRF] := aTotCR[1]
                    EndIf

                    FreeObj( oObjCRDet )
                    oObjCRDet := JsonObject():New()
                EndIf
            EndIf

            (cAliasGov)->(dbSkip())

            //Se trocou a chave busca os dados das informações complementares
            If cChvPosFun <> (cCRMen + (cAliasGov)->RUQ_CPF)
                //Informações de Deduções (Dependentes e Pensão Alimentícia)
                fDeduGov(aFiliais, cCPFAnt, aReqCR)

                //Informações de Deduções de previdência complementar
                fPrevCGov(aFiliais, cCPFAnt, aReqCR)
            EndIf

            //Se trocou o CPF
            If cCPFAnt <> (cAliasGov)->RUQ_CPF .And. !Empty(cObjPl) .And. !Empty(nPosFuncPl)
                //Informações de Plano de Saúde e Reembolso Médico
                fPlSauGov(aFiliais, cCPFAnt, cObjPl, nPosFuncPl)
            EndIf

            //Grava os primeiro 50% de peso do relatório (Preparação dos dados)
            If Findfunction("SetPercent")
                SetPercent( cTicket, nItem, nQtdItens )
            EndIf
        EndDo

        // Fecha a tabela temporária
        (cAliasGov)->(DBCloseArea())
    EndIf

    //Se a quantidade de itens for maior que zero alimenta o total de IR
    If nQtdItens > 0
        oTotIRComp["totalIrrfErp"] := nTotIRERP
        oTotIRComp["totalIrrfRet"] := nTotIRGov

        aLstObj := oObjCR:GetNames()
        For nX := 1 To Len(aLstObj)
            cObjCR := oObjCR[aLstObj[nX]]
            If &cObjCR <> Nil
                aAdd(aAllCR, &cObjCR)
            EndIf
        Next nX

        aAdd(aArqTrab, oTotIRComp)
        aAdd(aArqTrab, aClone(aAllCR))
    Else
	    //Grava os primeiro 50% de peso do relatório (Preparação dos dados) se não houver dados na query
	    If Findfunction("SetPercent")
            SetPercent( cTicket, 1, 1)
        EndIf
    EndIf

    FreeObj(oCR056107)
    FreeObj(oCR056111)
    FreeObj(oCR056112)
    FreeObj(oCR056113)
    FreeObj(oCR058806)
    FreeObj(oCR356201)
    FreeObj(oCR188901)

	RestArea( aArea )

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} Status
@type			method
@description	Método para consultar o percentual de execução do relatório.
@author			lidio.oliveira
@since			20/10/2025
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET Status QUERYPARAM companyId, requestId WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oResponse		:= Nil
    Local aAmb		    := {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local lRet			:= .T.

    If fChkParam(self:companyId, , self:requestId)
        fResetErrorHandler()
        fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

        //Inicialização de Ambiente
        aAmb := StrTokArr( self:companyId, "|")
        If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
            fTrGrpGPE( aAmb[1], aAmb[2], "RU4", "GPE" )
        EndIf

        If ValidID(self:requestId)
            GetStatus( @oResponse, self:requestId)
            self:SetResponse( oResponse:toJson() )
        Else
            //"Ocorreu uma falha no retorno da informação."
            //"A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe."
            fSendMess(400, OemToAnsi(STR0011), .T., 400, OemToAnsi(STR0013) + self:requestId + OemToAnsi(STR0014),,) 
            lRet := .F.
        EndIf
    Else
        lRet := .F.            
    EndIf

    oResponse := Nil
    FreeObj( oResponse )
    DelClassIntF()

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} Totalizers
@type			method
@description	Método para retonar os valores totais de IR apurado
@author			lidio.oliveira
@since			07/11/2025
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET Totalizers QUERYPARAM companyId, period, requestId, differencesOnly WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oResponse		:= Nil
    Local aAmb		    := {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local lRet			:= .T.
    Local lDiverg       := .F.
    Local cRequestID    := ""

    cRequestID := self:requestId

    If fChkParam(self:companyId, self:period, cRequestID)
        fResetErrorHandler()
        fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

        //Inicialização de Ambiente
        aAmb := StrTokArr( self:companyId, "|")
        If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
            fTrGrpGPE( aAmb[1], aAmb[2], "RU5", "GPE" )
        EndIf

        If self:differencesOnly <> Nil
            lDiverg := self:differencesOnly
        EndIf  

        If ValidID(cRequestID)
            GetReport( @oResponse, cRequestID, .T., lDiverg, "0")
            self:SetResponse( oResponse:toJson() )
        Else
            //"Ocorreu uma falha no retorno da informação."
            //"A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe."
            fSendMess(400, OemToAnsi(STR0011), .T., 400, OemToAnsi(STR0013) + self:requestId + OemToAnsi(STR0014),,) 
            lRet := .F.
        EndIf
    Else
        lRet := .F.            
    EndIf

    oResponse := Nil
    FreeObj( oResponse )
    DelClassIntF()

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} RevenueCodes
@type			method
@description	Método para retonar os valores totais de IR apurado
@author			lidio.oliveira
@since			07/11/2025
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET RevenueCodes QUERYPARAM companyId, period, requestId, differencesOnly, cpf WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oResponse		:= Nil
    Local aAmb		    := {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local lRet			:= .T.
    Local lDiverg       := .F.
    Local cRequestID    := ""
    
    cRequestID := self:requestId

    If fChkParam(self:companyId, self:period, cRequestID)
        fResetErrorHandler()
        fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

        //Inicialização de Ambiente
        aAmb := StrTokArr( self:companyId, "|")
        If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
            fTrGrpGPE( aAmb[1], aAmb[2], "RU5", "GPE" )
        EndIf

        If self:differencesOnly <> Nil
            lDiverg := self:differencesOnly
        EndIf  

        If ValidID(cRequestID)
            GetReport( @oResponse, cRequestID, .F., lDiverg, "1")
            self:SetResponse( oResponse:toJson() )
        Else
            //"Ocorreu uma falha no retorno da informação."
            //"A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe."
            fSendMess(400, OemToAnsi(STR0011), .T., 400, OemToAnsi(STR0013) + self:requestId + OemToAnsi(STR0014),,) 
            lRet := .F.
        EndIf
    Else
        lRet := .F.            
    EndIf

    oResponse := Nil
    FreeObj( oResponse )
    DelClassIntF()

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} GetReport
@type			function
@description	Executa a consulta do resultado do relatório de conferência de INSS.
@author			lidio.oliveira
@since			18/11/2025
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
@param			lSynthetic	-	Indica se o retorno deve ser sintético ou analítico
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			cNivel	    -	Nivel para pesquisa
@param			cCPF	    -	CPF para pesquisa
@param			cCodRec	    -	Código de Receita
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
/*/
//---------------------------------------------------------------------
Static Function GetReport( oResponse, cRequestID, lSynthetic, lDiverg, cNivel, cCPF, cCodRec, nPage, nPageSize )

    Local lHasNext      := .F.
    Local aJson         := {}
    Local aEvenue       := {}
    Local oJson         := Nil

    Default oResponse   := Nil
    Default cRequestID  := ""
    Default lSynthetic  := .F.
    Default lDiverg     := .F.
    Default cNivel      := "0"
    Default cCPF        := ""
    Default cCodRec     := ""
    Default nPage       := 1
    Default nPageSize   := 100

    oResponse := JsonObject():New()
    oJson     := JsonObject():New()

    If lSynthetic
        //RU5_FILIAL+RU5_ID+RU5_TIPO+RU5_DIVERG+RU5_NIVEL
        RU5->( DBSetOrder( 2 ) )
        If RU5->( dbSeek( xFilial( "RU5" ) + cRequestID + "1" + Iif( lDiverg, "1", "2" ) + cNivel) )
            If cNivel == "0"
                oJson:FromJson( RU5->RU5_RESP )
                aAdd( aJson, oJson )
                oResponse["items"] := aJson
            EndIf
        EndIf
    Else
        aJson := Getdetails( cRequestID, lDiverg, nPage, nPageSize, cCPF, cNivel, cCodRec, @lHasNext)
        If cNivel == "1"
            oJson["evenue"]         := aJson
            aAdd(aEvenue, oJson)
        EndIf
        oResponse["hasNext"]	:= lHasNext
        oResponse["items"]		:= Iif(cNivel == "1", aEvenue, aJson)
    EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} Getdetails
@type			function
@description	Retorna os registros analíticos com controle de paginação.
@author			lidio.oliveira
@since			18/11/2025
@param			cRequestID	-	Identificador da Requisição
@param			lDiverg		-	Indica se deve retornar apenas as divergências
@param			nPage		-	Identificador da página solicitada
@param			nPageSize	-	Identificador do total de registros retornados
@param			cCPF	    -	CPF para pesquisa
@param			cNivel	    -	Nivel para pesquisa
@param			cCodRec	    -	Código de Receita
@param			lHasNext	-	Indica se há existência de mais registros além dos retornados ( Referência )
@return			aJson		-	Json com o resultado processado para o relatório
/*/
//---------------------------------------------------------------------
Static Function Getdetails( cRequestID, lDiverg, nPage, nPageSize, cCPF, cNivel, cCodRec, lHasNext )

    Local oJson			:= Nil
    Local cNextAlias	:= GetNextAlias()
    Local nRegIni		:= 0
    Local nRegFim		:= 0
    Local aJson			:= {}
    Local cWhere		:= ""
    Local cBanco		:= TcGetDb()

    Default cRequestID  := ""
    Default lDiverg     := .F.
    Default nPage       := 1
    Default nPageSize   := 100
    Default cCPF		:= ""
    Default cNivel		:= ""
    Default cCodRec     := ""
    Default lHasNext    := .F.

    If lDiverg
        cWhere := " RU5.RU5_DIVERG = '1' "
    Else
        cWhere := " RU5.RU5_DIVERG IN ('1', '2') "
    EndIf

    If !Empty(cCPF)
        cWhere += " AND RU5.RU5_CPF = '"+ cCPF +"' "
    EndIf

    If !Empty(cNivel)
        cWhere += " AND RU5.RU5_NIVEL = '"+ cNivel +"' "
    EndIf

    If !Empty(cCodRec)
        cWhere += " AND RU5.RU5_CODREC = '"+ cCodRec +"' "
    EndIf

    cWhere	:= "%" + cWhere + "%"

    nRegIni := IIf(cBanco != "OPENEDGE", ((nPage - 1) * nPageSize) + 1, (nPage - 1) * nPageSize)
    nRegFim := nPage * nPageSize

    BeginSQL Alias cNextAlias
        
        SELECT * FROM (
            SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER, R_E_C_N_O_ RU5_RECNO
                FROM %table:RU5% RU5
                WHERE RU5.RU5_FILIAL = %xFilial:RU5%
                    AND RU5.RU5_ID = %exp:cRequestID%
                    AND %exp:cWhere%
                    AND RU5.%notdel%
            ) TAB
            WHERE LINE_NUMBER BETWEEN %exp:nRegIni% AND %exp:nRegFim%
        EndSQL

        While ( cNextAlias )->( !Eof() )
            RU5->( DBGoTo( ( cNextAlias )->RU5_RECNO ) )

            If ( lDiverg .and. RU5->RU5_DIVERG == "1" ) .Or. !lDiverg
                oJson := JsonObject():New()
                oJson:FromJson( RU5->RU5_RESP )
                aAdd( aJson, oJson )
                FreeObj( oJson )
            EndIf

            ( cNextAlias )->( DBSkip() )
        EndDo

    ( cNextAlias )->( DBCloseArea() )

    lHasNext := HasNextTab(cRequestID, nRegFim, lDiverg, cNivel, cCodRec)

Return aJson 


//---------------------------------------------------------------------
/*/{Protheus.doc} HasNextTab
@type			function
@description	Retorna se há uma nova página de acordo com os parâmetros informados.
@author			lidio.oliveira
@since			18/11/2025
@param			cRequestID	-	Identificador da Requisição
@param			nRegFim		-	Identificador do último registro retornado
@param			lOnlyDif	-	Indica se é para filtrar somente os registros com diferências
@param			cNivel  	-	Filtro no campo RU5_NIVEL
@param			cCodRec	    -	Código de Receita
@return			lHasNext	-	Indica se há existência de mais registros além dos retornados
/*/
//---------------------------------------------------------------------
Static Function HasNextTab(cRequestID, nRegFim, lOnlyDif, cNivel, cCodRec)

	Local cWhere	:= ""
	Local cBanco	:= TcGetDb()
	Local cAliasMax	:= GetNextAlias()
	Local lHasNext	:= .F.

    Default cRequestID  := ""
    Default nRegFim     := 0
    Default lOnlyDif    := .F.
    Default cNivel      := "0"
    Default cCodRec     := ""

	If lOnlyDif
		cWhere := " RU5.RU5_DIVERG = '1' "
	Else
		cWhere := " RU5.RU5_DIVERG IN ('1', '2') "
	EndIf

	cWhere += " AND RU5.RU5_NIVEL = '" + cNivel + "' "

    If !Empty(cCodRec)
        cWhere += " AND RU5.RU5_CODREC = '"+ cCodRec +"' "
    EndIf

	cWhere	:= "%" + cWhere + "%"

	If cBanco != "OPENEDGE"
		BeginSQL Alias cAliasMax
			SELECT MAX(LINE_NUMBER) MAX_LINE FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY R_E_C_N_O_) LINE_NUMBER
				FROM %table:RU5% RU5
				WHERE RU5.RU5_FILIAL = %xFilial:RU5%
					AND RU5.RU5_ID = %exp:cRequestID%
					AND RU5.RU5_TIPO = '2'
					AND %Exp:cWhere%
					AND RU5.%notdel%
			) TAB
		EndSQL

		( cAliasMax )->( DBGoTop() )

		If ( cAliasMax )->( !Eof() )
			If ( cAliasMax )->MAX_LINE > nRegFim
				lHasNext := .T.
			EndIf
		EndIf

		( cAliasMax )->( DBCloseArea() )
	EndIf

Return lHasNext


//---------------------------------------------------------------------
/*/{Protheus.doc} ValidID
@type			function
@description	Verifica se o Identificador da Requisição é válido.
@author			lidio.oliveira
@since			22/10/2025
@param			cRequestID	-	Identificador da Requisição
@return			lRet		-	Indica se o Identificador da Requisição é válido
/*/
//---------------------------------------------------------------------
Static Function ValidID( cRequestID )

    Local lRet  := .F.

    Default cRequestID := ""

    DBSelectArea( "RU4" )
    RU4->( DBSetOrder( 1 ) )
    If RU4->( MsSeek( xFilial( "RU4" ) + cRequestID ) )
        lRet  := .T.
    EndIf

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} GetStatus
@type			function
@description	Executa a consulta do percentual de execução do relatório.
@author			lidio.oliveira
@since			22/10/2025
@param			oResponse	-	Json com os valores do relatório totalizador
@param			cRequestID	-	Identificador da Requisição
/*/
//---------------------------------------------------------------------
Static Function GetStatus( oResponse, cRequestID )

    Local aArea			:= GetArea()

    Default oResponse   := JsonObject():New()
    Default cRequestID  := ""

    DBSelectArea( "RU4" )
    RU4->( DBSetOrder( 1 ) )
    If RU4->( dbSeek( xFilial( "RU4" ) + cRequestID ) )
        oResponse["percent"] :=	RU4->RU4_PERC
        If RU4->RU4_PERC == 100
            oResponse["finished"] := .T.
        Else
            oResponse["finished"] := .F.
        EndIf
    EndIf

    RestArea(aArea)

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} fTmpFOL
@type			function
@description	Cria alias com dados da folha
@author			lidio.oliveira
@since			05/11/2025
@return			
/*/
//---------------------------------------------------------------------
Static Function fTmpFOL(oReq, aFiliais, aReqCPF)

    Local oStatement    := Nil
    Local cQuery        := ""
    Local cAlias        := ""
    Local nParamOrder   := 1
    Local aPdDtRef      := {}

    Default oReq        := Nil
    Default aFiliais    := {}
    Default aReqCPF     := {}

    //Carrega lista de verbas que devem considerar o campo _DTREF
    aPdDtRef := fGetVbRef()

    cQuery := "SELECT "
    cQuery +=     "RC_FILIAL, "
    cQuery +=     "RC_MAT, "
    cQuery +=     "RC_ROTEIR, "
    cQuery +=     "RC_VALOR, "
    cQuery +=     "RV_INCIRF, "
    cQuery +=     "RC_PD, "
    cQuery +=     "RC_PROCES, "
    cQuery +=     "RC_PERIODO, "
    cQuery +=     "RC_DATA, "
    cQuery +=     "RC_SEMANA, "
    cQuery +=     "TABELA, "
    cQuery +=     "RA_NOME, "
    cQuery +=     "RA_NOMECMP, "
    cQuery +=     "RA_NSOCIAL, "
    cQuery +=     "RA_CATEFD, "
    cQuery +=     "RA_CODUNIC, "
    cQuery +=     "RA_CIC, "
    cQuery +=     "RA_DEMISSA, "
    cQuery +=     "RA_SITFOLH, "
    cQuery +=     "RA_RESCRAI, "
    cQuery +=     "RA_CODRET, "
    cQuery +=     "RG_TIPORES, "
    cQuery +=     "RG_RESCDIS, "
    cQuery +=     "RG_DTGERAR, "
    cQuery +=     "SRA.R_E_C_N_O_ RECNO_SRA, "
    cQuery +=     "RV_TIPOCOD, "
    cQuery +=     "RV_CONTRAP, "
    cQuery +=     "RV_CODFOL, "
    cQuery +=     "RV_NATUREZ, "
    cQuery +=     "RC_FERSUB "
    cQuery += "FROM "
    cQuery +=     RetSQLName("SRA") + " SRA "
    cQuery +=     "LEFT JOIN "
    cQuery +=         "( "
    cQuery +=             "SELECT "
    cQuery +=                 "RC_FILIAL, "
    cQuery +=                 "RC_MAT, "
    cQuery +=                 "RC_ROTEIR, "
    cQuery +=                 "RC_VALOR, "
    cQuery +=                 "RV_INCIRF, "
    cQuery +=                 "RC_PD, "
    cQuery +=                 "RC_PROCES, "
    cQuery +=                 "RC_PERIODO, "
    cQuery +=                 "RC_DATA, "
    cQuery +=                 "RC_SEMANA, "
    cQuery +=                 "? AS RR_DATA, " // " "
    cQuery +=                 "'SRC' AS TABELA, "
    cQuery +=                 "RV_TIPOCOD, "
    cQuery +=                 "RV_CONTRAP, "
    cQuery +=                 "RV_CODFOL, "
    cQuery +=                 "RV_NATUREZ, "
    cQuery +=                 "RC_FERSUB "
    cQuery +=             "FROM "
    cQuery +=                 RetSQLName("SRC") + " SRC "
    cQuery +=                 "INNER JOIN "
    cQuery +=                     RetSQLName("SRV") + " SRV "
    cQuery +=                     "ON "
    cQuery +=                         FwJoinFilial("SRV", "SRC") + " "
    cQuery +=                         "AND RV_COD = RC_PD "
    cQuery +=                         "AND RV_INCIRF NOT IN (?) "   // {" ", "09"," 9","9"}
    cQuery +=                         "AND SRV.D_E_L_E_T_ = ? "     // " "
    cQuery +=             "WHERE "
    cQuery +=                 "RC_FILIAL IN (?) "                   // aFiliais
    cQuery +=                 "AND ((RC_PD NOT IN (?) AND RC_DATA BETWEEN ? AND ?) OR "        // oReq["period"]
    cQuery +=                       "(RC_PD IN (?) AND RC_DTREF BETWEEN ? AND ? ))"       
                                // Ignora verba se existir RHH para ela
    cQuery +=                 "AND NOT EXISTS (SELECT 1 FROM " + RetSQLName("RHH") + " RHH WHERE " + FwJoinFilial("RHH", "SRC") + " AND RHH_MAT = RC_MAT AND RHH_MESANO = RC_PERIODO AND RHH_VERBA = RC_PD AND RHH.D_E_L_E_T_ = ?) " // " "
    cQuery +=                 "AND SRC.D_E_L_E_T_ = ? "          // " "
    cQuery +=             "UNION "
    cQuery +=             "SELECT "
    cQuery +=                 "RD_FILIAL, "
    cQuery +=                 "RD_MAT, "
    cQuery +=                 "RD_ROTEIR, "
    cQuery +=                 "RD_VALOR, "
    cQuery +=                 "RV_INCIRF, "
    cQuery +=                 "RD_PD, "
    cQuery +=                 "RD_PROCES, "
    cQuery +=                 "RD_PERIODO, "
    cQuery +=                 "RD_DATPGT, "        
    cQuery +=                 "RD_SEMANA, "
    cQuery +=                 "? AS RR_DATA, " // " "
    cQuery +=                 "'SRD' AS TABELA, "
    cQuery +=                 "RV_TIPOCOD, "
    cQuery +=                 "RV_CONTRAP, "
    cQuery +=                 "RV_CODFOL, "
    cQuery +=                 "RV_NATUREZ, "
    cQuery +=                 "RD_FERSUB " 
    cQuery +=             "FROM "
    cQuery +=                 RetSQLName("SRD") + " SRD "
    cQuery +=                 "INNER JOIN "
    cQuery +=                     RetSQLName("SRV") + " SRV "
    cQuery +=                     "ON "
    cQuery +=                         FwJoinFilial("SRV", "SRD") + " "
    cQuery +=                         "AND RV_COD = RD_PD "
    cQuery +=                         "AND RV_INCIRF NOT IN (?) " // {" ", "09"," 9","9"}
    cQuery +=                         "AND SRV.D_E_L_E_T_ = ? "    // " "
    cQuery +=             "WHERE "
    cQuery +=                 "RD_FILIAL IN (?) "                       // aFiliais
    cQuery +=                 "AND ((RD_PD NOT IN (?) AND RD_DATPGT BETWEEN ? AND ?) OR " 
    cQuery +=                       "(RD_PD IN (?) AND RD_DTREF BETWEEN ? AND ? ))"                     // oReq["period"]
    cQuery +=                 "AND (RD_EMPRESA = ? OR RD_EMPRESA = ?) " // " " | cEmpAnt
                                // Ignora verba se existir RHH para ela
    cQuery +=                 "AND NOT EXISTS (SELECT 1 FROM " + RetSQLName("RHH") + " RHH WHERE " + FwJoinFilial("RHH", "SRD") + " AND RHH_MAT = RD_MAT AND RHH_MESANO = RD_PERIODO AND RHH_VERBA = RD_PD AND RHH.D_E_L_E_T_ = ?) " // " "
    cQuery +=                 "AND SRD.D_E_L_E_T_ = ? "                 // " "
    cQuery +=             "UNION "
    cQuery +=             "SELECT "
    cQuery +=                 "RHH_FILIAL, "
    cQuery +=                 "RHH_MAT, "
    cQuery +=                 "RHH_ROTEIR, "
    cQuery +=                 "RHH_VALOR, "
    cQuery +=                 "RV_INCIRF, "
    cQuery +=                 "RHH_VERBA, "
    cQuery +=                 "RHH_PROCES, "
    cQuery +=                 "RHH_MESANO, "
    cQuery +=                 "RHH_DTPGT, "        
    cQuery +=                 "RHH_SEMANA, "
    cQuery +=                 "? AS RR_DATA, " // " "
    cQuery +=                 "'RHH' AS TABELA, "
    cQuery +=                 "RV_TIPOCOD, "
    cQuery +=                 "RV_CONTRAP, "
    cQuery +=                 "RV_CODFOL, "
    cQuery +=                 "RV_NATUREZ, "
    cQuery +=                 "RHH_VB "  
    cQuery +=             "FROM "
    cQuery +=                 RetSQLName("RHH") + " RHH "
    cQuery +=                 "INNER JOIN "
    cQuery +=                     RetSQLName("SRV") + " SRV "
    cQuery +=                     "ON "
    cQuery +=                         FwJoinFilial("SRV", "RHH") + " "
    cQuery +=                         "AND RV_COD = RHH_VB "
    cQuery +=                         "AND RV_INCIRF NOT IN (?) " // {" ", "09"," 9","9"}
    cQuery +=                         "AND SRV.D_E_L_E_T_ = ? "    // " "
    cQuery +=             "WHERE  "
    cQuery +=                 "RHH_FILIAL IN (?) "          // aFiliais
    cQuery +=                 "AND RHH_MESANO = ? "         // oReq["period"]
    cQuery +=                 "AND RHH_INTEGR = ? "         // "S"
    cQuery +=                 "AND RHH_VB != ? "            // "000"
    cQuery +=                 "AND RHH.D_E_L_E_T_ = ? "     // " "
    cQuery +=             "UNION "
    cQuery +=             "SELECT "
    cQuery +=                 "RR_FILIAL, "
    cQuery +=                 "RR_MAT, "
    cQuery +=                 "RR_ROTEIR, "
    cQuery +=                 "RR_VALOR, "
    cQuery +=                 "RV_INCIRF, "
    cQuery +=                 "RR_PD, "
    cQuery +=                 "RR_PROCES, "
    cQuery +=                 "RR_PERIODO, "
    cQuery +=                 "RR_DATAPAG, "
    cQuery +=                 "RR_SEMANA, "
    cQuery +=                 "RR_DATA, "
    cQuery +=                 "'SRR' AS TABELA, "
    cQuery +=                 "RV_TIPOCOD, "
    cQuery +=                 "RV_CONTRAP, "
    cQuery +=                 "RV_CODFOL, "
    cQuery +=                 "RV_NATUREZ, "
    cQuery +=                 "RR_FERSUB "
    cQuery +=             "FROM "
    cQuery +=                 RetSQLName("SRR") + " SRR "
    cQuery +=                 "INNER JOIN "
    cQuery +=                     RetSQLName("SRV") + " SRV "
    cQuery +=                     "ON "
    cQuery +=                         FwJoinFilial("SRV", "SRR") + " "
    cQuery +=                         "AND RV_COD = RR_PD "
    cQuery +=                         "AND (RV_INCIRF NOT IN (?) OR RR_FERSUB <> ' ')" // {" ", "09"," 9","9"}
    cQuery +=                         "AND SRV.D_E_L_E_T_ = ? "    // " "
    cQuery +=             "WHERE "
    cQuery +=                 "RR_FILIAL IN (?) "                   //aFiliais
    cQuery +=                 "AND RR_DATAPAG BETWEEN ? AND ? "        // oReq["period"]
                                // Ignora verba se existir RHH para ela
    cQuery +=                 "AND NOT EXISTS (SELECT 1 FROM " + RetSQLName("RHH") + " RHH WHERE " + FwJoinFilial("RHH", "SRR") + " AND RHH_MAT = RR_MAT AND RHH_MESANO = RR_PERIODO AND RHH_VERBA = RR_PD AND RHH.D_E_L_E_T_ = ?) " // " "
    cQuery +=                 "AND SRR.D_E_L_E_T_ = ? "    // " "
    cQuery +=         ") SRC "
    cQuery +=         "ON "
    cQuery +=             FwJoinFilial("SRC", "SRA") + " "
    cQuery +=             "AND RC_MAT = RA_MAT "
    cQuery +=     "LEFT JOIN "
    cQuery +=         RetSQLName("SRG") + " SRG "
    cQuery +=         "ON "
    cQuery +=             FwJoinFilial("SRG", "SRC") + " "
    cQuery +=             "AND RG_MAT = RC_MAT "
    cQuery +=             "AND RG_DTGERAR = RR_DATA "
    cQuery +=             "AND TABELA = ? " // "SRR"
    cQuery +=             "AND SRG.D_E_L_E_T_ = ? "    // " "
    cQuery += "WHERE "
    cQuery +=     "RA_FILIAL IN (?) "      // "aFiliais"
    cQuery +=     "AND RA_CODUNIC BETWEEN ? AND ? " // " " | "999"
    If Len(aReqCPF) > 0 
        cQuery +=     "AND RA_CIC IN (?) "          // aReqCPF
    EndIf
    If oReq:HasProperty("name")  .And. !Empty(oREQ["name"])
        cQuery +=     "AND ( RA_NOME LIKE ? OR RA_NOMECMP LIKE ? OR RA_NSOCIAL LIKE ? ) " 
    EndIf
    cQuery +=     "AND RA_MAT BETWEEN ? AND ? " // cEmployeeCodeFrom | cEmployeeCodeTo
    cQuery +=     "AND RC_FILIAL != ? "         // " "
    cQuery +=     "AND SRA.D_E_L_E_T_ = ? "     // " "
    cQuery += "ORDER BY "
    cQuery +=     "RA_CIC, "
    cQuery +=     "RV_INCIRF "
    cQuery := ChangeQuery(cQuery)

    // Instancia a classe
    oStatement := FwExecStatement():New(cQuery)

    // INÍCIO - Definições dos valores dos parâmetros - SRC
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, {" ", "09"," 9","9"})
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, aFiliais)
    oStatement:SetIN(nParamOrder++, aPdDtRef)
    oStatement:SetString(nParamOrder++, oReq["period"] + "01")
    oStatement:SetString(nParamOrder++, DToS(lastDay(SToD(oReq["period"] + "01"))))
    oStatement:SetIN(nParamOrder++, aPdDtRef)
    oStatement:SetString(nParamOrder++, oReq["period"] + "01")
    oStatement:SetString(nParamOrder++, DToS(lastDay(SToD(oReq["period"] + "01"))))
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, " ")

    // INÍCIO - Definições dos valores dos parâmetros - SRD
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, {" ", "09"," 9","9"})
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, aFiliais)
    oStatement:SetIN(nParamOrder++, aPdDtRef)
    oStatement:SetString(nParamOrder++, oReq["period"] + "01")
    oStatement:SetString(nParamOrder++, DToS(lastDay(SToD(oReq["period"] + "01"))))
    oStatement:SetIN(nParamOrder++, aPdDtRef)
    oStatement:SetString(nParamOrder++, oReq["period"] + "01")
    oStatement:SetString(nParamOrder++, DToS(lastDay(SToD(oReq["period"] + "01"))))
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, cEmpAnt)
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, " ")

    // INÍCIO - Definições dos valores dos parâmetros - RHH
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, {" ", "09"," 9","9"})
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, aFiliais)
    oStatement:SetString(nParamOrder++, oReq["period"])
    oStatement:SetString(nParamOrder++, "S")
    oStatement:SetString(nParamOrder++, "000")
    oStatement:SetString(nParamOrder++, " ")

    // INÍCIO - Definições dos valores dos parâmetros - SRR
    oStatement:SetIN(nParamOrder++, {" ", "09"," 9","9"})
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetIN(nParamOrder++, aFiliais)
    oStatement:SetString(nParamOrder++, oReq["period"] + "01")
    oStatement:SetString(nParamOrder++, DToS(lastDay(SToD(oReq["period"] + "01"))))
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, " ")

    // INÍCIO - Definições dos parâmetros do join da subquery com a SRG
    oStatement:SetString(nParamOrder++, "SRR")
    oStatement:SetString(nParamOrder++, " ")

    // INÍCIO - Definições dos parâmetros para a SRA
    oStatement:SetIN(nParamOrder++, aFiliais)
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, "ZZZZZZZZZZZZZZZZZZZZZ")
    If Len(aReqCPF) > 0
        oStatement:SetIN(nParamOrder++, aReqCPF)
    EndIf
    If oReq:HasProperty("name") .And. !Empty(oREQ["name"])
        oStatement:SetString(nParamOrder++, "%" + oREQ["name"]  + "%")    //Nome
        oStatement:SetString(nParamOrder++, "%" + oREQ["name"]  + "%")    //Nome  
        oStatement:SetString(nParamOrder++, "%" + oREQ["name"]  + "%")    //Nome    
    EndIf
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, "ZZZZZZZZZ")
    oStatement:SetString(nParamOrder++, " ")
    oStatement:SetString(nParamOrder++, " ")

    // Executa a query e retorna o alias criado
    cAlias := oStatement:OpenAlias()   

Return cAlias


//---------------------------------------------------------------------
/*/{Protheus.doc} fGetVbRef()
Retorna array com lista de verbas para consulta do campo _DTREF
@author lidio.oliveira
@since 02/12/2025
@Return.....: (array) - aRet    - Lista de Verbas
/*/
//---------------------------------------------------------------------
Static Function fGetVbRef()

	Local aArea     := GetArea()
    Local aCodFol   := {}
    Local aRet      := {}
    
    fp_CodFol( @aCodFol, xFilial('SRV', cFilAnt) )

    If Len(aCodFol) > 0
        aAdd(aRet, aCodFol[1893][1]) //Informativo dedução IRRF Ferias
        aAdd(aRet, aCodFol[1723][1]) //Informativa da Dedução INSS Base IR Férias
        aAdd(aRet, aCodFol[1562][1]) //Base de IRRF Férias s/ desconto 
    EndIF

    RestARea(aArea)

Return aRet


//---------------------------------------------------------------------
/*/{Protheus.doc} fTmpGOV
@type			function
@description	Cria alias com dados do RET
@author			lidio.oliveira
@since			05/11/2025
@return			
/*/
//---------------------------------------------------------------------
Static Function fTmpGOV(oReq, aFiliais, aReqCPF, aReqCR)

    Local oQryGOV       := Nil
    Local cQuery        := ""
    Local cAlias        := ""
    Local nParamOrder   := 1

    Default oReq        := Nil
    Default aFiliais    := {}
    Default aReqCPF     := {}
    Default aReqCR      := {}

    cQuery := "SELECT "
    cQuery +=     "RUQ_FILIAL, "
    cQuery +=     "RUQ_PERAPU, "
    cQuery +=     "RUQ_CPF, "
    cQuery +=     "RUQ_TPINSC, "
    cQuery +=     "RUQ_NRINSC, "
    cQuery +=     "RUQ_CODREC, "
    cQuery +=     "RUQ_TPIRRF, "
    cQuery +=     "RUQ_VALOR "
    cQuery += "FROM "
    cQuery +=     RetSQLName("RUQ") + " RUQ "
    cQuery += "WHERE "
    cQuery +=     "RUQ_FILIAL IN (?) "                                                  // "aFiliais"
    cQuery +=     "AND RUQ_PERAPU = ? "                                                 // oREQ["period"]
    If Len(aReqCPF) > 0
        cQuery +=     "AND RUQ_CPF IN (?) "                                             // oREQ["cpf"]
    EndIf
    If Len(aReqCR) > 0
        cQuery +=     "AND RUQ_CODREC IN (?) "                                          // oREQ["revenueCode"]
    EndIf
    If oReq:HasProperty("name") .And. !Empty(oREQ["name"])
        cQuery +=     "AND RUQ_NOME LIKE ? "                                            // oREQ["name"]
    EndIf
    cQuery +=     "AND RUQ_DMDEV = ? "                                                  // " "
    cQuery +=     "AND RUQ.D_E_L_E_T_ = ? "                                             // " "
    cQuery += "ORDER BY "
    cQuery +=     "RUQ_CODREC, "
    cQuery +=     "RUQ_TPIRRF "
    cQuery := ChangeQuery(cQuery)

    // Instancia a classe
    oQryGOV := FwExecStatement():New(cQuery)
    
    // INÍCIO - Definições dos valores dos parâmetros - SRC
    oQryGOV:SetIN(nParamOrder++, aFiliais)                          //Filiais
    oQryGOV:SetString(nParamOrder++, oReq["period"])                //period
    If Len(aReqCPF) > 0
        oQryGOV:SetIN(nParamOrder++, aReqCPF)                    //CPF
    EndIf
    If Len(aReqCR) > 0
        oQryGOV:SetIN(nParamOrder++, aReqCR)                     //revenueCode
    EndIf
    If oReq:HasProperty("name") .And. !Empty(oReq["name"])
        oQryGOV:SetString(nParamOrder++, "%" + oReq["name"]  + "%") //Nome
    EndIf
    oQryGOV:SetString(nParamOrder++, " ")                           //DMDEV
    oQryGOV:SetString(nParamOrder++, " ")                           //DELETE

    // Executa a query e retorna o alias criado
    cAlias := oQryGOV:OpenAlias()

Return cAlias


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgRendT
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita do tipo do rendimento tributável vlrRendTrib
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o rendimento tributável
/*/
//---------------------------------------------------------------------
Static Function fRgRendT()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '11'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '11'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '11'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 061001  
    //IRRF sobre rendimentos relativos a prestação de serviços de transporte rodoviário internacional de carga, 
    //pagos a transportador autônomo PF residente no Paraguai
    AAdd(aRegras, {;
        "061001",;
        "cTpInfoIR == '11'",;
        "cCatEFD == '712'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 356201
    //IRRF sobre participação dos trabalhadores em lucros ou resultados - PLR
    AAdd(aRegras, {;
        "356201",;
        "cTpInfoIR == '14'",;
        "Substr(cCatEFD, 1, 1) == '1'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegras, {;
        "188901",;
        "cTpInfoIR $ '11*12*14'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'S'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgRendT13
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita do tipo do rendimento tributável vlrRendTrib13
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o rendimento tributável 
sobre 13 Salario
/*/
//---------------------------------------------------------------------
Static Function fRgRendT13()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '12'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056112  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário
    AAdd(aRegras, {;
        "056112",;
        "!(cOrigEve $ 'S-2299*S-2399')",;
        "cTpInfoIR == '12'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 056113  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário rescisório
    AAdd(aRegras, {;
        "056113",;
        "(cOrigEve $ 'S-2299*S-2399')",;
        "cTpInfoIR == '12'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '12'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgPrev
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita do tipo previdência oficial vlrPrevOficial
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para a previdência oficial
/*/
//---------------------------------------------------------------------
Static Function fRgPrev()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '41'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '41'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '41'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 061001  
    //IRRF sobre rendimentos relativos a prestação de serviços de transporte rodoviário internacional de carga, 
    //pagos a transportador autônomo PF residente no Paraguai
    AAdd(aRegras, {;
        "061001",;
        "cTpInfoIR == '41'",;
        "cCatEFD == '712'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegras, {;
        "188901",;
        "cTpInfoIR $ '41*42'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'S'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgPrev13
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita do tipo previdência oficial vlrPrevOficial13
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para a previdencia oficial 
sobre 13 Salario
/*/
//---------------------------------------------------------------------
Static Function fRgPrev13()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '42'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056112  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário
    AAdd(aRegras, {;
        "056112",;
        "!(cOrigEve $ 'S-2299*S-2399')",;
        "cTpInfoIR == '42'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 056113  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário rescisório
    AAdd(aRegras, {;
        "056113",;
        "(cOrigEve $ 'S-2299*S-2399')",;
        "cTpInfoIR == '42'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '42'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgCRMen
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo ao imposto retido - vlrCRMen
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o imposto retido
/*/
//---------------------------------------------------------------------
Static Function fRgCRMen()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '31'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '31'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '31'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 356201
    //IRRF sobre participação dos trabalhadores em lucros ou resultados - PLR
    AAdd(aRegras, {;
        "356201",;
        "cTpInfoIR == '34'",;
        "Substr(cCatEFD, 1, 1) == '1'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 061001  
    //IRRF sobre rendimentos relativos a prestação de serviços de transporte rodoviário internacional de carga, 
    //pagos a transportador autônomo PF residente no Paraguai
    AAdd(aRegras, {;
        "061001",;
        "cTpInfoIR == '31'",;
        "cCatEFD == '712'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegras, {;
        "188901",;
        "cTpInfoIR $ '31*32*34'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'S'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgCRMen13
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo ao imposto retido 13 - vlrCR13Men
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para o imposto retido 
sobre 13 salário
/*/
//---------------------------------------------------------------------
Static Function fRgCRMen13()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '32'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056112  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário
    AAdd(aRegras, {;
        "056112",;
        "!(cOrigEve $ 'S-2299*S-2399')",;
        "cTpInfoIR == '32'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 056113  
    //IRRF - Empregado/Trabalhador rural - Segurado especial 13° salário rescisório
    AAdd(aRegras, {;
        "056113",;
        "(cOrigEve $ 'S-2299*S-2399')",;
        "cTpInfoIR == '32'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '32'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgIsen65
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo ao imposto retido - vlrParcIsenta65
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para a parcela isenta de 
proventos de aposentadoria, reserva remunerada, reforma e pensão de 
beneficiário com 65 anos ou mais.
/*/
//---------------------------------------------------------------------
Static Function fRgIsen65()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegras, {;
        "188901",;
        "cTpInfoIR $ '70*71'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'S'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgVlDia
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo a diárias - vlrDiarias
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a diárias.
/*/
//---------------------------------------------------------------------
Static Function fRgVlDia()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '72'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '72'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '72'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgVlAjCus
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo a ajuda de custo - vlrAjudaCusto
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
ajuda de custo
/*/
//---------------------------------------------------------------------
Static Function fRgVlAjCus()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '73'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '73'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '73'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgIndResC
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo a indenização e rescisão de contrato, 
inclusive a título de PDV e acidentes de trabalho.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
Indenização e rescisão de contrato
/*/
//---------------------------------------------------------------------
Static Function fRgIndResC()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '74'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '74'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '74'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgAbonoP
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo ao abono pecuniário.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
ao abono pecuniário
/*/
//---------------------------------------------------------------------
Static Function fRgAbonoP()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '75'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '75'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '75'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgMoleG
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo moléstia grave ou acidente em serviço
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
moléstia grave ou acidente em serviço
/*/
//---------------------------------------------------------------------
Static Function fRgMoleG()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegras, {;
        "188901",;
        "cTpInfoIR $ '76*77'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'S'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgAuxMor
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo ao auxílio moradia.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
auxílio moradia
/*/
//---------------------------------------------------------------------
Static Function fRgAuxMor()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '700'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '700'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '700'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgBolM
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo a bolsa médico residente.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
bolsa médico residente
/*/
//---------------------------------------------------------------------
Static Function fRgBolM()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '702'",;
        "cCatEFD == '902'$",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgBolM13
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo a bolsa médico residente - 13º salário.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
bolsa médico residente - 13º salário
/*/
//---------------------------------------------------------------------
Static Function fRgBolM13()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '703'",;
        "cCatEFD == '902'$",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgJurosM
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo a juros de mora
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
a juros de mora
/*/
//---------------------------------------------------------------------
Static Function fRgJurosM()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 188901
    //Rendimentos Recebidos Acumuladamente - RRA
    AAdd(aRegras, {;
        "188901",;
        "cTpInfoIR == '704'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'S'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fRgIsenOu
@type			function
@description	Cria array com as regras para classificação  da rubrica 
por código de receita relativo aos rendimentos isentos - outros.
@author			lidio.oliveira
@since			05/11/2025
@return			aRegras - Array com as regras para valor relativo a 
aos rendimentos isentos - outros
/*/
//---------------------------------------------------------------------
Static Function fRgIsenOu()
    
    Local aRegras := {} // Vetor de regras de classificação para o rendimento tributável

    //CRMen = 056107
    //IRRF mensal, 13° salário e férias sobre trabalho assalariado no país ou ausente no exterior a serviço do país, 
    //exceto se contratado por empregador doméstico ou por segurado especial sujeito a recolhimento unificado
    AAdd(aRegras, {;
        "056107",;
        "cTpInfoIR == '79'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111*301*302*303*304*305*306*307*308*309*310*311*312*313*314*401*410*501*721*722*723*761*901*902*903*904*906'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib <> '22'";
    })

    //CRMen = 056111 
    //IRRF - Empregado/Trabalhador rural - Segurado especial
    AAdd(aRegras, {;
        "056111",;
        "cTpInfoIR == '79'",;
        "cCatEFD $ '101*102*103*105*106*107*108*111'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'",;
        "cClassTrib == '22'";
    })

    //CRMen = 058806 
    //IRRF sobre rendimento do trabalho sem vínculo empregatício
    AAdd(aRegras, {;
        "058806",;
        "cTpInfoIR == '79'",;
        "cCatEFD $ '201*202*701*711*712*731*734*738*741*751*771*781'",;
        "cIndApurIR == '0'",;
        "cIndRRA == 'N'",;
        "cResidExt == 'N'";
    })

Return aRegras


//---------------------------------------------------------------------
/*/{Protheus.doc} fSM0BsCNPJ
@type			function
@description	Busca as Filias com a mesma Raiz de CNPJ.
@author			lidio.oliveira
@since			14/11/2022
@Param......: (char) - cCodEmp - Código do Grupo de Empresa
@Param......: (char) - cCodFil - Código da Filial
@Return.....: (array) - cCGC - Retorna o valor do campo M0_CGC
@return			aFilial	-	Filiais com a mesma Raiz de CNPJ da Filial logada
/*/
//---------------------------------------------------------------------
Static Function fSM0BsCNPJ(cCodEmp, cCodFil)

	Local cBaseCNPJ	:= ""
	Local nI		:= 0
	Local aFilial	:= {}

    Default cCodEmp := cEmpAnt
    Default cCodFil := cFilAnt

    cBaseCNPJ := Left( AllTrim( Posicione( "SM0", 1, cCodEmp + cCodFil, "M0_CGC" ) ), 8 )

	For nI := 1 to Len( aSM0 )
		If cBaseCNPJ == AllTrim( Left( aSM0[nI][SM0_CGC], 8 ) )
			If aSM0[nI][SM0_GRPEMP] == cCodEmp
				aAdd( aFilial, aSM0[nI][SM0_CODFIL] )
			EndIf
		EndIf
	Next nI

Return aFilial


//---------------------------------------------------------------------
/*/{Protheus.doc} fGetCGC()
Retorno o CGC da filial informada
@author lidio.oliveira
@since 24/10/2025
@Param......: (char) - cCodEmp - Código do Grupo de Empresa
@Param......: (char) - cCodFil - Código da Filial
@Param......: (logical) - lRaiz - Indica de deve retonar somente a Raiz
@Return.....: (char) - cCGC - Retorna o valor do campo M0_CGC
/*/
//---------------------------------------------------------------------
Static Function fGetCGC(cCodEmp, cCodFil, lRaiz)

	Local cCGC		:= ""
	Local nPos		:= 0

	Default cCodEmp	:= ""
	Default cCodFil := ""
	Default lRaiz 	:= .T.

	//Pesquisa o CGC conforme o grupo e filial
	//aSM0 está declara no inicio do programa como Private
	If Len(aSM0) > 0
		nPos := aScan( aSM0, { |x| x[1] == cCodEmp .And. x[2] == cCodFil} )
		If nPos > 0
			cCGC := aSM0[nPos][18]
			If lRaiz
				cCGC := SubStr(cCGC, 1, 8)
			EndIf
		EndIf
	EndIf

Return cCGC


//---------------------------------------------------------------------
/*/{Protheus.doc} fVldRegIR()
Retorna se as Regras do IR foram atendidas
@author lidio.oliveira
@since 05/11/2025
@Param......: (array)   - aRegras   - Array com as regras de validação
@Param......: (char)    - cCodCR    - Código de Receita localizado
@Return.....: (logical) - lRegOk    - Indica se atendeu as regras
/*/
//---------------------------------------------------------------------
Static Function fVldRegIR(aRegras, cCodCR)

	Local lValid    := .T.
    Local lRegOk    := .T.
    Local nAux      := 0
    Local nAux2     := 0

	Default aRegras := {}
	Default cCodCR  := ""

    For nAux := 1 To Len(aRegras)
        If lValid
            lRegOk := .T.
            For nAux2 := 2 To Len(aRegras[nAux])
                If !&(aRegras[nAux][nAux2])
                    lRegOk := .F.
                    Exit
                EndIf
            Next nAux2 
            If lRegOk
                lValid      := .F.
                cCodCR      := aRegras[nAux][1]
            EndIf
        Else
            Exit
        EndIf
    Next nAux

Return lRegOk


//---------------------------------------------------------------------
/*/{Protheus.doc} fCarIfIR()
Carrega a lista do tpInfoIR (Consolidação dos tipos de valores de IRRF)
É uma Listagem de excecão, quando RV_INCIR difere de tpInfoIR
@author lidio.oliveira
@since 05/11/2025
/*/
//---------------------------------------------------------------------
Static Function fCarIfIR()

    //RV_INCIR | tpInfoIR
    oIncIR["13"]    := "11"
    oIncIR["9"]     := "7900"
    oIncIR["0"]     := "7950"
    oIncIR["1"]     := "7951"
    oIncIR["15"]    := "7952"
    oIncIR["78"]    := "7956"
    oIncIR["91"]    := "7960"
    oIncIR["92"]    := "7961"
    oIncIR["93"]    := "7962"
    oIncIR["94"]    := "7963"
    oIncIR["95"]    := "7964"
    oIncIR["9013"]  := "9011"
    oIncIR["33"]    := "31"
    oIncIR["43"]    := "41"
    oIncIR["48"]    := "46"
    oIncIR["53"]    := "51"
    oIncIR["66"]    := "61"
    oIncIR["65"]    := "63"
    oIncIR["35"]    := "7953"
    oIncIR["44"]    := "7954"
    oIncIR["55"]    := "7955"
    oIncIR["81"]    := "7957"
    oIncIR["82"]    := "7958"
    oIncIR["83"]    := "7959"
    oIncIR["9033"]  := "9031"
    oIncIR["9833"]  := "9831"
    oIncIR["9043"]  := "9041"
    oIncIR["9048"]  := "9046"
    oIncIR["9053"]  := "9051"
    oIncIR["9066"]  := "9061"
    oIncIR["9065"]  := "9063"

Return 


//---------------------------------------------------------------------
/*/{Protheus.doc} GrvItRes
@type			function
@description	Grava o item do resultado da requisição.
@author			lidio.oliveira
@since			06/11/2025
@param			cResp		-	Resposta da API
@param			cSeq		-	Sequencial
@param			lDiverg		-	Valor Folha e Governo Divergentes
@param			cTipo		-	1- Sintético 2 - Analítico
@param			cCPF		-	CPF do Funcionário
@param			cTicket		-	Ticket da requisição
@param			cNivel		-	Nível da Requisição
@param			cCodRec		-	Código de Receita
/*/
//---------------------------------------------------------------------
Static Function GrvItRes(cResp, cSeq, lDiverg, cTipo, cCPF, cTicket, cNivel, cCodRec)

    Default cResp       := ""       //Json de resposta
    Default cSeq        := ""       //Código de sequencia do Item
    Default lDiverg		:= .F.      //Indica se o item possui divergência
    Default cTipo       := ""       //Indica o tipo de resposta 1 - Sintético e 2 - Analítico
    Default cCPF		:= ""       //CPF dp funcionário caso o registro seja específico
    Default cTicket		:= ""       //Código do ticket de processamento
    Default cNivel  	:= ""       //Nível da Requisição 
    Default cCodRec 	:= ""       //Código de Receita     

	//RU5_FILIAL+RU5_ID+RU5_TIPO+RU5_SEQ+RU5_NIVEL
	RU5->(DbSetOrder(1))
    lNovo := RU5->( !dbSeek( xFilial("RU5") + cTicket + cTipo + cSeq + cNivel ))

    If RU5->( RecLock("RU5", lNovo) )
		RU5->RU5_ID			:= cTicket
		RU5->RU5_RESP		:= cResp
		RU5->RU5_SEQ		:= cSeq
		RU5->RU5_DIVERG		:= Iif(lDiverg, "1", "2" )
		RU5->RU5_TIPO		:= cTipo
		RU5->RU5_CPF		:= cCPF
		RU5->RU5_NIVEL      := cNivel
        If RU5->(ColumnPos("RU5_CODREC")) > 0
            RU5->RU5_CODREC     := cCodRec
        EndIf
		RU5->(MsUnlock())
	EndIf

Return


//---------------------------------------------------------------------
/*/{Protheus.doc} EmployeesByRevenueCode
@type			method
@description	Método para retonar os valores totais de IR apurado
@author			lidio.oliveira
@since			04/12/2025
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET EmployeesByRevenueCode QUERYPARAM companyId, period, requestId, differencesOnly, revenueCode, page, pageSize WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oResponse		:= Nil
    Local aAmb		    := {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local lRet			:= .T.
    Local lDiverg       := .F.
    Local cRequestID    := ""
    Local nPage         := 1
    Local nPageSize     := 20000
    
    cRequestID := self:requestId

    If self:page <> Nil
        nPage := self:page
    EndIf

    If self:pageSize <> Nil
        nPageSize := self:pageSize
    EndIf    

    If fChkParam(self:companyId, self:period, cRequestID, self:revenueCode)
        fResetErrorHandler()
        fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

        //Inicialização de Ambiente
        aAmb := StrTokArr( self:companyId, "|")
        If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
            fTrGrpGPE( aAmb[1], aAmb[2], "RU5", "GPE" )
        EndIf

        If self:differencesOnly <> Nil
            lDiverg := self:differencesOnly
        EndIf  

        If ValidID(cRequestID)
            GetReport( @oResponse, cRequestID, .F., lDiverg, "2", /*cpf*/, self:revenueCode, nPage, nPageSize )
            self:SetResponse( oResponse:toJson() )
        Else
            //"Ocorreu uma falha no retorno da informação."
            //"A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe."
            fSendMess(400, OemToAnsi(STR0011), .T., 400, OemToAnsi(STR0013) + self:requestId + OemToAnsi(STR0014),,) 
            lRet := .F.
        EndIf
    Else
        lRet := .F.            
    EndIf

    oResponse := Nil
    FreeObj( oResponse )
    DelClassIntF()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fIfDedDep
Monta objeto com os dados de dedução de dependente
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fIfDedDep(aDados, cCRMen)

    Local oDados    := Nil
    Local aRet      := {}
    Local aIfDedDep := {}
    Local aItem     := {}
    Local nX        := 0

    Default aDados  := {}
    Default cCRMen  := ""

    If Len(aDados) > 0
        oDados  := JsonObject():New()
        
        For nX := 1 To Len(aDados)
            If aDados[nX][7] == cCRMen
                aItem := fObjDetDep(aDados[nX])
                If Len(aItem) > 0
                    aAdd(aIfDedDep, aClone(aItem)[1])
                EndIf
            EndIf
        Next nX

        If Len(aIfDedDep) > 0
            oDados["DEDDEP"] := aClone(aIfDedDep)
            aAdd(aRet, oDados)
        EndIf
    EndIf

    FreeObj(oDados)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fObjDetDep
Monta objeto com os detalhes do dependente
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fObjDetDep(aDados)

	Local oDados    := Nil
    Local aRet      := {}

    Default aDados  := {} 

    If Len(aDados) > 0
        oDados  := JsonObject():New()
        oDados["TPREND"] 	:= aDados[5]            //Tipo de Rendimento
        oDados["NOME"] 		:= AllTrim(aDados[8])   //Nome do Dependente
        oDados["CPF"] 	    := aDados[4]            //CPF do dependente
        oDados["NVLRERP"] 	:= aDados[6]            //Valor de dedução
        oDados["NVLRRET"] 	:= 0                    //Valor Governo
        aAdd( aRet, oDados )
    EndIf

    FreeObj(oDados)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fDeduDep
Monta objeto com os detalhes do dependente para a detailsOfEmployee
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fDeduDep(aDados)

	Local oItem := Nil
    Local oVal  := Nil
    Local aVal  := {}
    Local aRet  := {}
    Local nX    := 0

    Default aDados  := {}

    oItem := JsonObject():New()
    oVal  := JsonObject():New()

    For nX := 1 To Len(aDados)
        oItem["incomeType"] 	:= aDados[nX]["TPREND"]  //Tipo de Rendimento
        oItem["name"] 		    := aDados[nX]["NOME"]   //Nome do Dependente
        oItem["cpf"] 	        := aDados[nX]["CPF"]    //CPF do dependente

        oVal["erpValue"] 	:= aDados[nX]["NVLRERP"]    //Valor de dedução
        oVal["retValue"] 	:= aDados[nX]["NVLRRET"]    //Valor Governo
        oVal["divergent"] 	:= aDados[nX]["NVLRERP"] <> aDados[nX]["NVLRRET"]
        
        aAdd( aVal, oVal )
        oItem["values"] := aClone(aVal)[1]

        aAdd(aRet, oItem)

        aVal := {}
        
        FreeObj(oVal)
        FreeObj(oItem)
        oItem := JsonObject():New()
        oVal  := JsonObject():New()
    Next nX

    FreeObj(oVal)
    FreeObj(oItem)

Return aRet


//---------------------------------------------------------------------
/*/{Protheus.doc} detailsOfEmployee
@type			method
@description	Método para retonar o detalhe dos rendimento do funcionário para o código de receita solicitado
@author			lidio.oliveira
@since			23/12/2025
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET DetailsOfEmployee QUERYPARAM companyId, period, requestId, differencesOnly, revenueCode, cpf WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oResponse		:= Nil
    Local aAmb		    := {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local lRet			:= .T.
    Local lDiverg       := .F.
    Local cRequestID    := ""
    Local cCPF          := ""
    
    cRequestID := self:requestId

    If fChkParam(self:companyId, self:period, cRequestID, self:revenueCode, self:cpf)
        fResetErrorHandler()
        fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

        //Inicialização de Ambiente
        aAmb := StrTokArr( self:companyId, "|")
        If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
            fTrGrpGPE( aAmb[1], aAmb[2], "RU5", "GPE" )
        EndIf

        If self:differencesOnly <> Nil
            lDiverg := self:differencesOnly
        EndIf  

        If self:cpf <> Nil
            cCPF := self:cpf
        EndIf  

        If ValidID(cRequestID)
            GetReport( @oResponse, cRequestID, .F., lDiverg, "3", cCPF, self:revenueCode )
            self:SetResponse( oResponse:toJson() )
        Else
            //"Ocorreu uma falha no retorno da informação."
            //"A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe."
            fSendMess(400, OemToAnsi(STR0011), .T., 400, OemToAnsi(STR0013) + self:requestId + OemToAnsi(STR0014),,) 
            lRet := .F.
        EndIf
    Else
        lRet := .F.            
    EndIf

    oResponse := Nil
    FreeObj( oResponse )
    DelClassIntF()

Return lRet


//---------------------------------------------------------------------
/*/{Protheus.doc} exportEmployeeDetails
@type			method
@description	Método para retonar o detalhe dos rendimento do funcionário para o código de receita solicitado
@author			lidio.oliveira
@since			23/12/2025
@return			lRet	-	Indica se o método aceitou a execução do processo
/*/
//---------------------------------------------------------------------
WSMETHOD GET exportEmployeeDetails QUERYPARAM companyId, period, requestId, differencesOnly, cpf WSRESTFUL GPEreportEsocialIrrfRevenueCodes

    Local oResponse		:= Nil
    Local aAmb		    := {}
    Local cEmpAntBck	:= cEmpAnt
    Local cFilAntBck	:= cFilAnt
    Local lRet			:= .T.
    Local lDiverg       := .F.
    Local cRequestID    := ""
    Local cCPF          := ""
    
    cRequestID := self:requestId

    If fChkParam(self:companyId, self:period, cRequestID, , self:cpf)
        fResetErrorHandler()
        fSetErrorHandler( EncodeUTF8(STR0005) ) //"Falha ao inicializar o ambiente com os dados informados!"

        //Inicialização de Ambiente
        aAmb := StrTokArr( self:companyId, "|")
        If cEmpAntBck <> aAmb[1] .Or. cFilAntBck <> aAmb[2]
            fTrGrpGPE( aAmb[1], aAmb[2], "RU5", "GPE" )
        EndIf

        If self:differencesOnly <> Nil
            lDiverg := self:differencesOnly
        EndIf  

        If self:cpf <> Nil
            cCPF := self:cpf
        EndIf  

        If ValidID(cRequestID)
            GetReport( @oResponse, cRequestID, .F., lDiverg, "3", cCPF )
            self:SetResponse( oResponse:toJson() )
        Else
            //"Ocorreu uma falha no retorno da informação."
            //"A Identificação da Requisição '" + self:requestId + "' informado no parâmetro 'requestId' não existe."
            fSendMess(400, OemToAnsi(STR0011), .T., 400, OemToAnsi(STR0013) + self:requestId + OemToAnsi(STR0014),,) 
            lRet := .F.
        EndIf
    Else
        lRet := .F.            
    EndIf

    oResponse := Nil
    FreeObj( oResponse )
    DelClassIntF()

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fIfPenAli
Monta array com dados de pensão alimentícia por código de receita
Return array - Exemplo {{356201,oPen},{056207,oPen}}
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fIfPenAli(aDados, cCodRec)

    Local cCodCR    := ""
    Local aIfPenAli := {}
    Local aRet      := {}
    Local aItem     := {}
    Local nX        := 0

    Default aDados  := {}
    Default cCodRec := ""

    If Len(aDados) > 0     
        //Garante a ordenação Código de Receita + CPF Beneficiário
        ASort( aDados, , , {|x,y| x[10]+x[4] < y[10]+y[4]} )
        
        //Varre o array de Dados
        For nX := 1 To Len(aDados)
            //Se houver filtro por código de receita, respeita esse filtro
            If Empty(cCodRec) .Or. aDados[nX][10] $ cCodRec               
                //Se alterou o código de receita armeneza os dados no array de retorno
                If !Empty(aIfPenAli) .And. cCodCR <> aDados[nX][10]
                    aAdd(aRet,{cCodCR, aClone(aIfPenAli)})
                    aIfPenAli := {}
                EndIf

                cCodCR  := aDados[nX][10]
                aItem   := fObjDetPen(aDados[nX])
                If Len(aItem) > 0
                    aAdd(aIfPenAli, aClone(aItem)[1])
                EndIf

                aItem := {}
            EndIf
        Next nX
    EndIf

    //Guarda pensão alimentícia do último CR processado
    If !Empty(aIfPenAli)
        aAdd(aRet,{cCodCR, aClone(aIfPenAli)})
    EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fObjDetPen
Monta objeto com os detalhes da pensão
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fObjDetPen(aDados)

	Local oDados    := Nil
    Local aRet      := {}

    Default aDados  := {} 

    If Len(aDados) > 0
        oDados  := JsonObject():New()
        oDados["TPREND"] 	:= aDados[9]            //Tipo de Rendimento
        oDados["NOME"] 		:= AllTrim(aDados[3])   //Nome do Dependente
        oDados["CPF"] 	    := aDados[4]            //CPF do dependente
        oDados["NVLRERP"] 	:= aDados[5]            //Valor de dedução
        oDados["NVLRRET"] 	:= 0                    //Valor Governo
        aAdd( aRet, oDados )
    
        FreeObj(oDados)
    EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fAlimony
Monta objeto com os detalhes de pensão alimentícia para a detailsOfEmployee
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fAlimony(aDados)

	Local oItem := Nil
    Local oVal  := Nil
    Local aVal  := {}
    Local aRet  := {}
    Local nX    := 0

    Default aDados  := {}

    oItem := JsonObject():New()
    oVal  := JsonObject():New()

    For nX := 1 To Len(aDados)
        oItem["incomeType"] 	:= aDados[nX]["TPREND"]  //Tipo de Rendimento
        oItem["name"] 		    := aDados[nX]["NOME"]   //Nome do Dependente
        oItem["cpf"] 	        := aDados[nX]["CPF"]    //CPF do dependente

        oVal["erpValue"] 	:= aDados[nX]["NVLRERP"]    //Valor de dedução
        oVal["retValue"] 	:= aDados[nX]["NVLRRET"]    //Valor Governo
        oVal["divergent"] 	:= aDados[nX]["NVLRERP"] <> aDados[nX]["NVLRRET"]
        
        aAdd( aVal, oVal )
        oItem["values"] := aClone(aVal)[1]

        aAdd(aRet, oItem)

        aVal := {}

        FreeObj(oVal)
        FreeObj(oItem)
        oItem := JsonObject():New()
        oVal  := JsonObject():New()
    Next nX

    FreeObj(oVal)
    FreeObj(oItem)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fDeduGov
Alimenta as informações de deduções de dependente e pensão do RET
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fDeduGov(aFiliais, cCPF, aReqCR)

    Local cQuery        := ""
    Local cAlias        := "DEDUGOV"
    Local cObjCR        := ""
    Local nPosFunc      := 0
    Local nPosDep       := 0
    Local nParamOrder   := 1
    
    Default aFiliais    := {}
    Default aReqCR      := {}
    Default cCPF        := ""

    If __oSt01 == Nil
        __oSt01 := FWPreparedStatement():New()
        cQuery := "SELECT RUR_CODREC, RUR.RUR_CPF, RUR_TPDED, RUR_TPREND, RUR_CPFDEP, RUR_VALOR"
        cQuery += "FROM " + RetSqlName('RUR') + " RUR "
        cQuery += "WHERE RUR.RUR_FILIAL IN (?) AND "
        cQuery += 		"RUR.RUR_CPF = ? AND "
        If Len(aReqCR) > 0
            cQuery += 	"RUR.RUR_CODREC IN (?) AND "            
        EndIf
        cQuery += 		"RUR.D_E_L_E_T_ = ? "
        cQuery := ChangeQuery(cQuery)
        __oSt01:SetQuery(cQuery)
    EndIf
    __oSt01:SetIN(nParamOrder++, aFiliais)
    __oSt01:SetString(nParamOrder++, cCPF)
    If Len(aReqCR) > 0
        __oSt01:SetIN(nParamOrder++, aReqCR)         
    EndIf
    __oSt01:SetString(nParamOrder++, " ")
    cQuery := __oSt01:getFixQuery()
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

    //Ajuste os valores GOV no objeto de código de receita
    While (cAlias)->(!Eof())
        cObjCR := "oCR" + (cAlias)->RUR_CODREC 

        If nPosFunc == 0 .Or. (cChvPosFun <> ((cAlias)->RUR_CODREC + (cAlias)->RUR_CPF))
            nPosFunc    := aScan(&cObjCR["FUNCIONARIOS"], { |x| x["CPF"] == (cAlias)->RUR_CPF })
            cChvPosFun  := (cAlias)->RUR_CODREC + (cAlias)->RUR_CPF
        EndIf

        If nPosFunc > 0
            If (cAlias)->RUR_TPDED == "1"
                nPosDep := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["DEDDEP"], { |x| x["CPF"] == (cAlias)->RUR_CPFDEP .And. x["TPREND"] == (cAlias)->RUR_TPREND })
                If nPosDep > 0
                    &cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["DEDDEP"][nPosDep]["NVLRRET"] := (cAlias)->RUR_VALOR
                EndIf
            ElseIf (cAlias)->RUR_TPDED == "2"
                nPosDep := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PENSALIM"], { |x| x["CPF"] == (cAlias)->RUR_CPFDEP .And. x["TPREND"] == (cAlias)->RUR_TPREND })
                If nPosDep > 0
                    &cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PENSALIM"][nPosDep]["NVLRRET"] := (cAlias)->RUR_VALOR
                EndIf
            EndIf
        EndIf

        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(DBCloseArea())

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} fIfPlSau
Monta objeto com os detalhes de Plano de Saúde
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fIfPlSau(aDados)

	Local oItem := Nil
    Local oDep  := Nil
    Local aDep  := {}
    Local aRet  := {}
    Local nX    := 0
    Local nY    := 0

    Default aDados  := {}

    For nX := 1 To Len(aDados)
        oItem := JsonObject():New()

        oItem["CPF"] 	    := aDados[nX][11]   //CPF do Titular
        oItem["CNPJ"] 	    := aDados[nX][6]    //CNPJ do operador de Plano de Saúde
        oItem["ANS"] 	    := aDados[nX][7]    //Código ANS
        oItem["NVLRERP"] 	:= aDados[nX][8]    //Valor no ERP
        oItem["NVLRRET"] 	:= 0                //Valor no ERP
        
        //Varre o array com dados de Dependente
        If Len(aDados[nX][9]) > 0
            For nY := 1 To Len(aDados[nX][9])
                oDep  := JsonObject():New()

                oDep["CPF"] 	    := aDados[nX][9][nY][1]    //CPF do Dependente
                oDep["NOME"] 	    := aDados[nX][9][nY][5]    //Nome do Dependente
                oDep["NVLRERP"] 	:= aDados[nX][9][nY][2]    //Valor no ERP
                oDep["NVLRRET"] 	:= 0                       //Valor no ERP

                aAdd(aDep, oDep)
                FreeObj(oDep)            
            Next nY

            oItem["DEPENDENTES"]    := aClone(aDep)
        EndIf

        aDep := {}
        aAdd(aRet, oItem)
        FreeObj(oItem)
    Next nX

    FreeObj(oDep)
    FreeObj(oItem)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fHolders
Monta objeto com os detalhes de plano de Saúde holders
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fHolders(aDados)

	Local oItem := Nil
    Local oVal  := Nil
    Local oDep  := Nil
    Local aDep  := {}
    Local aRet  := {}
    Local nX    := 0
    Local nY    := 0

    Default aDados  := {}

    For nX := 1 To Len(aDados)
        oItem := JsonObject():New()
        oItem["cpf"] 	    := aDados[nX]["CPF"]    //CPF do Titular
        oItem["cnpj"] 	    := aDados[nX]["CNPJ"]   //CNPJ do operador de Plano de Saúde
        oItem["ansCode"] 	:= aDados[nX]["ANS"]    //Código ANS
        
        oVal := JsonObject():New()
        oVal["erpValue"] 	:= aDados[nX]["NVLRERP"]    //Valor de dedução
        oVal["retValue"] 	:= aDados[nX]["NVLRRET"]    //Valor Governo
        oVal["divergent"] 	:= aDados[nX]["NVLRERP"] <> aDados[nX]["NVLRRET"]
        
        oItem["values"] :=  oVal

        //Varre o array com dados de Dependente
        If aDados[nX]:HasProperty("DEPENDENTES")
            For nY := 1 To Len(aDados[nX]["DEPENDENTES"])
                oDep  := JsonObject():New()

                oDep["cpf"] 	    := aDados[nX]["DEPENDENTES"][nY]["CPF"]        //CPF do Dependente

                oVal := JsonObject():New()
                oVal["erpValue"] 	:= aDados[nX]["DEPENDENTES"][nY]["NVLRERP"]    //Valor de dedução
                oVal["retValue"] 	:= aDados[nX]["DEPENDENTES"][nY]["NVLRRET"]    //Valor Governo
                oVal["divergent"] 	:= aDados[nX]["DEPENDENTES"][nY]["NVLRERP"] <> aDados[nX]["DEPENDENTES"][nY]["NVLRRET"]

                oDep["values"] :=  oVal

                aAdd(aDep, oDep)
                FreeObj(oDep)            
            Next nY

            oItem["dependents"]    := aClone(aDep)
        EndIf

        aDep := {}
        aAdd(aRet, oItem)
        FreeObj(oItem)
    Next nX

    FreeObj(oDep)
    FreeObj(oItem)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fPlSauGov
Alimenta as informações de plano de Saúde do RET
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fPlSauGov(aFiliais, cCPF, cObjCR, nPosFunc)

    Local cQuery        := ""
    Local cAlias        := "PLSAUGOV"
    Local cCNPJOper     := ""
    Local cRegANS       := ""
    Local cChvOper      := ""
    Local cChvReemb     := ""
    Local nPosOper      := 0
    Local nChvReemb     := 0
    Local nPosDep       := 0
    Local nPosItDep     := 0
    Local nPosTit       := 0
    Local nParamOrder   := 1
    
    Default aFiliais    := {}
    Default cCPF        := ""
    Default cObjCR      := ""
    Default nPosFunc    := 0

    If __oSt02 == Nil
        __oSt02 := FWPreparedStatement():New()
        cQuery := "SELECT RUT.RUT_CPF, RUT.RUT_CNPJOP, RUT.RUT_REGANS, RUT.RUT_TPINFO, RUT.RUT_TPMED, RUT.RUT_INMED, RUT.RUT_ORIGEM, RUT.RUT_CPFDEP, RUT.RUT_VLR"
        cQuery += "FROM " + RetSqlName('RUT') + " RUT "
        cQuery += "WHERE RUT.RUT_FILIAL IN (?) AND "
        cQuery += 		"RUT.RUT_CPF = ? AND "
        cQuery += 		"RUT.D_E_L_E_T_ = ? "
        cQuery := ChangeQuery(cQuery)
        __oSt02:SetQuery(cQuery)
    EndIf
    __oSt02:SetIN(nParamOrder++, aFiliais)
    __oSt02:SetString(nParamOrder++, cCPF)
    __oSt02:SetString(nParamOrder++, " ")
    cQuery := __oSt02:getFixQuery()
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

    //Ajuste os valores GOV no objeto de código de receita
    While (cAlias)->(!Eof())
        If &cObjCR["FUNCIONARIOS"][nPosFunc]:HasProperty("PLANOSAUDE")        
            //Valores de Plano de Saúde
            //RUT_TPINFO = 1 - Plano de Saúde, 2 - Reembolso
            If (cAlias)->RUT_TPINFO == "1"
                //Encontra no objeto a posição referente ao operador do plano de saúde
                If nPosOper == 0 .Or. (cChvOper <> AllTrim((cAlias)->RUT_CNPJOP) + (cAlias)->RUT_REGANS)
                    cChvOper := AllTrim((cAlias)->RUT_CNPJOP) + (cAlias)->RUT_REGANS
                    nPosOper := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["PLANOSAUDE"], { |x| x["CNPJ"] + x["ANS"] == AllTrim((cAlias)->RUT_CNPJOP) + (cAlias)->RUT_REGANS })
                EndIf
                
                //Se encontrou o operador de plano de saúde ajusta o valor referente ao governo
                //RUT_ORIGEM = 1 - Titular, 2 - Dependente
                If nPosOper > 0
                    If (cAlias)->RUT_ORIGEM == "1" 
                        &cObjCR["FUNCIONARIOS"][nPosFunc]["PLANOSAUDE"][nPosOper]["NVLRRET"] := (cAlias)->RUT_VLR
                    ElseIf (cAlias)->RUT_ORIGEM == "2"
                        nPosDep := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["PLANOSAUDE"][nPosOper]["DEPENDENTES"], {|x| x["CPF"] == (cAlias)->RUT_CPFDEP})
                        
                        If nPosDep > 0
                            &cObjCR["FUNCIONARIOS"][nPosFunc]["PLANOSAUDE"][nPosOper]["DEPENDENTES"][nPosDep]["NVLRRET"] := (cAlias)->RUT_VLR
                        EndIf
                    EndIf
                EndIf
            ElseIf (cAlias)->RUT_TPINFO == "2"
                //Encontra no objeto a posição referente ao operador do plano de saúde
                If nChvReemb == 0 .Or. (cChvReemb <> AllTrim((cAlias)->RUT_CNPJOP) + (cAlias)->RUT_REGANS)
                    cChvReemb := AllTrim((cAlias)->RUT_CNPJOP) + (cAlias)->RUT_REGANS
                    nChvReemb := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["REEMBMEDICO"], { |x| x["CNPJ"] + x["ANS"] == AllTrim((cAlias)->RUT_CNPJOP) + (cAlias)->RUT_REGANS })
                EndIf

                //Se encontrou o operador no reembolso ajusta o valor referente ao governo
                //RUT_ORIGEM = 1 - Titular, 2 - Dependente
                If nPosOper > 0
                    If (cAlias)->RUT_ORIGEM == "1" 
                        nPosTit := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["REEMBMEDICO"][nChvReemb]["TITULAR"], {|x| x["NUMINSC"] == AllTrim((cAlias)->RUT_INMED)})
                        
                        If nPosTit > 0
                            &cObjCR["FUNCIONARIOS"][nPosFunc]["REEMBMEDICO"][nChvReemb]["TITULAR"][nPosTit]["NVLRRET"] := (cAlias)->RUT_VLR
                        EndIf
                    ElseIf (cAlias)->RUT_ORIGEM == "2"
                        nPosDep := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["REEMBMEDICO"][nChvReemb]["DEPENDENTES"], {|x| x["CPF"] == AllTrim((cAlias)->RUT_CPFDEP)})
                        
                        If nPosDep > 0
                            nPosItDep := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["REEMBMEDICO"][nChvReemb]["DEPENDENTES"][nPosDep]["ITEMDEP"], {|x| x["NUMINSC"] == AllTrim((cAlias)->RUT_INMED)})

                            If nPosItDep > 0
                                &cObjCR["FUNCIONARIOS"][nPosFunc]["REEMBMEDICO"][nChvReemb]["DEPENDENTES"][nPosDep]["ITEMDEP"][nPosItDep]["NVLRRET"] := (cAlias)->RUT_VLR    
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(DBCloseArea())

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} fIfReembM
Monta objeto com os detalhes de Reembolso Médico
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fIfReembM(aDados)

	Local oItem     := Nil
    Local oItemTit  := Nil
    Local oDep      := Nil
    Local oItemDep  := Nil
    Local aItemTit  := {}
    Local aDep      := {}
    Local aItemDep  := {}
    Local aRet      := {}
    Local cCPFDep   := ""
    Local nX        := 0
    Local nY        := 0

    Default aDados  := {}

    For nX := 1 To Len(aDados)
        cCPFDep := ""
        
        oItem := JsonObject():New()

        oItem["ORIGEM"]     := "1"              //1 - Reembolso efetuado pelo empregador no âmbito do plano de saúde (a operadora reembolsa o empregador)
        oItem["CNPJ"] 	    := aDados[nX][6]    //CNPJ do operador de Plano de Saúde
        oItem["ANS"] 	    := aDados[nX][7]    //Código ANS

        //Varre array com dados do titular
        For nY := 1 To Len(aDados[nX][8])
            If aDados[nX][6] == aDados[nX][8][nY][6] //Valida se o CNPJ do operador está correto
                oItemTit    := JsonObject():New()

                oItemTit["TIPOINSC"]    := aDados[nX][8][nY][3]            //Tipo 1 - CNPJ, 2 - CPF
                oItemTit["NUMINSC"]     := AllTrim(aDados[nX][8][nY][4])   //Número de inscrição
                oItemTit["NVLRERP"]     := aDados[nX][8][nY][5]            //Valor no ERP 
                oItemTit["NVLRRET"]     := 0                               //Valor no RET 

                aAdd(aItemTit, oItemTit)
                FreeObj(oItemTit)   
            EndIf
        Next nY

        //Garda os valores do titular no item
        If Len(aItemTit) > 0
            oItem["TITULAR"] := aItemTit
        EndIf 

        //Varre o array com dados de Dependente
        For nY := 1 To Len(aDados[nX][9])
            If aDados[nX][6] == aDados[nX][9][nY][7] //Valida se o CNPJ do operador está correto
                oDep        := JsonObject():New()
                oItemDep    := JsonObject():New()

                If Empty(cCPFDep) .Or. cCPFDep <> aDados[nX][9][nY][1] 
                    oDep["CPF"]     := aDados[nX][9][nY][1]             //CPF do Dependente
                    oDep["NOME"]    := AllTrim(aDados[nX][9][nY][9])    //Nome do Dependente
                EndIf

                oItemDep["TIPOINSC"] 	:= aDados[nX][9][nY][5]             //Tipo 1 - CNPJ, 2 - CPF
                oItemDep["NUMINSC"] 	:= AllTrim(aDados[nX][9][nY][6])    //Número de inscrição
                oItemDep["NVLRERP"] 	:= aDados[nX][9][nY][2]             //Valor no ERP
                oItemDep["NVLRRET"] 	:= 0                                //Valor no RET

                aAdd(aItemDep, oItemDep)
                oDep["ITEMDEP"] := aClone(aItemDep)
                aAdd(aDep, oDep)

                cCPFDep     := aDados[nX][9][nY][1]
                aItemDep    := {}
                
                FreeObj(oDep)   
                FreeObj(oItemDep)
            EndIf            
        Next nY

        If Len(aDep) > 0
            oItem["DEPENDENTES"]    := aClone(aDep)
        EndIf

        aItemTit    := {}
        aDep        := {}
        aAdd(aRet, oItem)
        FreeObj(oItem)
    Next nX

Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} fReimburs
Monta array de objeto com os detalhes de reembolso médico reimbursements
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fReimburs(aDados)

	Local oItem     := Nil
    Local oVal      := Nil
    Local oHDetail  := Nil
    Local oItemDep  := Nil
    Local aHDetail  := {}
    Local aReimbDep := {}
    Local aItemDep  := {}
    Local aRet      := {}
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0

    Default aDados  := {}

    For nX := 1 To Len(aDados)
        oItem := JsonObject():New()
        oItem["originOfRefund"] 	    := aDados[nX]["ORIGEM"] //Origem
        oItem["registrationNumber"] 	:= aDados[nX]["CNPJ"]   //CNPJ do operador de Plano de Saúde
        oItem["ansCode"] 	            := aDados[nX]["ANS"]    //Código ANS

        //Varre o array com dados do Titular
        If aDados[nX]:HasProperty("TITULAR")        
            For nY := 1 To Len(aDados[nX]["TITULAR"])
                oHDetail := JsonObject():New()

                oHDetail["registrationType"]    := aDados[nX]["TITULAR"][nY]["TIPOINSC"]    //Tipo de inscrição
                oHDetail["registrationNumber"]  := aDados[nX]["TITULAR"][nY]["NUMINSC"]     //Número de inscrição
                
                oVal := JsonObject():New()
                oVal["erpValue"] 	:= aDados[nX]["TITULAR"][nY]["NVLRERP"]    //Valor de dedução
                oVal["retValue"] 	:= aDados[nX]["TITULAR"][nY]["NVLRRET"]    //Valor Governo
                oVal["divergent"] 	:= aDados[nX]["TITULAR"][nY]["NVLRERP"] <> aDados[nX]["TITULAR"][nY]["NVLRRET"]

                oHDetail["values"]  :=  oVal
                
                aAdd(aHDetail, oHDetail)
                
                FreeObj(oHDetail)
                FreeObj(oVal)
            Next nY
        EndIf

        //Acrescenta o reembolso do titular
        If Len(aHDetail) > 0
            oItem["holderDetail"] := aClone(aHDetail)
        EndIf

        //Varre o array com dados dos Dependentes
        If aDados[nX]:HasProperty("DEPENDENTES")        
            For nY := 1 To Len(aDados[nX]["DEPENDENTES"])
                oReimbDep        := JsonObject():New()
                oReimbDep["cpf"] := aDados[nX]["DEPENDENTES"][nY]["CPF"]    //CPF do Dependente
                
                //Varre o array de itens do dependente
                For nZ := 1 To Len(aDados[nX]["DEPENDENTES"][nY]["ITEMDEP"])
                    oItemDep    := JsonObject():New()

                    oItemDep["registrationType"]    := aDados[nX]["DEPENDENTES"][nY]["ITEMDEP"][nZ]["TIPOINSC"] //Tipo de inscrição
                    oItemDep["registrationNumber"]  := aDados[nX]["DEPENDENTES"][nY]["ITEMDEP"][nZ]["NUMINSC"]  //Número de inscrição
                    oItemDep["registrationType"]    := aDados[nX]["DEPENDENTES"][nY]["ITEMDEP"][nZ]["TIPOINSC"] //Tipo de inscrição

                    oVal := JsonObject():New()
                    oVal["erpValue"] 	:= aDados[nX]["DEPENDENTES"][nY]["ITEMDEP"][nZ]["NVLRERP"]    //Valor de dedução
                    oVal["retValue"] 	:= aDados[nX]["DEPENDENTES"][nY]["ITEMDEP"][nZ]["NVLRRET"]    //Valor Governo
                    oVal["divergent"] 	:= oVal["erpValue"] <> oVal["retValue"] 

                    oItemDep["values"]  :=  oVal
                    
                    aAdd(aItemDep, oItemDep)

                    FreeObj(oItemDep)
                    FreeObj(oVal)
                Next nZ
                
                oReimbDep["dependentDetail"] := aClone(aItemDep) //Itens do Dependente

                aAdd(aReimbDep, oReimbDep)
                
                aItemDep := {}
                FreeObj(oReimbDep)
                FreeObj(oVal)
            Next nY
        EndIf

        //Acrescenta o reembolso do dependente
        If Len(aReimbDep) > 0
            oItem["reimbursementDependent"] := aClone(aReimbDep)
        EndIf

        aHDetail    := {}
        aReimbDep   := {}

        aAdd(aRet, oItem)
        FreeObj(oItem)
    Next nX

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fIfPrev
Monta array com dados de previdência privada por código de receita
Return array - Exemplo {{356201,oPrev},{056207,oPrev}}
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fIfPrev(aDados, cCodRec)

    Local cCodCR    := ""
    Local aIfPrev   := {}
    Local aRet      := {}
    Local aItem     := {}
    Local nX        := 0

    Default aDados  := {}
    Default cCodRec := ""

    If Len(aDados) > 0     
        //Garante a ordenação Código de Receita + CPF
        ASort( aDados, , , {|x,y| x[5]+x[7] < y[5]+y[7]} )
        
        //Varre o array de Dados
        For nX := 1 To Len(aDados)
            //Se houver filtro por código de receita, respeita esse filtro
            If Empty(cCodRec) .Or. aDados[nX][5] $ cCodRec               
                //Se alterou o código de receita armeneza os dados no array de retorno
                If !Empty(aIfPrev) .And. cCodCR <> aDados[nX][5]
                    aAdd(aRet,{cCodCR, aClone(aIfPrev)})
                    aIfPrev := {}
                EndIf

                cCodCR  := aDados[nX][5]
                aItem   := fObjDetPre(aDados[nX])
                If Len(aItem) > 0
                    aAdd(aIfPrev, aClone(aItem)[1])
                EndIf

                aItem := {}
            EndIf
        Next nX
    EndIf

    //Guarda pensão alimentícia do último CR processado
    If !Empty(aIfPrev)
        aAdd(aRet,{cCodCR, aClone(aIfPrev)})
    EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fObjDetPre
Monta objeto com os detalhes da pensão
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fObjDetPre(aDados)

	Local oDados    := Nil
    Local aRet      := {}

    Default aDados  := {} 

    If Len(aDados) > 0
        oDados  := JsonObject():New()
        oDados["TPPREV"] 	:= aDados[3]            //Tipo de Previdência
        oDados["CNPJ"] 	    := aDados[2]            //CNPJ do Fornecedor
        oDados["NVLRERP"] 	:= aDados[4]            //Valor de dedução
        oDados["NVLRRET"] 	:= 0                    //Valor Governo
        oDados["NVLRERP13"] := aDados[6]            //Valor Governo
        oDados["NVLRRET13"] := 0                    //Valor Governo
        aAdd( aRet, oDados )
    
        FreeObj(oDados)
    EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fPrivPen
Monta objeto com os detalhes de previdência privada para a detailsOfEmployee
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fPrivPen(aDados)

	Local oItem     := Nil
    Local oVal      := Nil
    Local aRet      := {}
    Local nX        := 0
    Local cDescT    := ""

    Default aDados  := {}

    For nX := 1 To Len(aDados)
        oVal    := JsonObject():New()
        oval13  := JsonObject():New()
        oItem   := JsonObject():New()

        //Encontra a descrição do tipo de previdência
        If aDados[nX]["TPPREV"] == "1"
            cDescT := "Privada"
        ElseIf aDados[nX]["TPPREV"] == "2"
            cDescT := "FAPI"
        ElseIf aDados[nX]["TPPREV"] == "3"
            cDescT := "Funpresp"
        EndIf
        
        oItem["pensionType"] 	:= cDescT                //Tipo de Rendimento
        oItem["cnpj"] 		    := aDados[nX]["CNPJ"]   //CNPJ do Fornecedor de previdência

        oVal["erpValue"] 	:= Iif(aDados[nX]["TPPREV"] $ "1|2", aDados[nX]["NVLRERP"], 0)  //Valor de dedução
        oVal["retValue"] 	:= Iif(aDados[nX]["TPPREV"] $ "1|2", aDados[nX]["NVLRRET"], 0)  //Valor Governo
        oVal["divergent"] 	:= oVal["erpValue"] <> oVal["retValue"] 
        
        oItem["values"]       := oVal

        oVal13["erpValue"]  := Iif(aDados[nX]["TPPREV"] $ "1|2", aDados[nX]["NVLRERP13"], 0)    //Valor de dedução
        oVal13["retValue"] 	:= Iif(aDados[nX]["TPPREV"] $ "1|2", aDados[nX]["NVLRRET13"], 0)    //Valor Governo
        oVal13["divergent"] := oVal13["erpValue"] <> oVal13["retValue"]

        oItem["values13"]    := oVal13

        //Acrescenta dados se for Funpresp
        If aDados[nX]["TPPREV"] == "3"
            FreeObj(oVal)
            FreeObj(oVal13)

            oVal    := JsonObject():New()
            oval13  := JsonObject():New()     

            oVal["erpValue"] 	:= aDados[nX]["NVLRERP"]  //Valor de dedução
            oVal["retValue"] 	:= aDados[nX]["NVLRRET"]  //Valor Governo
            oVal["divergent"] 	:= oVal["erpValue"] <> oVal["retValue"] 
            
            oItem["publicServantValue"]       := oVal

            oVal13["erpValue"]  := aDados[nX]["NVLRERP13"]  //Valor de dedução
            oVal13["retValue"] 	:= aDados[nX]["NVLRRET13"]  //Valor Governo
            oVal13["divergent"] := oVal13["erpValue"] <> oVal13["retValue"]

            oItem["publicServantValue13"]    := oVal13
        EndIf

        aAdd(aRet, oItem)

        FreeObj(oVal)
        FreeObj(oVal13)
        FreeObj(oItem)      
    Next nX

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} fPrevCGov
Alimenta as informações de deduções de dependente e pensão do RET
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fPrevCGov(aFiliais, cCPF, aReqCR)

    Local cQuery        := ""
    Local cAlias        := "PREVCGOV"
    Local cObjCR        := ""
    Local nPosFunc      := 0
    Local nPosForn      := 0
    Local nParamOrder   := 1
    
    Default aFiliais    := {}
    Default aReqCR      := {}
    Default cCPF        := ""

    If __oSt03 == Nil
        __oSt03 := FWPreparedStatement():New()
        cQuery := "SELECT RUS_CODREC, RUS_CPF, RUS_TPPREV, RUS_CNPJPC, RUS_VLPC, RUS_VLPC13, RUS_VLPF, RUS_VLPF13"
        cQuery += "FROM " + RetSqlName('RUS') + " RUS "
        cQuery += "WHERE RUS.RUS_FILIAL IN (?) AND "
        cQuery += 		"RUS.RUS_CPF = ? AND "
        If Len(aReqCR) > 0
            cQuery += 	"RUS.RUS_CODREC IN (?) AND "            
        EndIf
        cQuery += 		"RUS.D_E_L_E_T_ = ? "
        cQuery := ChangeQuery(cQuery)
        __oSt03:SetQuery(cQuery)
    EndIf
    __oSt03:SetIN(nParamOrder++, aFiliais)
    __oSt03:SetString(nParamOrder++, cCPF)
    If Len(aReqCR) > 0
        __oSt03:SetIN(nParamOrder++, aReqCR)         
    EndIf
    __oSt03:SetString(nParamOrder++, " ")
    cQuery := __oSt03:getFixQuery()
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

    //Ajuste os valores GOV no objeto de código de receita
    While (cAlias)->(!Eof())
        cObjCR := "oCR" + (cAlias)->RUS_CODREC 

        If nPosFunc == 0 .Or. (cChvPosFun <> ((cAlias)->RUS_CODREC + (cAlias)->RUS_CPF))
            nPosFunc    := aScan(&cObjCR["FUNCIONARIOS"], { |x| x["CPF"] == (cAlias)->RUS_CPF })
            cChvPosFun  := (cAlias)->RUS_CODREC + (cAlias)->RUS_CPF
        EndIf

        If nPosFunc > 0
            If (cAlias)->RUS_TPPREV $ "1|2"
                nPosForn := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PREVCOMP"], {|x| x["TPPREV"]+x["CNPJ"] == (cAlias)->RUS_TPPREV + (cAlias)->RUS_CNPJPC})
                
                If nPosForn > 0
                    &cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PREVCOMP"][nPosForn]["NVLRRET"] := (cAlias)->RUS_VLPC
                    &cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PREVCOMP"][nPosForn]["NVLRRET13"] := (cAlias)->RUS_VLPC13
                EndIf
            ElseIf (cAlias)->RUS_TPPREV == "3"
                nPosForn := aScan(&cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PREVCOMP"], {|x| x["CNPJ"] == (cAlias)->RUS_CNPJPC})
                
                If nPosForn > 0
                    &cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PREVCOMP"][nPosForn]["NVLRRET"] := (cAlias)->RUS_VLPF
                    &cObjCR["FUNCIONARIOS"][nPosFunc]["INFOCOMPLEM"]["PREVCOMP"][nPosForn]["NVLRRET13"] := (cAlias)->RUS_VLPF13
                EndIf
            EndIf
        EndIf

        (cAlias)->(dbSkip())
    EndDo

    (cAlias)->(DBCloseArea())

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} fAltTrab
Altera arquivo de trabalho se for preciso avaliar os divergentes.
@author lidio.oliveira
@since 23/12/2025
/*/
//-------------------------------------------------------------------
Static Function fAltTrab(aArqTrab)

    Local oTotIRDiv := Nil
    Local oDetCRDiv := Nil
    Local oVlrCRDiv := Nil
    Local aArqDiv   := {}
    Local aNewTrab  := {}
    Local aNewCRs   := {}
    Local aFuncCR   := {}
    Local aListTpIR := {}
    Local nVlrERP   := 0
    Local nVlrRET   := 0
    Local nX        := 0
    Local nY        := 0
    Local nZ        := 0
    
    Default aArqTrab := {}

    If !Empty(aArqTrab)
        aArqDiv := aClone(aArqTrab)

        oTotIRDiv   := JsonObject():New()

        oTotIRDiv["totalIrrfErp"] := 0
        oTotIRDiv["totalIrrfRet"] := 0  

        aAdd(aListTpIR, "TOTALIRRFCR")
        aAdd(aListTpIR, "VLRRENDTRIB")
        aAdd(aListTpIR, "VLRRENDTRIB13")
        aAdd(aListTpIR, "VLRPREVOFICIAL")
        aAdd(aListTpIR, "VLRPREVOFICIAL13")
        aAdd(aListTpIR, "VLRCRMEN")
        aAdd(aListTpIR, "VLRCR13MEN")
        aAdd(aListTpIR, "VLRPARCISENTA65")
        aAdd(aListTpIR, "VLRPARCISENTA65DEC")
        aAdd(aListTpIR, "VLRDIARIAS")
        aAdd(aListTpIR, "VLRAJUDACUSTO")
        aAdd(aListTpIR, "VLRINDRESCONTRATO")
        aAdd(aListTpIR, "VLRABONOPEC")
        aAdd(aListTpIR, "VLRRENDMOLEGRAVE")
        aAdd(aListTpIR, "VLRRENDMOLEGRAVE13")
        aAdd(aListTpIR, "VLRAUXMORADIA")
        aAdd(aListTpIR, "VLRBOLSAMEDICO")
        aAdd(aListTpIR, "VLRBOLSAMEDICO13")
        aAdd(aListTpIR, "VLRJUROSMORA")
        aAdd(aListTpIR, "VLRISENOUTROS")
        
        For nX := 1 To Len(aArqDiv[2])
            oDetCRDiv       := JsonObject():New()
            oDetCRDiv["CR"] := aArqDiv[2][nX]["CR"]

            For nY := 1 To Len(aArqDiv[2][nX]["FUNCIONARIOS"])
                If aArqDiv[2][nX]["FUNCIONARIOS"][nY]["NVLRERP"] <> aArqDiv[2][nX]["FUNCIONARIOS"][nY]["NVLRRET"]
                    aAdd(aFuncCR, aArqDiv[2][nX]["FUNCIONARIOS"][nY])
                    For nZ := 1 To Len(aListTpIR)
                        If aArqDiv[2][nX]["FUNCIONARIOS"][nY]:HasProperty(aListTpIR[nZ])
                            oVlrCRDiv   := JsonObject():New()
                            
                            nVlrERP := aArqDiv[2][nX]["FUNCIONARIOS"][nY][aListTpIR[nZ]]["NVLRERP"]
                            nVlrRET := aArqDiv[2][nX]["FUNCIONARIOS"][nY][aListTpIR[nZ]]["NVLRRET"]
                            
                            If oDetCRDiv:HasProperty(aListTpIR[nZ])
                                oDetCRDiv[aListTpIR[nZ]]["NVLRERP"] += nVlrERP
                                oDetCRDiv[aListTpIR[nZ]]["NVLRRET"] += nVlrRET
                            Else
                                oVlrCRDiv["NVLRERP"] := nVlrERP
                                oVlrCRDiv["NVLRRET"] := nVlrERP

                                oDetCRDiv[aListTpIR[nZ]] := oVlrCRDiv
                            EndIf

                            If aListTpIR[nZ] $ "VLRCRMEN|VLRCRMEN13"
                                If oDetCRDiv:HasProperty("TOTALIRRFCR")
                                    oDetCRDiv["TOTALIRRFCR"]["NVLRERP"] += nVlrERP
                                    oDetCRDiv["TOTALIRRFCR"]["NVLRRET"] += nVlrRET
                                Else
                                    oVlrCRDiv["NVLRERP"] := nVlrERP
                                    oVlrCRDiv["NVLRRET"] := nVlrRET

                                    oDetCRDiv["TOTALIRRFCR"] := oVlrCRDiv
                                EndIf                                
                            EndIf

                            FreeObj(oVlrCRDiv)
                        EndIf
                    Next nZ
                EndIf
            Next nY
            
            oDetCRDiv["FUNCIONARIOS"] := aClone(aFuncCR)
            aAdd(aNewCRs, oDetCRDiv)

            If oDetCRDiv:HasProperty("TOTALIRRFCR")
                oTotIRDiv["totalIrrfErp"] += oDetCRDiv["TOTALIRRFCR"]["NVLRERP"]
                oTotIRDiv["totalIrrfRet"] += oDetCRDiv["TOTALIRRFCR"]["NVLRRET"]           
            EndIf

            aFuncCR := {}
            FreeObj(oDetCRDiv)
        Next nX

        aAdd(aNewTrab, oTotIRDiv)
        aAdd(aNewTrab, aClone(aNewCRs))

        FreeObj(oTotIRDiv)
    EndIf

    If !Empty(aNewTrab)
        aArqTrab := aClone(aNewTrab)
    EndIf

Return
