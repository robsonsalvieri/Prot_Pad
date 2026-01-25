#INCLUDE 'WMSV070.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#DEFINE _CRLF CHR(13)+CHR(10)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥ WMSV070 | Autor ≥ Alex Egydio              ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Conferencia de mercadorias                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function WmsV070()
Local aAreaAnt  := GetArea()
//-- Salva todas as teclas de atalho anteriores
Local aSavKey    := VTKeys()
Local aAreaSDB   := SDB->(GetArea())
Local aPrdSYS    := {}
Local aLoteSYS   := {}
Local aJaConf    := {}
Local cEndereco  := Space(Len(SDB->DB_LOCALIZ))
Local cDocto     := Space(Len(SDB->DB_DOC))
Local cSerie     := Space(Len(SDB->DB_SERIE))
Local cCarga     := Space(Len(SDB->DB_CARGA))
Local cProduto   := Space(Len(SDB->DB_PRODUTO))
Local cPrdAnt    := Space(Len(SDB->DB_PRODUTO))
Local cRecHVazio := Space(Len(SDB->DB_RECHUM))
Local cDescPro   := ''
Local cDescPr2   := ''
Local cDescPr3   := ''
Local cLoteCtl   := ''
Local cServic    := SDB->DB_SERVIC
Local cTarefa    := SDB->DB_TAREFA
Local cAtivid    := SDB->DB_ATIVID
Local cLoja      := ''
Local cCliFor    := ''
Local cOrdTar    := SDB->DB_ORDTARE
Local dDataFec   := DToS(WmsData())
Local cAliasNew  := 'SDB'
Local cQuery     := ''
//-- 0=Permanece como antes ate a proxima versao
Local aSize      := {VTMaxCol()}
Local aUNI       := {}
Local aTelaAnt   := {}
//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM  := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local cWmsUMIAux := AllTrim(SuperGetMv('MV_WMSUMI',.F.,'0')) // Valor oficial do par‚metro (cWmsUMI pode mudar durante o processamento)
Local cWmsUMI    := cWmsUMIAux
Local nQtdNorma  := 0
Local nAviso     := 0

Local cPictQt    := ''
Local cUM        := ''
Local cDscUM     := ''
Local lEncerra   := .F.
Local lCarga     := .F.
Local lRet       := .T.
Local lZeraConf  := .F.
//-- Se sim leitura atraves codigo de barras, se nao digitacao
Local lDigita    := (SuperGetMV('MV_DLCOLET',.F.,'N')=='N')
//-- Solicita a confirmacao do lote nas operacoes com radio frequencia
Local lWmsLote   := SuperGetMv('MV_WMSLOTE',.F.,.F.)
//-- Forca selecionar Unidade de Medida a cada leitura do codigo do produto
Local lWMSConf   := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local lOcorr     := .F.
Local nMaxConta  := Val(SuperGetMV('MV_MAXCONT',.F.,'3'))
Local nContagem  := 0
Local nQtde      := 0
Local nQtde1UM   := 0
Local nQtde2UM   := 0
Local nSeek      := 0
Local nSeek1     := 0
Local nItem      := 0
Local n1Cnt      := 0
Local n2Cnt      := 0
Local nQtdLid    := 0
Local aRetPE     := {}
Local lDLV070PR  := ExistBlock('DLV070PR')
Local lDV070DOC  := ExistBlock('DV070DOC')
Local lDV070SCR  := ExistBlock('DV070SCR')
Local lDLV070CF  := ExistBlock('DLV070CF')
Local lDLV070RC  := ExistBlock('DLV070RC')
Local lDLV070RG  := ExistBlock('DLV070RG')
Local lDLV070FI  := ExistBlock('DLV070FI')
//-- Disponibiliza novamente o documento para convocaÁ„o quando o operador
//-- altera o documento ou abandona conferÍncia pelo Coletor RF.
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local aRetRegra  := {}

Private cCadastro := STR0001 //'Conferencia'

If !(cWmsUMI$'0˙1˙2˙3˙4˙5')
	DLVTAviso('WMSV07012',STR0002) //'Parametro MV_WMSUMI incorreto...'
	lRet := .F.
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
	Return(lRet)
EndIf
//-- Atribui a funcao de JA CONFERIDOS a combinacao de teclas <CTRL> + <Q>
VTSetKey(17,{||WmsV070Con(aJaConf,lCarga,cDocto,cSerie,cCarga)},STR0003) //'Ja Conferidos'
//-- Indica ao operador o endereco de destino da conferencia
DLVTCabec()
DLVEndereco(0,0,SDB->DB_LOCALIZ,SDB->DB_LOCAL,,,STR0004) //'Va para o Endereco'
If VTLastKey()==27 .And. DLVTAviso(cCadastro,STR0005,{STR0006,STR0007})==1 //'Deseja encerrar a conferencia?'###'Sim'###'Nao'
	lRet := .F.
	//-- Variavel definida no programa dlgv001
	DLVAltSts(.F.)

	//Grava SDB
	RecLock('SDB', .F.)  // Trava para gravacao
	SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
	SDB->DB_STATUS := cStatAExe // Atividade A Executar
	//-- Libera o registro do arquivo SDB
	MsUnlock()
	If lLiberaRH
		//-- Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
		WMSCancRH(cServic,cTarefa,cAtivid,Nil,Nil,Nil,Nil)
	EndIf
EndIf
If lRet
	While .T.
		DLVTCabec(cCadastro,.F.,.F.,.T.)
		@ 02, 00 VTSay PadR(STR0008,VTMaxCol()) //'Endereco'
		@ 03, 00 VTSay PadR(SDB->DB_LOCALIZ,VTMaxCol())
		@ 05, 00 VTSay PadR(STR0009, VTMaxCol()) //'Confirme !'
		@ 06, 00 VTGet cEndereco Pict '@!' Valid WmsV070End(SDB->DB_LOCALIZ,@cEndereco)
		VTRead
		If VTLastKey()==27
			If DLVTAviso(cCadastro,STR0005,{STR0006,STR0007})==1 //'Deseja encerrar a conferencia?'###'Sim'###'Nao'
				lRet := .F.
				//-- Variavel definida no programa dlgv001
				DLVAltSts(.F.)

				//Grava
				RecLock('SDB', .F.)  // Trava para gravacao
				SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
				SDB->DB_STATUS := cStatAExe // Atividade A Executar
				//-- Libera o registro do arquivo SDB
				MsUnlock()
				If lLiberaRH
					//-- Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
					WMSCancRH(cServic,cTarefa,cAtivid,Nil,Nil,Nil,Nil)
				EndIf
			Else
				Loop
			EndIf
		EndIf
		Exit
	EndDo
