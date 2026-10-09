#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Define ENTIDADE_REFER "AGD-TBDC"

/*/{Protheus.doc} AGDXTBDC
Realiza validações para permitir ou não a geração de transação no adapter
de dados mestres do AGD, enviando somente registros ativos ou aqueles que
já possuem De/Para cadastrado na base.
Rotina utilizada no valid (XX4_EXPFIL) dos adapters de integração.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Function AGDXTBDC()

	Local lRet      := .F.
	Local oModelAct := FwModelActive()

	// Só executa a regra se o Agrodistribuidor estiver ativo
	If !SuperGetMV("MV_SIGAAGD", .F., .F.)
		Return .F.
	EndIf

	Do Case
	Case IsRotina("AGDP060", oModelAct)
		lRet := ExpPropRural()

	Case IsRotina("CRMA980", oModelAct) .Or. IsRotina("MATA030", oModelAct)
		lRet := ExpCliente()

	Case IsRotina("MATA010", oModelAct)
		lRet := ExpProduto()

	Case IsRotina("MATA360", oModelAct)
		lRet := ExpCondPgto()

	Case IsRotina("OMSA010", oModelAct)
		lRet := ExpTabPreco()

	Case IsRotina("AGRA045", oModelAct)
		lRet := ExpArmazem()

	Case IsRotina("SCHEDESTMG", oModelAct)
		lRet := ExpSaldoEstoque()

	Case IsRotina("OGA100", oModelAct)
		lRet := ExpSafra()

	EndCase

Return lRet

/*/{Protheus.doc} IsRotina
Verifica se a rotina atual corresponde ao nome do programa informado,
considerando o nome do programa em execução e o model ativo.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@param cRotina, character, nome do programa/modelo a ser validado
@param oModelAct, object, model ativo da rotina
@return logical, resultado da verificação
/*/
Static Function IsRotina(cRotina, oModelAct)

	Local lRet := .F.

	cRotina := Upper(AllTrim(cRotina))

	// Verifica também pelo model ativo, quando existir
	If oModelAct != Nil .And. ValType(oModelAct) == "O"
		If !Empty(oModelAct:GetId()) .And. Upper(AllTrim(oModelAct:GetId())) == cRotina
			lRet := .T.
		EndIf
	EndIf

	// Verifica pelo nome do programa em execução
	If !lRet .And. Upper(AllTrim(FunName())) == cRotina
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} HasDePara
Verifica se o registro já possui De/Para cadastrado na base de integração.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@param cAlias, character, alias da tabela origem
@param cCampo, character, campo chave da origem
@param cChave, character, chave utilizada na busca do De/Para
@return logical, indica se existe De/Para
/*/
Static Function HasDePara(cAlias, cCampo, cChave)

	Local lRet := .F.
	Local cEntidade := ENTIDADE_REFER

	If !Empty(AllTrim(CFGA070Ext(cEntidade, cAlias, cCampo, cChave)))
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} ExpCliente
Valida se o cliente deve ser enviado pelo adapter, permitindo envio
somente para clientes não bloqueados ou que já possuam De/Para.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Static Function ExpCliente()

	Local lRet       := .F.
	Local lCliOk     := .F.
	Local lTemNEP    := .F.

	// Cliente deve estar ativo ou já possuir De/Para
	lCliOk := (SA1->A1_MSBLQL <> "1") .Or. ;
		HasDePara("SA1", "A1_COD", cEmpAnt + "|" + xFilial("SA1") + "|" + SA1->A1_COD + "|" + SA1->A1_LOJA + "|C")

	// Para envio do cliente, deve existir relacionamento com Propriedade Rural
	lTemNEP := HasDePara("NEP", "NEP_CODCLI", cEmpAnt + "|" + xFilial("NEP") + "|" + SA1->A1_COD + "|" + SA1->A1_LOJA)

	lRet := lCliOk .And. lTemNEP

Return lRet

