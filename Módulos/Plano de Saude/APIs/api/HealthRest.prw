#INCLUDE 'protheus.ch'
#INCLUDE 'restful.ch'

#DEFINE ALL "02"

//-------------------------------------------------------------------
/*/{Protheus.doc} APIs Padrão do PLS

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
WsRestful totvsHealthPlans Description "Serviços Rest dedicados a integrações padrões TOTVS Saúde Planos" Format APPLICATION_JSON

    //Atributos gerais padrao guia TOTVS - https://api.totvs.com.br/guia
    WSDATA apiVersion   as STRING OPTIONAL
    WSDATA fields       as STRING OPTIONAL
    WSDATA page         as STRING OPTIONAL
    WSDATA pageSize     as STRING OPTIONAL
    WSDATA filter       as STRING OPTIONAL
    WSDATA expand       as STRING OPTIONAL
    WSDATA order        as STRING OPTIONAL
    
    //Atributos userUsage obrigatorios
    WSDATA subscriberId   as STRING OPTIONAL
    WSDATA initialPeriod  as STRING OPTIONAL
    WSDATA finalPeriod    as STRING OPTIONAL

    //Atributos userUsage opcionais
    WSDATA procedureCode  as STRING OPTIONAL
    WSDATA executionDate as STRING OPTIONAL
    WSDATA healthProviderCode as STRING OPTIONAL
    WSDATA locationCode as STRING OPTIONAL
    WSDATA healthProviderDocument as STRING OPTIONAL
    WSDATA cid as STRING OPTIONAL
    WSDATA procedureName as STRING OPTIONAL
    WSDATA healthProviderName as STRING OPTIONAL
    WSDATA quantity as STRING OPTIONAL
    WSDATA toothRegion as STRING OPTIONAL
    WSDATA face as STRING OPTIONAL
    
    //Atributos internação
    WSDATA authorizationId as STRING OPTIONAL

    //Atributos glossedAppeal
    WsData protocol         as string optional
    WsData formNumber       as string optional
    WsData justification    as string optional
    WsData operation        as string optional
    WsData items            as string optional
    WsData appealProtocol   as string optional
    WsData status           as string optional
    WsData sequential       as string optional

    //Atributos knowledgeBank
    WsData alias            as string optional
    WsData attachmentsKey   as string optional
    WsData fileName         as string optional
    WsData file             as string optional
    WsData attendanceProtocol   as string optional
    WsData idOnHealthInsurer    as string optional

    //atributos elegibilidade
    WsData cardNumberOrCpf as string optional
    WsData eligibilityType as string optional

    //atributos autorizacao de procedimentos
    WsData procedureId as string optional 

    //atributos authorizations
    WsData idHealthIns as string optional
    WsData authorizationType as string optional
    WSDATA resendBatch as Boolean optional
    WsData action as string optional
    WsData codRda as string optional

    //atributos clinicalStaff
    WSDATA specialtyCode as string optional
    WsData id as integer optional

    //atributos procedures
    WSDATA customWhere as string optional
    WSDATA tableCode as string optional
    WSDATA teethRegionId as string optional

    //atributos authorizationBatch
    WSDATA batchCode as string optional

    //atributos healthProviders
    WSDATA healthProviderId as string optional
    WSDATA attendanceLocation as string optional
    WSDATA stateAbbreviation as string optional
    WSDATA professionalCouncil as string optional
    WSDATA professionalCouncilNumber as string optional
    WSDATA officialRecord as string optional
    WSDATA professionalType as string optional
    WSDATA healthProviderType as string optional
    WSDATA name as string optional
    WSDATA filterClinicalStaffRequest as Boolean optional
    WSDATA filterClinicalStaffExecution as Boolean optional
    WSDATA email as string optional
    WSDATA cpf as string optional

    WSDATA showDeniedProc as Boolean optional
	WSDATA initialSituation AS Boolean optional 

    WSDATA professionalCode as string optional
    WSDATA isOdonto as Boolean optional

    WSDATA month as string optional
    WSDATA year as string optional

    WSDATA beneficiaryId as STRING  OPTIONAL
    WSDATA operatorId as STRING  OPTIONAL
    WSDATA calcType as STRING OPTIONAL

    WSDATA elapTime as STRING  OPTIONAL


    //Endpoints
    WSMETHOD GET userUsage DESCRIPTION "" ;
    WSsyntax "{apiVersion}/userUsage" ;
    PATH "{apiVersion}/userUsage" PRODUCES APPLICATION_JSON
    
    WSMETHOD POST glossedAppeal DESCRIPTION "" ;
    WSsyntax "{apiVersion}/glossedAppeal" ;
    PATH "{apiVersion}/glossedAppeal" PRODUCES APPLICATION_JSON

    WSMETHOD GET glossedAppeal DESCRIPTION "" ;
    WSsyntax "{apiVersion}/glossedAppeal" ;
    PATH "{apiVersion}/glossedAppeal" PRODUCES APPLICATION_JSON

    WSMETHOD GET itemAppeal DESCRIPTION "" ;
    WSsyntax "{apiVersion}/itemAppeal" ;
    PATH "{apiVersion}/itemAppeal" PRODUCES APPLICATION_JSON

    WSMETHOD GET appealValid DESCRIPTION "" ;
    WSsyntax "{apiVersion}/appealValid" ;
    PATH "{apiVersion}/appealValid" PRODUCES APPLICATION_JSON

    WSMETHOD GET knowledgeBank DESCRIPTION "" ;
    WSsyntax "{apiVersion}/knowledgeBank" ;
    PATH "{apiVersion}/knowledgeBank" PRODUCES APPLICATION_JSON

    WSMETHOD POST knowledgeBank DESCRIPTION "" ;
    WSsyntax "{apiVersion}/knowledgeBank" ;
    PATH "{apiVersion}/knowledgeBank" PRODUCES APPLICATION_JSON

    WSMETHOD PUT knowledgeBank DESCRIPTION "" ;
    WSsyntax "{apiVersion}/knowledgeBank/{attachmentsKey}" ;
    PATH "{apiVersion}/knowledgeBank/{attachmentsKey}" PRODUCES APPLICATION_JSON

    WSMETHOD POST postAuditXml DESCRIPTION "" ;
    WSsyntax "{apiVersion}/postAuditXml" ;
    PATH "{apiVersion}/postAuditXml" PRODUCES APPLICATION_JSON

    WSMETHOD PUT batchNotes DESCRIPTION "Alteração do campo de notas de um lote" ;
    WSsyntax "{apiVersion}/batchNotes/{protocol}";
    PATH "{apiVersion}/batchNotes/{protocol}" PRODUCES APPLICATION_JSON  

    WSMETHOD PUT hospitalizationDate DESCRIPTION "Informar data de internação/alta" ;
    WSsyntax "{apiVersion}/hospitalizationDate/{authorizationId}";
    PATH "{apiVersion}/hospitalizationDate/{authorizationId}" PRODUCES APPLICATION_JSON  

    WSMETHOD POST tokenBenef DESCRIPTION "Retorna o token de atendimento de um beneficiario" ;
    WSsyntax "{apiVersion}/tokenBenef/{subscriberId}";
    PATH "{apiVersion}/tokenBenef/{subscriberId}" PRODUCES APPLICATION_JSON 

    //************** integracao HAT *******************

    WSMETHOD GET beneficiaryElegibility DESCRIPTION "Find beneficiary by CPF or CARD NUMBER" ;
        WSsyntax "{apiVersion}/beneficiaryElegibility";
        PATH "{apiVersion}/beneficiaryElegibility" PRODUCES APPLICATION_JSON

    WSMETHOD POST procedureAuthorization DESCRIPTION "Authorization of procedure" ;
        WSsyntax "{apiVersion}/procedureAuthorization" ;
        PATH "{apiVersion}/procedureAuthorization" PRODUCES APPLICATION_JSON

    WSMETHOD GET authorizations DESCRIPTION "Retorna os dados do atendimento de um beneficiario" ;
        WSsyntax "{apiVersion}/authorizations/{idHealthIns}";
        PATH "{apiVersion}/authorizations/{idHealthIns}" PRODUCES APPLICATION_JSON 

    WSMETHOD GET cliAttach DESCRIPTION "Retorna os anexos clinicos de uma guia" ;
        WSsyntax "{apiVersion}/authorizations/{idHealthIns}/clinicalAttachments";
        PATH "{apiVersion}/authorizations/{idHealthIns}/clinicalAttachments" PRODUCES APPLICATION_JSON

    WSMETHOD GET treatExt DESCRIPTION "Retorna as prorrogacoes de uma guia" ;
        WSsyntax "{apiVersion}/authorizations/{idHealthIns}/treatmentExtensions";
        PATH "{apiVersion}/authorizations/{idHealthIns}/treatmentExtensions" PRODUCES APPLICATION_JSON

    WSMETHOD GET iniSituac DESCRIPTION "Retorna as prorrogacoes de uma guia" ;
        WSsyntax "{apiVersion}/authorizations/{idHealthIns}/initialSituation";
        PATH "{apiVersion}/authorizations/{idHealthIns}/initialSituation" PRODUCES APPLICATION_JSON

    WSMETHOD POST authorizations DESCRIPTION "Verifica se pode realizar o reenvio de uma Solic TISS online no HAT" ;
        WSsyntax "{apiVersion}/authorizations" ;
        PATH "{apiVersion}/authorizations" PRODUCES APPLICATION_JSON

    WSMETHOD POST authCancel DESCRIPTION "Cancela uma guia" ;
        WSsyntax "{apiVersion}/authorizations/{idHealthIns}/cancel" ;
        PATH "{apiVersion}/authorizations/{idHealthIns}/cancel" PRODUCES APPLICATION_JSON

    WSMETHOD POST pegTransfer DESCRIPTION "Realiza a transferencias de guias para PEGs de faturamento" ;
        WSsyntax "{apiVersion}/pegTransfer" ;
        PATH "{apiVersion}/pegTransfer" PRODUCES APPLICATION_JSON

    WSMETHOD DELETE pegTransfer DESCRIPTION "Realiza a exclusão de guias de PEGs de faturamento" ;
        WSsyntax "{apiVersion}/pegTransfer" ;
        PATH "{apiVersion}/pegTransfer" PRODUCES APPLICATION_JSON

    WSMETHOD POST postProf DESCRIPTION "Cadastra profissional de Saude" ;
        WSsyntax "{apiVersion}/professionals" ;
        PATH "{apiVersion}/professionals" PRODUCES APPLICATION_JSON

    WSMETHOD GET profColl DESCRIPTION "Busca profissionais de saude" ;
		WSsyntax "{apiVersion}/professionals" ;
		PATH "{apiVersion}/professionals" PRODUCES APPLICATION_JSON

    WSMETHOD GET profSpecialty DESCRIPTION "Especialidades de um profissional" ;
		WSsyntax "{apiVersion}/professionals/{professionalCode}/professionalSpecialities" ;
		PATH "{apiVersion}/professionals/{professionalCode}/professionalSpecialities" PRODUCES APPLICATION_JSON

    WSMETHOD GET profCbos DESCRIPTION "CBOS de um profissional" ;
		WSsyntax "{apiVersion}/professionals/{professionalCode}/cbos" ;
		PATH "{apiVersion}/professionals/{professionalCode}/cbos" PRODUCES APPLICATION_JSON

    WSMETHOD GET cbos DESCRIPTION "CBOS de um prestador" ;
		WSsyntax "{apiVersion}/cbos" ;
		PATH "{apiVersion}/cbos" PRODUCES APPLICATION_JSON

    WSMETHOD GET accreditations DESCRIPTION "Acreditacoes do prestador" ;
        WSsyntax "{apiVersion}/accreditations" ;
        PATH "{apiVersion}/accreditations" PRODUCES APPLICATION_JSON
    
    WSMETHOD GET healthProviders DESCRIPTION "Dados de um prestador" ;
        WSsyntax "{apiVersion}/healthProviders/{healthProviderCode}" ;
        PATH "{apiVersion}/healthProviders/{healthProviderCode}" PRODUCES APPLICATION_JSON

    WSMETHOD GET provItem DESCRIPTION "Dados de um prestador" ;
        WSsyntax "{apiVersion}/healthProviders" ;
        PATH "{apiVersion}/healthProviders" PRODUCES APPLICATION_JSON

    WSMETHOD GET hPrSpecialty DESCRIPTION "Especialidades de um prestador" ;
		WSsyntax "{apiVersion}/healthProviders/{healthProviderCode}/healthProviderSpecialities" ;
		PATH "{apiVersion}/healthProviders/{healthProviderCode}/healthProviderSpecialities" PRODUCES APPLICATION_JSON

    WSMETHOD GET clinicalStaff DESCRIPTION "Retorna Corpo Clinico" ;
        WSsyntax "{apiVersion}/clinicalStaff" ;
        PATH "{apiVersion}/clinicalStaff" PRODUCES APPLICATION_JSON

    WSMETHOD POST clinicalStaff DESCRIPTION "Adiciona um profissional em um corpo clinico" ;
        WSsyntax "{apiVersion}/clinicalStaff" ;
        PATH "{apiVersion}/clinicalStaff" PRODUCES APPLICATION_JSON

    WSMETHOD PUT blockClinicallStaff DESCRIPTION "Bloqueia um profissional do corpo clinico" ;
        WSsyntax "{apiVersion}/clinicalStaff/{id}/block" ;
        PATH "{apiVersion}/clinicalStaff/{id}/block" PRODUCES APPLICATION_JSON

    WSMETHOD POST apoInfo DESCRIPTION "Retorna os status dos fontes passados no body" ;
        WSsyntax "{apiVersion}/apoInfo" ;
        PATH "{apiVersion}/apoInfo" PRODUCES APPLICATION_JSON

     WSMETHOD GET paymentCalendar DESCRIPTION "Retorna o periodo do calendario de pagamento" ;
        WSsyntax "{apiVersion}/paymentCalendar" ;
        PATH "{apiVersion}/paymentCalendar" PRODUCES APPLICATION_JSON    

    WSMETHOD GET ProcCol DESCRIPTION "Pesquisa de procedimentos para execucao" ;
        WSsyntax "{apiVersion}/procedures" ;
        PATH "{apiVersion}/procedures" PRODUCES APPLICATION_JSON

    WSMETHOD GET ProcSgl DESCRIPTION "Pesquisa de procedimentos para execucao" ;
        WSsyntax "{apiVersion}/procedures/{procedureId}" ;
        PATH "{apiVersion}/procedures/{procedureId}" PRODUCES APPLICATION_JSON

    WSMETHOD GET tothReg DESCRIPTION "Pesquisa de procedimentos para execucao" ;
        WSsyntax "{apiVersion}/procedures/{procedureId}/teethRegions/" ;
		PATH "{apiVersion}/procedures/{procedureId}/teethRegions/" PRODUCES APPLICATION_JSON

    WSMETHOD GET surfaces DESCRIPTION "" ;
		WSsyntax "{apiVersion}/procedures/{procedureId}/teethRegions/{teethRegionId}/surfaces" ;
		PATH "{apiVersion}/procedures/{procedureId}/teethRegions/{teethRegionId}/surfaces" PRODUCES APPLICATION_JSON
    
    WSMETHOD GET batchesAuthorization DESCRIPTION "" ;
        WSsyntax "{apiVersion}/batchesAuthorization" ;
        PATH "{apiVersion}/batchesAuthorization" PRODUCES APPLICATION_JSON

    WSMETHOD PUT authorizationBatch DESCRIPTION "Alteração do campo correspondente ao lote do HAT de uma guia" ;
        WSsyntax "{apiVersion}/authorizationBatch";
        PATH "{apiVersion}/authorizationBatch" PRODUCES APPLICATION_JSON   

    WSMETHOD GET authBatch DESCRIPTION "" ;
        WSsyntax "{apiVersion}/authorizationBatch/{batchCode}" ;
        PATH "{apiVersion}/authorizationBatch/{batchCode}" PRODUCES APPLICATION_JSON
    
    WSMETHOD GET patientHealthcareFacility DESCRIPTION "" ;
        WSsyntax "{apiVersion}/patientHealthcareFacility" ;
        PATH "{apiVersion}/patientHealthcareFacility" PRODUCES APPLICATION_JSON
    
    WSMETHOD POST benefPortalPassRec DESCRIPTION "" ;
        WSsyntax "{apiVersion}/benefPortalPassRec" ;
        PATH "{apiVersion}/benefPortalPassRec" PRODUCES APPLICATION_JSON

    WSMETHOD POST firstAccess DESCRIPTION "" ;
        WSsyntax "{apiVersion}/BenefFirstAccess" ;
        PATH "{apiVersion}/BenefFirstAccess" PRODUCES APPLICATION_JSON

    WSMETHOD GET executions DESCRIPTION "Lista execuções de tratamento seriado" ;
        WSsyntax "{apiVersion}/executions/{idHealthIns}" ;
        PATH "{apiVersion}/executions/{idHealthIns}" PRODUCES APPLICATION_JSON

     WSMETHOD GET batchCover DESCRIPTION "" ;
        WSsyntax "{apiVersion}/batchCover" ;
        PATH "{apiVersion}/batchCover" PRODUCES APPLICATION_JSON

    WSMETHOD POST passwordRecovery DESCRIPTION "" ;
        WSsyntax "{apiVersion}/passwordRecovery" ;
        PATH "{apiVersion}/passwordRecovery" PRODUCES APPLICATION_JSON

    // Manutenção Cadastral do Beneficiário
    WSMETHOD POST SolCanBenef DESCRIPTION "Solicita protocolo de bloqueio dos beneficiários pela RN 402" ;
    WSsyntax "{version}/beneficiaries/{subscriberId}/block" ;
    PATH "{version}/beneficiaries/{subscriberId}/block" PRODUCES APPLICATION_JSON

    WSMETHOD GET RetCanBenef DESCRIPTION "Retorna solicitação de protocolo de bloqueio do beneficiários" ;
    WSsyntax "{version}/beneficiaries/{subscriberId}/block" ;
    PATH "{version}/beneficiaries/{subscriberId}/block" PRODUCES APPLICATION_JSON

    WSMETHOD GET competenceProtocols DESCRIPTION "Retorna os dados da competencia do prestador" ;
    WSsyntax "{apiVersion}/competenceProtocols" ;
    PATH "{apiVersion}/competenceProtocols" PRODUCES APPLICATION_JSON

    WSMETHOD PUT updtStatusCompetence DESCRIPTION "Altera o status de uma competencia do prestador" ;
    WSsyntax "{apiVersion}/competenceProtocols/{sequential}" ;
    PATH "{apiVersion}/competenceProtocols/{sequential}" PRODUCES APPLICATION_JSON

    WSMETHOD GET dentalTreatment DESCRIPTION "Retorna liberações odonto de um beneficiario" ;
        WSsyntax "{apiVersion}/dentalTreatment/{beneficiaryId}";
        PATH "{apiVersion}/dentalTreatment/{beneficiaryId}" PRODUCES APPLICATION_JSON 
    
    WSMETHOD GET serialTreatment DESCRIPTION "Retorna tratamentos seriados de um beneficiario" ;
        WSsyntax "{apiVersion}/serialTreatment/{beneficiaryId}";
        PATH "{apiVersion}/serialTreatment/{beneficiaryId}" PRODUCES APPLICATION_JSON 

End WsRestful


//-------------------------------------------------------------------
/*/{Protheus.doc} userUsage
Extrato de utilização de beneficiários de saúde

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
WSMETHOD GET userUsage QUERYPARAM page, pageSize, fields, expand, order, initialPeriod, finalPeriod, subscriberId, ;
                                  procedureCode, executionDate, healthProviderCode, healthProviderDocument, cid, ;
                                  procedureName, healthProviderName, quantity, toothRegion, face WSSERVICE totvsHealthPlans
        
    Local oRequest

    Default self:fields    := ""
    Default self:page      := "1"
    Default self:pageSize  := "20"
    Default self:expand    := ""
    Default self:order     := ""
    //Atributos de Pesquisa
    Default self:subscriberId  := ""
    Default self:initialPeriod := ""
    Default self:finalPeriod   := ""
    //Atributos de Pesquisa opcionais
    Default self:procedureCode := ""
    Default self:executionDate := ""
    Default self:healthProviderCode := ""
    Default self:healthProviderDocument := ""
    Default self:cid := ""
    Default self:procedureName := ""
    Default self:healthProviderName := ""
    Default self:quantity := ""
    Default self:toothRegion := ""
    Default self:face := ""

    oRequest := PLUtzUsReq():New(self)
    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyPageSize()
        oRequest:buscar()
        oRequest:procGet(ALL)
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} glossedAppeal

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod POST glossedAppeal WSService totvsHealthPlans
    local oRequest 	                    := PLSGlosaRequest():new(self)
    default self:protocol               := ""
    default self:formNumber             := ""
    default self:operation              := ""
    default self:items                  := ""
    default self:justification          := ""
    default self:healthProviderCode     := ""    

    oRequest:initRequest()

    if oRequest:checkAuth() .and. oRequest:checkBody() 
        oRequest:inclui()
    endif

    cJson := EncodeUTF8(FWJsonSerialize(oRequest:oJson))
    ::setResponse(cJson)

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} glossedAppeal

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET glossedAppeal QUERYPARAM healthProviderCode, page, pageSize, fields, expand, order, protocol, formNumber,;
                                        initialPeriod, finalPeriod, appealProtocol, status WSService totvsHealthPlans

    local oRequest 	            := nil
    default self:formNumber     := ""
    default self:fields         := ""
    default self:page           := "1"
    default self:pageSize       := "20"
    default self:expand         := ""
    default self:order          := ""
    //Atributos de Pesquisa
    default self:initialPeriod  := ""
    default self:finalPeriod    := ""

    oRequest := PLSB4DReq():New(self)
    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyPageSize()
        oRequest:buscar()
        oRequest:procGet(ALL)
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} itemAppeal

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET itemAppeal QUERYPARAM healthProviderCode, sequential, page, pageSize, fields, expand, order, status WSService totvsHealthPlans

    local oRequest 	            := nil
    default self:fields         := ""
    default self:page           := "1"
    default self:pageSize       := "20"
    default self:expand         := ""
    default self:order          := ""
    default self:status         := ""

    oRequest := PLSB4EReq():New(self)
    oRequest:initRequest()
    if oRequest:checkAuth()
        oRequest:applyFilter(ALL)
        oRequest:applyFields(self:fields)
        oRequest:applyOrder(self:order)
        oRequest:applyPageSize()
        oRequest:buscar()
        oRequest:procGet(ALL)
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} appealValid

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET appealValid QUERYPARAM protocol, formNumber, healthProviderCode WSService totvsHealthPlans
    local oRecurso 	            := PLSGlosaValid():new(self)
    local lResult 		        := oRecurso:get()
    default self:formNumber     := ""    

    freeObj(oRecurso)
    oRecurso := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} knowledgeBank

