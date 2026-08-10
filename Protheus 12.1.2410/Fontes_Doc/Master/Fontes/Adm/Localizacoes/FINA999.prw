#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA999.CH'

PUBLISH MODEL REST NAME FINA999

/*/{Protheus.doc} FINA999
	Fuente de Modelo de Datos de Orden de Pago
	@author 	arodriguez
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/
 
Function FINA999()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	arodriguez
@since 		16/05/2025
@version	12.1.2310 / Superior
/*/

Static Function BrowseDef()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('FJR')
	oBrowse:SetDescription(STR0001)	// "Órdenes de Pago"

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	arodriguez
@since 		16/05/2025
@version	12.1.2310 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FINA999' OPERATION 1 ACCESS 0	// 'Buscar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FINA999' OPERATION 2 ACCESS 0	// 'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FINA999' OPERATION 3 ACCESS 0 	// 'Registrar Pago'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FINA999' OPERATION 4 ACCESS 0 	// 'Anticipo'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FINA999' OPERATION 6 ACCESS 0	// 'Tipo de Cambio'

Return aRotina

/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados
	@author 	arodriguez
	@return		oModel objeto del Modelo
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/

Static Function ModelDef()
Local oModel        := Nil
Local oStruEOP		:= FWFormModelStruct():New()
Local oStruDOP		:= FWFormModelStruct():New()
Local oStruFJR		:= FWFormStruct(1, 'FJR', , .F.)
Local oStruSEK		:= FWFormStruct(1, 'SEK', , .F.)
Local oStruSE2		:= FWFormStruct(1, 'SE2', , .F.)
Local oStruPAG		:= FWFormStruct(1, 'SEK', , .F.)
Local oMdlEvent		:= FINV999():New()
Local oBcoEvent		:= F999BCO():New()
Local nLenDesMoe	:= F999LnDesM()

    oModel := MPFormModel():New( 'FINA999',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

	//Encabezado OP
	oStruEOP:AddTable('' , { '' } , "ENCABEZADOOP", {|| ''})
	oStruEOP:AddField(STR0008	, STR0008	, 'NNUMORDENS'	, 'N' , 3, 0)		// "Órdenes de pago:"
	oStruEOP:AddField(STR0009	, STR0009	, 'NVALORDENS'	, 'N' , 16, 2)		// "Total por pagar:"
	oStruEOP:AddField(STR0010	, STR0010	, 'CMOEDA'		, 'C' , nLenDesMoe)	// "Mostrar valores en:"
	oStruEOP:AddField(STR0011	, STR0011	, 'CPGTOELT'	, 'C' , 2)			// "¿Pago Elect.?"
	oStruEOP:AddField('NMOEDA'	, 'NMOEDA'	, 'NMOEDA'		, 'N' , 2)
	oStruEOP:AddField('PA'		, 'PA'		, 'PA'			, 'L' , 1)

	//Detalle OP
	oStruDOP:AddTable('' , { '' } , "DETALLEOP", {|| ''})
	oStruDOP:AddField(' '		, 'Marca'	, 'MARK'		, 'N' , 1, 0)
	oStruDOP:AddField(STR0019   , STR0019	, 'FORNECE'		, 'C' , GetSx3Cache("EK_FORNECE","X3_TAMANHO"), 0)	// "Proveedor"
	oStruDOP:AddField(STR0020   , STR0020	, 'LOJA'		, 'C' , GetSx3Cache("EK_LOJA","X3_TAMANHO"), 0)	// "Tienda"
	oStruDOP:AddField(STR0021	, STR0021	, 'NOMBRE'		, 'C' , GetSx3Cache("A2_NOME","X3_TAMANHO"), 0)	// "Nombre"
	oStruDOP:AddField(STR0023	, STR0023	, 'FACTURAS'	, 'N' , 16, 2)		// "Facturas"
	oStruDOP:AddField(STR0024	, STR0024	, 'DESCUENTO'	, 'N' , 16, 2)		// "Desc./Comp."
	oStruDOP:AddField(STR0025	, STR0025	, 'TOTAL'		, 'N' , 16, 2)		// "Total pagar"
	oStruDOP:AddField(STR0012	, STR0012	, 'NPORDESC'	, 'N' , 5, 2)		// "%Desc."
	oStruDOP:AddField(STR0013	, STR0013	, 'NVALDESC'	, 'N' , 12, 2)		// "Valor del descuento"
	oStruDOP:AddField(STR0014	, STR0014	, 'NVLRPAGAR'	, 'N' , 16, 2)		// "Inf.Valor por Pagar"
	oStruDOP:AddField(STR0015	, STR0015	, 'CNATUREZA'	, 'C' , GetSx3Cache("FJR_NATURE","X3_TAMANHO"), 0)	// "Modalidad"
	oStruDOP:AddField(STR0016	, STR0016	, 'NSALDOPGOP'	, 'N' , 16, 2)		// "Saldo ($):"
	oStruDOP:AddField(STR0017	, STR0017	, 'NTOTDOCTERC'	, 'N' , 16, 2)		// "Documentos de terceros:"
	oStruDOP:AddField(STR0018	, STR0018	, 'NTOTDOCPROP'	, 'N' , 16, 2)		// "Documentos propios:"

	oStruSE2:AddField('SALDO1'	, 'SALDO1'	, 'SALDO1'	, 'N' , 16, 2)
	oStruSE2:AddField('RECNO'	, 'RECNO'	, 'RECNO'	, 'N' , 16, 2)

    oModel:addFields('FJR_MASTER',,oStruFJR)				// Encabezado
    oModel:addGrid('SEK_DETAIL','FJR_MASTER',oStruSEK,,)	// OP a generar
    oModel:addGrid('SE2_DETAIL','FJR_MASTER',oStruSE2,,)	// Títulos
	oModel:addGrid('PAG_DETAIL','FJR_MASTER',oStruPAG,,)	// Documentos propios

	//Modelos que deben ir a la vista o a un modelo principal que llame al modelo FINA999 con el objetivo de poder incluir varios registros en la tabla FJR en un pago automático Encabezado OP y Detalle de OP
	oModel:addGrid('EOP_DETAIL','FJR_MASTER',oStruEOP)
	oModel:addGrid('DOP_DETAIL','FJR_MASTER',oStruDOP)

	oModel:SetRelation('SE2_DETAIL', { { 'E2_FILIAL', 'XFilial("SE2")' }, { 'E2_ORDPAGO', 'FJR_ORDPAG' } }, SE2->(IndexKey(8)) )

    oModel:SetRelation('PAG_DETAIL', { { 'EK_FILIAL', 'FWxFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
	oModel:GetModel('PAG_DETAIL'):SetLoadFilter(,"EK_TIPODOC NOT IN ('TB','PA','RG','RB','RI','RS')" )

	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel('SEK_DETAIL'):SetOptional(.T.)
	oModel:GetModel('SE2_DETAIL'):SetOptional(.T.)
	oModel:GetModel('PAG_DETAIL'):SetOptional(.T.)
	oModel:GetModel('EOP_DETAIL'):SetOptional(.T.)
	oModel:GetModel('DOP_DETAIL'):SetOptional(.T.)

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('FJR_MASTER'):SetOnlyQuery(.F.)
	oModel:GetModel('SEK_DETAIL'):SetOnlyQuery(.F.)
	oModel:GetModel('SE2_DETAIL'):SetOnlyQuery(.F.)
	oModel:GetModel('PAG_DETAIL'):SetOnlyQuery(.F.)
	oModel:GetModel('EOP_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('DOP_DETAIL'):SetOnlyQuery(.T.)

	oStruPAG:SetProperty( '*'			, 	MODEL_FIELD_OBRIGAT,	.F. )
	oStruSEK:SetProperty( '*'			, 	MODEL_FIELD_OBRIGAT,	.F. )
	oStruSE2:SetProperty( '*'			, 	MODEL_FIELD_OBRIGAT,	.F. )
	oStruFJR:SetProperty( '*'			, 	MODEL_FIELD_OBRIGAT,	.F. )

	//Evento del Modelo
	oModel:InstallEvent("FINV999"	,/*cOwner*/,oMdlEvent)
	oModel:InstallEvent("F999BCO"	,/*cOwner*/,oBcoEvent)

Return oModel

/*/{Protheus.doc} ViewDef
	Interfce del modelo de datos de Cobros Diversos para localización padrón
	@return		oView objeto del View
	@author 	arodriguez
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/
Static Function ViewDef()
Local oModel	:= FWLoadModel('FINA999')
Local oView		:= FWFormView():New()
Local oStruEOP	:= FWFormViewStruct():New()
Local oStruDOP	:= FWFormViewStruct():New()
local oStruFJR  := FWFormStruct(2, 'FJR', , .T.)
local oStruSEK  := FWFormStruct(2, 'SEK', , .T.)
local oStruSE2  := FWFormStruct(2, 'SE2', , .T.)
local oStruPAG  := FWFormStruct(2, 'SEK', , .T.)

	SetFunName("FINA999")
	
	oView:SetModel(oModel)

	oView:SetContinuousForm(.T.)

	oStruEOP:AddField('NNUMORDENS', '1', STR0008	, STR0008	, NIL, 'GET', , , , .F.) // "Órdenes de pago:"
	oStruEOP:AddField('NVALORDENS', '2', STR0009	, STR0009	, NIL, 'GET', , , , .F.) // "Total por pagar:"
	oStruEOP:AddField('CMOEDA'	  , '3', STR0010	, STR0010	, NIL, 'GET', , , , .T.) // "Mostrar valores en:"
	oStruEOP:AddField('CPGTOELT'  , '4', STR0011	, STR0011	, NIL, 'GET', , , , .T.) // "¿Pago Elect.?"
	
	oStruDOP:AddField('MARK'      	 , '1' , 'MARK'	    , 'MARK'	, NIL, 'GET', , , , .T.)
	oStruDOP:AddField('FORNECE'      , '2' , STR0019	, STR0019	, NIL, 'GET', , , , .F.) // "Proveedor"
	oStruDOP:AddField('LOJA'         , '3' , STR0020	, STR0020	, NIL, 'GET', , , , .F.) // "Tienda"
	oStruDOP:AddField('NOMBRE'       , '4' , STR0021	, STR0021	, NIL, 'GET', , , , .F.) // "Nombre"
	oStruDOP:AddField('FACTURAS'     , '5' , STR0023	, STR0023	, NIL, 'GET', , , , .F.) // "Facturas"
	oStruDOP:AddField('DESCUENTO'    , '6' , STR0024	, STR0024	, NIL, 'GET', , , , .F.) // "Desc./Comp."
	oStruDOP:AddField('TOTAL'        , '7' , STR0025	, STR0025	, NIL, 'GET', , , , .F.) // "Total pagar"
	oStruDOP:AddField('NPORDESC'     , '8' , STR0012	, STR0012	, NIL, 'GET', , , , .T.) // "%Desc."
	oStruDOP:AddField('NVALDESC'     , '9' , STR0013	, STR0013	, NIL, 'GET', , , , .T.) // "Valor del descuento"
	oStruDOP:AddField('NVLRPAGAR'    , '10', STR0014	, STR0014	, NIL, 'GET', , , , .F.) // "Inf.Valor por Pagar"
	oStruDOP:AddField('CNATUREZA'    , '11', STR0015	, STR0015	, NIL, 'GET', , , , .T.) // "Modalidad"
	oStruDOP:AddField('NSALDOPGOP'   , '12', STR0016	, STR0016	, NIL, 'GET', , , , .F.) // "Saldo ($):"
	oStruDOP:AddField('NTOTDOCTERC'  , '13', STR0017	, STR0017	, NIL, 'GET', , , , .F.) // "Documentos de terceros:"
	oStruDOP:AddField('NTOTDOCPROP'  , '14', STR0018	, STR0018	, NIL, 'GET', , , , .F.) // "Documentos propios:"

	oStruFJR:SetProperty( '*', 	MVC_VIEW_FOLDER_NUMBER, '')
	oStruFJR:SetProperty( '*', 	MVC_VIEW_GROUP_NUMBER , '')

	oStruFJR:aFolders := {}
	oStruFJR:aGroups := {}


	oView:AddGrid('VIEW_EOP' , oStruEOP, 'EOP_DETAIL' )
	oView:AddGrid('VIEW_DOP'  , oStruDOP, 'DOP_DETAIL' )

	oView:AddField('VIEW_FJR' , oStruFJR, 'FJR_MASTER' )
	oView:AddGrid('VIEW_SEK'  , oStruSEK, 'SEK_DETAIL')
	oView:AddGrid('VIEW_SE2'  , oStruSE2, 'SE2_DETAIL')
	oView:AddGrid('VIEW_PAG'  , oStruPAG, 'PAG_DETAIL')

	oView:CreateHorizontalBox( 'INI1', 15)
	oView:CreateHorizontalBox( 'INI2', 15)

	oView:CreateHorizontalBox( 'CIMA', 20)
	oView:CreateHorizontalBox( 'MEDIO', 20)
	oView:CreateHorizontalBox( 'BAIXO', 30)

	oView:CreateFolder("FOLDER","BAIXO")
	
	oView:AddSheet( 'FOLDER', 'SHEET_SE2', "Títulos" )
	oView:AddSheet( 'FOLDER', 'SHEET_PAG', "Formas de Pago" )
	
	oView:CreateHorizontalBox( 'BAIXO1', 100, , , 'FOLDER', 'SHEET_SE2')
	oView:CreateHorizontalBox( 'BAIXO2', 100, , , 'FOLDER', 'SHEET_PAG')

	oView:SetViewProperty('VIEW_SE2', 'SETGRIDLINES', {12}) //Títulos
	oView:SetViewProperty('VIEW_PAG', 'SETGRIDLINES', {12}) //Formas de pago
	
	oView:SetOwnerView('VIEW_EOP', 'INI1')
	oView:SetOwnerView('VIEW_DOP', 'INI2')

	oView:SetOwnerView('VIEW_FJR', 'CIMA')
	oView:SetOwnerView('VIEW_SEK', 'MEDIO')
	oView:SetOwnerView('VIEW_SE2', 'BAIXO1')
	oView:SetOwnerView('VIEW_PAG', 'BAIXO2')

	//Habilitando título
	oView:EnableTitleView('VIEW_EOP',"Encabezado OP")
	oView:EnableTitleView('VIEW_DOP',"Detalle OP")
	oView:EnableTitleView('VIEW_FJR',"Encabezado OP")
	oView:EnableTitleView('VIEW_SEK',"Detalle OP")
	oView:EnableTitleView('VIEW_SE2',"Títulos")
	oView:EnableTitleView('VIEW_PAG',"Formas de Pago")
	oView:SetDescription("Orden de Pago")

Return oView

/*/{Protheus.doc} F999LnDesM
	Función Tamaño del nombre de las monedas
	@author 	carlos.espinoza
	@since 		18/08/2025
	@version	12.1.2410 / Superior
	@Param
	@Return 
		nLen - numerico - tamaño del nombre de la moneda más larga
/*/
Function F999LnDesM()
Local nQtMoedas		:= Moedfin()
Local nX			:= 0
Local nLen			:= 20
Local nLenAux		:= 0
Local cMoeda		:= ""

	For nX := 1 To nQtMoedas
		cMoeda := Str(nX,IIf(nX <= 9,1,2))
		nLenAux := Len(AllTrim(SuperGetMv("MV_MOEDA" + cMoeda, .F., "")))
		If nLen < nLenAux
			nLen := nLenAux
		EndIf
	Next

Return nLen
