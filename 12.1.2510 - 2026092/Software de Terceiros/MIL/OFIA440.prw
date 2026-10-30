#INCLUDE "TOTVS.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA440.CH"

Function OFIA440(cCodSBM)

Local oOFIA440
Local aSize   := FWGetDialogSize( oMainWnd )
Local cTitVBN := STR0002 // Movimentações
Private cCadastro := STR0001 // Saldos das Promoções
Private oBrwVBM
Private oBrwVBN
Default cCodSBM := "" // se vier conteudo, esta consultando e mostra apenas as movimentações de uma determinada promoção

oOFIA440 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],STR0001,,,,128,,,,,.t.) // Saldos das Promoções

	If Empty(cCodSBM)
		oTPanVBM := TPanel():New(0,0,"",oOFIA440,NIL,.T.,.F.,NIL,NIL,120,(oOFIA440:nClientHeight/4)-10,.F.,.F.)
		oTPanVBM:Align := CONTROL_ALIGN_TOP
		oTPanVBN := TPanel():New(0,0,"",oOFIA440,NIL,.T.,.F.,NIL,NIL,120,(oOFIA440:nClientHeight/4)-10,.F.,.F.)
		oTPanVBN:Align := CONTROL_ALIGN_BOTTOM 
		oBrwVBM := FWMBrowse():New()
		oBrwVBM:SetAlias('VBM')
		oBrwVBM:SetOwner(oTPanVBM)
		oBrwVBM:ForceQuitButton()
		oBrwVBM:SetDescription(STR0001) // Saldos das Promoções
		oBrwVBM:AddLegend(" dtos(VBM_DATFIN) < '"+dtos(dDataBase)+"' ", "RED"  , STR0003 ) // Promoção Antiga
		oBrwVBM:AddLegend(" dtos(VBM_DATINI) > '"+dtos(dDataBase)+"' ", "BLUE" , STR0004 ) // Promoção Futura
		oBrwVBM:AddLegend(" dtos(VBM_DATINI) <= '"+dtos(dDataBase)+"' .and. dtos(VBM_DATFIN) >= '"+dtos(dDataBase)+"' ", "GREEN" , STR0005+" ("+Transform(dDataBase,"@D")+")") // Promoção Atual
		oBrwVBM:DisableDetails()
		oBrwVBM:Activate()
	Else
		oTPanVBN := TPanel():New(0,0,"",oOFIA440,NIL,.T.,.F.,NIL,NIL,120,oOFIA440:nClientHeight,.F.,.F.)
		oTPanVBN:Align := CONTROL_ALIGN_ALLCLIENT
		VBM->(DbSetOrder(1))
		VBM->(DbSeek( xFilial("VBM") + cCodSBM )) // Poscionar no VBM
		cTitVBN := Alltrim(OA4400031_NomeCriterio( VBM->VBM_SEQVEN ))
	EndIf

	oBrwVBN := FwMBrowse():New()
	oBrwVBN:SetDescription( cTitVBN )
	oBrwVBN:SetMenuDef( '' )
	oBrwVBN:SetAlias('VBN')
	oBrwVBN:SetOwner(oTPanVBN)
	If !Empty(cCodSBM)
		oBrwVBN:AddFilter( cTitVBN , "@ VBN_CODVBM = '"+cCodSBM+"' ",.t.,.f.,)
		oBrwVBN:AddButton(STR0006,{ || oOFIA440:End() }) // Fechar
		oBrwVBN:ForceQuitButton()
	EndIf
	oBrwVBN:AddButton(STR0007,{ || OA4400021_Visualiza_Orcamento() }) // Visualiza Orçamento posicionado
	oBrwVBN:AddLegend(" VBN_TIPMOV == '0' ", "GRAY"   , STR0008+" ( + )" ) // Saldo Inicial
	oBrwVBN:AddLegend(" VBN_TIPMOV == '1' ", "YELLOW" , STR0009+" ( - )" ) // Utilização
	oBrwVBN:AddLegend(" VBN_TIPMOV == '2' ", "ORANGE" , STR0010+" ( + )" ) // Devolução
	oBrwVBN:AddFilter( "+" , "@ VBN_TIPMOV IN ('0','2') ",.f.,.f.,)
	oBrwVBN:AddFilter( "-" , "@ VBN_TIPMOV = '1' ",.f.,.f.,)
	oBrwVBN:DisableLocate()
	oBrwVBN:DisableDetails()
	oBrwVBN:SetAmbiente(.F.)
	oBrwVBN:SetWalkthru(.F.)
	oBrwVBN:SetInsert(.f.)
	If Empty(cCodSBM)
		oBrwVBN:SetUseFilter(.f.)
	EndIf
	oBrwVBN:SetDoubleClick( { || OA4400021_Visualiza_Orcamento() } )
	oBrwVBN:Activate()

	If Empty(cCodSBM)
		oRelac:= FWBrwRelation():New()
		oRelac:AddRelation( oBrwVBM , oBrwVBN , {{ "VBN_FILIAL", "VBM_FILIAL" }, { "VBN_CODVBM", "VBM_CODIGO" } })
		oRelac:Activate()
	EndIf

oOFIA440:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('OFIA440')

Return aRotina

Static Function ModelDef()

Local oModel
Local oStrVBM := FWFormStruct(1, "VBM")
Local oStrVBN := FWFormStruct(1, "VBN")

