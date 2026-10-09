#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIC000.CH"

/*/{Protheus.doc} OFIC000()
Consulta Itens Obsoletos (BZ_OBSOLE)

@author Andre Luis Almeida
@since 12/06/2025
@version 1.0
@return NIL
/*/
Function OFIC000()
Local aTELA       := FWGetDialogSize(oMainWnd)
Local cFB1Def     := "" // Filtro SB1 Default Padrao
Local cFB1ComB2   := "" // Filtro SB1 COM SB2
Local cFB1SemB2   := "" // Filtro SB1 SEM SB2
Local cFBZDef     := "" // Filtro SBZ Default Padrao
Local cFBZComB2   := "" // Filtro SBZ COM SB2
Local cFBZSemB2   := "" // Filtro SBZ SEM SB2
Local nNomeFil    := FWFilialName()
Private aRotina   := {} // Necessario deixar em branco para poder chamar a Consulta de outras rotinas
Private cCadastro := STR0001+" - "+STR0002+": "+cFilAnt+" - "+nNomeFil // Consulta Itens Obsoletos / Filial

DEFINE MSDIALOG oDlgOFIC000 TITLE cCadastro FROM aTELA[1], aTELA[2] TO aTELA[3], aTELA[4] PIXEL // TELA

oFolders := TFolder():New(001,001,{STR0007,STR0008},{}, oDlgOFIC000,,,,.t.,.f.,100,100) // Por Produtos / Por Indicadores dos Produtos
oFolders:Align := CONTROL_ALIGN_ALLCLIENT

// Filtro SB1 Default Padrao
cFB1Def := "@ EXISTS ("
cFB1Def += "SELECT SBZ.BZ_COD"
cFB1Def += "  FROM "+RetSqlName("SBZ")+" SBZ "
cFB1Def += " WHERE SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'"
cFB1Def += "   AND SBZ.BZ_COD = B1_COD"
cFB1Def += "   AND SBZ.BZ_OBSOLE = '1'"
cFB1Def += "   AND SBZ.D_E_L_E_T_ = ' ' )"
// Filtros do SB1 em relacao ao SB2
cFB1ComB2 := OC0000021_MontaFiltrosSB2(.t.,"B1_COD") // Filtro COM SB2
cFB1SemB2 := OC0000021_MontaFiltrosSB2(.f.,"B1_COD") // Filtro SEM SB2

// Filtro SBZ Default Padrao
cFBZDef := "@ BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_OBSOLE = '1'"
// Filtros do SBZ em relacao ao SB2
cFBZComB2 := OC0000021_MontaFiltrosSB2(.t.,"BZ_COD") // Filtro COM SB2
cFBZSemB2 := OC0000021_MontaFiltrosSB2(.f.,"BZ_COD") // Filtro SEM SB2

// Browse SB1 com BZ_OBSOLE
oBrwSB1 := FWMBrowse():New()
oBrwSB1:SetAlias("SB1")
oBrwSB1:SetDescription(STR0009+" - "+STR0002+": "+cFilAnt+" - "+nNomeFil ) // Produtos / Filial
oBrwSB1:SetOwner(oFolders:aDialogs[1])
oBrwSB1:SetMenuDef('')
oBrwSB1:AddButton(STR0003,{ || OC0000011_Visualizar(1,.f.) } ) // Visualizar Item
oBrwSB1:AddButton(STR0004,{ || OC0000011_Visualizar(2,.f.) } ) // Analise do Item
oBrwSB1:SetFilterDefault(cFB1Def)
oBrwSB1:AddFilter(STR0005+": "+cFilAnt+" - "+nNomeFil,cFB1ComB2,.f.,.f.,) // Com Saldo na Filial
oBrwSB1:AddFilter(STR0006+": "+cFilAnt+" - "+nNomeFil,cFB1SemB2,.f.,.f.,) // Sem Saldo na Filial
oBrwSB1:DisableLocate()
oBrwSB1:DisableDetails()
oBrwSB1:SetAmbiente(.F.)
oBrwSB1:SetWalkthru(.F.)
oBrwSB1:SetInsert(.f.)
oBrwSB1:SetUseFilter()
oBrwSB1:ForceQuitButton()
oBrwSB1:Activate()

