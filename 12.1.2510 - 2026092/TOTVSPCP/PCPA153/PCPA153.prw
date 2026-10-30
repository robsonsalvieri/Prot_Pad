#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA153.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PCPA153
Chamada da tela de diagnostico PCP (PO-UI)

@type  Function
@author douglas.heydt
@since 13/05/2024
@version P12
@return Nil
/*/
Function PCPA153()

	If PCPVldApp()
		If !AMIIn(10,44,4)
			Help( ,  , "P153" + cValToChar(ProcLine()), , STR0118; //"O MRP não pode ser acessado pelo módulo atual."
				, 1, 0, , , , , , {STR0119})                      //"A rotina do MRP só pode ser acessada através dos módulos PCP, Estoque e Gestão de Projetos."
			Return .F.
		EndIf
		FwCallApp("diagnosticopcp")
	EndIf

Return Nil
