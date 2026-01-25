#Include "Totvs.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CritIdPrest
Descricao: 	Critica referente ao Campo Id Prestador Executante
				-> BKR_IDEEXC
@author Hermiro Júnior
@since 01/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Class CritIdPrest From CritGrpBKR
	Method New() Constructor
	Method getWhereCrit()
EndClass

Method New() Class CritIdPrest
	_Super:New()
	self:setCodCrit('M015' )
	self:setMsgCrit('Indicador de prestador executante inválido.')
	self:setSolCrit('') 
	self:setCpoCrit('BKR_IDEEXC')
	self:setCodAns('5029')
	self:setDesOri('Tipo  da identificação prestador executante deve ser 1-CNPJ ou 2-CPF, e para guias de Resumo de internação apenas 1-CNPJ')
Return Self

Method getWhereCrit() Class CritIdPrest
	Local cQuery := ""
	Local cDB	  := TCGetDB()

	cQuery += " 	AND ( ( ( (BKR_TPEVAT='1') OR (BKR_TPEVAT='2') ) AND ( (BKR_IDEEXC<>'1') AND (BKR_IDEEXC<>'2') ) )  "
	cQuery += " 		  OR ( BKR_TPEVAT = '3' AND BKR_IDEEXC <> '1' ) OR ( BKR_TPEVAT = '3' AND BKR_IDEEXC = '1' AND " 

	If cDB == "MSSQL"
		cQuery += "LEN"
	else
		cQuery += "LENGTH"
	Endif	

	cQuery += "(BKR_CPFCNP)=11 ) ) "
	
Return cQuery