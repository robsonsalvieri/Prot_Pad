#Include "Totvs.ch"
#Include "WMSDTCProdutoDadosGenericos.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0037
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0037()
Return Nil
//------------------------------------------------
/*/{Protheus.doc} WMSDTCProdutoDadosGenericos
Classe dados genericos do produto
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//------------------------------------------------
CLASS WMSDTCProdutoDadosGenericos FROM LongNameClass
	// Data
	DATA cProduto
	DATA cDesc
	DATA cTipo
	DATA cUM
	DATA cArmPadrao
	DATA cGrupo
	DATA cSegum
	DATA nConv
	DATA cTipConv
	DATA cFamilia
	DATA cRastro
	DATA cCtrlEnd
	DATA cCodNorma
	DATA cCodBarra
	DATA cCC
	DATA lRastro
	DATA lRastSub
	DATA lMsBlQl
	DATA aB1_CONV AS ARRAY
	DATA nRecno
	DATA cErro
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD ClearData()
	METHOD SetProduto(cProduto)
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
	METHOD GetCC()
	METHOD HasRastro()
	METHOD HasRastSub()
	METHOD IsMsBlQl()
	METHOD ChkFatConv()
	METHOD SelectFtCn(lProcess,cArmazem,cProduto)
	METHOD RemFatConv(cArmazem, cProduto)
	METHOD GetErro()
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
METHOD New() CLASS WMSDTCProdutoDadosGenericos
	Self:cProduto   := PadR("", GetWmsSX3("B1_COD", 1))
	Self:cUM        := PadR("", GetWmsSX3("B1_UM", 1))
	Self:cDesc      := PadR("", GetWmsSX3("B1_DESC", 1))
	Self:cTipo      := PadR("", GetWmsSX3("B1_TIPO", 1))
	Self:cArmPadrao := PadR("", GetWmsSX3("B1_LOCPAD", 1))
	Self:cGrupo     := PadR("", GetWmsSX3("B1_GRUPO", 1))
	Self:cSegum     := PadR("", GetWmsSX3("B1_SEGUM", 1))
	Self:cTipConv   := PadR("", GetWmsSX3("B1_TIPCONV", 1))
	Self:cFamilia   := PadR("", GetWmsSX3("B1_FAMILIA", 1))
	Self:cRastro    := PadR("", GetWmsSX3("B1_RASTRO", 1))
	Self:cCodNorma  := PadR("", GetWmsSX3("B1_CODNOR", 1))
	Self:cCodBarra  := PadR("", GetWmsSX3("B1_CODBAR", 1))
	Self:cCC        := PadR("", GetWmsSX3("B1_CC", 1))
	Self:aB1_CONV   := GetWmsSX3('B1_CONV')
	Self:ClearData()
Return

METHOD ClearData() CLASS WMSDTCProdutoDadosGenericos
	Self:cProduto   := PadR("", Len(Self:cProduto))
	Self:cUM        := PadR("", Len(Self:cUM))
	Self:cDesc      := PadR("", Len(Self:cDesc))
	Self:cTipo      := PadR("", Len(Self:cTipo))
	Self:cArmPadrao := PadR("", Len(Self:cArmPadrao))
	Self:cGrupo     := PadR("", Len(Self:cGrupo))
	Self:cSegum     := PadR("", Len(Self:cSegum))
	Self:cTipConv   := PadR("", Len(Self:cTipConv))
	Self:cFamilia   := PadR("", Len(Self:cFamilia))
	Self:cRastro    := PadR("", Len(Self:cRastro))
	Self:cCodNorma  := PadR("", Len(Self:cCodNorma))
	Self:cCodBarra  := PadR("", Len(Self:cCodBarra))
	Self:cCC        := PadR("", Len(Self:cCC))
	Self:nConv      := 0
	Self:cCtrlEnd   := Nil
	Self:lRastro    := .F.
	Self:lRastSub   := .F.
	Self:lMsBlQl    := .T.
	Self:cErro      := ""
	Self:nRecno     := 0
Return Nil

METHOD Destroy() CLASS WMSDTCProdutoDadosGenericos
	//Mantido para compatibilidade
Return
//------------------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados SB1
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//------------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCProdutoDadosGenericos
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local cAliasSB1:= Nil
Default nIndex := 1
	Do Case
		Case nIndex == 1 // B1_FILIAL+B1_COD
			If Empty(Self:cProduto)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cAliasSB1:= GetNextAlias()
		Do Case
			Case nIndex == 1
				BeginSql Alias cAliasSB1
					SELECT SB1.B1_COD,
							SB1.B1_UM,
							SB1.B1_DESC,
							SB1.B1_TIPO,
							SB1.B1_LOCPAD,
							SB1.B1_GRUPO,
							SB1.B1_SEGUM,
							SB1.B1_CONV,
							SB1.B1_TIPCONV,
							SB1.B1_FAMILIA,
							SB1.B1_RASTRO,
							SB1.B1_CODNOR,
							SB1.B1_CODBAR,
							SB1.B1_CC,
							SB1.B1_MSBLQL,
							SB1.R_E_C_N_O_ RECNOSB1
					FROM %Table:SB1% SB1
					WHERE SB1.B1_FILIAL = %xFilial:SB1%
					AND SB1.B1_COD = %Exp:Self:GetProduto()%
					AND SB1.%NotDel%
				EndSql
		EndCase
		TCSetField(cAliasSB1,'B1_CONV','N',Self:aB1_CONV[1],Self:aB1_CONV[2])
		lRet := (cAliasSB1)->(!Eof())
		If lRet
			Self:SetProduto((cAliasSB1)->B1_COD)
			Self:cUM        := (cAliasSB1)->B1_UM
			Self:cDesc      := (cAliasSB1)->B1_DESC
			Self:cTipo      := (cAliasSB1)->B1_TIPO
			Self:cArmPadrao := (cAliasSB1)->B1_LOCPAD
			Self:cGrupo     := (cAliasSB1)->B1_GRUPO
			Self:cSegum     := (cAliasSB1)->B1_SEGUM
			Self:nConv      := (cAliasSB1)->B1_CONV
			Self:cTipConv   := (cAliasSB1)->B1_TIPCONV
			Self:cFamilia   := (cAliasSB1)->B1_FAMILIA
			Self:cRastro    := (cAliasSB1)->B1_RASTRO
			Self:cCodNorma  := (cAliasSB1)->B1_CODNOR
			Self:cCodBarra  := (cAliasSB1)->B1_CODBAR
			Self:cCC        := (cAliasSB1)->B1_CC
			Self:cCtrlEnd   := Nil
			Self:lRastro    := (cAliasSB1)->B1_RASTRO == "L" .Or.  (cAliasSB1)->B1_RASTRO == "S"
			Self:lRastSub   := (cAliasSB1)->B1_RASTRO == "S"
			Self:lMsBlQl    := (cAliasSB1)->B1_MSBLQL == "1"
			Self:nRecno     := (cAliasSB1)->RECNOSB1
		Else
			Self:cErro := STR0002 // Produto não cadastrado (SB1)!
		EndIf
		(cAliasSB1)->(dbCloseArea())
	EndIf
	RestArea(aAreaSB1)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetProduto(cProduto) CLASS WMSDTCProdutoDadosGenericos
	Self:cProduto := Padr(cProduto, Len(Self:cProduto))
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetProduto() CLASS WMSDTCProdutoDadosGenericos
Return Self:cProduto

METHOD GetDesc() CLASS WMSDTCProdutoDadosGenericos
Return Self:cDesc

METHOD GetTipo() CLASS WMSDTCProdutoDadosGenericos
Return Self:cTipo

METHOD GetUM() CLASS WMSDTCProdutoDadosGenericos
Return Self:cUM

METHOD GetArmPadr() CLASS WMSDTCProdutoDadosGenericos
Return Self:cArmPadrao

METHOD GetGrupo() CLASS WMSDTCProdutoDadosGenericos
Return Self:cGrupo

METHOD GetSegum() CLASS WMSDTCProdutoDadosGenericos
Return Self:cSegum

METHOD GetConv() CLASS WMSDTCProdutoDadosGenericos
Return Self:nConv

METHOD GetTipConv() CLASS WMSDTCProdutoDadosGenericos
Return Self:cTipConv

METHOD GetFamilia() CLASS WMSDTCProdutoDadosGenericos
Return Self:cFamilia

METHOD GetRastro() CLASS WMSDTCProdutoDadosGenericos
Return Self:cRastro

METHOD GetCtrlEnd() CLASS WMSDTCProdutoDadosGenericos
	dbSelectArea("SB1")
	If Self:cCtrlEnd == Nil
		Self:cCtrlEnd := IIf(Localiza(Self:GetProduto(),.T.),"1","2")
	EndIf
Return Self:cCtrlEnd

METHOD GetCodNor() CLASS WMSDTCProdutoDadosGenericos
Return Self:cCodNorma

METHOD GetCodBar() CLASS WMSDTCProdutoDadosGenericos
Return Self:cCodBarra

METHOD GetCC() CLASS WMSDTCProdutoDadosGenericos
Return Self:cCC

METHOD HasRastro() CLASS WMSDTCProdutoDadosGenericos
Return Self:lRastro

METHOD HasRastSub() CLASS WMSDTCProdutoDadosGenericos
Return Self:lRastSub

METHOD IsMsBlQl() CLASS WMSDTCProdutoDadosGenericos
Return Self:lMsBlQl

METHOD GetErro() CLASS WMSDTCProdutoDadosGenericos
Return Self:cErro

METHOD GetProdCol() CLASS WMSDTCProdutoDadosGenericos
	If !SuperGetMv("MV_WMSCODP",.F.,.T.)
		Return Self:GetCodBar()
	EndIf
Return Self:GetProduto()

METHOD ChkFatConv() CLASS WMSDTCProdutoDadosGenericos
Local lRet := .T.
	If !Empty(Self:cSegum)
		If Empty(Self:nConv) .Or. QtdComp(Self:nConv) <= QtdComp(0)
			Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",Self:cProduto}}) // Produto [VAR01] possui segunda unidade de medida e o fator de conversão está vazio!
			lRet := .F.
		EndIf
	ElseIf !Empty(Self:nConv) .And. QtdComp(Self:nConv) > QtdComp(0)
			Self:cErro := WmsFmtMsg(STR0004,{{"[VAR01]",Self:cProduto}}) // Produto [VAR01] possui fator de conversão e segunda unidade está vazio!
			lRet := .F.
	EndIf
Return lRet

METHOD SelectFtCn(lProcess,cArmazem,cProduto) CLASS WMSDTCProdutoDadosGenericos
Local cAliasQry  := Nil
Local cWhereD14  := ""
Local cWhereD13  := ""
Local cWhereD15  := ""
Local cWhereD0G  := ""
Local cWhereDCF  := ""
Local cWhereD12  := ""
Local cWhereD07  := ""
Local cWhereD08  := ""
Local cWhereD09  := ""
Local cWhereD0F  := ""
Local cWhereD0M  := ""

Default lProcess := .T.
	// Estoque por endereço (D14)
	cAliasQry := GetNextAlias()
	// Clausula Where
	If !Empty(cArmazem)
		cWhereD14 += " AND D14.D14_LOCAL = '"+cArmazem+"'"
		cWhereD13 += " AND D13.D13_LOCAL = '"+cArmazem+"'"
		cWhereD15 += " AND D15.D15_LOCAL = '"+cArmazem+"'"
		cWhereD0G += " AND D0G.D0G_LOCAL = '"+cArmazem+"'"
		cWhereDCF += " AND DCF.DCF_LOCAL = '"+cArmazem+"'"
		cWhereD12 += " AND D12.D12_LOCORI = '"+cArmazem+"'"
		cWhereD07 += " AND D07.D07_LOCAL = '"+cArmazem+"'"
		cWhereD08 += " AND D08.D08_LOCAL = '"+cArmazem+"'"
		cWhereD09 += " AND D09.D09_LOCAL = '"+cArmazem+"'"
		cWhereD0F += " AND D0F.D0F_LOCAL = '"+cArmazem+"'"
		cWhereD0M += " AND D0M.D0M_LOCAL = '"+cArmazem+"'"
	EndIf
	If !Empty(cProduto)
		cWhereD14 += " AND D14.D14_PRODUT = '"+cProduto+"'"
		cWhereD13 += " AND D13.D13_PRODUT = '"+cProduto+"'"
		cWhereD15 += " AND D15.D15_PRODUT = '"+cProduto+"'"
		cWhereD0G += " AND D0G.D0G_PRODUT = '"+cProduto+"'"
		cWhereDCF += " AND DCF.DCF_CODPRO = '"+cProduto+"'"
		cWhereD12 += " AND D12.D12_PRODUT = '"+cProduto+"'"
		cWhereD07 += " AND D07.D07_PRODUT = '"+cProduto+"'"
		cWhereD08 += " AND D08.D08_PRODUT = '"+cProduto+"'"
		cWhereD09 += " AND D09.D09_PRODUT = '"+cProduto+"'"
		cWhereD0F += " AND D0F.D0F_PRODUT = '"+cProduto+"'"
		cWhereD0M += " AND D0M.D0M_PRODUT = '"+cProduto+"'"
	EndIf
	cWhereD14 := "%"+cWhereD14+"%
	cWhereD13 := "%"+cWhereD13+"%
	cWhereD15 := "%"+cWhereD15+"%
	cWhereD0G := "%"+cWhereD0G+"%
	cWhereDCF := "%"+cWhereDCF+"%
	cWhereD12 := "%"+cWhereD12+"%
	cWhereD07 := "%"+cWhereD07+"%
	cWhereD08 := "%"+cWhereD08+"%
	cWhereD09 := "%"+cWhereD09+"%
	cWhereD0F := "%"+cWhereD0F+"%
	cWhereD0M := "%"+cWhereD0M+"%

	If lProcess
		BeginSql Alias cAliasQry
			SELECT 'D14' ALIASQRY,
					D14.R_E_C_N_O_ RECNOQRY
			FROM %Table:D14% D14
			WHERE D14.D14_FILIAL = %xFilial:D14%
			AND D14.%NotDel%
			%Exp:cWhereD14%
			UNION ALL
			SELECT 'D13' ALIASQRY,
					D13.R_E_C_N_O_ RECNOQRY
			FROM %Table:D13% D13
			WHERE D13.D13_FILIAL = %xFilial:D13%
			AND D13.%NotDel%
			%Exp:cWhereD13%
			UNION ALL
			SELECT 'D15' ALIASQRY,
					D15.R_E_C_N_O_ RECNOQRY
			FROM %Table:D15% D15
			WHERE D15.D15_FILIAL = %xFilial:D15%
			AND D15.%NotDel%
			%Exp:cWhereD15%
			UNION ALL
			SELECT 'D0G' ALIASQRY,
					D0G.R_E_C_N_O_ RECNOQRY
			FROM %Table:D0G% D0G
			WHERE D0G.D0G_FILIAL = %xFilial:D0G%
			AND D0G.%NotDel%
			%Exp:cWhereD0G%
			UNION ALL
			SELECT 'DCF' ALIASQRY,
					DCF.R_E_C_N_O_ RECNOQRY
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.%NotDel%
			%Exp:cWhereDCF%
			UNION ALL
			SELECT 'D12' ALIASQRY,
					D12.R_E_C_N_O_ RECNOQRY
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.%NotDel%
			%Exp:cWhereD12%
			UNION ALL
			SELECT 'DCR' ALIASQRY,
					DCR.R_E_C_N_O_ RECNOQRY
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.%NotDel%
			%Exp:cWhereD12%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			AND DCR.%NotDel%
			UNION ALL
			SELECT 'D07' ALIASQRY,
					D07.R_E_C_N_O_ RECNOQRY
			FROM %Table:D07% D07
			WHERE D07.D07_FILIAL = %xFilial:D07%
			AND D07.%NotDel%
			%Exp:cWhereD07%
			UNION ALL
			SELECT 'D08' ALIASQRY,
					D08.R_E_C_N_O_ RECNOQRY
			FROM %Table:D08% D08
			WHERE D08.D08_FILIAL = %xFilial:D08%
			AND D08.%NotDel%
			%Exp:cWhereD08%
			UNION ALL
			SELECT 'D09' ALIASQRY,
					D09.R_E_C_N_O_ RECNOQRY
			FROM %Table:D09% D09
			WHERE D09.D09_FILIAL = %xFilial:D09%
			AND D09.%NotDel%
			%Exp:cWhereD09%
			UNION ALL
			SELECT 'D0F' ALIASQRY,
					D0F.R_E_C_N_O_ RECNOQRY
			FROM %Table:D0F% D0F
			WHERE D0F.D0F_FILIAL = %xFilial:D0F%
			AND D0F.%NotDel%
			%Exp:cWhereD0F%
			UNION ALL
			SELECT 'D0M' ALIASQRY,
					D0M.R_E_C_N_O_ RECNOQRY
			FROM %Table:D0M% D0M
			WHERE D0M.D0M_FILIAL = %xFilial:D0M%
			AND D0M.%NotDel%
			%Exp:cWhereD0M%
			UNION ALL
			SELECT 'D0P' ALIASQRY,
					D0P.R_E_C_N_O_ RECNOQRY
			FROM %Table:D0P% D0P
			INNER JOIN %Table:D0M% D0M
			ON D0M.D0M_FILIAL = %xFilial:D0M%
			AND D0M.D0M_CODPLN = D0P.D0P_CODPLN
			AND D0M.D0M_ITEM = D0P.D0P_ITEM
			AND D0M.%NotDel%
			%Exp:cWhereD0M%
			WHERE D0P.D0P_FILIAL = %xFilial:D0P%
			AND D0P.%NotDel%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT COUNT(*) NR_COUNT
			FROM (SELECT 'D14' ALIASQRY,
							D14.R_E_C_N_O_ RECNOQRY
					FROM %Table:D14% D14
					WHERE D14.D14_FILIAL = %xFilial:D14%
					AND D14.%NotDel%
					%Exp:cWhereD14%
					UNION ALL
					SELECT 'D13' ALIASQRY,
							D13.R_E_C_N_O_ RECNOQRY
					FROM %Table:D13% D13
					WHERE D13.D13_FILIAL = %xFilial:D13%
					AND D13.%NotDel%
					%Exp:cWhereD13%
					UNION ALL
					SELECT 'D15' ALIASQRY,
							D15.R_E_C_N_O_ RECNOQRY
					FROM %Table:D15% D15
					WHERE D15.D15_FILIAL = %xFilial:D15%
					AND D15.%NotDel%
					%Exp:cWhereD15%
					UNION ALL
					SELECT 'D0G' ALIASQRY,
							D0G.R_E_C_N_O_ RECNOQRY
					FROM %Table:D0G% D0G
					WHERE D0G.D0G_FILIAL = %xFilial:D0G%
					AND D0G.%NotDel%
					%Exp:cWhereD0G%
					UNION ALL
					SELECT 'DCF' ALIASQRY,
							DCF.R_E_C_N_O_ RECNOQRY
					FROM %Table:DCF% DCF
					WHERE DCF.DCF_FILIAL = %xFilial:DCF%
					AND DCF.%NotDel%
					%Exp:cWhereDCF%
					UNION ALL
					SELECT 'D12' ALIASQRY,
							D12.R_E_C_N_O_ RECNOQRY
					FROM %Table:D12% D12
					WHERE D12.D12_FILIAL = %xFilial:D12%
					AND D12.%NotDel%
					%Exp:cWhereD12%
					UNION ALL
					SELECT 'DCR' ALIASQRY,
							DCR.R_E_C_N_O_ RECNOQRY
					FROM %Table:DCR% DCR
					INNER JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = DCR.DCR_IDORI
					AND D12.D12_IDMOV = DCR.DCR_IDMOV
					AND D12.D12_IDOPER = DCR.DCR_IDOPER
					AND D12.%NotDel%
					%Exp:cWhereD12%
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					AND DCR.%NotDel%
					UNION ALL
					SELECT 'D07' ALIASQRY,
							D07.R_E_C_N_O_ RECNOQRY
					FROM %Table:D07% D07
					WHERE D07.D07_FILIAL = %xFilial:D07%
					AND D07.%NotDel%
					%Exp:cWhereD07%
					UNION ALL
					SELECT 'D08' ALIASQRY,
							D08.R_E_C_N_O_ RECNOQRY
					FROM %Table:D08% D08
					WHERE D08.D08_FILIAL = %xFilial:D08%
					AND D08.%NotDel%
					%Exp:cWhereD08%
					UNION ALL
					SELECT 'D09' ALIASQRY,
							D09.R_E_C_N_O_ RECNOQRY
					FROM %Table:D09% D09
					WHERE D09.D09_FILIAL = %xFilial:D09%
					AND D09.%NotDel%
					%Exp:cWhereD09%
					UNION ALL
					SELECT 'D0F' ALIASQRY,
							D0F.R_E_C_N_O_ RECNOQRY
					FROM %Table:D0F% D0F
					WHERE D0F.D0F_FILIAL = %xFilial:D0F%
					AND D0F.%NotDel%
					%Exp:cWhereD0F%
					UNION ALL
					SELECT 'D0M' ALIASQRY,
							D0M.R_E_C_N_O_ RECNOQRY
					FROM %Table:D0M% D0M
					WHERE D0M.D0M_FILIAL = %xFilial:D0M%
					AND D0M.%NotDel%
					%Exp:cWhereD0M%
					UNION ALL
					SELECT 'D0P' ALIASQRY,
							D0P.R_E_C_N_O_ RECNOQRY
					FROM %Table:D0P% D0P
					INNER JOIN %Table:D0M% D0M
					ON D0M.D0M_FILIAL = %xFilial:D0M%
					AND D0M.D0M_CODPLN = D0P.D0P_CODPLN
					AND D0M.D0M_ITEM = D0P.D0P_ITEM
					AND D0M.%NotDel%
					%Exp:cWhereD0M%
					WHERE D0P.D0P_FILIAL = %xFilial:D0P%
					AND D0P.%NotDel%
				) TOT
		EndSql
	EndIf
Return cAliasQry

METHOD RemFatConv(cArmazem,cProduto,oProcess) CLASS WMSDTCProdutoDadosGenericos
Local lRet      := .T.
Local lContinua := .T.
Local lProcess  := oProcess <> Nil
Local aAreaD14  := D14->(GetArea())
Local aAreaD13  := D13->(GetArea())
Local aAreaD15  := D15->(GetArea())
Local aAreaD0G  := D0G->(GetArea())
Local aAreaDCF  := DCF->(GetArea())
Local aAreaD12  := D12->(GetArea())
Local aAreaDCR  := DCR->(GetArea())
Local aAreaD07  := D07->(GetArea())
Local aAreaD08  := D08->(GetArea())
Local aAreaD09  := D09->(GetArea())
Local aAreaD0F  := D0F->(GetArea())
Local aAreaD0M  := D0M->(GetArea())
Local aAreaD0P  := D0P->(GetArea())
Local cAliasQry := Nil
Local nCount    := 0

Default cArmazem := ""
Default cProduto := ""

	// Verificar a quantidade de registros
	If lProcess
		cAliasQry := Self:SelectFtCn(.F.,cArmazem,cProduto)
		If (cAliasQry)->(!Eof()) .And. (cAliasQry)->NR_COUNT > 0
			nCount := (cAliasQry)->NR_COUNT
			oProcess:SetRegua1((cAliasQry)->NR_COUNT)
			oProcess:SetRegua2(2)
		Else
			lContinua := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lContinua
		// Busca registros para processamento
		cAliasQry := Self:SelectFtCn(.T.,cArmazem,cProduto)
		Do While (cAliasQry)->(!Eof())
			If lProcess
				oProcess:IncRegua1( WmsFmtMsg(STR0005 + "...",{{"[VAR01]",cValToChar(oProcess:nMeter1+1)},{"[VAR02]",cValToChar(oProcess:oMeter1:nTotal)}}) ) // Processando [VAR01]/[VAR02] registro(s)
				oProcess:IncRegua2(WmsFmtMsg(STR0006,{{"[VAR01]","("+(cAliasQry)->ALIASQRY+")"}})) // Atualizando [VAR01]
			EndIf
			Do Case
				Case (cAliasQry)->ALIASQRY == 'D14'
					D14->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D14",.F.)
					D14->D14_QTDES2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDEST,0,2)
					D14->D14_QTDEP2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDEPR,0,2)
					D14->D14_QTDSP2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDSPR,0,2)
					D14->D14_QTDEM2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDEMP,0,2)
					D14->D14_QTDBL2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDBLQ,0,2)
					D14->D14_QTDPE2 := ConvUm(D14->D14_PRODUT,D14->D14_QTDPEM,0,2)
					D14->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D13'
					D13->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D13",.F.)
					D13->D13_QTDES2 := ConvUm(D13->D13_PRODUT,D13->D13_QTDEST,0,2)
					D13->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D15'
					D15->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D15",.F.)
					D15->D15_QISEGU := ConvUm(D15->D15_PRODUT,D15->D15_QINI,0,2)
					D15->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D0G'
					D0G->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D0G",.F.)
					D0G->D0G_QTORI2 := ConvUm(D0G->D0G_PRODUT,D0G->D0G_QTDORI,0,2)
					D0G->D0G_QTSEUM := ConvUm(D0G->D0G_PRODUT,D0G->D0G_SALDO,0,2)
					D0G->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'DCF'
					DCF->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("DCF",.F.)
					DCF->DCF_QTSEUM := ConvUm(DCF->DCF_CODPRO,DCF->DCF_QUANT,0,2)
					DCF->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D12'
					D12->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D12",.F.)
					D12->D12_QTDOR2 := ConvUm(D12->D12_PRODUT,D12->D12_QTDORI,0,2)
					D12->D12_QTDMO2 := ConvUm(D12->D12_PRODUT,D12->D12_QTDMOV,0,2)
					D12->D12_QTDLI2 := ConvUm(D12->D12_PRODUT,D12->D12_QTDLID,0,2)
					D12->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'DCR'
					DCR->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("DCR",.F.)
					DCR->DCR_QTSEUM := ConvUm(D12->D12_PRODUT,DCR->DCR_QUANT,0,2)
					DCR->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D07'
					D07->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D07",.F.)
					D07->D07_QTDEN2 := ConvUm(D07->D07_PRODUT,D07->D07_QTDENT,0,2)
					D07->D07_QTDDI2 := ConvUm(D07->D07_PRODUT,D07->D07_QTDDIS,0,2)
					D07->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D08'
					D08->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D08",.F.)
					D08->D08_QTDEN2 := ConvUm(D08->D08_PRODUT,D08->D08_QTDEND,0,2)
					D08->D08_QTDDI2 := ConvUm(D08->D08_PRODUT,D08->D08_QTDDIS,0,2)
					D08->D08_QTDVE2 := ConvUm(D08->D08_PRODUT,D08->D08_QTDVEN,0,2)
					D08->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D09'
					D09->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D09",.F.)
					D09->D09_QTDAD2 := ConvUm(D09->D09_PRODUT,D09->D09_QTDADI,0,2)
					D09->D09_QTDDI2 := ConvUm(D09->D09_PRODUT,D09->D09_QTDDIS,0,2)
					D09->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D0F'
					D0F->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D0F",.F.)
					D0F->D0F_QTDDI2 := ConvUm(D0F->D0F_PRODUT,D0F->D0F_QTDDIS,0,2)
					D0F->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D0M'
					D0M->(dbGoTo((cAliasQry)->RECNOQRY))
					RecLock("D0M",.F.)
					D0M->D0M_QTDDE2 := ConvUm(D0M->D0M_PRODUT,D0M->D0M_QTDDEM,0,2)
					D0M->D0M_QTDDI2 := ConvUm(D0M->D0M_PRODUT,D0M->D0M_QTDDIS,0,2)
					D0M->(MsUnlock())
				Case (cAliasQry)->ALIASQRY == 'D0P'
					D0P->(dbGoTo((cAliasQrY)->RECNOQRY))
					RecLock("D0P",.F.)
					D0P->D0P_QTDDI2 := ConvUm(D0M->D0M_PRODUT,D0P->D0P_QTDDIS,0,2)
					D0P->(MsUnlock())
			EndCase
			// Próximo registro
			If lProcess
				oProcess:IncRegua2(WmsFmtMsg(STR0007,{{"[VAR01]","("+(cAliasQry)->ALIASQRY+")"}})) // Finalizando [VAR01]
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lProcess
		If nCount > 0
			WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]",cValToChar(nCount)}})) // Finalizado, [VAR01] registro(s) processado(s)!
		Else
			WmsMessage(STR0009) // Não há registros para o processamentos
		EndIf
	EndIf
	// RestArea
	RestArea(aAreaD14)
	RestArea(aAreaD13)
	RestArea(aAreaD15)
	RestArea(aAreaD0G)
	RestArea(aAreaDCF)
	RestArea(aAreaD12)
	RestArea(aAreaDCR)
	RestArea(aAreaD07)
	RestArea(aAreaD08)
	RestArea(aAreaD09)
	RestArea(aAreaD0F)
	RestArea(aAreaD0M)
	RestArea(aAreaD0P)
Return lRet