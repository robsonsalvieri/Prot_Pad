#Include "Totvs.ch"
#Include "WMSDTCVolumeCrossDockingItens.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0049
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0091()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCVolumeCrossDockingItens
Classe itens do volume
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCVolumeCrossDockingItens FROM LongNameClass
	// Data
	DATA oVolume
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA nQuant
	DATA cCodOpe
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0O(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0O()
	METHOD ExcludeD0O()
	// Setters
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEndereco)
	METHOD SetCodVol(cCodVol)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetQuant(nQuant)
	METHOD SetCodOpe(cCodOpe)
	// Getters
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetCodVol()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetQuant()
	METHOD GetCodOpe()
	METHOD GetRecno()
	METHOD GetErro()
	// Metodo
	METHOD AssignD0O()
	METHOD VldPrdCmp(lEstorno)
	METHOD QtdPrdVol(lEstorno)
	METHOD LoadPrdVol(aProdutos,nQtde)
	METHOD MntPrdVol(aProdutos)
	METHOD EstPrdVol(aProdutos,lTotal,lBlqEst)
	METHOD UpdSldBlq(cTipo)
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.correa
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCVolumeCrossDockingItens
	Self:oVolume   := WMSDTCVolumeCrossDocking():New()
	Self:cPrdOri   := PadR("", TamSx3("D0O_PRDORI")[1])
	Self:cProduto  := PadR("", TamSx3("D0O_CODPRO")[1])
	Self:cLoteCtl  := PadR("", TamSx3("D0O_LOTECT")[1])
	Self:cNumLote  := PadR("", TamSx3("D0O_NUMLOT")[1])
	Self:cCodOpe   := __cUserID
	Self:nQuant    := 0
	Self:nRecno    := 0
	Self:cErro     := ""
Return

METHOD Destroy() CLASS WMSDTCVolumeCrossDockingItens
	//Mantido para compatibilidade
Return Nil

