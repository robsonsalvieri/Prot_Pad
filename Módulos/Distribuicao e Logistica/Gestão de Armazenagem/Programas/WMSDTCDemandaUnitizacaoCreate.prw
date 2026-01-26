#Include "Totvs.ch"
#Include "WMSDTCDemandaUnitizacaoCreate.ch"
//---------------------------------------------
/*{Protheus.doc} WMSCLS0054
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 21/03/2017
@version 1.0
*/
//---------------------------------------------
Function WMSCLS0054()
Return Nil
//-------------------------------------------------
/*{Protheus.doc} WMSDTCDemandaUnitizacaoCreate
Classe criação da ordem de serviço
@author Inovação WMS
@since 21/03/2017
@version 1.0
*/
//-------------------------------------------------
CLASS WMSDTCDemandaUnitizacaoCreate FROM WMSDTCDemandaUnitizacao
	// Data
	DATA cCf
	DATA cCodRec
	DATA lGeraSaldo
	// Method
	METHOD New() CONSTRUCTOR
	METHOD SetCf(cCf)
	METHOD SetCodRec(cCodRec)
	METHOD SetGeraSld(lGeraSaldo)
	METHOD CreateD0Q()
	METHOD AssignSD1()
	METHOD AssignSC2()
	METHOD AssignSD7()
	METHOD AssignSD3()
	METHOD AssignDCW()
	METHOD RecordD0G()
	METHOD UpdateD0G()
	METHOD MakeAmzUni()
	METHOD Destroy()
ENDCLASS
//-------------------------------------------------
/*{Protheus.doc} New
Método construtor
@author Inovação WMS
@since 21/03/2017
@version 1.0
*/
//-------------------------------------------------
METHOD New() CLASS WMSDTCDemandaUnitizacaoCreate
	_Super:New()
	Self:cCf     := Space(TamSx3("D3_CF")[1])
	Self:cCodRec := Space(TamSx3("DCW_EMBARQ")[1])
	Self:lGeraSaldo := .T.
Return

METHOD Destroy() CLASS WMSDTCDemandaUnitizacaoCreate
	//Mantido para compatibilidade
Return
//----------------------------------------
// Setters
//----------------------------------------
METHOD SetCf(cCf) CLASS WMSDTCDemandaUnitizacaoCreate
	Self:cCf := PadR(cCf, Len(Self:cCf))
Return
//----------------------------------------
METHOD SetCodRec(cCodRec) CLASS WMSDTCDemandaUnitizacaoCreate
	Self:cCodRec := PadR(cCodRec, Len(Self:cCodRec))
Return
//-------------------------------------------------
METHOD SetGeraSld(lGeraSaldo) CLASS WMSDTCDemandaUnitizacaoCreate
	Self:lGeraSaldo := lGeraSaldo
Return
//-------------------------------------------------
/*{Protheus.doc} CreateD0Q
Criação da ordem de serviço
@author Inovação WMS
@since 21/03/2017
@version 1.0
*/
//-------------------------------------------------
METHOD CreateD0Q() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet := .T.
	Do Case
		Case Self:cOrigem == 'SD1'
			lRet := Self:AssignSD1()
		Case Self:cOrigem == 'SC2'
			lRet := Self:AssignSC2()
		Case Self:cOrigem == 'SD3'
			lRet := Self:AssignSD3()
		Case Self:cOrigem == 'SD7'
			lRet := Self:AssignSD7()
		Case Self:cOrigem == 'DCW'
			lRet := Self:AssignDCW()
	EndCase
	If !lRet
		AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) //"SIGAWMS - OS [VAR01] - Produto: [VAR02]"
	EndIf
