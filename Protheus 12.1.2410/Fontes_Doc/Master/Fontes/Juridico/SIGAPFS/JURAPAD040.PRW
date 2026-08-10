#INCLUDE "JURAPAD040.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD040
Relatorio Smart View Pagadores X Contratos/Junções

@param lAutomato, Se verdadeiro indica execução via automação
@param cNameAuto, Nome do arquivo do relatório via a ser gerado através da automação

@Return lRet    , Indica se o relatório foi emitido com sucesso

@author João Pedro dos Santos Neto
@since 22/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD040(lAutomato, cNameAuto, lSVAutomato)
Local lRet        := .F.
Local aArea       := GetArea()
Local lPDUserAc   := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
Local lJURRPAD040 := ExistBlock('JURRPAD040')

Default lAutomato   := .F.
Default cNameAuto   := ""
Default lSVAutomato := .F.
	
	If lPDUserAc
		If !lJURRPAD040 .And. Alltrim(__FWLibVersion()) >= "20231009" .And. totvs.framework.smartview.util.isConfig(); 
			.And. FindFunction("JurTRepCall") .And. (!lAutomato .Or. lSVAutomato) // Proteção Smart View 12.1.2310
			JurTRepCall("juridico.sv.sigapfs.jurapad040_pagadores_x_contratos.default.dg" , "data-grid",,, lSVAutomato)
		Else
			MsgInfo(STR0003, STR0004) // "Smart View não configurado", "Acesso negado"
		EndIf
	Else
		MsgInfo(STR0001, STR0002) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return lRet
