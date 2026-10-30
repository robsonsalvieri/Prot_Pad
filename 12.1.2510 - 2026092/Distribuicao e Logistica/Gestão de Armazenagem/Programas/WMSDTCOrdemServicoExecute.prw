#Include "Totvs.ch"
#Include "WMSDTCOrdemServicoExecute.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0032
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0032()
Return Nil

//-----------------------------------------------
/*/{Protheus.doc} WMSDTCOrdemServicoExecute
Classe execução da ordem de serviço
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------------
CLASS WMSDTCOrdemServicoExecute FROM WMSDTCOrdemServico
	// Data
	DATA aRecD12    As array
	DATA aWmsReab   As array
	DATA aLogSld    As array
	DATA aLogEnd    As array
	DATA aLogEndUni As Array
	DATA aOrdAglu   As Array
	DATA aLstUnit   As array
	DATA aRecDCF    As array
	DATA aReabD12   As array
	// Method
	METHOD New() CONSTRUCTOR
	METHOD GetLogUni()
	METHOD GetLogEnd()
	METHOD GetLogSld()
	METHOD ChecaPrior()
	METHOD ExecuteDCF()
	METHOD ExecuteUni()
	METHOD ExecutePrd()
	METHOD ExeDistPrd()
	METHOD AgluOSEnd()
	METHOD AgluOSTrf()
	METHOD AgluOSExp()
	METHOD ExecDesmon()
	METHOD VldOrdEnd()
	METHOD VldAgluOS()
	METHOD UpdateEnd()
	METHOD UpdEndOri(cNewEnd)
	METHOD UpdEndDes(cNewEnd)
	METHOD Destroy()
	METHOD WmsTrocDes()
ENDCLASS

//-----------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD New() CLASS WMSDTCOrdemServicoExecute
	_Super:New()
	Self:aLibD12    := Nil
	Self:aRecD12    := {}
	Self:aWmsReab   := {}
	Self:aLogEnd    := {}
	Self:aLogSld    := {}
	Self:aLogEndUni := {}
	Self:aOrdAglu   := {}
	Self:aLstUnit   := {}
	Self:aRecDCF    := {}
	Self:aReabD12   := {}
Return

METHOD Destroy() CLASS WMSDTCOrdemServicoExecute
	//Mantido para compatibilidade
Return

//-----------------------------------------------
/*/{Protheus.doc} GetLogUni
Retorna log de enderecamento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD GetLogUni() CLASS WMSDTCOrdemServicoExecute
Return Self:aLogEndUni

//-----------------------------------------------
/*/{Protheus.doc} GetLogEnd
Retorna log de endereços
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD GetLogEnd() CLASS WMSDTCOrdemServicoExecute
Return Self:aLogEnd

//-----------------------------------------------
/*/{Protheus.doc} GetLogSld
Retorna o log de saldos
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD GetLogSld() CLASS WMSDTCOrdemServicoExecute
Return Self:aLogSld

