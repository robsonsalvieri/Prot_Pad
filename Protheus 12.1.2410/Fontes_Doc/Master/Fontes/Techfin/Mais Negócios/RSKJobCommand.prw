#INCLUDE "Protheus.ch"
#INCLUDE "RSKDefs.ch"
#INCLUDE "RSKJobCommand.ch"

#DEFINE INVOICE_INSTALLMENT      1   // Parcelas da Invoice 
#DEFINE PURCHASE_LIMIT           2   // Limites do cliente

Static __RskCtb105   := .F.
Static __lRegistry   := FindFunction( "FINA138B" )
Static __oTFRegistry := Nil


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobCommand
Função chamada pelo Schedule para execução das rotinas de atualização entre a base 
Protheus e as informações da Plataforma.
@type function
@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada por
User Function
@param lConciliation, logical, variável que define a execução do Schedule RSKJobBank.
@param nOriginSched, numeric, define a origem da chamada dos Schedule apartados.
    Opções:
    SCHEDULE_JOBCOMMAND     - RSKJobCommand     [0]
    SCHEDULE_JOBBANK        - RSKJobBank        [1]
    SCHEDULE_JOBPOST        - RSKJobPost        [2]
    SCHEDULE_JOBGETMOVEMENT - RSKJobGetMovement [3]
    SCHEDULE_JOBGETRECORDS  - RSKJobGetRecords  [4]
@param cLock, caracter, define qual o codigo que sera usado no Lock do Schedule.
@param aEntityList, array, vetor com as rotinas que serão executadas pelos Schedule apartados.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Marcia Junko
@since   22/05/2020
/*/
//-------------------------------------------------------------------
Function RSKJobCommand( aParam As Array, cFil As Character, lConciliation As Logical, nOriginSched As Numeric, cLock As Character ,aEntityList As Array, lAutomato As Logical )
    Local nType         As Numeric
    Local cHost         As Character
    Local lJob          As Logical
    Local lRskNTkt      As Logical
    Local cMessage      As Character
    Local aJobCmdInf    As Array
    Local lSplitSched   As Logical
    Local lProcessOk    As Logical
    Local oTechFinLog   As Object     
    Local lObjRet       As Logical

    Default aParam        := nil 
    Default cFil          := NIL
    Default lConciliation := .F.
    Default nOriginSched  := SCHEDULE_JOBCOMMAND      // 0=RSKJobCommand
    Default cLock         := "RSKJobCommand"
    Default aEntityList   := {}
    Default lAutomato     := .F.

    nType       := 0
    cHost       := ''
    lJob        := .F.
    lRskNTkt    := .T.  // Geração\cancelamento de ticket de crédito automática após liberação de pedidos.
    cMessage    := ""
    aJobCmdInf  := {}
    lSplitSched := .F.
    lProcessOk  := .T.

    If nOriginSched <= SCHEDULE_JOBBANK // Se for RSKJobCommand ou JobBank faço o login no ambiente
        lJob := RskProcJob( aParam, cFil )
    EndIF

    //--------------------------------------------------------------------------------
    // Verifica a forma de como executar os Schedules, de acordo com o parâmetro 
    // MV_RSKSPLS,1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records
    //--------------------------------------------------------------------------------
    lSplitSched := IIF(SuperGetMv( "MV_RSKSPLS", .F., 1 ) == 1, .F., .T.)
    If (lSplitSched .And. nOriginSched == SCHEDULE_JOBCOMMAND) .Or. ( .Not. lSplitSched .And. nOriginSched > SCHEDULE_JOBBANK)    // 0=RSKJobCommand ### 1=RskJobBank
        lProcessOk := .F.
    EndIf

    If RskIsActive() .And. lProcessOk

        If __lRegistry .And. __oTFRegistry == Nil
            __oTFRegistry := FINA138BTFRegistry():New()
        EndIf
        aJobCmdInf := GetAPOInfo( "RSKJobCommand.prw" )

        If .Not. __RskCtb105 .And. FindFunction("CTB105MVC")
            __RskCtb105 := CTB105MVC( .T. )
        EndIf
        
        LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0038, {cLock, cEmpAnt, cFilAnt} )) //" ****** Iniciando #1 Empresa: #2 Filial: #3 ******"
        If Len( aJobCmdInf ) == 5
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0039, {cLock, dToc(aJobCmdInf[4]), aJobCmdInf[5]} ) ) //" ****** #1 Version #2 #3 ******"
        EndIf      

        //--------------------------------------------------------------------------------
        // Cria uma thread separada para rodar as rotinas que precisam ser executadas por 
        // filial, devido o processamento entre o Protheus e a Plataforma
        //--------------------------------------------------------------------------------
        If nOriginSched == SCHEDULE_JOBCOMMAND .Or. nOriginSched == SCHEDULE_JOBPOST    // 0=RSKJobCommand ### 1=RskJobPost
            RskJobFil( aParam, cFil, lAutomato )  
        EndIf

        If nOriginSched <> SCHEDULE_JOBPOST      // 1=RskJobPost
            //--------------------------------------------------------------------------------
            // Efetua a trava para efetuar apenas um processamento por empresa
            //--------------------------------------------------------------------------------
            If LockByName( cLock, .T., .F. )       
                cHost   := GetRSKPlatform()   //Host Plataforma Risk

                If !lConciliation
                    lRskNTkt := SuperGetMv( "MV_RSKNTKT", .F., .T. ) 
                
                    If Len(aEntityList) == 0
                        If lRskNTkt   
                            //------------------------------------------------------------------------------
                            // Cria novos tickets de forma automática
                            //------------------------------------------------------------------------------
                            aAdd( aEntityList, NEWTICKET )      // 1=Criação de novo ticket
                        EndIf 

                        //------------------------------------------------------------------------------
                        // Atualiza as informações do ticket de acordo com o retorno da plataforma
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, UPDTICKET )          // 2=Atualiza ticket

                                
                        //------------------------------------------------------------------------------
                        // Atualiza as informações da NFS Mais Negócios de acordo com a plataforma
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, UPDARINVOICE )       // 3=Atualiza fatura

                        //------------------------------------------------------------------------------
                        // Atualização dos dados do pós-faturamento de acordo com o Antecipa
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, AFTERSALES  )        // 4=Pos venda
                                    
                        //------------------------------------------------------------------------------
                        // Executa a atualização dos pedidos de concessão
                        //------------------------------------------------------------------------------
                        If AliasInDic( "AR5" ) .And. AR5->( ColumnPos( "AR5_RCOUNT" ) ) > 0
                            aAdd( aEntityList, CONCESSION )     // 5=Concessão
                        EndIf

                        //------------------------------------------------------------------------------
                        // Executa o cancelamento de NFS Mais Negocios  
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, NFSCANCEL )          // 7=Cancelamento de NFS Mais Negócios

                        //------------------------------------------------------------------------------
                        // Atualiza a posição dos clientes
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, CLIENTPOSITION )     // 10=Posição do Cliente     

                        //------------------------------------------------------------------------------
                        // Monitora as tentativa de Cancelamento de NFS Mais Negócios
                        //------------------------------------------------------------------------------
                        aAdd( aEntityList, MONITCANCEL )        // 11=Tentativa de Cancelamento de NFS Mais Negócios

                        //------------------------------------------------------------------------------
                        // Executa a Antecipação - Mais Negócios
                        //------------------------------------------------------------------------------
                        If AR2->( ColumnPos( "AR2_DATAOR" ) ) > 0
                            aAdd( aEntityList, ANTECIPACAOMN )        // 12=Antecipação - Mais Negócios
                        EndIf
                    EndIf

                    For nType := 1 To Len( aEntityList )                      
                        cMessage := ""
                        lObjRet  := .F.
                        If aEntityList[ nType ] == AFTERSALES   // 4=Pos venda
                            cHost :=  RSKURLAntecipa()     
                        EndIf
                        
                        Do Case 
                            Case aEntityList[ nType ] == NEWTICKET         // 1=Criação de novo ticket
                                cMessage := STR0018 //"Executando o processo => Processamento do Ticket de Credito"
                            Case aEntityList[ nType ] == UPDTICKET         // 2=Atualiza ticket
                                cMessage := STR0019 //"Executando o processo => Atualizacao de Ticket de Credito / Liberacao de Pedidos"
                            Case aEntityList[ nType ] == UPDARINVOICE      // 3=Atualiza fatura
                                cMessage := STR0020 //"Executando o processo => Processamento da NFS Mais Negocios"
                            Case aEntityList[ nType ] == AFTERSALES        // 4=Pos venda
                                cMessage := STR0021 //"Executando o processo => Processamento do Pos-Faturamento"
                            Case aEntityList[ nType ] == CONCESSION        // 5=Concessão
                                cMessage := STR0022 //"Executando o processo => Atualizacao da Concessao de Credito"
                            Case aEntityList[ nType ] == NFSCANCEL         // 7=Cancelamento de NFS Mais Negócios
                                cMessage := STR0024 //"Executando o processo => Cancelamento de NFS Mais Negocios"  
                            Case aEntityList[ nType ] == CLIENTPOSITION    // 10=Posição do Cliente     
                                cMessage := STR0035 //"Executando o processo => Atualizando posição dos clientes" 
                            Case aEntityList[ nType ] == MONITCANCEL       // 11=Tentativa de Cancelamento de NFS Mais Negócios
                                cMessage := STR0037 //"Executando o processo => Processamento do Cancelamento de NFS Mais Negocios"
                            Case aEntityList[ nType ] == ANTECIPACAOMN     // 12=Antecipação - Mais Negócios
                                cMessage := STR0041 //"Executando o processo => Processamento da Antecipacao - Mais Negocios"
                                lObjRet  := .T.
                        EndCase  
                        
                        LogMsg( "RSKJobCommand", 23, 6, 1, "", "", cMessage + I18N( STR0027, { cEmpAnt, cFilAnt } ))  //" Empresa: #1 Filial: #2"  

                        //--------------------------------------------------------------
                        // Executa a rotina de acordo com o tipo
                        //--------------------------------------------------------------     
                        RSKUpdEntity( cHost, aEntityList[ nType ], lAutomato, aParam, lObjRet ) 
                    Next                                     
                Else   
                    //realiza limpeza da tabela de log - AR7 
                    If FindFunction( "FINA138A" )
                        oTechFinLog := TechFinLog():New()
                        If oTechFinLog:lIntegLog
                            oTechFinLog:DeleteLog()
                        EndIf
                    Endif              
                    LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0028, { cEmpAnt, cFilAnt } )) //"Executando o processo => Processamento da Conciliacao Financeira Empresa: #1 Filial: #2" 

                    //--------------------------------------------------------------
                    // Executa a rotina de conciliação
                    //--------------------------------------------------------------     
                    RSKUpdEntity( cHost, CONCILIATION, lAutomato, aParam )      // 9=Conciliação                    
                Endif              
                UnLockByName( cLock, .T., .F. )
            Else
                LogMsg( "RSKJobCommand", 23, 6, 1, "", "", STR0001 )    //"Job já está em execução por outra instância" 
            EndIf        
        EndIf
        LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0040, {cLock, cEmpAnt, cFilAnt} ))   //"Fim #1 Empresa: #2 Filial: #3"
    EndIf
    
    If nOriginSched <= SCHEDULE_JOBBANK // Se for RSKJobCommand ou JobBank reset do ambiente
        If lJob .And. !lAutomato  
            RPCClearEnv()        
        EndIF
    EndIf

    FWFreeArray( aEntityList )
    FWFreeArray( aJobCmdInf )
    FWFreeArray( aParam )

    FwFreeObj( oTechFinLog )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKUpdEntity
Função chamada pelo Schedule para execução das rotinas de atualização entre a base 
Protheus e as informações da Plataforma.

@param cHost, caracter, endereço onde está a plataforma
@param nType, number, identifica qual a entidade está semdo executada. Sendo:
    1 - Criação de Tickets
    2 - Ticket
    3 - Faturamento
    4 - Pos Venda
    5 - Concessão de Credito
    6 - Requisições da plataforma
    7 - Cancelamento de NFS Mais Negócios
    9 - Conciliação
    10 - Posição do cliente
    11 - Tentativa de Cancelamento de NFS Mais Negócios
    12 - Antecipação - Mais Negócios
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param  aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário
@param  lObjRet, Logical, se o retorno da API será tratado como um objeto Json

@author  Marcia Junko
@since   22/05/2020
/*/
//-------------------------------------------------------------------
Static Function RSKUpdEntity( cHost As Character, nType As Numeric, lAutomato As Logical, aParam As Array, lObjRet As Logical )
    Local aRecords       As Array
    Local aItemsByBranch As Array
    Local nRec           As Numeric
    Local aRetGetItems   As Array

    Default lAutomato  := .F.
    Default aParam     := {}
    Default lObjRet    := .F.

    aRecords       := {}
    aItemsByBranch := {}
    nRec           := 0
    aRetGetItems   := {}

    If lObjRet
        If AR2->( ColumnPos( "AR2_DATAOR" ) ) > 0
            GetItems( nType, aParam, @aRetGetItems )
            If Len( aRetGetItems ) > 0
                ActionProc( nType, cHost, aRetGetItems )
            EndIf
        EndIf
    Else
        //------------------------------------------------------------------------------
        // Lista de registros por operação
        //------------------------------------------------------------------------------
        aRecords := GetRSKItems( cHost, nType, lAutomato, aParam )     
        
        If !Empty( aRecords )
            //------------------------------------------------------------------------------
            // Separa os registros por filial
            //------------------------------------------------------------------------------
            aItemsByBranch := RSKRecbyBranch( nType, aRecords ) 
            If !Empty( aItemsByBranch )
                For nRec := 1 to Len( aItemsByBranch )
                    //------------------------------------------------------------------------------
                    // Executa as rotinas para os registros de acordo com a operação
                    //------------------------------------------------------------------------------
                    RSKAction( nType, cHost, aItemsByBranch[ nRec ], lAutomato, aParam )
                Next  
            EndIf
        EndIf
    EndIf

    FWFreeArray( aRecords )
    FWFreeArray( aItemsByBranch )
    FwFreeArray( aRetGetItems )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRSKItems
Extrator central de todas as dimensões e fatos para o TOTVS KPI.
Esta função deverá ser chamada via Protheus Scheduler

@param cHost, caracter, endereço onde está a plataforma
@param nEntity, number, define qual a entidade está sendo pesquisada
    1 - Criação de Tickets
    2 - Ticket
    3 - Faturamento
    4 - Pos Venda
    5 - Concessão de Credito
    6 - Requisições da plataforma
    7 - Cancelamento de NFS Mais Negócios
    9 - Conciliação
    10 - Posição do cliente
    11 - Tentativa de Cancelamento de NFS Mais Negócios
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados retornados pela plataforma, dependendo do tipo 
    1 = Criação de tickets
        [1] - filial
        [2] - pedido
        [3] - cliente
        [4] - loja
        [5] - sequencia
    2 = Atualização de ticket
        [1] - filial
        [2] - numero do ticket
        [3] - status
        [4] - motivo da reprovação
        [5] - id do ticket
        [6] - observação
        [7] - ID da linha de crédito
        [8] - data da avaliação de crédito pela plataforma
        [9] - código de pré-autorização
        [10] - Faturado Parcial ou Total ( 1=Parcial e 2=Total )
        [11] - saldo do ticket
    3 = Faturamento
        [1] - filial
        [2] - numero do documento
        [3] - id da fatura
        [4] - codigo do retorno
        [5] - mensagem do retorno
        [6] - codigo da transação
        [7] - boleto em base64
        [8] - valor total das taxas
        [9] - valor total das parcelas
        [10] - data recebimento parceiro
        [11] - informações das parcelas
            [1] - numero da parcela
            [2] - data de vencimento da parcela
            [3] - valor da parcela
            [4] - valor de recebimento parceiro
            [5] - data de recebimento parceiro
            [6] - id tipo de taxa  
            [7] - tipo de taxa Parcela
            [8] - valor da taxa Parcela
            [9] - valor da taxa da parcela em reais
        [12] - informações dos tickets de crédito
            [1] - Código de pré-autorização
            [2] - Número do Pedido
    4 = Pós-venda (Antecipa)
        [1] - tenantId - ID do Tenant na Plataforma e Fluig
        [2] - platformId - PK da plataforma posteriormente enviada no POST para conclusão da sincronia da parcela
        [3] - erpId - Id de identificação do Titulo ( ArInvoiceInstallment )
        [4] - date - Data do movimento (dataHoraConclusaoProcessamento da API Supplier) com pattern AAAAMMDD
        [5] - operation - tipo de operação ( numero )
                Opções:
                    0-Antecipação
                    1-Baixa de título
                    2-Estorno da baixa do título
                    3-Coobrigação
                    4-Divergencia comercial
                    8-Recompra
                    11-Prorrogação de vencimentos
                    12-Bonificação
                    13-Devolução
                    14-Liberação de NCC
                    20-Conciliação bancária 
        [6] - history - Descrição do histórico
        [7] - localAmount - Valor bruto da operação - valor original da parcela ( numero )
        [8] - feeAmount - Valor do custo da operação ( numero )
        [9] - debitDate - data do débito do parceiro ( Data em que ocorrerá o débito do valor ao parceiro )
        [10] - creditUnits - Array com a relação de notas de credito e seu valor a ser compensado.
            [1] - Id de identificação da Nota de Crédito ( ArInvoiceInstalment ) - ERPID
            [2] - empresa - ERPID
            [3] - filial - ERPID
            [4] - prefixo - ERPID
            [5] - numero do titulo - ERPID
            [6] - parcela - ERPID
            [7] - tipo - ERPID
            [8] - Valor a ser compensado utilizando essa nota de crédito ( numero )
        [11] - creditAmount - Valor da soma das NCCs utilizadas nessa operação ( Terá valor apenas quando a operação for 12-Bonificação - numero )
        [12] - discountAmount - Valor do desconto a ser aplicado ( Terá valor apenas quando a operação for 12-Bonificação - numero )
        [13] - feeAmountOrigin - Estorno da taxa de antecipação ( Terá valor apenas quando a operação for 4-Divergência comercial ou 13-Devolução - numero )
        [14] - newDueDate - Nova data de vencimento
    
    5 = Concessao de Credito
        [1] - ErpId da Concessão
        [2] - Id da Concessão
        [3] - Id da Concessão Risk
        [4] - Filial do cliente
        [5] - Codigo do cliente
        [6] - Loja do cliente
        [7] - Limite Desejado  
        [8] - Limite Aprovado
        [9] - Data da Requisição
        [10] - Data da Avaliação
        [11] - Status
        [12] - Observações
        [13] - Origem (1=Plataforma ou 2=Protheus)
    6 = Requisições da plataforma
        [1] - Grupo de Empresa do cliente
        [2] - Filial do cliente
        [3] - Código do cliente
        [4] - Loja do cliente
        [5] - Filial do ErpID
        [6] - Código do ErpID
        [7] - OrganizationID
        [8] - Tipo de requisição
        [9] - Número do protocolo
    7 = Cancelamento de NFS Mais Negócios
        [1] - Chave da empresa/filial
        [2] - Código da NF Mais Neg.
        [3] - Guide do Cancelamento
        [4] - Status do cancelamento (2=aprovado;3=reprovado)
        [5] - Observação
        [6] - Valor da Taxa
        [7] - Saldo do ticket
        [8] - Número da Parcela
        [9] - Data de Pagamento da taxa.
        [10] - Valor do Devolvido por parcela.
        [11] - Valor da parcela.
        [12] - Estorno da taxa.
    9 = Conciliação
        [1] - Id da conciliação (guide)
        [2] - Código do grupo
        [3] - Data dos lançamentos
        [4] - Id da conta (guide)
        [5] - Banco
        [6] - Agencia 
        [7] - Conta corrente
        [8] - Parcela 
        [9] - Número de parcelas 
        [10] - Número da nota fiscal 
        [11] - Código da transação 
        [12] - Tipo de evento 
        [13] - Descrição do tipo de evento
        [14] - Tipo de lançamento 
        [15] - Tipo de transação 
        [16] - Descrição do tipo de transação
        [17] - Lançamento Futuro ?
        [18] - Data do lançamento 
        [19] - Data do evento 
        [20] - Data do vencimento original da parcela 
        [21] - Data do vencimento atual da parcela 
        [22] - Valor principal da transação 
        [23] - Valor total da transação 
        [24] - Valor principal da parcela 
        [25] - Valor total da parcela 
        [26] - Valor do lançamento 
        [27] - Custo de antecipação da parcela 
        [28] - Valor dos impostos
        [29] - Cnpj do parceiro (SIGAMAT)
        [30] - Cnpj/Cpf do cliente 
        [31] - Evento divergencia comercial
        [32] - Id do lançamento (guide)
    10 - Posição do Cliente
        [1] - Id do cliente (guide)
        [2] - Numero do CNPJ
        [3] - Status do Cliente
        [4] - Descrição do status da posição do cliente.
        [5] - Limite total do cliente
        [6] - Limite disponivel do cliente
        [7] - Limite total do cliente
        [8] - Limite disponivel do cliente 
        [9] - Limite liberado do clientee
        [10] - Limite pré-autorizado do cliente 
        [11] - Limite usado do cliente
    11 - Cancelamento de NFS Mais Negócios
        [1] - filial
        [2] - código de identificação
