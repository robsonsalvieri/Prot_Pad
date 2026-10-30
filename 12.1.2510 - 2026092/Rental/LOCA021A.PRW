#INCLUDE "TOTVS.CH"

// Tipos de Faturamento usados na Simulação e no estorno
#DEFINE FAT_RECORRENTE  '1'
#DEFINE FAT_CUSTO		'2'
#DEFINE FAT_PRORATA     '3'
#DEFINE FAT_MEDICAO     '4'
#DEFINE FAT_FRETE       '5'
#DEFINE FAT_REMESSA     '6'
/*/{Protheus.doc} LOCA021APZ
Inclui no Array da FPZ os IDs da FH2 rateando o valor pelo itens
@type function
@version  25.10
@author Alexandre Circenis
@since 25/03/2026
@param aFPZ, array, Array para gerar os dados na FPZ
@param aBens, array, Array com os Bens da Fh2 1ue serão incluidos no array da FPZ
@param nValUnit, numeric, Valor unitário a ser faturado
@param nSaldo, numeric, Valor a ser rateado
@param dDtIni, date, Data Inicial do Periodo
@param dDtFim, date, Data Final do Perido
@param cItem, character, Item da SC6 ao qual os bens serão adicionados
@param cTES, character, TES usada na Remessa
@param lClaVaL, logical, Utiliza A.S. como Classe de valor 
@param cExtra, character, Vem do custo Extra
@param cPerloca, character, Period de Locacao
@param nRecnoFQZ, numeric, Numero do registro da tabela FQZ ou zero se não tiver Pro-rata
@param nRecnoFPG, numeric, Numero do registro da tabela FPG ou zero se não tiver custo extra sendo faturado
@param cOrigem, character, Indica a origem do Registro Faturado (1=Recorrente, 2=Custo Extra, 3=Pro-rata, 4=Medicao, 5=Frete, 6=Remessa)
@param dtProxFat, date, Data estimada para o proximo faturamento
@param dGeraEm, date, data do novo Gera Em 
/*/
Function LOCA021APZ(aFPZ, aBens, nValUnit, nSaldo, dDtIni, dDtFim, cItem, cTES, lClaVaL,cExtra, cPerloca, nRecnoFQZ, nRecnoFPG, cOrigem,  dtProxFat, dGeraEm)
Local nX := 0
Local cItemFPZ := Loca021AIt(aFPZ, cItem) // Proximo Item do item para FPZ

DEFAULT dGeraEm := Ctod('//')

    for nX := 1 to Len(aBens)-1
		nSaldo -= nValunit * aBens[nX, 3]
		Aadd(aFPZ,Aclone( ItemFPZ(aBens[nX], dDtIni, dDtFim, cItem, cItemFPZ, cPerLoca, nValUnit, nValunit * aBens[nX, 3] , cTes, cExtra,;
		 lClaVal, nRecnoFQZ, nRecnoFPG, cOrigem, dtProxFat, dGeraEm)))
		cItemFPZ := Soma1( cItemFPZ)
	next
	
	Aadd(aFPZ,Aclone( ItemFPZ(aBens[nX], dDtIni, dDtFim, cItem, cItemFPZ, cPerLoca,  nValUnit, nSaldo, cTes, cExtra ,  lClaVal, nRecnoFQZ, nRecnoFPG, cOrigem,  dtProxFat, dGeraEm)))

Return