//-----------------------------------------------
/*/{Protheus.doc} ChecaPrior
Checa a prioridade
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD ChecaPrior() CLASS WMSDTCOrdemServicoExecute
Local lRet       := .T.
Local cCont      := ""
Local cError     := ""
Local cParam     := SuperGetMv("MV_WMSPRIO",.F.,"")
Local aTamSx3    := TamSx3("D12_PRIORI")
Local oLastError := ErrorBlock({|e| cError := e:Description + e:ErrorStack})
Local aAreaD12   := D12->(GetArea())
	dbSelectArea("D12")
	D12->(dbGoTop())
	cCont := &cParam

	If !Empty(cError)
		lRet := .F.
		Self:cErro := STR0002 // Valor inválido rever parâmetro MV_WMSPRIO (Sequência de Prioridade).
	EndIf
	// Deve ser menor que o tamanho do campo menos as 4 posições fixas ZZ + (Parametro) + XX
	If lRet .And. Len(cCont) > aTamSx3[1]-4
		lRet := .F.
		Self:cErro := WmsFmtMsg(STR0003,{{"[VAR01]",LTrim(Str(aTamSx3[1]-4))}}) // Quantidade de caracteres da expressão configurada no parâmetro MV_WMSPRIO (Sequência de Prioridade) é maior que [VAR01].
	EndIf
	ErrorBlock(oLastError)
	If !lRet
		AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) //"SIGAWMS - OS [VAR01] - Produto: [VAR02]"
	EndIf
	RestArea(aAreaD12)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ExecuteDCF
Execução da ordem de serviço
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD ExecuteDCF() CLASS WMSDTCOrdemServicoExecute
Local lRet       := .T.
Local nCont      := 0
Local cMessError := ""
Local nRecnoAnt  := Self:GetRecno()
Local lHasTransf := .F.
Local oEtiqUnit  := Nil
Local oBlqSaldo  := Nil
Local cWMSACEX   := SuperGetMv("MV_WMSACEX",.F.,"0")

	// Desconsidera ordens de serviço já executadas, não retorna o erro devido os casos de aglutinação de documento
	// Desconsidera ordens de serviço que estão marcadas como executadas durante um mesmo processamento - aglutinação
	If Self:cStServ == '3' .Or. !Empty(Self:cStRadi)
		Return .T.
	EndIf
	If lRet .And. Self:LockDCF()
		WmsConout('ExecuteDCF Início DCF ' + Self:cIdDCF + ' ' + Self:oProdLote:GetProduto() + ' ' + Self:cCarga)

		If Self:cStServ == '3' .Or. !Empty(Self:cStRadi)
			Return .T.
		EndIf

		// Verifica servico com conferencia de entrada
		If Self:oServico:HasOperac({'6'})
			If !Self:oServico:ChkConfOrd(1)
				Self:cErro := STR0013 //Tarefa de conferência de entrada deve ser configurada antes das tarefas WMS Padrão!
				lRet := .F.
			EndIf

			If Self:IsMovUnit()
				Self:cErro := STR0018 //Não é permitida, em armazéns unitizados, a execução de serviço com tarefa de conferência. Altere o serviço da ordem de serviço para permitir a execução.
				lRet := .F.
			EndIf
		EndIf
		// Verifica servico com conferencia de saída
		If lRet .And. Self:oServico:HasOperac({'7'})
			If !Self:oServico:ChkConfOrd(2)
				Self:cErro := STR0014 //Tarefa de conferência de saída deve ser configurada depois das tarefas WMS Padrão de expedição!
				lRet := .F.
			EndIf
		EndIf
		// Valida bloqueio produto (B1_MSBLQL) somente se não for endereçamento ou transferência unitizada
		If lRet .And. (Self:oServico:ChkRecebi() .Or. Self:oServico:ChkTransf()) .And. !Self:IsMovUnit() .And. !WmsSB1Blq(Self:oProdLote:GetProduto(),@cMessError)
			Self:cErro := cMessError
			lRet := .F.
		EndIf
		If lRet .And. !(Self:cStServ $ '1|2')
			lRet := .F.
			Self:cErro := WmsFmtMsg(STR0008,{{"[VAR01]",Self:cStServ}}) // Situação ([VAR01]) da ordem de serviço não permite que seja executada!
		EndIf
		// Verifica endereço
		If lRet .And. !Self:VldOrdEnd()
			Self:cErro := WmsFmtMsg(STR0009,{{"[VAR01]",IIf(Self:oServico:HasOperac({'3','4'}),STR0010,STR0011)}}) // Endereço [VAR01] não informado! // destino // origem
			lRet := .F.
		EndIf
		// Verifica parametro prioridade
		If lRet .And. !Self:ChecaPrior()
			lRet := .F.
		EndIf
		// Verifica se há documentos originados desse documento que ainda estejam pendentes
		If lRet .And. Self:ChkDepPend()
			lRet := .F.
		EndIf
		//Valida se o tipo do unitizador está preenchido na tabela de etiqueta
		lHasTransf := Self:oServico:HasOperac({'8'})
		If WmsX212118("D0Y")
			If lRet .And. lHasTransf .And. !Empty(Self:cUniDes)
				oEtiqUnit := WMSDTCEtiquetaUnitizador():New()
				oEtiqUnit:SetIdUnit(Self:cUniDes)
				If oEtiqUnit:LoadData()
					If Empty(oEtiqUnit:GetTipUni())
						Self:cErro := WmsFmtMsg(STR0016,{{"[VAR01]",Self:cUniDes}}) //Unitizador destino da OS [VAR01] não possui tipo definido.
						lRet := .F.
					EndIf
				Else
					Self:cErro := WmsFmtMsg(STR0017,{{"[VAR01]",Self:cUniDes}}) // Etiqueta do unitizador [VAR01] não gerada!
					lRet := .F.
				EndIf
				FreeObj(oEtiqUnit)
			EndIf
		EndIf
		If lRet
			// Se for endereçamento unitizado sem informar endereço destino, deve aglutinar as ordens de serviço selecionadas para execução
			If Self:IsMovUnit() .And. Empty(Self:oOrdEndDes:GetEnder())
				lRet := Self:AgluOSEnd()
			// Se for uma transferência com unitizador destino, porém não possui endereço definido
			// Deve executar como se fosse um endereçamento unitizado, mesmo possuindo o produto informado
			ElseIf lHasTransf .And. !Empty(Self:cUniDes) .And. Empty(Self:oOrdEndDes:GetEnder())
				lRet := Self:AgluOSTrf()
			Else
				If ExistBlock("WMSACEXN")
					cWMSACEX := ExecBlock('WMSACEXN',.F.,.F.,{Self:CIdDcf})
				EndIf
				// Se for um serviço de expedição, verifica se está parametrizado para gerar ordens de serviço aglutinadas na expedição
				If (Self:oServico:GetTipo() == '2' .And. cWMSACEX <> '0' .And. WmsCarga(Self:GetCarga())) .Or. !Empty(Self:GetCodPln())
					lRet := Self:AgluOSExp()
				EndIf
			EndIf
			If lRet
				// Atualiza status do serviço quando não está aglutinado
				If Empty(Self:aRecDCF)
					Self:SetStServ('2')
					Self:SetOk("")
					Self:UpdateDCF(.F.) // Para não liberar o lock
					Self:UpdStatus()
					Wmsconout('ExecuteDCF Atualização StServ DCF não aglutinado - .' + Self:cIdDCF)
				EndIf
			EndIf

			WMSCTPENDU() // Cria as temporárias - FORA DA TRANSAÇÃO

			Begin Transaction
				// Carrega os produtos a serem geradas as movimentacoes
				If (Self:oServico:ChkRecebi() .Or. Self:oServico:ChkTransf()) .And. Self:IsMovUnit() .Or. (lHasTransf .And. !Empty(Self:cUniDes) .And. Empty(Self:oOrdEndDes:GetEnder()))
					lRet := Self:ExecuteUni()
				ElseIf Self:oServico:ChkRecebi() .And. Self:ChkDistr()
					lRet := Self:ExeDistPrd()
				Else
					lRet := Self:ExecutePrd()
				EndIf
				//Gera D0U, SDD e SDC para bloqueio de saldo
				If lRet .And. Self:oServico:ChkRecebi() .And. Self:oServico:ChkBlqSld()
					oBlqSaldo := WMSDTCBloqueioSaldoItens():New()
					oBlqSaldo:SetOrdServ(Self)
					lRet := oBlqSaldo:AssignSDD()
				EndIf

				//Verifica se as informações criadas estão corretas
				//Validação é feita antes de limpar os registros de aOrdAglu
				If lRet
					If !Self:VldAgluOS(@cMessError)
						Self:cErro := cMessError
						lRet := .F.
					EndIf
				EndIf

				If lRet
					// Carrega os movimentos criados
					For nCont := 1 To Len(Self:aRecD12)
						AAdd(Self:aLibD12,Self:aRecD12[nCont])
					Next
					// Carrega os movimentos criados de reabastecimento por percentual de reposição 
					For nCont := 1 To Len(Self:aReabD12)
						AAdd(Self:aLibD12,Self:aReabD12[nCont])
				    Next

					Self:aRecD12:= {}
					Self:aReabD12:= {}
					// Quando documentos aglutinados
					If Len(Self:aRecDCF) > 0
						WmsConout('ExecuteDCF Atualização StServ / StRadi aglutinado')
						Self:UpdAgluDCF({{'DCF_STSERV','3'},{'DCF_STRADI',' '}})
						Self:UpdAgluSta('3')

						Self:aRecDCF  := {}
						Self:aLstUnit := {}
						Self:aOrdAglu := {}
					Else
						// Atualiza status
						WmsConout('ExecuteDCF Atualização StServ / StRadi não aglutinado')
						Self:SetStServ('3')
						Self:cStRadi := ' '
						Self:UpdateDCF()
						Self:UpdStatus()
					EndIf
				EndIf

				If !lRet
					Self:aRecD12:= {}
					Self:aReabD12 := {}
					Self:aRecDCF  := {}
					Self:aLstUnit := {}
					Self:aOrdAglu := {}
					DisarmTransaction()
				EndIf
			End Transaction

			WMSDTPENDU() // Destroy as temporárias - FORA DA TRANSAÇÃO

		EndIf
		If !lRet
			If Self:IsMovUnit()
				AADD(Self:aWmsAviso, WmsFmtMsg(STR0015,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:cIdUnitiz}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Unitizador: [VAR02]
			Else
				AADD(Self:aWmsAviso, WmsFmtMsg(STR0001,{{"[VAR01]",Self:GetDocto()+Iif(!Empty(Self:GetSerie()),"/"+AllTrim(Self:GetSerie()),'')},{"[VAR02]",Self:oProdLote:GetProduto()}}) + CRLF +Self:GetErro()) // SIGAWMS - OS [VAR01] - Produto: [VAR02]
			EndIf
		EndIf
		Self:UnLockDCF()

		WmsConout('ExecuteDCF Fim DCF ' + Self:cIdDCF)

	Else
		lRet := .F.
	EndIf

	IIF(oBlqSaldo != Nil, FreeObj(oBlqSaldo), Nil)

Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ExecuteUni
Execução do endereçamento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD ExecuteUni() CLASS WMSDTCOrdemServicoExecute
Local lRet    := .T.
Local oFuncao := Nil
Local nI      := 1
	// Se for transferência ou endereçamento sem informar endereço destino
	If Empty(Self:oOrdEndDes:GetEnder())
		// Instacia o objeto da classe de enderecamento unitizado
		oFuncao := WMSBCCEnderecamentoUnitizado():New()
		oFuncao:SetLstUnit(Self:aLstUnit)
		oFuncao:SetLogEnd(Self:aLogEndUni)
	Else
		oFuncao := WMSBCCTransferencia():New()
		oFuncao:SetIdUnit(Self:cIdUnitiz)
		oFuncao:SetUniDes(Self:cUniDes)
	EndIf
	// Carrega Servico x Tarefa
	Self:oServico:LoadData()
	// Atribui Demais Dados
	oFuncao:SetOrdServ(Self)
	oFuncao:SetQuant(Self:nQuant)
	oFuncao:SetRecD12(Self:aRecD12)
	If !oFuncao:ExecFuncao()
		Self:cErro := oFuncao:GetErro()
		lRet := .F.
	EndIf
	// Se o endereço não estiver preenchido, passou pelo processo de aglutinação de OS
	// Por isso deve guardar o registro no array de recnos para atualização de status
	If Empty(Self:oOrdEndDes:GetEnder())
		// Faz o repasse do status da execução para o array de DCFs
		For nI := 1 To Len(Self:aLstUnit)
			Self:aRecDCF[nI][2] := Self:aLstUnit[nI][3]
		Next
	EndIf
	FreeObj(oFuncao)
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} ExecutePrd
Execução produto
@author felipe.m
@since 23/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//-----------------------------------------------
METHOD ExecutePrd() CLASS WMSDTCOrdemServicoExecute
Local lRet       := .T.
Local aProduto   := {}
Local aTarefa    := {}
Local nProdAux   := 0
Local nTarAux    := 0
Local nIdDCFAux  := 0
Local oFuncao    := Nil
	aProduto := Self:oProdLote:GetArrProd()
	Self:oServico:ServTarefa()
	aTarefa  := Self:oServico:GetArrTar()

	//Reserva os campos para as quantidades das atividades
	If !Empty(Self:aOrdAglu)
		For nIdDCFAux := 1 To Len(Self:aOrdAglu)
			For nProdAux := 1 To Len(aProduto)
				AAdd(Self:aOrdAglu[nIdDCFAux][5],{})
				For nTarAux := 1 To Len(aTarefa)
					AAdd(Self:aOrdAglu[nIdDCFAux][5][nProdAux],{Self:aOrdAglu[nIdDCFAux][2] * aProduto[nProdAux][2],0,'',0})
				Next
			Next
		Next
	EndIf
	// Produtos
	For nProdAux := 1 To Len(aProduto)
		Self:nProduto := nProdAux
		// Atribui quantidade multipla
		nQuant := (QtdComp(Self:nQuant * aProduto[Self:nProduto][2]) )
		WmsConout('Nova quantidade multipla produto indice: ' + cValToChar(nProdAux) + ' ' + cValToChar(nQuant))
		// Tarefas
		For nTarAux := 1 To Len(aTarefa)
			Self:nProduto := nProdAux //Recuperando posicao do produto

			Self:nTarefa := nTarAux
			// Atribui para oMovimento - oServico a ordem
			Self:oServico:SetOrdem(aTarefa[Self:nTarefa][1])
			Self:oServico:LoadData()
			// Quando informado a ordem da tarefa poderão ser utilizadas as checagens de operação
			// Cria classe para regra derminada
			Do Case
				// Valida se é endereçamento, endereçamento crossdocking, transferencia, desfragmentação
				Case Self:oServico:ChkRecebi() .Or. Self:oServico:ChkTransf()
					// Valida se endereço destino informado
					If Self:ChkMovEst(.F.)
						oFuncao := WMSBCCTransferencia():New()
					Else
						oFuncao := WMSBCCEnderecamento():New()
						oFuncao:SetLogEnd(Self:aLogEnd)
					EndIf
				// Valida se é conferencia de endereçamento
				Case Self:oServico:ChkConfEnt()
					oFuncao := WMSBCCConferenciaEntrada():New()
				// Valida se é conferencia de expedição
				Case Self:oServico:ChkConfSai()
					oFuncao := WMSBCCConferenciaSaida():New()
				// Valida se é processo de expedição
				Case Self:oServico:ChkSepara()
					//---------------------------------------
					// Trata os itens filhos dentro da classe
					//---------------------------------------
					If Self:nProduto > 1 .And. !Self:ChkMovEst()
						Loop
					EndIf
					//--------------------------------------------
					// Valida se endereço origem informado
					// Somente para produtos sem componente,
					// onde é digitado o endereço origem no pedido
					//--------------------------------------------
					If Self:ChkMovEst()
						oFuncao := WMSBCCTransferencia():New()
					Else
						oFuncao := WMSBCCSeparacao():New()
						oFuncao:SetContPrd(Self:nProduto)
						oFuncao:SetLogSld(Self:aLogSld)
						oFuncao:SetWmsReab(Self:aWmsReab)
					EndIf
				// Valida se é processo de reabastecimento
				Case Self:oServico:ChkReabast()
					oFuncao := WMSBCCAbastecimento():New()
				Otherwise
					oFuncao := WMSBCCCustomizacao():New()
			EndCase
			If lRet
				// Atribui o produto origem ao movimento
				// Atribui para oMovimento produto/lote/sub-lote
				oFuncao:oMovPrdLot:SetArmazem(Self:oProdLote:GetArmazem())
				oFuncao:oMovPrdLot:SetPrdOri(Self:oProdLote:GetPrdOri())
				oFuncao:oMovPrdLot:SetProduto(aProduto[Self:nProduto][1])
				oFuncao:oMovPrdLot:SetLoteCtl(Self:oProdLote:GetLoteCtl())
				oFuncao:oMovPrdLot:SetNumLote(Self:oProdLote:GetNumLote())
				oFuncao:oMovPrdLot:SetNumSer(Self:oProdLote:GetNumSer())
				oFuncao:oMovPrdLot:LoadData()
				// Valida possui segunda unidade de medida
				// e se possui fator de conversão
				If !oFuncao:oMovPrdLot:oProduto:oProdGen:ChkFatConv()
					Self:cErro  := oFuncao:oMovPrdLot:oProduto:oProdGen:GetErro()
					lRet := .F.
				EndIf
				If lRet
					// Atribui Demais Dados
					oFuncao:SetOrdServ(Self)
					oFuncao:SetQuant(nQuant)
					oFuncao:SetRecD12(Self:aRecD12)
					oFuncao:SetOrdAglu(Self:aOrdAglu)
					oFuncao:oOrdServ:nProduto := Self:nProduto
					oFuncao:oOrdServ:nTarefa := Self:nTarefa
					oFuncao:SetIdUnit(Self:cIdUnitiz)
					oFuncao:SetTipUni(Self:cTipUni)
					oFuncao:SetUniDes(Self:cUniDes)
					If !oFuncao:ExecFuncao()
						Self:cErro := oFuncao:GetErro()
						lRet := .F.
					Else
						//alimenta array com movimentos de reabastecimento por percentual de reposição.
						If AttIsMemberOf(oFuncao,"aReabD12",.T.) .AND. !Empty(oFuncao:GetReabD12())
							Self:aReabD12 := oFuncao:GetReabD12()
						EndIf
					EndIf
				EndIf
			EndIf
			// Erro sai do for
			If !lRet
				Exit
			EndIf
		Next
		// Erro sai do for
		If !lRet
			Exit
		EndIf
	Next
	If oFuncao != Nil
		FreeObj(oFuncao)
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} AgluOSEnd
Aglutina ordens de serviço de endereçamento unitizado
@author  Guilherme A. Metzger
@since   27/04/2017
@version 1.0
/*/
//-----------------------------------------------
METHOD AgluOSEnd() CLASS WMSDTCOrdemServicoExecute
Local lRet      := .T.
Local cAliasQry := Nil
Local cPrdVazio := Space(TamSX3("DCF_CODPRO")[1])
Local cEndVazio := Space(TamSX3("DCF_ENDDES")[1])
Local cUniVazio := Space(TamSX3("DCF_UNITIZ")[1])
Local nCont     := 1
	//Grava no array a OS que encontra-se posicionada, que não será considerada pelo SELECT
	AAdd(Self:aLstUnit,{Self:cIdUnitiz,Self:GetRecno(),.F.})
	AAdd(Self:aRecDCF ,{Self:GetRecno(),.F.})
	//Busca ordens de serviços semelhantes para serem aglutinadas
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_UNITIZ,
				DCF.DCF_ID,
				DCF.R_E_C_N_O_ RECNODCF
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:Self:oServico:GetServico()%
		AND DCF.DCF_CODPRO = %Exp:cPrdVazio%
		AND DCF.DCF_LOCDES = %Exp:Self:oOrdEndDes:GetArmazem()%
		AND DCF.DCF_ENDER = %Exp:Self:oOrdEndOri:GetArmazem()%
		AND DCF.DCF_OK = %Exp:Self:cOk%
		AND DCF.DCF_ENDDES = %Exp:cEndVazio%
		AND DCF.DCF_UNITIZ <> %Exp:cUniVazio%
		AND DCF.DCF_STSERV <> '3'
		AND DCF.DCF_STRADI = ' '
		AND DCF.R_E_C_N_O_ <> %Exp:AllTrim(Str(Self:GetRecno()))%
		AND DCF.%NotDel%
	EndSql
	Do While !(cAliasQry)->(Eof())
		// Caso alguma ordem de serviço da carga não esteja disponível para execução não aglutina
		If Self:ChkDepPend((cAliasQry)->DCF_ID)
			lRet := .F.
			Exit
		EndIf
		// Salva o registro na lista de ordens de serviço unitizadas
		AAdd(Self:aLstUnit,{(cAliasQry)->DCF_UNITIZ,(cAliasQry)->RECNODCF,.F.})
		// Salva o recno no array para posterior atualização de status
		AAdd(Self:aRecDCF ,{(cAliasQry)->RECNODCF,.F.})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Seta o status das ordens de serviço para Interrompido
	If Len(Self:aRecDCF) > 0
		For nCont := 1 To Len(Self:aRecDCF)
			Self:GoToDCF(Self:aRecDCF[nCont][1])
			Self:SetStServ('2')
			Self:SetOk("")
			Self:cStRadi := '1'
			Self:UpdateDCF(.F.) // Para não liberar o lock
		Next
	EndIf
	//Ordena o array pelo IDDCF
	ASort(Self:aLstUnit, , , {|x,y|x[1] < y[1]})