@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod GET knowledgeBank QUERYPARAM attachmentsKey, fileName WSService totvsHealthPlans
    local oAC9 	            := PLSAC9Req():new(self)

    if( !empty(self:fileName) )
        oAC9:get() // retornamos o arquivo selecionado em base 64 para ser exibido em tela 
    elseif (!empty(self:attachmentsKey))
        oAC9:getFiles() // retornamos os arquivos para serem exibidos na grid vinculados a guia
    else 
        oAC9:setGetError()
    endif

    freeObj(oAC9)
    oAC9 := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} knowledgeBank
de 
@author    Lucas Nonato
@version   V12
@since     01/03/2021
/*/
WSMethod POST knowledgeBank WSService totvsHealthPlans
    local oAC9 	            := PLSAC9Req():new(self)
    local lResult 		    := .f.

    oAC9:initRequest()

   if oAC9:checkAuth() .and. oAC9:checkBody()
        lResult := oAC9:post()
    endif

    freeObj(oAC9)
    oAC9 := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} knowledgeBank
de 
@author    Daniel Silva
@version   V12
@since     30/11/2023
/*/
WSMethod put knowledgeBank WSService totvsHealthPlans
    local oAC9 	            := PLSAC9Req():new(self)
    local lResult 		    := .f.

    oAC9:initRequest()

    if (!empty(self:attachmentsKey))
        oAC9:deleteFiles() 
    else 
        oAC9:setPutError()
    endif

    freeObj(oAC9)
    oAC9 := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} postAuditXml
