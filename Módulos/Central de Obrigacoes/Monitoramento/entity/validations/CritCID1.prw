#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCID1
Descricao: 	Critica referente ao Campo.
				-> BKR_CDCID1
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCID1 From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCID1
	_Super:New()
	self:setCodCrit('M032' )
	self:setMsgCrit('Código do Primeiro Diagnóstico é inválido.(CID)')
	self:setSolCrit('Não deve haver repetição do conteúdo do CID nos campos CID1, CID2, CID3, CID4.Verificar se é guia de resumo de internação')
	self:setCpoCrit('BKR_CDCID1')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritCID1
	Local cQuery := ""
	cQuery += " 		AND ( (BKR_TPEVAT='1') OR (BKR_TPEVAT='2') OR (BKR_TPEVAT='3') ) "
	cQuery += " 		AND BKR_CDCID1 <> '' "
	cQuery += " 		AND ( "
	cQuery += " 			BKR_CDCID1 = BKR_CDCID2 OR "
	cQuery += " 			BKR_CDCID1 = BKR_CDCID3 OR "
	cQuery += " 			BKR_CDCID1 = BKR_CDCID4 "
	cQuery += " 		) "
Return cQuery


