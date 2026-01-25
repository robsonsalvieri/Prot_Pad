#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LJCRetornoPayHub ; Return       

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJCRetornoPayHub
Armazena o retorno de uma transacao do Payment Hub.

@type       Class
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJCRetornoPayHub  
    
	Data lTransOK														//Indica se a transacao foi efetuada
	Data nCodTrans   													//Codigo da transacao selecionada (Tabela de codigos de meios de pagamento, configuracoes e menus)
	Data cInstit														//Instituicao que ira processar a transacao
	Data cTpCartao														//Tipo do cartao da transacao
	Data cAdmFin														//Administradora financeira retornada na transacao
	Data lJurosLoja														//Indica se o juros é do lojista
	Data cViaCliente													//Comprovante tef via do cliente em formato texto
	Data cViaCaixa														//Comprovante tef via do caixa em formato texto
	Data aViaCliente													//Comprovante tef via do cliente em formato Array
	Data aViaCaixa														//Comprovante tef via do caixa em formato Array
	Data cNsuPayHub														//Nsu do Pyment Hub (Transacao de cartoes)
	Data cNsuAuto														//Nsu do autorizador (Transacao de cartoes)
	Data cCodAuto														//Codigo da autorizacao (Transacao de cartoes)
	Data dData															//Data da transacao
	Data cHora															//Hora da transacao
	Data nParcelas    													//Numero de parcelas
	Data nValorPgto														//Valor do pagamento (Transacoes de cartoes)
	Data nValorCanc														//Valor a ser cancelado
	Data dDataCanRei													//Data do cancelamento ou re-impressao
	Data cCartao														//Numero do cartao digitado
   	Data cDocCanRei														//Numero do documento do cancelamento ou re-impressao
	Data cCPFCGC														//Numero do documento (CPF ou CGC)
	Data cRede															//Rede
	Data aAdmin															//Administradoras selecionadas
	Data cIdtransaction													//ID da Transação
	Data cProcessorTransactionId										//ID da transação do processador
	Data cExternalTransactionId											//ID da transação Externa
	Data cErrorReason													//Status de erro da trasação	
			   		   	
	Method New()

EndClass


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe LJCRetornoPayHub.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@return Self, Objeto, Objeto de representação da classe LJCRetornoPayHub.
/*/
//-------------------------------------------------------------------------------------
Method New() Class LJCRetornoPayHub
	
	Self:lTransOK					:= .F.
	Self:nCodTrans					:= 0
	Self:cInstit					:= ""
	Self:cTpCartao					:= ""
	Self:cAdmFin					:= ""
	Self:lJurosLoja					:= .F.
	Self:cViaCliente				:= ""
	Self:cViaCaixa					:= ""
	Self:aViaCliente				:= {}
	Self:aViaCaixa 					:= {}
	Self:cNsuPayHub					:= ""
	Self:cNsuAuto					:= ""
	Self:cCodAuto					:= ""
	Self:dData						:= CtoD("  /  /  ")
	Self:cHora						:= "00:00"
	Self:nParcelas					:= 0
	Self:nValorPgto					:= 0
	Self:nValorCanc					:= 0    
	Self:dDataCanRei				:= CtoD("  /  /  ")	
	Self:cCartao					:= ""
	Self:cDocCanRei					:= ""
   	Self:cCPFCGC					:= ""
   	Self:cRede						:= ""  
   	Self:aAdmin						:= {}
	Self:cIdtransaction				:= ""
	Self:cProcessorTransactionId 	:= ""
	Self:cExternalTransactionId 	:= ""
	Self:cErrorReason				:= ""
			
Return Self