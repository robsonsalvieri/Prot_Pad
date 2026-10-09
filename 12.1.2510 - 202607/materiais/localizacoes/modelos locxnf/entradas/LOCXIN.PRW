#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCXIN.CH'

//Define's
#Define SnMaxPE 78
PUBLISH MODEL REST NAME LOCXIN

Static aHeaderF1   := {}
Static aColsD1     := {}
Static aLockFldF1  := {}
Static aVldLine    := {}
Static aVldTudoOK  := {}
Static aVldCampo   := {}
Static aDataPE     := {}

/*/{Protheus.doc} LOCXIN
Model para todos los documentos de campos de entradas
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Function LOCXIN()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('SF1')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LOCXIN' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.LOCXIN' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.LOCXIN' OPERATION 4 ACCESS 0 // 'Alterar'
	
Return aRotina


/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function ModelDef()
Local aCampSEV      := {"EV_NATUREZ", "EV_VALOR", "EV_PERC", "EV_RATEICC", "EV_PREFIXO", "EV_NUM", "EV_CLIFOR", "EV_LOJA", "EV_FILIAL"} 
Local oModel        := Nil
Local oStruSF1      := NIL
Local oStruSD1      := FWFormStruct(1, 'SD1', , .F.)
Local oStruDUP		:= FWFormModelStruct():New()
Local oStruSEV      := FWFormStruct(1, 'SEV', { | cCampo | FindString(AllTrim(cCampo), aCampSEV)}, .F.)
Local oStruAFN      := FWFormStruct(1, 'AFN', , .F.)
Local oStruSDE      := FWFormStruct(1, 'SDE', , .F.)
Local oStruSEU	    := FWFormStruct(1, 'SEU', , .F.)
Local oInputFields	:= Nil
Local oEvtFinIn		:= LXINFIN():New()
Local oEvtFisIn		:= LXINFIS():New()
Local oEvtEstIn     := LXINEST():New()
Local oEvtCtbIn		:= LXINCTB():New()
Local oEvtTMSIn     := LXINTMS():New()
Local oEvtWMSIn     := LXINWMS():New()
Local oEvtPCOIn     := LXINPCO():New()
Local oEvtPMSIn     := LXINPMS():New()
Local nTamDup       := 0
Local xAux          := {}
Local aRelSEV       := { { 'EV_FILIAL', 'xFilial( "SEV" )' }, {'EV_CLIFOR', 'F1_FORNECE'}, {'EV_LOJA', 'F1_LOJA'}, {'EV_NUM', 'F1_DOC'}, {'EV_PREFIXO', 'F1_SERIE'}}
Local nIndSEV       := 1

    oModel := MPFormModel():New( 'LOCXIN',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

    oInputFields := InputFieldsAll():New("", .T., .F., .T., .F., .F., .F.)
    oInputFields:AddModel()

    oStruSF1 := oInputFields:getModel()

    //Tabla de saldos y monedas
	oStruDUP:AddTable('' , { '' } , "DUPLICATAS", {|| ''})
    nTamDup := GetSx3Cache('E2_NUM', 'X3_TAMANHO') + GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO') +  GetSx3Cache('E2_PARCELA', 'X3_TAMANHO') + GetSx3Cache('E2_VENCTO', 'X3_TAMANHO') +  GetSx3Cache('E2_VALOR', 'X3_TAMANHO') + 13
	oStruDUP:AddField('DUP' 	, 'DUP'	, 'DUP' 	, 'C' , nTamDup)
    oStruDUP:AddField(STR0015   , STR0015   , 'DUP_NUM' 	, 'C' , GetSx3Cache('E2_NUM', 'X3_TAMANHO')) //'Número'
    oStruDUP:AddField(STR0016   , STR0016	, 'DUP_PREFIX' 	, 'C' , GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO')) //'Serie'
    oStruDUP:AddField(STR0017   , STR0017	, 'DUP_PARCEL' 	, 'C' , GetSx3Cache('E2_PARCELA', 'X3_TAMANHO')) //'Cuota'
    oStruDUP:AddField(STR0018 	, STR0018	, 'DUP_VENCTO' 	, 'D' , GetSx3Cache('E2_VENCTO', 'X3_TAMANHO')) //'Vecto'
    oStruDUP:AddField(STR0019 	, STR0019	, 'DUP_VALOR' 	, 'N' , GetSx3Cache('E2_VALOR', 'X3_TAMANHO')) //'Valor'
    

    oStruSF1:SetProperty( 'F1_TIPO'     , MODEL_FIELD_OBRIGAT , .F.)
    oStruSF1:SetProperty( 'F1_FORMUL'   , MODEL_FIELD_OBRIGAT , .F.)
    oStruSF1:SetProperty( 'F1_COND'     , MODEL_FIELD_OBRIGAT , .F.)
    oStruSF1:SetProperty( 'F1_ORIGEM'   , MODEL_FIELD_OBRIGAT , .F.)
    If oStruSF1:HasField("F1_UUID")
        oStruSF1:SetProperty( 'F1_UUID'     , MODEL_FIELD_OBRIGAT , .F.)
    EndIf
    If oStruSF1:HasField("F1_IPI")
        oStruSF1:SetProperty( 'F1_IPI'      , MODEL_FIELD_OBRIGAT , .F.)
    EndIf
    If oStruSF1:HasField("F1_SERIE2")
        oStruSF1:SetProperty( 'F1_SERIE2'   , MODEL_FIELD_OBRIGAT , .F.)
    EndIf
    If oStruSF1:HasField("F1_TPDOC")
        oStruSF1:SetProperty( 'F1_TPDOC'   , MODEL_FIELD_OBRIGAT , .F.)
    EndIf
    If oStruSF1:HasField("F1_MOTIVO")
        oStruSF1:SetProperty( 'F1_MOTIVO'   , MODEL_FIELD_OBRIGAT , .F.)
    EndIf
    If oStruSF1:HasField("F1_TIPREF")
        oStruSF1:SetProperty( 'F1_TIPREF'   , MODEL_FIELD_OBRIGAT , .F.)
    EndIf

    oStruSF1:RemoveField( "F1_MSIDENT")

    oStruSF1:AddField(  STR0034,;   // [01]  C   Titulo del campo.   //STR0034 "Ctd. Total Dig." 
                        STR0034,;   // [02]  C   ToolTip del campo.  //STR0034 "Ctd. Total Dig." 
                  "F1_CANACU",;	    // [03]  C   ID de campo //F1_CANACU+=D1_QUANT
                  "N",;		        // [04]  C   Tipo do campo
                  18,;		        // [05]  N   Tamaño del campo
                  2,;		        // [06]  N   Indica cuantos decimales maneja el campo
                  ,;	            // [07]  B   bloque de código de validación de campo.
                  ,;		        // [08]  B   Bloque de código de validación para el campo Cuándo.
                  ,;		        // [09]  A   Lista de valores permitidos para el campo.
                  .F.,;		        // [10]  L   Indica si el campo es obligatorio.
                  ,;                // [11]  B   Bloque de código de inicialización de campo.
                  .F.,;		        // [12]  L   Indica si este es un campo clave.
                  .F.,;		        // [13]  L   Indica si el campo puede recibir un valor en una operación de actualización.
                  .T.)		        // [14]  L   Indica si es virtual.

    oStruSD1:SetProperty( 'D1_COD'      , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_COD()"))
    oStruSD1:SetProperty( 'D1_QUANT'    , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_QUANT()"))
    oStruSD1:SetProperty( 'D1_VUNIT'    , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_VUNIT()"))
    oStruSD1:SetProperty( 'D1_TOTAL'    , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_TOTAL()"))
    oStruSD1:SetProperty( 'D1_RATEIO'   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_RATEIO()"))
    oStruSD1:SetProperty( 'D1_REMITO'  , MODEL_FIELD_OBRIGAT , .F.)
    oStruSD1:SetProperty('*'   , MODEL_FIELD_OBRIGAT , .F.)

    If oStruSD1:HasField("D1_NFORI")
        oStruSD1:SetProperty( 'D1_NFORI'   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_NFORI()"))
    EndIf
    If oStruSD1:HasField("D1_ITEMORI")
        oStruSD1:SetProperty( 'D1_ITEMORI'   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_ITEMORI()"))
    EndIf

    If oStruSD1:HasField("D1_PEDIDO")
        oStruSD1:SetProperty( 'D1_PEDIDO'   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_PEDIDO()"))
    EndIf
    If oStruSD1:HasField("D1_ITEMPC")
        oStruSD1:SetProperty( 'D1_ITEMPC'   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_ITEMPC()"))
    EndIf

    //Campo para descripción del producto.    
    oStruSD1:AddField(STR0024, STR0024, "D1_CODDESC","C",GetSX3Cache("B1_DESC", "X3_TAMANHO"),,,,,,,,,.T.,) //'Descripción'
    oStruSD1:SetProperty( 'D1_CODDESC'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,AllTrim(Posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_DESC")), "")'  ) )

    oStruSD1:SetProperty( 'D1_EMISSAO'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI, FwFldGet("D1_EMISSAO"), FwFldGet("F1_EMISSAO"))'  ) )

    //Disparadores SD1
    //D1_TES
    xAux := FwStruTrigger('D1_TES', 'D1_CF', 'AllTrim(Posicione("SF4", 1, xFilial("SF4") + FwFldGet("D1_TES"), "F4_CF"))', .F.)
	oStruSD1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

    xAux := FwStruTrigger('D1_QUANT', 'D1_TOTAL', '(FwFldGet("D1_QUANT") * FwFldGet("D1_VUNIT"))', .F.)
	oStruSD1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])
    
    xAux := FwStruTrigger('D1_VUNIT', 'D1_TOTAL', '(FwFldGet("D1_QUANT") * FwFldGet("D1_VUNIT"))', .F.)
	oStruSD1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

    xAux := FwStruTrigger('D1_COD', 'D1_CODDESC', 'AllTrim(Posicione("SB1", 1, xFilial("SB1") + FwFldGet("D1_COD"), "B1_DESC"))', .F.)
	oStruSD1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])                                                                                                                        

    UpdTrigger(@oStruSD1)

    oStruSF1:AddField('', '',"BASEDUP","N",GetSX3Cache("F1_VALMERC", "X3_TAMANHO"),GetSX3Cache("F1_VALMERC", "X3_DECIMAL"),/*valid*/,,,,)
    oStruSF1:AddField("AUTO"		,"AUTO"					,"AUTO"		,"L",1)
    oStruSF1:AddField("CALC"		,"CALC"					,"CALC"		,"L",1) //Indica si debe de ser realizado el calculo de los valores.
    oStruSF1:AddField("ALTIMP"		,"ALTIMP"               ,"ALTIMP"   ,"L",1) //Indica si los impuestos fueron alterados.
    oStruSF1:AddField("DOCSOP"		,"DOCSOP"               ,"DOCSOP"   ,"L",1) //Indica si es un documento de soporte.
    oStruSF1:AddField("CALCGASTOS"  ,"CALCGASTOS"           ,"CALCGASTOS"   ,"L",1) //Indica si recalcula gastos.
    If oStruSF1:HasField("F1_NATUREZ")
        oStruSF1:AddField(STR0033, STR0033, "F1_NATFIN", GetSX3Cache("F1_NATUREZ", "X3_TIPO"), GetSX3Cache("F1_NATUREZ", "X3_TAMANHO"), GetSX3Cache("F1_NATUREZ", "X3_DECIMAL"),,,,,,,,.T.,)
    EndIf
    oStruSF1:AddField(AllTrim(FwX3Titulo("F1_MOEDA")), AllTrim(FwX3Titulo("F1_MOEDA")), "F1_MOEFIN", GetSX3Cache("F1_MOEDA", "X3_TIPO"), GetSX3Cache("F1_MOEDA", "X3_TAMANHO"), GetSX3Cache("F1_MOEDA", "X3_DECIMAL"),,,,,,,,.T.,)

    //Campos para descripciones de campos Financieros
    oStruSF1:AddField(STR0021, STR0021,"F1_DSCCOND","C",GetSX3Cache("E4_DESCRI", "X3_TAMANHO"),,,,,,,,,.T.,) //'Desc. Pago'
    oStruSF1:SetProperty( 'F1_DSCCOND'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,AllTrim(Posicione("SE4", 1, xFilial("SE4") + SF1->F1_COND, "E4_DESCRI")), "")'  ) )
    oStruSF1:AddField(STR0023, STR0023,"F1_DSCMODL","C",GetSX3Cache("ED_DESCRIC", "X3_TAMANHO"),,,,,,,,,.T.,) //'Desc. Mod.'
    If oStruSF1:HasField("F1_NATUREZ")
        oStruSF1:SetProperty( 'F1_NATFIN'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetNatFin(1, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DOC, SF1->F1_SERIE, F1_ESPECIE, F1_TIPODOC), "")'  ) ) 
    EndIF
    oStruSF1:SetProperty( 'F1_DSCMODL'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetNatFin(2, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DOC, SF1->F1_SERIE, F1_ESPECIE, F1_TIPODOC), "")'  ) )

    //Disparadores SF1
    xAux := FwStruTrigger('F1_COND', 'F1_DSCCOND', 'AllTrim(Posicione("SE4", 1, xFilial("SE4") + FwFldGet("F1_COND"), "E4_DESCRI"))', .F.)
	oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    If oStruSF1:HasField("F1_NATUREZ")
        xAux := FwStruTrigger('F1_NATUREZ', 'F1_NATFIN', 'FwFldGet("F1_NATUREZ")', .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 
        
        xAux := FwStruTrigger('F1_NATFIN', 'F1_DSCMODL', 'AllTrim(Posicione("SED", 1, xFilial("SED") + FwFldGet("F1_NATFIN"), "ED_DESCRIC"))', .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F1_FORNECE', 'F1_NATFIN', "DispNatFin('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F1_LOJA', 'F1_NATFIN', "DispNatFin('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 
    EndIf

    xAux := FwStruTrigger('F1_FORNECE', 'F1_COND', "DispCond('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
	oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    xAux := FwStruTrigger('F1_LOJA', 'F1_COND', "DispCond('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
	oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    If oStruSF1:HasField("F1_PROVENT") .AND. oStruSF1:HasField("F1_PV")  
        xAux := FwStruTrigger('F1_FORNECE', 'F1_PROVENT', "DispProven('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F1_LOJA', 'F1_PROVENT', "DispProven('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])
    EndIf

    xAux := FwStruTrigger('F1_MOEDA', 'F1_MOEFIN', 'FwFldGet("F1_MOEDA")', .F.)
	oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    oStruSF1:SetProperty( 'F1_COND'      , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, 'F1_CONDVal()'))
    If oStruSF1:HasField("F1_NATUREZ")
        oStruSF1:SetProperty( 'F1_NATFIN'    , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_INIPAD,GetSX3Cache("F1_NATUREZ", "X3_VALID")))
    EndIf
    oStruSF1:SetProperty( 'F1_MOEFIN'    , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetMoeFin(SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DOC, SF1->F1_SERIE, F1_ESPECIE, F1_TIPODOC), Val(GetSx3Cache("F1_MOEDA", "X3_RELACAO")))') )
    oStruSF1:SetProperty( 'F1_MOEFIN'    , MVC_MODEL_VALUES    , oInputFields:GetMonedas()) 

    oStruSF1:SetProperty( 'CALC'    , MODEL_FIELD_INIT , { || .F.})
    oStruSF1:SetProperty( 'ALTIMP'  , MODEL_FIELD_INIT , { || .F.})
    oStruSF1:SetProperty( 'DOCSOP'  , MODEL_FIELD_INIT , { || .F.})
    oStruSF1:SetProperty( 'CALCGASTOS'  , MODEL_FIELD_INIT , { || .F.})
    If oStruSF1:HasField("F1_SOPORT")
        oStruSF1:SetProperty( 'F1_SOPORT', MODEL_FIELD_INIT , { || ""})
    EndIf
    If oStruSF1:HasField("F1_MARK")
        oStruSF1:SetProperty( 'F1_MARK', MODEL_FIELD_INIT , { || ""})
    EndIf

    oStruSEU:AddField(STR0024, STR0024,"EU_DSCCAIX","C",GetSX3Cache("ET_NOME", "X3_TAMANHO"),,,,,,,,,.T.,) //'Descripción'
    oStruSEU:SetProperty( 'EU_DSCCAIX'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,AllTrim(Posicione("SET", 1, xFilial("SET") + SEU->EU_CAIXA, "ET_NOME")), "")'  ) )
    
    //Disparador Caja chica
    xAux := FwStruTrigger('EU_CAIXA', 'EU_DSCCAIX', 'AllTrim(Posicione("SET", 1, xFilial("SET") + FwFldGet("EU_CAIXA"), "ET_NOME"))', .F.)
	oStruSEU:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    oStruSEV:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)
    oStruAFN:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)
    oStruSDE:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)
    oStruSEU:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)

    oModel:addFields('SF1_MASTER',,oStruSF1)
    oModel:addGrid('SD1_DETAIL','SF1_MASTER',oStruSD1,,)
    oModel:addGrid('DUP_DETAIL','SF1_MASTER',oStruDUP,,,,,{|oGrid| LoadGridDup(oGrid)})
    oModel:addGrid('SEV_DETAIL','SF1_MASTER',oStruSEV,,)
    oModel:addGrid('AFN_DETAIL','SF1_MASTER',oStruAFN,,)
    oModel:addGrid('SDE_DETAIL','SF1_MASTER',oStruSDE,,)
    oModel:addFields('SEU_DETAIL', 'SF1_MASTER', oStruSEU)
        
    oModel:AddCalc("TOTCALC", "SF1_MASTER", "SD1_DETAIL", "D1_TOTAL", "VALMERC", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F1_VALMERC') /*cTitle*/,  { |oModel| LxInGetFld( oModel, "SF1_MASTER", "F1_VALMERC" ) }/*bFormula*/)
    oModel:AddCalc("TOTCALC", "SF1_MASTER", "SD1_DETAIL", "D1_TOTAL", "DESCONT", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F1_DESCONT') /*cTitle*/,  { |oModel| LxInGetFld( oModel, "SF1_MASTER", "F1_DESCONT" ) }/*bFormula*/)
    oModel:AddCalc("TOTCALC", "SF1_MASTER", "SD1_DETAIL", "D1_TOTAL", "VALBRUT", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F1_VALBRUT') /*cTitle*/,  { |oModel| LxInGetFld( oModel, "SF1_MASTER", "F1_VALBRUT" ) }/*bFormula*/)
    oModel:AddCalc("TOTCALC", "SF1_MASTER", "SD1_DETAIL", "D1_QUANT", "QTDACUM", 'SUM',     /*bCondition*/, /*bInitValue*/, RetTitle('B1_QTDACUM') /*cTitle*/,/*bFormula*/)


    // Indica que es opcional tener datos informados en el grid
    oModel:GetModel( 'SD1_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DUP_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEV_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'AFN_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SDE_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEU_DETAIL' ):SetOptional(.T.)

    oModel:GetModel("SD1_DETAIL"):SetMaxLine(9999)

    oModel:SetPrimaryKey({'F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA'}) //{'F1_FILIAL','F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA','F1_TIPO'}
    
    If FWSIXUtil():ExistIndex( "SEV" , "6" )
        aRelSEV       := { { 'EV_FILIAL', 'xFilial( "SEV" )' }, {'EV_NUM', 'F1_DOC'},{'EV_PREFIXO', 'F1_SERIE'},{'EV_CLIFOR', 'F1_FORNECE'}, {'EV_LOJA', 'F1_LOJA'}}
        nIndSEV       := 6
    EndIf
    oModel:SetRelation('SD1_DETAIL',{ { 'D1_FILIAL', 'xFilial( "SD1" )' }, {'D1_DOC', 'F1_DOC'}, {'D1_SERIE', 'F1_SERIE'}, {'D1_FORNECE', 'F1_FORNECE'}, {'D1_LOJA', 'F1_LOJA'}}, SD1->(IndexKey(1)))
    oModel:SetRelation('SDE_DETAIL',{ { 'DE_FILIAL', 'xFilial( "SDE" )' }, {'DE_DOC', 'F1_DOC'}, {'DE_SERIE', 'F1_SERIE'}, {'DE_FORNECE', 'F1_FORNECE'}, {'DE_LOJA', 'F1_LOJA'}}, SDE->(IndexKey(1)))
    oModel:SetRelation('SEU_DETAIL',{ { 'EU_FILIAL', 'xFilial( "SEU" )' }, {'EU_FORNECE', 'F1_FORNECE'}, {'EU_LOJA', 'F1_LOJA'}, {'EU_NRCOMP', 'F1_DOC'}, {'EU_SERCOMP', 'F1_SERIE'}}, SEU->(IndexKey(7))) //EU_FILIAL+EU_FORNECE+EU_LOJA+EU_NRCOMP+EU_SERCOMP
    oModel:SetRelation('SEV_DETAIL',aRelSEV, SEV->(IndexKey(nIndSEV))) //EV_FILIAL+EV_NUM+EV_PREFIXO+EV_CLIFOR+EV_LOJA
    oModel:SetRelation('AFN_DETAIL',{ { 'AFN_FILIAL', 'xFilial( "AFN" )'}, {'AFN_DOC', 'F1_DOC'}, {'AFN_SERIE', 'F1_SERIE'}, {'AFN_FORNEC', 'F1_FORNECE'}, {'AFN_LOJA', 'F1_LOJA'}}, AFN->(IndexKey(2))) //AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA


    //Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SF1_MASTER'):SetOnlyQuery(.T.)
    oModel:GetModel('SD1_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('DUP_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SEV_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('AFN_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SDE_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SEU_DETAIL'):SetOnlyQuery(.T.)

    oModel:GetModel( "SD1_DETAIL" ):SetUseOldGrid(.T.)
    oModel:GetModel( "SDE_DETAIL" ):SetUseOldGrid(.T.)
    oModel:GetModel( "SEV_DETAIL" ):SetUseOldGrid(.T.)

    oModel:InstallEvent("LXINFIS"	,/*cOwner*/,oEvtFisIn) //Evento fiscal
    oModel:InstallEvent("LXINFIN"	,/*cOwner*/,oEvtFinIn) //Evento financiero
    oModel:InstallEvent("LXINEST"	,/*cOwner*/,oEvtEstIN) //Evento Stock
    oModel:InstallEvent("LXINCTB"	,/*cOwner*/,oEvtCtbIn) //Evento contabilidad
    oModel:InstallEvent("LXINTMS"	,/*cOwner*/,oEvtTMSIn) //Evento TMS
    oModel:InstallEvent("LXINWMS"   ,/*cOwner*/,oEvtWMSIn) //Evento WMS
    oModel:InstallEvent("LXINPCO"   ,/*cOwner*/,oEvtPCOIn) //Evento PCO
    oModel:InstallEvent("LXINPMS"   ,/*cOwner*/,oEvtPMSIn) //Evento PMS

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oStruSF1      := Nil
Local oStruSD1      := FWFormStruct( 2, 'SD1', , .T. )
Local oView         := Nil
Local oInputFields	:= Nil
Local oModel	    := FWLoadModel('LOCXIN')
Local lLxinProd     := ExistBlock("LXINPROD")
Local cCpoDesc      := ""

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:SetContinuousForm(.T.)

    oInputFields := InputFieldsAll():New("", .T., .F., .F., .F., .F., .F.)
    oInputFields:AddFields()
    oStruSF1 := oInputFields:GetView()

    oView:AddField('oStruSF1' , oStruSF1, 'SF1_MASTER' )
    oView:AddGrid('oStruSD1'  , oStruSD1, 'SD1_DETAIL', , , {||LxInPreCal(oView:GetModel()),ViewCalcIn(oView)})

    oView:AddIncrementField( 'SD1_DETAIL', 'D1_ITEM' )

    //Campos retirados del grid para no ser editados.
    oStruSD1:RemoveField( "D1_DOC" )
    oStruSD1:RemoveField( "D1_SERIE" )
    oStruSD1:RemoveField( "D1_VLSLXML" )

    If lLxinProd
        cCpoDesc := ExecBlock("LXINPROD",.F.,.F.)
        If Empty(cCpoDesc) .Or. Empty(GetSX3Cache(cCpoDesc,"X3_CAMPO"))
            cCpoDesc := ""
        EndIf
    EndIf

    If Empty(cCpoDesc)
        //Campo para descripción del producto.
        oStruSD1:AddField("D1_CODDESC", Soma1(oStruSD1:GetProperty("D1_COD", MVC_VIEW_ORDEM)), STR0024, STR0024, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //Descripción
    EndIf

    //Filtros de busqueda para el grid de productos.
    oView:SetViewProperty("oStruSD1","ENABLENEWGRID")
    oView:SetViewProperty("oStruSD1","GRIDFILTER",{.T.})
    oView:SetViewProperty("oStruSD1","GRIDSEEK",{.T.})

    oView:SetFieldAction( 'F1_DOC',     { |oView| RefreshFld(oView, "SF1_MASTER", "F1_DOC") } )
    oView:SetFieldAction( 'F1_FORNECE', { |oView| CleanModIn(oView) } )
    oView:SetFieldAction( 'F1_TXMOEDA', { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_FRETE',   { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_DESPESA', { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_SEGURO',  { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_DESCONT', { |oView| LxUpdItems(oView:GetModel(), "SD1_DETAIL", "D1_VALDESC", 0), ViewCalcIn(oView) } )
    If oView:GetModel("SF1_MASTER"):HasField("F1_TPACTIV")
        oView:SetFieldAction( 'F1_TPACTIV',  { |oView| ViewCalcIn(oView) } )
    EndIf
    If oView:GetModel("SF1_MASTER"):HasField("F1_CODMUN")
        oView:SetFieldAction( 'F1_CODMUN',  { |oView| ViewCalcIn(oView) } )
    EndIf
    If oView:GetModel("SF1_MASTER"):HasField("F1_PV")
        oView:SetFieldAction( 'F1_COND',  { |oView| RecalView(oView) } )
    EndIf

    oView:EnableTitleView("oStruSD1",  STR0001 ) //'Productos'

    MaFisFound()
	
Return oView

/*/{Protheus.doc} F1IniName
Función utilizada para regresar el nombre del proveedor
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
Parametros
    cFornece - caracter - código del proveedor.
    cLoja - caracter - tienda del proveedor.
    cCpoTpoDoc - caracter - Campo de numero de documento (F1_TIPODOC).
@Return 
    cName - caracter - nombre del proveedor..
/*/
Function F1IniName(cFornece, cLoja, cTipoDoc)
Local cName     := ""
Local cTable    := ""
Local oTipoDoc  := TipoDoc():New()

Default cFornece := ""
Default cLoja    := ""
Default cTipoDoc:= ""
    
    If !Empty(cFornece) .and. !Empty(cLoja) .and. !Empty(cTipoDoc)
        oTipoDoc:SetTipoDoc(cTipoDoc)
        cTable := oTipoDoc:GetTableOrig()
        cName := Posicione(cTable,1,xFilial(cTable)+cFornece+cLoja,Iif(cTable=="SA1", "A1_NOME", "A2_NOME"))
    EndIf

Return cName

/*/{Protheus.doc} LxModForPC
Función utilizada para realizar la llamada de la pantalla de selección de pedidos de compra.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
    lUseCond - logico - Indica si debe actualizar la condición de pago. (Para remitos no aplica)
@Return 
/*/
Function LxModForPC(oModel, lUseCond)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local oModelSDE     := oModel:GetModel("SDE_DETAIL")
Local aOldData
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local cDoc          := ""
Local cSerie        := ""
Local oStruSD1      := Nil
Local nPosCod       := 0
Local lRet          := .F.
Local nFrete        := 0
Local nSeguro       := 0
Local nDespesa      := 0
Local nTipoDoc      := 0
Local aCposSDE      := {}

Private nMoedaNF    := 0
Private aHeader     := {}
Private aCols       := {}
Private cA100For    := ""
Private cLoja       := ""
Private lConsLoja   := .F.
Private lReajuste   := .T.
Private dDEmissao   := cToD("//")
Private aRatCC    	:= {}
Private aRatAFN 	:= {} //Int.c/PMS
Private aHdrAFN 	:= {} //Int.c/PMS (Cab. da aRatAFN)
Private aRotina     := {{"", "", 0, 1, 0, .F.}, {"", "", 0, 2, 0, }}
Private n           := oModelSD1:GetLine()
Private cTipo       := ""
Private cCadastro   := "" 
Private cCondicao   := ""

Default lUseCond    := .T.

    aOldData := oModelSD1:GetOldData()
    cA100For := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    nMoedaNF := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    dDEmissao := oModel:GetModel("SF1_MASTER"):GetValue("F1_EMISSAO")
    cTipo  := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    nTipoDoc := Val(oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC"))
    oStruSD1 := oModelSD1:GetStruct()
    nPosCod := oStruSD1:GetFieldPos("D1_COD")
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])
    aCposSDE := GetCposSDE(oModelSDE)
    aRatCC := GetModSDE(oModelSDE, aCposSDE)
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF1CfgNF()
    EndIf

    If LxA103ItemPC( .F., , nTipoDoc)
    
        For nX := 1 To Len(aCols)
            If !Empty(aCols[nX][nPosCod])
                If oModelSD1:Length() < nX
                    oModelSD1:LVALID := .T. //Actualización x campo
                    oModelSD1:AddLine()
                else
                    oModelSD1:GoLine(nX)
                EndIf
                //Actualización x campo
                For nY := 1 To Len(aHeader)
                    If !Empty(aCols[nX][nY])
                        xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                        oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                    EndIf
                Next
                oModelSD1:LoadValue("D1_DOC", cDoc)
                oModelSD1:LoadValue("D1_SERIE", cSerie)
                oModelSD1:LoadValue("D1_FORNECE", cA100For)
                oModelSD1:LoadValue("D1_LOJA", cLoja)
                oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
                lRet := .T.
            EndIf
            nFrete        += oModelSD1:GetValue("D1_VALFRE")
            nSeguro       += oModelSD1:GetValue("D1_SEGURO")
            nDespesa      += oModelSD1:GetValue("D1_DESPESA")
        Next
        oModelSD1:GoLine(1)
        ActModSDE(oModelSDE, aCposSDE, aRatCC)

        oModel:GetModel("SF1_MASTER"):LoadValue("F1_FRETE", nFrete)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_SEGURO", nSeguro)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESPESA", nDespesa)

        If lUseCond .and. !Empty(cCondicao)
            oModel:GetModel("SF1_MASTER"):LoadValue("F1_COND", cCondicao)
        EndIf

        If lRet .and. oModel:GetModel("SF1_MASTER"):HasField("CALC")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
        EndIf
        If oModel:GetModel("SF1_MASTER"):HasField("CALCGASTOS")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALCGASTOS", .T.) //Cambia flag para indicar que no se debe recalcular gastos.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LxModForF4
Función utilizada para realizar la llamada de la pantalla de selección de pedidos de compra.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
    lUseCond - logico - Indica si debe actualizar la condición de pago. (Para remitos no aplica)
@Return 
/*/
Function LxModForF4(oModel, lUseCond)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local oModelSDE     := oModel:GetModel("SDE_DETAIL")
Local aOldData
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local nPosCod       := 0
Local cDoc          := ""
Local cSerie        := ""
Local oStruSD1      := Nil
Local lRet          := .F.
Local nFrete        := 0
Local nSeguro       := 0
Local nDespesa      := 0
Local nTipoDoc      := 0
Local aCposSDE      := {}

Private aHeader     := {}
Private aCols       := {}
Private cA100For    := ""
Private cLoja       := ""
Private lConsLoja   := .F.
Private nMoedaNF    := 0
Private lReajuste   := .T.
Private dDEmissao   := cToD("//")
Private aRatCC    	:= {}
Private aRatAFN 	:= {} //Int.c/PMS
Private aHdrAFN 	:= {} //Int.c/PMS (Cab. da aRatAFN)
Private aRotina     := {{"", "", 0, 1, 0, .F.}, {"", "", 0, 2, 0, }}
Private cTipo       := ""
Private cCadastro   := "" 
Private N           := 0
Private cCondicao   := ""

Default lUseCond    := .T.

    aOldData := oModelSD1:GetOldData()
    cA100For := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    nMoedaNF := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    dDEmissao := oModel:GetModel("SF1_MASTER"):GetValue("F1_EMISSAO")
    cTipo  := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    nTipoDoc := Val(oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC"))
    oStruSD1 := oModelSD1:GetStruct()
    nPosCod := oStruSD1:GetFieldPos("D1_COD")
    N := oModelSD1:GetLine()
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])
    aCposSDE := GetCposSDE(oModelSDE)
    aRatCC := GetModSDE(oModelSDE, aCposSDE)
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF1CfgNF()
    EndIf
    If LxA103ForF4(.F., .T., nTipoDoc)
        oModelSD1:ClearData(.F., .T.)
        For nX := 1 To Len(aCols)
            If !Empty(aCols[nX][nPosCod])
                If oModelSD1:Length() < nX
                    oModelSD1:LVALID := .T. //Actualización x campo
                    oModelSD1:AddLine()
                EndIf
                //Actualización x campo
                For nY := 1 To Len(aHeader)
                    If !Empty(aCols[nX][nY])
                        xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                        oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                    EndIf
                Next
                oModelSD1:LoadValue("D1_DOC", cDoc)
                oModelSD1:LoadValue("D1_SERIE", cSerie)
                oModelSD1:LoadValue("D1_FORNECE", cA100For)
                oModelSD1:LoadValue("D1_LOJA", cLoja)
                oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
                lRet := .T.
            EndIf
            nFrete        += oModelSD1:GetValue("D1_VALFRE")
            nSeguro       += oModelSD1:GetValue("D1_SEGURO")
            nDespesa      += oModelSD1:GetValue("D1_DESPESA")
        Next
        oModelSD1:GoLine(1)
        ActModSDE(oModelSDE, aCposSDE, aRatCC)

        oModel:GetModel("SF1_MASTER"):LoadValue("F1_FRETE", nFrete)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_SEGURO", nSeguro)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESPESA", nDespesa)

        If lUseCond .and. !Empty(cCondicao)
            oModel:GetModel("SF1_MASTER"):LoadValue("F1_COND", cCondicao)
        EndIf

        If lRet .and. oModel:GetModel("SF1_MASTER"):HasField("CALC")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
        EndIf
        If oModel:GetModel("SF1_MASTER"):HasField("CALCGASTOS")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALCGASTOS", .T.) //Cambia flag para indicar que no se debe recalcular gastos.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LxSetModIn
Función utilizada para actualizar la estructura segun documento/pais para SF1
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oModel - - modelo a ser actualizado con la estructura del documento recibido, debe ser enviado como @oModel.
    cPais - caracter - país para el cual será utilizada la estructura.
    nDoc - numerico - número del documento para ser actualizada la estructura
    cEspecie - caracter - especie del documento.
    lDocSop - logico - indica si es documento soporte.
    lAutoFact - logico - indica si es documento Autofactura.
@Return 
/*/
Function LxSetModIn(oModel, cPais, nDoc, cEspecie, lDocSop, lAutoFact)
Local oInputFields	:= Nil
Local oLxInEvent	:= LXINEVENT():New()

Default cPais       := ""
Default nDoc        := 0
Default cEspecie    := ""
Default lDocSop     := .F.
Default lAutoFact   := .F.

    oInputFields := InputFields(cPais,.T., .F., .T., .F., .F., .F., cEspecie)
    If lDocSop .and. AttIsMemberOf(oInputFields , "lDocSoporte", .T.)
        oInputFields:lDocSoporte := lDocSop
    EndIf
    If lAutoFact .and. AttIsMemberOf(oInputFields , "lAutoFact", .T.)
        oInputFields:lAutoFact := lAutoFact
    EndIf
    oInputFields:SetModel(oModel:GetModel("SF1_MASTER"):GetStruct())
	oInputFields:AddModelProperties(nDoc)

    oModel:GetModel("SF1_MASTER"):SetStruct(oInputFields:getModel())

    oModel:InstallEvent("LXINEVENT"   ,/*cOwner*/,oLxInEvent) //Evento locxnf

Return

/*/{Protheus.doc} LxSetModIn
Función utilizada para actualizar la estructura de la view segun documento/pais para SF1
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
    cPais - caracter - país para el cual será utilizada la estructura.
    nDoc - numerico - número del documento para ser actualizada la estructura
    cEspecie - caracter - especie del documento.
    lDocSop - logico - indica si es documento soporte.
    lAutoFact - logico - indica si es documento Autofactura.
@Return 
/*/
Function LxSelDocIn(oView, cPais, nTipo, cEspecie, lDocSop, lAutoFact)
Local oInputFields  := Nil

Default cPais       := ""
Default nTipo       := 0
Default cEspecie    := ""
Default lDocSop     := .F.
Default lAutoFact   := .F.

    oInputFields := InputFields(cPais,.T., .F., .F., .F., .F., .F., cEspecie)
    If lDocSop .and. ValType(oInputFields:lDocSoporte) == "L"
        oInputFields:lDocSoporte := lDocSop
    EndIf
    If lAutoFact .and. ValType(oInputFields:lAutoFact) == "L"
        oInputFields:lAutoFact := lAutoFact
    EndIf
    oInputFields:AddFields()
    oInputFields:AddInputFields(nTipo, .T.)
    oInputFields:CamposGastos()
    oView:GetViewObj("SF1_MASTER")[3]:GetStruct() := oInputFields:GetView()
    oView:GetViewObj("SF1_MASTER")[3]:oStructview := oInputFields:GetView()
Return

/*/{Protheus.doc} LxFinView
Función utilizada para actualizar la estructura para el apartado financiero de la view
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxFinView(oView)
Local oStruFIN	    := FWFormStruct( 2, 'SF1',{|cCampo| FindString(AllTrim(cCampo), {"F1_COND"})}, .F.)

    oStruFIN:SetProperty("F1_COND", MVC_VIEW_ORDEM, "01")
    oStruFIN:AddField("F1_DSCCOND", "02", STR0021, STR0021, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Desc. Pago'
    oStruFIN:AddField("F1_NATFIN", "03", STR0033, STR0033, Nil, "C", "@!", NIL, "SED", .T., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Modalidad financiera'
    oStruFIN:AddField("F1_DSCMODL", "04", STR0023, STR0023, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Desc. Mod.'
    oStruFIN:AddField("F1_MOEFIN", "05", AllTrim(FwX3Titulo("F1_MOEDA")), AllTrim(FwX3Titulo("F1_MOEDA")), {STR0030 }, "Get", "@!", NIL, "SED", .T., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Moneda financiera'
    oStruFIN:SetProperty( "F1_MOEFIN", MVC_VIEW_COMBOBOX, oView:GetViewStruct("SF1_MASTER"):GetProperty("F1_MOEDA", MVC_VIEW_COMBOBOX) )
    
    oStruFIN:SetProperty( '*', 	MVC_VIEW_FOLDER_NUMBER, '')
	oStruFIN:aFolders := {}
    oStruFIN:SetProperty( '*', 	MVC_VIEW_GROUP_NUMBER , '')
    oStruFIN:aGroups := {}
    
    
    oView:AddField('oStruFIN' , oStruFIN, 'SF1_MASTER' )

    oView:SetViewProperty('oStruFIN',  'SETLAYOUT', { FF_LAYOUT_HORZ_DESCR_LEFT, 5 } )

    oView:EnableTitleView("oStruFIN", STR0002 ) //'Financiero'

    oView:SetFieldAction( 'F1_FORNECE', { |oView| ViewCalcIn(oView), ViewRfresh(oView, 'oStruFIN') } )
    oView:SetFieldAction( 'F1_LOJA',    { |oView| ViewCalcIn(oView), ViewRfresh(oView, 'oStruFIN') } )
    oView:SetFieldAction( 'F1_SERIE',   { |oView| LxUpdItems(oView:GetModel(), "SD1_DETAIL", "D1_DOC", oView:GetModel("SF1_MASTER"):GetValue("F1_DOC")), ViewCalcIn(oView), ViewRfresh(oView, 'oStruFIN') } )
    oView:SetFieldAction( 'F1_NATUREZ', { |oView| ViewRfresh(oView, 'oStruFIN') } )
    oView:SetFieldAction( 'F1_MOEDA',   { |oView| ViewRfresh(oView, 'oStruFIN') } )
    oView:SetFieldAction( 'F1_MOEFIN',  { |oView| F1PaymntCn(oView:GetModel("SF1_MASTER"):GetValue("F1_COND")), ViewRfresh(oView, 'oStruFIN') } )

Return

/*/{Protheus.doc} LxFisView
Función utilizada para actualizar la estructura para el apartado fiscal de la view
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxFisView(oView)
Local oStruSF3	    := FWFormStruct( 2, 'SF3',, .T.)
Local oStruIMP	    := FWFormViewStruct():New()

    oView:AddGrid('oStruSF3' , oStruSF3, 'SF3_DETAIL' )
    oView:EnableTitleView("oStruSF3",  STR0003 ) //'Fiscales'

    oStruIMP:AddField('IMP_COD' 	, '1',  STR0004     , STR0004	    , NIL, 'GET', , , , .F.) //'Cod. Imp.'
	oStruIMP:AddField('IMP_DESC' 	, '2',  STR0005	    , STR0005	    , NIL, 'GET', , , , .F.) //'Descripción'
	oStruIMP:AddField('IMP_ALQIMP'  , '3',  STR0006     , STR0006	    , NIL, 'GET', Alltrim(GetSx3Cache("FB_ALIQ","X3_PICTURE")), , , .F.) //'Alic.'
	oStruIMP:AddField('IMP_BASIMP' 	, '4',  STR0007	    , STR0007       , NIL, 'GET', Alltrim(GetSx3Cache("F1_BASIMP1","X3_PICTURE")), , , .F.) //'Base'
    oStruIMP:AddField('IMP_VALIMP' 	, '5',  STR0008     , STR0008	    , NIL, 'GET', Alltrim(GetSx3Cache("F1_VALIMP1","X3_PICTURE")), , , .F.) //'Valor Impuesto'

    oView:AddGrid('oStruIMP' , oStruIMP, 'IMP_DETAIL' )
    oView:EnableTitleView("oStruIMP",  STR0009 ) //Impuestos

Return

/*/{Protheus.doc} LxDupView
Función utilizada para actualizar la estructura para el apartado de titulos de la view
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxDupView(oView)
Local oStruDUP	:= FWFormViewStruct():New()
Local nTamDup   := 0
    
    //
    nTamDup := GetSx3Cache('E2_NUM', 'X3_TAMANHO') + GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO') +  GetSx3Cache('E2_PARCELA', 'X3_TAMANHO') + GetSx3Cache('E2_VENCTO', 'X3_TAMANHO') +  GetSx3Cache('E2_VALOR', 'X3_TAMANHO') + 12
    //oStruDUP:AddField('DUP' 	    , '1',  'DUP'	, 'DUP'	, NIL, 'GET', , , , .F.)
    oStruDUP:AddField('DUP_NUM' 	, '1',  STR0015 , STR0015	, NIL, 'GET', , , , .F.) //'Número'
    oStruDUP:AddField('DUP_PREFIX' 	, '2',  STR0016	, STR0016	, NIL, 'GET', , , , .F.) //'Serie'
    oStruDUP:AddField('DUP_PARCEL'  , '3',  STR0017	, STR0017	, NIL, 'GET', , , , .F.) //'Cuota'
    oStruDUP:AddField('DUP_VENCTO'  , '4',  STR0018	, STR0018	, NIL, 'GET', , , , .T.) //'Vecto'
    oStruDUP:AddField('DUP_VALOR'   , '5',  STR0019 , STR0019	, NIL, 'GET', Alltrim(GetSx3Cache("E1_VALOR","X3_PICTURE")), , , .T.) //'Valor'

    oView:AddGrid('oStruDUP' , oStruDUP, 'DUP_DETAIL' )
    oView:GetModel("SF1_MASTER"):GetStruct():SetProperty( 'F1_COND', MODEL_FIELD_WHEN  , {|| VF1_COND()} )

    oView:EnableTitleView("oStruDUP",  STR0010 ) //'Titulos'

    // Deshabilita las alteraciones en la view de titulos.
    oView:SetNoInsertLine("DUP_DETAIL")
    oView:SetNoDeleteLine("DUP_DETAIL")

    oView:SetFieldAction( 'DUP_VENCTO', { |oView| UpdTitMod(oView:GetModel(), "SF1_MASTER") } )
    oView:SetFieldAction( 'DUP_VALOR',  { |oView| UpdTitMod(oView:GetModel(), "SF1_MASTER") } )
	If oView:GetModel("SF1_MASTER"):HasField("F1_PV")
        oView:SetFieldAction( 'F1_EMISSAO',  { |oView| ViewCalcIn(oView) } )
    Else
        oView:SetFieldAction( 'F1_EMISSAO',  { |oView| F1PaymntCn(FWFLDGET('F1_COND')) } )
    EndIf

Return

/*/{Protheus.doc} LxTotView
Función utilizada para actualizar la estructura para el apartado de totales de la view
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxTotView(oView)
Local oStruTot	    := Nil 

    oStruTot := FWCalcStruct( oView:GetModel():GetModel( 'TOTCALC') )
    oView:AddField('oStruTot', oStruTot, 'TOTCALC')
    oView:EnableTitleView('oStruTot', STR0014 ) //'Totales'
    
Return

/*/{Protheus.doc} ModFisStru
Función utilizada para actualizar la estructura fiscal
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oModel - - modelo a ser actualizado con la estructura del documento recibido, debe ser enviado como @oModel.
@Return 
/*/
Function ModFisStru(oModel)
Local oStruIMP		:= FWFormModelStruct():New()
Local oStruSF3	    := FWFormStruct(1, 'SF3', , .F.)

    oStruIMP:AddTable('' , { '' } , "IMPUESTOS", {|| ''})
    oStruIMP:AddField(STR0004, STR0004, "IMP_COD",'C', GetSx3Cache("FB_CODIGO","X3_TAMANHO")) //'Cod. Imp.'
    oStruIMP:AddField(STR0005, STR0005, "IMP_DESC",'C', GetSx3Cache("FB_DESCR","X3_TAMANHO")) //'Descripción'
    If !Empty(GetSx3Cache("FB_ALIQ","X3_CAMPO"))
        oStruIMP:AddField(STR0006, STR0006, "IMP_ALQIMP",'N', GetSx3Cache("FB_ALIQ","X3_TAMANHO"), GetSx3Cache("FB_ALIQ","X3_DECIMAL")) //'Alic.'
    EndIf
    oStruIMP:AddField(STR0007, STR0007, "IMP_BASIMP",'N', GetSx3Cache("F1_BASIMP1","X3_TAMANHO"), GetSx3Cache("F1_BASIMP1","X3_DECIMAL")) //'Base'
    oStruIMP:AddField(STR0008, STR0008, "IMP_VALIMP",'N', GetSx3Cache("F1_VALIMP1","X3_TAMANHO"), GetSx3Cache("F1_VALIMP1","X3_DECIMAL")) //'Valor Impuesto'

    oStruSF3:SetProperty( '*'           , MODEL_FIELD_OBRIGAT , .F.)
    
    oModel:addGrid('IMP_DETAIL','SF1_MASTER',oStruIMP,,,,,{|oGrid| LoadGridImp(oGrid)})
    oModel:addGrid('SF3_DETAIL','SF1_MASTER',oStruSF3,,)

    oModel:SetRelation('SF3_DETAIL',{ { 'F3_FILIAL', 'xFilial( "SF3" )' }, {'F3_CLIEFOR', 'F1_FORNECE'}, {'F3_LOJA', 'F1_LOJA'}, {'F3_NFISCAL', 'F1_DOC'}, {'F3_SERIE', 'F1_SERIE'} }, SF3->(IndexKey(4))) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

    oModel:GetModel( 'IMP_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SF3_DETAIL' ):SetOptional(.T.)

    oModel:GetModel('IMP_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SF3_DETAIL'):SetOnlyQuery(.T.)

    oModel:GetModel("SF3_DETAIL"):SetNoInsertLine()
    oModel:GetModel("SF3_DETAIL"):SetNoUpdateLine()
    oModel:GetModel("SF3_DETAIL"):SetNoDeleteLine()

    oModel:GetModel("IMP_DETAIL"):SetNoInsertLine()
    oModel:GetModel("IMP_DETAIL"):SetNoUpdateLine()
    oModel:GetModel("IMP_DETAIL"):SetNoDeleteLine()

Return

/*/{Protheus.doc} LxViewInF
Función utilizada para crear los box de los documentos que incluyen fiscal, impuestos, titulos y financiero.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxViewInF(oView) 

    oView:CreateHorizontalBox( 'CIMA'   , 15 ) //Encabezado
    oView:CreateHorizontalBox( 'CIMAFIN', 05 ) //Financiero
	oView:CreateHorizontalBox( 'MEDIO'  , 60 ) //Grid items
	oView:CreateHorizontalBox( 'BAIXOT' , 05 ) //Total
    oView:CreateHorizontalBox( 'BAIXOF' , 15 ) //Financiero/Fiscales

    oView:CreateFolder("FOLDER","BAIXOF")
    oView:AddSheet( 'FOLDER', 'SHEET_TIT', STR0010 ) //'Titulos'
    oView:AddSheet( 'FOLDER', 'SHEET_LIBROS', STR0013 ) //'Libros Fiscales'
    oView:AddSheet( 'FOLDER', 'SHEET_IMP', STR0009 ) //'Impuestos'
    oView:CreateHorizontalBox( 'TITULOS', 100, , , 'FOLDER', 'SHEET_TIT')
    oView:CreateHorizontalBox( 'LIBROS', 100, , , 'FOLDER', 'SHEET_LIBROS')
    oView:CreateHorizontalBox( 'IMPUESTOS', 100, , , 'FOLDER', 'SHEET_IMP') 

    oView:SetOwnerView('oStruSF1', 'CIMA')
    oView:SetOwnerView('oStruFIN', 'CIMAFIN')
	oView:SetOwnerView('oStruSD1', 'MEDIO')
    oView:SetOwnerView('oStruTot', 'BAIXOT')
    oView:SetOwnerView('oStruDUP', 'TITULOS')
    oView:SetOwnerView('oStruSF3', 'LIBROS')
    oView:SetOwnerView('oStruIMP', 'IMPUESTOS')

Return

/*/{Protheus.doc} LxInViewIn
Función utilizada para crear los box de los documentos que no datos fiscales ni fincieros.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxInViewIn(oView)

    //Divisiones horizontales
	oView:CreateHorizontalBox( 'CIMA' , 20 )
	oView:CreateHorizontalBox( 'MEDIO', 60 )
	oView:CreateHorizontalBox( 'BAIXO', 20 )

Return

/*/{Protheus.doc} VD1_COD
	Función encargada de realizar las validaciones para el campo D1_COD.
	@type  Function
	@author raul.medina
	@since 
	@param
	@return 
		lValid -Logico - Devuelve el resultado de las validaciones.
	/*/
Function VD1_COD()
Local lRet      := .T.

    If !(Type("cTipo") == "C")
		cTipo  := FwFldGet("F1_TIPO")
	EndIf

    If !(Type("lConsLoja") == "L")
		lConsLoja  := .F.
	EndIf

    If !(Type("cA100For") == "C")
		cA100For  := FwFldGet("F1_FORNECE")
	EndIf


    lRet := Vazio() .or. (A093Prod() .And. A103PrdGrd() .And. MaFisRef("IT_PRODUTO","MT100",M->D1_COD))

Return lRet

/*/{Protheus.doc} VD1_VUNIT
	Función encargada de realizar las validaciones para el campo D1_VUNIT.
	@type  Function
	@author raul.medina
	@since 
	@param
	@return 
		lValid -Logico - Devuelve el resultado de las validaciones.
	/*/
Function VD1_VUNIT()
Local lRet      := .T.

    If !(Type("cTipo") == "C")
		cTipo  := FwFldGet("F1_TIPO")
	EndIf

    lRet := A103TOLER() .And. MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)

Return lRet

/*/{Protheus.doc} VD1_TOTAL
	Función encargada de realizar las validaciones para el campo D1_TOTAL.
	@type  Function
	@author raul.medina
	@since 
	@param
	@return 
		lValid -Logico - Devuelve el resultado de las validaciones.
	/*/
Function VD1_TOTAL()
Local lRet      := .T.

    If !(Type("cTipo") == "C")
		cTipo  := FwFldGet("F1_TIPO")
	EndIf

    lRet := A103Total(M->D1_TOTAL) .and. MaFisRef("IT_VALMERC","MT100",M->D1_TOTAL) .And. MTA103TROP(n)

Return lRet

/*/{Protheus.doc} VD1_RATEIO
	Función encargada de realizar las validaciones para el campo D1_RATEIO.
	@type  Function
	@author raul.medina
	@since 
	@param
	@return 
		lValid -Logico - Devuelve el resultado de las validaciones.
	/*/
Function VD1_RATEIO()
Local lRet      := .T.

    If !(Type("l103Auto") == "L")
		l103Auto := Iif(IsBlind(), .T., .F.)
	EndIf

    lRet := Pertence("12 ") .And. A103RatCC(M->D1_RATEIO)

Return lRet

/*/{Protheus.doc} CalcImpIN
	Función utilizada para realizar el calculo de impuestos de acuerdo a los datos del model, así como la asignación de valores al model.
	@type  Function
	@author raul.medina
    @since 		08/2023
    @version	12.1.2210 / Superior
	@return 
	/*/
Function CalcImpIN()
Local oModel        := FwModelActivate()
Local cCliFor       := ""
Local cLoja         := ""
Local cTipoCF       := ""
Local cTipo         := ""
Local cAliasProd    := "SB1"
Local cTipoDoc      := ""
Local cEspecie      := ""
Local cSerie        := ""
Local cPaymntCnd    := ""
Local nNFMoeda      := 1
Local nTxMoeda      := 0
Local nFlete        := 0
Local nGastos       := 0 
Local nSeguro       := 0
Local nTipCli       := 0
Local aOldData      := {}
Local aCitensOri    := {}
Local aCpItensOri   := {}
Local ojson         := Nil
Local lCalcVal      := .F.
Local dDEmissao := dDataBase
Local cCodICA       := ""
Local cCodMun       := ""
Local aClientes     := {"1","2","3","4","5","12","17","19","21","24","50","51","53","62","63"}
Local lPropGastos     := SuperGetMV("MV_FRT103E",.F.,.T.)
Local cEst          := ""
Local cProvent      := ""

    If oModel:GetModel("SF1_MASTER"):HasField("CALC") .and. !oModel:GetModel("SF1_MASTER"):GetValue("CALC") //CALC el falso indica que ya existe calculo y no lo realizará.
        Return .F.
    EndIf
    If lPropGastos .And. oModel:GetModel("SF1_MASTER"):HasField("CALCGASTOS") .And. oModel:GetModel("SF1_MASTER"):GetValue("CALCGASTOS")
        RecalGasto(oModel) //recalcular los gastos en el documento de entrada a partir de los ítems del pedido de compra
        oModel:GetModel("SF1_MASTER"):LoadValue("CALCGASTOS", .F.)
    EndIf
    cCliFor       := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja         := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cTipoCF       := "F"
    cTipo         := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    cTipoDoc      := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC")
    cEspecie      := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
    cSerie        := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    nNFMoeda      := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    nTxMoeda      := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
    cPaymntCnd    := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")
    nFlete        := oModel:GetModel("SF1_MASTER"):GetValue("F1_FRETE")
    nGastos       := oModel:GetModel("SF1_MASTER"):GetValue("F1_DESPESA")
    nSeguro       := oModel:GetModel("SF1_MASTER"):GetValue("F1_SEGURO")
    nDescont      := oModel:GetModel("SF1_MASTER"):GetValue("F1_DESCONT")
	dDEmissao     := oModel:GetModel("SF1_MASTER"):GetValue("F1_EMISSAO")
    If oModel:GetModel("SF1_MASTER"):HasField("F1_TPACTIV")
        cCodICA       := oModel:GetModel("SF1_MASTER"):GetValue("F1_TPACTIV")
    EndIf
    If oModel:GetModel("SF1_MASTER"):HasField("F1_CODMUN")
        cCodMun      := oModel:GetModel("SF1_MASTER"):GetValue("F1_CODMUN")
    EndIf
    If oModel:GetModel("SF1_MASTER"):HasField("F1_EST")
        cEst       := oModel:GetModel("SF1_MASTER"):GetValue("F1_EST")
    EndIf
    If oModel:GetModel("SF1_MASTER"):HasField("F1_PROVENT")
        cProvent   := oModel:GetModel("SF1_MASTER"):GetValue("F1_PROVENT")
    EndIf
    aOldData      := {}
    aCitensOri    := {}
    aCpItensOri   := {}
    lCalcVal      := !&(IsRemito(2,"'" + cTipoDoc + "'"))
    aOldData      := oModel:GetModel("SD1_DETAIL"):GetOldData()
    aCpItensOri   := aOldData[1]
    aCitensOri    := aOldData[2]
    nTipCli       := aScan(aClientes, { |x| x == cTipoDoc })

    If nTipCli > 0
        cTipoCF := "C"
    EndIf

    //Llamada a la función de calculo.
    ojson := CalImpxMod(cCliFor, cLoja, cTipoCF, cTipo, cAliasProd, cTipoDoc, cEspecie, cSerie, nNFMoeda, nTxMoeda, aCpItensOri, aCitensOri, lCalcVal, nFlete, nGastos, nSeguro, nDescont, dDEmissao, cCodICA, cCodMun,,,cEst,cProvent)

    //Actualización de los valores de los impuestos y libros fiscales.
    ActCalcFis(oModel, ojson, lCalcVal, "SF1_MASTER")

    //Actualización de items
    ActItemsIN(oModel, ojson)

    If oModel:GetModel("SF1_MASTER"):HasField("CALC")
        oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .F.) //Cambia flag para indicar que no se debe recalcular.
    EndIf

    //Se actualizan los datos de los títulos.
    If lCalcVal
        F1PaymntCn(cPaymntCnd)
    EndIf

    //Actualización de datos de la multi naturaleza.
    MActValSEV(oModel:GetModel("SEV_DETAIL"), cTipoDoc, oModel:GetModel("SF1_MASTER"):GetValue("BASEDUP"))

Return .T.

/*/{Protheus.doc} ViewCalcIn
Función utilizada para realizar la llamada de calculo de impuestos/valores y actualización de las views.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido.
@Return 
/*/
Function ViewCalcIn(oView)
Local lRefresh      := .T.
Local nFocus        := GetFocus()
Local aModelsId     := {}
Local nOper         := oView:GetOperation()
Local oModel        := oView:oModel

    If nOper == MODEL_OPERATION_INSERT .and. oModel:GetModel("SF1_MASTER"):HasField("CALC") .and. oModel:GetModel("SF1_MASTER"):GetValue("CALC") //CALC en falso indica que no debe realizarse el calculo (Ya realizado).
        FWMsgRun( , {|| lRefresh := CalcImpIN()}, STR0020, STR0020 )
        If lRefresh
            oView:Refresh("oStruSD1")
            oView:Refresh("oStruTot")
            aModelsId := oView:GetModelsIds()
            If FindString("SF3_DETAIL", aModelsId) //Verificación de existencia del grid
                oView:Refresh("oStruSF3")
            EndIf
            If FindString("IMP_DETAIL", aModelsId) //Verificación de existencia del grid
                oView:Refresh("oStruIMP")
            EndIf
            SetFocus(nFocus)
            If oModel:GetModel("SF1_MASTER"):HasField("ALTIMP") .and.  oModel:GetModel("SF1_MASTER"):GetValue("ALTIMP")
                oModel:GetModel("SF1_MASTER"):LoadValue("ALTIMP", .F.) //Informa del borrado de modificaciones.
                MsgInfo(STR0029, STR0028)//"Es necesario ajustar nuevamente los valores actualizados en edición de impuestos."   "Edición de impuestos"
            EndIf
           
        EndIf
    EndIf

Return

/*/{Protheus.doc} F1PaymntCn
Función utilizada para realizar la llamada de la actualización de los valores de los títulos..
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    cCondition - caracter - código de la condición de pago utilizada.
@Return 
/*/
Function F1PaymntCn(cCondition)
Local oModel    := FwModelActivate()
Local oModelSF1 := oModel:GetModel("SF1_MASTER")
Local oModelSD1 := oModel:GetModel("SD1_DETAIL")
Local nMoedaFin := 1
Local aOldData  := {}

//Variables privadas para Colombia.
Private N       := oModelSD1:GetLine()
Private aHeader := {}
Private aCols   := {}

Default cCondition  := ""

    aOldData := oModelSD1:GetOldData()
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])

    nMoedaFin := IIf(oModelSF1:HasField("F1_MOEFIN") .and. !Empty(oModelSF1:GetValue("F1_MOEFIN")),  oModelSF1:GetValue("F1_MOEFIN"), oModelSF1:GetValue("F1_MOEDA"))
    MPaymntCon(@oModel, oModelSF1:GetValue("BASEDUP"), oModelSF1:GetValue("F1_MOEDA"), oModelSF1:GetValue("F1_EMISSAO"), cCondition, oModelSF1:GetValue("F1_NATUREZ"), oModelSF1:GetValue("F1_TXMOEDA"), oModelSF1:GetValue("F1_DOC"), oModelSF1:GetValue("F1_SERIE"), nMoedaFin)

Return

/*/{Protheus.doc} LoadGridImp
Función utilizada para realizar la carga inicial de los impuestos al visualizar o borrar un documento.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oGrid -  - submodelo del grid que está siendo inicializado.
@Return 
    aLoadGrid - array - Información para ser asiganada al grid.
/*/
Static Function LoadGridImp(oGrid)
Local aLoadGrid	:= {}

    If oGrid:GetOperation() == MODEL_OPERATION_DELETE .Or. oGrid:GetOperation() == MODEL_OPERATION_VIEW
        aLoadGrid := GImpostosD1(FwFldGet("F1_DOC"), FwFldGet("F1_SERIE"), FwFldGet("F1_FORNECE"), FwFldGet("F1_LOJA"), FwFldGet("F1_ESPECIE"))
    EndIf

Return aLoadGrid

/*/{Protheus.doc} LoadGridDup
Función utilizada para realizar la carga inicial de los títulos al visualizar o borrar un documento.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oGrid -  - submodelo del grid que está siendo inicializado.
@Return 
    aLoadGrid - array - Información para ser asiganada al grid.
/*/
Static Function LoadGridDup(oGrid)
Local aLoadGrid	:= {}
Local oTipoDoc
Local cTable    := ""

    If oGrid:GetOperation() == MODEL_OPERATION_DELETE .Or. oGrid:GetOperation() == MODEL_OPERATION_VIEW
        oTipodoc := TipoDoc():New()
        oTipoDoc:SetTipoDoc(FwFldGet("F1_TIPODOC"))
        cTable := oTipoDoc:GetTableFinDoc()
        aLoadGrid := GetDupFin(cTable, FwFldGet("F1_DOC"), FwFldGet("F1_SERIE"), FwFldGet("F1_FORNECE"), FwFldGet("F1_LOJA"), FwFldGet("F1_ESPECIE"))
    EndIf

Return aLoadGrid

/*/{Protheus.doc} LxSCMToREM
Función utilizada para realizar la llamada de la pantalla de Remitos.
@author 	raul.medina
@since 		09/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf..
@Return 
/*/
Function LxSCMToREM(oModel)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local oModelSDE     := oModel:GetModel("SDE_DETAIL")
Local aOldData
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local nPosCod       := 0
Local cDoc          := ""
Local cSerie        := ""
Local oStruSD1      := Nil
Local lRet          := .F.
Local aCposSDE      := {}
Private aHeader     := {}
Private aCols       := {}
Private cCliFor     := ""
Private cLoja       := ""
Private cCadastro   := ""
Private aHeaderSDE  := {}
Private aRatCC      := {}
Private cCondicao   := ""
Private aPE         := {}

    aOldData := oModelSD1:GetOldData()
    cCliFor := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    oStruSD1 := oModelSD1:GetStruct()
    nPosCod := oStruSD1:GetFieldPos("D1_COD")
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])
    aCposSDE := GetCposSDE(oModelSDE)
    aRatCC := GetModSDE(oModelSDE, aCposSDE)
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF1CfgNF()
    EndIf
    cCadastro:= aCfgNF[20]
    aPE := aClone(aCfgNF[17])
    If SCMToREM(.F.)
        oModelSD1:ClearData(.F., .T.)
        For nX := 1 To Len(aCols)
            If !Empty(aCols[nX][nPosCod])
                If oModelSD1:Length() < nX
                    oModelSD1:LVALID := .T. //Actualización x campo
                    oModelSD1:AddLine()
                EndIf
                //Actualización x campo
                For nY := 1 To Len(aHeader)
                    If !Empty(aCols[nX][nY])
                        xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                        oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                    EndIf
                Next
                oModelSD1:LoadValue("D1_DOC", cDoc)
                oModelSD1:LoadValue("D1_SERIE", cSerie)
                oModelSD1:LoadValue("D1_FORNECE", cCliFor)
                oModelSD1:LoadValue("D1_LOJA", cLoja)
                oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
                lRet := .T.
            EndIf
        Next
        oModelSD1:GoLine(1)
        ActModSDE(oModelSDE, aCposSDE, aRatCC)

        oModel:GetModel("SF1_MASTER"):LoadValue("F1_FRETE", M->F1_FRETE)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_SEGURO", M->F1_SEGURO)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESPESA", M->F1_DESPESA)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESCONT", M->F1_DESCONT)

        If !Empty(cCondicao)
            oModel:GetModel("SF1_MASTER"):LoadValue("F1_COND", cCondicao)
        EndIf
        
        If lRet .and. oModel:GetModel("SF1_MASTER"):HasField("CALC")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
        EndIf
    EndIf

    aSize(aPE, 0)

