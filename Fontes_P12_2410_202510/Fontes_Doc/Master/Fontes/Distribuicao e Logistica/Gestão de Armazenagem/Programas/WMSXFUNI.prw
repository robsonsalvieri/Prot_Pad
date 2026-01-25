#INCLUDE "PROTHEUS.CH"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNI - Funções WMS Consulta Saldo Integração                   |
+---------+--------------------------------------------------------------------+
|Objetivo | Deverá agrupar todas as funções que serão utilizadas em            |
|         | integrações para fazer consultas de saldo com base na tabela D14.  |
+---------+--------------------------------------------------------------------+
*/
//------------------------------------------------------------------------------
// Permite efetuar a consulta de saldo por endereço no WMS
//------------------------------------------------------------------------------
Function WmsSldD14(cArmazem,cEndereco,cProduto,cNumSerie,cLoteCtl,cNumLote,lBaixaEmp,lProducao,cIdUnitiz)
Local nQuant    := 0
Local oSaldoWMS := WMSDTCEstoqueEndereco():New()

Default lBaixaEmp := .F.
	oSaldoWMS:SetProducao(lProducao)
	nQuant := oSaldoWMS:GetSldWMS(cProduto,cArmazem,cEndereco,cLoteCtl,cNumLote,cNumSerie,,cIdUnitiz)
Return nQuant
//------------------------------------------------------------------------------
// Retorna o saldo a classificar original
//------------------------------------------------------------------------------
Function WmsSldD0G(cProduto,cArmazem,cNumSeq,cDocto)
Local nQuant := 0
Local oSaldoADis := WMSDTCSaldoADistribuir():New()

	oSaldoADis:oProdLote:SetProduto(cProduto)
	oSaldoADis:oProdLote:SetArmazem(cArmazem)
	oSaldoADis:SetNumSeq(cNumSeq)
	oSaldoADis:SetDocto(cDocto)
	oSaldoADis:LoadData(1)
	nQuant := oSaldoADis:GetQtdOri()
