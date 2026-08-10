#Include "Totvs.ch"
#Include "WMSDTCDistribuicaoProdutosDocumentosEnderecos.ch"
//----------------------------------------------
/*/{Protheus.doc} WMSCLS0013
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0013()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoProdutosDocumentosEnderecos
Classe distribuição de produtos documentos e endereços
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos FROM LongNameClass
	// Data
	DATA oMntDist // D06
	DATA cDocumento
	DATA cFornec
	DATA cLoja
	DATA cSerie
	DATA cSerieDoc
	DATA dDataEmis
	DATA cArmazem
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cItem
	DATA cEndereco
	DATA nQtdDis
	DATA nQtdDi2
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD RecordD0F()
	METHOD UpdateD0F()
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
	METHOD SetEnder(cEndereco)
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
	METHOD GetEnder()
	METHOD GetQtdDis()
	METHOD GetQtdDi2()
	// Metodo
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:oMntDist   := WMSDTCDistribuicaoProdutos():New()
	Self:cDocumento := PadR("", TamSx3("D0F_DOC")[1])
	Self:cSerie     := PadR("", TamSx3("D0F_SERIE")[1])
	Self:cSerieDoc  := PadR("", TamSx3("D0F_SDOC")[1])
	Self:cFornec    := PadR("", TamSx3("D0F_FORNEC")[1])
	Self:cLoja      := PadR("", TamSx3("D0F_LOJA")[1])
	Self:cItem      := PadR("", TamSx3("D0F_ITEM")[1])
	Self:dDataEmis  := CtoD("  /  /    ")
	Self:cArmazem   := PadR("", TamSx3("D0F_LOCAL")[1])
	Self:cProduto   := PadR("", TamSx3("D0F_PRODUT")[1])
	Self:cLoteCtl   := PadR("", TamSx3("D0F_LOTECT")[1])
	Self:cNumLote   := PadR("", TamSx3("D0F_NUMLOT")[1])
	Self:cEndereco  := PadR("", TamSx3("D0F_ENDER")[1])
	Self:nQtdDis    := 0
	Self:nQtdDi2    := 0
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	//Mantido para compatibilidade
Return

METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD0F    := D0F->(GetArea())
Local aD0F_QTDDIS := TamSx3("D02_QTSEPA")
Local aD0F_QTDDI2 := TamSx3("D02_QTCONF")
Local cAliasD0F   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 1 // D0F_FILIAL+D0F_CODDIS+D0F_DOC+D0F_SERIE+D0F_FORNEC+D0F_LOJA+D0F_PRODUT+D0F_ITEM
			If Empty(Self:GetCodDis()) .Or. Empty(Self:cDocumento) .Or. Empty(Self:cSerie) .Or. Empty(Self:cFornec);
				.Or. Empty(Self:cLoja) .Or. Empty(Self:cProduto) .Or. Empty(Self:cItem)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0F   := GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD0F
					SELECT D0F.D0F_CODDIS,
							D0F.D0F_ENDER,
							D0F.D0F_DOC,
							D0F.D0F_SDOC,
							D0F.D0F_FORNEC,
							D0F.D0F_LOJA,
							D0F.D0F_DTEMIS,
							D0F.D0F_SERIE,
							D0F.D0F_LOCAL,
							D0F.D0F_ITEM,
							D0F.D0F_PRODUT,
							D0F.D0F_LOTECT,
							D0F.D0F_NUMLOT,
							D0F.D0F_QTDDIS,
							D0F.D0F_QTDDI2,
							D0F.R_E_C_N_O_ RECNOD0F
					FROM %Table:D0F% D0F
					WHERE D0F.D0F_FILIAL = %xFilial:D0F%
					AND D0F.D0F_CODDIS = %Exp:Self:GetCodDis()%
					AND D0F.D0F_DOC = %Exp:Self:cDocumento %
					AND D0F.D0F_SERIE = %Exp:Self:cSerie%
					AND D0F.D0F_FORNEC = %Exp:Self:cFornec%
					AND D0F.D0F_LOJA = %Exp:Self:cLoja%
					AND D0F.D0F_PRODUT = %Exp:Self:cProduto%
					AND D0F.D0F_ITEM = %Exp:Self:cItem%
					AND D0F.D0F_ENDER = %Exp:Self:cEndereco%
					AND D0F.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD0F,'D0F_QTDDIS','N',aD0F_QTDDIS[1],aD0F_QTDDIS[2])
		TCSetField(cAliasD0F,'D0F_QTDDI2','N',aD0F_QTDDI2[1],aD0F_QTDDI2[2])
		If (lRet := (cAliasD0F)->(!Eof()))
			Self:SetCodDis( (cAliasD0F)->D0F_CODDIS )
			Self:oMntDist:LoadData()
			Self:dDataEmis:= (cAliasD0F)->D0F_DTEMIS
			Self:cArmazem := (cAliasD0F)->D0F_LOCAL
			Self:cLoteCtl := (cAliasD0F)->D0F_LOTECT
			Self:cNumLote := (cAliasD0F)->D0F_NUMLOT
			Self:nQtdDis  := (cAliasD0F)->D0F_QTDDIS
			Self:nQtdDi2  := (cAliasD0F)->D0F_QTDDI2
			Self:nRecno   := (cAliasD0F)->RECNOD0F
		EndIf
		(cAliasD0F)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0F)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD0F() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Local lRet := .T.
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	DbSelectArea("D0F")
	D0F->(dbSetOrder(1)) // D0F_FILIAL+D0F_CODDIS+D0F_DOC+D0F_SERIE+D0F_FORNEC+D0F_LOJA+D0F_PRODUT+D0F_ITEM
	If !D0F->(dbSeek(xFilial("D0F")+Self:oMntDist:GetCodDis()+Self:cDocumento+Self:cSerie+Self:cFornec+Self:cLoja+Self:cProduto+Self:cItem+Self:cEndereco ))
		Reclock('D0F',.T.)
		D0F->D0F_FILIAL := xFilial("D0F")
		D0F->D0F_CODDIS := Self:oMntDist:GetCodDis()
		D0F->D0F_DOC    := Self:cDocumento
		D0F->D0F_SERIE  := Self:cSerie
		D0F->D0F_SDOC   := Self:cSerieDoc
		D0F->D0F_FORNEC := Self:cFornec
		D0F->D0F_LOJA   := Self:cLoja
		D0F->D0F_ITEM   := Self:cItem
		D0F->D0F_DTEMIS := Self:dDataEmis
		D0F->D0F_LOCAL  := Self:cArmazem
		D0F->D0F_PRODUT := Self:cProduto
		D0F->D0F_LOTECT := Self:cLoteCtl
		D0F->D0F_NUMLOT := Self:cNumLote
		D0F->D0F_ENDER  := Self:cEndereco
		D0F->D0F_QTDDIS := Self:nQtdDis
		D0F->D0F_QTDDI2 := Self:nQtdDi2
		D0F->(MsUnLock())
		// Grava recno
		Self:nRecno := D0F->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD0F() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Local lRet := .T.
Local aAreaD0F := D0F->(GetArea())
	// Converte 2UM
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	If !Empty(Self:nRecno)
		D0F->(dbGoTo( Self:nRecno))
		// Grava D0F
		RecLock('D0F', .F.)
		D0F->D0F_QTDDIS := Self:nQtdDis
		D0F->D0F_QTDDI2 := Self:nQtdDi2
		D0F->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0F)
Return lRet

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:oMntDist:SetCodDis(cCodDis)
Return

METHOD SetDocto(cDocumento) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cDocumento := PadR(cDocumento, Len(Self:cDocumento))
Return

METHOD SetSerie(cSerie) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cSerie := PadR(cSerie, Len(Self:cSerie))
Return

METHOD SetSerDoc(cSerieDoc) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cSerieDoc := PadR(cSerieDoc, Len(Self:cSerieDoc))
Return

METHOD SetFornec(cFornec) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cFornec := PadR(cFornec, Len(Self:cFornec))
Return

METHOD SetLoja(cLoja) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cLoja := PadR(cLoja, Len(Self:cLoja))
Return

METHOD SetItem(cItem) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cItem := PadR(cItem, Len(Self:cItem))
Return

METHOD SetDatEmis(dDataEmis) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:dDataEmis := dDataEmis
Return

METHOD SetArmazem(cArmazem) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetEnder(cEndereco) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:cEndereco := PadR(cEndereco, Len(Self:cEndereco))
Return

METHOD SetQtdDis(nQtdDis) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:nQtdDis := nQtdDis
Return

METHOD SetQtdDi2(nQtdDi2) CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
	Self:nQtdDi2 := nQtdDi2
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodDis() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:oMntDist:GetCodDis()

METHOD GetDocto() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cDocumento

METHOD GetSerie() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cSerie

METHOD GetFornec() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cFornec

METHOD GetLoja() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cLoja

METHOD GetItem() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cItem

METHOD GetDatEmis() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:dDataEmis

METHOD GetArmazem() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cArmazem

METHOD GetProduto() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cNumLote

METHOD GetEnder() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cEndereco

METHOD GetQtdDis() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:nQtdDis

METHOD GetQtdDi2() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:nQtdDi2

METHOD GetErro() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:cErro

METHOD GetRecno() CLASS WMSDTCDistribuicaoProdutosDocumentosEnderecos
Return Self:nRecno
