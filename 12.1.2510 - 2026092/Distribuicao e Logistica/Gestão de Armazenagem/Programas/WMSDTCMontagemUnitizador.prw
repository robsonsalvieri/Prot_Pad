#INCLUDE 'TOTVS.CH'
#INCLUDE "WMSDTCMONTAGEMUNITIZADOR.CH"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0055
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Squad WMS Embarcador
@since 03/04/2017
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0055()
Return Nil
//-----------------------------------------
/*/{Protheus.doc} WMSDTCMontagemUnitizador
Classe Montagem de Unitizador
@author Squad WMS Embarcador
@since 03/04/2017
@version 1.0
/*/
//-----------------------------------------
CLASS WMSDTCMontagemUnitizador FROM LongNameClass
	// Data
	DATA oEndereco
	DATA oTipUnit
	DATA oEtiqUnit
	DATA cStatus
	DATA cServico
	DATA dDatIni
	DATA cHorIni
	DATA dDatFim
	DATA cHorFim
	DATA cIdDCF
	DATA cOrigem
	DATA nRecno
	DATA cErro
	DATA nPeso
	DATA nVolume
	DATA nLargura
	DATA nComprim
	DATA nAltura
	// Method
	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD GoToD0R(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0R()
	METHOD UpdateD0R()
	METHOD ExcludeD0R()
	METHOD ExcludeOS()
	// Setters
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEndereco)
	METHOD SetIdUnit(cIdUnit)
	METHOD SetTipUni(cTipUni)
	METHOD SetStatus(cStatus)
	METHOD SetServico(cServico)
	METHOD SetDatIni(dDatIni)
	METHOD SetHorIni(cHorIni)
	METHOD SetDatFim(dDatFim)
	METHOD SetHorFim(cHotFim)
	METHOD SetIdDCF(cIdDCF)
	METHOD SetOrigem(cOrigem)
	// Getters
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetIdUnit()
	METHOD GetTipUni()
	METHOD GetStatus()
	METHOD GetServico()
	METHOD GetDatIni()
	METHOD GetHorIni()
	METHOD GetDatFim()
	METHOD GetHorFim()
	METHOD GetIdDCF()
	METHOD GetOrigem()
	METHOD GetRecno()
	METHOD GetErro()
	// Method
	METHOD Destroy()
	METHOD GetCtrNor()
	METHOD GetCapMax()
	METHOD GetPeso()
	METHOD GetVolume()
	METHOD GetAltura()
	METHOD GetLargura()
	METHOD GetComprim()
	METHOD CalcOcupac(oTmpSldD14,lMontagem)
	METHOD CalcDimens(oTmpSldD14)
	METHOD IsMultPrd(cProduto,oTmpSldD14,lMontagem)
	METHOD IsMultLot(cProduto,cLoteCtl,oTmpSldD14)
	METHOD UniHasItem()
	METHOD UpdStatus()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 03/04/2017
@version 1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCMontagemUnitizador
	Self:oEndereco  := WMSDTCEndereco():New()
	Self:oTipUnit   := WMSDTCUnitizadorArmazenagem():New()
	Self:oEtiqUnit  := WMSDTCEtiquetaUnitizador():New()
	Self:cServico   := PadR("", TamSx3("D0R_SERVIC")[1])
	Self:cIdDCF     := PadR("", TamSx3("D0R_IDDCF")[1])
	Self:cHorIni    := PadR("", TamSx3("D0R_HORINI")[1])
	Self:cOrigem    := PadR("", TamSx3("D0Q_ORIGEM")[1])
	Self:ClearData()
Return
//----------------------------------------
METHOD ClearData() CLASS WMSDTCMontagemUnitizador
	Self:oEndereco:ClearData()
	Self:oTipUnit:ClearData()
	Self:cStatus    := "1"
	Self:cServico   := PadR("", Len(Self:cServico))
	Self:cIdDCF     := PadR("", Len(Self:cIdDCF))
	Self:dDatIni    := CtoD("")
	Self:cHorIni    := PadR("", Len(Self:cHorIni))
	Self:dDatFim    := CtoD("")
	Self:cHorFim    := PadR("", Len(Self:cHorIni))
	Self:cOrigem    := PadR("", Len(Self:cOrigem))
	Self:nRecno     := 0
	Self:cErro      := ""
	Self:nPeso      := 0
	Self:nVolume    := 0
	Self:nLargura   := 0
	Self:nComprim   := 0
	Self:nAltura    := 0
Return Nil
//----------------------------------------
METHOD Destroy() CLASS WMSDTCMontagemUnitizador
	//Mantido para compatibilidade
Return Nil
//----------------------------------------
METHOD GoToD0R(nRecno) CLASS WMSDTCMontagemUnitizador
	Self:nRecno := nRecno
