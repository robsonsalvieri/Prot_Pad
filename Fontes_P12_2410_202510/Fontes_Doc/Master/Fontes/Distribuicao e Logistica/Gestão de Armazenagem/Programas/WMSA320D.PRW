#include "PROTHEUS.CH"
#include "WMSA320D.CH"
#include "FWMVCDEF.CH"

#define WMSA320D01 "WMSA320D01"
#define WMSA320D02 "WMSA320D02"
#define WMSA320D03 "WMSA320D03"
#define WMSA320D04 "WMSA320D04"
#define WMSA320D05 "WMSA320D05"
#define WMSA320D06 "WMSA320D06"
#define WMSA320D07 "WMSA320D07"
#define WMSA320D08 "WMSA320D08"
#define WMSA320D09 "WMSA320D09"
#define WMSA320D10 "WMSA320D10"
#define WMSA320D11 "WMSA320D11"
#define WMSA320D12 "WMSA320D12"
#define WMSA320D13 "WMSA320D13"
#define WMSA320D14 "WMSA320D14"
#define WMSA320D15 "WMSA320D15"
#define WMSA320D16 "WMSA320D16"
#define WMSA320D17 "WMSA320D17"
#define WMSA320D18 "WMSA320D18"
#define WMSA320D19 "WMSA320D19"
#define WMSA320D20 "WMSA320D20"
#define WMSA320D21 "WMSA320D21"
#define WMSA320D22 "WMSA320D22"
#define WMSA320D23 "WMSA320D23"
#define WMSA320D24 "WMSA320D24"
#define WMSA320D25 "WMSA320D25"
#define WMSA320D26 "WMSA320D26"
#define WMSA320D27 "WMSA320D27"
#define WMSA320D28 "WMSA320D28"
#define WMSA320D29 "WMSA320D29"
#define WMSA320D30 "WMSA320D30"
#define WMSA320D31 "WMSA320D31"
#define WMSA320D32 "WMSA320D32"
#define WMSA320D33 "WMSA320D33"
#define WMSA320D34 "WMSA320D34"
#define WMSA320D35 "WMSA320D35"
#define WMSA320D36 "WMSA320D36"
#define WMSA320D37 "WMSA320D37"
#define WMSA320D38 "WMSA320D38"
#define WMSA320D39 "WMSA320D39"
#define WMSA320D40 "WMSA320D40"
#define WMSA320D41 "WMSA320D41"

Static __lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Static __cWmsLcFt := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Static __cWmsLcEx := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Static __cWmsEnFt := SuperGetMV('MV_WMSENFT',.F.,"") // Endereço de falta
Static __cWmsEnEx := SuperGetMV('MV_WMSENEX',.F.,"") // Endereço de excesso
Static __cWmsSrRe := SuperGetMV("MV_WMSSRRE",.F.,"") // Serviço de retirada
Static __cWmsSrFt := SuperGetMV("MV_WMSSRFT",.F.,"") // Servico de falta
Static __cWmsSrEx := SuperGetMV("MV_WMSSREX",.F.,"") // Servico de excesso
Static __cWmsTMRe := SuperGetMV('MV_WMSTMRE',.F.,"") // Tipo de movimentação de retirada
Static __cWmsTMFt := SuperGetMV('MV_WMSTMFT',.F.,"") // Tipo de movimentação de falta
Static __cWmsTMEx := SuperGetMV('MV_WMSTMEX',.F.,"") // Tipo de movimentação de excesso
Static __lMovEx   := (!Empty(__cWmsLcEx) .And. !Empty(__cWmsEnEx) .And. !Empty(__cWmsSrEx) .And. Iif(__lWmsNew,!Empty(__cWmsTMEx),.T.))
Static __lMovFt   := (!Empty(__cWmsLcFt) .And. !Empty(__cWmsEnFt) .And. !Empty(__cWmsSrFt) .And. Iif(__lWmsNew,!Empty(__cWmsTMFt) .And. !Empty(__cWmsSrRe) .And. !Empty(__cWmsTMRe),.T.))
Static __lClParam := Empty(__cWmsLcEx+__cWmsEnEx+__cWmsSrEx+__cWmsTMEx+__cWmsLcFt+__cWmsEnFt+__cWmsSrFt+__cWmsTMFt+__cWmsSrRe+__cWmsTMRe)
Static lDtValid   := DCY->(ColumnPos("DCY_DTVAL")) > 0

//------------------------------------------------------------------------------
// Funções que retornam os parâmetros para a conferência
//------------------------------------------------------------------------------
Function Wm320MovEx()
Return __lMovEx

Function Wm320MovFt()
Return __lMovFt


Function Wm320SvcFt()
Return __cWmsSrFt

Function Wm320SvcEx()
Return __cWmsSrEx

Function Wm320EndFt()
Return __cWmsEnFt

Function Wm320EndEx()
Return __cWmsEnEx

Function Wm320ClPar()
Return __lClParam

//------------------------------------------------------------------------------
// Retorna a quantidade de saldo a endereçar para o estorno da movimentação de falta
//------------------------------------------------------------------------------
Static __nSldDist := 0
Function Wm320SdDis(nSldDist)
	If nSldDist != Nil
		__nSldDist := nSldDist
	EndIf
Return __nSldDist

