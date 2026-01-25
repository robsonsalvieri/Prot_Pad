#INCLUDE "WMSV103.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

#DEFINE WMSV10301 "WMSV10301"
#DEFINE WMSV10302 "WMSV10302"
#DEFINE WMSV10303 "WMSV10303"
#DEFINE WMSV10304 "WMSV10304"
#DEFINE WMSV10305 "WMSV10305"
#DEFINE WMSV10306 "WMSV10306"
#DEFINE WMSV10307 "WMSV10307"
#DEFINE WMSV10308 "WMSV10308"
#DEFINE WMSV10309 "WMSV10309"
#DEFINE WMSV10310 "WMSV10310"
#DEFINE WMSV10311 "WMSV10311"
#DEFINE WMSV10312 "WMSV10312"
#DEFINE WMSV10313 "WMSV10313"
#DEFINE WMSV10314 "WMSV10314"
#DEFINE WMSV10315 "WMSV10315"
#DEFINE WMSV10316 "WMSV10316"
#DEFINE WMSV10317 "WMSV10317"
#DEFINE WMSV10318 "WMSV10318"
#DEFINE WMSV10319 "WMSV10319"
#DEFINE WMSV10320 "WMSV10320"
#DEFINE WMSV10321 "WMSV10321"
#DEFINE WMSV10322 "WMSV10322"
#DEFINE WMSV10323 "WMSV10323"
#DEFINE WMSV10324 "WMSV10324"
#DEFINE WMSV10325 "WMSV10325"
#DEFINE WMSV10326 "WMSV10326"
#DEFINE WMSV10327 "WMSV10327"
#DEFINE WMSV10328 "WMSV10328"
#DEFINE WMSV10329 "WMSV10329"
#DEFINE WMSV10330 "WMSV10330"
#DEFINE WMSV10331 "WMSV10331"
#DEFINE WMSV10332 "WMSV10332"
#DEFINE WMSV10333 "WMSV10333"
#DEFINE WMSV10334 "WMSV10334"
#DEFINE WMSV10335 "WMSV10335"
//----------------------------------------------------------
/*/{Protheus.doc} WMSV103 - Embarque de Expedição
Permite que os produtos de um pedido de venda, carga ou
nota fiscal possa ter o registro que o embarque foi efetuado.

@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Function WMSV103()
Local cKey09 := VtDescKey(09)
Local cKey22 := VtDescKey(22)
Local cKey24 := VtDescKey(24)
Local bkey09 := VTSetKey(09)
Local bkey22 := VTSetKey(22)
Local bkey24 := VTSetKey(24)
Local aTela  := {}
Local lRet   := .T.
Local nOpc   := 0
Local lWmsNew := SuperGetMV("MV_WMSNEW",.F.,.F.)

Private cCodOpe   := __cUserID
Private cCarga    := Space(Len(DAK->DAK_COD))
Private cPedido   := Space(Len(DAI->DAI_PEDIDO))
Private cEndereco := Space(Len(SBE->BE_LOCALIZ))
Private cNota     := Space(Len(SC9->C9_NFISCAL))
Private aEmbarque := {}
Private cEndAtu   := Space(Len(SBE->BE_LOCALIZ))
Private cEndOk    := Space(Len(SBE->BE_LOCALIZ))
Private lEmbDir   := .F.
Private lOk       := .F.
Private cVolume   := Space(Len(DCU->DCU_CODVOL))
Private aPedidos  := {} // Carrega pedidos do volume WMSV100VOL
Private cRomaneio := Space(Len(DA3->DA3_PLACA))
Private cVolumes  := ""
Private lFuncVol  := FindFunction('WMSV100VOL')

If lRet
	If Empty(cCodOpe)
		WmsMessage(STR0001,WMSV10301) // Operador nao cadastrado
		lRet := .F.
	EndIf
	If lRet
		aTela := VtSave()
		VTClear()

		If IsInCallStack("WMSV103")
			@ 0,0 VTSay STR0003 // Selecione:
			If lWmsNew
				nOpc := VTaChoice(2,0,5,VTMaxCol(),{STR0004,STR0005,STR0006,STR0063}) // Embarcar Carga // Embarcar Pedido // Embarcar Nota // Embarcar Romaneio
			Else
				nOpc := VTaChoice(2,0,5,VTMaxCol(),{STR0004,STR0005,STR0006}) // Embarcar Carga // Embarcar Pedido // Embarcar Nota
			EndIf
		ElseIf IsInCallStack("WMSV103A")
			nOpc := 1 // Embarcar Carga
		ElseIf IsInCallStack("WMSV103B")
			nOpc := 2 // Embarcar Pedido
		ElseIf IsInCallStack("WMSV103C")
			nOpc := 3 // Embarcar NF
		ElseIf IsInCallStack("WMSV103D")
			nOpc := 4 // Embarcar NF
		EndIf
		VtClearBuffer()

		// Tela de embarque
		If nOpc <> 0
			WMSV1031(nOpc)
		EndIf

		If VtLastKey() == 27
			VtRestore(,,,,aTela)
			lRet := .F.
		EndIf

		// Restaura teclas
		VTSetKey(09,bkey09,cKey09)
		VTSetKey(22,bkey22,cKey22)
		VTSetKey(24,bkey24,cKey24)
		VtRestore(,,,,aTela)
	Else
		VtKeyboard(Chr(20))
	EndIf
EndIf
Return ( lRet )

//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Embarque de Carga
//----------------------------------------------------------
Function WMSV103A()
Return WMSV103()

//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Embarque de Pedido
//----------------------------------------------------------
Function WMSV103B()
Return WMSV103()

//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Embarque de Nota Fiscal
//----------------------------------------------------------
Function WMSV103C()
Return WMSV103()

//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Embarque de Romaneio
//----------------------------------------------------------
Function WMSV103D()
Return WMSV103()
//----------------------------------------------------------
/*/{Protheus.doc} WMSV1031
Tela de Embarque de Expedição

@param   nTipo    Tipo de endereçamento:
                  1 - Carga
                  2 - Pedido
                  3 - NF
                  4 - Romaneio

