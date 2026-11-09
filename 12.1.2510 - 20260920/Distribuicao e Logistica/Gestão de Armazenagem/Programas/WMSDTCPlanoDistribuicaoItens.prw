#Include "Totvs.ch"  
#INCLUDE "FWMVCDEF.CH"
#Include "WMSDTCPlanoDistribuicaoItens.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0050
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0051()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCPlanoDistribuicaoItens
Classe distribuição de produtos, pedidos e itens
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCPlanoDistribuicaoItens FROM LongNameClass
	// Data
	DATA oPlnDist // D0L
	DATA cItem
	DATA cCliente
	DATA cLoja
	DATA cArmazem
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA nQtdDem
	DATA nQtdDe2
	DATA nQtdDis
	DATA nQtdDi2
	DATA cPedCom
	DATA cItemPC
	DATA dDataEnt
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD GoToD0M(nRecno)
	METHOD RecordD0M()
	METHOD UpdateD0M()
	METHOD DeleteD0M()
	// Setters
	METHOD SetCodPln(cCodPln)
	METHOD SetItem(cItem)
	METHOD SetCliente(cCliente)
	METHOD SetLoja(cLoja)
	METHOD SetArmazem(cArmazem)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetQtdDem(nQtdDem)
	METHOD SetQtdDe2(nQtdDe2)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetQtdDi2(nQtdDi2)
	METHOD SetDataEnt(dDataEnt)
	METHOD SetPedCom(cPedCom)
	METHOD SetItemPC(cItemPC)
	// Getters
	METHOD GetCodPln()
	METHOD GetItem()
	METHOD GetCliente()
	METHOD GetLoja()
	METHOD GetArmazem()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetQtdDem()
	METHOD GetQtdDe2()
	METHOD GetQtdDis()
	METHOD GetQtdDi2()
	METHOD GetPedCom()
	METHOD GetItemPC()
	METHOD GetDataEnt()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
	METHOD PlnDisAuto(aPlnDist,aErro,cCodPln)
	METHOD UpdStatus()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCPlanoDistribuicaoItens
	Self:oPlnDist  := WMSDTCPlanoDistribuicao():New()
	Self:cItem     := PadR("", TamSx3("D0M_ITEM")[1])
	Self:cCliente  := PadR("", TamSx3("D0M_CLIENT")[1])
	Self:cLoja     := PadR("", TamSx3("D0M_LOJA")[1])
	Self:cArmazem  := PadR("", TamSx3("D0M_LOCAL")[1])
	Self:cProduto  := PadR("", TamSx3("D0M_PRODUT")[1])
	Self:cLoteCtl  := PadR("", TamSx3("D0M_LOTECT")[1])
	Self:cNumLote  := PadR("", TamSx3("D0M_NUMLOT")[1])
	Self:cPedCom   := PadR("", TamSx3("D0M_PEDCOM")[1])
	Self:cItemPC   := PadR("", TamSx3("D0M_ITPC")[1])
	Self:dDataEnt  := CtoD("  /  /    ")
	Self:nQtdDem   := 0
	Self:nQtdDe2   := 0
	Self:nQtdDis   := 0
	Self:nQtdDi2   := 0
	Self:cErro     := ""
	Self:nRecno    := 0
Return

METHOD Destroy() CLASS WMSDTCPlanoDistribuicaoItens
	//Mantido para compatibilidade
Return

METHOD GoToD0M(nRecno) CLASS WMSDTCPlanoDistribuicaoItens
	Self:nRecno := nRecno
Return Self:LoadData(0)

METHOD LoadData(nIndex) CLASS WMSDTCPlanoDistribuicaoItens
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aD0M_QTDDEM := TamSx3("D0M_QTDDEM")
Local aD0M_QTDDIS := TamSx3("D0M_QTDDIS")
Local aD0M_QTDDE2 := TamSx3("D0M_QTDDE2")
Local aD0M_QTDDI2 := TamSx3("D0M_QTDDI2")
Local aData       := TamSx3("D0L_DATGER")
Local aAreaD0M    := D0M->(GetArea())
Local cAliasD0M   := Nil

