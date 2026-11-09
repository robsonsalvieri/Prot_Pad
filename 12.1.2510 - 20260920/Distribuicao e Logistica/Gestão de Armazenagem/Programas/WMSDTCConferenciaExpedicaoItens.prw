#Include 'TOTVS.CH'
#Include 'WMSDTCConferenciaExpedicaoItens.CH'
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0011
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0011()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCConferenciaExpedicaoItens
Classe itens da conferência de expedição
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCConferenciaExpedicaoItens FROM LongNameClass
	// Data
	DATA oConfExp
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cStatus
	DATA nQtdCof
	DATA nQtdOri
	DATA nQtdSep
	DATA nTotOri
	DATA nTotSep
	DATA nTotCof
	DATA nRecno
	DATA cErro
	DATA cIdDCF
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD02(nRecno)
	METHOD LoadData(nIndex)
	METHOD AssignD0H()
	METHOD DeleteD0H()
	METHOD AssignD02()
	METHOD RecordD02()
	METHOD UpdateD02()
	// Setters
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetCodExp(cCodExp)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetStatus(cStatus)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSep(nQtdSep)
	METHOD SetQtdCof(nQtdCof)
	METHOD SetLibPed(cLibPed)
	METHOD SetIdDCF(cIdDCF)
	// Getters
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetCodExp()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetStatus()
	METHOD GetQtdOri()
	METHOD GetQtdSep()
	METHOD GetQtdCof()
	METHOD GetTotOri()
	METHOD GetTotSep()
	METHOD GetTotCof()
	METHOD GetLibPed()
	METHOD GetIdDCF()
	METHOD GetRecno()
	METHOD GetErro()
	// Metodos
	METHOD CalcConfExp(nAcao)
	METHOD RevConfExp(nQtdOri,nQtdSep)
	METHOD DelConfExp()
	METHOD Destroy()
	METHOD UpdQtdParc(nQtdQuebra,lBxEmp)
	METHOD GerAIdDCF()
	METHOD CalcQtdCof()
	METHOD ChkQtdCof(aIdDCFs)
	
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.correa
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCConferenciaExpedicaoItens
	Self:oConfExp   := WMSDTCConferenciaExpedicao():New()
	Self:cPrdOri    := PadR("", TamSx3("D02_PRDORI")[1])
	Self:cProduto   := PadR("", TamSx3("D02_CODPRO")[1])
	Self:cLoteCtl   := PadR("", TamSx3("D02_LOTE")[1])
	Self:cNumLote   := PadR("", TamSx3("D02_SUBLOT")[1])
	Self:cStatus    := "1"
	Self:nQtdOri    := 0
	Self:nQtdSep    := 0
	Self:nQtdCof    := 0
	Self:nTotOri    := 0
	Self:nTotSep    := 0
	Self:nTotCof    := 0
	Self:cIdDCF     := ""
	Self:nRecno     := 0
	Self:cErro      := ""
Return

METHOD Destroy() CLASS WMSDTCConferenciaExpedicaoItens
	//Mantido para compatibilidade