de 
@author    Lucas Nonato
@version   V12
@since     10/08/2021
/*/
WSMethod POST postAuditXml WSService totvsHealthPlans
    local oPos 	            := PostAuditReq():new(self)
    local lResult 		    := .f.

    oPos:initRequest()

    if oPos:checkAuth() .and. oPos:checkBody()
        lResult := oPos:post()
    endif

    freeObj(oPos)
    oPos := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} batchNotes
de 
@author    Lucas Nonato
@version   V12
@since     10/08/2021
/*/
WSMethod PUT batchNotes PATHPARAM protocol WSService totvsHealthPlans
    local oRequest  := PLSBCIOBSReq():new(self)
    local lResult   := .f.

    if oRequest:checkBody()
        lResult := oRequest:put()
    endif

    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} hospitalizationDate
de 
@author    Lucas Nonato
@version   V12
@since     05/09/2022
/*/
WSMethod PUT hospitalizationDate PATHPARAM authorizationId WSService totvsHealthPlans
    local oRequest  := PLSDtIntSvc():new(self)
    
    if oRequest:checkBody()
        oRequest:put()
    endif

    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} userUsage
Extrato de utilização de beneficiários de saúde

@author  Renan Sakai
@version P12
@since   15/12/2020
/*/
//-------------------------------------------------------------------
WSMETHOD POST tokenBenef PATHPARAM subscriberId WSSERVICE totvsHealthPlans
    Local oRequest := TotpBenReq():new(self)

    oRequest:validTotp()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} beneficiaryElegibility return data of beneficiary by CPF or CARD NUMBER

