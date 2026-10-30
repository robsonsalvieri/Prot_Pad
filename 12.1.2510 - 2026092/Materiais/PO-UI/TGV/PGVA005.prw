#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PGVA005.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PGVA005
	Cadastro de Filtros do Vendedor (Utilizado no Portal Gestão de Vendas)
    @type function
	@author Danilo Salve - Squad CRM & Faturamento
	@since 23/09/2022
	@version 12.1.2210 ou Superior
/*/
//-------------------------------------------------------------------------------
function PGVA005()
	// local oMBrowse 	:= Nil

	// oMBrowse := FWMBrowse():New()
	// oMBrowse:SetAlias("AQ4")
	// oMBrowse:SetDescription(STR0001) // "Filtros dos Vendedores"
	// oMBrowse:SetCanSaveArea(.T.)
	// oMBrowse:SetMenudef("PGVA005")
	// oMBrowse:SetTotalDefault("AQ4_FILIAL","COUNT", STR0002) // "Total de Registros"
	// oMBrowse:Activate()
return nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
    Menu de cadastro de filtro de vendedores offline
    @type function
    @version 12.1.2210 ou Superior
    @author Danilo Salve / Squad CRM & Faturamento
    @since 23/09/2022
    @return array, Lista de ações da rotina PGVA005
/*/
//-------------------------------------------------------------------------------
// static function MenuDef()
// 	local aRotina := {}
// 	ADD OPTION aRotina TITLE STR0003 	ACTION "PesqBrw"            OPERATION 1 ACCESS 0 // "Pesquisar"
// 	ADD OPTION aRotina TITLE STR0004	ACTION "VIEWDEF.PGVA005"    OPERATION 2 ACCESS 0 // "Visualizar"
// 	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.PGVA005'    OPERATION 3	ACCESS 0 // "Incluir"
// 	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.PGVA005'    OPERATION 4	ACCESS 0 // "Alterar"
// 	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.PGVA005'    OPERATION 5	ACCESS 0 // "Excluir"
// 	ADD OPTION aRotina TITLE STR0008	ACTION "VIEWDEF.PGVA005"    OPERATION 8 ACCESS 0 // "Imprimir"
// return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Modelo do cadastro de filtro de vendedores offline
    @type function
    @version 12.1.2210 ou Superior
    @author	Danilo Salve / Squad CRM & Faturamento
    @since 23/09/2022
    @return	object, Model das entidades AQ4 e AQ5
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local bPosVldMdl    := {|oModel| PGVA005TOK(oModel) }
	Local oStructAQ4    := FWFormStruct(1,'AQ4',/*bAvalCampo*/,/*lViewUsado*/)
	Local oStructAQ5    := FWFormStruct(1,'AQ5',/*bAvalCampo*/,/*lViewUsado*/)

	oModel:= MPFormModel():New('PGVA005',/*bPreValidacao*/, bPosVldMdl,{|oModel| PGVCommit(oModel) },/*bCancel*/)
	oModel:AddFields('AQ4MASTER',/*cOwner*/, oStructAQ4,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid( 'AQ5DETAIL', 'AQ4MASTER', oStructAQ5 )
	oModel:SetDescription(STR0001) // // "Filtros dos Vendedores"
	oModel:SetRelation( 'AQ5DETAIL', { { 'AQ5_FILIAL', 'FwxFilial( "AQ5" )' }, {'AQ5_UUID', 'AQ4_UUID' } }, AQ5->( IndexKey( 1 ) ) ) //AQ5_FILIAL, AQ5_UUID, AQ5_ITEM, , AQ5_CODENT
	oModel:GetModel( 'AQ5DETAIL' ):SetUniqueLine( { 'AQ5_CODENT' } ) //define o controle de linha unica
	oModel:GetModel('AQ4MASTER'):SetDescription(STR0001) // "Filtros dos Vendedores"
	oModel:GetModel('AQ5DETAIL'):SetDescription(STR0009) // "Itens do filtro"
return oModel

//-------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Interface do modelo de dados de do cadastro de filtro de vendedores offline
	@type function
    @version 12.1.2210 ou Superior
    @author	Danilo Salve / Squad CRM & Faturamento
    @since 23/09/2022
    @return	object, Model das entidades AQ4 e AQ5
/*/
//-------------------------------------------------------------------------------
// static function ViewDef()
// 	Local oView
// 	Local oModel 		:= ModelDef()
// 	Local oStructAQ4	:= FWFormStruct(2,'AQ4',/*bAvalCampo*/,/*lViewUsado*/)
// 	Local oStructAQ5	:= FWFormStruct(2,'AQ5',/*bAvalCampo*/,/*lViewUsado*/)

