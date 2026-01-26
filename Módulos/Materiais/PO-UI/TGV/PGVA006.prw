#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PGVA006.CH"

//----------------------------------------------------------------------------------------
/*/{Protheus.doc} PGVA006
	Cadastro de Configurações de PDF Customizados (Utilizado no Portal Gestão de Vendas)
    @type function
	@author Squad CRM & Faturamento
	@since 25/11/2024
	@version 12.1.2410 ou Superior
/*/
//----------------------------------------------------------------------------------------
function PGVA006()
// 	local oMBrowse 	:= Nil

// 	oMBrowse := FWMBrowse():New()
// 	oMBrowse:SetAlias("AQ6")
// 	oMBrowse:SetDescription(STR0001) // "Configurações de PDF"
// 	oMBrowse:SetCanSaveArea(.T.)
// 	oMBrowse:SetMenudef("PGVA006")
// 	oMBrowse:SetTotalDefault("AQ6_FILIAL","COUNT", STR0002) // "Total de Registros"
// 	oMBrowse:Activate()
return nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
    Menu do Cadastro de Configurações de PDF Customizados
    @type function
    @version 12.1.2410 ou Superior
    @author Squad CRM & Faturamento
    @since 25/11/2024
    @return array, Lista de ações da rotina PGVA006
