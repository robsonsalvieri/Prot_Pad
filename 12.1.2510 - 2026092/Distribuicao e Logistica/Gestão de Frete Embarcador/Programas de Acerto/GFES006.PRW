#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "GFEXFUNB.ch"
#INCLUDE "FWMVCDEF.CH"

//====================================================================================================================//
/*{Protheus.doc} GFES006
  ===================================================================================================
	@description   	Programa especial para criar os cadastros genéricos Cliente, Fornecedor e Produto para uso no GFE.
	@author         Matheus de Souza
	@version    	1.0
	@since          15/12/2025
*/
//===================================================================================================================//
User Function GFES006()
    Local cTitle  := "Geração dos cadastros genéricos"
    Local cMsg    := "Execução finalizada!"
    Local cMsg1   := "A criação dos registros genéricos do GFE é realizada somente quando a integração com o ERP Datasul ou ERP Logix estiver ativa. Verifique o parâmetro MV_ERPGFE."
    Local cErpCfg := SuperGetMv("MV_ERPGFE",.F.,"2")

	If cErpCfg == "1" .Or. cErpCfg == "4" //Gera cadastro para integração ativa com ERP Datasul ou ERP Logix
        GFEFBMCLI("CLIGFE") // Criando cadastros de clientes
        GFEFBMFOR("FORGFE") // Criando cadastros de fornecedor
        GFEFBMPROD("PRODGFE01") // Criando produto genérico GFE
        MsgInfo(cMsg, cTitle)
    Else
        MsgStop(cMsg1,cTitle)
    EndIf 
Return
