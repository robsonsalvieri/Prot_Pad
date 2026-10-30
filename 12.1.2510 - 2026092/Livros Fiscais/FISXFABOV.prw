#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISXFABOV
    (Componentização da função MaFisFFF - Calculo do FABOV)

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
Function FISXFABOV(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
	Local nQtdUm	:= 0
	Local cUMPadrao := "UN"

	aNfItem[nItem][IT_BASEFAB] := 0
	aNfItem[nItem][IT_ALIQFAB] := 0
	aNfItem[nItem][IT_VALFAB]  := 0

	if aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI])
		if ( aNFCab[NF_CLIFOR] == "C" )
			dbSelectArea("SD2")
			MsGoTo(aNFItem[nItem][IT_RECORI])
			if SD2->D2_VALFAB > 0 // não existe verificação desse campo
				// devolução total
				if aNFItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_BASEFAB]	:= SD2->D2_BASEFAB
					aNfItem[nItem][IT_ALIQFAB]	:= SD2->D2_ALIQFAB
					aNfItem[nItem][IT_VALFAB]	:= SD2->D2_VALFAB
				else// devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD2->D2_QUANT)
					aNfItem[nItem][IT_BASEFAB] := Round((SD2->D2_BASEFAB / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIQFAB] := SD2->D2_ALIQFAB
					aNfItem[nItem][IT_VALFAB] := Round((SD2->D2_VALFAB / nQtdOri) * nQtdUm,2)
				endif
			endif
		else
			dbSelectArea("SD1")
			MsGoTo(aNFItem[nItem][IT_RECORI])
			if SD1->D1_VALFAB > 0 // não existe verificação desse campo
				// devolução total
				if aNFItem[nItem][IT_QUANT] == SD1->D1_QUANT
					aNfItem[nItem][IT_BASEFAB]	:= SD1->D1_BASEFAB
					aNfItem[nItem][IT_ALIQFAB]	:= SD1->D1_ALIQFAB
					aNfItem[nItem][IT_VALFAB]	:= SD1->D1_VALFAB
				else// devolução parcial
					nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], SD1->D1_QUANT)
					aNfItem[nItem][IT_BASEFAB] := Round((SD1->D1_BASEFAB / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIQFAB] := SD1->D1_ALIQFAB
					aNfItem[nItem][IT_VALFAB] := Round((SD1->D1_VALFAB / nQtdOri) * nQtdUm,2)
				endif
			endif
		endif
	else
		//FABOV - BASE / ALIQUOTA e VALOR
		If (fisExtCmp('12.1.2310', .T.,'SB1','B1_AFABOV') .And. fisExtCmp('12.1.2310', .T.,'SA2','A2_RFABOV') .And. fisExtCmp('12.1.2310', .T.,'SA1','A1_RFABOV') .And. fisExtCmp('12.1.2310', .T.,'SF4','F4_CFABOV') ) .And. ;
			!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FABOV))

			If aNfItem[nItem][IT_AFABOV] > 0 .And. aNFItem[nItem][IT_TS][TS_CALCFAB] == "1"

				nQtdUm := defQtdUm(cPrUM, cSgUM, cUMPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])

				If nQtdUm > 0
					aNfItem[nItem][IT_BASEFAB] := Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFABOV] /100),2)
					aNfItem[nItem][IT_ALIQFAB] := aNfItem[nItem][IT_AFABOV]
					aNfItem[nItem][IT_VALFAB]  := Round(((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFABOV] /100) * nQtdUm),2)
				EndIf
			EndIf
		EndIf
	endif
Return
