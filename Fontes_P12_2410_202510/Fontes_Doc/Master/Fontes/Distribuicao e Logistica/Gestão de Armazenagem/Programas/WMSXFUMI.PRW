#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUMI.CH"

#DEFINE WMSXFUMI01 "WMSXFUMI01"
#DEFINE WMSXFUMI02 "WMSXFUMI02"
#DEFINE WMSXFUMI03 "WMSXFUMI03"
#DEFINE WMSXFUMI04 "WMSXFUMI04"
#DEFINE WMSXFUMI05 "WMSXFUMI05"
#DEFINE WMSXFUMI06 "WMSXFUMI06"
#DEFINE WMSXFUMI07 "WMSXFUMI07"
#DEFINE WMSXFUMI08 "WMSXFUMI08"
#DEFINE WMSXFUMI09 "WMSXFUMI09"
#DEFINE WMSXFUMI10 "WMSXFUMI10"
#DEFINE WMSXFUMI11 "WMSXFUMI11"
#DEFINE WMSXFUMI12 "WMSXFUMI12"
/*-----------------------------------------------------------------------
	Funções de Integração com o Mercado Internacional 
------------------------------------------------------------------------*/

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsFatMI()
Realiza a movimentação de estoque ao faturar um remito (MI).
@type function
@author Wander Horongoso
@version 12.1.2210
@since 08/06/2022
@param
Pedido: número do pedido
Item: código do item do pedido
Sequencia: número de sequência do pedido
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Function WmsFatMI(cPedido, cItem, cSeq, cProd,lSc9,cEspecie)
Local lRet := .T. 
Local cQry := ''
Local oEstEnder := nil
Default lSc9:= .T. 
	 
	If SuperGetMV("MV_WMSNEW",.F.,.F.) .And. IntWms(cProd)
		If !lSc9 .AND. Alltrim(cEspecie) == "RTS" 
			lRet := WmsIntSD2(cEspecie) 
		Else
		   IF !lSc9 .AND. (Alltrim(cEspecie) == "RCD" .OR. (AllTrim(cEspecie) == "NCP" .And. FwIsInCallStack('MATA466N'))) 
				//Baixa estoque na DOCA para o documento 
				If lRet
					oEstEnder := WMSDTCEstoqueEndereco():New()
					lRet := oEstEnder:MakeFtMI(SD2->(Recno()),/*ID_DCF*/,SD2->D2_LOCALIZ,.F. /*baixa direto estoque sem atualiza empenho*/ )
					If !lRet 
						WmsMessage(oOrdServ:GetErro()+" "+STR0001,WMSXFUMI01,,,,STR0002)  //"Erro ao Baixar Estoque WMS (D14)."  //"Movimentos WMS não executados."
					EndIF
				EndIF 
				//RestArea(aAreaAnt)
		   Else
			 	cQry := GetNextAlias()
				BeginSQL Alias cQry
					SELECT R_E_C_N_O_
					FROM %Table:SC9% 
					WHERE C9_FILIAL = %xFilial:SC9%
					AND C9_PEDIDO = %Exp:cPedido%
					AND C9_ITEM = %Exp:cItem%
					AND C9_SEQUEN = %Exp:cSeq%
					AND %NotDel%
				EndSQL
				If !(cQry)->(Eof())
					oEstEnder := WMSDTCEstoqueEndereco():New()
					lRet := oEstEnder:MakeFatur((cQry)->R_E_C_N_O_)
				EndIf

				(cQry)->(dbCloseArea())
			EndIf
		EndIF 
	EndIf
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsIntSD2()
Realiza a movimentação de estoque ao faturar um remito de Transferência(MI).
@type function
@author Roselaine Adriano
@version 12.1.2210
@since 05/10/2022
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Static Function WmsIntSD2(cEspecie)
Local lRet     := .T.
Local oOrdServ := Nil
Local aAreaAnt := GetArea()
Local oMovimento := WMSBCCMovimentoServico():New()
Local cAliasQry:= Nil
Local cAliasDCF:= Nil 

	If !FWIsIncallStack("MATA462TN") .OR. Alltrim(cEspecie) <> "RTS"
		Return lRet
	EndIf
	If oOrdServ == Nil
		oOrdServ := WMSDTCOrdemServicoCreate():New()
		WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
	EndIf
	oOrdServ:SetDocto(SD2->D2_DOC)
	oOrdServ:SetSerie(SD2->D2_SERIE)
	oOrdServ:oProdLote:SetProduto(SD2->D2_COD)
	oOrdServ:SetNumSeq(SD2->D2_NUMSEQ)
	oOrdServ:SetOrigem('SD2')
	//busca através do numero do documento da Sd2 o ultimos local destino na tabela DCF para setar os dados para o proxmo 
	cAliasDCF:= GetNextAlias()
	BeginSql Alias cAliasDCF
		SELECT DISTINCT DCF_ENDDES
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF_DOCTO = %Exp:SD2->D2_DOC%
		AND DCF_SERIE = %Exp:SD2->D2_SERIE%
		AND DCF_STSERV = '3'
		AND DCF.DCF_CLIFOR = %Exp:SD2->D2_CLIENTE%
		AND DCF.DCF_LOJA = %Exp:SD2->D2_LOJA%
		AND DCF.DCF_SERVIC = %Exp:SD2->D2_SERVIC%
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
	    //Se ja havia Setado o endereco setar para o proximo produto automatico sem abrir a tela. 
		oOrdServ:oOrdEndDes:SetEnder((cAliasDCF)->DCF_ENDDES)
	ENDIF
	(cAliasDCF)->(DbCloseArea())

	If !oOrdServ:CreateDCF()
		WmsMessage(oOrdServ:GetErro(),"WmsIntSD2",1)
		lRet := .F.
	EndIf

	//Depois que criou a DCf ja executa e finaliza os movimentos 
	//Executa ordem de serviço
	If lRet
		AAdd(oOrdServ:aLibDCF,oOrdServ:GetIdDCF())
		lRet := WmsExeServ(.F.,.T.,,.F.)
	EndIf

	//Finaliza movimentação oOrdServ:oProdlote:oProduto:GetEndSai()
	If lRet
		cAliasQry:= GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_DOC = %Exp:SD2->D2_DOC%
			AND D12.D12_SERIE = %Exp:SD2->D2_SERIE%
			AND D12.D12_CLIFOR = %Exp:SD2->D2_CLIENTE%
			AND D12.D12_LOJA = %Exp:SD2->D2_LOJA%
			AND D12.D12_SERVIC = %Exp:SD2->D2_SERVIC%
			AND D12.D12_PRODUT = %Exp:SD2->D2_COD%
			AND D12.D12_LOTECT = %Exp:SD2->D2_LOTECTL%
			AND D12.D12_NUMLOT = %Exp:SD2->D2_NUMLOTE%
			AND D12.D12_IDDCF  = %Exp:oOrdServ:GetIdDCF()%
			AND D12.%NotDel%
			ORDER BY D12_ORDTAR,
						D12_IDMOV,
						D12_ORDATI
		EndSql
		Do While lRet .And. (cAliasQry)->(!Eof())
			oMovimento:GoToD12((cAliasQry)->RECNOD12)
			oMovimento:SetLog("2")
			oMovimento:SetStatus("1")
			oMovimento:SetPrAuto("2")
			oMovimento:SetDataIni(dDataBase)
			oMovimento:SetHoraIni(Time())
			oMovimento:SetDataFim(dDataBase)
			oMovimento:SetHoraFim(Time())
			oMovimento:SetRecHum(__cUserID)
			oMovimento:SetQtdLid(oMovimento:nQtdMovto)
			oMovimento:SetRadioF("2")
			oMovimento:UpdateD12()
			// Finalizar ou Apontar a movimentação
			If oMovimento:IsUltAtiv()
				If oMovimento:IsUpdEst()
					lRet := oMovimento:RecEnter()
					If !lRet 
						WmsMessage(oOrdServ:GetErro()+" "+STR0003,WMSXFUMI02,,,,STR0004)  //"Movimentação WMS Não finalizada". //"Problema na atualização de saldos WMS durante a finalização dos movimentos." 
						EXIT
					EndIF
					
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	//Baixa estoque na DOCA para o documento 
	If lRet
		oEstEnder := WMSDTCEstoqueEndereco():New()
		lRet := oEstEnder:MakeFtMI(SD2->(Recno()),oOrdServ:GetIdDCF(),oMovimento:oMovenddes:cEndereco)
		If !lRet 
			WmsMessage(oOrdServ:GetErro()+" "+STR0001,WMSXFUMI03,,,,STR0002)  //"Erro ao Baixar Estoque WMS (D14)."  //"Movimentos WMS não executados."
		EndIF
	EndIF 
	RestArea(aAreaAnt)

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsVldReMI()
Realiza a Validação de tipo de servico e saldo utilizado para remito de transferencia Mercado internacional .
@type function
@author Roselaine Adriano
@version 12.1.2210
@since 10/10/2022
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Function WmsVldReMI(cAliasI,cTipDoc, nLinha, aDadosIOri, aCols, cEspecie, aHeaderM)
Local lRet := .T. 
Local cWmsSrRT := SuperGetMV("MV_WMSSRRT",.F.,"")  // Servico parametrizado para utilização no remito de Transferência mErcado internacional. 
Local oEstEnder := Nil
Local nSaldoD14 := 0 
Local aSaldos	:= {}
Local aAreaAnt  := Nil
Local oSaldoWMS := Nil
LOCAL nFindEnd	:= 0
LOCAL cLoteAux  := ""
LOCAL cNLoteAux := ""
Local nZ := 0
Local nQuantAux := 0
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.) 
Local oEndereco := Nil 
Local cWmsEdMi := SuperGetMV("MV_WMSEDMI",.F.,"")  // Endereço para baixa WMS na geração Remito de devolução Fornecedor. 
Local cLocal := ''
Local cLocaliz := ''
Local cProd    := ''
Local nQuant   := 0 
Local cCliente := ""
Local cLoja    := ""
Local cRemitoDev  := ""
Local cSeriRemito := ""
Local cItemRem    := ""
Local nPosServ    := 0
Local nPosLoteCt  := 0
Local nPosNumLot  := 0
Local nPosQuant   := 0
Local nPosCod     := 0
Local nPosLocaliz := 0
Local nPosLocal   := 0
Local nPosRemito  := 0
Local nPosSerRem  := 0 
Local nPosItemRem := 0 
Local nPosCliFor  := 0 

	nPosServ      := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_SERVIC"  })
    nPosLoteCt    := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_LOTECTL" })
    nPosNumLot      := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_NUMLOTE" })
    nPosQuant     := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_QUANT"   })
    nPosCod       := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_COD"     })
    nPosLocaliz   := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_LOCALIZ" })
    nPosLocal     := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_LOCAL"   })
	nPosRemito    := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_REMITO"   })
    nPosSerRem    := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_SERIREM"   })
    nPosItemRem   := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_ITEMREM"   })
    nPosCliFor    := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_CLIENTE"   })
    nPosLoja      := aScan(aHeaderM, {|x| AllTrim(x[2]) == "D2_LOJA"   })


	If nLinha > 0 
		cLocal   := aDadosIOri[nLinha][nPosLocal]
		cLocaliz := aDadosIOri[nLinha][nPosLocaliz]
		cProd    := aDadosIOri[nLinha][nPosCOD]
		nQuant   := aDadosIOri[nLinha][nPosQuant]
		cCliente   := aDadosIOri[nLinha][nPosCliFor]
 		cLoja      := aDadosIOri[nLinha][nPosLoja]
		IF nPosRemito > 0 
			cRemitoDev := aDadosIOri[nLinha][nPosRemito]
			cSeriRemito := aDadosIOri[nLinha][nPosSerRem]
			cItemRem    := aDadosIOri[nLinha][nPosItemRem]
		EndIF 
	EndIf

    If lWmsNew .And. IntWms(cProd) .And. cAliasI == 'SD2' .And. ((AllTrim(cEspecie) == "RTS" .And. FwIsInCallStack('MATA462TN')) .OR. (AllTrim(cEspecie) == "RCD" .And. FwIsInCallStack('MATA102DN')) .OR. (AllTrim(cEspecie) == "NCP" .And. FwIsInCallStack('MATA466N'))) .And. nLinha > 0 
		If ((AllTrim(cEspecie) == "RTS") .And. FwIsInCallStack('MATA462TN'))
            If !Empty(cWmsSrRT) 
		    	DC5->(DbSetOrder(1))
		    	If DC5->(DbSeek(xFilial("DC5")+cWmsSrRT, .F.))
		    		If DC5->DC5_TIPO == "2" 
		    		   aDadosIOri[nLinha][nPosserv]  := cWmsSrRT
		    		   aCols[nLinha][nPosserv]  := cWmsSrRT
		    		ENDIF
		    	ENDIF
		    EndIf

		    If Empty(aCols[nLinha][nPosserv])
		    	WmsMessage(STR0005,WMSXFUMI04,,,,STR0006)  //"Produto com controle WMS" // "Informe um serviço de saida."
		    	lRet := .F. 
		    EndIf
        EndIf

		//Validar quando e nota de credito se for vincuada a remito de devolução nao vai baixar estoque 
		If ((AllTrim(cEspecie) == "NCP") .And. FwIsInCallStack('MATA466N')) .AND. WMSVRemDMI(cCLiente,cLoja,cSeriRemito,cRemitoDev,cItemRem,cProd)
			Return .T. 
		ENDIF

        //Para remito de devolução de fornecedor sugerir endereço parametrizado se houver
        If ((AllTrim(cEspecie) == "RCD" .And. FwIsInCallStack('MATA102DN')) .OR. (AllTrim(cEspecie) == "NCP" .And. FwIsInCallStack('MATA466N'))) .AND. !Empty(cWmsEdMi) .AND. Empty(aCols[nLinha][nPosLocaliz]) 
            If WmsMessage(WmsFmtMsg(STR0015,{{"[VAR01]",cValToChar(cWmsEdMi)}}),WMSXFUMI11,3 /*MSG_QUESTION*/)  // Sim // Não //"Necessário informar o endereço para baixa de saldos WMS. Deseja utilizar o endereço: [VAR01] parametrizado em MV_WMSEDMI ?"
                aDadosIOri[nLinha][nPosLocaliz]  := cWmsEdMi
		        aCols[nLinha][nPosLocaliz]  := cWmsEdMi
				cLocaliz := cWmsEdMi
            Else 
                lRet := .F. 
            EndIf 
		EndIf
	
		If lRet .AND. Empty(cLocaliz)
			WmsMessage(STR0005,WMSXFUMI05,,,,STR0007)  //"Produto com controle de WMS." //"Obrigatório informar o endereço origem."
			lRet := .F. 
		ENDIF 

        //Quanto e remito de devolução de fornecedor validar se a estrutura do endereço informado para baixa no documento e DOCA.
        If lRet .AND. ((AllTrim(cEspecie) == "RCD" .And. FwIsInCallStack('MATA102DN')) .OR. (AllTrim(cEspecie) == "NCP" .And. FwIsInCallStack('MATA466N')))
            //Valida o tipo de estrutura do endereço informado
			aAreaAnt := GetArea()
            oEndereco := WMSDTCEndereco():New()
            oEndereco:SetArmazem(cLocal)
			oEndereco:SetEnder(cLocaliz)
			oEndereco:LoadData()
            If oEndereco:GetTipoEst() <> 5
                WmsMessage(STR0016,WMSXFUMI12,,,,)  //"Tipo de estrutura do endereço informado no documento deve ser DOCA. " //"Obrigatório informar o endereço origem."
			    lRet := .F. 
            EndIF 
			RestArea(aAreaAnt)
        EndIf 
		If lRet .And. Rastro(cProd) 
		    //Protege o Alias antes da chamada do método WMS
			aAreaAnt := GetArea()
			oSaldoWMS := WMSDTCEstoqueEndereco():New()
			//Consulta o Saldo do Endereço no WMS
			aSaldos  := oSaldoWMS:GetSldEnd(cProd,cLocal,cLocaliz,aDadosIOri[nLinha][nPosloteCt],aDadosIOri[nLinha][nPosNumlot],,1)//cPrdOri,cLocal,cEnder,cLote,cSubLote,cNumSer,nOrdem
			nFindEnd := aScan(aSaldos,  {|x| x[2] = cLocaliz})
			nSaldoD14 := IIf( nFindEnd == 0,0,aSaldos[nFindEnd][6])
			cLoteAux := IIf( nFindEnd == 0,"",aSaldos[nFindEnd][3])
			cNLoteAux:= IIf( nFindEnd == 0,"",aSaldos[nFindEnd][4])
			//Recupera o Alias
			RestArea(aAreaAnt)
			
			If Len(aSaldos) == 1 .AND. !Empty(cLoteAux)
				If nSaldoD14 < nQuant
					WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]", cValTochar(nSaldoD14)},{"[VAR02]", cLoteAux}}),WMSXFUMI06,,,,STR0009) // "Quantidade saldo WMS indisponível. Saldo WMS: [VAR01] para o LOTE: [VAR02]." "Verifique o Saldo ou informe o LOTE."
					lRet := .F. 
				EndIf
				If lRet .AND. !Empty( nSaldoD14 )
					If Empty(aCols[nLinha, nPosLoteCt])
						aCols[nLinha,nPosLoteCt]    := cLoteAux
						aDadosIOri[nLinha,nPosLoteCt] := cLoteAux
					EndIf 
					If Empty(aCols[nLinha,nPosNumLot])
						aCols[nLinha,nPosNumLot]   := cNLoteAux
						aDadosIOri[nLinha,nPosNumLot] := cNLoteAux
					EndIf
				EndIf 
	    	Else
				WmsMessage(STR0010,WMSXFUMI07,,,,STR0011)  //"Produto com mais de um lote no endereço ou sem saldo disponível no endereço. " //"Obrigatório informar o LOTE."
				lRet := .F.
			EndIf 
		EndIf 

		If lRet
			nSaldoD14 := 0 
			//Busca o Saldo do produto geral mesmo quando nao informou endereço 
			oEstEnder := WMSDTCEstoqueEndereco():New()
			oEstEnder:ClearData()
			oEstEnder:oEndereco:SetArmazem(cLocal)
			oEstEnder:oEndereco:SetEnder(cLocaliz)
			oEstEnder:oProdLote:SetProduto(cProd)
			oEstEnder:oProdLote:SetLoteCtl(aDadosIOri[nLinha][nPosloteCt])
			oEstEnder:oProdLote:SetNumLote(aDadosIOri[nLinha][nPosNumlot])
			nSaldoD14 := oEstEnder:ConsultSld(.F./*EntPrevista*/,.T./*SaidPrevista*/,.T./*Empenho*/,.T./*Bloqueado*/)
	 		If nSaldoD14 < nQuant
				WmsMessage(WmsFmtMsg(STR0012,{{"[VAR01]",cValTochar(nSaldoD14)}}),WMSXFUMI08,5/*MSG_HELP*/) // "Quantidade saldo WMS indisponível. Saldo WMS: [VAR01]."
				lRet := .F. 
			ENDIF
		ENDIF

		//buscar a quantidade ja informada no remito para o LOTE
		If lRet
			For nZ := 1 to Len(aCols)
				If !aCols[nZ][Len(aCols[nZ])]
					If Rastro(cProd)
						If 	aCols[nZ][nPosCod] == cProd	.And. aCols[nZ][nPosLoteCt] == cLoteAux	.And. aCols[nZ][nPosNumLot] == cNLoteAux .AND. aCols[nZ][nPosLocal] == cLocal .AND. aCols[nZ][nPosLocaliz] == cLocaliz
							nQuantAux += aCols[nZ][nPosQuant]
						EndIf
					Else 
						If 	aCols[nZ][nPosCod] == cProd	.AND. aCols[nZ][nPosLocal] == cLocal .AND. aCols[nZ][nPosLocaliz] == cLocaliz
							nQuantAux += aCols[nZ][nPosQuant]
						EndIf
					EndIf
				EndIf
			Next
			If nSaldoD14 < nQuantAux
				WmsMessage(WmsFmtMsg(STR0013,{{"[VAR01]",cValTochar(nSaldoD14)}}),WMSXFUMI09,5/*MSG_HELP*/) // "Quantidade saldo WMS indisponível para o documento. Saldo WMS: [VAR01]."
				lRet := .F.
			EndIf
		endIf
	ENDIF
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WMSMovRemt()
Realiza a Validação de tipo de servico e saldo utilizado para remito de transferencia Mercado internacional .
@type function
@author Roselaine Adriano
@version 12.1.2210
@since 10/10/2022
@return
Boolean: .T. se a operação foi executada com sucesso ou .F. se houve erro.
/*/
//-------------------------------------------------------------------------------------------------
Function WMSMovRemt()
Local lWMSGREM := SuperGetMV("MV_WMSGREM",.F.,.F.)
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
	
	If !lWMSGREM .OR. !lWmsNew .OR. !FindFunction("WMSR459")
	   Return 
	EndIf 

   Pergunte("WMSR459",.F.)   
	MV_PAR01 := SD2->D2_DOC
	MV_PAR02 := SD2->D2_DOC
	MV_PAR03 := SD2->D2_SERIE
	MV_PAR04 := SD2->D2_SERIE
   WMSR459()
   
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WmsMeInt
	Função que avalia se o pedido de venda esta com todos as atividade do WMS liberadas.
	@murilo.brandao
	@since 08/12/2022
	@version 1.0
	/*/