@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Function WMSV1031(nTipo)
Local aTela  := VTSave()
Local cKey15 := VtDescKey(15)
Local bkey15 := VTSetKey(15)
Local cKey24 := VtDescKey(24)
Local bkey24 := VTSetKey(24)
Local nLin   := 0
Local cMsg   := ""
Local i      := 0
Local lEsc   := .F.
Local lVolume:= .F.
Local dDtIni := CtoD('  /  /  ')
Local cHrIni := ''

	While .T.

		VTSetKey(15,{|| MontaCons(nTipo)}, STR0055) // Ctrl+O - Embarques
		VTSetKey(24,{|| GrvEstorno(nTipo,lVolume)}, STR0056) // Ctrl+X - Estorno

		VTClear()
		cCarga    := Space(Len(DAK->DAK_COD))
		cPedido   := Space(Len(DAI->DAI_PEDIDO))
		cEndereco := Space(Len(SBE->BE_LOCALIZ))
		cNota     := Space(Len(SC9->C9_NFISCAL))
		cEndOk    := Space(Len(SBE->BE_LOCALIZ))
		cEndAtu   := Space(Len(SBE->BE_LOCALIZ))
		cVolume   := Space(Len(DCU->DCU_CODVOL))
		cRomaneio := Space(Len(DA3->DA3_PLACA))
		aEmbarque := {}
		lEsc      := .F.
		aPedidos  := {}

		WMSVTCabec(STR0007, .F., .F., .T.) // Embarque
		If nTipo == 1
			@ 02, 00 VTSay PadR(STR0008, VTMaxCol()) // Carga
			@ 03, 00 VTGet cCarga Valid ValidCarga() .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.) .And. If(lVolume,ValPedido(nTipo,,lVolume),.T.)
			VTRead()

			If VTLastKey() == 27
				Exit
			EndIf
			If !lVolume
				@ 05, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
				@ 06, 00 VTGet cPedido Valid ValPedido(nTipo) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
			EndIf
		ElseIf nTipo == 2
			@ 02, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
			@ 03, 00 VTGet cPedido Valid ValPedido(nTipo) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		ElseIf nTipo == 3
			@ 02, 00 VTSay PadR(STR0010, VTMaxCol()) // Nota
			@ 03, 00 VTGet cNota Valid ValidaNf() .And. ValPedido(nTipo) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		ElseIf nTipo == 4
			lVolume := .T.
			@ 02, 00 VTSay PadR(STR0062, VTMaxCol()) // Romaneio
			@ 03, 00 VTGet cRomaneio Valid VlRomaneio(nTipo,lVolume,@lEsc,.F.,.F.)
		Endif

		VTRead()
		If VTLastKey() == 27
			Exit
		EndIf

		If nTipo < 4

			For i := 1 to Len(aEmbarque)

				// Desconsidera os que já foram embarcados
				If !Empty(aEmbarque[i][2])
					Loop
				EndIf

				cVolume := Space(Len(DCU->DCU_CODVOL))
				lEmbDir := Empty(aEmbarque[i][5])
				cEndOk  := aEmbarque[i][5]
				
				VTClear()
				WMSVTCabec(STR0007, .F., .F., .T.) // Embarque

				nLin := 1
				If Empty(cEndereco) .Or. (!lEmbDir .And. AllTrim(aEmbarque[i][1]) != AllTrim(cEndereco))
					If !lEmbDir
						@ ++nLin, 00 VTSay PadR(STR0011, VTMaxCol()) // Va para o endereco:
						@ ++nLin, 00 VTSay aEmbarque[i][1]
						@ ++nLin, 00 VTSay PadR(STR0012, VTMaxCol()) // Confirme!
						@ ++nLin, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(.F.,nTipo,cEndereco,aEmbarque[i][6])
					Else
						@ ++nLin, 00 VTSay PadR(STR0057, VTMaxCol()) // Informe o endereco:
						@ ++nLin, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(.F.,nTipo,cEndereco,aEmbarque[i][6])
					EndIf
					VTRead()
				Else
					cEndereco := Iif(lEmbDir,cEndereco,aEmbarque[i][1])
					@ ++nLin, 00 VTSay PadR(STR0064, VTMaxCol()) // Endereco
					@ ++nLin, 00 VTSay PadR(cEndereco, VTMaxCol())
				EndIf

				dDtIni := dDataBase
				cHrIni := Time()

				If VTLastKey() == 27
					lEsc := .T.
					Exit
				EndIf

				If lVolume
					@ ++nLin, 00 VTSay PadR(STR0060, VTMaxCol())  // Volume
					@ ++nLin, 00 VTGet cVolume Valid !Empty(cVolume) .And. MensVolume(nTipo,cVolume) .And. WMSV100VOL(3,,,,cVolume)
					VTRead()
					If VTLastKey() == 27
						lEsc := .T.
						Exit
					EndIf
				EndIf

			Next i

			// Caso tenha algum pedido a ser embarcado, pergunta se finaliza
			If !lEsc .And. Len(aPedidos) > 0
				// Chama a gravação 1 vez pois ja está carregado o array de pedidos
				GravaDados(nTipo,cEndOk,dDtIni,cHrIni)
			EndIf

		EndIf

		// Mostra tela somente se houve alguma movimentação
		If !lEsc .And. Len(aPedidos) > 0
			If !ChecaReg(nTipo)
				MntAndamen(nTipo,lVolume) // tela em andamento
			Else
				VTClear()
				WMSVTCabec(STR0007, .F., .F., .T.)// Embarque
				@ 01, 00 VTSay PadR(STR0013, VTMaxCol())// Finalizado
				@ 02, 00 VTSay "--------------------"
				If nTipo == 1
					@ 03, 00 VTSay PadR(STR0014+cCarga, VTMaxCol()) // Carga.:
					@ 04, 00 VTSay "--------------------"
				ElseIf nTipo == 2
					@ 03, 00 VTSay PadR(STR0015+cPedido, VTMaxCol()) // Pedido:
				ElseIf nTipo == 3
					@ 03, 00 VTSay PadR(STR0016+cNota, VTMaxCol()) // Nota:
				EndIf
				WMSVTRodPe()
			EndIf
		EndIf
		If VTLastKey() == 27
			Exit
		EndIf

	EndDo
	// Restaura teclas
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil

//----------------------------------------------------------
/*/{Protheus.doc} ValidCarga
Valida se a carga informada é valida

@return  lRet  Indica se a carga informada é válida
@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function ValidCarga()
Local lRet	:= .T.
	If Empty(cCarga)
		Return .F.
	EndIf

	If lRet
		DAK->(DbSetOrder(1))
		If DAK->(!DbSeek(xFilial("DAK")+cCarga))
			WmsMessage(STR0018,WMSV10302) // Carga inválida!
			lRet := .F.
			VTKeyBoard(Chr(20))
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} ValPedido
Valida se o pedido informado é valido

@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF
@param   lEstorno    Indica se a função foi chamada pelo processo de estorno

@return  lRet        Indica se o pedido informado é válido
@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function ValPedido(nTipo,lEstorno,lVolume)
Local lRet       := .T.
Local lAchou     := .F.
Local cMsg       := ""
Local aPeds      := {}
Local aTela      := VTSave()
Local nPos,i     := 1
Local cQuery     := ''
Local cAliasQry  := ""
Local cCargaVal  := ""
Local cAliasDCF  := ""
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)

Default lEstorno := .F.
Default lVolume  := .F.
	aPedidos := {}
	cVolumes := ""
	// Caso nao informado o pedido, ira verifica se existem pedidos pendentes e mostra em um grid
	If Empty(cPedido)
		If !lEstorno .AND. nTipo == 1 .And. !lVolume
			aPeds := MntOrdInv(lVolume)
			// Monta o grid com os pedidos pendentes de embarque
			If Len(aPeds) > 0
				@ 0,0 VtSay STR0058   // Pedidos
				nPos := VTaBrowse(2,,,,{STR0014,STR0015},aPeds,{10,10}) // Carga # Pedido
				If !Empty(nPos)
					cPedido := aPeds[nPos][2]
				EndIf

				VtRestore(,,,,aTela)
				VtGetRefresh("cPedido")
			EndIf
		EndIf
	EndIf

	// Tratamento de pedido em branco
	If Empty(cPedido) .And. nTipo == 2
		Return .F.
	EndIf

	// Caso pedido informado segue tratamento
	If lRet
		// Verifica se possui bloqueio WMS, impedindo embarque caso serviço e liberação não tenham sido executados
		If lRet := If(lEstorno,.T., ValPedBlq(nTipo,cCarga,cPedido))
			If nTipo == 1 .And. !Empty(cPedido)
				DAI->(DbSetOrder(4))
				If DAI->(!DbSeek(xFilial("DAI")+cPedido+cCarga))
					WmsMessage(STR0021,WMSV10304) // Pedido inválido!
					lRet := .F.
				EndIf
			EndIf

			If lRet
				If nTipo == 2
					// Valida se o pedido está contido em uma carga
					cQuery := "SELECT DCF.DCF_CARGA"
					cQuery +=  " FROM "+RetSqlName('SC9')+" SC9"
					cQuery += " INNER JOIN "+RetSqlName('DCF')+" DCF"
					cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
					cQuery +=   " AND DCF.DCF_ID     = SC9.C9_IDDCF"
					cQuery +=   " AND DCF.DCF_DOCTO  = SC9.C9_PEDIDO"
					cQuery +=   " AND DCF.DCF_CARGA  <> '"+Space(TamSX3("DCF_CARGA")[1])+"'"
					cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
					cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
					cQuery +=   " AND SC9.C9_PEDIDO  = '"+cPedido+"'"
					cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					cAliasDCF := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
					If (cAliasDCF)->(!Eof())
						WmsMessage(WmsFmtMsg(STR0087,{{"[VAR01]",(cAliasDCF)->DCF_CARGA}}),WMSV10305) // Pedido esta contido na carga [VAR01], utilize o menu por carga!
						lRet := .F.
					EndIf
					(cAliasDCF)->(dbCloseArea())
				EndIf

				If lRet
					aEmbarque := {}
					// Carrega o array de embarques, para prever os dados
					// e validar com o que foi informado pelo coletor
					cQuery :=      " SELECT SC9.C9_CARGA,"
					cQuery +=             " SC9.C9_PEDIDO,"
					If nTipo == 1
						cQuery +=         " DAI.DAI_SEQUEN,"
					EndIf
					cQuery +=             " CASE WHEN DCU.DCU_CODVOL IS NULL THEN '"+Space(TamSX3("DCU_CODVOL")[1])+"' ELSE DCU.DCU_CODVOL END DCU_CODVOL,"
					cQuery +=             " D00.D00_CODEND,"
					cQuery +=             " CASE WHEN D00.D00_CODDOC IS NULL THEN SC9.C9_ENDPAD ELSE D00.D00_CODDOC END D00_CODDOC,"
					cQuery +=             " D00.D00_OPEEMB,"
					cQuery +=             " D00.D00_DATEMB,"
					cQuery +=             " D00.D00_HOREMB"
					cQuery +=        " FROM "+RetSqlName("SC9")+" SC9"
					cQuery +=       " INNER JOIN "+RetSqlName("DCF")+" DCF"	 	
					cQuery +=          " ON DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
					cQuery +=         " AND DCF.DCF_ID = SC9.C9_IDDCF"
					cQuery +=         " AND DCF.D_E_L_E_T_ = ' '"
					// Realiza um Left, pois pode ter ou nao um volume
					cQuery +=        " LEFT JOIN "+RetSqlName("DCU")+" DCU"
					cQuery +=          " ON DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
					cQuery +=         " AND DCU.DCU_CARGA = DCF.DCF_CARGA"
					cQuery +=         " AND DCU.DCU_PEDIDO = DCF.DCF_DOCTO"
					If lEstorno
						cQuery +=         " AND EXISTS (SELECT 1"
						cQuery +=                       " FROM "+RetSqlName("D00")+" D00A"
						cQuery +=                      " WHERE D00A.D00_FILIAL = '"+xFilial("D00")+"'"
						cQuery +=                        " AND D00A.D00_CARGA = DCU.DCU_CARGA"
						cQuery +=                        " AND D00A.D00_PEDIDO = DCU.DCU_PEDIDO"
						cQuery +=                        " AND D00A.D00_CODVOL = DCU.DCU_CODVOL"
						cQuery +=                        " AND D00A.D_E_L_E_T_ = ' ')"
					EndIf
					cQuery +=         " AND DCU.D_E_L_E_T_ = ' '"
					// Realiza um Left, pois pode ser um embarque direto
					cQuery +=        " LEFT JOIN "+RetSqlName("D00")+" D00"
					cQuery +=          " ON D00.D00_FILIAL = '"+xFilial("D00")+"'"
					cQuery +=         " AND D00.D00_CARGA = DCF.DCF_CARGA"
					cQuery +=         " AND D00.D00_PEDIDO = DCF.DCF_DOCTO"
					cQuery +=         " AND (DCU.DCU_CODVOL IS NULL OR D00.D00_CODVOL = DCU.DCU_CODVOL)"
					cQuery +=         " AND D00.D_E_L_E_T_ = ' '"
					// Quando por carga (nTipo=1), traz os resultados ordenando
					// os pedidos de forma inversa ao roteiro de entrega
					If nTipo == 1
						cQuery +=   " INNER JOIN "+RetSqlName("DAI")+" DAI"
						cQuery +=      " ON DAI.DAI_FILIAL = '"+xFilial("DAI")+"'"
						cQuery +=     " AND DAI.DAI_COD = SC9.C9_CARGA"
						cQuery +=     " AND DAI.DAI_PEDIDO = SC9.C9_PEDIDO"
						cQuery +=     " AND DAI.D_E_L_E_T_ = ' '"
					EndIf
					cQuery +=       " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
					If nTipo == 1 // Embarque por carga
						cQuery +=     " AND SC9.C9_CARGA = '"+cCarga+"'"
					ElseIf nTipo < 4 // Embarque por pedido ou nota
						cQuery +=     " AND SC9.C9_PEDIDO = '"+cPedido+"'"
					Else
						// Embarque por romaneio/volumes
						If !Empty(cVolumes)
							cQuery += " AND DCU.DCU_CODVOL IN ("+cVolumes+")"
						EndIf
						If !Empty(cRomaneio)
							cQuery +=   " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
						EndIf
					EndIf
					cQuery +=     " AND SC9.D_E_L_E_T_ = ' '"
					cQuery +=   " GROUP BY SC9.C9_CARGA,"
					cQuery +=            " SC9.C9_PEDIDO,"
					cQuery +=            " SC9.C9_ENDPAD,"
					If nTipo == 1
						cQuery +=        " DAI.DAI_SEQUEN,"
					EndIf
					cQuery +=            " DCU.DCU_CODVOL,"
					cQuery +=            " D00.D00_CODEND,"
					cQuery +=            " D00.D00_CODDOC,"
					cQuery +=            " D00.D00_OPEEMB,"
					cQuery +=            " D00.D00_DATEMB,"
					cQuery +=            " D00.D00_HOREMB"
					If nTipo == 1
						cQuery +="ORDER BY DAI.DAI_SEQUEN DESC"
					EndIf
					cQuery := ChangeQuery(cQuery)
					cAliasQry  := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
					If (cAliasQry)->(!Eof())
						Do While (cAliasQry)->(!Eof())
							lAchou  := .T.
							aAdd(aEmbarque,{;
								(cAliasQry)->D00_CODDOC,;
								(cAliasQry)->D00_OPEEMB,;
								(cAliasQry)->D00_DATEMB,;
								(cAliasQry)->D00_HOREMB,;
								(cAliasQry)->D00_CODEND,;
								(cAliasQry)->DCU_CODVOL,;
								(cAliasQry)->C9_PEDIDO})
								
							If lWmsNew .And. !Empty((cAliasQry)->DCU_CODVOL)
								cVolumes += "'"+(cAliasQry)->DCU_CODVOL+"',"
							EndIf
							(cAliasQry)->(DbSkip())
						EndDo
						(cAliasQry)->(DbCloseArea())
						cVolumes := SubsTr(cVolumes,1,Len(cVolumes)-1)
						lVolume := !Empty(cVolumes)
						lAllEmbarc := .T.
						// Validação se ainda existe algo nao embarcado
						For i := 1 To Len(aEmbarque)
							If lEstorno
								lRet := .F.
								// Se encontrar alguma com embarque realizado, deixa estornar
								If !Empty(aEmbarque[i][2]) // Código do operador que realizou o embarque
									lRet := .T.
									Exit
								EndIf
							Else
								If Empty(aEmbarque[i][2]) // Código do operador que realizou o embarque
									// Considera que falta embarcar alguma coisa quando o código do operador estiver vazio
									lAllEmbarc := .F.
									// Se foi realizado apenas o endereçamento e falta a transferencia,
									// porém continua para verificar se algum pode ser embarcado
									If !Empty(aEmbarque[i][5]) .And. Empty(aEmbarque[i][1])
										cMsg := WmsFmtMsg(STR0065,{{"[VAR01]",aEmbarque[i][7]}}) // Existe embarques com transferencia pendente do pedido: [VAR01]
										lRet := .F.
									EndIf
								EndIf
								If !lVolume
									// Carrega o array de pedidos quando nao utiliza volume
									nPos := aScan(aPedidos,{|x| x[2] == aEmbarque[i][7] })
									If nPos == 0
										aAdd(aPedidos,{cCarga,aEmbarque[i][7],""})
									EndIf
								EndIf
							EndIf
						Next i
						If lRet .And. !lEstorno .And. lAllEmbarc
							cMsg := STR0024 // Ja embarcado!
							lRet := .F.
						ElseIf !lRet .And. lEstorno
							// Caso nenhum tenha sido embarcado, não deixa estornar
							WmsMessage(STR0025,WMSV10306) // Nao embarcado!
						EndIf
						If !Empty(cMsg)
							WmsMessage(cMsg,WMSV10307)
						EndIf
					Else
						If nTipo == 1
							WmsMessage(WmsFmtMsg(STR0074,{{"[VAR01]",cCarga}}),WMSV10303) // Embarque para a carga [VAR01] nao encontrada!
						ElseIf nTipo == 2
							WmsMessage(WmsFmtMsg(STR0075,{{"[VAR01]",cPedido}}),WMSV10314) // Embarque para o pedido [VAR01] nao encontrado!
						ElseIf nTipo == 3
							WmsMessage(WmsFmtMsg(STR0076,{{"[VAR01]",cNota}}),WMSV10334) // Embarque para a nota [VAR01] nao encontrado!
						Else
							WmsMessage(WmsFmtMsg(STR0077,{{"[VAR01]",cRomaneio}}),WMSV10335) // Embarque para o romaneio [VAR01] nao encontrado!
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} ValidEnder
Valida se o endereço informado pode receber o documento

@param   lEstorno    Indica se a função foi chamada pelo processo de estorno
@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF
@param   cCodEnd     Código do endereço

@return  lRet        Indica se o endereço informado pode receber o documento
@author  Evaldo Cevinscki Jr.
@version P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function ValidEnder(lEstorno,nTipo,cCodEnd,cVol)
Local lRet  := .T.
Local cAliasQry := GetNextAlias()

Default cVol := Space(Len(DCU->DCU_CODVOL))

	If Empty(cCodEnd)
		Return .F.
	EndIf

	SBE->(DbSetOrder(9))
	If SBE->(DbSeek(xFilial('SBE')+cCodEnd))
		DC8->(DbSetOrder(1))
		DC8->(DbSeek(xFilial('DC8')+SBE->BE_ESTFIS))
		If DC8->DC8_TPESTR != '5'
			WmsMessage(STR0066,WMSV10308) // Informe um endereco de estrutura fisica do tipo DOCA!
			lRet := .F.
		EndIf
	Else
		WmsMessage(STR0067,WMSV10309) // Endereco invalido!
		lRet := .F.
	EndIf

	If lRet
		If (nPos := aScan(aEmbarque, {|x| x[1] == cEndereco})) == 0
			WmsMessage(STR0026,WMSV10310) // Local diferente do previsto!
			VtKeyboard(Chr(20))
			Return .F.
		EndIf

		cQuery :=       "SELECT D00.D00_CODDOC,"
		cQuery +=             " D00.D00_OPEEMB"
		cQuery +=        " FROM "+RetSqlName('D00')+" D00"
		cQuery +=       " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
		If nTipo == 1
			cQuery +=     " AND D00.D00_CARGA  = '"+cCarga+"'"
			If !Empty(cPedido)
				cQuery += " AND D00.D00_PEDIDO = '"+cPedido+"'"
			EndIf
		ElseIf nTipo < 4
			cQuery +=     " AND D00.D00_PEDIDO = '"+cPedido+"'"
		EndIf
		If !Empty(cVol)
			cQuery +=     " AND D00.D00_CODVOL = '"+cVol+"'"
		EndIf
		cQuery +=         " AND D00.D00_CODDOC = '"+cEndereco+"'"
		cQuery +=         " AND D00.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

		lAchou := .F.
		Do While (cAliasQry)->(!Eof())
			lAchou := .T.
			If !lEstorno .And. !Empty((cAliasQry)->D00_OPEEMB)
				WmsMessage(STR0024,WMSV10311) // Ja Embarcado!
				lRet := .F.
				Exit
			Else
				If lEstorno .And. Empty((cAliasQry)->D00_OPEEMB)
					WmsMessage(STR0027,WMSV10312) // Estorno nao permitido, nao esta embarcado!
					lRet := .F.
					Exit
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

		If lRet .And. !lAchou .And. lEstorno
			WmsMessage(STR0028,WMSV10313) // Nao ha embarque do Pedido/Endereco!
			lRet := .F.
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} MontaCons
Monta consulta de endereços do embarque do documento

@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF

@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12 - revisão 02/10/14
/*/
//----------------------------------------------------------
Static Function MontaCons(nTipo)
Local cKey15    := VtDescKey(15)
Local cKey24    := VtDescKey(24)
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local aTela     := VTSave()
Local aEnds     := {}
Local nPos      := 1
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local lVolume := .F.

	WMSVTCabec(STR0068, .F., .F., .T.) // Consulta Embarques
	If nTipo == 1 .And. Empty(cCarga)
		@ 02, 00 VTSay PadR(STR0008, VTMaxCol())	 // Carga
		@ 03, 00 VTGet cCarga Valid ValidCarga() .And. ValPedido(nTipo,.t.) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.)
		VTRead()
	ElseIf nTipo == 2 .And. Empty(cPedido)
		@ 02, 00 VTSay PadR(STR0009, VTMaxCol())	 // Pedido
		@ 03, 00 VTGet cPedido Valid ValPedido(nTipo,.t.) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 3 .And. Empty(cNota)
		@ 02, 00 VTSay PadR(STR0010, VTMaxCol())	 // Nota
		@ 03, 00 VTGet cNota Valid ValidaNf() .And. ValPedido(nTipo,.t.) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 4 .And. Empty(cRomaneio)
		lVolume := .T.
		@ 02, 00 VTSay PadR(STR0062, VTMaxCol()) // Romaneio
		@ 03, 00 VTGet cRomaneio Valid VlRomaneio(nTipo,lVolume,.T.,.T.,.F.)
		VTRead()
	Endif

	If VTLastKey() == 27
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0055)
		VTSetKey(24,bKey24, STR0056)
		Return
	EndIf

	If nTipo == 1 .And. Empty(cCarga)
		WmsMessage(STR0069,WMSV10315) // Informe uma carga para consultar.
		VtKeyboard(Chr(20))
		Return Nil
	ElseIf nTipo == 2 .And. Empty(cPedido)
		WmsMessage(STR0070,WMSV10316) // Informe um pedido para consultar.
		VtKeyboard(Chr(20))
		Return Nil
	ElseIf nTipo == 3 .And. Empty(cNota)
		WmsMessage(STR0071,WMSV10317) // Informe uma nota para consultar.
		VtKeyboard(Chr(20))
		Return Nil
	ElseIf nTipo == 4 .And. Empty(cRomaneio)
		WmsMessage(STR0072,WMSV10318) // Informe um romaneio para consultar.
		VtKeyboard(Chr(20))
		Return Nil
	EndIf

	cQuery +=      " SELECT D00.D00_PEDIDO,"
	cQuery +=             " D00.D00_CODDOC,"
	cQuery +=             " D00.D00_OPEEMB,"
	cQuery +=             " D00.D00_DATEMB,"
	cQuery +=             " D00.D00_HOREMB,"
	cQuery +=             " D00.D00_CODVOL"
	cQuery +=        " FROM "+RetSqlName("D00")+" D00"
	cQuery +=       " WHERE D00.D00_FILIAL = '"+xFilial("D00")+"'"
	If Empty(cVolume)
		If nTipo == 1 .And. !Empty(cCarga)
			cQuery += " AND D00.D00_CARGA  = '"+cCarga+"'"
		ElseIf !Empty(cPedido)
			cQuery += " AND D00.D00_PEDIDO = '"+cPedido+"'"
		EndIf
	Else
		cQuery +=     " AND D00.D00_CODVOL = '"+cVolume+"'"
	EndIf
	// filtra volumes do Romaneio
	If !Empty(cVolumes)
		cQuery +=     " AND D00.D00_CODVOL IN ("+cVolumes+")"
	EndIf
	cQuery +=         " AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		AAdd(aEnds,{(cAliasQry)->D00_PEDIDO,(cAliasQry)->D00_CODDOC,If(Empty((cAliasQry)->D00_OPEEMB),"*",(cAliasQry)->D00_OPEEMB),(cAliasQry)->D00_DATEMB,(cAliasQry)->D00_HOREMB,(cAliasQry)->D00_CODVOL})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	If Len(aEnds) > 0
		VTClear()
		If nTipo == 1
			@ 0,0 VtSay STR0032   // Embarque Pedido
			@ 1,0 VtSay STR0033+cCarga+STR0034+cPedido // C.:"###" P.:
		ElseIf nTipo == 2
			@ 0,0 VtSay STR0032   // Embarque Pedido
			@ 1,0 VtSay STR0015+cPedido // Pedido:
		ElseIf nTipo == 3
			@ 0,0 VtSay STR0035   // Embarque Nota
			@ 1,0 VtSay STR0016+cNota	 // Nota:
		ElseIf nTipo == 4
			@ 0,0 VtSay STR0073  // Embarque Romaneio
			@ 1,0 VtSay STR0062+": "+cRomaneio // Romaneio:
		EndIf
		nPos := VTaBrowse(2,,,,{STR0009,STR0036,STR0037,STR0038,STR0039,STR0060},aEnds,{6,15,6,10,5,10}) // Pedido # Doca # Operador # Data # Hora # Volume
	Else
		If nTipo == 1
			WmsMessage(WmsFmtMsg(STR0074,{{"[VAR01]",cCarga}}),WMSV10319) // Embarque para a carga [VAR01] nao encontrada!
		ElseIf nTipo == 2
			WmsMessage(WmsFmtMsg(STR0075,{{"[VAR01]",cPedido}}),WMSV10320) // Embarque para o pedido [VAR01] nao encontrado!
		ElseIf nTipo == 3
			WmsMessage(WmsFmtMsg(STR0076,{{"[VAR01]",cNota}}),WMSV10321) // Embarque para a nota [VAR01] nao encontrado!
		Else
			WmsMessage(WmsFmtMsg(STR0077,{{"[VAR01]",cRomaneio}}),WMSV10322) // Embarque para o romaneio [VAR01] nao encontrado!
		EndIf
		VtKeyboard(Chr(20))
	EndIf

	// Restaura Tecla
	VtRestore(,,,,aTela)
	VTSetKey(15,bKey15, STR0055)
	VTSetKey(24,bKey24, STR0056)