@author  PLSTEAM
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod GET beneficiaryElegibility QUERYPARAM cardNumberOrCpf, authorizationType, healthProviderCode, eligibilityType WSService totvsHealthPlans

    local lResult  := .f.
    local oRequest := PLSBenefElegSvc():new(self)
    default self:eligibilityType := ""

    if oRequest:valida()
        lResult := oRequest:elegibility()
    endIf

    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return lResult


//-------------------------------------------------------------------
/*/{Protheus.doc} procedureAuthorization return if the procedure is autorization or denied

@author  PLSTEAM
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod POST procedureAuthorization QUERYPARAM procedureId WSService totvsHealthPlans

    local lResult  := .f.
    local oRequest := PLSProcAuthSvc():new(self)

    if oRequest:valida()
        lResult := oRequest:authorization()
    endIf

    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return lResult


//-------------------------------------------------------------------
/*/{Protheus.doc} SolCanBenef
Solicita protocolo de bloqueio dos beneficiários pela RN 402

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 13/06/2022
/*/
//------------------------------------------------------------------- 
WSMETHOD POST SolCanBenef QUERYPARAM subscriberId WSService totvsHealthPlans

    Local oRequest := nil

    Default self:subscriberId := ""

    oRequest := PLSBenefBloqReq():New(self)

    oRequest:Post()
    oRequest:EndRequest()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} RetCanBenef
Retorna solicitação de protocolo de bloqueio do beneficiários

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 20/06/2022
/*/
//------------------------------------------------------------------- 
WSMETHOD GET RetCanBenef QUERYPARAM subscriberId WSService totvsHealthPlans

    Local oRequest := nil

    Default self:subscriberId := ""

    oRequest := PLSBenefBloqReq():New(self)

    oRequest:Get()
    oRequest:EndRequest()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} authorizations