oStrVBN:SetProperty( 'VBN_CODVBM' , MODEL_FIELD_INIT , { || FWFldGet('VBM_CODIGO') } )

oModel := MPFormModel():New('OFIA440',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

oModel:AddFields('VBMMASTER',/*cOwner*/ , oStrVBM)
oModel:SetPrimaryKey( { "VBM_FILIAL", "VBM_CODIGO" } )

oModel:AddGrid("VBNDETAIL","VBMMASTER",oStrVBN)
oModel:SetRelation( 'VBNDETAIL', { { 'VBN_FILIAL', 'xFilial( "VBN" )' }, { 'VBN_CODVBM', 'VBM_CODIGO' } }, VBN->( IndexKey( 1 ) ) )

oModel:SetDescription(STR0001) // Saldos das Promoções
oModel:GetModel('VBMMASTER'):SetDescription(STR0001) // Saldos das Promoções
oModel:GetModel('VBNDETAIL'):SetDescription(STR0002) // Movimentações

//oModel:InstallEvent("OFIA440LOG", /*cOwner*/, MVCLOGEV():New("OFIA440") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("OFIA440EVDEF", /*cOwner*/, OFIA440EVDEF():New("OFIA440"))

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVBM:= FWFormStruct(2, "VBM")
Local oStrVBN:= FWFormStruct(2, "VBN", { |cCampo| !ALLTRIM(cCampo)+"|" $ "VBN_CODVBM|VBN_CODIGO|" })

oView := FWFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox( 'BOXVBM', 30)
oView:AddField('VIEW_VBM', oStrVBM, 'VBMMASTER')
oView:EnableTitleView('VIEW_VBM', STR0001) // Saldos das Promoções
oView:SetOwnerView('VIEW_VBM','BOXVBM')

oView:CreateHorizontalBox( 'BOXVBN', 70)
oView:AddGrid("VIEW_VBN",oStrVBN, 'VBNDETAIL')
oView:EnableTitleView('VIEW_VBN', STR0002) // Movimentações
oView:SetOwnerView('VIEW_VBN','BOXVBN')
oView:SetNoInsertLine('VIEW_VBN')
oView:SetNoDeleteLine('VIEW_VBN')
oView:SetViewProperty("VIEW_VBN", "ONLYVIEW")

Return oView

/*/
{Protheus.doc} OA4400011_Codigo_Saldo_Promocao
Retorna Codigo do VBM - Cabeça do Saldo das Promoções

@author Andre Luis Almeida
@since 26/05/2022
/*/
Function OA4400011_Codigo_Saldo_Promocao( cSeqVEN )
Local cRet   := ""
Local cQuery := ""
cQuery := "SELECT VEN_SEQUEN"
cQuery += "  FROM "+RetSqlName("VEN")
cQuery += " WHERE VEN_FILIAL = '"+xFilial("VEN")+"'"
cQuery += "   AND VEN_SEQUEN = '"+cSeqVEN+"'"
cQuery += "   AND VEN_SLDPRO = '1'"
cQuery += "   AND D_E_L_E_T_ = ' '"
If !Empty(FM_SQL(cQuery)) // Verifica se é necessário ter Cadastro do Saldo
	cQuery := "SELECT VBM_CODIGO "
	cQuery += "  FROM "+RetSqlName("VBM")
	cQuery += " WHERE VBM_FILIAL = '"+xFilial("VBM")+"'"
	cQuery += "   AND VBM_SEQVEN = '"+cSeqVEN+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cRet := FM_SQL(cQuery)
	If Empty(cRet) // Validar SEM Cadastro VBM ?
		cRet := "SEM_VBM"
	EndIf
EndIf
Return cRet

/*/
{Protheus.doc} OA4400021_Visualiza_Orcamento
Visualiza o Orçamento

@author Andre Luis Almeida
@since 26/05/2022
/*/
Static Function OA4400021_Visualiza_Orcamento()
If !Empty( VBN->VBN_FILORC + VBN->VBN_NUMORC )
	dbSelectArea("VS1")
	dbSetOrder(1)
	If dbSeek( VBN->VBN_FILORC + VBN->VBN_NUMORC )
		OFIC170( VS1->VS1_FILIAL , VS1->VS1_NUMORC )
	EndIf
Else
	MsgInfo(STR0012,STR0011) // Selecione uma movimentação que possui Orçamento relacionado. / Atenção
EndIf
Return

/*/
{Protheus.doc} OA4400031_NomeCriterio
Retorna o Nome do Criterio de Desconto

@author Andre Luis Almeida
@since 26/05/2022
/*/
Function OA4400031_NomeCriterio( cSeqVEN )
Local cQuery := ""
cQuery := "SELECT VEM.VEM_NOMCRI "
cQuery += "  FROM "+RetSqlName("VEN")+" VEN "
cQuery += "  JOIN "+RetSqlName("VEM")+" VEM "
cQuery += "    ON VEM.VEM_FILIAL = VEN.VEN_FILIAL"
cQuery += "   AND VEM.VEM_CODIGO = VEN.VEN_CODVEM"
cQuery += "   AND VEM.D_E_L_E_T_ = ' '"
cQuery += " WHERE VEN.VEN_FILIAL = '"+xFilial("VEN")+"'"
cQuery += "   AND VEN.VEN_SEQUEN = '"+cSeqVEN+"'"
cQuery += "   AND VEN.D_E_L_E_T_ = ' '"
Return FM_SQL(cQuery)