//------------------------------------------------------------------------------
// Efetua a finalização da conferência do recebimento
//------------------------------------------------------------------------------
Function Wm320FnCof(cEmbarque,cTpConf,lDiverge,lDiverLote)
Local lRet       := .T.
Local lCtrLote   := .F.
Local lSaiLote   := .F.
Local lPreNota   := .F.
Local lProdPai   := .F.
Local lExcTotal  := .F.
Local aAreaAnt   := GetArea()
Local aPrdDist   := {}
Local aTamDCY    := TamSX3("DCY_QTCONF")
Local oModelD06  := Nil
Local oDmdUnit   := Nil
Local cAliasSD1  := ""
Local cAliasSF1  := ""
Local cAliasQry  := ""
Local cAliasDCY  := ""
Local cDocto     := ""
Local cSerie     := ""
Local cFornece   := ""
Local cLoja      := ""
Local cProduto   := ""
Local cItem      := ""
Local cDocFtSD3  := ""
Local cDocExSD3  := ""
Local cSelect    := ""
Local nQuant     := 0
Local nQtdCofTot := 0
Local nQtdOrig   := 0
Local nQtdConf   := 0
Local nQtdDCY    := 0
Local nRecnoSD1  := 0
Local nWmsDpCa   := Val(SuperGetMv("MV_WMSDPCA",.F.,"0"))
Local nI         := 0
Local nX         := 0
Local dDtValid   := CtoD("")
Local dDtVazia   := CtoD("")
Local lW320DFCO	 := .T.
Local lExistStat := ExisteStatus()

	cSelect := "%"
	If lDtValid
		cSelect += " ,DCY.DCY_DTVAL"
	EndIf
	cSelect += "%"
	// Seta um tamanho para régua de progressão
	If !IsTelNet() .And. !Wm320Autom()
		ProcRegua(0)
	EndIf
	Begin Transaction
		// Somando os itens conferidos, para distribuir entre as notas
		cAliasDCY := GetNextAlias()
		BeginSql Alias cAliasDCY
			SELECT DCY.DCY_PROD,
			       DCY.DCY_LOTE,
			       DCY.DCY_SUBLOT,
			       DCY.DCY_QTCONF,
			       DCY.DCY_LOCAL
				   %Exp:cSelect%
			FROM %Table:DCY% DCY
			WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			AND DCY.DCY_PRDORI = DCY.DCY_PROD
			AND DCY.DCY_QTCONF > 0
			AND DCY.%NotDel%
			UNION ALL
			SELECT DCY.DCY_PROD,
			       DCY.DCY_LOTE,
			       DCY.DCY_SUBLOT,
			       DCY.DCY_QTCONF,
			       DCY.DCY_LOCAL
				   %Exp:cSelect%
			FROM %Table:DCY% DCY
			WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			AND DCY.DCY_EMBARQ = %Exp:cEmbarque% 
			AND DCY.DCY_PRDORI <> DCY.DCY_PROD
			AND DCY.DCY_QTCONF > 0
			AND EXISTS (SELECT 1
			            FROM %Table:DCY% DCY1
			            WHERE DCY1.DCY_FILIAL = %xFilial:DCY%
			            AND DCY1.DCY_EMBARQ = DCY.DCY_EMBARQ
			            AND DCY1.DCY_PRDORI = DCY.DCY_PRDORI
			            AND DCY1.DCY_PROD = DCY.DCY_PRDORI
			            AND DCY1.DCY_LOTE = DCY.DCY_LOTE
			            AND DCY1.DCY_SUBLOT = DCY.DCY_SUBLOT
			            AND DCY1.DCY_LOCAL = DCY.DCY_LOCAL
			            AND DCY1.DCY_QTCONF = 0
			            AND DCY1.%NotDel%)
			AND DCY.%NotDel%
		EndSql
		TCSetField(cAliasDCY,'DCY_QTCONF','N',aTamDCY[1],aTamDCY[2])
		Do While (cAliasDCY)->(!Eof())
			DbSelectArea(cAliasDCY) // Força ter um alias ativo, pois a função Rastro obriga isso
			lCtrLote  := Rastro((cAliasDCY)->DCY_PROD)
			lSaiLote  := .F.
			lPreNota  := .T.
			nQtdDCY   := (cAliasDCY)->DCY_QTCONF
			nRecnoSD1 := 0
			nQtdCofTot:= 0 // Guarda a quantidade conferida total, para calcular os excessos dos filhos no caso de falta do pai

			If __lWmsNew
				// Deve verificar se o produto é um produto "pai"
				lProdPai := A320PrdPai(cEmbarque,(cAliasDCY)->DCY_PROD,(cAliasDCY)->DCY_LOTE,(cAliasDCY)->DCY_SUBLOT)
			EndIf
			
			cAliasSD1 := GetNextAlias()
			BeginSql Alias cAliasSD1 
				SELECT SD1.D1_TES,
				       SD1.R_E_C_N_O_ RECNOSD1,
				       CASE WHEN D1_LOTECTL = ' ' THEN 2 ELSE 1 END ORDLOTE,
			           SD1.D1_LOTECTL,
			           SD1.D1_NUMLOTE,
			           SD1.D1_DOC,
			           SD1.D1_LOCAL
		        FROM %Table:DCX% DCX 
		        INNER JOIN %Table:SD1% SD1
				ON SD1.D1_FILIAL = %xFilial:SD1%
				AND SD1.D1_DOC = DCX.DCX_DOC
				AND SD1.D1_SERIE = DCX.DCX_SERIE
				AND SD1.D1_FORNECE = DCX.DCX_FORNEC
				AND SD1.D1_LOJA = DCX.DCX_LOJA
				AND SD1.D1_COD = %Exp:(cAliasDCY)->DCY_PROD%
				AND (SD1.D1_LOTECTL = %Exp:(cAliasDCY)->DCY_LOTE% OR SD1.D1_LOTECTL = '   ')
				AND (SD1.D1_NUMLOTE = %Exp:(cAliasDCY)->DCY_SUBLOT% OR SD1.D1_NUMLOTE = '   ')
				AND SD1.D1_LOCAL = %Exp:(cAliasDCY)->DCY_LOCAL%
				AND SD1.D1_QUANT > 0
				AND SD1.D1_OP = ' '
				AND SD1.%NotDel%
			    WHERE DCX.DCX_FILIAL = %xFilial:DCX%
			    AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
			    AND DCX.%NotDel%
				ORDER BY ORDLOTE,
				         SD1.D1_LOTECTL DESC,
				         SD1.D1_NUMLOTE,
				         SD1.D1_DOC
			EndSql
			
			Do While lRet .And. (cAliasSD1)->(!Eof())

				SD1->(DbGoTo((cAliasSD1)->RECNOSD1))
				nRecnoSD1 := (cAliasSD1)->RECNOSD1
				lPreNota  := Empty((cAliasSD1)->D1_TES)
				nQtdConf  := 0

				If QtdComp(nQtdDCY) > 0

					If QtdComp(SD1->D1_QUANT) <= QtdComp(nQtdDCY)
						nQtdOrig := SD1->D1_QUANT
						nQtdConf := SD1->D1_QUANT
					Else
						// Se tem lote informado na nota, deve ser usado total
						// Senão, pode usar o restante da DCZ e dividir o item na nota
						If !lCtrLote .Or. (lCtrLote .And. !Empty(SD1->D1_LOTECTL))
							nQtdOrig := SD1->D1_QUANT
							nQtdConf := nQtdDCY
						Else
							lSaiLote := .T.
							nQtdOrig := nQtdDCY
							nQtdConf := nQtdDCY
						EndIf
					EndIf
					// Diminuindo a quantidade conferida
					nQtdDCY -= nQtdConf
					nQtdCofTot += nQtdConf
				EndIf
				// Se não informou o lote na nota e não tem mais saldo desta DCY,
				// Deve quebrar o item da nota, que ficou sem lote em outro
				If lPreNota .And. lCtrLote .And. lSaiLote .And. QtdComp(nQtdDCY) <= 0
					lRet := CofAtuSD1('F',(SD1->D1_QUANT-nQtdConf),nRecnoSD1,SD1->D1_LOCAL,SD1->D1_ENDER)
				EndIf
				If QtdComp(nQtdConf) > 0
					// Grava a quantidade conferida na SD1
					RecLock('SD1',.F.)
					SD1->D1_QTDCONF := nQtdConf
					If lPreNota
						SD1->D1_LOTECTL := (cAliasDCY)->DCY_LOTE
						SD1->D1_NUMLOTE := (cAliasDCY)->DCY_SUBLOT
						If lDtValid .And. !Empty((cAliasDCY)->DCY_DTVAL)
							SD1->D1_DTVALID := sToD((cAliasDCY)->DCY_DTVAL)
						EndIf
					EndIf
					SD1->(MsUnlock())
				EndIf
				// Deve fazer os cálculos com base na SD1 para verificar excessos ou faltas
				If QtdComp(nQtdConf) > 0 .And. QtdComp(nQtdOrig) > QtdComp(nQtdConf) .And. __lMovFt
					// Deve pegar a diferença e gerar um registro de falta
					If lPreNota
						// Atualiza a SD1 com o registro de falta divindindo se for o caso
						lRet := CofAtuSD1('F',(nQtdOrig-nQtdConf),nRecnoSD1,__cWmsLcFt,__cWmsEnFt)
					ElseIf __lWmsNew
						// Deve atualizar a movimentação da ordem de serviço no WMS
						// Neste ponto sempre atualiza do produto PAI
						lRet := CofMovFal(cEmbarque,(nQtdOrig-nQtdConf),lProdPai,aPrdDist,@cDocFtSD3)
					EndIf
				EndIf
				// Se não informou o lote na nota e não tem mais saldo desta DCZ, sai
				If lCtrLote .And. lSaiLote .And. QtdComp(nQtdDCY) <= 0
					Exit
				EndIf
				(cAliasSD1)->(DbSkip())
			EndDo
			(cAliasSD1)->(DbCloseArea())
			DbSelectArea(cAliasDCY) // Força ter um alias ativo, pois a função Rastro obriga isso
			// Se não existir SD1 ou existir sobra o nQtdDCY estará positivo,
			// então procede com o tratamento para a sobra
			// Só efetua os ajustes na SD1 se o parâmetro de excesso estiverem preenchidos
			If lRet .And. QtdComp(nQtdDCY) > 0 .And. __lMovEx
				// Se o recno é igual a zero, quer dizer que o produto não existe na SD1,
				// portanto é um excesso total, neste caso mesmo sendo um "pai" vai registrar somente deste
				If nRecnoSD1 == 0
					// Busca o último documento do embarque
					cAliasSD1 := GetNextAlias()
					BeginSql Alias cAliasSD1
						SELECT CASE WHEN SD1.D1_COD = %Exp:(cAliasDCY)->DCY_PROD% THEN 1 ELSE 2 END ORDPRD, // Priorizando o mesmo produto
						       CASE WHEN SD1.D1_LOTECTL = %Exp:(cAliasDCY)->DCY_LOTE% THEN 1 ELSE 2 END ORDLOT,
						       CASE WHEN SD1.D1_NUMLOTE = %Exp:(cAliasDCY)->DCY_SUBLOT% THEN 1 ELSE 2 END ORDSUB,
						       SD1.D1_TES,
						       SD1.D1_DOC,
						       SD1.D1_NUMSEQ,
						       SD1.D1_SERIE,
						       SD1.D1_FORNECE,
						       SD1.D1_LOJA,
						       SD1.D1_COD,
						       SD1.D1_LOTECTL,
						       SD1.D1_NUMLOTE,
						       SD1.R_E_C_N_O_ RECNOSD1
						FROM %Table:DCX% DCX 
						INNER JOIN %Table:SD1% SD1
						ON SD1.D1_FILIAL = %xFilial:SD1%
						AND SD1.D1_DOC = DCX.DCX_DOC
						AND SD1.D1_SERIE = DCX.DCX_SERIE
						AND SD1.D1_FORNECE = DCX.DCX_FORNEC
						AND SD1.D1_LOJA = DCX.DCX_LOJA
						AND SD1.D1_QUANT > 0
						AND SD1.D1_OP = ' '
						AND SD1.%NotDel%
						WHERE DCX.DCX_FILIAL = %xFilial:DCX%
						AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
						AND DCX.%NotDel%
						ORDER BY ORDPRD,ORDLOT,ORDSUB,
						         SD1.D1_DOC DESC,
						         RECNOSD1 DESC			
					EndSql
					
					If (cAliasSD1)->(!Eof())
						lPreNota  := Empty((cAliasSD1)->D1_TES)
						If lPreNota
							lExcTotal := !((cAliasSD1)->D1_COD + (cAliasSD1)->D1_LOTECTL + (cAliasSD1)->D1_NUMLOTE == (cAliasDCY)->DCY_PROD + (cAliasDCY)->DCY_LOTE + (cAliasDCY)->DCY_SUBLOT)
							lRet := CofAtuSD1('E',nQtdDCY,(cAliasSD1)->RECNOSD1,__cWmsLcEx,__cWmsEnEx,lExcTotal,(cAliasDCY)->DCY_PROD,(cAliasDCY)->DCY_LOTE,(cAliasDCY)->DCY_SUBLOT)
						ElseIf __lWmsNew
							dDtValid := dDtVazia
							If !Empty((cAliasDCY)->DCY_LOTE)

								If lDtValid
									dDtValid := SToD((cAliasDCY)->DCY_DTVAL)
								Else
									// Deve buscar a data de validade na SB8 ou então criar uma
									SB8->(DbSetOrder(5)) // B8_FILIAL+B8_PRODUTO+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
									If SB8->(DbSeek(xFilial("SB8")+(cAliasDCY)->DCY_PROD+(cAliasDCY)->DCY_LOTE+(cAliasDCY)->DCY_SUBLOT))
										dDtValid := SB8->B8_DTVALID
									Else
										SB1->(DbSetOrder(1))
										SB1->(DbSeek(xFilial('SB1')+cProduto))
										dDtValid := dDataBase + SB1->B1_PRVALID
									EndIf
								EndIf
							EndIf
						   // Gera uma ordem de serviço de endereçamento para o armazém/endereço de excesso
						   // Neste ponto sempre atualiza do produto PAI
							lRet := CofMovExc(cEmbarque,(cAliasDCY)->DCY_PROD,(cAliasDCY)->DCY_LOTE,(cAliasDCY)->DCY_SUBLOT,dDtValid,nQtdDCY,@cDocExSD3,lProdPai,(cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA)
						EndIf
					EndIf
					(cAliasSD1)->(DbCloseArea())
					DbSelectArea(cAliasDCY) // Força ter um alias ativo, pois a função Rastro obriga isso
				Else
					// Senão é sobra parcial
					If lPreNota
						// Quebra a quantidade do item na pré-nota
						lRet := CofAtuSD1('E',nQtdDCY,nRecnoSD1,__cWmsLcEx,__cWmsEnEx)
					ElseIf __lWmsNew
						// Gera uma ordem de serviço de endereçamento para o armazém/endereço de excesso
						// Neste ponto sempre atualiza do produto PAI
						lRet := CofMovExc(cEmbarque,(cAliasDCY)->DCY_PROD,(cAliasDCY)->DCY_LOTE,(cAliasDCY)->DCY_SUBLOT,SD1->D1_DTVALID,nQtdDCY,@cDocExSD3,lProdPai,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA)
					EndIf
				EndIf
				nQtdCofTot += nQtdDCY
			EndIf
			(cAliasDCY)->(DbSkip())
		EndDo
		(cAliasDCY)->(DbCloseArea())

		// Deve verificar agora se não ficou algum item da nota sem conferir
		If lRet .And. __lMovFt
			cAliasSD1 := GetNextAlias()
			BeginSql Alias cAliasSD1
			    SELECT SD1.D1_TES,
			           SD1.R_E_C_N_O_ RECNOSD1
			    FROM %Table:DCX% DCX
			    INNER JOIN %Table:SD1% SD1
			    ON SD1.D1_FILIAL = %xFilial:SD1%
			    AND SD1.D1_DOC = DCX.DCX_DOC
			    AND SD1.D1_SERIE = DCX.DCX_SERIE
			    AND SD1.D1_FORNECE = DCX.DCX_FORNEC
			    AND SD1.D1_LOJA = DCX.DCX_LOJA
			    AND SD1.D1_QTDCONF = 0
			    AND SD1.D1_QUANT > 0
			    AND SD1.D1_OP = ' '
			    AND SD1.%NotDel%
			    WHERE DCX.DCX_FILIAL = %xFilial:DCX%
			    AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
			    AND DCX.%NotDel%
			    ORDER BY SD1.D1_COD,
			             SD1.D1_LOTECTL,
			             SD1.D1_NUMLOTE			    
			EndSql
			
			Do While lRet .And. (cAliasSD1)->(!Eof())
				SD1->(DbGoTo((cAliasSD1)->RECNOSD1))
				lPreNota  := Empty((cAliasSD1)->D1_TES)
				If lPreNota
					// Atualiza a SD1 com o registro de falta divindindo se for o caso
					lRet := CofAtuSD1('F',(SD1->D1_QUANT-SD1->D1_QTDCONF),(cAliasSD1)->RECNOSD1,__cWmsLcFt,__cWmsEnFt)
				ElseIf __lWmsNew
					// Deve verificar se o produto é um produto "pai"
					lProdPai := A320PrdPai(cEmbarque,SD1->D1_COD,SD1->D1_LOTECTL,SD1->D1_NUMLOTE)
					// Deve gerar uma movimentação de estoque para o armazém/endereço de falta
					// Neste ponto sempre atualiza do produto PAI
					lRet := CofMovFal(cEmbarque,(SD1->D1_QUANT-SD1->D1_QTDCONF),lProdPai,aPrdDist,@cDocFtSD3)
				EndIf
				(cAliasSD1)->(DbSkip())
			EndDo
			(cAliasSD1)->(DbCloseArea())
		EndIf

		If lRet
			// Deve atualizar a situação dos documentos
			cAliasSF1 := GetNextAlias()
			BeginSql Alias cAliasSF1
				SELECT SF1.R_E_C_N_O_ RECNOSF1
				FROM %Table:DCX% DCX
				INNER JOIN %Table:SF1% SF1
				ON SF1.F1_FILIAL = %xFilial:SF1%
				AND SF1.F1_DOC = DCX.DCX_DOC
				AND SF1.F1_SERIE = DCX.DCX_SERIE
				AND SF1.F1_FORNECE = DCX.DCX_FORNEC
				AND SF1.F1_LOJA = DCX.DCX_LOJA
				AND SF1.%NotDel%
				WHERE DCX.DCX_FILIAL = %xFilial:DCX%
				AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
				AND DCX.%NotDel%
			EndSql
			
			Do While (cAliasSF1)->(!Eof())
				SF1->(DbGoTo((cAliasSF1)->RECNOSF1))
				// Verifica se teve algum item da nota que apresentou divergência
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
	  			    SELECT R_E_C_N_O_ RECNOSD1
	  			    FROM %Table:SD1% SD1
	  			    WHERE D1_FILIAL = %xFilial:SD1%
	  			    AND D1_DOC = %Exp:SF1->F1_DOC%
	  			    AND D1_SERIE = %Exp:SF1->F1_SERIE%
	  			    AND D1_FORNECE = %Exp:SF1->F1_FORNECE%
	  			    AND D1_LOJA = %Exp:SF1->F1_LOJA%
	  			    AND D1_QUANT > 0
	  			    AND (SD1.D1_QUANT <> SD1.D1_QTDCONF)
	  			    AND D1_OP = ' '
	  			    AND %NotDel%	  			    
				EndSql
				
				RecLock('SF1',.F.)
				If (cAliasQry)->(Eof()) // Se não tem divergencia
					SF1->F1_STATCON := "1" // NF conferida
				ElseIf Empty(SF1->F1_STATUS) // É Pre-Nota
					SF1->F1_STATCON := "2" // NF com divergencia
				Else
					SF1->F1_STATCON := "4" // NF Clas. C/ Diver.
				EndIf
				SF1->(MsUnlock())
				(cAliasQry)->(DbCloseArea())

				(cAliasSF1)->(DbSkip())
			EndDo
			(cAliasSF1)->(DbCloseArea())

			If lRet
				DCW->(DbSetOrder(1))
				If DCW->(DbSeek(xFilial('DCW')+cEmbarque))
					RecLock('DCW',.F.)
					If lDiverge
						DCW->DCW_SITEMB = Iif(lExistStat .And. lDiverLote,"8","7") //7=Prod.Confer.c/Diverg Qtd.  //8=Prod.Confer.c/Diverg Lote'
					Else
						DCW->DCW_SITEMB = "6" //6=Prod.Confer
					EndIf
					DCW->(MsUnlock())
				EndIf
			EndIf
		EndIf
		If lRet
			cAliasQry := GetNextAlias()
			If __lWmsNew
				BeginSql Alias cAliasQry 
					SELECT R_E_C_N_O_ RECNODCY
					FROM %Table:DCY% DCY
					WHERE DCY.DCY_FILIAL = %xFilial:DCY%
					AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
					AND DCY.DCY_QTORIG <= 0
					AND DCY.DCY_QTCONF <= 0
					AND NOT EXISTS (SELECT 1
					                FROM %Table:DCY% DCY1
					                WHERE DCY1.DCY_FILIAL = DCY.DCY_FILIAL
					                AND DCY1.DCY_EMBARQ = DCY.DCY_EMBARQ
					                AND DCY1.DCY_PRDORI = DCY.DCY_PRDORI
					                AND DCY1.DCY_LOTE = DCY.DCY_LOTE
					                AND DCY1.DCY_SUBLOT = DCY.DCY_SUBLOT
					                AND DCY1.DCY_LOCAL = DCY.DCY_LOCAL
					                AND DCY1.DCY_QTORIG <= 0
					                AND DCY1.DCY_QTCONF > 0
					                AND DCY1.%NotDel%)
					AND DCY.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasQry 
					SELECT R_E_C_N_O_ RECNODCY
					FROM %Table:DCY% DCY
					WHERE DCY.DCY_FILIAL = %xFilial:DCY%
					AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
					AND DCY.DCY_QTORIG <= 0
					AND DCY.DCY_QTCONF <= 0
					AND DCY.%NotDel%
				EndSql
			EndIf
			
			Do While (cAliasQry)->(!Eof() )
				DCY->(DbGoTo((cAliasQry)->RECNODCY))
				RecLock('DCY',.F.)
				DCY->(dbDelete())
				DCY->(MsUnlock())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		EndIf
		If Len(aPrdDist) > 0
			// Realiza o recalculo de cada distribuição encontrada na conferência
			For nI := 1 To Len(aPrdDist)

				// Posiciona no registro para carregar o modelo de dados
				D06->(dbSetOrder(1))
				D06->(dbSeek(xFilial("D06")+aPrdDist[nI][1]))
				oModelD06 := FWLoadModel("WMSA325A")
				oModelD06:SetOperation( MODEL_OPERATION_UPDATE )
				oModelD06:Activate()

				// Altera todos os produtos da distribuição
				For nX := 1 To Len(aPrdDist[nI][2])
					cDocto   := aPrdDist[nI][2][nX][1]
					cSerie   := aPrdDist[nI][2][nX][2]
					cFornece := aPrdDist[nI][2][nX][3]
					cLoja    := aPrdDist[nI][2][nX][4]
					cProduto := aPrdDist[nI][2][nX][5]
					cItem    := aPrdDist[nI][2][nX][6]
					nQuant   := aPrdDist[nI][2][nX][7]

					// Altera a D07 com quantidade do produto alterado
					oModelD06:GetModel("D07GRID"):SeekLine({{"D07_DOC",cDocto},{"D07_SERIE",cSerie},{"D07_FORNEC",cFornece},{"D07_LOJA",cLoja},{"D07_PRODUT",cProduto},{"D07_ITEM",cItem}})
					oModelD06:GetModel("D07GRID"):SetValue("D07_QTDENT",(oModelD06:GetModel("D07GRID"):GetValue("D07_QTDENT") - nQuant))
					oModelD06:GetModel("D07GRID"):SetValue("D07_QTDEN2", ConvUm(cProduto, oModelD06:GetModel("D07GRID"):GetValue("D07_QTDENT"), 0, 2))
				Next nX

				// Ajusta as quantidades da D09
				WMS325RD09(oModelD06)
				// Função com a regra da distribuição das quantidades
				// Tipo de rateio: 1=Direto, 2=Proporcional, 3=Unidade + Proporcional
				// Toma como padrão o tipo de rateio 1
				WMSA325ART(oModelD06,Iif(nWmsDpCa<1.Or.nWmsDpCa>3,1,nWmsDpCa))
				// Validação do modelo de dados
				// Monta os dados da D0F no valid
				If oModelD06:VldData()
					// Efetivação dos dados
					oModelD06:CommitData()
				Else
					// Erro do modelo de dados
					WmsMessage(oModelD06:GetErrorMessage()[6],WMSA320D01)
					lRet := .F.
					Exit
				EndIf
				oModelD06:DeActivate()
			Next nI
		EndIf

		//Ajusta D14 caso foram gerados unitizadores e a conferência for do tipo "Documento de Entrada"
		If lRet .And. WmsX212118("D0R")
			//Cria D0Q para a conferência
			If lRet
				oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
				oDmdUnit:SetCodRec(cEmbarque)
				oDmdUnit:SetOrigem('DCW')
				If !(lRet := oDmdUnit:AssignDCW())
					WmsMessage(oDmdUnit:GetErro(),WMSA320D40)
				EndIf
			EndIf
			If lRet
				If cTpConf == "2"
					If (lRet := Wm320UnD14(cEmbarque))
						//Gera ordens de serviço para os unitizadores.
						lRet := Wm320UnDCF(cEmbarque)
					EndIf
				Else
					// Atualiza status dos unitizadores da conferencia de prenota
					lRet := UpdStsUnit(cEmbarque)
				EndIf
			EndIf
		EndIf

		If ExistBlock("W320DFCO")
			lW320DFCO := Execblock("W320DFCO",.F.,.F., {cEmbarque})
			If ValType(lW320DFCO) == "L"
				lRet := lW320DFCO
			Endif
		Endif

		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction

	If lRet
		WmsExeServ() // Executa as ordens de serviço que por ventura foram geradas
	EndIf

	RestArea(aAreaAnt)
Return lRet

//Verifica se existe o tratamento para o novo status 8(Divergência de Lotes)
Static Function ExisteStatus()
Return "WMA320CBox()" $ GetSx3Cache("DCW_SITEMB","X3_CBOX")

//------------------------------------------------------------------------------
// Efetua a reabertura da conferência do recebimento
//------------------------------------------------------------------------------
Function Wm320RbCof(cEmbarque,cTpConf)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cAliasQry  := ""
Local cSelect    := ""
Local cLocalCQ   := SuperGetMV("MV_CQ",.F.,"98")
Local oRegraConv := Nil
Local oOrdSerExe := Nil
Local aRecDCF    := {}
Local nX         := 0
Local lD0kPed    := D0K->(ColumnPos("D0K_PEDIDO")) > 0
Local lD0kEnd    := D0K->(ColumnPos("D0K_ENDER")) > 0
Local lD0kServ    := D0K->(ColumnPos("D0K_SERVIC")) > 0
Local lEstMovCof := .T. //Variavel utilizada no retorno do ponto de entrada W320DMOV

	//Ponto de entrada para não gerar as movimentações de ajustes no sistema, referentes as divergências da conferência
	If ExistBlock("W320DMOV")
		lW320DMOV := Execblock("W320DMOV",.F.,.F., {cEmbarque,cTpConf})
		If ValType(lW320DMOV) == "L"  .And. !lW320DMOV
			lEstMovCof := .F.
		Endif
	Endif

	// Seta um tamanho para régua de progressão
	If !IsTelNet() .And. !Wm320Autom()
		ProcRegua(0)
	EndIf
	Begin Transaction
		// Volta as notas fiscais para o status de não conferidas
		lRet := Wm320BqSF1(cEmbarque) // Em Processo Conferencia
		// Avalia as ordens de serviço e movimentos para retornar ao status inicial
		If lRet .And. __lWmsNew .And. cTpConf == '2' .And. lEstMovCof
			lRet := EstMovCof(cEmbarque,@aRecDCF)
		EndIf
		// Atualiza status dos unitizadores da conferencia de prenota
		If (lRet := UpdStsUnit(cEmbarque,.F.))
			If cTpConf == '1'
				// Apaga demanda de unitização e desassocia D0Q e D0S
				lRet := DelDmdUni(cEmbarque)
			EndIf
		EndIf
		// Deve reagrupar os itens das pré-notas que foram conferidas num
		// processo anterior e foram registrados como divergências ou preenchidos os lotes
		If lRet
			cSelect := "%"
			If lDtValid
				cSelect += " ,D0K.D0K_DTVAL"
			EndIf
			If lD0kPed
				cSelect += " ,D0K.D0K_PEDIDO "
				cSelect += " ,D0K.D0K_ITEMPC "
			EndIf
			If lD0kEnd
				cSelect += " ,D0K.D0K_ENDER "
			EndIf
			If lD0kServ
				cSelect += " ,D0K.D0K_SERVIC "
			EndIf
			cSelect += "%"
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry 
				SELECT D0K.D0K_LOCAL,
				       D0K.D0K_LOTE,
				       D0K.D0K_SUBLOT,
				       D0K.D0K_QUANT,
					   SD1.R_E_C_N_O_ RECNOSD1
					   %Exp:cSelect%
				FROM %Table:D0K% D0K
				INNER JOIN %Table:SD1% SD1
				ON SD1.D1_FILIAL = %xFilial:SD1%
				AND SD1.D1_DOC = D0K.D0K_DOC
				AND SD1.D1_SERIE = D0K.D0K_SERIE
				AND SD1.D1_FORNECE = D0K.D0K_FORNEC
				AND SD1.D1_LOJA = D0K.D0K_LOJA
				AND SD1.D1_COD = D0K.D0K_PROD
				AND SD1.D1_ITEM = D0K.D0K_ITEM
				AND SD1.D1_TES = ' ' // Somente pré-nota
				AND SD1.D1_QUANT > 0
				AND SD1.D1_OP = ' '
				AND SD1.%NotDel%
				WHERE D0K.D0K_FILIAL = %xFilial:D0K%
				AND D0K.D0K_EMBARQ = %Exp:cEmbarque%
				AND D0K.%NotDel%
			EndSql
			
			Do While lRet .And. (cAliasQry)->(!Eof())
				SD1->(DbGoTo((cAliasQry)->RECNOSD1))
				// Ajusta as quantidades e valores caso seja necessário
				If QtdComp(SD1->D1_QUANT) != QtdComp((cAliasQry)->D0K_QUANT)
					WmsSubSD1("WMSA320",SD1->D1_QUANT-(cAliasQry)->D0K_QUANT)
				EndIf
				// Ajusta as informações originais da SD1
				RecLock('SD1',.F.)
				SD1->D1_LOCAL   := (cAliasQry)->D0K_LOCAL
				SD1->D1_LOTECTL := (cAliasQry)->D0K_LOTE
				SD1->D1_NUMLOTE := (cAliasQry)->D0K_SUBLOT
				If lDtValid
					SD1->D1_DTVALID := SToD((cAliasQry)->D0K_DTVAL)
				EndIf
				SD1->D1_QTDCONF := 0
				IF lD0kPed .AND. !Empty((cAliasQry)->D0K_PEDIDO)
					SD1->D1_PEDIDO := (cAliasQry)->D0K_PEDIDO
					SD1->D1_ITEMPC := (cAliasQry)->D0K_ITEMPC
				EndIf 
				If lD0kEnd
					SD1->D1_ENDER := (cAliasQry)->D0K_ENDER
				EndIf
				If lD0kServ
					SD1->D1_SERVIC := (cAliasQry)->D0K_SERVIC
				EndIf
				SD1->(MsUnlock())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
		If lRet .And. cTpConf == '1'
			// Deve excluir os itens das pré-notas que foram conferidas num
			// processo anterior e foram registrados como divergências ou preenchidos
			// os lotes, porém não existiam originalmente nos documentos
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry 
			    SELECT SD1.R_E_C_N_O_ RECNOSD1
			    FROM %Table:DCX% DCX
			    INNER JOIN %Table:SD1% SD1
			    ON SD1.D1_FILIAL = %xFilial:SD1%
			    AND SD1.D1_DOC = DCX.DCX_DOC
			    AND SD1.D1_SERIE = DCX.DCX_SERIE
			    AND SD1.D1_FORNECE = DCX.DCX_FORNEC
			    AND SD1.D1_LOJA = DCX.DCX_LOJA
			    AND SD1.D1_TES = ' ' // Somente pré-nota
			    AND SD1.D1_QUANT > 0
			    AND SD1.D1_OP = ' '
			    AND SD1.%NotDel%
			    AND NOT EXISTS (SELECT 1
			                    FROM %Table:D0K% D0K
			                    WHERE D0K.D0K_FILIAL = %xFilial:D0K%
			                    AND D0K.D0K_EMBARQ = %Exp:cEmbarque%
			                    AND D0K.D0K_DOC = SD1.D1_DOC
			                    AND D0K.D0K_SERIE = SD1.D1_SERIE
			                    AND D0K.D0K_FORNEC = SD1.D1_FORNECE
			                    AND D0K.D0K_LOJA = SD1.D1_LOJA
			                    AND D0K.D0K_PROD = SD1.D1_COD
			                    AND D0K.D0K_ITEM = SD1.D1_ITEM
			                    AND D0K.%NotDel%)
			    WHERE DCX.DCX_FILIAL = %xFilial:DCX%
			    AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
			    AND DCX.%NotDel%
			EndSql
			Do While lRet .And. (cAliasQry)->(!Eof())
				SD1->(DbGoTo((cAliasQry)->RECNOSD1))
				// Exclui o excesso da pré-nota
				RecLock('SD1',.F.)
				SD1->(DbDelete())
				SD1->(MsUnlock())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
		// Zerando todas as quantidades conferidas
		// Deve fazer separado, pois pode ter sido reaberto uma conferência após
		// classificar uma nota fiscal que foi conferida originalmente como pré-nota
		If lRet
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry 
				SELECT SD1.R_E_C_N_O_ RECNOSD1
				FROM %Table:SD1% SD1
				INNER JOIN %Table:DCX% DCX
				ON DCX.DCX_FILIAL = %xFilial:DCX%
				AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
				AND DCX.DCX_DOC = SD1.D1_DOC
				AND DCX.DCX_SERIE = SD1.D1_SERIE
				AND DCX.DCX_FORNEC = SD1.D1_FORNECE
				AND DCX.DCX_LOJA = SD1.D1_LOJA
				AND DCX.%NotDel%
				WHERE SD1.D1_FILIAL = %xFilial:SD1%
				AND SD1.D1_QUANT > 0
				AND SD1.D1_QTDCONF > 0
				AND SD1.D1_OP = ' '
				AND SD1.%NotDel%
			EndSql
			
			Do While lRet .And. (cAliasQry)->(!Eof())
				SD1->(DbGoTo((cAliasQry)->RECNOSD1))
				RecLock('SD1',.F.)
				SD1->D1_QTDCONF := 0
				SD1->(MsUnlock())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
		// Caso existam itens que tenham ido para o controle de qualidade,
		// deve retornar as quantidades que tenham sido conferidas com divergência
		If lRet .And. cTpConf == '2' .And. lEstMovCof
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry 
				SELECT SD1.D1_COD,
				       SD1.D1_QUANT,
				       SD1.R_E_C_N_O_ RECNOSD1,
				       SF1.R_E_C_N_O_ RECNOSF1,
				       SD7.D7_SALDO,
				       SD7.R_E_C_N_O_ RECNOSD7
				FROM %Table:SD1% SD1
				INNER JOIN %Table:DCX% DCX
				ON DCX.DCX_FILIAL = %xFilial:DCX%
				AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
				AND DCX.DCX_DOC = SD1.D1_DOC
				AND DCX.DCX_SERIE = SD1.D1_SERIE
				AND DCX.DCX_FORNEC = SD1.D1_FORNECE
				AND DCX.DCX_LOJA = SD1.D1_LOJA
				AND DCX.%NotDel%
				INNER JOIN %Table:SF1% SF1
				ON SF1.F1_FILIAL = %xFilial:SF1%
				AND SF1.F1_DOC = SD1.D1_DOC
				AND SF1.F1_SERIE = SD1.D1_SERIE
				AND SF1.F1_FORNECE = SD1.D1_FORNECE
				AND SF1.F1_LOJA = SD1.D1_LOJA
				AND SF1.%NotDel%
				LEFT JOIN %Table:SD7% SD7
				ON SD7.D7_FILIAL = %xFilial:SD7%
				AND SD7.D7_PRODUTO = SD1.D1_COD
				AND SD7.D7_NUMSEQ = SD1.D1_NUMSEQ
				AND SD7.D7_NUMERO = SD1.D1_NUMCQ
				AND SD7.%NotDel%
				WHERE SD1.D1_FILIAL = %xFilial:SD1%
				AND SD1.D1_QUANT > 0
				AND SD1.D1_OP = ' '
				AND SD1.D1_LOCAL = %Exp:cLocalCQ%
				AND SD1.%NotDel%
			EndSql
			
			Do While lRet .And. !(cAliasQry)->(Eof())
				// Caso encontre o registro de CQ
				If (cAliasQry)->RECNOSD7 > 0
					// Altera apenas se as quantidades forem diferentes, indicando que houve divergência na conferência
					If QtdComp((cAliasQry)->D1_QUANT) != QtdComp((cAliasQry)->D7_SALDO)
						SD7->(DbGoTo((cAliasQry)->RECNOSD7))
						RecLock('SD7',.F.)
						SD7->D7_SALDO  := (cAliasQry)->D1_QUANT
						SD7->D7_SALDO2 := ConvUm((cAliasQry)->D1_COD,(cAliasQry)->D1_QUANT,0,2)
						SD7->(MsUnlock())
					EndIf
				Else
					// Caso tenha sido falta total na primeira conferência
					SF1->(DbGoTo((cAliasQry)->RECNOSF1))
					SD1->(DbGoTo((cAliasQry)->RECNOSD1))
					If (lRet := fGeraCQ0("SD1",SD1->D1_COD,"CP",SD1->D1_LOCAL))
						RecLock('SD1',.F.)
						SD1->D1_NUMCQ := SD7->D7_NUMERO
						SD1->(MsUnlock())
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
		// Volta o status da conferência do recebimento
		If lRet
			RecLock('DCW',.F.)
			DCW->DCW_SITEMB := "5" // Produto em Andamento
			DCW->(MsUnlock())
		EndIf
		// Rollback quando houve problema
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction

	If lRet
		// Verificar status da conferencia de recebimento.
		A320COFDCY(cEmbarque)
		If Len(aRecDCF) > 0
			oRegraConv := WMSBCCRegraConvocacao():New()
			oOrdSerExe := WMSDTCOrdemServicoExecute():New()

			For nX := 1 To Len(aRecDCF)
				oOrdSerExe:SetArrLib(oRegraConv:GetArrLib())
				oOrdSerExe:GoToDCF(aRecDCF[nX])
				If oOrdSerExe:ExecuteDCF()
					// O wms devera avaliar as regras para convocacao do servico e disponibilizar os
					// registros do D12 para convocacao
					oRegraConv:LawExecute()
				Else
					WmsMessage( oOrdSerExe:GetErro(),WMSA320D02,2)
				EndIf
			Next nX

			FreeObj(oRegraConv)
			oOrdSerExe:Destroy()
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} CofAtuSD1
Atualiza a SD1, quebrando as quantidades de acordo com falta
ou sobra na pré-nota de entrada

