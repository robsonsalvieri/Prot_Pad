#INCLUDE "PROTHEUS.CH"
#INCLUDE "WMSXFUNG.CH"
/*
+---------+--------------------------------------------------------------------+
|Função   | WMSXFUNG - Funções WMS Integração com Movimentações Internas       |
+---------+--------------------------------------------------------------------+
|Objetivo | Deverá agrupar todas as funções que serão utilizadas em            |
|         | integrações que estejam relacionadas com o proceso de movimentação |
|         | interna (devolução/requisição) e movimentação entre armazéns.      |
|         | Validações, Geração, Estorno...                                    |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSXFUNG01 "WMSXFUNG01"
#DEFINE WMSXFUNG02 "WMSXFUNG02"
#DEFINE WMSXFUNG03 "WMSXFUNG03"
#DEFINE WMSXFUNG04 "WMSXFUNG04"
#DEFINE WMSXFUNG05 "WMSXFUNG05"
#DEFINE WMSXFUNG06 "WMSXFUNG06"
#DEFINE WMSXFUNG07 "WMSXFUNG07"
#DEFINE WMSXFUNG08 "WMSXFUNG08"
#DEFINE WMSXFUNG09 "WMSXFUNG09"
#DEFINE WMSXFUNG10 "WMSXFUNG10"
#DEFINE WMSXFUNG11 "WMSXFUNG11"
#DEFINE WMSXFUNG12 "WMSXFUNG12"
#DEFINE WMSXFUNG13 "WMSXFUNG13"
#DEFINE WMSXFUNG14 "WMSXFUNG14"
#DEFINE WMSXFUNG15 "WMSXFUNG15"
#DEFINE WMSXFUNG16 "WMSXFUNG16"
#DEFINE WMSXFUNG17 "WMSXFUNG17"
#DEFINE WMSXFUNG18 "WMSXFUNG18"
#DEFINE WMSXFUNG19 "WMSXFUNG19"
#DEFINE WMSXFUNG20 "WMSXFUNG20"
#DEFINE WMSXFUNG21 "WMSXFUNG21"
#DEFINE WMSXFUNG22 "WMSXFUNG22"
#DEFINE WMSXFUNG23 "WMSXFUNG23"
#DEFINE WMSXFUNG24 "WMSXFUNG24"
#DEFINE WMSXFUNG25 "WMSXFUNG25"
#DEFINE WMSXFUNG26 "WMSXFUNG26"
#DEFINE WMSXFUNG27 "WMSXFUNG27"
#DEFINE WMSXFUNG28 "WMSXFUNG28"
#DEFINE WMSXFUNG29 "WMSXFUNG29"
#DEFINE WMSXFUNG30 "WMSXFUNG30"
#DEFINE WMSXFUNG31 "WMSXFUNG31"
#DEFINE WMSXFUNG32 "WMSXFUNG32"
#DEFINE WMSXFUNG33 "WMSXFUNG33"
#DEFINE WMSXFUNG34 "WMSXFUNG34"
#DEFINE WMSXFUNG35 "WMSXFUNG35"
#DEFINE WMSXFUNG36 "WMSXFUNG36"
#DEFINE WMSXFUNG37 "WMSXFUNG37"
#DEFINE WMSXFUNG38 "WMSXFUNG38"
#DEFINE WMSXFUNG39 "WMSXFUNG39"
#DEFINE WMSXFUNG40 "WMSXFUNG40"
#DEFINE WMSXFUNG41 "WMSXFUNG41"

/*-----------------------------------------------------------------------------
Valida a integração da entrada de notas fiscais com WMS
Efetua validações com base no cabeçalho das notas fiscais
-----------------------------------------------------------------------------*/
Function WmsAvalDH1(cAcao,cAlias,cRotina,oNil,cEndereco)
Local lRet     := .T.
Local oOrdServ := WmsOrdSer() // Busca referencia do objeto WMS
Local oDmdUnit := Nil

Default cEndereco  := ""

	If cAcao == "1"
		If (cAlias)->DH1_TM <= '500' .And. WmsArmUnit((cAlias)->DH1_LOCAL) //Verifica se armazém utiliza unitizador
			oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
			oDmdUnit:SetOrigem('DH1')
			oDmdUnit:SetNumSeq((cAlias)->DH1_NUMSEQ)
			oDmdUnit:SetDocto((cAlias)->DH1_DOC)
			oDmdUnit:oProdLote:SetArmazem((cAlias)->DH1_LOCAL)
			// Dados endereço origem
			oDmdUnit:oDmdEndOri:SetArmazem((cAlias)->DH1_LOCAL)
			oDmdUnit:oDmdEndOri:SetEnder(cEndereco)
			// Dados endereço destino
			oDmdUnit:oDmdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
			oDmdUnit:oDmdEndDes:SetEnder((cAlias)->DH1_LOCALI)
			oDmdUnit:CreateD0Q()
		Else
			//-- Somente cria a ordem de serviço na primeira vez
			If oOrdServ == Nil .OR. (oOrdServ != Nil .AND. GetClassName(oOrdServ) <> "WMSDTCORDEMSERVICOCREATE") 
				oOrdServ := WMSDTCOrdemServicoCreate():New()
				WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
			EndIf

			oOrdServ:SetDocto((cAlias)->DH1_DOC)
			oOrdServ:SetNumSeq((cAlias)->DH1_NUMSEQ)
			oOrdServ:SetCf((cAlias)->DH1_CF) // Tipo de REquisição/DEvolução
			oOrdServ:SetIdUnit("")
			
			If AllTrim(cRotina) $ "MATA240/MATA241" // Movimentação interda de requisição/devolução
				If (cAlias)->DH1_TM <= '500' // Devolução
					// Dados endereço origem
					oOrdServ:oOrdEndOri:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndOri:SetEnder(cEndereco)
					// Dados endereço destino
					oOrdServ:oOrdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndDes:SetEnder((cAlias)->DH1_LOCALI)
				Else
					// Requisição
					// Dados endereço origem
					oOrdServ:oOrdEndOri:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndOri:SetEnder((cAlias)->DH1_LOCALI)
					// Dados endereço destino
					oOrdServ:oOrdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
					oOrdServ:oOrdEndDes:SetEnder(cEndereco)
				EndIf

				oOrdServ:oProdLote:SetPrdOri((cAlias)->DH1_PRODUT) // Produto Origem
				oOrdServ:oProdLote:SetProduto((cAlias)->DH1_PRODUT) // Produto
				oOrdServ:oProdLote:SetArmazem((cAlias)->DH1_LOCAL) // Armazém
				oOrdServ:oProdLote:SetLoteCtl((cAlias)->DH1_LOTECT) // Lote
				oOrdServ:oProdLote:SetNumLote((cAlias)->DH1_NUMLOT) // Sub-Lote

			ElseIf AllTrim(cRotina) $ "MATA260/MATA261/MATA175" // Transferência
				// Dados endereço destino
				oOrdServ:oOrdEndDes:SetArmazem((cAlias)->DH1_LOCAL)
				oOrdServ:oOrdEndDes:SetEnder((cAlias)->DH1_LOCALI)

				// Posiciona no primeiro DH1 criado para buscar o endereço origem
				DH1->(dbSetOrder(2)) //DH1_FILIAL+DH1_DOC+DH1_NUMSEQ
				DH1->(dbSeek(xFilial("DH1")+(cAlias)->(DH1->DH1_DOC+DH1_NUMSEQ) )) //DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ

				// Dados endereço origem
				oOrdServ:oOrdEndOri:SetArmazem(DH1->DH1_LOCAL)
				oOrdServ:oOrdEndOri:SetEnder(DH1->DH1_LOCALI)

				oOrdServ:oProdLote:SetPrdOri(DH1->DH1_PRODUT) // Produto Origem
				oOrdServ:oProdLote:SetProduto(DH1->DH1_PRODUT) // Produto
				oOrdServ:oProdLote:SetArmazem(DH1->DH1_LOCAL) // Armazém
				oOrdServ:oProdLote:SetLoteCtl(DH1->DH1_LOTECT) // Lote
				oOrdServ:oProdLote:SetNumLote(DH1->DH1_NUMLOT) // Sub-Lote
			EndIf

			oOrdServ:oProdLote:LoadData()

			oOrdServ:SetOrigem('DH1')
			If !(lRet := oOrdServ:CreateDCF())
				If cRotina == "MATA241"
					WmsMessage(oOrdServ:GetErro(),"CreateDCF",1)
				Else 
				     WmsMessage(oOrdServ:GetErro(),"CreateDCF",1,.F.)
				EndIF 
			EndIf
			If lRet .And. !oOrdServ:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
				WmsEmpB2B8(.T./*lReserva*/,oOrdServ:nQuant,oOrdServ:oProdLote:GetProduto(),oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oProdLote:GetLoteCtl(),oOrdServ:oProdLote:GetNumLote())
			EndIf
		EndIf
	ElseIf cAcao == "2" //-- Processamento das regras WMS referentes as ordens de serviço do documento
		//-- Verifica as Ordens de servico geradas para execução automatica
		WmsExeServ()
	EndIf
