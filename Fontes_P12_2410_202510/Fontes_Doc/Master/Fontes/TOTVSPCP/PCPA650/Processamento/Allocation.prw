#INCLUDE "TOTVS.CH"

#DEFINE EST_G1_COMP     1
#DEFINE EST_G1_QUANT    2
#DEFINE EST_G1_TRT      3
#DEFINE EST_QTDFIXA     4
#DEFINE EST_G1_PERDA    5
#DEFINE EST_G1_FANTASM  6
#DEFINE EST_PRODMOD     7
#DEFINE EST_G1_POTENCI  8
#DEFINE EST_RECNOSB1    9
#DEFINE EST_LOCPAD     10
#DEFINE EST_TAMANHO    10

#DEFINE EMP_D4_FILIAL   1
#DEFINE EMP_D4_COD      2
#DEFINE EMP_D4_LOCAL    3
#DEFINE EMP_D4_OP       4
#DEFINE EMP_D4_DATA     5
#DEFINE EMP_D4_QSUSP    6
#DEFINE EMP_D4_SITUACA  7
#DEFINE EMP_D4_QTDEORI  8
#DEFINE EMP_D4_QUANT    9
#DEFINE EMP_D4_TRT     10
#DEFINE EMP_D4_LOTECTL 11
#DEFINE EMP_D4_NUMLOTE 12
#DEFINE EMP_D4_DTVALID 13
#DEFINE EMP_D4_OPORIG  14
#DEFINE EMP_D4_QTSEGUM 15
#DEFINE EMP_D4_ORDEM   16
#DEFINE EMP_D4_POTENCI 17
#DEFINE EMP_D4_SEQ     18
#DEFINE EMP_D4_NUMPVBN 19
#DEFINE EMP_D4_ITEPVBN 20
#DEFINE EMP_D4_SLDEMP  21
#DEFINE EMP_D4_SLDEMP2 22
#DEFINE EMP_D4_EMPROC  23
#DEFINE EMP_D4_CBTM    24
#DEFINE EMP_D4_CODLAN  25
#DEFINE EMP_D4_IDDCF   26
#DEFINE EMP_D4_PRODUTO 27
#DEFINE EMP_D4_ROTEIRO 28
#DEFINE EMP_D4_OPERAC  29
#DEFINE EMP_D4_CODAEN  30
#DEFINE EMP_D4_QTNECES 31
#DEFINE EMP_D4_PRDORG  32
#DEFINE EMP_TAMANHO    32

#DEFINE SLD_PRODUTO     1
#DEFINE SLD_LOCAL       2
#DEFINE SLD_QUANTIDADE  3
#DEFINE SLD_QTSEGUM     4
#DEFINE SLD_TIPO        5
#DEFINE SLD_TAMANHO     5

/*/{Protheus.doc} Allocation
Classe com as regras de negócio para manipulação dos empenhos (SD4)

@author lucas.franca
@since 29/11/2021
@version P12
@example
	//Exemplo de utilização gerando empenho a partir da estrutura de produto:
	oEmpenho := Allocation():New()
	oEmpenho:cargaEstrutura()
	Begin Transaction
		oEmpenho:gravar()
	End Transaction
	oEmpenho:Destroy()
	FreeObj(oEmpenho)

	//Exemplo de utilização sem gerar empenho pela estrutura:
	oEmpenho := Allocation():New()
	oEmpenho:adicionar() //Chamar uma vez para cada empenho desejado
	Begin Transaction
		oEmpenho:gravar()
	End Transaction
	oEmpenho:clear()
	//Se desejar adicionar novos empenhos para outras OPs, repetir o processo oEmpenho:adicionar() e oEmpenho:gravar().
	//Após incluir todos os empenhos
	oEmpenho:Destroy()
	FreeObj(oEmpenho)
	
/*/
Class Allocation
	
	DATA cARQPROD   AS Character
	DATA cFilSB2    AS Character
	DATA cFilSD4    AS Character
	DATA cTPHR      AS Character
	DATA cUNIDMOD   AS Character
	DATA cRotPad    AS Character
	DATA lPRODMOD   AS Logic
	DATA oBaseProd  AS Object
	DATA oEmpenhos  AS Object
	DATA oPotProd   AS Object
	DATA oProdSGF   AS Object
	DATA oQryEstrut AS Object
	DATA oRevProd   AS Object
	DATA oSaldos    AS Object
	DATA oTamanhos  AS Object

	Method New() Constructor
	Method Clear()
	Method Destroy()
	Method adicionar(cCod  , cLocal  , cOP     , dData   , nQSusp  , cSituaca, nQtdeOri, nQuant  ,;
	                 cTRT  , cLoteCTL, cNumLote, dDtValid, cOPOrig , nQtSegum, cOrdem  , nPotenci,;
	                 cSeq  , cNumPvBn, cItePvBn, nSldEmp , nSldEmp2, nEmProc , cCBTM   , cCodLan ,;
	                 cIDDCF, cProduto, cRoteiro, cOperac , cCodAEN , nQtNeces, cPrdOrg)
	Method arredondar(cProduto, nQuant)
	Method buscaEstrutura(cProduto, cRevisao, dData)
	Method buscaOperacao(cProdPai, cRoteiro, cComp, cTRT)
	Method calculaMOD(nQtdEst, nQtdPai, lFixVar)
	Method calculaPotencia(cProduto, nQuant, nFPotEstru)
	Method calculaQtdCompon(cProdPai, aCompon, nQtdPai)
	Method cargaEstrutura(cProduto, nQuant, cOP, cRevisao, dDataIni, cRoteiro, cProdOP)
	Method cargaParametros()
	Method cargaTamanhos()
	Method gravar(cTpOp)
	Method gravarSaldos(cTpOp)
	Method potenciaProduto(cProduto)
	Method qtdBaseProduto(cProduto)
	Method revisaoProduto(cProduto)
	Method setSaldo(cProduto, cLocal, nQuant, nQtSegum)

EndClass

/*/{Protheus.doc} New
Método construtor da classe.

@author lucas.franca
@since 29/11/2021
@version P12
@return Self, Object, Instância da classe Allocation
/*/
Method New() Class Allocation
	
	Self:cargaParametros()
	Self:cargaTamanhos()

	Self:cFilSB2    := Nil
	Self:cFilSD4    := Nil
	Self:cRotPad    := StrZero(1, Self:oTamanhos["C2_ROTEIRO"][1])
	Self:oBaseProd  := JsonObject():New()
	Self:oEmpenhos  := JsonObject():New()
	Self:oPotProd   := JsonObject():New()
	Self:oProdSGF   := JsonObject():New()
	Self:oRevProd   := JsonObject():New()
	Self:oSaldos    := JsonObject():New()
	