Return lRet
//-------------------------------------------------
/*{Protheus.doc} AssignSD1
Registra os dados as propriedades SD1
@author Inovação WMS
@since 21/03/2017
@version 1.0
*/
//-------------------------------------------------
METHOD AssignSD1() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet     := .T.
Local aAreaSD1 := SD1->(GetArea())

	If Empty(Self:cNumSeq)
		lRet := .F.
		Self:cErro := STR0002 // Dados para busca não foram informados!
	EndIf

	If lRet
		If !(xFilial("SD1")+Self:cNumSeq == SD1->D1_FILIAL+SD1->D1_NUMSEQ)
			SD1->(dbSetOrder(4))
			If !SD1->(dbSeek(xFilial("SD1")+Self:cNumSeq))
				lRet := .F.
			ElseIf !Empty(SD1->D1_IDDCF)
				Self:cErro := STR0003 // Documento já possui D0Q Gerada
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		Self:cDocumento:= SD1->D1_DOC
		Self:cSerie    := SD1->D1_SERIE
		Self:cCliFor   := SD1->D1_FORNECE
		Self:cLoja     := SD1->D1_LOJA
		Self:nQuant    := SD1->D1_QUANT
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

	// Valida se serviço foi informado
	If lRet .And. Empty(SD1->D1_SERVIC)
		Self:cErro := STR0004 // Serviço não informado!
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

	// Valida se endereco foi informado
	If lRet .And. Empty(SD1->D1_ENDER)
		Self:cErro := STR0005 // Endereco não informado!
		lRet := .F.
	EndIf

	// Busca dados Endereco Destino
	Self:oDmdEndOri:SetArmazem(SD1->D1_LOCAL)
	Self:oDmdEndOri:SetEnder(SD1->D1_ENDER)
	If !Self:oDmdEndOri:LoadData()
		Self:cErro := Self:oDmdEndOri:GetErro()
		lRet := .F.
	EndIf

	If lRet
		// Busca dados Endereco Origem
		Self:oDmdEndDes:SetArmazem(SD1->D1_LOCAL)
	EndIf

	If lRet
		WmsChkDCW("5",SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,@Self:cCodRec)
		//Quando possui conferência de recebimento não gera D0Q novamente
		If Empty(Self:cCodRec)
			lRet := Self:RecordD0Q()
		Else
			Self:cIdD0Q := SD1->D1_IDDCF
			If(lRet := Self:LoadData(3))
				//Atualiza informações da demanda que podem ter sofrido alteração
				Self:oProdLote:SetNumLote(SD1->D1_NUMLOTE)
				Self:oServico:SetServico(SD1->D1_SERVIC)
				Self:oServico:LoadData()
				Self:SetNumSeq(SD1->D1_NUMSEQ)
				Self:UpdateD0Q()
			EndIf
		EndIf
	EndIf

	// Grava entrada saldo doca
	If lRet .And. Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
		If Self:lGeraSaldo
			lRet := Self:MakeArmaz()
			If lRet
				lRet := Self:RecordD0G()
			EndIf
			// Se já possui conferência do recebimento, deve ser uma pré-nota que está sendo classificada
			// Deve gerar o estoque já com base nos unitizadores montados, efetuando o rateio do saldo por unitizador
			If lRet .And. !Empty(Self:cCodRec)
				lRet := Self:MakeAmzUni()
			EndIf
		Else
			lRet := Self:UpdateD0G()
		EndIf
	EndIf

	If lRet .And. Empty(Self:cCodRec)
		// Grava o ID da demanda de unitização na SD1
		RecLock('SD1', .F.)
		SD1->D1_IDDCF  := Self:cIdD0Q
		SD1->D1_STSERV := Self:cStatus
		SD1->(MsUnLock())
	EndIf

RestArea(aAreaSD1)
Return lRet
//-------------------------------------------------
/*{Protheus.doc} RecordD0G
Grava saldo a distribuir D0G.
@author Inovação WMS
@since 24/03/2017
@version 1.0
*/
//-------------------------------------------------
METHOD RecordD0G() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet       := .T.
Local oSaldoADis := Nil
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
		oSaldoADis:SetIdDCF(Self:cIdD0Q)
		If !oSaldoADis:RecordD0G()
			Self:cErro := oSaldoADis:GetErro()
			lRet := .F.
		EndIf
	EndIf
