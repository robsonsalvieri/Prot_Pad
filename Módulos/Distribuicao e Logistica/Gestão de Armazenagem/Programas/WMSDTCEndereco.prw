#Include "Totvs.ch"
#Include "WMSDTCEndereco.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0019
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0019()
Return Nil
//-----------------------------------
/*/{Protheus.doc} WMSDTCEndereco
Classe endereço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------
CLASS WMSDTCEndereco FROM LongNameClass
	// Data
	DATA lHasNrUnit   // Utilizado para suavizar o campo BE_NRUNIT
	DATA cArmazem
	DATA cEndereco
	DATA cEstFis
	DATA nTipoEst
	DATA cPrior
	DATA cCodZona
	DATA cStatus
	DATA cCodCfg
	DATA cExcecao
	DATA cProduto
	DATA nValNv1
	DATA nValNv2
	DATA nValNv3
	DATA nValNv4
	DATA nValNv5
	DATA nValNv6
	DATA nCapacid
	DATA nAltura
	DATA nLargura
	DATA nComprim
	DATA nNrUnit
	DATA lArmzUnit
	DATA aExceptEnd AS Array
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cArmazAnt //Performance
	DATA cEnderAnt //Performance
	DATA aBE_CAPACID AS ARRAY
	DATA aBE_ALTURLC AS ARRAY
	DATA aBE_LARGLC AS ARRAY
	DATA aBE_COMPRLC AS ARRAY
	DATA aBE_NRUNIT AS ARRAY
	// Method
	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD LoadData(nIndex,lForca)
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEndereco)
	METHOD SetProduto(cProduto)
	METHOD SetEstFis(cEstFis)
	METHOD SetPrior(cPrior)
	METHOD SetCodZona(cCodZona)
	METHOD SetStatus(cStatus)
	METHOD SetCodCfg(cCodCfg)
	METHOD SetExcecao(cExcecao)
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetProduto()
	METHOD GetEstFis()
	METHOD GetTipoEst()
	METHOD GetPrior()
	METHOD GetCodZona()
	METHOD GetStatus()
	METHOD GetCodCfg()
	METHOD GetValNv1()
	METHOD GetValNv2()
	METHOD GetValNv3()
	METHOD GetValNv4()
	METHOD GetValNv5()
	METHOD GetValNv6()
	METHOD GetCapacid()
	METHOD GetAltura()
	METHOD GetLargura()
	METHOD GetComprim()
	METHOD GetNrUnit()
	METHOD GetCubagem()
	METHOD GetExcecao()
	METHOD GetArrExce()
	METHOD GetErro()
	METHOD ExceptEnd()
	METHOD IsArmzUnit()
	METHOD ChkEndInv()
	METHOD Destroy()
ENDCLASS
//-----------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-----------------------------------
METHOD New() CLASS WMSDTCEndereco
	Self:lHasNrUnit  := WmsX312120("SBE","BE_NRUNIT")
	Self:cArmazem    := PadR("", GetWmsSX3('BE_LOCAL', 1)) 
	Self:cEndereco   := PadR("", GetWmsSX3('BE_LOCALIZ', 1))
	Self:cArmazAnt   := PadR("", Len(Self:cArmazem))
	Self:cEnderAnt   := PadR("", Len(Self:cEndereco))
	Self:cEstFis     := PadR("", GetWmsSX3('BE_ESTFIS', 1)) 
	Self:cPrior      := PadR("", GetWmsSX3('BE_PRIOR', 1)) 
	Self:cCodZona    := PadR("", GetWmsSX3('BE_CODZON', 1))
	Self:cStatus     := PadR("", GetWmsSX3('BE_STATUS', 1))
	Self:cCodCfg     := PadR("", GetWmsSX3('BE_CODCFG', 1))
	Self:cExcecao    := PadR("", GetWmsSX3('BE_EXCECAO', 1))
	Self:cProduto    := PadR("", GetWmsSX3('BE_CODPRO', 1)) 
	Self:aBE_CAPACID := GetWmsSX3("BE_CAPACID")
	Self:aBE_ALTURLC := GetWmsSX3("BE_ALTURLC")
	Self:aBE_LARGLC  := GetWmsSX3("BE_LARGLC")
	Self:aBE_COMPRLC := GetWmsSX3("BE_COMPRLC")
	Self:aBE_NRUNIT  := IIf(Self:lHasNrUnit,GetWmsSX3("BE_NRUNIT"),{1,0})
	Self:ClearData()
Return
//-----------------------------------
/*/{Protheus.doc} ClearData
Atualiza o endereço
@author felipe.m
@since 23/01/2015
@version 1.0
/*/
//-----------------------------------
METHOD ClearData() CLASS WMSDTCEndereco
	Self:cArmazem   := PadR("", Len(Self:cArmazem))
	Self:cEndereco  := PadR("", Len(Self:cEndereco))
	Self:cArmazAnt  := PadR("", Len(Self:cArmazAnt))
	Self:cEnderAnt  := PadR("", Len(Self:cEnderAnt))
	Self:cEstFis    := PadR("", Len(Self:cEstFis))
	Self:cPrior     := PadR("", Len(Self:cPrior))
	Self:cCodZona   := PadR("", Len(Self:cCodZona))
	Self:cStatus    := PadR("", Len(Self:cStatus))
	Self:cCodCfg    := PadR("", Len(Self:cCodCfg))
	Self:cExcecao   := PadR("", Len(Self:cExcecao))
	Self:cProduto   := PadR("", Len(Self:cProduto))
	Self:nTipoEst   := 0
	Self:nValNv1    := 0
	Self:nValNv2    := 0
	Self:nValNv3    := 0
	Self:nValNv4    := 0
	Self:nValNv5    := 0
	Self:nValNv6    := 0
	Self:nCapacid   := 0
	Self:nAltura    := 0
	Self:nLargura   := 0
	Self:nComprim   := 0
	Self:nNrUnit    := 0
	Self:lArmzUnit  := Nil
	Self:aExceptEnd := {}
	Self:cErro      := ""
	Self:nRecno     := 0
Return Nil

METHOD Destroy() CLASS WMSDTCEndereco
//	FreeObj(Self)
Return Nil
//-----------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos daods SBE
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
@param lForca, Logico, (Indica se força a atualização das informações)
/*/
//-----------------------------------
METHOD LoadData(nIndex,lForca) CLASS WMSDTCEndereco
Local lRet     := .T.
Local lCarrega := .T.
Local aAreaAnt := GetArea()
Local aAreaSBE := SBE->(GetArea())
Local cAliasSBE:= Nil
Local cEndInv  := PadR('INVENTARIO',Len(Self:cEndereco))
Default nIndex := 1
Default lForca := .F.
	Do Case
		Case nIndex == 1 // BE_FILIAL+BE_LOCAL+BE_LOCALIZ
			If Empty(Self:cArmazem) .OR. Empty(Self:cEndereco)
				lRet := .F.
			Else
				//Se não mudou a chave não recarrega nada - Performance
				If !lForca .And. Self:cArmazem == Self:cArmazAnt .And. Self:cEndereco == Self:cEnderAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	ElseIf lCarrega
		cCmpNrUnit := IIf(Self:lHasNrUnit,"% SBE.BE_NRUNIT,%","% 0 BE_NRUNIT,%")
		cAliasSBE:= GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasSBE
					SELECT SBE.BE_LOCAL,
							%Exp:cCmpNrUnit%
							SBE.BE_LOCALIZ,
							SBE.BE_ESTFIS,
							SBE.BE_PRIOR,
							SBE.BE_CODZON,
							SBE.BE_STATUS,
							SBE.BE_CODCFG,
							SBE.BE_EXCECAO,
							SBE.BE_CODPRO,
							SBE.BE_VALNV1,
							SBE.BE_VALNV2,
							SBE.BE_VALNV3,
							SBE.BE_VALNV4,
							SBE.BE_VALNV5,
							SBE.BE_VALNV6,
							SBE.BE_CAPACID,
							SBE.BE_ALTURLC,
							SBE.BE_LARGLC,
							SBE.BE_COMPRLC,
							SBE.R_E_C_N_O_ RECNOSBE
					FROM %Table:SBE% SBE
					WHERE SBE.BE_FILIAL = %xFilial:SBE%
					AND SBE.BE_LOCAL = %Exp:Self:cArmazem%
					AND SBE.BE_LOCALIZ = %Exp:Self:cEndereco%
					AND SBE.%NotDel%
				EndSql
		EndCase
		TcSetField(cAliasSBE,'BE_CAPACID','N',Self:aBE_CAPACID[1],Self:aBE_CAPACID[2])
		TcSetField(cAliasSBE,'BE_ALTURLC','N',Self:aBE_ALTURLC[1],Self:aBE_ALTURLC[2])
		TcSetField(cAliasSBE,'BE_LARGLC' ,'N',Self:aBE_LARGLC[1],Self:aBE_LARGLC[2])
		TcSetField(cAliasSBE,'BE_COMPRLC','N',Self:aBE_COMPRLC[1],Self:aBE_COMPRLC[2])
		TcSetField(cAliasSBE,'BE_NRUNIT','N',Self:aBE_NRUNIT[1],Self:aBE_NRUNIT[2])
		If (lRet := (cAliasSBE)->(!Eof()))
			Self:cArmazem  := (cAliasSBE)->BE_LOCAL
			Self:cEndereco := (cAliasSBE)->BE_LOCALIZ
			Self:cEstFis   := (cAliasSBE)->BE_ESTFIS
			Self:cPrior    := (cAliasSBE)->BE_PRIOR
			Self:cCodZona  := (cAliasSBE)->BE_CODZON
			Self:cStatus   := (cAliasSBE)->BE_STATUS
			Self:cCodCfg   := (cAliasSBE)->BE_CODCFG
			Self:cExcecao  := (cAliasSBE)->BE_EXCECAO
			Self:cProduto  := (cAliasSBE)->BE_CODPRO
			Self:nValNv1   := (cAliasSBE)->BE_VALNV1
			Self:nValNv2   := (cAliasSBE)->BE_VALNV2
			Self:nValNv3   := (cAliasSBE)->BE_VALNV3
			Self:nValNv4   := (cAliasSBE)->BE_VALNV4
			Self:nValNv5   := (cAliasSBE)->BE_VALNV5
			Self:nValNv6   := (cAliasSBE)->BE_VALNV6
			Self:nCapacid  := (cAliasSBE)->BE_CAPACID
			Self:nAltura   := (cAliasSBE)->BE_ALTURLC
			Self:nLargura  := (cAliasSBE)->BE_LARGLC
			Self:nComprim  := (cAliasSBE)->BE_COMPRLC
			Self:nNrUnit   := (cAliasSBE)->BE_NRUNIT
			Self:nRecno    := (cAliasSBE)->RECNOSBE
			Self:lArmzUnit := Nil
			Self:nTipoEst  := 0
			If !(Self:cEndereco == cEndInv) .And. (Empty(Self:cEstFis) .Or. Empty(Self:cCodZona))
				Self:cErro := STR0002 // Endereço não destinado para produtos com controle WMS!
				lRet := .F.
			EndIf
			If lRet
				// Controle dados anteriores
				Self:cArmazAnt := Self:cArmazem
				Self:cEnderAnt := Self:cEndereco
			EndIf
		Else
			Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",AllTrim(Self:cArmazem)},{"[VAR02]",AllTrim(Self:cEndereco)}}) // Armazém [VAR01] e endereço [VAR02] não cadastrados!
		EndIf
		(cAliasSBE)->(dbCloseArea())
	EndIf
	RestArea(aAreaSBE)
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCEndereco
	If !(Self:cArmazem == cArmazem)
		Self:lArmzUnit := Nil
	EndIf
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return

