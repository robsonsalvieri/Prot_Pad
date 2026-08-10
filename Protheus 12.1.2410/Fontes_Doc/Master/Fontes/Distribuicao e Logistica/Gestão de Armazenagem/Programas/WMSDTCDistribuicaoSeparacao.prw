#Include "Totvs.ch"  
#Include "WMSDTCDistribuicaoSeparacao.CH"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0017
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0017()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoSeparacao
Classe distribuição de separação
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoSeparacao FROM LongNameClass
	// Data
	DATA oDisEndDes
	DATA cCarga
	DATA cPedido
	DATA cCodDis
	DATA dData
	DATA cStatus
	DATA nQtdOri
	DATA nQtdSep
	DATA nQtdDis
	DATA nRecno
	DATA cErro
	DATA cLibEst
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD FindCodDis()
	METHOD RecordD0D()
	METHOD UpdateD0D()
	METHOD ExcludeD0D()
	METHOD ChkPedFat()
	METHOD Destroy()
	METHOD UpdLibEst()
	// Setters
	METHOD SetPedido(cPedido)
	METHOD SetCarga(cCarga)
	METHOD SetCodDis(cCodDis)
	METHOD SetData(dData)
	METHOD SetStatus(cStatus)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSep(nQtdSep)
	METHOD SetQtdDis(nQtdDis)
	METHOD SetLibEst(cLibEst)
	// Getters
	METHOD GetPedido()
	METHOD GetCarga()
	METHOD GetCodDis()
	METHOD GetData()
	METHOD GetStatus()
	METHOD GetQtdOri()
	METHOD GetQtdSep()
	METHOD GetQtdDis()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD GetLibEst()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.correa
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoSeparacao
	Self:oDisEndDes := WMSDTCEndereco():New()
	Self:cPedido    := PadR("", TamSx3("D0D_PEDIDO")[1])
	Self:cCarga     := PadR("", TamSx3("D0D_CARGA")[1])
	Self:cCodDis    := PadR("", TamSx3("D0D_CODDIS")[1])
	Self:dData      := dDataBase
	Self:cStatus    := "1"
	Self:nQtdOri    := 0
	Self:nQtdSep    := 0
	Self:nQtdDis    := 0
	Self:cErro      := ""
	Self:cLibEst    := "2"
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoSeparacao
	//Mantido para compatibilidade
