#Include "PROTHEUS.CH"  
#Include "APVT100.CH"
#Include "WMSV105.CH"

#DEFINE WMSV10501 "WMSV10501"
#DEFINE WMSV10502 "WMSV10502"
#DEFINE WMSV10503 "WMSV10503"
#DEFINE WMSV10504 "WMSV10504"
#DEFINE WMSV10505 "WMSV10505"
#DEFINE WMSV10506 "WMSV10506"
#DEFINE WMSV10507 "WMSV10507"
#DEFINE WMSV10508 "WMSV10508"
#DEFINE WMSV10509 "WMSV10509"
#DEFINE WMSV10510 "WMSV10510"
#DEFINE WMSV10511 "WMSV10511"
#DEFINE WMSV10512 "WMSV10512"
#DEFINE WMSV10513 "WMSV10513"
#DEFINE WMSV10514 "WMSV10514"
#DEFINE WMSV10515 "WMSV10515"
#DEFINE WMSV10516 "WMSV10516"
#DEFINE WMSV10517 "WMSV10517"
#DEFINE WMSV10518 "WMSV10518"
#DEFINE WMSV10519 "WMSV10519"
#DEFINE WMSV10520 "WMSV10520"
#DEFINE WMSV10521 "WMSV10521"
#DEFINE WMSV10522 "WMSV10522"

//----------------------------------------------------------
/*/{Protheus.doc} WMSV105 - Romaneio de Embarque
Permite associar os volumes que serão embarcados e realizar 
a liberação para o faturamento.  

@version	P11
@since   15/04/15 
/*/
//----------------------------------------------------------
Function WMSV105()
Local cKey09 := VtDescKey(09)
Local cKey22 := VtDescKey(22)
Local cKey24 := VtDescKey(24)
Local bkey09 := VTSetKey(09)
Local bkey22 := VTSetKey(22)
Local bkey24 := VTSetKey(24)
Local aTela  := {}
Local lRet   := .T.
Local nOpc   := 0

Private cCodOpe	  := __cUserID
Private cRomaneio := Space(TamSx3("DCU_ROMEMB")[1])
Private cVolume	  := Space(TamSx3("DCU_CODVOL")[1])   
Private cTransp	  := Space(TamSx3("C5_TRANSP")[1])    
Private aPedidos  := {} // carrega pedidos do volume

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If Empty(cCodOpe)
		WmsMessage(STR0001,WMSV10501) // Operador nao cadastrado 
		lRet := .F.
	EndIf
	
	If lRet
		aTela := VtSave()
		VTCLear()        
		
		@ 0,0 VTSay "Selecione:" // Selecione:
		nOpc := VTaChoice(2,0,4,VTMaxCol(),{STR0035,STR0036}) // Anterior Faturamento // Posterior Faturamento 
		VtClearBuffer()
		
		If nOpc != 0
			WMSV1051(nOpc)
		EndIf
		
		If VtLastKey() == 27
			lRet := .F.
		EndIf
	Else
		VtKeyboard(Chr(20))  
	EndIf
	
	//-- Restaura teclas
	VTSetKey(09,bkey09,cKey09)
	VTSetKey(22,bkey22,cKey22)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return ( lRet )
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de romaneio de embarque anterior ao faturamento
//----------------------------------------------------------
Function WMSV105A()
	WMSV1051(1)
Return Nil
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de romaneio de embarque posterior ao faturamento
//----------------------------------------------------------
Function WMSV105B()
	WMSV1051(2)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} WMSV1051
Tela de Montagem do Romaneio de Embarque

@version	P11
@since   15/04/15
/*/
//----------------------------------------------------------
Function WMSV1051(nOpc)        
Local aTela       := VTSave()
Local cKey15      := VtDescKey(15)
Local bkey15      := VTSetKey(15)
Local cKey24      := VtDescKey(24)
Local bkey24      := VTSetKey(24)
Local nLin        := 0   
Local cMsg        := ""
Local cQuery      := ""
Local cAliasQry   := ""
Local lVolume     := .F.
Local lRomAuto    := SuperGetMV("MV_WMSROA",.F.,.F.) .And. !Empty(SuperGetMV("MV_WMSROM",.F.,""))
Local lRet        := .T.
Local lRomPosFat  := (nOpc == 2)
Local lRetPE      := .F.
Local lV105IMPETI := ExistBlock('V105IMPETI')
Local lV105POSLIB := ExistBlock('V105POSLIB')

	VTSetKey(24,{|| WMS105EST(lRomPosFat)}, STR0002) // Ctrl+X // Estorno
	VTSetKey(15,{|| WMS105CON(lRomPosFat)}, STR0003) // Ctrl+O // Romaneio 			WMSVTCabec(STR0004, .F., .F., .T.) // Romaneio de Embarque 

	Do While .T.
		VTCLear()
		cRomaneio := Space(TamSx3("DCU_ROMEMB")[1]) 	
		WMSVTCabec(STR0004, .F., .F., .T.) // Romaneio de Embarque
		@ 02, 00 VTSay PadR(STR0005, VTMaxCol()) // Informe o codigo:	 
		@ 03, 00 VTGet cRomaneio Valid VldRom(@cRomaneio,.F.,lRomPosFat,lRomAuto)
		VTRead()
		If VTLastKey() == 27
			lRet := .F.
		EndIf
		
		If lRet
			If lRomAuto .And. Empty(cRomaneio)
				cRomaneio := WMSProxSeq("MV_WMSROM","DCU_ROMEMB")
				@ 02, 00 VTSay PadR(STR0006+cRomaneio, VTMaxCol()) // Romaneio:
			EndIf
			// Pega a transportadora informada anteriormente
			If !Empty(cRomaneio)
				cQuery := " SELECT DCU.DCU_TRANSP FROM "+RetSqlName("DCU")+" DCU"
				cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'" 
				cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
				cQuery +=    " AND D_E_L_E_T_ = ' '"
				cQuery +=  " ORDER BY R_E_C_N_O_ DESC"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				cTransp := (cAliasQry)->DCU_TRANSP
			EndIf
			If Empty(cTransp)
				@ 04, 00 VTSay PadR("Transportadora:", VTMaxCol()) // Transportadora:
				@ 05, 00 VTGet cTransp Valid VldTransp(cTransp, .F.,,,lRomPosFat) F3 'SA4'
				VTRead()
			EndIf
			
			If VTLastKey() == 27
				lRet := .F.
			EndIf
			
			// Ponto de entrada para chamar impressão da etiqueta
			If lRet .And. lV105IMPETI
	  			ExecBlock('V105IMPETI',.F.,.F.,{cRomaneio,cTransp})
			EndIf
		EndIf		
		If lRet
			Do While .T.
				cVolume := Space(TamSx3("DCU_CODVOL")[1])
				VTCLear()
				
				WMSVTCabec(STR0004, .F., .F., .T.) // Romaneio de Embarque
				@ 02, 00 VTSay PadR(STR0006+cRomaneio, VTMaxCol()) // Romaneio:
				
				@ 03, 00 VTSay PadR("Transp.: ", VTMaxCol()) // Transportadora:
				@ 03, 10 VTGet cTransp Valid VldTransp(cTransp,.T.,cRomaneio,cVolume,lRomPosFat) F3 'SA4'
				
				VTKeyBoard(Chr(13))
				
				@ 05, 00 VTSay PadR(STR0007, VTMaxCol()) // Informe o Volume:
				@ 06, 00 VTGet cVolume Valid WMSV100VOL(3,,,,cVolume) .And. WMS105VOL(cRomaneio,cVolume,.F.,cTransp,lRomPosFat,lRomAuto)
				VTRead()
				
				If VTLastKey() == 27	// ESC
					// Valida se romaneio possui algum volume sem estar liberado
					If !lRomPosFat
						VTClear()
						//Somente realiza a pergunta se o usuário deseja liberar para faturamento caso o romaneio ainda não foi liberado
						If VldRomLib(cRomaneio) .Or. VtYesNo(STR0009,WMSV10512) // Deseja liberar esse Romaneio para o Faturamento?
							// Validações antes da efetivação da liberação para faturamento
							If ValidaCmp()
								lRet := WMS105FAT()
							EndIf
						EndIf
					EndIf
					If lRet .And. lV105POSLIB
	  					lRetPE := ExecBlock('V105POSLIB',.F.,.F.,{cRomaneio,cTransp})
	  					lRet := If(ValType(lRetPE)=='L',lRetPE,.F.)
	  				EndIf
  					Exit
				EndIf
			EndDo
		EndIf
		If !lRet
			Exit
		EndIf		
	EndDo
	//-- Restaura teclas
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} VldRom
Valida se o romaneio ja nao foi liberado                          	 			 		    

@version	P11
@since   16/04/15
/*/
//----------------------------------------------------------
Static Function VldRom(cRom,lEstorno,lRomPosFat,lRomAuto)
Local lRet         := .T.
Local lAchou       := .F.
Local cQuery       := ""
Local cAliasQry    := ""
Default lRomPosFat := .F.
Default lRomAuto   := .F.
	If !Empty(cRom)
		cQuery := " SELECT "
		If lEstorno
			cQuery +=    " DCS.DCS_LIBEST,"
		EndIf
		cQuery +=        " SC9.C9_NFISCAL"
		cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
		cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV"
		cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
		cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
		cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
		If lEstorno
			cQuery += " INNER JOIN "+RetSqlName("DCS")+" DCS"
			cQuery +=    " ON DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
			cQuery +=   " AND DCS.DCS_CODMNT = DCV.DCV_CODMNT"
			cQuery +=   " AND DCS.DCS_CARGA = DCV.DCV_CARGA"
			cQuery +=   " AND DCS.DCS_PEDIDO = DCV.DCV_PEDIDO"
			cQuery +=   " AND DCS.D_E_L_E_T_ = ' '"
		EndIf
		cQuery +=   " LEFT JOIN "+RetSqlName("SC9")+" SC9"
		cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=    " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
		cQuery +=    " AND SC9.C9_ITEM = DCV.DCV_ITEM"
		cQuery +=    " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
		cQuery +=    " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
		cQuery +=    " AND SC9.C9_ROMEMB = '"+cRom+"'"
		cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
		cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRom+"'"
		cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		Do While (cAliasQry)->(!Eof())
			lAchou := .T.
			// Quando estorno, valida se está faturado apenas se o volume não está liberado para estorno.
			// Utilizado no estorno por carteira em que o CanReverse libera o estorno dos processos de expedição
			If lEstorno .And. (cAliasQry)->DCS_LIBEST == "2"
				lRet := .F.
				If lRomPosFat .Or. Empty((cAliasQry)->C9_NFISCAL)
					lRet := .T.
					Exit
				EndIf
			ElseIf !lEstorno .And. !lRomPosFat .And. !Empty((cAliasQry)->C9_NFISCAL)
				//Caso não for romaneio pós faturamento e possuir pedidos faturados, não permite a inclusão de novos itens
				lRet := .F.
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		
		If !lAchou .And. (lEstorno .Or. lRomAuto)
			WmsMessage(STR0012,WMSV10503) // Romaneio nao encontrado!
			lRet := .F.
		EndIf
			
		If lAchou .And. !lRet
			WmsMessage(STR0011,WMSV10504) // Romaneio ja foi Faturado!
		EndIf
			
		If !lRet
			cRom := Space(TamSx3("DA3_PLACA")[1])
		EndIf
	Else
		If !lRomAuto
			lRet := .F.
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMS105VOL
Gravação do romaneio no volume                          	 			 		    

