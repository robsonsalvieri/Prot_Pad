//#INCLUDE 'TECA746.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//Status do orçamento de serviços
#DEFINE DEF_TFJ_ATIVO     "1" //TFJ_STATUS Contrato Gerado
#DEFINE DEF_TFJ_EMREVISAO "2" //TFJ_STATUS Em Revisão
#DEFINE DEF_TFJ_REVISADO  "3" //TFJ_STATUS Revisado
#DEFINE DEF_TFJ_AGDAPROVA "4" //TFJ_STATUS Aguardando Aprovação
#DEFINE DEF_TFJ_ENCERRADO "5" //TFJ_STATUS Encerrado
#DEFINE DEF_TFJ_CANCELADO "6" //TFJ_STATUS Cancelado
#DEFINE DEF_TFJ_INATIVO   "7" //TFJ_STATUS Inativo

/*/{Protheus.doc} TECA746
    (long_description)
    @type Function
    @author Anderson F. Gomes
    @since 13/03/2025
    @version 12.1.2310
    @return Nil, Nil, Nulo
/*/
Function TECA746()
    Local oBrowse As Object
    Local cFiltro := "TFJ_ORCSIM == '1' .AND. EMPTY(TFJ_CODVIS) .AND. TFJ_RESTEC <> '1'"

    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias( "TFJ" )
    oBrowse:SetMenudef( "TECA746" )
    oBrowse:SetDescription( "Orçamento para Serviços" )

	oBrowse:AddLegend( "EMPTY(TFJ->TFJ_CONTRT) .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_INATIVO + "'","BR_VERDE","Orçamento em Aberto")
	oBrowse:AddLegend("!EMPTY(TFJ->TFJ_CONTRT) .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_INATIVO + "' .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_REVISADO + "'","BR_VERMELHO","Contrato Gerado")
	oBrowse:AddLegend("!EMPTY(TFJ->TFJ_CONTRT) .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_INATIVO + "' .AND. TFJ->TFJ_STATUS == '" + DEF_TFJ_REVISADO + "'","BR_BRANCO","Contrato Revisado")
	oBrowse:AddLegend("TFJ->TFJ_STATUS == '" + DEF_TFJ_INATIVO + "'","BR_CANCEL","Orçamento Inativo")

    oBrowse:SetFilterDefault(cFiltro)

    oBrowse:Activate()

Return Nil


/*/{Protheus.doc} Menudef
    (long_description)
    @type Static Function
    @author Anderson F. Gomes
    @since 13/03/2025
    @version 12.1.2310
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
/*/
Static Function Menudef() As Array
    Local aRotina As Array

    aRotina := {}
    ADD OPTION aRotina TITLE "Pesquisar"  ACTION 'PesqBrw'         OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.TECA746' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.TECA746' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.TECA746' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.TECA746' OPERATION 5 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
    Definição do modelo
    @type Static Function
    @author Anderson F. Gomes
    @since 13/03/2025
    @version 12.1.2310
    @return oModel, Object, Objeto do Modelo
/*/
Static Function ModelDef() As Object
    Local oModel As Object
    Local oStrTFJ As Object
    Local oStrTFL As Object
    Local oStrTFF As Object
    Local oStrTFG As Object
    Local oStrTFH As Object
    Local oStrTFI As Object
    Local oStrTFU As Object
    Local oStrABP As Object
    Local oStrTEV As Object
    Local oStrTXQ As Object
    Local oStrTXP As Object
    Local oStrABZ As Object
    Local oStrTGV As Object
    Local oStrTDS As Object
    Local oStrTDT As Object
    Local oStrTWO As Object
    Local oEvent  As Object

    oStrTFJ := FWFormStruct( 1, "TFJ" )
    oStrTFL := FWFormStruct( 1, "TFL" )
    oStrTFF := FWFormStruct( 1, "TFF" )
    oStrTFG := FWFormStruct( 1, "TFG" )
    oStrTFH := FWFormStruct( 1, "TFH" )
    oStrTFI := FWFormStruct( 1, "TFI" )
    oStrTFU := FWFormStruct( 1, "TFU" )
    oStrABP := FWFormStruct( 1, "ABP" )
    oStrABZ := FWFormStruct( 1, "ABZ" )
    oStrTEV := FWFormStruct( 1, "TEV" )
    oStrTXP := FWFormStruct( 1, "TXP" )
    oStrTXQ := FWFormStruct( 1, "TXQ" )
    oStrTGV := FWFormStruct( 1, "TGV" )
    oStrTDS := FWFormStruct( 1, "TDS" )
    oStrTDT := FWFormStruct( 1, "TDT" )
    oStrTWO := FwFormStruct( 1, "TWO" )

    // Campos de Agrupamento dos itens de Orçamento
    If oStrTFJ:HasField( "TFJ_GRPRH" )
        oStrTFJ:RemoveField( "TFJ_GRPRH" )
    EndIf
    If oStrTFJ:HasField( "TFJ_GRPMI" )
        oStrTFJ:RemoveField( "TFJ_GRPMI" )
    EndIf
    If oStrTFJ:HasField( "TFJ_GRPMC" )
        oStrTFJ:RemoveField( "TFJ_GRPMC" )
    EndIf
    If oStrTFJ:HasField( "TFJ_GRPLE" )
        oStrTFJ:RemoveField( "TFJ_GRPLE" )
    EndIf
    If oStrTFJ:HasField( "TFJ_TES" )
        oStrTFJ:RemoveField( "TFJ_TES" )
    EndIf
    If oStrTFJ:HasField( "TFJ_TESMI" )
        oStrTFJ:RemoveField( "TFJ_TESMI" )
    EndIf
    If oStrTFJ:HasField( "TFJ_TESMC" )
        oStrTFJ:RemoveField( "TFJ_TESMC" )
    EndIf
    If oStrTFJ:HasField( "TFJ_TESLE" )
        oStrTFJ:RemoveField( "TFJ_TESLE" )
    EndIf
    If oStrTFJ:HasField( "TFJ_DSCRH" )
        oStrTFJ:RemoveField( "TFJ_DSCRH" )
    EndIf
    If oStrTFJ:HasField( "TFJ_DSCMI" )
        oStrTFJ:RemoveField( "TFJ_DSCMI" )
    EndIf
    If oStrTFJ:HasField( "TFJ_DSCMC" )
        oStrTFJ:RemoveField( "TFJ_DSCMC" )
    EndIf
    If oStrTFJ:HasField( "TFJ_DSCLE" )
        oStrTFJ:RemoveField( "TFJ_DSCLE" )
    EndIf

    oStrTFJ:SetProperty( "TFJ_DTPLRV", MODEL_FIELD_OBRIGAT, .F. )

    oStrTFF:AddField(	"" , ;						// [01] C Titulo do campo
                        "" , ;						// [02] C ToolTip do campo
                        "TFF_LEGEND" , ;			// [03] C identificador (ID) do Field
                        "C" , ;						// [04] C Tipo do campo
                        50 , ;						// [05] N Tamanho do campo
                        0 , ;						// [06] N Decimal do campo
                        NIL , ;						// [07] B Code-block de validação do campo
                        NIL , ;						// [08] B Code-block de validação When do campo
                        NIL , ;						// [09] A Lista de valores permitido do campo
                        NIL , ;						// [10] L Indica se o campo tem preenchimento obrigatório
                        {|| "BR_BRANCO"} , ;		// [11] B Code-block de inicializacao do campo
                        NIL , ;						// [12] L Indica se trata de um campo chave
                        NIL , ;						// [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )						// [14] L Indica se o campo é virtual

    // Definir propriedades dos campos obrigatórios
    oStrTFL:SetProperty( "TFL_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
    oStrTFF:SetProperty( "TFF_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
    oStrTFF:SetProperty( "TFF_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
    oStrTFG:SetProperty( "TFG_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
    oStrTFG:SetProperty( "TFG_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )
    oStrTFH:SetProperty( "TFH_CODPAI", MODEL_FIELD_OBRIGAT, .F. )
    oStrTFH:SetProperty( "TFH_LOCAL" , MODEL_FIELD_OBRIGAT, .F. )

    // Definir propriedades dos campos Codigo/Loja Cliente para orçamento simplificado
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_OBRIGAT, .T. )
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_OBRIGAT, .T. )
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_TITULO , "Cliente" )
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_TITULO , "Loja" )
	oStrTFJ:SetProperty( "TFJ_CODENT", MODEL_FIELD_NOUPD , .F. )
	oStrTFJ:SetProperty( "TFJ_LOJA",   MODEL_FIELD_NOUPD , .F. )

    // Definir o modelo
    oModel := MPFormModel():New( "TECA740", , Nil, Nil, Nil )

    oEvent := AT740EVDEF():New()
    oModel:InstallEvent("AT740EVDEF", /*cOwner*/, oEvent)

    oModel:SetDescription( "Orçamento para Serviços" )

    oModel:addFields( "TFJ_REFER", , oStrTFJ )
    oModel:SetPrimaryKey( { "TFJ_FILIAL", "TFJ_CODIGO" } )

    oModel:addGrid( "TFL_LOC", "TFJ_REFER", oStrTFL, Nil, , Nil, Nil, Nil )
    oModel:SetRelation( "TFL_LOC", { { "TFL_FILIAL", "xFilial('TFJ')" }, { "TFL_CODPAI", "TFJ_CODIGO" } }, TFL->(IndexKey(1)) )

    oModel:addGrid( "TFF_RH", "TFL_LOC", oStrTFF, Nil, Nil, Nil, Nil, Nil )
    oModel:SetRelation( "TFF_RH", { { "TFF_FILIAL", "xFilial('TFF')" }, { "TFF_CODPAI", "TFL_CODIGO" }, { "TFF_LOCAL", "TFL_LOCAL" } }, TFF->(IndexKey(1)) )

    oModel:addGrid( "ABP_BENEF", "TFF_RH", oStrABP, Nil )
    oModel:SetRelation( "ABP_BENEF", { { "ABP_FILIAL", "xFilial('ABP')" }, { "ABP_ITRH", "TFF_COD" } }, ABP->( IndexKey(1) ) )
    oModel:GetModel( "ABP_BENEF" ):SetUniqueLine( { "ABP_BENEFI" } )

    oModel:addGrid( "TFG_MI", "TFF_RH", oStrTFG, Nil, Nil, Nil, Nil, Nil )
    oModel:SetRelation( "TFG_MI", { { "TFG_FILIAL", "xFilial('TFG')" }, { "TFG_CODPAI", "TFF_COD" } }, TFG->( IndexKey(1) ) )

    oModel:addGrid( "TFH_MC", "TFF_RH", oStrTFH, Nil, Nil, Nil, Nil, Nil )
    oModel:SetRelation( "TFH_MC", { { "TFH_FILIAL", "xFilial('TFH')" }, { "TFH_CODPAI", "TFF_COD" } }, TFH->( IndexKey(1) ) )

    oModel:addGrid( "TFU_HE", "TFF_RH", oStrTFU, Nil, Nil )
    oModel:SetRelation( "TFU_HE", { { "TFU_FILIAL", "xFilial('TFU')" }, { "TFU_CODTFF", "TFF_COD" } }, TFU->( IndexKey(1) ) )

    oModel:addGrid( "TFI_LE", "TFL_LOC", oStrTFI, Nil, Nil, Nil,Nil, Nil )
    oModel:SetRelation( "TFI_LE", { { "TFI_FILIAL", "xFilial('TFI')" }, { "TFI_CODPAI", "TFL_CODIGO" }, { "TFI_LOCAL", "TFL_LOCAL" } }, TFI->( IndexKey(1) ) )

    oModel:addGrid( "TEV_ADICIO", "TFI_LE", oStrTEV, Nil )
    oModel:SetRelation( "TEV_ADICIO", { { "TEV_FILIAL", "xFilial('TEV')" }, { "TEV_CODLOC", "TFI_COD" } }, TEV->( IndexKey(1) ) )
    oModel:GetModel( "TEV_ADICIO" ):SetUniqueLine( { "TEV_MODCOB" } )

    oModel:AddGrid( "TGV_RH", "TFF_RH", oStrTGV, Nil, Nil, Nil, Nil, Nil )
    oModel:SetRelation( "TGV_RH", { { "TGV_FILIAL", "xFilial('TGV')" }, { "TGV_CODTFF", "TFF_COD" } }, TGV->( IndexKey(1) ) )
    oModel:GetModel( "TGV_RH" ):SetUniqueLine( { "TGV_CODTFF","TGV_CURSO" } )

    oModel:AddGrid( "TDS_RH", "TFF_RH", oStrTDS, Nil, Nil, Nil, Nil, Nil )
    oModel:SetRelation( "TDS_RH", { { "TDS_FILIAL", "xFilial('TDS')" }, { "TDS_CODTFF", "TFF_COD" } }, TDS->( IndexKey(1) ) )
    oModel:GetModel( "TDS_RH" ):SetUniqueLine( { "TDS_CODTFF","TDS_CODTCZ" } )

    oModel:AddGrid( "TDT_RH", "TFF_RH", oStrTDT, Nil, Nil, Nil, Nil, Nil )
    oModel:SetRelation( "TDT_RH", { { "TDT_FILIAL", "xFilial('TDT')" }, { "TDT_CODTFF", "TFF_COD" } }, TDT->( IndexKey(1) ) )

	oModel:AddGrid( "TWODETAIL", "TFF_RH", oStrTWO, Nil, Nil, Nil, Nil, Nil )
	oModel:SetRelation( "TWODETAIL", { { "TWO_FILIAL", "xFilial('TWO')" }, {"TWO_CODRH","TFF_COD"} }, TWO->( IndexKey(4) ) )

	oModel:addGrid( "TXPDETAIL", "TFF_RH", oStrTXP, Nil, Nil, Nil, Nil, Nil )
	oModel:SetRelation( "TXPDETAIL", { { "TXP_FILIAL", "xFilial('TXP')" }, { "TXP_CODTFF", "TFF_COD" } }, TXP->( IndexKey(2) ) )

	oModel:addGrid( "TXQDETAIL", "TFF_RH", oStrTXQ, Nil, Nil, Nil, Nil, Nil )
	oModel:SetRelation("TXQDETAIL", { { "TXQ_FILIAL", "xFilial('TXQ')" }, { "TXQ_CODTFF", "TFF_COD" } }, TXQ->( IndexKey(2) ) )

	oModel:addGrid( "ABZDETAIL", "TFF_RH", oStrABZ, Nil, Nil, Nil, Nil, Nil)
	oModel:SetRelation( "ABZDETAIL", { { "ABZ_FILIAL", "xFilial('ABZ')" }, { "ABZ_CODTFF", "TFF_COD" } }, ABZ->( IndexKey(1) ) )

    // Definir as descrições das views e grids
    oModel:getModel( "TFJ_REFER" ):SetDescription( "Ref. Proposta" )
    oModel:getModel( "TFL_LOC" ):SetDescription( "Locais" )
    oModel:getModel( "TFF_RH" ):SetDescription( "Recursos Humanos" )
    oModel:getModel( "TFG_MI" ):SetDescription( "Materiais de Implantação" )
    oModel:getModel( "TFH_MC" ):SetDescription( "Material de Consumo" )
    oModel:getModel( "TFU_HE" ):SetDescription( "Hora Extra" )
    oModel:getModel( "TFI_LE" ):SetDescription( "Locação de Equipamentos" )
    oModel:getModel( "ABP_BENEF" ):SetDescription( "Beneficios" )
    oModel:getModel( "TEV_ADICIO" ):SetDescription( "Cobrança da Locação" )
    oModel:getModel( "TGV_RH" ):SetDescription( "Cursos" )
    oModel:getModel( "TDS_RH" ):SetDescription( "Habilidades" )
    oModel:getModel( "TDT_RH" ):SetDescription( "Caracteristicas" )
    oModel:getModel( "TWODETAIL" ):SetDescription( "Facilitador")

    // Definir as grids como opcionais
    oModel:getModel( "TEV_ADICIO" ):SetOptional( .T. )
    oModel:getModel( "TFI_LE" ):SetOptional( .T. )
    oModel:getModel( "TFH_MC" ):SetOptional( .T. )
    oModel:getModel( "TFG_MI" ):SetOptional( .T. )
    oModel:getModel( "TFU_HE" ):SetOptional( .T. )
    oModel:getModel( "ABP_BENEF" ):SetOptional( .T. )
    oModel:getModel( "TFF_RH" ):SetOptional( .T. )
    oModel:getModel( "TGV_RH" ):SetOptional( .T. )
    oModel:getModel( "TDS_RH" ):SetOptional( .T. )
    oModel:getModel( "TDT_RH" ):SetOptional( .T. )
    oModel:getModel( "TWODETAIL" ):SetOptional( .T. )


	oModel:getModel( "TXPDETAIL" ):SetDescription( "Uniforme" )
	oModel:getModel( "TXPDETAIL" ):SetOptional( .T. )

	oModel:getModel( "TXQDETAIL" ):SetDescription( "Armamento" )
	oModel:getModel( "TXQDETAIL" ):SetOptional( .T. )

	oModel:getModel( "ABZDETAIL" ):SetDescription( "Verbas CCT" )
	oModel:getModel( "ABZDETAIL" ):SetOptional( .T. )
	oModel:getModel( "ABZDETAIL" ):SetNoInserLine( .T. )
	oModel:getModel( "ABZDETAIL" ):SetNoUpdateLine( .T. )
	oModel:getModel( "ABZDETAIL" ):SetNoDeleteLine( .T. )

    // Bloco de código executado no activate
    oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel


/*/{Protheus.doc} ViewDef
    Definição da interface
    @type Static Function
    @author Anderson F. Gomes
    @since 13/03/2025
    @version 12.1.2310
    @return oView, Object, Objeto da Interface
/*/
Static Function ViewDef() As Object
    Local oView As Object
    Local oModel As Object
    Local oStrTFJ As Object
    Local oStrTFL As Object
    Local oStrTFF As Object
    Local oStrABP As Object
    Local oStrTFG As Object
    Local oStrTFH As Object
    Local oStrTFI As Object
    Local oStrTFU As Object
    Local oStrTEV As Object
    Local oStrTWO As Object
    Local oStrTXP As Object
    Local oStrTXQ As Object
    Local oStrABZ As Object

    oView := Nil
    oModel := ModelDef()

    oStrTFJ := FWFormStruct( 2, "TFJ", { |cCpo| At746SelFields( "TFJ", AllTrim( cCpo ) ) } )
    oStrTFL := FWFormStruct( 2, "TFL", { |cCpo| At746SelFields( "TFL", AllTrim( cCpo ) ) } )
    oStrTFF := FWFormStruct( 2, "TFF", { |cCpo| At746SelFields( "TFF", AllTrim( cCpo ) ) } )
    oStrABP := FWFormStruct( 2, "ABP", { |cCpo| At746SelFields( "ABP", AllTrim( cCpo ) ) } )
    oStrTFG := FWFormStruct( 2, "TFG", { |cCpo| At746SelFields( "TFG", AllTrim( cCpo ) ) } )
    oStrTFH := FWFormStruct( 2, "TFH", { |cCpo| At746SelFields( "TFH", AllTrim( cCpo ) ) } )
    oStrTFI := FWFormStruct( 2, "TFI", { |cCpo| At746SelFields( "TFI", AllTrim( cCpo ) ) } )
    oStrTFU := FWFormStruct( 2, "TFU", { |cCpo| At746SelFields( "TFU", AllTrim( cCpo ) ) } )
    oStrTEV := FWFormStruct( 2, "TEV", { |cCpo| At746SelFields( "TEV", AllTrim( cCpo ) ) } )
    oStrTWO := FwFormStruct( 2, "TWO", { |cCpo| At746SelFields( "TWO", AllTrim( cCpo ) ) } )
	oStrTXP := FwFormStruct( 2, "TXP", { |cCpo| At746SelFields( "TXP", AllTrim( cCpo ) ) } )
	oStrTXQ := FwFormStruct( 2, "TXQ", { |cCpo| At746SelFields( "TXQ", AllTrim( cCpo ) ) } )
	oStrABZ := FwFormStruct( 2, "ABZ", { |cCpo| At746SelFields( "ABZ", AllTrim( cCpo ) ) } )

    oStrTFF:AddField(	"TFF_LEGEND",;		// [01]  C   Nome do Campo
                        "00",;				// [02]  C   Ordem
                        "",;				// [03]  C   Titulo do campo
                        "Legenda",;			// [04]  C   Descricao do campo	// "Legenda"
                        {"Legenda"},;		// [05]  A   Array com Help // "Legenda"
                        "C",;				// [06]  C   Tipo do campo
                        "@BMP",;			// [07]  C   Picture
                        NIL,;				// [08]  B   Bloco de Picture Var
                        "",;				// [09]  C   Consulta F3
                        .F.,;				// [10]  L   Indica se o campo é alteravel
                        NIL,;				// [11]  C   Pasta do campo
                        NIL,;				// [12]  C   Agrupamento do campo
                        NIL,;				// [13]  A   Lista de valores permitido do campo (Combo)
                        NIL,;				// [14]  N   Tamanho maximo da maior opção do combo
                        NIL,;				// [15]  C   Inicializador de Browse
                        .T.,;				// [16]  L   Indica se o campo é virtual
                        NIL,;				// [17]  C   Picture Variavel
                        .F.)				// [18]  L   Indica pulo de linha após o campo

    // Definir propriedades dos campos Codigo/Loja Cliente para orçamento simplificado
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_LOOKUP     , 'SA1' )
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_CANCHANGE  , .T. )
	oStrTFJ:SetProperty( "TFJ_LOJA",   MVC_VIEW_CANCHANGE  , .T. )
	oStrTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_TITULO     , 'Cliente' )
	oStrTFJ:SetProperty( "TFJ_LOJA",   MVC_VIEW_TITULO     , 'Loja' )

    // Definir propriedades dos campos
    oStrTFJ:SetProperty('TFJ_GESMAT', MVC_VIEW_CANCHANGE, .F.)

    // Remover campos que não serão utilizados na View (Interface)
    oStrTFJ:RemoveField("TFJ_LUCRO")
	oStrTFJ:RemoveField("TFJ_DESCON")
	oStrTFJ:RemoveField("TFJ_ADM")
	oStrTFJ:RemoveField("TFJ_CLIPED")
	oStrTFJ:RemoveField("TFJ_DTPLRV")
	oStrTFJ:RemoveField("TFJ_CODREL")
	oStrTFJ:RemoveField("TFJ_PRDRET")
	oStrTFJ:RemoveField("TFJ_APRVOP")
	oStrTFJ:RemoveField("TFJ_USAPRO")
	oStrTFJ:RemoveField("TFJ_DTAPRO")
    oStrTFJ:RemoveField("TFJ_OBSREJ")
    // Local de Atendimento
	oStrTFL:RemoveField("TFL_MODPLA")
	oStrTFL:RemoveField("TFL_CODREL")
	oStrTFL:RemoveField("TFL_ATCC")
    // Local de Atendimento: Campos Totais

    oStrTFL:RemoveField("TFL_TOTAL")
    oStrTFL:RemoveField("TFL_TOTRH")
    oStrTFL:RemoveField("TFL_TOTLE")
    oStrTFL:RemoveField("TFL_TOTMI")
    oStrTFL:RemoveField("TFL_TOTMC")
    oStrTFL:RemoveField("TFL_TOTUNI")
    oStrTFL:RemoveField("TFL_TOTARM")
    oStrTFL:RemoveField("TFL_TOTIMP")
    oStrTFL:RemoveField("TFL_GERPLA")

    // Recursos Humanos: Campos Totais
    oStrTFL:RemoveField("TFF_TOTMES")
    oStrTFL:RemoveField("TFF_TOTMC")
    oStrTFL:RemoveField("TFF_TOTMI")
    oStrTFL:RemoveField("TFF_TOTUNI")
    oStrTFL:RemoveField("TFF_TOTARM")
    oStrTFL:RemoveField("TFF_TOTPLA")
    oStrTFL:RemoveField("TFF_GERPLA")

    // Instanciar a View
    oView := FWFormView():New()
    oView:SetModel( oModel )

    oView:AddField( "VIEW_REFER", oStrTFJ, "TFJ_REFER" )
    oView:AddGrid( "VIEW_LOC",    oStrTFL, "TFL_LOC" )
    oView:AddGrid( "VIEW_RH",     oStrTFF, "TFF_RH" )
    oView:AddGrid( "VIEW_MI",     oStrTFG, "TFG_MI" )
    oView:AddGrid( "VIEW_MC",     oStrTFH, "TFH_MC" )
    oView:AddGrid( "VIEW_BENEF",  oStrABP, "ABP_BENEF" )
    oView:AddGrid( "VIEW_HE",     oStrTFU, "TFU_HE" )
    oView:AddGrid( "VIEW_LE",     oStrTFI, "TFI_LE" )
    oView:AddGrid( "VIEW_ADICIO", oStrTEV, "TEV_ADICIO" )

    oView:AddGrid( "VIEW_UNIF", oStrTXP, "TXPDETAIL" )
    oView:AddGrid( "VIEW_ARMA", oStrTXQ, "TXQDETAIL" )

    oView:CreateHorizontalBox( "TOP", 30 )
    oView:CreateHorizontalBox( "MIDDLE", 70 )

    oView:CreateFolder( "ABAS", "MIDDLE" )
    oView:AddSheet( "ABAS", "ABA01", "Locais de Atendimento" )
    oView:AddSheet( "ABAS", "ABA02", "Recursos Humanos" )
    oView:AddSheet( "ABAS", "ABA03", "Locação de Equipamentos" )

    oView:CreateHorizontalBox( "ID_ABA01" , 100,,, "ABAS", "ABA01" ) // Define a área de Locais
    oView:CreateHorizontalBox( "ID_ABA02" , 060,,, "ABAS", "ABA02" ) // Define a área de RH
    oView:CreateHorizontalBox( "ID_ABA02A", 040,,, "ABAS", "ABA02" ) // área dos acionais relacionados com RH
    oView:CreateHorizontalBox( "ID_RH_02" , 100,,, "RH_ABAS", "RH_MATIMP" ) // Define a área de Materiais de Implantação
    oView:CreateHorizontalBox( "ID_RH_03" , 100,,, "RH_ABAS", "RH_MATCON" ) // Define a área de Materiais de Consumo
	oView:CreateHorizontalBox( "ID_RH_06" , 100,,, "RH_ABAS", "RH_UNIFOR" ) // Define a área da Uniforme
	oView:CreateHorizontalBox( "ID_RH_07" , 100,,, "RH_ABAS", "RH_ARMAME" ) // Define a área da Armamento
    oView:CreateHorizontalBox( "ID_RH_04" , 100,,, "RH_ABAS", "RH_HORAEX" ) // Define a área da Hora Extra
    oView:CreateHorizontalBox( "ID_RH_01" , 100,,, "RH_ABAS", "RH_GRATIF" ) // Define a área de Gratificação de Posto de item de Rh
    oView:CreateHorizontalBox( "ID_ABA03" , 060,,, "ABAS", "ABA03" ) // Define a área de Locação de Equipamentos
    oView:CreateHorizontalBox( "ID_ABA03A", 040,,, "ABAS", "ABA03" )

    oView:CreateFolder( "RH_ABAS", "ID_ABA02A" )
    oView:AddSheet( "RH_ABAS", "RH_MATIMP", "Materiais de Implantação" )
    oView:AddSheet( "RH_ABAS", "RH_MATCON", "Materiais de Consumo" )
	oView:AddSheet( "RH_ABAS", "RH_UNIFOR", "Uniforme" )
	oView:AddSheet( "RH_ABAS", "RH_ARMAME", "Armamento" )
    oView:AddSheet( "RH_ABAS", "RH_HORAEX" ,"Hora Extra" )
    oView:AddSheet( "RH_ABAS", "RH_GRATIF", "Gratificação de Posto" )

    oView:EnableTitleView( "VIEW_ADICIO", "Cobrança da Locação" )
    oView:AddIncrementField( "VIEW_BENEF", "ABP_ITEM" )
    oView:AddIncrementField( "VIEW_ADICIO", "TEV_ITEM" )
    oView:AddIncrementField( "VIEW_LE", "TFI_ITEM" )

    // Relacionar as views com box visual
    oView:SetOwnerView( "VIEW_REFER",  "TOP" ) // Cabeçalho
    oView:SetOwnerView( "VIEW_LOC",    "ID_ABA01" ) // Grid Locais
    oView:SetOwnerView( "VIEW_RH",     "ID_ABA02" ) // Grid RH
    oView:SetOwnerView( "VIEW_MI",     "ID_RH_02" ) // Grid Materiais de Implantação
    oView:SetOwnerView( "VIEW_MC",     "ID_RH_03" ) // Grid Materiais de Consumo
	oView:SetOwnerView( "VIEW_UNIF",   "ID_RH_06" ) // Grid Uniforme
	oView:SetOwnerView( "VIEW_ARMA",   "ID_RH_07" ) // Grid Armamento
    oView:SetOwnerView( "VIEW_HE",     "ID_RH_04" ) // Grid Hora Extra
    oView:SetOwnerView( "VIEW_BENEF",  "ID_RH_01" )  // Grid Gratificação de Posto
    oView:SetOwnerView( "VIEW_LE",     "ID_ABA03" )  // Grid Locação de Equipamentos
    oView:SetOwnerView( "VIEW_ADICIO", "ID_ABA03A" )

    oView:AddIncrementField( "VIEW_MC", "TFH_ITEM" )
    oView:AddIncrementField( "VIEW_MI", "TFG_ITEM" )
    oView:AddIncrementField( "VIEW_RH", "TFF_ITEM" )

