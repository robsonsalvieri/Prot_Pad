#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA450.CH"

/*/{Protheus.doc} OFIA450
	Cadastro de Serviços Especializados

	@author Andre Luis Almeida
	@since 20/08/2022
/*/
Function OFIA450(_cGruSrv,_cTipSrv)
Local aSize       := FWGetDialogSize( oMainWnd )
Local nCntFor     := 0
Local aGrpSrv     := {}
Local aTipSrv     := {}
Local cDesGrp     := ""
Local cDesTip     := ""
Local cFiltro     := ""
Local cQuery      := ""
Local cAuxAlias   := "SQLAUX"
Private cCadastro := STR0001 // Cadastro de Serviços Especializados
Default _cGruSrv  := ""
Default _cTipSrv  := ""
//
If !Empty(_cGruSrv) .or. !Empty(_cTipSrv)
	cCadastro := STR0002 // Serviços Especializados
EndIf
//
If !OA4500071_Validar_VRQ_SERINT() // Valida o Tamanho do campo VRQ_SERINT
	Return
EndIf
//
cQuery := "SELECT VPW_CODGRU , VPW_DESGRU "
cQuery += "  FROM " + RetSQLName("VPW")
cQuery += " WHERE VPW_FILIAL = '" + xFilial("VPW") + "'"
If !Empty(_cGruSrv)
	cQuery += "   AND VPW_CODGRU = '"+_cGruSrv+"'"
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	aAdd(aGrpSrv,{ (cAuxAlias)->( VPW_CODGRU ) , (cAuxAlias)->( VPW_DESGRU ) })
	If !Empty(_cGruSrv)
		cDesGrp := Alltrim((cAuxAlias)->( VPW_DESGRU ))
		cFiltro += " - "+STR0003+": "+_cGruSrv +" - "+cDesGrp // Grupo
	EndIf
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
//
cQuery := "SELECT VPV_CODTIP , VPV_DESTIP "
cQuery += "  FROM " + RetSQLName("VPV")
cQuery += " WHERE VPV_FILIAL = '" + xFilial("VPV") + "'"
If !Empty(_cTipSrv)
	cQuery += "   AND VPV_CODTIP = '"+_cTipSrv+"'"
EndIf
cQuery += "   AND D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	aAdd(aTipSrv,{ (cAuxAlias)->( VPV_CODTIP ) , (cAuxAlias)->( VPV_DESTIP ) })
	If !Empty(_cTipSrv)
		cDesTip := Alltrim((cAuxAlias)->( VPV_DESTIP ))
		cFiltro += " - "+STR0004+": "+_cTipSrv +" - "+cDesTip // Tipo
	EndIf
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
//
DbSelectArea("VPX")
DbSetOrder(1)
DbSelectArea("VPY")
DbSetOrder(2)

SetKey(VK_F6,{|| OA4500031_VisualizaMovimentacoes() })

oDlgOA450 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro+cFiltro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

oWorkArea := FWUIWorkArea():New( oDlgOA450 )
oWorkArea:CreateHorizontalBox( "LINE01", 60 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "OBJServico" } )
oWorkArea:CreateHorizontalBox( "LINE02", 40 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "OBJEstoque" } )
oWorkArea:Activate()

oBrwVPX := FWMBrowse():New()
oBrwVPX:SetAlias('VPX')
oBrwVPX:SetDescription(cCadastro+cFiltro)
oBrwVPX:SetOwner(oWorkarea:GetPanel("OBJServico"))
If !Empty(_cGruSrv) .or. !Empty(_cTipSrv) // Se filtrou o Grupo ou o Tipo do Serviço
	oBrwVPX:SetMenuDef( '' ) // Não deixar incluir/alterar/excluir
	oBrwVPX:AddButton(STR0005,{|| oDlgOA450:End() },,2,2) // Fechar
EndIf
If !Empty(_cGruSrv)
	oBrwVPX:AddButton(STR0006+" ( "+_cGruSrv+" )",{|| OA3900021_EstoqueTotal(_cGruSrv,cDesGrp) },,2,2) // Totais de Estoque do Grupo de Serviço Especializado
