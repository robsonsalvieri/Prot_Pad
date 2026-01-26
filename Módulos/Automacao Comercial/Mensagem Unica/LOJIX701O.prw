#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} Loji701OItens
 Funcao de retorno de itens preparados conforme Reservas recebidas 
@since 02/08/2022	
@version P12
@param	aItem	 - Array de item 
@param	aReserva - Array de reserva
@param	nValDesTot - Valor de desconto total na venda
@return aRet	 - Retorno de Array de item dividido conforme a 
                    quantidade de reserva					  
/*/
//-------------------------------------------------------------------
Function Loji701OItens(aItem, aReserva, nVlMercTot, nFrete, nValDesTot)

LOcal nX         := 0
LOcal nQuant     := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_QUANT"})
LOcal nVlrItem   := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VLRITEM"})
LOcal nVrUnit    := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VRUNIT"})
LOcal nValItDesc := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VALDESC"})
LOcal nDesc      := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_DESC"})
LOcal nDescPro   := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_DESCPRO"})
LOcal nValFre    := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_VALFRE"})
LOcal nReserva   := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_RESERVA"})
Local nPorc      := 0
Local nPorcFre   := 0
Local aAux       := {}
Local aRet       := {}
Local nLocaliz   := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_LOCALIZ"})
Local nLotectl   := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_LOTECTL"})
Local nSubLote   := Ascan(aItem[1], {|x| AllTrim(x[1]) == "LR_NLOTE"})

Default aItem       := {}
Default aReserva    := {}
Default nValDesTot  := 0 
Default nVlMercTot  := 0
Default nFrete      := 0 

    For nX := 1 to Len(aReserva)
        Aadd(aAux, Aclone(aItem[Len(aItem)]))
    NExt nX

    If Len(aItem) > 1
        For nX := 1 to Len(aItem) - 1
            Aadd(aRet, Aclone(aItem[nX]))
        NExt nX
    EndIF
        
    For nX := 1 to Len(aAux)
    
        aAux[nX][nQuant][2]     := aReserva[nX][3]

        aAux[nX][nVlrItem][2]   := aReserva[nX][3] * aAux[nX][nVrUnit][2]
     
        //desconto no item e frete
        nPorc := Round((aAux[nX][nVlrItem][2] / nVlMercTot) * 100,2)
    
        nPorcFre := Round((aAux[nX][nVlrItem][2] / aItem[Len(aItem)][nVlrItem][2]) * 100,2)

        aAux[nX][nValFre][2]    := (nFrete * nPorcFre) / 100

        If nValDesTot > 0 
            //desconto no total e frete            
            aAux[nX][nDescPro][2]   := (nValDesTot * nPorc) /100
        elseIf aAux[nX][nValItDesc][2] > 0
             //desconto no item e frete           
            aAux[nX][nDesc][2] := (aAux[nX][nVlrItem][2] / nVlMercTot) * 100
            aAux[nX][nValItDesc][2] := (aAux[nX][nValItDesc][2] * aAux[nX][nDesc][2]) / 100             
        EndIf

        aAux[nX][nReserva][2]   := aReserva[nX][2] 
        IIF(nLotectl > 0 ,aAux[nX][nLotectl][2]   := aReserva[nX][6],0) // Ajusta Lotes
        IIF(nSubLote > 0 ,aAux[nX][nSubLote][2]   := aReserva[nX][7],0) // Ajusta SubLotes
        IIF(nLocaliz > 0 ,aAux[nX][nLocaliz][2]   := aReserva[nX][8],0) // Ajusta Endereço
        Aadd(aRet, AClone(aAux[nX]))
    NExt nX
    
Return aRet
