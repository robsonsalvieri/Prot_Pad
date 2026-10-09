#include 'totvs.ch'
#include 'fwmvcdef.ch'
#include 'fina999.ch'

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
Local oStruFJR		:= oModel:GetModel('FJR_MASTER'):GetStruct()
Local oStru3RO		:= FWFormStruct(1, 'SE1', , .F.)
Local oStruSFE		:= FWFormStruct(1, 'SFE', , .F.)
Local oMdlEvent		:= FINV999ARG():New()
Local oFinEvent		:= F999FINARG():New()
Local oRetEvent		:= F999RETARG():New()
Local oPgoEvent		:= F999PGOARG():New()
Local nPosSFE       := oStruSFE:GetFieldPos("FE_TIPO")

	oStruFJR:AddField(RetTitle("A2_ENDOSSO"), RetTitle("A2_ENDOSSO"), 'ACEPTA3'		, 'C' , 2, 0)
	oStruFJR:AddField(STR0026	, STR0026	, 'GANANCIAS'	, 'N' , 16, 2)		// "Ret. Ganancias"
	oStruFJR:AddField(STR0027	, STR0027	, 'IVA'			, 'N' , 16, 2)		// "Ret. IVA"
	oStruFJR:AddField(STR0028	, STR0028	, 'IIBB'		, 'N' , 16, 2)		// "Ret. IB"
	oStruFJR:AddField(STR0029	, STR0029	, 'SUSS'		, 'N' , 16, 2)		// "Ret. SUSS"
	oStruFJR:AddField(STR0030	, STR0030	, 'SLI'			, 'N' , 16, 2)		// "Ret. SLI"
	oStruFJR:AddField(STR0031	, STR0031	, 'MUNICIPAL'	, 'N' , 16, 2)		// "Ret. Municipal"
	oStruFJR:AddField(STR0032	, STR0032	, 'CBU'			, 'L' , 1)			// "Ret. CBU"
	oStruFJR:AddField('DOCTERPA','DOCTERPA' , 'DOCTERPA'	, 'L' , 1)		    // "Genera PA por documento de tercero"
	oStruFJR:AddField('NMOERET'	,'NMOERET'	, 'NMOERET'		, 'N' , 2)		    // "Moneda para retención"
	oStruFJR:AddField('NTXPROM' ,'NTXPROM'	, 'NTXPROM'		, 'N' , 16,2)		// "Tasa promedio de todos los títulos financieros de una OP"
	oStruFJR:AddField('ATXPROM'	,'ATXPROM'	, 'ATXPROM'		, 'C' , 255)		// "Tasas de la tabla SM2"
	oStruFJR:AddField('SOLFUN'	,'SOLFUN'	, 'SOLFUN'		, 'C' , GetSx3Cache("FJA_SOLFUN","X3_TAMANHO"))		// "Solicitud de fondos"

	oStruSFE:AddField('RETTOT'	 , 'RETTOT'	  , 'RETTOT'	, 'N' , 16, 2)		// "Retención Total"
	oStruSFE:AddField('ESRETADC' , 'ESRETADC' , 'ESRETADC'	, 'L' , 1)		 	// "Flag de retención adicional"
	oStruSFE:AddField('ALIQRET'	 , 'ALIQRET'  , 'ALIQRET'	, 'N' , 6, 2)		// "Alicuota retención SFF"
	oStruSFE:AddField('ALIQADC'  , 'ALIQADC'  , 'ALIQADC'	, 'N' , 6, 2)		// "Alicuota retención adicional"
	oStruSFE:AddField('SALDO'    , 'SALDO'    , 'SALDO'		, 'N' , 16, 2)		// "Saldo en la moneda del documento"
	oStruSFE:AddField('NOCALC'   , 'NOCALC'   , 'NOCALC'	, 'L' , 1)		    // "Indica si debe calcular/considerar la retención"
	oStruSFE:AddField('CFORA'    , 'CFORA'    , 'CFORA'		, 'C' , GetSx3Cache("FF_CFORA","X3_TAMANHO")) // "CFO de retención adicional"
	oStruSFE:AddField('TPOBRA'   , 'TPOBRA'   , 'TPOBRA'	, 'C' , GetSx3Cache("F1_CONCOBR","X3_TAMANHO")) // "Tipo de obra (SUSS)"
	oStruSFE:AddField('IMPUESTO' , 'IMPUESTO' , 'IMPUESTO'	, 'C' , 20) 		// "Nombre Impuesto para retención Municipal"
	oStruSFE:AddField('RGANNC'	 , 'RGANNC'   , 'RGANNC'	, 'L' , 1) 		    // "Flag - NC - Conceptos diferentes (Retención Ganacias)"

	oStru3RO:AddField('RECSE1'	 , 'RECSE1'	  , 'RECSE1'	, 'N' , 16, 0)
	oStru3RO:AddField('RECSEF'	 , 'RECSEF'	  , 'RECSEF'	, 'N' , 16, 0)

    oModel:addGrid('3RO_DETAIL','EOP_MASTER',oStru3RO,,)	// Documentos terceros
    oModel:addGrid('SFE_DETAIL','EOP_MASTER',oStruSFE,,)	// Retenciones

	oModel:GetModel('3RO_DETAIL'):SetOptional(.T.)
	oModel:GetModel('SFE_DETAIL'):SetOptional(.T.)

	oModel:GetModel('3RO_DETAIL'):SetOnlyQuery(.T.)

	oStru3RO:SetProperty('*' , MODEL_FIELD_OBRIGAT,	.F.)
	oStruSFE:SetProperty('*' , MODEL_FIELD_OBRIGAT,	.F.)

	oStruSFE:SetProperty('FE_ORDPAGO', MODEL_FIELD_VALUES , "") 
	
	If nPosSFE > 0 .And. Len(oStruSFE:aFields[nPosSFE][MODEL_FIELD_VALUES]) == 7
		AADD(oStruSFE:aFields[nPosSFE][MODEL_FIELD_VALUES], "L=L")
	EndIf

	//Evento del Modelo
	oModel:InstallEvent("FINV999ARG","FINV999" ,oMdlEvent)
	oModel:InstallEvent("F999FINARG","F999FIN" ,oFinEvent)
	oModel:InstallEvent("F999RETARG",/*cOwner*/,oRetEvent)
	oModel:InstallEvent("F999PGOARG","F999PGO" ,oPgoEvent)

Return oModel

/*/{Protheus.doc} ViewDef
	Interface del modelo de datos de Cobros Diversos para localización padrón
	@return		oView objeto del View
	@author 	arodriguez
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)
Local oModel    := Nil

	oModel := oView:GetModel()

Return oView
