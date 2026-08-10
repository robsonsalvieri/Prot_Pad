#INCLUDE "WMSV101.ch" 
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APVT100.CH"

#DEFINE WMSV10101 "WMSV10101"
#DEFINE WMSV10102 "WMSV10102"
#DEFINE WMSV10103 "WMSV10103"
#DEFINE WMSV10104 "WMSV10104"
#DEFINE WMSV10105 "WMSV10105"
#DEFINE WMSV10106 "WMSV10106"
#DEFINE WMSV10107 "WMSV10107"
#DEFINE WMSV10108 "WMSV10108"
#DEFINE WMSV10109 "WMSV10109"
#DEFINE WMSV10110 "WMSV10110"
#DEFINE WMSV10111 "WMSV10111"
#DEFINE WMSV10112 "WMSV10112"
#DEFINE WMSV10113 "WMSV10113"
#DEFINE WMSV10114 "WMSV10114"
#DEFINE WMSV10115 "WMSV10115"
#DEFINE WMSV10116 "WMSV10116"
#DEFINE WMSV10117 "WMSV10117"
#DEFINE WMSV10118 "WMSV10118"
#DEFINE WMSV10119 "WMSV10119"
#DEFINE WMSV10120 "WMSV10120"
#DEFINE WMSV10121 "WMSV10121"
#DEFINE WMSV10122 "WMSV10122"
#DEFINE WMSV10123 "WMSV10123"
#DEFINE WMSV10124 "WMSV10124"
#DEFINE WMSV10125 "WMSV10125"
#DEFINE WMSV10126 "WMSV10126"
#DEFINE WMSV10127 "WMSV10127"
#DEFINE WMSV10128 "WMSV10128"
#DEFINE WMSV10129 "WMSV10129"
#DEFINE WMSV10130 "WMSV10130"
#DEFINE WMSV10131 "WMSV10131"
#DEFINE WMSV10132 "WMSV10132"
#DEFINE WMSV10133 "WMSV10133"
//----------------------------------------------------------
/*/{Protheus.doc} WMSV101 - Transferência para Doca
Permite que um pedido de venda, carga ou nota fiscal 
possa ser transferido do endereço atual para a Doca.                                                

@author  Evaldo Cevinscki Jr.
@version	P11
@since   12/07/12 - revisão 02/10/14
/*/
//----------------------------------------------------------
Function WMSV101()
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
Private cCarga    := Space(TamSx3("DAK_COD")[1])
Private cPedido   := Space(TamSx3("DAI_PEDIDO")[1])
Private cEndereco := Space(TamSx3("BE_LOCALIZ")[1])
Private cNota     := Space(TamSx3("C9_NFISCAL")[1])
Private aTransf   := {}
Private cEndPad   := Space(TamSx3("C9_ENDPAD")[1])
Private cEndOk    := Space(TamSx3("BE_LOCALIZ")[1])
Private cVolume   := Space(TamSx3("DCU_CODVOL")[1])
Private aPedidos  := {} // carrega pedidos do volume WMSV100VOL
Private lFuncVol  := FindFunction('WMSV100VOL')
Private lWMSAltDca:= SuperGetMV('MV_WMSALDC', .F., .F.) //Permite alterar DOCA
Private lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
Private cLocal	  := IIF(lD00Local, Space(TamSx3("D00_LOCDOC")[1]), "") 

	If Empty(cCodOpe)
		WmsMessage(STR0001,WMSV10101) //Operador nao cadastrado
		lRet := .F.
	EndIf
	If lRet	
		aTela := VtSave()
		VTClear()        
		
		If IsInCallStack("WMSV101")  
			@ 0,0 VTSay STR0003 // Selecione:
			If lWmsNew
				nOpc := VTaChoice(2,0,5,VTMaxCol(),{STR0004,STR0005,STR0006,STR0064}) // Transfere Carga // Transfere Pedido // Transfere Nota // Transfere Volume
			Else
				nOpc := VTaChoice(2,0,5,VTMaxCol(),{STR0004,STR0005,STR0006}) // Transfere Carga // Transfere Pedido // Transfere Nota
			EndIf
		ElseIf IsInCallStack("WMSV101A")
			nOpc := 1 // Transf. Carga
		ElseIf IsInCallStack("WMSV101B")
			nOpc := 2  // Transf. Pedido
		ElseIf IsInCallStack("WMSV101C")
			nOpc := 3 // Transf. NF
		EndIf
		VtClearBuffer()
		// Tela de tranferência
		If nOpc <> 0
			WMSV1011(nOpc)
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
Return ( lRet )
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Transferência de Carga   
//----------------------------------------------------------
Function WMSV101A()
	WMSV101()
Return Nil
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Transferência de Pedido 
//----------------------------------------------------------
Function WMSV101B()
	WMSV101()
Return Nil
//----------------------------------------------------------
// Função para ser chamada direto do menu e ir direto para
// a tela de Transferência de Nota
//----------------------------------------------------------
Function WMSV101C()
	WMSV101()
