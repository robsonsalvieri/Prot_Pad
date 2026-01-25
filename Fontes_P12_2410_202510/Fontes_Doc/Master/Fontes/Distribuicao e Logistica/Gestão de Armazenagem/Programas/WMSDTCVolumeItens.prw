#Include "Totvs.ch"  
#Include "WMSDTCVolumeItens.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0041
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0041()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCVolumeItens
Classe itens do volume
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCVolumeItens FROM LongNameClass
	// Data
	DATA oVolume
	DATA cPrdOri
	DATA cProduto
	DATA cLoteCtl
	DATA cNumLote
	DATA cItem
	DATA cSequen
	DATA cStatus
	DATA nQuant
	DATA dDtInicio
	DATA cHrInicio
	DATA dDtFinal
	DATA cHrFinal
	DATA cCodOpe
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToDCV(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordDCV()
	METHOD UpdateDCV()
	// Setters
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetCodMnt(cCodMnt)
	METHOD SetCodVol(cCodVol) 
	METHOD SetPrdOri(cPrdOri)
	METHOD SetProduto(cProduto)
	METHOD SetLoteCtl(cLoteCtl)
	METHOD SetNumLote(cNumLote)
	METHOD SetStatus(cStatus)
	METHOD SetItem(cItem)
	METHOD SetSequen(cSequen)
	METHOD SetQuant(nQuant)
	METHOD SetCodOpe(cCodOpe)
	METHOD SetDtIni(dDtInicio)
	METHOD SetHrIni(cHrInicio)
	// Getters
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetCodMnt()
	METHOD GetCodVol()
	METHOD GetPrdOri()
	METHOD GetProduto()
	METHOD GetLoteCtl()
	METHOD GetNumLote()
	METHOD GetStatus()
	METHOD GetItem()
	METHOD GetSequen()
	METHOD GetQuant()
	METHOD GetCodOpe()
	METHOD GetRecno()
	METHOD GetErro()
	// Metodo
	METHOD AssignDCV()
	METHOD Destroy()
	METHOD GetQtSeqLib()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author alexsander.correa
@since 27/02/2015
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCVolumeItens
	Self:oVolume   := WMSDTCVolume():New()
	Self:cPrdOri   := PadR("", TamSx3("DCV_PRDORI")[1])
	Self:cProduto  := PadR("", TamSx3("DCV_CODPRO")[1])
	Self:cLoteCtl  := PadR("", TamSx3("DCV_LOTE")[1])
	Self:cNumLote  := PadR("", TamSx3("DCV_SUBLOT")[1])
	Self:cItem     := PadR("", TamSx3("DCV_ITEM")[1])
	Self:cSequen   := PadR("", TamSx3("DCV_SEQUEN")[1])
	Self:cCodOpe   := __cUserID
	Self:cStatus   := "1"
	Self:nQuant    := 0
	Self:dDtInicio := dDataBase
	Self:cHrInicio := Time()
	Self:dDtFinal  := CtoD("  /  /    ")
	Self:cHrFinal  := PadR("", Len(Self:cHrInicio))
	Self:nRecno    := 0
	Self:cErro     := ""
Return

METHOD Destroy() CLASS WMSDTCVolumeItens
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
METHOD GoToDCV(nRecno) CLASS WMSDTCVolumeItens
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DCv
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCVolumeItens
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local aDCV_QUANT:= TamSx3("DCV_QUANT")
Local aAreaDCV  := DCV->(GetArea())
Local cAliasDCV := Nil
Default nIndex  := 5
	Do Case
		Case nIndex == 0 // DCV.R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 4 // DCV_FILIAL+DCV_CODVOL+DCV_CODMNT
			If Empty(Self:GetCodVol())
				lRet := .F.
			EndIf
		Case nIndex == 5 //DCV_FILIAL+DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI
			If Empty(Self:GetPedido()) .Or. Empty(Self:GetItem()) .Or. Empty(Self:GetSequen()) .Or. Empty(Self:GetPrdOri())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0002 // Dados para busca não foram informados!
	Else
		cAliasDCV := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasDCV
					SELECT DCV.DCV_CODMNT,
							DCV.DCV_CARGA,
							DCV.DCV_PEDIDO,
							DCV.DCV_ITEM,
							DCV.DCV_SEQUEN,
							DCV.DCV_CODVOL,
							DCV.DCV_PRDORI,
							DCV.DCV_CODPRO,
							DCV.DCV_LOTE,
							DCV.DCV_SUBLOT,
							DCV.DCV_STATUS,
							DCV.DCV_QUANT,
							DCV.DCV_CODOPE,
							DCV.DCV_DATINI,
							DCV.DCV_HORINI,
							DCV.DCV_DATFIM,
							DCV.DCV_HORFIM,
							DCV.R_E_C_N_O_ RECNODCV
					FROM %table:DCV% DCV
					WHERE DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND DCV.%NotDel%
				EndSql
			Case nIndex == 4
				BeginSql Alias cAliasDCV
					SELECT DCV.DCV_CODMNT,
							DCV.DCV_CARGA,
							DCV.DCV_PEDIDO,
							DCV.DCV_ITEM,
							DCV.DCV_SEQUEN,
							DCV.DCV_CODVOL,
							DCV.DCV_PRDORI,
							DCV.DCV_CODPRO,
							DCV.DCV_LOTE,
							DCV.DCV_SUBLOT,
							DCV.DCV_STATUS,
							DCV.DCV_QUANT,
							DCV.DCV_CODOPE,
							DCV.DCV_DATINI,
							DCV.DCV_HORINI,
							DCV.DCV_DATFIM,
							DCV.DCV_HORFIM,
							DCV.R_E_C_N_O_ RECNODCV
					FROM %table:DCV% DCV
					WHERE DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.DCV_CODVOL = %Exp:Self:GetCodVol()%
					AND DCV.%NotDel%
				EndSql
			Case nIndex == 5
				BeginSql Alias cAliasDCV
					SELECT DCV.DCV_CODMNT,
							DCV.DCV_CARGA,
							DCV.DCV_PEDIDO,
							DCV.DCV_ITEM,
							DCV.DCV_SEQUEN,
							DCV.DCV_CODVOL,
							DCV.DCV_PRDORI,
							DCV.DCV_CODPRO,
							DCV.DCV_LOTE,
							DCV.DCV_SUBLOT,
							DCV.DCV_STATUS,
							DCV.DCV_QUANT,
							DCV.DCV_CODOPE,
							DCV.DCV_DATINI,
							DCV.DCV_HORINI,
							DCV.DCV_DATFIM,
							DCV.DCV_HORFIM,
							DCV.R_E_C_N_O_ RECNODCV
					FROM %table:DCV% DCV
					WHERE DCV.DCV_FILIAL = %xFilial:DCV%
					AND DCV.DCV_PEDIDO = %Exp:Self:GetPedido()%
					AND DCV.DCV_ITEM = %Exp:Self:GetItem()%
					AND DCV.DCV_SEQUEN = %Exp:Self:GetSequen()%
					AND DCV.DCV_PRDORI = %Exp:Self:GetPrdOri()%
					AND DCV.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasDCV,'DCV_QUANT','N',aDCV_QUANT[1],aDCV_QUANT[2])
		TcSetField(cAliasDCV,'DCV_DATINI','D')
		TcSetField(cAliasDCV,'DCV_DATFIM','D')
		If (lRet := (cAliasDCV)->(!Eof()))
			// Dados Gerais
			Self:SetCodMnt((cAliasDCV)->DCV_CODMNT)
			Self:SetCodVol((cAliasDCV)->DCV_CODVOL)
			Self:SetCarga((cAliasDCV)->DCV_CARGA)
			Self:SetPedido((cAliasDCV)->DCV_PEDIDO)
			Self:SetItem((cAliasDCV)->DCV_ITEM)
			Self:SetSequen((cAliasDCV)->DCV_SEQUEN)
			// Montagem
			Self:oVolume:LoadData()
			// Busca dados lote/produto
			Self:SetPrdOri((cAliasDCV)->DCV_PRDORI)
			Self:SetProduto((cAliasDCV)->DCV_CODPRO)
			Self:SetLoteCtl((cAliasDCV)->DCV_LOTE)
			Self:SetNumLote((cAliasDCV)->DCV_SUBLOT)
			// Busca dados endereco origem
			// Dados complementares
			Self:cStatus  := (cAliasDCV)->DCV_STATUS
			Self:nQuant   := (cAliasDCV)->DCV_QUANT
			Self:cCodOpe  := (cAliasDCV)->DCV_CODOPE
			Self:dDtInicio:= (cAliasDCV)->DCV_DATINI
			Self:cHrInicio:= (cAliasDCV)->DCV_HORINI
			Self:dDtFinal := (cAliasDCV)->DCV_DATFIM
			Self:cHrFinal := (cAliasDCV)->DCV_HORFIM
			Self:nRecno   := (cAliasDCV)->RECNODCV
		EndIf
		(cAliasDCV)->(dbCloseArea())
	EndIf	
	RestArea(aAreaDCV)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCVolumeItens
	Self:oVolume:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCVolumeItens
	Self:oVolume:SetPedido(cPedido)