Return nQuant
//------------------------------------------------------------------------------
// Retorna array com o saldo do unitizador por endereço
//------------------------------------------------------------------------------
Function WmsSldUni(cIdUnit)
Local aSldUni   := {}
Local aTamSX3   := TamSx3("D14_QTDEST")
Local oEstEnd   := Nil
Local cQuery    := ""
Local cAliasD14 := Nil

	If !Empty(cIdUnit)
		//Busca saldos por endereço do unitizador
		oEstEnd := WMSDTCEstoqueEndereco():New()
		oEstEnd:ClearData()
		oEstEnd:SetIdUnit(cIdUnit)
		oEstEnd:GetQryComp(@cQuery,.T.,1,0)
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT %Exp:cQuery%
		EndSql
		TcSetField(cAliasD14,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
		TcSetField(cAliasD14,'D14_DTVALD','D')
		Do While (cAliasD14)->( !Eof() )
			aAdd(aSldUni, { ;
				(cAliasD14)->(FieldGet(1)),;                                             //[1]  Local            D14_LOCAL
				(cAliasD14)->(FieldGet(2)),;                                             //[2]  Endereço         D14_ENDER
				(cAliasD14)->(FieldGet(3)),;                                             //[3]  Lote             D14_LOTECT
				(cAliasD14)->(FieldGet(4)),;                                             //[4]  Sub-lote         D14_NUMLOT
				(cAliasD14)->(FieldGet(5)),;                                             //[5]  Número de Série  D14_NUMSER
				Int((cAliasD14)->(FieldGet(6))),;                                        //[6]  Quantidade       D14_QTDEST
				ConvUm((cAliasD14)->(FieldGet(9)),Int((cAliasD14)->(FieldGet(6))),0,2),; //[7]  Seg. Un medida   D14_QTDES2
				(cAliasD14)->(FieldGet(7)),;                                             //[8]  Data de Validade D14_DTVALD
				(cAliasD14)->(FieldGet(8)),;                                             //[9]  Produto origem   D14_PRDORI
				(cAliasD14)->(FieldGet(9))})                                             //[10] Produto          D14_PRODUT
			(cAliasD14)->(dbSkip())
		EndDo
		(cAliasD14)->(dbCloseArea())
	EndIf
Return aSldUni
//------------------------------------------------------------------------------
// Utilizado na rotina de Consulta de Lote x Endereço (MATC070)
//------------------------------------------------------------------------------
Function MATC070WMS(lEnd)
Local lLotUni   := SuperGetMV('MV_LOTEUNI', .F., .F.)
Local lConsPrev := (SuperGetMV("MV_QTDPREV",.F.,"N")=="S")
Local lPrdPai   := WmsPrdPai(SB1->B1_COD)
Local lEmpPrev  := If(SuperGetMV("MV_QTDPREV")== "S",.T.,.F.)
Local cChave    := ""
Local cDescri   := ""
Local cChaveB8  := ""
Local cLocal    := ""
Local cProduto  := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local cLocaliz  := CriaVar("BF_LOCALIZ" )
Local cNumSeri  := CriaVar("BF_NUMSERIE")
Local cWhere    := ""
Local cAliasD14 := Nil
Local cAliasD11 := Nil
Local cAliasD0V := Nil
Local nRegD14   := 0
Local nLenTrbp  := 1
Local nSaldo    := 0
Local nEmpenho  := 0
Local nScan     := 0
Local nSaldo2   := 0
Local nEmpenh2  := 0
Local dDtValid  := CtoD("  /  /  ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o grupo de perguntas MTC070                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MTC070",.F.)

	cChave := xFilial("SB8") + SB1->B1_COD
	SB8->(DbSetOrder(3))
	SB8->(DbSeek(cChave))
	ProcRegua(SB8->(LastRec()))
	Do While !SB8->(Eof()) .And. cChave == SB8->B8_FILIAL+SB8->B8_PRODUTO
		IncProc()

		If mv_par01 == 2 .And. SB8SALDO(,,,,,lEmpPrev,,,.T.) == 0
			SB8->(dbSkip())
			Loop
		EndIf

		cChaveB8 := xFilial("SB8")+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL+Iif(lLotUni,SB8->B8_NUMLOTE,"")
		nSaldo   := nEmpenho := nSaldo2 := nEmpenh2 := 0
		cLocal   := SB8->B8_LOCAL
		cProduto := SB8->B8_PRODUTO
		cLoteCtl := SB8->B8_LOTECTL
		cNumLote := SB8->B8_NUMLOTE
		dDtValid := SB8->B8_DTVALID

		Do While !SB8->(Eof()) .And. cChaveB8 == SB8->B8_FILIAL+SB8->B8_PRODUTO+SB8->B8_LOCAL+SB8->B8_LOTECTL+Iif(lLotUni,SB8->B8_NUMLOTE,"")
			nSaldo   += SB8SALDO(,,,,,lEmpPrev,,,.T.)
			nEmpenho += SB8SALDO(.T.,,,,,lEmpPrev,,,.T.)
			nSaldo2  += SB8SALDO(,,,.T.,,lEmpPrev,,,.T.)
			nEmpenh2 += SB8SALDO(.T.,,,.T.,,lEmpPrev,,,.T.)
			SB8->(dbSkip())
		EndDo

		If mv_par01 == 1 .And. nSaldo == 0
			aAdd(aTrbp,{})
			nLenTrbp := Len(aTrbp)
			aAdd(aTrbp[nLenTrbp],cLocal)
			aAdd(aTrbp[nLenTrbp],cLoteCtl)
			aAdd(aTrbp[nLenTrbp],Iif(lLotUni,cNumLote,""))
			aAdd(aTrbp[nLenTrbp],dDtValid)
			If lPrdPai
				aAdd(aTrbp[nLenTrbp],"")
			EndIf
			aAdd(aTrbp[nLenTrbp],cLocaliz)
			aAdd(aTrbp[nLenTrbp],cNumSeri)
			aAdd(aTrbp[nLenTrbp],nSaldo)
			aAdd(aTrbp[nLenTrbp],nSaldo  - nEmpenho)
			aAdd(aTrbp[nLenTrbp],nSaldo2)
			aAdd(aTrbp[nLenTrbp],nSaldo2 - nEmpenh2)
			Loop
		EndIf
		cWhere := "%"
		If lLotUni
			cWhere += " AND D14.D14_NUMLOT = '"+cNumLote+"'"
		EndIf
		If mv_par02 == 2
			If lConsPrev .Or. lEmpPrev
				cWhere += " AND (D14.D14_QTDEST-D14.D14_QTDEMP) > 0"
			Else
				cWhere += " AND D14.D14_QTDEST > 0"
			EndIf
		EndIf
		cWhere += "%"
		cAliasD14 := GetNextAlias()
		BeginSql Alias cAliasD14
			SELECT D14_LOCAL,
					D14_PRDORI,
					D14_PRODUT,
					D14_LOTECT,
					D14_NUMLOT,
					D14_DTVALD,
					D14_ENDER,
					D14_NUMSER,
					D14_QTDEST,
					D14_QTDES2,
					D14_QTDEMP,
					D14_QTDEM2,
					D14_QTDBLQ,
					D14_QTDBL2,
					CASE WHEN D11_QTMULT IS NULL THEN 1 ELSE D11_QTMULT END D11_QTMULT
			FROM %Table:D14% D14
			LEFT JOIN %Table:D11% D11
			ON D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = D14.D14_PRDORI
			AND D11.D11_PRDCMP = D14.D14_PRODUT
			AND D11.%NotDel%
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL = %Exp:cLocal%
			AND D14.D14_PRDORI = %Exp:cProduto%
			AND D14.D14_LOTECT = %Exp:cLoteCtl%
			AND D14.%NotDel%
			%Exp:cWhere%
		EndSql
		TcSetField(cAliasD14,'D14_DTVALD','D')
		(cAliasD14)->(dbEval({|| nRegD14++}))
		(cAliasD14)->(DbGoTop())
		ProcRegua(nRegD14)
		Do While !(cAliasD14)->(Eof())
			IncProc()
			nPosLote := aScan( aTrbp, {|x| x[1]+x[2]+x[3]+DtoS(x[4])+x[5]+x[6] == (cAliasD14)->D14_LOCAL+(cAliasD14)->D14_LOTECT+(cAliasD14)->D14_NUMLOT+DtoS(dDtValid)+(cAliasD14)->D14_ENDER+(cAliasD14)->D14_NUMSER})
			If nPosLote == 0
				aAdd(aTrbp,{})
				nLenTrbp := Len(aTrbp)
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_LOCAL )
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_LOTECT)
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_NUMLOT)
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_DTVALD)
				If lPrdPai
					aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_PRODUT)
				EndIf
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_ENDER )
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_NUMSER)
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_QTDEST)
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_QTDEST - ((cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ))
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_QTDES2)
				aAdd(aTrbp[nLenTrbp],(cAliasD14)->D14_QTDES2 - ((cAliasD14)->D14_QTDEM2+(cAliasD14)->D14_QTDBL2))

				aQuant[ 1 ] += (cAliasD14)->D14_QTDEST/(cAliasD14)->D11_QTMULT
				aQuant[ 2 ] += ((cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ)/(cAliasD14)->D11_QTMULT

				cAliasD0V := GetNextAlias()
				BeginSql Alias cAliasD0V
					SELECT D0U_DOCTO,
							D0U_MOTIVO,
							D0U_OBSERV,
							D0V_PRODUT,
							D0V_LOTECT,
							D0V_NUMLOT,
							D0V_LOCAL,
							D0V_ENDER,
							D0V_QTDBLQ
					FROM %Table:D0V% D0V
					INNER JOIN %Table:D0U% D0U
					ON D0U.D0U_FILIAL = %xFilial:D0U%
					AND D0U.D0U_IDBLOQ = D0V.D0V_IDBLOQ"
					AND D0U.%NotDel%
					WHERE D0V.D0V_FILIAL = %xFilial:D0V%
					AND D0V.D0V_PRDORI = %Exp:(cAliasD14)->D14_PRDORI%
					AND D0V.D0V_PRODUT = %Exp:(cAliasD14)->D14_PRODUT%
					AND D0V.D0V_LOTECT = %Exp:(cAliasD14)->D14_LOTECT%
					AND D0V.D0V_NUMLOT = %Exp:(cAliasD14)->D14_NUMLOT%
					AND D0V.D0V_LOCAL = %Exp:(cAliasD14)->D14_LOCAL%
					AND D0V.D0V_ENDER = %Exp:(cAliasD14)->D14_ENDER%
					AND D0V.%NotDel%
				EndSql
				Do While !(cAliasD0V)->(Eof())
					// Busca a descrição do motivo do bloqueio
					cDescri := Tabela("E1",(cAliasD0V)->D0U_MOTIVO)
					// Adiciona as informações do produto/lote no array de bloqueio
					aAdd(aBloqueio,{(cAliasD0V)->D0V_LOTECT,;
										 (cAliasD0V)->D0V_NUMLOT,;
										 (cAliasD0V)->D0U_DOCTO,;
										 (cAliasD0V)->D0U_MOTIVO,;
										 cDescri,;
										 (cAliasD0V)->D0U_OBSERV,;
										 Transform((cAliasD0V)->D0V_QTDBLQ,cPictQtd14),;
										 (cAliasD0V)->D0V_LOCAL,;
										 (cAliasD0V)->D0V_ENDER,;
										 (cAliasD14)->D14_NUMSER})
					// Agrupa os bloqueios com o mesmo motivo para o caso do usuário selecionar a impressão de relatório
					nScan := aScan( aTrbT, { |x| x[ 1 ] == (cAliasD0V)->D0U_MOTIVO } )
					If nScan > 0
						aTrbT[ nScan, 3 ] += (cAliasD0V)->D0V_QTDBLQ
					Else
						AAdd( aTrbT, { (cAliasD0V)->D0U_MOTIVO, AllTrim(cDescri), (cAliasD0V)->D0V_QTDBLQ } )
					EndIf
					nTotBloq += (cAliasD0V)->D0V_QTDBLQ
					(cAliasD0V)->(DbSkip())
				EndDo
				(cAliasD0V)->(DbCloseArea())
			Else
				If lPrdPai
					aTrbp[nPosLote, 8] += (cAliasD14)->D14_QTDEST
					aTrbp[nPosLote, 9] += (cAliasD14)->D14_QTDEST - ((cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ)
					aTrbp[nPosLote,10] += (cAliasD14)->D14_QTDES2
					aTrbp[nPosLote,11] += (cAliasD14)->D14_QTDES2 - ((cAliasD14)->D14_QTDEM2+(cAliasD14)->D14_QTDBL2)
				Else
					aTrbp[nPosLote, 7] += (cAliasD14)->D14_QTDEST
					aTrbp[nPosLote, 8] += (cAliasD14)->D14_QTDEST - ((cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ)
					aTrbp[nPosLote, 9] += (cAliasD14)->D14_QTDES2
					aTrbp[nPosLote,10] += (cAliasD14)->D14_QTDES2 - ((cAliasD14)->D14_QTDEM2+(cAliasD14)->D14_QTDBL2)
				EndIf

				aQuant[ 1 ] += (cAliasD14)->D14_QTDEST/(cAliasD14)->D11_QTMULT
				aQuant[ 2 ] += ((cAliasD14)->D14_QTDEMP+(cAliasD14)->D14_QTDBLQ)/(cAliasD14)->D11_QTMULT
			EndIf
			(cAliasD14)->(DbSkip())
		EndDo
		(cAliasD14)->(DbCloseArea())
	EndDo
	If lPrdPai
		cAliasD11 := GetNextAlias()
		BeginSql Alias cAliasD11
			SELECT COUNT(*) D11_QUANT
			FROM %Table:D11% D11
			WHERE D11.D11_FILIAL = %xFilial:D11%
			AND D11.D11_PRDORI = %Exp:SB1->B1_COD%
			AND D11.%NotDel%
		EndSql
		If !(cAliasD11)->(Eof())
			aQuant[1] := aQuant[1] / (cAliasD11)->D11_QUANT
			aQuant[2] := aQuant[2] / (cAliasD11)->D11_QUANT
		EndIf
		(cAliasD11)->(DbCloseArea())
	EndIf
	aTotal := aClone(aQuant)
Return aQuant
//----------------------------------------
/*/{Protheus.doc} WmsUniEnd
Busca outros endereços que contenham o unitizador,
utilizado para gerar contagem de inventário zerada
@author Amanda Rosa Vieira
@since 10/11/2017
@version 1.0
@param cArmazem,cEndereco (endereço a ser desconsiderado na query)
/*/
//----------------------------------------
Function WmsUniEnd(cArmazem,cEndereco,cIdUnit)
Local aSldUni   := {}
Local cWhere    := ""
Local cAliasD14 := Nil
	// Parâmetro Where
	cWhere := "%"
	If !Empty(cArmazem)
		cWhere += " AND D14.D14_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cEndereco)
		cWhere += " AND D14.D14_ENDER <> '"+cEndereco+"'"
	EndIf
	cWhere += "%"
	cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT D14.D14_LOCAL,
				D14.D14_ENDER,
				D14.D14_LOTECT,
				D14.D14_NUMLOT,
				D14.D14_NUMSER,
				D14.D14_DTVALD,
				D14.D14_PRDORI,
				D14.D14_PRODUT,
				D14.D14_IDUNIT
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_IDUNIT = %Exp:cIdUnit%
		AND D14.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasD14,'D14_DTVALD','D')
	Do While (cAliasD14)->( !Eof() )
		aAdd(aSldUni, { ;
			(cAliasD14)->D14_LOCAL,; //[1]  Local
			(cAliasD14)->D14_ENDER,; //[2]  Endereço
			(cAliasD14)->D14_LOTECT,;//[3]  Lote
			(cAliasD14)->D14_NUMLOT,;//[4]  Sub-lote
			(cAliasD14)->D14_NUMSER,;//[5]  Número de Série
			0,;                      //[6]  Quantidade
			0,;                      //[7]  Seg. Un medida
			(cAliasD14)->D14_DTVALD,;//[8]  Data de Validade
			(cAliasD14)->D14_PRDORI,;//[9]  Produto origem
			(cAliasD14)->D14_PRODUT,;//[11] Produto
			(cAliasD14)->D14_IDUNIT})//[10] Id Unitizador
		(cAliasD14)->(dbSkip())
	EndDo
	(cAliasD14)->(dbCloseArea())
Return aSldUni
//----------------------------------------
/*/{Protheus.doc} WmsD14SSB8
Caso o produto controle rastro (lote), verifica se o produto possui movimentos na D14 mas não possui na SB8.
Essa funcionalidade é usada para os casos em que o controle do produto é feito pelo WMS e o usuário alterou o campo 
de rastro de Não para Sim.  
A partir desse momento, já há registros na tabela D14 mas não há na tabela SB8.
Baseado nessa função, as funções chamadoras determinam de onde será feita a leitura do saldo do produto (se SB8 ou D14).
@author Wander Horongoso
@since 31/10/2019
@version 1.0
@param cArmazem,cProduto
@return Se não encontrar SB8 retorna verdadeiro. Se encontrar SB8 retorna falso.
/*/
//----------------------------------------
Function WmsD14SSB8(cArmazem,cProd)
Local aAreaAnt := GetArea()
Local cAliasD14 := Nil
Local lRet := .F.

	cAliasD14 := GetNextAlias()
	BeginSql Alias cAliasD14
		SELECT COUNT(R_E_C_N_O_) QTTOTAL
		FROM %Table:D14% D14 
		WHERE D14.D14_FILIAL = %xFilial:D14% 
		AND D14.D14_LOCAL = %Exp:cArmazem%
		AND D14.D14_PRODUT = %Exp:cProd%
		AND D14.D14_LOTECT = ' '
		AND D14.D14_NUMLOT = ' '
		AND D14.%NotDel%	
		AND NOT EXISTS (SELECT 1
		                FROM %Table:SB8% SB8
	                    WHERE SB8.B8_FILIAL = D14.D14_FILIAL
	                    AND SB8.B8_LOCAL = D14.D14_LOCAL
	                    AND SB8.B8_PRODUTO = D14.D14_PRODUT
	                    AND SB8.%NotDel%)
	EndSql
	
	lRet := (cAliasD14)->QTTOTAL > 0	
	
	(cAliasD14)->(dbCloseArea())
	
	RestArea(aAreaAnt)	
		
Return lRet