Return Nil 
//----------------------------------------------------------
/*/{Protheus.doc} WMSV1011
Tela de Transferência de Expedição

@param   nTipo    Tipo de endereçamento: 
                  1 - Carga
                  2 - Pedido
                  3 - NF

@author  Evaldo Cevinscki Jr.
@version	P11
@since   12/07/12 - revisão 02/10/14
/*/
//----------------------------------------------------------
Function WMSV1011(nTipo)
Local aTela    := VTSave()
Local cKey15   := VtDescKey(15)
Local bkey15   := VTSetKey(15)
Local cKey24   := VtDescKey(24)
Local bkey24   := VTSetKey(24)
Local nLin     := 0
Local lEsc     := .F.
Local lVolume  := .F.
Local dDtIni   := CtoD('  /  /  ')
Local cHrIni   := ''
Local nPos     := 0
Local aVolumes := {}
Local nOpc     := 0
Local nI       := 0
Local lLevaEnd := .F.
Local lContinua:= .F.
Local lAbandona:= .F.
Local aLocEnd  := {}
Local lRet     := .T.

	While .T.
		VTClear()
		nLin   := 0
		VTSetKey(15,{|| MontaCons(nTipo)}, STR0059) // Ctrl+O // Transferencias
		VTSetKey(24,{|| GerEstorno(nTipo,lVolume)}, STR0060) // Ctrl+X // Estorno
		
		cCarga    := Space(TamSx3("DAK_COD")[1])
		cPedido   := Space(TamSx3("DAI_PEDIDO")[1])
		cEndereco := Space(TamSx3("BE_LOCALIZ")[1])
		cNota     := Space(TamSx3("C9_NFISCAL")[1])
		cEndOk    := Space(TamSx3("BE_LOCALIZ")[1])
		cEndPad   := Space(TamSx3("C9_ENDPAD")[1])
		cVolume   := Space(TamSx3("DCU_CODVOL")[1])
		aTransf   := {} 
		lEsc      := .F.
		aPedidos  := {}
		
		If nTipo != 4
			WMSVTCabec(STR0007, .F., .F., .T.) // Transferir para Doca
			If nTipo == 1
				@ 02, 00 VTSay PadR(STR0008, VTMaxCol()) // Carga
				@ 03, 00 VTGet cCarga Valid ValidCarga(cCarga)  .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.) .And. If(lVolume,ValPedido(nTipo,,cCarga,cPedido),.T.)	
				VTRead()
				If VTLastKey() == 27
					Exit 
				EndIf 
				If !lVolume
					@ 05, 00 VTSay PadR(STR0009, VTMaxCol())	 // Pedido
					@ 06, 00 VTGet cPedido Valid ValPedido(nTipo,,cCarga,cPedido)
				EndIf
			ElseIf nTipo == 2	 
				@ 02, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
				@ 03, 00 VTGet cPedido Valid ValPedido(nTipo,,cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
			ElseIf nTipo == 3
				@ 02, 00 VTSay PadR(STR0010, VTMaxCol()) // Nota
				@ 03, 00 VTGet cNota Valid ValidaNf(cNota) .And. ValPedido(nTipo,,cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
			EndIf
			VTRead()
			If VTLastKey() == 27
				Exit
			EndIf
		EndIf
		
		nPos := 1
		While .T.
			lBrw := .F.
			aVolumes := {}
			// Mostra os volumes disponíveis quando a opção for 4 = por Volume
			If nTipo == 4
				WMSVTCabec(STR0007, .F., .F., .T.) // Transferir para Doca
				@ 02, 00 VTSay PadR(STR0062+":", VTMaxCol()) // Volume
				@ 03, 00 VTGet cVolume Valid If(lFuncVol .And. !Empty(cVolume),WMSV100VOL(3,@lVolume,,,cVolume),.T.) .And. ValPedido(nTipo,,'','',cVolume)
				VTRead()
				If VTLastKey() == 27
					Exit
				EndIf			
				If Empty(cVolume)
					WMSVTCabec(STR0007, .F., .F., .T.) // Transferir para Doca   
					nPos := VTaBrowse(2,,,,{STR0065,STR0066,STR0067,STR0068,STR0062,STR0009,STR0069,STR0008},aTransf,{15,15,10,8,10,6,15,6}) // Endereco // Operador End // Dt.Ender // Hr.Ender // Volume // Pedido // End.Destino // Carga
					If VTLastKey() == 27
						lEsc	:= .T.
						VtRestore(,,,,aTela) 
						Exit
					EndIf
					lBrw := .T.
					// Inclui o volume no array de pedidos
					cVolume := aTransf[nPos][5]
				Else
					aAdd(aVolumes, cVolume)
				EndIf
				lVolume := .T.
			EndIf
			// Confirmação da posição do carga/pedido ou volume do aTransf
			If nTipo != 4
				nPos := aScan(aTransf, {|x| x[8]+x[6] == cCarga+cPedido})
			Else
				nPos := aScan(aTransf, {|x| x[5] == cVolume })
			EndIf
			If nPos == 0
				nPos := 1
			EndIf
			
			cEndereco := Space(TamSx3("BE_LOCALIZ")[1])
			cEndOk    := Space(TamSx3("BE_LOCALIZ")[1])
			cVolume   := If(nTipo < 4,Space(TamSx3("DCU_CODVOL")[1]),cVolume)
			cCarga    := aTransf[nPos][8]
			cPedido   := aTransf[nPos][6]
			If lBrw .Or. nTipo < 4
				VTClear()
				WMSVTCabec(STR0007, .F., .F., .T.)        // Transferir para Doca
				@ 02, 00 VTSay PadR(STR0011, VTMaxCol()) // Va para o endereco:
				@ 03, 00 VTSay aTransf[nPos][1]
				@ 04, 00 VTSay PadR(STR0012, VTMaxCol()) // Confirme!
				@ 05, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(cEndereco,.F.,nTipo,aTransf[nPos][1],cCarga,cPedido)
				VTRead()
			Else
				cEndereco := aTransf[nPos][1]
			EndIf
			
			dDtIni := dDataBase
			cHrIni := 	Time()
			If VTLastKey() == 27
				lEsc	:= .T.
				Exit 
			EndIf
			If lVolume .And. Len(aTransf) > 0
				VTSetKey(22,{|| MntVolume(aVolumes)}, STR0062) // Ctrl+V // Volume
				VTSetKey(21,{|| EstVolume(@aVolumes,nPos)}, STR0070) // Ctrl+U // Estorno Volume
				Do While .T.
					VTCLear()
					WMSVTCabec(STR0007, .F., .F., .T.) // Transferir para Doca
					nLin := 1
					cVolume := Space(TamSx3("DCU_CODVOL")[1])
					@ ++nLin, 00 VTSay PadR(STR0065+": ", VTMaxCol()) // Endereco:
					@ ++nLin, 00 VTSay PadR(aTransf[nPos][1], VTMaxCol()) // DOCAAUX
					@ ++nLin, 00 VTSay PadR(STR0062+": ", VTMaxCol()) // Volume
					@ ++nLin, 00 VTGet cVolume Valid MensVolume(nPos) .And. WMSV100VOL(IIf(nTipo != 4,1,3),,cCarga,cPedido,cVolume) // Se a opção for por volume (nTipo == 4) desconsidera Carga+Pedido
					VTRead()
					
					If nPos == 0
						nPos := 1
					EndIf
					If VTLastKey() == 27
						nOpc := VTaBrowse(2,0,VTMaxRow(),VTMaxCol(),{Padr(STR0003,VTMaxCol())},IIf(!Empty(aVolumes),{{STR0071},{STR0072},{STR0073}},{{STR0072},{STR0073}}),{VTMaxCol()},,1) // Selecione: // Levar p/ Endereco // Continuar // Abandonar
						If !Empty(aVolumes)
							lLevaEnd  := (nOpc == 1)
							lContinua := (nOpc == 2)
							lAbandona := (nOpc == 3)
						Else
							lLevaEnd  := .F.
							lContinua := (nOpc == 1)
							lAbandona := (nOpc == 2)
						EndIf
						If lLevaEnd .Or. lAbandona// Levar p/ Endereço // Abandonar
							If lAbandona
								lEsc := .T.
							EndIf
							Exit
						EndIf
					Else
						If !Empty(cVolume) .And. aScan(aVolumes, {|x| x == cVolume }) == 0
							aAdd(aVolumes, cVolume)
							If Len(aTransf) == 1
								Exit
							EndIf
						ElseIf !Empty(cVolume) .And. aScan(aVolumes, {|x| x == cVolume }) > 0
							WmsMessage(STR0097,WMSV10127) // Volume ja selecionado para o endereçamento!
							VtKeyboard(Chr(20))
							Loop
						EndIf
					EndIf
				EndDo
			EndIf
			If !lEsc

				If !lWMSAltDca

					VTCLear()
					WMSVTCabec(STR0007, .F., .F., .T.) // Transferir para Doca
					nLin := 1
					@ ++nLin, 00 VTSay PadR(STR0013+aTransf[nPos][7], VTMaxCol()) // Leve p/
					@ ++nLin, 00 VTGet cEndOk Picture "@!" Valid ValidEnder(cEndOk,.F.,nTipo,aTransf[nPos][7],cCarga,cPedido,cVolume)
					VTRead()
					If VTLastKey() == 27
						lEsc := .T.
						Exit
					EndIf
				
				else
					VTCLear()
					WMSVTCabec(STR0007, .F., .F., .T.) // Transferir para Doca
					nLin := 1
					@ ++nLin, 00 VTSay PadR(STR0013+aTransf[nPos][7], VTMaxCol()) // Leve p/
					@ ++nLin, 00 VTGet cEndOk Picture "@!" Valid ValidEnder(cEndOk,.F.,nTipo,,cCarga,cPedido,cVolume)
					VTRead()

					If lD00Local .And. !Empty(cEndOk)
						cLocal :=  Space(TamSx3("D00_LOCDOC")[1])
						aLocEnd := WmsLocEnd(cEndOk)
						If Len(aLocEnd) = 1
							cLocal := aLocEnd[1][2]
						ElseIf Len(aLocEnd) > 1
							@ ++nLin,00 VTSay PadR(STR0099,VTMaxCol()) // "Informe o armazem:"
							@ ++nLin,00 VTGet cLocal Pict "@!" Valid WmsVldArm(cLocal,cEndOk) F3 'NNR'
							VTRead()
						EndIf
						lRet := WmsVld2D00(nTipo,cCarga,cPedido,cNota,cLocal,cEndOk)
						If !lRet
							lEsc := .T.
							Exit
						EndIf
					EndIf

					If VTLastKey() == 27
						lEsc := .T.
						Exit
					EndIf

				EndIf
				
				If !GravaDados(nTipo,dDtIni,cHrIni,aVolumes)
					// quando nao confirma a transferencia volta ao registro que estava
					VtRestore(,,,,aTela)
				Else
					// quando a selecao foi feita pelo browse, precisa excluir do array a posicao que foi selecionada
					If Len(aVolumes) > 0
						For nI := 1 To Len(aVolumes)
							nPos := aScan(aTransf, {|x| x[5] == aVolumes[nI]})
							If nPos > 0
								aDel(aTransf, nPos)
								aSize(aTransf,Len(aTransf) - 1)
							EndIf
						Next nI
					Else
						// Exclui o pedido do aTransf
						nPos := aScan(aTransf, {|x| x[6] == cPedido})
						aDel(aTransf, nPos)
						aSize(aTransf,Len(aTransf) - 1)
					EndIf
					nPos := 1
				EndIf
			Else
				Exit
			EndIf
			If lVolume
				VTSetKey(22)
				VTSetKey(21)
			EndIf
			
			If Len(aTransf) == 0
				Exit
			EndIf
		EndDo
		
		If VTLastKey() == 27 .Or. Len(aTransf) == 0
			If nTipo != 4
				If Len(aTransf) > 0
					TelaStatus(1,nTipo,lVolume) // Andamento
				Else
					TelaStatus(2,nTipo,lVolume)	// Finalizado
				EndIf
			EndIf
			Exit
		EndIf
	EndDo
	// Restaura teclas
	VTSetKey(15,bkey15,cKey15)
	VTSetKey(24,bkey24,cKey24)
	VtRestore(,,,,aTela)
Return Nil
//----------------------------------------------------------
// ValidCarga
// Valida se a carga informada é válida

// cCarga   Código da carga
//----------------------------------------------------------    
Static Function ValidCarga(cCarg)
Local lRet := .T.              
	If Empty(cCarg)
		Return .F. 
	EndIf
	If lRet
		DAK->(DbSetOrder(1))
		If DAK->(!DbSeek(xFilial("DAK")+cCarg))
			WmsMessage(STR0021,WMSV10102) // Carga inválida!
			lRet := .F.
		EndIf
		
		If lRet
			D00->(DbSetOrder(1))
			If D00->(!DbSeek(xFilial("D00")+cCarg))
				WmsMessage(STR0022,WMSV10103) // Carga nao enderecada!
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
// ValPedido
// Valida se o pedido informado é válido

// nTipo       Tipo de endereçamento: 
//             1 - Carga
//             2 - Pedido
//             3 - NF 
//             4 - Volume
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// cCarga      Código da carga
// cPedido     Código do pedido
//----------------------------------------------------------  
Static Function ValPedido(nTipo,lEstorno,cCarg,cPed,cVol)
Local lRet      := .T.
Local cQuery    := ''
Local cQuery2   := ''
Local cAliasQry := ''
			 
Default lEstorno := .F. 
Default cVol     := ''

	If (Empty(cPed) .And. (nTipo = 2 .Or. nTipo = 3) )
		Return .F.
	EndIf
	
	SC9->(DbSetOrder(1))
	If SC9->(!DbSeek(xFilial("SC9")+cPed)) .And. (nTipo = 2 .Or. nTipo = 3)
		WmsMessage(STR0024,WMSV10104) // Pedido inválido!
		lRet := .F.
	EndIf
	If lRet .And. lEstorno .And. nTipo == 1
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName('D00')
		cQuery += " WHERE D00_FILIAL = '"+xFilial('D00')+"'"
		cQuery +=   " AND D00_CARGA  = '"+cCarg+"'"
		cQuery +=   " AND D00_PEDIDO = '"+cPed+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(EoF())
			WmsMessage(STR0024,WMSV10129) // Pedido inválido!
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet
		If nTipo == 2
			D00->(dbSetOrder(3))
			D00->(dbSeek(xFilial("D00")+cPed))
			If D00->(!Eof()) .And. D00->(D00_FILIAL+D00_PEDIDO) == xFilial("D00")+cPed
				If !Empty(D00->D00_CARGA)
					lRet := .F.
					WmsMessage(WmsFmtMsg(STR0074,{{"[VAR01]",AllTrim(D00->D00_CARGA)}}),WMSV10105) // Pedido está contido na carga [VAR01], utilize o menu por carga!
				EndIf
			EndIf
		EndIf
		If lRet
			cQuery :=       "SELECT D00.D00_CODEND,"
			cQuery +=             " D00.D00_OPEEND,"
			cQuery +=             " D00.D00_DATEND,"
			cQuery +=             " D00.D00_HOREND,"
			cQuery +=             " D00.D00_CODDOC,"
			cQuery +=             " D00.D00_CARGA,"
			cQuery +=             " D00.D00_PEDIDO"
			cQuery +=            ", D00.D00_CODVOL"
			cQuery +=        " FROM "+RetSqlName('D00')+" D00"
			cQuery +=       " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
			If nTipo == 1
				cQuery +=     " AND D00.D00_CARGA  = '"+cCarg+"'"
				cQuery +=     " AND D00.D00_PEDIDO = '"+cPed+"'"
			ElseIf nTipo == 2 .Or. nTipo == 3
				cQuery +=     " AND D00.D00_PEDIDO = '"+cPed+"'"
			Else
				cQuery +=     " AND D00.D00_CODVOL <> ' '"
				cQuery +=     " AND D00.D00_CODEND <> ' '"
				cQuery +=     " AND D00.D00_CODDOC = ' '"
				cQuery +=     " AND D00.D00_TIPEMB = '0'"
				If !Empty(cVol)
					cQuery += " AND D00.D00_CODEND IN (SELECT D002.D00_CODEND"
					cQuery +=                         " FROM "+RetSqlName("D00")+" D002"
					cQuery +=                        " WHERE D002.D00_FILIAL = '"+xFilial('D00')+"'"
					cQuery +=                          " AND D002.D00_CODVOL = '"+cVol+"'"
					cQuery +=                          " AND D002.D_E_L_E_T_ = ' ')"
				EndIf  
			EndIf	
			cQuery +=         " AND D00.D_E_L_E_T_ = ' '"
			cQuery2 := cQuery
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			Do While (cAliasQry)->(!Eof())
				If nTipo == 2 .Or. nTipo == 3  // verifica se o pedido possui mais de uma carga
					If Empty(cCarg)
						ChkCarga(@cCarg,cPed,cQuery2)
					EndIf
					If !Empty(cCarg) .And. cCarg <> (cAliasQry)->D00_CARGA
						(cAliasQry)->(DbSkip())
						Loop
					EndIf
				EndIf
				If SC9->(DbSeek(xFilial("SC9")+(cAliasQry)->D00_PEDIDO))
					cEndPad := SC9->C9_ENDPAD
				EndIf
				
				cVol := (cAliasQry)->D00_CODVOL
				
				If Empty((cAliasQry)->D00_CODDOC) .And. If(!Empty(cVol),Ascan( aTransf, { |x| x[ 5 ] == cVol} ) == 0 ,.T.)
					AAdd(aTransf,{(cAliasQry)->D00_CODEND,(cAliasQry)->D00_OPEEND,(cAliasQry)->D00_DATEND,(cAliasQry)->D00_HOREND,cVol,(cAliasQry)->D00_PEDIDO,cEndPad,(cAliasQry)->D00_CARGA})
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())

			If Len(aTransf) < 1 .And. !lEstorno
				If nTipo == 1 .Or. nTipo == 2                                                        					
					WmsMessage(STR0026,WMSV10106) // Pedido nao enderecado ou ja transferido!
				ElseIf nTipo == 3
					WmsMessage(STR0027,WMSV10107)// Nota nao enderecada ou ja transferida!
				ElseIf nTipo == 4
					WmsMessage(STR0075,WMSV10108) // Volume nao enderecado ou ja transferido!
				EndIf
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
// ValidaNf
// Valida se a nota fiscal informada é válida
//
// cNF   Código da nota fiscal
//----------------------------------------------------------
Static Function ValidaNf(cNF)
Local lRet      := .T.
Local cQuery    := ''
Local cAliasQry := GetNextAlias()

	If Empty(cNF)
		Return .F.
	EndIf
	
	cAliasQry := GetNextAlias()
	cQuery := "SELECT DCF.DCF_CARGA,"
	cQuery +=       " SC9.C9_PEDIDO,"
	cQuery +=       " SC9.C9_ENDPAD"
	cQuery +=  " FROM " +RetSqlName('SC9') + " SC9"
	cQuery += " INNER JOIN "+RetSqlName('DCF')+" DCF"
	cQuery +=    " ON DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_ID     = SC9.C9_IDDCF"
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SC9.C9_FILIAL  = '"+xFilial('SC9')+"'"
	cQuery +=   " AND SC9.C9_NFISCAL = '"+cNota+"'"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
	If (cAliasQry)->(!Eof())
		cCarga  := (cAliasQry)->DCF_CARGA
		cPedido := (cAliasQry)->C9_PEDIDO 
		cEndPad := (cAliasQry)->C9_ENDPAD
	Else
		WmsMessage(STR0058,WMSV10109) // Nota nao encontrada!
		lRet := .F. 	
		VTKeyBoard(Chr(20))
	EndIf
	(cAliasQry)->(DbCloseArea())
Return lRet
//----------------------------------------------------------
// ValidEnder
// Valida se o endereço informado pode receber o documento

// cEnd        Código do endereço
// lEstorno    Indica se a função foi chamada pelo processo de estorno
// nTipo       Tipo de endereçamento: 
//             1 - Carga
//             2 - Pedido
//             3 - NF 
// lChkEndPad  Indica se deve checar se o endereço informado é igual
//             ao previsto para endereçamento/tranferência do documento
// i           Variável utilizada na execução da tranferência, se for maior
//             que 0 (zero) checa se o endereço para onde está sendo efetuada
//             a transferência é o mesmo que informado incialmente
// cCarg       Código da carga
// cPed        Código do pedido
//----------------------------------------------------------  
Static Function ValidEnder(cEnd,lEstorno,nTipo,cEndDes,cCarg,cPed,cVol)
Local lRet      := .T.   
Local cAliasQry := GetNextAlias()

Default cVol    := Space(TamSx3("DCU_CODVOL")[1])

	If Empty(cEnd)
		Return .F.
	EndIf 
	// Valida se o endereco digitado é igual ao endereco original
	If !Empty(cEndDes) .And. !lWMSAltDca
		If cEnd <> cEndDes
			WmsMessage(STR0031,WMSV10110)// Local diferente do previsto!
			VtKeyboard(Chr(20))  
			Return .F.
		EndIf
	EndIf
	SBE->(DbSetOrder(9))
	If SBE->(DbSeek(xFilial('SBE')+cEnd))
		DC8->(DbSetOrder(1))
		DC8->(DbSeek(xFilial('DC8')+SBE->BE_ESTFIS))
		If DC8->DC8_TPESTR != '5'
			WmsMessage(STR0076,WMSV10111) // Informe um endereco de estrutura fisica do tipo DOCA!
			lRet := .F.
		EndIf 
	Else
		WmsMessage(STR0077,WMSV10112) // Endereco invalido!
		lRet := .F.
	EndIf
	If lRet
		If lEstorno
			cQuery :=   "SELECT D00.D00_CODDOC"
			cQuery +=    " FROM "+RetSqlName('D00')+" D00"
			cQuery +=   " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
			If nTipo == 1
				cQuery += " AND D00.D00_CARGA  = '"+cCarg+"'"
			ElseIf nTipo < 4 
				If !Empty(cCarg)
					cQuery += " AND D00.D00_CARGA  = '"+cCarg+"'"
				EndIf 
				cQuery +=   " AND D00.D00_PEDIDO = '"+cPed+"'"
			EndIf
			If !Empty(cVol)
				cQuery +=   " AND D00.D00_CODVOL = '"+cVol+"'"
			EndIf
			cQuery +=   " AND D00.D00_CODDOC = '"+cEnd+"'"
			cQuery +=   " AND D00.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (lRet := (cAliasQry)->(!Eof())) 
				Do While (cAliasQry)->(!Eof())
					If Empty((cAliasQry)->D00_CODDOC)
						lRet := .F.	
						Exit
					EndIf
					(cAliasQry)->(DbSkip())
				EndDo
			EndIf
			(cAliasQry)->(DbCloseArea())
			If !lRet
				WmsMessage(STR0078,WMSV10113) // Transferencia do pedido nao encontrada!
				lRet := .F.	
			EndIf
		EndIf
	EndIf
	
	If !lRet
		VTKeyBoard(Chr(20))
	EndIf
Return lRet
//----------------------------------------------------------
// MontaCons 
//Monta a consulta de transferências
//
// nTipo    Tipo de endereçamento: 
//          1 - Carga
//          2 - Pedido
//          3 - NF 
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
Local lVolume   := .F.
Local lRet      := .T.
	cCarga    := Space(TamSx3("DAK_COD")[1])
	cPedido   := Space(TamSx3("DAI_PEDIDO")[1])
	cNota     := Space(TamSx3("C9_NFISCAL")[1])
	cVolume   := Space(TamSx3("DCU_CODVOL")[1])
	WMSVTCabec(STR0079, .F., .F., .T.) // Consulta Transfs 
	If nTipo == 1 .And. Empty(cCarga)
		@ 02, 00 VTSay PadR(STR0008, VTMaxCol()) // Carga
		@ 03, 00 VTGet cCarga Valid ValidCarga(cCarga) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.)
		VTRead()				
	ElseIf nTipo == 2	 .And. Empty(cPedido)
		@ 02, 00 VTSay PadR(STR0009, VTMaxCol()) // Pedido
		@ 03, 00 VTGet cPedido Valid ValPedido(nTipo,.T.,@cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 3 .And. Empty(cNota)
		@ 02, 00 VTSay PadR(STR0010, VTMaxCol()) // Nota
		@ 03, 00 VTGet cNota Valid ValidaNf(cNota) .And. ValPedido(nTipo,.T.,@cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 4 
		@ 02, 00 VTSay PadR(STR0062+":", VTMaxCol())	 // Volume
		@ 03, 00 VTGet cVolume Valid If(lFuncVol,WMSV100VOL(3,@lVolume,,,cVolume),.T.) .And. ValPedido(nTipo,.T.,'','',cVolume)
		VTRead()
	EndIf
	
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0059)
		VTSetKey(24,bKey24, STR0060)
		Return 
	EndIf    
	
	If nTipo == 1 .And. Empty(cCarga) 
		WmsMessage(STR0080,WMSV10115) // Informe uma carga consultar.
		lRet := .F.
	ElseIf nTipo == 2 .And. Empty(cPedido)
		WmsMessage(STR0081,WMSV10116) // Informe um pedido para consultar.
		lRet := .F.
	ElseIf nTipo == 3 .And. Empty(cNota)
		WmsMessage(STR0082,WMSV10117) // Informe uma nota para consultar.
		lRet := .F.
	ElseIf nTipo == 4 .And. Empty(cVolume)
		WmsMessage(STR0083,WMSV10118) // Informe um volume para consultar.
		lRet := .F.
	EndIf
	
	If !lRet
		VtKeyboard(Chr(20))
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0059)
		VTSetKey(24,bKey24, STR0060)
		Return Nil
	EndIf
	
	cQuery :=       "SELECT DISTINCT D00.D00_PEDIDO,"
	cQuery +=                      " D00.D00_CODEND,"
	cQuery +=                      " D00.D00_CODDOC,"
	cQuery +=                      " D00.D00_OPEDOC,"
	cQuery +=                      " D00.D00_DATDOC,"
	cQuery +=                      " D00.D00_HORDOC,"
	cQuery +=                      " D00.D00_CODVOL"
	cQuery +=        " FROM "+RetSqlName('D00')+" D00"
	// Não considerar os pedidos que já foram faturados.
	cQuery +=       " INNER JOIN "+RetSqlName("SC9")+" SC9"
	cQuery +=          " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=         " AND SC9.C9_PEDIDO = D00.D00_PEDIDO"
	If nTipo != 3
		cQuery +=     " AND SC9.C9_NFISCAL = ' '"
	EndIf
	cQuery +=         " AND SC9.D_E_L_E_T_ = ' '"
	cQuery +=       " WHERE D00.D00_FILIAL = '"+xFilial('D00')+"'"
	If Empty(cVolume)
		If nTipo == 1
			cQuery += " AND D00.D00_CARGA  = '"+cCarga+"'"
		Else 
			cQuery += " AND D00.D00_PEDIDO = '"+cPedido+"'"
		EndIf	
	Else
		cQuery +=     " AND D00.D00_CODVOL = '"+cVolume+"'"
	EndIf
	cQuery +=         " AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		AAdd(aEnds,{(cAliasQry)->D00_PEDIDO,(cAliasQry)->D00_CODEND,(cAliasQry)->D00_CODDOC,(cAliasQry)->D00_OPEDOC,(cAliasQry)->D00_DATDOC,(cAliasQry)->D00_HORDOC,(cAliasQry)->D00_CODVOL})
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	If Len(aEnds) > 0
		VTClear()
		If nTipo == 1
			@ 0,0 VtSay STR0035 // Transferencia Pedido
			@ 1,0 VtSay STR0036+cCarga+STR0037+cPedido // C.: // P.:
		ElseIf nTipo == 2
			@ 0,0 VtSay STR0035 // Transferencia Pedido
			@ 1,0 VtSay STR0017+cPedido // Pedido:
		ElseIf nTipo == 3
			@ 0,0 VtSay STR0038 // Transferencia Nota
			@ 1,0 VtSay STR0018+cNota // Nota:
		ElseIf nTipo == 4
			@ 0,0 VtSay STR0084 // Transferencia Volume
			@ 1,0 VtSay STR0062+": "+cVolume
		EndIf	
		nPos:=VTaBrowse(2,,,,{STR0009,STR0039,STR0040,STR0041,STR0042,STR0043,STR0062},aEnds,{6,15,15,6,10,5,10}) // Endereco // Doca // Operador // Data // Hora // Pedido // Volume
		VtRestore(,,,,aTela)
	Else
		If nTipo == 1
			WmsMessage(WmsFmtMsg(STR0085,{{"[VAR01]",AllTrim(cCarga)}}),WMSV10119) // Transferencia para a carga [VAR01] nao encontrada!
		ElseIf nTipo == 2
			WmsMessage(WmsFmtMsg(STR0086,{{"[VAR01]",AllTrim(cPedido)}}),WMSV10120) // Transferencia para o pedido [VAR01] nao encontrado!
		ElseIf nTipo == 3
			WmsMessage(WmsFmtMsg(STR0087,{{"[VAR01]",AllTrim(cNota)}}),WMSV10121) // Transferencia para a nota [VAR01] nao encontrado!
		ElseIf nTipo == 4
			WmsMessage(WmsFmtMsg(STR0088,{{"[VAR01]",AllTrim(cVolume)}}),WMSV10122) // Transferencia para o volume [VAR01] nao encontrado!   
		EndIf
		VtKeyboard(Chr(20))
	EndIf
	// Restaura Tecla
	VTSetKey(15,bKey15, STR0059)
	VTSetKey(24,bKey24, STR0060)