Return Self

/*/{Protheus.doc} clear
Limpa os dados exclusivos do empenho e deixa a classe pronta para um novo processamento.

@author lucas.franca
@since 29/11/2021
@version P12
@return Nil
/*/
Method clear() Class Allocation
	
	Local aNames := {}
	Local nIndex := 0
	Local nTotal := 0

	aNames := Self:oEmpenhos:GetNames()
	nTotal := Len(aNames)
	For nIndex := 1 To nTotal
		aSize(Self:oEmpenhos[aNames[nIndex]], 0)
		Self:oEmpenhos[aNames[nIndex]] := Nil
		Self:oEmpenhos:delName(aNames[nIndex])
	Next nIndex 

	aSize(aNames, 0)

	aNames := Self:oSaldos:GetNames()
	nTotal := Len(aNames)
	For nIndex := 1 To nTotal 
		aSize(Self:oSaldos[aNames[nIndex]], 0)
		Self:oSaldos[aNames[nIndex]] := Nil
		Self:oSaldos:delName(aNames[nIndex])
	Next nIndex 
	aSize(aNames, 0)

	Self:cFilSB2 := Nil
	Self:cFilSD4 := Nil
	
Return Self

/*/{Protheus.doc} Destroy
Limpa todas as informações da classe. Não permite reutilização da instância da classe após execução do Destroy.

@author lucas.franca
@since 06/12/2021
@version P12
@return Nil
/*/
Method Destroy() Class Allocation 

	Self:clear()
	FreeObj(Self:oEmpenhos )
	FreeObj(Self:oBaseProd )
	FreeObj(Self:oPotProd  )
	FreeObj(Self:oProdSGF  )
	If Self:oQryEstrut != Nil 
		Self:oQryEstrut:Destroy()
		FreeObj(Self:oQryEstrut)
	EndIf
	FreeObj(Self:oRevProd  )
	FreeObj(Self:oSaldos   )
	FreeObj(Self:oTamanhos )

Return