Return

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D01
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoSeparacao
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aD0D_QTDORI := TamSx3("D0D_QTDORI")
Local aD0D_QTDSEP := TamSx3("D0D_QTDSEP")
Local aD0D_QTDDIS := TamSx3("D0D_QTDDIS") 
Local aAreaD0D    := D0D->(GetArea())
Local cAliasD0D   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 1 // D0D_FILIAL+D0D_CODDIS+D0D_CARGA+D0D_PEDIDO
			If Empty(Self:cCodDis) .Or. Empty(Self:cPedido) .Or. Empty(Self:oDisEndDes:GetArmazem())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		cAliasD0D := GetNextAlias()
		Do Case
			Case nIndex == 1
				If !Empty(Self:cCarga) .And. WmsCarga(Self:cCarga)
					BeginSql Alias cAliasD0D
						SELECT D0D.D0D_CODDIS,
								D0D.D0D_CARGA,
								D0D.D0D_PEDIDO,
								D0D.D0D_DATA,
								D0D.D0D_STATUS,
								D0D.D0D_QTDORI,
								D0D.D0D_QTDSEP,
								D0D.D0D_QTDDIS,
								D0D.D0D_LOCDES,
								D0D.D0D_ENDDES,
								D0D.D0D_LIBEST,
								D0D.R_E_C_N_O_ RECNOD0D
						FROM %Table:D0D% D0D
						WHERE D0D.D0D_FILIAL = %xFilial:D0D%
						AND D0D.D0D_CODDIS = %Exp:Self:cCodDis%
						AND D0D.D0D_CARGA =  %Exp:Self:cCarga%
						AND D0D.D0D_PEDIDO = %Exp:Self:cPedido%
						AND D0D.D0D_LOCDES = %Exp:Self:oDisEndDes:GetArmazem()%
						AND D0D.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD0D
						SELECT D0D.D0D_CODDIS,
								D0D.D0D_CARGA,
								D0D.D0D_PEDIDO,
								D0D.D0D_DATA,
								D0D.D0D_STATUS,
								D0D.D0D_QTDORI,
								D0D.D0D_QTDSEP,
								D0D.D0D_QTDDIS,
								D0D.D0D_LOCDES,
								D0D.D0D_ENDDES,
								D0D.D0D_LIBEST,
								D0D.R_E_C_N_O_ RECNOD0D
						FROM %Table:D0D% D0D
						WHERE D0D.D0D_FILIAL = %xFilial:D0D%
						AND D0D.D0D_CODDIS = %Exp:Self:cCodDis%
						AND D0D.D0D_PEDIDO = %Exp:Self:cPedido%
						AND D0D.D0D_LOCDES = %Exp:Self:oDisEndDes:GetArmazem()%
						AND D0D.%NotDel%
					EndSql
				EndIf
		EndCase
		TCSetField(cAliasD0D,'D0D_QTDORI','N',aD0D_QTDORI[1],aD0D_QTDORI[2])
		TCSetField(cAliasD0D,'D0D_QTDSEP','N',aD0D_QTDSEP[1],aD0D_QTDSEP[2])
		TCSetField(cAliasD0D,'D0D_QTDDIS','N',aD0D_QTDDIS[1],aD0D_QTDDIS[2])
		TcSetField(cAliasD0D,'D0D_DATA','D')
		If (lRet := (cAliasD0D)->(!Eof()))
			Self:SetCodDis((cAliasD0D)->D0D_CODDIS)
			Self:SetCarga((cAliasD0D)->D0D_CARGA)
			Self:SetPedido((cAliasD0D)->D0D_PEDIDO)
			
			Self:oDisEndDes:SetArmazem((cAliasD0D)->D0D_LOCDES)
			Self:oDisEndDes:SetEnder((cAliasD0D)->D0D_ENDDES)
			Self:oDisEndDes:LoadData()
			// Busca dados lote/produto
			Self:dData   := (cAliasD0D)->D0D_DATA
			Self:cStatus := (cAliasD0D)->D0D_STATUS
			Self:nQtdOri := (cAliasD0D)->D0D_QTDORI
			Self:nQtdSep := (cAliasD0D)->D0D_QTDSEP
			Self:nQtdDis := (cAliasD0D)->D0D_QTDDIS
			Self:cLibEst := (cAliasD0D)->D0D_LIBEST
			Self:nRecno  := (cAliasD0D)->RECNOD0D
		EndIf
		(cAliasD0D)->(dbCloseArea())
	EndIf		
	RestArea(aAreaD0D)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
//Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCDistribuicaoSeparacao
	Self:cCarga := PadR(cCarga, Len(Self:cCarga))
Return

METHOD SetPedido(cPedido) CLASS WMSDTCDistribuicaoSeparacao
	Self:cPedido := PadR(cPedido, Len(Self:cPedido))
Return

METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoSeparacao
	Self:cCodDis := PadR(cCodDis, Len(Self:cCodDis))
Return

METHOD SetData(dData) CLASS WMSDTCDistribuicaoSeparacao
	Self:dData := dData
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCDistribuicaoSeparacao
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSep(nQtdSep) CLASS WMSDTCDistribuicaoSeparacao
	Self:nQtdSep := nQtdSep
Return

METHOD SetQtdDis(nQtdDis) CLASS WMSDTCDistribuicaoSeparacao
	Self:nQtdDis := nQtdDis
Return

METHOD SetStatus(cStatus) CLASS WMSDTCDistribuicaoSeparacao
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetLibEst(cLibEst) CLASS WMSDTCDistribuicaoSeparacao
	Self:cLibEst := PadR(cLibEst, Len(Self:cLibEst))
Return 
//-----------------------------------
//Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCDistribuicaoSeparacao
Return Self:cCarga

