#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//===============================================================================================\\
/*/{Protheus.doc} GFEFIX35
  ================================================================================================
	@description   	Programa de acerto para corrigir os cadastros anteriores à implementação do
                    novo campo, alimentando o campo GU3_APISSO com o valor padrão.
	@author         Philippe Rocca Bretas
	@version    	1.0
	@since          08/12/2023
/*/
//================================================================================================\\
Function GFEFIX35()
    Local oDlg      := Nil
	Local oConfirm  := Nil
    Local oCancel   := Nil
	
	
	DEFINE MSDIALOG oDlg FROM 0, 0 TO 150, 500 TITLE 'Correção do campo de Apuração ISS de outro município' PIXEL
	
	@ 60, 20 BUTTON oConfirm PROMPT "Processar" SIZE 040,012 OF oDlg PIXEL ACTION (Processa(),oDlg:End())
	@ 60, 65 BUTTON oCancel  PROMPT "Cancelar"  SIZE 040,012 OF oDlg PIXEL ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function Processa()
    Local cAliasGU3  := GetNextAlias()
    Local cApIssOMun := "1"
    Private oProcessC   := Nil
    Private lSaveLogC   := .F.

    BeginSQL Alias cAliasGU3
        SELECT GU3.R_E_C_N_O_ RECNOGU3
        FROM %Table:GU3% GU3
        WHERE GU3.GU3_APISSO = ''
        AND GU3.GU3_FILIAL = %xFilial:GU3%
        AND GU3.%NotDel%
    EndSQL

    While ((cAliasGU3)->(!Eof()))
        GU3->(dbGoTo((cAliasGU3)->RECNOGU3))
        RecLock("GU3", .F.)
            GU3->GU3_APISSO := cApIssOMun    
        MsUnlock()
        (cAliasGU3)->(dbSkip())
    EndDo
    (cAliasGU3)->(dbCloseArea())
    MsgInfo("","Acerto Finalizado!")
Return
