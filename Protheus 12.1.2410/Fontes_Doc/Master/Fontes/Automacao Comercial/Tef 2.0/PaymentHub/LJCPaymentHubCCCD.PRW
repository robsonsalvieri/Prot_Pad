#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"

Function LJCPaymentHubCCCD ; Return                     

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJCPaymentHubCCCD
Interface para transacao com cartao de credito e cartao de debito utilizando Payment Hub.

@type       Class
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJCPaymentHubCCCD From LJACCCD

	Data oTransPaymentHub					//Objeto do tipo LJCTransPaymentHub
	
	Method New()
	Method Credito()
	Method Debito()
	Method FuncoesAdm()
	Method Confirmar()
	Method Desfazer()
      
EndClass       

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LJCCfgTefPaymentHub.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@return Self, Objeto, Objeto de representação da classe LJCPaymentHubCCCD.
/*/
//-------------------------------------------------------------------------------------
Method New(oComPaymentHub) Class LJCPaymentHubCCCD 

   	_Super:New()
   	
   	Self:oTransPaymentHub := LJCTransPaymentHub():New(oComPaymentHub)  

Return Self      

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Credito
Transação com Cartão de Crédito.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oDadosTran, Objeto, Objeto representando os dados da transação.

@return oDadosTran, Objeto, Objeto representando os dados da transação.
/*/
//-------------------------------------------------------------------------------------
Method Credito(oDadosTran) Class LJCPaymentHubCCCD
    
	Self:oTransPaymentHub:oPaymentHub:SetTrans(oDadosTran)
	
	//Envia transacao de pagamento
	Self:oTransPaymentHub:oPaymentHub:TransCCCD()
       
	//Trata retorno
	oDadosTran := Self:oTransPaymentHub:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz, oDadosTran, .T.)
	
Return oDadosTran

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Debito
Transação com Cartão de Débito.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@param oDadosTran, Objeto, Objeto representando os dados da transação.

@return oDadosTran, Objeto, Objeto representando os dados da transação.
/*/
//-------------------------------------------------------------------------------------
Method Debito(oDadosTran) Class LJCPaymentHubCCCD  
	
	Self:oTransPaymentHub:oPaymentHub:SetTrans(oDadosTran)
	
	//Envia transacao de pagamento
	Self:oTransPaymentHub:oPaymentHub:TransCCCD()
       
	//Trata retorno
	oDadosTran := Self:oTransPaymentHub:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz, oDadosTran, .T.)
	
Return oDadosTran

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FuncoesAdm
Realiza as funcoes Administrativas.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@param oDadosTran, Objeto, Objeto representando os dados da transação.
@param aTransCanc, Array, Array com as informações da transação de deve ser cancelada.

@return oDadosTran, Objeto, Objeto representando os dados da transação.
/*/
//-------------------------------------------------------------------------------------
Method FuncoesAdm(oDadosTran,aTransCanc) Class LJCPaymentHubCCCD 
	
	Default aTransCanc := {}

	Self:oTransPaymentHub:oPaymentHub:SetTrans(oDadosTran)

	//Executa opções Administrativas do TEF
	Self:oTransPaymentHub:oPaymentHub:Gerenciais(oDadosTran,aTransCanc)

    //Trata retorno
	oDadosTran := Self:oTransPaymentHub:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)

Return oDadosTran

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Confirmar
Confirmar a operacao de Venda.

@type       Method
@author     Alberto Deviciente
@since      16/07/2020
@version    12.1.27

@return Nulo, Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method Confirmar() Class LJCPaymentHubCCCD 
	
	//Confirma a transacao
   	Self:oTransPaymentHub:Confirmar(Self:oTrans)    

	//Inicializa a colecao de transacoes
	Self:InicTrans()

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Desfazer
Desfaz a transação do cartão.

@type       Method
@author     Alberto Deviciente
@since      14/07/2020
@version    12.1.27

@return Nulo, Nil, Nulo
/*/
//-------------------------------------------------------------------------------------
Method Desfazer() Class LJCPaymentHubCCCD 
   	
	//Desfaz a transacao
   	Self:oTransPaymentHub:Desfazer(Self:oTrans)
   	
	//Inicializa a colecao de transacoes
	Self:InicTrans()
   	
Return Nil