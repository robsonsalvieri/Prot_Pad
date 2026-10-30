#INCLUDE "PROTHEUS.CH"
#INCLUDE "VEIA331.CH"

/*/{Protheus.doc} VEIA331
	Cancelamento Individual do Agrega/Desagrega (VDV)

	@author Andre Luis Almeida
	@since 02/05/2023
/*/
Function VEIA331( nRecVDV )
Local lRet := .f.
Local oProcess // nao deixa cancelar tela
Private cDebugMIL := IIf(ExistBlock("DEBUGMIL"),ExecBlock("DEBBUGMIL",.f.,.f.),"")
Private cCadastro := STR0001 // Cancelamento Agrega/Desagrega
Private aRotina   := {	{ "" , "" , 0 , 1 },;
						{ "" , "" , 0 , 2 },;
						{ "" , "" , 0 , 3 },;
						{ "" , "" , 0 , 4 },;
						{ "" , "" , 0 , 5 }} // variavel necessária para rodar os VEIXX000 e VEIXX001
If nRecVDV > 0
	DbSelectArea("VDV")
	DbGoTo(nRecVDV)
	If VA3310021_ValidaCancelamento( nRecVDV , VDV->VDV_FILEXE , VDV->VDV_CODEXE )
		oProcess := MsNewProcess():New({|lEnd| VA3310011_Cancelar( @oProcess , @lEnd , cCadastro , nRecVDV ) },cCadastro,cCadastro,.T.) 
		oProcess:Activate()
		lRet := .t.
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} VA3310021_ValidaCancelamento
Executa o Cancelamento

