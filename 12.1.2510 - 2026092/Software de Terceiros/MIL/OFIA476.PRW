#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA476.CH"

/*/{Protheus.doc} OFIA476
	Relacionamento entre Saidas e Entradas de Serviços Especializados

	@author Andre Luis Almeida
	@since 16/12/2022
/*/
Function OFIA476()
Local aSize       := FWGetDialogSize( oMainWnd )
Local cFiltro     := ""
Local cQuery      := ""
Local cQAlias     := "SQLVPV"
Local cSem_Relac  := ""
Local cCom_Cancel := ""
Local cCom_Valido := ""
Local cNamVRQ     := RetSqlName("VRQ")
Local cNamVRP     := RetSqlName("VRP")
Private cCadastro := STR0001 // Relacionamento entre Saidas e Entradas de Serviços Especializados

// Filtro Padrão SAIDA
cFiltro := "@ EXISTS ("
cFiltro += " SELECT VPX.VPX_SERINT "
cFiltro += "   FROM " + RetSqlName("VPX") + " VPX "
cFiltro += "  WHERE VPX.VPX_FILIAL = '"+xFilial("VPX")+"' "
cFiltro += "    AND VPX.VPX_SERINT = VRS_SERINT "
cFiltro += "    AND VPX.VPX_TIPSER IN ("
//
cQuery := "SELECT DISTINCT VPV_CODTIP "
cQuery += "  FROM "+RetSQLName("VPV")
cQuery += " WHERE VPV_FILIAL = '"+xFilial("VPV")+"'"
cQuery += "   AND VPV_RELSAI = '1'"
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
While ( cQAlias )->(!Eof())
	cFiltro += "'"+( cQAlias )->VPV_CODTIP+"',"
	( cQAlias )->(DbSkip())
Enddo
( cQAlias )->( dbCloseArea() )
DbSelectArea("VRS")
//
cFiltro := left(cFiltro,len(cFiltro)-1)
cFiltro += ") AND VPX.D_E_L_E_T_ = ' ' )"

// Filtro Sem Relacionamento
cSem_Relac := "NOT EXISTS ("
cSem_Relac += " SELECT VRQ.VRQ_SERINT "
cSem_Relac += "   FROM " + cNamVRQ + " VRQ "
cSem_Relac += "  WHERE VRQ.VRQ_FILVRS = VRS_FILIAL "
cSem_Relac += "    AND VRQ.VRQ_CODVRS = VRS_CODIGO "
cSem_Relac += "    AND VRQ.D_E_L_E_T_ = ' ' )"

// Filtro Com Relacionamento Cancelado
cCom_Cancel := "EXISTS ("
cCom_Cancel += " SELECT VRQ.VRQ_SERINT "
cCom_Cancel += "   FROM " + cNamVRQ + " VRQ "
cCom_Cancel += "   JOIN " + cNamVRP + " VRP ON VRP.VRP_FILIAL=VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO=VRQ.VRQ_CODVRP AND VRP.VRP_STATUS='2' AND VRP.D_E_L_E_T_ = ' ' "
cCom_Cancel += "  WHERE VRQ.VRQ_FILVRS = VRS_FILIAL "
cCom_Cancel += "    AND VRQ.VRQ_CODVRS = VRS_CODIGO "
cCom_Cancel += "    AND VRQ.D_E_L_E_T_ = ' ' )"
cCom_Cancel += " AND NOT EXISTS ("
cCom_Cancel += " SELECT VRQ.VRQ_SERINT "
cCom_Cancel += "   FROM " + cNamVRQ + " VRQ "
cCom_Cancel += "   JOIN " + cNamVRP + " VRP ON VRP.VRP_FILIAL=VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO=VRQ.VRQ_CODVRP AND VRP.VRP_STATUS<>'2' AND VRP.D_E_L_E_T_ = ' ' "
cCom_Cancel += "  WHERE VRQ.VRQ_FILVRS = VRS_FILIAL "
cCom_Cancel += "    AND VRQ.VRQ_CODVRS = VRS_CODIGO "
cCom_Cancel += "    AND VRQ.D_E_L_E_T_ = ' ' )"

