#INCLUDE "TOTVS.CH"
#INCLUDE "WMSBCCSEPARACAO.CH"

#DEFINE CLRF CHR(13)+CHR(10)

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0007
Função para permitir que a classe seja visualizada
no inspetor de objetos
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Static lWMSNRPKG  := ExistBlock("WMSNRPKG")
Static lWMSAENDE  := ExistBlock("WMSAENDE")
Static lWMSQYSEP  := ExistBlock("WMSQYSEP")

Function WMSCLS0007()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSBCCSeparacao
Classe para analise e geração dos movimentos de expedição
e expedição crossdocking
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
CLASS WMSBCCSeparacao FROM WMSDTCMovimentosServicoArmazem

	// Declaracao das propriedades da Classe
	DATA oEstFis
	DATA lBlOrdDec
	DATA lFefoBlFr
	DATA lPrdTemPul
	DATA lPrdTemPkg
	DATA nQtdApUni
	DATA nQtdNorma
	DATA xRegra
	DATA nContPrd
	DATA nSeqAbast
	DATA aLogSld
	DATA lEndCli
	DATA nGerReab

	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD SetOrdServ(oOrdServ)
	METHOD SetContPrd(nContPrd)
	METHOD SetLogSld(aLogSld)
	METHOD SetPrdTemPul(lPrdTemPul)
	METHOD ExecFuncao()
	METHOD VldGeracao()
	METHOD ProcSerEmb()
	METHOD ProcEstExp()
	METHOD ProcEndExp(lReiSeqAb)
	METHOD PerRepPkg(nQtdAbast,nQtdSep)
	METHOD GeraAbtDem(lGeraAbast,nQtdApanhe,aSeqAbPkg)
	METHOD QryEstEnd(lCnsPkgFut)
	METHOD UpdControl()
	METHOD AddMsgLog()
	METHOD Destroy()
	METHOD RetQtdMul(nQtdApEnd)
	METHOD GerAbast(nQtdSep,lGerouReab)
	METHOD FindReabPK(lGerouReab)
	METHOD AddInfoParametros()
	METHOD AddInfoProduto()
	METHOD AddInfoOrdemServico()
ENDCLASS

METHOD New() CLASS WMSBCCSeparacao
	_Super:New()
	Self:oEstFis   := WMSDTCEstruturaFisica():New()
	Self:nQtdNorma := 0
	Self:nQtdApUni := 0
	Self:lPrdTemPul:= .F.
	Self:lPrdTemPkg:= .F.

	Self:lBlOrdDec := (SuperGetMV('MV_WMSBLAP',.F.,2)==2) // Define Ordem apanhe para estrutura blocado (1-Crescente/2-Descrescente)
	Self:lFefoBlFr := SuperGetMV('MV_FEFOBLF',.F.,.F.)
	Self:aLogSld   := Nil
	Self:nContPrd  := 0
	Self:nSeqAbast := 0
	Self:lEndCli   := .F.
	Self:nGerReab  := 0
	Self:xRegra    := CtoD("")
Return

METHOD Destroy() CLASS WMSBCCSeparacao
	//Mantido para compatibilidade
Return

METHOD SetOrdServ(oOrdServ) CLASS WMSBCCSeparacao
	Self:oOrdServ := oOrdServ
	Self:oMovServic := Self:oOrdServ:oServico
	// Carrega dados endereço origem
	Self:oMovEndOri:SetArmazem(Self:oOrdServ:oOrdEndOri:GetArmazem())
	Self:oMovEndOri:SetEnder(Self:oOrdServ:oOrdEndOri:GetEnder())
	Self:oMovEndOri:LoadData()
	Self:oMovEndOri:ExceptEnd()
	// Carrega dados endereço destino
	Self:oMovEndDes:SetArmazem(Self:oOrdServ:oOrdEndDes:GetArmazem())
	Self:oMovEndDes:SetEnder(Self:oOrdServ:oOrdEndDes:GetEnder())
	Self:oMovEndDes:LoadData()
	Self:oMovEndDes:ExceptEnd()
Return

METHOD SetContPrd(nContPrd) CLASS WMSBCCSeparacao
	Self:nContPrd := nContPrd
Return

METHOD SetLogSld(aLogSld) CLASS WMSBCCSeparacao
	Self:aLogSld := aLogSld
Return

METHOD SetPrdTemPul(lPrdTemPul) CLASS WMSBCCSeparacao
	Self:lPrdTemPul := lPrdTemPul
Return 

METHOD ExecFuncao() CLASS WMSBCCSeparacao
Local lRet       := .T.
Local oCliEndBlq := Nil
Local lConsVenc  := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')
Local nRecnoDCF  := Self:oOrdServ:GetRecno()
Local nRegraWMS  := Self:oOrdServ:GetRegra()

	Self:lFefoBlFr := (Self:lFefoBlFr .And. Self:oMovPrdLot:HasRastro())
	// Valida se é Cross para forçar a regra WMS para tipo 3 (sequencia/Data)
	If Self:oMovServic:ChkSpCross() .AND. Self:oOrdServ:GetRegra() == "4"
		Self:oOrdServ:SetRegra("3")
	EndIf
	If Self:oOrdServ:GetRegra() == "1"
		Self:xRegra := Self:oMovPrdLot:GetLoteCtl()
	ElseIf Self:oOrdServ:GetRegra() == "2"
		Self:xRegra := Space(TamSx3("D14_NUMSER")[1]) // Numero de Serie
	ElseIf Self:oOrdServ:GetRegra() $ "3|4"
		// Caso produto não controle rastro grava xRegra com data em branco
		Self:xRegra := IIf(Self:oMovPrdLot:HasRastro() .And. !lConsVenc,dDataBase,CtoD(""))
	Else
		Self:oOrdServ:SetRegra("3") // Ajusta regra quando vazio, para que a separação busque sempre o lote mais antigo dentro da estrutura
		Self:xRegra := CtoD("")
	EndIf
	// Seta as informações da sequencia de abastecimento para carregar se o produto tem pulmão
	Self:oMovSeqAbt:SetArmazem(Self:oMovEndOri:GetArmazem())
	Self:oMovSeqAbt:SetProduto(Self:oMovPrdLot:GetProduto())
	Self:oMovSeqAbt:SetServico(Self:oMovServic:GetServico())

	Self:lPrdTemPul := Self:oOrdServ:HasPrdPul()
	Self:lPrdTemPkg := Self:oOrdServ:HasPrdPkg()
	// Verifica caso cross-docking se cliente possui endereço definido
	// Caso não informado o endereço origem verifica se possui cadastro para o cliente
	If Empty(Self:oMovEndOri:GetEnder()) .AND. Self:oMovServic:ChkSpCross()
		oCliEndBlq := WMSDTCClienteEnderecoBlocado():New()
		oCliEndBlq:SetCliente(Self:oOrdServ:GetCliFor())
		oCliEndBlq:SetLoja(Self:oOrdServ:GetLoja())
		oCliEndBlq:SetLocal(Self:oMovPrdLot:GetArmazem())
		If oCliEndBlq:LoadData()
			// Atribui endereco destino/caso não encotre deixe vazio
			Self:oMovEndOri:SetEnder(oCliEndBlq:GetEnder())
			Self:lEndCli := Self:oMovEndOri:LoadData()
			If !Empty(Self:oMovEndOri:GetEnder()) .And. !Self:ChkEndOri()
				Self:oMovEndOri:SetEnder("")
			EndIf
		EndIf
	EndIf
	If (lRet := Self:VldGeracao())
		lRet := Self:ProcSerEmb()
	EndIf
	If Self:oOrdServ:GetRecno() != nRecnoDCF
		Self:oOrdServ:GoToDCF(nRecnoDCF) // Recarrega a DCF original quando aglutina tarefas
	EndIf
	Self:oOrdServ:SetRegra(nRegraWMS) // Recarrega também a regra WMS, que pode estar em branco no registro da DCF, porém foi definida no processo de separação

	If lRet .And. Self:oOrdServ:GetOrigem() == "SC9" .And. (Self:oMovServic:ChkMntVol() .Or. Self:oMovServic:ChkConfExp() .Or. Self:oMovServic:ChkDisSep())
		// Cria os processos de expedição
		lRet := Self:UpdExpedic(Self:oOrdServ:GetIdDCF(),Self:oOrdServ:GetDocto(),Self:oOrdServ:GetCliFor(),Self:oOrdServ:GetLoja())
	EndIf
Return lRet

METHOD VldGeracao() CLASS WMSBCCSeparacao
Local lRet := .T.
	// Valida o endereço origem, caso informado.
	If !Empty(Self:oMovEndOri:GetEnder())
		If !Self:ChkEndOri(.T.)
			lRet := .F.
		EndIf
	EndIf
	// Valida se endereço destino informado.
	If lRet .And. !Self:ChkEndDes()
		lRet := .F.
	EndIf
Return lRet