Return lRet
//-------------------------------------------------
/*{Protheus.doc} UpdateD0G
Atualiza o saldo a distribuir D0G.
@author Inovação WMS
@since 24/03/2017
@version 1.0
*/
//-------------------------------------------------
METHOD UpdateD0G() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet       := .T.
	//Ajusta D0G com o novo IDD0Q gerado
	D0G->(DbSetOrder(1)) // D0G_FILIAL+D0G_PRODUT+D0G_LOCAL+D0G_NUMSEQ+D0G_DOC+D0G_SERIE+D0G_CLIFOR+D0G_LOJA+D0G_IDDCF
	If D0G->(dbSeek(xFilial('D0G')+Self:oProdLote:GetProduto()+Self:oProdLote:GetArmazem()+Self:cNumSeq+Self:cDocumento+Self:cSerie+Self:cCliFor+Self:cLoja))
		RecLock('D0G', .F.)
		D0G->D0G_IDDCF := Self:cIdD0Q
		D0G->(MsUnLock())
	EndIf
Return lRet
//-------------------------------------------------
/*{Protheus.doc} MakeAmzUni
Faz o armazenamento unitizado.
@author Inovação WMS
@since 24/03/2017
@version 1.0
*/
//-------------------------------------------------
METHOD MakeAmzUni() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet      := .T.
Local cAliasQry := GetNextAlias()
Local cWmsLcFt  := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Local cWmsEndFt  := SuperGetMV("MV_WMSENFT",.F.,"") // Endereço de falta
	
	BeginSql Alias cAliasQry
		SELECT DISTINCT DCX.DCX_DOC
		FROM %Table:DCX% DCX
		WHERE DCX.DCX_FILIAL = %xFilial:DCX%
		AND DCX.DCX_EMBARQ = %Exp:Self:cCodRec%
		AND DCX.%NotDel%
		// Caso exista algum documento sem classificar, não gera o saldo nem OS
		AND EXISTS (SELECT DISTINCT SD1.D1_DOC
					FROM %Table:SD1% SD1
					INNER JOIN %Table:NNR% NNR
					ON NNR.NNR_FILIAL = %xFilial:NNR%
					AND NNR.NNR_CODIGO = SD1.D1_LOCAL
					AND NNR.NNR_AMZUNI = '1'
					AND NNR.%NotDel%"
					WHERE SD1.D1_FILIAL = %xFilial:SD1%
					AND SD1.D1_DOC = DCX.DCX_DOC
					AND SD1.D1_SERIE = DCX.DCX_SERIE
					AND SD1.D1_FORNECE = DCX.DCX_FORNEC
					AND SD1.D1_LOJA = DCX.DCX_LOJA
					AND (SD1.D1_LOCAL <> %Exp:cWmsLcFt%
					OR (SD1.D1_LOCAL = %Exp:cWmsLcFt% AND SD1.D1_ENDER <> %Exp:cWmsEndFt%))
					AND SD1.D1_TES = ' '
					AND SD1.%NotDel% )
	EndSql
	If (cAliasQry)->(Eof())
		// Gera o estoque por endereço e unitizador
		If (lRet := WMSA320D14(Self:cCodRec))
			// Gera as ordens de serviço de endereçamento de cada unitizador
			lRet := WMSA320DCF(Self:cCodRec)
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
Return lRet
//-------------------------------------------------
/*{Protheus.doc} AssignSC2
Criação da demanda de unitização a partir do apontamento da OP
@author Squad WMS
@since 28/06/2017
@version 1.0
*/
//-------------------------------------------------
METHOD AssignSC2() CLASS WMSDTCDemandaUnitizacaoCreate
Return Self:AssignSD3()