METHOD SetEnder(cEndereco) CLASS WMSDTCEndereco
	Self:cEndereco := PadR(cEndereco, Len(Self:cEndereco))
Return

METHOD SetEstFis(cEstFis) CLASS WMSDTCEndereco
	Self:cEstFis := PadR(cEstFis, Len(Self:cEstFis))
Return

METHOD SetPrior(cPrior) CLASS WMSDTCEndereco
	Self:cPrior := PadR(cPrior, Len(Self:cPrior))
Return

METHOD SetCodZona(cCodZona) CLASS WMSDTCEndereco
	Self:cCodZona := PadR(cCodZona, Len(Self:cCodZona))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCEndereco
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetCodCfg(cCodCfg) CLASS WMSDTCEndereco
	Self:cCodCfg := PadR(cCodCfg, Len(Self:cCodCfg))
Return

METHOD SetExcecao(cExcecao) CLASS WMSDTCEndereco
	Self:cExcecao := PadR(cExcecao, Len(Self:cExcecao))
Return

METHOD SetProduto(cProduto) CLASS WMSDTCEndereco
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCEndereco
Return Self:cArmazem

METHOD GetEnder() CLASS WMSDTCEndereco
Return Self:cEndereco

METHOD GetEstFis() CLASS WMSDTCEndereco
Return Self:cEstFis

