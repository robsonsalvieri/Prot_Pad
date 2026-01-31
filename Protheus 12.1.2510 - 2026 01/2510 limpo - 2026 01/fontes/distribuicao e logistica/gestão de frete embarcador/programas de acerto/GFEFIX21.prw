#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEFIX21

Programa de acerto para ajustar a transportadora do cálculo de frete
nos ratéios contábeis de frete de mesmo número de cálculo com transportadoras 
diferentes

@author  Squad GFE
@since   21/05/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEFIX21()
	Local oDlg      := Nil
	Local oCancel   := Nil
	Local oConfirm  := Nil
	Local dDtEmiIni := Ctod(Space(8))
	Local dDtEmiFim := Ctod(Space(8))
	
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 150, 350 TITLE 'Correção do transportador nos cálculos do Romaneio' PIXEL
	lCheck := .F.

	@ 10, 20  SAY 'Data Inicial Romaneio:' OF oDlg PIXEL		
	@ 08, 73  MSGET dDtEmiIni When .T. Picture "@!" PIXEL OF oDlg PICTURE '@!' PIXEL
	@ 30, 20  SAY 'Data Final Romaneio:' OF oDlg PIXEL
	@ 30, 73  MSGET dDtEmiFim When .T. Picture "@!" PIXEL OF oDlg PICTURE '@!' PIXEL		
	@ 49,21 CHECKBOX oChkBox VAR lCheck PROMPT "Ajusta transportadora" SIZE 60,15 OF oDlg PIXEL
	
	@ 60, 20 BUTTON oConfirm PROMPT "Processar" SIZE 040,012 OF oDlg PIXEL ACTION (Processa(dDtEmiIni,dDtEmiFim),oDlg:End())
	@ 60, 65 BUTTON oCancel  PROMPT "Cancelar"  SIZE 040,012 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

Static Function Processa(dDtEmiIni,dDtEmiFim)
	Local cQuery    := ""

	cQuery := " UPDATE "+RetSqlName("GWM")
	cQuery += " SET GWM_CDTRP = GWF.GWF_TRANSP"
	cQuery += " FROM "+RetSqlName("GWM")+" GWM"
	cQuery += " INNER JOIN "+RetSqlName("GWF")+ " GWF"
	cQuery += " ON GWF.GWF_FILIAL = GWM.GWM_FILIAL"
	cQuery += " AND GWF.GWF_NRCALC = GWM.GWM_NRDOC"
	cQuery += " AND GWF.GWF_TRANSP <> GWM.GWM_CDTRP"
	cQuery += " AND GWF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GWM.GWM_TPDOC = '1'"
	cQuery += " AND GWM.GWM_DTEMIS >= '"+DToS(dDtEmiIni)+"'"
	cQuery += " AND GWM.GWM_DTEMIS <= '"+DToS(dDtEmiFim)+"'"
	cQuery += " AND GWM.D_E_L_E_T_ = ' '"
	TcSqlExec(cQuery)
	MsgInfo("Processamento encerrado.")
Return