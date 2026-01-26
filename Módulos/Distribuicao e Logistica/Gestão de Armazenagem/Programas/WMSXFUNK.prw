#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNK.CH"
/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNK - Funções WMS Integração com Liberação Qualidade          |
+---------+--------------------------------------------------------------------+
|Objetivo | Deverá agrupar todas as funções que serão utilizadas em            |
|         | integrações que estejam relacionadas com o processo de liberação   |
|         | de qualidade.                                                      |
|         | Validações, Integração, Estorno...                                 |
+---------+--------------------------------------------------------------------+
*/

#define WMSXFUNK01 "WMSXFUNK01"
#define WMSXFUNK02 "WMSXFUNK02"
#define WMSXFUNK03 "WMSXFUNK03"
#define WMSXFUNK04 "WMSXFUNK04"
#define WMSXFUNK05 "WMSXFUNK05"
#define WMSXFUNK06 "WMSXFUNK06"
#define WMSXFUNK07 "WMSXFUNK07"
#define WMSXFUNK08 "WMSXFUNK08"
#define WMSXFUNK09 "WMSXFUNK09"
#define WMSXFUNK10 "WMSXFUNK10"
#define WMSXFUNK11 "WMSXFUNK11"
#define WMSXFUNK12 "WMSXFUNK12"

//------------------------------------------------------------------------------
// Efetua as validações na integração de CQ com o WMS
//------------------------------------------------------------------------------
Function WMSAvalSD7(cAcao,nRecSD7)
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local nPosServic := 0
Local nPosLoclz  := 0
Local nPosLocDes := 0
Local oOrdSerDel := Nil
Local oDmdUniDel := Nil
Local lRet       := .T.

Default nRecSD7 := 0

	If nRecSD7 > 0
		SD7->(MsGoTo(nRecSD7))
	EndIf
	If cAcao == "1" // Utilizado no A175LinOk
		nPosServic := aScan(aHeader,{|x| Alltrim(x[2]) == 'D7_SERVIC' })
		// Valida se o serviço foi informado e se o mesmo é válido
		If nPosServic > 0
			If lWmsNew
				If !(Empty(aCols[n,nPosServic]))
					If !(Posicione("DC5",1,xFilial('DC5')+aCols[n,nPosServic],"DC5_OPERAC") $ "1|2")
						WmsMessage(STR0001,WMSXFUNK01,1) // "Somente serviços WMS do tipo Entrada podem ser utilizados."
						lRet := .F.
					EndIf
				Else
					WmsMessage(STR0002,WMSXFUNK02,1) // "Produtos com controle WMS devem obrigatoriamente ter o serviço WMS informado."
					lRet := .F.
				EndIf
			Else
				If !(Empty(aCols[n,nPosServic])) .And. Posicione("DC5",1,xFilial('DC5')+aCols[n,nPosServic],"DC5_TIPO") != "1"
					WmsMessage(STR0001,WMSXFUNK03,1) // "Somente serviços WMS do tipo Entrada podem ser utilizados."
					lRet := .F.
				EndIf
			EndIf
		EndIf
		
		If lWmsNew
			nPosLocDes := aScan(aHeader,{|x| Alltrim(x[2]) == 'D7_LOCDEST'})
			nPosLoclz  := aScan(aHeader,{|x| Alltrim(x[2]) == 'D7_LOCALIZ'})
			If !Empty(aCols[n,nPosLoclz])
				SBE->(DbSetOrder(1)) //BE_FILIAL, BE_LOCAL, BE_LOCALIZ
				If !SBE->(DbSeek(xFilial("SBE")+aCols[n,nPosLocDes]+aCols[n,nPosLoclz]))
					WmsMessage(STR0007,WMSXFUNK12,5,,,STR0008) // "Endereço não cadastrado no armazém destino."##"Para integração com o WMS é necessário ter o mesmo endereço de qualidade cadastrado no armazém CQ e armazém destino."
					lRet := .F.
				EndIf
			EndIf
		EndIf

	ElseIf cAcao == "2" // Utilizado no A175GetDad
		If !lWmsNew
			If WmsChkDCF('SD3',,,SD7->D7_SERVIC,'3',,SD7->D7_NUMERO,,,,SD7->D7_LOCDEST,SD7->D7_PRODUTO,,,SD7->D7_NUMSEQ)
				lRet := WmsAvalDCF('2')
			EndIf
		Else
			// Posiciona no SD3 do registro de movimentação original para pegar o IDDCF
			SD3->(DbSetOrder(4)) // D3_FILIAL, D3_NUMSEQ, D3_CHAVE, D3_COD
			If SD3->(DbSeek(xFilial("SD3")+SD7->D7_NUMSEQ+'E9'))
				If WmsArmUnit(SD7->D7_LOCDEST)
					oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
					oDmdUniDel:SetIdD0Q(SD3->D3_IDDCF)
					If oDmdUniDel:LoadData()
		 				If !oDmdUniDel:CanDelete()
				 			cMessage := Iif(SD7->D7_TIPO==2,STR0004,STR0003) + STR0005 + " - DU "+LTrim(oDmdUniDel:GetDocto())+" - ID "+oDmdUniDel:GetIdD0Q() // Rejeição CQ##Liberação CQ##integrado ao SIGAWMS
				 			cMessage += CRLF + oDmdUniDel:GetErro()
		 					WmsMessage(cMessage,WMSXFUNK04,1)
		 					lRet := .F.
		 				EndIf
		 			EndIf
				Else
					oOrdSerDel := WMSDTCOrdemServicoDelete():New()
					oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
					If oOrdSerDel:LoadData()
						If !oOrdSerDel:CanDelete()
							cMessage := Iif(SD7->D7_TIPO==2,STR0004,STR0003) + STR0005 + " - OS "+LTrim(oOrdSerDel:GetDocto())+" - ID "+oOrdSerDel:GetIdDCF() // Rejeição CQ##Liberação CQ##integrado ao SIGAWMS
							cMessage += CRLF + oOrdSerDel:GetErro()
							WmsMessage(cMessage,WMSXFUNK05,1)
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Else
				WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",SD7->D7_NUMSEQ}}),WMSXFUNK11,1) // Não foi possível encontrar a movimentação de entrada Num.Seq/CF: [VAR01]/E9 (SD3)
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Efetua a integração do registro de liberação de CQ com o WMS
//------------------------------------------------------------------------------
Function WmsIntCQ(nRecSD7)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaAnt   := GetArea()