//-----------------------------------------------------------------------------------
Function WmsMeInt(cProduto,lTela,lAll,cEntfut)
Local lRet := .T.
DEFAULT cEntfut := ''
Default lAll := .F.

If IntWms(cProduto) .And. cEntfut <> '3'
	If SC9->C9_BLWMS <> '05'
		lRet := .F.
		IF lTela .And. !lAll
			WmsMessage(STR0014,WMSXFUMI10,5)//"Nesse pedido de venda existe atividades pendentes de execução no WMS."
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WMSVRemDMI
	Função que avalia se a nota de credito está sendo relacionada com um remito de devolução.
	@roselaine.adriano
	@since 03/08/2023
	@version 1.0
	/*/
//------------------------------------------------------------------------------------
Function WMSVRemDMI(cCLiente,cLoja,cSeriRemito,cRemitoDev,cItemRem,cProd)
Local lRet := .F.
Local cAliasQry := Nil 

	//Buscar na tabelaa S2 se existe o remito de devolução 
	cAliasQry := GetNextAlias()
	BeginSQL Alias cAliasQry
		SELECT DISTINCT 1
		FROM %Table:SD2% 
		WHERE D2_FILIAL = %xFilial:SD2%
 		AND D2_CLIENTE  = %Exp:cCliente%
		AND D2_LOJA     =  %Exp:cLoja%
		AND D2_SERIE  =  %Exp:cSeriRemito%
		AND D2_DOC   =  %Exp:cRemitoDev%
		AND D2_ITEM  =  %Exp:cItemRem%
		AND D2_COD =  %Exp:cProd%
		AND D2_ESPECIE = 'RCD'
		AND %NotDel% 
	ENDSQL
	If !(cAliasQry)->(Eof())
		lRet := .T. 
	ENDIF
	(cAliasQry)->(dbCloseArea())
		
Return lRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WMSMT462DN
	Gatilha o servico e endereco para o MATA462DN. B5_SERVENT/B5_ENDENT
	@equipe WMS
	@since 05/09/2023
	@version 1.0
	/*/
//------------------------------------------------------------------------------------
Function WMSMT462DN(aHeader, aCols, nLinha)
	Local nI := 1
	Local nCod := 0
	Local nServic := 0
	Local nEnder := 0
	Local aAreaSB5 := SB5->(GetArea())
	Local lWmsNew := SuperGetMv("MV_WMSNEW",.F.,.F.)

	If lWmsNew
		For nI := 1 to Len(aHeader)
			Do Case
				Case  Alltrim(aHeader[nI][2]) == "D1_COD"
					nCod := nI
				Case  Alltrim(aHeader[nI][2]) == "D1_SERVIC"
					nServic := nI
				Case Alltrim(aHeader[nI][2]) == "D1_ENDER"
					nEnder := nI
			Endcase
		Next nI

		If nCod > 0 .And. nServic > 0 .And. nEnder > 0
			SB5->(dbSetOrder(1))
			If SB5->(dbSeek(xFilial("SB5")+aCols[nLinha][nCod]))
				aCols[nLinha][nServic] := SB5->B5_SERVENT
				aCols[nLinha][nEnder]  := SB5->B5_ENDENT
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSB5)
Return
