#include "protheus.ch"
#include "fina708fat.ch"

#DEFINE ANTECIPACAO "2"

Static __oEstNF     := NIL

/*/
    FINA708FAT
    Agrupamento das funções que realizam a geração dos dados na tabela F7T com base
    nas operações das rotinas do faturamento
/*/

/*/{Protheus.doc} F708GrvAdt
    Gravação do adiantamento vinculado ao pedido de venda para 
    geração da nota de debito
    @type  Function
    @author Vitor Duca
    @since 26/06/2026
    @version 1.0
    @param cPedido, Character, Numero do pedido que foi relacionado ao adiantamento
    @param cIdDoc, Character, IDDOC do titulo a receber
    @param nValue, Numeric, Valor que foi relacionado ao pedido
/*/
Function F708GrvAdt(cPedido as character, cIdDoc as character, nValue as numeric)
    local oDebitInv as object
    local jData     as json
    local aArea     as array
    local aAreaFK5  as array
    local cIDF7T    as character

    Default cPedido := ""
    Default cIdDoc := ""
    Default nValue := 0
    
    cIDF7T := ""

    If !Empty(cIdDoc)
        aArea := FwGetArea()
        aAreaFK5 := FK5->(FwGetArea())

        FK5->(DbSetOrder(6)) //FK5_IDDOC, FK5_SEQ
        If FK5->(DbSeek(cIdDoc))
            // Prepara os dados para a DebtitTaxInvoice
            jData := JsonObject():New()
            jData['movementBranch'] := FwxFilial("F7T", FK5->FK5_FILORI)
            jData['sourceTable'] := "FK5"
            jData['movementIdentification'] := FK5->FK5_IDMOV
            jData['movementType'] := ANTECIPACAO
            
            F708DtaTit(@jData, cIdDoc)

            jData['movementDate'] := FK5->FK5_DATA
            jData['movementSequence'] := ""
            jData['movementValue'] := FK5->FK5_VALOR
            jData['increaseValue'] := nValue
            jData['bankCode'] := FK5->FK5_BANCO
            jData['bankBranch'] := FK5->FK5_AGENCI
            jData['bankAccountNumber'] := FK5->FK5_CONTA

            oDebitInv := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():new("F7T")
            If jData:hasProperty("billCurrency") .and. jData["billCurrency"] == 1 .and. MethIsMemberOf(oDebitInv, "prepareRecordF7T") .And. oDebitInv:getValidatedEnvironment()
                oDebitInv:setParameters(jData)
                oDebitInv:prepareRecordF7T()
                cIDF7T := oDebitInv:recordInsertF7T()

                If !Empty(cIDF7T)
                    ProcLogIni( {}, cIDF7T, "F708GrvAdt")
                    ProcLogAtu("MENSAGEM", "F708GrvAdt", STR0001 + " - " + cPedido, , .T.) //Recebimento antecipado vinculado ao pedido
                Endif
            EndIf
        Endif

        FwRestArea(aArea)
        FwRestArea(aAreaFK5)
    Endif
Return

/*/{Protheus.doc} F708EstNF
    @description Função responsável por retirar o vinculo entre a nota e a F7T
    quando a exclusão da nota ocorre pelo Faturamento (MATA600 ou MATA521)
    @type  Function
    @author Vitor Duca
    @since 21/05/2026
    @version 1.0
    @param cIdNF, character, ID unico da NF gerada, representa o campo F2_IDNF
    @param cDoc, character, Representa o numero da nota de debito F2_DOC
    @param cSerie, character, Representa a serie da nota de debito F2_SERIE
/*/
Function F708EstNF(cIdNF as character, cDoc as character, cSerie as character)
    Local cQuery        as character
    Local nParam        as numeric
    Local nRecno        as numeric
    Local cFunName      as character
    Local aArea         as array
    Local aAreaF7T      as array
    Local lOrigemFIN    as logical

    Default cIdNF := ""
    Default cDoc := ""
    Default cSerie := ""

    cQuery := ""
    nParam := 1
    nRecno := 0
    cFunName := AllTrim(FunName())
    aArea := {}
    aAreaF7T := {}
    lOrigemFIN := FwIsInCallStack("F708EstMov")

    If ChkFile("F7T") .and. !lOrigemFIN
        If __oEstNF == NIL
            cQuery := "SELECT R_E_C_N_O_ RECNOF7T "
            cQuery += "FROM " + RetSqlName("F7T") + " "
            cQuery += "WHERE F7T_IDNF = ? "
            cQuery += "AND D_E_L_E_T_ = ? "

            __oEstNF := FWExecStatement():New( cQuery )
        Endif
        
        __oEstNF:setString(nParam++, cIdNF)
        __oEstNF:setString(nParam++, " ")
        nRecno := __oEstNF:execScalar("RECNOF7T")

        If nRecno > 0
            aArea := FwGetArea()
            aAreaF7T := F7T->(FwGetArea())

            F7T->(DbGoto(nRecno))

            RecLock("F7T", .F.)
                F7T->F7T_IDNF := ""
                F7T->F7T_NUMNOT := ""
            F7T->(MsUnLock())

            ProcLogIni( {}, F7T->F7T_IDF7T, cFunName)
            ProcLogAtu("MENSAGEM", "DELETANOTA", STR0002 + cSerie + STR0003 + cDoc + STR0004 + cFunName, , .T.) //"Nota de debito/credito - Serie: "#" Numero: "#" excluida pela rotina "

            FwRestArea(aAreaF7T)
            FwRestArea(aArea)
        Endif
    Endif
