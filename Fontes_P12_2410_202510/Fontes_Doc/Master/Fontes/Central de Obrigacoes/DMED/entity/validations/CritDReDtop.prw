#Include "Totvs.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} CritDReDtop
Descricao: 	Critica referente ao Campo.
				-> B2W_IDEREG
@author vinicius.nicolau
@since 08/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDReDtop From CritGrpB2W
    Method New() Constructor
    Method getWhereCrit()
EndClass

Method New() Class CritDReDtop
    _Super:New()
    self:setCodCrit('DM12')
    self:setMsgCrit('Esse registro DTOP deve estar associado a um registro do tipo TOP.')
    self:setSolCrit('Enviar para a Central de Obrigações o registro do tipo TOP.')
    self:setCpoCrit('B2W_IDEREG')
    self:setCodANS('')
Return Self

Method getWhereCrit() Class CritDReDtop

    Local cQuery := ""
    Local cTable := RetSqlName("B2W")

    cQuery += "  AND B2W_IDEREG = '3' "
    cQuery += "  AND NOT EXISTS ( SELECT 1 FROM " + cTable
    cQuery += "  AS B2WF WHERE B2W_FILIAL = '" 	  + xFilial("B2W") + "' "
    cQuery += "  AND B2WF.B2W_IDEREG = '1' "
    cQuery += "  AND B2WF.B2W_STATUS <> '4' "
    cQuery += "  AND " + cTable + ".B2W_CPFTIT = B2WF.B2W_CPFBEN "
    cQuery += "  AND " + cTable + ".B2W_CODOBR = B2WF.B2W_CODOBR "
    cQuery += "  AND " + cTable + ".B2W_CDCOMP = B2WF.B2W_CDCOMP "
    cQuery += "  AND B2WF.D_E_L_E_T_ = ' ') "

Return cQuery

