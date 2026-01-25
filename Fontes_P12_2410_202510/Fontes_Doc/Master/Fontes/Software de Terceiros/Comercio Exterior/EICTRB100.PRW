#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'eictrb100.ch'

#define POS_CAMPO   1
#define POS_TIPO    2
#define POS_TAMANHO 3
#define POS_DECIMAL 4
#define POS_TITULO  5
#define POS_DESCRI  6
#define POS_PICTURE 7
#define POS_CBOX    8

#define TRB100_SB1  "TRB100_SB1"
#define ALIAS_TEMP  1
#define ARQ_TAB     2
#define INDEX1      3
#define INDEX2      4

static _aStrSWZ   := nil
static _aRegTrib  := {}
static _aTabsTmp  := {}

/*/{Protheus.doc} EICTRB100
    Função responsável pelo cadastro de Regime de Tributação 
    Chamada no Menu do módulo SIGAEIC

    @type  Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param 
    @return nulo
    @example
    @see
/*/
function EICTRB100()
    local oBrowse    := nil
    local aAreaSWZ   := {}
    local aAreaSB1   := {}
    local aAreaSYD   := {}

    dbSelectArea("SWZ")
    aAreaSWZ := SWZ->(getArea())

    dbSelectArea("SB1")
    aAreaSB1 := SB1->(getArea())

    dbSelectArea("SYD")
    aAreaSYD := SYD->(getArea())

    _aStrSWZ := {}
    aSize( _aStrSWZ, 0 )

    createTmp()

    oBrowse := FWmBrowse():New()
    oBrowse:SetDescription(STR0001) // "Regime de Tributação"
    oBrowse:SetAlias("EKR")
    oBrowse:SetMenuDef("EICTRB100")
    oBrowse:Activate()

    restArea(aAreaSWZ)
    restArea(aAreaSB1)
    restArea(aAreaSYD)

    eraseTmp()

return

/*/{Protheus.doc} MenuDef
    Opções do Menu

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param 
    @return aRotina, array, opções do Menu
    @example
    (examples)
    @see (links_or_references)
/*/
static function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina Title STR0002 Action 'AxPesqui'          OPERATION 1 ACCESS 0 // "Pesquisar"
    ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.EICTRB100' OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.EICTRB100' OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.EICTRB100' OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.EICTRB100' OPERATION 5 ACCESS 0 // "Excluir"
    ADD OPTION aRotina Title STR0007 ACTION 'VIEWDEF.EICTRB100' OPERATION 9 ACCESS 0 // "Copiar"

return aRotina

/*/{Protheus.doc} ModelDef
    ModelDef

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param 
    @return oModel, Objeto, Objeto da classe MPFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
static function ModelDef()
    local oModel   := nil 
    local oStruEKR := FWFormStruct( 1, "EKR")
    local oStruEKS := FWFormStruct( 1, "EKS")

    // retira pois o upddistr atualiza se o valor do novo dicionário NÃO estiver vazio.
    if avFlags("TRIBUTACAO_DUIMP")
        oStruEKR:SetProperty("EKR_REGIPI", MODEL_FIELD_VALUES , {})
    endif

    CpoSWZModel(@oStruEKR)
    oStruEKR:AddTrigger("EKR_OPERAC","EKR_OPERAC",, {|| TRB100GAT("EKR_OPERAC")} )  

    oModel := MPFormModel():New("EICTRB100", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields( "EKR_MASTER",/*nOwner*/,oStruEKR, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
    oModel:AddGrid("EKS_DETAIL", "EKR_MASTER", oStruEKS )

    oModel:GetModel("EKR_MASTER"):SetFldNoCopy({"EKR_CODREG", "EKR_DESCRI"})
    oModel:GetModel("EKR_MASTER"):SetDescription(STR0001) // "Regime de Tributação"

    oModel:GetModel("EKS_DETAIL"):SetUniqueLine( {"EKS_COD_I"} )
    oModel:GetModel("EKS_DETAIL"):SetOptional(.T.)
    oModel:GetModel("EKS_DETAIL"):SetDescription(STR0011) // "Produtos Associados"
    oModel:SetRelation('EKS_DETAIL', {;
        { "EKS_FILIAL"   ,"xFilial('EKS')"},;
        { "EKS_CODREG"   ,"EKR_CODREG"    };
        },; 
        EKS->(dbSetOrder(1)) ) // EKS_FILIAL+EKS_CODREG

return oModel

/*/{Protheus.doc} ViewDef
    ViewDef

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param 
    @return oModel, Objeto, Objeto da classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/
static function ViewDef()
    local oModel   := FWLoadModel("EICTRB100")
    local oStruEKR := FWFormStruct( 2, "EKR") 
    local oStruEKS := FWFormStruct( 2, "EKS") 
    local oView    := nil
 
    oView := FWFormView():New()
    oView:SetModel( oModel ) 
    oView:SetDescription(STR0001) // "Regime de Tributação"
    oView:CreateHorizontalBox("CAPA", 60)
    oView:CreateHorizontalBox("ITEM", 40)

    // retira pois o upddistr atualiza se o valor do novo dicionário NÃO estiver vazio.
    if avFlags("TRIBUTACAO_DUIMP")
        oStruEKR:SetProperty("EKR_REGIPI", MVC_VIEW_COMBOBOX , {})
    endif
    CpoSWZView(@oStruEKR)

    oView:AddField("VIEW_EKR", oStruEKR, "EKR_MASTER")
    oView:SetOwnerView("VIEW_EKR", "CAPA")

    oView:AddGrid( "VIEW_EKS", oStruEKS, "EKS_DETAIL" )
    oView:SetOwnerView("VIEW_EKS", "ITEM")
    oView:EnableTitleView("VIEW_EKS",STR0011) // "Produtos Associados"
    oView:addUserButton( STR0022, "", { |oView| AssocProd(oView)  }, STR0022,, {MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE}) //"Associar Produtos"

return oView

/*/{Protheus.doc} TRB100WHEN
    Função para tratamento do when dos campos

    @type  Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param 
    @return lRet, logico, .T. editável e .F. para não editável
    @example
    (examples)
    @see (links_or_references)
/*/
function TRB100WHEN(cCampo)
    local lRet       := .T.
    local oModel     := nil
    local oModelEKR  := nil
    local cRegInfo   := ""
    local cTipoAli   := ""
    local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

    default cCampo := ""

    do case

        case cCampo == "EKR_TPAII" .or. ( !lTribDUIMP .and. ( cCampo == "EKR_TPAIPI" .or. cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF" ))
            lRet := .F.

        case cCampo == "EKR_TPAIPI" .or. cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF" .or. cCampo == "EKR_TPADUM"
            lRet := .T.

        case cCampo == "EKR_ALI_II" .or. cCampo == "EKR_ALCOFM" .or. cCampo == "EKR_ALPISM"
            lRet := .T.

        case cCampo == "EKR_ALR_II"

            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")
            lRet := oModelEKR:getValue("EKR_REGTRI") == "4" // REDUCAO

        case cCampo == "EKR_ALRIPI"
            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")

            cRegInfo := oModelEKR:getValue("EKR_REGIPI")
            cTipoAli := oModelEKR:getValue("EKR_TPAIPI")

            lRet := cRegInfo == "4" .and. cTipoAli $ "1|3" // REDUCAO e Tipo de alíquota 1=Ad Valorem ou 3=Mista

        case cCampo == "EKR_REDPIS" .or. cCampo == "EKR_REDCOF"

            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")
            do case 
                case cCampo == "EKR_REDPIS"
                    cRegInfo := oModelEKR:getValue("EKR_REGPIS")
                    cTipoAli := oModelEKR:getValue("EKR_TPAPIS")
                case cCampo == "EKR_REDCOF"
                    cRegInfo := oModelEKR:getValue("EKR_REGCOF")
                    cTipoAli := oModelEKR:getValue("EKR_TPACOF")
            end case

            lRet := cRegInfo == "4" .and. cTipoAli == "1" // REDUCAO e Tipo de alíquota 1=Ad Valorem

        case cCampo == "EKR_ALUIPI" .or. cCampo == "EKR_ALEADU"

            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")
            do case 
                case cCampo == "EKR_ALUIPI"
                    cTipoAli := oModelEKR:getValue("EKR_TPAIPI")
                case cCampo == "EKR_ALEADU"
                    cTipoAli := oModelEKR:getValue("EKR_TPADUM")
            end case
 
            lRet := cTipoAli $ "2|3" // Tipo de alíquota 2=Específica ou 3=Mista

        case cCampo == "EKR_ALUPIS" .or. cCampo == "EKR_ALUCOF"

            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")
            do case 
                case cCampo == "EKR_ALUPIS"
                    cTipoAli := oModelEKR:getValue("EKR_TPAPIS")
                case cCampo == "EKR_ALUCOF"
                    cTipoAli := oModelEKR:getValue("EKR_TPACOF")
            end case
 
            lRet := cTipoAli == "2" // Tipo de alíquota 2=Específica

        case cCampo == "EKR_ALAIPI" .or. cCampo == "EKR_ALADDU"

            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")
            do case 
                case cCampo == "EKR_ALAIPI"
                    cTipoAli := oModelEKR:getValue("EKR_TPAIPI")
                case cCampo == "EKR_ALADDU"
                    cTipoAli := oModelEKR:getValue("EKR_TPADUM")
            end case
            lRet := cTipoAli $ "1|3" // Tipo de alíquota 1=Ad Valorem ou 3=Mista

        case cCampo == "EKR_ALAPIS" .or. cCampo == "EKR_ALACOF"

            oModel := FWModelActive()
            oModelEKR := oModel:GetModel("EKR_MASTER")
            do case 
                case cCampo == "EKR_ALAPIS"
                    cTipoAli := oModelEKR:getValue("EKR_TPAPIS")
                case cCampo == "EKR_ALACOF"
                    cTipoAli := oModelEKR:getValue("EKR_TPACOF")
            end case
            lRet := cTipoAli == "1" // Tipo de alíquota 1=Ad Valorem

    end case

return lRet

/*/{Protheus.doc} TRB100GAT
    Função para tratamento do gatilho dos campos

    @type  Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param 
    @return cRet, caracter, informação a ser disparada
    @example
    (examples)
    @see (links_or_references)
