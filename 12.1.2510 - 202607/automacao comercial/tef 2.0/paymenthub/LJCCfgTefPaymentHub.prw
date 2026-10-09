#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"

Function LJCCfgTefPaymentHub ; Return        

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LJCCfgTefPaymentHub
Carrega as configuracoes do Payment Hub disponiveis para a aplicação.

@type       Class
@author     Alberto Deviciente
@since      13/07/2020
@version    12.1.27
/*/
//-------------------------------------------------------------------------------------
Class LJCCfgTefPaymentHub

	Data cCodeComp 		//Codigo da Companhia
	Data cTenant 		//Tenant
	Data cUserName 		//Usuário com o perfil ROAcessorUser
	Data cPassword 		//Senha do usuário com o perfil ROAcessorUser
	Data cEnvironment	//Ambiente
	Data cClientId 		//Client ID
	Data cClientSecret 	//Client Secret
	Data cIdPinPed 		//Código de identificação do Terminal TEF
	Data lCCCD			//Habilita Transação para CC e CD
	Data lInfAdm		//Informa a Administradora? 
	Data lPagDig		//Habilita os meios de pagamentos digitais //Bruno Almeida
	
	Method New()
	Method Carregar()
	Method Salvar()
	Method GetEnvironment()

EndClass                

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe LJCCfgTefPaymentHub.

@type       Method
@author     Alberto Deviciente
@since      13/07/2020
@version    12.1.27

@return Self, Objeto, Objeto de representação da classe LJCCfgTefPaymentHub.
/*/
//-------------------------------------------------------------------------------------
Method New() Class LJCCfgTefPaymentHub

	Self:cCodeComp 		:= Space(TamSX3("MDG_PHCOMP")[1])
	Self:cIdPinPed 		:= ""
	Self:cTenant 		:= Space(TamSX3("MDG_PHTENA")[1])
	Self:cUserName 		:= Space(TamSX3("MDG_PHUSER")[1])
	Self:cPassword 		:= Space(TamSX3("MDG_PHPSWD")[1])
	Self:cEnvironment	:= " "
	Self:cClientId 		:= Space(TamSX3("MDG_PHCLID")[1])
	Self:cClientSecret 	:= Space(TamSX3("MDG_PHCLSR")[1])
	Self:lCCCD			:= .F.
	Self:lInfAdm		:= .T.
	Self:lPagDig		:= .F.

Return Self       

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Carregar
Carrega as configuracoes de TEF disponiveis para o Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      13/07/2020
@version    12.1.27

@param cAlias, Caractere, Alias da tabela de configuração do TEF 2.0.

@return lRet, Lógico, Retorna se carregou com sucesso as configurações do Payment Hub.
/*/
//-------------------------------------------------------------------------------------
Method Carregar(cAlias) Class LJCCfgTefPaymentHub

	Local lRet := .F.

	If Select(cAlias) > 0

		Self:cCodeComp 		:= (cAlias)->MDG_PHCOMP
		Self:cTenant 		:= (cAlias)->MDG_PHTENA
		Self:cUserName 		:= (cAlias)->MDG_PHUSER
		Self:cPassword 		:= PadR(Embaralha(AllTrim((cAlias)->MDG_PHPSWD),1), TamSX3("MDG_PHPSWD")[1]) 	//Desembaralha a senha
		Self:cClientId 		:= (cAlias)->MDG_PHCLID
		Self:cClientSecret 	:= (cAlias)->MDG_PHCLSR
		Self:cEnvironment	:= Self:GetEnvironment() 														//1=Homologação;2=Produção
		Self:lPagDig		:= IIf((cAlias)->MDG_PHPAGD=="1",.T.,.F.)
		Self:cIdPinPed 		:= ""
		Self:lCCCD			:= .F.

		lRet := .T.
	EndIf

Return lRet   

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Salvar
Salva as configuracoes de TEF disponiveis para o Payment Hub.

@type       Method
@author     Alberto Deviciente
@since      13/07/2020
@version    12.1.27

@param cAlias, Caractere, Alias da tabela de configuração do TEF 2.0.

@return lRet, Lógico, Retorna se Salvou com sucesso as configurações do Payment Hub.
/*/
//-------------------------------------------------------------------------------------
Method Salvar(cAlias) Class LJCCfgTefPaymentHub
	
	Local lRet := .F.

	If Select(cAlias) > 0
		REPLACE (cAlias)->MDG_PHCOMP WITH Self:cCodeComp
		REPLACE (cAlias)->MDG_PHTENA WITH Self:cTenant
		REPLACE (cAlias)->MDG_PHUSER WITH Self:cUserName
		REPLACE (cAlias)->MDG_PHPSWD WITH Embaralha( AllTrim(Self:cPassword), 0 )	//Embaralha a senha
		REPLACE (cAlias)->MDG_PHCLID WITH Self:cClientId
		REPLACE (cAlias)->MDG_PHCLSR WITH Self:cClientSecret
		REPLACE (cAlias)->MDG_PHPAGD WITH IIf(Self:lPagDig,"1","2")
		
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEnvironment
Retorna o Ambiente a ser utilizado para o Payment Hub (1=Homologação;2=Produção).

@type       Method
@author     Alberto Deviciente
@since      23/11/2020
@version    12.1.27

@return cRet, Caractere, Retorna o Ambiente a ser utilizado (1=Homologação;2=Produção).
/*/
//-------------------------------------------------------------------------------------
Method GetEnvironment() Class LJCCfgTefPaymentHub

	Local cRet := "2" 	//1=Homologação;2=Produção
	
	If AllTrim(Self:cClientId) == "totvs_pagamento_digital_protheus_ro" .And. AllTrim(Self:cClientSecret) == "39f56c0d-1a0d-48e9-94de-eb32f4e8877c"
		cRet := "1"
	EndIf

Return cRet