#Include "Totvs.ch"  
#Include "WMSDTCMontagemVolume.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0024
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0024()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCMontagemVolume
Classe estrutura física
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCMontagemVolume FROM LongNameClass
	// Data
	DATA cCarga
	DATA cPedido
	DATA cCodMnt
	DATA cStatus
	DATA nQtdOri
	DATA nQtdSep
	DATA nQtdEmb
	DATA dData
	DATA cHora
	DATA cLibPed
	DATA cMntExc
	DATA cLibEst
	DATA cIdDCF
	DATA cMltati
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD FindCodMnt()
	METHOD RecordDCS()
	METHOD UpdateDCS()	
	METHOD ExcludeDCS()
	// Setters
	METHOD SetPedido(cPedido)
	METHOD SetCarga(cCarga)
	METHOD SetCodMnt(cCodMnt)
	METHOD SetStatus(cStatus)
	METHOD SetQtdOri(nQtdOri)
	METHOD SetQtdSep(nQtdSep)
	METHOD SetQtdEmb(nQtdEmb)
	METHOD SetLibPed(cLibPed)
	METHOD SetMntExc(cMntExc)
	METHOD SetLibEst(cLibEst)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetMultAtiv(cMltati)
	// Getters
	METHOD GetPedido()
	METHOD GetCarga()
	METHOD GetCodMnt()
	METHOD GetStatus()
	METHOD GetQtdOri()
	METHOD GetQtdSep()
	METHOD GetQtdEmb()
	METHOD GetLibPed()
	METHOD GetMntExc()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD GetLibEst()
	METHOD GetIdDCF()
	METHOD GetMultAtiv() 
	// Metodos
	METHOD ChkPedFat()
	METHOD ChkCarga()
	METHOD LiberSC9()
	METHOD UpdSitDCV()
	METHOD Destroy()
	METHOD UpdLibEst()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.corra
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCMontagemVolume
	Self:cPedido := PadR("", TamSx3("DCS_PEDIDO")[1])
	Self:cCarga  := PadR("", TamSx3("DCS_CARGA")[1])
	Self:cCodMnt := PadR("", TamSx3("DCS_CODMNT")[1])
	Self:cStatus := "1"
	Self:nQtdOri := 0
	Self:nQtdSep := 0
	Self:nQtdEmb := 0
	Self:dData   := dDataBase
	Self:cHora   := Time()
	Self:cErro   := ""
	Self:cLibPed := "6"
	Self:cMntExc := "2"
	Self:nRecno  := 0
	Self:cLibEst := "2"
	Self:cIdDCF  := PadR("", TamSx3("C9_IDDCF")[1])
	Self:cMltati := PadR("", TamSx3("DC5_MLTATI")[1])
Return

METHOD Destroy() CLASS WMSDTCMontagemVolume
	//Método mantido para compatibilidade