/*/{Protheus.doc} adicionar
Adiciona novas informações de um empenho para inclusão

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 - cCod    , Character, Conteúdo da coluna D4_COD
@param 02 - cLocal  , Character, Conteúdo da coluna D4_LOCAL
@param 03 - cOP     , Character, Conteúdo da coluna D4_OP
@param 04 - dData   , Date     , Conteúdo da coluna D4_DATA
@param 05 - nQSusp  , Numeric  , Conteúdo da coluna D4_QSUSP
@param 06 - cSituaca, Character, Conteúdo da coluna D4_SITUACA
@param 07 - nQtdeOri, Numeric  , Conteúdo da coluna D4_QTDEORI
@param 08 - nQuant  , Numeric  , Conteúdo da coluna D4_QUANT
@param 09 - cTRT    , Character, Conteúdo da coluna D4_TRT
@param 10 - cLoteCTL, Character, Conteúdo da coluna D4_LOTECTL
@param 11 - cNumLote, Character, Conteúdo da coluna D4_NUMLOTE
@param 12 - dDtValid, Date     , Conteúdo da coluna D4_DTVALID
@param 13 - cOPOrig , Character, Conteúdo da coluna D4_OPORIG
@param 14 - nQtSegum, Numeric  , Conteúdo da coluna D4_QTSEGUM
@param 15 - cOrdem  , Character, Conteúdo da coluna D4_ORDEM
@param 16 - nPotenci, Numeric  , Conteúdo da coluna D4_POTENCI
@param 17 - cSeq    , Character, Conteúdo da coluna D4_SEQ
@param 18 - cNumPvBn, Character, Conteúdo da coluna D4_NUMPVBN
@param 19 - cItePvBn, Character, Conteúdo da coluna D4_ITEPVBN
@param 20 - nSldEmp , Numeric  , Conteúdo da coluna D4_SLDEMP
@param 21 - nSldEmp2, Numeric  , Conteúdo da coluna D4_SLDEMP2
@param 22 - nEmProc , Numeric  , Conteúdo da coluna D4_EMPROC
@param 23 - cCBTM   , Character, Conteúdo da coluna D4_CBTM
@param 24 - cCodLan , Character, Conteúdo da coluna D4_CODLAN
@param 25 - cIDDCF  , Character, Conteúdo da coluna D4_IDDCF
@param 26 - cProduto, Character, Conteúdo da coluna D4_PRODUTO
@param 27 - cRoteiro, Character, Conteúdo da coluna D4_ROTEIRO
@param 28 - cOperac , Character, Conteúdo da coluna D4_OPERAC
@param 29 - cCodAEN , Character, Conteúdo da coluna D4_CODAEN
@param 30 - nQtNeces, Numeric  , Conteúdo da coluna D4_QTNECES
@param 31 - cPrdOrg , Character, Conteúdo da coluna D4_PRDORG
@return Nil
/*/
Method adicionar(cCod  , cLocal  , cOP     , dData   , nQSusp  , cSituaca, nQtdeOri, nQuant  ,;
                 cTRT  , cLoteCTL, cNumLote, dDtValid, cOPOrig , nQtSegum, cOrdem  , nPotenci,;
                 cSeq  , cNumPvBn, cItePvBn, nSldEmp , nSldEmp2, nEmProc , cCBTM   , cCodLan ,;
                 cIDDCF, cProduto, cRoteiro, cOperac , cCodAEN , nQtNeces, cPrdOrg) Class Allocation
	
	Local cChave := ""

	/*
		Chave única da SD4:
		D4_FILIAL, D4_COD, D4_OP, D4_TRT, D4_LOTECTL, D4_NUMLOTE, D4_OPORIG, D4_LOCAL
		Se já existir o empenho com a mesma chave, irá somar a quantidade.
	*/

	If Self:cFilSD4 == Nil
		Self:cFilSD4 := xFilial("SD4")
	EndIf

	//Padroniza o tamanho das informações do tipo CHAR.
	cCod     := PadR(cCod    , Self:oTamanhos["D4_COD"    ][1])
	cLocal   := PadR(cLocal  , Self:oTamanhos["D4_LOCAL"  ][1])
	cOP      := PadR(cOP     , Self:oTamanhos["D4_OP"     ][1])
	cSituaca := PadR(cSituaca, Self:oTamanhos["D4_SITUACA"][1])
	cTRT     := PadR(cTRT    , Self:oTamanhos["D4_TRT"    ][1])
	cLoteCTL := PadR(cLoteCTL, Self:oTamanhos["D4_LOTECTL"][1])
	cNumLote := PadR(cNumLote, Self:oTamanhos["D4_NUMLOTE"][1])
	cOPOrig  := PadR(cOPOrig , Self:oTamanhos["D4_OPORIG" ][1])
	cOrdem   := PadR(cOrdem  , Self:oTamanhos["D4_ORDEM"  ][1])
	cSeq     := PadR(cSeq    , Self:oTamanhos["D4_SEQ"    ][1])
	cNumPvBn := PadR(cNumPvBn, Self:oTamanhos["D4_NUMPVBN"][1])
	cItePvBn := PadR(cItePvBn, Self:oTamanhos["D4_ITEPVBN"][1])
	cCBTM    := PadR(cCBTM   , Self:oTamanhos["D4_CBTM"   ][1])
	cCodLan  := PadR(cCodLan , Self:oTamanhos["D4_CODLAN" ][1])
	cIDDCF   := PadR(cIDDCF  , Self:oTamanhos["D4_IDDCF"  ][1])
	cProduto := PadR(cProduto, Self:oTamanhos["D4_PRODUTO"][1])
	cRoteiro := PadR(cRoteiro, Self:oTamanhos["D4_ROTEIRO"][1])
	cOperac  := PadR(cOperac , Self:oTamanhos["D4_OPERAC" ][1])
	cCodAEN  := PadR(cCodAEN , Self:oTamanhos["D4_CODAEN" ][1])
	cPrdOrg  := PadR(cPrdOrg , Self:oTamanhos["D4_PRDORG" ][1])

	//Verifica os numéricos. Se estiverem NIL considera como 0
	Iif(nQSusp   == Nil, 0, nQSusp  )
	Iif(nQtdeOri == Nil, 0, nQtdeOri)
	Iif(nQuant   == Nil, 0, nQuant  )
	Iif(nQtSegum == Nil, ConvUm(cCod, nQuant, 0, 2 ), nQtSegum)
	Iif(nPotenci == Nil, 0, nPotenci)
	Iif(nSldEmp  == Nil, 0, nSldEmp )
	Iif(nSldEmp2 == Nil, 0, nSldEmp2)
	Iif(nEmProc  == Nil, 0, nEmProc )
	Iif(nQtNeces == Nil, 0, nQtNeces)

	//Campos data, se estiverem Nil considera como "  /  /    "
	Iif(dData    == Nil, StoD(""), dData   )
	Iif(dDtValid == Nil, StoD(""), dDtValid)

	//Monta a chave do registro
	cChave := Self:cFilSD4          +;
	          "|" + RTrim(cCod)     +;
	          "|" + RTrim(cOP)      +;
	          "|" + RTrim(cTRT)     +;
	          "|" + RTrim(cLoteCTL) +;
	          "|" + RTrim(cNumLote) +;
	          "|" + RTrim(cOPOrig)  +;
	          "|" + RTrim(cLocal)   

	If !Self:oEmpenhos:hasProperty(cChave)
		//Não existe esta chave. Cria o array de dados.
		Self:oEmpenhos[cChave] := Array(EMP_TAMANHO)

		Self:oEmpenhos[cChave][EMP_D4_FILIAL ] := Self:cFilSD4
		Self:oEmpenhos[cChave][EMP_D4_COD    ] := cCod
		Self:oEmpenhos[cChave][EMP_D4_LOCAL  ] := cLocal
		Self:oEmpenhos[cChave][EMP_D4_OP     ] := cOP
		Self:oEmpenhos[cChave][EMP_D4_DATA   ] := dData
		Self:oEmpenhos[cChave][EMP_D4_QSUSP  ] := nQSusp
		Self:oEmpenhos[cChave][EMP_D4_SITUACA] := cSituaca
		Self:oEmpenhos[cChave][EMP_D4_TRT    ] := cTRT
		Self:oEmpenhos[cChave][EMP_D4_LOTECTL] := cLoteCTL
		Self:oEmpenhos[cChave][EMP_D4_NUMLOTE] := cNumLote
		Self:oEmpenhos[cChave][EMP_D4_DTVALID] := dDtValid
		Self:oEmpenhos[cChave][EMP_D4_OPORIG ] := cOPOrig
		Self:oEmpenhos[cChave][EMP_D4_ORDEM  ] := cOrdem
		Self:oEmpenhos[cChave][EMP_D4_POTENCI] := nPotenci
		Self:oEmpenhos[cChave][EMP_D4_SEQ    ] := cSeq
		Self:oEmpenhos[cChave][EMP_D4_NUMPVBN] := cNumPvBn
		Self:oEmpenhos[cChave][EMP_D4_ITEPVBN] := cItePvBn
		Self:oEmpenhos[cChave][EMP_D4_SLDEMP ] := nSldEmp
		Self:oEmpenhos[cChave][EMP_D4_SLDEMP2] := nSldEmp2
		Self:oEmpenhos[cChave][EMP_D4_EMPROC ] := nEmProc
		Self:oEmpenhos[cChave][EMP_D4_CBTM   ] := cCBTM
		Self:oEmpenhos[cChave][EMP_D4_CODLAN ] := cCodLan
		Self:oEmpenhos[cChave][EMP_D4_IDDCF  ] := cIDDCF
		Self:oEmpenhos[cChave][EMP_D4_PRODUTO] := cProduto
		Self:oEmpenhos[cChave][EMP_D4_ROTEIRO] := cRoteiro
		Self:oEmpenhos[cChave][EMP_D4_OPERAC ] := cOperac
		Self:oEmpenhos[cChave][EMP_D4_CODAEN ] := cCodAEN
		Self:oEmpenhos[cChave][EMP_D4_QTNECES] := nQtNeces
		Self:oEmpenhos[cChave][EMP_D4_PRDORG ] := cPrdOrg
		Self:oEmpenhos[cChave][EMP_D4_QUANT  ] := nQuant
		Self:oEmpenhos[cChave][EMP_D4_QTDEORI] := nQtdeOri
		Self:oEmpenhos[cChave][EMP_D4_QTSEGUM] := nQtSegum
	
	Else
		//Soma as quantidades no registro já existente
		Self:oEmpenhos[cChave][EMP_D4_QTDEORI] += nQtdeOri
		Self:oEmpenhos[cChave][EMP_D4_QUANT  ] += nQuant
		Self:oEmpenhos[cChave][EMP_D4_QTSEGUM] += nQtSegum
	EndIf

	//Atualiza saldos em memória para atualização posterior
	Self:setSaldo(cCod, cLocal, nQuant, nQtSegum)

