#INCLUDE "PROTHEUS.CH"  
#INCLUDE "WMSA495.CH"
#Define CLRF  CHR(13)+CHR(10)

//-----------------------------------
/*/{Protheus.doc} WMSA495()
Distribui Saldos para Inventário
@author Felipe Machado de Oliveira 
@version P12
@Since 19/03/14
@obs Distribui Saldos para Inventário apartir da SB2
/*/
//-----------------------------------
Function WMSA495()
Local lRet       := .T.
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local cAliasSB2  := GetNextAlias()
Local cAliasSB9  := GetNextAlias()
Local cQuery     := ""
Local cLocAnt    := ""
Local lContinua  := .T.
Local aCampos    := {}
Local oReport
Local cMsg       := ""
Local cUlMes     := DTOS(SuperGetMv("MV_ULMES",.F.,"14990101"))

Static cAliasTmp:= Nil
Static aErro    := {}
Static aProcess := {}

	aProcess := {}

	If !IntWMS()
		WmsMessage(STR0008) // O módulo de WMS não está ativo (MV_INTWMS).
		lRet := .F.
	EndIf

	// Verificar data base igual a data de fechamento MV_ULMES
	If lRet .And. cUlMes != DTOS(dDatabase)
		WmsMessage(STR0002) // Data fechamento estoque não coincide com a data Atual.
		lRet := .F.
	EndIf
	
	If lRet
		// Verifica se há saldos iniciais na data de fechamento
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("SB9")+" SB9"
		cQuery +=  " WHERE SB9.B9_FILIAL = '"+xFilial("SB9")+"'"
		cQuery +=    " AND SB9.B9_DATA = '"+ cUlMes + "'"
		cQuery +=    " AND SB9.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSB9,.F.,.T.)			
		If (cAliasSB9)->(Eof())
			WmsMessage(WmsFmtMsg(STR0022,{{"[VAR01]",DTOC(SuperGetMv("MV_ULMES",.F.,"14990101"))}})) // Não foi encontrado na data de fechamento [VAR01] os saldos iniciais (SB9)!
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. Pergunte("WMSA495")
		// Filtra SB2
		cQuery := " SELECT SB2.B2_LOCAL, SB2.B2_COD B2_PRDORI, SB2.B2_COD, SB2.B2_QATU"
		cQuery +=   " FROM "+RetSqlName("SB2")+" SB2"
		cQuery +=  " WHERE SB2.B2_FILIAL = '"+xFilial("SB2")+"'"
		cQuery +=    " AND SB2.B2_LOCAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
		cQuery +=    " AND SB2.B2_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"
		cQuery +=    " AND SB2.B2_QATU > 0"
		cQuery +=    " AND SB2.D_E_L_E_T_ = ' '"
		cQuery +=    " ORDER BY SB2.B2_LOCAL"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSB2,.F.,.T.)
		ProcRegua( (cAliasSB2)->( RecCount()) )
		While (cAliasSB2)->(!Eof())
			// Verifica se o endereço de distribuição esta configurado para o armazem
			If cLocAnt <> (cAliasSB2)->B2_LOCAL
				If !ValEndInv((cAliasSB2)->B2_LOCAL)
					lContinua := .F.
				Else
					lContinua := .T.
				EndIf
				cLocAnt := (cAliasSB2)->B2_LOCAL
			EndIf
			// Continua endereço de inventário estiver correto
			If lcontinua
				// Valida se produto sem saldo no estoque por endereço
				If ValSldEnd((cAliasSB2)->B2_COD,(cAliasSB2)->B2_LOCAL)
					// Verifica se o produto controla endereçamento e possui controle WMS
					If IntWMS((cAliasSB2)->B2_COD)
						// Adiciona o armazem e produto para processamento
						AAdd(aProcess,{(cAliasSB2)->B2_LOCAL,(cAliasSB2)->B2_PRDORI,(cAliasSB2)->B2_COD,(cAliasSB2)->B2_QATU})
					EndIf
				EndIf
			EndIf
			(cAliasSB2)->(dbSkip())
		EndDo
		(cAliasSB2)->(dbCloseArea())
		// Verifica se existem registros aptos a processar
		If lRet .And. !Empty(aProcess)
			cMsg := WmsFmtMsg(STR0003,{{"[VAR01]",IIf(lWmsNew,"D15","SBK")}}) // Esse programa tem como objetivo realizar a distribuição do saldo físico (SB2) nas tabelas de saldos iniciais ([VAR01]) para o endereço (INVENTARIO)
			cMsg += CLRF+STR0004 // Para os produtos com controle de lote (SB8) o saldo a distribuir será conforme o lote no estoque ou distribuido para o lote (A DEFINIR).
			If !lWmsNew
				cMsg += CLRF+CLRF+STR0005 // Após processamento é necessário executar a rotina de acerto saldo atual.
			Else
				cMsg += CLRF+CLRF+STR0009 // Após processamento é necessário executar a rotina de inventário.
			EndIf
			WmsMessage(cMsg)
			Processa({|| AtuaSaldos() }, STR0006, STR0007,.F.) // Aguarde... // Processando dados...
			WmsMessage(STR0010) // Distribuição de Saldos concluída!
		Else
			WmsMessage(STR0011) // Não há itens para distribuição de saldos!
		EndIf
		If !Empty(aErro)
			If WmsQuestion(STR0012) // Houveram ocorrencias de erro, deseja imprimir?
				// Verifica se existem registros de erro
				cAliasTmp := CriaTabTmp({{"INDREC","N",10,0},{"DIVER","C",120,0}},{"INDREC"},cAliasTmp)
				cAliasTmp := MntCargDad(cAliasTmp,aErro,{{"INDREC","N",10,0},{"DIVER","C",120,0}})
				oReport:= ReportDef()
				oReport:PrintDialog()
				delTabTmp(cAliasTmp)
			EndIf
		EndIf						
	EndIf	
