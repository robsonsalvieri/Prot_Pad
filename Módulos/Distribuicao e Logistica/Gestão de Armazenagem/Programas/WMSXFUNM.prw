#include "protheus.ch"
/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNM - Funções Para Automação de Testes                        |
+---------+--------------------------------------------------------------------+
|Objetivo | Deverá agrupar todas as funções que serão utilizadas na            |
|         | automação de testes.                                               |
+---------+--------------------------------------------------------------------+
*/


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsAutCmt
Realiza a validação da automação, verificando o conteúdo dos registros criados.
@type function
@author Wander Horongoso
@version 12.1.31
@since 16/11/2020
@param
oHelper: objeto helper da automação
lAssert: indica se a automção deve retornar execução com (.T.) ou sem (.F.) sucesso.
lCommit: Se verdadeiro  efetua o commit. Senão não faz, pois já foi feito externamente.
aFields: relação de campos a serem validados.
	aFields[1]: nome do campo
	aFields[2]: conteúdo do campo
	aFields[3]: se o campo será usado 	para a pesquisa/condição where (.T.) ou para validação do contéudo gravado (.F.).
/*/
//-------------------------------------------------------------------------------------------------
Function WmsAutCmt(oHelper, lAssert, lCommit, aFields)
Local cQuery := ''
Local cTable := ''
Local cTableFld := ''
Local nTable := 0
Local nField := 0
Local xVal := nil

	If lCommit
		lCommit := oHelper:UTCommitData()
	Else
		lCommit := .T.		
	EndIf	
	
	If lCommit
		For nTable := 1 to Len(aFields)
			cMsgTab := ''

			cTable := aFields[nTable][1] 
			If cTable $ 'SD1|SD2|SF1|SF2|SA1|SA2|SB1|SB2|SB5|SB8'
				cTableFld := Substr(cTable,2,2)
			Else	
				cTableFld := cTable
			EndIf

			cQuery := cTable + "." + cTableFld + "_FILIAL = '" + xFilial(cTable) + "'"
			
			For nField := 1 To Len(aFields[nTable][2])
				If aFields[nTable][2][nField][3]
				    xVal := aFields[nTable][2][nField][2]
	
				    Iif (ValType(xVal) == 'C', xVal := "'" + xVal + "'",)
					Iif (ValType(xVal) == 'N', xVal := Str(xVal),)
				    
					cQuery  += ' AND ' + cTable + "." + aFields[nTable][2][nField][1] + " = " + xVal
				EndIf
			Next nField
			
			For nField := 1 To Len(aFields[nTable][2])
				If !aFields[nTable][2][nField][3]				
					xVal := aFields[nTable][2][nField][2]

					Iif (ValType(xVal) == 'D', xVal := DTOS(xVal),)

					oHelper:UTQueryDB(cTable,aFields[nTable][2][nField][1], cQuery, aFields[nTable][2][nField][2])
				EndIf			
			Next nField
	
		Next nTable
	EndIf

	Iif (lAssert, oHelper:AssertTrue(), oHelper:AssertFalse())

Return oHelper
