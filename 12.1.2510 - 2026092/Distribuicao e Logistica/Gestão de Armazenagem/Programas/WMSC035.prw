#INCLUDE "WMSC035.CH"  
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
/*--------------------------------------------------------------------------------
---WMSC035
---Consulta de Saldo por Endereço WMS (D14)
---Amanda Rosa Vieira - 30/09/2015
----------------------------------------------------------------------------------*/
Function WMSC035()
Private oBrowse

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"3")
		Return Nil
	EndIf
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("D14") // Alias da tabela utilizada
	oBrowse:SetMenuDef(STR0001) // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0002)	// Descrição do browse  
	
	oBrowse:Activate()
Return .T.

Static Function MenuDef()

Local aRotina := {}                                    
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina  TITLE  STR0003  ACTION  "VIEWDEF.WMSC035"  OPERATION 2  ACCESS 0 // Visualizar
Return aRotina  

Static Function ModelDef()
Local oModel
Local oStructD14 := FWFormStruct(1,"D14")
	
	oModel := MPFormModel():New("WMSC035", /*bPre*/, /* bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields("WMSC035_D14", Nil, oStructD14,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"D14_FILIAL", "D14_LOCAL","D14_ENDER","D14_PRODUT","D14_LOTECT","D14_NUMLOT","D14_NUMSER"})
Return oModel

Static Function ViewDef()
Local oModel     := FWLoadModel("WMSC035")
Local oView      := Nil
Local oStructD14 := FWFormStruct(2, "D14")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("WMSC035_D14" , oStructD14, /*cLinkID*/ )	//
	oView:CreateHorizontalBox("MASTER" , 100 )
	
	// Associa um View a um box
	oView:SetOwnerView("WMSC035_D14" , "MASTER")
Return oView