Return lRet

METHOD AgluOSTrf() CLASS WMSDTCOrdemServicoExecute
Local lRet      := .T.
Local cAliasQry := Nil
Local cPrdVazio := Space(TamSX3("DCF_CODPRO")[1])
Local cEndVazio := Space(TamSX3("DCF_ENDDES")[1])
Local cUniVazio := Space(TamSX3("DCF_UNITIZ")[1])
Local nCont     := 1

	//Grava no array a OS que encontra-se posicionada, que não será considerada pelo SELECT
	AAdd(Self:aLstUnit,{Self:cUniDes,Self:GetRecno(),.F.})
	AAdd(Self:aRecDCF ,{Self:GetRecno(),.F.})
	//Busca ordens de serviços semelhantes para serem aglutinadas
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_UNIDES,
				DCF.DCF_ID,
				DCF.R_E_C_N_O_ RECNODCF
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:Self:oServico:GetServico()%
		AND DCF.DCF_CODPRO <> %Exp:cPrdVazio%
		AND DCF.DCF_LOCDES = %Exp:Self:oOrdEndDes:GetArmazem()%
		AND DCF.DCF_ENDER = %Exp:Self:oOrdEndOri:GetArmazem()%
		AND DCF.DCF_OK = %Exp:Self:cOk%
		AND DCF.DCF_ENDDES = %Exp:cEndVazio%
		AND DCF.DCF_UNIDES <> %Exp:cUniVazio%
		AND DCF.DCF_STSERV <> '3'
		AND DCF.DCF_STRADI = ' '
		AND DCF.R_E_C_N_O_ <> %Exp:AllTrim(Str(Self:GetRecno()))%
		AND DCF.%NotDel%
	EndSql
	Do While !(cAliasQry)->(Eof())
		// Caso alguma ordem de serviço da carga não esteja disponível para execução não aglutina
		If Self:ChkDepPend((cAliasQry)->DCF_ID)
			lRet := .F.
			Exit
		EndIf
		// Salva o registro na lista de ordens de serviço unitizadas
		AAdd(Self:aLstUnit,{(cAliasQry)->DCF_UNIDES,(cAliasQry)->RECNODCF,.F.})
		// Salva o recno no array para posterior atualização de status
		AAdd(Self:aRecDCF ,{(cAliasQry)->RECNODCF,.F.})
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	// Seta o status das ordens de serviço para Interrompido
	If Len(Self:aRecDCF) > 0
		For nCont := 1 To Len(Self:aRecDCF)
			Self:GoToDCF(Self:aRecDCF[nCont][1])
			Self:SetStServ('2')
			Self:SetOk("")
			Self:cStRadi := '1'
			Self:UpdateDCF(.F.) // Para não liberar o lock
		Next
	EndIf
	//Ordena o array pelo IDDCF
	ASort(Self:aLstUnit, , , {|x,y|x[1] < y[1]})