@version	P11
@since   16/04/15
/*/
//---------------------------------------------------------- 
Static Function WMS105VOL(cRom,cVol,lEstorno,cTransport,lRomPosFat,lRomAuto)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDCV := ""
Local cAliasDCU := ""
Local cCliente  := ""
Local cLoja     := ""
Local cResRomCL := SuperGetMv("MV_WMSRRCL",.F.,"0") // Restringir Romaneio por Cliente e Loja
Local cPedido   := ""

Default lRomPosFat := .F.
Default lRomAuto   := .F.

	If Empty(cVol)
		lRet := .F.
	EndIf
	
	If lRet
		If cResRomCL == "0" // 0=Não Valida
			cResRomCL := "N"
		ElseIf cResRomCL == "1" .And. !lRomPosFat // 1=Validar Ant Faturamento
			cResRomCL := "S"
		ElseIf cResRomCL == "2" .And. lRomPosFat // 2=Validar Pos Faturamento
			cResRomCL := "S"
		ElseIf cResRomCL == "3" // 3=Ambos
			cResRomCL := "S"
		Else
			cResRomCL := "N"
		EndIf
		
		If cResRomCL == "S"
			cQuery := " SELECT DCU.DCU_PEDIDO"
			cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
			cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
			cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRom+"'"
			cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasDCU := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCU,.F.,.T.)
			If (cAliasDCU)->(!Eof())
				cPedido := (cAliasDCU)->DCU_PEDIDO
			EndIf
			(cAliasDCU)->(dbCloseArea())
		EndIf
		
		dbSelectArea("DCU")
		DCU->(dbSetOrder(1))
		DCU->(dbSeek(xFilial("DCU")+cVol))
		While DCU->(!Eof()) .And. DCU->(DCU_FILIAL+DCU_CODVOL) == xFilial("DCU")+cVol
			If cResRomCL == "S" .And. !Empty(cPedido) .And. !WMSV081CLI(DCU->DCU_PEDIDO,cPedido,.F./*lShowMsg*/,@cCliente,@cLoja) // Apenas permite volumes no romaneio com o mesmo cliente e loja
				WmsMessage(WmsFmtMsg(STR0039,{{"[VAR01]",cCliente},{"[VAR02]",cLoja},{"[VAR03]", Iif(!Empty(DCU->DCU_CARGA),DCU->DCU_CARGA+'/'+DCU->DCU_PEDIDO,DCU->DCU_PEDIDO) }})) // "Este romaneio está sendo utilizado pelo Cliente:[VAR01] Loja:[VAR02] Carga/Pedido:[VAR03]" 
				lRet := .F.
				Exit
			EndIf
			
			If !Empty(DCU->DCU_ROMEMB)
				If DCU->DCU_ROMEMB == cRom
					If !lEstorno
						WmsMessage(WmsFmtMsg(STR0013,{{"[VAR01]",cVol}}),WMSV10505) // Volume: [VAR01] ja esta vinculado ao Romaneio! 
						lRet := .F.
					EndIf	
				Else
					WmsMessage(WmsFmtMsg(STR0014,{{"[VAR01]",cVol},{"[VAR02]",DCU->DCU_ROMEMB}}),WMSV10506) // Volume: [VAR01] ja foi vinculado ao Romaneio: [VAR02]!
					lRet := .F.
				EndIf
				Exit
			Else
				If lEstorno
					WmsMessage(WmsFmtMsg(STR0015,{{"[VAR01]",cVol},{"[VAR02]",cRom}}),WMSV10507) // Volume: [VAR01] nao esta vinculado ao Romaneio: [VAR02]!
					lRet := .F.
					Exit
				EndIf
			EndIf
			
			If DCU->DCU_STCONF == "1" .And. VldConfExp(DCU->DCU_CODMNT,DCU->DCU_CARGA,DCU->DCU_PEDIDO,DCU->DCU_CODVOL)
				WmsMessage(WmsFmtMsg(STR0046,{{"[VAR01]",cVol}}),WMSV10522) // Volume: [VAR01] precisa ser conferido antes da inclusão no romaneio de embarque!
				lRet := .F.
				Exit
			EndIf
			
			DCU->(dbSkip())
		EndDo
	EndIf
	
	//Verifica se o volume encontra-se com o processo de separação em andamento
	If lRet .And. !lEstorno
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
		cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
		cQuery +=    " AND DCV.DCV_CODVOL = '"+cVol+"'"
		cQuery +=    " AND DCV.DCV_STATUS = '3'"
		cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
		cAliasDCV := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
		If (cAliasDCV)->(!EoF())
			lRet := .F.
			WmsMessage(WmsFmtMsg(STR0044,{{"[VAR01]",cVol}})) // Volume [VAR01] em montagem durante a separação.
		EndIf
		(cAliasDCV)->(DbCloseArea())
	EndIf
	If lRet .And. !lEstorno
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
		cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
		cQuery +=    " AND DCV.DCV_CODVOL = '"+cVol+"'"
		cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
		cQuery +=    " AND EXISTS ("
		cQuery +=        " SELECT 1"
		cQuery +=          " FROM "+RetSqlName("SC9")+" SC9"
		cQuery +=         " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=           " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
		cQuery +=           " AND SC9.C9_ITEM = DCV.DCV_ITEM"
		cQuery +=           " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
		cQuery +=           " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
		cQuery +=           " AND SC9.C9_NFISCAL <> ' '"
		cQuery +=           " AND SC9.D_E_L_E_T_ = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasDCV := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
		If !lRomPosFat
			If (cAliasDCV)->(!Eof())
				WmsMessage(WmsFmtMsg(STR0041,{{"[VAR01]",cVol}}),"Rom. Ant. Fat.") // Volume [VAR01] possui item Faturado e nao pode ser usado neste tipo de romaneio.
				lRet := .F.
			EndIf
		Else
			If (cAliasDCV)->(Eof())
				WmsMessage(WmsFmtMsg(STR0042,{{"[VAR01]",cVol}}),"Rom. Pos. Fat.") // Volume [VAR01] possui item Nao Faturado e nao pode ser usado neste tipo de romaneio.
				lRet := .F.
			EndIf
		EndIf
		(cAliasDCV)->(dbCloseArea())
	EndIf
	
	If lRet .And. lRomPosFat .And. !lEstorno
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
		cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
		cQuery +=    " AND DCV.DCV_CODVOL = '"+cVol+"'"
		cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
		cQuery +=    " AND EXISTS ("
		cQuery +=        " SELECT 1"
		cQuery +=          " FROM "+RetSqlName("SC9")+" SC9"
		cQuery +=         " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=           " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
		cQuery +=           " AND SC9.C9_ITEM = DCV.DCV_ITEM"
		cQuery +=           " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
		cQuery +=           " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
		cQuery +=           " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=           " AND NOT EXISTS ("
		cQuery +=                   " SELECT 1"
		cQuery +=                     " FROM "+RetSqlName("SF2")+" SF2"
		cQuery +=                    " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
		cQuery +=                      " AND SF2.F2_DOC = SC9.C9_NFISCAL"
		cQuery +=                      " AND SF2.F2_SERIE = SC9.C9_SERIENF"
		cQuery +=                      " AND SF2.F2_CLIENTE = SC9.C9_CLIENTE"
		cQuery +=                      " AND SF2.F2_LOJA = SC9.C9_LOJA"
		If !Empty(cTransport)
			cQuery +=                   " AND SF2.F2_TRANSP = '"+cTransport+"'"
		EndIf
		cQuery +=                      " AND SF2.D_E_L_E_T_ = ' '))"
		cQuery := ChangeQuery(cQuery)
		cAliasDCV := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
		If (cAliasDCV)->(!Eof())
			WmsMessage(WmsFmtMsg(STR0037,{{"[VAR01]",cVol}}),WMSV10519) // Volume [VAR01] nao esta faturado ou a transportadora informada nao corresponde a nota faturada!
			lRet := .F.
		EndIf
		(cAliasDCV)->(dbCloseArea())
	EndIf
	
	If lRet .And. !lEstorno
		// Valida se no serviço a liberação do faturamento é pelo romaneio de embarque,
		// apenas quando não for Romaneio posterior ao faturamento
		If lRet := (lRomPosFat .Or. WMS105SER())
			// Valida se todos os itens do pedido estão com a separação finalizada.
			If lRet := (lRomPosFat .Or. WMS105PED())
				// Grava Romaneio realizando as validações de volume
				If lRet := GrvRom(cRom,cVol,,lRomAuto)
					// Valida e grava transportadora
					lRet:= (lRomPosFat .Or. GrvTransp(cRom,cVol,cTransport,lRomPosFat))
				EndIf
			EndIf
		EndIf
	EndIf
	
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMS105SER
Valida se no serviço a liberação do faturamento é pelo romaneio
de embarque.
@version	P11
@since   15/04/15
/*/
//----------------------------------------------------------
Static Function WMS105SER()
Local lRet      := .T.
Local cQuery := ""
Local cAliasQry := GetNextAlias()

	cQuery := " SELECT DCU.DCU_CODVOL"
	cQuery +=   " FROM "+RetSqlName('DCU')+" DCU"
	cQuery +=  " INNER JOIN "+RetSqlName('DCV')+" DCV"
	cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
	cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
	cQuery +=    " AND DCV.DCV_PEDIDO = DCU.DCU_PEDIDO"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName('SC9')+" SC9"
	cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=    " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
	cQuery +=    " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
	cQuery +=    " AND SC9.C9_ITEM = DCV.DCV_ITEM"
	cQuery +=    " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
	cQuery +=    " AND SC9.C9_LOTECTL = DCV.DCV_LOTE"
	cQuery +=    " AND SC9.C9_NUMLOTE = DCV.DCV_SUBLOT"
	cQuery +=    " AND SC9.C9_NFISCAL = ' '"
	cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName('DCS')+" DCS"
	cQuery +=     " ON DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
	cQuery +=    " AND DCS.DCS_CODMNT = DCU.DCU_CODMNT"
	cQuery +=    " AND DCS.DCS_LIBPED <> '5'" // Liberação romaneio
	cQuery +=    " AND DCS.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=    " AND DCU.DCU_CODVOL = '"+cVolume+"'"
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof()) 
		WmsMessage(STR0016,WMSV10508) //-- O Serviço não está configurado com liberação do pedido por romaneio (DC5_LIBPED)!
		VTKeyBoard(Chr(20))
		lRet := .F.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ValidaCmp
Caso contenha itens do pedido com componentes, verifica se todos os componentes estão nesse mesmo romaneio com a quantidade correta 
para formar a quantidade do produto pai, caso contrário deverá alertar e não liberar para o faturamento.
@version	P11
@since   18/04/15
/*/
//----------------------------------------------------------                             
Static Function ValidaCmp()
Local cAliasQry    := GetNextAlias()
Local cPrdOri      := ""
Local cProduto     := ""
Local nQtdVol      := ""
Local nQtdLib      := ""
Local nPos1        := 0
Local nPos2        := 0
Local lCompleto    := .T.
Local cQuery       := ""
Local i            := 0
Local nI           := 0
Local aComponentes := {}
Local aPrdPend     := {}
Local aCab         := {}
Local aSize        := {}
Local aTelaAnt     := VTSave(00, 00, VTMaxRow(), VTMaxCol())

	// Pedidos
	dbSelectArea("SC9")
	SC9->(dbSetOrder(1))
	VTMsg("Processando...") // Processando...
	cQuery := " SELECT DCV.DCV_CODPRO,"
	cQuery +=        " DCV.DCV_PRDORI,"
	cQuery +=        " DCV.DCV_PEDIDO,"
	cQuery +=        " DCV.DCV_CARGA,"
	cQuery +=        " DCV.DCV_ITEM,"
	cQuery +=        " DCV.DCV_SEQUEN,"
	cQuery +=        " SUM(DCV.DCV_QUANT) DCV_QUANT"
	cQuery +=   " FROM "+RetSqlName('DCU')+" DCU"
	cQuery +=  " INNER JOIN "+RetSqlName('DCV')+" DCV"
	cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL" 
	cQuery +=    " AND DCV.DCV_PEDIDO = DCU.DCU_PEDIDO"
	cQuery +=    " AND DCV.DCV_CODPRO <> DCV.DCV_PRDORI"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial('DCU')+"'"	    
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=  " GROUP BY DCV.DCV_CODPRO,DCV.DCV_PRDORI,DCV.DCV_PEDIDO,DCV.DCV_CARGA,DCV.DCV_ITEM,DCV.DCV_SEQUEN"
	cQuery +=  " ORDER BY DCV.DCV_CARGA,DCV.DCV_PEDIDO,DCV.DCV_CODPRO"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		If SC9->(dbSeek(xFilial("SC9")+(cAliasQry)->(DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI)))			
			If SC9->C9_BLWMS == "01"
				If (nPos1:= aScan(aComponentes,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == (cAliasQry)->(DCV_CARGA+DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI)})) == 0					
					aAdd(aComponentes,{	(cAliasQry)->DCV_CARGA,;  // Carga
										(cAliasQry)->DCV_PEDIDO,; // Pedido										
										(cAliasQry)->DCV_ITEM,;   // Item
										(cAliasQry)->DCV_SEQUEN,; // Sequencia
										(cAliasQry)->DCV_PRDORI,; // Produto Origem
										SC9->C9_IDDCF,;           // Identificador WMS										
										{{(cAliasQry)->DCV_CODPRO,; // Produto Componente
										(cAliasQry)->DCV_QUANT}}})  // Quantidade volume
				Else					
					If (nPos2:= aScan(aComponentes[nPos1][7],{|x| x[1] == (cAliasQry)->DCV_CODPRO})) == 0
						aAdd(aComponentes[nPos1][7],{(cAliasQry)->DCV_CODPRO,; // Produto Componente
										             (cAliasQry)->DCV_QUANT})  // Quantidade volume

					Else
						aComponentes[nPos1][7][nPos2][2] += (cAliasQry)->DCV_QUANT
					EndIf
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(DbCloseArea())

	If Len(aComponentes) > 0  //-- calcula a quantidade de itens completos quando possui componentes
		// Componentes
		dbSelectArea("D11")
		D11->(dbSetOrder(3))
		For nPos1:= 1 to Len(aComponentes)
			cCarga   := aComponentes[nPos1][1]
			cPedido  := aComponentes[nPos1][2]
			cItem    := aComponentes[nPos1][3]
			cSequen  := aComponentes[nPos1][4]
			cPrdOri  := aComponentes[nPos1][5]
			cIdDCF   := aComponentes[nPos1][6]				
			nQtdLib := 0
			For nPos2 := 1 To Len(aComponentes[nPos1][7])
				cProduto := aComponentes[nPos1][7][nPos2][1]
				nQtdVol  := aComponentes[nPos1][7][nPos2][2]
				If D11->(dbSeek(xFilial("D11")+cPrdOri+cProduto))
					If QtdComp(nQtdLib) < QtdComp(nQtdVol/D11->D11_QTMULT)
						nQtdLib := nQtdVol/D11->D11_QTMULT
					EndIf
				EndIf
			Next nPos2
			D11->(dbSeek(xFilial("D11")+cPrdOri))
			While D11->(!Eof()) .And. D11->(D11_FILIAL+D11_PRODUT) == xFilial("D11")+cPrdOri
				If (nPos2:= aScan(aComponentes[nPos1][7],{|x| x[1] == D11->D11_PRDCMP})) == 0
					DocPend(aPrdPend,cCarga,cPedido,cItem,cSequen,D11->D11_PRDCMP,cPrdOri,cIdDCF,nQtdLib,0,D11->D11_QTMULT)										
				Else
					cProduto := aComponentes[nPos1][7][nPos2][1]
					nQtdVol  := aComponentes[nPos1][7][nPos2][2]
					If QtdComp(nQtdLib) > QtdComp(nQtdVol/D11->D11_QTMULT)
						DocPend(aPrdPend,cCarga,cPedido,cItem,cSequen,cProduto,cPrdOri,cIdDCF,nQtdLib,nQtdVol/D11->D11_QTMULT,D11->D11_QTMULT)
					EndIf
				EndIf
				D11->(dbSkip())
			EndDo
		Next nPos1
	EndIf
	
	If Len(aPrdPend) > 0
		lCompleto := .F.
		aCab  := {RetTitle("DCV_CODPRO"),RetTitle("DCV_PEDIDO"),RetTitle("DCV_CARGA"),RetTitle("DCV_CODVOL")}
		aSize := {TamSx3("DCV_CODPRO")[1],TamSx3("DCV_PEDIDO")[1],TamSx3("DCV_CARGA")[1],TamSx3("DCV_CODVOL")[1]}
		WMSVTCabec("Produtos Pendentes",.F.,.F.,.T.)
		VTaBrowse(2,0,(VTMaxRow()-2),VTMaxCol(),aCab,aPrdPend,aSize)
		VTKeyBoard(Chr(20))	
	Else	
		//Valida se não há algum pedido do romaneio pendente de faturamento em outro romaneio, com transportadoras diferentes
		dbSelectArea("SC5")
		SC5->(dbSetOrder(1))//C5_FILIAL+C5_NUM
		dbSelectArea("SC9")
		SC9->(dbSetOrder(1))//C9_FILIAL+C9_PEDIDO
		
		cQuery:= " SELECT DISTINCT DCU.DCU_PEDIDO, DCU.DCU_TRANSP "
		cQuery+=   " FROM "+RetSqlName("DCU")+" DCU"
		cQuery+=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
		cQuery+=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
		cQuery+=    " AND DCU.D_E_L_E_T_ = ' '"
		cQuery:= ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof())
			If SC5->(dbSeek(xFilial("SC5")+(cAliasQry)->DCU_PEDIDO))
				If  SC9->(dbSeek(xFilial("SC9")+SC5->C5_NUM))
					While (SC9->(!Eof()) .And. SC9->C9_FILIAL == SC5->C5_FILIAL .And. SC9->C9_PEDIDO == SC5->C5_NUM)
						If SC9->C9_BLWMS == '05' .And. Empty(SC9->C9_NFISCAL) .And. !Empty((cAliasQry)->DCU_TRANSP)
							If SC5->C5_TRANSP != (cAliasQry)->DCU_TRANSP
								WmsMessage(WmsFmtMsg(STR0032,{{"[VAR01]",SC9->C9_ROMEMB}}),WMSV10516) //"O romaneio [VAR01] está pendente para faturamento, com transportadora diferente. "	
								lCompleto := .F.
								Exit
							EndIf
						EndIf
						SC9->(dbSkip())
					EndDo
				EndIf
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return lCompleto
//----------------------------------------------------------
/*/{Protheus.doc} WMS105FAT
Liberação para o faturamento
@version	P11
@since   15/04/15
/*/
//----------------------------------------------------------                             
Static Function WMS105FAT()
Local lRet := .T.
Local lRetLib := .F.
Local aPedCarg  := {}
Local aErroLib  := {}
Local aAreaAnt  := GetArea()
Local cAliasQry := ""
Local cAliasDCV := ""
Local cQuery    := ""
Local cNewSequen:= ""
Local cSequen   := ""
Local nPos      := 0
Local nI        := 0
Local nAux      := 0

	VTMsg("Processando...") // Processando...
	// Busca todos os itens dos volumes com código do romaneio
	cQuery := " SELECT DCV.DCV_CODMNT,"
	cQuery +=        " DCV.DCV_PRDORI,"
	cQuery +=        " DCV.DCV_LOTE,"
	cQuery +=        " DCV.DCV_SUBLOT,"
	cQuery +=        " DCV.DCV_CARGA,"
	cQuery +=        " DCV.DCV_PEDIDO,"
	cQuery +=        " DCV.DCV_ITEM,"
	cQuery +=        " DCV.DCV_SEQUEN,"
	cQuery +=        " DCF.DCF_SERVIC,"
	cQuery +=        " DCF.DCF_LOCAL,"
	cQuery +=        " DCF.DCF_ENDER,"
	cQuery +=        " DCF.DCF_ID,"
	cQuery +=        " SUM(DCV.DCV_QUANT) DCV_QUANT"
	cQuery +=   " FROM "+RetSqlName("DCU")+" DCU" 
	cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV" 
	cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'" 
	cQuery +=    " AND DCV.DCV_CODMNT = DCU.DCU_CODMNT" 
	cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
	cQuery +=    " AND DCV.DCV_CODPRO = DCV.DCV_PRDORI"
	cQuery +=    " AND DCV.DCV_STATUS = '1'"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9" 
	cQuery +=    " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'" 
	cQuery +=   " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
	cQuery +=   " AND SC9.C9_ITEM = DCV.DCV_ITEM"
	cQuery +=   " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN" 
	cQuery +=   " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
	cQuery +=   " AND SC9.C9_BLWMS = '01'"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("DCF")+" DCF" 
	cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'" 
	cQuery +=   " AND DCF.DCF_ID = SC9.C9_IDDCF"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'" 
	cQuery +=   " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=   " AND DCU.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY DCV.DCV_CODMNT,"
	cQuery +=          " DCV.DCV_CODPRO,"
	cQuery +=          " DCV.DCV_PRDORI,"
	cQuery +=          " DCV.DCV_LOTE,"
	cQuery +=          " DCV.DCV_SUBLOT,"
	cQuery +=          " DCV.DCV_CARGA,"
	cQuery +=          " DCV.DCV_PEDIDO,"
	cQuery +=          " DCV.DCV_ITEM,"
	cQuery +=          " DCV.DCV_SEQUEN," 
	cQuery +=          " DCF.DCF_SERVIC,"
	cQuery +=          " DCF.DCF_LOCAL,"
	cQuery +=          " DCF.DCF_ENDER,"
	cQuery +=          " DCF.DCF_ID"
	// Quando produto componente, considera somente o primeiro componente no calculo
	// Pois até esse ponto já foi validado se os outros componentes são multiplos
	cQuery += " UNION ALL"
	cQuery += "SELECT DCV.DCV_CODMNT,"
	cQuery +=       " DCV.DCV_PRDORI,"
	cQuery +=       " DCV.DCV_LOTE,"
	cQuery +=       " DCV.DCV_SUBLOT,"
	cQuery +=       " DCV.DCV_CARGA,"
	cQuery +=       " DCV.DCV_PEDIDO,"
	cQuery +=       " DCV.DCV_ITEM,"
	cQuery +=       " DCV.DCV_SEQUEN,"
	cQuery +=       " DCF.DCF_SERVIC,"
	cQuery +=       " DCF.DCF_LOCAL,"
	cQuery +=       " DCF.DCF_ENDER,"
	cQuery +=       " DCF.DCF_ID,"
	cQuery +=       " SUM(DCV.DCV_QUANT/ D11.D11_QTMULT) DCV_QUANT"
	cQuery +=  " FROM "+RetSqlName("DCU")+" DCU"
	cQuery += " INNER JOIN "+RetSqlName("DCV")+" DCV"
	cQuery +=    " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
	cQuery +=   " AND DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=   " AND DCV.DCV_CODMNT = DCU.DCU_CODMNT"
	cQuery +=   " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
	cQuery +=   " AND DCV.DCV_CODPRO <> DCV.DCV_PRDORI"
	cQuery +=   " AND DCV.DCV_STATUS = '1'"
	cQuery +=   " AND DCV.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9"
	cQuery +=    " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'" 
	cQuery +=   " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
	cQuery +=   " AND SC9.C9_ITEM = DCV.DCV_ITEM"
	cQuery +=   " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
	cQuery +=   " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
	cQuery +=   " AND SC9.C9_BLWMS = '01'"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("DCF")+" DCF"
	cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=   " AND SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=   " AND DCF.DCF_ID = SC9.C9_IDDCF"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN "+RetSqlName("D11")+" D11" 
	cQuery +=    " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=   " AND D11.D11_PRODUT = DCF.DCF_CODPRO"
	cQuery +=   " AND D11.D11_PRDORI = DCF.DCF_CODPRO"
	cQuery +=   " AND D11.D11_PRDCMP = DCV.DCV_CODPRO"
	cQuery +=   " AND D11.D11_SEQUEN = (SELECT MIN(D11A.D11_SEQUEN)"
	cQuery +=                           " FROM "+RetSqlName("D11")+" D11A"
	cQuery +=                          " WHERE D11A.D11_FILIAL = D11.D11_FILIAL"
	cQuery +=                            " AND D11A.D11_PRDORI = D11.D11_PRDORI"
	cQuery +=                            " AND D11A.D_E_L_E_T_ = '')"
	cQuery +=   " AND D11.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'" 
	cQuery +=   " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=   " AND DCU.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY DCV.DCV_CODMNT,"
	cQuery +=          " DCV.DCV_PRDORI,"
	cQuery +=          " DCV.DCV_LOTE,"
	cQuery +=          " DCV.DCV_SUBLOT," 
	cQuery +=          " DCV.DCV_CARGA,"
	cQuery +=          " DCV.DCV_PEDIDO," 
	cQuery +=          " DCV.DCV_ITEM,"
	cQuery +=          " DCV.DCV_SEQUEN," 
	cQuery +=          " DCF.DCF_SERVIC,"
	cQuery +=          " DCF.DCF_LOCAL,"
	cQuery +=          " DCF.DCF_ENDER,"
	cQuery +=          " DCF.DCF_ID"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	Begin Transaction
		SC9->(dbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		DCV->(dbSetOrder(1))
		Do While (cAliasQry)->(!Eof())
			If SC9->(dbSeek(xFilial("SC9")+(cAliasQry)->(DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI)))
				lRetLib := WmsDivSC9(;
					SC9->C9_CARGA,;           //-- Carga
					SC9->C9_PEDIDO,;          //-- Pedido
					SC9->C9_ITEM,;            //-- Item
					SC9->C9_PRODUTO,;         //-- Codigo Produto
					(cAliasQry)->DCF_SERVIC,; //-- Serviço
					SC9->C9_LOTECTL,;         //-- Lote
					SC9->C9_NUMLOTE,;         //-- Sub-Lote
					Nil,;                     //-- Numero Serie
					(cAliasQry)->DCV_QUANT,;  //-- Quantidade
					Nil,;                     //-- Qtd 2 UM
					SC9->C9_LOCAL,;           //-- Armazem
					SC9->C9_ENDPAD,;          //-- Endereço
					(cAliasQry)->DCF_ID,;     //-- Id DCF
					.T.,;                     //-- lWmsLibSC9 - Libera C9_BLWMS
					.T.,;                     //-- Gera empenho
					Nil,;                     //-- cBlqWMS
					SC9->(Recno()),;          //-- nRecSC9
					cRomaneio,;               //-- Numero do romaneio de embarque
					@cNewSequen,;             //-- Nova Sequencia do SC9 criada
					Nil)                      //-- lLotVazio
				
				// Adiciona os itens do volume que precisarão ter o DCV_SEQUEN alterados
				If lRetLib
					//-- Atualização da DCV com o sequen gerado pela divisão
					cQuery := " SELECT DCV.R_E_C_N_O_ RECNODCV" 
					cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
					cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV"
					cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
					cQuery +=    " AND DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
					cQuery +=    " AND DCV.DCV_CODMNT = DCU.DCU_CODMNT"
					cQuery +=    " AND DCV.DCV_CARGA = DCU.DCU_CARGA"
					cQuery +=    " AND DCV.DCV_PEDIDO = DCU.DCU_PEDIDO"
					cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
					cQuery +=    " AND DCV.DCV_PRDORI = '"+(cAliasQry)->DCV_PRDORI+"'"
					cQuery +=    " AND DCV.DCV_ITEM = '"+(cAliasQry)->DCV_ITEM +"'"
					cQuery +=    " AND DCV.DCV_SEQUEN = '"+(cAliasQry)->DCV_SEQUEN+"'"
					cQuery +=    " AND DCV.DCV_LOTE = '"+(cAliasQry)->DCV_LOTE+"'"
					cQuery +=    " AND DCV.DCV_SUBLOT = '"+(cAliasQry)->DCV_SUBLOT+"'"
					cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
					cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
					cQuery +=    " AND DCU.DCU_CARGA = '"+(cAliasQry)->DCV_CARGA+"'"
					cQuery +=    " AND DCU.DCU_PEDIDO = '"+(cAliasQry)->DCV_PEDIDO+"'"
					cQuery +=    " AND DCU.DCU_CODMNT = '"+(cAliasQry)->DCV_CODMNT+"'"
					cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
					cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
					cAliasDCV := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
					While (cAliasDCV)->(!Eof())
						DCV->(dbGoTo((cAliasDCV)->RECNODCV))
						cSequen := DCV->DCV_SEQUEN
						
						If !Empty(cNewSequen) .And. cNewSequen != DCV->DCV_SEQUEN
							cSequen := cNewSequen
						EndIf
						
						RecLock("DCV",.F.)
						DCV->DCV_STATUS := '2'
						DCV->DCV_SEQUEN := cSequen
						DCV->(MsUnlock())
						
						(cAliasDCV)->(dbSkip())
					EndDo
					(cAliasDCV)->(dbCloseArea())
					nAux := aScan(aPedCarg,{|x| x[1]+x[2] == (cAliasQry)->DCV_PEDIDO+(cAliasQry)->DCV_CARGA})  //Informações guardadas por aluno
					If nAux == 0
						aAdd(aPedCarg,{(cAliasQry)->DCV_PEDIDO,(cAliasQry)->DCV_CARGA})
					EndIf
					
				Else
					aAdd(aErroLib,{(cAliasQry)->DCV_PRDORI,(cAliasQry)->DCV_PEDIDO,(cAliasQry)->DCV_CARGA})
					lRetLib := .T.
				EndIf
			EndIf
			
			// Equaliza os sequens da conferencia de expedição caso houver
			WmsEqizSeq(.F./*lEstorno*/,(cAliasQry)->DCV_PEDIDO,(cAliasQry)->DCV_ITEM,(cAliasQry)->DCV_PRDORI)
			
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		
		If Len(aErroLib) > 0
			lRet := .F.
		EndIf
		
		//Grava cód. da transportadora na carga(DAK) e no pedido(SC5)
		If lRet .And. !Empty(cTransp)
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))//C5_FILIAL+C5_NUM
			dbSelectArea("DAK")
			DAK->(dbSetOrder(1))//DAK_FILIAL+DAK_COD			
			For nPos := 1 To Len(aPedCarg)
				If SC5->(dbSeek(xFilial("SC5")+aPedCarg[nPos][1]))
					If SC5->C5_TRANSP != cTransp
						RecLock("SC5",.F.)
						SC5->C5_TRANSP := cTransp
						SC5->(MsUnlock())
					EndIf
					If DAK->(dbSeek(xFilial("DAK")+aPedCarg[nPos][2]))
						RecLock("DAK",.F.)
						DAK_TRANSP := cTransp
						DAK->(MsUnlock())	
					EndIf
				EndIf
			Next nPos
		EndIf		
		If !lRet
			DisarmTransaction()
			aCab  := {RetTitle("C9_PRODUTO"),RetTitle("C9_PEDIDO"),RetTitle("C9_CARGA")}
			aSize := {TamSx3("C9_PRODUTO")[1],TamSx3("C9_PEDIDO")[1],TamSx3("C9_CARGA")[1]}
			WMSVTCabec("Erro Liberação",.F.,.F.,.T.)
			VTaBrowse(2,0,(VTMaxRow()-2),VTMaxCol(),aCab,aErroLib,aSize)
		EndIf
	End Transaction
	
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMS105CON
Monta consulta dos volumes do Romaneio
@version	P11
@since   22/04/15
/*/
//----------------------------------------------------------
Static Function WMS105CON(lRomPosFat)
Local aTela     := VTSave()
Local cKey15    := VtDescKey(15)
Local bkey15    := VTSetKey(15)
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local nPos      := 1  
Local aConsulta := {}
Local aOpcoes   := {}
Local aTamOpc   := {}
Local lRet      := .T.

	If Empty(cRomaneio)
		lRet := .F.
	EndIf
	
	If lRet
		cQuery := " SELECT DCU.DCU_CARGA,"
		cQuery +=        " DCU.DCU_PEDIDO,"
		cQuery +=        " DCU.DCU_CODVOL,"
		cQuery +=        " DCU.DCU_CODMNT,"
		cQuery +=        " SC9.C9_ROMEMB"
		cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
		cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV"
		cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
		cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
		cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN "+RetSqlName("SC9")+" SC9"
		cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=    " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
		cQuery +=    " AND SC9.C9_ITEM = DCV.DCV_ITEM"
		cQuery +=    " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
		cQuery +=    " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
		cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
		cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
		cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
		If !lRomPosFat
			cQuery +=    " AND SC9.C9_NFISCAL = ' '"
		EndIf
		cQuery +=   " GROUP BY DCU.DCU_CARGA,"
		cQuery +=            " DCU.DCU_PEDIDO,"
		cQuery +=            " DCU.DCU_CODVOL,"
		cQuery +=            " DCU.DCU_CODMNT,"
		cQuery +=            " SC9.C9_ROMEMB"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof())
			If aScan(aConsulta,{|x| x[1]+x[2]+x[3] == (cAliasQry)->(DCU_CODVOL+DCU_CARGA+DCU_PEDIDO)}) == 0
				aAdd(aConsulta,{;
					(cAliasQry)->DCU_CODVOL,;
					(cAliasQry)->DCU_CARGA,;
					(cAliasQry)->DCU_PEDIDO,;
					If(Empty((cAliasQry)->C9_ROMEMB),"Nao","Sim")})
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
		
		VTCLear()
		If Len(aConsulta) > 0
			@ 0,0 VtSay STR0006+cRomaneio //-- Romaneio:
			@ 1,0 VtSay STR0040+AllTrim(Str(Len(aConsulta))) //-- Qtde. volumes:
			If !lRomPosFat
				aOpcoes := {STR0017,STR0018,STR0019,STR0020}
				aTamOpc := {10,6,6,8}
			Else
				aOpcoes := {STR0017,STR0018,STR0019}
				aTamOpc := {10,6,6}
			EndIf
			nPos := VTaBrowse(2,,,,aOpcoes,aConsulta,aTamOpc)
			VtRestore(,,,,aTela)
		Else
			WmsMessage(STR0022,WMSV10509) //-- Romaneio não encontrado!
			lRet := .F.
			VtKeyboard(Chr(20))
		EndIf
	EndIf
	
	VTSetKey(15,bkey15,cKey15)
	VtRestore(,,,,aTela)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMS105EST
Realiza o estorno de um volume do romaneio
@version	P11
@since   22/04/15
/*/
//----------------------------------------------------------
Static Function WMS105EST(lRomPosFat)
Local aTela     := VTSave()
Local cKey24    := VtDescKey(24)
Local bkey24    := VTSetKey(24)
Local cRomEst   := cRomaneio
Local cVolEst   := Space(TamSx3("DCU_CODVOL")[1])
Local cAliasQry := ""
Local cAliasDCV := ""
Local cNewSequen:= ""
Local cQuery    := ""
Local cSequen   := ""
Local cSeqD04   := ""
Local nQuant    := 0
Local nQtdConf  := 0
Local lRet      := .T.

	VTCLear()
	If Empty(cRomEst)
		WMSVTCabec(STR0023, .F., .F., .T.) //-- Estorno Volume Rom.
		@ 02, 00 VTSay PadR(STR0024, VTMaxCol()) //-- Informe o Romaneio:
		@ 03, 00 VTGet cRomEst Valid VldRom(@cRomEst,.T.,lRomPosFat)
		VTRead()
	ElseIf !VldRom(@cRomEst,.T.,lRomPosFat)
		lRet := .F.
	EndIf
	
	If lRet
		If VTLastKey() == 27
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		WMSVTCabec(STR0023, .F., .F., .T.) //-- Estorno Volume Rom.
		@ 02, 00 VTSay PadR(STR0006+cRomEst, VTMaxCol()) //-- Romaneio:
		@ 04, 00 VTSay PadR(STR0025, VTMaxCol()) //-- Informe o Volume:
		@ 05, 00 VTGet cVolEst Valid WMSV100VOL(3,,,,cVolEst) .And. WMS105VOL(cRomEst,cVolEst,.T.,,lRomPosFat)
		VTRead()
		
		If VTLastKey() == 27
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		If VtYesNo(WmsFmtMsg(STR0026,{{"[VAR01]",cVolEst}}),WMSV10510) //-- Confirma o estorno do volume [VAR01] desse romaneio de embarque?
			If !lRomPosFat
				cQuery := " SELECT SC9.C9_PEDIDO,"
				cQuery +=        " SC9.C9_ITEM,"
				cQuery +=        " SC9.C9_SEQUEN,"
				cQuery +=        " SC9.C9_PRODUTO,"
				cQuery +=        " SC9.C9_NFISCAL"
				cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
				cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV"
				cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
				cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
				cQuery +=    " AND DCV.DCV_STATUS = '2'"
				cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
				cQuery +=  " INNER JOIN "+RetSqlName("DCS")+" DCS"
				cQuery +=     " ON DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
				cQuery +=    " AND DCS.DCS_CODMNT = DCV.DCV_CODMNT"
				cQuery +=    " AND DCS.DCS_CARGA = DCV.DCV_CARGA"
				cQuery +=    " AND DCS.DCS_PEDIDO = DCV.DCV_PEDIDO"
				cQuery +=    " AND DCS.DCS_LIBEST = '2'"
				cQuery +=    " AND DCS.D_E_L_E_T_ = ' '"
				cQuery +=  " INNER JOIN "+RetSqlName("SC9")+" SC9"
				cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
				cQuery +=    " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
				cQuery +=    " AND SC9.C9_ITEM = DCV.DCV_ITEM"
				cQuery +=    " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
				cQuery +=    " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
				cQuery +=    " AND SC9.C9_NFISCAL <> ' '"
				cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
				cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomEst+"'"
				cQuery +=    " AND DCU.DCU_CODVOL = '"+cVolEst+"'"
				cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
				If (cAliasQry)->(!Eof()) // Apenas valida quando não está liberado para estorno. Deixa passar quando estorno por carteira
					WmsMessage(STR0028,WMSV10511) //-- Nao foi possivel realizar o estorno do volume, pois ja esta faturado!
					VtKeyboard(Chr(20))
					lRet := .F.
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf
			
			If lRet
				DCU->(dbSetOrder(1))
				SC9->(dbSetOrder(1))
				Begin Transaction
					If !lRomPosFat
						cQuery := " SELECT DCV.DCV_CODVOL,"
						cQuery +=        " DCV.DCV_CODMNT,"
						cQuery +=        " DCV.DCV_PRDORI,"
						cQuery +=        " DCV.DCV_LOTE,"
						cQuery +=        " DCV.DCV_SUBLOT,"
						cQuery +=        " DCV.DCV_CARGA,"
						cQuery +=        " DCV.DCV_PEDIDO,"
						cQuery +=        " DCV.DCV_ITEM,"
						cQuery +=        " DCV.DCV_SEQUEN,"							
						cQuery +=        " (SUM(DCV.DCV_QUANT / CASE WHEN D11.D11_QTMULT IS NULL THEN 1"
						cQuery +=                                  " ELSE D11.D11_QTMULT END) / COUNT(CASE WHEN D11.D11_QTMULT IS NULL THEN 1"
						cQuery +=                                                                        " ELSE D11.D11_QTMULT END)) DCV_QUANT"
						cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
						cQuery +=  " INNER JOIN "+RetSqlName("DCU")+" DCU"
						cQuery +=     " ON DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
						cQuery +=    " AND DCU.DCU_CODVOL = DCV.DCV_CODVOL"
						cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomEst+"'"
						cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
						cQuery +=  " INNER JOIN "+RetSqlName("SC9")+" SC9"
						cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
						cQuery +=    " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
						cQuery +=    " AND SC9.C9_ITEM = DCV.DCV_ITEM"
						cQuery +=    " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
						cQuery +=    " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
						cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
						cQuery +=   " LEFT JOIN "+RetSqlName("D11")+" D11"
						cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
						cQuery +=    " AND D11.D11_PRDCMP = DCV.DCV_CODPRO"
						cQuery +=    " AND D11.D11_PRDORI = DCV.DCV_PRDORI"
						cQuery +=    " AND D11.D11_PRODUT = DCV.DCV_PRDORI"
						cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
						cQuery +=  " INNER JOIN "+RetSqlName("DCS")+" DCS"
						cQuery +=     " ON DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
						cQuery +=    " AND DCS.DCS_CODMNT = DCV.DCV_CODMNT"
						cQuery +=    " AND DCS.DCS_CARGA = DCV.DCV_CARGA"
						cQuery +=    " AND DCS.DCS_PEDIDO = DCV.DCV_PEDIDO"
						cQuery +=    " AND DCS.DCS_LIBEST = '2'"
						cQuery +=    " AND DCS.D_E_L_E_T_ = ' '"
						cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
						cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
						cQuery +=    " AND DCV.DCV_CODVOL = '"+cVolEst+"'"
						cQuery +=    " AND DCV.DCV_STATUS = '2'"
						cQuery +=  " GROUP BY DCV.DCV_CODVOL,"
						cQuery +=           " DCV.DCV_CODMNT,"
						cQuery +=           " DCV.DCV_PRDORI,"
						cQuery +=           " DCV.DCV_LOTE,"
						cQuery +=           " DCV.DCV_SUBLOT,"
						cQuery +=           " DCV.DCV_CARGA,"
						cQuery +=           " DCV.DCV_PEDIDO,"
						cQuery +=           " DCV.DCV_ITEM,"
						cQuery +=           " DCV.DCV_SEQUEN"
						cQuery := ChangeQuery(cQuery)
						cAliasQry := GetNextAlias()
						dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
						Do While (cAliasQry)->(!Eof()) .And. lRet
							cNewSequen := Nil
							// Realiza o estorno da SC9, aglutinando caso tenha liberado parcial
							lRet := WmsEstVC9((cAliasQry)->DCV_PEDIDO,(cAliasQry)->DCV_ITEM,(cAliasQry)->DCV_SEQUEN,(cAliasQry)->DCV_PRDORI,(cAliasQry)->DCV_QUANT,Nil,.T.,@cNewSequen)
							If lRet
								//-- Atualização da DCV com o sequen gerado pela divisão
								cQuery := " SELECT DCV.R_E_C_N_O_ RECNODCV" 
								cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
								cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV"
								cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
								cQuery +=    " AND DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
								cQuery +=    " AND DCV.DCV_CODMNT = DCU.DCU_CODMNT"
								cQuery +=    " AND DCV.DCV_CARGA = DCU.DCU_CARGA"
								cQuery +=    " AND DCV.DCV_PEDIDO = DCU.DCU_PEDIDO"
								cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
								cQuery +=    " AND DCV.DCV_PRDORI = '"+(cAliasQry)->DCV_PRDORI+"'"
								cQuery +=    " AND DCV.DCV_ITEM = '"+(cAliasQry)->DCV_ITEM +"'"
								cQuery +=    " AND DCV.DCV_SEQUEN = '"+(cAliasQry)->DCV_SEQUEN+"'"										
								cQuery +=    " AND DCV.DCV_LOTE = '"+(cAliasQry)->DCV_LOTE+"'"
								cQuery +=    " AND DCV.DCV_SUBLOT = '"+(cAliasQry)->DCV_SUBLOT+"'"
								cQuery +=    " AND DCV.DCV_STATUS = '2'"
								cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
								cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
								cQuery +=    " AND DCU.DCU_CARGA = '"+(cAliasQry)->DCV_CARGA+"'"
								cQuery +=    " AND DCU.DCU_PEDIDO = '"+(cAliasQry)->DCV_PEDIDO+"'"
								cQuery +=    " AND DCU.DCU_CODMNT = '"+(cAliasQry)->DCV_CODMNT+"'"
								cQuery +=    " AND DCU.DCU_CODVOL = '"+(cAliasQry)->DCV_CODVOL+"'"						
								cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomEst+"'"
								cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
								cAliasDCV := GetNextAlias()
								DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
								While (cAliasDCV)->(!Eof())				
									DCV->(dbGoTo((cAliasDCV)->RECNODCV))
									cSequen := DCV->DCV_SEQUEN
									nQuant  := 0
									
									If cNewSequen != DCV->DCV_SEQUEN
										cSequen := cNewSequen
										DCV->(dbSetOrder(1))
										If DCV->(dbSeek(xFilial("DCV")+DCV->(DCV_CODMNT+DCV_CODVOL+DCV_PRDORI+DCV_CODPRO+DCV_LOTE+DCV_SUBLOT+DCV_ITEM)+cSequen))
											// Carrega quantidade
											nQuant := DCV->DCV_QUANT
											// Apaga registro
											RecLock("DCV",.F.)
											DCV->(dbDelete())
											DCV->(MsUnLock())
										EndIf
									EndIf
									
									DCV->(dbGoTo((cAliasDCV)->RECNODCV))
									RecLock("DCV",.F.)				
									DCV->DCV_STATUS := '1'
									DCV->DCV_SEQUEN := cSequen
									DCV->DCV_QUANT  += nQuant
									DCV->(MsUnlock())
									
									(cAliasDCV)->(dbSkip())
								EndDo
								(cAliasDCV)->(dbCloseArea())
							EndIf
							// Equaliza as sequencias da D04 com base no estorno da DCV
							WmsEqizSeq(.T./*lEstorno*/,(cAliasQry)->DCV_PEDIDO,(cAliasQry)->DCV_ITEM,(cAliasQry)->DCV_PRDORI)
							(cAliasQry)->(dbSkip())		
						EndDo
						(cAliasQry)->(dbCloseArea())
					EndIf
					DCU->(dbSeek(xFilial("DCU")+cVolEst))
					While DCU->(!Eof()) .And. DCU->(DCU_FILIAL+DCU_CODVOL) == xFilial("DCU")+cVolEst
						RecLock("DCU",.F.)
						DCU->DCU_ROMEMB := Space(TamSx3("DCU_ROMEMB")[1])
						DCU->DCU_TRANSP := Space(TamSx3("DCU_TRANSP")[1])
						DCU->(MsUnlock())
						DCU->(dbSkip())
					EndDo
				End Transaction
			EndIf
		EndIf
	EndIf	
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil
/*--------------------------------------------------------
---WMS105PED
---Valida se existe algum item do volume que não foi totalmente separado,
---utilizando como referência a tabela SDC que só é criada após a finalização da separação
---felipe.m 28/10/2015
--------------------------------------------------------*/
Static Function WMS105PED()
Local aAreaAnt := GetArea()
Local cAliasQry := ""
Local cQuery := ""
Local lRet := .T.
Local aPrdPend := {}
Local aCab := {}
Local aSize := {}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
	dbSelectArea("SC9")
	dbSelectArea("SDC")
	SC9->(dbSetOrder(1))
	SDC->(dbSetOrder(1))
	cQuery := " SELECT DCV.DCV_CARGA," 
	cQuery +=        " DCV.DCV_PEDIDO,"
	cQuery +=        " DCV.DCV_ITEM,"
	cQuery +=        " DCV.DCV_SEQUEN,"
	cQuery +=        " DCV.DCV_PRDORI"
	cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
	cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
	cQuery +=    " AND DCV.DCV_CODVOL = '"+cVolume+"'"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		// C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		If SC9->(dbSeek(xFilial("SC9")+(cAliasQry)->(DCV_PEDIDO+DCV_ITEM+DCV_SEQUEN+DCV_PRDORI)))
			// DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
			If !SDC->(dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_LOTECTL+SC9->C9_NUMLOTE+SC9->C9_ENDPAD+SC9->C9_NUMSERI))
				aAdd(aPrdPend,{SC9->C9_PRODUTO,SC9->C9_PEDIDO,(cAliasQry)->DCV_CARGA})
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	If Len(aPrdPend) > 0
		WmsMessage(STR0029,WMSV10513) // Existem itens do volume que não foram totalmente separados.
		VTKeyBoard(Chr(20))		
		lRet := .F.
		//			
		aCab  := {RetTitle("DCV_CODPRO"),RetTitle("DCV_PEDIDO"),RetTitle("DCV_CARGA")}
		aSize := {TamSx3("DCV_CODPRO")[1],TamSx3("DCV_PEDIDO")[1],TamSx3("DCV_CARGA")[1]}
		WMSVTCabec(STR0043,.F.,.F.,.T.) // Produtos Pendentes
		VTaBrowse(2,0,(VTMaxRow()-2),VTMaxCol(),aCab,aPrdPend,aSize)
	EndIf
	
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------
---VldTransp
---Valida se existe transportador informado
---Amanda Vieira 16/11/2015
--------------------------------------------------------*/
Static Function VldTransp(cTransport,lGrava,cRom,cVol,lRomPosFat )
Local lRet := .T.
Local aAreaAnt := GetArea()

