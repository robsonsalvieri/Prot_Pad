#Include "Totvs.ch"
#Include "WMSDTCProdutoDadosAdicionais.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0036
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0036()
Return Nil
//------------------------------------------------
/*/{Protheus.doc} WMSDTCProdutoDadosAdicionais
Classe dados adicionais do produto
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//------------------------------------------------
CLASS WMSDTCProdutoDadosAdicionais FROM LongNameClass
	// Data
	DATA oProdGen
	DATA oProdComp
	DATA cCodZona
	DATA cEndPadrao
	DATA cEndereco
	DATA cNumSerie
	DATA cCtrlWms
	DATA cCategoria
	DATA cWmsEmb
	DATA cUMIndust
	DATA cServEmb
	DATA cServTran
	DATA cServTrDv
	DATA cServEnt
	DATA cEnderEnt
	DATA cServSai
	DATA cEnderSai
	DATA cSerRequis
	DATA cEndRequis
	DATA cSerDevol
	DATA cEndDevol
	DATA cSerEntCD
	DATA cEndEntCD
	DATA cSerSaiCD
	DATA cEndSaiCD
	DATA cArreQtd
	DATA aArrProd
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD ClearData()
	METHOD SetProduto(cProduto)
	METHOD SetCodZona(cCodZona)
	METHOD CreateArr()
	METHOD GetCodZona()
	METHOD GetEnder()
	METHOD GetNumSeri()
	METHOD GetCtrlWMS()
	METHOD GetCateg()
	METHOD GetWmsEmb()
	METHOD GetUMInd()
	METHOD GetSerEmb()
	METHOD GetSerTran()
	METHOD GetSerTrDv()
	METHOD GetSerEnt()
	METHOD GetEndEnt()
	METHOD GetSerSai()
	METHOD GetEndSai()
	METHOD GetSerReq()
	METHOD GetEndReq()
	METHOD GetSerDev()
	METHOD GetEndDev()
	METHOD GetSerECD()
	METHOD GetEndECD()
	METHOD GetSerSCD()
	METHOD GetEndSCD()
	METHOD GetArreQtd()
	// Refente aos dados genéricos do produto
	METHOD GetProduto()
	METHOD GetDesc()
	METHOD GetTipo()
	METHOD GetUM()
	METHOD GetArmPadr()
	METHOD GetGrupo()
	METHOD GetSegum()
	METHOD GetConv()
	METHOD GetTipConv()
	METHOD GetFamilia()
	METHOD GetRastro()
	METHOD GetCtrlEnd()
	METHOD GetCodNor()
	METHOD GetCodBar()
	METHOD GetProdCol()
	METHOD HasRastro()
	METHOD HasRastSub()
	METHOD GetErro()
	METHOD GetRecno()
	METHOD GetArrProd()
	METHOD IsCtrWms()
	METHOD Destroy()
ENDCLASS
//------------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD New() CLASS WMSDTCProdutoDadosAdicionais
	Self:oProdGen   := WMSDTCProdutoDadosGenericos():New()
	Self:oProdComp  := WMSDTCProdutoComponente():New()
	Self:cCodZona   := PadR("", GetWmsSX3("B5_CODZON", 1))
	Self:cEndPadrao := PadR("", GetWmsSX3("B5_LOCALIZ", 1))
	Self:cNumSerie  := PadR("", GetWmsSX3("B5_NSERIE", 1))
	Self:cCategoria := PadR("", GetWmsSX3("B5_CATEG", 1))
	Self:cUMIndust  := PadR("", GetWmsSX3("B5_UMIND", 1))
	Self:cServEmb   := PadR("", GetWmsSX3("B5_SERVEMB", 1))
	Self:cServTran  := PadR("", GetWmsSX3("B5_SERVINT", 1))
	Self:cServTrDv  := PadR("", GetWmsSX3("B5_SERVTDV", 1))
	Self:cServEnt   := PadR("", GetWmsSX3("B5_SERVENT", 1))
	Self:cEnderEnt  := PadR("", GetWmsSX3("B5_ENDENT", 1))
	Self:cServSai   := PadR("", GetWmsSX3("B5_SERVSAI", 1))
	Self:cEnderSai  := PadR("", GetWmsSX3("B5_ENDSAI", 1))
	Self:cSerRequis := PadR("", GetWmsSX3("B5_SERVREQ", 1))
	Self:cEndRequis := PadR("", GetWmsSX3("B5_ENDREQ", 1))
	Self:cSerDevol  := PadR("", GetWmsSX3("B5_SERVDEV", 1))
	Self:cEndDevol  := PadR("", GetWmsSX3("B5_ENDDEV", 1))
	Self:cSerEntCD  := PadR("", GetWmsSX3("B5_SERECD", 1))
	Self:cEndEntCD  := PadR("", GetWmsSX3("B5_ENDECD", 1))
	Self:cSerSaiCD  := PadR("", GetWmsSX3("B5_SERSCD", 1))
	Self:cEndSaiCD  := PadR("", GetWmsSX3("B5_ENDSCD", 1))
	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCProdutoDadosAdicionais
	Self:oProdGen:ClearData()
	Self:oProdComp:ClearData()
	Self:cEndPadrao := PadR("", Len(Self:cEndPadrao))
	Self:cNumSerie  := PadR("", Len(Self:cNumSerie))
	Self:cCategoria := PadR("", Len(Self:cCategoria))
	Self:cUMIndust  := PadR("", Len(Self:cUMIndust))
	Self:cServEmb   := PadR("", Len(Self:cServEmb))
	Self:cServTran  := PadR("", Len(Self:cServTran))
	Self:cServTrDv  := PadR("", Len(Self:cServTrDv))
	Self:cServEnt   := PadR("", Len(Self:cServEnt))
	Self:cEnderEnt  := PadR("", Len(Self:cEnderEnt))
	Self:cServSai   := PadR("", Len(Self:cServSai))
	Self:cEnderSai  := PadR("", Len(Self:cEnderSai))
	Self:cSerRequis := PadR("", Len(Self:cSerRequis))
	Self:cEndRequis := PadR("", Len(Self:cEndRequis))
	Self:cSerDevol  := PadR("", Len(Self:cSerDevol))
	Self:cEndDevol  := PadR("", Len(Self:cEndDevol))
	Self:cSerEntCD  := PadR("", Len(Self:cSerEntCD))
	Self:cEndEntCD  := PadR("", Len(Self:cEndEntCD))
	Self:cSerSaiCD  := PadR("", Len(Self:cSerSaiCD))
	Self:cEndSaiCD  := PadR("", Len(Self:cEndSaiCD))
	Self:cWmsEmb    := "2" // Não utiliza por Default
	Self:cCtrlWMS   := Nil
	Self:cArreQtd   := "2"
	Self:cErro      := ""
	Self:aArrProd   := {}
	Self:nRecno     := 0
Return Nil

METHOD Destroy() CLASS WMSDTCProdutoDadosAdicionais
	//FreeObj(Self)
Return Nil
//------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados SB5
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCProdutoDadosAdicionais
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aAreaSB5 := SB5->(GetArea())
Local cAliasSB5:= Nil
Default nIndex := 1
	Do Case
		Case nIndex == 1 // B5_FILIAL+B5_COD
			If Empty(Self:GetProduto())
				lRet := .F.
			Endif
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If Self:oProdGen:LoadData()
			cAliasSB5:= GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasSB5
						SELECT SB5.B5_COD,
								SB5.B5_CODZON,
								SB5.B5_LOCALIZ,
								SB5.B5_NSERIE,
								SB5.B5_CATEG,
								SB5.B5_WMSEMB,
								SB5.B5_UMIND,
								SB5.B5_SERVEMB,
								SB5.B5_SERVINT,
								SB5.B5_SERVTDV,
								SB5.B5_SERVENT,
								SB5.B5_ENDENT,
								SB5.B5_SERVSAI,
								SB5.B5_ENDSAI,
								SB5.B5_SERVREQ,
								SB5.B5_ENDREQ,
								SB5.B5_SERVDEV,
								SB5.B5_ENDDEV,
								SB5.B5_SERECD,
								SB5.B5_ENDECD,
								SB5.B5_SERSCD,
								SB5.B5_ENDSCD,
								SB5.B5_ARREQTD,
								SB5.R_E_C_N_O_ RECNOSB5
						FROM %Table:SB5% SB5
						WHERE SB5.B5_FILIAL = %xFilial:SB5%
						AND SB5.B5_COD = %Exp:Self:GetProduto()%
						AND SB5.%NotDel%
					EndSql
			EndCase
			If (lRet := (cAliasSB5)->(!Eof()))
				Self:SetProduto((cAliasSB5)->B5_COD)
				Self:cCodZona   := (cAliasSB5)->B5_CODZON
				Self:cEndPadrao := (cAliasSB5)->B5_LOCALIZ
				Self:cNumSerie  := (cAliasSB5)->B5_NSERIE
				Self:cCtrlWMS   := Nil
				Self:cCategoria := (cAliasSB5)->B5_CATEG
				Self:cWmsEmb    := IIf(Empty((cAliasSB5)->B5_WMSEMB),"2",(cAliasSB5)->B5_WMSEMB)
				Self:cUMIndust  := (cAliasSB5)->B5_UMIND
				Self:cServEmb   := (cAliasSB5)->B5_SERVEMB
				Self:cServTran  := (cAliasSB5)->B5_SERVINT
				Self:cServTrDv  := (cAliasSB5)->B5_SERVTDV
				Self:cServEnt   := (cAliasSB5)->B5_SERVENT
				Self:cEnderEnt  := (cAliasSB5)->B5_ENDENT
				Self:cServSai   := (cAliasSB5)->B5_SERVSAI
				Self:cEnderSai  := (cAliasSB5)->B5_ENDSAI
				Self:cSerRequis := (cAliasSB5)->B5_SERVREQ
				Self:cEndRequis := (cAliasSB5)->B5_ENDREQ
				Self:cSerDevol  := (cAliasSB5)->B5_SERVDEV
				Self:cEndDevol  := (cAliasSB5)->B5_ENDDEV
				Self:cSerEntCD  := (cAliasSB5)->B5_SERECD
				Self:cEndEntCD  := (cAliasSB5)->B5_ENDECD
				Self:cSerSaiCD  := (cAliasSB5)->B5_SERSCD
				Self:cEndSaiCD  := (cAliasSB5)->B5_ENDSCD
				Self:cArreQtd   := (cAliasSB5)->B5_ARREQTD
				Self:nRecno     := (cAliasSB5)->RECNOSB5
				Self:CreateArr()
			Else
				Self:cErro := STR0002 // Produto não cadastrados no cadastros de dados adicionais do produto (SB5)!
			EndIf
			(cAliasSB5)->(dbCloseArea())
		Else
			lRet := .F.
			Self:cErro := Self:oProdGen:GetErro()
		EndIf
	EndIf
	RestArea(aAreaSB5)
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------
// Setters
//------------------------------------------------
METHOD SetProduto(cProduto) CLASS WMSDTCProdutoDadosAdicionais
	Self:oProdGen:SetProduto(cProduto)
Return

METHOD SetCodZona(cCodZona) CLASS WMSDTCProdutoDadosAdicionais
	Self:cCodZona := PadR(cCodZona, Len(Self:cCodZona))
Return
//------------------------------------------------
// Getters
//------------------------------------------------
METHOD GetCodZona() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cCodZona

METHOD GetEnder() CLASS WMSDTCProdutoDadosAdicionais
Return Self:EndPadrao

METHOD GetNumSeri() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cNumSerie

METHOD GetCtrlWMS() CLASS WMSDTCProdutoDadosAdicionais
	dbSelectArea("SB1")
	If Self:cCtrlWms == Nil
		Self:cCtrlWms := IIf(IntWMS(Self:GetProduto()),"1","2")
	EndIf
Return Self:cCtrlWMS

METHOD GetCateg() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cCategoria

METHOD GetWmsEmb() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cWmsEmb

METHOD GetUMInd() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cUMIndust

METHOD GetSerEmb() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cServEmb

METHOD GetSerTran() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cServTran

METHOD GetSerTrDv() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cServTrDv

METHOD GetSerEnt() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cServEnt

METHOD GetEndEnt() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cEnderEnt

METHOD GetSerSai() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cServSai

METHOD GetEndSai() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cEnderSai

METHOD GetSerReq() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cSerRequis

METHOD GetEndReq() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cEndRequis

METHOD GetSerDev() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cSerDevol

METHOD GetEndDev() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cEndDevol

METHOD GetSerECD() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cSerEntCD

METHOD GetEndECD() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cEndEntCD

METHOD GetSerSCD() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cSerSaiCD

METHOD GetEndSCD() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cEndSaiCD

METHOD GetArreQtd() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cArreQtd

METHOD GetArrProd() CLASS WMSDTCProdutoDadosAdicionais
Return Self:aArrProd
// Referentes ao Dados Genéricos
METHOD GetProduto() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetProduto()

METHOD GetDesc() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetDesc()

METHOD GetTipo() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetTipo()

METHOD GetUM() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetUM()

METHOD GetArmPadr() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetArmPadr()

METHOD GetGrupo() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetGrupo()

METHOD GetSegum() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetSegum()

METHOD GetConv() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetConv()

METHOD GetTipConv() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetTipConv()

METHOD GetFamilia() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetFamilia()

METHOD GetRastro() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetRastro()

METHOD GetCtrlEnd() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetCtrlEnd()

METHOD GetCodNor() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetCodNor()

METHOD GetCodBar() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetCodBar()

METHOD GetProdCol() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:GetProdCol()

METHOD HasRastro() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:HasRastro()

METHOD HasRastSub() CLASS WMSDTCProdutoDadosAdicionais
Return Self:oProdGen:HasRastSub()

METHOD GetRecno() CLASS WMSDTCProdutoDadosAdicionais
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCProdutoDadosAdicionais
Return Self:cErro
//------------------------------------------------
/*/{Protheus.doc} CreateArr
Carrega o array de partes do produto
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD CreateArr() CLASS WMSDTCProdutoDadosAdicionais
Local lRet := .T.
	Self:aArrProd := {}

	// Carrega estrutura do produto x componente
	Self:oProdComp:SetProduto(Self:GetProduto())
	Self:oProdComp:SetPrdOri(Self:GetProduto())
	Self:oProdComp:EstProduto()

	Self:aArrProd := Self:oProdComp:GetArrProd()
Return lRet
//------------------------------------------------
/*/{Protheus.doc} IsCtrWms
Retorno lógico se o produto controla WMS
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD IsCtrWms() CLASS WMSDTCProdutoDadosAdicionais
Return Self:GetCtrlWMS() == "1"