Return

/*/{Protheus.doc} arredondar
Faz o arredondamento da quantidade do empenho com base nos parâmetros do produto

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para buscar a estrutura.
@param 02 nQuant  , Numeric  , Quantidade calculada do produto
@return nQuant    , Numeric  , Quantidade arredondada.
/*/
Method arredondar(cProduto, nQuant) Class Allocation

	//Verifica necessidade de posicionar o produto
	If SB1->(B1_FILIAL+B1_COD) != xFilial("SB1")+cProduto
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
	EndIf

	Do Case
		Case SB1->B1_TIPODEC == "N" //Normal
			//Arredonda de acordo com a qtd. de decimais da estrutura.
			nQuant := Round(nQuant, Self:oTamanhos["G1_QUANT"][2])
		
		Case SB1->B1_TIPODEC == "A" //Arredonda
			//Se os decimais forem >= a 5, arredonda para cima. Caso contrário, arredonda para baixo.
			nQuant := Round(nQuant, 0)
		
		Case SB1->B1_TIPODEC == "I" //Incrementa
			//Se houver qualquer quantidade decimal, irá arredondar para cima.
			nQuant := Ceiling(nQuant)
		
		Case SB1->B1_TIPODEC == "T" //Trunca
			//Desconsidera os decimais, sem fazer arredondamento p/ cima.
			nQuant := Int(nQuant)
			
	EndCase

Return nQuant

/*/{Protheus.doc} buscaEstrutura
Busca a estrutura do produto

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para buscar a estrutura.
@param 02 cRevisao, Character, Revisão do produto para busca da estrutura.
@param 03 dData   , Date     , Data para considerar a validade dos componentes.
@return aEstrutura, Array    , Array com os componentes do produto
/*/
Method buscaEstrutura(cProduto, cRevisao, dData) Class Allocation
	
	Local aEstrutura := {}
	Local cAlias     := ""
	Local cQuery     := ""
	Local nIndex     := 0
	Local nPosPar    := 0

	If Self:oQryEstrut == Nil 
		cQuery := " SELECT SG1.G1_COMP, "
		cQuery +=        " SG1.G1_QUANT, "
		cQuery +=        " SG1.G1_TRT, "
		cQuery +=        " SG1.G1_FIXVAR, "
		cQuery +=        " SG1.G1_PERDA, "
		cQuery +=        " SG1.G1_FANTASM, "
		cQuery +=        " SG1.G1_POTENCI, "
		cQuery +=        " SB1.B1_FANTASM, "
		cQuery +=        " SB1.B1_CCCUSTO, "
		cQuery +=        " SB1.R_E_C_N_O_ RECSB1, "
		If Self:cARQPROD == "SBZ"
			cQuery +=    " COALESCE(SBZ.BZ_LOCPAD, SB1.B1_LOCPAD) LOCPAD "
		Else
			cQuery +=    " SB1.B1_LOCPAD LOCPAD "
		EndIf
		cQuery +=   " FROM " + RetSqlName("SG1") + " SG1 "
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 " //SB1 relacionada com o COMPONENTE
		cQuery +=     " ON SB1.B1_FILIAL  = ? "
		cQuery +=    " AND SB1.B1_COD     = SG1.G1_COMP "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB1.B1_MSBLQL  <> '1' "
		If Self:cARQPROD == "SBZ"
			cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ "
			cQuery +=   " ON SBZ.BZ_FILIAL  = ? "
			cQuery +=  " AND SBZ.BZ_COD     = SB1.B1_COD "
			cQuery +=  " AND SBZ.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery +=  " WHERE SG1.G1_FILIAL  = ? "
		cQuery +=    " AND SG1.G1_COD     = ? "
		cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SG1.G1_INI     <= ? "
		cQuery +=    " AND SG1.G1_FIM     >= ? "
		cQuery +=    " AND SG1.G1_REVINI  <= ? "
		cQuery +=    " AND SG1.G1_REVFIM  >= ? "
		cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		Self:oQryEstrut := FwExecStatement():New(cQuery)
	EndIf

	If Empty(cRevisao)
		cRevisao := Self:revisaoProduto(cProduto)
	EndIf

	nPosPar++
	Self:oQryEstrut:setString(nPosPar, xFilial("SB1")) //B1_FILIAL
	
	If Self:cARQPROD == "SBZ"
		nPosPar++
		Self:oQryEstrut:setString(nPosPar, xFilial("SBZ")) //BZ_FILIAL
	EndIf

	nPosPar++
	Self:oQryEstrut:setString(nPosPar, xFilial("SG1")) //G1_FILIAL
	nPosPar++
	Self:oQryEstrut:setString(nPosPar, cProduto      ) //G1_COD
	nPosPar++
	Self:oQryEstrut:setDate(  nPosPar, dData         ) //G1_INI
	nPosPar++
	Self:oQryEstrut:setDate(  nPosPar, dData         ) //G1_FIM
	nPosPar++
	Self:oQryEstrut:setString(nPosPar, cRevisao      ) //G1_REVINI
	nPosPar++
	Self:oQryEstrut:setString(nPosPar, cRevisao      ) //G1_REVFIM
	
	cAlias := Self:oQryEstrut:openAlias()

	TcSetField(cAlias, "G1_QUANT"  , "N", Self:oTamanhos["G1_QUANT"  ][1], Self:oTamanhos["G1_QUANT"  ][2])
	TcSetField(cAlias, "G1_PERDA"  , "N", Self:oTamanhos["G1_PERDA"  ][1], Self:oTamanhos["G1_PERDA"  ][2])
	TcSetField(cAlias, "G1_POTENCI", "N", Self:oTamanhos["G1_POTENCI"][1], Self:oTamanhos["G1_POTENCI"][2])

	While (cAlias)->(!Eof())
		
		nIndex++

		aAdd(aEstrutura, Array(EST_TAMANHO))
		aEstrutura[nIndex][EST_G1_COMP   ] := (cAlias)->(G1_COMP)
		aEstrutura[nIndex][EST_G1_QUANT  ] := (cAlias)->(G1_QUANT)
		aEstrutura[nIndex][EST_G1_TRT    ] := (cAlias)->(G1_TRT)
		aEstrutura[nIndex][EST_QTDFIXA   ] := (cAlias)->(G1_FIXVAR) == "F"
		aEstrutura[nIndex][EST_G1_PERDA  ] := (cAlias)->(G1_PERDA)
		aEstrutura[nIndex][EST_G1_POTENCI] := (cAlias)->(G1_POTENCI)
		aEstrutura[nIndex][EST_RECNOSB1  ] := (cAlias)->(RECSB1)
		aEstrutura[nIndex][EST_PRODMOD   ] := Left((cAlias)->(G1_COMP), 3) == "MOD"
		aEstrutura[nIndex][EST_LOCPAD    ] := (cAlias)->(LOCPAD)

		If aEstrutura[nIndex][EST_PRODMOD] == .F. .And. Self:lPRODMOD .And. !Empty((cAlias)->(B1_CCCUSTO))
			aEstrutura[nIndex][EST_PRODMOD] := .T.
		EndIf

		If Empty((cAlias)->(G1_FANTASM))
			aEstrutura[nIndex][EST_G1_FANTASM] := (cAlias)->(B1_FANTASM) == "S"
		Else
			aEstrutura[nIndex][EST_G1_FANTASM] := (cAlias)->(G1_FANTASM) == "1"
		EndIf


		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return aEstrutura