EndIf
If lRet
	While .T.
		//-- Confirmar Documento / Carga
		lCarga := WmsCarga(SDB->DB_CARGA)
		If lCarga
			DLVTCabec(,.F.,.F.,.T.)
			@ 01, 00 VTSay PadR(STR0040+SDB->DB_CARGA,VTMaxCol()) //"Carga: "
			@ 02, 00 VTGet cCarga Picture '@!'
		Else
			If lDV070DOC
				ExecBlock('DV070DOC', .F., .F.)
			EndIf
			DLVTCabec(,.F.,.F.,.T.)
			If SDB->DB_ORIGEM=="SC9"
				@ 01, 00 VTSay PadR(STR0064,VTMaxCol()) //"Pedido"
				@ 02, 00 VTSay PadR(SDB->DB_DOC,VTMaxCol())
				@ 03, 00 VTGet cDocto Picture '@!'
			Else
				@ 01, 00 VTSay PadR(STR0010,VTMaxCol()) //"Documento / Serie"
				@ 02, 00 VTSay PadR(SDB->DB_DOC,VTMaxCol())
				@ 03, 00 VTGet cDocto Picture '@!'
				@ 03, 12 VTGet cSerie Picture '@!'
			EndIf
		EndIf
		VTRead
		If VTLastKey()==27 .And. DLVTAviso(cCadastro,STR0005,{STR0006,STR0007})==1 //'Deseja encerrar a conferencia?'###'Sim'###'Nao'
			//-- Variavel definida no programa dlgv001
			DLVAltSts(.F.)
			lRet := .F.
			aPrdSYS  := {}
			aLoteSYS := {}
			RecLock('SDB', .F.) // Trava para gravacao
			SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
			SDB->DB_STATUS := cStatAExe // Atividade A Executar
			//-- Libera o registro do arquivo SDB
			MsUnlock()
			If lLiberaRH
				//-- Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
				WMSCancRH(cServic,cTarefa,cAtivid,Nil,Nil,Nil,cEndereco)
			EndIf
			Exit
		EndIf
		If lCarga
			If Empty(cCarga)
				cCarga := SDB->DB_CARGA
			EndIf
		Else
			If Empty(cDocto)
				cDocto := SDB->DB_DOC
			EndIf
			//-- Busca Cliente/Fornecedor e Loja
			BusCliForL(cServic,cTarefa,cAtivid,cDocto,cSerie,@cCliFor,@cLoja,cRecHVazio,cEndereco)
		EndIf
		//-- Se algum item do mesmo documento foi convocado p/ outro operador.
		If !(WmsExecAnt(cServic,cTarefa,cAtivid,cCarga,cDocto,cSerie,cEndereco))
			cDocto   := Space(Len(SDB->DB_DOC))
			cSerie   := Space(Len(SDB->DB_SERIE))
			cCarga   := Space(Len(SDB->DB_CARGA))
			Loop
		EndIf
		//-- Se o operador informou outro documento tira a reserva feita pelo dlgv001
		If (!lCarga .And. !Empty(cDocto) .And. cDocto <> SDB->DB_DOC  ) .Or. ;
			(!lCarga .And. !Empty(cSerie) .And. cSerie <> SDB->DB_SERIE) .Or. ;
			( lCarga .And. !Empty(cCarga) .And. cCarga <> SDB->DB_CARGA)
			If DLVTAviso('WMSV07003',STR0062,{STR0006,STR0007})==1 //"Deseja alterar docto/carga?"###"Sim"###"Nao"
				RecLock('SDB', .F.)  //-- Trava para gravacao
				SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
				SDB->DB_STATUS := cStatAExe // Atividade A Executar
				//-- Libera o registro do arquivo SDB
				MsUnlock()
				If lLiberaRH
					//-- Retira recurso humano atribuido as atividades de outros itens do mesmo pedido / carga.
					WMSCancRH(cServic,cTarefa,cAtivid,Nil,Nil,Nil,cEndereco)
				EndIf
				aPrdSYS  := {}
				aLoteSYS := {}
				DLVTCabec()
				@ 01, 00 VTSay PadC(STR0057, VTMaxCol()) //"Atencao"
				@ 02, 00 VTSay PadR(STR0058, VTMaxCol()) //"Docto alterado."
				@ 03, 00 VTSay PadR(STR0059, VTMaxCol()) //"Executar a"
				@ 04, 00 VTSay PadR(STR0060, VTMaxCol()) //"conferencia do"
				@ 05, 00 VTSay PadR(STR0061, VTMaxCol()) //"docto informado."
				DLVTRodaPe()
			Else
				//-- Restaura docto/carga original
				If lCarga
					cCarga := SDB->DB_CARGA
				Else
					cDocto := SDB->DB_DOC
				EndIf
			EndIf
		EndIf
		Exit
	EndDo
EndIf

If lRet
	VtAlert(STR0011,cCadastro,.T.,1000,3) //'Aguarde... Contando produtos.'

	cAliasNew := GetNextAlias()
	cQuery      := WMSQrySDB(cServic, cTarefa, cAtivid, lCarga, cCarga, cDocto, cSerie, cCliFor, cLoja, cRecHVazio, cEndereco)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

	If (cAliasNew)->(Eof()) .And. Empty(aPrdSYS)
		If !Empty(cDocto)
			DLVTAviso('WMSV07001',STR0012+cDocto+'/'+cSerie+STR0013) //'Documento:'###' nao encontrado!'
		Else
			DLVTAviso('WMSV07002',STR0014) //'Dados para conferencia nao encontrados!'
		EndIf
		lRet := .F.
		//-- Variavel definida no programa dlgv001
		DLVAltSts(.F.)
	Else
		SDB->(DbGoTo((cAliasNew)->SDBRECNO))
		aRetRegra := {}
		//-- Como trocou o documento, verifica novamente a regra de convocaÁ„o e analisa se convoca ou n„o
		If WmsRegra('1',SDB->DB_LOCAL,__cUserID,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,PadL(Posicione('SBE',1,xFilial('SBE')+SDB->DB_LOCAL+SDB->DB_LOCALIZ,SBE->BE_ESTFIS),Len(SBE->BE_ESTFIS),'0'),SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRegra,SDB->DB_RHFUNC,SDB->DB_CARGA)
			WmsRegra('2',SDB->DB_LOCAL,__cUserID,SDB->DB_SERVIC,SDB->DB_TAREFA,SDB->DB_ATIVID,SDB->DB_LOCALIZ,PadL(Posicione('SBE',1,xFilial('SBE')+SDB->DB_LOCAL+SDB->DB_LOCALIZ,SBE->BE_ESTFIS),Len(SBE->BE_ESTFIS),'0'),SDB->DB_ENDDES,SDB->DB_ESTDES,aRetRegra,SDB->DB_RHFUNC,SDB->DB_CARGA)
		EndIf
		While (cAliasNew)->(!Eof())
			lRet := WMSLockSDB((cAliasNew)->SDBRECNO, aPrdSYS, aLoteSYS)
			(cAliasNew)->(DbSkip())
		EndDo
	EndIf

	(cAliasNew)->(DbCloseArea())
	RestArea(aAreaSDB)
EndIf
cDscUM   := ''
cPictQt  := ''

//-- Ponto de entrada no inicio da conferencia.
If lDLV070PR
	lRet := ExecBlock('DLV070PR', .F., .F., {cProduto,aPrdSys})
EndIf

