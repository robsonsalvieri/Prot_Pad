#Include "Totvs.ch"
#Include "WMSDTCSaldoADistribuir.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0042
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0042()
Return Nil
//------------------------------------------------
/*/{Protheus.doc} WMSDTCSaldoADistribuir
Saldo a distribuir
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//------------------------------------------------
CLASS WMSDTCSaldoADistribuir FROM LongNameClass
	// Data
	DATA oProdLote
	DATA nQtdOri
	DATA nQtOri2
	DATA nSaldo
	DATA nQtSeUm
	DATA nRecno
	DATA cErro
	DATA cDocto
	DATA cSerie
	DATA cCliFor
	DATA cLoja
	DATA cOrigem
	DATA cNumSeq
	DATA cIdDCF
	// Method
	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD LoadData(nIndex)
	METHOD GoToD0G(nRecno)
	METHOD RecordD0G()
	METHOD DeleteD0G()
	METHOD UpdateD0G()
	METHOD UpdAClass(lEstorno)
	METHOD AssignD0G()
	METHOD WmsVldEst(cLocal,cProduto,cDoc,cNumSerie,cCliFor,cLoja,cNumSeq)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSld(nSaldo)
	METHOD SetQtSeUm(nQtSeUm)
	METHOD SetDocto(cDocto)
	METHOD SetSerie(cSerie)
	METHOD SetCliFor(cCliFor)
	METHOD SetLoja(cLoja)
	METHOD SetOrigem(cOrigem)
	METHOD SetNumSeq(cNumSeq)
	METHOD SetIdDCF(cIdDCF)
	METHOD GetArmazem()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetNumSer()
	METHOD GetQtdOri()
	METHOD GetQtOri2()
	METHOD GetSaldo()
	METHOD GetQtSeUm()
	METHOD GetDocto()
	METHOD GetSerie()
	METHOD GetCliFor()
	METHOD GetLoja()
	METHOD GetOrigem()
	METHOD GetIdDCF()
	METHOD GetNumSeq()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//------------------------------------------------
/*/{Protheus.doc} New
Método contrutor
@author felipe.m
@since 04/08/2015
@version 1.0
/*/
//------------------------------------------------
METHOD New() CLASS WMSDTCSaldoADistribuir
	Self:oProdLote  := WMSDTCProdutoLote():New()
	Self:cDocto     := Padr("", TamSX3("D0G_DOC")[1])
	Self:cSerie     := Padr("", TamSX3("D0G_SERIE")[1])
	Self:cCliFor    := Padr("", TamSX3("D0G_CLIFOR")[1])
	Self:cLoja      := Padr("", TamSX3("D0G_LOJA")[1])
	Self:cOrigem    := Padr("", TamSX3("D0G_ORIGEM")[1])
	Self:cNumSeq    := Padr("", TamSX3("D0G_NUMSEQ")[1])
	Self:cIdDCF     := Padr("", TamSX3("D0G_IDDCF")[1])
	Self:ClearData()
Return
//------------------------------------------------
METHOD ClearData() CLASS WMSDTCSaldoADistribuir
	Self:oProdLote:ClearData()
	Self:nQtdOri    := 0
	Self:nQtOri2    := 0
	Self:nSaldo     := 0
	Self:nQtSeUm    := 0
	Self:nRecno     := 0
	Self:cErro      := ""
	Self:cDocto     := Padr("", Len(Self:cDocto))
	Self:cSerie     := Padr("", Len(Self:cSerie))
	Self:cCliFor    := Padr("", Len(Self:cCliFor))
	Self:cLoja      := Padr("", Len(Self:cLoja))
	Self:cOrigem    := Padr("", Len(Self:cOrigem))
	Self:cNumSeq    := Padr("", Len(Self:cNumSeq))
	Self:cIdDCF     := Padr("", Len(Self:cIdDCF))
Return
//------------------------------------------------
METHOD Destroy() CLASS WMSDTCSaldoADistribuir
	//Mantido para compatibilidade
Return Nil
//------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0G
@author felipe.m
@since 04/08/2015
@version 1.0
@param nIndex, numérico, (Index da tabela)
/*/
//------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCSaldoADistribuir
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD0G    := D0G->(GetArea())
Local aD0G_QTDORI := TamSx3("D0G_QTDORI")
Local aD0G_QTORI2 := TamSx3("D0G_QTORI2")
Local aD0G_SALDO  := TamSx3("D0G_SALDO")
Local aD0G_QTSEUM := TamSx3("D0G_QTSEUM")
Local cAliasD0G   := Nil
Default nIndex := 1
	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0G_FILIAL+D0G_PRODUT+D0G_LOCAL+D0G_NUMSEQ+D0G_DOC+D0G_SERIE+D0G_CLIFOR+D0G_LOJA
			If (Empty(Self:GetProduto()) .Or. Empty(Self:GetArmazem()) .Or.;
			    Empty(Self:cDocto).Or. Empty(Self:cNumSeq))
				lRet := .F.
			EndIf
		Case nIndex == 2 // D0G_FILIAL+D0G_PRODUT+D0G_LOCAL+D0G_LOTECT+D0G_NUMLOT
			If (Empty(Self:GetProduto()) .Or. Empty(Self:GetArmazem()) .Or. Empty(Self:GetLoteCtl()))
				lRet := .F.
			EndIf

		Case nIndex == 3 // D0G_FILIAL+D0G_IDDCF
			If (Empty(Self:cIdDCF))
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0G := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0G
					SELECT D0G.D0G_LOCAL,
							D0G.D0G_PRODUT,
							D0G.D0G_LOTECT,
							D0G.D0G_NUMLOT,
							D0G.D0G_NUMSER,
							D0G.D0G_DOC,
							D0G.D0G_SERIE,
							D0G.D0G_CLIFOR,
							D0G.D0G_LOJA,
							D0G.D0G_ORIGEM,
							D0G.D0G_NUMSEQ,
							D0G.D0G_IDDCF,
							D0G.D0G_QTDORI,
							D0G.D0G_QTORI2,
							D0G.D0G_SALDO,
							D0G.D0G_QTSEUM,
							D0G.R_E_C_N_O_ RECNOD0G
					FROM %Table:D0G% D0G
					WHERE D0G.D0G_FILIAL = %xFilial:D0G%
					AND D0G.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0G.%NotDel%
				EndSql
			Case nIndex == 1
				If !Empty(Self:cIdDCF)
					BeginSql Alias cAliasD0G
						SELECT D0G.D0G_LOCAL,
								D0G.D0G_PRODUT,
								D0G.D0G_LOTECT,
								D0G.D0G_NUMLOT,
								D0G.D0G_NUMSER,
								D0G.D0G_DOC,
								D0G.D0G_SERIE,
								D0G.D0G_CLIFOR,
								D0G.D0G_LOJA,
								D0G.D0G_ORIGEM,
								D0G.D0G_NUMSEQ,
								D0G.D0G_IDDCF,
								D0G.D0G_QTDORI,
								D0G.D0G_QTORI2,
								D0G.D0G_SALDO,
								D0G.D0G_QTSEUM,
								D0G.R_E_C_N_O_ RECNOD0G
						FROM %Table:D0G% D0G
						WHERE D0G.D0G_FILIAL = %xFilial:D0G%
						AND D0G.D0G_PRODUT = %Exp:Self:GetProduto()%
						AND D0G.D0G_LOCAL = %Exp:Self:GetArmazem()%
						AND D0G.D0G_NUMSEQ = %Exp:Self:cNumSeq%
						AND D0G.D0G_DOC = %Exp:Self:cDocto%
						AND D0G.D0G_SERIE = %Exp:Self:cSerie%
						AND D0G.D0G_CLIFOR = %Exp:Self:cCliFor%
						AND D0G.D0G_LOJA = %Exp:Self:cLoja%
						AND D0G.D0G_IDDCF = %Exp:Self:cIdDCF%
						AND D0G.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD0G
						SELECT D0G.D0G_LOCAL,
								D0G.D0G_PRODUT,
								D0G.D0G_LOTECT,
								D0G.D0G_NUMLOT,
								D0G.D0G_NUMSER,
								D0G.D0G_DOC,
								D0G.D0G_SERIE,
								D0G.D0G_CLIFOR,
								D0G.D0G_LOJA,
								D0G.D0G_ORIGEM,
								D0G.D0G_NUMSEQ,
								D0G.D0G_IDDCF,
								D0G.D0G_QTDORI,
								D0G.D0G_QTORI2,
								D0G.D0G_SALDO,
								D0G.D0G_QTSEUM,
								D0G.R_E_C_N_O_ RECNOD0G
						FROM %Table:D0G% D0G
						WHERE D0G.D0G_FILIAL = %xFilial:D0G%
						AND D0G.D0G_PRODUT = %Exp:Self:GetProduto()%
						AND D0G.D0G_LOCAL = %Exp:Self:GetArmazem()%
						AND D0G.D0G_NUMSEQ = %Exp:Self:cNumSeq%
						AND D0G.D0G_DOC = %Exp:Self:cDocto%
						AND D0G.D0G_SERIE = %Exp:Self:cSerie%
						AND D0G.D0G_CLIFOR = %Exp:Self:cCliFor%
						AND D0G.D0G_LOJA = %Exp:Self:cLoja%
						AND D0G.%NotDel%
					EndSql
				EndIf
			Case nIndex == 2
				BeginSql Alias cAliasD0G
					SELECT D0G.D0G_LOCAL,
							D0G.D0G_PRODUT,
							D0G.D0G_LOTECT,
							D0G.D0G_NUMLOT,
							D0G.D0G_NUMSER,
							D0G.D0G_DOC,
							D0G.D0G_SERIE,
							D0G.D0G_CLIFOR,
							D0G.D0G_LOJA,
							D0G.D0G_ORIGEM,
							D0G.D0G_NUMSEQ,
							D0G.D0G_IDDCF,
							D0G.D0G_QTDORI,
							D0G.D0G_QTORI2,
							D0G.D0G_SALDO,
							D0G.D0G_QTSEUM,
							D0G.R_E_C_N_O_ RECNOD0G
					FROM %Table:D0G% D0G
					WHERE D0G.D0G_FILIAL = %xFilial:D0G%
					AND D0G.D0G_PRODUT = %Exp:Self:GetProduto()%
					AND D0G.D0G_LOCAL = %Exp:Self:GetArmazem()%
					AND D0G.D0G_LOTECT = %Exp:Self:GetLoteCtl()%
					AND D0G.%NotDel%
				EndSql
			Case nIndex == 3
				BeginSql Alias cAliasD0G
					SELECT D0G.D0G_LOCAL,
							D0G.D0G_PRODUT,
							D0G.D0G_LOTECT,
							D0G.D0G_NUMLOT,
							D0G.D0G_NUMSER,
							D0G.D0G_DOC,
							D0G.D0G_SERIE,
							D0G.D0G_CLIFOR,
							D0G.D0G_LOJA,
							D0G.D0G_ORIGEM,
							D0G.D0G_NUMSEQ,
							D0G.D0G_IDDCF,
							D0G.D0G_QTDORI,
							D0G.D0G_QTORI2,
							D0G.D0G_SALDO,
							D0G.D0G_QTSEUM,
							D0G.R_E_C_N_O_ RECNOD0G
					FROM %Table:D0G% D0G
					WHERE D0G.D0G_FILIAL = %xFilial:D0G%
					AND D0G.D0G_IDDCF = %Exp:Self:cIdDCF%
					AND D0G.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD0G,'D0G_QTDORI','N',aD0G_QTDORI[1],aD0G_QTDORI[2])
		TCSetField(cAliasD0G,'D0G_QTORI2','N',aD0G_QTORI2[1],aD0G_QTORI2[2])
		TCSetField(cAliasD0G,'D0G_SALDO','N',aD0G_SALDO[1],aD0G_SALDO[2])
		TCSetField(cAliasD0G,'D0G_QTSEUM','N',aD0G_QTSEUM[1],aD0G_QTSEUM[2])
		lRet := (cAliasD0G)->(!Eof())
		If lRet
			Self:oProdLote:SetPrdOri((cAliasD0G)->D0G_PRODUT)
			Self:oProdLote:SetProduto((cAliasD0G)->D0G_PRODUT)
			Self:oProdLote:SetArmazem((cAliasD0G)->D0G_LOCAL)
			Self:oProdLote:SetLoteCtl((cAliasD0G)->D0G_LOTECT)
			Self:oProdLote:SetNumLote((cAliasD0G)->D0G_NUMLOT)
			Self:oProdLote:SetNumSer((cAliasD0G)->D0G_NUMSER)
			Self:oProdLote:LoadData() // Para forçar carregar os dados
			Self:cNumSeq := (cAliasD0G)->D0G_NUMSEQ
			Self:cDocto  := (cAliasD0G)->D0G_DOC
			Self:cSerie  := (cAliasD0G)->D0G_SERIE
			Self:cCliFor := (cAliasD0G)->D0G_CLIFOR
			Self:cLoja   := (cAliasD0G)->D0G_LOJA
			Self:cIdDCF  := (cAliasD0G)->D0G_IDDCF
			Self:nQtdOri := (cAliasD0G)->D0G_QTDORI
			Self:nQtOri2 := (cAliasD0G)->D0G_QTORI2
			Self:nSaldo  := (cAliasD0G)->D0G_SALDO
			Self:nQtSeUm := (cAliasD0G)->D0G_QTSEUM
			Self:nRecno  := (cAliasD0G)->RECNOD0G
		EndIf
		(cAliasD0G)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0G)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------