@author Andre Luis Almeida
@since 10/05/2023
/*/
Static Function VA3310011_Cancelar( oProcess , lEnd , cTitProc , nRecVDV )
Local nCntFor    := 0
Local aCabNFE    := {}
Local aIteNFE    := {}
Local aRegSD2    := {}
Local aRegSE1    := {}
Local aRegSE2    := {}
Local aSB1SD3    := {}
Local aTemp      := {}
Local aTotVV1    := {}
Local aVDV       := {}
Local aAutoCab   := {}
Local cNumPed    := ""
Local lNFeCancel := SuperGetMV('MV_CANCNFE',.F.,.F.) .AND. SF2->(ColumnPos("F2_STATUS")) > 0
Local nQtdProc   := 4
Local lOk        := .T.

If VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
	If !Empty(VDV->VDV_ENUMNP)
		nQtdProc++
	EndIf
	If !Empty(VDV->VDV_SNUMNP)
		nQtdProc++
	EndIf
EndIf
//
oProcess:SetRegua1(nQtdProc)
VA3310041_Regua( oProcess , STR0016 ) // Iniciando
//
nOpc := 5 // Setar nOpc com 5 para chamar as funcoes padrao de Cancelamento.
//
If lNFeCancel
	If VDV->VDV_TIPDOC <> '2' .and. !Empty(VDV->VDV_SNUMNP) // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) ) e Possui NF de Saida de Pecas
		SF2->(DbSetOrder(1))
		SF2->(DbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP ))
		SD2->(DbSetOrder(3))
		SD2->(DbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP ))
		cNumPed := SD2->D2_PEDIDO
		If !FGX_STATF2("D",VDV->VDV_SSERNP,VDV->VDV_SNUMNP,SF2->F2_CLIENTE,SF2->F2_LOJA,"S") // verifica se NF foi Deletada
			If !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) .or. cDebugMIL == "VEIA331001"
				Return .f.
			Else
				PERGUNTE("MTA521",.f.)
				If !SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1))) .or. cDebugMIL == "VEIA331002"
					Return .f.
				Endif
			EndIf
			If !FGX_STATF2("V",VDV->VDV_SSERNP,VDV->VDV_SNUMNP,SF2->F2_CLIENTE,SF2->F2_LOJA,"S") .or. cDebugMIL == "VEIA331003" /// Verifica STATUS da NF no SEFAZ
				Return .f.
			EndIf
		EndIf
	EndIf
EndIf
//
aAdd(aVDV,{ "VDV_STATUS" , "0" }) // 0=Cancelado
//
BEGIN TRANSACTION
//
If VDV->VDV_TIPDOC <> '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
	//
	VA3310041_Regua( oProcess , STR0014+": "+Alltrim(VDV->VDV_ENUMNF)+" - "+VDV->VDV_ESERNF) // Nota Fiscal Entrada
	//
	//////////////////
	// NF ENTRADA   //
	//////////////////
	lMsErroAuto := .t.
	DbSelectArea("VVF")
	DbSetOrder(6) // VVF_FILIAL+VVF_NUMNFI+VVF_SERNFI+VVF_CODFOR+VVF_LOJA
	If DbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNF + VDV->VDV_ESERNF + VDV->VDV_ECDFOR + VDV->VDV_ELJFOR )
		VVF->(DbSetOrder(1))
		DbSelectArea("VVG")
		DbSetOrder(1) // VVG_FILIAL+VVG_TRACPA
		DbSeek( VVF->VVF_FILIAL + VVF->VVF_TRACPA )
		lMsErroAuto := .f.
		aAutoCab := {}
		aAdd(aAutoCab,{ "VVF_FILIAL" , VVF->VVF_FILIAL , Nil })
		aAdd(aAutoCab,{ "VVF_NUMTRA" , VVF->VVF_TRACPA , Nil }) // VVF_NUMTRA é pesquisado dentro do VEIXX000
		MSExecAuto({|x,y,w,z,k,l,m| VEIXX000(x,y,w,z,k,l,m)},aAutoCab,{},{},5,"0",NIL,.f.) // CANCELAMENTO
	EndIf
	//
	If !lMsErroAuto .and. !Empty(VDV->VDV_ENUMNP) // Possui NF de Entrada de Pecas
		//
		VA3310041_Regua( oProcess , STR0014+": "+Alltrim(VDV->VDV_ENUMNP)+" - "+VDV->VDV_ESERNP) // Nota Fiscal Entrada
		//
		DBSelectArea("SF1")
		DBSetOrder(1)
		dbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP )
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP )
		While !Eof() .and. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP
			aTemp := {}
			aAdd(aTemp,{"D1_DOC"   	,SD1->D1_DOC	,Nil})
			aAdd(aTemp,{"D1_SERIE" 	,SD1->D1_SERIE	,Nil})
			aAdd(aTemp,{"D1_FORNECE",SD1->D1_FORNECE,Nil})
			aAdd(aTemp,{"D1_LOJA"	,SD1->D1_LOJA	,Nil})
			aAdd(aTemp,{"D1_COD"    ,SD1->D1_COD	,Nil})
			aAdd(aTemp,{"D1_ITEM"   ,SD1->D1_ITEM	,Nil})
			aAdd(aIteNFE,aClone(aTemp))
			DBSelectArea("SD1")
			DbSkip()
		EndDo
		//#############################################################################
		//# Montagem do cabecalho para integracao MATA103                             #
		//#############################################################################
		aCabNFE := {}
		aAdd(aCabNFE,{"F1_DOC"	  ,SF1->F1_DOC    ,Nil})
		aAdd(aCabNFE,{"F1_SERIE"  ,SF1->F1_SERIE  ,Nil})
		aAdd(aCabNFE,{"F1_FORNECE",SF1->F1_FORNECE,Nil})
		aAdd(aCabNFE,{"F1_LOJA"   ,SF1->F1_LOJA   ,Nil})
		aAdd(aCabNFE,{"F1_TIPO"	  ,SF1->F1_TIPO   ,Nil})
		aAdd(aCabNFE,{"F1_FORMUL" ,SF1->F1_FORMUL ,Nil})
		aAdd(aCabNFE,{"F1_EMISSAO",SF1->F1_EMISSAO,Nil})
		aAdd(aCabNFE,{"F1_ESPECIE",SF1->F1_ESPECIE,Nil})
		aAdd(aCabNFE,{"F1_COND"	  ,SF1->F1_COND   ,Nil})
		aAdd(aCabNFE,{"F1_EST"	  ,SF1->F1_EST    ,Nil})
		If !Empty(SF1->F1_TRANSP)
			aAdd(aCabNFE,{"F1_TRANSP"  ,SF1->F1_TRANSP  ,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE1",SF1->F1_ESPECIE1,Nil})
			aAdd(aCabNFE,{"F1_VOLUME1" ,SF1->F1_VOLUME1 ,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE2",SF1->F1_ESPECIE2,Nil})
			aAdd(aCabNFE,{"F1_VOLUME2" ,SF1->F1_VOLUME2 ,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE3",SF1->F1_ESPECIE3,Nil})
			aAdd(aCabNFE,{"F1_VOLUME3" ,SF1->F1_VOLUME3 ,Nil})
			aAdd(aCabNFE,{"F1_ESPECIE4",SF1->F1_ESPECIE4,Nil})
			aAdd(aCabNFE,{"F1_VOLUME4" ,SF1->F1_VOLUME4 ,Nil})
		EndIf
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabNFE,aIteNFE,5) // CANCELAMENTO
	EndIf
	If lMsErroAuto .or. cDebugMIL == "VEIA331004"
		DisarmTransaction()
		MostraErro()
		lOk := .f.
		break
	EndIf
	//
	//////////////////
	// NF SAIDA	    //
	//////////////////
	//
	VA3310041_Regua( oProcess , STR0015+": "+Alltrim(VDV->VDV_SNUMNF)+" - "+VDV->VDV_SSERNF) // Nota Fiscal Saida
	//
	lMsErroAuto := .t.
	DbSelectArea("VV0")
	DbSetOrder(4) // VV0_FILIAL+VV0_NUMNFI+VV0_SERNFI
	If DbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNF + VDV->VDV_SSERNF )
		VV0->(DbSetOrder(1))
		DbSelectArea("VVA")
		DbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
		DbSeek( VV0->VV0_FILIAL + VV0->VV0_NUMTRA )
		lMsErroAuto := .f.
		aAutoCab := {}
		aAdd(aAutoCab,{ "VV0_FILIAL" , VV0->VV0_FILIAL , Nil })
		aAdd(aAutoCab,{ "VV0_NUMTRA" , VV0->VV0_NUMTRA , Nil })
		MSExecAuto({|x,y,w,z,k,l,m| VEIXX001(x,y,w,z,k,l,m)},aAutoCab,{},{},5,"0",NIL,.f.) // CANCELAMENTO
	EndIf
	//
	If !lMsErroAuto .and. !Empty(VDV->VDV_SNUMNP) // Possui NF de Saida de Pecas
		//
		VA3310041_Regua( oProcess , STR0015+": "+Alltrim(VDV->VDV_SNUMNP)+" - "+VDV->VDV_SSERNP) // Nota Fiscal Saida
		//
		DBSelectArea("SF2")
		DBSetOrder(1)
		dbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP )
		dbSelectArea("SD2")
		dbSetOrder(3)
		dbSeek( VDV->VDV_SFILNF + VDV->VDV_SNUMNP + VDV->VDV_SSERNP )
		cNumPed := SD2->D2_PEDIDO
		If !lNFeCancel
			aRegSD2 := {}
			aRegSE1 := {}
			aRegSE2 := {}
			If !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2) .or. cDebugMIL == "VEIA331005"
				lMsErroAuto := .t.
			Else
				PERGUNTE("MTA521",.f.)
				SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,(mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1)))
			EndIf
		Endif
		dbSelectArea("SC5")
		dbSetOrder(1)
		if !lMsErroAuto .and. dbSeek(xFilial("SC5")+cNumPed)
			aMata410Cab   := {{"C5_NUM",cNumPed,Nil}} // Numero do Pedido SC5
			aMata410Itens := {{"C6_NUM",cNumPed,Nil}} // Numero do Pedido SC6
			//Exclui Pedido
			SC9->(dbSetOrder(1))
			SC9->(dbSeek(xFilial("SC9")+cNumPed))
			While ( !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO ) .or. cDebugMIL == "VEIA331006"
				SC9->(a460Estorna())
				SC9->(dbSkip())
			EndDo
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aMata410Cab,{aMata410Itens},5) // CANCELAMENTO
		Endif
	EndIf
	If lMsErroAuto .or. cDebugMIL == "VEIA331007"
		DisarmTransaction()
		MostraErro()
		lOk := .f.
		break
	EndIf
	//
Else // Movimentacao Interna
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	// CRIAR MOVIMENTACAO INTERNA SD3 para reverter a Mov.Interna de Saida/Entrada realizada anteriormente //
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	VA3310041_Regua( oProcess , STR0003 ) // Mov.Interna
	//
	aSB1SD3 := VA3310031_Carrega_SD3( "1" , "1" , VDV->VDV_CODIGO , @aTotVV1 ) // Carregar Vetores dos SD3 para Cancela-los
	If len(aSB1SD3) > 0
		If !VA3300071_Movimentacoes_Internas( "2" , "0" , VDV->VDV_CODIGO ,   , aSB1SD3 ) .or. cDebugMIL == "VEIA331008" // Mov.Interna Peça ( 2=Saida , 0=Tp.Cancelamento , Codigo VDV , TM , aSB1 )
			DisarmTransaction()
			MostraErro()
			lOk := .f.
			break
		EndIf
	EndIf
	//
	VA3310041_Regua( oProcess , STR0003 ) // Mov.Interna
	//
	aSB1SD3 := VA3310031_Carrega_SD3( "2" , "1" , VDV->VDV_CODIGO , @aTotVV1 ) // Carregar Vetores dos SD3 para Cancela-los
	If len(aSB1SD3) > 0
		If !VA3300071_Movimentacoes_Internas( "1" , "0" , VDV->VDV_CODIGO ,   , aSB1SD3 ) .or. cDebugMIL == "VEIA331009" // Mov.Interna Peça ( 1=Entrada , 0=Tp.Cancelamento , Codigo VDV , TM , aSB1 )
			DisarmTransaction()
			MostraErro()
			lOk := .f.
			break
		EndIf
	EndIf
	//
	DbSelectArea("VV0")
	DbSetOrder(1) // VV0_FILIAL+VV0_NUMTRA
	If DbSeek( VDV->VDV_FILVV0 + VDV->VDV_NUMTRA )
		RecLock("VV0",.f.)
			VV0->VV0_SITNFI := "0" // 0=Cancelada
			VV0->VV0_STATUS := "C" // C=Cancelado
		MsUnLock()
	EndIf
	DbSelectArea("VVF")
	DbSetOrder(1) // VVF_FILIAL+VVF_TRACPA
	If DbSeek( VDV->VDV_FILVVF + VDV->VDV_TRACPA )
		RecLock("VVF",.f.)
			VVF->VVF_SITNFI := "0" // 0=Cancelada
		MsUnLock()
	EndIf
EndIf
//
END TRANSACTION

if lOk
	VA3310041_Regua( oProcess , STR0017 ) // Finalizando
//
	If VDV->VDV_TIPDOC == '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
		For nCntFor := 1 to len(aTotVV1)
			FGX_AMOVVEI(xFilial("VV1"),aTotVV1[nCntFor]) // VV1_CHASSI - Corrigir campos utilizados nas Movimentações
		Next
	EndIf
//
	VA3180011_MVC_CAD_VDV( nRecVDV , aVDV ) // Atualiza VDV
endif
Return lOk

/*/{Protheus.doc} VA3310021_ValidaCancelamento
Valida Cancelamento

