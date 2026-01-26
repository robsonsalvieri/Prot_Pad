#Include 'Totvs.ch' 
#Include 'WMSDTCVolume.ch'

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0046
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0046()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCVolume
Classe volume
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCVolume FROM LongNameClass
	// Data
	DATA oMntVol
	DATA cCodVol
	DATA cPedido
	DATA cImpVol
	DATA cRomEmb
	DATA dDtInicio
	DATA cHrInicio
	DATA dDtFinal
	DATA cHrFinal
	DATA cTmpMovto
	DATA cStConf
	DATA cCodOpe
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD RecordDCU()
	METHOD ExcludeDCU()
	// Setters
	METHOD SetCodMnt(cCodMnt)
	METHOD SetCarga(cCarga)
	METHOD SetPedido(cPedido)
	METHOD SetCodVol(cCodVol)
	METHOD SetDtIni(dDtInicio)
	METHOD SetHrIni(cHrInicio)
	METHOD SetDtFim(dDtFinal)
	METHOD SetHrFim(cHrFinal)
	METHOD SetImpVol(cImpVol)
	METHOD SetStConf(cStConf)
	METHOD SetCodOpe(cCodOpe)
	// Getters
	METHOD GetCodMnt()
	METHOD GetCarga()
	METHOD GetPedido()
	METHOD GetCodVol()
	METHOD GetStConf()
	METHOD GetMntExc()
	METHOD GetCodOpe()
	METHOD GetRecno()
	METHOD GetErro()
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
METHOD New() CLASS WMSDTCVolume
	Self:oMntVol    := WMSDTCMontagemVolume():New()
	Self:cCodVol    := PadR("", TamSx3("DCU_CODVOL")[1])
	Self:dDtInicio  := dDataBase
	Self:cHrInicio  := Time()
	Self:dDtFinal   := StoD("")
	Self:cHrFinal   := PadR("", Len(Self:cHrInicio))
	Self:cTmpMovto  := ""
	Self:cStConf    := "1"
	Self:cCodOpe    := __cUserID
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCVolume
	//Mantido para compatibilidade
Return Nil

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados DCU
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCVolume
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aAreaDCU := DCU->(GetArea())
Local cAliasDCU:= Nil