Return lRet

/*/{Protheus.doc} LxSCMToNF
Función utilizada para realizar la llamada de la pantalla de Remitos por item
@author 	raul.medina
@since 		09/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf..
@Return 
/*/
Function LxSCMToNF(oModel)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local oModelSDE     := oModel:GetModel("SDE_DETAIL")
Local aOldData
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local nPosCod       := 0
Local cDoc          := ""
Local cSerie        := ""
Local oStruSD1      := Nil
Local lRet          := .F.
Local nDelLine      := 0
Local aCposSDE      := {}
Private aHeader     := {}
Private aCols       := {}
Private aRatCC      := {}
Private cCliFor     := ""
Private cLoja       := ""
Private cCadastro   := ""
Private cCondicao   := ""
Private aPE         := {}

    aOldData := oModelSD1:GetOldData()
    cCliFor := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    oStruSD1 := oModelSD1:GetStruct()
    nPosCod := oStruSD1:GetFieldPos("D1_COD")
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])
    aCposSDE := GetCposSDE(oModelSDE)
    aRatCC := GetModSDE(oModelSDE, aCposSDE)
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF1CfgNF()
    EndIf
    cCadastro:= aCfgNF[20]
    aPE := aClone(aCfgNF[17])
    If SCMToNF(.F.)
        nDelLine := Len(aHeader)+1 
        oModelSD1:ClearData(.F., .T.)
        For nX := 1 To Len(aCols)
            If !Empty(aCols[nX][nPosCod])
                If oModelSD1:Length() < nX
                    oModelSD1:LVALID := .T. //Actualización x campo
                    oModelSD1:AddLine()
                EndIf
                //Actualización x campo
                For nY := 1 To Len(aHeader)
                    If !Empty(aCols[nX][nY])
                        xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                        oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                    EndIf
                Next
                oModelSD1:LoadValue("D1_DOC", cDoc)
                oModelSD1:LoadValue("D1_SERIE", cSerie)
                oModelSD1:LoadValue("D1_FORNECE", cCliFor)
                oModelSD1:LoadValue("D1_LOJA", cLoja)
                oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
                lRet := .T.
                If aCols[nX][nDelLine]
                    oModelSD1:DeleteLine()
                EndIf
            EndIf
        Next
        oModelSD1:GoLine(1)
        ActModSDE(oModelSDE, aCposSDE, aRatCC)

        oModel:GetModel("SF1_MASTER"):LoadValue("F1_FRETE", M->F1_FRETE)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_SEGURO", M->F1_SEGURO)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESPESA", M->F1_DESPESA)

        If !Empty(cCondicao)
            oModel:GetModel("SF1_MASTER"):LoadValue("F1_COND", cCondicao)
        EndIf

        If lRet .and. oModel:GetModel("SF1_MASTER"):HasField("CALC")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
        EndIf
    EndIf

    aSize(aPE, 0)

