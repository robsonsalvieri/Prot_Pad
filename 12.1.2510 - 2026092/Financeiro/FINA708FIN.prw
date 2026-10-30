#include "protheus.ch"
#include "fina708fin.ch"

#DEFINE MULTA_JUROS "1"

Static __oQryHNF := NIL

/*/
    FINA708FIN
    Agrupamento das funções que realizam a geração dos dados na tabela F7T com base
    nas operações das rotinas do financeiro
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} F708GrvBx
    @description Função responsável por capturar os dados do modelo 
    de baixa (FINM010) e repassar a integração de Juros e Multa 
    na tabela F7T para posterior geração de Nota de Débito.

    @param oModel, object, Instância do FWFormModel do FINM010
    @param cBankCode, character, Código do banco (opcional, pode ser capturado na FK5)
    @param cAgency, character, Código da agência (opcional, pode ser capturado na FK5)
    @param cAccount, character, Número da conta (opcional, pode ser capturado na FK5)

    @author Vitor Duca
    @since 15/04/2026
    @type function
/*/
//-------------------------------------------------------------------
Function F708GrvBx(oModel as object, cBankCode as character, cAgency as character, cAccount as character) as logical
    Local lSuccess as logical
    Local oModelFK1 as object
    Local oModelFK6 as object
    Local oModelFKA as object
    Local nI as numeric
    Local dMovement as date
    Local nIncrease as numeric
    Local nMovValue as numeric
    Local cTypeDoc as character
    Local cIdMov as character
    Local cIdDoc as character
    Local cSeqMov as character
    Local aArea as array
    Local aSaveLine as array
    Local jData as json
    Local lExistBco as logical

    Default oModel := Nil
    Default cBankCode := ""
    Default cAgency := ""  
    Default cAccount := ""
    
    lSuccess := .F.
    nI := 1 
    dMovement := dDataBase 
    nIncrease  := 0 
    nMovValue := 0 
    cTypeDoc := ""
    cIdMov := ""
    cIdDoc := ""
    cSeqMov := ""
    aArea := FwGetArea()
    aSaveLine := {}
    lExistBco := !Empty(cBankCode) .and. !Empty(cAgency) .and. !Empty(cAccount)

    If lExistBco .and. oModel != Nil .And. oModel:isActive()

        aSaveLine := FWSaveRows()

        oModelFK1 := oModel:GetModel("FK1DETAIL")
        oModelFK6 := oModel:GetModel("FK6DETAIL")
        oModelFKA := oModel:GetModel("FKADETAIL")

        If oModelFK1 != Nil .And. oModelFK6 != Nil .And. oModelFKA != Nil .And. !oModelFK1:isEmpty() .And. !oModelFK6:isEmpty() .And. !oModelFKA:isEmpty()
            
            // Verifica se houve Juros ou Multa na baixa
            For nI := 1 To oModelFK6:Length()
                oModelFK6:GoLine(nI)
                If !oModelFK6:IsDeleted()
                    cTypeDoc := oModelFK6:GetValue("FK6_TPDOC")
                    If cTypeDoc $ "JR|MT" // Juros/Multa
                        nIncrease += oModelFK6:GetValue("FK6_VALMOV")
                    EndIf
                EndIf
            Next nI

            // Se não houver juros nem multa, não grava F7T
            If nIncrease > 0

                // Busca dados na FKA
                cIdMov := oModelFKA:GetValue('FKA_IDORIG')

                // Busca dados na FK1
                oModelFK1:GoLine(1)
                cIdDoc := oModelFK1:GetValue("FK1_IDDOC")
                dMovement := oModelFK1:GetValue("FK1_DATA")
                nMovValue := oModelFK1:GetValue("FK1_VALOR")
                cSeqMov := oModelFK1:GetValue("FK1_SEQ")

                // Prepara os dados para a DebtitTaxInvoice
                jData := JsonObject():New()
                jData['movementBranch'] := FwxFilial("F7T")
                jData['sourceTable'] := "FK1"
                jData['movementIdentification'] := cIdMov
                jData['movementType'] := MULTA_JUROS

                F708DtaTit(@jData, cIdDoc)

                If jData["billCurrency"] == 1 .and. F708HasNF(jData['billBranchOrigin'], jData['billNumber'], jData['billInvoiceSeries'], jData['billParticipantCode'], jData['billParticipantStore'], @__oQryHNF) 
                    jData['movementDate'] := dMovement
                    jData['movementSequence'] := cSeqMov
                    jData['movementValue'] := nMovValue
                    jData['increaseValue'] := nIncrease
                    jData['bankCode'] := cBankCode
                    jData['bankBranch'] := cAgency
                    jData['bankAccountNumber'] := cAccount

                    lSuccess := insertF7T(jData)
                Endif
            EndIf
            FWRestRows(aSaveLine)
        EndIf

        // NÃO destruir modelos filhos obtidos de GetModel() — pertencem ao oModel pai
        // Apenas limpa as referências locais atribuindo NIL
        oModelFK1 := Nil
        oModelFK6 := Nil
        oModelFKA := Nil
    EndIf

    If __oQryHNF <> NIL
        __oQryHNF:destroy()
        __oQryHNF := NIL
    Endif

    FwRestArea(aArea)