@param  aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@author  Marcia Junko
@since   22/05/2020
/*/
//-------------------------------------------------------------------
Function GetRSKItems( cHost As Character, nEntity As Numeric, lAutomato As Logical, aParam As Array ) As Array
    Local oRest          As Object
    Local oJSON          As Object
    Local aJSONItens     As Array
    Local aItems         As Array
    Local aAux           As Array
    Local aProperties    As Array
    Local aERPID         As Array
    Local aSubItems      As Array
    Local aParcel        As Array
    Local aCreditTickets As Array
    Local aAuxParcel     As Array
    Local aSubAux        As Array
    Local aAuxProperties As Array
    Local cBody          As Character
    Local cAction        As Character
    Local cEndPoint      As Character
    Local cAuxContent    As Character
    Local cPropertie     As Character
    Local cTabela        As Character
    Local cOrigem        As Character
    Local nJSON          As Numeric
    Local nProp          As Numeric
    Local nPage          As Numeric
    Local nAux           As Numeric
    Local nSize          As Numeric
    Local nOption        As Numeric
    Local nBranchSize    As Numeric
    Local nLenProperties As Numeric
    Local nLenJSONItens  As Numeric
    Local lContinue      As Logical
    Local lInsert        As Logical
    Local jItems
    Local xValue         

    Default lAutomato    := .F.
    Default aParam    := {}

    aJSONItens     := {}
    aItems         := {}
    aAux           := {}
    aProperties    := {}
    aERPID         := {}
    aSubItems      := {}
    aParcel        := {}
    aCreditTickets := {}
    aAuxParcel     := {}
    aSubAux        := {} 
    aAuxProperties := {}
    cBody          := ''
    cAction        := ''
    cEndPoint      := ''
    cAuxContent    := ''
    cPropertie     := ''
    nJSON          := 0
    nProp          := 0
    nPage          := 1
    nAux           := 0
    nSize          := 0
    nOption        := 0
    nBranchSize    := FWSizeFilial()
    nLenProperties := 0
    nLenJSONItens  := 0
    lContinue      := .T. 
    lInsert        := .F.
    cTabela        := ''
    cOrigem        := ''

    If nEntity == NEWTICKET         // 1=Criação de novo ticket
        Return RSKGetNewOrders( lAutomato )
    ElseIf nEntity == AFTERSALES    // 4=Pos venda
        If __lRegistry
            cAction := __oTFRegistry:oUrlTF["risk-antecipa-bearers-V4"]
        Else
            cAction := '/integration/api/v4/bearers'
        EndIf
        Return RSKRecPosVenda( lAutomato, cAction )
    ElseIf nEntity == MONITCANCEL   // 11=Cancelamento de NFS Mais Negócios
        Return RskMonitCancel( lAutomato )
    ENDIF

    oRest := FWRest():New( cHost )

    If !Empty( cHost ) .Or. lAutomato
        Do Case    
            Case nEntity == UPDTICKET           // 2=Atualiza ticket
                If __lRegistry
                    cAction := __oTFRegistry:oUrlTF["risk-protheusapi-credit-ticket-V1"]
                Else
                    cAction := '/v1/credit_ticket'
                EndIf
                aProperties := { 'erpId', 'status', 'disapprovalReason', 'id', 'obs', 'creditLineId', 'dateCreditAnalysis', ;
                                "preAuthorizationCode", "typeInvoice", "balanceCreditTicket" }
                cTabela := 'AR0'
                cOrigem := 'RSKA010'
            Case nEntity == UPDARINVOICE        // 3=Atualiza fatura
                If __lRegistry
                    cAction := __oTFRegistry:oUrlTF["risk-protheusapi-invoice-partner-V3"]
                Else
                    cAction := '/v3/invoice_partner'
                EndIf
                aProperties := { 'erpId', 'id', 'responseCode', 'responseMessage','transaction' }
                aAuxProperties := { 'transaction', 'bankSlip', 'installments' }
                cTabela := 'AR1'
                cOrigem := 'RSKA020'
            Case nEntity == CONCESSION          // 5=Concessão
                If __lRegistry
                    cAction := __oTFRegistry:oUrlTF["risk-protheusapi-credit-concession-V4"]
                Else
                    cAction := '/v4/credit_concession'
                EndIf    
                aProperties := { 'erpId', 'id', 'customerErpId', 'desiredLimit', 'approvedCreditLimit', ;  
                                'requestDate', 'evaluationDate', 'status', 'observationReason', 'origin', 'codeAnalyze' }
                cTabela := 'AR5'
                cOrigem := 'RSKA060'
            Case nEntity == NFSCANCEL           // 7=Cancelamento de NFS Mais Negócios
                If __lRegistry
                    cAction := __oTFRegistry:oUrlTF["risk-protheusapi-invoice-cancellation-V3"]
                Else
                    cAction := '/v3/invoice_cancellation'
                EndIf
                aProperties := { 'erpId', 'id', 'status', 'observation', 'amountDebitTax', 'balanceCreditTicket', ;
                                'instalment', 'debitDate', 'amountDebitTotal', 'amountReturn', 'amountReversalTax' }
                cTabela := 'AR1'
                cOrigem := 'RSKA020'
            Case nEntity == CONCILIATION        // 9=Conciliação
                If __lRegistry
                    cAction := __oTFRegistry:oUrlTF["risk-protheusapi-conciliation-V4"]
                Else
                    cAction := '/v4/conciliation'
                EndIf
                aProperties := { 'ConciliacaoId', 'codigoGrupo', 'dataLancamentos', 'contas' }
                cTabela := 'AR4'
                cOrigem := 'RSKA050'
            Case nEntity == CLIENTPOSITION      // 10=Posição do Cliente
                If __lRegistry
                    cAction := __oTFRegistry:oUrlTF["risk-protheusapi-position-V1"]
                Else
                    cAction := '/v1/position'
                EndIf
                aProperties := { 'id', 'cpfCnpj', 'status', 'statusDescription', 'customerType', 'numberOfDaysPaymentOverdue', 'purchaseLimit', 'allowForwardSale' }
                cTabela := 'AR3'
                cOrigem := 'RSKA040'
        EndCase        

        LogMsg( "GetRSKItems", 23, 6, 1, "", "", "GetRSKItems -> API " + cAction)

        While lContinue
            
            cEndPoint := cAction + "?page=" + Alltrim( Str( nPage ) ) 

            //------------------------------------------------------------------------------
            // Busca os registros que serão tratados
            //------------------------------------------------------------------------------
            cBody := RSKRestExec( RSKGET, cEndPoint, @oRest,/*xValues*/,/*nTypePlat*/,/*nTypeAuth*/,/*lCompanyID*/,/*lProtheusAPI*/, nEntity, cTabela, cOrigem, aParam )   // GET 

            If !Empty( cBody )
                oJSON := JSONObject():New() 
                oJSON:FromJSON( cBody )

                //------------------------------------------------------------------------------
                // Carrega os items da propriedade principal
                //------------------------------------------------------------------------------
                aJSONItens := oJSON:GetJsonObject( 'items' )
                lContinue  := oJSON:GetJsonObject( "hasNext" )  
                If ValType( aJSONItens ) == "A" .And. len( aJSONItens ) > 0 

                    If nEntity == CLIENTPOSITION .And. Ascan( aJSONItens[1]:GetNames(), {|x| x == 'enableLongTermConditions' } ) > 0
                        aProperties := { 'id', 'cpfCnpj', 'status', 'statusDescription', 'customerType', 'numberOfDaysPaymentOverdue', 'purchaseLimit', 'allowForwardSale', 'enableLongTermConditions', 'maximumDaysLongTerm' }
                    EndIf
                    nLenJSONItens  := Len( aJSONItens )
                    nLenProperties := Len( aProperties )
                    
                    For nJSON := 1 to nLenJSONItens
                        aAux := {}
                        lInsert := .F.
                        cContent := ''
                        xValue := NIL

                        //------------------------------------------------------------------------------
                        // Trata somente as propriedades necessárias para o fluxo
                        //------------------------------------------------------------------------------
                        For nProp := 1 to nLenProperties
                            cPropertie := aProperties[ nProp ]
                            xValue := aJSONItens[ nJSON ][ cPropertie ]
                            
                            If Valtype( xValue ) != "U"
                                If cPropertie == 'erpId'  
                                    aErpID := StrTokArr2( xValue , '|', .T.)
                                
                                    cContent += Padr( aErpID[2], nBranchSize )
                                    If nEntity == CONCESSION .And. Empty( aErpID[3] ) // 5=Concessão
                                        //------------------------------------------------------------------------------
                                        // Reserva espaco no array para gerar a numeracao. 
                                        //------------------------------------------------------------------------------
                                        cContent += '|' + " "
                                    Else
                                        cContent += '|' + aErpID[3]
                                    EndIf
                                ElseIf cPropertie == 'customerErpId'
                                    aErpID := StrTokArr2( xValue , '|', .T. )
                                
                                    cContent += Padr( aErpID[2], nBranchSize ) + '|' + aErpID[3] + '|' + aErpID[4]
                                ElseIf cPropertie == "preAuthorizationCode"
                                    cContent += Iif( xValue == 0, ' ', Alltrim( Str( xValue ) ) ) 
                                ElseIf 'id' $ Lower( cPropertie )
                                    cContent += StrTran( xValue, '-', '')
                                ElseIf cPropertie $ 'dataLancamentos'
                                    cAuxContent := Subs( xValue, 1, At( 'T', xValue ) - 1 )

                                    cContent += StrTran( cAuxContent, '-', '')
                                ElseIf cPropertie == 'obs'
                                    cContent += StrTran( DecodeUTF8( xValue ), '|', CHR(13) + CHR(10) )
                                ElseIf cPropertie  $ 'transaction|purchaseLimit'
                                    lInsert := .T.
                                    cAuxContent := ''
                                    
                                    //------------------------------------------------------------------------------
                                    // Carrega as informações sobre as transações
                                    //------------------------------------------------------------------------------
                                    IF( cPropertie == 'transaction')
                                        nOption := INVOICE_INSTALLMENT      // 1=Parcelas da Invoice
                                        jItems := aJSONItens[ nJSON ]:GetJsonObject( "transaction" )
                                    Else
                                        nOption := PURCHASE_LIMIT           // 2=Limites do cliente
                                        jItems := aJSONItens[ nJSON ]:GetJsonObject( "purchaseLimit" )
                                    ENDIF
                                    cAuxContent := GetTransactions( jItems, @aParcel, nOption, @aCreditTickets )
                                    
                                    //------------------------------------------------------------------------------
                                    // Inclui os dados no vetor de controle
                                    //------------------------------------------------------------------------------
                                    cAuxContent := cContent + Subs( cAuxContent, 1, Len( cAuxContent ) - 1 )
                                    Aadd( aItems, StrTokArr2( cAuxContent , '|', .T. ) )
                                    nSize := Len( aItems )

                                    //------------------------------------------------------------------------------
                                    // Volta para numerico as posições de valor
                                    //------------------------------------------------------------------------------
                                    IF( nOption ==  1 )
                                        aItems[ nSize ][ UPD_I_TOTAL_FEE ]  := Val( aItems[ nSize ][ UPD_I_TOTAL_FEE ] )    // [8]-valor total das taxas
                                        aItems[ nSize ][ UPD_I_TOTAL_PARC ] := Val( aItems[ nSize ][ UPD_I_TOTAL_PARC ] )   // [9]-valor total das parcelas
                                    Else
                                        aItems[ nSize ][ UPD_C_DAYSPAYOVER ]:= Val( aItems[ nSize ][ UPD_C_DAYSPAYOVER ] )  // [6]-Dias em atraso.
                                        aItems[ nSize ][ UPD_C_TOTALPUR ]   := Val( aItems[ nSize ][ UPD_C_TOTALPUR ] )     // [7]-imite total do cliente
                                        aItems[ nSize ][ UPD_C_AVALIPUR ]   := Val( aItems[ nSize ][ UPD_C_AVALIPUR ] )     // [8]-Limite disponivel do cliente
                                        aItems[ nSize ][ UPD_C_RELEAPUR ]   := Val( aItems[ nSize ][ UPD_C_RELEAPUR ] )     // [9]-Limite liberado do cliente
                                        aItems[ nSize ][ UPD_C_PREAUTPUR ]  := Val( aItems[ nSize ][ UPD_C_PREAUTPUR ] )    // [10]-Limite pré-autorizado do cliente
                                        aItems[ nSize ][ UPD_C_USEPUR ]     := Val( aItems[ nSize ][ UPD_C_USEPUR ] )       // [11]-Valor faturado do cliente
                                    ENDIF

                                    cContent := ''
                                ElseIf cPropertie == 'observationReason' .And. Empty( xValue )
                                    cContent += " "  
                                ElseIf cPropertie == 'contas'
                                    //------------------------------------------------------------------------------
                                    // Salva informações sobre as contas
                                    //------------------------------------------------------------------------------
                                    jItems := aJSONItens[ nJSON ]:GetJsonObject( "contas" )
                                    GetAccounts( jItems, cContent, @aItems ) 

                                    cContent := ''
                                ElseIf cPropertie == 'allowForwardSale'
                                    AADD( aItems[Len( aItems )], IF(xValue, "0", "1" ) )
                                ElseIf cPropertie == 'enableLongTermConditions'
                                    AADD( aItems[Len( aItems )], IF(xValue, "1", "2" ) )
                                ElseIf cPropertie == 'maximumDaysLongTerm'
                                    AADD( aItems[Len( aItems )], cValToChar( xValue ) )
                                Else
                                    //------------------------------------------------------------------------------
                                    // Faz o tratamento necessário para incluir a informação na variável
                                    //------------------------------------------------------------------------------
                                    If Valtype( xValue ) == "N"
                                        cContent += Alltrim( Str( xValue ) )
                                    Else
                                        cContent += DecodeUTF8( xValue )
                                    EndIf
                                EndIf
                            else
                                //------------------------------------------------------------------------------
                                // Adiciona as posições que não tem informação preenchida para manter a mesma
                                // estrutura e ordem da variável de retorno desta função, de acordo com o que é
                                // esperado nas demais funções.
                                //------------------------------------------------------------------------------
                                If nEntity != UPDTICKET     // 2=Atualiza ticket
                                    cContent += ' '
                                else
                                    If nProp != Len( aProperties ) 
                                        cContent += ' '
                                    else
                                        //------------------------------------------------------------------------------
                                        // Adiciona também as posições que não fazem parte do payload
                                        //------------------------------------------------------------------------------
                                        For nAux := 1 to len( aAuxProperties ) + 3
                                            If nAux > 1
                                                cContent += '|'
                                            EndIf
                                            cContent += ' '
                                        Next
                                    EndIf    
                                EndIf
                            EndIF
                            
                            If len( cContent ) > 1
                                cContent += '|'
                            EndIf
                        Next

                        //------------------------------------------------------------------------------
                        // Transforma as propriedades selecionadas no array de itens para o fluxo
                        //------------------------------------------------------------------------------
                        If !Empty( cContent ) 
                            cContent := Subs( cContent, 1, Len( cContent ) - 1 )

                            Aadd( aItems, StrtokArr( cContent, '|' ) )
                        ENDIF

                        //------------------------------------------------------------------------------
                        // Só atribui as parcelas no array se estiver rodando atualização de fatura
                        //------------------------------------------------------------------------------
                        If nEntity == UPDARINVOICE      // 3=Atualiza fatura
                            If Len( aItems[ Len( aItems ) ] ) >= UPD_I_PARCELS  // [11]-informações das parcelas
                                If lInsert
                                    aItems[ Len( aItems ) ][ UPD_I_PARCELS ] := aClone( aParcel )        // [11]-informações das parcelas
                                Else
                                    aItems[ Len( aItems ) ][ UPD_I_PARCELS ] := {}                  // [11]-informações das parcelas
                                EndIf
                            EndIf
                            If lInsert
                                aItems[ Len( aItems ) ][ 12 ] := aClone( aCreditTickets ) // [12]-informações dos Tickets
                            EndIf

                        EndIf                    
                    Next
                else
                    lContinue := .F.
                EndIf
            else
                lContinue := .F. 
                If !lAutomato
                    LogMsg( "GetRSKItems", 23, 6, 1, "", "", "GetRSKItems -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )   
                Endif
            Endif
            nPage++ 
        End 
    EndIf

    FWFreeArray( aAux )
    FWFreeArray( aJSONItens )
    FWFreeArray( aProperties )
    FWFreeArray( aERPID )
    FWFreeArray( aSubItems )
    FWFreeArray( aParcel )
    FWFreeArray( aCreditTickets )
    FWFreeArray( aAuxParcel )
    FWFreeArray( aSubAux )
    FWFreeArray( aAuxProperties )
    FreeObj( oRest )
    FreeObj( oJSON )    
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTransactions
Função auxiliar para carga dos dados de transação no endpoint invoice_partner.

@param jItems, JSON, objeto com os itens da transação
@param @aParcel, array, vetor que armazena os dados de parcela para serem encaminhados 
    à função do Protheus resposável pelo processamento.
@param nOption, number, sendo: 1 = parcelas Invoice e 2 = Limites do Cliente.   
@param aCreditTickets, array, vetpr que armazena os dados dos Tickets de Créditos.   

@return caracter, conteúdo que será transformado em vetor.
@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetTransactions( jItems, aParcel, nOption, aCreditTickets )
    Local nAux           := 0
    Local nPayment       := 0
    Local nFee           := 0
    Local nSub           := 0
    Local nSubAux        := 0
    Local cReceiptDt     := ''
    Local cAuxContent    := ''
    Local cPropertie     := ''
    Local aAuxProperties := {}
    Local aSubItems      := {}
    Local aAuxParcel     := {}
    Local aAuxTktCrd     := {}
    Local aSubAux        := {}
    Local aParcelaAux    := {}
    Local aCTickets      := {}
    Local xAuxValue      := NIL
    Local oSubItems
    Local oSubAux

    IF ( nOption == INVOICE_INSTALLMENT )   // 1=Parcelas da Invoice
        aAuxProperties := { 'transactionCode', 'bankSlip', 'installments', 'creditTickets', 'issuerReceiptType' }
    Else                                    // 2=Limites do cliente
        aAuxProperties := { 'totalPurchaseLimit', 'availablePurchaseLimit', 'releasedPurchaseLimit', ;
                     'preAuthorizationPurchaseLimit', 'usedPurchaseLimit' }
    ENDIF

    //------------------------------------------------------------------------------
    // Trata somente as propriedades necessárias para o fluxo
    //------------------------------------------------------------------------------
    For nAux := 1 To Len( aAuxProperties )
        cPropertie := aAuxProperties[ nAux ]
        xAuxValue  := jItems[ cPropertie ]

        If Valtype( xAuxValue ) != "U"
            If cPropertie $ 'dataVencimentoOriginalParcela|dataVencimentoAtualParcela'
                cAuxContent += StrTran( xAuxValue, '-', '' )
            Elseif cPropertie == 'tipoLancamento'
                cAuxContent += Iif( Upper( Alltrim( xAuxValue ) ) == 'CREDITO', '1', '2')
            ElseIf cPropertie == 'installments'
                nPayment   := 0
                nFee       := 0
                cReceiptDt := ''
                aSubItems  := jItems:GetJsonObject( "installments" )
                For nSub := 1 To Len( aSubItems )
                    aAuxParcel := Array(9)
                    oSubItems  := aSubItems[ nSub ]
                    cReceiptDt := oSubItems[ 'issuerReceiptDate' ]
                    cReceiptDt := StrTran( cReceiptDt, '-', '' )
                    nPayment   += oSubItems[ 'issuerReceiptAmount' ]
                    aSubAux    := oSubItems[ "installmentFees" ]
                    For nSubAux := 1 To Len( aSubAux )
                        oSubAux := aSubAux[ nSubAux ] 
                        
                        If oSubAux[ 'feeTypeId' ] == "1" .Or. oSubAux[ 'feeTypeId' ] == "4"
                            nFee += oSubAux[ 'feeAmountBRL' ]   
                    
                            aAuxParcel[ PARCEL_FEEID ]    := oSubAux[ 'feeTypeId' ]      // [6]-id tipo de taxa
                            aAuxParcel[ PARCEL_FEETYPE ]  := oSubAux[ 'feeType' ]        // [7]-tipo de taxa Parcela
                            aAuxParcel[ PARCEL_FEEVALUE ] := oSubAux[ 'feeAmount' ]      // [8]-valor da taxa Parcela
                            aAuxParcel[ PARCEL_RSVALUE ]  := oSubAux[ 'feeAmountBRL' ]   // [9]-valor da taxa da parcela em reais
                        EndIf        
                    Next 

                    aAuxParcel[ PARCEL_NUMBER ]    := oSubItems[ 'numberOfInstallments' ]                     // [1]-numero da parcela
                    aAuxParcel[ PARCEL_DUEDATE ]   := StrTran(oSubItems[ 'installmentExpireDate' ], '-', '' ) // [2]-data de vencimento da parcela
                    aAuxParcel[ PARCEL_VALUE ]     := oSubItems[ 'installmentAmount' ]                        // [3]-valor da parcela
                    aAuxParcel[ PARCEL_RECAMOUNT ] := oSubItems[ 'issuerReceiptAmount' ]                      // [4]-valor de recebimento parceiro
                    aAuxParcel[ PARCEL_AMOUNTDT ]  := StrTran(oSubItems[ 'issuerReceiptDate' ], '-', '' )      // [5]-data de recebimento parceiro
                    
                    aAdd( aParcelaAux, aAuxParcel )
                Next

                //------------------------------------------------------------------------------
                // ATENÇÂO - Não retirar o espaço no fim da proxima linha, pois ela faz parte do fluxo 
                //------------------------------------------------------------------------------
                cAuxContent += Alltrim( Str( nFee ) ) + '|' + Alltrim( Str( nPayment ) ) + '|' + cReceiptDt + '| '
            ElseIf cPropertie == 'creditTickets'
                aSubItems := jItems:GetJsonObject( "creditTickets" )
                For nSub := 1 To Len( aSubItems )
                    aAuxTktCrd := Array(2)
                    oSubItems  := aSubItems[ nSub ]
                    aAuxTktCrd[ 01 ]    := oSubItems[ 'preAuthorizationCode' ]   // [1]-Código de Pré-Autorização
                    aAuxTktCrd[ 02 ]    := oSubItems[ 'orderNumber' ]            // [2]-Número do Pedido
                    aAdd( aCTickets, aAuxTktCrd )
                Next
            Else 
                If Valtype( xAuxValue ) == "N"
                    cAuxContent += Alltrim( Str( xAuxValue ) )
                else
                    cAuxContent += DecodeUTF8( xAuxValue )
                ENDIF
            EndIf
        else 
            cAuxContent += ' '
        EndIf                     
        cAuxContent += '|'
    Next

    aParcel        := aClone(aParcelaAux)
    aCreditTickets := aClone(aCTickets)

    FWFreeArray( aAuxProperties )
    FWFreeArray( aSubItems )
    FWFreeArray( aAuxParcel )
    FWFreeArray( aAuxTktCrd )
    FWFreeArray( aSubAux )
    FWFreeArray( aParcelaAux )
    FWFreeArray( aCTickets )
    FreeObj( oSubItems )
    FreeObj( oSubAux )
 Return cAuxContent

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAccounts
Função auxiliar para carga dos dados de conta no endpoint conciliation.

@param jItems, JSON, objeto com os itens da transação
@param cContent, caracter, string com dados básicos para gravação
@param @aItems, array, vetor com itens que serão retornados ao vetor principal

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetAccounts( jItems As Json, cContent As Character, aItems As Array ) 
    Local oItem          As Object
    Local oSubItem       As Object
    Local nCount         As Numeric
    Local nAux           As Numeric
    Local nSub           As Numeric
    Local nSubAux        As Numeric
    Local nLen           As Numeric
    Local aAuxProperties As Array
    Local aSubItems      As Array
    Local aSubProperties As Array
    Local cAuxContent    As Character
    Local cSubContent    As Character
    Local cAddItem       As Character
    Local cPropertie     As Character
    Local xAuxValue      
    Local xSubValue      

    oItem          := Nil
    oSubItem       := Nil
    nCount         := 0
    nAux           := 0
    nSub           := 0 
    nSubAux        := 0
    nLen           := 0
    aAuxProperties := {}
    aSubItems      := {}
    aSubProperties := {}
    cAuxContent    := ''
    cSubContent    := ''
    cAddItem       := ''
    cPropertie     := ''
    xAuxValue      := NIL
    xSubValue      := NIL

    aAuxProperties := { 'contaId', 'banco', 'agencia', 'contaCorrente', 'lancamentos' }
    aSubProperties := { 'parcela', 'numeroParcelas', 'numeroNotaFiscal', 'codigoTransacao', 'tipoEvento', 'tipoEventoDesc', 'tipoLancamento', 'tipoTransacao', 'tipoTransacaoDesc', 'lancamentoFuturo', ;
                        'dataLancamento', 'dataEvento', 'dataVencimentoOriginalParcela', 'dataVencimentoAtualParcela', 'valorPrincipalTransacao', 'valorTotalTransacao', 'valorPrincipalParcela', ;
                        'valorTotalParcela', 'valorLancamento', 'custoAntecipacaoParcela', 'valorImpostos', 'cnpjParceiro', 'cnpjCpf', 'eventoDivergenciaComercial', 'lancamentoId', '_extraInfo', ;
                        'tipoDevolucaoOrigem', 'valorPrincipalParcelaCalculado' ,'erpId', 'codigoSolicitacao' }

    //------------------------------------------------------------------------------
    // Itera pelos items do JSON
    //------------------------------------------------------------------------------
    For nCount := 1 to len( jItems )                                            
        cAuxContent := ''
        oItem := jItems[ nCount ]

        //------------------------------------------------------------------------------
        // Trata somente as propriedades necessárias para o fluxo
        //------------------------------------------------------------------------------
        For nAux := 1 to len( aAuxProperties )
            cPropertie := aAuxProperties[ nAux ]
            xAuxValue := oItem[ cPropertie ]

            If Valtype( xAuxValue ) != "U"
                If 'id' $ Lower( cPropertie )
                    cAuxContent += StrTran( xAuxValue, '-', '')
                ElseIf cPropertie == 'lancamentos'
                    aSubItems := oItem:GetJsonObject( "lancamentos" )
                    
                    For nSub := 1 to len( aSubItems )
                        oSubItem := aSubItems[ nSub ]

                        cSubContent := ''
                        For nSubAux := 1 to len( aSubProperties )
                            cPropertie := aSubProperties[ nSubAux ]
                            xSubValue := oSubItem[ cPropertie ]

                            If Valtype( xSubValue ) != "U"
                                If cPropertie $ 'dataLancamento|dataEvento|dataVencimentoOriginalParcela|dataVencimentoAtualParcela'
                                    xSubValue := Subs( xSubValue, 1, At('T', xSubValue) - 1 )
                                    cSubContent += StrTran( xSubValue, '-', '' )
                                ElseIf 'id' $ Lower( cPropertie )
                                    cSubContent += StrTran( xSubValue, '-', '' )
                                Elseif cPropertie == 'tipoLancamento'
                                    cSubContent += Iif( Upper( Alltrim( xSubValue ) ) == 'CREDITO', '1', '2' )
                                Else 
                                    If Valtype( xSubValue ) == "N"
                                        cSubContent += Alltrim( Str( xSubValue ) )
                                    else
                                        cSubContent += DecodeUTF8( xSubValue )
                                    ENDIF
                                EndIf
                            else
                                cSubContent += ' '
                            EndIf                        
                            cSubContent += '|'
                        Next

                        cAddItem := cContent + cAuxContent + Subs( cSubContent, 1, Len( cSubContent ) - 1 )                           
                        Aadd( aItems, StrTokArr2( cAddItem, '|', .T. ) )


                        //------------------------------------------------------------------------------
                        // Volta para numerico as posições de valor
                        //------------------------------------------------------------------------------
                        nLen := len( aItems ) 
                        aItems[ nLen ][ BANK_TRANS_MAIN ]  := Val( aItems[ nLen ][ BANK_TRANS_MAIN ] )      // [22]-Valor principal da transação 
                        aItems[ nLen ][ BANK_TRANS_TOTAL ] := Val( aItems[ nLen ][ BANK_TRANS_TOTAL ] )     // [23]-Valor total da transação 
                        aItems[ nLen ][ BANK_PARC_MAIN ]   := Val( aItems[ nLen ][ BANK_PARC_MAIN ] )       // [24]-Valor principal da parcela 
                        aItems[ nLen ][ BANK_PARC_TOTAL ]  := Val( aItems[ nLen ][ BANK_PARC_TOTAL ] )      // [25]-Valor total da parcela 
                        aItems[ nLen ][ BANK_ENTRY_VALUE ] := Val( aItems[ nLen ][ BANK_ENTRY_VALUE ] )     // [26]-Valor do lançamento 
                        aItems[ nLen ][ BANK_PARC_COST ]   := Val( aItems[ nLen ][ BANK_PARC_COST ] )       // [27]-Custo de antecipação da parcela 
                        aItems[ nLen ][ BANK_TAXES ]       := Val( aItems[ nLen ][ BANK_TAXES ] )           // [28]-Valor dos impostos
                        aItems[ nLen ][ BANK_PARC_CALC ]   := Val( aItems[ nLen ][ BANK_PARC_CALC ] )       // [35]-Valor Principal Parcela Calculado
                    Next
                Else 
                    If Valtype( xAuxValue ) == "N"
                        cAuxContent += Alltrim( Str( xAuxValue ) )
                    else
                        cAuxContent += DecodeUTF8( xAuxValue )
                    ENDIF
                EndIf
            else
                cAuxContent += ' '
            EndIf                        
            cAuxContent += '|'
        Next
    NEXT

    FWFreeArray( aAuxProperties )
    FWFreeArray( aSubItems )
    FWFreeArray( aSubProperties )
    FreeObj( oItem )
    FreeObj( oSubItem )

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKAction
Função auxiliar para carga dos dados de conta no endpoint conciliation.

@param nType, number, tipo de ação que será executada
@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param aRecords, array, vetor com as informações a serem processadas
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKAction( nType As Numeric, cHost As Character, aRecords As Array, lAutomato As Logical, aParam As Array)
    Local cCompany      As Character
    Local cBranch       As Character
    Local cBKPCompany   As Character
    Local cBKPBranch    As Character
    Local aRecordInfo   As Array
    Local lNewCompany   As Logical

    Default lAutomato := .F.
    Default aParam    := {}

    lNewCompany := .F.

    cBKPCompany := cEmpAnt
    cBKPBranch := cFilAnt

    cCompany := aRecords[ REC_COMPANY ]     // [1]-grupo de empresa
    cBranch := aRecords[ REC_BRANCH ]       // [2]-codigo da filial
    aRecordInfo := aRecords[ REC_ITEMS ]    // [5]-lista de registros

    If Empty( cCompany )
        cCompany := cEmpAnt
    EndIf

    If Empty( cBranch )
        cBranch := cFilAnt
    EndIf

    If cBKPCompany != cCompany
        If nType == CONCILIATION // 9=Conciliação
            RpcClearEnv()
        EndIf
        lNewCompany := .T.
        RpcSetType(3)
        RpcSetEnv( cCompany, cBranch )
    else
        cFilAnt := cBranch

        //-----------------------------------------------------------------------------------------
        // O comando abaixo é necessário pois existem algumas rotinas do padrão que pesquisam 
        // a empresa\filial, mas não retornam o ponteiro para o registro anterior. 
        // Este comando serve para garantir que o sistema esteja posicionado no registro correto.
        //-----------------------------------------------------------------------------------------
        SM0->( MSSeek( cEmpAnt + cFilAnt ) )
    EndIf

    //-----------------------------------------------------------------------------------------
    // Se houver registros para processar, executa as rotinas de acordo com a ação necessária
    //-----------------------------------------------------------------------------------------
    If !Empty( aRecordInfo )
        Do Case
            Case nType == NEWTICKET         // 1=Criação de novo ticket        
                //--------------------------------------------------------------
	            // Funcao que cancela os tickets de credito da filial corrente
	            //--------------------------------------------------------------
	            RskCanTicket( lAutomato )
	    
	            //--------------------------------------------------------------
	            // Funcao que gera os tickets de credito da filial corrente
	            //--------------------------------------------------------------
	            RskNewTicket( aRecordInfo, lAutomato ) 
            Case nType == UPDTICKET         // 2=Atualiza ticket       
                RSKUpdTicket( aRecordInfo, lAutomato, cHost, nType )
            Case nType == UPDARINVOICE      // 3=Atualiza fatura
                RSKDesdobr( aRecordInfo, lAutomato, cHost, nType ) 
            Case nType == AFTERSALES        // 4=Pos venda
                RSKMovAftSales( aRecordInfo, lAutomato, cHost, nType  )
            Case nType == CONCESSION        // 5=Concessão
                RskUpdConcession( aRecordInfo, lAutomato, cHost, nType )        
            Case nType == NFSCANCEL         // 7=Cancelamento de NFS Mais Negócios
            	RSKConfCanc( aRecordInfo, lAutomato )
            Case nType == CONCILIATION      // 9=Conciliação
                //-------------------------------------------------------------------
                // Ordena pelo CNPJ do cliente. 
                //-------------------------------------------------------------------       
                aSort( aRecordInfo, , , {|x, y| AllTrim( Upper( x[ BANK_CUST_CNPJ ] ) ) < AllTrim( Upper( y[ BANK_CUST_CNPJ ] ) ) } )   // [30]=Cnpj/Cpf do cliente 

                RSKBankConciliation( aRecordInfo, lAutomato, cHost, nType )
            Case nType == CLIENTPOSITION    // 10=Posição do Cliente     
                RskUpdClientPos( aRecordInfo, lAutomato, aParam )
            Case nType == MONITCANCEL       // 11=Cancelamento de NFS Mais Negócios
                RSKCancNf( aRecordInfo, lAutomato ) 
        EndCase
    EndIf

    If lNewCompany
        RPCClearEnv()

        RpcSetType(3)
        RpcSetEnv( cBKPCompany, cBKPBranch )
    Else
        cFilAnt := cBKPBranch
        
        SM0->( MSSeek( cEmpAnt + cFilAnt ) )  
    EndIf

    FWFreeArray( aRecordInfo )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKPlatConfirm
Função de confirmação dos dados na plataforma RISK
@type function
@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param nType, number, tipo de ação que será executada
@param aRecords, array, vetor com as informações a serem processadas
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKPlatConfirm( cHost As Character, nType As Numeric, aRecords As Array, lAutomato As Logical, aParam As Array) 
    Local aSvAlias  As Array
    Local oRest     As Object
    Local oJASales  As Object
    Local oJSON     As Object
    Local nItem     As Numeric
    Local nPosID    As Numeric
    Local nRecCode  As Numeric
    Local cAction   As Character
    Local cEndPoint As Character
    Local cBody     As Character
    Local cAlias    As Character
    Local lSent     As Logical
    Local lStatus   As Logical
    Local nOrder    As Numeric
    Local nPosFind  As Numeric
    Local cChvFind  As Character
    Local cErpId    As Character
    Local nTypePlat As Numeric
    Local nTypeRac  As Numeric
    Local cOrigem   As Character
    Local nTotalReg As Numeric
    
    Default lAutomato := .F.
    Default aParam    := {}

    aSvAlias  := GetArea()
    oRest     := Nil
    oJASales  := Nil
    oJSON     := Nil
    nItem     := 0
    nPosID    := 0
    nRecCode  := 0
    cAction   := ''
    cEndPoint := ''
    cBody     := ''
    cAlias    := ''
    lSent     := .F.  
    lStatus   := .F.
    nOrder    := 1 
    nPosFind  := 1
    cChvFind  := ""
    cErpId    := ""
    nTypePlat := RISK         // 1=Plataforma Risk
    nTypeRac  := SERVICE      // 2=URL de autenticação de serviços
    cOrigem   := ''
    nTotalReg := 01

    If !Empty( cHost ) .Or. lAutomato
        If nType == AFTERSALES      // 4=Pos venda
            nTypePlat   := ANTECIPA // 2=Plataforma Antecipa
            nTypeRac    := AUTH     // 1=URL de autenticação no RAC
        EndIf   

        oRest := FWRest():New( cHost )   

        If nType == UPDTICKET           // 2=Atualiza ticket
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-credit-ticket-V1"]
            Else
                cAction := '/v1/credit_ticket'
            EndIf
            cAlias := 'AR0'
            nPosID := UPD_T_ID          // [5]-id do ticket   
            nRecCode := UPD_T_TICKET    // [2]-numero do ticket
            cOrigem := 'RSKA010'
        Elseif nType == UPDARINVOICE    // 3=Atualiza fatura
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-invoice-partner-V3"]
            Else
                cAction := '/v3/invoice_partner'
            EndIf
            cAlias := 'AR1'
            nPosID := UPD_I_INVOICEID   // [3]-id da fatura   
            nRecCode := UPD_I_INVOICE   // [2]-numero do documento
            cOrigem := 'RSKA020'
        Elseif nType == AFTERSALES      // 4=Pos venda
            nOrder := 2
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-antecipa-bearers-V4"]
            Else
                cAction := '/integration/api/v4/bearers' 
            EndIf              
            cAlias := 'AR4'
            nPosID := AFTER_ERPID       // [3]-Id de identificação do Titulo ( ArInvoiceInstallment )  
            nPosFind := 2
            nRecCode := AFTER_ERPID     // [3]-Id de identificação do Titulo ( ArInvoiceInstallment )  
            cOrigem := 'RSKA050'
        Elseif nType == CONCESSION      // 5=Concessão
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-credit-concession-V4"]
            Else
                cAction :=  '/v4/credit_concession' 
            EndIf
            cAlias  := "AR5"
            nPosID  := CONCESSION_RSKID     // [3]-Id da concessao RISK     
            nRecCode := CONCESSION_ID       // [2]-ID da concessão
            cOrigem := 'RSKA060'
        Elseif nType == CONCILIATION    // 9=Conciliação 
            nOrder := 2
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-conciliation-V4"] + '/confirmation'
            Else
                cAction := '/v4/conciliation/confirmation'
            EndIf            
            cAlias := 'AR4'
            nPosID := BANK_ENTRY_ID      // [32]-Id do lançamento (guide) 
            nPosFind := 32
            nRecCode := BANK_ID         // [1]-ID da conciliação (guide)
            cOrigem := 'RSKA050'
        Elseif nType == ANTECIPACAOMN   // 12=Antecipação de Pagamento
            cAction := '/protheus-api/v1/advance_payment'
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-advance-payment-V1"]
            EndIf            
            cAlias  := 'AR2'
            cOrigem := 'RSKA030'
        EndIf

        If nType == ANTECIPACAOMN // 12=Antecipação de Pagamento
            nTotalReg := Len( aRecords )
            For nItem := 01 To nTotalReg
                cEndPoint := cAction + "?id=" + aRecords[ nItem, "id" ]
                cResult   := RSKRestExec( RSKPUT, cEndPoint, @oRest, cBody, nTypePlat, nTypeRac, /*lCompanyID*/,/*lProtheusAPI*/, nType, cAlias, cOrigem, aParam )

                IF !Empty( cResult )
                    oJSON := JSONObject():New()
                    oJSON:FromJSON( cResult )   
                    lSent := oJSON:GetJsonObject( "sent" )
                    If !lSent
                        LogMsg( "RSKPlatConfirm", 23, 6, 1, "", "", "RSKPlatConfirm -> " + STR0042 ) // "Erro na confirmação do processamento na Plataforma!"
                    EndIf
                Else
                    LogMsg( "RSKPlatConfirm", 23, 6, 1, "", "", "RSKPlatConfirm -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )  
                EndIf
            Next
        Else
            DbSelectArea( cAlias )
            DbSetOrder( nOrder )
            For nItem := 1 to len( aRecords )
                lSent := .F.
                If nType == AFTERSALES .Or. nType == CONCILIATION    // 4=Pos venda ### 9=Conciliação
                    cChvFind := xFilial( "AR4" ) + aRecords[ nItem ][ nPosFind ] 
                Else 
                    cChvFind := xFilial( cAlias, aRecords[ nItem ][ nPosFind ] ) + aRecords[ nItem ][2]
                EndIf  
            
                If ( cAlias )->( DBSeek( cChvFind ) )
                    If ( nType == UPDTICKET .Or. nType == UPDARINVOICE .Or. nType == CONCESSION )   // 2=Atualiza ticket ### 3=Atualiza fatura ### 5=Concessão
                        If nType == UPDTICKET .And. AR0->AR0_STATUS == AR0_STT_CANCELED      // 2=Atualiza ticket ### 4=Cancelado
                            lStatus := .T.  
                        Else
                            lStatus := ( cAlias )->&( cAlias + '_STARSK' ) == STARSK_RECEIVED // 3=Recebido
                        EndIf
                    ElseIf nType == AFTERSALES  // 4=Pos venda
                        lStatus := ( cAlias )->&( cAlias + '_STARSK' ) == STT_RSK_CONFIRMED // 1=Confirmado
                    Else 
                        lStatus := AR4->AR4_STATUS <> STARSK_CONFIRMED      // 4=Confirmado
                    EndIf     
                    
                    If lStatus
                        If nType != AFTERSALES  // 4=Pos venda
                            If nType == CONCESSION  // 5=Concessão
                                cErpId := AllTrim(cEmpAnt) + '|' + AllTrim(aRecords[ nItem ][ CONCESSION_BRANCH  ]) + '|' + AllTrim(aRecords[ nItem ][ CONCESSION_ID  ])    // [1]=Filial da concessao ### [2]=ID da concessao
                                cEndPoint := cAction + '/' + aRecords[ nItem ][ nPosID ] + '/' + Escape(cErpId) + '/confirmation' 
                            Else
                                cEndPoint := cAction + '/' + aRecords[ nItem ][ nPosID ] + Iif( nType != CONCILIATION, '/confirmation', '')     // 9=Conciliação
                            EndIf

                            cResult := RSKRestExec( RSKPUT, cEndPoint, @oRest, cBody, nTypePlat, nTypeRac, /*lCompanyID*/,/*lProtheusAPI*/, nType, cAlias, cOrigem, aParam )
        
                            IF !Empty( cResult )
                                oJSON := JSONObject():New()
                                oJSON:FromJSON( cResult )   

                                lSent := oJSON:GetJsonObject( "sent" )

                                If lSent 
                                    RecLock( cAlias, .F. )
                                        If nType == UPDTICKET .And. AR0->AR0_STATUS == AR0_STT_CANCELED       // 2=Atualiza ticket ### 4=Cancelado
                                            AR0->AR0_STARSK := STARSK_SUBMIT        // 1=Enviar 
                                        Else
                                            &( cAlias + '_STARSK' ) := STARSK_CONFIRMED     // 4=Confirmado
                                        EndIf
                                    MSUnlock()     
                                EndIf
                            Else
                                IF !lAutomato
                                    LogMsg( "RSKPlatConfirm", 23, 6, 1, "", "", "RSKPlatConfirm -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )  
                                EndIf
                            EndIf
                        Else
                            oJASales := JsonObject():New()

                            oJASales["tenantId"]    := Nil
                            oJASales["platformId"]  := aRecords[ nItem ][ nPosFind ] 
                            oJASales["erpId"]       := aRecords[ nItem ][ nPosID ]
                            oJASales["history"]     := STR0003      //"Processado com sucesso..."
                            oJASales["returnType"]  := "00"

                            cResult := RSKRestExec( RSKPOST, cAction, @oRest, oJASales, nTypePlat, nTypeRac, /*lCompanyID*/,/*lProtheusAPI*/, nType, cAlias, cOrigem, aParam ) 

                            IF !Empty( cResult )
                                RecLock( cAlias, .F. )
                                    AR4->AR4_STARSK := STT_RSK_PROCESSED  // 2=Processado
                                MSUnlock()   
                            Else
                                If !lAutomato
                                    LogMsg( "RSKPlatConfirm", 23, 6, 1, "", "", "RSKPlatConfirm -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf 
            Next
        EndIf
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias ) 
    FreeObj( oJASales )
    FreeObj( oRest )
    FreeObj( oJSON )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobBank
Função chamada pelo Schedule para execução da rotina de conciliação.
@type function
@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada 
    por User Function
@param lAutomato, boolean, indica que a função foi chamada por um script ADVPR
@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKJobBank( aParam As Array, cFil As Character, lAutomato As Logical )
    Local lConciliation As Logical
    Local nTypeSchedule As Numeric
    Local cLockSchedule As Character

    Default lAutomato := .F.

    lConciliation := .T.
    nTypeSchedule := SCHEDULE_JOBBANK // 1=RSKJobBank
    cLockSchedule := 'RSKJobBank'

    RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, Nil, lAutomato )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskProcJob
Função auxiliar para iniciar o ambiente para execução das funções

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando executada por
User Function

@return boolean, indica se está sendo executado via Schedule ou User Function
@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RskProcJob( aParam, cFil )
    Local cCompany := NIL
    Local cBranch := NIL
    Local lJob := .F.

    Default aParam := nil
    Default cFil := NIL

    //------------------------------------------------------------------------------
    // Tratamento para validar se a execução é via JOB ou User Function
    //------------------------------------------------------------------------------
    If Valtype( aParam ) != "A" 
        If ValType( aParam ) <> "C" .AND. !Empty( cEmpAnt )
            cCompany := cEmpAnt
            cBranch := cFilant
        Else
            cCompany := aParam
            cBranch := cFil
            lJob  := .T.
        EndIf
    Else
        lJob :=  .T.
        cCompany := aParam[1]
        cBranch := aParam[2]
    EndIf
    
    IF lJob
        RPCSetType( 3 )
        RPCSetEnv( cCompany, cBranch )
    EndIF 
Return lJob

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRecbyBranch
Função auxiliar para separar os registros do endpoint por filial

@param nType, number, tipo de ação que será executada
@param aRecords, array, vetor com as informações a serem processadas

@return array, vetor com itens retornados pelo endpoint por filial
    [1] = grupo de empresa
    [2] = codigo da filial
    [3] = cgc da filial
    [4] = nome da filial
    [5] = lista de registros de acordo com o tipo. Para informações, verifique a 
            documentação do retorno da função GetRSKItems

@author  Marcia Junko
@since   24/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRecbyBranch( nType, aRecords )
    Local aSM0         := {}
    Local aRecByBranch := {}
    Local lSeekBranch  := .F.
    Local cBranch      := ""
    Local cGrpEmp      := ""
    Local nRec         := 0
    Local nBranch      := 0
    Local nLen         := 0
    Local nFind        := 0
    Local nRecPos      := 0   // Posição do array aRecord a validar
    Local nByBranch    := 0   // Posição do array aRecByBranch a pesquisar
    Local nPosSM0      := 0   // Posição do SIGAMAT para validar
    Local nLenRecords  := 0

    Default nType :=  NEWTICKET     // 1=Criação de novo ticket

    If nType == AFTERSALES      // 4=Pos venda
        nRecPos := AFTER_BRANCH           // [15]-Filial 
    ElseIf nType == CONCESSION  // 5=Concessão
        nRecPos := CONCESSION_CUSTBRANCH    // [4]-Filial do cliente               
    Else
        nRecPos := 1  
    EndIf
    nByBranch := REC_BRANCH     // [2]-código da filial         
    nPosSm0   := SM0_CODFIL

    aSM0 := FWLoadSM0()
    nLenRecords := Len( aRecords )
    For nRec := 1 To nLenRecords
		If nType == CONCILIATION 
            If Len( aRecords[ nRec ] ) < COD_FIL   // [37]-Código Filial
                nRecPos     := BANK_PART_CNPJ      // [29]-Cnpj do parceiro (SIGAMAT)
                nByBranch   := REC_CNPJ            // [3]-CNPJ/CGC da filial        
                nPosSm0     := SM0_CGC
                lSeekBranch := .F.
            Else
                nRecPos     := COD_FIL        // [37]-Código Filial
                nByBranch   := REC_BRANCH     // [2]-Codigo da filial (RSKRecbyBranch)
                nPosSm0     := SM0_CODFIL
                lSeekBranch := .T.
            EndIf
        EndIf

        cBranch := IIF( nType != CLIENTPOSITION, rtrim(aRecords[ nRec ][ nRecPos ]), cFilAnt )   // 10=Posição do Cliente     
        cGrpEmp := IIF( nType == CONCILIATION .And. lSeekBranch, aRecords[ nRec ][ COD_EMP ], cEmpAnt ) //[9]-Conciliação # [36]-Código Empresa
        
        IF !Empty( aRecByBranch ) .And. ( ( nFind := Ascan( aRecByBranch, {|x| x[ SM0_GRPEMP ] == cGrpEmp .And. ;
            Subs( x[ nByBranch ], 1, Len( cBranch ) ) == cBranch } ) ) > 0 ) 
                Aadd( aRecByBranch[ nFind ][ REC_ITEMS ], aRecords[ nRec ] )        // [5]-lista de registros
        Else
            If !Empty( cBranch ) 
                nBranch :=  Ascan( aSM0, {|x| x[ SM0_GRPEMP ] == cGrpEmp .And. Subs( x[ nPosSm0 ], 1, Len( cBranch ) ) == cBranch  } )
                If nType == CONCILIATION .And. nBranch == 0 .And. !lSeekBranch
                    nBranch :=  Ascan( aSM0, {|x| Subs( x[ nPosSm0 ], 1, Len( cBranch ) ) == cBranch  } )
                EndIf
            Else
                nBranch :=  Ascan( aSM0, {|x| x[ SM0_GRPEMP ] == cGrpEmp } )      
            EndIf 

            IF nBranch > 0
                aAdd( aRecByBranch, Array(5) ) 

                nLen := len( aRecByBranch )
                aRecByBranch[ nLen ][ REC_COMPANY ] := aSM0[ nBranch ][ SM0_GRPEMP ]    // [1]-grupo de empresa  
                aRecByBranch[ nLen ][ REC_BRANCH ]  := aSM0[ nBranch ][ SM0_CODFIL ]    // [2]-código da filial
                aRecByBranch[ nLen ][ REC_CNPJ ]    := aSM0[ nBranch ][ SM0_CGC ]       // [3]-CNPJ\CGC da filial
                aRecByBranch[ nLen ][ REC_NAME ]    := aSM0[ nBranch ][ SM0_NOMRED ]    // [4]-nome da filial
                aRecByBranch[ nLen ][ REC_ITEMS ]   := {}                               // [5]-lista de registros

                Aadd( aRecByBranch[ nLen ][ REC_ITEMS ], aRecords[ nRec ] )             // [5]-lista de registros
            EndIf
        EndIf  
    Next

    FWFreeArray( aSM0 )
Return aRecByBranch 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKGetNewOrders
Função que busca os pedidos que ainda não viraram ticket.
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os pedidos para transformar em ticket.
    [1] - filial
    [2] - numero do pedido
    [3] - cliente 
    [4] - loja
@author  Marcia Junko
@since   25/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKGetNewOrders( lAutomato )
    Local aSvAlias := GetArea()
    Local aItems := {}
    Local aBranches := {}
    Local aKnownBranches := {}
    Local cTemp := ''
    Local cBranch := ''
    
    Default lAutomato := .F.

    aBranches := FWLoadSM0()
    cTemp := GetQryNewOrders()

    While ( cTemp )->( !EOF() )
        cBranch := SeekFullBranch( aBranches, @aKnownBranches, ( cTemp )->FILIAL )

        aAdd( aItems, { cBranch, ( cTemp )->PEDIDO, ( cTemp )->CLIENTE, ( cTemp )->LOJA } )

        ( cTemp )->( DBSkip() )
    End

    ( cTemp )->( DBCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )    
    FWFreeArray( aBranches )    
    FWFreeArray( aKnownBranches )    
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQryNewOrders
Função auxiliar para montagem da query de pesquisa dos pedidos que ainda não 
viraram ticket.

@return caracter, nome do alias temporária com a consulta dos novos tickets.
@author  Marcia Junko
@since   25/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function GetQryNewOrders()
    Local aSvAlias := GetArea()
    Local cQuery := ''
    Local cTempAlias := ''

    cQuery := "SELECT C9_FILIAL FILIAL, C9_PEDIDO PEDIDO, C9_CLIENTE CLIENTE, " + ;
            " C9_LOJA LOJA " + ;
            " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
            " WHERE SC9.C9_TICKETC = ' ' AND SC9.C9_BLCRED = '80' " + ; 
                " AND SC9.C9_NFISCAL = ' ' AND SC9.C9_SERIENF = ' ' " + ;
                " AND SC9.D_E_L_E_T_ = ' ' " + ;
            " GROUP BY C9_FILIAL,C9_PEDIDO, C9_CLIENTE, C9_LOJA " + ;
            " ORDER BY C9_FILIAL,C9_PEDIDO, C9_CLIENTE, C9_LOJA "
    
    cQuery := ChangeQuery( cQuery )  

    cTempAlias := MPSysOpenQuery( cQuery )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )
Return cTempAlias 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SeekFullBranch
Função auxiliar para buscar a filial completa do registro para poder associar corretamente
o registro na plataforma.
Esta função é útil, pois não há CNPJ da filial em registros com algum nível de 
compartilhamento e somente com a filial completa é possível atrelar ao organization na 
.plataforma

@param aBranches, array, vetor com todas as filiais do sistema
@param @aKnownBranches, array, vetor com as filiais que já foram processadas para diminuir 
    a pesquisa devido ao WHILE.
@param cBranch, caracter, filial a ser pesquisada

@return caracter, filial completa que foi retornada.
@author  Marcia Junko
@since   27/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function SeekFullBranch( aBranches, aKnownBranches, cBranch )
    Local cFullBranch := ''
    Local cSeek := ''
    Local nItem := 0
    Local nLen := 0

    If ( nItem := Ascan( aKnownBranches, {|x| x[1] == Upper( Alltrim( cBranch ) ) } ) ) > 0
        cFullBranch := aKnownBranches[ nItem ][2]
    else
        cSeek := Upper( Alltrim( cBranch ) )
        nLen := Len( cSeek )

        If nLen != 0
            nItem := Ascan( aBranches, {|x| Upper( Subs( x[ SM0_CODFIL ], 1, nLen ) ) == cSeek } )

            cFullBranch := aBranches[ nItem ][ SM0_CODFIL ]
        else
            cFullBranch := aBranches[ 1 ][ SM0_CODFIL ]
        EndIf

        aAdd( aKnownBranches, { cSeek, cFullBranch } )
    EndIf
Return cFullBranch

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRecPosVenda
Função que separa somente os registros do Pos-venda ( 11-Prorrogação de vencimentos | 
    12-Bonificação | 13-Devolução | 14-Liberação de NCC ) dos dados do antecipa.
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados de pós venda do Antecipa. Para informações, verifique a documentação 
    do retorno da função GetRSKItems para o tipo 4.
@author  Marcia Junko
@since   29/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRecPosVenda( lAutomato As Logical, cAction As Character ) As Array
    Local aSvAlias      As Array
    Local aItems        As Array
    Local aRecAntecipa  As Array
    Local cOperations   As Character
    Local nPosOperation As Numeric

    Default lAutomato := .F.

    aSvAlias      := GetArea()
    aItems        := {}
    aRecAntecipa  := {}
    cOperations   := "11|12|13|14"              // 11-Prorrogação de vencimentos | 12-Bonificação | 13-Devolução | 14-Liberação de NCC
    nPosOperation := AFTER_MOVTYPE            // [5]-Posição do tipo de operação

    aRecAntecipa := RSKRecAntecipa( lAutomato, cAction )
    If !Empty( aRecAntecipa )
        aEval( aRecAntecipa, {|x|  Iif( alltrim( Str( x[ nPosOperation ] ) )  $ cOperations, Aadd( aItems , aClone(x) ), ) } )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aRecAntecipa )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKRecAntecipa
Função que busca os registros do Antecipa para execução das funções do Pos venda.
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, dados retornados pela plataforma do Antecipa. Para informações, 
    verifique a documentação do retorno da função GetRSKItems para o tipo 4.
@author  Marcia Junko
@since   27/06/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RSKRecAntecipa( lAutomato As Logical, cAction As Character ) As Array
    Local aSvAlias     As Array
    Local aItems       As Array
    Local aProperties  As Array
    Local aCreditUnits As Array
    Local aNumberProp  As Array
    Local aERPID       As Array
    Local aAuxCred     As Array
    Local aObject      As Array
    Local cERPIDFrom   As Character
    Local cERPIDTo     As Character
    Local cResult      As Character
    Local cContent     As Character
    Local cPropertie   As Character
    Local cBranch      As Character
    Local cERPId       As Character
    Local nRec         As Numeric
    Local nProp        As Numeric
    Local nSub         As Numeric
    Local nLen         As Numeric
    Local nBranchSize  As Numeric
    Local nSAccBranch  As Numeric
    Local nSAccPrefix  As Numeric
    Local nSAccNumber  As Numeric
    Local nSAccParcel  As Numeric
    Local nSAccType    As Numeric
    Local oRest        As Object
    Local oJSON        As Object
    Local oRecord      As Object
    Local oCreditUnits As Object
    Local xValue

    Default lAutomato := .F.

    aSvAlias     := GetArea()
    aItems       := {}
    aProperties  := {}
    aCreditUnits := {}
    aNumberProp  := {}
    aERPID       := {}
    aAuxCred     := {}
    aObject      := {}
    cERPIDFrom   := ''
    cERPIDTo     := ''
    cResult      := ''
    cContent     := ''
    cPropertie   := ''
    cBranch      := ''
    cERPId       := ''
    nRec         := 0
    nProp        := 0
    nSub         := 0
    nLen         := 0
    nBranchSize  := FWSizeFilial()
    nSAccBranch  := TamSX3( "E1_FILIAL")[1] 
    nSAccPrefix  := TamSX3( "E1_PREFIXO")[1]
    nSAccNumber  := TamSX3( "E1_NUM" )[1]
    nSAccParcel  := TamSx3( "E1_PARCELA" )[1]
    nSAccType    := TamSx3( "E1_TIPO" )[1]
    xValue       := NIL
    oRest        := Nil
    oJSON        := Nil
    oRecord      := Nil
    oCreditUnits := Nil

    cERPIDFrom  := cEmpAnt + "|              "
    cERPIDTo    := cEmpAnt + "|||||||||||||||"

    cAction += "?ErpId.from=" + Escape( cERPIDFrom ) + "&ErpId.to=" + Escape( cERPIDTo ) + "&AppCode=Risk"
    aProperties := { 'tenantId', 'platformId', 'erpId', 'date', 'operation', 'history', 'localAmount', 'feeAmount', 'debitDate', ;
            'creditUnits', 'creditAmount', 'discountAmount', 'feeAmountOrigin', 'newDueDate', 'debitPrincipalAmount', 'totalDebitAmount', 'receiptType', 'requestCode' }

    cResult := RSKRestExec( RSKGET, cAction, @oRest, NIL, ANTECIPA, AUTH, .F., /*lProtheusAPI*/, AFTERSALES, "AR4", "RSKA050", /*aParam*/ )   // GET ### 2=Antecipa ### 1=URL de autenticação no RAC
    
    If !Empty( cResult )
        oJSON := JSONObject():New()
        oJson:fromJson( cResult )

        aObject := oJSON:GetNames()

        If ValType( aObject ) == "A" 
            SE1->( DbSetOrder(1) )  //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

            For nRec := 1 to len( oJSON )
                oRecord := oJSON[ nRec ]  

                cContent    := ''
                xValue      := NIL
                aCreditUnits := {}

                //------------------------------------------------------------------------------
                // Trata somente as propriedades necessárias para o fluxo
                //------------------------------------------------------------------------------
                For nProp := 1 to len( aProperties )                       
                    cPropertie := aProperties[ nProp ]
                    xValue := oRecord[ cPropertie ]  
                    If Valtype( xValue ) != "U"
                        If cPropertie == 'erpId'
                            cERPId := StrTran( xValue, '|', ';')
                            aErpID := StrTokArr2( xValue , '|', .T.)  
                            cContent += cERPId      

                            If SE1->( MSSeek( Padr( aERPID[2], nSAccBranch ) + Padr( aERPID[3], nSAccPrefix ) + Padr( aERPID[4], nSAccNumber ) + ;
                                    Padr( aERPID[5], nSAccParcel ) + Padr( aERPID[6], nSAccType ) ) )
                                cBranch := SE1->E1_FILORIG 
                            Else 
                                cBranch := Padr( aErpID[2], nBranchSize )  
                            EndIf 
                            
                        ElseIf cPropertie == 'creditUnits' 
                            cContent += ' '
                            oCreditUnits := oRecord:GetJsonObject( "creditUnits" )
                            For nSub := 1 to len( oCreditUnits )
                                aAuxCred := Array(8)
                                oSubItems := oCreditUnits[ nSub ]

                                aERPID := StrToKArr2( oSubItems[ 'creditErpId' ], '|', .T. )

                                aAuxCred[1] := oSubItems[ 'creditErpId' ]   // ERPID completo
                                aAuxCred[2] := aERPID[ ERPID_COMPANY ]      // [1]-empresa
                                aAuxCred[3] := aERPID[ ERPID_BRANCH ]       // [2]-filial
                                aAuxCred[4] := aERPID[ ERPID_PREFIX ]       // [3]-prefixo
                                aAuxCred[5] := aERPID[ ERPID_INVOICE ]      // [4]-numero do titulo
                                aAuxCred[6] := aERPID[ ERPID_PARCEL ]       // [5]-parcela
                                aAuxCred[7] := aERPID[ ERPID_TYPE]          // [6]-tipo
                                aAuxCred[8] := oSubItems[ 'creditAmount' ]  // valor a ser compensado

                                aAdd( aCreditUnits, aAuxCred )
                            Next
                        ElseIf 'id' $ Lower( cPropertie )
                            cContent += StrTran( xValue, '-', '')
                        Else
                            If Valtype( xValue ) == "N"                            
                                cContent += Alltrim( Str( xValue ) )
                            Else
                                cContent += xValue
                            EndIf
                        EndIf
                    Else
                        cContent += ' '
                    EndIF
                    
                    cContent += '|'
                Next

                cContent += cBranch + '|'

                If !Empty( cContent ) 
                    cContent := Subs( cContent, 1, Len( cContent ) - 1 )

                    Aadd( aItems, StrtokArr( cContent, '|' ) )
                ENDIF

                nLen := Len( aItems )
                aItems[ nLen ][ AFTER_CREDITUNITS ] := aClone( aCreditUnits )     // [10]-Vetor com as notas de crédito
    
                //------------------------------------------------------------------------------
                // Ajusta o conteúdo para o formato necessário
                //------------------------------------------------------------------------------            
                aItems[ nLen ][ AFTER_ERPID ]            := StrTran( aItems[ nLen ][ AFTER_ERPID ], ';', '|' ) // [3]-Id de identificação do Titulo
                //------------------------------------------------------------------------------
                // Ajusta as posições de valor
                //------------------------------------------------------------------------------
                aItems[ nLen ][ AFTER_MOVTYPE ]          := Val( aItems[ nLen ][ AFTER_MOVTYPE ] )             // [5]-tipo de operação
                aItems[ nLen ][ AFTER_LOCALAMOUNT ]      := Val( aItems[ nLen ][ AFTER_LOCALAMOUNT ] )         // [7]-Valor bruto da operação - valor original da parcela
                aItems[ nLen ][ AFTER_FEEAMOUNT ]        := Val( aItems[ nLen ][ AFTER_FEEAMOUNT ] )           // [8]-Valor do custo da operação 
                aItems[ nLen ][ AFTER_CREDITAMOUNT ]     := Val( aItems[ nLen ][ AFTER_CREDITAMOUNT ] )        // [11]-Valor da soma das NCCs utilizadas nessa operação 
                aItems[ nLen ][ AFTER_DISCOUNTAMOUNT ]   := Val( aItems[ nLen ][ AFTER_DISCOUNTAMOUNT ] )      // [12]-Valor do desconto a ser aplicado 
                aItems[ nLen ][ AFTER_FEEAMOUNTORIGIN ]  := Val( aItems[ nLen ][ AFTER_FEEAMOUNTORIGIN ] )     // [13]-Estorno da taxa de antecipação
                aItems[ nLen ][ AFTER_DEBITAMOUNT ]      := Val( aItems[ nLen ][ AFTER_DEBITAMOUNT ] )         // [15]-Valor do Debito a ser pago pelo parceiro a Supplier
                aItems[ nLen ][ AFTER_TOTALDEBITAMOUNT ] := Val( aItems[ nLen ][ AFTER_TOTALDEBITAMOUNT ] )    // [16]-Valor Total do Debito a ser pago pelo parceiro a Supplier contempla Taxas
            Next
        EndIf
    EndIF      

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aProperties )
    FWFreeArray( aCreditUnits )
    FWFreeArray( aNumberProp )
    FWFreeArray( aERPID )
    FWFreeArray( aAuxCred )
    FWFreeArray( aObject )
    FreeObj( oRest )
    FreeObj( oJSON )
    FreeObj( oRecord ) 
    FreeObj( oCreditUnits )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskJobFil
Função chamada pelo RskJobCommand para processamento de rotinas de processamento
por filial.

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando 
    executada por User Function
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT
@since  30/04/2021 
/*/
//-------------------------------------------------------------------
Static Function RskJobFil( aParam, cFil, lAutomato )
    If aParam == Nil .And. cFil == Nil  
        aParam  := cEmpAnt
        cFil    := cFilAnt
    EndIf
    StartJob("RskJobBranch", GetEnvServer() , .T., aParam, cFil, lAutomato )
Return Nil 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskJobBranch
Função que cria uma thread separada para processsar as rotinas por filial. 

@param aParam, array, vetor com as informações para execução da função via Schedule.
@param cFil, caracter, define qual a filial será utilizada pela função quando 
    executada por User Function
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT
@since  30/04/2021 
/*/
//-------------------------------------------------------------------
Function RskJobBranch( aParam As Array, cFil As Character, lAutomato As Logical )
    Local cEndPoint As Character

    Local lJob      As Logical
    Local lLock     As Logical
    Local lRskNTkt  As Logical

    cEndPoint := ""
    lJob      := RskProcJob( aParam, cFil )
    lLock     := LockByName("RskJobBranch", .T., .T. )
    lRskNTkt  := .T. //Geração\Cancelamento de ticket de crédito automática após liberação de pedidos.

    If __lRegistry .And. __oTFRegistry == Nil
        __oTFRegistry := FINA138BTFRegistry():New()
    EndIf

    If lLock
        lRskNTkt  := SuperGetMv( "MV_RSKNTKT", .F., .T. )  

        //---------------------------------------------
        // Cancela os tickets de credito.  
        //---------------------------------------------
        If lRskNTkt
            I18N( STR0030, { cEmpAnt, cFilAnt} ) 
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0030, { cEmpAnt, cFilAnt } )) //"Executando o processo => Geracao de Cancelamento de Ticket Empresa: #1 Filial: #2"       
            RskCanTicket( lAutomato )
        EndIf

        //--------------------------------------------------------------------------
        // Funcao que envia os tickets de credito diretamente para plataforma risk.
        //--------------------------------------------------------------------------
        If AR0->( ColumnPos( "AR0_RCOUNT" ) ) > 0 
            If __lRegistry
                cEndPoint := __oTFRegistry:oUrlTF["risk-riskapi-credit-ticket-V1"]
            Else
                cEndPoint := "/api/credit_ticket"
            EndIf
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0031, { cEmpAnt, cFilAnt } ))  //"Executando o processo => Enviando Ticket de Credito para Plataforma Risk Empresa: #1 Filial: #2" 
            //------------------------------------------------------------------------------
            // Envia os tickets de credito que foram cancelados.
            // Os tickets cancelados deverao ser enviados primeiro para evitar rejeicao
            // de credito devido o valor pre-autorizado ser proximo do limite disponivel.
            //------------------------------------------------------------------------------
            RskPostTicket( AR0_STT_CANCELED, cEndPoint, lAutomato, aParam )        // 4=Cancelado 
            
            //---------------------------------------------
            // Envia os tickets de credito para analise.
            //---------------------------------------------
            RskPostTicket( AR0_STT_AWAIT, cEndPoint, lAutomato, aParam )           // 0=Aguardando Envio
        EndIf  
            
        //--------------------------------------------------------------------------
        // Envia as concessões de credito diretamente para plataforma risk.
        //--------------------------------------------------------------------------
        If AliasInDic( "AR5" ) .And. AR5->( ColumnPos( "AR5_RCOUNT" ) ) > 0
            If __lRegistry
                cEndPoint := __oTFRegistry:oUrlTF["risk-riskapi-concession-creditconcession-V3"]
            Else
                cEndPoint := "/concession/api/v3/creditconcession"
            EndIf
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0032, { cEmpAnt, cFilAnt } )) //"Executando o processo => Enviando Concessao de Credito para Plataforma Risk Empresa: #1 Filial: #2"       
            RskPostConcession( cEndPoint, lAutomato, aParam )              
        EndIf

        //--------------------------------------------------------------------------
        // Envia as NFS Mais Negócios diretamente para plataforma risk.
        //--------------------------------------------------------------------------
        If AR1->(ColumnPos("AR1_RCOUNT")) > 0
            If __lRegistry
                cEndPoint := __oTFRegistry:oUrlTF["risk-riskapi-invoice-V3"]
            Else
                cEndPoint := "/api/v3/invoice" 
            EndIf
            LogMsg( "RSKJobCommand", 23, 6, 1, "", "", I18N( STR0033, { cEmpAnt, cFilAnt } ))    //"Executando o processo => Enviando NFS Mais Negocios para Plataforma Risk Empresa: #1 Filial #2"
            RskPostNFS( cEndPoint, lAutomato, aParam )  
        EndIf

        UnLockByName( "RskJobBranch", .T., .T. )
    Else
        LogMsg( "RskJobBranch", 23, 6, 1, "", "", STR0034 )    //"Job já está em execução por outra instância" 
    EndIf

    If lJob   
        RPCClearEnv()        
    EndIF