//-- Inicio da contagem de produtos
While lRet
	If lDigita
		cProduto := Space(Len(SDB->DB_PRODUTO))
	Else
		If Len(SB1->B1_CODBAR) > 48
			cProduto := Space(Len(SB1->B1_CODBAR))
		Else
			cProduto := Space(48) //-- Tamanho minimo da Etiqueta
		EndIf
	EndIf
	cDescPro := ''
	cDescPr2 := ''
	cDescPr3 := ''
	cLoteCtl := Space(Len(SDB->DB_LOTECTL))
	cUM      := ''
	aUNI     := {}
	lEncerra := .F.
	lOcorr   := .F.
	nQtde    := 0
	nSeek    := 0
	//--            1
	//--  01234567890123456789
	//--0 ____Conferencia____
	//--1 Produto
	//--2 PA1
	//--3 NOME DO PRODUTO
	//--4 Lote
	//--5 AUTO000636
	//--6 Quantidade
	//--7     240.00

	//-- Escolha do Produto a ser Conferido
	DLVTCabec()
	@ 01,00 VTSay PadR(STR0016,VTMaxCol()) //'Produto'
	@ 02,00 VTGet cProduto Pict '@!' Valid WmsV070Prd(aPrdSYS,@cProduto,@cDescPro,@cDescPr2,@cDescPr3,lDigita,cCarga,lCarga,@cLoteCtl,@nQtde,cServic,cTarefa,cAtivid,cDocto,cSerie,cCliFor,cLoja,cRecHVazio,cEndereco,aLoteSYS)
	//-- Descricao do Produto com tamanho especifico.
	@ 03,00 VTGet cDescPro When .F.
	@ 04,00 VTGet cDescPr2 When .F.
	@ 05,00 VTGet cDescPr3 When .F.
	//-- ajusta na tela quando necessario
	If lDV070SCR
		ExecBlock('DV070SCR',.F.,.F.,{cProduto,cDescPro})
	EndIf
	VTRead
	If VTLastKey()==27
		nAviso := DLVTAviso(cCadastro,STR0005,{/*STR0006,STR0007*/STR0065,STR0066}) //'Encerrar'##'Interromper'
		//If  DLVTAviso(cCadastro,STR0005,{STR0006,STR0007})==1 //'Deseja encerrar a conferencia?'###'Sim'###'Nao'
		If nAviso == 1
			lEncerra := .T.
		ElseIf nAviso == 2
			lEncerra := .T.
			//-- Variavel definida no programa dlgv001
			DLVAltSts(.F.)
			lRet := .F.
		Else
			Loop
		EndIf
	EndIf
	If lWmsLote .And. Rastro(cProduto) .And. aScan(aLoteSYS,{|x|x[1]==cProduto})>0
		@ 04,00 VTSay PadR(STR0017,VTMaxCol()) //'Lote'
		@ 05,00 VTGet cLoteCtl Picture PesqPict('SDB','DB_LOTECTL') When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid WmsV070Lot(aLoteSYS,cProduto,@cLoteCtl,lCarga)
		VTRead
		If VTLastKey()==27
			nAviso := DLVTAviso(cCadastro,STR0005,{/*STR0006,STR0007*/STR0065,STR0066}) //'Encerrar'##'Interromper'
			//If  DLVTAviso(cCadastro,STR0005,{STR0006,STR0007})==1 //'Deseja encerrar a conferencia?'###'Sim'###'Nao'
			If nAviso == 1
				lEncerra := .T.
			ElseIf nAviso == 2
				lEncerra := .T.
				//-- Variavel definida no programa dlgv001
				DLVAltSts(.F.)
				lRet := .F.
			Else
				Loop
			EndIf
		EndIf
	EndIf

	If !lEncerra .AND. lRet
		//-- Forca selecionar Unidade de Medida se informou produto diferente ou a cada leitura do codigo do produto
		If cProduto <> cPrdAnt .OR. lWMSConf
			cWmsUMI := cWmsUMIAux
			nItem   := 0
		EndIf
		SB1->(DbSetOrder(1))
		lEncerra := (Empty(cProduto) .Or. SB1->(!MsSeek(xFilial('SB1')+cProduto)))
		cPrdAnt := cProduto
	EndIf

	If !lEncerra .AND. lRet
		While .T. //Precisa existir While para o caso de dar loop pelo MV_WMSUMI ser igual a 3 ou 5 e n„o haver norma para estrutura
		//-- Indica a unidade de medida utilizada pelas rotinas de -RF-. 1=1a.UM / 2=2a.UM / 3=UNITIZADOR / 4=U.M.I.
		//-- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
		If cWmsUMI == '4'
			SB5->(DbSetOrder(1))
			SB5->(MsSeek(xFilial('SB5')+cProduto))
			cWmsUMI := SB5->B5_UMIND
			If !(cWmsUMI$'1˙2')
				cWmsUMI := '0'
			EndIf
		EndIf
		//-- Se db_qtsegum nao estiver preenchido
		If cWmsUMI $ '2˙3˙5'
			If (nSeek := aScan(aPrdSYS,{|x|x[1]==cProduto}))>0
				SDB->(MsGoTo(aPrdSYS[nSeek,5,1]))
				If SDB->DB_QTSEGUM==0
					cWmsUMI := '1'
				EndIf
			EndIf
		EndIf
			//-- Se parametro MV_WMSUMI = 3 ou 5, permite a escolha da U.M. com a qual ir· trabalhar
			If cWmsUMI $ '3˙5'
				If nItem == 0
				nQtdNorma := DLQtdNorma(cProduto,SDB->DB_LOCAL,SDB->DB_ESTFIS,@cDscUM,.F.)
				If nQtdNorma == 0
					//MV_WMSUMI 3 -> 4 Sem norma para Produto/ArmazÈm/Estrutura ####/####/####
					DLVTAviso(cCadastro,'MV_WMSUMI 3 -> 4    '+STR0067+' '+AllTrim(cProduto)+'/'+AllTrim(SDB->DB_LOCAL)+'/'+AllTrim(SDB->DB_ESTFIS),{})
					cWmsUMI := '4'
					Loop
				EndIf
				nItem := 3
				aAdd(aUNI,{cDscUM})
				aAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_SEGUM,'AH_UMRES')})
				aAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,   'AH_UMRES')})
				//--            1
				//--  01234567890123456789
				//--0 UNIDADE
				//--1 -------------------
				//--2 PALETE PBRII
				//--3 CAIXA
				//--4 PECA
				//--5 ___________________
				//--6
				//--7  Unidade p/Confer?
				aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
				DLVTCabec()
				DLVTRodaPe(STR0018,.F.) //'Unidade p/Confer?'
				nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{STR0019},aUNI,{VTMaxCol()},,nItem) //'Unidade'
				VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
				If nItem <= 0
					nItem := 3
				EndIf
				cDscUM := aUNI[nItem,1]
				If nItem == 1
					cPictQt:= '@R 9999999999'
					cUM    := ''
				ElseIf nItem == 2
					cPictQt:= PesqPict('SDB','DB_QTSEGUM')
					cUM    := SB1->B1_SEGUM
				ElseIf nItem == 3
					cPictQt:= PesqPict('SDB','DB_QUANT')
					cUM    := SB1->B1_UM
				EndIf
				If !Empty(cUM)
					SAH->(DbSetOrder(1))
					SAH->(MsSeek(xFilial('SAH')+cUM))
					cDscUM := PadR(SAH->AH_UMRES,VTMaxCol())
				EndIf
			EndIf
		Else
			If cWmsUMI $ '0˙1'
				cPictQt:= PesqPict('SDB','DB_QUANT')
				cUM    := SB1->B1_UM
			ElseIf cWmsUMI == '2'
				cPictQt:= PesqPict('SDB','DB_QTSEGUM')
				cUM    := SB1->B1_SEGUM
			EndIf
			SAH->(DbSetOrder(1))
			SAH->(MsSeek(xFilial('SAH')+cUM))
			cDscUM := PadR(SAH->AH_UMRES,VTMaxCol())
		EndIf
		@ 06,00 VTSay PadR('Qtde '+cDscUM,VTMaxCol())
		@ 07,00 VTGet nQtde Picture cPictQt When VTLastKey()==05 .Or. Empty(nQtde) Valid WmsV070Qtd(@nQtde,cProduto,cLoteCtl,aPrdSYS)
		VTRead
		If VTLastKey()==27 .And. DLVTAviso(cCadastro,STR0005,{STR0006,STR0007})==1 //'Deseja encerrar a conferencia?'###'Sim'###'Nao'
			lEncerra  := .T.
		EndIf
			Exit
		EndDo
	EndIf

	// Ponto de Entrada para tratamento de produtos lidos e encerramento
	If lDLV070CF .AND. lRet
		aRetPE   := { cProduto,cLoteCtl,nQtde,lEncerra,aPrdSys,aJaConf,lZeraConf }
		aRetPE   := ExecBlock('DLV070CF', .F., .F., aRetPE )
		If ValType(aRetPE) = 'A' .And. Len(aRetPE) >= 7
			cProduto := aRetPE[1]
			cLoteCtl := aRetPE[2]
			nQtde    := aRetPE[3]
			lEncerra := aRetPE[4]
			aPrdSys  := aRetPE[5]
			aJaConf  := aRetPE[6]

			lZeraConf := .F.
		Endif
	Endif

	If lEncerra .AND. lRet

		If !(lEncerra := AtividAnt(lCarga,cCarga,cDocto,cCliFor,cLoja,cServic,cOrdTar,dDataFec))
			DLVTAviso(cCadastro,STR0063) //Existem atividades anteriores n„o finalizadas
			Loop
		EndIf

		//-- Verifica se ha ocorrencias
		For n1Cnt := 1 To Len(aPrdSYS)
			If aPrdSYS[n1Cnt,3]<>aPrdSYS[n1Cnt,4] .And. ABS(QtdComp(aPrdSYS[n1Cnt,3]-aPrdSYS[n1Cnt,4])) > nToler1UM
				lOcorr := .T.
				Exit
			EndIf
		Next
		If lOcorr
			nContagem += 1
			For n1Cnt := 1 To Len(aJaConf)
				aJaConf[n1Cnt,2]:=0
				aJaConf[n1Cnt,3]:=0
			Next

			If nContagem >= nMaxConta
				DLVTAviso(cCadastro,STR0020+AllTrim(Str(nContagem))+STR0021) //'As divergencias encontradas na '###'a. conferencia serao registradas!'
				//-- Grava ocorrencia
				WmsV070Grv(aPrdSYS,cCarga,cDocto,cSerie,nContagem)
				lRet := .F.
				//-- Variavel definida no programa dlgv001
				DLVAltSts(.F.)
				Exit
			Else
				If DLVTAviso(cCadastro,STR0022+AllTrim(Str(nContagem))+STR0023,{STR0024,STR0025})==1 //'Divergencias encontradas na '###'a. conferencia!'###'Confere Novamente'###'Registra Ocorrencia'
					If lDLV070RC
						aRetPE := ExecBlock('DLV070RC', .F., .F., {aPrdSys})
						If ValType(aRetPE) == "A"
							aPrdSys := aRetPE
						EndIf
					EndIf
					//-- Zera a quantidade informada pelo operador para uma nova contagem
					n1Cnt:= 0
					lZeraConf := .T.
					For n1Cnt := 1 To Len(aPrdSYS)
						aPrdSYS[n1Cnt,4]:=0
						n2Cnt:= 0
						For n2Cnt := 1 To Len(aPrdSYS[n1Cnt,5])
							SDB->(DbGoTo(aPrdSYS[n1Cnt,5,n2Cnt]))
							If SDB->DB_STATUS <> cStatExec
								RecLock('SDB', .F.) // Trava para gravacao
								SDB->DB_QTDLID := 0
								MsUnlock() // Destrava apos gravacao
							EndIf
						Next
					Next
					Loop
				Else
					//-- Grava ocorrencia
					WmsV070Grv(aPrdSYS,cCarga,cDocto,cSerie,nContagem)
					lRet := .F.
					//-- Variavel definida no programa dlgv001
					DLVAltSts(.F.)
					Exit
				EndIf
			EndIf
		Else
			//-- Conferencia sem problemas
			WmsV070Grv(aPrdSYS)
			//-- Variavel definida no programa dlgv001
			DLVAltSts(.F.)
			Exit
		EndIf
	Else
		//Interrompe a conferecia, mantem com status interrompido
		//Para permitir sair e entrar novamente na mesma conferÍncia
		If !lRet
			Exit
		EndIf
		If !Empty(cProduto) .And. WmsV070Qtd(@nQtde,cProduto,cLoteCtl,aPrdSYS) .And. If(Empty(cLoteCtl),.T.,WmsV070Lot(aLoteSYS,cProduto,cLoteCtl,lCarga))
			//-- O sistema trabalha sempre na 1a.UM
			If cWmsUMI $ '0˙1'
				nQtde1UM := nQtde
				nQtde2UM := ConvUm(cProduto,nQtde,0,2)
			ElseIf   cWmsUMI == '2'
				//-- Converter de 2a.UM p/ 1a.UM
				nQtde2UM := nQtde
				nQtde    := ConvUm(cProduto,0,nQtde,1)
				nQtde1UM := nQtde
			ElseIf cWmsUMI $ '3˙5'
				//-- O nItem corresponde ao item selecionado pela funcao VTaBrowse quando cWmsUMI == '3' ou cWmsUMI == '5'
				//-- Converter de U.M.I. p/ 1a.UM
				If nItem == 1
					nQtde := (nQtde*nQtdNorma)
					nQtde1UM := nQtde
					nQtde2UM := ConvUm(cProduto,nQtde,0,2)
				//-- Converter de 2a.UM p/ 1a.UM
				ElseIf nItem == 2
					nQtde2UM := nQtde
					nQtde := ConvUm(cProduto,0,nQtde,1)
					nQtde1UM := nQtde
				EndIf
			EndIf
			//-- Registra a quantidade informada pelo operador na posicao [03] de aPrdSYS
			nSeek := ASCan(aPrdSYS,{|x|x[1]==cProduto .And. x[2]==cLoteCtl})

			If nSeek > 0
				aPrdSYS[nSeek,4]+=nQtde

				//Grava
				WmsCalcQtdLid(aPrdSYS[nSeek,5], nQtde)

				//-- Registra os produtos JA CONFERIDOS para posterior consulta atraves das teclas <CTRL> + <Q>
				If ( nSeek1 := ASCan(aJaConf,{|x|x[1]==cProduto}) ) == 0
					AAdd(aJaConf,{cProduto,0,0,' '})
					nSeek1 := Len(aJaConf)
				EndIf
				aJaConf[nSeek1,2]+=nQtde1UM
				aJaConf[nSeek1,3]+=nQtde2UM
				aJaConf[nSeek1,4]:=Iif(aPrdSYS[nSeek,3]==aPrdSYS[nSeek,4].Or.ABS(QtdComp(aPrdSYS[nSeek,3]-aPrdSYS[nSeek,4])) <= nToler1UM,' ','*')
			EndIf

			//-- Ponto de Entrada para tratamento de produtos lidos e conferidos registrados
			If lDLV070RG
				ExecBlock('DLV070RG', .F., .F., {aPrdSys,aJaConf})
			EndIf
		EndIf
	EndIf
