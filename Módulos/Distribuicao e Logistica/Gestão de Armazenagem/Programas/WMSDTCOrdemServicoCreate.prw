#Include "Totvs.ch"
#Include "WMSDTCOrdemServicoCreate.ch"

Static lWMSOSEDT := ExistBlock('WMSOSEDT')

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0030
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0030()
Return Nil
//-------------------------------------------------
/*/{Protheus.doc} WMSDTCOrdemServicoCreate
Classe criação da ordem de serviço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-------------------------------------------------
CLASS WMSDTCOrdemServicoCreate FROM WMSDTCOrdemServico
	// Data
	DATA cSeqSC9
	DATA cCf
	// Method
	METHOD New() CONSTRUCTOR
	METHOD SetSeqSC9(cSeqSC9)
	METHOD SetCf(cCf)
	METHOD CreateDCF()
	METHOD AssignSD1()
	METHOD AssignSD2()
	METHOD AssignDH1()
	METHOD AssignSC9()
	METHOD AssignDCF()
	METHOD AssignD0G()
	METHOD AssignD0R()
	METHOD AssignSC2()
	METHOD AssignSD3()
	METHOD AssignSD7()
	METHOD FindCodRec()
	METHOD Destroy()
	METHOD WmsValRes()
ENDCLASS
//-------------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------------
METHOD New() CLASS WMSDTCOrdemServicoCreate
	_Super:New()
	Self:cSeqSC9 := PadR("",TamSx3("C9_SEQUEN")[1])
	Self:cCf     := PadR("",TamSx3("D3_CF")[1])
Return

METHOD Destroy() CLASS WMSDTCOrdemServicoCreate
	//FreeObj(Self)
Return
//----------------------------------------
// Setters
//----------------------------------------
METHOD SetSeqSC9(cSeqSC9) CLASS WMSDTCOrdemServicoCreate
	Self:cSeqSC9 := PadR(cSeqSC9, Len(Self:cSeqSC9))
Return

METHOD SetCf(cCf) CLASS WMSDTCOrdemServicoCreate
	Self:cCf := PadR(cCf, Len(Self:cCf))
Return
//-------------------------------------------------
/*/{Protheus.doc} CreateDCF
Criação da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------------
METHOD CreateDCF() CLASS WMSDTCOrdemServicoCreate
Local lRet := .T.
	Do Case
		Case Self:cOrigem == 'SD1'
			lRet := Self:AssignSD1()
		Case Self:cOrigem == 'SD2'
			lRet := Self:AssignSD2()
		Case Self:cOrigem == 'DH1'
			lRet := Self:AssignDH1()
		Case Self:cOrigem == 'SC9'
			lRet := Self:AssignSC9()
		Case Self:cOrigem == 'D0R'
			lRet := Self:AssignD0R()
		Case Self:cOrigem == 'DCF' .Or. Self:cOrigem == 'SD4'
			lRet := Self:AssignDCF()
		Case Self:cOrigem == 'SC2'
			lRet := Self:AssignSC2()
		Case Self:cOrigem == 'SD3'
			lRet := Self:AssignSD3()
		Case Self:cOrigem == 'SD7'
			lRet := Self:AssignSD7()
	EndCase
	If !lRet
		AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) //"SIGAWMS - OS [VAR01] - Produto: [VAR02]"
	EndIf
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignSD1
Registra os dados as propriedades SD1
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------------
METHOD AssignSD1() CLASS WMSDTCOrdemServicoCreate
Local lRet       := .T.
Local aAreaSD1   := SD1->(GetArea())
Local cLocalCQ   := SuperGetMV("MV_CQ",.F.,"")
Local cLocalizCQ := SuperGetMV("MV_DISTAUT",.F.,"")
Local cRetPE     := ""

	If Empty(Self:cNumSeq)
		lRet := .F.
		Self:cErro := STR0002 // Dados para busca não foram informados!
	EndIf
	If lRet
		If !(xFilial("SD1")+Self:cNumSeq == SD1->(D1_FILIAL+D1_NUMSEQ))
			SD1->(dbSetOrder(4))
			If !SD1->(dbSeek(xFilial("SD1")+Self:cNumSeq))
				lRet := .F.
			ElseIf !Empty(SD1->D1_IDDCF)
				Self:cErro := STR0003 // Documento já possui DFC Gerada
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Valida se serviço foi informado
	If lRet .AND. Empty(SD1->D1_SERVIC)
		Self:cErro := STR0005 // Serviço não informado!
		lRet := .F.
	EndIf
	// Valida se endereco foi informado
	If lRet .AND. Empty(SD1->D1_ENDER)
		Self:cErro := STR0006 // Endereco não informado!
		lRet := .F.
	EndIf

	If lRet
		Self:cDocumento:= SD1->D1_DOC
		Self:cSerie    := SD1->D1_SERIE
		Self:cCliFor   := SD1->D1_FORNECE
		Self:cLoja     := SD1->D1_LOJA
		Self:cStServ   := SD1->D1_STSERV
		Self:nQuant    := SD1->D1_QUANT
		Self:cRegra    := SD1->D1_REGWMS
		Self:cCodNorma := SD1->D1_CODNOR
		Self:cCodRec   := Self:FindCodRec() // Grava codigo do recebimento de conferência
	EndIf

	If lRet
		// Busca dados Endereco Destino
		Self:oOrdEndOri:SetArmazem(SD1->D1_LOCAL)
		Self:oOrdEndOri:SetEnder(SD1->D1_ENDER)
		If !Self:oOrdEndOri:LoadData()
			Self:cErro := Self:oOrdEndOri:GetErro()
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Busca dados Endereco Origem
		Self:oOrdEndDes:SetArmazem(SD1->D1_LOCAL)
		// Quando apontamento envia para o CQ e o parâmetro MV_DISTAUT está ativo, seta endereço destino do parâmetro.
		// ---------------------------------
		// O parametro MV_DISTAUT deve ser do tipo "C" (caracter), e seu conteudo deve ser AALLLLLLLLLLLLLLL,
		// onde A=Almoxarifado CQ e L=Localização Fisica Padrão. Ex.: Se o almoxarifado CQ for "98" e a
		// Localização Fisica Padrão cadastrada para este Almoxarifado for "P01" o conteúdo do parametro ficaria igual a 98P01
		If !WmsSkipCQ() .And. (cLocalCQ == SD1->D1_LOCAL) .And. !Empty(cLocalizCQ) .And. cLocalCQ $ cLocalizCQ
			Self:oOrdEndDes:SetEnder(SubStr(cLocalizCQ, TamSx3("D1_LOCAL")[1]+1))
			If !Self:oOrdEndDes:LoadData()
				Self:oOrdEndDes:SetEnder("")
			EndIf
		EndIf

		If lWMSOSEDT
			cRetPE := ExecBlock('WMSOSEDT',.F.,.F.,{Self:cOrigem, Self:oOrdEndDes:GetArmazem(),Self:oOrdEndDes:GetEnder()})
			If ValType( cRetPE ) ==  "C"
				Self:oOrdEndDes:SetEnder(cRetPE)
				If !Self:oOrdEndDes:LoadData()
					Self:oOrdEndDes:SetEnder("")
				EndIf
			EndIf
		EndIf

		// Busca dados Lote/Produto
		Self:oProdLote:SetArmazem(SD1->D1_LOCAL)
		Self:oProdLote:SetPrdOri(SD1->D1_COD)
		Self:oProdLote:SetProduto(SD1->D1_COD)
		Self:oProdLote:SetLoteCtl(SD1->D1_LOTECTL)
		Self:oProdLote:SetNumLote(SD1->D1_NUMLOTE)
		Self:oProdLote:SetNumSer("")
		Self:oProdLote:LoadData()
	EndIf
	// Valida bloqueio produto (B1_MSBLQL)
	If lRet .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@Self:cErro)
		lRet := .F.
	EndIf

	If lRet
		// Busca dados Servico
		Self:oServico:SetServico(SD1->D1_SERVIC)
		If !Self:oServico:LoadData()
			Self:cErro := Self:oServico:GetErro()
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Grava DCF
		If Self:RecordDCF()
			// Grava entrada saldo doca
			If Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
				lRet := Self:MakeArmaz()
				If lRet .AND. Self:ChkMovEst(.F.)
					lRet := Self:MakeInput()
				EndIf
				// Quando parametrizado que atualiza saldo a distribuir
				// Caso serviço tenha operação de endereçamento, endereçamento crossdocking
				If lRet
					// Cria os saldos a distribuir
					lRet := Self:AssignD0G()
				EndIf
			EndIf
			If lRet
				// Grava IDDCF na SD1
				RecLock('SD1', .F.)
				SD1->D1_STSERV := Self:cStServ
				SD1->D1_IDDCF  := Self:cIdDCF  // Incluir o campo IDDCF na SD1
				SD1->(MsUnLock())
			EndIf
			// Verifica se o servico possuí execução automatica
			If lRet .AND. Self:oServico:GetTpExec() == "2"
				AAdd(Self:aLibDCF,Self:cIdDCF)
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSD1)
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignSD2
Registra os dados as propriedades SD2
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------------
METHOD AssignSD2() CLASS WMSDTCOrdemServicoCreate
Local lRet     := .T.
Local aAreaSD2 := SD2->(GetArea())
	If Empty(Self:cNumSeq)
		lRet                := .F.
		Self:cErro := STR0002 // Dados para busca não foram informados!
	EndIf
	If lRet
		If !(xFilial("SD2")+Self:cNumSeq == SD2->(D2_FILIAL+D2_NUMSEQ))
			SD2->(dbSetOrder(4))
			If !SD2->(dbSeek(xFilial("SD2")+Self:cNumSeq))
				lRet := .F.
			EndIf
		EndIf
	EndIf
	// Valida se serviço foi informado
	If lRet .AND. Empty(SD2->D2_SERVIC)
		Self:cErro := STR0005 // Serviço não informado!
		lRet := .F.
	EndIf

	If lRet
		Self:cDocumento:= SD2->D2_DOC
		Self:cSerie    := SD2->D2_SERIE
		Self:cCliFor   := SD2->D2_CLIENTE
		Self:cLoja     := SD2->D2_LOJA
		Self:cStServ   := SD2->D2_STSERV
		Self:nQuant    := SD2->D2_QUANT
		//Self:cArmazem  := SD2->D2_LOCAL
		Self:cRegra    := SD2->D2_REGWMS
		// Busca dados endereco Origem
		Self:oOrdEndOri:SetArmazem(SD2->D2_LOCAL)
		Self:oOrdEndOri:SetEnder(SD2->D2_LOCALIZ)
		// Busca dados endereco Destino
		Self:oOrdEndDes:SetArmazem(SD2->D2_LOCAL)
		// Busca dados lote/produto
		Self:oProdLote:SetArmazem(SD2->D2_LOCAL)
		Self:oProdLote:SetPrdOri(SD2->D2_COD)
		Self:oProdLote:SetProduto(SD2->D2_COD)
		Self:oProdLote:SetLoteCtl(SD2->D2_LOTECTL)
		Self:oProdLote:SetNumLote(SD2->D2_NUMLOTE)
		Self:oProdLote:SetNumSer(SD2->D2_NUMSERI)
		Self:oProdLote:LoadData()
	EndIf
	// Valida bloqueio produto (B1_MSBLQL)
	If lRet .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@Self:cErro)
		lRet := .F.
	EndIf

	If lRet
		// busca dados servico
		Self:oServico:SetServico(SD2->D2_SERVIC)
		If !Self:oServico:LoadData()
			Self:cErro := Self:oServico:GetErro()
			lRet := .F.
		EndIf
	EndIf
	// Grava DCF
	If lRet
		If Self:RecordDCF()
			// Atualiza estoque endereco com saida prevista
			// empenho do lote
			If lRet .And. Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
				If lRet .And. Self:ChkMovEst()
					lRet := Self:MakeOutput()
					If lRet
						lRet := Self:MakeInput()
					EndIf
				EndIf
			EndIf 
			// Grava SD2
			RecLock('SD2', .F.)
			SD2->D2_STSERV := Self:cStServ
			//SD2->D2_IDDCF  := Self:cIdDCF  //Não existe este campo na Sd2.
			SD2->(MsUnLock())
		EndIf
	EndIf
	// Verifica se o servico possue execução automatica
	If lRet .AND. Self:oServico:GetTpExec() == "2"
		AAdd(Self:aLibDCF,Self:cIdDCF)
	EndIf
	RestArea(aAreaSD2)
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignDH1
Registra os dados as propriedades DH1
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------------
METHOD AssignDH1() CLASS WMSDTCOrdemServicoCreate
Local lRet       := .T.
Local aAreaDH1   := DH1->(GetArea())
Local aAreaSD3   := SD3->(GetArea())
Local cAliasQry  := Nil
Local cAliasDCF  := Nil

	If (Empty(Self:GetDocto()) .Or. Empty(Self:oProdLote:GetArmazem()) .Or. Empty(Self:cNumSeq))
		lRet := .F.
		Self:cErro := STR0002 // Dados para busca não foram informados!
	EndIf
	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DH1.R_E_C_N_O_ RECNODH1,
				   DH1.DH1_IDDCF DH1IDDCF
			  FROM %Table:DH1% DH1
		 	 WHERE DH1.DH1_FILIAL = %xFilial:DH1%
	 		   AND DH1.DH1_DOC = %Exp:Self:cDocumento% 
			   AND DH1.DH1_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
			   AND DH1.DH1_NUMSEQ = %Exp:Self:cNumSeq%
			   AND DH1.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			cAliasDCF := GetNextAlias()
			BeginSql Alias cAliasDCF 
				SELECT DCF.DCF_ID
				  FROM %Table:DCF% DCF
			     WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			       AND DCF.DCF_ID = %Exp:(cAliasQry)->DH1IDDCF%
			       AND DCF.%NotDel%
			EndSql
			If !Empty((cAliasDCF)->DCF_ID)
				Self:cErro := STR0003 // Documento já possui DCF Gerada
				lRet := .F.
			Else
				DH1->(dbGoto((cAliasQry)->RECNODH1))
			EndIf
			(cAliasDCF)->(dbCloseArea())			
		Else
			Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:oProdLote:GetArmazem()},{"[VAR03]",Self:cNumSeq}}) // "Documento: [VAR01] Armazem: [VAR02] Número Sequencial: [VAR03] não encontrados! (DH1)"
			lRet := .F.
		EndIf		
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet
		Self:cCF     := DH1->DH1_CF
		Self:cStServ := "1"
		Self:nQuant  := DH1->DH1_QUANT
		If Type("__cCodRec") == "C"
			Self:cCodRec := __cCodRec
		EndIf
		Self:cRegra  := "" //DH1->DH1_REGWMS
		If DH1->DH1_TM > "500"
			// Verifica informacoes de lote/sub-lote
			If Empty(Self:cRegra) .And. !Empty(DH1->DH1_LOTECT+DH1->DH1_NUMLOT)
				Self:cRegra := "1"
			EndIf
		EndIf
	EndIf
	If lRet
		// Busca dados Servico
		Self:oServico:SetServico(DH1->DH1_SERVIC)
		If !Self:oServico:LoadData()
			Self:cErro := Self:oServico:GetErro()
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Busca dados Lote/Produto
		Self:oProdLote:SetPrdOri(DH1->DH1_PRODUT)
		Self:oProdLote:SetLoteCtl(DH1->DH1_LOTECT)
		Self:oProdLote:SetNumLote(DH1->DH1_NUMLOT)
		Self:oProdLote:SetNumSer(DH1->DH1_NUMSER)
		Self:oProdLote:LoadData()
	EndIf

	// Valida produtos bloqueados SB1
	If lRet .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@Self:cErro)
		lRet := .F.
	EndIf

	// Validação do serviço x endereço informado.
	If lRet
		// Valida se endereço origem preenchido
		If !Empty(Self:oOrdEndOri:GetEnder()) .And. !Self:oOrdEndOri:LoadData()
			Self:cErro := Self:oOrdEndOri:GetErro()
			lRet := .F.
		EndIf
		// Valida se o endereço destino preenchido
		If lRet .And. !Empty(Self:oOrdEndDes:GetEnder()) .And. !Self:oOrdEndDes:LoadData()
			Self:cErro := Self:oOrdEndDes:GetErro()
			lRet := .F.
		EndIf

		If lRet
			If Self:oServico:HasOperac({'8'}) .And. Empty(Self:oOrdEndOri:GetEnder()) // Caso serviço tenha operação de transferencia
				Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",Self:oServico:GetServico()},{"[VAR02]",Self:oServico:GetDesServ()}}) // Endereço origem não foi informado para o serviço: [VAR01] - [VAR02].
				lRet := .F.
			ElseIf Self:oServico:HasOperac({'3','4'}) .And. Empty(Self:oOrdEndDes:GetEnder()) // caso serviço tenha operação de separação, separação crossdocking
				Self:cErro := WmsFmtMsg(STR0011,{{"[VAR01]",Self:oServico:GetServico()},{"[VAR02]",Self:oServico:GetDesServ()}}) // "Endereço destino não foi informado para o serviço: [VAR01] - [VAR02]."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	// Grava DCF
	If lRet
		If Self:RecordDCF()
			// Grava IDDCF na DH1
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
			SELECT DH1.R_E_C_N_O_ RECNODH1
				FROM %Table:DH1% DH1
				WHERE DH1.DH1_FILIAL = %xFilial:DH1%
				AND DH1.DH1_DOC = %Exp:Self:cDocumento% 
				AND DH1.DH1_NUMSEQ = %Exp:Self:cNumSeq%
				AND DH1.%NotDel%
			EndSql
			Do While (cAliasQry)->(!Eof())
				DH1->(dbGoTo((cAliasQry)->RECNODH1))
				RecLock("DH1", .F.)
				DH1->DH1_STATUS := "1" // Não Iniciada
				DH1->DH1_IDDCF  := Self:cIdDCF
				DH1->(MsUnLock())
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			If Self:oServico:HasOperac({'8'}) // Caso serviço tenha operação de transferencia
				// Atualiza estoque endereco com saida prevista
				lRet := Self:MakeOutput()
				If lRet .And. Self:ChkMovEst(.F.)
					lRet := Self:MakeInput()
				EndIf
			ElseIf Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
				If Self:ChkMovEst()
					lRet := Self:MakeOutput()
					If lRet
						lRet := Self:MakeInput()
					EndIf
				EndIf
			EndIf
			// Verifica se o servico possui execução automatica
			If lRet .AND. Self:oServico:GetTpExec() == "2"
				AAdd(Self:aLibDCF,Self:cIdDCF)
			EndIf
		ELSE
			lRet := .F.  	
		EndIf
	EndIf
	RestArea(aAreaDH1)
	RestArea(aAreaSD3)
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignSC9
Registra os dados as propriedades SC9
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD AssignSC9() CLASS WMSDTCOrdemServicoCreate
Local lRet     := .T.
Local aAreaSC9 := SC9->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local cPedido  := ""
Local cItem    := ""
Local cEndOri  := ""
Local cCliFor  := ""
Local cLoja    := ""

	If (Empty(Self:cDocumento) .OR. Empty(Self:cSerie);
		.OR. Empty(Self:cSeqSC9) .OR. Empty(Self:oProdLote:GetProduto()))
		lRet  := .F.
		Self:cErro := STR0002 // Dados para busca não foram informados!
	EndIf
	If lRet
		cPedido := PadR(Self:cDocumento, TamSx3("C9_PEDIDO")[1])
		cItem   := PadR(Self:cSerie, TamSx3("C9_ITEM")[1])
		
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SC9.R_E_C_N_O_ RECNOSC9,
					SC6.C6_LOCALIZ,
					SC5.C5_CLIENTE,
					SC5.C5_LOJACLI
			FROM %Table:SC9% SC9
			INNER JOIN %Table:SC5% SC5
			ON SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = SC9.C9_PEDIDO
			AND SC5.%NotDel%
			INNER JOIN %Table:SC6% SC6
			ON SC6.C6_FILIAL = %xFilial:SC6%
			AND SC6.C6_NUM = SC9.C9_PEDIDO
			AND SC6.C6_ITEM = SC9.C9_ITEM
			AND SC6.C6_PRODUTO = SC9.C9_PRODUTO
			AND SC6.%NotDel%
			WHERE SC9.C9_FILIAL = %xFilial:SC9%
			AND SC9.C9_PEDIDO = %Exp:cPedido%
			AND SC9.C9_ITEM = %Exp:cItem%
			AND SC9.C9_SEQUEN = %Exp:Self:cSeqSC9%
			AND SC9.C9_PRODUTO = %Exp:Self:oProdLote:GetProduto()%
			AND SC9.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SC9->(dbGoTo((cAliasQry)->RECNOSC9))
			If !Empty(SC9->C9_IDDCF)
				Self:cIdDCF := SC9->C9_IDDCF
				If Self:ExisteDCF()
					Self:cErro := STR0003 // Documento já possui DFC Gerada
					lRet := .F.
				EndIf
			EndIf
			If lRet
				cEndOri := (cAliasQry)->C6_LOCALIZ
				cCliFor := (cAliasQry)->C5_CLIENTE
				cLoja   := (cAliasQry)->C5_LOJACLI
				
			EndIf
		Else
			Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",cPedido},{"[VAR02]",cItem},{"[VAR03]",Self:cSeqSC9}}) // Não foi possível encontrar a liberação do Pedido/Item/Seq [VAR01]/[VAR02]/[VAR03].
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	If lRet .AND. Empty(SC9->C9_SERVIC)
		Self:cErro := STR0005 // Serviço não informado!
		lRet := .F.
	EndIf

	If lRet
		Self:cStServ    := SC9->C9_STSERV
		Self:nQuant     := SC9->C9_QTDLIB
		Self:cRegra     := SC9->C9_REGWMS
		Self:cNumSeq    := ProxNum()
		// Verifica informacoes de lote/sub-lote
		If Empty(Self:cRegra) .And. !Empty(SC9->C9_LOTECTL+SC9->C9_NUMLOTE)
			Self:cRegra := "1"
		EndIf
		Self:cCarga  := SC9->C9_CARGA
		Self:cCliFor := cCliFor
		Self:cLoja   := cLoja
		// Busca dados endereco
		Self:oOrdEndDes:SetArmazem(SC9->C9_LOCAL)
		Self:oOrdEndDes:SetEnder(SC9->C9_ENDPAD)
		Self:oOrdEndDes:LoadData()
		// Busca dados Endereco origem
		Self:oOrdEndOri:SetArmazem(SC9->C9_LOCAL)
		Self:oOrdEndOri:SetEnder(cEndOri)
		// Busca dados lote/produto
		Self:oProdLote:SetArmazem(SC9->C9_LOCAL)
		Self:oProdLote:SetPrdOri(SC9->C9_PRODUTO)
		Self:oProdLote:SetLoteCtl(SC9->C9_LOTECTL)
		Self:oProdLote:SetNumLote(SC9->C9_NUMLOTE)
		Self:oProdLote:SetNumSer(SC9->C9_NUMSERI)
		Self:oProdLote:LoadData()
	EndIf
	// Valida produtos bloqueados SB1
	If lRet .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@Self:cErro)
		lRet := .F.
	EndIf

	If lRet
		// Busca dados servico
		Self:oServico:SetServico(SC9->C9_SERVIC)
		If !Self:oServico:LoadData()
			Self:cErro := Self:oServico:GetErro()
			lRet := .F.
		EndIf
	EndIf
		// Grava DCF
	If lRet
		If Self:RecordDCF()
			// Atualiza estoque endereco com saida prevista
			// empenho do lote
			If lRet .And. Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
				If lRet .And. Self:ChkMovEst()
					lRet := Self:MakeOutput()
					If lRet
						lRet := Self:MakeInput()
					EndIf
				EndIf
			EndIf
			If lRet
				// Grava IDDCF na SC9
				RecLock('SC9', .F.)
				SC9->C9_STSERV := Self:cStServ
				SC9->C9_IDDCF  := Self:cIdDCF
				SC9->(MsUnLock())
			EndIf
			// Verifica se o servico possui execução automatica
			If lRet .AND. Self:oServico:GetTpExec() == "2"
				AAdd(Self:aLibDCF,Self:cIdDCF)
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSC9)
	RestArea(aAreaSC5)
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignDCF
Registra os dados as propriedades DCF
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD AssignDCF() CLASS WMSDTCOrdemServicoCreate
Local lRet     := .T.
	If (!Self:IsMovUnit() .And. Empty(Self:oProdLote:GetProduto())) .OR. Empty(Self:oServico:GetServico()) .OR. QtdComp(Self:nQuant) <= 0
		If (Empty(Self:oOrdEndOri:GetArmazem()) .AND. Empty(Self:oOrdEndDes:GetArmazem())) .OR. (Empty(Self:oOrdEndOri:GetEnder()) .AND. Empty(Self:oOrdEndDes:GetEnder()))
			lRet := .F.
			Self:cErro := STR0002 // Dados para busca não foram informados!
		EndIf
	EndIf
	If lRet
		// Busca dados endereco origem
		Self:oOrdEndOri:LoadData()
		// Busca dados endereco destino
		Self:oOrdEndDes:LoadData()
	EndIf
	If lRet .And. !Self:IsMovUnit()
		// Busca dados lote/produto
		If !Empty(Self:oOrdEndOri:GetArmazem())
			Self:oProdLote:SetArmazem(Self:oOrdEndOri:GetArmazem())
		Else
			Self:oProdLote:SetArmazem(Self:oOrdEndDes:GetArmazem())
		EndIf
		If Empty(Self:oProdLote:GetPrdOri())
			Self:oProdLote:SetPrdOri(Self:oProdLote:GetProduto())
		EndIf
		Self:oProdLote:LoadData()
		// Valida produtos bloqueados SB1
		If !WmsSB1Blq(Self:oProdLote:GetProduto(),@Self:cErro)
			lRet := .F.
		EndIf
	EndIf
	If lRet
		// Busca dados servico
		Self:oServico:LoadData()
		If Empty(Self:cDocumento)
			Self:cDocumento :=  GetSX8Num('DCF', 'DCF_DOCTO'); ConfirmSx8()
		EndIf
		If Empty(Self:cNumSeq)
			Self:cNumSeq := ProxNum()
		EndIf

		// Retira o unitizador e tipo unitizador destino caso o endereço seja de picking ou produção
		If !Empty(Self:GetUniDes()) .And. (Self:oOrdEndDes:GetTipoEst() == 2 .Or. Self:oOrdEndDes:GetTipoEst() == 7)
			Self:cUniDes := ""
			Self:cTipUni := ""
		EndIf

		// Grava DCF
		If Self:RecordDCF()
			// Atualiza Saldo
			// Caso serviço tenha operação de transferencia
			If Self:oServico:HasOperac({'8'})
				// Atualiza estoque endereco com saida prevista
				lRet := Self:MakeOutput()
				If lRet .AND. Self:ChkMovEst(.F.)
					lRet := Self:MakeInput()
				EndIf
			EndIf
			// Caso serviço tenha operação de endereçamento, endereçamento crossdocking
			If lRet .And. Self:oServico:HasOperac({'1','2'})
				// Atualiza estoque endereco com saida prevista
				lRet := Self:MakeArmaz()
				If lRet .AND. Self:ChkMovEst(.F.)
					lRet := Self:MakeInput()
				EndIf
				// Quando parametrizado que atualiza saldo a distribuir
				If lRet
					// Cria os saldos a distribuir
					lRet := Self:AssignD0G()
				EndIf
			EndIf
			// Atualiza estoque endereco com saida prevista
			// empenho do lote
			If lRet .And. Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
				If lRet .And. Self:ChkMovEst()
					lRet := Self:MakeOutput()
					If lRet
						lRet := Self:MakeInput()
					EndIf
				EndIf
			EndIf
			// Verifica se o servico possue execução automatica
			If lRet .AND. Self:oServico:GetTpExec() == "2"
				AAdd(Self:aLibDCF,Self:cIdDCF)
			EndIf
			//Verifica se deverá atualizar a reserva do produto (B2_RESERVA)
			IF lRet .And. Self:WmsValRes()			
				WmsEmpB2B8(.T./*lReserva*/,Self:nQuant,Self:oProdLote:GetProduto(),Self:oProdLote:GetArmazem(),Self:oProdLote:GetLoteCtl(),Self:oProdLote:GetNumLote())
			EndIf
		Else
		   lRet := .F. 
		EndIf
		
	EndIf
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} FindCodRec
Procura o código da conferencia de recebimento para atualizar
a ordem de serviço
@author Alexsander.correa
@since 14/09/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD FindCodRec() CLASS WMSDTCOrdemServicoCreate
Local cCodRec   := ""
Local cAliasDCX := GetNextAlias()
	BeginSql Alias cAliasDCX
		SELECT DCX.DCX_EMBARQ
		FROM %Table:DCX% DCX
		WHERE DCX.DCX_FILIAL = %xFilial:DCX%
		AND DCX.DCX_DOC = %Exp:Self:cDocumento%
		AND DCX.DCX_SERIE = %Exp:Self:cSerie%
		AND DCX.DCX_FORNEC = %Exp:Self:cCliFor%
		AND DCX.DCX_LOJA = %Exp:Self:cLoja%
		AND DCX.%NotDel%
	EndSql
	If (cAliasDCX)->(!Eof())
		cCodRec := (cAliasDCX)->DCX_EMBARQ
	EndIf
	(cAliasDCX)->(dbCloseArea())
