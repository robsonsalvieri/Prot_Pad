#Include "Totvs.ch"
#Include "WMSDTCDistribuicaoProdutosItens.ch"
//----------------------------------------------
/*/{Protheus.doc} WMSCLS0015
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0015()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoProdutosItens
Classe distribuição de produtos e itens
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoProdutosItens FROM LongNameClass
	// Data
	DATA oMntDist // D06
	DATA cArmazem
	DATA cProduto
	DATA nQtdAdi
	DATA nQtdAd2
	DATA nQtdDis
	DATA nQtdDi2
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD RecordD09()
	METHOD UpdateD09()
	// Setters
	METHOD SetCodDis(cCodDis)
	METHOD SetArmazem(cArmazem)
	METHOD SetProduto(cProduto)
	METHOD SetQtdAdi(nQtdAdi)
	METHOD SetQtdAd2(nQtdAd2)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetQtdDi2(nQtdDi2)
	// Getters
	METHOD GetCodDis()
	METHOD GetArmazem()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetQtdAdi()
	METHOD GetQtdAd2()
	METHOD GetQtdDis()
	METHOD GetQtdDi2()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoProdutosItens
	Self:oMntDist   := WMSDTCDistribuicaoProdutos():New()
	Self:cArmazem   := PadR("", TamSx3("D09_LOCAL")[1])
	Self:cProduto   := PadR("", TamSx3("D09_PRODUT")[1])
	Self:nQtdAdi    := 0
	Self:nQtdAd2    := 0
	Self:nQtdDis    := 0
	Self:nQtdDi2    := 0
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoProdutosItens
	//Mantido para compatibilidade
Return

METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoProdutosItens
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD09    := D09->(GetArea())
Local aD09_QTDADI := TamSx3("D09_QTDADI")
Local aD09_QTDAD2 := TamSx3("D09_QTDAD2")
Local aD09_QTDDIS := TamSx3("D09_QTDDIS")
Local aD09_QTDDI2 := TamSx3("D09_QTDDI2")
Local cAliasD09   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 1 // D09_FILIAL+D09_CODDIS+D09_LOCAL+D09_PRODUT
			If Empty(Self:GetCodDis()) .Or. Empty(Self:cArmazem) .Or. Empty(Self:cProduto)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD09 := GetNextAlias()
		Do case
			Case nIndex == 1
				BeginSql Alias cAliasD09
					SELECT D09.D09_CODDIS,
							D09.D09_LOCAL,
							D09.D09_PRODUT,
							D09.D09_QTDADI,
							D09.D09_QTDAD2,
							D09.D09_QTDDIS,
							D09.D09_QTDDI2,
							D09.R_E_C_N_O_ RECNOD09
					FROM %Table:D09% D09
					WHERE D09.D09_FILIAL = %xFilial:D09%
					AND D09.D09_CODDIS = %Exp:Self:GetCodDis()%
					AND D09.D09_LOCAL = %Exp:Self:cArmazem%
					AND D09.D09_PRODUT = %Exp:Self:cProduto%
					AND D09.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD09,'D09_QTDADI','N',aD09_QTDADI[1],aD09_QTDADI[2])
		TCSetField(cAliasD09,'D09_QTDAD2','N',aD09_QTDAD2[1],aD09_QTDAD2[2])
		TCSetField(cAliasD09,'D09_QTDDIS','N',aD09_QTDDIS[1],aD09_QTDDIS[2])
		TCSetField(cAliasD09,'D09_QTDDI2','N',aD09_QTDDI2[1],aD09_QTDDI2[2])
		If (lRet := (cAliasD09)->(!Eof()))
			Self:SetCodDis((cAliasD09)->D09_CODDIS)
			Self:SetArmazem((cAliasD09)->D09_LOCAL)
			Self:SetProduto((cAliasD09)->D09_PRODUT)
			Self:oMntDist:LoadData()
			Self:nQtdAdi  := (cAliasD09)->D09_QTDADI
			Self:nQtdAd2  := (cAliasD09)->D09_QTDAD2
			Self:nQtdDis  := (cAliasD09)->D09_QTDDIS
			Self:nQtdDi2  := (cAliasD09)->D09_QTDDI2
			Self:nRecno   := (cAliasD09)->RECNOD09
		EndIf
		(cAliasD09)->(dbCloseArea())
	EndIf
	RestArea(aAreaD09)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD09() CLASS WMSDTCDistribuicaoProdutosItens
Local lRet := .T.
	Self:nQtdAd2 := ConvUm(Self:cProduto,Self:nQtdAdi,0,2)
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	DbSelectArea("D09")
	D09->(dbSetOrder(1)) // D09_FILIAL+D09_CODDIS+D09_LOCAL+D09_PRODUT
	If !D09->(dbSeek(xFilial("D09")+Self:oMntDist:GetCodDis()+Self:cArmazem+Self:cProduto))
		Reclock('D09',.T.)
		D09->D09_FILIAL := xFilial("D09")
		D09->D09_CODDIS := Self:oMntDist:GetCodDis()
		D09->D09_LOCAL  := Self:cArmazem
		D09->D09_PRODUT := Self:cProduto
		D09->D09_QTDADI := Self:nQtdAdi
		D09->D09_QTDAD2 := Self:nQtdAd2
		D09->D09_QTDDIS := Self:nQtdDis
		D09->D09_QTDDI2 := Self:nQtdDi2
		D09->(MsUnLock())
		// Grava recno
		Self:nRecno := D09->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD09() CLASS WMSDTCDistribuicaoProdutosItens
Local lRet := .T.
Local aAreaD09 := D09->(GetArea())
	// Converte 2UM
	Self:nQtdAd2 := ConvUm(Self:cProduto,Self:nQtdAdi,0,2)
	Self:nQtdDi2 := ConvUm(Self:cProduto,Self:nQtdDis,0,2)
	If !Empty(Self:nRecno)
		D09->(dbGoTo( Self:nRecno ))
		// Grava D09
		RecLock('D09', .F.)
		D09->D09_QTDADI += Self:nQtdAdi
		D09->D09_QTDAD2 += Self:nQtdAd2
		D09->D09_QTDDIS += Self:nQtdDis
		D09->D09_QTDDI2 += Self:nQtdDi2
		D09->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD09)
Return lRet
//-----------------------------------
//Setters
//-----------------------------------
METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoProdutosItens
	Self:oMntDist:SetCodDis(cCodDis)
Return

METHOD SetArmazem(cArmazem) CLASS WMSDTCDistribuicaoProdutosItens
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCDistribuicaoProdutosItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetQtdAdi(nQtdAdi) CLASS WMSDTCDistribuicaoProdutosItens
	Self:nQtdAdi := nQtdAdi
Return

METHOD SetQtdAd2(nQtdAd2) CLASS WMSDTCDistribuicaoProdutosItens
	Self:nQtdAd2 := nQtdAd2
Return

METHOD SetQtdDis(nQtdDis) CLASS WMSDTCDistribuicaoProdutosItens
	Self:nQtdDis := nQtdDis
Return

METHOD SetQtdDi2(nQtdDi2) CLASS WMSDTCDistribuicaoProdutosItens
	Self:nQtdDi2 := nQtdDi2
Return
//-----------------------------------
//Getters
//-----------------------------------
METHOD GetCodDis() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:oMntDist:GetCodDis()

METHOD GetArmazem() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:cArmazem

METHOD GetProduto() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:cProduto

METHOD GetQtdAdi() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:nQtdAdi

METHOD GetQtdAd2() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:nQtdAd2

METHOD GetQtdDis() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:nQtdDis

METHOD GetQtdDi2() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:nQtdDi2

METHOD GetErro() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:cErro

METHOD GetRecno() CLASS WMSDTCDistribuicaoProdutosItens
Return Self:nRecno