METHOD GetPedido() CLASS WMSDTCDistribuicaoSeparacao
Return Self:cPedido

METHOD GetCodDis() CLASS WMSDTCDistribuicaoSeparacao
Return Self:cCodDis

METHOD GetData() CLASS WMSDTCDistribuicaoSeparacao
Return Self:dData

METHOD GetQtdOri() CLASS WMSDTCDistribuicaoSeparacao
Return Self:nQtdOri

METHOD GetQtdSep() CLASS WMSDTCDistribuicaoSeparacao
Return Self:nQtdSep

METHOD GetQtdDis() CLASS WMSDTCDistribuicaoSeparacao
Return Self:nQtdDis

METHOD GetStatus() CLASS WMSDTCDistribuicaoSeparacao
Return Self:cStatus

METHOD GetRecno() CLASS WMSDTCDistribuicaoSeparacao
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCDistribuicaoSeparacao
Return Self:cErro

METHOD GetLibEst() CLASS WMSDTCDistribuicaoSeparacao
Return Self:cLibEst

METHOD FindCodDis() CLASS WMSDTCDistribuicaoSeparacao
Local aAreaAnt  := GetArea()
Local cAliasD0D := GetNextAlias()
Local cCodDis   := ""
	cAliasD0D := GetNextAlias()
	BeginSql Alias cAliasD0D
		SELECT MAX(D0D.D0D_CODDIS) D0D_CODDIS
		FROM %Table:D0D% D0D
		WHERE D0D.D0D_FILIAL = %xFilial:D0D%
		AND D0D.D0D_CARGA  = %Exp:Self:cCarga%
		AND D0D.D0D_PEDIDO = %Exp:Self:cPedido%
		AND D0D.D0D_LOCDES = %Exp:Self:oDisEndDes:GetArmazem()%
		AND D0D.%NotDel%
	EndSql
	If (cAliasD0D)->(!Eof())
		cCodDis := (cAliasD0D)->D0D_CODDIS
	EndIf
	(cAliasD0D)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cCodDis

METHOD RecordD0D() CLASS WMSDTCDistribuicaoSeparacao
Local lRet := .T.
	Self:cCodDis := GetSX8Num('D0D','D0D_CODDIS'); IIf(__lSX8,ConfirmSX8(),)
	Self:cStatus := "1"
	Self:nQtdOri := 0
	Self:nQtdSep := 0
	Self:nQtdDis := 0
	// Grava DCF
	D0D->(dbSetOrder(1))
	If !D0D->(dbSeek(xFilial("D0D")+Self:cCodDis+Self:cCarga+Self:cPedido+Self:oDisEndDes:GetArmazem()))
		RecLock('D0D', .T.)
		D0D->D0D_FILIAL := xFilial("D0D")
		D0D->D0D_CODDIS := Self:cCodDis
		D0D->D0D_CARGA  := Self:cCarga
		D0D->D0D_PEDIDO := Self:cPedido
		D0D->D0D_DATA   := Self:dData
		D0D->D0D_LOCDES := Self:oDisEndDes:GetArmazem()
		D0D->D0D_ENDDES := Self:oDisEndDes:GetEnder()
		D0D->D0D_QTDORI := Self:nQtdOri
		D0D->D0D_QTDSEP := Self:nQtdSep
		D0D->D0D_QTDDIS := Self:nQtdDis
		D0D->D0D_STATUS := Self:cStatus
		D0D->D0D_LIBEST := "2"
		D0D->(MsUnLock())
		// Grava recno
		Self:nRecno := D0D->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD0D() CLASS WMSDTCDistribuicaoSeparacao