// Filtro Com Relacionamento Valido
cCom_Valido := "EXISTS ("
cCom_Valido += " SELECT VRQ.VRQ_SERINT "
cCom_Valido += "   FROM " + cNamVRQ + " VRQ "
cCom_Valido += "   JOIN " + cNamVRP + " VRP ON VRP.VRP_FILIAL=VRQ.VRQ_FILIAL AND VRP.VRP_CODIGO=VRQ.VRQ_CODVRP AND VRP.VRP_STATUS<>'2' AND VRP.D_E_L_E_T_ = ' ' "
cCom_Valido += "  WHERE VRQ.VRQ_FILVRS = VRS_FILIAL "
cCom_Valido += "    AND VRQ.VRQ_CODVRS = VRS_CODIGO "
cCom_Valido += "    AND VRQ.D_E_L_E_T_ = ' ' )"

oDlgOA476 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOA476 )
oWorkArea:CreateHorizontalBox( "LINE01", 65 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "OBJSaida" } )
oWorkArea:CreateHorizontalBox( "LINE02", 35 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "OBJEntrada" } )
oWorkArea:Activate()

oBrwVRQ := FWMBrowse():New()
oBrwVRQ:SetAlias('VRQ')
oBrwVRQ:SetDescription(STR0002) // Entrada relacionada
oBrwVRQ:SetMenuDef( '' )
oBrwVRQ:SetOwner(oWorkarea:GetPanel("OBJEntrada"))
oBrwVRQ:SetDoubleClick( { || OA4760041_VisualizarEntrada() } )
oBrwVRQ:AddButton( STR0003 , {|| OA4760041_VisualizarEntrada() },,2,2) // Visualizar Entrada
oBrwVRQ:AddFilter( STR0004 , "@ VRQ_CODVRS <> ' '" ,.t.,.t.,,,,"filtro_VRQ") // Existe Relacionamento com a Saida
oBrwVRQ:AddLegend( 'OA4760031_LegendaEntrada() == "0"' , 'BR_BRANCO'   , STR0005 ) // Entrada Digitada
oBrwVRQ:AddLegend( 'OA4760031_LegendaEntrada() == "1"' , 'BR_VERDE'    , STR0006 ) // Entrada Efetivada
oBrwVRQ:AddLegend( 'OA4760031_LegendaEntrada() == "2"' , 'BR_VERMELHO' , STR0007 ) // Entrada Cancelada
oBrwVRQ:DisableDetails()
oBrwVRQ:DisableLocate()
oBrwVRQ:DisableConfig()
oBrwVRQ:DisableSeek()
oBrwVRQ:SetAmbiente(.F.)
oBrwVRQ:SetWalkthru(.F.)
oBrwVRQ:SetUseFilter()
oBrwVRQ:Activate()