Return Self:LoadData(0)

//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0R
@author felipe.m
@since 04/04/2017
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCMontagemUnitizador
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aAreaD0R := D0R->(GetArea())
Local cAliasD0R:= Nil

Default nIndex := 1

	Do Case
		Case nIndex == 0 // D0R.R_E_C_N_O_
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0R_FILIAL+D0R_LOCAL+D0R_ENDER+D0R_IDUNIT+D0R_IDDCF
			If Empty(Self:GetArmazem()) .Or. Empty(Self:GetEnder()) .Or. Empty(Self:GetIdUnit())
				lRet := .F.
			EndIf
		Case nIndex == 2 // D0R_FILIAL+D0R_IDDCF
			If Empty(Self:GetIdDCF())
				lRet := .F.
			EndIf

		Case nIndex == 3 // D0R_FILIAL+D0R_IDUNIT
			If Empty(Self:GetIdUnit())
				lRet := .F.
			EndIf

		Otherwise
			lRet := .F.
	EndCase

	If !lRet
		Self:cErro := STR0001 + " (" + GetClassName(Self) + ":LoadData(" + cValToChar(nIndex) + " )(D0R))" // Dados para busca não foram informados!
	Else
		// Busca etiqueta unitizador
		cAliasD0R:= GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0R
					SELECT D0R.D0R_LOCAL,
							D0R.D0R_ENDER,
							D0R.D0R_IDUNIT,
							D0R.D0R_CODUNI,
							D0R.D0R_STATUS,
							D0R.D0R_SERVIC,
							D0R.D0R_DATINI,
							D0R.D0R_HORINI,
							D0R.D0R_DATFIM,
							D0R.D0R_HORFIM,
							D0R.D0R_IDDCF,
							D0R.R_E_C_N_O_ RECNOD0R
					FROM %Table:D0R% D0R
					WHERE D0R.D0R_FILIAL = %xFilial:D0R%
					AND D0R.R_E_C_N_O_ = %Exp:Self:nRecno%
					AND D0R.%NotDel%
				EndSql
			Case nIndex == 1
				If !Empty(Self:GetIdDCF())
					BeginSql Alias cAliasD0R
						SELECT D0R.D0R_LOCAL,
								D0R.D0R_ENDER,
								D0R.D0R_IDUNIT,
								D0R.D0R_CODUNI,
								D0R.D0R_STATUS,
								D0R.D0R_SERVIC,
								D0R.D0R_DATINI,
								D0R.D0R_HORINI,
								D0R.D0R_DATFIM,
								D0R.D0R_HORFIM,
								D0R.D0R_IDDCF,
								D0R.R_E_C_N_O_ RECNOD0R
						FROM %Table:D0R% D0R
						WHERE D0R.D0R_FILIAL = %xFilial:D0R%
						AND D0R.D0R_LOCAL = %Exp:Self:GetArmazem()%
						AND D0R.D0R_ENDER = %Exp:Self:GetEnder()%
						AND D0R.D0R_IDUNIT = %Exp:Self:GetIdUnit()%
						AND D0R.D0R_IDDCF = %Exp:Self:GetIdDCF()%
						AND D0R.%NotDel%
					EndSql
				Else
					BeginSql Alias cAliasD0R
						SELECT D0R.D0R_LOCAL,
								D0R.D0R_ENDER,
								D0R.D0R_IDUNIT,
								D0R.D0R_CODUNI,
								D0R.D0R_STATUS,
								D0R.D0R_SERVIC,
								D0R.D0R_DATINI,
								D0R.D0R_HORINI,
								D0R.D0R_DATFIM,
								D0R.D0R_HORFIM,
								D0R.D0R_IDDCF,
								D0R.R_E_C_N_O_ RECNOD0R
						FROM %Table:D0R% D0R
						WHERE D0R.D0R_FILIAL = %xFilial:D0R%
						AND D0R.D0R_LOCAL = %Exp:Self:GetArmazem()%
						AND D0R.D0R_ENDER = %Exp:Self:GetEnder()%
						AND D0R.D0R_IDUNIT = %Exp:Self:GetIdUnit()%
						AND D0R.%NotDel%
					EndSql
				EndIf
			Case nIndex == 2
				BeginSql Alias cAliasD0R
					SELECT D0R.D0R_LOCAL,
							D0R.D0R_ENDER,
							D0R.D0R_IDUNIT,
							D0R.D0R_CODUNI,
							D0R.D0R_STATUS,
							D0R.D0R_SERVIC,
							D0R.D0R_DATINI,
							D0R.D0R_HORINI,
							D0R.D0R_DATFIM,
							D0R.D0R_HORFIM,
							D0R.D0R_IDDCF,
							D0R.R_E_C_N_O_ RECNOD0R
					FROM %Table:D0R% D0R
					WHERE D0R.D0R_FILIAL = %xFilial:D0R%
					AND D0R.D0R_IDDCF = %Exp:Self:GetIdDCF()%
					AND D0R.%NotDel%
				EndSql
			Case nIndex == 3
				BeginSql Alias cAliasD0R
					SELECT D0R.D0R_LOCAL,
							D0R.D0R_ENDER,
							D0R.D0R_IDUNIT,
							D0R.D0R_CODUNI,
							D0R.D0R_STATUS,
							D0R.D0R_SERVIC,
							D0R.D0R_DATINI,
							D0R.D0R_HORINI,
							D0R.D0R_DATFIM,
							D0R.D0R_HORFIM,
							D0R.D0R_IDDCF,
							D0R.R_E_C_N_O_ RECNOD0R
					FROM %Table:D0R% D0R
					WHERE D0R.D0R_FILIAL = %xFilial:D0R%
					AND D0R.D0R_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D0R.%NotDel%
				EndSql
		EndCase
		TcSetField(cAliasD0R,'D0R_DATINI','D')
		TcSetField(cAliasD0R,'D0R_DATFIM','D')
		If (lRet := (cAliasD0R)->(!Eof()))
			// Dados Endereço
			Self:SetArmazem((cAliasD0R)->D0R_LOCAL)
			Self:SetEnder((cAliasD0R)->D0R_ENDER)
			Self:oEndereco:LoadData()
			// Tipo de unitizador
			Self:oTipUnit:SetTipUni((cAliasD0R)->D0R_CODUNI)
			Self:oTipUnit:LoadData()
			// Etiqueta Unitizador
			Self:oEtiqUnit:SetIdUnit((cAliasD0R)->D0R_IDUNIT)
			Self:oEtiqUnit:LoadData()
			// Dados Gerais
			Self:cStatus  := (cAliasD0R)->D0R_STATUS
			Self:cServico := (cAliasD0R)->D0R_SERVIC
			Self:dDatIni  := (cAliasD0R)->D0R_DATINI
			Self:cHorIni  := (cAliasD0R)->D0R_HORINI
			Self:dDatFim  := (cAliasD0R)->D0R_DATFIM
			Self:cHorFim  := (cAliasD0R)->D0R_HORFIM
			Self:cIdDCF   := (cAliasD0R)->D0R_IDDCF
			Self:nRecno   := (cAliasD0R)->RECNOD0R
		EndIf
		(cAliasD0R)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0R)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCMontagemUnitizador
	Self:oEndereco:SetArmazem(cArmazem)