@author  Guilherme A. Metzger
@version P11
@since   18/11/14
/*/
//----------------------------------------------------------
Static Function CofAtuSD1(cTipo,nQuant,nRecnoSD1,cLocal,cEnder,lExcTotal,cProduto,cLote,cSubLote)
Local aAreaAnt  := GetArea()
Local aAreaSD1  := SD1->(GetArea())
Local cLocAnt   := ""
Local cEndAnt   := ""

Default lExcTotal := .F.

	// Posiciona na SD1 correspondente
	SD1->(DbGoTo(nRecnoSD1))
	cLocAnt := SD1->D1_LOCAL
	cEndAnt := SD1->D1_ENDER
	// Se for falta e a quantidade for igual a do item, só altera o local
	If cTipo == "F" .And. nQuant == SD1->D1_QUANT
		RecLock('SD1',.F.)
		// Se armazem falta diferente do armazem do item do documento
		SD1->D1_LOCAL   := cLocal
		SD1->(MsUnlock())
	Else
		// Quebra o item da SD1 e recalcula impostos, despesas, etc, de acordo a quantidade de quebra
		WmsSplitD1("WMSA320",SD1->D1_QUANT,nQuant,(cTipo == "F"),lExcTotal,cLocal,cProduto,cLote,cSubLote)
	EndIf
	// Se armazem falta diferente do armazem do item do documento
	If cLocAnt <> cLocal .Or. cEndAnt <> cEnder
		RecLock('SD1',.F.)
		If cTipo == "F"
			SD1->D1_SERVIC  := __cWmsSrFt
			SD1->D1_ENDER   := __cWmsEnFt
		Else
			SD1->D1_SERVIC  := __cWmsSrEx
			SD1->D1_ENDER   := __cWmsEnEx
		EndIf
		SD1->D1_PEDIDO  := ""
		SD1->D1_ITEMPC  := ""
		SD1->(MsUnlock())
	EndIf

// Restaura
RestArea(aAreaSD1)
RestArea(aAreaAnt)
Return .T.

//------------------------------------------------------------------------------------------------------
Static Function CofMovFal(cEmbarque,nQuant,lProdPai,aPrdDist,cDoctoSD3)
//------------------------------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local oProdComp  := Iif(!lProdPai,Nil,WMSDTCProdutoComponente():New())
Local aProdComp  := {}
Local cAliasQry  := ""
Local cNumSeqFal := ""
Local cProduto   := SD1->D1_COD
Local cIdDCF     := SD1->D1_IDDCF
Local cLoteCtl   := SD1->D1_LOTECTL
Local cNumLote   := SD1->D1_NUMLOTE
Local dDtValid   := SD1->D1_DTVALID
Local cNumSeq    := SD1->D1_NUMSEQ
Local cDocto     := SD1->D1_DOC
Local cSerie     := SD1->D1_SERIE
Local cCliFor    := SD1->D1_FORNECE
Local cLoja      := SD1->D1_LOJA
Local cLocal     := SD1->D1_LOCAL
Local cEndereco  := SD1->D1_ENDER
Local cWhere     := ""

	//Ponto de entrada para não gerar as movimentações de ajustes no sistema, referentes as divergências da conferência
	If ExistBlock("W320DMOV")
		lW320DMOV := Execblock("W320DMOV",.F.,.F., {cEmbarque,"F"})
		If ValType(lW320DMOV) == "L" .And. !lW320DMOV
			Return lRet
		Endif
	Endif

	//Carrega produtos
	If lProdPai
		oProdComp:SetProduto(cProduto)
		oProdComp:SetPrdOri(cProduto)
		oProdComp:EstProduto()
		aProdComp := oProdComp:GetArrProd()
	Else
		Aadd(aProdComp,{cProduto,1,cProduto})
	EndIf

	If Empty(cDoctoSD3)
		cDoctoSD3 := AjustaDoc("CFT"+cEmbarque,cEmbarque)
	EndIf

	If WmsArmUnit(SD1->D1_LOCAL) //Se o armazém controla unitizador
		lRet := MovFalUni(nQuant,aProdComp,cProduto,cLocal,cDocto,cSerie,cCliFor,cLoja,cNumSeq,cEndereco,cLoteCtl,cNumLote)
	Else
		lRet := MovFalOrd(cEmbarque,cIdDCF,nQuant,aProdComp)
	EndIf

	If lRet
		cAliasQry := GetNextAlias()

		If !Empty(cIdDCF)
			cWhere := " AND SD1.D1_IDDCF = '"+cIdDCF+"'"
		Else
			cWhere := " AND SD1.D1_NUMSEQ = '"+cNumSeq+"'"
		EndIf
		cWhere := "%" + cWhere + "%"

		BeginSql Alias cAliasQry
			SELECT SD1.D1_CODDIS,
			       SD1.D1_DOC,
			       SD1.D1_SERIE,
			       SD1.D1_FORNECE,
			       SD1.D1_LOJA,
			       SD1.D1_COD,
			       SD1.D1_ITEM
			FROM %Table:SD1% SD1
			INNER JOIN %Table:D06% D06
			ON D06.D06_FILIAL = %xFilial:D06%
			AND D06.D06_CODDIS = SD1.D1_CODDIS
			AND D06.D06_SITDIS <> '3'
			AND D06.%NotDel%
			WHERE SD1.D1_FILIAL = %xFilial:SD1%
			%Exp:cWhere%
			AND SD1.D1_CODDIS <> '   '
			AND SD1.D1_QUANT > 0
			AND SD1.D1_OP = ' '
			AND SD1.%NotDel%
		EndSql

		Do While (cAliasQry)->(!Eof())
			// Carrega dos dados da D07
			If (nPosDist := aScan(aPrdDist,{|x| x[1] == (cAliasQry)->D1_CODDIS})) == 0
				// Adiciona o código da distribuição que está na conferência com divergência negativa
				aAdd(aPrdDist,{(cAliasQry)->D1_CODDIS,{{(cAliasQry)->D1_DOC,(cAliasQry)->D1_SERIE,(cAliasQry)->D1_FORNECE,(cAliasQry)->D1_LOJA,(cAliasQry)->D1_COD,(cAliasQry)->D1_ITEM,nQuant}}})
			Else
				// Adiciona os produtos de cada distribuição que possa estar na conferência
				aAdd(aPrdDist[nPosDist][2],{(cAliasQry)->D1_DOC,(cAliasQry)->D1_SERIE,(cAliasQry)->D1_FORNECE,(cAliasQry)->D1_LOJA,(cAliasQry)->D1_COD,(cAliasQry)->D1_ITEM,nQuant})
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	// Geração das requisições de retirada e entrada da falta na SD3
	// Realiza a movimentação de retirada do produto no armazém atual
	If lRet
		lRet := UpdMovSd3(__cWmsTMRe,;
							cProduto,;
							cLoteCtl,;
							cNumLote,;
							dDtValid,;
							nQuant,;
							cLocal,;
							cEndereco,;
							__cWmsSrRe,;
							@cNumSeqFal,;
							cDoctoSD3,;
							cEmbarque,;
							cDocto,;
							cSerie,;
							cCliFor,;
							cLoja)
	EndIf
	// Realiza a movimentação de saída no WMS e o registro do KARDEX para o armazém atual
	If lRet
		lRet := UpdMovEst(__cWmsTMRe,;
							aProdComp,;
							cLoteCtl,;
							cNumLote,;
							nQuant,;
							cLocal,;
							cEndereco,;
							cNumSeqFal,;
							cDoctoSD3,;
							"DCW")
	EndIf
	// Realiza a movimentação de entrada do produto no armazém de falta
	If lRet
		cNumSeqFal := Nil
		lRet := UpdMovSd3(__cWmsTMFt,;
							cProduto,;
							cLoteCtl,;
							cNumLote,;
							dDtValid,;
							nQuant,;
							__cWmsLcFt,;
							__cWmsEnFt,;
							__cWmsSrFt,;
							@cNumSeqFal,;
							cDoctoSD3,;
							cEmbarque,;
							cDocto,;
							cSerie,;
							cCliFor,;
							cLoja)
	EndIf
	// Realiza a movimentação de saída no WMS e o registro do KARDEX para o armazém de falta
	If lRet
		lRet := UpdMovEst(__cWmsTMFt,;
							aProdComp,;
							cLoteCtl,;
							cNumLote,;
							nQuant,;
							__cWmsLcFt,;
							__cWmsEnFt,;
							cNumSeqFal,;
							cDoctoSD3,;
							"DCW")
	EndIf
	// Ajusta o movimento de controle de qualidade, se houver
	If lRet
		lRet := UpdMovCQ(cDocto,;
							cSerie,;
							cCliFor,;
							cLoja,;
							cProduto,;
							cLoteCtl,;
							cNumLote,;
							cIdDCF,;
							nQuant)
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-------------------------------------------------------------------------
Static Function CofMovExc(cEmbarque,cProduto,cLoteCtl,cNumLote,dDtValid,nQuant,cDoctoSD3,lProdPai,cDocSD1,cSerie,cFornec,cLoja)
//-------------------------------------------------------------------------
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cNumSeqEx := ""
Local oOrdServ  := WmsOrdSer()
Local oDmdUnit  := Nil
Private __cCodRec := cEmbarque

	//Ponto de entrada para não gerar as movimentações de ajustes no sistema, referentes as divergências da conferência
	If ExistBlock("W320DMOV")
		lW320DMOV := Execblock("W320DMOV",.F.,.F., {cEmbarque,"E"})
		If ValType(lW320DMOV) == "L" .And. !lW320DMOV
			Return lRet
		Endif
	Endif

	If Empty(cDoctoSD3)
		cDoctoSD3 := AjustaDoc("CEX"+cEmbarque,cEmbarque)
	EndIf

	lRet := UpdMovSd3(__cWmsTMEx,;
						cProduto,;
						cLoteCtl,;
						cNumLote,;
						dDtValid,;
						nQuant,;
						__cWmsLcEx,;
						__cWmsEnEx,;
						__cWmsSrEx,;
						@cNumSeqEx,;
						cDoctoSD3,;
						cEmbarque,;
						cDocSD1,;
						cSerie,;
						cFornec,;
						cLoja)

	If lRet
		// Quando o armazém de excesso não é unitizado, grava DCF para endereçar o excesso
		If !WmsArmUnit(__cWmsLcEx)

			If oOrdServ == Nil
				oOrdServ := WMSDTCOrdemServicoCreate():New()
				WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
			EndIf

			oOrdServ:SetOrigem('SD3')
			oOrdServ:SetDocto(cDoctoSD3)
			oOrdServ:SetSerie("")
			oOrdServ:SetCliFor("")
			oOrdServ:SetLoja("")
			oOrdServ:SetNumSeq(cNumSeqEx)
			oOrdServ:SetCodRec(cEmbarque)
			oOrdServ:SetServico(__cWmsSrEx)
			oOrdServ:SetIdUnit('')
			// Dados endereço origem
			oOrdServ:oOrdEndOri:SetArmazem(__cWmsLcEx)
			oOrdServ:oOrdEndOri:SetEnder(__cWmsEnEx)
			// Dados endereço destino
			oOrdServ:oOrdEndDes:SetArmazem(__cWmsLcEx)
			// Gera a ordem de serviço gerando a entrada com base nos endereços escolhidos
			If !(lRet := oOrdServ:CreateDCF())
				WmsMessage(oOrdServ:GetErro(),WMSA320D03,1)
			EndIf
		Else
			oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
			oDmdUnit:SetOrigem('SD3')
			oDmdUnit:SetDocto(cDoctoSD3)
			oDmdUnit:SetSerie("")
			oDmdUnit:SetCliFor("")
			oDmdUnit:SetLoja("")
			oDmdUnit:SetNumSeq(cNumSeqEx)
			oDmdUnit:SetCodRec(cEmbarque)
			oDmdUnit:SetServico(__cWmsSrEx)
			// Dados endereço origem
			oDmdUnit:oDmdEndOri:SetArmazem(__cWmsLcEx)
			oDmdUnit:oDmdEndOri:SetEnder(__cWmsEnEx)
			// Dados endereço destino
			oDmdUnit:oDmdEndDes:SetArmazem(__cWmsLcEx)
			// Gera a demanda de unitização gerando a entrada com base nos endereços escolhidos
			If !oDmdUnit:CreateD0Q()
				WmsMessage(oDmdUnit:GetErro(),WMSA320D36,1)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Static Function UpdMovSd3(cWmsTMMov,cProduto,cLoteCtl,cNumLote,dDtValid,nQuant,cLocal,cEndereco,cServico,cNumSeq,cDocumento,cEmbarque,cDocSD1,cSerie,cFornec,cLoja)
//------------------------------------------------------------------------------
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local aRotAuto  := {}
Local nI        := 1
Local cErro     := ""
Local cAliasSF5 := ""
Local cAliasSD1 := ""
Local cAliasQry := ""
Local nCusto    := 0
Local lValoriz  := .F.

Default cLoteCtl := Space(TamSx3("D1_LOTECTL")[1])
Default cNumLote := Space(TamSx3("D1_NUMLOTE")[1])

	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private cA240End  := cEndereco
	// Indica que não será DH1 e DCF, apenas uma movimentação na SD3
	Private lExecWms := .T.
	Private lDocWms  := .T.
	cNumSeq       := ProxNum() //Pega o numero sequencial do movimento


	//Verifica custo se o tipo de movimentação for valorizada
	cAliasSF5 := GetNextAlias()
	BeginSql Alias cAliasSF5
		SELECT SF5.F5_VAL
		  FROM %Table:SF5% SF5
		 WHERE SF5.F5_FILIAL = %xFilial:SF5%
	  	   AND SF5.F5_CODIGO = %Exp:cWmsTMMov%
		   AND SF5.F5_VAL    = 'S'
		   AND SF5.%NotDel%
	EndSql
	If (cAliasSF5)->(!EoF())
		lValoriz := .T.
		//Verifica se existe a linha na SD1 para o produto e lote
		cAliasSD1 := GetNextAlias()
		BeginSql Alias cAliasSD1
			SELECT SD1.D1_CUSTO,
			       SD1.D1_QUANT
			FROM %Table:SD1% SD1
			WHERE SD1.D1_FILIAL  = %xFilial:SD1%
			  AND SD1.D1_DOC     = %Exp:cDocSD1%
			  AND SD1.D1_SERIE   = %Exp:cSerie%
			  AND SD1.D1_FORNECE = %Exp:cFornec%
			  AND SD1.D1_LOJA    = %Exp:cLoja%
			  AND SD1.D1_COD     = %Exp:cProduto%
			  AND SD1.D1_LOTECTL = %Exp:cLoteCtl%
			  AND SD1.D1_NUMLOTE = %Exp:cNumLote%
			  AND SD1.%NotDel%
		EndSql
		If (cAliasSD1)->(!EoF())
			nCusto := ((cAliasSD1)->D1_CUSTO / (cAliasSD1)->D1_QUANT) * nQuant
		Else
			//Verifica se existe a linha na SD1 para o produto
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SD1.D1_CUSTO,
				       SD1.D1_QUANT
				FROM %Table:SD1% SD1
				WHERE SD1.D1_FILIAL  = %xFilial:SD1%
				  AND SD1.D1_DOC     = %Exp:cDocSD1%
				  AND SD1.D1_SERIE   = %Exp:cSerie%
				  AND SD1.D1_FORNECE = %Exp:cFornec%
				  AND SD1.D1_LOJA    = %Exp:cLoja%
				  AND SD1.D1_COD     = %Exp:cProduto%
				  AND SD1.%NotDel%
			EndSql
			If (cAliasQry)->(!EoF())
				nCusto := ((cAliasQry)->D1_CUSTO / (cAliasQry)->D1_QUANT) * nQuant
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
		(cAliasSD1)->(DbCloseArea()) 

	EndIf
	(cAliasSF5)->(DbCloseArea())
	
	If lValoriz .And. nCusto == 0
		lRet  := .F.
		cErro := WmsFmtMsg(STR0029,{{"[VAR01]",cWmsTMMov},{"[VAR02]",cProduto}}) //Finalização da conferência não permitida porque o tipo de movimentação [VAR01] é valorizado (F5_VAL = 'S') e o produto [VAR02] não possuí custo informado no documento de entrada. É necessário ajustar o documento de entrada.
		WmsMessage(cErro,WMSA320D41) 
	EndIf

	If lRet
		// Valida se SB2 existe
		WmsAvalSB2(cLocal,cProduto)

		// Itens SD3
		AAdd(aRotAuto,{"D3_TM"     , cWmsTMMov,  Nil})
		AAdd(aRotAuto,{"D3_DOC"    , cDocumento, Nil})
		AAdd(aRotAuto,{"D3_EMISSAO", dDataBase,  Nil})
		AAdd(aRotAuto,{"D3_IDENT"  , cEmbarque,  Nil})
		// Carrega dados movimento interno
		AAdd(aRotAuto, {"D3_NUMSEQ", cNumSeq , Nil})
		AAdd(aRotAuto, {"D3_COD"   , cProduto, Nil})
		If Rastro(cProduto)
			AAdd(aRotAuto, {"D3_LOTECTL", cLoteCtl,Nil})
			AAdd(aRotAuto, {"D3_NUMLOTE", cNumLote,Nil})
			AAdd(aRotAuto, {"D3_DTVALID", dDtValid,Nil})
		EndIf
		AAdd(aRotAuto, {"D3_NUMSERI", ""        ,Nil})
		AAdd(aRotAuto, {"D3_LOCAL"  , cLocal    ,Nil})
		AAdd(aRotAuto, {"D3_LOCALIZ", cEndereco ,Nil})
		AAdd(aRotAuto, {"D3_QUANT"  , nQuant    ,Nil})
		AAdd(aRotAuto, {"D3_UM"     , Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM"),Nil})
		AAdd(aRotAuto, {"D3_SERVIC" , cServico  ,Nil})
		AAdd(aRotAuto, {"D3_STSERV" , "1"       ,Nil})
		AAdd(aRotAuto, {"D3_CUSTO1" , nCusto    ,Nil})
		// Realiza a baixa do SD3 com base no DH1
		MSExecAuto({|x,y| MATA240(x,y)},aRotAuto,3) //Inclusão
		If lMsErroAuto
			aErro := GetAutoGrLog()
			For nI := 1 To Len(aErro)
				cErro += aErro[nI] + CRLF
			Next nI
			If !Empty(cErro)
				WmsMessage(cErro,WMSA320D04,2) //Não foi possível gerar a ordem de serviço.
			Else
				If !IsTelNet()
					WmsMessage(WmsFmtMsg(STR0001,{{"[VAR01]",cProduto},{"[VAR02]",cLocal},{"[VAR03]",cValtoChar(nQuant)},{"[VAR04]",cWmsTMMov}}),WMSA320D05) // "Erro ao gerar movimentação SD3 para produto [VAR01] armazém [VAR02] quantidade [VAR03] TM [VAR04], através de MsExecAuto MATA240"
				Else
					WmsMessage(WmsFmtMsg(STR0001,{{"[VAR01]",cProduto},{"[VAR02]",cLocal},{"[VAR03]",cValtoChar(nQuant)},{"[VAR04]",cWmsTMMov}}),WMSA320D06,,,,STR0002) // "Erro ao gerar movimentação SD3 para produto [VAR01] armazém [VAR02] quantidade [VAR03] TM [VAR04], através de MsExecAuto MATA240"##"Rever saldo do produto, tipo de movimentação (MV_WMSTMFT, MV_WMSTMEX e MV_WMSTMRE)."
				EndIf
			EndIf
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Static Function UpdMovEst(cWmsTMMov,aProdComp,cLoteCtl,cNumLote,nQuant,cLocal,cEndereco,cNumSeq,cDocto,cOrigem)
//------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local nI         := 0
Local cPrdOri    := ""
Local cProdComp  := ""
Local nQtdMult   := 0
Local nQtdAux    := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

	// Gera as movimentações de estoque para as quantidades para cada filho, quando for o caso
	For nI := 1 To Len(aProdComp)
		cProdComp := aProdComp[nI][1]
		nQtdMult  := aProdComp[nI][2]
		cPrdOri   := aProdComp[nI][3]
		nQtdAux   := (nQuant * nQtdMult)
		//------------------------------------------------------//
		//------------ Atualização Saldo Estoque D14 -----------//
		//------------------------------------------------------//
		// Realiza a entrada/saída da quantidade de estoque no armazém/endereço passado
		oEstEnder:ClearData()
		oEstEnder:oEndereco:SetArmazem(cLocal)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oProdLote:SetArmazem(cLocal)
		oEstEnder:oProdLote:SetPrdOri(cPrdOri)
		oEstEnder:oProdLote:SetProduto(cProdComp)
		oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)
		oEstEnder:oProdLote:SetNumLote(cNumLote)

		// Seta o bloco de código para informações do documento
		oEstEnder:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem(cOrigem),;
			oMovEstEnd:SetDocto(cDocto),;
			oMovEstEnd:SetNumSeq(cNumSeq);
		})

		If cWmsTMMov >= "500" // Saída - deve ter saldo no endereço
			If (lRet := oEstEnder:LoadData())
				// Atualização Estoque Endereço D14
				oEstEnder:SetQuant(nQtdAux)
				// Diminui saldo de estoque
				If !(lRet := oEstEnder:UpdSaldo("999",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
					WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cLocal},{"[VAR02]",cEndereco},{"[VAR03]",cProdComp}}),WMSA320D07,1) // "Problema ao subtrair quantidade em estoque no armazém [VAR01] endereço [VAR02] e produto [VAR03]."
					Exit
				EndIf
			Else
				WmsMessage(WmsFmtMsg(STR0005,{{"[VAR01]",cLocal},{"[VAR02]",cEndereco},{"[VAR03]",cProdComp}}),WMSA320D08,1) // "Não foi possível localizar armazém [VAR01] endereço [VAR02] e produto [VAR03]."
				Exit
			EndIf
		Else
			// Atualização Estoque Endereço D14
			oEstEnder:SetQuant(nQtdAux)
			// Diminui saldo de estoque
			If !(lRet := oEstEnder:UpdSaldo("499",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
				WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cLocal},{"[VAR02]",cEndereco},{"[VAR03]",cProdComp}}),WMSA320D09,1) // "Problema ao gerar quantidade em estoque no armazém [VAR01] endereço [VAR02] e produto [VAR03]."
				Exit
			EndIf
		EndIf
	Next nI

	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Static Function UpdMovCQ(cDocto,cSerie,cCliFor,cLoja,cProduto,cLoteCtl,cNumLote,cIdDCF,nQuant)
//------------------------------------------------------------------------------
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""

	cQuery := "SELECT SD7.R_E_C_N_O_ RECNOSD7"
	cQuery +=  " FROM "+RetSqlName('SD1')+" SD1,"
	cQuery +=          +RetSqlName('SD7')+" SD7"
	cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial('SD1')+"'"
	cQuery +=   " AND SD1.D1_DOC     = '"+cDocto+"'"
	cQuery +=   " AND SD1.D1_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND SD1.D1_FORNECE = '"+cCliFor+"'"
	cQuery +=   " AND SD1.D1_LOJA    = '"+cLoja+"'"
	cQuery +=   " AND SD1.D1_COD     = '"+cProduto+"'"
	cQuery +=   " AND SD1.D1_LOTECTL = '"+cLoteCtl+"'"
	cQuery +=   " AND SD1.D1_NUMLOTE = '"+cNumLote+"'"
	cQuery +=   " AND SD1.D1_IDDCF   = '"+cIdDCF+"'"
	cQuery +=   " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SD7.D7_FILIAL  = '"+xFilial('SD7')+"'"
	cQuery +=   " AND SD7.D7_PRODUTO = SD1.D1_COD"
	cQuery +=   " AND SD7.D7_NUMSEQ  = SD1.D1_NUMSEQ"
	cQuery +=   " AND SD7.D7_NUMERO  = SD1.D1_NUMCQ"
	cQuery +=   " AND SD7.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If !(cAliasQry)->(Eof())
		SD7->(DbGoTo((cAliasQry)->RECNOSD7))
		RecLock('SD7')
		SD7->D7_SALDO := (SD7->D7_SALDO - nQuant)
		SD7->D7_SALDO2 := ConvUm(cProduto, SD7->D7_SALDO, 0, 2)
		// Se for uma falta total, deleta o registro
		If SD7->D7_SALDO <= 0
			SD7->(DbDelete())
		EndIf
		SD7->(MsUnlock())
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAnt)
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} MovFalOrd
Faz ajustes necessários quando ocorre falta e o armazém não controla unitizador.
@author  Inovação WMS
@version P12
@since   20/04/2017
/*/
//----------------------------------------------------------
Static Function MovFalOrd(cEmbarque,cIdDCF,nQuant,aProdComp)
Local oOrdServ   := WMSDTCOrdemServico():New()
Local oSaldoADis := WMSDTCSaldoADistribuir():New()
Local oMovimento := WMSDTCMovimentosServicoArmazem():New()
Local oRelacMov  := WMSDTCRelacionamentoMovimentosServicoArmazem():New()
Local nQtdMult   := 0
Local nQtdAux    := 0
Local nQtdDCR    := 0
Local nQtdMov    := 0
Local nI         := 1
Local cPrdOri    := ""
Local cProdComp  := ""
Local cQuery     := ""
Local cAliasQry  := ""
Local cIdMovAnt  := Space(TamSX3("D12_IDMOV")[1])
Local lRet       := .T.
Local aTamSx3    := {}

	//Valida Ordem de Serviço
	oOrdServ:SetIdDCF(cIdDCF)
	If !(lRet := oOrdServ:LoadData())
		WmsMessage(WmsFmtMsg(STR0012,{{"[VAR01]",cIdDCF}}),WMSA320D10,1) // "Não foi encontrada a ordem de serviço de ID [VAR01]."
	EndIf

	// Atualização da quantidade na ordem de serviço
	If lRet
		oOrdServ:SetQuant(oOrdServ:GetQuant()-nQuant)
		If oOrdServ:GetQuant() <= 0
			oOrdServ:SetStServ("0")
		EndIf
		If !(lRet := oOrdServ:UpdateDCF())
			WmsMessage(WmsFmtMsg(STR0007,{{"[VAR01]",cIdDCF}}),WMSA320D11,1) // "Problema ao atualizar ordem de serviço DCF de ID [VAR01]."
		EndIf
	EndIf

	// Carrega o saldo a distribuir para atualização quando existir D0G
	oSaldoADis:SetIdDCF(cIdDCF)
	If oSaldoADis:LoadData(3)
		// Atualização Saldo a distribuir D0G
		If lRet
			If oOrdServ:GetQuant() <= 0
				lRet := oSaldoADis:DeleteD0G()
			Else
				oSaldoADis:SetQtdOri(oOrdServ:GetQuant())
				oSaldoADis:SetQtdSld(oOrdServ:GetQuant())
				lRet := oSaldoADis:UpdateD0G()
			EndIf
			If !lRet
				WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]",cIdDCF}}),WMSA320D12,1) // "Problema ao atualizar o saldo a distribuir D0G da ordem de serviço de ID [VAR01]."
			EndIf
		EndIf
	EndIf

	// Desconta a saida prevista do endereço origem
	If lRet
		lRet := oOrdServ:ReverseMO(nQuant)
	EndIf

	// Procura as movimentações criadas do produto para atualização da nova quantidade
	If lRet
		For nI := 1 To Len(aProdComp)
			cProdComp := aProdComp[nI][1]
			nQtdMult  := aProdComp[nI][2]
			cPrdOri   := aProdComp[nI][3]
			nQtdAux   := (nQuant * nQtdMult)

			cQuery := " SELECT D12.D12_IDMOV,"
			cQuery +=        " D12.R_E_C_N_O_ RECNOD12,"
			cQuery +=        " DCR.R_E_C_N_O_ RECNODCR,"
			// Busca a quantidade que está distribuída para o endereço,
			// para que o ajuste mantenha esta quantidade, pois será utilizado pelo pedido liberado no cross-docking
			cQuery +=        " (SELECT D0F.D0F_QTDDIS"
			cQuery +=           " FROM "+RetSqlName("SD1")+" SD1"
			cQuery +=          " INNER JOIN "+RetSqlName("D0F")+" D0F"
			cQuery +=             " ON D0F.D0F_FILIAL = '"+xFilial("D0F")+"'"
			cQuery +=            " AND D0F.D0F_DOC = SD1.D1_DOC"
			cQuery +=            " AND D0F.D0F_SERIE = SD1.D1_SERIE"
			cQuery +=            " AND D0F.D0F_FORNEC = SD1.D1_FORNECE"
			cQuery +=            " AND D0F.D0F_LOJA = SD1.D1_LOJA"
			cQuery +=            " AND D0F.D0F_ITEM = SD1.D1_ITEM"
			cQuery +=            " AND D0F.D_E_L_E_T_ = ' '"
			cQuery +=          " INNER JOIN "+RetSqlName("D06")+" D06"
			cQuery +=             " ON D06.D06_FILIAL = '"+xFilial("D06")+"'"
			cQuery +=            " AND D06.D06_CODDIS = D0F.D0F_CODDIS"
			cQuery +=            " AND D06.D06_SITDIS = '2'"
			cQuery +=            " AND D06.D_E_L_E_T_ = ' '"
			cQuery +=          " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
			cQuery +=            " AND SD1.D1_IDDCF = DCF.DCF_ID"
			cQuery +=            " AND D0F.D0F_ENDER = D12.D12_ENDDES"
			cQuery +=            " AND SD1.D_E_L_E_T_ = ' ') D0F_QTDDIS,"
			// Utilizado para realizar a ordenação para considerar as distribuições com endereço específico
			cQuery +=        " CASE WHEN D10.D10_ENDER IS NULL THEN 2 ELSE 1 END D12_ORDEM"
			cQuery +=   " FROM "+RetSqlName("DCF")+" DCF"
			cQuery +=  " INNER JOIN "+RetSqlName("DCR")+" DCR"
			cQuery +=     " ON DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
			cQuery +=    " AND DCR.DCR_IDDCF = DCF.DCF_ID"
			cQuery +=    " AND DCR.DCR_SEQUEN = DCF.DCF_SEQUEN"
			cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
			cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
			cQuery +=     " ON D12.D12_IDDCF = DCR.DCR_IDORI"
			cQuery +=    " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
			cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
			cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
			cQuery +=   " LEFT JOIN "+RetSqlName("D10")+" D10"
			cQuery +=     " ON D10.D10_FILIAL = '"+xFilial("D10")+"'"
			cQuery +=    " AND D10.D10_LOCAL = D12.D12_LOCDES"
			cQuery +=    " AND D10.D10_ENDER = D12.D12_ENDDES"
			cQuery +=    " AND D10.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
			cQuery +=    " AND DCF.DCF_ID = '"+cIdDCF+"'"
			cQuery +=    " AND DCF.DCF_CODREC = '"+cEmbarque+"'"
			cQuery +=    " AND D12.D12_PRDORI = '"+cPrdOri+"'"
			cQuery +=    " AND D12.D12_PRODUT = '"+cProdComp+"'"
			cQuery +=    " AND D12.D12_STATUS IN ('2','3','4')"
			cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
			cQuery +=  " ORDER BY D12_ORDEM,"
			cQuery +=        " D12.D12_IDMOV" // Importante para sequenciar por movimento
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			aTamSx3 := TamSx3("D0F_QTDDIS")
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			TcSetField( cAliasQry,'D0F_QTDDIS','N',aTamSx3[1],aTamSx3[2])
			// Subtrai quantidade cortada do DCR
			Do While (cAliasQry)->(!Eof()) .And. QtdComp(nQtdAux) > QtdComp(0)
				If oMovimento:GoToD12((cAliasQry)->RECNOD12) .And. oRelacMov:GoToDCR((cAliasQry)->RECNODCR)
					// Volta quantidade para ratear para a segunda atividade também
					If cIdMovAnt != (cAliasQry)->D12_IDMOV
						nQtdDCR := oRelacMov:GetQuant() - ((cAliasQry)->D0F_QTDDIS * nQtdMult)
						If QtdComp(nQtdDCR) == QtdComp(0)
							(cAliasQry)->(dbSkip())
							Loop
						EndIf
						// Rateio da quantidade conferida
						If QtdComp(nQtdAux) > QtdComp(nQtdDCR)
							nQtdMov := nQtdDCR
						Else
							nQtdMov := nQtdAux
						EndIf

						cIdMovAnt := (cAliasQry)->D12_IDMOV
					EndIf
					// Apenas desfaz a movimentação no movimento que atualiza estoque
					If oMovimento:IsUpdEst()
						// Realiza os estorno da quantidade entrada prevista
						oMovimento:oEstEnder:ClearData()
						oMovimento:oEstEnder:oEndereco:SetArmazem(oMovimento:oMovEndDes:GetArmazem())
						oMovimento:oEstEnder:oEndereco:SetEnder(oMovimento:oMovEndDes:GetEnder())
						oMovimento:oEstEnder:oProdLote:SetArmazem(oMovimento:oMovPrdLot:GetArmazem())
						oMovimento:oEstEnder:oProdLote:SetPrdOri(oMovimento:oMovPrdLot:GetPrdOri())
						oMovimento:oEstEnder:oProdLote:SetProduto(oMovimento:oMovPrdLot:GetProduto())
						oMovimento:oEstEnder:oProdLote:SetLoteCtl(oMovimento:oMovPrdLot:GetLoteCtl())
						oMovimento:oEstEnder:oProdLote:SetNumLote(oMovimento:oMovPrdLot:GetNumLote())
						oMovimento:oEstEnder:oProdLote:SetNumSer(oMovimento:oMovPrdLot:GetNumSer())
						If (lRet := oMovimento:oEstEnder:LoadData())
							// Atualização Estoque Endereço D14
							oMovimento:oEstEnder:SetQuant(nQtdMov)
							// Diminui entrada prevista
							If !(lRet := oMovimento:oEstEnder:UpdSaldo("999",.F. /*lEstoque*/,.T. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/))
								WmsMessage(WmsFmtMsg(STR0009,{{"[VAR01]",oMovimento:oMovEndDes:GetArmazem()},{"[VAR02]",oMovimento:oMovEndDes:GetEnder()},{"[VAR03]",oMovimento:oMovPrdLot:GetProduto()}}),WMSA320D13,1) // "Problema ao subtrair entrada prevista do armazém [VAR01] endereço [VAR02] e produto [VAR03]."
								Exit
							EndIf
						Else
							WmsMessage(WmsFmtMsg(STR0005,{{"[VAR01]",oMovimento:oMovEndDes:GetArmazem()},{"[VAR02]",oMovimento:oMovEndDes:GetEnder()},{"[VAR03]",oMovimento:oMovPrdLot:GetProduto()}}),WMSA320D14,1) // "Não foi possível localizar armazém [VAR01] endereço [VAR02] e produto [VAR03]."
							Exit
						EndIf
					EndIf
					//--------------------------------------------//
					//--- Atualização dos movimentos D12 e DCR ---//
					//--------------------------------------------//
					If QtdComp(oMovimento:GetQtdMov() - nQtdMov) == QtdComp(0)
						oMovimento:SetStatus("0")
						lRet := oMovimento:UpdateD12()
					Else
						// Desconta da quantidade lida, caso exista priorizando descontar do não lido
						// Mov -> 100 , Lid -> 80 , Canc -> 30 -> Qtd Lida = 70
						// Mov -> 100 , Lid -> 80 , Canc -> 80 -> Qtd Lida = 20
						// Mov -> 100 , Lid -> 80 , Canc -> 100 -> Qtd Lida = 0
						If QtdComp(oMovimento:GetQtdLid()) > 0  .And.;
							QtdComp(oMovimento:GetQtdMov() - oMovimento:GetQtdLid()) < QtdComp(nQtdMov)
							// 80-(80-(100-30)) -> 80-(80-(70)) -> 80-(10) -> 70
							// 80-(80-(100-80)) -> 80-(80-(20)) -> 80-(60) -> 20
							// 80-(80-(100-100)) -> 80-(80-(0)) -> 80-(80) -> 0
							oMovimento:SetQtdLid(oMovimento:GetQtdLid() - (oMovimento:GetQtdLid()-(oMovimento:GetQtdMov()-nQtdMov)))
						EndIf
						oMovimento:SetQtdMov(oMovimento:GetQtdMov() - nQtdMov)
						If (lRet := oMovimento:UpdateD12())
							If QtdComp(oRelacMov:GetQuant() - nQtdMov) == QtdComp(0)
								lRet := oRelacMov:DeleteDCR()
							Else
								oRelacMov:SetQuant(nQtdDCR - nQtdMov)
								oRelacMov:SetQuant2(ConvUm(oMovimento:oMovPrdLot:GetProduto(),nQtdDCR,0,2))
								lRet := oRelacMov:UpdateDCR()
							EndIf
						EndIf
					EndIf
					If !lRet
						WmsMessage(WmsFmtMsg(STR0010,{{"[VAR01]",oMovimento:oMovEndDes:GetArmazem()},{"[VAR02]",oMovimento:oMovEndDes:GetEnder()},{"[VAR03]",oMovimento:oMovPrdLot:GetProduto()}}),WMSA320D15,1) // "Problema na atualização dos movimentos D12 de armazém [VAR01] endereço [VAR02] e produto [VAR03]."
						Exit
					EndIf
					If oMovimento:IsUltAtiv()
						nQtdAux -= nQtdMov
					EndIf
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			If !lRet
				Exit
			EndIf
		Next nI
	EndIf
Return lRet
//----------------------------------------------------------
/*{Protheus.doc} MovFalUni
Faz ajustes necessários quando ocorre falta e o armazém controla unitizador.
@author  Amanda Rosa Vieira
@version P12
@since   20/04/2017
*/
//----------------------------------------------------------
Static Function MovFalUni(nQuant,aProduto,cProduto,cLocal,cDocto,cSerie,cCliFor,cLoja,cNumSeq,cEnder,cLoteCtl,cNumLote)
Local lRet       := .T.
Local nProduto   := 1
Local oSaldoADis := WMSDTCSaldoADistribuir():New()
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

	// Carrega o saldo a distribuir para atualização
	oSaldoADis:oProdLote:SetProduto(cProduto)
	oSaldoADis:oProdLote:SetArmazem(cLocal)
	oSaldoADis:SetDocto(cDocto)
	oSaldoADis:SetSerie(cSerie)
	oSaldoADis:SetCliFor(cCliFor)
	oSaldoADis:SetLoja(cLoja)
	oSaldoADis:SetNumSeq(cNumSeq)
	// Atualização Saldo a distribuir D0G quando existir
	If oSaldoADis:LoadData(1)
		oSaldoADis:SetQtdOri(oSaldoADis:GetSaldo() - nQuant)
		oSaldoADis:SetQtdSld(oSaldoADis:GetSaldo() - nQuant)
		If oSaldoADis:GetSaldo() <= 0
			lRet := oSaldoADis:DeleteD0G()
		Else
			lRet := oSaldoADis:UpdateD0G()
		EndIf
		If !lRet
			WmsMessage(WmsFmtMsg(STR0011,{{"[VAR01]",oSaldoADis:GetDocto()},{"[VAR02]",oSaldoADis:GetSerie()}}),WMSA320D16,1) // "Problema ao atualizar o saldo a distribuir D0G do documento/série [VAR01]/[VAR02]."
		EndIf
	EndIf
	// Desconta a saida prevista do endereço origem
	If lRet
		// Atualiza Saldo
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				// Carrega dados para Estoque por Endereço
				oEstEnder:oEndereco:SetArmazem(cLocal)
				oEstEnder:oEndereco:SetEnder(cEnder)
				oEstEnder:oProdLote:SetArmazem(cLocal) // Armazem
				oEstEnder:oProdLote:SetPrdOri(cProduto)   // Produto Origem
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])       // Componente
				oEstEnder:oProdLote:SetLoteCtl(cLoteCtl) // Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:oProdLote:SetNumLote(cNumLote) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
				oEstEnder:LoadData()
				oEstEnder:SetQuant(QtdComp(nQuant * aProduto[nProduto][2]) )
				// Realiza Entrada Armazem Estoque por Endereço
				oEstEnder:UpdSaldo('999',.F. /*lEstoque*/,.F. /*lEntPrev*/,.T./*lSaiPrev*/,.F./*lEmpenho*/,.F. /*lBloqueio*/,.F.)
			Next
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} EstMovCof
Avalia a ordem de serviço para estornar as alterações realizadas
na finalização de conferência com divergência

@author  Guilherme A. Metzger
@version P11
@since   24/08/2015
/*/
//----------------------------------------------------------
Static Function EstMovCof(cEmbarque,aRecDCF)
Local aAreaAnt := GetArea()
Local lRet     := .T.

	// **************************************** IMPORTANTE ****************************************//
	// Se for trocada a ordem das chamadas das funções podem ter situações que não funcionem       //
	// Pois existem informações dependentes nas atualizações que em certos momentos são excluídas  //
	// **************************************** IMPORTANTE ****************************************//

	//Estorna movimentações falta
	lRet := EstMovFalt(cEmbarque)
	
	//Estorna conferência unitizada
	If lRet
		If WmsX212118("D0R")
			lRet := EstCofUnit(cEmbarque)
		EndIf
	EndIf

	//Estorna conferência para itens não unitizados
	If lRet
		lRet := EstCofEnd(cEmbarque,aRecDCF)
	EndIf

	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} EstCofUnit
Estorna conferência unitizada.
@author  Amanda Rosa Vieira
@version P12
@since   08/05/2017
/*/
//----------------------------------------------------------
Static Function EstCofUnit(cEmbarque)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local lHasUnitiz := .F.

	// Apaga ordem de serviço e desassocia DCF e D0R
	cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF,"
	cQuery +=       " D0R.R_E_C_N_O_ RECNOD0R"
	cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
	cQuery += " INNER JOIN "+RetSqlName('D0R')+" D0R"
	cQuery +=    " ON D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
	cQuery +=   " AND D0R.D0R_IDUNIT = DCF.DCF_UNITIZ"
	cQuery +=   " AND D0R.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF.DCF_CODREC = '"+cEmbarque+"'"
	cQuery +=   " AND DCF.DCF_ORIGEM = 'D0R'"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry  := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While lRet .And. (cAliasQry)->(!Eof())
		//Apaga IDDCF da D0R
		D0R->(DbGoTo((cAliasQry)->RECNOD0R))
		RecLock('D0R', .F.)
		D0R->D0R_SERVIC := ""
		D0R->D0R_IDDCF  := ""
		D0R->(MsUnlock())
		//Apaga ordem de serviço
		DCF->(DbGoTo((cAliasQry)->RECNODCF))
		RecLock('DCF', .F.)
		DCF->(DbDelete())
		DCF->(MsUnlock())
		(cAliasQry)->(DbSkip())
		lHasUnitiz := .T.
	EndDo
	(cAliasQry)->(DbCloseArea())
	// Se não encontrou nenhum unitizador, não há o que estornar
	If !lHasUnitiz
		Return lRet
	EndIf
	
	// Estorna quebra da D14 por unitizador
	If lRet
		lRet := Wm320UnD14(cEmbarque,.T.)
	EndIf
	// Apaga demanda de unitização e desassocia D0Q e D0S
	If lRet
		lRet := DelDmdUni(cEmbarque)
	EndIf
	// Estorna as movimentações de excesso geradas para armazéns unitizados
	If lRet
		lRet := EstMovExec(cEmbarque)
	EndIf

Return lRet

//----------------------------------------------------------
Static Function EstCofEnd(cEmbarque,aRecDCF)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local cAliasSD3  := ""
Local oOrdSerRev := Nil
Local nStatus    := Nil
Local aCodDis    := {}
Local oModelD06  := Nil
Local nI         := 0
Local nX         := 0
	cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND DCF.DCF_CODREC = '"+cEmbarque+"'"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry  := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While lRet .And. (cAliasQry)->(!Eof())
		If oOrdSerRev == Nil
			oOrdSerRev := WMSDTCOrdemServicoReverse():New()
		EndIf
		// Posiciona na ordem de serviço
		oOrdSerRev:GoToDCF((cAliasQry)->RECNODCF)
		nStatus := oOrdSerRev:GetStServ()
		// Se for registro de falta
		If oOrdSerRev:GetOrigem() == "SD1"
			If QtdComp(oOrdSerRev:GetQuant()) < QtdComp(oOrdSerRev:GetQtdOri())
				//----------------------------------------------------//
				//------------- Ajusta DCF, D12 e DCR ----------------//
				//----------------------------------------------------//
				// Caso a ordem de serviço esteja executada
				If nStatus == "3"
					// Avalia se o estorno automático pode ser realizado
					If oOrdSerRev:CanReverse()
						If !(lRet := oOrdSerRev:ReverseDCF())
							WmsMessage(oOrdSerRev:GetErro(),WMSA320D17,1)
						EndIf
					Else
						WmsMessage(oOrdSerRev:GetErro(),WMSA320D18,1)
						lRet := .F.
					EndIf
				EndIf
				If lRet
					// Retorna a OS para quantidade e status original
					oOrdSerRev:SetQuant(oOrdSerRev:GetQtdOri())
					oOrdSerRev:SetStServ("1")
					oOrdSerRev:UpdateDCF()
					// Se a ordem de serviço estava executada ou se ela foi cancelada e possuia execução automática
					If lRet .And. nStatus == "3" .Or. (nStatus == "0" .And. oOrdSerRev:oServico:GetTpExec() == '2')
						// Adiciona as DCF que precisam ser executadas depois
						aAdd(aRecDCF,oOrdSerRev:GetRecno())
					EndIf
				EndIf
				If lRet
					SD1->(dbSetOrder(4))
					// Verifica se o item da conferência está em uma distribuição de produtos
					If SD1->(dbSeek(xFilial("SD1")+oOrdSerRev:GetNumSeq())) .And. !Empty(SD1->D1_CODDIS)
						If aScan(aCodDis , SD1->D1_CODDIS) == 0
							// Adiciona no array para desfazer o ajuste de falta na distribuição de produtos
							aAdd(aCodDis,SD1->D1_CODDIS)
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf oOrdSerRev:GetOrigem() == "SD3"
			// Caso a ordem de serviço esteja executada
			If nStatus == "3"
				// Avalia se o estorno automático pode ser realizado
				If oOrdSerRev:CanReverse()
					If !(lRet := oOrdSerRev:ReverseDCF())
						WmsMessage(oOrdSerRev:GetErro(),WMSA320D22,1)
					EndIf
				Else
					WmsMessage(oOrdSerRev:GetErro(),WMSA320D23,1)
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If !(lRet := oOrdSerRev:UndoIntegr())
					WmsMessage(oOrdSerRev:GetErro(),WMSA320D24,1)
				EndIf
				If lRet
					If !(lRet := oOrdSerRev:ExcludeDCF())
						WmsMessage(oOrdSerRev:GetErro(),WMSA320D25,1)
					EndIf
				EndIf
			EndIf
			// Deve excluir a movimentação de excesso da SD3 gerada para esta OS
			If lRet
				cQuery := "SELECT SD3.R_E_C_N_O_ RECNOSD3"
				cQuery +=  " FROM "+RetSqlName("SD3")+" SD3"
				cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"
				cQuery +=   " AND SD3.D3_DOC     = '"+oOrdSerRev:GetDocto()+"'"
				cQuery +=   " AND SD3.D3_NUMSEQ  = '"+oOrdSerRev:GetNumSeq()+"'"
				cQuery +=   " AND SD3.D3_IDENT   = '"+cEmbarque+"'"
				cQuery +=   " AND SD3.D3_ESTORNO = ' '"
				cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasSD3 := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
				If (cAliasSD3)->(!Eof())
					lRet := EstornaSD3((cAliasSD3)->RECNOSD3)
				EndIf
				(cAliasSD3)->(DbCloseArea())
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If lRet .And. Len(aCodDis) > 0
		DbSelectArea("D06")
		// Volta as quantidades da distribuição de produtos caso tenha algum documento conferido com divergencia
		For nI := 1 To Len(aCodDis)

			// Posiciona no registro para carregar o modelo de dados
			D06->(dbSetOrder(1))
			D06->(dbSeek(xFilial("D06")+aCodDis[nI]))
			oModelD06 := FWLoadModel("WMSA325A")
			oModelD06:SetOperation( MODEL_OPERATION_UPDATE )
			oModelD06:Activate()

			For nX := 1 To oModelD06:GetModel("D07GRID"):Length()
				oModelD06:GetModel("D07GRID"):GoLine(nX)

				// Retorna a quantidade original da distribuição
				oModelD06:GetModel("D07GRID"):LoadValue("D07_QTDENT",oModelD06:GetModel("D07GRID"):GetValue("D07_QTORIE"))
				oModelD06:GetModel("D07GRID"):LoadValue("D07_QTDDIS",oModelD06:GetModel("D07GRID"):GetValue("D07_QTORID"))

				oModelD06:GetModel("D07GRID"):LoadValue("D07_QTDEN2", ConvUm(oModelD06:GetModel("D07GRID"):GetValue("D07_PRODUT"),oModelD06:GetModel("D07GRID"):GetValue("D07_QTORIE"),0,2) )
				oModelD06:GetModel("D07GRID"):LoadValue("D07_QTDDI2", ConvUm(oModelD06:GetModel("D07GRID"):GetValue("D07_PRODUT"),oModelD06:GetModel("D07GRID"):GetValue("D07_QTORID"),0,2) )
			Next nX

			For nX := 1 To oModelD06:GetModel("D08GRID"):Length()
				oModelD06:GetModel("D08GRID"):GoLine(nX)

				// Retorna a quantidade original da distribuição
				oModelD06:GetModel("D08GRID"):LoadValue("D08_QTDDIS",oModelD06:GetModel("D08GRID"):GetValue("D08_QTORID"))
				oModelD06:GetModel("D08GRID"):LoadValue("D08_QTDDI2", ConvUm(oModelD06:GetModel("D08GRID"):GetValue("D08_PRODUT"),oModelD06:GetModel("D08GRID"):GetValue("D08_QTORID"),0,2) )
			Next nX

			// Ajusta as quantidades da D09
			WMS325RD09(oModelD06)
			// Validação do modelo de dados
			// Monta os dados da D0F no valid
			If oModelD06:VldData()
				// Efetivação dos dados
				oModelD06:CommitData()
			Else
				// Erro do modelo de dados
				WmsMessage(oModelD06:GetErrorMessage()[6],WMSA320D26,1)
				lRet := .F.
				Exit
			EndIf
			oModelD06:DeActivate()
		Next nI
	EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} EstMovFalt
Estorna movimentações de estoque de falta.
@author  Amanda Rosa Vieira
@version P12
@since   08/05/2017
/*/
//----------------------------------------------------------
Static Function EstMovFalt(cEmbarque)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local oEstEnder  := Nil
Local aMovtoSD3  := {}
Local nI         := 0
Local aTamSx3    := TamSX3("D13_QTDEST")

	// Apaga as movimentações de kardex da conferência de falta
	cQuery := "SELECT D13.D13_ORIGEM,"
	cQuery +=       " D13.D13_LOCAL,"
	cQuery +=       " D13.D13_ENDER,"
	cQuery +=       " D13.D13_PRODUT,"
	cQuery +=       " D13.D13_PRDORI,"
	cQuery +=       " D13.D13_LOTECT,"
	cQuery +=       " D13.D13_NUMLOT,"
	cQuery +=       " D13.D13_NUMSER,"
	cQuery +=       " D13.D13_QTDEST,"
	cQuery +=       " D13.D13_TM,"
	cQuery +=       " D13.D13_DOC,"
	cQuery +=       " D13.D13_SERIE,"
	cQuery +=       " D13.D13_CLIFOR,"
	cQuery +=       " D13.D13_LOJA,"
	cQuery +=       " D13.D13_NUMSEQ,"
	cQuery +=       " D13.R_E_C_N_O_ RECNOD13,"
	cQuery +=       " SD3.R_E_C_N_O_ RECNOSD3"
	cQuery +=  " FROM "+RetSqlName("SD3")+" SD3"
	cQuery += " INNER JOIN "+RetSqlName("D13")+" D13"
	cQuery +=    " ON D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=   " AND D13.D13_LOCAL  = SD3.D3_LOCAL"
	cQuery +=   " AND D13.D13_PRDORI = SD3.D3_COD"
	cQuery +=   " AND D13.D13_LOTECT = SD3.D3_LOTECTL"
	cQuery +=   " AND D13.D13_NUMLOT = SD3.D3_NUMLOTE"
	cQuery +=   " AND D13.D13_NUMSER = SD3.D3_NUMSERI"
	cQuery +=   " AND D13.D13_DOC    = SD3.D3_DOC"
	cQuery +=   " AND D13.D13_NUMSEQ = SD3.D3_NUMSEQ"
	cQuery +=   " AND D13.D13_ORIGEM = 'DCW'"
	cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"'"
	cQuery +=   " AND SD3.D3_IDENT = '"+cEmbarque+"'"
	cQuery +=   " AND Substring(SD3.D3_DOC,1,3) = 'CFT'" // Para garantir que é uma movimentação de falta de conferência
	cQuery +=   " AND SD3.D3_ESTORNO = ' '"
	cQuery +=   " AND SD3.D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY D13.R_E_C_N_O_ DESC"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'D13_QTDEST','N',aTamSx3[1],aTamSx3[2])
	If (cAliasQry)->(!Eof())
		oEstEnder := WMSDTCEstoqueEndereco():New()
	EndIf
	Do While lRet .And. (cAliasQry)->(!Eof())
		// Com base nos movimentos do kardex, volta o saldo do estoque por endereço D14 retirando o saldo do armazém de falta
		// Seta as propriedades do endereço D14
		oEstEnder:oEndereco:SetArmazem((cAliasQry)->D13_LOCAL)
		oEstEnder:oEndereco:SetEnder((cAliasQry)->D13_ENDER)
		// Seta as propriedades do produto
		oEstEnder:oProdLote:SetArmazem((cAliasQry)->D13_LOCAL)
		oEstEnder:oProdLote:SetProduto((cAliasQry)->D13_PRODUT)
		oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D13_PRDORI)
		oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D13_LOTECT)
		oEstEnder:oProdLote:SetNumLote((cAliasQry)->D13_NUMLOT)
		oEstEnder:oProdLote:SetNumSer((cAliasQry)->D13_NUMSER)
		oEstEnder:SetQuant((cAliasQry)->D13_QTDEST)

		// Seta o bloco de código para informações do documento
		oEstEnder:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem((cAliasQry)->D13_ORIGEM),;
			oMovEstEnd:SetDocto((cAliasQry)->D13_DOC),;
			oMovEstEnd:SetSerie((cAliasQry)->D13_SERIE),;
			oMovEstEnd:SetCliFor((cAliasQry)->D13_CLIFOR),;
			oMovEstEnd:SetLoja((cAliasQry)->D13_LOJA),;
			oMovEstEnd:SetNumSeq((cAliasQry)->D13_NUMSEQ),;
			oMovEstEnd:SetIdDCF("");
		})

		oEstEnder:SetBlkMov({|oMovEstEnd| oMovEstEnd:SetlUsaCal(.F.)})

		If (cAliasQry)->D13_TM=="999"
			// Atualização da D14
			If !(lRet := oEstEnder:UpdSaldo("499",.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
				WmsMessage(oEstEnder:GetErro(),WMSA320D27,1)
				Exit
			EndIf
		ElseIf (cAliasQry)->D13_TM=="499"
			// Atualização da D14
			If !(lRet := oEstEnder:UpdSaldo("999",.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
				WmsMessage(oEstEnder:GetErro(),WMSA320D28,1)
				Exit
			EndIf
		EndIf

		If lRet .And. WmsX312118("D13","D13_USACAL")
			D13->(dbGoTo((cAliasQry)->RECNOD13))
			RecLock("D13",.F.)
			D13->D13_USACAL = '2'
			D13->(MsUnLock())
		EndIf

		If aScan(aMovtoSD3, (cAliasQry)->RECNOSD3) == 0
			AAdd(aMovtoSD3,(cAliasQry)->RECNOSD3)
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	// Estorna as movimentações da SD3
	For nI := 1 To Len(aMovtoSD3)
		If !(lRet := EstornaSD3(aMovtoSD3[nI]))
			Exit
		EndIf
	Next

	// Ajusta os saldos a endereçar das quantidades faltantes, voltando para o original
	If lRet .And. SuperGetMV("MV_WMSBLQE",.F.,.F.)
		lRet := RefSldEnd(cEmbarque)
	EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} EstMovExec
Estorna movimentações de estoque de excesso.
@author  Jackson Patrick Werka
@version P12
@since   10/08/2017
/*/
//----------------------------------------------------------
Static Function EstMovExec(cEmbarque)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local oEstEnder  := Nil
Local aMovtoSD3  := {}
Local nI         := 0
Local aTamSx3    := TamSX3("D13_QTDEST")

	// Apaga as movimentações de kardex da conferência de falta
	cQuery := "SELECT D13.D13_ORIGEM,"
	cQuery +=       " D13.D13_LOCAL,"
	cQuery +=       " D13.D13_ENDER,"
	cQuery +=       " D13.D13_PRODUT,"
	cQuery +=       " D13.D13_PRDORI,"
	cQuery +=       " D13.D13_LOTECT,"
	cQuery +=       " D13.D13_NUMLOT,"
	cQuery +=       " D13.D13_NUMSER,"
	cQuery +=       " D13.D13_QTDEST,"
	cQuery +=       " D13.D13_TM,"
	cQuery +=       " D13.D13_DOC,"
	cQuery +=       " D13.D13_SERIE,"
	cQuery +=       " D13.D13_CLIFOR,"
	cQuery +=       " D13.D13_LOJA,"
	cQuery +=       " D13.D13_NUMSEQ,"
	cQuery +=       " D13.R_E_C_N_O_ RECNOD13,"
	cQuery +=       " SD3.R_E_C_N_O_ RECNOSD3"
	cQuery +=  " FROM "+RetSqlName("SD3")+" SD3"
	cQuery += " INNER JOIN "+RetSqlName("D13")+" D13"
	cQuery +=    " ON D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=   " AND D13.D13_LOCAL  = SD3.D3_LOCAL"
	cQuery +=   " AND D13.D13_PRDORI = SD3.D3_COD"
	cQuery +=   " AND D13.D13_LOTECT = SD3.D3_LOTECTL"
	cQuery +=   " AND D13.D13_NUMLOT = SD3.D3_NUMLOTE"
	cQuery +=   " AND D13.D13_NUMSER = SD3.D3_NUMSERI"
	cQuery +=   " AND D13.D13_DOC    = SD3.D3_DOC"
	cQuery +=   " AND D13.D13_NUMSEQ = SD3.D3_NUMSEQ"
	cQuery +=   " AND D13.D13_ORIGEM = 'SD3'"
	cQuery +=   " AND D13.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName('NNR')+" NNR"
	cQuery +=     " ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"'"
	cQuery +=    " AND NNR.NNR_CODIGO = D13.D13_LOCAL"
	cQuery +=    " AND NNR.NNR_AMZUNI = '1'"
	cQuery +=    " AND NNR.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"'"
	cQuery +=   " AND SD3.D3_IDENT = '"+cEmbarque+"'"
	cQuery +=   " AND Substring(SD3.D3_DOC,1,3) = 'CEX'" // Para garantir que é uma movimentação de excesso de conferência
	cQuery +=   " AND SD3.D3_ESTORNO = ' '"
	cQuery +=   " AND SD3.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'D13_QTDEST','N',aTamSx3[1],aTamSx3[2])
	If (cAliasQry)->(!Eof())
		oEstEnder := WMSDTCEstoqueEndereco():New()
	EndIf
	Do While lRet .And. (cAliasQry)->(!Eof())
		// Com base nos movimentos do kardex, volta o saldo do estoque por endereço D14 retirando o saldo do armazém de falta
		// Seta as propriedades do endereço D14
		oEstEnder:oEndereco:SetArmazem((cAliasQry)->D13_LOCAL)
		oEstEnder:oEndereco:SetEnder((cAliasQry)->D13_ENDER)
		// Seta as propriedades do produto
		oEstEnder:oProdLote:SetArmazem((cAliasQry)->D13_LOCAL)
		oEstEnder:oProdLote:SetProduto((cAliasQry)->D13_PRODUT)
		oEstEnder:oProdLote:SetPrdOri((cAliasQry)->D13_PRDORI)
		oEstEnder:oProdLote:SetLoteCtl((cAliasQry)->D13_LOTECT)
		oEstEnder:oProdLote:SetNumLote((cAliasQry)->D13_NUMLOT)
		oEstEnder:oProdLote:SetNumSer((cAliasQry)->D13_NUMSER)
		oEstEnder:SetQuant((cAliasQry)->D13_QTDEST)

		// Seta o bloco de código para informações do documento
		oEstEnder:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem((cAliasQry)->D13_ORIGEM),;
			oMovEstEnd:SetDocto((cAliasQry)->D13_DOC),;
			oMovEstEnd:SetSerie((cAliasQry)->D13_SERIE),;
			oMovEstEnd:SetCliFor((cAliasQry)->D13_CLIFOR),;
			oMovEstEnd:SetLoja((cAliasQry)->D13_LOJA),;
			oMovEstEnd:SetNumSeq((cAliasQry)->D13_NUMSEQ),;
			oMovEstEnd:SetIdDCF("");
		})

		oEstEnder:SetBlkMov({|oMovEstEnd| oMovEstEnd:SetlUsaCal(.F.)})

		If !(lRet := oEstEnder:UpdSaldo("999",.T. /*lEstoque*/,.F. /*lEntPrev*/,.T. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
			WmsMessage(oEstEnder:GetErro(),WMSA320D29,1)
			Exit
		EndIf

		If lRet .And. WmsX312118("D13","D13_USACAL")
			D13->(dbGoTo((cAliasQry)->RECNOD13))
			RecLock("D13",.F.)
			D13->D13_USACAL = '2'
			D13->(MsUnLock())
		EndIf

		If aScan(aMovtoSD3, (cAliasQry)->RECNOSD3) == 0
			AAdd(aMovtoSD3,(cAliasQry)->RECNOSD3)
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	// Estorna as movimentações da SD3
	For nI := 1 To Len(aMovtoSD3)
		If !(lRet := EstornaSD3(aMovtoSD3[nI]))
			Exit
		EndIf
	Next

Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} EstornaSD3
Realiza estorno da SD3 de movimentações de falta
@author  Amanda Rosa Vieira
@version P12
@since   08/05/2017
/*/
//----------------------------------------------------------
Static Function EstornaSD3(nRecnoSD3)
Local lRet       := .T.
Local aRotAuto   := {}
Local nI         := 1

	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.
	// Indica que não será DH1 e DCF, apenas uma movimentação na SD3
	Private lExecWms := .T.

	DbSelectArea("SD3")
	SD3->(dbGoto(nRecnoSD3))
	// Itens SD3
	AAdd(aRotAuto,{"D3_DOC"    , SD3->D3_DOC, Nil})
	AAdd(aRotAuto,{"D3_NUMSEQ" , SD3->D3_NUMSEQ, Nil})
	AAdd(aRotAuto,{"INDEX",8, Nil})

	// Se for uma entrada de falta da conferência, não tem saldo a endereçar,
	// desta forma deve 'setar' esta variável para ser usada na classe SaldoADistribuir
	If SD3->D3_TM <= "500"
		Private lSldEndCof := .T.
		Wm320SdDis(SD3->D3_QUANT)
	EndIf

	MsExecAuto({|x,y| MATA240(x,y)},aRotAuto,5)
	If lMsErroAuto
		// Anula as variáveis para mostrar a tela de Help
		lMsHelpAuto := Nil
		lMsErroAuto := Nil
		If IsTelNet()
			// Erro na criação da SD3
			aErro := GetAutoGrLog()
			For nI := 1 To Len(aErro)
				cErro += aErro[nI] + CRLF
			Next nI
			If !Empty(cErro)
				WmsMessage(cErro,WMSA320D30,1) //Não foi possível realizar o estorno.
			Else
				WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",SD3->D3_COD},{"[VAR02]",SD3->D3_LOCAL},{"[VAR03]",cValtoChar(SD3->D3_QUANT)},{"[VAR04]",SD3->D3_TM}}),WMSA320D31,1) // "Erro ao estornar movimentação SD3 para produto [VAR01] armazém [VAR02] quantidade [VAR03] TM [VAR04], através de MsExecAuto MATA240"
			EndIf
		Else
			WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",SD3->D3_COD},{"[VAR02]",SD3->D3_LOCAL},{"[VAR03]",cValtoChar(SD3->D3_QUANT)},{"[VAR04]",SD3->D3_TM}}),WMSA320D32,,,,STR0002) // "Erro ao gerar movimentação SD3 para produto [VAR01] armazém [VAR02] quantidade [VAR03] TM [VAR04], através de MsExecAuto MATA240"##"Rever saldo do produto, tipo de movimentação (MV_WMSTMFT, MV_WMSTMEX e MV_WMSTMRE)."
		EndIf
		lRet := .F.
	EndIf

Return lRet

//---------------------------------------------------------------
// Refaz o saldo a endereçar que foi descontado pelas faltas
//---------------------------------------------------------------
Static Function RefSldEnd(cEmbarque)
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := ""
Local oSaldoADis := Nil
Local aTamSx3    := TamSX3("D0K_QUANT")

	cQuery := "SELECT D0K.D0K_DOC,"
	cQuery +=       " D0K.D0K_SERIE,"
	cQuery +=       " D0K.D0K_FORNEC,"
	cQuery +=       " D0K.D0K_LOJA,"
	cQuery +=       " D0K.D0K_PROD,"
	cQuery +=       " D0K.D0K_LOCAL,"
	cQuery +=       " D0K.D0K_LOTE,"
	cQuery +=       " D0K.D0K_SUBLOT,"
	cQuery +=       " D0K.D0K_QUANT,"
	cQuery +=       " SD1.D1_NUMSEQ,"
	cQuery +=       " SD1.D1_IDDCF"
	cQuery +=  " FROM "+RetSqlName('D0K')+" D0K, ";
	                   +RetSqlName('SD1')+" SD1"
	cQuery += " WHERE D0K.D0K_FILIAL  = '"+xFilial('D0K')+"'"
	cQuery +=   " AND D0K.D0K_EMBARQ  = '"+cEmbarque+"'"
	cQuery +=   " AND D0K.D_E_L_E_T_  = ' '"
	cQuery +=   " AND SD1.D1_FILIAL   = '"+xFilial('SD1')+"'"
	cQuery +=   " AND SD1.D1_DOC      = D0K.D0K_DOC"
	cQuery +=   " AND SD1.D1_SERIE    = D0K.D0K_SERIE"
	cQuery +=   " AND SD1.D1_FORNECE  = D0K.D0K_FORNEC"
	cQuery +=   " AND SD1.D1_LOJA     = D0K.D0K_LOJA"
	cQuery +=   " AND SD1.D1_COD      = D0K.D0K_PROD"
	cQuery +=   " AND SD1.D1_ITEM     = D0K.D0K_ITEM"
	cQuery +=   " AND SD1.D1_QTDCONF < SD1.D1_QUANT"
	cQuery +=   " AND SD1.D1_QUANT    > 0"
	cQuery +=   " AND SD1.D1_OP       = ' '"
	cQuery +=   " AND SD1.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry  := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'D0K_QUANT','N',aTamSx3[1],aTamSx3[2])
	If (cAliasQry)->(!Eof())
		oSaldoADis := WMSDTCSaldoADistribuir():New()
	EndIf
	Do While lRet .And. (cAliasQry)->(!Eof())
		// Carrega o saldo a distribuir para atualização
		oSaldoADis:ClearData()
		oSaldoADis:oProdLote:SetArmazem((cAliasQry)->D0K_LOCAL)
		oSaldoADis:oProdLote:SetProduto((cAliasQry)->D0K_PROD)
		oSaldoADis:SetDocto((cAliasQry)->D0K_DOC)
		oSaldoADis:SetSerie((cAliasQry)->D0K_SERIE)
		oSaldoADis:SetCliFor((cAliasQry)->D0K_FORNEC)
		oSaldoADis:SetLoja((cAliasQry)->D0K_LOJA)
		oSaldoADis:SetNumSeq((cAliasQry)->D1_NUMSEQ)
		oSaldoADis:SetIdDCF((cAliasQry)->D1_IDDCF)
		// Atualização Saldo a distribuir D0G quando existir
		If oSaldoADis:LoadData(1)
			oSaldoADis:SetQtdOri((cAliasQry)->D0K_QUANT)
			oSaldoADis:SetQtdSld((cAliasQry)->D0K_QUANT)
			If !(lRet := oSaldoADis:UpdateD0G())
				WmsMessage(oSaldoADis:GetErro(),WMSA320D33,1)
			EndIf
		Else
			oSaldoADis:SetOrigem("SD1")
			oSaldoADis:oProdLote:GetLoteCtl((cAliasQry)->D0K_LOTE)
			oSaldoADis:oProdLote:GetLoteCtl((cAliasQry)->D0K_SUBLOT)
			oSaldoADis:oProdLote:oProduto:LoadData() // Para forçar carregar os dados do produto
			oSaldoADis:SetQtdOri((cAliasQry)->D0K_QUANT)
			oSaldoADis:SetQtdSld((cAliasQry)->D0K_QUANT)
			If !(lRet := oSaldoADis:RecordD0G())
				WmsMessage(oSaldoADis:GetErro(),WMSA320D38,1)
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet

//------------------------------------------------------------------------------
// Efetua o ajuste do campo dopcumento, caso o tamanho do campo D3_DOC não suporte
// o tamanho padrão do documento -> CFT|CFE + cEmbarque = CFE123456|CFT123456
//------------------------------------------------------------------------------
Static Function AjustaDoc(cDocumento,cEmbarque)
Local aAreaAnt  := {}
Local nTamDoc   := TamSx3("D3_DOC")[1]
Local cDocIni   := ""
Local cDocFim   := ""
Local cQuery    := ""
Local cAliasQry := ""

	// Tamanho é igual, retorna o próprio documento
	If Len(cDocumento) == nTamDoc
		Return cDocumento
	// Tamanho é menor, preenche com zeros entre o inicio e o embarque - CFT + 00 + 123456
	ElseIf Len(cDocumento) < nTamDoc
		cDocumento := Left(cDocumento,3)+PadL(cEmbarque,nTamDoc-3,'0')
	// Tamanho é menor, deve retornar um valor do próximo documento
	Else
		aAreaAnt := GetArea()
		cDocIni := Left(cDocumento,3)+Replicate('0',nTamDoc-3)
		cDocFim := Left(cDocumento,3)+Replicate('Z',nTamDoc-3)
		cQuery := "SELECT MAX(D3_DOC) D3_DOC"
		cQuery +=  " FROM "+RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"'"
		cQuery +=   " AND D3_DOC >= '"+cDocIni+"'"
		cQuery +=   " AND D3_DOC <= '"+cDocFim+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof()) .And. !Empty((cAliasQry)->D3_DOC)
			cDocumento := Left(cDocumento,3)+Soma1(SubStr((cAliasQry)->D3_DOC,4))
		Else
			cDocumento := cDocIni
		EndIf
		(cAliasQry)->(DbCloseArea())
		RestArea(aAreaAnt)
	EndIf
Return cDocumento

//----------------------------------------------------------
/*/{Protheus.doc} Wm320UnD14
Faz ajustes necessários na D14 quando tratar-se de uma conferência de documento de entrada e há unitizadores gerados.
@author  Amanda Rosa Vieira
@version P12
@since   25/04/2017
/*/
//----------------------------------------------------------
Function Wm320UnD14(cEmbarque,lEstorno)
Local lRet        := .T.
Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
Default lEstorno  := .F.

	cQuery := " SELECT D0R.D0R_IDUNIT,"
	cQuery +=        " D0R.D0R_CODUNI,"
	cQuery +=        " D0R.D0R_LOCAL,"
	cQuery +=        " D0R.D0R_ENDER,"
	cQuery +=        " D0S.D0S_CODPRO,"
	cQuery +=        " D0S.D0S_PRDORI,"
	cQuery +=        " D0S.D0S_LOTECT,"
	cQuery +=        " D0S.D0S_QUANT,"
	cQuery +=        " D0S.D0S_IDD0Q,"
	If oMntUniItem:lHasIdMvUn
		cQuery +=     " D0S.D0S_IDMVUN,"
	EndIf
	cQuery +=        " CASE WHEN D0Q.D0Q_ORIGEM = 'SD1' THEN SD1.D1_NUMLOTE ELSE SD3.D3_NUMLOTE END D0Q_NUMLOT"
	cQuery +=   " FROM "+RetSqlName('DCZ')+" DCZ"
	cQuery +=  " INNER JOIN "+RetSqlName('NNR')+" NNR"
	cQuery +=     " ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"'"
	cQuery +=    " AND NNR.NNR_CODIGO = DCZ.DCZ_LOCAL"
	cQuery +=    " AND NNR.NNR_AMZUNI = '1'"
	cQuery +=    " AND NNR.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName('D0R')+" D0R"
	cQuery +=     " ON D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
	cQuery +=    " AND D0R.D0R_IDUNIT = DCZ.DCZ_IDUNIT"
	cQuery +=    " AND D0R.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName('D0S')+" D0S"
	cQuery +=     " ON D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
	cQuery +=    " AND D0S.D0S_IDUNIT = DCZ.DCZ_IDUNIT"
	cQuery +=    " AND D0S.D0S_PRDORI = DCZ_PRDORI"
	cQuery +=    " AND D0S.D0S_CODPRO = DCZ.DCZ_PROD"
	cQuery +=    " AND D0S.D0S_LOTECT = DCZ.DCZ_LOTE"
	cQuery +=    " AND D0S.D0S_NUMLOT = DCZ.DCZ_SUBLOT"
	cQuery +=    " AND D0S.D0S_CODOPE = DCZ.DCZ_OPER"
	cQuery +=    " AND D0S.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("D0Q")+" D0Q"
	cQuery +=     " ON D0Q.D0Q_FILIAL = '"+xFilial("D0Q")+"'"
	cQuery +=    " AND D0Q.D0Q_ID     = D0S.D0S_IDD0Q"
	CQuery +=    " AND D0Q.D0Q_LOTECT = D0S.D0S_LOTECT"
	cQuery +=    " AND D0Q.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+RetSqlName("SD1")+" SD1"
	cQuery +=     " ON SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery +=    " AND SD1.D1_NUMSEQ  = D0Q.D0Q_NUMSEQ"
	cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+RetSqlName("SD3")+" SD3"
	cQuery +=     " ON SD3.D3_FILIAL  = '"+xFilial("SD3")+"'"
	cQuery +=    " AND SD3.D3_NUMSEQ  = D0Q.D0Q_NUMSEQ"
	cQuery +=    " AND SD3.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery +=   "ORDER BY D0R.D0R_IDUNIT,"
	cQuery +=        " D0S.D0S_PRDORI,"
	cQuery +=        " D0S.D0S_CODPRO,"
	cQuery +=        " D0S.D0S_LOTECT,"
	cQuery +=        " D0S.D0S_NUMLOT"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While lRet .And. (cAliasQry)->(!EoF())
		oMntUniItem:oUnitiz:SetArmazem((cAliasQry)->D0R_LOCAL)
		oMntUniItem:oUnitiz:SetEnder((cAliasQry)->D0R_ENDER)
		oMntUniItem:SetProduto((cAliasQry)->D0S_CODPRO)
		oMntUniItem:SetPrdOri((cAliasQry)->D0S_PRDORI)
		oMntUniItem:SetLoteCtl((cAliasQry)->D0S_LOTECT)
		oMntUniItem:SetNumLote((cAliasQry)->D0Q_NUMLOT)
		oMntUniItem:SetQuant((cAliasQry)->D0S_QUANT)
		oMntUniItem:SetIdUnit((cAliasQry)->D0R_IDUNIT)
		If oMntUniItem:lHasIdMvUn
			oMntUniItem:SetIdMovUn((cAliasQry)->D0S_IDMVUN)
		EndIf
		oMntUniItem:oUnitiz:SetTipUni((cAliasQry)->D0R_CODUNI)
		oMntUniItem:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetDocto(cEmbarque),;
			oMovEstEnd:SetIdDCF((cAliasQry)->D0S_IDD0Q);
		})
		oMntUniItem:SetUsaD0Q(.F.)
		oMntUniItem:SetIdD0Q((cAliasQry)->D0S_IDD0Q)
		If !oMntUniItem:UpdateD14(lEstorno)
			WmsMessage(oMntUniItem:GetErro(),WMSA320D39,1) // Erro do objeto
			lRet := .F.
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} Wm320UnDCF
Gera ordens de serviço para os unitizadores da conferência.
@author  Amanda Rosa Vieira
@version P12
@since   08/05/2017
/*/
//----------------------------------------------------------
Function Wm320UnDCF(cEmbarque)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local oOrdServ  := WmsOrdSer()
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasDCZ := ""

	cQuery := " SELECT DISTINCT DCZ.DCZ_LOCAL,"
	cQuery +=        " DCZ.DCZ_IDUNIT"
	cQuery +=   " FROM "+RetSqlName('DCZ')+" DCZ"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
	cQuery +=    " AND DCZ.DCZ_IDUNIT <> '"+Space(TamSX3("DCZ_IDUNIT")[1])+"'"
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasDCZ := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCZ,.F.,.T.)
	While (cAliasDCZ)->(!EoF())

		//-- Somente cria a ordem de serviço na primeira vez
		If oOrdServ == Nil
			oOrdServ := WMSDTCOrdemServicoCreate():New()
			WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
		EndIf

		cQuery := " SELECT SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_FORNECE,SD1.D1_LOJA,"
		cQuery += 	" SD1.D1_LOCAL,SD1.D1_ENDER,SD1.D1_SERVIC,SD1.D1_NUMSEQ,SD1.D1_COD"
		cQuery += 		" FROM "+RetSqlName('DCZ')+" DCZ"
		cQuery += 		" INNER JOIN "+RetSqlName('DCX')+" DCX ON (DCX.D_E_L_E_T_ = ' '"
		cQuery += 			" AND DCX_FILIAL = '"+xFilial('DCX')+"'"
		cQuery += 			" AND DCZ.DCZ_EMBARQ = DCX.DCX_EMBARQ)"
		cQuery += 		" INNER JOIN "+RetSqlName('D0S')+" D0S ON (D0S.D_E_L_E_T_ = ' '"
		cQuery += 			" AND D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
		cQuery += 			" AND D0S.D0S_IDUNIT = DCZ.DCZ_IDUNIT"
		cQuery += 			" AND D0S.D0S_PRDORI = DCZ.DCZ_PRDORI"
		cQuery += 			" AND D0S.D0S_CODPRO = DCZ.DCZ_PROD"
		cQuery += 			" AND D0S.D0S_LOTECT = DCZ.DCZ_LOTE"
		cQuery += 			" AND D0S.D0S_NUMLOT = DCZ.DCZ_SUBLOT)"
		cQuery += 		" INNER JOIN "+RetSqlName('SD1')+" SD1 ON( SD1.D_E_L_E_T_ = ' '"
		cQuery += 			" AND SD1.D1_FILIAL = '"+xFilial('SD1')+"'"
		cQuery += 			" AND SD1.D1_DOC = DCX.DCX_DOC"
		cQuery += 			" AND SD1.D1_SERIE = DCX.DCX_SERIE"
		cQuery += 			" AND SD1.D1_FORNECE = DCX.DCX_FORNEC"
		cQuery += 			" AND SD1.D1_LOJA = DCX.DCX_LOJA"
		cQuery +=			" AND SD1.D1_LOCAL = DCZ.DCZ_LOCAL"
		cQuery += 			" AND SD1.D1_COD = DCZ.DCZ_PRDORI"
		cQuery += 			" AND SD1.D1_LOTECTL = DCZ.DCZ_LOTE)"
		cQuery += 		" INNER JOIN "+RetSqlName('D0Q')+" D0Q ON (D0Q.D_E_L_E_T_ = ' '"
		cQuery += 			" AND D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
		cQuery += 			" AND D0Q.D0Q_ID = D0S.D0S_IDD0Q"
		cQuery += 			" AND D0Q_SERVIC = SD1.D1_SERVIC"
		cQuery += 			" AND D0Q_ORIGEM = 'SD1'"
		cQuery += 			" AND D0Q_DOCTO = SD1.D1_DOC"
		cQuery += 			" AND D0Q_SERIE = SD1.D1_SERIE"
		cQuery +=			" AND D0Q_CLIFOR = SD1.D1_FORNECE"
		cQuery += 			" AND D0Q_LOJA = SD1.D1_LOJA"
		cQuery += 			" AND D0Q_CODPRO = SD1.D1_COD"
		cQuery += 			" AND D0Q_LOTECT = SD1.D1_LOTECTL"
		cQuery += 			" AND D0Q_NUMLOT = SD1.D1_NUMLOTE)"
		cQuery += 				" WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
		cQuery += 					" AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
		cQuery += 					" AND DCZ_IDUNIT = '"+(cAliasDCZ)->DCZ_IDUNIT+"'"
		cQuery += 					" AND DCZ.DCZ_IDUNIT <> ' '"
		cQuery += 					" AND DCZ.D_E_L_E_T_ = ' '"
		cQuery += 					" AND SD1.D1_IDDCF <> ' '"
		cQuery += 					" AND SD1.D1_QUANT > 0"
		cQuery += 					" AND SD1.D1_OP = ' '"

		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		If (cAliasQry)->(!Eof())  
			// Seta os atributos do objeto
			oOrdServ:SetIdUnit((cAliasDCZ)->DCZ_IDUNIT)
			oOrdServ:SetData(dDataBase)
			oOrdServ:SetServico((cAliasQry)->D1_SERVIC)
			oOrdServ:SetDocto((cAliasQry)->D1_DOC)
			oOrdServ:SetSerie((cAliasQry)->D1_SERIE)
			oOrdServ:SetCliFor((cAliasQry)->D1_FORNECE)
			oOrdServ:SetLoja((cAliasQry)->D1_LOJA)
			oOrdServ:SetNumSeq((cAliasQry)->D1_NUMSEQ)
			oOrdServ:SetCodRec(cEmbarque)
			oOrdServ:oOrdEndOri:SetArmazem((cAliasQry)->D1_LOCAL)
			oOrdServ:oOrdEndOri:SetEnder((cAliasQry)->D1_ENDER)
			oOrdServ:oOrdEndDes:SetArmazem((cAliasQry)->D1_LOCAL)
			oOrdServ:oOrdEndDes:SetEnder("")
			oOrdServ:oProdLote:ClearData()
			oOrdServ:SetOrigem("D0R")
			oOrdServ:SetQuant(1)
			// Realiza a criação da ordem de serviço como origem D0R
			If !oOrdServ:CreateDCF()
				WmsMessage(oOrdServ:GetErro(),WMSA320D34,1) // Erro do objeto
				lRet := .F.
			EndIf
		// Se for o local de excesso, tenta buscar a movimentação da SD3 para gravar o unitizador
		ElseIf (cAliasDCZ)->DCZ_LOCAL == __cWmsLcEx
			cQuery := " SELECT SD3.D3_DOC,"
			cQuery +=        " SD3.D3_SERVIC,"
			cQuery +=        " SD3.D3_NUMSEQ"
			cQuery += " FROM "+RetSqlName('DCZ')+" DCZ,"
			cQuery +=      " "+RetSqlName('SD3')+" SD3"
			cQuery += " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
			cQuery +=   " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
			cQuery +=   " AND DCZ.DCZ_IDUNIT = '"+(cAliasDCZ)->DCZ_IDUNIT+"'"
			cQuery +=   " AND DCZ.D_E_L_E_T_ = ' '"
			cQuery +=   " AND SD3.D3_FILIAL  = '"+xFilial('SD3')+"'"
			cQuery +=   " AND SD3.D3_IDENT   = DCZ.DCZ_EMBARQ"
			cQuery +=   " AND SD3.D3_LOCAL   = DCZ.DCZ_LOCAL"
			cQuery +=   " AND SD3.D3_COD     = DCZ.DCZ_PRDORI"
			cQuery +=   " AND SD3.D3_LOTECTL = DCZ.DCZ_LOTE"
			cQuery +=   " AND SD3.D3_ESTORNO = ' '"
			cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				// Seta os atributos do objeto
				oOrdServ:SetIdUnit((cAliasDCZ)->DCZ_IDUNIT)
				oOrdServ:SetData(dDataBase)
				oOrdServ:SetServico((cAliasQry)->D3_SERVIC)
				oOrdServ:SetDocto((cAliasQry)->D3_DOC)
				oOrdServ:SetSerie("")
				oOrdServ:SetCliFor("")
				oOrdServ:SetLoja("")
				oOrdServ:SetNumSeq((cAliasQry)->D3_NUMSEQ)
				oOrdServ:SetCodRec(cEmbarque)
				oOrdServ:oOrdEndOri:SetArmazem(__cWmsLcEx)
				oOrdServ:oOrdEndOri:SetEnder(__cWmsEnEx)
				oOrdServ:oOrdEndDes:SetArmazem(__cWmsLcEx)
				oOrdServ:oOrdEndDes:SetEnder("")
				oOrdServ:oProdLote:ClearData()
				oOrdServ:SetOrigem("D0R")
				oOrdServ:SetQuant(1)
				// Realiza a criação da ordem de serviço como origem D0R
				If !oOrdServ:CreateDCF()
					WmsMessage(oOrdServ:GetErro(),WMSA320D35,1) // Erro do objeto
					lRet := .F.
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
		If !lRet
			Exit
		EndIf
		(cAliasDCZ)->(DbSkip())
		//Limpa código de unitizador do objeto
		oOrdServ:SetIdUnit("")
	EndDo
	(cAliasDCZ)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
// Atualiza situação dos unitizadores quando conferência de pré-nota
//------------------------------------------------------------------------------
Static Function UpdStsUnit(cEmbarque,lFinaliza)
Local lRet        := .T.
Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local oUnitiz     := Nil
Default cEmbarque  := ""
Default lFinaliza  := .T.

	cQuery := " SELECT DCZ.DCZ_IDUNIT"
	cQuery +=   " FROM "+RetSqlName('DCZ')+" DCZ"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!EoF())
		oUnitiz := WMSDTCMontagemUnitizador():New()
	EndIf
	While (cAliasQry)->(!EoF())
		oUnitiz:SetIdUnit((cAliasQry)->DCZ_IDUNIT)
		If oUnitiz:LoadData(3)
			oUnitiz:SetStatus(IIf(lFinaliza,'6','5'))
			oUnitiz:UpdateD0R()
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return lRet

//---------------------------------------------------------------
// Apaga demanda de unitização e desfaz ligações entre D0S e D0G.
//---------------------------------------------------------------
Static Function DelDmdUni(cEmbarque)
Local lRet      := .T.
Local cAliasQry := ""
Local cAliasD0S := ""
Local cQuery    := ""
Local oSaldoADis := Nil

	cQuery := " SELECT SD1.R_E_C_N_O_ RECNODOC,"
	cQuery +=        " D0G.R_E_C_N_O_ RECNOD0G,"
	cQuery +=        " D0Q.R_E_C_N_O_ RECNOD0Q,"
	cQuery +=        " D0Q.D0Q_ID,"
	cQuery +=        " 'SD1' ORIGEM"
	cQuery +=   " FROM "+RetSqlName('DCX')+" DCX"
	cQuery +=  " INNER JOIN "+RetSqlName('D0Q')+" D0Q"
	cQuery +=     " ON D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
	cQuery +=    " AND D0Q.D0Q_DOCTO = DCX.DCX_DOC"
	cQuery +=    " AND D0Q.D0Q_SERIE = DCX.DCX_SERIE"
	cQuery +=    " AND D0Q.D0Q_CLIFOR = DCX.DCX_FORNEC"
	cQuery +=    " AND D0Q.D0Q_LOJA = DCX.DCX_LOJA"
	cQuery +=    " AND D0Q.D0Q_ORIGEM = 'SD1'"
	cQuery +=    " AND D0Q.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName('SD1')+" SD1"
	cQuery +=     " ON SD1.D1_FILIAL = '"+xFilial('SD1')+"'"
	cQuery +=    " AND SD1.D1_NUMSEQ = D0Q.D0Q_NUMSEQ"
	cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+RetSqlName('D0G')+" D0G"
	cQuery +=     " ON D0G.D0G_FILIAL = '"+xFilial('D0G')+"'"
	cQuery +=    " AND D0G.D0G_IDDCF  = D0Q.D0Q_ID"
	cQuery +=    " AND D0G.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
	cQuery +=    " AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
	cQuery +=    " AND DCX.D_E_L_E_T_ = ' '"
	cQuery +=  " UNION ALL"
	cQuery += " SELECT SD3.R_E_C_N_O_ RECNODOC,"
	cQuery +=        " D0G.R_E_C_N_O_ RECNOD0G,"
	cQuery +=        " D0Q.R_E_C_N_O_ RECNOD0Q,"
	cQuery +=        " D0Q.D0Q_ID,"
	cQuery +=        " 'SD3' ORIGEM"
	cQuery +=   " FROM "+RetSqlName('SD3')+" SD3"
	cQuery +=  " INNER JOIN "+RetSqlName('D0Q')+" D0Q"
	cQuery +=     " ON D0Q.D0Q_FILIAL = '"+xFilial('D0Q')+"'"
	cQuery +=    " AND D0Q.D0Q_DOCTO  = SD3.D3_DOC"
	cQuery +=    " AND D0Q.D0Q_NUMSEQ = SD3.D3_NUMSEQ"
	cQuery +=    " AND D0Q.D0Q_ORIGEM = 'SD3'"
	cQuery +=    " AND D0Q.D_E_L_E_T_ = ' '"
	cQuery +=   " LEFT JOIN "+RetSqlName('D0G')+" D0G"
	cQuery +=     " ON D0G.D0G_FILIAL = '"+xFilial('D0G')+"'"
	cQuery +=    " AND D0G.D0G_PRODUT = SD3.D3_COD"
	cQuery +=    " AND D0G.D0G_LOCAL  = SD3.D3_LOCAL"
	cQuery +=    " AND D0G.D0G_NUMSEQ = SD3.D3_NUMSEQ"
	cQuery +=    " AND D0G.D0G_DOC    = SD3.D3_DOC"
	cQuery +=    " AND D0G.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"'"
	cQuery +=    " AND SD3.D3_IDENT  = '"+cEmbarque+"'"
	cQuery +=    " AND Substring(SD3.D3_DOC,1,3) = 'CEX'" // Para garantir que é uma movimentação de excesso de conferência
	cQuery +=    " AND SD3.D3_ESTORNO = ' '"
	cQuery +=    " AND SD3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While lRet .And. (cAliasQry)->(!Eof())
		cQuery := " SELECT D0S.R_E_C_N_O_ RECNOD0S,"
		cQuery +=        " D0S.D0S_IDUNIT,"
		cQuery +=        " D0S.D0S_PRDORI,"
		cQuery +=        " D0S.D0S_CODPRO,"
		cQuery +=        " D0S.D0S_LOTECT,"
		cQuery +=        " D0S.D0S_NUMLOT,"
		cQuery +=        " D0S.D0S_QUANT"
		cQuery +=   " FROM "+RetSqlName('D0S')+" D0S"
		cQuery +=  " WHERE D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
		cQuery +=    " AND D0S.D0S_IDD0Q = '"+(cAliasQry)->D0Q_ID+"'"
		cQuery +=    " AND D0S.D_E_L_E_T_ = ' '"
		cAliasD0S := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD0S,.F.,.T.)
		Do While lRet .And. (cAliasD0S)->(!Eof())
			D0S->(DbSetOrder()) //D0S_FILIAL+D0S_IDUNIT+D0S_PRDORI+D0S_CODPRO+D0S_LOTECT+D0S_NUMLOT+D0S_IDD0Q
			//Se já existe uma linha do unitizador com o ID D0Q em branco, soma as quantidades e apaga uma das D0S
			If D0S->(DbSeek(xFilial('D0S')+(cAliasD0S)->(D0S_IDUNIT+D0S_PRDORI+D0S_CODPRO+D0S_LOTECT+D0S_NUMLOT)+Space(TamSx3("D0S_IDD0Q")[1])))
				//Soma quantidade com a D0S encontrada
				RecLock('D0S', .F.)
				D0S->D0S_QUANT += (cAliasD0S)->D0S_QUANT
				D0S->(MsUnlock())
				//Apaga D0S retornada na query
				D0S->(DbGoTo((cAliasD0S)->RECNOD0S))
				RecLock('D0S', .F.)
				D0S->(dbDelete())
				D0S->(MsUnlock())
			Else
				D0S->(DbGoTo((cAliasD0S)->RECNOD0S))
				RecLock('D0S', .F.)
				D0S->D0S_IDD0Q := ""
				D0S->(MsUnlock())
			EndIf
			(cAliasD0S)->(DbSkip())
		EndDo
		(cAliasD0S)->(DbCloseArea())
		//Apaga D0Q
		D0Q->(DbGoTo((cAliasQry)->RECNOD0Q))
		RecLock('D0Q', .F.)
		D0Q->(DbDelete())
		D0Q->(MsUnlock())
		//Remove ligação entre demanda e documento
		If (cAliasQry)->ORIGEM = 'SD1'
			SD1->(DbGoTo((cAliasQry)->RECNODOC))
			RecLock('SD1', .F.)
			SD1->D1_IDDCF := ""
			SD1->(MsUnlock())
			//Remove ligação entre demanda e saldo a distribuir
			If !Empty((cAliasQry)->RECNOD0G)
				D0G->(DbGoTo((cAliasQry)->RECNOD0G))
				RecLock('D0G', .F.)
				D0G->D0G_IDDCF := ""
				D0G->(MsUnlock())
			EndIf
		EndIf
		If (cAliasQry)->ORIGEM = 'SD3'
			SD3->(DbGoTo((cAliasQry)->RECNODOC))
			RecLock('SD3', .F.)
			SD3->D3_IDDCF := ""
			SD3->(MsUnlock())
			// Se possui saldo a endereçar, deve buscar excluir o saldo a endereçar para este registro
			If !Empty((cAliasQry)->RECNOD0G)
				If oSaldoADis == Nil
					oSaldoADis := WMSDTCSaldoADistribuir():New()
				EndIf
				If oSaldoADis:GoToD0G((cAliasQry)->RECNOD0G)
					If !(lRet := oSaldoADis:DeleteD0G())
						WmsMessage(oSaldoADis:GetErro(),WMSA320D37,1) // Erro do objeto
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} WMSA320Par
Avalia se todos os parâmetros necessários estão preenchidos.

@author  Guilherme A. Metzger
@version P12
@since   01/12/2017
/*/
//----------------------------------------------------------
Function WMSA320Par()
Local lTelNet := IsTelNet()
Local aParams := {}
Local aTela   := {}
Local aCab    := {STR0013,STR0014} // Parametro / Descricao
Local aSize   := {10,40}
Local nI      := 1

	// A regra é:
	// 1 - Nenhum parâmetro precisa estar preenchido (no entanto, o sistema não executará as tratamentos de falta e excesso)
	// 2 - Todos os parâmetros devem ter sido preenchidos
	If !(Wm320ClPar() .Or. (Wm320MovEx() .And. Wm320MovFt()))
		If !lTelNet
			Aadd(aParams,{STR0015}) // "Para que os tratamentos de falta e excesso funcionem corretamente, é necessário preencher os seguintes parâmetros:"
		EndIf
		If Empty(__cWmsLcFt)
			Aadd(aParams,{STR0016,""}) // "MV_WMSLCFT - Local de falta"
		EndIf
		If Empty(__cWmsLcEx)
			Aadd(aParams,{STR0017,""}) // "MV_WMSLCEX - Local de excesso"
		EndIf
		If Empty(__cWmsEnFt)
			Aadd(aParams,{STR0018,""}) // "MV_WMSENFT - Endereço de falta"
		EndIf
		If Empty(__cWmsEnEx)
			Aadd(aParams,{STR0019,""}) // "MV_WMSENEX - Endereço de excesso"
		EndIf
		If Empty(__cWmsSrFt)
			Aadd(aParams,{STR0020,""}) // "MV_WMSSRFT - Serviço de falta"
		EndIf
		If Empty(__cWmsSrEx)
			Aadd(aParams,{STR0021,""}) // "MV_WMSSREX - Serviço de excesso"
		EndIf
 		If __lWmsNew
			If Empty(__cWmsSrRe)
				Aadd(aParams,{STR0022,""}) // "MV_WMSSRRE - Serviço de retirada"
			EndIf
			If Empty(__cWmsTMFt)
				Aadd(aParams,{STR0023,""}) // "MV_WMSTMFT - Tipo de movimentação de falta"
			EndIf
			If Empty(__cWmsTMEx)
				Aadd(aParams,{STR0024,""}) // "MV_WMSTMEX - Tipo de movimentação de excesso"
			EndIf
			If Empty(__cWmsTMRe)
				Aadd(aParams,{STR0025,""}) // "MV_WMSTMRE - Tipo de movimentação de retirada"
			EndIf
		EndIf

		If lTelNet
			// Separa o código e a descrição do parâmetro para mostrar em colunas diferentes
			For nI := 1 To Len(aParams)
				aParams[nI,2] := FwNoAccent(SubStr(aParams[nI,1],14))
				aParams[nI,1] := SubStr(aParams[nI,1],1,10)
			Next
			// Apresenta mensagem informativa e uma lista com os parâmetros não preenchidos
			aTela := VTSave()
			VTClear()
			WmsMessage(STR0026) // "Existem parâmetros da rotina que não foram preenchidos! Algumas funcionalidades serão comprometidas."
			WMSVTCabec("SIGAWMS",.F.,.F.,.T.) // Lotes a separar
			VTaBrowse(1,0,VTMaxRow()-1,VTMaxCol(),aCab,aParams,aSize)
			VtRestore(,,,,aTela)
		Else
			TmsMsgErr(aParams,STR0027) // "Parâmetros da Conferência do Recebimento Incompletos"
		EndIf
	EndIf

Return
