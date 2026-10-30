#INCLUDE 'TOTVS.CH'
#INCLUDE "WMSDTCEtiquetaUnitizador.CH"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0059
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS Embarcador
@since 17/04/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0060()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCEtiquetaUnitizador
Classe Unitizador Armazenagem
@author Squad WMS Embarcador
@since 17/04/2017
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCEtiquetaUnitizador FROM LongNameClass
	// Data
	DATA cIdUnit
	DATA cTipUni
	DATA dDatGer
	DATA cHorGer
	DATA cUsuario
	DATA cTipGer
	DATA cUsado
	DATA cImpresso
	DATA IsUsed
	DATA IsPrinted
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0Y(nRecno)
	METHOD LoadData(nIndex)
	METHOD LockD0Y()
	METHOD UnLockD0Y()
	METHOD RecordD0Y()
	METHOD UpdateD0Y(lMsUnLock)
	// Setters
	METHOD SetIdUnit(cIdUnit)
	METHOD SetTipUni(cTipUni)
	METHOD SetDatGer(dDatGer)
	METHOD SetHorGer(cHorGer)
	METHOD SetUsuario(cUsuario)
	METHOD SetTipGer(cTipGer)
	METHOD SetUsado(cUsado)
	METHOD SetImpresso(cImpresso)
	// Getters
	METHOD GetIdUnit(cIdUnit)
	METHOD GetTipUni(cTipUni)
	METHOD GetDatGer(dDatGer)
	METHOD GetHorGer(cHorGer)
	METHOD GetUsuario(cUsuario)
	METHOD GetTipGer(cTipGer)
	METHOD GetUsado(cUsado)
	METHOD GetImpresso(cImpresso)
	METHOD GetIsUsed()
	METHOD GetIsPrinted()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 03/04/2017
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCEtiquetaUnitizador
	Self:cIdUnit    := PadR("", TamSx3("D0Y_IDUNIT")[1])
	Self:cTipUni    := PadR("", TamSx3("D0Y_TIPUNI")[1])
	Self:dDatGer    := CtoD("")
	Self:cHorGer    := PadR("", TamSx3("D0Y_HORGER")[1])
	Self:cUsuario   := PadR("", TamSx3("D0Y_USUARI")[1])
	Self:cTipGer    := PadR("", TamSx3("D0Y_TIPGER")[1])
	Self:cUsado     := "2"
	Self:cImpresso  := "2"
	Self:IsUsed     := .F.
	Self:IsPrinted  := .F.
	Self:nRecno     := 0
	Self:cErro      := ""
Return
//----------------------------------------
METHOD Destroy() CLASS WMSDTCEtiquetaUnitizador
	//Mantido para compatibilidade
Return Nil

//----------------------------------------
METHOD GoToD0Y(nRecno) CLASS WMSDTCEtiquetaUnitizador
	Self:nRecno := nRecno