Return lRet
//-----------------------------------------------
/*/{Protheus.doc} AgluOSExp
Verifica a possibilidade de aglutinação de OS de
expedição pertencentes a uma mesma carga ou plano
de execução
@author  felipe.m
@since   23/12/2014
@version 1.0
/*/
//-----------------------------------------------
METHOD AgluOSExp() CLASS WMSDTCOrdemServicoExecute
Local lRet       := .T.
Local cWhere     := ""
Local cAliasQry  := Nil
Local nQtdOrdSer := Self:nQuant
Local nCont      := 1
	//Busca ordens de serviços semelhantes para serem aglutinadas
	// Parâmetro Where
	cWhere := "%"
	If !Empty(Self:GetCodPln())
		cWhere +=     " AND DCF.DCF_CODPLN = '"+Self:GetCodPln()+"'"
	ElseIf WmsCarga(Self:GetCarga())
		If SuperGetMv("MV_WMSACEX",.F.,"0") == '2' // Se aglutina por cliente
			cWhere += " AND DCF.DCF_CLIFOR = '"+Self:GetCliFor()+"'"
			cWhere += " AND DCF.DCF_LOJA = '"+Self:GetLoja()+"'"
		EndIf
		cWhere +=     " AND DCF.DCF_CARGA = '"+Self:GetCarga()+"'"
	EndIf
	If Self:oServico:GetTipo() == '2'
		cWhere +=     " AND DCF.DCF_LOCAL = '"+Self:oOrdEndOri:GetArmazem()+"'"
		cWhere +=     " AND DCF.DCF_ENDER = '"+Self:oOrdEndOri:GetEnder()+"'"
	Else
		cWhere +=     " AND DCF.DCF_LOCDES = '"+Self:oOrdEndDes:GetArmazem()+"'"
		cWhere +=     " AND DCF.DCF_ENDDES = '"+Self:oOrdEndDes:GetEnder()+"'"
	EndIf
	cWhere += "%"
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_ID,
				DCF.DCF_NUMSEQ,
				DCF.DCF_QUANT,
				DCF.DCF_DOCTO,
				DCF.DCF_SERIE,
				DCF.DCF_CLIFOR,
				DCF.DCF_LOJA,
				DCF.DCF_SEQUEN,
				DCF.R_E_C_N_O_ RECNODCF
		FROM %Table:DCF% DCF
		WHERE DCF.DCF_FILIAL = %xFilial:DCF%
		AND DCF.DCF_SERVIC = %Exp:Self:oServico:GetServico()%
		AND DCF.DCF_CODPRO = %Exp:Self:oProdLote:GetProduto()%
		AND DCF.DCF_LOTECT = %Exp:Self:oProdLote:GetLoteCtl()%
		AND DCF.DCF_NUMLOT = %Exp:Self:oProdLote:GetNumLote()%
		AND DCF.DCF_STSERV <> '3'
		AND DCF.DCF_STRADI = ' '
		AND DCF.R_E_C_N_O_ <> %Exp:AllTrim(Str(Self:GetRecno()))%
		AND DCF.%NotDel%
		%Exp:cWhere%
	EndSql
	WmsConout('Início Aglutinação - Carga ' + Self:cCarga)
	WmsConout('DCF Recno Aglutinador ' + cValToChar(Self:GetRecno()))
	WmsConout(GetLastQuery()[2])
	Do While !(cAliasQry)->(Eof())
		// Caso alguma ordem de serviço da carga não esteja disponível para execução não aglutina
		If Self:ChkDepPend((cAliasQry)->DCF_ID)
			lRet := .F.
			Exit
		EndIf
		// Salva o registro na lista de ordens de serviço de expedição aglutinada
		AAdd(Self:aOrdAglu,{(cAliasQry)->DCF_ID,(cAliasQry)->DCF_QUANT,(cAliasQry)->RECNODCF,(cAliasQry)->DCF_SEQUEN,{}})
		WmsConout('Adição em aOrdAglu ID ' + (cAliasQry)->DCF_ID + '/ qtde ' + cValToChar((cAliasQry)->DCF_QUANT) + ' / RecnoDCF ' + cValToChar((cAliasQry)->RECNODCF) + ' / Seq ' + (cAliasQry)->DCF_SEQUEN)

		// Salva o recno no array para posterior atualização de status
		AAdd(Self:aRecDCF ,{(cAliasQry)->RECNODCF,.T.})
		nQtdOrdSer += (cAliasQry)->DCF_QUANT
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	If Len(Self:aOrdAglu) > 0
		//Grava no array a OS que encontra-se posicionada, que não foi considerada pelo SELECT
		AAdd(Self:aOrdAglu,{Self:cIdDCF,Self:nQuant,Self:GetRecno(),Self:cSequen,{}})
		WmsConout('aOrdAglu ID ' + Self:cIdDCF + '/' + cValToChar(Self:nQuant) + '/' + cValToChar(Self:GetRecno()) + '/' + Self:cSequen)
		AAdd(Self:aRecDCF ,{Self:GetRecno(),.T.})
		//Ordena o array pelo IDDCF
		ASort(Self:aOrdAglu, , , {|x,y|x[1] < y[1]})
		WmsConout('Ordenação aOrdAglu')
		// Seta o status das ordens de serviço para Interrompido
		If Len(Self:aRecDCF) > 0
			For nCont := 1 To Len(Self:aRecDCF)
				Self:GoToDCF(Self:aRecDCF[nCont][1])
				Self:SetStServ('2')
				Self:SetOk("")
				Self:cStRadi := '1'
				Self:UpdateDCF(.F.) // Para não liberar o lock
			Next
		EndIf
		Self:nQuant := nQtdOrdSer
		WmsConout('*** Quantidade apos aglutinacao: ' + cValToChar(Self:nQuant))
	EndIf
