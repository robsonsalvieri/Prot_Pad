#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA483.CH"

Function OFIA483()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VB4')
	oBrowse:SetDescription(STR0001) //'Divergencia na conferência de item'
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA483')

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStrVB4 := FWFormStruct(1, "VB4")

	oModel := MPFormModel():New('OFIA483',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VB4MASTER',/*cOwner*/ , oStrVB4)
	oModel:SetPrimaryKey( { "VB4_FILIAL", "VB4_CODIGO" } )
	oModel:SetDescription(STR0001)
	oModel:GetModel('VB4MASTER'):SetDescription(STR0002) //Dados de divergencia na conferência de item

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVB4:= FWFormStruct(2, "VB4")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VB4', 100)
	oView:AddField('VIEW_VB4', oStrVB4, 'VB4MASTER')
	oView:EnableTitleView('VIEW_VB4', STR0001)
	oView:SetOwnerView('VIEW_VB4','VB4')

Return oView

/*/{Protheus.doc} OA4830015_MovtoDivergenciaConferencia
	Função para fazer a gravação histórico da movimentação de divergencia na conferencia do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 27/10/2022
/*/
Function OA4830015_MovtoDivergenciaConferencia(cFilOrc, cNumOrc, cTipo, cGruIte, cCodIte, cSeqIte, lMTela)

	Local aSize   := FWGetDialogSize( oMainWnd )
	Local cQuery  := ""
	Local cFiltro := ""
	Local oDlgHist
	Local aBkpRot := aClone(aRotina)

	Default cFilOrc := ""
	Default cNumOrc := ""
	Default cTipo   := ""
	Default cGruIte := ""
	Default cCodIte := ""
	Default cSeqIte := ""
	Default lMTela  := .t.

	aRotina := {}

	If !Empty(cNumOrc)

		cFiltro := 	" VB4_FILIAL = '" + xFilial("VB4") + "' "
		cFiltro += 	" AND VB4_FILORC = '" + cFilOrc + "' "
		cFiltro += 	" AND VB4_NUMORC = '" + cNumOrc + "' "
		cFiltro += 	" AND D_E_L_E_T_ = ' ' "

		If !Empty(cTipo)
			cFiltro += 	" AND VB4_TIPCON = '" + cTipo + "' "
		EndIf

		If !Empty(cGruIte) .and. !Empty(cCodIte)
			cFiltro += 	" AND VB4_GRUITE = '" + cGruIte + "'"
			cFiltro += 	" AND VB4_CODITE = '" + cCodIte + "' "
			
			If !Empty(cSeqIte)
				cFiltro += 	" AND VB4_SEQITE = '" + cSeqIte + "' "
			endif
		EndIf


		If lMTela

			oBrwVB4 := FwMBrowse():New()
			oBrwVB4:SetAlias('VB4')
			oBrwVB4:SetDescription( STR0003 + " - " + cNumOrc ) //"Histórico de Movimentação de Divergencia na Conferência"
			oBrwVB4:SetMenuDef( 'OFIA484' )
			oBrwVB4:AddFilter( STR0004 + cNumOrc , "@ " + cFiltro,.t.,.t.,) // "Orçamento "
			oBrwVB4:DisableLocate()
			oBrwVB4:DisableDetails()
			oBrwVB4:SetAmbiente(.F.)
			oBrwVB4:SetWalkthru(.F.)
			oBrwVB4:SetUseFilter()
			oBrwVB4:Activate()

		EndIf

	EndIf

	aRotina := aClone(aBkpRot)

Return