Return
//----------------------------------------
METHOD SetEnder(cEndereco) CLASS WMSDTCMontagemUnitizador
	Self:oEndereco:SetEnder(cEndereco)
Return
//----------------------------------------
METHOD SetIdUnit(cIdUnit) CLASS WMSDTCMontagemUnitizador
	Self:oEtiqUnit:SetIdUnit(cIdUnit)
Return
//----------------------------------------
METHOD SetTipUni(cTipUni) CLASS WMSDTCMontagemUnitizador
	Self:oTipUnit:SetTipUni(cTipUni)
Return
//----------------------------------------
METHOD SetStatus(cStatus) CLASS WMSDTCMontagemUnitizador
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return
//----------------------------------------
METHOD SetServico(cServico) CLASS WMSDTCMontagemUnitizador
	Self:cServico := PadR(cServico, Len(Self:cServico))
Return
//----------------------------------------
METHOD SetDatIni(dDatIni) CLASS WMSDTCMontagemUnitizador
	Self:dDatIni := dDatIni
Return
//----------------------------------------
METHOD SetHorIni(cHorIni) CLASS WMSDTCMontagemUnitizador
	Self:cHorIni := cHorIni
Return
//----------------------------------------
METHOD SetDatFim(dDatFim) CLASS WMSDTCMontagemUnitizador
	Self:dDatFim := dDatFim
Return
//----------------------------------------
METHOD SetHorFim(cHotFim) CLASS WMSDTCMontagemUnitizador
	Self:cHorFim := cHotFim
Return
//----------------------------------------
METHOD SetIdDCF(cIdDCF) CLASS WMSDTCMontagemUnitizador
	Self:cIdDCF := PadR(cIdDCF, Len(Self:cIdDCF))
Return
//----------------------------------------
METHOD SetOrigem(cOrigem) CLASS WMSDTCMontagemUnitizador
	Self:cOrigem := PadR(cOrigem, Len(Self:cOrigem))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCMontagemUnitizador
Return Self:oEndereco:GetArmazem()
//----------------------------------------
METHOD GetEnder() CLASS WMSDTCMontagemUnitizador
Return Self:oEndereco:GetEnder()
//----------------------------------------
METHOD GetIdUnit() CLASS WMSDTCMontagemUnitizador
Return Self:oEtiqUnit:GetIdUnit()
//----------------------------------------
METHOD GetTipUni() CLASS WMSDTCMontagemUnitizador
Return Self:oTipUnit:GetTipUni()
//----------------------------------------
METHOD GetStatus() CLASS WMSDTCMontagemUnitizador
Return Self:cStatus
//----------------------------------------
METHOD GetServico() CLASS WMSDTCMontagemUnitizador
Return Self:cServico
//----------------------------------------
METHOD GetDatIni() CLASS WMSDTCMontagemUnitizador
Return Self:dDatIni
//----------------------------------------
METHOD GetHorIni() CLASS WMSDTCMontagemUnitizador
Return Self:cHorIni
//----------------------------------------
METHOD GetDatFim() CLASS WMSDTCMontagemUnitizador
Return Self:dDatFim
//----------------------------------------
METHOD GetHorFim() CLASS WMSDTCMontagemUnitizador
Return Self:cHotFim
//----------------------------------------
METHOD GetIdDCF() CLASS WMSDTCMontagemUnitizador
Return Self:cIdDCF
//----------------------------------------
METHOD GetOrigem() CLASS WMSDTCMontagemUnitizador
Return Self:cOrigem
//----------------------------------------
METHOD GetRecno() CLASS WMSDTCMontagemUnitizador
Return Self:nRecno
//----------------------------------------
METHOD GetErro() CLASS WMSDTCMontagemUnitizador
Return Self:cErro
//----------------------------------------
METHOD GetCapMax() CLASS WMSDTCMontagemUnitizador
Return Self:oTipUnit:GetCapMax()
//----------------------------------------
METHOD GetCtrNor() CLASS WMSDTCMontagemUnitizador
Return Self:oTipUnit:GetCtrNor()
//----------------------------------------
METHOD GetPeso() CLASS WMSDTCMontagemUnitizador
Return Self:nPeso
//----------------------------------------
METHOD GetVolume() CLASS WMSDTCMontagemUnitizador
Return Self:nVolume
//----------------------------------------
METHOD GetAltura() CLASS WMSDTCMontagemUnitizador
Return Self:nAltura
//----------------------------------------
METHOD GetLargura() CLASS WMSDTCMontagemUnitizador
Return Self:nLargura
//----------------------------------------
METHOD GetComprim() CLASS WMSDTCMontagemUnitizador
Return Self:nComprim
//----------------------------------------
METHOD CalcOcupac(oTmpSldD14,lMontagem) CLASS WMSDTCMontagemUnitizador
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aTamSX3    := {}
Local cAliasQry  := GetNextAlias()
Local cTmpSldD14 := Nil