Return lRet

/*/{Protheus.doc} ModRatCC
Función utilizada para realizar el mantenimiento de prorrateo contable por item.
@author 	raul.medina
@since 		09/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf..
@Return 
/*/
Function ModRatCC(oModel)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local oModelSDE     := oModel:GetModel("SDE_DETAIL")
Local nOper         := oModel:GetOperation()
Local aOldData      := {}
Local aCposSDE      := {}
Local nPosCC		:= oModelSD1:GetStruct():GetFieldPos("D1_CC")
Local nPosConta		:= oModelSD1:GetStruct():GetFieldPos("D1_CONTA")
Local nPosItemCta	:= oModelSD1:GetStruct():GetFieldPos("D1_ITEMCTA")
Local nPosCLVL		:= oModelSD1:GetStruct():GetFieldPos("D1_CLVL")
Local nPosRateio	:= oModelSD1:GetStruct():GetFieldPos("D1_RATEIO")
Private aHeader     := {}
Private aCols       := {}
Private aRatCC    	:= {}
Private aRotina     := {}
Private n           := oModelSD1:GetLine()
Private l103Visual  := .F.
Private lInclui     := nOper == MODEL_OPERATION_INSERT
Private cSerie      := ""
Private cNFiscal    := ""

    cSerie  := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    cNFiscal := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    aOldData := oModelSD1:GetOldData()
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])

    aCposSDE := GetCposSDE(oModelSDE)
    aRatCC := GetModSDE(oModelSDE, aCposSDE)
    Lxa103RatCC(,aCposSDE)
    
    If lInclui
        //Actualización SDE
        ActModSDE(oModelSDE, aCposSDE, aRatCC)
        oModelSD1:LoadValue("D1_CC", aCols[n][nPosCC])
        oModelSD1:LoadValue("D1_CONTA", aCols[n][nPosConta])
        oModelSD1:LoadValue("D1_ITEMCTA", aCols[n][nPosItemCta])
        oModelSD1:LoadValue("D1_CLVL", aCols[n][nPosCLVL])
        oModelSD1:LoadValue("D1_RATEIO", aCols[n][nPosRateio])
    EndIf

Return

/*/{Protheus.doc} MultiNatIn
Función utilizada para la llamada del prorrateo de la multinaturaleza.
@author 	raul.medina
@since 		10/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function MultiNatIn(oModel)
Local oModelSEV     := oModel:GetModel("SEV_DETAIL")
Local oModelSDE     := oModel:GetModel("SDE_DETAIL")
Local nOperation    := oModel:GetOperation()
Local nValor        := oModel:GetModel("SF1_MASTER"):GetValue("BASEDUP")

    RatMulTiNat(oModelSEV, nOperation, nValor, oModelSDE)

Return

/*/{Protheus.doc} LxLegendIn
Función utilizada para la llamada la función de leyendas de la locxnf.
@author 	raul.medina
@since 		11/2023
@version	12.1.2210 / Superior
Parametros
@Return 
/*/
Function LxLegendIn()

Private lIntegracao	:= SuperGetMV("MV_EASY",.F.,"N") == "S"
Private aCfgNf      := {}

    aCfgNf  := GetCfgNF(SF1->F1_TIPODOC)

    LocxLegenda("SF1")

Return

/*/{Protheus.doc} LxNFForF6
Función utilizada para realizar la llamada de la pantalla de Remitos por item
@author 	raul.medina
@since 		09/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf..
@Return 
/*/
Function LxNFForF6(oModel) 
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local aOldData
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local nPosCod       := 0
Local nTipo         := 0
Local cDoc          := ""
Local cSerie        := ""
Local oStruSD1      := Nil
Local lRet          := .F.
Local nDelLine      := 0
Local nMoneda       := 0
Local nTaxaMon      := 0
Private aHeader     := {}
Private aCols       := {}
Private cCliFor    := ""
Private cLoja       := ""
Private cCadastro   := ""

    aOldData := oModelSD1:GetOldData()
    cCliFor := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    nTipo := Val(oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC"))
    nMoneda := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    nTaxaMon := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
    oStruSD1 := oModelSD1:GetStruct()
    nPosCod := oStruSD1:GetFieldPos("D1_COD")
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF1CfgNF()
    EndIf
    If LxN466ForF6(nTipo, nMoneda, nTaxaMon)
        nDelLine := Len(aHeader)+1 
        oModelSD1:ClearData(.F., .T.)
        For nX := 1 To Len(aCols)
            If !Empty(aCols[nX][nPosCod])
                If oModelSD1:Length() < nX
                    oModelSD1:LVALID := .T. //Actualización x campo
                    oModelSD1:AddLine()
                EndIf
                //Actualización x campo
                For nY := 1 To Len(aHeader)
                    If !Empty(aCols[nX][nY])
                        xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                        oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                    EndIf
                Next
                oModelSD1:LoadValue("D1_DOC", cDoc)
                oModelSD1:LoadValue("D1_SERIE", cSerie)
                oModelSD1:LoadValue("D1_FORNECE", cCliFor)
                oModelSD1:LoadValue("D1_LOJA", cLoja)
                oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
                lRet := .T.
                If aCols[nX][nDelLine]
                    oModelSD1:DeleteLine()
                EndIf
            EndIf
        Next
        oModelSD1:GoLine(1)

        If lRet .and. oModel:GetModel("SF1_MASTER"):HasField("CALC")
            oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} BtnPrnfBen
Función utilizada para verificar si debe ser incluida la opción de devolución de mejora (Remito - 60 y Factura - 10)
@author 	raul.medina
@since 		11/2023
@version	12.1.2210 / Superior
Parametros
@Return 
/*/
Function BtnPrnfBen()
Local lRet      := .F.
Local lPrnfben  := SuperGetMV("MV_PRNFBEN",.F.,.F.)

    If lPrnfben
        SF5->(dbSetOrder(1))
		If SF5->(MsSeek(xFilial("SF5")+GetMV("MV_TMPAD")))
            lRet := .T.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LxF1Track
