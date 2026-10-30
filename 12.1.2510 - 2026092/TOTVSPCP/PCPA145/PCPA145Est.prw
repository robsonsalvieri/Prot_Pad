#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145DEF.ch"

Static _oProcesso := Nil

/*/{Protheus.doc} PCPA145Est
Função para atualização dos saldos

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cTicket , Character, Ticket de processamento do MRP para geração dos documentos
@param cProduto, Character, Código do produto que será processado
@param cName   , Character, Nome do contador de controle de jobs processados
@param cNivel  , Character, Nível do produto que está sendo processado.
@param cFilProc, Character, Código da filial para processamento
@return Nil
/*/
Function PCPA145Est(cTicket, cProduto, cName, cNivel, cFilProc)
	Local aSaldos    := {}
	Local cFilBkp    := cFilAnt
	Local cLocal     := ""
	Local lRet       := .T.
	Local nEntrFirme := 0
	Local nEntrPrev  := 0
	Local nIndex     := 0
	Local nQtdSegUM  := 0
	Local nTotal     := 0
	Local nSaidFirme := 0
	Local nSaidPrev  := 0
	Local nSdFirPV   := 0
	Local nSdPrvPV   := 0

	If _oProcesso == Nil
		_oProcesso := ProcessaDocumentos():New(cTicket, .T.)
	EndIf

	//Atualiza filial de processamento
	If cFilAnt != cFilProc
		cFilAnt := cFilProc
	EndIf

	aSaldos := _oProcesso:getSaldosProduto(cProduto, @lRet, cFilProc)

	If lRet
		nTotal := Len(aSaldos)
		For nIndex := 1 To nTotal

			cLocal       := aSaldos[nIndex][SALDOS_POS_LOCAL]
			nEntrFirme   := aSaldos[nIndex][SALDOS_POS_QTD][SALDOS_QTD_POS_ENTRADA_FIRME  ]
			nEntrPrev    := aSaldos[nIndex][SALDOS_POS_QTD][SALDOS_QTD_POS_ENTRADA_PREV   ]
			nSaidFirme   := aSaldos[nIndex][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_FIRME    ]
			nSaidPrev    := aSaldos[nIndex][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_PREV     ]
			nSdFirPV     := aSaldos[nIndex][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_FIRME_PV ]
			nSdPrvPV     := aSaldos[nIndex][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_PREV_PV  ]

			_oProcesso:criaSB2(cFilAnt,cProduto,cLocal,.T.)

			//Grava quantidade de entrada prevista
			If nEntrPrev > 0
				nQtdSegUM := _oProcesso:ConvUm(cProduto, nEntrPrev, 0, 2)
				GravaB2Pre("+", nEntrPrev, "P", nQtdSegUM)
			EndIf

			//Grava quantidade de entrada firme
			If nEntrFirme > 0
				nQtdSegUM := _oProcesso:ConvUm(cProduto, nEntrFirme, 0, 2)
				GravaB2Pre("+", nEntrFirme, "F", nQtdSegUM)
			EndIf

			//Grava quantidade de saida prevista
			If nSaidPrev > 0
				nQtdSegUM := _oProcesso:ConvUm(cProduto, nSaidPrev, 0, 2)
				GravaB2Emp("+", nSaidPrev, "P", .F., nQtdSegUM)
			EndIf

			//Grava quantidade de saida firme
			If nSaidFirme > 0
				nQtdSegUM := _oProcesso:ConvUm(cProduto, nSaidFirme, 0, 2)
				GravaB2Emp("+", nSaidFirme, "F", .F., nQtdSegUM)
			EndIf

			//Grava quantidade de saida prevista para demanda de Pedido de Venda
			//A650AtEmpn("P") ? B2_QEMPPRE + B2_QEPRE2
			If nSdPrvPV > 0
				A650AtEmpn(nSdPrvPV, "+", "P")
			EndIf

			//Grava quantidade de saida firme para demanda de Pedido de Venda
			//A650AtEmpn("F") ? B2_QEMPN + B2_QEMPN2
			If nSdFirPV > 0
				A650AtEmpn(nSdFirPV, "+", "F")
			EndIf
		Next nIndex
	EndIf

	aSize(aSaldos, 0)

	If cFilAnt != cFilBkp
		cFilAnt := cFilBkp
	EndIf

	//No fim do processamento deste JOB, incrementa o contador de jobs processados.
	_oProcesso:incCount(cName)

	_oProcesso:incCount(_oProcesso:cThrSaldoJob + "_Concluidos")
Return
