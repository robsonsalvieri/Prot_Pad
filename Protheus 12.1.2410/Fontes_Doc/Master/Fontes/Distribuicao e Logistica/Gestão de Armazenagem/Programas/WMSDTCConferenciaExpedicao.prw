#Include "Totvs.ch" 
#Include "WMSDTCConferenciaExpedicao.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0009
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0009()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCConferenciaExpedicao
Classe para analise e geração da conferência de expedição
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCConferenciaExpedicao FROM LongNameClass
	// Data
	DATA cCarga
	DATA cPedido
	DATA cCodExp
	DATA cStatus
	DATA dData
	DATA cHora
	DATA cLibPed
	DATA nQtdOri
	DATA nQtdSep
	DATA nQtdCof
	DATA cLibEst
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD FindCodExp()
	METHOD RecordD01()
	METHOD UpdateD01()
	// Setters
	METHOD SetPedido(cPedido)
	METHOD SetCarga(cCarga)
	METHOD SetCodExp(cCodExp)
	METHOD SetStatus(cStatus)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSep(nQtdSep)
	METHOD SetQtdCof(nQtdCof)
	METHOD SetLibPed(cLibPed)
	METHOD SetLibEst(cLibEst)
	// Getters	
	METHOD GetPedido()
	METHOD GetCarga()
	METHOD GetCodExp()
	METHOD GetStatus()
	METHOD GetLibPed()
	METHOD GetQtdOri()
	METHOD GetQtdSep()
	METHOD GetQtdCof()
	METHOD GetLibEst()
	METHOD GetRecno()
	METHOD GetErro()
	// Metodos
	METHOD ExcludeD01()
	METHOD ChkPedFat()
	METHOD UpdLibEst()
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.corra
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCConferenciaExpedicao
	Self:cPedido    := PadR("", TamSx3("D01_PEDIDO")[1])
	Self:cCarga     := PadR("", TamSx3("D01_CARGA")[1])
	Self:cCodExp    := PadR("", TamSx3("D01_CODEXP")[1])
	Self:cStatus    := "1"
	Self:nQtdOri    := 0
	Self:nQtdSep    := 0
	Self:nQtdCof    := 0
	Self:cLibPed    := "3"
	Self:dData      := dDataBase
	Self:cHora      := Time()
	Self:cLibEst    := "2"
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCConferenciaExpedicao
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
METHOD LoadData(nIndex) CLASS WMSDTCConferenciaExpedicao
Local lRet        := .T.
Local aAreaAnt   := GetArea()
Local aD01_QTORIG := TamSx3("D01_QTORIG")
Local aD01_QTSEPA := TamSx3("D01_QTSEPA")
Local aD01_QTCONF := TamSx3("D01_QTCONF") 
Local aAreaD01    := D01->(GetArea())
Local cAliasD01   := GetNextAlias()

Default nIndex := 1
	Do Case
		Case nIndex == 1 // D01_FILIAL+D01_CODEXP+D01_CARGA+D01_PEDIDO
			If Empty(Self:cCodExp) .Or. Empty(Self:cPedido)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD01 := GetNextAlias()
		Do Case
			Case nIndex = 1
				If !Empty(Self:cCarga) .And. WMSCarga(Self:cCarga)
					BeginSql Alias cAliasD01
						SELECT D01.D01_CODEXP,
								D01.D01_CARGA,
								D01.D01_PEDIDO,
								D01.D01_STATUS,
								D01.D01_QTORIG,
								D01.D01_QTSEPA,
								D01.D01_QTCONF,
								D01.D01_LIBPED,
								D01.D01_DATA,
								D01.D01_HORA,
								D01.D01_LIBEST,
								D01.R_E_C_N_O_ RECNOD01
						FROM %Table:D01% D01
						WHERE D01.D01_FILIAL = %xFilial:D01%
						AND D01.D01_CODEXP = %Exp:Self:cCodExp%
						AND D01.D01_CARGA = %Exp:Self:cCarga%
						AND D01.D01_PEDIDO = %Exp:Self:cPedido%
						AND D01.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD01
						SELECT D01.D01_CODEXP,
								D01.D01_CARGA,
								D01.D01_PEDIDO,
								D01.D01_STATUS,
								D01.D01_QTORIG,
								D01.D01_QTSEPA,
								D01.D01_QTCONF,
								D01.D01_LIBPED,
								D01.D01_DATA,
								D01.D01_HORA,
								D01.D01_LIBEST,
								D01.R_E_C_N_O_ RECNOD01
						FROM %Table:D01% D01
						WHERE D01.D01_FILIAL = %xFilial:D01%
						AND D01.D01_CODEXP = %Exp:Self:cCodExp%
						AND D01.D01_PEDIDO = %Exp:Self:cPedido%
						AND D01.%NotDel%
					EndSql				
				EndIf
		EndCase
		TCSetField(cAliasD01,'D01_QTORIG','N',aD01_QTORIG[1],aD01_QTORIG[2])
		TCSetField(cAliasD01,'D01_QTSEPA','N',aD01_QTSEPA[1],aD01_QTSEPA[2])
		TCSetField(cAliasD01,'D01_QTCONF','N',aD01_QTCONF[1],aD01_QTCONF[2])
		TcSetField(cAliasD01,'D01_DATA','D')
		If (lRet := (cAliasD01)->(!Eof()))
			// Busca dados lote/produto
			Self:cCodExp := (cAliasD01)->D01_CODEXP
			Self:cCarga  := (cAliasD01)->D01_CARGA
			Self:cPedido := (cAliasD01)->D01_PEDIDO
			Self:cStatus := (cAliasD01)->D01_STATUS
			Self:nQtdOri := (cAliasD01)->D01_QTORIG
			Self:nQtdSep := (cAliasD01)->D01_QTSEPA
			Self:nQtdCof := (cAliasD01)->D01_QTCONF
			Self:cLibPed := (cAliasD01)->D01_LIBPED
			Self:dData   := (cAliasD01)->D01_DATA
			Self:cHora   := (cAliasD01)->D01_HORA
			Self:cLibEst := (cAliasD01)->D01_LIBEST
			Self:nRecno  := (cAliasD01)->RECNOD01
		EndIf
		(cAliasD01)->(dbCloseArea())
	EndIf
	RestArea(aAreaD01)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCConferenciaExpedicao
	Self:cCarga := PadR(cCarga, Len(Self:cCarga))