Return
//----------------------------------------
/*/{Protheus.doc} GoToD02
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecnoD0E, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToD02(nRecno) CLASS WMSDTCConferenciaExpedicaoItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D02
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCConferenciaExpedicaoItens
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aD02_QTORIG:= TamSx3("D02_QTORIG")
Local aD02_QTSEPA:= TamSx3("D02_QTSEPA")
Local aD02_QTCONF:= TamSx3("D02_QTCONF")
Local aAreaD02   := D02->(GetArea())
Local cWhere     := ""
Local cAliasD02  := Nil

Default nIndex   := 1
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
			If Empty(Self:GetCodExp()) .Or. Empty(Self:GetPedido()) .Or. Empty(Self:cPrdOri) .Or. Empty(Self:cProduto)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD02  := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD02
					SELECT D02.D02_CODEXP,
							D02.D02_CARGA,
							D02.D02_PEDIDO,
							D02.D02_PRDORI,
							D02.D02_CODPRO,
							D02.D02_LOTE,
							D02.D02_SUBLOT,
							D02.D02_STATUS,
							D02.D02_QTSEPA,
							D02.D02_QTORIG,
							D02.D02_QTCONF,
							D02.R_E_C_N_O_ RECNOD02
					FROM %Table:D02% D02
					WHERE D02.D02_FILIAL = %xFilial:D02%
					AND D02.R_E_C_N_O_   = %EXP:Self:nRecno%
					AND D02.%NotDel%
				EndSql
			Case nIndex == 1
				cWhere := "%"
				If !Empty(Self:GetCarga()) .And. WMSCarga(Self:GetCarga())
					cWhere += " AND D02.D02_CARGA  = '" + Self:GetCarga()  + "'"
				EndIf
				If !Empty(Self:cLoteCtl)
					cWhere += " AND D02.D02_LOTE   = '" + Self:cLoteCtl    + "'"
				EndIf
				If !Empty(Self:cNumLote)
					cWhere += " AND D02.D02_SUBLOT = '" + Self:cNumLote    + "'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD02
					SELECT D02.D02_CODEXP,
							D02.D02_CARGA,
							D02.D02_PEDIDO,
							D02.D02_PRDORI,
							D02.D02_CODPRO,
							D02.D02_LOTE,
							D02.D02_SUBLOT,
							D02.D02_STATUS,
							D02.D02_QTSEPA,
							D02.D02_QTORIG,
							D02.D02_QTCONF,
							D02.R_E_C_N_O_ RECNOD02
					FROM %Table:D02% D02
					WHERE D02.D02_FILIAL = %xFilial:D02%
					AND D02.D02_CODEXP = %Exp:Self:GetCodExp()%
					AND D02.D02_PEDIDO = %Exp:Self:GetPedido()%
					AND D02.D02_PRDORI = %Exp:Self:cPrdOri%
					AND D02.D02_CODPRO = %Exp:Self:cProduto%
					AND D02.%NotDel%
					%Exp:cWhere%
				EndSql
		EndCase
		TCSetField(cAliasD02,'D02_QTORIG','N',aD02_QTORIG[1],aD02_QTORIG[2])
		TCSetField(cAliasD02,'D02_QTSEPA','N',aD02_QTSEPA[1],aD02_QTSEPA[2])
		TCSetField(cAliasD02,'D02_QTCONF','N',aD02_QTCONF[1],aD02_QTCONF[2])
		If (lRet := (cAliasD02)->(!Eof()))
			Self:SetCodExp((cAliasD02)->D02_CODEXP)
			Self:SetCarga((cAliasD02)->D02_CARGA)
			Self:SetPedido((cAliasD02)->D02_PEDIDO)
			// Montagem
			Self:oConfExp:LoadData()
			// Busca dados lote/produto
			Self:cPrdOri  := (cAliasD02)->D02_PRDORI
			Self:cProduto := (cAliasD02)->D02_CODPRO
			Self:cLoteCtl := (cAliasD02)->D02_LOTE
			Self:cNumLote := (cAliasD02)->D02_SUBLOT
			// Busca dados endereco origem
			// Dados complementares
			Self:cStatus  := (cAliasD02)->D02_STATUS
			Self:nQtdOri  := (cAliasD02)->D02_QTORIG
			Self:nQtdSep  := (cAliasD02)->D02_QTSEPA
			Self:nQtdCof  := (cAliasD02)->D02_QTCONF
			Self:nRecno   := (cAliasD02)->RECNOD02
		EndIf
		(cAliasD02)->(dbCloseArea())
	EndIf
	RestArea(aAreaD02)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCConferenciaExpedicaoItens
	Self:oConfExp:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCConferenciaExpedicaoItens
	Self:oConfExp:SetPedido(cPedido)
Return

METHOD SetCodExp(cCodExp) CLASS WMSDTCConferenciaExpedicaoItens
	Self:oConfExp:SetCodExp(cCodExp)
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCConferenciaExpedicaoItens
	Self:cPrdOri := PadR(cPrdOri, Len(Self:cPrdOri))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCConferenciaExpedicaoItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCConferenciaExpedicaoItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCConferenciaExpedicaoItens
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCConferenciaExpedicaoItens
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCConferenciaExpedicaoItens
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSep(nQtdSep) CLASS WMSDTCConferenciaExpedicaoItens
	Self:nQtdSep := nQtdSep
Return

METHOD SetQtdCof(nQtdCof) CLASS WMSDTCConferenciaExpedicaoItens
	Self:nQtdCof := nQtdCof
Return

METHOD SetLibPed(cLibPed) CLASS WMSDTCConferenciaExpedicaoItens
	Self:oConfExp:SetLibPed(cLibPed)
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCConferenciaExpedicaoItens
	Self:cIdDCF := cIdDCF
Return

//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:oConfExp:GetCarga()

METHOD GetPedido() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:oConfExp:GetPedido()

METHOD GetCodExp() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:oConfExp:GetCodExp()

METHOD GetPrdOri() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cPrdOri

METHOD GetProduto() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cNumLote

METHOD GetStatus() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cStatus

METHOD GetQtdOri() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nQtdOri

METHOD GetQtdSep() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nQtdSep

METHOD GetQtdCof() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nQtdCof

METHOD GetTotOri() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nTotOri

METHOD GetTotSep()CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nTotSep

METHOD GetTotCof()CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nTotCof

METHOD GetLibPed() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:oConfExp:GetLibPed()

METHOD GetIdDCF()CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cIdDCF

METHOD GetRecno() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCConferenciaExpedicaoItens
Return Self:cErro
//-----------------------------------------
/*/{Protheus.doc} AssignD0H
Cria registro na tabela de Conf. Expedição x OS

