#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritCID3
Descricao: 	Critica referente ao Campo.
				-> BKR_CDCID3
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritCID3 From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritCID3
	_Super:New()
	self:setCodCrit('M034' )
	self:setMsgCrit('Código do Terceiro Diagnóstico é inválido.(CID)')
	self:setSolCrit('Não deve haver repetição do conteúdo do CID nos campos CID1, CID2, CID3, CID4.Verificar se é guia de resumo de internação')
	self:setCpoCrit('BKR_CDCID3')
	self:setCodAns('5029')
Return Self

Method getWhereCrit() Class CritCID3
	Local cQuery := ""
	cQuery += " 		AND ((BKR_TPEVAT='1') OR (BKR_TPEVAT='2') OR (BKR_TPEVAT='3')) AND BKR_CDCID3 <> '' AND ( "
	cQuery += " 		BKR_CDCID3 = BKR_CDCID1 OR "
	cQuery += " 		BKR_CDCID3 = BKR_CDCID2 OR "
	cQuery += " 		BKR_CDCID3 = BKR_CDCID4 "
	cQuery += " 	) "
Return cQuery