Return

METHOD SetCodMnt(cCodMnt) CLASS WMSDTCVolumeItens
	Self:oVolume:SetCodMnt(cCodMnt)
Return

METHOD SetCodVol(cVolume) CLASS WMSDTCVolumeItens
	Self:oVolume:SetCodVol(cVolume)
Return

METHOD SetPrdOri(cPrdOri) CLASS WMSDTCVolumeItens
	Self:cPrdOri := PadR(cPrdOri, Len(Self:cPrdOri))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCVolumeItens
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return

METHOD SetLoteCtl(cLoteCtl) CLASS WMSDTCVolumeItens
	Self:cLoteCtl := PadR(cLoteCtl, Len(Self:cLoteCtl))
Return

METHOD SetNumLote(cNumLote) CLASS WMSDTCVolumeItens
	Self:cNumLote := PadR(cNumLote, Len(Self:cNumLote))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCVolumeItens
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetItem(cItem) CLASS WMSDTCVolumeItens
	Self:cItem := PadR(cItem, Len(Self:cItem))
Return

METHOD SetSequen(cSequen) CLASS WMSDTCVolumeItens
	Self:cSequen := PadR(cSequen, Len(Self:cSequen))
Return

METHOD SetQuant(nQuant) CLASS WMSDTCVolumeItens
	Self:nQuant := nQuant