Return

METHOD SetPedido(cPedido) CLASS WMSDTCConferenciaExpedicao
	Self:cPedido := PadR(cPedido, Len(Self:cPedido))
Return

METHOD SetCodExp(cCodExp) CLASS WMSDTCConferenciaExpedicao
	Self:cCodExp := PadR(cCodExp, Len(Self:cCodExp))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCConferenciaExpedicao
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCConferenciaExpedicao
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSep(nQtdSep) CLASS WMSDTCConferenciaExpedicao
	Self:nQtdSep := nQtdSep
Return

METHOD SetQtdCof(nQtdCof) CLASS WMSDTCConferenciaExpedicao
	Self:nQtdCof := nQtdCof
Return

METHOD SetLibPed(cLibPed) CLASS WMSDTCConferenciaExpedicao
	Self:cLibPed := PadR(cLibPed, Len(Self:cLibPed))
Return

METHOD SetLibEst(cLibEst) CLASS WMSDTCConferenciaExpedicao
	Self:cLibEst := PadR(cLibEst, Len(Self:cLibEst))
Return 
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCConferenciaExpedicao
Return Self:cCarga

METHOD GetPedido() CLASS WMSDTCConferenciaExpedicao
Return Self:cPedido

METHOD GetCodExp() CLASS WMSDTCConferenciaExpedicao
Return Self:cCodExp

METHOD GetStatus() CLASS WMSDTCConferenciaExpedicao
Return Self:cStatus

METHOD GetQtdOri() CLASS WMSDTCConferenciaExpedicao
Return Self:nQtdOri

METHOD GetQtdSep() CLASS WMSDTCConferenciaExpedicao
Return Self:nQtdSep

METHOD GetQtdCof() CLASS WMSDTCConferenciaExpedicao
Return Self:nQtdCof

METHOD GetLibEst() CLASS WMSDTCConferenciaExpedicao
Return Self:cLibEst

METHOD GetLibPed() CLASS WMSDTCConferenciaExpedicao
Return Self:cLibPed

METHOD GetRecno() CLASS WMSDTCConferenciaExpedicao
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCConferenciaExpedicao
Return Self:cErro

METHOD FindCodExp() CLASS WMSDTCConferenciaExpedicao
Local aAreaAnt  := GetArea()
Local cAliasD01 := GetNextAlias()
Local cCodExp   := ""
	BeginSql Alias cAliasD01
		SELECT MAX(D01_CODEXP) D01_CODEXP
		FROM %Table:D01% D01
		WHERE D01.D01_FILIAL = %xFilial:D01%
		AND D01.D01_CARGA = %Exp:Self:cCarga%
		AND D01.D01_PEDIDO = %Exp:Self:cPedido%
		AND D01.%NotDel%
	EndSql
	If (cAliasD01)->(!Eof())
		cCodExp := (cAliasD01)->D01_CODEXP
	EndIf
	(cAliasD01)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cCodExp