Retorna dados de uma guia (usado na contingencia HAT x PLS)

@author  sakai
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod GET authorizations PATHPARAM idHealthIns QUERYPARAM authorizationType, action, healthProviderCode, locationCode, showDeniedProc, initialSituation WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    Default self:authorizationType := ""
    Default self:action := ''
    Default self:healthProviderCode := ''
    Default self:locationCode := ''
    Default self:initialSituation := .F.

    if self:action == 'customPrint'
        oRequest:customPrint()
    elseIf self:action == 'validRelease'
        oRequest:validaLiberacao()
    else
        if oRequest:valida(self:authorizationType, self:initialSituation)
            oRequest:authorization()
        endIf
    endIf
    oRequest:endRequest()
    oRequest:destroy()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} cliAttach
Retorna os anexos de uma guia

@author  sakai
@version P12
@since   12/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET cliAttach PATHPARAM idHealthIns QUERYPARAM page,pageSize,expand WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    default self:page := '1'
    default self:pageSize := '10'
    default self:expand := 'procedures,rejectionCauses'

    if oRequest:validaGuiasRelacionadas('B4A')
        oRequest:geraJsonGuiasRelacionadas('B4A')
    endIf

    oRequest:endRequest()
    oRequest:destroy()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} treatExt
Retorna as prorrogacoes de uma guia

@author  sakai
@version P12
@since   12/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET treatExt PATHPARAM idHealthIns QUERYPARAM page,pageSize,expand WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    default self:page := '1'
    default self:pageSize := '10'
    default self:expand := 'procedures,rejectionCauses'

    if oRequest:validaGuiasRelacionadas('B4Q')
        oRequest:geraJsonGuiasRelacionadas('B4Q')
    endIf

    oRequest:endRequest()
    oRequest:destroy()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} treatExt
Retorna as situacoes iniciais de uma guia

@author  sakai
@version P12
@since   12/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET iniSituac PATHPARAM idHealthIns QUERYPARAM page,pageSize,expand WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    default self:page := '1'
    default self:pageSize := '10'
    default self:expand := 'procedures,rejectionCauses,teeth'

    if oRequest:validaGuiasRelacionadas('BEC')
        oRequest:geraJsonGuiasRelacionadas('BEC')
    endIf

    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} authorizations
Verifica se e possivel realizar o reenvio de uma 
guia gerada pelo TISS ON (usado na contingencia HAT x PLS)

