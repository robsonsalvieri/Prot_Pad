#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA999.CH'

#DEFINE SOURCEFATHER "FINA999"

/*/{Protheus.doc} FINA999ARG
	Fuente de Modelo de Datos de Orden de Pago Localizado para Argentina
	@author 	arodriguez
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Function FINA999ARG()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
	Definición de Browse
	@author	 	arodriguez
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Static Function BrowseDef()
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
	Define las operaciones que serán realizadas por la aplicación
	@author 	arodriguez
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Static Function MenuDef()
Local aRotina := {}
	
aRotina := FWLoadMenuDef(SOURCEFATHER)

// ExistBlock("F850ADLE") => PE850Leg() | lShowPOrd => F850POPLeg() | ExistBlock("F085ABT") => Execblock("F085ABT",.F.,.F.,aRotina) 
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FINA999' OPERATION 7 ACCESS 0 //	"Leyenda"

Return aRotina

/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados
	@author 	arodriguez
	@return		oModel objeto del Modelo
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oStruEOP		:= oModel:GetModel('EOP_DETAIL'):GetStruct()
Local oStruDOP		:= oModel:GetModel('DOP_DETAIL'):GetStruct()
Local oStru3RO		:= FWFormStruct(1, 'SE1', , .F.)
Local oStruSFE		:= FWFormStruct(1, 'SFE', , .F.)
Local oMdlEvent		:= FINV999ARG():New()
Local oRetEvent		:= F999RETARG():New()

	oStruEOP:AddField('PREORD'	, 'PREORD'	, 'PREORD'	, 'L' , 1)	// "Indica si la orden de pago es una orden previa"

	oStruDOP:AddField(RetTitle("A2_ENDOSSO"), RetTitle("A2_ENDOSSO"), 'ACEPTA3'		, 'C' , 2, 0)
	oStruDOP:AddField(STR0026	, STR0026	, 'GANANCIAS'	, 'N' , 16, 2)		// "Ret. Ganancias"
	oStruDOP:AddField(STR0027	, STR0027	, 'IVA'			, 'N' , 16, 2)		// "Ret. IVA"
	oStruDOP:AddField(STR0028	, STR0028	, 'IIBB'		, 'N' , 16, 2)		// "Ret. IB"
	oStruDOP:AddField(STR0029	, STR0029	, 'SUSS'		, 'N' , 16, 2)		// "Ret. SUSS"
	oStruDOP:AddField(STR0030	, STR0030	, 'SLI'			, 'N' , 16, 2)		// "Ret. SLI"
	oStruDOP:AddField(STR0031	, STR0031	, 'MUNICIPAL'	, 'N' , 16, 2)		// "Ret. Municipal"
	oStruDOP:AddField(STR0032	, STR0032	, 'CBU'			, 'N' , 16, 2)		// "Ret. CBU"
	oStruDOP:AddField('DOCTERPA','DOCTERPA' , 'DOCTERPA'	, 'L' , 1)		    // "Genera PA por documento de tercero"

    oModel:addGrid('3RO_DETAIL','FJR_MASTER',oStru3RO,,)	// Documentos terceros
    oModel:addGrid('SFE_DETAIL','FJR_MASTER',oStruSFE,,)	// Retenciones

	oModel:GetModel('3RO_DETAIL'):SetOptional(.T.)
	oModel:GetModel('SFE_DETAIL'):SetOptional(.T.)

	oModel:GetModel('3RO_DETAIL'):SetOnlyQuery(.T.)
	oModel:GetModel('SFE_DETAIL'):SetOnlyQuery(.T.)

	oStru3RO:SetProperty( '*'			, 	MODEL_FIELD_OBRIGAT,	.F. )
	oStruSFE:SetProperty( '*'			, 	MODEL_FIELD_OBRIGAT,	.F. )

	//Evento del Modelo
	oModel:InstallEvent("FINV999ARG","FINV999",oMdlEvent)
	oModel:InstallEvent("F999RETARG",/*cOwner*/,oRetEvent)
Return oModel

/*/{Protheus.doc} ViewDef
	Interfce del modelo de datos de Cobros Diversos para localización padrón
	@return		oView objeto del View
	@author 	arodriguez
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)

	oModel := oView:GetModel()

Return oView