Return lRet

METHOD ExecDesmon() CLASS WMSDTCOrdemServicoExecute
Local oCompEnder := WMSDTCProdutoComponente():New()
Local oEstEnder := WMSDTCEstoqueEndereco():New()

	oCompEnder:SetPrdCmp(Self:oProdLote:GetProduto())
	oCompEnder:LoadData(2)

	oEstEnder:oEndereco:SetArmazem( Self:oOrdEndOri:GetArmazem() )
	oEstEnder:oEndereco:SetEnder( Self:oOrdEndOri:GetEnder() )
	oEstEnder:oProdLote:SetArmazem( Self:oProdLote:GetArmazem() )
	oEstEnder:oProdLote:SetPrdOri( oCompEnder:GetPrdOri() )
	oEstEnder:oProdLote:SetProduto( Self:oProdLote:GetProduto() )
	oEstEnder:oProdLote:SetLoteCtl( Self:oProdLote:GetLoteCtl() )
	oEstEnder:oProdLote:SetNumLote( Self:oProdLote:GetNumLote() )
	oEstEnder:oProdLote:SetNumSer( Self:oProdLote:GetNumSer() )
	oEstEnder:SetQuant( Self:GetQuant() )
	oEstEnder:UpdSaldo("999",.T.,.F.,.T.,.F.,.F.)

	oEstEnder:SetPrdOri( Self:oProdLote:GetPrdOri() )
	oEstEnder:UpdSaldo("499",.T.,.F.,.F.,.F.,.F.)