Return .T.
//----------------------------------------------------------
// GerEstorno
// Realiza o estorno de uma transferência

// nTipo    Tipo de endereçamento: 
//          1 - Carga
//          2 - Pedido
//          3 - NF 
//----------------------------------------------------------   
Static Function GerEstorno(nTipo,lVolume)
Local cKey15  := VtDescKey(15)
Local cKey24  := VtDescKey(24)
Local bkey15  := VTSetKey(15)
Local bkey24  := VTSetKey(24)
Local aTela	:= VTSave()
Local nLin    :=	0 
Local cQuery  := ''
Local cAliasQry := GetNextAlias()
Local cMsg      := ''
Local cPedidos  := ''
Local lRet      := .T.
Local aLocEnd   := {}

Default lVolume := .F.
	
	cEstVol   := Space(TamSx3("DCU_CODVOL")[1])
	cCarga    := Space(TamSx3("DAK_COD")[1])
	cPedido   := Space(TamSx3("DAI_PEDIDO")[1])
	cEndereco := Space(TamSx3("BE_LOCALIZ")[1])
	cNota     := Space(TamSx3("C9_NFISCAL")[1])
	cLocal	  := IIF(lD00Local, Space(TamSx3("D00_LOCDOC")[1]), "") 
	
	VTClear()
	nLin := 1
	WMSVTCabec(STR0044, .F., .F., .T.)   // Estorna Transf.
	If nTipo == 1 .And. Empty(cCarga)
		@ ++nLin, 00 VTSay PadR(STR0008, VTMaxCol())	 // Carga
		@ ++nLin, 00 VTGet cCarga Valid ValidCarga(cCarga) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga),.T.)	
		VTRead() 
		If Empty(cPedido)
			@ ++nLin, 00 VTSay PadR(STR0009, VTMaxCol())	 // Pedido
			@ ++nLin, 00 VTGet cPedido Valid ValPedido(nTipo,.T.,@cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
			VTRead()
		EndIf
	ElseIf nTipo == 2 .And. Empty(cPedido)
		@ ++nLin, 00 VTSay PadR(STR0009, VTMaxCol())	 // Pedido
		@ ++nLin, 00 VTGet cPedido Valid ValPedido(nTipo,.T.,@cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)
		VTRead()
	ElseIf nTipo == 3 .And. Empty(cNota)
		@ ++nLin, 00 VTSay PadR(STR0010, VTMaxCol())	 // Nota
		@ ++nLin, 00 VTGet cNota Valid ValidaNf(cNota) .And. ValPedido(nTipo,.T.,@cCarga,cPedido) .And. If(lFuncVol,WMSV100VOL(2,@lVolume,cCarga,cPedido),.T.)	 
		VTRead()
	ElseIf nTipo == 4
		@ ++nLin, 00 VTSay PadR(STR0062, VTMaxCol())	 // Volume
		@ ++nLin, 00 VTGet cEstVol Valid If(lFuncVol,WMSV100VOL(3,@lVolume,,,cEstVol),.T.) .And. ValPedido(nTipo,.T.,'','',cEstVol)
		VTRead()	
	EndIf	 

	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0059)
		VTSetKey(24,bKey24, STR0060)
		Return Nil
	EndIf 
	
	If lVolume .And. nTipo <> 4
		@ ++nLin, 00 VTSay PadR(STR0062+": ", VTMaxCol())	  // Volume
		@   nLin, 09 VTGet cEstVol Valid lFuncVol .And. WMSV100VOL(3,,,,cEstVol)
		VTRead()
		If VTLastKey() == 27
			VtRestore(,,,,aTela)
			// Restaura Tecla
			VTSetKey(15,bKey15, STR0059)
			VTSetKey(24,bKey24, STR0060)
			Return Nil
		EndIf 
	EndIf
	
	VTClear()
	nLin := 1
	WMSVTCabec(STR0044, .F., .F., .T.) // Estorna Transf.
	If nTipo == 1
		@ ++nLin, 00 VTSay PadR(STR0016+cCarga, VTMaxCol())	 // Carga.:	  	
	ElseIf nTipo == 2
		@ ++nLin, 00 VTSay PadR(STR0017+cPedido, VTMaxCol())  // Pedido:			  	
	ElseIf nTipo == 3
		@ ++nLin, 00 VTSay PadR(STR0018+cNota, VTMaxCol())  // Nota:		  			
	ElseIf nTipo == 4
		@ ++nLin, 00 VTSay PadR(STR0062+": "+cEstVol, VTMaxCol())  	
	EndIf	
	If !Empty(cEstVol) .And. nTipo <> 4
		@ ++nLin, 00 VTSay PadR(STR0062+": "+cEstVol, VTMaxCol())  // Volume
	EndIf
	If Empty(cEndereco) // Não pede o endereço se ja foi informado
		@ ++nLin, 00 VTSay PadR(STR0045, VTMaxCol())		 // Endereco Destino
		@ ++nLin, 00 VTGet cEndereco Picture "@!" Valid ValidEnder(cEndereco,.T.,nTipo,cEndPad,cCarga,cPedido,cEstVol)
		VTRead()
		// Caso o endereço já tenha sido informado, apenas valida de existe a tranferencia para estornar
	ElseIf !ValidEnder(cEndereco,.T.,nTipo,,cCarga,cPedido,cEstVol)
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0059)
		VTSetKey(24,bKey24, STR0060)
		Return Nil
	EndIf
	
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		// Restaura Tecla
		VTSetKey(15,bKey15, STR0059)
		VTSetKey(24,bKey24, STR0060)
		Return Nil
	EndIf   
	
	If lWMSAltDca  .And. lD00Local .And. !Empty(cEndereco) .And. Empty(cLocal)
		aLocEnd := WmsLocEnd(cEndereco)
		If Len(aLocEnd) = 1
			cLocal := aLocEnd[1][2]
		ElseIf Len(aLocEnd) > 1
			@ ++nLin,00 VTSay PadR(STR0099,VTMaxCol()) // "Informe o armazem:"
			@ ++nLin,00 VTGet cLocal Pict "@!" Valid WmsVldArm(cLocal,cEndereco) F3 'NNR'
			VTRead()
		EndIf
		lRet := WmsEmbD00(1,cCarga,cPedido,cEstVol,cNota,cLocal,cEndereco) //Valida se possui embarque para deixar estornar
		If lRet
			lRet := WmsBoxDoca(.F.,nTipo,cPedido,,,,cNota, cCarga, cEstVol, cLocal, cEndereco)
		EndIf
		If !lRet
			VtRestore(,,,,aTela)
			// Restaura Tecla
			VTSetKey(15,bKey15, STR0059)
			VTSetKey(24,bKey24, STR0060)
			Return Nil
		EndIf
	EndIf

	If nTipo == 1
		cMsg	:= STR0046+AllTrim(cCarga) // Confirma o estorno da transf. da Carga: "######" Pedido: "###" no endereço:
		cMsg   += If(Empty(cVolume),""," / "+STR0062+": "+AllTrim(cVolume))   // Volume	
		cMsg	+= STR0048+AllTrim(cEndereco) // no endereço:
	ElseIf nTipo == 2
		cMsg	:= STR0049+AllTrim(cPedido)+STR0048+AllTrim(cEndereco) // Confirma o estorno da transf. do Pedido: "###" no endereço:		
	ElseIf nTipo == 3
		cMsg	:= STR0050+AllTrim(cNota)+STR0048+AllTrim(cEndereco) // Confirma o estorno da transf. da Nota: "###" no endereço:	
	ElseIf nTipo == 4
		cMsg	:= WmsFmtMsg(STR0089,{{"[VAR01]",cEstVol},{"[VAR02]",cEndereco}}) // Confirma o estorno da transf. do Volume: [VAR01] no endereco: [VAR02]	
	EndIf	
				 
	VTClear()
	WMSVTCabec(STR0051, .F., .F., .T.) // Atenção
	If VtYesNo(AllTrim(cMsg),STR0051) // Atenção
	   // query para filtrar pelo codigo do volume quando for informando, fazendo um While para deletar todos os pedidos do volume
		cQuery := "SELECT D00_PEDIDO, D00_CODEND, D00_OPEEND, D00_DATEND, D00_HOREND, R_E_C_N_O_ nRec"
		cQuery +=      ", D00_CODVOL"	
		cQuery +=  " FROM "+RetSqlName('D00')+" D00"
		cQuery += " WHERE D00_FILIAL = '"+xFilial('D00')+"'"
		If Empty(cEstVol)
			If nTipo == 1 
				cQuery += " AND D00_CARGA  = '"+cCarga+"'"
			Else
				If !Empty(cCarga)
					cQuery += " AND D00_CARGA  = '"+cCarga+"'"
				EndIf
			EndIf	
			cQuery +=   " AND D00_PEDIDO = '"+cPedido+"'"
		Else
			cQuery +=   " AND D00_CODVOL = '"+cEstVol+"'"
		EndIf	
		If lD00Local
			cQuery +=   " AND D00_LOCDOC = '"+cLocal+"'"
			cQuery +=   " AND D00_CODDOC = '"+cEndereco+"'"
		EndIf
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	   
		Begin Transaction	
	
			While (cAliasQry)->(!Eof()) 
				D00->(dbGoTo((cAliasQry)->nRec))   	
				If (D00->D00_TIPEMB == '1')
					WmsMessage(STR0061,WMSV10123) // Não foi possivel realizar o estorno!
					VtKeyboard(Chr(20))  
					Exit
				Else
					cPedidos += If(Empty(cPedidos),'',', ') + D00->D00_PEDIDO	
					RecLock("D00",.F.)
					D00->D00_CODDOC	:= ""
					D00->D00_OPEDOC	:= ""
					D00->D00_DATDOC	:= CtoD("  /  /  ")
					D00->D00_HORDOC	:= ""   
					D00->D00_DTDOCF := CtoD("  /  /  ")
					D00->D00_HRDOCF := ""
					If lD00Local
						D00->D00_LOCDOC := ""
					EndIf
					D00->(MsUnlock())
				EndIf	
				(cAliasQry)->(DbSkip())
			EndDo	 
			(cAliasQry)->(DbCloseArea())
			 If lVolume
				WmsMessage(WmsFmtMsg(STR0090,{{"[VAR01]",AllTrim(cEstVol)},{"[VAR02]",AllTrim(cPedidos)}}),WMSV10124) // Estornada a transferencia do volume: [VAR01] do Pedido: [VAR02]
				VtKeyboard(Chr(20))	
			EndIf
		End Transaction
	EndIf 
	VtRestore(,,,,aTela)
	// Restaura Tecla
	VTSetKey(15,bKey15, cKey15)
	VTSetKey(24,bKey24, cKey24)