METHOD GetPrior() CLASS WMSDTCEndereco
Return Self:cPrior

METHOD GetCodZona() CLASS WMSDTCEndereco
Return Self:cCodZona

METHOD GetStatus() CLASS WMSDTCEndereco
Return Self:cStatus

METHOD GetCodCfg() CLASS WMSDTCEndereco
Return Self:cCodCfg

METHOD GetValNv1() CLASS WMSDTCEndereco
Return Self:nValNv1

METHOD GetValNv2() CLASS WMSDTCEndereco
Return Self:nValNv2

METHOD GetValNv3() CLASS WMSDTCEndereco
Return Self:nValNv3

METHOD GetValNv4() CLASS WMSDTCEndereco
Return Self:nValNv4

METHOD GetValNv5() CLASS WMSDTCEndereco
Return Self:nValNv5

METHOD GetValNv6() CLASS WMSDTCEndereco
Return Self:nValNv6

METHOD GetExcecao() CLASS WMSDTCEndereco
Return Self:cExcecao

METHOD GetProduto() CLASS WMSDTCEndereco
Return Self:cProduto

METHOD GetCapacid() CLASS WMSDTCEndereco
Return Self:nCapacid

METHOD GetAltura() CLASS WMSDTCEndereco
Return Self:nAltura

