#Include "Totvs.ch"
#Include "WMSDTCMontagemVolumeItens.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0025
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0025()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCMontagemVolumeItens
Classe estrutura física
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCMontagemVolumeItens FROM LongNameClass
	// Data
	DATA oMntVol
	DATA oVolume
	DATA oVolItens
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cItem
	DATA cStatus
	DATA nQtdOri
	DATA nQtdSep
	DATA nQtdEmb
	DATA dData
	DATA cHora
	DATA nTotOri
	DATA nTotSep
	DATA nTotEmb
	DATA cMntExc
	DATA nRecno
	DATA cErro
	DATA cIdDCF
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToDCT(nRecno)
	METHOD LoadData(nIndex)
	METHOD AssignD0I()
	METHOD DeleteD0I()
	METHOD AssignDCT()
	METHOD RecordDCT()
	METHOD UpdateDCT()
	// Setters
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetCodMnt(cCodMnt)
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetStatus(cStatus)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSep(nQtdSep)
	METHOD SetQtdEmb(nQtdEmb)
	METHOD SetLibPed(cLibPed)
	METHOD SetMntExc(cMntExc)
	METHOD SetIdDCF(cIdDCF)
	// Getters
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetCodMnt()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetStatus()
	METHOD GetQtdOri()
	METHOD GetQtdSep()
	METHOD GetQtdEmb()
	METHOD GetQtdLib()
	METHOD GetTotOri()
	METHOD GetTotSep()
	METHOD GetTotEmb()
	METHOD GetTotLib()
	METHOD GetLibPed()
	METHOD GetMntExc()
	METHOD GetIdDCF()
	METHOD GetRecno()
	METHOD GetErro()
	// Metodos
	METHOD CalcMntVol(nAcao)
	METHOD VldPrdCmp(lEstorno)
	METHOD QtdPrdVol(lEstorno)
	METHOD LoadPrdVol(aProdutos,nQtde)
	METHOD MntPrdVol(aProdutos)
	METHOD RevMntVol(nQtdOri,nQtdSep)
	METHOD DelMntVol()
	METHOD Destroy()
	METHOD UpdQtdParc(nQtdQuebra,lBxEmp)
	METHOD GeraIdDCF()
	METHOD CalcQtdMnt()
	METHOD ChkQtdMnt(aIdDCFs)

ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.correa
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCMontagemVolumeItens
	Self:oMntVol    := WMSDTCMontagemVolume():New()
	Self:oVolume    := WMSDTCVolume():New()
	Self:oVolume:oMntVol := Self:oMntVol //Faz com que classe aponte para o mesmo objeto (sincronismo)
	Self:oVolItens  := WMSDTCVolumeItens():New()
	Self:oVolItens:oVolume := Self:oVolume //Faz com que classe aponte para o mesmo objeto (sincronismo)
	Self:cPrdOri    := PadR("", TamSx3("DCT_PRDORI")[1])
	Self:cProduto   := PadR("", TamSx3("DCT_CODPRO")[1])
	Self:cLoteCtl   := PadR("", TamSx3("DCT_LOTE")[1])
	Self:cNumLote   := PadR("", TamSx3("DCT_SUBLOT")[1])
	Self:cStatus    := "1"
	Self:nQtdOri    := 0
	Self:nQtdSep    := 0
	Self:nQtdEmb    := 0
	Self:nTotOri    := 0
	Self:nTotSep    := 0
	Self:nTotEmb    := 0
	Self:cIdDCF     := ""
	Self:dData      := dDataBase
	Self:cHora      := Time()
	Self:nRecno     := 0
	Self:cErro      := ""
Return

METHOD Destroy() CLASS WMSDTCMontagemVolumeItens
	//Segundo frame, o método do objeto não pode eliminá-lo. Além disso, não há necessidade visto que isso é feito pelo gerenciador do Protneus 
	//FreeObj(Self)
Return

//----------------------------------------
/*/{Protheus.doc} GoToDCF
Posicionamento para atualização das propriedades
@author felipe.m
@since 23/12/2014
@version 1.0
@param nRecnoDCT, numérico, (Descrição do parâmetro)
/*/
//----------------------------------------
METHOD GoToDCT(nRecno) CLASS WMSDTCMontagemVolumeItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DCT
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMontagemVolumeItens
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aDCT_QTSEPA := TamSx3("DCT_QTSEPA")
Local aDCT_QTEMBA := TamSx3("DCT_QTEMBA")
Local aDCT_QTORIG := TamSx3("DCT_QTORIG")
Local aAreaDCT    := DCT->(GetArea())
Local cWhere      := ""
Local cAliasDCT   := Nil
Default nIndex := 1
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // DCT_FILIAL+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_CODPRO+DCT_LOTE+DCT_SUBLOT
			If Empty(Self:GetPedido()) .Or. Empty(Self:cPrdOri) .Or. Empty(Self:cProduto) .Or. Empty(Self:GetCodMnt())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		cAliasDCT:= GetNextAlias()
		Do Case
			Case nIndex == 0 
				BeginSql Alias cAliasDCT
					SELECT DCT.DCT_CARGA,
							DCT.DCT_PEDIDO,
							DCT.DCT_STATUS,
							DCT.DCT_CODPRO,
							DCT.DCT_LOTE,
							DCT.DCT_SUBLOT,
							DCT.DCT_QTSEPA,
							DCT.DCT_QTEMBA,
							DCT.DCT_CODMNT,
							DCT.DCT_PRDORI,
							DCT.DCT_DATA,
							DCT.DCT_HORA,
							DCT.DCT_QTORIG,
							DCT.R_E_C_N_O_ RECNODCT
					FROM %Table:DCT% DCT
					WHERE DCT.DCT_FILIAL = %xFilial:DCT%
					AND DCT.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND DCT.%NotDel%
					
				EndSql
			Case nIndex == 1
				cWhere := "%"
				If !Empty(Self:cLoteCtl)
					cWhere += " AND DCT.DCT_LOTE = '"+Self:cLoteCtl+"'"
				Endif
				If !Empty(Self:cNumLote)
					cWhere += " AND DCT.DCT_SUBLOT = '"+Self:cNumLote+"'"
				EndIf
				cWhere += "%"
				If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
					BeginSql Alias cAliasDCT
						SELECT DCT.DCT_CARGA,
								DCT.DCT_PEDIDO,
								DCT.DCT_STATUS,
								DCT.DCT_CODPRO,
								DCT.DCT_LOTE,
								DCT.DCT_SUBLOT,
								DCT.DCT_QTSEPA,
								DCT.DCT_QTEMBA,
								DCT.DCT_CODMNT,
								DCT.DCT_PRDORI,
								DCT.DCT_DATA,
								DCT.DCT_HORA,
								DCT.DCT_QTORIG,
								DCT.R_E_C_N_O_ RECNODCT
						FROM %Table:DCT% DCT
						WHERE DCT.DCT_FILIAL = %xFilial:DCT%
						AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
						AND DCT.DCT_CARGA =  %Exp:Self:GetCarga()%
						AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
						AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
						AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
						AND DCT.%NotDel%
						%Exp:cWhere%
					EndSql
				Else
					BeginSql Alias cAliasDCT
						SELECT DCT.DCT_CARGA,
								DCT.DCT_PEDIDO,
								DCT.DCT_STATUS,
								DCT.DCT_CODPRO,
								DCT.DCT_LOTE,
								DCT.DCT_SUBLOT,
								DCT.DCT_QTSEPA,
								DCT.DCT_QTEMBA,
								DCT.DCT_CODMNT,
								DCT.DCT_PRDORI,
								DCT.DCT_DATA,
								DCT.DCT_HORA,
								DCT.DCT_QTORIG,
								DCT.R_E_C_N_O_ RECNODCT
						FROM %Table:DCT% DCT
						WHERE DCT.DCT_FILIAL = %xFilial:DCT%
						AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
						AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
						AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
						AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
						AND DCT.%NotDel%
						%Exp:cWhere%
					EndSql
				EndIf
		EndCase
		TCSetField(cAliasDCT,'DCT_QTSEPA','N',aDCT_QTSEPA[1],aDCT_QTSEPA[2])
		TCSetField(cAliasDCT,'DCT_QTEMBA','N',aDCT_QTEMBA[1],aDCT_QTEMBA[2])
		TCSetField(cAliasDCT,'DCT_QTORIG','N',aDCT_QTORIG[1],aDCT_QTORIG[2])
		TcSetField(cAliasDCT,'DCT_DATA','D')
		If (lRet := (cAliasDCT)->(!Eof()))
			Self:SetCodMnt((cAliasDCT)->DCT_CODMNT)
			Self:SetCarga((cAliasDCT)->DCT_CARGA)
			Self:SetPedido((cAliasDCT)->DCT_PEDIDO)
			// Montagem
			Self:oMntVol:LoadData()
			// Busca dados lote/produto
			Self:SetPrdOri((cAliasDCT)->DCT_PRDORI)
			Self:SetProduto((cAliasDCT)->DCT_CODPRO)
			Self:SetLoteCtl((cAliasDCT)->DCT_LOTE)
			Self:SetNumLote((cAliasDCT)->DCT_SUBLOT)
			// Busca dados endereco origem
			// Dados complementares
			Self:cStatus  := (cAliasDCT)->DCT_STATUS
			Self:nQtdOri  := (cAliasDCT)->DCT_QTORIG
			Self:nQtdSep  := (cAliasDCT)->DCT_QTSEPA
			Self:nQtdEmb  := (cAliasDCT)->DCT_QTEMBA
			Self:dData    := (cAliasDCT)->DCT_DATA
			Self:cHora    := (cAliasDCT)->DCT_HORA
			Self:nRecno   := (cAliasDCT)->RECNODCT
		EndIf
		(cAliasDCT)->(dbCloseArea())
	EndIf
	RestArea(aAreaDCT)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCMontagemVolumeItens
	Self:oMntVol:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCMontagemVolumeItens
	Self:oMntVol:SetPedido(cPedido)
