#include 'totvs.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'fina999.ch'

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
Local oStruMOE		:= FWFormModelStruct():New()
Local oStruSOP		:= FWFormModelStruct():New()
Local oStruFJR		:= FWFormStruct(1, 'FJR', , .F.)
Local oStruSE2		:= FWFormStruct(1, 'SE2', , .F.)
Local oStruPAG		:= FWFormStruct(1, 'SEK', , .F.)
Local oStruTTB		:= FWFormStruct(1, 'SEK', , .F.)
Local oMdlEvent		:= FINV999():New()
Local oBcoEvent		:= F999BCO():New()
Local oFinEvent		:= F999FIN():New()
Local oPGOEvent		:= F999PGO():New()
Local oPAEvent		:= F999PA():New()
Local nLenDesMoe	:= F999LnDesM()
Local nTamNumOp		:= 7
Local aAreaSEK 		:= GetArea()
Local nPosTTB		:= oStruTTB:GetFieldPos("EK_TIPODOC")

	If SEK->(ColumnPos("EK_NUMOPER")) > 0
		nTamNumOp := GetSx3Cache("EK_NUMOPER","X3_TAMANHO")
	EndIf

    oModel := MPFormModel():New('FINA999',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

	//Encabezado OP
	oStruEOP:AddTable('' , { 'NNUMORDENS' } , "ENCABEZADOOP", {|| ''})
	oStruEOP:AddField(STR0008	, STR0008	, 'NNUMORDENS'	, 'N' , 3, 0)		// "Órdenes de pago:"
	oStruEOP:AddField(STR0009	, STR0009	, 'NVALORDENS'	, 'N' , 16, 2)		// "Total por pagar:"
	oStruEOP:AddField(STR0010	, STR0010	, 'CMOEDA'		, 'C' , nLenDesMoe)	// "Mostrar valores en:"
	oStruEOP:AddField(STR0011	, STR0011	, 'CPGTOELT'	, 'C' , 2)			// "¿Pago Elect.?"
	oStruEOP:AddField('NMOEDA'	, 'NMOEDA'	, 'NMOEDA'		, 'N' , 2)			// "nMoedaCor"
	oStruEOP:AddField('PA'		, 'PA'		, 'PA'			, 'L' , 1)			// "Indica si es pantalla de pago anticipado"
	oStruEOP:AddField('NPAGAR'	, 'NPAGAR'	, 'NPAGAR'		, 'N' , 1, 0)		// "Indica el método de pago"
	oStruEOP:AddField('COTIZ'	, 'COTIZ'	, 'COTIZ'		, 'C' , 255)		// "Cotización original"
	oStruEOP:AddField('PREORD'	, 'PREORD'	, 'PREORD'		, 'L' , 1)			// "Indica si la orden de pago es una orden previa"
	oStruEOP:AddField('PROCCCR'	, 'PROCCCR'	, 'PROCCCR'		, 'L' , 1)			// "Flag de transmisión AFIP"
	oStruEOP:AddField('CAPROV'	, 'CAPROV'	, 'CAPROV'		, 'C' , 50)			// "Valor para el campo E2_CODAPRO"
	oStruEOP:AddField('HASERROR', 'HASERROR', 'HASERROR'	, 'L' , 1)			// "Indica si la Orden de Pago tiene algún error en el commit"

	//Detalle OP
	oStruFJR:AddField(' '		, 'Marca'	, 'MARK'		, 'N' , 1, 0)
	oStruFJR:AddField(STR0021	, STR0021	, 'NOMBRE'		, 'C' , GetSx3Cache("A2_NOME","X3_TAMANHO"))	// "Nombre"
	oStruFJR:AddField(STR0023	, STR0023	, 'FACTURAS'	, 'N' , 16, 2)		// "Facturas"
	oStruFJR:AddField(STR0024	, STR0024	, 'DESCUENTO'	, 'N' , 16, 2)		// "Desc./Comp."
	oStruFJR:AddField(STR0025	, STR0025	, 'TOTAL'		, 'N' , 16, 2)		// "Total pagar"
	oStruFJR:AddField(STR0012	, STR0012	, 'NPORDESC'	, 'N' , 5, 2)		// "%Desc."
	oStruFJR:AddField(STR0013	, STR0013	, 'NVALDESC'	, 'N' , 12, 2)		// "Valor del descuento"
	oStruFJR:AddField(STR0014	, STR0014	, 'NVLRPAGAR'	, 'N' , 16, 2)		// "Inf.Valor por Pagar"
	oStruFJR:AddField(STR0016	, STR0016	, 'NSALDOPGOP'	, 'N' , 16, 2)		// "Saldo ($):"
	oStruFJR:AddField(STR0017	, STR0017	, 'NTOTDOCTERC'	, 'N' , 16, 2)		// "Documentos de terceros:"
	oStruFJR:AddField(STR0018	, STR0018	, 'NTOTDOCPROP'	, 'N' , 16, 2)		// "Documentos propios:"
	oStruFJR:AddField('CLIQUID'	, 'CLIQUID'	, 'CLIQUID'		, 'C' , GetSx3Cache("E5_NUMLIQ","X3_TAMANHO"))		// "Número de liquidación"
	oStruFJR:AddField('CIDPROC'	, 'CIDPROC'	, 'CIDPROC'		, 'C' , GetSx3Cache("FKA_IDPROC","X3_TAMANHO"))		// "Id de proceso FKA"
	oStruFJR:AddField('NUMOP'	, 'NUMOP'	, 'NUMOP'		, 'C' , nTamNumOp)	// "Número de operación"
	oStruFJR:AddField('TES'		, 'TES'		, 'TES'			, 'C' , GetSx3Cache("F4_CODIGO","X3_TAMANHO"))		// "Tipo de entrada/salida"
	oStruFJR:AddField('PROVIN'	, 'PROVIN'	, 'PROVIN'		, 'C' , GetSx3Cache("A2_EST","X3_TAMANHO"))			// "Provincia"
	oStruFJR:AddField('TOTANT'	, 'TOTANT'	, 'TOTANT'		, 'N' , 16, 2)										// "Total anterior"
	oStruFJR:AddField('VALORIG'	, 'VALORIG'	, 'VALORIG'		, 'N' , 16, 2)	    // "Valor Original"

	oStruSE2:AddField('SALDO1'	, 'SALDO1'	, 'SALDO1'	, 'N' , 16, 2)
	oStruSE2:AddField('RECNO'	, 'RECNO'	, 'RECNO'	, 'N' , 16, 0)

	oStruPAG:AddField('RECSEF'	, 'RECSEF'	, 'RECSEF'	, 'N' , 16, 0)

	oStruMOE:AddTable('' , { '' } 	, "MONEDAS", {|| ''})
	oStruMOE:AddField('Moneda' 		, 'Moneda'		, 'MONEDA' 	, 'C' , 1)
	oStruMOE:AddField('Desc. Moneda', 'Desc. Moneda', 'DESC' 	, 'C' , nLenDesMoe)
	oStruMOE:AddField('Tasa' 		, 'Tasa' 		, 'TASA' 	, 'N' , 10, 4)
	oStruMOE:AddField('Picture' 	, 'Picture' 	, 'PICT' 	, 'C' , 30)

	oStruSOP:AddTable('' , { '' } 	, "SALDOSOP", {|| ''})
	oStruSOP:AddField('Orden Pago' 	, 'Orden Pago'	, 'ORDPAGO' , 'C' , GetSx3Cache("FJR_ORDPAG","X3_TAMANHO"))
	oStruSOP:AddField('Moneda' 		, 'Moneda'		, 'MONEDA' 	, 'N' , 2, 0)
	oStruSOP:AddField('Saldo'	 	, 'Saldo' 		, 'SALDO' 	, 'N' , 16, 2)

	oModel:addFields('EOP_MASTER',,oStruEOP)
    oModel:addGrid('FJR_MASTER','EOP_MASTER',oStruFJR)		// Encabezado
	oModel:addGrid('TTB_DETAIL','EOP_MASTER',oStruTTB)		// Títulos de Baja
    oModel:addGrid('SE2_DETAIL','EOP_MASTER',oStruSE2)		// Títulos
	oModel:addGrid('PAG_DETAIL','EOP_MASTER',oStruPAG)		// Documentos propios
	oModel:addGrid('MOE_DETAIL','EOP_MASTER',oStruMOE)		// Tasa monedas
	oModel:addGrid('SOP_DETAIL','EOP_MASTER',oStruSOP)		// Saldos de Orden de Pago
	
	oModel:SetRelation('SE2_DETAIL', { { 'E2_FILIAL', 'FWxFilial("SE2")' }, { 'E2_ORDPAGO', 'FJR_ORDPAG' } }, SE2->(IndexKey(8)) )

    oModel:SetRelation('PAG_DETAIL', { { 'EK_FILIAL', 'FWxFilial("SEK")' }, { 'EK_ORDPAGO', 'FJR_ORDPAG' } }, SEK->(IndexKey(1)) )
	oModel:GetModel('PAG_DETAIL'):SetLoadFilter(,"EK_TIPODOC NOT IN ('TB','PA','RG','RB','RI','RS')" )

	// Indica que es opcional tener datos informados en el grid
	oModel:GetModel('FJR_MASTER'):SetOptional(.T.)
	oModel:GetModel('SE2_DETAIL'):SetOptional(.T.)
	oModel:GetModel('PAG_DETAIL'):SetOptional(.T.)
	oModel:GetModel('TTB_DETAIL'):SetOptional(.T.)
	oModel:GetModel('MOE_DETAIL'):SetOptional(.T.)
	oModel:GetModel('SOP_DETAIL'):SetOptional(.T.)

	//Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('EOP_MASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('SE2_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('PAG_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('MOE_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('SOP_DETAIL'):SetOnlyQuery(.T.)

	oStruTTB:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruPAG:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruSE2:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
	oStruFJR:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )

	If nPosTTB > 0 .And. Len(oStruTTB:aFields[nPosTTB][MODEL_FIELD_VALUES]) == 3
		AADD(oStruTTB:aFields[nPosTTB][MODEL_FIELD_VALUES], "TB=TB")
		AADD(oStruTTB:aFields[nPosTTB][MODEL_FIELD_VALUES], "RG=RG")
	EndIf

	//Evento del Modelo
	oModel:InstallEvent("FINV999"	,/*cOwner*/,oMdlEvent)
	oModel:InstallEvent("F999FIN"	,/*cOwner*/,oFinEvent)
	oModel:InstallEvent("F999PGO"	,/*cOwner*/,oPGOEvent)
	oModel:InstallEvent("F999BCO"	,/*cOwner*/,oBcoEvent)
	oModel:InstallEvent("F999PA"	,/*cOwner*/,oPAEvent)

	RestArea(aAreaSEK)

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
local oStruFJR  := FWFormStruct(2, 'FJR', , .T.)
local oStruSE2  := FWFormStruct(2, 'SE2', , .T.)
local oStruPAG  := FWFormStruct(2, 'SEK', , .T.)
local oStruTTB  := FWFormStruct(2, 'SEK', , .T.)

	SetFunName("FINA999")
	
	oView:SetModel(oModel)

	oView:SetContinuousForm(.T.)

	oStruEOP:AddField('NNUMORDENS', '1', STR0008	, STR0008	, NIL, 'GET', , , , .F.) // "Órdenes de pago:"
	oStruEOP:AddField('NVALORDENS', '2', STR0009	, STR0009	, NIL, 'GET', , , , .F.) // "Total por pagar:"
	oStruEOP:AddField('CMOEDA'	  , '3', STR0010	, STR0010	, NIL, 'GET', , , , .T.) // "Mostrar valores en:"
	oStruEOP:AddField('CPGTOELT'  , '4', STR0011	, STR0011	, NIL, 'GET', , , , .T.) // "¿Pago Elect.?"
	
	oStruFJR:AddField('MARK'      	 , '1' , 'MARK'	    , 'MARK'	, NIL, 'GET', , , , .T.)
	oStruFJR:AddField('NOMBRE'       , '4' , STR0021	, STR0021	, NIL, 'GET', , , , .F.) // "Nombre"
	oStruFJR:AddField('FACTURAS'     , '5' , STR0023	, STR0023	, NIL, 'GET', , , , .F.) // "Facturas"
	oStruFJR:AddField('DESCUENTO'    , '6' , STR0024	, STR0024	, NIL, 'GET', , , , .F.) // "Desc./Comp."
	oStruFJR:AddField('TOTAL'        , '7' , STR0025	, STR0025	, NIL, 'GET', , , , .F.) // "Total pagar"
	oStruFJR:AddField('NPORDESC'     , '8' , STR0012	, STR0012	, NIL, 'GET', , , , .T.) // "%Desc."
	oStruFJR:AddField('NVALDESC'     , '9' , STR0013	, STR0013	, NIL, 'GET', , , , .T.) // "Valor del descuento"
	oStruFJR:AddField('NVLRPAGAR'    , '10', STR0014	, STR0014	, NIL, 'GET', , , , .F.) // "Inf.Valor por Pagar"
	oStruFJR:AddField('NSALDOPGOP'   , '12', STR0016	, STR0016	, NIL, 'GET', , , , .F.) // "Saldo ($):"
	oStruFJR:AddField('NTOTDOCTERC'  , '13', STR0017	, STR0017	, NIL, 'GET', , , , .F.) // "Documentos de terceros:"
	oStruFJR:AddField('NTOTDOCPROP'  , '14', STR0018	, STR0018	, NIL, 'GET', , , , .F.) // "Documentos propios:"

	oStruFJR:SetProperty( '*', 	MVC_VIEW_FOLDER_NUMBER, '')
	oStruFJR:SetProperty( '*', 	MVC_VIEW_GROUP_NUMBER , '')

	oStruFJR:aFolders := {}
	oStruFJR:aGroups := {}

	oView:AddField('VIEW_EOP' , oStruEOP, 'EOP_MASTER' )
	oView:AddGrid('VIEW_FJR'  , oStruFJR, 'FJR_MASTER' )
	oView:AddGrid('VIEW_SE2'  , oStruSE2, 'SE2_DETAIL')
	oView:AddGrid('VIEW_PAG'  , oStruPAG, 'PAG_DETAIL')
	oView:AddGrid('VIEW_TTB'  , oStruTTB, 'TTB_DETAIL')

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
	
	oView:SetOwnerView('VIEW_EOP', 'CIMA')
	oView:SetOwnerView('VIEW_FJR', 'MEDIO')
	oView:SetOwnerView('VIEW_SE2', 'BAIXO1')
	oView:SetOwnerView('VIEW_PAG', 'BAIXO2')

	//Habilitando título
	oView:EnableTitleView('VIEW_EOP',"Encabezado OP")
	oView:EnableTitleView('VIEW_FJR',"Encabezado OP")
	oView:EnableTitleView('VIEW_SE2',"Títulos")
	oView:EnableTitleView('VIEW_PAG',"Formas de Pago")
	oView:SetDescription("Orden de Pago")

Return oView

/*/{Protheus.doc} F999LnDesM
	Función Tamaño del nombre de las monedas
	@author 	carlos.espinoza
	@since 		18/08/2025
	@version	12.1.2310 / Superior
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
