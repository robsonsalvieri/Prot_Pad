#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LJPayHubDi ; Return  

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJCPaymentHubDigitais
Interface para transacao com pgto digitais utilizando Payment Hub.

@type       Class
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJCPaymentHubDigitais From LJAPgtoDigital

	Data oTransPaymentHub					//Objeto do tipo LJCTransPaymentHub
	
	Method New()
	Method Digitais()
	Method FuncoesAdm()
	Method Confirmar()
	Method Desfazer()
      
EndClass       

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LJCPaymentHubDigitais.

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
@return     Self, Objeto de representação da classe LJCPaymentHubDigitais.
/*/
//-------------------------------------------------------------------------------------
Method New(oComPaymentHub) Class LJCPaymentHubDigitais 

   	_Super:New()
   	
   	Self:oTransPaymentHub := LJCTransPaymentHub():New(oComPaymentHub)  

Return Self      

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Digitais
Transação com meio de pgto digital

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
@param      oDadosTran, Objeto representando os dados da transação.

@return     oDadosTran, Objeto representando os dados da transação.
/*/
//-------------------------------------------------------------------------------------
Method Digitais(oDadosTran) Class LJCPaymentHubDigitais
    
	Self:oTransPaymentHub:oPaymentHub:SetTrans(oDadosTran)
	
	//Envia transacao de pagamento
	Self:oTransPaymentHub:oPaymentHub:TransPd()
       
	//Trata retorno
	oDadosTran := Self:oTransPaymentHub:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz, oDadosTran, .T.)
	
Return oDadosTran

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FuncoesAdm
Realiza as funcoes Administrativas.

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27
@param      oDadosTran, Objeto representando os dados da transação.
@param      aTransCanc, Array com as informações da transação de deve ser cancelada.

@return     oDadosTran, Objeto representando os dados da transação.
/*/
//-------------------------------------------------------------------------------------
Method FuncoesAdm(oDadosTran,aTransCanc) Class LJCPaymentHubDigitais 
	
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
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27

@return     Nil
/*/
//-------------------------------------------------------------------------------------
Method Confirmar() Class LJCPaymentHubDigitais 
	
	//Confirma a transacao
   	Self:oTransPaymentHub:Confirmar(Self:oTrans)    

	//Inicializa a colecao de transacoes
	Self:InicTrans()

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Desfazer
Desfaz a transação do cartão.

@type       Method
@author     Bruno Almeida
@since      26/10/2020
@version    12.1.27

@return     Nil
/*/
//-------------------------------------------------------------------------------------
Method Desfazer() Class LJCPaymentHubDigitais 

	LjGrvLog("Totvs Pagamentos Digitais","Metodo Desfazer - Inicio",,.T.,.T.)
   	
	//Desfaz a transacao
   	Self:oTransPaymentHub:Desfazer(Self:oTrans)
   	
	//Inicializa a colecao de transacoes
	Self:InicTrans()
   	
Return Nil
