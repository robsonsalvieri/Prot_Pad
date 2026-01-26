#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIdReOp
Descricao: 	Critica referente ao Campo.
				-> BKR_IDEREE
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIdReOp From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritIdReOp
	_Super:New()
	self:setCodCrit('M014' )
	self:setMsgCrit('ID de reeembolso inválido.')
	self:setSolCrit('Campo deve ser preenchido quando a origem da guia for igual a 4. Caso contrário, preencher com 20 zeros.' )
	//self:setSolCrit('Campo deve ser preenchido quando a origem da guia for igual a: 1-Rede Contratada/2-Rede Própria-Cooperados/3-Rede Própria-Demais Prestadores.' )
	self:setCpoCrit('BKR_IDEREE')
	self:setCodAns('1307')
Return Self

Method getWhereCrit() Class CritIdReOp
	Local cQuery := ""

	cQuery += " 	AND ( "
		cQuery += "	BKR_OREVAT = '4' "
		cQuery += " 	AND (BKR_IDEREE = '' OR BKR_IDEREE = '00000000000000000000') "
	cQuery += " ) OR ( "
		cQuery += "	BKR_OREVAT <> '4' "
		cQuery += " AND BKR_IDEREE <> '00000000000000000000' "
	cQuery += " ) "
	
Return cQuery