Return oView


/*/{Protheus.doc} InitDados
    Bloco de código executado no activate
    @type Static Function
    @author flavio.vicco
    @since 15/08/2025
    @version 12.1.2410
    @param oMdlGer, Object, Objeto do Modelo
    @return nulo
/*/
Static Function InitDados(oMdlGer)

Local oMdlTFJ := oMdlGer:GetModel("TFJ_REFER")

At746Set(oMdlTFJ, "TFJ_ENTIDA", "1" )

Return

/*/{Protheus.doc} At746Set
    Carga de conteudo padrão para os campos da View
    @type Static Function
    flavio.vicco
    @since 15/08/2025
    @version 12.1.2410
    @param oView, Object, Objeto da Interface
    @param cField, Character, Nome do campo a ser setado
    @param xValue, Variant, Valor a ser setado no campo
    @param lAlwaysLoad, Logical, .T. se deve carregar o valor do campo
    @return lRet, Logical, .T. se o valor foi setado com sucesso / .F. se não foi possível setar o valor
/*/
Function At746Set(oModel, cField, xValue, lAlwaysLoad)

Local lRet := .T.
Default lAlwaysLoad := .F.

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
    If oModel:GetOperation() == MODEL_OPERATION_VIEW .Or. lAlwaysLoad
        oModel:LoadValue( cField, xValue )
    Else
        lRet := oModel:SetValue( cField, xValue )
    EndIf