@author  Guilherme A. Metzger
@since   30/09/2015
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD0H() CLASS WMSDTCConferenciaExpedicaoItens
	D0H->(DbSetOrder(1)) // D0H_FILIAL+D0H_CODEXP+D0H_IDDCF
	If !D0H->(DbSeek(xFilial('D0H')+Self:GetCodExp()+Self:cIdDCF))
		RecLock('D0H',.T.)
		D0H->D0H_FILIAL := xFilial('D0H')
		D0H->D0H_CODEXP := Self:GetCodExp()
		D0H->D0H_IDDCF  := Self:cIdDCF
		D0H->(MsUnlock())
	EndIf
Return .T.

METHOD AssignD02() CLASS WMSDTCConferenciaExpedicaoItens
Local lRet    := .T.
Local nQtdOri := Self:nQtdOri
Local nQtdSep := Self:nQtdSep
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaAnt:= GetArea()
// Salva valor atual
Local cLibPed := Self:GetLibPed()
	// Verifica se há conferência cadastra
	If Self:oConfExp:LoadData()
		// Verifica se conferência está liberada
		If Self:oConfExp:ChkPedFat()
			// Atualiza o objeto para manter a informação atual ao invés da antiga carregada no LoadData
			Self:SetLibPed(cLibPed)
			// Cria nova conferência
			If !Self:oConfExp:RecordD01()
				lRet := .T.
				Self:cErro := Self:oConfExp:GetErro()
			EndIf
		EndIf
	Else
		// Cria nova conferência
		If !Self:oConfExp:RecordD01()
			lRet := .F.
			Self:cErro := Self:oConfExp:GetErro()
		EndIf
	EndIf
	If lRet
		// Atualiza codigo da conferência
		If Self:LoadData()
			If lWmsNew
				Self:nQtdOri := nQtdOri
			Else
				Self:nQtdOri := nQtdOri
				Self:nQtdSep += nQtdSep
			EndIf
			lRet := Self:UpdateD02()
		Else
			lRet := Self:RecordD02()
		EndIf
		If lRet
			Self:AssignD0H()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD02() CLASS WMSDTCConferenciaExpedicaoItens
