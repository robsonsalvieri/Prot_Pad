
#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} AGDH010
Chamada para tela em HTML do Cockpit Barter
@type function
@version 12
@author jean.schulze
@since 13/05/2025
@return variant, nil
/*/
Function AGDH010()
	FwCallApp('AGDBARTER')
Return Nil

/*/{Protheus.doc} JsToAdvpl
Execução de telas Protheus através do APP do Cockpit Barter
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
	Local aPartes := {}

	Do Case
		// Abrir a tela de consulta de pedido de venda
	Case cType == 'AGD20CONSPV'
		aPartes := StrTokArr2(cContent, "|", .T.)
		DBSelectArea("NEC")
		if DBSeek(Padr(aPartes[1], TamSX3("NEC_FILIAL")[1])+Padr(aPartes[2], TamSX3("NEC_CODIGO")[1]))
			AGD20CONSPV()
		endif
		//Abrir a tela de relatório de fechamento finaceiro
	Case cType == 'AGDR060'
		aPartes := StrTokArr2(cContent, "|", .T.)
		DBSelectArea("NEJ")
		if DBSeek(Padr(aPartes[1], TamSX3("NEJ_FILIAL")[1])+Padr(aPartes[2], TamSX3("NEJ_CODIGO")[1]))
			AGDR060(.F.)
		endif

		//Abrir a tela de histórico de versionamento
	Case cType == 'AGDC010'
		aPartes := StrTokArr2(cContent, "|", .T.)
		DBSelectArea("NEA")
		if DBSeek(Padr(aPartes[1], TamSX3("NEA_FILIAL")[1])+Padr(aPartes[2], TamSX3("NEA_CODIGO")[1]))
			AGDC010()
		endif

		//Negociacao - Parametros Impressão
	Case cType == 'AGDR010PAR'
		AGDR010PAR(.T. /*lShowDlg*/)

		//Negociacao - Variáveis Impressão
	Case cType == 'AGDR010VAR'
		AGDR010VAR()

		//Negociacao - Impressao
	Case cType == 'AGDR010'
		aPartes := StrTokArr2(cContent, "|", .T.)

		DBSelectArea("NEA")
		NEA->(DbSetOrder(1))
		if NEA->(DBSeek(AvKey(aPartes[1], "NEA_FILIAL") + AvKey(aPartes[2], "NEA_CODIGO")))
			AGDR010(.F.)
		endif
	End
Return .T.
