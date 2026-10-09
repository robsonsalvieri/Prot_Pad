#INCLUDE "TOTVS.CH"
#INCLUDE "ESTA101.CH"

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ESTA101CST
    Modelo secundário exclusivo para gravação (Commit) dos dados de custo
    @type Function
    @author Squad Entradas
    @since 03/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Function ESTA101CST()
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definições do modelo
    @type Function
    @author Squad Entradas
    @since 03/06/2026
    @version 12.1.2510
/*/
//----------------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel   := MPFormModel():New("ESTA101CST",,,)
    Local oStruD5D := FWFormStruct(1, "D5D")

    oModel:SetDescription(STR0059) // "Custo"
    
    oModel:AddFields("D5DMASTER", /*cOwner*/, oStruD5D)
    oModel:SetPrimaryKey({})
    
Return oModel
