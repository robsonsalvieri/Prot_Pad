#INCLUDE 'WMSV073.CH' 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'
#DEFINE CRLF CHR(13)+CHR(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WMSV073 | Autor ³                          ³Data³08.04.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Conferência de Recebimento via Convocação                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static cServico   := ""
Static cOrdTar    := ""
Static cTarefa    := ""
Static cAtividade := ""
Static cArmazem   := ""
Static cEndereco  := ""
Static lWmsDaEn   := SuperGetMV("MV_WMSDAEN",.F.,.F.) // Conferência apenas considerando o endereço sem o armazém

Static lWV073AIL  := ExistBlock('WV073AIL') // Após Informar Lote
Static lWV073FCR  := ExistBlock('WV073FCR') // Ao finalizar a conferência
Static lWV073GQL  := ExistBlock('WV073GQL') // Ao gravar a quantidade lida
Static lWV073VLD  := ExistBlock("WV073VLD") // Ao informar endereço

Function WMSV073()
Local aAreaAnt   := GetArea()
Local aAreaSDB   := SDB->(GetArea())
Local aSavKey    := VTKeys() //Salva todas as teclas de atalho anteriores
Local lRet       := .T.
Local lTrocouDoc := .F.
Local cWmsUMI    := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
Local cDocto     := Space(Len(SDB->DB_DOC))
Local cSerie     := Space(Len(SDB->DB_SERIE))
Local lAbandona  := .F.

cServico   := SDB->DB_SERVIC
cOrdTar    := SDB->DB_ORDTARE
cTarefa    := SDB->DB_TAREFA
cAtividade := SDB->DB_ATIVID
cArmazem   := SDB->DB_LOCAL
cEndereco  := Space(Len(SDB->DB_LOCALIZ))

If !(cWmsUMI $ '0|1|2|3|4|5')
   DLVTAviso(STR0001,STR0002) //"Parâmetro MV_WMSUMI incorreto..."
   lRet      := .F.
   RestArea(aAreaSDB)
   RestArea(aAreaAnt)
   Return lRet
EndIf

Do While lRet .And. !lAbandona
	//Indica ao operador o endereço de destino da conferência
	DLVTCabec(STR0001,.F.,.F.,.T.) //"Conferência"
	DLVEndereco(0,0,SDB->DB_LOCALIZ,SDB->DB_LOCAL,,,STR0003) //"Vá para o Endereço"
	If VTLastKey() == 27
		WMSV073ESC(@lAbandona)
		Loop
	EndIf
	Exit
EndDo
	
Do While lRet .And. !lAbandona
	DLVTCabec(STR0001,.F.,.F.,.T.) //"Conferência"
	If !lWmsDaEn
		@ 01, 00 VTSay Padr(STR0063+cArmazem,VTMaxCol()) // Armazem: 
	EndIf
	@ 02, 00 VTSay PadR(STR0004,VTMaxCol()) //"Endereço"
	@ 03, 00 VTSay PadR(SDB->DB_LOCALIZ,VTMaxCol())
	@ 05, 00 VTSay PadR(STR0005, VTMaxCol()) //"Confirme !"
	@ 06, 00 VTGet cEndereco Pict '@!' Valid ValidEnder(SDB->DB_LOCALIZ,@cEndereco)
	VTRead()
	If (VTLastKey()==27)
		WMSV073ESC(@lAbandona)
		Loop
	EndIf
	Exit
EndDo

Do While lRet .And. !lAbandona
   //-- Confirmar Documento / Série
   DLVTCabec(,.F.,.F.,.T.)
   @ 01, 00 VTSay PadR(STR0006,VTMaxCol()) //"Documento / Série"
   @ 02, 00 VTSay PadR(SDB->DB_DOC+' / '+SDB->DB_SERIE,VTMaxCol())
   @ 04, 00 VTSay PadR(STR0005, VTMaxCol()) //"Confirme !"
   @ 05, 00 VTGet cDocto Picture '@!' Valid ValidDocto(cDocto,SDB->DB_DOC)
   @ 05, 10 VTSay '/'
   @ 05, 12 VTGet cSerie Picture '@!' Valid ValidSerie(cDocto,cSerie,SDB->DB_SERIE)
   VTRead()
   If (VTLastKey()==27)
      WMSV073ESC(@lAbandona)
      Loop
   EndIf
   If Empty(cDocto)
      cDocto := SDB->DB_DOC
   EndIf
   If Empty(cSerie)
      cSerie := SDB->DB_SERIE
   EndIf
   //-- Se o operador informou outro documento tira a reserva feita pelo DLGV001
   If ( !Empty(cDocto) .And. cDocto <> SDB->DB_DOC   ) .Or. ;
      ( !Empty(cSerie) .And. cSerie <> SDB->DB_SERIE )
      If !WmsQuestion(STR0007) //"Deseja alterar documento/serie?"
         Loop
      Else
         lTrocouDoc := .T.
      EndIf
   EndIf
   //-- Efetua as validações para o documento/serie informado
   If !ValidDocSer(cDocto,cSerie,lTrocouDoc)
      Loop
   EndIf
   Exit
EndDo

If lRet .And. !lAbandona
   //Efetua a conferencia dos produtos deste embarque
   lRet := CofPrdLot(cDocto,cSerie)
   DLVAltSts(.F.) //Não altera a situação da atividade no DLGV0001
EndIf