@author  sakai
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod POST authorizations QUERYPARAM resendBatch, action WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)
    Default self:resendBatch := .F.
    Default self:action := ''

    if oRequest:checkAuth()
        if self:resendBatch
            oRequest:checkBodyResend()
            oRequest:procReenvioHAT()        
        
        elseIf self:action == 'execute'
            oRequest:checkBodyExecute()
            if oRequest:procExecuteAuthorization()
                oRequest:execution()
            endIf
        
        else //Nao achou acao de POST
            oRequest:faultPostOption()
        endIf
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} authCancel
Cancela uma guia

@author  sakai
@version P12
@since   28/03/2022
/*/
//-------------------------------------------------------------------
WSMethod POST authCancel WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)

    if oRequest:checkAuth()
        oRequest:checkBodyCancel()
        oRequest:cancelaGuia()
    endIf
    
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf() 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} pegTransfer
Realiza a transferencia de guias em PEGS temporarias para PEGS de faturamento

@author  PLSTEAM
@version P12
@since   04/10/2022
/*/
//-------------------------------------------------------------------
WSMethod POST pegTransfer WSService totvsHealthPlans
    
    local oRequest := PLPegTransferReq():new(self)
    
    oRequest:valida()
    oRequest:processa()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} pegTransfer
Realiza a exclusão de PEGS temporarias para PEGS de faturamento

@author  Lucas Nonato
@version P12
@since   06/03/2025
/*/
//-------------------------------------------------------------------
WSMethod DELETE pegTransfer QUERYPARAM healthProviderId, protocol, sequential WSService totvsHealthPlans

    local oRequest := PLPegTransferReq():new(self)
    default self:healthProviderId   := ''
    default self:protocol           := ''
    default self:sequential         := ''

    oRequest:validaExc(.t.)
    oRequest:procExc()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} postProf
Realiza a cadastro de um profissional de Saude

@author  sakai
@version P12
@since   08/02/2023
/*/
//-------------------------------------------------------------------
WSMethod POST postProf WSService totvsHealthPlans
    
    local oRequest := PLProfessionalsReq():new(self)
    
    oRequest:valida()
    oRequest:procPost()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} profColl
Busca o cadastro de profissionais de Saude

@author  sakai
@version P12
@since   08/02/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET profColl QUERYPARAM healthProviderId, idOnHealthInsurer, stateAbbreviation,;
             professionalCouncil, professionalCouncilNumber, officialRecord,;
             professionalType, healthProviderType, expand, fields, name, page,;
             pageSize, action, filterClinicalStaffRequest, filterClinicalStaffExecution, isOdonto WSSERVICE totvsHealthPlans

	Local lResult                               := .F.
	Local oRequest                              := nil
    Default self:healthProviderId               := ""
    Default self:idOnHealthInsurer              := ""
  	Default self:stateAbbreviation              := ""
    Default self:professionalCouncil            := ""
	Default self:professionalCouncilNumber      := ""
    Default self:officialRecord                 := ""
	Default self:professionalType               := "S"
	Default self:healthProviderType             := "J"
    Default self:expand                         := ""
	Default self:fields                         := ""
	Default self:name                           := ""
	Default self:page                           := "1"
	Default self:pageSize                       := "10"
    Default self:action                         := ""
    Default self:filterClinicalStaffRequest     := .F.
    Default self:filterClinicalStaffExecution   := .F.
    Default self:isOdonto                       := .F.

    oRequest := PLProfessionalsReq():new(self)

    oRequest:applyFilter()
    oRequest:procGet()
    oRequest:endRequest()

    oRequest:destroy()
    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} accreditations

@author    Lucas Nonato
@version   V12
@since     04/04/2023
/*/
WSMethod GET accreditations QUERYPARAM healthProviderCode,locationCode WSService totvsHealthPlans

    local oRequest 	                        := nil
    default self:healthProviderCode         := ""
    default self:locationCode               := ""

    oRequest := PLSB7PReq():New(self)
    oRequest:initRequest()
    if oRequest:valida()
        oRequest:procGet()
    endIf
    oRequest:endRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} healthProviders

@author    Sakai
@version   V12
@since     22/05/2023
/*/
WSMETHOD GET healthProviders PATHPARAM healthProviderCode WSService totvsHealthPlans

    local oRequest := PLSHealthProvidersRequest():new(self)
   
    if oRequest:valida()
        oRequest:getRda()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} provItem

@author    Sakai
@version   V12
@since     29/02/2024
/*/
WSMETHOD GET provItem QUERYPARAM healthProviderId,page,pageSize,expand,elapTime WSService totvsHealthPlans

    local oRequest                  := nil
    default self:elapTime           := ''
    default self:expand             := ''
    default self:healthProviderId   := ''
    default self:page               := '1'
    default self:pageSize           := '20'
    default self:filter             := ''

    oRequest := PLSHealthProvidersRequest():new(self)
    oRequest:applyFilter(self)
    oRequest:procCollection()
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} hPrSpecialty

@author    Sakai
@version   V12
@since     04/03/2024
/*/
WSMETHOD GET hPrSpecialty PATHPARAM healthProviderCode QUERYPARAM page, pageSize, attendanceLocation WSService totvsHealthPlans

	Local oRequest := nil
	Default self:healthProviderCode := ""
	Default self:page               := "1"
	Default self:pageSize           := "20"
	Default self:attendanceLocation := "001"

    oRequest := PLSHealthProvidersRequest():new(self)
    oRequest:getSpecialty()
    oRequest:endRequest()
    
    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} clinicalStaff

@author    Sakai
@version   V12
@since     22/05/2023
/*/
WSMETHOD GET clinicalStaff QUERYPARAM healthProviderCode,locationCode,specialtyCode,pageSize,page WSService totvsHealthPlans

    local oRequest := nil
    default self:healthProviderCode := ''
    default self:locationCode       := ''
    default self:specialtyCode      := ''
    default self:pageSize := '10'
    default self:page := '1'

    oRequest := PLSClinicalStaffRequest():new(self)
    if oRequest:validaGet()
        oRequest:getClinicalStaff()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} clinicalStaff

@author    Sakai
@version   V12
@since     22/05/2023
/*/
WSMETHOD POST clinicalStaff  WSService totvsHealthPlans

    local oRequest := PLSClinicalStaffRequest():new(self)

    if oRequest:validaPost()
        oRequest:postClinicalStaff()
    endIf
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} blockClinicallStaff
de 
@author    Lucas Nonato
@version   V12
@since     24/05/2023
/*/
WSMethod PUT blockClinicallStaff WSService totvsHealthPlans

    local oRequest  := PLSClinicalStaffRequest():new(self)
    local lResult   := .f.

    lResult := oRequest:block()    

    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil    

    delClassIntf()

return lResult


//-------------------------------------------------------------------
/*/{Protheus.doc} apoInfo