/*/{Protheus.doc} ItemFPZ
Gera array para item da FPZ
@type function
@version 25.10
@author Alexandre Circenis
@since 25/03/2026
@param aProd, array, Array com os dados do produto a ser incluido n FPZ
@param dDtIni, character, Data de Inicio do Periodo
@param dDtFim, character, Data de Final de Periodo 
@param cItem, character, Item da SC6
@param cItemFPZ, character, Item da FPZ
@param cPerLoca, character, Periodo de Locacao
@param nValUnit, numeric, Valor unitario
@param nValTot, numeric, Valor total
@param cTes, character, TES de remessa
@param cExtra, character, Veio do custo extra
@param lClaVal, logical, Indica se se irá usar o Código da A.S. como Classe de Valor
@return variant, Array com os dados da Linha da FPZ
/*/
Static Function ItemFPZ(aProd, dDtIni, dDtFim, cItem, cItemFPZ, cPerLoca, nValUnit, nValTot , cTes, cExtra, lClaVal, nRecnoFQZ, nRecnoFPG, cOrigem, dtProxFat , dGeraEm)
Local aItemFPZ := {}
Local cTipo    := ""
DEFAULT cOrigem := '1' // 1=Faturamento Recorrente;2=Custo Extra;3=Pro-Rata;4=Medicao,5=Frete; Branco outras Origens
DEFAULT nRecnoFPG := 0
DEFAULT nRecnoFQZ := 0
DEFAULT dtProxFat :=  Ctod("//")
DEFAULT dGeraEm   := CTod("//")

	if cOrigem = '1'
		cTipo := "Recorrente"
	elseif cOrigem = '2'
		cTipo := "Custo"
	elseif cOrigem = '3'
		cTipo := "Pro-Rata"
	elseif cOrigem = '5'
		cTipo := 'FRETE'
	endif

    Aadd(aItemFPZ, {"FPZ_FILIAL"	, XFILIAL("SC6")	,	NIL })
	Aadd(aItemFPZ, {"FPZ_PEDVEN"	, ""				, 	NIL })
	Aadd(aItemFPZ, {"FPZ_DTPED"	    , dDataBase			, 	NIL })
	Aadd(aItemFPZ, {"FPZ_DTINI"	    , dDtIni	, 	NIL })
	Aadd(aItemFPZ, {"FPZ_DTFIM"	    , dDtFim	, 	NIL })
    Aadd(aItemFPZ, {"FPZ_FROTA"		, aProd[1]      	,	NIL })
	Aadd(aItemFPZ, {"FPZ_PROJET"	, FPA->FPA_PROJET	,	NIL })
	Aadd(aItemFPZ, {"FPZ_PRVFAT"	, FPA->FPA_ULTFAT	,	NIL })
	Aadd(aItemFPZ, {"FPZ_ITEM"		, cItem 			,	NIL })
	Aadd(aItemFPZ, {"FPZ_AS"		, FPA->FPA_AS	    , 	NIL }) // Rossana
	Aadd(aItemFPZ, {"FPZ_EXTRA"		, cExtra			,	NIL })
	Aadd(aItemFPZ, {"FPZ_PERLOC"	, cPerloca			,	NIL })
	Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO	,	NIL })
	If FPZ->(FIELDPOS("FPZ_GERAAT")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
		Aadd(aItemFPZ, {"FPZ_GERAAT", FPA->FPA_GERAEM   ,	NIL })
	EndIf

	if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0

		Aadd(aItemFPZ, {"FPZ_ITMFPZ", cItemFPZ ,	NIL })
		Aadd(aItemFPZ, {"FPZ_QUANT" , aProd[3],	NIL })
		Aadd(aItemFPZ, {"FPZ_VALUNI", nValUnit,	NIL })
		Aadd(aItemFPZ, {"FPZ_PROD"  , aProd[2],	NIL })
		Aadd(aItemFPZ, {"FPZ_VIAGEM", FPA->FPA_VIAGEM,	NIL })
		if cExtra <> 'S'
			Aadd(aItemFPZ, {"FPZ_DIAS"  , dDtFim - dDtIni + 1,	NIL })
		endif
		Aadd(aItemFPZ, {"FPZ_TOTAL" , nValTot,	NIL })
		Aadd(aItemFPZ, {"FPZ_OBRA"  , FPA->FPA_OBRA,	NIL })

		if lClaVal
			Aadd(aItemFPZ, {"FPZ_CLVL"  , FPA->FPA_AS,	NIL })
		endif
		Aadd(aItemFPZ, {"FPZ_GERAEM", dGeraEm , NIL})		
		Aadd(aItemFPZ, {"FPZ_TES"  , cTES     , NIL})
		Aadd(aItemFPZ, {"TIPO"     , cTipo    , NIL})
		Aadd(aItemFPZ, {"DTPROXFAT", dtProxFat, NIL})
		Aadd(aItemFPZ,{ "RECNOFQZ" , nRecnoFQZ, NIL})
		Aadd(aItemFPZ,{ "RECNOFPG" , nRecnoFPG, NIL})
		Aadd(aItemFPZ,{ "CUSTNEG"  , ""       ,NIL})
		Aadd(aItemFPZ, {"FPZ_PRXFAT" , dtProxFat    	, NIL})
		Aadd(aItemFPZ, {"FPZ_ORIGEM" , cOrigem    		, NIL})
		Aadd(aItemFPZ, {"FPZ_PERINI" , FPA->FPA_DTINI	, NIL})
		Aadd(aItemFPZ,{ "FPZ_PERFIM" , FPA->FPA_DTFIM	, NIL})
		Aadd(aItemFPZ,{ "FPZ_ULTFAT" , FPA->FPA_ULTFAT	, NIL})
		Aadd(aItemFPZ,{ "FPZ_LOCDIA" , FPA->FPA_LOCDIA  , NIL})
	endif
	
	if FPZ->(FIELDPOS("FPZ_IDPO")) > 0
		Aadd(aItemFPZ,{ "FPZ_IDPO"   , FPA->FPA_IDPO	, NIL})
		Aadd(aItemFPZ,{ "FPZ_DPTCLI" , FPA->FPA_DPTCLI  , NIL})
	endif
Return aItemFPZ

/*/{Protheus.doc} Loca021AIt
Retorno o Proximo item da FPZ relativo do itens da SC6
@type function
@version 25.10 
@author Alexandre Circenis
@since 25/03/2026
@param aFPZ, array, Array de itens da FPZ
@param cItem, character, Item da SC6
@return variant, Codigo do novo item da FPZ
/*/
Function Loca021AIt(aFPZ, cItem)
Local nX
Local cItemFPZ := Criavar("FPZ_ITMFPZ")
Local nPosItem

for nX := 1 to Len(aFPZ)
	nPosItem := aScan(aFPZ[nX], {|x| x[1] = "FPZ_ITEM" })
	if aFPZ[ nX, nPosItem, 2] = cItem .and.  cItemFPZ < aFPZ[ nX, aScan(aFPZ[nX], {|x| x[1] = "FPZ_ITMFPZ" }), 2]
		cItemFPZ := aFPZ[ nX, aScan(aFPZ[nX], {|x| x[1] = "FPZ_ITMFPZ" }), 2]
	endif
next nX

cItemFPZ := Soma1(cItemFPZ)

Return cItemFPZ

/*/{Protheus.doc} Loca021AAGL
Função para atualizar os itens da FPZ quando houver aglutinação na SC6
Atualiza o array de itens da aFPZ (Usado no LOCA021)
@type function
@version 25.10
@author Alexandre Circenis
@since 11/06/2026
@param aFPZ, array, Itens da FPZ
@param cItem, character, Numero do Item qua gerou a aglutinação

/*/
Function Loca021AAGL(aFPZ, cItem )
Local cItemFPZ := Criavar("FPZ_ITMFPZ")
Local nX

for nX := 1 to Len(aFPZ)
	cItemFPZ := Soma1(cItemFPZ)
	aFPZ[ nX, aScan(aFPZ[nX], {|x| x[1] = "FPZ_ITEM" }), 2] := cItem
	aFPZ[ nX, aScan(aFPZ[nX], {|x| x[1] = "FPZ_ITMFPZ" }), 2] := cItemFPZ

next

REturn