Return

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DCS
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMontagemVolume
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aDCS_QTSEPA := TamSx3("DCS_QTSEPA")
Local aDCS_QTEMBA := TamSx3("DCS_QTEMBA")
Local aDCS_QTORIG := TamSx3("DCS_QTORIG")
Local aAreaDCS    := DCS->(GetArea())
Local cAliasDCS   := Nil
Default nIndex := 1
	Do Case
		Case nIndex == 1 // DCS_FILIAL+DCS_CODMNT+DCS_CARGA+DCS_PEDIDO
			If Empty(Self:cPedido) .Or. Empty(Self:cCodMnt)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase	
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasDCS   := GetNextAlias()
		Do Case
			Case nIndex == 1
				If !Empty(Self:cCarga) .And. WMSCarga(Self:cCarga)
					BeginSql Alias cAliasDCS
						SELECT DCS.DCS_CARGA,
								DCS.DCS_PEDIDO,
								DCS.DCS_STATUS,
								DCS.DCS_QTSEPA,
								DCS.DCS_QTEMBA,
								DCS.DCS_DATA,
								DCS.DCS_HORA,
								DCS.DCS_CODMNT,
								DCS.DCS_QTORIG,
								DCS.DCS_LIBPED,
								DCS.DCS_MNTEXC,
								DCS.DCS_LIBEST,
								DCS.R_E_C_N_O_ RECNODCS
						FROM %Table:DCS% DCS
						WHERE DCS.DCS_FILIAL = %xFilial:DCS%
						AND DCS.DCS_CODMNT = %Exp:Self:cCodMnt%
						AND DCS.DCS_CARGA = %Exp:Self:cCarga%
						AND DCS.DCS_PEDIDO = %Exp:Self:cPedido%
						AND DCS.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasDCS
						SELECT DCS.DCS_CARGA,
								DCS.DCS_PEDIDO,
								DCS.DCS_STATUS,
								DCS.DCS_QTSEPA,
								DCS.DCS_QTEMBA,
								DCS.DCS_DATA,
								DCS.DCS_HORA,
								DCS.DCS_CODMNT,
								DCS.DCS_QTORIG,
								DCS.DCS_LIBPED,
								DCS.DCS_MNTEXC,
								DCS.DCS_LIBEST,
								DCS.R_E_C_N_O_ RECNODCS
						FROM %Table:DCS% DCS
						WHERE DCS.DCS_FILIAL = %xFilial:DCS%
						AND DCS.DCS_CODMNT = %Exp:Self:cCodMnt%
						AND DCS.DCS_PEDIDO = %Exp:Self:cPedido%
						AND DCS.%NotDel%
					EndSql
				EndIf
		EndCase
		TCSetField(cAliasDCS,'DCS_QTSEPA','N',aDCS_QTSEPA[1],aDCS_QTSEPA[2])
		TCSetField(cAliasDCS,'DCS_QTEMBA','N',aDCS_QTEMBA[1],aDCS_QTEMBA[2])
		TCSetField(cAliasDCS,'DCS_QTORIG','N',aDCS_QTORIG[1],aDCS_QTORIG[2])
		TcSetField(cAliasDCS,'DCS_DATA','D')
		If (lRet := (cAliasDCS)->(!Eof()))
			Self:cCodMnt := (cAliasDCS)->DCS_CODMNT
			Self:cCarga  := (cAliasDCS)->DCS_CARGA
			Self:cPedido := (cAliasDCS)->DCS_PEDIDO
			// Busca dados lote/produto
			Self:cStatus := (cAliasDCS)->DCS_STATUS
			Self:nQtdOri := (cAliasDCS)->DCS_QTORIG
			Self:nQtdSep := (cAliasDCS)->DCS_QTSEPA
			Self:nQtdEmb := (cAliasDCS)->DCS_QTEMBA
			Self:dData   := (cAliasDCS)->DCS_DATA
			Self:cHora   := (cAliasDCS)->DCS_HORA
			Self:cLibPed := (cAliasDCS)->DCS_LIBPED
			Self:cMntExc := (cAliasDCS)->DCS_MNTEXC
			Self:cLibEst := (cAliasDCS)->DCS_LIBEST
			Self:nRecno  := (cAliasDCS)->RECNODCS
		EndIf
		(cAliasDCS)->(dbCloseArea())
	EndIf
	RestArea(aAreaDCS)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCMontagemVolume
	Self:cCarga := PadR(cCarga, Len(Self:cCarga))
Return

METHOD SetPedido(cPedido) CLASS WMSDTCMontagemVolume
	Self:cPedido := PadR(cPedido, Len(Self:cPedido))
Return

METHOD SetCodMnt(cCodMnt) CLASS WMSDTCMontagemVolume
	Self:cCodMnt := PadR(cCodMnt, Len(Self:cCodMnt))
Return

METHOD SetQtdOri(nQtdOri) CLASS WMSDTCMontagemVolume
	Self:nQtdOri := nQtdOri
Return

METHOD SetQtdSep(nQtdSep) CLASS WMSDTCMontagemVolume
	Self:nQtdSep := nQtdSep
Return

METHOD SetQtdEmb(nQtdEmb) CLASS WMSDTCMontagemVolume
	Self:nQtdEmb := nQtdEmb
Return

METHOD SetStatus(cStatus) CLASS WMSDTCMontagemVolume
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetLibPed(cLibPed) CLASS WMSDTCMontagemVolume
	Self:cLibPed := PadR(cLibPed, Len(Self:cLibPed))
Return

METHOD SetMntExc(cMntExc) CLASS WMSDTCMontagemVolume
	Self:cMntExc := PadR(cMntExc, Len(Self:cMntExc))
Return

