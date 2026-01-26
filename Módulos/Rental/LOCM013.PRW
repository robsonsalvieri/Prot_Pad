#Include "locm013.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} LOCM013
Validação para não permitir alterações em pedidos com origem no Rental
@type function
@version 23.10
@author Alexandre Circenis
@since 11/1/2024
@return variant, .t. o pedido pode ser alterado e .f. se não puder
/*/

FUNCTION LOCM013()
	Local lLocBac := GetMV("MV_LOCBAC")
	Local lPedRental := .F.
	Local aArea := GetArea()
	Local aAreaSC6 := SC6->(GetArea())
	Local nPItem	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEM"})
	Local nPQtdVen	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDVEN"})
	Local nPQtdLib	 := aScan(aHeader,{|x| AllTrim(x[2])=="C6_QTDLIB"})
	Local nMaxArray	 := Len(aCols)
	Local nCntFor := 0
	Local lRet := .T.
	Local cItens := ""
	LOcal nPosVir
	Local cTipFat := " "

// Usa LOCBAC
	if lLocBac
    // Verificar de o pedido está na FPY
	    dbSelectArea("FPY")
    	dbSetOrder(1)
	    lPedRental := dbSeek(xFilial("FPY")+M->C5_NUM)
		cTipFat := FPY->FPY_TIPFAT

// Não usa LOCBAC
	elseif SC5->(FIELDPOS("C5_XTIPFAT")) // Existe o campo Tipo de faturamento Pode ser RENTAL

    lPedRental :=  M->C5_XTIPFAT $ "MPRI" // Veio do RENTAL

	endif

// Pedido Gerado pelo RENTAL
	if lPedRental

    // Analisar Itens do pedido
		For nCntFor := 1 to nMaxArray

			If aCols[nCntFor][Len(aCols[nCntFor])] // não pode deletar linha do Rental
				Help( ,, "LOCM013-001",, STR0002, 1, 0,,,,,,{STR0001}) //"Desmarque as linhas marcadas para deleção." //"Este pedido foi gerado pelo modulo SIGALOC não se permite excluir itens."

				lRet := .F.
			else
           		dbSelectArea("SC6")
           		dbSetOrder(1)
           		if dbSeek(xFilial("SC6")+M->C5_NUM+aCols[nCntFor][nPItem]) // Achou o item na SC6
                	if SC6->C6_QTDVEN <> aCols[nCntFor][nPQtdVen] 
                    	// Houve alteração de quantidade
                    	if !Empty(cItens)
                        	cItens += ", "
                    	endif
                    	cItens += aCols[nCntFor][nPItem]
                    	lRet := .F.
					else
              	  		if SC6->C6_QTDLIB <> aCols[nCntFor][nPQtdLib]
              	    		// Houve alteração de quantidade liberada
					 		If cTipFat == "R"
              		    		if !Empty(cItens)
                 	     			cItens += ", "
                		  		endif
                  		  		cItens += aCols[nCntFor][nPItem]
              		      		lRet := .f.
							EndIf
						EndIf
                	endif
            	endif
			EndIf
		Next nCntFor

    	if !lREt .and. !Empty(cItens)
        	nPosVir := Rat(",", cItens)
        	if nPosVir > 0
				cItens := Stuff (cItens, nPosVir, 1, STR0003) //" e"
        	endif
			Help( ,, "LOCM013-002",, STR0007, 1, 0,,,,,,{STR0004+cItens+STR0005}) //"Retorne o(s) item(ns) " //" para sua quantidade original" //"Este pedido foi gerado pelo modulo SIGALOC não se permite alterar a quantidade" //"O pedido foi encontrado na tabela FPY. Este pedido foi gerado pelo RENTAL/SIGALOC, não se permite alterar a quantidade."
    	endif

	endif

	RestArea(aAreaSC6)
	RestArea(aArea)

return lRet
