#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} OFIA270
Funcoes DMS - Chamadas pelo MATA120 ( PEDIDOS DE COMPRA )

@author Andre Luis Almeida
@since 04/03/2020
@version 1.0
@return NIL
/*/
Function OFIA270()
Return NIL

/*/{Protheus.doc} OA2700011_A120Pedido
	Chamada do MATA120 funcao A120Pedido ( Rotina de Inclusao e Alteracao dos Pedidos de Compra )

	@author Andre Luis Almeida
	@since 04/03/2020
/*/
Function OA2700011_A120Pedido( l120Deleta , ALTERA , INCLUI , cA120Num )

	Local lJohnDeere := (Alltrim(GetNewPar("MV_MIL0006","")) == "JD")

	Private oSqlHlp  := DMS_SqlHelper():New()

	If lJohnDeere .and. (INCLUI .or. ALTERA)

		///Gera VB8
		cQuery := "SELECT SC7.C7_PRODUTO, SB1.B1_CRICOD, SBM.BM_PROORI "
		cQuery += " FROM " + RetSQLName("SC7") + " SC7 "
		cQuery += 	" JOIN " + oSqlHlp:NoLock("SB1")
		cQuery += 		"  ON SB1.B1_FILIAL = '" +xFilial("SB1")+ "' "
		cQuery += 		" AND SB1.B1_COD = SC7.C7_PRODUTO "
		cQuery += 		" AND SB1.D_E_L_E_T_ = ' '"
		cQuery += 	" JOIN " + oSqlHlp:NoLock("SBM")
		cQuery += 		"  ON BM_FILIAL = '"+xFilial("SBM")+"' "
		cQuery += 		" AND SB1.B1_GRUPO = SBM.BM_GRUPO "
		cQuery += 		" AND SBM.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE SC7.C7_FILIAL = '" +xFilial("SC7")+ "' "
		cQuery += 	" AND SC7.C7_NUM = '" + cA120Num + "' "
		cQuery += 	" AND SC7.C7_PEDFAB <> ' '"
		cQuery += 	" AND SC7.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPC7"

		While !TMPC7->(Eof())

			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial("VB8")    },;
				{'VB8_PRODUT' , TMPC7->C7_PRODUTO },;
				{'VB8_CRICOD' , TMPC7->B1_CRICOD  },;
				{'VB8_ANO'    , cValToChar(YEAR(dDataBase))   },;
				{'VB8_MES'    , cValToChar(StrZero(MONTH(dDataBase),2))  },;
				{'VB8_DIA'    , cValToChar(StrZero(DAY(dDataBase),2))    },;
				{'VB8_LOCAL'  , IIF(TMPC7->BM_PROORI == "1","D1","N1") },;
				{'VB8_TIPLOC' , IIF(TMPC7->BM_PROORI == "1","M","N") },;
				{'VB8_STOCK'  , "S"},;
				{'VB8_TIPREG' , "D"},;
				{'VB8_PROCES' , "N"};
			})

			oDem := DMS_DataContainer():New({;
				{'VB8_HITSI' , 0},;
				{'VB8_VDAI'  , 0},;
				{'VB8_IMEDI' , 0},;
				{'VB8_HIPERI', 0};
			})

			ONJD3101_GravaDem(oDados, oDem, .t.)
			
			TMPC7->(DbSkip())
		EndDo
		TMPC7->(DbCloseArea())

	EndIf

	If ExistBlock("OF270PED")
		ExecBlock("OF270PED",.f.,.f.,{l120Deleta , ALTERA , INCLUI , cA120Num})
	EndIf

Return
