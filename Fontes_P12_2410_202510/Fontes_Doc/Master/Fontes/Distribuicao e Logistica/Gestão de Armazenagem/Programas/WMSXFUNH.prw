#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNH.CH"

#DEFINE WMSXFUNH01 "WMSXFUNH01"
#DEFINE WMSXFUNH02 "WMSXFUNH02"
#DEFINE WMSXFUNH03 "WMSXFUNH03"
#DEFINE WMSXFUNH04 "WMSXFUNH04"
#DEFINE WMSXFUNH05 "WMSXFUNH05"
#DEFINE WMSXFUNH06 "WMSXFUNH06"
#DEFINE WMSXFUNH07 "WMSXFUNH07"
#DEFINE WMSXFUNH08 "WMSXFUNH08"
#DEFINE WMSXFUNH09 "WMSXFUNH09"
#DEFINE WMSXFUNH10 "WMSXFUNH10"
#DEFINE WMSXFUNH11 "WMSXFUNH11"
#DEFINE WMSXFUNH12 "WMSXFUNH12"
#DEFINE WMSXFUNH13 "WMSXFUNH13"
#DEFINE WMSXFUNH14 "WMSXFUNH14"
#DEFINE WMSXFUNH15 "WMSXFUNH15"
#DEFINE WMSXFUNH16 "WMSXFUNH16"
#DEFINE WMSXFUNH17 "WMSXFUNH17"
#DEFINE WMSXFUNH18 "WMSXFUNH18"
#DEFINE WMSXFUNH29 "WMSXFUNH29"
#DEFINE WMSXFUNH30 "WMSXFUNH30"
#DEFINE WMSXFUNH31 "WMSXFUNH31"
#DEFINE WMSXFUNH32 "WMSXFUNH32"
#DEFINE WMSXFUNH33 "WMSXFUNH33"

//------------------------------------------------------------------------------
Function WmsAvalSC2(cAcao,cServico,cEndOri,cDocto,nRecSD3,nRecSC2)
//------------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel := Nil
Local oDmdUnit   := Nil
Local oServico   := Nil
Local cMessage   := ""
Local cOp        := ""
Local cAliasQry	 := ""