/*/{Protheus.doc} buscaOperacao
Busca a operação do produto na SGF

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProdPai, Character, Código do produto pai (produto da OP)
@param 02 cRoteiro, Character, Roteiro da ordem de produção
@param 03 cComp   , Character, Código do componente
@param 04 cTRT    , Character, Sequência do componente
@return cOperacao , Character, Código da operação
/*/
Method buscaOperacao(cProdPai, cRoteiro, cComp, cTRT) Class Allocation
	
	Local cChavePrd  := xFilial("SGF") + cProdPai + cRoteiro
	Local cOperacao  := ""
	Local lVerificou := Self:oProdSGF:HasProperty(cChavePrd)

	If lVerificou == .F.
		//Verifica se este pai possui vínculo de operações x componentes para algum componente.
		//Verificação feita para não fazer o SEEK para todos os componentes caso o produto
		//pai não possua nenhum vínculo na SGF.
		If SGF->(dbSeek(cChavePrd))
			Self:oProdSGF[cChavePrd] := .T. //Armazena que este PAI+ROTEIRO possui vínculo de roteiro x operações.
		Else
			Self:oProdSGF[cChavePrd] := .F. //Armazena que este PAI+ROTEIRO NÃO possui vínculo de roteiro x operações.
		EndIf
	EndIf

	If Self:oProdSGF[cChavePrd] == .T.
		SGF->(dbSetOrder(2))
		If SGF->(dbSeek(cChavePrd + cComp + cTRT))
			cOperacao := SGF->GF_OPERAC
		EndIf
	EndIf

Return cOperacao

/*/{Protheus.doc} calculaMOD
Calcula quantidade de um produto MOD

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 nQtdEst, Numeric, Quantidade necessária do componente na estrutura
@param 02 nQtdPai, Numeric, Quantidade da ordem de produção (produto pai)
@param 03 lFixVar, Logic  , Identifica se o componente utiliza quantidade fixa
@return nQuant, Numeric, Quantidade necessária do componente.
/*/
Method calculaMOD(nQtdEst, nQtdPai, lFixVar) Class Allocation 
	
	Local nQuant := nQtdEst

	If Self:cTPHR == "N"
		nQuant := Int(nQtdEst)
		nQuant += ((nQtdEst - nQuant) / 60) * 100
	EndIf

	If lFixVar == .F.
		If Self:cUNIDMOD != "H"
			nQuant := nQtdPai / nQuant
		Else
			nQuant := nQtdPai * nQuant
		EndIf
	EndIf

Return nQuant

/*/{Protheus.doc} calculaPotencia
Calcula a potência do produto

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto  , Character, Código do componente
@param 02 nQuant    , Numeric  , Necessidade do componente
@param 03 nFPotEstru, Numeric  , Fator de potência da estrutura do componente
@return nQuant, Numeric, Quantidade necessária do componente com a potência aplicada
/*/
Method calculaPotencia(cProduto, nQuant, nFPotEstru) Class Allocation

	If nFPotEstru != Nil .And. nFPotEstru > 0 .And. Self:potenciaProduto(cProduto)
		nQuant := nQuant * (nFPotEstru/100)
	EndIf

Return nQuant

/*/{Protheus.doc} calculaQtdCompon
Calcula a quantidade do componente para atender a necessidade do produto pai.

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProdPai, Character, Código do produto pai
@param 02 aCompon , Array    , Array com os dados do componente, obtido pelo método buscaEstrutura
@param 03 nQtdPai , Numeric  , Quantidade do produto pai para efetuar o cálculo
@return nQuant, Numeric, Quantidade necessária do componente.
/*/
Method calculaQtdCompon(cProdPai, aCompon, nQtdPai) Class Allocation
	
	Local nQuant   := aCompon[EST_G1_QUANT]
	Local nQtdBase := 0

	If aCompon[EST_PRODMOD] //Cálculo de componente MOD.
		nQuant := Self:calculaMOD(aCompon[EST_G1_QUANT], nQtdPai, aCompon[EST_QTDFIXA]) 

	ElseIf aCompon[EST_QTDFIXA] == .F. //Multiplica pela qtd do pai caso não utilize quantidade fixa
		nQuant := aCompon[EST_G1_QUANT] * nQtdPai

	EndIf

	If aCompon[EST_QTDFIXA] == .F. //Aplica qtd base do produto pai, caso exista e não use quantidade fixa
		nQtdBase := Self:qtdBaseProduto(cProdPai)
		If nQtdBase > 1
			nQuant := nQuant / nQtdBase
		EndIf
	EndIf

	//Faz calculo de potência
	nQuant := Self:calculaPotencia(aCompon[EST_G1_COMP], nQuant, aCompon[EST_G1_POTENCI])

	//Aplica fator de perda
	If aCompon[EST_G1_PERDA] > 0
		nQuant := (nQuant/(100-aCompon[EST_G1_PERDA]))*100
	EndIf

	//Verifica arredondamentos
	nQuant := Self:arredondar(aCompon[EST_G1_COMP], nQuant)