Local lRet   := .T.
	Self:cStatus := "1"
	DbSelectArea("D02")
	D02->(DbSetOrder(1)) // D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
	If !D02->(dbSeek(xFilial("D02")+Self:GetCodExp()+Self:GetCarga()+Self:GetPedido()+Self:cPrdOri+Self:cProduto+Self:cLoteCtl+Self:cNumLote ))
		Reclock('D02',.T.)
		D02->D02_Filial := xFilial("D02")
		D02->D02_CODExp := Self:GetCodExp()
		D02->D02_CARGA  := Self:GetCarga()
		D02->D02_PEDIDO := Self:GetPedido()
		D02->D02_STATUS := Self:cStatus
		D02->D02_PRDORI := Self:cPrdOri
		D02->D02_CODPRO := Self:cProduto
		D02->D02_LOTE   := Self:cLoteCtl
		D02->D02_SUBLOT := Self:cNumLote
		D02->D02_QTORIG := Self:nQtdOri
		D02->D02_QTSEPA := Self:nQtdSep
		D02->D02_QTCONF := Self:nQtdCof
		D02->(MsUnLock())
		// Grava recno
		Self:nRecno := D02->(Recno())
		// Analise se produto é componente
		If D02->D02_CODPRO <> D02->D02_PRDORI
			If !D02->(dbSeek(xFilial("D02")+Self:GetCodExp()+Self:GetCarga()+Self:GetPedido()+Self:cPrdOri+Self:cPrdOri+Self:cLoteCtl+Self:cNumLote))
				RecLock('D02', .T.)
				D02->D02_Filial := xFilial("D02")
				D02->D02_CODEXP := Self:GetCodExp()
				D02->D02_CARGA  := Self:GetCarga()
				D02->D02_PEDIDO := Self:GetPedido()
				D02->D02_STATUS := Self:cStatus
				D02->D02_PRDORI := Self:cPrdOri
				D02->D02_CODPRO := Self:cPrdOri
				D02->D02_LOTE   := Self:cLoteCtl
				D02->D02_SUBLOT := Self:cNumLote
				D02->(MsUnLock())
			EndIf
			Self:CalcConfExp(1)
			RecLock('D02', .F.)
			D02->D02_QTORIG := Self:nTotOri
			D02->D02_QTSEPA := Self:nTotSep
			D02->D02_QTCONF := Self:nTotCof
			D02->D02_STATUS := Self:cStatus
			D02->(MsUnLock())
		EndIf

		If lRet
			// Atualiza quantidade original da conferência
			If Self:CalcConfExp(2)
				Self:oConfExp:SetQtdOri(Self:nTotOri)
				Self:oConfExp:SetQtdSep(Self:nTotSep) // WMS Atual
				If !Self:oConfExp:UpdateD01()
					lRet := .F.
					Self:cErro := Self:oConfExp:GetErro()
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD02() CLASS WMSDTCConferenciaExpedicaoItens
Local lRet   := .T.
Local cStatus := ""
	If !Empty(Self:GetRecno())
		D02->(dbGoTo( Self:GetRecno() ))
		// Status
		If QtdComp(Self:nQtdCof) == 0
			Self:cStatus := "1" // Aguardando Conferencia
		ElseIf QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdCof)
			Self:cStatus := "3" // Conferido
		Else
			Self:cStatus := "2" // Conferencia em Andamento
		EndIf
		// Grava
		RecLock('D02', .F.)
		D02->D02_QTORIG := Self:nQtdOri
		D02->D02_QTSEPA := Self:nQtdSep
		D02->D02_QTCONF := Self:nQtdCof
		D02->D02_STATUS := Self:cStatus
		D02->(MsUnLock())
		If D02->D02_CODPRO <> D02->D02_PRDORI
			If D02->(dbSeek(xFilial("D02")+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_PRDORI+D02_LOTE+D02_SUBLOT))
				Self:CalcConfExp(1)

				If QtdComp(Self:nQtdCof) == 0
					cStatus := "1" // Aguardando Conferencia
				ElseIf QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdCof)
					cStatus := "3" // Conferido
				Else
					cStatus := "2" // Conferencia em Andamento
				EndIf

				RecLock('D02', .F.)
				D02->D02_QTORIG := Self:nTotOri
				D02->D02_QTSEPA := Self:nTotSep
				D02->D02_QTCONF := Self:nTotCof
				D02->D02_STATUS := cStatus
				D02->(MsUnLock())
			EndIf
		EndIf
		If lRet
			// Atualiza quantidade original da conferência
			If Self:CalcConfExp(2)
				Self:oConfExp:SetQtdOri(Self:nTotOri)
				Self:oConfExp:SetQtdSep(Self:nTotSep)
				Self:oConfExp:SetQtdCof(Self:nTotCof)
				If !Self:oConfExp:UpdateD01()
					lRet := .F.
					Self:cErro := Self:oConfExp:GetErro()
				EndIf
			EndIf
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0002 // Dados não encontrados!
	EndIf
Return lRet

METHOD CalcConfExp(nAcao) CLASS WMSDTCConferenciaExpedicaoItens
Local lRet      := .T.
Local aTamSx3   := TamSx3("D02_QTSEPA")
Local aAreaAnt  := GetArea()
Local cAliasD02 := GetNextAlias()

