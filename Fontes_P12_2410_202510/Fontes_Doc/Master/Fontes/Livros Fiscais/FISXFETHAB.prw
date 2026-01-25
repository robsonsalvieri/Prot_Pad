#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FETHAB
    (Componentização da função MaFisFFF - Calculo do FETHAB)

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
Function FISXFETHAB(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cPrUm, cSgUm)
    Local nQtdUm    := 0
	Local nQtdOri	:= 0
	Local cUmPadrao	:= ''
	Local aUMFethab := {"TL|TON|TN", "TL|TON|TN", "UN", "M3", "TL|TON|TN"}//1-soja; 2-algodão; 3-gado; 4-madeira; 5-milho.

	aNfItem[nItem][IT_BASEFET] := 0
	aNfItem[nItem][IT_ALIQFET] := 0
	aNfItem[nItem][IT_VALFET]  := 0

	if aNfCab[NF_TIPONF] $ "BD" .And. !Empty(aNFItem[nItem][IT_RECORI])
		if ( aNFCab[NF_CLIFOR] == "C" )// devolução de venda
			dbSelectArea("SD2")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD2','D2_VALFET') .and. SD2->D2_VALFET > 0
				// devolução total
				if aNfItem[nItem][IT_QUANT] == SD2->D2_QUANT
					aNfItem[nItem][IT_BASEFET]	:= SD2->D2_BASEFET
					aNfItem[nItem][IT_ALIQFET]	:= SD2->D2_ALIQFET
					aNfItem[nItem][IT_VALFET]	:= SD2->D2_VALFET
				else// devolução parcial
					cUmPadrao := aUMFethab[val(aNfItem[nItem][IT_TFETHAB])]
					nQtdUm	:= defQtdUm(cPrUm, cSgUm, cUmPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri	:= defQtdUm(cPrUm, cSgUm, cUmPadrao, aNfItem[nItem][IT_PRODUTO], SD2->D2_QUANT)
					aNfItem[nItem][IT_BASEFET] := Round((SD2->D2_BASEFET / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIQFET] := SD2->D2_ALIQFET
					aNfItem[nItem][IT_VALFET]  := Round((SD2->D2_VALFET / nQtdOri) * nQtdUm,2)
				endif
			endif
		else// devolução de compra
			dbSelectArea("SD1")
			MsGoto( aNFItem[nItem][IT_RECORI] )
			if fisExtCmp('12.1.2310', .T.,'SD1','D1_VALFET') .AND. SD1->D1_VALFET > 0
				// devolução total
				If aNfItem[nItem][IT_QUANT] == SD1->D1_QUANT
					aNfItem[nItem][IT_BASEFET] := SD1->D1_BASEFET
					aNfItem[nItem][IT_ALIQFET] := SD1->D1_ALIQFET
					aNfItem[nItem][IT_VALFET] := SD1->D1_VALFET
				else// devolução parcial
					cUmPadrao := aUMFethab[val(aNfItem[nItem][IT_TFETHAB])]
					nQtdUm	:= defQtdUm(cPrUm, cSgUm, cUmPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])
					nQtdOri	:= defQtdUm(cPrUm, cSgUm, cUmPadrao, aNfItem[nItem][IT_PRODUTO], SD1->D1_QUANT)
					aNfItem[nItem][IT_BASEFET] := Round((SD1->D1_BASEFET / nQtdOri) * nQtdUm,2)
					aNfItem[nItem][IT_ALIQFET] := SD1->D1_ALIQFET
					aNfItem[nItem][IT_VALFET]  := Round((SD1->D1_VALFET / nQtdOri) * nQtdUm,2)
				EndIf
			endif
		endif
	else//FETHAB - BASE / ALIQUOTA e VALOR
		If  (fisExtCmp('12.1.2310', .T.,'SB1','B1_AFETHAB')  .And. fisExtCmp('12.1.2310', .T.,'SA2','A2_RECFET')  .And. fisExtCmp('12.1.2310', .T.,'SA1','A1_RECFET') .And. fisExtCmp('12.1.2310', .T.,'SF4','F4_CALCFET') ) .AND. ;
			!(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_FETHAB))

			If aNfItem[nItem][IT_AFETHAB]  > 0  .And. !Empty(aNfItem[nItem][IT_TFETHAB]) .And. aNFItem[nItem][IT_TS][TS_CALCFET] == "1"

				cUmPadrao := aUMFethab[val(aNfItem[nItem][IT_TFETHAB])]
				nQtdUm := defQtdUm(cPrUm, cSgUm, cUmPadrao, aNfItem[nItem][IT_PRODUTO], aNfItem[nItem][IT_QUANT])

				If nQtdUm > 0
					aNfItem[nItem][IT_BASEFET] := Round((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFETHAB] / 100),2)
					aNfItem[nItem][IT_ALIQFET] := aNfItem[nItem][IT_AFETHAB]
					aNfItem[nItem][IT_VALFET]  := Round(((aNfCab[NF_INDUFP] * aNfItem[nItem][IT_AFETHAB] / 100) * nQtdUm),2)
				EndIf

				IF aNfItem[nItem][IT_TFETHAB] == "2"
					IF fisExtCmp('12.1.2310', .T.,'SF4','F4_RFETALG') .AND. aNFItem[nItem][IT_TS][TS_RFETALG] == "2"// Algodão irá verificar retenção no cadastro de TES
						aNfItem[nItem][IT_VALFETR] := 0 //Se no cadastro do TES estiver igual a SIM então não irá reter FETHAB, se estiver diferente irá considerar o padrão
					ElseIF aNfCab[NF_RECFET] == "1"
						aNfItem[nItem][IT_VALFETR] := aNfItem[nItem][IT_VALFET]
					EndIF
				EndIF
			Endif
		endif
	EndIf
Return