Return Nil
//----------------------------------------------------------
// GravaDados
// Gravação das informações da transferência na tabela D00
// 
// nTipo    Tipo de endereçamento: 
//          1 - Carga
//          2 - Pedido
//          3 - NF 
//----------------------------------------------------------
Static Function GravaDados(nTipo,dDtIni,cHrIni,aVolumes)
Local aTela  := VTSave()
Local cMsg   := ""
Local i      := 0
	
	If nTipo == 1
		cMsg	:= STR0052+AllTrim(cCarga) // Confirma a transf. da Carga: "###"
		cMsg   += If(Empty(cVolume),""," / "+STR0062+": "+AllTrim(cVolume))   // Volume
		cMsg   += STR0053+AllTrim(cEndereco)       // do Endereço: "###"
		cMsg   += STR0054+AllTrim(cEndOk)     // p/:
	ElseIf nTipo == 2
		cMsg	:= STR0055+AllTrim(cPedido)+STR0053+AllTrim(cEndereco)+STR0054+AllTrim(cEndOk) // Confirma a transf. do Pedido: "###" do Endereço: "###" p/:	
	ElseIf nTipo == 3
		cMsg	:= STR0056+AllTrim(cNota)+STR0053+AllTrim(cEndereco)+STR0054+AllTrim(cEndOk) // Confirma a transf. da Nota: "###" do Endereço: "###" p/:	
	ElseIf nTipo == 4
		cMsg	:= WmsFmtMsg(STR0091,{{"[VAR01]",cVolume},{"[VAR02]",cEndereco},{"[VAR03]",cEndOk}}) // Confirma a transf. do Volume: [VAR01] do Endereco: [VAR02] p/: [VAR03]
	EndIf	
	
	If Len(aPedidos) == 0
		For i := 1 To Len(aVolumes)
			aAdd(aPedidos,{cCarga,cPedido,aVolumes[i]})
		Next i
		If Len(aVolumes) == 0
			aAdd(aPedidos,{cCarga,cPedido,""})
		EndIf
	EndIf
	
	VTClear()
	WMSVTCabec(STR0051, .F., .F., .T.) // Atenção
	If VtYesNo(AllTrim(cMsg),STR0051) // Atenção
		Begin Transaction
			For i:= 1 to Len(aPedidos)
				D00->(DbSetOrder(1))
				If D00->(DbSeek(xFilial("D00")+aPedidos[i][1]+aPedidos[i][2]+cEndereco+aPedidos[i][3]))
					RecLock("D00",.F.)
					D00->D00_CODDOC := cEndOk
					D00->D00_OPEDOC := cCodOpe
					D00->D00_DATDOC := dDtIni
					D00->D00_HORDOC := cHrIni
					D00->D00_DTDOCF := dDataBase
					D00->D00_HRDOCF := Time()
					If lD00Local
						D00->D00_LOCDOC := cLocal
					EndIf
					D00->(MsUnlock())
				EndIf
			Next i
		End Transaction
	Else
		VtRestore(,,,,aTela)
		Return .F.
	EndIf
	If VTLastKey() == 27
		VtRestore(,,,,aTela)
		Return .F.
	EndIf
	VtRestore(,,,,aTela)
