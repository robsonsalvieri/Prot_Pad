#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GFEA039()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GUO")
	oBrowse:SetMenuDef("GFEA039")
	oBrowse:SetDescription("Observações Contrato de Transporte")
	
	oBrowse:Activate()
Return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "AxPesqui"        	OPERATION 1  ACCESS 0  	// "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.GFEA039" 	OPERATION 2  ACCESS 0  	// "Visualizar"
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.GFEA039" 	OPERATION 3  ACCESS 0  	// "Incluir"
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.GFEA039" 	OPERATION 4  ACCESS 0  	// "Alterar"
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.GFEA039" 	OPERATION 5  ACCESS 0  	// "Excluir"
	ADD OPTION aRotina TITLE "Copiar" 		ACTION "VIEWDEF.GFEA039"	OPERATION 9  ACCESS 0  	// "Copiar"
	ADD OPTION aRotina TITLE "Imprimir" 	ACTION "VIEWDEF.GFEA039" 	OPERATION 8  ACCESS 0   // "Imprimir"
Return aRotina

Static Function ModelDef()
	Local oModel

	oModel := MPFormModel():New("GFEA039", /* */, /* */, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEA039_GUO", Nil, FWFormStruct(1,"GUO"),/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GUO_FILIAL", "GUO_CODOBS"})
	oModel:SetDescription("Observação Contrato Transporte")
Return oModel

Static Function ViewDef()
	Local oModel  	 := FWLoadModel("GFEA039")
	Local oStruct 	 := FWFormStruct(2,"GUO")
	Local oView   	 := Nil
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	oView:AddField( "GFEA039_GUO" , oStruct, /*cLinkID*/ )
Return oView