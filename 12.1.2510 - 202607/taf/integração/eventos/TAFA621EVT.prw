#include 'totvs.ch'
#include 'PROTHEUS.CH'

/*----------------------------------------------------------------------
{Protheus.doc} TAF621FIN
Responsável por chamar a funcção principal de geração  e envio do xml 
O mesmo teve que ser criado como .prw 
porque nele Ã© usada a funÃ§Ã£o Scheddef() e a mesma, atÃ© 
entÃ£o nÃ£o estava funcionado em fontes .tlpp

@author Evandro Italo
@since 29/10/2025
//----------------------------------------------------------------------*/
Function TAFA621EVT()
	Local oXml := totvs.protheus.fiscal.taf.event.TAFXmlMonitorEvent():New()
	oXml:TAFGetXmlMonitorEvent()
Return

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro Italo
@since 29/10/2025
--------------------------------------------------------------------------------*/
Static Function Scheddef()
	Local aParam := {}

	aParam := {'P', 'PARAMDEF', '', {}, ''}

Return aParam

