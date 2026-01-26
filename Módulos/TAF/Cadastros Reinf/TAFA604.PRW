#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA604.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA604
Cadastro MVC - R-9005 - Bases e tributos - retenções na fonte

@author Wesley Matos
@since 06/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA604()

If TAFAlsInDic( "V9D" ) .And. TAFAlsInDic( "V9G" )
	BrowseDef()
Else
	Aviso( "TAF", STR0002 , { STR0015 }, 2 ) //'Ambiente desatualizado. Rotina não disponível' "Encerrar"
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Wesley Matos
@since 06/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina	as array

aRotina	:= {}

ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.TAFA604" OPERATION 2 ACCESS 0 //"Visualizar"

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Wesley Matos
@since 06/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV9D as object
Local oStruV9G as object
Local oModel   as object

oStruV9D := FWFormStruct( 1, 'V9D' )
oStruV9G := FWFormStruct( 1, 'V9G' )

oModel	 := MPFormModel():New('TAFA604')

oModel:AddFields('MODEL_V9D',,oStruV9D)
oModel:GetModel('MODEL_V9D'):SetPrimaryKey({'V9D_FILIAL','V9D_ID','V9D_VERSAO'})

oModel:addgrid('MODEL_V9G_MENSAL','MODEL_V9D', oStruV9G)
oModel:GetModel("MODEL_V9G_MENSAL"):SetUniqueLine({'V9G_TPPER','V9G_PERTRB','V9G_CR','V9G_NATREN'})
oModel:GetModel("MODEL_V9G_MENSAL"):SetLoadFilter({{'V9G_TPPER',"'1'"}})
oModel:GetModel("MODEL_V9G_MENSAL"):SetOptional(.T.)
oModel:SetRelation("MODEL_V9G_MENSAL",{{"V9G_FILIAL","xFilial('V9G')"},{"V9G_ID","V9D_ID"},{"V9G_VERSAO","V9D_VERSAO"}},V9G->(IndexKey(1)))

oModel:addgrid('MODEL_V9G_QUINZENAL','MODEL_V9D', oStruV9G)
oModel:GetModel("MODEL_V9G_QUINZENAL"):SetUniqueLine({'V9G_TPPER','V9G_PERTRB','V9G_CR','V9G_NATREN'})
oModel:GetModel("MODEL_V9G_QUINZENAL"):SetLoadFilter({{'V9G_TPPER',"'2'"}})
oModel:GetModel("MODEL_V9G_QUINZENAL"):SetOptional(.T.)
oModel:SetRelation("MODEL_V9G_QUINZENAL",{{"V9G_FILIAL","xFilial('V9G')"},{"V9G_ID","V9D_ID"},{"V9G_VERSAO","V9D_VERSAO"}},V9G->(IndexKey(1)))

oModel:addgrid('MODEL_V9G_DECENDIAL','MODEL_V9D', oStruV9G)
oModel:GetModel("MODEL_V9G_DECENDIAL"):SetUniqueLine({'V9G_TPPER','V9G_PERTRB','V9G_CR','V9G_NATREN'})
oModel:GetModel("MODEL_V9G_DECENDIAL"):SetLoadFilter({{'V9G_TPPER',"'3'"}})
oModel:GetModel("MODEL_V9G_DECENDIAL"):SetOptional(.T.)
oModel:SetRelation("MODEL_V9G_DECENDIAL",{{"V9G_FILIAL","xFilial('V9G')"},{"V9G_ID","V9D_ID"},{"V9G_VERSAO","V9D_VERSAO"}},V9G->(IndexKey(1)))

oModel:addgrid('MODEL_V9G_SEMANAL','MODEL_V9D', oStruV9G)
oModel:GetModel("MODEL_V9G_SEMANAL"):SetUniqueLine({'V9G_TPPER','V9G_PERTRB','V9G_CR','V9G_NATREN'})
oModel:GetModel("MODEL_V9G_SEMANAL"):SetLoadFilter({{'V9G_TPPER',"'4'"}})
oModel:GetModel("MODEL_V9G_SEMANAL"):SetOptional(.T.)
oModel:SetRelation("MODEL_V9G_SEMANAL",{{"V9G_FILIAL","xFilial('V9G')"},{"V9G_ID","V9D_ID"},{"V9G_VERSAO","V9D_VERSAO"}},V9G->(IndexKey(1)))