Default nIndex := 2

	Do Case
		Case nIndex == 1 // DCU_FILIAL+DCU_CODVOL
			If Empty(Self:GetCodMnt()) .Or. Empty(Self:GetCodVol())
				lRet := .F.
			EndIf
		Case nIndex == 2 // DCU_FILIAL+DCU_CODMNT+DCU_CARGA+DCU_PEDIDO+DCU_CODVOL
			If Empty(Self:GetCodMnt()) .Or. Empty(Self:GetPedido()) .Or. Empty(Self:cCodVol)
				lRet := .F.
			EndIf
			
		Case nIndex == 3 // DCU_FILIAL+DCT_CODMNT+DCU_CARGA+DCU_PEDIDO
			If Empty(Self:GetCodMnt()) .Or. Empty(Self:GetPedido())
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasDCU:= GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasDCU
					SELECT DCU.DCU_CODMNT,
							DCU.DCU_CARGA,
							DCU.DCU_PEDIDO,
							DCU.DCU_CODVOL,
							DCU.DCU_DATINI,
							DCU.DCU_HORINI,
							DCU.DCU_DATFIM,
							DCU.DCU_HORFIM,
							DCU.DCU_IMPETI,
							DCU.DCU_ROMEMB,
							DCU.DCU_STCONF,
							DCU.R_E_C_N_O_ RECNODCU
					FROM %Table:DCU% DCU	
					WHERE DCU.DCU_FILIAL = %xFilial:DCU%
					AND DCU.DCU_CODVOL = %Exp:Self:cCodVol%
					AND DCU.DCU_CODMNT = %Exp:Self:GetCodMnt()%
					AND DCU.%NotDel%
				EndSql
			Case nIndex == 2
				If !Empty(Self:GetCarga()) .And. WmsCarga(Self:GetCarga())
					BeginSql Alias cAliasDCU
						SELECT DCU.DCU_CODMNT,
								DCU.DCU_CARGA,
								DCU.DCU_PEDIDO,
								DCU.DCU_CODVOL,
								DCU.DCU_DATINI,
								DCU.DCU_HORINI,
								DCU.DCU_DATFIM,
								DCU.DCU_HORFIM,
								DCU.DCU_IMPETI,
								DCU.DCU_ROMEMB,
								DCU.DCU_STCONF,
								DCU.R_E_C_N_O_ RECNODCU
						FROM %Table:DCU% DCU	
						WHERE DCU.DCU_FILIAL = %xFilial:DCU%
						AND DCU.DCU_CARGA = %Exp:Self:GetCarga()%
						AND DCU.DCU_PEDIDO = %Exp:Self:GetPedido()%
						AND DCU.DCU_CODMNT = %Exp:Self:GetCodMnt()%
						AND DCU.DCU_CODVOL = %Exp:Self:cCodVol%
						AND DCU.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasDCU
						SELECT DCU.DCU_CODMNT,
								DCU.DCU_CARGA,
								DCU.DCU_PEDIDO,
								DCU.DCU_CODVOL,
								DCU.DCU_DATINI,
								DCU.DCU_HORINI,
								DCU.DCU_DATFIM,
								DCU.DCU_HORFIM,
								DCU.DCU_IMPETI,
								DCU.DCU_ROMEMB,
								DCU.DCU_STCONF,
								DCU.R_E_C_N_O_ RECNODCU
						FROM %Table:DCU% DCU	
						WHERE DCU.DCU_FILIAL = %xFilial:DCU%
						AND DCU.DCU_PEDIDO = %Exp:Self:GetPedido()%
						AND DCU.DCU_CODMNT = %Exp:Self:GetCodMnt()%
						AND DCU.DCU_CODVOL = %Exp:Self:cCodVol%
						AND DCU.%NotDel%
					EndSql
				EndIf
		EndCase
		TcSetField(cAliasDCU,'DCU_DATINI','D')
		TcSetField(cAliasDCU,'DCU_DATFIM','D')
		lRet := (cAliasDCU)->(!Eof())
		If lRet
			// Dados Gerais
			Self:SetCodMnt((cAliasDCU)->DCU_CODMNT)
			Self:SetCarga((cAliasDCU)->DCU_CARGA)
			Self:SetPedido((cAliasDCU)->DCU_PEDIDO)
			Self:oMntVol:LoadData()
			Self:cCodVol   := (cAliasDCU)->DCU_CODVOL
			// Busca dados lote/produto
			Self:dDtInicio := (cAliasDCU)->DCU_DATINI
			Self:cHrInicio := (cAliasDCU)->DCU_HORINI
			Self:dDtFinal  := (cAliasDCU)->DCU_DATFIM
			Self:cHrFinal  := (cAliasDCU)->DCU_HORFIM
			Self:cImpVol   := (cAliasDCU)->DCU_IMPETI
			Self:cRomEmb   := (cAliasDCU)->DCU_ROMEMB
			Self:cStConf   := (cAliasDCU)->DCU_STCONF
			Self:nRecno    := (cAliasDCU)->RECNODCU
		EndIf
		(cAliasDCU)->(dbCloseArea())
	EndIf
	RestArea(aAreaDCU)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCarga(cCarga) CLASS WMSDTCVolume
	Self:oMntVol:SetCarga(cCarga)
Return

METHOD SetPedido(cPedido) CLASS WMSDTCVolume
	Self:oMntVol:SetPedido(cPedido)
Return

METHOD SetCodMnt(cCodMnt) CLASS WMSDTCVolume
	Self:oMntVol:SetCodMnt(cCodMnt)
Return

METHOD SetCodVol(cCodVol) CLASS WMSDTCVolume
	Self:cCodVol := PadR(cCodVol, Len(Self:cCodVol))
Return

METHOD SetDtIni(dDtInicio) CLASS WMSDTCVolume
	Self:dDtInicio := dDtInicio
Return

METHOD SetHrIni(cHrInicio) CLASS WMSDTCVolume
	Self:cHrInicio := PadR(cHrInicio, Len(Self:cHrInicio))
Return

METHOD SetDtFim(dDtFinal) CLASS WMSDTCVolume
	Self:dDtFinal := dDtFinal
Return

METHOD SetHrFim(cHrFinal) CLASS WMSDTCVolume
	Self:cHrFinal := PadR(cHrFinal, Len(Self:cHrFinal))
Return

METHOD SetStConf(cStConf) CLASS WMSDTCVolume
	Self:cStConf := cStConf
Return

METHOD SetCodOpe(cCodOpe) CLASS WMSDTCVolume
	Self:cCodOpe := PadR(cCodOpe, Len(Self:cCodOpe))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCarga() CLASS WMSDTCVolume
Return Self:oMntVol:GetCarga()

METHOD GetPedido() CLASS WMSDTCVolume
Return Self:oMntVol:GetPedido()

METHOD GetCodMnt() CLASS WMSDTCVolume
Return Self:oMntVol:GetCodMnt()

METHOD GetCodVol() CLASS WMSDTCVolume
Return Self:cCodVol

METHOD GetErro() CLASS WMSDTCVolume
Return Self:cErro

METHOD GetStConf() CLASS WMSDTCVolume
Return Self:cStConf

METHOD GetMntExc() CLASS WMSDTCVolume
Return Self:oMntVol:GetMntExc()

METHOD GetCodOpe() CLASS WMSDTCVolume
Return Self:cCodOpe

METHOD RecordDCU() CLASS WMSDTCVolume
Local lRet := .T.
Local lAchou := .F.
	If Empty(Self:cCodVol)
		Self:cCodVol := Padl(CBProxCod('MV_WMSNVOL'),TamSx3("DCU_CODVOL")[1],'0')
	EndIf
	
	// Grava DCF
	DCU->(dbSetOrder(2))
	lAchou := DCU->(dbSeek(xFilial("DCU")+Self:GetCarga()+Self:GetPedido()+Self:GetCodMnt()+Self:cCodVol))
	Reclock('DCU',!lAchou)
	If !lAchou
		DCU->DCU_FILIAL := xFilial("DCU")
		DCU->DCU_CODMNT := Self:oMntVol:GetCodMnt()
		DCU->DCU_CARGA  := Self:oMntVol:GetCarga()
		DCU->DCU_PEDIDO := Self:oMntVol:GetPedido()
		DCU->DCU_CODVOL := Self:cCodVol
		DCU->DCU_STCONF := Self:cStConf
		DCU->DCU_DATINI := Self:dDtInicio
		DCU->DCU_HORINI := Self:cHrInicio
		DCU->DCU_DATFIM := Iif(Empty(Self:dDtFinal),dDataBase,Self:dDtInicio)
		DCU->DCU_HORFIM := Iif(Empty(Self:cHrFinal),Time(),Self:cHrFinal)
		DCU->DCU_OPERAD := Iif(Empty(Self:cCodOpe),__cUserID,Self:cCodOpe)
		// Grava recno
		Self:nRecno := DCU->(Recno())
	Else
		DCU->DCU_DATFIM := Iif(Empty(Self:dDtFinal),dDataBase,Self:dDtInicio)
		DCU->DCU_HORFIM := Iif(Empty(Self:cHrFinal),Time(),Self:cHrFinal)
	EndIf
	DCU->(MsUnLock())
Return lRet

METHOD ExcludeDCU() CLASS WMSDTCVolume
Local lRet := .T.
	DCU->(dbGoTo( Self:GetRecno() ))
	// Excluindo a ordem de serviço
	RecLock('DCU', .F.)
	DCU->(DbDelete())
	DCU->(MsUnlock())
Return lRet