Default nIndex    := 1

	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0M_FILIAL+D0M_CODPLN+D0M_ITEM
			If Empty(Self:GetCodPln()) .Or. Empty(Self:cItem)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0M  := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0M
					SELECT D0M.D0M_CODPLN,
							D0M.D0M_ITEM,
							D0M.D0M_CLIENT,
							D0M.D0M_LOJA,
							D0M.D0M_LOCAL,
							D0M.D0M_PRODUT,
							D0M.D0M_LOTECT,
							D0M.D0M_NUMLOT,
							D0M.D0M_QTDDEM,
							D0M.D0M_QTDDIS,
							D0M.D0M_QTDDE2,
							D0M.D0M_QTDDI2,
							D0M.D0M_DATENT,
							D0M.D0M_PEDCOM,
							D0M.D0M_ITPC,
							D0M.R_E_C_N_O_ RECNOD0M
					FROM %Table:D0M% D0M
					WHERE D0M.D0M_FILIAL = %xFilial:D0M%
					AND D0M.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0M.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0M
					SELECT D0M.D0M_CODPLN,
							D0M.D0M_ITEM,
							D0M.D0M_CLIENT,
							D0M.D0M_LOJA,
							D0M.D0M_LOCAL,
							D0M.D0M_PRODUT,
							D0M.D0M_LOTECT,
							D0M.D0M_NUMLOT,
							D0M.D0M_QTDDEM,
							D0M.D0M_QTDDIS,
							D0M.D0M_QTDDE2,
							D0M.D0M_QTDDI2,
							D0M.D0M_DATENT,
							D0M.D0M_PEDCOM,
							D0M.D0M_ITPC,
							D0M.R_E_C_N_O_ RECNOD0M
					FROM %Table:D0M% D0M
					WHERE D0M.D0M_FILIAL = %xFilial:D0M%
					AND D0M.D0M_CODPLN = %Exp:Self:GetCodPln()%
					AND D0M.D0M_ITEM = %Exp:Self:cItem%
					AND D0M.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD0M,'D0M_QTDDEM','N',aD0M_QTDDEM[1],aD0M_QTDDEM[2])
		TCSetField(cAliasD0M,'D0M_QTDDIS','N',aD0M_QTDDIS[1],aD0M_QTDDIS[2])
		TCSetField(cAliasD0M,'D0M_QTDDE2','N',aD0M_QTDDE2[1],aD0M_QTDDE2[2])
		TCSetField(cAliasD0M,'D0M_QTDDI2','N',aD0M_QTDDI2[1],aD0M_QTDDI2[2])
		TCSetField(cAliasD0M,'D0M_DATENT','D',aData[1],aData[2])
		If (lRet := (cAliasD0M)->(!Eof()))
			Self:SetCodPln((cAliasD0M)->D0M_CODPLN)
			Self:oPlnDist:LoadData()
			//
			Self:cItem     := (cAliasD0M)->D0M_ITEM
			Self:cCliente  := (cAliasD0M)->D0M_CLIENT
			Self:cLoja     := (cAliasD0M)->D0M_LOJA
			Self:cArmazem  := (cAliasD0M)->D0M_LOCAL
			Self:cProduto  := (cAliasD0M)->D0M_PRODUT
			Self:cLoteCtl  := (cAliasD0M)->D0M_LOTECT
			Self:cNumLote  := (cAliasD0M)->D0M_NUMLOT
			Self:nQtdDem   := (cAliasD0M)->D0M_QTDDEM
			Self:nQtdDe2   := (cAliasD0M)->D0M_QTDDE2
			Self:nQtdDis   := (cAliasD0M)->D0M_QTDDIS
			Self:nQtdDi2   := (cAliasD0M)->D0M_QTDDI2
			Self:cPedCom   := (cAliasD0M)->D0M_PEDCOM
			Self:cItemPC   := (cAliasD0M)->D0M_QTDDI2
			Self:dDataEnt  := (cAliasD0M)->D0M_DATENT
			Self:nRecno    := (cAliasD0M)->RECNOD0M
		EndIf
		(cAliasD0M)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0M)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD0M() CLASS WMSDTCPlanoDistribuicaoItens
