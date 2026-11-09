#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"

/*/{Protheus.doc} FISxSenar
    Componentização da função MaFisCSLL
    Contribuição Social Sobre O Lucro Líquido
        
	@author Rafael Oliveira
    @since 03/04/2020
    @version 12.1.27
    @history 13/08/2026, Douglas Dourado, DSERFISE-14392 - Correcao da base de CSLL com deducao de ISS CFGTRIB na duplicata.
    
    @Autor da unção original -Alexandre Lemes -01/10/2012 

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
    /*/

/*MaFisCSLL-Alexandre Lemes -01/10/2012 
*/
Function FISXCSLL(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc,cExecuta)

Local aMaCalcCSL := IIf( fisExtPE('MACALCCSL') , ExecBlock("MaCalcCSL") , Array(2) )
Local nAliqSB1   := aNfItem[nItem][IT_PRD][SB_PCSLL]
Local nAliquota  := IIf(Empty(nAliqSB1),fisGetParam('MV_TXCSLL',0),nAliqSB1)
Local nDesconto  := 0
Local nDescISS	 := 0
Local nBaseDup   := 0
Local lISSAbateDup := FisISSAbatDup(aNfCab, aNFItem, nItem)
Local lTribGen := aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_CSLL)

DEFAULT cExecuta  := "BSE|ALQ|VLR"

If !lTribGen
	//Define Base CSLL
	If "BSE" $ cExecuta
		If (( fisExtPE('MACALCCSL') .And. aMaCalcCSL[1]=="S" ) .Or. ( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCSL]=="S" )) .And.;
		(aNfCab[NF_RECCSLL] $ "S|P" ) .And. ( aNfItem[nItem][IT_PRD][SB_CSLL] == " " .Or. aNfItem[nItem][IT_PRD][SB_CSLL] == "1" .Or. (aNfCab[NF_RECCSLL] == "P" .And. !fisGetParam('MV_RETEMPU',.F.)))
		//MV_RETEMPU Define a forma de calculo de retenção para empresas publicas, caso esteja = .T. passará a validar informações dos campos de retenção do cadastro de produtos e não mais do cadastro de clientes. 
			// A base de calculo da retencao eh o valor da duplicata
			// porem de acordo com a Cons. Trib. Liz, o valor do ISS nao
			// devera ser deduzido da base do PIS/COF/CSL retencao. Para
			// isso foi criado o parametro MV_DEISSBS que se estiver como
			// .T. nao sera descontado e se estiver como .F. - default sera
			nDescISS := IIf(fisGetParam('MV_DEISSBS',.f.) .And. aNfCab[NF_RECISS]=="1" .And. fisGetParam('MV_DESCISS',.f.) .And. aNfCab[NF_OPERNF]=="S" .And. fisGetParam('MV_TPABISS',"1")=="1", aNfItem[nItem][IT_VALISS] , 0 )
			nDesconto:= IIf(fisGetParam('MV_CSLLBRU',2) == "1" , (aNfItem[nItem][IT_DESCONTO]+aNfItem[nItem][IT_DESCTOT]) , 0) // Caso o parametro indique a base de calculo pelo valor bruto da nota fiscal somar o valor do desconto concedido ao total da duplicata.

			// O Configurador pode reduzir a duplicata pelo ISS antes do calculo legado.
			// Recompoe somente essa deducao para preservar a base usada pelo legado.
			nBaseDup := aNfItem[nItem][IT_BASEDUP]
			If lISSAbateDup
				nBaseDup += aNfItem[nItem][IT_VALISS]
			EndIf

			aNfItem[nItem][IT_BASECSL] := nBaseDup + IIf( aNfItem[nItem][IT_BASEDUP] > 0 , nDesconto , 0 ) + nDescISS

			if fisGetParam('MV_DEISSBS',.f.) == .F. .and. fisGetParam('MV_TPABISS',"1")=="2" .And. aNfCab[NF_OPERNF]=="S"
				aNfItem[nItem][IT_BASECSL] := aNfItem[nItem][IT_BASECSL] - aNfItem[nItem][IT_VALISS]
			endif

			If aNFItem[nItem][IT_TS][TS_IPIPC]=="2" 	// Indica se o valor do IPI deve compor a base de calculo. 1=Sim (Compoe) e 2=Nao(Nao Compoe)
				aNfItem[nItem][IT_BASECSL] -= aNfItem[nItem][IT_VALIPI]
			Endif

			// Tratamento para retirada do valor do ICMS solidario da base do CSLL
			// Verifica se o valor do ICMS Solidario esta agregado ao valor total
			If !(aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D") .And. MaFisDbST("CSL",nItem)
				aNfItem[nItem][IT_BASECSL] -= aNfItem[nItem][IT_VALSOL]
			Endif

			If aNFItem[nItem][IT_TS][TS_DBSTCSL] == "1" .And. aNFCab[NF_OPIRRF] == "EP" // Agrega o Valor do ICMS Retido - Somente para Empresa Publica
				aNfItem[nItem][IT_BASECSL] += aNfItem[nItem][IT_VALSOL]
			Endif

			//Quando operação de entrada com diferimento para orgão Publico, base de retenção deve ser sobre total da nota.
			If aNFItem[nItem][IT_TS][TS_PICMDIF]<>0 .And. aNFItem[nItem][IT_TS][TS_ICMSDIF]=="1" .And. aNFItem[nItem][IT_TS][TS_ICM] == "S"
				aNfItem[nItem][IT_BASECSL] += aNfItem[nItem][IT_ICMSDIF]
			EndIf

		Else
			aNfItem[nItem][IT_BASECSL] := 0
		EndIf
	EndIf
	//Define Aliquota CSLL
	If "ALQ" $ cExecuta
		If Empty(nAliqSB1) .Or. fisGetParam('MV_TPALCSL',"2")== "1"
			If !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCSL]=="S" .And. !Empty(aInfNat[NT_PERCCSL])
				nAliquota :=  aInfNat[NT_PERCCSL]
			EndIf

			If fisExtPE('MACALCCSL')
				If aMaCalcCSL[1]=="S" .And. !Empty(aMaCalcCSL[2])
					nAliquota := aMaCalcCSL[2]
				EndIf
			EndIf
		EndIf
		aNfItem[nItem][IT_ALIQCSL]	:= nAliquota
	EndIf

	//Define Valor CSLL
	If "VLR" $ cExecuta
		If ( fisExtPE('MACALCCSL') .And. aMaCalcCSL[1] == "S" ) .Or. ( !Empty(aNfCab[NF_NATUREZA]) .And. aInfNat[NT_CALCCSL] == "S" )
			aNfItem[nItem][IT_VALCSL] := aNfItem[nItem][IT_BASECSL]*aNfItem[nItem][IT_ALIQCSL]/100
		Else
			aNfItem[nItem][IT_VALCSL] := 0
		EndIf

		MaItArred(nItem,{"IT_VALCSL"})
	EndIf