Default cServico := ""
Default nRecSD3  := 0
Default nRecSC2  := 0
	
	If nRecSD3 > 0
		SD3->(MsGoTo(nRecSD3))
		If Empty(cServico)
			cServico := SD3->D3_SERVIC
		EndIf
		cOp := SD3->D3_OP
	EndIf
	If nRecSC2 > 0
		SC2->(MsGoTo(nRecSC2))
		cOp := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
	EndIf
	If cAcao == "1" // Validação apontamento OP - MATA250 e MATA680/681
		// Valida o preenchimento do campo Serviço
		If lWmsNew .And. Empty(cServico)
			WmsMessage(WmsFmtMsg(STR0001,{{"[VAR01]",RetTitle("D3_SERVIC")}}),WMSXFUNH03,1) // "O campo '[VAR01]' deve ser preenchido para produtos com controle de WMS."
			lRet := .F.
		EndIf
		// Valida o preenchimento do campo Documento
		If lRet .And. !Empty(cServico) .And. Empty(cDocto)
			WmsMessage(WmsFmtMsg(STR0002,{{"[VAR01]",RetTitle("D3_DOC")}}),WMSXFUNH04,1) // "O campo '[VAR01]' deve ser preenchido sempre que uma produção gerar serviço de WMS."
			lRet := .F.
		EndIf
		If lWmsNew
			If lRet 
				oServico := WMSDTCServicoTarefa():New()
				oServico:SetServico(cServico)
				If oServico:LoadData()
					If !oServico:HasOperac({'1','2'}) // Serviço endereçamento, endereçamento crossdocking
						WmsMessage(WmsFmtMsg(STR0003,{{"[VAR01]",cServico}}),WMSXFUNH08,1) // "Serviço '[VAR01]' deve ser de operação Endereçamento ou Endereçamento Crossdocking."
						lRet := .F.
					EndIf
				Else
					WmsMessage(WmsFmtMsg(STR0004,{{"[VAR01]",cServico}}),WMSXFUNH09,1) // "Serviço '[VAR01]' não existe no cadastro de Serviço x Tarefa (DC5)."
					lRet := .F.
				EndIf
				oServico:Destroy()
			EndIf
			
			If lRet .And. Empty(cEndOri)
				WmsMessage(STR0005,WMSXFUNH12,1) // "Endereço Origem não foi preenchido para o endereçamento do WMS."
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. lWmsNew .And. !Empty(cDocto)
			
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT 1
				FROM %Table:DH1% DH1
				LEFT JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND D12.D12_IDDCF = DH1.DH1_IDDCF
					AND D12.D12_NUMSEQ = DH1.DH1_NUMSEQ
					AND D12.D12_STATUS NOT IN ('0','1') //-- 0=Estornada;1=Executada
					AND D12.%NotDel%
				LEFT JOIN %Table:DCF% DCF
					ON DCF.DCF_ID = DH1.DH1_IDDCF
					AND DCF.DCF_NUMSEQ = DH1.DH1_NUMSEQ
					AND DCF.DCF_STSERV NOT IN ('0','3') //-- 0=Estornado;3=Executado
					AND DCF.%NotDel%
				WHERE DH1.DH1_FILIAL = %xFilial:DH1%
					AND DH1.DH1_OP = %Exp:cDocto%
					AND ( D12_IDDCF IS NOT NULL OR DCF_ID IS NOT NULL )
					AND DH1.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cOp}}),WMSXFUNH15,,,,STR0007) // "A ordem de produção [VAR01] possui requisições pendentes de atendimento em ordens de serviço de separação no WMS."###"Aguarde a finalização da separação ou exclua a integração das requisições com o WMS para realizar esta operação."
				lRet := .F.
			EndIf
			(cAliasQry)->(DbCloseArea())

		EndIf

	ElseIf cAcao == "2" // Validação estorno do apontamento OP - MATA250 e MATA680/681
		If !lWmsNew
			If WmsChkDCF("SD3",,,SD3->D3_SERVIC,"3",,SD3->D3_DOC,,,,SD3->D3_LOCAL,SD3->D3_COD,,,SD3->D3_NUMSEQ)
				lRet := WmsAvalDCF("2")
			EndIf
		Else
			If SD3->D3_QUANT > 0  .OR. !Empty(SD3->D3_IDDCF)
				If WmsArmUnit(SD3->D3_LOCAL)
					oDmdUnit := WMSDTCDemandaUnitizacaoDelete():New()
 					oDmdUnit:SetIdD0Q(SD3->D3_IDDCF)
 					oDmdUnit:LoadData()
		 			If !oDmdUnit:CanDelete()
		 				cMessage := STR0010 + " - DU "+LTrim(oDmdUnit:GetDocto())+" - ID "+oDmdUnit:GetIdD0Q() // "Apontamento integrado ao SIGAWMS
		 				cMessage += CRLF + oDmdUnit:GetErro()
	 					WmsMessage(cMessage,WMSXFUNH01,5)
	 					lRet := .F.
	 				EndIf
					FreeObj(oDmdUnit)
				Else
					oOrdSerDel := WMSDTCOrdemServicoDelete():New()
					oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
					oOrdSerDel:LoadData()
					If !oOrdSerDel:CanDelete()
						cMessage := STR0010 + " - OS "+LTrim(oOrdSerDel:GetDocto())+" - ID "+oOrdSerDel:GetIdDCF() // "Apontamento integrado ao SIGAWMS 
						cMessage += CRLF + oOrdSerDel:GetErro()
						WmsMessage(cMessage,WMSXFUNH05,5)
						lRet := .F.
					EndIf
					FreeObj(oOrdSerDel)
				EndIf
			EndIf 
		EndIf

	ElseIf cAcao == "3" // Exclusão/Encerramento da Ordem de Produção
		lRet := ValIntReq(cOp)
	EndIf
Return lRet
//------------------------------------------------------------------------------
Function WmsAvalSD4(cAcao,nRecSD4,nQtdSD4Wms,cOp,nQtd)
//------------------------------------------------------------------------------
Local lRet := .T.
Local lWmsBxOp  := SuperGetMV("MV_WMSBXOP",.F.,.F.)
Local aArea := GetArea()
Default cAcao   := "1"
Default nRecSD4 := 0
Default cOp     := ""
Default nQtd    := 0

	If cAcao == "3" .And. FwIsInCallStack("MATA241") .And. lWmsBxOp
		If WMSBxTotOp() //Se baixou toda a OP na SD4, retorna .T. para nao validar cAcao3
			Return .T.
		EndIf
		If !WMSAptMais(nQtd) //Se apto maior que empenho, valida depois na WMS241D4Sl
			Return .T.
		EndIf
	EndIf

	If nRecSD4 > 0
		SD4->(MsGoTo(nRecSD4))
	EndIf

	If cAcao == "1" // Modificação/Exclusão da Requisição de Estoque
		IF !Empty(SD4->D4_IDDCF)
			WmsMessage(WmsFmtMsg(STR0012,{{"[VAR01]",cOp}}),WMSXFUNH18,,,,STR0013) // "A ordem de produção [VAR01] possui requisições com ordens de serviço de separação no WMS." ### "Efetue o estorno da integração das requisições com o WMS para realizar esta operação."
			lRet := .F.
		EndIF
	ElseIf cAcao == "2" 
		nQtdSD4Wms := 0
		lRet :=  ValIntReq(SD4->D4_OP,SD4->D4_TRT,SD4->D4_IDDCF,@nQtdSD4Wms)
	ElseIf cAcao == "3"
		WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cOp}}),WMSXFUNH15,,,,STR0007) // "A ordem de produção [VAR01] possui requisições pendentes de atendimento em ordens de serviço de separação no WMS."###"Aguarde a finalização da separação ou exclua a integração das requisições com o WMS para realizar esta operação."
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet

//------------------------------------------------------------------------------
Function WmsIntOP(nRecSD3,cEndereco,cServico)
//------------------------------------------------------------------------------
Local aAreaAnt := GetArea()
Local aAreaSD3 := SD3->(GetArea())
Local lRet     := .T.
Local oOrdServ := WmsOrdSer()
Local oDmdUnit := Nil

Default cServico := ""

	SD3->(MsGoTo(nRecSD3))
	If SD3->D3_QUANT <= 0  
		Return .T. 
	EndIf
	
	If Empty(cServico)
		cServico := SD3->D3_SERVIC
	EndIf
	
	If Empty(cEndereco)
		WmsMessage(STR0008,WMSXFUNH10,1) // "Endereço Origem não informado para integração com WMS."
		Return .F.
	EndIf
	
	If Empty(cServico)
		WmsMessage(STR0009,WMSXFUNH11,1) // "Serviço não informado para integração com WMS."
		Return .F.
	EndIf
	
	If !(SD3->D3_LOCAL == SuperGetMv("MV_CQ",.F.,"")) .And. WmsArmUnit(SD3->D3_LOCAL) //Verifica se deve unitizar o produto 
		oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
		// Dados produto
		oDmdUnit:oProdLote:SetArmazem(SD3->D3_LOCAL)
		// Dados endereço origem
		oDmdUnit:oDmdEndOri:SetArmazem(SD3->D3_LOCAL)
		oDmdUnit:oDmdEndOri:SetEnder(cEndereco)
		// Dados endereço destino
		oDmdUnit:oDmdEndDes:SetArmazem(SD3->D3_LOCAL)
		oDmdUnit:oDmdEndDes:SetEnder("")
		// Dados serviço
		oDmdUnit:oServico:SetServico(cServico)
		// Dados documento
		oDmdUnit:SetNumSeq(SD3->D3_NUMSEQ)
		oDmdUnit:SetDocto(SD3->D3_DOC)
		oDmdUnit:SetOrigem("SC2")
		If !(lRet := oDmdUnit:CreateD0Q())
			WmsMessage(oDmdUnit:GetErro(),WMSXFUNH13,1)
		EndIf
	Else
		If oOrdServ == Nil
			oOrdServ := WMSDTCOrdemServicoCreate():New()
			WmsOrdSer(oOrdServ)
		EndIf
		// Dados produto
		oOrdServ:oProdLote:SetArmazem(SD3->D3_LOCAL)
		// Dados endereço origem
		oOrdServ:oOrdEndOri:SetArmazem(SD3->D3_LOCAL)
		oOrdServ:oOrdEndOri:SetEnder(cEndereco)
		// Dados endereço destino
		oOrdServ:oOrdEndDes:SetArmazem(SD3->D3_LOCAL)
		oOrdServ:oOrdEndDes:SetEnder("")
		// Dados serviço
		oOrdServ:oServico:SetServico(cServico)
		// Dados documento
		oOrdServ:SetNumSeq(SD3->D3_NUMSEQ)
		oOrdServ:SetDocto(SD3->D3_DOC)
		oOrdServ:SetOrigem("SC2")
		If !(lRet := oOrdServ:CreateDCF())
			WmsMessage(oOrdServ:GetErro(),WMSXFUNH14,1)
		EndIf
	EndIf
	
RestArea(aAreaSD3)
RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
Function WmsDelOP(nRecSD3)
//------------------------------------------------------------------------------
Local aAreaAnt   := GetArea()
Local aAreaSD3   := SD3->(GetArea())
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oOrdSerDel := Nil
Local oDmdUnit   := Nil

	SD3->(MsGoTo(nRecSD3))
	If !lWmsNew
		lRet := WmsDelDCF("1","SD3")
	Else
		If SD3->D3_QUANT > 0 .AND. !Empty(SD3->D3_IDDCF)
			If WmsArmUnit(SD3->D3_LOCAL) 
				oDmdUnit := WMSDTCDemandaUnitizacaoDelete():New()
				oDmdUnit:SetIdD0Q(SD3->D3_IDDCF)
				oDmdUnit:LoadData()
				If !(lRet := oDmdUnit:DeleteD0Q())
					WmsMessage(oDmdUnit:GetErro(),WMSXFUNH02,1)
				EndIf
				FreeObj(oDmdUnit)
			Else
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
				oOrdSerDel:LoadData()
				If !(lRet := oOrdSerDel:DeleteDCF())
					WmsMessage(oOrdSerDel:GetErro(),WMSXFUNH07,1)
				EndIf
				FreeObj(oOrdSerDel)
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSD3)
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------------------
// Valida se na exclusão ou no encerramento da OP não existem 
// requisições no WMS que ainda não foram atendidas.
//------------------------------------------------------------------------------
Static Function ValIntReq(cOp,cTrt,cIdDCF,nQtdSD4Wms)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cWhere    := ""
Local cAliasQry := GetNextAlias()
Local nTamSx3   := TamSx3("D4_QUANT")