Default nAcao := 1
	// ----------nAcao-----------
	// Totalizador dos itens da conferencia
	Self:nTotOri := 0
	Self:nTotSep := 0
	Self:nTotCof := 0
	Do Case
		Case nAcao == 1
			BeginSql Alias cAliasD02
				SELECT MIN(D02.D02_QTORIG / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTORIG,
						MIN(D02.D02_QTSEPA / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTSEPA,
						MIN(D02.D02_QTCONF / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D02_QTCONF
				FROM %Table:D02% D02
				LEFT JOIN %Table:D11% D11
				ON D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = D02.D02_PRDORI
				AND D11.D11_PRDCMP = D02.D02_CODPRO
				AND D11.%NotDel%
				WHERE D02.D02_FILIAL = %xFilial:D02%
				AND D02.D02_CARGA =  %Exp:Self:oConfExp:GetCarga()%
				AND D02.D02_PEDIDO = %Exp:Self:oConfExp:GetPedido()%
				AND D02.D02_CODEXP = %Exp:Self:oConfExp:GetCodExp()%
				AND D02.D02_PRDORI = %Exp:Self:cPrdOri%
				AND D02.D02_LOTE =   %Exp:Self:GetLoteCtl()%
				AND D02.D02_SUBLOT = %Exp:Self:GetNumLote()%
				AND D02.D02_PRDORI <> D02.D02_CODPRO
				AND D02.%NotDel%
			EndSql
		Case nAcao == 2
			BeginSql Alias cAliasD02
				SELECT SUM(D02.D02_QTORIG) D02_QTORIG,
						SUM(D02.D02_QTSEPA) D02_QTSEPA,
						SUM(D02.D02_QTCONF) D02_QTCONF
				FROM %Table:D02% D02
				WHERE D02.D02_FILIAL = %xFilial:D02%
				AND D02.D02_CARGA =  %Exp:Self:oConfExp:GetCarga()%
				AND D02.D02_PEDIDO = %Exp:Self:oConfExp:GetPedido()%
				AND D02.D02_CODEXP = %Exp:Self:oConfExp:GetCodExp()%
				AND D02.D02_PRDORI = D02.D02_CODPRO
				AND D02.%NotDel%
			EndSql
	EndCase
	TcSetField(cAliasD02,'D02_QTORIG','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD02,'D02_QTSEPA','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD02,'D02_QTCONF','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD02)->(!Eof())
		Self:nTotOri := (cAliasD02)->D02_QTORIG
		Self:nTotSep := (cAliasD02)->D02_QTSEPA
		Self:nTotCof := (cAliasD02)->D02_QTCONF
	Else
		lRet := .F.
	EndIf
	(cAliasD02)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

METHOD RevConfExp(nQtdOri,nQtdSep) CLASS WMSDTCConferenciaExpedicaoItens
Local lRet := .T.
Local cStatus := ""

	If QtdComp(Self:nQtdOri-nQtdOri) <= 0
		D02->(DbGoTo(Self:GetRecno()))
		RecLock('D02', .F.)
		D02->(DbDelete())
		D02->(MsUnlock())
		If D02->D02_CODPRO <> D02->D02_PRDORI
			D02->(DbSetOrder(1)) // D02_FILIAL+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_CODPRO+D02_LOTE+D02_SUBLOT
			If D02->(DbSeek(xFilial("D02")+D02_CODEXP+D02_CARGA+D02_PEDIDO+D02_PRDORI+D02_PRDORI+D02_LOTE+D02_SUBLOT))
				Self:CalcConfExp(1)
				RecLock('D02', .F.)
				If QtdComp(Self:nTotOri) <= 0
					D02->(DbDelete())
				Else
					If QtdComp(Self:nQtdCof) == 0
						cStatus := "1" // Aguardando Conferencia
					ElseIf QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdCof)
						cStatus := "3" // Conferido
					Else
						cStatus := "2" // Conferencia em Andamento
					EndIf
					RecLock('D02', .F.)
					D02->D02_QTORIG := Self:nTotOri
					D02->D02_QTSEPA := Self:nTotSep
					D02->D02_QTCONF := Self:nTotCof
					D02->D02_STATUS := cStatus
				EndIf
				D0E->(MsUnlock())
			EndIf
		EndIf
		// Recalcula a quantidade original da capa
		Self:CalcConfExp(2)
		If QtdComp(Self:nTotOri) <= 0
			lRet := Self:oConfExp:ExcludeD01()
			If lRet
				// Delete D0H
				Self:DeleteD0H()
			EndIf
		Else
			Self:oConfExp:SetQtdOri(Self:nTotOri)
			Self:oConfExp:SetQtdSep(Self:nTotSep)
			Self:oConfExp:SetQtdCof(Self:nTotCof)
			lRet := Self:oConfExp:UpdateD01()
		EndIf
	Else
		Self:nQtdOri -= nQtdOri
		Self:nQtdSep -= nQtdSep
		lRet := Self:UpdateD02()
	EndIf
	If !lRet
		Self:cErro := STR0004 // Problemas no processo de estorno da conferência de expedição (RevConfExp)!
	EndIf
Return lRet

//-----------------------------------------
/*/{Protheus.doc} DelConfExp
Exclui conferencia de expedição
@author jackson.werka
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD DelConfExp() CLASS WMSDTCConferenciaExpedicaoItens
Local lRet      := .T.
Local cAliasD02 := Nil
Local cWhere    := ""
Local lWmsNew := SuperGetMv("MV_WMSNEW",.F.,.F.)
	// Exclui D02
	// Parâmetro Where
	cWhere := "%"
	If lWmsNew
		If Self:GetProduto() != Self:GetPrdOri()
			cWhere += " AND D02.D02_PRDORI = '"+Self:GetPrdOri()+"'"
		Else
			cWhere += " AND D02.D02_CODPRO = '"+Self:GetProduto()+"'"
			cWhere += " AND D02.D02_PRDORI = '"+Self:GetPrdOri()+"'"
		EndIf
	EndIf
	cWhere += "%"
	cAliasD02 := GetNextAlias()
	BeginSql Alias cAliasD02
		SELECT D02.R_E_C_N_O_ RECNOD02
		FROM %Table:D02% D02
		WHERE D02.D02_FILIAL = %xFilial:D02%
		AND D02.D02_CARGA =  %Exp:Self:GetCarga()%
		AND D02.D02_PEDIDO = %Exp:Self:GetPedido()%
		AND D02.D02_CODEXP = %Exp:Self:GetCodExp()%
		AND D02.D02_QTORIG <= 0
		AND D02.%NotDel%
		%Exp:cWhere%
	EndSql
	Do While (cAliasD02)->(!Eof())
		D02->(dbGoTo((cAliasD02)->RECNOD02))
		RecLock('D02', .F.)
		D02->(dbDelete())
		D02->(MsUnLock())
		(cAliasD02)->(dbSkip())
	EndDo
	(cAliasD02)->(dbCloseArea())
	// Recalcula D01 cada vez que um D02 é excluído, excluindo quando chega a 0
	Self:CalcConfExp(2)
	If QtdComp(Self:nTotOri) <= 0 .Or. !lWmsNew
		lRet := Self:oConfExp:ExcludeD01()
		If lRet
			// Delete D0H
			Self:DeleteD0H()
		EndIf
	Else
		Self:oConfExp:SetQtdOri(Self:nTotOri)
		Self:oConfExp:SetQtdSep(Self:nTotSep)
		Self:oConfExp:SetQtdCof(Self:nTotCof)
		lRet := Self:oConfExp:UpdateD01()
	EndIf
Return lRet

METHOD UpdQtdParc(nQtdQuebra,lBxEmp) CLASS WMSDTCConferenciaExpedicaoItens
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT D02.R_E_C_N_O_ RECNOD02,
				CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END D11_QTMULT
		FROM %Table:D02% D02
		LEFT JOIN %Table:D11% D11
		ON D11.D11_FILIAL = %xFilial:D11%
		AND D02.D02_FILIAL = %xFilial:D02%
		AND D11.D11_PRDORI = D02.D02_PRDORI
		AND D11.D11_PRDCMP = D02.D02_CODPRO
		AND D11.%NotDel%
		WHERE D02.D02_FILIAL = %xFilial:D02%
		AND D02.D02_CODEXP = %Exp:Self:GetCodExp()%
		AND D02.D02_CARGA = %Exp:Self:GetCarga()%
		AND D02.D02_PEDIDO = %Exp:Self:GetPedido()%
		AND D02.D02_PRDORI = %Exp:Self:GetPrdOri()%
		AND D02.D02_LOTE = %Exp:Self:GetLoteCtl()%
		AND D02.D02_SUBLOT = %Exp:Self:GetNumLote()%
		AND D02.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		Self:GoToD02((cAliasQry)->RECNOD02)
		Self:nQtdOri -= (nQtdQuebra * (cAliasQry)->D11_QTMULT)
		If lBxEmp
			Self:nQtdSep -= (nQtdQuebra * (cAliasQry)->D11_QTMULT)
		EndIf
		Self:UpdateD02()
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Finalização da conferência
	If Self:oConfExp:GetLibPed() $ "3|4" .And. Self:oConfExp:GetStatus() == "3"
		WMSV102LIB(2,Self:GetCodExp(),Self:GetCarga(),Self:GetPedido())
	EndIf
	RestArea(aAreaAnt)
Return Nil
//-----------------------------------------
/*/{Protheus.doc} DeleteD0H
Elimina registro na tabela de Conf. Expedição x OS

@author  Guilherme A. Metzger
@since   30/09/2015
@version 1.0
/*/
//-----------------------------------------
METHOD DeleteD0H() CLASS WMSDTCConferenciaExpedicaoItens
	D0H->(DbSetOrder(1)) // D0H_FILIAL+D0H_CODEXP+D0H_IDDCF
	If D0H->(DbSeek(xFilial('D0H')+Self:GetCodExp()+Self:cIdDCF))
		RecLock('D0H',.F.)
		D0H->(DbDelete())
		D0H->(MsUnlock())
	EndIf
Return .T.

METHOD GerAIdDCF() CLASS WMSDTCConferenciaExpedicaoItens
Local aIdDCFs  := {}
Local aAreaD0H := D0H->(GetArea())

	D0H->(dbSetOrder(1)) // D0I_FILIAL+D0I_CODMNT+D0I_IDDCF
	D0H->(dbSeek(xFilial('D0H')+Self:GetCodExp()))
	Do While D0H->(!Eof()) .And. D0H->D0H_CODEXP == Self:GetCodExp()
		Aadd(aIdDCFs,D0H->D0H_IDDCF)
		D0H->(dbSkip())
	EndDo
	RestArea(aAreaD0H)
	
Return aIdDCFs

METHOD CalcQtdCof() CLASS WMSDTCConferenciaExpedicaoItens
Local cWhere    := ""
Local cAliasD02 := Nil
Local nQtdOri   := 0
Local nQtdCof   := 0
	// Verifica a quantidade distribuida
	aTamSX3 := TamSx3("D02_QTORIG")
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		cWhere += " AND D02.D02_CARGA  = '"+Self:GetCarga()+"'"
	EndIf
	If !Empty(Self:GetLoteCtl())
		cWhere += " AND D02.D02_LOTE = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cWhere += " AND D02.D02_SUBLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	cAliasD02 := GetNextAlias()
	BeginSql Alias cAliasD02
		SELECT SUM(D02.D02_QTORIG) D02_QTORIG,
				SUM(D02.D02_QTCONF) D02_QTCONF
		FROM %Table:D02% D02
		WHERE D02.D02_FILIAL = %xFilial:D02%
		AND D02.D02_PEDIDO = %Exp:Self:GetPedido()%
		AND D02.D02_PRDORI = %Exp:Self:GetPrdOri()%
		AND D02.D02_CODPRO = %Exp:Self:GetProduto()%
		AND D02.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasD02,'D02_QTORIG','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasD02,'D02_QTCONF','N',aTamSx3[1],aTamSx3[2])
	If (cAliasD02)->(!Eof())
		nQtdOri   := (cAliasD02)->D02_QTORIG
		nQtdCof   := (cAliasD02)->D02_QTCONF
	EndIf
	(cAliasD02)->(dbCloseArea())
Return {nQtdOri,nQtdCof}

METHOD ChkQtdCof(aIdDCFs) CLASS WMSDTCConferenciaExpedicaoItens
Local aOrdSer   := {}
Local aTamSx3   := {}
Local cWhere    := ""
Local cAliasD02 := Nil
Local cAliasD12 := Nil
Local nI        := 0
Local nQtdCof   := 0
Local nQtdOri   := 0

Default aIdDCFs   := {}
	// Verifica a quantidade distribuida
	aTamSX3 := TamSx3("D02_QTCONF")
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		cWhere += " AND D02.D02_CARGA  = '"+Self:GetCarga()+"'"
	EndIf
	If !Empty(Self:GetLoteCtl())
		cWhere += " AND D02.D02_LOTE = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cWhere += " AND D02.D02_SUBLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	cAliasD02 := GetNextAlias()
	BeginSql Alias cAliasD02
		SELECT SUM(D02.D02_QTCONF) D02_QTCONF
		FROM %Table:D02% D02
		WHERE D02.D02_FILIAL = %xFilial:D02%
		AND D02.D02_PEDIDO = %Exp:Self:GetPedido()%
		AND D02.D02_PRDORI = %Exp:Self:GetPrdOri()%
		AND D02.D02_CODPRO = %Exp:Self:GetProduto()%
		AND D02.D_E_L_E_T_ = ' '"
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasD02,'D02_QTCONF','N',aTamSx3[1],aTamSx3[2])
	If (cAliasD02)->(!Eof())
		nQtdTot := (cAliasD02)->D02_QTCONF
	EndIf
	(cAliasD02)->(dbCloseArea())
	// Verifica a quantidade origem
	aTamSX3 := TamSx3("DCR_QUANT")
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		cWhere += " AND D12.D12_CARGA  = '"+Self:GetCarga()+"'"
	EndIf
	If !Empty(Self:GetLoteCtl())
		cWhere += " AND D12.D12_LOTECT = '"+Self:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:GetNumLote())
		cWhere += " AND D12.D12_NUMLOT = '"+Self:GetNumLote()+"'"
	EndIf
	cWhere += "%"
	cAliasD12 := GetNextAlias()
	BeginSql Alias cAliasD12
		SELECT DCR.DCR_IDDCF,
				SUM(DCR.DCR_QUANT) DCR_QUANT
		FROM %Table:D12% D12
		INNER JOIN %Table:D0H% D0H
		ON D0H.D0H_FILIAL = %xFilial:D0H%
		AND D0H.%NotDel%
		INNER JOIN %Table:DCR% DCR
		ON DCR.DCR_FILIAL = %xFilial:DCR%
		AND DCR.DCR_IDDCF = D0H.D0H_IDDCF
		AND DCR.%NotDel%
		INNER JOIN %Table:DCF% DCF
		ON DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_ID = D0H.D0H_IDDCF
		AND DCF.%NotDel%
		WHERE D12.D12_FILIAL = %xFilial:D12%
		AND D12.D12_IDDCF = DCR.DCR_IDORI
		AND D12.D12_IDMOV = DCR.DCR_IDMOV
		AND D12.D12_IDOPER = DCR.DCR_IDOPER
		AND D12.D12_DOC = %Exp:Self:GetPedido()%
		AND D12.D12_PRDORI = %Exp:Self:GetPrdOri()%
		AND D12.D12_PRODUT = %Exp:Self:GetProduto()%
		AND D12.D12_ATUEST = '1'
		AND D12.D12_STATUS = '1'
		AND D12.%NotDel%
		%Exp:cWhere%
		GROUP BY DCR.DCR_IDDCF
	EndSql
	TcSetField(cAliasD12,'DCR_QUANT','N',aTamSx3[1],aTamSx3[2])
	Do While (cAliasD12)->(!Eof())
		cIdDCF  := (cAliasD12)->DCR_IDDCF
		nQtdMov := (cAliasD12)->DCR_QUANT
		nQtdCof := 0
		If QtdComp(nQtdTot) > QtdComp(0)
			If QtdComp(nQtdTot) > QtdComp(nQtdMov)
				nQtdCof := nQtdMov
			Else
				nQtdCof := nQtdTot
			EndIf
			nQtdTot -= nQtdCof
		EndIf
		aAdd(aOrdSer,{cIdDCF,nQtdMov,nQtdCof})
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
	// Inicializa quantidades
	nQtdOri := 0
	nQtdCof := 0
	// Monta os id dcfs
	For nI := 1 To Len(aIdDCFs)
		If (nPos := AScan(aOrdSer, { |x| x[1] == aIdDCFs[nI] })) > 0
			nQtdOri += aOrdSer[nPos][2]
			nQtdCof += aOrdSer[nPos][3]
		EndIf
	Next nI
Return {nQtdOri,nQtdCof}