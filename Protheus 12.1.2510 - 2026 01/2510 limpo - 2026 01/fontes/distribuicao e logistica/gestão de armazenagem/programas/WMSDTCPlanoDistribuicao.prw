#Include "Totvs.ch"   
#Include "WMSDTCPlanoDistribuicao.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0012
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0050()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCPlanoDistribuicao
Classe distribuição de produtos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCPlanoDistribuicao FROM LongNameClass
	// Data
	DATA cCodPln
	DATA cStatus
	DATA dDataGer
	DATA cHoraGer
	DATA cErro
	DATA nRecno
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD RecordD0L()
	METHOD DeleteD0L()
	METHOD UpdateD0L()
	// Setters
	METHOD SetCodPln(cCodPln)
	METHOD SetStatus(cStatus)
	// Getters
	METHOD GetCodPln()
	METHOD GetStatus()
	METHOD GetDataGer()
	METHOD GetHoraGer()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCPlanoDistribuicao
	Self:cCodPln    := PadR("",TamSx3("D0L_CODPLN")[1])
	Self:cStatus    := "1"
	Self:dDataGer   := CtoD("  /  /    ")
	Self:cHoraGer   := PadR("",TamSx3("D0L_HORGER")[1])
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCPlanoDistribuicao
	//Mantido para compatibilidade
Return

METHOD LoadData(nIndex) CLASS WMSDTCPlanoDistribuicao
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aAreaD0L    := D0L->(GetArea())
Local aData       := TamSx3("D0L_DATGER")
Local cAliasD0L   := Nil

Default nIndex := 1

	Do Case 
		Case nIndex == 1 // D0L_FILIAL+D0L_CODPLN
			If Empty(Self:cCodPln)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0L   := GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasD0L
					SELECT D0L.D0L_CODPLN,
							D0L.D0L_STATUS,
							D0L.D0L_DATGER,
							D0L.D0L_HORGER,
							D0L.R_E_C_N_O_ RECNOD0L
					FROM %Table:D0L% D0L
					WHERE D0L.D0L_FILIAL = %xFilial:D0L%
					AND D0L.D0L_CODPLN = %Exp:Self:cCodPln%
					AND D0L.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasD0L,'D0L_DATGER','D',aData[1],aData[2])
		If (lRet := (cAliasD0L)->(!Eof()))
			Self:cCodPln  := (cAliasD0L)->D0L_CODPLN
			Self:cStatus  := (cAliasD0L)->D0L_STATUS
			Self:dDataGer := (cAliasD0L)->D0L_DATGER
			Self:cHoraGer := (cAliasD0L)->D0L_HORGER
			Self:nRecno   := (cAliasD0L)->RECNOD0L
		EndIf
		(cAliasD0L)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0L)
	RestArea(aAreaAnt)
Return lRet

METHOD RecordD0L() CLASS WMSDTCPlanoDistribuicao
Local lRet := .T.
	If Empty(Self:cCodPln)	
		Self:cCodPln := GetSX8Num('D0L','D0L_CODPLN')
	EndIf
	If Empty(Self:cStatus)
		Self:cStatus := "1"
	EndIf
	If Empty(Self:dDataGer)
		Self:dDataGer:= dDataBase
	EndIf
	If Empty(Self:cHoraGer)
		Self:cHoraGer:= Time()
	EndIf
	DbSelectArea("D0L")
	D0L->(dbSetOrder(1)) // D0L_FILIAL+D0L_CODPLN
	If !D0L->(dbSeek(xFilial("D0L")+Self:cCodPln))
		Reclock('D0L',.T.)
		D0L->D0L_FILIAL := xFilial("D0L")
		D0L->D0L_CODPLN := Self:cCodPln 
		D0L->D0L_STATUS := Self:cStatus
		D0L->D0L_DATGER := Self:dDataGer
		D0L->D0L_HORGER := Self:cHoraGer
		D0L->(MsUnLock())
		// Grava recno
		Self:nRecno := D0L->(Recno())
		// Confirmação do número sequencial do documento D0L (GetSX8Num('D0L','D0L_CODPLN')).
		If lRet .And. __lSX8
			ConfirmSX8()
		EndIf	
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada!
	EndIf
Return lRet

METHOD UpdateD0L() CLASS WMSDTCPlanoDistribuicao
Local lRet := .T.
Local aAreaD0L := D0L->(GetArea())
	If !Empty(Self:nRecno)
		D0L->(dbGoTo( Self:GetRecno() ))
		// Grava D0L
		RecLock('D0L', .F.)
		D0L->D0L_STATUS := Self:cStatus
		D0L->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0L)
Return lRet

METHOD DeleteD0L() CLASS WMSDTCPlanoDistribuicao
Local lRet := .T.
Local aAreaD0L := D0L->(GetArea())
	If !Empty(Self:nRecno)
		D0L->(dbGoTo( Self:nRecno ))
		// Grava D07
		RecLock('D0L', .F.)
		D0L->(dbDelete())
		D0L->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
	RestArea(aAreaD0L)
Return lRet

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodPln(cCodPln) CLASS WMSDTCPlanoDistribuicao
	Self:cCodPln := PadR(cCodPln, Len(Self:cCodPln))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCPlanoDistribuicao
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodPln() CLASS WMSDTCPlanoDistribuicao
Return Self:cCodPln

METHOD GetStatus() CLASS WMSDTCPlanoDistribuicao
Return Self:cStatus

METHOD GetDataGer() CLASS WMSDTCPlanoDistribuicao
Return Self:dDataGer

METHOD GetHoraGer() CLASS WMSDTCPlanoDistribuicao
Return Self:cHoraGer

METHOD GetErro() CLASS WMSDTCPlanoDistribuicao
Return Self:cErro

METHOD GetRecno() CLASS WMSDTCPlanoDistribuicao
Return Self:nRecno