VTClear()
VTKeyBoard(chr(13))
VTInkey(0)
//-- Restaura as teclas de atalho anteriores
VTKeys(aSavKey)
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Permite ir executando a conferência dos produtos, informando os dados
//de lote, sub-lote e quantidade a ser conferida
//-----------------------------------------------------------------------------
Static Function CofPrdLot(cDocto,cSerie)
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lWMSConf   := SuperGetMV('MV_WMSCONF',.F.,.F.)
Local cWmsUMIAux := AllTrim(SuperGetMV('MV_WMSUMI',.F.,'0'))
Local cWmsUMI    := cWmsUMIAux
Local cProduto   := ""
Local cPrdAnt    := ""
Local cDescPro   := ""
Local cDescPr2   := ""
Local cDesNorma  := ""
Local cLoteCtl   := ""
Local cSubLote   := ""
Local nQtConf    := 0
Local cPictQt    := ""
Local cUM        := ""
Local cDscUM     := ""
Local aUNI       := {}
Local nItem      := 0
Local lEncerra   := .F.
Local lAbandona  := .F.
Local nAviso     := 0
Local nQtdNorma  := 0
Local nQtde1UM   := 0
Local nQtde2UM   := 0
Local aGets      := {}
Local nGet       := 0
Local nLin       := 0
Local nContTent  := 0

   //-- Atribui a funcao de JA CONFERIDOS a combinacao de teclas <CTRL> + <Q>
   VTSetKey(17,{||ShowPrdCof(cDocto,cSerie)},) //"Já Conferidos"

   While !lEncerra .And. !lAbandona
      cProduto  := Space(128)
      cDescPro  := Space(VTMaxCol())
      cDescPr2  := Space(VTMaxCol())
      cDesNorma := Space(VTMaxCol())

      //--  01234567890123456789
      //--0 ____Conferência_____
      //--1 Documento: 000000
      //--2 Informe o Produto
      //--3 PA1
      //--4 Informe o Lote
      //--5 AUTO000636
      //--6 Qtde 999.00 UM
      //--7               240.00
      DLVTCabec(STR0001,.F.,.F.,.T.) //"Conferência"
      @ 01,00  VtSay STR0009 + cDocto //"Documento"
      @ 02,00  VTSay STR0010 //"Informe o Produto"
      @ 03,00  VtGet cProduto Picture "@!" Valid ValidPrdLot(cDocto,cSerie,@cProduto,@cDescPro,@cDescPr2,@cDesNorma,@cLoteCtl,@cSubLote,@nQtConf)
      //-- Descricao do Produto com tamanho especifico.
      @ 04,00 VTGet cDescPro When .F.
      @ 05,00 VTGet cDescPr2 When .F.
      @ 06,00 VTGet cDesNorma When .F.
      VtRead()

      If VTLastKey()==27
         nAviso := DLVTAviso(STR0001,STR0011,{STR0012,STR0013}) //"Conferência" //"Deseja encerrar a conferência?" //"Encerrar" //"Interromper"
         If nAviso == 1
            lEncerra := .T.
         ElseIf nAviso == 2
            lAbandona  := .T.
         Else
            Loop
         EndIf
      EndIf

      If !lEncerra .And. !lAbandona
         nLin := 4
         //Se tiver espaço na tela suficiente ele mostra o sub-lote na mesma tela
         If VTMaxRow() >= 10
            If Rastro(cProduto)
               @ nLin++,00  VtSay STR0014 //"Informe o Lote"
               @ nLin++,00  VtGet cLoteCtl Picture "@!" When VTLastKey()==05 .Or. Empty(cLoteCtl) Valid ValLoteCtl(cDocto,cSerie,cProduto,cLoteCtl)
            EndIf
            If Rastro(cProduto,"S")
               @ nLin++,00 VTSay STR0015 //"Informe o Sub-Lote"
               @ nLin++,00 VTGet cSubLote Picture "@!" When VTLastKey()==05 .Or. Empty(cSubLote) Valid ValSubLote(cDocto,cSerie,cProduto,cLoteCtl,cSubLote)
            EndIf
            VtRead()

            If VTLastKey()==27
               Loop //Volta para o inicio do produto
            EndIf
         Else
            nGet := 1
            aGets := {}
            If Rastro(cProduto)
               AAdd(aGets,{STR0014,cLoteCtl,{||ValLoteCtl(cDocto,cSerie,cProduto,aGets[nGet,2])}}) //"Informe o Lote"
            EndIf
            If Rastro(cProduto,"S")
               AAdd(aGets,{STR0015,cSubLote,{||ValSubLote(cDocto,cSerie,cProduto,cLoteCtl,aGets[nGet,2])}}) //"Informe o Sub-Lote"
            EndIf
            //Aqui ele faz um loop para pegar as informações de rastro
            While nGet <= Len(aGets)
               If Len(aGets) > 0
                  @ nLin,  00  VtSay Padr(aGets[nGet,1],VTMaxCol())
                  @ nLin+1,00  VtSay Space(VTMaxCol()) //Apaga a linha, caso haja algo nela
                  @ nLin+1,00  VtGet aGets[nGet,2] Picture "@!" When VTLastKey()==05 .Or. Empty(aGets[nGet,2]) Valid Eval(aGets[nGet,3])
               EndIf
               VtRead()

               If VTLastKey()==27
                  Exit //Volta para o inicio do produto
               EndIf
               If nGet == 1
                  cLoteCtl := aGets[nGet,2]
               ElseIf nGet == 2
                  cSubLote := aGets[nGet,2]
               EndIf
               nGet++
            EndDo

            If VTLastKey()==27
               Loop //Volta para o inicio do produto
            EndIf
            nLin += Iif(Len(aGets) > 0,2,0)
         EndIf
         //- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
         If !(Iif(Empty(cLoteCtl),.T.,ValLoteCtl(cDocto,cSerie,cProduto,cLoteCtl))) .Or. ;
            !(Iif(Empty(cSubLote),.T.,ValSubLote(cDocto,cSerie,cProduto,cLoteCtl,cSubLote)))
            Loop //Volta para o inicio do produto
         EndIf
      EndIf
      
      // Ponto de entrada após informar o lote para permitir o usuário solicitar informações customizadas
      If !lEncerra .And. !lAbandona
      	If lWV073AIL
      		ExecBlock('WV073AIL', .F., .F., {cProduto,cLoteCtl})
      	EndIf
         If VTLastKey()==27
            Loop //Volta para o inicio do produto
         EndIf
      EndIf

      If !lEncerra .And. !lAbandona
         //-- Forca selecionar unidade de medida se informou produto diferente ou a cada leitura do codigo do produto
         If cProduto <> cPrdAnt .Or. lWMSConf
            cWmsUMI   := cWmsUMIAux
            nItem     := 0
            nQtdNorma := 0
         EndIf
         cPrdAnt := cProduto
      EndIf

      If !lEncerra .And. !lAbandona
         //-- Indica a unidade de medida utilizada pelas rotinas de -RF-. 1=1a.UM / 2=2a.UM / 3=UNITIZADOR / 4=U.M.I.
         //-- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
         If cWmsUMI == '4'
            SB5->(DbSetOrder(1))
            SB5->(MsSeek(xFilial('SB5')+cProduto))
            cWmsUMI := SB5->B5_UMIND
            If !(cWmsUMI$'1|2')
               cWmsUMI := '0'
            EndIf
         EndIf
         //-- Se db_qtsegum nao estiver preenchido
         If cWmsUMI $ '2|3|5'
            If Empty(SB1->B1_SEGUM)
               cWmsUMI := '1'
            EndIf
         EndIf
         //-- Se parametro MV_WMSUMI = 3, solicita unidade de medida a cada nova informação de quantidade
         //-- Se parametro MV_WMSUMI = 5, solicita unidade de medida somente quando informado novo produto
         If cWmsUMI $ '3|5'
            If nItem == 0 .Or. cWmsUMI == '3'
               nQtdNorma := DLQtdNorma(cProduto,SDB->DB_LOCAL,SDB->DB_ESTFIS,@cDscUM,.F.)
               nItem := Iif(nQtdNorma > 0,3,2)
               aUNI := {}
               If nQtdNorma > 0
                  aAdd(aUNI,{cDscUM})
               EndIf
               aAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_SEGUM,'AH_UMRES')})
               aAdd(aUNI,{Posicione('SAH',1,xFilial('SAH')+SB1->B1_UM,   'AH_UMRES')})
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
               DLVTRodaPe(STR0016,.F.) //"Unidade p/Confer?"
               nItem := VTaBrowse(0,0,VTMaxRow()-3,VTMaxCol(),{STR0017},aUNI,{VTMaxCol()},,nItem) //"Unidade"
               VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
               If nItem <= 0
                  nItem := Iif(nQtdNorma > 0,3,2)
               EndIf
               cDscUM := aUNI[nItem,1]
               If nQtdNorma > 0 .And. nItem == 1
                  cPictQt:= '@R 9999999999'
                  cUM    := ''
               ElseIf (nQtdNorma > 0 .And. nItem == 2) .Or. (nQtdNorma == 0 .And. nItem == 1)
                  cPictQt:= PesqPict('SDB','DB_QTSEGUM')
                  cUM    := SB1->B1_SEGUM
               ElseIf (nQtdNorma > 0 .And. nItem == 3) .Or. (nQtdNorma == 0 .And. nItem == 2)
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
            If cWmsUMI $ '0|1'
               nItem  := 2
               cPictQt:= PesqPict('SDB','DB_QUANT')
               cUM    := SB1->B1_UM
            ElseIf cWmsUMI == '2'
               nItem  := 1
               cPictQt:= PesqPict('SDB','DB_QTSEGUM')
               cUM    := SB1->B1_SEGUM
            EndIf
            SAH->(DbSetOrder(1))
            SAH->(MsSeek(xFilial('SAH')+cUM))
            cDscUM := PadR(SAH->AH_UMRES,VTMaxCol())
         EndIf

         //- Processar validacoes quando etiqueta = Produto/Lote/Sub-Lote/Qtde
         While .T.
            @ nLin++,00 VTSay PadR(STR0018+cDscUM,VTMaxCol())
            @ nLin++,00 VTGet nQtConf Picture cPictQt When Empty(nQtConf) Valid !Empty(nQtConf)
            VTRead()
            If VTLastKey()==27
               Exit //Volta para o inicio do produto
            EndIf
            If !ValidQtd(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,nQtConf,nItem,nQtdNorma,@nQtde1UM,@nQtde2UM)
               nQtConf := 0
               nLin -= 2
               Loop
            EndIf
            Exit
         EndDo

         If VTLastKey()==27
            Loop
         EndIf
      EndIf

      //Somente grava a quantidade se o usuário não cancelar
      If !lEncerra .And. !lAbandona
         GravCofOpe(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,nQtde1UM)
      EndIf
      //Se o usuário optou por encerrar, deve verificar se pode ser finalizado a conferência
      If lEncerra
         nContTent++
         lEncerra := FinCofEnt(cDocto,cSerie,nContTent)
      EndIf
      //Se o usuário optou por interromper, deve verificar se pode sair da conferência
      //Caso não haja mais nada para ser executado, não será possível efetuar
      //a liberação da expedição para o faturamento
      If lAbandona
         lAbandona := SaiCofEnt(cDocto,cSerie)
      EndIf
   EndDo

//Restaura tela anterior
VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return

