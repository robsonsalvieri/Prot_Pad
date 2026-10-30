#INCLUDE "TOTVS.CH"
#INCLUDE "ESTA101.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101OPE
    Modelo secundário exclusivo para gravação (Commit) dos dados de roteiro
    @type Function
    @author Squad Entradas
    @since 29/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101OPE()
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definições do modelo
    @type Function
    @author Squad Entradas
    @since 29/05/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   := MPFormModel():New("ESTA101OPE",,,)
    Local oStruD5C := FWFormStruct(1, "D5C")

    oModel:SetDescription(STR0011) // Roteiro
    
    oModel:AddFields("D5CMASTER", /*cOwner*/, oStruD5C)
    oModel:SetPrimaryKey({})
    
Return oModel
