#Include 'Totvs.ch'
#Include "WMSDTCVolumeCrossDockingItens.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0048
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0090()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCVolumeCrossDocking
Classe volume
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCVolumeCrossDocking FROM LongNameClass
	// Data
	DATA oEndereco
	DATA cCodVol
	DATA dDtInicio
	DATA cHrInicio
	DATA dDtFinal
	DATA cHrFinal
	DATA cTmpMovto
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GoToD0N(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0N()
	METHOD ExcludeD0N()
	// Setters
	METHOD SetCodMnt(cCodMnt)
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEndereco)
	METHOD SetCodVol(cCodVol)
	METHOD SetDtIni(dDtInicio)
	METHOD SetHrIni(cHrInicio)
	METHOD SetDtFim(dDtFinal)
	METHOD SetHrFim(cHrFinal)
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetDtIni()
	METHOD GetHrIni()
	METHOD GetDtFim()
	METHOD GetHrFim()
	METHOD GetCodVol()
	METHOD GetRecno()
	METHOD GetErro()
	METHOD VolHasItem()
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
METHOD New() CLASS WMSDTCVolumeCrossDocking
	Self:oEndereco  := WMSDTCEndereco():New()
	Self:cCodVol    := PadR("", TamSx3("D0N_CODVOL")[1])
	Self:dDtInicio  := dDataBase
	Self:cHrInicio  := Time()
	Self:dDtFinal   := StoD("")
	Self:cHrFinal   := PadR("",Len(Self:cHrInicio))
	Self:cTmpMovto  := ""
	Self:cErro      := ""
	Self:nRecno     := 0
Return

METHOD Destroy() CLASS WMSDTCVolumeCrossDocking
	//Mantido para compatibilidade
Return Nil

//----------------------------------------
METHOD GoToD0N(nRecno) CLASS WMSDTCVolumeCrossDocking
	Self:nRecno := nRecno
Return Self:LoadData(0)

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0N
@author alexsander.correa
@since 27/02/2015
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCVolumeCrossDocking
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aAreaD0N := D0N->(GetArea())
Local cAliasD0N:= Nil

Default nIndex := 2

	Do Case
		Case nIndex == 0 // D0N.R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0N_FILIAL+D0N_CODVOL
			If Empty(Self:cCodVol)
				lRet := .F.
			EndIf
		Case nIndex == 2 // D0N_FILIAL+D0N_LOCAL+D0N_ENDER+D0N_CODVOL
			If Empty(Self:GetEnder()) .Or. Empty(Self:cCodVol)
				lRet := .F.
			EndIf

		Otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasD0N:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0N
					SELECT D0N.D0N_LOCAL,
							D0N.D0N_ENDER,
							D0N.D0N_CODVOL,
							D0N.D0N_DATINI,
							D0N.D0N_HORINI,
							D0N.D0N_DATFIM,
							D0N.D0N_HORFIM,
							D0N.R_E_C_N_O_ RECNOD0N
					FROM %Table:D0N% D0N
					WHERE D0N.D0N_FILIAL = %xFilial:D0N%
					AND D0N.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					AND D0N.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0N
					SELECT D0N.D0N_LOCAL,
							D0N.D0N_ENDER,
							D0N.D0N_CODVOL,
							D0N.D0N_DATINI,
							D0N.D0N_HORINI,
							D0N.D0N_DATFIM,
							D0N.D0N_HORFIM,
							D0N.R_E_C_N_O_ RECNOD0N
					FROM %Table:D0N% D0N
					WHERE D0N.D0N_FILIAL = %xFilial:D0N%
					AND D0N.D0N_CODVOL = %Exp:Self:cCodVol%
					AND D0N.%NotDel%
				EndSql
			Case nIndex == 2
				BeginSql Alias cAliasD0N
					SELECT D0N.D0N_LOCAL,
							D0N.D0N_ENDER,
							D0N.D0N_CODVOL,
							D0N.D0N_DATINI,
							D0N.D0N_HORINI,
							D0N.D0N_DATFIM,
							D0N.D0N_HORFIM,
							D0N.R_E_C_N_O_ RECNOD0N
					FROM %Table:D0N% D0N
					WHERE D0N.D0N_FILIAL = %xFilial:D0N%
					AND D0N.D0N_LOCAL = %Exp:Self:GetArmazem()%
					AND D0N.D0N_ENDER = %Exp:Self:GetEnder()%
					AND D0N.D0N_CODVOL = %Exp:Self:cCodVol%
					AND D0N.%NotDel%
				EndSql
		EndCase
		TcSetField(cAliasD0N,'D0N_DATINI','D')
		TcSetField(cAliasD0N,'D0N_DATFIM','D')
		lRet := (cAliasD0N)->(!Eof())
		If lRet
			// Dados Gerais
			Self:SetArmazem((cAliasD0N)->D0N_LOCAL)
			Self:SetEnder((cAliasD0N)->D0N_ENDER)
			Self:oEndereco:LoadData()
			Self:cCodVol   := (cAliasD0N)->D0N_CODVOL
			// Busca dados lote/produto
			Self:dDtInicio := (cAliasD0N)->D0N_DATINI
			Self:cHrInicio := (cAliasD0N)->D0N_HORINI
			Self:dDtFinal  := (cAliasD0N)->D0N_DATFIM
			Self:cHrFinal  := (cAliasD0N)->D0N_HORFIM
			Self:nRecno    := (cAliasD0N)->RECNOD0N
		EndIf
		(cAliasD0N)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0N)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCVolumeCrossDocking
	Self:oEndereco:SetArmazem(cArmazem)