Return lRet

//------------------------------------------------------------------------------
Function WmsAvalSD3(cAcao,cAlias,cRotina,cEndereco)
//------------------------------------------------------------------------------
Local lRet := .T.

	If cAcao == "1" // Integração da movimentação interna a partir da SD3
		lRet := IntMovInt(cRotina,cEndereco)
	ElseIf cAcao == "2" // Execução dos serviços no WMS
		WmsExeServ()
	ElseIf cAcao == "3" // Valida estorno da movimentação interna
		lRet := ValEstMov(cRotina)
	ElseIf cAcao == "4" // Estorna movimentação interna
		lRet := EstMovInt()
	ElseIf cAcao == "5" // Chamado pelo A240TudoOk
		lRet := ValIntMov1(cRotina)
	ElseIf cAcao == "6" // Chamado pelo A241LinOk
		lRet := ValIntMov2(cRotina)
	ElseIf cAcao == "7" // Chamado pelo Estorno inventario
		lRet := EstMovInv()	
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Function WmsEmpB2B8(lReserva,nQuant,cProduto,cArmazem,cLoteCtl,cNumLote,lEmpSB8)
//-----------------------------------------------------------------------------
Local cOper := Iif(lReserva,"+","-")
Local nValNovo := 0
Local lRet := .T.
Default lEmpSB8 := .T.

	// Geração da reserva SB2
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
	If !SB2->(dbSeek(xFilial("SB2")+cProduto+cArmazem))
		CriaSB2(cProduto,cArmazem)
	EndIf
	nValNovo := SB2->B2_RESERVA + (nQuant * (Iif(cOper == "-",-1,1)))
	GravaB2Emp(cOper,nQuant,"",.T.)
	
	lRet := B2_RESERVA = nValNovo
	If !lRet
		WmsMessage(STR0030,WMSXFUNG26) //Erro ao atualizar Reserva do Estoque (B2_RESERVA)
	EndIf

	// Geração da reserva SB8
	If lRet .And. lEmpSB8 .And. Rastro(cProduto) .And. !Empty(cLoteCtl+cNumLote)
		SB8->(dbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
		SB8->(dbSeek( xFilial("SB8")+cProduto+cArmazem+cLoteCtl+cNumLote))
		nValNovo := SB8->B8_EMPENHO + (nQuant * (Iif(cOper == "-",-1,1)))
		GravaB8Emp(cOper,nQuant,"",.T.)
		
		lRet := B8_EMPENHO = nValNovo
		If !lRet
			WmsMessage(STR0031,WMSXFUNG27) //Erro ao atualizar Empenho do Estoque por Lote (B8_EMPENHO)
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------
Function WmsGeraDH1(cRotina, lEmpSB8, lDevolucao)
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local nX         := 0
Local cNumSeq    := ""
Local aItenDH1   := {}
Local oOrdServ   := WmsOrdSer()
Local lCpoUser   := ExistBlock('CPOSDH1')
Local aCpoUser   := {}
Local aCpoAuxUsr := {}
Local nPosAux    := 0
Local nY         := 0
Local nMax       := 0

Default lEmpSB8    := .T.
Default lDevolucao := .T.
	
	nMax := IIf(lDevolucao,2,1)
	// Valida informações do objeto para geração DH1
	If Empty(oOrdServ:oProdLote:GetProduto())
		WmsMessage(STR0001,WMSXFUNG17) //"Produto não informado para geração DH1"
		lRet := .F.
	EndIf

	If lRet .And. Empty(oOrdServ:oOrdEndOri:GetArmazem())
		WmsMessage(STR0002,WMSXFUNG18) //"Armazém origem não informado para geração DH1"
		lRet := .F.
	EndIf

	If oOrdServ:GetOrigem() != "SD4"
		If lRet .And. Empty(oOrdServ:oOrdEndOri:GetEnder())
			WmsMessage(STR0003,WMSXFUNG19) //"Endereço origem não informado para geração DH1"
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. Empty(oOrdServ:oOrdEndDes:GetArmazem())
		WmsMessage(STR0004,WMSXFUNG20) //"Armazém destino não informado para geração DH1"
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(oOrdServ:GetQuant()) <= 0
		WmsMessage(STR0006,WMSXFUNG22) //"Quantidade não informada para geração DH1"
		lRet := .F.
	EndIf

	If lRet .And. Empty(oOrdServ:oServico:GetServico())
		WmsMessage(STR0007,WMSXFUNG23) //"Serviço não informado para geração DH1"
		lRet := .F.
	EndIf

	If oOrdServ:GetOrigem() != "SD4"
		If lRet .And. oOrdServ:oProdLote:HasRastro() .And. Empty(oOrdServ:oProdLote:GetLoteCtl())
			WmsMessage(STR0008,WMSXFUNG24) //"Lote não informado para geração DH1"
			lRet := .F.
		EndIf
	
		If lRet .And. oOrdServ:oProdLote:HasRastSub() .And. Empty(oOrdServ:oProdLote:GetNumLote())
			WmsMessage(STR0013,WMSXFUNG25) //"Sub-Lote não informado para geração DH1"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Atribui o código sequencial
		// Caso for origem SD4, entende-se que o número da sequência já encontra-se definida na ordem de serviço previamente criada
		If oOrdServ:GetOrigem() == "SD4" .And. !Empty(oOrdServ:GetNumSeq())
			cNumSeq := oOrdServ:GetNumSeq()
		Else 
			cNumSeq := ProxNum()
			oOrdServ:SetNumSeq(cNumSeq)
		EndIf
		// Gerar a movimentacao de REQUISICAO = 1 / DEVOLUCAO = 2
		For nX := 1 To nMax
			aAdd(aItenDH1,Array(33))
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+oOrdServ:oProdLote:GetProduto()))
			aItenDH1[nX][01]/*DH1_FILIAL*/:= xFilial("SD3")
			aItenDH1[nX][02]/*DH1_TM    */:= IIf(nX == 1,"999","499")
			aItenDH1[nX][03]/*DH1_EMISAO*/:= dDataBase
			aItenDH1[nX][04]/*DH1_NUMSEQ*/:= cNumSeq
			aItenDH1[nX][05]/*DH1_PRODUT*/:= oOrdServ:oProdLote:GetProduto()
			aItenDH1[nX][06]/*DH1_LOTECT*/:= oOrdServ:oProdLote:GetLoteCtl()
			aItenDH1[nX][07]/*DH1_LOCAL */:= IIf(nX == 1,oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oOrdEndDes:GetArmazem())
			aItenDH1[nX][08]/*DH1_LOCALI*/:= IIf(nX == 1,oOrdServ:oOrdEndOri:GetEnder(),oOrdServ:oOrdEndDes:GetEnder())
			aItenDH1[nX][09]/*DH1_QUANT */:= oOrdServ:GetQuant()
			aItenDH1[nX][10]/*DH1_QTSEGU*/:= ConvUm(oOrdServ:oProdLote:GetProduto(),oOrdServ:GetQuant(),0,2)
			aItenDH1[nX][11]/*DH1_TRT   */:= oOrdServ:GetTrt()
			aItenDH1[nX][12]/*DH1_PROJPM*/:= CriaVar("DH1_PROJPM")
			aItenDH1[nX][13]/*DH1_TASKPM*/:= CriaVar("DH1_TASKPM")
			aItenDH1[nX][14]/*DH1_CLVL  */:= CriaVar("DH1_CLVL")
			aItenDH1[nX][15]/*DH1_SERVIC*/:= oOrdServ:oServico:GetServico()
			aItenDH1[nX][16]/*DH1_CC    */:= CriaVar("DH1_CC")
			aItenDH1[nX][17]/*DH1_CONTA */:= SB1->B1_CONTA
			aItenDH1[nX][18]/*DH1_ITEMCT*/:= CriaVar("DH1_ITEMCT")
			aItenDH1[nX][19]/*DH1_STATUS*/:= "1"
			aItenDH1[nX][20]/*DH1_OP    */:= oOrdServ:GetOp()
			aItenDH1[nX][21]/*DH1_NUMSA */:= CriaVar("DH1_NUMSA")
			aItenDH1[nX][22]/*DH1_ITEMSA*/:= CriaVar("DH1_ITEMSA")
			aItenDH1[nX][23]/*DH1_DOC   */:= oOrdServ:GetDocto()
			aItenDH1[nX][24]/*DH1_CF    */:= IIf(nX == 1,"RE4","DE4")
			aItenDH1[nX][25]/*DH1_NUMLOT*/:= IIf(oOrdServ:oProdLote:HasRastSub(),oOrdServ:oProdLote:GetNumLote(),CriaVar("D3_NUMLOTE"))
			aItenDH1[nX][26]/*DH1_NUMSER*/:= CriaVar("D3_NUMSERI")
			aItenDH1[nX][27]/*DH1_CUSTO1*/:= 0
			aItenDH1[nX][28]/*DH1_CUSTO2*/:= 0
			aItenDH1[nX][29]/*DH1_CUSTO3*/:= 0
			aItenDH1[nX][30]/*DH1_CUSTO4*/:= 0
			aItenDH1[nX][31]/*DH1_CUSTO5*/:= 0
			If Empty(oOrdServ:oProdLote:GetDtValid())
			   oOrdServ:oProdLote:SetDtValid(STOD("//"))
			Endif 
			aItenDH1[nX][32]/*DH1_DTVALI*/:= oOrdServ:oProdLote:GetDtValid()
			aItenDH1[nX][33]/*DH1_POTENC*/:= 0
			// Campos extras WMS
			AAdd(aCpoAuxUsr,{})
			nPosAux := Len(aCpoAuxUsr)
			AAdd(aCpoAuxUsr[nPosAux],{"DH1_IDDCF",oOrdServ:GetIdDCF()})
			// Campos extras usuário
			If lCpoUser
				aCpoUser := ExecBlock('CPOSDH1',.F.,.F.,{cRotina,nX})
				If ValType(aCpoUser) == 'A'
					For nY := 1 to Len(aCpoUser)
						AAdd(aCpoAuxUsr[nPosAux],{aCpoUser[nY,1],aCpoUser[nY,2]})
					Next nY
				EndIf
			EndIf
		Next nX
		// Grava DH1 sem gerar ordem de serviço (cGravaWms == "2")
		If (lRet := EspDH1Wms(aItenDH1,cRotina,oOrdServ:oOrdEndDes:GetEnder(),"2"/*cGravaWms*/,Nil,aCpoAuxUsr))
			// Reserva SB2
			lRet := WmsEmpB2B8(.T./*lReserva*/,oOrdServ:GetQuant(),oOrdServ:oProdLote:GetProduto(),oOrdServ:oOrdEndOri:GetArmazem(),oOrdServ:oProdLote:GetLoteCtl(),oOrdServ:oProdLote:GetNumLote(),lEmpSB8)
		EndIf
	EndIf