/*/
//-------------------------------------------------------------------------------
// static function MenuDef()
// 	local aRotina := {}
// 	ADD OPTION aRotina TITLE STR0003 	ACTION "PesqBrw"            OPERATION 1 ACCESS 0 // "Pesquisar"
// 	ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.PGVA006"    OPERATION 2 ACCESS 0 // "Visualizar"
// 	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.PGVA006'    OPERATION 3	ACCESS 0 // "Incluir"
// 	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.PGVA006'    OPERATION 4	ACCESS 0 // "Alterar"
// 	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.PGVA006'    OPERATION 5	ACCESS 0 // "Excluir"
// 	ADD OPTION aRotina TITLE STR0008	ACTION "VIEWDEF.PGVA006"    OPERATION 8 ACCESS 0 // "Imprimir"
// return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Modelo do Cadastro de Configurações de PDF Customizados
    @type function
    @version 12.1.2410 ou Superior
    @author	Squad CRM & Faturamento
    @since 25/11/2024
    @return	object, Model das entidades AQ6, AQ7 e AQ8
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local bPosVldMdl    := {|oModel| PGVA006TOK(oModel) }
	Local oStructAQ6    := FWFormStruct(1,'AQ6',/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAQ7    := FWFormStruct(1,'AQ7',/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAQ8    := FWFormStruct(1,'AQ8',/*bAvalCampo*/,/*lViewUsado*/)

	oModel:= MPFormModel():New('PGVA006',/*bPreValidacao*/, bPosVldMdl , /*{|oModel| PGVCommit(oModel) }*/,/*bCancel*/)
	oModel:AddFields('AQ6MASTER',/*cOwner*/, oStructAQ6,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid( 'AQ7DETAIL', 'AQ6MASTER', oStructAQ7 )
	oModel:AddGrid( 'AQ8DETAIL', 'AQ7DETAIL', oStructAQ8 )
	oModel:SetDescription(STR0001) // "Configurações de PDF"
	oModel:SetRelation( 'AQ7DETAIL', { { 'AQ7_FILIAL', 'FwxFilial( "AQ7" )' }, {'AQ7_IDCFG' , 'AQ6_ID' } }, AQ7->( IndexKey( 1 ) ) ) //AQ7_FILIAL+AQ7_IDCFG+AQ7_ID
	oModel:SetRelation( 'AQ8DETAIL', { { 'AQ8_FILIAL', 'FwxFilial( "AQ8" )' }, {'AQ8_IDCFG' , "AQ6_ID" }, {'AQ8_IDSECT', 'AQ7_ID' } }, AQ8->( IndexKey( 1 ) ) ) //AQ8_FILIAL+AQ8_IDCFG+AQ8_IDSECT+AQ8_ID
	oModel:GetModel( 'AQ7DETAIL' ):SetUniqueLine( { 'AQ7_ID' } ) //define o controle de linha unica
	oModel:GetModel( 'AQ8DETAIL' ):SetUniqueLine( { 'AQ8_ID' } ) //define o controle de linha unica
	oModel:GetModel('AQ6MASTER'):SetDescription(STR0001) // "Configurações de PDF"
	oModel:GetModel('AQ7DETAIL'):SetDescription(STR0009) // "Seções"
	oModel:GetModel('AQ8DETAIL'):SetDescription(STR0010) // "Campos"
return oModel

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Interface do modelo de dados do Cadastro de Configurações de PDF Customizados
	@type function
    @version 12.1.2410 ou Superior
    @author	Squad CRM & Faturamento
    @since 25/11/2024
    @return	object, View das entidades AQ6, AQ7 e AQ8
/*/
//-------------------------------------------------------------------------------
// static function ViewDef()
// 	Local oView
// 	Local oModel 		:= ModelDef()
// 	Local oStructAQ6	:= FWFormStruct(2,'AQ6',/*bAvalCampo*/,/*lViewUsado*/)
// 	Local oStructAQ7	:= FWFormStruct(2,'AQ7',/*bAvalCampo*/,/*lViewUsado*/)
// 	Local oStructAQ8	:= FWFormStruct(2,'AQ8',/*bAvalCampo*/,/*lViewUsado*/)
// 	oView := FWFormView():New()
// 	oView:SetModel(oModel)
// 	oView:AddField('VIEW_AQ6', oStructAQ6, 'AQ6MASTER')
// 	oView:AddGrid( 'VIEW_AQ7', oStructAQ7, 'AQ7DETAIL' )
// 	oView:AddGrid( 'VIEW_AQ8', oStructAQ8, 'AQ8DETAIL' )
// 	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
// 	oView:CreateHorizontalBox( 'MEIO'    , 40 )
// 	oView:CreateHorizontalBox( 'INFERIOR', 40 )
// 	oView:SetOwnerView( 'VIEW_AQ6', 'SUPERIOR' )
// 	oView:SetOwnerView( 'VIEW_AQ7', 'MEIO' )
// 	oView:SetOwnerView( 'VIEW_AQ8', 'INFERIOR' )
// 	oView:EnableTitleView('VIEW_AQ6')
// 	// Liga a identificacao do componente
// 	oView:EnableTitleView( 'VIEW_AQ7' )
// 	oView:EnableTitleView( 'VIEW_AQ8' )
// return oView

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PGVA006TOK
	Funcao de TudoOK da rotina para validar a chave duplicada
	@type function
    @version 12.1.2410 ou Superior
    @author	Squad CRM & Faturamento
    @since 25/11/2024
    @return	lOk, Logical, .T. o valor da chave não está duplicado
/*/
//-------------------------------------------------------------------------------
static function PGVA006TOK(oModel)
	Local aArea	     := {}
	Local aAreaAQ6	 := {}
	Local lOk        := .T. as Logical
	Local nOperation := oModel:GetOperation()
	Local cID        := oModel:GetValue( 'AQ6MASTER', 'AQ6_ID' ) as Character

	If (nOperation == MODEL_OPERATION_INSERT)
		aArea := GetArea()
		aAreaAQ6 := AQ6->(GetArea())

		If(ExistCPO("AQ6",cID,1))
			oModel:GetModel():SetErrorMessage(	'AQ6MASTER', ;
												'AQ6_ID' , ;
												'AQ6MASTER' , ;
												'AQ6_ID' , ;
												"PGVA006TOK", ;
												STR0011, ;	// "O ID já possui um registro cadastrado na tabela."
												STR0012)	// "Informe um novo ID."
			lOk := .F.
		EndIf
	EndIf

	restArea(aAreaAQ6)
	restArea(aArea)
	FWFreeObj(aAreaAQ6)
	FWFreeObj(aArea)
Return lOk