/*/{Protheus.doc} ExpPropRural
Valida se a fazenda/propriedade rural deve ser enviada pelo adapter,
permitindo envio somente para propriedades rurais ou registros com De/Para.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Static Function ExpPropRural()

	Local lAtivo  := (NEP->NEP_PRORUR == "1")
	Local lDePara := HasDePara("NEP", "NEP_CODCLI", cEmpAnt + "|" + xFilial("NEP") + "|" + NEP->NEP_CODCLI + "|C")

Return (lAtivo .Or. lDePara)

/*/{Protheus.doc} ExpProduto
Valida se o produto deve ser enviado pelo adapter, permitindo envio
somente para produtos não bloqueados ou com De/Para já existente.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Static Function ExpProduto()

	Local lAtivo  := (SB1->B1_MSBLQL <> "1")
	Local lDePara := HasDePara("SB1", "B1_COD", cEmpAnt + "|" + xFilial("SB1") + "|" + SB1->B1_COD + "|C")

Return (lAtivo .Or. lDePara)

/*/{Protheus.doc} ExpCondPgto
Valida se a condição de pagamento deve ser enviada pelo adapter,
permitindo envio somente para registros não bloqueados ou com De/Para.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Static Function ExpCondPgto()

	Local lAtivo  := (SE4->E4_MSBLQL <> "1")
	Local lDePara := HasDePara("SE4", "E4_CODIGO", cEmpAnt + "|" + xFilial("SE4") + "|" + SE4->E4_CODIGO + "|C")

Return (lAtivo .Or. lDePara)

/*/{Protheus.doc} ExpTabPreco
Valida se a tabela de preço deve ser enviada pelo adapter,
permitindo envio somente para tabelas ativas ou com De/Para.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Static Function ExpTabPreco()

	Local lExisteNE8 := .F.
	Local lAtivo  := (DA0->DA0_ATIVO == "1")
	Local lDePara := HasDePara("DA0", "DA0_CODTAB", cEmpAnt + "|" + xFilial("DA0") + "|" + DA0->DA0_CODTAB)

	// Trava de seguranca: so integra DA0 se existir extensao correspondente na NE8.
	DBSelectArea("NE8")
	DBSetOrder(1) //NE8_FILIAL+NE8_CODTAB
	If DBSeek(xFilial("DA0") + DA0->DA0_CODTAB)
		lExisteNE8 := .T.
	EndIf

	// Sem registro na NE8, o item atual da DA0 deve ser ignorado (skip logico).
	If !lExisteNE8
		Return .F.
	EndIf

Return (lAtivo .Or. lDePara)

/*/{Protheus.doc} ExpArmazem
Valida se o armazém/local de estoque deve ser enviado pelo adapter,
permitindo envio somente para registros não bloqueados ou com De/Para.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 05/03/2026
@return logical, resultado da validação
/*/
Static Function ExpArmazem()

	Local lAtivo  := (NNR->NNR_MSBLQL <> "1")
	Local lDePara := HasDePara("NNR", "NNR_CODIGO", cEmpAnt + "|" + xFilial("NNR") + "|" + NNR->NNR_CODIGO + "|C")

Return (lAtivo .Or. lDePara)

/*/{Protheus.doc} ExpSaldoEstoque
Valida se o saldo de estoque deve ser enviado pelo adapter, permitindo envio
somente quando o produto e o local de estoque possuírem relacionamento De/Para.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 14/05/2026
@return logical, resultado da validação
/*/
Static Function ExpSaldoEstoque()

	Local lRet       := .F.
	Local lTemProd   := .F.
	Local lTemSB5    := .F.
	Local lTemArmz   := .F.

	lTemProd := HasDePara("SB1", "B1_COD", cEmpAnt + "|" + RTrim(xFilial("SB1")) + "|" + RTrim(SB2->B2_COD))

	lTemSB5  := HasDePara("SB5", "B5_COD", cEmpAnt + "|" + RTrim(xFilial("SB1")) + "|" + RTrim(SB2->B2_COD))

	lTemArmz := HasDePara("NNR", "NNR_CODIGO", cEmpAnt + "|" + RTrim(xFilial("NNR")) + "|" + RTrim(SB2->B2_LOCAL))

	lRet := lTemProd .And. lTemSB5 .And. lTemArmz

Return lRet

/*/{Protheus.doc} ExpSafra
Valida se os campos opcionais de safra estão preenchidos para permitir o envio pelo adapter, considerando a configuração do MV_SIGAAGD.
@type function
@version 12
@author jean.schulze
@since 20/05/2026
@return variant, resiultado da validação
/*/
Static Function ExpSafra()
Return !Empty(NJU->NJU_ANOSAF) .and. !Empty(NJU->NJU_DTINI) .and. !Empty(NJU->NJU_DTFIM)