//-----------------------------------------------------------------------------
// Exibe os produtos e quantidade conferida para cada um deles
//-----------------------------------------------------------------------------
Static Function ShowPrdCof(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local aProduto   := {}
Local aTelaAnt   := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aHeaders   := {}
Local aSizes     := {}

	cQuery := "SELECT DB_PRODUTO, DB_LOTECTL, DB_NUMLOTE, DB_LOCAL, "
	cQuery += "SUM(DB_QUANT) DB_QUANT, SUM(DB_QTDLID) DB_QTDLID"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"','"+cStatExec+"')"
	cQuery +=   " AND DB_RECHUM  = '"+__cUserID+"'"
	If !lWmsDaEn
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND DB_QTDLID  > 0"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY DB_PRODUTO, DB_LOTECTL, DB_NUMLOTE, DB_LOCAL"
	If lWmsDaEn
		cQuery += " ORDER BY DB_PRODUTO, DB_LOTECTL DESC, DB_NUMLOTE, DB_LOCAL DESC"
	Else
		cQuery += " ORDER BY DB_LOCAL,DB_PRODUTO, DB_LOTECTL DESC, DB_NUMLOTE DESC"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TCSetField(cAliasQry,'DB_QUANT' ,'N',TamSx3('DB_QUANT')[1], TamSx3('DB_QUANT')[2])
	TCSetField(cAliasQry,'DB_QTDLID','N',TamSx3('DB_QTDLID')[1],TamSx3('DB_QTDLID')[2])
	While (cAliasQry)->(!Eof())
	   AAdd(aProduto,{Iif((cAliasQry)->DB_QUANT <> (cAliasQry)->DB_QTDLID,'*',' '),IiF(!lWmsDaEn,(cAliasQry)->DB_LOCAL,' '),(cAliasQry)->DB_PRODUTO,Posicione('SB1',1,xFilial('SB1')+(cAliasQry)->DB_PRODUTO,'SB1->B1_DESC'),(cAliasQry)->DB_LOTECTL,(cAliasQry)->DB_NUMLOTE,(cAliasQry)->DB_QTDLID})
	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
	
	aHeaders := {' ',RetTitle("DB_LOCAL"),RetTitle("DB_PRODUTO"),RetTitle("B1_DESC"),RetTitle("DB_LOTECTL"),RetTitle("DB_NUMLOTE"),"Qtde Conferida"} //Produto|Descrição|Lote|Sub-Lote|Qtde Conferida
	aSizes   := {1,TamSx3("DB_LOCAL")[1],TamSx3("DB_PRODUTO")[1],30,TamSx3("DB_LOTECTL")[1],TamSx3("DB_NUMLOTE")[1],11}
	VtClearBuffer()
	DLVTCabec(STR0019,.F.,.F.,.T.) //"Produto"
	VTaBrowse(1,,,,aHeaders,aProduto,aSizes)
	VTKeyBoard(chr(20))
	VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
Return Nil

//-----------------------------------------------------------------------------
// Valida o endereço informado
//-----------------------------------------------------------------------------
Static Function ValidEnder(cEnderSYS,cEndereco)
Local aAreaAnt := GetArea()
Local lRet     := .T.
	//Se não informou endereço retorna
	If Empty(cEndereco)
	   lRet := .F.
	Else
		lRet := Alltrim(cEndereco)==Alltrim(cEnderSYS)
		If lWV073VLD
			lRet := ExecBlock('WV073VLD',.F.,.F.,{cEndereco, cEnderSYS})
		EndIf
		If !lRet
			DLVTAviso(STR0001,STR0020) //"Endereco incorreto!"
			VTKeyBoard(chr(20))
			lRet := .F.
		EndIf
	EndIf
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida a informação do campo Documento
//-----------------------------------------------------------------------------
Static Function ValidDocto(cDoctoInf,cDoctoSys)
Local aAreaAnt := GetArea()
Local lRet
   //Se não informou o documento retorna
   If Empty(cDoctoInf)
      Return .F.
   EndIf
   //Se o documento informado é o mesmo convocado
   If cDoctoInf == cDoctoSys
      Return .T.
   EndIf
   //Se o documento é diferente, deve validar se existe este documento
   cDoctoInf := PadR(cDoctoInf,TamSX3("F1_DOC")[1])
   SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
   If SF1->(!DbSeek(xFilial("SF1")+cDoctoInf))
      DLVTAviso("SIGAWMS",STR0022) //"Documento inválido!"
      lRet := .F.
   EndIf
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida a informação do campo Série
//-----------------------------------------------------------------------------
Static Function ValidSerie(cDoctoInf,cSerieInf,cSerieSys)
Local aAreaAnt := GetArea()
Local lRet
   //Se a série informada é a mesma convocada
   If cSerieInf == cSerieSys
      Return .T.
   EndIf
   //Se não informou a série retorna
   If Empty(cSerieInf)
      Return .F.
   EndIf
   //Se a série é diferente, deve validar se existe este documento + série
   cSerieInf := PadR(cSerieInf,TamSX3("F1_SERIE")[1])
   SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
   If SF1->(!DbSeek(xFilial("SF1")+cDoctoInf+cSerieInf))
      DLVTAviso("SIGAWMS",STR0023) //"Série inválida!"
      lRet := .F.
   EndIf
RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida a informação do documento/serie informado, trocando o operador se for o caso
//-----------------------------------------------------------------------------
Static Function ValidDocSer(cDocto,cSerie,lTrocouDoc)
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local cServAnt   := cServico
Local cOrdTarAnt := cOrdTar
local cTarAnt    := cTarefa
Local cAtivAnt   := cAtividade
Local cArmAnt    := cArmazem

	//Se trocou o documento ou a série, deve validar a nova informação
	If lTrocouDoc
		If !HasTarDoc(cDocto,cSerie)
			DLVTAviso("SIGAWMS",WmsFmtMsg(STR0064,{{"[VAR01]",cArmazem}})) // Não existem atividades de conferência para o documento para o armazém [VAR01].
			Return .F.
		EndIf
	EndIf

	//-- Se algum item do mesmo documento foi convocado p/ outro operador.
	If TarExeOper(cDocto,cSerie)
		DLVTAviso("SIGAWMS",STR0025) //"Atividades da tarefa em andamento por outro operador."
		//Retorna variáveis
		cServico  := cServAnt
		cOrdTar   := cOrdTarAnt
		cTarefa   := cTarAnt
		cAtividade:= cAtivAnt
		cArmazem  := cArmAnt
		Return .F.
	EndIf

	If lTrocouDoc
		RecLock('SDB', .F.)  //-- Trava para gravacao
		SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
		SDB->DB_STATUS := cStatAExe // Atividade A Executar
		//-- Libera o registro do arquivo SDB
		MsUnlock()
		If lLiberaRH
			//-- Retira recurso humano atribuido as atividades de outros itens do mesmo documento/série.
			CancRHServ(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_SERVIC)
		EndIf
		DLVTAviso(STR0001,PadC(STR0026,VTMaxCol())+STR0027) //"Atenção" - "Documento alterado. Executar a conferência do documento informado."
	EndIf
	//-- Atribui o documento todo para o usuário
	AddRHServ(cDocto,cSerie)
Return .T.

//-----------------------------------------------------------------------------
// Verifica se tem atividades para o novo documento informado
//-----------------------------------------------------------------------------
Static Function HasTarDoc(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local lRet       := .F.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.DB_SERVIC,"
	cQuery +=       " SDB.DB_ORDTARE,"
	cQuery +=       " SDB.DB_TAREFA,"
	cQuery +=       " SDB.DB_ATIVID,"
	cQuery +=       " SDB.DB_LOCAL"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
	cQuery +=   " AND (DB_RECHUM = '"+cRecHVazio+"'"
	cQuery +=   " OR   DB_RECHUM = '"+__cUserID+"')"
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (lRet := (cAliasQry)->(!Eof())) 
		//Atribui variáveis
		cServico   := (cAliasQry)->DB_SERVIC
		cOrdTar    := (cAliasQry)->DB_ORDTARE
		cTarefa    := (cAliasQry)->DB_TAREFA
		cAtividade := (cAliasQry)->DB_ATIVID
		cArmazem   := (cAliasQry)->DB_LOCAL
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Analisa se a tarefa está em andamento por outro operador.
//-----------------------------------------------------------------------------
Static Function TarExeOper(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " INNER JOIN "+RetSqlName('DCD')+" DCD"
	cQuery +=  " ON DCD_FILIAL   = '"+xFilial('DCD')+"'"
	cQuery +=   " AND DCD_CODFUN = DB_RECHUM"
	cQuery +=   " AND DCD_STATUS IN ('1','2')" // Somente se o operador estiver livre ou ocupado
	cQuery +=   " AND DCD.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_RECHUM  <> '"+cRecHVazio+"'"
	cQuery +=   " AND DB_RECHUM  <> '"+__cUserID+"'"
	If !lWmsDaEn
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery +=   " AND SDB.D_E_L_E_T_ = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Retira recurso humano atribuido as atividades de conferência
// de outros itens do mesmo documento/série.
//-----------------------------------------------------------------------------
Static Function CancRHServ(cDocto,cSerie,cServic)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

   cAliasQry := GetNextAlias()
   cQuery := " SELECT SDB.R_E_C_N_O_ SDBRECNO"
   cQuery +=  " FROM " + RetSqlName('SDB')+" SDB"
   cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
   cQuery +=   " AND DB_ESTORNO = ' '"
   cQuery +=   " AND DB_ATUEST  = 'N'"
   cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
   cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
   cQuery +=   " AND DB_SERVIC  = '"+cServic+"'"
   cQuery +=   " AND DB_STATUS  = '"+cStatAExe+"'" // Atividade A Executar
   cQuery +=   " AND DB_RECHUM  = '"+__cUserID+"'"
   cQuery +=   " AND D_E_L_E_T_ = ' '"
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
   While (cAliasQry)->(!Eof())
      SDB->(MsGoto((cAliasQry)->SDBRECNO))
      RecLock('SDB', .F.)  // Trava para gravacao
      SDB->DB_RECHUM := cRecHVazio
      MsUnlock()
      (cAliasQry)->(DbSkip())
   EndDo
   (cAliasQry)->(DbCloseArea())
   RestArea(aAreaAnt)

Return

//-----------------------------------------------------------------------------
// Atribui o recurso humano para as atividades de conferência
// de outros itens do mesmo documento/série
//-----------------------------------------------------------------------------
Static Function AddRHServ(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local lRet       := .F.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

	cQuery := "SELECT SDB.R_E_C_N_O_ SDBRECNO"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery +=   " AND DB_RECHUM  = '"+cRecHVazio+"'"
	If !lWmsDaEn 
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof())
	   SDB->(MsGoto((cAliasQry)->SDBRECNO))
	   RecLock('SDB', .F.)  // Trava para gravacao
	   SDB->DB_RECHUM := __cUserID
	   MsUnlock()
	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
// Valida o produto informado, verificando se o mesmo pertence ao documento/serie
// Valida se o mesmo já foi separado e pode ser conferido
//-----------------------------------------------------------------------------
Static Function ValidPrdLot(cDocto,cSerie,cProduto,cDescPro,cDescPr2,cDesNorma,cLoteCtl,cSubLote,nQtde)
Local lRet     := .T.
Local nMax     := VTMaxCol()
Local aTelaAnt := VTSave(00, 00, VTMaxRow(), VTMaxCol())
Local lVerSimp := SuperGetMV('MV_WMSVSTC',.F.,.F.) //-- Versao simplificada telas de conferência no coletor RF
   // Validações genéricas relacionadas ao código do produto
   lRet := DLVValProd(@cProduto,@cLoteCtl,@cSubLote,@nQtde)
   //Deve validar se o produto possui quantidade para ser conferida
   If lRet
      If QtdComp(QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,cSubLote)) == 0
         DLVTAviso(STR0001,IIF(lWmsDaEn,STR0029,WmsFmtMsg(STR0065,{{"[VAR01]",cArmazem}}))) //Não existe conferência para o produto. // Não existe conferência para o produto no armazém [VAR01].
         lRet := .F.
      EndIf
      //Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
      If lRet .And. QtdComp(QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,.T.)) > 0
         DLVTAviso(STR0001,STR0030) //"Conferência do produto bloqueada."
         lRet := .F.
      EndIf
   EndIf
   // Ajustes para exibição de informações sobre produto
   If lRet .And. !lVerSimp
      //-- Divide Descr. do produto em 3 linhas
      SB1->(DbSetOrder(1))
      SB1->(MsSeek(xFilial('SB1')+cProduto))
      cDescPro  := SubStr(SB1->B1_DESC,       1,nMax)
      cDescPr2  := SubStr(SB1->B1_DESC,  nMax+1,nMax)
      cDesNorma := GetDesNorma(cProduto,RetFldProd(SB1->B1_COD,"B1_LOCPAD"))
      VtGetRefresh("cProduto")
      VtGetRefresh("cDescPro")
      VtGetRefresh("cDescPr2")
      VtGetRefresh("cDesNorma")
      DLVTRodape()
      VTRestore(00, 00, VTMaxRow(), VTMaxCol(), aTelaAnt)
   EndIf
   If !lRet
      cProduto := Space(128)
      VTKeyBoard(Chr(20))
   EndIf
Return lRet

//-----------------------------------------------------------------------------
//Permite carregar a quantidade do produto que está pendente de conferência
//-----------------------------------------------------------------------------
Static Function QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,lSitBlq)
Local aAreaAnt   := GetArea()
Local nQuant     := 0
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local aTamSX3    := TamSx3('DB_QUANT')
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local cLoteCtlVz := Space(TamSX3('DB_LOTECTL')[1])
Local cSubLoteVz := Space(TamSX3('DB_NUMLOTE')[1])

