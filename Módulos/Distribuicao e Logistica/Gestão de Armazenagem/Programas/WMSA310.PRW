#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA310.CH'

#DEFINE WMSA31001 'WMSA31001'

//----------------------------------------------------------
/*/{Protheus.doc} WMSA310 - Percentual de Ocupação da Norma de Unitização

@author  SIGAWMS
@version P11
@since   06/03/15
/*/
//----------------------------------------------------------
Function WMSA310()
Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DCP')
	oBrowse:SetDescription(STR0001) // Descrição do browse "Percentual de Ocupação da Norma de Unitização"
	oBrowse:SetMenuDef('WMSA310')   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()
Return
//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0008 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA310' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA310' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA310' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA310' OPERATION 5 ACCESS 0 // Excluir
	// Ponto de entrada utilizado para inserir novas opções no array aRotina
	If ExistBlock("DLG310MNU")
		ExecBlock("DLG310MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel   := MPFormModel():New('WMSA310')
Local oStruDCP := FWFormStruct(1, 'DCP')
	
	oStruDCP:SetProperty('DCP_ENDERE', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,'ExistCpo("SBE", M->DCP_LOCAL+M->DCP_ENDERE) .And. WMS310VFld(A,B,C)'))

	oModel:AddFields('DCPMASTER', /*cOwner*/, oStruDCP, /*bPreValid*/, { |oModel| PosVldMdl(oModel)} )
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel('WMSA310')
Local oView    := FWFormView():New()
Local oStruDCP := FWFormStruct(2, 'DCP')
	oView:SetModel(oModel)
	oView:AddField('VIEWDCP', oStruDCP, 'DCPMASTER')
Return oView
//----------------------------------------------------------
// Função de validação dos campos
//----------------------------------------------------------
Function WMS310VFld(oModel,cField,xValue)
	If cField == "DCP_ENDERE"
		oModel:SetValue('DCP_ESTFIS',Posicione('SBE',1,xFilial('SBE')+oModel:GetValue('DCP_LOCAL')+oModel:GetValue('DCP_ENDERE'),'BE_ESTFIS'))
	EndIf
Return .T.
//----------------------------------------------------------
// Função de pós-validação do model
//----------------------------------------------------------
Static Function PosVldMdl(oModel)
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local cProduto := Space(Len('DCP_CODPRO'))
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		DCP->(DbSetOrder(1)) // DCP_FILIAL+DCP_LOCAL+DCP_ENDERE+DCP_ESTFIS+DCP_NORMA+DCP_CODPRO
		If DCP->(DbSeek(xFilial('DCP')+oModel:GetValue('DCP_LOCAL')+oModel:GetValue('DCP_ENDERE')+oModel:GetValue('DCP_ESTFIS')+oModel:GetValue('DCP_NORMA')+(Iif(!Empty(oModel:GetValue('DCP_CODPRO')),oModel:GetValue('DCP_CODPRO'),cProduto))))
			oModel:GetModel():SetErrorMessage(oModel:GetId(),,,,WMSA31001,STR0006,STR0007) // Já existe registro com esta informação. // Troque a chave principal deste registro.
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
