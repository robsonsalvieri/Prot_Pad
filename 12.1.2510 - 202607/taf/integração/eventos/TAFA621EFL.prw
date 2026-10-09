#include 'totvs.ch'
#include 'PROTHEUS.CH'

/*----------------------------------------------------------------------
{Protheus.doc} TAFA621EFL
Responsável por chamar a funcção principal de geração  e envio do xml 
O mesmo teve que ser criado como .prw 
porque nele é usada a função Scheddef() e a mesma, até 
então não estava funcionado em fontes .tlpp

@author Pâmela Bernardo
@since 05/02/2026
//----------------------------------------------------------------------*/
Function TAFA621EFL()
	Local oXml := totvs.protheus.fiscal.taf.event.Processingqueue():New()
	oXml:TafProcessingqueue()
Return

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Pâmela Bernardo
@since 05/02/2026
--------------------------------------------------------------------------------*/
Static Function Scheddef()
	Local aParam := {}

	aParam := {'P', 'PARAMDEF', '', {}, ''}

Return aParam