//-------------------------------------------------
/*{Protheus.doc} AssignSD7
Criação da demanda de unitização a partir da liberação de CQ
@author Squad WMS
@since 26/07/2017
@version 1.0
*/
//-------------------------------------------------
METHOD AssignSD7() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet     := .T.

	If (Empty(Self:cDocumento) .Or. Empty(Self:cNumSeq) .Or. Empty(Self:oProdLote:GetProduto()) )
		Self:cErro := STR0006 // Dados para busca não foram informados!
		lRet := .F.
	EndIf

	If lRet
		If !(xFilial("SD7")+Self:oProdLote:GetProduto()+Self:cNumSeq+Self:cDocumento == SD7->(D7_FILIAL+D7_PRODUTO+D7_NUMSEQ+D7_NUMERO))
			SD7->(dbSetOrder(3)) //D7_FILIAL+D7_PRODUTO+D7_NUMSEQ+D7_NUMERO
			If !SD7->(dbSeek(xFilial("SD7")+Self:oProdLote:GetProduto()+Self:cNumSeq+Self:cDocumento))
				Self:cErro := WmsFmtMsg(STR0013,{{"[VAR01]",Self:cDocumento},{"[VAR02]",Self:oProdLote:GetProduto()},{"[VAR03]",Self:cNumSeq}}) // Não foi possível encontrar a liberação do CQ - Documento/Produto/Num.Seq. [VAR01]/[VAR02]/[VAR03].
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		Self:cCliFor := SD7->D7_FORNECE
		Self:cLoja   := SD7->D7_LOJA
		Self:oServico:SetServico(SD7->D7_SERVIC)
		// Dados endereço origem
		Self:oDmdEndOri:SetArmazem(SD7->D7_LOCDEST)
		Self:oDmdEndOri:SetEnder(SD7->D7_LOCALIZ)
		// Dados endereço destino
		Self:oDmdEndDes:SetArmazem(SD7->D7_LOCDEST)
	EndIf

	If lRet
		lRet := Self:AssignSD3()
	EndIf
Return lRet