Local lRet := .T.
	Self:nQtdDe2 := ConvUm(Self:cProduto,Self:nQtdDem,0,2)
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	// D0M_FILIAL+D0M_CODPLN+D0M_ITEM
	If !D0M->(dbSeek(xFilial("D0M")+Self:oPlnDist:GetCodPln()+Self:cItem))
		RecLock('D0M', .T.)
		D0M->D0M_FILIAL := xFilial("D0M")
		D0M->D0M_CODPLN := Self:oPlnDist:GetCodPln()
		D0M->D0M_ITEM   := Self:cItem
		D0M->D0M_CLIENT := Self:cCliente
		D0M->D0M_LOJA   := Self:cLoja
		D0M->D0M_LOCAL  := Self:cArmazem
		D0M->D0M_PRODUT := Self:cProduto
		D0M->D0M_LOTECT := Self:cLoteCtl
		D0M->D0M_NUMLOT := Self:cNumLote
		D0M->D0M_QTDDEM := Self:nQtdDem
		D0M->D0M_QTDDE2 := Self:nQtdDe2
		D0M->D0M_QTDDIS := Self:nQtdDis
		D0M->D0M_QTDDI2 := Self:nQtdDi2
		D0M->D0M_PEDCOM := Self:cPedCom
		D0M->D0M_ITPC   := Self:cItemPC
		D0M->D0M_DATENT := Self:dDataEnt
		D0M->(MsUnLock())
		//--
		Self:nRecno     := D0M->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada
	EndIf
Return lRet

METHOD UpdateD0M() CLASS WMSDTCPlanoDistribuicaoItens
Local lRet := .T.
Local aAreaD0M := D0M->(GetArea())
	// Converte 2UM
	Self:nQtdDe2 := ConvUm(Self:cProduto,Self:nQtdDem,0,2)
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	If !Empty(Self:nRecno)
		D0M->(dbGoTo( Self:nRecno ))
		// Grava D07
		RecLock('D0M', .F.)
		D0M->D0M_QTDDEM := Self:nQtdDem
		D0M->D0M_QTDDE2 := Self:nQtdDe2
		D0M->D0M_QTDDIS := Self:nQtdDis
		D0M->D0M_QTDDI2 := Self:nQtdDi2
		D0M->(MsUnLock())
		// Atualiza status do plano
		Self:UpdStatus()
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0M)
Return lRet

METHOD DeleteD0M() CLASS WMSDTCPlanoDistribuicaoItens
Local lRet := .T.
Local aAreaD0M := D0M->(GetArea())
	If !Empty(Self:nRecno)
		D0M->(dbGoTo( Self:nRecno ))
		// Grava D07
		RecLock('D0M', .F.)
		D0M->(dbDelete())
		D0M->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0M)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodPln(cCodPln) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:oPlnDist:SetCodPln(cCodPln)

METHOD SetItem(cItem) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cItem := PadR(cItem, Len(Self:cItem))

METHOD SetCliente(cCliente) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cCliente := PadR(cCliente, Len(Self:cCliente))

METHOD SetLoja(cLoja) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cLoja := PadR(cLoja, Len(Self:cLoja))

METHOD SetArmazem(cArmazem) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))

METHOD SetProduto(cProduto) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cProduto := PadR(cProduto, Len(Self:cProduto))

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))

METHOD SetNumLote(cNumLote) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))

METHOD SetQtdDem(nQtdDem) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDem := nQtdDem

METHOD SetQtdDe2(nQtdDe2) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDe2 := nQtdDe2

METHOD SetQtdDis(nQtdDis)CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDis := nQtdDis

METHOD SetQtdDi2(nQtdDi2) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDi2 := nQtdDi2

METHOD SetPedCom(cPedCom) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cPedCom := PadR(cPedCom, TamSx3("D0M_PEDCOM")[1])