Return lRet

//-----------------------------------------------------------------------------
Static Function ValIntMov1(cRotina)
//-----------------------------------------------------------------------------
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local oEndereco := Nil
Local aBoxDC8   := {}

	If !Empty(M->D3_SERVIC) .And. M->D3_QUANT > 0
		lRet := WmsVldSrv('6',M->D3_SERVIC,,,,,,M->D3_TM)
		//-- Valida o Preenchimento do campo DOCUMENTO
		If lRet .And. Empty(M->D3_DOC)
			WmsMessage(STR0015,WMSXFUNG08,,,,STR0016) // Não foi informado o campo documento.##O campo "DOCUMENTO" deve ser preenchido sempre que um movimento interno gerar serviço de WMS.
			lRet := .F.
		EndIf
	ElseIf !Empty(M->D3_SERVIC) .And. M->D3_QUANT == 0
		WmsMessage(STR0017,WMSXFUNG09,,,,STR0018) // "Serviço não pode ser informado para ajuste de custo!"##"Apague o serviço WMS informado!"
		lRet := .F.
	ElseIf lWmsNew .And. Empty(M->D3_SERVIC) .And. M->D3_QUANT > 0
		WmsMessage(STR0019,WMSXFUNG10,,,,STR0020) // Serviço WMS não informado! // Informe um serviço WMS válido.
		lRet := .F.
	EndIf
	// Valida se o armazém é unitizado e o endereço é de estrutura que controla unitizador
	If lRet .And. lWmsNew .And. !Empty(M->D3_LOCALIZ) .And. WmsArmUnit(M->D3_LOCAL)
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(M->D3_LOCAL)
		oEndereco:SetEnder(M->D3_LOCALIZ)
		If oEndereco:LoadData()
			If (oEndereco:GetTipoEst() != 2 .And. oEndereco:GetTipoEst() != 5)
				aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
				WmsMessage(WmsFmtMsg(STR0025,{{"[VAR01]",aBoxDC8[oEndereco:GetTipoEst()]}}),WMSXFUNG11,1,,,WmsFmtMsg(STR0026,{{"[VAR01]",aBoxDC8[2]},{"[VAR02]",aBoxDC8[5]}})) // Não é permitido informar o endereço origem com estrutura física [VAR01], quando o armazém controla unitizador (D3_LOCALIZ). // Informe um endereço do tipo [picking] ou [doca].
				lRet := .F.
			EndIf
		EndIf
		oEndereco:Destroy()
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function ValIntMov2(cRotina)
//-----------------------------------------------------------------------------
Local lRet      := .T.
Local lWmsNew   := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lWmsBxOp  := SuperGetMV("MV_WMSBXOP",.F.,.F.)
Local cServico  := GdFieldGet('D3_SERVIC',n)
Local cArmazem  := GdFieldGet('D3_LOCAL',n)
Local cEndereco := GdFieldGet('D3_LOCALIZ',n)
Local nQtde     := GdFieldGet('D3_QUANT',n)
Local cDocOp    := GdFieldGet('D3_OP',n)
Local cProd     := GdFieldGet('D3_COD',n)
Local cLocTM    := IIF(Type("cTM") == "C" , cTM, "999") 

	If !Empty(cServico) .And. nQtde > 0
		lRet := WmsVldSrv('6',cServico,,,,,,cTm) // cTm - Private
	ElseIf !Empty(cServico) .And. nQtde == 0
		WmsMessage(STR0017,WMSXFUNG12,,,,STR0018) // "Serviço não pode ser informado para ajuste de custo!"##"Apague o serviço WMS informado!"
		lRet := .F.
	ElseIf (lWmsNew .And. !lWmsBxOp .And. Empty(cServico) .And. nQtde > 0) ;
           .Or. (lWmsNew .And. lWmsBxOp .And. Empty(cServico) .And. FwIsInCallStack("MATA241") .And. Empty(cDocOp) .And. nQtde > 0);
           .Or. (lWmsNew .And. lWmsBxOp .And. Empty(cServico) .And. FwIsInCallStack("MATA241") .And. cLocTM <= "500" .And. nQtde > 0)
        WmsMessage(STR0019,WMSXFUNG13,,,,STR0020) // "Serviço WMS não informado!"##"Informe um serviço WMS válido."
        lRet := .F.
	ElseIf lWmsNew .And. lWmsBxOp .And. !Empty(cDocOp) .And. Empty(cServico) .And. FwIsInCallStack("MATA241") .And. !WMS241VPro(cArmazem,cDocOp,cProd)
		WmsMessage(WmsFmtMsg(STR0032,{{"[VAR01]",cProd}}),WMSXFUNG29,5,.T.) //"O produto [VAR01] não faz parte da OP. Informe um serviço WMS."
		lRet := .F.
	ElseIf lWmsNew .And. lWmsBxOp .And. !Empty(cDocOp) .And. Empty(cServico) .And. FwIsInCallStack("MATA241") .And. !WMS241VEnd(cArmazem,cEndereco)
		WmsMessage(WmsFmtMsg(STR0033,{{"[VAR01]",cEndereco}}),WMSXFUNG30,5,.T.) //"Tipo de estrutura do endereço [VAR01] inválida. Para baixa de estoque de ordem de produção informe um endereço com tipo de estrutura 'Produção'."
		lRet := .F.
	ElseIf lWmsNew .And. lWmsBxOp .And. !Empty(cDocOp) .And. Empty(cServico) .And. nQtde > 0 .And. FwIsInCallStack("MATA241") 
		lRet := WMS241VFJ(cProd,cDocOp,cArmazem)
	EndIf
	If lRet .And. lWmsNew .And. !Empty(cDocOp) .And. !Empty(cServico) .And. FwIsInCallStack("MATA241") .And. !WMS241VEmp(cLocTM,cDocOp,cProd,cArmazem,cEndereco)
		WmsMessage(WmsFmtMsg(STR0034,{{"[VAR01]",cLocTM}}),WMSXFUNG32,5,.T.) //"Verifique se a TM ([VAR01]) atualiza empenho ou se a ordem de produção está empenhada."
		lRet := .F.
	EndIf
	// Valida se o armazém é unitizado e o endereço é de estrutura que controla unitizador
	If lRet .And. lWmsNew .And. !Empty(cEndereco) .And. WmsArmUnit(cArmazem)
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(cArmazem)
		oEndereco:SetEnder(cEndereco)
		If oEndereco:LoadData()
			If (oEndereco:GetTipoEst() != 2 .And. oEndereco:GetTipoEst() != 5)
				aBoxDC8 := StrTokArr(Posicione("SX3",2,"DC8_TPESTR",'X3CBox()'),';')
				WmsMessage(WmsFmtMsg(STR0025,{{"[VAR01]",aBoxDC8[oEndereco:GetTipoEst()]}}),WMSXFUNG14,1,,,WmsFmtMsg(STR0026,{{"[VAR01]",aBoxDC8[2]},{"[VAR02]",aBoxDC8[5]}})) // Não é permitido informar o endereço origem com estrutura física [VAR01], quando o armazém controla unitizador (D3_LOCALIZ). // Informe um endereço do tipo [picking] ou [doca].
				lRet := .F.
			EndIf
		EndIf
		oEndereco:Destroy()
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function ValEstMov(cRotina)
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lEstWms    := If(Type('lExecWms')=='L', lExecWms, .F.)
Local oDmdUniDel := Nil
Local oOrdSerDel := Nil
Local cMessage   := ""
Local aMessage   := {}

	If !lWmsNew
		If WmsChkDCF('SD3',,,SD3->D3_SERVIC,'3',,SD3->D3_DOC,,,,SD3->D3_LOCAL,SD3->D3_COD,,,SD3->D3_NUMSEQ)
			lRet := WmsAvalDCF('2')
		EndIf
	ElseIf !lEstWms
		If !Empty(SD3->D3_IDDCF)
			If SD3->D3_TM <= "500" .And. WmsArmUnit(SD3->D3_LOCAL)  //Verifica se deve unitizar o produto
				oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
				oDmdUniDel:SetIdD0Q(SD3->D3_IDDCF)
				If oDmdUniDel:LoadData()
					If !oDmdUniDel:CanDelete()
						cMessage := STR0021+" - DU "+LTrim(oDmdUniDel:GetDocto())+" - ID "+oDmdUniDel:GetIdD0Q()+CRLF // Movimentação integrada ao SIGAWMS
						aMessage := StrTokArr2(oDmdUniDel:GetErro(),CRLF)
						AEval(aMessage, {|x| cMessage := cMessage + x + " "}, 1,Len(aMessage)-1)
						WmsHelp(cMessage,aMessage[Len(aMessage)],WMSXFUNG01)
						lRet := .F.
					EndIf
				EndIf
			Else
				oOrdSerDel := WMSDTCOrdemServicoDelete():New()
				oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
				If oOrdSerDel:LoadData()
					If !oOrdSerDel:CanDelete()
						cMessage := STR0021+" - OS "+LTrim(oOrdSerDel:GetDocto())+" - ID "+oOrdSerDel:GetIdDCF()+CRLF // Movimentação integrada ao SIGAWMS
						aMessage := StrTokArr2(oOrdSerDel:GetErro(),CRLF)
						AEval(aMessage, {|x| cMessage := cMessage + x + " "}, 1,Len(aMessage)-1)
						WmsHelp(cMessage,aMessage[Len(aMessage)],WMSXFUNG02)
						lRet := .F.
					EndIf
				EndIf
			EndIf
			// Valida se a quantidade saldo do produto não ficará menor que a quantidade reservada
			If lRet .And. SD3->D3_TM <= "500" .And. SD3->D3_QUANT > 0
				// Geração da reserva SB2
				dbSelectArea("SB2")
				SB2->(dbSetOrder(1)) // B2_FILIAL+B2_COD+B2_LOCAL
				If SB2->(dbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)) .And. SB2->B2_RESERVA > 0 .And. SaldoSB2() < 0
					WmsHelp(WmsFmtMsg(STR0029,{{"[VAR01]",AllTrim(SD3->D3_LOCAL)},{"[VAR02]",AllTrim(SD3->D3_COD)}}),,WMSXFUNG15) // Há reservas no armazém [VAR01] e produto [VAR02] que comprometem o saldo, estorno não permitido!
					lRet := .F.
				ElseIf Rastro(SD3->D3_COD)
					// Geração da reserva SB2
					dbSelectArea("SB8")
					SB8->(dbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
					If SB8->(dbSeek(xFilial("SB8")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_LOTECTL+SD3->D3_NUMLOTE)) .And. SB8->B8_EMPENHO > 0 .And. SB8SALDO() < 0
						cMessage := WmsFmtMsg(STR0027,{{"[VAR01]",AllTrim(SD3->D3_LOCAL)},{"[VAR02]",AllTrim(SD3->D3_COD)},{"[VAR03]",AllTrim(SD3->D3_LOTECTL)}}) // Há reservas no armazém [VAR01] e produto [VAR02] do lote [VAR02] que comprometem o saldo, estorno não permitido!
						If !Empty(SD3->D3_NUMLOTE)
							cMessage := WmsFmtMsg(STR0028,{{"[VAR01]",AllTrim(SD3->D3_LOCAL)},{"[VAR02]",AllTrim(SD3->D3_COD)},{"[VAR03]",AllTrim(SD3->D3_LOTECTL)},{"[VAR04]",AllTrim(SD3->D3_NUMLOTE)}}) // Há reservas no armazém [VAR01] e produto [VAR02] do lote [VAR02] e sublote [VAR01] que comprometem o saldo, estorno não permitido!
						EndIf
						WmsHelp(cMessage ,,WMSXFUNG16)
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
		If lRet .And. !Empty(SD3->D3_IDENT) .And. (Left(SD3->D3_DOC,3) $ "CEX|CFT")
			If Left(SD3->D3_DOC,3) == "CEX"
				cMessage := STR0022+SD3->D3_IDENT // "Movimentação automática gerada pelo SIGAWMS para registro de excesso na conferência do recebimento: "
			Else
				cMessage := STR0023+SD3->D3_IDENT // "Movimentação automática gerada pelo SIGAWMS para registro de falta na conferência do recebimento: "
			EndIf
			WmsHelp(cMessage,STR0024,WMSXFUNG07) // "Para estorno desta movimentação deverá ser reaberto o processo de conferência no WMS."
			lRet := .F.
		EndIf
	EndIf
Return lRet

//-----------------------------------------------------------------------------
Static Function IntMovInt(cRotina,cEndereco)
//-----------------------------------------------------------------------------
Local lRet     := .T.
Local lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local nPosDCF  := 0
Local aLibDCF  := WmsLibDCF() // Busca referencia do array WMS
Local oOrdServ := WmsOrdSer() // Busca referencia do objeto WMS
Local oDmdUnit := Nil

    If SD3->D3_QUANT > 0 
        If !lWmsNew
            WmsCriaDCF("SD3",,,,@nPosDCF)
            //-- Verifica se a execucao do servico de wms sera automatica
            If Empty(nPosDCF)
                lRet := .F.
            ElseIf WmsVldSrv('4',SD3->D3_SERVIC)
                AAdd(aLibDCF,nPosDCF)
            EndIf
        Else
            // Se o armazém destino é unitizado, deve gerar uma demanda de unitização
            If WmsArmUnit(SD3->D3_LOCAL)
                oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
                oDmdUnit:SetOrigem('SD3')
                oDmdUnit:SetDocto(SD3->D3_DOC)
                oDmdUnit:SetNumSeq(SD3->D3_NUMSEQ)
                oDmdUnit:SetServico(SD3->D3_SERVIC)
                // Dados endereço origem
                oDmdUnit:oDmdEndOri:SetArmazem(SD3->D3_LOCAL)
                oDmdUnit:oDmdEndOri:SetEnder(cEndereco)
                // Dados endereço destino
                oDmdUnit:oDmdEndDes:SetArmazem(SD3->D3_LOCAL)
                oDmdUnit:oDmdEndDes:SetEnder(SD3->D3_LOCALIZ)
                // Gera a demanda de unitização gerando a entrada com base nos endereços escolhidos
                If !(lRet := oDmdUnit:CreateD0Q())
                    WmsMessage(oDmdUnit:GetErro(),WMSXFUNG03,1)
                EndIf
            // Senão simplesmente gera uma ordem de serviço para a quantidade da SD3
            Else
                //-- Somente cria a ordem de serviço na primeira vez
                If oOrdServ == Nil
                    oOrdServ := WMSDTCOrdemServicoCreate():New()
                    WmsOrdSer(oOrdServ) // Atualiza referencia do objeto WMS
                EndIf
                oOrdServ:SetOrigem('SD3')
                oOrdServ:SetDocto(SD3->D3_DOC)
                oOrdServ:SetNumSeq(SD3->D3_NUMSEQ)
                oOrdServ:SetServico(SD3->D3_SERVIC)
                // Dados endereço origem
                oOrdServ:oOrdEndOri:SetArmazem(SD3->D3_LOCAL)
                oOrdServ:oOrdEndOri:SetEnder(cEndereco)
                // Dados endereço destino
                oOrdServ:oOrdEndDes:SetArmazem(SD3->D3_LOCAL)
                oOrdServ:oOrdEndDes:SetEnder(SD3->D3_LOCALIZ)
                // Gera a ordem de serviço gerando a entrada com base nos endereços escolhidos
                If !(lRet := oOrdServ:CreateDCF())
                    WmsMessage(oOrdServ:GetErro(),WMSXFUNG04,1)
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

//-----------------------------------------------------------------------------
Static Function EstMovInt()
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMV("MV_WMSNEW",.F.,.F.)
Local lEstWms    := If(Type('lExecWms')=='L', lExecWms, .F.)
Local oDmdUniDel := Nil
Local oOrdSerDel := Nil

	If !lWmsNew
		WmsDelDCF('1','SD3')
	ElseIf !lEstWms
		// Quando é estorno, está posicionado no registro do estorno gerado
		// Estorno de TM <= 500 -> 999 | TM > 500 -> 499 - Fixo
		If SD3->D3_TM == "999" .And. WmsArmUnit(SD3->D3_LOCAL)  //Verifica se deve unitizar o produto
			oDmdUniDel := WMSDTCDemandaUnitizacaoDelete():New()
			oDmdUniDel:SetIdD0Q(SD3->D3_IDDCF)
			If oDmdUniDel:LoadData()
				If !(lRet := oDmdUniDel:DeleteD0Q())
					WmsMessage(oDmdUniDel:GetErro(),WMSXFUNG05,1)
				EndIf
			EndIf
		Else
			oOrdSerDel := WMSDTCOrdemServicoDelete():New()
			oOrdSerDel:SetIdDCF(SD3->D3_IDDCF)
			If oOrdSerDel:LoadData()
				If !(lRet := oOrdSerDel:DeleteDCF())
					WmsMessage(oOrdSerDel:GetErro(),WMSXFUNG06,1)
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
/*
@description: Retorna serviço e endereço de entrada de produção
A tabela D1A é a tabela de complemento de produto para WMS. Foi criada pois a tabela SB1 já possui 255 campos,
que é a limitação do GCAD.
@type function
@author Wander Horongoso
@since 29/12/2019
@param
cProduto: código do produto
cServProd: ponteiro com a variável que receberá o código do serviço de produção
cEndProd: ponteiro com a variável que receberá o código do endereço de produção
*/
Function WmsSerEndPr(cProduto,cServProd,cEndProd)
Local cAliasAnt := GetArea()
Local cAliasD1A := ""

	If TableInDic("D1A")
		dbSelectArea("D1A") //usado para criar a tabela enquanto não houver cadastro. 

		cAliasD1A := GetNextAlias()
		BeginSql Alias cAliasD1A
			SELECT D1A.D1A_SEREPR,
				D1A.D1A_ENDEPR
			FROM %Table:D1A% D1A
			WHERE D1A.D1A_FILIAL = %xFilial:D1A%
			AND D1A.D1A_COD = %Exp:cProduto%
			AND D1A.%NotDel%
		EndSql
		If (cAliasD1A)->(!EoF())
			cServProd := (cAliasD1A)->D1A_SEREPR 
			cEndProd := (cAliasD1A)->D1A_ENDEPR
		Else
			cServProd := Replicate(' ', TamSX3('D3_SERVIC')[1])
			cEndProd := Replicate(' ', TamSX3('D3_LOCALIZ')[1])	
		EndIf
		(cAliasD1A)->(DbCloseArea())
	EndIf
	
	RestArea(cAliasAnt)
Return

//Rotina chamada do apontamento de produção simples ACDV020, para preenchimento
Function WmsAcdv020(aSD3,cProduto)
Local cEndProd := ""
Local cServPod := ""	 

	//Busca serviço e endereço de entrada de produção
	WmsSerEndPr(cProduto,@cServPod,@cEndProd)

	If !Empty(cEndProd) .And. (aScan(aSD3,{|x| x[1] == "D3_LOCALIZ"}) == 0)
		aadd(aSD3,{"D3_LOCALIZ",cEndProd,nil})
	EndIf

	If !Empty(cServPod) .And. (aScan(aSD3,{|x| x[1] == "D3_SERVIC"}) == 0)
		aadd(aSD3,{"D3_SERVIC",cServPod,nil})
	EndIf

	//Comando obrigatório para o execauto do mata250
	aadd(aSD3,{"D3_NUMSERI","",nil})
Return

/*Rotina chamada no MATA240, ao estornar um serviço criado a partir da geração da baixa de pré-requisição (MATA185).
Diferentemente do Materiais, que gera um novo documento a cada baixa, o WMS mantém o mesmo número de documento.
Com isso, no caso de executar o serviço, estornar, executar e estornar novamente, é necessário selecionar o registro
da SD3 que ainda não foi estornado. Antes dessa implementação o sistema selecionava sempre o primeiro, já estornado.
@autor: Wander Horongoso
@data: 22/05/2020
@param: 
*/
Function WmsRecNoD3(aCampos)
Local nInd := 0
Local nRet := 0

	For nInd := 1 To Len(aCampos)
		If aCampos[nInd,1] == 'WMS_R_E_C_N_O_'
			nRet := aCampos[nInd,2]
			Exit
		EndIf
	Next nInd

Return nRet

/*Rotina chamada no MATA185, ao estornar uma baixa de pré-requisição.
Objetivo é obter um array com informações a partir da DH1 (tabela auxiliar com as informações da SD3)
em substituição à leitura da SD3 existente no MATA185.
@autor: Wander Horongoso
@data: 27/05/2020
@param: 
*/
Function Wms185EstA(cProd, cNumReq, cSCQRecNo, dDataFec)
Local cAliasDH1 := GetNextAlias()
Local aBaixas   := {}

	BeginSql Alias cAliasDH1
	  	SELECT DH1.DH1_EMISAO, DH1.DH1_QUANT, DH1.R_E_C_N_O_
	   	FROM %Table:DH1% DH1
	   	WHERE DH1.DH1_FILIAL = %xFilial:DH1%
		AND DH1.DH1_PRODUT = %Exp:cProd%
		AND DH1.DH1_NUMSEQ = %Exp:cNumReq%
		AND DH1.%NotDel%
	EndSql
	Do While !(cAliasDH1)->(Eof())
	  	If dDataFec < sToD((cAliasDH1)->DH1_EMISAO)
	   		aAdd(aBaixas,{.T.,(cAliasDH1)->DH1_EMISAO,Transform((cAliasDH1)->DH1_QUANT,PesqPict("DH1","DH1_QUANT",14)),(cAliasDH1)->R_E_C_N_O_,SCQ->(Recno())})
	   	EndIf
	   	(cAliasDH1)->(dbSkip())
	EndDo
	(cAliasDH1)->(dbCloseArea())

Return aBaixas

/*Rotina chamada no MATA185, ao estornar uma baixa de pré-requisição.
Objetivo é obter informações a partir da DH1 (tabela auxiliar com as informações da SD3)
em substituição à leitura da SD3 existente no MATA185.
@autor: Wander Horongoso
@data: 27/05/2020
@param: 
*/
Function Wms185EstB(nRecNo)
Local aRet := {}

	dbSelectArea("DH1")
	dbGoTo(nRecNo)
	Aadd(aRet,DH1->DH1_QUANT)
	Aadd(aRet,DH1->DH1_PROJPM)
	Aadd(aRet,DH1->DH1_TASKPM)

Return aRet

/*Rotina chamada no MATA185, ao estornar uma baixa de pré-requisição.
Objetivo é excluir a ordem de serviço gerada na baixa.
@autor: Wander Horongoso
@data: 27/05/2020
@param: 
*/
Function Wms185EstC(nRecNo)
Local oOrdServ := nil
Local lRet := .T.

	dbSelectArea('DCF')
	DCF->(dbSetOrder(9))
	If DCF->(dbSeek(xFilial('DCF')+DH1->DH1_IDDCF))
		Begin Transaction
			WmsDCFdDH1(DCF->DCF_ID)//Deleta DH1
			oOrdServ := WMSDTCOrdemServicoDelete():New()
			If oOrdServ:GoToDCF(DCF->(Recno()))
				If oOrdServ:CanDelete()
					oOrdServ:DeleteDCF()
				Else
					lRet := .F.
					oOrdServ:ShowWarnig()
					FwFreeObj(oOrdServ)
					DisarmTransaction()
				EndIf
			EndIf
		End Transaction
	EndIf

Return lRet

//-----------------------------------------------------------------------------
/*Rotina chamada no MATA240, ao estornar um lançamento de inventário.
Objetivo é estornar o lançamento de ajuste de inventário nas tabelas D14, D13 quando WMS novo
@autor: Roselaine Adriano
@data: 07/05/2021

*/
Static Function EstMovInv()
//-----------------------------------------------------------------------------
Local lRet       := .T.
Local lWmsNew    := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local oProduto   := IIf(lWmsNew,WMSDTCProdutoDadosAdicionais():New(),Nil)
Local oEstEnder  := IIf(lWmsNew,WMSDTCEstoqueEndereco():New(),Nil)
Local oMovEstEnd := IIf(lWmsNew,WMSDTCMovimentosEstoqueEndereco():New(),Nil)
Local aProduto   := {}
Local nProduto   := NIL

	If lWmsNew
		oProduto:SetProduto(SD3->D3_COD)
        If oProduto:LoadData()
            // Carrega estrutura do produto x componente
            aProduto := oProduto:GetArrProd()                    
            If Len(aProduto) > 0
                For nProduto := 1 To Len(aProduto)
                    // Carrega dados para Estoque por Endereço
                    oEstEnder:oEndereco:SetArmazem(SD3->D3_LOCAL)
                    oEstEnder:oEndereco:SetEnder(SD3->D3_LOCALIZ)
                    // Carrega dados produto
                    oEstEnder:oProdLote:SetArmazem(SD3->D3_LOCAL)
                    oEstEnder:oProdLote:SetPrdOri(SD3->D3_COD)                 // Produto Origem
                    oEstEnder:oProdLote:SetProduto(aProduto[nProduto][1] ) // Componente
                    oEstEnder:oProdLote:SetLoteCtl(SD3->D3_LOTECTL)               // Lote do produto principal que deverá ser o mesmo no componentes
                    oEstEnder:oProdLote:SetNumLote(SD3->D3_NUMLOTE)               // Sub-Lote do produto principal que deverá ser o mesmo no componentes
                    oEstEnder:oProdLote:SetNumSer(SD3->D3_NUMSERI)                 // Numero de serie
                    oEstEnder:LoadData()
                    oEstEnder:SetQuant(QtdComp(SD3->D3_QUANT * aProduto[nProduto][2]) )
                    // Realiza Entrada Armazem Estoque por Endereço
                    // Seta o bloco de código para informações do documento
					oEstEnder:SetBlkDoc({|oMovEstEnd|;
										oMovEstEnd:SetOrigem("SB7"),;
										oMovEstEnd:SetDocto(SD3->D3_DOC),;
										oMovEstEnd:SetNumSeq(SD3->D3_NUMSEQ);
					})
					// Seta o bloco de código para informações do movimento para o Kardex
    				oEstEnder:SetBlkMov({|oMovEstEnd|;
        							oMovEstEnd:SetIdUnit(oEstEnder:cIdUnitiz);
    				})
					lRet := oEstEnder:UpdSaldo(SD3->D3_TM,.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F. /*lEmpPrev*/,.T., /*lMovEstEnd*/)
					If !lRet
					   Exit
					EndIf 
				Next
            EndIf
        EndIf    
	EndIf
Return lRet

/*/{Protheus.doc} WMS241VPro
	(Valida se produto posicionado na SD3 do MATA241 faz parte da OP informada)
	@type  Function
	@author equipe wms
	@since 17/11/2023
	@version 1.0
	@return lRet, boolean, produto faz parte da OP?
	/*/
Function WMS241VPro(cArmazem,cDocOp,cProd)
	Local lRet      := .F.
	Local aArea     := GetArea()

	SD4->(DbSetOrder(2))
	If SD4->(DbSeek(FWxFilial("SD4")+cDocOp+cProd+cArmazem))
		lRet := .T.
	EndIf
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} WMS241VEnd
	(Valida se endereco na posicionado na SD3 do MATA241 é do tipo producao)
	@type  Function
	@author equipe wms
	@since 24/11/2023
	@version 1.0
	@return lRet, boolean, produto faz parte da OP?
	/*/
Function WMS241VEnd(cArmazem,cEnd)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local oEndereco := WMSDTCEndereco():New()

	oEndereco:SetArmazem(cArmazem)
	oEndereco:SetEnder(cEnd)
	If oEndereco:LoadData() 
		If oEndereco:GetTipoEst() <> 7 
			lRet := .F.
		EndIf
	EndIf
	oEndereco:Destroy()
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} WMS241VEmp
	(Bloqueio para baixa de OP com WMS e OP empenhada)
	@type  Function
	@author equipe wms
	@since 30/11/2023
	@version 1.0
	@return lRet, .F. Não permite baixar
	/*/
