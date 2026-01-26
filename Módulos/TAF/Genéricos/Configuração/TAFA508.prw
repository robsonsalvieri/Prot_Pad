#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA508
Cadastro MVC Log alteração automática do protocolo - LOG TSS      

@author Ronaldo Tapia
@since 05/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA508()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription("Log alteração automática do protocolo") //"Log alteração via JOB do protocolo"
oBrw:SetAlias("V1X")
oBrw:SetMenuDef("TAFA508")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Ronaldo Tapia
@since 05/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title "Visualizar"	Action 'VIEWDEF.TAFA508' 	OPERATION 2 ACCESS 0 		//"Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Ronaldo Tapia
@since 05/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruVIX := FwFormStruct(1,"V1X")
Local oModel   := MpFormModel():New("TAFA508")

oModel:AddFields("MODEL_V1X",/*cOwner*/,oStruVIX)
oModel:GetModel("MODEL_V1X"):SetPrimaryKey({'V1X_FILIAL','V1X_ID'})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Ronaldo Tapia
@since 05/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA508")
Local oStruVIX := FwFormStruct(2,"V1X")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_V1X",oStruVIX,"MODEL_V1X")
oView:CreateHorizontalBox( 'FIELDV1X', 100 )
oView:EnableTitleView("VIEW_V1X","Log alteração automática do recibo de protocolo") //"Log alteração automática do recibo de protocolo"
oView:SetOwnerView( 'VIEW_V1X', 'FIELDV1X' )

Return(oView)