//-------------------------------------------------
// Utilizado para integração com SD3 - Apontamento, Liberação CQ
//-------------------------------------------------
METHOD AssignSD3() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet     := .T.
Local aAreaAnt := GetArea()
Local cAliasQry:= Nil

	If (Empty(Self:GetDocto()) .Or. Empty(Self:cNumSeq))
		Self:cErro := STR0006 // Dados para busca não foram informados!
		lRet := .F.
	EndIf

	If lRet
		// Verifica se tabela n esta posicionada
		If !(xFilial("SD3")+Self:GetDocto()+Self:cNumSeq == SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ))
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SD3.R_E_C_N_O_ RECNOSD3
				FROM %Table:SD3% SD3
				WHERE SD3.D3_FILIAL = %xFilial:SD3%
				AND SD3.D3_DOC = %Exp:Self:GetDocto()%
				AND SD3.D3_NUMSEQ  = %Exp:Self:cNumSeq%
				AND SD3.D3_TM = '499'
				AND SD3.%NotDel%
			EndSql
			If (cAliasQry)->(Eof())
				Self:cErro := WmsFmtMsg(STR0012,{{"[VAR01]",Self:GetDocto()},{"[VAR02]",Self:cNumSeq}}) // "Documento: [VAR01] Número Sequencial: [VAR02] não encontrados! (SD3)"
				lRet := .F.
			Else
				SD3->(DbGoTo((cAliasQry)->RECNOSD3))
				If !Empty(SD3->D3_IDDCF)
					Self:cErro := STR0008 // Documento já possui D0Q Gerada
					lRet := .F.
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	EndIf
	If lRet
		Self:cStatus := "1"
		Self:cCF     := SD3->D3_CF
		Self:nQuant  := SD3->D3_QUANT
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
	If lRet .And. !Empty(Self:oDmdEndOri:GetEnder()) .And. !Self:oDmdEndOri:LoadData()
		Self:cErro := Self:oDmdEndOri:GetErro()
		lRet := .F.
	EndIf
	// Valida se o endereço destino preenchido
	If lRet .And. !Empty(Self:oDmdEndDes:GetEnder()) .And. !Self:oDmdEndDes:LoadData()
		Self:cErro := Self:oDmdEndDes:GetErro()
		lRet := .F.
	EndIf
	// Validação do serviço x endereço informado.
	If lRet .And. Self:oServico:HasOperac({'1','2'}) .And. Empty(Self:oDmdEndOri:GetEnder()) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
		Self:cErro := WmsFmtMsg(STR0010,{{"[VAR01]",Self:oServico:GetServico()},{"[VAR02]",Self:oServico:GetDesServ()}}) // Endereço origem não foi informado para o serviço: [VAR01] - [VAR02].
		lRet := .F.
	EndIf
	// Grava D0Q
	If lRet
		// Quando possui conferência de recebimento não gera D0Q novamente
		// Vai gerar a D0Q num momento posterior na função AssignDCW
		If Empty(Self:cCodRec)
			lRet := Self:RecordD0Q()
		EndIf
		// Gera saldo no endereço origem
		If lRet .And. Self:oServico:HasOperac({'1','2'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking
			If Self:lGeraSaldo
				// Grava saldo no endereço origem quando enderecamento
				lRet := Self:MakeArmaz()
				// Quando parametrizado que atualiza saldo a distribuir
				If lRet
					// Cria os saldos a distribuir
					lRet := Self:RecordD0G()
				EndIf
			Else
				lRet := Self:UpdateD0G()
			EndIf
		EndIf
		// Grava o ID da demanda de unitização na SD3
		If lRet .And. Empty(Self:cCodRec)
			// Grava o IDD0Q no SD3
			SD3->(dbSetOrder(8))
			SD3->(dbSeek(xFilial("SD3")+Self:cDocumento+Self:cNumSeq)) //D3_FILIAL+D3_DOC+D3_NUMSEQ
			Do While SD3->(!Eof()) .And. xFilial("SD3")+Self:cDocumento+Self:cNumSeq == SD3->(D3_FILIAL+D3_DOC+D3_NUMSEQ)
				If Self:oProdLote:GetProduto() == SD3->D3_COD
					RecLock("SD3",.F.)
					SD3->D3_IDDCF := Self:cIdD0Q
					SD3->(MsUnLock())
				EndIf
				SD3->(dbSkip())
			EndDo
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet
//-------------------------------------------------------------------------
// Utilizado para geração de demanda ao finalzar conferência de recebimento
//-------------------------------------------------------------------------
METHOD AssignDCW() CLASS WMSDTCDemandaUnitizacaoCreate
Local lRet      := .T.
Local aProdComp := {}
Local oProdComp := WMSDTCProdutoComponente():New()
Local cAliasQry := Nil
Local cAliasD0S := Nil
Local nQuant    := 0
Local nI        := 0
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT 'SD1' DMD_ORIGEM,
				SD1.D1_DOC DMD_DOCTO,
				SD1.D1_SERIE DMD_SERIE,
				SD1.D1_FORNECE DMD_FORNEC,
				SD1.D1_LOJA DMD_LOJA,
				SD1.D1_COD DMD_CODPRO,
				SD1.D1_LOTECTL DMD_LOTECTL,
				SD1.D1_NUMLOTE DMD_NUMLOTE,
				SD1.D1_QTDCONF DMD_QUANT,
				SD1.D1_NUMSEQ DMD_NUMSEQ,
				SD1.D1_LOCAL DMD_LOCAL,
				SD1.D1_ENDER DMD_ENDER,
				SD1.D1_SERVIC DMD_SERVIC,
				SD1.R_E_C_N_O_ RECNODOC,
				DCW.DCW_TPCONF DMD_TPCONF,
				DCW.DCW_EMBARQ DMD_EMBARQ,
				DCW.DCW_DATGER DMD_DATA,
				DCW.DCW_HORGER DMD_HORA,
				D0G.R_E_C_N_O_ RECNOD0G
		FROM %Table:DCX% DCX
		INNER JOIN %Table:SD1% SD1
		ON SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_DOC = DCX.DCX_DOC
		AND SD1.D1_SERIE = DCX.DCX_SERIE
		AND SD1.D1_FORNECE = DCX.DCX_FORNEC
		AND SD1.D1_LOJA = DCX.DCX_LOJA
		AND SD1.D1_QTDCONF > 0
		AND SD1.%NotDel%
		INNER JOIN %Table:NNR% NNR
		ON NNR.NNR_FILIAL = %xFilial:NNR%
		AND NNR.NNR_CODIGO = SD1.D1_LOCAL
		AND NNR.NNR_AMZUNI = '1'
		AND NNR.%NotDel%
		INNER JOIN %Table:DCW% DCW
		ON DCW.DCW_FILIAL = %xFilial:DCW%
		AND DCW.DCW_EMBARQ = DCX.DCX_EMBARQ
		AND DCW.%NotDel%
		LEFT JOIN %Table:D0G% D0G
		ON D0G.D0G_FILIAL = %xFilial:D0G%
		AND D0G.D0G_PRODUT = SD1.D1_COD
		AND D0G.D0G_LOCAL = SD1.D1_LOCAL
		AND D0G.D0G_NUMSEQ = SD1.D1_NUMSEQ
		AND D0G.D0G_DOC = SD1.D1_DOC
		AND D0G.D0G_SERIE = SD1.D1_SERIE
		AND D0G.D0G_CLIFOR = SD1.D1_FORNECE
		AND D0G.D0G_LOJA = SD1.D1_LOJA
		AND D0G.%NotDel%
		WHERE DCX.DCX_FILIAL = %xFilial:DCX%
		AND DCX.DCX_EMBARQ = %Exp:Self:cCodRec%
		AND DCX.%NotDel%
		UNION ALL
		SELECT 'SD3' DMD_ORIGEM,
				SD3.D3_DOC DMD_DOCTO,
				' ' DMD_SERIE,
				' ' DMD_FORNEC,
				' ' DMD_LOJA,
				SD3.D3_COD DMD_CODPRO,
				SD3.D3_LOTECTL DMD_LOTECTL,
				SD3.D3_NUMLOTE DMD_NUMLOTE,
				SD3.D3_QUANT DMD_QUANT,
				SD3.D3_NUMSEQ DMD_NUMSEQ,
				SD3.D3_LOCAL DMD_LOCAL,
				(   SELECT MIN(D0R.D0R_ENDER)
					FROM %Table:DCZ% DCZ
					INNER JOIN %Table:D0R% D0R
					ON D0R.D0R_FILIAL = %xFilial:D0R%
					AND D0R.D0R_LOCAL = DCZ.DCZ_LOCAL
					AND D0R.D0R_IDUNIT = DCZ.DCZ_IDUNIT
					AND D0R.%NotDel%
					WHERE DCZ.DCZ_FILIAL = %xFilial:DCZ%
					AND DCZ.DCZ_EMBARQ = SD3.D3_IDENT
					AND DCZ.DCZ_LOCAL = SD3.D3_LOCAL
					AND DCZ.%NotDel% ) DMD_ENDER,
				SD3.D3_SERVIC DMD_SERVIC,
				SD3.R_E_C_N_O_ RECNODOC,
				DCW.DCW_TPCONF DMD_TPCONF,
				DCW.DCW_EMBARQ DMD_EMBARQ,
				DCW.DCW_DATGER DMD_DATA,
				DCW.DCW_HORGER DMD_HORA,
				D0G.R_E_C_N_O_ RECNOD0G
		FROM %Table:SD3% SD3
		INNER JOIN %Table:NNR% NNR
		ON NNR.NNR_FILIAL = %xFilial:NNR%
		AND NNR.NNR_CODIGO = SD3.D3_LOCAL
		AND NNR.NNR_AMZUNI = '1'
		AND NNR.%NotDel%
		INNER JOIN %Table:DCW% DCW
		ON DCW.DCW_FILIAL = %xFilial:DCW%
		AND DCW.DCW_EMBARQ = SD3.D3_IDENT
		AND DCW.%NotDel%
		LEFT JOIN %Table:D0G% D0G
		ON D0G.D0G_FILIAL = %xFilial:D0G%
		AND D0G.D0G_PRODUT = SD3.D3_COD
		AND D0G.D0G_LOCAL = SD3.D3_LOCAL
		AND D0G.D0G_NUMSEQ = SD3.D3_NUMSEQ
		AND D0G.D0G_DOC = SD3.D3_DOC
		AND D0G.%NotDel%
		WHERE SD3.D3_FILIAL = %xFilial:SD3%
		AND SD3.D3_IDENT = %Exp:Self:cCodRec%
		AND SD3.D3_DOC LIKE '%CEX%' // Para garantir que é uma movimentação de excesso de conferência
		AND SD3.D3_ESTORNO = ' '
		AND SD3.%NotDel%"
	EndSql
	TcSetField(cAliasQry,'DMD_DATA','D')
	Do While (cAliasQry)->(!EoF()) .And. lRet
		Self:oServico:SetServico((cAliasQry)->DMD_SERVIC)
		Self:oProdLote:SetProduto((cAliasQry)->DMD_CODPRO)
		Self:oProdLote:SetPrdOri((cAliasQry)->DMD_CODPRO)
		Self:oProdLote:SetLoteCtl((cAliasQry)->DMD_LOTECTL)
		Self:oProdLote:SetNumLote((cAliasQry)->DMD_NUMLOTE)
		Self:oDmdEndOri:SetArmazem((cAliasQry)->DMD_LOCAL)
		Self:oDmdEndOri:SetEnder((cAliasQry)->DMD_ENDER)
		Self:cOrigem    := (cAliasQry)->DMD_ORIGEM
		Self:cDocumento := (cAliasQry)->DMD_DOCTO
		Self:cSerie     := (cAliasQry)->DMD_SERIE
		Self:cCliFor    := (cAliasQry)->DMD_FORNEC
		Self:cLoja      := (cAliasQry)->DMD_LOJA
		Self:cNumSeq    := (cAliasQry)->DMD_NUMSEQ
		Self:nQuant     := (cAliasQry)->DMD_QUANT
		Self:nQtdUni    := (cAliasQry)->DMD_QUANT
		Self:cStatus    := '3'
		Self:dData      := (cAliasQry)->DMD_DATA
		If Self:lHasHora
			Self:cHora      := (cAliasQry)->DMD_HORA
		EndIf
		//Grava D0Q
		lRet := Self:RecordD0Q()
		//Atualiza SD1_IDDCF com a demanda gerada
		If lRet .And. (cAliasQry)->DMD_ORIGEM = 'SD1'
			SD1->(DbGoTo((cAliasQry)->RECNODOC))
			RecLock("SD1",.F.)
			SD1->D1_IDDCF := Self:cIdD0Q
			SD1->(MsUnLock())
		EndIf
		//Atualiza SD3_IDDCF com a demanda gerada
		If lRet .And. (cAliasQry)->DMD_ORIGEM = 'SD3'
			SD3->(DbGoTo((cAliasQry)->RECNODOC))
			RecLock("SD3",.F.)
			SD3->D3_IDDCF := Self:cIdD0Q
			SD3->(MsUnLock())
		EndIf
		//Atualiza D0G_IDDCF com o ID da demanda gerada, para possibiliar a "baixa" do saldo a distribuir no finalização da movimentação
		If lRet .And. (cAliasQry)->DMD_TPCONF == "2"  .And. !Empty((cAliasQry)->RECNOD0G)
			D0G->(DbGoTo((cAliasQry)->RECNOD0G))
			RecLock("D0G",.F.)
			D0G->D0G_IDDCF := Self:cIdD0Q
			D0G->(MsUnLock())
		EndIf
		If lRet
			oProdComp:SetProduto((cAliasQry)->DMD_CODPRO)
			oProdComp:SetPrdOri((cAliasQry)->DMD_CODPRO)
			oProdComp:EstProduto()
			aProdComp := oProdComp:GetArrProd()
			For nI := 1 To Len(aProdComp)
				//Atualiza os itens do unitizador (D0V) com o ID da demanda gerada (D0Q)
				nQuant := (cAliasQry)->DMD_QUANT * aProdComp[nI][2]
				cAliasD0S := GetNextAlias()
				BeginSql Alias cAliasD0S
					SELECT D0S.D0S_IDUNIT,
							D0S.D0S_PRDORI,
							D0S.D0S_CODPRO,
							D0S.D0S_LOTECT,
							D0S.D0S_NUMLOT,
							D0S.D0S_CODOPE,
							D0S.D0S_QUANT,
							D0S.D0S_ENDREC,
							D0S.R_E_C_N_O_ RECNOD0S
					FROM %Table:DCZ% DCZ
					INNER JOIN %Table:D0S% D0S
					ON D0S.D0S_FILIAL = %xFilial:D0S%
					AND D0S.D0S_IDUNIT = DCZ.DCZ_IDUNIT
					AND D0S.D0S_PRDORI = DCZ.DCZ_PRDORI
					AND D0S.D0S_CODPRO = DCZ.DCZ_PROD
					AND D0S.D0S_LOTECT = DCZ.DCZ_LOTE
					AND D0S.D0S_NUMLOT = DCZ.DCZ_SUBLOT
					AND D0S.D0S_IDD0Q  = ' '
					AND D0S.%NotDel%
					WHERE DCZ.DCZ_FILIAL = %xFilial:DCZ%
					AND DCZ.DCZ_EMBARQ = %Exp:(cAliasQry)->DMD_EMBARQ%
					AND DCZ.DCZ_PRDORI = %Exp:(cAliasQry)->DMD_CODPRO%
					AND D0S.D0S_CODPRO = %Exp:aProdComp[nI][1]%
					AND DCZ.DCZ_LOTE = %Exp:(cAliasQry)->DMD_LOTECTL%
					AND DCZ.DCZ_SUBLOT = %Exp:(cAliasQry)->DMD_NUMLOTE%
					AND DCZ.DCZ_LOCAL  = %Exp:(cAliasQry)->DMD_LOCAL%
					AND DCZ.%NotDel%
				EndSql
				Do While (cAliasD0S)->(!EoF()) .And. QtdComp(nQuant) > 0
					If QtdComp((cAliasD0S)->D0S_QUANT) <= QtdComp(nQuant)
						//Grava ID da demanda para o unitizador
						D0S->(DbGoTo((cAliasD0S)->RECNOD0S))
						RecLock("D0S",.F.)
						D0S->D0S_IDD0Q := Self:cIdD0Q
						D0S->(MsUnlock())
						//Desconta quantidade atendida
						nQuant -= (cAliasD0S)->D0S_QUANT
					Else
						//Grava ID da demanda para o unitizador
						D0S->(DbGoTo((cAliasD0S)->RECNOD0S))
						RecLock("D0S",.F.)
						D0S->D0S_IDD0Q := Self:cIdD0Q
						D0S->D0S_QUANT := nQuant
						D0S->(MsUnlock())
						//Cria nova linha de unitizador para a quantidade restante
						Reclock('D0S',.T.)
						D0S->D0S_FILIAL := xFilial("D0S")
						D0S->D0S_IDUNIT := (cAliasD0S)->D0S_IDUNIT
						D0S->D0S_CODPRO := (cAliasD0S)->D0S_CODPRO
						D0S->D0S_LOTECT := (cAliasD0S)->D0S_LOTECT
						D0S->D0S_NUMLOT := (cAliasD0S)->D0S_NUMLOT
						D0S->D0S_QUANT  := (cAliasD0S)->D0S_QUANT - nQuant
						D0S->D0S_PRDORI := (cAliasD0S)->D0S_PRDORI
						D0S->D0S_CODOPE := (cAliasD0S)->D0S_CODOPE
						D0S->D0S_ENDREC := (cAliasD0S)->D0S_ENDREC
						D0S->D0S_IDD0Q  := ""
						D0S->(MsUnLock())
						//Zera quantidade restante para finalizar o rateio
						nQuant := 0
					EndIf
					(cAliasD0S)->(DbSkip())
				EndDo
				(cAliasD0S)->(DbCloseArea())
			Next nI
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
Return lRet