Default cTrt   := ""
Default cIdDCF := ""
	cWhere := "%"
	If !Empty(cTrt)
		cWhere += " AND SD4.D4_TRT = '"+cTrt+"'"
	EndiF
	If !Empty(cIdDCF)
		cWhere += " AND SD4.D4_IDDCF = '"+cIdDCF+"'"
	Else
		cWhere += " AND SD4.D4_IDDCF <> '"+Space(TamSx3("D4_IDDCF")[1])+"'"
	EndIf
	cWhere += "%"
	BeginSql Alias cAliasQry
		SELECT SUM(SD4.D4_QUANT) D4_QUANT,
				SUM(SDC.DC_QUANT) DC_QUANT
		FROM %Table:SD4% SD4
		LEFT JOIN %Table:SDC% SDC
		ON SDC.DC_FILIAL = %xFilial:SDC%
		AND SD4.D4_FILIAL = %xFilial:SD4%
		AND SDC.DC_PRODUTO = SD4.D4_COD
		AND SDC.DC_LOCAL = SD4.D4_LOCAL
		AND SDC.DC_OP = SD4.D4_OP
		AND SDC.DC_TRT = SD4.D4_TRT
		AND SDC.DC_IDDCF = SD4.D4_IDDCF
		AND SDC.%NotDel%
		WHERE SD4.D4_FILIAL = %xFilial:SD4%
		AND SD4.D4_OP = %Exp:cOp%
		AND SD4.D4_QTDEORI > 0
		AND SD4.%NotDel%
		%Exp:cWhere%
	EndSql
	TcSetField(cAliasQry,'D4_QUANT','N',nTamSx3[1],nTamSx3[2])
	TcSetField(cAliasQry,'DC_QUANT','N',nTamSx3[1],nTamSx3[2])
	If (cAliasQry)->(!Eof()) .And. (cAliasQry)->D4_QUANT > 0
		// Se recebeu o parametro, deve retornar o mesmo, caso contrário deve validar
		If ValType(nQtdSD4Wms) == "N"
			nQtdSD4Wms := (cAliasQry)->DC_QUANT
		Else
			If QtdComp((cAliasQry)->D4_QUANT) != QtdComp((cAliasQry)->DC_QUANT)
				WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cOp}}),WMSXFUNH06,,,,STR0007) // "A ordem de produção [VAR01] possui requisições pendentes de atendimento em ordens de serviço de separação no WMS."###"Aguarde a finalização da separação ou exclua a integração das requisições com o WMS para realizar esta operação."
				lRet := .F.
			EndIf
		EndIf
	EndIf 
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
// Executa as regras de Perda por OP relacionadas ao WMS
//------------------------------------------------------------------------------
Function WmsPerdaOP(nRecnoSBC,lEstorno,cProg)
Local oEstEnder := WMSDTCEstoqueEndereco():New()
Local lRet      := .T.

Default cProg	:= ""

	If !lEstorno
		lRet := oEstEnder:MakePerda(nRecnoSBC, cProg)
	Else
		lRet := oEstEnder:UndoPerda(nRecnoSBC)
	EndIf
	If !lRet
		WmsMessage(STR0011 + CRLF + CRLF + oEstEnder:GetErro(),WMSXFUNH16,2) // Problema na integração do Apontamento de Perda com o WMS:
	EndIf
	oEstEnder:Destroy()
Return lRet
//------------------------------------------------------------------------------
// Executa validações WMS na Perda por OP
//------------------------------------------------------------------------------
Function WMSVldPerda(lVldendori,cLocOri,cEnder)
Local lRet := .T.
Local oEndereco := Nil
Default lVldendori := .F. //Valida endereço 
Default cLocOri := ""
Default cEnder := ""

	If !lVldendori
		cLocOri := aCols[n,nPosLoc]
		cEnder := aCols[n,nPosLocFIs]
	EndIf 
	
	If !lVldendori .AND. !Empty(aCols[n,nPosLocDes]+aCols[n,nPosLocFDe]+aCols[n,nPosProDes])
		WmsMessage(STR0031,WMSXFUNH17,5) //"Não é permitido informar Local, Endereço ou Produto Destino para os produtos controlados pelo WMS. Funcionalidade pendente de desenvolvimento."
		lRet := .F.
	EndIf

	// validar aqui se a estrutura fisica do endereço informad e de produção.
	If lRet 
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(cLocOri)
		oEndereco:SetEnder(cEnder)
		If oEndereco:LoadData()	
			If oEndereco:GetTipoEst() <> 7 // Valida para que o apontamento da perda seja pra estrutura do tipo produção
				WmsMessage(STR0032,WMSXFUNH30,5) //"Não é permitido informar Endereço com estrutura diferente de Produção para apontamento de perda de produtos com controle WMS."
				lRet := .F.
			EndIf
		EndIf 
	EndIf 