/*/
function TRB100GAT(cCampo, cOrdem)
    local oModel     := FWModelActive()
    local oModelEKR  := nil
    local oModelEKS  := nil
    local cRet       := ""
    local lSeekSWZ   := .F. 
    local aCposSWZ   := {}
    local nCpo       := 0
    local nTam       := 0
    local cCpoInfo   := ""
    local cRegInfo   := ""
    local cTipoAli   := ""
    local cCpoDesc   := ""

    default cCampo   := "EKR_OPERAC"
    default cOrdem   := ""

    if oModel <> nil

        do case

            case cCampo == "EKR_OPERAC"

                oModelEKR := oModel:GetModel("EKR_MASTER")
                cRet := oModelEKR:getValue("EKR_OPERAC")
                lSeekSWZ := .F.
                if !empty(cRet)
                    lSeekSWZ := PosSWZ(cRet)
                endif

                aCposSWZ := getStruct()
                for nCpo := 1 to len(aCposSWZ)
                    oModelEKR:LoadValue( aCposSWZ[nCpo][POS_CAMPO] , if( lSeekSWZ , SWZ->&(aCposSWZ[nCpo][POS_CAMPO]), RetInfo(aCposSWZ[nCpo][POS_CAMPO], aCposSWZ[nCpo][POS_TIPO], aCposSWZ[nCpo][POS_TAMANHO], aCposSWZ[nCpo][POS_DECIMAL]) ) )
                next nCpo

            case cCampo == "EKR_COD_I"

                oModelEKS := oModel:GetModel("EKS_DETAIL")
                cRet := oModelEKS:getValue("EKS_VINCUL")
                cRet := if( empty(oModelEKS:getValue("EKS_COD_I")) , "" , if( empty(cRet), "1", cRet))

            case ( cCampo == "EKR_FUNII" .or. cCampo == "EKR_FUNIPI" .or. cCampo == "EKR_FUNPIS" .or. cCampo == "EKR_FUNCOF" .or. cCampo == "EKR_FUNADU" ) .and. cOrdem == "1"

                do case
                    case cCampo == "EKR_FUNII"
                        nTam := getSx3Cache( "EKR_DSCFL1", "X3_TAMANHO")
                    case cCampo == "EKR_FUNIPI"
                        nTam := getSx3Cache( "EKR_DSCFL2", "X3_TAMANHO")
                    case cCampo == "EKR_FUNPIS"
                        nTam := getSx3Cache( "EKR_DSCFL3", "X3_TAMANHO")
                    case cCampo == "EKR_FUNCOF"
                        nTam := getSx3Cache( "EKR_DSCFL4", "X3_TAMANHO")
                    case cCampo == "EKR_FUNADU"
                        nTam := getSx3Cache( "EKR_DSCFL5", "X3_TAMANHO")
                end case

                oModelEKR := oModel:GetModel("EKR_MASTER")
                cRet := space( nTam )
                cCpoInfo := oModelEKR:getValue( cCampo )
                if !empty( cCpoInfo )
                    cRet := PadR( Posicione("EKU", 1, xFilial("EKU") + cCpoInfo , "EKU_FDTDES"), nTam )
                endif

            case ( cCampo == "EKR_FUNII" .or. cCampo == "EKR_FUNIPI" .or. cCampo == "EKR_FUNPIS" .or. cCampo == "EKR_FUNCOF" ) .and. cOrdem == "2"

                do case
                    case cCampo == "EKR_FUNII"
                        cCDomin := "EKR_REGTRI"
                        cCpoDesc := "EKR_DSCRG1"
                    case cCampo == "EKR_FUNIPI"
                        cCDomin := "EKR_REGIPI"
                        cCpoDesc := "EKR_DSCRG2"
                    case cCampo == "EKR_FUNPIS"
                        cCDomin := "EKR_REGPIS"
                        cCpoDesc := "EKR_DSCRG3"
                    case cCampo == "EKR_FUNCOF"
                        cCDomin := "EKR_REGCOF"
                        cCpoDesc := "EKR_DSCRG4"
                end case

                oModelEKR := oModel:GetModel("EKR_MASTER")
                cRet := oModelEKR:getValue( cCampo )
                cCpoInfo := oModelEKR:getValue( cCampo )
                if !empty(cCpoInfo)
                    nTam := getSx3Cache( cCDomin , "X3_TAMANHO")
                    cRet := PadR( Posicione("EKU", 1, xFilial("EKU") + cCpoInfo , "EKU_REGIME"), nTam )
                endif

                if( empty(cRet), oModelEKR:loadValue( cCpoDesc, " " ), nil)

            case ( cCampo == "EKR_REGTRI" .or. cCampo == "EKR_REGIPI" .or. cCampo == "EKR_REGPIS" .or. cCampo == "EKR_REGCOF" ) .and. cOrdem == "1"
            
                do case
                    case cCampo == "EKR_REGTRI"
                        nTam := getSx3Cache( "EKR_DSCRG1", "X3_TAMANHO")
                    case cCampo == "EKR_REGIPI"
                        nTam := getSx3Cache( "EKR_DSCRG2", "X3_TAMANHO")
                    case cCampo == "EKR_REGPIS"
                        nTam := getSx3Cache( "EKR_DSCRG3", "X3_TAMANHO")
                    case cCampo == "EKR_REGCOF"
                        nTam := getSx3Cache( "EKR_DSCRG4", "X3_TAMANHO")
                end case

                oModelEKR := oModel:GetModel("EKR_MASTER")
                cRet := space( nTam )
                cCpoInfo := oModelEKR:getValue( cCampo )
                if !empty( cCpoInfo )
                    cRet := PadR( Posicione("SJP", 1, xFilial("SJP") + cCpoInfo , "JP_DESC"), nTam )
                endif

            case cCampo == "EKR_REGTRI" .and. cOrdem == "2"

                oModelEKR := oModel:GetModel("EKR_MASTER")
                cRet := oModelEKR:getValue("EKR_ALR_II")
                if !(oModelEKR:getValue("EKR_REGTRI") == "4") // REDUCAO
                    cRet := 0
                endif

            case (cCampo == "EKR_REGIPI" .and. cOrdem == "2") .or. (cCampo == "EKR_TPAIPI" .and. cOrdem == "1")

                oModelEKR := oModel:GetModel("EKR_MASTER")
                cRet := oModelEKR:getValue("EKR_ALRIPI")
                if !(oModelEKR:getValue("EKR_REGIPI") == "4" .and. oModelEKR:getValue("EKR_TPAIPI") $ "1|3") // REDUCAO e Tipo de alíquota 1=Ad Valorem ou 3=Mista
                    cRet := 0
                endif

            case ((cCampo == "EKR_REGPIS" .or. cCampo == "EKR_REGCOF") .and. cOrdem == "2") .or. ((cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF") .and. cOrdem == "1")

                oModelEKR := oModel:GetModel("EKR_MASTER")
                do case 
                    case cCampo == "EKR_REGPIS"
                        cRet := oModelEKR:getValue("EKR_REDPIS")
                        cRegInfo := oModelEKR:getValue("EKR_REGPIS")
                        cTipoAli := oModelEKR:getValue("EKR_TPAPIS")
                    case cCampo == "EKR_REGCOF"
                        cRet := oModelEKR:getValue("EKR_REDCOF")
                        cRegInfo := oModelEKR:getValue("EKR_REGCOF")
                        cTipoAli := oModelEKR:getValue("EKR_TPACOF")
                end case

                if !(cRegInfo == "4" .and. cTipoAli == "1") // REDUCAO e Tipo de alíquota 1=Ad Valorem
                    cRet := 0
                endif

            case (cCampo == "EKR_TPAIPI" .and. cOrdem == "2") .or. (cCampo == "EKR_TPADUM" .and. cOrdem == "1")

                oModelEKR := oModel:GetModel("EKR_MASTER")
                do case 
                    case cCampo == "EKR_TPAIPI"
                        cRet := oModelEKR:getValue("EKR_ALUIPI")
                        cTipoAli := oModelEKR:getValue("EKR_TPAIPI")
                    case cCampo == "EKR_TPADUM"
                        cRet := oModelEKR:getValue("EKR_ALEADU")
                        cTipoAli := oModelEKR:getValue("EKR_TPADUM")
                end case
 
                if !(cTipoAli $ "2|3") // Tipo de alíquota 2=Específica ou 3=Mista
                    cRet := 0
                endif

            case (cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF") .and. cOrdem == "2"

                oModelEKR := oModel:GetModel("EKR_MASTER")
                do case 
                    case cCampo == "EKR_TPAPIS"
                        cRet := oModelEKR:getValue("EKR_ALUPIS")
                        cTipoAli := oModelEKR:getValue("EKR_TPAPIS")
                    case cCampo == "EKR_TPACOF"
                        cRet := oModelEKR:getValue("EKR_ALUCOF")
                        cTipoAli := oModelEKR:getValue("EKR_TPACOF")
                end case
    
                if !(cTipoAli == "2") // Tipo de alíquota 2=Específica
                    cRet := 0
                endif

            case (cCampo == "EKR_TPAIPI" .and. cOrdem == "3") .or. (cCampo == "EKR_TPADUM" .and. cOrdem == "2")

                oModelEKR := oModel:GetModel("EKR_MASTER")
                do case 
                    case cCampo == "EKR_TPAIPI"
                        cRet := oModelEKR:getValue("EKR_ALAIPI")
                        cTipoAli := oModelEKR:getValue("EKR_TPAIPI")
                    case cCampo == "EKR_TPADUM"
                        cRet := oModelEKR:getValue("EKR_ALADDU")
                        cTipoAli := oModelEKR:getValue("EKR_TPADUM")
                end case

                if !(cTipoAli $ "1|3") // Tipo de alíquota 1=Ad Valorem ou 3=Mista
                    cRet := 0
                endif

            case (cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF") .and. cOrdem == "3"

                oModelEKR := oModel:GetModel("EKR_MASTER")
                do case 
                    case cCampo == "EKR_TPAPIS"
                        cRet := oModelEKR:getValue("EKR_ALAPIS")
                        cTipoAli := oModelEKR:getValue("EKR_TPAPIS")
                    case cCampo == "EKR_TPACOF"
                        cRet := oModelEKR:getValue("EKR_ALACOF")
                        cTipoAli := oModelEKR:getValue("EKR_TPACOF")
                end case

                if !(cTipoAli == "1") // Tipo de alíquota 1=Ad Valorem
                    cRet := 0
                endif

        end case

    endif

return cRet

/*/{Protheus.doc} TRB100Init
    Função para tratamento do inicializador padrão dos campos

    @type  Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  cCampo, caracter, nome do campo
            oModelo, objeto, objeto do modelo
    @return cRet, caracter, informação a ser disparada
    @example
    (examples)
    @see (links_or_references)