Default lMontagem := .F.

	Self:nPeso   := 0
	Self:nVolume := 0
	If lMontagem
		BeginSql Alias cAliasQry
			// Realiza o cálculo do peso dos produtos que já estão no unitizador
			SELECT  SUM ( ( SB1.B1_PESO + ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
						THEN (SB5.B5_ECPESOE / SB1.B1_CONV) ELSE  SB5.B5_ECPESOE END ) ) * ( D0S.D0S_QUANT ) ) UNT_PESUNI,
					SUM( ( B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
						THEN ( ( D0S.D0S_QUANT ) / SB1.B1_CONV) ELSE   ( D0S.D0S_QUANT ) END ) ) UNT_VOLUNI
			FROM %Table:D0S% D0S
			INNER JOIN %Table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = D0S.D0S_CODPRO
			AND SB1.%NotDel%
			INNER JOIN %Table:SB5% SB5
			ON SB5.B5_FILIAL = %xFilial:SB5%
			AND SB5.B5_COD = SB1.B1_COD
			AND SB5.%NotDel%
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
			AND D0S.%NotDel%
		EndSql
	Else
		If oTmpSldD14!=Nil
			cTmpSldD14 := "%"+oTmpSldD14:GetRealName()+"%"
			BeginSql Alias cAliasQry
				// Realiza o cálculo do peso dos produtos que já estão no unitizador
				SELECT  SUM ( ( SB1.B1_PESO + ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
							THEN (SB5.B5_ECPESOE / SB1.B1_CONV) ELSE  SB5.B5_ECPESOE END ) ) * ( D14.D14_QTDEST + D14.D14_QTDEPR ) ) UNT_PESUNI,
						SUM( ( B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
							THEN ( ( D14.D14_QTDEST + D14.D14_QTDEPR ) / SB1.B1_CONV) ELSE   ( D14.D14_QTDEST + D14.D14_QTDEPR ) END ) ) UNT_VOLUNI
				FROM %Exp:cTmpSldD14% D14
				INNER JOIN %Table:SB1% SB1
				ON SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = D14.D14_PRODUT
				AND SB1.%NotDel%
				INNER JOIN %Table:SB5% SB5
				ON SB5.B5_FILIAL = %xFilial:SB5%
				AND SB5.B5_COD = SB1.B1_COD
				AND SB5.%NotDel%
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_LOCAL = %Exp:Self:GetArmazem()%
				AND D14.D14_ENDER = %Exp:Self:GetEnder()%
				AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
				AND D14.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasQry
				// Realiza o cálculo do peso dos produtos que já estão no unitizador
				SELECT  SUM ( ( SB1.B1_PESO + ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
							THEN (SB5.B5_ECPESOE / SB1.B1_CONV) ELSE  SB5.B5_ECPESOE END ) ) * ( D14.D14_QTDEST + D14.D14_QTDEPR ) ) UNT_PESUNI,
						SUM( ( B5_COMPRLC * B5_LARGLC * B5_ALTURLC ) * ( CASE WHEN (SB1.B1_CONV > 0 AND SB1.B1_TIPCONV = 'D')
							THEN ( ( D14.D14_QTDEST + D14.D14_QTDEPR ) / SB1.B1_CONV) ELSE   ( D14.D14_QTDEST + D14.D14_QTDEPR ) END ) ) UNT_VOLUNI
				FROM %Table:D14% D14
				INNER JOIN %Table:SB1% SB1
				ON SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = D14.D14_PRODUT
				AND SB1.%NotDel%
				INNER JOIN %Table:SB5% SB5
				ON SB5.B5_FILIAL = %xFilial:SB5%
				AND SB5.B5_COD = SB1.B1_COD
				AND SB5.%NotDel%
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_LOCAL = %Exp:Self:GetArmazem()%
				AND D14.D14_ENDER = %Exp:Self:GetEnder()%
				AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
				AND D14.%NotDel%
			EndSql
		EndIf
	EndIf
	aTamSX3 := TamSx3("B1_PESO"); TcSetField(cAliasQry,'UNT_PESUNI','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasQry,'UNT_VOLUNI','N',16,6)
	If (cAliasQry)->(!Eof())
		Self:nPeso   := (cAliasQry)->UNT_PESUNI
		Self:nVolume := (cAliasQry)->UNT_VOLUNI
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------------------------------------------
METHOD CalcDimens(oTmpSldD14) CLASS WMSDTCMontagemUnitizador
Local lRet       := .T.
Local aTamSX3    := {}
Local cAliasQry  := Nil
Local cTmpSldD14 := ""
Local nQtdAndar  := 0
Local nQtd2UM    := 0

	Self:nLargura := Self:oTipUnit:GetLargura()
	Self:nComprim := Self:oTipUnit:GetComprim()
	Self:nAltura  := 0 // Caso não encontre na query para garatir zerado
	// Se o controle de altura é pelo unitizador, assume a altura do unitizador
	If Self:oTipUnit:GetCtrAlt() == "2"
		Self:nAltura := Self:oTipUnit:GetAltura()
	Else
		// Se é produto misto, não tem como controlar altura
		If !Self:IsMultPrd(/*cProduto*/,oTmpSldD14)
			cAliasQry:= GetNextAlias()
			If oTmpSldD14!=Nil
				cTmpSldD14 := "%"+oTmpSldD14:GetRealName()+"%"
				BeginSql Alias cAliasQry
					SELECT SB1.B1_CONV,
							SB1.B1_TIPCONV,
							SB5.B5_ALTURLC,
							DC2.DC2_LASTRO,
							SUM(D14.D14_QTDEST+D14.D14_QTDEPR) D14_QTDEST
					FROM %Exp:cTmpSldD14% D14
					INNER JOIN %Table:SB1% SB1
					ON SB1.B1_FILIAL = %xFilial:SB1%
					AND SB1.B1_COD = D14.D14_PRODUT
					AND SB1.%NotDel%
					INNER JOIN %Table:SB5% SB5
					ON SB5.B5_FILIAL = %xFilial:SB5%
					AND SB1.B1_FILIAL = %xFilial:SB1%
					AND SB5.B5_COD = SB1.B1_COD
					AND SB5.%NotDel%
					INNER JOIN %Table:DC3% DC3
					ON DC3.DC3_FILIAL = %xFilial:DC3%
					AND DC3.DC3_LOCAL  = D14.D14_LOCAL
					AND DC3.DC3_CODPRO = D14.D14_PRODUT
					AND DC3.DC3_TPESTR = D14.D14_ESTFIS
					AND DC3.%NotDel%
					INNER JOIN %Table:DC2% DC2
					ON DC2.DC2_FILIAL = %xFilial:DC2%
					AND DC2.DC2_CODNOR = DC3.DC3_CODNOR
					AND DC2.%NotDel%
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = %Exp:Self:GetArmazem()%
					AND D14.D14_ENDER = %Exp:Self:GetEnder()%
					AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D14.%NotDel%
					GROUP BY SB1.B1_CONV,
								SB1.B1_TIPCONV,
								SB5.B5_ALTURLC,
								DC2.DC2_LASTRO
				EndSql
			Else
				BeginSql Alias cAliasQry
					SELECT SB1.B1_CONV,
							SB1.B1_TIPCONV,
							SB5.B5_ALTURLC,
							DC2.DC2_LASTRO,
							SUM(D14.D14_QTDEST+D14.D14_QTDEPR) D14_QTDEST
					FROM %Table:D14% D14
					INNER JOIN %Table:SB1% SB1
					ON SB1.B1_FILIAL = %xFilial:SB1%
					AND SB1.B1_COD = D14.D14_PRODUT
					AND SB1.%NotDel%
					INNER JOIN %Table:SB5% SB5
					ON SB5.B5_FILIAL = %xFilial:SB5%
					AND SB1.B1_FILIAL = %xFilial:SB1%
					AND SB5.B5_COD = SB1.B1_COD
					AND SB5.%NotDel%
					INNER JOIN %Table:DC3% DC3
					ON DC3.DC3_FILIAL = %xFilial:DC3%
					AND DC3.DC3_LOCAL  = D14.D14_LOCAL
					AND DC3.DC3_CODPRO = D14.D14_PRODUT
					AND DC3.DC3_TPESTR = D14.D14_ESTFIS
					AND DC3.%NotDel%
					INNER JOIN %Table:DC2% DC2
					ON DC2.DC2_FILIAL = %xFilial:DC2%
					AND DC2.DC2_CODNOR = DC3.DC3_CODNOR
					AND DC2.%NotDel%
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_LOCAL = %Exp:Self:GetArmazem()%
					AND D14.D14_ENDER = %Exp:Self:GetEnder()%
					AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D14.%NotDel%
					GROUP BY SB1.B1_CONV,
								SB1.B1_TIPCONV,
								SB5.B5_ALTURLC,
								DC2.DC2_LASTRO
				EndSql
			EndIf
			aTamSX3 := TamSx3("B1_CONV"); TcSetField(cAliasQry,'B1_CONV','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSx3("B5_ALTURLC"); TcSetField(cAliasQry,'B5_ALTURLC','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSx3("DC2_LASTRO"); TcSetField(cAliasQry,'DC2_LASTRO','N',aTamSX3[1],aTamSX3[2])
			aTamSX3 := TamSx3("D14_QTDEST"); TcSetField(cAliasQry,'D14_QTDEST','N',aTamSX3[1],aTamSX3[2])
			If (cAliasQry)->(!Eof())
				If QtdComp((cAliasQry)->B1_CONV) > 0 .And. (cAliasQry)->B1_TIPCONV == "D"
					nQtd2UM := ( (cAliasQry)->D14_QTDEST / (cAliasQry)->B1_CONV )
					If Mod( nQtd2UM, (cAliasQry)->DC2_LASTRO ) > 0
						nQtdAndar := NoRound( ( nQtd2UM / (cAliasQry)->DC2_LASTRO ), 0 ) + 1
					Else
						nQtdAndar := ( nQtd2UM / (cAliasQry)->DC2_LASTRO )
					EndIf
				Else
					nQtdAndar := NoRound( ( (cAliasQry)->D14_QTDEST / (cAliasQry)->DC2_LASTRO ), 0 )
				EndIf
				Self:nAltura := ( nQtdAndar * (cAliasQry)->B5_ALTURLC )
			EndIf
			// Soma a altura do unitizador
			Self:nAltura += Self:oTipUnit:GetAltura()
		EndIf
	EndIf
Return lRet
//-----------------------------------------------------------------------------
METHOD IsMultPrd(cProduto,oTmpSldD14,lMontagem) CLASS WMSDTCMontagemUnitizador
Local lMisto    := .F.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil
Default cProduto  := ""
Default lMontagem := .F.
	cAliasQry := GetNextAlias()
	If lMontagem
		If !Empty(cProduto)
			BeginSql Alias cAliasQry
				SELECT COUNT(DISTINCT D0S_CODPRO) TOT_PRODUT
				FROM %Table:D0S% D0S
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
				AND D0S.D0S_CODPRO <> %Exp:cProduto%
				AND D0S.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT COUNT(DISTINCT D0S_CODPRO) TOT_PRODUT
				FROM %Table:D0S% D0S
				WHERE D0S.D0S_FILIAL = %xFilial:D0S%
				AND D0S.D0S_IDUNIT = %Exp:Self:GetIdUnit()%
				AND D0S.%NotDel%
			EndSql
		EndIf
	Else
		If !Empty(cProduto)
			BeginSql Alias cAliasQry
				SELECT COUNT(DISTINCT D14_PRODUT) TOT_PRODUT
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
				AND D14.D14_PRODUT <> %Exp:cProduto%
				AND D14.%NotDel%
			EndSql
		Else
			BeginSql Alias cAliasQry
				SELECT COUNT(DISTINCT D14_PRODUT) TOT_PRODUT
				FROM %Table:D14% D14
				WHERE D14.D14_FILIAL = %xFilial:D14%
				AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
				AND D14.%NotDel%
			EndSql
		EndIf
	EndIf
	TcSetField(cAliasQry,'TOT_PRODUT','N',10,0)
	If (cAliasQry)->(!Eof())
		lMisto := Iif(Empty(cProduto),((cAliasQry)->TOT_PRODUT > 1),((cAliasQry)->TOT_PRODUT > 0))
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lMisto
//-----------------------------------------------------------------------------
METHOD IsMultLot(cProduto,cLoteCtl,oTmpSldD14) CLASS WMSDTCMontagemUnitizador
Local lMisto     := .F.
Local aAreaAnt   := GetArea()
Local cWhere     := ""
Local cTmpSldD14 := ""
Local cAliasQry  := Nil
Default cProduto := ""
Default cLoteCtl := ""
	// Parâmetro Where
	cWhere := "%"
	If !Empty(cProduto)
		cWhere +=        " AND D14.D14_PRODUT <> '"+cProduto+"'"
	EndIf
	If !Empty(cLoteCtl)
		cWhere +=        " AND D14.D14_LOTECT <> '"+cLoteCtl+"'"
	EndIf
	cWhere += "%"
	cAliasQry := GetNextAlias()
	If oTmpSldD14 != Nil
		cTmpSldD14 := "%"+oTmpSldD14:GetRealName()+"%"
		BeginSql Alias cAliasQry
			SELECT COUNT(*) TOT_PRDLOT 
			FROM ( SELECT D14.D14_PRODUT,
							D14.D14_LOTECT
					FROM %Exp:cTmpSldD14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D14.%NotDel%
					%Exp:cWhere%
					GROUP BY D14.D14_PRODUT,
								D14.D14_LOTECT) TMP
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT COUNT(*) TOT_PRDLOT 
			FROM ( SELECT D14.D14_PRODUT,
							D14.D14_LOTECT
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.D14_IDUNIT = %Exp:Self:GetIdUnit()%
					AND D14.%NotDel%
					%Exp:cWhere%
					GROUP BY D14.D14_PRODUT,
								D14.D14_LOTECT) TMP
		EndSql
	EndIf
	TcSetField(cAliasQry,'TOT_PRDLOT','N',10,0)
	If (cAliasQry)->(!Eof())
		lMisto := ((cAliasQry)->TOT_PRDLOT > 1)
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lMisto
//-----------------------------------
// Method
//-----------------------------------
METHOD RecordD0R() CLASS WMSDTCMontagemUnitizador
Local lRet := .T.
Local lAchou := .F.

	If Self:oEtiqUnit:LoadData() .And. Self:oEtiqUnit:LockD0Y()
		// Atualiza status da etiqueta de unitizador
		Self:oEtiqUnit:SetTipUni(Self:GetTipUni())
		Self:oEtiqUnit:SetUsado("1")
		Self:oEtiqUnit:UpdateD0Y(.F.)
		
		// Grava D0R
		D0R->(dbSetOrder(1)) // D0R_FILIAL+D0R_LOCAL+D0R_ENDER+D0R_IDUNIT+D0R_IDDCF
		lAchou := D0R->(dbSeek(xFilial("D0R")+Self:GetArmazem()+Self:GetEnder()+Self:GetIdUnit()+Self:cIdDCF))
		Reclock("D0R",!lAchou)
		If !lAchou
			D0R->D0R_FILIAL := xFilial("D0R")
			D0R->D0R_LOCAL  := Self:GetArmazem()
			D0R->D0R_ENDER  := Self:GetEnder()
			D0R->D0R_IDUNIT := Self:GetIdUnit()
			D0R->D0R_CODUNI := Self:oTipUnit:GetTipUni()
			D0R->D0R_STATUS := Self:cStatus
			D0R->D0R_SERVIC := Self:cServico
			D0R->D0R_DATINI := Self:dDatIni
			D0R->D0R_HORINI := Self:cHorIni
			D0R->D0R_DATFIM := Iif(Empty(Self:dDatFim),dDataBase,Self:dDatFim)
			D0R->D0R_HORFIM := Iif(Empty(Self:cHorFim),Time(),Self:cHorFim)
			D0R->D0R_IDDCF  := Self:cIdDCF
		Else
			D0R->D0R_DATFIM := Iif(Empty(Self:dDatFim),dDataBase,Self:dDatFim)
			D0R->D0R_HORFIM := Iif(Empty(Self:cHorFim),Time(),Self:cHorFim)
		EndIf
		D0R->(MsUnLock())
		// Grava recno
		Self:nRecno := D0R->(Recno())
		// Libera lock
		Self:oEtiqUnit:UnLockD0Y()
	Else
	    Self:cErro :=  Self:oEtiqUnit:cerro 
		lRet := .F.
	EndIf
	
Return lRet
//----------------------------------------
/*/{Protheus.doc} UpdateD0R
Atualização dos dados D0R
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//----------------------------------------
METHOD UpdateD0R() CLASS WMSDTCMontagemUnitizador
Local lRet := .T.
	If !Empty(Self:GetRecno())
		D0R->(dbGoTo( Self:GetRecno() ))
		// Grava D0R
		RecLock('D0R', .F.)
		D0R->D0R_STATUS := Self:cStatus
		D0R->(dbCommit()) // Para forçar atualização do banco
		D0R->(MsUnLock())
	Else
		lRet := .F.
		Self:cErro := STR0001 // Recno inválido!
	EndIf
Return lRet
//----------------------------------------
METHOD ExcludeD0R() CLASS WMSDTCMontagemUnitizador
Local aAreaD0R := D0R->(GetArea())
Local lRet := .T.
	// Atualiza etiqueta
	If Self:oEtiqUnit:LoadData()
		Self:oEtiqUnit:SetTipUni("")
		Self:oEtiqUnit:SetUsado("2")
		Self:oEtiqUnit:UpdateD0Y()
		// Exclui montagem unitizador
		D0R->(dbGoTo( Self:nRecno ))
		// Exclui a ordem de serviço
		RecLock("D0R",.F.)
		D0R->(DbDelete())
		D0R->(MsUnlock())
		RestArea(aAreaD0R)
	EndIf
Return lRet
//----------------------------------------
METHOD ExcludeOS() CLASS WMSDTCMontagemUnitizador
Local lRet       := .T.
Local oOrdSerDel := WMSDTCOrdemServicoDelete():New()
	// Seta o IDDCF
	oOrdSerDel:SetIdDCF(Self:cIdDCF)
	// Efetua a carga de dados
	If oOrdSerDel:LoadData()
		// Verifica se pode excluir a ordem de serviço
		If oOrdSerDel:CanDelete(1)
			If !oOrdSerDel:DeleteDCF()
				Self:cErro := oOrdSerDel:GetErro()
				lRet := .F.
			EndIf
		Else
			Self:cErro := oOrdSerDel:GetErro()
			lRet := .F.
		EndIf
	EndIf
Return lRet
//----------------------------------------
METHOD UniHasItem() CLASS WMSDTCMontagemUnitizador
Local aAreaAnt := GetArea()
Local lRet := .F.

	D0S->(dbSetOrder(1))
	If D0S->(dbSeek(xFilial("D0S")+Self:GetIdUnit()))
		lRet := .T.
	EndIf
RestArea(aAreaAnt)
Return lRet
//----------------------------------------
METHOD UpdStatus() CLASS WMSDTCMontagemUnitizador
Local aAreaD0R := D0R->(GetArea())
Local aSx3Box := RetSx3Box(Posicione("SX3",2,"D0R_STATUS","X3CBox()"),,,1)
Local lRet := .T.
	If Empty(Self:cStatus) .Or. (aScan( aSx3Box, {|x| AllTrim(x[2]) == AllTrim(Self:cStatus)} )) == 0
		Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",Self:cStatus}}) // Erro ao atualizar status D0R. Status '[VAR01]' inválido!
		lRet := .F.
	EndIf
	If lRet
		D0R->(dbSetOrder(3))
		If D0R->(dbSeek( xFilial("D0R")+Self:GetIdUnit()))
			// Atualiza o status do unitizador
			RecLock("D0R",.F.)
			D0R->D0R_STATUS := Self:cStatus
			D0R->(MsUnlock())
		Else
			Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",Self:GetIdUnit()}}) // Unitizador [VAR01] não encontrado para atualização do status!
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaD0R)
Return lRet