Return lRet

//----------------------------------------
/*/{Protheus.doc} WmsSldD13
Compõe saldo do produto na database através dos movimentos WMS
@author Fagner Barreto
@since 11/07/2023
@version 1.0
/*/
//----------------------------------------
Function WmsSldD13(cLocal,cEndereco,cProduto,cNumSerie,cLoteCtl,cNumLote,dDataPerda)
	Local cAliasD13	:= GetNextAlias()
	Local nSaldo	:= 0
	Local cDtUlFech	:= DToS(SuperGetMv("MV_ULMES",.F.,"14990101"))
	Local cQuery	:= ""
	
	Default cLocal		:= ""
	Default cEndereco	:= ""
	Default cProduto	:= ""
	Default cNumSerie	:= ""
	Default cLoteCtl	:= ""
	Default cNumLote	:= ""
	DEFAULT dDataPerda	:= CTOD(" / / ")

	cQuery := " SELECT SUM(SALDO) SALDO " + CRLF
    cQuery += "	FROM ("	+ CRLF      
	cQuery += "		SELECT COALESCE( SUM(D15.D15_QINI) ,0) SALDO "	+ CRLF
	cQuery += "		FROM " + RetSQLName("D15") + " D15 "	+ CRLF
	cQuery += "		WHERE D15.D15_FILIAL = '" + xFilial("D15") + "' "	+ CRLF
	cQuery += "			AND D15.D15_LOCAL = '" + cLocal + "' "	+ CRLF
	cQuery += "			AND D15.D15_ENDER = '" + cEndereco + "' "	+ CRLF
	cQuery += "			AND D15.D15_PRDORI = '" + cProduto + "' "	+ CRLF
	cQuery += "			AND D15.D15_PRODUT = '" + cProduto + "' "	+ CRLF
	cQuery += "			AND D15.D15_LOTECT = '" + cLoteCtl + "' "	+ CRLF
	cQuery += "			AND D15.D15_NUMLOT = '" + cNumLote + "' "	+ CRLF
	cQuery += "			AND D15.D15_NUMSER = '" + cNumSerie + "' "	+ CRLF
	cQuery += "			AND D15.D15_DATA = '" + cDtUlFech + "' "	+ CRLF
	cQuery += "			AND D15.D_E_L_E_T_ = ' ' "	+ CRLF
	cQuery += "	UNION ALL "	+ CRLF
	cQuery += "		SELECT COALESCE( SUM(D13E.D13_QTDEST) ,0) SALDO "	+ CRLF
	cQuery += "		FROM " + RetSQLName("D13") + " D13E "	+ CRLF
	cQuery += "		WHERE D13E.D13_FILIAL = '" + xFilial("D13") + "' "	+ CRLF
	cQuery += "			AND D13E.D13_LOCAL = '" + cLocal + "' "	+ CRLF
	cQuery += "			AND D13E.D13_ENDER = '" + cEndereco + "' "	+ CRLF
	cQuery += "			AND D13E.D13_PRDORI = '" + cProduto + "' "	+ CRLF
	cQuery += "			AND D13E.D13_PRODUT = '" + cProduto + "' "	+ CRLF
	cQuery += "			AND D13E.D13_LOTECT = '" + cLoteCtl + "' "	+ CRLF
	cQuery += "			AND D13E.D13_NUMLOT = '" + cNumLote + "' "	+ CRLF
	cQuery += "			AND D13E.D13_NUMSER = '" + cNumSerie + "' "	+ CRLF
	cQuery += "			AND D13E.D13_DTESTO > '" + cDtUlFech + "' "	+ CRLF
	cQuery += "			AND D13E.D13_DTESTO <= '" + DToS(dDataPerda) + "' "	+ CRLF
    cQuery += "			AND D13E.D13_TM <= '499' "	+ CRLF
    cQuery += "			AND D13E.D13_USACAL = '1' "	+ CRLF //--Utiliza o registro no cálculo do saldo por endereço do período. / 1=Sim;2=Não
    cQuery += "			AND D13E.D_E_L_E_T_ = ' ' "	+ CRLF
	cQuery += "	UNION ALL "	+ CRLF
    cQuery += "		SELECT COALESCE( SUM(D13S.D13_QTDEST) ,0) * (- 1) SALDO "	+ CRLF
	cQuery += "		FROM " + RetSQLName("D13") + " D13S "	+ CRLF
	cQuery += "		WHERE D13S.D13_FILIAL = '" + xFilial("D13") + "' "	+ CRLF
	cQuery += "			AND D13S.D13_LOCAL = '" + cLocal + "' "	+ CRLF
	cQuery += "			AND D13S.D13_ENDER = '" + cEndereco + "' "	+ CRLF
	cQuery += "			AND D13S.D13_PRDORI = '" + cProduto + "' "	+ CRLF
	cQuery += "			AND D13S.D13_PRODUT = '" + cProduto + "' "	+ CRLF
	cQuery += "			AND D13S.D13_LOTECT = '" + cLoteCtl + "' "	+ CRLF
	cQuery += "			AND D13S.D13_NUMLOT = '" + cNumLote + "' "	+ CRLF
	cQuery += "			AND D13S.D13_NUMSER = '" + cNumSerie + "' "	+ CRLF
	cQuery += "			AND D13S.D13_DTESTO > '" + cDtUlFech + "' "	+ CRLF
	cQuery += "			AND D13S.D13_DTESTO <= '" + DToS(dDataPerda) + "' "	+ CRLF
    cQuery += "			AND D13S.D13_TM > '499' "	+ CRLF
    cQuery += "			AND D13S.D13_USACAL = '1' "	+ CRLF //--Utiliza o registro no cálculo do saldo por endereço do período. / 1=Sim;2=Não
	cQuery += "			AND D13S.D_E_L_E_T_ = ' ' "	+ CRLF
    cQuery += "	)TMP "	+ CRLF

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasD13, .T., .T. )

	(cAliasD13)->( DbGoTop() )
	If (cAliasD13)->( !Eof() )
		nSaldo := (cAliasD13)->SALDO
	EndIf
	(cAliasD13)->( DbCloseArea() )