Return Nil  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskMonitCancel
Função que busca as notas fiscais pendentes de retorno da Sefaz
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os códigos da AR1 para processamento do cancelamento
    [1] - filial
    [2] - código de identificação
@author  Claudio Yoshio Muramatsu
@since   14/09/2021
/*/
//-------------------------------------------------------------------------------------
Static Function RskMonitCancel( lAutomato )
    Local aSvAlias       := GetArea()
    Local aItems         := {}
    Local aBranches      := {}
    Local aKnownBranches := {}
    Local cTemp          := ''
    Local cBranch        := ''
    Local cQuery         := ''

    Default lAutomato := .F.
    
    aBranches := FWLoadSM0()
    cQuery :=   "SELECT AR1_FILIAL FILIAL, AR1_COD CODIGO " + ;
                " FROM " + RetSqlName( "AR1" ) + " AR1 " + ;
                " WHERE AR1.AR1_STATUS = '" + AR1_STT_CANCELINGSEF + "' " + ; 
                    " AND AR1.D_E_L_E_T_ = ' ' " + ;
                " ORDER BY AR1_FILIAL,AR1_COD "
    
    cQuery := ChangeQuery( cQuery )
    cTemp  := MPSysOpenQuery( cQuery )

    While ( cTemp )->( !EOF() )
        cBranch := SeekFullBranch( aBranches, @aKnownBranches, ( cTemp )->FILIAL )

        aAdd( aItems, { cBranch, ( cTemp )->CODIGO } )

        ( cTemp )->( DBSkip() )
    End

    ( cTemp )->( DBCloseArea() )

    RestArea( aSvAlias )
    FWFreeArray( aSvAlias )    
    FWFreeArray( aBranches )    
    FWFreeArray( aKnownBranches )
Return aItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobPost
Função chamada pelo Schedule para execução da rotina RskJobFil.
Comandos da Plataforma para o Protheus nos processos de atualizações.
@type function
@param aParam, array, vetor com as informações para execução da função via Schedule.
@param lAutomato, logical, Indica que a função foi chamada por um script ADVPR
@author  Daniel Moda
@since   14/10/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKJobPost( aParam As Array, lAutomato As Logical)
    Local cFil           As Character
    Local lConciliation  As Logical
    Local nTypeSchedule  As Numeric
    Local cLockSchedule  As Character
    Local aTasksSchedule As Array
    Local nTypeProcess   As Numeric

    Default lAutomato := .F.

    cFil           := NIL
    lConciliation  := .F.
    nTypeSchedule  := SCHEDULE_JOBPOST // 2=RskJobPost
    cLockSchedule  := 'RSKJobPost'
    aTasksSchedule := {}

    If RskProcJob( aParam, cFil )
        nTypeProcess := SuperGetMv( "MV_RSKSPLS", .F., 1 ) //1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records

        If nTypeProcess == 3  // 3-Post, Movement e Records
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule, lAutomato )
        EndIf
        RPCClearEnv()
    EndIf
    
    FWFreeArray( aTasksSchedule )    
    FWFreeArray( aParam )

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobGetMovement
Função chamada pelo Schedule para execução da rotina RSKUpdEntity.
Comandos da Plataforma para o Protheus nos processos de movimentações.
Obs. Quando o parâmetro MV_RSKSPLS for 2 executará os comandos para de atualizações
nessa chamada.
@type function
@param aParam, array, vetor com as informações para execução da função via Schedule.
@param lAutomato, logical, Indica que a função foi chamada por um script ADVPR
@author  Daniel Moda
@since   14/10/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKJobGetMovement( aParam As Array, lAutomato As Logical)
    Local cFil           As Character
    Local lConciliation  As Logical
    Local nTypeSchedule  As Numeric
    Local cLockSchedule  As Character
    Local aTasksSchedule As Array
    Local nTypeProcess   As Numeric
    Local aBkpParam      As Array

    Default lAutomato := .F.

    cFil           := NIL
    lConciliation  := .F.
    nTypeSchedule  := SCHEDULE_JOBGETMOVEMENT // 3=RSKJobGetMovement
    cLockSchedule  := 'RSKJobGetMovement'
    aTasksSchedule := { NEWTICKET, UPDTICKET , UPDARINVOICE, MONITCANCEL, AFTERSALES, NFSCANCEL, ANTECIPACAOMN }
    aBkpParam      := AClone(aParam)

    If RskProcJob( aParam, cFil )
        nTypeProcess := SuperGetMv( "MV_RSKSPLS", .F., 1 ) //1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records

        If nTypeProcess == 2 .Or. nTypeProcess == 3 // 2=Post+Movement e Records # 3-Post, Movement e Records
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule, lAutomato )
        EndIf
        If nTypeProcess == 2 // 2=Post+Movement e Records
            nTypeSchedule  := SCHEDULE_JOBPOST // 2=RskJobPost
            cLockSchedule  := 'RSKJobPost'
            aTasksSchedule := {}
            aParam         := aBkpParam
            If RskProcJob( aParam, cFil )
                RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule, lAutomato )
            EndIf
        EndIf

        RPCClearEnv()
    EndIf

    FWFreeArray( aTasksSchedule )
    FWFreeArray( aParam )
    FWFreeArray( aBkpParam )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKJobGetRecords
Função chamada pelo Schedule para execução da rotina RSKUpdEntity.
Comandos da Plataforma para o Protheus nos processos de cadastros.
@type function
@param aParam, array, vetor com as informações para execução da função via Schedule.
@param lAutomato, logical, Indica que a função foi chamada por um script ADVPR
@author  Daniel Moda
@since   14/10/2021
/*/
//-------------------------------------------------------------------------------------
Function RSKJobGetRecords( aParam As Array, lAutomato As Logical)
    Local cFil           As Character
    Local lConciliation  As Logical
    Local nTypeSchedule  As Numeric
    Local cLockSchedule  As Character
    Local aTasksSchedule As Array
    Local nTypeProcess   As Numeric

    Default lAutomato := .F.

    cFil           := NIL
    lConciliation  := .F.
    nTypeSchedule  := SCHEDULE_JOBGETRECORDS // 4=RSKJobGetRecords
    cLockSchedule  := 'RSKJobGetRecords'
    aTasksSchedule := { CONCESSION , CLIENTPOSITION }

    If RskProcJob( aParam, cFil )
        nTypeProcess := SuperGetMv( "MV_RSKSPLS", .F., 1 ) //1-JobCommand # 2=Post+Movement e Records # 3-Post, Movement e Records

        If nTypeProcess == 2 .Or. nTypeProcess == 3 // 2=Post+Movement e Records # 3-Post, Movement e Records
            RSKJobCommand( aParam, cFil, lConciliation, nTypeSchedule, cLockSchedule, aTasksSchedule, lAutomato )
        EndIf
        RPCClearEnv()
    EndIf
    
    FWFreeArray( aTasksSchedule )
    FWFreeArray( aParam )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKConfPlat
Função que permite a execução individual da RSKPlatConfirm().
@param cHost, caracter, URL da plataforma onde será executado os endpoints
@param nType, number, tipo de ação que será executada
@param aRecords, array, vetor com as informações a serem processadas
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@author  Djalma Borges
@since   27/12/2022
/*/
//-------------------------------------------------------------------------------------
Function RSKConfPlat( cHost, nType, aRecordInfo, lAutomato )

    RSKPlatConfirm( cHost, nType, aRecordInfo, lAutomato )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRSKItems
Função para retornar os dados para processamento das APIs.
12 - Antecipação - Mais Negócios
    12 - Antecipação - Mais Negócios
        [1] - filial
        [2] - código de identificação
@param  aParam, vetor, possui os dados do agendamento (schedule), empresa, filial e usuário

@author  Daniel Moda
@since   05/02/2024
/*/
//-------------------------------------------------------------------
Static Function GetItems( nEntity As Numeric, aParam As Array, aRetGetItems As Array )
    Local oRest     As Object
    Local oJSON     As Object
    Local oRetJson  As Object
    Local cEndPoint As Character
    Local cTabela   As Character
    Local cOrigem   As Character
    Local cAction   As Character
    Local nPage     As Numeric
    Local nSize     As Numeric
    Local nX        As Numeric
    Local lContinue As Logical

    Default aParam := {}

    oRest     := Nil
    oJSON     := Nil
    oRetJson  := Nil
    cEndPoint := ''
    cTabela   := ''
    cOrigem   := ''
    cAction   := ''
    nPage     := 1
    nSize     := 1
    nX        := 01
    lContinue := .T. 
    cAction   := '/protheus-api/v1/advance_payment'

    Do Case    
        Case nEntity == ANTECIPACAOMN // 12=Antecipação de Pagamento
            If __lRegistry
                cAction := __oTFRegistry:oUrlTF["risk-protheusapi-advance-payment-V1"]
            EndIf
            cTabela := 'AR2'
            cOrigem := 'RSKA030'
    EndCase        

    LogMsg( ProcName(), 23, 6, 1, "", "", ProcName() + " -> API " + cAction)

    While lContinue
        
        cEndPoint := cAction + "?page=" + cValToChar( nPage )
        //------------------------------------------------------------------------------
        // Busca os registros que serão tratados
        //------------------------------------------------------------------------------
        cBody := RSKRestExec( RSKGET, cEndPoint, @oRest,/*xValues*/,/*nTypePlat*/,/*nTypeAuth*/,/*lCompanyID*/,/*lProtheusAPI*/, nEntity, cTabela, cOrigem, aParam )   // GET 

        If !Empty( cBody )
            oJSON := JSONObject():New() 
            oJSON:FromJSON( cBody )
            //------------------------------------------------------------------------------
            // Carrega os items da propriedade principal
            //------------------------------------------------------------------------------
            oRetJson  := JSONObject():New()
            oRetJson  := oJSON:GetJsonObject( 'items' )
            nSize     := Len( oRetJson )
            lContinue := oJSON:GetJsonObject( "hasNext" )
            If nSize > 0
                For nX := 01 To nSize
                    AADD( aRetGetItems, oRetJson[ nX ] )
                Next
            Else
                lContinue := .F.
            EndIf
        Else
            lContinue := .F.
            LogMsg( ProcName(), 23, 6, 1, "", "", ProcName() + " -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )   
        Endif
        nPage++
    EndDo 

    FreeObj( oRest )
    FreeObj( oJSON )
    FreeObj( oRetJson )

Return

//-------------------------------------------------------------------------------------
/*/
    {Protheus.doc} ActionProc
    Função que realiza o processamento do retorno do Get da função GetItems, tratado.
    por empresa/filial.

    @param nType, number, identifica qual a entidade está semdo executada. Sendo:
    @param cHost, Character, endereço onde está a plataforma
    @param aRetGetItems, Array, dados do retorno do Get da função GetItems.
    @author  Daniel Moda
    @since   07/02/2024
/*/
//-------------------------------------------------------------------------------------
Static Function ActionProc( nType As Numeric, cHost As Character, aRetGetItems As Array )
    Local cCompany    As Character
    Local cBranch     As Character
    Local nX          As Numeric
    Local nY          As Numeric
    Local nTotPaginas As Numeric
    Local nProcEmp    As Numeric
    Local nTamParc    As Numeric
    Local aErpID      As Array
    Local aErpIDItem  As Array
    Local aTotalReg   As Array

    cCompany    := ''
    cBranch     := ''
    nX          := 01
    nY          := 01
    nTotPaginas := Len( aRetGetItems )
    nProcEmp    := 0
    nTamParc    := Len( cValToChar( aRetGetItems[ nX, 'numberInstallments' ] ) )
    aErpID      := {}
    aErpIDItem  := {}
    aTotalReg   := {}
    aSort( aRetGetItems, , , {|x,y| x['erpId'] + StrZero( x['numberInstallment'], nTamParc ) < y['erpId'] + StrZero( y['numberInstallment'], nTamParc ) }) 
    AADD( aTotalReg, {} )

    aErpID := StrToKArr2( aRetGetItems[ nX, 'erpId' ], '|', .T. )
    For nX := 01 To nTotPaginas
        aErpIDItem := StrToKArr2( aRetGetItems[ nX, 'erpId' ], '|', .T. )
        If aErpID[1] <> aErpIDItem[1] .Or. aErpID[2] <> aErpIDItem[2]
            AADD( aTotalReg, {} )
            aErpID := aErpIDItem
        EndIf
        AADD( aTotalReg[ Len(aTotalReg) ], aRetGetItems[nX] )
    Next

    nProcEmp := Len( aTotalReg ) 
    For nY := 01 To nProcEmp
        aErpID := StrToKArr2( aTotalReg[ nY, 01, 'erpId' ], '|', .T. )
        If cCompany <> aErpID[1] .Or. cBranch <> aErpID[2]
            cCompany := aErpID[1]
            cBranch  := aErpID[2]
        Do Case
            Case nType == ANTECIPACAOMN .And. FindFunction( "RskAntecMn" ) // 12=Antecipação de Pagamento
                StartJob( "RskExecJob", GetEnvServer(), .T., cCompany, cBranch, aTotalReg[nY], nType, cHost )
        EndCase
        EndIf
    Next

FwFreeArray( aErpID )
FwFreeArray( aErpIDItem )
FwFreeArray( aTotalReg )

Return

//-------------------------------------------------------------------------------------
/*/
    {Protheus.doc} RskExecJob
    Chamada da função para processamento das antecipações em nova thread.

    @type function
    @param cCompany, Character, empresa
    @param cBranch, Character, filial
    @param nType, numeric, identifica qual a entidade está semdo executada
    @param cHost, Character, endereço onde está a plataforma
    @param aTotalReg, Array, dados para processamento
    @author Claudio Yoshio Muramatsu
    @since 13/05/2024
/*/
//-------------------------------------------------------------------------------------
Function RskExecJob( cCompany As Character, cBranch As Character, aTotalReg As Array, nType As Numeric, cHost As Character )
    If __lRegistry .And. __oTFRegistry == Nil
        __oTFRegistry := FINA138BTFRegistry():New()
    EndIf

    RpcSetType(3)
    RpcSetEnv( cCompany, cBranch )
    RskAntecMn( aTotalReg, nType, cHost )
Return
