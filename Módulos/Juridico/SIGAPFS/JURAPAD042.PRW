#INCLUDE "JURAPAD042.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD042
Relatorio Smart View Parcelas Fixas

@param lAutomato, Se verdadeiro indica execução via automação
@param cNameAuto, Nome do arquivo do relatório via a ser gerado através da automação
@param lSVAutomato, Indica se é automação do relatório em Smart View (deve mandar .T. no lAutomato também)

@Return lRet    , Indica se o relatório foi emitido com sucesso

@author João Pedro dos Santos Neto
@since 24/09/24

/*/
//-------------------------------------------------------------------
Function JURAPAD042(lAutomato, cNameAuto, lSVAutomato)
Local aArea       := GetArea()
Local lPDUserAc   := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
Local cNome       := "Parcelas Fixas"
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  )
Local lReport     := .T.
Local lDataGrid   := .T.
Local lPivotTable := .F.
Local nType       := 0
Local jParams as json

Default lAutomato   := .F.
Default cNameAuto   := ""
Default lSVAutomato := .F.
	
	If lPDUserAc
		If Alltrim(__FWLibVersion()) >= "20231009" .And. totvs.framework.smartview.util.isConfig(); 
			.And. FindFunction("JurTRepCall") .And. (!lAutomato .Or. lSVAutomato) // Proteção Smart View 12.1.2310
			
			nType := JurTRepBox(lReport, lDataGrid, lPivotTable, cNome)

			Do Case
				Case (nType == 1)
					If cLojaAuto == "2"
						JurTRepCall("juridico.sv.sigapfs.jurapad042_parcelas_fixas.default.rep" , "report",,, lSVAutomato,.F.,,,,,, jParams)
					Else
						JurTRepCall("juridico.sv.sigapfs.jurapad042_parcelas_fixas.lojaauto.rep" , "report",,, lSVAutomato,.F.,,,,,, jParams)
					EndIf
				Case (nType == 2)
						JurTRepCall("juridico.sv.sigapfs.jurapad042_parcelas_fixas.default.dg", "data-grid",,, lSVAutomato,.F.,,,,,, jParams)
			EndCase
		Else
			MsgInfo(STR0003, STR0004) // "Smart View não configurado", "Acesso negado"
		EndIf
	Else
		MsgInfo(STR0001, STR0002) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return 