@author Andre Luis Almeida
@since 02/05/2023
/*/
Static Function VA3310021_ValidaCancelamento( nRecVDV , cFilExe , cCodExe )
Local lRet       := .f.
Local lOk        := .t.
Local aUltMov    := {}
Local cQuery     := ""
Local cPictQtd   := x3Picture("B2_QATU")
Local nSaldoSB2  := 0
Local cPulaLinha := CHR(13)+CHR(10) // Pula linha
Local lSeekOK    := .f.
//
cQuery := "SELECT VDV.R_E_C_N_O_ "
cQuery += "FROM "+RetSQLName("VDV")+" VDV "
cQuery += "WHERE VDV.VDV_FILIAL = '"+xFilial("VDV")+"'"
cQuery += "  AND VDV.VDV_STATUS IN (' ','1') "
cQuery += "  AND VDV.R_E_C_N_O_ > "+str(nRecVDV)
cQuery += "  AND VDV.VDV_FILEXE = '"+cFilExe+"'"
cQuery += "  AND VDV.VDV_CODEXE = '"+cCodExe+"'"
cQuery += "  AND VDV.D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0 .or. cDebugMIL == "VEIA331010"
	MsgStop(STR0005,STR0004) // Para cancelar este movimento, será necessário cancelar todos os eventos posteriores! / Atenção
	lOk := .f.
EndIf
//
If lOk
	VV1->(DbSetOrder(1))
	VV1->(DbSeek(xFilial("VV1")+VDV->VDV_CHAINT))
	cQuery := "SELECT VDV.R_E_C_N_O_ "
	cQuery += "FROM "+RetSQLName("VDV")+" VDV "
	cQuery += "JOIN "+RetSQLName("VV1")+" VV1 ON ( VV1.VV1_FILIAL='"+xFilial("VV1")+"' AND VV1.VV1_CHAINT=VDV.VDV_CHAINT AND VV1.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VDV.VDV_FILIAL = '"+xFilial("VDV")+"'"
	cQuery += "  AND VDV.VDV_STATUS IN (' ','1') "
	cQuery += "  AND VDV.R_E_C_N_O_ > "+str(nRecVDV)
	cQuery += "  AND VDV.D_E_L_E_T_ = ' '"
	cQuery += "  AND VV1.VV1_CHASSI = '"+VV1->VV1_CHASSI+"'"
	If FM_SQL(cQuery) > 0
		MsgStop(STR0006+cPulaLinha+cPulaLinha+; // Para cancelar este movimento, será necessário cancelar todos os movimentos posteriores!
				STR0007+": "+VV1->VV1_CHASSI,STR0004) // Chassi / Atenção
		lOk := .f.
	EndIf
EndIf
//
If lOk
	//
	lSeekOK := .f.
	DbSelectArea("VVF")
	DbSetOrder(1) // VVF_FILIAL+VVF_TRACPA
	If DbSeek( VDV->VDV_EFILNF + VDV->VDV_TRACPA )
		lSeekOK := .t.
	EndIf
	If lSeekOK
		DbSelectArea("VVG")
		DbSetOrder(1) // VVG_FILIAL+VVG_TRACPA
		If DbSeek( VVF->VVF_FILIAL + VVF->VVF_TRACPA )
			While !Eof() .and. VVG->VVG_FILIAL + VVG->VVG_TRACPA == VVF->VVF_FILIAL + VVF->VVF_TRACPA
				DbSelectArea("VV1")
				DbSetOrder(1) // VV1_FILIAL+VV1_CHAINT
				DbSeek( xFilial("VV1") + VVG->VVG_CHAINT )
				If VV1->VV1_SITVEI<>"0" .or. cDebugMIL == "VEIA331011"
					MsgStop(STR0008+cPulaLinha+cPulaLinha+; // Equipamento não esta no Estoque!
							STR0007+": "+VV1->VV1_CHASSI,STR0004) // Chassi / Atenção
					lOk := .f.
					Exit
				EndIf
				aUltMov := FM_VEIUMOV( VV1->VV1_CHASSI , "E" , )
				If len(aUltMov) > 0
					If aUltMov[3] > VVF->VVF_TRACPA .or. cDebugMIL == "VEIA331012"
						MsgStop(STR0009+cPulaLinha+cPulaLinha+; // Impossivel cancelar movimentação anterior a ultima entrada!
								STR0007+": "+VV1->VV1_CHASSI,STR0004) // Chassi / Atenção
						lOk := .f.
						Exit
					EndIf
				EndIf
				DbSelectArea("VVG")
				DbSkip()
			EndDo
		EndIf
	EndIf
	//
	lSeekOK := .f.
	If lOk 
		DbSelectArea("VV0")
		DbSetOrder(1) // VV0_FILIAL+VV0_NUMTRA
		If DbSeek( VDV->VDV_FILVV0 + VDV->VDV_NUMTRA )
			lSeekOK := .t.
		EndIf
	EndIf
	If lSeekOK
		DbSelectArea("VVA")
		DbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
		If DbSeek( VV0->VV0_FILIAL + VV0->VV0_NUMTRA )
			While !Eof() .and. VVA->VVA_FILIAL + VVA->VVA_NUMTRA == VV0->VV0_FILIAL + VV0->VV0_NUMTRA
				DbSelectArea("VV1")
				DbSetOrder(1) // VV1_FILIAL+VV1_CHAINT
				DbSeek( xFilial("VV1") + VVA->VVA_CHAINT )
				aUltMov := FM_VEIUMOV( VV1->VV1_CHASSI , "S" , )
				If len(aUltMov) > 0
					If aUltMov[3] > VV0->VV0_NUMTRA .or. cDebugMIL == "VEIA331013"
						MsgStop(STR0010+cPulaLinha+cPulaLinha+; // Impossivel cancelar movimentação anterior a ultima saida!
								STR0007+": "+VV1->VV1_CHASSI,STR0004) // Chassi / Atenção
						lOk := .f.
						Exit
					EndIf
				EndIf
				DbSelectArea("VVA")
				DbSkip()
			EndDo
		EndIf
	EndIf
	//
	If lOk .and. VDV->VDV_AGRDES == "2" // 2=Desagrega
		If !Empty(VDV->VDV_SNUMNP) .or. cDebugMIL $ "VEIA331014/VEIA331015/" // Possui NF de Saida de Pecas
			lOk := .f.
			DbSelectArea("SD1")
			DbSetOrder(1) // D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA
			If DbSeek( VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP ) .or. cDebugMIL $ "VEIA331014/VEIA331015/"
				lOk := .t.
				While ( !Eof() .and. SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA == VDV->VDV_EFILNF + VDV->VDV_ENUMNP + VDV->VDV_ESERNP + VDV->VDV_ECDFOP + VDV->VDV_ELJFOP ) .or. cDebugMIL $ "VEIA331014/VEIA331015/"
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+SD1->D1_COD))
					SB2->(DbSetOrder(1))
					SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SD1->D1_LOCAL))
					nSaldoSB2 := SALDOSB2()
					If nSaldoSB2 < SD1->D1_QUANT .or. cDebugMIL == "VEIA331015"
						MsgStop(STR0011+cPulaLinha+cPulaLinha+; // Impossivel cancelar movimentação. Item com saldo insuficiente!
								SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+left(SB1->B1_DESC,20)+cPulaLinha+;
								STR0012+": "+Transform(SD1->D1_QUANT,cPictQtd)+cPulaLinha+; // Qtde
								STR0013+": "+Transform(nSaldoSB2,cPictQtd),STR0004) // Saldo / Atencao 
						lOk := .f.
						DbSelectArea("SD1")
						Exit
					EndIf
					DbSelectArea("SD1")
					DbSkip()
				EndDo
			EndIf
		ElseIf VDV->VDV_TIPDOC == '2' // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
			lOk := .f.
			DbSelectArea("VBH")
			DbSetOrder(2) // VBH_FILIAL + VBH_CODVDV + VBH_SAIENT
			If DbSeek( xFilial("VBH") + VDV->VDV_CODIGO + "1" ) // 1=Entrada
				lOk := .t.
				While !Eof() .and. VBH->VBH_FILIAL + VBH->VBH_CODVDV + VBH->VBH_SAIENT == xFilial("VBH") + VDV->VDV_CODIGO + "1" // 1=Entrada
					SD3->(DbSetOrder(2))
					SD3->(DbSeek(xFilial("SD3")+VBH->VBH_DOCSD3))
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+VBH->VBH_CODSB1))
					SB2->(DbSetOrder(1))
					SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SD3->D3_LOCAL))
					nSaldoSB2 := SALDOSB2()
					If nSaldoSB2 < SD3->D3_QUANT .or. cDebugMIL == "VEIA331016"
						MsgStop(STR0011+cPulaLinha+cPulaLinha+; // Impossivel cancelar movimentação. Item com saldo insuficiente!
								SB1->B1_GRUPO+" "+Alltrim(SB1->B1_CODITE)+" - "+left(SB1->B1_DESC,20)+cPulaLinha+;
								STR0012+": "+Transform(SD3->D3_QUANT,cPictQtd)+cPulaLinha+; // Qtde
								STR0013+": "+Transform(nSaldoSB2,cPictQtd),STR0004) // Saldo / Atencao 
						lOk := .f.
						DbSelectArea("VBH")
						Exit
					EndIf
					DbSelectArea("VBH")
					DbSkip()
				EndDo
			EndIf
		EndIf
	EndIf
	//
	lRet := lOk // Retorno das validações
	//
EndIf
//
Return lRet

/*/{Protheus.doc} VA3310031_Carrega_SD3
Carrega SD3 correspondente a Entrada/Saida ( VDV )

