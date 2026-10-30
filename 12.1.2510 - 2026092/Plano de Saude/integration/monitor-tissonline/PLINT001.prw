#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

#define UNPROCESSED "0" // Nao Processado
#define PROCESSED "1" // Processado

function PLINT001()

    local oBrowse as object

    oBrowse := FWMBrowse():new()
	oBrowse:setAlias("BKG")
	oBrowse:setDescription("Monitoramento Tiss Online")
    oBrowse:setMenuDef("PLINT001")

    oBrowse:addLegend("BKG_SITUAC == '" + UNPROCESSED +"'", "RED", "Transação não Processada")
    oBrowse:addLegend("BKG_SITUAC == '" + PROCESSED +"'", "GREEN", "Transação Processada")
    
	oBrowse:activate()

    oBrowse:destroy()
    freeObj(oBrowse)

return

static function menuDef()

    local aRotina := {} as array
    
	ADD OPTION aRotina TITLE "Visualizar Solicitação" ACTION "VIEWDEF.PLINT001" OPERATION MODEL_OPERATION_VIEW ACCESS 0

return aRotina

static function modelDef()

    local oModel as object
    local oStruBKG as object

    oStruBKG := fwFormStruct(1, "BKG")

    oModel := MPFormModel():new("PLINT001")
    oModel:setDescription("Monitoramento Tiss Online")
    oModel:addFields("BKGMASTER", nil, oStruBKG)
    oModel:getModel("BKGMASTER")
    oModel:setPrimaryKey({"BKG_FILIAL", "BKG_IDINTE"})

return oModel

static function viewDef()

	local oModel as object
	local oView as object
	local oStruBKG as object

    oStruBKG := fwFormStruct(2, "BKG")
    oStruBKG:addGroup("GENERAL_GROUP", "Dados Gerais", "1", 2)
	oStruBKG:addGroup("MESSAGES_GROUP", "Mensagens Retorno", "1", 2)
    
    oStruBKG:setProperty("*", MVC_VIEW_GROUP_NUMBER, "GENERAL_GROUP")

	oStruBKG:setProperty("BKG_SOAENV", MVC_VIEW_GROUP_NUMBER, "MESSAGES_GROUP")
	oStruBKG:setProperty("BKG_SOARET", MVC_VIEW_GROUP_NUMBER, "MESSAGES_GROUP")
    
    oModel := fwLoadModel("PLINT001")

	oView := fwFormView():new()
	oView:setModel(oModel)

	oView:addField("FORM_BKG", oStruBKG, "BKGMASTER") 
	
	oView:createHorizontalBox("BOX_FORM", 100)
	oView:setOwnerView("FORM_BKG", "BOX_FORM")
	
return oView
