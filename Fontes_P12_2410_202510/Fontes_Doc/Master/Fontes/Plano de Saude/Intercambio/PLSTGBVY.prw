#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} PLSTGBVY
Cadastro TAG A500
@type function
@version 12.1.2410
@author claudiol
@since 2/12/2025
/*/
Function PLSTGBVY()

    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias('BVY')
    oBrowse:SetDescription('TAG A500')
    oBrowse:Activate()
    
Return Nil


/*/{Protheus.doc} MenuDef
Menudef
@type function
@version 12.1.2410
@author claudiol
@since 2/12/2025
@return array, aRotina
/*/
Static Function MenuDef()

    Local aRotina := {}

    Add Option aRotina Title 'Pesquisar'  	Action 'PesqBrw'           	Operation 1 Access 0
    Add Option aRotina Title 'Visualizar' 	Action 'VIEWDEF.PLSTGBVY' 	Operation 2 Access 0
    Add Option aRotina Title 'Incluir'    	Action 'VIEWDEF.PLSTGBVY' 	Operation 3 Access 0
    Add Option aRotina Title 'Alterar'    	Action 'VIEWDEF.PLSTGBVY' 	Operation 4 Access 0
    Add Option aRotina Title 'Excluir'    	Action 'VIEWDEF.PLSTGBVY' 	Operation 5 Access 0
    Add Option aRotina Title 'Imprimir'  	Action 'VIEWDEF.PLSTGBVY' 	Operation 8 Access 0
    
Return aRotina


/*/{Protheus.doc} ModelDef
Modelo de dados
@type function
@version 12.1.2410
@author claudiol
@since 2/12/2025
@return object, oModel
/*/
Static Function ModelDef()

    Local oModel   := MPFormModel():New('PLSTGBVY',/*bPreValidacao*/,/*bValidacao*/,/*bCommit*/,/*bCancel*/)
    Local oStruBVY := FwFormStruct(1,'BVY')

    oModel:AddFields("BVYMASTER",/*Owner*/  ,oStruBVY        ,/*bPre*/,,)
	oModel:getModel('BVYMASTER')
	oModel:SetDescription(Fundesc())
    oModel:SetPrimaryKey({"BVY_FILIAL","BVY_TAG550"})

Return oModel


/*/{Protheus.doc} ViewDef
Definição da interface
@type function
@version 12.1.2410
@author claudiol
@since 2/12/2025
@return object, oView
/*/
Static Function ViewDef()

    Local oModel   := FwLoadModel("PLSTGBVY")
    Local oStruBVY := FWFormStruct(2,'BVY')
    Local oView    := FwFormView():New()

    oView:SetModel(oModel) 
    oView:AddField('VWBVYMASTER',oStruBVY,'BVYMASTER')
    oView:CreateHorizontalBox('SUPERIOR',100)
    oView:SetOwnerView('VWBVYMASTER','SUPERIOR')

Return oView
