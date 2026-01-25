#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plcto001.ch"

#define STATUS_RECEIVED "1"
#define STATUS_PROCESSING "2"
#define STATUS_IMPORTED_WITH_ERRORS "3"
#define STATUS_IMPORT_COMPLETED "4"
#define STATUS_CANCELLED "5"

#define STATUS_BENEF_RECEIVED "1"
#define STATUS_BENEF_IMPORTED_WITH_ERROR "2"
#define STATUS_BENEF_IMPORTED_SUCCESSFULLY "3"
#define STATUS_BENEF_CANCELED "4"

/*/{Protheus.doc} PLCTO001
Executa a importação em lote de beneficiários na Analise de Beneficiários (PLSA977AB)
@type function
@version 12.1.2510
@author vinicius.queiros
@since 22/05/2025
/*/
function PLCTO001()

	local oBrowse as object

	oBrowse := FWMBrowse():new()
	oBrowse:setAlias("BJ5")
	oBrowse:setDescription(STR0001) // "Lotes de Importação de Beneficiários"
	oBrowse:setMenuDef("PLCTO001")

	oBrowse:addLegend("BJ5_STATUS == '" + STATUS_RECEIVED + "'", "LBLUE", STR0002) // "Recebido"
	oBrowse:addLegend("BJ5_STATUS == '" + STATUS_PROCESSING + "'", "ORANGE", STR0003) // "Em Processamento"
	oBrowse:addLegend("BJ5_STATUS == '" + STATUS_IMPORTED_WITH_ERRORS + "'", "RED", STR0004) // "Importado com Erro"
	oBrowse:addLegend("BJ5_STATUS == '" + STATUS_IMPORT_COMPLETED + "'", "GREEN", STR0005) // "Importação Concluída"
	oBrowse:addLegend("BJ5_STATUS == '" + STATUS_CANCELLED + "'", "GRAY", STR0006) // "Cancelado"

	oBrowse:activate()

	oBrowse:destroy()
	freeObj(oBrowse)

return

/*/{Protheus.doc} menuDef
Retorna a definição do menu da rotina
@type function
@version 12.1.2510
@author vinicius.queiros
@since 22/05/2025
@return array, definição do menu da rotina
/*/
static function menuDef() as array

	local aMenu := {} as array

	ADD OPTION aMenu TITLE STR0007 ACTION "VIEWDEF.PLCTO001" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Visualizar"

return aMenu

/*/{Protheus.doc} modelDef
Retorna a definição do modelo de dados (MVC) da importação de beneficiários
@type function
@version 12.1.2510
@author vinicius.queiros
@since 22/05/2025
@return object, objeto modelDef
/*/
static function modelDef() as object

	local oModel as object
	local oStruBJ5 := fwFormStruct(1, "BJ5") as object
	local oStruBJ6 := fwFormStruct(1, "BJ6") as object

	oStruBJ6:addField("", "", "BJ6_LEGEND", "C", 50, 0, nil, nil, {}, .F., {|| getStatusColor(BJ6->BJ6_STATUS)}, .F., nil, .T.)

	oModel := MPFormModel():new("PLCTO001")
	oModel:setDescription(STR0001) // "Lotes de Importação de Beneficiários"

	oModel:addFields("BJ5MASTER", nil, oStruBJ5)
	oModel:addGrid("BJ6DETAIL", "BJ5MASTER", oStruBJ6)

	oModel:setRelation("BJ6DETAIL", {{"BJ6_FILIAL", "xFilial('BJ6')"},;
									 {"BJ6_CODLOT", "BJ5_CODLOT"}},;
									  BJ6->(IndexKey(1)))

	oModel:getModel("BJ5MASTER"):setDescription(STR0009) // "Detalhes da Importação"
	oModel:getModel("BJ6DETAIL"):setDescription(STR0008) // "Beneficiários do Arquivo"
	oModel:getModel("BJ6DETAIL"):setMaxLine(999999)

	oModel:getModel("BJ6DETAIL"):setOptional(.T.)

return oModel

/*/{Protheus.doc} viewDef
Retorna a definição da tela (visualização) da importação de beneficiários
@type function
@version 12.1.2510
@author vinicius.queiros
@since 22/05/2025
@return object, objeto viewDef
/*/
static function viewDef() as object

	local oView as object
	local oModel := fwLoadModel("PLCTO001") as object
	local oStruBJ5 := fwFormStruct(2, "BJ5") as object
	local oStruBJ6 := fwFormStruct(2, "BJ6") as object

	oStruBJ6:AddField("BJ6_LEGEND", "00", "", "", nil, "C", "@BMP", nil, nil, .T., nil, nil, nil, nil, nil, .T., nil, nil)

	oView := FWFormView():new()

	oView:setModel(oModel)

	oStruBJ6:removeField("BJ6_CODLOT")

	oView:addField("FORM_BJ5", oStruBJ5, "BJ5MASTER")
	oView:addGrid("GRID_BJ6", oStruBJ6, "BJ6DETAIL")

	oView:enableTitleView("GRID_BJ6", STR0008) // "Beneficiários do Arquivo"

	oView:createHorizontalBox("BOX_FORM", 40)
	oView:createHorizontalBox("BOX_GRID", 60)

	oView:setOwnerView("FORM_BJ5", "BOX_FORM")
	oView:setOwnerView("GRID_BJ6", "BOX_GRID")

	oView:addUserButton(STR0010, "", {|| msDocument("BJ5", BJ5->(recno()), MODEL_OPERATION_VIEW)}, nil, nil, nil, .T.) // "Arquivo"

return oView

/*/{Protheus.doc} getStatusColor
Retorna a cor correspondente ao status informado do beneficiário
@type function
@version 12.1.2510
@author vinicius.queiros
@since 13/06/2025
@param cStatus, character, status do beneficiário a ser avaliado
@return character, cor correspondente ao status informado
/*/
static function getStatusColor(cStatus as character) as character

	local cColor := "" as character

	do case
		case cStatus == STATUS_BENEF_RECEIVED
			cColor := "BR_AZUL_CLARO"

		case cStatus == STATUS_BENEF_IMPORTED_WITH_ERROR
			cColor := "BR_VERMELHO"

		case cStatus == STATUS_BENEF_IMPORTED_SUCCESSFULLY
			cColor := "BR_VERDE"

		case cStatus == STATUS_BENEF_CANCELED
			cColor := "BR_CINZA"	
	endcase

return cColor
