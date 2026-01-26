#INCLUDE "JURAPAD041.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD041
Relatorio Smart View Faturas Canceladas/ Emitidas

@param lAutomato, Se verdadeiro indica execução via automação
@param cNameAuto, Nome do arquivo do relatório via a ser gerado através da automação
@param lSVAutomato, Indica se é automação do relatório em Smart View (deve mandar .T. no lAutomato também)

@Return lRet    , Indica se o relatório foi emitido com sucesso

@author João Pedro dos Santos Neto
@since 02/02/24

/*/
//-------------------------------------------------------------------
Function JURAPAD041(lAutomato, cNameAuto, lSVAutomato)
Local aArea       := GetArea()
Local lPDUserAc   := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
Local cNome       := "Faturas Canceladas/Emitidas"
Local lReport     := .T.
Local lDataGrid   := .T.
Local lPivotTable := .F.
Local nType       := 0

Default lAutomato   := .F.
Default cNameAuto   := ""
Default lSVAutomato := .F.
	
	If lPDUserAc
		If Alltrim(__FWLibVersion()) >= "20231009" .And. totvs.framework.smartview.util.isConfig(); 
			.And. FindFunction("JurTRepCall") .And. (!lAutomato .Or. lSVAutomato) // Proteção Smart View 12.1.2310
			
			nType := JurTRepBox(lReport, lDataGrid, lPivotTable, cNome)
			Do Case
				Case (nType == 1)
					JurTRepCall("juridico.sv.sigapfs.jurapad041_faturas_canceladas_emitidas.default.rep" , "report",,, lSVAutomato)
				Case (nType == 2)
					JurTRepCall("juridico.sv.sigapfs.jurapad041_faturas_canceladas_emitidas.default.dg" , "data-grid",,, lSVAutomato)
			EndCase
		Else
			MsgInfo(STR0003, STR0004) // "Smart View não configurado", "Acesso negado"
		EndIf
	Else
		MsgInfo(STR0001, STR0002) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return 