Default cRom := ""
Default cVol := ""
	
	If !Empty(cTransport)
		dbSelectArea("SA4")
		SA4->(dbSetOrder(1)) //A4_FILIAL+A4_COD
		If !(SA4->(dbSeek(xFilial("SA4")+cTransport))) 
			WmsMessage(STR0030,WMSV10514) //--Transportadora Inválida!
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. lGrava
		If lRomPosFat
			// Validação da transportadora quando pós faturamento
			lRet := VldTPosFat()
		EndIf
		
		If lRet	
			lRet := GrvTransp(cRom, cVol, cTransport,lRomPosFat)
		EndIf
	EndIf
	
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
	RestArea(aAreaAnt)
Return lRet
/*--------------------------------------------------------
---GrvTransp
---Grava cód. da Transportadora 
---Valida se há integração com GFE
---Amanda Vieira 17/11/2015
--------------------------------------------------------*/
Static Function GrvTransp(cRom, cVol, cTransport,lRomPosFat)
Local lGFE      := .F.  //Indica se há romaneio de carga em aberto no GFE
Local lRet      := .T.
Local cQuery    := ""
Local cQuerySC9 := ""
Local cAliasSC9 := ""
Local cAliasQry := ""
Local aAreaDCU  := DCU->(GetArea())
Local aAreaDCV  := DCV->(GetArea())
Local lIntGFE   := SuperGetMv("MV_INTGFE",.T.,.T.)

	cQuery := " SELECT R_E_C_N_O_ RECNODCU"
	cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=    " AND (DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=     " OR DCU.DCU_CODVOL = '"+cVol+"')"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	If (cAliasQry)->(!Eof())
		DCU->(dbGoto((cAliasQry)->RECNODCU))
		If !lRomPosFat
			//Verifica se não está integrado com o GFE
			dbSelectArea("GWN")
			GWN->(dbSetOrder(1))//GWN_FILIAL+GWN_NRROM
			dbSelectArea("DCV")
			DCV->(dbSetOrder(1))//DCV_FILIAL+DCV_CODMNT+DCV_CODVOL			
			DCV->(dbSeek(xFilial("DCV")+DCU->DCU_CODMNT+DCU->DCU_CODVOL))
			While (DCV->(!EoF()) .And. DCV->DCV_CODMNT == DCU->DCU_CODMNT .And. DCV->DCV_CODVOL == DCU->DCU_CODVOL)
				If !Empty(cTransport) .And. lIntGFE .And. GWN->(dbSeek(xFilial("GWN")+DCV->DCV_CARGA)) 
					WmsMessage(WmsFmtMsg(STR0031,{{"[VAR01]",DCV->DCV_CARGA}}),WMSV10515)//"Não é possível alterar a transportadora. Carga pendente no SIGAGFE "
					lGFE := .T.	
					lRet := .F.		
					Exit
				EndIf
				DCV->(dbSkip())
			EndDo
			
			//Grava os campos de transporte 
			If lRet .And. DCU->DCU_TRANSP != cTransport  .And. !Empty(DCU->DCU_TRANSP)
				(cAliasQry)->(dbGoTop())
			
				cQuerySC9 := " SELECT SC9.C9_ROMEMB"
				cQuerySC9 +=   " FROM "+RetSqlName("SC9")+" SC9"
				cQuerySC9 +=  " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
				cQuerySC9 +=    " AND SC9.C9_ROMEMB = '"+cRom+"'"
				cQuerySC9 +=    " AND SC9.C9_NFISCAL = ' '"
				cQuerySC9 +=    " AND SC9.C9_BLWMS = '05'"
				cQuerySC9 +=    " AND SC9.D_E_L_E_T_ = ''"
				cQuerySC9 := ChangeQuery(cQuerySC9)
				cAliasSC9 := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuerySC9),cAliasSC9,.F.,.T.)
				
				If (cAliasSC9)->(!Eof())
					WmsMessage(STR0034,WMSV10518)//"Romaneio encontra-se liberado para faturamento, não é possível alterar a transportadora "
					cTransport := DCU->DCU_TRANSP
					lRet := .F.
				EndIf
				(cAliasSC9)->(DbCloseArea())
			EndIf
		EndIf
		If lRet .And. !Empty(DCU->DCU_TRANSP) .And. DCU->DCU_TRANSP != cTransport
			lRet := VtYesNo(STR0033,WMSV10517) //-- "Confirma a alteração da transportadora de todo o romaneio?"
		EndIf
		If lRet 
			(cAliasQry)->(dbGoTop())
			While (cAliasQry)->(!Eof()) 
				DCU->(dbGoTo((cAliasQry)->RECNODCU))
				If !lGFE .And. DCU->DCU_TRANSP != cTransport
					RecLock("DCU",.F.)
					DCU->DCU_TRANSP := cTransport
					DCU->(MsUnLock())
				EndIf
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf 
		(cAliasQry)->(DbCloseArea())
		
		If !lRet
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
		
