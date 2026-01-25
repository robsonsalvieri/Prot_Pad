#Include "Totvs.ch"  
#Include "WMSDTCTransferenciaBloqueioSaldo.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0067
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0067()
Return Nil
//--------------------------------------
/*/{Protheus.doc} WMSDTCTransferenciaBloqueioSaldo
Classe Transferência x Bloqueio de Saldo D18
@author amanda.vieira
@since 25/11/2019
@version 1.0
/*/
//--------------------------------------
CLASS WMSDTCTransferenciaBloqueioSaldo FROM LongNameClass
	DATA cIdDCF
	DATA cIdDCFBlq
	DATA cDocto
	DATA cDoctoBlq
	DATA cIdBlq
	DATA cTipBlq
	DATA cMotivo
	DATA cObserv
	DATA cOrigem
	DATA cErro
	DATA nRecno

	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetDocto(cDocto)
	METHOD SetIdBlq(cIdBlq)
	METHOD SetIdDCFBlq(cIdDCFBlq)
	METHOD SetDoctoBlq(cDoctoBlq)
	METHOD SetOrigem(cOrigem)
	METHOD SetTipBlq(cTipBlq)
	METHOD SetMotivo(cMotivo)
	METHOD SetObserv(cObserv)
	METHOD SetRecno(nRecno)
	METHOD ExisteD18()
	METHOD RecordD18()
	METHOD DeleteD18()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS

METHOD New() CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cErro := ""
Return

METHOD Destroy() CLASS WMSDTCTransferenciaBloqueioSaldo
	//Mantido para compatibilidade
Return 

METHOD SetIdDCF(cIdDCF) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cIdDCF := cIdDCF
Return

METHOD SetDocto(cDocto) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cDocto := cDocto
Return

METHOD SetIdBlq(cIdBlq) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cIdBlq := cIdBlq
Return

METHOD SetIdDCFBlq(cIdDCFBlq) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cIdDCFBlq := cIdDCFBlq
Return

METHOD SetDoctoBlq(cDoctoBlq) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cDoctoBlq := cDoctoBlq
Return

METHOD SetOrigem(cOrigem) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cOrigem := cOrigem
Return

METHOD SetTipBlq(cTipBlq) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cTipBlq := cTipBlq
Return

METHOD SetMotivo(cMotivo) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cMotivo := cMotivo
Return

METHOD SetObserv(cObserv) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:cObserv := cObserv
Return

METHOD SetRecno(nRecno) CLASS WMSDTCTransferenciaBloqueioSaldo
	Self:nRecno := nRecno
Return 

METHOD GetErro() CLASS WMSDTCTransferenciaBloqueioSaldo
Return Self:cErro

METHOD LoadData(nIndex) CLASS WMSDTCTransferenciaBloqueioSaldo
Local lRet      := .T.
Local cAliasD18 := ""
Default nIndex  := 1
	Do Case 
		Case nIndex == 1 //D18_FILIAL+D18_IDDCF+D18_IDBLOQ
			If Empty(Self:cIdDCF) .Or.;
			   Empty(Self:cIdBlq)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD18:= GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD18
					SELECT D18.D18_IDDCF,
						   D18.D18_DOCTO,
						   D18.D18_IDBLOQ,
						   D18.D18_TIPBLQ,
						   D18.D18_MOTIVO,
						   D18.D18_OBSERV,
						   D18.D18_DCFBLQ,
						   D18.D18_DOCBLQ,
						   D18.D18_ORIGEM
					FROM %Table:D18% D18
				   WHERE D18.D18_FILIAL = %xFilial:D18%
					 AND D18.D18_IDDCF  = %Exp:Self:cIdDCF%
					 AND D18.D18_IDBLOQ = %Exp:Self:cIdBlq%
					 AND D18.%NotDel%
				EndSql
		EndCase
		If (lRet := (cAliasD18)->(!Eof()))
			Self:cIdDCF    := (cAliasD18)->D18_IDDCF
			Self:cDocto    := (cAliasD18)->D18_DOCTO
			Self:cIdBlq    := (cAliasD18)->D18_IDBLOQ
			Self:cDoctoBlq := (cAliasD18)->D18_DOCBLQ
			Self:cIdDCFBlq := (cAliasD18)->D18_DCFBLQ
			Self:cTipBlq   := (cAliasD18)->D18_TIPBLQ
			Self:cMotivo   := (cAliasD18)->D18_MOTIVO
			Self:cObserv   := (cAliasD18)->D18_OBSERV
		EndIf
		(cAliasD18)->(dbCloseArea())
	EndIf
Return lRet

METHOD ExisteD18() CLASS WMSDTCTransferenciaBloqueioSaldo
Return Self:LoadData(1)

//----------------------------------------
METHOD DeleteD18() CLASS WMSDTCTransferenciaBloqueioSaldo
Local lRet       := .T.
	If !Empty(Self:nRecno)
		D18->(dbGoTo(Self:nRecno))
		RecLock('D18',.F.)
		D18->(dbDelete())
		D18->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Dados não encontrados (D18)!
	EndIf
Return lRet

METHOD RecordD18() CLASS WMSDTCTransferenciaBloqueioSaldo
Local lRet := .T.
	If !Self:ExisteD18()
		RecLock("D18",.T.)
		D18->D18_FILIAL := xFilial("D18")
		D18->D18_IDDCF  := Self:cIdDCF
		D18->D18_DOCTO  := Self:cDocto
		D18->D18_IDBLOQ := Self:cIdBlq
		D18->D18_TIPBLQ := Self:cTipBlq
		D18->D18_MOTIVO := Self:cMotivo
		D18->D18_OBSERV := Self:cObserv
		D18->D18_DOCBLQ := Self:cDoctoBlq
		D18->D18_DCFBLQ := Self:cIdDCFBlq
		D18->D18_ORIGEM := Self:cOrigem
		D18->(MsUnLock())
		Self:nRecno := D18->(Recno())
	EndIf
Return lRet