Return .T.
//------------------------------------------------------
// MensVolume 
// Mensagem de validação do volume informado
//------------------------------------------------------
Static Function MensVolume(nPos)
Local lRet := .T.
Local cAliasQry := GetNextAlias()
	cQuery := "SELECT R_E_C_N_O_ nRec"
	cQuery +=  " FROM "+RetSqlName('D00')+" D00"
	cQuery += " WHERE D00_FILIAL = '"+xFilial('D00')+"'"
	cQuery +=   " AND D00_CODVOL = '"+cVolume+"'"
	cQuery +=   " AND D00_CODDOC <> '' "
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof()) 
		WmsMessage(WmsFmtMsg(STR0098,{{"[VAR01]",AllTrim(cVolume)}}),WMSV10125) // O Volume: [VAR01] ja foi transferido!
		lRet := .F.
		VtKeyboard(Chr(20))
	EndIf	 
	(cAliasQry)->(DbCloseArea())
	
	If lRet
		nPos := Ascan( aTransf, { |x| x[ 5 ] == cVolume} )
		If nPos == 0
			WmsMessage(STR0063,WMSV10126) // Volume diferente do previsto!
			lRet := .F.
			VtKeyboard(Chr(20))
		Else  
			D00->(DbSetOrder(4)) //D00_FILIAL+D00_CODEND+D00_CODVOL
			If D00->(!DbSeek(xFilial("D00")+cEndereco+cVolume))
				WmsMessage(WmsFmtMsg(STR0096,{{"[VAR01]",AllTrim(cVolume)},{"[VAR02]",AllTrim(cEndereco)}}),WMSV10128) // "O Volume: [VAR01] nao encontra-se no Endereco:[VAR02]!"
				lRet := .F.
				VtKeyboard(Chr(20))
			Else 	
				cPedido := aTransf[nPos][6]
			EndIf
		EndIf
	EndIf