Return

METHOD SetCodMnt(cCodMnt) CLASS WMSDTCMontagemVolumeItens
	Self:oMntVol:SetCodMnt(cCodMnt)
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCMontagemVolumeItens
	Self:cPrdOri := PadR(cPrdOri, Len(Self:cPrdOri))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCMontagemVolumeItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCMontagemVolumeItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCMontagemVolumeItens
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCMontagemVolumeItens
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCMontagemVolumeItens
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSep(nQtdSep) CLASS WMSDTCMontagemVolumeItens
	Self:nQtdSep := nQtdSep
Return

METHOD SetQtdEmb(nQtdEmb) CLASS WMSDTCMontagemVolumeItens
	Self:nQtdEmb := nQtdEmb
Return

METHOD SetLibPed(cLibPed) CLASS WMSDTCMontagemVolumeItens
	Self:oMntVol:SetLibPed(cLibPed)
Return

METHOD SetMntExc(cMntExc) CLASS WMSDTCMontagemVolumeItens
	Self:oMntVol:SetMntExc(cMntExc)
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMontagemVolumeItens
	Self:cIdDCF := cIdDCF
Return

//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCMontagemVolumeItens
Return Self:oMntVol:GetCarga()

METHOD GetPedido() CLASS WMSDTCMontagemVolumeItens
Return Self:oMntVol:GetPedido()

METHOD GetCodMnt() CLASS WMSDTCMontagemVolumeItens
Return Self:oMntVol:GetCodMnt()

METHOD GetPrdOri() CLASS WMSDTCMontagemVolumeItens
Return Self:cPrdOri

METHOD GetProduto() CLASS WMSDTCMontagemVolumeItens
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCMontagemVolumeItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCMontagemVolumeItens
Return Self:cNumLote

METHOD GetStatus() CLASS WMSDTCMontagemVolumeItens
Return Self:cStatus

METHOD GetQtdOri() CLASS WMSDTCMontagemVolumeItens
Return  Self:nQtdOri

METHOD GetQtdSep() CLASS WMSDTCMontagemVolumeItens
Return Self:nQtdSep

METHOD GetQtdEmb() CLASS WMSDTCMontagemVolumeItens
Return Self:nQtdEmb

METHOD GetTotOri() CLASS WMSDTCMontagemVolumeItens
Return Self:nTotOri

METHOD GetTotSep() CLASS WMSDTCMontagemVolumeItens
Return Self:nTotSep

METHOD GetTotEmb() CLASS WMSDTCMontagemVolumeItens
Return Self:nTotEmb

METHOD GetLibPed() CLASS WMSDTCMontagemVolumeItens
Return Self:oMntVol:GetLibPed()

METHOD GetMntExc() CLASS WMSDTCMontagemVolumeItens
Return Self:oMntVol:GetMntExc()

METHOD GetIdDCF() CLASS WMSDTCMontagemVolumeItens
Return Self:cIdDCF

METHOD GetRecno() CLASS WMSDTCMontagemVolumeItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMontagemVolumeItens
Return Self:cErro
//-----------------------------------------
/*/{Protheus.doc} AssignD0I
Cria registro na tabela de Mnt. Volume x OS

@author  felipe.m
@since   02/09/2016
@version 1.0
/*/
//-----------------------------------------
METHOD AssignD0I() CLASS WMSDTCMontagemVolumeItens
	D0I->(dbSetOrder(1)) // D0I_FILIAL+D0I_CODDIS+D0I_IDDCF
	If !D0I->(dbSeek(xFilial('D0I')+Self:GetCodMnt()+Self:cIdDCF))
		RecLock('D0I',.T.)
		D0I->D0I_FILIAL := xFilial('D0I')
		D0I->D0I_CODMNT := Self:GetCodMnt()
		D0I->D0I_IDDCF  := Self:cIdDCF
		D0I->(MsUnlock())
	Endif
Return .T.

METHOD AssignDCT() CLASS WMSDTCMontagemVolumeItens
Local lRet    := .T.
Local nQtdOri := Self:nQtdOri
Local nQtdSep := Self:nQtdSep
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaAnt:= GetArea()
// Salva valor atual
Local cLibPed := Self:GetLibPed()
Local cMntExc := Self:GetMntExc()
	// Verifica se há montagem cadastra
	If Self:oMntVol:LoadData()
		// Verifica se montagem está liberada
		If Self:oMntVol:ChkPedFat()
			// Atualiza o objeto para manter a informação atual ao invés da antiga carregada no LoadData
			Self:SetLibPed(cLibPed)
			Self:SetMntExc(cMntExc)
			// Cria nova montagem
			If !Self:oMntVol:RecordDCS()
				lRet := .T.
				Self:cErro := Self:oMntVol:GetErro()
			EndIf
		EndIf
	Else
		// Cria nova montagem
		If !Self:oMntVol:RecordDCS()
			lRet := .F.
			Self:cErro := Self:oMntVol:GetErro()
		EndIf
	EndIf

	If lRet
		// Atualiza codigo da montagem
		If Self:LoadData()
			If lWmsNew
				Self:nQtdOri := nQtdOri
			Else
				Self:nQtdOri := nQtdOri
				Self:nQtdSep += nQtdSep
			EndIf
			lRet := Self:UpdateDCT()
		Else
			lRet := Self:RecordDCT()
		EndIf
		If lRet
			Self:AssignD0I()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