oBrwVRS := FWMBrowse():New()
oBrwVRS:SetAlias('VRS')
oBrwVRS:SetDescription(cCadastro)
oBrwVRS:SetMenuDef( '' )
oBrwVRS:SetOwner(oWorkarea:GetPanel("OBJSaida"))
oBrwVRS:SetDoubleClick( { || OA4760021_VisualizarSaida() } )
oBrwVRS:SetFilterDefault(cFiltro)
oBrwVRS:AddButton( STR0008 , {|| OA4760021_VisualizarSaida() },,2,2) // Visualizar Saida
oBrwVRS:AddFilter( STR0009 , "@ ( "+cSem_Relac+" OR ( "+cCom_Cancel+" ) )" ,.f.,.t.,,,,"pendentes") // Pendentes ( Sem Relacionamento ou Com Relacionamento Cancelado )
oBrwVRS:AddFilter( STR0010 , "@ "+cSem_Relac ,.f.,.f.,,,,"sem_relac") // Sem Relacionamento
oBrwVRS:AddFilter( STR0011 , "@ "+cCom_Cancel,.f.,.f.,,,,"com_cancel") // Com Relacionamento Cancelado
oBrwVRS:AddFilter( STR0012 , "@ "+cCom_Valido,.f.,.f.,,,,"com_valido") // Com Relacionamento Valido
oBrwVRS:AddLegend( 'OA4760011_LegendaSaida() == "0"' , 'BR_BRANCO'   , STR0013 ) // Saida Digitada
oBrwVRS:AddLegend( 'OA4760011_LegendaSaida() == "3"' , 'BR_LARANJA'  , STR0014 ) // Pendências - Aguadando Liberação
oBrwVRS:AddLegend( 'OA4760011_LegendaSaida() == "5"' , 'BR_MARROM'   , STR0015 ) // Liberação de Pendências Reprovada
oBrwVRS:AddLegend( 'OA4760011_LegendaSaida() == "4"' , 'BR_AZUL'     , STR0016 ) // Liberado para Efetivar Saida
oBrwVRS:AddLegend( 'OA4760011_LegendaSaida() == "1"' , 'BR_VERDE'    , STR0017 ) // Saida Efetivada
oBrwVRS:AddLegend( 'OA4760011_LegendaSaida() == "2"' , 'BR_VERMELHO' , STR0018 ) // Saida Cancelada
oBrwVRS:DisableDetails()
oBrwVRS:DisableLocate()
oBrwVRS:DisableConfig()
oBrwVRS:DisableSeek()
oBrwVRS:SetAmbiente(.F.)
oBrwVRS:SetWalkthru(.F.)
oBrwVRS:SetUseFilter()
oBrwVRS:ForceQuitButton()
oBrwVRS:Activate()

oRelac:= FWBrwRelation():New() 
oRelac:AddRelation( oBrwVRS , oBrwVRQ , { { "VRQ_FILVRS" , "VRS_FILIAL" }, { "VRQ_CODVRS" , "VRS_CODIGO" } }) // Relacionamento entre a Saida e a Entrada
oRelac:Activate()

oDlgOA476:Activate( , , , , , , ) //ativa a janela

Return

/*/{Protheus.doc} OA4760011_LegendaSaida
Legenda da Saida

@author Andre Luis Almeida
@since 16/12/2022
/*/
Function OA4760011_LegendaSaida()
VRR->(DbSetOrder(1))
VRR->(DbSeek( VRS->VRS_FILIAL + VRS->VRS_CODVRR ))
Return VRR->VRR_STATUS

/*/{Protheus.doc} OA4760021_VisualizarSaida
Chama Visualização da Saida OFIA470

@author Andre Luis Almeida
@since 16/12/2022
/*/
Static Function OA4760021_VisualizarSaida()
Local nRecVRS := VRS->(RecNo())
DbSelectArea("VRR")
DbSetOrder(1)
If DbSeek( VRS->VRS_FILIAL + VRS->VRS_CODVRR )
	OA4700051_VisualizarSaida()
EndIf
DbSelectArea("VRS")
DbGoTo(nRecVRS)
Return()

/*/{Protheus.doc} OA4760031_LegendaEntrada
Legenda da Entrada

@author Andre Luis Almeida
@since 16/12/2022
/*/
Function OA4760031_LegendaEntrada()
VRP->(DbSetOrder(1))
VRP->(DbSeek( VRQ->VRQ_FILIAL + VRQ->VRQ_CODVRP ))
Return VRP->VRP_STATUS

/*/{Protheus.doc} OA4760041_VisualizarEntrada
Chama Visualização da Entrada OFIA460

@author Andre Luis Almeida
@since 16/12/2022
/*/
Static Function OA4760041_VisualizarEntrada()
Local nRecVRQ := VRQ->(RecNo())
DbSelectArea("VRP")
DbSetOrder(1)
If DbSeek( VRQ->VRQ_FILIAL + VRQ->VRQ_CODVRP )
	OA4600041_VisualizarEntrada()
EndIf
DbSelectArea("VRQ")
DbGoTo(nRecVRQ)
Return()