Función utilizada para realizar la carga de devolución de mejora.
@author 	raul.medina
@since 		11/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function LxaRetBen(oModel)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local aOldData
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local nPosCod       := 0
Local nNFMoeda      := 1
Local nTxMoeda      := 0
Local cDoc          := ""
Local cSerie        := ""
Local cTipoDoc      := ""
Local cEspecie      := ""
Local oStruSD1      := Nil

Private aHeader     := {}
Private aCols       := {}
Private cA100For    := ""
Private cLoja       := ""
Private lConsLoja   := .T.
Private n           := oModelSD1:GetLine()
Private cTipo       := ""
Private bRefresh    := {||}

    aOldData := oModelSD1:GetOldData()
    cA100For := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    cTipo  := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    cTipoDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC")
    cEspecie := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
    nNFMoeda := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    nTxMoeda := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
    lCalcImp := !&(IsRemito(2,"'" + cTipoDoc + "'"))
    oStruSD1 := oModelSD1:GetStruct()
    nPosCod := oStruSD1:GetFieldPos("D1_COD")
    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])

    If !MaFisRestore()
        MaFisIni(cA100For, cLoja, "F", cTipo, Nil, , , .F., "SB1", , cTipoDoc, cEspecie)
        MaFisAlt("NF_SERIENF", cSerie)
        MaFisAlt("NF_MOEDA"  , nNFMoeda)
        MaFisAlt("NF_TXMOEDA", nTxMoeda)
    EndIf

    If ARetBenef()
        nDelLine := Len(aHeader)+1 
        oModelSD1:ClearData(.F., .T.)
        For nX := 1 To Len(aCols)
            If !Empty(aCols[nX][nPosCod])
                If oModelSD1:Length() < nX
                    oModelSD1:LVALID := .T. //Actualización x campo
                    oModelSD1:AddLine()
                EndIf
                //Actualización x campo
                For nY := 1 To Len(aHeader)
                    If !Empty(aCols[nX][nY])
                        xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                        oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                    EndIf
                Next
                oModelSD1:LoadValue("D1_DOC", cDoc)
                oModelSD1:LoadValue("D1_SERIE", cSerie)
                oModelSD1:LoadValue("D1_FORNECE", cA100For)
                oModelSD1:LoadValue("D1_LOJA", cLoja)
                oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
                If aCols[nX][nDelLine]
                    oModelSD1:DeleteLine()
                EndIf
            EndIf
        Next
        oModelSD1:GoLine(1)

        ojson := GetCalxFis(aCols, .T.)
        ActCalcFis(oModel, ojson, lCalcImp, "SF1_MASTER")
    EndIf

    MaFisSave()
    MaFisEnd()

Return

/*/{Protheus.doc} LxMNFDesp
Función utilizada para realizar la carga de devolución de mejora.
@author 	raul.medina
@since 		11/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
    nTipNota - numerico - Tipo de documento.
@Return 
/*/
Function LxMNFDesp(oModel, nTipNota)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local aOldData
Local nNFMoeda      := 1
Local nTxMoeda      := 0
Local cDoc          := ""
Local cSerie        := ""
Local cTipoDoc      := ""
Local cEspecie      := ""
Local cPaymntCnd    := ""
Local ojson         

Private aHeader     := {}
Private aCols       := {}
Private cA100For    := ""
Private cLoja       := ""
Private n           := oModelSD1:GetLine()
Private cTipo       := ""

Private aHGastos	:= {}	//utilizados pela locxgastos
Private aCGastos	:= {}	//inclusao das despesas na nota de frete
Private aIndD1D2    := {}
Private aAmarrAFN   := {}
Private bFilBrw     := {||}

Default nTipNota    := 1

    aOldData := oModelSD1:GetOldData()
    cA100For := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    cTipo  := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    cTipoDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC")
    cEspecie := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
    nNFMoeda := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    nTxMoeda := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
    cPaymntCnd := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")

    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])

    If !MaFisRestore()
        MaFisIni(cA100For, cLoja, "F", cTipo, Nil, , , .F., "SB1", , cTipoDoc, cEspecie)
        MaFisAlt("NF_SERIENF", cSerie)
        MaFisAlt("NF_MOEDA"  , nNFMoeda)
        MaFisAlt("NF_TXMOEDA", nTxMoeda)
    EndIf

    If LocxNFDesp(nTipNota, .F.)
        
        //Llenado de items en el model.
        LoadSD1It(aHeader, aCols, @oModelSD1, .T., cDoc, cSerie, cA100For, cLoja)

        oModelSD1:GoLine(1)

        ojson := GetCalxFis(aCols, .T.)
        ActCalcFis(oModel, ojson, .T., "SF1_MASTER")
    EndIf

    MaFisSave()
    MaFisEnd()

    F1PaymntCn(cPaymntCnd)

Return

/*/{Protheus.doc} LoadSD1It
Función utilizada para realizar la carga de los items al model.
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
Parametros
    aHeader - array - array del encabezado  de los items.
    aCols - array - acols de los items..
    oModelSD1 -  - Submodel de los tiems.
    lMarcaDel - logico - Indica si debe marcar los registros como borrados.
    cDoc - string - Número del documento.
    cSerie - string - Serie del documento.
    cCliFor - string - Proveedor con el cual se está creando el documento.
    cLoja - string - Tienda del proveedor con el cual se está creando el documento.
@Return 
/*/
Static Function LoadSD1It(aHeader, aCols, oModelSD1, lMarcaDel, cDoc, cSerie, cCliFor, cLoja)
Local nX            := 0  
Local nY            := 0     
Local nDelLine      := 0
Local nPosCod       := 0
Local xValue   
Local oStruSD1

