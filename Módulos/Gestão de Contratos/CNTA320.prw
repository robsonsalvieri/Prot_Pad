#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'CNTA320.CH'
#INCLUDE "GCTXDEF.CH"

Static _aValDev := {}
Static _cFilCtr := ""
Static _lIsBlind:= IsBlind()
Static _oLogDefs:= InitLogDef()//Armazena a definição dos logs
Static _cLogArq := ""

#DEFINE TAMANHOLOG 12
	#DEFINE LOG_CONTRA 1
	#DEFINE LOG_REVISA 2
	#DEFINE LOG_TIPCTR 3
	#DEFINE LOG_SLDCTR 4
	#DEFINE LOG_SLDPLA 5
	#DEFINE LOG_VLINIC 6 
	#DEFINE LOG_VLFINA 7 
	#DEFINE LOG_VLATUA 8 
	#DEFINE LOG_VLATUF 9 
	#DEFINE LOG_SUBLOG 10
	#DEFINE LOG_AJUSTE 11
	#DEFINE LOG_TOTPLA 12
#DEFINE TAM_SUBLOG 11
	#DEFINE SUB_CONTRA 1
	#DEFINE SUB_REVISA 2
	#DEFINE SUB_NUMPLA 3
	#DEFINE SUB_FORNEC 4
	#DEFINE SUB_OLDSLD 5
	#DEFINE SUB_NEWSLD 6
	#DEFINE SUB_OLDTOT 7
	#DEFINE SUB_NEWTOT 8
	#DEFINE SUB_LOGCNB 9
	#DEFINE SUB_LOGCNF 10
	#DEFINE SUB_LOGCNS 11


//=============================================================================
/*/{Protheus.doc}  CNTA320
Efetua ajustes dos saldos do contrato

@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
//=============================================================================
Function CNTA320(aLog, lKeepLog, cLogFile)
Local cLog		:= ""
Local bAction	:= Nil
Local lContinua	:= IIF(_lIsBlind, .T., MsgYesNo( STR0005, STR0001 ))//-- Esta rotina efetua ajustes de saldos do contrato, das planilhas, dos itens e dos cronogramas com base nas medições realizadas até o momento. É importante que um backup seja realizado. Para processar contratos eventuais configure o parâmetro MV_320SLD = 2. Deseja prosseguir?
Default aLog	:= {}
Default lKeepLog:= .F.
Default cLogFile:= ""

If lContinua	
	If Pergunte("CNTA320",!_lIsBlind)
		bAction := {|oSay|aLog:= AjustaSaldos(oSay)}
		If(_lIsBlind)
			Eval(bAction)
		Else
			FWMsgRun(, bAction,STR0001, STR0002)//-- Ajuste de Saldos | Processando, aguarde...			
		EndIf

		cLog:= MontaLog(aLog, .T.)
		If !_lIsBlind
			If Empty(cLog)
				FWAlertInfo(STR0003,'CNTA320') //-- Processo finalizado! Nenhum contrato precisou ser ajustado.				
			Else		
				GCTLog(cLog, STR0004, 1, .T.) //-- Ajuste de Saldos
			EndIf
		EndIf
		If !lKeepLog
			FwFreeArray(aLog)
		EndIf
		aSize(_aValDev, 0)

		cLogFile := _cLogArq
		_cLogArq := ""
	EndIf
EndIf

FreeObj(_oLogDefs)
Return cLog

//=============================================================================
/*/{Protheus.doc}  AjustaSaldos
Ajusta os campos CNA_SALDO e CN9_SALDO, com base nas medições realizadas para 
os itens da planilha.

