#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'WMSA160.CH'

#DEFINE WMSA16001 'WMSA16001'
#DEFINE WMSA16002 'WMSA16002'
#DEFINE WMSA16003 'WMSA16003'

Static lExistEnd := .F.

//----------------------------------------------------------
/*/{Protheus.doc} WMSA160 - Configuração de Código de Endereço

@author  SIGAWMS
@version P11
@since   04/03/15
/*/
//----------------------------------------------------------
Function WMSA160()
Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DC7')
	oBrowse:SetDescription(STR0001) // Descrição do browse "Configuração de Código de Endereço"
	oBrowse:SetMenuDef('WMSA160')   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()
Return
//----------------------------------------------------------
// Função MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0010 ACTION 'AxPesqui'        OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.WMSA160' OPERATION 2 ACCESS 0 // Visualizar
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.WMSA160' OPERATION 3 ACCESS 0 // Incluir
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.WMSA160' OPERATION 4 ACCESS 0 // Alterar
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.WMSA160' OPERATION 5 ACCESS 0 // Excluir
	//Ponto de entrada utilizado para inserir novas opções no array aRotina
	If ExistBlock("DLG160MNU")
		ExecBlock ("DLG160MNU",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// Função ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local aCposCab  := {'DC7_CODCFG', 'DC7_DESCFG', 'DC7_PESO1'} // Campos que nao devem ser exibidos na Grid
Local oModel
Local oStruDC7M
Local oStruDC7D
	oStruDC7M := FWFormStruct(1, 'DC7', { |cCampo| AllTrim(cCampo) == "DC3_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) )  > 0 })
	oStruDC7D := FWFormStruct(1, 'DC7', { |cCampo| AllTrim(cCampo) == "DC3_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) == 0 })

	oModel := MPFormModel():New('WMSA160',/*bPreValid*/,{ |oModel| PosVldMdl(oModel)})
	oModel:SetDescription(STR0001) // Configuração de Código de Endereço
	// Adicionando ao modelo um componente de formulário
	oModel:AddFields('DC7MASTER', /*cOwner*/, oStruDC7M)
	// Adicionando ao modelo um componente de grid
	oModel:AddGrid('DC7DETAIL', 'DC7MASTER', oStruDC7D, /*bLinePre*/, { |oModel,nLinha| PosVldLin(oModel,nLinha) })
	// Criação de relação entre as entidades do modelo
	oModel:SetRelation('DC7DETAIL', { { 'DC7_FILIAL', 'xFilial( "DC7" )' }, { 'DC7_CODCFG', 'DC7_CODCFG' }, { 'DC7_DESCFG', 'DC7_DESCFG' }, { 'DC7_PESO1', 'DC7_PESO1' } }, DC7->( IndexKey( 1 ) ) )
	// Definindo a chave primária do modelo
	oModel:SetPrimaryKey( { 'DC7_FILIAL', 'DC7_CODCFG', 'DC7_SEQUEN' } )
	oModel:SetActivate( { |oModel| ActModel(oModel) } )
Return oModel
//----------------------------------------------------------
// Função ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local aCposCab  := {'DC7_CODCFG', 'DC7_DESCFG', 'DC7_PESO1'} // Campos que nao devem ser exibidos na Grid
Local oModel    := FWLoadModel('WMSA160')
Local oView     := FWFormView():New()
Local oStruDC7M
Local oStruDC7D
	oStruDC7M := FWFormStruct(2, 'DC7', { |cCampo| AllTrim(cCampo) == "DC3_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) )  > 0 })
	oStruDC7D := FWFormStruct(2, 'DC7', { |cCampo| AllTrim(cCampo) == "DC3_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) == 0 })

	oView:SetModel(oModel)
	// Criando o componente de formulário na interface
	oView:AddField('VIEWDC7M', oStruDC7M, 'DC7MASTER')
	// Criando o componente de grid na interface
	oView:AddGrid('VIEWDC7D', oStruDC7D, 'DC7DETAIL')
	oView:AddIncrementField('VIEWDC7D', 'DC7_SEQUEN')
	// Criação dos conteiners para exibição dos dados na interface
	oView:CreateHorizontalBox('SUPERIOR', 20)
	oView:CreateHorizontalBox('INFERIOR', 80)
	// Relacionando o componente da interface
	oView:SetOwnerView('VIEWDC7M', 'SUPERIOR')
	oView:SetOwnerView('VIEWDC7D', 'INFERIOR')
Return oView
//----------------------------------------------------------
// Função chamada logo após a ativação do model
//----------------------------------------------------------
Static Function ActModel(oModel)
Local oModelGrid := oModel:GetModel('DC7DETAIL')
Local cCodCfgEnd := oModel:GetValue('DC7MASTER','DC7_CODCFG')
	SBE->(DbSetOrder(5))
	If SBE->(DbSeek(xFilial('SBE')+cCodCfgEnd))
		lExistEnd := .T.
	Else
		lExistEnd := .F.
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. lExistEnd
		oModelGrid:SetNoInsertLine(.T.)
		oModelGrid:SetNoDeleteLine(.T.)
	Else
		oModelGrid:SetNoInsertLine(.F.)
		oModelGrid:SetNoDeleteLine(.F.)
	EndIf
Return
//----------------------------------------------------------
// Função de pós-validação do model
//----------------------------------------------------------
Static Function PosVldMdl(oModel)
Local lRet := .T.
Local lWmsNew := SuperGetMv("MV_WMSNEW",.F.)

	If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. lExistEnd
		oModel:SetErrorMessage(oModel:GetId(),,,,WMSA16002,STR0008 + AllTrim(SBE->BE_LOCAL) + '.') // Não é possível deletar este código de endereço, pois o mesmo está vinculado a um ou mais endereços do Armazém '#####'
		lRet := .F.
	EndIf
	
	If lWmsNew .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		If oModel:GetModel("DC7DETAIL"):Length() > 6
			oModel:SetErrorMessage(oModel:GetId(),,,,WMSA16003,STR0009) // A quantidade de níveis máxima para configurações de endereço é 6.
			lRet := .F.
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
// Função de pós-validação de linha
//----------------------------------------------------------
Static Function PosVldLin(oMdGrid,nLinha)
Local aSaveRows := FWSaveRows() //Salvando as linhas
Local lRet      := .T.
Local nI        := 0
Local nPosicoes := 0
Local nMaxPos   := TamSX3('BE_LOCALIZ')[1]
	For nI := 1 To oMdGrid:Length()
		oMdGrid:GoLine( nI )
		If !oMdGrid:IsDeleted()
			nPosicoes += oMdGrid:GetValue('DC7_POSIC')
		EndIf
	Next nI
	If nPosicoes > nMaxPos
		oMdGrid:GetModel():SetErrorMessage(oMdGrid:GetId(),'DC7_SEQUEN',,,WMSA16001,STR0006,STR0007 + AllTrim(Str(nMaxPos)) + '.') // Total de posições ultrapassou o tamanho do código do endereço. //O total de posições não pode ser maior do que '#####'
		lRet := .F.
	EndIf
	FWRestRows( aSaveRows ) // Restaurando as linhas
Return lRet

//----------------------------------------------------------
// Função que valida se é possível a edição do campo - Chamada em dicionario
//----------------------------------------------------------
Function WMSA160WHN(oModel,cField)
Local lRet := .T.
	If cField == "DC7_POSIC"
		lRet := !lExistEnd
	EndIf
Return lRet
