#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plptu001.ch"

#define BATCH_RECEIVED "1" // Lote recebido
#define SENDING_BATCH "2" // Enviando lote
#define BATCH_WITH_ERROR "3" // Lote com erro
#define SUCCESSFULLY_COMPLETED "4" // Finalizado com sucesso
#define SUCCESSFULLY_PARTIALLY "5" // Finalizado Parcialmente

/*/{Protheus.doc} PLPTU001
Browser com os lotes dos beneficiários a serem enviados para o CadBenef
@type function
@version 12.1.2410 
@author vinicius.queiros
@since 21/05/2024
/*/
function PLPTU001()

	local oBrowse as object

	oBrowse := FWMBrowse():new()
	oBrowse:setAlias("BPW")
	oBrowse:setDescription(STR0001) // "CadBenef Online - Movimentação Cadastral"
	oBrowse:setMenuDef("PLPTU001")

	oBrowse:addLegend("BPW_STATUS == '" + BATCH_RECEIVED +"'", "WHITE", STR0002) // "Recebido"
	oBrowse:addLegend("BPW_STATUS == '" + SENDING_BATCH +"'", "BLUE", STR0003) // "Processando envio"
	oBrowse:addLegend("BPW_STATUS == '" + BATCH_WITH_ERROR +"'", "RED", STR0004) // "Falha de envio"
	oBrowse:addLegend("BPW_STATUS == '" + SUCCESSFULLY_COMPLETED +"'", "GREEN", STR0005) // "Finalizado com sucesso"
	oBrowse:addLegend("BPW_STATUS == '" + SUCCESSFULLY_PARTIALLY +"'", "YELLOW", STR0006) // "Finalizado parcialmente"

	oBrowse:activate()

	oBrowse:destroy()
	freeObj(oBrowse)

return

/*/{Protheus.doc} menuDef
Menu do browser dos lotes do CadBenef Online
@type function
@version 12.1.2410
@author vinicius.queiros
@since 21/05/2024
@return array, lista de menus do browser (aRotina)
/*/
static function menuDef() as array

	local aRotina := {} as array
	local cSendBatchFunction as character
	local cShowBatchStatusFunction as character
	local cErrorsReportFunction as character
	local cDeleteBatchFunction as character

	cSendBatchFunction := "fwMsgRun(nil, {|| totvs.protheus.health.plan.unimed.cadBenefSendBatch()}, '', '" + STR0007 + "')" // "Processando envio do lote ..."
	cShowBatchStatusFunction := "totvs.protheus.health.plan.unimed.showBatchStatus(BPW->BPW_CODIGO)"
	cErrorsReportFunction := "fwMsgRun(nil, {|| totvs.protheus.health.plan.unimed.cadBenefErrorsReport()}, '', '" + STR0008 + "')" // "Exportando erros do lote ..."
	cDeleteBatchFunction := "fwMsgRun(nil, {|| totvs.protheus.health.plan.unimed.cadBenefDeleteBatch(BPW->BPW_CODIGO)}, '', '" + STR0009 + "')" // "Excluindo lote ..."

	ADD OPTION aRotina TITLE STR0010 ACTION "PLPTU002" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Consultar Beneficiários"
	ADD OPTION aRotina TITLE STR0011 ACTION "VIEWDEF.PLPTU001" OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Consultar Lote"
	ADD OPTION aRotina TITLE STR0012 ACTION "VIEWDEF.PLPTU001" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Novo Lote"
	ADD OPTION aRotina TITLE STR0013 ACTION cSendBatchFunction OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Enviar Lote"
	ADD OPTION aRotina TITLE STR0014 ACTION cDeleteBatchFunction OPERATION MODEL_OPERATION_DELETE ACCESS 0 // "Excluir Lote"
	ADD OPTION aRotina TITLE STR0015 ACTION cShowBatchStatusFunction OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Consultar Status"
	ADD OPTION aRotina TITLE STR0016 ACTION cErrorsReportFunction OPERATION MODEL_OPERATION_VIEW ACCESS 0 // "Exportar Erros"
	ADD OPTION aRotina TITLE STR0023 ACTION "PLPTU001SCH" OPERATION MODEL_OPERATION_INSERT ACCESS 0 // "Agendamento"

return aRotina

/*/{Protheus.doc} modelDef
Modelo de dados para incluir, alterar e excluir os lotes do CadBenef.
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 21/05/2024
@return object, objeto da instância do modelo
/*/
static function modelDef() as object

	local oModel as object
	local oStruBPW as object
	local oEvent := totvs.protheus.health.plan.unimed.CadBenefEventBatch():new() as object

	oStruBPW := fwFormStruct(1, "BPW")

	oModel := MPFormModel():new("PLPTU001")
	oModel:setDescription(STR0017) // "Movimentação cadastral de beneficiários"
	oModel:addFields("BPWMASTER", nil, oStruBPW)
	oModel:getModel("BPWMASTER"):setDescription(STR0018) // "Configuração do envio dos beneficiários"
	oModel:setPrimaryKey({"BPW_FILIAL", "BPW_CODIGO"})

	oModel:installEvent("CadBenefEventBatch", /*cOwner*/, oEvent)

return oModel

/*/{Protheus.doc} viewDef
Interface (View) para incluir, alterar e excluir os lotes do CadBenef.
@type function
@version 12.1.2410  
@author vinicius.queiros
@since 21/05/2024
@return object, objeto da instância da interface
/*/
static function viewDef() as object

	local oModel as object
	local oView as object
	local oStruBPW as object

	oStruBPW := fwFormStruct(2, "BPW")

	oModel := fwLoadModel("PLPTU001")

	oView := FWFormView():new()
	oView:setModel(oModel)

	oView:addField("FORM_BPW", oStruBPW, "BPWMASTER")

	oView:createHorizontalBox("BOX_FORM", 100)
	oView:setOwnerView("FORM_BPW", "BOX_FORM")

	oView:setInsertMessage("", STR0021) // "Lote incluído com sucesso."
	oView:setDeleteMessage("", STR0022) // "Lote excluído com sucesso."

return oView

/*/{Protheus.doc} PLPTU001SCH
Executa o novo schedule para agendamento do lote do CadBenef
@type function
@version 12.1.2510
@author vinicius.queiros
@since 18/10/2024
/*/
function PLPTU001SCH()

	if findFunction("callSchedule")
		callSchedule('PLSSCH001')
	else
		fwAlertWarning(STR0024, "") // "Agendamento disponível a partir do release 12.1.2410, para lib 20240520 ou superior. Contate o administrador do sistema"
	endif

return