EndIf
If !Empty(_cTipSrv)
	oBrwVPX:AddButton(STR0007+" ( "+_cTipSrv+" )",{|| OA3800031_EstoqueTotal(_cTipSrv,cDesTip) },,2,2) // Totais de Estoque do Tipo de Serviço Especializado
EndIf
oBrwVPX:DisableDetails()
oBrwVPX:DisableLocate()
For nCntFor := 1 to len(aGrpSrv)
	oBrwVPX:AddFilter( STR0003+": "+aGrpSrv[nCntFor,1]+" - "+aGrpSrv[nCntFor,2] ,"@ VPX_GRUSER = '"+aGrpSrv[nCntFor,1]+"'",!Empty(_cGruSrv),!Empty(_cGruSrv)) // Grupo
Next
For nCntFor := 1 to len(aTipSrv)
	oBrwVPX:AddFilter( STR0004+": "+aTipSrv[nCntFor,1]+" - "+aTipSrv[nCntFor,2] ,"@ VPX_TIPSER = '"+aTipSrv[nCntFor,1]+"'",!Empty(_cTipSrv),!Empty(_cTipSrv)) // Tipo
Next
oBrwVPX:SetAmbiente(.F.)
oBrwVPX:SetWalkthru(.F.)
oBrwVPX:SetUseFilter()
oBrwVPX:ForceQuitButton()
oBrwVPX:Activate()

oBrwVPY := FWMBrowse():New()
oBrwVPY:SetAlias('VPY')
oBrwVPY:SetDescription(STR0008) // Estoque do Serviço Especializado posicionado
oBrwVPY:SetOwner(oWorkarea:GetPanel("OBJEstoque"))
oBrwVPY:SetMenuDef( '' )
oBrwVPY:AddButton("<F6> "+STR0009,{|| OA4500031_VisualizaMovimentacoes() },,2,2) // Visualiza Movimentações da Filial posicionada
oBrwVPY:AddButton(STR0010,{|| OA4500021_EstoqueTotal( VPX->VPX_SERINT , VPX->VPX_GRUSER , VPX->VPX_CODSER , VPX->VPX_DESSER ) },,2,2) // Total das Filiais
oBrwVPY:DisableDetails()
oBrwVPY:DisableLocate()
oBrwVPY:SetAmbiente(.F.)
oBrwVPY:SetWalkthru(.F.)
oBrwVPY:SetUseFilter()
oBrwVPY:Activate()

oRelac:= FWBrwRelation():New() 
oRelac:AddRelation( oBrwVPX , oBrwVPY , { { "VPY_FILIAL" , "VPX_FILIAL" }, { "VPY_SERINT" , "VPX_SERINT" } })
oRelac:Activate()

oDlgOA450:Activate( , , , , , , ) //ativa a janela

SetKey(VK_F6, Nil )

Return

Static Function MenuDef()

	Local aRotina := {}
	aRotina := FWMVCMenu('OFIA450')

	ADD OPTION aRotina Title STR0016 Action 'OA4500061_VisualizaTipoServico(VPX->VPX_TIPSER)' OPERATION 2 ACCESS 0 // Visualiza Tipo de Serviço com Regras de Valores

Return aRotina

Static Function ModelDef()

	Local oModel
	Local oStrVPX := FWFormStruct(1, "VPX")

	oModel := MPFormModel():New('OFIA450',,,,)
	oModel:AddFields('VPXMASTER',/*cOwner*/ , oStrVPX)
	oModel:SetDescription(STR0002) // Serviços Especializados
	oModel:GetModel('VPXMASTER'):SetDescription(STR0002) // Serviços Especializados
//	oModel:InstallEvent("OFIA450LOG", /*cOwner*/, MVCLOGEV():New("OFIA450") ) // CONSOLE.LOG para verificar as chamadas dos eventos
	oModel:InstallEvent("OFIA450EVDEF", /*cOwner*/, OFIA450EVDEF():New("OFIA450"))

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVPX:= FWFormStruct(2, "VPX", { |cCampo| !ALLTRIM(cCampo) $ "VPX_CUSQTD/" } )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'BOXVPX', 100)
	oView:AddField('VIEW_VPX', oStrVPX, 'VPXMASTER')
	oView:EnableTitleView('VIEW_VPX', STR0002) // Serviços Especializados
	oView:SetOwnerView('VIEW_VPX','BOXVPX')

	oView:AddUserButton(STR0016,'PRODUTO', {|| OA4500061_VisualizaTipoServico() }) // Visualiza Tipo de Serviço com Regras de Valores