Default aHeader     := {}
Default aCols       := {}
Default lMarcaDel   := .T.
Default cDoc        := ""
Default cSerie      := ""
Default cCliFor     := ""
Default cLoja       := ""

    oStruSD1 := oModelSD1:GetStruct()
    nPosCod  := oStruSD1:GetFieldPos("D1_COD")

    nDelLine := Len(aHeader)+1 
    oModelSD1:ClearData(.F., .T.)
    For nX := 1 To Len(aCols)
        If !Empty(aCols[nX][nPosCod])
            If oModelSD1:Length() < nX
                oModelSD1:LVALID := .T. //Actualización x campo
                oModelSD1:AddLine()
            EndIf
            //Actualización x campo
            For nY := 1 To Len(aHeader)
                If !Empty(aCols[nX][nY])
                    xValue := TypeData(oStruSD1, AllTrim(aHeader[nY][2]), aCols[nX][nY])
                    oModelSD1:LoadValue(AllTrim(aHeader[nY][2]), xValue)
                EndIf
            Next
            oModelSD1:LoadValue("D1_DOC", cDoc)
            oModelSD1:LoadValue("D1_SERIE", cSerie)
            oModelSD1:LoadValue("D1_FORNECE", cCliFor)
            oModelSD1:LoadValue("D1_LOJA", cLoja)
            oModelSD1:LoadValue("D1_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD1:GetValue("D1_COD"), "B1_DESC")))
            If lMarcaDel .and. aCols[nX][nDelLine]
                oModelSD1:DeleteLine()
            EndIf
        EndIf
    Next
    oModelSD1:GoLine(1)

Return

/*/{Protheus.doc} LxF1Track
Función utilizada para realizar la llamada del tracker en la visualización de documentos.
@author 	raul.medina
@since 		11/2023
@version	12.1.2210 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function LxF1Track(oModel)
Local oModelSF1     := oModel:GetModel("SF1_MASTER")
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local nX            := 0
Local cKey          := ""
Local aEnt          := {}

    cKey := oModelSF1:GetValue("F1_DOC") + oModelSF1:GetValue("F1_SERIE") + oModelSF1:GetValue("F1_FORNECE") + oModelSF1:GetValue("F1_LOJA")
    For nX := 1 To oModelSD1:Length()
        AAdd(aEnt,{"SD1", cKey + oModelSD1:GetValue("D1_COD", nX) + oModelSD1:GetValue("D1_ITEM", nX)})
    Next nX

    MaTrkShow(aEnt)

Return

/*/{Protheus.doc} CleanModIn
Función utilizada para realizar la limpieza de los valores del model.
@author 	raul.medina
@since 		12/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido.
@Return 
/*/
Function CleanModIn(oView)
Local nFocus        := GetFocus()
Local aModelsId     := {}
Local oModel        := oView:GetModel()

        //Items
        oModel:GetModel("SD1_DETAIL"):ClearData(.T., .T.)
        oView:Refresh("oStruSD1")
        //Totales
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_VALMERC", 0)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESCONT", 0)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_VALBRUT", 0)
        oModel:GetModel("SF1_MASTER"):LoadValue("BASEDUP", 0)
        LxSetVal(oModel,0)
        oView:Refresh("oStruTot")
        //PMS
        oModel:GetModel("AFN_DETAIL"):ClearData(.F., .T.)
        //Prorrateo
        oModel:GetModel("SDE_DETAIL"):ClearData(.F., .T.)

        aModelsId := oView:GetModelsIds()
        //Libros fiscales
        If FindString("SF3_DETAIL", aModelsId) //Verificación de existencia del grid
            oModel:GetModel("SF3_DETAIL"):ClearData(.F., .T.)
            oView:Refresh("oStruSF3")
        EndIf
        //Impuestos
        If FindString("IMP_DETAIL", aModelsId) //Verificación de existencia del grid
            oModel:GetModel("IMP_DETAIL"):ClearData(.F., .T.)
            oView:Refresh("oStruIMP")
        EndIf
        //Títulos
        If FindString("DUP_DETAIL", aModelsId) //Verificación de existencia del grid
            oModel:GetModel("DUP_DETAIL"):ClearData(.F., .T.)
            oView:Refresh("oStruSF3")
        EndIf
        
        SetFocus(nFocus)

Return

/*/{Protheus.doc} ActItemsIN
	Función utilizada para actualizar los valores de los items dentro del model.
	@type  Function
	@author raul.medina
	@since 01/2024
	@param
        oModel -  - Model que está siendo procesado.
        ojson - JsonObject - Json con la información de totales y valores por item.
	@return 
	/*/
Function ActItemsIN(oModel, ojson)
Local oModelSD1     := oModel:GetModel("SD1_DETAIL")
Local nX            := 0
Local nLine         := 0

Default ojson       := JsonObject():new()

    nLine := oModelSD1:GetLine()
    For nX := 1 To oModelSD1:Length()
        oModelSD1:GoLine(nX)
        If !oModelSD1:IsDeleted(nX)
            oModelSD1:LoadValue("D1_VALDESC", ojson['ITEMS'][nX]['IT_DESCONTO'])
            oModelSD1:LoadValue("D1_VALFRE", ojson['ITEMS'][nX]['IT_FRETE'])
            oModelSD1:LoadValue("D1_DESPESA", ojson['ITEMS'][nX]['IT_DESPESA'])
            oModelSD1:LoadValue("D1_SEGURO", ojson['ITEMS'][nX]['IT_SEGURO'])
        EndIf
    Next
    oModelSD1:GoLine(nLine)

Return

/*/{Protheus.doc} LxInPreCal
	Función utilizada para alterar valores antes del calculo.
	@type  Function
	@author raul.medina
	@since 01/2024
	@param
        oModel -  - Model que está siendo procesado.
	@return 
	/*/
Function LxInPreCal(oModel)

    If oModel:GetModel("SF1_MASTER"):HasField("CALC") .and. oModel:GetModel("SF1_MASTER"):GetValue("CALC")
        oModel:LoadValue("SF1_MASTER", "F1_DESCONT", 0)
    EndIf

Return

/*/{Protheus.doc} LxInAdian
	Función utilizada para seleccionar Anticipos en facuras de entrada.
	@type  Function
	@author raul.medina
	@since 01/2024
	@param
        oView -  - view que está siendo procesado.
	@return 
	/*/
Function LxInAdian(oView)
Local cDoc      := ""
Local cSerie    := ""
Local cCondicao := ""
Local cFornece  := ""
Local cLoja     := ""
Local cNatureza := ""
Local cTipo     := ""
Local cTipoDoc  := ""
Local cEspecie  := ""
Local cPaymntCnd:= ""
Local nNFMoeda  := 1
Local nTxMoeda  := 0
Local nValMerc  := 0
Local nEvent    := 0
Local nPosValadi:= 0
Local bWhenHead := {||.T.}
Local aOldData  := {}
Local aRecnoSE1 := {}
Local oModel
Local oModelSD1
Local ojson 

Private N       := 0
Private aCols   := {}
Private aHEader := {}
Private bRefresh := {||}

Default oView := FwViewActive()

    oModel := oView:GetModel()
    oModelSD1 := oModel:GetModel("SD1_DETAIL")
    N := oModelSD1:GetLine()
    aOldData := oModelSD1:GetOldData()
    cFornece := oModel:GetModel("SF1_MASTER"):GetValue("F1_FORNECE")
    cLoja    := oModel:GetModel("SF1_MASTER"):GetValue("F1_LOJA")
    cDoc     := oModel:GetModel("SF1_MASTER"):GetValue("F1_DOC")
    cSerie   := oModel:GetModel("SF1_MASTER"):GetValue("F1_SERIE")
    cCondicao := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")
    nValMerc := oModel:GetModel("SF1_MASTER"):GetValue("F1_VALMERC")
    cTipo    := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPO")
    cTipoDoc := oModel:GetModel("SF1_MASTER"):GetValue("F1_TIPODOC")
    cEspecie := oModel:GetModel("SF1_MASTER"):GetValue("F1_ESPECIE")
    nNFMoeda := oModel:GetModel("SF1_MASTER"):GetValue("F1_MOEDA")
    nTxMoeda := oModel:GetModel("SF1_MASTER"):GetValue("F1_TXMOEDA")
    cNatureza := Iif(oModel:GetModel("SF1_MASTER"):HasField("F1_NATFIN") .and. !Empty(oModel:GetModel("SF1_MASTER"):GetValue("F1_NATFIN")), oModel:GetModel("SF1_MASTER"):GetValue("F1_NATFIN"),oModel:GetModel("SF1_MASTER"):GetValue("F1_NATUREZ"))
    cPaymntCnd := oModel:GetModel("SF1_MASTER"):GetValue("F1_COND")
    nPosValadi := oModelSD1:GetStruct():GetFieldPos("D1_VALADI")

    aHeader := aOldData[1]
    aCols  := aClone(aOldData[2])

    If !MaFisRestore()
        MaFisIni(cFornece, cLoja, "F", cTipo, Nil, , , .F., "SB1", , cTipoDoc, cEspecie)
        MaFisAlt("NF_SERIENF", cSerie)
        MaFisAlt("NF_MOEDA"  , nNFMoeda)
        MaFisAlt("NF_TXMOEDA", nTxMoeda)
    EndIf
    

    nEvent := aScan(oModel:oEventHandler:aEvents, {|x| x:cIdEvent == "LXINEVENT"})

    If nEvent > 0
        aRecnoSE1 := aClone(oModel:oEventHandler:aEvents[nEvent]:aRecnoSE1)
    EndIf

    LxAdianMex(cDoc, cCondicao, Eval({|aX|IIf(Len(aX)>0,aX[1][2],0)},Condicao(nValMerc,cCondicao,0.00,dDataBase,0.00)), @aRecnoSE1, .F., cFornece, cLoja, cNatureza, aHeader)

    //Actualización de valor del anticipo.
    If nPosValadi > 0
        oModelSD1:LoadValue("D1_VALADI", aCols[N][nPosValadi])
    EndIf

    oModel:GetModel("SF1_MASTER"):LoadValue("F1_VALBRUT", MaFisRet( ,"NF_TOTAL"))
    oModel:GetModel("SF1_MASTER"):LoadValue("F1_VALMERC", MaFisRet( ,"NF_VALMERC"))

    ojson := GetCalxFis(aCols, .T.)
    ActCalcFis(oModel, ojson, .T., "SF1_MASTER")
    F1PaymntCn(cPaymntCnd)

    If nEvent > 0
        oModel:oEventHandler:aEvents[nEvent]:aRecnoSE1 := aClone(aRecnoSE1)
    EndIf

    If Len(aRecnoSE1) > 0
        bWhenHead := {||.F.} //Si hay anticipos no se permite más editar los campos.
    EndIf
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_FORNECE"  ,   MODEL_FIELD_WHEN, bWhenHead)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_LOJA"     ,   MODEL_FIELD_WHEN, bWhenHead)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_MOEDA"    ,   MODEL_FIELD_WHEN, bWhenHead)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TXMOEDA"  ,   MODEL_FIELD_WHEN, bWhenHead)

    MaFisSave()
    MaFisEnd()

Return

/*/{Protheus.doc} RefreshFld
Función utilizada verificar si un campo sufrió un cambio en la variable de memoria y debe ser actualizado.
@author 	raul.medina
@since 		06/2024
@version	12.1.2210 / Superior
Parametros
    oView -  - view que está siendo procesado.
    cModelId - caracter - nombre de la vista que debe ser actualizada.
    cField - caracter - nombre del campo que está siendo actualizado.
@Return 
/*/
Static Function RefreshFld(oView, cModelId, cField)
Local oSubModel

Default oView   := FwViewActive()
Default cModelId:= "SF1_MASTER"
Default cField  := ""

    oSubModel := oView:GetModel(cModelId)
    If !(oSubModel:GetValue(cField) == FWFLDGET(cField))
        oSubModel:LoadValue("F1_DOC", FWFLDGET(cField)) 
        oView:Refresh(cModelId)
    EndIf

Return

/*/{Protheus.doc} LxValDesc
Función utilizada para reemplazar el  disparador del campo D1_VALDESC cuando el disparador retorna un 0 (M->D1_DESC := 0).
@author 	raul.medina
@since 		06/2024
@version	12.1.2210 / Superior
Parametros
@Return 
    nDescont - numerico - Valor del % de descuento (D1_DESC).
/*/
Function LxValDesc()
Local nValDesc  := 0
Local nTotal    := 0
Local nDescont  := 0
Local nDec      := 0

    nValDesc := FwFldGet("D1_VALDESC")
    nTotal  := FwFldGet("D1_TOTAL")
    nDec    := GetSx3Cache("D1_DESC", "X3_DECIMAL")

    nDescont := Round(nValDesc*100 /nTotal,nDec)

Return nDescont

/*/{Protheus.doc} LxDesc
Función utilizada para reemplazar el disparador estandar del campo D1_DESC para dar un tratamiento para no actualizar el valor en la ejecución en MVC.
@author 	raul.medina
@since 		06/2024
@version	12.1.2210 / Superior
Parametros
    lRound - logico - indica si el calculo del valor debe ser utilizado el round.
@Return 
    nRet - numerico - Valor del descuento (D1_VALDESC).
/*/
Function LxDesc(lRound)
Local nValDesc  := 0
Local nTotal    := 0
Local nDesc     := 0
Local nMoeda    := 1
Local nDecVal   := 0
Local nDecDesc  := 0
Local nDescAux  := 0
Local nMoeDec   := 0
Local nRet      := 0

Default lRound  := .T.

    nValDesc:= FwFldGet("D1_VALDESC")
    nDesc   := FwFldGet("D1_DESC")
    nTotal  := FwFldGet("D1_TOTAL")
    nMoeda  := FwFldGet("F1_MOEDA")
    nDecVal := GetSx3Cache("D1_VALDESC", "X3_DECIMAL")
    nDecDesc:= GetSx3Cache("D1_DESC", "X3_DECIMAL")
    nMoeDec := MsDecimais(nMoeda)

    If lRound .or. nMoeDec == 0
        nRet := Round(nTotal*nDesc/100, Iif(nMoeDec==0, nMoeDec, nDecVal))
    Else 
        nRet := NoRound(nTotal*nDesc/100, nDecVal)
    EndIf

    //Se verifica si al valor del % de descuento se le truncaron decimales para no realizar nuevamente la actualización.
    If nValDesc > 0
        nDescAux := Round(nValDesc*100 /nTotal,nDecDesc)
        If nDesc == nDescAux
            nRet := nValDesc
        EndIF
    EndIf

Return nRet
/*/{Protheus.doc} RecalView
Función para recalcular impuestos
@param      oView,objeto,view que está siendo procesado.
@return		Nil,nulo , regresa nulo
@author 	adrian.perez
@since 		29/09/2024
/*/
Static Function RecalView(oView)
Local oModel

Default oView := FwViewActive()
    
    If MsgYesNo(OemToAnsi(STR0032),OemToAnsi(STR0031)) // STR0031 - Impuestos // STR0032-"¿Desea rehacer el cálculo de los impuestos?"                                                                                                                                                                              
        oModel := oView:GetModel()
        oModel:GetModel("SF1_MASTER"):LoadValue("CALC", .T.)
        ViewCalcIn(oView)
    EndIf

Return Nil

/*/{Protheus.doc} VD1_NFORI
    Función encargada de realizar las validaciones para el campo D1_NFORI.
    @type  Function
    @author luis.samaniego
    @since 25/06/2025
    @return lRet, Logical, .T. si cumple las condiciones.
    /*/
Function VD1_NFORI()
Local cX3Valid := ""
Local lRet     := .T.

    If !(Type("cTipo") == "C")
		cTipo  := FwFldGet("F1_TIPO")
	EndIf
    
    cX3Valid := GetSX3Cache("D1_NFORI", "X3_VALID")

    If !Empty(cX3Valid)
        lRet := &(cX3Valid)
    EndIf

Return lRet

/*/{Protheus.doc} VD1_ITEMORI
    Función encargada de realizar las validaciones para el campo D1_ITEMORI.
    @type  Function
    @author luis.samaniego
    @since 25/06/2025
    @return lRet, Logical, .T. si cumple las condiciones.
    /*/
Function VD1_ITEMORI()
Local cX3Valid := ""
Local lRet     := .T.

    If !(Type("bGdRefresh") == "B")
		bGdRefresh := {||}
	EndIf

    If !(Type("cTipo") == "C")
		cTipo  := FwFldGet("F1_TIPO")
	EndIf

    If !(Type("cA100For") == "C")
		cA100For  := FwFldGet("F1_FORNECE")
	EndIf

    If !(Type("cLoja") == "C")
		cLoja  := FwFldGet("F1_LOJA")
	EndIf    

    If !(Type("cSerie") == "C")
		cSerie  := FwFldGet("F1_SERIE")
	EndIf

     If !(Type("cNFiscal") == "C")
		cNFiscal  := FwFldGet("F1_DOC")
	EndIf

    cX3Valid := GetSX3Cache("D1_ITEMORI", "X3_VALID")

    If !Empty(cX3Valid)
        lRet := &(cX3Valid)
    EndIf

Return lRet

/*/{Protheus.doc} VD1_PEDIDO
    Función encargada de realizar las validaciones para el campo D1_PEDIDO.
    @type  Function
    @author pedro.candido
    @since 24/03/2026
    @return lRet, Logical, .T. si cumple las condiciones.
    /*/
Function VD1_PEDIDO()
Local cX3Valid := ""
Local lRet     := .T.

    cX3Valid := GetSX3Cache("D1_PEDIDO", "X3_VALID")

    If !Empty(cX3Valid)
        lRet := &(cX3Valid)
    EndIf

Return lRet

/*/{Protheus.doc} VD1_ITEMPC
    Función encargada de realizar las validaciones para el campo D1_ITEMPC.
    @type  Function
    @author pedro.candido
    @since 24/03/2026
    @return lRet, Logical, .T. si cumple las condiciones.
    /*/
Function VD1_ITEMPC()
Local cX3Valid := ""
Local lRet     := .T.

    If !(Type("bGdRefresh") == "B")
		bGdRefresh := {||}
	EndIf

    If !(Type("cA100For") == "C")
		cA100For  := FwFldGet("F1_FORNECE")
	EndIf

    If !(Type("cLoja") == "C")
		cLoja  := FwFldGet("F1_LOJA")
	EndIf    

    If !(Type("lReajuste") == "L")
		lReajuste  := .T.
	EndIf    

    If !(Type("dDEmissao") == "D")
		dDEmissao  := FwFldGet("F1_EMISSAO")
	EndIf    

    If !(Type("nMoedaNF") == "N")
		nMoedaNF  := FwFldGet("F1_MOEDA")
	EndIf    

    If !(Type("aRatCC") == "A")
		aRatCC  := {}
	EndIf    

    If !(Type("aRatAFN") == "A")
		aRatAFN  := {}
	EndIf    

    cX3Valid := GetSX3Cache("D1_ITEMPC", "X3_VALID")

    If !Empty(cX3Valid)
        lRet := &(cX3Valid)
    EndIf

Return lRet

/*/{Protheus.doc} F1_CONDVal
    Función encargada de realizar las validaciones para el campo F1_COND.
    @type  Function
    @author diego.batista
    @since 10/11/2025
    @return lRet, Logical, .F. si cumple las condiciones.
    /*/
Function F1_CONDVal()
Local lRet          := .F.

    If Type("cEspecie") <> "C"
        cEspecie := FwFldGet("F1_ESPECIE")
    EndIf

    If Type("nTipo") <> "N"
        nTipo := Val(FwFldGet("F1_TIPO"))
    EndIf

    if  Type("aPE") <>  "A"
          aPE  := Array(SnMaxPE,2)
          aPE  := MontaPE(nTipo)
    EndIf

    lRet := Vazio() .Or. LxA103Cond(FwFldGet("F1_COND"))

Return lRet

/*/{Protheus.doc} VF1_COND
    Función encargada de realizar las validaciones para habilitar/deshabilitar el campo F1_COND.
    @type  Function
    @author veronica.flores
    @since 11/10/2025
    @return lRet, Logical, .T. si cumple las condiciones.
    /*/
Function VF1_COND()
Local lRet      := .F.

    If FwFldGet("F1_VALMERC") > 0 .And. FwFldGet("BASEDUP") > 0
        lRet := .T.
    EndIf    

Return lRet

/*/{Protheus.doc} VD1_QUANT
    Función encargada de realizar las validaciones para el campo D1_QUANT.
    @type function
    @version 12.1.2310 / Superior
    @author luis.samaniego
    @since 1/12/2025
    @return Logical, .T. si cumple las condiciones.
/*/
Function VD1_QUANT()
Local cX3Valid := ""
Local lRet     := .T.
Local oModel   := FWModelActive()

    If !(Type("cA100For") == "C")
		cA100For  := FwFldGet("F1_FORNECE")
	EndIf
    If !(Type("cLoja") == "C")
		cLoja  := FwFldGet("F1_LOJA")
	EndIf
    If !(Type("dDEmissao") == "D")
		dDEmissao := FwFldGet("F1_EMISSAO")
	EndIf

    cX3Valid := GetSX3Cache("D1_QUANT", "X3_VALID")

    If !Empty(cX3Valid)
        lRet := &(cX3Valid)
    EndIf

    If oModel != Nil .And. oModel:GetModel("SF1_MASTER"):HasField("CALCGASTOS")
        oModel:GetModel("SF1_MASTER"):LoadValue("CALCGASTOS", .T.)
    EndIf

Return lRet

/*/{Protheus.doc} RecalGasto
    Función encargada de recalcular los gastos en el documento de entrada a partir de los ítems del pedido de compra.
    @type function
    @version 12.1.2310 / Superior
    @author luis.samaniego
    @since 07/12/2025
    @param oModel, object, Modelo de datos
/*/
Static Function RecalGasto(oModel)
Local aAreaSC7  := {}
Local cItemPC   := ""
Local cNFOrig   := ""
Local cPedido   := ""
Local cRemito   := ""
Local cSerOri   := ""
Local cSerRem   := ""
Local dDEmissao := CTOD("")
Local lUpdGasto := .F.
Local nDivisor  := 0
Local nLine     := 0
Local nMultipl  := 0
Local nQuant    := 0
Local nVlrDesp  := 0
Local nVlrFrt   := 0
Local nVlrSeg   := 0
Local nX        := 0
Local oModelSD1 := Nil

Default oModel := FWModelActive()

    oModelSD1 := oModel:GetModel("SD1_DETAIL")
    dDEmissao := FwFldGet("F1_EMISSAO")
    nLine     := oModelSD1:GetLine()

    aAreaSC7 := SC7->(GetArea())
    DbSelectArea("SC7")
    SC7->(dbSetOrder(1))
    For nX := 1 To oModelSD1:Length()
        If !oModelSD1:IsDeleted(nX)

            nQuant := oModelSD1:GetValue("D1_QUANT", nX)
            If oModelSD1:HasField("D1_PEDIDO")
                cPedido := oModelSD1:GetValue("D1_PEDIDO", nX)
            EndIf
            If oModelSD1:HasField("D1_ITEMPC")
                cItemPC := oModelSD1:GetValue("D1_ITEMPC", nX)
            EndIf
            If oModelSD1:HasField("D1_NFORI")
                cNFOrig := oModelSD1:GetValue("D1_NFORI", nX)
            EndIf
            If oModelSD1:HasField("D1_SERIORI")
                cSerOri := oModelSD1:GetValue("D1_SERIORI", nX)
            EndIf
            If oModelSD1:HasField("D1_REMITO")
                cRemito := oModelSD1:GetValue("D1_REMITO", nX)
            EndIf
            If oModelSD1:HasField("D1_SERIREM")
                cSerRem := oModelSD1:GetValue("D1_SERIREM", nX)
            EndIf

            If !Empty(cPedido + cItemPC) .And. Empty(cNFOrig + cSerOri + cRemito + cSerRem)
                If SC7->(MsSeek(xFilial("SC7")+ cPedido + cItemPC))
        
                    nDivisor := SC7->C7_QUANT
                    nMultipl := nQuant

                    oModelSD1:GoLine(nX)
                    //Recalcula despesa
                    If !Empty(SC7->C7_DESPESA)
                        oModelSD1:LoadValue("D1_DESPESA", xMoeda((SC7->C7_DESPESA / nDivisor) * nMultipl, SC7->C7_MOEDA, 1, dDEmissao, Nil, SC7->C7_TXMOEDA))		
                        nVlrDesp += oModelSD1:GetValue("D1_DESPESA", nX)
                    EndIf
                    //Recalcula seguro
                    If !Empty(SC7->C7_SEGURO)
                        oModelSD1:LoadValue("D1_SEGURO", xMoeda((SC7->C7_SEGURO / nDivisor) * nMultipl, SC7->C7_MOEDA, 1, dDEmissao, Nil, SC7->C7_TXMOEDA))	
                        nVlrSeg += oModelSD1:GetValue("D1_SEGURO", nX)
                    EndIf
                    //Recalcula frete
                    If !Empty(SC7->C7_VALFRE)
                        oModelSD1:LoadValue("D1_VALFRE", xMoeda((SC7->C7_VALFRE / nDivisor) * nMultipl, SC7->C7_MOEDA, 1, dDEmissao, Nil, SC7->C7_TXMOEDA))		
                        nVlrFrt += oModelSD1:GetValue("D1_VALFRE", nX)
                    EndIf
                    lUpdGasto := .T.
                EndIf
            EndIf
        EndIf
    Next

    oModelSD1:GoLine(nLine)
    If lUpdGasto
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_FRETE", nVlrFrt)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_SEGURO", nVlrSeg)
        oModel:GetModel("SF1_MASTER"):LoadValue("F1_DESPESA", nVlrDesp)
    EndIf

    RestArea(aAreaSC7)
    fwFreeArray(aAreaSC7)

Return



/*/{Protheus.doc} LxAutoSF1
    Función utilizada para realizar la inclusión o eliminación automática de documentos SF1.
    @author  raul.medina
    @since   01/2026
    @version 12.1.2210 / Superior
    @param   aAutoCab   - Array - Datos del encabezado del documento.
    @param   aAutoItens - Array - Datos de los ítems del documento.
    @param   nTipoDoc   - Numérico - Tipo de documento (por defecto 10).
    @param   nOpcAuto   - Numérico - Opción de automatización (3=Incluir, 5=Eliminar).
    @param   cFunName   - Caracter - Nombre de la función llamadora.
    @return  Nil
/*/
Function LxAutoSF1(aAutoCab, aAutoItens, nTipoDoc, nOpcAuto, cFunName)

Default aAutoCab    := {}
Default aAutoItens  := {}
Default nTipoDoc    := 10
Default nOpcAuto    := 3
Default cFunName    := Funname()

    If nOpcAuto == 3
        LxAuIncSF1(aAutoCab, aAutoItens, nTipoDoc, cFunName)
    ElseIf nOpcAuto == 5
        LxAuDelSF1(aAutoCab, aAutoItens, nTipoDoc, cFunName)
    EndIf

Return

/*/{Protheus.doc} LxAuIncSF1
    Función utilizada para ejecutar la inclusión de modelos para tipos de documento de entrada.
    @type      Function
    @author    raul.medina
    @since     01/2026
    @param     aAutoCab   - array     - Encabezado automático.
    @param     aAutoItens - array     - Ítems automáticos.
    @param     nTipoDoc   - numérico  - Tipo de documento.
    @param     cFunName   - caracter  - Nombre de la función invocadora.
    @return    Nil
*/
Function LxAuIncSF1(aAutoCab, aAutoItens, nTipoDoc, cFunName)
Local oModel        := Nil
Local nItem         := 0
Local nX            := 0
Local aError        := {}
Local lRet          := .T.
Local oStruct       := Nil
Local cField        := ""
Local xValue        := Nil
Private Inclui      := .T.
Default aAutoCab    := {}
Default aAutoItens  := {}
Default nTipoDoc    := 10
Default cFunName    := Funname()

    If Type("bGdRefresh") == "B"
		bGdRefresh := {||}
	EndIf

    oModel := FWLoadModel("LOCX"+StrZero(nTipoDoc, 2))	
    
    If oModel != Nil
        If oModel:GetModel("SF1_MASTER"):HasField("F1_SERIE2") //Se quita la obligatoriedad del campo F1_SERIE2 en la inclusión automática ya que para antiguos documentos este campo puede venir vacío.
            oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_SERIE2"  ,   MODEL_FIELD_OBRIGAT, .F.)
        EndIf
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()

        //Llenado del encabezado del documento.
        oStruct := oModel:GetModel("SF1_MASTER"):GetStruct()
        For nX := 1 To Len(aAutoCab)
            cField := AllTrim(aAutoCab[nX][1])
            If oModel:GetModel("SF1_MASTER"):HasField(cField) .and. oModel:CanSetValue("SF1_MASTER", cField) .and. !Empty(aAutoCab[nX][2])
                xValue := TypeData(oStruct, cField, aAutoCab[nX][2])
                oModel:GetModel("SF1_MASTER"):SetValue(cField, xValue)
            EndIf
        Next
        If oModel:GetModel("SF1_MASTER"):HasField("AUTO") //Se indica que es una inclusión automática.
            oModel:GetModel("SF1_MASTER"):LoadValue("AUTO", .T.)
        EndIf

        //Llenado de los items.
        oStruct := oModel:GetModel("SD1_DETAIL"):GetStruct()
        For nItem := 1 To Len(aAutoItens)
            If lRet
                If nItem > 1
                    If oModel:GetModel("SD1_DETAIL"):AddLine() < nItem
                        lRet := .F.
                        Exit
                    EndIf
                EndIf
                For nX := 1 To Len(aAutoItens[nItem])
                    cField := AllTrim(aAutoItens[nItem][nX][1])
                    If oModel:GetModel("SD1_DETAIL"):HasField(cField) .and. oModel:CanSetValue("SD1_DETAIL", cField) .and. (!Empty(aAutoItens[nItem][nX][2]) .and. !(cField == "D1_ITEM"))
                        xValue := TypeData(oStruct, cField, aAutoItens[nItem][nX][2])
                        oModel:GetModel("SD1_DETAIL"):SetValue(cField, xValue)
                    EndIf
                Next
            EndIf
        Next


        If lRet .and. oModel:VldData()
            oModel:CommitData()
        Else
            aError := oModel:GetErrorMessage()
            If Type("lMSErroAuto") == "L"
                lMSErroAuto := .T.
                If Type("aAutoErro") == "A"
                    AAdd(aAutoErro,aError[5]) 
                    AAdd(aAutoErro,aError[6]) 
                    AAdd(aAutoErro,aError[7]) 
                Endif
            Else   
                Help(" ", 1, aError[5], , aError[6], 2, 0,,,,,, {aError[7]})
            EndIf
            FwFreeArray(aError)
        EndIf
        oModel:DeActivate()
        oModel:Destroy()
        FreeObj(oStruct)
    EndIf
Return

/*/{Protheus.doc} LxAuDelSF1
    Función utilizada para ejecutar el borrado de modelos para tipos de documento de entrada.
    @type      Function
    @author    raul.medina
    @since     01/2026
    @param     aAutoCab   - array     - Encabezado automático.
    @param     aAutoItens - array     - Ítems automáticos.
    @param     nTipoDoc   - numérico  - Tipo de documento.
    @param     cFunName   - caracter  - Nombre de la función invocadora.
    @return    Nil
*/
Function LxAuDelSF1(aAutoCab, aAutoItens, nTipoDoc, cFunName)
Local aArea         := GetArea()
Local oModel        := Nil
Local aError        := {}
Local lRet          := .T.
Local nFilial       := 0
Local nDoc          := 0
Local nSerie        := 0
Local nFornece      := 0
Local nLoja         := 0
Local nTipo         := 0
Local cFilSF1       := xFilial("SF1")
Local cLlave        := ""

Default aAutoCab    := {}
Default aAutoItens  := {}
Default nTipoDoc    := 10
Default cFunName    := Funname()

    nFilial := aScan(aAutoCab, {|x| AllTrim(x[1]) == "F1_FILIAL"})
    nDoc    := aScan(aAutoCab, {|x| AllTrim(x[1]) == "F1_DOC"})
    nSerie  := aScan(aAutoCab, {|x| AllTrim(x[1]) == "F1_SERIE"})
    nFornece := aScan(aAutoCab, {|x| AllTrim(x[1]) == "F1_FORNECE"})
    nLoja   := aScan(aAutoCab, {|x| AllTrim(x[1]) == "F1_LOJA"})
    nTipo   := aScan(aAutoCab, {|x| AllTrim(x[1]) == "F1_TIPO"})

    If nFilial > 0
        cFilSF1 := aAutoCab[nFilial][2]
    EndIf

    // Validar que todos los índices requeridos existen
    If nDoc == 0 .or. nSerie == 0 .or. nFornece == 0 .or. nLoja == 0
        // Algún campo requerido no está presente, no continuar
        Return
    EndIf

    cLlave := cFilSF1
    cLlave += PadR(aAutoCab[nDoc][2], GetSx3Cache("F1_DOC", "X3_TAMANHO"))
    cLlave += PadR(aAutoCab[nSerie][2], GetSx3Cache("F1_SERIE", "X3_TAMANHO"))
    cLlave += PadR(aAutoCab[nFornece][2], GetSx3Cache("F1_FORNECE", "X3_TAMANHO"))
    cLlave += PadR(aAutoCab[nLoja][2], GetSx3Cache("F1_LOJA", "X3_TAMANHO"))
    If nTipo > 0
        cLlave += PadR(aAutoCab[nTipo][2], GetSx3Cache("F1_TIPO", "X3_TAMANHO"))
    EndIf

    DbSelectArea("SF1")
    SF1->(DbSetOrder(1))
    SF1->(MsSeek(cLlave)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
    If !SF1->(Found())
         //Documento no encontrado
        FWLogMsg(STR0035 + aAutoCab[nDoc][2] + " " + aAutoCab[nSerie][2]) // LxAuDelSF1: Documento SF1 no encontrado para borrar. Datos: 
        Help(STR0036, 1, STR0037, , "", 2, 0) // Documento SF1 no encontrado para borrar.
        RestArea(aArea)
        Return
    EndIf

    If Type("bGdRefresh") == "B"
		bGdRefresh := {||}
	EndIf

    oModel := FWLoadModel("LOCX"+StrZero(nTipoDoc, 2))	
    
    If oModel != Nil
        oModel:SetOperation(MODEL_OPERATION_DELETE)
        oModel:Activate()

        If lRet .and. oModel:VldData()
            oModel:CommitData()
        Else
            aError := oModel:GetErrorMessage()
            Help(" ", 1, aError[5], , aError[6], 2, 0,,,,,, {aError[7]})
            FwFreeArray(aError)
        EndIf
        oModel:DeActivate()
        oModel:Destroy()
    EndIf
    RestArea(aArea)
Return


/*/{Protheus.doc} LxViewSF1
    Función utilizada para abrir la vista de documentos SF1 de acuerdo al tipo y operación especificados.
    @author  raul.medina
    @since   01/2026
    @version 12.1.2210 / Superior
    @param   cTipo      - Caracter - Tipo de documento (por defecto "10").
    @param   nOperation - Numérico - Operación a realizar (por defecto 3).
    @param   cFunName   - Caracter - Nombre de la función llamadora.
    @return  Nil
/*/
Function LxViewSF1(cTipo, nOperation, cFunName)
Local cOperation    := ""
Local cView         := "" 
Local oExecView     := Nil
Local oView         := Nil

Default cTipo       := "10"
Default nOperation  := 3
Default cFunName    := Funname()

    If nOperation == MODEL_OPERATION_INSERT
		cOperation := OemToAnsi(STR0025) //'Incluir'
	ElseIf nOperation == MODEL_OPERATION_DELETE
		cOperation := OemToAnsi(STR0027) //'Excluir'
	ElseIf nOperation == 6 //Verificar
		cOperation := OemToAnsi(STR0038) //'Anular'
	Elseif nOperation == 2
		nOperation  := MODEL_OPERATION_VIEW // Operación Visualizar
		cOperation := OemToAnsi(STR0026) // Visualizar
	EndIf

    cView := "LOCX" + cTipo
    oView := FWLoadView(cView)
    oView:SetOperation(nOperation)

    If nOperation == MODEL_OPERATION_INSERT
        If !Pergunte('MTXRED',.T.)
            Return
        EndIf
        LxCfgMVC(oView) //Configuración de la vista

        oView:SetAfterViewActivate({|| LxLoadMVC()})
    EndIf
    
    oExecView := FWViewExec():New()
    oExecView:SetTitle(cOperation)
    oExecView:SetView(oView)
    oExecView:setModal(.F.)               

    oExecView:openView(.F.)

    If oView != Nil
        oView:DeActivate()
        oView:Destroy()
    EndIf

Return

/*/{Protheus.doc} LxArrayMVC
    Rellena las variables estaticas con los datos que se utilizarán en la función LxViewSF1 
    @type function
    @version 12.1.2510
    @author pedro.candido
    @since 5/22/2026
    @param aSF1Val, array, arreglo con los valores del encabezado del documento
    @param aSD1Val, array, arreglo con los valores de los itens del documento
    @param aLockCampos, array, arreglo con los campos bloqueados
    @param aValLine, array, arreglo con las validaciones por línea
    @param aValTudoOK, array, arreglo con las validaciones del tudook
    @param aValCampo, array, arreglo con las validaciones por campo
    @param aValPE, array, arreglo con las validaciones de PE
    @return variant, Nil
/*/
Function LxArrayMVC(aSF1Val, aSD1Val, aLockCampos, aValLine, aValTudoOK, aValCampo, aValPE)

Default aSF1Val     := {}
Default aSD1Val     := {}
Default aLockCampos := {}
Default aValLine    := {}
Default aValTudoOK  := {}
Default aValCampo   := {}
Default aValPE      := {}

    aHeaderF1   := aClone(aSF1Val)
    aColsD1     := aClone(aSD1Val)
    aLockFldF1  := aClone(aLockCampos)
    aVldLine    := aClone(aValLine)
    aVldTudoOK  := aClone(aValTudoOK)
    aVldCampo   := aClone(aValCampo)
    aDataPE     := aClone(aValPE)
    
Return

/*/{Protheus.doc} LxCfgMVC
    Configuración de la vista de acuerdo a los datos recibidos en el arreglo estático, 
    esta función se ejecuta antes de abrir la vista para que al momento de cargar 
    los datos estos ya tengan la configuración necesaria.
    @type function
    @version 12.1.2510
    @author pedro.candido
    @since 5/22/2026
    @param oView, object, vista que se va a configurar
    @return variant, Nil
/*/
Static Function LxCfgMVC(oView)
Local oModel    := Nil
Local oStruSF1  := Nil
Local oStruSD1  := Nil
Local oModelSD1 := Nil
Local nX        := 0
Local cVldCampo := ""

Default oView := FwViewActive()

    oModel   := oView:GetModel()
    oStruSF1 := oView:GetViewStruct("SF1_MASTER")
    oModelSD1 := oModel:GetModel("SD1_DETAIL")
    oStruSD1 := oModelSD1:GetStruct()
    
    If Len(aVldLine) > 0
        oModel:GetModel("SD1_DETAIL"):SetLPost(aVldLine[1])
    EndIf

    If Len(aVldTudoOK) > 0
        oModel:SetPost(aVldTudoOK[1])
    EndIf

    For nX := 1 To Len(aLockFldF1)
        If  oStruSF1:HasField(aLockFldF1[nX])
                oStruSF1:SetProperty(aLockFldF1[nX], MVC_VIEW_CANCHANGE, .F.)
        EndIf
    Next
    
    For nX := 1 To Len(aVldCampo)
        cVldCampo := blocAStr(oStruSD1:GetProperty(aVldCampo[nX][1]       , MODEL_FIELD_VALID))
        If !Empty(cVldCampo)
            oStruSD1:SetProperty( aVldCampo[nX][1]      , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, aVldCampo[nX][2] + ".And." + cVldCampo) )
        Else
            oStruSD1:SetProperty( aVldCampo[nX][1]      , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, aVldCampo[nX][2]) )
        EndIf
    Next

Return Nil

/*/{Protheus.doc} LxLoadMVC
    Carga los datos a la vista de acuerdo a los arreglos estáticos, 
    esta función se ejecuta después de activar la vista para que 
    los datos se carguen con la configuración ya establecida.
    @type function
    @version 12.1.2510
    @author pedro.candido
    @since 5/22/2026
    @return variant, Nil
/*/
Static Function LxLoadMVC()
Local oView      := FWViewActive()
Local oModel     := FWModelActive()
Local oModelSD1  := Nil
Local oStruSD1   := Nil
Local nItem      := 0
Local nX         := 0
Local aOldData   := {}
Local aColsOld   := {}
Local aAltPE     := {}
Local cPE        := ""

    If !(Type("aCfgNf") == "A") .OR. Empty(aCfgNf)
		aCfgNf  := GetF1CfgNF()
	EndIf

    For nX := 1 To Len(aHeaderF1)
        If  oModel:GetModel("SF1_MASTER"):HasField(aHeaderF1[nX][1])
                oModel:GetModel("SF1_MASTER"):SetValue(aHeaderF1[nX][1], aHeaderF1[nX][2])
        EndIf
    Next

    oModelSD1 := oModel:GetModel("SD1_DETAIL")

    oStruSD1 := oModelSD1:GetStruct()

    For nItem := 1 To Len(aColsD1)
        If !Empty(aColsD1[nItem][1])
            If nItem > 1
                oModelSD1:AddLine()
            EndIf
            For nX := 1 To Len(aColsD1[nItem])
                If oModelSD1:HasField(aColsD1[nItem][nX][1])
                    If aColsD1[nItem][nX][1] == "D1_COD"
                        oModelSD1:SetValue(aColsD1[nItem][nX][1], aColsD1[nItem][nX][2])
                    Else
                        oModelSD1:LoadValue(aColsD1[nItem][nX][1], aColsD1[nItem][nX][2])
                    EndIf
                EndIf
            Next
        EndIf
    Next
    
    If Len(aDataPE) > 0
        For nX := 1 To Len(aDataPE)
            cPE := aDataPE[nX][1]
            If LxChkPE(cPE)
                aOldData   := oModelSD1:GetOldData()
                aHeader    := aOldData[1]
                aCols      := aOldData[2]
                aColsOld   := aClone(aCols)

                ExecBlock(aDataPE[nX][1], aDataPE[nX][2], aDataPE[nX][3])

                aAltPE   := LxAltData(aHeader, aCols, aColsOld)
                For nX := 1 To Len(aAltPE)
                    If oModelSD1:HasField(aAltPE[nX][2])
                        oModelSD1:GoLine(aAltPE[nX][1])
                        oModelSD1:LoadValue(aAltPE[nX][2],aAltPE[nX][4])
                    EndIf
                Next
            Else
                Loop
            EndIf
        Next
    EndIf


    oView:Refresh()
    oView:Refresh("SF1_MASTER")

    If Type("aHeader") != "U"
        FwFreeArray(aHeader)
    EndIf
    If Type("aCols") != "U"
        FwFreeArray(aCols)
    EndIf
    FwFreeArray(aOldData)
    FwFreeArray(aColsOld)
    FwFreeArray(aAltPE)