METHOD RecordDCT() CLASS WMSDTCMontagemVolumeItens
Local lRet   := .T.
	Self:cStatus := "1"
	DbSelectArea("DCT")
	DCT->(DbSetOrder(1)) // DCT_FILIAL+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_CODPRO+DCT_LOTE+DCT_SUBLOT
	If !DCT->(dbSeek(xFilial("DCT")+Self:GetCodMnt()+Self:GetCarga()+Self:GetPedido()+Self:cPrdOri+Self:cProduto+Self:cLoteCtl+Self:cNumLote ))
		Reclock('DCT',.T.)
		DCT->DCT_Filial := xFilial("DCT")
		DCT->DCT_CODMNT := Self:GetCodMnt()
		DCT->DCT_CARGA  := Self:GetCarga()
		DCT->DCT_PEDIDO := Self:GetPedido()
		DCT->DCT_STATUS := Self:cStatus
		DCT->DCT_PRDORI := Self:cPrdOri
		DCT->DCT_CODPRO := Self:cProduto
		DCT->DCT_LOTE   := Self:cLoteCtl
		DCT->DCT_SUBLOT := Self:cNumLote
		DCT->DCT_QTORIG := Self:nQtdOri
		DCT->DCT_QTSEPA := Self:nQtdSep
		DCT->DCT_QTEMBA := Self:nQtdEmb
		DCT->(MsUnLock())
		// Grava recno
		Self:nRecno := DCT->(Recno())
		// Analise se produto é componente
		If DCT->DCT_CODPRO <> DCT->DCT_PRDORI
			If  !DCT->(dbSeek(xFilial("DCT")+Self:GetCodMnt()+Self:GetCarga()+Self:GetPedido()+Self:cPrdOri+Self:cPrdOri+Self:cLoteCtl+Self:cNumLote))
				RecLock('DCT', .T.)
				DCT->DCT_Filial := xFilial("DCT")
				DCT->DCT_CODMNT := Self:GetCodMnt()
				DCT->DCT_CARGA  := Self:GetCarga()
				DCT->DCT_PEDIDO := Self:GetPedido()
				DCT->DCT_STATUS := Self:cStatus
				DCT->DCT_PRDORI := Self:cPrdOri
				DCT->DCT_CODPRO := Self:cPrdOri
				DCT->DCT_LOTE   := Self:cLoteCtl
				DCT->DCT_SUBLOT := Self:cNumLote
				DCT->(MsUnLock())
			EndIf
			Self:CalcMntVol(1)
			RecLock('DCT', .F.)
			DCT->DCT_QTORIG := Self:nTotOri
			DCT->DCT_QTSEPA := Self:nTotSep
			DCT->DCT_QTEMBA := Self:nTotEmb
			DCT->DCT_STATUS := Self:cStatus
			DCT->(MsUnLock())
		EndIf

		If lRet
			// Atualiza quantidade original da montagem da carga
			If Self:CalcMntVol(2)
				Self:oMntVol:SetQtdOri(Self:nTotOri)
				Self:oMntVol:SetQtdSep(Self:nTotSep) // WMS Atual
				If !Self:oMntVol:UpdateDCS()
					lRet := .F.
					Self:cErro := Self:oMntVol:GetErro()
				EndIf
			EndIf
		EndIf

	Else
		lRet := .F.
		Self:cErro := STR0003 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateDCT() CLASS WMSDTCMontagemVolumeItens
Local lRet   := .T.
Local cStatus := ""
	If !Empty(Self:GetRecno())
		DCT->(dbGoTo( Self:GetRecno() ))
		// Status
		If QtdComp(Self:nQtdEmb) == 0
			Self:cStatus := '1' // Não Iniciado
		ElseIf QtdComp(Self:nQtdEmb) == QtdComp(Self:nQtdOri)
			Self:cStatus := '3' // Finalizado
		Else
			Self:cStatus := '2' // Em Andamento
		EndIf
		// Grava DCF
		RecLock('DCT', .F.)
		DCT->DCT_QTORIG := Self:nQtdOri
		DCT->DCT_QTSEPA := Self:nQtdSep
		DCT->DCT_QTEMBA := Self:nQtdEmb
		DCT->DCT_STATUS := Self:cStatus
		DCT->(MsUnLock())
		If DCT->DCT_CODPRO <> DCT->DCT_PRDORI
			If DCT->(dbSeek(xFilial("DCT")+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_PRDORI+DCT_LOTE+DCT_SUBLOT))
				Self:CalcMntVol(1)

				If QtdComp(Self:nTotEmb) == 0
					cStatus := '1' // Não Iniciado
				ElseIf QtdComp(Self:nTotEmb) == QtdComp(Self:nTotOri)
					cStatus := '3' // Finalizado
				Else
					cStatus := '2' // Em Andamento
				EndIf

				RecLock('DCT', .F.)
				DCT->DCT_QTORIG := Self:nTotOri
				DCT->DCT_QTSEPA := Self:nTotSep
				DCT->DCT_QTEMBA := Self:nTotEmb
				DCT->DCT_STATUS := cStatus
				DCT->(MsUnLock())
			EndIf
		EndIf

		If lRet
			// Atualiza quantidade original da montagem da carga
			If Self:CalcMntVol(2)
				Self:oMntVol:SetQtdOri(Self:nTotOri)
				Self:oMntVol:SetQtdSep(Self:nTotSep)
				Self:oMntVol:SetQtdEmb(Self:nTotEmb)
				If !Self:oMntVol:UpdateDCS()
					lRet := .F.
					Self:cErro := Self:oMntVol:GetErro()
				EndIf
			EndIf
		EndIf

	Else
		lRet := .F.
		Self:cErro := STR0004 // Dados não encontrados!
	EndIf
Return lRet

//-----------------------------------------------------------------------------
METHOD CalcMntVol(nAcao) CLASS WMSDTCMontagemVolumeItens
Local lRet      := .T.
Local aTamSx3   := TamSx3("DCT_QTORIG")
Local cAliasDCT := Nil
Local aAreaAnt  := GetArea()