Return

METHOD UpdateEnd() CLASS WMSDTCOrdemServicoExecute
Local lRet      := .T.
Local lCarga    := WmsCarga(Self:GetCarga())
Local lCargaPE  := .F.
Local aAreaDCF  := DCF->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local cWhere    := ""
Local cAliasDCF := Nil
Local cAliasSC9 := Nil
	// Permite indicar se considera a carga para atribuir o endereço destino informado
	If lCarga .And. ExistBlock("DLENDOSE")
		lCargaPE := ExecBlock('DLENDOSE',.F.,.F.,{lCarga})
		If ValType(lCargaPE) =='L'
			lCarga := lCargaPE
		EndIf
	EndIf
	// Preenche DCF com os endereco e estrutura escolhidos
	// Atualiza as outras ordens de serviço, caso existam
	// Parâmetro Where
	cWhere := "%"
	If Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
		cWhere += " AND DCF.DCF_LOCAL = '"+Self:oOrdEndDes:GetArmazem()+"'"
		cWhere += " AND DCF.DCF_ENDDES = '"+Space(TamSx3("DCF_ENDDES")[1])+"'"
	Else
		cWhere += " AND DCF.DCF_LOCAL = '"+Self:oOrdEndOri:GetArmazem()+"'"
		cWhere += " AND DCF.DCF_ENDER = '"+Space(TamSx3("DCF_ENDER")[1])+"'"
	EndIf
	cWhere += "%"
	cAliasDCF := GetNextAlias()
	If lCarga
		BeginSql Alias cAliasDCF
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC = %Exp:Self:oServico:GetServico()%
			AND DCF_CARGA = %Exp:Self:GetCarga()%
			AND DCF.%NotDel%
			%Exp:cWhere%
		EndSql
	Else
		BeginSql Alias cAliasDCF
			SELECT DCF.R_E_C_N_O_ RECNODCF
			FROM %Table:DCF% DCF
			WHERE DCF.DCF_FILIAL = %xFilial:DCF%
			AND DCF.DCF_SERVIC = %Exp:Self:oServico:GetServico()%
			AND DCF.DCF_DOCTO = %Exp:Self:GetDocto()%
			AND DCF.DCF_CLIFOR = %Exp:Self:GetCliFor()%
			AND DCF.DCF_LOJA = %Exp:Self:GetLoja()%
			AND DCF.D_E_L_E_T_ = ' '"
			%Exp:cWhere%
		EndSql
	EndIf
	Do While (cAliasDCF)->(!Eof())
		DCF->(dbGoTo((cAliasDCF)->RECNODCF))
		//Criado essa rotina para casos onde temos endereço de origem no PV e NÃO é informado o endereço destino
		//Esta rotina vai retirar a entrada prevista do endereço em Branco na D14 e enviar para o endereço informado 
		//na Execução do Serviço.
		If (DCF->DCF_ORIGEM == "SC9" .OR. (DCF->DCF_ORIGEM == "SD2" .AND. cPaisLoc <> 'BRA')) .And. !Empty(DCF->DCF_ENDER) .And. Empty(DCF->DCF_ENDDES) .And. Empty(DCF->DCF_UNITIZ) .And. (DCF->DCF_CODPRO == DCF->DCF_PRDORI)
			 if !Self:WmsTrocDes() 
			 	lRet := .F.
				 Exit
			 Endif
		EndIf
		RecLock('DCF', .F.)
		DCF->DCF_ENDER  := Self:oOrdEndOri:GetEnder()
		DCF->DCF_ENDDES := Self:oOrdEndDes:GetEnder()
		DCF->(MsUnLock())
		// Atualiza pedido
		If DCF->DCF_ORIGEM == "SC9"
			// Atualiza as liberações do pedido
			cAliasSC9 := GetNextAlias()
			If lCarga
				BeginSql Alias cAliasSC9
					SELECT SC9.R_E_C_N_O_ RECNOSC9
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_SERVIC =  %Exp:DCF->DCF_SERVIC%
					AND SC9.C9_CARGA   = %Exp:DCF->DCF_CARGA%
					AND SC9.C9_ENDPAD  = %Exp:Space(TamSx3("C9_ENDPAD")[1])%
					AND SC9.C9_IDDCF = %Exp:DCF->DCF_ID%
					AND SC9.%NotDel%
				EndSql
			Else
				BeginSql Alias cAliasSC9
					SELECT SC9.R_E_C_N_O_ RECNOSC9
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %xFilial:SC9%
					AND SC9.C9_SERVIC =  %Exp:DCF->DCF_SERVIC%
					AND SC9.C9_PEDIDO = %Exp:DCF->DCF_DOCTO%
					AND SC9.C9_CLIENTE = %Exp:DCF->DCF_CLIFOR%
					AND SC9.C9_LOJA = %Exp:DCF->DCF_LOJA%
					AND SC9.C9_ENDPAD  = %Exp:Space(TamSx3("C9_ENDPAD")[1])%
					AND SC9.C9_IDDCF = %Exp:DCF->DCF_ID%
					AND SC9.%NotDel%
				EndSql
			EndIf
			Do While (cAliasSC9)->(!Eof())
				SC9->(dbGoTo((cAliasSC9)->RECNOSC9))
				RecLock('SC9', .F.)
				SC9->C9_ENDPAD := DCF->DCF_ENDDES
				SC9->(MsUnLock())
				(cAliasSC9)->(dbSkip())
			EndDo
			(cAliasSC9)->(dbCloseArea())
		EndIf
		(cAliasDCF)->(dbSkip())
	EndDo
	(cAliasDCF)->(dbCloseArea())
	RestArea(aAreaDCF)
	RestArea(aAreaSC9)
Return lRet

METHOD VldOrdEnd() CLASS WMSDTCOrdemServicoExecute
Local lRet      := .T.
Local lFindEnd  := .T.
Local cArmazem  := ""
Local cEndereco := ""

	If Self:oServico:HasOperac({'1','2','3','4'}) // Caso serviço tenha operação de endereçamento, endereçamento crossdocking, separação, separação crossdocking
		If Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
			cArmazem  := Self:oOrdEndDes:GetArmazem()
			cEndereco := Self:oOrdEndDes:GetEnder()
			lFindEnd  := Self:oOrdEndDes:LoadData()
		Else
			cArmazem  := Self:oOrdEndOri:GetArmazem()
			cEndereco := Self:oOrdEndOri:GetEnder()
			lFindEnd  := Self:oOrdEndOri:LoadData()
		EndIf
		// Força a utilização de um endereco destino caso o endereço encontra-se vazio ou o endereço preenchido é inválido.
		If Empty(cEndereco) .Or. (!Empty(cEndereco) .And. !lFindEnd)
			cEndereco := Space(TamSx3("D14_ENDER")[1])
			DLPergEnd(@cEndereco,.T.,.T.,IIf(Self:oServico:HasOperac({'3','4'}) ,'2','1'),cArmazem) // Identifique o destino do Serviço WMS:
			If Self:oServico:HasOperac({'3','4'}) // Caso serviço tenha operação de separação, separação crossdocking
				//Se o endereço que encontra-se na DCF é inválido, realiza a troca de endereços e ajusta a D14, DCF e demais tabelas
				If !Empty(Self:oOrdEndDes:GetEnder()) .And. !lFindEnd
					Self:UpdEndDes(cEndereco)
				Else //Caso o endereço vazio na DCF
					Self:oOrdEndDes:SetEnder(cEndereco)
					If Self:UpdateEnd()
						Self:LoadData()
					Else
						lRet := .F.
					EndIf
				EndIf
			Else
				//Se o endereço que encontra-se na DCF é inválido, realiza a troca de endereços e ajusta a D14, DCF e demais tabelas
				If !Empty(Self:oOrdEndOri:GetEnder()) .And. !lFindEnd
					Self:UpdEndOri(cEndereco)
				Else //Caso o endereço vazio na DCF
					Self:oOrdEndOri:SetEnder(cEndereco)
					If Self:UpdateEnd()
						Self:LoadData()
					Else
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

