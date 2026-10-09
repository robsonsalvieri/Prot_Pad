#include 'totvs.ch'
#include 'PROTHEUS.CH'
#include "TAFXFIN.CH"

/*----------------------------------------------------------------------
{Protheus.doc} TAF621FIN
Essa programa é responsavel por chamar a função principal de integração
dos dos dados entre os modulos financeiro e TAF. O mesmo teve que ser 
criado como .prw porque nele é usada a função Scheddef() e a mesma, até 
então não estava funcionado em fontes .tlpp

@author Pâmela Bernardo
@since 06/03/2025
//----------------------------------------------------------------------*/
Function TAFA621FIN()
	Local lIntTAF		:= FindFunction('TafUsaISCH') .And. TafUsaISCH()	    as logical

	If lIntTAF
		If TafColumnPos("LEM_IDDOC")
			totvs.protheus.fiscal.taf.financialintegration.TAFfinancialintegration()
		Else
			TAFConout(STR0016) //Dicionário de dados desatualizado. Para utilizar essa funcionalidade, é necessário estar com o dicionário compativel com o repositório de dados.
		Endif
	Endif
Return

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Carlos Eduardo Nonato
@since 21/02/2024
--------------------------------------------------------------------------------*/
Static Function Scheddef()
	Local aParam := {}

	aParam := {'P', 'PARAMDEF', '', {}, '', '', .T., .F.}

Return aParam

