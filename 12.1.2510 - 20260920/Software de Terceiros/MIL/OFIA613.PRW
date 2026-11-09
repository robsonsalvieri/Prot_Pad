#include 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#include 'OFIA613.ch'

#define CABECALHO 'CABECALHO'
#define CABECALHO_MODEL 'CABECALHO_MODEL'
#define CABECALHO_VIEW 'CABECALHO_VIEW'

/*/{Protheus.doc} OFIA613
	Cadastro Owner Feedback Scania
	@type  Function
	@author Paulo Alves
	@since 13/03/2026
	/*/
Function OFIA613()
	local aArea := FwGetArea()
    local oBrw613 := FWMBrowse():new()
    private oModel := nil
    private oView := nil	

	oBrw613:setAlias("VWB")
	oBrw613:setDescription(STR0001) // "Gestores de Frota"
	oBrw613:disableDetails()

	oBrw613:activate()

	fwRestArea(aArea)
Return


Static Function MenuDef()
	local aRotina := {}

    ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.OFIA613' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.OFIA613' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.OFIA613' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.OFIA613' OPERATION 5 ACCESS 0 //'Excluir'
	
Return aRotina


Static Function ModelDef()
	local oStru := FwFormStruct(1, 'VWB')

    oModel := MpFormModel():new('OFIA613')
    oModel:addFields(CABECALHO_MODEL, /*cOwner*/, oStru, /*bPre*/,/*bPost*/, /*bLoad*/ )     
	oModel:addRules(CABECALHO_MODEL, 'VWB_LOJA', CABECALHO_MODEL, 'VWB_CODCLI', 3) // pre e pos validacao

Return oModel


Static Function ViewDef()
    local oModel := FwLoadModel('OFIA613')
	local lSCANIA := getMV("MV_MIL0006") == "SCA"
    local oStru := FwFormStruct(2, 'VWB')

	if ! lSCANIA
		oStru := FwFormStruct(2, 'VWB', {|cField| cField != "VWB_COMPAR"} )
	endif

    oView := FwFormView():new()
    oView:setModel(oModel)
    oView:addField(CABECALHO_VIEW, oStru, CABECALHO_MODEL)

    oView:CreateHorizontalBox(CABECALHO, 100)
	oView:SetOwnerView(CABECALHO_VIEW, CABECALHO)
	
Return oView