METHOD SetItemPC(cItemPC) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cItemPC := PadR(cItemPC, TamSx3("D0M_ITPC")[1])

METHOD SetDataEnt(dDataEnt) CLASS WMSDTCPlanoDistribuicaoItens
Return Self:dDataEnt
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodPln() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:oPlnDist:GetCodPln()

METHOD GetItem() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cItem

METHOD GetCliente() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cCliente

METHOD GetLoja() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cLoja

METHOD GetArmazem() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cArmazem

METHOD GetProduto() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cNumLote

METHOD GetQtdDem() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDem

METHOD GetQtdDe2() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDe2

METHOD GetQtdDis()CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDis

METHOD GetQtdDi2() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:nQtdDi2

METHOD GetPedCom() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cPedCom

METHOD GetItemPC() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:cItemPC

METHOD GetDataEnt() CLASS WMSDTCPlanoDistribuicaoItens
Return Self:dDataEnt

METHOD PlnDisAuto(aPlnDist,aErro,cCodPln) CLASS WMSDTCPlanoDistribuicaoItens
Local lRet      := .T.
Local aAreaSA1  := SA1->(GetArea())
Local aAreaNNR  := NNR->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local aAreaSC7  := SC7->(GetArea())
Local nI        := 0
Local cCliente  := ""
Local cLoja     := ""
Local cArmazem  := ""
Local cProduto  := ""
Local cLoteCtl  := ""
Local cNumLote  := ""
Local nQtdDem   := ""
Local nQtdDe2   := ""
Local cPedCom   := ""
Local cItemPC   := ""
Local cAliasD0M := ""

