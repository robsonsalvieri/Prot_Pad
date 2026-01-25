#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXIMA
    (Componentização da função MaFisFFF - Calculo do IMA-MT)

	@author Rafael.soliveira
    @since 22/01/2020
    @version 12.1.25

	@param:
	aNfCab -> Array com dados do cabeçalho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos   -> Array com dados de FieldPos de campos
	aInfNat	-> Array com dados da narutureza
	aPE		-> Array com dados dos pontos de entrada
	aSX6	-> Array com dados Parametros
	aDic	-> Array com dados Aliasindic
	aFunc	-> Array com dados Findfunction
	cPrUm	-> Primeira unidade de medida
	cSgUm	-> Segunda unidade de medida
/*/
Function FISXIMA(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    Local nQtdUm   := 0
	Local nQtdOri	:= 0
	Local cUMPadrao := "TL|TN|TON"

	aNfItem[nItem][IT_BASIMA]	:= 0
	aNfItem[nItem][IT_ALIIMA]	:= 0
	aNfItem[nItem][IT_VALIMA]	:= 0

	If aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI])
		If ( aNFCab[NF_CLIFOR] == "C" )
			dbSelectArea("SD2")
			MsGoTo(aNFItem[nItem][IT_RECORI])
			if fisExtCmp('12.1.2310', .T.,'SD2','D2_VALIMA') .AND. SD2->D2_VALIMA > 0
				// devolução total
				if aNFItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_BASIMA] := SD2->D2_BASIMA
					aNfItem[nItem][IT_ALIIMA] := SD2->D2_ALIIMA
					aNfItem[nItem][IT_VALIMA] := SD2->D2_VALIMA
				else// devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD2->D2_QUANT)
					aNfItem[nItem][IT_BASIMA] := Round((SD2->D2_BASIMA / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIIMA] := SD2->D2_ALIIMA
					aNfItem[nItem][IT_VALIMA] := Round((SD2->D2_VALIMA / nQtdOri) * nQtdUm,2)
				endif
			endif
		else
			dbSelectArea("SD1")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD1','FP_D1_VALIMA') .And. SD1->D1_VALIMA > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
					aNfItem[nItem][IT_BASIMA] := SD1->D1_BASIMA
					aNfItem[nItem][IT_ALIIMA] := SD1->D1_ALIIMA
					aNfItem[nItem][IT_VALIMA] := SD1->D1_VALIMA
				else // devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD1->D1_QUANT)
					aNfItem[nItem][IT_BASIMA] := Round((SD1->D1_BASIMA / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIIMA] := SD1->D1_ALIQFAC
					aNfItem[nItem][IT_VALIMA] := Round((SD1->D1_VALIMA / nQtdOri) * nQtdUm,2)
				EndIf
			endif
		endif
	else
		//IMA-MT
		If  (fisExtCmp('12.1.2310', .T.,'SB1','B1_AIMAMT') .And. fisExtCmp('12.1.2310', .T.,'SA2','A2_RIMAMT') .And. fisExtCmp('12.1.2310', .T.,'SA1','A1_RIMAMT') .And. fisExtCmp('12.1.2310', .T.,'SF4','F4_CIMAMT')) .AND. ;
			!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_IMAMT))

			If aNfItem[nItem][IT_AIMAMT] > 0 .And. aNFItem[nItem][IT_TS][TS_CIMAMT] == "1"

				nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])

				If nQtdUm > 0
					aNfItem[nItem][IT_BASIMA]	:= aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AIMAMT] / 100
					aNfItem[nItem][IT_ALIIMA]	:= aNfItem[nItem][IT_AIMAMT]
					aNfItem[nItem][IT_VALIMA]	:= Round(aNfItem[nItem][IT_BASIMA] * nQtdUm,2)
				EndIf

				IF aNfCab[NF_RECIMA] == "1"
					aNfItem[nItem][IT_VLIMAR]	:= aNfItem[nItem][IT_VALIMA]
				EndIF
			EndIf
		EndIf
	endif
Return