oModel:addgrid('MODEL_V9G_DIARIO','MODEL_V9D', oStruV9G)
oModel:GetModel("MODEL_V9G_DIARIO"):SetUniqueLine({'V9G_TPPER','V9G_PERTRB','V9G_CR','V9G_NATREN'})
oModel:GetModel("MODEL_V9G_DIARIO"):SetLoadFilter({{'V9G_TPPER',"'5'"}})
oModel:GetModel("MODEL_V9G_DIARIO"):SetOptional(.T.)
oModel:SetRelation("MODEL_V9G_DIARIO",{{"V9G_FILIAL","xFilial('V9G')"},{"V9G_ID","V9D_ID"},{"V9G_VERSAO","V9D_VERSAO"}},V9G->(IndexKey(1)))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Wesley Matos
@since 06/09/2022

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

local oView    as object
local oModel   as object
local oStrV9D as object
local oStrV9DR as object
local oStrV9Gm  as object
local oStrV9Gp  as object
local cCmpFil  as character

oView   := FWFormView():new()
oModel  := FWLoadModel('TAFA604')

//Informações de retorno
cCmpFil  := "V9D_PERAPU|V9D_DTPROC|V9D_HRPROC|V9D_TPEVEN|V9D_IDEVEN|V9D_HASH|V9D_TPINSE|V9D_NRINSE|V9D_NRINSB|V9D_NMBENE|"
If TAFColumnPos( "V9D_EVADIC" ) // Reinf 2.1.2
	cCmpFil += 'V9D_EVADIC|V9D_DTRECE|V9D_HRRECE|'
Endif
oStrV9D := FwFormStruct( 2, "V9D", {|x| AllTrim(x) + "|" $ cCmpFil } )

//Recibo
cCmpFil  := "V9D_PROTUL|"
oStrV9DR := FwFormStruct( 2, "V9D", {|x| AllTrim(x) + "|" $ cCmpFil } )


//periodo mensal
cCmpFil  := "V9G_CR|V9G_BASECR|V9G_BSUSCR|V9G_NATREN|V9G_VINFO|V9G_VCALC|V9G_VSUSPI|V9G_VSUSPC|"
oStrV9Gm  := FwFormStruct(2,"V9G",{|x| AllTrim(x) + "|" $ cCmpFil })

//outros periodos
cCmpFil  := "V9G_PERTRB|V9G_CR|V9G_BASECR|V9G_BSUSCR|V9G_NATREN|V9G_VINFO|V9G_VCALC|V9G_VSUSPI|V9G_VSUSPC|"
oStrV9Gp  := FwFormStruct(2,"V9G",{|x| AllTrim(x) + "|" $ cCmpFil })

oView:SetModel( oModel )
oView:SetContinuousForm(.F.)

oView:CreateHorizontalBox( 'BOXH_MASTER', 100)
oView:CreateFolder("FOLDER_MASTER","BOXH_MASTER")
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_MASTER', STR0003 ) //'Informações do Retorno'
oView:AddSheet( 'FOLDER_MASTER', 'SHEET_PROTUL', STR0004 ) //"Recibo"

oView:AddField("VIEW_V9DA", oStrV9D, "MODEL_V9D" )
oView:CreateHorizontalBox("PAINEL_SUPERIORA", 30,,,"FOLDER_MASTER","SHEET_MASTER" )
oView:SetOwnerView( "VIEW_V9DA", "PAINEL_SUPERIORA" )

oView:AddField("VIEW_V9DR", oStrV9DR, "MODEL_V9D" )
oView:EnableTitleView("VIEW_V9DR", STR0004) //"Recibo"
oView:CreateHorizontalBox("PAINEL_SUPERIORR", 100,,,"FOLDER_MASTER","SHEET_PROTUL" )
oView:SetOwnerView( "VIEW_V9DR", "PAINEL_SUPERIORR" )