Function WMS241VEmp(cTm,cDocOp,cProd,cArmazem,cEnd)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local cLoteCtl := GdFieldGet('D3_LOTECTL',n)
	Local cNumLote := GdFieldGet('D3_NUMLOTE',n)
	Local cAliasNew := Nil
	Local cQuery := ""

	If !EMPTY( cTm )
		If SF5->(dbSeek(xFilial("SF5")+cTm))
			If SF5->F5_ATUEMP == "S" .And. cTm > '500'
				cAliasNew := GetNextAlias()
				cQuery := " SELECT Distinct 1"
				cQuery += 	" FROM "+RetSqlName('SD4')+" SD4"
				cQuery +=		" INNER JOIN "+RetSqlName('SDC')+" SDC ON (SDC.D_E_L_E_T_ = ' '"
				cQuery +=			" AND SDC.DC_FILIAL = '"+xFilial("SDC")+"'" 
				cQuery +=			" AND SDC.DC_PRODUTO = SD4.D4_COD"
				cQuery +=			" AND SDC.DC_LOCAL = SD4.D4_LOCAL"
				cQuery +=			" AND SDC.DC_OP = SD4.D4_OP"
				cQuery +=			" AND SDC.DC_TRT = SD4.D4_TRT"
				cQuery +=			" AND SDC.DC_IDDCF = SD4.D4_IDDCF"
				cQuery +=			" AND SDC.DC_QUANT > 0 ) "
				cQuery +=			" WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'" 
				cQuery +=			" AND SD4.D4_OP = '"+cDocOp+"'"
				cQuery +=			" AND SD4.D4_COD = '"+cProd+"'"
				cQuery +=			" AND SD4.D4_LOCAL = '"+cArmazem+"'"
				
				If Rastro(cProd,"L")
					cQuery +=	" AND SD4.D4_LOTECTL = '"+cLoteCtl+"'"
				EndIf
				If Rastro(cProd,"S")
					cQuery +=	" AND SD4.D4_NUMLOTE = '"+cNumLote+"'"
				EndIf
				cQuery +=			" AND SD4.D_E_L_E_T_ = ' '
				
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
				If (cAliasNew)->(!Eof())
					lRet := .F.
				EndIf
				(cAliasNew)->(DbCloseArea())

			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} WMS241VFJ
	(Validação para item empenhado somente na OP)
	Quando o lote foi informado no mata650 e não processo o WMSA505 é necessario obrigar para o apontamento no MATA241.
	@type  Function
	@author equipe wms
	@since 07/12/2023
	@version 1.0
	@return lRet, .F. Não permite baixar
	/*/
Function WMS241VFJ(cProd,cDocOp,cArmazem)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local cLoteCtl  := GdFieldGet('D3_LOTECTL',n)
	Local cNumLote  := GdFieldGet('D3_NUMLOTE',n)
	Local cTRT      := GdFieldGet('D3_TRT',n)
	Local cAliasQry := Nil
	Local lCriaSDC := .T.
	Local nQtdSDC := 0
	Local lBlqExec := .T.

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DC_QUANT
		FROM %Table:SDC% SDC
		WHERE SDC.DC_FILIAL =  %xFilial:SDC%
		AND SDC.DC_PRODUTO = %Exp:cProd%
		AND SDC.DC_LOCAL = %Exp:cArmazem%
		AND SDC.DC_OP = %Exp:cDocOp%
		AND SDC.DC_TRT = %Exp:cTRT%
		AND SDC.DC_LOTECTL = %Exp:cLoteCtl%
		AND SDC.DC_NUMLOTE = %Exp:cNumLote%
		AND SDC.%NotDel%
	EndSql
	If (cAliasQry)->(!Eof())
		lCriaSDC := .F.
		nQtdSDC  := (cAliasQry)->DC_QUANT
	EndIf
	(cAliasQry)->(DbCloseArea())

	SD4->(dbSetOrder(1))
	If SD4->(dbSeek(xFilial("SD4")+cProd+cDocOp+cTRT+cLoteCtl+cNumLote))
		If SD4->D4_QUANT > 0 .And. nQtdSDC > 0
			lBlqExec := .F.
		EndIf
	ElseIf Rastro(cProd,"L") //Se não encontrou SD4 e controla lote é pq nao foi empenhado MATA650 e WMSA505
		If SD4->(dbSeek(xFilial("SD4")+cProd+cDocOp))
			lBlqExec := .F.
		EndIf
	EndIf

	If lCriaSDC .AND. Rastro(cProd,"L") .AND. !Empty(cLoteCtl) .AND. lBlqExec
		WmsMessage(WmsFmtMsg(STR0035,{{"[VAR01]",cProd}}),WMSXFUNG31,5,.T.) //"Componente : [VAR01], com controle de lote e endereço, porém somente o saldo por lote foi empenhado. Para efetuar o apontamento é necessário efetivar o processo de empenho de requisição no SIGAWMS." 	
		lRet := .F. 
	EndIf
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} WmsMvItDes
	(Função para inclusão de saldo de produto filho na movimentação de desmontagem)
	@type  Function
	@author equipe wms
	@since 24/11/2023
	@version 1.0
	@Param
	lAcao: 1 - Inclusão da desmontagem
	       2 - Estorno
	cLocal: Local de estoque
	cEndereco: Endereço  
	cProduto: Produto WMS que está sendo criado saldo na desmontagem
	cLotectl: Lote 
	cNumlote: Sublote
	nQuant : Quantidade
	nQtSegUM: Quantidade na segunda unidade de medida
	cDocumento: cDocumento
	cNumseq: Numero sequencia SD3 origem movimento.
	@return lRet, boolean
	/*/