Return lRet
//-----------------------------------------------------------
//  Monta tela com Status da Transferencia.
//-----------------------------------------------------------
Static Function TelaStatus(nAcao,nTipo,lVolume)

	VTClear()
	WMSVTCabec(STR0014, .F., .F., .T.) // Transf. p/ Doca
	If nAcao == 1
		@ 01, 00 VTSay PadR(STR0015, VTMaxCol()) // Em andamento!
	Else
		@ 01, 00 VTSay PadR(STR0019, VTMaxCol()) // Finalizada
	EndIf
	@ 02, 00 VTSay "--------------------"
	If nTipo == 1
		@ 03, 00 VTSay PadR(STR0016+cCarga, VTMaxCol()) // Carga.:
		@ 04, 00 VTSay "--------------------"
	ElseIf nTipo == 2
		@ 03, 00 VTSay PadR(STR0017+cPedido, VTMaxCol()) // Pedido:
	ElseIf nTipo == 3
		@ 03, 00 VTSay PadR(STR0018+cNota, VTMaxCol()) // Nota:
	EndIf
	WMSVTRodPe()
Return .T.
//-----------------------------------------------------------
// Verifica se o pedido possui mais de uma carga, nesse 
// caso mostra em um browser para selecionar a carga correta.
//----------------------------------------------------------- 
Static Function ChkCarga(cCarg,cPed,cQry)
Local aTela    := VTSave()
Local cAliasCg := GetNextAlias()
Local aCarga   := {}
Local nPos     := 1
 
	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),cAliasCg,.F.,.T.)
	Do While (cAliasCg)->(!Eof())
		If !Empty((cAliasCg)->D00_CARGA) .And. ( Ascan( aCarga, { |x| x[ 1 ] == (cAliasCg)->D00_CARGA} ) == 0 )
			aAdd(aCarga,{(cAliasCg)->D00_CARGA} )
		EndIf
		(cAliasCg)->(DbSkip())
	EndDo
	(cAliasCg)->(DbCloseArea())

	If Len(aCarga) > 0 
		If Len(aCarga) = 1
			cCarg := aCarga[1][1]
		Else
			// monta browse para selecionar a carga correta
			WMSVTCabec(STR0093, .F., .F., .T.) // Selecione a Carga 
			nPos := VTaBrowse(2,,,,{STR0008},aCarga,{6}) // Carga 
			If !Empty(nPos)
				cCarg := aCarga[nPos][1]
			EndIf	
			VtRestore(,,,,aTela)
		EndIf
	EndIf