Default nRecSD7 := 0
	// No WMS Atual não integra desta forma - Gera endereçamento a partir da SD3
	If !lWmsNew
		Return .T.
	EndIf
	If !WmsSkipCQ()
		If nRecSD7 > 0
			SD7->(MsGoTo(nRecSD7))
		EndIf
	
		// Deve efetuar a movimentação de estoque no WMS para esta sequencia da SD7
		lRet := MovEstCQ('999')
		
		If lRet 
			lRet := IntServCQ()
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
// Efetua o estorno da integração do registro de liberação de CQ
//------------------------------------------------------------------------------
Function WmsEstCQ(nRecSD7,nRecSD3)
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local aAreaAnt   := GetArea()
Local cAliasD13  := Nil

Default nRecSD7 := 0
Default nRecSD3 := 0

	If nRecSD7 > 0
		SD7->(MsGoTo(nRecSD7))
	EndIf
	If nRecSD3 > 0
		SD3->(MsGoTo(nRecSD3))
	EndIf
	If !lWmsNew
		lRet := WmsDelDCF("1","SD3",SD3->D3_IDDCF)
	Else
		lRet := EstServCQ()
		// Deve efetuar a movimentação de estoque no WMS para esta sequencia da SD7
		If lRet
			lRet := MovEstCQ('499',.T.)
		EndIf
		If lRet
			// Verifica os movimentos da ordem de serviço origem para desconsiderar
			// no cálculo de estoque 
			If lRet .And. WmsX312118("D13","D13_USACAL")
				cAliasD13 := GetNextAlias()
				BeginSql Alias cAliasD13
					SELECT D13.R_E_C_N_O_ RECNOD13
					FROM %Table:D13% D13
					WHERE D13.D13_FILIAL = %xFilial:D13%
					AND D13.D13_DOC = %Exp:SD7->D7_NUMERO%
					AND D13.D13_NUMSEQ = %Exp:SD7->D7_NUMSEQ%
					AND D13.D13_ORIGEM = 'SD7'
					AND D13.D13_USACAL <> '2'
					AND D13.%NotDel%
				EndSql
				Do While (cAliasD13)->(!Eof())
					D13->(dbGoTo((cAliasD13)->RECNOD13))
					RecLock("D13",.F.)
					D13->D13_USACAL = '2'
					D13->(MsUnLock())
					(cAliasD13)->(dbSkip())
				EndDo
				(cAliasD13)->(dbCloseArea())
			EndIf	
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//------------------------------------------------------------------------------
// Efetua a movimentação de estoque no WMS (D14)
//------------------------------------------------------------------------------
Static Function MovEstCQ(cTipo,lEstorno)
Local lRet       := .T.
Local aAreaSD7   := {}
Local cSubLotOri := ""
Local aProduto   := {}
Local nProduto   := 0
Local oEstEnder  := WMSDTCEstoqueEndereco():New()