Default lSitBlq := .F.

	cQuery := "SELECT SUM(DB_QUANT) QTD_SALDO"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_PRODUTO = '"+cProduto+"'"
	If !Empty(cLoteCtl)
	   cQuery += " AND (DB_LOTECTL  = '"+cLoteCtl+"'"
	   cQuery +=   " OR DB_LOTECTL  = '"+cLoteCtlVz+"')"
	EndIf
	If !Empty(cSubLote)
	   cQuery += " AND (DB_NUMLOTE  = '"+cSubLote+"'"
	   cQuery +=   " OR DB_NUMLOTE  = '"+cSubLoteVz+"')"
	EndIf
	If lSitBlq
	   cQuery += " AND DB_STATUS = '"+cStatProb+"'"
	EndIf
	cQuery +=   " AND (DB_RECHUM = '"+__cUserID+"'"
	cQuery +=   "  OR DB_RECHUM  = '"+cRecHVazio+"')"
	If !lWmsDaEn 
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'QTD_SALDO','N',aTamSX3[1],aTamSX3[2])
	If (cAliasQry)->(!Eof())
	   nQuant := (cAliasQry)->QTD_SALDO
	EndIf
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return nQuant

//-----------------------------------------------------------------------------
// Valida o produto/lote informado, verificando se o mesmo pertence ao documento/série
// Valida se o mesmo já foi separado e pode ser conferido
//-----------------------------------------------------------------------------
Static Function ValLoteCtl(cDocto,cSerie,cProduto,cLoteCtl)
Local lRet  := .T.

   If Empty(cLoteCtl)
      Return .F.
   EndIf
   If QtdComp(QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,/*cSubLote*/)) == 0
      DLVTAviso(STR0001,STR0031) //"Produto/Lote não pertence a conferência."
      VTKeyBoard(Chr(20))
      lRet := .F.
   EndIf
   //Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
   If QtdComp(QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,,.T.)) > 0
      DLVTAviso(STR0001,STR0032) //"Conferência do Produto/Lote bloqueada."
      VTKeyBoard(Chr(20))
      lRet := .F.
   EndIf
Return lRet

//-----------------------------------------------------------------------------
// Valida o produto/rastro informado, verificando se o mesmo pertence ao documento/série
// Valida se o mesmo já foi separado e pode ser conferido
//-----------------------------------------------------------------------------
Static Function ValSubLote(cDocto,cSerie,cProduto,cLoteCtl,cSubLote)
Local lRet  := .T.

   If Empty(cSubLote)
      Return .F.
   EndIf
   If QtdComp(QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,cSubLote)) == 0
      DLVTAviso(STR0001,STR0033) //"Produto/Rastro não pertence a conferência."
      VTKeyBoard(Chr(20))
      lRet := .F.
   EndIf
   //Caso não haja quantidade liberada, verifica se possui quantidade bloqueada
   If QtdComp(QtdPrdCof(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,.T.)) > 0
      DLVTAviso(STR0001,STR0034) //"Conferência do Produto/Rastro bloqueada."
      VTKeyBoard(Chr(20))
      lRet := .F.
   EndIf
Return lRet

//-----------------------------------------------------------------------------
//Valida a quantidade informada efetuando a conversão das unidades de medida
//-----------------------------------------------------------------------------
Static Function ValidQtd(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,nQtConf,nItem,nQtdNorma,nQtde1UM,nQtde2UM)

   If Empty(nQtConf)
      Return .F.
   EndIf
   //-- O sistema trabalha sempre na 1a.UM
   If nQtdNorma > 0 .And. nItem == 1
      //-- Converter de U.M.I. p/ 1a.UM
      nQtde1UM := (nQtConf*nQtdNorma)
      nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
   ElseIf (nQtdNorma > 0 .And. nItem == 2) .Or. (nQtdNorma == 0 .And. nItem == 1)
      //-- Converter de 2a.UM p/ 1a.UM
      nQtde2UM := nQtConf
      nQtde1UM := ConvUm(cProduto,0,nQtde2UM,1)
   ElseIf (nQtdNorma > 0 .And. nItem == 3) .Or. (nQtdNorma == 0 .And. nItem == 2)
      //-- Converter de 1a.UM p/ 2a.UM
      nQtde1UM := nQtConf
      nQtde2UM := ConvUm(cProduto,nQtde1UM,0,2)
   EndIf

Return .T.