METHOD SetLibEst(cLibEst) CLASS WMSDTCMontagemVolume
	Self:cLibEst := PadR(cLibEst, Len(Self:cLibEst))
Return

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMontagemVolume
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return

METHOD SetMultAtiv(cMltati) CLASS WMSDTCMontagemVolume
	Self:cMltati := PadR(cMltati, Len(Self:cMltati))
Return


//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCMontagemVolume
Return Self:cCarga

METHOD GetPedido() CLASS WMSDTCMontagemVolume
Return Self:cPedido

METHOD GetCodMnt() CLASS WMSDTCMontagemVolume
Return Self:cCodMnt

METHOD GetQtdOri() CLASS WMSDTCMontagemVolume
Return Self:nQtdOri

METHOD GetQtdSep() CLASS WMSDTCMontagemVolume
Return Self:nQtdSep

METHOD GetQtdEmb() CLASS WMSDTCMontagemVolume
Return Self:nQtdEmb

METHOD GetStatus() CLASS WMSDTCMontagemVolume
Return Self:cStatus

METHOD GetLibPed() CLASS WMSDTCMontagemVolume
Return Self:cLibPed

METHOD GetMntExc() CLASS WMSDTCMontagemVolume
Return Self:cMntExc

METHOD GetRecno() CLASS WMSDTCMontagemVolume
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCMontagemVolume
Return Self:cErro

METHOD GetLibEst() CLASS WMSDTCMontagemVolume
Return Self:cLibEst

METHOD GetIdDCF() CLASS WMSDTCMontagemVolume
Return Self:cIdDCF

METHOD GetMultAtiv() CLASS WMSDTCMontagemVolume
Return Self:cMltati


METHOD ChkCarga() CLASS WMSDTCMontagemVolume
Local lRet := .T.
Local aAreaDCS := DCS->(GetArea())
	DCS->(dbSetOrder(2))
	If !DCS->(dbSeek(xFilial("DCS")+Self:cCarga))
		Self:cErro := STR0002 // Não existe montagem para esta carga!
		lRet := .F.
	EndIf
	RestArea(aAreaDCS)
Return lRet

METHOD FindCodMnt() CLASS WMSDTCMontagemVolume
Local aAreaAnt  := GetArea()
Local cAliasDCS := GetNextAlias()
Local cCodMnt   := ""
	BeginSql Alias cAliasDCS
		SELECT MAX(DCS.DCS_CODMNT) DCS_CODMNT
		FROM %Table:DCS% DCS
		WHERE DCS.DCS_FILIAL = %xFilial:DCS%
		AND DCS.DCS_CARGA = %Exp:Self:cCarga%
		AND DCS.DCS_PEDIDO = %Exp:Self:cPedido%
		AND DCS.%NotDel%
	EndSql
	If (cAliasDCS)->(!Eof())
		cCodMnt := (cAliasDCS)->DCS_CODMNT
	EndIf
	(cAliasDCS)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cCodMnt

METHOD RecordDCS() CLASS WMSDTCMontagemVolume
Local lRet     := .T.
	Self:cCodMnt := GetSX8Num('DCS','DCS_CODMNT'); IIf(__lSX8,ConfirmSX8(),)
	Self:cStatus := "1"
	Self:dData   := dDataBase
	Self:cHora   := Time()
	Self:nQtdOri := 0
	Self:nQtdSep := 0
	Self:nQtdEmb := 0
	// Grava DCF
	DCS->(dbSetOrder(1))
	If !DCS->(dbSeek(xFilial("DCS")+Self:cCodMnt+Self:cCarga+Self:cPedido))
		RecLock('DCS', .T.)
		DCS->DCS_FILIAL := xFilial("DCS")
		DCS->DCS_CODMNT := Self:cCodMnt
		DCS->DCS_CARGA  := Self:cCarga
		DCS->DCS_PEDIDO := Self:cPedido
		DCS->DCS_STATUS := Self:cStatus
		DCS->DCS_QTORIG := Self:nQtdOri
		DCS->DCS_QTSEPA := Self:nQtdSep
		DCS->DCS_QTEMBA := Self:nQtdEmb
		DCS->DCS_DATA   := Self:dData
		DCS->DCS_HORA   := Self:cHora
		DCS->DCS_LIBPED := Self:cLibPed
		DCS->DCS_MNTEXC := Self:cMntExc
		DCS->DCS_LIBEST := "2"
		DCS->(MsUnLock())
		// Grava recno
		Self:nRecno := DCS->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0004 // Chave duplicada! 
	EndIf
