#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCXIN.CH'

PUBLISH MODEL REST NAME LOCXIN

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

    oStruSD1:SetProperty( 'D1_COD'      , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD1_COD()"))
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

    //Campo para descripción del producto.    
    oStruSD1:AddField(STR0024, STR0024, "D1_CODDESC","C",GetSX3Cache("B1_DESC", "X3_TAMANHO"),,,,,,,,,.T.,) //'Descripción'
    oStruSD1:SetProperty( 'D1_CODDESC'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,AllTrim(Posicione("SB1", 1, xFilial("SB1") + SD1->D1_COD, "B1_DESC")), "")'  ) )

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

    If oStruSF1:HasField("F1_PROVENT")
        xAux := FwStruTrigger('F1_FORNECE', 'F1_PROVENT', "DispProven('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F1_LOJA', 'F1_PROVENT', "DispProven('F1_FORNECE', 'F1_LOJA', 'F1_TIPODOC')", .F.)
        oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])
    EndIf

    xAux := FwStruTrigger('F1_MOEDA', 'F1_MOEFIN', 'FwFldGet("F1_MOEDA")', .F.)
	oStruSF1:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    oStruSF1:SetProperty( 'F1_COND'      , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, 'Vazio() .Or. LxA103Cond(FwFldGet("F1_COND"))'))
    If oStruSF1:HasField("F1_NATUREZ")
        oStruSF1:SetProperty( 'F1_NATFIN'    , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_INIPAD,GetSX3Cache("F1_NATUREZ", "X3_VALID")))
    EndIf
    oStruSF1:SetProperty( 'F1_MOEFIN'    , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetMoeFin(SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_DOC, SF1->F1_SERIE, F1_ESPECIE, F1_TIPODOC), Val(GetSx3Cache("F1_MOEDA", "X3_RELACAO")))') )
    oStruSF1:SetProperty( 'F1_MOEFIN'    , MVC_MODEL_VALUES    , oInputFields:GetMonedas()) 

    oStruSF1:SetProperty( 'CALC'    , MODEL_FIELD_INIT , { || .F.})
    oStruSF1:SetProperty( 'ALTIMP'  , MODEL_FIELD_INIT , { || .F.})
    oStruSF1:SetProperty( 'DOCSOP'  , MODEL_FIELD_INIT , { || .F.})
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

    // Indica que es opcional tener datos informados en el grid
    oModel:GetModel( 'SD1_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DUP_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEV_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'AFN_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SDE_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEU_DETAIL' ):SetOptional(.T.)

    oModel:GetModel("SD1_DETAIL"):SetMaxLine(9999)

    oModel:SetPrimaryKey({'F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA'}) //{'F1_FILIAL','F1_DOC','F1_SERIE','F1_FORNECE','F1_LOJA','F1_TIPO'}

    oModel:SetRelation('SD1_DETAIL',{ { 'D1_FILIAL', 'xFilial( "SD1" )' }, {'D1_DOC', 'F1_DOC'}, {'D1_SERIE', 'F1_SERIE'}, {'D1_FORNECE', 'F1_FORNECE'}, {'D1_LOJA', 'F1_LOJA'}}, SD1->(IndexKey(1)))
    oModel:SetRelation('SDE_DETAIL',{ { 'DE_FILIAL', 'xFilial( "SDE" )' }, {'DE_DOC', 'F1_DOC'}, {'DE_SERIE', 'F1_SERIE'}, {'DE_FORNECE', 'F1_FORNECE'}, {'DE_LOJA', 'F1_LOJA'}}, SDE->(IndexKey(1)))
    oModel:SetRelation('SEU_DETAIL',{ { 'EU_FILIAL', 'xFilial( "SEU" )' }, {'EU_FORNECE', 'F1_FORNECE'}, {'EU_LOJA', 'F1_LOJA'}, {'EU_NRCOMP', 'F1_DOC'}, {'EU_SERCOMP', 'F1_SERIE'}}, SEU->(IndexKey(7))) //EU_FILIAL+EU_FORNECE+EU_LOJA+EU_NRCOMP+EU_SERCOMP
    oModel:SetRelation('SEV_DETAIL',{ { 'EV_FILIAL', 'xFilial( "SEV" )' }, {'EV_CLIFOR', 'F1_FORNECE'}, {'EV_LOJA', 'F1_LOJA'}, {'EV_NUM', 'F1_DOC'}, {'EV_PREFIXO', 'F1_SERIE'}}, SEV->(IndexKey(1))) //EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ
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
    oView:SetFieldAction( 'F1_FRETE',   { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_DESPESA', { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_SEGURO',  { |oView| ViewCalcIn(oView) } )
    oView:SetFieldAction( 'F1_DESCONT', { |oView| LxUpdItems(oView:GetModel(), "SD1_DETAIL", "D1_VALDESC", 0), ViewCalcIn(oView) } )
    If oView:GetModel("SF1_MASTER"):HasField("F1_TPACTIV")
        oView:SetFieldAction( 'F1_TPACTIV',  { |oView| ViewCalcIn(oView) } )
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
    If lDocSop .and. AttIsMemberOf(oInputFields , "lDocSoporte")
        oInputFields:lDocSoporte := lDocSop
    EndIf
    If lAutoFact .and. AttIsMemberOf(oInputFields , "lAutoFact")
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
Local oStruTot	    := FWFormStruct( 2, 'SF1',{|cCampo| FindString(AllTrim(cCampo), {"F1_VALMERC", "F1_DESCONT", "F1_VALBRUT"})}, .F.)

    oStruTot:SetProperty("*", MVC_VIEW_CANCHANGE,  .F.)

    oView:AddField('oStruTot', oStruTot, 'SF1_MASTER')

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
Local aOldData      := {}
Local aCitensOri    := {}
Local aCpItensOri   := {}
Local ojson         := Nil
Local lCalcVal      := .F.
Local dDEmissao := dDataBase

    If oModel:GetModel("SF1_MASTER"):HasField("CALC") .and. !oModel:GetModel("SF1_MASTER"):GetValue("CALC") //CALC el falso indica que ya existe calculo y no lo realizará.
        Return .F.
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
    aOldData      := {}
    aCitensOri    := {}
    aCpItensOri   := {}
    lCalcVal      := !&(IsRemito(2,"'" + cTipoDoc + "'"))
    aOldData := oModel:GetModel("SD1_DETAIL"):GetOldData()
    aCpItensOri := aOldData[1]
    aCitensOri  := aOldData[2]

    //Llamada a la función de calculo.
    ojson := CalImpxMod(cCliFor, cLoja, cTipoCF, cTipo, cAliasProd, cTipoDoc, cEspecie, cSerie, nNFMoeda, nTxMoeda, aCpItensOri, aCitensOri, lCalcVal, nFlete, nGastos, nSeguro, nDescont, dDEmissao)

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