//-----------------------------------------------------------------------------
//Busca a descrição da norma da doca para o produto
//-----------------------------------------------------------------------------
Static Function GetDesNorma(cProduto,cLocal)
Local aAreaAnt  := GetArea()
Local cDesNorma := ""
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

   cQuery := "SELECT DC3_ORDEM, DC2_LASTRO, DC2_CAMADA"
   cQuery +=  " FROM "+RetSqlName('DC3')+" DC3, "+RetSqlName('DC8')+" DC8, "+RetSqlName('DC2')+" DC2"
   cQuery += " WHERE DC3.DC3_FILIAL = '"+xFilial('DC3')+"'"
   cQuery +=   " AND DC3.DC3_LOCAL  = '"+cLocal+"'"
   cQuery +=   " AND DC3.DC3_CODPRO = '"+cProduto+"'"
   cQuery +=   " AND DC3.D_E_L_E_T_ = ' '"
   cQuery +=   " AND DC8.DC8_FILIAL = '"+xFilial('DC8')+"'"
   cQuery +=   " AND DC8.DC8_CODEST = DC3.DC3_TPESTR"
   cQuery +=   " AND DC8.DC8_TPESTR = '5'" //Doca
   cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
   cQuery +=   " AND DC2.DC2_FILIAL = '"+xFilial('DC2')+"'"
   cQuery +=   " AND DC2.DC2_CODNOR = DC3.DC3_CODNOR"
   cQuery +=   " AND DC2.D_E_L_E_T_ = ' '"
   cQuery +=   " ORDER BY DC3.DC3_ORDEM DESC"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
   If (cAliasQry)->(!Eof())
      cDesNorma := "Norma: L "+AllTrim(Str((cAliasQry)->DC2_LASTRO))+" x "+AllTrim(Str((cAliasQry)->DC2_CAMADA))+" C" // "Norma: L [VAR01] x [VAR02] C"
   EndIf
   (cAliasQry)->(DbCloseArea())

RestArea(aAreaAnt)
Return cDesNorma

//-----------------------------------------------------------------------------
//Grava a quantidade conferida, finalizando a atividade
//relativa ao produto conferido, se for o caso.
//-----------------------------------------------------------------------------
Static Function GravCofOpe(cDocto,cSerie,cProduto,cLoteCtl,cSubLote,nQtConf)
Local aAreaAnt   := GetArea()
Local lRet       := .T.
Local lRetPE     := .T.
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local nQtdLid    := 0
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local cLoteCtlVz := Space(TamSX3('DB_LOTECTL')[1])
Local cSubLoteVz := Space(TamSX3('DB_NUMLOTE')[1])
//--- Qtde. de tolerancia p/calculos com a 1UM. Usado qdo o fator de conv gera um dizima periodica
Local nToler1UM  := QtdComp(SuperGetMV("MV_NTOL1UM",.F.,0))
Local nRecnoSDB  := 0
Local cSeekSD1   := ''
	
	Begin Transaction
	
	cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_PRODUTO = '"+cProduto+"'"
	If !Empty(cLoteCtl)
	   cQuery += " AND (DB_LOTECTL  = '"+cLoteCtl+"'"
	   cQuery +=   " OR DB_LOTECTL  = '"+cLoteCtlVz+"')"
	EndIf
	If !Empty(cSubLote)
	   cQuery += " AND (DB_NUMLOTE  = '"+cSubLote+"'"
	   cQuery +=   " OR DB_NUMLOTE  = '"+cSubLoteVz+"')"
	EndIf
	cQuery +=   " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"')"
	cQuery +=   " AND (DB_RECHUM  = '"+__cUserID+"'"
	cQuery +=    " OR DB_RECHUM   = '"+cRecHVazio+"')"
	If !lWmsDaEn 
		cQuery +=   " AND DB_LOCAL    = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_  = ' '"
	cQuery += " ORDER BY DB_LOTECTL DESC, DB_NUMLOTE DESC"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While lRet .And. (cAliasQry)->(!Eof()) .And. QtdComp(nQtConf) > 0
	   SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	   //Guarda sempre o último SDB que possui lote
	   If !Empty(SDB->DB_LOTECTL)
	      nRecnoSDB := (cAliasQry)->RECNOSDB
	   EndIf
	   //Verifica somente o saldo que falta conferir daquele item
	   //Se já tiver sido conferida toda a quantidade do registro
	   //ou essa quantidade já tiver sido ultrapassada, passa para o próximo
	   If QtdComp(SDB->DB_QUANT-SDB->DB_QTDLID) <= 0
	      (cAliasQry)->(DbSkip())
	      Loop
	   //Se o saldo é maior do informado para conferir
	   //E a diferença absoluta do saldo mais o conferido é maior que a tolerancia
	   ElseIf (QtdComp(SDB->DB_QUANT-SDB->DB_QTDLID) > QtdComp(nQtConf)) .And.;
	          (QtdComp(Abs(SDB->DB_QUANT-(SDB->DB_QTDLID+nQtConf))) > QtdComp(nToler1UM))
	      nQtdLid := nQtConf
	   Else
	      nQtdLid := SDB->DB_QUANT-SDB->DB_QTDLID
	   EndIf
	   //Caso o registro corrente tenha sido gerado sem lote, deve verificar se a conferência
	   //vai deixar resíduo e existe a necessidade de quebrá-lo, gerando um novo com a diferença
	   If Empty(SDB->DB_LOTECTL) .And. Rastro(SDB->DB_PRODUTO) .And. QtdComp(SDB->DB_QUANT - nQtdLid) > 0
	      //Gera o novo registro
	      WmsAtzSDB('1',nQtdLid)
	      //Reposiciona SDB que foi desposicionada com a criação do novo registro
	      SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	   EndIf
	   If (lRet := RecLock("SDB",.F.))
	      SDB->DB_RECHUM  := __cUserID
	      SDB->DB_DATAFIM := dDataBase
	      SDB->DB_HRFIM   := Time()
	      SDB->DB_QTDLID  += nQtdLid
	      SDB->DB_LOTECTL := cLoteCtl
	      SDB->DB_STATUS  := cStatInte //Em andamento
	      SDB->(MsUnlock())
	      //Diminuindo a quantidade utilizada da quantidade conferida
	      nQtConf -= nQtdLid
	      If lWV073GQL
	   		lRetPE := ExecBlock('WV073GQL', .F., .F.)
	   		If ValType(lRetPE) = 'L' .And. !lRetPE
	   			lRet := .F.
	   		EndIf
		  EndIf
	   EndIf

		cSeekSD1 := xFilial('SD1') + SDB->(DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_PRODUTO+DB_ITEM)
		dbSelectArea('SD1')
		dbSetOrder(1)
		If SD1->(dbSeek(cSeekSD1))
			RecLock('SD1')
			SD1->D1_LOTECTL := cLoteCtl
			SD1->(MsUnlock())
		EndIf

	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	//Se sobrou saldo de quantidade conferida, soma à quantidade
	//lida do último SDB COM LOTE utilizado no rateio.
	//Caso não exista SDB com lote do produto, irá jogar o saldo
	//no último SDB SEM LOTE utilizado no rateio.
	If QtdComp(nQtConf) > 0
	   If nRecnoSDB != 0
	      SDB->(DbGoTo(nRecnoSDB))
	   EndIf
	   If (lRet := RecLock("SDB",.F.))
	      SDB->DB_QTDLID  += nQtConf
	      SDB->(MsUnlock())
	      If lWV073GQL
	   		lRetPE := ExecBlock('WV073GQL', .F., .F.)
	   		If ValType(lRetPE) = 'L' .And. !lRetPE
	   			lRet := .F.
	   		EndIf
	   	EndIf
	   EndIf
	EndIf
	If !lRet
	   DisarmTransaction()
	   DLVTAviso(STR0001,STR0035) //"Não foi possível registrar a quantidade."
	EndIf
	End Transaction
	RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Grava a quantidade conferida, finalizando a atividade
//relativa ao produto conferido, se for o caso.
//-----------------------------------------------------------------------------
Static Function FinCofEnt(cDocto,cSerie,nContTent)
Local nMaxTent := Val(SuperGetMV('MV_MAXCONT',.F.,'3')) //Número máximo de tentativas de conferência
Local lRet     := .T.
Local lRetPE   := .T.
Local nOpcao   := 1
Local cLogFile := ""