/*/
function TRB100Init(cCampo, oModel)
    local xRet      := nil
    local aCposSWZ  := {}
    local nPosCpo   := 0
    local cOperacao := ""
    local cCodProd  := ""
    local nTam      := ""
    local cCpoInfo  := ""

    default cCampo := ""
    default oModel := FWModelActive()

    if oModel <> nil

        if "WZ_" $ cCampo
            if oModel:GetOperation() <> 3 .and. !empty(cOperacao := oModel:GetValue("EKR_OPERAC")) .and. PosSWZ(cOperacao)
                xRet := SWZ->&(cCampo)
            else
                aCposSWZ  := getStruct()
                if !empty(cCampo)
                    nPosCpo := aScan( aCposSWZ, { |X| X[POS_CAMPO] == cCampo})
                endif

                if nPosCpo > 0
                    xRet := RetInfo(cCampo, aCposSWZ[nPosCpo][POS_TIPO], aCposSWZ[nPosCpo][POS_TAMANHO], aCposSWZ[nPosCpo][POS_DECIMAL])
                endif
            endif

        elseif "EKS_" $ cCampo
            xRet := RetInfo(cCampo, getSX3Cache(cCampo,"X3_TIPO"), getSX3Cache(cCampo,"X3_TAMANHO"), getSX3Cache(cCampo,"X3_DECIMAL"))
            if oModel:GetOperation() <> 3
                cCodProd := EKS->EKS_COD_I
                if !empty(cCodProd) 
                    if cCampo $ "EKS_DESCRI||EKS_UNIDAD||EKS_NCM||EKS_EXNCM" .and. PosSB1(cCodProd)
                        do case
                            case cCampo == "EKS_DESCRI"
                                xRet := SB1->B1_DESC
                            case cCampo == "EKS_UNIDAD"
                                xRet := SB1->B1_UM
                            case cCampo == "EKS_NCM"
                                xRet := SB1->B1_POSIPI
                            case cCampo == "EKS_EXNCM"
                                xRet := SB1->B1_EX_NCM
                        end case
                    elseif cCampo == "EKS_UMNCM" .and. PosSB1(cCodProd) .and. PosSYD( SB1->B1_POSIPI, SB1->B1_EX_NCM)
                        xRet := SYD->YD_UNID
                    endif       
                endif
            endif

        elseif "EKR_" $ cCampo
            if cCampo == "EKR_DSCFL1" .or. cCampo == "EKR_DSCFL2" .or. cCampo == "EKR_DSCFL3" .or. cCampo == "EKR_DSCFL4" .or. cCampo == "EKR_DSCFL5"
                nTam := getSx3Cache( cCampo, "X3_TAMANHO")
                xRet := space( nTam )
                do case
                    case cCampo == "EKR_DSCFL1"
                        cCpoInfo := M->EKR_FUNII // Fundamento legal para II
                    case cCampo == "EKR_DSCFL2"
                        cCpoInfo := M->EKR_FUNIPI // Fundamento legal para IPI
                    case cCampo == "EKR_DSCFL3"
                        cCpoInfo := M->EKR_FUNPIS // Fundamento legal para PIS
                    case cCampo == "EKR_DSCFL4"
                        cCpoInfo := M->EKR_FUNCOF // Fundamento legal para COFINS
                    case cCampo == "EKR_DSCFL5"
                        cCpoInfo := M->EKR_FUNADU // Fundamento legal para ANTIDUMPING
                end case

                if !empty( cCpoInfo )
                    xRet := PadR( Posicione("EKU", 1, xFilial("EKU") + cCpoInfo , "EKU_FDTDES"), nTam )
                endif

            elseif cCampo == "EKR_REGTRI" .or. cCampo == "EKR_REGIPI" .or. cCampo == "EKR_REGPIS" .or. cCampo == "EKR_REGCOF"
                xRet := "1" // Recolhimento Integral

            elseif cCampo == "EKR_DSCRG1" .or. cCampo == "EKR_DSCRG2" .or. cCampo == "EKR_DSCRG3" .or. cCampo == "EKR_DSCRG4"
                nTam := getSx3Cache( cCampo, "X3_TAMANHO")
                xRet := space( nTam )

                do case
                    case cCampo == "EKR_DSCRG1"
                        cCpoInfo := M->EKR_REGTRI // Regime tributário para II
                    case cCampo == "EKR_DSCRG2"
                        cCpoInfo := M->EKR_REGIPI // Regime tributário para IPI
                    case cCampo == "EKR_DSCRG3"
                        cCpoInfo := M->EKR_REGPIS // Regime tributário para PIS
                    case cCampo == "EKR_DSCRG4"
                        cCpoInfo := M->EKR_REGCOF // Regime tributário para COFINS
                end case

                if !empty( cCpoInfo )
                    xRet := PadR( Posicione("SJP", 1, xFilial("SJP") + cCpoInfo , "JP_DESC"), nTam )
                endif

            elseif cCampo == "EKR_TPAII" .or. cCampo == "EKR_TPAIPI" .or. cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF" .or. cCampo == "EKR_TPADUM"
                xRet := "1"

            endif
        endif
    endif

return xRet

/*/{Protheus.doc} TRB100Vld
    Função para tratamento da validação dos campos

    @type  Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  cCampo, caracter, nome do campo
            oModelo, objeto, objeto do modelo
    @return cRet, caracter, informação a ser disparada
    @example
    (examples)
    @see (links_or_references)
/*/
function TRB100Vld(cCampo)
    local lRet      := .T.
    local oModel    := FWModelActive()
    local oModelEKS := nil
    local oModelEKR := nil
    local cTributo  := ""

    if oModel <> nil
        do case
            case cCampo == "EKS_VINCUL"
                oModelEKS := oModel:GetModel("EKS_DETAIL")
                if !empty(oModelEKS:getValue("EKS_VINCUL")) .and. empty(oModelEKS:getValue("EKS_COD_I"))
                    lRet := .F.
                    EasyHelp(STR0009, STR0008, STR0010) // "Campo do código do produto está em branco." ### "Atenção" ### "Informe primeiro o código do produto."
                elseif empty(oModelEKS:getValue("EKS_VINCUL")) .and. !empty(oModelEKS:getValue("EKS_COD_I"))
                    lRet := .F.
                    EasyHelp(STR0012, STR0008, STR0013) // "O código do produto está preenchido." ### "Atenção" ### "Informe a vinculação para o produto."
                endif

            case cCampo == "EKR_FUNII" .or. cCampo == "EKR_FUNIPI" .or. cCampo == "EKR_FUNPIS" .or. cCampo == "EKR_FUNCOF" .or. cCampo == "EKR_FUNADU"
                
                oModelEKR := oModel:GetModel("EKR_MASTER")
                if !empty(oModelEKR:getValue(cCampo))
                    //lRet := ExistCpo("EKU", oModelEKR:getValue(cCampo))
                    //if lRet

                        do case
                            case cCampo == "EKR_FUNII" // Fundamento legal para II
                                cTributo := TEGetOpcTr("II")
                            case cCampo == "EKR_FUNIPI" // Fundamento legal para IPI
                                cTributo := TEGetOpcTr("IPI")
                            case cCampo == "EKR_FUNPIS" // Fundamento legal para PIS
                                cTributo := TEGetOpcTr("PIS")
                            case cCampo == "EKR_FUNCOF" // Fundamento legal para COFINS
                                cTributo := TEGetOpcTr("COFINS")
                            case cCampo == "EKR_FUNADU" // Fundamento legal para ANTIDUMPING
                                cTributo := TEGetOpcTr("ANTIDUMPING")
                        end case

                        lRet := ExistCpo("EKV", oModelEKR:getValue(cCampo) + cTributo, 3)
                    //endif
                endif

            case cCampo == "EKR_REGTRI" .or. cCampo == "EKR_REGIPI" .or. cCampo == "EKR_REGPIS" .or. cCampo == "EKR_REGCOF"
                oModelEKR := oModel:GetModel("EKR_MASTER")
                lRet := empty(oModelEKR:getValue(cCampo)) .or. ExistCpo("SJP", oModelEKR:getValue(cCampo))

            case cCampo == "EKR_TPAII" .or. cCampo == "EKR_TPAIPI" .or. cCampo == "EKR_TPADUM"
                oModelEKR := oModel:GetModel("EKR_MASTER")
                lRet := empty(oModelEKR:getValue(cCampo)) .or. Pertence("123")

            case cCampo == "EKR_TPAPIS" .or. cCampo == "EKR_TPACOF"
                oModelEKR := oModel:GetModel("EKR_MASTER")
                lRet := empty(oModelEKR:getValue(cCampo)) .or. Pertence("12")

            case cCampo == "EKR_ALI_II" .or. cCampo == "EKR_ALR_II" .or. ;
                 cCampo == "EKR_ALAIPI" .or. cCampo == "EKR_ALRIPI" .or. cCampo == "EKR_ALUIPI" .or. ;
                 cCampo == "EKR_ALAPIS" .or. cCampo == "EKR_REDPIS" .or. cCampo == "EKR_ALUPIS" .or. cCampo == "EKR_ALPISM" .or. ;
                 cCampo == "EKR_ALACOF" .or. cCampo == "EKR_REDCOF" .or. cCampo == "EKR_ALUCOF" .or. cCampo == "EKR_ALCOFM" .or. ;
                 cCampo == "EKR_ALEADU" .or. cCampo == "EKR_ALADDU" 
                lRet := Positivo()

        end case
    endif

return lRet

/*/{Protheus.doc} CpoSWZModel
    inclusão dos campos da tabela SWZ no modelo 

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  oStruct, Objeto, Objeto da classe FWFormStruct
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
static function CpoSWZModel( oStruct )
    local aStruct    := getStruct()
    local nCpo       := 0

    default oStruct := FWFormStruct( 1 , "EKR") 

    for nCpo := 1 to len(aStruct)
        oStruct:AddField( 	aStruct[nCpo][POS_TITULO]                               , ; // [01]  C   Titulo do campo
                            aStruct[nCpo][POS_DESCRI]                               , ; // [02]  C   ToolTip do campo
                            aStruct[nCpo][POS_CAMPO]                                , ; // [03]  C   identificador (ID) do Field
                            aStruct[nCpo][POS_TIPO]                                 , ; // [04]  C   Tipo do campo
                            aStruct[nCpo][POS_TAMANHO]                              , ; // [05]  N   Tamanho do campo
                            aStruct[nCpo][POS_DECIMAL]                              , ; // [06]  N   Decimal do campo
                            {|| .T. }                                               , ; // [07]  B   Code-block de validação do campo
                            {|| .F. }                                               , ; // [08]  B   Code-block de validação When do campo
                            {}                                                      , ; // [09]  A   Lista de valores permitido do campo
                            .F.                                                     , ; // [10]  L   Indica se o campo tem preenchimento obrigatório
                            FwBuildFeature(STRUCT_FEATURE_INIPAD,'TRB100Init(b,a)') , ; // [11]  B   Code-block de inicializacao do campo
                            .F.                                                     , ; // [12]  L   Indica se trata de um campo chave
                            .T.                                                     , ; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                            .T.                                                     )   // [14]  L   Indica se o campo é virtual
    next nCpo