Return nSaldo

//----------------------------------------
/*/{Protheus.doc} WmsBxEmp
Efetua baixa de empenho
@author Fagner Barreto
@since 14/09/2023
@version 1.0
/*/
//----------------------------------------
Function WmsBxEmp(nRecnoSBC, nQuant)
	Local oEstEnder	:= WMSDTCEstoqueEndereco():New()
	Local oProdLote	:= WMSDTCProdutoLote():New()
	Local lRet		:= .T.
	Local aAreaSBC	:= SBC->(GetArea())
	Local aProduto	:= {}
	Local nProduto	:= 0

	Default	nRecnoSBC	:=	0
	Default nQuant		:=	0

	If nRecnoSBC > 0
		SBC->(dbGoTo(nRecnoSBC))
		oProdLote:SetArmazem(SBC->BC_LOCORIG)
		oProdLote:SetPrdOri(SBC->BC_PRODUTO)
		oProdLote:SetProduto(SBC->BC_PRODUTO)
		oProdLote:SetLoteCtl(SBC->BC_LOTECTL)
		oProdLote:SetNumLote(SBC->BC_NUMLOTE)
		oProdLote:SetNumSer(SBC->BC_NUMSERI)
		oProdLote:LoadData()

		// Carrega estrutura do produto x componente
		aProduto := oProdLote:GetArrProd()
		If Len(aProduto) > 0
			For nProduto := 1 To Len(aProduto)
				
				//Informações do endereço
				oEstEnder:oEndereco:SetArmazem(oProdLote:GetArmazem())
				oEstEnder:oEndereco:SetEnder(SBC->BC_LOCALIZ)
				oEstEnder:oEndereco:LoadData()
				// Informações do produto
				oEstEnder:oProdLote:SetArmazem(oProdLote:GetArmazem())
				oEstEnder:oProdLote:SetPrdOri(oProdLote:GetPrdOri())
				oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1] )
				oEstEnder:oProdLote:SetLoteCtl(oProdLote:GetLotectl())
				oEstEnder:oProdLote:SetNumLote(oProdLote:GetNumLote())
				oEstEnder:oProdLote:SetNumSer(oProdLote:GetNumSer())
				oEstEnder:oProdLote:LoadData()
				oEstEnder:SetQuant(nQuant)
				//--Efetua a baixa de empenho
				lRet := oEstEnder:UpdSaldo("999",.F. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.T. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.F./*lMovEstEnd*/)
			Next
		EndIf	
	EndIf

	If !lRet
		WmsMessage(STR0011 + CRLF + CRLF + oEstEnder:GetErro(),WMSXFUNH16,2) // Problema na integração do Apontamento de Perda com o WMS:
	EndIf

	oProdLote:Destroy()
	oEstEnder:Destroy()
	RestArea(aAreaSBC)
Return lRet

//----------------------------------------
/*/{Protheus.doc} WMS241SlOp
Validacoes para baixa no MATA241
@author Equipe WMS
@since 23/11/2023
@version 1.0
/*/
//----------------------------------------
Function WMS241SlOp(cTm,cProduto,cOp,cServ,cLocal,cEnd,cLoteDigi,cLote,nQuant,cTRT,cEnd,nSaldoD14)
	Local aArea := GetArea()
	Local lRet := .T.

	If !Empty(cServ) .Or. Empty(cOp) 
		lRet := .F.
	EndIf

	If lRet .And. SF5->(dbSeek(xFilial("SF5")+cTm))
		If SF5->F5_ATUEMP == "N"
			WmsMessage(WmsFmtMsg(STR0033,{{"[VAR01]",cTm}}),WMSXFUNH31,5,.T.)//"O tipo de movimentação [VAR01] não atualiza empenho. A quantidade disponível no endereço é menor do que a quantidade informada."
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If !WMS241D4Sl(cProduto, cLocal, cOp, cLoteDigi, cLote, cTRT, cEnd, nQuant, nSaldoD14 )
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)

