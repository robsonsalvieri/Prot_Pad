#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CritDResArq
Descricao: 	Critica referente ao Campo.
            -> B2W_CODOPE
@author vinicius.nicolau
@since 08/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDResArq From CritGrpB2W
    Method New() Constructor
    Method getWhereCrit()
EndClass

Method New() Class CritDResArq
    _Super:New()
    self:setCodCrit('DM14')
    self:setMsgCrit('Deve existir um responsável ativo.')
    self:setSolCrit('Realize o cadastro de um responsável para operadora.')
    self:setCpoCrit('B2W_CODOPE')
    self:setCodANS('')
Return Self

Method getWhereCrit() Class CritDResArq

    Local cQuery := ""
    Local cTable := RetSqlName("B6N")

    cQuery += "  AND NOT EXISTS ( SELECT 1 FROM " + cTable
    cQuery += "  WHERE B6N_FILIAL = '" + xFilial("B2W") + "' "
    cQuery += "  AND B6N_CODOPE = B2W_CODOPE "
    cQuery += "  AND B6N_ATIVO='1' AND D_E_L_E_T_=' ') "

Return cQuery