return

/*/{Protheus.doc} CpoSWZView
    inclusão dos campos da tabela SWZ na view 

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  oStruct, Objeto, Objeto da classe FWFormStruct
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
static function CpoSWZView( oStruct )
    local aStruct    := getStruct()
    local nCpo       := 0
    local cPasta     := GetSX3Cache("EKR_OPERAC", "X3_FOLDER")
    local cGrupo     := GetSX3Cache("EKR_OPERAC", "X3_AGRUP")
    local cOrdem     := GetSX3Cache("EKR_OPERAC", "X3_ORDEM")
    local nOrdem     := val(cOrdem)

    default oStruct := FWFormStruct( 2 , "EKR")

    for nCpo := 1 to len(aStruct)
        nOrdem += 1
        oStruct:AddField(	aStruct[nCpo][POS_CAMPO]   , ;  // [01]  C   Nome do Campo
                            StrZero( nOrdem , 2)       , ;  // [02]  C   Ordem
                            aStruct[nCpo][POS_TITULO]  , ;  // [03]  C   Titulo do campo
                            aStruct[nCpo][POS_DESCRI]  , ;  // [04]  C   Descrição do campo
                            nil                        , ;  // [05]  A   Array com Help
                            aStruct[nCpo][POS_TIPO]    , ;  // [06]  C   Tipo do campo
                            aStruct[nCpo][POS_PICTURE] , ;  // [07]  C   Picture
                            nil                        , ;  // [08]  B   Bloco de Picture Var
                            ''                         , ;  // [09]  C   Consulta F3
                            .F.                        , ;  // [10]  L   Indica se o campo é editável
                            cPasta                     , ;  // [11]  C   Pasta do campo
                            cGrupo                     , ;  // [12]  C   Agrupamento do campo
                            aStruct[nCpo][POS_CBOX]    , ;  // [13]  A   Lista de valores permitido do campo (Combo)
                            nil                        , ;  // [14]  N   Tamanho Maximo da maior opção do combo
                            nil                        , ;  // [15]  C   Inicializador de Browse
                            .T.                        , ;  // [16]  L   Indica se o campo é virtual
                            nil                        )    // [17]  C   Picture Variável
    next nCpo

return

/*/{Protheus.doc} getStruct
    Retorna a estrutura da tabela SWZ

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  
    @return aStruct, Vetor, Vetor com os campos da tabela SWZ 
    @example
    (examples)
    @see (links_or_references)
/*/
static function getStruct()
    local aStruct    := {}
    local aStrSWZ    := {}
    local nCpo       := 0

    if _aStrSWZ == nil .or. len(_aStrSWZ) == 0
        aStrSWZ := FWSX3Util():GetAllFields("SWZ", .T.)
        if valtype(aStrSWZ) == "A"
            _aStrSWZ := {}
            for nCpo := 1 to len(aStrSWZ)
                if aStrSWZ[nCpo] $ "WZ_FILIAL||WZ_OPERACA||WZ_ALPISM||WZ_BASENFT||WZ_ALCOFM||WZ_IPINFT"
                    loop
                endif
                // { 1       , 2      , 3         , 4         , 5        , 6       , 7         , 8       }
                // { X3_CAMPO, X3_TIPO, X3_TAMANHO, X3_DECIMAL, X3_TITULO, X3_DESCR, X3_PICTURE, X3_CBOX }
                aAdd( _aStrSWZ, { aStrSWZ[nCpo] , GetSX3Cache(aStrSWZ[nCpo], "X3_TIPO"), GetSX3Cache(aStrSWZ[nCpo], "X3_TAMANHO"), GetSX3Cache(aStrSWZ[nCpo], "X3_DECIMAL"), GetSX3Cache(aStrSWZ[nCpo], "X3_TITULO"), FWSX3Util():GetDescription( aStrSWZ[nCpo] ), GetSX3Cache(aStrSWZ[nCpo], "X3_PICTURE"), getCombo(aStrSWZ[nCpo]) })
            next
        endif
    endif

    if valtype(_aStrSWZ) == "A"
        aStruct := aClone(_aStrSWZ)
    endif

return aStruct

/*/{Protheus.doc} getCombo
    Retorna a estrutura do combo de um campo

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  
    @return aCombo, Vetor, Vetor com os combox
    @example
    (examples)
    @see (links_or_references)
/*/
static function getCombo(cCampo)
    local aCombo := {}
    local cCombo := ""

    default cCampo := ""

    if !empty(cCampo)
        cCombo :=  GetSX3Cache(cCampo, "X3_CBOX")
        if !empty(cCombo)
            aCombo := StrTokArr2(cCombo, ";")
        endif
    endif

return aCombo

/*/{Protheus.doc} RetInfo
    Retorna a informação vazia do campo dependendo do tipo

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  
    @return cCampo, caracter, Nome do campo
            cTipo , caracter, Tipo do campo
    @example
    (examples)
    @see (links_or_references)
/*/
static function RetInfo(cCampo, cTipo, nTamanho, nDecimal)
    local xRet   := nil

    default cCampo   := ""
    default cTipo    := getSX3Cache(cCampo,"X3_TIPO")
    default nTamanho := getSX3Cache(cCampo,"X3_TAMANHO")
    default nDecimal := getSX3Cache(cCampo,"X3_DECIMAL")

    xRet := if( cTipo == "N", 0 , if( cTipo == "D", cTod("") , space(nTamanho) ) )

return xRet

/*/{Protheus.doc} PosSWZ
    POsiciona na tabela SWZ

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  cOperacao, caracter, Operacao
    @return lRet, logico, .T. posicionou e .F. não posicionou
    @example
    (examples)
    @see (links_or_references)
/*/
static function PosSWZ(cOperacao)
    local lRet       := .F.

    lRet := alltrim(cOperacao) == alltrim(SWZ->WZ_OPERACA)
    if !lRet
        SWZ->(dbSetOrder(2)) // WZ_FILIAL+WZ_OPERACA
        lRet := SWZ->(dbSeek( xFilial("SWZ") + cOperacao ))
    endif

return lRet

/*/{Protheus.doc} PosSB1
    POsiciona na tabela SB1

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  cCodProd, caracter, Codigo do produto
    @return lRet, logico, .T. posicionou e .F. não posicionou
    @example
    (examples)
    @see (links_or_references)
/*/
static function PosSB1(cCodProd)
    local lRet       := .F.

    lRet := alltrim(cCodProd) == alltrim(SB1->B1_COD)
    if !lRet
        SB1->(dbSetOrder(1)) // B1_FILIAL+B1_COD
        lRet := SB1->(dbSeek( xFilial("SB1") + cCodProd ))
    endif

return lRet

/*/{Protheus.doc} PosSYD
    Posiciona na tabela SYD

    @type  Static Function
    @author bruno akyo kubagawa
    @since 20/11/2022
    @version 1.0
    @param  cNCM, caracter, NCM
            cEXNCM, caracter, EX NCM
    @return lRet, logico, .T. posicionou e .F. não posicionou
    @example
    (examples)
    @see (links_or_references)
/*/
static function PosSYD(cNCM, cExNCM)
    local lRet       := .F.

    lRet := alltrim(cNCM) == alltrim(SYD->YD_TEC) .and. alltrim(cExNCM) == alltrim(SYD->YD_EX_NCM)
    if !lRet
        SYD->(dbSetOrder(1)) // YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM+YD_DESTAQU
        lRet := SYD->(dbSeek( xFilial("SYD") + cNCM +  cExNCM))
    endif

return lRet

/*/{Protheus.doc} TRB100GetEKR
    Função que retorna o código do Regime de Tributação DUIMP

    @type  Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param cCodProd, caractere, código do produto
           cLocEntr, caractere, sigla do destino
    @return cCodReg, caractere, código do regime de tributação DUIMP
    @example
    (examples)
    @see (links_or_references)