Default lEstorno := .F.

	// Caso o produto controle sub-lote deve buscar o sub-lote origem da movimentação
	If Rastro(SD7->D7_PRODUTO,"S")
		aAreaSD7 := SD7->(GetArea())
		// Busca a sequencia original da SD7 para pegar o sub-lote origem
		If (lRet:= SD7->(DbSeek(SD7->D7_FILIAL+SD7->D7_NUMERO+SD7->D7_PRODUTO+SD7->D7_LOCAL+'001', .F.)))
			cSubLotOri := SD7->D7_NUMLOTE
		EndIf
		RestArea(aAreaSD7)
	EndIf

	// Atualiza Saldo
	// Carrega estrutura do produto x componente
	oEstEnder:oProdLote:SetProduto(SD7->D7_PRODUTO)
	oEstEnder:oProdLote:oProduto:CreateArr()
	aProduto := oEstEnder:oProdLote:oProduto:GetArrProd()
	For nProduto := 1 To Len(aProduto)
		// Carrega dados para Estoque por Endereço
		oEstEnder:oEndereco:SetArmazem(SD7->D7_LOCAL)
		oEstEnder:oEndereco:SetEnder(SD7->D7_LOCALIZ)
		oEstEnder:oProdLote:SetArmazem(SD7->D7_LOCAL)          // Armazem
		oEstEnder:oProdLote:SetPrdOri(SD7->D7_PRODUTO)         // Produto Origem
		oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1])  // Componente
		oEstEnder:oProdLote:SetLoteCtl(SD7->D7_LOTECTL)        // Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumLote(cSubLotOri)             // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumSer(SD7->D7_NUMSERI)         // Numero de serie
		oEstEnder:SetQuant(SD7->D7_QTDE * aProduto[nProduto][2])
		// Seta o bloco de código para informações do documento
		oEstEnder:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem("SD7"),;
			oMovEstEnd:SetDocto(SD7->D7_NUMERO),;
			oMovEstEnd:SetSerie(""),;
			oMovEstEnd:SetCliFor(SD7->D7_FORNECE),;
			oMovEstEnd:SetLoja(SD7->D7_LOJA),;
			oMovEstEnd:SetNumSeq(SD7->D7_NUMSEQ),;
			oMovEstEnd:SetIdDCF("");
		})
		// Seta o bloco de código para informações do movimento
		oEstEnder:SetBlkMov({|oMovEstEnd|;
			oMovEstEnd:SetIdMovto(""),;
			oMovEstEnd:SetIdOpera(""),;
			oMovEstEnd:SetIdUnit(""),;
			oMovEstEnd:SetlUsaCal(!lEstorno);
		})
		// Realiza Entrada/Saída Armazem Origem Estoque por Endereço
		If !(lRet := oEstEnder:UpdSaldo(cTipo,.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/))
			WmsMessage(oEstEnder:GetErro(),WMSXFUNK06,1)
			Exit
		EndIf
	Next

Return lRet

