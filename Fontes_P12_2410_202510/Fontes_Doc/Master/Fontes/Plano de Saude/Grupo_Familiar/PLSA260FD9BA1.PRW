#include "protheus.ch"
#include "fwmvcdef.ch"
#include "plsa260fd9ba1.ch"

#define FOLDER_PLANO "3"

/*/{Protheus.doc} modelDef
Modelo de dados do folder dados do plano do beneficiário

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 28/07/2023
@return object, retorna o modelo de dados criado
@obs Para utilizar o modelo de dados é necessário está com o registro da BA1, BA3 posicionado
/*/
static function modelDef()

	local oModel as object
	local cFixedFields := "BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_NOMUSR" as character
	local oStruBA1 := fwFormStruct(1, "BA1", { |cField| getSx3Cache(cField, "X3_FOLDER") == FOLDER_PLANO .or. alltrim(cField) $ cFixedFields}) as object
	local oStruBA3 := fwFormStruct(1, "BA3") as object
	local oEventBA1 := PLGFBA1Event():new() as object

	oStruBA1 := PLAddFldStruct(1, oStruBA1, {"BA1_MATRIC"}, .t.)
	oStruBA3:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)	

	oModel := MPFormModel():new("PLSA260FD9BA1")	
	oModel:addFields("BA1MASTER", nil, oStruBA1)
	oModel:addFields("BA3MASTER", "BA1MASTER", oStruBA3)

	oModel:setRelation("BA3MASTER", {{"BA3_FILIAL", "xFilial('BA3')"},; 
                                     {"BA3_MATRIC", "BA1_CODINT"},;
									 {"BA3_CODEMP", "BA1_CODEMP"},;
                                     {"BA3_MATRIC", "BA1_MATRIC"}},;
                                     BA3->(indexKey(1)))
	
	oModel:getModel("BA3MASTER"):setOnlyView(.t.)
    oModel:getModel("BA3MASTER"):setOnlyQuery(.t.)
									
    oModel:setDescription("Dados cadastrais do beneficiário - Dados do Plano")

	oModel:getModel("BA1MASTER"):setDescription("Dados do Plano do Beneficiario")
	oModel:getModel("BA3MASTER"):setDescription("Dados da Família")
		
	oModel:setPrimaryKey({})

	oModel:installEvent("PLGFBA1Event", /*cOwner*/, oEventBA1)

return oModel

/*/{Protheus.doc} viewDef
Tela de visualização dos dados do plano do beneficiário

@type function
@version Protheus 12.1.2310 
@author vinicius.queiros
@since 28/07/2023
@return object, retorna a tela de visualização do modelo de dados criado
/*/
static function viewDef() 

	local oView as object
	local cFixedFields := "BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_NOMUSR" as character
	local oStruBA1 := fwFormStruct(2, "BA1", { |cField| getSx3Cache(cField, "X3_FOLDER") == FOLDER_PLANO .or. alltrim(cField) $ cFixedFields}) as object
	local oModel := fwLoadModel("PLSA260FD9BA1") as object

	oStruBA1 := PLAddFldStruct(2, oStruBA1, {"BA1_MATRIC"}, .t.)
	
	oStruBA1:setProperty("BA1_CODINT", MVC_VIEW_CANCHANGE, .f.)
	oStruBA1:setProperty("BA1_CODEMP", MVC_VIEW_CANCHANGE, .f.)
	oStruBA1:setProperty("BA1_MATRIC", MVC_VIEW_CANCHANGE, .f.)
	oStruBA1:setProperty("BA1_TIPREG", MVC_VIEW_CANCHANGE, .f.)
	oStruBA1:setProperty("BA1_DIGITO", MVC_VIEW_CANCHANGE, .f.)
	oStruBA1:setProperty("BA1_NOMUSR", MVC_VIEW_CANCHANGE, .f.)
	oStruBA1:setNoFolder()

	oStruBA1:addGroup("BENEFGROUP", STR0001, "1", 2) // "Beneficiário"
	oStruBA1:addGroup("PLANGROUP", STR0002, "1", 2) // "Dados do Plano"

	oStruBA1:setProperty("*", MVC_VIEW_GROUP_NUMBER, "PLANGROUP")
	oStruBA1:setProperty("BA1_CODINT", MVC_VIEW_GROUP_NUMBER, "BENEFGROUP")
	oStruBA1:setProperty("BA1_CODEMP", MVC_VIEW_GROUP_NUMBER, "BENEFGROUP")
	oStruBA1:setProperty("BA1_MATRIC", MVC_VIEW_GROUP_NUMBER, "BENEFGROUP")
	oStruBA1:setProperty("BA1_TIPREG", MVC_VIEW_GROUP_NUMBER, "BENEFGROUP")
	oStruBA1:setProperty("BA1_DIGITO", MVC_VIEW_GROUP_NUMBER, "BENEFGROUP")
	oStruBA1:setProperty("BA1_NOMUSR", MVC_VIEW_GROUP_NUMBER, "BENEFGROUP")

	oView := FWFormView():new()
	oView:setModel(oModel)

    oView:addField("VIEWBA1", oStruBA1, "BA1MASTER")
	oView:createHorizontalBox("CONTENT", 100) 
	oView:setOwnerView("VIEWBA1", "CONTENT")
		
return oView

/*/{Protheus.doc} PlGfWhMsReaj
When do campo mês de reajuste (BA1_MESREA) no cadastro do beneficiário

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 31/07/2023
@return lEdit, retorna se o campo poderá sofrer edição
/*/
function PlGfWhMsReaj()

	local lEdit := PFldGetBA3("BA3_TIPOUS") == "1" .or. getNewpar("MV_PLREAPJ", "2") == "1"

return lEdit 

/*/{Protheus.doc} PlGfExiEqp
Valida a equipe e os vendedores no cadastro do beneficiário/família

@type function
@version Protheus 12.1.2310
@author vinicius.queiros
@since 31/07/2023
@param cTeamCode, character, código da equipe
@param aSellers, array, lista de vendedores que faz parte da equipe
@return lCheck, retorna se a equipe e os vendedores estão válidos
@obs function baseada na PLS260EQP
/*/
function PlGfExiEqp(cTeamCode, cSeller1, cSeller2)

	local lCheck := .t. as logical

	if !empty(cTeamCode)
		BXL->(dbSetOrder(1))
		if BXL->(msSeek(xFilial("BXL")+cTeamCode))
			BXM->(dbSetOrder(1))
			if !BXM->(msSeek(xFilial("BXM")+BXL->BXL_SEQ))
				help("", 1, "PLS260EQP1")
				lCheck := .f.
			else
				do case
					case !empty(cSeller1) .and. !BXM->(msSeek(xFilial("BXM")+BXL->BXL_SEQ+cSeller1))
						help("", 1, "PLS260EQP2")
						lCheck := .f.

					case !empty(cSeller2) .and. !BXM->(msSeek(xFilial("BXM")+BXL->BXL_SEQ+cSeller2))
						help("", 1, "PLS260EQP3")
						lCheck := .f.
				endcase
			endif
		else
			help("", 1, "REGNOIS")
			lCheck := .f.
		endif
	endif

return lCheck