// Setters
//-----------------------------------------------
METHOD SetQtdOri(nQtdOri) CLASS WMSDTCSaldoADistribuir
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSld(nSaldo) CLASS WMSDTCSaldoADistribuir
	Self:nSaldo := nSaldo
Return

METHOD SetQtSeUm(nQtSeUm) CLASS WMSDTCSaldoADistribuir
	Self:nQtSeUm := nQtSeUm
Return

METHOD SetDocto(cDocto) CLASS WMSDTCSaldoADistribuir
	Self:cDocto := cDocto
Return

METHOD SetSerie(cSerie) CLASS WMSDTCSaldoADistribuir
	Self:cSerie := cSerie
Return

METHOD SetCliFor(cCliFor) CLASS WMSDTCSaldoADistribuir
	Self:cCliFor := cCliFor
Return

METHOD SetLoja(cLoja) CLASS WMSDTCSaldoADistribuir
	Self:cLoja := cLoja
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCSaldoADistribuir
	Self:cOrigem := cOrigem
Return

METHOD SetNumSeq(cNumSeq) CLASS WMSDTCSaldoADistribuir
	Self:cNumSeq := cNumSeq
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCSaldoADistribuir
	Self:cIdDCF := cIdDCF
Return
//-----------------------------------------------
// Getters
//-----------------------------------------------
METHOD GetArmazem() CLASS WMSDTCSaldoADistribuir
Return Self:oProdLote:GetArmazem()