Return

/*/{Protheus.doc} F708GtPedV
    Recupera o pedido de venda atrelado ao RA que terá sua nota de débito gerada
    @type  Function
    @author Vitor Duca
    @since 01/07/2026
    @version 1.0
    @param cIdDoc, Character, IDDOC do titulo
    @param oStatPedV, Object, Objeto da FwExecStatement que será reaproveitado (Performance)
    @return cNumPed, Character, Numero do pedido de venda vinculado ao RA
    @example
    F708GtPedV(cIdDoc, oStatPedV)
/*/
Function F708GtPedV(cIdDoc as character, oStatPedV as object) as character
    local cQuery    as character
    local nParam    as numeric
    local cNumPed   as character

    Default cIdDoc := ""
    Default oStatPedV := NIL
    
    nParam := 1
    cQuery := ""
    cNumPed := ""

    If oStatPedV == NIL
        cQuery := "SELECT FIE.FIE_PEDIDO PEDIDO "
        cQuery += "FROM " + RetSqlName("FK7") + " FK7 "
        cQuery += "INNER JOIN " + RetSqlName("FIE") + " FIE "
        cQuery += "ON "
        cQuery += FWJoinFilial("FIE", "FK7") + " "
        cQuery += "AND FIE.FIE_CART = ? "
        cQuery += "AND FIE.FIE_PREFIX = FK7.FK7_PREFIX "
        cQuery += "AND FIE.FIE_NUM = FK7.FK7_NUM "
        cQuery += "AND FIE.FIE_PARCEL = FK7.FK7_PARCEL "
        cQuery += "AND FIE.FIE_TIPO = FK7.FK7_TIPO "
        cQuery += "AND FIE.FIE_CLIENT = FK7.FK7_CLIFOR "
        cQuery += "AND FIE.FIE_LOJA = FK7.FK7_LOJA "
        cQuery += "AND FIE.D_E_L_E_T_ = ? "
        cQuery += "WHERE "
        cQuery += "FK7.FK7_IDDOC = ? "
        cQuery += "AND FK7.D_E_L_E_T_ = ? "

        oStatPedV := FwExecStatement():new(ChangeQuery(cQuery))
    Endif

    oStatPedV:setString(nParam++, 'R') //FIE.FIE_CART
    oStatPedV:setString(nParam++, ' ') //FIE.D_E_L_E_T_
    oStatPedV:setString(nParam++, cIdDoc) //FK7.FK7_IDDOC
    oStatPedV:setString(nParam++, ' ') //FK7.D_E_L_E_T_

    cNumPed := oStatPedV:ExecScalar("PEDIDO")

Return cNumPed

/*/{Protheus.doc} F708HasNF
    Verifica se existe uma nota fiscal de saida com base nos parametros
    @type  Function
    @author Vitor Duca
    @since 28/08/2026
    @version 1.0
    @param cBranchOri, Character, Filial de origem do titulo, geralmente representa E1_FILORIG
    @param cDoc, Character, Numero da nota fiscal de saida, geralmente representa E1_NUM
    @param cSerie, Character, Serie da nota fiscal de saida, geralmente representa E1_SERIE
    @param cCustomer, Character, Codigo do cliente, geralmente representa E1_CLIENTE
    @param cStore, Character, Loja do cliente, geralmente representa E1_LOJA
    @param oQryHasNF, Object, Objeto que deve ser passado por referencia para reaproveitando do FwExecStatement
    @return !Empty(oQryHasNF:ExecScalar("TEMNOTA")), logical, Retorna se existe ou não a nota
/*/
Function F708HasNF(cBranchOri as character, cDoc as character, cSerie as character, cCustomer as character, cStore as character, oQryHasNF as object) as logical
    local cQuery    as character
    local nParam    as numeric
    
    Default cBranchOri := ""
    Default cDoc := ""
    Default cSerie := ""
    Default cCustomer := ""
    Default cStore := ""
    Default oQryHasNF := NIL

    nParam := 1

    If oQryHasNF == NIL
        cQuery := "SELECT COUNT(F2_DOC) TEMNOTA "
        cQuery += "FROM " + retSqlName("SF2") + " "
        cQuery += "WHERE "
        cQuery += "F2_FILIAL = ? "
        cQuery += "AND F2_DOC = ? "
        cQuery += "AND F2_SERIE = ? "
        cQuery += "AND F2_CLIENTE = ? "
        cQuery += "AND F2_LOJA = ? "
        cQuery += "AND D_E_L_E_T_ = ? "

        oQryHasNF := FwExecStatement():new(ChangeQuery(cQuery))
    Endif

    oQryHasNF:setString(nParam++, FwXFilial("SF2", cBranchOri)) //F2_FILIAL
    oQryHasNF:setString(nParam++, cDoc) //F2_DOC
    oQryHasNF:setString(nParam++, cSerie) //F2_SERIE
    oQryHasNF:setString(nParam++, cCustomer) //F2_CLIENTE
    oQryHasNF:setString(nParam++, cStore) //F2_LOJA
    oQryHasNF:setString(nParam++, " ") //D_E_L_E_T_

Return !Empty(oQryHasNF:ExecScalar("TEMNOTA"))
