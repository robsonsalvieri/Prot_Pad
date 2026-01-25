#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSV086.CH"
#INCLUDE "APVT100.CH"
#Define CLRF  CHR(13)+CHR(10)

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSV086 - Geração da Ordem de Serviço por unitizador Coletor       |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a seleção de uma listagem de unitizadores para     |
|         | efetuar a geração da Ordem de Serviço de origem D0R.               |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSV08601 "WMSV08601"
#DEFINE WMSV08602 "WMSV08602"
#DEFINE WMSV08603 "WMSV08603"
#DEFINE WMSV08604 "WMSV08604"
#DEFINE WMSV08605 "WMSV08605"
#DEFINE WMSV08606 "WMSV08606"
#DEFINE WMSV08607 "WMSV08607"
#DEFINE WMSV08608 "WMSV08608"
#DEFINE WMSV08609 "WMSV08609"
#DEFINE WMSV08610 "WMSV08610"

Static oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
//----------------------------------------------------------------------------------
Function WMSV086()
Local aTela    := VtSave()
Local cKey06   := VtDescKey(06)
Local cKey09   := VtDescKey(09)
Local cKey24   := VtDescKey(24)
Local bkey06   := VTSetKey(06) // Ctrl+F
Local bkey09   := VTSetKey(09) // Ctrl+I
Local bkey24   := VTSetKey(24) // Ctrl+X
Local lRet     := .T.
Local cUnitiz  := ""
Local aEndUnit := {} // Array para o Endereçamento de Unitizadores
	
	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	VTSetKey(06,{|| GeraOsUnit(aEndUnit)}, STR0001) // Ctrl+F // Gerar OS End.
	VTSetKey(09,{|| ShowLstUni(aEndUnit)}, STR0002) // Ctrl+I // Lista Unitizador
	VTSetKey(24,{|| EstUnitiz(aEndUnit)}, STR0003) // Ctrl-X // Estorno Uni. Lista

	While .T.
		// Inicializa variaveis
		cUnitiz := Space(TamSx3("D0R_IDUNIT")[1])
		VtClear()
		WMSVTCabec(STR0001, .F., .F., .T.) // Gerar OS End.
		@ 01,00 VtSay STR0005 // Informe o Unitiz.
		@ 02,00 VtGet cUnitiz Picture '@!' Valid VldIdUnit(cUnitiz,aEndUnit)
		VtRead()

		If VtLastkey() == 27 .And. WmsQuestion(STR0006,STR0001) // Confirma a saída? // Gerar OS End.
			Exit
		EndIf
	EndDo

	VTSetKey(06,bkey06,cKey06)
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(24,bkey24,cKey24)
	// Restaura tela
	VtRestore(,,,,aTela)
Return Nil
//-----------------------------------------------------------------------------
Static Function GeraOsUnit(aEndUnit)
Local lRet  := .T.
	If Empty(aEndUnit)
		Return .F.
	EndIf
	If !WmsQuestion(STR0007,STR0001) // Confirma geração da OS para os unitizadores? // Gerar OS End.
		lRet := .F.
	EndIf

	If lRet
		lRet := WMSV086END(aEndUnit)
	EndIf
	// Se deu certo a geração, limpa os unitizadores
	If lRet
		aEndUnit := {}
	EndIf