EndIf
Return lRet

/*/{Protheus.doc} At746SelFields
    Filtra os campos de controle da rotina para nao serem exibidos na View
    @type Static Function
    @author Anderson F. Gomes
    @since 13/03/2025
    @version 12.1.2310
    @param cTab, Character, Alias da tabela da estrutura
    @param cCpoAval, Character, Nome do Campo a ser avaliado
    @return lRet, Logical, .T. Campo incluído na estrutura / .F. Campo excluido da estrutura
/*/
Static Function At746SelFields( cTab, cCpoAval ) As Logical
    Local lRet As Logical

    lRet := .T.

    If !Empty( cTab ) .And. !Empty( cCpoAval )
        If cTab == "TFJ"
            lRet := !( cCpoAval $ "TFJ_PROPOS#TFJ_PREVIS#TFJ_ENTIDA#TFJ_ITEMRH#TFJ_ITEMMI#TFJ_DESCON#TFJ_DSGCN#TFJ_ORCSIM" )
            lRet := lRet .And. !( cCpoAval $ "TFJ_ITEMMC#TFJ_ITEMLE#TFJ_CONTRT#TFJ_CONREV#TFJ_STATUS#TFJ_TOTRH#TFJ_TOTMI#TFJ_TOTMC#TFJ_TOTLE#TFJ_CODVIS#TFJ_TABXML#TFJ_TOTUNI#TFJ_TOTARM#TFJ_GERPLA" )
            lRet := lRet .And. !( cCpoAval $ "TFJ_TOTCUS#TFJ_TOTGER#TFJ_GRPRH#TFJ_DSCRH#TFJ_TES#TFJ_GRPMI#TFJ_DSCMI#TFJ_TESMI##TFJ_GRPMC#TFJ_DSCMC#TFJ_TESMC#TFJ_TESM#TFJ_GRPLE#TFJ_DSCLE#TFJ_TESLE" )
            lRet := lRet .And. !( cCpoAval $ "TFJ_CODTAB#TFJ_TABREV#TFJ_TREINA#TFJ_RESTEC")
        ElseIf cTab == "TFL"
            lRet := !( cCpoAval $ "TFL_CODIGO#TFL_CODPAI#TFL_CONTRT#TFL_CONREV#TFL_CODSUB" )
            lRet := lRet .And. !( cCpoAval $ "TFL_ITPLRH#TFL_ITPLMI#TFL_ITPLMC#TFL_ITPLLE#TFL_ENCE" )
            lRet := lRet .And. !( cCpoAval $ "TFL_MESRH#TFL_MESMI#TFL_MESMC" )
        ElseIf cTab == "TFF"
            lRet := !( (cCpoAval +"#") $ "TFF_LOCAL#TFF_CODPAI#TFF_CONTRT#TFF_CONREV#TFF_CODSUB#TFF_CHVTWO#TFF_ENCE#TFF_PROCES#TFF_ITCNB#TFF_TABXML#TFF_ITEXOP#" )
            lRet := lRet .And. !( cCpoAval $ "TFF_TOTMI#TFF_TOTMC#TFF_TOTUNI" )
            lRet := lRet .And. !( cCpoAval $ "TFF_TOTMES#TFF_CODLIM" )
        ElseIf cTab == "TFI"
            lRet := !( cCpoAval $ "TFI_COD#TFI_LOCAL#TFI_OK#TFI_SEPARA#TFI_CODPAI#TFI_CONTRT#TFI_CONREV#TFI_CODSUB#TFI_CHVTWO#TFI_ITCNB" )
            lRet := lRet .And. !( cCpoAval $ "TFI_CODTGQ#TFI_ITTGR#TFI_CODATD#TFI_NOMATD#TFI_CONENT#TFI_CONCOL#TFI_ENCE#TFI_DTPFIM" )
        ElseIf cTab == "ABP"
            lRet := !( cCpoAval $ "ABP_COD#ABP_REVISA#ABP_CODPRO#ABP_ENTIDA#ABP_ITRH#ABP_ITEMPR#ABP_CODTWO#ABP_CHVTWO" )
        ElseIf cTab == "TFG"
            lRet := !( cCpoAval $ "TFG_COD#TFG_LOCAL#TFG_CODPAI#TFG_SLD#TFG_CODSUB#TFG_CHVTWO#TFG_ITCNB#TFG_CONTRT#TFG_CONREV" )
        ElseIf cTab == "TFH"
            lRet := !( cCpoAval $ "TFH_COD#TFH_LOCAL#TFH_CODPAI#TFH_SLD#TFH_CODSUB#TFH_CHVTWO#TFH_ITCNB#TFH_CONTRT#TFH_CONREV" )
        ElseIf cTab == "TFU"
            lRet := !( cCpoAval $ "TFU_CODIGO#TFU_CODTFF#TFU_LOCAL" )
        ElseIf cTab == "TEV"
            lRet := !( cCpoAval $ "TEV_CODLOC#TEV_SLD" )
        ElseIf cTab == "TWO"
            lRet := !( cCpoAval $ "TWO_CODORC#TWO_PROPOS#TWO_OPORTU#TWO_LOCAL#TWO_CODIGO" )
        ElseIf cTab == "TXP"
            lRet := !( cCpoAval $ "TXP_CONTRT#TXP_CONREV#TXP_CODSUB#TXP_CODTFF" )
        ElseIf cTab == "TXQ"
            lRet := !( cCpoAval $ "TXQ_CONTRT#TXQ_CONREV#TXQ_CODSUB#TXQ_CODTFF" )
        ElseIf cTab == "ABZ"
            lRet := !( cCpoAval $ "ABZ_CODTFF#ABZ_FILSRV#ABZ_FILCCT#ABZ_CCTCOD" )
        EndIf
    EndIf

Return lRet


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT740EVDEF
@description Classe interna implementando o FWModelEvent, para interceptacao do commit e validacao
/*/
//--------------------------------------------------------------------------------------------------------------------
Class AT740EVDEF FROM FWModelEvent
	Method New()
	Method BeforeTTS() //quando ocorrer as ações do commit antes  da transação.
End Class

//---------------------------------------------------------
Method New() Class AT740EVDEF
Return

//---------------------------------------------------------
Method BeforeTTS(oModel, cModelId) Class AT740EVDEF
Return
