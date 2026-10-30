#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

Static __cSessionID := ""
Static __cMetricName := ""

/*/{Protheus.doc} DemandAlert
Função chamada pela rotina MATA110 da Central IA (PINSA030)
	
@param cAlias, caracter, Alias do arquivo                                   
@param nReg, number, Numero do registro       
@param nOpc, number, Numero da opcao selecionada 			    
@param lADVPR, logical, se executado via automação

@return lReturn, logical, executado com sucesso

@author BA
@since  10/08/2026
/*/
Function DemandAlert( cAlias, nReg, nOpc, lADVPR )
	Local lHasValidate	:= FindFunction( "totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights", .T. )

	Default lADVPR := .F.

	IF lHasValidate .And. totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights( 0 ) 	//Valida requisitos
		__cMetricName := "INSIGHT_ACCESS_MATA110"
		__cSessionID := FWUUIDV1( .T. )
		SendMetricFin ({__cMetricName,__cSessionID})

		If !lADVPR
			PINSA030()	// Central IA
		EndIf
	EndIf

Return .T.
