#INCLUDE 'TOTVS.CH'
#INCLUDE 'WMSDTCBloqueioSaldo.CH'
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0061
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS Embarcador
@since 26/07/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0061()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCBloqueioSaldo
Classe da Capa do Bloqueio de Saldo (D0U)
@author Squad WMS Embarcador
@since 26/07/2017
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCBloqueioSaldo FROM LongNameClass
	// Data	
	DATA cDocto
	DATA cIdDCF
	DATA cOrigem
	DATA dDatInc
	DATA cHorInc
	DATA cTipBlq
	DATA cIdBloq
	DATA cMotivo
	DATA cObserv
	DATA cErro
	DATA nRecno
	DATA nIndex
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0U(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0U()
	METHOD DeleteD0U()
	METHOD ClearData()
	// Setters
	METHOD SetDocto(cDocto)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetIdBlq(cIdBloq)
	METHOD SetOrigem(cOrigem)
	METHOD SetTipBlq(cTipBlq)
	METHOD SetMotivo(cMotivo)
	METHOD SetObserv(cObserv)
	// Getters
	METHOD GetDocto()
	METHOD GetIdDCF()
	METHOD GetOrigem()
	METHOD GetDatInc()
	METHOD GetHorInc()
	METHOD GetTipBlq()
	METHOD GetIdBlq()
	METHOD GetMotivo()
	METHOD GetObserv()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author Squad WMS Embarcador
@since 26/07/2017
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCBloqueioSaldo
	Self:cDocto  := PadR("", TamSx3("D0U_DOCTO")[1])
	Self:cOrigem := PadR("", TamSx3("D0U_ORIGEM")[1])
	Self:cIdBloq := PadR("", TamSx3("D0U_IDBLOQ")[1])
	Self:cMotivo := PadR("", TamSx3("D0U_MOTIVO")[1])
	Self:cObserv := PadR("", TamSx3("D0U_OBSERV")[1])
	Self:cIdDCF  := PadR("", TamSx3("DCF_ID")[1])
	Self:ClearData()
Return
//-----------------------------------------
METHOD ClearData() CLASS WMSDTCBloqueioSaldo
	Self:cDocto  := PadR("", Len(Self:cDocto))
	Self:cOrigem := PadR("", Len(Self:cOrigem))
	Self:cIdBloq := PadR("", Len(Self:cIdBloq))
	Self:cMotivo := PadR("", Len(Self:cMotivo))
	Self:cObserv := PadR("", Len(Self:cObserv))
	Self:cIdDCF  := PadR("", Len(Self:cIdDCF))
	Self:dDatInc := CtoD("")
	Self:cTipBlq := "2"
	Self:cHorInc := ""
	Self:cErro   := ""
	Self:nRecno  := 0
Return
//----------------------------------------
METHOD Destroy() CLASS WMSDTCBloqueioSaldo
	//Mantido para compatibilidade
Return Nil
//----------------------------------------
METHOD GoToD0U(nRecno) CLASS WMSDTCBloqueioSaldo
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCBloqueioSaldo
Local lRet        := .T.
Local aAreaD0U    := D0U->(GetArea())
Local cAliasD0U   := ""
Local cWhere      := ""

Default nIndex := 1

	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0U_FILIAL+D0U_DOCTO
			If Empty(Self:cDocto)
				lRet := .F.
			EndIf
		Case nIndex == 2 //D0U_FILIAL+D0U_IDDCF+D0U_DOCTO+D0U_IDBLOQ
			If Empty(Self:cIdDCF)
				lRet := .F.
			EndIf
		Case nIndex == 3 //D0U_FILIAL+D0U_IDBLOQ+D0U_DOCTO
			If Empty(Self:cIdBloq)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0001 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + " )(D0U))" // Dados para busca não foram informados! 
	Else
		cAliasD0U:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0U
					SELECT D0U.D0U_DOCTO,
							D0U.D0U_IDDCF,
							D0U.D0U_DATINC,
							D0U.D0U_HORINC,
							D0U.D0U_TIPBLQ,
							D0U.D0U_IDBLOQ,
							D0U.D0U_MOTIVO,
							D0U.D0U_OBSERV,
							D0U.D0U_ORIGEM,
							D0U.R_E_C_N_O_ RECNOD0U
					FROM %Table:D0U% D0U
					WHERE D0U.D0U_FILIAL = %xFilial:D0U%
					AND D0U.R_E_C_N_O_ = %Exp:Self:nRecno%
					AND D0U.%NotDel%
				EndSql
			Case nIndex == 1
				cWhere := "%"
				If !Empty(Self:cIdBloq)
					cWhere += " AND D0U.D0U_IDBLOQ = '"+Self:cIdBloq+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0U
					SELECT D0U.D0U_DOCTO,
							D0U.D0U_IDDCF,
							D0U.D0U_DATINC,
							D0U.D0U_HORINC,
							D0U.D0U_TIPBLQ,
							D0U.D0U_IDBLOQ,
							D0U.D0U_MOTIVO,
							D0U.D0U_OBSERV,
							D0U.D0U_ORIGEM,
							D0U.R_E_C_N_O_ RECNOD0U
					 FROM %Table:D0U% D0U
					WHERE D0U.D0U_FILIAL = %xFilial:D0U%
					  AND D0U.D0U_DOCTO = %Exp:Self:cDocto%
					  AND D0U.%NotDel%
					  %Exp:cWhere%
				EndSql
			Case nIndex == 2
				cWhere := "%"
				If !Empty(Self:cDocto)
					cWhere += " AND D0U.D0U_DOCTO = '"+Self:cDocto+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0U
					SELECT D0U.D0U_DOCTO,
							D0U.D0U_IDDCF,
							D0U.D0U_DATINC,
							D0U.D0U_HORINC,
							D0U.D0U_TIPBLQ,
							D0U.D0U_IDBLOQ,
							D0U.D0U_MOTIVO,
							D0U.D0U_OBSERV,
							D0U.D0U_ORIGEM,
							D0U.R_E_C_N_O_ RECNOD0U
					  FROM %Table:D0U% D0U
					 WHERE D0U.D0U_FILIAL = %xFilial:D0U%
					   AND D0U.D0U_IDDCF = %Exp:Self:cIdDCF%
					   AND D0U.%NotDel%
					   %Exp:cWhere%
				EndSql
			Case nIndex == 3
				cWhere := "%"
				If !Empty(Self:cDocto)
					cWhere += " AND D0U.D0U_DOCTO = '"+Self:cDocto+"'"
				EndIf
				cWhere += "%"
				BeginSql Alias cAliasD0U
					SELECT D0U.D0U_DOCTO,
							D0U.D0U_IDDCF,
							D0U.D0U_DATINC,
							D0U.D0U_HORINC,
							D0U.D0U_TIPBLQ,
							D0U.D0U_IDBLOQ,
							D0U.D0U_MOTIVO,
							D0U.D0U_OBSERV,
							D0U.D0U_ORIGEM,
							D0U.R_E_C_N_O_ RECNOD0U
					  FROM %Table:D0U% D0U
					 WHERE D0U.D0U_FILIAL = %xFilial:D0U%
					   AND D0U.D0U_IDBLOQ = %Exp:Self:cIdBloq%
					   AND D0U.%NotDel%
					  %Exp:cWhere%
				EndSql
		EndCase
		TcSetField(cAliasD0U,'D0U_DATINC','D')
		If (lRet := (cAliasD0U)->(!Eof()))
			Self:cDocto  := (cAliasD0U)->D0U_DOCTO
			Self:cIdDCF  := (cAliasD0U)->D0U_IDDCF
			Self:dDatInc := (cAliasD0U)->D0U_DATINC
			Self:cHorInc := (cAliasD0U)->D0U_HORINC
			Self:cTipBlq := (cAliasD0U)->D0U_TIPBLQ
			Self:cIdBloq := (cAliasD0U)->D0U_IDBLOQ
			Self:cMotivo := (cAliasD0U)->D0U_MOTIVO
			Self:cObserv := (cAliasD0U)->D0U_OBSERV
			Self:cOrigem := (cAliasD0U)->D0U_ORIGEM
			Self:nRecno  := (cAliasD0U)->RECNOD0U
		EndIf
		(cAliasD0U)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0U)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetDocto(cDocto) CLASS WMSDTCBloqueioSaldo
	Self:cDocto := PadR(cDocto, Len(Self:cDocto))