Default nAcao := 1
	// ----------nAcao-----------
	// [1] - Totalizador do item da montagem de volume
	// [2] - Totalizador da montagem do volume
	Self:nTotOri := 0
	Self:nTotSep := 0
	Self:nTotEmb := 0

	Do Case
		Case nAcao == 1
			cAliasDCT := GetNextAlias()
			BeginSql Alias cAliasDCT
				SELECT MIN(DCT.DCT_QTORIG / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) DCT_QTORIG,
						MIN(DCT.DCT_QTSEPA / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) DCT_QTSEPA,
						MIN(DCT.DCT_QTEMBA / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) DCT_QTEMBA
				FROM %Table:DCT% DCT
				LEFT JOIN %Table:D11% D11
				ON D11_FILIAL = %xFilial:D11%
				AND D11.D11_PRDORI = DCT.DCT_PRDORI
				AND D11.D11_PRDCMP = DCT.DCT_CODPRO
				AND D11.%NotDel%
				WHERE DCT.DCT_FILIAL = %xFilial:DCT%
				AND DCT.DCT_CARGA = %Exp:Self:oMntVol:GetCarga()%
				AND DCT.DCT_PEDIDO = %Exp:Self:oMntVol:GetPedido()%
				AND DCT.DCT_CODMNT = %Exp:Self:oMntVol:GetCodMnt()%
				AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
				AND DCT.DCT_LOTE = %Exp:Self:cLoteCtl%
				AND DCT.DCT_SUBLOT = %Exp:Self:cNumLote%
				AND DCT.DCT_PRDORI <> DCT.DCT_CODPRO
				AND DCT.%NotDel%
			EndSql
		
		Case nAcao == 2
			cAliasDCT := GetNextAlias()
			BeginSql Alias cAliasDCT
				SELECT SUM(DCT.DCT_QTORIG) DCT_QTORIG,
						SUM(DCT.DCT_QTSEPA) DCT_QTSEPA,
						SUM(DCT.DCT_QTEMBA) DCT_QTEMBA
				FROM %Table:DCT% DCT
				WHERE DCT.DCT_FILIAL = %xFilial:DCT%
				AND DCT.DCT_CARGA =  %Exp:Self:oMntVol:GetCarga()%
				AND DCT.DCT_PEDIDO = %Exp:Self:oMntVol:GetPedido()%
				AND DCT.DCT_CODMNT = %Exp:Self:oMntVol:GetCodMnt()%
				AND DCT.DCT_PRDORI = DCT.DCT_CODPRO
				AND DCT.%NotDel%
			EndSql
	EndCase
	TcSetField(cAliasDCT,'DCT_QTORIG','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasDCT,'DCT_QTSEPA','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasDCT,'DCT_QTEMBA','N',aTamSX3[1],aTamSX3[2])
	If (cAliasDCT)->(!Eof() )
		Self:nTotOri := (cAliasDCT)->DCT_QTORIG
		Self:nTotSep := (cAliasDCT)->DCT_QTSEPA
		Self:nTotEmb := (cAliasDCT)->DCT_QTEMBA
	Else
		lRet := .F.
	EndIf
	(cAliasDCT)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
METHOD VldPrdCmp(lEstorno) CLASS WMSDTCMontagemVolumeItens
Local lAchou    := .F.
Local aAreaAnt  := GetArea()
Local cWhere    := ""
Local cAliasDCT := Nil
Local cPrdOriAnt:= ""
Local nPrdOri   := 0
Local nOpcao    := 0

Default lEstorno:= .F.
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND DCT.DCT_LOTE   = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND DCT.DCT_SUBLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	cAliasDCT := GetNextAlias()
	BeginSql Alias cAliasDCT
		SELECT DCT.DCT_PRDORI
		FROM %table:DCT% DCT
		WHERE DCT.DCT_FILIAL = %xFilial:DCT%
		AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
		AND DCT.DCT_CARGA  = %Exp:Self:GetCarga()%
		AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
		AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
		AND DCT.%NotDel%
		%Exp:cWhere%
	EndSql
	(cAliasDCT)->(dbEval( {|| Iif(cPrdOriAnt!=DCT_PRDORI,nPrdOri++,), cPrdOriAnt := DCT_PRDORI }))
	// Pergunta o que deve considerar
	If nPrdOri > 1
		nOpcao := WmsMessage(STR0008,STR0007,4,.T.,{STR0009,STR0010}) // Montagem Volume // Considerar produto como: // Componente // Produto
	EndIf

	(cAliasDCT)->(dbGoTop())
	Do While (cAliasDCT)->(!Eof())
		If nPrdOri > 1
			// Quando "Componente", pula aquele que é produto
			If nOpcao == 1 .And. (cAliasDCT)->DCT_PRDORI == Self:cProduto
				(cAliasDCT)->(DbSkip())
				Loop
			EndIf
			// Quando "Produto", pula aquele que é componente
			If nOpcao == 2 .And. (cAliasDCT)->DCT_PRDORI != Self:cProduto
				(cAliasDCT)->(DbSkip())
				Loop
			EndIf
		EndIf
		Self:cPrdOri := (cAliasDCT)->DCT_PRDORI
		lAchou := .T.
		Exit
	EndDo
	(cAliasDCT)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lAchou
