#INCLUDE "TOTVS.CH"
#INCLUDE "AGDI120.CH"

/*/{Protheus.doc} AGDI120
Função chamada após a criação do aRotina no MenuDef da rotina MATA920
@type function
@version 12
@author jc.maldonado
@since 15/04/2026
@return array, Lista de opções do menu
/*/
Function AGDI120()
	Local aMenu := {}

	//Adiciona a rotina AGDA070NFM ao menu do MATA920 se o parametro MV_CADPROD possuir o código "AGRO"
	If "AGRO" $ SUPERGETMV("MV_CADPROD", .F., "")
		AAdd(aMenu, {STR0001, "AGDA070NFM", 0, 4, 0, .F.}) //"Dados Guia/Receituário"
	EndIf
Return aMenu