Return Nil

/*/{Protheus.doc} LxAltData
    Compara los datos anteriores con los datos actuales después de ejecutar 
    el PE para verificar si hubo cambios en lo arreglo aCols, 
    regresa un arreglo con las columnas que tuvieron cambios 
    para actualizar los datos en la pantalla MVC.
    @type function
    @version 12.1.2510
    @author pedro.candido
    @since 27/5/2026
    @param aHeaderAux, array, información del encabezado de las columnas
    @param aColsAux, array, valores actuales de las columnas
    @param aColsOld, array, valores anteriores de las columnas
    @return array, arreglo de columnas modificadas
/*/
Static Function LxAltData(aHeaderAux, aColsAux, aColsOld)
Local aAltCols := {}
Local nLin     := 0
Local nCol     := 0
Local cCampo   := ""

Default aHeaderAux := {}
Default aColsAux   := {}
Default aColsOld   := {}

// compara alteracoes
For nLin := 1 To Len(aColsAux)
    For nCol := 1 To Len(aColsAux[nLin])
        If aColsAux[nLin][nCol] != aColsOld[nLin][nCol]
            cCampo := aHeaderAux[nCol][2]
            aAdd(aAltCols, {nLin, cCampo, aColsOld[nLin][nCol], aColsAux[nLin][nCol] })
        EndIf
    Next
Next
Return aAltCols

/*/{Protheus.doc} blocAStr
    Retorna el código del bloque de validación en formato string 
    para poder concatenar validaciones al mismo bloque.
    @type function
    @version 12.1.2510
    @author pedro.candido
    @since 5/22/2026
    @param bBloc, codeblock, bloque de validación del cual se quiere obtener el código en string
    @return variant, string con el código del bloque de validación
/*/
Static Function blocAStr(bBloc As codeblock)
	Local cBloc     := ""   As Character
	Local cValid    := ""   As Character
	Local nInicio   := 0    As numeric
	Local nFin      := 0    As numeric
	Default bBloc 	:= {||}

    If ValType(bBloc) == "B"
        cBloc := GetCbSource(bBloc)
    EndIf

    If !Empty(cBloc)
        nInicio := At(":=(", cBloc) + 2
        nFin    := RAt("),FWCloseCpo", cBloc)
        If nInicio > 0 .and. nFin > 0
            cValid  := Substr(cBloc, nInicio + 1, (nFin - 1) - (nInicio))
        EndIf
        cValid := AllTrim(cValid)
    EndIf
    bBloc := NIL
Return cValid

/*/{Protheus.doc} LxInGetFld
    Función para obtemer el valor del campo en un modelo
    @type function
    @author adrian.perez
    @since 12/03/2026
    @param oModel, objeto, Modelo de datos
    @param cIdMod, Carácter, Modelo a acceder para obtener valor del campo
    @param cField, Carácter, Campo del cual se regresa valor
    return cRet  , Carácter, valor del campo
/*/

Function LxInGetFld(oModel, cIdMod, cField)
Local oModelId := Nil
Local cRet     := ""

Default oModel  := NIL
Default cIdMod  := "SF1_MASTER"
Default cField  := ""

    oModelId := oModel:GetModel(cIdMod)
    If oModelId != Nil
        cRet := oModelId:GetValue(cField)
    EndIf

Return cRet


/*/{Protheus.doc} LxSetVal
    Función para fijar el valor de la cantidad acumulada del ítem principalmente usada para limpiar el valor
    @type function
    @author adrian.perez
    @since 11/03/2026
    @param oModel, objeto, Modelo de datos
    @param nVal, Numérico, valor a asignar
    return nil
/*/

function LxSetVal(oModel,nVal)

Default oModel  := Nil
Default nVal    := 0

 IF oModel:GetModel("SF1_MASTER"):HasField("F1_CANACU")
    
    oModel:GetModel("SF1_MASTER"):SetValue("F1_CANACU",nVal)
    oModel:GetModel("TOTCALC"):SetValue("QTDACUM",nVal)

 EndIF

return nil

/*/{Protheus.doc} LxExecMod
    Retorna el contenido del parametro MV_EXECMOD para validar 
    si el proceso si debe ejecutar a partir de los nuevos 
    modelos y rutinas en MVC
    @type function
    @version 12.1.2510
    @author pedro.candido
    @since 5/22/2026
    @return logical, Retorna .T. si el proceso debe ejecutarse en MVC o .F. si debe ejecutarse en el modelo antiguo
/*/
Function LxExecMod()
Return SuperGetMv("MV_EXECMOD",.F., .F.)

/*{Protheus.doc} LxChkPE
    Función para verificar si el PE existe en el sistema
    @type function
    @author 
    @since 11/03/2026
    @param cPE, Carácter, Nombre del PE a verificar
    return lRet, Logical, .T. si el PE existe o .F. si no existe
    */
Static Function LxChkPE(cPE)
Local lRet      := .F.

Default cPE     := ""

    If ExistBlock(cPE)
        lRet := .T.
    EndIf

Return lRet