Return nil
/*--------------------------------------------------------------------------
---MntVolume
---Visualiza os todos os volumes informados para a carga/pedido corrente
---felipe.m 03/06/2015
---Esta opção só é habilitada quando o usuário está informando os volumes
--------------------------------------------------------------------------*/
Static Function MntVolume(aVolumes)
Local cKey15 := VtDescKey(15)
Local cKey24 := VtDescKey(24)
Local cKey22 := VtDescKey(22)
Local cKey21 := VtDescKey(21)
Local bkey15 := VTSetKey(15)
Local bkey24 := VTSetKey(24)
Local bkey22 := VTSetKey(22)
Local bkey21 := VTSetKey(21)
Local aTela  := VTSave()
Local nI     := 0
Local aItens := {}

	For nI := 1 To Len(aVolumes)
		aAdd(aItens,{aVolumes[nI]})
	Next nI
	
	VTaBrowse(2,0,VTMaxRow(),VTMaxCol(),{Padr(STR0094,VTMaxCol())},aItens,{VTMaxCol()},,1) // Consulta Volumes
		
	VTSetKey(15,bKey15, cKey15)
	VTSetKey(24,bKey24, cKey24)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(21,bKey21, cKey21)
	// Restaura Tecla
	VtRestore(,,,,aTela)
Return .T.
/*--------------------------------------------------------------------------
---EstVolume
---Estorna o volume informado
---felipe.m 03/06/2015
---Esta opção só é habilitada quando o usuário está informando os volumes
--------------------------------------------------------------------------*/
Static Function EstVolume(aVolumes,nPos)
Local cKey15 := VtDescKey(15)
Local cKey24 := VtDescKey(24)
Local cKey22 := VtDescKey(22)
Local cKey21 := VtDescKey(21)
Local bkey15 := VTSetKey(15)
Local bkey24 := VTSetKey(24)
Local bkey22 := VTSetKey(22)
Local bkey21 := VTSetKey(21)
Local aTela  := VTSave()
Local nLin   := 1
Local nDel   := 1
	
	cVolume := Space(TamSx3("DCU_CODVOL")[1])
	WMSVTCabec(STR0070, .F., .F., .T.) // Estorno Volume
	@ ++nLin,00 VTSay PadR(STR0065+":", VTMaxCol()) // Endereco:
	@ ++nLin,00 VTSay PadR(aTransf[nPos][1], VTMaxCol()) // DOCAAUX
	@ ++nLin,00 VTSay PadR(STR0062+": ", VTMaxCol()) // Volume
	@ ++nLin,00 VTGet cVolume Valid ValidVol(aVolumes,cVolume,@nDel)
	VTRead()
	
	If VtLastKey() != 27
		If nDel > 0
			aDel(aVolumes,nDel)
			aSize(aVolumes,Len(aVolumes)-1)
		EndIf
	EndIf

	VTSetKey(15,bKey15, cKey15)
	VTSetKey(24,bKey24, cKey24)
	VTSetKey(22,bKey22, cKey22)
	VTSetKey(21,bKey21, cKey21)
	// Restaura Tecla
	VtRestore(,,,,aTela)
Return .T.
/*-------------------------------------------------------------------------
---ValidVol
---Utilizada para validar se o volume é válido e está na lista do que foi informado
---felipe.m 03/06/2015
-------------------------------------------------------------------------*/
Static Function ValidVol(aVolumes,cVolume,nDel)
Local lRet := .T.
	If !Empty(cVolume) .And. (nDel := aScan(aVolumes,{|x| x == cVolume})) == 0
		VtAlert(STR0095,STR0002,.T.,4000,3) // Volume invalido!
		VtKeyboard(Chr(20))
		lRet := .F.
	EndIf
Return lRet


//-----------------------------------------
/*/{Protheus.doc} 
Valida se foi criado um embarque baseado na transferencia
@author Equipe WMS
@since 21/10/2022
/*/
//-----------------------------------------
Function WmsEmbD00(nOper,cCarga,cPedido,cEstVol,cNota,cLocal,cEndereco)
	Local aArea := Nil
	Local cAliD0ZEmb := Nil
	Local lRet    := .T.
	Local cMsg   := ""
	Local cWhereLoc := "%"
	Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
	Local lWMSAltDca:= SuperGetMV('MV_WMSALDC', .F., .F.) //Permite alterar DOCA no enderecamento

	If !lWMSAltDca
		Return .T. 
	EndIf

	aArea := GetArea()
	cAliD0ZEmb := GetNextAlias()
	If !Empty(cCarga)
		cWhereLoc += " AND SC9.C9_CARGA   ='"+cCarga+"'"
	EndIf
	If !Empty(cEstVol)
		cWhereLoc += " AND D00.D00_CODVOL ='"+cEstVol+"'"
	EndIf
	If !Empty(cPedido)
		cWhereLoc += " AND D00.D00_PEDIDO ='"+cPedido+"'"
	EndIf
	If !Empty(cNota)
		cWhereLoc += " AND SC9.C9_NFISCAL ='"+cNota+"'"
	EndIf
	If lD00Local .And. !Empty(cLocal)
		cWhereLoc += " AND D00.D00_LOCDOC ='"+cLocal+"'"
	EndIf
	If !Empty(cEndereco)
		cWhereLoc += " AND D00.D00_CODDOC ='"+cEndereco+"'"
	EndIf
	If lD00Local 
		cWhereLoc += " AND D00.D00_CODDOC = D0Z.D0Z_ENDER AND D00.D00_LOCDOC = D0Z.D0Z_LOCAL "
	EndIf

	cWhereLoc += "%"

	BeginSql Alias cAliD0ZEmb
		SELECT D0X.D0X_EMBARQ
			FROM %Table:D00% D00
				INNER JOIN %Table:SC9% SC9 
						ON (SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_PEDIDO = D00.D00_PEDIDO
						AND SC9.C9_CARGA = D00.D00_CARGA
						AND SC9.%NotDel%)
				LEFT JOIN %Table:DCV% DCV 
						ON (DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
						AND DCV.DCV_ITEM = SC9.C9_ITEM
						AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
						AND DCV.DCV_CODVOL = D00.D00_CODVOL
						AND DCV.%NotDel%)
				LEFT JOIN %Table:SD2% SD2 
						ON (SD2.D2_FILIAL = %xFilial:SD2%
						AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
						AND SD2.D2_ITEMPV = SC9.C9_ITEM
						AND SD2.D2_DOC = SC9.C9_NFISCAL
						AND SD2.D2_SERIE = SC9.C9_SERIENF
						AND SD2.%NotDel%)
				INNER JOIN %Table:D0Z% D0Z
						ON(D0Z.D0Z_FILIAL = %xFilial:D0Z%
						AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
						AND D0Z.D0Z_ITEM  = SC9.C9_ITEM
						AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
						AND D0Z.%NotDel% )
				INNER JOIN %Table:D0X% D0X
						ON(D0X.D0X_FILIAL = %xFilial:D0X%
						AND D0X.D0X_EMBARQ = D0Z.D0Z_EMBARQ
						AND D0X.%NotDel%)
							WHERE D00.D00_FILIAL = %xFilial:D00%
								%Exp:cWhereLoc%
								AND D00.%NotDel%
	EndSql
	If (cAliD0ZEmb)->(!Eof())
		If nOper == 1
			cMsg := STR0100 + (cAliD0ZEmb)->D0X_EMBARQ //"O registro consta no embarque: "
			If !Empty(cCarga)
				cMsg += STR0101 + cCarga+", " //" Carga:"
			EndIf
			If !Empty(cPedido)
				cMsg += STR0102 + cPedido+", " //" Pedido:"
			EndIf
			If !Empty(cEstVol)
				cMsg += STR0101 + Alltrim(cEstVol)+", " //" Volume:"
			EndIf
			If !Empty(cNota)
				cMsg += STR0101 + Alltrim(cNota)+", " //" Nota:"
			EndIf
			If !Empty(cEndereco)
				cMsg += STR0101 + Alltrim(cEndereco)+"." //" Endereco:"
			EndIf
		ElseIf nOper == 2
			cMsg := STR0106 + (cAliD0ZEmb)->D0X_EMBARQ + STR0107 //"O embarque "" foi efetivado pelo WMSV104, favor utilizar a rotina de Monitor de Embarque para estorno (WMSA113)."
		EndIf
		lRet := .F.
		WmsMessage(cMsg,WMSV10130)
	EndIf
	(cAliD0ZEmb)->(DbCloseArea())
	RestArea(aArea)
Return lRet

