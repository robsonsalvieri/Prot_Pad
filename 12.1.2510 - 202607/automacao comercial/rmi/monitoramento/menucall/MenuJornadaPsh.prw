#Include 'Protheus.ch'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TBICONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc}
FwCallApp faz a execução das classe em Angular no Protheus.
@version 1.0
/*/
//-------------------------------------------------------------------
Function JornadaPsh()
    FwCallApp("protheus-smart-hub-tools")
return

//-------------------------------------------------------------------
/*/{Protheus.doc}
JsToAdvpl faz a execução das chamadas do POUI em Angular no Protheus.
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	Do CASE
		Case cType == "CadastroAssinante"
			RmiCadAssi()
		Case cType == "CadastroProcesso"
            RmiCadProc()
		Case cType == "RmiDePara"
			RmiDePara()
		Case cType == "LjCadAux"
			LjCadAux("",.T.)
		Case cType == "pshWizCfg"
			pshWizCfg()
		Case cType == "MonitorIntegracao"
			pshStaInte()
	ENDCASE

Return .T.