Return lRet

METHOD UpdateDCS() CLASS WMSDTCMontagemVolume
Local lRet      := .T.
Local cAliasDCT := Nil
	If !Empty(Self:GetRecno())
		DCS->(dbGoTo( Self:GetRecno() ))
		// Status
		If QtdComp(Self:nQtdEmb) == 0
			// Verica se há algum produto da carga/pedido que esteja em andamento
			// situação ocorrerá quando produto/componente
			cAliasDCT := GetNextAlias()
			BeginSql Alias cAliasDCT
				SELECT 1
				FROM %Table:DCT% DCT
				WHERE DCT.DCT_FILIAL = %xFilial:DCT%
				AND DCT.DCT_CODMNT = %Exp:DCS->DCS_CODMNT%
				AND DCT.DCT_CARGA = %Exp:DCS->DCS_CARGA%
				AND DCT.DCT_PEDIDO = %Exp:DCS->DCS_PEDIDO%
				AND DCT.DCT_CODPRO <> DCT.DCT_PRDORI
				AND DCT.DCT_STATUS <> '1'
				AND DCT.%NotDel%
			EndSql
			If (cAliasDCT)->(!Eof())
				Self:cStatus := "2" // Em Andamento
			Else
				Self:cStatus := "1" // Não Iniciado
			EndIf
			(cAliasDCT)->(dbCloseArea())
		ElseIf QtdComp(Self:nQtdOri) == QtdComp(Self:nQtdEmb)
			Self:cStatus := "3" // Finalizado			
		Else 
			Self:cStatus := "2" // Em Andamente
		EndIf		
		// Grava DCS
		RecLock('DCS', .F.)
		DCS->DCS_QTORIG := Self:nQtdOri
		DCS->DCS_QTSEPA := Self:nQtdSep
		DCS->DCS_QTEMBA := Self:nQtdEmb
		DCS->DCS_STATUS := Self:cStatus
		DCS->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0005 // Dados não encontrados!
	EndIf	
Return lRet

METHOD ExcludeDCS() CLASS WMSDTCMontagemVolume
Local lRet     := .T.
	DCS->(dbGoTo( Self:GetRecno() ))
	// Excluindo a ordem de serviço
	RecLock('DCS', .F.)
	DCS->(DbDelete())
	DCS->(MsUnlock())
Return lRet

