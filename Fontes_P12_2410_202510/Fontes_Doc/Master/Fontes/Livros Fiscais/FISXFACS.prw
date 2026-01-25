#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFACS
    (Componentização da função MaFisFFF - Calculo do FACS)

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
Function FISXFACS(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    Local nQtdUm	:= 0
	Local nQtdOri	:= 0
	Local cUMPadrao := "TL|TON|TN"

	aNfItem[nItem][IT_BASEFAC] := 0
	aNfItem[nItem][IT_ALIQFAC] := 0
	aNfItem[nItem][IT_VALFAC]  := 0

	If aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI])
		If ( aNFCab[NF_CLIFOR] == "C" )
			dbSelectArea("SD2")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD2','D2_VALFAC') .And. SD2->D2_VALFAC > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_BASEFAC] := SD2->D2_BASEFAC
					aNfItem[nItem][IT_ALIQFAC] := SD2->D2_ALIQFAC
					aNfItem[nItem][IT_VALFAC] := SD2->D2_VALFAC
				else // devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD2->D2_QUANT)
					aNfItem[nItem][IT_BASEFAC] := Round((SD2->D2_BASEFAC / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIQFAC] := SD2->D2_ALIQFAC
					aNfItem[nItem][IT_VALFAC] := Round((SD2->D2_VALFAC / nQtdOri) * nQtdUm,2)
				EndIf
			endif
		Else
			dbSelectArea("SD1")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD1','D1_VALFAC') .And. SD1->D1_VALFAC > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
					aNfItem[nItem][IT_BASEFAC] := SD1->D1_BASEFAC
					aNfItem[nItem][IT_ALIQFAC] := SD1->D1_ALIQFAC
					aNfItem[nItem][IT_VALFAC] := SD1->D1_VALFAC
				else // devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD1->D1_QUANT)
					aNfItem[nItem][IT_BASEFAC] := Round((SD1->D1_BASEFAC / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIQFAC] := SD1->D1_ALIQFAC
					aNfItem[nItem][IT_VALFAC] := Round((SD1->D1_VALFAC / nQtdOri) * nQtdUm,2)
				EndIf
			endif
		EndIf
	Else
		//FACS  - BASE / ALIQUOTA e VALOR
		If  (fisExtCmp('12.1.2310', .T.,'SB1','B1_AFACS') .And. fisExtCmp('12.1.2310', .T.,'SA2','A2_RFACS') .And. fisExtCmp('12.1.2310', .T.,'SA1','A1_RFACS') .And. fisExtCmp('12.1.2310', .T.,'SF4','F4_CFACS') ) .AND. ;
			!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FACS))

			If aNfItem[nItem][IT_AFACS] > 0 .And. aNFItem[nItem][IT_TS][TS_CALCFAC] == "1"
				nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])

				If nQtdUm > 0
					aNfItem[nItem][IT_BASEFAC] := Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFACS] /100),2)
					aNfItem[nItem][IT_ALIQFAC] := aNfItem[nItem][IT_AFACS]
					aNfItem[nItem][IT_VALFAC]  := Round(((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFACS] /100) * nQtdUm),2)
				Endif
			EndIf
		EndIf
	EndIf
Return
