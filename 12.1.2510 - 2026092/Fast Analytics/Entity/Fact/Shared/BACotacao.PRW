#INCLUDE "BADEFINITION.CH"

NEW ENTITY COTACAO

//-------------------------------------------------------------------
/*/{Protheus.doc} BACotacao
Visualiza as cotacoes por moeda.

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Class BACotacao from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrao.

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BACotacao
	_Super:Setup("Cotacao", FACT, "SM2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BACotacao
	Local cQuery := ""
	Local nMoeda := 0
	Local aMoeda := {} 

	aMoeda := BALoadMoeda()
 	  	
 	//------------------------------------------------
	// Geração de um select virtual.
	//------------------------------------------------
	For nMoeda := 1 To Len( aMoeda )
		cQuery += "SELECT <<KEY_COMPANY>> AS BK_EMPRESA, "
		cQuery += " M2_DATA AS DATA,"
		cQuery += " <<KEY_MOEDA_'" + aMoeda[nMoeda][1] + "'>> AS BK_MOEDA, "
		cQuery += " M2_MOEDA" + aMoeda[nMoeda][1] + " AS COTACAO, "
		cQuery += " <<CODE_INSTANCE>> AS INSTANCIA "
		cQuery += " FROM <<SM2_COMPANY>> SM2" 
		cQuery += " WHERE M2_DATA BETWEEN <<START_DATE>> AND <<FINAL_DATE>> "
		cQuery += " AND SM2.D_E_L_E_T_ = ' '"

		If (nMoeda < Len( aMoeda ) )
			cQuery += "UNION "
		EndIf
	Next nMoeda

Return cQuery

