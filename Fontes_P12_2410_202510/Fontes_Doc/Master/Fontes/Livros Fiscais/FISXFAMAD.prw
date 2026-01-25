#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FAMAD
    (Componentização da função MaFisFFF - Calculo do FAMAD)    
    
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
Function FISXFAMAD(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
	Local nQtdUm	:= 0
	Local cUMPadrao	:= "M3"

	aNfItem[nItem][IT_BASEFMD] := 0
	aNfItem[nItem][IT_VALFMD]  := 0

	If aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI])
		If ( aNFCab[NF_CLIFOR] == "C" )
			dbSelectArea("SD2")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD2','D2_VALFMD') .And. SD2->D2_VALFMD > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_BASEFMD]	:= SD2->D2_BASEFMD
					aNfItem[nItem][IT_ALQFMD] 	:= SD2->D2_ALQFMD
					aNfItem[nItem][IT_VALFMD] 	:= SD2->D2_VALFMD
				else // devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD2->D2_QUANT)
					aNfItem[nItem][IT_BASEFMD] 	:= Round((SD2->D2_BASEFMD / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALQFMD] 	:= SD2->D2_ALQFMD
					aNfItem[nItem][IT_VALFMD] 	:= Round((SD2->D2_VALFMD / nQtdOri) * nQtdUm,2)
				EndIf
			endif
		Else
			dbSelectArea("SD1")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD1','D1_VALFMD') .And. SD1->D1_VALFMD > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT .AND. fisExtCmp('12.1.2310', .T.,'SD1','D1_VALFMD') .And. SD1->D1_VALFMD > 0
					aNfItem[nItem][IT_BASEFMD]	:= SD1->D1_BASEFMD
					aNfItem[nItem][IT_ALQFMD] 	:= SD1->D1_ALQFMD
					aNfItem[nItem][IT_VALFMD] 	:= SD1->D1_VALFMD
				else // devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD1->D1_QUANT)
					aNfItem[nItem][IT_BASEFMD] 	:= Round((SD1->D1_BASEFMD / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALQFMD] 	:= SD1->D1_ALQFMD
					aNfItem[nItem][IT_VALFMD] 	:= Round((SD1->D1_VALFMD / nQtdOri) * nQtdUm,2)
				EndIf
			endif
		EndIf
	Else
		//FAMAD - BASE / ALIQUOTA e VALOR
		If (fisExtCmp('12.1.2310', .T.,'SB1','B1_AFAMAD') .And. fisExtCmp('12.1.2310', .T.,'SA2','A2_RECFMD') .And. fisExtCmp('12.1.2310', .T.,'SA1','A1_RECFMD') .And. fisExtCmp('12.1.2310', .T.,'SF4','F4_CFAMAD') ) .And. ;
			!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FAMAD))

			If aNfItem[nItem][IT_ALQFMD] > 0 .And. aNFItem[nItem][IT_TS][TS_CFAMAD] == "1"
				nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])

				If nQtdUm > 0
					aNfItem[nItem][IT_BASEFMD] := Round((aNfCab[NF_INDUFP]  * aNfItem[nItem][IT_ALQFMD] / 100),2)
					aNfItem[nItem][IT_ALQFMD]  := aNfItem[nItem][IT_ALQFMD]
					aNfItem[nItem][IT_VALFMD]  := Round(((aNfCab[NF_INDUFP]  * aNfItem[nItem][IT_ALQFMD] / 100) * nQtdUm),2)
				Endif
			EndIf
		EndIf
	EndIf
Return