/*/
function TRB100GetEKR(cCodProd, cLocEntr, lAuto)
    local cCodReg    := ""
    local aArea      := {}
    local aAreaEKR   := {}
    local aAreaEKS   := {}
    local cQuery     := ""
    local cAliasQry  := ""
    local oQuery     := nil
    local aRegTrib   := {}

    default cCodProd   := ""
    default cLocEntr   := ""
    default lAuto      := .F.

    if !empty(cCodProd) .and. avFlags("REGIME_TRIBUTACAO_DUIMP")

        cCodReg := getRegTrb( cCodProd, cLocEntr)
        if empty(cCodReg)

            aArea := getArea()
            dbSelectArea("EKR")
            aAreaEKR := EKR->(getArea())
            dbSelectArea("EKS")
            aAreaEKS := EKS->(getArea())

            cCodProd := padr(cCodProd, len(EKS->EKS_COD_I) )
            cLocEntr := padr(cLocEntr, len(EKR->EKR_DESTIN) )

            cQuery := " SELECT EKR.EKR_FILIAL, EKR.EKR_CODREG, EKR.EKR_DESTIN, EKS.EKS_COD_I, EKS.EKS_VINCUL, EKR.R_E_C_N_O_ RECEKR, EKS.R_E_C_N_O_ RECEKS FROM " + RetSqlName('EKS') + " EKS "
            cQuery += " INNER JOIN " + RetSqlName('EKR') + " EKR ON EKR.D_E_L_E_T_ = ' ' AND EKR.EKR_FILIAL = EKS.EKS_FILIAL AND EKR.EKR_CODREG = EKS.EKS_CODREG AND EKR.EKR_MSBLQL = '2' "
            cQuery += " WHERE EKS.D_E_L_E_T_ = ' ' "
            cQuery += " AND EKS.EKS_FILIAL = ? "
            cQuery += " AND EKS.EKS_COD_I = ? "
            cQuery += " AND ( EKS.EKS_VINCUL = '1' OR EKS.EKS_VINCUL = '2') "
            if !empty(cLocEntr)
                cQuery += " AND ( EKR.EKR_DESTIN = ' ' OR EKR.EKR_DESTIN = ? )"
            endif
            cQuery += " ORDER BY EKR.EKR_FILIAL, EKR.EKR_CODREG, EKR.EKR_DESTIN, EKS.EKS_COD_I, EKS.EKS_VINCUL "

            oQuery := FWPreparedStatement():New(cQuery)
            oQuery:SetString(1,xFilial('EKS'))
            oQuery:SetString(2,cCodProd)
            if !empty(cLocEntr)
                oQuery:SetString(3,cLocEntr)
            endif
            cQuery := oQuery:GetFixQuery()

            cAliasQry := getNextAlias()
            MPSysOpenQuery(cQuery, cAliasQry)

            aRegTrib := {}
            (cAliasQry)->(dbGoTop())
            while (cAliasQry)->(!eof())
                // 1-Automático
                // 2-Perguntar
                // 3-Não vincular
                aAdd( aRegTrib , { (cAliasQry)->EKR_CODREG, (cAliasQry)->EKR_DESTIN, (cAliasQry)->EKS_VINCUL, (cAliasQry)->RECEKR, (cAliasQry)->RECEKS } )
                (cAliasQry)->(dbSkip())
            end
            (cAliasQry)->(dbCloseArea())
            oQuery:Destroy()

            if len(aRegTrib) > 0
                if len(aRegTrib) == 1 .and. ( empty( aRegTrib[1][2] ) .or. aRegTrib[1][2] == cLocEntr )
                    if aRegTrib[1][3] == "1"
                        cCodReg := aRegTrib[1][1]
                        setRegTrb( cCodProd, cLocEntr, cCodReg)
                    elseif aRegTrib[1][3] == "2"
                        if !lAuto .and. MsgYesNo(STR0014) // "Deseja vincular o cadastro de tributação ao item do Purchase Order?"
                            cCodReg := aRegTrib[1][1]
                        endif
                    endif
                elseif !lAuto
                    if ( aScan( aRegTrib, { |X| !(X[3] == "1") } ) == 0 .or. MsgYesNo(STR0014) ) // "Deseja vincular o cadastro de tributação ao item do Purchase Order?"
                        cCodReg := SelRegTrib(cCodProd, cLocEntr, aRegTrib)
                    endif
                endif
            endif

            FwFreeObj(oQuery)

            restArea(aArea)
            restArea(aAreaEKS)
            restArea(aAreaEKR)

        endif

        cCodReg := padr(cCodReg, len(EKR->EKR_CODREG) )

    endif

return cCodReg

/*/{Protheus.doc} SelRegTrib
    Função de seleção do código de tributação 

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  cCodProd, caractere, código do produto
            cLocEntr, caractere, sigla do destino
            aRegTrib, vetor, com os regimes de tributação encontrado
    @return cCodReg, caractere, código do regime de tributação DUIMP
    @example
    (examples)
    @see (links_or_references)
/*/
static function SelRegTrib(cCodProd, cLocEntr, aRegTrib)
    local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
    local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
    local aAreaEKR   := {}
    local aAreaEKS   := {}
    local cCodReg    := ""
    local cAliasMrk  := ""
    local cTmpRegTrb := ""
    local cIndex2    := ""
    local cIndExt    := ""
    local nCpo       := 0
    local aStruct    := {}
    local aSemSX3    := {}
    local cFieldMark := "REG_MARCA"
    local cMarcaTrb  := "X"
    local nReg       := 0
    local aColumns   := {}
    local oDlgTrb    := nil
    local oMrkBrTrb  := nil
    local nOpc       := 0
    local bConfirmar := { || nOpc := 1 , oDlgTrb:DeActivate() }
    local bValidMark := { || VldMark(oMrkBrTrb, cMarcaTrb, cFieldMark, cAliasMrk) }
    local lTribDUIMP := avFlags("TRIBUTACAO_DUIMP")

    default cCodProd   := ""
    default cLocEntr   := ""
    default aRegTrib   := {}

    aRotina := {}

    cAliasMrk := "F3_EKR" // GetNextAlias()
    if( select(cAliasMrk) > 0 , (cAliasMrk)->(dbCloseArea()), nil )

    aStruct := EKR->(dbStruct())
    aAdd(aStruct, {"RECNO"    ,"N" ,10 ,0 })
    aAdd(aStruct, {"RECEKR"   ,"N" ,10 ,0 })
    aAdd(aStruct, {cFieldMark ,"C" ,01 ,0 })

    aAdd(aSemSX3, {"RECNO"    ,"N" ,10 ,0 })
    aAdd(aSemSX3, {"RECEKR"   ,"N" ,10 ,0 })
    aAdd(aSemSX3, {cFieldMark ,"C" ,01 ,0 })

    aCampos := Array(EKR->(FCOUNT()))
    cTmpRegTrb := e_criatrab("EKR", aSemSX3, cAliasMrk )

    cIndExt := TEOrdBagExt()
    E_IndRegua( cAliasMrk , cTmpRegTrb+cIndExt, "EKR_CODREG+EKR_DESTIN")

    cIndex2 := e_create()
    E_IndRegua( cAliasMrk , cIndex2+cIndExt, cFieldMark)

    SET INDEX TO (cTmpRegTrb+cIndExt),(cIndex2+cIndExt)

    for nReg := 1 to len( aRegTrib )
        EKR->(dbGoto( aRegTrib[nReg][4] ))
        if EKR->(Recno()) == aRegTrib[nReg][4] .and. reclock(cAliasMrk, .T.)
            for nCpo := 1 To Len(aStruct)
                if aStruct[nCpo][1] == "RECEKR"
                    (cAliasMrk)->RECEKR := aRegTrib[nReg][4] 
                elseif !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO"))
                    (cAliasMrk)->&(aStruct[nCpo][1]) := EKR->&(aStruct[nCpo][1])
                endif
            next nCpo
            (cAliasMrk)->(MsUnlock())
        endif
    next nReg

    for nCpo := 1 To Len(aStruct)
        if !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO||EKR_FILIAL"))
            
            if lTribDUIMP .and. ( aStruct[nCpo][1] == "EKR_FUNREG" .or. aStruct[nCpo][1] == "EKR_ASSIPI" .or. aStruct[nCpo][1] == "EKR_REG_PC" .or. aStruct[nCpo][1] == "EKR_FUN_PC" )
                loop
            endif
            
            aAdd(aColumns,FWBrwColumn():New())
            if (aStruct[nCpo][1] $ "EKR_TPAPLI||EKR_MATUSA||EKR_TPAII||EKR_TPAIPI||EKR_TPAPIS||EKR_TPACOF||EKR_MSBLQL") .or. (!lTribDUIMP .and. aStruct[nCpo][1] == "EKR_REGIPI")
                aColumns[Len(aColumns)]:SetData( &("{|| X3Combo( '" + aStruct[nCpo][1] + "', " + aStruct[nCpo][1] + ") }") )
            elseif aStruct[nCpo][1] $ "EKR_REGTRI||EKR_REGIPI||EKR_REGPIS||EKR_REGCOF"
                aColumns[Len(aColumns)]:SetData( &("{|| Posicione('SJP', 1, xFilial('SJP') + " + aStruct[nCpo][1] + ", 'JP_DESC')}") )
            elseif aStruct[nCpo][1] == "EKR_FUNREG" .and. !lTribDUIMP
                aColumns[Len(aColumns)]:SetData( &("{|| Posicione('SY8', 1, xFilial('SY8') + EKR_FUNREG, 'Y8_DES')}") )
            elseif aStruct[nCpo][1] == "EKR_ASSIPI" .and. !lTribDUIMP
                aColumns[Len(aColumns)]:SetData( &("{|| cInfo := EKR_ASSIPI, SX5->(dbSeek(xFilial('SX5') + 'C4' + cInfo)), AllTrim(X5DESCRI()) }") )
            elseif aStruct[nCpo][1] == "EKR_REG_PC" .and. !lTribDUIMP
                aColumns[Len(aColumns)]:SetData( &("{|| Posicione('SJP', 1, xFilial('SJP') + EKR_REG_PC, 'JP_DESC')}") )
            elseif aStruct[nCpo][1] == "EKR_FUN_PC" .and. !lTribDUIMP
                aColumns[Len(aColumns)]:SetData( &("{|| Posicione('SJY', 1, xFilial('SJY') + EKR_FUN_PC, 'JY_DESC')}") )
            else
                aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nCpo][1]+"}") )
            endif
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE") )
            if aStruct[nCpo][1] == "EKR_DESTIN"
                aAdd(aColumns,FWBrwColumn():New())
                aColumns[Len(aColumns)]:SetData( &("{|| Posicione('SY9', 2, xFilial('SY9') + EKR_DESTIN, 'Y9_DESCR')}") )
                aColumns[Len(aColumns)]:SetTitle( RetTitle("EKR_DSCDES") ) 
                aColumns[Len(aColumns)]:SetSize( GetSx3Cache("EKR_DSCDES", "X3_TAMANHO") )
                aColumns[Len(aColumns)]:SetDecimal( GetSx3Cache("EKR_DSCDES", "X3_DECIMAL") )
                aColumns[Len(aColumns)]:SetPicture( GetSx3Cache("EKR_DSCDES", "X3_PICTURE") )
            endif
        endif	
    next nCpo 

    oDlgTrb := FWDialogModal():New()
    oDlgTrb:setEscClose(.F.)
    oDlgTrb:setTitle( OemTOAnsi(STR0015) + " - " + alltrim(cCodProd)) // "Selecione o regime de tributação para o produto"
    oDlgTrb:setSize(200, 340)
    oDlgTrb:enableFormBar(.F.)
    oDlgTrb:createDialog()

    oMrkBrTrb := FWMarkBrowse():New()
    oMrkBrTrb:SetFieldMark( cFieldMark )
    oMrkBrTrb:SetOwner( oDlgTrb:getPanelMain() )
    oMrkBrTrb:SetAlias( cAliasMrk )
    oMrkBrTrb:AddButton( OemTOAnsi(STR0016), bConfirmar,, 2 ) // "Confirmar"
    oMrkBrTrb:AddButton( OemTOAnsi(STR0017), { || oDlgTrb:DeActivate() },, 2 ) // "Cancelar"
    oMrkBrTrb:AddButton( OemTOAnsi(STR0018), { || EKR->(dbGoTo((cAliasMrk)->RECEKR)), FWExecView( STR0001,'EICTRB100', MODEL_OPERATION_VIEW,, { || .T. } ) },, 2 ) // // "Regime de Tributação" ### "Visualizar"
    oMrkBrTrb:SetAllMark( { || .T. } )
    oMrkBrTrb:SetMark( cMarcaTrb, cAliasMrk, cFieldMark )
    oMrkBrTrb:SetValid( bValidMark )
    oMrkBrTrb:SetColumns( aColumns )
    oMrkBrTrb:SetMenuDef("")
    oMrkBrTrb:SetTemporary(.T.)
    oMrkBrTrb:Activate()

    oDlgTrb:Activate()

    if nOpc == 1
        (cAliasMrk)->(dbSetOrder(2))
        if (cAliasMrk)->(dbSeek(cMarcaTrb))
            cCodReg := (cAliasMrk)->EKR_CODREG
        endif
    endif

    (cAliasMrk)->(E_EraseArq(cTmpRegTrb,cIndex2))

    if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)
    if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

    restArea(aAreaEKS)
    restArea(aAreaEKR)

return cCodReg

/*/{Protheus.doc} VldMark
    Função para validar a marcação do regime de tributação

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  oMrkBrTrb, objeto, objeto da classe FwMarkBrowse
            cMarcaTrb, caractere, marca utilizada (X)
            cFieldMark, caractere, campo da marca
            cAliasTmp, caractere, tabela informada no FwMarkBrowse
    @return lRet, lógico, retorno da validação 
    @example
    (examples)
    @see (links_or_references)
