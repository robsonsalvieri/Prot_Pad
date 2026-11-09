#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC350.CH"

/*/{Protheus.doc} VEIC350()
Browse para chamar a Consulta para visualizar os Cotitulares relacionados ao Atendimento - SOMENTE ARGENTINA que possui COTITULARES

@author Andre Luis Almeida
@since 06/08/2026
@version 1.0
@return NIL
/*/
Function VEIC350()
Local cFiltro := ""
If cPaisLoc == "ARG" .and. FWAliasInDic("VW1")
	////////////////////////////////////////////////////////////////////////
	// Filtro do Browse - visualizar somente Atenidmentos com Cotitulares //
	////////////////////////////////////////////////////////////////////////
	cFiltro := "EXISTS ( SELECT VW1.VW1_NUMTRA FROM "+RetSQLName("VW1")+" VW1 WHERE VW1.VW1_FILIAL=VV9_FILIAL AND VW1.VW1_NUMTRA=VV9_NUMATE AND VW1.D_E_L_E_T_=' ' ) " // Possui Cotitulares
	oBrwVV9 := FWMBrowse():New()
	oBrwVV9:SetAlias("VV9")
	oBrwVV9:SetDescription(STR0001) // Cotitulares do Atendimento
	oBrwVV9:SetMenuDef( 'VEIC350' )
	oBrwVV9:SetFilterDefault("@ "+cFiltro)
	oBrwVV9:DisableDetails()
	oBrwVV9:DisableLocate()
	oBrwVV9:SetAmbiente(.F.)
	oBrwVV9:SetWalkthru(.F.)
	oBrwVV9:SetUseFilter()
	oBrwVV9:ForceQuitButton()
	oBrwVV9:Activate()
EndIf
Return

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 06/08/2026
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VC3500011_Visualizar' OPERATION 2 ACCESS 0 // Visualizar
Return aRotina

/*/{Protheus.doc} VC3500011_Visualizar
Visualizar Cotitulares do Atendimento de Veiculos

@author Andre Luis Almeida
@since 06/08/2026
@version 1.0
/*/
Function VC3500011_Visualizar()
	VEIA350(2,VV9->VV9_NUMATE,VV9->VV9_FILIAL)
Return