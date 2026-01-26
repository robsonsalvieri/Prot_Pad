#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFASE
    (Componentização da função MaFisFFF - Calculo do FASE-MT)

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
Function FISXFASE(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    Local nQtdUm   := 0
	Local nQtdOri	:= 0
	local cUMPadrao := "KG"

	aNfItem[nItem][IT_BASFASE]  := 0
	aNfItem[nItem][IT_ALIFASE]	:= 0
	aNfItem[nItem][IT_VALFASE]	:= 0

	if aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI])
		if ( aNFCab[NF_CLIFOR] == "C" )
			dbSelectArea("SD2")
			MsGoTo(aNFItem[nItem][IT_RECORI])
			if fisExtCmp('12.1.2310', .T.,'SD2','D2_VALFASE') .AND. SD2->D2_VALFASE > 0
				// devolução total
				if aNFItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_BASFASE]	:= SD2->D2_BASFASE
					aNfItem[nItem][IT_ALIFASE]	:= SD2->D2_ALIFASE
					aNfItem[nItem][IT_VALFASE]	:= SD2->D2_VALFASE
				else// devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD2->D2_QUANT)
					aNfItem[nItem][IT_BASFASE] := Round((SD2->D2_BASFASE / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIFASE] := SD2->D2_ALIFASE
					aNfItem[nItem][IT_VALFASE] := Round((SD2->D2_VALFASE / nQtdOri) * nQtdUm,2)
				endif
			endif
		else
			dbSelectArea("SD1")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD1','D1_VALFASE') .And. SD1->D1_VALFASE > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
					aNfItem[nItem][IT_BASFASE]	:= SD1->D1_BASFASE
					aNfItem[nItem][IT_ALIFASE]	:= SD1->D1_ALIFASE
					aNfItem[nItem][IT_VALFASE]	:= SD1->D1_VALFASE
				else// devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD1->D1_QUANT)
					aNfItem[nItem][IT_BASFASE] := Round((SD1->D1_BASFASE / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIFASE] := SD1->D1_ALIFASE
					aNfItem[nItem][IT_VALFASE] := Round((SD1->D1_VALFASE / nQtdOri) * nQtdUm,2)
				endif
			endif
		endif
	else
		//FASE-MT
		If (fisExtCmp('12.1.2310', .T.,'SB1','B1_AFASEMT') .AND. fisExtCmp('12.1.2310', .T.,'SA2','A2_RFASEMT') .AND. fisExtCmp('12.1.2310', .T.,'SA1','A1_RFASEMT') .AND. fisExtCmp('12.1.2310', .T.,'SF4','F4_CFASE')) .AND. ;		
			!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FASEMT))

			If aNfItem[nItem][IT_AFASEMT] > 0 .And. aNFItem[nItem][IT_TS][TS_CFASE] == "1"

				nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])

				If nQtdUm > 0
					aNfItem[nItem][IT_BASFASE]	:= Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFASEMT] /100),2)
					aNfItem[nItem][IT_ALIFASE]	:= aNfItem[nItem][IT_AFASEMT]
					aNfItem[nItem][IT_VALFASE]	:= Round(aNfItem[nItem][IT_BASFASE] * nQtdUm,2)
				EndIf

				IF aNfCab[NF_RECFASE] == "1"
					aNfItem[nItem][IT_VLFASER]	:= aNfItem[nItem][IT_VALFASE]
				EndIF
			EndIf
		EndIf
	endif
Return