//-----------------------------------------------
/*/{Protheus.doc} VldAgluOS
Confronta as quantidades das tabelas SC9, D12, DCR e DCF de todas as OS aglutinadas, para garantir que
não houve erro no processo de aglutinação.
@author  Wander Horongoso
@since   06/04/2021
@version 1.0
/*/
//-----------------------------------------------
METHOD VldAgluOS(cMessError) CLASS WMSDTCOrdemServicoExecute
Local lRet := .T.

	If MethIsMemberOf(Self,"VldGrvOS",.T.)
		lRet := Self:VldGrvOS(@cMessError, Self:aOrdAglu)
	EndIf

Return lRet

METHOD ExeDistPrd()  CLASS WMSDTCOrdemServicoExecute
Local lRet        := .T.
Local lCarregou   := .F.
Local oOrdServAux := Nil
Local cAliasNew   := ""

	// Busca as informações do documento de montagem/desmontagem
	cAliasNew := GetNextAlias()
	BeginSql Alias cAliasNew
		SELECT D0F.D0F_ENDER,
				D0F.D0F_QTDDIS
		FROM %Table:SD1% SD1
		INNER JOIN %Table:D06% D06
		ON D06.D06_FILIAL = %xFilial:D06%
		AND D06.D06_CODDIS = SD1.D1_CODDIS
		AND D06.D06_SITDIS <> '3'
		AND D06.%NotDel%
		INNER JOIN %Table:D0F% D0F
		ON D0F.D0F_FILIAL = %xFilial:D0F%
		AND D0F.D0F_CODDIS = SD1.D1_CODDIS
		AND D0F.D0F_DOC = SD1.D1_DOC
		AND D0F.D0F_SERIE = SD1.D1_SERIE
		AND D0F.D0F_FORNEC = SD1.D1_FORNECE
		AND D0F.D0F_LOJA = SD1.D1_LOJA
		AND D0F.D0F_PRODUT = SD1.D1_COD
		AND D0F.D0F_ITEM = SD1.D1_ITEM
		AND D0F.%NotDel%
		WHERE SD1.D1_FILIAL = %xFilial:SD1%
		AND SD1.D1_NUMSEQ = %Exp:Self:cNumSeq%
		AND SD1.%NotDel%
		ORDER BY D0F.D0F_ENDER
	EndSql
	If (cAliasNew)->(!Eof())
		oOrdServAux:= WMSDTCOrdemServico():New()
		// Carrega dados originais da ordem de serviço
		oOrdServAux:GoToDCF(Self:nRecno)
		lCarregou := .T.
	Else
		Self:cErro := WmsFmtMsg(STR0012,{{"[VAR01]",Self:GetDocto()}})  // Não encontrada a distribuição de produtos do documento [VAR01]!
		lRet := .F.
	EndIf
	Do While lRet .And. (cAliasNew)->(!Eof())
		// Verifica se há endereço destino informado na distribuição
		Self:oOrdEndDes:SetArmazem(Self:oOrdEndDes:GetArmazem())
		If !Empty((cAliasNew)->D0F_ENDER)
			Self:oOrdEndDes:SetEnder((cAliasNew)->D0F_ENDER) // Endereço destino
		Else
			// Carrega dados endereço destino
			Self:oOrdEndDes:SetEnder(Self:oOrdEndDes:GetEnder())
		EndIf
		Self:oOrdEndDes:LoadData()
		Self:oOrdEndDes:ExceptEnd()
		// Atribui demais informações
		Self:SetQuant((cAliasNew)->D0F_QTDDIS)
		// Deverá grava na ordem de serviço as informações pois são utilizadas na geração das atividades
		Self:UpdateDCF(.F.)
		lRet := Self:ExecutePrd()
		(cAliasNew)->(dbSkip())
	EndDo
	(cAliasNew)->(dbCloseArea())
	If lRet .And. lCarregou
		// Recarrega a ordem de serviço para atualização das informações
		// Atribui dados endereco destino
		Self:oOrdEndDes:SetArmazem(oOrdServAux:oOrdEndDes:GetArmazem())
		Self:oOrdEndDes:SetEnder(oOrdServAux:oOrdEndDes:GetEnder()) // Endereço Origem
		Self:oOrdEndDes:LoadData()
		Self:oOrdEndDes:ExceptEnd()
		// Atribui o produto origem ao movimento
		// Demais informações
		Self:SetQuant(oOrdServAux:GetQuant())
		// Deverá atualizar a ordem de serviço com as informações originais
		Self:UpdateDCF(.F.)
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdEndDes
Atualiza endereço destino antes de gerar D12
@author amanda.vieira
@since 24/11/2016
@version 1.0
@param cNewEnd, character, (Novo endereço)
/*/
//--------------------------------------------------
METHOD UpdEndDes(cNewEnd) CLASS WMSDTCOrdemServicoExecute
Local lRet      := .T.
Local lEndOri   := !Empty(Self:oOrdEndOri:GetEnder())

	// Verifica se endereço origem preenchi
	// Desfaz saida e entrada prevista
	If lEndOri
		lRet := Self:ReverseMI()
	EndIf
	// Atualiza endereço destino
	If lRet
		Self:oOrdEndDes:SetEnder(cNewEnd)
		Self:UpdateDCF(.F.)
	EndIf
	// Verifca se endereço origem preechido
	// Refaz saida e entrada prevista
	If lRet .And. lEndOri
		lRet := Self:MakeInput()
	EndIf
	 // Atualiza documentos com o endereço destino
	If lRet
		If Self:cOrigem == "DH1"
			// Atualiza o endereço na DH1 quando foi informado.
			DH1->(dbSetOrder(1)) // DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ
			DH1->(dbSeek(xFilial("DH1")+Self:cDocumento+Self:oOrdEndOri:GetArmazem()+Self:cNumSeq))
			Do While DH1->(!Eof()) .And. xFilial("DH1")+Self:cDocumento+Self:oOrdEndOri:GetArmazem()+Self:cNumSeq == DH1->(DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ)
				If Self:cIdDCF == DH1->DH1_IDDCF
					RecLock('DH1',.F.)
					DH1->DH1_LOCALI := cNewEnd
					DH1->(MsUnLock())
				EndIf
				DH1->(dbSkip())
			EndDo
		ElseIf Self:cOrigem == "SC9"
			SC9->(dbSetOrder(9)) // C9_FILIAL+C9_IDDCF
			If SC9->(dbSeek(xFilial("SC9")+Self:cIdDCF))
				SC6->(dbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(dbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM+C9_PRODUTO)))
					RecLock('SC6',.F.)
					SC6->C6_ENDPAD := cNewEnd
					SC6->(MsUnLock())
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} UpdEndOri
Atualiza endereço origem antes de gerar D12
@author amanda.vieira
@since 24/11/2016
@version 1.0
@param cNewEnd, character, (Novo endereço)
/*/
//--------------------------------------------------
METHOD UpdEndOri(cNewEnd) CLASS WMSDTCOrdemServicoExecute
Local lRet      := .T.
	// Desfaz o saldo do endereço origem
	lRet := Self:ReverseMA()
	// Atualiza endereço origem
	If lRet
		Self:oOrdEndOri:SetEnder(cNewEnd)
		Self:UpdateDCF()
	EndIf
	// Refaz saldo no endereço origem
	If lRet
		lRet := Self:MakeArmaz()
	EndIf
	// Atualiza endereço origem
	If lRet .And. Self:cOrigem == "DH1"
		// Atualiza o endereço na DH1 quando foi informado.
		DH1->(dbSetOrder(1)) // DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ
		DH1->(dbSeek(xFilial("DH1")+Self:cDocumento+Self:oOrdEndDes:GetArmazem()+Self:cNumSeq))
		Do While DH1->(!Eof()) .And. xFilial("DH1")+Self:cDocumento+Self:oOrdEndDes:GetArmazem()+Self:cNumSeq == DH1->(DH1_FILIAL+DH1_DOC+DH1_LOCAL+DH1_NUMSEQ)
			If Self:cIdDCF == DH1->DH1_IDDCF
				RecLock('DH1',.F.)
				DH1->DH1_LOCALI := cNewEnd
				DH1->(MsUnLock())
			EndIf
			DH1->(dbSkip())
		EndDo
	EndIf