METHOD GetLargura() CLASS WMSDTCEndereco
Return Self:nLargura

METHOD GetComprim() CLASS WMSDTCEndereco
Return Self:nComprim

METHOD GetNrUnit() CLASS WMSDTCEndereco
Return Self:nNrUnit

METHOD GetCubagem() CLASS WMSDTCEndereco
Return (Self:nAltura * Self:nLargura * Self:nComprim)

METHOD GetArrExce() CLASS WMSDTCEndereco
Return Self:aExceptEnd

METHOD GetErro() CLASS WMSDTCEndereco
Return Self:cErro

METHOD GetTipoEst() CLASS WMSDTCEndereco
	// Carrega sob demanda
	If Self:nTipoEst <= 0
		Self:nTipoEst := DLTipoEnd(Self:cEstFis)
	EndIf
Return Self:nTipoEst

//-----------------------------------
/*/{Protheus.doc} ExceptEnd
Carrega o array de exeção a atividades
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-----------------------------------
METHOD ExceptEnd() CLASS WMSDTCEndereco
Local lRet      := .T.
Local aAreaSBE  := SBE->(GetArea())
Local cAliasDCL := GetNextAlias()
	Self:aExceptEnd := {}
	If Empty(Self:cArmazem) .OR. Empty(Self:cEstFis) .OR. Empty(Self:cEndereco)
		lRet := .F.
		Self:cErro := STR0001 // Dados para busca não foram informados!
	EndIf
	If lRet
		BeginSql Alias cAliasDCL
			SELECT DCL.DCL_ATIVID 
			FROM %Table:SBE% SBE
			INNER JOIN %table:DCL% DCL
			ON DCL.DCL_FILIAL = %xFilial:DCL%
			AND DCL.DCL_CODIGO = SBE.BE_EXCECAO
			AND DCL.%NotDel%
			WHERE SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = %Exp:Self:cArmazem%
			AND SBE.BE_ESTFIS = %Exp:Self:cEstFis%
			AND SBE.BE_LOCALIZ = %Exp:Self:cEndereco%
			AND SBE.%NotDel%
		EndSql
		Do While (cAliasDCL)->(!Eof())
			aAdd(Self:aExceptEnd, (cAliasDCL)->DCL_ATIVID)
			(cAliasDCL)->( dbSkip())
		EndDo
		(cAliasDCL)->(dbCloseArea())
	EndIf
	RestArea(aAreaSBE)
Return lRet
//-----------------------------------
/*/{Protheus.doc} IsArmzUnit
Indica que o armazém ao qual o endereço
pertence é unitizado
@author  Guilherme A. Metzger
@since   30/05/2017
@version 1.0
/*/
//-----------------------------------
METHOD IsArmzUnit() CLASS WMSDTCEndereco
	// Carrega sob demanda
	If Self:lArmzUnit == Nil
		If WmsX312118("NNR","NNR_AMZUNI",.T.) // Verifica no SX3
			Self:lArmzUnit := WmsArmUnit(Self:cArmazem) 
		Else
			Self:lArmzUnit := .F.
		EndIf
	EndIf
Return Self:lArmzUnit
//-----------------------------------
/*/{Protheus.doc} ChkEndInv
Carrega as informações do endereço de inventário
e valida se as informações de zona e estrutura física
estão corretas
@author  Squad WMS Protheus
@since   31/01/2019
@version 1.0
/*/
//-----------------------------------
METHOD ChkEndInv() CLASS WMSDTCEndereco
Local lRet    := .T.
	If Empty(Self:cArmazem)
		Self:cErro := STR0004 // Armazem não informado! 
		lRet := .F.
	EndIf
	If lRet .And. Empty(Self:cEndereco)
		Self:cErro := STR0008 // Endereço não informado! 
		lRet := .F.
	EndIf
	
	If lRet
		If Self:LoadData()
			If Empty(Self:cCodZona)
				Self:cErro := WmsFmtMsg(STR0005,{{"[VAR01]",AllTrim(Self:cArmazem)}}) // Endereço INVENTARIO no armazem [VAR01] sem zona de armazenagem definida!
				lRet := .F.
			EndIf
			If Empty(Self:cEstFis)
				Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",AllTrim(Self:cArmazem)}}) // Endereço INVENTARIO no armazem [VAR01] sem estrutura física definida!
				lRet := .F.
			EndIf
		Else
			Self:cErro := WmsFmtMsg(STR0007,{{"[VAR01]",AllTrim(Self:cArmazem)}}) // Endereço INVENTARIO não definido no armazem [VAR01]!
			lRet := .F.
		EndIf
	EndIf
Return lRet