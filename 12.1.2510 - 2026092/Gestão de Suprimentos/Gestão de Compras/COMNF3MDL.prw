#include "protheus.ch"
#include "fwmvcdef.ch"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados, para gravação da DKO, utilizando o MVC padrão
@type static function
@return oModel - Objeto do modelo de dados
@author renan.martins
@since 05/2026
/*/
//-------------------------------------------------------------------
static function ModelDef()
    Local oModel    := Nil as object
    Local oStrCab   := Nil as object
    Local oStrGrid  := Nil as object
    Private aNfSped := {"", "", ""} as array //Por causa da tabela DKO, do campo DKO_UMED
 
    // Cabeçalho obrigatório
    oStrCab := FWFormModelStruct():New()
    oStrCab:addTable("", {"C_STRING1"}, "TSTTABLE", {|| ""})
    oStrCab:AddField("TESTE" , "TESTE" , 'TESTE' , 'C', 5)

    //Alias DKO, para os itens da NF3E
    oStrGrid := FWFormStruct(1, "DKO")
    oModel := MPFormModel():New("COMNF3MDL")
    
    oModel:addFields("CABMASTER", /*cOwner*/, oStrCab)
    
    oModel:addGrid("ITENSDETAIL", "CABMASTER", oStrGrid)
    
    oModel:setDescription("MODEL_DKO")
    
    // É necessário que haja alguma alteração na estrutura Field
    oModel:setActivate({ |oModel| onActivate(oModel)})
    oModel:SetPrimaryKey({'DKO_FILIAL', 'DKO_DOC', 'DKO_SERIE', 'DKO_FORNEC', 'DKO_LOJA', 'DKO_ITEM', 'DKO_COD'})
 
return oModel
 
//-------------------------------------------------------------------
/*/{Protheus.doc} onActivate
Função estática para o activate do model
@type static function
@param oModel - Objeto do modelo de dados
@author renan.martins
@since 05/2026
/*/
//-------------------------------------------------------------------
static function onActivate(oModel as object)
Default oModel := FwModelActive()

//Só efetua a alteração do campo para inserção
if (oModel:GetOperation() == MODEL_OPERATION_INSERT)
    FwFldPut("TESTE", "FAKE" , /*nLinha*/, oModel)
endif
 
return
