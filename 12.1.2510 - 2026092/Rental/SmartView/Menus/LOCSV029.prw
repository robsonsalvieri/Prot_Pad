#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV029
Funcao utilizada para execucao do objeto de negocio Lista de Pendencias de Devolucao
@type  Funcao
@author Leonardo Pacheco Fuga
@since  01/09/2026
@param cProjeto, character, projeto em que o usuario esta posicionado (FQW_PROJET)
@param cObra, character, obra em que o usuario esta posicionado (FQW_OBRA)
@return logical, indica se a impressao foi executada com sucesso
/*/
//-------------------------------------------------------------------
Function LOCSV029(cProjeto, cObra)

Local oPendDev as object
Local lRet as Logical

	lRet := .F.

	If !findClass("totvs.protheus.rental.manutencao.integratedprovider.pendenciasdevolucao") .or. file("\SYSTEM\LOCSV029.TXT")
		Return .F.
	EndIf

	oPendDev := totvs.protheus.rental.manutencao.integratedprovider.pendenciasdevolucao():new()

	lRet := (oPendDev:printPendencias(cProjeto, cObra))

	FreeObj(oPendDev)

Return lRet