// 	oView := FWFormView():New()
// 	oView:SetModel(oModel)
// 	oView:AddField('VIEW_AQ4', oStructAQ4,'AQ4MASTER')
// 	oView:AddGrid( 'VIEW_AQ5', oStructAQ5, 'AQ5DETAIL' )

// 	oView:GetViewStruct('VIEW_AQ4'):SetProperty('AQ4_UUID', MVC_VIEW_CANCHANGE, .F. )

// 	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
// 	oView:CreateHorizontalBox( 'INFERIOR', 80 )

// 	oView:SetOwnerView( 'VIEW_AQ4', 'SUPERIOR' )
// 	oView:SetOwnerView( 'VIEW_AQ5', 'INFERIOR' )

// 	oView:AddIncrementField( 'VIEW_AQ5', 'AQ5_ITEM' )
// 	oView:EnableTitleView('VIEW_AQ5')
// 	// Liga a identificacao do componente
// 	oView:EnableTitleView( 'VIEW_AQ4' )
// 	oView:EnableTitleView( 'VIEW_AQ5' )
// return oView

//-------------------------------------------------------------------------------
/*/{Protheus.doc} onInitUUID
	Inicializador padrão do campo AQ4_UUID
	@type function
	@version  12.1.2210
	@author Danilo Salve / Squad CRM & Faturamento
	@since 23/09/2022
	@param cUuid, character, Código UUID
	@return character, UUID válido
/*/
//-------------------------------------------------------------------------------
function onInitUUID(cUuid)
	Local aArea		:= GetArea()
	Local aAreaAQ4	:= AQ4->(GetArea())

	Default cUuid	:= FWUUIDV4(.T.)

	DbSelectArea("AQ4")
	AQ4->(DbSetOrder(1)) // AQ4_FILIAL, AQ4_UUID

	While AQ4->(DbSeek(FwXFilial("AQ4") + cUuid))
		cUuid := FWUUIDV4(.T.)
	Enddo

	restArea(aAreaAQ4)
	restArea(aArea)

	aSize(aAreaAQ4, 0)
	aSize(aArea, 0)
return cUuid

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PGVA005TOK
	Avalia se o filtro do vendedor pode ser gravado
	@type function
	@version 12.1.2210
	@author Danilo Salve / Squad CRM & Faturamento
	@since 23/09/2022
	@param oModel, object, Modelo de dados utilizado para o CRUD da rotina PGVA005
	@return logical, permite salvar o filtro
/*/
//-------------------------------------------------------------------------------
function PGVA005TOK(oModel)
	Local aArea			:= {}
	Local aAreaAQ4		:= {}
	Local lOk			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local cVendedor		:= oModel:GetValue( 'AQ4MASTER', 'AQ4_VEND' )
	Local cSchema		:= oModel:GetValue( 'AQ4MASTER', 'AQ4_SCHEMA' )
	Local cData			:= oModel:GetValue( 'AQ4MASTER', 'AQ4_DATA' )
	local cFilialAQ4	:= FwXFilial("AQ4")

	If nOperation == MODEL_OPERATION_INSERT
		aArea := GetArea()
		aAreaAQ4 := AQ4->(GetArea())

		DbSelectArea("AQ4")
		AQ4->(DbSetOrder(2)) // AQ4_FILIAL, AQ4_VEND, AQ4_SCHEMA, AQ4_DATA

		If AQ4->(DbSeek(cFilialAQ4 + cVendedor + cSchema + dtos(cData)))
			lOk := .F.
			oModel:SetErrorMessage("", "AQ4_VEND", oModel:GetId() , "", "PGVA005TOK",;
				STR0010,; // "O Vendedor já possui um filtro cadastrado para a data informada!"
				STR0011) // Informe um novo Vendedor ou Altere o Filtro já existente.
		Endif

		restArea(aArea)
		restArea(aAreaAQ4)
		aSize(aAreaAQ4, 0)
		aSize(aArea, 0)
	Endif
return lOk

//-------------------------------------------------------------------------------
/*/{Protheus.doc} PGVCommit
	Avalia se o commit deve ser complementado
	@type function
	@version 12.1.2210
	@author Gabriel Oliveira dos Santos / Squad CRM & Faturamento
	@since 25/04/2023
	@param oModel, object, Modelo de dados
	@return Logical, lCommit