METHOD ProcSerEmb() CLASS WMSBCCSeparacao
Local lRet       := .T.
Local lAtvPad    := .T.
Local lAtvEmb    := .F.
Local aProduto   := {}
Local oFuncaoAux := Nil
Local cAliasD12  := Nil
Local cIdDCFPld  := Nil
Local cSeqDCPld  := Nil
Local nFatConv   := 0
Local nQtdUn     := 0
Local nQtdCx     := 0

	Self:cMapaTipo := "2" // 2 - Caixa Fechada
	// Tratamento para quando o produto gera quantidades unitizadas para embalagem
	If Self:oMovPrdLot:GetWmsEmb() == "1"
		// Fator de conversao do produto
		nFatConv := Self:oMovPrdLot:GetConv()
		// Regras para a geracao das atividades
		// Se a quantidade da total for menor que o fator de conversão do produto, gera somente atividade de embalagem
		If QtdComp(Self:nQuant) < QtdComp(nFatConv)
			lAtvPad := .F.
			lAtvEmb := .T.
			nQtdUn  := Self:nQuant
		// Se a quantidade do unitizador for igual ao fator de conversão do produto, gera somente atividade padrão
		ElseIf QtdComp(Self:nQuant) == QtdComp(nFatConv)
			lAtvPad := .T.
			lAtvEmb := .F.
			nQtdCx  := Self:nQuant
		// Se a quantidade do unitizador for maior que o fator de conversão do produto efetua o cálculo
		Else
			nQtdCx := Int( Self:nQuant / nFatConv ) * nFatConv
			// Se o resultado do cálculo for igual a quantidade do unitizador, gera somente atividade padrão
			If QtdComp(Self:nQuant) == QtdComp(nQtdCx)
				lAtvPad := .T.
				lAtvEmb := .F.
			// Gera atividade padrao e atividade de embalagem
			Else
				lAtvPad := .T.
				lAtvEmb := .T.
				nQtdUn  := Self:nQuant - nQtdCx
			EndIf
		EndIf
	Else
		lAtvPad := .T.
		lAtvEmb := .F.
		nQtdCx  := Self:nQuant
	EndIf

	// Monta cabeçalho do log
	If lRet .And. Self:aLogSld != Nil
		If Len(Self:aLogSld) == 0 // Adiciona apenas na primeira vez.
			Self:AddInfoParametros()
		EndIf
		
		Self:AddInfoOrdemServico()

		Self:AddInfoProduto()
	EndIf
	If lAtvPad
		Self:nQuant := nQtdCx
		lRet := Self:ProcEstExp()
	EndIf
	If lRet .And. lAtvEmb
		Self:nQuant := nQtdUn
		Self:cMapaTipo := "1" // 1 - Unitário
		lRet := Self:ProcEstExp()
	EndIf
	If lRet .And. QtdComp(Self:nQuant) > QtdComp(0)
		Self:cErro := WmsFmtMsg(STR0002,{{"[VAR01]",Str(Self:nQuant)}}) // Não foi possível separar toda a quantidade. Saldo pendente ([VAR01]).
		lRet = .F.
	EndIf
	If lRet
		// Efetua o ajuste na tabela de liberação de pedidos (SC9)
		// Efetua o ajuste na tabela de liberação de requisições (SD4)
		If Self:nContPrd == 1 .And. Self:oOrdServ:GetOrigem() $ "SC9|SD4" .And. Self:oOrdServ:oProdLote:HasRastro() .And. Empty(Self:oOrdServ:oProdLote:GetLoteCtl())
			lRet := Self:UpdControl()
		EndIf
	EndIf
	// Valida quando possuir filhos, se o mesmo lote poderá ser utilizado
	If lRet
		aProduto := Self:oOrdServ:oProdLote:GetArrProd()
		If Self:nContPrd+1 <= Len(aProduto)
			// Remove o endereço origem
			Self:oMovEndOri:SetEnder('')
			// Verifica a quantidade movimentada de cada componente, para que sejam multiplos.
			cAliasD12 := GetNextAlias()
			// Quando por plano separação busca a quantidade de todas as ordens de serviço
			If !Empty(Self:aOrdAglu)
				aEval(Self:aOrdAglu,{|x| cIdDCFPld += "'"+x[1]+"'," })
				aEval(Self:aOrdAglu,{|x| cSeqDCPld += "'"+x[4]+"'," })
				cIdDCFPld := Substr(cIdDCFPld,1,Len(cIdDCFPld)-1)
				cSeqDCPld := Substr(cSeqDCPld,1,Len(cSeqDCPld)-1)
			Else
				cIdDCFPld := "'"+Self:oOrdServ:GetIdDCF()+"'"
				cSeqDCPld := "'"+Self:oOrdServ:GetSequen()+"'"
			EndIf
			cIdDCFPld := "%"+cIdDCFPld+"%"
			cSeqDCPld := "%"+cSeqDCPld+"%"
			If Self:nContPrd > 1
				BeginSql Alias cAliasD12
					SELECT D12.D12_PRODUT,
							D12.D12_LOTECT,
							D12.D12_NUMLOT,
							D12.D12_NUMSER,
							SUM(DCR.DCR_QUANT) D12_QTDMOV
					FROM %Table:DCR% DCR
					INNER JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND DCR.DCR_FILIAL = %xFilial:DCR%
					AND D12.D12_IDDCF = DCR.DCR_IDORI
					AND D12.D12_IDMOV = DCR.DCR_IDMOV
					AND D12.D12_IDOPER = DCR.DCR_IDOPER
					AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
					AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
					AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()% // Assume a tarefa exatamante anterior
					AND D12.D12_ORDMOV IN ('3','4')
					AND D12.D12_STATUS <> '0'
					AND D12.%NotDel%
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					// Quando por plano separação busca a quantidade de todas as ordens de serviço
					AND DCR.DCR_IDDCF IN ( %Exp:cIdDCFPld% )
					AND DCR.DCR_SEQUEN IN ( %Exp:cSeqDCPld% )
					AND DCR.%NotDel%
					GROUP BY D12.D12_PRODUT,
								D12.D12_LOTECT,
								D12.D12_NUMLOT,
								D12.D12_NUMSER
					ORDER BY D12.D12_PRODUT DESC,
								D12.D12_LOTECT DESC,
								D12.D12_NUMLOT DESC,
								D12.D12_NUMSER DESC
				EndSql
			Else
				BeginSql Alias cAliasD12
					SELECT D12.D12_PRODUT,
							D12.D12_LOTECT,
							D12.D12_NUMLOT,
							D12.D12_NUMSER,
							SUM(DCR.DCR_QUANT) D12_QTDMOV
					FROM %Table:DCR% DCR
					INNER JOIN %Table:D12% D12
					ON D12.D12_FILIAL = %xFilial:D12%
					AND DCR.DCR_FILIAL = %xFilial:DCR%
					AND D12.D12_IDDCF = DCR.DCR_IDORI
					AND D12.D12_IDMOV = DCR.DCR_IDMOV
					AND D12.D12_IDOPER = DCR.DCR_IDOPER
					AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
					AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
					AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()% // Assume a tarefa exatamante anterior
					AND D12.D12_ORDMOV IN ('3','4')
					AND D12.D12_STATUS <> '0'
					AND D12.%NotDel%
					WHERE DCR.DCR_FILIAL = %xFilial:DCR%
					// Quando por plano separação busca a quantidade de todas as ordens de serviço
					AND DCR.DCR_IDDCF IN ( %Exp:cIdDCFPld% )
					AND DCR.DCR_SEQUEN IN ( %Exp:cSeqDCPld% )
					AND DCR.%NotDel%
					GROUP BY D12.D12_PRODUT,
								D12.D12_LOTECT,
								D12.D12_NUMLOT,
								D12.D12_NUMSER
				EndSql
			EndIf
			// Ajustando o tamanho dos campos da query
			TcSetField(cAliasD12,'D12_QTDMOV','N',TamSx3('D12_QTDMOV')[1],TamSx3('D12_QTDMOV')[2])
			Do While lRet .AND. (cAliasD12)->(!Eof())
				oFuncaoAux := WMSBCCSeparacao():New()
				// Atribui o produto origem ao movimento
				// Atribui para oMovimento produto/lote/sub-lote
				oFuncaoAux:oMovPrdLot:SetArmazem(Self:oMovPrdLot:GetArmazem())
				oFuncaoAux:oMovPrdLot:SetPrdOri(Self:oMovPrdLot:GetPrdOri())
				oFuncaoAux:oMovPrdLot:SetProduto(aProduto[Self:nContPrd+1][1])
				// Atribui Lote e Sub-lote
				oFuncaoAux:oMovPrdLot:SetLoteCtl((cAliasD12)->D12_LOTECT)
				oFuncaoAux:oMovPrdLot:SetNumLote((cAliasD12)->D12_NUMLOT)
				oFuncaoAux:oMovPrdLot:LoadData()
				oFuncaoAux:SetQuant(((cAliasD12)->D12_QTDMOV/aProduto[Self:nContPrd][2]) * aProduto[Self:nContPrd+1][2])
				oFuncaoAux:SetOrdServ(Self:oOrdServ)
				oFuncaoAux:SetContPrd(Self:nContPrd+1)
				oFuncaoAux:SetLogSld(Self:aLogSld)
				oFuncaoAux:SetRecD12(Self:aRecD12)
				oFuncaoAux:SetOrdAglu(Self:aOrdAglu)
				oFuncaoAux:SetWmsReab(Self:aWmsReab)
				oFuncaoAux:oOrdServ:nProduto := Self:nContPrd + 1
				oFuncaoAux:oOrdServ:nTarefa := Self:oOrdServ:nTarefa
				If !oFuncaoAux:ExecFuncao()
					Self:cErro := oFuncaoAux:GetErro()
					lRet := .F.
				EndIf
				If Self:nContPrd > 1
					Exit
				EndIf
				(cAliasD12)->(dbSkip())
			EndDo
			(cAliasD12)->(dbCloseArea())
		EndIf
	EndIf

	IIF(oFuncaoAux != Nil, FreeObj(oFuncaoAux), Nil)

Return lRet
/*/-----------------------------------------------------------------------------
Efetua a busca dos saldos para serem feitos o apanhe de acordo com a Regra WMS
- Pode fazer a busca de saldo seguindo a sequencia de abastecimento na ordem
inversa, considerando apenas sequencias de endereçamento.
- Pode fazer a busca de saldo pela data de validade independente da sequencia
de abastecimento.
-----------------------------------------------------------------------------/*/
METHOD ProcEstExp() CLASS WMSBCCSeparacao
Local lRet       := .T.
Local lGeraAbast := .F.
Local lGerouReab := .F.
Local lReiSeqAb  := .F.
Local lLogSld    := Self:aLogSld != Nil
	//Realiza busca por saldo físico
	lRet := Self:ProcEndExp(.F.,@lReiSeqAb)

	//Refaz a busca por saldo físico, considerando quantidade unitária
	If lRet .And. lReiSeqAb .And. QtdComp(Self:nQuant) > QtdComp(0)
		lRet := Self:ProcEndExp(.F.,lReiSeqAb)
	EndIf
	// Se sobrou saldo, deve verificar se tem reabastecimento pendente, para poder utilizar
	If lRet .And. QtdComp(Self:nQuant) > QtdComp(0) .And. (Self:lPrdTemPul .Or. Self:oMovSeqAbt:HasPickMas(.T.)) .And. Self:lPrdTemPkg // Se tem Pulmão e Picking
		lReiSeqAb := .T.
		//Permanece buscando saldo do picking enquanto gerar reabastecimento
		Do While lReiSeqAb .And. lRet .And. QtdComp(Self:nQuant) > QtdComp(0)
			lReiSeqAb := .F.
			//Realiza busca considerando entradas previstas
			If lLogSld
				AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0044,{{"[VAR01]",Self:oMovPrdLot:GetArmazem()}})+" - "+STR0021,{}}) // Armazém [VAR01] - Busca de saldo // Reabastecimentos anteriores pendentes.
			EndIf
			lRet := Self:ProcEndExp(.T.,@lReiSeqAb)
		EndDo
		// Se sobrou saldo, deve verificar se pode gerar reabastecimento para completar a separação
		If lRet .And. QtdComp(Self:nQuant) > QtdComp(0)
			If lLogSld
				AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0040,{{"[VAR01]",Self:oMovPrdLot:GetArmazem()}}),{}}) // "Armazém [VAR01] - Geração de reabastecimento por demanda."
			EndIf
			// Carrega somente pickings
			Self:oMovSeqAbt:SeqAbast(6)
			// Procede com a geração de reabastecimento por demanda
			lRet := Self:GeraAbtDem(@lGeraAbast,Self:nQuant,Self:oMovSeqAbt:GetArrSeqA())
			If lRet .And. lGeraAbast
				If lLogSld
					AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0044,{{"[VAR01]",Self:oMovPrdLot:GetArmazem()}})+" - "+STR0022,{}}) // Armazém [VAR01] - Busca de saldo // Reabastecimentos gerados pendentes.
				EndIf
				// Deve utilizar estes reabastecimentos pendentes para a separação
				IF Self:oMovSeqAbt:HasPickMas()
                   Self:oMovEndOri:SetEnder("")
                EndIf				
				lRet := Self:ProcEndExp(.T.)
			EndIf
		EndIf
	EndIf
	
	//Caso exista o ponto de entrada, permite uma nova execução da separação.	
	If ExistBlock("WMSRESEP")		
		If ExecBlock("WMSRESEP",.F.,.F.,{.T., Self:oMovPrdLot:GetProduto(), Self})
			lRet := Self:ProcEndExp(.F.,lReiSeqAb)
		EndIf
		ExecBlock("WMSRESEP",.F.,.F.,{.F., Self:oMovPrdLot:GetProduto(), Self})
	EndIf 

	// Verifica se há endereços de picking para reabastecimento
	// por percentual de reposição
	If lRet .And. !Empty(Self:aRecD12)
		Self:FindReabPK(@lGerouReab)
		If lGerouReab .Or. Self:nGerReab > 0
			If lLogSld .AND. lGerouReab
				AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0044,{{"[VAR01]",Self:oMovPrdLot:GetArmazem()}})+" - "+STR0022,{}}) // Armazém [VAR01] - Busca de saldo // Reabastecimentos gerados pendentes.
			EndIf
			If ValType(Self:aWmsReab) == "A"
				//Deve adicionar no log apenas uma vez
				If AScan(Self:aWmsReab, { |x| AllTrim(Self:oMovPrdLot:GetProduto()) $ x[1] }) == 0
					AAdd(Self:aWmsReab,{STR0027+AllTrim(Self:oMovPrdLot:GetProduto())}) // Reabastecimentos pendentes que precisam ser executados para o produto
				EndIf
			EndIf
		ElseIf !lGerouReab
			If Empty(Self:cErro)
				Self:AddMsgLog(,,,,,,,Self:nQuant,,STR0043) // Não foi possível gerar reabastecimento na estrutura física.
			Else
				Self:AddMsgLog(,,,,,,,Self:nQuant,,Self:cErro)
				Self:cErro := ""
			EndIf
		EndIf
	EndIf
Return lRet
/*/-----------------------------------------------------------------------------
Busca o próximo endereço para realizar o apanhe.
-----------------------------------------------------------------------------/*/
METHOD ProcEndExp(lCnsPkgFut,lReiSeqAb) CLASS WMSBCCSeparacao
Local lRet       := .T.
Local lRegraOK   := .T.
Local lConsVenc  := (SuperGetMV('MV_LOTVENC', .F., 'N')=='S')
Local lFoundD14  := .F.
Local lUtilNorm  := .F.
Local lPulEstFis := .F.
Local lValFinEnd := .T.
Local lWmsQtAp   := SuperGetMV("MV_WMSQTAP",.F.,"N") == "S" //Reinicia a busca de saldo de forma unitária se a quantidade a separar for maior que a capacidade de expedição do picking
Local lLogMsgPE  := .F.
Local aSldD14    := 0
Local aAreaAnt   := GetArea()
Local oUnitArm   := Nil
Local cAliasD14  := Nil
Local cAliasSB8  := Nil
Local nQtdSep    := 0
Local nQtdApMax  := 0
Local nQtdSaldo  := 0
Local nSldD14    := 0
Local nEmpD14    := 0
Local nEmpSB8    := 0
Local nSaldoDis  := 0
Local cMensag    := ""
Local aEstFis    := {}
Local nEstFis    := 0
Local lEstFis    := .F.
Local lEstFisChg := .T.
Local lPeWMSAVLT := ExistBlock("WMSAVLT") //Ponto de entrada para validacao do lote escolhido na separacao