Return oView

/*/{Protheus.doc} OA4500011_ServicoUsado()
Verifica se foi utilizado o Servico Especializado nas tabelas de Estoque e Movimentações

@author Andre Luis Almeida
@since 25/08/2022
/*/
Function OA4500011_ServicoUsado(cCodigo)
Local cQAlias := "SQLAUX"
Local cQAux   := "" // Query Auxiliar
Local cQuery  := "" // Query Validação
Local cFilVPY := "" // Filiais Estoque
Local cFilVRQ := "" // Filiais Entradas
Local cFilVRT := "" // Filiais Transferencias
Local cFilVRS := "" // Filiais Saidas
//
// Estoque
//
cQAux := "SELECT DISTINCT VPY_FILEST FROM "+RetSqlName("VPY")+" WHERE VPY_FILIAL = '"+xFilial("VPY")+"' AND D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQAux), cQAlias, .T., .T. )
Do While !( cQAlias )->( Eof() )
	cFilVPY += "'"+( cQAlias )->( VPY_FILEST )+"',"
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
cFilVPY := IIf(!Empty(cFilVPY),left(cFilVPY,len(cFilVPY)-1),"' '")
cQuery += "SELECT VPY.R_E_C_N_O_ AS RECNO "
cQuery += "  FROM "+RetSQLName('VPY')+" VPY"
cQuery += " WHERE VPY.VPY_FILIAL = '"+xFilial("VPY")+"'"
cQuery += "   AND VPY.VPY_SERINT = '"+cCodigo+"'"
cQuery += "   AND VPY.VPY_FILEST IN ("+cFilVPY+")"
cQuery += "   AND VPY.D_E_L_E_T_ = ' '"
//
cQuery += " UNION "
//
// Entradas
//
cQAux := "SELECT DISTINCT VRQ_FILIAL FROM "+RetSqlName("VRQ")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQAux), cQAlias, .T., .T. )
Do While !( cQAlias )->( Eof() )
	cFilVRQ += "'"+( cQAlias )->( VRQ_FILIAL )+"',"
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
cFilVRQ := IIf(!Empty(cFilVRQ),left(cFilVRQ,len(cFilVRQ)-1),"' '")
cQuery += "SELECT VRQ.R_E_C_N_O_ AS RECNO "
cQuery += "  FROM "+RetSQLName('VRQ')+" VRQ"
cQuery += " WHERE VRQ.VRQ_FILIAL IN ("+cFilVRQ+")"
cQuery += "   AND VRQ.VRQ_SERINT = '"+cCodigo+"'"
cQuery += "   AND VRQ.D_E_L_E_T_ = ' '"
//
cQuery += " UNION "
//
// Transferencias
//
cQAux := "SELECT DISTINCT VRT_FILIAL FROM "+RetSqlName("VRT")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQAux), cQAlias, .T., .T. )
Do While !( cQAlias )->( Eof() )
	cFilVRT += "'"+( cQAlias )->( VRT_FILIAL )+"',"
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
cFilVRT := IIf(!Empty(cFilVRT),left(cFilVRT,len(cFilVRT)-1),"' '")
cQuery += "SELECT VRT.R_E_C_N_O_ AS RECNO "
cQuery += "  FROM "+RetSQLName('VRT')+" VRT"
cQuery += " WHERE VRT.VRT_FILIAL IN ("+cFilVRT+")"
cQuery += "   AND VRT.VRT_SERINT = '"+cCodigo+"'"
cQuery += "   AND VRT.D_E_L_E_T_ = ' '"
//
cQuery += " UNION "
//
// Saidas
//
cQAux := "SELECT DISTINCT VRS_FILIAL FROM "+RetSqlName("VRS")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQAux), cQAlias, .T., .T. )
Do While !( cQAlias )->( Eof() )
	cFilVRS += "'"+( cQAlias )->( VRS_FILIAL )+"',"
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
cFilVRS := IIf(!Empty(cFilVRS),left(cFilVRS,len(cFilVRS)-1),"' '")
cQuery += "SELECT VRS.R_E_C_N_O_ AS RECNO "
cQuery += "  FROM "+RetSQLName('VRS')+" VRS"
cQuery += " WHERE VRS.VRS_FILIAL IN ("+cFilVRS+")"
cQuery += "   AND VRS.VRS_SERINT = '"+cCodigo+"'"
cQuery += "   AND VRS.D_E_L_E_T_ = ' '"
//
DbSelectArea("VPX")
//
Return ( FM_SQL( cQuery ) > 0 )

