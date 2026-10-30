
#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} AGDH030
Chamada para tela em HTML do Receituário Agronômico
@type function
@version 12
@author jean.schulze
@since 12/09/2025
@return variant, nil
/*/
Function AGDH030()
	FwCallApp('AGDRECEITUARIO')
Return Nil

/*/{Protheus.doc} JsToAdvpl
Execução de telas Protheus através do APP do TCO
@type function
@version 12
@author jean.schulze
@since 16/06/2025
@param oWebChannel, object, canal de comunicação com o app angular
@param cType, character, funcao a ser executada
@param cContent, character, parametros enviados do app angular
@return variant, true
/*/
Static Function JsToAdvpl(oWebChannel,cType,cContent)
	
	Do Case
		// Abrir a tela de consulta de pedido de venda
	Case cType == 'VIEW_PEDIDO'
		Private aRotina := { { "", "", 0, 1 }, { "", "", 0, 1 } }
		
		DBSelectArea("SC5")
		SC5->(dBSetOrder(1))	//C5_FILIAL+C5_NUM
		if DBSeek(xFilial("SC5")+Padr(cContent, TamSX3("C5_NUM")[1]))
		
			A410Visual("SC5",SC5->(RecNo()), 2)
		endif	


	Case cType == 'FATURAR_PEDIDO'

		DBSelectArea("SC5")
		SC5->(dBSetOrder(1))	//C5_FILIAL+C5_NUM
		if DBSeek(xFilial("SC5")+Padr(cContent, TamSX3("C5_NUM")[1]))
			SC5->( Ma410PvNfs(Alias(), Recno()) )
		endif	

	Case cType == 'DADOS_AGRONEGOCIO'

		DBSelectArea("SC5")
		SC5->(dBSetOrder(1))	//C5_FILIAL+C5_NUM
		if DBSeek(xFilial("SC5")+Padr(cContent, TamSX3("C5_NUM")[1]))
			AGDI071({SC5->C5_FILIAL, SC5->C5_NUM })
		endif	

	End
Return .T.