/*/
//-------------------------------------------------------------------------------
Static Function PGVCommit(oModel)

	Local cVendedor	 := oModel:GetValue( 'AQ4MASTER', 'AQ4_VEND' )		As Character
	Local cSchema	 := oModel:GetValue( 'AQ4MASTER', 'AQ4_SCHEMA' )	As Character
	Local cSchemaCl  := "000002"										As Character
	Local aCliSUS	 := {}												As Array
	Local lOk		 := .F.												As Logical 
	Local lCommit	 := .F. 											As Logical
	Local nOperation := oModel:GetOperation()                           As Numeric
	
	Do Case 
	Case cSchema == "000016" 
		If !(nOperation == MODEL_OPERATION_DELETE)
			aCliSUS := CheckCliSUS(oModel)
		EndIf
		lCommit := FWFormCommit(oModel)
		If !EMPTY(aCliSUS)
			lOk := WriteFilterOffLine(cVendedor,cSchemaCl,aCliSUS)		
		EndIf 
	Otherwise
		lCommit := FWFormCommit(oModel)
	EndCase 

	FWFreeObj(aCliSUS)

Return lCommit 

//-------------------------------------------------------------------------------
/*/{Protheus.doc} CheckCliSUS
	Checa os items da SUS que possuem Cliente
	@type function
	@version 12.1.2210
	@author Gabriel Oliveira dos Santos / Squad CRM & Faturamento
	@since 25/04/2023
	@param oModel, object, Modelo de dados
	@return Array, permite salvar o filtro
/*/
//-------------------------------------------------------------------------------
Static Function CheckCliSUS(oModel)

	Local aArea		:= {}							As Array
	Local aAreaSUS	:= {}							As Array
	Local cCodEnt	:= ""							As Character
	Local cCodEntSUS:= ""							As Character
	Local cFilialSUS:= FwXFilial("SUS")				As Character
	Local aCliSUS	:= {}							As Array 	
	Local nItemSUS	:= 0							As Numeric 
	Local oModelDet := NIL							As Object
	Local cOrCliPD  := SuperGetMV("MV_ORCLIPD")		As Character
	
	oModelDet := FWModelActivate()

	oModelDet := oModel:GetModel('AQ5DETAIL')	
 
	aArea	 := GetArea()
	aAreaSUS := SUS->(GetArea())

	DbSelectArea("SUS")
	SUS->(DbSetOrder(1)) // US_FILIAL,US_COD,US_LOJA                                                                                                                                        

	For nItemSUS := 1 to oModelDet:length()
		oModelDet:GoLine(nItemSUS)
		cCodEnt := oModel:GetValue( 'AQ5DETAIL', 'AQ5_CODENT' )
		If SUS->(DbSeek(cFilialSUS + cCodent))
			If !EMPTY(SUS->US_CODCLI) .AND. !EMPTY(SUS->US_LOJACLI)
				cCodEntSUS := US_CODCLI+US_LOJACLI
			ElseIf !EMPTY(cOrCliPD)
				cCodEntSUS := cOrCliPD
			Else 
				cCodEntSUS := ""
			EndIf 
			If !EMPTY(cCodEntSUS) .AND. aScan(aCliSUS, {|cCodigo|cCodigo == cCodEntSUS}) == 0 
				AADD(aCliSUS,cCodEntSUS)			
			EndIf
		Endif
	Next nItemSUS
	
	restArea(aArea)
	restArea(aAreaSUS)
	FWFreeObj(aAreaSUS)
	FWFreeObj(aArea)

Return aCliSUS