Function WmsMvItDes(cAcao,cLocal,cEndereco,cProduto,cLoteCtl,cNumLote,cNumser,nQuant,nQtSegUM,cDocumento,cNumseq)
	Local aArea     := GetArea()
	Local oEstEnder  := WMSDTCEstoqueEndereco():New()
	Local oMovEstEnd:= WMSDTCMovimentosEstoqueEndereco():New()
   
	If cAcao = '1' //inclusão
    	oEstEnder:oEndereco:SetArmazem(cLocal)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oProdLote:SetArmazem(cLocal) // Armazem
		oEstEnder:oProdLote:SetPrdOri(cProduto)   // Produto Origem
		oEstEnder:oProdLote:SetProduto(cProduto) // Componente
		oEstEnder:oProdLote:SetLoteCtl(cLoteCtl) // Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumLote(cNumLote) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumSer(cNumSer)   // Numero de serie
		oEstEnder:LoadData()
		oEstEnder:SetQuant(nQuant)
		// Seta o bloco de código para informações do documento para o Kardex
		oEstEnder:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SD3"),;
					oMovEstEnd:SetDocto(cDocumento),;
					oMovEstEnd:SetNumSeq(cNumseq),;
				})
		// Realiza Entrada Armazem Estoque por Endereço
		oEstEnder:UpdSaldo('499',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)
	Else //cAcao = 2 Estorno desmontagem
		oEstEnder:oEndereco:SetArmazem(cLocal)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oProdLote:SetArmazem(cLocal) // Armazem
		oEstEnder:oProdLote:SetPrdOri(cProduto)   // Produto Origem
		oEstEnder:oProdLote:SetProduto(cProduto) // Componente
		oEstEnder:oProdLote:SetLoteCtl(cLoteCtl) // Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumLote(cNumlote) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		oEstEnder:oProdLote:SetNumSer(cNumser)   // Numero de serie
		oEstEnder:LoadData()
		oEstEnder:SetQuant(nQuant)
		// Seta o bloco de código para informações do documento para o Kardex
		oEstEnder:SetBlkDoc({|oMovEstEnd|;
					oMovEstEnd:SetOrigem("SD3"),;
					oMovEstEnd:SetDocto(cDocumento),;
					oMovEstEnd:SetNumSeq(cNumseq),;
				})
		// Realiza Entrada Armazem Estoque por Endereço
		oEstEnder:UpdSaldo('999',.T. /*lEstoque*/,.F. /*lEntPrev*/,.F. /*lSaiPrev*/,.F. /*lEmpenho*/,.F. /*lBloqueio*/,.F./*lEmpPrev*/,.T./*lMovEstEnd*/)

		// Verifica os movimentos da ordem de serviço origem para desconsiderar
		// no cálculo de estoque 
		WmsX312118("D13","D13_USACAL")
		cAliasD13 := GetNextAlias()
		BeginSql Alias cAliasD13
			SELECT D13.R_E_C_N_O_ RECNOD13
			FROM %Table:D13% D13
			WHERE D13.D13_FILIAL = %xFilial:D13%
			AND D13.D13_DOC = %Exp:cDocumento%
			AND D13.D13_NUMSEQ =  %Exp:cNumseq%
			AND D13.D13_ORIGEM = 'SD3'
			AND D13.D13_USACAL <> '2'
			AND D13.%NotDel%
		EndSql
		While (cAliasD13)->(!Eof())
			D13->(dbGoTo((cAliasD13)->RECNOD13))
			If RecLock("D13",.F.)
				D13->D13_USACAL := '2'
				D13->(MsUnLock())
			Endif
			(cAliasD13)->(dbSkip())
		EndDo
		(cAliasD13)->(dbCloseArea())
	EndIf	
	RestArea(aArea)