Return .T.

//----------------------------------------------------------
/*/{Protheus.doc} MntOrdInv
Monta um array dos pedidos em ordem inversa ao roteiro de entrega

@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF

@return  aPeds    Array com os pedidos em ordem inversa ao roteiro de entrega
@author  Tiago F. da Silva
@version	P11
@since   15/01/14
/*/
//----------------------------------------------------------
Static Function MntOrdInv(lVolume)
Local aPeds	:= {}
Local cAliasQry := GetNextAlias()
	If Empty(cRomaneio)
		cQuery :=    "SELECT DISTINCT DAI_COD,"
		cQuery +=                   " DAI_PEDIDO,"
		cQuery +=                   " DAI_SEQUEN"
		cQuery +=     " FROM "+RetSqlName('DAI')+" DAI"
		cQuery +=    " INNER JOIN "+RetSqlName('SC9')+" SC9"
		cQuery +=       " ON SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
		cQuery +=      " AND SC9.C9_PEDIDO = DAI.DAI_PEDIDO"
		cQuery +=      " AND SC9.C9_CARGA = DAI.DAI_COD"
		cQuery +=      " AND SC9.D_E_L_E_T_= ' '"
		cQuery +=    " INNER JOIN "+RetSqlName('DCF')+" DCF"
		cQuery +=       " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=      " AND DCF.DCF_ID = SC9.C9_IDDCF"
		cQuery +=      " AND DCF.DCF_CARGA = SC9.C9_CARGA"
		cQuery +=      " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=    " WHERE DAI.DAI_FILIAL = '"+xFilial('DAI')+"'"
		cQuery +=      " AND DAI.DAI_COD = '"+cCarga+"'"
		If !lVolume
			cQuery	+= " AND NOT EXISTS (SELECT 1"
			cQuery	+=                   " FROM " +RetSqlName('D00')+" D00"
			cQuery	+=                  " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
			cQuery	+=                    " AND D00.D00_CARGA  = DAI_COD"
			cQuery	+=                    " AND D00.D00_PEDIDO = DAI_PEDIDO"
			cQuery +=                     " AND D00.D00_OPEEMB <> ' '"
			cQuery	+=                    " AND D00.D_E_L_E_T_ = ' ') "
		EndIf
		cQuery	+=     " AND DAI.D_E_L_E_T_ = ' ' "
		cQuery	+=   " ORDER BY DAI_SEQUEN,"
		cQuery +=             " DAI_COD,"
		cQuery +=             " DAI_PEDIDO"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		Do While (cAliasQry)->(!Eof())
			If lVolume
				DCU->(dbSetOrder(2))
				If DCU->(dbSeek(xFilial("DCU")+(cAliasQry)->DAI_COD + (cAliasQry)->DAI_PEDIDO))
					While !Eof() .And. DCU->(DCU_FILIAL+DCU_CARGA+DCU_PEDIDO) == xFilial("DCU")+(cAliasQry)->DAI_COD + (cAliasQry)->DAI_PEDIDO
						aAdd(aPeds, {(cAliasQry)->DAI_COD, (cAliasQry)->DAI_PEDIDO, DCU->DCU_CODVOL})
						DCU->(dbSkip())
					End
				EndIf
			Else
				aAdd(aPeds, {(cAliasQry)->DAI_COD, (cAliasQry)->DAI_PEDIDO})
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Else
		cQuery := "SELECT DCU_CARGA,"
		cQuery +=       " DCU_PEDIDO,"
		cQuery +=       " DCU_CODVOL"
		cQuery +=  " FROM "+RetSqlName('DCU')+" DCU"
		cQuery +=  " LEFT JOIN "+RetSqlName('DAI')+" DAI"
		cQuery +=    " ON DAI.DAI_FILIAL = '"+xFilial('DAI')+"'"
		cQuery +=   " AND DAI.D_E_L_E_T_ = ' '"
		cQuery +=   " AND DAI.DAI_COD =  DCU.DCU_CARGA"
		cQuery += " WHERE DCU.DCU_FILIAL = '"+xFilial('DCU')+"'"
		cQuery +=   " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
		cQuery +=   " AND DCU.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY DAI.DAI_SEQUEN DESC"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		Do While (cAliasQry)->(!Eof())
			aAdd(aPeds, {(cAliasQry)->DCU_CARGA, (cAliasQry)->DCU_PEDIDO, DCU->DCU_CODVOL})
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
Return aPeds
//----------------------------------------------------------
/*/{Protheus.doc} GrvEstorno
Realiza o estorno do embarque

@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF

@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function GrvEstorno(nTipo,lVolume)
Local cKey15    := VtDescKey(15)
Local cKey24    := VtDescKey(24)
Local bkey15    := VTSetKey(15)
Local bkey24    := VTSetKey(24)
Local aTela     := VTSave()
Local aEnds     := {}
Local nPos      := 1
Local cCodEnd   := ""
Local nLin      := 0
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
Local cPedidos  := ''

Default lVolume := .F.

	// Não permite estornar quando o item já está faturado.
	If nTipo == 3
		Return Nil
	EndIf

	cEndOld   := cEndereco
	cEstVol   := Space(Len(DCU->DCU_CODVOL))

	VTClear()
	WMSVTCabec(STR0040, .F., .F., .T.)   // Estorna Embarque
	nLin := 1
	If nTipo == 1 .And. Empty(cCarga)
		@ ++nLIn, 00 VTSay PadR(STR0008, VTMaxCol()) // Carga
		@ ++nLIn, 00 VTGet cCarga Valid ValidCarga() .And. ValPedido(nTipo,.t.) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.)
		VTRead()
	ElseIf nTipo == 2 .And. Empty(cPedido)
		@ ++nLIn, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
		@ ++nLIn, 00 VTGet cPedido Valid ValPedido(nTipo,.t.) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 3 .And. Empty(cNota)
		@ ++nLIn, 00 VTSay PadR(STR0010, VTMaxCol()) // Nota
		@ ++nLIn, 00 VTGet cNota Valid ValidaNf() .And. ValPedido(nTipo,.t.) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 4 .And. Empty(cRomaneio)
		lVolume := .T.
		@ ++nLIn, 00 VTSay PadR(STR0062, VTMaxCol()) // Romaneio
		@ ++nLIn, 00 VTGet cRomaneio Valid VlRomaneio(nTipo,lVolume,.F.,.F.,.T.,@aEnds)
		VTRead()
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0055)
		VTSetKey(24,bKey24, STR0056)
		cEndereco := cEndOld
		Return Nil
	EndIf
	If lVolume
		nLin := 1
		If Len(aEnds) > 0
			@ 0,0 VtSay PadR(STR0055, VTMaxCol()) // Embarques
			nPos := VTaBrowse(2,,,,{STR0062,STR0060},aEnds,{15,10}) // Endereco # Volume
			If !Empty(nPos)
				cEstVol := aEnds[nPos][2]
			EndIf
		Else
			@ ++nLin, 00 VTSay PadR(STR0060+": ", VTMaxCol())	  // Volume
			@ ++nLin, 00 VTGet cEstVol Valid If(lFuncVol,WMSV100VOL(3,,,,cEstVol),.T.)
			VTRead()
		EndIf
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0055)
		VTSetKey(24,bKey24, STR0056)
		cEndereco := cEndOld
		Return Nil
	Else
		// Valida se pode prosseguir com o estorno, impedindo caso o item esteja faturado.
		If !VldFatEst(nTipo,lVolume)
			WmsMessage(STR0088,WMSV10331) // O item nao pode ser estornado, pois esta faturado!
			VtRestore(,,,,aTela)
			// Restaura Tecla
			VTSetKey(15,bKey15, STR0055)
			VTSetKey(24,bKey24, STR0056)
			cEndereco := cEndOld
			Return Nil
		EndIf
	EndIf

	VTClear()
	nLin := 1
	WMSVTCabec(STR0040, .F., .F., .T.) // Estorna Embarque
	If nTipo == 1
		@ ++nLin, 00 VTSay PadR(STR0014+cCarga, VTMaxCol())	 // Carga.:
	ElseIf nTipo == 2
		@ ++nLin, 00 VTSay PadR(STR0015+cPedido, VTMaxCol())  // Pedido:
	ElseIf nTipo == 3
		@ ++nLin, 00 VTSay PadR(STR0016+cNota, VTMaxCol())  // Nota:
	EndIf

	If !Empty(cEstVol)
		@ ++nLin, 00 VTSay PadR(STR0060+": "+cEstVol, VTMaxCol())  // Volume
	EndIf
	If Empty(cEndereco)
		@ ++nLin, 00 VTSay PadR(STR0041, VTMaxCol())		 // Endereco Destino
		@ ++nLin, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(.T.,nTipo,cEndereco,cEstVol)
		VTRead()
		// Caso o endereço já tenha sido informado, apenas valida de existe embarque para ser estornado
	ElseIf !ValidEnder(.T.,nTipo,cEndereco,cEstVol)
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0055)
		VTSetKey(24,bKey24, STR0056)
		cEndereco := cEndOld
		Return Nil
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0055)
		VTSetKey(24,bKey24, STR0056)
		cEndereco := cEndOld
		Return Nil
	EndIf
	If nTipo == 1
		cMsg	:= WmsFmtMsg(STR0042,{{"[VAR01]",AllTrim(cCarga)},{"[VAR02]",IIf(Empty(cEstVol),""," "+STR0060+": "+AllTrim(cEstVol))},{"[VAR03]",AllTrim(cEndereco)}}) // Confirma o estorno do embarque da Carga: [VAR01] [VAR02] p/ endereço [VAR03]?
	ElseIf nTipo == 2
		cMsg	:= WmsFmtMsg(STR0045,{{"[VAR01]",AllTrim(cPedido)},{"[VAR02]",AllTrim(cEndereco)}}) // Confirma o estorno do embarque do Pedido: [VAR01] p/ endereço: [VAR02]?
	ElseIf nTipo == 3
		cMsg	:= WmsFmtMsg(STR0046,{{"[VAR01]",AllTrim(cNota)},{"[VAR02]",AllTrim(cEndereco)}})   // Confirma o estorno do embarque da Nota: [VAR01] p/ endereço: [VAR02]?
	ElseIf nTipo == 4
		cMsg	:= WmsFmtMsg(STR0078,{{"[VAR01]",AllTrim(cEstVol)},{"[VAR02]",AllTrim(cEndereco)}}) // Confirma o estorno do embarque do Volume: [VAR01] p/ endereço: [VAR02]?
	EndIf

	VTClear()
	WMSVTCabec(STR0047, .F., .F., .T.) // Atenção
	If VtYesNo(AllTrim(cMsg),STR0047) // Atenção
		// query para filtrar pelo codigo do volume quando for informando, fazendo um While para deletar todos os pedidos do volume
		cQuery :=           "SELECT D00.D00_PEDIDO,"
		cQuery +=                 " D00.D00_CODEND,"
		cQuery +=                 " D00.D00_OPEEND,"
		cQuery +=                 " D00.D00_DATEND,"
		cQuery +=                 " D00.D00_HOREND,"
		cQuery +=                 " D00.D00_CODVOL,"
		cQuery +=                 " D00.R_E_C_N_O_ RECNOD00"
		cQuery +=            " FROM "+RetSqlName('D00')+" D00"
		cQuery +=           " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
		If Empty(cEstVol)
			If nTipo == 1
				cQuery +=     " AND D00.D00_CARGA  = '"+cCarga+"'"
			Else
				If !Empty(cCarga)
					cQuery += " AND D00.D00_CARGA  = '"+cCarga+"'"
				EndIf
				cQuery +=     " AND D00.D00_PEDIDO = '"+cPedido+"'"
			EndIf
		Else
			cQuery +=         " AND D00.D00_CODVOL = '"+cEstVol+"'"
		EndIf
		cQuery +=             " AND D00.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			Begin Transaction
				Do While (cAliasQry)->(!Eof())
					D00->(dbGoTo((cAliasQry)->RECNOD00))
					cPedidos += If(Empty(cPedidos),'',', ') + D00->D00_PEDIDO
					If D00->D00_TIPEMB == "1"
						RecLock("D00",.F.)
						D00->(DbDelete())
						D00->(MsUnlock())
					Else
						RecLock("D00",.F.)
						D00->D00_OPEEMB := ""
						D00->D00_DATEMB := CtoD("  /  /  ")
						D00->D00_HOREMB := ""
						D00->D00_DTEMBF := CtoD("  /  /  ")
						D00->D00_HREMBF := ""
						D00->(MsUnlock())
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
				(cAliasQry)->(DbCloseArea())
			End Transaction
		EndIf
		If lVolume
			WmsMessage(WmsFmtMsg(STR0079,{{"[VAR01]",cEstVol},{"[VAR02]",cPedidos}}),WMSV10323) // Estornado o embarque do volume: [VAR01] com os Pedidos: [VAR02]
			VtKeyboard(Chr(20))
		EndIf
	EndIf

	aEmbarque := {}

	VtRestore(,,,,aTela)
	cEndereco := cEndOld
	cCarga    := Space(Len(DAK->DAK_COD))
	cPedido   := Space(Len(DAI->DAI_PEDIDO))
	// Restaura Tecla
	VTSetKey(15,bKey15, STR0055)
	VTSetKey(24,bKey24, STR0056)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} GravaDados
Gravação das informações do embarque na tabela D00

@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF
@param   cCodEnd     Código do endereço

@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function GravaDados(nTipo,cCodEnd,dDtIni,cHrIni)
Local aTela := VTSave()
Local cMsg  := ""
Local i
	If nTipo == 1
		cMsg	:= WmsFmtMsg(STR0048,{{"[VAR01]",AllTrim(cCarga)},{"[VAR02]",AllTrim(cEndereco)}})  // Confirma o embarque da Carga: [VAR01] do endereço: [VAR02]?
	ElseIf nTipo == 2
		cMsg	:= WmsFmtMsg(STR0050,{{"[VAR01]",AllTrim(cPedido)},{"[VAR02]",AllTrim(cEndereco)}}) // Confirma o embarque do Pedido: [VAR01] do endereço: [VAR02]?
	ElseIf nTipo == 3
		cMsg	:= WmsFmtMsg(STR0051,{{"[VAR01]",AllTrim(cNota)},{"[VAR02]",AllTrim(cEndereco)}})   // Confirma o embarque da Nota:  [VAR01] do endereço: [VAR02]?
	ElseIf nTipo == 4
		cMsg	:= WmsFmtMsg(STR0080,{{"[VAR01]",AllTrim(cEndereco)}}) // Confirma o embarque do(s) volume(s) do Endereço: [VAR01]
	EndIf
	If Len(aPedidos) == 0
		aAdd(aPedidos,{cCarga,cPedido,cVolume})
	EndIf
	VTClear()
	WMSVTCabec(STR0047, .F., .F., .T.) // Atenção
	If VtYesNo(AllTrim(cMsg),STR0047) // Atenção
		Begin Transaction
			For i:= 1 to Len(aPedidos)
				D00->(DbSetOrder(1))
				If D00->(DbSeek(xFilial("D00")+aPedidos[i][1]+aPedidos[i][2]+cCodEnd+aPedidos[i][3]))
					RecLock("D00",.F.)
					D00->D00_OPEEMB := cCodOpe
					D00->D00_DATEMB := dDtIni
					D00->D00_HOREMB := cHrIni
					D00->D00_DTEMBF := dDataBase
					D00->D00_HREMBF := Time()
					D00->(MsUnlock())
				Else
					RecLock("D00",.T.)
					D00->D00_FILIAL := xFilial("D00")
					D00->D00_CARGA  := aPedidos[i][1] // Carga
					D00->D00_PEDIDO := aPedidos[i][2] // Pedido
					D00->D00_CODDOC := cEndereco
					D00->D00_OPEEMB := cCodOpe
					D00->D00_DATEMB := dDtIni
					D00->D00_HOREMB := cHrIni
					D00->D00_TIPEMB := "1"
					D00->D00_CODVOL := aPedidos[i][3]
					D00->D00_DTEMBF := dDataBase
					D00->D00_HREMBF := Time()
					D00->(MsUnlock())
				EndIf
			Next i
		End Transaction
	EndIf
	If VTLastKey() == 27
		Return Nil
	EndIf
	VtRestore(,,,,aTela)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} ValidaNf
Valida informações da nota fiscal

@return  lRet  Indica se a nota fiscal informada é válida
@author  Evaldo Cevinscki Jr.
@version	P11
@since   18/07/12
/*/
//----------------------------------------------------------
Static Function ValidaNf()
Local lRet	    := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

	If Empty(cNota)
		Return .F.
	EndIf

	cQuery := "SELECT DCF.DCF_CARGA,"
	cQuery +=       " SC9.C9_PEDIDO"
	cQuery +=  " FROM " +RetSqlName('SC9') + " SC9"
	cQuery += " INNER JOIN "+RetSqlName('DCF')+" DCF"
	cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_ID     = SC9.C9_IDDCF"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=   " AND SC9.C9_NFISCAL = '"+cNota+"'"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		cCarga  := (cAliasQry)->DCF_CARGA
		cPedido := (cAliasQry)->C9_PEDIDO
	Else
		WmsMessage(STR0053,WMSV10324) // Nota nao encontrada!
		lRet := .F.
		VTKeyBoard(Chr(20))
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ChecaReg
Checa se ainda existe algum registro não embarcado
@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF
                     4 - Volume
