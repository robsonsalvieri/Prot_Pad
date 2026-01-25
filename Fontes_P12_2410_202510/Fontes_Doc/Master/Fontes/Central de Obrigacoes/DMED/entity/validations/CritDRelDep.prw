#Include "Totvs.ch"

#Define CONJUGE    '03'  //Cônjuge/companheiro
#Define FILHO      '04'  //Filho/filha
#Define ENTEADO    '06'  //Enteado/enteada
#Define PAI_MAE    '08'  //Pai/mãe
#Define AGRE_OUTRO '10'  //Agregado/outros

//-------------------------------------------------------------------
/*/{Protheus.doc} CritDDatNas
Descricao: 	Critica referente ao Campo.
				-> B2W_RELDEP
@author lima.everton
@since 10/09/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritDRelDep From CritGrpB2W
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritDRelDep
	_Super:New()
	self:setCodCrit('DM03')
	self:setMsgCrit('Relação de depêndencia inválida.')
	self:setSolCrit('O campo é numérico de tamanho 2, e deve seguir conforme Tabela de Relação de Dependência (03,04,06,08,10).')
	self:setCpoCrit('B2W_RELDEP')
	self:setCodANS('')
Return Self

Method getWhereCrit() Class CritDRelDep
	Local cQuery := ""
	
	// cQuery += "  AND B2W_CPFBEN <> '' "
	cQuery += "  AND B2W_IDEREG = '3' "
	cQuery += "  AND B2W_RELDEP <> '' "
	cQuery += "  AND B2W_RELDEP NOT IN ('"+CONJUGE+"','"+FILHO+"','"+ENTEADO+"','"+PAI_MAE+"','"+AGRE_OUTRO+"') "
Return cQuery

