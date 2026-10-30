#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 


User Function FIXUPDCID()

    cAliGU7 := GetNextAlias()
	BeginSQL Alias cAliGU7
		SELECT GU7.R_E_C_N_O_ RECNOGU7
		FROM %Table:GU7% GU7
		WHERE GU7.GU7_FILIAL = %xFilial:GU7%
		AND GU7.%NotDel%
	EndSQL
    
    While (cAliGU7)->(!EoF())
    GU7->(DBGOTO((cAliGU7)->RECNOGU7))
   
    RecLock("GU7",.F.)      
        GU7->GU7_NMCID := FwNoAccent(GU7->GU7_NMCID) // Remove caracteres especiais 
    MsUnlock("GU7")
   
    (cAliGU7)->(dbSkip())
    EndDo
    
    //Mensagem de Conclusão da atualização. 
	MsgInfo("Execução Finalizada com Sucesso!")
Return .T.
