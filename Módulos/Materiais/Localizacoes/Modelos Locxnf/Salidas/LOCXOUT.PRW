#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

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

    oModel := MPFormModel():New( 'LOCXOUT',/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

    oOutputFields := OutputFieldsAll():New("", .T., .F., .F., .F., .F., .F.)
    oOutputFields:AddModel()

    oStruSF2 := oOutputFields:getModel()

    //Tabla de saldos y monedas
	oStruDUP:AddTable('' , { '' } , "DUPLICATAS", {|| ''})
    nTamDup := GetSx3Cache('E2_NUM', 'X3_TAMANHO') + GetSx3Cache('E2_PREFIXO', 'X3_TAMANHO') +  GetSx3Cache('E2_PARCELA', 'X3_TAMANHO') + GetSx3Cache('E2_VENCTO', 'X3_TAMANHO') +  GetSx3Cache('E2_VALOR', 'X3_TAMANHO') + 13
	oStruDUP:AddField('DUP' 	, 'DUP'	, 'DUP' 	, 'C' , nTamDup)

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

    oStruSF2:AddField('', '',"BASEDUP","N",GetSX3Cache("F2_VALMERC", "X3_TAMANHO"),GetSX3Cache("F2_VALMERC", "X3_DECIMAL"),/*valid*/,,,,)
    oStruSF2:AddField("AUTO"		,"AUTO"					,"AUTO"		,"L",1)
    oStruSF2:AddField(AllTrim(FwX3Titulo("F2_MOEDA")), AllTrim(FwX3Titulo("F2_MOEDA")), "F2_MOEFIN", GetSX3Cache("F2_MOEDA", "X3_TIPO"), GetSX3Cache("F2_MOEDA", "X3_TAMANHO"), GetSX3Cache("F2_MOEDA", "X3_DECIMAL"),,,,,,,,.T.,)

    oStruSEV:SetProperty('*'        , MODEL_FIELD_OBRIGAT , .F.)

    oModel:addFields('SF2_MASTER',,oStruSF2)
    oModel:addGrid('SD2_DETAIL','SF2_MASTER',oStruSD2,,)
    oModel:addGrid('DUP_DETAIL','SF2_MASTER',oStruDUP,,)
    oModel:addGrid('SEV_DETAIL','SF2_MASTER',oStruSEV,,)

    // Indica que es opcional tener datos informados en el grid
    oModel:GetModel( 'SD2_DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DUP_DETAIL' ):SetOptional(.T.)
    oModel:GetModel( 'SEV_DETAIL' ):SetOptional(.T.)

    oModel:SetPrimaryKey({'F2_DOC','F2_SERIE','F2_CLIENTE','F2_LOJA'}) //{'F2_FILIAL','F2_DOC','F2_SERIE','F2_FORNECE','F2_LOJA','F2_FORMUL','F2_TIPO'}

    oModel:SetRelation('SD2_DETAIL',{ { 'D2_FILIAL', 'xFilial( "SD2" )' }, {'D2_DOC', 'F2_DOC'}, {'D2_SERIE', 'F2_SERIE'}, {'D2_CLIENTE', 'F2_CLIENTE'}, {'D2_LOJA', 'F2_LOJA'}}, SD2->(IndexKey(3)))

    //Indica No grabar datos de un componente del modelo de datos
	oModel:GetModel('DUP_DETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('SEV_DETAIL'):SetOnlyQuery(.T.)

    oModel:GetModel( "SD2_DETAIL" ):SetUseOldGrid(.T.)

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
    oView:AddGrid('oStruSD2'  , oStruSD2, 'SD2_DETAIL')

    //Divisiones horizontales
	oView:CreateHorizontalBox( 'CIMA' , 35)
	oView:CreateHorizontalBox( 'MEDIO', 35)
	oView:CreateHorizontalBox( 'BAIXO', 30)

    oView:SetOwnerView('oStruSF2', 'CIMA')
	oView:SetOwnerView('oStruSD2', 'MEDIO')
	
Return oView