Return

METHOD SetCodOpe(cCodOpe) CLASS WMSDTCVolumeItens
	Self:cCodOpe := PadR(cCodOpe, Len(Self:cCodOpe))
Return

METHOD SetDtIni(dDtInicio) CLASS WMSDTCVolumeItens
	Self:dDtInicio := dDtInicio
Return

METHOD SetHrIni(cHrInicio) CLASS WMSDTCVolumeItens
	Self:cHrInicio := PadR(cHrInicio, Len(Self:cHrInicio))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCVolumeItens
Return Self:oVolume:GetCarga()

METHOD GetPedido() CLASS WMSDTCVolumeItens	
Return Self:oVolume:GetPedido()

METHOD GetCodMnt() CLASS WMSDTCVolumeItens
Return Self:oVolume:GetCodMnt()

METHOD GetCodVol() CLASS WMSDTCVolumeItens
Return Self:oVolume:GetCodVol()

METHOD GetPrdOri() CLASS WMSDTCVolumeItens
Return Self:cPrdOri

METHOD GetProduto() CLASS WMSDTCVolumeItens
Return Self:cProduto

METHOD GetLoteCtl() CLASS WMSDTCVolumeItens
Return Self:cLoteCtl

METHOD GetNumLote() CLASS WMSDTCVolumeItens
Return Self:cNumLote

METHOD GetStatus() CLASS WMSDTCVolumeItens
Return Self:cStatus

METHOD GetItem() CLASS WMSDTCVolumeItens
Return Self:cItem

METHOD GetSequen() CLASS WMSDTCVolumeItens
Return Self:cSequen

METHOD GetQuant() CLASS WMSDTCVolumeItens
Return  Self:nQuant

METHOD GetCodOpe() CLASS WMSDTCVolumeItens
Return Self:cCodOpe

METHOD GetRecno() CLASS WMSDTCVolumeItens
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCVolumeItens
Return Self:cErro