Return

METHOD SetEnder(cEndereco) CLASS WMSDTCVolumeCrossDocking
	Self:oEndereco:SetEnder(cEndereco)
Return

METHOD SetCodVol(cCodVol) CLASS WMSDTCVolumeCrossDocking
	Self:cCodVol := PadR(cCodVol, Len(Self:cCodVol))
Return

METHOD SetDtIni(dDtInicio) CLASS WMSDTCVolumeCrossDocking
	Self:dDtInicio := dDtInicio
Return

METHOD SetHrIni(cHrInicio) CLASS WMSDTCVolumeCrossDocking
	Self:cHrInicio := PadR(cHrInicio, Len(Self:cHrInicio))
Return

METHOD SetDtFim(dDtFinal) CLASS WMSDTCVolumeCrossDocking
	Self:dDtFinal := dDtFinal
Return

METHOD SetHrFim(cHrFinal) CLASS WMSDTCVolumeCrossDocking
	Self:cHrFinal := PadR(cHrFinal, Len(Self:cHrFinal))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCVolumeCrossDocking
Return Self:oEndereco:GetArmazem()

METHOD GetEnder() CLASS WMSDTCVolumeCrossDocking
Return Self:oEndereco:GetEnder()

METHOD GetCodVol() CLASS WMSDTCVolumeCrossDocking
Return Self:cCodVol

METHOD GetDtIni() CLASS WMSDTCVolumeCrossDocking
Return Self:dDtInicio

METHOD GetHrIni() CLASS WMSDTCVolumeCrossDocking
Return Self:cHrInicio

METHOD GetDtFim() CLASS WMSDTCVolumeCrossDocking
Return Self:dDtFinal

METHOD GetHrFim() CLASS WMSDTCVolumeCrossDocking
Return Self:cHrFinal

METHOD GetRecno() CLASS WMSDTCVolumeCrossDocking
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCVolumeCrossDocking
Return Self:cErro

METHOD RecordD0N() CLASS WMSDTCVolumeCrossDocking
Local lRet := .T.
Local lAchou := .F.
	If Empty(Self:cCodVol)
		Self:cCodVol := Padl(CBProxCod('MV_WMSNVOL'),10,'0')
	EndIf

	// Grava DCF
	D0N->(dbSetOrder(2))
	lAchou := D0N->(dbSeek(xFilial("D0N")+Self:GetArmazem()+Self:GetEnder()+Self:cCodVol))
	Reclock('D0N',!lAchou)
	If !lAchou
		D0N->D0N_FILIAL := xFilial("D0N")
		D0N->D0N_LOCAL  := Self:oEndereco:GetArmazem()
		D0N->D0N_ENDER  := Self:oEndereco:GetEnder()
		D0N->D0N_CODVOL := Self:cCodVol
		D0N->D0N_DATINI := Self:dDtInicio
		D0N->D0N_HORINI := Self:cHrInicio
		D0N->D0N_DATFIM := Iif(Empty(Self:dDtFinal),dDataBase,Self:dDtInicio)
		D0N->D0N_HORFIM := Iif(Empty(Self:cHrFinal),Time(),Self:cHrFinal)
	Else
		D0N->D0N_DATFIM := Iif(Empty(Self:dDtFinal),dDataBase,Self:dDtInicio)
		D0N->D0N_HORFIM := Iif(Empty(Self:cHrFinal),Time(),Self:cHrFinal)
	EndIf
	D0N->(MsUnLock())
	D0N->(DbCommit())
	// Grava recno
	Self:nRecno := D0N->(Recno())
Return lRet

METHOD ExcludeD0N() CLASS WMSDTCVolumeCrossDocking
Local lRet := .T.
	D0N->(dbGoTo( Self:nRecno ))
	// Excluindo a ordem de serviço
	RecLock('D0N', .F.)
	D0N->(DbDelete())
	D0N->(MsUnlock())
Return lRet

METHOD VolHasItem() CLASS WMSDTCVolumeCrossDocking
Local lRet      := .T.
Local cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:D0O% D0O
		WHERE D0O.D0O_FILIAL = %xFilial:D0O%
		AND D0O.D0O_CODVOL = %Exp:Self:cCodVol%
		AND %NotDel%
	EndSql
	lRet := (cAliasQry)->(!Eof())
Return lRet
