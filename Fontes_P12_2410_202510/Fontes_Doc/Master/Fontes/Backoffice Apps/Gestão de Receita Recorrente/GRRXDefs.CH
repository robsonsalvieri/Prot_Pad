#include "protheus.ch"

/*-----------------------------------------------------
                    Dados da plataforma
-----------------------------------------------------*/
#Define SIZE_PLATFORM   5

// posições do array PLATFORM
#Define CLIENT_ID       1    
#Define CLIENT_SECRET   2    
#Define REGISTRY        3    
#Define PLATFORM_URL    4    
#Define PLATFORM_PATH   5    


/*-----------------------------------------------------
                    Tipos de autenticação no RAC
-----------------------------------------------------*/
#DEFINE SERVICE         1   // URL de autenticação do RAC dos endpoints acessados pelo Protheus
#DEFINE AUTH            2   // Geralmente utilizada para endpoints que se que conectam com o FRONTEND e que utilizam autenticação pelo Fluig


/*-----------------------------------------------------
                Tipo de Requisição REST
-----------------------------------------------------*/
#Define GRR_POST        1
#Define GRR_PUT         2
#Define GRR_DELETE      3
#Define GRR_PATCH       4

/*-----------------------------------------------------
            Tipos de Controle de Sincronização 
-----------------------------------------------------*/
#Define GRR_SYNC_DAYS           1 // sincroniza em dias
#Define GRR_SYNC_HOURS          2 // sincroniza em horas
#Define GRR_SYNC_MINUTES        3 // sincroniza em minutos

/*-----------------------------------------------------
            Status do Controle de Mensagens do GRR
-----------------------------------------------------*/
#Define HRF_STT_AWAIT_PROCESSING    "1"
#Define HRF_STT_PROCESSING          "2"
#Define HRF_STT_PROCESSING_FAILURE  "3"
#Define HRF_STT_PROCESSED           "4"

/*-----------------------------------------------------
            Estrutura de Integração
-----------------------------------------------------*/
#DEFINE INT_COMPANY         1
#DEFINE INT_BRANCH          2
#DEFINE INT_REFERENCE       3

/*-----------------------------------------------------
                Tipo de Metadata
-----------------------------------------------------*/
#DEFINE GRR_SALESORDER          1   // Metadata do pedido de venda    
#DEFINE GRR_SALESORDER_ITEMS    2   // Metadata dos itens do pedido de venda

/*-----------------------------------------------------
                Ações do Metadata
-----------------------------------------------------*/
#DEFINE GRR_SAVE_METADATA       1   // Montagem do metadata para enviar para a plataforma
#DEFINE GRR_LOAD_METADATA       2   // Leitura do metadata vindo da plataforma

/*-----------------------------------------------------
                Tipos de eventos de Pagamento
-----------------------------------------------------*/
#DEFINE GRR_PAY_PREDICTION      0   // Previsão de pagamento
#DEFINE GRR_PAY_SETTLEMENT      1   // Pagamento Recebido
#DEFINE GRR_PAY_CHARGEBACK      2   // Estorno
#DEFINE GRR_PAY_REVERSAL        3   // Reversão
#DEFINE GRR_PAY_REFUND          4   // Reembolso

/*-----------------------------------------------------
                Tipos de serviço do GRR
-----------------------------------------------------*/
#DEFINE GRR_CONCILIATION      1   // Conciliação


/*-----------------------------------------------------
            Tipos de títulos financeiros
-----------------------------------------------------*/
#DEFINE GRR_AR                  1   // a receber   
#DEFINE GRR_AP                  2   // a pagar

/*-----------------------------------------------------
                Tipos de eventos de Provider
-----------------------------------------------------*/
#DEFINE GRR_PROVIDER_CREATED                  "1"   // Ordem de Pagamento Criada
#DEFINE GRR_PROVIDER_GENERATED_BANKSLIP       "2"   // Notificado para Plataforma
#DEFINE GRR_PROVIDER_COMPLETED                "3"   // Ordem de Pagamento Finalizada

/*-----------------------------------------------------
                Formas de Pagamento do Provider
-----------------------------------------------------*/
#DEFINE GRR_PROVIDER_BANKSLIP       "1"     // Boleto
#DEFINE GRR_PROVIDER_PIX            "2"     // Pix

/*-----------------------------------------------------
                Payment Order
-----------------------------------------------------*/
#DEFINE GRR_PAYMENT_ORDER_SRCFIL       1     // Filial origem da solicitação
#DEFINE GRR_PAYMENT_ORDER_ALIAS        2     // Alias da solicitação
#DEFINE GRR_PAYMENT_ORDER_SOURCE       3     // Origem da assinatura
#DEFINE GRR_PAYMENT_ORDER_REQCD        4     // Código da solicitação
#DEFINE GRR_PAYMENT_ORDER_CHARID       5     // Id da cobrança no GRR
#DEFINE GRR_PAYMENT_ORDER_BILLID       6     // Id da Fatura no GRR
#DEFINE GRR_PAYMENT_ORDER_CUSIID       7     // Referência do cliente na Integração.
#DEFINE GRR_PAYMENT_ORDER_BANKSLIP     8     // Boleto
#DEFINE GRR_PAYMENT_ORDER_STATUS       9     // Statusção
#DEFINE GRR_PAYMENT_ORDER_VALUE        10    // Valor
#DEFINE GRR_PAYMENT_ORDER_DUEDATE       11    // Vencimento
#DEFINE GRR_PAYMENT_ORDER_PAYMET       12    // Método de Pagamento

/*-----------------------------------------------------
                Status da Fatura na Plataforma
-----------------------------------------------------*/
#DEFINE GRR_BILL_STATUS_CREATED 1               //Criada 
#DEFINE GRR_BILL_STATUS_AWAITINGMEASUREMENT 2   //Aguardando Medição
#DEFINE GRR_BILL_STATUS_AWAITINGPAYMENT 3       //Aguardando Pagamento
#DEFINE GRR_BILL_STATUS_PAID 4                  //Paga
#DEFINE GRR_BILL_STATUS_INCANCELLATION 5        //Em Cancelamento
#DEFINE GRR_BILL_STATUS_CANCELED 6              //Cancelada
#DEFINE GRR_BILL_STATUS_MEASUREMENTCOMPLETED 7  //Medição Realizada
#DEFINE GRR_BILL_STATUS_AWAITINGPROVIDER 8      //Aguardando Provedor