RestArea(aAreaDCU)
RestArea(aAreaDCV)
Return lRet
/*--------------------------------------------------------
---GrvRom
---Grava cód. de Romaneio 
---Amanda Vieira 17/11/2015
--------------------------------------------------------*/
Static Function GrvRom(cRom, cVol, cTransport,lRomAuto)
Local lRet := .T.
Local cQuery
Local cAliasQry
Local aAreaDCU := DCU->(GetArea())
Local aAreaDCV := DCV->(GetArea())

Default lRomAuto := .F.

	cQuery := " SELECT R_E_C_N_O_ RECNODCU"
	cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=    " AND (DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=     " OR DCU.DCU_CODVOL = '"+cVol+"')"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

	//Grava cód. do Romaneio
	If lRet
		(cAliasQry)->(dbGoTop())
		While (cAliasQry)->(!Eof()) 
			DCU->(dbGoto((cAliasQry)->RECNODCU))
				RecLock("DCU",.F.)
				DCU->DCU_ROMEMB := cRom
				DCU->(MsUnLock())
			(cAliasQry)->(dbSkip())
		EndDo
	EndIf 
	(cAliasQry)->(DbCloseArea())
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
RestArea(aAreaDCU)
RestArea(aAreaDCV)
Return lRet
/*--------------------------------------------------------------------
---VldTPosFat
---Valida de a transportadora é valida para montagem pós faturamento.
---felipe.m 15/12/2015
--------------------------------------------------------------------*/
Static Function VldTPosFat()
Local aAreaAnt := GetArea()
Local lRet := .T.
Local cQuery := ""
Local cAliasQry := ""
	
	If !Empty(cTransp)
		// Procura de existe alguma nota com transportador diferente do informado
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("DCU")+" DCU"
		cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
		cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
		cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
		cQuery +=    " AND EXISTS ("
		cQuery +=        " SELECT 1"
		cQuery +=          " FROM "+RetSqlName("DCV")+" DCV"
		cQuery +=         " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
		cQuery +=           " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
		cQuery +=           " AND DCV.D_E_L_E_T_ = ' '"
		cQuery +=           " AND EXISTS ("
		cQuery +=               " SELECT 1"
		cQuery +=                 " FROM "+RetSqlName("SC9")+" SC9"
		cQuery +=                " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=                  " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
		cQuery +=                  " AND SC9.C9_ITEM = DCV.DCV_ITEM"
		cQuery +=                  " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
		cQuery +=                  " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
		cQuery +=                  " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=                  " AND EXISTS ("
		cQuery +=                      " SELECT 1"
		cQuery +=                        " FROM "+RetSqlName("SF2")+" SF2"
		cQuery +=                       " WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
		cQuery +=                         " AND SF2.F2_DOC = SC9.C9_NFISCAL"
		cQuery +=                         " AND SF2.F2_SERIE = SC9.C9_SERIENF"
		cQuery +=                         " AND SF2.F2_CLIENTE = SC9.C9_CLIENTE"
		cQuery +=                         " AND SF2.F2_LOJA = SC9.C9_LOJA"
		cQuery +=                         " AND SF2.F2_TRANSP <> '"+cTransp+"'"
		cQuery +=                         " AND SF2.D_E_L_E_T_ = ' ')))"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			WmsMessage(STR0038,WMSV10520) // Transportador informado é diferente da nota fiscal!
			lRet := .F.
		EndIf
		
		(cAliasQry)->(dbCloseArea())
	EndIf
RestArea(aAreaAnt)
Return lRet

Static Function DocPend(aPrdPend,cCarga,cPedido,cItem,cSequen,cProduto,cPrdOri,cIdDCF,nQtdLib,nQtdVol,nQtdMult)
Local cQuery    := ""
Local cAliasDCV := ""
Local cAliasDCR := ""
Local lVolMnt   := .F. 
Local nPos      := 0
	// Volumes sem romaneio de embarque
	cQuery := " SELECT DCV.DCV_CODVOL"
	cQuery +=   " FROM "+RetSqlName('DCU')+" DCU"
	cQuery +=  " INNER JOIN "+RetSqlName('DCV')+" DCV"
	cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL" 
	cQuery +=    " AND DCV.DCV_PEDIDO = DCU.DCU_PEDIDO"
	cQuery +=    " AND DCV.DCV_CODPRO = '"+cProduto+"'"
	cQuery +=    " AND DCV.DCV_PRDORI = '"+cPrdOri+"'"
	cQuery +=    " AND DCV.DCV_ITEM = '"+cItem+"'"
	cQuery +=    " AND DCV.DCV_SEQUEN = '"+cSequen+"'"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial('DCU')+"'"	    
	cQuery +=    " AND DCU.DCU_CARGA = '"+cCarga+"'"
	cQuery +=    " AND DCU.DCU_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND DCU.DCU_ROMEMB = ' '"
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	cAliasDCV := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
	If (cAliasDCV)->(!Eof())
		lVolMnt := .T.
	EndIf
	Do While (cAliasDCV)->(!Eof())
		aAdd(aPrdPend,{cProduto,cPedido,cCarga,(cAliasDCV)->DCV_CODVOL})
		(cAliasDCV)->(dbSkip())
	EndDo
	(cAliasDCV)->(dbCloseArea())
	If !lVolMnt
		// Movimentos Pendentes
		cQuery := " SELECT DISTINCT D12.D12_DOC,D12.D12_CARGA"
		cQuery +=   " FROM "+RetSqlName("DCR")+" DCR1"
		cQuery +=  " INNER JOIN "+RetSqlName("DCR")+" DCR2"
		cQuery +=     " ON DCR2.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR1.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR2.DCR_IDORI = DCR1.DCR_IDORI"
		cQuery +=    " AND DCR2.D_E_L_E_T_ = ' '"
		cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
		cQuery +=     " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND DCR2.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND D12.D12_PRODUT = '"+cProduto+"'"
		cQuery +=    " AND D12.D12_PRDORI = '"+cPrdOri+"'"
		cQuery +=    " AND D12.D12_ATUEST = '1'"
		cQuery +=    " AND D12.D12_IDDCF = DCR2.DCR_IDORI"
		cQuery +=    " AND D12.D12_IDMOV = DCR2.DCR_IDMOV"
		cQuery +=    " AND D12.D12_IDOPER = DCR2.DCR_IDOPER"	
		cQuery +=    " AND D12.D12_STATUS <> '0'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR1.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR1.DCR_IDORI = '"+cIdDCF+"'"
		cQuery +=    " AND DCR1.D_E_L_E_T_ = ' '"
		cAliasDCR := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCR,.F.,.T.)
		Do While (cAliasDCR)->(!Eof())
			If (nPos:= aScan(aPrdPend,{|x| x[1]+x[2]+x[3] == cProduto+(cAliasDCR)->(D12_DOC+D12_CARGA)+""})) == 0
				aAdd(aPrdPend,{cProduto,(cAliasDCR)->D12_DOC,(cAliasDCR)->D12_CARGA,""})
			EndIf
			(cAliasDCR)->(dbSkip())
		EndDo	
		(cAliasDCR)->(dbCloseArea())
	EndIf