Return
METHOD SetIdBlq(cIdBloq) CLASS WMSDTCBloqueioSaldo
	Self:cIdBloq := cIdBloq
Return
//----------------------------------------
METHOD SetOrigem(cOrigem) CLASS WMSDTCBloqueioSaldo
	Self:cOrigem := PadR(cOrigem, Len(Self:cOrigem))
Return
//----------------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCBloqueioSaldo
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return
//----------------------------------------
METHOD SetTipBlq(cTipBlq) CLASS WMSDTCBloqueioSaldo
	Self:cTipBlq := PadR(cTipBlq, Len(Self:cTipBlq))
Return
//----------------------------------------
METHOD SetMotivo(cMotivo) CLASS WMSDTCBloqueioSaldo
	Self:cMotivo := PadR(cMotivo, Len(Self:cMotivo))
Return
//----------------------------------------
METHOD SetObserv(cObserv) CLASS WMSDTCBloqueioSaldo
	Self:cObserv := PadR(cObserv, Len(Self:cObserv))
Return
//----------------------------------------
// Getters
//-----------------------------------
METHOD GetDocto() CLASS WMSDTCBloqueioSaldo
Return Self:cDocto
//----------------------------------------
METHOD GetOrigem() CLASS WMSDTCBloqueioSaldo
Return Self:cOrigem
//----------------------------------------
METHOD GetIdDCF() CLASS WMSDTCBloqueioSaldo
Return Self:cIdDCF
//----------------------------------------
METHOD GetDatInc() CLASS WMSDTCBloqueioSaldo
Return Self:dDatInc
//----------------------------------------
METHOD GetHorInc() CLASS WMSDTCBloqueioSaldo
Return Self:cHorInc
//----------------------------------------
METHOD GetTipBlq() CLASS WMSDTCBloqueioSaldo
Return Self:cTipBlq
//----------------------------------------
METHOD GetIdBlq() CLASS WMSDTCBloqueioSaldo
Return Self:cIdBloq
//----------------------------------------
METHOD GetRecno() CLASS WMSDTCBloqueioSaldo
Return Self:nRecno
//----------------------------------------
METHOD GetErro() CLASS WMSDTCBloqueioSaldo
Return Self:cErro
//----------------------------------------
METHOD GetMotivo() CLASS WMSDTCBloqueioSaldo
Return Self:cMotivo
//----------------------------------------
METHOD GetObserv() CLASS WMSDTCBloqueioSaldo
Return Self:cObserv
//----------------------------------------
METHOD RecordD0U() CLASS WMSDTCBloqueioSaldo
Local aAreaAnt := GetArea()
Local lRet := .T.
Local aRetPE := {}

	If Empty(Self:cIdBloq)
		Self:cIdBloq := ProxNum()
	EndIf
	If ExistBlock("WMSBLSD") // Executado para efetuar a validação do produto digitado
		aRetPE:= ExecBlock('WMSBLSD',.F.,.F.,{Self:cIdDCF,Self:cMotivo,Self:cObserv})
		IF ValType(aRetPE) == "A" .AND. Len(aRetPE) > 0
       		Self:cMotivo := aRetPE[1]
           Self:cObserv :=  aRetPE[2]
		EndIf
    ENDIF

	DbSelectArea("D0U")
	D0U->(DbSetOrder(1)) //D0U_FILIAL+D0U_DOCTO+D0U_IDBLOQ
	If !D0U->(DbSeek(xFilial('D0U')+Self:cDocto+Self:cIdBloq))
		RecLock("D0U", .T.)
		D0U->D0U_FILIAL := xFilial('D0U')
		D0U->D0U_IDBLOQ := Self:cIdBloq 
		D0U->D0U_DOCTO  := Self:cDocto
		D0U->D0U_TIPBLQ := Self:cTipBlq
		D0U->D0U_IDDCF  := Self:cIdDCF
		D0U->D0U_ORIGEM := Self:cOrigem
		D0U->D0U_MOTIVO := Self:cMotivo
		D0U->D0U_OBSERV := Self:cObserv
		D0U->D0U_DATINC := dDataBase
		D0U->D0U_HORINC := Time()
		D0U->(MsUnLock())
		// Grava recno
		Self:nRecno := D0U->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada D0U!
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------
METHOD DeleteD0U() CLASS WMSDTCBloqueioSaldo
Local lRet       := .T.
	If !Empty(Self:GetRecno())
		D0U->(dbGoTo( Self:GetRecno()))
		RecLock('D0U',.F.)
		D0U->(dbDelete())
		D0U->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados (D0U)!
	EndIf
Return lRet