Return Nil
//------------------------------------
/*/{Protheus.doc} ExistSaldo()
Verifica se o produto ja possui por endereço
@author Felipe Machado de Oliveira 
@version P12
@Since 19/03/14
@obs Verifica se o produto ja possui saldo por endereço
/*/
//------------------------------------
Static Function ValSldEnd(cProduto,cLocal)
Local aAreaSld := Nil
Local lRet     := .T.
Local lWmsNew  := SuperGetMv("MV_WMSNEW",.F.,.F.)
	cProduto := PadR(cProduto,TamSx3("B1_COD")[1])
	cLocal   := PadR(cLocal,TamSx3("BE_LOCAL")[1])
	If lWmsNew
		aAreaSld := D14->(GetArea())
		D14->(dbSetOrder(2))
		If D14->(dbSeek(xFilial("D14")+cLocal+cProduto))
			AAdd(aErro,{Len(aErro)+1,WmsFmtMsg(STR0013,{{"[VAR01]",cProduto},{"[VAR02]",cLocal}})}) // O produto [VAR01] no armazem [VAR02] possui saldo no estoque por endereço WMS(D14)!
			lRet := .F.
		EndIf
		RestArea(aAreaSld)
	Else
		aAreaSld := SBF->(GetArea())
		SBF->(dbSetOrder(2))
		If SBF->(dbSeek(xFilial("SBF")+cProduto+cLocal))
			AAdd(aErro,{Len(aErro)+1,WmsFmtMsg(STR0014,{{"[VAR01]",cProduto},{"[VAR02]",cLocal}})}) // O produto [VAR01] no armazem [VAR02] possui saldo no estoque por endereço (SBF)!
			lRet := .F.
		EndIf
		RestArea(aAreaSld)
	EndIf	