Return Nil
/*--------------------------------------------------------------------
---VldRomLib
---Valida se algum item do romaneio já encontra-se liberado para faturamento
---amanda.vieira (06/03/2018)
--------------------------------------------------------------------*/
Static Function VldRomLib(cRomaneio)
Local lRet      := .F.
Local cQuery    := " "
Local cAliasDCU := GetNextAlias()
	cQuery := " SELECT DCV_CODVOL" 
	cQuery +=   " FROM "+RetSqlName('DCU')+" DCU"
	cQuery +=  " INNER JOIN "+RetSqlName('DCV')+" DCV"
	cQuery +=     " ON DCV.DCV_FILIAL ='"+xFilial('DCV')+"'"
	cQuery +=    " AND DCV.DCV_CODMNT = DCU_CODMNT"
	cQuery +=    " AND DCV.DCV_CARGA = DCU_CARGA"
	cQuery +=    " AND DCV.DCV_PEDIDO = DCU_PEDIDO"
	cQuery +=    " AND DCV.DCV_CODVOL = DCU_CODVOL"
	cQuery +=    " AND DCV.DCV_STATUS  = '2'"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial('DCU')+"'"
	cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCU,.F.,.T.)
	If (cAliasDCU)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasDCU)->(DbCloseArea())
Return lRet
/*--------------------------------------------------------------------
---VldConfExp
---Valida se existe conferência de expedição em aberto para o pedido 
---amanda.vieira (12/03/2018)
--------------------------------------------------------------------*/
Static Function VldConfExp(cCodMnt,cCarga,cPedido,cVolume)
Local lRet      := .F.
Local cQuery    := " "
Local cAliasQry := " "
	cQuery := " SELECT DCV.DCV_CODVOL"
	cQuery +=   " FROM "+RetSqlName('DCV')+" DCV"
	cQuery +=  " INNER JOIN "+RetSqlName('D02')+" D02"
	cQuery +=     " ON D02.D02_FILIAL = '"+xFilial('D02')+"'"
	cQuery +=    " AND D02.D02_CARGA  = DCV.DCV_CARGA"
	cQuery +=    " AND D02.D02_PEDIDO = DCV.DCV_PEDIDO"
	cQuery +=    " AND D02.D02_PRDORI = DCV.DCV_PRDORI"
	cQuery +=    " AND D02.D02_CODPRO = DCV.DCV_CODPRO"
	cQuery +=    " AND D02.D02_LOTE   = DCV.DCV_LOTE"
	cQuery +=    " AND D02.D02_SUBLOT = DCV.DCV_SUBLOT"
	cQuery +=    " AND D02_STATUS <> '3'"
	cQuery +=    " AND D02.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
	cQuery +=    " AND DCV.DCV_CODMNT = '"+cCodMnt+"'"
	cQuery +=    " AND DCV.DCV_CARGA  = '"+cCarga+"'"
	cQuery +=    " AND DCV.DCV_PEDIDO = '"+cPedido+"'"
	cQuery +=    " AND DCV.DCV_CODVOL = '"+cVolume+"'"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T., 'TOPCONN', TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!EoF())
		lRet := .T.
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet