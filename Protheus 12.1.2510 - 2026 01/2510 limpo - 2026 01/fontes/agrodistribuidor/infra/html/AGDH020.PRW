
#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} AGDH020
Chamada para tela em HTML do TCO - Total Cost Ownership
@type function
@version 12
@author jean.schulze
@since 12/09/2025
@return variant, nil
/*/
Function AGDH020()
	FwCallApp('AGDTCO')
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
	Case cType == 'openCadastro'
		if isProgramTCO(cContent)
			SetFunName(cContent)
			&(cContent+"()")
			SetFunName("AGDH020")
		endif		
	End
Return .T.

/*/{Protheus.doc} isProgramTCO
Verifica se o programa está listado como cadastro generico
@type function
@version 12
@author jean.schulze
@since 21/10/2025
@param cProgram, character, nome do programa
@return variant, valido/invalido
/*/
Static Function isProgramTCO(cProgram)
	Local aLista := {}
	Local nX     as Numeric

	oTCOrepository := agd.tcoRepository.agdTCORepository():New()
	listaFeatures := oTCOrepository:findFeaturesDisponiveis()
	FWFreeObj(oTCOrepository)

	For nX:= 1 to Len(listaFeatures)
		oFeature := &(listaFeatures[nX, 2]+":new()")
		aLista := oFeature:getCadastrosBasicos() 
		FWFreeObj(oFeature)
		
		if aScan(aLista, {|x| x['rotina'] == cProgram }) > 0
			return .t.
		endif		
	Next


return .F.