//------------------------------------------------------------------------------
// Efetua a integração do CQ com o serviço WMS - Endereçamento ou Demanda de Unitização
//------------------------------------------------------------------------------
Static Function IntServCQ()
Local lRet       := .T.
Local oOrdServ   := WmsOrdSer() // Busca referencia do objeto WMS
Local oDmdUnit   := Nil

	// Se o armazém destino é unitizado, deve gerar uma demanda de unitização
	If WmsArmUnit(SD7->D7_LOCDEST)
		oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
		oDmdUnit:SetOrigem('SD7')
		oDmdUnit:SetDocto(SD7->D7_NUMERO)
		oDmdUnit:SetNumSeq(SD7->D7_NUMSEQ)
		oDmdUnit:oProdLote:SetProduto(SD7->D7_PRODUTO)
		// Gera a demanda de unitização gerando a entrada com base nos endereços escolhidos
		If !(lRet := oDmdUnit:CreateD0Q())
			WmsMessage(oDmdUnit:GetErro(),WMSXFUNK07,1)
		EndIf
	// Senão simplesmente gera uma ordem de serviço para a quantidade da SD7
	Else
		//-- Somente cria a ordem de serviço na primeira vez
		If oOrdServ == Nil
			oOrdServ := WMSDTCOrdemServicoCreate():New()
			WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
		EndIf
		oOrdServ:SetOrigem('SD7')
		oOrdServ:SetDocto(SD7->D7_NUMERO)
		oOrdServ:SetNumSeq(SD7->D7_NUMSEQ)
		oOrdServ:oProdLote:SetProduto(SD7->D7_PRODUTO)
		// Gera a ordem de serviço gerando a entrada com base nos endereços escolhidos
		If !(lRet := oOrdServ:CreateDCF())
			WmsMessage(oOrdServ:GetErro(),WMSXFUNK08,1)
		EndIf
		//Quando o serviço está configurado para execução automática.
		If lRet .AND. oOrdServ:oServico:GetTpExec() == "2" .AND. !Empty(oOrdServ:aLibDCF)
			lRet := WmsExeServ(.F./*lIsJob*/,.T./*lEncExe*/) 
    	EndIf
	EndIf
Return lRet

//------------------------------------------------------------------------------
// Efetua o estorno da integração do CQ com o serviço WMS - Endereçamento ou Demanda de Unitização
//------------------------------------------------------------------------------
Static Function EstServCQ()
Local lRet       := .T.
Local oOrdSerDel := Nil
Local oDmdUniDel := Nil

	If WmsArmUnit(SD7->D7_LOCDEST) 
		oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
		oDmdUniDel:SetIdD0Q(SD3->D3_IDDCF)
		oDmdUniDel:LoadData()
	 	If !(lRet := oDmdUniDel:DeleteD0Q())
 			WmsMessage(oDmdUniDel:GetErro(),WMSXFUNK09,1)
 		EndIf
		FreeObj(oDmdUniDel)
	Else
		oOrdSerDel := WMSDTCOrdemServicoDelete():New()
		oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
		oOrdSerDel:LoadData()
		If !(lRet := oOrdSerDel:DeleteDCF())
			WmsMessage(oOrdSerDel:GetErro(),WMSXFUNK10,1)
		EndIf
		FreeObj(oOrdSerDel)
	EndIf

Return lRet
//------------------------------------------------------------------------------
// Retorna in da liberação da SD7 
// Utilizado apenas para processos com skip lote
//------------------------------------------------------------------------------
Function WmsRecSD7(cProduto,cNumSeq)
Local aAreaAnt   := GetArea()
Local cAliasSD7  := GetNextAlias()
Local nRecno     := 0
	BeginSql Alias cAliasSD7
		SELECT SD7B.R_E_C_N_O_ RECNOSD7,
				SD7B.D7_NUMSEQ,
				SD7A.D7_LOCDEST
		FROM %Table:SD7% SD7A
		INNER JOIN %Table:SD7% SD7B
		ON SD7B.D7_FILIAL  = %xFilial:SD7%
		AND SD7B.D7_NUMERO = SD7A.D7_NUMERO
		AND SD7B.D7_PRODUTO = SD7A.D7_PRODUTO
		AND SD7B.D7_TIPO = '1'
		AND SD7B.%NotDel%
		WHERE SD7A.D7_FILIAL  = %xFilial:SD7%
		AND SD7A.D7_PRODUTO = %Exp:cProduto%
		AND SD7A.D7_NUMSEQ  = %Exp:cNumSeq%
		AND SD7A.%NotDel%
	EndSql
	If (cAliasSD7)->(!Eof())
		nRecno := (cAliasSD7)->RECNOSD7
	EndIf
	(cAliasSD7)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nRecno
//-------------------------------------
/*/{Protheus.doc} WMSConfer
Verifica se função foi chamada pela conferência WMS.
Atualmente chamado da rotina MATA240 para evitar a validação de CQ.
@author amanda.vieira
@since 30/09/2020
/*/
//-------------------------------------
Function WMSConfer()
Return IsInCallStack("WMSA320") .Or. IsInCallStack("WMSV090")