Return Self:LoadData(0)
//----------------------------------------
/*/{Protheus.doc} LockD0Y
Prende a tabela para alteração D0Y
@author SQUAD WMS
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD LockD0Y() CLASS WMSDTCEtiquetaUnitizador
Local lRet := .F.
Local nEspera := 1
	While nEspera <= 2 
	   If D0Y->(SimpleLock())
	      Self:cErro := "" 
	      lRet := .T. 
		  Exit
	   Else 
			Sleep(1000)
			Self:cErro :=  STR0003 // "Etiqueta em atualização com outro registro. Tente novamente!"
	    	nEspera := nEspera + 1
	   ENDiF 
	EndDo
Return lRet
//----------------------------------------
/*/{Protheus.doc} UnLockD0Y
Libera a tabela para alteração D0Y
@author SQUAD WMS
@since 28/06/2017
@version 1.0
/*/
//----------------------------------------
METHOD UnLockD0Y() CLASS WMSDTCEtiquetaUnitizador
	D0Y->(dbGoTo(Self:nRecno))
Return D0Y->(MsUnlock())
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0Y
@author felipe.m
@since 17/04/2017
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCEtiquetaUnitizador
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD0Y    := D0Y->(GetArea())
Local cAliasD0Y   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0Y_FILIAL+D0Y_IDUNIT
			If Empty(Self:GetIdUnit())
				lRet := .F.
			EndIf

		Otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0001 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + " )(D0Y))" // Dados para busca não foram informados! 
	Else
		cAliasD0Y:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0Y
					SELECT D0Y.D0Y_IDUNIT,
							D0Y.D0Y_TIPUNI,
							D0Y.D0Y_DATGER,
							D0Y.D0Y_HORGER,
							D0Y.D0Y_TIPGER,
							D0Y.D0Y_USUARI,
							D0Y.D0Y_USADO,
							D0Y.D0Y_IMPRES,
							D0Y.R_E_C_N_O_ RECNOD0Y
					FROM %Table:D0Y% D0Y
					WHERE D0Y.D0Y_FILIAL = %xFilial:D0Y%
					AND D0Y.R_E_C_N_O_ = %Exp:Self:nRecno%
					AND D0Y.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0Y
					SELECT D0Y.D0Y_IDUNIT,
							D0Y.D0Y_TIPUNI,
							D0Y.D0Y_DATGER,
							D0Y.D0Y_HORGER,
							D0Y.D0Y_TIPGER,
							D0Y.D0Y_USUARI,
							D0Y.D0Y_USADO,
							D0Y.D0Y_IMPRES,
							D0Y.R_E_C_N_O_ RECNOD0Y
					FROM %Table:D0Y% D0Y
					WHERE D0Y.D0Y_FILIAL = %xFilial:D0Y%
					AND D0Y.D0Y_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D0Y.%NotDel%
				EndSql
		EndCase
		TcSetField(cAliasD0Y,'D0Y_DATGER','D')
		If (lRet := (cAliasD0Y)->(!Eof()))
			Self:cTipUni   := (cAliasD0Y)->D0Y_TIPUNI
			Self:dDatGer   := (cAliasD0Y)->D0Y_DATGER
			Self:cHorGer   := (cAliasD0Y)->D0Y_HORGER
			Self:cTipGer   := (cAliasD0Y)->D0Y_TIPGER
			Self:cUsuario  := (cAliasD0Y)->D0Y_USUARI
			Self:cUsado    := (cAliasD0Y)->D0Y_USADO
			Self:cImpresso := (cAliasD0Y)->D0Y_IMPRES
			Self:nRecno  := (cAliasD0Y)->RECNOD0Y
		EndIf
		(cAliasD0Y)->(dbCloseArea())
		If !lRet
			Self:cErro := WmsFmtMsg(STR0004,{{"[VAR01]",Self:cIdUnit}}) // Etiqueta do unitizador [VAR01] não gerada!
		EndIf
	EndIf
	RestArea(aAreaD0Y)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD0Y() CLASS WMSDTCEtiquetaUnitizador
Local lRet := .T.
Local aAreaD0Y := D0Y->(GetArea())
	If !D0Y->(DbSeek(xFilial('D0Y')+Self:cIdUnit))
		RecLock("D0Y",.T.)
		D0Y->D0Y_FILIAL := xFilial("D0Y")
		D0Y->D0Y_IDUNIT := Self:cIdUnit
		D0Y->D0Y_TIPUNI := Self:cTipUni
		D0Y->D0Y_DATGER := dDataBase
		D0Y->D0Y_HORGER := Time()
		D0Y->D0Y_USUARI := __cUserID
		D0Y->D0Y_TIPGER := Self:cTipGer   // 1=Manual;2=Automatica
		D0Y->D0Y_USADO  := Self:cUsado    // 1=Sim;2=Nao
		D0Y->D0Y_IMPRES := Self:cImpresso // 1=Sim;2=Nao
		D0Y->(MsUnlock())
	Else
		lRet := .F.
		Self:cErro := "Chave duplicada D0Y!" // Chave duplicada D0Y!
	EndIf
	RestArea(aAreaD0Y)
Return lRet

METHOD UpdateD0Y(lMsUnLock) CLASS WMSDTCEtiquetaUnitizador
Local lRet := .T.

Default lMsUnLock := .T.
	If !Empty(Self:GetRecno())
		D0Y->(dbGoTo( Self:GetRecno() ))
		// Grava D0Y
		RecLock('D0Y', .F.)
		D0Y->D0Y_USADO  := Self:cUsado
		D0Y->D0Y_TIPUNI := Self:cTipUni 
		D0Y->(dbCommit()) // Para forçar atualização do banco
		If lMsUnLock
			D0Y->(MsUnLock())
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0002 + " (" + GetClassName(Self) + ":UpdateD0Y()(D0Y))" // Recno inválido!
	EndIf
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetIdUnit(cIdUnit) CLASS WMSDTCEtiquetaUnitizador
	Self:cIdUnit := PadR(cIdUnit, Len(Self:cIdUnit))
Return
//----------------------------------------
METHOD SetTipUni(cTipUni) CLASS WMSDTCEtiquetaUnitizador
	Self:cTipUni := PadR(cTipUni, Len(Self:cTipUni))
Return
//----------------------------------------
METHOD SetTipGer(cTipGer) CLASS WMSDTCEtiquetaUnitizador
	Self:cTipGer := PadR(cTipGer, Len(Self:cTipGer))
Return

METHOD SetUsado(cUsado) CLASS WMSDTCEtiquetaUnitizador
	Self:cUsado := PadR(cUsado, Len(Self:cUsado))
Return

METHOD SetImpresso(cImpresso) CLASS WMSDTCEtiquetaUnitizador
	Self:cImpresso := PadR(cImpresso, Len(Self:cImpresso))
Return
//----------------------------------------
// Getters
//-----------------------------------
METHOD GetIdUnit() CLASS WMSDTCEtiquetaUnitizador
Return Self:cIdUnit
//----------------------------------------
METHOD GetTipUni() CLASS WMSDTCEtiquetaUnitizador
Return Self:cTipUni
//----------------------------------------
METHOD GetDatGer() CLASS WMSDTCEtiquetaUnitizador
Return Self:dDatGer
//----------------------------------------
METHOD GetHorGer() CLASS WMSDTCEtiquetaUnitizador
Return Self:cHorGer
//----------------------------------------
METHOD GetTipGer() CLASS WMSDTCEtiquetaUnitizador
Return Self:cTipGer
//----------------------------------------
METHOD GetUsuario() CLASS WMSDTCEtiquetaUnitizador
Return Self:cUsuario
//----------------------------------------
METHOD GetUsado() CLASS WMSDTCEtiquetaUnitizador
Return Self:cUsado
//----------------------------------------
METHOD GetImpresso() CLASS WMSDTCEtiquetaUnitizador
Return Self:cImpresso
//----------------------------------------
METHOD GetIsUsed() CLASS WMSDTCEtiquetaUnitizador
Return Self:cUsado == '1'
//----------------------------------------
METHOD GetIsPrinted() CLASS WMSDTCEtiquetaUnitizador
Return Self:cImpresso == '1'
//----------------------------------------
METHOD GetRecno() CLASS WMSDTCEtiquetaUnitizador
Return Self:nRecno
//----------------------------------------
METHOD GetErro() CLASS WMSDTCEtiquetaUnitizador
Return Self:cErro