METHOD GetProduto() CLASS WMSDTCSaldoADistribuir
Return Self:oProdLote:GetProduto()

METHOD GetLoteCtl() CLASS WMSDTCSaldoADistribuir
Return Self:oProdLote:GetLoteCtl()

METHOD GetNumLote() CLASS WMSDTCSaldoADistribuir
Return Self:oProdLote:GetNumLote()

METHOD GetNumSer() CLASS WMSDTCSaldoADistribuir
Return Self:oProdLote:GetNumSer()

METHOD GetQtdOri() CLASS WMSDTCSaldoADistribuir
Return Self:nQtdOri

METHOD GetQtOri2() CLASS WMSDTCSaldoADistribuir
Return Self:nQtOri2

METHOD GetSaldo() CLASS WMSDTCSaldoADistribuir
Return Self:nSaldo

METHOD GetQtSeUm() CLASS WMSDTCSaldoADistribuir
Return Self:nQtSeUm

METHOD GetDocto() CLASS WMSDTCSaldoADistribuir
Return Self:cDocto

METHOD GetSerie() CLASS WMSDTCSaldoADistribuir
Return Self:cSerie

METHOD GetCliFor() CLASS WMSDTCSaldoADistribuir
Return Self:cCliFor

METHOD GetLoja() CLASS WMSDTCSaldoADistribuir
Return Self:cLoja