Return lRet
//------------------------------------
// ValEndInv()
// Valida endereço de inventário
//------------------------------------
Static Function ValEndInv(cLocal)
Local aAreaSBE := SBE->(GetArea())
Local lRet     := .T.

	cLocal := PadR(cLocal,TamSx3("BE_LOCAL")[1])
	SBE->(dbSetOrder(1))
	If !SBE->(dbSeek(xFilial("SBE")+cLocal+"INVENTARIO"))
		AAdd(aErro,{Len(aErro)+1,WmsFmtMsg(STR0015,{{"[VAR01]",cLocal}})}) // Endereço INVENTARIO não definido no armazem [VAR01]!
		lRet := .F.
	Else
		If Empty(SBE->BE_CODZON)
			AAdd(aErro,{Len(aErro)+1,WmsFmtMsg(STR0016,{{"[VAR01]",cLocal}})}) // Endereço INVENTARIO no armazem [VAR01] sem zona de armazenagem definida!
			lRet := .F.
		EndIf
		If lRet .And. Empty(SBE->BE_ESTFIS)
			AAdd(aErro,{Len(aErro)+1,WmsFmtMsg(STR0017,{{"[VAR01]",cLocal}})}) // Endereço INVENTARIO no armazem [VAR01] sem estrutura física definida!
			lRet := .F.
		EndIf
	EndIf	
	RestArea(aAreaSBE)
Return lRet
//-----------------------------------------
// AtuaSaldos
// Atualiza os saldos SBK / D15 | D14 | D13
//-----------------------------------------
Static Function AtuaSaldos()
Local cLocal     := ""
Local cPrdOri    := ""
Local cProduto   := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cEndereco  := PadR("INVENTARIO",TamSx3("BE_LOCALIZ")[1])
Local cNumSer    := ""
Local nI         := 0
	For nI := 1 To Len(aProcess)
		//Verificar se a data base é igual a data de fechamento do estoque MV_ULMES
		cLocal   := PadR(aProcess[nI][1],TamSx3("B2_LOCAL")[1])
		cPrdOri  := PadR(aProcess[nI][2],TamSx3("B2_COD")[1])
		cProduto := PadR(aProcess[nI][3],TamSx3("B2_COD")[1])
		cLoteCtl := PadR("",TamSx3("B8_LOTECTL")[1])
		cNumLote := PadR("",TamSx3("B8_NUMLOTE")[1])	 
		nQtdAtu  := aProcess[nI][4]
			
		Begin Transaction
			// Quando o novo wms não está ativo, carrega as tabelas antigas de saldo inicial
			If Rastro(cProduto)
				SB8->(dbSetOrder(3))
				If SB8->(dbSeek(xFilial("SB8")+cPrdOri+cLocal) )
					Do While SB8->(!Eof()) .And. SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL) == xFilial("SB8")+cPrdOri+cLocal
						cLoteCtl := SB8->B8_LOTECTL
						cNumLote := SB8->B8_NUMLOTE
						nQtdAtu  := SB8->B8_SALDO
						// Grava dados SBK / D15|D14|D13
						GravaDados(cLocal,cPrdOri,cLoteCtl,cNumLote,cNumSer,cEndereco,nQtdAtu)
						SB8->(dbSkip())					
					EndDo
				Else
					cLoteCtl := PadR("A DEFINIR",TamSx3("B8_LOTECTL")[1])
					cNumLote := PadR("A DEF.",TamSx3("B8_NUMLOTE")[1])				
					// Grava dados SBK / D14|D13
					GravaDados(cLocal,cPrdOri,cLoteCtl,cNumLote,cNumSer ,cEndereco, nQtdAtu)
				EndIf
			Else			
				// Grava dados SBK / D14|D13
				GravaDados(cLocal,cPrdOri,cLoteCtl,cNumLote,cNumSer ,cEndereco, nQtdAtu)
			EndIf						
		End Transaction	
	Next