// Browse SBZ ( BZ_OBSOLE == '1' )
oBrwSBZ := FWMBrowse():New()
oBrwSBZ:SetAlias("SBZ")
oBrwSBZ:SetDescription(STR0010+" - "+STR0002+": "+cFilAnt+" - "+nNomeFil ) // Indicadores dos Produtos / Filial
oBrwSBZ:SetOwner(oFolders:aDialogs[2])
oBrwSBZ:SetMenuDef('')
oBrwSBZ:AddButton(STR0003,{ || OC0000011_Visualizar(1,.t.) } ) // Visualizar Item
oBrwSBZ:AddButton(STR0004,{ || OC0000011_Visualizar(2,.t.) } ) // Analise do Item
oBrwSBZ:SetFilterDefault(cFBZDef)
oBrwSBZ:AddFilter(STR0005+": "+cFilAnt+" - "+nNomeFil,cFBZComB2,.f.,.f.,) // Com Saldo na Filial
oBrwSBZ:AddFilter(STR0006+": "+cFilAnt+" - "+nNomeFil,cFBZSemB2,.f.,.f.,) // Sem Saldo na Filial
oBrwSBZ:DisableLocate()
oBrwSBZ:DisableDetails()
oBrwSBZ:SetAmbiente(.F.)
oBrwSBZ:SetWalkthru(.F.)
oBrwSBZ:SetInsert(.f.)
oBrwSBZ:SetUseFilter()
oBrwSBZ:ForceQuitButton()
oBrwSBZ:Activate()

oDlgOFIC000:Activate( , , ,.t., , , )

Return

/*/{Protheus.doc} OC0000011_Visualizar
Visualizar Item / Analise do Item

@author Andre Luis Almeida
@since 12/06/2025
@version 1.0
@return NIL
/*/
Static Function OC0000011_Visualizar(nTp,lPosSB1)
Local aAreaSB1 := SB1->(getArea())
Local aAreaSBZ := SBZ->(getArea())
If lPosSB1
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1")+SBZ->BZ_COD))
EndIf
If nTp == 1 // Visualizar Item
    A010Visul("SB1",SB1->(RecNo()),2)
Else // Analise do Item
    OC001CONANA(SB1->B1_GRUPO,SB1->B1_CODITE)
EndIf
restArea(aAreaSB1)
restArea(aAreaSBZ)
Return

/*/{Protheus.doc} OC0000021_MontaFiltrosSB2
Monta Filtros com SB2

@author Andre Luis Almeida
@since 13/06/2025
@version 1.0
@return NIL
/*/
Static Function OC0000021_MontaFiltrosSB2(lComSB2,cCampo)
Local cFiltro := ""
Local cNamSB2 := RetSQLName("SB2")
Local cFilSB2 := xFilial("SB2")
If lComSB2 // Filtro COM SB2
    cFiltro := "@ EXISTS ("
    cFiltro += "SELECT SB2.R_E_C_N_O_"
    cFiltro += "  FROM "+cNamSB2+" SB2 "
    cFiltro += " WHERE SB2.B2_FILIAL = '"+cFilSB2+"'"
    cFiltro += "   AND SB2.B2_COD = "+cCampo
    cFiltro += "   AND SB2.B2_QATU > 0"
    cFiltro += "   AND SB2.D_E_L_E_T_ = ' ')"
Else // Filtro SEM SB2
    cFiltro := "@ EXISTS ("
    cFiltro += "SELECT SB2A.R_E_C_N_O_"
    cFiltro += "  FROM "+cNamSB2+" SB2A "
    cFiltro += " WHERE SB2A.B2_FILIAL = '"+cFilSB2+"'"
    cFiltro += "   AND SB2A.B2_COD = "+cCampo
    cFiltro += "   AND SB2A.B2_QATU = 0"
    cFiltro += "   AND SB2A.D_E_L_E_T_ = ' ')"
    cFiltro += " OR "
    cFiltro += "NOT EXISTS ("
    cFiltro += "SELECT SB2B.R_E_C_N_O_"
    cFiltro += "  FROM "+cNamSB2+" SB2B "
    cFiltro += " WHERE SB2B.B2_FILIAL = '"+cFilSB2+"'"
    cFiltro += "   AND SB2B.B2_COD = "+cCampo
    cFiltro += "   AND SB2B.D_E_L_E_T_ = ' ')"
EndIf
Return cFiltro