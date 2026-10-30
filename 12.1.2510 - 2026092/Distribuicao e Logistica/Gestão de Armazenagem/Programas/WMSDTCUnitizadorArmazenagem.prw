#INCLUDE 'TOTVS.CH'
#INCLUDE "WMSDTCUNITIZADORARMAZENAGEM.CH"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0057
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS Embarcador
@since 17/04/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0057()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCUnitizadorArmazenagem
Classe Unitizador Armazenagem
@author Squad WMS Embarcador
@since 17/04/2017
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCUnitizadorArmazenagem FROM LongNameClass
	// Data
	DATA cTipUni
	DATA nAltura
	DATA nLargur
	DATA nCompri
	DATA nCapMax
	DATA nEmpMax
	DATA nTara
	DATA cCtrNor
	DATA cCtrAlt
	DATA cPadrao
	DATA cMisto
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD GoToD0T(nRecno)
	METHOD LoadData(nIndex)
	// Setters
	METHOD SetTipUni(cTipUni)
	METHOD SetAltura(nAltura)
	METHOD SetLargura(nLargur)
	METHOD SetComprim(nCompri)
	METHOD SetCapMax(nCapMax)
	METHOD SetEmpMax(nEmpMax)
	METHOD SetTara(nTara)
	METHOD SetCtrNor(cCtrNor)
	METHOD SetCtrAlt(cCtrAlt)
	// Getters
	METHOD GetTipUni()
	METHOD GetAltura()
	METHOD GetLargura()
	METHOD GetComprim()
	METHOD GetCapMax()
	METHOD GetEmpMax()
	METHOD GetTara()
	METHOD GetCubagem()
	METHOD GetCtrNor()
	METHOD GetCtrAlt()
	METHOD GetPadrao()
	METHOD CanUniMis()
	METHOD GetRecno()
	METHOD GetErro()
	// Method
	METHOD Destroy()
	METHOD FindPadrao()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 03/04/2017
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCUnitizadorArmazenagem
	Self:cTipUni := PadR("", TamSx3("D0T_CODUNI")[1])
	Self:ClearData()
Return

//----------------------------------------
METHOD ClearData() CLASS WMSDTCUnitizadorArmazenagem
	Self:cTipUni := PadR("", Len(Self:cTipUni))
	Self:nAltura := 0
	Self:nLargur := 0
	Self:nCompri := 0
	Self:nCapMax := 0
	Self:nEmpMax := 0
	Self:nTara   := 0
	Self:cCtrNor := "1"
	Self:cCtrAlt := "1"
	Self:cPadrao := "2"
	Self:cMisto  := "2"
	Self:nRecno  := 0
	Self:cErro   := ""
Return Nil

//----------------------------------------
METHOD Destroy() CLASS WMSDTCUnitizadorArmazenagem
	//Mantido para compatibilidade
Return Nil

//----------------------------------------
METHOD GoToD0T(nRecno) CLASS WMSDTCUnitizadorArmazenagem
	Self:nRecno := nRecno
Return Self:LoadData(0)

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0T
@author felipe.m
@since 17/04/2017
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCUnitizadorArmazenagem
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD0T    := D0T->(GetArea())
Local aD0T_ALTURA := TamSx3("D0T_ALTURA")
Local aD0T_LARGUR := TamSx3("D0T_LARGUR")
Local aD0T_COMPRI := TamSx3("D0T_COMPRI")
Local aD0T_CAPMAX := TamSx3("D0T_CAPMAX")
Local aD0T_EMPMAX := TamSx3("D0T_EMPMAX")
Local aD0T_TARA   := TamSx3("D0T_TARA")
Local cAliasD0T   := Nil