Return lSuccess

/*/{Protheus.doc} insertF7T
    @description Realiza o processo de gravação da tabela F7T
    @type  Static Function
    @author Vitor Duca
    @since 05/08/2026
    @version 1.0
    @param jData, Json, Dados que serão armazenados na F7T em formato Json (Veja a função F708DtaTit)
    @param cMsgSucess, character, Altera a mensagem de sucesso caso necessario
    @return lSuccess, logical, Se gravou a tabela F7T corretamente
/*/
Static Function insertF7T(jData as json, cMsgSucess as character) as logical
    Local oDebitInv as object
    Local cIdF7T    as character
    Local lSuccess  as logical

    Default jData := JsonObject():new()
    Default cMsgSucess := STR0001 + " - " + AllTrim(FunName()) //"Baixa do titulo com calculo de juros e/ou multa pela rotina

    oDebitInv := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():new("F7T")
    If MethIsMemberOf(oDebitInv, "prepareRecordF7T") .And. oDebitInv:getValidatedEnvironment()
        oDebitInv:setParameters(jData)
        oDebitInv:prepareRecordF7T()
        cIdF7T := oDebitInv:recordInsertF7T()

        If (lSuccess := !Empty(cIdF7T))
            ProcLogIni( {}, cIdF7T, "F708GrvBx")
            ProcLogAtu("MENSAGEM", "F708GrvBx", cMsgSucess, , .T.)
        Endif
    EndIf

Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} F708EstMov
    @description Função responsável por repassar o estorno (exclusão) 
    do controle de Nota de Débito (F7T) gerado na baixa ou no vinculo do adiantamento
    com o pedido de venda.

    @param oModel, object, Instância do FWFormModel do FINM010
    @param lIsFK5, logical, Define se o processo esta sendo executado pelo estorno da FK5 (RA - FINM030)
    @author Vitor Duca
    @since 15/04/2026
    @type function