METHOD AssignDCV() CLASS WMSDTCVolumeItens
Local lRet := .T.
	// Criar um volume DCU caso não exista
	Self:SetCodMnt(Self:GetCodMnt())
	If !Self:oVolume:RecordDCU()
		lRet := .F.
		Self:cErro := Self:oVolume:GetErro()
	EndIf
	
	// Seta as informações para a criação da DCV
	If lRet
		If !Self:RecordDCV()
			lRet := .F.
		EndIf
	EndIf

Return lRet

METHOD RecordDCV() CLASS WMSDTCVolumeItens
Local lRet   := .T.
Local lAchou := .F.
	DbSelectArea("DCV")
	DCV->(DbSetOrder(1)) // DCV_FILIAL+DCV_CODVOL+DCV_PRDORI+DCV_CODPRO+DCV_LOTE+DCV_SUBLOT+DCV_ITEM+DCV_SEQUEN+DCV_CODMNT
	lAchou := DCV->(dbSeek(xFilial("DCV")+Self:GetCodMnt()+Self:GetCodVol()+Self:cPrdOri+Self:cProduto+Self:cLoteCtl+Self:cNumLote+Self:cItem+Self:cSequen))
	Reclock('DCV',!lAchou)
	If !lAchou
		DCV->DCV_Filial := xFilial("DCT")
		DCV->DCV_CODVOL := Self:GetCodVol()
		DCV->DCV_CODMNT := Self:GetCodMnt()
		DCV->DCV_CARGA  := Self:GetCarga()
		DCV->DCV_PEDIDO := Self:GetPedido()
		DCV->DCV_STATUS := Self:cStatus
		DCV->DCV_PRDORI := Self:cPrdOri
		DCV->DCV_CODPRO := Self:cProduto
		DCV->DCV_LOTE   := Self:cLoteCtl
		DCV->DCV_SUBLOT := Self:cNumLote
		DCV->DCV_QUANT  := Self:nQuant
		DCV->DCV_CODOPE := Self:cCodOpe
		DCV->DCV_ITEM   := Self:cItem
		DCV->DCV_SEQUEN := Self:cSequen
		DCV->DCV_DATINI := Self:dDtInicio
		DCV->DCV_HORINI := Self:cHrInicio
		DCV->DCV_DATFIM := dDataBase
		DCV->DCV_HORFIM := Time()
	Else
		DCV->DCV_STATUS := Self:cStatus
		DCV->DCV_DATFIM := dDataBase
		DCV->DCV_HORFIM := Time()
		DCV->DCV_QUANT  += Self:nQuant
	EndIf
	DCV->(MsUnLock())	
Return lRet

METHOD UpdateDCV() CLASS WMSDTCVolumeItens
Local lRet   := .T.
	If !Empty(Self:GetRecno())
		DCV->(dbGoTo( Self:GetRecno() ))
		If Self:cStatus == "2"
			Self:cStatus := "1"
		EndIf
		// Grava DCV
		RecLock('DCV', .F.)
		DCV->DCV_STATUS := Self:cStatus
		DCV->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf		
Return lRet

METHOD GetQtSeqLib() CLASS WMSDTCVolumeItens
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
Local nQtSeqLib := 0
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT MIN(DCV.DCV_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1 ELSE D11.D11_QTMULT END) DCV_QUANT
		FROM %Table:DCV% DCV
		LEFT JOIN %Table:D11% D11
		ON D11.D11_FILIAL = %xFilial:D11%
		AND DCV.DCV_FILIAL = %xFilial:DCV%
		AND D11.D11_PRODUT = DCV.DCV_PRDORI
		AND D11.D11_PRDORI = DCV.DCV_PRDORI
		AND D11.D11_PRDCMP = DCV.DCV_CODPRO
		AND D11.%NotDel%
		WHERE DCV.DCV_FILIAL = %xFilial:DCV%
		AND DCV.DCV_PEDIDO = %Exp:Self:GetPedido()%
		AND DCV.DCV_ITEM = %Exp:Self:GetItem()%
		AND DCV.DCV_SEQUEN = %Exp:Self:GetSequen()%
		AND DCV.DCV_PRDORI = %Exp:Self:GetPrdOri()%
		AND DCV.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		nQtSeqLib := (cAliasQry)->DCV_QUANT
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return nQtSeqLib