Default nIndex := 1

	Do Case
		Case nIndex == 0 // R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0T_FILIAL+D0T_CODUNI
			If Empty(Self:GetTipUni())
				lRet := .F.
			EndIf

		Otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0T:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0T
					SELECT D0T.D0T_CODUNI,
							D0T.D0T_ALTURA,
							D0T.D0T_LARGUR,
							D0T.D0T_COMPRI,
							D0T.D0T_CAPMAX,
							D0T.D0T_EMPMAX,
							D0T.D0T_TARA,
							D0T.D0T_CTRNOR,
							D0T.D0T_CTRALT,
							D0T.D0T_PADRAO,
							D0T.D0T_PERMIS,
							D0T.R_E_C_N_O_ RECNOD0T
					FROM %Table:D0T% D0T
					WHERE D0T.D0T_FILIAL = %xFilial:D0T%
					AND D0T.R_E_C_N_O_ = %Exp:Self:nRecno%
					AND D0T.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0T
					SELECT D0T.D0T_CODUNI,
							D0T.D0T_ALTURA,
							D0T.D0T_LARGUR,
							D0T.D0T_COMPRI,
							D0T.D0T_CAPMAX,
							D0T.D0T_EMPMAX,
							D0T.D0T_TARA,
							D0T.D0T_CTRNOR,
							D0T.D0T_CTRALT,
							D0T.D0T_PADRAO,
							D0T.D0T_PERMIS,
							D0T.R_E_C_N_O_ RECNOD0T
					FROM %Table:D0T% D0T
					WHERE D0T.D0T_FILIAL = %xFilial:D0T%
					AND D0T.D0T_CODUNI = %Exp:Self:GetTipUni()%
					AND D0T.%NotDel%
				EndSql
			EndCase
		TcSetField(cAliasD0T,'D0T_ALTURA','N',aD0T_ALTURA[1],aD0T_ALTURA[2])
		TcSetField(cAliasD0T,'D0T_LARGUR','N',aD0T_LARGUR[1],aD0T_LARGUR[2])
		TcSetField(cAliasD0T,'D0T_COMPRI','N',aD0T_COMPRI[1],aD0T_COMPRI[2])
		TcSetField(cAliasD0T,'D0T_CAPMAX','N',aD0T_CAPMAX[1],aD0T_CAPMAX[2])
		TcSetField(cAliasD0T,'D0T_EMPMAX','N',aD0T_EMPMAX[1],aD0T_EMPMAX[2])
		TcSetField(cAliasD0T,'D0T_TARA','N',aD0T_TARA[1],aD0T_TARA[2])
		If (lRet := (cAliasD0T)->(!Eof()))
			Self:cTipUni := (cAliasD0T)->D0T_CODUNI
			Self:nAltura := (cAliasD0T)->D0T_ALTURA
			Self:nLargur := (cAliasD0T)->D0T_LARGUR
			Self:nCompri := (cAliasD0T)->D0T_COMPRI
			Self:nCapMax := (cAliasD0T)->D0T_CAPMAX
			Self:nEmpMax := (cAliasD0T)->D0T_EMPMAX
			Self:nTara   := (cAliasD0T)->D0T_TARA
			Self:cCtrNor := (cAliasD0T)->D0T_CTRNOR
			Self:cCtrAlt := (cAliasD0T)->D0T_CTRALT
			Self:cPadrao := (cAliasD0T)->D0T_PADRAO
			Self:cMisto  := (cAliasD0T)->D0T_PERMIS
			Self:nRecno  := (cAliasD0T)->RECNOD0T
		EndIf
		(cAliasD0T)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0T)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetTipUni(cTipUni) CLASS WMSDTCUnitizadorArmazenagem
	Self:cTipUni := cTipUni
Return
//----------------------------------------
METHOD SetAltura(nAltura) CLASS WMSDTCUnitizadorArmazenagem
	Self:nAltura := nAltura
Return
//----------------------------------------
METHOD SetLargura(nLargur) CLASS WMSDTCUnitizadorArmazenagem
	Self:nLargur := nLargur
Return
//----------------------------------------
METHOD SetComprim(nCompri) CLASS WMSDTCUnitizadorArmazenagem
	Self:nCompri := nCompri
Return
//----------------------------------------
METHOD SetCapMax(nCapMax) CLASS WMSDTCUnitizadorArmazenagem
	Self:nCapMax := nCapMax
Return
//----------------------------------------
METHOD SetEmpMax(nEmpMax) CLASS WMSDTCUnitizadorArmazenagem
	Self:nEmpMax := nEmpMax
Return
//----------------------------------------
METHOD SetTara(nTara) CLASS WMSDTCUnitizadorArmazenagem
	Self:nTara := nTara
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetTipUni() CLASS WMSDTCUnitizadorArmazenagem
Return Self:cTipUni
//----------------------------------------
METHOD GetAltura() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nAltura
//----------------------------------------
METHOD GetLargura() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nLargur
//----------------------------------------
METHOD GetComprim() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nCompri
//----------------------------------------
METHOD GetCapMax() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nCapMax
//----------------------------------------
METHOD GetEmpMax() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nEmpMax
//----------------------------------------
METHOD GetTara() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nTara
//----------------------------------------
METHOD GetCubagem() CLASS WMSDTCUnitizadorArmazenagem
Return (Self:nAltura * Self:nLargur * Self:nCompri)
//----------------------------------------
METHOD GetCtrNor() CLASS WMSDTCUnitizadorArmazenagem
Return Self:cCtrNor == "1"
//----------------------------------------
METHOD GetCtrAlt() CLASS WMSDTCUnitizadorArmazenagem
Return Self:cCtrAlt
//----------------------------------------
METHOD GetPadrao() CLASS WMSDTCUnitizadorArmazenagem
Return Self:cPadrao
//----------------------------------------
METHOD GetRecno() CLASS WMSDTCUnitizadorArmazenagem
Return Self:nRecno
//----------------------------------------
METHOD GetErro() CLASS WMSDTCUnitizadorArmazenagem
Return Self:cErro
//----------------------------------------
METHOD CanUniMis() CLASS WMSDTCUnitizadorArmazenagem
Return Self:cMisto == "1"
//----------------------------------------
METHOD FindPadrao() CLASS WMSDTCUnitizadorArmazenagem
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
	// Carrega o objeto com o tipo de unitizador padrão da Filial
	cAliasQry:= GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT D0T.R_E_C_N_O_ RECNOD0T
		FROM %Table:D0T% D0T
		WHERE D0T.D0T_FILIAL = %xFilial:D0T%
		AND D0T.D0T_PADRAO = '1'
		AND D0T.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		Self:GoToD0T((cAliasQry)->RECNOD0T)
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return Nil
