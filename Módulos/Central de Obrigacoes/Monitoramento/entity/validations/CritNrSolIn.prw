#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritNrSolIn
Descricao: 	Critica referente ao Campo.
				-> BKR_NMGOPE
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritNrSolIn From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritNrSolIn
	_Super:New()
	self:setCodCrit('M012')
	self:setMsgCrit('Numero da Guia de Solicitação de Internação Inválido.')
	self:setSolCrit('Campo deve ser preenchido quando o Tipo da Guia for igual a: 3-Internação ou 5-Honorarios e a origem da Guia for a 1-Rede Contratada/2-Rede Própria-Cooperados/3-Rede Própria-Demais Prestadores.' )
	self:setCpoCrit('BKR_SOLINT')
	self:setCodAns('1307')
Return Self

Method getWhereCrit() Class CritNrSolIn
	Local cQuery := ""
	cQuery += " 	AND ( (BKR_TPEVAT='3') OR (BKR_TPEVAT='5') ) "
	cQuery += " 	AND BKR_SOLINT = '' "	
Return cQuery