METHOD GetOrigem() CLASS WMSDTCSaldoADistribuir
Return Self:cOrigem

METHOD GetNumSeq() CLASS WMSDTCSaldoADistribuir
Return Self:cNumSeq

METHOD GetIdDCF() CLASS WMSDTCSaldoADistribuir
Return Self:cIdDCF

METHOD GetRecno() CLASS WMSDTCSaldoADistribuir
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCSaldoADistribuir
Return Self:cErro
//----------------------------------------
/*/{Protheus.doc} GoToD0G
Posicionamento para atualização das propriedades
@author felipe.m
@since 04/08/2015
@version 1.0
@param nRecno, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0G(nRecno) CLASS WMSDTCSaldoADistribuir
	Self:nRecno := nRecno
Return Self:LoadData(0)

METHOD AssignD0G() CLASS WMSDTCSaldoADistribuir
Local lRet := .T.
	If Empty(Self:cIdDCF)
		lRet := .F.
	EndIf
	If lRet
		Self:RecordD0G()
	EndIf
Return lRet

METHOD RecordD0G() CLASS WMSDTCSaldoADistribuir
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
	Self:nQtOri2 := ConvUm(Self:oProdLote:GetProduto(),Self:nQtdOri,0,2)
	Self:nQtSeUm := ConvUm(Self:oProdLote:GetProduto(),Self:nSaldo,0,2)
	// Grava D0G
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D0G% D0G
		WHERE D0G.D0G_FILIAL = %xFilial:D0G%
		AND D0G.D0G_PRODUT = %Exp:Self:GetProduto()%
		AND D0G.D0G_LOCAL = %Exp:Self:GetArmazem()%
		AND D0G.D0G_NUMSEQ = %Exp:Self:cNumSeq%
		AND D0G.D0G_DOC = %Exp:Self:cDocto%
		AND D0G.D0G_SERIE = %Exp:Self:cSerie%
		AND D0G.D0G_CLIFOR = %Exp:Self:cCliFor%
		AND D0G.D0G_LOJA = %Exp:Self:cLoja%
		AND D0G.D0G_IDDCF = %Exp:Self:cIdDCF%
		AND D0G.%NotDel%
	EndSql
	If (cAliasQry)->(Eof())
		RecLock("D0G", .T.)
		D0G->D0G_FILIAL := xFilial("D0G")
		D0G->D0G_LOCAL  := Self:GetArmazem()
		D0G->D0G_PRODUT := Self:GetProduto()
		D0G->D0G_LOTECT := Self:GetLoteCtl()
		D0G->D0G_NUMLOT := Self:GetNumLote()
		D0G->D0G_NUMSER := Self:GetNumSer()
		D0G->D0G_DOC    := Self:cDocto
		D0G->D0G_SERIE  := Self:cSerie
		D0G->D0G_CLIFOR := Self:cCliFor
		D0G->D0G_LOJA   := Self:cLoja
		D0G->D0G_ORIGEM := Self:cOrigem
		D0G->D0G_NUMSEQ := Self:cNumSeq
		D0G->D0G_IDDCF  := Self:cIdDCF
		D0G->D0G_QTDORI := Self:nQtdOri
		D0G->D0G_QTORI2 := Self:nQtOri2
		D0G->D0G_SALDO  := Self:nSaldo
		D0G->D0G_QTSEUM := Self:nQtSeUm
		D0G->(MsUnLock())
		// Grava recno
		Self:nRecno := D0G->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
	(cAliasQry)->(dbCloseArea())
	If lRet
		// Atualiza quantidades a classificar
		Self:UpdAClass()
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD DeleteD0G() CLASS WMSDTCSaldoADistribuir
Local lRet       := .T.
Local nDifB2Clas := 0

	If !Empty(Self:GetRecno())
		D0G->(dbGoTo( Self:GetRecno() ))
		nDifB2Clas := D0G->D0G_SALDO
		// Alteração D0G
		RecLock('D0G', .F.)
		D0G->(dbDelete())
		D0G->(MsUnLock())
		// Atualiza quantidades a classificar
		Self:nSaldo  := nDifB2Clas
		Self:nQtSeUm := ConvUm(Self:GetProduto(),Self:nSaldo,0,2)
		Self:UpdAClass(.T.)
	Else
		lRet := .F.
		Self:cErro := STR0004 // Dados não encontrados!
	EndIf
Return lRet

METHOD UpdAClass(lEstorno) CLASS WMSDTCSaldoADistribuir
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local cAliasSB8:= Nil
Local cAliasSB2:= Nil

Default lEstorno:= .F.
	// Atualiza saldo produto
	cAliasSB2 := GetNextAlias()
	BeginSql Alias cAliasSB2
		SELECT SB2.R_E_C_N_O_ RECNOSB2
		FROM %Table:SB2% SB2
		WHERE SB2.B2_FILIAL = %xFilial:SB2%
		AND SB2.B2_COD = %Exp:Self:GetProduto()%
		AND SB2.B2_LOCAL = %Exp:Self:GetArmazem()%
		AND SB2.%NotDel%
	EndSql
	If (cAliasSB2)->(!Eof())
		SB2->(dbGoTo((cAliasSB2)->RECNOSB2))
		Reclock("SB2",.F.)
		If lEstorno
			SB2->B2_QACLASS -= Self:nSaldo
		Else
			SB2->B2_QACLASS += Self:nSaldo
		EndIf
		SB2->(MsUnlock())
	EndIf
	(cAliasSB2)->(dbCloseArea())
	// Verifica se controla lote
	If Self:oProdLote:HasRastro()
		cAliasSB8 := GetNextAlias()
		BeginSql Alias cAliasSB8
			SELECT SB8.R_E_C_N_O_ RECNOSB8
			FROM %Table:SB8% SB8
			WHERE SB8.B8_FILIAL = %xFilial:SB8%
			AND SB8.B8_PRODUTO = %Exp:Self:GetProduto()%
			AND SB8.B8_LOCAL = %Exp:Self:GetArmazem()%
			AND SB8.B8_LOTECTL = %Exp:Self:GetLoteCtl()%
			AND SB8.B8_NUMLOTE = %Exp:Self:GetNumLote()%
			AND SB8.%NotDel%
		EndSql
		If (cAliasSB8)->(!Eof())
			// Atualiza saldo produto/lote/sublote
			SB8->(dbGoTo((cAliasSB8)->RECNOSB8))
			Reclock("SB8",.F.)
			If lEstorno
				SB8->B8_QACLASS -= Self:nSaldo
				SB8->B8_QACLAS2 -= Self:nQtSeUm
			Else
				SB8->B8_QACLASS += Self:nSaldo
				SB8->B8_QACLAS2 += Self:nQtSeUm
			EndIf
			SB8->(MsUnlock())
		EndIf
		(cAliasSB8)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD WmsVldEst(cLocal,cProduto,cDoc,cNumSerie,cCliFor,cLoja,cNumSeq) CLASS WMSDTCSaldoADistribuir
Local cWhere      := ""
Local cAliasD0G   := Nil
Local nSaldo      := 0

Default cNumSerie := ""
Default cCliFor   := ""
Default cLoja     := ""

	// Se for uma entrada de falta da conferência, não tem saldo a endereçar, 
	// desta forma deve retornar a quantidade que foi atribuída pela conferência
	If Type("lSldEndCof") =="L"
		Return Wm320SdDis()
	EndIf
	// Parâmetro Where
	cWhere := "%"
	If !Empty(cNumSerie)
		cWhere +=   " AND D0G.D0G_SERIE = '"+cNumSerie+"'"
	EndIf
	If !Empty(cCliFor)
		cWhere +=   " AND D0G.D0G_CLIFOR = '"+cCliFor+"'"
	EndIf
	If !Empty(cLoja)
		cWhere +=   " AND D0G.D0G_LOJA = '"+cLoja+"'"
	EndIf
	cWhere += "%"
	// D0G_FILIAL+D0G_PRODUT+D0G_LOCAL+D0G_NUMSEQ+D0G_DOC+D0G_SERIE+D0G_CLIFOR+D0G_LOJA
	cAliasD0G := GetNextAlias()
	BeginSql Alias cAliasD0G
		SELECT D0G.D0G_SALDO
		FROM %Table:D0G% D0G
		WHERE D0G.D0G_FILIAL = %xFilial:D0G%
		AND D0G.D0G_PRODUT = %Exp:cProduto%
		AND D0G.D0G_LOCAL = %Exp:cLocal%
		AND D0G.D0G_DOC = %Exp:cDoc%
		AND D0G.D0G_NUMSEQ = %Exp:cNumSeq%
		AND D0G.%NotDel%
		%Exp:cWhere%
	EndSql
	If (cAliasD0G)->(!Eof())
		nSaldo := (cAliasD0G)->D0G_SALDO
	EndIf
	(cAliasD0G)->(dbCloseArea())
Return nSaldo

METHOD UpdateD0G() CLASS WMSDTCSaldoADistribuir
Local lRet       := .T.
Local lMenor     := .F.
Local aAreaAnt   := GetArea()
Local nDifB2Clas := 0
	// Atualiza D0G
	D0G->(dbSetOrder(1))  //D0G_FILIAL+D0G_PRODUT+D0G_LOCAL+D0G_NUMSEQ+D0G_DOC+D0G_SERIE+D0G_CLIFOR+D0G_LOJA
	If D0G->(dbSeek(xFilial("D0G")+Self:oProdLote:GetProduto()+Self:oProdLote:GetArmazem()+Self:cNumSeq+Self:cDocto+Self:cSerie+Self:cCliFor+Self:cLoja))
		Self:nQtOri2 := ConvUm(Self:GetProduto(),Self:nQtdOri,0,2)
		Self:nQtSeUm := ConvUm(Self:GetProduto(),Self:nSaldo,0,2)
		
		If D0G->D0G_SALDO > Self:nSaldo
			nDifB2Clas := D0G->D0G_SALDO - Self:nSaldo
			lMenor := .T.
		ElseIf D0G->D0G_SALDO < Self:nSaldo
			nDifB2Clas := Self:nSaldo - D0G->D0G_SALDO
			lMenor := .F.
		EndIf

		RecLock("D0G",.F.)
		D0G->D0G_QTDORI := Self:nQtdOri
		D0G->D0G_QTORI2 := Self:nQtOri2
		D0G->D0G_SALDO  := Self:nSaldo
		D0G->D0G_QTSEUM := Self:nQtSeUm
		D0G->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0005 // Saldo a distribuir não encontrado
	EndIf
	If lRet
		// Atualiza quantidades a classificar
		Self:nSaldo  := nDifB2Clas
		Self:nQtSeUm := ConvUm(Self:GetProduto(),Self:nSaldo,0,2)
		Self:UpdAClass(lMenor)
	EndIf
	RestArea(aAreaAnt)
Return lRet