Else

	If (nPosTrGCSLL := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_CSLL})) > 0 

		aNfItem[nItem][IT_BASECSL] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGCSLL][TG_IT_BASE]
		aNfItem[nItem][IT_ALIQCSL] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGCSLL][TG_IT_ALIQUOTA]
		aNfItem[nItem][IT_VALCSL] 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrGCSLL][TG_IT_VALOR]

	EndIf

EndIf

Return


/*/{Protheus.doc} FisISSAbatDup
Verifica se o ISS esta configurado no CFGTRIB com totalizacao subtraindo da duplicata (RE_TOTNF = "4").

@type static function
@author Douglas Dourado
@since 13/08/2026
@version 12.1.2510
@param aNfCab, array, Cabecalho da nota fiscal
@param aNfItem, array, Itens da nota fiscal
@param nItem, numeric, Indice do item processado
@return lAbate, logical, .T. se o ISS foi deduzido da duplicata via CFGTRIB
/*/
Static Function FisISSAbatDup(aNfCab, aNfItem, nItem)

Local lAbate  := .F.
Local nPosISS := 0

If aNfCab[NF_CHKTRIBLEG]
	nPosISS := FisPosTribGen(aNfItem, nItem, TRIB_ID_ISS)
	If nPosISS > 0
		If ValType(aNfItem[nItem][IT_TRIBGEN][nPosISS][TG_IT_REGRA_ESCR]) == "A"
			lAbate := (aNfItem[nItem][IT_TRIBGEN][nPosISS][TG_IT_REGRA_ESCR][RE_TOTNF] == "4")
		EndIf
	EndIf
EndIf

Return lAbate

/*/{Protheus.doc} FisPosTribGen
Retorna a posicao do tributo generico em IT_TRIBGEN via hash IT_TG_IDTRIB_IDX em O(1), com fallback aScan.

@type static function
@author Douglas Dourado
@since 13/08/2026
@version 12.1.2510
@param aNfItem, array, Itens da nota fiscal
@param nItem, numeric, Indice do item processado
@param cIdTrib, character, Identificador do tributo (ex: TRIB_ID_ISS, TRIB_ID_CSLL)
@return nPos, numeric, Posicao no array IT_TRIBGEN (0 se nao localizado)
/*/
Static Function FisPosTribGen(aNfItem, nItem, cIdTrib)

Local nPos := 0
Local cKey := AllTrim(cIdTrib)

If ValType(aNfItem[nItem][IT_TG_IDTRIB_IDX]) == "J" .And. aNfItem[nItem][IT_TG_IDTRIB_IDX]:HasProperty(cKey)
	nPos := aNfItem[nItem][IT_TG_IDTRIB_IDX][cKey]
	If ValType(nPos) == "N" .And. nPos > 0 .And. ValType(aNfItem[nItem][IT_TRIBGEN]) == "A" .And. nPos <= Len(aNfItem[nItem][IT_TRIBGEN]) .And. AllTrim(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_IDTRIB]) == cKey
		Return nPos
	EndIf
EndIf

If ValType(aNfItem[nItem][IT_TRIBGEN]) == "A"
	nPos := aScan(aNfItem[nItem][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_IDTRIB]) == cKey})
EndIf

Return nPos