/*/{Protheus.doc} OA4500021_EstoqueTotal()
Retorna a Qtde do Estoque Total de um determinado Serviço Especializado independente a Filial do Estoque

@author Andre Luis Almeida
@since 26/08/2022
/*/
Function OA4500021_EstoqueTotal(cCodigo,cGruSrv,cCodSrv,cDesSrv)
Local aIntCab   := {}
Local aIntLin   := {}
Local cQuery    := ""
Local cAuxAlias := "SQLAUX"
Private cCadastro := STR0011+": "+Alltrim(cGruSrv)+" - "+Alltrim(cCodSrv)+" - "+Alltrim(cDesSrv) // Estoque do Serviço Especializado
If !Empty(cCodigo)
	aadd( aIntLin , { STR0012 , 0 }) // TODAS FILIAIS
	cQuery := "SELECT VPY_FILEST , SUM(VPY_QTDEST) AS QTDEST"
	cQuery += "  FROM "+RetSQLName('VPY')
	cQuery += " WHERE VPY_FILIAL = '"+xFilial("VPY")+"'"
	cQuery += "   AND VPY_SERINT = '"+cCodigo+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY VPY_FILEST"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
	While !(cAuxAlias)->(Eof())
		aadd( aIntLin , { (cAuxAlias)->(VPY_FILEST)+" - "+FWFilialName( , (cAuxAlias)->(VPY_FILEST) ) , (cAuxAlias)->(QTDEST) })
		aIntLin[1,2] += (cAuxAlias)->(QTDEST)
		(cAuxAlias)->(DbSkip())
	EndDo
	(cAuxAlias)->(DbCloseArea())
	DbSelectArea("VPX")
	If len(aIntLin) > 1
		aAdd(aIntCab,{ Alltrim(cGruSrv)+" - "+Alltrim(cCodSrv)+" - "+Alltrim(cDesSrv) , "C" , 300 , "@!" })
		aAdd(aIntCab,{ RetTitle("VPY_QTDEST") , "N" , 100 , "@E 999,999,999,999,999" })
		FGX_VISINT( "OFIA450" , cCadastro , aIntCab , aIntLin , .t. )
	Else
		MsgStop(STR0014,STR0013) // Estoque inexistente. Impossível continuar. / Atencao
	EndIf
Else
	MsgStop(STR0014,STR0013) // Estoque inexistente. Impossível continuar. / Atencao
EndIf
Return

/*/{Protheus.doc} OA4500031_VisualizaMovimentacoes
Chama rotina para Visualizar as Movimentações de Entrada e Saida dos Serviços Especializados

@author Andre Luis Almeida
@since 14/09/2022
/*/
Function OA4500031_VisualizaMovimentacoes()
//
SetKey(VK_F6, Nil )
OFIA451( VPY->VPY_FILIAL , VPY->VPY_CODEST , .t. )
SetKey(VK_F6,{|| OA4500031_VisualizaMovimentacoes() })
//
Return

