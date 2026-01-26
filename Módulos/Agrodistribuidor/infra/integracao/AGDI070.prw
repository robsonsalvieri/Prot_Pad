#INCLUDE "TOTVS.CH"
#INCLUDE "AGDI070.CH"

/*/{Protheus.doc} AGDI070
Função chamada após a criação do aRotina no MenuDef da rotina MATA460A
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@param aRotina, array, aRotina
/*/
Function AGDI070(aRotina)
	aMenu := {}

	//Adiciona a rotina AGDA070TSS ao menu do MATA460A se o parametro MV_CADPROD possuir o código AGRO
	If "AGRO" $ SUPERGETMV("MV_CADPROD", .F., "")
		AAdd(aMenu, {STR0001, "AGDA070TSS", 0, 4, 0, .F.}) //"Dados Guia/Receituário"
	EndIf
Return aMenu
