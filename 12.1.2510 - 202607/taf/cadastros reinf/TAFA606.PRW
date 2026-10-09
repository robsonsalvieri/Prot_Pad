#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA606.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA606
Cadastro MVC - R-9015 - Consolidação das retenções na fonte

@author Rafael de Paula Leme
@since 16/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA606()

    If TAFAlsInDic("V9F") .And. TAFAlsInDic("V9Q") .And. TAFAlsInDic("V9R")
        BrowseDef()
    Else
        Aviso("TAF", STR0002, { STR0015 }, 2) //'Ambiente desatualizado. Rotina não disponível' "Encerrar"
    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael de Paula Leme
@since 16/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina as array

    aRotina	:= {}

    //Para teste de inclusão de campos habilitar a linhas 45
    ADD OPTION aRotina TITLE STR0001   ACTION "VIEWDEF.TAFA606" OPERATION 2 ACCESS 0 //"Visualizar"
    //ADD OPTION aRotina TITLE 'Incluir' ACTION "VIEWDEF.TAFA606" OPERATION 3 ACCESS 0 //"Incluir"

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael de Paula Leme
@since 16/09/22

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruV9F as object
    Local oStruV9Q as object
    Local oStruV9R as object
    Local oModel   as object

    oStruV9F := FWFormStruct(1, 'V9F')
    oStruV9Q := FWFormStruct(1, 'V9Q')
    oStruV9R := FWFormStruct(1, 'V9R')

    oModel	 := MPFormModel():New('TAFA606')

    oModel:AddFields('MODEL_V9F', ,oStruV9F)
    oModel:GetModel('MODEL_V9F'):SetPrimaryKey({'V9F_FILIAL', 'V9F_ID', 'V9F_VERSAO'})

    //-------------------------------------------------------------------------------------------
    //  Informações relativas a totalizadores pela natureza do rendimento e código de receita  //
    //-------------------------------------------------------------------------------------------
    oModel:addgrid('MODEL_V9Q_MENSAL','MODEL_V9F', oStruV9Q)
    oModel:GetModel("MODEL_V9Q_MENSAL"):SetUniqueLine({'V9Q_TPPER','V9Q_PERTRB','V9Q_CR','V9Q_NATREN'})
    oModel:GetModel("MODEL_V9Q_MENSAL"):SetLoadFilter({{'V9Q_TPPER',"'1'"}})
    oModel:GetModel("MODEL_V9Q_MENSAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9Q_MENSAL",{{"V9Q_FILIAL","xFilial('V9Q')"},{"V9Q_ID","V9F_ID"},{"V9Q_VERSAO","V9F_VERSAO"}},V9Q->(IndexKey(1)))

    oModel:addgrid('MODEL_V9Q_QUINZENAL','MODEL_V9F', oStruV9Q)
    oModel:GetModel("MODEL_V9Q_QUINZENAL"):SetUniqueLine({'V9Q_TPPER','V9Q_PERTRB','V9Q_CR','V9Q_NATREN'})
    oModel:GetModel("MODEL_V9Q_QUINZENAL"):SetLoadFilter({{'V9Q_TPPER',"'2'"}})
    oModel:GetModel("MODEL_V9Q_QUINZENAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9Q_QUINZENAL",{{"V9Q_FILIAL","xFilial('V9Q')"},{"V9Q_ID","V9F_ID"},{"V9Q_VERSAO","V9F_VERSAO"}},V9Q->(IndexKey(1)))

    oModel:addgrid('MODEL_V9Q_DECENDIAL','MODEL_V9F', oStruV9Q)
    oModel:GetModel("MODEL_V9Q_DECENDIAL"):SetUniqueLine({'V9Q_TPPER','V9Q_PERTRB','V9Q_CR','V9Q_NATREN'})
    oModel:GetModel("MODEL_V9Q_DECENDIAL"):SetLoadFilter({{'V9Q_TPPER',"'3'"}})
    oModel:GetModel("MODEL_V9Q_DECENDIAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9Q_DECENDIAL",{{"V9Q_FILIAL","xFilial('V9Q')"},{"V9Q_ID","V9F_ID"},{"V9Q_VERSAO","V9F_VERSAO"}},V9Q->(IndexKey(1)))

    oModel:addgrid('MODEL_V9Q_SEMANAL','MODEL_V9F', oStruV9Q)
    oModel:GetModel("MODEL_V9Q_SEMANAL"):SetUniqueLine({'V9Q_TPPER','V9Q_PERTRB','V9Q_CR','V9Q_NATREN'})
    oModel:GetModel("MODEL_V9Q_SEMANAL"):SetLoadFilter({{'V9Q_TPPER',"'4'"}})
    oModel:GetModel("MODEL_V9Q_SEMANAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9Q_SEMANAL",{{"V9Q_FILIAL","xFilial('V9Q')"},{"V9Q_ID","V9F_ID"},{"V9Q_VERSAO","V9F_VERSAO"}},V9Q->(IndexKey(1)))

    oModel:addgrid('MODEL_V9Q_DIARIO','MODEL_V9F', oStruV9Q)
    oModel:GetModel("MODEL_V9Q_DIARIO"):SetUniqueLine({'V9Q_TPPER','V9Q_PERTRB','V9Q_CR','V9Q_NATREN'})
    oModel:GetModel("MODEL_V9Q_DIARIO"):SetLoadFilter({{'V9Q_TPPER',"'5'"}})
    oModel:GetModel("MODEL_V9Q_DIARIO"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9Q_DIARIO",{{"V9Q_FILIAL","xFilial('V9Q')"},{"V9Q_ID","V9F_ID"},{"V9Q_VERSAO","V9F_VERSAO"}},V9Q->(IndexKey(1)))

    //-------------------------------------------------------------------------------------------
    //                    Informações consolidadas dos tributos da empresa                     //
    //-------------------------------------------------------------------------------------------
    oModel:addgrid('MODEL_V9R_MENSAL','MODEL_V9F', oStruV9R)
    oModel:GetModel("MODEL_V9R_MENSAL"):SetUniqueLine({'V9R_TPPER','V9R_PERTRB','V9R_CR'})
    oModel:GetModel("MODEL_V9R_MENSAL"):SetLoadFilter({{'V9R_TPPER',"'1'"}})
    oModel:GetModel("MODEL_V9R_MENSAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9R_MENSAL",{{"V9R_FILIAL","xFilial('V9R')"},{"V9R_ID","V9F_ID"},{"V9R_VERSAO","V9F_VERSAO"}},V9R->(IndexKey(1)))

    oModel:addgrid('MODEL_V9R_QUINZENAL','MODEL_V9F', oStruV9R)
    oModel:GetModel("MODEL_V9R_QUINZENAL"):SetUniqueLine({'V9R_TPPER','V9R_PERTRB','V9R_CR'})
    oModel:GetModel("MODEL_V9R_QUINZENAL"):SetLoadFilter({{'V9R_TPPER',"'2'"}})
    oModel:GetModel("MODEL_V9R_QUINZENAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9R_QUINZENAL",{{"V9R_FILIAL","xFilial('V9R')"},{"V9R_ID","V9F_ID"},{"V9R_VERSAO","V9F_VERSAO"}},V9R->(IndexKey(1)))

    oModel:addgrid('MODEL_V9R_DECENDIAL','MODEL_V9F', oStruV9R)
    oModel:GetModel("MODEL_V9R_DECENDIAL"):SetUniqueLine({'V9R_TPPER','V9R_PERTRB','V9R_CR'})
    oModel:GetModel("MODEL_V9R_DECENDIAL"):SetLoadFilter({{'V9R_TPPER',"'3'"}})
    oModel:GetModel("MODEL_V9R_DECENDIAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9R_DECENDIAL",{{"V9R_FILIAL","xFilial('V9R')"},{"V9R_ID","V9F_ID"},{"V9R_VERSAO","V9F_VERSAO"}},V9R->(IndexKey(1)))

    oModel:addgrid('MODEL_V9R_SEMANAL','MODEL_V9F', oStruV9R)
    oModel:GetModel("MODEL_V9R_SEMANAL"):SetUniqueLine({'V9R_TPPER','V9R_PERTRB','V9R_CR'})
    oModel:GetModel("MODEL_V9R_SEMANAL"):SetLoadFilter({{'V9R_TPPER',"'4'"}})
    oModel:GetModel("MODEL_V9R_SEMANAL"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9R_SEMANAL",{{"V9R_FILIAL","xFilial('V9R')"},{"V9R_ID","V9F_ID"},{"V9R_VERSAO","V9F_VERSAO"}},V9R->(IndexKey(1)))

    oModel:addgrid('MODEL_V9R_DIARIO','MODEL_V9F', oStruV9R)
    oModel:GetModel("MODEL_V9R_DIARIO"):SetUniqueLine({'V9R_TPPER','V9R_PERTRB','V9R_CR'})
    oModel:GetModel("MODEL_V9R_DIARIO"):SetLoadFilter({{'V9R_TPPER',"'5'"}})
    oModel:GetModel("MODEL_V9R_DIARIO"):SetOptional(.T.)
    oModel:SetRelation("MODEL_V9R_DIARIO",{{"V9R_FILIAL","xFilial('V9R')"},{"V9R_ID","V9F_ID"},{"V9R_VERSAO","V9F_VERSAO"}},V9R->(IndexKey(1)))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael de Paula Leme
@since 16/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView    as object
    Local oModel   as object
    Local oStrV9F  as object
    Local oStrV9FR as object
    Local oStrV9Qm as object
    Local oStrV9Qp as object
    Local oStrV9Rm as object
    Local oStrV9Rp as object
    Local cCmpFil  as character

    oView  := FWFormView():new()
    oModel := FWLoadModel('TAFA606')

    //Informações de retorno
    cCmpFil := "V9F_PERAPU|V9F_DTPROC|V9F_HRPROC|V9F_TPEVEN|V9F_IDEVEN|V9F_HASH|V9F_TPINSC|V9F_NRINSC|V9F_NRRECB|"
    If TafColumnPos("V9F_DTRECE") // Reinf 2.1.2
        cCmpFil += "V9F_DTRECE|V9F_HRRECE|V9F_FECHRE|"
    EndIf
    oStrV9F := FwFormStruct(2, "V9F", {|x| AllTrim(x) + "|" $ cCmpFil})

    //Recibo
    cCmpFil  := "V9F_PROTUL|"
    oStrV9FR := FwFormStruct(2, "V9F", {|x| AllTrim(x) + "|" $ cCmpFil})

    //periodo mensal
    cCmpFil  := "V9Q_CR|V9Q_VTRIBI|V9Q_VTRIBC|V9Q_VRDCTF|V9Q_VSUSPI|V9Q_VSUSPC|V9Q_VSDCTF|V9Q_NATREN|"
    oStrV9Qm := FwFormStruct(2, "V9Q", {|x| AllTrim(x) + "|" $ cCmpFil})
    cCmpFil  := "V9R_CR|V9R_VRDCTF|V9R_VSDCTF|
    oStrV9Rm := FwFormStruct(2, "V9R", {|x| AllTrim(x) + "|" $ cCmpFil})

    //outros periodos
    cCmpFil  := "V9Q_PERTRB|V9Q_CR|V9Q_VTRIBI|V9Q_VTRIBC|V9Q_VRDCTF|V9Q_VSUSPI|V9Q_VSUSPC|V9Q_VSDCTF|V9Q_NATREN|"
    oStrV9Qp := FwFormStruct(2, "V9Q", {|x| AllTrim(x) + "|" $ cCmpFil})
    cCmpFil  := "V9R_PERTRB|V9R_CR|V9R_VRDCTF|V9R_VSDCTF|
    oStrV9Rp := FwFormStruct(2, "V9R", {|x| AllTrim(x) + "|" $ cCmpFil})
       

    oView:SetModel(oModel)
    oView:SetContinuousForm(.F.)

    oView:CreateHorizontalBox('BOXH_MASTER', 100)
    oView:CreateFolder("FOLDER_MASTER", "BOXH_MASTER")
    oView:AddSheet('FOLDER_MASTER', 'SHEET_MASTER', STR0003) //'Informações do Retorno'
    oView:AddSheet('FOLDER_MASTER', 'SHEET_PROTUL', STR0004) //"Recibo"

    oView:AddField("VIEW_V9FA", oStrV9F, "MODEL_V9F")
    oView:CreateHorizontalBox("PAINEL_SUPERIORA", 30, , ,"FOLDER_MASTER","SHEET_MASTER")
    oView:SetOwnerView("VIEW_V9FA", "PAINEL_SUPERIORA")

    oView:AddField("VIEW_V9FR", oStrV9FR, "MODEL_V9F")
    oView:EnableTitleView("VIEW_V9FR", STR0004) //"Recibo"
    oView:CreateHorizontalBox("PAINEL_SUPERIORR", 100, , ,"FOLDER_MASTER","SHEET_PROTUL")
    oView:SetOwnerView("VIEW_V9FR", "PAINEL_SUPERIORR")


    //                            ABAS V9Q e V9R
    oView:CreateHorizontalBox( 'BOX_FILHOS_V9F', 70, , ,"FOLDER_MASTER","SHEET_MASTER")
    oView:CreateFolder("FOLDER_FILHOS_V9F", "BOX_FILHOS_V9F")
    oView:AddSheet('FOLDER_FILHOS_V9F', 'SHEET_V9Q', STR0016) // "Info. Total por Nat. e Rend. Cód. Receita"
    oView:AddSheet('FOLDER_FILHOS_V9F', 'SHEET_V9R', STR0017) // "Info. Consolidadas Tributos"


    //                      PERIODOS ABA INFOCR_CNR (V9Q)
    oView:CreateHorizontalBox( 'BOX_PERIODO_V9Q', 100,,,"FOLDER_FILHOS_V9F","SHEET_V9Q")
    oView:CreateFolder("FOLDER_PERIODO_V9Q","BOX_PERIODO_V9Q")
    oView:AddSheet( 'FOLDER_PERIODO_V9Q', 'SHEET_PERIODO_V9Q', STR0005 ) //"Períodos"
    //-----------------------------------------------------------------------------------

    //                       PERIODOS ABA INFOTOTALCR (V9R)
    oView:CreateHorizontalBox( 'BOX_PERIODO_V9R', 100,,,"FOLDER_FILHOS_V9F","SHEET_V9R")
    oView:CreateFolder("FOLDER_PERIODO_V9R","BOX_PERIODO_V9R")
    oView:AddSheet( 'FOLDER_PERIODO_V9R', 'SHEET_PERIODO_V9R', STR0005 ) //"Períodos"
    //-----------------------------------------------------------------------------------


    //                       ABAS FILHOS DA INFOCR_CNR (V9Q)
    oView:CreateHorizontalBox( 'BOX_FILHO_V9QA', 100, , ,"FOLDER_PERIODO_V9Q","SHEET_PERIODO_V9Q")
    oView:CreateFolder("FOLDER_FILHO_V9Q", "BOX_FILHO_V9QA")
    oView:AddSheet('FOLDER_FILHO_V9Q', 'SHEET_FILHO_MENSAL_V9Q'   , STR0006) //'Mensal'
    oView:AddSheet('FOLDER_FILHO_V9Q', 'SHEET_FILHO_QUINZENAL_V9Q', STR0007) //'Quinzenal'
    oView:AddSheet('FOLDER_FILHO_V9Q', 'SHEET_FILHO_DECENDIAL_V9Q', STR0008) //'Decendial'
    oView:AddSheet('FOLDER_FILHO_V9Q', 'SHEET_FILHO_SEMANAL_V9Q'  , STR0009) //'Semanal'
    oView:AddSheet('FOLDER_FILHO_V9Q', 'SHEET_FILHO_DIARIO_V9Q'   , STR0010) //'Diario' 

    oView:AddGrid("VIEW_V9Q_MENSAL", oStrV9Qm, "MODEL_V9Q_MENSAL")
    oView:CreateHorizontalBox('BOX_FILHO_MENSAL_V9Q', 100, , ,"FOLDER_FILHO_V9Q", "SHEET_FILHO_MENSAL_V9Q")
    oView:SetOwnerView("VIEW_V9Q_MENSAL", "BOX_FILHO_MENSAL_V9Q")

    oView:AddGrid("VIEW_V9Q_QUINZENAL", oStrV9Qp, "MODEL_V9Q_QUINZENAL")
    oView:CreateHorizontalBox('BOX_FILHO_QUINZENAL_V9Q', 100, , ,"FOLDER_FILHO_V9Q", "SHEET_FILHO_QUINZENAL_V9Q")
    oView:SetOwnerView("VIEW_V9Q_QUINZENAL", "BOX_FILHO_QUINZENAL_V9Q")

    oView:AddGrid("VIEW_V9Q_DECENDIAL", oStrV9Qp, "MODEL_V9Q_DECENDIAL")
    oView:CreateHorizontalBox('BOX_FILHO_DECENDIAL_V9Q', 100, , ,"FOLDER_FILHO_V9Q", "SHEET_FILHO_DECENDIAL_V9Q")
    oView:SetOwnerView("VIEW_V9Q_DECENDIAL", "BOX_FILHO_DECENDIAL_V9Q")

    oView:AddGrid("VIEW_V9Q_SEMANAL", oStrV9Qp, "MODEL_V9Q_SEMANAL")
    oView:CreateHorizontalBox('BOX_FILHO_SEMANAL_V9Q', 100, , ,"FOLDER_FILHO_V9Q", "SHEET_FILHO_SEMANAL_V9Q")
    oView:SetOwnerView("VIEW_V9Q_SEMANAL", "BOX_FILHO_SEMANAL_V9Q")

    oView:AddGrid("VIEW_V9Q_DIARIO", oStrV9Qp, "MODEL_V9Q_DIARIO")
    oView:CreateHorizontalBox('BOX_FILHO_DIARIO_V9Q', 100, , ,"FOLDER_FILHO_V9Q", "SHEET_FILHO_DIARIO_V9Q")
    oView:SetOwnerView("VIEW_V9Q_DIARIO", "BOX_FILHO_DIARIO_V9Q")

      
    //ABAS FILHOS DA INFOTOTALCR (V9R)
    oView:CreateHorizontalBox('BOX_FILHO_V9RA', 100, , ,"FOLDER_PERIODO_V9R","SHEET_PERIODO_V9R")
    oView:CreateFolder("FOLDER_FILHO_V9R", "BOX_FILHO_V9RA")
    oView:AddSheet('FOLDER_FILHO_V9R', 'SHEET_FILHO_MENSAL_V9R'   , STR0006) //'Mensal'
    oView:AddSheet('FOLDER_FILHO_V9R', 'SHEET_FILHO_QUINZENAL_V9R', STR0007) //'Quinzenal'
    oView:AddSheet('FOLDER_FILHO_V9R', 'SHEET_FILHO_DECENDIAL_V9R', STR0008) //'Decendial'
    oView:AddSheet('FOLDER_FILHO_V9R', 'SHEET_FILHO_SEMANAL_V9R'  , STR0009) //'Semanal'
    oView:AddSheet('FOLDER_FILHO_V9R', 'SHEET_FILHO_DIARIO_V9R'   , STR0010) //'Diario' 

    oView:AddGrid("VIEW_V9R_MENSAL", oStrV9Rm, "MODEL_V9R_MENSAL")
    oView:CreateHorizontalBox('BOX_FILHO_MENSAL_V9R', 100, , ,"FOLDER_FILHO_V9R", "SHEET_FILHO_MENSAL_V9R")
    oView:SetOwnerView("VIEW_V9R_MENSAL", "BOX_FILHO_MENSAL_V9R")

    oView:AddGrid("VIEW_V9R_QUINZENAL", oStrV9Rp, "MODEL_V9R_QUINZENAL")
    oView:CreateHorizontalBox('BOX_FILHO_QUINZENAL_V9R', 100, , ,"FOLDER_FILHO_V9R","SHEET_FILHO_QUINZENAL_V9R")
    oView:SetOwnerView("VIEW_V9R_QUINZENAL", "BOX_FILHO_QUINZENAL_V9R")

    oView:AddGrid("VIEW_V9R_DECENDIAL", oStrV9Rp, "MODEL_V9R_DECENDIAL")
    oView:CreateHorizontalBox('BOX_FILHO_DECENDIAL_V9R', 100, , ,"FOLDER_FILHO_V9R", "SHEET_FILHO_DECENDIAL_V9R")
    oView:SetOwnerView("VIEW_V9R_DECENDIAL", "BOX_FILHO_DECENDIAL_V9R")

    oView:AddGrid("VIEW_V9R_SEMANAL", oStrV9Rp, "MODEL_V9R_SEMANAL")
    oView:CreateHorizontalBox('BOX_FILHO_SEMANAL_V9R', 100, , ,"FOLDER_FILHO_V9R", "SHEET_FILHO_SEMANAL_V9R")
    oView:SetOwnerView("VIEW_V9R_SEMANAL", "BOX_FILHO_SEMANAL_V9R")

    oView:AddGrid("VIEW_V9R_DIARIO", oStrV9Rp, "MODEL_V9R_DIARIO")
    oView:CreateHorizontalBox('BOX_FILHO_DIARIO_V9R', 100, , ,"FOLDER_FILHO_V9R", "SHEET_FILHO_DIARIO_V9R")
    oView:SetOwnerView("VIEW_V9R_DIARIO", "BOX_FILHO_DIARIO_V9R")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Rafael de Paula Leme
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

    Private oBrowse	as object

    oBrowse	:= FWMBrowse():New()

    oBrowse:SetDescription(STR0011) //'R-9005 Bases e tributos - Retenções na fonte'
    oBrowse:SetAlias("V9F")
    oBrowse:SetMenuDef("TAFA606")
    oBrowse:SetFilterDefault("V9F_ATIVO == '1'")

    TAFLegReinf("V9F", oBrowse)

    oBrowse:Activate()

Return( oBrowse )