//-----------------------------------------
/*/{Protheus.doc} 
Nao permite misturar doca para o mesmo pedido
@author Equipe WMS
@since 21/10/2022
/*/
//-----------------------------------------
Function WmsVld2D00(nTipo,cCarga,cPedido,cNota,cLocal,cEndOk)
	Local 	aArea := GetArea()
	Local cAliasD00 := GetNextAlias()
	Local cQuery := ""
	Local lRet := .T.
	Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
	Local cMsg := ""

	cQuery := "SELECT D00_PEDIDO,"
	If lD00Local
		cQuery += "D00_LOCDOC,"
	EndIf
	cQuery += "D00_CODDOC "
	cQuery +=  " FROM "+RetSqlName('D00')+" D00"
	If !Empty(cNota)
		cQuery += " INNER JOIN "+RetSqlName('SD2')+" SD2"
		cQuery += 	" ON (SD2.D2_FILIAL = '"+xFilial('SD2')+"'"
		cQuery += 	" AND SD2.D2_DOC = '"+cNota+"'"
		cQuery += 	" AND SD2.D2_PEDIDO = D00.D00_PEDIDO
		cQuery +=  	" AND SD2.D_E_L_E_T_ = ' ')"
	EndIf
	cQuery += " WHERE D00_FILIAL = '"+xFilial('D00')+"'"

	If nTipo == 1 
		cQuery += " AND D00.D00_CARGA  = '"+cCarga+"'"
	Else
		If !Empty(cCarga)
			cQuery += " AND D00.D00_CARGA  = '"+cCarga+"'"
		EndIf
		cQuery +=   " AND D00.D00_PEDIDO = '"+cPedido+"'"
	EndIf	
	If lD00Local
		cQuery +=   " AND ((D00.D00_LOCDOC <> ' ' AND D00.D00_LOCDOC <> '"+cLocal+"')"
	EndIf
	cQuery +=   " OR (D00.D00_CODDOC <> ' ' AND D00.D00_CODDOC <> '"+cEndOk+"'))"
	cQuery +=   " AND D00.D00_OPEEMB = ' '"
	cQuery +=   " AND D00.D00_DATEMB = ' '"
	cQuery +=   " AND D00.D00_HOREMB = ' '"
	cQuery +=   " AND D00.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasD00,.F.,.T.)
	If (cAliasD00)->(!Eof())
		If nTipo == 1 
			cMsg := STR0108 //"A carga já possui transf para "
			If lD00Local
				cMsg += (cAliasD00)->D00_LOCDOC+"/"
			EndIf
			cMsg += Alltrim((cAliasD00)->D00_CODDOC)+"."
			WmsMessage(cMsg,WMSV10132)
		Else
			cMsg := STR0109  //"O pedido já possui transf para "
			If lD00Local
				cMsg += (cAliasD00)->D00_LOCDOC+"/"
			EndIf
			cMsg += Alltrim((cAliasD00)->D00_CODDOC)+"."
			WmsMessage(cMsg,WMSV10133)
		EndIf
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet


//-----------------------------------------
/*/{Protheus.doc} 
@param lExiste = .T., se existe transferencia, obtem local e endereco
@param lExiste = .F., valida se existe transferencia box doca para a chave informada
@author Equipe WMS
@since 21/10/2022
/*/
//-----------------------------------------
Function WmsBoxDoca(lExiste,nTipo,cPedido, cItem, cSequen, cProduto, cNota, cCarga, cEstVol, cLocal, cEndereco, cLote, cEmbarque,nQtdEmb)
	Local aArea := Nil
	Local cAliD00Upd := Nil
	Local lWMSAltDca:= SuperGetMV('MV_WMSALDC', .F., .F.) //Permite alterar DOCA no enderecamento
	Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
	Local lRet := IIF(lExiste,.F.,.T.) 

	If !lWMSAltDca
		Return .F.
	EndIf
	
	aArea := GetArea()	
	cAliD00Upd := GetNextAlias()

	cQuery := " SELECT D00.R_E_C_N_O_ RECNOD00,"+IIF(lD00Local,"D00.D00_LOCDOC,",)+" D00.D00_CODDOC"
	cQuery +=  	" FROM "+RetSqlName('D00')+" D00"
	cQuery +=  		" INNER JOIN "+RetSqlName('SC9')+" SC9 "
	cQuery +=  			" ON (SC9.C9_FILIAL = '"+xFilial('SC9')+"'"
	If !Empty(cPedido)
		cQuery +=  			" AND SC9.C9_PEDIDO = '"+cPedido+"'"
	EndIf
	If !Empty(cItem)
		cQuery +=  			" AND SC9.C9_ITEM = '"+cItem+"'"
	EndIf
	If !Empty(cSequen)
		cQuery +=  			" AND SC9.C9_SEQUEN = '"+cSequen+"'"
	EndIf
	If !Empty(cProduto)
		cQuery +=  			" AND SC9.C9_PRODUTO = '"+cProduto+"'"
	EndIf
	cQuery +=  			" AND SC9.D_E_L_E_T_ = ' ')"
	cQuery +=  		"LEFT JOIN "+RetSqlName('DCV')+" DCV "
	cQuery +=  			" ON (DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
	cQuery +=  			" AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO"
	cQuery +=  			" AND DCV.DCV_ITEM = SC9.C9_ITEM"
	cQuery +=  			" AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN"
	cQuery +=  			" AND DCV.DCV_CODVOL = D00.D00_CODVOL"
	cQuery +=  			" AND DCV.D_E_L_E_T_ = ' ')"
	cQuery +=  		" LEFT JOIN "+RetSqlName('SD2')+" SD2 "
	cQuery +=  			" ON (SD2.D2_FILIAL = '"+xFilial('SD2')+"'"
	cQuery +=  			" AND SD2.D2_PEDIDO = SC9.C9_PEDIDO"
	cQuery +=  			" AND SD2.D2_ITEMPV = SC9.C9_ITEM"
	cQuery +=  			" AND SD2.D2_DOC = SC9.C9_NFISCAL"
	cQuery +=  			" AND SD2.D2_SERIE = SC9.C9_SERIENF"
	cQuery +=  			" AND SD2.D_E_L_E_T_ = ' ')"
	If !Empty(cEmbarque)
		cQuery +=  	" INNER JOIN "+RetSqlName('D0Z')+" D0Z  ON D0Z.D0Z_FILIAL = '"+xFilial('D0Z')+"'"
		cQuery +=  		" AND D0Z.D0Z_CARGA = SC9.C9_CARGA "
		cQuery +=  		" AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO "
		cQuery +=  		" AND D0Z.D0Z_ITEM = SC9.C9_ITEM "
		cQuery +=  		" AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN "
		cQuery +=  		" AND D0Z.D_E_L_E_T_= ' ' "
	EndIf

	cQuery +=  		" WHERE SC9.C9_PEDIDO = D00.D00_PEDIDO"
	cQuery +=  			" AND SC9.C9_CARGA = D00.D00_CARGA "
	If !Empty(cEmbarque)
		cQuery +=  			" AND D0Z.D0Z_EMBARQ = D00.D00_EMBARQ "
	EndIf
	cQuery +=  			" AND D00.D_E_L_E_T_= ' ' "
	If !Empty(cEmbarque)
		cQuery +=  			" AND D0Z.D0Z_EMBARQ = '"+cEmbarque+"'"	
		cQuery +=  			" AND D0Z.D0Z_QTDORI <> D0Z.D0Z_QTDEMB"
  		cQuery +=  			" AND (D0Z.D0Z_QTDEMB + "+CValToChar(nQtdEmb)+") <= D0Z.D0Z_QTDORI"
		cQuery +=  			" AND D0Z.D0Z_PRODUT = '"+cProduto+"'"	
  		cQuery +=  			" AND D0Z.D0Z_LOTECT = '"+cLote+"'"	
	EndIf
	If Empty(cEstVol)
		If nTipo == 1 
			cQuery += " AND D00.D00_CARGA  = '"+cCarga+"'"
		EndIf	
	Else
		cQuery +=   " AND D00.D00_CODVOL = '"+cEstVol+"'"
	EndIf
	If lD00Local .And. !Empty(cLocal) 
		cQuery +=   " AND D00.D00_LOCDOC = '"+cLocal+"'"
	EndIf
	If !Empty(cEndereco)
		cQuery +=   " AND D00.D00_CODDOC = '"+cEndereco+"'"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliD00Upd,.F.,.T.)	
	If !lExiste .And. (cAliD00Upd)->(Eof())
		WmsMessage(STR0110 + cLocal+"/"+cEndereco+".",WMSV10131) //"Transf. box/doca nao encontrada para "
		lRet := .F.
	EndIf
	If lExiste .And. !(cAliD00Upd)->(Eof())
		cLocal :=    (cAliD00Upd)->D00_LOCDOC
		cEndereco := (cAliD00Upd)->D00_CODDOC
		lRet := .T.
	EndIf
	(cAliD00Upd)->(DbCloseArea())
	RestArea(aArea)
Return lRet