Default lReiSeqAb  := .F.
Default lCnsPkgFut := .F.

	// Valida se lote informado na ordem de serviço, senão apaga
	If Self:nContPrd == 1 .And. Empty(Self:oOrdServ:oProdLote:GetLoteCtl())
		Self:oMovPrdLot:SetLoteCtl("")
		Self:oMovPrdLot:SetNumLote("")
	EndIf
	//Limpa estrutura física
	Self:oEstFis:SetEstFis("")
	// Permite substituir a busca de saldo padrão
	If lWMSQYSEP
		cAliasD14 := ExecBlock("WMSQYSEP",.F.,.F.,{Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEnder(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),lCnsPkgFut, Self:oOrdServ:GetCliFor()})
		cAliasD14 := Iif(ValType(cAliasD14)=="C",cAliasD14,"")
	EndIf
	If Empty(cAliasD14)
		//Realiza query para buscar os endereços com saldo
		cAliasD14 := Self:QryEstEnd(lCnsPkgFut)
	Else
		lLogMsgPE := .T.
	EndIf
	If Self:oOrdServ:GetRegra() == "4" .And. Self:aLogSld != Nil
		AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0005,{{"[VAR01]",Self:oMovPrdLot:GetArmazem()}}),{}}) // Armazém [VAR01] - Busca de saldo por data de validade
		If lLogMsgPE
			Self:AddMsgLog(,,,,,,,Self:nQuant,,STR0046) // O saldo a ser utilizado foi retornado pelo PE WMSQYSEP
		EndIf
	EndIf
	Do While (cAliasD14)->(!Eof())
		lFoundD14 := .T.

		//Usado apenas para carregar informação de armazém e estrutura física no relatório
		//e para reduzir as leituras repetidas na tabela de estrutura física
		If (cAliasD14)->D14_ESTFIS != Self:oEstFis:GetEstFis()
			//Se achar estrutura física no array, não faz leitura
			lEstFisChg := .T.

			lEstFis := .F.			
			For nEstFis := 1 To Len(aEstFis)
				If AllTrim(aEstFis[nEstFis]:GetEstFis()) == AllTrim((cAliasD14)->D14_ESTFIS)
					Self:oEstFis := aEstFis[nEstFis]
 					lEstFis := .T.
					Exit
				EndIf
			Next nEstFis

			// Se não achar estrutura física no array, carrega as informações 
			If !lEstFis			
				Self:oEstFis:SetEstFis((cAliasD14)->D14_ESTFIS)
				Self:oEstFis:LoadData()
				Aadd(aEstFis, Self:oEstFis)
 			EndIf

			//Apresenta informações no relatório
			If !lCnsPkgFut .And. !(Self:oOrdServ:GetRegra() == "4") .And. Self:aLogSld != Nil
				AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0006,{{"[VAR01]",Self:oMovEndOri:GetArmazem()},{"[VAR02]",Self:oEstFis:GetEstFis()},{"[VAR03]",Self:oEstFis:GetDesEst()}}),{}}) // Armazém [VAR01] - Busca de saldo na estrutura [VAR02] - [VAR03]
				If lLogMsgPE
					Self:AddMsgLog(Self:oMovSeqAbt:GetEstFis(),,,,,,,Self:nQuant,,STR0046) // O saldo a ser utilizado foi retornado pelo PE WMSQYSEP
				EndIf
			EndIf
		EndIf

		// Desconsidera endereços bloqueados - Lê direto da query para performance
		If (cAliasD14)->BE_STATUS == "3"
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0010) // Endereço bloqueado. (SBE)
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Desconsidera endereços bloqueados de saída - Lê direto da query para performance
		If (cAliasD14)->BE_STATUS == "5"
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0028) // Endereço com bloqueio de saída. (SBE)
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Desconsidera endereços bloqueados de inventario - Lê direto da query para performance
		If (cAliasD14)->BE_STATUS == "6"
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0029) // Endereço com bloqueio de inventário. (SBE)
			(cAliasD14)->(DbSkip())
			Loop
		EndIf

		nQtdSaldo := (cAliasD14)->D14_SALDO
		// Se for por data de validade, não carregou previamente a estrutura fisica
		If lEstFisChg
			lEstFisChg := .F.

			lPulEstFis := .F.

 			Self:oMovEndOri:SetEstFis((cAliasD14)->D14_ESTFIS)
			// Carrega as informações da sequencia de abastecimento
			Self:oMovSeqAbt:SetOrdem((cAliasD14)->DC3_ORDEM)
			Self:oMovSeqAbt:LoadData()
			Self:nQtdApUni := Self:oMovSeqAbt:GetQtMinSp() //DC3->DC3_QTDUNI
			Self:nQtdNorma := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEstFis(),/*cDesUni*/,.F.,Self:oMovEndOri:GetEnder())
			If !(Self:oOrdServ:GetRegra() == "4")
				If !lReiSeqAb .And. Self:oMovSeqAbt:GetTipoSep() == "1" // Somente a norma completa
					Self:nQtdApUni := Self:nQtdNorma
				Else
					Self:nQtdApUni := Min(Self:nQtdApUni,Self:nQtdNorma)
				EndIf
				If Self:oEstFis:GetTipoEst() == "2" // Picking
					//Se permite alterar o tipo de apanhe do pulmão
					If lWmsQtAp .And. !lReiSeqAb
						//Busca a quantidade máxima para o apanhe
						nQtdApMax := Self:oMovSeqAbt:ApMaxPic()
						//Se a quantidade solicitada é maior que o apanhe máximo do picking
					    If QtdComp(Self:nQuant) > QtdComp(nQtdApMax)
							lReiSeqAb  := .T.
							lValFinEnd := .F.
							Self:AddMsgLog(Self:oMovSeqAbt:GetEstFis(),,,,,,,Self:nQuant,,WmsFmtMsg(STR0032,{{"[VAR01]",Str(nQtdApMax)}})) // Quantidade solicitada maior que percentual de apanhe máximo do picking ([VAR01]).
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		// Quando a regra de separação for diferente da regra por lote mais antigo
		//verifica se a quantidade a separar é menor que a norma/apanhe mínimo
		If !(Self:oOrdServ:GetRegra() == "4")
			If QtdComp(Self:nQuant) < QtdComp(Self:nQtdApUni)
				If !lPulEstFis
					If Self:oMovSeqAbt:GetTipoSep() == "1" 
						Self:AddMsgLog(Self:oEstFis:GetEstFis(),,,,,,,Self:nQuant,,WmsFmtMsg(STR0007,{{"[VAR01]",Str(Self:nQtdNorma)}})) //Tipo de separação: Somente norma. Quantidade menor que uma norma completa ([VAR01]).
					Else
						Self:AddMsgLog(Self:oEstFis:GetEstFis(),,,,,,,Self:nQuant,,WmsFmtMsg(STR0008,{{"[VAR01]",Str(Self:nQtdApUni)}})) //  Tipo de separação: Quantidade mínima. Qtd menor que a separação mínima. ([VAR01]).
					EndIf
				EndIf
				lPulEstFis := .T.
			EndIf
		EndIf

        If lPeWMSAVLT //Ponto de entrada para validacao do lote escolhido na separacao
            lLtOK := ExecBlock('WMSAVLT',.F.,.F.,{(cAliasD14)->D14_ESTFIS, (cAliasD14)->D14_ENDER, (cAliasD14)->D14_LOTECT,  ;
                                                  (cAliasD14)->D14_NUMLOT, (cAliasD14)->D14_DTVALD, (cAliasD14)->D14_IDUNIT, ;
                                                  (cAliasD14)->D14_QTDLIB, (cAliasD14)->D14_QTDSPR, Self:nQuant, Self })
            If ValType(lLtOK) =='L'
                if !(lLtOK) //Se retornou .F. então procura o próximo endereço
					(cAliasD14)->(DbSkip())
					Loop
                EndIf
            EndIf
        EndIf

		//Caso a separação não possa ser realizada para a estrutura em questão, ignora todos os outros endereços que possuam a mesma estrutura física
		If lPulEstFis
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		Self:cIdUnitiz := (cAliasD14)->D14_IDUNIT //Id Unitizador
		Self:cTipUni   := (cAliasD14)->D14_CODUNI //Tipo Unitizador
		// Analisa empenho do lote
		If Self:nContPrd == 1 .And. Self:oMovPrdLot:HasRastro() .And. Empty(Self:oOrdServ:oProdLote:GetLoteCtl())
			If QtdComp(nQtdSaldo) > 0 
				//Preenche informações sobre o saldo do lote D14/SB8
				aSldD14 := Self:SldPrdLot((cAliasD14)->D14_LOTECT,(cAliasD14)->D14_NUMLOT)
				nSldD14 := aSldD14[1] //Quantidade em estoque do lote (D14)
				nEmpD14 := aSldD14[2] //Quantidade de empenho e empenho previsto do lote (D14)
				nEmpSB8 := 0
				cAliasSB8 := GetNextAlias()
				BeginSql Alias cAliasSB8
					SELECT SB8.B8_EMPENHO
					FROM %Table:SB8% SB8
					WHERE SB8.B8_FILIAL = %xFilial:SB8%
					AND SB8.B8_PRODUTO = %Exp:Self:oMovPrdLot:GetPrdOri()%
					AND SB8.B8_LOCAL = %Exp:Self:oMovPrdLot:GetArmazem()%
					AND SB8.B8_LOTECTL = %Exp:(cAliasD14)->D14_LOTECT%
					AND SB8.B8_NUMLOTE = %Exp:(cAliasD14)->D14_NUMLOT%
					AND SB8.%NotDel%
				EndSql
				If (cAliasSB8)->(!Eof())
					nEmpSB8 := ((cAliasSB8)->B8_EMPENHO * Self:oMovPrdLot:oProduto:oProdComp:GetQtMult()) //Quantidade de empenho do lote (SB8)
				EndIf
				(cAliasSB8)->(dbCloseArea())
				//Verifica se a quantidade empenhada do lote (SB8) é maior que a quantidade empenhada dos endereços (D14)
				//Caso for maior, indica que existem ordens de serviços que estão pendentes de execução para o lote (lote informado no pedido) 
				If QtdComp(nEmpSB8) > QtdComp(nEmpD14)
					//Calcula a quantidade disponível para o lote 
					nSaldoDis := nSldD14 - nEmpSB8
					//Se sobrou saldo disponível, utiliza para realizar a separação
					If QtdComp(nSaldoDis) > 0
						//Se a quantidade disponível do lote for menor que a quantidade solicitada, assume a nova quantidade disponível para a separação
						If QtdComp(nSaldoDis) < QtdComp(nQtdSaldo)
							nQtdSaldo := nSaldoDis
						EndIf
					Else
						nQtdSaldo := 0
					EndIf
				EndIf
			EndIf
			If QtdComp(nQtdSaldo) <= 0
				nQtdSaldo := 0
				Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0037) // Empenho previsto do lote no Estoque ainda não efetivado no WMS. Verifique OS pendentes execução.
				(cAliasD14)->(DbSkip())
				Loop
			EndIf
		EndIf
		// Descontar do saldo os movimentos de RF pendentes
		If QtdComp(nQtdSaldo) <= QtdComp(0)
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0011) // Saldo utilizado para outros movimentos.
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Se o saldo for menor que o apanhe unitário minimo, não utiliza o saldo
		If QtdComp(nQtdSaldo) < QtdComp(Self:nQtdApUni)
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,WmsFmtMsg(STR0012,{{"[VAR01]",Str(Self:nQtdApUni)}})) // Saldo menor que o apanhe mínimo da estrutura ([VAR01]).
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Se separar somente o saldo restante e for maior que o solicitado, não utiliza o saldo
		If !lReiSeqAb .And. Self:oMovSeqAbt:GetTipoSep() == "2" .And. QtdComp(nQtdSaldo) > QtdComp(Self:nQuant)
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0013) // Tipo de separação: Saldo restante. Saldo maior que o solicitado.
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		lRegraOK := .T.
		cMensag  := ""
		If Empty(Self:oOrdServ:GetRegra())
			lRegraOK := .T.
		ElseIf Self:oOrdServ:GetRegra() == "1"
			lRegraOK := Iif(!Empty(Self:xRegra),(cAliasD14)->D14_LOTECT==Self:xRegra,.T.)
			cMensag := STR0049 + (cAliasD14)->D14_LOTECT + STR0050 + Self:xRegra  // "Lote item WMS: "+ (cAliasD14)->D14_LOTECT + " Lote Regra: " + Self:xRegra
		ElseIf Self:oOrdServ:GetRegra() == "2"
			lRegraOK := Iif(!Empty(Self:xRegra),(cAliasD14)->D14_NUMSER==Self:xRegra,.T.)                                                                                                          
			cMensag := STR0051 + (cAliasD14)->D14_NUMSER + STR0052 + Self:xRegra  //  "Num. Série item WMS: "  + (cAliasD14)->D14_NUMSER +  " Num. Série Regra: " + Self:xRegra
		ElseIf Self:oOrdServ:GetRegra() == "3"
			lRegraOK := Iif(!Empty(Self:xRegra),(cAliasD14)->D14_DTVALD>=Self:xRegra,.T.)
			cMensag := STR0053 + cValToChar((cAliasD14)->D14_DTVALD) + STR0054 + cValToChar(Self:xRegra) //"Validade item WMS: "  + cValToChar((cAliasD14)->D14_DTVALD) + " menor que data Regra: " +cValToChar(Self:xRegra) 
		EndIf
		If !lRegraOK
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0014+cMensag) // "Regra WMS impede utilização saldo. "
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Valida se controla rastro e não aceita lotes vencidos
		If Self:oMovPrdLot:HasRastro() .And. !lConsVenc .And. !((cAliasD14)->D14_DTVALD >= dDataBase)
		    Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0038) // Lote com a data de validade vencida!
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Inicializa Unitizador Armazem
		If !Empty(Self:cIdUnitiz) .And. !Empty(Self:cTipUni)
			oUnitArm := WMSDTCUnitizadorArmazenagem():New()
			oUnitArm:SetTipUni(Self:cTipUni)
			If oUnitArm:LoadData() .And. oUnitArm:GetCtrNor()
				lUtilNorm := .T.
			EndIf 
			FreeObj(oUnitArm)
		EndIf
		nQtdSep := Min(nQtdSaldo,Self:nQuant)
		//-- Valida se a quantidade é multipla da 2aUM do produto
		nQtdSep := Self:RetQtdMul(nQtdSep)
		If QtdComp(nQtdSep) <= QtdComp(0)
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0031) // Múltiplo da quantidade solicitada menor que 2a UM do produto ou menor que a separação mínima.
			(cAliasD14)->(DbSkip())
			Loop
		EndIf

		// Desconsidera SBE não encontrado - falha de integridade
		Self:oMovEndOri:SetEnder((cAliasD14)->D14_ENDER)
		If !Self:oMovEndOri:LoadData()
			Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,,STR0009) // Endereço não cadastradado. (SBE)
			(cAliasD14)->(DbSkip())
			Loop
		EndIf
		// Verifica se a Atividade utiliza Radio Frequencia
		// Carregas as exceções das atividades na origem
		Self:oMovEndOri:ExceptEnd()

		// Carregando as informações do movimento
		Self:oMovPrdLot:SetLoteCtl((cAliasD14)->D14_LOTECT) // Lote
		Self:oMovPrdLot:SetNumLote((cAliasD14)->D14_NUMLOT) // Sub-Lote
		Self:oMovPrdLot:SetNumSer((cAliasD14)->D14_NUMSER)  // Numero de serie
		Self:oMovPrdLot:SetDtValid((cAliasD14)->D14_DTVALD) // Data de validade
		// Logando que o endereço será utilizado
		Self:AddMsgLog((cAliasD14)->D14_ESTFIS,(cAliasD14)->D14_ENDER,(cAliasD14)->D14_LOTECT,(cAliasD14)->D14_DTVALD,(cAliasD14)->D14_IDUNIT,(cAliasD14)->D14_QTDLIB,(cAliasD14)->D14_QTDSPR,Self:nQuant,nQtdSep,STR0016) // Endereço utilizado.
		// Atividades do pedido
		If Self:oOrdServ:GetOrigem() == 'SC9'
			//Liberação do pedido
			Self:SetLibPed(Self:oMovServic:GetLibPed())
			// Servico monta volume
			Self:cMntVol  := IIf(Empty(Self:oMovServic:GetMntVol()),"0",Self:oMovServic:GetMntVol())
			// Servico Distribui Separação
			Self:cDisSep  := IIf(Empty(Self:oMovServic:GetDisSep()),"2",Self:oMovServic:GetDisSep())
		EndIf
		// Atividades da requisição
		If Self:oOrdServ:GetOrigem() $ 'SD4|DH1'
			// Baixa estoque movimento interno de requisição
			Self:cBxEsto  := IIf(Empty(Self:oMovServic:GetBxEsto()),"2",Self:oMovServic:GetBxEsto())
		EndIf
		// Enquanto for maior que zero, vai separando a quantidade de uma norma ou o restante
		// Gera Empenho por produto e lote
		If Self:nContPrd == 1 .And. Self:oMovPrdLot:HasRastro() .And. Empty(Self:oOrdServ:oProdLote:GetLoteCtl())
			lRet := Self:oOrdServ:UpdEmpSB8("+",Self:oMovPrdLot:GetPrdOri(),Self:oMovPrdLot:GetArmazem(),Self:oMovPrdLot:GetLoteCtl(),Self:oMovPrdLot:GetNumLote(),(nQtdSep / Self:oOrdServ:oProdLote:GetArrProd()[1,2]))
		EndIf
		// Gera movimentos pela norma
		Do While lRet .And. QtdComp(nQtdSep) > QtdComp(0)
			// Status movimento
			Self:cStatus   := IIf(Self:oMovServic:GetBlqSrv() == "1","2",IIf(lCnsPkgFut,"2","4"))
			// Verifica se é um movimento com unitizador e
			// o unitizador não controla norma para quebrar as movimentos em normas
			If !Empty(Self:cIdUnitiz) .And. !Empty(Self:cTipUni) .And. !lUtilNorm
				Self:nQtdMovto := nQtdSep
			Else
				Self:nQtdMovto := Min(nQtdSep,Self:nQtdNorma)
			EndIf
			nQtdSep     -= Self:nQtdMovto
			Self:nQuant -= Self:nQtdMovto
			// Gera empenho somente se endereço origem não definido na ordem de serviço.
			If lRet .And. !Self:oOrdServ:ChkMovEst()
				lRet := Self:MakeOutput()
				If lRet
					lRet := Self:MakeInput()
				EndIf
			EndIf
			// Gera movimentos WMS			
			If !Self:AssignD12()
				lRet := .F.
			EndIf
		EndDo
		If !lRet
			Exit
		EndIf
		// Conseguiu atender toda a quantidade solicitada
		If QtdComp(Self:nQuant) <= QtdComp(0)
			Exit
		EndIf
		(cAliasD14)->(DbSkip())
	EndDo
	(cAliasD14)->(DbCloseArea())
	dbSelectArea("D14") 
	// Para tratamento do Rastro
	If lRet .And. lValFinEnd .And. !lFoundD14 .And. !lCnsPkgFut
		If !(Self:oOrdServ:GetRegra() == "4") .And. Self:aLogSld != Nil
			AAdd(Self:aLogSld[Len(Self:aLogSld),7],{WmsFmtMsg(STR0044,{{"[VAR01]",Self:oMovPrdLot:GetArmazem()}}),{}}) // Armazém [VAR01] - Busca de saldo
		EndIf
		Self:AddMsgLog(,,,,,,,Self:nQuant,,STR0034) // Não possui saldo no armazem.
	EndIf
	Self:oMovEndOri:SetEnder("")
	RestArea(aAreaAnt)

	aSize(aEstFis, 0)
	aEstFis := {}