@return  lRet        Indica se existe registro que ainda não foi embarcado
@author  Evaldo Cevinscki Jr.
@version	P11
@since   04/10/12
/*/
//----------------------------------------------------------
Static Function ChecaReg(nTipo)
Local lRet      := .T.
Local cQuery    := ""
Local nI        := 0
Local cAliasQry := ""
Local aVols     := {}

	If !Empty(cVolumes)
		// Caso utilize volumes, verifica se todos já foram embarcados,
		// intependente do parâmetro nTipo
		aVols := Separa(cVolumes,",")
		For nI := 1 To Len(aVols)
			cQuery := " SELECT 1"
			cQuery +=   " FROM "+RetSqlName("D00")
			cQuery +=  " WHERE D00_FILIAL = '"+xFilial("D00")+"'"
			cQuery +=    " AND D00_CODVOL = "+aVols[nI]
			cQuery +=    " AND D00_OPEEMB <> ' '"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(Eof())
				lRet := .F.
				Exit
			EndIf
			(cAliasQry)->(dbCloseArea())
		Next nI
	Else
		cQuery :=      "SELECT SC9.C9_PEDIDO,"
		cQuery +=            " D00.D00_PEDIDO,"
		cQuery +=            " D00.D00_OPEEMB"
		cQuery +=       " FROM "+RetSqlName("SC9")+" SC9"
		cQuery +=      " INNER JOIN "+RetSqlName('DCF')+" DCF"
		cQuery +=         " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=        " AND DCF.DCF_ID     = SC9.C9_IDDCF"
		cQuery +=        " AND DCF.D_E_L_E_T_ = ' '"
		cQuery +=       " LEFT JOIN "+RetSqlName("D00")+" D00"
		cQuery +=         " ON D00.D00_FILIAL = '"+xFilial("D00")+"'"
		cQuery +=        " AND D00.D00_CARGA  = DCF.DCF_CARGA"
		cQuery +=        " AND D00.D00_PEDIDO = DCF.DCF_DOCTO"
		cQuery +=        " AND D00.D_E_L_E_T_ = ' '"
		cQuery +=      " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		If nTipo == 1 .Or. (nTipo == 3 .And. !Empty(cCarga))
			cQuery +=    " AND SC9.C9_CARGA = '"+cCarga+"'"
		EndIf
		cQuery +=        " AND SC9.C9_PEDIDO = '"+cPedido+"'"
		cQuery +=        " AND SC9.D_E_L_E_T_ = ' '"
		cQuery +=      " GROUP BY SC9.C9_PEDIDO,"
		cQuery +=               " D00.D00_PEDIDO,"
		cQuery +=               " D00.D00_OPEEMB"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		Do While (cAliasQry)->(!Eof())
			// Caso ainda tenha algum que nao foi embardo
			If Empty((cAliasQry)->D00_OPEEMB)
				lRet := .F.
				Exit
			EndIf
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} MntAndamen
Apresenta tela de embarque em andamento

@param   nTipo       Tipo de endereçamento:
                     1 - Carga
                     2 - Pedido
                     3 - NF

@author  Evaldo Cevinscki Jr.
@version	P11
@since   04/10/12
/*/
//----------------------------------------------------------
Static Function MntAndamen(nTipo,lVolume)
	VTClear()
	WMSVTCabec(STR0007, .F., .F., .T.)       // Embarque
	@ 01, 00 VTSay PadR(STR0054, VTMaxCol())// Em andamento!
	@ 02, 00 VTSay "--------------------"
	If nTipo == 1
		@ 03, 00 VTSay PadR(STR0014+cCarga, VTMaxCol())	// Carga.:
		@ 04, 00 VTSay "--------------------"
	ElseIf nTipo == 2
		@ 03, 00 VTSay PadR(STR0015+cPedido, VTMaxCol()) // Pedido:
	ElseIf nTipo == 3
		@ 03, 00 VTSay PadR(STR0016+cNota, VTMaxCol())   // Nota:
	ElseIf nTipo == 4
		@ 03, 00 VTSay PadR(STR0062+": "+cRomaneio, VTMaxCol()) // Romaneio:
	EndIf
	If lVolume .And. !Empty(cVolume)
		@ 05, 00 VTSay PadR(STR0060+": "+cVolume, VTMaxCol()) // Volume:
	EndIf
	WMSVTRodPe()
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} MensVolume
Mensagem de validação do volume informado
@since 09/12/2014
@version 1.0
@return False
/*/
//----------------------------------------------------------
Static Function MensVolume(nTipo,cVolAtu)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

Default cVolAtu := ""

	If AScan( aPedidos, { |x| x[3] == cVolAtu} ) > 0
		WmsMessage(WmsFmtMsg(STR0081,{{"[VAR01]",cVolume}}),WMSV10333) // Volume [VAR01] ja embarcado
		lRet := .F.
	EndIf
	If lRet .And. AScan( aEmbarque, { |x| x[6] == cVolAtu} ) == 0
		WmsMessage(STR0061,WMSV10326) // Volume diferente do previsto!
		lRet := .F.
	EndIf
	If lRet
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName('D00')+" D00"
		cQuery += " WHERE D00_FILIAL = '"+xFilial('D00')+"'"
		cQuery +=   " AND D00_CODVOL = '"+cVolume+"'"
		cQuery +=   " AND D00_OPEEMB <> ' '"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			WmsMessage(WmsFmtMsg(STR0081,{{"[VAR01]",cVolume}}),WMSV10325) // Volume [VAR01] ja embarcado
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	If lRet .And. nTipo == 4
		DCU->(dbSetOrder(1))
		If DCU->(DbSeek(xFilial("DCU")+cVolAtu))
			cCarga  := DCU->DCU_CARGA
			cPedido := DCU->DCU_PEDIDO
		EndIf
	EndIf
	If !lRet
		VtKeyboard(Chr(20))
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ValPedBlq
Validação se o pedido esta bloqueado
@since 26/02/2015
@version 1.0
@return False
/*/
//----------------------------------------------------------
Static Function ValPedBlq(nTipo,cCarg,cPed)
Local lRet := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()
	cQuery := "SELECT SC9.C9_BLEST,"
	cQuery +=       " SC9.C9_BLCRED,"
	cQuery +=       " SC9.C9_BLWMS,"
	cQuery +=       " SC9.C9_CARGA,"
	cQuery +=       " DCF.DCF_CARGA"
	cQuery +=  " FROM "+RetSqlName('SC9')+" SC9"
	cQuery += " INNER JOIN "+RetSqlName('DCF')+" DCF"
	cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_ID     = SC9.C9_IDDCF"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=   " AND SC9.C9_CARGA   = '"+cCarg+"'"
	cQuery +=   " AND SC9.C9_PEDIDO  = '"+cPed+"'"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		If Empty((cAliasQry)->DCF_CARGA) .And. !Empty((cAliasQry)->C9_CARGA)
			WmsMessage(STR0089,WMSV10332) //Carga não controlada pelo WMS.
			lRet := .F.
			Exit
		ElseIf !Empty((cAliasQry)->C9_BLEST) .And. (cAliasQry)->C9_BLEST  != "10"
			WmsMessage(STR0082,WMSV10327) // Pedido com bloqueio de estoque!
			lRet := .F.
			Exit
		ElseIf !Empty((cAliasQry)->C9_BLCRED) .And. (cAliasQry)->C9_BLCRED != "10"
			WmsMessage(STR0083,WMSV10328) // Pedido com bloqueio de crédito!
			lRet := .F.
			Exit
		ElseIf (cAliasQry)->C9_BLWMS $ "01|02|03"
			WmsMessage(STR0084,WMSV10329) // Pedido com bloqueio WMS!
			lRet := .F.
			Exit
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} VlRomaneio
Valida se o romaneio ja nao foi liberado e faz embarque romaneio