/*/{Protheus.doc} OA4500041_AjustaCustoMedio
Partindo da Entrada - Ajusta o Custo Medio do Serviço ( VPX_CUSMED / VPX_CUSQTD )

@author Andre Luis Almeida
@since 14/11/2022
/*/
Function OA4500041_AjustaCustoMedio( cVRPFILIAL , cVRPCODIGO )
Local oModVPX   := FWLoadModel( 'OFIA450' ) // MVC somente para atualizar o VPX
Local cQuery    := ""
Local cAuxAlias := "SQLAUX"
Local nCusTot   := 0
Local nQtdTot   := 0
Local nCusMed   := 0
//
cQuery := "SELECT VRQ.VRQ_VLRUNI , VRQ.VRQ_QTDSER , VPX.R_E_C_N_O_ AS RECVPX "
cQuery += "  FROM " + RetSQLName("VRQ") + " VRQ "
cQuery += "  JOIN " + RetSQLName("VPX") + " VPX ON ( VPX.VPX_FILIAL='"+xFilial("VPX")+"' AND VPX.VPX_SERINT=VRQ.VRQ_SERINT AND VPX.D_E_L_E_T_ = ' ' ) "
cQuery += "  JOIN " + RetSQLName("VPV") + " VPV ON ( VPV.VPV_FILIAL='"+xFilial("VPV")+"' AND VPV.VPV_CODTIP=VPX.VPX_TIPSER AND VPV.VPV_RELSAI='0' AND VPV.D_E_L_E_T_ = ' ' )"
cQuery += " WHERE VRQ.VRQ_FILIAL = '" + cVRPFILIAL + "'"
cQuery += "   AND VRQ.VRQ_CODVRP = '" + cVRPCODIGO + "'"
cQuery += "   AND VRQ.D_E_L_E_T_ = ' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	DbSelectArea("VPX")
	DbGoTo( (cAuxAlias)->( RECVPX ) )
	nCusTot := ( VPX->VPX_CUSMED * VPX->VPX_CUSQTD ) + ( (cAuxAlias)->( VRQ_VLRUNI ) * (cAuxAlias)->( VRQ_QTDSER ) ) // Custo Atual + Custo da Entrada
	nQtdTot := VPX->VPX_CUSQTD + (cAuxAlias)->( VRQ_QTDSER ) // Qtd.Autal + Qtd.Entrada
	nCusMed := ( nCusTot / nQtdTot ) // Custo Medio
	oModVPX:SetOperation( MODEL_OPERATION_UPDATE )
	If oModVPX:Activate()
		oModVPX:SetValue( "VPXMASTER" , "VPX_CUSMED" , nCusMed ) // Grava Custo Medio
		oModVPX:SetValue( "VPXMASTER" , "VPX_CUSQTD" , nQtdTot ) // Grava Quantidade Total para calculo do Custo Medio
		If oModVPX:VldData()
			oModVPX:CommitData()
		EndIf
		oModVPX:DeActivate()
	EndIf
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
DbSelectArea("VPX")
//
FreeObj(oModVPX)
Return

/*/{Protheus.doc} OA4500051_ZeraCustoMedio
Partindo dos Serviços da Entrada ou da Saida - Zera o Custo Medio do Serviço ( VPX_CUSMED / VPX_CUSQTD ) se NÃO possuir mais Estoque dos Serviços

@author Andre Luis Almeida
@since 14/11/2022
/*/
Function OA4500051_ZeraCustoMedio( cTipo , cFILIAL , cCODIGO )
Local oModVPX   := FWLoadModel( 'OFIA450' ) // MVC somente para atualizar o VPX
Local cQuery    := ""
Local cAuxAlias := "SQLAUX"
Local cFilVPY   := ""
//
cQuery := "SELECT DISTINCT VPY_FILIAL FROM "+RetSqlName("VPY")+" WHERE D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !( cAuxAlias )->( Eof() )
	cFilVPY += "'"+( cAuxAlias )->( VPY_FILIAL )+"',"
	( cAuxAlias )->( dbSkip() )
EndDo
( cAuxAlias )->( dbCloseArea() )
DbSelectArea("VPX")
cFilVPY := IIf(!Empty(cFilVPY),left(cFilVPY,len(cFilVPY)-1),"'"+xFilial("VPY")+"'")
//
cQuery := "SELECT VPX.R_E_C_N_O_ AS RECVPX "
If cTipo == "E" // Entrada
	cQuery += "  FROM " + RetSQLName("VRQ") + " VRQ "
	cQuery += "  JOIN " + RetSQLName("VPX") + " VPX ON ( VPX.VPX_FILIAL='"+xFilial("VPX")+"' AND VPX.VPX_SERINT=VRQ.VRQ_SERINT AND VPX.D_E_L_E_T_ = ' ' ) "
	cQuery += "  JOIN " + RetSQLName("VPV") + " VPV ON ( VPV.VPV_FILIAL='"+xFilial("VPV")+"' AND VPV.VPV_CODTIP=VPX.VPX_TIPSER AND VPV.VPV_RELSAI='0' AND VPV.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE VRQ.VRQ_FILIAL = '" + cFILIAL + "'"
	cQuery += "   AND VRQ.VRQ_CODVRP = '" + cCODIGO + "'"
	cQuery += "   AND VRQ.D_E_L_E_T_ = ' '"