Default aPlnDist := {}
Default aErro    := {}
Default cCodPln  := ""

	aErro := {}
	If Empty(aPlnDist)
		AAdd(aErro,{"Não há lançamento de demanda!"})
		lRet := .F.
	EndIf
	// Inicializa tabelas
	dbSelectArea("SA1")
	dbSelectArea("NNR")
	dbSelectArea("SB1")
	dbSelectArea("SC7")
	
	SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	NNR->(dbSetOrder(1)) // NNR_FILIAL+NNR_CODIGO
	SB1->(dbSetOrder(1)) // B1_FILIAL+B1_COD
	SC7->(dbSetOrder(4)) // C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
	// Efetua as validações dos registros
	If lRet
		For nI := 1 To Len(aPlnDist)
			cCliente := PadR(aPlnDist[nI][01], TamSx3("D0M_CLIENT")[1])
			cLoja    := PadR(aPlnDist[nI][02], TamSx3("D0M_LOJA")[1])
			cArmazem := PadR(aPlnDist[nI][03], TamSx3("D0M_LOCAL")[1])
			cProduto := PadR(aPlnDist[nI][04], TamSx3("D0M_PRODUT")[1])
			cLoteCtl := PadR(aPlnDist[nI][05], TamSx3("D0M_LOTECT")[1])
			cNumLote := PadR(aPlnDist[nI][06], TamSx3("D0M_NUMLOT")[1])
			nQtdDem  := Iif(ValType(aPlnDist[nI][08]) == "N", aPlnDist[nI][08], Val(aPlnDist[nI][08]))
			nQtdDe2  := Iif(ValType(aPlnDist[nI][09]) == "N", aPlnDist[nI][09], Val(aPlnDist[nI][09]))
			cPedCom  := PadR(aPlnDist[nI][10], TamSx3("D0M_PEDCOM")[1])
			cItemPC  := PadR(aPlnDist[nI][11], TamSx3("D0M_ITPC")[1])
			// Validações
			// Ao encontrar um erro atribui lRet := .F. e deverá efetuar a validação de todos os registros
			// Valida cliente informado
			If Empty(cCliente)
				AAdd(aErro,{ WmsFmtMsg( STR0004,{{"[VAR01]",AllTrim(Str(nI))}}) }) // Linha [VAR01] | Cliente não informado!
			EndIf
			// Valida loja informada
			If Empty(cLoja)
				AAdd(aErro,{ WmsFmtMsg( STR0005,{{"[VAR01]",AllTrim(Str(nI))}}) }) //Linha [VAR01] | Loja não informada!
			EndIf
			// Valida se cliente e loja estão cadastrados
			If !Empty(cCliente) .And. !Empty(cLoja)
				If !SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
					AAdd(aErro,{ WmsFmtMsg( STR0006,{{"[VAR01]",AllTrim(Str(nI))},{"[VAR02]",AllTrim(cCliente)},{"[VAR03]",AllTrim(cLoja)}}) }) // Linha [VAR01] | Cliente: [VAR02] e loja: [VAR03] não cadastrados!
				Else
					// Valida se cliente está ativo
					If SA1->A1_MSBLQL == '1'
						AAdd(aErro,{ WmsFmtMsg( STR0007,{{"[VAR01]",AllTrim(Str(nI))},{"[VAR02]",AllTrim(cCliente)},{"[VAR03]",AllTrim(cLoja)}}) }) // Linha [VAR01] | Cliente: [VAR02] e loja: [VAR03] inativos!
					EndIf
				EndIf
			EndIf
			// Valida se armazem informado
			If Empty(cArmazem)
				AAdd(aErro,{ WmsFmtMsg( STR0008,{{"[VAR01]",AllTrim(Str(nI))}}) }) // Linha [VAR01] | Armazém não informado!
			Else
				// Valida se armazem cadastrado
				If !NNR->(dbSeek(xFilial("NNR")+cArmazem))
					AAdd(aErro,{ WmsFmtMsg( STR0009,{{"[VAR01]",AllTrim(Str(nI))},{"[VAR02]",AllTrim(cArmazem)}}) }) // Linha [VAR01] | Armazém: [VAR02] não cadastrado!
				EndIf
			EndIf
			// Valida se produtos informado
			If Empty(cProduto)
				AAdd(aErro,{ WmsFmtMsg( STR0010,{{"[VAR01]",AllTrim(Str(nI))}}) }) // Linha [VAR01] | Produto não informado!
			Else
				If !SB1->(dbSeek(xFilial("SB1")+cProduto))
					AAdd(aErro,{ WmsFmtMsg( STR0011,{{"[VAR01]",AllTrim(Str(nI))},{"[VAR02]",AllTrim(cProduto)}}) }) // Linha [VAR01] | Produto: [VAR02] não cadastrado!
				EndIf
			EndIf
			// Valida quantidade demanda 1UM
			If QtdComp(nQtdDem) <= 0
				AAdd(aErro,{ WmsFmtMsg( STR0012,{{"[VAR01]",AllTrim(Str(nI))}}) }) // Linha [VAR01] | Quantidade demanda não informada!
			EndIf
			// Valida se pedido de compra cadastrado para o produto
			If !Empty(cPedCom) .And. !Empty(cItemPC) .And. !Empty(cProduto)
				If !SC7->(dbSeek(xFilial("SC7")+cProduto+cPedCom+cItemPC))
					AAdd(aErro,{ WmsFmtMsg( STR0013,{{"[VAR01]",AllTrim(Str(nI))},{"[VAR02]",AllTrim(cProduto)},{"[VAR03]",AllTrim(cPedCom)},{"[VAR04]",AllTrim(cItemPC)}}) }) // Linha [VAR01] | Produto: [VAR02]  não cadastrado para o pedido de compra: [VAR03] e item: [VAR04]!
				EndIf
			EndIf
		Next nI
		// Verifica se ocorreram erros
		If !Empty(aErro)
			lRet := .F.
		EndIf
	EndIf
	// Realiza a geração das movimentações
	If lRet
		Begin Transaction
			Self:oPlnDist:SetCodPln(cCodPln)
			If !Self:oPlnDist:LoadData()
				If Self:oPlnDist:RecordD0L()
					Self:cItem := PadR("", TamSx3("D0M_ITEM")[1])
				Else
					AAdd(aErro,{Self:oPlnDist:GetErro()})
					lRet := .F.
				EndIf
			Else
				cAliasD0M := GetNextAlias()
				BeginSql Alias cAliasD0M
					SELECT MAX(D0M_ITEM) D0M_ITEM
					FROM %Table:D0M% D0M
					WHERE D0M.D0M_FILIAL = %xFilial:D0M%
					AND D0M.D0M_CODPLN = %Exp:Self:GetCodPln()%
					AND D0M.%NotDel%
				EndSql
				Self:cItem := (cAliasD0M)->D0M_ITEM
			EndIf
			If lRet
				For nI := 1 To Len(aPlnDist)
					Self:cItem    := Soma1(Self:cItem)
					Self:cCliente := PadR(aPlnDist[nI][01], TamSx3("D0M_CLIENT")[1])
					Self:cLoja    := PadR(aPlnDist[nI][02], TamSx3("D0M_LOJA")[1])
					Self:cArmazem := PadR(aPlnDist[nI][03], TamSx3("D0M_LOCAL")[1])
					Self:cProduto := PadR(aPlnDist[nI][04], TamSx3("D0M_PRODUT")[1])
					Self:cLoteCtl := PadR(aPlnDist[nI][05], TamSx3("D0M_LOTECT")[1])
					Self:cNumLote := PadR(aPlnDist[nI][06], TamSx3("D0M_NUMLOT")[1])
					Self:dDataEnt := IIf(Empty(aPlnDist[nI][07]),dDataBase,IIf(ValType(aPlnDist[nI][08]) == "D",aPlnDist[nI][07],StoD(aPlnDist[nI][07])))
					Self:nQtdDem  := IIf(ValType(aPlnDist[nI][08]) == "N", aPlnDist[nI][08], Val(aPlnDist[nI][08]))
					Self:nQtdDe2  := IIf(ValType(aPlnDist[nI][09]) == "N", aPlnDist[nI][09], Val(aPlnDist[nI][09]))
					Self:cPedCom  := PadR(aPlnDist[nI][10], TamSx3("D0M_PEDCOM")[1])
					Self:cItemPC  := PadR(aPlnDist[nI][11], TamSx3("D0M_ITPC")[1])
					Self:nQtdDis  := 0
					Self:nQtdDi2  := 0
					If !Self:RecordD0M()
						AAdd(aErro,{Self:cErro})
						lRet := .F.
					EndIf
					If !lRet
						Exit
					EndIf
				Next nI
			EndIf
			If !lRet
				DisarmTransaction()
			EndIf
		End Transaction
	EndIf
	
	RestArea(aAreaSA1)
	RestArea(aAreaNNR)
	RestArea(aAreaSB1)
	RestArea(aAreaSC7)
Return lRet

METHOD UpdStatus() CLASS WMSDTCPlanoDistribuicaoItens
Local lRet      := .T.
Local cAliasD0M := Nil
	cAliasD0M := GetNextAlias()
	BeginSql Alias cAliasD0M
		SELECT PLANO.STATUS
		FROM ( SELECT CASE WHEN SUM(D0M.D0M_QTDDIS) = 0  THEN '1'
							WHEN SUM(D0M.D0M_QTDDIS) > 0 AND SUM(D0M.D0M_QTDDEM - D0M.D0M_QTDDIS) > 0 THEN '2'
							WHEN SUM(D0M.D0M_QTDDIS) > 0 AND SUM(D0M.D0M_QTDDEM - D0M.D0M_QTDDIS) = 0 THEN '3' END AS STATUS
				FROM %Table:D0M% D0M
				WHERE D0M.D0M_FILIAL = %xFilial:D0M%
				AND D0M.D0M_CODPLN = %Exp:Self:GetCodPln()%
				AND D0M.%NotDel% ) PLANO
	EndSql
	If (cAliasD0M)->(!Eof())
		Self:oPlnDist:SetStatus((cAliasD0M)->STATUS)
		Self:oPlnDist:UpdateD0L()
	EndIf
Return lRet