METHOD ChkPedFat() CLASS WMSDTCMontagemVolume
Local lRet      := .F.
Local aTamSx3   := TamSx3("C9_QTDLIB")
Local aAreaAnt  := GetArea()
Local cAliasSC9 := GetNextAlias()
	If WmsCarga(Self:cCarga)
		BeginSql Alias cAliasSC9
			SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB
			FROM %Table:SC9% SC9
			INNER JOIN %Table:D0I% D0I
			ON D0I.D0I_FILIAL =  %xFilial:D0I%
			AND D0I.D0I_CODMNT = %Exp:Self:GetCodMnt()%
			AND D0I.D0I_IDDCF = SC9.C9_IDDCF
			AND D0I.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_CARGA =  %Exp:Self:cCarga%
			AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasSC9
			SELECT SUM(SC9.C9_QTDLIB) C9_QTDLIB
			FROM %Table:SC9% SC9
			INNER JOIN %Table:D0I% D0I
			ON D0I.D0I_FILIAL =  %xFilial:D0I%
			AND D0I.D0I_CODMNT = %Exp:Self:GetCodMnt()%
			AND D0I.D0I_IDDCF = SC9.C9_IDDCF
			AND D0I.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:Self:cPedido%
			AND SC9.C9_NFISCAL <> ' '
			AND SC9.%NotDel%
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
//-----------------------------------------------------------------//
//--------------Liberação do Pedido de Venda Liberado--------------//
//-----------------------------------------------------------------//
METHOD LiberSC9() CLASS WMSDTCMontagemVolume
	Local lLibSC9 := .F.
	DCU->(dbSetOrder(2)) // DCU_FILIAL+DCU_CARGA+DCU_PEDIDO+DCU_CODMNT+DCU_CODVOL
	DCV->(dbSetOrder(1)) // DCV_FILIAL+DCV_CODMNT+DCV_CODVOL+DCV_PRDORI+DCV_CODPRO+DCV_LOTE+DCV_SUBLOT+DCV_ITEM+DCV_SEQUEN
	SC9->(dbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	If DCU->(dbSeek(xFilial('DCU')+Self:cCarga+Self:cPedido+Self:cCodMnt))
		Do While DCU->(!Eof()) .And. DCU->(DCU_FILIAL+DCU_CARGA+DCU_PEDIDO+DCU_CODMNT) == xFilial("DCU")+Self:cCarga+Self:cPedido+Self:cCodMnt
			// Posiciona dcv
			If DCV->(dbSeek(xFilial('DCV')+Self:cCodMnt+DCU->DCU_CODVOL))
				Do While DCV->(!Eof()) .And. DCV->(DCV_FILIAL+DCV_CODMNT+DCV_CODVOL)  == xFilial("DCV")+Self:cCodMnt+DCU->DCU_CODVOL					
					// Desbloqueia os pedidos de venda
					If DCV->DCV_STATUS == "1"
						If SC9->(MsSeek(xFilial('SC9')+DCV->(DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI)))
							If SC9->(!Eof()) .And. (SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO) == xFilial('SC9')+DCV->(DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI))
								IF Self:GetMultAtiv() != "1" .Or.; //DC5_MLTATI - Quando 1, processa LiberSC9 por item
									Empty(Self:GetIdDCF()) .Or. SC9->C9_IDDCF ==  Self:GetIdDCF()
									If SC9->C9_BLWMS != "05"
										RecLock('SC9',.F.)
										SC9->C9_BLWMS := "05"
										SC9->(MsUnlock())
									EndIf
									// Libera blwms.
									RecLock('DCV',.F.)
										DCV->DCV_STATUS := "2" // Liberado
									DCV->(MsUnlock())
									lLibSC9 := .T.
								EndIf
							EndIf
						EndIf
					EndIf
					DCV->(dbSkip())
				EndDo
			EndIf
			DCU->(dbSkip())
		EndDo
	EndIf
Return lLibSC9
//-----------------------------------------------------------------//
//--------------Liberação do Pedido de Venda Liberado--------------//
//-----------------------------------------------------------------//
METHOD UpdSitDCV() CLASS WMSDTCMontagemVolume
	DCU->(dbSetOrder(2)) // DCU_FILIAL+DCU_CARGA+DCU_PEDIDO+DCU_CODMNT+DCU_CODVOL
	DCV->(dbSetOrder(1)) // DCV_FILIAL+DCV_CODMNT+DCV_CODVOL+DCV_PRDORI+DCV_CODPRO+DCV_LOTE+DCV_SUBLOT+DCV_ITEM+DCV_SEQUEN
	If DCU->(dbSeek(xFilial('DCU')+Self:cCarga+Self:cPedido+Self:cCodMnt))
		Do While DCU->(!Eof()) .And. DCU->(DCU_FILIAL+DCU_CARGA+DCU_PEDIDO+DCU_CODMNT) == xFilial("DCU")+Self:cCarga+Self:cPedido+Self:cCodMnt
			// Posiciona dcv
			If DCV->(dbSeek(xFilial('DCV')+Self:cCodMnt+DCU->DCU_CODVOL))
				Do While DCV->(!Eof()) .And. DCV->(DCV_FILIAL+DCV_CODMNT+DCV_CODVOL)  == xFilial("DCV")+Self:cCodMnt+DCU->DCU_CODVOL					
					// Desbloqueia os pedidos de venda
					If DCV->DCV_STATUS == "3"
						RecLock('DCV',.F.)
						DCV->DCV_STATUS := "1" // Não liberado
						DCV->(MsUnlock())
					EndIf
					DCV->(dbSkip())
				EndDo
			EndIf
			DCU->(dbSkip())
		EndDo
	EndIf
Return

METHOD UpdLibEst() CLASS WMSDTCMontagemVolume
Local aAreaAnt := GetArea()
	DCS->(dbGoTo(Self:GetRecno()))
	RecLock("DCS",.F.)
	DCS->DCS_LIBEST := Self:GetLibEst()
	DCS->(MsUnlock())
	RestArea(aAreaAnt)
Return Nil