Return lRet
//-----------------------------------------------------------------------------
Function WMSV086END(aUnitiz)
Local lRet       := .T.
Local lTelNet    := IsTelNet()
Local aAreaAnt   := GetArea()
Local aTela      := Nil
Local oOrdServ   := WMSDTCOrdemServicoCreate():New()
Local cUnitiz    := ""
Local cAliasQry  := Nil
Local nI         := 0

	WmsOrdSer(oOrdServ)
	
	If lTelNet
		aTela := VTSave()
		VTMsg(STR0008+"...") // Processando
	Else
		ProcRegua(Len(aUnitiz) + 2)
		IncProc(STR0008+"...") // Processando
	EndIf

	For nI := 1 To Len(aUnitiz)
		cUnitiz := aUnitiz[nI]
		// Busca as informações da Ordem de Serviço do primeiro documento da demanda
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0Q.D0Q_SERVIC,
					D0Q.D0Q_DOCTO,
					D0Q.D0Q_SERIE,
					D0Q.D0Q_CLIFOR,
					D0Q.D0Q_LOJA,
					D0Q.D0Q_NUMSEQ,
					D0Q.D0Q_LOCAL,
					D0Q.D0Q_ORIGEM,
					D0Q.D0Q_ENDER,
					D0Q.D0Q_CODPRO,
					D0Q.D0Q_LOTECT,
					D0Q.D0Q_NUMLOT
			FROM       %Table:D0S% D0S
			INNER JOIN %Table:D0Q% D0Q
			ON D0Q.D0Q_FILIAL = %xFilial:D0Q%
			AND D0Q.D0Q_ID = D0S.D0S_IDD0Q
			AND D0Q.%NotDel%
			INNER JOIN %Table:D0R% D0R
			ON D0R.D0R_FILIAL = %xFilial:D0R%
			AND D0R.D0R_IDUNIT = D0S.D0S_IDUNIT
			AND D0R.D0R_STATUS IN ('1','2') // Para garantir que não irá gerar duplicado
			AND D0R.%NotDel%
			WHERE D0S.D0S_FILIAL = %xFilial:D0S%
			AND D0S.D0S_IDUNIT = %Exp:cUnitiz%
			AND D0S.%NotDel%
		EndSql
		If !lTelNet
			IncProc(WmsFmtMsg(STR0009,{{"[VAR01]",cUnitiz}})+"...") // Gerando OS para [VAR01]
		EndIf
		If (cAliasQry)->(!Eof())
			Begin Transaction
				// Seta os atributos do objeto
				oOrdServ:oOrdEndOri:SetArmazem((cAliasQry)->D0Q_LOCAL)
				oOrdServ:oOrdEndOri:SetEnder((cAliasQry)->D0Q_ENDER)
				oOrdServ:SetOrigem("D0R")
				oOrdServ:SetServico((cAliasQry)->D0Q_SERVIC)
				oOrdServ:SetDocto((cAliasQry)->D0Q_DOCTO)
				oOrdServ:SetSerie((cAliasQry)->D0Q_SERIE)
				oOrdServ:SetCliFor((cAliasQry)->D0Q_CLIFOR)
				oOrdServ:SetLoja((cAliasQry)->D0Q_LOJA)
				oOrdServ:SetNumSeq((cAliasQry)->D0Q_NUMSEQ)
				oOrdServ:SetIdUnit(cUnitiz)
				oOrdServ:SetQuant(1)
				// Realiza a criação da ordem de serviço como origem D0R
				If !oOrdServ:CreateDCF()
					If lTelNet
						WMSVTAviso(WMSV08601, oOrdServ:GetErro()) // Erro do objeto
					Else
						WmsMessage(oOrdServ:GetErro(),WMSV08608,1) // Erro do objeto
					EndIf
					lRet := .F.
					Disarmtransaction()
				EndIf
			End Transaction
		EndIf
		(cAliasQry)->(dbCloseArea())
		If !lRet
			Exit
		EndIf
	Next nI
	// Efetua a execução automática quando serviço configurado 
	If lRet
		WmsExeServ()
	EndIf
	If lRet
		If lTelNet
			WMSVTAviso(WMSV08610, STR0017) // Ordem de Serviço gerada com sucesso!
		Else
			WmsMessage(STR0017,WMSV08610,1) // Ordem de Serviço gerada com sucesso!
		EndIf
	EndIf
	
	If lTelNet
		VtRestore(,,,,aTela)
	EndIf

	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------------