Return
//-----------------------------------------------------------------------------------
// GravaDados
// Atualiza as informações da SBK / D15 | D14 | D13
//-----------------------------------------------------------------------------------
Static Function GravaDados(cLocal,cPrdOri,cLoteCtl,cNumLote,cNumSer,cEndereco, nQuant)
Local lRet       := .T.
Local aAreaSBK   := Nil
Local aProduto   := {}
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oProduto   := IIf(lWmsNew,WMSDTCProdutoDadosAdicionais():New(),Nil)
Local oEstEnder  := IIf(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local nProduto   := 0 
	If !lWmsNew
		aAreaSBK := SBK->(GetArea())
		If !SBK->(dbSeek(xFilial("SBK")+cPrdOri+cLocal+DTOS(dDataBase) ) )
			RecLock("SBK",.T.)
			SBK->BK_FILIAL	:= xFilial("SBK")
			SBK->BK_COD	:= cPrdOri
			SBK->BK_LOCAL	:= cLocal
			SBK->BK_DATA	:= dDatabase
			SBK->BK_LOTECTL	:= cLoteCtl // somente se produto tiver controle de Rastro.
			SBK->BK_NUMLOTE	:= cNumLote // somente se produto tiver controle de sublote
			SBK->BK_LOCALIZ	:= cEndereco
			SBK->BK_QINI	:= nQuant
			SBK->BK_QISEGUM	:= ConvUm(cPrdOri,SBK->BK_QINI,0,2) 
			SBK->(MsUnLock())
		EndIf	
		RestArea(aAreaSBK)
	Else
		oProduto:SetProduto(cPrdOri)
		If oProduto:LoadData()
			// Carrega estrutura do produto x componente
			aProduto := oProduto:GetArrProd()					
			If Len(aProduto) > 0
				For nProduto := 1 To Len(aProduto)
					// Carrega dados para Estoque por Endereço
					oEstEnder:oEndereco:SetArmazem(cLocal )
					oEstEnder:oEndereco:SetEnder(cEndereco)
					// Carrega dados produto
					oEstEnder:oProdLote:SetArmazem(cLocal)
					oEstEnder:oProdLote:SetPrdOri(cPrdOri)                 // Produto Origem
					oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
					oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)               // Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumLote(cNumLote)               // Sub-Lote do produto principal que deverá ser o mesmo no componentes
					oEstEnder:oProdLote:SetNumSer(cNumSer)                 // Numero de serie
					oEstEnder:LoadData()
					oEstEnder:SetQuant(QtdComp(nQuant * aProduto[nProduto][2]) )
					// Realiza Entrada Armazem Estoque por Endereço
					oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/, /*lEmpPrev*/,.T., /*lMovEstEnd*/)
				Next
			EndIf
		EndIf	
	EndIf
Return lRet					
//------------------------------------------------------------
//  Definições do relatório
//------------------------------------------------------------
Static Function ReportDef()
Local cTitle := OemToAnsi(STR0018) // Ocorrencias de erro da distribuição de saldos Iniciais
Local oReport
Local oSection
	// Criacao do componente de impressao
	oReport := TReport():New('WMSA495',cTitle,,{|oReport| ReportPrint(oReport,cAliasTmp)},cTitle)
	oSection := TRSection():New(oReport,STR0019,{cAliasTmp},) // Ocorrencias de erro
	
	TRCell():New(oSection,"INDREC",cAliasTmp,STR0020) // Seq
	TRCell():New(oSection,"DIVER",cAliasTmp,STR0021)  // Mensagem
Return oReport
//-----------------------------------------------------------
// Impressão do relatório
//-----------------------------------------------------------
Static Function ReportPrint(oReport,cAliasTmp)
Local oSection1 := oReport:Section(1)	
	MakeSqlExpr(oReport:GetParam())	
	oReport:SetMeter((cAliasTmp)->(RecCount()))
	dbSelectArea(cAliasTmp)
	(cAliasTmp)->(dbSetOrder(1))
	(cAliasTmp)->(dbGoTop())
	
	oSection1:Init()
	oSection1:Cell("INDREC"):SetSize(4)
	oSection1:Cell("DIVER"):SetSize(120)
	
	While !oReport:Cancel() .And. !(cAliasTmp)->(Eof())
		oSection1:Cell("INDREC"):Show()
		oSection1:Cell("DIVER"):Show()
	
		oSection1:PrintLine()
		oReport:SkipLine()
		
		(cAliasTmp)->(dbSkip())
	EndDo
	oSection1:Finish()
Return Nil