#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FIsXTPDP
    (Componentização da função MaFisTPDP - 
    TPDP - Paraiba Taxa de Processamento de Despesas Publicas
    
	@author Rafael.soliveira
    @since 17/02/2020
    @version 12.1.25
    
	@param:
	aNfCab -> Array com dados do cabeçalho da nota
	aNFItem-> Array com dados item da nota
	nItem  -> Item que esta sendo processado
	aPos - fisExtCmp   -> Objetivo da função é verificar se o campo existe no dicionário de dados
	aInfNat	-> Array com dados da narutureza
	aPE - fisExtPE	 -> Objetivo da função é verificar se o ponto de entrada existe no repositório
	aSX6 - fisGetParam	 -> Objetivo da função é obter o valor do parametro, caso parametro não exista no dicionário de dados, setorá o valor default
	aDic - fisExttab -> Objetivo da função é verificar se o campo existe no dicionário de dados
	aFunc - fisFindFunc	-> Objetivo da função é verificar se a função existe no repositório de funções
    /*/
Function FISXTPDP(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc)
    aNfItem[nItem][IT_BASTPDP]	:= 0
    aNfItem[nItem][IT_ALITPDP]	:= 0
    aNfItem[nItem][IT_VALTPDP]	:= 0

    //Verifica se algum tributo genérico com ID do TPDP enquadrado, e zera referências para não calcular em duplicidade
    If !(aNfCab[NF_CHKTRIBLEG] .And. ChkTribLeg(aNFItem, nItem, TRIB_ID_TPDP))

        If fisExtCmp('12.1.2310', .T.,'SA1','A1_TPDP') .And. fisExtCmp('12.1.2310', .T.,'SB1','B1_TPDP') .And. aNfCab[NF_OPERNF] == "S" .And. SA1->A1_TPDP == "1" .And. ;
            aNfItem[nItem][IT_PRD][SB_TPDP] == "1" .And. aNfCab[NF_UFDEST]=="PB" .And. aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .And. aNfItem[nItem][IT_VALMERC] > 0

            aNfItem[nItem][IT_BASTPDP]	:= aNfItem[nItem][IT_VALMERC]
            aNfItem[nItem][IT_ALITPDP]	:= fisGetParam('MV_ALITPDP', 0)

            If ( aNfItem[nItem][IT_BASTPDP] * ( fisGetParam('MV_ALITPDP', 0) / 100 ) ) >= 30000
                aNfItem[nItem][IT_VALTPDP]	:= 30000
            Else
                aNfItem[nItem][IT_VALTPDP] := ( aNfItem[nItem][IT_BASTPDP] * ( fisGetParam('MV_ALITPDP', 0) / 100 ) )
            Endif
            MaItArred(nItem,{"IT_VALTPDP"})
        EndIf

    EndIF
Return
