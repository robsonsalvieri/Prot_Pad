#INCLUDE "BADEFINITION.CH"

NEW ENTITY MOEDA

//-------------------------------------------------------------------
/*/{Protheus.doc} BAMoeda
Visualiza as informações de Moeda

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Class BAMoeda from BAEntity
	Method Setup() CONSTRUCTOR
	Method BuildQuery()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor padrão.

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAMoeda
	_Super:Setup("Moeda", DIMENSION, "SM2")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.
@return cQuery, string, query a ser processada.

@author  Andreia Lima
@since   16/06/2020
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAMoeda
	Local cQuery    := ""
	Local cDatabase := Upper( TCGetDB() )
	Local nMoeda    := 0
	Local aMoeda    := {}

	aMoeda  := BALoadMoeda()

	For nMoeda := 1 To Len( aMoeda )
		
		cQuery += "SELECT A.BK_MOEDA, A.CODIGO_MOEDA, A.DESCRICAO_MOEDA, A.INSTANCIA FROM ("
		
		If ( "ORACLE" $ cDatabase )
			
			cQuery += "SELECT '" + BIPrefixBK("<<KEY_SM2_>>") + "'" + "|| LPAD(" + aMoeda[nMoeda][1] + ", 2, '0') AS BK_MOEDA,"
			cQuery += " LPAD(" + aMoeda[nMoeda][1] + ", 2, '0') AS CODIGO_MOEDA, "
			cQuery += "'" + aMoeda[nMoeda][2] + "' AS DESCRICAO_MOEDA, "
			cQuery += Chr(39) + BIInstance() + Chr(39) + " AS INSTANCIA FROM DUAL) A "
		Else
			cQuery += "VALUES("
			cQuery += "'" + BIPrefixBK("<<KEY_SM2_>>") + "' || RIGHT('00' || CAST(" + aMoeda[nMoeda][1] + " AS VARCHAR(2)),2),"
			cQuery += " RIGHT('00' || CAST(" + aMoeda[nMoeda][1] + " AS VARCHAR(2)),2), "
			cQuery += "'" + aMoeda[nMoeda][2] + "',"
			cQuery += Chr(39) + BIInstance() + Chr(39)
			cQuery += ")) A (BK_MOEDA,CODIGO_MOEDA,DESCRICAO_MOEDA,INSTANCIA) "
		EndIf

		If (nMoeda < Len( aMoeda ) )
			cQuery += " UNION "
		EndIf
	
	Next nMoeda

Return cQuery