Return lRet

METHOD QryEstEnd(lCnsPkgFut) CLASS WMSBCCSeparacao
Local aTamSX3   := TamSx3("D14_QTDEST")
Local cQuery    := ""
Local cAliasD14 := GetNextAlias()
	cQuery :=              "% CASE DC8.DC8_TPESTR"
	If Self:oMovServic:ChkSepNorm() // Separação com ou sem volume
		cQuery +=           " WHEN '4' THEN 1" 
		cQuery +=           " WHEN '6' THEN 2" 
		cQuery +=           " WHEN '1' THEN 3" 
		cQuery +=           " WHEN '2' THEN 4" 
		cQuery +=           " WHEN '3' THEN 5 END DC3_REGRA,"
	Else // Separaçao cross docking com e sem volume
		cQuery +=           " WHEN '3' THEN 1" 
		cQuery +=           " WHEN '6' THEN 2" 
		cQuery +=           " WHEN '4' THEN 3" 
		cQuery +=           " WHEN '1' THEN 4" 
		cQuery +=           " WHEN '2' THEN 5 END DC3_REGRA,"
	EndIf
	cQuery +=           " CASE DC3.DC3_UMMOV"
	cQuery +=               " WHEN '1' THEN 2" 
	cQuery +=               " WHEN '2' THEN 1" 
	cQuery +=               " WHEN '3' THEN 3"
	cQuery +=               " ELSE 2 END DC3_UMMOV,"
	cQuery +=           " DC3_ORDEM,"
	cQuery +=           " DC3_QTDUNI,"
	cQuery +=           " D14_ENDER,"
	cQuery +=           " D14_ESTFIS,"
	cQuery +=           " D14_LOTECT,"
	cQuery +=           " D14_NUMLOT,"
	cQuery +=           " D14_DTVALD,"
	cQuery +=           " D14_NUMSER,"
	cQuery +=           " D14_PRIOR,"
	If lCnsPkgFut
		cQuery +=       " ((D14_QTDEST+D14_QTDEPR)-(D14_QTDEMP+D14_QTDBLQ)) D14_QTDLIB,"
		cQuery +=       " ((D14_QTDEST+D14_QTDEPR)-(D14_QTDEMP+D14_QTDBLQ+D14_QTDSPR)) D14_SALDO,"
	Else
		cQuery +=       " (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ)) D14_QTDLIB,"
		cQuery +=       " (D14_QTDEST-(D14_QTDEMP+D14_QTDBLQ+D14_QTDSPR)) D14_SALDO,"
	EndIf
	cQuery +=           " D14_QTDSPR,"
	cQuery +=           " D14_QTDPEM,"
	cQuery +=           " D14_IDUNIT,"
	cQuery +=           " D14_CODUNI,"
	cQuery +=           " BE_STATUS,"
	If !lCnsPkgFut
		cQuery +=       " CASE WHEN DC8.DC8_TPESTR "+Iif(!Self:lFefoBlFr,"IN ('4','6')","= '4'")+" THEN ((BE_VALNV1+BE_VALNV2+BE_VALNV3+BE_VALNV4)*"+Iif(Self:lBlOrdDec,"(-1)","1")+") ELSE 0 END SBE_ORDCOR"
	Else
		cQuery +=       " 0 SBE_ORDCOR"
	EndIf
	cQuery +=  " FROM "+RetSqlName("D14")+" D14"
	// Quando separa por data de validade não segue a sequencia de abastecimento
	cQuery +=     " INNER JOIN "+RetSqlName("DC3")+" DC3"
	cQuery +=        " ON DC3.DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=       " AND DC3.DC3_CODPRO = D14.D14_PRODUT"
	cQuery +=       " AND DC3.DC3_LOCAL  = D14.D14_LOCAL"
	cQuery +=       " AND DC3.DC3_TPESTR = D14.D14_ESTFIS"
	cQuery +=       " AND DC3.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN "+RetSqlName("DC8")+" DC8"
	cQuery +=        " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=       " AND DC8.DC8_CODEST = D14.D14_ESTFIS"
	cQuery +=       " AND DC8.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN "+RetSqlName("SBE")+" SBE"
	cQuery +=        " ON SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
	cQuery +=       " AND SBE.BE_LOCAL   = D14.D14_LOCAL"
	cQuery +=       " AND SBE.BE_LOCALIZ = D14.D14_ENDER"
	cQuery +=       " AND SBE.BE_ESTFIS  = D14.D14_ESTFIS"
	cQuery +=       " AND SBE.D_E_L_E_T_ = ' '"
	cQuery +=     " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=       " AND D14.D14_LOCAL  = '"+Self:oMovEndOri:GetArmazem()+"'"
	cQuery +=       " AND D14.D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
	cQuery +=       " AND D14.D14_PRDORI = '"+Self:oMovPrdLot:GetPrdOri()+"'"
	If !Empty(Self:oMovEndOri:GetEnder())
		cQuery +=   " AND D14.D14_ENDER = '"+Self:oMovEndOri:GetEnder()+"'"
	EndIf
	If !Empty(Self:oMovPrdLot:GetLoteCtl())
		cQuery +=   " AND D14.D14_LOTECT = '"+Self:oMovPrdLot:GetLoteCtl()+"'"
	EndIf
	If !Empty(Self:oMovPrdLot:GetNumLote())
		cQuery +=   " AND D14.D14_NUMLOT = '"+Self:oMovPrdLot:GetNumLote()+"'"
	EndIf
	// Apenas as estruturas que permitem a separação
	If lCnsPkgFut
		cQuery +=   " AND DC8.DC8_TPESTR = '2'"
		cQuery +=   " AND ((D14.D14_QTDEST+D14.D14_QTDEPR)-(D14.D14_QTDEMP+D14.D14_QTDBLQ)) > 0"
	Else
		cQuery +=   " AND DC8.DC8_TPESTR IN ('1','2','3','4','6')"
		cQuery +=   " AND (D14.D14_QTDEST-(D14.D14_QTDEMP+D14.D14_QTDBLQ)) > 0"
	EndIf
	// // somente se não for regra de data de validade, senão apenas busca o produto mais antigo
	If Self:oOrdServ:GetRegra() <> "4"
		cQuery +=   " AND (DC8.DC8_TPESTR <> '3' OR"
		cQuery +=        " NOT EXISTS(SELECT 1 FROM "+RetSqlName("D10")+" D10"
		cQuery +=                    " WHERE D10.D10_FILIAL = '"+xFilial("D10")+"'"
		cQuery +=                     " AND (D10.D10_CLIENT <> '"+Self:oOrdServ:GetCliFor()+"' "
		cQuery +=                          " OR D10.D10_LOJA <> '"+Self:oOrdServ:GetLoja()+"')"
		cQuery +=                          " AND D10.D10_LOCAL = '"+Self:oMovEndOri:GetArmazem()+"'"
		cQuery +=                          " AND D10.D10_ENDER = D14.D14_ENDER"
		cQuery +=                          " AND D10.D_E_L_E_T_ = ' ' ))"
	EndIf
	cQuery +=       " AND D14.D_E_L_E_T_ = ' '"
	If Self:oOrdServ:GetRegra() == "4"
		// Ordenar consulta -> Dt.Validade Lote + Prioridade + Endereco
		cQuery += " ORDER BY D14_DTVALD,"
		cQuery +=          " D14_DTFABR," 
		cQuery +=          " DC3_QTDUNI DESC,"
		cQuery +=          " DC3_UMMOV,"
		cQuery +=          " DC3_ORDEM,"
		cQuery +=          " D14_PRIOR,"
		cQuery +=          " D14_IDUNIT,"
		cQuery +=          " D14_ENDER"
	ElseIf Self:oOrdServ:GetRegra() == "1"
		// Ordenar consulta -> Prioridade + Lote + Sub-Lote + Endereco
		cQuery += " ORDER BY DC3_REGRA,"
		cQuery +=          " DC3_QTDUNI DESC,"
		cQuery +=          " DC3_UMMOV,"
		cQuery +=          " DC3_ORDEM,"
		cQuery +=          " D14_PRIOR,"
		cQuery +=          " SBE_ORDCOR,"
		cQuery +=          " D14_LOTECT,"
		cQuery +=          " D14_NUMLOT,"
		cQuery +=          " D14_IDUNIT,"
		cQuery +=          " D14_ENDER"
	Else // Data (Default)
		cQuery += " ORDER BY DC3_REGRA,"
		cQuery +=          " DC3_QTDUNI DESC,"
		cQuery +=          " DC3_UMMOV,"
		cQuery +=          " DC3_ORDEM,"
		cQuery +=          " D14_PRIOR,"
		cQuery +=          " SBE_ORDCOR,"
		cQuery +=          " D14_DTVALD,"
		cQuery +=          " D14_DTFABR,"
		cQuery +=          " D14_LOTECT,"
		cQuery +=          " D14_NUMLOT,"
		cQuery +=          " D14_IDUNIT,"
		cQuery +=          " D14_ENDER"
	EndIf
	cQuery += "%"
	BeginSql Alias cAliasD14
		SELECT %Exp:cQuery%
	EndSql
	// Ajustando o tamanho dos campos da query
	TcSetField(cAliasD14,'D14_DTVALD','D')
	TcSetField(cAliasD14,'D14_QTDLIB','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDSPR','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_QTDPEM','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD14,'D14_SALDO','N',aTamSX3[1],aTamSX3[2])
Return cAliasD14
/*/-----------------------------------------------------------------------------
Analisa a capacidade do endereço de picking e verificar se o mesmo necessita de
reabastecimento após um processo de separação no mesmo.
Para isto analisa se o endereço possui um percentual de reposição e ao retirar
a quantidade para separação atingiu este percentual de reposição ou ficou zerado
e o sistema está parametrizado para reabastecer endereço de picking vazios.
-----------------------------------------------------------------------------/*/
METHOD PerRepPkg(nQtdAbast,nQtdSep) CLASS WMSBCCSeparacao
Local lRet       := .F.
Local nCapEndPkg := 0
Local nReposicao := 0
Local nSaldoEnd  := 0
Local nTipoPerc  := 0
Local nQtdAbtPE  := 0
	nQtdAbast  := 0
	nCapEndPkg := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEstFis(),/*cDesUni*/,.T.,Self:oMovEndOri:GetEnder())
	nReposicao := nCapEndPkg - ((Self:oMovSeqAbt:GetPercRep()/100) * nCapEndPkg)
	// Carrega dados para consulta de saldo do produto no endereço
	Self:oEstEnder:ClearData()
	Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
	Self:oEstEnder:oEndereco:SetEnder(Self:oMovEndOri:GetEnder())
	// Caso o produto possua percentual de ocupação, deve considerar o saldo do endereço somente por produto
	If WmsChkDCP(Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEnder(),Self:oMovEndOri:GetEstFis(),Self:oMovSeqAbt:GetCodNor(),Self:oMovPrdLot:GetProduto(),@nTipoPerc) .And. nTipoPerc == 1
		Self:oEstEnder:oProdLote:SetArmazem(Self:oMovPrdLot:GetArmazem()) // Armazem
		Self:oEstEnder:oProdLote:SetProduto(Self:oMovPrdLot:GetProduto()) // Produto Principal
	EndIf
	nSaldoEnd := Self:oEstEnder:ConsultSld(.T.,.T.,.F.,.F.)
	nSaldoEnd -= nQtdSep
	If QtdComp(nReposicao) >= QtdComp(nSaldoEnd) // Se o saldo é menor que o mínimo para reposição
		If ExistBlock("DLQTDABT")
			nQtdAbtPE := ExecBlock('DLQTDABT',.F.,.F.,{Self:oMovEndOri:GetArmazem(),Self:oMovEndOri:GetEnder(),Self:oMovPrdLot:GetProduto(),nQtdSep})
			If ValType(nQtdAbtPE) == 'N'
				nQtdAbast := nQtdAbtPE
			EndIf
		EndIf
		If nQtdAbast <= 0
			nQtdAbast := nCapEndPkg-nSaldoEnd
		EndIf
		lRet := .T.
	Else
		Self:cErro := STR0047 //Percentual da taxa de reposição não atingido.
	EndIf
Return lRet

// Geração de abastecimento para endereços de picking vazios
METHOD GeraAbtDem(lGeraAbast,nQtdApanhe,aSeqAbPkg) CLASS WMSBCCSeparacao
Local lRet       := .T.
Local lFirstRat  := .T.
Local lPercOcup  := .F.
Local lUsaEndDem := .F.
Local lWMSQABDM  := ExistBlock("WMSQABDM")
Local aAreaAnt   := GetArea()
Local aTamSX3    := TamSx3('D14_QTDEST')
Local aEnderecos := {}
Local aGerPkMa   := {}
Local oAbastece  := Nil
Local cEndereco  := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cNumSer    := ""
Local cQuery     := ""
Local cQueryPE   := ""
Local cAliasQry  := GetNextAlias()
Local cWmsMulP   := SuperGetMV("MV_WMSMULP", .F., "N")
Local nLimSBE    := SuperGetMV("MV_WMSNRPO", .F., 10) // Limite de enderecos picking ocupados
Local nLimSBEPE  := 0
Local nCapEndPkg := 0
Local nQtdAbast  := 0
Local nX         := 0
Local nI         := 0
Local nSaldoD14  := 0
	// Ponto de entrada para permitir alterar o numero de 
	// limite de endereços de picking
	If lWMSNRPKG
		nLimSBEPE := ExecBlock("WMSNRPKG", .F., .F.,{nLimSBE})
		nLimSBE := Iif(ValType(nLimSBEPE)=="N",nLimSBEPE,nLimSBE)
	EndIf
	// Para os casos em que a seq. de abastecimento do produto possuir mais de uma estrutura do tipo
	// picking, deve realizar a busca por estrutura, para que reabasteça corretamente todas elas.
	For nI := 1 To Len(aSeqAbPkg)
		Self:oMovSeqAbt:SetOrdem(aSeqAbPkg[nI][1])
		Self:oMovSeqAbt:LoadData()
		// Somente estruturas que estejam parametrizadas para reabastecimento automático
		If Self:oMovSeqAbt:GetPercRep() <= 0
			Self:AddMsgLog(Self:oMovSeqAbt:GetEstFis(),,,,,,,nQtdApanhe,,STR0042) // Estrutura picking não permite reabastecimento automático.
			Loop
		EndIf
		// Somente reabastece, caso a quantidade minima de separação da estrtura seja menor que o solicitado
		If QtdComp(Self:oMovSeqAbt:GetQtMinSp()) > QtdComp(nQtdApanhe)
			Self:AddMsgLog(Self:oMovSeqAbt:GetEstFis(),,,,,,,nQtdApanhe,,WmsFmtMsg(STR0008,{{"[VAR01]",Str(Self:oMovSeqAbt:GetQtMinSp())}})) // "Tipo de separação: Quantidade mínima. Qtd menor que a separação mínima. ([VAR01])."
			Loop
		EndIf
		cQuery := "SELECT ZON.ZON_ORDEM,"
		// Se foi informado o produto no endereço ele tem prioridade
		cQuery +=       " CASE WHEN SBE.BE_CODPRO = '"+Space(TamSx3("BE_CODPRO")[1])+"' THEN 3 ELSE 1 END PRD_ORDEM,"
		cQuery +=       " SBE.BE_LOCALIZ,"
		// Carregando endereços que possuam saldo
		cQuery +=       " (SELECT CASE WHEN sum(D14_QTDEST) IS NULL THEN 0 ELSE sum(D14_QTDEST) END D14_QTDEST"
		cQuery +=          " FROM "+RetSqlName("D14")+" D14"
		cQuery +=         " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=           " AND D14_LOCAL = '"+Self:oMovPrdLot:GetArmazem()+"'"
		cQuery +=           " AND D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=           " AND D14_ENDER = BE_LOCALIZ"
		cQuery +=           " AND D14_ESTFIS = BE_ESTFIS"
		cQuery +=           " AND D14_QTDEST > 0"
		cQuery +=           " AND D_E_L_E_T_ = ' ') D14_QTDEST,"
		// Carregando o saldo previsto de entrada
		cQuery +=       " (SELECT CASE WHEN sum(D14_QTDEPR) IS NULL THEN 0 ELSE sum(D14_QTDEPR) END D14_QTDEPR"
		cQuery +=          " FROM "+RetSqlName("D14")+" D14"
		cQuery +=         " WHERE D14_FILIAL = '"+xFilial("D14")+"'"
		cQuery +=           " AND D14_LOCAL = '"+Self:oMovPrdLot:GetArmazem()+"'"
		cQuery +=           " AND D14_PRODUT = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=           " AND D14_ENDER = BE_LOCALIZ"
		cQuery +=           " AND D14_ESTFIS = BE_ESTFIS"
		cQuery +=           " AND D14_QTDEPR > 0"
		cQuery +=           " AND D_E_L_E_T_ = ' ') D14_QTDEPR"
		cQuery +=  " FROM "+RetSqlName("SBE")+" SBE"
		// Somente considera as zonas de armazenagem na query
		cQuery += " INNER JOIN ("
		// Não utiliza do cadastro por que existe um PE que pode alterar, usa a variável
		cQuery +=        "SELECT '00' ZON_ORDEM, '"+Self:oMovPrdLot:GetCodZona()+"' ZON_CODZON"
		cQuery +=         " FROM "+RetSqlName("SB5")
		cQuery +=        " WHERE B5_FILIAL = '"+xFilial("SB5")+"'"
		cQuery +=          " AND B5_COD = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=          " AND D_E_L_E_T_ = ' '"
		cQuery +=        " UNION ALL"
		cQuery +=       " SELECT DCH_ORDEM ZON_ORDEM, DCH_CODZON ZON_CODZON"
		cQuery +=         " FROM "+RetSqlName("DCH")
		cQuery +=        " WHERE DCH_FILIAL = '"+xFilial("DCH")+"'"
		cQuery +=          " AND DCH_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"'"
		cQuery +=          " AND DCH_CODZON <> '"+Self:oMovPrdLot:GetCodZona()+"'"
		cQuery +=          " AND D_E_L_E_T_ = ' ') ZON"
		cQuery +=    " ON ZON.ZON_CODZON = SBE.BE_CODZON"
		cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
		cQuery +=   " AND SBE.BE_LOCAL   = '"+Self:oMovPrdLot:GetArmazem()+"'"
		cQuery +=   " AND SBE.BE_ESTFIS  = '"+Self:oMovSeqAbt:GetEstFis()+"'"
		cQuery +=   " AND (SBE.BE_CODPRO = ' ' OR SBE.BE_CODPRO = '"+Self:oMovPrdLot:GetProduto()+"')"
		// Considerar apenas os endereços sem bloqueio,
		// devido a utilização do reabastecimento para a separação
		cQuery +=   " AND SBE.BE_STATUS IN ('1','2')"
		cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY D14_QTDEST DESC,"
		cQuery +=          " D14_QTDEPR DESC,"
		cQuery +=          " ZON_ORDEM,"
		cQuery +=          " PRD_ORDEM,"
		cQuery +=          " BE_LOCALIZ"
		If lWMSQABDM
			cQueryPE := ExecBlock('WMSQABDM',.F.,.F.,{cQuery})
			If !Empty(cQueryPE)
				cQuery := cQueryPE
			EndIf
		EndIf
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		TcSetField(cAliasQry,'D14_QTDEST', 'N',aTamSX3[1],aTamSX3[2])
		TcSetField(cAliasQry,'D14_QTDEPR', 'N',aTamSX3[1],aTamSX3[2])
		TcSetField(cAliasQry,'PRD_ORDEM' , 'N',1         ,0         )
		Do While (cAliasQry)->(!Eof())
			lUsaEndDem := .F.
			// Avalia se utiliza o endereço de picking, 
			// não existindo o ponto de entrada efetua 
			// a avaliação de capacidade e percentual de ocupação 
			If lWMSAENDE
				lRetPE     := ExecBlock("WMSAENDE", .F., .F.,{Self:oMovEndOri:GetArmazem(),(cAliasQry)->BE_LOCALIZ,Self:oMovPrdLot:GetProduto(),nQtdApanhe,(cAliasQry)->D14_QTDEST,(cAliasQry)->D14_QTDEPR})
				lUsaEndDem := Iif(ValType(lRetPE)=="L",lRetPE,lUsaEndDem)
			Else
				//Verifica se o endereço utiliza percentual de ocupação
				lPercOcup := WmsChkDCP(Self:oMovEndOri:GetArmazem(),(cAliasQry)->BE_LOCALIZ,Self:oMovSeqAbt:GetEstFis(),Self:oMovSeqAbt:GetCodNor(),Self:oMovPrdLot:GetProduto())
				// Se não possuir percentual de ocupação, deve avaliar se existe
				// saldo de outro produto no endereço. Neste caso não reabastece.
				If !lPercOcup
					// Carrega dados para consulta de saldo do produto no endereço
					Self:oEstEnder:ClearData()
					Self:oEstEnder:oEndereco:SetArmazem(Self:oMovEndOri:GetArmazem())
					Self:oEstEnder:oEndereco:SetEnder((cAliasQry)->BE_LOCALIZ)
					nSaldoD14 := Self:oEstEnder:ConsultSld(.T.,.F.,.F.,.F.)
					nSaldoD14 -= ((cAliasQry)->D14_QTDEST+(cAliasQry)->D14_QTDEPR)
					lUsaEndDem := (QtdComp(nSaldoD14) <= 0)
				Else
					lUsaEndDem := .T.
				EndIf
			EndIf
			If lUsaEndDem
				nCapEndPkg := DLQtdNorma(Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetArmazem(),Self:oMovSeqAbt:GetEstFis(),/*cDesUni*/,.T.,(cAliasQry)->BE_LOCALIZ)
				AAdd(aEnderecos,{(cAliasQry)->ZON_ORDEM,;
									Self:oMovSeqAbt:GetOrdem(),;
									Iif((cAliasQry)->PRD_ORDEM==3 .And. QtdComp((cAliasQry)->D14_QTDEST+(cAliasQry)->D14_QTDEPR)>0,2,(cAliasQry)->PRD_ORDEM),;
									Self:oMovSeqAbt:GetEstFis(),;
									(cAliasQry)->BE_LOCALIZ,;
									(cAliasQry)->D14_QTDEST,;
									(cAliasQry)->D14_QTDEPR,;
									nCapEndPkg})
				If (nLimSBE > 0 .And. nLimSBE <= Len(aEnderecos)) .Or. cWmsMulP == "N"
					Exit
				EndIf
			Else
				// Se o produto possui saldo do produto, porém possui saldo de outros produtos - picking misto
				If ((cAliasQry)->D14_QTDEST+(cAliasQry)->D14_QTDEPR) > 0
					Self:AddMsgLog(Self:oMovSeqAbt:GetEstFis(),(cAliasQry)->BE_LOCALIZ,,,,(cAliasQry)->D14_QTDEST,(cAliasQry)->D14_QTDEPR,Self:nQuant,,STR0041) // Endereço possui saldo de outros produtos.
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())
	Next
	aSeqAbPkg := {}
	If Len(aEnderecos) > 0
		// Pego todos os endereços, vai ordenar os mesmos do menor saldo para o maior saldo
		// Esta lógica é para fazer um "rateio" do reabastecimento, forçando todos os endereços ficarem abastecidos
		ASort(aEnderecos,,,{|x,y| x[1]+x[2]+Str(x[3])+StrZero((x[6]+x[7]),aTamSX3[1],aTamSX3[2])+x[5] > y[1]+y[2]+Str(y[3])+StrZero((y[6]+y[7]),aTamSX3[1],aTamSX3[2])+y[5]})

		nX := 1
		// Enquanto houver saldo a ser reabastecido
		Do While lRet .And. QtdComp(nQtdApanhe) > 0
			// Se é a primeira vez que está passando e o endereço está cheio, tenta outro
			If !lFirstRat .Or. QtdComp(aEnderecos[nX,6]+aEnderecos[nX,7]) < QtdComp(aEnderecos[nX,8])
				// Se a capacidade do endereço é maior que o saldo do mesmo, tente reabastecer a diferença
				If QtdComp(aEnderecos[nX,8]) > QtdComp(aEnderecos[nX,6]+aEnderecos[nX,7])
					// Se possuir só um endereço, deverá tentar reabastecer tudo para este
					If Len(aEnderecos) == 1
						nQtdAbast := Max(aEnderecos[nX,8] - (aEnderecos[nX,6]+aEnderecos[nX,7]),nQtdApanhe)
					Else // Senão reabastece até completar o saldo apenas
						nQtdAbast := aEnderecos[nX,8] - (aEnderecos[nX,6]+aEnderecos[nX,7])
					EndIf
				Else // Senão tenta jogar mais mais saldo
					nQtdAbast := Min(aEnderecos[nX,8], nQtdApanhe)
				EndIf
				// Atribui o endereço origem para separação,
				// pois será reapassado como destino para o reabastecimento
				Self:oMovEndOri:SetEnder(aEnderecos[nX,5])
				// Cria nova instância do objeto toda vez para que os valores sejam zerados
				oAbastece := WMSBCCAbastecimento():New()
				oAbastece:SetMovSepOri(Self,IIf(Self:nContPrd == 1,.F.,.T.))
				// Endereço está vazio, reabastece a quantidade total
				oAbastece:SetQuant(nQtdAbast)
				oAbastece:SetTipReab("D")
				lRet := oAbastece:ExecFuncao()
				//Se não gerou o reabastecimento, sai fora e aborta o processo
				If !lRet
					Self:cErro := oAbastece:GetErro()
					Exit
				EndIf
				// Se não conseguiu reabastecer nada, vai sair, pois não tem saldo para reabastecimento
				If QtdComp(oAbastece:oOrdServ:GetQuant()) <= 0
					Self:AddMsgLog(,,,,,,,Self:nQuant,,STR0045) // Não possui saldo para reabastecimento por demanda.
					Exit
				Else
					If !Empty(oAbastece:aGerReab)
						For nI := 1 To Len(oAbastece:aGerReab)
							Self:oEstFis:SetEstFis(oAbastece:aGerReab[nI][1])
							If Self:oEstFis:LoadData() .And. Self:oEstFis:GetTipoEst() == "2"
								AAdd(aGerPkMa,{oAbastece:aGerReab[nI][1],oAbastece:aGerReab[nI][2],oAbastece:aGerReab[nI][9]}) // Endereços de Pick Utilizados no abastecimento principal
							EndIf

							Self:AddMsgLog(oAbastece:aGerReab[nI][1],oAbastece:aGerReab[nI][2],oAbastece:aGerReab[nI][3],oAbastece:aGerReab[nI][5],oAbastece:aGerReab[nI][6],oAbastece:aGerReab[nI][7],oAbastece:aGerReab[nI][8],oAbastece:oOrdServ:GetQuant(),oAbastece:aGerReab[nI][9],STR0024,.T.) // Reabastecimento gerado para o endereço.
							// Conta TODOS os reabastecimentos que foram gerados durante a separação
							Self:nGerReab++
						Next nI
					EndIf
					aEnderecos[nX,7] += oAbastece:oOrdServ:GetQuant() // Soma o saldo no endereço abastecido, para calculos de rateio
					nQtdApanhe -= oAbastece:oOrdServ:GetQuant() // Diminui a quantidade abastecida da solicitada para separar
					lGeraAbast := .T.
					// Adiciona a sequencia de abastecimento para processar
					If AScan(aSeqAbPkg,{|x| x[1] == aEnderecos[nX,2]}) == 0
						AAdd(aSeqAbPkg,{aEnderecos[nX,2]})
					EndIf
					If !Empty(aGerPkMa)
						// Guarda os dados do abastecimento utilizado para separação
						cEndereco := Self:oMovEndOri:GetEnder()
						cLoteCtl  := Self:oMovPrdLot:GetLoteCtl()
						cNumLote  := Self:oMovPrdLot:GetNumLote()
						cNumSer   := Self:oMovPrdLot:GetNumSer()
						For nI := 1 To Len(aGerPkMa) 
							// Carrega as informações da estrutura fisica
							Self:oEstFis:SetEstFis(aGerPkMa[nI][1])
							Self:oEstFis:LoadData()
							Self:oMovEndOri:SetEnder(aGerPkMa[nI][2])
							Self:oMovEndOri:LoadData()
							// Carregando as informações do movimento
							Self:oMovPrdLot:SetLoteCtl("") // Lote
							Self:oMovPrdLot:SetNumLote("") // Sub-Lote
							Self:oMovPrdLot:SetNumSer("")  // Numero de serie
							// Gera reabastecimento
							Self:GerAbast(aGerPkMa[nI][3])
							
						Next nI
						// Restaura os dados do abastecimento utilizado para separação
						Self:oMovEndOri:SetEnder(cEndereco)  // Endereço
						Self:oMovEndOri:LoadData()
						Self:oMovPrdLot:SetLoteCtl(cLoteCtl) // Lote
						Self:oMovPrdLot:SetNumLote(cNumLote) // Sub-Lote
						Self:oMovPrdLot:SetNumSer(cNumSer)   // Numero de serie
					EndIf
				EndIf
				FreeObj(oAbastece)
			EndIf
			// Se chegou no ultimo endereço volta para o primeiro
			If (nX+1) > Len(aEnderecos)
				nX := 1
				lFirstRat := .F.
			Else
				nX++
			EndIf
		EndDo
	Else
		Self:AddMsgLog(Self:oMovSeqAbt:GetEstFis(),,,,,,,Self:nQuant,,STR0036) // Não há endereços de picking vazios disponíveis para o reabastecimento.
	EndIf
	// Só marcar que gerou reabastecimento, se conseguiu atender todo o solicitado para separação
	If lGeraAbast
		lGeraAbast := (QtdComp(nQtdApanhe) <= 0)
	EndIf
	RestArea(aAreaAnt)
Return(lRet)
//--------------------------------------------------
/*/{Protheus.doc} UpdControl
Atualização de controles da separação
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//--------------------------------------------------
METHOD UpdControl() CLASS WMSBCCSeparacao
Local lRet        := .T.
Local aAreaAnt    := GetArea()
Local aTamSX3     := TamSx3("DCR_QUANT")
Local oOrdSerAux  := Nil
Local cAliasD12   := Nil
Local cAliasQry   := Nil
Local cIdDCFPld   := ""
Local cSeqDCPld   := ""
Local cLoteCtlVz  := Space(TamSx3("D4_LOTECTL")[1])
Local cNumLoteVz  := Space(TamSx3("D4_NUMLOTE")[1])
Local nNewRecno   := 0

	// Quando primeiro produto
	// Origem SD4
	// Transferência entre armazéns, elimina a DH1
	If Self:nContPrd == 1 
		If !Empty(Self:aOrdAglu)
			aEval(Self:aOrdAglu,{|x| cIdDCFPld += "'"+x[1]+"'," })
			aEval(Self:aOrdAglu,{|x| cSeqDCPld += "'"+x[4]+"'," })
			cIdDCFPld := Substr(cIdDCFPld,1,Len(cIdDCFPld)-1)
			cSeqDCPld := Substr(cSeqDCPld,1,Len(cSeqDCPld)-1)
		Else
			cIdDCFPld := "'"+Self:oOrdServ:GetIdDCF()+"'"
			cSeqDCPld := "'"+Self:oOrdServ:GetSequen()+"'"
		EndIf
		cIdDCFPld := "%"+cIdDCFPld+"%"
		cSeqDCPld := "%"+cSeqDCPld+"%"
		oOrdSerAux := WMSDTCOrdemServico():New()
		If Self:oOrdServ:GetOrigem() == "SD4" .And. Self:oMovEndOri:GetArmazem() != Self:oMovEndDes:GetArmazem()
			cAliasD12 := GetNextAlias()
			BeginSql Alias cAliasD12
				SELECT DISTINCT DCR.DCR_IDDCF
				FROM %Table:DCR% DCR
				INNER JOIN %Table:D12% D12
				ON D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
				AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
				AND D12.D12_IDDCF = DCR.DCR_IDORI
				AND D12.D12_IDMOV = DCR.DCR_IDMOV
				AND D12.D12_IDOPER = DCR.DCR_IDOPER
				AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()% // Assume a tarefa exatamante anterior
				AND D12.D12_ORDMOV IN ('3','4')
				AND D12.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				// Quando por plano separação busca a quantidade de todas as ordens de serviço
				AND DCR.DCR_IDDCF IN ( %Exp:cIdDCFPld% )
				AND DCR.DCR_SEQUEN IN ( %Exp:cSeqDCPld% )
				AND DCR.%NotDel%
			EndSql
			Do While lRet .And. (cAliasD12)->(!Eof())
				oOrdSerAux:SetIdDCF((cAliasD12)->DCR_IDDCF)
				If oOrdSerAux:LoadData()
					cAliasDH1 := GetNextAlias()
					BeginSql Alias cAliasDH1
						SELECT DH1.R_E_C_N_O_ RECNODH1
						FROM %Table:DH1% DH1
						WHERE DH1.DH1_FILIAL = %xFilial:DH1%
						AND DH1.DH1_IDDCF = %Exp:oOrdSerAux:GetIdDCF()%
						AND DH1.%NotDel%
						ORDER BY DH1.R_E_C_N_O_
					EndSql
					Do While (cAliasDH1)->(!Eof())
						DH1->(dbGoTo((cAliasDH1)->RECNODH1))
						RecLock("DH1",.F.)
						DH1->(dbDelete())
						DH1->(MsUnlock())
						(cAliasDH1)->(dbSkip())
					EndDo
					// Retira a reserva da SB2 da quantidade cancelada
					oOrdSerAux:UpdEmpSB2("-",oOrdSerAux:oProdLote:GetPrdOri(),oOrdSerAux:oOrdEndOri:GetArmazem(),oOrdSerAux:GetQuant())
					
					(cAliasDH1)->(dbCloseArea())
				EndIf
				(cAliasD12)->(dbSkip())
			EndDo
			(cAliasD12)->(dbCloseArea())
		EndIf
		// Buscar as ordens de serviço para ajustar os pedidos ou as requisições
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT 	D12.D12_LOCORI,
					D12.D12_PRODUT,
					D12.D12_PRDORI,
					D12.D12_LOTECT,
					D12.D12_NUMLOT,
					D12.D12_NUMSER,
					DCR.DCR_IDDCF,
					SUM(DCR.DCR_QUANT) DCR_QUANT
			FROM %Table:DCR% DCR
			INNER JOIN %Table:D12% D12
			ON D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
			AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
			AND D12.D12_IDDCF = DCR.DCR_IDORI
			AND D12.D12_IDMOV = DCR.DCR_IDMOV
			AND D12.D12_IDOPER = DCR.DCR_IDOPER
			AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()% // Assume a tarefa exatamante anterior
			AND D12.D12_ORDMOV IN ('3','4')
			AND D12.%NotDel%
			WHERE DCR.DCR_FILIAL = %xFilial:DCR%
			// Quando por plano separação busca a quantidade de todas as ordens de serviço
			AND DCR.DCR_IDDCF IN ( %Exp:cIdDCFPld% )
			AND DCR.DCR_SEQUEN IN ( %Exp:cSeqDCPld% )
			AND DCR.%NotDel%
			GROUP BY D12.D12_LOCORI,
						D12.D12_PRODUT,
						D12.D12_PRDORI,
						D12.D12_LOTECT,
						D12.D12_NUMLOT,
						D12.D12_NUMSER,
						DCR.DCR_IDDCF
			ORDER BY D12.D12_PRODUT,
						D12.D12_LOTECT,
						D12.D12_NUMLOT
		EndSql
		TcSetField(cAliasD12,'DCR_QUANT','N',aTamSX3[1],aTamSX3[2])
		Do While lRet .And. (cAliasD12)->(!Eof())
			
			/*	Quando há mais de um lote do mesmo produto para separação na mesma OS,
			  	verifica se o lote carregado no objeto esta de acordo com o lote retornado pela consulta,
			  	se não estiver, faz a carga e o load dos dados novamente	*/
			If Self:oOrdServ:GetOrigem() == "SC9" .And. Self:oMovPrdLot:GetLoteCtl() != (cAliasD12)->D12_LOTECT
				// Busca dados Produto/Lote
				Self:oMovPrdLot:SetArmazem((cAliasD12)->D12_LOCORI)
				Self:oMovPrdLot:SetPrdOri((cAliasD12)->D12_PRDORI)
				Self:oMovPrdLot:SetProduto((cAliasD12)->D12_PRODUT)
				Self:oMovPrdLot:SetLoteCtl((cAliasD12)->D12_LOTECT)
				Self:oMovPrdLot:SetNumLote((cAliasD12)->D12_NUMLOT)
				Self:oMovPrdLot:SetNumSer((cAliasD12)->D12_NUMSER)
				Self:oMovPrdLot:LoadData()
			EndIf
			
			// Busca quantidade multipla quando componente
			If !(Self:oMovPrdLot:GetPrdOri() == Self:oMovPrdLot:GetProduto())
				Self:oMovPrdLot:oProduto:oProdComp:SetPrdCmp((cAliasD12)->D12_PRODUT)
				Self:oMovPrdLot:oProduto:oProdComp:LoadData(2)
			EndIf

			// Atualiza SC9
			If Self:oOrdServ:GetOrigem() == "SC9"
				oOrdSerAux:SetIdDCF((cAliasD12)->DCR_IDDCF)
				If oOrdSerAux:LoadData()
					lRet := WmsDivSC9(oOrdSerAux:GetCarga(),;
										oOrdSerAux:GetDocto(),;
										oOrdSerAux:GetSerie(),;
										oOrdSerAux:oProdLote:GetProduto(),;
										oOrdSerAux:oServico:GetServico(),;
										(cAliasD12)->D12_LOTECT,;
										(cAliasD12)->D12_NUMLOT,;
										(cAliasD12)->D12_NUMSER,;
										((cAliasD12)->DCR_QUANT / Self:oMovPrdLot:oProduto:oProdComp:GetQtMult()),;
										/*nQuant2UM*/,;
										oOrdSerAux:oOrdEndDes:GetArmazem(),;
										oOrdSerAux:oOrdEndDes:GetEnder(),;
										oOrdSerAux:GetIdDCF(),;
										.F.,;
										.F.,;
										"01",;
										Nil,;
										Nil,;
										Nil,;
										.T.,,;
										Self:oMovPrdLot:GetDtValid())
										
				EndIf
			ElseIf Self:oOrdServ:GetOrigem() == "SD4"
				oOrdSerAux:SetIdDCF((cAliasD12)->DCR_IDDCF)
				If oOrdSerAux:LoadData()
					nQtdSld := ((cAliasD12)->DCR_QUANT / Self:oMovPrdLot:oProduto:oProdComp:GetQtMult())
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SD4.R_E_C_N_O_ RECNOSD4
						FROM %Table:SD4% SD4
						WHERE SD4.D4_FILIAL = %xFilial:SD4%
						AND (SD4.D4_LOTECTL = %Exp:cLoteCtlVz% OR SD4.D4_LOTECTL = %Exp:(cAliasD12)->D12_LOTECT% )
						AND (SD4.D4_NUMLOTE = %Exp:cNumLoteVz% OR SD4.D4_NUMLOTE = %Exp:(cAliasD12)->D12_NUMLOT% )
						AND SD4.D4_IDDCF = %Exp:oOrdSerAux:GetIdDCF()%
						AND SD4.%NotDel%
					EndSql
					Do While (cAliasQry)->(!Eof()) .And. nQtdSld > 0
 						SD4->(dbGoTo((cAliasQry)->RECNOSD4))
						WmsDivSD4(SD4->D4_COD,;
								oOrdSerAux:oOrdEndDes:GetArmazem(),;
								SD4->D4_OP,;
								SD4->D4_TRT,;
								(cAliasD12)->D12_LOTECT,;
								(cAliasD12)->D12_NUMLOT,;
								(cAliasD12)->D12_NUMSER,;
								nQtdSld,;
								Nil,;
								oOrdSerAux:oOrdEndDes:GetEnder(),;
								oOrdSerAux:GetIdDCF(),;
								.F.,;
								SD4->(Recno()),;
								Nil,;
								@nNewRecno,;
								.F.,;
								oOrdSerAux:oOrdEndOri:GetArmazem())
						SD4->(dbGoTo((cAliasQry)->RECNOSD4))		
						nQtdSld -= SD4->D4_Quant 
						SD4->(dbGoTo(nNewRecno))
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
					// Transferência entre armazéns gera DH1 conforme os lotes
				EndIf
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
		//
		If lRet .And. Self:oOrdServ:GetOrigem() == "SD4" .And. Self:oMovEndOri:GetArmazem() != Self:oMovEndDes:GetArmazem()
			cAliasD12 := GetNextAlias()
			BeginSql Alias cAliasD12
				SELECT DISTINCT DCR.DCR_IDDCF
				FROM %Table:DCR% DCR
				INNER JOIN %Table:D12% D12
				ON  D12.D12_FILIAL = %xFilial:D12%
				AND D12.D12_SERVIC = %Exp:Self:oMovServic:GetServico()%
				AND D12.D12_PRODUT = %Exp:Self:oMovPrdLot:GetProduto()%
				AND D12.D12_IDDCF = DCR.DCR_IDORI
				AND D12.D12_IDMOV = DCR.DCR_IDMOV
				AND D12.D12_IDOPER = DCR.DCR_IDOPER
				AND D12.D12_ORDTAR = %Exp:Self:oMovServic:GetOrdem()% // Assume a tarefa exatamante anterior
				AND D12.D12_ORDMOV IN ('3','4')
				AND D12.%NotDel%
				WHERE DCR.DCR_FILIAL = %xFilial:DCR%
				// Quando por plano separação busca a quantidade de todas as ordens de serviço
				AND DCR.DCR_IDDCF IN ( %Exp:cIdDCFPld% )
				AND DCR.DCR_SEQUEN IN ( %Exp:cSeqDCPld% )
				AND DCR.%NotDel%
			EndSql
			Do While lRet .And. (cAliasD12)->(!Eof())
				oOrdSerAux:SetIdDCF((cAliasD12)->DCR_IDDCF)
				If oOrdSerAux:LoadData()
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT SD4.R_E_C_N_O_ RECNOSD4
						FROM %Table:SD4% SD4
						WHERE SD4.D4_FILIAL = %xFilial:SD4%
						AND SD4.D4_IDDCF = %Exp:oOrdSerAux:GetIdDCF()%
						AND SD4.%NotDel%
					EndSql
					If (cAliasQry)->(!Eof())
					EndIf
					Do While (cAliasQry)->(!Eof())
						SD4->(dbGoTo((cAliasQry)->RECNOSD4))
						// Dados lote e sublote
						oOrdSerAux:oProdLote:SetLoteCtl(SD4->D4_LOTECTL)
						oOrdSerAux:oProdLote:SetNumLote(SD4->D4_NUMLOTE)
						// Dados Requisição
						oOrdSerAux:SetOp(SD4->D4_OP)
						oOrdSerAux:SetTrt(SD4->D4_TRT)
						oOrdSerAux:SetQuant(SD4->D4_QUANT)
						// Passa a referência da OS para a função
						WmsOrdSer(oOrdSerAux)
						lRet := WmsGeraDH1("WMSBCCSeparacao",.F.,.F.)
						(cAliasQry)->(dbSkip())
					EndDo
					(cAliasQry)->(dbCloseArea())
				EndIf
				(cAliasD12)->(dbSkip())
			EndDo
			(cAliasD12)->(dbCloseArea())
		EndIf
		RestArea(aAreaAnt)
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RetQtdMul
Retorna a quantidade múltipla com base na segunda unidade de medida do produto

@author alexsader.correa
@since 01/09/2016
@version 1.0
/*/
//--------------------------------------------------
METHOD RetQtdMul(nQtdApEnd) CLASS WMSBCCSeparacao
Local nQtdMul 	:= nQtdApEnd
Local nEnMinimo	:= 1 / (10 ** TamSX3('DC3_ENDMIN')[2]) //--Baseado na lógica utilizada na propriedade nQtdMinEnd da classe WMSDTCSequenciaAbastecimento

	If Self:oMovPrdLot:GetConv() != 0 .And. Self:oMovSeqAbt:GetUMMovto() == "2" .And. !Self:oMovSeqAbt:HasMinSep()
		If Self:oMovPrdLot:GetTipConv() == "D"
			nQtdMul := NoRound(nQtdApEnd / Self:oMovPrdLot:GetConv(), 0) * Self:oMovPrdLot:GetConv()
		EndIf
	ElseIf Self:nQtdApUni > nEnMinimo //--Se a separação for maior que o mínimo divisível, efetua o cálculo da quantidade múltipla pela separação mínima
		nQtdMul := NoRound(nQtdApEnd / Self:nQtdApUni, 0) * Self:nQtdApUni
	EndIf

Return nQtdMul
//--------------------------------------------------
/*/{Protheus.doc} GerAbast
Gera reabastecimento por percentual de reposição

@author alexsader.correa
@since 03/07/2019
@version 1.0
/*/
//--------------------------------------------------
METHOD GerAbast(nQtdSep,lGerouReab) CLASS WMSBCCSeparacao
Local lRet       := .T.
Local aGerPkMa   := {}
Local oAbastece  := Nil
Local cEndereco  := ""
Local cLoteCtl   := ""
Local cNumLote   := ""
Local cNumSer    := ""
Local nI         := 0
Local nQtdAbast  := 0

Default nQtdSep    := 0
Default lGerouReab := .F.

	// Deve validar se é um endereço de picking, e se deve gerar reabastecimento para o mesmo
	If Self:oEstFis:GetTipoEst() == "2" .And. (Self:lPrdTemPul .Or. Self:oMovSeqAbt:HasPickMas()) .And. Self:oMovSeqAbt:GetPercRep() > 0
		// Desconsidera endereços bloqueados entrada
		If Self:oMovEndOri:GetStatus() == "4"
			Self:AddMsgLog(Self:oEstFis:GetEstFis(),Self:oMovEndOri:GetEnder(),,,,,,,,STR0030,.T.) // Endereço com bloqueio de entrada. (SBE)
		Else
			If Self:PerRepPkg(@nQtdAbast,nQtdSep)
				// Cria nova instância do objeto toda vez para que os valores sejam zerados
				oAbastece := WMSBCCAbastecimento():New()
				oAbastece:SetMovSepOri(Self,.F.)
				oAbastece:SetQuant(nQtdAbast)
				oAbastece:SetTipReab("A") // Reabastecimento por percentual de reposição automático
				If !oAbastece:ExecFuncao()
					Self:cErro := oAbastece:GetErro()
					lRet := .F.
				EndIf
				If lRet
					If QtdComp(oAbastece:oOrdServ:GetQuant()) > 0
						lGerouReab := .T.
						If !Empty(oAbastece:aGerReab)
							For nI := 1 To Len(oAbastece:aGerReab)
								Self:oEstFis:SetEstFis(oAbastece:aGerReab[nI][1])
								If Self:oEstFis:LoadData() .And. Self:oEstFis:GetTipoEst() == "2"
									AAdd(aGerPkMa,{oAbastece:aGerReab[nI][1],oAbastece:aGerReab[nI][2],oAbastece:aGerReab[nI][9]}) // Endereços de Pick Utilizados no abastecimento principal
								EndIf
								// Grava log
								Self:AddMsgLog(oAbastece:aGerReab[nI][1],oAbastece:aGerReab[nI][2],oAbastece:aGerReab[nI][3],oAbastece:aGerReab[nI][5],oAbastece:aGerReab[nI][6],oAbastece:aGerReab[nI][7],oAbastece:aGerReab[nI][8],oAbastece:oOrdServ:GetQuant(),oAbastece:aGerReab[nI][9],STR0024,.T.) // Reabastecimento gerado para o endereço.
								// Conta TODOS os reabastecimentos que foram gerados durante a separação
								Self:nGerReab++
							Next nI
						EndIf
					EndIf
				EndIf
				If lRet .And. lGerouReab .And. !Empty(aGerPkMa)
					// Guarda os dados do abastecimento utilizado para separação
					cEndereco := Self:oMovEndOri:GetEnder()
					cLoteCtl  := Self:oMovPrdLot:GetLoteCtl()
					cNumLote  := Self:oMovPrdLot:GetNumLote()
					cNumSer   := Self:oMovPrdLot:GetNumSer()
					For nI := 1 To Len(aGerPkMa) 
						// Carrega as informações da estrutura fisica
						Self:oEstFis:SetEstFis(aGerPkMa[nI][1])
						Self:oEstFis:LoadData()
						Self:oMovEndOri:SetEnder(aGerPkMa[nI][2])
						Self:oMovEndOri:LoadData()
						// Carregando as informações do movimento
						Self:oMovPrdLot:SetLoteCtl("") // Lote
						Self:oMovPrdLot:SetNumLote("") // Sub-Lote
						Self:oMovPrdLot:SetNumSer("")  // Numero de serie
						// Gera reabastecimento
						Self:GerAbast(aGerPkMa[nI][3])
					Next nI
					// Restaura os dados do abastecimento utilizado para separação
					Self:oMovEndOri:SetEnder(cEndereco)  // Endereço
					Self:oMovEndOri:LoadData()
					Self:oMovPrdLot:SetLoteCtl(cLoteCtl) // Lote
					Self:oMovPrdLot:SetNumLote(cNumLote) // Sub-Lote
					Self:oMovPrdLot:SetNumSer(cNumSer)   // Numero de serie
					
				EndIf
				FreeObj(oAbastece)
			EndIf
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} FindReabPK
Verifica se há endereços de picking para reabastecimento
por percentual de reposição

@author alexsader.correa
@since 03/07/2019
@version 1.0
/*/
//--------------------------------------------------
METHOD FindReabPK(lGerouReab) CLASS WMSBCCSeparacao
Local lRet       := .T.
Local lGerReab   := .F.
Local cAliasD12  := Nil
Local clistRecno := ""
Local nI         := 0
Local oSepAux    := Nil

	If !SuperGetMV("MV_WMSREAU", .F., .T.)	
		Self:cErro := STR0055 //Parâmetro MV_WMSREAU = .F.. Não será criada automaticamente OS reabastecimento por % de reposição.	
	Else
		oSepAux := WMSBCCSeparacao():New()
		
		// Busca os endereços de picking utilizado e avalia reabastecimento por percentual de reposição
		For nI := 1 To Len(Self:aRecD12)
			cListRecno += cValToChar(Self:aRecD12[nI][2])+","
		Next nI
		cListRecno := "%("+Substr(cListRecno,1,Len(cListRecno)-1)+")%"
		cAliasD12 := GetNextAlias()
		BeginSql Alias cAliasD12
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			INNER JOIN %Table:SBE% SBE
			ON SBE.BE_FILIAL = %xFilial:SBE%
			AND SBE.BE_LOCAL = D12.D12_LOCORI
			AND SBE.BE_LOCALIZ = D12.D12_ENDORI
			AND SBE.%NotDel%
			INNER JOIN %Table:DC8% DC8
			ON DC8.DC8_FILIAL = %xFilial:DC8%
			AND DC8.DC8_CODEST = SBE.BE_ESTFIS
			AND DC8.DC8_TPESTR = '2'
			AND DC8.%NotDel%
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.R_E_C_N_O_ IN %Exp:cListRecno%
			AND D12.D12_ATUEST = '1'
			AND D12.%NotDel%
		EndSql
		Do While (cAliasD12)->(!Eof())
			oSepAux:GoToD12((cAliasD12)->RECNOD12)
			// Carrega as informações da estrutura fisica
			oSepAux:oEstFis:SetEstFis(oSepAux:oMovEndOri:GetEstFis())
			oSepAux:oEstFis:LoadData()
			oSepAux:oMovSeqAbt:SetArmazem(oSepAux:oMovPrdLot:GetArmazem())
			oSepAux:oMovSeqAbt:SetProduto(oSepAux:oMovPrdLot:GetProduto())
			oSepAux:oMovSeqAbt:SetEstFis(oSepAux:oEstFis:GetEstFis())
			oSepAux:SetPrdTemPul(Self:lPrdTemPul)
			If oSepAux:oMovSeqAbt:FindSeqAbt()
				// Carrega as informações da sequencia de abastecimento
				oSepAux:oMovSeqAbt:SetOrdem(oSepAux:oMovSeqAbt:aSeqAbast[1][1])
				oSepAux:oOrdServ:SetArrLib({})
				If oSepAux:oMovSeqAbt:LoadData()
					oSepAux:GerAbast(,@lGerReab)
					If lGerReab .And. !lGerouReab
						lGerouReab := .T.
						If AttIsMemberOf(oSepAux,"aReabD12",.T.) 
							Self:SetReabD12(oSepAux:aRecD12)
						EndIf
					Else
						Self:cErro := STR0048+oSepAux:GetErro() //Tentativa reabast.
					EndIf
				EndIf
			EndIf
			(cAliasD12)->(dbSkip())
		EndDo
		(cAliasD12)->(dbCloseArea())
		FreeObj(oSepAux)
	EndIf
Return lRet

/*/-----------------------------------------------------------------------------
Adiciona mensagens ao registro de LOG de busca de saldo.
Formato ALogSld
	ALogSld[nX,1] = Carga
	ALogSld[nX,2] = Documento
	ALogSld[nX,3] = Produto
	ALogSld[nX,4] = Descrição Produto
	ALogSld[nX,5] = Quantidade Apanhe
	ALogSld[nX,6] = Regra WMS
	ALogSld[nX,7] = Array(2)
		ALogSld[nX,7,nY,1] = "Busca de saldo ..."
		ALogSld[nX,7,nY,2] = Array(6)
			ALogSld[nX,7,nY,2,nZ,1] = Estrutura Fisica
			ALogSld[nX,7,nY,2,nZ,2] = Endereço
			ALogSld[nX,7,nY,2,nZ,3] = Lote
			ALogSld[nX,7,nY,2,nZ,4] = Data Validade
			ALogSld[nX,7,nY,2,nZ,5] = Id Unitizador
			ALogSld[nX,7,nY,2,nZ,6] = Saldo Disponível Endereço
			ALogSld[nX,7,nY,2,nZ,7] = Saldo RF Saída
			ALogSld[nX,7,nY,2,nZ,8] = Quantidade Total a Separar
			ALogSld[nX,7,nY,2,nZ,9] = Quantidade Separada
			ALogSld[nX,7,nY,2,nZ,10] = Mensagem
			ALogSld[nX,7,nY,2,nZ,11] = Indica uma mensagem do reabastecimento
-----------------------------------------------------------------------------/*/
METHOD AddMsgLog(cEstrtura,cEndereco,cLoteCtl,dDtValid,cIdUnit,nSaldoD14,nSaldoRF,nTotSep,nQtdSep,cMensagem,lReabast) CLASS WMSBCCSeparacao
Local aLogMsg := Nil
Default cEstrtura := ""
Default cEndereco := ""
Default cLoteCtl  := ""
Default dDtValid  := CtoD('')
Default cIdUnit   := ""
Default nSaldoD14 := 0
Default nSaldoRF  := 0
Default nTotSep   := 0
Default nQtdSep   := 0
Default lReabast  := .F.
	If Self:aLogSld == Nil
		Return Nil
	EndIf
	aLogMsg := Self:aLogSld[Len(Self:aLogSld),7]
	AAdd(aLogMsg[Len(aLogMsg),2],{cEstrtura,cEndereco,cLoteCtl,dDtValid,cIdUnit,nSaldoD14,nSaldoRF,nTotSep,nQtdSep,cMensagem,lReabast})
Return (Nil)

METHOD AddInfoParametros() CLASS WMSBCCSeparacao
Local lUnicoReab := SuperGetMV("MV_WMSMABP", .F., "N")=="S"
Local lMultPick := SuperGetMV("MV_WMSMULP", .F., "N")=="S"
Local lNovoWMS := SuperGetMv("MV_WMSNEW",.F.,.F.)
Local lPickMaster := SuperGetMV("MV_WMSPKMA",.F.,.F.)
Local lReinBusca := SuperGetMV("MV_WMSQTAP",.F.,"N") == "S"
Local lLotesVenc := SuperGetMV('MV_LOTVENC', .F., 'N')=='S'
Local nNroPick := SuperGetMV("MV_WMSNRPO", .F., 10)
	Aadd(Self:aLogSld,{lUnicoReab, lMultPick, lNovoWMS, nNroPick, lPickMaster, lReinBusca, lLotesVenc})
Return

METHOD AddInfoOrdemServico() CLASS WMSBCCSeparacao
	AAdd(Self:aLogSld,{Self:oOrdServ:GetCarga(),Self:oOrdServ:GetDocto(),Self:oMovPrdLot:GetProduto(),Self:oMovPrdLot:GetDesc(),Self:nQuant,Self:oOrdServ:GetRegra(),{},{},Self:oOrdServ:oOrdEndDes:GetArmazem()})
Return

METHOD AddInfoProduto() CLASS WMSBCCSeparacao
Local oComplemento := Self:oMovPrdLot:oProduto
Local oProduto := Self:oMovPrdLot:oProduto:oProdGen
	Aadd(Self:aLogSld[Len(Self:aLogSld),8],{ oProduto:GetUM(), oProduto:GetSegum(), oProduto:GetConv(), oProduto:GetTipConv(), oComplemento:GetCodZona(), oComplemento:GetWmsEmb(), oComplemento:GetUMInd(), oComplemento:GetCtrlWMS(),Self:oOrdServ:oOrdEndDes:GetArmazem()})
Return
