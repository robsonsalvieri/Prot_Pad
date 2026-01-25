#Include "Totvs.ch"
#Include "WMSBCCConferenciaEntrada.CH"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0002
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0002()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSBCCConferenciaEntrada
Classe de conferência de entrada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCConferenciaEntrada FROM WMSDTCMovimentosServicoArmazem

	METHOD New() CONSTRUCTOR
	METHOD ExecFuncao()
	METHOD SetOrdServ(oOrdServ)
	METHOD VldGeracao()
	METHOD ProcConfEnt()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSBCCConferenciaEntrada
	_Super:New()
Return

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCConferenciaEntrada
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	// Carrega dados endereço origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	// Carrega dados endereço destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
Return

METHOD Destroy() CLASS WMSBCCConferenciaEntrada
	//Mantido para compatibilidade
Return

METHOD VldGeracao() CLASS WMSBCCConferenciaEntrada
Local lRet := .T.
Return lRet

METHOD ExecFuncao() CLASS WMSBCCConferenciaEntrada
Local lRet := .T.

	If Self:VldGeracao()
		lRet := Self:ProcConfEnt()
	Else
		lRet := .F.
	EndIf
Return lRet

METHOD ProcConfEnt() CLASS WMSBCCConferenciaEntrada
Local lRet      := .T.
	// Status movimento
	Self:cStatus := IIf(Self:oMovServic:GetBlqSrv() == "1","2","4")
	Self:nQtdMovto := Self:nQuant
	// Executa todas as Atividades (DC6) da Tarefa (DC5) Atual
	If !Self:AssignD12()
		lRet := .F.
	EndIf
Return lRet
