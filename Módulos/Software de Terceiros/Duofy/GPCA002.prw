#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'GPCA002.ch'

/*/{Protheus.doc} GPCA002
Cadastro de Tanques

@author Duofy
@since 01/08/2025
@version 1.0
@type function
/*/

Function GPCA002()

	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'A60' )
	oBrowse:SetDescription( STR0001 )

	//adiciona legenda no Browser
	oBrowse:AddLegend( "A60_STATUS == '1' .and. (Empty(A60_DTDESA) .or. A60_DTDESA >= Date())"	, "GREEN"	, STR0012)
	oBrowse:AddLegend( "A60_STATUS == '2' .OR. A60_DTDESA < Date()"	, "RED" 	, STR0013)

	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina

@type function
@version 1.0
@author Rafael Brito
@since 01/07/2022
/*/
Static Function MenuDef()

	Local aRotina 		:= {}

	ADD OPTION aRotina Title STR0003	Action 'PesqBrw'          	OPERATION 01 ACCESS 0 //Pesquisar
	ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.GPCA002' 	OPERATION 02 ACCESS 0 //Visualizar
	ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.GPCA002' 	OPERATION 03 ACCESS 0 //Incluir
	ADD OPTION aRotina Title STR0006	Action 'VIEWDEF.GPCA002' 	OPERATION 04 ACCESS 0 //Alterar
	ADD OPTION aRotina Title STR0007	Action 'VIEWDEF.GPCA002' 	OPERATION 05 ACCESS 0 //Excluir
	ADD OPTION aRotina Title STR0008	Action 'VIEWDEF.GPCA002' 	OPERATION 08 ACCESS 0 //Imprimir

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados

@type function
@version 1.0
@author Rafael Brito
@since 01/07/2022
/*/
Static Function ModelDef()

	Local oStruA62 := FWFormStruct( 1, 'A60', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'GPCA002', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'A60MASTER', /*cOwner*/, oStruA62 )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0009 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "A60_FILIAL" , "A60_CODTAN" })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'A60MASTER' ):SetDescription( STR0010 )

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de visão

@type function
@version 1.0
@author Rafael Brito
@since 01/07/2022
/*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oStruA60 := FWFormStruct( 2, 'A60' )

	// Cria a estrutura a ser usada na View
	Local oModel   := FWLoadModel( 'GPCA002' )

	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_A60', oStruA60, 'A60MASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_A60', 'SUPERIOR' )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_A60', STR0010)

	// Define fechamento da tela
	oView:SetCloseOnOk( {||.T.} )

Return(oView)

/*/{Protheus.doc} GPCA4VA
Funcao para validar dados informado
- chamado na validacao de campo.

@author pablo
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GPCA4VA(cCampo, xContent)

	Local lRet			:= .T.

	If cCampo == "A60_CAPNOM"

		if FwFldGet("A60_CAPMAX") > 0 .AND. xContent > 0 .AND. xContent > FwFldGet("A60_CAPMAX")
			Help(" ",1,STR0011,,STR0002,3,1)
			lRet:= .F.
		EndIf

	Elseif cCampo == "A60_CAPMAX"

		If FwFldGet("A60_CAPMAX") > 0 .AND. xContent > 0 .AND. FwFldGet("A60_CAPNOM") > xContent
			Help(" ",1,STR0011,,STR0002,3,1)
			lRet:= .F.
		EndIf

	EndIf

Return lRet