Return lRet

//----------------------------------------
/*/{Protheus.doc} WMSEmpSDC
Valida existe empenho na SDC
@author Equipe WMS
@since 10/11/2023
@version 1.0
/*/
//----------------------------------------
Function WMSEmpSDC(nD3Quant)
	Local aArea      := GetArea()
	Local lCriaSDC   :=.F.
	Local nQuantDC   :=0
	Local nQuantDC2  :=0
	Local lRetRastro := Rastro(SD4->D4_COD)
	Local cD4LOTECTL := SD3->D3_LOTECTL
	Local cD4NUMLOTE := SD3->D3_NUMLOTE
	Local nRecSDC    := 0
	Local cCompara   := ""
	Local cSeek      := ""

	//-- Procura por Empenhos de produtos sem controle de rastreabilidade
	If !(lRetRastro)
		cSeek:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT
		cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT)"
		//-- Procura por Empenhos que nao tiveram escolha de Lote e/ou Sub-lote
	ElseIf Empty(cD4LOTECTL)
		cSeek    := xFilial('SDC')+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+Space(Len(SDC->DC_LOTECTL))+Space(Len(SDC->DC_NUMLOTE))
		cCompara := 'SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE)'
	Else
		If Rastro(SD4->D4_COD,"L")
			// Procura por empenho com lote
			cSeek:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+cD4LOTECTL
			cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL)"
		Else
			// Procura por empenho com lote+sub-lote
			cSeek:=xFilial("SDC")+SD4->D4_COD+SD4->D4_LOCAL+SD4->D4_OP+SD4->D4_TRT+cD4LOTECTL+cD4NUMLOTE
			cCompara:="SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_OP+DC_TRT+DC_LOTECTL+DC_NUMLOTE)"
		EndIf
	EndIf

	//Caso nao encontre os empenhos no SDC ou nao tenha quantidade suficiente empenhada, cria o SDC agora.   
	SDC->(DbSetOrder(2))                      
	If !SDC->(dbSeek(cSeek))
		lCriaSDC:=.T.
	Else
		nRecSDC:=Recno()
		nQuantDC:=0
		Do While !Eof() .And. cSeek == &cCompara
			nQuantDC+=SDC->DC_QUANT
			SDC->(dbSkip())
		EndDo
		If nQuantDC < nD3Quant
			lCriaSDC:= .T.
		EndIf
		SDC->(MsGoto(nRecSDC))
	EndIf

	RestArea(aArea)
	If nRecSDC > 0
		SDC->(MsGoto(nRecSDC))
	EndIf

Return lCriaSDC

//----------------------------------------
/*/{Protheus.doc} WMSEmpSDC
Realiza validações e baixas quando executado via MATA241 sem servico e com OP
@author Equipe WMS
@since 10/11/2023
@version 1.0
/*/
//----------------------------------------
Function WMS241Baix()
	Local lCriaSDC  := .F.
	Local aArea := GetArea()
	Local cFilDelDC := ""
	Local lRet := .T.
	Local lEmpD14 := SD3->D3_EMPOP = "S"
			
	//Valida se deve criar SDC
	lCriaSDC :=	WMSEmpSDC(SD3->D3_QUANT)
		
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial("SC2")+Alltrim(SD3->D3_OP)))
		nPercPrM := (SD3->D3_QTMAIOR / SC2->C2_QUANT)
	EndIf

	If lCriaSDC
		lRet := WmsEmpReq("SD3",SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_QUANT,SD3->D3_LOCALIZ,SD3->D3_LOTECTL,SD3->D3_NUMLOTE,/*cNumSerie*/,SD3->D3_OP,SD3->D3_TRT,/*cIdDCF*/,/*cIdUnitiz*/,.F./*lEstorno*/,lCriaSDC,lEmpD14)
	EndIf
	If lRet
		lRet := WmsBaixaReq(SD3->(Recno()),lCriaSDC)
	EndIf
	If lRet .And. lCriaSDC
		cFilDelDC := "DC_FILIAL == '" +xFilial("SDC") +"' .And. DC_PRODUTO = '" +SD3->D3_COD +"' .And. "
		cFilDelDC += "AllTrim(DC_ORIGEM) == 'SD3' .And. DC_OP == '" +SD3->D3_OP +"'"

		SDC->(dbSetFilter({|| &cFilDelDC}, cFilDelDC))
		SDC->(dbGoTop())
		While SDC->(!EOF())
			RecLock("SDC",.F.)
			SDC->(dbDelete())
			SDC->(MsUnLock())
			SDC->(dbSkip())
		EndDo
		SDC->(dbClearFilter())
	EndIf


	If !lRet .And. InTransact()
		DisarmTransaction()
	EndIf
	RestArea(aArea)

