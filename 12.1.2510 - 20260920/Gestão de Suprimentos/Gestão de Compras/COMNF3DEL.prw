#include "protheus.ch"
#include "fwmvcdef.ch"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Modelo de dados - em formato Form - especí­fico para carregar os campos da DKO para NF3E, para efetuar sua exclusão via MVC.
	@type static
	@author renan.martins
	@since 05/2026
	@version 1.0
	@return oModel, object, objeto da Model MVC
/*/
//-------------------------------------------------------------------
static function ModelDef()
    Local oModel    := Nil as object
    Local oStrCab   := Nil as object
    Local cCampos   := "DKO_FILIAL,DKO_DOC,DKO_SERIE,DKO_FORNEC,DKO_LOJA,DKO_ESPECI,DKO_ITEM|DKO_COD|DKO_UM|DKO_QUANT|DKO_VUNIT|DKO_TOTAL|DKO_EMISSA" as character
    Private aNfSped := {"", "", ""} as array //Por causa da tabela DKO, do campo DKO_UMED
 
    oStrCab := FWFormStruct(1, "DKO", { |x| AllTrim(x) $ cCampos })
    oModel := MPFormModel():New("COMNF3DEL")
    oModel:addFields("CABMASTER", , oStrCab)
    oModel:setDescription("MODEL_DKO")
    oModel:SetPrimaryKey({'DKO_FILIAL', 'DKO_DOC', 'DKO_SERIE', 'DKO_FORNEC', 'DKO_LOJA', 'DKO_ITEM', 'DKO_COD'})

return oModel