/*/
static function VldMark(oMrkBrTrb, cMarcaTrb, cFieldMark, cAliasTmp )
    local lRet       := .T.
    local nOrder     := 0
    local nReg       := 0

    default cMarcaTrb := ""
    default cAliasTmp := ""

    nOrder := (cAliasTmp)->(IndexOrd())
    nReg := (cAliasTmp)->(Recno())

    if empty((cAliasTmp)->&(cFieldMark))
        (cAliasTmp)->(dbSetOrder(2))
        if (cAliasTmp)->(dbSeek(cMarcaTrb)) .and. !((cAliasTmp)->(Recno()) == nReg)
            lRet := MsgYesNo(STR0019 + CHR(13) + CHR(10) + STR0020 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; // "Já possui um registro marcado." ### 
                             STR0021) // "Caso confirme, será desmarcado o registro e marcado o registro atual."
            if lRet
                oMrkBrTrb:oBrowse:GoTo((cAliasTmp)->(Recno()),.T.)
                RecLock(cAliasTmp, .F.)
                (cAliasTmp)->&(cFieldMark) := " "
                (cAliasTmp)->(MsUnlock())
                oMrkBrTrb:oBrowse:GoTo(nReg, .T.)
            endif
        endif
    endif

    (cAliasTmp)->(dbSetOrder(nOrder))
    (cAliasTmp)->(dbGoTo(nReg))

return lRet

/*/{Protheus.doc} setRegTrb
    Função para adicionar o código do regime de tributação no vetor static _aRegTrib

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  cCodProd, caractere, código do produto
            cLocEntr, caractere, sigla do local de entrega
            cCodReg, caractere, código do regime de tributação
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
static function setRegTrb( cCodProd, cLocEntr, cCodReg)
    if !empty(cCodReg)
        aAdd( _aRegTrib , { cCodProd, cLocEntr, cCodReg } )
    endif
return

/*/{Protheus.doc} getRegTrb
    Função para retornar o código do regime de tributação adicionado no vetor static _aRegTrib

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  cCodProd, caractere, código do produto
            cLocEntr, caractere, sigla do local de entrega
    @return cRet, caractere, código do regime de tributação
    @example
    (examples)
    @see (links_or_references)
/*/
static function getRegTrb( cCodProd, cLocEntr)
    local cRet := ""
    local nPos := 0

    nPos := aScan( _aRegTrib , { |X| X[1] == cCodProd .and. X[2] == cLocEntr } )
    if nPos > 0
        cRet := _aRegTrib[nPos][3]
    endif

return cRet

/*/{Protheus.doc} TRB100Clear
    Função limpar o vetor static _aRegTrib

    @type  Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param 
    @return 
    @example
    (examples)
    @see (links_or_references)
/*/
function TRB100Clear()
    aSize(_aRegTrib, 0)
    _aRegTrib := {} 
return

/*/{Protheus.doc} AssocProd
    Função chamada em Outras Ações, para associar produtos ao cadastro do Regime de Tributação - DUIMP

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  oView, objeto, objeto da view 
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
static function AssocProd(oView)
    local aArea      := {}
    local aPergunte  := {}
    local oFwSX1Util := nil
    local lProc      := .F.
    local oModel     := nil
    local oModelEKS  := nil
    local nLine      := 0
    local lConfirmar := .F.

    aArea := getArea()

    oFwSX1Util := FwSX1Util():New()
    oFwSX1Util:AddGroup("EICTRB100")
    oFwSX1Util:SearchGroup()
    aPergunte := oFwSX1Util:GetGroup("EICTRB100")

    lProc := if( len(aPergunte) > 0 .and. len(aPergunte[2]) > 0, .T., (EasyHelp(STR0023, STR0008, STR0024 ),.F.)) // "Funcionalidade não disponível para esta versão do sistema." #### "Atenção" #### "A funcionalidade estará disponível a partir do próximo release ou através do pacote de Expedição Contínua. Acompanhe a página de publicações em Documentos de Referência - Comércio Exterior (TDN)."

    if lProc
        oModel := FWModelActive()
        oModelEKS := oModel:GetModel("EKS_DETAIL")
        nLine := oModelEKS:getLine()

        while pergunte("EICTRB100",.T.) 
            lConfirmar := .F.
            if getProduto(@oModelEKS, @lConfirmar)
                if lConfirmar
                    setProduto(@oModelEKS)
                endif
                exit
            endif
        end

        oModelEKS:goLine(nLine)
    endif

    RestArea(aArea)

    FwFreeArray(aPergunte)
    FwFreeObj(oFwSX1Util)
    aPergunte := nil

return nil

/*/{Protheus.doc} getProduto
    Função da query do produtos com os parametros do filtro EICTRB100

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  oModelEKS, objeto, objeto do modelo da tabela EKS
            lConfirmar, logico, variavel para controle se foi confirmado a operação
    @return lRet, logico, validação dos filtro de produtos (.T. com sucesso / .F. com falha)
    @example
    (examples)
    @see (links_or_references)
/*/
static function getProduto(oModelEKS, lConfirmar)
    local lRet       := .F.
    local cMsgError  := ""
    local cMsgSoluc  := ""
    local cProdImp   := ""
    local cNCMIni    := ""
    local cNCMFim    := ""
    local cEXNCMIni  := ""
    local cEXNCMFim  := ""
    local cQuery     := ""
    local oQuery     := nil
    local cAliasQry  := ""
    local aFilInfos  := {}
    local nFil       := 0

    default lConfirmar := .F.

    begin sequence

    pergunte("EICTRB100", .F.)
    cProdImp := if( MV_PAR01 == 1, "S", if( MV_PAR01 == 2, "N", "")) 
    cNCMIni := MV_PAR02
    cEXNCMIni := MV_PAR03
    cNCMFim := MV_PAR04
    cEXNCMFim := MV_PAR05

    if empty(cNCMFim)
        cMsgError := STR0025 // "Informe o intervalo de NCM para realizar o filtro dos produtos."
        break
    endif

    cAliasQry := getNextAlias()

    cQuery := " SELECT SB1.B1_IMPORT, SB1.B1_COD, SB1.B1_DESC, SB1.B1_POSIPI, SB1.B1_EX_NCM, SB1.R_E_C_N_O_ RECSB1 "
    cQuery += " FROM " + RetSqlName('SB1') + " SB1 "
    cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "

    aFilInfos := {} 
    aAdd( aFilInfos , xFilial('SB1'))
    cQuery += " AND SB1.B1_FILIAL = ? "

    if cNCMIni == cNCMFim
        aAdd( aFilInfos , cNCMIni)
        cQuery += " AND SB1.B1_POSIPI = ? "
    else
        aAdd( aFilInfos , cNCMIni)
        aAdd( aFilInfos , cNCMFim)
        cQuery += " AND SB1.B1_POSIPI >= ? "
        cQuery += " AND SB1.B1_POSIPI <= ? "
    endif

    if !empty(cProdImp)
        aAdd( aFilInfos , cProdImp)
        cQuery += " AND SB1.B1_IMPORT = ? "
    endif

    if !empty(cEXNCMIni) .or. !empty(cEXNCMFim)
        if cEXNCMIni == cEXNCMFim
            aAdd( aFilInfos , cEXNCMIni)
            cQuery += " AND SB1.B1_EX_NCM = ? "
        else
            aAdd( aFilInfos , cEXNCMIni)
            aAdd( aFilInfos , cEXNCMFim)
            cQuery += " AND SB1.B1_EX_NCM >= ? "
            cQuery += " AND SB1.B1_EX_NCM <= ? "
        endif
    endif
    cQuery += " ORDER BY SB1.B1_COD "

    oQuery := FWPreparedStatement():New(cQuery)
    for nFil := 1 to len(aFilInfos)
        oQuery:SetString(nFil,aFilInfos[nFil])
    next
    cQuery := oQuery:GetFixQuery()

    MPSysOpenQuery(cQuery, cAliasQry)

    lRet := SelProds(@oModelEKS, @lConfirmar, cAliasQry, @cMsgError, @cMsgSoluc, cProdImp, cNCMIni, cEXNCMIni, cNCMFim, cEXNCMFim)

    end sequence

    if !lRet .and. !empty(cMsgError)
        EasyHelp(cMsgError, STR0008, cMsgSoluc) // "Atenção"
    endif

    if !empty(cAliasQry) .and. select(cAliasQry) > 0
        (cAliasQry)->(dbCloseArea())
    endif
    fwFreeObj(oQuery)

return lRet

/*/{Protheus.doc} SelProds
    Função de seleção dos produtos que serão associados ao Regime de Tributação DUIMP

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  oModelEKS, objeto, objeto do modelo da tabela EKS
            lConfirmar, logico, variavel para controle se foi confirmado a operação 
            cAliasQry, caractere, alias da query dos produtos com o filtro do pergunte
            cMsgError, caractere, mensagem de validação
            cMsgSoluc, caractere, mensagem de solução
            cProdImp, caractere, produto importado (informação do pergunte)
            cNCMIni, caractere, NCM inicial (informação do pergunte)
            cEXNCMIni, caractere, EX-NCM inicial (informação do pergunte)
            cNCMFim, caractere, NCM final (informação do pergunte)
            cEXNCMFim, caractere, EX-NCM final (informação do pergunte)
    @return lRet, logico, validação da apresentação dos produtos para seleciona-los (.T. com sucesso / .F. com falha)
    @example
    (examples)
    @see (links_or_references)
