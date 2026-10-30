#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "OFIA490.CH"

/*/{Protheus.doc} OFIA490
Cadastro de tabela temporaria de preço de peça
@author Rubens
@since 11/08/2023
@version 1.0

@type function
/*/
Function OFIA490()

	Local oBrowse

	Private cGrupo := ""  // Utilizada na consulta padrao do VKZ

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return

Static Function BrowseDef()
	Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VKZ')
	oBrowse:SetDescription(STR0001) // 'Cadastro Tabela Temporária de Preço de Peça'
Return oBrowse

Static Function ModelDef()
	
	Local oModel
	Local aAuxTrigger

	Local oStruVKZ := FWFormStruct( 1, 'VKZ' ) // Tabela de Itens de Entrega

	oStruVKZ:AddTrigger( 'VKZ_GRUITE' ,'VKZ_GRUITE' , { || .T. } , { || cGrupo := FWFldGet('VKZ_GRUITE') } )

	aAuxTrigger := FwStruTrigger("VKZ_CODITE","VKZ_PRODUT","SB1->B1_COD",.T.,"SB1",7,"xFilial('SB1') + FWFldGet('VKZ_GRUITE') + FwFldGet('VKZ_CODITE')","!Empty(FWFldGet('VKZ_CODITE'))")
	oStruVKZ:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	oModel := MPFormModel():New('OFIA490' )

	// ======================================= //	
	oModel:AddFields( 'MODEL_VKZ', /*cOwner*/, oStruVKZ)
	oModel:SetDescription( STR0002 ) // 'Modelo de dados de Tabela Temporária de Preço de Peça'
	oModel:GetModel( 'MODEL_VKZ' ):SetDescription( STR0003 ) // 'Dados de Tabela Temporária de Preço de Peça' 

	oModel:AddRules( 'MODEL_VKZ', 'VKZ_CODITE', 'MODEL_VKZ', 'VKZ_GRUITE', 3)

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'OFIA490' )
	Local oStruVKZ := FWFormStruct( 2, 'VKZ' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VKZ', oStruVKZ, 'MODEL_VKZ' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VKZ', 'TELA' )

Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.OFIA490' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.OFIA490' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.OFIA490' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.OFIA490' OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina Title STR0008 Action 'OA4900013_DelRegistros' OPERATION 5 ACCESS 0 // 'Excluir Reg. em Lote'

Return aRotina

/*/{Protheus.doc} OA4900013_DelRegistros
Exclusão de Registros através dos parametros
@author Rubens
@since 11/08/2023
@version 1.0

@type function
/*/
Function OA4900013_DelRegistros(cAlias,nReg,nOpc)

	local cSQLCommand := ""

	if ! Pergunte("OFIA490",.t.)
		Return .f.
	endif

	// Exclui registros vencidos
	cSQLCommand := "UPDATE " + RetSQLName("VKZ") +;
		" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " +;
		" WHERE VKZ_FILIAL = '" + xFilial("VKZ") + "'" +;
		  " AND VKZ_DATVAL BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'" +;
		  " AND VKZ_FORMUL BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" +;
		  " AND D_E_L_E_T_ = ' '"

	nRet := TCSQLExec(cSQLCommand)

Return (nRet >= 0)

/*/{Protheus.doc} OA4900013_DelRegistros
Exclusão dos registros vencidos ou exclusao de todos os registros
Funcao foi criada para possibilitar os clientes executarem a funcao apos atualizacao de preco de lista e assim fazer a limpeza completa da tabela temporaria de preço.
@author Rubens
@since 11/08/2023
@version 1.0

@type function
/*/
Function OA490DELVKZ(lSoVencidos)

	local cSQLCommand := ""

	Default lSoVencidos := .t.

	// Exclui registros vencidos
	cSQLCommand := "UPDATE " + RetSQLName("VKZ") +;
		" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " +;
		" WHERE VKZ_FILIAL = '" + xFilial("VKZ") + "'" +;
		iif(lSoVencidos , " AND VKZ_DATVAL <= '" + Dtos(dDataBase) + "'" , "" )+;
		" AND D_E_L_E_T_ = ' '"

	nRet := TCSQLExec(cSQLCommand)

Return (nRet >= 0)