@author    Daniel Silva
@version   V12
@since     10/07/2023
/*/

WSMETHOD POST apoInfo  WSService totvsHealthPlans

    local oRequest := PLSapoInfoReq():new(self)
    
    oRequest:valida()
    oRequest:enviromentPost()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GetProcCol
Pesquisa de procedimentos para execucao

@author sakai
@version Protheus 12
@since 11/09/2023
/*/
//------------------------------------------------------------------- 
WSMETHOD GET ProcCol QUERYPARAM action, filter, tableCode, procedureId, customWhere, page, pageSize, healthProviderCode WSService totvsHealthPlans

    Local oRequest := nil

    Default self:action := ""
    Default self:filter := ""
    Default self:tableCode := ""
    Default self:procedureId := ""
    Default self:customWhere := ""
    Default self:page     := "1"
    Default self:pageSize := "7"
    Default self:healthProviderCode := ""

    oRequest := PLSProceduresRequest():New(self)
    oRequest:validaGet()
    oRequest:procGet("C")
    oRequest:EndRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GetProcSgl
Pesquisa de procedimentos para execucao

@author sakai
@version Protheus 12
@since 11/09/2023
/*/
//------------------------------------------------------------------- 
WSMETHOD GET ProcSgl PATHPARAM procedureId WSService totvsHealthPlans

    Local oRequest := nil

    Default self:procedureId := ""

    oRequest := PLSProceduresRequest():New(self)
    oRequest:procGet("S")
    oRequest:EndRequest()
    oRequest:destroy()

    FreeObj(oRequest)
    oRequest := Nil

    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} paymentCalendar

@author    Lucas Nonato
@version   V12
@since     19/09/2023
/*/
 WSMETHOD GET paymentCalendar WSService totvsHealthPlans

    local oRequest := PLSCalendReq():new(self)
    
    oRequest:initRequest()
    oRequest:procGet()    
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} tothReg
Pesquisa de procedimentos para execucao

@author sakai
@version Protheus 12
@since 11/09/2023
/*/
//------------------------------------------------------------------- 
WSMETHOD GET tothReg PATHPARAM procedureId QUERYPARAM expand, fields WSSERVICE totvsHealthPlans
	
	Local oRequest      := nil

	Default self:teethRegionId  := ""
	Default self:expand         := ""
	Default self:fields         := ""
	Default self:page           := "1"
	Default self:pageSize       := "120"

	oRequest := PLSOdontoRequest():New(self)
    oRequest:procGet(1)
    oRequest:EndRequest()

    oRequest:destroy()
	FreeObj(oRequest)
	oRequest := nil
	DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} surfaces
Pesquisa de procedimentos para execucao

@author sakai
@version Protheus 12
@since 11/09/2023
/*/
//------------------------------------------------------------------- 
WSMETHOD GET surfaces PATHPARAM procedureId, teethRegionId QUERYPARAM expand, fields WSSERVICE totvsHealthPlans
	
	Local oRequest      := nil

	Default self:teethRegionId  := ""
	Default self:expand         := ""
	Default self:fields         := ""
	Default self:page           := "1"
	Default self:pageSize       := "100"

	oRequest := PLSOdontoRequest():New(self)
    oRequest:procGet(2)
    oRequest:EndRequest()

    oRequest:destroy()
	FreeObj(oRequest)
	oRequest := nil
	DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} batchesAuthorization

@author    Daniel Silva
@version   V12
@since     11/01/2024
/*/
WSMethod GET batchesAuthorization QUERYPARAM healthProviderCode, protocol WSService totvsHealthPlans
    local oDemonstrativoAnalise := PLSDemonstrativoAnaliseContasRequest():new(self)

    if( oDemonstrativoAnalise:valida() )
        oDemonstrativoAnalise:get()
    else 
        oDemonstrativoAnalise:setGetError()
    endif

    freeObj(oDemonstrativoAnalise)
    oDemonstrativoAnalise := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT authorizationBatch
de 
@author    Nicole Luna
@version   V12
@since     29/01/2024
/*/

WSMethod PUT authorizationBatch QUERYPARAM batchCode, action, idOnHealthInsurer WSService totvsHealthPlans
    local oRequest                 := PLSAuthorizationBatchReq():new(self)
    local lResult                  := .F. 
    default self:batchCode         := ""
    default self:action            := nil
    default self:idOnHealthInsurer := ""

    if oRequest:valida()   
        lResult := oRequest:alteraLote()    
    endif

    oRequest:endRequest()

    oRequest:destroy()
    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GET authBatch
de 
@author    Nicole Luna
@version   V12
@since     01/02/2024
/*/

WSMethod GET authBatch PATHPARAM batchCode WSService totvsHealthPlans
    local oRequest                 := PLSAuthorizationBatchReq():new(self)
    local lResult                  := .F. 
    default self:batchCode         := ""

    oRequest:procGet()
    oRequest:endRequest()
    oRequest:destroy()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} patientHealthcareFacility

@author    Daniel Silva
@version   V12
@since     06/02/2024
/*/

WSMethod GET patientHealthcareFacility QUERYPARAM healthProviderCode, codRda WSService totvsHealthPlans
    local oPacienteLocal := PLSPacienteNoLocalRequest():new(self)

    if( oPacienteLocal:valida() )
        oPacienteLocal:get()
    else 
        oPacienteLocal:setGetError()
    endif

    freeObj(oPacienteLocal)
    oPacienteLocal := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} benefPortalPassRec