//GRID FILHO
oView:CreateHorizontalBox( 'BOX_FILHO', 70,,,"FOLDER_MASTER","SHEET_MASTER")
oView:CreateFolder("FOLDER_FILHO","BOX_FILHO")
oView:AddSheet( 'FOLDER_FILHO', 'SHEET_V9G', STR0005 ) //"Períodos"

//ABAS FILHOS DA V9G
oView:CreateHorizontalBox( 'BOX_FILHO_V9GA', 100,,,"FOLDER_FILHO","SHEET_V9G")
oView:CreateFolder("FOLDER_FILHO_V9G","BOX_FILHO_V9GA")
oView:AddSheet( 'FOLDER_FILHO_V9G', 'SHEET_FILHO_MENSAL', STR0006 ) //'Mensal'
oView:AddSheet( 'FOLDER_FILHO_V9G', 'SHEET_FILHO_QUINZENAL', STR0007 ) //'Quinzenal'
oView:AddSheet( 'FOLDER_FILHO_V9G', 'SHEET_FILHO_DECENDIAL', STR0008 ) //'Decendial'
oView:AddSheet( 'FOLDER_FILHO_V9G', 'SHEET_FILHO_SEMANAL', STR0009 ) //'Semanal'
oView:AddSheet( 'FOLDER_FILHO_V9G', 'SHEET_FILHO_DIARIO', STR0010 ) //'Diario' 

oView:AddGrid("VIEW_V9G_MENSAL", oStrV9Gm,"MODEL_V9G_MENSAL" )
oView:CreateHorizontalBox( 'BOX_FILHO_MENSAL', 100,,,"FOLDER_FILHO_V9G","SHEET_FILHO_MENSAL")
oView:SetOwnerView( "VIEW_V9G_MENSAL", "BOX_FILHO_MENSAL" )

oView:AddGrid("VIEW_V9G_QUINZENAL", oStrV9Gp,"MODEL_V9G_QUINZENAL" )
oView:CreateHorizontalBox( 'BOX_FILHO_QUINZENAL', 100,,,"FOLDER_FILHO_V9G","SHEET_FILHO_QUINZENAL")
oView:SetOwnerView( "VIEW_V9G_QUINZENAL", "BOX_FILHO_QUINZENAL" )

oView:AddGrid("VIEW_V9G_DECENDIAL", oStrV9Gp,"MODEL_V9G_DECENDIAL" )
oView:CreateHorizontalBox( 'BOX_FILHO_DECENDIAL', 100,,,"FOLDER_FILHO_V9G","SHEET_FILHO_DECENDIAL")
oView:SetOwnerView( "VIEW_V9G_DECENDIAL", "BOX_FILHO_DECENDIAL" )

oView:AddGrid("VIEW_V9G_SEMANAL", oStrV9Gp,"MODEL_V9G_SEMANAL" )
oView:CreateHorizontalBox( 'BOX_FILHO_SEMANAL', 100,,,"FOLDER_FILHO_V9G","SHEET_FILHO_SEMANAL")
oView:SetOwnerView( "VIEW_V9G_SEMANAL", "BOX_FILHO_SEMANAL" )

oView:AddGrid("VIEW_V9G_DIARIO", oStrV9Gp,"MODEL_V9G_DIARIO" )
oView:CreateHorizontalBox( 'BOX_FILHO_DIARIO', 100,,,"FOLDER_FILHO_V9G","SHEET_FILHO_DIARIO")
oView:SetOwnerView( "VIEW_V9G_DIARIO", "BOX_FILHO_DIARIO" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Karen Honda
@since 12/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()

Private oBrowse	as object

oBrowse	:=	FWMBrowse():New()

oBrowse:SetDescription( STR0011 ) //'R-9005 Bases e tributos - Retenções na fonte'
oBrowse:SetAlias( "V9D" )
oBrowse:SetMenuDef( "TAFA604" )
oBrowse:SetFilterDefault( "V9D_ATIVO == '1'" )

TAFLegReinf( "V9D", oBrowse)

oBrowse:Activate()

Return( oBrowse )
