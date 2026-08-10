#Include "Totvs.ch"   
#Include "WMSDTCDistribuicaoProdutos.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0012
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0012()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCDistribuicaoProdutos
Classe distribuição de produtos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCDistribuicaoProdutos FROM LongNameClass
	// Data
	DATA cCodDis
	DATA cTipoDis
	DATA cSitDis
	DATA dDataGer
	DATA cHoraGer
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD RecordD06()
	METHOD UpdateD06()
	// Setters
	METHOD SetCodDis(cCodDis)
	METHOD SetTipoDis(cTipoDis)
	METHOD SetSitDis(cSitDis)
	// Getters
	METHOD GetCodDis()
	METHOD GetTipoDis()
	METHOD GetSitDis()
	METHOD GetDataGer()
	METHOD GetHoraGer()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCDistribuicaoProdutos
	Self:cCodDis    := PadR("",TamSx3("D06_CODDIS")[1])
	Self:cTipoDis   := "1"
	Self:cSitDis    := "1"
	Self:dDataGer   := CtoD("  /  /    ")
	Self:cHoraGer   := PadR("",TamSx3("D06_HRGDIS")[1])
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCDistribuicaoProdutos
	//Mantido para compatibilidade
Return

METHOD LoadData(nIndex) CLASS WMSDTCDistribuicaoProdutos
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD06    := D06->(GetArea())
Local aD06_DTGDIS := TamSx3("D06_DTGDIS")
Local cAliasD06   := Nil

Default nIndex := 1

	Do Case 
		Case nIndex == 1 // D06_FILIAL+D06_CODDIS
			If Empty(Self:cCodDis)
				lRet := .F.
			EndIf			
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD06   := GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD06
					SELECT D06.D06_CODDIS,
							D06.D06_TIPDIS,
							D06.D06_SITDIS,
							D06.D06_DTGDIS,
							D06.D06_HRGDIS,
							D06.R_E_C_N_O_ RECNOD06
					FROM %Table:D06% D06
					WHERE D06.D06_FILIAL = %xFilial:D06%
					AND D06.D06_CODDIS = %Exp:Self:cCodDis%
					AND D06.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD06,'D06_DTGDIS','D',aD06_DTGDIS[1],aD06_DTGDIS[2])
		If (lRet := (cAliasD06)->(!Eof()))
			Self:cCodDis  := (cAliasD06)->D06_CODDIS
			Self:cTipoDis := (cAliasD06)->D06_TIPDIS
			Self:cSitDis  := (cAliasD06)->D06_SITDIS
			Self:dDataGer := (cAliasD06)->D06_DTGDIS
			Self:cHoraGer := (cAliasD06)->D06_HRGDIS
			Self:nRecno   := (cAliasD06)->RECNOD06
		EndIf
		(cAliasD06)->(dbCloseArea())
	EndIf
	RestArea(aAreaD06)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD06() CLASS WMSDTCDistribuicaoProdutos
Local lRet := .T.
	If Empty(Self:cCodDis)	
		Self:cCodDis := GetSX8Num('D06','D06_CODDIS')
	EndIf
	If Empty(Self:cSitDis)
		Self:cSitDis := "1"
	EndIf
	If Empty(Self:dDataGer)
		Self:dDataGer:= dDataBase
	EndIf
	If Empty(Self:cHoraGer)
		Self:cHoraGer:= Time()
	EndIf
	If Empty(Self:cTipoDis)
		Self:cTipoDis := "1"
	EndIf
	DbSelectArea("D06")
	D06->(dbSetOrder(1)) // D06_FILIAL+D06_CODDIS
	If !D06->(dbSeek(xFilial("D06")+Self:cCodDis))
		Reclock('D06',.T.)
		D06->D06_FILIAL := xFilial("D06")
		D06->D06_CODDIS := Self:cCodDis 
		D06->D06_TIPDIS := Self:cTipoDis
		D06->D06_SITDIS := Self:cSitDis
		D06->D06_DTGDIS := Self:dDataGer
		D06->D06_HRGDIS := Self:cHoraGer
		D06->(MsUnLock())
		// Grava recno
		Self:nRecno := D06->(Recno())
		// Confirmação do número sequencial do documento DCF (GetSX8Num('DCF','DCF_DOCTO')).
		If lRet .And. __lSX8
			ConfirmSX8()
		EndIf
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD06() CLASS WMSDTCDistribuicaoProdutos
Local lRet := .T.
Local aAreaD06 := D06->(GetArea())
	If !Empty(Self:nRecno)
		D06->(dbGoTo( Self:GetRecno() ))
		// Grava D06
		RecLock('D06', .F.)
		D06->D06_SITDIS := Self:cSitDis
		D06->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD06)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodDis(cCodDis) CLASS WMSDTCDistribuicaoProdutos
	Self:cCodDis := PadR(cCodDis, Len(Self:cCodDis))
Return

METHOD SetTipoDis(cTipoDis) CLASS WMSDTCDistribuicaoProdutos
	Self:cTipoDis := PadR(cTipoDis, Len(Self:cTipoDis))
Return  

METHOD SetSitDis(cSitDis) CLASS WMSDTCDistribuicaoProdutos
	Self:cSitDis := PadR(cSitDis, Len(Self:cSitDis))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodDis() CLASS WMSDTCDistribuicaoProdutos
Return Self:cCodDis

METHOD GetTipoDis() CLASS WMSDTCDistribuicaoProdutos
Return Self:cTipoDis

METHOD GetSitDis() CLASS WMSDTCDistribuicaoProdutos
Return Self:cSitDis

METHOD GetDataGer() CLASS WMSDTCDistribuicaoProdutos
Return Self:dDataGer

METHOD GetHoraGer() CLASS WMSDTCDistribuicaoProdutos
Return Self:cHoraGer

METHOD GetErro() CLASS WMSDTCDistribuicaoProdutos
Return Self:cErro

METHOD GetRecno() CLASS WMSDTCDistribuicaoProdutos
Return Self:nRecno