Static Function ShowLstUni(aEndUnit)
Local cKey06   := VtDescKey(06)
Local bKey06   := VTSetKey(06)
Local cKey09   := VTDescKey(09)
Local bKey09   := VTSetKey(09)
Local cKey24   := VTDescKey(24)
Local bKey24   := VTSetKey(24)
Local aTela    := VTSave()
Local nLin     := 1

	// Se a lista está vazia não mostra a mesma
	If Empty(aEndUnit)
		WMSVTAviso(WMSV08602, STR0012) // Não existem unitizadores informados na listagem.
	Else
		VTClear()
		While nLin > 0
			WMSVTCabec(STR0002,.F.,.F.,.T.) // Lista Unitizador
			nLin := VtAchoice(1,0,VtMaxRow(),VtMaxCol(),aEndUnit,,,nLin)
			If nLin > 0
				WMSV084ITU(aEndUnit[nLin])
			EndIf
		EndDo
	EndIf
	// Restaura teclas
	VTSetKey(06,bKey06,cKey06)
	VTSetKey(09,bKey09,cKey09)
	VTSetKey(24,bKey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil
//----------------------------------------------------------------------------------
Static Function EstUnitiz(aEndUnit)
Local cKey06   := VTDescKey(06)
Local cKey09   := VTDescKey(09)
Local cKey24   := VTDescKey(24)
Local bKey06   := VTSetKey(06)
Local bKey09   := VTSetKey(09)
Local bKey24   := VTSetKey(24)
Local aTela    := VTSave()
Local cUnitiz  := ""
Local nPos     := 0
Local lRet     := .T.

	If Empty(aEndUnit)
		WMSVTAviso(WMSV08603, STR0012) // Não existem unitizadores informados na listagem.
	Else
		While .T.
			VTCLear()
			cUnitiz := Space(TamSx3("D0R_IDUNIT")[1])

			WMSVTCabec(STR0003, .F., .F., .T.) // Estorno Uni. Lista
			@ 01,00 VtSay STR0005 // Informe o Unitiz.
			@ 02,00 VtGet cUnitiz Picture '@!' Valid VldEstUni(cUnitiz,aEndUnit,@nPos)
			VtRead()

			If VtLastKey() == 27
				Exit
			EndIf

			If nPos > 0 .And. WmsQuestion(WmsFmtMsg(STR0016,{{"[VAR01]",cUnitiz}}),STR0003) // Confirma estorno do unitizador [VAR01]? // Estorno Uni. Lista
				aDel(aEndUnit,nPos)
				aSize(aEndUnit,Len(aEndUnit)-1)
			EndIf
			// Se estornou todos os volumes sai
			If Len(aEndUnit) == 0
				WMSVTAviso(WMSV08604, STR0012) // Não existem unitizadores informados na listagem.
				Exit
			EndIf
		EndDo
		VTClearBuffer()
	EndIf
	VtRestore(,,,,aTela)
	VTSetKey(06, bKey06, cKey06)
	VTSetKey(09, bKey09, cKey09)
	VTSetKey(24, bKey24, cKey24)
Return
//----------------------------------------------------------------------------------
Static Function VldIdUnit(cUnitiz,aEndUnit)
Local aAreaAnt  := GetArea()
Local lRet      := .T.

	If Empty(cUnitiz)
		Return .F.
	EndIf

	oMntUniItem:SetIdUnit(cUnitiz)
	If !(lRet := oMntUniItem:VldIdUnit(3))
		WMSVTAviso(WMSV08605,oMntUniItem:GetErro()) // Erro do objeto
	EndIf

	If lRet .And. aScan(aEndUnit,{|x| x == cUnitiz}) > 0
		WMSVTAviso(WMSV08606, WmsFmtMsg(STR0013,{{"[VAR01]",cUnitiz}}))  // O unitizador [VAR01] já se encontra na listagem.
		lRet := .F.
	EndIf

	If lRet .And. oMntUniItem:oUnitiz:GetStatus() == "1"
		WMSVTAviso(WMSV08609,WmsFmtMsg(STR0015,{{"[VAR01]",cUnitiz}})) // Unitizador [VAR01] está 'Em Montagem'.
		lRet := .F.
	EndIf

	// Adiciona no agrupador de unitizadores para geração da OS.
	If lRet
		aAdd(aEndUnit,cUnitiz)
	EndIf

	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------------
Static Function VldEstUni(cUnitiz,aEndUnit,nPos)

	If Empty(aEndUnit)
		Return .F.
	EndIf

	If (nPos := aScan(aEndUnit,{|x| x == cUnitiz})) <= 0
		WMSVTAviso(WMSV08607, WmsFmtMsg(STR0014,{{"[VAR01]",cUnitiz}}))  // O unitizador [VAR01] não se encontra na listagem.
		VTKeyBoard(Chr(20))
		Return .F.
	EndIf
Return .T.