//----------------------------------------
/*/{Protheus.doc} GoToDCF
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecnoDCT, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD0O(nRecno) CLASS WMSDTCVolumeCrossDockingItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0O
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCVolumeCrossDockingItens
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aD0O_QUANT:= TamSx3("D0O_QUANT")
Local aAreaD0O  := D0O->(GetArea())
Local cWhere    := ""
Local cAliasD0O := Nil
Default nIndex  := 1
	Do Case
		Case nIndex == 0 // D0O.R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0O_FILIAL+D0O_CODVOL+D0O_PRDORI+D0O_CODPRO+D0O_LOTECT+D0O_NUMLOT
			If Empty(Self:GetCodVol()) .Or. Empty(Self:cPrdOri) .Or. Empty(Self:cProduto)
				lRet := .F.
			EndIf

		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0O := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0O
					SELECT D0O.D0O_CODVOL,
							D0O.D0O_PRDORI,
							D0O.D0O_CODPRO,
							D0O.D0O_LOTECT,
							D0O.D0O_NUMLOT,
							D0O.D0O_QUANT,
							D0O.D0O_CODOPE,
							D0O.R_E_C_N_O_ RECNOD0O
					FROM %Table:D0O% D0O
					WHERE D0O.D0O_FILIAL = %xFilial:D0O%
					AND D0O.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0O.%NotDel%
				EndSql
			Case nIndex == 1
				// Parâmetro Where
				cWhere := "%"
				If !Empty(Self:cLoteCtl)
					cWhere += " AND D0O.D0O_LOTECT = '" + Self:cLoteCtl + "'"
				EndIf
				If !Empty(Self:cNumLote)
					cWhere += " AND D0O.D0O_NUMLOT = '" + Self:cNumLote + "'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0O
					SELECT D0O.D0O_CODVOL,
							D0O.D0O_PRDORI,
							D0O.D0O_CODPRO,
							D0O.D0O_LOTECT,
							D0O.D0O_NUMLOT,
							D0O.D0O_QUANT,
							D0O.D0O_CODOPE,
							D0O.R_E_C_N_O_ RECNOD0O
					FROM %Table:D0O% D0O
					WHERE D0O.D0O_FILIAL = %xFilial:D0O%
					AND D0O.D0O_CODVOL = %Exp:Self:GetCodVol()%
					AND D0O.D0O_PRDORI = %Exp:Self:cPrdOri%
					AND D0O.D0O_CODPRO = %Exp:Self:cProduto%
					AND D0O.D_E_L_E_T_ = ' '"
					%Exp:cWhere%
				EndSql
		EndCase
		TCSetField(cAliasD0O,'D0O_QUANT','N',aD0O_QUANT[1],aD0O_QUANT[2])
		If (lRet := (cAliasD0O)->(!Eof()))
			// Dados Gerais
			Self:SetCodVol((cAliasD0O)->D0O_CODVOL)
			// Montagem
			Self:oVolume:LoadData()
			// Busca dados lote/produto
			Self:SetPrdOri((cAliasD0O)->D0O_PRDORI)
			Self:SetProduto((cAliasD0O)->D0O_CODPRO)
			Self:SetLoteCtl((cAliasD0O)->D0O_LOTECT)
			Self:SetNumLote((cAliasD0O)->D0O_NUMLOT)
			// Busca dados endereco origem
			// Dados complementares
			Self:nQuant   := (cAliasD0O)->D0O_QUANT
			Self:cCodOpe  := (cAliasD0O)->D0O_CODOPE
			Self:nRecno   := (cAliasD0O)->RECNOD0O
		EndIf
		(cAliasD0O)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0O)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCVolumeCrossDockingItens
	Self:oVolume:SetArmazem(cArmazem)
Return

METHOD SetEnder(cEndereco) CLASS WMSDTCVolumeCrossDockingItens
	Self:oVolume:SetEnder(cEndereco)
Return

METHOD SetCodVol(cVolume) CLASS WMSDTCVolumeCrossDockingItens
	Self:oVolume:SetCodVol(cVolume)
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCVolumeCrossDockingItens
	Self:cPrdOri := PadR(cPrdOri, Len(Self:cPrdOri))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCVolumeCrossDockingItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCVolumeCrossDockingItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCVolumeCrossDockingItens
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCVolumeCrossDockingItens
	Self:nQuant := nQuant
Return

METHOD SetCodOpe(cCodOpe) CLASS WMSDTCVolumeCrossDockingItens
	Self:cCodOpe := PadR(cCodOpe, Len(Self:cCodOpe))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCVolumeCrossDockingItens
Return Self:oVolume:GetArmazem()

METHOD GetEnder() CLASS WMSDTCVolumeCrossDockingItens
Return Self:oVolume:GetEnder()

METHOD GetCodVol() CLASS WMSDTCVolumeCrossDockingItens
Return Self:oVolume:GetCodVol()

METHOD GetPrdOri() CLASS WMSDTCVolumeCrossDockingItens
Return Self:cPrdOri

METHOD GetProduto() CLASS WMSDTCVolumeCrossDockingItens
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCVolumeCrossDockingItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCVolumeCrossDockingItens
Return Self:cNumLote

METHOD GetQuant() CLASS WMSDTCVolumeCrossDockingItens
Return  Self:nQuant

METHOD GetCodOpe() CLASS WMSDTCVolumeCrossDockingItens
Return Self:cCodOpe

METHOD GetRecno() CLASS WMSDTCVolumeCrossDockingItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCVolumeCrossDockingItens
Return Self:cErro

METHOD AssignD0O() CLASS WMSDTCVolumeCrossDockingItens
Local lRet := .T.
	// Criar um volume DCU caso não exista
	If !Self:oVolume:RecordD0N()
		lRet := .F.
		Self:cErro := Self:oVolume:GetErro()
	EndIf

	// Seta as informações para a criação da D0O
	If lRet
		If !Self:RecordD0O()
			lRet := .F.
		EndIf
	EndIf
Return lRet

METHOD RecordD0O() CLASS WMSDTCVolumeCrossDockingItens
Local lRet   := .T.
Local lAchou := .F.
	D0O->(DbSetOrder(1)) // D0O_FILIAL+D0O_CODVOL+D0O_PRDORI+D0O_CODPRO+D0O_LOTECT+D0O_NUMLOT
	lAchou := D0O->(dbSeek(xFilial("D0O")+Self:GetCodVol()+Self:cPrdOri+Self:cProduto+Self:cLoteCtl+Self:cNumLote))
	Reclock('D0O',!lAchou)
	If !lAchou
		D0O->D0O_FILIAL := xFilial("DCT")
		D0O->D0O_CODVOL := Self:GetCodVol()
		D0O->D0O_PRDORI := Self:cPrdOri
		D0O->D0O_CODPRO := Self:cProduto
		D0O->D0O_LOTECT := Self:cLoteCtl
		D0O->D0O_NUMLOT := Self:cNumLote
		D0O->D0O_QUANT  := Self:nQuant
		D0O->D0O_CODOPE := Self:cCodOpe
	Else
		D0O->D0O_QUANT  += Self:nQuant
	EndIf
	D0O->(MsUnLock())
	D0O->(DbCommit())
	// Grava recno
	Self:nRecno := D0O->(Recno())
	// Adicionando o bloqueio de estoque
	lRet := Self:UpdSldBlq('499')
Return lRet

METHOD ExcludeD0O() CLASS WMSDTCVolumeCrossDockingItens
Local lRet := .T.
	D0O->(dbGoTo( Self:GetRecno() ))
	// Excluindo o registro do item no volume
	RecLock('D0O', .F.)
	D0O->(DbDelete())
	D0O->(MsUnlock())
	// Removendo o bloqueio de estoque
	lRet := Self:UpdSldBlq('999')
Return lRet

//-----------------------------------------------------------------------------
METHOD VldPrdCmp(lEstorno) CLASS WMSDTCVolumeCrossDockingItens
Local lAchou    := .F.
Local aAreaAnt  := GetArea()
Local cWhere    := ""
Local cAliasQry := Nil
Local cPrdOriAnt:= ""
Local nPrdOri   := 0
Local nOpcao    := 0
Default lEstorno:= .F.
	cAliasQry := GetNextAlias()
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND D14.D14_LOTECT   = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND D14.D14_NUMLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	If !lEstorno
		BeginSql Alias cAliasQry
			SELECT D14.D14_PRDORI
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL  = %Exp:Self:oVolume:GetArmazem()%
			AND D14.D14_ENDER  = %Exp:Self:oVolume:GetEnder()%
			AND D14.D14_PRODUT = %Exp:Self:cProduto%
			AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0
			AND D14.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT D14.D14_PRDORI
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL  = %Exp:Self:oVolume:GetArmazem()%
			AND D14.D14_ENDER  = %Exp:Self:oVolume:GetEnder()%
			AND D14.D14_PRODUT = %Exp:Self:cProduto%
			AND D14.D14_QTDEST > 0 
			AND D14.D14_QTDBLQ > 0
			AND D14.%NotDel%
			%Exp:cWhere%
		EndSql
	
	EndIf
	(cAliasQry)->(dbEval( {|| Iif(cPrdOriAnt!=D14_PRDORI,nPrdOri++,), cPrdOriAnt := D14_PRDORI }))
	// Pergunta o que deve considerar
	If nPrdOri > 1
		nOpcao := WmsMessage(STR0003,STR0002,4,.T.,{STR0004,STR0005}) // Montagem Volume // Considerar produto como: // Componente // Produto
	EndIf
	(cAliasQry)->(dbGoTop())
	Do While (cAliasQry)->(!Eof())
		If nPrdOri > 1
			// Quando "Componente", pula aquele que é produto
			If nOpcao == 1 .And. (cAliasQry)->D14_PRDORI == cProduto
				(cAliasQry)->(DbSkip())
				Loop
			EndIf
			// Quando "Produto", pula aquele que é componente
			If nOpcao == 2 .And. (cAliasQry)->D14_PRDORI != cProduto
				(cAliasQry)->(DbSkip())
				Loop
			EndIf
		EndIf
		Self:cPrdOri := (cAliasQry)->D14_PRDORI
		lAchou := .T.
		Exit
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lAchou

//-----------------------------------------------------------------------------
METHOD QtdPrdVol(lEstorno) CLASS WMSDTCVolumeCrossDockingItens
Local aAreaAnt  := GetArea()
Local aTamSX3   := TamSx3('D0O_QUANT')
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Default lEstorno:= .F.
	Self:nQuant := 0
	If !lEstorno
		// Parâmetro Where
		cWhere := "%"
		If !Empty(Self:cLoteCtl)
			cWhere += " AND D14.D14_LOTECT   = '"+Self:cLoteCtl+"'"
		EndIf
		If !Empty(Self:cNumLote)
			cWhere += " AND D14.D14_NUMLOT = '"+Self:cNumLote+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT SUM(D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) PRD_QUANT
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.D14_LOCAL =  %Exp:Self:oVolume:GetArmazem()%
			AND D14.D14_ENDER =  %Exp:Self:oVolume:GetEnder()%
			AND D14.D14_PRDORI = %Exp:Self:cPrdOri%
			AND D14.D14_PRODUT = %Exp:Self:cProduto%
			AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0
			AND D14.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		// Parâmetro Where
		cWhere := "%"
		If !Empty(Self:cLoteCtl)
			cWhere += " AND D0O.D0O_LOTECT = '"+Self:cLoteCtl+"'"
		EndIf
		If !Empty(Self:cNumLote)
			cWhere += " AND D0O.D0O_NUMLOT = '"+Self:cNumLote+"'"
		EndIf
		cWhere += "%"
		BeginSql Alias cAliasQry
			SELECT SUM(D0O.D0O_QUANT) PRD_QUANT
			FROM %Table:D0O% D0O
			WHERE D0O.D0O_FILIAL = %xFilial:D0O%
			AND D0O.D0O_CODVOL = %Exp:Self:oVolume:GetCodVol()%
			AND D0O.D0O_PRDORI = %Exp:Self:cPrdOri%
			AND D0O.D0O_CODPRO = %Exp:Self:cProduto%
			AND D0O.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	TcSetField(cAliasQry,'PRD_QUANT','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		Self:nQuant := (cAliasQry)->PRD_QUANT
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return Nil
//-----------------------------------------------------------------------------
// Carrega as quantidades a serem montadas volumes de acordo com os dados informados
// Pode ser que um produto informado gere mais de um registro em função de ser
// produto componente, ou controlar lote e não pedir lote no coletor
//-----------------------------------------------------------------------------
METHOD LoadPrdVol(aProdutos,nQtde) CLASS WMSDTCVolumeCrossDockingItens
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aTamD14   := TamSx3('D14_QTDEST')
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nQtdPrd   := 0

Default nQtde := 0
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND D14.D14_LOTECT   = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND D14.D14_NUMLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT D14.D14_PRDORI,
				D14.D14_PRODUT,
				D14.D14_LOTECT,
				D14.D14_NUMLOT,
				(D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) D14_SALDO"
		FROM %Table:D14% D14
		WHERE D14.D14_FILIAL = %xFilial:D14%
		AND D14.D14_LOCAL = %Exp:Self:oVolume:GetArmazem()%
		AND D14.D14_ENDER = %Exp:Self:oVolume:GetEnder()%
		AND D14.D14_PRDORI = %Exp:Self:cPrdOri%
		AND D14.D14_PRODUT = %Exp:Self:cProduto%
		AND (D14.D14_QTDEST - (D14.D14_QTDSPR + D14.D14_QTDEMP + D14.D14_QTDBLQ)) > 0
		AND D14.%NotDel%
		%Exp:cWhere%
	EndSql

	TcSetField(cAliasQry,'D14_SALDO','N',aTamD14[1],aTamD14[2])
	Do While (cAliasQry)->(!Eof())
		// Calcula a quantidade que pode ser "rateada" para este produto
		If QtdComp(nQtde) > QtdComp((cAliasQry)->D14_SALDO)
			nQtdPrd := (cAliasQry)->D14_SALDO
			nQtde   -= (cAliasQry)->D14_SALDO
		Else
			nQtdPrd := nQtde
			nQtde   := 0
		EndIf
		// Adiciona o produto no array de produtos a serem colocados no volume
		If QtdComp(nQtdPrd) > 0
			AAdd(aProdutos, {(cAliasQry)->D14_PRODUT, (cAliasQry)->D14_LOTECT, (cAliasQry)->D14_NUMLOT, nQtdPrd, (cAliasQry)->D14_PRDORI})
		EndIf
		// Se não é produto componente e zerou a quantidade, deve sair
		If QtdComp(nQtde) == 0
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
METHOD MntPrdVol(aProdutos) CLASS WMSDTCVolumeCrossDockingItens
Local lRet := .T.
Local nY   := 0
	Begin Transaction
		// Gravando a capa do volume
		If !(lRet := Self:oVolume:RecordD0N())
			Self:cErro := Self:oVolume:GetErro()
		EndIf
		If lRet
			// Gravando os itens do volume
			For nY := 1  To Len(aProdutos)
				Self:cProduto := aProdutos[nY][1]
				Self:cLoteCtl := aProdutos[nY][2]
				Self:cNumLote := aProdutos[nY][3]
				Self:nQuant   := aProdutos[nY][4]
				Self:cPrdOri  := aProdutos[nY][5]
				If !(lRet := Self:RecordD0O())
					Exit
				EndIf
			Next
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
Return lRet

//-----------------------------------------------------------------------------
METHOD EstPrdVol(aProdutos,lTotal,lBlqEst) CLASS WMSDTCVolumeCrossDockingItens
Local aAreaD0O := D0O->(GetArea())
Local lRet := .T.
Local nY   := 0
Default lTotal := .F.
Default lBlqEst:= .T.
	Begin Transaction
		If lRet
			D0O->(DbSetOrder(1)) // D0O_FILIAL+D0O_CODVOL+D0O_PRDORI+D0O_CODPRO+D0O_LOTECT+D0O_NUMLOT
			// Gravando os itens do volume
			For nY := 1  To Len(aProdutos)
				Self:cProduto := aProdutos[nY][1]
				Self:cLoteCtl := aProdutos[nY][2]
				Self:cNumLote := aProdutos[nY][3]
				Self:nQuant   := aProdutos[nY][4]
				Self:cPrdOri  := aProdutos[nY][5]
				If D0O->(dbSeek(xFilial("D0O")+Self:GetCodVol()+Self:cPrdOri+Self:cProduto+Self:cLoteCtl+Self:cNumLote))
					If !lTotal
						// Se sobrar quantidade deve apenas diminuir a quantidade
						RecLock('D0O', .F.)
						D0O->D0O_QUANT -= Self:nQuant
						If QtdComp(D0O->D0O_QUANT) == 0
							D0O->(DbDelete())
						EndIf
						D0O->(MsUnLock())
					Else
						RecLock('D0O', .F.)
						D0O->(DbDelete())
						D0O->(MsUnLock())
					EndIf
					If lBlqEst
						// Removendo o bloqueio de estoque
						If !(lRet := Self:UpdSldBlq('999'))
							Exit
						EndIf
					EndIf
				EndIf
			Next
			If !lTotal
				lTotal := D0O->(!dbSeek(xFilial("D0O")+Self:GetCodVol()))
			EndIf
			If lTotal
				If Self:oVolume:LoadData(1)
					lRet := Self:oVolume:ExcludeD0N()
				EndIf
			EndIf
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	RestArea(aAreaD0O)
Return lRet

//-----------------------------------------------------------------------------
METHOD UpdSldBlq(cTipo) CLASS WMSDTCVolumeCrossDockingItens
Local lRet := .T.
Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	// Carrega dados para LoadData EstEnder
	oEstEnder:ClearData()
	oEstEnder:oEndereco:SetArmazem(Self:oVolume:GetArmazem())
	oEstEnder:oEndereco:SetEnder(Self:oVolume:GetEnder())
	oEstEnder:oProdLote:SetArmazem(Self:oVolume:GetArmazem()) // Armazem
	oEstEnder:oProdLote:SetPrdOri(Self:cPrdOri)   // Produto Origem - Componente
	oEstEnder:oProdLote:SetProduto(Self:cProduto) // Produto Principal
	oEstEnder:oProdLote:SetLoteCtl(Self:cLoteCtl) // Lote do produto principal que deverá ser o mesmo no componentes
	oEstEnder:oProdLote:SetNumLote(Self:cNumLote) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
	oEstEnder:SetQuant(Self:nQuant)
	If !(lRet := oEstEnder:UpdSaldo(cTipo,.F.,.F.,.F.,.F.,.T.)) //cTipo,lEstoque,lEntPrev,lSaiPrev,lEmpenho,lBloqueio,lEmpPrev
		Self:cErro := oEstEnder:GetErro()
	EndIf
Return lRet
