#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEFIX22

Programa de acerto para corrigir a situação do documento de frete

@author  Squad GFE
@since   10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEFIX22()
	Local oDlg      := Nil
	Local oCancel   := Nil
	Local oConfirm  := Nil
	Local dDtEmiIni := Ctod(Space(8))
	Local dDtEmiFim := Ctod(Space(8))
	
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 150, 350 TITLE 'Correção da situação do documento de frete' PIXEL
	lCheck := .F.

	@ 10, 20  SAY 'Data Emissão Inicial Doc Frete:' OF oDlg PIXEL		
	@ 08, 100  MSGET dDtEmiIni When .T. Picture "@!" PIXEL OF oDlg PICTURE '@!' PIXEL
	@ 30, 20  SAY 'Data Emissão Final Doc Frete:' OF oDlg PIXEL
	@ 30, 100  MSGET dDtEmiFim When .T. Picture "@!" PIXEL OF oDlg PICTURE '@!' PIXEL		
	
	@ 60, 20 BUTTON oConfirm PROMPT "Processar" SIZE 040,012 OF oDlg PIXEL ACTION (Processa(dDtEmiIni,dDtEmiFim),oDlg:End())
	@ 60, 65 BUTTON oCancel  PROMPT "Cancelar"  SIZE 040,012 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

Static Function Processa(dDtEmiIni,dDtEmiFim)
	Local cAliasGW3 := ""

    cAliasGW3 := GetNextAlias()

    BeginSQL Alias cAliasGW3
        SELECT GW3.R_E_C_N_O_ RECNOGW3
        FROM %Table:GW3% GW3
		WHERE GW3.GW3_DTEMIS >= %Exp:DToS(dDtEmiIni)%
        AND GW3.GW3_DTEMIS <= %Exp:DToS(dDtEmiFim)%
        AND GW3.GW3_SIT = '2'
        AND GW3.GW3_SITMLA = '4'
		AND GW3.%NotDel%
    EndSQL

    Do While (cAliasGW3)->(!EoF())
		GW3->(dbGoTo((cAliasGW3)->RECNOGW3))
		
        RecLock("GW3",.F.)
			GW3->GW3_SIT    := "4"
			GW3->GW3_MOTAPR := "Correção programa de acerto - GFEFIX22"
			GW3->GW3_USUAPR := "GFEFIX22"
			GW3->GW3_DTAPR  := Date()
            GW3->GW3_HRAPR  := Time()
		GW3->(MsUnlock())

		(cAliasGW3)->(dbSkip())
	EndDo		
	
    (cAliasGW3)->(dbCloseArea())

	MsgInfo("Processamento encerrado.")
Return