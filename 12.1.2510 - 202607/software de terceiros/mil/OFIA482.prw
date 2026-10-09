//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#Include "TOTVS.CH"
#Include "OFIA482.CH"

Static lGerLog := ("OFIA482" $ GetNewPar("MV_MILDBG", "NAO"))

/*/{Protheus.doc} OFIA482

@author Renato Vinicius
@since 06/10/2022
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OFIA482( cAprTela, cNumPesq, cGruIte, cCodIte )

	Local aSize		:= FWGetDialogSize( oMainWnd )

	Local nResOrc	:= 0
	Local nResOs	:= 0
	Local nResAte	:= 0

	// Permite reserva de peça para atendimento de veículo (VEIXA018) - Caso Verdadeiro será apresetando a tela com o historico.
	Local lPecAtend := FindFunction("VX0020277_permite_peca_atendimento") .AND. VX0020277_permite_peca_atendimento() 

	Default cAprTela:= "3"
	Default cNumPesq:= ""
	Default cGruIte := ""
	Default cCodIte := ""

	Private oDlgWA	:= Nil

	If cAprTela == "1"
		nResOrc := aSize[3]
	ElseIf cAprTela == "2"
		nResOs  := aSize[3]
	Else
		if lPecAtend
			nResOrc := aSize[3] * 0.33 
			nResOs  := aSize[3] * 0.33 
			nResAte := aSize[3] - (nResOrc + nResOs)
		Else
			nResOrc := aSize[3] * 0.5 // 60% da tela é para o Browse de Pedido
			nResOs  := aSize[3] - nResOrc
		EndIf
	Endif

	oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Painel de Reservas"

		oWorkArea := FWUIWorkArea():New( oDlgWA )

		If nResOrc > 0
			oWorkArea:CreateHorizontalBox( "LINE01", nResOrc, .t. )
			oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )
		Endif

		If nResOs > 0
			oWorkArea:CreateHorizontalBox( "LINE02", nResOs , .t. )
			oWorkArea:SetBoxCols( "LINE02", { "WDGT02" } )
		EndIf

		If nResAte > 0
			oWorkArea:CreateHorizontalBox( "LINE03", nResAte , .t. )
			oWorkArea:SetBoxCols( "LINE03", { "WDGT03" } )
		EndIf

		oWorkArea:Activate()

		cNomFilter := STR0002 // "Orçamento "

		If cAprTela == "3" .or. cAprTela == "1"

			cFiltro := "@"

			If !Empty(cNumPesq)
				cFiltro += "VB2_NUMORC = '" + cNumPesq + "' "
			EndIf
			
			If !Empty(cGruIte)
				If !Empty(cNumPesq)
					cFiltro += " AND "
				EndIf
				cFiltro += "VB2_GRUITE = '" + cGruIte + "' AND VB2_CODITE = '" + cCodIte + "'"
			EndIf

			oBrwVB2 := FwMBrowse():New()
			oBrwVB2:SetOwner(oWorkArea:GetPanel( "WDGT01" ))
			oBrwVB2:SetDescription( STR0003 ) //"Reservas de Orçamento"
			oBrwVB2:SetAlias('VB2')
			oBrwVB2:SetMenuDef( '' )
			oBrwVB2:AddButton( STR0004 , { || OA4820405_VisualizaReservaOrcamento() } ) //"Visualizar"

			if Len(cFiltro) > 1
				oBrwVB2:AddFilter( cNomFilter + cNumPesq , cFiltro,.t.,.t.,) // "Orçamento "
			EndIf

			oBrwVB2:lOptionReport := .f.
			oBrwVB2:ForceQuitButton()
			oBrwVB2:DisableDetails()
			oBrwVB2:Activate()

		EndIf

		If cAprTela == "3" .or. cAprTela == "2"

			cFiltro := "@"

			If !Empty(cNumPesq)
				cFiltro += "VB3_NUMOSV = '" + cNumPesq + "' "
			EndIf
			
			If !Empty(cGruIte)
				If !Empty(cNumPesq)
					cFiltro += " AND "
				EndIf
				cFiltro += "VB3_GRUITE = '" + cGruIte + "' AND VB3_CODITE = '" + cCodIte + "'"
			EndIf

			oBrwVB3 := FwMBrowse():New()
			oBrwVB3:SetOwner(oWorkArea:GetPanel( "WDGT02" ))
			oBrwVB3:SetDescription( STR0005 ) //"Reservas de Oficina"
			oBrwVB3:SetMenuDef( '' )
			oBrwVB3:AddButton( STR0004 , { || OA4820415_VisualizaReservaOficina() } ) //"Visualizar"

			if Len(cFiltro) > 1
				oBrwVB3:AddFilter( cNomFilter , cFiltro,.t.,.t.,) // "Orçamento "
			EndIf

			oBrwVB3:SetAlias('VB3')
			oBrwVB3:lOptionReport := .f.
			oBrwVB3:DisableDetails()
			oBrwVB3:Activate()

		EndIf

		If cAprTela == "3" .AND. lPecAtend

			cFiltro := "@"

			If !Empty(cNumPesq)
				cFiltro += "VW8_NUMTRA = '" + cNumPesq + "' "
			EndIf
			
			If !Empty(cGruIte)
				If !Empty(cNumPesq)
					cFiltro += " AND "
				EndIf
				cFiltro += "VW8_GRUITE = '" + cGruIte + "' AND VW8_CODITE = '" + cCodIte + "'"
			EndIf

			oBrwVW8 := FwMBrowse():New()
			oBrwVW8:SetOwner(oWorkArea:GetPanel( "WDGT03" ))
			oBrwVW8:SetDescription(STR0018) //"Reservas no Atendimento Modelo 2"
			oBrwVW8:SetMenuDef( '' )
			oBrwVW8:AddButton( STR0004 , { || OA4820487_VisualizaReservaAtendimento() } ) //"Visualizar"
			if Len(cFiltro) > 1
				oBrwVW8:AddFilter( cNomFilter , cFiltro,.t.,.t.,) // "Atendimento "
			EndIf

			oBrwVW8:SetAlias('VW8')
			oBrwVW8:lOptionReport := .f.
			oBrwVW8:DisableDetails()
			oBrwVW8:Activate()

		EndIf


	oDlgWA:Activate( , , , , , , ) //ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} MenuDef
	Função para fazer o processamento da reserva e desreserva do item com gravação de histórico

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.VEIA480' OPERATION 2 ACCESS 0 //"Visualizar"

Return aRotina

/*/{Protheus.doc} OA4820015_ProcessaReservaItem
	Função para fazer o processamento da reserva e desreserva do item com gravação de histórico

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820015_ProcessaReservaItem(cOrigem,nRecNo,cTpRes,cOperacao,aIteMov,cTipo,cTpConf,lSugCom,cTpMOrc,lConDel,cMsgRet,lDisarm,lArmProd)

	Local cRetorno  := ""
	Local aItensNew := {}
	Local aHistIte  := {}
	Local aHistCon  := {}
	Local aHistOrc  := {}
	Local aHistPed  := {}
	Local aHistAte  := {}
	Local cDocumento:= ""
	Local lProcItem := .f.
	Local nI        := 0
	Local aRecVS3   := {}
	Local aRecVW3   := {}
	Local aRecMov   := {}
	Local aArea     := sGetArea()
	Local oModel    := FwModelActive()
	Local cSolucao  := ""
	Local lBkpAlt := IIf(Type("ALTERA") != "U",ALTERA,.f.)
	Local lBkpInc := IIf(Type("INCLUI") != "U",INCLUI,.f.)
	Local cPulaLinha := chr(13) + chr(10)

	Default cOrigem   := ""
	Default nRecNo    := 0
	Default cTpRes    := "A"
	Default cOperacao := ""
	Default aIteMov   := {}
	Default cTipo     := ""
	Default cTpConf   := ""
	Default cTpMOrc   := ""
	Default lConDel   := .t.
	Default lDisarm   := .t.
	Default lArmProd  := .f.
	
	Private lMsErroAuto := .f.
	Private cMsgLog		:= ""
	Private cCodVQL 	:= ""
	Private oLogger 	:= DMS_Logger():New()

	lProcItem := Len(aIteMov) > 0

	If (!Empty(cOrigem) .and. nRecNo > 0) .or. lProcItem

		aArea := sGetArea(aArea,"VS1")
		aArea := sGetArea(aArea,"VS3")
		aArea := sGetArea(aArea,"VO1")
		aArea := sGetArea(aArea,"VSJ")
		aArea := sGetArea(	aArea,"VO3")
		if FWAliasInDic("VW3")
			aArea := sGetArea(aArea,"VW3")
		EndIf

		cMsgLog := oLogger:PilhaChamada()

		cMsgLog += "Parametros da Rotina " + cPulaLinha
		cMsgLog += "cOrigem: " + cOrigem + cPulaLinha
		cMsgLog += "nRecNo: " + cValToChar(nRecNo) + cPulaLinha
		cMsgLog += "cTpRes: " + cTpRes + cPulaLinha
		cMsgLog += "cOperacao: " + cOperacao + cPulaLinha
		cMsgLog += "aIteMov: " + cValToChar(Len(aIteMov)) + cPulaLinha
		cMsgLog += "cTipo: " + cTipo + cPulaLinha
		cMsgLog += "cTpConf: " + cTpConf + cPulaLinha
		cMsgLog += "lSugCom: " + cValtoChar(lSugCom) + cPulaLinha
		cMsgLog += "cTpMOrc: " + cTpMOrc + cPulaLinha
		cMsgLog += "lConDel: " + cValToChar(lConDel) + cPulaLinha
		cMsgLog += "lDisarm: " + cValToChar(lDisarm) + cPulaLinha
		cMsgLog += "lArmProd: " + cValToChar(lArmProd) + cPulaLinha

		If cOrigem == "OR" .or. cOrigem == "PD"

			DbSelectArea("VS1")
			DbGoTo(nRecNo)

			/*If !OA4820155_ValidaReservaOrcamento(VS1->VS1_NUMORC,@cRetorno)
				sRestArea( aArea )
				FWModelActive(oModel)
				Return cRetorno
			EndIf*/

			//+------------------------------------------------------------+
			//| PE para desviar e não fazer a reserva, pois há especifícos |
			//| que podem fazer a reserva do produto on-line.              |
			//+------------------------------------------------------------+
			if ExistBlock("OX001RES")
				cDocumento := ExecBlock("OX001RES",.F.,.F.)
			Endif

			If !Empty( cDocumento )

				sRestArea( aArea )
				FWModelActive(oModel)

				cMsgLog += "====== Problema ======= "  + cPulaLinha
				cMsgLog += "cDocumento: " + cDocumento + cPulaLinha

				OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VS1->VS1_NUMORC, .t. )

				Return( cDocumento )

			Endif

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			If lProcItem //Processamento por item

				For nI:= 1 to Len(aIteMov)

					DbSelectArea("VS3")
					DbGoTo(aIteMov[nI,1])

					OA4820145_ProcessaReservaItemBalcao(cOperacao,;
														cTpRes,;
														aIteMov[nI,1],;
														cDocumento,;
														@aItensNew,;
														@aRecVS3,;
														@aHistIte,;
														cTipo,;
														cOrigem,;
														,;
														,;
														lSugCom,;
														,;
														,;
														,;
														,;
														,;
														,;
														@cMsgRet,;
														,;
														,;
														,;
														,;
														,;
														@cMsgLog)

				Next

			Else // Processamento por Orçamento

				cQuery := "SELECT VS3.R_E_C_N_O_ AS VS3RECNO, VS3.D_E_L_E_T_ AS VS3DELET "
				cQuery += "FROM " + RetSqlName("VS3") + " VS3 "
				cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
				cQuery +=	"AND VS3.VS3_NUMORC = '" + VS1->VS1_NUMORC + "' "

				If lConDel
					cQuery +=	"AND VS3.D_E_L_E_T_ = ' ' "
				EndIf

				TcQuery cQuery New Alias "TMPVS3"

				While !TMPVS3->(Eof())

					DbSelectArea("VS3")
					DbGoTo(TMPVS3->(VS3RECNO))

					OA4820145_ProcessaReservaItemBalcao((If(Empty(cOperacao),If(Empty(TMPVS3->(VS3DELET)), NiL, "D" ),cOperacao)),;
														cTpRes,;
														TMPVS3->(VS3RECNO),;
														cDocumento,;
														@aItensNew,;
														@aRecVS3,;
														@aHistIte,;
														cTipo,;
														cOrigem,;
														,;
														,;
														lSugCom,;
														,;
														,;
														,;
														,;
														,;
														,;
														@cMsgRet,;
														,;
														,;
														,;
														,;
														,;
														@cMsgLog)

					TMPVS3->(DbSkip())

				EndDo

				TMPVS3->(DbCloseArea())
			EndIf

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					DisarmTransaction()

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += cMsgErro + cPulaLinha

					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )

					sRestArea( aArea )

					FWModelActive(oModel)

					Return cRetorno

				EndIf

				If OA4820125_GravaHistoricoMovBalcao(aHistIte)
					OA4820055_GravaDadosOrcamento(VS1->VS1_NUMORC,cTpRes,aRecVS3,cDocumento,,@cMsgLog)
				Else
					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += "OA4820125_GravaHistoricoMovBalcao" + cPulaLinha
					cMsgLog += MostraErro("\") + cPulaLinha
					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )
					DisarmTransaction()
					sRestArea( aArea )
					FWModelActive(oModel)
					Return cRetorno
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VS1->VS1_NUMORC, .t. )

			DbSelectArea("VS3")
			sRestArea( aArea )

			FWModelActive(oModel)

			If Type("ALTERA") != "U" .and. Type("INCLUI") != "U"
				ALTERA := lBkpAlt
				INCLUI := lBkpInc
			EndIf

			Return cRetorno

		ElseIf cOrigem == "PDOR" // Faturamento Pedido Orçamento

			/*If !OA4820205_ValidaReservaItemOficina(@cRetorno)
				sRestArea( aArea )
				FWModelActive(oModel)
				Return cRetorno
			EndIf*/

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			If lProcItem //Processamento por item

				For nI:= 1 to Len(aIteMov)

					If cOperacao == "T"

						OA4820395_TransfereReserva( cOrigem,;
													cDocumento,;
													@aItensNew,;
													@aRecVS3,;
													@aHistIte,;
													@aHistPed,;
													cTipo,;
													cTpMOrc,;
													aIteMov[nI,1],;
													aIteMov[nI,2],;
													,;
													Subs(GetMv( "MV_MIL0192" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO")),;
													Subs(GetMv( "MV_MIL0177" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO")),;
													@cMsgLog)

					EndIf

				Next

				if Len(aItensNew) > 1

					MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

					If lMsErroAuto

						DisarmTransaction()

						cMsgErro := MostraErro("\")
						If At("A260LOCAL",cMsgErro) > 0
							cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
							cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
							FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
						Else
							FMX_HELP("OA482RES", cMsgErro )
						EndIf

						cMsgLog += "====== Problema ======= "  + cPulaLinha
						cMsgLog += cMsgErro + cPulaLinha

						OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )

						sRestArea( aArea )

						FWModelActive(oModel)
						Return cRetorno

					EndIf

					If OA4820125_GravaHistoricoMovBalcao(aHistIte,,aHistPed)
						OA4820055_GravaDadosOrcamento(,cTpRes,aRecVS3,cDocumento,,@cMsgLog)
					Else
						cMsgLog += "====== Problema ======= "  + cPulaLinha
						cMsgLog += "OA4820125_GravaHistoricoMovBalcao" + cPulaLinha
						cMsgLog += MostraErro("\") + cPulaLinha
						OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )
						DisarmTransaction()
						sRestArea( aArea )
						FWModelActive(oModel)
						Return cRetorno
					EndIf

					cRetorno := cDocumento
				Else
					cRetorno := "NA"
				EndIf

				OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VS1->VS1_NUMORC, .t. )

				sRestArea( aArea )

				FWModelActive(oModel)
				Return cRetorno

			EndIf

		ElseIf cOrigem == "CO" // Conferência de Itens

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			cQuery := "SELECT VS3.R_E_C_N_O_ AS VS3RECNO "
			cQuery += "FROM " + RetSqlName("VS3") + " VS3 "
			cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
			cQuery +=	"AND VS3.VS3_NUMORC = '" + VS1->VS1_NUMORC + "' "
			cQuery +=	"AND VS3.D_E_L_E_T_ = ' ' "

			TcQuery cQuery New Alias "TMPVS3"

			While !TMPVS3->(Eof())

				DbSelectArea("VS3")
				DbGoTo(TMPVS3->(VS3RECNO))

				OA4820145_ProcessaReservaItemBalcao(cOperacao,;
													cTpRes,;
													TMPVS3->(VS3RECNO),;
													cDocumento,;
													@aItensNew,;
													@aRecVS3,;
													@aHistIte,;
													cTipo,;
													cOrigem,;
													@aHistCon,;
													cTpConf,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													,;
													@cMsgLog)

				TMPVS3->(DbSkip())

			EndDo

			TMPVS3->(DbCloseArea())

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					DisarmTransaction()

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += cMsgErro + cPulaLinha

					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )

					sRestArea( aArea )

					FWModelActive(oModel)
					Return cRetorno

				EndIf

				If OA4820125_GravaHistoricoMovBalcao(aHistIte,aHistCon)
					OA4820055_GravaDadosOrcamento(VS1->VS1_NUMORC,cTpRes,aRecVS3,cDocumento,cOrigem,@cMsgLog)
				Else
					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += "OA4820125_GravaHistoricoMovBalcao" + cPulaLinha
					cMsgLog += MostraErro("\") + cPulaLinha
					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )
					DisarmTransaction()
					sRestArea( aArea )
					FWModelActive(oModel)
					Return cRetorno
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VS1->VS1_NUMORC, .t. )

			sRestArea( aArea )

			FWModelActive(oModel)
			Return cRetorno

		ElseIf cOrigem == "SU" .or. cOrigem == "TR" // Sugestão de Compras ou Transferencia entre Filiais

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})
			
			For nI:= 1 to Len(aIteMov)

				DbSelectArea("VS3")
				DbGoTo(aIteMov[nI,1])

				OA4820145_ProcessaReservaItemBalcao(cOperacao,;
													cTpRes,;
													aIteMov[nI,1],;
													cDocumento,;
													@aItensNew,;
													@aRecVS3,;
													@aHistIte,;
													cTipo,;
													cOrigem,;
													,;
													,;
													lSugCom,;
													aIteMov[nI,2],; //Quantidade a considerar
													aIteMov[nI,3],; // Codigo da Sugestão de compra
													aIteMov[nI,4],; // Nota Fiscal de Compra
													aIteMov[nI,5],; // Serie da Nota Fiscal de Compra
													aIteMov[nI,6],; // Fornecedor da Nota Fiscal de Compra
													aIteMov[nI,7],; // Loja do Fornecedor da Nota Fiscal de Compra
													,; //cMsgRet
													,; //cTpMOrc
													,; //nRecVS3Ped
													,; //aHistPed
													,; //cArmDes
													aIteMov[nI,8],;//cArmOri
													@cMsgLog)

			Next

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					DisarmTransaction()

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += cMsgErro + cPulaLinha

					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS3->VS3_NUMORC, .t. )

					sRestArea( aArea )

					FWModelActive(oModel)
					Return cRetorno

				EndIf

				If OA4820125_GravaHistoricoMovBalcao(aHistIte)
					OA4820055_GravaDadosOrcamento(VS1->VS1_NUMORC,cTpRes,aRecVS3,cDocumento,cOrigem,@cMsgLog)
				Else
					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += "OA4820125_GravaHistoricoMovBalcao" + cPulaLinha
					cMsgLog += MostraErro("\") + cPulaLinha
					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VS1->VS1_NUMORC, .t. )
					DisarmTransaction()
					sRestArea( aArea )
					FWModelActive(oModel)
					Return cRetorno
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VS1->VS1_NUMORC, .t. )

			sRestArea( aArea )

			FWModelActive(oModel)
			Return cRetorno

		ElseIf cOrigem == "LJ" // Loja

			cDocumento := ""

			If lProcItem //Processamento por item

				For nI:= 1 to Len(aIteMov)

					DbSelectArea("VS3")
					DbGoTo(aIteMov[nI,1])

					aAdd(aHistIte, aClone(OA4820115_AddArrayItemHistoricoReservaBalcao(cOperacao,cDocumento,cTipo,"",cOrigem)))

				Next

			Else

				cQuery := "SELECT VS3.R_E_C_N_O_ AS VS3RECNO "
				cQuery += "FROM " + RetSqlName("VS3") + " VS3 "
				cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
				cQuery +=	"AND VS3.VS3_NUMORC = '" + VS1->VS1_NUMORC + "' "
				cQuery +=	"AND VS3.VS3_QTDRES > 0 "
				cQuery +=	"AND VS3.D_E_L_E_T_ = ' ' "

				TcQuery cQuery New Alias "TMPVS3"

				While !TMPVS3->(Eof())

					DbSelectArea("VS3")
					DbGoTo(TMPVS3->(VS3RECNO))

					aAdd(aHistIte, aClone(OA4820115_AddArrayItemHistoricoReservaBalcao(cOperacao,cDocumento,cTipo,"",cOrigem)))

					TMPVS3->(DbSkip())

				EndDo

				TMPVS3->(DbCloseArea())

			EndIf

			OA4820125_GravaHistoricoMovBalcao(aHistIte)

			FWModelActive(oModel)
			Return cDocumento

		ElseIf cOrigem == "EX" // Exportação Orçamento Oficina

			/*If !OA4820205_ValidaReservaItemOficina(@cRetorno)
				sRestArea( aArea )
				FWModelActive(oModel)
				Return cRetorno
			EndIf*/

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			If lProcItem //Processamento por item

				For nI:= 1 to Len(aIteMov)

					DbSelectArea("VSJ")
					DbGoTo(aIteMov[nI,1])

					DbSelectArea("VS3")
					DbGoTo(aIteMov[nI,2])

					OA4820215_ProcessaReservaItemOficina(cOperacao,;
														cTpRes,;
														VSJ->(Recno()),;
														VS3->(Recno()),;
														cDocumento,;
														@aItensNew,;
														@aRecMov,;
														@aHistIte,;
														@aHistOrc,;
														cTipo,;
														cOrigem,;
														,;
														,;
														lSugCom,;
														,;
														,;
														,;
														aIteMov[nI,3],; // Local de Origem
														cTpMOrc,;
														,;
														,;
														,;
														,;
														,;
														@cMsgLog)

				Next

				if Len(aItensNew) > 1

					MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

					If lMsErroAuto

						DisarmTransaction()

						cMsgErro := MostraErro("\")
						If At("A260LOCAL",cMsgErro) > 0
							cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
							cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
							FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
						Else
							FMX_HELP("OA482RES", cMsgErro )
						EndIf

						cMsgLog += "====== Problema ======= "  + cPulaLinha
						cMsgLog += cMsgErro + cPulaLinha

						OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )

						sRestArea( aArea )

						
						Break

					EndIf

					If OA4820255_GravaHistoricoMovOficina(aHistIte,,aHistOrc)
						OA4820265_GravaDadosOrdemServico(aRecMov,cTpRes,cDocumento,cOrigem,@cMsgLog)
					Else
						cMsgLog += "====== Problema ======= "  + cPulaLinha
						cMsgLog += "OA4820255_GravaHistoricoMovOficina" + cPulaLinha
						cMsgLog += MostraErro("\") + cPulaLinha
						OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )
						DisarmTransaction()
						sRestArea( aArea )
						Break
					EndIf

					cRetorno := cDocumento
				Else
					cRetorno := "NA"
				EndIf

				OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VSJ->VSJ_NUMOSV, .t. )

				sRestArea( aArea )

				FWModelActive(oModel)
				Return cRetorno

			EndIf
		
		ElseIf cOrigem == "OF" // Oficina

			/*If !OA4820205_ValidaReservaItemOficina(@cRetorno)
				sRestArea( aArea )
				FWModelActive(oModel)
				Return cRetorno
			EndIf*/

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			If lProcItem //Processamento por item

				For nI:= 1 to Len(aIteMov)

					DbSelectArea("VSJ")
					DbGoTo(aIteMov[nI,1]) // Recno VSJ

					OA4820215_ProcessaReservaItemOficina(cOperacao,;
														cTpRes,;
														VSJ->(Recno()),;
														,;
														cDocumento,;
														@aItensNew,;
														@aRecMov,;
														@aHistIte,;
														@aHistOrc,;
														cTipo,;
														cOrigem,;
														,;
														,;
														lSugCom,;
														aIteMov[nI,2],; // Quantidade
														,;
														aIteMov[nI,3],; // Armazem Destino
														,;
														,;
														,;
														,;
														,;
														,;
														lArmProd,; // Utiliza Armazem do Item ?
														@cMsgLog )

				Next
			
			Else

				cQuery := "SELECT VSJ.R_E_C_N_O_ AS VSJRECNO "
				cQuery += "FROM " + RetSqlName("VSJ") + " VSJ "
				cQuery += "WHERE VSJ.VSJ_FILIAL = '" + xFilial("VSJ") + "' "
				cQuery +=	"AND VSJ.VSJ_NUMOSV = '" + VO1->VO1_NUMOSV + "' "
				cQuery +=	"AND VSJ.D_E_L_E_T_ = ' ' "

				TcQuery cQuery New Alias "TMPVSJ"

				While !TMPVSJ->(Eof())

					DbSelectArea("VSJ")
					DbGoTo(TMPVSJ->(VSJRECNO))

					OA4820215_ProcessaReservaItemOficina(cOperacao,;
														cTpRes,;
														VSJ->(Recno()),;
														,;
														cDocumento,;
														@aItensNew,;
														@aRecMov,;
														@aHistIte,;
														@aHistOrc,;
														cTipo,;
														cOrigem,;
														,;
														,;
														lSugCom,;
														,;
														,;
														,;
														,;
														,;
														,;
														,;
														,;
														,;
														lArmProd,; // Utiliza Armazem do Item ?
														@cMsgLog )

					TMPVSJ->(DbSkip())

				EndDo

				TMPVSJ->(DbCloseArea())

			EndIf

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					If lDisarm
						DisarmTransaction()
					EndIf

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += cMsgErro + cPulaLinha

					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )

					sRestArea( aArea )

					FWModelActive(oModel)
					Return cRetorno

				EndIf

				If OA4820255_GravaHistoricoMovOficina(aHistIte,,aHistOrc)
					OA4820265_GravaDadosOrdemServico(aRecMov,cTpRes,cDocumento,cOrigem,@cMsgLog)
				Else
					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += "OA4820255_GravaHistoricoMovOficina" + cPulaLinha
					cMsgLog += MostraErro("\") + cPulaLinha
					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )
					If lDisarm
						DisarmTransaction()
					EndIf
					sRestArea( aArea )
					FWModelActive(oModel)
					Return cRetorno
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VSJ->VSJ_NUMOSV, .t. )

			DBSelectArea("VO1")
			sRestArea( aArea )

			FWModelActive(oModel)
			Return cRetorno

		ElseIf cOrigem == "COOF" // Conferência de Itens de Oficina

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			For nI := 1 to Len(aIteMov)

				cQuery := "SELECT R_E_C_N_O_ "
				cQuery += " FROM " + RetSqlName("VSJ")
				cQuery += " WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "' "
				cQuery += "   AND VSJ_CODIGO = '" + aIteMov[nI,1] + "' "
				cQuery += "   AND D_E_L_E_T_ = ' '"

				DbSelectArea("VSJ")
				DbGoTo(FM_SQL(cQuery))

				OA4820215_ProcessaReservaItemOficina(cOperacao,;
														cTpRes,;
														VSJ->(Recno()),;
														,;
														cDocumento,;
														@aItensNew,;
														@aRecMov,;
														@aHistIte,;
														@aHistOrc,;
														cTipo,;
														cOrigem,;
														@aHistCon,;
														cTpConf,;
														lSugCom,;
														aIteMov[nI,3],;
														,;
														,;
														,;
														,;
														,;
														,;
														,;
														,;
														,;
														@cMsgLog)

			Next

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					DisarmTransaction()

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += cMsgErro + cPulaLinha

					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )

					sRestArea( aArea )

					FWModelActive(oModel)
					Return cRetorno

				EndIf

				If OA4820255_GravaHistoricoMovOficina(aHistIte,aHistCon)
					OA4820265_GravaDadosOrdemServico(aRecMov,cTpRes,cDocumento,cOrigem,@cMsgLog)
				Else
					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += "OA4820255_GravaHistoricoMovOficina" + cPulaLinha
					cMsgLog += MostraErro("\") + cPulaLinha
					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )
					DisarmTransaction()
					sRestArea( aArea )
					FWModelActive(oModel)
					Return cRetorno
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VSJ->VSJ_NUMOSV, .t. )

			sRestArea( aArea )

			FWModelActive(oModel)
			Return cRetorno

		ElseIf cOrigem == "SUOF" .or. cOrigem == "TROF" // Sugestão de Compras Oficina ou Transferencia entre Filiais Oficina

			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})
			
			For nI:= 1 to Len(aIteMov)

				DbSelectArea("VSJ")
				DbGoTo(aIteMov[nI,1])

				OA4820215_ProcessaReservaItemOficina(cOperacao,;
													cTpRes,;
													VSJ->(Recno()),;
													,;
													cDocumento,;
													@aItensNew,;
													@aRecMov,;
													@aHistIte,;
													@aHistOrc,;
													cTipo,;
													cOrigem,;
													,;
													,;
													lSugCom,;
													aIteMov[nI,2],;
													aIteMov[nI,3],;
													,;
													aIteMov[nI,8],;
													,;
													aIteMov[nI,4],; // Nro Nota Fiscal
													aIteMov[nI,5],; // Serie Nota Fiscal
													aIteMov[nI,6],; // Fornecedor Nota Fiscal
													aIteMov[nI,7],; // Loja Fornecedor Nota Fiscal
													,;
													@cMsgLog)

			Next

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					DisarmTransaction()

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += cMsgErro + cPulaLinha

					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )

					sRestArea( aArea )

					FWModelActive(oModel)
					Return cRetorno

				EndIf

				If OA4820255_GravaHistoricoMovOficina(aHistIte)
					OA4820265_GravaDadosOrdemServico(aRecMov,cTpRes,cDocumento,cOrigem,@cMsgLog)
				Else
					cMsgLog += "====== Problema ======= "  + cPulaLinha
					cMsgLog += "OA4820255_GravaHistoricoMovOficina" + cPulaLinha
					cMsgLog += MostraErro("\") + cPulaLinha
					OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, "E-" + cOrigem, VSJ->VSJ_NUMOSV, .t. )
					DisarmTransaction()
					sRestArea( aArea )
					FWModelActive(oModel)
					Return cRetorno
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, VSJ->VSJ_NUMOSV, .t. )

			sRestArea( aArea )
			
			FWModelActive(oModel)
			Return cRetorno
		ElseIf cOrigem == "AM2" //Reserva na Rotina Atendimento Modelo2 (VEIXA018)
			
			DbSelectArea("VV9")
			VV9->(DbGoTo(nRecNo))
					
			cDocumento  := Criavar("D3_DOC")
			cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
			cDocumento	:= A261RetINV(cDocumento)

			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			aadd (aItensNew,{ cDocumento , dDataBase})

			cQuery := " SELECT VW3.R_E_C_N_O_ AS VW3RECNO, VW3.VW3_QTDITE AS VW3QTDITE"
			cQuery += " FROM " + RetSqlName("VW3") + " VW3 "
			cQuery += " WHERE VW3.VW3_FILIAL = '" + xFilial("VW3") + "' "
			cQuery += " AND VW3.VW3_NUMTRA = '" + VV9->VV9_NUMATE + "' "
			cQuery += " AND VW3.D_E_L_E_T_ = ' ' "

			TcQuery cQuery New Alias "TMPVW3"

			While !TMPVW3->(Eof())

				DbSelectArea("VW3")
				VW3->(DbGoTo(TMPVW3->(VW3RECNO)))

				OA4820447_ProcessaReservaAtendModelo2(cOperacao,;
													   TMPVW3->(VW3RECNO),;
													   cDocumento,;
													   @aItensNew,;
													   @aRecVW3,;
													   @aHistAte,;
													   cTipo,;
													   cOrigem,;
													   TMPVW3->(VW3QTDITE),;
													   ,;
													   ,;
													   @cMsgLog)

				TMPVW3->(DbSkip())

			EndDo

			TMPVW3->(DbCloseArea())

			if Len(aItensNew) > 1

				MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)

				If lMsErroAuto

					DisarmTransaction()

					cMsgErro := MostraErro("\")
					If At("A260LOCAL",cMsgErro) > 0
						cMsgErro := cMsgErro + CRLF + STR0006 //"Um ou mais itens estão sem saldo inicial para o armazém de origem informado."
						cSolucao := STR0007 //"Crie saldo inicial no armazém de origem para estes itens."
						FMX_HELP("A260LOCAL", cMsgErro, cSolucao )
					Else
						FMX_HELP("OA482RES", cMsgErro )
					EndIf

					sRestArea( aArea )

					FWModelActive(oModel)
					Return cRetorno

				EndIf

				If OA4820467_GravaHistoricoMovAtendMod2(aHistAte)
					OA4820477_GravaDadosAtendModelo2(aRecVW3, cDocumento)				
				EndIf

				cRetorno := cDocumento
			Else
				cRetorno := "NA"
			EndIf

			DbSelectArea("VW3")
			sRestArea( aArea )

			FWModelActive(oModel)

			If Type("ALTERA") != "U" .and. Type("INCLUI") != "U"
				ALTERA := lBkpAlt
				INCLUI := lBkpInc
			EndIf

			Return cRetorno

		EndIf

		sRestArea( aArea )

	EndIf
	
	FWModelActive(oModel)
	
Return cRetorno

/*/{Protheus.doc} OA4820025_ValidaReservaItem
	Função para fazer a validação da reserva e desreserva do item com gravação de histórico de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820025_ValidaReservaItemBalcao(nQtdMov,cMsgRet,cTpReqDev,cOrigem)

	Local lRetorno := .t.
	Local lTpFatR := (VS1->(FieldPos("VS1_TPFATR")) > 0 .and. cPaisLoc == "ARG")
	Default cTpReqDev := ""

	SF4->(dbSeek(xFilial("SF4")+VS3->VS3_CODTES))

	If ( cPaisLoc <> "BRA" .and. cTpReqDev == "D" ) .or.;// Volta Reserva
		( ( cOrigem == "SU" .or. cOrigem == "TR" .or. cOrigem == "PD" .or. cOrigem == "OR" ) .and. IIF(lTpFatR ,VS1->VS1_TPFATR == "4",.f. ))// quando for sugestão ou transferencia e entrega futura não irá validar
		If nQtdMov > 0
			Return .t.
		EndIf
	EndIf

	DBSelectArea("VS1")
	DbSetOrder(1)
	DbSeek(xFilial("VS1") + VS3->VS3_NUMORC)
	Do Case
		Case nQtdMov <= 0
			lRetorno := .f.
			cMsgRet := STR0008 + "( "+ cValtoChar(nQtdMov) +" )" //"Quantidade solicitada para reserva é negativa."
		Case SF4->F4_ESTOQUE != "S"
			lRetorno := .f.
			cMsgRet := STR0009 + "( "+ VS3->VS3_CODTES +" )" //"A TES utilizada não movimenta estoque."
		Case Type("Exclui") <> "U" .and. Exclui .and. Empty(VS3->VS3_DOCSDB)
			lRetorno := .f.
			cMsgRet := STR0010 + "( "+ VS3->VS3_GRUITE + " - " + VS3->VS3_CODITE +" )" //"Item sem código de movimentação."
	EndCase

Return lRetorno


/*/{Protheus.doc} OA4820035_AddArrayReservaItem
	Função para fazer a gravação da reserva e desreserva do item com gravação de histórico de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820035_AddArrayReservaItem(cTpReqDev,nQtdMov,cOrigem,lPecDes,cArmDes,cArmOri,lArmProd,cMsgLog,aItensNew)

	Local aDados   := {}
	Local aItemSD3 := {}
	Local oEst     := DMS_Estoque():New()

	Default cTpReqDev:= "R"
	Default nQtdMov:= 0
	Default lPecDes:= .f.
	Default lArmProd:= .f.

	aDados := OA4820045_LevantaDadosMovimentacao(cTpReqDev,nQtdMov,cOrigem,lPecDes,cArmDes,cArmOri,lArmProd,@cMsgLog)

	If Len(aDados) > 0

		If (nPosItem := OA482016K_ItemDuplicadoNaReserva(aItensNew, aDados)) > 0

			aItensNew[nPosItem][16] += aDados[6]

			aItemSD3 := aClone(aItensNew[nPosItem])

		Else

			aItemSD3 := oEst:SetItemSD3(aDados[1]    ,; // Código do Produto
										aDados[2]    ,; // Armazém de Origem
										aDados[3]    ,; // Armazém de Destino
										aDados[4]    ,; // Localização Origem
										aDados[5]    ,; // Localização Destino
										aDados[6]     ) // Qtd a transferir

			aAdd(aItensNew, aClone(aItemSD3))

		Endif

		If ExistBlock('OA482MOVITE')
			aItemSD3 := ExecBlock('OA482MOVITE', .F., .F., { cTpReqDev, cOrigem, lPecDes, lArmProd, aItemSD3 } )
		Endif

	EndIf

Return aItemSD3

/*/{Protheus.doc} OA4820045_LevantaDadosMovimentacao
	Função para fazer a gravação da reserva e desreserva do item com gravação de histórico de Oficina

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820045_LevantaDadosMovimentacao(cTpReqDev,nQtdMov,cOrigem,lPecDes,cArmDes,cArmOri,lArmProd,cMsgLog)

	Local aRetorno := {}
	Local cLocOri  := ""
	Local lReserva := .t.

	Default cTpReqDev:= "R"
	Default nQtdMov:= 0

	If cTpReqDev == "D"
		lReserva := .f.
	EndIf

	If Empty(cArmOri)
		cArmOri := OA4820065_LevantaArmazemOrigem(lReserva,cOrigem,lPecDes,@cMsgLog)
	EndIf

	cLocOri := OA4820085_LevantaLocalizacaoOrigem(lReserva,cOrigem,lPecDes)

	If Empty(cArmDes)
		cArmDes := OA4820075_LevantaArmazemDestino(lReserva,cOrigem,lPecDes,lArmProd,@cMsgLog)
	EndIf

	cLocDes := OA4820095_LevantaLocalizacaoDestino(lReserva,cOrigem,lPecDes)

	cLote    := ""
	cNumLote := ""

	if nQtdMov > 0

		aAdd( aRetorno, SB1->B1_COD ) //Código do Produto
		aAdd( aRetorno, cArmOri     ) // Armazém de Origem
		aAdd( aRetorno, cArmDes     ) // Armazém de Destino
		aAdd( aRetorno, cLocOri     ) // Localização Origem
		aAdd( aRetorno, cLocDes     ) // Localização Destino
		aAdd( aRetorno, nQtdMov     ) // Qtd a transferir

	EndIf

	cMsgLog += " ======== OA4820045_LevantaDadosMovimentacao ============== " + chr(13) + chr(10)

	cMsgLog += " cArmOri: " + cArmOri + chr(13) + chr(10)
	cMsgLog += " cArmDes: " + cArmDes + chr(13) + chr(10)
	cMsgLog += " cLocOri: " + cLocOri + chr(13) + chr(10)
	cMsgLog += " cLocDes: " + cLocDes + chr(13) + chr(10)


Return aRetorno

/*/{Protheus.doc} OA4820035_GravaReservaItemBalcao
	Função para fazer a gravação dos dados no orçamento que foi reservado / desreservado

	@type function
	@author Renato Vinicius de Souza Santos
	@since 10/10/2022
/*/
Function OA4820055_GravaDadosOrcamento(cNumOrc,cTpRes,aRecVS3,cDocumento,cOrigem,cMsgLog)

	Local nI := 0
	Local cOrcRes := "1"
	Local cReserv := "1"
	Local lDevolu := .f.
	Local aOrcmto := {}

	Default cNumOrc := ""

	For nI := 1 to Len(aRecVS3)

		VS3->(DbGoTo(aRecVS3[nI,1]))

		If aScan(aOrcmto,{|x| x == VS3->VS3_NUMORC }) == 0
			aAdd(aOrcmto, VS3->VS3_NUMORC )
		EndIf

		lDevolu := .f.

		If aRecVS3[nI,3] == "D"
			lDevolu := .t.
		EndIf

		lAtuRes := aRecVS3[nI,4]

		DbSelectArea("VS3")
		RecLock("VS3",.f.)

			If lAtuRes
				If lDevolu
					VS3->VS3_QTDRES -= aRecVS3[nI,2]
				Else
					VS3->VS3_QTDRES += aRecVS3[nI,2]
				EndIf

				If VS3->VS3_QTDRES == 0
					VS3->VS3_DOCSDB := ""
					VS3->VS3_RESERV := "0"
				Else
					If VS3->VS3_RESERV == "0"
						VS3->VS3_RESERV := "1"
					EndIf
					VS3->VS3_DOCSDB := cDocumento
				EndIf
			EndIf

			If cOrigem == "SU" .and. VS3->VS3_QTDAGU > 0 // Sugestão de Compra
				VS3->VS3_QTDAGU -= aRecVS3[nI,2]
				If cTpRes == "A" .AND. VS3->(ColumnPos("VS3_QTDATE")) > 0 //Reserva Automatica
					VS3->VS3_QTDATE += aRecVS3[nI,2]
				EndIf
			EndIf

			If cOrigem == "TR" .and. VS3->VS3_QTDTRA > 0 // Transferencia entre Filiais
				VS3->VS3_QTDTRA -= aRecVS3[nI,2]
				If cTpRes == "A" .AND. VS3->(ColumnPos("VS3_QTDATE")) > 0 //Reserva Automatica
					VS3->VS3_QTDATE += aRecVS3[nI,2]
				EndIf
			EndIf

			If cOrigem == "CO" // Conferencia de Itens
				VS3->VS3_QTDITE -= aRecVS3[nI,2]
			EndIf

		MsUnLock()

		cMsgLog += "======= Atualização da VS3 =========" + chr(13) + chr(10)
		cMsgLog += "VS3_FILIAL: " 	+ VS3->VS3_FILIAL + chr(13) + chr(10)
		cMsgLog += "VS3_NUMORC: " + VS3->VS3_NUMORC + chr(13) + chr(10)
		cMsgLog += "VS3_GRUITE: " + VS3->VS3_GRUITE + chr(13) + chr(10)
		cMsgLog += "VS3_CODITE: " + VS3->VS3_CODITE + chr(13) + chr(10)
		cMsgLog += "VS3_QTDRES: " + cValtoChar(VS3->VS3_QTDRES) + chr(13) + chr(10)
		cMsgLog += "VS3_QTDAGU: " + cValtoChar(VS3->VS3_QTDAGU) + chr(13) + chr(10)
		cMsgLog += "VS3_QTDTRA: " + cValtoChar(VS3->VS3_QTDTRA) + chr(13) + chr(10)
		cMsgLog += "VS3_QTDITE: " + cValtoChar(VS3->VS3_QTDITE) + chr(13) + chr(10)

	Next

	For nI := 1 To Len(aOrcmto)

		DBSelectArea("VS1")
		DbSetOrder(1)
		DbSeek(xFilial("VS1")+aOrcmto[nI])

		reclock("VS1",.f.)

			VS1->VS1_STARES := OA4820105_StatusReservaOrcamento(VS1->VS1_NUMORC)
			If Type("M->VS1_STARES") != "U"
				M->VS1_STARES := VS1->VS1_STARES
			EndIf

			If VS1->VS1_STARES $ "3/4"
				cReserv := "0"
				cOrcRes := "0"
			EndIf

			VS1->VS1_ORCRES := cOrcRes
			If Type("M->VS1_ORCRES") != "U"
				M->VS1_ORCRES := VS1->VS1_ORCRES
			EndIf

			If cTpRes == "M"
				//Reserva Manual
				VS1->VS1_RESERV := cReserv
				If Type("M->VS1_RESERV") != "U"
					M->VS1_RESERV := VS1->VS1_RESERV
				EndIf
			EndIf

		msunlock()

		cMsgLog += "======= Atualização da VS1 ========="+ chr(13) + chr(10)
		cMsgLog += "VS1_FILIAL: " + VS1->VS1_FILIAL + chr(13) + chr(10)
		cMsgLog += "VS1_NUMORC: " + VS1->VS1_NUMORC + chr(13) + chr(10)
		cMsgLog += "VS1_STARES: " + VS1->VS1_STARES + chr(13) + chr(10)
		cMsgLog += "VS1_TIPORC: " + VS1->VS1_TIPORC + chr(13) + chr(10)

	Next

Return

/*/{Protheus.doc} OA4820065_LevantaArmazemOrigem
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820065_LevantaArmazemOrigem(lReserva,cOrigem,lPecDes,cMsgLog)

	Local cArmRet := ""

	if cOrigem == "EX" .or. cOrigem == "OF" .or. cOrigem == "SUOF" .or. cOrigem == "TROF" // Exportação Orcamento Oficina // Oficina // Sugestão Oficina // Transferencia entre Filiais

		If lReserva
			If VSJ->VSJ_RESPEC == "1"
				cArmRet := Subs(GetMv( "MV_MIL0179" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
			Else
				cArmRet := VSJ->VSJ_LOCAL
			EndIf
		Else
			cArmRet := Subs(GetMv( "MV_MIL0179" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
		EndIf

	ElseIf cOrigem == "COOF" // Conferencia Oficina

		cArmRet := VSJ->VSJ_LOCAL
		If lPecDes
			cArmRet := Subs(GetMv( "MV_MIL0179" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
		EndIf

	ElseIf cOrigem == "CO" // Conferencia

		cArmRet := VS3->VS3_LOCAL
		If lPecDes
			cArmRet := Subs(GetMv( "MV_MIL0177" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
		EndIf

	ElseIf cOrigem == "AM2" // Atendimento Modelo 2 ( VEIXA018 )

		If lReserva
			cArmRet := VW3->VW3_LOCAL
		Else
			cArmRet := Subs(GetMv( "MV_MIL0213" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
		EndIf

	Else

		If lReserva
			cArmRet := VS3->VS3_LOCAL
		Else
			if cOrigem == "PD" .or. ( cOrigem == "SU" .and. VS1->VS1_TIPORC == "P" ) // Pedido de Orçamento
				cArmRet := Subs(GetMv( "MV_MIL0192" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
			Else
				cArmRet := Subs(GetMv( "MV_MIL0177" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
			EndIf
		EndIf

	EndIf

	cMsgLog += " ======== Inicio OA4820065_LevantaArmazemOrigem =========== " + chr(13) + chr(10)
	cMsgLog += " lReserva: " + cValToChar(lReserva) + chr(13) + chr(10)
	cMsgLog += " cOrigem: " + cOrigem + chr(13) + chr(10)
	cMsgLog += " lPecDes: " + cValToChar(lPecDes) + chr(13) + chr(10)

	cMsgLog += " VSJ_FILIAL: " + VSJ->VSJ_FILIAL + chr(13) + chr(10)
	cMsgLog += " VSJ_LOCAL : " + VSJ->VSJ_LOCAL + chr(13) + chr(10)
	cMsgLog += " VSJ_GRUITE: " + VSJ->VSJ_GRUITE + chr(13) + chr(10)
	cMsgLog += " VSJ_CODITE: " + VSJ->VSJ_CODITE + chr(13) + chr(10)
	cMsgLog += " VSJ_CODIGO: " + VSJ->VSJ_CODIGO + chr(13) + chr(10)
	cMsgLog += " VSJ_RESPEC: " + VSJ->VSJ_RESPEC + chr(13) + chr(10)

	cMsgLog += " VS3_LOCAL : " + VS3->VS3_LOCAL + chr(13) + chr(10)
	cMsgLog += " VS3_GRUITE: " + VS3->VS3_GRUITE + chr(13) + chr(10)
	cMsgLog += " VS3_CODITE: " + VS3->VS3_CODITE + chr(13) + chr(10)
	cMsgLog += " VS1_NUMORC: " + VS1->VS1_NUMORC + chr(13) + chr(10)
	cMsgLog += " VS1_TIPORC: " + VS1->VS1_TIPORC + chr(13) + chr(10)

	cMsgLog += " cArmRet: " + cArmRet + chr(13) + chr(10)

	cMsgLog += " ======== Fim OA4820065_LevantaArmazemOrigem =========== " + chr(13) + chr(10)

Return cArmRet


/*/{Protheus.doc} OA4820075_LevantaArmazemDestino
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820075_LevantaArmazemDestino(lReserva,cOrigem,lPecDes,lArmProd,cMsgLog)

	Local cArmRet := ""

	if cOrigem == "EX" .or. cOrigem == "OF" .or. cOrigem == "SUOF" .or. cOrigem == "TROF" // Oficina

		If lReserva
			cArmRet := Subs(GetMv( "MV_MIL0179" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
		Else
			If lArmProd
				cArmRet := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
			Else
				cArmRet := VSJ->VSJ_LOCAL
			Endif
		EndIf

	Elseif cOrigem == "CO" .or. cOrigem == "COOF" // Conferencia
		cArmRet := Subs(GetMv( "MV_DIVITE" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))

	Elseif cOrigem == "AM2" // Atendimento Modelo 2 ( VEIXA018 )
		
		If lReserva
			cArmRet := Subs(GetMv( "MV_MIL0213" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
		Else
			cArmRet := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		EndIf

	Else
		If lReserva
			if cOrigem == "PD" .or. ( (cOrigem == "SU" .or. cOrigem == "TR") .and. VS1->VS1_TIPORC == "P" ) // Pedido de Orçamento
				cArmRet := Subs(GetMv( "MV_MIL0192" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
			Else
				cArmRet := Subs(GetMv( "MV_MIL0177" ),1,GetSX3Cache("D3_LOCAL","X3_TAMANHO"))
			EndIf
		Else
			cArmRet := VS3->VS3_LOCAL
		EndIf
	EndIf

	cMsgLog += " ======== Inicio OA4820075_LevantaArmazemDestino =========== " + chr(13) + chr(10)
	cMsgLog += " lReserva: " + cValToChar(lReserva) + chr(13) + chr(10)
	cMsgLog += " cOrigem : " + cOrigem + chr(13) + chr(10)
	cMsgLog += " lPecDes : " + cValToChar(lPecDes) + chr(13) + chr(10)
	cMsgLog += " lArmProd: " + cValToChar(lArmProd) + chr(13) + chr(10)

	cMsgLog += " B1_COD " + SB1->B1_COD + chr(13) + chr(10)

	cMsgLog += " VSJ_LOCAL : " + VSJ->VSJ_LOCAL + chr(13) + chr(10)
	cMsgLog += " VSJ_GRUITE: " + VSJ->VSJ_GRUITE + chr(13) + chr(10)
	cMsgLog += " VSJ_CODITE: " + VSJ->VSJ_CODITE + chr(13) + chr(10)
	cMsgLog += " VSJ_CODIGO: " + VSJ->VSJ_CODIGO + chr(13) + chr(10)
	cMsgLog += " VSJ_RESPEC: " + VSJ->VSJ_RESPEC + chr(13) + chr(10)

	cMsgLog += " VS3_LOCAL : " + VS3->VS3_LOCAL + chr(13) + chr(10)
	cMsgLog += " VS3_GRUITE: " + VS3->VS3_GRUITE + chr(13) + chr(10)
	cMsgLog += " VS3_CODITE: " + VS3->VS3_CODITE + chr(13) + chr(10)
	cMsgLog += " VS1_NUMORC: " + VS1->VS1_NUMORC + chr(13) + chr(10)
	cMsgLog += " VS1_TIPORC: " + VS1->VS1_TIPORC + chr(13) + chr(10)

	cMsgLog += " cArmRet: " + cArmRet + chr(13) + chr(10)

	cMsgLog += " ======== Fim OA4820075_LevantaArmazemDestino =========== " + chr(13) + chr(10)

Return cArmRet

/*/{Protheus.doc} OA4820085_LevantaLocalizacaoOrigem
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820085_LevantaLocalizacaoOrigem(lReserva,cOrigem,lPecDes)

	Local cLocalizRet := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

Return cLocalizRet


/*/{Protheus.doc} OA4820095_LevantaLocalizacaoDestino
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820095_LevantaLocalizacaoDestino(lReserva,cOrigem,lPecDes)

	Local cLocalizRet := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

	If cOrigem == "CO" .or. cOrigem == "COOF"
		cLocalizRet := Subs(GetMv( "MV_DIVLOC" ),1,GetSX3Cache("B5_LOCALI2","X3_TAMANHO"))
	EndIf

Return cLocalizRet

/*/{Protheus.doc} OA4820105_StatusReservaOrcamento
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820105_StatusReservaOrcamento(cNumOrc)
	
	Local cStatus   := "3" //Não Reservado
	Local nQtIteOrc := 0
	Local nQtIteRes := 0
	Local cQuery    := ""

	cQuery := "SELECT Count(*) "
	cQuery += "FROM " + RetSQLName("VS3") + " VS3 "
	cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += 	"AND VS3.VS3_NUMORC = '" + cNumOrc + "' "
	cQuery += 	"AND VS3.D_E_L_E_T_ = ' '"

	nQtIteOrc := FM_SQL(cQuery)

	cQuery := "SELECT Count(*) "
	cQuery += "FROM " + RetSQLName("VS3") + " VS3 "
	cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += 	"AND VS3.VS3_NUMORC = '" + cNumOrc + "' "
	cQuery += 	"AND VS3.VS3_RESERV = '1' "
	cQuery += 	"AND VS3.D_E_L_E_T_ = ' '"

	nQtIteRes :=  FM_SQL(cQuery)

	If nQtIteOrc == nQtIteRes
		cStatus := "1" //Reservado
	ElseIf nQtIteRes > 0
		cStatus := "2" //Parcialmente reservado
	EndIf

Return cStatus


/*/{Protheus.doc} OA4820095_LevantaLocalizacaoDestino
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820115_AddArrayItemHistoricoReservaBalcao(cTpReqDev,cDocumento,cTipo,cCodVB5,cOrigem,nQtd,cArmOri,cEndOri,cArmDes,cEndDes,cNotaFis,cSerNf,cFornece,cLoja)

	Local aItem := {}

	Default cNotaFis := ""
	Default cSerNf := ""
	Default cFornece := ""
	Default cLoja := ""

	aadd(aItem,{"VB2_FILORC" ,VS3->VS3_FILIAL,Nil})
	aadd(aItem,{"VB2_NUMORC" ,VS3->VS3_NUMORC,Nil})
	aadd(aItem,{"VB2_SEQITE" ,VS3->VS3_SEQUEN,Nil})

	If cTpReqDev == "R"
		aadd(aItem,{"VB2_TIPREQ" ,cTipo,Nil})
	ElseIf cTpReqDev == "D"
		aadd(aItem,{"VB2_TIPDEV" ,cTipo,Nil})
	EndIf

	aadd(aItem,{"VB2_GRUITE" ,VS3->VS3_GRUITE,Nil})
	aadd(aItem,{"VB2_CODITE" ,VS3->VS3_CODITE,Nil})

	If cOrigem == "LJ"
		aadd(aItem,{"VB2_QUANT " ,VS3->VS3_QTDITE,Nil})
	Else
		aadd(aItem,{"VB2_QUANT " ,nQtd   ,Nil})
		aadd(aItem,{"VB2_ARMORI" ,cArmOri,Nil})
		aadd(aItem,{"VB2_ENDORI" ,cEndOri,Nil})
		aadd(aItem,{"VB2_ARMDES" ,cArmDes,Nil})
		aadd(aItem,{"VB2_ENDDES" ,cEndDes,Nil})
	EndIf
	aadd(aItem,{"VB2_DOCSDB" ,cDocumento,Nil})
	aadd(aItem,{"VB2_CODVB5" ,cCodVB5,Nil})
	aadd(aItem,{"VB2_NUMNFI" ,cNotaFis,Nil})
	aadd(aItem,{"VB2_SERNFI" ,cSerNf,Nil})
	aadd(aItem,{"VB2_FORNFI" ,cFornece,Nil})
	aadd(aItem,{"VB2_LOJNFI" ,cLoja,Nil})
	aadd(aItem,{"VB2_USUMOV" ,__CUSERID,Nil})

Return aItem

/*/{Protheus.doc} OA4820125_GravaHistoricoMovBalcao
	Função para fazer a gravação histórico de movimentações do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820125_GravaHistoricoMovBalcao(aHistIte,aHistCon,aHistPed)

	Local nI := 0
	Local aBkpRot := {}

	Default aHistIte := {}
	Default aHistCon := {}
	Default aHistPed := {}

	Private lMsErroAuto	:= .F.

	If Type("aRotina") == "U"
		aRotina := {}
	Else
		aBkpRot := aClone(aRotina)
	EndIf

	For nI := 1 To Len(aHistIte)

		oModelVB2 := FWLoadModel( 'OFIA480' )
		FWMVCRotAuto(oModelVB2,"VB2",3,{{"VB2MASTER",aHistIte[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	For nI := 1 To Len(aHistCon)

		oModelVB4 := FWLoadModel( 'OFIA483' )
		FWMVCRotAuto(oModelVB4,"VB4",3,{{"VB4MASTER",aHistCon[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	For nI := 1 To Len(aHistPed)

		oModelVB2 := FWLoadModel( 'OFIA480' )
		FWMVCRotAuto(oModelVB2,"VB2",3,{{"VB2MASTER",aHistPed[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	aRotina := aClone(aBkpRot)

Return .t.

/*/{Protheus.doc} OA4820135_LevantaQtdMovimentacaoResOrcamento
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820135_LevantaQtdMovimentacaoResOrcamento(cTpRes,cTpReqDev,cOrigem,lSugCom)

	Local nQtRet := 0

	Default cTpRes  := "A" // Reserva Automática
	Default cTpReqDev := "R"

	If cOrigem == "CO"

		cTpReqDev := "R"
		If VS3->VS3_QTDRES > 0
			cTpReqDev := "D"
			nQtRet := VS3->VS3_QTDRES - VS3->VS3_QTDCON
		Else
			nQtRet := VS3->VS3_QTDITE - VS3->VS3_QTDCON
		EndIf

	Else
		nQtRet := VS3->VS3_QTDITE - VS3->VS3_QTDRES - VS3->VS3_QTDAGU - VS3->VS3_QTDTRA

		If lSugCom
			nQtEst := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VS3->VS3_LOCAL)
			If nQtEst < nQtRet
				nQtRet := nQtEst
			EndIf
		EndIf

		If cTpRes == "A"
			If cTpReqDev == "D"
				nQtRet := VS3->VS3_QTDRES
			ElseIf nQtRet < 0
				cTpReqDev := "D"
				nQtRet := nQtRet*(-1)
			EndIf
		ElseIf !Empty(cTpReqDev)
			If cTpReqDev == "D"
				If nQtRet < 0
					nQtRet := nQtRet*(-1)
				ElseIf nQtRet >= 0
					nQtRet := VS3->VS3_QTDRES
				EndIf
			EndIf
		Else
			cTpReqDev := "R"
			If nQtRet < 0
				cTpReqDev := "D"
				nQtRet := nQtRet*(-1)
			EndIf
		EndIf
	EndIf

Return nQtRet

/*/{Protheus.doc} OA4820145_ProcessaReservaItemBalcao
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/
Function OA4820145_ProcessaReservaItemBalcao(cOperacao,cTpRes,nVS3Rec,cDocumento,aItensNew,aRecVS3,aHistIte,cTipo,cOrigem,aHistCon,cTpConf,lSugCom,nQtdMov,cCodVB5,cNotaFis,cSerNf,cFornece,cLoja,cMsgRet,cTpMOrc,nRecVS3Ped,aHistPed,cArmDes,cArmOri,cMsgLog)

	Local aItemMov:= {}
	Local lPecDes := .f.
	Local cReqDev := ""

	Default lSugCom := .f.
	Default nQtdMov := 0
	Default cCodVB5 := ""
	Default cNotaFis := ""
	Default cSerNf   := ""
	Default cFornece := ""
	Default cLoja    := ""
	Default cMsgRet  := ""
	Default cArmDes  := ""
	Default cArmOri  := ""
	Default cMsgLog  := ""

	DbSelectArea("SB1")
	DbSetOrder(7)
	DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
	DbSetOrder(1)

	DbSelectArea("SB5")
	DbSetOrder(1)
	DbSeek( xFilial("SB5") + SB1->B1_COD )

	cTpReqDev := cOperacao //Operação Default

	If nQtdMov == 0
		nQtdMov := OA4820135_LevantaQtdMovimentacaoResOrcamento(cTpRes,@cTpReqDev,cOrigem,lSugCom)
	EndIf

	If OA4820025_ValidaReservaItemBalcao(nQtdMov,@cMsgRet,cTpReqDev,cOrigem)

		lPecDes := (cOrigem <> "CO") .or. (cOrigem == "CO" .and. cTpReqDev == "D")

		aItemMov := OA4820035_AddArrayReservaItem(cTpReqDev,nQtdMov,cOrigem,lPecDes,cArmDes,cArmOri,,@cMsgLog,@aItensNew)

		cMsgLog += "VS3_GRUITE: " 	+ VS3->VS3_GRUITE + chr(13) + chr(10)
		cMsgLog += "VS3_CODITE: " 	+ VS3->VS3_CODITE + chr(13) + chr(10)
		cMsgLog += "VS3_QTDITE: " 	+ cValtoChar(VS3->VS3_QTDITE) + chr(13) + chr(10)
		cMsgLog += "VS3_QTDRES: " 	+ cValtoChar(VS3->VS3_QTDRES) + chr(13) + chr(10)
		cMsgLog += "nVS3Rec: " 		+ cValToChar(nVS3Rec) + chr(13) + chr(10)
		cMsgLog += "Quantidade Mov SD3: " + cValToChar(nQtdMov) + chr(13) + chr(10)
		cMsgLog += "Armazem Origem SD3: " + cValToChar(aItemMov[4]) + chr(13) + chr(10)
		cMsgLog += "Armazem Destino SD3: " + cValToChar(aItemMov[9]) + chr(13) + chr(10)

		aadd(aRecVS3,{nVS3Rec,nQtdMov,cTpReqDev,lPecDes}) // Registro / Quantidade / Reserva ou Desreserva

		If cOrigem == "CO"
			aAdd(aHistCon, aClone(OA4820195_AddArrayDivergenciaConferenciaItem(VS3->VS3_FILIAL,VS3->VS3_NUMORC,VS3->VS3_SEQUEN,,,,VS3->VS3_GRUITE,VS3->VS3_CODITE,cTpReqDev,aItemMov,cDocumento,cTpConf)))
		EndIf

		If lPecDes
			aAdd(aHistIte, aClone(OA4820115_AddArrayItemHistoricoReservaBalcao(cTpReqDev,cDocumento,cTipo,cCodVB5,cOrigem,aItemMov[16],aItemMov[4],aItemMov[5],aItemMov[9],aItemMov[10],cNotaFis,cSerNf,cFornece,cLoja)))
		EndIf

	Endif

	cMsgLog += cMsgRet

Return

/*/{Protheus.doc} OA4820155_ValidaReservaOrcamento
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*//*
Function OA4820155_ValidaReservaOrcamento(cNumOrc,cRetorno)

	Local lRetorno := .t.


Return lRetorno*/

/*/{Protheus.doc} OA4820175_SaldoReservaItemOrcamento
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 01/11/2022
/*/
Function OA4820175_SaldoReservaItemOrcamento(cFilOrc, cNumOrc, cGruIte, cCodIte, cTipo)

	Local nTotRes := 0

	Default cFilOrc := ""
	Default cNumOrc := ""
	Default cGruIte := ""
	Default cCodIte := ""

	nQtdRes := OA4820185_QtdReservaItemOrcamento(cFilOrc, cNumOrc, cGruIte, cCodIte, cTipo, "R" , .t.)
	nQtdDev := OA4820185_QtdReservaItemOrcamento(cFilOrc, cNumOrc, cGruIte, cCodIte, cTipo, "D" , .t.)

	nTotRes := nQtdRes - nQtdDev

Return nTotRes

/*/{Protheus.doc} OA4820185_QtdReservaItemOrcamento
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 01/11/2022
/*/
Function OA4820185_QtdReservaItemOrcamento(cFilOrc, cNumOrc, cGruIte, cCodIte, cTipo, cOperacao , lSintetico)

	Local nQtMov := 0

	cFiltro := 	" VB2_FILIAL = '" + xFilial("VB2") + "' "
	cFiltro += 	" AND VB2_FILORC = '" + cFilOrc + "' "
	cFiltro += 	" AND VB2_NUMORC = '" + cNumOrc + "' "
	
	If cOperacao == "R"
		If Empty(cTipo)
			cFiltro += 	" AND VB2_TIPREQ <> ' '"
		Else
			cFiltro += 	" AND VB2_TIPREQ = '" + cTipo + "'"
		EndIf
	Elseif cOperacao == "D"
		If Empty(cTipo)
			cFiltro += 	" AND VB2_TIPDEV <> ' '"
		Else
			cFiltro += 	" AND VB2_TIPDEV = '" + cTipo + "'"
		EndIf
	EndIf

	cFiltro += 	" AND D_E_L_E_T_ = ' ' "

	If !Empty(cGruIte) .and. !Empty(cCodIte)
		cFiltro += 	" AND VB2_GRUITE = '" + cGruIte + "'"
		cFiltro += 	" AND VB2_CODITE = '" + cCodIte + "' "
	EndIf

	cQuery := "SELECT "

	If lSintetico
		cQuery += " SUM(VB2.VB2_QUANT) "
	Else
		cQuery += " VB2.R_E_C_N_O_ AS VB2RECNO "
	EndIf

	cQuery += "FROM " + RetSqlName("VB2") + " VB2 "
	cQuery += " WHERE "
	cQuery += cFiltro

	If !lSintetico
		cQuery += " ORDER BY VB2_CODIGO DESC"
	EndIf

	If lSintetico

		nQtMov := FM_SQL(cQuery)

	Else

		TcQuery cQuery New Alias "TMPVB2"

		While !Eof()

			TMPVB2->(DbSkip())

		EndDo

		TMPVB2->(DbCloseArea())

	EndIf

Return nQtMov

/*/{Protheus.doc} OA4820195_AddArrayDivergenciaConferenciaItem
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/

Function OA4820195_AddArrayDivergenciaConferenciaItem(cFilOrc,cNumOrc,cSeqIte,cFilOsv,cNumOsv,cCodVSJ,cGruIte,cCodIte,cTpReqDev,aItemMov,cDocumento,cTpConf,cOrigem)

	Local aItem := {}

	Default cFilOrc := ""
	Default cNumOrc := ""
	Default cSeqIte := ""
	Default cGruIte := ""
	Default cCodIte := ""
	Default cFilOsv := ""
	Default cNumOsv := ""
	Default cCodVSJ := ""

	aadd(aItem,{"VB4_FILORC" , cFilOrc		, Nil})
	aadd(aItem,{"VB4_NUMORC" , cNumOrc		, Nil})
	aadd(aItem,{"VB4_SEQITE" , cSeqIte		, Nil})
	aadd(aItem,{"VB4_FILOSV" , cFilOsv		, Nil})
	aadd(aItem,{"VB4_NUMOSV" , cNumOsv		, Nil})
	aadd(aItem,{"VB4_CODVSJ" , cCodVSJ		, Nil})
	aadd(aItem,{"VB4_TIPCON" , cTpConf		, Nil})
	aadd(aItem,{"VB4_GRUITE" , cGruIte		, Nil})
	aadd(aItem,{"VB4_CODITE" , cCodIte		, Nil})
	aadd(aItem,{"VB4_QUANT " , aItemMov[16]	, Nil})
	aadd(aItem,{"VB4_ARMORI" , aItemMov[4]	, Nil})
	aadd(aItem,{"VB4_ENDORI" , aItemMov[5]	, Nil})
	aadd(aItem,{"VB4_ARMDES" , aItemMov[9]	, Nil})
	aadd(aItem,{"VB4_ENDDES" , aItemMov[10]	, Nil})
	aadd(aItem,{"VB4_DOCSDB" , cDocumento	, Nil})

Return aItem


/*/{Protheus.doc} OA4820205_ValidaReservaItemOficina
	Função para fazer a validação da reserva e desreserva do item com gravação de histórico de Oficina

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*//*

Function OA4820205_ValidaReservaItemOficina()


Return .t.
*/
/*/{Protheus.doc} OA4820215_ProcessaReservaItemOficina
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 05/10/2022
/*/

Function OA4820215_ProcessaReservaItemOficina(cOperacao,cTpRes,nRecVSJ,nVS3Rec,cDocumento,aItensNew,aRecMov,aHistIte,aHistOrc,cTipo,cOrigem,aHistCon,cTpConf,lSugCom,nQtdMov,cCodVB5,cArmDes,cArmOri,cTpMOrc,cNotaFis,cSerNf,cFornece,cLoja,lArmProd,cMsgLog)

	Local aItemMov:= {}
	Local lPecDes := .f.
	Local cReqDev := ""

	Default lSugCom := .f.
	Default nQtdMov := 0
	Default cCodVB5 := ""
	Default nVS3Rec := 0
	Default cArmDes := ""
	Default cArmOri := ""
	Default cTpMOrc := ""
	Default cNotaFis:= ""
	Default cSerNf  := ""
	Default cFornece:= ""
	Default cLoja   := ""
	Default lArmProd:= .f.

	DbSelectArea("SB1")
	DbSetOrder(7)
	DBSeek(xFilial("SB1")+VSJ->VSJ_GRUITE+VSJ->VSJ_CODITE)
	DbSetOrder(1)

	DbSelectArea("SB5")
	DbSetOrder(1)
	DbSeek( xFilial("SB5") + SB1->B1_COD )

	cTpReqDev := cOperacao //Operação Default

	If nQtdMov == 0
		nQtdMov := OA4820225_LevantaQtdMovimentacaoResOficina(@cTpReqDev,cOrigem,lSugCom)
	EndIf

	If OA4820235_ValidaReservaItemOficina(nQtdMov)

		lPecDes := (cOrigem <> "COOF") .or. (cOrigem == "COOF" .and. cTpReqDev == "D")

		aItemMov := OA4820035_AddArrayReservaItem(cTpReqDev,nQtdMov,cOrigem,lPecDes,cArmDes,cArmOri,lArmProd,@cMsgLog,@aItensNew)

		cMsgLog += "VSJ_GRUITE: " 	+ VSJ->VSJ_GRUITE + chr(13) + chr(10)
		cMsgLog += "VSJ_CODITE: " 	+ VSJ->VSJ_CODITE + chr(13) + chr(10)
		cMsgLog += "VSJ_QTDITE: " 	+ cValtoChar(VSJ->VSJ_QTDITE) + chr(13) + chr(10)
		cMsgLog += "VSJ_QTDRES: " 	+ cValtoChar(VSJ->VSJ_QTDRES) + chr(13) + chr(10)
		cMsgLog += "VSJ_CODIGO: " 	+ VSJ->VSJ_CODIGO + chr(13) + chr(10)
		cMsgLog += "nRecVSJ: " 		+ cValToChar(nRecVSJ) + chr(13) + chr(10)
		cMsgLog += "Quantidade Mov SD3: " + cValToChar(nQtdMov) + chr(13) + chr(10)
		cMsgLog += "Armazem Origem SD3: " + cValToChar(aItemMov[4]) + chr(13) + chr(10)
		cMsgLog += "Armazem Destino SD3: " + cValToChar(aItemMov[9]) + chr(13) + chr(10)

		aadd(aRecMov,{nRecVSJ,nVS3Rec,nQtdMov,cTpReqDev,lPecDes}) // Registro / Quantidade / Reserva ou Desreserva
		If cOrigem == "COOF"
			aAdd(aHistCon, aClone(OA4820195_AddArrayDivergenciaConferenciaItem(,,,VSJ->VSJ_FILIAL,VSJ->VSJ_NUMOSV,VSJ->VSJ_CODIGO,VSJ->VSJ_GRUITE,VSJ->VSJ_CODITE,cTpReqDev,aItemMov,cDocumento,cTpConf)))
		EndIf
		If lPecDes
			aAdd(aHistIte, aClone(OA4820245_AddArrayItemHistoricoReservaOficina(cTpReqDev,aItemMov,cDocumento,cTipo,cCodVB5,cOrigem,cNotaFis,cSerNf,cFornece,cLoja)))
			If cOrigem == "EX"
				If OA4820175_SaldoReservaItemOrcamento(VS3->VS3_FILIAL, VS3->VS3_NUMORC, VS3->VS3_GRUITE, VS3->VS3_CODITE, cTpMOrc) > 0

					cMsgLog += "nVS3Rec: " 		+ cValToChar(nVS3Rec) + chr(13) + chr(10)
					cMsgLog += "VS3_GRUITE: " 	+ VS3->VS3_GRUITE + chr(13) + chr(10)
					cMsgLog += "VS3_CODITE: " 	+ VS3->VS3_CODITE + chr(13) + chr(10)
					cMsgLog += "VS3_QTDITE: " 	+ cValtoChar(VS3->VS3_QTDITE) + chr(13) + chr(10)
					cMsgLog += "VS3_QTDRES: " 	+ cValtoChar(VS3->VS3_QTDRES) + chr(13) + chr(10)

					aAdd(aHistOrc, aClone(OA4820115_AddArrayItemHistoricoReservaBalcao("D",cDocumento,cTpMOrc,cCodVB5,cOrigem,aItemMov[16],aItemMov[4],aItemMov[5],aItemMov[9],aItemMov[10])))
				EndIf
			EndIf
		EndIf

	Endif

Return 


/*/{Protheus.doc} OA4820225_LevantaQtdMovimentacaoResOficina
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 27/01/2023
/*/
Function OA4820225_LevantaQtdMovimentacaoResOficina(cTpReqDev,cOrigem,lSugCom)

	Local nQtRet := 0

	If cOrigem == "COOF"

		cTpReqDev := "R"
		If VSJ->VSJ_QTDRES > 0
			cTpReqDev := "D"
			nQtRet := VSJ->VSJ_QTDRES
		Else
			nQtRet := VSJ->VS3_QTDITE
		EndIf

	Else

		nQtRet := ( VSJ->VSJ_QTDITE ) - VSJ->VSJ_QTDAGU - VSJ->VSJ_QTDRES

		If VSJ->(FieldPos("VSJ_QTDTRA")) > 0
			nQtRet -= VSJ->VSJ_QTDTRA
		EndIf

		nQtEst := OX001SLDPC(xFilial("SB2")+SB1->B1_COD+VSJ->VSJ_LOCAL)
		If nQtEst < nQtRet
			nQtRet := nQtEst
		EndIf

		If !Empty(cTpReqDev)
			If cTpReqDev == "D"
				nQtRet := VSJ->VSJ_QTDRES
			EndIf
		Else
			cTpReqDev := "R"
			If nQtRet < 0
				cTpReqDev := "D"
				nQtRet := nQtRet*(-1)
			EndIf
		EndIf

	EndIf

Return nQtRet

/*/{Protheus.doc} OA4820235_ValidaReservaItemOficina
	Função para fazer a validação da reserva e desreserva do item com gravação de histórico de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 27/01/2023
/*/
Function OA4820235_ValidaReservaItemOficina(nQtdMov)

	Local lRetorno := .t.

	Do Case
		Case nQtdMov <= 0
			lRetorno := .f.
	EndCase

Return lRetorno

/*/{Protheus.doc} OA4820245_AddArrayItemHistoricoReservaOficina
	Função para fazer a gravação da reserva e desreserva do item com gravação de histórico de Oficina

	@type function
	@author Renato Vinicius de Souza Santos
	@since 27/01/2023
/*/

Function OA4820245_AddArrayItemHistoricoReservaOficina(cTpReqDev,aItemMov,cDocumento,cTipo,cCodVB5,cOrigem,cNotaFis,cSerNf,cFornece,cLoja)

	Local aItem := {}

	aadd(aItem,{"VB3_FILOSV" ,VSJ->VSJ_FILIAL,Nil})
	aadd(aItem,{"VB3_NUMOSV" ,VSJ->VSJ_NUMOSV,Nil})
	aadd(aItem,{"VB3_CODVSJ" ,VSJ->VSJ_CODIGO,Nil})
	
	If cTpReqDev == "R"
		aadd(aItem,{"VB3_TIPREQ" ,cTipo,Nil})
	ElseIf cTpReqDev == "D"
		aadd(aItem,{"VB3_TIPDEV" ,cTipo,Nil})
	EndIf
	
	aadd(aItem,{"VB3_GRUITE" ,VSJ->VSJ_GRUITE,Nil})
	aadd(aItem,{"VB3_CODITE" ,VSJ->VSJ_CODITE,Nil})
	aadd(aItem,{"VB3_QUANT " ,aItemMov[16],Nil})
	aadd(aItem,{"VB3_ARMORI" ,aItemMov[4],Nil})
	aadd(aItem,{"VB3_ENDORI" ,aItemMov[5],Nil})
	aadd(aItem,{"VB3_ARMDES" ,aItemMov[9],Nil})
	aadd(aItem,{"VB3_ENDDES" ,aItemMov[10],Nil})
	aadd(aItem,{"VB3_DOCSDB" ,cDocumento,Nil})
	aadd(aItem,{"VB3_CODVB5" ,cCodVB5,Nil})
	aadd(aItem,{"VB3_NUMNFI" ,cNotaFis,Nil})
	aadd(aItem,{"VB3_SERNFI" ,cSerNf,Nil})
	aadd(aItem,{"VB3_FORNFI" ,cFornece,Nil})
	aadd(aItem,{"VB3_LOJNFI" ,cLoja,Nil})

Return aItem


/*/{Protheus.doc} OA4820255_GravaHistoricoMovOficina
	Função para fazer a gravação histórico de movimentações do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 27/01/2023
/*/
Function OA4820255_GravaHistoricoMovOficina(aHistIte,aHistCon,aHistOrc)

	Local nI := 0
	Local aBkpRot := {}
	Local oModel := FwModelActive()

	Default aHistIte := {}
	Default aHistCon := {}
	Default aHistOrc := {}

	Private lMsErroAuto	:= .F.

	If type ("aRotina") == "U"
		aRotina := {}
	Else
		aBkpRot := aClone(aRotina)
	EndIf

	For nI := 1 To Len(aHistOrc)

		oModelVB2 := FWLoadModel( 'OFIA480' )
		FWMVCRotAuto(oModelVB2,"VB2",3,{{"VB2MASTER",aHistOrc[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	For nI := 1 To Len(aHistIte)

		oModelVB3 := FWLoadModel( 'OFIA481' )
		FWMVCRotAuto(oModelVB3,"VB3",3,{{"VB3MASTER",aHistIte[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	For nI := 1 To Len(aHistCon)

		oModelVB4 := FWLoadModel( 'OFIA483' )
		FWMVCRotAuto(oModelVB4,"VB4",3,{{"VB4MASTER",aHistCon[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	aRotina := aClone(aBkpRot)

Return .t.


/*/{Protheus.doc} OA4820265_GravaDadosOrdemServico
	Função para fazer a gravação dos dados no orçamento que foi reservado / desreservado

	@type function
	@author Renato Vinicius de Souza Santos
	@since 10/10/2022
/*/
Function OA4820265_GravaDadosOrdemServico(aRecMov,cTpRes,cDocumento,cOrigem,cMsgLog)

	Local nI := 0
	Local cOrcRes := "1"
	Local cReserv := "1"
	Local lDevolu := .f.
	Local nQtdMov := 0

	Default cNumOrc := ""

	For nI := 1 to Len(aRecMov)

		VSJ->(DbGoTo(aRecMov[nI,1]))
		//VS3->(DbGoTo(aRecMov[nI,2]))

		lDevolu := .f.

		If aRecMov[nI,4] == "D"
			lDevolu := .t.
		EndIf

		lAtuRes := aRecMov[nI,5]
		nQtdMov := aRecMov[nI,3]

		DbSelectArea("VSJ")
		RecLock("VSJ",.f.)

			If lAtuRes
				If lDevolu
					VSJ->VSJ_QTDRES -= nQtdMov
				Else
					VSJ->VSJ_QTDRES += nQtdMov
				EndIf

				If VSJ->VSJ_QTDRES == 0
					VSJ->VSJ_RESPEC := "0"
				Else
					If VSJ->VSJ_RESPEC == "0"
						VSJ->VSJ_RESPEC := "1"
					EndIf
				EndIf
			EndIf

			If cOrigem == "SUOF" .and. VSJ->VSJ_QTDAGU > 0 // Sugestão de Compra
				VSJ->VSJ_QTDAGU -= nQtdMov
			EndIf

			If VSJ->(FieldPos("VSJ_QTDTRA")) > 0
				If cOrigem == "TROF" .and. VSJ->VSJ_QTDTRA > 0 // Transferencia entre Filiais
					VSJ->VSJ_QTDTRA -= nQtdMov
				EndIf
			EndIf

			If cOrigem == "COOF" // Conferencia de Itens
				VSJ->VSJ_QTDITE -= nQtdMov
			EndIf

		MsUnLock()

		cMsgLog += "======= Atualização da VSJ ========="+ chr(13) + chr(10)
		cMsgLog += "VSJ_NUMORC: " + VSJ->VSJ_NUMORC + chr(13) + chr(10)
		cMsgLog += "VSJ_NUMOSV: " + VSJ->VSJ_NUMOSV + chr(13) + chr(10)
		cMsgLog += "VSJ_CODIGO: " + VSJ->VSJ_CODIGO + chr(13) + chr(10)
		cMsgLog += "VSJ_GRUITE: " + VSJ->VSJ_GRUITE + chr(13) + chr(10)
		cMsgLog += "VSJ_CODITE: " + VSJ->VSJ_CODITE + chr(13) + chr(10)
		cMsgLog += "VSJ_QTDRES: " + cValtoChar(VSJ->VSJ_QTDRES) + chr(13) + chr(10)
		cMsgLog += "VSJ_QTDAGU: " + cValtoChar(VSJ->VSJ_QTDAGU) + chr(13) + chr(10)
		If VSJ->(FieldPos("VSJ_QTDTRA")) > 0
			cMsgLog += "VSJ_QTDTRA: " + cValtoChar(VSJ->VSJ_QTDTRA) + chr(13) + chr(10)
		Endif
		cMsgLog += "VSJ_QTDITE: " + cValtoChar(VSJ->VSJ_QTDITE) + chr(13) + chr(10)

	Next

	/*If !Empty(cNumOrc)
		DBSelectArea("VS1")
		reclock("VS1",.f.)
			VS1->VS1_STARES := OA4820105_StatusReservaOrcamento(cNumOrc)

			If VS1->VS1_STARES == "3"
				cReserv := "0"
				cOrcRes := "0"
			EndIf

			VS1->VS1_ORCRES := cOrcRes
			If cTpRes == "M"
				//Reserva Manual
				VS1->VS1_RESERV := cReserv
			EndIf
		msunlock()
	EndIf*/

Return

/*/{Protheus.doc} OA4820175_SaldoReservaItemOrcamento
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 24/02/2023
/*/
Function OA4820275_SaldoReservaItemOficina(cFilOsv, cNumOsv, cCodVSJ, cGruIte, cCodIte, cTipo)

	Local nTotRes := 0

	Default cFilOsv := ""
	Default cNumOsv := ""
	Default cGruIte := ""
	Default cCodIte := ""

	nQtdRes := OA4820285_QtdReservaItemOficina(cFilOsv, cNumOsv, cCodVSJ , cGruIte, cCodIte, cTipo, "R" , .t.)
	nQtdDev := OA4820285_QtdReservaItemOficina(cFilOsv, cNumOsv, cCodVSJ , cGruIte, cCodIte, cTipo, "D" , .t.)

	nTotRes := nQtdRes - nQtdDev

Return nTotRes

/*/{Protheus.doc} OA4820185_QtdReservaItemOrcamento
	Função para fazer a gravação histórico da reserva e desreserva do item de Balcao

	@type function
	@author Renato Vinicius de Souza Santos
	@since 01/11/2022
/*/
Function OA4820285_QtdReservaItemOficina(cFilOsv, cNumOsv, cCodVSJ, cGruIte, cCodIte, cTipo, cOperacao , lSintetico)

	Local nQtMov := 0

	cFiltro := 	" VB3_FILIAL = '" + xFilial("VB3") + "' "
	cFiltro += 	" AND VB3_FILOSV = '" + cFilOsv + "' "
	cFiltro += 	" AND VB3_NUMOSV = '" + cNumOsv + "' "

	If !Empty(cCodVSJ)
		cFiltro := " AND VB3_CODVSJ = '" + cCodVSJ + "' "
	EndIf
	
	If cOperacao == "R"
		If Empty(cTipo)
			cFiltro += 	" AND VB3_TIPREQ <> ' '"
		Else
			cFiltro += 	" AND VB3_TIPREQ = '" + cTipo + "'"
		EndIf
	Elseif cOperacao == "D"
		If Empty(cTipo)
			cFiltro += 	" AND VB3_TIPDEV <> ' '"
		Else
			cFiltro += 	" AND VB3_TIPDEV = '" + cTipo + "'"
		EndIf
	EndIf

	cFiltro += 	" AND D_E_L_E_T_ = ' ' "

	If !Empty(cGruIte) .and. !Empty(cCodIte)
		cFiltro += 	" AND VB3_GRUITE = '" + cGruIte + "'"
		cFiltro += 	" AND VB3_CODITE = '" + cCodIte + "' "
	EndIf

	cQuery := "SELECT "

	If lSintetico
		cQuery += " SUM(VB3.VB3_QUANT) "
	Else
		cQuery += " VB3.R_E_C_N_O_ AS VB3RECNO "
	EndIf

	cQuery += "FROM " + RetSqlName("VB3") + " VB3 "
	cQuery += " WHERE "
	cQuery += cFiltro

	If !lSintetico
		cQuery += " ORDER BY VB3_CODIGO DESC"
	EndIf

	If lSintetico

		nQtMov := FM_SQL(cQuery)

	Else

		TcQuery cQuery New Alias "TMPVB3"

		While !Eof()

			TMPVB3->(DbSkip())

		EndDo

		TMPVB3->(DbCloseArea())

	EndIf

Return nQtMov


/*/{Protheus.doc} OA4820295_ValidaAtivacaoReservaRastreavel
	Função para fazer a validação de ativacao da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820295_ValidaAtivacaoReservaRastreavel()

	Local lNewRes := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?

	If lNewRes

		If !OA4820305_ValidaParametrosReservaRastreavel()
			Return .f.
		EndIf

	EndIf

Return .t.

/*/{Protheus.doc} OA4820305_ValidaParametrosReservaRastreavel
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820305_ValidaParametrosReservaRastreavel()

	Local cArmROrc := GetNewPar("MV_MIL0177","") // "Armazém reserva de orçamento"
	Local cEndROrc := GetNewPar("MV_MIL0178","") // "Codigo do endereço das peças no armazem de pecas reservadas de orçamento"
	Local cArmROsv := GetNewPar("MV_MIL0179","") // "Armazém reserva de oficina"
	Local cEndROsv := GetNewPar("MV_MIL0180","") // "Codigo do endereço das peças no armazem de pecas reservadas de oficina"
	Local cArmRPed := GetNewPar("MV_MIL0192","") // "Armazém reserva de pedido de orçamento"
	Local cEndRPed := GetNewPar("MV_MIL0193","") // "Codigo do endereço das peças no armazem de pecas reservadas de pedido de orçamento"

	if Empty(cArmROrc) .or.;
		Empty(cArmROsv) .or.;
		Empty(cArmRPed)

		FMX_HELP("CONFPARAM","Os parâmetros da reserva não estão configurados. Há parâmetros com conteúdo em branco.")
		Return .f.

	EndIf

	If OA4820315_ValArmazemReservaRastreavelBalcao(cArmROrc)
		If !OA4820365_MovArmazemReservaRastreavel(cArmROrc)
			Return .f.
		EndIf
	Else
		Return .f.
	EndIf

//	If !OA4820325_ValEnderecoReservaRastreavelBalcao(cArmROrc,cEndROrc)
//		Return .f.
//	EndIf

	If OA4820335_ValArmazemReservaRastreavelOficina(cArmROsv)
		If !OA4820365_MovArmazemReservaRastreavel(cArmROsv)
			Return .f.
		EndIf
	Else
		Return .f.
	EndIf

//	If !OA4820345_ValEnderecoReservaRastreavelOficina(cArmROsv,cEndROsv)
//		Return .f.
//	EndIf

	If OA4820425_ValArmazemReservaRastreavelPedBalcao(cArmRPed)
		If !OA4820365_MovArmazemReservaRastreavel(cArmRPed)
			Return .f.
		EndIf
	Else
		Return .f.
	EndIf

//	If !OA4820435_ValEnderecoReservaRastreavelPedBalcao(cArmRPed,cEndRPed)
//		Return .f.
//	EndIf

	If !OA4820375_ValArmazemReservaRastreavelOrcxOfi(cArmROrc,cArmROsv,cArmRPed)
		Return .f.
	EndIf

Return .t.


/*/{Protheus.doc} OA4820315_ValArmazemReservaRastreavelBalcao
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820315_ValArmazemReservaRastreavelBalcao(cArmROrc)

	If !ExistCpo( "NNR" , cArmROrc , 1 )
		FMX_HELP("EXISTARM", STR0012 + " (MV_MIL0177)") //"O armazém de reserva informado no parâmetro não está cadastrado."
		Return .f.
	Endif

Return .t.

/*/{Protheus.doc} OA4820325_ValEnderecoReservaRastreavelBalcao
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*//*
Function OA4820325_ValEnderecoReservaRastreavelBalcao(cArmROrc,cEndROrc)

	If !ExistCpo( "SBE" , cArmROrc + cEndROrc )
		FMX_HELP("EXISTEND", STR0013 ) //"O endereço de reserva informado no parâmetro não está cadastrado."
		Return .f.
	EndIf

Return .t.
*/
/*/{Protheus.doc} OA4820335_ValArmazemReservaRastreavelOficina
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820335_ValArmazemReservaRastreavelOficina(cArmROsv)

	If !ExistCpo( "NNR" , cArmROsv , 1 )
		FMX_HELP("EXISTARM", STR0012 + " (MV_MIL0179)") //"O armazém de reserva informado no parâmetro não está cadastrado."
		Return .f.
	Endif

Return .t.

/*/{Protheus.doc} OA4820345_ValEnderecoReservaRastreavelOficina
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*//*
Function OA4820345_ValEnderecoReservaRastreavelOficina(cArmROsv,cEndROsv)

	If !ExistCpo( "SBE" , cArmROsv + cEndROsv )
		FMX_HELP("EXISTEND", STR0013 )
		Return .f.
	EndIf

Return .t.
*/
/*/{Protheus.doc} OA4820315_ValArmazemReservaRastreavelBalcao
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820425_ValArmazemReservaRastreavelPedBalcao(cArmRPed)

	If !ExistCpo( "NNR" , cArmRPed , 1 )
		FMX_HELP("EXISTARM", STR0012 + " (MV_MIL0192)") //"O armazém de reserva informado no parâmetro não está cadastrado."
		Return .f.
	Endif

Return .t.

/*/{Protheus.doc} OA4820435_ValEnderecoReservaRastreavelPedBalcao
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*//*
Function OA4820435_ValEnderecoReservaRastreavelPedBalcao(cArmRPed,cEndRPed)

	If !ExistCpo( "SBE" , cArmRPed + cEndRPed )
		FMX_HELP("EXISTEND", STR0013) //"O endereço de reserva informado no parâmetro não está cadastrado."
		Return .f.
	EndIf

Return .t.
*/
/*/{Protheus.doc} OA4820355_PrimeiraExecucaoReservaRastreavel
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820355_PrimeiraExecucaoReservaRastreavel()

	Local cQuery := ""

	cQuery := "SELECT SUM(CONT)
	cQuery += " FROM (
	cQuery += 		"SELECT Count(*) AS CONT FROM " + RetSqlName("VB2") + " VB2 WHERE VB2.VB2_FILIAL = '" + xFilial("VB2") + "' AND VB2.VB2_CODITE <> ' ' "
	cQuery += 		" UNION "
	cQuery += 		"SELECT Count(*) AS CONT FROM " + RetSqlName("VB3") + " VB3 WHERE VB3.VB3_FILIAL = '" + xFilial("VB3") + "' AND VB3.VB3_CODITE <> ' ' "
	cQuery += " ) TMPVM

	If FM_SQL(cQuery) > 0
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} OA4820365_MovArmazemReservaRastreavel
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820365_MovArmazemReservaRastreavel(cArmRes)

	Local cQuery := ""

	If OA4820355_PrimeiraExecucaoReservaRastreavel()

		cQuery := "SELECT SB2.R_E_C_N_O_"
		cQuery += " FROM " + RetSqlName("SB2") + " SB2 "
		cQuery += " WHERE SB2.B2_FILIAL = '" + xFilial("SB2") + "' "
		cQuery += 	" AND SB2.B2_LOCAL = '" + cArmRes + "' "
		cQuery += 	" AND SB2.D_E_L_E_T_ = ' ' "

		If FM_SQL(cQuery) > 0
			FMX_HELP("MOVARMRES", STR0014 + "(" + cArmRes + ")" , STR0015 ) //"O armazém de reserva informado no parâmetro já teve movimentação. (Armazém " // "Informe no parâmetro um armazém que não tenha movimentações anteriores."
			Return .f.
		EndIf
	
	EndIf

Return .t.


/*/{Protheus.doc} OA4820345_ValEnderecoReservaRastreavelOficina
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820375_ValArmazemReservaRastreavelOrcxOfi(cArmROrc,cArmROsv,cArmRPed)

	If cArmROrc == cArmROsv
		FMX_HELP("ARMRESORCOFI", STR0016 ) //"O armazém de reserva de orçamento e reserva de oficina não podem ser iguais."
		Return .f.
	EndIf

	If cArmRPed == cArmROrc
		FMX_HELP("ARMRESPEDORC", STR0017 ) //"O armazém de reserva de pedido de orçamento e reserva de orçamento não podem ser iguais."
		Return .f.
	EndIf

Return .t.


/*/{Protheus.doc} OA4820385_TransfereReservaPedidoOrcamento
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820385_TransfereReservaPedidoOrcamento(cNumPed,cNumOrc)

	Local aOrcIte := {}

	cQuery := "SELECT VS3.R_E_C_N_O_ VS3RECNOPED "
	cQuery += " FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
	cQuery += 	" AND VS3.VS3_RESERV = '1' "
	cQuery += 	" AND VS3.VS3_NUMORC = '" + cNumPed + "' "
	cQuery += 	" AND VS3.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPPED"

	While !TMPPED->(Eof())

		VS3->(DbGoTo(TMPPED->VS3RECNOPED))

		cQuery := "SELECT VS3.R_E_C_N_O_ VS3RECORC "
		cQuery += " FROM " + RetSqlName("VS3") + " VS3 "
		cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "' "
		cQuery += 	" AND VS3.VS3_NUMORC = '" + cNumOrc + "' "
		cQuery += 	" AND VS3.VS3_SEQUEN = '" + VS3->VS3_SEQUEN + "' "
		cQuery += 	" AND VS3.VS3_GRUITE = '" + VS3->VS3_GRUITE + "' "
		cQuery += 	" AND VS3.VS3_CODITE = '" + VS3->VS3_CODITE + "' "
		cQuery += 	" AND VS3.D_E_L_E_T_ = ' ' "

		cVS3RECORC := FM_SQL(cQuery)

		aAdd(aOrcIte,{ TMPPED->VS3RECNOPED , cVS3RECORC })

		TMPPED->(DbSkip())

	EndDo

	TMPPED->(DbCloseArea())

	If Len(aOrcIte) > 0
		DbSelectArea("VS1")
		cDocto := OA4820015_ProcessaReservaItem("PDOR",,"A","T",aOrcIte,"17",,,"14")
		If Empty(cDocto)
			Return .f.
		EndIf
	EndIf

Return .t.

/*/{Protheus.doc} OA4820395_TransfereReserva
	Função para fazer a validação de Parametros da reserva rastreavel no protheus

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/04/2023
/*/
Function OA4820395_TransfereReserva(cOrigem,cDocumento,aItensNew,aRecVS3,aHistIte,aHistPed,cTipo,cTpMOrc,nRecPed,nRecOrc,nQtdMov,cArmOri,cArmDes,cMsgLog)

	Local aItemMov:= {}

	Default nQtdMov := 0
	Default cCodVB5 := ""
	Default cMsgRet  := ""

	VS3->(DbGoTo(nRecPed)) // Pedido de Orçamento
	DbSelectArea("SB1")
	DbSetOrder(7)
	DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
	DbSetOrder(1)

	cMsgLog += "Do pedido de Orçamento: " + VS3->VS3_NUMORC + chr(13) + chr(10)
	cMsgLog += "VS3_FILIAL: " 	+ VS3->VS3_FILIAL + chr(13) + chr(10)
	cMsgLog += "VS3_GRUITE: " 	+ VS3->VS3_GRUITE + chr(13) + chr(10)
	cMsgLog += "VS3_CODITE: " 	+ VS3->VS3_CODITE + chr(13) + chr(10)
	cMsgLog += "VS3_QTDRES: " 	+ cValtoChar(VS3->VS3_QTDRES) + chr(13) + chr(10)
	cMsgLog += "cArmDes: " 		+ cArmDes + chr(13) + chr(10)
	cMsgLog += "cArmOri: " 		+ cArmOri + chr(13) + chr(10)
	cMsgLog += "nRecPed: " 		+ cValToChar(nRecPed) + chr(13) + chr(10)

	nQtdMov := VS3->VS3_QTDRES

	aItemMov := OA4820035_AddArrayReservaItem(,nQtdMov,,,cArmDes,cArmOri,,@cMsgLog,@aItensNew)

	cMsgLog += "Quantidade Mov SD3: " + cValToChar(nQtdMov) + chr(13) + chr(10)
	cMsgLog += "Armazem Origem SD3: " + cValToChar(aItemMov[4]) + chr(13) + chr(10)
	cMsgLog += "Armazem Destino SD3: " + cValToChar(aItemMov[9]) + chr(13) + chr(10)

	aadd(aRecVS3,{nRecPed,nQtdMov,"D",.t.}) // Registro / Quantidade / Reserva ou Desreserva / Atualiza Registro
	aAdd(aHistPed, aClone(OA4820115_AddArrayItemHistoricoReservaBalcao("D",cDocumento,cTipo,cCodVB5,cOrigem,nQtdMov,aItemMov[4],aItemMov[5],aItemMov[9],aItemMov[10])))

	VS3->(DbGoTo(nRecOrc)) // Orçamento

	cMsgLog += "Para o Orçamento: " + VS3->VS3_NUMORC + chr(13) + chr(10)
	cMsgLog += "VS3_FILIAL: " 	+ VS3->VS3_FILIAL + chr(13) + chr(10)
	cMsgLog += "VS3_GRUITE: " 	+ VS3->VS3_GRUITE + chr(13) + chr(10)
	cMsgLog += "VS3_CODITE: " 	+ VS3->VS3_CODITE + chr(13) + chr(10)
	cMsgLog += "nRecOrc: " 		+ cValToChar(nRecOrc) + chr(13) + chr(10)

	aadd(aRecVS3,{nRecOrc,aItemMov[16],"R",.t.}) // Registro / Quantidade / Reserva ou Desreserva / Atualiza Registro
	aAdd(aHistIte, aClone(OA4820115_AddArrayItemHistoricoReservaBalcao("R",cDocumento,cTpMOrc,cCodVB5,cOrigem,nQtdMov,aItemMov[4],aItemMov[5],aItemMov[9],aItemMov[10])))

Return

/*/{Protheus.doc} OFIA482

@author Renato Vinicius
@since 04/05/2023
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA4820405_VisualizaReservaOrcamento()

	FWExecView( STR0003, "OFIA480", MODEL_OPERATION_VIEW) //"Reservas de Orçamento"

Return

/*/{Protheus.doc} OFIA482

@author Renato Vinicius
@since 04/05/2023
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA4820415_VisualizaReservaOficina()

	FWExecView( STR0005, "OFIA481", MODEL_OPERATION_VIEW) //"Reservas de Oficina"

Return

/*/{Protheus.doc} OA4820447_ProcessaReservaAtendModelo2
	Função para fazer a gravação histórico da reserva e desreserva no Atendimento Modelo 2

	@type function
	@author Leandro Henrique Rodrigues
	@since 19/11/2025
/*/
Function OA4820447_ProcessaReservaAtendModelo2(cOperacao,nVW3Rec,cDocumento,aItensNew,aRecVW3,aHistIte,cTipo,cOrigem,nQtdMov,cArmDes,cArmOri,cMsgLog)

	Local aItemMov   := {}
	Local lPecDes    := .F.
	Local cTpReqDev  := ""
		
	DbSelectArea("SB1")
	SB1->(DbSetOrder(7))
	SB1->(DBSeek(xFilial("SB1") + VW3->VW3_GRUITE + VW3->VW3_CODITE))

	DbSelectArea("SB5")
	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5") + SB1->B1_COD ))

	cTpReqDev := cOperacao //Operação Default

	lPecDes := cTpReqDev == "R"
	
	aItemMov := OA4820035_AddArrayReservaItem(cTpReqDev,nQtdMov,cOrigem,lPecDes,cArmDes,cArmOri,,@cMsgLog,@aItensNew)

	aadd(aRecVW3,{nVW3Rec,aItemMov[16],cTpReqDev,lPecDes}) // Registro / Quantidade / Reserva ou Desreserva

	aAdd(aHistIte, aClone(OA4820457_AddArrayItemHistoricoReservaAtendimentModelo2(cTpReqDev,cDocumento,cTipo,aItemMov[16],aItemMov[4],aItemMov[5],aItemMov[9],aItemMov[10])))
	
Return

/*/{Protheus.doc} OA4820457_AddArrayItemHistoricoReservaAtendimentModelo2
	Função para fazer a gravação histórico da reserva e estorno (desreserva) do item no Atendimento Modelo 2 (VEIXA018)

	@type function
	@author Leandro Henrique Rodrigues
	@since 21/11/2025
/*/
Function OA4820457_AddArrayItemHistoricoReservaAtendimentModelo2(cTpReqDev,cDocumento,cTipo,nQtd,cArmOri,cEndOri,cArmDes,cEndDes)

	Local aItem := {}

	aadd(aItem,{"VW8_FILTRA" ,VW3->VW3_FILIAL  ,Nil})
	aadd(aItem,{"VW8_NUMTRA" ,VW3->VW3_NUMTRA  ,Nil})
	aadd(aItem,{"VW8_SEQITE" ,VW3->VW3_SEQUEN  ,Nil})	
	aadd(aItem,{"VW8_GRUITE" ,VW3->VW3_GRUITE  ,Nil})
	aadd(aItem,{"VW8_CODITE" ,VW3->VW3_CODITE  ,Nil})
	aadd(aItem,{"VW8_QUANT"  ,nQtd             ,Nil})
	aadd(aItem,{"VW8_ARMORI" ,cArmOri          ,Nil})
	aadd(aItem,{"VW8_ENDORI" ,cEndOri          ,Nil})
	aadd(aItem,{"VW8_ARMDES" ,cArmDes          ,Nil})
	aadd(aItem,{"VW8_ENDDES" ,cEndDes          ,Nil})
	aadd(aItem,{"VW8_DOCSDB" ,cDocumento       ,Nil})

	If cTpReqDev == "R"
		aadd(aItem,{"VW8_TIPREQ" ,cTipo,Nil})
	ElseIf cTpReqDev == "D"
		aadd(aItem,{"VW8_TIPDEV" ,cTipo,Nil})
	EndIf

Return aItem

/*/{Protheus.doc} OA4820467_GravaHistoricoMovAtendMod2
	Função para fazer a gravação histórico de movimentações do item no Atendimento Modelo 2 (VEIXA018)

	@type function
	@author Leandro Henrique Rodrigues
	@since 24/11/2025
/*/
Function OA4820467_GravaHistoricoMovAtendMod2(aHistAte)

	Local nI := 0
	Local aBkpRot := {}

	Private lMsErroAuto	:= .F.

	If Type("aRotina") == "U"
		aRotina := {}
	Else
		aBkpRot := aClone(aRotina)
	EndIf

	For nI := 1 To Len(aHistAte)

		oModelVW8 := FWLoadModel("OFIA543")
		FWMVCRotAuto(oModelVW8,"VW8",3,{{"VW8MASTER",aHistAte[ni]}})

		If ( lMsErroAuto )
			MostraErro()
			aRotina := aClone(aBkpRot)
			Return .f.
		EndIf
	Next

	aRotina := aClone(aBkpRot)

Return .t.

/*/{Protheus.doc} OA4820477_GravaDadosAtendModelo2
	Função para fazer a gravação dos dados no atendimendimento do que foi reservado / estornado (desreservado)

	@type function
	@author Renato Vinicius de Souza Santos
	@since 10/10/2022
/*/
Function OA4820477_GravaDadosAtendModelo2(aRecVW3,cDocumento)
	Local aArea   := GetArea()
	Local nI      := 0
	Local lDevolu := .F.

	For nI := 1 to Len(aRecVW3)

		lDevolu := .F.

		If aRecVW3[nI,3] == "D"
			lDevolu := .T.
		EndIf

		// lAtuRes := aRecVW3[nI,4]

		DbSelectArea("VW3")
		VW3->(DbGoTo(aRecVW3[nI,1]))
		
		RecLock("VW3",.f.)
			// If lAtuRes
				If lDevolu
					VW3->VW3_QTDRES -= aRecVW3[nI,2]
				Else
					VW3->VW3_QTDRES += aRecVW3[nI,2]
				EndIf

				If VW3->VW3_QTDRES == 0
					VW3->VW3_DOCSDB := ""
					VW3->VW3_RESERV := "0"
				Else
					If VW3->VW3_RESERV == "0"
						VW3->VW3_RESERV := "1"
					EndIf
					VW3->VW3_DOCSDB := cDocumento
				EndIf
			// EndIf
		MsUnLock()

	Next

	RestArea(aArea)
Return

/*/{Protheus.doc} OA4820487_VisualizaReservaAtendimento
	Função para apresentar a tela de atendimento modelos no historico do item na rotina analise de itens

	@type function
	@author Leandro Henrique Rodrigues
	@since 25/11/2025
/*/
Static Function OA4820487_VisualizaReservaAtendimento()

	FWExecView(STR0018, "OFIA543", MODEL_OPERATION_VIEW) //"Reserva no Atendimento Modelo 2"

Return
/*/{Protheus.doc} OA533008K_RegistraLOGVQL
	Função que registra os logs desde o inicio
	do processamento até a conclusão
	@type  Static Function
	@author Renato Vinicius
	@since 27/09/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function OA4820445_RegistraLogVQL(cMsgLog, cCodVQL, cOrigem, cNroDoc, lClose)

	Local aLogVQL	:= {}
	Local aVQL		:= {}

	Default cMsgLog	:= ""
	Default cOrigem	:= ""
	Default cCodVQL := ""
	Default cNroDoc	:= ""
	Default lClose	:= .F.

	If !lGerLog .and. left(cOrigem,2) <> "E-" // Quando for ERRO, vamos gravar o LOG independente se estiver habilitado o LOG 
		Return
	EndIf

	If Empty(cCodVQL)
//		aAdd(aVQL,{'VQL_CODVQL', ' '})
	Else
		aAdd(aVQL,{'VQL_CODVQL', cCodVQL })
	EndIf

	aAdd(aVQL,{'VQL_AGROUP',	'OFIA482'	})
	aAdd(aVQL,{'VQL_TIPO'  , 	cOrigem		}) // Pedido de Orçamento // Orçamento // Ordem de Serviço
	aAdd(aVQL,{'VQL_DADOS' , 	cNroDoc		}) // Nro do Pedido de Orçamento // Orçamento // Ordem de Serviço
	aAdd(aVQL,{'VQL_FILORI', 	xFilial()	})
	aAdd(aVQL,{'VQL_MSGLOG', 	cMsgLog })

	aAdd(aLogVQL,aClone(aVQL))

	cCodVQL := oLogger:LogToTable( aVQL )

	If lClose
		oLogger:CloseOpened(cCodVQL)
	Endif

Return cCodVQL

/*/{Protheus.doc} OA482016K_ItemDuplicadoNaReserva
	Função que unifica a quantidade movimentada de itens
	com mesmo grupo e código (B1_COD) igual e evitar o HELP 
	A42JACAD
	@type  Function
	@author Lucas Oliveira
	@since 28/10/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OA482016K_ItemDuplicadoNaReserva(aItensNew, aItemMov)

	Local nPosItem 		:= 0
	Default aItensNew	:= {}
	Default aItemMov	:= {}

	nPosItem := aScan(aItensNew, {|x|;
		x[1] == aItemMov[1] .and. ; // Código Produto Origem
		x[4] == aItemMov[2] .and. ; // Armázem Produto Origem
		x[6] == aItemMov[1] .and. ; // Código Produto Destino
		x[9] == aItemMov[3];		// Armázem Produto Destino
	})

Return nPosItem