Return lRet


/*/{Protheus.doc} WMSApMaior
	(Valida se baixou toda a SD4)
	@type  Function
	@author equipe wms
	@since 21/11/2023
	@version 1.0
	@return lRet, boolean, baixou a SD4
	/*/
Static Function WMSBxTotOp()
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cArmazem  := GdFieldGet('D3_LOCAL',n)
	Local cDocOp    := GdFieldGet('D3_OP',n)
	Local cProd     := GdFieldGet('D3_COD',n)
	Local cServic   := GdFieldGet('D3_SERVIC',n)
	Local nQtd      := 0

	If Empty(cServic) .And. !Empty(cDocOp)
		SD4->(DbSetOrder(2))
		If SD4->(DbSeek(FWxFilial("SD4")+cDocOp+cProd+cArmazem))
			While SD4->(!Eof()) .And. SD4->D4_FILIAL == FWxFilial("SD4") .And. SD4->D4_OP == cDocOp .And. ;
				SD4->D4_COD == cProd .And.  SD4->D4_LOCAL == cArmazem
					nQtd += SD4->D4_QUANT
				SD4->(DbSkip())
			EndDo
		EndIf
		If nQtd > 0
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet



//----------------------------------------
/*/{Protheus.doc} WMSAptMais
Validacoes para baixa no MATA241. Apontamento maior do que o empenhado
@author Equipe WMS
@since 23/11/2023
@version 1.0
/*/
//----------------------------------------
Function WMSAptMais(nQtd)
	Local aArea	   := GetArea()
	Local nQuant   :=  0
	Local lRet     := .T.
	Local cNumOP   := GdFieldGet('D3_OP',n)
	Local cProduto := GdFieldGet('D3_COD',n)
	Local nQtdInfo := nQtd
	Local cTRT     := GdFieldGet('D3_TRT',n)
	Local cLoteCtl := GdFieldGet('D3_LOTECTL',n)
	Local cNumLote := GdFieldGet('D3_NUMLOTE',n)
	Local cEnd := GdFieldGet('D3_LOCALIZ',n)
	Local cServic   := GdFieldGet('D3_SERVIC',n)

	If Empty(cServic) .And. !Empty(cNumOP)
		SD4->(dbSetOrder(1))
		If SD4->(dbSeek(xFilial("SD4")+cProduto+cNumOP+cTRT+cLoteCtl+cNumLote))
			SDC->(dbSetOrder(2))
			IF SDC->(dbSeek(xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE+cEnd)))
				nQuant := SDC->DC_QUANT
			EndIf
		EndIf

		If nQuant > 0 .And. nQtdInfo > nQuant
			//Não temos mensagem a exibir neste momento, pois retornando .F. o processo é
			//confirmado da mesma forma. Ver a função WMS241D4Sl
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet


//----------------------------------------
/*/{Protheus.doc} WMS241D4Sl
Validacoes para baixa no MATA241
@author Equipe WMS
@since 23/11/2023
@version 1.0
/*/
//----------------------------------------
Function WMS241D4Sl(cProduto, cLocal, cNumOP, cLoteCtl, cNumLote, cTRT, cEnd, nQtdInfo, nSaldoD14 )
Local aArea	:= GetArea()
Local nQuant :=  0
Local lRet   := .T.

	SD4->(dbSetOrder(1))
	If SD4->(dbSeek(xFilial("SD4")+cProduto+cNumOP+cTRT+cLoteCtl+cNumLote))
		SDC->(dbSetOrder(2))
		IF SDC->(dbSeek(xFilial("SDC")+SD4->(D4_COD+D4_LOCAL+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE+cEnd)))
			nQuant := SDC->DC_QUANT
		EndIf
	EndIf

	nSaldoD14 += nQuant
	If QtdComp(nSaldoD14) <  QtdComp(nQtdInfo)
		WmsMessage(WmsFmtMsg(STR0034,{{"[VAR01]",cProduto}}),WMSXFUNH32,5,.T.)//"O produto [VAR01] não possui saldo para a baixa da ordem de produção. 
		//Utilize a funcionalidade  do botão Outras Ações > 1o.Nível para obter os dados da ordem de produção corretamente."
		lRet := .F.
	EndIf
	If lRet .And. nQuant > 0 .And. nQtdInfo > nQuant
		WmsMessage(WmsFmtMsg(STR0035,{{"[VAR01]",cNumOP}}),WMSXFUNH33,5,.T.)//"O saldo livre disponível no endereço de produção é menor que a quantidade informada. 
		//Diminua a quantidade ou utilize o primeiro nível (botão Outras Ações > 1o.Nível) para obter as quantidades da ordem de produção [VAR01] para baixa."
		lRet := .F.
	EndIf
	RestArea(aArea)

Return lRet