Local lRet     := .T.
	If !Empty(Self:GetRecno())
		D0D->(dbGoTo( Self:GetRecno() ))
		// Status
		If QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdDis) .And. QtdComp(Self:nQtdOri) > 0
			Self:cStatus := "2" // Finalizado
		Else
			Self:cStatus := "1" // Não Iniciado
		EndIf		
		// Grava D0D
		RecLock('D0D', .F.)
		D0D->D0D_LOCDES := Self:oDisEndDes:GetArmazem()
		D0D->D0D_ENDDES := Self:oDisEndDes:GetEnder()
		D0D->D0D_QTDORI := Self:nQtdOri
		D0D->D0D_QTDSEP := Self:nQtdSep
		D0D->D0D_QTDDIS := Self:nQtdDis
		D0D->D0D_STATUS := Self:cStatus
		D0D->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0004 // Dados não encontrados!
	EndIf
Return lRet

METHOD ExcludeD0D() CLASS WMSDTCDistribuicaoSeparacao
Local lRet     := .T.
	D0D->(dbGoTo( Self:GetRecno() ))
	RecLock('D0D', .F.)
	D0D->(DbDelete())
	D0D->(MsUnlock())
Return lRet

METHOD ChkPedFat() CLASS WMSDTCDistribuicaoSeparacao
Local lRet      := .F.
Local lCarga    := WmsCarga(Self:cCarga)
Local aAreaAnt  := GetArea()
Local aTamSx3   := TamSx3("C9_QTDLIB")
Local cAliasSC9 := GetNextAlias()

	If lCarga
		BeginSql Alias cAliasSC9
			SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB
			FROM %Table:SC9% SC9
			INNER JOIN %Table:D0J% D0J
			ON D0J.D0J_FILIAL = %xFilial:D0J%
			AND D0J.D0J_CODDIS = %Exp:Self:GetCodDis()%
			AND D0J.D0J_IDDCF = SC9.C9_IDDCF
			AND D0J.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA = %Exp:Self:cCarga%
			AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
			// Precisa validar se tem alguma coisa distribuida
			AND EXISTS (SELECT 1 FROM %Table:D0E% D0E
						WHERE D0E.D0E_FILIAL = %xFilial:D0E%
						AND D0E.D0E_CARGA = SC9.C9_CARGA
						AND D0E.D0E_PEDIDO = SC9.C9_PEDIDO
						AND D0E.D0E_PRDORI = SC9.C9_PRODUTO
						AND D0E.D0E_CODDIS = D0J.D0J_CODDIS
						AND D0E.D0E_QTDDIS > 0
						AND D0E.%NotDel% )
		EndSql
	Else
		BeginSql Alias cAliasSC9
			SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB
			FROM %Table:SC9% SC9
			INNER JOIN %Table:D0J% D0J
			ON D0J.D0J_FILIAL = %xFilial:D0J%
			AND D0J.D0J_CODDIS = %Exp:Self:GetCodDis()%
			AND D0J.D0J_IDDCF = SC9.C9_IDDCF
			AND D0J.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
			// Precisa validar se tem alguma coisa distribuida
			AND EXISTS (SELECT 1 FROM %Table:D0E% D0E
						WHERE D0E.D0E_FILIAL = %xFilial:D0E%
						AND D0E.D0E_PEDIDO = SC9.C9_PEDIDO
						AND D0E.D0E_PRDORI = SC9.C9_PRODUTO
						AND D0E.D0E_CODDIS = D0J.D0J_CODDIS
						AND D0E.D0E_QTDDIS > 0
						AND D0E.%NotDel% )
		EndSql
	EndIf
	TcSetField(cAliasSC9,'C9_QTDLIB','N',aTamSX3[1],aTamSX3[2])
	If (cAliasSC9)->(!Eof()) .And. QtdComp((cAliasSC9)->C9_QTDLIB) > 0
		If QtdComp(Self:nQtdOri) == QtdComp((cAliasSC9)->C9_QTDLIB)
			lRet := .T.
		EndIf
	EndIf
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

METHOD UpdLibEst() CLASS WMSDTCDistribuicaoSeparacao
Local aAreaAnt := GetArea()
	D0D->(dbGoTo(Self:GetRecno()))
	RecLock("D0D",.F.)
	D0D->D0D_LIBEST := Self:GetLibEst()
	D0D->(MsUnlock())
	RestArea(aAreaAnt)
Return Nil