//-----------------------------------------------------------------------------
// Permite carregar a quantidade do produto que está pendente de montagem de volumes
//-----------------------------------------------------------------------------
METHOD QtdPrdVol(lEstorno) CLASS WMSDTCMontagemVolumeItens
Local aAreaAnt  := GetArea()
Local aTamSX3   := TamSx3('DCT_QTORIG')
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Default lEstorno:= .F.

	Self:SetQtdOri(0)
	Self:SetQtdSep(0)
	Self:SetQtdEmb(0)
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere +=  " AND DCT.DCT_LOTE   = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere +=  " AND DCT.DCT_SUBLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	If !lEstorno
		BeginSql Alias cAliasQry
			SELECT SUM(DCT.DCT_QTORIG) DCT_QTORIG,
					SUM(DCT.DCT_QTSEPA) DCT_QTSEPA,
					SUM(DCT.DCT_QTEMBA) DCT_QTEMBA
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
			AND DCT.DCT_CARGA = %Exp:Self:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT SUM(DCT.DCT_QTORIG) DCT_QTORIG,
					SUM(DCT.DCT_QTSEPA) DCT_QTSEPA,
					SUM(DCV.DCV_QUANT) DCT_QTEMBA
			FROM %Table:DCT% DCT
			INNER JOIN %Table:DCV% DCV
			ON DCV.DCV_FILIAL = %xFilial:DCV%
			AND DCV.DCV_CODVOL = %Exp:Self:oVolume:GetCodVol()%
			AND DCV.DCV_CODMNT = DCT.DCT_CODMNT
			AND DCV.DCV_CARGA = DCT.DCT_CARGA
			AND DCV.DCV_PEDIDO = DCT.DCT_PEDIDO
			AND DCV.DCV_PRDORI = DCT.DCT_PRDORI
			AND DCV.DCV_CODPRO = DCT.DCT_CODPRO
			AND DCV.DCV_LOTE = DCT.DCT_LOTE
			AND DCV.DCV_SUBLOT = DCT.DCT_SUBLOT
			AND DCV.%NotDel%
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
			AND DCT.DCT_CARGA = %Exp:Self:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	TcSetField(cAliasQry,'DCT_QTORIG','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'DCT_QTSEPA','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'DCT_QTEMBA','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
		Self:SetQtdOri((cAliasQry)->DCT_QTORIG)
		Self:SetQtdSep((cAliasQry)->DCT_QTSEPA)
		Self:SetQtdEmb((cAliasQry)->DCT_QTEMBA)
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return Nil
//-----------------------------------------------------------------------------
// Carrega as quantidades a serem montadas volumes de acordo com os dados informados
// Pode ser que um produto informado gere mais de um registro em função de ser
// produto componente, ou controlar lote e não pedir lote no coletor
//-----------------------------------------------------------------------------
METHOD LoadPrdVol(aProdutos,nQtde) CLASS WMSDTCMontagemVolumeItens
Local lRet       := .T.
Local lVerChild  := .T.
Local lHasChild  := .F.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaAnt   := GetArea()
Local aTamDCT    := TamSx3('DCT_QTORIG')
Local aTamD11    := {}
Local cWhere     := ""
Local cAliasQry  := GetNextAlias()
Local cLastChild := ""
Local cProdAnt   := ""
Local nQtdPrd    := 0
Local nQtdOri    := 0
Default nQtde    := 0
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND DCT.DCT_LOTE   = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND DCT.DCT_SUBLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	If lWmsNew
		// Guarda a quantidade total para rateio entre produtos filhos
		nQtdOri := nQtde
		aTamD11 := TamSx3('D11_QTMULT')
		// Esta query deve ordenar primeiro os produtos filhos quando possuir
		// pois neste caso o produto pai não poderá ser considerado e deverá ser descartado ficando por ultimo
		If Self:cProduto != Self:cPrdOri
			lVerChild := .F. // Ja é produto filho, não precisa verificar
			BeginSql Alias cAliasQry
				SELECT CASE WHEN D11.D11_QTMULT IS NULL THEN 2 ELSE 1 END ORD_PRDCMP,
						DCT.DCT_PRDORI,
						DCT.DCT_CODPRO,
						DCT.DCT_LOTE,
						DCT.DCT_SUBLOT,
						(DCT.DCT_QTSEPA - DCT.DCT_QTEMBA) DCT_SALDO,
						(CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D11_QTMULT
				FROM %Table:DCT% DCT
				LEFT JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND DCT.DCT_FILIAL = %xFilial:DCT%
				AND D11.D11_PRODUT = DCT.DCT_PRDORI
				AND D11.D11_PRDORI = DCT.DCT_PRDORI
				AND D11.D11_PRDCMP = DCT.DCT_CODPRO
				AND D11.%NotDel%
				WHERE DCT.DCT_FILIAL = %xFilial:DCT%
				AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
				AND DCT.DCT_CARGA = %Exp:Self:GetCarga()%
				AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
				AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
				AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
				AND DCT.%NotDel%
				%Exp:cWhere%
				ORDER BY ORD_PRDCMP,
							DCT.DCT_CODPRO,
							DCT.DCT_LOTE,
							DCT.DCT_SUBLOT
			EndSql

		Else
			BeginSql Alias cAliasQry
				SELECT CASE WHEN D11.D11_QTMULT IS NULL THEN 2 ELSE 1 END ORD_PRDCMP,
						DCT.DCT_PRDORI,
						DCT.DCT_CODPRO,
						DCT.DCT_LOTE,
						DCT.DCT_SUBLOT,
						(DCT.DCT_QTSEPA - DCT.DCT_QTEMBA) DCT_SALDO,
						(CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) D11_QTMULT
				FROM %Table:DCT% DCT
				LEFT JOIN %Table:D11% D11
				ON D11.D11_FILIAL = %xFilial:D11%
				AND DCT.DCT_FILIAL = %xFilial:DCT%
				AND D11.D11_PRODUT = DCT.DCT_PRDORI
				AND D11.D11_PRDORI = DCT.DCT_PRDORI
				AND D11.D11_PRDCMP = DCT.DCT_CODPRO
				AND D11.%NotDel%
				WHERE DCT.DCT_FILIAL = %xFilial:DCT%
				AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
				AND DCT.DCT_CARGA  = %Exp:Self:GetCarga()%
				AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
				AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
				AND DCT.%NotDel%
				%Exp:cWhere%
				ORDER BY ORD_PRDCMP,
							DCT.DCT_CODPRO,
							DCT.DCT_LOTE,
							DCT.DCT_SUBLOT
			EndSql
		EndIf
		TcSetField(cAliasQry,'ORD_PRDCMP','N',5,0)
		TcSetField(cAliasQry,'DCT_SALDO','N',aTamDCT[1],aTamDCT[2])
		TcSetField(cAliasQry,'D11_QTMULT','N',aTamD11[1],aTamD11[2])
		Do While (cAliasQry)->(!Eof())
			If (cAliasQry)->DCT_PRDORI != (cAliasQry)->DCT_CODPRO
				lHasChild := .T.
			EndIf
			If lVerChild .And. lHasChild .And.; //Se deve verificar os filhos e já encontrou um filho
				(cAliasQry)->DCT_PRDORI == (cAliasQry)->DCT_CODPRO // e o produto atual é o pai, sai fora
				Exit
			EndIf
			// Se mudou o filho ou é o primeiro restaura a quantidade original
			If Empty(cLastChild) .Or. cLastChild != (cAliasQry)->DCT_CODPRO
				// Se pro filho anterior não conseguiu atender tudo, sai fora
				If !Empty(cLastChild) .And. QtdComp(nQtde) > 0
					Exit
				EndIf
				nQtde := nQtdOri
				cLastChild := (cAliasQry)->DCT_CODPRO
			EndIf
			// Calcula a quantidade que pode ser "rateada" para este produto
			If QtdComp(nQtde) > Iif(!lVerChild,QtdComp((cAliasQry)->DCT_SALDO),QtdComp((cAliasQry)->DCT_SALDO / (cAliasQry)->D11_QTMULT))
				nQtdPrd := (cAliasQry)->DCT_SALDO
				nQtde   -= Iif(!lVerChild,(cAliasQry)->DCT_SALDO,((cAliasQry)->DCT_SALDO / (cAliasQry)->D11_QTMULT))
			Else
				nQtdPrd := Iif(!lVerChild,nQtde,(nQtde * (cAliasQry)->D11_QTMULT))
				nQtde   := 0
			EndIf
			// Adiciona o produto no array de produtos a serem colocados no volume
			If QtdComp(nQtdPrd) > 0
				AAdd(aProdutos, {(cAliasQry)->DCT_CODPRO, (cAliasQry)->DCT_LOTE, (cAliasQry)->DCT_SUBLOT, nQtdPrd, (cAliasQry)->DCT_PRDORI})
			EndIf
			cProdAnt := (cAliasQry)->DCT_CODPRO
			// Se não é produto componente e zerou a quantidade, deve sair
			If lVerChild .And. !lHasChild .And. QtdComp(nQtde) == 0
				Exit
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
	Else
		BeginSql Alias cAliasQry
			SELECT DCT.DCT_PRDORI,
					DCT.DCT_CODPRO,
					DCT.DCT_LOTE,
					DCT.DCT_SUBLOT,
					(DCT.DCT_QTSEPA - DCT.DCT_QTEMBA) DCT_SALDO
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
			AND DCT.DCT_CARGA = %Exp:Self:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.%NotDel%
			%Exp:cWhere%
			ORDER BY DCT.DCT_CODPRO,
						DCT.DCT_LOTE,
						DCT.DCT_SUBLOT
		EndSql
		TcSetField(cAliasQry,'DCT_SALDO','N',aTamDCT[1],aTamDCT[2])
		Do While (cAliasQry)->(!Eof())
			// Calcula a quantidade que pode ser "rateada" para este produto
			If QtdComp(nQtde) > QtdComp((cAliasQry)->DCT_SALDO)
				nQtdPrd := (cAliasQry)->DCT_SALDO
				nQtde   -= (cAliasQry)->DCT_SALDO
			Else
				nQtdPrd := nQtde
				nQtde   := 0
			EndIf
			// Adiciona o produto no array de produtos a serem colocados no volume
			If QtdComp(nQtdPrd) > 0
				AAdd(aProdutos, {(cAliasQry)->DCT_CODPRO, (cAliasQry)->DCT_LOTE, (cAliasQry)->DCT_SUBLOT, nQtdPrd, (cAliasQry)->DCT_PRDORI})
			EndIf
			// Se zerou a quantidade, deve sair
			If QtdComp(nQtde) == 0
				Exit
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(DbCloseArea())
	// Se sobrou quantidade de um produto filho ou do produto normal
	If QtdComp(nQtde) > 0
		Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",cProdAnt}}) //"Quantidade em volumes mais informada ultrapassa a quantidade separada do produto [VAR01]."
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
METHOD MntPrdVol(aProdutos) CLASS WMSDTCMontagemVolumeItens
Local lRet        := .T.
Local lCarga      := WmsCarga(Self:GetCarga())
Local aTamSC9     := TamSx3('C9_QTDLIB')
Local aTamDCV     := TamSx3('DCV_QUANT')
Local oProdComp   := WMSDTCProdutoComponente():New()
Local cAliasSC9   := Nil
Local cAliasDCV   := Nil
Local nY          := 0
Local nQtdVol     := 0
Local nQtdMult    := 1
Local nQtdTot     := 0
Local nQtdSld     := 0

	Begin Transaction
		Self:oVolItens:SetCodOpe(__cUserID)
		For nY := 1  To Len(aProdutos)
			Self:cProduto := aProdutos[nY,1]
			Self:cLoteCtl := aProdutos[nY,2]
			Self:cNumLote := aProdutos[nY,3]
			Self:cPrdOri  := aProdutos[nY,5]
			If Self:LoadData()
				nQtdTot := aProdutos[nY,4]
				nQtdMult := 1
				// Verifica se o produto é um filho
				If aProdutos[nY,1] != aProdutos[nY,5]
					oProdComp:SetPrdCmp(aProdutos[nY,1])
					If oProdComp:LoadData(2)
						nQtdMult := oProdComp:GetQtMult()
					EndIf
				EndIf
				nQtdTot := aProdutos[nY,4] / nQtdMult
				// Buscar o item e sequen da SC9 correspondente
				cAliasSC9 := GetNextAlias()
				If lCarga
					BeginSql Alias cAliasSC9
						SELECT SC9.C9_ITEM,
								SC9.C9_SEQUEN,
								SC9.C9_QTDLIB
						FROM %Table:SC9% SC9
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_CARGA = %Exp:Self:GetCarga()%
						AND SC9.C9_PEDIDO = %Exp:Self:GetPedido()%
						AND SC9.C9_PRODUTO = %Exp:Self:cPrdOri%
						AND SC9.C9_LOTECTL = %Exp:Self:cLoteCtl%
						AND SC9.C9_NUMLOTE = %Exp:Self:cNumLote%
						AND SC9.C9_BLWMS = '01'
						AND SC9.C9_BLEST = '  '
						AND SC9.%NotDel%
						ORDER BY SC9.C9_ITEM,
									SC9.C9_SEQUEN
					EndSql
				Else
					BeginSql Alias cAliasSC9
						SELECT SC9.C9_ITEM,
								SC9.C9_SEQUEN,
								SC9.C9_QTDLIB
						FROM %Table:SC9% SC9
						WHERE SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_PEDIDO = %Exp:Self:GetPedido()%
						AND SC9.C9_PRODUTO = %Exp:Self:cPrdOri%
						AND SC9.C9_LOTECTL = %Exp:Self:cLoteCtl%
						AND SC9.C9_NUMLOTE = %Exp:Self:cNumLote%
						AND SC9.C9_BLWMS = '01'
						AND SC9.C9_BLEST = '  '
						AND SC9.%NotDel%
						ORDER BY SC9.C9_ITEM,
									SC9.C9_SEQUEN
					EndSql
				EndIf
				TcSetField(cAliasSC9,'C9_QTDLIB','N',aTamSC9[1],aTamSC9[2])
				If (cAliasSC9)->(Eof())
					Self:cErro := STR0011+" "+; // "Não foi encontrado a liberação do pedido:[VAR01]"
								  Iif(lCarga,STR0012+" ","")+; // "carga:[VAR02]"
								  STR0013+" "+; // "produto:[VAR03]"
								  Iif(!Empty(Self:cLoteCtl),STR0014,"") // "lote:[VAR04]"
				
					Self:cErro := WmsFmtMsg(Self:cErro,{{"[VAR01]",Self:GetPedido()},{"[VAR02]",Self:GetCarga()},{"[VAR03]",Self:cPrdOri},{"[VAR04]",Self:cLoteCtl}})
					lRet := .F.
				EndIf
				Do While lRet .And. (cAliasSC9)->(!Eof()) .And. nQtdTot > 0
					// É preciso descontar a quantidade embalada em volumes anteriores
					cAliasDCV := GetNextAlias()
					BeginSql Alias cAliasDCV
						SELECT SUM(DCV.DCV_QUANT) AS SOMADCV
						FROM %Table:DCV% DCV
						WHERE DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_CODMNT = %Exp:Self:GetCodMnt()%
						AND DCV.DCV_CARGA = %Exp:Self:GetCarga()%
						AND DCV.DCV_PEDIDO = %Exp:Self:GetPedido()%
						AND DCV.DCV_PRDORI = %Exp:Self:cPrdOri%
						AND DCV.DCV_CODPRO = %Exp:Self:cProduto%
						AND DCV.DCV_LOTE = %Exp:Self:cLoteCtl%
						AND DCV.DCV_SUBLOT = %Exp:Self:cNumLote%
						AND DCV.DCV_ITEM = %Exp:(cAliasSC9)->C9_ITEM%
						AND DCV.DCV_SEQUEN = %Exp:(cAliasSC9)->C9_SEQUEN%
						AND DCV.DCV_STATUS = '1'
						AND DCV.%NotDel%
					EndSql
					TcSetField(cAliasDCV,'SOMADCV','N',aTamDCV[1],aTamDCV[2])
					nQtdSld := ((cAliasSC9)->C9_QTDLIB - ((cAliasDCV)->SOMADCV / nQtdMult))
					(cAliasDCV)->(dbCloseArea())
	
					If QtdComp(nQtdSld) > QtdComp(nQtdTot)
						nQtdVol := nQtdTot * nQtdMult
					Else
						nQtdVol := nQtdSld * nQtdMult
					EndIf
					If QtdComp(nQtdVol) <= 0
						(cAliasSC9)->(dbSkip())
						Loop
					EndIf
					nQtdTot -= (nQtdVol / nQtdMult)
					// DCV
					Self:oVolItens:SetDtIni(dDataBase)
					Self:oVolItens:SetHrIni(Time())
					Self:oVolItens:SetPrdOri(Self:cPrdOri)
					Self:oVolItens:SetProduto(Self:cProduto)
					Self:oVolItens:SetLoteCtl(Self:cLoteCtl)
					Self:oVolItens:SetNumLote(Self:cNumLote)
					Self:oVolItens:SetItem((cAliasSC9)->C9_ITEM)
					Self:oVolItens:SetSequen((cAliasSC9)->C9_SEQUEN)
					Self:oVolItens:SetQuant(nQtdVol)
					Self:oVolItens:AssignDCV()
					// DCT
					Self:SetQtdEmb(Self:GetQtdEmb() + nQtdVol)
					Self:UpdateDCT()
				EndDo
				(cAliasSC9)->(dbCloseArea())
			EndIf
			If !lRet
				Exit
			EndIf
		Next nY
		// Atualiza o status para da DCV para liberado
		If lRet .And. Self:oMntVol:GetLibPed() == "6" .And. Self:oMntVol:GetStatus() == "3"
			Self:oMntVol:LiberSC9()
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	If lRet .And. Self:oMntVol:GetLibPed() == "6" .And. Self:oMntVol:GetStatus() == "3"
		If Existblock("WMTLSC9")
			Execblock("WMTLSC9",.F.,.F.,{Self:GetCodMnt(),Self:GetCarga(),Self:GetPedido()})
		Endif
	Endif
Return lRet

//-----------------------------------------------------------------------------
METHOD RevMntVol(nQtdOri,nQtdSep) CLASS WMSDTCMontagemVolumeItens
Local lRet := .T.
Local cStatus := ""

	If QtdComp(Self:nQtdOri-nQtdOri) <= 0
		DCT->(dbGoTo( Self:GetRecno() ))
		RecLock('DCT', .F.)
		DCT->(dbDelete())
		DCT->(MsUnLock())
		If DCT->DCT_CODPRO <> DCT->DCT_PRDORI
			DCT->(DbSetOrder(1)) // DCT_FILIAL+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_CODPRO+DCT_LOTE+DCT_SUBLOT
			If DCT->(dbSeek(xFilial("DCT")+DCT_CODMNT+DCT_CARGA+DCT_PEDIDO+DCT_PRDORI+DCT_PRDORI+DCT_LOTE+DCT_SUBLOT))
				Self:CalcMntVol(1)
				RecLock('DCT', .F.)
				If QtdComp(Self:nTotOri) <= 0
					DCT->(dbDelete())
				Else
					If QtdComp(Self:nTotEmb) == 0
						cStatus := '1' // Não Iniciado
					ElseIf QtdComp(Self:nTotEmb) == QtdComp(Self:nTotOri)
						cStatus := '3' // Finalizado
					Else
						cStatus := '2' // Em Andamento
					EndIf
					RecLock('DCT', .F.)
					DCT->DCT_QTORIG := Self:nTotOri
					DCT->DCT_QTSEPA := Self:nTotSep
					DCT->DCT_QTEMBA := Self:nTotEmb
					DCT->DCT_STATUS := cStatus
				EndIf
				DCT->(MsUnLock())
			EndIf
		EndIf
		// Recalcula a quantidade original da capa
		Self:CalcMntVol(2)
		If QtdComp(Self:nTotOri) <= 0
			lRet := Self:oMntVol:ExcludeDCS()
			// Delete D0I
			If lRet
				Self:DeleteD0I()
			EndIf
		Else
			Self:oMntVol:SetQtdOri(Self:nTotOri)
			Self:oMntVol:SetQtdSep(Self:nTotSep)
			Self:oMntVol:SetQtdEmb(Self:nTotEmb)
			lRet := Self:oMntVol:UpdateDCS()
			If lRet .And. Self:oMntVol:GetStatus() = "3" .And. FindFunction("WMSLibVols")//Só altera para 3 quando as quantidades conferem
				WMSLibVols(Self:oMntVol)
			EndIf
		EndIf
	Else
		Self:nQtdOri -= nQtdOri
		Self:nQtdSep -= nQtdSep
		lRet := Self:UpdateDCT()
	EndIf
	If !lRet
		Self:cErro := STR0005  // Problemas no processo de estorno da montagem de volume (RevMntVol)!
	EndIf
Return lRet

METHOD DelMntVol() CLASS WMSDTCMontagemVolumeItens
Local lRet      := .T.
Local cAliasDCT := GetNextAlias()
	// Exclui DCT
	If Self:cProduto != Self:cPrdOri
		BeginSql Alias cAliasDCT
			SELECT DCT.R_E_C_N_O_ RECNODCT
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CARGA =  %Exp:Self:oMntVol:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:oMntVol:GetPedido()%
			AND DCT.DCT_CODMNT = %Exp:Self:oMntVol:GetCodMnt()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_QTORIG <= 0
			AND DCT.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasDCT
			SELECT DCT.R_E_C_N_O_ RECNODCT
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CARGA =  %Exp:Self:oMntVol:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:oMntVol:GetPedido()%
			AND DCT.DCT_CODMNT = %Exp:Self:oMntVol:GetCodMnt()%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_QTORIG <= 0
			AND DCT.%NotDel%
		EndSql
	EndIf
	Do While (cAliasDCT)->(!Eof())
		DCT->(dbGoTo((cAliasDCT)->RECNODCT))
		RecLock('DCT', .F.)
		DCT->(dbDelete())
		DCT->(MsUnLock())
		(cAliasDCT)->(dbSkip())
	EndDo
	(cAliasDCT)->(dbCloseArea())
	// Recalcula DCS cada vez que um DCT é excluído, excluindo quando chega a 0
	Self:CalcMntVol(2)
	If QtdComp(Self:nTotOri) <= 0
		lRet := Self:oMntVol:ExcludeDCS()
		// Delete D0I
		If lRet
			Self:DeleteD0I()
		EndIf
	Else
		Self:oMntVol:SetQtdOri(Self:nTotOri)
		Self:oMntVol:SetQtdSep(Self:nTotSep)
		Self:oMntVol:SetQtdEmb(Self:nTotEmb)
		lRet := Self:oMntVol:UpdateDCS()
	EndIf
Return lRet

METHOD UpdQtdParc(nQtdQuebra,lBxEmp) CLASS WMSDTCMontagemVolumeItens
Local aAreaAnt  := GetArea()
Local cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCT.R_E_C_N_O_ RECNODCT,
				CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END D11_QTMULT
		FROM %Table:DCT% DCT
		LEFT JOIN %Table:D11% D11
		ON D11.D11_FILIAL = %xFilial:D11%
		AND DCT.DCT_FILIAL = %xFilial:DCT%
		AND D11.D11_PRDORI = DCT.DCT_PRDORI
		AND D11.D11_PRDCMP = DCT.DCT_CODPRO
		AND D11.%NotDel%
		WHERE DCT.DCT_FILIAL = %xFilial:DCT%
		AND DCT.DCT_CODMNT = %Exp:Self:GetCodMnt()%
		AND DCT.DCT_CARGA =  %Exp:Self:GetCarga()%
		AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
		AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
		AND DCT.DCT_LOTE =   %Exp:Self:cLoteCtl%
		AND DCT.DCT_SUBLOT = %Exp:Self:cNumLote%
		AND DCT.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		Self:GoToDCT((cAliasQry)->RECNODCT)
		Self:nQtdOri -= (nQtdQuebra * (cAliasQry)->D11_QTMULT)
		If lBxEmp
			Self:nQtdSep -= (nQtdQuebra * (cAliasQry)->D11_QTMULT)
		EndIf
		If Self:UpdateDCT()
			Self:DelMntVol()
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	// Liberação dos pedidos do volume
	If Self:oMntVol:GetLibPed() == "6" .And. Self:oMntVol:GetStatus() == "3"
		Self:oMntVol:LiberSC9()
	EndIf
	RestArea(aAreaAnt)
Return Nil

METHOD DeleteD0I() CLASS WMSDTCMontagemVolumeItens
	D0I->(DbSetOrder(1)) // D0I_FILIAL+D0I_CODMNT+D0I_IDDCF
	If D0I->(DbSeek(xFilial('D0I')+Self:GetCodMnt()+Self:GetIdDCF()))
		RecLock('D0I',.F.)
		D0I->(DbDelete())
		D0I->(MsUnlock())
	EndIf
Return .T.

METHOD GeraIdDCF() CLASS WMSDTCMontagemVolumeItens
Local aIdDCFs  := {}
Local aAreaD0I := D0I->(GetArea())
	D0I->(dbSetOrder(1)) // D0I_FILIAL+D0I_CODMNT+D0I_IDDCF
	D0I->(dbSeek(xFilial('D0I')+Self:GetCodMnt()))
	Do While D0I->(!Eof()) .And. D0I->D0I_CODMNT == Self:GetCodMnt()
		Aadd(aIdDCFs,D0I->D0I_IDDCF)
		D0I->(dbSkip())
	EndDo
	RestArea(aAreaD0I)
Return aIdDCFs

METHOD CalcQtdMnt() CLASS WMSDTCMontagemVolumeItens
Local cWhere    := ""
Local cAliasDCT := Nil
Local nQtdOri   := 0
Local nQtdEmb   := 0
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND DCT.DCT_LOTE = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND DCT.DCT_SUBLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	aTamSX3 := TamSx3("DCT_QTORIG")
	cAliasDCT := GetNextAlias()
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		// Verifica a quantidade distribuida
		BeginSql Alias cAliasDCT
			SELECT SUM(DCT.DCT_QTORIG) DCT_QTORIG,
					SUM(DCT.DCT_QTEMBA) DCT_QTEMBA
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CARGA = %Exp:Self:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		// Verifica a quantidade distribuida
		BeginSql Alias cAliasDCT
			SELECT SUM(DCT.DCT_QTORIG) DCT_QTORIG,
					SUM(DCT.DCT_QTEMBA) DCT_QTEMBA
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	TcSetField(cAliasDCT,'DCT_QTORIG','N',aTamSx3[1],aTamSx3[2])
	TcSetField(cAliasDCT,'DCT_QTEMBA','N',aTamSx3[1],aTamSx3[2])
	If (cAliasDCT)->(!Eof())
		nQtdOri := (cAliasDCT)->DCT_QTORIG
		nQtdEmb := (cAliasDCT)->DCT_QTEMBA
	EndIf
	(cAliasDCT)->(dbCloseArea())
Return {nQtdOri,nQtdEmb}

METHOD ChkQtdMnt(aIdDCFs) CLASS WMSDTCMontagemVolumeItens
Local aOrdSer   := {}
Local aTamSx3   := {}
Local cWhere    := ""
Local cAliasDCT := Nil
Local cAliasD12 := Nil
Local nI        := 0
Local nQtdMnt   := 0
Local nQtdOri   := 0

Default aIdDCFs   := {}
	aTamSX3 := TamSx3("DCT_QTEMBA")
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND DCT.DCT_LOTE = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND DCT.DCT_SUBLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	cAliasDCT := GetNextAlias()
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga()) 
		// Verifica a quantidade distribuida
		BeginSql Alias cAliasDCT
			SELECT SUM(DCT.DCT_QTEMBA) DCT_QTEMBA
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_CARGA  = %Exp:Self:GetCarga()%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		// Verifica a quantidade distribuida
		BeginSql Alias cAliasDCT
			SELECT SUM(DCT.DCT_QTEMBA) DCT_QTEMBA
			FROM %Table:DCT% DCT
			WHERE DCT.DCT_FILIAL = %xFilial:DCT%
			AND DCT.DCT_PEDIDO = %Exp:Self:GetPedido()%
			AND DCT.DCT_PRDORI = %Exp:Self:cPrdOri%
			AND DCT.DCT_CODPRO = %Exp:Self:cProduto%
			AND DCT.%NotDel%
			%Exp:cWhere%
		EndSql
	EndIf
	TcSetField(cAliasDCT,'DCT_QTEMBA','N',aTamSx3[1],aTamSx3[2])
	If (cAliasDCT)->(!Eof())
		nQtdTot := (cAliasDCT)->DCT_QTEMBA
	EndIf
	(cAliasDCT)->(dbCloseArea())
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:cLoteCtl)
		cWhere += " AND D12.D12_LOTECT = '"+Self:cLoteCtl+"'"
	EndIf
	If !Empty(Self:cNumLote)
		cWhere += " AND D12.D12_NUMLOT = '"+Self:cNumLote+"'"
	EndIf
	cWhere += "%"
	aTamSX3 := TamSx3("DCR_QUANT")
	cAliasD12 := GetNextAlias()
	If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
		// Verifica a quantidade origem
		BeginSql Alias cAliasD12
			SELECT DCR.DCR_IDDCF,
					SUM(DCR.DCR_QUANT) DCR_QUANT
			FROM %Table:D12% D12
			INNER JOIN %Table:D0I% D0I
			ON D0I.D0I_FILIAL = %xFilial:D0I%
			AND D0I.%NotDel%
			INNER JOIN %Table:DCR% DCR
			ON DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = D0I.D0I_IDDCF
			AND DCR.%NotDel%
			INNER JOIN %Table:DCF% DCF
			ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_ID = D0I.D0I_IDDCF
			AND DCF.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_CARGA = %Exp:Self:GetCarga()%
			AND D12.D12_DOC = %Exp:Self:GetPedido()%
			AND D12.D12_PRDORI = %Exp:Self:cPrdOri%
			AND D12.D12_PRODUT = %Exp:Self:cProduto%
			AND D12.D12_ATUEST = '1'
			AND D12.D12_STATUS = '1'
			AND D12.%NotDel%
			%Exp:cWhere%
			GROUP BY DCR.DCR_IDDCF
		EndSql
	Else
		// Verifica a quantidade origem
		BeginSql Alias cAliasD12
			SELECT DCR.DCR_IDDCF,
					SUM(DCR.DCR_QUANT) DCR_QUANT
			FROM %Table:D12% D12
			INNER JOIN %Table:D0I% D0I
			ON D0I.D0I_FILIAL = %xFilial:D0I%
			AND D0I.%NotDel%
			INNER JOIN %Table:DCR% DCR
			ON DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.DCR_IDDCF = D0I.D0I_IDDCF
			AND DCR.%NotDel%
			INNER JOIN %Table:DCF% DCF
			ON DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_ID = D0I.D0I_IDDCF
			AND DCF.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_DOC = %Exp:Self:GetPedido()%
			AND D12.D12_PRDORI = %Exp:Self:cPrdOri%
			AND D12.D12_PRODUT = %Exp:Self:cProduto%
			AND D12.D12_ATUEST = '1'
			AND D12.D12_STATUS = '1'
			AND D12.%NotDel%
			%Exp:cWhere%
			GROUP BY DCR.DCR_IDDCF
		EndSql
	EndIf
	TcSetField(cAliasD12,'DCR_QUANT','N',aTamSx3[1],aTamSx3[2])
	Do While (cAliasD12)->(!Eof())
		cIdDCF  := (cAliasD12)->DCR_IDDCF
		nQtdMov := (cAliasD12)->DCR_QUANT
		nQtdMnt := 0
		If QtdComp(nQtdTot) > QtdComp(0)
			If QtdComp(nQtdTot) > QtdComp(nQtdMov)
				nQtdMnt := nQtdMov
			Else
				nQtdMnt := nQtdTot
			EndIf
			nQtdTot -= nQtdMnt
		EndIf
		aAdd(aOrdSer,{cIdDCF,nQtdMov,nQtdMnt})
		(cAliasD12)->(dbSkip())
	EndDo
	(cAliasD12)->(dbCloseArea())
	// Inicializa quantidades
	nQtdOri := 0
	nQtdMnt := 0
	// Monta os id dcfs
	For nI := 1 To Len(aIdDCFs)
		If (nPos := AScan(aOrdSer, { |x| x[1] == aIdDCFs[nI] })) > 0
			nQtdOri += aOrdSer[nPos][2]
			nQtdMnt += aOrdSer[nPos][3]
		EndIf
	Next nI
Return {nQtdOri,nQtdMnt}