@version	P11
@since   24/04/15
/*/
//----------------------------------------------------------
Static Function VlRomaneio(nTipo,lVolume,lEsc,lConsuta,lEstorno,aEnds)
Local lRet      := .F.
Local cAliasQry := GetNextAlias()
Local aTela     := VTSave()
Local aRomaneio := {}
Local i
Local dDtIni    := CtoD('  /  /  ')
Local cHrIni    := ''

Default aEnds := {}

	If Empty(cRomaneio)
		Return .F.
	EndIf
	cVolumes := ''

	cQuery :=  "SELECT DCU.DCU_ROMEMB,"
	cQuery +=        " DCU.DCU_CARGA,"
	cQuery +=        " DCU.DCU_PEDIDO,"
	cQuery +=        " DCU.DCU_CODVOL"
	cQuery +=   " FROM "+RetSqlName('DCU')+" DCU"
	cQuery +=  " WHERE DCU.DCU_FILIAL = '"+xFilial('DCU')+"'"
	cQuery +=    " AND DCU.DCU_ROMEMB = '"+cRomaneio+"'"
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY DCU.DCU_CARGA,"
	cQuery +=           " DCU.DCU_PEDIDO"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
		If Empty(cVolumes)
			cVolumes += "'"+(cAliasQry)->DCU_CODVOL+"'"
		Else
			cVolumes += ",'"+(cAliasQry)->DCU_CODVOL+"'"
		EndIf
		lRet := .T.
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If !lRet
		WmsMessage(STR0085,WMSV10330) // Este romaneio nao existe!
	ElseIf !lConsuta
		If lRet := ValPedido(nTipo,lEstorno,lVolume)
			VTClear()
			If lEstorno
				For i := 1 To Len(aEmbarque)
					aAdd(aEnds,{aEmbarque[i][1],aEmbarque[i][6]})
				Next i
			Else
				// Desconsidera os que já foram embarcados
				Do While (i := aScan(aEmbarque, {|x| !Empty(x[2]) })) > 0
					aDel(aEmbarque, i)
					aSize(aEmbarque, Len(aEmbarque) - 1)
				EndDo
				aRomaneio := aClone(aEmbarque)
				For i:= 1 to Len(aRomaneio)
					cVolume := Space(Len(DCU->DCU_CODVOL))
					lEmbDir := Empty(aRomaneio[i][5])
					cEndOk  := aRomaneio[i][5]
					
					VTClear()
					WMSVTCabec(STR0007, .F., .F., .T.) // Embarque
					nLin := 1
					If Empty(cEndereco) .Or. (!lEmbDir .And. AllTrim(aRomaneio[i][5]) != AllTrim(cEndereco))
						If !lEmbDir
							@ ++nLin, 00 VTSay PadR(STR0011, VTMaxCol()) // Va para o endereco:
							@ ++nLin, 00 VTSay aRomaneio[i][5]
							@ ++nLin, 00 VTSay PadR(STR0012, VTMaxCol()) // Confirme!
							@ ++nLin, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(.F.,nTipo,cEndereco,aRomaneio[i][6])
						Else
							@ ++nLin, 00 VTSay PadR(STR0057, VTMaxCol()) // Informe o endereco:
							@ ++nLin, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(.F.,nTipo,cEndereco,aRomaneio[i][6])
						EndIf
						VTRead()
					Else
						cEndereco := Iif(lEmbDir,cEndereco,aEmbarque[i][5])
						@ ++nLin, 00 VTSay PadR(STR0064, VTMaxCol()) // Endereco
						@ ++nLin, 00 VTSay PadR(cEndereco, VTMaxCol())
					EndIf
					dDtIni := dDataBase
					cHrIni := Time()
					
					If VTLastKey() == 27
						lEsc := .T.
						VtRestore(,,,,aTela)
						Exit
					EndIf
					
					If lVolume
						@ ++nLin, 00 VTSay PadR(STR0060, VTMaxCol())  // Volume
						@ ++nLin, 00 VTGet cVolume Valid !Empty(cVolume) .And. MensVolume(nTipo,cVolume) .And. WMSV100VOL(3,,,,cVolume)
						VTRead()
						If VTLastKey() == 27
							lEsc := .T.
							VtRestore(,,,,aTela)
							Exit
						EndIf
					EndIf
					nVol := aScan( aRomaneio, { |x| x[ 6 ] == cVolume} )
					If nVol > 0
						aDel(aRomaneio, nVol)
						aSize(aRomaneio,Len(aRomaneio)-1)
						i--
					EndIf
					If Len(aRomaneio) == 0
						Exit
					EndIf
				Next i
				// Caso tenha algum pedido a ser embarcado, pergunta se finaliza
				If Len(aPedidos) > 0
					// Chama a gravação 1 vez pois ja está carregado o array de pedidos
					GravaDados(nTipo,cEndOk,dDtIni,cHrIni)
				EndIf
			EndIf
			VtRestore(,,,,aTela)
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
/*---------------------------------------------------
---VldFatEst
---Valida se o item informado pode ser estornado
---felipe.m 21/07/2015
---nTipo, numérico, (Opção escolhida pelo menu)
---lVolume, lógico, (Possui volume)
---------------------------------------------------*/
Static Function VldFatEst(nTipo,lVolume)
Local aAreaAnt := GetArea()
Local lRet := .T.
Local cQuery := ""
Local cAliasQry := ""
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)

	If lWmsNew
		D00->(dbSetOrder(1)) // D00_FILIAL+D00_CARGA+D00_PEDIDO+D00_CODEND+D00_CODVOL
		If D00->(dbSeek(xFilial("D00")+cCarga+cPedido))
			If D00->D00_LIBEST == "1"
				Return .T.
			EndIf
		EndIf
	EndIf

	cQuery := " SELECT 1"
	cQuery +=   " FROM "+RetSqlName("SC9")+" SC9"
	If lVolume
	cQuery +=  " INNER JOIN "+RetSqlName("DCU")+" DCU"
	cQuery +=     " ON DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=    " AND DCU.DCU_CODVOL = '"+cEstVol+"'"
	cQuery +=    " AND DCU.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("DCV")+" DCV"
	cQuery +=     " ON DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
	cQuery +=    " AND DCV.DCV_CODVOL = DCU.DCU_CODVOL"
	cQuery +=    " AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO"
	cQuery +=    " AND DCV.DCV_ITEM = SC9.C9_ITEM"
	cQuery +=    " AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN"
	cQuery +=    " AND DCV.DCV_PRDORI = SC9.C9_PRODUTO"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	EndIf
	cQuery +=  " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	If nTipo == 1
	cQuery +=    " AND SC9.C9_CARGA = '"+cCarga+"'"
	ElseIf nTipo == 2
	cQuery +=    " AND SC9.C9_PEDIDO = '"+cPedido+"'"
	ElseIf nTipo == 4
	cQuery +=    " AND SC9.C9_ROMEMB = '"+cRomaneio+"'"
	EndIf
	cQuery +=    " AND SC9.C9_NFISCAL <> ' '"
	cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aAreaAnt)
Return lRet
