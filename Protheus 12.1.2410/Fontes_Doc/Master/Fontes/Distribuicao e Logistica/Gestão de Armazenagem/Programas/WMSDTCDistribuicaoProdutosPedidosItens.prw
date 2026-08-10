#Include "Totvs.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "WMSDTCDistribuicaoProdutosPedidosItens.ch"
//----------------------------------------------
/*/{Protheus.doc} WMSCLS0016
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0016()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoProdutosPedidosItens
Classe distribuição de produtos, pedidos e itens
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoProdutosPedidosItens FROM LongNameClass
	// Data
	DATA oMntDist // D06
	DATA cPedido
	DATA cCliente
	DATA cLoja
	DATA cItem
	DATA cSequen
	DATA cArmazem
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cOrigem
	DATA cEndereco
	DATA nQtdVen
	DATA nQtdVe2
	DATA nQtdDis
	DATA nQtdDi2
	DATA nQtdEnd
	DATA nQtdEn2
	DATA dDatEnt
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD GoToD08(nRecno)
	METHOD RecordD08()
	METHOD UpdateD08()
	METHOD DeleteD08()
	// Setters
	METHOD SetCodDis(cCodDis)
	METHOD SetPedido(cPedido)
	METHOD SetCliente(cCliente)
	METHOD SetLoja(cLoja)
	METHOD SetItem(cItem)
	METHOD SetSequen(cSequen)
	METHOD SetArmazem(cArmazem)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetOrigem(cOrigem)
	METHOD SetQtdVen(nQtdVen)
	METHOD SetQtdVe2(nQtdVe2)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetQtdDi2(nQtdDi2)
	METHOD SetQtdEnd(nQtdEnd)
	METHOD SetQtdEn2(nQtdEn2)
	METHOD SetDatEnt(dDatEnt)
	// Getters
	METHOD GetCodDis()
	METHOD GetPedido()
	METHOD GetCliente()
	METHOD GetLoja()
	METHOD GetItem()
	METHOD GetSequen()
	METHOD GetArmazem()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetOrigem()
	METHOD GetQtdVen()
	METHOD GetQtdVe2()
	METHOD GetQtdDis()
	METHOD GetQtdDi2()
	METHOD GetQtdEnd()
	METHOD GetQtdEn2()
	METHOD MntDisAuto(nRecnoSF1)
	METHOD CancelDist(nRecno,cCodDis,lAuto)
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:oMntDist  := WMSDTCDistribuicaoProdutos():New()
	Self:cPedido   := PadR("", TamSx3("D08_PEDIDO")[1])
	Self:cCliente  := PadR("", TamSx3("D08_CLIENT")[1])
	Self:cLoja     := PadR("", TamSx3("D08_LOJA")[1])
	Self:cItem     := PadR("", TamSx3("D08_ITEM")[1])
	Self:cSequen   := PadR("", TamSx3("D08_SEQUEN")[1])
	Self:cArmazem  := PadR("", TamSx3("D08_LOCAL")[1])
	Self:cProduto  := PadR("", TamSx3("D08_PRODUT")[1])
	Self:cLoteCtl  := PadR("", TamSx3("D08_LOTECT")[1])
	Self:cNumLote  := PadR("", TamSx3("D08_NUMLOT")[1])
	Self:cOrigem   := PadR("", TamSx3("D08_ORIGEM")[1])
	Self:cEndereco := PadR("", TamSx3("D08_ENDER")[1])
	Self:nQtdVen   := 0
	Self:nQtdVe2   := 0
	Self:nQtdDis   := 0
	Self:nQtdDi2   := 0
	Self:nQtdEnd   := 0
	Self:nQtdEn2   := 0
	Self:dDatEnt   := CTOD("")
	Self:cErro     := ""
	Self:nRecno    := 0
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoProdutosPedidosItens
	//Mantido para compatibilidade
Return

METHOD GoToD08(nRecno) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nRecno := nRecno
Return Self:LoadData(0)

METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoProdutosPedidosItens
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aD08_QTDVEN := TamSx3("D08_QTDVEN")
Local aD08_QTDDIS := TamSx3("D08_QTDDIS")
Local aD08_QTDVE2 := TamSx3("D08_QTDVE2")
Local aD08_QTDDI2 := TamSx3("D08_QTDDI2")
Local aD08_QTDEND := TamSx3("D08_QTDEND")
Local aD08_QTDEN2 := TamSx3("D08_QTDEN2")
Local aAreaD08    := D08->(GetArea())
Local cAliasD08   := Nil

Default nIndex    := 1

	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D08_FILIAL+D08_CODDIS+D08_PEDIDO+D08_ITEM+D08_SEQUEN+D08_PRODUT
			If Empty(Self:GetCodDis()) .Or. Empty(Self:cPedido) .Or. Empty(Self:cItem) .Or. Empty(Self:cProduto)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		cAliasD08  := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD08
					SELECT D08.D08_CODDIS,
							D08.D08_PEDIDO,
							D08.D08_CLIENT,
							D08.D08_LOJA,
							D08.D08_LOCAL,
							D08.D08_ITEM,
							D08.D08_SEQUEN,
							D08.D08_PRODUT,
							D08.D08_LOTECT,
							D08.D08_NUMLOT,
							D08.D08_ORIGEM,
							D08.D08_ENDER,
							D08.D08_QTDVEN,
							D08.D08_QTDDIS,
							D08.D08_QTDVE2,
							D08.D08_QTDDI2,
							D08.D08_QTDEND,
							D08.D08_QTDEN2,
							D08.D08_QTORID,
							D08.D08_DATENT,
							D08.R_E_C_N_O_ RECNOD08
					FROM %Table:D08% D08
					WHERE D08.D08_FILIAL = %xFilial:D08%
					AND D08.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D08.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD08
					SELECT D08.D08_CODDIS,
							D08.D08_PEDIDO,
							D08.D08_CLIENT,
							D08.D08_LOJA,
							D08.D08_LOCAL,
							D08.D08_ITEM,
							D08.D08_SEQUEN,
							D08.D08_PRODUT,
							D08.D08_LOTECT,
							D08.D08_NUMLOT,
							D08.D08_ORIGEM,
							D08.D08_ENDER,
							D08.D08_QTDVEN,
							D08.D08_QTDDIS,
							D08.D08_QTDVE2,
							D08.D08_QTDDI2,
							D08.D08_QTDEND,
							D08.D08_QTDEN2,
							D08.D08_QTORID,
							D08.D08_DATENT,
							D08.R_E_C_N_O_ RECNOD08
					FROM %Table:D08% D08
					WHERE D08.D08_FILIAL = %xFilial:D08%
					AND D08.D08_CODDIS = %Exp:Self:GetCodDis()%
					AND D08.D08_PEDIDO = %Exp:Self:cPedido%
					AND D08.D08_ITEM   = %Exp:Self:cItem%
					AND D08.D08_SEQUEN = %Exp:Self:cSequen%
					AND D08.D08_PRODUT = %Exp:Self:cProduto%
					AND D08.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD08,'D08_QTDVEN','N',aD08_QTDVEN[1],aD08_QTDVEN[2])
		TCSetField(cAliasD08,'D08_QTDDIS','N',aD08_QTDDIS[1],aD08_QTDDIS[2])
		TCSetField(cAliasD08,'D08_QTDVE2','N',aD08_QTDVE2[1],aD08_QTDVE2[2])
		TCSetField(cAliasD08,'D08_QTDDI2','N',aD08_QTDDI2[1],aD08_QTDDI2[2])
		TCSetField(cAliasD08,'D08_QTDEND','N',aD08_QTDEND[1],aD08_QTDEND[2])
		TCSetField(cAliasD08,'D08_QTDEN2','N',aD08_QTDEN2[1],aD08_QTDEN2[2])
		If (lRet := (cAliasD08)->(!Eof()))
			Self:SetCodDis((cAliasD08)->D08_CODDIS)
			Self:SetPedido((cAliasD08)->D08_PEDIDO)
			Self:oMntDist:LoadData()
			//
			Self:cCliente  := (cAliasD08)->D08_CLIENT
			Self:cLoja     := (cAliasD08)->D08_LOJA
			Self:cArmazem  := (cAliasD08)->D08_LOCAL
			Self:cItem     := (cAliasD08)->D08_ITEM
			Self:cSequen   := (cAliasD08)->D08_SEQUEN
			Self:cProduto  := (cAliasD08)->D08_PRODUT
			Self:cLoteCtl  := (cAliasD08)->D08_LOTECT
			Self:cNumLote  := (cAliasD08)->D08_NUMLOT
			Self:cOrigem   := (cAliasD08)->D08_ORIGEM
			Self:cEndereco := (cAliasD08)->D08_ENDER
			Self:nQtdVen   := (cAliasD08)->D08_QTDVEN
			Self:nQtdVe2   := (cAliasD08)->D08_QTDVE2
			Self:nQtdDis   := (cAliasD08)->D08_QTDDIS
			Self:nQtdDi2   := (cAliasD08)->D08_QTDDI2
			Self:nQtdEnd   := (cAliasD08)->D08_QTDEND
			Self:nQtdEn2   := (cAliasD08)->D08_QTDEN2
			Self:dDatEnt   := (cAliasD08)->D08_DATENT
			Self:nRecno    := (cAliasD08)->RECNOD08
		EndIf
		(cAliasD08)->(dbCloseArea())
	EndIf
	RestArea(aAreaD08)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD08() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Local lRet := .T.
	Self:nQtdVe2 := ConvUm(Self:cProduto,Self:nQtdVen,0,2)
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	Self:nQtdEn2 := ConvUm(Self:cProduto,Self:nQtdEnd,0,2)
	// D08_FILIAL+D08_CODDIS+D08_PEDIDO+D08_ITEM+D08_SEQUEN+D08_PRODUT
	If !D08->(dbSeek(xFilial("D08")+Self:oMntDist:GetCodDis()+Self:cPedido+Self:cItem+Self:cSequen+Self:cProduto))
		RecLock('D08', .T.)
		D08->D08_FILIAL := xFilial("D08")
		D08->D08_CODDIS := Self:oMntDist:GetCodDis()
		D08->D08_PEDIDO := Self:cPedido
		D08->D08_CLIENT := Self:cCliente
		D08->D08_LOJA   := Self:cLoja
		D08->D08_LOCAL  := Self:cArmazem
		D08->D08_ITEM   := Self:cItem
		D08->D08_SEQUEN := Self:cSequen
		D08->D08_PRODUT := Self:cProduto
		D08->D08_LOTECT := Self:cLoteCtl
		D08->D08_NUMLOT := Self:cNumLote
		D08->D08_ORIGEM := Self:cOrigem
		D08->D08_ENDER  := Self:cEndereco
		D08->D08_QTDVEN := Self:nQtdVen
		D08->D08_QTDVE2 := Self:nQtdVe2
		D08->D08_QTDDIS := Self:nQtdDis
		D08->D08_QTDDI2 := Self:nQtdDi2
		D08->D08_QTDEND := Self:nQtdEnd
		D08->D08_QTDEN2 := Self:nQtdEn2
		D08->D08_DATENT := Self:dDatEnt
		D08->(MsUnLock())
		Self:nRecno     := D08->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada
	EndIf
Return lRet

METHOD UpdateD08() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Local lRet := .T.
Local aAreaD08 := D08->(GetArea())
	// Converte 2UM
	Self:nQtdVe2 := ConvUm(Self:cProduto,Self:nQtdVen,0,2)
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	Self:nQtdEn2 := ConvUm(Self:cProduto,Self:nQtdEnd,0,2)
	If !Empty(Self:nRecno)
		D08->(dbGoTo( Self:nRecno ))
		// Grava D07
		RecLock('D08', .F.)
		D08->D08_QTDVEN := Self:nQtdVen
		D08->D08_QTDVE2 := Self:nQtdVe2
		D08->D08_QTDDIS := Self:nQtdDis
		D08->D08_QTDDI2 := Self:nQtdDi2
		D08->D08_QTDEND := Self:nQtdEnd
		D08->D08_QTDEN2 := Self:nQtdEn2
		D08->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0004 // Dados não encontrados!
	EndIf
	RestArea(aAreaD08)
Return lRet

METHOD DeleteD08() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Local lRet := .T.
Local aAreaD08 := D08->(GetArea())
	If !Empty(Self:nRecno)
		D08->(dbGoTo( Self:nRecno ))
		// Grava D07
		RecLock('D08', .F.)
		D08->(dbDelete())
		D08->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0004 // Dados não encontrados!
	EndIf
	RestArea(aAreaD08)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:oMntDist:SetCodDis(cCodDis)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cPedido := PadR(cPedido, Len(Self:cPedido))
Return

METHOD SetCliente(cCliente) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cCliente := PadR(cCliente, Len(Self:cCliente))
Return

METHOD SetLoja(cLoja) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return

METHOD SetItem(cItem) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cItem := PadR(cItem, Len(Self:cItem))
Return

METHOD SetSequen(cSequen) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cSequen := PadR(cSequen, Len(Self:cSequen))
Return

METHOD SetArmazem(cArmazem) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:cOrigem := PadR(cOrigem, Len(Self:cOrigem))
Return

METHOD SetQtdVen(nQtdVen) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nQtdVen := nQtdVen
Return

METHOD SetQtdVe2(nQtdVe2) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nQtdVe2 := nQtdVe2
Return

METHOD SetQtdDis(nQtdDis)CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nQtdDis := nQtdDis
Return

METHOD SetQtdDi2(nQtdDi2) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nQtdDi2 := nQtdDi2
Return

METHOD SetQtdEnd(nQtdEnd) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nQtdEnd := nQtdEnd
Return

METHOD SetQtdEn2(nQtdEn2) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:nQtdEn2 := nQtdEn2
Return

METHOD SetDatEnt(dDatEnt) CLASS WMSDTCDistribuicaoProdutosPedidosItens
	Self:dDatEnt := dDatEnt
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodDis() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:oMntDist:GetCodDis()

METHOD GetPedido() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cPedido

METHOD GetCliente() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cCliente

METHOD GetLoja() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cLoja

METHOD GetItem() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cItem

METHOD GetSequen() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cSequen

METHOD GetArmazem() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cArmazem

METHOD GetProduto() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cNumLote

METHOD GetOrigem() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:cOrigem

METHOD GetQtdVen() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:nQtdVen

METHOD GetQtdVe2() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:nQtdVe2

METHOD GetQtdDis()CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:nQtdDis

METHOD GetQtdDi2() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:nQtdDi2

METHOD GetQtdEnd() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:nQtdEnd

METHOD GetQtdEn2() CLASS WMSDTCDistribuicaoProdutosPedidosItens
Return Self:nQtdEn2

METHOD MntDisAuto(nRecnoSF1) CLASS WMSDTCDistribuicaoProdutosPedidosItens
Local lRet      := .T.
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local oDistDoc  := WMSDTCDistribuicaoProdutosDocumentosItens():New() //D07
Local oDistProd := WMSDTCDistribuicaoProdutosItens():New() //D09
Local cAliasNew := GetNextAlias()
Local cCodDis   := ""
Local cDocumento:= ""
Local cSerie    := ""
Local cFornec   := ""
Local cLoja     := ""
Local nWmsDpCa  := Val(SuperGetMV("MV_WMSDPCA",.F.,'0'))
	If !Empty(nRecnoSF1)
		// Busca dados prenota
		SF1->(dbGoTo(nRecnoSF1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		// Atribui dados prenota
		cDocumento := SF1->F1_DOC
		cSerie     := SF1->F1_SERIE
		cFornec    := SF1->F1_FORNECE
		cLoja      := SF1->F1_LOJA
		// Busca pedidos de vendas associados ao pedido de compra da prenota com saldo liberado
		BeginSql Alias cAliasNew
			SELECT SD1.D1_LOCAL,
					SD1.D1_DOC,
					SD1.D1_SERIE,
					SD1.D1_CODDIS,
					SD1.D1_FORNECE,
					SD1.D1_LOJA,
					SD1.D1_ITEM,
					SD1.D1_EMISSAO,
					SD1.D1_COD,
					SD1.D1_LOTECTL,
					SD1.D1_NUMLOTE,
					SD1.D1_QUANT,
					SC9.C9_LOCAL DST_LOCAL,
					SC9.C9_PEDIDO DST_PEDIDO,
					SC9.C9_CLIENTE DST_CLIENT,
					SC9.C9_LOJA DST_LOJA,
					SC9.C9_ITEM DST_ITEM,
					SC9.C9_SEQUEN DST_SEQUEN,
					SC9.C9_PRODUTO DST_PRODUT,
					SC9.C9_LOTECTL DST_LOTECT,
					SC9.C9_NUMLOTE DST_NUMLOT,
					D10.D10_ENDER DST_ENDER,
					(SC9.C9_QTDLIB - CASE WHEN D08B.D08_QTDDIS IS NULL THEN 0 ELSE D08B.D08_QTDDIS END) DST_SALDO,
					'SC9' DST_ORIGEM,
					SC9.C9_DATENT DST_DATENT
			FROM %Table:SD1% SD1
			INNER JOIN %Table:SC6% SC6
			ON SC6.C6_FILIAL = %xFilial:SC6%
			AND SD1.D1_FILIAL = %xFilial:SD1%
			AND SC6.C6_PEDCOM = SD1.D1_PEDIDO
			AND SC6.C6_ITPC = SD1.D1_ITEMPC
			AND SC6.C6_PRODUTO = SD1.D1_COD
			AND SC6.C6_ITPC <> ' '
			AND SC6.C6_PRODUTO <> ' '
			AND SC6.%NotDel%
			INNER JOIN %Table:SC9% SC9
			ON SC9.C9_FILIAL =  %xFilial:SC9%
			AND SC6.C6_FILIAL = %xFilial:SC6%
			AND SC9.C9_PEDIDO = SC6.C6_NUM
			AND SC9.C9_ITEM = SC6.C6_ITEM
			AND SC9.C9_PRODUTO = SC6.C6_PRODUTO
			AND SC9.C9_BLEST = '02'
			AND SC9.C9_BLCRED = '  '
			AND SC9.C9_NFISCAL = ' '
			AND SC9.D_E_L_E_T_ = ' '
			LEFT JOIN ( SELECT D08A.D08_LOCAL,
								D08A.D08_PEDIDO,
								D08A.D08_ITEM,
								D08A.D08_SEQUEN,
								D08A.D08_PRODUT,
								SUM(D08A.D08_QTDDIS) D08_QTDDIS
						FROM %Table:D08% D08A
						INNER JOIN %Table:D06% D06A
						ON D06A.D06_FILIAL = %xFilial:D06%
						AND D08A.D08_FILIAL = %xFilial:D08%
						AND D06A.D06_CODDIS = D08A.D08_CODDIS
						AND D06A.D06_SITDIS = '2'
						AND D06A.%NotDel%
						WHERE D08A.D08_FILIAL = %xFilial:D08%
						AND D08A.%NotDel%
						GROUP BY D08A.D08_LOCAL,
									D08A.D08_PEDIDO,
									D08A.D08_ITEM,
									D08A.D08_SEQUEN,
									D08A.D08_PRODUT) D08B
			ON D08B.D08_PEDIDO = SC9.C9_PEDIDO
			AND D08B.D08_ITEM = SC9.C9_ITEM
			AND D08B.D08_SEQUEN = SC9.C9_SEQUEN
			AND D08B.D08_PRODUT = SC9.C9_PRODUTO
			LEFT JOIN %Table:D10% D10
			ON D10.D10_FILIAL = %xFilial:D10%
			AND SC9.C9_FILIAL = %xFilial:SC9%
			AND D10.D10_CLIENT = SC9.C9_CLIENTE
			AND D10.D10_LOJA = SC9.C9_LOJA
			AND D10.D10_LOCAL = SC9.C9_LOCAL
			AND D10.%NotDel%
			WHERE SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_DOC = %Exp:cDocumento%
			AND SD1.D1_SERIE = %Exp:cSerie%
			AND SD1.D1_FORNECE = %Exp:cFornec%
			AND SD1.D1_LOJA = %Exp:cLoja%
			AND SD1.D1_PEDIDO <> ' '
			AND SD1.D1_ITEMPC <> ' '
			AND SD1.D1_TES = ' '
			AND SD1.D1_TIPO = 'N'
			AND SD1.D1_CODDIS = ' '
			AND SD1.%NotDel%
			AND NOT EXISTS (SELECT 1
							FROM %Table:D08% D08
							INNER JOIN %Table:D06% D06
							ON D06.D06_FILIAL = %xFilial:D06%
							AND D08.D08_FILIAL = %xFilial:D08%
							AND D06.D06_CODDIS = D08.D08_CODDIS
							AND D06.D06_SITDIS IN ('1','2')
							AND D06.%NotDel%
							WHERE D08.D08_FILIAL = %xFilial:D08%
							AND SC9.C9_FILIAL = %xFilial:SC9%
							AND D08.D08_LOCAL = SC9.C9_LOCAL
							AND D08.D08_PEDIDO = SC9.C9_PEDIDO
							AND D08.D08_ITEM = SC9.C9_ITEM
							AND D08.D08_SEQUEN = SC9.C9_SEQUEN
							AND D08.D08_PRODUT = SC9.C9_PRODUTO
							AND ((D08.D08_QTDDIS = SC9.C9_QTDLIB AND D06.D06_SITDIS = '2') OR D06.D06_SITDIS = '1')
							AND D08.%NotDel% )
			AND NOT EXISTS (SELECT 1
							FROM %Table:DCX% DCX
							INNER JOIN %Table:DCW% DCW
							ON DCW.DCW_FILIAL = %xFilial:DCW%
							AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ
							AND DCW.DCW_SITEMB IN ('1','2','3','4','5')
							AND DCW.%NotDel%
							WHERE DCX.DCX_FILIAL = %xFilial:DCX%
							AND DCX.DCX_DOC = SD1.D1_DOC
							AND DCX.DCX_SERIE = SD1.D1_SERIE
							AND DCX.DCX_FORNEC = SD1.D1_FORNECE
							AND DCX.DCX_LOJA = SD1.D1_LOJA
							AND DCX.%NotDel% )
			UNION ALL
			SELECT SD1.D1_LOCAL,
					SD1.D1_DOC,
					SD1.D1_SERIE,
					SD1.D1_CODDIS,
					SD1.D1_FORNECE,
					SD1.D1_LOJA,
					SD1.D1_ITEM,
					SD1.D1_EMISSAO,
					SD1.D1_COD,
					SD1.D1_LOTECTL,
					SD1.D1_NUMLOTE,
					SD1.D1_QUANT,
					D0M.D0M_LOCAL DST_LOCAL,
					D0M.D0M_CODPLN DST_PEDIDO,
					D0M.D0M_CLIENT DST_CLIENT,
					D0M.D0M_LOJA DST_LOJA,
					D0M.D0M_ITEM DST_ITEM,
					'01' DST_SEQUEN,
					D0M.D0M_PRODUT DST_PRODUT,
					D0M.D0M_LOTECT DST_LOTECT,
					D0M.D0M_NUMLOT DST_NUMLOT,
					D10.D10_ENDER DST_ENDER,
					(D0M.D0M_QTDDEM - CASE WHEN D08B.D08_QTDDIS IS NULL THEN 0 ELSE D08B.D08_QTDDIS END) DST_SALDO,
					'D0M' DST_ORIGEM,
					D0M.D0M_DATENT DST_DATENT
			FROM %Table:SD1% SD1
			INNER JOIN %Table:D0M% D0M
			ON D0M.D0M_FILIAL = %xFilial:D0M%
			AND SD1.D1_FILIAL = %xFilial:SD1%
			AND D0M.D0M_PEDCOM = SD1.D1_PEDIDO
			AND D0M.D0M_ITPC = SD1.D1_ITEMPC
			AND D0M.D0M_PRODUT = SD1.D1_COD
			AND (D0M.D0M_QTDDEM - D0M.D0M_QTDDIS) > 0
			AND D0M.%NotDel%
			INNER JOIN %Table:D0L% D0L
			ON D0L.D0L_FILIAL = %xFilial:D0L%
			AND D0M.D0M_FILIAL = %xFilial:D0M%
			AND D0L.D0L_CODPLN = D0M.D0M_CODPLN
			AND D0L.D0L_STATUS NOT IN ('3','4')
			AND D0L.%NotDel%
			LEFT JOIN (SELECT D08A.D08_LOCAL,
								D08A.D08_PEDIDO,
								D08A.D08_ITEM,
								D08A.D08_SEQUEN,
								D08A.D08_PRODUT,
								SUM(D08A.D08_QTDDIS) D08_QTDDIS
						FROM %Table:D08% D08A
						INNER JOIN %Table:D06% D06A
						ON D06A.D06_FILIAL = %xFilial:D06%
						AND D08A.D08_FILIAL = %xFilial:D08%
						AND D06A.D06_CODDIS = D08A.D08_CODDIS
						AND D06A.D06_SITDIS = '2'
						AND D06A.%NotDel%
						WHERE D08A.D08_FILIAL = %xFilial:D08%
						AND D08A.%NotDel%
						GROUP BY D08A.D08_LOCAL,
									D08A.D08_PEDIDO,
									D08A.D08_ITEM,
									D08A.D08_SEQUEN,
									D08A.D08_PRODUT) D08B
			ON D08B.D08_PEDIDO = D0M.D0M_CODPLN
			AND D08B.D08_ITEM = D0M.D0M_ITEM
			AND D08B.D08_SEQUEN = '01'
			AND D08B.D08_PRODUT = D0M.D0M_PRODUT
			LEFT JOIN %Table:D10% D10
			ON D10.D10_FILIAL = %xFilial:D10%
			AND D0M.D0M_FILIAL = %xFilial:D0M%
			AND D10.D10_CLIENT = D0M.D0M_CLIENT
			AND D10.D10_LOJA = D0M.D0M_LOJA
			AND D10.D10_LOCAL = D0M.D0M_LOCAL
			AND D10.%NotDel%
			WHERE SD1.D1_FILIAL = %xFilial:SD1%
			AND SD1.D1_DOC = %Exp:cDocumento%
			AND SD1.D1_SERIE = %Exp:cSerie%
			AND SD1.D1_FORNECE = %Exp:cFornec%
			AND SD1.D1_LOJA = %Exp:cLoja%
			AND SD1.D1_PEDIDO <> ' '
			AND SD1.D1_ITEMPC <> ' '
			AND SD1.D1_TES = ' '
			AND SD1.D1_TIPO = 'N'
			AND SD1.D1_CODDIS = ' '
			AND SD1.%NotDel%
			AND NOT EXISTS (SELECT 1
							FROM %Table:D08% D08
							INNER JOIN %Table:D06% D06
							ON D06.D06_FILIAL = %xFilial:D06%
							AND D08.D08_FILIAL = %xFilial:D08%
							AND D06.D06_CODDIS = D08.D08_CODDIS
							AND D06.D06_SITDIS IN ('1','2')
							AND D06.%NotDel%
							WHERE D08.D08_FILIAL = %xFilial:D08%
							AND D0M.D0M_FILIAL = %xFilial:D0M%
							AND D08.D08_LOCAL = D0M.D0M_LOCAL
							AND D08.D08_PEDIDO = D0M.D0M_CODPLN
							AND D08.D08_ITEM = D0M.D0M_ITEM
							AND D08.D08_SEQUEN = '01'
							AND D08.D08_PRODUT = D0M.D0M_PRODUT
							AND ((D08.D08_QTDDIS = D0M.D0M_QTDDEM AND D06.D06_SITDIS = '2') OR D06.D06_SITDIS = '1')
							AND D08.%NotDel% )
			AND NOT EXISTS (SELECT 1
							FROM %Table:DCX% DCX
							INNER JOIN %Table:DCW% DCW
							ON DCW.DCW_FILIAL = %xFilial:DCW%
							AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ
							AND DCW.DCW_SITEMB IN ('1','2','3','4','5')
							AND DCW.%NotDel%
							WHERE DCX.DCX_FILIAL = %xFilial:DCX%
							AND DCX.DCX_DOC = SD1.D1_DOC
							AND DCX.DCX_SERIE = SD1.D1_SERIE
							AND DCX.DCX_FORNEC = SD1.D1_FORNECE
							AND DCX.DCX_LOJA = SD1.D1_LOJA
							AND DCX.%NotDel% )
		EndSql
		TcSetField(cAliasNew,'DST_DATENT','D')
		If (cAliasNew)->(!Eof())
			Begin Transaction
				Do While lRet .And. (cAliasNew)->(!Eof())
					// Pula produtos que já estão em uma distribuição
					If !Empty((cAliasNew)->D1_CODDIS)
						(cAliasNew)->(dbSkip())
						Loop
					EndIf
					// Verifica se produto possue controle WMS
					If !IntWMS((cAliasNew)->D1_COD)
						(cAliasNew)->(dbSkip())
						Loop
					EndIf
					If (cAliasNew)->DST_SALDO == 0
						(cAliasNew)->(dbSkip())
						Loop
					EndIf
					// Atribui dados distribuicao
					Self:oMntDist:SetCodDis(cCodDis)
					Self:oMntDist:SetTipoDis("2")
					Self:oMntDist:SetSitDis("2")
					If !Self:oMntDist:LoadData()
						If !Self:oMntDist:RecordD06()
							lRet := .F.
						EndIf
					EndIf
					cCodDis := Self:oMntDist:GetCodDis()
					If lRet
						// Atribui dados documentos distribuidos
						oDistDoc:SetCodDis(Self:oMntDist:GetCodDis())
						oDistDoc:SetArmazem((cAliasNew)->D1_LOCAL)
						oDistDoc:SetDocto((cAliasNew)->D1_DOC)
						oDistDoc:SetSerie((cAliasNew)->D1_SERIE)
						//oDistDoc:SetSerDoc((cAliasNew)->D1_SERIE)
						oDistDoc:SetFornec((cAliasNew)->D1_FORNECE)
						oDistDoc:SetLoja((cAliasNew)->D1_LOJA)
						oDistDoc:SetItem((cAliasNew)->D1_ITEM)
						oDistDoc:SetDatEmis(StoD((cAliasNew)->D1_EMISSAO))
						oDistDoc:SetProduto((cAliasNew)->D1_COD)
						oDistDoc:SetLoteCtl((cAliasNew)->D1_LOTECTL)
						oDistDoc:SetNumLote((cAliasNew)->D1_NUMLOTE)
						oDistDoc:SetQtdEnt((cAliasNew)->D1_QUANT)
						If !oDistDoc:LoadData()
							If oDistDoc:RecordD07()
								oDistProd:SetCodDis(Self:oMntDist:GetCodDis())
								oDistProd:SetArmazem(oDistDoc:GetArmazem())
								oDistProd:SetProduto(oDistDoc:GetProduto())
								If !oDistProd:LoadData()
									oDistProd:SetQtdAdi(oDistDoc:GetQtdEnt())
									If !oDistProd:RecordD09()
										lRet := .F.
									EndIf
								Else
									oDistProd:SetQtdAdi(oDistProd:GetQtdAdi() + oDistDoc:GetQtdEnt())
									If !oDistProd:UpdateD09()
										lRet := .F.
									EndIf
								EndIf
							Else
								lRet := .F.
							EndIf
						EndIf
					EndIf
					If lRet
						// Atribui dados pedidos distribuidos
						Self:cArmazem  := (cAliasNew)->DST_LOCAL
						Self:cPedido   := (cAliasNew)->DST_PEDIDO
						Self:cCliente  := (cAliasNew)->DST_CLIENT
						Self:cLoja     := (cAliasNew)->DST_LOJA
						Self:cItem     := (cAliasNew)->DST_ITEM
						Self:cSequen   := (cAliasNew)->DST_SEQUEN
						Self:cProduto  := (cAliasNew)->DST_PRODUT
						Self:cLoteCtl  := (cAliasNew)->DST_LOTECT
						Self:cNumLote  := (cAliasNew)->DST_NUMLOT
						Self:cOrigem   := (cAliasNew)->DST_ORIGEM
						Self:cEndereco := (cAliasNew)->DST_ENDER
						Self:nQtdVen   := (cAliasNew)->DST_SALDO
						Self:dDatEnt   := (cAliasNew)->DST_DATENT
						If !Self:LoadData()
							If !Self:RecordD08()
								lRet := .F.
							EndIf
						EndIf
					EndIf
					(cAliasNew)->(dbSkip())
				EndDo
				(cAliasNew)->(dbCloseArea())
				// Realiza a distribuição de acordo com o parametro MV_WMSDPCA
				// (0=Não Utiliza;1=Automático Direto;2=Automático Proporcional;3=Automático Unidade + Proporcional)
				If lRet .And. nWmsDpCa > 0
					oModelD06 := FWLoadModel("WMSA325A")
					D06->(dbSetOrder(1))
					D06->(dbSeek(xFilial("D06")+Self:oMntDist:GetCodDis()))
					oModelD06:SetOperation( MODEL_OPERATION_UPDATE )
					oModelD06:Activate()
					// Função com a regra da distribuição das quantidades
					WMSA325ART(oModelD06,nWmsDpCa)
					// Validação do modelo de dados
					// Monta os dados da D0F no valid
					If oModelD06:VldData()
						// Efetivação dos dados
						// Quebra a SD1 no commit
						oModelD06:CommitData()
					Else
						// Erro do modelo de dados
						Self:cErro := oModelD06:GetErrorMessage()[6]
						lRet := .F.
					EndIf
					oModelD06:Deactivate()
				EndIf
				If !lRet
					DisarmTransaction()
				EndIf
			End Transaction
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0005 // Documento inválido!
	EndIf
	RestArea(aAreaSD1)
	RestArea(aAreaSC9)
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} CancelDist
Método para cancelar a distribuição de produtos WMS.
@author amanda.vieira
@since 04/11/2016
@version 1.0
@param nRecno,  numérico,  (Recno da SF1)
@param cCodDis, caractere, (Código da Distribuição, utilizado quando cancela uma distribuição não automática)
@param lAuto,   lógico,    (Indica se é o cancelamento de uma distribuição automática)
/*/
//--------------------------------------------------
METHOD CancelDist(nRecno,cCodDis,lAuto) CLASS WMSDTCDistribuicaoProdutosPedidosItens
Local lRet       := .T.
Local aAreaD06   := D06->(GetArea())
Local aAreaSD1   := SD1->(GetArea())
Local oPlDiItDis := Nil
Local cAliasQry  := Nil
Local cAliasD07  := Nil
Local cAliasD08  := Nil
Local cAliasD09  := Nil
Local cAliasD0F  := Nil
Local cAliasSD1  := Nil
Local cCodDisVz  := Space(TamSx3("D1_CODDIS")[1])
Local nIcmsPad   := 0
Local nICMPAD    := SuperGetMV("MV_ICMPAD",.F.,0)
Default lAuto    := .T.
	If !Empty(nRecno)
		Begin Transaction
			cAliasQry := GetNextAlias()
			If lAuto
				BeginSql Alias cAliasQry
					SELECT SD1.R_E_C_N_O_ RECNOSD1,
							SD1.D1_DOC,
							SD1.D1_FORNECE,
							SD1.D1_LOJA,
							SD1.D1_COD,
							SD1.D1_ITEM,
							SD1.D1_TES,
							SD1.D1_QUANT,
							D07.D07_QTDENT,
							D07.D07_QTDDIS,
							D06.R_E_C_N_O_ RECNOD06
					FROM %Table:SF1% SF1
					INNER JOIN %Table:SD1% SD1
					ON SD1.D1_FILIAL  = %xFilial:SD1%
					AND SD1.D1_DOC     = SF1.F1_DOC
					AND SD1.D1_SERIE   = SF1.F1_SERIE
					AND SD1.D1_FORNECE = SF1.F1_FORNECE
					AND SD1.D1_LOJA    = SF1.F1_LOJA
					AND SD1.D1_CODDIS <> %Exp:cCodDisVz%
					AND SD1.%NotDel%
					INNER JOIN %Table:D06% D06
					ON D06.D06_FILIAL = %xFilial:D06%
					AND D06.D06_CODDIS = SD1.D1_CODDIS
					AND D06.D06_TIPDIS = '2'
					AND D06.%NotDel%
					INNER JOIN %Table:D07% D07
					ON D07.D07_FILIAL = %xFilial:D07%
					AND D07.D07_CODDIS = SD1.D1_CODDIS
					AND D07.D07_DOC = SD1.D1_DOC
					AND D07.D07_SERIE = SD1.D1_SERIE
					AND D07.D07_FORNEC = SD1.D1_FORNECE
					AND D07.D07_LOJA = SD1.D1_LOJA
					AND D07.D07_PRODUT = SD1.D1_COD
					AND D07.D07_ITEM = SD1.D1_ITEM
					AND D07.%NotDel%
					WHERE SF1.R_E_C_N_O_ = %Exp:nRecno%
					AND SF1.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT SD1.R_E_C_N_O_ RECNOSD1,
							SD1.D1_DOC,
							SD1.D1_FORNECE,
							SD1.D1_LOJA,
							SD1.D1_COD,
							SD1.D1_ITEM,
							SD1.D1_TES,
							SD1.D1_QUANT,
							D07.D07_QTDENT,
							D07.D07_QTDDIS,
							D06.R_E_C_N_O_ RECNOD06
					FROM %Table:SF1% SF1
					INNER JOIN %Table:SD1% SD1
					ON SD1.D1_FILIAL = %xFilial:SD1%
					AND SD1.D1_DOC = SF1.F1_DOC
					AND SD1.D1_SERIE = SF1.F1_SERIE
					AND SD1.D1_FORNECE = SF1.F1_FORNECE
					AND SD1.D1_LOJA = SF1.F1_LOJA
					AND SD1.D1_CODDIS = %Exp:cCodDis%
					AND SD1.%NotDel%
					INNER JOIN %Table:D06% D06
					ON D06.D06_FILIAL = %xFilial:D06%
					AND D06.D06_CODDIS = SD1.D1_CODDIS
					AND D06.%NotDel%
					INNER JOIN %Table:D07% D07
					ON D07.D07_FILIAL = %xFilial:D07%
					AND D07.D07_CODDIS = SD1.D1_CODDIS
					AND D07.D07_DOC    = SD1.D1_DOC
					AND D07.D07_SERIE  = SD1.D1_SERIE
					AND D07.D07_FORNEC = SD1.D1_FORNECE
					AND D07.D07_LOJA   = SD1.D1_LOJA
					AND D07.D07_PRODUT = SD1.D1_COD
					AND D07.D07_ITEM   = SD1.D1_ITEM
					AND D07.%NotDel%
					WHERE SF1.R_E_C_N_O_ = %Exp:cValToChar(nRecno)%
					AND SF1.%NotDel%
				EndSql
			EndIf
			If (cAliasQry)->(!Eof())
				D06->(dbGoTo( (cAliasQry)->RECNOD06 ))
				//Ajusta quantidade distribuida do plano de distribuição
				cAliasD08 := GetNextAlias()
				BeginSql Alias cAliasD08
					SELECT D08.R_E_C_N_O_ RECNOD08
					FROM %Table:D08% D08
					WHERE D08.D08_FILIAL = %xFilial:D08%
					AND D08.D08_CODDIS = %Exp:D06->D06_CODDIS%
					AND D08.D08_ORIGEM = 'D0M'
					AND D08.%NotDel%
				EndSql
				If (cAliasD08)->(!Eof())
					oPlDiItDis := WMSDTCPlanoDistribuicaoItensDistribuidos():New()
				EndIf
				Do While (cAliasD08)->(!Eof())
					D08->(dbGoTo( (cAliasD08)->RECNOD08 ))
					oPlDiItDis:SetCodPln(D08->D08_PEDIDO)
					oPlDiItDis:SetItem(D08->D08_ITEM)
					oPlDiItDis:SetCodDis(D08->D08_CODDIS)
					If oPlDiItDis:LoadData()
						oPlDiItDis:DeleteD0P()
					EndIf
					(cAliasD08)->(dbSkip())
				EndDo
				(cAliasD08)->(dbCloseArea())
				//Altera a situação da distribuição para cancelada e exclui quando altomática
				If !lAuto
					RecLock('D06',.F.)
					D06->D06_SITDIS := "3"
					D06->(MsUnlock())
				Else
					// Deleta D07
					cAliasD07 := GetNextAlias()
					BeginSql Alias cAliasD07
						SELECT D07.R_E_C_N_O_ RECNOD07
						FROM %Table:D07% D07
						WHERE D07.D07_FILIAL = %xFilial:D07%
						AND D07.D07_CODDIS = %Exp:D06->D06_CODDIS%
						AND D07.%NotDel%
					EndSql
					Do While (cAliasD07)->(!Eof())
						D07->(dbGoTo( (cAliasD07)->RECNOD07 ))
						RecLock('D07',.F.)
						D07->(dbDelete())
						D07->(MsUnlock())
						(cAliasD07)->(dbSkip())
					EndDo
					(cAliasD07)->(dbCloseArea())
					// Deleta D08
					cAliasD08 := GetNextAlias()
					BeginSql Alias cAliasD08
						SELECT D08.R_E_C_N_O_ RECNOD08
						FROM %Table:D08% D08
						WHERE D08.D08_FILIAL = %xFilial:D08%
						AND D08.D08_CODDIS = %Exp:D06->D06_CODDIS%
						AND D08.%NotDel%
					EndSql
					Do While (cAliasD08)->(!Eof())
						D08->(dbGoTo( (cAliasD08)->RECNOD08))
						// Deleta D08
						RecLock('D08',.F.)
						D08->(dbDelete())
						D08->(MsUnlock())
						(cAliasD08)->(dbSkip())
					EndDo
					(cAliasD08)->(dbCloseArea())
					// Deleta D09
					cAliasD09 := GetNextAlias()
					BeginSql Alias cAliasD09
						SELECT D09.R_E_C_N_O_ RECNOD09
						FROM %Table:D09% D09
						WHERE D09.D09_FILIAL = %xFilial:D09%
						AND D09.D09_CODDIS = %Exp:D06->D06_CODDIS%
						AND D09.%NotDel%
					EndSql
					Do While (cAliasD09)->(!Eof())
						D09->(dbGoTo( (cAliasD09)->RECNOD09 ))
						RecLock('D09',.F.)
						D09->(dbDelete())
						D09->(MsUnlock())
						(cAliasD09)->(dbSkip())
					EndDo
					(cAliasD09)->(dbCloseArea())
					// Deleta D0F
					cAliasD0F := GetNextAlias()
					BeginSql Alias cAliasD0F
						SELECT D0F.R_E_C_N_O_ RECNOD0F
						FROM %Table:D0F% D0F
						WHERE D0F.D0F_FILIAL = %xFilial:D0F%
						AND D0F.D0F_CODDIS = %Exp:D06->D06_CODDIS%
						AND D0F.%NotDel%
					EndSql
					Do While (cAliasD0F)->(!Eof())
						D0F->(dbGoTo( (cAliasD0F)->RECNOD0F ))
						RecLock('D0F',.F.)
						D0F->(dbDelete())
						D0F->(MsUnlock())
						(cAliasD0F)->(dbSkip())
					EndDo
					(cAliasD0F)->(dbCloseArea())
					// Deleta D06
					RecLock('D06',.F.)
					D06->D06_SITDIS := "3"
					D06->(dbDelete())
					D06->(MsUnlock())
				EndIf
			EndIf
			Do While (cAliasQry)->(!Eof())
				//Verifica se quebrou a SD1, então apaga a SD1 duplicada e ajusta as quantidades
				If Empty((cAliasQry)->D1_TES)
					If (cAliasQry)->D1_QUANT < (cAliasQry)->D07_QTDENT
						cAliasSD1 := GetNextAlias()
						BeginSql Alias cAliasSD1
							SELECT SD1.R_E_C_N_O_ RECNOSD1,
									SD1.D1_QUANT
							FROM %Table:SD1% SD1
							WHERE SD1.D1_FILIAL = %xFilial:SD1%
							AND SD1.%NotDel%
							AND SD1.D1_DOC = %Exp:(cAliasQry)->D1_DOC%
							AND SD1.D1_FORNECE = %Exp:(cAliasQry)->D1_FORNECE%
							AND SD1.D1_LOJA = %Exp:(cAliasQry)->D1_LOJA%
							AND SD1.D1_COD = %Exp:(cAliasQry)->D1_COD%
							AND SD1.D1_ITEM > %Exp:(cAliasQry)->D1_ITEM%
							AND NOT EXISTS (SELECT 1
											FROM %Table:D07% D07
											WHERE D07.D07_FILIAL = %xFilial:D07%
											AND D07.D07_DOC = SD1.D1_DOC
											AND D07.D07_SERIE = SD1.D1_SERIE
											AND D07.D07_FORNEC = SD1.D1_FORNECE
											AND D07.D07_LOJA = SD1.D1_LOJA
											AND D07.D07_PRODUT = SD1.D1_COD
											AND D07.D07_ITEM = SD1.D1_ITEM
											AND D07.%NotDel% )
							ORDER BY SD1.D1_ITEM DESC
						EndSql
						Do While !(cAliasSD1)->(Eof())
							If ((cAliasQry)->D1_QUANT + (cAliasSD1)->D1_QUANT) == (cAliasQry)->D07_QTDENT
								SD1->(dbGoTo( (cAliasSD1)->RECNOSD1 ))
								RecLock('SD1',.F.)
								SD1->( dbDelete() )
								SD1->(MsUnlock())
							EndIf
							(cAliasSD1)->( dbSkip() )
						EndDo
						(cAliasSD1)->( dbCloseArea() )
						// Atualiza dados
						SD1->(dbGoTo( (cAliasQry)->RECNOSD1 ))
						SB1->(dbSetOrder(1)) // B1_FILIAL+B1_COD
						SB1->(dbSeek(xFilial('SB1')+SD1->D1_COD))
						nIcmsPad := If(!Empty(SB1->B1_PICM),SB1->B1_PICM,nICMPAD)/100
						RecLock('SD1',.F.)
						SD1->D1_QUANT   := (cAliasQry)->D07_QTDENT
						SD1->D1_TOTAL   := SD1->D1_QUANT    * SD1->D1_VUNIT
						SD1->D1_QTSEGUM := (SD1->D1_QTSEGUM * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_PESO    := (SD1->D1_PESO    * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_BASEICM := (SD1->D1_BASEICM * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_BRICMS  := (SD1->D1_BRICMS  * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_VALDESC := (SD1->D1_VALDESC * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_BASEIPI := (SD1->D1_BASEIPI * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_II      := (SD1->D1_II      * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_VALCMAJ := (SD1->D1_VALCMAJ * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_BASIMP5 := (SD1->D1_BASIMP5 * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_BASIMP6 := (SD1->D1_BASIMP6 * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_VALIMP5 := (SD1->D1_VALIMP5 * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_VALIMP6 := (SD1->D1_VALIMP6 * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_DESPESA := (SD1->D1_DESPESA * (cAliasQry)->D07_QTDENT) / (cAliasQry)->D07_QTDDIS
						SD1->D1_VALIPI  := (SD1->D1_BASEIPI * (SD1->D1_IPI / 100))
						SD1->D1_VALICM  := (SD1->D1_BASEICM * (SD1->D1_PICM / 100))
						SD1->D1_VALICM  := (SD1->D1_BASEICM * (SD1->D1_PICM / 100))
						SD1->D1_ICMSRET := (SD1->D1_BRICMS * nIcmsPad) - SD1->D1_VALICM
						SD1->D1_SERVIC  := ""
						SD1->D1_ENDER   := ""
						SD1->D1_CODDIS  := ""
						SD1->(MsUnlock())
					Else
						SD1->(dbGoTo( (cAliasQry)->RECNOSD1 ))
						RecLock('SD1',.F.)
						SD1->D1_SERVIC  := ""
						SD1->D1_ENDER   := ""
						SD1->D1_CODDIS  := ""
						SD1->(MsUnlock())
					EndIf
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		End Transaction
	Else
		lRet := .F.
		Self:cErro := STR0005 // Documento inválido!
	EndIf
	RestArea(aAreaD06)
	RestArea(aAreaSD1)
Return lRet