@author    Daniel Silva
@version   V12
@since     20/02/2024
/*/

WSMethod POST benefPortalPassRec WSService totvsHealthPlans

    local  oBenPasReq := PLSBeneficiaryPasswordRecoveryRequest():new(self)

    oBenPasReq:processa()
    oBenPasReq:endRequest()
    
    freeObj(oBenPasReq)
    oBenPasReq := nil
    delClassIntf()

return .t.

//Recuperacao de senha - Portal da Operadora, reaproveitando APIs criadas para portal benef
WSMethod POST passwordRecovery WSService totvsHealthPlans

    local  oPasswordRec := PLSBeneficiaryPasswordRecoveryRequest():new(self, .T.)

    oPasswordRec:processa()
    oPasswordRec:endRequest()
    
    freeObj(oPasswordRec)
    oPasswordRec := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} cbos

@author    Nicole Luna
@version   V12
@since     14/03/2024
/*/
WSMETHOD GET cbos QUERYPARAM page, pageSize, locationCode, healthProviderId, filter WSService totvsHealthPlans

	Local oRequest                  := nil
	Default self:healthProviderCode := ""
	Default self:page               := "1"
	Default self:pageSize           := "20"
	Default self:attendanceLocation := ""
	Default self:healthProviderId   := ""
	Default self:filter             := ""

    oRequest := PLSHealthProvidersRequest():new(self)
    oRequest:getCbos()
    oRequest:endRequest()
    
    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.

/*/{Protheus.doc} executions
Retorna TOTAL

@author  Lucas Nonato
@version P12
@since   02/04/2024
/*/
WSMethod GET executions PATHPARAM idHealthIns WSService totvsHealthPlans

    local oRequest := PLSAuthorizationsRequest():new(self)

    oRequest:executions()
    oRequest:endRequest()
    
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} profSpecialty

@author    Nicole Duarte 
@version   V12
@since     09/04/2024
/*/
WSMETHOD GET profSpecialty PATHPARAM professionalCode QUERYPARAM page, pageSize WSService totvsHealthPlans

	Local oRequest := nil
	Default self:professionalCode := ""
	Default self:page               := "1"
	Default self:pageSize           := "20"

    oRequest := PLProfessionalsReq():new(self)
    oRequest:getSpecialty()
    oRequest:endRequest()
    
    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} profCbos

@author    Nicole Luna
@version   V12
@since     14/03/2024
/*/
WSMETHOD GET profCbos PATHPARAM professionalCode QUERYPARAM page, pageSize, filter WSService totvsHealthPlans

	Local oRequest                  := nil
	Default self:professionalCode   := ""
	Default self:page               := "1"
	Default self:pageSize           := "20"
	Default self:filter             := ""

    oRequest := PLProfessionalsReq():new(self)
    oRequest:getCbos()
    oRequest:endRequest()
    
    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} BeneficiaryFirstAccess

@author    Daniel Silva
@version   V12
@since     24/04/2024
/*/

WSMethod POST firstAccess WSService totvsHealthPlans

    local oRest := PLSBeneficiaryFirstAccessRequest():new(self)

    oRest:processa()
    oRest:endRequest()
    
    freeObj(oRest)
    oRest := nil
    delClassIntf()

return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET CompetenceProtocols

@author    Nicole Luna
@version   V12
@since     11/07/2024
/*/

WSMethod GET competenceProtocols QUERYPARAM healthProviderCode, sequential, month, year, page, pageSize  WSService totvsHealthPlans

    Local oRequest                  := PLSCompetenceProtocolsReq():new(self)
    Default self:page               := "1"
	Default self:pageSize           := "20"
    Default self:healthProviderCode := ""
    Default self:sequential         := ""
    Default self:month              := ""
    Default self:year               := ""

    oRequest:valida()
    oRequest:getCompetence()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT CompetenceProtocols
de 
@author    Nicole Luna
@version   V12
@since     17/07/2024
/*/
WSMethod PUT updtStatusCompetence PATHPARAM sequential WSService totvsHealthPlans

    Local oRequest  := PLSCompetenceProtocolsReq():new(self)

    oRequest:validaPut()    
    oRequest:updtStatus()    
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil    

    delClassIntf()

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} dentalTreatment
Retorna liberações odonto de um beneficiario

@author  Nicole Luna
@version P12
@since   08/10/2024
/*/
//-------------------------------------------------------------------
WSMethod GET dentalTreatment PATHPARAM beneficiaryId QUERYPARAM healthProviderCode, page, pageSize, expand WSService totvsHealthPlans

    Local oRequest := PLSAuthorizationsRequest():new(self)
    Default self:healthProviderCode := ''
    Default self:beneficiaryId      := ''
    Default self:page               := '1'
    Default self:pageSize           := '5'
    Default self:expand             := 'procedures,professional,cbos'

    oRequest:vldBenef()
    oRequest:endRequest()
    
    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} serialTreatment
Retorna tratamento seriado vinculado a um beneficiario

@author  Daniel Silva
@version P12
@since   07/11/2024
/*/
//-------------------------------------------------------------------

WSMethod GET serialTreatment PATHPARAM beneficiaryId QUERYPARAM healthProviderCode, page, pageSize, expand WSService totvsHealthPlans

    Local oRequest := PLSAuthorizationsRequest():new(self)
    Default self:healthProviderCode := ''
    Default self:beneficiaryId      := ''
    Default self:page               := '1'
    Default self:pageSize           := '5'
    Default self:expand             := 'procedures,professional,cbos'

    oRequest:procTratSeri()
    oRequest:endRequest()
    
    oRequest:destroy()
    FreeObj(oRequest)
    oRequest := nil
    DelClassIntf()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} serialTreatment

Retorna dados da capa do lote 

@author  Daniel Silva
@version P12
@since   01/04/2025
/*/
//-------------------------------------------------------------------

WSMETHOD GET batchCover QUERYPARAM healthProviderCode, operatorId, protocol, calcType, expand WSService totvsHealthPlans
    Local oRequest := PlsBatchCoverReq():new(self)

    default self:calcType := "1"
    default self:expand := 'protocol'

    oRequest:Process()
    oRequest:endRequest()

    freeObj(oRequest)
    oRequest := nil
    delClassIntf()

Return .T.