Return nQuant

/*/{Protheus.doc} cargaParametros
Carrega os parâmetros MV utilizados pela classe

@author lucas.franca
@since 06/12/2021
@version P12
@return Nil
/*/
Method cargaParametros() Class Allocation
	
	Self:cARQPROD   := SuperGetMV("MV_ARQPROD", .F., "SB1")
	Self:cTPHR      := SuperGetMV("MV_TPHR")
	Self:cUNIDMOD   := SuperGetMV("MV_UNIDMOD")
	Self:lPRODMOD   := SuperGetMV("MV_PRODMOD", .F., .F.)

Return

/*/{Protheus.doc} cargaTamanhos
Carrega o tamanho dos campos em memória

@author lucas.franca
@since 29/11/2021
@version P12
@return Nil
/*/
Method cargaTamanhos() Class Allocation

	Self:oTamanhos  := JsonObject():New()

	Self:oTamanhos["D4_COD"    ] := {GetSX3Cache("D4_COD"    , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_LOCAL"  ] := {GetSX3Cache("D4_LOCAL"  , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_OP"     ] := {GetSX3Cache("D4_OP"     , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_SITUACA"] := {GetSX3Cache("D4_SITUACA", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_TRT"    ] := {GetSX3Cache("D4_TRT"    , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_LOTECTL"] := {GetSX3Cache("D4_LOTECTL", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_NUMLOTE"] := {GetSX3Cache("D4_NUMLOTE", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_OPORIG" ] := {GetSX3Cache("D4_OPORIG" , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_ORDEM"  ] := {GetSX3Cache("D4_ORDEM"  , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_SEQ"    ] := {GetSX3Cache("D4_SEQ"    , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_NUMPVBN"] := {GetSX3Cache("D4_NUMPVBN", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_ITEPVBN"] := {GetSX3Cache("D4_ITEPVBN", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_CBTM"   ] := {GetSX3Cache("D4_CBTM"   , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_CODLAN" ] := {GetSX3Cache("D4_CODLAN" , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_IDDCF"  ] := {GetSX3Cache("D4_IDDCF"  , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_PRODUTO"] := {GetSX3Cache("D4_PRODUTO", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_ROTEIRO"] := {GetSX3Cache("D4_ROTEIRO", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_OPERAC" ] := {GetSX3Cache("D4_OPERAC" , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_CODAEN" ] := {GetSX3Cache("D4_CODAEN" , "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_PRDORG" ] := {GetSX3Cache("D4_PRDORG" , "X3_TAMANHO"), 0}
	Self:oTamanhos["C2_ROTEIRO"] := {GetSX3Cache("C2_ROTEIRO", "X3_TAMANHO"), 0}
	Self:oTamanhos["D4_QUANT"  ] := {GetSX3Cache("D4_QUANT"  , "X3_TAMANHO"), GetSX3Cache("D4_QUANT"  , "X3_DECIMAL")}
	Self:oTamanhos["G1_QUANT"  ] := {GetSX3Cache("G1_QUANT"  , "X3_TAMANHO"), GetSX3Cache("G1_QUANT"  , "X3_DECIMAL")}
	Self:oTamanhos["G1_PERDA"  ] := {GetSX3Cache("G1_PERDA"  , "X3_TAMANHO"), GetSX3Cache("G1_PERDA"  , "X3_DECIMAL")}
	Self:oTamanhos["G1_POTENCI"] := {GetSX3Cache("G1_POTENCI", "X3_TAMANHO"), GetSX3Cache("G1_POTENCI", "X3_DECIMAL")}

Return

/*/{Protheus.doc} cargaEstrutura
Faz a carga dos empenhos baseado na estrutura do produto

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para buscar a estrutura.
@param 02 nQuant  , Numeric  , Quantidade do produto a ser considerada.
@param 03 cOP     , Character, Número da ordem de produção.
@param 04 cRevisao, Character, Revisão do produto para busca da estrutura.
@param 05 dDataIni, Date     , Data de início da ordem de produção.
@param 06 cRoteiro, Character, Roteiro do produto
@param 07 cProdOP , Character, Produto da ordem de produção. Utilizado devido a recursividade de produtos fantasmas.
@return Nil
/*/
Method cargaEstrutura(cProduto, nQuant, cOP, cRevisao, dDataIni, cRoteiro, cProdOP) Class Allocation
	
	Local aCompon   := {}
	Local cOperacao := ""
	Local cRotComp  := ""
	Local dDataLT   := dDataIni
	Local nIndex    := 0
	Local nPrazo    := 0
	Local nQtdComp  := 0
	Local nQtdSegum := 0
	Local nTotal    := 0
	
	//Padroniza o tamanho do produto recebido por parâmetro
	cProduto := PadR(cProduto, Self:oTamanhos["D4_COD"][1])
	cOP      := PadR(cOP     , Self:oTamanhos["D4_OP" ][1])

	//Caso não tenha recebido o parâmetro do produto da OP,
	//utiliza o produto recebido no primeiro parâmetro (cProduto).
	//cProdOP é necessário devido a recursividade realizada quando existe produto fantasma,
	//para registrar corretamente o produto pai.	
	If Empty(cProdOP)
		cProdOP := cProduto
	EndIf

	If Empty(cRoteiro)
		//Verifica se o produto possui roteiro padrão.
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + cProduto))
			cRoteiro := SB1->B1_OPERPAD
		EndIf
		If Empty(cRoteiro)
			cRoteiro := Self:cRotPad
		EndIf
	EndIf

	//Busca os componentes do produto
	aCompon := Self:buscaEstrutura(cProduto, cRevisao, dDataIni)
	nTotal  := Len(aCompon)

	For nIndex := 1 To nTotal 
		//Mantém a SB1 posicionada no componente para os próximos métodos
		//não precisarem fazer SEEK na SB1.
		SB1->(dbGoTo(aCompon[nIndex][EST_RECNOSB1]))
		cRotComp := SB1->B1_OPERPAD
		nQtdComp := Self:calculaQtdCompon(cProduto, aCompon[nIndex], nQuant)

		//Arredonda qtd de acordo com os decimais da SD4.
		nQtdComp := Round(nQtdComp, Self:oTamanhos["D4_QUANT"][2])

		If aCompon[nIndex][EST_G1_FANTASM]
			//Componente fantasma, faz a recursividade.
			//Verifica necessidade de calcular o leadtime do produto.
			dDataLT := dDataIni
			nPrazo  := CalcPrazo(cProduto, nQtdComp,,, .F., dDataLT)
			dDataLT := SomaPrazo(dDataLT, - nPrazo)
			Self:cargaEstrutura(aCompon[nIndex][EST_G1_COMP], nQtdComp, cOP, Nil, dDataLT, cRotComp, cProdOP)
		Else
			nQtdSegum := ConvUm(aCompon[nIndex][EST_G1_COMP], nQtdComp, 0, 2 )
			//Arredonda qtd de acordo com os decimais da SD4.
			nQtdSegum := Round(nQtdSegum, Self:oTamanhos["D4_QUANT"][2])

			cOperacao := Self:buscaOperacao(cProduto, cRoteiro, aCompon[nIndex][EST_G1_COMP], aCompon[nIndex][EST_G1_TRT])

			Self:adicionar(aCompon[nIndex][EST_G1_COMP],; //D4_COD
			               aCompon[nIndex][EST_LOCPAD ],; //D4_LOCAL
			               cOP                         ,; //D4_OP
			               dDataIni                    ,; //D4_DATA
			               0                           ,; //D4_QSUSP
			               ""                          ,; //D4_SITUACA
			               nQtdComp                    ,; //D4_QTDEORI
			               nQtdComp                    ,; //D4_QUANT
			               aCompon[nIndex][EST_G1_TRT ],; //D4_TRT
			               ""                          ,; //D4_LOTECTL
			               ""                          ,; //D4_NUMLOTE
			               Nil                         ,; //D4_DTVALID
			               ""                          ,; //D4_OPORIG
			               nQtdSegum                   ,; //D4_QTSEGUM
			               ""                          ,; //D4_ORDEM
			               0                           ,; //D4_POTENCI
			               ""                          ,; //D4_SEQ
			               ""                          ,; //D4_NUMPVBN
			               ""                          ,; //D4_ITEPVBN
			               0                           ,; //D4_SLDEMP
			               0                           ,; //D4_SLDEMP2
			               0                           ,; //D4_EMPROC
			               ""                          ,; //D4_CBTM
			               ""                          ,; //D4_CODLAN
			               ""                          ,; //D4_IDDCF
			               cProdOP                     ,; //D4_PRODUTO
			               cRoteiro                    ,; //D4_ROTEIRO
			               cOperacao                   ,; //D4_OPERAC
			               ""                          ,; //D4_CODAEN
			               0                           ,; //D4_QTNECES
			               ""                           ) //D4_PRDORG
		EndIf
	Next nIndex 

	aSize(aCompon, 0)

Return Nil

/*/{Protheus.doc} gravar
Grava as informações de empenhos registradas em memória
OBS: O controle da transação deve ser realizado na chamada deste método.

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cTpOp, Character, Tipo da ordem de produção (Firme/Prevista)
@return Nil
/*/
Method gravar(cTpOp) Class Allocation
	
	Local aNames := Self:oEmpenhos:GetNames()
	Local cChave := ""
	Local nIndex := 0
	Local nTotal := Len(aNames)

	//Grava as informações na tabela SD4
	For nIndex := 1 To nTotal
		
		cChave := aNames[nIndex]
		RecLock("SD4", .T.)
			SD4->D4_FILIAL  := Self:oEmpenhos[cChave][EMP_D4_FILIAL ]
			SD4->D4_COD     := Self:oEmpenhos[cChave][EMP_D4_COD    ]
			SD4->D4_LOCAL   := Self:oEmpenhos[cChave][EMP_D4_LOCAL  ]
			SD4->D4_OP      := Self:oEmpenhos[cChave][EMP_D4_OP     ]
			SD4->D4_DATA    := Self:oEmpenhos[cChave][EMP_D4_DATA   ]
			SD4->D4_QSUSP   := Self:oEmpenhos[cChave][EMP_D4_QSUSP  ]
			SD4->D4_SITUACA := Self:oEmpenhos[cChave][EMP_D4_SITUACA]
			SD4->D4_QTDEORI := Self:oEmpenhos[cChave][EMP_D4_QTDEORI]
			SD4->D4_QUANT   := Self:oEmpenhos[cChave][EMP_D4_QUANT  ]
			SD4->D4_TRT     := Self:oEmpenhos[cChave][EMP_D4_TRT    ]
			SD4->D4_LOTECTL := Self:oEmpenhos[cChave][EMP_D4_LOTECTL]
			SD4->D4_NUMLOTE := Self:oEmpenhos[cChave][EMP_D4_NUMLOTE]
			SD4->D4_DTVALID := Self:oEmpenhos[cChave][EMP_D4_DTVALID]
			SD4->D4_OPORIG  := Self:oEmpenhos[cChave][EMP_D4_OPORIG ]
			SD4->D4_QTSEGUM := Self:oEmpenhos[cChave][EMP_D4_QTSEGUM]
			SD4->D4_ORDEM   := Self:oEmpenhos[cChave][EMP_D4_ORDEM  ]
			SD4->D4_POTENCI := Self:oEmpenhos[cChave][EMP_D4_POTENCI]
			SD4->D4_SEQ     := Self:oEmpenhos[cChave][EMP_D4_SEQ    ]
			SD4->D4_NUMPVBN := Self:oEmpenhos[cChave][EMP_D4_NUMPVBN]
			SD4->D4_ITEPVBN := Self:oEmpenhos[cChave][EMP_D4_ITEPVBN]
			SD4->D4_SLDEMP  := Self:oEmpenhos[cChave][EMP_D4_SLDEMP ]
			SD4->D4_SLDEMP2 := Self:oEmpenhos[cChave][EMP_D4_SLDEMP2]
			SD4->D4_EMPROC  := Self:oEmpenhos[cChave][EMP_D4_EMPROC ]
			SD4->D4_CBTM    := Self:oEmpenhos[cChave][EMP_D4_CBTM   ]
			SD4->D4_CODLAN  := Self:oEmpenhos[cChave][EMP_D4_CODLAN ]
			SD4->D4_IDDCF   := Self:oEmpenhos[cChave][EMP_D4_IDDCF  ]
			SD4->D4_PRODUTO := Self:oEmpenhos[cChave][EMP_D4_PRODUTO]
			SD4->D4_ROTEIRO := Self:oEmpenhos[cChave][EMP_D4_ROTEIRO]
			SD4->D4_OPERAC  := Self:oEmpenhos[cChave][EMP_D4_OPERAC ]
			SD4->D4_CODAEN  := Self:oEmpenhos[cChave][EMP_D4_CODAEN ]
			SD4->D4_QTNECES := Self:oEmpenhos[cChave][EMP_D4_QTNECES]
			SD4->D4_PRDORG  := Self:oEmpenhos[cChave][EMP_D4_PRDORG ]
		SD4->(MsUnLock())

	Next nIndex

	//Faz a atualização das tabelas de saldos.
	Self:gravarSaldos(cTpOp)
	
	//Limpa os dados gravados da memória.
	Self:clear()
	aSize(aNames, 0)

Return

/*/{Protheus.doc} gravarSaldos
Faz a atualização dos dados de Saldos dos empenhos que foram registrados na SD4

@author lucas.franca
@since 10/12/2021
@version P12
@param 01 cTpOp, Character, Tipo da ordem de produção (Firme/Prevista)
@return Nil
/*/
Method gravarSaldos(cTpOp) Class Allocation
	Local aNames := Self:oSaldos:GetNames()
	Local cChave := ""
	Local nIndex := 0
	Local nTotal := Len(aNames)

	//Faz a atualização do saldo (SB2) dos empenhos
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1))

	For nIndex := 1 To nTotal 
		cChave := aNames[nIndex]
		
		//Posiciona a SB2. Caso não exista faz a criação do registro.
		If ! SB2->(dbSeek(Self:cFilSB2 + Self:oSaldos[cChave][SLD_PRODUTO] + Self:oSaldos[cChave][SLD_LOCAL]))
			CriaSB2(Self:oSaldos[cChave][SLD_PRODUTO], Self:oSaldos[cChave][SLD_LOCAL])
		EndIf

		If Self:oSaldos[cChave][SLD_TIPO] == "+"
			//Registra qtd de empenho na tabela de estoque.
			GravaB2Emp("+", Self:oSaldos[cChave][SLD_QUANTIDADE], cTpOp, .F., Self:oSaldos[cChave][SLD_QTSEGUM])
		Else
			//Produtos com empenho negativo registram a quantidade de empenho como entrada
			GravaB2Pre("+", ABS(Self:oSaldos[cChave][SLD_QUANTIDADE]), cTpOp, ABS(Self:oSaldos[cChave][SLD_QTSEGUM]), .T.)
		EndIf

	Next nIndex

	aSize(aNames, 0)

Return

/*/{Protheus.doc} potenciaProduto
Busca a potência do produto e armazena na memória para reutilização.

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para buscar a estrutura.
@return lPotencia, Logic, Identifica se o produto utiliza potência
/*/
Method potenciaProduto(cProduto) Class Allocation
	
	Local cChave    := cFilAnt + cProduto
	Local lPotencia := Self:oPotProd[cChave]
	
	If lPotencia == Nil
		lPotencia := PotencLote(cProduto)
		
		Self:oPotProd[cChave] := lPotencia
	EndIf

Return lPotencia


/*/{Protheus.doc} revisaoProduto
Busca a revisão atual do produto e armazena na memória para reutilização.

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para buscar a estrutura.
@return cRevisao, Character, Revisão atual do produto
/*/
Method revisaoProduto(cProduto) Class Allocation
	
	Local cChave   := cFilAnt + cProduto
	Local cRevisao := Self:oRevProd[cChave]
	
	If cRevisao == Nil
		cRevisao := PCPREVATU(cProduto)
		
		Self:oRevProd[cChave] := cRevisao
	EndIf

Return cRevisao

/*/{Protheus.doc} qtdBaseProduto
Busca a quantidade base do produto e armazena na memória para reutilização.

@author lucas.franca
@since 29/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para buscar a estrutura.
@return nQtdBase, Numeric, Quantidade base do produto
/*/
Method qtdBaseProduto(cProduto) Class Allocation

	Local cChave   := cFilAnt + cProduto
	Local nQtdBase := Self:oBaseProd[cChave]

	If nQtdBase == Nil
		//Verifica se utiliza SBZ
		If Self:cARQPROD == "SBZ"
			SBZ->(dbSetOrder(1))
			If SBZ->(dbSeek(xFilial("SBZ")+cProduto))
				nQtdBase := SBZ->BZ_QB
			EndIf
		EndIf

		//Se não utiliza SBZ, ou se não encontrou na SBZ, verifica na SB1.
		If Self:cARQPROD == "SB1" .Or. nQtdBase == Nil
			If SB1->(B1_FILIAL+B1_COD) != xFilial("SB1")+cProduto
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+cProduto))
			EndIf
			nQtdBase := SB1->B1_QB
		EndIf

		Self:oBaseProd[cChave] := nQtdBase

	EndIf

Return nQtdBase

/*/{Protheus.doc} setSaldo
Armazena informações de saldo para atualização posterior

@author lucas.franca
@since 30/11/2021
@version P12
@param 01 cProduto, Character, Código do produto para atualizar o saldo
@param 02 cLocal  , Character, Armazém do produto
@param 03 nQuant  , Numeric  , Quantidade para atualização
@param 04 nQtSegum, Numeric  , Quantidade na segunda unidade de medida
@return Nil
/*/
Method setSaldo(cProduto, cLocal, nQuant, nQtSegum) Class Allocation

	Local cChave := ""
	Local cTipo  := "+"

	If Self:cFilSB2 == Nil
		Self:cFilSB2 := xFilial("SB2")
	EndIf

	//cTipo - Define se a quantidade é positiva (+) ou negativa (-)
	If nQuant < 0
		cTipo := "-"
	EndIf

	cChave := Self:cFilSB2          + ;
	          "|" + RTrim(cProduto) + ;
	          "|" + RTrim(cLocal)   + ;
	          "|" + cTipo

	If !Self:oSaldos:HasProperty(cChave)
		Self:oSaldos[cChave] := Array(SLD_TAMANHO)
		Self:oSaldos[cChave][SLD_PRODUTO   ] := cProduto
		Self:oSaldos[cChave][SLD_LOCAL     ] := cLocal
		Self:oSaldos[cChave][SLD_TIPO      ] := cTipo
		Self:oSaldos[cChave][SLD_QUANTIDADE] := 0
		Self:oSaldos[cChave][SLD_QTSEGUM   ] := 0
	EndIf
	Self:oSaldos[cChave][SLD_QUANTIDADE] += nQuant
	Self:oSaldos[cChave][SLD_QTSEGUM   ] += nQtSegum

Return