EndDo
//-- Ponto de Entrada para tratamento validaÁ„o conferencia
If lDLV070FI
	ExecBlock('DLV070FI', .F., .F., {aPrdSys,aJaConf,cCarga})
EndIf

VTClear()
VTKeyBoard(chr(13))
VTInkey(0)
//-- Restaura as teclas de atalho anteriores
VTKeys(aSavKey)
RestArea(aAreaSDB)
RestArea(aAreaAnt)
Return(lRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSV070END| Autor ≥ Alex Egydio             ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Valida o endereco                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsV070End(cEnderSYS,cEndereco)
Local aAreaAnt := GetArea()
Local aAreaSBE := SBE->(GetArea())
Local lRet     := .T.
If cEndereco!=cEnderSYS
   DLVTAviso('WMSV07004',STR0026) //'Endereco incorreto!'
   VTKeyBoard(chr(20))
   lRet := .F.
EndIf
If lRet
   SBE->(DbSetOrder(9))
   If SBE->( ! MsSeek(xFilial('SBE')+cEndereco))
	  DLVTAviso('WMSV07005',STR0027+cEndereco+STR0028) //'O Endereco '###' nao esta cadastrado!'
	  VTKeyBoard(chr(20))
	  lRet := .F.
   EndIf
EndIf
RestArea(aAreaSBE)
RestArea(aAreaAnt)
Return(lRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSV070PRD| Autor ≥ Alex Egydio             ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Valida o produto                                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsV070Prd(aPrdSYS,cProduto,cDescPro,cDescPr2,cDescPr3,lDigita,cCarga,lCarga,cLoteCtl,nQtde,cServic,cTarefa,cAtivid,cDocto,cSerie,cCliFor,cLoja,cRecHVazio,cEndereco,aLoteSYS)
Local aAreaAnt := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local dDataFec := DToS(WmsData())
Local nMax      := VTMaxCol()
Local nSeek     := 0
Local lRet       := .T.
Local aProduto  := {}
Local aRetPE     := {}
Local nTipoConv := SuperGetMV('MV_TPCONVO',.F., 1 ) //-- 1=Por Atividade/2=Por Tarefa
Local cAliasNew := ''

If ExistBlock('DLV070VL')
   aRetPE   := ExecBlock('DLV070VL', .F., .F., {cProduto, aPrdSYS, lDigita})
   If ValType(aRetPE) <> 'A'
	  aRetPe := {.F.,"",""}
   Endif
   lRet     := aRetPE[1]
   cProduto := aRetPE[2]
   cDescPro := aRetPE[3]
   If len(aRetPe) >= 4
	  aPrdSYS  := aRetPE[4]
   Endif
Else
   aProduto := CBRetEtiEAN(cProduto)
   If Len(aProduto)>0
	  cProduto := aProduto[1]
	  nQtde    := 0 //-- Se nQtde = 0, solicita digitacao
	  cLoteCtl := Padr(aProduto[3],Len(SDB->DB_LOTECTL))
	  If ExistBlock("CBRETEAN")
		 nQtde := aProduto[2]
	  EndIf
   Else
	  aProduto := CBRetEti(cProduto, '01')
	  If Len(aProduto)>0
		 cProduto := aProduto[1]
		 nQtde    := aProduto[2]
		 cLoteCtl := Padr(aProduto[16],Len(SDB->DB_LOTECTL))
	  EndIf
   EndIf

   If Empty(aProduto)
	  DLVTAviso('WMSV07006',STR0029) //'Etiqueta invalida!'
	  VTKeyBoard(chr(20))
	  lRet := .F.
   EndIf
   If lRet
	  SB1->(DbSetOrder(1))
	  If !SB1->(MsSeek(xFilial('SB1')+cProduto))
		 DLVTAviso('WMSV07007',STR0030+AllTrim(cProduto)+STR0028) //'O produto '###' nao esta cadastrado!'
		 VTKeyBoard(chr(20))
		 lRet := .F.
	  EndIf
   EndIf
   If lRet
	  If (nSeek := aScan(aPrdSYS,{|x|x[1]==cProduto}))>0
		 SDB->(MsGoTo(aPrdSYS[nSeek,5,1]))
		 If !DLVExecAnt(nTipoConv,dDataFec,__cUserID)
			DLVTAviso("WMSV07014",STR0063) //"Existem atividades anteriores nao finalizadas"
			VTKeyBoard(chr(20))
			lRet := .F.
		 EndIf
	  Else
		 cAliasNew := GetNextAlias()
		 cQuery      := WMSQrySDB(cServic, cTarefa, cAtivid, lCarga, cCarga, cDocto, cSerie, cCliFor, cLoja, cRecHVazio, cEndereco, cProduto)
		 DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

		 If (cAliasNew)->(Eof())
			DLVTAviso('WMSV07008',STR0030+AllTrim(cProduto)+STR0031+Iif(lCarga,STR0032,STR0033)) //'O produto '###' nao consta '###'na carga'###'no documento'
			VTKeyBoard(chr(20))
			lRet := .F.
		 Else
			While (cAliasNew)->(!Eof())
			   lRet := WMSLockSDB((cAliasNew)->SDBRECNO, aPrdSYS, aLoteSYS)
			   (cAliasNew)->(DbSkip())
			EndDo
		 EndIf
	  EndIf
   EndIf
   If lRet
	  //-- Divide Descr. do produto em 3 linhas
	  cDescPro := SubStr(SB1->B1_DESC,       1,nMax)
	  cDescPr2 := SubStr(SB1->B1_DESC,  nMax+1,nMax)
	  cDescPr3 := SubStr(SB1->B1_DESC,2*nMax+1,nMax)
	  VtGetRefresh("cProduto")
	  VtGetRefresh("cDescPro")
	  VtGetRefresh("cDescPr2")
	  VtGetRefresh("cDescPr3")
   EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaAnt)
Return(lRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSV070QTD| Autor ≥ Alex Egydio             ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Valida a quantidade                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsV070Qtd(nQtde,cProduto,cLoteCtl,aPrdSYS)
Local lRet  := (nQtde>0)
Local aRetPE:= {}
If ExistBlock('DV070QTD')
   aRetPE := ExecBlock('DV070QTD', .F., .F., {lRet, nQtde, cProduto,cLoteCtl,aPrdSYS})
   lRet   := aRetPE[01]
   nQtde  := aRetPE[02]
EndIf
Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSV070GRV| Autor ≥ Alex Egydio             ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Confirma itens conferidos ou gera ocorrencia               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsV070Grv(aPrdSYS,cCarga,cDocto,cSerie,nContagem)
Local aAreaAnt  := GetArea()
Local n1Cnt    := 0
Local n2Cnt    := 0
//-- Ocorrencia
Local aOcorr   := {}
Local aLog     := {}
Local cLogFile := ""
Local lOcorr   := .F.
Local lRet     := .F.
Local lCarga   := .F.
Local lLote    := .F.
Local lSLote   := .F.
Local lWV070Grv   := ExistBlock("WV070GRV")
Local nTamDoc  := TamSX3('DB_DOC')[1]
Local nTamCar  := TamSX3('DB_CARGA')[1]
//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM   := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local cWmsDoc  := SuperGetMV("MV_WMSDOC",.F.,"")
Local lWmsv070 := SuperGetMV("MV_WMSV070",.F.,.T.)
Local nHandle  := 0
Local nQtde2UM  := 0
//--- Quando se tratar de Pre-Nota apaga os campos referentes ao servico de WMS.
Local cSeek     := ''
Local cComp     := ''
Local cLocal    := ''
Local cServic   := ''
Local cProduto  := ''
Local cSeqCar   := ''
Local cDoc      := ''
Local cSeri     := ''
Local cCliFor   := ''
Local cLoja     := ''
Local cLoteCTL  := ''
Local cNumLote  := ''
Private lAutoErrNoFile := .T.

//-- Verifica se houveram divergencias na contagem.
lOcorr := aScan(aPrdSYS,{|x|x[3]<>x[4] .And. ABS(QtdComp(x[3]-x[4])) > nToler1UM})>0

Begin Transaction
For n1Cnt := 1 To Len(aPrdSYS)
   //-- Verifica se contagem esta divergente.
   If lWmsv070
	  lOcorr := .F.
	  If aPrdSYS[n1Cnt,3]<>aPrdSYS[n1Cnt,4] .And. ABS(QtdComp(aPrdSYS[n1Cnt,3]-aPrdSYS[n1Cnt,4])) > nToler1UM
		 aAdd(aOcorr,{aPrdSYS[n1Cnt,1],aPrdSYS[n1Cnt,3],aPrdSYS[n1Cnt,1],aPrdSYS[n1Cnt,4]})
		 lOcorr := .T.
	  EndIf
   EndIf
   For n2Cnt := 1 To Len(aPrdSYS[n1Cnt,5])
	  SDB->(MsGoTo(aPrdSYS[n1Cnt,5,n2Cnt]))
	  RecLock('SDB',.F.)
	  SDB->DB_DATAFIM:= dDataBase
	  SDB->DB_HRFIM  := Time()
	  If lOcorr
		 SDB->DB_STATUS := cStatProb // Atividade com Problemas
		 SDB->DB_ANOMAL := 'S'
		 SDB->DB_QTDLID := 0 // Zera quantidade lida
		 If Empty(cCarga) .And. Empty(cDocto)
			cDocto := SDB->DB_DOC
		 EndIf
	  Else
		 SDB->DB_STATUS := cStatExec // Atividade Executada
	  EndIf
	  MsUnLock()
	  //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	  //≥ Quando se tratar de conferencia no pedido/carga com endereco informado (C9_BLWMS="02")    ≥
	  //≥ e servico WMS, executar a liberacao (C9_BLWMS="06")                                       ≥
	  //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	  If !lOcorr .And. SDB->DB_ORIGEM == 'SC9'
		 cLocal     := PadR(SDB->DB_LOCAL,   TamSX3('C9_LOCAL')[1])
		 cServic    := PadR(SDB->DB_SERVIC,  TamSX3('C9_SERVIC')[1])
		 cProduto   := PadR(SDB->DB_PRODUTO, TamSX3('C9_PRODUTO')[1])
		 cCarga     := PadR(SDB->DB_CARGA,   TamSX3('C9_CARGA')[1])
		 cSeqCar    := PadR(SDB->DB_SEQCAR,  TamSX3('C9_SEQCAR')[1])
		 cDoc       := PadR(SDB->DB_DOC,     TamSX3('C9_PEDIDO')[1])
		 cSeri      := PadR(SDB->DB_SERIE,   TamSX3('C9_ITEM')[1])
		 cLoteCTL   := PadR(SDB->DB_LOTECTL, TamSX3('C9_LOTECTL')[1])
		 cNumLote   := PadR(SDB->DB_NUMLOTE, TamSX3('C9_NUMLOTE')[1])
		 lLote      := Rastro(cProduto)
		 lSLote     := Rastro(cProduto,'S')
		 //-- Verifica se o servico diferente de conferencia 000005 - DLCONFEREN
		 DC5->(DbSetOrder(1)) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
		 If DC5->(MsSeek(xFilial('DC5')+cServic) .And. DC5_FUNEXE=='000005')
			If WmsCarga(cCarga)
			   cSeek := xFilial('SC9')+cCarga+cSeqCar
			   cComp := "C9_FILIAL+C9_CARGA+C9_SEQCAR"
			   SC9->(DbSetOrder(5)) //C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
			Else
			   cSeek := xFilial('SC9')+cDoc+cSeri
			   cComp := "C9_FILIAL+C9_PEDIDO+C9_ITEM"
			   SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			EndIf
			If SC9->(dbSeek(cSeek))
			   While SC9->(!EOF() .And. &cComp == cSeek)
				  If SC9->(C9_BLWMS=="02" .And. C9_BLEST=="  " .And. C9_BLCRED=="  ") .And. ;
					 SC9->(C9_LOCAL+C9_SERVIC+C9_PRODUTO == cLocal+cServic+cProduto)   .And. ;
					 Iif(lLote  .And. !Empty(SC9->C9_LOTECTL) .And. !Empty(cLoteCTL),SC9->C9_LOTECTL == cLoteCTL,.T.) .And.;
					 Iif(lSLote .And. !Empty(SC9->C9_NUMLOTE) .And. !Empty(cNumLote),SC9->C9_NUMLOTE == cNumLote,.T.) .And.;
					 RecLock("SC9",.F.)
					 C9_BLWMS := "06"
					 SC9->(MsUnlock())
				  EndIf
				  SC9->(dbSkip())
			   EndDo
			EndIf
		 EndIf
	  EndIf
	  If lWV070Grv
		 Execblock("WV070GRV",.F.,.F.,{lOcorr})
	  EndIf
   Next n2Cnt
Next n1Cnt
End Transaction

If Len(aOcorr)>0
   VTAlert(STR0034,STR0035, .T., 3000, 3) //'Aguarde... Gerando o LOG.'###'Processamento'
   If !Empty(cCarga)
	  cLogFile := "RF"+PadR(cCarga,nTamCar)+".LOG"
   Else
	  cLogFile := "RF"+AllTrim(PadR(cDocto,nTamDoc))+".LOG"
   EndIf
   //-- MV_WMSDOC - Define o diretorio onde serao armazenados os documentos/logs gerados pelo WMS.
   //-- Este parametro deve estar preenchido com um diretorio criado abaixo do RootPath.
   //-- Exemplo: Preencha o parametro com \WMS para o sistema mover o log de ocorrencias do diretorio
   //-- C:\MP8\SYSTEM p/o diretorio C:\MP8\WMS
   If !Empty(cWmsDoc)
	  cWmsDoc := AllTrim(cWmsDoc)
	  If Right(cWmsDoc,1)$"/\"
		 cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
	  EndIf
	  cLogFile := cWmsDoc+"\"+cLogFile
   EndIf
   //-- Gera array Log
   AutoGrLog(OemToAnsi(STR0036) + cLogFile + ")") //"Microsiga Protheus WMS - LOG de Ocorrencias na Conferencia ("
   AutoGrLog(OemToAnsi(STR0037) + DtoC(dDataBase) + OemToAnsi(STR0038) + Time()) //"Log gerado em "###", as "
   AutoGrLog(OemToAnsi(STR0039) + AllTrim(SubStr(cUsuario,7,15))) //"Usuario: "
   If !Empty(cCarga)
	  AutoGrLog(OemToAnsi(STR0040) + AllTrim(cCarga)) //"Carga: "
   Else
	  AutoGrLog(OemToAnsi(STR0041) + AllTrim(cDocto) + STR0042 + AllTrim(cSerie)) //"Documento: "###" / Serie: "
   EndIf
   AutoGrLog(OemToAnsi(STR0043) + AllTrim(Str(nContagem))) //"Contagem no.: "
   AutoGrLog(If(Len(aOcorr)>1, OemToAnsi(STR0044) + AllTrim(Str(Len(aOcorr))) + ") : ", OemToAnsi(STR0045))) //"Ocorrencias ("###"Ocorrencia :"
   AutoGrLog("--------------------------------------++--------------------------------")
   AutoGrLog(PadC(STR0046,38)+"||"+PadC(STR0047,32)) //"Contagem do Sistema"###"Contagem do Usuario"
   AutoGrLog("-----+-----------------+--------------++-----------------+--------------")
   AutoGrLog(PadR("Item",5)+"|"+PadR(STR0048,17)+"|"+PadR(STR0049,14)+"||"+PadR(STR0048,17)+"|"+PadR(STR0049,14)) //"Produto"###"Quantidade"###"Produto"###"Quantidade"
   AutoGrLog("-----+-----------------+--------------++-----------------+--------------")
   For n1Cnt := 1 To Len(aOcorr)
	  AutoGrLog(StrZero(n1Cnt,3)+"  |"+PadR(aOcorr[n1Cnt,1],16)+" |"+Transform(aOcorr[n1Cnt,2],PesqPict('SDB', 'DB_QUANT'))+"||"+PadR(aOcorr[n1Cnt,3],16)+" | "+Transform(aOcorr[n1Cnt,4],PesqPict('SDB', 'DB_QUANT')))
	  If (nQtde2UM := ConvUm(aOcorr[n1Cnt,1],aOcorr[n1Cnt,2],0,2))>0
		 AutoGrLog("     |                 |"+Transform(nQtde2UM,PesqPict('SDB', 'DB_QUANT'))+ "||                 | "+Transform(ConvUm(aOcorr[n1Cnt,3],aOcorr[n1Cnt,4],0,2),PesqPict('SDB', 'DB_QUANT')))
	  EndIf
   Next
   AutoGrLog("-----+-----------------+--------------++-----------------+--------------")
   //-- Grava Arquivo Log
   aLog := GetAutoGRLog()
   If !File(cLogFile)
	  If (nHandle := MSFCreate(cLogFile,0)) <> -1
		 lRet := .T.
	  EndIf
   Else
	  If (nHandle := FOpen(cLogFile,2)) <> -1
		 FSeek(nHandle,0,2)
		 lRet := .T.
	  EndIf
   EndIf
   If lRet
	  For n1Cnt := 1 To Len(aLog)
		 FWrite(nHandle,aLog[n1Cnt]+_CRLF)
	  Next
	  FClose(nHandle)
   EndIf
   DLVTAviso('WMSV07009',STR0050+cLogFile+STR0051) //'O LOG '###' foi gerado. Entre em contato com seu Supervisor.'
   VTClear()
EndIf
RestArea(aAreaAnt)
Return NIL
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSV070LOT| Autor ≥ Alex Egydio             ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Valida o lote                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsV070Lot(aLoteSYS,cProduto,cLoteCtl,lCarga)
Local cRetPE := ""
Local lRet   := .T.

//-- PE para tratar o numero do lote.
If ExistBlock("WV070LOT")
   cRetPE := ExecBlock("WV070LOT",.F.,.F.,{cProduto,cLoteCtl})
   If ValType(cRetPE) == "C"
	  cLoteCtl := cRetPE
   EndIf
EndIf

lRet := !Empty(cLoteCtl)
If lRet .And. Len(aLoteSYS)>0 .And. aScan(aLoteSYS,{|x|x[1]==cProduto.And.x[2]==cLoteCtl})==0
   DLVTAviso('WMSV07010',STR0052+AllTrim(cLoteCtl)+STR0031+Iif(lCarga,STR0032,STR0033)+STR0053) //'O lote '###' nao consta '###'na carga'###'no documento'###' atual!'
   lRet := .F.
EndIf
Return(lRet)
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSV070CON| Autor ≥ Alex Egydio             ≥Data≥12.02.2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Consulta produtos conferidos                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ ExpA1 = vetor dos produtos ja conferidos                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsV070Con(aJaConf,lCarga,cDocto,cSerie,cCarga)
Local aCab     := {STR0016,STR0049,STR0054,' '} //"Produto"###"Quantidade"###"Quant.2aUM"
Local aSize    := {Len(SDB->DB_PRODUTO), Len(aCab[2]), Len(aCab[3]), Len(aCab[4])}
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
If Len(aJaConf) > 0
   //--            1
   //--  01234567890123456789
   //--0 Produto    |Quantidade|Quant.2aUM|
   //--1 -----------|----------|----------|-
   //--2 PA1        |       240|*
   //--3 PA2        |       240|*
   //--4
   //--5 ___________________
   //--6
   //--7 * Divergente
   VTClear()
   DLVTRodaPe(STR0055,.F.) //"* Divergente"
   If lCarga
	  @ 00, 00 VTSay PadR(STR0040,VTMaxCol()) //"Carga: "
	  @ 01, 00 VTSay PadR(cCarga,VTMaxCol())
   Else
	  @ 00, 00 VTSay PadR(STR0012,VTMaxCol()) //"Documento:"
	  @ 01, 00 VTSay PadR(cDocto+" / "+cSerie,VTMaxCol())
   EndIf
   VTaBrowse(02, 00, VTMaxRow()-2, VTMaxCol(), aCab, aJaConf, aSize)
   VTRestore(00, 00, VTMaxRow(),   VTMaxCol(), aTelaAnt)
Else
   DLVTAviso('WMSV07011',STR0056) //'Nenhum produto conferido...'
EndIf
Return NIL
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSExecAnt≥ Autor ≥ Flavio Luiz Vicco     ≥ Data ≥ 26.01.10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Analisa se a atividade anterior ja foi executada, se sim   ≥±±
±±≥          ≥  permite ir para a proxima atividade.                      ≥±±
±±≥          ≥  E se tarefa em andamento por outro operador.              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ WmsExecAnt( ExpC1, ExpC2, ExpC3 )                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ WMSV070                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WmsExecAnt(cServic,cTarefa,cAtivid,cCarga,cDocto,cSerie,cEndereco)
   Local aAreaAnt  := SDB->(GetArea())
   Local lCarga    := WmsCarga(cCarga)
   Local cRecHVazio:= Space(TamSX3('DB_RECHUM')[1])
   Local cCliFor   := SDB->DB_CLIFOR
   Local cLoja     := SDB->DB_LOJA
   Local cIdopera  := SDB->DB_IDOPERA
   Local cAliasNew := 'SDB'
   Local cQuery    := ''
   Local lRet      := .T.

   cAliasNew := GetNextAlias()
   cQuery := " SELECT SDB.R_E_C_N_O_ SDBRECNO"
   cQuery += " FROM "+RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery += " AND DB_DOC      = '"+cDocto+"'"
   cQuery += " AND DB_SERIE    = '"+cSerie+"'"
   cQuery += " AND DB_CLIFOR   = '"+cCliFor+"'"
   cQuery += " AND DB_LOJA     = '"+cLoja+"'"
   cQuery += " AND DB_ATUEST   = 'N'"
   cQuery += " AND DB_ESTORNO  = ' '"
   cQuery += " AND (DB_SERVIC <> '"+cServic+"'"
   cQuery += "  OR (DB_SERVIC = '"+cServic+"' AND DB_TAREFA <> '"+cTarefa+"'))"
   cQuery += " AND DB_IDOPERA < '"+cIdopera+"'"
   cQuery += " AND DB_STATUS IN ('"+cStatAExe+"','"+cStatInte+"','"+cStatProb+"')"
   cQuery += " AND SDB.D_E_L_E_T_ = ' ' "
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
   lRet := (cAliasNew)->(Eof())
   (cAliasNew)->(DbCloseArea())
   If !lRet
	  DLVTAviso("WMSV07014",STR0063) //"Existem atividades anteriores nao finalizadas"
	  RestArea(aAreaAnt)
	  Return lRet
   EndIf

   cAliasNew := GetNextAlias()
   cQuery := " SELECT SDB.R_E_C_N_O_ SDBRECNO"
   cQuery += " FROM " + RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery += " AND DB_ESTORNO  = ' '"
   cQuery += " AND DB_ATUEST   = 'N'"
   cQuery += " AND DB_SERVIC   = '"+cServic+"'"
   cQuery += " AND DB_TAREFA   = '"+cTarefa+"'"
   cQuery += " AND DB_ATIVID   = '"+cAtivid+"'"
   If lCarga
	  cQuery += " AND DB_CARGA = '"+cCarga+"'"
   Else
	  cQuery += " AND DB_DOC   = '"+cDocto+"'"
	  If !Empty(cSerie)
		 cQuery += " AND DB_SERIE  = '"+cSerie+"'"
	  EndIf
	  cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
	  cQuery += " AND DB_LOJA   = '"+cLoja+"'"
   EndIf
   cQuery += " AND (DB_RECHUM  <> '"+cRecHVazio+"'"
   cQuery += " AND  DB_RECHUM  <> '"+__cUserID+"')"
   cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
   cQuery += " AND D_E_L_E_T_  = ' '"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
   lRet := (cAliasNew)->(Eof())
   (cAliasNew)->(DbCloseArea())
   If !lRet
	  DLVTAviso("WMSV07013",STR0015) //"Tarefa em andamento por outro operador"
   EndIf
   RestArea(aAreaAnt)
Return lRet
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥WMSCancRH ≥ Autor ≥ Flavio Luiz Vicco     ≥ Data ≥ 26.01.10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Retira recurso humano atribuido as atividades de           ≥±±
±±≥          ≥ conferencia de outros itens do mesmo pedido / carga.       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ WMSCancRH( ExpC1, ExpC2, ExpC3 )                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ WMSV070                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function WMSCancRH(cServic,cTarefa,cAtivid,cCarga,cDocto,cSerie,cEndereco)
Local aAreaAnt    := SDB->(GetArea())
Local cAliasNew      := 'SDB'
Local cQuery      := ''
Local cRecHVazio  := Space(TamSX3('DB_RECHUM')[1])

Default cServic      := SDB->DB_SERVIC
Default cTarefa      := SDB->DB_TAREFA
Default cAtivid      := SDB->DB_ATIVID
Default cCarga    := SDB->DB_CARGA
Default cDocto    := SDB->DB_DOC
Default cSerie    := SDB->DB_SERIE
Default cEndereco := SDB->DB_LOCALIZ

   cAliasNew := GetNextAlias()
   cQuery := " SELECT SDB.R_E_C_N_O_ SDBRECNO"
   cQuery += " FROM " + RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery += " AND DB_ESTORNO  = ' '"
   cQuery += " AND DB_ATUEST   = 'N'"
   cQuery += " AND DB_SERVIC   = '"+cServic+"'"
   If WmsCarga(cCarga)
	  cQuery += " AND DB_CARGA = '"+cCarga+"'"
   Else
	  If !Empty(cDocto)
		 cQuery += " AND DB_DOC   = '"+cDocto+"'"
		 If !Empty(cSerie) .And. (SDB->DB_ORIGEM != 'SC9')
			cQuery += " AND DB_SERIE = '"+cSerie+"'"
		 EndIf
	  EndIf
   EndIf
   cQuery += " AND DB_STATUS   = '"+cStatAExe+"'" // Atividade A Executar
   cQuery += " AND DB_RECHUM   = '"+__cUserID+"'"
   cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
   cQuery += " AND D_E_L_E_T_  = ' '"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
   While (cAliasNew)->(!Eof())
	  SDB->(MsGoto((cAliasNew)->SDBRECNO))
	  RecLock('SDB', .F.)  // Trava para gravacao
	  SDB->DB_RECHUM := cRecHVazio
	  MsUnlock()
	  (cAliasNew)->(DbSkip())
   EndDo
   (cAliasNew)->(DbCloseArea())
   RestArea(aAreaAnt)

Return

//----------------------------------------------------------
/*/{Protheus.doc}
Seta DB_STATUS para Servico em Execucao

@author
@version P11
@Since    20/02/2014
@obs
/*/
//----------------------------------------------------------
Static Function WMSLockSDB(nRecno, aPrdSYS, aLoteSYS)
   Local lRet  := .T.
   Local nSeek := 0

		 SDB->(MsGoto(nRecno))
		 If !SoftLock("SDB")
			DLVTAviso('WMSV07013',STR0015) //"Tarefa em andamento por outro operador"
			lRet := .F.
			//-- Variavel definida no programa dlgv001
			DLVAltSts(.F.)
		 EndIf
		 If lRet
			RecLock('SDB',.F.)
			SDB->DB_RECHUM := __cUserID
			SDB->DB_STATUS := cStatInte // Atividade Em Execucao
			SDB->DB_DATA   := dDataBase
			SDB->DB_HRINI  := Time()
			//-- Formato do vetor aPrdSYS
			//-- [01] = Produto
			//-- [02] = Quantidade registrada pelo sistema
			//-- [03] = Lote
			//-- [04] = Quantidade informada pelo operador
			//-- [05] = Vetor unidimensional contendo os registros do arquivo SDB
			//-- Inclui produto no array aTotPrdSY
			If (nSeek:=aScan(aPrdSYS,{|x|x[1]==SDB->DB_PRODUTO .And. x[2]==SDB->DB_LOTECTL})) == 0
			   AAdd(aPrdSYS,{SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_QUANT,SDB->DB_QTDLID,{}})
			   nSeek := Len(aPrdSYS)
			Else
			   //-- Soma a quantidade
			   aPrdSYS[nSeek, 3] += SDB->DB_QUANT
			   aPrdSYS[nSeek, 4] += SDB->DB_QTDLID
			EndIf
			//-- Inclui nr.do registro do SDB
			AAdd(aPrdSYS[nSeek,5],SDB->(Recno()))
			//-- Inclui lote no array aLoteSYS, para validacao apos a digitacao do lote
			If !Empty(SDB->DB_LOTECTL) .And. aScan(aLoteSYS,{|x|x[1]==SDB->DB_PRODUTO.And.x[2]==SDB->DB_LOTECTL})==0
			   aAdd(aLoteSYS,{SDB->DB_PRODUTO,SDB->DB_LOTECTL})
			EndIf
			//-- Libera o registro do arquivo SDB
			MsUnlock()
		 EndIf
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc}
Monta a query para busca dos itens da conferÍncia

@author
@version P11
@Since    20/02/2014
@obs
/*/
//----------------------------------------------------------
Static Function WMSQrySDB(cServic, cTarefa, cAtivid, lCarga, cCarga, cDocto, cSerie, cCliFor, cLoja, cRecHVazio, cEndereco, cProduto)
   Local cQuery      := ''
   Local cRetPE      := ""

   cQuery := " SELECT SDB.R_E_C_N_O_ SDBRECNO"
   cQuery += " FROM " + RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery += " AND DB_ESTORNO  = ' '"
   cQuery += " AND DB_ATUEST   = 'N'"
   cQuery += " AND DB_SERVIC   = '"+cServic+"'"
   cQuery += " AND DB_TAREFA   = '"+cTarefa+"'"
   cQuery += " AND DB_ATIVID   = '"+cAtivid+"'"
   If !Empty(cProduto)
	  cQuery += " AND DB_PRODUTO = '"+cProduto+"'"
   EndIf
   If lCarga
	  cQuery += " AND DB_CARGA = '"+cCarga+"'"
   Else
	  If !Empty(cDocto)
		 cQuery += " AND DB_DOC   = '"+cDocto+"'"
		 If !Empty(cSerie)
			cQuery += " AND DB_SERIE = '"+cSerie+"'"
		 EndIf
		 cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
		 cQuery += " AND DB_LOJA   = '"+cLoja+"'"
	  EndIf
   EndIf
   cQuery += " AND DB_STATUS   IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
   cQuery += " AND (DB_RECHUM  = '"+cRecHVazio+"'"
   cQuery += " OR   DB_RECHUM  = '"+__cUserID+"')"
   cQuery += " AND DB_LOCALIZ  = '"+cEndereco+"'"
   cQuery += " AND D_E_L_E_T_  = ' '"
   If ExistBlock("DV070QRY")
	  cRetPE := ExecBlock("DV070QRY",.F.,.F.,{ cQuery })
	  cQuery := If(ValType(cRetPE)=="C", cRetPE, cQuery)
   EndIf
   cQuery := ChangeQuery(cQuery)
Return cQuery

//----------------------------------------------------------
/*/{Protheus.doc}
Verifica se existem atividades anteriores n„o finalizadas

@author
@version P11
@Since    25/03/2014
@obs
/*/
//----------------------------------------------------------
Static Function AtividAnt(lCarga,cCarga,cDocto,cCliFor,cLoja,cServic,cOrdTar,dDataFec)
Local cAreaAnt    := GetArea()
Local cAliasNext  := ''
Local cQuery      := ''
Local lRet        := .T.

cAliasNext := GetNextAlias()
cQuery := "SELECT DB_STATUS"
cQuery += " FROM "+RetSqlName('SDB')+" SDB"
cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
If lCarga
   cQuery += " AND DB_CARGA  = '"+cCarga+"'"
Else
   cQuery += " AND DB_DOC    = '"+cDocto+"'"
   cQuery += " AND DB_CLIFOR = '"+cCliFor+"'"
   cQuery += " AND DB_LOJA   = '"+cLoja+"'"
EndIf
cQuery += "    AND DB_SERVIC  = '"+cServic+"'"
cQuery += "    AND DB_ORDTARE < '"+cOrdTar+"'"
cQuery += "    AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
cQuery += "    AND DB_ATUEST  = 'N'"
cQuery += "    AND DB_ESTORNO = ' '"
cQuery += "    AND SDB.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNext,.F.,.T.)

lRet := Iif((cAliasNext)->(!Eof()),.F.,.T.)

(cAliasNext)->(DbCloseArea())
RestArea(cAreaAnt)
Return lRet

//----------------------------------------------------------------------------------//
//------------------------- Busca Cliente/Fornecedor e Loja ------------------------//
//----------------------------------------------------------------------------------//
Static Function BusCliForL(cServic,cTarefa,cAtivid,cDocto,cSerie,cCliFor,cLoja,cRecHVazio,cEndereco)
Local aAreaAnt := GetArea()
Local cQuery   := ''
Local cAlias   := GetNextAlias()
Local aCliFor  := {}
Local aLoja    := {}
Local nItem    := 1

   cQuery := "SELECT DISTINCT DB_CLIFOR, DB_LOJA"
   cQuery +=  " FROM " + RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery +=   " AND DB_ESTORNO  = ' '"
   cQuery +=   " AND DB_ATUEST   = 'N'"
   cQuery +=   " AND DB_SERVIC   = '"+cServic+"'"
   cQuery +=   " AND DB_TAREFA   = '"+cTarefa+"'"
   cQuery +=   " AND DB_ATIVID   = '"+cAtivid+"'"
   cQuery +=   " AND DB_DOC      = '"+cDocto+"'"
   If !Empty(cSerie)
	  cQuery += " AND DB_SERIE = '"+cSerie+"'"
   EndIf
   cQuery +=   " AND DB_STATUS   IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
   cQuery +=   " AND (DB_RECHUM  = '"+cRecHVazio+"'"
   cQuery +=   " OR   DB_RECHUM  = '"+__cUserID+"')"
   cQuery +=   " AND DB_LOCALIZ  = '"+cEndereco+"'"
   cQuery +=   " AND D_E_L_E_T_  = ' '"
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

   While (cAlias)->(!Eof())
	  AAdd(aCliFor,(cAlias)->DB_CLIFOR)
	  AAdd(aLoja  ,(cAlias)->DB_LOJA)
	  (cAlias)->(DbSkip())
   EndDo

   If Len(aCliFor) == 1
	  cCliFor := aCliFor[nItem]
	  cLoja   := aLoja[nItem]
   ElseIf Len(aCliFor) > 1
	  //Quando existir documento de entrada com mesmo n˙mero e sÈrie,
	  //disponibiliza browse para escolha do fornecedor
	  @ 04, 00 VTSay PadR(STR0069,VTMaxCol())
	  nItem   := VTAChoice(05,00,VTMaxRow(),VTMaxCol(),aCliFor)
	  cCliFor := aCliFor[nItem]
	  cLoja   := aLoja[nItem]
   EndIf

(cAlias)->(DbCloseArea())
RestArea(aAreaAnt)
Return

//----------------------------------------------------------
/*/{Protheus.doc}
Grava a quantidade lida nas linha SDB do produto

@param 	aPrdSYSSDB		(ObrigatÛrio) 	Array de Recno da tabela SDB
@param 	nQtde 		 					Quantidade lida

@author  Alexsander Burigo CorrÍa
@version P11
@Since	  08/08/13
/*/
//----------------------------------------------------------
Static Function WMSCalcQtdLid(aPrdSYSSDB, nQtde)
Local aAreaAnt			:= SDB->(GetArea())
Local lRet  			:= .T.
Local n1Cnt 			:= 0
Local nQtdLid			:= 0

Default nQtde 			:= 0
Default aPrdSYSSDB 	:= {}
	nQtdLid := nQtde
	For n1Cnt := 1 To Len(aPrdSYSSDB)
		If nQtdLid == 0
			Exit
		EndIf

		SDB->(MsGoTo(aPrdSYSSDB[n1Cnt]))
		RecLock('SDB', .F.) // Trava para gravacao
	    If n1Cnt == Len(aPrdSYSSDB)
	    	SDB->DB_QTDLID += nQtdLid
	    Else
			If nQtdLid + SDB->DB_QTDLID <= SDB->DB_QUANT
	        	SDB->DB_QTDLID += nQtdLid
	            nQtdLid := 0
	        Else
	            nQtdLid -= (SDB->DB_QUANT - SDB->DB_QTDLID)
	            SDB->DB_QTDLID += (SDB->DB_QUANT - SDB->DB_QTDLID)
	        EndIf
	    EndIf
	    MsUnlock() // Destrava apos gravacao
	Next
	RestArea(aAreaAnt)

Return lRet