/*/
static function SelProds(oModelEKS, lConfirmar, cAliasQry, cMsgError, cMsgSoluc, cProdImp, cNCMIni, cEXNCMIni, cNCMFim, cEXNCMFim )
    local lRet       := .F.
    local aBckRot    := if( isMemVar( "aRotina" ), aClone( aRotina ), {})
    local cAliasSB1  := TRB100_SB1
    local lProd      := .F.
    local aSeekEKS   := {}
    local cFieldMark := "REG_MARCA"
    local cMarcaSB1  := "X"
    local nCpo       := 0
    local aStruct    := {}
    local aColumns   := {}
    local oDlgSB1    := nil
    local oMrkBrSB1  := nil
    local bMarcar    := { || MarcarProd( cAliasSB1, cFieldMark, cMarcaSB1), oMrkBrSB1:oBrowse:Refresh() }

    default lConfirmar := .F.
    default cAliasQry  := ""
    default cMsgError  := ""
    default cMsgSoluc  := ""
    default cProdImp   := ""
    default cNCMIni    := ""
    default cEXNCMIni  := ""
    default cNCMFim    := ""
    default cEXNCMFim  := ""

    aRotina := {}

    clearTmp(cAliasSB1)
    aStruct := (cAliasSB1)->(dbStruct())

    (cAliasQry)->(dbGoTop())
    while (cAliasQry)->(!eof())

        aSeekEKS := { {"EKS_COD_I", (cAliasQry)->B1_COD }}
        if !oModelEKS:SeekLine(aSeekEKS, .T., .F.)
            reclock(cAliasSB1, .T.)
            lProd := .T.
            for nCpo := 1 To Len(aStruct)
                if aStruct[nCpo][1] == cFieldMark
                    (cAliasSB1)->&(cFieldMark) := cMarcaSB1
                elseif aStruct[nCpo][1] == "B1_IMPORT"
                    (cAliasSB1)->&(aStruct[nCpo][1]) := X3COMBO( aStruct[nCpo][1], (cAliasQry)->&(aStruct[nCpo][1]) ) 
                elseif !aStruct[nCpo][1] == "RECNO"
                    (cAliasSB1)->&(aStruct[nCpo][1]) := (cAliasQry)->&(aStruct[nCpo][1])
                endif
            next nCpo
            (cAliasSB1)->(MsUnlock())
        endif

        (cAliasQry)->(dbSkip())
    end

    if !lProd
        cMsgError := STR0026 + CHR(10) // "Não foram encontrados novos produtos."
        cMsgError += STR0027 + ":" + CHR(10) // "Filtro"
        cMsgError += if( cNCMIni == cNCMFim, " - NCM: " + cNCMIni,  " - " + STR0028 + ": " +  cNCMIni + " - " + cNCMFim) + CHR(10) // Intervalo de NCM
        cMsgError += if( !empty(cEXNCMIni) .or. !empty(cEXNCMFim), if(cEXNCMIni == cEXNCMFim, " - EX-NCM: " + cEXNCMIni, " - " + STR0029 + ": " + cEXNCMIni + " - " + cEXNCMFim) + CHR(10), "") // Intervalo de EX-NCM
        cMsgError += if( !empty(cProdImp), " - " + STR0030 + ": " + if(cProdImp=="S", STR0031, if(cProdImp=="N", STR0032, STR0033)), "") // "Produto Importado" #### "Sim" #### "Não" #### "Ambos"
        cMsgSoluc := STR0034 // "Verifique os critérios do filtro."
        break
    endif

    for nCpo := 1 To Len(aStruct)
        if !(aStruct[nCpo][1] $ (cFieldMark +"||RECNO||RECSB1"))
            aAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCpo][1] + "}") )
            aColumns[Len(aColumns)]:SetTitle( RetTitle(aStruct[nCpo][1]) ) 
            aColumns[Len(aColumns)]:SetSize( aStruct[nCpo][3] ) 
            aColumns[Len(aColumns)]:SetDecimal( aStruct[nCpo][4] )
            aColumns[Len(aColumns)]:SetPicture( if( aStruct[nCpo][1] == "B1_IMPORT", "", GetSx3Cache(aStruct[nCpo][1], "X3_PICTURE")) )
        endif
    next nCpo 

    oDlgSB1 := FWDialogModal():New()
    oDlgSB1:setEscClose(.F.)
    oDlgSB1:setTitle( OemTOAnsi(STR0022) ) // "Associar Produtos"
    oDlgSB1:setSize(250, 480)
    oDlgSB1:enableFormBar(.F.)
    oDlgSB1:createDialog()

    oMrkBrSB1 := FWMarkBrowse():New()
    oMrkBrSB1:SetFieldMark( cFieldMark )
    oMrkBrSB1:SetOwner( oDlgSB1:getPanelMain() )
    oMrkBrSB1:SetAlias( cAliasSB1 )
    oMrkBrSB1:AddButton( OemTOAnsi(STR0016), { || lConfirmar := .T. , oDlgSB1:DeActivate() },, 2 ) // "Confirmar"
    oMrkBrSB1:AddButton( OemTOAnsi(STR0017), { || oDlgSB1:DeActivate() },, 2 ) // "Cancelar"
    oMrkBrSB1:AddButton( OemTOAnsi(STR0035), bMarcar,, 2 ) // "Marcar/Desmarcar todos"
    oMrkBrSB1:AddButton( OemTOAnsi(STR0018), { || SB1->(dbGoTo((cAliasSB1)->RECSB1)), FWExecView( STR0036,'MATA010', MODEL_OPERATION_VIEW,, { || .T. } ) },, 2 ) // "Visualizar" ### "Cadastro de Produto"
    oMrkBrSB1:SetAllMark( bMarcar )
    oMrkBrSB1:SetMark( cMarcaSB1, cAliasSB1, cFieldMark )
    oMrkBrSB1:SetColumns( aColumns )
    oMrkBrSB1:SetMenuDef("")
    oMrkBrSB1:SetTemporary(.T.)
    oMrkBrSB1:DisableFilter()
    oMrkBrSB1:DisableConfig()
    oMrkBrSB1:DisableReport()
    oMrkBrSB1:DisableDetails()
    oMrkBrSB1:Activate()

    oDlgSB1:Activate()

    lRet := .T.

    if( len(aBckRot) > 0, aRotina := aClone(aBckRot), nil)

return lRet

/*/{Protheus.doc} createTmp
    Função para criação do arquivo temporario no banco

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  cAliasSB1, caractere, Alias do arquivo temporario
            cFieldMark, caractere, Campo de marcação
            cMarcaSB1, caractere, Marcação
            lAll, logico, .F. para duplo clique no cabeçalho, somente inverte, .T. para marca ou desmarcar de acordo com o registro posicionado
    @return True, logico, .T. sempre
    @example
    (examples)
    @see (links_or_references)