Return lRet

/*/{Protheus.doc} WmsTrocDes
	Criado essa Method para casos onde temos um Pedido de Venda com endereço de origem informado "C6_LOCALIZ" o endereço 
	destino C6_ENDPAD não preenchido,vamos retirar a entrada prevista do endereço em Branco na D14 e enviar esse saldo 
	para o endereço informado na Execução do Serviço 
	@Murilo Brandão
	@since 20/08/2021
	/*/
METHOD WmsTrocDes() CLASS WMSDTCOrdemServicoExecute
Local lRet := .T.
Local OenderAux := WMSDTCEstoqueEndereco():New()
Local oMovEstEnd := WMSDTCMovimentosEstoqueEndereco():New()

		OenderAux:oEndereco:SetArmazem(DCF->DCF_LOCAL)
		OenderAux:oEndereco:SetEnder(Space(TamSx3("DCF_ENDER")[1]))
		OenderAux:oProdLote:SetArmazem(DCF->DCF_LOCAL) // Armazem
		OenderAux:oProdLote:SetPrdOri(DCF->DCF_CODPRO)   // Produto Origem - Componente
		OenderAux:oProdLote:SetProduto(DCF->DCF_CODPRO) // Produto Principal
		OenderAux:oProdLote:SetLoteCtl(DCF->DCF_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
		OenderAux:oProdLote:SetNumLote(DCF->DCF_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
		OenderAux:oProdLote:LoadData()
		OenderAux:SetQuant(DCF->DCF_QUANT)
		// Seta o bloco de código para informações do documento para o Kardex
		OenderAux:SetBlkDoc({|oMovEstEnd|;
			oMovEstEnd:SetOrigem(DCF->DCF_QUANT),;
			oMovEstEnd:SetDocto(DCF->DCF_DOCTO),;
			oMovEstEnd:SetSerie(DCF->DCF_SERIE),;
			oMovEstEnd:SetCliFor(DCF->DCF_CLIFOR),;
			oMovEstEnd:SetLoja(DCF->DCF_LOJA),;
			oMovEstEnd:SetNumSeq(DCF->DCF_NUMSEQ),;
			oMovEstEnd:SetIdDCF(DCF->DCF_ID);
		})
		// Seta o bloco de código para informações do movimento para o Kardex
			OenderAux:SetBlkMov({|oMovEstEnd|;
			oMovEstEnd:SetIdUnit();
		})
		lRet := OenderAux:UpdSaldo('999',.F./*lEstoque*/,.T./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,/*lEmpPrev*/,.F./*lMovEstEnd*/)
		
		If lRet 
			OenderAux:oEndereco:SetArmazem(DCF->DCF_LOCAL)
			OenderAux:oEndereco:SetEnder(Self:oOrdEndDes:GetEnder())
			OenderAux:oProdLote:SetArmazem(DCF->DCF_LOCAL) // Armazem
			OenderAux:oProdLote:SetPrdOri(DCF->DCF_CODPRO)   // Produto Origem - Componente
			OenderAux:oProdLote:SetProduto(DCF->DCF_CODPRO) // Produto Principal
			OenderAux:oProdLote:SetLoteCtl(DCF->DCF_LOTECT) // Lote do produto principal que deverá ser o mesmo no componentes
			OenderAux:oProdLote:SetNumLote(DCF->DCF_NUMLOT) // Sub-Lote do produto principal que deverá ser o mesmo no componentes
			OenderAux:oProdLote:LoadData()
			OenderAux:SetQuant(DCF->DCF_QUANT)
			// Seta o bloco de código para informações do documento para o Kardex
			OenderAux:SetBlkDoc({|oMovEstEnd|;
				oMovEstEnd:SetOrigem(DCF->DCF_QUANT),;
				oMovEstEnd:SetDocto(DCF->DCF_DOCTO),;
				oMovEstEnd:SetSerie(DCF->DCF_SERIE),;
				oMovEstEnd:SetCliFor(DCF->DCF_CLIFOR),;
				oMovEstEnd:SetLoja(DCF->DCF_LOJA),;
				oMovEstEnd:SetNumSeq(DCF->DCF_NUMSEQ),;
				oMovEstEnd:SetIdDCF(DCF->DCF_ID);
			})
			// Seta o bloco de código para informações do movimento para o Kardex
			OenderAux:SetBlkMov({|oMovEstEnd|;
				oMovEstEnd:SetIdUnit();
			})
			lRet := OenderAux:UpdSaldo('499',.F./*lEstoque*/,.T./*lEntPrev*/,.F./*lSaiPrev*/,.F./*lEmpenho*/,.F./*lBloqueio*/,/*lEmpPrev*/,.F./*lMovEstEnd*/)
		EndIf
Return lRet	
