#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV025
Função utilizada para execução do objeto de negócio Gestão de Devolução
@type  Função
@author Leonardo Pacheco Fuga
@since  02/12/2025
/*/
//-------------------------------------------------------------------
Function LOCSV025(cRomaneio)
    
Local oRomaneio as object
Local lRet as Logical

	lRet := .F.

	If !findClass("totvs.protheus.rental.manutencao.integratedprovider.gestaodevolucao") .or. file("\SYSTEM\LOCSV013.TXT") //Comentario adicionado para passagem do DSERLOCA-10105 20/02/2026
		Return .F.
	EndIf

	oRomaneio := totvs.protheus.rental.manutencao.integratedprovider.gestaodevolucao():new()	
	
	lRet := (oRomaneio:printDevolucao(cRomaneio))
	
	FreeObj(oRomaneio)

Return