/*/
static function MarcarProd(cAliasSB1, cFieldMark, cMarcaSB1 )
    local nPosSB1    := 0
    local cMarca     := ""
    local lMarcados  := .T.

    default cAliasSB1  := ""
    default cFieldMark := ""
    default cMarcaSB1  := ""

    nPosSB1 := (cAliasSB1)->(recno())

    (cAliasSB1)->(dbGoTop())
    while (cAliasSB1)->(!eof())
        lMarcados := !empty((cAliasSB1)->&(cFieldMark))
        if !lMarcados
            exit
        endif
        (cAliasSB1)->(dbSkip())
    end
    cMarca := if( lMarcados, " ", cMarcaSB1)

    (cAliasSB1)->(dbGoTop())
    while (cAliasSB1)->(!eof())
        reclock(cAliasSB1,.F.)
        (cAliasSB1)->&(cFieldMark) := cMarca
        (cAliasSB1)->(msUnLock())
        (cAliasSB1)->(dbSkip())
    end

    (cAliasSB1)->(dbGoTo(nPosSB1))

return .T.

/*/{Protheus.doc} createTmp
    Função para criação do arquivo temporario no banco

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param nenhum
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
static function createTmp()
    local aBckCampo  := if( isMemVar( "aCampos" ), aClone( aCampos ), {})
    local cAliasTmp  := ""
    local cFieldMark := ""
    local aSemSX3    := {}
    local cArqTab    := ""
    local cIndExt    := ""
    local cIndex1    := ""
    local cIndex2    := ""

    // ---- Criação da tabela temporaria para a funcionalidade Associar Produtos
    cAliasTmp := TRB100_SB1
    if Select(cAliasTmp) == 0
        cFieldMark := "REG_MARCA"
        aCampos := {}
        aSemSX3 := {}

        aAdd(aSemSX3, {"B1_COD"    , getSX3Cache( "B1_COD"   , "X3_TIPO"), getSX3Cache( "B1_COD"   , "X3_TAMANHO"), getSX3Cache( "B1_COD"   , "X3_DECIMAL") })
        aAdd(aSemSX3, {"B1_DESC"   , getSX3Cache( "B1_DESC"  , "X3_TIPO"), getSX3Cache( "B1_DESC"  , "X3_TAMANHO"), getSX3Cache( "B1_DESC"  , "X3_DECIMAL") })
        aAdd(aSemSX3, {"B1_POSIPI" , getSX3Cache( "B1_POSIPI", "X3_TIPO"), getSX3Cache( "B1_POSIPI", "X3_TAMANHO"), getSX3Cache( "B1_POSIPI", "X3_DECIMAL") })
        aAdd(aSemSX3, {"B1_EX_NCM" , getSX3Cache( "B1_EX_NCM", "X3_TIPO"), getSX3Cache( "B1_EX_NCM", "X3_TAMANHO"), getSX3Cache( "B1_EX_NCM", "X3_DECIMAL") })
        aAdd(aSemSX3, {"B1_IMPORT" , getSX3Cache( "B1_IMPORT", "X3_TIPO"), 03                                     , getSX3Cache( "B1_IMPORT", "X3_DECIMAL") })
        aAdd(aSemSX3, {"RECNO"     , "N"                                 , 10                                     , 0                                       })
        aAdd(aSemSX3, {"RECSB1"    , "N"                                 , 10                                     , 0                                       })
        aAdd(aSemSX3, {cFieldMark  , "C"                                 , 01                                     , 0                                       })

        cArqTab := e_criatrab(, aSemSX3, cAliasTmp )

        cIndExt := TEOrdBagExt()
        E_IndRegua( cAliasTmp , cArqTab+cIndExt, "B1_COD+B1_IMPORT")

        cIndex1 := e_create()
        E_IndRegua( cAliasTmp , cIndex1+cIndExt, cFieldMark)

        SET INDEX TO (cArqTab+cIndExt),(cIndex1+cIndExt)

        aAdd( _aTabsTmp, {cAliasTmp, cArqTab, cIndex1, cIndex2 })
    endif
    // ------------------------------------------------------------------------

    if( len(aBckCampo) > 0, aCampos := aClone(aBckCampo), nil)

return

/*/{Protheus.doc} eraseTmp
    Função para exclusão do arquivo temporario no banco

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param nenhum
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
static function eraseTmp()
    local nTab       := 0
    local cAliasTmp  := ""
    local cTabArq    := ""
    local cIndex1    := ""
    local cIndex2    := ""

    for nTab := 1 to len(_aTabsTmp)
        cAliasTmp := _aTabsTmp[nTab][ALIAS_TEMP]
        cTabArq := _aTabsTmp[nTab][ARQ_TAB]
        cIndex1 := if(empty(_aTabsTmp[nTab][INDEX1]),nil,_aTabsTmp[nTab][INDEX1])
        cIndex2 := if(empty(_aTabsTmp[nTab][INDEX2]),nil,_aTabsTmp[nTab][INDEX2])
        if select(cAliasTmp) > 0
            (cAliasTmp)->(E_EraseArq(cTabArq, cIndex1, cIndex2))
        endif
    next

    aSize(_aTabsTmp, 0)
    _aTabsTmp := {}

return

/*/{Protheus.doc} clearTmp
    Função limpeza do arquivo temporario no banco

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  cAliasTmp, caractere, Alias do arquivo temporario
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
static function clearTmp(cAliasTmp)
    default cAliasTmp := ""

    if( !empty(cAliasTmp), if( select(cAliasTmp)  > 0, AvZap(cAliasTmp), createTmp()), nil)

return

/*/{Protheus.doc} setProduto
    Função para carregar a grid Produtos Associados, após executação do filtro 

    @type  Static Function
    @author Bruno Akyo Kubagawa
    @since 02/12/2022
    @version 1.0
    @param  oModelEKS, objeto, objeto do modelo da tabela EKS
    @return nenhum
    @example
    (examples)
    @see (links_or_references)
/*/
static function setProduto(oModelEKS)
    local cAliasSB1  := TRB100_SB1
    local cFieldMark := "REG_MARCA"
    local aSeekEKS   := {}
    local nQtdLine   := oModelEKS:Length()
    local lAddLine   := .T.

    if nQtdLine == 1 .and. empty(oModelEKS:getValue("EKS_COD_I"))
        lAddLine := .F.
    endif

    (cAliasSB1)->(dbGoTop())
    while (cAliasSB1)->(!eof())

        if !empty( (cAliasSB1)->&(cFieldMark) )
            aSeekEKS := { {"EKS_COD_I", (cAliasSB1)->B1_COD }}
            if !oModelEKS:SeekLine(aSeekEKS, .T., .F.)
                if lAddLine
                    oModelEKS:addLine()
                endif
                oModelEKS:setValue( "EKS_COD_I", (cAliasSB1)->B1_COD )
                lAddLine := .T.
            endif
        endif

        (cAliasSB1)->(dbSkip())
    end

return

/*
Funcao     : TRB100RetF3
Parametros :  
Objetivos  : Função responsável pelo retorno da consulta padrão EKR
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 14/12/2021
*/
function TRB100RetF3()
    local cRet       := EKR->EKR_CODREG

    if FwIsInCallStack("EICPO400") .and. ExistFunc("PO400GetEKR") .and. select("WorkPO_EIJ") > 0
        PO400GetEKR(EKR->EKR_CODREG)
    endif

return cRet

/*/{Protheus.doc} TRB100VEKV
    Função utilizado para visualizar o registro na consulta padrão EKV

    @type  Function
    @author user
    @since 01/07/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
function TRB100VEKV()
    local aAreaEKU := EKU->(getArea())

    EKU->(dbSetOrder(1)) // EKU_FILIAL+EKU_FDTLGL   
    if EKU->(dbSeek( xFilial("EKU") + EKV->EKV_FDTLGL))
        FWExecView(STR0003,'EICFL100', MODEL_OPERATION_VIEW,, { || .T. } ) // "Visualizar"
    endif
    restArea(aAreaEKU)

return

/*/{Protheus.doc} TRB100Filt
    Função utilizado para filtrar a consulta padrão EKV

    @type  Function
    @author user
    @since 01/07/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
function TRB100Filt()
    local cFiltro    := ""
    local cField     := ReadVar()
    local oModel     := nil
    local oView      := nil
    local aFolder    := {}
    local cNcm       := ""
    local lFundLegIt := AvFlags("FUNDAMENTO_LEGAL_ITEM")
    local cPaisOrigem:= LP500GetPais()

    if !empty(cField)
        cField := StrTran(cField,"M->", "")

        if subStr(cField,1,3) $ "EIJ|EKW"
            oModel := FwModelActive()
            If lFundLegIt
                oView  := FwViewActive()
                if valtype(oModel) == "O"
                    aFolder := oView:GetFolderActive("INFERIOR_TRIB",2)
                EndIf
            EndIf
            if valtype(oModel) == "O" .and. oModel:getid() == "EICLP500"
                oModelSWV := oModel:GetModel("SWVDETAIL_TRIBUTACAO")
            endif
        endif
        lFundLegIt := AvFlags("FUNDAMENTO_LEGAL_ITEM") .And. cField == "EKW_FDTLGL" .And. !Empty(aFolder)
        do case
            case cField == "EKR_FUNII" .or. cField == "EIJ_FUNII" .or. (lFundLegIt .and. aFolder[1] == 1) // Fundamento legal II
                cFiltro := "EKV->EKV_TRIBUT == '" + TEGetOpcTr("II") + "'"
            case cField == "EKR_FUNIPI" .or. cField == "EIJ_FUNIPI" .or. (lFundLegIt .and. aFolder[1] == 2)// Fundamento legal IPI
                cFiltro := "EKV->EKV_TRIBUT == '" + TEGetOpcTr("IPI") + "'"
            case cField == "EKR_FUNPIS" .or. cField == "EIJ_FUNPIS" .or. (lFundLegIt .and. aFolder[1] == 3)// Fundamento legal PIS
                cFiltro := "EKV->EKV_TRIBUT == '" + TEGetOpcTr("PIS") + "'"
            case cField == "EKR_FUNCOF" .or. cField == "EIJ_FUNCOF" .or. (lFundLegIt .and. aFolder[1] == 4) // Fundamento legal COFINS
                cFiltro := "EKV->EKV_TRIBUT == '" + TEGetOpcTr("COFINS") + "'"
            case cField == "EKR_FUNADU" .or. cField == "EIJ_FUNADU"  .or. (lFundLegIt .and. aFolder[1] == 5) // Fundamento legal ANTIDUMPING
                cFiltro := "EKV->EKV_TRIBUT == '" + TEGetOpcTr("ANTIDUMPING") + "'"
        end case

        if (cField == "EIJ_FUNII" .or. cField == "EIJ_FUNIPI" .or. cField == "EIJ_FUNPIS" .or. cField == "EIJ_FUNCOF" .or. cField == "EIJ_FUNADU" .Or. lFundLegIt) .and. valtype(oModelSWV) == "O"
            cNcm := oModelSWV:getValue("WV_NCM")
            if !empty(cNcm)
                cFiltro += " .and. EKV->EKV_NCM == '" + cNcm + "'"
            endif
        endif

        if lFundLegIt //Se for fundamento legal de item, filtra também somente o tipo Opcional
            cFiltro += " .and. EKV->EKV_TIPO == '3' .and. EKV->EKV_PAIS == '" + cPaisOrigem + "'"
        EndIf

    endif

return cFiltro