Private lAutoErrNoFile := .T.

   If AtivAntPen(cDocto,cSerie)
      DLVTAviso(STR0001,STR0036) // "Existem atividades anteriores não finalizadas."
      Return .F.
   EndIf

   If DocAntPen(cDocto,cSerie)
      DLVTAviso(STR0001,STR0037) // "Existem ordens de serviço pendentes de execução."
      Return .F.
   EndIf

   If ItemDiverg(cDocto,cSerie,@cLogFile,nContTent) //Verifica se possui item divergente
      If nContTent >= nMaxTent  //Caso tenha chegado ao número máximo de tentativas de conferência
         WmsMessage(WmsFmtMsg(STR0038,{{"[VAR01]",Str(nContTent)}}),STR0001) //"As divergências encontradas na [VAR01]a conferência serão registradas!"
      Else
         nOpcao := WmsMessage(WmsFmtMsg(STR0039,{{"[VAR01]",Str(nContTent)}}),STR0001,,,{STR0040,STR0041,STR0042}) //"Conferência" //"Foram encontradas divergências na [VAR01]a conferência." //"Registrar Ocorrência" //"Reconferir Divergentes" //"Reconferir Tudo"
      EndIf
      If VTLastKey()==27
         Return .F.
      EndIf
      //Executa a opção escolhida pelo usuário
      Do Case
         Case nOpcao == 1 //Registrar Ocorrência
            lRet := RegOcorren(cDocto,cSerie,cLogFile)
            If lWV073FCR
            	lRetPE := ExecBlock('WV073FCR', .F., .F.,{cDocto,cSerie,.T./*Divergente*/}) 
	      		If ValType(lRetPE) = 'L' .And. !lRetPE
	      			lRet := .F.
	      		EndIf
	      	EndIf
         Case nOpcao == 2 //Reconferir Divergentes
            lRet := ReConfDiv(cDocto,cSerie)
         Case nOpcao == 3 //Reconferir Tudo
            lRet := ReConfTudo(cDocto,cSerie)
      End Case
   Else
      If lWV073FCR
      	lRetPE := ExecBlock('WV073FCR', .F., .F.,{cDocto,cSerie,.F./*Divergente*/}) 
   		If ValType(lRetPE) = 'L' .And. !lRetPE
   			lRet := .F.
   		EndIf
   	EndIf
   	If lRet
      	DLVTAviso(STR0001,STR0043) // "Conferência encerrada com sucesso!"
      EndIf
   EndIf
Return lRet

//----------------------------------------------------------
//Verifica se existem atividades anteriores não finalizadas
//----------------------------------------------------------
Static Function AtivAntPen(cDocto,cSerie)
Local aAreaAnt    := GetArea()
Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local lRet        := .F.

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial('SDB')+"'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cSerie+"'"
	cQuery +=   " AND DB_ORDTARE < '"+cOrdTar+"'"
	If lWmsDaEn
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_STATUS  IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
//Verifica se existem ordens de serviço não executadas para o mesmo documento
//----------------------------------------------------------
Static Function DocAntPen(cDocto,cSerie)
Local aAreaAnt    := GetArea()
Local cQuery      := ""
Local cAliasQry   := GetNextAlias()
Local lRet        := .F.

   cQuery := "SELECT DISTINCT 1"
   cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
   cQuery += " WHERE DCF_FILIAL = '"+xFilial('DCF')+"'"
   cQuery +=   " AND DCF_DOCTO  = '"+cDocto+"'"
   cQuery +=   " AND DCF_SERIE  = '"+cSerie+"'"
   cQuery +=   " AND DCF_SERVIC = '"+cServico+"'"
   	If lWmsDaEn
		cQuery += " AND DCF_LOCAL = '"+cArmazem+"'"
	EndIf
   cQuery +=   " AND DCF_STSERV IN ('1','2')"
   cQuery +=   " AND D_E_L_E_T_ = ' '"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
   lRet := (cAliasQry)->(!Eof())
   (cAliasQry)->(DbCloseArea())
RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
// Verifica se existe item divergente
// Se existir, grava na memória do log
//----------------------------------------------------------
Static Function ItemDiverg(cDocto,cSerie,cLogFile,nContTent)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local nToler1UM  := SuperGetMV("MV_NTOL1UM",.F.,0)
Local lDiverg    := .F.
Local cDCFAnt    := ""
Local nItem      := 1
	
	Begin Transaction
	
	cQuery := "SELECT R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"','"+cStatProb+"')"
	cQuery +=   " AND (DB_RECHUM = '"+__cUserID+"'"
	cQuery +=     " OR DB_RECHUM = '"+cRecHVazio+"')"
	If !lWmsDaEn 
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	While (cAliasQry)->(!Eof())
	   SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	   //Verifica se é item divergente
	   If QtdComp(SDB->DB_QUANT) != QtdComp(SDB->DB_QTDLID) .And.;
	      QtdComp(Abs(SDB->DB_QUANT-SDB->DB_QTDLID)) > QtdComp(nToler1UM)
	      //Grava item na memória do log de divergências
	      ImprLogDiv(cDocto,cSerie,@cLogFile,nContTent,@cDCFAnt,@nItem,!lDiverg)
	      lDiverg := .T.
	   Else
	      If RecLock("SDB",.F.)
	         SDB->DB_RECHUM  := __cUserID
	         SDB->DB_DATAFIM := dDataBase
	         SDB->DB_HRFIM   := Time()
	         SDB->DB_STATUS  := cStatExec //Status Executado
	         SDB->(MsUnlock())
	      EndIf
	   EndIf 
	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	If lDiverg
	   DisarmTransaction() //Se existirem itens divergentes, cancela a atualização dos registros
	   AutoGrLog("-----+-----------------+--------------+--------------+--------------+--------------")
	EndIf
	End Transaction

RestArea(aAreaAnt)
Return lDiverg

//----------------------------------------------------------
// Registra ocorrência dos itens divergentes
//----------------------------------------------------------
Static Function RegOcorren(cDocto,cSerie,cLogFile)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local lRet       := .T.
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local nToler1UM  := SuperGetMV("MV_NTOL1UM",.F.,0)

	Begin Transaction
	
	cQuery := "SELECT R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"','"+cStatProb+"')"
	cQuery +=   " AND (DB_RECHUM = '"+__cUserID+"'"
	cQuery +=     " OR DB_RECHUM = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	While lRet .And. (cAliasQry)->(!Eof())
	   SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	   If (lRet := RecLock("SDB",.F.))
	      If QtdComp(SDB->DB_QUANT) != QtdComp(SDB->DB_QTDLID) .And.;
	         QtdComp(Abs(SDB->DB_QUANT-SDB->DB_QTDLID)) > QtdComp(nToler1UM)
	         SDB->DB_STATUS := cStatProb //Status Com Problemas
	         SDB->DB_ANOMAL := 'S'
	      Else
	         SDB->DB_STATUS := cStatExec //Status Executado
	      EndIf
	      SDB->DB_RECHUM  := __cUserID
	      SDB->DB_DATAFIM := dDataBase
	      SDB->DB_HRFIM   := Time()
	      SDB->(MsUnlock())
	   EndIf
	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	
	If lRet
	   //Grava o log em arquivo
	   GravLogDiv(cLogFile)
	Else
	   WmsMessage(STR0044,STR0001) //"Problemas no registro da ocorrência!"
	   DisarmTransaction()
	EndIf
	
	End Transaction
	
RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
// Reinicia a conferência somente dos itens divergentes
//----------------------------------------------------------
Static Function ReConfDiv(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local lRet       := .T.
Local lRetPE     := .T.
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local nToler1UM  := SuperGetMV("MV_NTOL1UM",.F.,0)
	
	Begin Transaction
	
	cQuery := "SELECT R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatInte+"','"+cStatAExe+"','"+cStatProb+"')"
	cQuery +=   " AND (DB_RECHUM = '"+__cUserID+"'"
	cQuery +=     " OR DB_RECHUM = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	While lRet .And. (cAliasQry)->(!Eof())
	   SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	   If QtdComp(SDB->DB_QUANT) != QtdComp(SDB->DB_QTDLID) .And.;
	      QtdComp(Abs(SDB->DB_QUANT-SDB->DB_QTDLID)) > QtdComp(nToler1UM)
	      If (lRet := RecLock("SDB",.F.))
	         SDB->DB_DATAFIM := CtoD('  /  /    ')
	         SDB->DB_HRFIM   := ''
	         SDB->DB_STATUS  := cStatAExe //Status A Executar
	         SDB->DB_QTDLID  := 0
	         SDB->DB_ANOMAL  := ''
	         SDB->(MsUnlock())
	         If lWV073GQL
		      		lRetPE := ExecBlock('WV073GQL', .F., .F.)
		      		If ValType(lRetPE) = 'L' .And. !lRetPE
		      			lRet := .F.
		      		EndIf
		      	EndIf
	      EndIf
	   EndIf
	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	If lRet
	   lRet := .F. //Necessário para que a conferência não seja encerrada
	Else
	   WmsMessage(STR0045,STR0001) //"Problemas no reinício das atividades divergentes!"
	   DisarmTransaction()
	EndIf
	
	End Transaction

RestArea(aAreaAnt)
Return lRet

//-----------------------------------------------------------------------------
//Efetua a validação para verificar se não exitem mais itens pendentes
//Caso não exista mais nenhuma pendencia, somente deverá ser finalizado a conferência
//-----------------------------------------------------------------------------
Static Function SaiCofEnt(cDocto,cSerie)
Local aAreaAnt := GetArea()
Local lRet     := .T.

   If !AtivAtuPen(cDocto,cSerie)
      If !DocAntPen(cDocto,cSerie)
         DLVTAviso(STR0001,STR0046) // "Não existem mais itens para serem conferidos. Conferência deve ser finalizada."
         lRet := .F.
      EndIf
   EndIf
   RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
//Verifica se existem atividades do documento atual ainda pendentes
//----------------------------------------------------------
Static Function AtivAtuPen(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])
Local lRet       := .F.

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	cQuery +=   " AND DB_ATIVID  = '"+cAtividade+"'"
	cQuery +=   " AND DB_STATUS IN ('"+cStatProb+"','"+cStatInte+"','"+cStatAExe+"')"
	cQuery +=   " AND (DB_RECHUM  = '"+__cUserID+"'"
	cQuery +=     " OR DB_RECHUM  = '"+cRecHVazio+"')"
	If !lWmsDaEn
		cQuery +=   " AND DB_LOCAL    = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ  = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	lRet := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