@author Andre Luis Almeida
@since 03/05/2023
/*/
Static Function VA3310031_Carrega_SD3( cSaiEnt , cTipMov , cCodVDV , aTotVV1 )
Local cGruVei   := left(GetMv("MV_GRUVEI")+space(10),len(SB1->B1_GRUPO))
Local aRetSD3   := {}
Local cQuery    := ""
Local cSQLAlias := "SQLSD3"
cQuery := "SELECT SB1.B1_COD , SB1.B1_DESC , SB1.B1_GRUPO , "
cQuery += "       SD3.D3_QUANT , SD3.D3_CUSTO1 , "
cQuery += "       SD3.D3_CC , SD3.D3_CONTA , SD3.D3_ITEMCTA , SD3.D3_CLVL "
cQuery += " FROM " + RetSqlName("VBH") + " VBH "
cQuery += " JOIN " + RetSqlName("SB1") + " SB1 "
cQuery += "   ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery += "  AND SB1.B1_COD = VBH.VBH_CODSB1 "
cQuery += "  AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " JOIN " + RetSqlName("SD3") + " SD3 "
cQuery += "   ON SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
cQuery += "  AND SD3.D3_DOC    = VBH.VBH_DOCSD3 "
cQuery += "  AND SD3.D3_NUMSEQ = VBH.VBH_NUMSEQ "
cQuery += "  AND SD3.D3_COD    = VBH.VBH_CODSB1 "
cQuery += "  AND SD3.D_E_L_E_T_ = ' ' "
cQuery += "WHERE VBH.VBH_FILIAL = '" + xFilial("VBH") + "' "
cQuery += "  AND VBH.VBH_CODVDV = '" + cCodVDV + "' " 
cQuery += "  AND VBH.VBH_SAIENT = '" + cSaiEnt + "' "
cQuery += "  AND VBH.VBH_TIPMOV = '" + cTipMov + "' "
cQuery += "  AND VBH.D_E_L_E_T_ = ' ' "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
While !(cSQLAlias)->(Eof())
	// ( Codigo SB1 , Qtde , Valor , Centro de Custo , Conta Contab , Item Conta , Class.Valor )
	aAdd(aRetSD3,{	(cSQLAlias)->( B1_COD ) ,;
					(cSQLAlias)->( D3_QUANT ) ,;
					Round((cSQLAlias)->( D3_CUSTO1 ),2) ,;
					(cSQLAlias)->( D3_CC ) ,;
					(cSQLAlias)->( D3_CONTA ) ,;
					(cSQLAlias)->( D3_ITEMCTA ) ,;
					(cSQLAlias)->( D3_CLVL ) })
	If (cSQLAlias)->( B1_GRUPO ) == cGruVei // somente Veiculos e AMS
		aAdd(aTotVV1,(cSQLAlias)->( B1_DESC )) // VV1_CHASSI
	EndIf
	(cSQLAlias)->(dbSkip())
EndDo
(cSQLAlias)->(dbCloseArea())
DbSelectArea("SD3")
Return aClone(aRetSD3)

/*/{Protheus.doc} VA3310041_Regua
Regua do Processo

@author Andre Luis Almeida
@since 10/05/2023
/*/
Static Function VA3310041_Regua( oProcess , cTitRegua )
oProcess:IncRegua1()
oProcess:SetRegua2(0)
oProcess:IncRegua2(cTitRegua)
Return
