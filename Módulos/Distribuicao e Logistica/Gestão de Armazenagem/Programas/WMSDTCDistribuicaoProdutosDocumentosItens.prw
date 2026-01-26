#Include "Totvs.ch"
#Include "WMSDTCDistribuicaoProdutosDocumentosItens.ch"
//----------------------------------------------
/*/{Protheus.doc} WMSCLS0014
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0014()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoProdutosDocumentosItens
Classe distribuição de produtos documentos e itens
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoProdutosDocumentosItens FROM LongNameClass
	// Data
	DATA oMntDist // D06
	DATA oProduto
	DATA cDocumento
	DATA cFornec
	DATA cLoja
	DATA cSerie
	DATA cSerieDoc
	DATA dDataEmis
	DATA cArmazem
	DATA cLoteCtl
	DATA cNumLote
	DATA cItem
	DATA nQtdEnt
	DATA nQtdEn2
	DATA nQtdDis
	DATA nQtdDi2
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD RecordD07()
	METHOD UpdateD07()
	// Setters
	METHOD SetCodDis(cCodDis)
	METHOD SetDocto(cDocumento)
	METHOD SetSerie(cSerie)
	METHOD SetSerDoc(cSerieDoc)
	METHOD SetFornec(cFornec)
	METHOD SetLoja(cLoja)
	METHOD SetItem(cItem)
	METHOD SetDatEmis(dDataEmis)
	METHOD SetArmazem(cArmazem)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetQtdEnt(nQtdEnt)
	METHOD SetQtdEn2(nQtdEn2)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetQtdDi2(nQtdDi2)
	// Getters
	METHOD GetCodDis()
	METHOD GetDocto()
	METHOD GetSerie()
	METHOD GetFornec()
	METHOD GetLoja()
	METHOD GetItem()
	METHOD GetDatEmis()
	METHOD GetArmazem()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetQtdEnt()
	METHOD GetQtdEn2()
	METHOD GetQtdDis()
	METHOD GetQtdDi2()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:oMntDist   := WMSDTCDistribuicaoProdutos():New()
	Self:oProduto   := WMSDTCProdutoDadosAdicionais():New()
	Self:cDocumento := PadR("", TamSx3("D07_DOC")[1])
	Self:cSerie     := PadR("", TamSx3("D07_SERIE")[1])
	Self:cSerieDoc  := PadR("", TamSx3("D07_SDOC")[1])
	Self:cFornec    := PadR("", TamSx3("D07_FORNEC")[1])
	Self:cLoja      := PadR("", TamSx3("D07_LOJA")[1])
	Self:cItem      := PadR("", TamSx3("D07_ITEM")[1])
	Self:dDataEmis  := CtoD("  /  /    ")
	Self:cArmazem   := PadR("", TamSx3("D07_LOCAL")[1])
	Self:cLoteCtl   := PadR("", TamSx3("D07_LOTECT")[1])
	Self:cNumLote   := PadR("", TamSx3("D07_NUMLOT")[1])
	Self:nQtdEnt    := 0
	Self:nQtdEn2    := 0
	Self:nQtdDis    := 0
	Self:nQtdDi2    := 0
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	//Mantido para compatibilidade
Return

METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD07    := D07->(GetArea())
Local aD07_QTDENT := TamSx3("D07_QTDENT")
Local aD07_QTDEN2 := TamSx3("D07_QTDEN2")
Local aD07_QTDDIS := TamSx3("D07_QTDDIS")
Local aD07_QTDDI2 := TamSx3("D07_QTDDI2")
Local cAliasD07   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 1 // D07_FILIAL+D07_CODDIS+D07_DOC+D07_SERIE+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM
			If Empty(Self:GetCodDis()) .Or. Empty(Self:cDocumento) .Or. Empty(Self:cFornec);
				.Or. Empty(Self:cLoja) .Or. Empty(Self:GetProduto()) .Or. Empty(Self:cItem)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD07:= GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD07
					SELECT D07.D07_CODDIS,
							D07.D07_DOC,
							D07.D07_SDOC,
							D07.D07_FORNEC,
							D07.D07_LOJA,
							D07.D07_DTEMIS,
							D07.D07_SERIE,
							D07.D07_ITEM,
							D07.D07_LOCAL,
							D07.D07_PRODUT,
							D07.D07_LOTECT,
							D07.D07_NUMLOT,
							D07.D07_QTDENT,
							D07.D07_QTDEN2,
							D07.D07_QTDDIS,
							D07.D07_QTDDI2,
							D07.R_E_C_N_O_ RECNOD07
					FROM %Table:D07% D07
					WHERE D07.D07_FILIAL = %xFilial:D07%
					AND D07.D07_CODDIS = %Exp:Self:GetCodDis()%
					AND D07.D07_DOC = %Exp:Self:cDocumento%
					AND D07.D07_SERIE = %Exp:Self:cSerie%
					AND D07.D07_FORNEC = %Exp:Self:cFornec%
					AND D07.D07_LOJA = %Exp:Self:cLoja%
					AND D07.D07_PRODUT = %Exp:Self:GetProduto()%
					AND D07.D07_ITEM = %Exp:Self:cItem%
					AND D07.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD07,'D07_QTDENT','N',aD07_QTDENT[1],aD07_QTDENT[2])
		TCSetField(cAliasD07,'D07_QTDEN2','N',aD07_QTDEN2[1],aD07_QTDEN2[2])
		TCSetField(cAliasD07,'D07_QTDDIS','N',aD07_QTDDIS[1],aD07_QTDDIS[2])
		TCSetField(cAliasD07,'D07_QTDDI2','N',aD07_QTDDI2[1],aD07_QTDDI2[2])
		If (lRet := (cAliasD07)->(!Eof()))
			//
			Self:SetCodDis((cAliasD07)->D07_CODDIS)
			Self:SetSerie((cAliasD07)->D07_SERIE)
			Self:SetSerDoc((cAliasD07)->D07_SDOC)
			Self:SetFornec((cAliasD07)->D07_FORNEC)
			Self:SetLoja((cAliasD07)->D07_LOJA)
			Self:SetItem((cAliasD07)->D07_ITEM)
			Self:oMntDist:LoadData()
			//
			Self:SetProduto((cAliasD07)->D07_PRODUT)
			Self:oProduto:LoadData()
			//
			Self:dDataEmis:= (cAliasD07)->D07_DTEMIS
			Self:cArmazem := (cAliasD07)->D07_LOCAL
			Self:cLoteCtl := (cAliasD07)->D07_LOTECT
			Self:cNumLote := (cAliasD07)->D07_NUMLOT
			Self:nQtdEnt  := (cAliasD07)->D07_QTDENT
			Self:nQtdEn2  := (cAliasD07)->D07_QTDEN2
			Self:nQtdDis  := (cAliasD07)->D07_QTDDIS
			Self:nQtdDi2  := (cAliasD07)->D07_QTDDI2
			Self:nRecno   := (cAliasD07)->RECNOD07
		EndIf
		(cAliasD07)->(dbCloseArea())
	EndIf
	RestArea(aAreaD07)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD07() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Local lRet := .T.
	Self:nQtdEn2 := ConvUm(Self:GetProduto(),Self:nQtdEnt,0,2)
	Self:nQtdDi2 := ConvUm(Self:GetProduto(),Self:nQtdDis,0,2)
	DbSelectArea("D07")
	D07->(dbSetOrder(1)) // D07_FILIAL+D07_CODDIS+D07_DOC+D07_SERIE+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM
	If !D07->(dbSeek(xFilial("D07")+Self:GetCodDis()+Self:cDocumento+Self:cSerie+Self:cFornec+Self:cLoja+Self:GetProduto()+Self:cItem ))
		Reclock('D07',.T.)
		D07->D07_FILIAL := xFilial("D07")
		D07->D07_CODDIS := Self:GetCodDis()
		D07->D07_DOC    := Self:cDocumento
		D07->D07_SERIE  := Self:cSerie
		D07->D07_SDOC   := Self:cSerieDoc
		D07->D07_FORNEC := Self:cFornec
		D07->D07_LOJA   := Self:cLoja
		D07->D07_ITEM   := Self:cItem
		D07->D07_DTEMIS := Self:dDataEmis
		D07->D07_LOCAL  := Self:cArmazem
		D07->D07_PRODUT := Self:GetProduto()
		D07->D07_LOTECT := Self:cLoteCtl
		D07->D07_NUMLOT := Self:cNumLote
		D07->D07_QTDENT := Self:nQtdEnt
		D07->D07_QTDEN2 := Self:nQtdEn2
		D07->D07_QTDDIS := Self:nQtdDis
		D07->D07_QTDDI2 := Self:nQtdDi2
		D07->(MsUnLock())
		// Grava recno
		Self:nRecno := D07->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD07() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Local lRet := .T.
Local aAreaD07 := D07->(GetArea())
	// Converte 2UM
	Self:nQtdEn2 := ConvUm(Self:GetProduto(),Self:nQtdEnt,0,2)
	Self:nQtdDi2 := ConvUm(Self:GetProduto(),Self:nQtdDis,0,2)
	If !Empty(Self:nRecno)
		D07->(dbGoTo( Self:nRecno))
		// Grava D07
		RecLock('D07', .F.)
		D07->D07_QTDDIS := Self:nQtdDis
		D07->D07_QTDDI2 := Self:nQtdDi2
		D07->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD07)
Return lRet

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:oMntDist:SetCodDis(cCodDis)
Return

METHOD SetDocto(cDocumento) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cDocumento := PadR(cDocumento, Len(Self:cDocumento))
Return

METHOD SetSerie(cSerie) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cSerie := PadR(cSerie, Len(Self:cSerie))
Return

METHOD SetSerDoc(cSerieDoc) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cSerieDoc := PadR(cSerieDoc, Len(Self:cSerieDoc))
Return

METHOD SetFornec(cFornec) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cFornec := PadR(cFornec, Len(Self:cFornec))
Return

METHOD SetLoja(cLoja) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return

METHOD SetItem(cItem) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cItem := PadR(cItem, Len(Self:cItem))
Return

METHOD SetDatEmis(dDataEmis) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:dDataEmis := dDataEmis
Return

METHOD SetArmazem(cArmazem) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:oProduto:SetProduto(cProduto)
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:cNumLote := PadR(cNumLote, LEn(Self:cNumLote))
Return

METHOD SetQtdEnt(nQtdEnt) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:nQtdEnt := nQtdEnt
Return

METHOD SetQtdEn2(nQtdEn2) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:nQtdEn2 := nQtdEn2
Return

METHOD SetQtdDis(nQtdDis) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:nQtdDis := nQtdDis
Return

METHOD SetQtdDi2(nQtdDi2) CLASS WMSDTCDistribuicaoProdutosDocumentosItens
	Self:nQtdDi2 := nQtdDi2
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodDis() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:oMntDist:GetCodDis()

METHOD GetDocto() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cDocumento

METHOD GetSerie() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cSerie

METHOD GetFornec() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cFornec

METHOD GetLoja() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cLoja

METHOD GetItem() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cItem

METHOD GetDatEmis() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:dDataEmis

METHOD GetArmazem() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cArmazem

METHOD GetProduto() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:oProduto:GetProduto()

METHOD GetLoteCtl() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cNumLote

METHOD GetQtdEnt() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:nQtdEnt

METHOD GetQtdEn2() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:nQtdEn2

METHOD GetQtdDis() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:nQtdDis

METHOD GetQtdDi2() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:nQtdDi2

METHOD GetErro() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:cErro

METHOD GetRecno() CLASS WMSDTCDistribuicaoProdutosDocumentosItens
Return Self:nRecno