/*/
//-------------------------------------------------------------------
Function F708EstMov(oModel as object, lIsFK5 as logical) as logical
    Local lSuccess as logical
    Local cBranch as character
    Local cIdMov as character
    Local oModelMov as object
    Local jData as json
    Local oDebitInv as object
    Local aSaveLine as array
    Local cModel as character
    Local cTable as character
    Local cField as character

    Default oModel := NIL
    Default lIsFK5 := .F.

    lSuccess := .T.

    If oModel != Nil .And. oModel:isActive()

        cModel := "FK1DETAIL"
        cTable := "FK1"
        cField := "FK1_IDFK1"

        If lIsFK5
            cModel := "FK5DETAIL"
            cTable := "FK5"
            cField := "FK5_IDMOV"
        Endif

        aSaveLine := FWSaveRows()

        oModelMov := oModel:getModel(cModel)

        If oModelMov != Nil
            oModelMov:GoLine(1)
            cBranch := xFilial("F7T")
            cIdMov := oModelMov:GetValue(cField)

            jData := JsonObject():New()
            jData['movementBranch'] := cBranch
            jData['sourceTable'] := cTable
            jData['movementIdentification'] := cIdMov

            oDebitInv := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():new("F7T")
            If MethIsMemberOf(oDebitInv, "prepareDeletionF7T") .And. oDebitInv:getValidatedEnvironment()
                oDebitInv:setParameters(jData)
                oDebitInv:prepareDeletionF7T()
                lSuccess := oDebitInv:recordDeletionF7T()
            EndIf
        EndIf
        FWRestRows(aSaveLine)          
    EndIf

    // NÃO destruir modelos filhos obtidos de GetModel() — pertencem ao oModel pai
    // Apenas limpa as referências locais atribuindo NIL
    oModelMov := Nil

Return lSuccess

/*/{Protheus.doc} F708DtaTit
    Recupera as informações do titulo com base no IDDOC passado por parametro
    e preenche o json com as informações:
        jData['documentId'] := cIdDoc - variavel passada por parametro
        jData['billBranch'] := SE1->E1_FILIAL
        jData['billPrefix'] := SE1->E1_PREFIXO
        jData['billNumber'] := SE1->E1_NUM
        jData['billInstallment'] := SE1->E1_PARCELA
        jData['billType'] := SE1->E1_TIPO
        jData['billParticipantCode'] := SE1->E1_CLIENTE
        jData['billParticipantStore'] := SE1->E1_LOJA
        jData['participantName'] := Alltrim(SE1->E1_NOMCLI)
        jData['billDueDate'] := SE1->E1_VENCTO
        jData['billBranchOrigin'] := SE1->E1_FILORIG
        jData['billOrigin'] := SE1->E1_ORIGEM
        jData['billCurrency'] := SE1->E1_MOEDA
        jData['billInvoiceSeries'] := SE1->E1_SERIE
    @type  Function
    @author Vitor Duca
    @since 27/06/2026
    @version 1.0
    @param jData, Json, Variavel passada por referencia para ser preenchida pela função
    @param cIdDoc, Character, IDDOC do titulo que deve ser encontrado
    @example
    F708DtaTit(@jData, FK7->FK7_IDDOC)
/*/
Function F708DtaTit(jData as json, cIdDoc as character)
    local aAreaFK7  as array
    local aAreaSE1  as array

    default jData := JsonObject():new()
    default cIdDoc := ""

    aAreaFK7 := {}
    aAreaSE1 := {}

    If !Empty(cIdDoc) .and. ValType(jData) == "J"
        aAreaFK7  := FK7->(FwGetArea())
        FK7->(DbSetOrder(5)) // FK7_IDDOC
        If FK7->(DbSeek(cIdDoc))              
            // Busca dados na SE1
            aAreaSE1  := SE1->(FwGetArea())
            SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
            SE1->(DbSeek(FK7->FK7_FILTIT + FK7->FK7_PREFIX + FK7->FK7_NUM + FK7->FK7_PARCEL + FK7->FK7_TIPO))

            jData['documentId'] := cIdDoc
            jData['billBranch'] := SE1->E1_FILIAL
            jData['billPrefix'] := SE1->E1_PREFIXO
            jData['billNumber'] := SE1->E1_NUM
            jData['billInstallment'] := SE1->E1_PARCELA
            jData['billType'] := SE1->E1_TIPO
            jData['billParticipantCode'] := SE1->E1_CLIENTE
            jData['billParticipantStore'] := SE1->E1_LOJA
            jData['participantName'] := Alltrim(SE1->E1_NOMCLI)
            jData['billDueDate'] := SE1->E1_VENCTO
            jData['billBranchOrigin'] := SE1->E1_FILORIG
            jData['billOrigin'] := SE1->E1_ORIGEM
            jData['billCurrency'] := SE1->E1_MOEDA
            jData['billInvoiceSeries'] := SE1->E1_SERIE

            FwRestArea(aAreaSE1)
        EndIf

        FwRestArea(aAreaFK7)
    Endif
Return