METHOD RecordD01() CLASS WMSDTCConferenciaExpedicao
Local lRet     := .T.
	Self:cCodExp := GetSX8Num('D01','D01_CODEXP'); IIf(__lSX8,ConfirmSX8(),)
	Self:cStatus := "1"
	Self:nQtdCof := 0
	Self:dData   := dDataBase
	Self:cHora   := Time()
	// Grava D1
	D01->(dbSetOrder(1))
	If !D01->(dbSeek(xFilial("D01")+Self:cCodExp+Self:cCarga+Self:cPedido))
		RecLock('D01', .T.)
		D01->D01_FILIAL := xFilial("D01")
		D01->D01_CODEXP := Self:cCodExp
		D01->D01_CARGA  := Self:cCarga
		D01->D01_PEDIDO := Self:cPedido
		D01->D01_STATUS := Self:cStatus
		D01->D01_QTORIG := Self:nQtdOri
		D01->D01_QTSEPA := Self:nQtdSep
		D01->D01_QTCONF := Self:nQtdCof
		D01->D01_LIBPED := Self:cLibPed
		D01->D01_DATA   := Self:dData
		D01->D01_HORA   := Self:cHora
		D01->D01_LIBEST := "2"
		D01->(MsUnLock())
		// Grava recno
		Self:nRecno := D01->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada! 
	EndIf
Return lRet

METHOD ExcludeD01() CLASS WMSDTCConferenciaExpedicao
Local lRet := .T.
	D01->(dbGoTo( Self:GetRecno() ))
	// Excluindo a capa da conferencia de expedição
	RecLock('D01', .F.)
	D01->(dbDelete())
	D01->(MsUnlock())
Return lRet

METHOD UpdateD01() CLASS WMSDTCConferenciaExpedicao
Local lRet      := .T.
Local cAliasD02 := Nil 
	If !Empty(Self:GetRecno())
		D01->(dbGoTo( Self:GetRecno() ))
		// Define o status
		If QtdComp(Self:nQtdCof) == 0
			// Verica se há algum produto da carga/pedido que esteja em andamento
			// situação ocorrerá quando produto/componente
			cAliasD02 := GetNextAlias()
			BeginSql Alias cAliasD02
				SELECT 1
				FROM %Table:D02% D02
				WHERE D02.D02_FILIAL = %xFilial:D02%
				AND D02.D02_CODEXP = %Exp:D01->D01_CODEXP%
				AND D02.D02_CARGA = %Exp:D01->D01_CARGA%
				AND D02.D02_PEDIDO = %Exp:D01->D01_PEDIDO%
				AND D02.D02_CODPRO <> D02.D02_PRDORI
				AND D02.D02_STATUS <> '1'
				AND D02.%NotDel%
			EndSql
			If (cAliasD02)->(!Eof())
				Self:cStatus := "2" // Em Andamente
			Else
				Self:cStatus := "1" // Não Iniciado
			EndIf
			(cAliasD02)->(dbCloseArea())
		ElseIf QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdCof)
			Self:cStatus := "3" // Finalizado			
		Else 
			Self:cStatus := "2" // Em Andamente
		EndIf
		// Grava D01
		RecLock('D01', .F.)
		D01->D01_QTORIG := Self:nQtdOri
		D01->D01_QTSEPA := Self:nQtdSep
		D01->D01_QTCONF := Self:nQtdCof
		D01->D01_STATUS := Self:cStatus
		D01->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
Return lRet

METHOD ChkPedFat() CLASS WMSDTCConferenciaExpedicao
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local aTamSx3   := TamSX3("C9_QTDLIB")
Local cAliasSC9 := GetNextAlias()

	If WmsCarga(Self:cCarga)
		BeginSql Alias cAliasSC9
			SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB
			FROM %Table:SC9% SC9
			INNER JOIN %Table:D0H% D0H
			ON D0H.D0H_FILIAL = %xFilial:D0H%
			AND D0H.D0H_CODEXP = %Exp:Self:cCodExp%
			AND D0H.D0H_IDDCF = SC9.C9_IDDCF
			AND D0H.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA = %Exp:Self:cCarga%
			AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasSC9
			SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB
			FROM %Table:SC9% SC9
			INNER JOIN %Table:D0H% D0H
			ON D0H.D0H_FILIAL = %xFilial:D0H%
			AND D0H.D0H_CODEXP = %Exp:Self:cCodExp%
			AND D0H.D0H_IDDCF = SC9.C9_IDDCF
			AND D0H.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
		EndSql
	End
	TcSetField(cAliasSC9,'C9_QTDLIB','N',aTamSX3[1],aTamSX3[2])
	If (cAliasSC9)->(!Eof()) .And. QtdComp((cAliasSC9)->C9_QTDLIB) > 0
		If QtdComp(Self:nQtdOri) == QtdComp((cAliasSC9)->C9_QTDLIB)
			lRet := .T.
		EndIf
	EndIf
	(cAliasSC9)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

METHOD UpdLibEst() CLASS WMSDTCConferenciaExpedicao
Local aAreaAnt := GetArea()
	D01->(dbGoTo(Self:GetRecno()))
	RecLock("D01",.F.)
	D01->D01_LIBEST := Self:GetLibEst()
	D01->(MsUnlock())
	RestArea(aAreaAnt)
Return Nil