// Reinicia as atividades de conferência do documento
//----------------------------------------------------------
Static Function ReConfTudo(cDocto,cSerie)
Local aAreaAnt   := GetArea()
Local cQuery     := ""
Local cAliasQry  := GetNextAlias()
Local lRet       := .T.
Local n1Cnt      := 1

Private aParam150 := {}
Private aLibSDB   := {}

	Begin Transaction
	//Para realizar o reinício das atividades, as SDBs não podem ser apenas zeradas,
	//pois pode ser que elas tenham sido quebradas para atender às quantidades
	//informadas sem lote na inclusão do documento
	cQuery := "SELECT SDB.R_E_C_N_O_ RECNOSDB"
	cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
	cQuery += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"'"
	cQuery +=   " AND DB_ESTORNO = ' '"
	cQuery +=   " AND DB_ATUEST  = 'N'"
	cQuery +=   " AND DB_DOC     = '"+cDocto+"'"
	cQuery +=   " AND DB_SERIE   = '"+cSerie+"'"
	cQuery +=   " AND DB_SERVIC  = '"+cServico+"'"
	cQuery +=   " AND DB_ORDTARE = '"+cOrdTar+"'"
	cQuery +=   " AND DB_TAREFA  = '"+cTarefa+"'"
	If !lWmsDaEn 
		cQuery +=   " AND DB_LOCAL   = '"+cArmazem+"'"
	EndIf
	cQuery +=   " AND DB_LOCALIZ = '"+cEndereco+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	DCR->(DbSetOrder(1)) //DCR_FILIAL+DCR_IDORI+DCR_IDDCF+DCR_IDMOV+DCR_IDOPER
	//Prossegue com o estorno de todos os movimentos
	While lRet .And. (cAliasQry)->(!Eof())
	   SDB->(DbGoTo((cAliasQry)->RECNOSDB))
	   If (lRet := RecLock("SDB",.F.))
	      SDB->DB_ESTORNO := 'S'
	      SDB->(MsUnlock())
	   EndIf
	   //Deleta o registro relacionado na DCR
	   If DCR->(DbSeek(xFilial('DCR')+SDB->DB_IDDCF+SDB->DB_IDDCF+SDB->DB_IDMOVTO+SDB->DB_IDOPERA))
	      If (lRet := RecLock("DCR",.F.))
	         DCR->(DbDelete())
	         DCR->(MsUnlock())
	      EndIf
	   EndIf
	   (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	//Se o estorno dos movimentos ocorreu com sucesso
	If lRet
		cQuery := "SELECT R_E_C_N_O_ RECNODCF"
		cQuery += " FROM "+RetSqlName('DCF')+" DCF"
		cQuery += " WHERE DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=   " AND DCF_DOCTO  = '"+cDocto+"'"
		cQuery +=   " AND DCF_SERIE  = '"+cSerie+"'"
		cQuery +=   " AND DCF_SERVIC = '"+cServico+"'"
		If !lWmsDaEn 
			cQuery +=   " AND DCF_LOCAL  = '"+cArmazem+"'"
		EndIf
		cQuery +=   " AND DCF_ENDER  = '"+cEndereco+"'"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		//Recria os movimentos com base nas ordens de serviço do documento
		While lRet .And. (cAliasQry)->(!Eof())
		   DCF->(DbGoTo((cAliasQry)->RECNODCF))
		   aParam150     := Array(33)
		   aParam150[01] := DCF->DCF_CODPRO   //-- Produto
		   aParam150[02] := DCF->DCF_LOCAL    //-- Local Origem
		   aParam150[03] := DCF->DCF_DOCTO    //-- Documento
		   aParam150[04] := DCF->DCF_SERIE    //-- Serie
		   aParam150[05] := DCF->DCF_NUMSEQ   //-- Sequencial
		   aParam150[06] := DCF->DCF_QUANT    //-- Saldo do produto em estoque
		   aParam150[07] := dDataBase         //-- Data da Movimentacao
		   aParam150[08] := Time()            //-- Hora da Movimentacao
		   aParam150[09] := cServico          //-- Servico
		   aParam150[10] := cTarefa           //-- Tarefa
		   aParam150[11] := ''                //-- Atividade
		   aParam150[12] := DCF->DCF_CLIFOR   //-- Cliente/Fornecedor
		   aParam150[13] := DCF->DCF_LOJA     //-- Loja
		   aParam150[14] := ''                //-- Tipo da Nota Fiscal
		   aParam150[15] := '01'              //-- Item da Nota Fiscal
		   aParam150[16] := ''                //-- Tipo de Movimentacao
		   aParam150[17] := DCF->DCF_ORIGEM   //-- Origem de Movimentacao
		   aParam150[18] := DCF->DCF_LOTECT   //-- Lote
		   aParam150[19] := DCF->DCF_NUMLOT   //-- Sub-Lote
		   aParam150[20] := DCF->DCF_ENDER    //-- Endereco
		   aParam150[21] := DCF->DCF_ESTFIS   //-- Estrutura Fisica
		   aParam150[22] := Val(DCF->DCF_REGRA)//-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
		   aParam150[23] := DCF->DCF_CARGA    //-- Carga
		   aParam150[24] := DCF->DCF_UNITIZ   //-- Nr. do Pallet
		   aParam150[25] := DCF->DCF_LOCAL    //-- Local Destino
		   aParam150[26] := DCF->DCF_ENDER    //-- Endereco Destino
		   aParam150[27] := DCF->DCF_ESTFIS   //-- Estrutura Fisica Destino
		   aParam150[28] := cOrdTar           //-- Ordem da Tarefa
		   aParam150[29] := ''                //-- Ordem da Atividade
		   aParam150[30] := ''                //-- Recurso Humano
		   aParam150[31] := ''                //-- Recurso Fisico
		   aParam150[32] := DCF->DCF_ID       //-- Identificador do DCF
		   aParam150[33] := DCF->DCF_CODNOR      //-- Identificador do DCF
		   //Criação dos movimentos para o processo de conferência de recebimento
		   lRet := DLConfEnt()
		   (cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	EndIf
	If lRet
	   //Reprocessa regra WMS para definir sequência de priorização
	   WmsRegra('7',cArmazem,,cServico)
	   For n1Cnt := 1 To Len(aLibSDB)
	      SDB->(DbGoTo(aLibSDB[n1Cnt,2]))
	      If SDB->(!Eof())
	         RecLock('SDB',.F.)
	         SDB->DB_RECHUM  = __cUserID
	         SDB->DB_STATUS := '4'
	         SDB->(MsUnlock())
	      EndIf
	   Next
	   lRet := .F. //Necessário para que a conferência não seja encerrada
	Else
	   WmsMessage(STR0047,STR0001) //"Problemas no reinício das atividades de conferência!"
	   DisarmTransaction()
	EndIf
	End Transaction
	
RestArea(aAreaAnt)
Return lRet

//----------------------------------------------------------
// Iprime log de divergências
//----------------------------------------------------------
Static Function ImprLogDiv(cDocto,cSerie,cLogFile,nContTent,cDCFAnt,nItem,lCabecalho)
Local cWmsDoc  := ""
Local cUsuario := ""
Local cLoteSys := ""
Local nQtdeSys := 0

   // Protheus SIGAWMS - LOG de Ocorrências na Conferência de Recebimento (RF000001.LOG)
   // Log gerado em 10/04/2015, as 15:27:37
   // Usuário..................: Administrador
   // Documento / Série........: 000071 / UNI
   // Tentativa Conferência no.: 1
   // Número de Divergências...: 4
   // -----+-----------------+--------------+--------------+--------------+--------------
   // Item |Produto          |Lote Sistema  |Qtd Sistema   |Lote Usuário  |Qtd Usuário
   // -----+-----------------+--------------+--------------+--------------+--------------
   // 001  |PRDWMS0001       |      LT041003|        600,00|              |          0,00
   //      |                 |              |      6.000,00|              |          0,00
   // -----+-----------------+--------------+--------------+--------------+--------------
   // 002  |PRDWMS0003       |      LT041005|        150,00|      LT000001|        150,00
   //      |                 |              |              |              |
   // -----+-----------------+--------------+--------------+--------------+--------------
   // 003  |PRDWMS0004       |      LT041001|        150,00|      LT041001|        100,00
   //      |                 |              |      2.250,00|              |      1.500,00
   // -----+-----------------+--------------+--------------+--------------+--------------
   // 003  |PRDWMS0005       |              |      1.000,00|      LT150415|        100,00
   //      |                 |              |        100,00|              |         10,00
   //      |                 |              |              |      LT885782|        200,00
   //      |                 |              |              |              |         20,00
   // -----+-----------------+--------------+--------------+--------------+--------------

   If lCabecalho
      cWmsDoc  := SuperGetMV("MV_WMSDOC",.F.,"")
      cUsuario := Posicione('DCD',1,xFilial('DCD')+__cUserID,'DCD_NOMFUN')
      cLogFile := "RF"+AllTrim(cDocto)+".LOG"
      //-- MV_WMSDOC - Define o diretorio onde serao armazenados os documentos/logs gerados pelo WMS.
      //-- Este parametro deve estar preenchido com um diretorio criado abaixo do RootPath.
      //-- Exemplo: Preencha o parametro com \WMS para o sistema mover o log de ocorrencias do diretorio
      //-- C:\MP8\SYSTEM p/o diretorio C:\MP8\WMS
      If !Empty(cWmsDoc)
         cWmsDoc := AllTrim(cWmsDoc)
         If Right(cWmsDoc,1) $ "/\"
            cWmsDoc := Left(cWmsDoc,Len(cWmsDoc)-1)
         EndIf
         cLogFile := cWmsDoc+"\"+cLogFile
      EndIf
      AutoGrLog(WmsFmtMsg(STR0048,{{"[VAR01]",cLogFile}})) //"Microsiga Protheus WMS - LOG de Ocorrências na Conferência de Recebimento ([VAR01])"
      AutoGrLog(WmsFmtMsg(STR0049,{{"VAR01",DtoC(dDataBase)},{"VAR02",Time()}})) //"Log gerado em [VAR01], as [VAR02]"
      AutoGrLog(STR0050 + AllTrim(cUsuario))                         //"Usuário..................: "
      AutoGrLog(STR0051 + AllTrim(cDocto) + " / " + AllTrim(cSerie)) //"Documento / Série........: "
      AutoGrLog(STR0052 + AllTrim(Str(nContTent)))                   //"Tentativa Conferência no.:"
      AutoGrLog("-----+-----------------+--------------+--------------+--------------+--------------")
      AutoGrLog(PadR(STR0053,5)+"|"+PadR(STR0019,17)+"|"+PadR(STR0054,14)+"|"+PadR(STR0055,14)+"|"+PadR(STR0056,14)+"|"+PadR(STR0057,14)) //"Item" //"Produto" //"Lote Sistema" //"Qtd Sistema" //"Lote Usuário" //"Qtd Usuário"
   EndIf
   //Se a SDB corresponde a uma DCF diferente, deve buscar as informações novamente
   If cDCFAnt != SDB->DB_IDDCF
      LotQtdDCF(cDocto,cSerie,SDB->DB_PRODUTO,SDB->DB_IDDCF,@cLoteSys,@nQtdeSys)
      //Salva o IDDCF
      cDCFAnt := SDB->DB_IDDCF
      //Imprime as informações da DCF somente na primeira vez
      AutoGrLog("-----+-----------------+--------------+--------------+--------------+--------------")
      AutoGrLog(StrZero(nItem,3)+"  |"+PadR(SDB->DB_PRODUTO,17)+"|"+PadR(cLoteSys,14)+"|"+Transform(nQtdeSys,PesqPict('SDB','DB_QUANT'))+"|"+PadR(SDB->DB_LOTECTL,14)+"|"+Transform(SDB->DB_QTDLID,PesqPict('SDB','DB_QTDLID')))
      AutoGrLog("     |                 |              |"+Transform(ConvUm(SDB->DB_PRODUTO,nQtdeSys,0,2),PesqPict('SDB', 'DB_QUANT'))+ "|              |"+Transform(ConvUm(SDB->DB_PRODUTO,SDB->DB_QTDLID,0,2),PesqPict('SDB', 'DB_QUANT')))
      nItem++
   Else
      //Enquanto as SDBs corresponderem a um mesmo IDDCF, não é necessária a impressão das informações da DCF
      AutoGrLog("     |                 |              |              |"+PadR(SDB->DB_LOTECTL,14)+"|"+Transform(SDB->DB_QTDLID,PesqPict('SDB','DB_QTDLID')))
      AutoGrLog("     |                 |              |"+Transform(ConvUm(SDB->DB_PRODUTO,nQtdeSys,0,2),PesqPict('SDB', 'DB_QUANT'))+ "|              |"+Transform(ConvUm(SDB->DB_PRODUTO,SDB->DB_QTDLID,0,2),PesqPict('SDB', 'DB_QUANT')))
   EndIf

Return

//----------------------------------------------------------
// Finaliza log de divergências
//----------------------------------------------------------
Static Function GravLogDiv(cLogFile)
Local lRet    := .T.
Local aLog    := {}
Local nHandle := 0
Local n1Cnt   := 0

   VTAlert(STR0058,STR0059, .T., 3000, 3) //"Aguarde... Gerando o LOG." //"Processamento"
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
         FWrite(nHandle,aLog[n1Cnt]+CRLF)
      Next
      FClose(nHandle)
      WmsMessage(WmsFmtMsg(STR0060,{{"[VAR01]",cLogFile}}),STR0001) //"O LOG [VAR01] foi gerado. Entre em contato com seu supervisor."
   Else
      WmsMessage(STR0061,STR0001) //"Problemas ao tentar gerar o LOG."
   EndIf
   VTClear()

Return lRet

//----------------------------------------------------------
// Busca, de acordo com a SDB, lote e quantidade correspondente na DCF
//----------------------------------------------------------
Static Function LotQtdDCF(cDocto,cSerie,cProduto,cIDDCF,cLoteSys,nQtdeSys)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasDCF := GetNextAlias()

   cQuery := "SELECT DCF_LOTECT, DCF_QUANT"
   cQuery +=  " FROM "+RetSqlName('DCF')+" DCF"
   cQuery += " WHERE DCF_FILIAL = '"+xFilial('DCF')+"'"
   cQuery +=   " AND DCF_DOCTO  = '"+cDocto+"'"
   cQuery +=   " AND DCF_SERIE  = '"+cSerie+"'"
   cQuery +=   " AND DCF_CODPRO = '"+cProduto+"'"
   cQuery +=   " AND DCF_ID     = '"+cIDDCF+"'"
   cQuery +=   " AND D_E_L_E_T_ = ' '"
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
   If (cAliasDCF)->(!Eof())
      cLoteSys := (cAliasDCF)->DCF_LOTECT
      nQtdeSys := (cAliasDCF)->DCF_QUANT
   EndIf
   (cAliasDCF)->(DbCloseArea())

   RestArea(aAreaAnt)
Return

//----------------------------------------------------------
//Questiona ao usuário se o mesmo deseja sair da conferência, abandonando a mesma
//----------------------------------------------------------
Static Function WMSV073ESC(lAbandona)
//-- Disponibiliza novamente o documento para convocação quando o operador
//-- altera o documento ou abandona conferência pelo Coletor RF.
Local lLiberaRH  := SuperGetMV('MV_WMSCLRH',.F.,.T.)
Local cRecHVazio := Space(TamSX3('DB_RECHUM')[1])

   If WmsQuestion(STR0062) //"Deseja sair da conferencia?"
      //-- Variavel private definida no programa dlgv001
      lAbandona := .T.
      //-- Variavel definida no programa dlgv001
      DLVAltSts(.F.)

      //Grava SDB
      RecLock('SDB', .F.)  // Trava para gravacao
      SDB->DB_RECHUM := Iif(lLiberaRH,cRecHVazio,SDB->DB_RECHUM)
      SDB->DB_STATUS := cStatAExe // Atividade A Executar
      //-- Libera o registro do arquivo SDB
      MsUnlock()
      If lLiberaRH
         //-- Retira recurso humano atribuido as atividades de outros itens do mesmo documento/série.
         CancRHServ(SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_SERVIC)
      EndIf
   EndIf
Return Nil