Else // cTipo == "S" // Saida
	cQuery += "  FROM " + RetSQLName("VRS") + " VRS "
	cQuery += "  JOIN " + RetSQLName("VPX") + " VPX ON ( VPX.VPX_FILIAL='"+xFilial("VPX")+"' AND VPX.VPX_SERINT=VRS.VRS_SERINT AND VPX.D_E_L_E_T_ = ' ' ) "
	cQuery += "  JOIN " + RetSQLName("VPV") + " VPV ON ( VPV.VPV_FILIAL='"+xFilial("VPV")+"' AND VPV.VPV_CODTIP=VPX.VPX_TIPSER AND VPV.VPV_RELSAI='0' AND VPV.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE VRS.VRS_FILIAL = '" + cFILIAL + "'"
	cQuery += "   AND VRS.VRS_CODVRR = '" + cCODIGO + "'"
	cQuery += "   AND VRS.D_E_L_E_T_ = ' '"
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAuxAlias , .F., .T. )
While !(cAuxAlias)->(Eof())
	DbSelectArea("VPX")
	DbGoTo( (cAuxAlias)->( RECVPX ) )
	cQuery := "SELECT SUM(VPY_QTDEST) AS QTDEST"
	cQuery += "  FROM "+RetSQLName('VPY')
	cQuery += " WHERE VPY_FILIAL IN ("+cFilVPY+")"
	cQuery += "   AND VPY_SERINT = '"+VPX->VPX_SERINT+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) == 0 // NÃO possui Estoque - Zera Custo Medio
		oModVPX:SetOperation( MODEL_OPERATION_UPDATE )
		If oModVPX:Activate()
			oModVPX:SetValue( "VPXMASTER" , "VPX_CUSMED" , 0 ) // Grava Custo Medio
			oModVPX:SetValue( "VPXMASTER" , "VPX_CUSQTD" , 0 ) // Grava Quantidade Total para calculo do Custo Medio
			If oModVPX:VldData()
				oModVPX:CommitData()
			EndIf
			oModVPX:DeActivate()
		EndIf
	EndIf
	(cAuxAlias)->(DbSkip())
EndDo
(cAuxAlias)->(DbCloseArea())
DbSelectArea("VPX")
//
FreeObj(oModVPX)
Return

/*/{Protheus.doc} OA4500061_VisualizaTipoServico
Visualizar o Tipo de Serviço Especializado

@author Andre Luis Almeida
@since 29/12/2022
/*/
Function OA4500061_VisualizaTipoServico(cTipSer)
Local oModel    := FWModelActive()
Default cTipSer := oModel:GetValue("VPXMASTER","VPX_TIPSER")
DbSelectArea("VPV")
DbSetOrder(1)
If !Empty(cTipSer) .and. DbSeek(xFilial("VPV")+cTipSer)
	oExecView := FWViewExec():New()
	oExecView:SetOperation(MODEL_OPERATION_VIEW)
	oExecView:SetTitle(STR0017) // Visualizar
	oExecView:SetSource("OFIA380")
	oExecView:OpenView(.T.)
EndIf
Return

/*/{Protheus.doc} OA4500071_Validar_VRQ_SERINT
Validar o tamanho do campo VRQ_SERINT

@author Andre Luis Almeida
@since 01/11/2023
/*/
Function OA4500071_Validar_VRQ_SERINT()
Local lRet := .t.
If GetSX3Cache("VRQ_SERINT","X3_TAMANHO") == 2 // Tamanho esta errado na base de dados - Foi corrigido ATUSX na Release 12.1.2310
	MsgInfo(STR0018,STR0013) // A funcionalidade de Serviço Especializado está disponível a partir da release 12.1.2310. Para utilizá-la, por favor atualize o Protheus para esta release e aplique o último pacote de expedição contínua dos módulos de DMS. / Atencao
	lRet := .f.
EndIf
Return lRet