@return aLog, Array, array com os contratos processados
@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
//=============================================================================
Static Function AjustaSaldos(oSay as Object)
	Local cAliasCNA  := GetNextAlias()
	Local cAliasCNAP := GetNextAlias()
	Local cContrato  := ""
	Local cRevisa    := ""
	Local cContraPos := ""
	Local nNewVltot	 := 0
	Local nCNASaldo  := 0
	Local nCNAVltot  := 0
	Local nNewSaldo  := 0
	Local nDifSaldo  := 0
	Local nDifVltot	 := 0
	Local nDifCN9Tot := 0
	Local nX         := 1
	Local nY         := 1
	Local lAjustou   := .F.
	Local lFixo      := .F.
	Local lEventual  := .F.
	Local lEvenSItem := .F.
	Local lFisico	 := .F.
	Local aLog       := {}
	Local nTipoSaldo := SuperGetMV("MV_320SLD", .F., 1) //-- Processa apenas contratos fixos = 1, fixos e eventuais = 2
	Local aNovoLog	 := {}
	Local aSubLog	 := {}
	Local lHasLoader := (ValType(oSay) == "O")
	Local nInicio	 := 0
	Local oLogFile	 := Nil
	Local cDecorrido := ""
	Local cSituacIn	 := "%" + fSqlIn((DEF_SELAB + DEF_SVIGE), GetSX3Cache('CN9_SITUAC','X3_TAMANHO')) + "%"
	Local c1stRevisa := Space(GetSx3Cache( 'CN9_REVISA', 'X3_TAMANHO' ))
		
	If CriaArqLog(@oLogFile)
		//-- Busca planilhas da revisão vigente de cada contrato que não esteja em revisão(CN9_SITUAC = 05 que não tenha CN9_SITUAC = 09)
		BeginSql Alias cAliasCNA
			SELECT CNA.CNA_CONTRA, CNA.CNA_REVISA, CNA.CNA_NUMERO, CNA.CNA_SALDO,CNA.CNA_VLTOT, CNA.CNA_FORNEC, CN9.*
			FROM %table:CNA% CNA
			INNER JOIN %table:CN9% CN9 ON(
					CN9.CN9_FILIAL = CNA.CNA_FILIAL
				AND CN9.CN9_NUMERO = CNA.CNA_CONTRA
				AND CN9.CN9_REVISA = CNA.CNA_REVISA
				AND CN9.%NotDel%)
			WHERE 		
				CNA.CNA_FILIAL = %xFilial:CNA% 
				AND CNA.CNA_CONTRA BETWEEN %exp:MV_PAR01% AND %exp:MV_PAR02%		 
				AND CN9.CN9_SITUAC IN (%exp:cSituacIn%)
				AND CN9.CN9_REVATU = %exp:Space(Len(CN9->CN9_REVATU))%
				AND CNA.%NotDel%	
			ORDER BY CNA_CONTRA, CNA_NUMERO		 
				
		EndSQL

		CNA->(dbSetOrder(1))
		CN9->(dbSetOrder(1))

		If (cAliasCNA)->(EOF())
			If !_lIsBlind
				FWAlertWarning(STR0006,'CNTA320') //-- Contrato(s) não encontrado(s)
			EndIf
			oLogFile:Write(STR0006 + CRLF)
		Else	
			nInicio	:= Seconds()
			While (cAliasCNA)->(!EOF())
				If lHasLoader
					cDecorrido := cValToChar(Int(((Seconds() - nInicio) / 60)))
					oSay:SetText(I18N(STR0023,{(cAliasCNA)->CNA_CONTRA,cDecorrido}))//Aguarde, tempo decorrido
					ProcessMessage()
				EndIf

				If (cAliasCNA)->CN9_SITUAC == DEF_SVIGE //Contratos vigentes
					lFixo     	:= CN300RetSt("FIXO"	,0,(cAliasCNA)->CNA_NUMERO,(cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CN9_FILCTR,.F.)
					lEventual	:= CN300RetSt("MEDEVE"	,0,(cAliasCNA)->CNA_NUMERO,(cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CN9_FILCTR,.F.)
					lFisico 	:= CN300RetSt("FISICO"	,0,(cAliasCNA)->CNA_NUMERO,(cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CN9_FILCTR,.F.)
					lEvenSItem 	:= !lFixo .And. lEventual //-- Verifica se o contrato é eventual sem itens

					If nTipoSaldo == 2 .Or. !lEventual
						cContrato := (cAliasCNA)->CNA_CONTRA
						cRevisa   := (cAliasCNA)->CNA_REVISA
						_cFilCtr  := (cAliasCNA)->CN9_FILCTR
						If nY == 1
							aNovoLog := Array(TAMANHOLOG)
							aNovoLog[LOG_CONTRA]:= cContrato
							aNovoLog[LOG_REVISA]:= cRevisa
							aNovoLog[LOG_TIPCTR]:= ""
							aNovoLog[LOG_SLDCTR]:= 0
							aNovoLog[LOG_SLDPLA]:= 0
							aNovoLog[LOG_VLINIC]:= 0
							aNovoLog[LOG_VLFINA]:= 0
							aNovoLog[LOG_VLATUA]:= 0
							aNovoLog[LOG_VLATUF]:= 0
							aNovoLog[LOG_TOTPLA]:= 0
							aNovoLog[LOG_SUBLOG]:= {}
							aNovoLog[LOG_AJUSTE]:= lAjustou
							aAdd(aLog, aClone(aNovoLog))
							aSize(aNovoLog,0)
						EndIf

						aSubLog := aLog[nX][LOG_SUBLOG]
						aNovoLog:= Array(TAM_SUBLOG)
						aNovoLog[SUB_CONTRA]:= cContrato
						aNovoLog[SUB_REVISA]:= cRevisa
						aNovoLog[SUB_NUMPLA]:= (cAliasCNA)->CNA_NUMERO
						aNovoLog[SUB_FORNEC]:= (cAliasCNA)->CNA_FORNEC
						aNovoLog[SUB_OLDSLD]:= (cAliasCNA)->CNA_SALDO						
						aNovoLog[SUB_NEWSLD]:= 0
						aNovoLog[SUB_OLDTOT]:= (cAliasCNA)->CNA_VLTOT
						aNovoLog[SUB_NEWTOT]:= 0
						aNovoLog[SUB_LOGCNB]:= {}
						aNovoLog[SUB_LOGCNF]:= {}
						aNovoLog[SUB_LOGCNS]:= {}

						aAdd(aSubLog, aClone(aNovoLog))
						aSize(aNovoLog,0)		

						FwLogMsg("INFO", , "", "CNTA320", "", "01", "Contrato: " + (cAliasCNA)->CNA_CONTRA + "Revisão: " + (cAliasCNA)->CNA_REVISA + "Planilha: " + (cAliasCNA)->CNA_NUMERO + "nX: " + cValtoChar(nX) + "nY: " + cValtoChar(nY), 0, -1, {})
						
						If !lEvenSItem //-- Não atualiza CNA caso o contrato não possua itens
							nNewVltot := 0
							nNewSaldo := CalcSaldo((cAliasCNA)->CNA_CONTRA,(cAliasCNA)->CNA_REVISA,(cAliasCNA)->CNA_NUMERO, @aLog[nX][LOG_SUBLOG][nY], @lAjustou, @nNewVltot)
							nDifSaldo := nNewSaldo - (cAliasCNA)->CNA_SALDO
							nDifCN9Tot := nNewSaldo - (cAliasCNA)->CN9_VLATU
							nDifVltot := nNewVltot - (cAliasCNA)->CNA_VLTOT
																		
							If ABS(nDifSaldo) > 0.00 .Or. ABS(nDifVltot) > 0.00 .Or.  ABS(nDifCN9Tot) > 0.00

								If CNA->(dbSeek(xFilial('CNA')+(cAliasCNA)->CNA_CONTRA+(cAliasCNA)->CNA_REVISA+(cAliasCNA)->CNA_NUMERO))
									RecLock( "CNA", .F. )
									nCNASaldo:= CNA->CNA_SALDO += nDifSaldo
									nCNAVltot:= CNA->CNA_VLTOT += nDifVltot
									CNA->( MsUnlock() )
									lAjustou := .T.
									aLog[nX][LOG_SUBLOG][nY][SUB_NEWSLD]+= nCNASaldo
									aLog[nX][LOG_SUBLOG][nY][SUB_NEWTOT]+= nCNAVltot
								EndIf
								
							Else
								aLog[nX][LOG_SUBLOG][nY][SUB_NEWSLD]+= (cAliasCNA)->CNA_SALDO								
								aLog[nX][LOG_SUBLOG][nY][SUB_NEWTOT]+= (cAliasCNA)->CNA_VLTOT							
							EndIf
						EndIf	
						
						aLog[nX][LOG_AJUSTE]:= lAjustou
						
						If lFisico
							lAjustou:= (cAliasCNA)->( AjustaCNS(CNA_CONTRA, CNA_REVISA, nTipoSaldo,@aLog[nX][LOG_SUBLOG][nY] , CNA_NUMERO))//Ajusta valor Realizado do cronograma físico(CNS)
							lAjustou:= lAjustou .Or. (cAliasCNA)->(AjsCNFxCNS(CNA_CONTRA, CNA_REVISA, CNA_NUMERO, @aLog[nX][LOG_SUBLOG][nY]))//Ajusta valor previsto da CNF pelo cronograma físico(CNS)
						EndIf

						ReajuCrono((cAliasCNA)->CNA_CONTRA, (cAliasCNA)->CNA_REVISA, (cAliasCNA)->CNA_NUMERO, @aLog[nX][LOG_SUBLOG][nY], @lAjustou)			
						
						aLog[nX][LOG_AJUSTE]:= aLog[nX][LOG_AJUSTE] .Or. lAjustou

						(cAliasCNA)->(dbSkip())
						cContraPos:= (cAliasCNA)->CNA_CONTRA+(cAliasCNA)->CNA_REVISA
						nY++
						If cContraPos != cContrato+cRevisa
							
							BeginSql Alias cAliasCNAP	
								SELECT SUM (CNA.CNA_SALDO) CNA_SALDO, SUM (CNA.CNA_VLTOT) CNA_VLTOT
								FROM %table:CNA% CNA
								WHERE
								CNA.CNA_FILIAL = %xFilial:CNA% AND
								CNA.CNA_CONTRA = %exp:cContrato% AND
								CNA.CNA_REVISA = %exp:cRevisa% AND
								CNA.%NotDel%
							EndSql
						
							If CN9->(dbSeek(xFilial('CN9')+cContrato+cRevisa)) 	
								aLog[nX][LOG_TIPCTR]:= CN9->CN9_TPCTO
								aLog[nX][LOG_SLDCTR]:= CN9->CN9_SALDO
								aLog[nX][LOG_VLINIC]:= CN9->CN9_VLINI
								aLog[nX][LOG_VLATUA]:= CN9->CN9_VLATU
																
								If CN9->CN9_SALDO != (cAliasCNAP)->CNA_SALDO .OR. ;
								   CN9->CN9_VLATU != (cAliasCNAP)->CNA_VLTOT
								  
									RecLock( "CN9", .F. )
									CN9->CN9_SALDO := (cAliasCNAP)->CNA_SALDO	
									CN9->CN9_VLATU := (cAliasCNAP)->CNA_VLTOT
									If CN9->CN9_REVISA == c1stRevisa .And. CN9->CN9_VLINI != CN9->CN9_VLATU
										CN9->CN9_VLINI := (cAliasCNAP)->CNA_VLTOT
									Endif 
									CN9->( MsUnlock() )
									lAjustou:= .T.
										
									aLog[nX][LOG_SLDPLA]:= (cAliasCNAP)->CNA_SALDO
									aLog[nX][LOG_VLFINA]:= CN9->CN9_VLINI									
									aLog[nX][LOG_VLATUF]:= CN9->CN9_VLATU
									
								Else
									aLog[nX][LOG_SLDPLA]:= CN9->CN9_SALDO
									aLog[nX][LOG_VLFINA]:= CN9->CN9_VLINI									
									aLog[nX][LOG_VLATUF]:= CN9->CN9_VLATU
								EndIf

							EndIf
				
							aLog[nX][LOG_AJUSTE]:= aLog[nX][LOG_AJUSTE] .Or. lAjustou

							oLogFile:Write(MontaLog({ aLog[nX] }))

							nX++
							nY:= 1	
							lAjustou := .F.		
							
							(cAliasCNAP)->(dbCloseArea())

						EndIf
					Else
						(cAliasCNA)->(dbSkip())
					EndIf
					
				ElseIf (cAliasCNA)->CN9_SITUAC == DEF_SELAB //Contratos em elaboração					
					cContraPos:= (cAliasCNA)->(CNA_CONTRA+CNA_REVISA)
					AjsCtrElab(cAliasCNA, aLog, oLogFile) //Ajusta contrato em elaboração
					While (cAliasCNA)->(!Eof() .And. CNA_CONTRA+CNA_REVISA == cContraPos)						
						(cAliasCNA)->(dbSkip()) //Pula todas as demais planilhas do mesmo contrato
					EndDo
				EndIf
			EndDo
		EndIf
		(cAliasCNA)->(dbCloseArea())		
		
		oLogFile:Write( I18N(STR0024,{DtoC(Date()), AllTrim(Time()) }) )//Fim do Processamento
		_cLogArq := oLogFile:getFileName()
		oLogFile:Close()
	Else
		FWAlertWarning(STR0020,'CNTA320')//Não foi possível criar um arquivo de log.
	EndIf

Return aLog

/*/{Protheus.doc}  CalcSaldo
Calcula o saldo dos itens da planilha e efetua ajuste dos itens na CNB

@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param aLog, array, Dados dos contratos processados
@param lAjustou, logico, verifica se houver ajuste
@param nVlTot, numerico, Valor total da planilha

@return nSaldo, numerico, saldo da planilha

@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
Static Function CalcSaldo(cContra, cRev, cPlan, aLog, lAjustou, nVlTot)
Local nSaldo     := 0
Local nTotal	 := 0
Local nSldItem   := 0
Local nSldQtd    := 0
Local aCNEMed    := {0,0,0}
Local nI         := 1
Local nDifQdt    := 0
Local nDifSld    := 0
Local nVlDesc    := 0
Local nDescItem  := 0
Local nDecQtMed  := TamSx3("CNB_QTDMED")[2]
Local nTipoSaldo := SuperGetMV("MV_320SLD", .F., 1) //-- Processa apenas contratos fixos = 1, fixos e eventuais
Local cItem      := ""
Local cAliasCNB  := GetNextAlias()
Local nDiv		 := 1/Val('1'+Replicate('0',nDecQtMed))
Local lCtrCompra :=  CN300RetSt( "COMPRA",0, cPlan, cContra, _cFilCtr, .F. )
Local cTipoCtr	 :=  IIF(lCtrCompra,"1", "2")
Default aLog := {}
Default lAjustou := .F.

BeginSql Alias cAliasCNB

	SELECT 	CNB_CONTRA,CNB_REVISA,CNB_NUMERO,CNB_ITEM,CNB_VLTOT,CNB_QUANT,CNB_VLUNIT,
			CNB_QTDMED,CNB_SLDMED,CNB_DESC,CNB_VLDESC,CNB_PRODUT,CNB_DESCRI
	FROM 	%table:CNB% CNB
	WHERE	CNB.CNB_FILIAL = %xFilial:CNB% AND
			CNB.CNB_CONTRA = %exp:cContra% AND
			CNB.CNB_REVISA = %exp:cRev% AND
			CNB.CNB_NUMERO = %exp:cPlan% AND
			CNB.%NotDel%
EndSQL

CNB->(dbSetOrder(1))

While (cAliasCNB)->(!EOF())
	cItem		:= (cAliasCNB)->CNB_ITEM
	
	aCNEMed	:= QuantMed(cContra, cRev, cPlan, cItem,(cAliasCNB)->CNB_VLTOT, (cAliasCNB)->CNB_QUANT)
	nSldQtd	:= (cAliasCNB)->CNB_QUANT - aCNEMed[nTipoSaldo]
	nVlDesc := CtrValDesc(cTipoCtr,;
				(cAliasCNB)->CNB_VLTOT ,;
				(cAliasCNB)->CNB_DESC  ,;
				(cAliasCNB)->CNB_VLUNIT,;
				(cAliasCNB)->CNB_QUANT)	
	
	nDescItem := CtrValDesc(cTipoCtr,;
				(cAliasCNB)->CNB_VLTOT ,;
				(cAliasCNB)->CNB_DESC  ,;
				(cAliasCNB)->CNB_VLUNIT,;
				 nSldQtd)
	nSldItem := ( nSldQtd * (cAliasCNB)->CNB_VLUNIT ) - nDescItem
	nTotal :=  (cAliasCNB)->CNB_VLTOT  - nVlDesc
	nVltot += nTotal
	
	aCNEMed[1]	:= Round(aCNEMed[1], nDecQtMed) //Quantidade
	aCNEMed[2]	:= Round(aCNEMed[2], nDecQtMed) //Quantidade proporcional ao valor da medição

	if nTipoSaldo == 1
		nDifQdt	:= aCNEMed[1] - (cAliasCNB)->CNB_QTDMED
	Else
		nDifQdt	:= aCNEMed[2] - (cAliasCNB)->CNB_QTDMED
	EndIf

	nDifSld	:= nSldQtd - (cAliasCNB)->CNB_SLDMED
	If nSldItem > 0
		nSaldo += nSldItem
	EndIf
	
	aadd(aLog[SUB_LOGCNB], {(cAliasCNB)->CNB_ITEM, (cAliasCNB)->CNB_PRODUT, (cAliasCNB)->CNB_DESCRI, (cAliasCNB)->CNB_QTDMED, 0, (cAliasCNB)->CNB_SLDMED, 0 , (cAliasCNB)->CNB_VLDESC, 0 } )

	If aCNEMed[nTipoSaldo] < 0 //-- Tratamento para valores negativos
		aCNEMed[nTipoSaldo] := 0
	EndIf
	If nSldQtd < 0
		nSldQtd := 0
	EndIf
	
	If ( ABS(nDifQdt) > nDiv .Or. ABS(nDifSld) > nDiv ) .Or. ;
	   ( (cAliasCNB)->CNB_QTDMED != aCNEMed[nTipoSaldo] .Or. ;
		 (cAliasCNB)->CNB_SLDMED != nSldQtd				.Or. ;
		 (cAliasCNB)->CNB_VLDESC != nVlDesc )

		If CNB->( dbSeek( xFilial('CNB') + (cAliasCNB)->CNB_CONTRA + (cAliasCNB)->CNB_REVISA + (cAliasCNB)->CNB_NUMERO + (cAliasCNB)->CNB_ITEM ) )
			
			RecLock( "CNB", .F. )
			CNB->CNB_QTDMED := aCNEMed[nTipoSaldo]
			CNB->CNB_SLDMED := nSldQtd
			CNB->CNB_VLDESC := nVlDesc
			CNB->( MsUnlock() )
			lAjustou := .T.
			
			aLog[SUB_LOGCNB][nI][5]:= aCNEMed[nTipoSaldo] //Quantidade Medida		
			aLog[SUB_LOGCNB][nI][7]:= nSldQtd //Quantidade a Medir
			aLog[SUB_LOGCNB][nI][9]:= nVlDesc //Valor do desconto
			
		EndIf	
	Else
		aLog[SUB_LOGCNB][nI][5]:= (cAliasCNB)->CNB_QTDMED	//Quantidade Medida		
		aLog[SUB_LOGCNB][nI][7]:= (cAliasCNB)->CNB_SLDMED //Quantidade a Medir		
		aLog[SUB_LOGCNB][nI][9]:= (cAliasCNB)->CNB_VLDESC //Valor do desconto	
	EndIf

	(cAliasCNB)->(dbSkip())
	nI++
End

(cAliasCNB)->(dbCloseArea())

return nSaldo

/*/{Protheus.doc} QuantMed
Retorna a quantidade medida do item da planilha
@type function
@author janaina.jesus
@since 24/07/2018
@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param cItem, character, Item da planilha
@param nTotItem, numeric, Valor total do item no contrato
@param nQtdItem, numeric, Quantidade total do item no contrato
@return array, Quatidade medida do item do contrato
/*/
Static Function QuantMed(cContra, cRev, cPlan, cItem, nTotItem, nQtdItem)
Local aArea    	:= GetArea()
Local aCNEMed  	:= {0,0}
Local nPosDev	:= 0
Local cChave	:= cContra+cRev+cPlan
Local lEventual := Cn300RetSt("MEDEVE", 0, cPlan, cContra, _cFilCtr, .F.)
Local cDataFim	:= Space(8)
local oExec		:= FWExecStatement():new() as object
Local cJoinCNE	As Character
Local cJoinSC5	As Character
Local cJoinSC6	As Character
Local cJoinSD2	As Character
Local cAliasCNE	As Character
Local cQuery   	As Character
Local nParOrder As Numeric

cJoinCNE	:= FWJoinFilial("CNE", "CND")
cJoinSC5	:= FWJoinFilial("SC5", "CNE")
cJoinSC6	:= FWJoinFilial("SC6", "SC5")
cJoinSD2	:= FWJoinFilial("SD2", "SC5")
cAliasCNE   := ""
cQuery   	:= ""
nParOrder   := 1

cQuery += " SELECT "
cQuery += "    CND.CND_SERVIC, "
cQuery += "    CND.CND_NUMMED, "
cQuery += "    MAX(CNE.CNE_QUANT)   AS CNE_QUANT, "
cQuery += "    MAX(CNE.CNE_VLTOT)   AS CNE_VLTOT, "
cQuery += "    MAX(COALESCE(SD2.D2_QTDEDEV,0)) AS D2_QTDEDEV, "
cQuery += "    MAX(COALESCE(SD2.D2_VALDEV,0))  AS D2_VALDEV, "
cQuery += "    MAX(COALESCE(SD2.D2_ITEMPV,' '))  AS D2_ITEMPV "
cQuery += " FROM " + RetSQLName("CND") + " CND "
cQuery += " INNER JOIN " + RetSQLName("CNE") + " CNE "
cQuery += "   ON " + cJoinCNE + " "
cQuery += "  AND CNE.CNE_CONTRA = CND.CND_CONTRA "
cQuery += "  AND CNE.CNE_REVISA = CND.CND_REVISA "
cQuery += "  AND CNE.CNE_NUMMED = CND.CND_NUMMED "
cQuery += "  AND CNE.CNE_VLTOT > ? "
cQuery += "	 AND CNE.D_E_L_E_T_ = ? "
cQuery += " LEFT JOIN " + RetSQLName("SC5") + " SC5 "
cQuery += "   ON " + cJoinSC5 + " "
cQuery += "  AND SC5.C5_MDNUMED = CNE.CNE_NUMMED "
cQuery += "  AND SC5.C5_MDPLANI = CNE.CNE_NUMERO "
cQuery += "  AND SC5.D_E_L_E_T_ = ? "
cQuery += " LEFT JOIN " + RetSQLName("SC6") + " SC6 "
cQuery += "   ON  " + cJoinSC6 + "  "
cQuery += "  AND SC6.C6_NUM    = SC5.C5_NUM "
cQuery += "  AND SC6.C6_ITEMED = CNE.CNE_ITEM "
cQuery += "  AND SC6.D_E_L_E_T_ = ? "
cQuery += " LEFT JOIN " + RetSQLName("SD2") + " SD2 "
cQuery += "   ON " + cJoinSD2 + " "
cQuery += "  AND SD2.D2_PEDIDO = SC6.C6_NUM "
cQuery += "  AND SD2.D2_ITEMPV = SC6.C6_ITEM "
cQuery += "  AND SD2.D2_CLIENTE= SC6.C6_CLI "
cQuery += "  AND SD2.D2_LOJA   = SC6.C6_LOJA "
cQuery += "  AND SD2.D_E_L_E_T_ = ? "
cQuery += " WHERE CND.CND_FILCTR = ? "
cQuery += "   AND CND.D_E_L_E_T_ = ? "
cQuery += "   AND CNE.CNE_CONTRA = ? "
cQuery += "   AND CNE.CNE_REVISA = ? "
cQuery += "   AND CNE.CNE_NUMERO = ? "
cQuery += "   AND CNE.CNE_ITEM   = ? "
cQuery += "   AND CND.CND_DTFIM <> ? "
cQuery += " GROUP BY CND.CND_SERVIC, CND.CND_NUMMED "

cQuery := ChangeQuery(cQuery)

oExec := FWExecStatement():New(cQuery)

oExec:SetString(nParOrder++, 0) 
oExec:SetString(nParOrder++, ' ') 
oExec:SetString(nParOrder++, ' ') 
oExec:SetString(nParOrder++, ' ') 
oExec:SetString(nParOrder++, ' ') 
oExec:SetString(nParOrder++, _cFilCtr)
oExec:SetString(nParOrder++, ' ') 
oExec:SetString(nParOrder++, cContra) 
oExec:SetString(nParOrder++, cRev)        
oExec:SetString(nParOrder++, cPlan)        
oExec:SetString(nParOrder++, cItem)        
oExec:SetString(nParOrder++, cDataFim)         

cAliasCNE := oExec:OpenAlias()

While (cAliasCNE)->(!EOF())
	
	aCNEMed[1] += (cAliasCNE)->CNE_QUANT - (cAliasCNE)->D2_QTDEDEV//Subtrai a quantidade devolvida da quantidade do item da medição

	If lEventual
		aCNEMed[2] := aCNEMed[1]
	Else
		aCNEMed[2] += ( ( (cAliasCNE)->CNE_VLTOT / nTotItem ) * nQtdItem ) //qtde proporcional ao valor medido
	EndIf

	If (cAliasCNE)->D2_QTDEDEV > 0
		If (nPosDev := aScan(_aValDev, {|x| x[1] == cChave+(cAliasCNE)->CND_NUMMED})) > 0
			_aValDev[nPosDev, 2] += (cAliasCNE)->D2_VALDEV
		Else			
			aAdd(_aValDev, {cChave+(cAliasCNE)->CND_NUMMED, (cAliasCNE)->D2_VALDEV})
		EndIf
	EndIf
	(cAliasCNE)->(dbSkip())
EndDo

(cAliasCNE)->(DbCloseArea())
FreeObj(oExec)

RestArea(aArea)

Return aCNEMed

/*/{Protheus.doc} ReajuCrono
Efetua o ajuste do saldo do cronograma financeiro do contrato.

@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param cItem, character, Item da planilha
@param aLog, array, Dados dos contratos processados
@param lAjustou, logico, verifica se houver ajuste

@return nQtdMed, numérico, Quatidade medida do item do contrato
    
@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
Static Function ReajuCrono(cContra, cRev, cPlan, aLog, lAjustou)
	Local cAliasCNF  := GetNextAlias()
	Local nSaldo     := 0
	Local nDifSaldo  := 0
	Local nVlrMed    := 0
	Local nX         := 0
	Local aCNFLog	 := {}
	Local nTamLogCNF := 8
	Default aLog := {}
	Default lAjustou := .F.

	BeginSql Alias cAliasCNF

		SELECT 	CNF_CONTRA,CNF_REVISA,CNF_NUMERO,CNF_PARCEL,CNF_COMPET,CNF_VLPREV,CNF_VLREAL,CNF_SALDO
		FROM 	%table:CNF% CNF
		WHERE	CNF.CNF_FILIAL = %xFilial:CNF% AND
				CNF.CNF_CONTRA = %exp:cContra% AND
				CNF.CNF_REVISA = %exp:cRev% AND
				CNF.CNF_NUMPLA = %exp:cPlan% AND
				CNF.%NotDel%
				ORDER BY
				CNF.CNF_PARCEL

	EndSQL

	dbSelectArea("CNF")
	CNF->(dbSetOrder(3)) //CNF_FILIAL+CNF_CONTRA+CNF_REVISA+CNF_NUMERO+CNF_PARCEL                                                                                                                                                                                                                 

	While (cAliasCNF)->(!EOF())
		aSize(aCNFLog,0)

		nVlrMed := CN320VlrMed(cContra, cRev, cPlan, (cAliasCNF)->CNF_COMPET, (cAliasCNF)->CNF_PARCEL)
		nSaldo := ((cAliasCNF)->CNF_VLPREV - (cAliasCNF)->CNF_VLREAL)
		nDifSaldo:= (cAliasCNF)->CNF_SALDO - nSaldo
		
		If ((cAliasCNF)->CNF_VLREAL <> nVlrMed) .Or. (ABS(nDifSaldo) > 0.02)
			aCNFLog := Array(nTamLogCNF)
			aCNFLog[1] := (cAliasCNF)->CNF_PARCEL
			aCNFLog[2] := (cAliasCNF)->CNF_SALDO
			aCNFLog[3] := (cAliasCNF)->CNF_SALDO
			aCNFLog[4] := (cAliasCNF)->CNF_VLREAL
			aCNFLog[5] := 0
			aCNFLog[6] := 0
			aCNFLog[7] := 0
			aCNFLog[8] := 0			
			nX++
		EndIf
		If (cAliasCNF)->CNF_VLREAL <> nVlrMed

			If CNF->(dbSeek(xFilial('CNF')+(cAliasCNF)->CNF_CONTRA+(cAliasCNF)->CNF_REVISA+(cAliasCNF)->CNF_NUMERO+(cAliasCNF)->CNF_PARCEL))
				RecLock( "CNF", .F. )
				CNF->CNF_VLREAL := nVlrMed
				nSaldo := CNF->CNF_VLPREV - CNF->CNF_VLREAL
				CNF->CNF_SALDO := nSaldo
				CNF->( MsUnlock() )
				
				aCNFLog[3] := nSaldo
				aCNFLog[5] := nVlrMed

				aCNFLog[6] := CNF->CNF_VLPREV //Compatibilidade com a função <AjsCNFxCNS>
				aCNFLog[7] := CNF->CNF_VLPREV //Compatibilidade com a função <AjsCNFxCNS>
							
				lAjustou := .T.
			EndIf
		ElseIf ABS(nDifSaldo) > 0.02

			If CNF->(dbSeek(xFilial('CNF')+(cAliasCNF)->CNF_CONTRA+(cAliasCNF)->CNF_REVISA+(cAliasCNF)->CNF_NUMERO+(cAliasCNF)->CNF_PARCEL))
				RecLock( "CNF", .F. )
				CNF->CNF_SALDO := nSaldo
				CNF->( MsUnlock() )
				
				aCNFLog[3] := nSaldo

				aCNFLog[6] := CNF->CNF_VLPREV //Compatibilidade com a função <AjsCNFxCNS>
				aCNFLog[7] := CNF->CNF_VLPREV //Compatibilidade com a função <AjsCNFxCNS>
				
				lAjustou := .T.
			EndIf	
		EndIf

		If !Empty(aCNFLog)
			aAdd(aLog[SUB_LOGCNF], aClone(aCNFLog))
		EndIf
		(cAliasCNF)->(dbSkip())
	EndDo
	(cAliasCNF)->(dbCloseArea())

Return 

/*/{Protheus.doc} CN320VlrMed
Retorna o valor total medido pela competencia.

@param cContra, character, Número do contrato
@param cRev, character, Revisão do contrato
@param cPlan, character, Planilha do contrato
@param cCompet, character, Competência do Cronograma
@param cParcel, character, número da parcela a ser considerada na busca

@return nVlrMed, numérico, Valor medido na competencia do Cronograma Financeiro.
    
@author janaina.jesus
@since 24/07/2018
@version 1.0
/*/
Static Function CN320VlrMed(cContra, cRev, cPlan, cCompet, cParcel)
Local cAliasCND	:= GetNextAlias()
Local nVlrMed   := 0
Local aArea     := GetArea()
Local nPosDev	:= 0
Local cChave	:= ""
Local cCN9Join	:= ""
Local cCNFJoin	:= ""

cCN9Join := "CN9.CN9_FILCTR = CND.CND_FILCTR"
cCN9Join += " AND CN9.CN9_NUMERO = CND.CND_CONTRA"
cCN9Join += " AND CN9.CN9_REVISA = CND.CND_REVISA"
cCN9Join := '%'+cCN9Join+'%'

cCNFJoin := "CNF.CNF_FILIAL=CN9.CN9_FILIAL"
cCNFJoin += " AND CNF.CNF_CONTRA = CN9.CN9_NUMERO"
cCNFJoin += " AND CNF.CNF_REVISA = CN9.CN9_REVISA"
cCNFJoin += " AND CNF.CNF_COMPET = CND.CND_COMPET"
cCNFJoin := '%'+cCNFJoin+'%'

BeginSql Alias cAliasCND

		SELECT 	SUM (CXN_VLLIQD) CND_VLTOT, CND.CND_NUMMED
			FROM 	%table:CND% CND

			INNER JOIN %table:CN9% CN9 ON(%exp:cCN9Join% AND CN9.%NotDel%)
			INNER JOIN %table:CNF% CNF ON(%exp:cCNFJoin% AND CNF.%NotDel%)

			INNER JOIN %Table:CXN% CXN ON( 
				CXN.CXN_FILIAL = CND.CND_FILIAL
				AND CXN.CXN_CONTRA = CND.CND_CONTRA
				AND CXN.CXN_REVISA = CND.CND_REVISA
				AND CXN.CXN_NUMMED = CND.CND_NUMMED
				AND CXN.CXN_NUMPLA = CNF.CNF_NUMPLA
				AND CXN.CXN_CRONOG = CNF.CNF_NUMERO
				AND CXN.CXN_PARCEL = CNF.CNF_PARCEL
				AND CXN.CXN_CHECK  = 'T'
				AND CXN.%NotDel%)
			
			WHERE	CND.CND_DTFIM <> %exp:Space(8)%	AND
					CND.CND_FILCTR = %exp:_cFilCtr%	AND
					CND.CND_CONTRA = %exp:cContra% 	AND
					CND.CND_REVISA = %exp:cRev%  	AND
					CND.CND_COMPET = %exp:cCompet%	AND
					CNF.CNF_NUMPLA = %exp:cPlan% 	AND					
					CNF.CNF_PARCEL = %exp:cParcel% 	AND					
					CND.%NotDel%
			GROUP BY CND.CND_NUMMED
		UNION
		SELECT 	SUM (CND_VLTOT) CND_VLTOT, CND.CND_NUMMED
			FROM 	%table:CND% CND			
			
			INNER JOIN %table:CN9% CN9 ON(%exp:cCN9Join% AND CN9.%NotDel%)			
			INNER JOIN %table:CNF% CNF ON(%exp:cCNFJoin% AND CND.CND_NUMERO = CNF.CNF_NUMPLA AND CNF.%NotDel%)			
						
			WHERE	CND.CND_DTFIM <> %exp:Space(8)%	AND
					CND.CND_FILCTR = %exp:_cFilCtr% AND
					CND.CND_CONTRA = %exp:cContra% 	AND
					CND.CND_REVISA = %exp:cRev%  	AND
					CND.CND_COMPET = %exp:cCompet%	AND
					CNF.CNF_NUMPLA = %exp:cPlan% 	AND
					CND.%NotDel%					
			GROUP BY CND.CND_NUMMED
EndSQL

While (cAliasCND)->(!EOF())
	nVlrMed += (cAliasCND)->CND_VLTOT

	cChave := cContra + cRev + cPlan + (cAliasCND)->CND_NUMMED	
	If (nPosDev := aScan(_aValDev, {|x| x[1] == cChave })) > 0
		nVlrMed -= _aValDev[nPosDev,2]
	EndIf
	(cAliasCND)->(dbSkip())
EndDo

(cAliasCND)->(dbCloseArea())

RestArea(aArea)

Return nVlrMed

/*/{Protheus.doc} MontaLog
Retorna a quantidade medida do item da planilha

@param aLog, array, Dados dos contratos processados

@return cLog, character, Log a ser exibido para o usuário
    
@author janaina.jesus
@since 25/07/2018
@version 1.0
/*/
Static Function MontaLog(aLog, lOnlyProc)
	Local cLog       := ""
	Local nX         := 0 //Contratos
	Local nY         := 0 //Planilhas
	Local nW         := 0 //Itens
	Local nZ         := 0 //Cronograma
	Local nContratos := 0
	Local cQuebra	:= CRLF + Replicate('=',110) + CRLF	
	Local aContrato := {}
	Local aPlanilhas:= {}
	Local aUmaPlan	:= {}
	Local aItensPlan:= {}
	Local aCronoFin := {}
	Local aCrgFisico:= {}
	
	Local oCNFLog	:= _oLogDefs["CNF"]
	Local oCNSLog	:= _oLogDefs["CNS"]
	Local oCN9Log	:= _oLogDefs["CN9"]
	Local oCNALog	:= _oLogDefs["CNA"]
	Local oCNBLog	:= _oLogDefs["CNB"]
	
	Local aCposLog	:= {}

	Default aLog:= {}
	Default lOnlyProc := .F.

	nContratos:= Len(aLog)

	For nX:= 1 To nContratos
		aContrato := aLog[nX]
		
		If aContrato[LOG_AJUSTE]

			cLog += oCN9Log['TITULO']
			cLog += oCN9Log['CABECALHO']
			cLog += CposToLine(aContrato, oCN9Log['CAMPOS'])

			aPlanilhas := aContrato[LOG_SUBLOG]
			
			For nY:= 1 To Len(aPlanilhas)

				aUmaPlan := aPlanilhas[nY]

				cLog += oCNALog['TITULO']
				cLog += oCNALog['CABECALHO']
				cLog += CposToLine(aUmaPlan, oCNALog['CAMPOS'])
				
				cLog += oCNBLog['TITULO']
				cLog += oCNBLog['CABECALHO']
				aItensPlan := aUmaPlan[SUB_LOGCNB]
				For nW:= 1 to Len(aItensPlan)
					cLog += CposToLine(aItensPlan[nW], oCNBLog['CAMPOS'])
				Next nW				
				
				aCposLog	:= oCNFLog['CAMPOS']
				aCronoFin	:= aUmaPlan[SUB_LOGCNF]
				For nZ:= 1 to Len(aCronoFin)
					If nZ == 1 //Apenas na primeira linha, inclui título e cabeçalho
						cLog += oCNFLog['TITULO']
						cLog += oCNFLog['CABECALHO']						
					EndIf
					cLog += CposToLine(aCronoFin[nZ],aCposLog)
				Next nZ
				
				aCposLog	:= oCNSLog['CAMPOS']
				aCrgFisico	:= aUmaPlan[SUB_LOGCNS]
				For nZ:= 1 to Len(aCrgFisico)
					If nZ == 1
						cLog += oCNSLog['TITULO']
						cLog += oCNSLog['CABECALHO']
					endIf
					cLog += CposToLine(aCrgFisico[nZ],aCposLog)					
				Next nZ
				
			Next nY
					
			cLog += cQuebra
		ElseIf(!lOnlyProc)
			cLog += I18N(STR0022,{ aContrato[LOG_CONTRA] }) + CRLF//Contrato [#1] : nenhum ajuste necessário.
		EndIf	
	Next nX
Return cLog


/*/{Protheus.doc} AjsCNFxCNS
Ajusta previsto do cronograma financeiro 
@author vitor.pires
@since 01/09/2022
@param cContra, character, Numero do Contrato
@param cRevisa, character, Revisao do contrato
@param aLog, array, Array do Log
@return lAjustou, logical, Indica se ajustou ou não
/*/
Static Function AjsCNFxCNS(cContra, cRevisa, cPlan, aLog)
	Local lAjustou := .F.
	Local cAlCNS := GetNextAlias()
	Local nTamLogCNF := 8
	Local aCNFLog	 := Array(nTamLogCNF)	

	BeginSQL Alias cAlCNS
		SELECT
		CNF.CNF_PARCEL,
		CNF.CNF_VLPREV,
		CNF.R_E_C_N_O_ REGCNF,
		SUM(CNS_PRVQTD * CNB.CNB_VLUNIT) CNFCALC,
		SUM(CNS_PRVQTD * CNB.CNB_VLUNIT) - CNF_VLPREV DIVERGENCIA
		FROM
		%table:CNS% CNS
		INNER JOIN %table:CNF% CNF ON(
				CNF_FILIAL = CNS_FILIAL
			AND CNF_CONTRA = CNS_CONTRA
			AND CNF_REVISA = CNS_REVISA
			AND CNF_NUMPLA = CNS_PLANI
			AND CNF_PARCEL = CNS_PARCEL
			AND CNF.%NotDel%)		
		INNER JOIN %table:CNB% CNB ON(
				CNB.CNB_FILIAL 	= CNS.CNS_FILIAL
			AND CNB.CNB_CONTRA 	= CNS.CNS_CONTRA
			AND CNB.CNB_REVISA 	= CNS.CNS_REVISA
			AND CNB.CNB_NUMERO 	= CNS.CNS_PLANI
			AND CNB.CNB_ITEM 	= CNS.CNS_ITEM
			AND CNB.%NotDel%)
		WHERE
				CNS_FILIAL 	= %xFilial:CNS%
		AND CNS.CNS_CONTRA 	= %exp:cContra% 
		AND	CNS.CNS_REVISA 	= %exp:cRevisa%
		AND CNS.CNS_PLANI 	= %exp:cPlan%
		AND CNS.%NotDel%
		GROUP BY CNF_PARCEL, CNF_VLPREV, CNF.R_E_C_N_O_
		HAVING ABS(SUM(CNS_PRVQTD * CNB.CNB_VLUNIT) - CNF_VLPREV) > 0.01
		ORDER BY CNF_PARCEL
	EndSQL

	While (cAlCNS)->(!EOF())		
		lAjustou := .T.
		CNF->(dbGoTo((cAlCNS)->REGCNF))

		aCNFLog[1] := (cAlCNS)->CNF_PARCEL
		aCNFLog[2] := CNF->CNF_SALDO	//Compatibilidade com a função <ReajuCrono>
		aCNFLog[3] := CNF->CNF_SALDO	//Compatibilidade com a função <ReajuCrono>
		aCNFLog[4] := CNF->CNF_VLREAL	//Compatibilidade com a função <ReajuCrono>
		aCNFLog[5] := CNF->CNF_VLREAL	//Compatibilidade com a função <ReajuCrono>
		aCNFLog[6] := (cAlCNS)->CNF_VLPREV
		aCNFLog[7] := (cAlCNS)->CNFCALC
		aCNFLog[8] := (cAlCNS)->(CNFCALC-CNF_VLPREV)

		aAdd(aLog[SUB_LOGCNF], aClone(aCNFLog))
		
		RecLock( "CNF", .F. )
		CNF->CNF_VLPREV := (cAlCNS)->CNFCALC
		CNF->( MsUnlock() )
		(cAlCNS)->(dbSkip())
	EndDo

	(cAlCNS)->(dbCloseArea())
Return lAjustou

/*/{Protheus.doc} AjustaCNS
Ajusta Realizado e saldo do cronograma fisico com base nas medições CNE, sendo a qtde medida conforme o MV_320SLD
@type function
@author vitor.pires
@since 25/10/2022
@param cContra, character, Numero do Contrato
@param cRevisa, character, Revisão do contrato
@param aLog, array, Array de Logs
@return variant, Se houve ajuste
/*/
Static Function AjustaCNS(cContra, cRevisa, nTipoSaldo, aLog ,cPlan)
	Local aAreas    := {CNS->(GetArea()), GetArea()}
	Local lAjustou 	:= .F.
	Local cAliasCND	:= GetNextAlias()
	Local cAliasCNS	:= GetNextAlias()
	Local nQuant	:= 0
	Local cChave	:= ""
	Local cFilCNB 	:= xFilial("CNB", _cFilCtr)
	Local cPlanVazia:= Space(GetSX3Cache("CND_NUMERO", "X3_TAMANHO"))
	Local cFilCNS	:= xFilial("CNS", _cFilCtr)
	Local nNovosld	:= 0
	Local nSaldoAnt := 0
	Local nDifMed	:= 0

	BeginSql Alias cAliasCND
		SELECT CNB_VLUNIT,CRONOG,PARCELA,CNE_NUMERO,CNE_ITEM,SUM(CNE_QUANT) CNE_QUANT,SUM(CNE_VLTOT) CNE_VLTOT 
		FROM(
			SELECT 
				CNB_VLUNIT,CXN_CRONOG CRONOG, CXN_PARCEL PARCELA,CNE_NUMERO,CNE_ITEM,SUM(CNE_QUANT) CNE_QUANT,
				SUM(CNE_VLTOT) CNE_VLTOT
				FROM %table:CNE% CNE 
				INNER JOIN %table:CNB% CNB ON(
					CNB_FILIAL= %exp:cFilCNB% 
					AND CNB_CONTRA=CNE_CONTRA 
					AND CNE_REVISA=CNB_REVISA 
					AND CNE_NUMERO=CNB_NUMERO 
					AND CNE_ITEM=CNB_ITEM 
					AND CNB.%NotDel%)
				INNER JOIN 	%table:CXN% CXN ON(
						CXN_FILIAL = CNE_FILIAL
					AND CXN_CONTRA = CNE_CONTRA
					AND CXN_REVISA = CNE_REVISA
					AND CXN_NUMPLA = CNE_NUMERO
					AND CXN_NUMMED = CNE_NUMMED
					AND CXN.CXN_CHECK  = 'T'
					AND CXN.%NotDel%)
				INNER JOIN %table:CND% CND ON(
						CND_FILIAL = CXN_FILIAL
					AND CND_CONTRA = CXN_CONTRA
					AND CND_REVISA = CXN_REVISA
					AND CND_NUMMED = CXN_NUMMED					
					AND CND.%NotDel%)
				WHERE
					CNE_CONTRA=%exp:cContra% 
					AND	CNE_REVISA=%exp:cRevisa%
					AND CNE_NUMERO =%exp:cPlan%
					AND CND_FILCTR = %exp:_cFilCtr% 
					AND CND.CND_NUMERO = %exp:cPlanVazia%
					AND CND.CND_DTFIM <> %exp:Space(8)%	
					AND CNE.%NotDel%					
				GROUP BY CNB_VLUNIT,CXN_CRONOG, CXN_PARCEL,CNE_NUMERO,CNE_ITEM
			UNION
				SELECT CNB_VLUNIT,CNF_NUMERO CRONOG, CND_PARCEL PARCELA,CNE_NUMERO,CNE_ITEM,SUM(CNE_QUANT) CNE_QUANT,
				SUM(CNE_VLTOT) CNE_VLTOT
				FROM %table:CNE% CNE 
				INNER JOIN %table:CND% CND  ON(
						CND_CONTRA = CNE_CONTRA
					AND CND_REVISA = CNE_REVISA
					AND CND_NUMERO = CNE_NUMERO
					AND CND_NUMMED = CNE_NUMMED
					AND CND.%NotDel%)
				INNER JOIN %table:CNF% CNF ON(
						CNF_CONTRA = CNE_CONTRA
					AND CNF_REVISA = CNE_REVISA
					AND CNF_NUMPLA = CNE_NUMERO
					AND CNF_PARCEL = CND_PARCEL
					AND CNF.%NotDel%)
				INNER JOIN %table:CNB% CNB ON(
						CNB_FILIAL = %exp:cFilCNB%
					AND CNB_CONTRA = CNE_CONTRA
					AND	CNE_REVISA = CNB_REVISA
					AND CNE_NUMERO = CNB_NUMERO
					AND CNE_ITEM = CNB_ITEM
					AND CNB.%NotDel%)
				WHERE 	CNE_CONTRA=%exp:cContra% 
					AND CNE_REVISA=%exp:cRevisa%
					AND CNE_NUMERO =%exp:cPlan%
					AND CND.CND_NUMERO <> %exp:cPlanVazia%
					AND CND.CND_DTFIM <> %exp:Space(8)%	
					AND CND.CND_FILCTR = %exp:_cFilCtr%
					AND CNE.%NotDel%					
				GROUP BY CNB_VLUNIT,CNF_NUMERO, CND_PARCEL,CNE_NUMERO,CNE_ITEM) ITEM
		GROUP BY CNB_VLUNIT,CRONOG,PARCELA,CNE_NUMERO,CNE_ITEM
		ORDER BY CRONOG,PARCELA,CNE_NUMERO,CNE_ITEM
	EndSQL

	CNS->(dbSetOrder(3)) //3-CNS_FILIAL+CNS_CONTRA+CNS_REVISA+CNS_CRONOG+CNS_PARCEL+CNS_PLANI+CNS_ITEM
	While (cAliasCND)->(!EOF())
		cChave := xFilial('CNS', _cFilCtr)+cContra + cRevisa + (cAliasCND)->(CRONOG+PARCELA+CNE_NUMERO+CNE_ITEM)
		IF CNS->(dbSeek(cChave))
			If nTipoSaldo == 1
				nQuant := (cAliasCND)->CNE_QUANT
			Else
				nQuant := (cAliasCND)->(CNE_VLTOT/CNB_VLUNIT) //proporcional
			EndIf	
			If !(CNS->CNS_RLZQTD == nQuant) .Or. !(CNS->CNS_SLDQTD == CNS->(CNS_PRVQTD-CNS_RLZQTD))	
				nSaldoAnt		:=	CNS->CNS_SLDQTD	// Saldo anterior ao ajuste
				RecLock( "CNS", .F. )
				CNS->CNS_RLZQTD := nQuant
				CNS->CNS_SLDQTD := CNS->(CNS_PRVQTD-CNS_RLZQTD)
				CNS->( MsUnlock() )
				lAjustou:=.T.
				aAdd(aLog[SUB_LOGCNS], {(cAliasCND)->PARCELA, CNS->CNS_ITEM, CNS->CNS_RLZQTD,nQuant,CNS->CNS_RLZQTD-nQuant,;
				nSaldoAnt,CNS->CNS_SLDQTD,CNS->CNS_SLDQTD-nSaldoAnt})
			EndIf
		EndIf
		(cAliasCND)->(dbSkip())
	EndDo
	(cAliasCND)->(dbCloseArea())

	BeginSQL Alias cAliasCNS
		SELECT CNS.R_E_C_N_O_ REGCNS
		FROM %table:CNS% CNS
		WHERE 
		CNS.CNS_FILIAL     = %exp:cFilCNS%
		AND CNS.CNS_CONTRA = %exp:cContra%
		AND CNS.CNS_REVISA = %exp:cRevisa%
		AND CNS.CNS_PLANI  = %exp:cPlan%
		
		AND CNS.CNS_PRVQTD-CNS.CNS_RLZQTD <> CNS.CNS_SLDQTD
		AND CNS.%NotDel%
	EndSQL

	While (cAliasCNS)->(!EOF())
		CNS->(DbGoTo((cAliasCNS)->REGCNS))
		nNovosld:= CNS->(CNS_PRVQTD-CNS_RLZQTD)// Previsto - realizado
		nDifCNS:= nNovosld - CNS->CNS_SLDQTD // Novo saldo - saldo prévio
		nDifMed:= CNS->(CNS_RLZQTD-CNS_RLZQTD)
		CNS->(aAdd(aLog[SUB_LOGCNS], {CNS_PARCEL, CNS_ITEM, CNS_RLZQTD,CNS_RLZQTD,nDifMed,;
			CNS_SLDQTD,nNovosld,nDifCNS}))
		RecLock("CNS", .F.)
		CNS->(CNS_SLDQTD:= CNS_PRVQTD-CNS_RLZQTD)
		CNS->(MsUnlock())
		lAjustou:= .T.
		(cAliasCNS)->(dbSkip())
	EndDo

	(cAliasCNS)->(dbCloseArea())

	aEval(aAreas, {|x| RestArea(x) })
	FwFreeArray(aAreas)
Return lAjustou

/*/{Protheus.doc} GetLogDef
	Retorna a definição para o log de <cTabela>
@author philipe.pompeu
@since 20/12/2022
@param cTabela, caractere
@return oLogDef, objeto, instância de JsonObject
/*/
Static Function GetLogDef(cTabela)
	Local oLogDef 	:= JsonObject():New()
	Local aCampos 	:= {}
	Local cAntes 	:= STR0018
	Local cDepois	:= STR0019
	Local nX 		:= 0
	Local cCampo 	:= ""
	Local cTipo 	:= ""
	Local cPicture	:= ""
	Local nTamanho	:= 0
	Local cTitulo	:= ""
	Local cHeader	:= ""
	Local cTitle	:= ""
	Local cCpoDef 	:= {}	
	Local cSubHead	:=""
	Local nLenPad := 0
	Local nTamCpos:= 0
	Local lDiferenca:= .F.

	Do Case
		Case cTabela == "CNF"
			aCampos := {'CNF_PARCEL', 'CNF_SALDO', 'CNF_VLREAL', 'CNF_VLPREV', 'CNF_VLPREV'}
			nTamCpos:= Len(aCampos)

			for nX := 1 to nTamCpos
				cCampo	:= aCampos[nX]
				cTipo	:= GetSx3Cache(cCampo, 'X3_TIPO')
				nTamanho:= GetSx3Cache(cCampo, 'X3_TAMANHO')
				cPicture:= AllTrim(GetSx3Cache(cCampo, 'X3_PICTURE'))

				If nX == nTamCpos
					cTitulo := STR0017 //Diferença
				Else					
					cTitulo := AllTrim(FWX3Titulo(cCampo))
				EndIf

				If cTipo == "N"
					nTamanho += GetSx3Cache(cCampo,'X3_DECIMAL')
				endif

				nLenPad := Max(nTamanho, Len(cTitulo))
				
				aAdd(cCpoDef,{nLenPad, cPicture})
				If cCampo == "CNF_PARCEL" .Or. nX == nTamCpos
					cHeader	+= PadC(cTitulo,nLenPad)	+"|"					
					cSubHead+= Replicate("_",nLenPad)	+"|"				
				Else
					cHeader	+= PadC(cTitulo	,(nLenPad * 2)+1 )	+"|"
					cSubHead+= PadC(cAntes	,nLenPad,'_')	+ "|"
					cSubHead+= PadC(cDepois	,nLenPad,'_')	+ "|"
					aAdd(cCpoDef,{nLenPad, cPicture})					
				Endif
			next nX
			
		Case cTabela == "CNS"
			aCampos := {'CNS_PARCEL', 'CNS_ITEM', 'CNS_RLZQTD', 'CNS_RLZQTD','CNS_SLDQTD','CNS_SLDQTD'}
			nTamCpos:= Len(aCampos)

			for nX := 1 to nTamCpos
				cCampo	:= aCampos[nX]
				cTipo	:= GetSx3Cache(cCampo, 'X3_TIPO')
				nTamanho:= GetSx3Cache(cCampo, 'X3_TAMANHO')
				cPicture:= AllTrim(GetSx3Cache(cCampo, 'X3_PICTURE'))
				lDiferenca:= (nX == nTamCpos .OR. nx == 4)

				If lDiferenca
					cTitulo := STR0017 //Diferença
				Else					
					cTitulo := AllTrim(FWX3Titulo(cCampo))
				EndIf

				If cTipo == "N"
					nTamanho += GetSx3Cache(cCampo,'X3_DECIMAL')
				endif

				nLenPad := Max(nTamanho, Len(cTitulo))
				
				aAdd(cCpoDef,{nLenPad, cPicture})
				If (cCampo $ "CNS_PARCEL|CNS_ITEM") .Or. lDiferenca
					cHeader	+= PadC(cTitulo,nLenPad)	+"|"					
					cSubHead+= Replicate("_",nLenPad)	+"|"				
				Else
					cHeader	+= PadC(cTitulo	,(nLenPad * 2)+1 )	+"|"
					cSubHead+= PadC(cAntes	,nLenPad,'_')	+ "|"
					cSubHead+= PadC(cDepois	,nLenPad,'_')	+ "|"
					aAdd(cCpoDef,{nLenPad, cPicture})					
				Endif
			next nX	
		Case cTabela == "CN9"
			aCampos := {'CN9_NUMERO', 'CN9_REVISA', 'CN9_TPCTO', 'CN9_SALDO', 'CN9_VLINI', 'CN9_VLATU'}
			nTamCpos:= Len(aCampos)

			for nX := 1 to nTamCpos
				cCampo	:= aCampos[nX]
				cTipo	:= GetSx3Cache(cCampo, 'X3_TIPO')
				nTamanho:= GetSx3Cache(cCampo, 'X3_TAMANHO')
				cPicture:= AllTrim(GetSx3Cache(cCampo, 'X3_PICTURE'))
								
				cTitulo := AllTrim(FWX3Titulo(cCampo))			

				If cTipo == "N"
					nTamanho += GetSx3Cache(cCampo,'X3_DECIMAL')
				endif

				nLenPad := Max(nTamanho, Len(cTitulo))
				
				aAdd(cCpoDef,{nLenPad, cPicture})
				If (cCampo $ "CN9_SALDO|CN9_VLINI|CN9_VLATU")
					cHeader	+= PadC(cTitulo	,(nLenPad * 2)+1 )	+"|"
					cSubHead+= PadC(cAntes	,nLenPad,'_')	+ "|"
					cSubHead+= PadC(cDepois	,nLenPad,'_')	+ "|"
					aAdd(cCpoDef,{nLenPad, cPicture})									
				Else
					cHeader	+= PadC(cTitulo,nLenPad)	+"|"					
					cSubHead+= Replicate("_",nLenPad)	+"|"
				Endif
			next nX
		Case cTabela == "CNA"
			aCampos := {'CNA_CONTRA', 'CNA_REVISA', 'CNA_NUMERO', 'CNA_FORNEC', 'CNA_SALDO', 'CNA_VLTOT'}
			nTamCpos:= Len(aCampos)

			for nX := 1 to nTamCpos
				cCampo	:= aCampos[nX]
				cTipo	:= GetSx3Cache(cCampo, 'X3_TIPO')
				nTamanho:= GetSx3Cache(cCampo, 'X3_TAMANHO')
				cPicture:= AllTrim(GetSx3Cache(cCampo, 'X3_PICTURE'))
								
				cTitulo := AllTrim(FWX3Titulo(cCampo))			

				If cTipo == "N"
					nTamanho += GetSx3Cache(cCampo,'X3_DECIMAL')
				endif

				nLenPad := Max(nTamanho, Len(cTitulo))
				
				aAdd(cCpoDef,{nLenPad, cPicture})				
				If (cCampo $ "CNA_SALDO|CNA_VLTOT")					
					cHeader	+= PadC(cTitulo	,(nLenPad * 2)+1 )	+"|"
					cSubHead+= PadC(cAntes	,nLenPad,'_')	+ "|"
					cSubHead+= PadC(cDepois	,nLenPad,'_')	+ "|"
					aAdd(cCpoDef,{nLenPad, cPicture})					
				Else
					cHeader	+= PadC(cTitulo,nLenPad)	+"|"					
					cSubHead+= Replicate("_",nLenPad)	+"|"
				Endif
			next nX
		Case cTabela == "CNB"
			aCampos := {'CNB_ITEM', 'CNB_PRODUT', 'CNB_DESCRI', 'CNB_QTDMED', 'CNB_SLDMED', 'CNB_VLDESC'}
			nTamCpos:= Len(aCampos)

			for nX := 1 to nTamCpos
				cCampo	:= aCampos[nX]
				cTipo	:= GetSx3Cache(cCampo, 'X3_TIPO')
				nTamanho:= GetSx3Cache(cCampo, 'X3_TAMANHO')
				cPicture:= AllTrim(GetSx3Cache(cCampo, 'X3_PICTURE'))
								
				cTitulo := AllTrim(FWX3Titulo(cCampo))			

				If cTipo == "N"
					nTamanho += GetSx3Cache(cCampo,'X3_DECIMAL')
				endif

				nLenPad := Max(nTamanho, Len(cTitulo))
				
				aAdd(cCpoDef,{nLenPad, cPicture})
				If (cCampo $ "CNB_QTDMED|CNB_SLDMED|CNB_VLDESC")
					cHeader	+= PadC(cTitulo	,(nLenPad * 2)+1 )	+"|"
					cSubHead+= PadC(cAntes	,nLenPad,'_')	+ "|"
					cSubHead+= PadC(cDepois	,nLenPad,'_')	+ "|"
					aAdd(cCpoDef,{nLenPad, cPicture})					
				Else
					cHeader	+= PadC(cTitulo,nLenPad)	+"|"					
					cSubHead+= Replicate("_",nLenPad)	+"|"				
				Endif
			next nX
	EndCase

	FwFreeArray(aCampos)
	cHeader+= CRLF + cSubHead + CRLF
	cTitle := AllTrim(FwSX2Util():GetX2Name(cTabela))+ I18N("[#1]", {cTabela})
	cTitle := PadC(cTitle	, Len(cSubHead), '_' ) + CRLF

	oLogDef['CABECALHO']:= cHeader
	oLogDef['TITULO'] 	:= cTitle
	oLogDef['CAMPOS'] 	:= cCpoDef

Return oLogDef

/*/{Protheus.doc} CriaArqLog
	Cria um arquivo para armazenamento do log de processamento.
@author vitor.pires | philipe.pompeu
@since 14/02/2023
@param oLogFile, objeto, variável que receberá a instância de FwFileWriter
@return lResult, lógico, se foi possível criar o arquivo
/*/
Static Function CriaArqLog(oLogFile)
	Local lResult := .F.
	Local cChvMD5 := DtoS(Date()) + Time()
	Local cNomeArq:= "CNTA320_"+MD5(cChvMD5, 2 )+ ".log"
	Local cInitLog:= ""

	oLogFile := FwFileWriter():New(cNomeArq , .T.)
	If lResult := oLogFile:Create()
		cInitLog:= I18N(STR0021,{DtoC(Date()), AllTrim(Time()) })
		cInitLog:= PadC(cInitLog,110,"=") + CRLF
		lResult	:= oLogFile:Write(cInitLog)
	EndIf	
Return lResult

/*/{Protheus.doc} InitLogDef
	Inicializa uma variável com a definição de todos os logs
@author philipe.pompeu
@since 14/02/2023
@return oLogDef, object, instância de JsonObject com as definições de log
/*/
Static Function InitLogDef()
	Local oLogDef := JsonObject():New()

	oLogDef["CN9"] := GetLogDef('CN9')
	oLogDef["CNF"] := GetLogDef('CNF')
	oLogDef["CNS"] := GetLogDef('CNS')
	oLogDef["CNA"] := GetLogDef('CNA')
	oLogDef["CNB"] := GetLogDef('CNB')
Return oLogDef

/*/{Protheus.doc} CposToLine
	Retorna uma linha com os dados de <aRegistro> conforme a definição estabelecida em <aCposLog>
@author philipe.pompeu
@since 14/02/2023
@param aRegistro, vetor, contêm o registro que deve ser impresso
@param aCposLog, vetor, contêm o metadado pra definição da linha
@return cLog, caractere, linha tratada
/*/
Static Function CposToLine(aRegistro,aCposLog)
	Local nW 		:= 0
	Local cLog		:= ""
	Local cPicture	:= ""
	Local nSizePad	:= 0
	Local nLenCpo	:= Len(aCposLog)
	
	for nW := 1 to nLenCpo
		nSizePad := aCposLog[nW,1]
		cPicture := aCposLog[nW,2]
		cLog += PadC(AllTrim(Transform(aRegistro[nW], cPicture)), nSizePad)
		cLog += "|"
		If (nW == nLenCpo)//No último campo
			cLog += CRLF //Pula linha no último campo
		EndIf
	next nW
Return cLog

/*/{Protheus.doc} AjsCtrElab
	Reajusta um contrato ainda em elaboração para corrigir possíveis inconsistências na base
@author philipe.pompeu
@since 03/07/2024
@param cAliasCtr, caractere, alias da query com o contrato a ser buscado
@param aLog, vetor, onde deve ser armazenado o log de processamento
@param oLogFile, objeto, instancia de FwFileWriter
/*/
Static Function AjsCtrElab(cAliasCtr, aLog, oLogFile)
	Local aAreas := {CN9->(GetArea()), CNA->(GetArea()), GetArea() }
	Local cChave := ""
	Local aNovoLog := {}
	Local aSubLog := {}
	Local aCNALog := {}
	Local lCompra := .F.
	Local lAjustou:= .F.
	Local nIndex := 0
	Local lHasPLServ := .F.
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.

	CN9->(DbSetOrder(1))
	cChave := (cAliasCtr)->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)
	
	If CN9->(DbSeek(cChave) .And. CN9_SITUAC == DEF_SELAB)

		lHasPLServ := Cn300RetSt('SERVIÇO', 2, /*cPlan*/, CN9->CN9_NUMERO, CN9->CN9_FILCTR, .F.)
		If !lHasPLServ //Se tiver qualquer planilha de serviço, não recalcula os saldos
			lCompra := (CN9->CN9_ESPCTR == '1')

			aNovoLog := Array(TAMANHOLOG)
			aNovoLog[LOG_CONTRA]:= CN9->CN9_NUMERO
			aNovoLog[LOG_REVISA]:= CN9->CN9_REVISA
			aNovoLog[LOG_TIPCTR]:= CN9->CN9_TPCTO
			aNovoLog[LOG_SLDCTR]:= CN9->CN9_SALDO
			aNovoLog[LOG_SLDPLA]:= 0		
			aNovoLog[LOG_VLINIC]:= CN9->CN9_VLINI
			aNovoLog[LOG_VLFINA]:= 0
			aNovoLog[LOG_VLATUA]:= CN9->CN9_VLATU
			aNovoLog[LOG_VLATUF]:= 0
			aNovoLog[LOG_TOTPLA]:= 0
			aNovoLog[LOG_SUBLOG]:= {}
			aNovoLog[LOG_AJUSTE]:= .F.

			aSubLog := aNovoLog[LOG_SUBLOG]

			CNA->(DbSetOrder(1))
			If CNA->(DbSeek(cChave))
				While CNA->( !Eof() .And. CNA_FILIAL+CNA_CONTRA+CNA_REVISA == cChave )
					aCNALog:= Array(TAM_SUBLOG)
					aCNALog[SUB_CONTRA]:= CNA->CNA_CONTRA
					aCNALog[SUB_REVISA]:= CNA->CNA_REVISA
					aCNALog[SUB_NUMPLA]:= CNA->CNA_NUMERO
					
					aCNALog[SUB_FORNEC]:= CNA->(IIF(lCompra, CNA_FORNEC, CNA_CLIENT))
					aCNALog[SUB_OLDSLD]:= CNA->CNA_SALDO					
					aCNALog[SUB_NEWSLD]:= 0
					aCNALog[SUB_OLDTOT]:= CNA->CNA_VLTOT
					aCNALog[SUB_NEWTOT]:= 0
					aCNALog[SUB_LOGCNB]:= {}
					aCNALog[SUB_LOGCNF]:= {}
					aCNALog[SUB_LOGCNS]:= {}

					aAdd(aSubLog, aClone(aCNALog))

					CNA->(DbSkip())
				EndDo			
			EndIf

			MsExecAuto({||  CNAjCtElab() }) //Usa o MsExecAuto pra prevenir erros relacionados ao uso do IsBlind dentro do CNTA300

			lAjustou := !(lMsErroAuto)
			aNovoLog[LOG_AJUSTE] := lAjustou

			If lAjustou
				If CNA->(DbSeek(cChave))
					While CNA->( !Eof() .And. CNA_FILIAL+CNA_CONTRA+CNA_REVISA == cChave )					
						nIndex := aScan(aSubLog, {|x| x[1]+x[2]+x[3] == CNA->(CNA_CONTRA+CNA_REVISA+CNA_NUMERO)})
						If nIndex > 0
							aSubLog[nIndex, SUB_NEWSLD] := CNA->CNA_SALDO //Caso tenha sofrido alteração
							aSubLog[nIndex, SUB_NEWTOT] := CNA->CNA_VLTOT //Caso tenha sofrido alteração
						EndIf
						CNA->(DbSkip())
					EndDo			
				EndIf
				aNovoLog[LOG_SLDPLA]:= CN9->CN9_SALDO
			EndIf
			aAdd(aLog, aClone(aNovoLog))
			
			oLogFile:Write(MontaLog({ aNovoLog }))
		EndIf

	EndIf

	aEval(aAreas,{|x|RestArea(x)})
	FwFreeArray(aAreas)
	FwFreeArray(aNovoLog)
	FwFreeArray(aCNALog)
Return

/*/{Protheus.doc} CNAjCtElab
	Recalcula os totalizadores e os descontos do contrato posicionado.
@author philipe.pompeu
@since 03/07/2024
/*/
Function CNAjCtElab()
	Local aArea 	:= GetArea()
	Local oModel 	:= Nil
	Local oMdlCN9 	:= Nil
	Local oMdlCNA 	:= Nil
	Local oMdlCNB 	:= Nil
	Local cModelId	:= IIF(CN9->CN9_ESPCTR == '1', 'CNTA300','CNTA301')
	Local bTrueWhen := FwBuildFeature( STRUCT_FEATURE_WHEN, ".T.")
	Local nX := 0
	Local nY := 0
	Local lResult := .F.
	Local nPercDesc := 0
	Local nQuant := 0
	Local nVlUnit := 0
	Private INCLUI	:= .F.

	oModel := FwLoadModel(cModelId)

	oModel:SetOperation(MODEL_OPERATION_UPDATE)

	If oModel:Activate()
		oMdlCN9 := oModel:GetModel("CN9MASTER")
		oMdlCNA := oModel:GetModel("CNADETAIL")
		oMdlCNB := oModel:GetModel("CNBDETAIL")

		//Libera totalmente os três modelos
		oMdlCN9:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,bTrueWhen)
		oMdlCNA:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,bTrueWhen)
		oMdlCNB:GetStruct():SetProperty('*',MODEL_FIELD_WHEN,bTrueWhen)
		CNTA300BlMd(oMdlCNA,.F.)
		CNTA300BlMd(oMdlCNB,.F.)

		for nX := 1 to oMdlCNA:Length()
			oMdlCNA:GoLine(nX)
			If !oMdlCNA:IsDeleted()
				for nY := 1 to oMdlCNB:Length() //Recalcula os totais e descontos dos itens
					oMdlCNB:GoLine(nY)
										
					nPercDesc 	:= oMdlCNB:GetValue('CNB_DESC')
					nQuant 		:= oMdlCNB:GetValue('CNB_QUANT')
					nVlUnit 	:= oMdlCNB:GetValue('CNB_VLUNIT')

					oMdlCNB:LoadValue('CNB_DESC'	, 0)
					oMdlCNB:LoadValue('CNB_VLDESC'	, 0)
					oMdlCNB:LoadValue('CNB_QUANT'	, 0)
					oMdlCNB:LoadValue('CNB_VLUNIT'	, 0)

					oMdlCNB:SetValue('CNB_QUANT'	, nQuant)
					oMdlCNB:SetValue('CNB_VLUNIT'	, nVlUnit)
					oMdlCNB:SetValue('CNB_DESC'		, nPercDesc)					
					
					oMdlCNB:DeleteLine()
				next nY

				//Limpa saldos da planilha
				oMdlCNA:LoadValue('CNA_SALDO', 0)
				oMdlCNA:LoadValue('CNA_VLTOT', 0)
				oMdlCNA:DeleteLine()
			EndIf
		next nX

		//Limpa campos do Contrato, já que os mesmos serão recalculados.
		oMdlCN9:LoadValue('CN9_VLINI', 0)
		oMdlCN9:LoadValue('CN9_VLATU', 0)
		oMdlCN9:LoadValue('CN9_SALDO', 0)
		
		for nX := 1 to oMdlCNA:Length()//Ao percorrer a CNA, deve recalcular tudo
			oMdlCNA:GoLine(nX)
			If oMdlCNA:IsDeleted()
				oMdlCNA:UnDeleteLine()
				
				for nY := 1 to oMdlCNB:Length()
					oMdlCNB:GoLine(nY)
					If oMdlCNB:IsDeleted()
						//Ao desfazer a exclusão, chama o pré-valid da CNB(função CN300PItPre), com <action> como 'UNDELETE', gatilhando o recalculo. Pra todos os efeitos, como se fosse uma nova inclusão
						oMdlCNB:UnDeleteLine()
					EndIf
				next nY

			EndIf
		next nX

		If oModel:VldData()
			/*Qualquer divergência no cronograma será tratada pela função <Cn300AjuMt> antes da gravação dos dados.*/
			oModel:CommitData()
		EndIf

		oModel:DeActivate()
	EndIf
	
	lResult := !(oModel:HasErrorMessage())

	FreeObj(oModel)

	RestArea(aArea)
	FwFreeArray(aArea)
Return