Return cCodRec
//-------------------------------------------------
/*/{Protheus.doc} AssignD0G
Grava saldo a distribuir D0G.
@author Inovação WMS
@since 24/03/2017
@version 1.0
/*/
//-------------------------------------------------
METHOD AssignD0G() CLASS WMSDTCOrdemServicoCreate
Local lRet      := .T.
Local oSaldoADis:= Nil
	If SuperGetMV("MV_WMSBLQE",.F.,.F.)
		oSaldoADis := WMSDTCSaldoADistribuir():New()
		oSaldoADis:oProdLote := Self:oProdLote // Utiliza a mesma referência do objeto já carregado
		oSaldoADis:SetQtdOri(Self:nQuant)
		oSaldoADis:SetQtdSld(Self:nQuant)
		oSaldoADis:SetDocto(Self:cDocumento)
		oSaldoADis:SetSerie(Self:cSerie)
		oSaldoADis:SetCliFor(Self:cCliFor)
		oSaldoADis:SetLoja(Self:cLoja)
		oSaldoADis:SetOrigem(Self:cOrigem)
		oSaldoADis:SetNumSeq(Self:cNumSeq)
		oSaldoADis:SetIdDCF(Self:cIdDCF)
		If !oSaldoADis:AssignD0G()
			Self:cErro := oSaldoADis:GetErro()
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignD0R
Registra os dados as propriedades DCF
@author felipe.m
@since 26/04/2017
@version 1.0
/*/
//-------------------------------------------------
METHOD AssignD0R() CLASS WMSDTCOrdemServicoCreate
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil 
	// Carrega dados servico
	Self:oServico:LoadData()
	// Carrega dados do endereço origem
	Self:oOrdEndOri:LoadData()
	// Grava DCF
	If (lRet := Self:RecordDCF())
		If lRet .And. Self:ChkMovEst(.F.)
			lRet := Self:MakeInput()
		EndIf
		// Verifica se o servico possue execução automática
		If Self:oServico:GetTpExec() == "2"
			aAdd(Self:aLibDCF,Self:cIdDCF)
		EndIf
		// Atualiza o código identificador da ordem de serviço na tabela do unitizador
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D0R.R_E_C_N_O_ RECNOD0R
			FROM %Table:D0R% D0R
			WHERE D0R.D0R_FILIAL = %xFilial:D0R%
			AND D0R.D0R_IDUNIT = %Exp:Self:cIdUnitiz%
			AND D0R.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			D0R->(dbGoTo((cAliasQry)->RECNOD0R))
			RecLock("D0R",.F.)
			D0R->D0R_STATUS := "3" // Finalizado
			D0R->D0R_IDDCF := Self:cIdDCF
			If Empty(D0R->D0R_SERVIC)
				D0R->D0R_SERVIC := Self:oServico:GetServico()
			EndIf
			D0R->(MsUnlock())
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} AssignSC2
Criação da ordem de serviço a partir do apontamento da OP
@author felipe.m
@since 26/04/2017
@version 1.0
/*/
//-------------------------------------------------
METHOD AssignSC2() CLASS WMSDTCOrdemServicoCreate
Return Self:AssignSD3()
//-------------------------------------------------
/*{Protheus.doc} AssignSD7
Criação da demanda de unitização a partir da liberação de CQ
@author Squad WMS
@since 26/07/2017
@version 1.0
*/
//-------------------------------------------------
METHOD AssignSD7() CLASS WMSDTCOrdemServicoCreate
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil

	If (Empty(Self:cDocumento) .Or. Empty(Self:cNumSeq) .Or. Empty(Self:oProdLote:GetProduto()))
		Self:cErro := STR0006 // Dados para busca não foram informados!
		lRet := .F.
	EndIf

	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD7.D7_FORNECE,
					SD7.D7_LOJA,
					SD7.D7_SERVIC,
					SD7.D7_LOCDEST,
					SD7.D7_LOCALIZ,
					SD7.D7_LOCDEST
			FROM %Table:SD7% SD7
			WHERE SD7.D7_FILIAL = %xFilial:SD7%
			AND SD7.D7_PRODUTO = %Exp:Self:oProdLote:GetProduto()%
			AND SD7.D7_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD7.D7_NUMERO = %Exp:Self:cDocumento%
			AND SD7.%NotDel%
		EndSql
		If (cAliasQry)->(Eof())
			Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",Self:cDocumento},{"[VAR02]",Self:oProdLote:GetProduto()},{"[VAR03]",Self:cNumSeq}}) // Não foi possível encontrar a liberação do CQ - Documento/Produto/Num.Seq. [VAR01]/[VAR02]/[VAR03].
			lRet := .F.
		EndIf
		If lRet
			Self:cCliFor := (cAliasQry)->D7_FORNECE
			Self:cLoja   := (cAliasQry)->D7_LOJA
			Self:oServico:SetServico((cAliasQry)->D7_SERVIC)
			// Dados endereço origem
			Self:oOrdEndOri:SetArmazem((cAliasQry)->D7_LOCDEST)
			Self:oOrdEndOri:SetEnder((cAliasQry)->D7_LOCALIZ)
			// Dados endereço destino
			Self:oOrdEndDes:SetArmazem((cAliasQry)->D7_LOCDEST)
			Self:oOrdEndDes:SetEnder("")
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet
		lRet := Self:AssignSD3()
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-------------------------------------------------
METHOD AssignSD3() CLASS WMSDTCOrdemServicoCreate
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local cLocalizCQ := SuperGetMv("MV_DISTAUT",.F.,"")
Local cLocalCQ   := SuperGetMv("MV_CQ",.F.,"")
Local cAliasQry  := Nil
Local cRetPE     := ""

	If (Empty(Self:GetDocto()) .Or. Empty(Self:cNumSeq))
		lRet := .F.
		Self:cErro := STR0002 // Dados para busca não foram informados!
	EndIf
	If lRet
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT SD3.R_E_C_N_O_ RECNOSD3
			FROM %Table:SD3% SD3
			WHERE SD3.D3_FILIAL = %xFilial:SD3%
			AND SD3.D3_DOC = %Exp:Self:cDocumento%
			AND SD3.D3_NUMSEQ = %Exp:Self:cNumSeq%
			AND SD3.D3_TM <= '500'
			AND SD3.%NotDel%
		EndSql
		If (cAliasQry)->(!Eof())
			SD3->(DbGoTo((cAliasQry)->RECNOSD3))
			If !Empty(SD3->D3_IDDCF)
				Self:cErro := STR0003 // Documento já possui DCF Gerada
				lRet := .F.
			EndIf
		Else
			Self:cErro := WmsFmtMsg(STR0012,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:cNumSeq}}) // "Documento: [VAR01] Número Sequencial: [VAR02] não encontrados! (SD3)"
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If lRet
		Self:cCF     := SD3->D3_CF
		Self:cStServ := "1"
		Self:nQuant  := SD3->D3_QUANT
		Self:cRegra  := ""
	EndIf
	If lRet
		// Busca dados Servico
		If !Self:oServico:LoadData()
			Self:cErro := Self:oServico:GetErro()
			lRet := .F.
		EndIf
	EndIf
	If lRet
		// Busca dados Lote/Produto
		Self:oProdLote:SetArmazem(SD3->D3_LOCAL)
		Self:oProdLote:SetProduto(SD3->D3_COD)
		Self:oProdLote:SetPrdOri(SD3->D3_COD)
		Self:oProdLote:SetLoteCtl(SD3->D3_LOTECTL)
		Self:oProdLote:SetNumLote(SD3->D3_NUMLOTE)
		Self:oProdLote:SetNumSer(SD3->D3_NUMSERI)
		Self:oProdLote:LoadData()
	EndIf
	// Valida produtos bloqueados SB1
	If lRet .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@Self:cErro)
		lRet := .F.
	EndIf
	// Valida se endereço origem preenchido
	If lRet .And. !Empty(Self:oOrdEndOri:GetEnder()) .And. !Self:oOrdEndOri:LoadData()
		Self:cErro := Self:oOrdEndOri:GetErro()
		lRet := .F.
	EndIf
	// Quando apontamento envia para o CQ e o parâmetro MV_DISTAUT está ativo, seta endereço destino do parâmetro.
	// ---------------------------------
	// O parametro MV_DISTAUT deve ser do tipo "C" (caracter), e seu conteudo deve ser AALLLLLLLLLLLLLLL,
	// onde A=Almoxarifado CQ e L=Localização Fisica Padrão. Ex.: Se o almoxarifado CQ for "98" e a
	// Localização Fisica Padrão cadastrada para este Almoxarifado for "P01" o conteúdo do parametro ficaria igual a 98P01
	If (cLocalCQ == SD3->D3_LOCAL) .And. !Empty(cLocalizCQ) .And. cLocalCQ $ cLocalizCQ
		Self:oOrdEndDes:SetEnder(SubStr(cLocalizCQ, TamSx3("D3_LOCAL")[1]+1))
		If !Self:oOrdEndDes:LoadData()
			Self:oOrdEndDes:SetEnder("")
		EndIf
	EndIf
	If lWMSOSEDT
		cRetPE := ExecBlock('WMSOSEDT',.F.,.F.,{Self:cOrigem, Self:oOrdEndDes:GetArmazem(),Self:oOrdEndDes:GetEnder()})
		If ValType( cRetPE ) ==  "C"
			Self:oOrdEndDes:SetEnder(cRetPE)
			If !Self:oOrdEndDes:LoadData()
				Self:oOrdEndDes:SetEnder("")
			EndIf
		EndIf
	EndIf
	// Valida se o endereço destino preenchido
	If lRet .And. !Empty(Self:oOrdEndDes:GetEnder()) .And. !Self:oOrdEndDes:LoadData()
		Self:cErro := Self:oOrdEndDes:GetErro()
		lRet := .F.
	EndIf
	// Validação do serviço x endereço informado.
	If lRet .And. Self:oServico:HasOperac({'1','2'}) .And. Empty(Self:oOrdEndOri:GetEnder()) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
		Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",Self:oServico:GetServico()},{"[VAR02]",Self:oServico:GetDesServ()}}) // Endereço origem não foi informado para o serviço: [VAR01] - [VAR02].
		lRet := .F.
	EndIf
	// Grava DCF
	If lRet
		If Self:RecordDCF()
			// Grava IDDCF na SD3
			If Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
				// Grava IDDCF no SD3 criado antes da DCF
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SD3.R_E_C_N_O_ RECNOSD3
					FROM %Table:SD3% SD3
					WHERE SD3.D3_FILIAL = %xFilial:SD3%
					AND SD3.D3_DOC = %Exp:Self:cDocumento%
					AND SD3.D3_NUMSEQ = %Exp:Self:cNumSeq%
					AND SD3.%NotDel%
				EndSql
				Do While (cAliasQry)->(!Eof())
					SD3->(dbGoTo((cAliasQry)->RECNOSD3))
					If Self:oProdLote:GetProduto() == SD3->D3_COD
						RecLock("SD3",.F.)
						SD3->D3_IDDCF := Self:cIdDCF
						SD3->(MsUnLock())
					EndIf
					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				// Grava saldo no endereço origem quando enderecamento
				lRet := Self:MakeArmaz()

				If lRet .And. Self:ChkMovEst(.F.)
					lRet := Self:MakeInput()
				EndIf
				// Quando parametrizado que atualiza saldo a distribuir
				If lRet
					// Cria os saldos a distribuir
					lRet := Self:AssignD0G()
				EndIf
			EndIf

			// Verifica se o servico possue execução automatica
			If lRet .AND. Self:oServico:GetTpExec() == "2"
				AAdd(Self:aLibDCF,Self:cIdDCF)
			EndIf
		Else
			lRet := .F. 	
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------
/*/{Protheus.doc} WmsValRes
Método que verifica se o registro estornado deve atualizar o campo B2_RESERVA.
Movimento interno (MATA241)
@author Murilo Brandao
@since 31/08/2023
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------
METHOD WmsValRes() CLASS WMSDTCOrdemServicoCreate
Local lRet := .F.
Local cAliasDCF := GetNextAlias()
Local cOriEst	:= "DH1"
Local cServic   := "3"

	BeginSql Alias cAliasDCF
		SELECT DCF.DCF_ID
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_CODPRO = %Exp:Self:oProdLote:GetProduto()%
		AND DCF.DCF_LOCAL = %Exp:Self:oProdLote:GetArmazem()%
		AND DCF.DCF_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
		AND DCF.DCF_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
		AND DCF.DCF_DOCTO = %Exp:Self:cDocPen%
		AND DCF.DCF_STSERV = %Exp:cServic%
		AND DCF.DCF_ORIGEM = %Exp:cOriEst%
		AND DCF.%NotDel%
	EndSql
	If (cAliasDCF)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasDCF)->(DbCloseArea())

Return lRet
