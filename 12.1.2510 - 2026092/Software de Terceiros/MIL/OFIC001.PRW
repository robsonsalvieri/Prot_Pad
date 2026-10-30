#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "OFIC001.CH"

/*/{Protheus.doc} OFIC001
Consulta Orçamentos Balcão de Entrega Futura - Argentina

@author Andre Luis Almeida
@since 09/12/2025
@version 1.0
@type function
/*/
Function OFIC001()

	Local cVdaFut := "VS1_STATUS = 'X' AND VS1_TIPORC = '1' AND VS1_TPFATR = '4' AND " // Venda Futura
	Private oBrwOC001
	Private aRotina := {} // Necessário declarar devido a função OXA0110075_ConsultaItensEntregaFutura()
	
	If cPaisLoc <> "ARG"
		FMX_HELP("OFIC001",STR0009) // Funcionalidade disponível apenas para Argentina
		Return
	EndIf

	DbSelectArea("VS1")
	oBrwOC001 := FWMBrowse():New()
	oBrwOC001:SetAlias("VS1")
	oBrwOC001:DisableLocate()
	oBrwOC001:DisableDetails()
	oBrwOC001:SetAmbiente(.F.)
	oBrwOC001:SetWalkthru(.F.)
	oBrwOC001:SetDescription(STR0001) // Consulta Orçamentos Balcão de Entrega Futura
	oBrwOC001:SetMenuDef("OFIC001") // Mostra os botões da rotina
	oBrwOC001:SetFilterDefault( "@ "+cVdaFut+OX0180061_SQL_EntregaFutura(4) ) // 4 = Todos Orçamentos de Entrega Futura (com ou sem Remito)
	oBrwOC001:AddFilter(STR0002,"@ "+cVdaFut+OX0180061_SQL_EntregaFutura(1),.f.,.f.,) // Filtro Adicional - 1 = Orçamentos que possui Remito com todos Itens Entregues
	oBrwOC001:AddFilter(STR0003,"@ "+cVdaFut+OX0180061_SQL_EntregaFutura(2),.f.,.f.,) // Filtro Adicional - 2 = Orçamentos que possui Remito com Itens Entregues parcialmente
	oBrwOC001:AddFilter(STR0004,"@ "+cVdaFut+OX0180061_SQL_EntregaFutura(3),.f.,.f.,) // Filtro Adicional - 3 = Orçamentos sem Remito (nenhum Item Entregue)
	oBrwOC001:AddFilter(STR0005,"@ "+cVdaFut+OX0180061_SQL_EntregaFutura(5),.f.,.f.,) // Filtro Adicional - 5 = Orçamentos que possuem alguma pendência de Entrega
	oBrwOC001:AddLegend( 'OFC001021_CorBrowse()=="1"' , 'BR_VERDE'    , STR0002 , , .f. ) // Orçamentos que possui Remito com todos Itens Entregues
	oBrwOC001:AddLegend( 'OFC001021_CorBrowse()=="2"' , 'BR_LARANJA'  , STR0003 , , .f. ) // Orçamentos que possui Remito com Itens Entregues parcialmente
	oBrwOC001:AddLegend( 'OFC001021_CorBrowse()=="3"' , 'BR_VERMELHO' , STR0004 , , .f. ) // Orçamentos sem Remito (nenhum Item Entregue)
	oBrwOC001:SetInsert(.f.)
	oBrwOC001:SetUseFilter(.t.)
	oBrwOC001:lOptionReport := .f.
	oBrwOC001:Activate()

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 09/12/2025
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION 'OFC001011_VisualizaOrcamento' OPERATION 2 ACCESS 0 // Visualiza Orçamento
ADD OPTION aRotina TITLE STR0007 ACTION 'OXA0110075_ConsultaItensEntregaFutura' OPERATION 2 ACCESS 0 // Consulta Itens da Entrega Futura
ADD OPTION aRotina TITLE STR0008 ACTION 'OFC001031_LegendaBrowse' OPERATION 2 ACCESS 0 // Legenda

Return aRotina

/*/{Protheus.doc} OFC001011_VisualizaOrcamento
Visualiza o Orçamento

@author Andre Luis Almeida
@since 09/12/2025
/*/
Function OFC001011_VisualizaOrcamento()

OFIC170( VS1->VS1_FILIAL, VS1->VS1_NUMORC )

Return

/*/{Protheus.doc} OFC001021_CorBrowse
Cor do Browse do Orçamento

@author Andre Luis Almeida
@since 09/12/2025
/*/
Function OFC001021_CorBrowse()
Local nPos    := 0
Local aCor    := {0,0,0}
Local cCor    := "3"
Local aDados  := {}
Local oSqlHlp := DMS_SqlHelper():New()
Local cQuery  := ""
cQuery += "SELECT SC6.C6_NOTA, SC6.C6_QTDENT, SC6.C6_QTDVEN "
cQuery += "  FROM " + RetSqlName("SC6") + " SC6 "
cQuery += " WHERE SC6.C6_FILIAL = '"+VS1->VS1_FILIAL+"'"
cQuery += "   AND SC6.C6_NUM = '"+VS1->VS1_PEDREM+"'"
cQuery += "   AND SC6.D_E_L_E_T_ = ' ' "
aDados := oSqlHlp:GetSelectArray(cQuery,3)
For nPos := 1 to Len(aDados)
	Do Case
		Case aDados[nPos,1] <> ' ' .and. aDados[nPos,2] >= aDados[nPos,3]
			aCor[1]++ // Orçamentos que possui Remito com todos Itens Entregues
		Case aDados[nPos,1] <> ' ' .and. aDados[nPos,2] > 0 .and. aDados[nPos,2] < aDados[nPos,3]
			aCor[2]++ // Orçamentos que possui Remito com Itens Entregues parcialmente
		Case aDados[nPos,1] = ' ' .and. aDados[nPos,2] == 0
			aCor[3]++ // Orçamentos sem Remito (nenhum Item Entregue)
	EndCase
Next
Do Case
	Case aCor[2] > 0
		cCor := "2" // Orçamentos que possui Remito com Itens Entregues parcialmente
	Case aCor[3] > 0
		cCor := "3" // Orçamentos sem Remito (nenhum Item Entregue)
	Case aCor[1] > 0
		cCor := "1" // Orçamentos que possui Remito com todos Itens Entregues
EndCase
Return cCor

/*/{Protheus.doc} OFC001031_LegendaBrowse
Exibe a tela com as legendas

@author Andre Luis Almeida
@since 09/12/2025
/*/
Function OFC001031_LegendaBrowse()
	Local oLegenda as Object
	oLegenda := FWLegend():New()
	oLegenda:Add( "" , "BR_VERDE"    , STR0002 ) // Orçamentos que possui Remito com todos Itens Entregues
	oLegenda:Add( "" , "BR_LARANJA"  , STR0003 ) // Orçamentos que possui Remito com Itens Entregues parcialmente
	oLegenda:Add( "" , "BR_VERMELHO" , STR0004 ) // Orçamentos sem Remito (nenhum Item Entregue)
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:Deactivate()
	FreeObj(oLegenda)
Return