Return

/*/{Protheus.doc} WmsVlDesm
	(Função para validações WMS para desmontagem/estorno através da rotina MATA242)
	@type  Function
	@author equipe wms
	@since 24/11/2023
	@version 1.0
	@Param
	lAcao: 1 - Validação no momento da inclusão da desmontagem
	       2 - Validação no momento do estorno
	cLocal: Local de estoque
	cEndereco: Endereço  
	cProduto: Produto WMS que está sendo criado saldo na desmontagem
	cLotectl: Lote 
	cNumlote: Sublote
	nQuant : Quantidade
	cServico: Campo de serviço da tela para que ocorra validação 
	@return lRet
	/*/
Function WmsVlDesm(lAcao,cLocal,cEndereco,cProduto,cLoteCtl,cNumLote,nQuant,cServico)
	Local lRet      := .T.
	Local aArea     := GetArea()
	Local oEstEnder := Nil
	Local oEndereco := Nil 
	Local oSeqAbast := Nil 
	Local nSldEnd := 0
	
	If lAcao = '1' //Inclusão de desmontagem
		oEndereco := WMSDTCEndereco():New()
		oEndereco:SetArmazem(cLocal)
		oEndereco:SetEnder(cEndereco)
		If !oEndereco:LoadData()
			WmsMessage(WmsFmtMsg(STR0036 + oEndereco:GetErro() ,{{"[VAR01]",cEndereco},{"[VAR02]",cLocal}}),WMSXFUNG33,5,,,) //"Endereço [VAR01] não cadastrado para o armazém [VAR02]. Verifique o cadastro de endereços (SBE)."
			lRet := .F. 
		EndIf
		oEstEnder := WMSDTCEstoqueEndereco():New()
		oEstEnder:ClearData()
		oEstEnder:oProdLote:SetArmazem(cLocal)
		oEstEnder:oProdLote:SetPrdOri(cProduto)
		oEstEnder:oProdLote:SetProduto(cProduto)
		oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)
		oEstEnder:oProdLote:SetNumLote(cNumLote)
		oEstEnder:oProdLote:LoadData()
		oEstEnder:oProdLote:oProduto:LoadData()
		If lRet .AND. oEstEnder:oProdLote:oProduto:oProdComp:IsDad()
			WmsMessage(WmsFmtMsg(STR0037 ,{{"[VAR01]",cProduto}}),WMSXFUNG34,5,,,) //"Produto com controle WMS [VAR01], possui estrutura de armazenamento. Operação não permitida!"
			lRet := .F.
		EndIf
		If lRet .AND. oEstEnder:oProdLote:HasRastro() .And. Empty(cLoteCtl)
			WmsMessage(WmsFmtMsg(STR0038,{{"[VAR01]",cProduto}}),WMSXFUNG35,5,,,) //"Produto com controle de rastro: [VAR01]  e controle WMS. Necessário informar o Lote! " 
			lRet := .F. 
		EndIf
		If lRet .And. oEstEnder:oProdLote:HasRastSub() .And. Empty(cNumLote)
			WmsMessage(WmsFmtMsg(STR0039,{{"[VAR01]",cProduto}}),WMSXFUNG36,5,,,) //"Produto com controle de rastro: [VAR01]  e controle WMS. Necessário informar o SubLote! "
			lRet := .F. 
		EndIf
		If lRet .And. !Empty(cServico)
			WmsMessage(WmsFmtMsg(STR0040,{{"[VAR01]",cProduto}}),WMSXFUNG37,5,,,) //"Produto com controle WMS: [VAR01]. Para desmontagem não deverá ser informado serviço."
			lRet := .F. 
		EndIf

		oEstEnder:oEndereco:SetArmazem(cLocal)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oEndereco:LoadData()
		If lRet .And. WmsArmUnit(cLocal)
			If !(oEstEnder:oEndereco:GetTipoEst() == 2 .Or. oEstEnder:oEndereco:GetTipoEst() == 5 .Or. oEstEnder:oEndereco:GetTipoEst() == 7 .Or. oEstEnder:oEndereco:GetTipoEst() == 8)
				WmsMessage(WmsFmtMsg(STR0041,{{"[VAR01]",cLocal},{"[VAR02]",AllTrim(cEndereco)}}),WMSXFUNG38,5,,,STR0042) //"Armazém [VAR01] e o tipo de estrutura do endereço [VAR02] controlam unitizadores! Operação não permitida."//" Informe um endereço com estrutura do tipo (1-Picking, 5-Doca, 7-Produção ou 8-Qualidade) para realizar a desmontagem."
				lRet := .F. 
			EndIf
		EndIf
		If lRet
			oSeqAbast := WMSDTCSequenciaAbastecimento():New()
			oSeqAbast:SetArmazem(cLocal)
			oSeqAbast:SetProduto(cProduto)
			oSeqAbast:SetEstFis(oEstEnder:oEndereco:GetEstFis())
			If !oSeqAbast:LoadData(2)
				WmsMessage(WmsFmtMsg(STR0043,{{"[VAR01]",cProduto}}),WMSXFUNG39,5,,,STR0044) //"O produto [VAR01] possui controle WMS e não possui a estrutura cadastrada do endereço informado." //"Informe outro endereço ou cadastre a estrutura para o produto."
				lRet := .F.
			EndIf
			If lRet
				If !(oSeqAbast:GetTipoEnd() == '4')
					WmsMessage(WmsFmtMsg(STR0045,{{"[VAR01]",oEstEnder:oEndereco:GetEstFis()}}),WMSXFUNG40,5,,,WmsFmtMsg(STR0046 ,{{"[VAR01]",cProduto},{"[VAR02]",oEstEnder:oEndereco:GetEstFis()}})) //"Estrutura física [VAR01] não permite misturar produtos."" Informe outro endereço ou configure no cadastro de sequência de abastecimento do produto [VAR01] a estrutura fisica [VAR02] o tipo de endereçamento que permita misturar produtos."
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Else  //Estorno
		oEstEnder := WMSDTCEstoqueEndereco():New()
		oEstEnder:oEndereco:SetArmazem(cLocal)
		oEstEnder:oEndereco:SetEnder(cEndereco)
		oEstEnder:oProdLote:SetArmazem(cLocal)
		oEstEnder:oProdLote:SetPrdOri(cProduto)
		oEstEnder:oProdLote:SetProduto(cProduto)
		oEstEnder:oProdLote:SetLoteCtl(cLoteCtl)
		oEstEnder:oProdLote:SetNumLote(cNumLote)
		If oEstEnder:LoadData()
			nSldEnd := oEstEnder:ConsultSld(.F.,.T.,.T.,.T.)
		EndIf
		If QtdComp(nSldEnd) < QtdComp(nQuant)
			WmsMessage(WmsFmtMsg(STR0047,{{"[VAR01]",cEndereco},{"[VAR02]",Str(nSldEnd)}}),WMSXFUNG41,5,,,) //"Saldo indisponível no endereço: [VAR01] para retirada. Saldo Disponível: [VAR02] ."
			lRet := .F. 
		EndIf 
		oEstEnder:Destroy()
	EndIf
	RestArea(aArea)
Return lRet
