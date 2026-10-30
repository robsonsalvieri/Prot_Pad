#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCXOUT.CH'

PUBLISH MODEL REST NAME LOCXOUT

/*/{Protheus.doc} LOCXOUT
Model para todos los documentos de campos de salidas
@author 	raul.medina
@since 		03/2022
@version	12.1.2210 / Superior
/*/

Function LOCXOUT()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		03/2022
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse	:= Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('SF2')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2022
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LOCXOUT' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.LOCXOUT' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.LOCXOUT' OPERATION 4 ACCESS 0 // 'Alterar'
	
Return aRotina


/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		03/2022
@version	12.1.2210 / Superior
/*/

Static Function ModelDef()
Local aCampSEV      := {"EV_NATUREZ", "EV_VALOR", "EV_PERC", "EV_RATEICC", "EV_PREFIXO", "EV_NUM", "EV_CLIFOR", "EV_LOJA", "EV_FILIAL"} 
Local oModel        := Nil
Local oStruSF2      := NIL
Local oStruSD2      := FWFormStruct(1, 'SD2', , .F.)
Local oStruDUP		:= FWFormModelStruct():New()
Local oStruSEV      := FWFormStruct(1, 'SEV', { | cCampo | FindString(AllTrim(cCampo), aCampSEV)}, .F.)
Local oOutputFields	:= Nil
Local oEvtFinOut	:= LXOUTFIN():New()
Local oEvtFisOut	:= LXOUTFIS():New()
Local oEvtEstOut	:= LXOUTEST():New()
Local oEvtCtbOut	:= LXOUTCTB():New()
Local oEvtPMSOut    := LXOUTPMS():New()
Local oEvtPCOOut    := LXOUTPCO():New()
Local oEvtWMSOut    := LXOUTWMS():New()
Local nTamDup       := 0
Local xAux          := {}
Local aRelSEV       := { { 'EV_FILIAL', 'xFilial( "SEV" )' }, {'EV_CLIFOR', 'F2_CLIENTE'}, {'EV_LOJA', 'F2_LOJA'}, {'EV_NUM', 'F2_DOC'}, {'EV_PREFIXO', 'F2_SERIE'}}
Local nIndSEV       := 1

    oModel := MPFormModel():New( 'LOCXOUT',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

    oOutputFields := OutputFieldsAll():New("", .T., .F., .T., .F., .F., .F.)
    oOutputFields:AddModel()

    oStruSF2 := oOutputFields:getModel()

    //Tabla de saldos y monedas
	oStruDUP:AddTable('' , { '' } , "DUPLICATAS", {|| ''})
    nTamDup := GetSx3Cache('E2_NUM', 'X3_TAMANHO') + GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO') +  GetSx3Cache('E2_PARCELA', 'X3_TAMANHO') + GetSx3Cache('E2_VENCTO', 'X3_TAMANHO') +  GetSx3Cache('E2_VALOR', 'X3_TAMANHO') + 13
	oStruDUP:AddField(STR0001 	, STR0001	, 'DUP' 	, 'C' , nTamDup)
    oStruDUP:AddField(STR0002   , STR0002   , 'DUP_NUM' 	, 'C' , GetSx3Cache('E2_NUM', 'X3_TAMANHO')) //'Número'
    oStruDUP:AddField(STR0003   , STR0003	, 'DUP_PREFIX' 	, 'C' , GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO')) //'Serie'
    oStruDUP:AddField(STR0004   , STR0004	, 'DUP_PARCEL' 	, 'C' , GetSx3Cache('E2_PARCELA', 'X3_TAMANHO')) //'Cuota'
    oStruDUP:AddField(STR0005 	, STR0005	, 'DUP_VENCTO' 	, 'D' , GetSx3Cache('E2_VENCTO', 'X3_TAMANHO')) //'Vecto'
    oStruDUP:AddField(STR0006 	, STR0006	, 'DUP_VALOR' 	, 'N' , GetSx3Cache('E2_VALOR', 'X3_TAMANHO')) //'Valor'

    //Campos obligatorios del encabezado de documentos de salida.
    oStruSF2:SetProperty( '*'           , MODEL_FIELD_OBRIGAT , .F.)
    /*oStruSF2:SetProperty('F2_TIPO'      , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_DOC'       , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_CLIENTE'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_LOJA'      , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_COND'      , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_EMISSAO'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_ESPECIE'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_MOEDA'     , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_TXMOEDA'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_TIPODOC'   , MODEL_FIELD_OBRIGAT , .T.)
    oStruSF2:SetProperty('F2_COND'      , MODEL_FIELD_OBRIGAT , .T.)*/
    oStruSF2:SetProperty( 'F2_TIPORET'	, MODEL_FIELD_VALID,	FWBuildFeature( STRUCT_FEATURE_VALID, 'Pertence("1|2|3| ")'))

    //Campos obligatorios de los items de documentos de salida.
    oStruSD2:SetProperty( '*'           , MODEL_FIELD_OBRIGAT , .F.)
    /*oStruSD2:SetProperty('D2_PRCVEN'    , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_TOTAL'     , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_GERANF'    , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_NUMSEQ'    , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_COD'       , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_UM'        , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_CF'        , MODEL_FIELD_OBRIGAT , .T.)
    oStruSD2:SetProperty('D2_TES'       , MODEL_FIELD_OBRIGAT , .T.)*/

    //Campo para descripción del producto.    
    oStruSD2:AddField(STR0007, STR0007, "D2_CODDESC","C",GetSX3Cache("B1_DESC", "X3_TAMANHO"),,,,,,,,,.T.,) //'Descripción'
    oStruSD2:SetProperty( 'D2_CODDESC'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,AllTrim(Posicione("SB1", 1, xFilial("SB1") + SD2->D2_COD, "B1_DESC")), "")'  ) )
    oStruSD2:SetProperty( 'D2_GERANF'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'N'  ) )
    oStruSD2:SetProperty( 'D2_NUMSEQ'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'ProxNum()'  ) )
    oStruSD2:SetProperty( 'D2_RATEIO'   , MODEL_FIELD_VALID   , FWBuildFeature(STRUCT_FEATURE_VALID, "VD2_RATEIO()"))
    //Disparadores SD2
    //D1_TES
    xAux := FwStruTrigger('D2_TES', 'D2_CF', 'AllTrim(Posicione("SF4", 1, xFilial("SF4") + FwFldGet("D2_TES"), "F4_CF"))', .F.)
	oStruSD2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

    xAux := FwStruTrigger('D2_QUANT', 'D2_TOTAL', '(FwFldGet("D2_QUANT") * FwFldGet("D2_PRCVEN"))', .F.)
	oStruSD2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])
    
    xAux := FwStruTrigger('D2_PRCVEN', 'D2_TOTAL', '(FwFldGet("D2_QUANT") * FwFldGet("D2_PRCVEN"))', .F.)
	oStruSD2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])

    xAux := FwStruTrigger('D2_COD', 'D2_CODDESC', 'AllTrim(Posicione("SB1", 1, xFilial("SB1") + FwFldGet("D2_COD"), "B1_DESC"))', .F.)
	oStruSD2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])   

    oStruSF2:AddField('', '',"BASEDUP","N",GetSX3Cache("F2_VALMERC", "X3_TAMANHO"),GetSX3Cache("F2_VALMERC", "X3_DECIMAL"),/*valid*/,,,,)
    oStruSF2:AddField("AUTO"		,"AUTO"					,"AUTO"		,"L",1)
    oStruSF2:AddField("CALC"		,"CALC"					,"CALC"		,"L",1) //Indica si debe de ser realizado el calculo de los valores.
    oStruSF2:AddField("ALTIMP"		,"ALTIMP"               ,"ALTIMP"   ,"L",1) //Indica si los impuestos fueron alterados.
    oStruSF2:AddField(AllTrim(FwX3Titulo("F2_MOEDA")), AllTrim(FwX3Titulo("F2_MOEDA")), "F2_MOEFIN", GetSX3Cache("F2_MOEDA", "X3_TIPO"), GetSX3Cache("F2_MOEDA", "X3_TAMANHO"), GetSX3Cache("F2_MOEDA", "X3_DECIMAL"),,,,,,,,.T.,)

    If oStruSF2:HasField("F2_NATUREZ")
        oStruSF2:AddField("", "", "F2_NATFIN", GetSX3Cache("F2_NATUREZ", "X3_TIPO"), GetSX3Cache("F2_NATUREZ", "X3_TAMANHO"), GetSX3Cache("F2_NATUREZ", "X3_DECIMAL"),,,,,,,,.T.,)
    EndIf
    oStruSF2:AddField(AllTrim(FwX3Titulo("F2_MOEDA")), AllTrim(FwX3Titulo("F2_MOEDA")), "F2_MOEFIN", GetSX3Cache("F2_MOEDA", "X3_TIPO"), GetSX3Cache("F2_MOEDA", "X3_TAMANHO"), GetSX3Cache("F2_MOEDA", "X3_DECIMAL"),,,,,,,,.T.,)

    //Campos para descripciones de campos Financieros
    oStruSF2:AddField(STR0008, STR0008,"F2_DSCCOND","C",GetSX3Cache("E4_DESCRI", "X3_TAMANHO"),,,,,,,,,.T.,) //'Desc. Pago'
    oStruSF2:SetProperty( 'F2_DSCCOND'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,AllTrim(Posicione("SE4", 1, xFilial("SE4") + SF2->F2_COND, "E4_DESCRI")), "")'  ) )
    oStruSF2:AddField(STR0009, STR0009,"F2_DSCMODL","C",GetSX3Cache("ED_DESCRIC", "X3_TAMANHO"),,,,,,,,,.T.,) //'Desc. Mod.'
    If oStruSF2:HasField("F2_NATUREZ")
        oStruSF2:SetProperty( 'F2_NATFIN'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetNatFin(1, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE, F2_ESPECIE, F2_TIPODOC), "")'  ) ) 
    EndIF
    oStruSF2:SetProperty( 'F2_DSCMODL'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetNatFin(2, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE, F2_ESPECIE, F2_TIPODOC), "")'  ) )
    
    //Disparadores SF1
    xAux := FwStruTrigger('F2_COND', 'F2_DSCCOND', 'AllTrim(Posicione("SE4", 1, xFilial("SE4") + FwFldGet("F2_COND"), "E4_DESCRI"))', .F.)
	oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    If oStruSF2:HasField("F2_NATUREZ")
        xAux := FwStruTrigger('F2_NATUREZ', 'F2_NATFIN', 'FwFldGet("F2_NATUREZ")', .F.)
        oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 
        
        xAux := FwStruTrigger('F2_NATFIN', 'F2_DSCMODL', 'AllTrim(Posicione("SED", 1, xFilial("SED") + FwFldGet("F2_NATFIN"), "ED_DESCRIC"))', .F.)
        oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F2_CLIENTE', 'F2_NATFIN', "DispNatFin('F2_CLIENTE', 'F2_LOJA', 'F2_TIPODOC')", .F.)
        oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F2_LOJA', 'F2_NATFIN', "DispNatFin('F2_CLIENTE', 'F2_LOJA', 'F2_TIPODOC')", .F.)
        oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 
    EndIf

    xAux := FwStruTrigger('F2_CLIENTE', 'F2_COND', "DispCond('F2_CLIENTE', 'F2_LOJA', 'F2_TIPODOC')", .F.)
	oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    xAux := FwStruTrigger('F2_LOJA', 'F2_COND', "DispCond('F2_CLIENTE', 'F2_LOJA', 'F2_TIPODOC')", .F.)
	oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

    If oStruSF2:HasField("F2_PROVENT") .AND. oStruSF2:HasField("F2_PV")  
        xAux := FwStruTrigger('F2_CLIENTE', 'F2_PROVENT', "DispProven('F2_CLIENTE', 'F2_LOJA', 'F2_TIPODOC')", .F.)
        oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 

        xAux := FwStruTrigger('F2_LOJA', 'F2_PROVENT', "DispProven('F2_CLIENTE', 'F2_LOJA', 'F2_TIPODOC')", .F.)
        oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4])
    EndIf

    xAux := FwStruTrigger('F2_MOEDA', 'F2_MOEFIN', 'FwFldGet("F2_MOEDA")', .F.)
	oStruSF2:AddTrigger(xAux[1], xAux[2], xAux[3], xAux[4]) 
    
    If oStruSF2:HasField("F2_NATUREZ")
        oStruSF2:SetProperty( 'F2_NATFIN'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetNatFin(1, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_ESPECIE, SF2->F2_TIPODOC), "")'  ) ) 
    EndIF
    oStruSF2:SetProperty( 'F2_DSCMODL'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetNatFin(2, SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_ESPECIE, SF2->F2_TIPODOC), "")'  ) )

    If oStruSF2:HasField("F2_NATUREZ")
        oStruSF2:SetProperty( 'F2_NATFIN'    , MODEL_FIELD_VALID   , FwBuildFeature(STRUCT_FEATURE_INIPAD,GetSX3Cache("F2_NATUREZ", "X3_VALID")))
    EndIf
    oStruSF2:SetProperty( 'F2_MOEFIN'    , MODEL_FIELD_INIT    , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,GetMoeFin(SF2->F2_CLIENTE, SF2->F2_LOJA, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_ESPECIE, SF2->F2_TIPODOC), Val(GetSx3Cache("F2_MOEDA", "X3_RELACAO")))') )
    oStruSF2:SetProperty( 'F2_MOEFIN'    , MVC_MODEL_VALUES    , oOutputFields:GetMonedas()) 
    
    oStruSF2:SetProperty( 'CALC'    , MODEL_FIELD_INIT , { || .F.})

    oStruSEV:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)

    oModel:addFields('SF2_MASTER',,oStruSF2)
    oModel:addGrid('SD2_DETAIL','SF2_MASTER',oStruSD2,,)
    oModel:addGrid('DUP_DETAIL','SF2_MASTER',oStruDUP,,,,,{|oGrid| LoadGridDup(oGrid)})
    oModel:addGrid('SEV_DETAIL','SF2_MASTER',oStruSEV,,)

    oModel:AddCalc("TOTCALC", "SF2_MASTER", "SD2_DETAIL", "D2_TOTAL", "VALMERC", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F2_VALMERC') /*cTitle*/,  { |oModel| LxOutGtFld( oModel, "SF2_MASTER", "F2_VALMERC" ) }/*bFormula*/)
    oModel:AddCalc("TOTCALC", "SF2_MASTER", "SD2_DETAIL", "D2_TOTAL", "DESCONT", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F2_DESCONT') /*cTitle*/,  { |oModel| LxOutGtFld( oModel, "SF2_MASTER", "F2_DESCONT" ) }/*bFormula*/)
    oModel:AddCalc("TOTCALC", "SF2_MASTER", "SD2_DETAIL", "D2_TOTAL", "VALBRUT", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F2_VALBRUT') /*cTitle*/,  { |oModel| LxOutGtFld( oModel, "SF2_MASTER", "F2_VALBRUT" ) }/*bFormula*/)
    oModel:AddCalc("TOTCALC", "SF2_MASTER", "SD2_DETAIL", "D2_QUANT", "QTDACUM", 'SUM',     /*bCondition*/, /*bInitValue*/, RetTitle('B1_QTDACUM') /*cTitle*/,/*bFormula*/)

    // Indica que es opcional tener datos informados en el grid
    oModel:GetModel( 'SD2_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DUP_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEV_DETAIL' ):SetOptional(.T.)
    
    oModel:GetModel("SD2_DETAIL"):SetMaxLine(9999)

    oModel:SetPrimaryKey({'F2_DOC','F2_SERIE','F2_CLIENTE','F2_LOJA'}) //{'F2_FILIAL','F2_DOC','F2_SERIE','F2_FORNECE','F2_LOJA','F2_FORMUL','F2_TIPO'}

    If FWSIXUtil():ExistIndex( "SEV" , "6" )
        aRelSEV       := { { 'EV_FILIAL', 'xFilial( "SEV" )' }, {'EV_NUM', 'F2_DOC'},{'EV_PREFIXO', 'F2_SERIE'},{'EV_CLIFOR', 'F2_CLIENTE'}, {'EV_LOJA', 'F2_LOJA'}}
        nIndSEV       := 6
    EndIf
    oModel:SetRelation('SD2_DETAIL',{ { 'D2_FILIAL', 'xFilial( "SD2" )' }, {'D2_DOC', 'F2_DOC'}, {'D2_SERIE', 'F2_SERIE'}, {'D2_CLIENTE', 'F2_CLIENTE'}, {'D2_LOJA', 'F2_LOJA'}}, SD2->(IndexKey(3)))

    //Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('SF2_MASTER'):SetOnlyQuery(.T.)
    oModel:GetModel('SD2_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('DUP_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SEV_DETAIL'):SetOnlyQuery(.T.)

    oModel:GetModel( "SD2_DETAIL" ):SetUseOldGrid(.T.)
    oModel:GetModel( "SEV_DETAIL" ):SetUseOldGrid(.T.)

    oModel:InstallEvent("LXOUTFIS"	,/*cOwner*/,oEvtFisOut) //Evento ifscal
    oModel:InstallEvent("LXOUTFIN"	,/*cOwner*/,oEvtFinOut) //Evento financiero
    oModel:InstallEvent("LXOUTEST"	,/*cOwner*/,oEvtEstOut) //Evento Stock
    oModel:InstallEvent("LXOUTCTB"	,/*cOwner*/,oEvtCtbOut) //Evento Contable
    oModel:InstallEvent("LXOUTPMS"	,/*cOwner*/,oEvtPMSOut) //Evento PMS
    oModel:InstallEvent("LXOUTPCO"  ,/*cOwner*/,oEvtPCOOut) //Evento PCO
    oModel:InstallEvent("LXOUTWMS"  ,/*cOwner*/,oEvtWMSOut) //Evento WMS

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		03/2022
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oStruSF2      := FWFormStruct( 2, 'SF2', , .T. )
Local oStruSD2      := FWFormStruct( 2, 'SD2', , .T. )
Local oView         := Nil
Local oOutputFields	:= Nil
Local oModel	    := FWLoadModel('LOCXOUT')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:SetContinuousForm(.T.)

    oOutputFields := OutputFieldsAll():New("", .T., .F., .F., .F., .F., .F.)
    oOutputFields:AddFields()
    oStruSF2 := oOutputFields:GetView()

    oView:AddField('oStruSF2' , oStruSF2, 'SF2_MASTER' )
    oView:AddGrid('oStruSD2'  , oStruSD2, 'SD2_DETAIL', , , {||ViewCalOUT(oView)})

    oView:AddIncrementField( 'SD2_DETAIL', 'D2_ITEM' )

    //Campos retirados del grid para no ser editados.
    oStruSD2:RemoveField( "D2_DOC" )
    oStruSD2:RemoveField( "D2_SERIE" )


    oStruSD2:AddField("D2_CODDESC", Soma1(oStruSD2:GetProperty("D2_COD", MVC_VIEW_ORDEM)), STR0007, STR0007, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //Descripción

    //Filtros de busqueda para el grid de productos.
    oView:SetViewProperty("oStruSD2","ENABLENEWGRID")
    oView:SetViewProperty("oStruSD2","GRIDFILTER",{.T.})
    oView:SetViewProperty("oStruSD2","GRIDSEEK",{.T.})

    oView:SetFieldAction( 'F2_DOC',     { |oView| RefreshFld(oView, "SF2_MASTER", "F2_DOC") } )
    oView:SetFieldAction( 'F2_CLIENTE', { |oView| CleanMdOut(oView) } )
    oView:SetFieldAction( 'F2_TXMOEDA', { |oView| ViewCalOUT(oView) } )
    oView:SetFieldAction( 'F2_FRETE',   { |oView| ViewCalOUT(oView) } )
    oView:SetFieldAction( 'F2_DESPESA', { |oView| ViewCalOUT(oView) } )
    oView:SetFieldAction( 'F2_SEGURO',  { |oView| ViewCalOUT(oView) } )
    If oView:GetModel("SF2_MASTER"):HasField("F2_PV")
        oView:SetFieldAction( 'F2_COND',  { |oView| RecalView(oView) } )
    EndIf

    oView:EnableTitleView("oStruSD2",  STR0010 ) //'Productos'
    
	
Return oView


/*/{Protheus.doc} LxStModOut
Función utilizada para actualizar la estructura segun documento/pais para SF2
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oModel - - modelo a ser actualizado con la estructura del documento recibido, debe ser enviado como @oModel.
    cPais - caracter - país para el cual será utilizada la estructura.
    nDoc - numerico - número del documento para ser actualizada la estructura
    cEspecie - caracter - especie del documento.
@Return 
/*/
Function LxStModOut(oModel, cPais, nDoc, cEspecie)
Local oOutputFds	:= Nil
Local oLxOutEvnt	:= LXOUTEVENT():New()

Default oModel      := FWModelActive()
Default cPais       := ""
Default nDoc        := 0
Default cEspecie    := ""

    oOutputFds := OutputFields(cPais,.T., .F., .T., .F., .F., .F., cEspecie)
    oOutputFds:SetModel(oModel:GetModel("SF2_MASTER"):GetStruct())
	oOutputFds:AddModelProperties(nDoc)

    oModel:GetModel("SF2_MASTER"):SetStruct(oOutputFds:getModel())

    oModel:InstallEvent("LXOUTEVENT"   ,/*cOwner*/,oLxOutEvnt) //Evento locxnf

Return

/*/{Protheus.doc} LxSlDocOut
Función utilizada para actualizar la estructura de la view segun documento/pais para SF1
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
    cPais - caracter - país para el cual será utilizada la estructura.
    nDoc - numerico - número del documento para ser actualizada la estructura
    cEspecie - caracter - especie del documento.
@Return 
/*/
Function LxSlDocOut(oView, cPais, nTipo, cEspecie)
Local oOutputFds  := Nil

Default oView   := FwViewActive()
Default cPais       := ""
Default nTipo       := 0
Default cEspecie    := ""

    oOutputFds := OutputFields(cPais,.T., .F., .F., .F., .F., .F., cEspecie)
    oOutputFds:AddFields()
    oOutputFds:AddOutPutFields(nTipo, .T.)
    oOutputFds:CamposGastos()
    oView:GetViewObj("SF2_MASTER")[3]:GetStruct() := oOutputFds:GetView()
    oView:GetViewObj("SF2_MASTER")[3]:oStructview := oOutputFds:GetView()

Return

/*/{Protheus.doc} LxOFinView
Función utilizada para actualizar la estructura para el apartado financiero de la view
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxOFinView(oView)
Local oStruFIN	    := FWFormStruct( 2, 'SF2',{|cCampo| FindString(AllTrim(cCampo), {"F2_COND"})}, .F.)

Default oView   := FwViewActive()

    oStruFIN:SetProperty("F2_COND", MVC_VIEW_ORDEM, "01")
    oStruFIN:AddField("F2_DSCCOND", "02", STR0008, STR0008, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Desc. Pago'
    oStruFIN:AddField("F2_NATFIN", "03", STR0011, STR0011, Nil, "C", "@!", NIL, "SED", .T., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Modalidad'
    oStruFIN:AddField("F2_DSCMODL", "04", STR0009, STR0009, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Desc. Mod.'
    oStruFIN:AddField("F2_MOEFIN", "05", AllTrim(FwX3Titulo("F2_MOEDA")), AllTrim(FwX3Titulo("F2_MOEDA")), {'Moneda financiera' }, "Get", "@!", NIL, , .T., NIL, NIL, NIL, NIL, NIL, .T., NIL) //'Moneda financiera'
    oStruFIN:SetProperty( "F2_MOEFIN", MVC_VIEW_COMBOBOX, oView:GetViewStruct("SF2_MASTER"):GetProperty("F2_MOEDA", MVC_VIEW_COMBOBOX) )
    
    oStruFIN:SetProperty( '*', 	MVC_VIEW_FOLDER_NUMBER, '')
	oStruFIN:aFolders := {}
    oStruFIN:SetProperty( '*', 	MVC_VIEW_GROUP_NUMBER , '')
    oStruFIN:aGroups := {}
    
    
    oView:AddField('oStruFIN' , oStruFIN, 'SF2_MASTER' )

    oView:SetViewProperty('oStruFIN',  'SETLAYOUT', { FF_LAYOUT_HORZ_DESCR_LEFT, 5 } )

    oView:EnableTitleView("oStruFIN", STR0012 ) //'Financiero'

Return

/*/{Protheus.doc} LxOFisView
Función utilizada para actualizar la estructura para el apartado fiscal de la view
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxOFisView(oView)
Local oStruSF3	    := FWFormStruct( 2, 'SF3',, .T.)
Local oStruIMP	    := FWFormViewStruct():New()

Default oView   := FwViewActive()

    oView:AddGrid('oStruSF3' , oStruSF3, 'SF3_DETAIL' )
    oView:EnableTitleView("oStruSF3",  'Fiscales' ) //'Fiscales'

    oStruIMP:AddField('IMP_COD' 	, '1',  STR0013     , STR0013	    , NIL, 'GET', , , , .F.) //'Cod. Imp.'
	oStruIMP:AddField('IMP_DESC' 	, '2',  STR0007	    , STR0007	    , NIL, 'GET', , , , .F.) //'Descripción'
	oStruIMP:AddField('IMP_ALQIMP'  , '3',  STR0014     , STR0014	    , NIL, 'GET', Alltrim(GetSx3Cache("FB_ALIQ","X3_PICTURE")), , , .F.) //'Alic.'
	oStruIMP:AddField('IMP_BASIMP' 	, '4',  STR0015	    , STR0015       , NIL, 'GET', Alltrim(GetSx3Cache("F2_BASIMP1","X3_PICTURE")), , , .F.) //'Base'
    oStruIMP:AddField('IMP_VALIMP' 	, '5',  STR0016     , STR0016	    , NIL, 'GET', Alltrim(GetSx3Cache("F2_VALIMP1","X3_PICTURE")), , , .F.) //'Valor Impuesto'

    oView:AddGrid('oStruIMP' , oStruIMP, 'IMP_DETAIL' )
    oView:EnableTitleView("oStruIMP",  STR0017 ) //Impuestos

Return

/*/{Protheus.doc} LxOTotView
Función utilizada para actualizar la estructura para el apartado de totales de la view
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxOTotView(oView)
Local oStruTot	    := Nil 

Default oView   := FwViewActive()

    oStruTot := FWCalcStruct( oView:GetModel():GetModel( 'TOTCALC') )
    oView:AddField('oStruTot', oStruTot, 'TOTCALC')
    oView:EnableTitleView('oStruTot', STR0018 ) //'Totales'
    
Return

/*/{Protheus.doc} ModOFisStr
Función utilizada para actualizar la estructura fiscal
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
Parametros
    oModel - - modelo a ser actualizado con la estructura del documento recibido, debe ser enviado como @oModel.
@Return 
/*/
Function ModOFisStr(oModel)
Local oStruIMP		:= FWFormModelStruct():New()
Local oStruSF3	    := FWFormStruct(1, 'SF3', , .F.)

Default oModel := FWModelActive()

    oStruIMP:AddTable('' , { '' } , "IMPUESTOS", {|| ''})
    oStruIMP:AddField(STR0013, STR0013, "IMP_COD",'C', GetSx3Cache("FB_CODIGO","X3_TAMANHO")) //'Cod. Imp.'
    oStruIMP:AddField(STR0007, STR0007, "IMP_DESC",'C', GetSx3Cache("FB_DESCR","X3_TAMANHO")) //'Descripción'
    If !Empty(GetSx3Cache("FB_ALIQ","X3_CAMPO"))
        oStruIMP:AddField(STR0014, STR0014, "IMP_ALQIMP",'N', GetSx3Cache("FB_ALIQ","X3_TAMANHO"), GetSx3Cache("FB_ALIQ","X3_DECIMAL")) //'Alic.'
    EndIf
    oStruIMP:AddField(STR0015, STR0015, "IMP_BASIMP",'N', GetSx3Cache("F2_BASIMP1","X3_TAMANHO"), GetSx3Cache("F2_BASIMP1","X3_DECIMAL")) //'Base'
    oStruIMP:AddField(STR0016, STR0016, "IMP_VALIMP",'N', GetSx3Cache("F2_VALIMP1","X3_TAMANHO"), GetSx3Cache("F2_VALIMP1","X3_DECIMAL")) //'Valor Impuesto'

    oStruSF3:SetProperty( '*'           , MODEL_FIELD_OBRIGAT , .F.)
    
    oModel:addGrid('IMP_DETAIL','SF2_MASTER',oStruIMP,,,,,{|oGrid| LoadGridImp(oGrid)})
    oModel:addGrid('SF3_DETAIL','SF2_MASTER',oStruSF3,,)

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

/*/{Protheus.doc} LxViewOutF
Función utilizada para crear los box de los documentos que incluyen fiscal, impuestos, titulos y financiero.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxViewOutF(oView) 

Default oView   := FwViewActive()

    oView:CreateHorizontalBox( 'CIMA'   , 15 ) //Encabezado
    oView:CreateHorizontalBox( 'CIMAFIN', 05 ) //Financiero
	oView:CreateHorizontalBox( 'MEDIO'  , 60 ) //Grid items
	oView:CreateHorizontalBox( 'BAIXOT' , 05 ) //Total
    oView:CreateHorizontalBox( 'BAIXOF' , 15 ) //Financiero/Fiscales

    oView:CreateFolder("FOLDER","BAIXOF")
    oView:AddSheet( 'FOLDER', 'SHEET_TIT', STR0019 ) //'Titulos'
    oView:AddSheet( 'FOLDER', 'SHEET_LIBROS', STR0020 ) //'Libros Fiscales'
    oView:AddSheet( 'FOLDER', 'SHEET_IMP', STR0021 ) //'Impuestos'
    oView:CreateHorizontalBox( 'TITULOS', 100, , , 'FOLDER', 'SHEET_TIT')
    oView:CreateHorizontalBox( 'LIBROS', 100, , , 'FOLDER', 'SHEET_LIBROS')
    oView:CreateHorizontalBox( 'IMPUESTOS', 100, , , 'FOLDER', 'SHEET_IMP') 

    oView:SetOwnerView('oStruSF2', 'CIMA')
    oView:SetOwnerView('oStruFIN', 'CIMAFIN')
	oView:SetOwnerView('oStruSD2', 'MEDIO')
    oView:SetOwnerView('oStruTot', 'BAIXOT')
    oView:SetOwnerView('oStruDUP', 'TITULOS')
    oView:SetOwnerView('oStruSF3', 'LIBROS')
    oView:SetOwnerView('oStruIMP', 'IMPUESTOS')

Return

/*/{Protheus.doc} LxOutView
Función utilizada para crear los box de los documentos que no datos fiscales ni fincieros.
@author 	raul.medina
@since 		08/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxOutView(oView)

Default oView   := FwViewActive()

    //Divisiones horizontales
	oView:CreateHorizontalBox( 'CIMA' , 20 )
	oView:CreateHorizontalBox( 'MEDIO', 60 )
	oView:CreateHorizontalBox( 'BAIXO', 20 )

Return

/*/{Protheus.doc} LxOutGtFld
    Función para obtemer el valor del campo en un modelo
    @type function
    @author 
    @since 08/2026
    @param oModel, objeto, Modelo de datos
    @param cIdMod, Carácter, Modelo a acceder para obtener valor del campo
    @param cField, Carácter, Campo del cual se regresa valor
    return cRet  , Carácter, valor del campo
/*/

Function LxOutGtFld(oModel, cIdMod, cField)
Local oModelId := Nil
Local cRet     := ""

Default oModel  := FWModelActive()
Default cIdMod  := "SF2_MASTER"
Default cField  := ""

    oModelId := oModel:GetModel(cIdMod)
    If oModelId != Nil
        cRet := oModelId:GetValue(cField)
    EndIf

Return cRet


/*/{Protheus.doc} CalcImpOUT
	Función utilizada para realizar el calculo de impuestos de acuerdo a los datos del model, así como la asignación de valores al model.
	@type  Function
	@author raul.medina
    @since 		08/2025
    @version	12.1.2510 / Superior
	@return 
	/*/
Function CalcImpOUT()
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
Local dDEmissao     := dDataBase
Local cCodICA       := ""
Local cCodMun       := ""
Local aClientes     := {"1","2","3","4","5","12","17","19","21","24","50","51","53","62","63"}
Local cEst          := ""
Local cProvent      := ""

    If oModel:GetModel("SF2_MASTER"):HasField("CALC") .and. !oModel:GetModel("SF2_MASTER"):GetValue("CALC") //CALC el falso indica que ya existe calculo y no lo realizará.
        Return .F.
    EndIf

    cCliFor       := oModel:GetModel("SF2_MASTER"):GetValue("F2_CLIENTE")
    cLoja         := oModel:GetModel("SF2_MASTER"):GetValue("F2_LOJA")
    cTipoCF       := "F"
    cTipo         := oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPO")
    cTipoDoc      := oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPODOC")
    cEspecie      := oModel:GetModel("SF2_MASTER"):GetValue("F2_ESPECIE")
    cSerie        := oModel:GetModel("SF2_MASTER"):GetValue("F2_SERIE")
    nNFMoeda      := oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA")
    nTxMoeda      := oModel:GetModel("SF2_MASTER"):GetValue("F2_TXMOEDA")
    cPaymntCnd    := oModel:GetModel("SF2_MASTER"):GetValue("F2_COND")
    nFlete        := oModel:GetModel("SF2_MASTER"):GetValue("F2_FRETE")
    nGastos       := oModel:GetModel("SF2_MASTER"):GetValue("F2_DESPESA")
    nSeguro       := oModel:GetModel("SF2_MASTER"):GetValue("F2_SEGURO")
    nDescont      := oModel:GetModel("SF2_MASTER"):GetValue("F2_DESCONT")
	dDEmissao     := oModel:GetModel("SF2_MASTER"):GetValue("F2_EMISSAO")

    If oModel:GetModel("SF2_MASTER"):HasField("F2_EST")
        cEst       := oModel:GetModel("SF2_MASTER"):GetValue("F2_EST")
    EndIf
    If oModel:GetModel("SF2_MASTER"):HasField("F2_PROVENT")
        cProvent   := oModel:GetModel("SF2_MASTER"):GetValue("F2_PROVENT")
    EndIf
    aOldData      := {}
    aCitensOri    := {}
    aCpItensOri   := {}
    lCalcVal      := !&(IsRemito(2,"'" + cTipoDoc + "'"))
    aOldData      := aClone(oModel:GetModel("SD2_DETAIL"):GetOldData())
    aCpItensOri   := aClone(aOldData[1])
    aCitensOri    := aClone(aOldData[2])
    nTipCli       := aScan(aClientes, { |x| x == cTipoDoc })

    If nTipCli > 0
        cTipoCF := "C"
    EndIf

    //Llamada a la función de calculo.
    ojson := CalImpxMod(cCliFor, cLoja, cTipoCF, cTipo, cAliasProd, cTipoDoc, cEspecie, cSerie, nNFMoeda, nTxMoeda, aCpItensOri, aCitensOri, lCalcVal, nFlete, nGastos, nSeguro, nDescont, dDEmissao, cCodICA, cCodMun,,,cEst,cProvent)

    //Actualización de los valores de los impuestos y libros fiscales.
    ActCalcFis(oModel, ojson, lCalcVal, "SF2_MASTER")

    //Actualización de items
    ActItmsOUT(oModel, ojson)

    If oModel:GetModel("SF2_MASTER"):HasField("CALC")
        oModel:GetModel("SF2_MASTER"):LoadValue("CALC", .F.) //Cambia flag para indicar que no se debe recalcular.
    EndIf

    //Se actualizan los datos de los títulos.
    If lCalcVal
        F2PaymntCn(cPaymntCnd)
    EndIf

Return .T.

/*/{Protheus.doc} ActItmsOUT
	Función utilizada para actualizar los valores de los items dentro del model.
	@type  Function
	@author raul.medina
	@since 08/2026
    @version	12.1.2510 / Superior
	@param
        oModel -  - Model que está siendo procesado.
        ojson - JsonObject - Json con la información de totales y valores por item.
	@return 
	/*/
Function ActItmsOUT(oModel, ojson)
Local oModelSD2     := oModel:GetModel("SD2_DETAIL")
Local nX            := 0
Local nLine         := 0

Default oModel      := FWModelActive()
Default ojson       := JsonObject():new()

    nLine := oModelSD2:GetLine()
    For nX := 1 To oModelSD2:Length()
        oModelSD2:GoLine(nX)
        If !oModelSD2:IsDeleted(nX)
            oModelSD2:LoadValue("D2_DESCON", ojson['ITEMS'][nX]['IT_DESCONTO'])
            oModelSD2:LoadValue("D2_VALFRE", ojson['ITEMS'][nX]['IT_FRETE'])
            oModelSD2:LoadValue("D2_DESPESA", ojson['ITEMS'][nX]['IT_DESPESA'])
            oModelSD2:LoadValue("D2_SEGURO", ojson['ITEMS'][nX]['IT_SEGURO'])
        EndIf
    Next
    oModelSD2:GoLine(nLine)

Return

/*/{Protheus.doc} F2PaymntCn
Función utilizada para realizar la llamada de la actualización de los valores de los títulos..
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    cCondition - caracter - código de la condición de pago utilizada.
@Return 
/*/
Function F2PaymntCn(cCondition)
Local oModel    := FwModelActivate()
Local oModelSF2 := oModel:GetModel("SF2_MASTER")
Local oModelSD2 := oModel:GetModel("SD2_DETAIL")
Local nMoedaFin := 1
Local aOldData  := {}

//Variables privadas para Colombia.
Private N       := oModelSD2:GetLine()
Private aHeader := {}
Private aCols   := {}

Default cCondition  := ""

    aOldData := aClone(oModelSD2:GetOldData())
    aHeader := aClone(aOldData[1])
    aCols  := aClone(aOldData[2])

    If Type("cEspecie") <> "C"
        cEspecie := FwFldGet("F2_ESPECIE")
    EndIf

    If Type("nTipo") <> "N"
        nTipo := Val(FwFldGet("F2_TIPO"))
    EndIf

    If !(Type("dDEmissao") == "D")
		dDEmissao  := oModelSF2:GetValue("F2_EMISSAO")
	EndIf

    nMoedaFin := IIf(oModelSF2:HasField("F2_MOEFIN") .and. !Empty(oModelSF2:GetValue("F2_MOEFIN")),  oModelSF2:GetValue("F2_MOEFIN"), oModelSF2:GetValue("F2_MOEDA"))
    MPaymntCon(@oModel, oModelSF2:GetValue("BASEDUP"), oModelSF2:GetValue("F2_MOEDA"), oModelSF2:GetValue("F2_EMISSAO"), cCondition, oModelSF2:GetValue("F2_NATUREZ"), oModelSF2:GetValue("F2_TXMOEDA"), oModelSF2:GetValue("F2_DOC"), oModelSF2:GetValue("F2_SERIE"), nMoedaFin)

    FwFreeArray(aOldData)

Return

/*/{Protheus.doc} ViewCalOUT
Función utilizada para realizar la llamada de calculo de impuestos/valores y actualización de las views.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido.
@Return 
/*/
Function ViewCalOUT(oView)
Local lRefresh      := .T.
Local nFocus        := GetFocus()
Local aModelsId     := {}
Local nOper         := oView:GetOperation()
Local oModel        := oView:oModel

Default oView   := FwViewActive()

    If nOper == MODEL_OPERATION_INSERT .and. oModel:GetModel("SF2_MASTER"):HasField("CALC") .and. oModel:GetModel("SF2_MASTER"):GetValue("CALC") //CALC en falso indica que no debe realizarse el calculo (Ya realizado).
        FWMsgRun( , {|| lRefresh := CalcImpOUT()}, "Calculando", "Calculando" )
        If lRefresh
            oView:Refresh("oStruSD2")
            oView:Refresh("oStruTot")
            aModelsId := oView:GetModelsIds()
            If FindString("SF3_DETAIL", aModelsId) //Verificación de existencia del grid
                oView:Refresh("oStruSF3")
            EndIf
            If FindString("IMP_DETAIL", aModelsId) //Verificación de existencia del grid
                oView:Refresh("oStruIMP")
            EndIf
            SetFocus(nFocus)
           
        EndIf
    EndIf

Return

/*/{Protheus.doc} CleanMdOut
Función utilizada para realizar la limpieza de los valores del model.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido.
@Return 
/*/
Function CleanMdOut(oView)
Local nFocus        := GetFocus()
Local aModelsId     := {}
Local oModel        := oView:GetModel()

Default oView   := FwViewActive()

        //Items
        oModel:GetModel("SD2_DETAIL"):ClearData(.T., .T.)
        oView:Refresh("oStruSD2")
        //Totales
        oModel:GetModel("SF2_MASTER"):LoadValue("F2_VALMERC", 0)
        oModel:GetModel("SF2_MASTER"):LoadValue("F2_DESCONT", 0)
        oModel:GetModel("SF2_MASTER"):LoadValue("F2_VALBRUT", 0)
        oModel:GetModel("SF2_MASTER"):LoadValue("BASEDUP", 0)
        //LxSetVal(oModel,0)
        oView:Refresh("oStruTot")
        //Prorrateo

        aModelsId := aClone(oView:GetModelsIds())
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
        FwFreeArray(aModelsId)

Return


/*/{Protheus.doc} LoadGridImp
Función utilizada para realizar la carga inicial de los impuestos al visualizar o borrar un documento.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oGrid -  - submodelo del grid que está siendo inicializado.
@Return 
    aLoadGrid - array - Información para ser asiganada al grid.
/*/
Static Function LoadGridImp(oGrid)
Local aLoadGrid	:= {}

Default oGrid      := FWModelActive()

    If oGrid:GetOperation() == MODEL_OPERATION_DELETE .Or. oGrid:GetOperation() == MODEL_OPERATION_VIEW
        aLoadGrid := GImpostosD2(FwFldGet("F2_DOC"), FwFldGet("F2_SERIE"), FwFldGet("F2_CLIENTE"), FwFldGet("F2_LOJA"), FwFldGet("F2_ESPECIE"))
    EndIf

Return aLoadGrid


/*/{Protheus.doc} LoadGridDup
Función utilizada para realizar la carga inicial de los títulos al visualizar o borrar un documento.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oGrid -  - submodelo del grid que está siendo inicializado.
@Return 
    aLoadGrid - array - Información para ser asiganada al grid.
/*/
Static Function LoadGridDup(oGrid)
Local aLoadGrid	:= {}
Local oTipoDoc
Local cTable    := ""

Default oGrid      := FWModelActive()

    If oGrid:GetOperation() == MODEL_OPERATION_DELETE .Or. oGrid:GetOperation() == MODEL_OPERATION_VIEW
        oTipodoc := TipoDoc():New()
        oTipoDoc:SetTipoDoc(FwFldGet("F2_TIPODOC"))
        cTable := oTipoDoc:GetTableFinDoc()
        aLoadGrid := GetDupFin(cTable, FwFldGet("F2_DOC"), FwFldGet("F2_SERIE"), FwFldGet("F2_CLIENTE"), FwFldGet("F2_LOJA"), FwFldGet("F2_ESPECIE"))
    EndIf

Return aLoadGrid

/*/{Protheus.doc} RefreshFld
Función utilizada verificar si un campo sufrió un cambio en la variable de memoria y debe ser actualizado.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oView -  - view que está siendo procesado.
    cModelId - caracter - nombre de la vista que debe ser actualizada.
    cField - caracter - nombre del campo que está siendo actualizado.
@Return 
/*/
Static Function RefreshFld(oView, cModelId, cField)
Local oSubModel

Default oView   := FwViewActive()
Default cModelId:= "SF2_MASTER"
Default cField  := ""

    oSubModel := oView:GetModel(cModelId)
    If !(oSubModel:GetValue(cField) == FWFLDGET(cField))
        oSubModel:LoadValue("F2_DOC", FWFLDGET(cField)) 
        oView:Refresh(cModelId)
    EndIf

Return

/*/{Protheus.doc} RecalView
Función para recalcular impuestos
@param      oView,objeto,view que está siendo procesado.
@return		Nil,nulo , regresa nulo
@author 	raul.medina
@since 		29/09/2024
/*/
Static Function RecalView(oView)
Local oModel

Default oView := FwViewActive()
    
    If MsgYesNo(OemToAnsi(STR0023),OemToAnsi(STR0022)) // STR0023 - Impuestos // STR0022-"¿Desea rehacer el cálculo de los impuestos?"                                                                                                                                                                              
        oModel := oView:GetModel()
        oModel:GetModel("SF2_MASTER"):LoadValue("CALC", .T.)
        ViewCalOUT(oView)
    EndIf

Return Nil

/*/{Protheus.doc} GInfoTesD2
	Función utilizada para generar un json con la información de las TES de un documento.
	@type  Function
	@author raul.medina
	@since 
	@param
        cDoc - caracter - Numero del documento.
        cSerie - caracter - Serie del documento.
        cCliente - caracter - Código del cliente/proveedor.
        cLoja - caracter - Loja del cliente/proveedor.
        cEspecie - caracter - Especie del documento.
	@return 
        oTes - json - json con la información de las TES de un documento.
*/
Function GInfoTesD2(cDoc, cSerie, cCliente, cLoja, cEspecie)
Local cAliasTmp     := getNextAlias()
Local cQuery        := ""
Local oTes          := JsonObject():new()
Local oQryExec      := Nil
Local nOrd          := 1

Default cDoc        := ""
Default cSerie      := ""
Default cCliente    := ""
Default cLoja       := ""
Default cEspecie    := ""

    //Impuestos de documento
    cQuery := " SELECT SD2.D2_TES, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_DESCR "
    cQuery += " FROM " + RetSqlName("SD2") + " SD2, "
    cQuery +=            RetSqlName("SFC") + " SFC, "
    cQuery +=            RetSqlName("SFB") + " SFB "
    cQuery += " WHERE SD2.D2_FILIAL   = ? "
    cQuery += " AND   SD2.D2_DOC      = ? "
    cQuery += " AND   SD2.D2_SERIE    = ? "
    cQuery += " AND   SD2.D2_CLIENTE  = ? "
    cQuery += " AND   SD2.D2_LOJA     = ? "
    cQuery += " AND   SD2.D2_ESPECIE  = ? "
    cQuery += " AND   SD2.D2_TES      = SFC.FC_TES"
    cQuery += " AND   SFC.FC_IMPOSTO  = SFB.FB_CODIGO"
    cQuery += " AND   SFC.FC_FILIAL   = ? "
    cQuery += " AND   SFB.FB_FILIAL   = ? "
    cQuery += " AND   SD2.D_E_L_E_T_  = ? "
    cQuery += " AND   SFC.D_E_L_E_T_  = ? "
    cQuery += " AND   SFB.D_E_L_E_T_  = ? "
    cQuery += " GROUP BY SD2.D2_TES, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_DESCR"
    cQuery += " ORDER BY SD2.D2_TES, SFB.FB_CODIGO, SFB.FB_CPOLVRO, SFB.FB_DESCR"

    cQuery := ChangeQuery(cQuery)
    
    oQryExec := FWExecStatement():New(cQuery)

    oQryExec:SetString(nOrd++, xFilial("SD2")) //Numero 
    oQryExec:SetString(nOrd++, cDoc) //Numero 
    oQryExec:SetString(nOrd++, cSerie) //Serie 
    oQryExec:SetString(nOrd++, cCliente) //Cliente 
    oQryExec:SetString(nOrd++, cLoja) //Loja 
    oQryExec:SetString(nOrd++, cEspecie) //cEspecie
    oQryExec:SetString(nOrd++, xFilial("SFC")) //Numero 
    oQryExec:SetString(nOrd++, xFilial("SFB")) //Numero 
    oQryExec:SetString(nOrd++, ' ') //DELET SD2 
    oQryExec:SetString(nOrd++, ' ') //DELET SFC 
    oQryExec:SetString(nOrd++, ' ') //DELET SFB 


    cAliasTmp := oQryExec:OpenAlias()

    While (cAliasTmp)->(!Eof())
        If !oTes:HasProperty((cAliasTmp)->D2_TES)
            oTes[(cAliasTmp)->D2_TES] := {}
        EndIf
        aAdd(oTes[(cAliasTmp)->D2_TES], {(cAliasTmp)->FB_CODIGO, (cAliasTmp)->FB_CPOLVRO, (cAliasTmp)->FB_DESCR})
        (cAliasTmp)->(DbSkip())
    EndDo
    (cAliasTmp)->(DBCloseArea())

    oQryExec:Destroy()

Return oTes

/*/{Protheus.doc} GImpostosD2
	Función utilizada para generar un array con la información de los impuestos de un documento.
	@type  Function
	@author raul.medina
	@since 
	@param
        cDoc - caracter - Numero del documento.
        cSerie - caracter - Serie del documento.
        cCliente - caracter - Código del cliente/proveedor.
        cLoja - caracter - Loja del cliente/proveedor.
        cEspecie - caracter - Especie del documento.
	@return 
        aRetImp - array - array con la información de los impuestos de un documento.
*/
Function GImpostosD2(cDoc, cSerie, cCliente, cLoja, cEspecie)
Local cAliasSD2     := ""
Local cQuery        := ""
Local cCampos       := ""
Local cGroup        := ""
Local nX            := 0
Local nBasImp       := 0
Local nAlqImp       := 0
Local nValImp       := 0
Local nParam        := 1
Local aCposImpD2    := Nil
Local oTes
Local aTes
Local oImpuestos    := JsonObject():new()
Local aRetImp       := {}
Local aJsonImp      := {}
Local oQryExec

Default cDoc        := ""
Default cSerie      := ""
Default cCliente    := ""
Default cLoja       := ""
Default cEspecie    := ""

    oTes := GInfoTesD2(cDoc, cSerie, cCliente, cLoja, cEspecie)

    aCposImpD2 := FWFormStruct( 1, 'SD2',{|cCampo| "D2_VALIMP" $ cCampo .Or. "D2_ALQIMP" $ cCampo .Or. "D2_BASIMP" $ cCampo}, .F.):GetFields()

    // Monta os campos do SELECT dinamicamente
    cCampos := "SD2.D2_TES"
    cGroup  := "SD2.D2_TES"
    For nX := 1 To Len(aCposImpD2)
        If "D2_ALQIMP" $ aCposImpD2[nX][MODEL_FIELD_IDFIELD]
            cCampos += ", SD2." + aCposImpD2[nX][MODEL_FIELD_IDFIELD]
            cGroup  += ", SD2." + aCposImpD2[nX][MODEL_FIELD_IDFIELD]
        Else
            cCampos += ", SUM(SD2." + aCposImpD2[nX][MODEL_FIELD_IDFIELD] + ") AS " + aCposImpD2[nX][MODEL_FIELD_IDFIELD]
        EndIf
    Next

    // Monta a query com placeholders para binds
    cQuery  := "SELECT " + cCampos + " "
    cQuery  += "FROM " + RetSqlName("SD2") + " SD2 "
    cQuery  += "WHERE SD2.D2_FILIAL  = ? "
    cQuery  += "AND   SD2.D2_DOC     = ? "
    cQuery  += "AND   SD2.D2_SERIE   = ? "
    cQuery  += "AND   SD2.D2_CLIENTE = ? "
    cQuery  += "AND   SD2.D2_LOJA    = ? "
    cQuery  += "AND   SD2.D2_ESPECIE = ? "
    cQuery  += "AND   SD2.D_E_L_E_T_ = ? "
    cQuery  += "GROUP BY " + cGroup + " "
    cQuery  += "ORDER BY SD2.D2_TES"

    cQuery := ChangeQuery(cQuery)

    oQryExec := FwExecStatement():New(cQuery)

    oQryExec:SetString(nParam++, xFilial("SD2"))     // D2_FILIAL
    oQryExec:SetString(nParam++, cDoc)               // D2_DOC
    oQryExec:SetString(nParam++, cSerie)             // D2_SERIE
    oQryExec:SetString(nParam++, cCliente)           // D2_CLIENTE
    oQryExec:SetString(nParam++, cLoja)              // D2_LOJA
    oQryExec:SetString(nParam++, cEspecie)           // D2_ESPECIE
    oQryExec:SetString(nParam++, " ")                // D_E_L_E_T_

    cAliasSD2 := oQryExec:OpenAlias()

    While (cAliasSD2)->(!Eof())
        aTes := If(oTes:HasProperty((cAliasSD2)->D2_TES), oTes[(cAliasSD2)->D2_TES], {})
        For nX := 1 To Len(aTes)
            nBasImp := (cAliasSD2)->&("D2_BASIMP"+aTes[nX][2])
            nAlqImp := (cAliasSD2)->&("D2_ALQIMP"+aTes[nX][2])
            nValImp := (cAliasSD2)->&("D2_VALIMP"+aTes[nX][2])
            If nBasImp > 0
                GroupImp(@oImpuestos, aTes[nX][1], aTes[nX][3], nBasImp, nAlqImp, nValImp)
            EndIf
        Next
        (cAliasSD2)->(DbSkip())
    EndDo

    (cAliasSD2)->(DbCloseArea())
    oQryExec:Destroy()
    oQryExec := Nil

    aJsonImp := oImpuestos:GetNames()
    For nX := 1 To Len(aJsonImp)
        aAdd(aRetImp, {nX-1, oImpuestos[aJsonImp[nX]]})
    Next

    FwFreeArray(aJsonImp)

Return aClone(aRetImp)


/*/{Protheus.doc} ActMdlItOt
	Función utilizada para atualizar os itens do grid SD2_DETAIL dentro do model de salidas,
	carregando os valores de cada coluna a partir dos arrays de cabealho e colunas recebidos.
	Para cada item com cdigo de produto preenchido, adiciona ou atualiza a linha correspondente
	no submodelo SD2, ajustando tambm os campos de documento, srie, cliente/fornecedor,
	loja e descrio do produto.
	@type  Function
	@author raul.medina
	@since 08/2026
	@version 12.1.2510 / Superior
	@param oModel, Objeto, Model principal que contm os submodelos SF2_MASTER e SD2_DETAIL.
	                        Quando no informado, utiliza o model ativo via FwModelActivate().
	@param aColsAct, Array, Array de arrays com os valores de cada item/linha a ser carregado no grid.
	                        Cada posio corresponde a uma linha de item.
	@param aHeaderAct, Array, Array com os descritores dos campos (cabealho) que sero atualizados,
	                          onde cada elemento contm o nome do campo na posio [2].
	@param lInit, Lógico, Indica se a atualizao  de inicializao (.T.) ou de alterao (.F.).
	                       Padro: .F.
	@param lBlankLine, Lógico, Indica se deve ser considerada a adio de linha em branco no grid.
	                            Padrón: .T.
	@return Nil
/*/
Function ActMdlItOt(oModel, aColsAct, aHeaderAct, lInit, lBlankLine, nLine)
Local oModelSD2     := Nil
Local nX            := 0  
Local nY            := 0 
Local xValue           
Local nPosCod       := 0
Local nDelLine      := 0
Local oStruSD2      := Nil
Local cDoc          := ""
Local cSerie        := ""
Local cCliForn      := ""
Local cLojaCliF     := ""
Local lRet          := .T.

Default oModel      := FwModelActivate()
Default aColsAct    := {}
Default aHeaderAct  := {}
Default lInit       := .F.
Default lBlankLine  := .T.
Default nLine       := 0

    oModelSD2 := oModel:GetModel("SD2_DETAIL")
    cCliForn := oModel:GetModel("SF2_MASTER"):GetValue("F2_CLIENTE")
    cLojaCliF := oModel:GetModel("SF2_MASTER"):GetValue("F2_LOJA")
    cDoc := oModel:GetModel("SF2_MASTER"):GetValue("F2_DOC")
    cSerie := oModel:GetModel("SF2_MASTER"):GetValue("F2_SERIE")
    oStruSD2 := oModelSD2:GetStruct()
    nPosCod := oStruSD2:GetFieldPos("D2_COD")

    nDelLine := Len(aHeader)+1 
    If nLine > 0
        oModelSD2:GoLine(nLine)
    Else
        oModelSD2:ClearData(lInit, lBlankLine)
    EndIf
    For nX := 1 To Len(aColsAct)
        If !Empty(aColsAct[nX][nPosCod])
            If oModelSD2:Length() < nX
                oModelSD2:LVALID := .T. //Actualización x campo
                oModelSD2:AddLine()
            EndIf
            //Actualización x campo
            For nY := 1 To Len(aHeaderAct)
                If !Empty(aColsAct[nX][nY])
                    xValue := TypeData(oStruSD2, AllTrim(aHeaderAct[nY][2]), aColsAct[nX][nY])
                    oModelSD2:LoadValue(AllTrim(aHeaderAct[nY][2]), xValue)
                EndIf
            Next
            oModelSD2:LoadValue("D2_DOC", cDoc)
            oModelSD2:LoadValue("D2_SERIE", cSerie)
            oModelSD2:LoadValue("D2_CLIENTE", cCliForn)
            oModelSD2:LoadValue("D2_LOJA", cLojaCliF)
            oModelSD2:LoadValue("D2_CODDESC", AllTrim(Posicione("SB1", 1, xFilial("SB1") + oModelSD2:GetValue("D2_COD"), "B1_DESC")))
            lRet := .T.
            If aColsAct[nX][nDelLine]
                oModelSD2:DeleteLine()
            EndIf
        EndIf
    Next
    oModelSD2:GoLine(1)

Return lRet

/*/{Protheus.doc} LxNFSD2F6
Función utilizada para realizar la llamada de la seleccion de documentos
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf..
@Return 
/*/
Function LxNFSD2F6(oModel) 
Local lRet          := .F.
Local oModelSD2     := Nil
Local aOldData      := {}
Local nTipo         := 0
Local nMoneda       := 0
Local nTaxaMon      := 0

Private aHeader     := {}
Private aCols       := {}
Private cCliFor     := ""
Private cLoja       := ""

Default oModel      := FwModelActivate()

    oModelSD2     := oModel:GetModel("SD2_DETAIL")
    aOldData := aClone(oModelSD2:GetOldData())
    cCliFor := oModel:GetModel("SF2_MASTER"):GetValue("F2_CLIENTE")
    cLoja := oModel:GetModel("SF2_MASTER"):GetValue("F2_LOJA")
    nTipo := Val(oModel:GetModel("SF2_MASTER"):GetValue("F2_TIPODOC"))
    nMoneda := oModel:GetModel("SF2_MASTER"):GetValue("F2_MOEDA")
    nTaxaMon := oModel:GetModel("SF2_MASTER"):GetValue("F2_TXMOEDA")
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF2CfgNF()
    EndIf
    aHeader := aClone(aOldData[1])
    aCols  := aClone(aOldData[2])

    If LxN466ForF6(nTipo, nMoneda, nTaxaMon)
        If ActMdlItOt(oModel, aCols, aHeader, .F., .T.)
            If oModel:GetModel("SF2_MASTER"):HasField("CALC")
                oModel:GetModel("SF2_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
            EndIf
            lRet := .T.
        EndIf
    EndIf

    FwFreeArray(aOldData)

Return lRet

/*/{Protheus.doc} LxSCMToNF2
Función utilizada para realizar la llamada de la seleccion Remitos (Item).
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function LxSCMToNF2(oModel)
Local lRet          := .F.
Local oModelSD2     := Nil
Local aOldData      := {}

Private aHeader     := {}
Private aCols       := {}
Private cCliFor     := ""
Private cLoja       := ""
Private cCadastro   := ""

Default oModel      := FwModelActivate()

    oModelSD2     := oModel:GetModel("SD2_DETAIL")
    aOldData := aClone(oModelSD2:GetOldData())
    cCliFor := oModel:GetModel("SF2_MASTER"):GetValue("F2_CLIENTE")
    cLoja := oModel:GetModel("SF2_MASTER"):GetValue("F2_LOJA")
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF2CfgNF()
    EndIf
    cCadastro:= aCfgNF[20]
    aHeader := aClone(aOldData[1])
    aCols  := aClone(aOldData[2])

    If SCMToNF2(.F.)
        If ActMdlItOt(oModel, aCols, aHeader, .F., .T.)
            If oModel:GetModel("SF2_MASTER"):HasField("CALC")
                oModel:GetModel("SF2_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
            EndIf
            lRet := .T.
        EndIf
    EndIf

    FwFreeArray(aOldData)

Return lRet

/*/{Protheus.doc} LxSCMToRm2
Función utilizada para realizar la llamada de la seleccion Remitos.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function LxSCMToRm2(oModel)
Local lRet          := .F.
Local oModelSD2     := Nil
Local aOldData      := {}

Private aHeader     := {}
Private aCols       := {}
Private cCliFor     := ""
Private cLoja       := ""
Private cCadastro   := ""

Default oModel      := FwModelActivate()

    oModelSD2     := oModel:GetModel("SD2_DETAIL")
    aOldData := aClone(oModelSD2:GetOldData())
    cCliFor := oModel:GetModel("SF2_MASTER"):GetValue("F2_CLIENTE")
    cLoja := oModel:GetModel("SF2_MASTER"):GetValue("F2_LOJA")
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF2CfgNF()
    EndIf
    cCadastro:= aCfgNF[20]
    aHeader := aClone(aOldData[1])
    aCols  := aClone(aOldData[2])

    If SCMToREM2(.F.)
        If ActMdlItOt(oModel, aCols, aHeader, .F., .T.)
            If oModel:GetModel("SF2_MASTER"):HasField("CALC")
                oModel:GetModel("SF2_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
            EndIf
            lRet := .T.
        EndIf
    EndIf

    FwFreeArray(aOldData)

Return lRet

/*/{Protheus.doc} LXStockOut
Función utilizada para realizar la llamada de la seleccion Doc Orig
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function LXStockOut(oModel, cOpc, cCampo, lActItems)
Local lRet          := .F.
Local oModelSD2     := Nil
Local aOldData      := {}


Private aHeader     := {}
Private aCols       := {}
Private n           := 0

Default oModel  := FwModelActivate()
Default cOpc        := "2"
Default cCampo      := ""
Default lActItems   := .F.

    oModelSD2     := oModel:GetModel("SD2_DETAIL")
    aOldData := aClone(oModelSD2:GetOldData())
    n := oModelSD2:GetLine()
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF2CfgNF()
    EndIf
    aHeader := aClone(aOldData[1])
    aCols  := aClone(aOldData[2])

    LocXStock(cOpc, cCampo, .F.)

    If "D2_NFORI" $ cCampo
        If ActMdlItOt(oModel, {aCols[n]}, aHeader, .F., .F., n)
            If oModel:GetModel("SF2_MASTER"):HasField("CALC")
                oModel:GetModel("SF2_MASTER"):LoadValue("CALC", .T.) //Cambia flag para indicar que no se debe recalcular.
            EndIf
            lRet := .T.
        EndIf
    EndIf

    FwFreeArray(aOldData)

Return lRet

/*/{Protheus.doc} LXInPMSOut
Función utilizada para realizar integración con PMS
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function LXInPMSOut(oModel)
Local lRet          := .F.
Local oModelSD2     := Nil
Local aOldData      := {}


Private aHeader     := {}
Private aCols       := {}
Private aRatAFS     := {}

Default oModel  := FwModelActivate()

    oModelSD2     := oModel:GetModel("SD2_DETAIL")
    aOldData := aClone(oModelSD2:GetOldData())
    n := oModelSD2:GetLine()
    If !(Type("aCfgNf") == "A")
        aCfgNf  := GetF2CfgNF()
    EndIf
    If !(Type("__nOpcx") == "N")
        __nOpcx := 1
    EndIf
    If !(Type("aRotina") == "A")
        aRotina := {{"", "", 0, oModel:GetOperation(), 0, .F.}}
    EndIf
    If !(Type("cP3") == "C")
        cP3 := "F2_"
    EndIf
    If !(Type("nOpcao") == "N")
        nOpcao := oModel:GetOperation()
    EndIf
    If !(Type("nOpc") == "N")
        nOpc := oModel:GetOperation()
    EndIf
    aHeader := aClone(aOldData[1])
    aCols  := aClone(aOldData[2])
    

    PmsVldNf()

    FwFreeArray(aOldData)
    FwFreeArray(aRatAFS)

Return lRet

/*/{Protheus.doc} MultNatOut
Función utilizada para la llamada del prorrateo de la multinaturaleza.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
    oModel -  - modelo utilizado para documentos de la locxnf.
@Return 
/*/
Function MultNatOut(oModel)
Local oModelSEV     := Nil
Local nOperation    := Nil
Local nValor        := Nil

Default oModel  := FwModelActivate()

    oModelSEV     := oModel:GetModel("SEV_DETAIL")
    nOperation    := oModel:GetOperation()
    nValor        := oModel:GetModel("SF2_MASTER"):GetValue("BASEDUP")

    //RatMulTiNat(oModelSEV, nOperation, nValor, oModelSDE)

Return

/*/{Protheus.doc} LxLegndOut
Función utilizada para la llamada la función de leyendas de la locxnf.
@author 	raul.medina
@since 		08/2026
@version	12.1.2510 / Superior
Parametros
@Return 
/*/
Function LxLegndOut()

Private lIntegracao	:= SuperGetMV("MV_EASY",.F.,"N") == "S"
Private aCfgNf      := {}

    aCfgNf  := GetCfgNF(SF2->F2_TIPODOC)

    LocxLegenda("SF2")

Return

/*/{Protheus.doc} VD2_RATEIO
	Función encargada de realizar las validaciones para el campo D2_RATEIO.
	@type  Function
	@author raul.medina
	@since 
	@param
	@return 
		lValid -Logico - Devuelve el resultado de las validaciones.
	/*/
Function VD2_RATEIO()
Local lRet      := .T.

    lRet := Pertence("12") //.And. NCPRATCC(M->D2_RATEIO) Verificar como activar pantalla

Return lRet

