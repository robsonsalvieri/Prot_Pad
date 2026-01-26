#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDef.ch"
#INCLUDE "JURXFIN.CH"

Static _aDistBxAnt := {0, 0, 0, 0, 0, 0, 0} // Distribuição dos valores de baixas anteriores entre despesas e honorários, conforme parcelas
Static _aDistDesc  := {0, 0, 0, 0, 0, 0, 0} // Distribuição dos valores de descontos entre despesas e honorários, conforme parcelas
Static _aImpLanc   := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} JurListCon()
Retorna a lista de opções dos tipos de contas para o dicionário.

@author Bruno Ritter
@since 26/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurListCon()
Local oTpConta := JURTPCONTA():New()
Local cRet     := oTpConta:GetListDic()

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValSED()
Valida o campo e volta o valor padrão dos campos relacionados na função.
Valida se existe apenas uma natureza do tipo "6-Transitória de Pós pagamentos"
ou "8=Transitória de Recebimento"

@author Bruno Ritter
@since  26/07/2017
/*/
//-------------------------------------------------------------------
Function JurValSED()
Local aArea      := GetArea()
Local oTpConta   := JURTPCONTA():New()
Local lRet       := .T.
Local cCampo     := ReadVar()
Local cVlCampo   := &cCampo
Local cQuery     := ""
Local cQryRes    := ""
Local cCodigo    := ""
Local cDescTpCt  := ""
Local cMoeNac    := SuperGetMv('MV_JMOENAC',, '01')
Local cBoxTpCta  := ""
Local cTitCCJuri := ""

If "ED_CCJURI" $ cCampo

	lRet := Vazio() .Or. Pertence("12345678")

	If lRet .And. cVlCampo $ ("6|8")
		cQuery :=  "SELECT COUNT(SED.R_E_C_N_O_) RECNO, SED.ED_CODIGO "
		cQuery +=   " FROM " + RetSqlName("SED") + " SED "
		cQuery +=  " WHERE SED.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SED.ED_FILIAL = '" + xFilial("SED") + "'"
		cQuery +=    " AND SED.ED_CCJURI = '" + cVlCampo + "'"
		cQuery +=    " GROUP BY SED.ED_CODIGO"

		cQryRes := GetNextAlias()
		cQuery  := ChangeQuery(cQuery)

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

		If !((cQryRes)->RECNO == 0)
			cCodigo := (cQryRes)->ED_CODIGO
			lRet    := JurMsgErro(I18N(STR0004, {cCodigo, JurInfBox('ED_CCJURI', cVlCampo)}),, I18N(STR0005, {cCodigo}))
			//#"Natureza '#1' já está cadastrada com centro de custo '#2'." ##"Altere o centro custo na natureza '#1' ou informe outro centro de custo."
		EndIf

		(cQryRes)->( dbcloseArea() )
	EndIf

	// Valida natureza de impostos e centro de custo de profissional
	If lRet .And. M->ED_TPCOJR $ "6" .And. !Empty(cVlCampo) // 6-Obrigações
		cBoxTpCta  := JurInfBox("ED_TPCOJR", M->ED_TPCOJR, "3")
		cTitCCJuri := AllTrim(RetTitle("ED_CCJURI"))
		lRet       := JurMsgErro(I18N(STR0099, {'"' + cBoxTpCta + '"'}),, I18N(STR0100, {'"' + cTitCCJuri + '"', '"' + M->ED_CODIGO + '"'})) // "Naturezas com tipo conta #1 não devem conter centro de custo jurídico!" # "Limpe o conteúdo do campo #1 da natureza #2."
	EndIf

	// Valida naturezas transitórias
	If lRet .And. !Empty(cVlCampo) 
		If (M->ED_TPCOJR <> "1" .And. M->ED_CCJURI $ "6|7|8") .Or. (M->ED_TPCOJR == "1" .And. !(M->ED_CCJURI $ " |6|7|8"))
			lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle("ED_CCJURI")), AllTrim(RetTitle('ED_TPCOJR'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
		EndIf
	EndIf

ElseIf "ED_CFJUR" $ cCampo

	If M->ED_TPCOJR <> "1" .And. M->ED_CFJUR == "1"
		cDescTpCt := oTpConta:GetNmConta("1")
		lRet      := JurMsgErro(STR0018,, I18N(STR0019, {AllTrim(RetTitle('ED_CFJUR')), cDescTpCt})) // "O campo foi alterado de forma indevida." -- "O '#1' só pode ser utilizado com naturezas do tipo conta '#2'."
	EndIf

	If lRet
		If M->ED_CFJUR <> "2" .And. M->ED_CCJURI == "6"
			lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_CFJUR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
		EndIf
	EndIf

ElseIf "ED_BANCJUR" $ cCampo

	If M->ED_BANCJUR <> "2" .And. M->ED_CCJURI == "6"
		lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_BANCJUR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
	EndIf

	If M->ED_BANCJUR == "1" .And. M->ED_TPCOJR <> "1"
		lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_BANCJUR')), AllTrim(RetTitle('ED_TPCOJR'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
	EndIf

ElseIf "ED_CPJUR" $ cCampo

	If M->ED_CPJUR <> "1" .And. M->ED_CCJURI == "6"
		lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_CPJUR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
	EndIf

ElseIf "ED_CRJUR" $ cCampo

	If M->ED_CRJUR <> "2" .And. M->ED_CCJURI == "6"
		lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_CRJUR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
	EndIf

ElseIf "ED_CMOEJUR" $ cCampo

	lRet := (ExistCpo('CTO', M-> ED_CMOEJUR, 1) .AND. (JAVLDCAMPO('SEDMASTER', 'ED_CMOEJUR', 'CTO', 'CTO_BLOQ', '2' )))

	If lRet .And. M->ED_CMOEJUR <> cMoeNac .And. M->ED_CCJURI == "6"
		lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_CMOEJUR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
	EndIf

ElseIf "ED_TPCOJR" $ cCampo

	If M->ED_TPCOJR <> "1" // Diferente de '1 - Banco/Caixa'
		If M->ED_CCJURI $ "6|7|8" // Transitórias
			lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_TPCOJR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
		ElseIf M->ED_BANCJUR == "1"
			lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_TPCOJR')), AllTrim(RetTitle('ED_BANCJUR'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
		EndIf
	ElseIf !(M->ED_CCJURI $ " |6|7|8") // Igual a '1 - Banco/Caixa' e Centro de Custo diferente de Transitórias
		lRet := JurMsgErro(STR0018,, I18N(STR0022, {AllTrim(RetTitle('ED_TPCOJR')), AllTrim(RetTitle('ED_CCJURI'))})) // "O campo foi alterado de forma indevida." -- "O '#1' não pode ser alterado quando o '#2' estiver com este conteúdo."
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurWhenSED(cCampo)
Valida o When dos campos da pasta do júridico na SED

@Param  cCampo   Nome do campo da condição When

@author Bruno Ritter
@since 26/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurWhenSED(cCampo)
Local lRet     := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

Default cCampo := ""

If lRet .And. !Empty(cCampo)
	Do Case
	Case cCampo == "ED_CCJURI"
		lRet := M->ED_BANCJUR == "2"

	Case cCampo == "ED_RATJUR"
		lRet := M->ED_CCJURI=='4' .And. M->ED_BANCJUR == "2"

	Case cCampo $ "ED_CBANCO|ED_CAGENC|ED_CCONTA"
		If altera
			//verifica se existe lançamento, se existir nao pode ser alterado.
			lRet := JExitLanc()
			If lRet
				lRet := M->ED_BANCJUR == "1"
			EndIf
		Else
			lRet := M->ED_BANCJUR == "1"
		EndIf

	Case cCampo == "ED_TPCOJR"
		If altera
			//verifica se existe lançamento, se existir nao pode ser alterado.
			lRet := JExitLanc()
		EndIf

	Case cCampo == "ED_CMOEJUR"
		If altera
			//verifica se existe lançamento, se existir nao pode ser alterado.
			lRet := JExitLanc()
		EndIf

	Case cCampo == "ED_BANCJUR"
		If altera
			//verifica se existe lançamento, se existir nao pode ser alterado.
			lRet := JExitLanc()
		EndIf

	Case cCampo == "ED_DESFAT"
		lRet := M->ED_CCJURI == "5"

	Otherwise
		lRet := .F.
	EndCase
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURRAT()
Verifica se o rateio jurídico é válido

@Param  cRateio  Código do Rateio
@Param  lValBlq  .T. valida se o codigo de rateio esta inativo.

@author Abner Fogaça de Oliveira
@since 28/07/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURRAT(cRateio, lValBlq)
Local lRet      := .T.
Local aArea     := GetArea()

Default cRateio := M->ED_RATJUR
Default lValBlq := .T.

OH6->(DbsetOrder(1)) //OH6_FILIAL+OH6_CODIGO

If OH6->(Dbseek(xFilial("OH6") + cRateio))
	If OH6->OH6_ATIVO != "1" .And. lValBlq
		lRet := JurMsgErro(STR0001, , STR0002) //#Código do rateio selecionado encontra-se inativo. ##Informe um código de rateio válido.
	EndIf
Else
	lRet := JurMsgErro(STR0003, , STR0002) //#Código do rateio não encontrado. ##Informe um código de rateio válido.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JVldFin010
Função chamada no pós valid do Model da FINA010(Natureza) para validações referente a integração SIGAFIN x SIGAPFS

@author Jorge Luis Branco Martins Junior
@version 12.1.17
@since 23/08/17

@param oModel Modelo de Dados de Natureza (SED)

@return lRet
/*/
//-------------------------------------------------------------------------------------------------------------
Function JVldFin010(oModel)
Local lRet      := .T.
Local oModelSED := oModel:GetModel("SEDMASTER")

If SED->(ColumnPos("ED_CMOEJUR")) > 0 .And.; // Proteção
		SED->(ColumnPos("ED_TPCOJR")) > 0 .And.;
		SED->(ColumnPos("ED_BANCJUR")) > 0 .And.;
		SED->(ColumnPos("ED_CBANCO")) > 0 .And.;
		SED->(ColumnPos("ED_CCONTA")) > 0 .And.;
		SED->(ColumnPos("ED_CAGENC")) > 0

	If (oModel:GetOperation() == OP_INCLUIR .Or. oModel:GetOperation() == OP_ALTERAR) // Inclusão ou Alteração
		lRet := JF010PrCpo(oModelSED) // Validações de preenchimento de campos

		lRet := lRet .And. JF010VldMd(oModelSED) // Validações a moeda da Natureza x Banco

		lRet := lRet .And. JVldNatBan(oModelSED) // Validações para Natureza do tipo Banco/Caixa
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JF010PrCpo
Validações de preenchimento de campos

@param oModel Modelo de Dados

@return lRet

@author Jorge Luis Branco Martins Junior
@since 11/08/17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function JF010PrCpo(oModelSED)
Local cProblema := ""
Local cSolucao  := ""
Local cCampos   := ""
Local lRet      := .T.

	If !Empty(oModelSED:GetValue('ED_CMOEJUR')) .And. Empty(oModelSED:GetValue('ED_TPCOJR'))
		cProblema := I18N(STR0017, {AllTrim(RetTitle('ED_TPCOJR'))}) // "O campo '#1' não foi preenchido."
		cSolucao  := I18N(STR0016, {AllTrim(RetTitle('ED_CMOEJUR'))}) // "Quando o campo '#1' estiver preenchido é obrigatório preencher o campo citado acima."
		lRet      := JurMsgErro(cProblema,, cSolucao)
	EndIf

	If lRet .And. oModelSED:GetValue('ED_BANCJUR') == '1' .And. ;
		( Empty(oModelSED:GetValue('ED_CBANCO')) .Or. ;
		Empty(oModelSED:GetValue('ED_CAGENC')) .Or. ;
		Empty(oModelSED:GetValue('ED_CCONTA')) )

		cCampos   := AllTrim(RetTitle('ED_CBANCO')) + ", " + ;
					AllTrim(RetTitle('ED_CAGENC')) + ", " + ;
					AllTrim(RetTitle('ED_CCONTA'))

		cProblema := I18N(STR0006, {cCampos}) // "Ao menos um dos seguintes campos não foi preenchido: #1."
		cSolucao  := I18N(STR0007, {AllTrim(RetTitle('ED_BANCJUR'))}) //"Para o '#1' igual a 1-Sim é obrigatório preencher os campos citados acima."
		lRet      := JurMsgErro(cProblema,, cSolucao)
	EndIf

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JF010VldMd
Validações a moeda do banco quando ele for preenchido.

@param oModelSED Modelo de Dados

@return lRet

@author Bruno Ritter
@since 06/11/2017
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function JF010VldMd(oModelSED)
Local lRet       := .T.
Local nMoedaBanc := 0
Local cBanco     := ""
Local cAgencia   := ""
Local cConta     := ""

If oModelSED:GetValue('ED_BANCJUR') == '1'
	cBanco     := oModelSED:GetValue('ED_CBANCO')
	cAgencia   := oModelSED:GetValue('ED_CAGENC')
	cConta     := oModelSED:GetValue('ED_CCONTA')
	nMoedaBanc := JurGetDados("SA6", 1, xFilial("SA6") + cBanco + cAgencia + cConta, "A6_MOEDA")

	If nMoedaBanc != Val(oModelSED:GetValue('ED_CMOEJUR'))
		lRet := JurMsgErro(STR0038,, STR0039) //"A moeda da natureza está diferente da moeda banco",, "Verifique o cadastro Banco."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldNatBan(oModelSED)
Função verificar se o Banco já esta sendo usado em outra natureza.

@author Luciano Pereira dos Santos
@since 02/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVldNatBan(oModelSED)
Local lRet       := .T.
Local cNatureza  := ""
Local cNatExist  := ""
Local cQuery     := ""
Local cQueryRes  := ""
Local cBanco     := ""
Local cAgencia   := ""
Local cConta     := ""

If oModelSED:GetValue('ED_BANCJUR') == '1'

	cBanco    := oModelSED:GetValue('ED_CBANCO')
	cAgencia  := oModelSED:GetValue('ED_CAGENC')
	cConta    := oModelSED:GetValue('ED_CCONTA')
	cNatExist := oModelSED:GetValue('ED_CODIGO')
	cQueryRes := GetNextAlias()

	cQuery += " SELECT SED.ED_CODIGO "
	cQuery += " FROM " + RetSqlName("SED") + " SED "
	cQuery += " WHERE SED.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=        " AND SED.ED_BANCJUR = '1' "
	cQuery +=        " AND SED.ED_CBANCO = '" + cBanco + "' "
	cQuery +=        " AND SED.ED_CAGENC = '" + cAgencia + "' "
	cQuery +=        " AND SED.ED_CCONTA = '" + cConta + "' "
	cQuery +=        " AND SED.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

	If !(cQueryRes)->(EOF())
		cNatureza := (cQueryRes)->ED_CODIGO
	EndIf

	(cQueryRes)->(DbCloseArea())

	If !Empty(cNatureza) .And. cNatureza != cNatExist
		lRet := JurMsgErro(I18N(STR0042, {cNatureza}),, STR0043) //#"A natureza '#1' já utiliza o mesmo banco, agência e conta informado." ##"Utilize outro o banco, agência e conta para essa natureza."
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValNat
Função para validar a natureza

@param cCampo       Campo do modelo referente ao código da natureaza (ED_CODIGO).
@param cValid       Ativa a validação adicional : 1- Contas a pagar; 2- Contas a receber.
@param cValor       Valor do campo referente ao código da natureza (ED_CODIGO), usado
                    em validações onde não existe modelo (tela criada manualmente).
@param lVldCCJuri   Ativa validação de centro de custo especiais (ED_CCJURI) :
                    5- Despesa de Cliente; 6- Transitória pós-pagamento.
@param cValAddCCJ   Passar os centro de custo Jurídicos para serem validados
                    Ex: "4|3", os centro de custo 4-Rateio e 3-Profissional não poderão ser usados
@param aError       Array para passar como referência para receber o erro gerado
@param lExibeErro   Se deve executar o JurMsgErro
@param lPermBloq    Indica se permite que a natureza escolhida esteja bloqueada
@param lSintetica   Indica se a natureza escolhida deve ser sintética

@author bruno.ritter
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurValNat(cCampo, cValid, cValor, lVldCCJuri, cValAddCCJ, aError, lExibeErro, lPermBloq, lSintetica)
Local lRet          := .T.
Local cTitle        := ""
Local aRetDados     := {}
Local cNatureza     := ""
Local cBxTPosPag    := ""

Default cCampo      := ''
Default cValid      := ''
Default cValor      := ''
Default lVldCCJuri  := .F.
Default cValAddCCJ  := ''
Default aError      := {}
Default lExibeErro  := .T.
Default lPermBloq   := .F.
Default lSintetica  := .F.

If lVldCCJuri
	cValAddCCJ += "|5|6" //5-Despesa de Cliente; 6-Transitória pós-pagamento.
EndIf

If Empty(cValor) .And. !Empty(cCampo)
	cNatureza := FwFldGet(cCampo)
Else
	cNatureza := cValor
EndIf

aRetDados := JurGetDados("SED", 1, xFilial("SED") + cNatureza, {"ED_CODIGO", "ED_TIPO", "ED_CMOEJUR", "ED_MSBLQL", "ED_CPJUR", "ED_CRJUR", "ED_CCJURI"})

If Empty(aRetDados)
	aError := {I18N(STR0008, {cNatureza}), STR0009} //"A natureza '#1' não foi localizada." //"Selecione uma natureza válida."
	lRet := .F.

ElseIf Len(aRetDados) < 2 .OR. (aRetDados[2] != "2" .And. !lSintetica)
	aError := {I18N(STR0010, {cNatureza}), STR0011} //"A natureza '#1' é do tipo sintético." //"Selecione uma natureza do tipo analítico."
	lRet := .F.

ElseIf Len(aRetDados) < 2 .OR. (aRetDados[2] != "1" .And. lSintetica)
	aError := {I18N(STR0114, {cNatureza}), STR0115} //"A natureza '#1' é do tipo analitica." //"Selecione uma natureza do tipo sintética."
	lRet := .F.

ElseIf (Len(aRetDados) < 3 .OR. Empty(aRetDados[3])) .And. !lSintetica
	cTitle := AllTrim(RetTitle("ED_CMOEJUR"))
	aError := {I18N(STR0012, {cNatureza, cTitle}), I18N(STR0013,{cTitle})} //"A natureza '#1' está com o campo '#2' vazio." //"Verifique o cadastro da natureza ou selecione uma natureza com campo '#1' informado."
	lRet := .F.

ElseIf Len(aRetDados) < 4 .OR. ( aRetDados[4] == "1" .And. !lPermBloq)
	aError := {I18N(STR0014, {cNatureza}), STR0015} //"A natureza '#1' está bloqueada." // "Verifique o cadastro da natureza ou selecione uma natureza ativa."
	lRet := .F.

ElseIf cValid == '1' .And. !lSintetica
	If Len(aRetDados) < 5 .OR. aRetDados[5] != "1"
		aError := {I18N(STR0023, {cNatureza}), STR0024} //"A natureza '#1' não é uma natureza de contas a pagar." // "Verifique o cadastro da natureza ou selecione uma natureza de contas a pagar."
		lRet := .F.
	EndIf

ElseIf cValid == '2' .And. !lSintetica
	If Len(aRetDados) < 6 .OR. aRetDados[6] != "1"
		aError := {I18N(STR0025, {cNatureza}), STR0026} //"A natureza '#1' não é uma natureza de contas a receber." // "Verifique o cadastro da natureza ou selecione uma natureza de contas a receber."
		lRet := .F.
	EndIf
EndIf

If lRet .And. !Empty(cValAddCCJ) .And. !lSintetica
	If Len(aRetDados) < 7 .OR. aRetDados[7] $ cValAddCCJ
		cTitle     := AllTrim(RetTitle('ED_CCJURI'))
		cBxTPosPag := JurInfBox('ED_CCJURI', aRetDados[7], '3')
		aError := {I18n(STR0040, {cNatureza, cTitle, cBxTPosPag}), STR0041} //"Não é possível utilizar a natureza '#1' com o campo '#2' igual a '#3'." // "Verifique o cadastro da natureza."
		lRet := .F.
	EndIf
EndIf

If !lRet .And. lExibeErro
	JurMsgErro(aError[1], , aError[2])
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDocVinc
Função para chamada dos Docs Vinculados relacionados a Fatura do Título
a Receber.
Chamada pelo menu da FINA040 - Contas a Receber.

OBS: Preenchimento do E1_JURFAT, que contém o Escritório e Cód da Fatura:
cFatJur := xFilial( 'NXA' ) + '-' + NXA->NXA_CESCR + '-' + NXA->NXA_COD + '-' + cFilAnt

@author Cristina Cintra
@since 13/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDocVinc()
Local cJurFat   := StrTran(SE1->E1_JURFAT, "-", "")
Local nTamFil   := TamSX3("NXA_FILIAL")[1]
Local nTamEsc   := TamSX3("NXA_CESCR")[1]
Local nTamFat   := TamSX3("NXA_COD")[1]
Local cEscrit   := Substr(cJurFat, nTamFil + 1, nTamEsc)
Local cFatura   := Substr(cJurFat, nTamFil + nTamEsc + 1, nTamFat)
Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
Local lExistOHT := AliasInDic("OHT")

	If (!Empty(cJurFat)) .Or. (lExistOHT .And.;
		!Empty(JurGetDados("OHT", 2, xFilial("OHT") + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "OHT_CFATUR")))
		If lPDUserAc
			If lExistOHT .And. Empty(cJurFat)
				J243SE1Opt(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO, 1)
			Else
				J204PDF(.T., cEscrit, cFatura)
			EndIf
		Else
			MsgInfo(STR0136, STR0137) // "Usuário com restrição de acesso a dados pessoais/sensíveis." "Acesso restrito"
		EndIf
	Else
		MsgInfo(STR0021, STR0020) // "A demonstração de Documentos Relacionados só está disponível nos títulos a receber das faturas geradas pelo SIGAPFS." "Atenção!"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSalNat(cNatureza, cFilOrig)
Rotina para retornar o saldo da natureza.

@Param  cNatureza Código da natureza
@Param  cFilOrig  Código da filial de origem (usar para natureza modelo
					compartilhado com o Lançamento

@Return nRet Saldo no valor da moeda da natureza.

@author Luciano Pereira dos Santos
@since 01/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSalNat(cNatureza, cFilOrig)
Local nRet       := 0
Local aArea      := GetArea()
Local aSED       := {}
Local cMoeda     := ''
Local cTpCont    := ''
Local cQuery     := ''
Local cQryRes    := ''

Default cFilOrig := xFilial('SED')

aSED := JurGetDados('SED', 1, FWxFilial("SED", cFilOrig) + cNatureza, {'ED_TPCOJR', 'ED_CMOEJUR'})

If Len(aSED) == 2
	cTpCont := aSED[1]
	cMoeda  := aSED[2]

	If cTpCont $ '1|7' //"1 - Banco/Caixa" ou "7 - C. C. Profissional"
		cQuery  := " SELECT "
		cQuery +=    " SUM( "
		cQuery +=        " CASE "
		cQuery +=            " WHEN FIW.FIW_CARTEI = 'R' THEN  FIW.FIW_VALOR "
		cQuery +=            " WHEN FIW.FIW_CARTEI = 'P' THEN - FIW.FIW_VALOR "
		cQuery +=        " ELSE 0 "
		cQuery +=     " END) FIW_VALOR "
		cQuery += " FROM " + RetSqlName('FIW') + " FIW "
		cQuery += " WHERE FIW.FIW_FILIAL = '"+ FWxFilial("FIW",cFilOrig) +"'"
		cQuery +=   " AND FIW.FIW_NATUR = '"+ cNatureza+ "'"
		cQuery +=   " AND FIW.FIW_MOEDA = '"+ cMoeda+ "'"
		cQuery +=   " AND FIW.FIW_TPSALD = '3'"
		cQuery +=   " AND FIW.D_E_L_E_T_ = ' '"

		cQuery  := ChangeQuery(cQuery, .F.)
		cQryRes := GetNextAlias()

		DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cQryRes, .T., .F. )

		nRet := (cQryRes)->FIW_VALOR

		(cQryRes)->(DbCloseArea())
	EndIf

EndIf

RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIniValDes()
Rotina de inicializador padrão dos valores de saldo e total do
desdobramento no cabeçalho.
Usado nas telas de desdobramento e desdobramento pós pagto.

@param oModel    Modelo de dados de desdobramento/desd. pós pagto
@param cTab      Indica se é desdobramento ou desd. pós pagto
                 - OHF - Desdobramento (JURA246)
				 - OHG - Desdobramento pós pagto (JURA247)

@Return lRet  Indica se os campos de Valor do saldo/total do
              desdobramento foram atualizados

@author Jorge Martins
@since 05/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JIniValDes(oModel, cTab)
Local lRet       := .T.
Local oModDet    := oModel:GetModel(cTab + 'DETAIL')
Local nValTit    := oModel:GetValue('SE2MASTER', 'E2__VALOR')
Local cFilSE2    := oModel:GetValue('SE2MASTER', 'E2_FILIAL')
Local cPrefixo   := oModel:GetValue('SE2MASTER', 'E2_PREFIXO')
Local cNum       := oModel:GetValue('SE2MASTER', 'E2_NUM')
Local cParcela   := oModel:GetValue('SE2MASTER', 'E2_PARCELA')
Local cTipo      := oModel:GetValue('SE2MASTER', 'E2_TIPO')
Local cFornece   := oModel:GetValue('SE2MASTER', 'E2_FORNECE')
Local cLoja      := oModel:GetValue('SE2MASTER', 'E2_LOJA')
Local nDecimal   := TamSx3('E2_VALOR')[2]
Local nConLin    := 0
Local nTotal     := 0
Local nSaldo     := 0
Local nValDesPos := 0

//Função executada ao inicar o modulo do SIGAPFS, mas como o desdobramento não é executado pelo SIGAPFS, se faz necessário executar essa função para atribuir valor para variável static de situações de pré-fatura.
JurSitLoad()

For nConLin := 1 To oModDet:GetQtdLine()
	nTotal += oModDet:GetValue( cTab + '_VALOR', nConLin)
Next nConLin

If cTab == "OHF"
	nSaldo := Round(nValTit - nTotal, nDecimal)
ElseIf cTab == "OHG"
	nValDesPos := JValDesPos(cFilSE2, cPrefixo, cNum, cParcela, cTipo, cFornece, cLoja)
	nSaldo := Round(nValDesPos - nTotal, nDecimal)
EndIf

IIF(lRet, lRet := oModel:LoadValue('SE2MASTER', 'E2__TOTDES', Round(nTotal, nDecimal )), )
IIF(lRet, lRet := oModel:LoadValue('SE2MASTER', 'E2__SLDDES', Round(nSaldo, nDecimal )), )

If cTab == "OHF" .And. FWIsInCallStack("JURA273") // Cópia de Contas a Pagar
	J273CpDesd(oModel)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAtuValDes()
Rotina para atualizar os campos de valores de saldo e total do
desdobramento no cabeçalho durante as alterações.
Usado nas telas de desdobramento e desdobramento pós pagto.

@param cTab          Indica se é desdobramento ou desd. pós pagto
                     - OHF - Desdobramento (JURA246)
				     - OHG - Desdobramento pós pagto (JURA247)
@param oModel       Modelo que está sendo usado (OHF ou OHG)
@param nLine         Linha que está posicionado o grid
@param cAction       Ação que foi executada no modelo (DELETE, SETVALUE)

@Return lRet  Indica se os campos de Valor do saldo/total do
              desdobramento foram atualizados

@author Jorge Martins
@since 06/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAtuValDes(cTab, oModel, nLine, cAction)
Local lRet       := .T.
Local nOpc       := 0
Local oModDet    := Nil
Local nValTit    := 0
Local cFilSE2    := ""
Local cPrefixo   := ""
Local cNum       := ""
Local cParcela   := ""
Local cTipo      := ""
Local cFornece   := ""
Local cLoja      := ""
Local nDecimal   := TamSx3('E2_VALOR')[2]
Local nTotal     := 0
Local nSaldo     := 0
Local nConLin    := 0

Default oModel   := FwModelActive()
Default nLine    := 0
Default cAction  := ""

nOpc       := oModel:GetOperation()
oModDet    := oModel:GetModel(cTab + 'DETAIL')
If nLine == 0
	nLine  := oModDet:GetLine()
EndIf
nValTit    := oModel:GetValue('SE2MASTER', 'E2__VALOR')
cFilSE2    := oModel:GetValue('SE2MASTER', 'E2_FILIAL')
cPrefixo   := oModel:GetValue('SE2MASTER', 'E2_PREFIXO')
cNum       := oModel:GetValue('SE2MASTER', 'E2_NUM')
cParcela   := oModel:GetValue('SE2MASTER', 'E2_PARCELA')
cTipo      := oModel:GetValue('SE2MASTER', 'E2_TIPO')
cFornece   := oModel:GetValue('SE2MASTER', 'E2_FORNECE')
cLoja      := oModel:GetValue('SE2MASTER', 'E2_LOJA')

For nConLin := 1 To oModDet:GetQtdLine()
	If Empty(cAction) // Valid do campo de valor
		If !oModDet:IsDeleted(nConLin) .And. !Empty(oModDet:GetValue( cTab + '_CITEM',nConLin))
			nTotal += oModDet:GetValue( cTab + '_VALOR', nConLin)
		EndIf
	Else // Pré-Valid da linha do modelo
		If !Empty(oModDet:GetValue( cTab + '_CITEM',nConLin)) .And.;
		   ( (!(cAction == 'DELETE' .And. nConLin == nLine .And. !oModDet:IsDeleted(nConLin)) .And.;
		   !(nConLin != nLine .And. oModDet:IsDeleted(nConLin))) .Or. (cAction == 'SETVALUE' .And. !oModDet:IsDeleted(nConLin)) )

			nTotal += oModDet:GetValue( cTab + '_VALOR', nConLin)

		EndIf
	EndIf
Next nConLin

If nOpc == 3 .Or. nOpc == 4

	If cTab == "OHF"
		nSaldo := Round(nValTit - nTotal, nDecimal)
	ElseIf cTab == "OHG"
		nValDesPos := JValDesPos(cFilSE2, cPrefixo, cNum, cParcela, cTipo, cFornece, cLoja)
		nSaldo := Round(nValDesPos - nTotal, nDecimal)
	EndIf

	IIF(lRet, lRet := oModel:LoadValue('SE2MASTER', 'E2__TOTDES', Round(nTotal, nDecimal )), )
	IIF(lRet, lRet := oModel:LoadValue('SE2MASTER', 'E2__SLDDES', Round(nSaldo, nDecimal )), )

EndIf

oModDet:GoLine(nLine)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JValDesPos()
Rotina que indica a somatória dos valores de desdobramentos que
estão com a Natureza do tipo "Desdobramento Pós Pagamento"
Usado na tela de desdobramento pós pagto.

@param cFilSE2    Filial do título da SE2 (Contas a pagar)
@param cPrefixo   Prefixo do título
@param cNum       Número do título
@param cParcela   Parcela do título
@param cTipo      Tipo do título
@param cFornece   Fornecedor
@param cLoja      Loja do fornecedor

@Return nValor  Valor do saldo/total do desdobramento

@author Jorge Martins
@since 06/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JValDesPos(cFilSE2, cPrefixo, cNum, cParcela, cTipo, cFornece, cLoja)
Local nValor     := 0
Local cQuery     := ""
Local cChave     := cFilSE2 + "|" +  cPrefixo + "|" + cNum + "|" + cParcela + "|" + cTipo + "|" + cFornece + "|" + cLoja
Local cIdDoc     := FINGRVFK7("SE2", cChave) // IDDOC da FK7 para busca
Local cQueryRes  := GetNextAlias()

cQuery += " SELECT SUM(OHF.OHF_VALOR) VALOR "
cQuery +=   " FROM " + RetSqlName("OHF") + " OHF "
cQuery +=     " INNER JOIN " + RetSqlName("SED") + " SED "
cQuery +=        " ON ( SED.ED_FILIAL = '" + xFilial("SED") + "' "
cQuery +=        " AND  SED.ED_CODIGO = OHF_CNATUR "
cQuery +=        " AND  SED.ED_CCJURI = '6' "
cQuery +=        " AND  SED.D_E_L_E_T_ = ' ' ) "
cQuery +=   " WHERE OHF.OHF_FILIAL = '" + cFilSE2 + "' "
cQuery +=     " AND OHF_IDDOC = '" + cIdDoc + "' "
cQuery +=     " AND OHF.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery( cQuery, .F. )
DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cQueryRes, .T., .F. )

If !(cQueryRes)->(EOF())
	nValor := (cQueryRes)->VALOR
EndIf

(cQueryRes)->(DbCloseArea())

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldBxPag
Rotina para centralizar as regras de validação de titulos no
contas a pagar quando a integração esta ativa MV_JURXFIN = .T.

@param nRecno     Recno  do título da SE2 (Contas a pagar)
@param lTodos     Se .T. indica se foi precionada a opção de selecionar todos os título
@param lPrimeiro  Quando encontrar o primeiro título que não atenda a validação e
					exibir a mensagem, retorna por referencia que não serão exibidas
					novas mensagens caso ocorram inconsistencias nos próximos títulos.

@Return lRet   .T. Se o título é valido para ser manipulado.

Uso nas funções Fa080Juri (FINA080) - Validação de Integração SIGAPFS x SIGAFIN - Baixa
                Fa090Juri (FINA090) - Validação de Integração SIGAPFS x SIGAFIN - Baixa Automática
                Fa340Juri (FINA340) - Validação de Integração SIGAPFS x SIGAFIN - Compensação
                Fa390Juri (FINA390) - Validação de Integração SIGAPFS x SIGAFIN - Geração de Cheques
                Fa450Juri (FINA450) - Validação de Integração SIGAPFS x SIGAFIN - Compensação entre carteiras
                Fa565Juri (FINA565) - Validação de Integração SIGAPFS x SIGAFIN - Liquidação

@author Luciano Pereira dos Santos
@since 09/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldBxPag(nRecno, lTodos, lPrimeiro)
Local lRet        := .T.
Local aArea       := {}
Local cChave      := ''
Local cIdDoc      := ''
Local cSolucao    := ''
Local cProblema   := ''
Local lIntPFS     := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

Default lTodos    := .F.
Default lPrimeiro := .T.

If lIntPFS
	aArea := GetArea()
	
	//Garante o posicionamento no registro da SE2
	SE2->(DbGoto(nRecno))

	// Ao substituir um PR, o financeiro baixa o mesmo, mas o PR não pode incluir desdobramento 
	If SE2->E2_TIPO != MVPROVIS // PR
		cChave := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
		cIdDoc := FINGRVFK7("SE2", cChave)

		//validação quanto a baixa de titulos com desdobremento completo
		lRet := JurDesdobr(cIdDoc, JCPVlBruto(nRecno))

		If !lRet .And. lPrimeiro
			If JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_CCJURI") == "7" // Natureza transitória de pagamento
				cProblema := Iif(lTodos, STR0027, STR0029) //#"Existem título(s) com valor diferente do total desdobrado." ##"Não é possível realizar a operação em um título com valor desdobrado diferente do valor do título."
				cSolucao  := Iif(lTodos, STR0028, STR0030) //"Corrija o valor desdobrado do(s) título(s) para realizar a operação." ##"Corrija o valor desdobrado para realizar a operação."

			Else // Natureza definida
				cProblema := Iif(lTodos, STR0046, STR0048) //"Há título(s) sem as informações de centro de custo jurídico."      # "Não é possível realizar a operação em um título sem as informações de centro de custo jurídico."
				cSolucao  := Iif(lTodos, STR0047, STR0049) //"Preencha as informações no(s) título(s) para realizar a operação." # "Preencha as informações no título para realizar a operação."

			EndIf

			lPrimeiro := JurMsgErro(cProblema, 'JVldBxPag', cSolucao)
		EndIf
	EndIf

	RestArea(aArea)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDesdobr(cIdDoc, nValorTit)
Rotina pra verificar se o título foi totalmente desdobrado.

@param cIdDoc     Codigo de identificação do titulo da SE2 (Contas a pagar)
@param nValorTit  Valor do Titulo da SE2 (Contas a pagar)

@Return lRet   .T. Se o titulo foi totalmente desdobrado.

@author Luciano Pereira dos Santos
@since 06/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDesdobr(cIdDoc, nValorTit)
Local lRet       := .T.
Local aAreaOHF   := {}
Local nTotDesdob := 0
Local cFilOHF    := FWxFilial("OHF", SE2->E2_FILIAL)

If Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM <> 'FINA290 ' // Desconsidera validação para títulos aglutinados (FINA290)
	aAreaOHF   := OHF->(GetArea())

	OHF->(DbSetOrder(1)) //OHF_FILIAL + OHF_IDDOC + OHF_CITEM
	If OHF->(DbSeek(cFilOHF + cIdDoc))
		While !OHF->(EOF()) .And. OHF->OHF_FILIAL + OHF->OHF_IDDOC == cFilOHF + cIdDoc
			nTotDesdob += OHF->OHF_VALOR
	 		OHF->(DbSkip())
		EndDo
		lRet := (nTotDesdob == nValorTit)
	Else
		lRet := .F.
	EndIf
	
	RestArea(aAreaOHF)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIncMov(oModel, cNatureza, cTpNatur)
Função para incluir uma movimentação bancária.

@param cNatureza  - Codigo de Natureza
@param cTpNatur   - O=Natureza de Origem, D=Naturaza de destino
@param cCodLanc   - Código do lanaçamento que originou a movimentação bancária
@param cNatMoeda  - a moeda que será usada para gerar a movimentação
@param nValorLanc - valor da movimentação referente a moeda informada em 'cNatMoeda'
@param dDataLanc  - Data da movimentação bancária.
@param nTaxa      - Taxa da moeda
@param lShowErr   - Exibe mensagem de Erro
@param cLog       - Mensagem de Erro

@Return Nil

@author Luciano.pereira
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Function JurIncMov(cNatureza, cTpNatur, cCodLanc, cNatMoeda, nValorLanc, dDataLanc, nTaxa, lShowErr, cLog)
Local aFina100   := {}
Local nOpc       := 0
Local oTpConta   := JURTPCONTA():New()
Local cMoedaSM2  := ""
Local cRetNat    := ""
Local cNatBanco  := ""
Local cNatAgenc  := ""
Local cNatConta  := ""
Local cNatBancJr := ""
Local cTpContJr  := ""
Local cRecPag    := ""
Local lRet       := .T.

Default nTaxa       := GetCotacD(cNatMoeda, dDataLanc)
Default lShowErr    := .T.
Private lMsErroAuto := .F.

	If !lShowErr
		Private lAutoErrNoFile  := .T.
		Private lMsHelpAuto     := .T.
	EndIf

	cRetNat     := JurGetDados("SED", 1, xFilial("SED") + cNatureza, {"ED_BANCJUR", "ED_CBANCO", "ED_CAGENC", "ED_CCONTA", "ED_TPCOJR"})
	cNatBancJr  := cRetNat[1]
	cNatBanco   := cRetNat[2]
	cNatAgenc   := cRetNat[3]
	cNatConta   := cRetNat[4]
	cTpContJr   := cRetNat[5]

	If cNatBancJr == "1"
		cMoedaSM2  := "M" + Iif(cNatMoeda < "10", Right(cNatMoeda, 1), cNatMoeda) //Remove o zero a esquerda

		If oTpConta:GetRecPag(cTpContJr, cTpNatur) == 'P'
			nOpc    := 3
			cRecPag := "P"
		ElseIf oTpConta:GetRecPag(cTpContJr, cTpNatur) == 'R'
			nOpc    := 4
			cRecPag := "R"
		EndIf

		aFina100 := { {"E5_DATA"   , dDataLanc                 , Nil},;
		              {"E5_VENCTO" , dDataLanc                 , Nil},;
		              {"E5_MOEDA"  , cMoedaSM2                 , Nil},;
		              {"E5_VALOR"  , nValorLanc                , Nil},;
		              {"E5_NATUREZ", cNatureza                 , Nil},;
		              {"E5_BANCO"  , cNatBanco                 , Nil},;
		              {"E5_AGENCIA", cNatAgenc                 , Nil},;
		              {"E5_CONTA"  , cNatConta                 , Nil},;
		              {"E5_DOCUMEN", cCodLanc                  , Nil},;
		              {"E5_TXMOEDA", nTaxa                     , Nil},;
		              {"E5_RECPAG" , cRecPag                   , Nil},;
		              {"E5_HISTOR" , STR0037 + " - " + cCodLanc, Nil}} //"Lanc entre naturezas"

		aFina100 := FWVetByDic(aFina100,"SE5",.F.,1)
		MsExecAuto({|x,y,z| FINA100(x,y,z)},0,aFina100, nOpc)
		If lMsErroAuto
			If lShowErr
				MostraErro()
			Else
				aEval(GetAutoGRLog(), {|l| cLog += l + CRLF})
			EndIf
			lRet := .F.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurExcMov(cCodLanc)
Rotina de exclusão na alteração

@param cCodLanc   - Codigo do lançamento
@param cOrigem    - Fonte de Origem (ex: JURA241)
@param cExcNatExp - Código da natureza para ser excluída (Se Vazio, exclui todas o código e fonte do lançamento)
@param lShowErr   - Exibe mensagem de Erro
@param cLog       - Mensagem de Erro

@Return Nil

@author Luciano.pereira
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Function JurExcMov(cCodLanc, cOrigem, cExcNatExp, lShowErr, cLog)
Local aAreaSE5  := SE5->(GetArea())
Local cTmpSE5   := GetNextAlias()
Local cQrySE5   := ""
Local aFina100  := {}
Local lRet		:= .T.
Local dDataOrig := dDataBase

Default cExcNatExp  := ""
Default lShowErr    := .T.
Private lMsErroAuto := .F.

	If !lShowErr
		Private lAutoErrNoFile  := .T.
		Private lMsHelpAuto     := .T.
	EndIf

	cQrySE5 := " SELECT R_E_C_N_O_ FROM " + RetSqlName("SE5")
	cQrySE5 += " WHERE D_E_L_E_T_ = ' ' "
	cQrySE5 +=   " AND E5_FILIAL  = '" + xFilial("SE5") + "' "
	cQrySE5 +=   " AND E5_DOCUMEN = '" + cCodLanc + "' "
	cQrySE5 +=   " AND E5_ORIGEM  = '" + cOrigem + "' "
	cQrySE5 +=   " AND E5_SITUACA NOT IN ('C','X','E') "
	If !Empty(cExcNatExp)
		cQrySE5 += " AND E5_NATUREZ  = '" + cExcNatExp + "' "
	EndIf
	cQrySE5 := ChangeQuery(cQrySE5)

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQrySE5), cTmpSE5, .T., .T.)
	SE5->(DbSetOrder(21)) // E5_FILIAL+E5_IDORIG+E5_TIPODOC

	While  (cTmpSE5)->( ! Eof() )
		SE5->(DbGoTo( (cTmpSE5)->R_E_C_N_O_ ))

		dDataBase := SE5->E5_DATA // Alterar o dDataBase para atualizar o saldo bancário na data do lançamento

		aFina100 := { {"E5_FILIAL"	,SE5->E5_FILIAL	,Nil},;
					{"E5_IDORIG"	,SE5->E5_IDORIG	,Nil},;
					{"E5_TIPODOC"	,SE5->E5_TIPODOC,Nil},;
					{"INDEX"		,21				,Nil} }
		MsExecAuto({|x,y,z| FINA100(x,y,z)},0,aFina100,5)

		dDataBase := dDataOrig // Restaura a dDataBase original

		If lMsErroAuto
			If lShowErr
				MostraErro()
			Else
				aEval(GetAutoGRLog(), {|l| cLog += l + CRLF })
			EndIf
			lRet := .F.
			Exit
		EndIf
		(cTmpSE5)->(DbSkip())
	End

	(cTmpSE5)->(DbCloseArea())
	RestArea(aAreaSE5)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBusNat
Função para buscar natureza financeira conforme o centro de custo informado.

@Param cTipoNat   Centro de Custo Jurídico para busca da natureza relacionada a ele.
@Param cBanco     Banco para busca da natureza relacionada a ele.
@Param cAgenc     Agência para busca da natureza relacionada a ele.
@Param cConta     Conta para busca da natureza relacionada a ele.
@Param lValid     Se vai exibir uma mensagem de erro quando não achar a natureza.

@Return cNatureza Natureza relacionada ao Centro de Custo ou ao Banco informados.

@author bruno.ritter
@since  19/10/2017
/*/
//-------------------------------------------------------------------
Function JurBusNat(cTipoNat, cBanco, cAgenc, cConta, lValid)
Local aArea      := GetArea()
Local cNatureza  := ""
Local cQuery     := ""
Local cQueryRes  := GetNextAlias()
Local cX3Box     := ""
Local cTitCpo    := ""

Default cTipoNat := ""
Default cBanco   := ""
Default cAgenc   := ""
Default cConta   := ""
Default lValid   := .F.

	cQuery += " SELECT SED.ED_CODIGO "
	cQuery += " FROM " + RetSqlName("SED") + " SED "
	cQuery += " WHERE SED.ED_FILIAL = '" + xFilial("SED") + "' "
	If !Empty(cTipoNat)
		cQuery +=    " AND SED.ED_CCJURI = '" + cTipoNat + "' "
	Else
		cQuery +=    " AND SED.ED_CBANCO = '" + cBanco + "' "
		cQuery +=    " AND SED.ED_CAGENC = '" + cAgenc + "' "
		cQuery +=    " AND SED.ED_CCONTA = '" + cConta + "' "
	EndIf
	cQuery +=        " AND SED.ED_MSBLQL <> '1' "
	cQuery +=        " AND SED.D_E_L_E_T_ = ' ' "

	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

	If !(cQueryRes)->(EOF())
		cNatureza := (cQueryRes)->ED_CODIGO
	EndIf

	(cQueryRes)->(DbCloseArea())

	If lValid .And. Empty(cNatureza)
		If !Empty(cTipoNat)
			cX3Box  := JurInfBox("ED_CCJURI", cTipoNat, "1")
			cTitCpo := AllTrim(RetTitle('ED_CCJURI'))
			JurMsgErro(i18n(STR0123, {cTitCpo, cX3Box}),, STR0124) // "Não foi encontrado uma natureza do tipo '#1' = '#2'." "Favor verifique o cadastro de natureza."

		ElseIf !Empty(cBanco) .And. !Empty(cAgenc) .And. !Empty(cConta)
			JurMsgErro(i18n(STR0125, {cBanco, cAgenc, cConta}),, STR0124) //"Não foi encontrado uma natureza para o Banco: '#1', Agência: '#2' e Conta: '#3'." "Favor verifique o cadastro de natureza."
		EndIf
	EndIf

	RestArea(aArea)

Return cNatureza

//-------------------------------------------------------------------
/*/{Protheus.doc} JURSLDOHB
Função executar a função AtuSldNat() conforme os parâmetros gerados pelo método BeforeTTS da classe JA241CM

@param oSelf    => Objeto de controle do processo
@param nInc     => Incremento do processamento
@param aFiltros => Arrays com filtros para não utilizar o pergunte

@author Abner Fogaça de Oliveira
@since 08/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURSLDOHB(oSelf, nInc, aFiltros)
Local aArea      := GetArea()
Local aRet       := {}
Local cQuery     := ''
Local cQryRes    := ''
Local nOper      := 3
Local lEstorno   := .F.
Local lAtuO      := .F.
Local lAtuD      := .F.
Local cTpContO   := ''
Local cTpContD   := ''
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
Local cNatO      := ''
Local cNatD      := ''
Local aPNatO     := {}
Local aPNatD     := {}

Default oSelf    := Nil
Default aFiltros := Nil

If oSelf <> Nil
	oSelf:SetRegua2(0)
EndIf

cQuery := " SELECT 'O' TIPO, SED.ED_TPCOJR, SED.ED_CMOEJUR, OHB.OHB_NATORI NATUREZA, OHB.OHB_CMOELC,"
cQuery +=        " OHB.OHB_VALOR, OHB.OHB_DTLANC, OHB.OHB_VALORC, OHB.R_E_C_N_O_ RECNO"
cQuery +=   " FROM " + RetSqlName("OHB") + " OHB"
cQuery +=  " INNER JOIN " + RetSqlName("SED") + " SED"
cQuery +=     " ON SED.ED_FILIAL  = '" + xFilial("SED") + "'"
cQuery +=    " AND OHB.OHB_NATORI = SED.ED_CODIGO"
cQuery +=  " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "'"
cQuery +=    " AND OHB.OHB_DTLANC >= '" + Iif(!Empty(aFiltros),DTOS(aFiltros[1]), DTOS(mv_par04)) +"'"
cQuery +=    " AND OHB.OHB_DTLANC <= '" + Iif(!Empty(aFiltros),DTOS(aFiltros[2]), DTOS(mv_par05)) +"'"
cQuery +=    " AND OHB.OHB_NATORI >= '" + Iif(!Empty(aFiltros),aFiltros[3], mv_par06) +"'"
cQuery +=    " AND OHB.OHB_NATORI <= '" + Iif(!Empty(aFiltros),aFiltros[4], mv_par07) +"'"
cQuery +=    " AND OHB.D_E_L_E_T_ = ' '"
cQuery +=    " AND SED.D_E_L_E_T_ = ' '"

cQuery +=  " UNION ALL"

cQuery += " SELECT 'D' TIPO, SED.ED_TPCOJR, SED.ED_CMOEJUR, OHB.OHB_NATDES NATUREZA, OHB.OHB_CMOELC,"
cQuery +=        " OHB.OHB_VALOR, OHB.OHB_DTLANC, OHB.OHB_VALORC, OHB.R_E_C_N_O_ RECNO"
cQuery +=   " FROM " + RetSqlName("OHB") + " OHB"
cQuery +=  " INNER JOIN " + RetSqlName("SED") + " SED"
cQuery +=     " ON SED.ED_FILIAL  = '" + xFilial("SED") + "'"
cQuery +=    " AND OHB.OHB_NATDES = SED.ED_CODIGO"
cQuery +=  " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "'"
cQuery +=    " AND OHB.OHB_DTLANC >= '" + Iif(!Empty(aFiltros),DTOS(aFiltros[1]), DTOS(mv_par04)) +"'"
cQuery +=    " AND OHB.OHB_DTLANC <= '" + Iif(!Empty(aFiltros),DTOS(aFiltros[1]), DTOS(mv_par05)) +"'"
cQuery +=    " AND OHB.OHB_NATDES >= '" + Iif(!Empty(aFiltros),aFiltros[3], mv_par06) +"'"
cQuery +=    " AND OHB.OHB_NATDES <= '" + Iif(!Empty(aFiltros),aFiltros[4], mv_par07) +"'"
cQuery +=    " AND OHB.D_E_L_E_T_ = ' '"
cQuery +=    " AND SED.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
cQryRes := GetNextAlias()
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	If oSelf <> Nil
		oSelf:IncRegua2(STR0033) //"Atualizando saldos dos lançamentos das naturezas jurídicas..."
	EndIf

	lAtuO    := Iif((cQryRes)->TIPO=='O', .T., .F.)
	lAtuD    := Iif((cQryRes)->TIPO=='D', .T., .F.)

	If lAtuO
		cTpContO   := (cQryRes)->ED_TPCOJR
		cMoedaO    := (cQryRes)->ED_CMOEJUR
		cNatO      := (cQryRes)->NATUREZA
		cTpContD   := ''
		cMoedaD    := ''
	Elseif lAtuD
		cTpContD   := (cQryRes)->ED_TPCOJR
		cMoedaD    := (cQryRes)->ED_CMOEJUR
		cNatD      := (cQryRes)->NATUREZA
		cTpContO   := ''
		cMoedaO    := ''
	EndIf

	cMoedaLanc     := (cQryRes)->OHB_CMOELC
	nValorLanc     := (cQryRes)->OHB_VALOR
	dDataLan       := SToD((cQryRes)->OHB_DTLANC)
	nValorCot      := (cQryRes)->OHB_VALORC
	nRecno         := (cQryRes)->RECNO

	aRet := J241Params(nOper, lEstorno, lAtuO, cTpContO, cMoedaO, cNatO, lAtuD, cTpContD, cMoedaD, cNatD,;
	                   cMoedaLanc, cMoedaNac, nValorLanc, dDataLan, nValorCot, nRecno)

	If !Empty(aRet) .And. Len(aRet) == 2
		aPNatO := aRet[1]
		aPNatD := aRet[2]

		If Len(aPNatO) == 15
			AtuSldNat( aPNatO[1] ,aPNatO[2] ,aPNatO[3] ,aPNatO[4] ,aPNatO[5] ,;
				aPNatO[6] ,aPNatO[7] ,aPNatO[8] ,aPNatO[9] ,aPNatO[10],;
				aPNatO[11],aPNatO[12],aPNatO[13],aPNatO[14],aPNatO[15])
		EndIf

		If Len(aPNatD) == 15
			AtuSldNat( aPNatD[1] ,aPNatD[2] ,aPNatD[3] ,aPNatD[4] ,aPNatD[5] ,;
				aPNatD[6] ,aPNatD[7] ,aPNatD[8] ,aPNatD[9] ,aPNatD[10],;
				aPNatD[11],aPNatD[12],aPNatD[13],aPNatD[14],aPNatD[15])
		EndIf

	EndIf
	(cQryRes)->(DbSkip())
EndDo

(cQryRes)->(DbCloseArea())

RestArea(aArea)

Return aRet

//----------------------------------------------------------------------
/*/ { Protheus.doc } JurF3NXA1
Função para filtrar faturas do escritório digitado, caso estiver em 
branco retornará todas as faturas.

@author Jonatas Martins
@since  26/10/2017
@obs    Variável "cEscrit" é uma PRIVATE criada no fonte FINA460.prw.
        Função utilizada na consulta padrão NXA1.
/*/
//----------------------------------------------------------------------
Function JurF3NXA1()
Local cRet := "@# "

If Type('cEscrit') == 'C' .And. !Empty(cEscrit)
	cRet += "NXA->NXA_TIPO == 'FT' .AND. NXA->NXA_CESCR == '" + cEscrit + "'"
EndIf

cRet += "@#"

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JFltF3SED
Filtro da consulta padrão "SED".
Utilizado para localização "BRA".

@param lFiltroSQL, .T. Indica que o filtro é no formato SQL
                   .F. Indica que o filtro é no formato ADVPL

@return cRet   Filtro usado na consulta

@author Jorge Martins
@since  26/01/2018
/*/
//-------------------------------------------------------------------
Function JFltF3SED(lFiltroSQL)
Local cRet     := ""
Local lIntPFS  := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cCampo   := Alltrim(StrTran(ReadVar(), 'M->', ''))

Default lFiltroSQL := .F.

	// Filtro padrão da consulta
	cRet := IIf(lFiltroSQL, "@ED_TIPO IN (' ', '2')", ;
	                        "@#SED->ED_TIPO $ ' /2'@#")

	// A consulta terá seu filtro alterado somente para campos indicados abaixo.
	// Pois existem vários campos que utilizam a consulta, porém não necessitam de alteração.
	If lIntPFS
		If cCampo == "E7_NATUREZ"
			cRet := IIf(lFiltroSQL, "@ED_TIPO = '2' AND ED_CMOEJUR <> ' ' AND ED_MSBLQL <> '1' AND ED_CCJURI NOT IN ('5','6')", ;
			                        "@#SED->ED_TIPO == '2' .And. !Empty(SED->ED_CMOEJUR) .And. SED->ED_MSBLQL != '1' .And. !(SED->ED_CCJURI $ '5|6')@#")
		ElseIf (FwIsInCallStack("fA290Aut") .And. cCampo == "CNAT") .Or. ; // F3 do campo da tela de filtro na rotina de Faturas a Pagar/Aglutinação FINA290
		       (cCampo $ "E2_NATUREZ" .And. Type("ALTERA") == "L" .And. ALTERA .And. !Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM $ "FINA290 |FINA290M") // F3 do campo E2_NATUREZ do Contas a Pagar, filtra natureza transitória na alteração de títulos a pagar aglutinados
			cRet := IIf(lFiltroSQL, "@ED_CCJURI = '7'", ;
			                        "@#SED->ED_CCJURI == '7'@#")
		EndIf
	EndIf

	If cCampo == "NRN_NATSLD"
		cRet := IIf(lFiltroSQL, "@ED_MSBLQL <> '1'", ;
		                        "@#SED->ED_MSBLQL != '1'@#")
	EndIf

	If cCampo == "NXG_CNATPG" .Or. cCampo == "NXP_CNATPG"
		cRet := IIf(lFiltroSQL, "@ED_TIPO = '2' AND ED_MSBLQL <> '1' AND ED_CRJUR = '1'", ;
		                        "@#SED->ED_TIPO == '2' .And. SED->ED_MSBLQL != '1' .And. SED->ED_CRJUR == '1' @#")
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurListCc()
Carregar a lista do combo box do centro de custo da natureza

@return cRet - String as opções de centro de custo da natureza.

@author nivia.ferreira
@since 02/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurListCc()

Local cRet := Alltrim(STR0044) // "1=Escritório; 2=Escritório e C.C. Jurídico; 3=Profissional; 4=Tabela de Rateio; 5=Desp de Cliente; 6=Transitória Pós Pagamento; 7=Transitória de Pagamento; 8=Transitória de Recebimento"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUpdHistCR
Atualiza a posição do contas a receber referente ao ano-mês atual.

@author Bruno Ritter
@since 06/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUpdHistCR()
Local cQuery     := ""
Local cQueryRes  := GetNextAlias()
Local cSpcDtCanc := Space(TamSx3('NXA_DTCANC')[1])
Local cData      := DtoS(Date())
Local cAnoMes    := AnoMes(Date())

dbSelectArea( 'OHH' ) // Cria a tabela caso ela não exista ainda no banco.

cQuery += " SELECT SE1.E1_FILIAL OHH_FILIAL, " + CRLF
cQuery +=        " SE1.E1_PREFIXO OHH_PREFIX, " + CRLF
cQuery +=        " SE1.E1_NUM OHH_NUM, " + CRLF
cQuery +=        " SE1.E1_PARCELA OHH_PARCEL, " + CRLF
cQuery +=        " SE1.E1_TIPO OHH_TIPO, " + CRLF
cQuery +=        " '"+cData+"' OHH_DTHIST, "+CRLF
cQuery +=        " SE1.E1_JURFAT OHH_JURFAT, "+CRLF
cQuery +=        " '"+cAnoMes+"' OHH_ANOMES, "+CRLF
cQuery +=        " SE1.E1_HIST OHH_HIST, "+CRLF
cQuery +=        " SE1.E1_MOEDA OHH_CMOEDA, " + CRLF
cQuery +=        " SE1.E1_CLIENTE OHH_CCLIEN, " + CRLF
cQuery +=        " SE1.E1_LOJA OHH_CLOJA, " + CRLF
cQuery +=        " SE1.E1_NATUREZ OHH_CNATUR, " + CRLF
cQuery +=        " SE1.E1_VALOR OHH_VALOR, " + CRLF
cQuery +=        " SE1.E1_SALDO OHH_SALDO, " + CRLF
cQuery +=        " CASE " + CRLF
cQuery +=            " WHEN SE1.E1_JURFAT IS NULL OR SE1.E1_ORIGEM = 'FINA040' THEN 0 " + CRLF // Digitado
cQuery +=            " ELSE SE1.E1_BASEIRF " + CRLF // Gerado
cQuery +=        " END OHH_VLFATH, " + CRLF
cQuery +=        " CASE " + CRLF
cQuery +=            " WHEN SE1.E1_JURFAT IS NULL OR SE1.E1_ORIGEM = 'FINA040' THEN 0 " + CRLF // Digitado
cQuery +=            " ELSE SE1.E1_VALOR - SE1.E1_BASEIRF " + CRLF // Gerado
cQuery +=        " END OHH_VLFATD, " + CRLF
cQuery +=        " SE1.E1_IRRF OHH_VLIRRF, " + CRLF
cQuery +=        " SE1.E1_VENCREA OHH_VENCRE, " + CRLF
cQuery +=        " CASE " + CRLF
cQuery +=            " WHEN SE1.E1_JURFAT IS NULL OR SE1.E1_ORIGEM = 'FINA040' THEN '1' " + CRLF // Digitado
cQuery +=            " ELSE '2' " + CRLF // Gerado
cQuery +=        " END OHH_TPENTR, " + CRLF
cQuery +=        " SE1.E1_PIS OHH_VLPIS, " + CRLF
cQuery +=        " SE1.E1_COFINS OHH_VLCOFI, " + CRLF
cQuery +=        " SE1.E1_CSLL OHH_VLCSLL, " + CRLF
cQuery +=        " SE1.E1_ISS OHH_VLISS, " + CRLF
cQuery +=        " SE1.E1_INSS OHH_VLINSS " + CRLF
cQuery += " FROM " + RetSqlName( "SE1" ) + " SE1 " + CRLF
cQuery += " FROM " + RetSqlName( "SE1" ) + " SE1 " + CRLF
cQuery += " WHERE SE1.E1_ORIGEM IN ('JURA203','FINA040') " + CRLF
cQuery +=       " AND SE1.E1_TITPAI = '" + Space(TamSx3('E1_TITPAI')[1]) + "' " + CRLF
cQuery +=       " AND SE1.E1_SALDO = '" + cSpcDtCanc + "' " + CRLF
cQuery +=       " AND SE1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)

dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

nRet := (cQueryRes)->TOTAL

(cQueryRes)->(DbCloseArea())

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JGrvBaixa
Realiza as operações referente ao módulo SIGAPFS logo após a baixa
dos títulos do contas a receber no financeiro.

@param  nSE1Recno, numerico, Recno do registro SE1
@param  nSE5Recno, numerico, Recno do registro SE5
@param  nRegCmp  , numerico, Recno do Título que está sendo usado para compensar

@author Bruno Ritter | Jorge Martins
@since 08/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGrvBaixa(nSE1Recno, nSE5Recno, nRegCmp)
Local lIntPFS     := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lRet        := .T.
Local lGeraLanc   := .T.

Default nSE1Recno := 0
Default nSE5Recno := 0
Default nRegCmp   := 0

If lIntPFS
	If FwIsInCallStack("FINA330") // Compensação entre títulos e adiantamentos
		lGeraLanc := JTrataComp(@nSE1Recno, nSE5Recno, @nRegCmp)
	EndIf
	
	If lGeraLanc
		If FindFunction("J256GrvRas")
			lRet := J256GrvRas(nSE1Recno, nSE5Recno, nRegCmp) // Rastreamento de recebimento por casos da fatura
		EndIf
		If lRet .And. FindFunction("J255APosHis")
			J255APosHis(nSE1Recno,,,, .T.) // Atualiza a posição histórica do contas a receber
		EndIf
		If lRet .And. FindFunction("J241LancCR")
			lRet := J241LancCR(nSE1Recno, nSE5Recno, nRegCmp) // Gera o Lançamento com os dados da baixa.
		EndIf
	EndIf

	// Cria período no Calendário Contábil quando não existir
	If FindFunction("JCriaCalend")
		SE5->(DbGoto(nSE5Recno))
		JCriaCalend(SE5->E5_DATA)
	EndIf
EndIf

If lRet .And. FindFunction("J069ValAdi")
	J069ValAdi(nSE1Recno, nSE5Recno, nRegCmp) // Atualiza valores do adiantamento (Saldo, Valor Utilizado e Valor Estornado)
EndIf

// Utilização de RA sem NWF via SIGAFIN na compensação de títulos
// Não executar esse trecho quando tiver passado na função "JGrvBxRA" (nRegCmp > 0)
If  FwIsInCallStack("FINA330") .And. SE1->E1_ORIGEM <> "JURA069 " .And. FindFunction("J311Insert") .And. FWAliasInDic("OI8"); // @12.1.2310
	.And. SE1->E1_TIPO == PadR(SuperGetMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1]) .And. (SuperGetMV("MV_JESCJUR",, ".F.") .Or. SuperGetMV("MV_JURXFIN",, .F.))
	J311Insert("D", 0, nSE5Recno) // 2 - Utilizado
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCancBaixa
Realiza as operações referente ao módulo SIGAPFS logo após o
cancelamento da baixa dos títulos do contas a receber no financeiro.

@param  nSE1Recno, Recno do registro SE1
@param  nSE5Recno, Recno do registro SE5
@param  nRegRA   , Recno do título RA da compensação
@param  dBaixaCan, data da baixa a receber que foi cancelada

@param  lEstComp , logico  , Se verdadeiro indica que é um estorno de compensação

@author Bruno Ritter | Jorge Martins
@since 08/02/2018
/*/
//-------------------------------------------------------------------
Function JCancBaixa(nSE1Recno, nSE5Recno, dBaixaCan, nRegRA, lEstComp)
Local lIntPFS     := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lRet        := .T.
Local lDelLanc    := .F.
Local aOHIBxAnt   := {{"", "", 0, 0, 0, 0, 0, 0}}

Default nSE1Recno := 0
Default nSE5Recno := 0
Default dBaixaCan := Date()
Default nRegRA    := 0
Default lEstComp  := .F.

If lIntPFS
	If FindFunction("J241DelLan") .And. FindFunction("J241LancCR")
		// A função J241LancCR (chamada nos estornos) deve ser executada antes da chamada da J256DelRas
		If SE5->E5_TIPODOC == "ES" // Estorno de baixa
			lRet := J241LancCR(nSE1Recno, nSE5Recno,, .T.)
		ElseIf lEstComp // Estorno de Compensação
			If nRegRA > 0
				lRet := J241LancCR(nSE1Recno, nSE5Recno, nRegRA, .T.)
			EndIf
		Else
			lDelLanc := .T.
		EndIf
	EndIf

	If FindFunction("J256DelRas")
		J256DelRas(nSE1Recno, nSE5Recno, @aOHIBxAnt)   // Deleta rastramento das baixas dos casos da fatura.
	EndIf
	If FindFunction("J255APosHis")
		J255APosHis(nSE1Recno, dBaixaCan, , aOHIBxAnt) // Cancela a posição histórica do contas a receber
	EndIf

	If lDelLanc
		lRet := J241DelLan(nSE1Recno, nSE5Recno) // Deleta os Lançamento gerados pelo Contas a Receber.
	EndIf
EndIf

If lRet .And. FindFunction("J069ValAdi")
	J069ValAdi(nSE1Recno, nSE5Recno, nRegRA) // Atualiza valores do adiantamento (Saldo, Valor Utilizado e Valor Estornado)
EndIf

// Cancelamento/Exclusão da baixa do RA sem NWF ou estorno/exclusão de compensação via SIGAFIN
// Passa duas vezes na exclusão/estorno da compensação, uma do RA e outra para o título compesado
If AllTrim(SE1->E1_ORIGEM) <> "JURA069" .And. FindFunction("J311Insert") .And. FWAliasInDic("OI8"); // @12.1.2310
	.And. SE1->E1_TIPO == PadR(GETMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1]) .And. (SuperGetMV("MV_JESCJUR",, ".F.") .Or. SuperGetMV("MV_JURXFIN",, .F.))
	
	If FWIsInCallStack("FA070CAN") .And. SE1->E1_TIPO == PadR(GETMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1]) // Estorno/exclusão da baixa do RA via SIGAFIN
		J311Insert("F") // 4-Estorno (Valor Negativo) - Cancelamento/exclusão do Estorno via SIGAFIN
	ElseIf FWIsInCallStack("FA330DESC") // estorno/exclusão de compensação via SIGAFIN
		J311Insert("E", 0, nSE5Recno) // 3 - Cancelado
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIncTitCR
Realiza as operações referente ao módulo SIGAPFS logo após a inclusão
dos títulos do contas a receber no financeiro.

@param  nSE1Recno, numerico, Recno do registro SE1
@param  dEmissao , data    , Data da emissão do título

@author Bruno Ritter | Jorge Martins
@since 09/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JIncTitCR( nSE1Recno, dEmissao )
Local aArea       := GetArea()
Local lRet        := .T.
Local lExistOHT   := AliasInDic("OHT")
Local lIncTitLiq  := .F.

Default nSE1Recno := 0
Default dEmissao  := Date()

If FwInTTSBreak() // Indica se na transação atual foi efetuado DisarmTransaction
	lRet := .F.
Else

	// Indica que está realizando a inclusão de títulos no momento da liquidação
	lIncTitLiq := FwIsincallstack("FINA040") .And. FwIsincallstack("FINA460")

	// Não executa durante a inclusão dos títulos no momento da liquidação.
	// Somente depois de criar a OHT dos novos títulos, o sistema executará a função JIncTitCR via JurGrvOHT.
	// Essa trava só será feita caso exista OHT, pois a chamada da função JurGrvOHT está condicionada a existência da tabela.
	If !lExistOHT .Or. !lIncTitLiq
		If FindFunction("J255APosHis")
			J255APosHis( nSE1Recno, dEmissao ) // Inclui posição histórica do contas a receber.
		EndIf
		If FindFunction("J241InsAD")
			lRet := lRet .And. J241InsAD(nSE1Recno) // Gerar lançamento quando o título for RA
		EndIf

		If FindFunction("JCriaCalend")
			SE1->(DbGoto(nSE1Recno))
			JCriaCalend(SE1->E1_VENCTO) // Cria período no Calendário Contábil quando não existir
		EndIf
	EndIf

	// Inclusão de RA sem NWF direto do SIGAFIN grava OI8
	If SE1->E1_ORIGEM <> "JURA069 " .And. FindFunction("J311Insert") .And. FWAliasInDic("OI8"); // @12.1.2310
	   .And. SE1->E1_TIPO == PadR(SuperGetMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1]) .And. (SuperGetMV("MV_JESCJUR",, ".F.") .Or. SuperGetMV("MV_JURXFIN",, .F.))
		J311Insert("A", 0, SE5->(Recno())) // 1 - Recebido
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JAltTitCR
Realiza as operações referente ao módulo SIGAPFS logo após a alteração
dos títulos do contas a receber no financeiro.

@param  nSE1Recno, numerico, Recno do registro SE1
@param  dEmissao , data    , Data da emissão do título
@param  aAtuPFS  , array   , retorna ALGUNS campos quer foram alterados.

@author Bruno Ritter | Jorge Martins
@since 09/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAltTitCR( nSE1Recno, dEmissao, aAtuPFS )
Local aArea       := GetArea()
Local cCamposAtu  := ""

Default nSE1Recno := 0
Default dEmissao  := Date()
Default aAtuPFS   := {}

If !FwInTTSBreak() // Indica se na transação atual foi efetuado DisarmTransaction

	Aeval( aAtuPFS, { |cCampo| cCamposAtu += cCampo + "|" } )

	BEGIN TRANSACTION

		If FindFunction("J255APosHis") .And. ("E1_VALOR" $ cCamposAtu .Or. "E1_HIST" $ cCamposAtu .Or. "E1_VENCREA" $ cCamposAtu .Or. "E1_NATUREZ" $ cCamposAtu)
			J255APosHis(nSE1Recno, dEmissao) // Altera a posição histórica do contas a receber.
		EndIf

		If FindFunction("J241UpdRA") .And. "E1_HIST" $ cCamposAtu // Só é possível alterar o histórico no RA
			J241UpdRA(nSE1Recno, cCamposAtu) // Altera o lançamento gerado na inclusão do RA
		EndIf

		If FindFunction("JCriaCalend")
			SE1->(DbGoto(nSE1Recno))
			JCriaCalend(SE1->E1_VENCTO) // Cria período no Calendário Contábil quando não existir
		EndIf

	END TRANSACTION

EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDelTitCR
Realiza as operações referente ao módulo SIGAPFS logo após a exclusão
dos títulos do contas a receber no financeiro.

@param  cChaveSE1, caractere, Chave do registro SE1

@author Bruno Ritter | Jorge Martins
@since 09/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDelTitCR(cChaveSE1)
Local lRet := .T.

If FwInTTSBreak() // Indica se na transação atual foi efetuado DisarmTransaction
	lRet := .F.
Else
	BEGIN TRANSACTION
		If FindFunction("J255DelHist")
			J255DelHist(cChaveSE1) // Deleta a posição histórica do contas a receber referente ao cChaveSE1.
		EndIf

		If FindFunction("J241DelLan")
			lRet := lRet .And. J241DelLan(,, cChaveSE1)
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf

		// Limpa moviventações em adiantamentos sem NWF (OI8) na exclusão do RA
		If SE1->E1_ORIGEM <> "JURA069 " .And. FindFunction("J311Insert") .And. FWAliasInDic("OI8");
		  .And. SE1->E1_TIPO == PadR(SuperGetMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1]) .And. (SuperGetMV("MV_JESCJUR",, ".F.") .Or. SuperGetMV("MV_JURXFIN",, .F.)) // @12.1.2310
			J311Insert("B") // 4 - Devolvido
		EndIf
	END TRANSACTION
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGrvBxRA
Realiza as operações referente ao módulo SIGAPFS logo após a baixa
dos títulos de adiantamento "RA" do contas a receber no financeiro.

@param  nSE1Recno, numerico, Recno do registro SE1

@author Jorge Martins
@since 16/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGrvBxRA(nSE1Recno)
Default nSE1Recno := 0

If FindFunction("J069ValAdi")
	J069ValAdi(nSE1Recno) // Atualiza valores do adiantamento (Saldo, Valor Utilizado e Valor Estornado)
EndIf

// Grava estorno ao baixar RA sem NWF
If SE1->E1_ORIGEM <> "JURA069 " .And. FindFunction("J311Insert") .And. FWAliasInDic("OI8");
  .And. SE1->E1_TIPO == PadR(SuperGetMV("MV_JADTTP",, "RA"), TamSX3("E1_TIPO")[1]) .And. (SuperGetMV("MV_JESCJUR",, ".F.") .Or. SuperGetMV("MV_JURXFIN",, .F.)) // @12.1.2310
	J311Insert("C", 0, SE5->(Recno())) // 4 - Devolvido
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDtBxCR(nRecnoSE5)
Retorna data da baixa para estorno de compensação

@param  nRecnoSE5,  Recno do título (SE5).
@return dDtBaixa ,  Data da baixa.

@author Bruno Ritter | Jorge Martins
@since 13/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDtBxCR(nRecnoSE5)
Local dDtBaixa   := Date()
Local nRecSE5old := SE5->(Recno())
Local cQuery     := ""
Local cQryRes    := ""

SE5->(DbGoto(nRecnoSE5))

If SE5->E5_RECPAG  == 'R'
	dDtBaixa := SE5->E5_DTDISPO

Else
	cQuery := " SELECT SE5.E5_DTDISPO "
	cQuery += " FROM " + RetSqlName( "SE5" ) + " SE5 "
	cQuery += " WHERE SE5.E5_FILIAL  = '" + SE5->E5_FILIAL  + "' "
	cQuery +=   " AND SE5.E5_PREFIXO = '" + SE5->E5_PREFIXO + "' "
	cQuery +=   " AND SE5.E5_NUMERO  = '" + SE5->E5_NUMERO  + "' "
	cQuery +=   " AND SE5.E5_PARCELA = '" + SE5->E5_PARCELA + "' "
	cQuery +=   " AND SE5.E5_TIPO    = '" + SE5->E5_TIPO    + "' "
	cQuery +=   " AND SE5.E5_CLIFOR  = '" + SE5->E5_CLIFOR  + "' "
	cQuery +=   " AND SE5.E5_LOJA    = '" + SE5->E5_LOJA    + "' "
	cQuery +=   " AND SE5.E5_SEQ     = '" + SE5->E5_SEQ     + "' "
	cQuery +=   " AND SE5.E5_RECPAG  = 'R' "
	cQuery +=   " AND SE5.D_E_L_E_T_ = ' ' "

	cQryRes := GetNextAlias()
	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	If !(cQryRes)->( EOF() )
		dDtBaixa := StoD((cQryRes)->E5_DTDISPO)
	EndIf

	(cQryRes)->( DbCloseArea() )
EndIf

SE5->(DbGoto(nRecSE5old))

Return dDtBaixa

//-------------------------------------------------------------------
/*/{Protheus.doc} JGrvBxPag
Realiza as operações referente ao módulo SIGAPFS logo no momento da
baixa dos títulos do contas a pagar no financeiro.

@param  nSE2Recno, numerico, Recno do registro SE2
@param  nOpc,      numérico, indica a operação a ser realizada
@param  nRecnoSE5, numérico, indica o recno do registro na SE5 (Mov. Bancária)
@param  nRegCmp  , numerico, Recno do Título que está sendo usado para compensar
@param  lExclusao, Boolean,  indica se esta sendo realizada a exclusão da baixa

@author Jorge Martins
@since 26/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JGrvBxPag(nRecnoSE2, nOpc, nRecnoSE5, nRegCmp, lExclusao)
Local aAreas       := {}
Local lRet         := .T.
Local lIntPFS      := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local nItemPFS     := 0
Local aModelLanc   := {}

Default nRecnoSE2  := 0
Default nOpc       := 0
Default nRecnoSE5  := 0
Default nRegCmp    := 0
Default lExclusao  := .T.

If lIntPFS
	aAreas := { SE2->(GetArea()), SE5->(GetArea()), GetArea() }

	If OHB->(ColumnPos("OHB_CPAGTO")) > 0
		If nOpc == MODEL_OPERATION_INSERT .And. FindFunction("JGeraLanc")
			lRet := JGeraLanc(nRecnoSE2, @aModelLanc, nRecnoSE5, nRegCmp)

		ElseIf nOpc == MODEL_OPERATION_DELETE .And. FindFunction("JurDelLanc")

			// Valida se é exclusão ou cancelamento da baixa
			If lExclusao
				lRet := JurDelLanc(, @aModelLanc, "P", , nRecnoSE2)
			Else
				lRet := JGeraLanc(nRecnoSE2, @aModelLanc, nRecnoSE5, nRegCmp, .T.)
			EndIf

			// Contabiliza Estorno de Desdobramento Baixa
			If lRet .And. FindFunction("JURA265B") .And. OHF->(ColumnPos("OHF_DTCONT")) > 0 .And. VerPadrao("957")
				lRet := JURA265B("957")
			EndIf
		EndIf

		// Integração SIGAPFS x SIGAFIN - Criação de Lançamentos (OHB) no momento da baixa
		If !Empty(aModelLanc)
			For nItemPFS := 1 To Len(aModelLanc)
				aModelLanc[nItemPFS]:CommitData()
			Next
		EndIf
	EndIf

	If FindFunction("JCriaCalend")
		SE5->(DbGoto(nRecnoSE5))
		JCriaCalend(SE5->E5_DATA) // Cria período no Calendário Contábil quando não existir
	EndIf
	
	Aeval( aAreas, {|aArea| RestArea( aArea ) } )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGeraLanc
Cria os lançamentos (OHB) na baixa dos títulos a pagar, verificando os
desdobramentos e desdobramentos pós pagamento, proporcionalizando de
acordo com o valor da baixa.

@param nRecnoSE2   - Recno do título - (SE2)
@param aModelLanc  - Array vazio para receber os modelos não comitados
@param nRecnoSE5   - Recno da Movimentação Bancária - (SE5)
@param nRegCmp     - Recno do Título que está sendo usado para compensar
@param lCancelBaix - Indica se esta fazendo o cancelamento da baixa do título

@Return lRet       - .T. Se a geração dos lançamentos foi feita com sucesso.

@author Cristina Cintra/Thiago Murakami
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGeraLanc(nRecnoSE2, aModelLanc, nRecnoSE5, nRegCmp, lCancelBaix)
Local aAreaOHB   := OHB->(GetArea())
Local aAreaOHF   := OHF->(GetArea())
Local lRet       := .T.
Local cBcoLanc   := ""
Local cAgeLanc   := ""
Local cCtaLanc   := ""
Local cHistLanc  := ""
Local nTxLanc    := 0
Local cNatTrans  := ""
Local cNatPag    := "" // Natureza relacionada ao banco da baixa, PA ou NDF
Local nValBxSE5  := 0
Local dDataSE5   := Date()
Local cSeqSE5    := ""
Local cMoedaSE5  := ""
Local cNatSE2    := ""
Local cDesNatSE2 := ""
Local cMoedaSE2  := ""
Local nVlSE2Desd := 0
Local nValOHF    := 0
Local nValOHB    := 0
Local nCotac     := 0
Local nI         := 1
Local aSetValue  := {}
Local aSetFields := {}
Local aDadosSED  := {}
Local lBaixaPA   := .F.
Local lBaixaImp  := .F.
Local lExistImp  := .F.
Local cNatOrig   := ""
Local cNatDest   := ""
Local cChvTitP   := ""
Local cChvDesd   := ""
Local cChvPagP   := ""
Local cIdDocTit  := ""
Local cIdDocPag  := ""
Local lReturn    := .F.
Local aLancDiv   := {}
Local aTemImp    := {}
Local nTotDistr  := 0
Local nLanc      := 0
Local nPag       := 0
Local nValTitNDF := 0
Local aRetDivLan := {}
Local cImpostos  := ""
Local cNatImp    := ""
Local lCompensac := .F.
Local cMoedaConv := ""
Local nTxConv    := 0
Local cMoeNac    := SuperGetMv('MV_JMOENAC',, '01')
Local lNegativo  := .F.
Local cCpoProjet := ""
Local cCpoPrjItm := ""
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))
Local lSE2Trans  := .F.
Local lMigrador  := FwIsInCallStack("MigBaixaCP")
Local aTitulos   := {}
Local nTit       := 1
Local lCpoOHBAgl := OHB->(ColumnPos("OHB_FATPAG")) > 0
Local cNatSE2Pai := ""
Local cTitPai    := ""
Local aChvSE2Pai := {}
Local aNatPag    := {}
Local lBxImpOld  := .F.
Local lExecImp   := .T. // Indica se deve executar a função JImpLanc no momento da baixa do título principal
Local lNDF       := .F.
Local cCpoEscrit := ""
Local cCpoCCusto := ""
Local cCpoSigla  := ""
Local cCpoTabRat := ""
Local lResSE2SE5 := .F. // Indica se deve ser restaurado o posicionamento inicial da SE2 e SE5
Local nIndexSE5  := 0
Local nBkpRecSE2 := nRecnoSE2
Local nBkpRecSE5 := nRecnoSE5

Default nRegCmp     := 0
Default lCancelBaix := .F.

SE2->(DbGoto(nRecnoSE2))
SE5->(DbGoto(nRecnoSE5))

lCompensac := Empty(SE5->E5_BANCO) .And. nRegCmp > 0 // Compensação de PA ou NDF

If JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_CCJURI") == "7" // A natureza do título é uma transitória de Pagamento
	cNatTrans := SE2->E2_NATUREZ
Else
	cNatTrans := JGetNatTra() // Natureza transitória de pagamento da classificação (OHP)
EndIf

// Se a compensação for feita posicionada no PA/NDF e não é cancelamento (estorno)
If lCompensac .And. !lCancelBaix .And. (SE2->E2_TIPO $ (MVPAGANT + "|NDF") .And. Empty(SE5->E5_BANCO))
	// Muda o posicionamento para o título a ser compensado (Ex: FT)
	SE2->(DbGoto(nRegCmp))
	// Inverte os valores das variáveis para serem usadas mais abaixo
	nRegCmp   := nRecnoSE2
	nRecnoSE2 := SE2->(Recno())

	If JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_CCJURI") == "7" // A natureza do título é uma transitória de Pagamento
		cNatTrans := SE2->E2_NATUREZ
	Else
		cNatTrans := JGetNatTra() // Natureza transitória de pagamento da classificação (OHP)
	EndIf
	
	// Também muda o posicionamento da SE5 para o título a ser compensado (Ex: FT)
	// Necessário pois a função JurLancDiv abaixo precisa do Recno do título e não do PA/NDF
	nIndexSE5 := SE5->(IndexOrd())
	SE5->(DbSetOrder(7))
	If SE5->(DbSeek(xFilial("SE5", SE2->E2_FILORIG) + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) + SE5->E5_SEQ))
		nRecnoSE5 := SE5->(Recno())
	EndIf

	lResSE2SE5  := .T. // Indica que os recnos e posicionamentos da SE2 e SE5 devem ser restaurados

EndIf

// Não executar nada quando for um cancelamento de compensação e estiver posicionado no PA ou NDF,
// pois o cancelamento da compensação faz dois estornos, a do PA ou NDF e a do Título a Pagar.
lReturn := (SE2->E2_TIPO $ (MVPAGANT + "|NDF") .And. Empty(SE5->E5_BANCO))

// Não cria OHB quando o motivo de baixa não gera movimento bancário,
// Se for compensação, ainda gera OHB para definir os valores desdobrados.
lReturn := lReturn .Or. (!lCompensac .And. !JIsMovBco(SE5->E5_MOTBX))

If Empty(cNatTrans)
	lRet := JurMsgErro(STR0181, , STR0182) // "Natureza transitória de pagamento não identificada." ## "Verifique o cadastro de classificação de naturezas, e informe uma natureza transitória de pagamento."
EndIf

If lRet .And. !lReturn
	cImpostos := MVTAXA   + '|' + MVTXA   + '|' // Taxa
	cImpostos += MVINSS   + '|' + MVINABT + '|' // INS
	cImpostos += MVISS    + '|' + MVISABT + '|' // ISS
	cImpostos += MVCOFINS + '|' + MVCFABT + '|' // COFINS
	cImpostos += MVPIS    + '|' + MVPIABT + '|' // PIS
	cImpostos += MVIRF    + '|' + MVIRABT + '|' // IRRF
	cImpostos += MVCS     + '|' + MVCSABT + '|' // CSS

	lBaixaImp := SE2->E2_TIPO $ cImpostos
	lBaixaPA  := SE2->E2_TIPO == MVPAGANT .And. !Empty(SE5->E5_BANCO) // Baixa de PA

	//---------------------------------------------------------------------------------------------
	// Controla se criam os lançamentos de impostos na baixa/estorno do título principal
	// Faz uma consulta na JImpLanc para ver se serão gerados lançamentos de imposto
	// Se o aTemImp tiver conteúdo indica que deverão ser gerados lançamentos de impostos
	//---------------------------------------------------------------------------------------------
	JImpLanc(@aTemImp, cNatTrans, nRecnoSE2, , lCompensac, .T.) // Faz uma consulta para ver se serão gerados lançamentos de imposto
	lExistImp := Len(aTemImp) > 0

	If lCompensac

		// Posiciona no PA/NDF
		If lCancelBaix
			// Quando é cancelamento o nRegCmp não vem com o Recno do PA/NDF, por isso é necessário fazer o posicionamento pelo SE5
			SE2->(DbSetOrder(1)) // SE2->E2_FILIAL +  SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
			SE2->(DbSeek(SE5->E5_FILIAL + SE5->E5_DOCUMEN))
		Else
			SE2->(dbGoTo(nRegCmp))
		EndIf

		lNDF       := SE2->E2_TIPO == "NDF"
		cChvPagP   := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
		cIdDocPag  := FINGRVFK7("SE2", cChvPagP)

		OHF->(DbSetOrder(1)) // OHF_FILIAL+OHF_IDDOC+OHF_CITEM

		If OHF->(DbSeek(SE2->E2_FILIAL + cIdDocPag)) // Cancelamento de Compensação ou Compensação
			If lNDF // NDF pode ter vários desdobramentos
				nValTitNDF := JCPVlBruto(SE2->(Recno())) // Valor do título do NDF (será usado para proporcionalizar o valor)
				aNatPag    := {} // Carrega as definições de escritório, centro de custo, profissional e tabela de rateio do título NDF
				While !OHF->(Eof()) .And. SE2->E2_FILIAL + cIdDocPag == OHF->OHF_FILIAL + OHF->OHF_IDDOC
					aAdd(aNatPag, {OHF->OHF_CNATUR, OHF->OHF_CESCR, OHF->OHF_CCUSTO, JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART2, "RD0_SIGLA"), OHF->OHF_CRATEI, OHF->OHF_VALOR})
					OHF->(DbSkip())
				EndDo
			Else // PA só pode ter um desdobramento
				aAdd(aNatPag, {OHF->OHF_CNATUR, "", "" , "" , "", 0})
			EndIf
		Else
			lRet := JurMsgErro(i18n(STR0126, {cChvPagP}),, STR0127) // "Não foi encontrado o complemento do título '#1'." "Verifique o desdobramento do título (Tabela: 'OHF')."
		EndIf

		// Posiciona no Título a Pagar
		SE2->(dbGoTo(nRecnoSE2))

	Else
		If lBaixaImp
			cChvPagP  := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
			cIdDocPag := FINGRVFK7("SE2", cChvPagP)
			OHF->(DbSetOrder(1)) // OHF_FILIAL+OHF_IDDOC+OHF_CITEM
			If OHF->(DbSeek(SE2->E2_FILIAL + cIdDocPag) )
				cNatImp := OHF->OHF_CNATUR
			Else
				lRet := JurMsgErro(i18n(STR0126, {cChvPagP}),, STR0127) // "Não foi encontrado o complemento do título '#1'." "Verifique o desdobramento do título (Tabela: 'OHF')."
			EndIf
		EndIf

		If lRet
			cBcoLanc := SE5->E5_BANCO
			cAgeLanc := SE5->E5_AGENCIA
			cCtaLanc := SE5->E5_CONTA
			cNatPag  := JurBusNat("", cBcoLanc, cAgeLanc, cCtaLanc, .T.)
			aAdd(aNatPag, {cNatPag, "", "" , "" , "", 0}) // Natureza do banco de pagamento do título
			lRet     := !Empty(cNatPag)
		EndIf
	EndIf

	If lRet

		If lBaixaImp
			If AllTrim(SE2->E2_ORIGEM) $ ("FINA381|FINA376|FINA378") // Aglutinação de impostos
				cTitPai := JBuscTitPai(SE2->E2_FILIAL, SE2->E2_NUM, SE2->E2_NATUREZ)
			EndIf
			// Se for uma baixa de um contas a pagar do tipo imposto,
			// Então pega a chave e valor do título pai do imposto para encontrar os desdobramentos dele e proporcionalizar o valor da baixa.
			SE2->(dbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
			If Empty(cTitPai)
				SE2->(DbSeek(SE2->E2_FILIAL + SE2->E2_TITPAI))
			Else
				SE2->(DbSeek(SE2->E2_FILIAL + cTitPai))
			EndIf
			cChvDesd   := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
			cNatSE2Pai := SE2->E2_NATUREZ
			aChvSE2Pai := {SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA}
			nVlSE2Desd := JCPVlBruto(SE2->(Recno()))
			SE2->(dbGoTo(nRecnoSE2))
		Else
			cChvDesd   := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
			nVlSE2Desd := JCPVlBruto(SE2->(Recno()))
		EndIf

		cIdDocTit  := FINGRVFK7("SE2", cChvDesd)

		cNatSE2    := SE2->E2_NATUREZ
		aDadosSED  := JurGetDados("SED", 1, xFilial("SED") + cNatSE2, {"ED_DESCRIC", "ED_CCJURI"})
		cDesNatSE2 := AllTrim(aDadosSED[1]) // Descrição da Natureza
		lSE2Trans  := aDadosSED[2] == "7" // Natureza do título é transitória de pagamento
		cMoedaSE2  := PADL(SE2->E2_MOEDA, TamSx3('CTO_MOEDA')[1], '0') // Moeda do título

		If lSE2Trans
			If SE2->E2_TIPO == MVPAGANT // Verifica se é PA, pois PA também vem como transitória
				cHistLanc := STR0132 + " - " + AllTrim(SE2->E2_FORNECE) + "/" + AllTrim(SE2->E2_LOJA) + " - " // "Estorno PA"
				cHistLanc += Capital(AllTrim(JurGetDados("SA2", 1, xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA , "A2_NOME")))
				cHistLanc += Iif(!Empty(SE2->E2_HIST), " - " + Capital(AllTrim(SE2->E2_HIST)), "")
			Else // Se for transitória indica o histórico do título no lançamento
				cHistLanc := Iif(Empty(SE2->E2_HIST), "", Capital(SE2->E2_HIST))
				If Empty(cHistLanc) // Se o histórico do título estiver em branco, indica o da baixa
					cHistLanc := Iif(Empty(SE5->E5_HISTOR), STR0045, Capital(SE5->E5_HISTOR)) // "Baixa a pagar automática"
				EndIf
			EndIf
		
		Else // Quando a natureza for definida, o Histórico dos lançamentos gerados será SEMPRE o do detalhe/desdobramento
			cChvPagP  := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
			cIdDocPag := FINGRVFK7("SE2", cChvPagP)
			If lBaixaImp // Coloca a descrição da natureza de imposto antes do histórico definido
				cHistLanc := cDesNatSE2 + " - "
			EndIf
			cHistLanc += JurGetDados("OHF", 1, SE2->E2_FILIAL + cIdDocPag, "OHF_HISTOR")
		EndIf

		cMoedaSE5  := SE5->E5_MOEDA
		nValBxSE5  := SE5->E5_VALOR
		If lCancelBaix .And. !Empty(SE5->E5_DTCANBX)
			dDataSE5 := SE5->E5_DTCANBX
		Else
			dDataSE5 := SE5->E5_DATA
		EndIf
		cSeqSE5    := SE5->E5_SEQ
		aRetDivLan := JurLancDiv("1", nRecnoSE5)
		lRet       := aRetDivLan[1]
		aLancDiv   := aRetDivLan[2]
		cChvTitP   := SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
	EndIf

	/*
	O sistema permite que no momento da baixa de um título em moeda estrangeira, seja selecionado um banco com moeda nacional.

	Por isso é necessário realizar a conversão do valor do título, já que a baixa será feita na moeda do banco,
	e o lançamento será gerado com a moeda do banco e com o valor convertido.

	Ex: SE2 - Título
		- Valor do título = 1000 - Moeda do título = 2 (Dólar) - Taxa moeda = 4
		SE5 - Baixa
		- Valor da baixa  = 4000 (Valor do título x Taxa moeda) - Moeda do banco  = 1 (Nacional)
		OHB - Lançamento
		- Valor do lançamento = 4000 - Moeda do lançamento = 1 (Nacional)
		Cotação no lançamento = 0,25 -> (1 / Taxa Moeda)
	*/
	If lRet
		If cMoedaSE2 <> cMoedaSE5
			If FwIsInCallStack("FINA090") // Baixa automática e baixa de borderô
				nTxLanc := IIf(SE2->E2_TXMOEDA > 0, SE2->E2_TXMOEDA, RecMoeda(Date(), SE2->E2_MOEDA) )

			ElseIf FwIsInCallStack("FINA080") // Baixa manual e baixa em lote
				If Type("nOldTxMoed") <> "U" // nOldTxMoed -> Taxa da Moeda da Baixa (Usada na baixa manual)
					nTxLanc := nOldTxMoed
				ElseIf Type("nValPadrao") <> "U" .And. Type("nValEstrang") <> "U" // Baixa em lote
					nTxLanc := nValPadrao / nValEstrang
				EndIf
			EndIf

			nCotac     := 1 / nTxLanc
			nVlSE2Desd := nVlSE2Desd * nTxLanc // Aplica a taxa de conversão no valor do título, para que fique convertido na moeda do banco da baixa
		EndIf

		If !lBaixaPA .And. (lSE2Trans .Or. !Empty(aLancDiv) .Or. lBaixaImp .Or. lExistImp .Or. !Empty(SE2->E2_FATURA))

			// Em baixas: Cria um lançamento com 100% do valor da baixa com Origem na Natureza do Banco e Destino na Transitória de Pagamento
			
			// Compensação usando PA: Cria um lançamento com o valor da compensação com Origem na Natureza do PA e Destino na Transitória de Pagamento
			
			// Compensação usando NDF:
				// Se a natureza do título de NDF for definida: Cria um lançamento com o valor da compensação com Origem na Natureza do NDF e Destino na Transitória de Pagamento
				// Se a natureza do título de NDF for transitória: Cria um lançamento com o valor proporcional da compensação para cada desdobramento com Origem na Natureza do desdobramento do NDF e Destino na Transitória de Pagamento
			
			For nPag := 1 To Len(aNatPag)

				cNatPag := aNatPag[nPag][1] // Natureza do banco de pagamento (baixa) ou da compensação (PA ou NDF)

				If JurGetDados("SED", 1, xFilial("SED") + cNatPag, "ED_CCJURI") == "7" .And. cNatPag == cNatTrans // Tratamento quando for uma compensação de PA
					// Ao gerar um compensação é enviado o valor do PA direto para a transitória de pagamento
					// assim não devemos gerar novamente essa movimentação
					nTotDistr := nValBxSE5
					If lExistImp .And. lExecImp // Cria lançamentos de impostos no momento da baixa do título principal
						JImpLanc(@aLancDiv, cNatTrans, nRecnoSE2, , lCompensac)
						lExecImp := .F. // Altera a variável para não incluir os impostos mais de uma vez nas compesações de NDF com vários desdobramentos
					EndIf
				Else
					If lBaixaImp // Baixa de imposto
						aAdd(aLancDiv, {cNatPag, cNatImp, nValBxSE5, cHistLanc})
						
						If JurGetDados("SED", 1, xFilial("SED") + cNatSE2Pai, "ED_CCJURI") == "7" // Natureza do título principal é transitória de pagamento
							cNatTrans := cNatSE2Pai // Ao invés de usar a transitória da classificação, usa a do título principal
						EndIf
						
						// Valida se a OHB do imposto será no formato antigo.
						If !JExImpLanc(cNatImp, cNatTrans, cChvDesd, aChvSE2Pai)

							// Caso não encontre o lançamento de imposto no momento da baixa do título principal,
							// Indica que essa baixa de imposto é da forma antiga
							lBxImpOld := .T.

							// Com isso deve gerar as OHB's do imposto para transitória e da transitória para a natureza de resultado (OHF's)
							aAdd(aLancDiv, {cNatImp, cNatTrans, nValBxSE5, cHistLanc})
						EndIf
					Else
						If lNDF
							nValOHB := JurValOHB(nValBxSE5, nValTitNDF, aNatPag[nPag][6]) // Pega o valor proporcional por desdobramento do NDF
						Else
							nValOHB := nValBxSE5
						EndIf
						aAdd(aLancDiv, {cNatPag, cNatTrans, nValOHB, cHistLanc, aNatPag[nPag][2], aNatPag[nPag][3], aNatPag[nPag][4], aNatPag[nPag][5]})
						If lExistImp .And. lExecImp // Cria lançamentos de impostos no momento da baixa do título principal
							JImpLanc(@aLancDiv, cNatTrans, nRecnoSE2, , lCompensac)
							lExecImp := .F. // Altera a variável para não incluir os impostos mais de uma vez nas compesações de NDF com vários desdobramentos
						EndIf
					EndIf
				EndIf
			
			Next

			nTxConv :=  IIF(FwIsInCallStack("FINA080") .And. Type("nOldTxMoed") <> "U", nOldTxMoed, SE2->E2_TXMOEDA)
			
			// Gera Lançamentos com base na SE5
			For nLanc := 1 To Len(aLancDiv)
				aAdd(aSetValue, {"OHB_ORIGEM" , "1"                }) // 1-Contas a Pagar

				If lCancelBaix
					aAdd(aSetValue, {"OHB_NATORI" , aLancDiv[nLanc][2] })
					aAdd(aSetValue, {"OHB_NATDES" , aLancDiv[nLanc][1] })
					If Len(aLancDiv[nLanc]) == 8 // Usado para compensação de NDF
						aAdd(aSetValue, {"OHB_CESCRD" , aLancDiv[nLanc][5] })
						aAdd(aSetValue, {"OHB_CCUSTD" , aLancDiv[nLanc][6] })
						aAdd(aSetValue, {"OHB_SIGLAD" , aLancDiv[nLanc][7] })
						aAdd(aSetValue, {"OHB_CTRATD" , aLancDiv[nLanc][8] })
					EndIf
				Else
					aAdd(aSetValue, {"OHB_NATORI" , aLancDiv[nLanc][1] })
					aAdd(aSetValue, {"OHB_NATDES" , aLancDiv[nLanc][2] })
					If Len(aLancDiv[nLanc]) == 8 // Usado para compensação de NDF
						aAdd(aSetValue, {"OHB_CESCRO" , aLancDiv[nLanc][5] })
						aAdd(aSetValue, {"OHB_CCUSTO" , aLancDiv[nLanc][6] })
						aAdd(aSetValue, {"OHB_SIGLAO" , aLancDiv[nLanc][7] })
						aAdd(aSetValue, {"OHB_CTRATO" , aLancDiv[nLanc][8] })
					EndIf
				EndIf

				aAdd(aSetValue, {"OHB_DTLANC" , dDataSE5           })
				aAdd(aSetValue, {"OHB_CMOELC" , cMoedaSE5          })
				aAdd(aSetValue, {"OHB_VALOR"  , aLancDiv[nLanc][3] })

				cMoedaConv :=  JurGetDados("SED", 1, xFilial("SED") + aLancDiv[nLanc][2], "ED_CMOEJUR")
				If cMoedaSE2 <>  cMoedaConv
					aAdd(aSetValue, {"OHB_CMOEC"  , IIF(cMoedaSE5 == cMoedaConv, "", cMoedaConv) }) // Moeda da conversão
					aAdd(aSetValue, {"OHB_COTAC"  , nTxConv                                      })
					aAdd(aSetValue, {"OHB_VALORC" , aLancDiv[nLanc][3] * nTxConv                 }) // Valor da conversão
				EndIf

				If nCotac > 0
					aAdd(aSetValue, {"OHB_COTAC", IIF(cMoedaSE5 == cMoedaConv, 0, nCotac * nTxLanc) })
				EndIf
				aAdd(aSetValue, {"OHB_HISTOR" , aLancDiv[nLanc][4] })
				aAdd(aSetValue, {"OHB_FILORI" , cFilAnt   })
				aAdd(aSetValue, {"OHB_CPAGTO" , cChvTitP  })
				aAdd(aSetValue, {"OHB_SE5SEQ" , cSeqSE5   })
				If lCpoOHBAgl .And. !Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM $ "FINA290 |FINA290M"
					aAdd(aSetValue, {"OHB_FATPAG" , cChvTitP}) // Chave do título oriundo da aglutinação FINA290
				EndIf

				// Se for execução do migrador, gera a OHB via RecLock na GrvOHBCP
				If lMigrador
					U_GrvOHBCP(aSetValue)
				Else
					aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
					aAdd(aModelLanc, JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, aSetFields))
				EndIf

				// Gera o total sem os Acréscimos e somando os descontos
				If Empty(cNatImp) .Or. cNatImp != aLancDiv[nLanc][2]
					nTotDistr += Iif( aLancDiv[nLanc][1] == cNatTrans , -aLancDiv[nLanc][3], aLancDiv[nLanc][3])
				EndIf
			Next nLanc

			If !Empty(SE2->E2_FATURA) .Or. (SE2->E2_ORIGEM $ "FINA290 |FINA290M") // Faturas a pagar - Aglutinação
				aTitulos   := JurTit290(.F.)
				nVlSE2Desd := 0
				AEval(aTitulos, {|x| nVlSE2Desd += x[3]})

				If nCotac > 0
					nVlSE2Desd := nVlSE2Desd * nTxLanc
				EndIf
			ElseIf AllTrim(SE2->E2_ORIGEM) $ ("FINA381|FINA376|FINA378") // Aglutinação de impostos
				aTitulos := JurTitAgl()
			Else
				aTitulos := {{cIdDocTit, cChvTitP, nVlSE2Desd}}
			EndIf

			OHF->(DbSetOrder(1)) // OHF_FILIAL+OHF_IDDOC+OHF_CITEM

			// No novo comportamento baixa de imposto não gera lançamentos (OHB) para as naturezas das OHFs do título original
			// Porém em alguns casos, o sistema deve se comportar da forma antiga, por esse motivo usamos a lBxImpOld
			// para saber se a baixa do imposto de comportará da forma antiga
			If !lBaixaImp .Or. lBxImpOld
				For nTit := 1 To Len(aTitulos)
					cIdDocTit := aTitulos[nTit][1]
					cChvTitP  := aTitulos[nTit][2]

					// Cria um lançamento para cada desdobramento
					If OHF->(DbSeek( SE2->E2_FILIAL + cIdDocTit))

						While !OHF->(Eof()) .And. cIdDocTit == OHF->OHF_IDDOC
							// A posição 4 do array aTitulos só existirá quando o título principal já estiver baixado (lBxImpOld = T)
							If (Len(aTitulos[nTit]) == 3 .Or. (Len(aTitulos[nTit]) == 4 .And. aTitulos[nTit][4] == OHF->OHF_CITEM))
								lNegativo := OHF->OHF_VALOR < 0
								nValOHF   := IIF(lNegativo, OHF->OHF_VALOR * -1, OHF->OHF_VALOR)
								
								If nCotac > 0
									nValOHF := nValOHF * nTxLanc
								EndIf
								
								If lBxImpOld .And. lBaixaImp
									nValOHB := JurValOHB(nTotDistr, SE2->E2_VALOR, aTitulos[nTit][3])
								Else
									nValOHB := JurValOHB(nTotDistr, nVlSE2Desd, nValOHF)
								EndIf
								
								JurFreeArr(@aSetValue)
								JurFreeArr(@aSetFields)
								aAdd(aSetValue, {"OHB_ORIGEM" , "1"                                                                  }) // 1-Contas a Pagar

								If lCancelBaix
									// Caso o lançamento for negativo, além de inverter as naturezas
									// também precisa inverter os campos de definição do centro de custo
									cCpoEscrit := IIF(lNegativo, "OHB_CESCRD", "OHB_CESCRO")
									cCpoCCusto := IIF(lNegativo, "OHB_CCUSTD", "OHB_CCUSTO")
									cCpoSigla  := IIF(lNegativo, "OHB_SIGLAD", "OHB_SIGLAO")
									cCpoTabRat := IIF(lNegativo, "OHB_CTRATD", "OHB_CTRATO")

									aAdd(aSetValue, {"OHB_NATDES" , IIF(lNegativo, OHF->OHF_CNATUR, cNatTrans)                           })
									aAdd(aSetValue, {"OHB_NATORI" , IIF(lNegativo, cNatTrans, OHF->OHF_CNATUR)                           })
									aAdd(aSetValue, {cCpoEscrit   , OHF->OHF_CESCR                                                       })
									aAdd(aSetValue, {cCpoCCusto   , OHF->OHF_CCUSTO                                                      })
									aAdd(aSetValue, {cCpoSigla    , JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART2, "RD0_SIGLA") })
									aAdd(aSetValue, {cCpoTabRat   , OHF->OHF_CRATEI                                                      })
								Else
									// Caso o lançamento for negativo, além de inverter as naturezas
									// também precisa inverter os campos de definição do centro de custo
									cCpoEscrit := IIF(lNegativo, "OHB_CESCRO", "OHB_CESCRD")
									cCpoCCusto := IIF(lNegativo, "OHB_CCUSTO", "OHB_CCUSTD")
									cCpoSigla  := IIF(lNegativo, "OHB_SIGLAO", "OHB_SIGLAD")
									cCpoTabRat := IIF(lNegativo, "OHB_CTRATO", "OHB_CTRATD")

									aAdd(aSetValue, {"OHB_NATORI" , IIF(lNegativo, OHF->OHF_CNATUR, cNatTrans)                           })
									aAdd(aSetValue, {"OHB_NATDES" , IIF(lNegativo, cNatTrans, OHF->OHF_CNATUR)                           })
									aAdd(aSetValue, {cCpoEscrit   , OHF->OHF_CESCR                                                       })
									aAdd(aSetValue, {cCpoCCusto   , OHF->OHF_CCUSTO                                                      })
									aAdd(aSetValue, {cCpoSigla    , JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART2, "RD0_SIGLA") })
									aAdd(aSetValue, {cCpoTabRat   , OHF->OHF_CRATEI                                                      })
								EndIf

								aAdd(aSetValue, {"OHB_CCLID"  , OHF->OHF_CCLIEN                                                      })
								aAdd(aSetValue, {"OHB_CLOJD"  , OHF->OHF_CLOJA                                                       })
								aAdd(aSetValue, {"OHB_CCASOD" , OHF->OHF_CCASO                                                       })
								aAdd(aSetValue, {"OHB_CTPDPD" , OHF->OHF_CTPDSP                                                      })
								aAdd(aSetValue, {"OHB_QTDDSD" , OHF->OHF_QTDDSP                                                      })
								aAdd(aSetValue, {"OHB_COBRAD" , OHF->OHF_COBRA                                                       })
								aAdd(aSetValue, {"OHB_DTDESP" , OHF->OHF_DTDESP                                                      })
								aAdd(aSetValue, {"OHB_SIGLA"  , JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART, "RD0_SIGLA")  })
								aAdd(aSetValue, {"OHB_DTLANC" , dDataSE5                                                             })
								aAdd(aSetValue, {"OHB_CMOELC" , cMoedaSE5                                                            })
								aAdd(aSetValue, {"OHB_VALOR"  , nValOHB                                                              })
								cMoedaConv  := JurGetDados("SED", 1, xFilial("SED") + OHF->OHF_CNATUR, "ED_CMOEJUR")
								aAdd(aSetValue, {"OHB_CMOEC"  , IIF(cMoedaSE5 == cMoedaConv, "", cMoedaConv)                         }) // Moeda da conversão
								aAdd(aSetValue, {"OHB_COTAC"  , IIF(cMoedaSE5 == cMoedaConv, 0 , nTxConv)                            })
								aAdd(aSetValue, {"OHB_VALORC" , IIF(cMoedaSE5 == cMoedaConv, 0 , nValOHB * IIF(nCotac == 0, nTxConv, nCotac))}) // Valor da conversão
								aAdd(aSetValue, {"OHB_VLNAC"  , IIF(cMoedaSE5 == cMoeNac, nValOHB, nValOHB * nTxConv)                }) // Valor na Moeda Nacional
								aAdd(aSetValue, {"OHB_CHISTP" , OHF->OHF_CHISTP                                                      })
								aAdd(aSetValue, {"OHB_HISTOR" , IIf(lBaixaImp, cHistLanc, OHF->OHF_HISTOR)                           }) // Quando for impostos coloca o mesmo histórico em todos os lançamentos gerados
								aAdd(aSetValue, {"OHB_FILORI" , cFilAnt                                                              })
								aAdd(aSetValue, {"OHB_ITDES"  , OHF->OHF_CITEM                                                       })
								aAdd(aSetValue, {"OHB_CPAGTO" , cChvTitP                                                             })
								aAdd(aSetValue, {"OHB_SE5SEQ" , cSeqSE5                                                              })
								aAdd(aSetValue, {"OHB_CDESPD" , OHF->OHF_CDESP                                                       })

								aAdd(aSetValue, {Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE") , OHF->OHF_CPROJE                         })
								aAdd(aSetValue, {Iif(lHasPrjDes,"OHB_CITPRD","OHB_CITPRJ") , OHF->OHF_CITPRJ                         })
								If lCpoOHBAgl .And. !Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM $ "FINA290 |FINA290M"
									aAdd(aSetValue, {"OHB_FATPAG" , SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA }) // Chave do título oriundo da aglutinação FINA290
								EndIf
								
								// Se for execução do migrador, gera a OHB via RecLock na GrvOHBCP
								If lMigrador
									U_GrvOHBCP(aSetValue)
								Else
									aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
									aAdd(aModelLanc, JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, aSetFields))
								EndIf
							EndIf
							OHF->(DbSkip())
						EndDo
					EndIf
				Next nTit
			EndIf
			
			JurFreeArr(@aTitulos)
		Else

			// Cria um lançamento com 100% do valor da baixa com Origem na Natureza do Banco e Destino na Natureza da SE2 / único desdobramento
			OHF->(DbSetOrder(1)) // OHF_FILIAL+OHF_IDDOC+OHF_CITEM
			If OHF->(DbSeek( SE2->E2_FILIAL + cIdDocTit))

				For nPag := 1 To Len(aNatPag)

					cNatPag := aNatPag[nPag][1] // Natureza do banco de pagamento (baixa) ou da compensação (PA ou NDF)
			
					If lBaixaPA
						cNatOrig   := OHF->OHF_CNATUR
						cNatDest   := cNatPag
						cCpoProjet := "OHB_CPROJE"
						cCpoPrjItm := "OHB_CITPRJ"
					Else
						cNatOrig   := cNatPag
						cNatDest   := OHF->OHF_CNATUR
						cCpoProjet := Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE")
						cCpoPrjItm := Iif(lHasPrjDes,"OHB_CITPRD","OHB_CITPRJ")
					EndIf

					If lNDF
						nValOHB := JurValOHB(nValBxSE5, nValTitNDF, aNatPag[nPag][6]) // Pega o valor proporcional por desdobramento do NDF
					Else
						nValOHB := nValBxSE5
					EndIf
				
					nValOHF := OHF->OHF_VALOR
					If nCotac > 0
						nValOHF := nValOHF * nTxLanc
					EndIf
					aAdd(aSetValue, {"OHB_ORIGEM" , "1"                                                                   })

					If lCancelBaix
						aAdd(aSetValue, {"OHB_NATORI" , cNatDest                                                              })
						aAdd(aSetValue, {"OHB_NATDES" , cNatOrig                                                              })
						aAdd(aSetValue, {"OHB_CESCRO" , OHF->OHF_CESCR                                                        })
						aAdd(aSetValue, {"OHB_CCUSTO" , OHF->OHF_CCUSTO                                                       })
						aAdd(aSetValue, {"OHB_SIGLAO" , JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART2, "RD0_SIGLA")  })
						aAdd(aSetValue, {"OHB_CTRATO" , OHF->OHF_CRATEI                                                       })
						If lNDF
							aAdd(aSetValue, {"OHB_CESCRD" , aNatPag[nPag][2]                                                  })
							aAdd(aSetValue, {"OHB_CCUSTD" , aNatPag[nPag][3]                                                  })
							aAdd(aSetValue, {"OHB_SIGLAD" , aNatPag[nPag][4]                                                  })
							aAdd(aSetValue, {"OHB_CTRATD" , aNatPag[nPag][5]                                                  })
						EndIf
					Else
						aAdd(aSetValue, {"OHB_NATORI" , cNatOrig                                                              })
						aAdd(aSetValue, {"OHB_NATDES" , cNatDest                                                              })
						aAdd(aSetValue, {"OHB_CESCRD" , OHF->OHF_CESCR                                                        })
						aAdd(aSetValue, {"OHB_CCUSTD" , OHF->OHF_CCUSTO                                                       })
						aAdd(aSetValue, {"OHB_SIGLAD" , JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART2, "RD0_SIGLA")  })
						aAdd(aSetValue, {"OHB_CTRATD" , OHF->OHF_CRATEI                                                       })
						If lNDF
							aAdd(aSetValue, {"OHB_CESCRO" , aNatPag[nPag][2]                                                  })
							aAdd(aSetValue, {"OHB_CCUSTO" , aNatPag[nPag][3]                                                  })
							aAdd(aSetValue, {"OHB_SIGLAO" , aNatPag[nPag][4]                                                  })
							aAdd(aSetValue, {"OHB_CTRATO" , aNatPag[nPag][5]                                                  })
						EndIf
					EndIf

					aAdd(aSetValue, {"OHB_CCLID"  , OHF->OHF_CCLIEN                                                       })
					aAdd(aSetValue, {"OHB_CLOJD"  , OHF->OHF_CLOJA                                                        })
					aAdd(aSetValue, {"OHB_CCASOD" , OHF->OHF_CCASO                                                        })
					aAdd(aSetValue, {"OHB_CTPDPD" , OHF->OHF_CTPDSP                                                       })
					aAdd(aSetValue, {"OHB_QTDDSD" , OHF->OHF_QTDDSP                                                       })
					aAdd(aSetValue, {"OHB_COBRAD" , OHF->OHF_COBRA                                                        })
					aAdd(aSetValue, {"OHB_DTDESP" , OHF->OHF_DTDESP                                                       })
					aAdd(aSetValue, {"OHB_SIGLA"  , JurGetDados("RD0", 1, xFilial("RD0") + OHF->OHF_CPART, "RD0_SIGLA")   })
					aAdd(aSetValue, {"OHB_DTLANC" , dDataSE5                                                              })
					aAdd(aSetValue, {"OHB_CMOELC" , cMoedaSE5                                                             })
					aAdd(aSetValue, {"OHB_VALOR"  , JurValOHB(nValOHB, nVlSE2Desd, nValOHF)                               })
					If nCotac > 0
						aAdd(aSetValue, {"OHB_COTAC", nCotac                                                              })
					EndIf
					aAdd(aSetValue, {"OHB_CHISTP" , OHF->OHF_CHISTP                                                       })
					aAdd(aSetValue, {"OHB_HISTOR" , IIf(lBaixaPA, cHistLanc, OHF->OHF_HISTOR)                             }) // Quando for baixa de PA coloca o histórico indicando Estorno
					aAdd(aSetValue, {"OHB_FILORI" , cFilAnt                                                               })
					aAdd(aSetValue, {"OHB_ITDES"  , OHF->OHF_CITEM                                                        })
					aAdd(aSetValue, {"OHB_CPAGTO" , cChvTitP                                                              })
					aAdd(aSetValue, {"OHB_SE5SEQ" , cSeqSE5                                                               })
					aAdd(aSetValue, {cCpoProjet   , OHF->OHF_CPROJE                                                       })
					aAdd(aSetValue, {cCpoPrjItm   , OHF->OHF_CITPRJ                                                       })
					aAdd(aSetValue, {"OHB_CDESPD" , OHF->OHF_CDESP                                                        })

					// Se for execução do migrador, gera a OHB via RecLock na GrvOHBCP
					If lMigrador
						U_GrvOHBCP(aSetValue)
					Else
						aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
						aAdd(aModelLanc, JurGrModel("JURA241", MODEL_OPERATION_INSERT, {}/*aSeek*/, aSetFields))
					EndIf
				Next
			EndIf
		EndIf

		For nI := 1 To Len(aModelLanc)
			If Empty(aModelLanc[nI])
				lRet       := .F.
				JurFreeArr(@aModelLanc)
				Exit
			EndIf
		Next
	EndIf
EndIf

If lResSE2SE5 // Restura o posicionamento e índice inicial da SE2 e SE5 (necessário em casos de compensação posicionado no PA)
	SE2->(DbGoto(nBkpRecSE2))

	SE5->(DbSetOrder(nIndexSE5))
	SE5->(DbGoto(nBkpRecSE5))
EndIf

RestArea(aAreaOHF)
RestArea(aAreaOHB)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDelLanc
Deleta os lançamentos (OHB) na baixa dos títulos a Pagar/Receber,

@param cChave     Chave do contas a Pagar/Receber
@param aModelLanc Array vazio para receber os modelos não comitados para ser delatados (passar como referência).
@param cOrigem    Origem do título (P=Pagar, R=Receber)
@param cSeqSE5    Sequencia do SE5
@param nRecnoSE2  Recno do contas a Pagar/Receber

@return lRet      Se houve erro para gerar o modelo

@author Cristina Cintra/Thiago Murakami
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurDelLanc(cChave, aModelLanc, cOrigem, cSeqSE5, nRecnoSE2)
Local aAreaOHB    := OHB->(GetArea())
Local aAreaOHF    := OHF->(GetArea())
Local lRet        := .T.
Local nI          := 0
Local nTit        := 0
Local cCodOHB     := ""
Local aSeek       := {}
Local aCampos     := {}
Local aCodOHB     := {}
Local aTitulos    := {}
Local lCpoOHBAgl  := OHB->(ColumnPos("OHB_FATPAG")) > 0 // @12.1.2310

Default cSeqSE5   := SE5->E5_SEQ
Default cChave    := ""
Default nRecnoSE2 := 0

	If nRecnoSE2 > 0
		SE2->(dbGoTo(nRecnoSE2))
		cChave  := SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
	EndIf

	If cOrigem == "P" .And. !Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM $ "FINA290 |FINA290M" // Título gerado através da aglutinação de faturas FINA290
		aTitulos := JurTit290(.T.)
	EndIf

	Aadd(aTitulos, {cChave, cSeqSE5})

	aAdd(aCampos, {"OHB_SE5SEQ", cSeqSE5})
		
	If cOrigem == "P"
		aAdd(aCampos, {"OHB_CPAGTO", cChave})
	Else
		aAdd(aCampos, {"OHB_CRECEB", cChave})
	EndIf

	For nTit := 1 To Len(aTitulos)
		cChave  := AllTrim(aTitulos[nTit][1])
		cSeqSE5 := aTitulos[nTit][2]
		
		aCampos[1][2] := cSeqSE5
		aCampos[2][2] := cChave

		aCodOHB := JGetInfOHB("OHB_CODIGO", aCampos, lCpoOHBAgl)

		For nI := 1 to Len(aCodOHB)
			cCodOHB := aCodOHB[nI][1]

			// Array para busca do Lançamento na OHB que será excluído
			aAdd(aSeek, "OHB")
			aAdd(aSeek, 1)
			aAdd(aSeek, xFilial("OHB") + cCodOHB)

			aAdd(aModelLanc, JurGrModel("JURA241", MODEL_OPERATION_DELETE, aSeek))

			aSeek := {}
		Next nI
	Next nTit

	For nI := 1 To Len(aModelLanc)
		If Empty(aModelLanc[nI])
			lRet       := .F.
			aModelLanc := {}
			Exit
		EndIf
	Next

	JurFreeArr(@aSeek)
	JurFreeArr(@aCampos)
	JurFreeArr(@aCodOHB)
	JurFreeArr(@aTitulos)

	RestArea(aAreaOHF)
	RestArea(aAreaOHB)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSetVal()
Realiza SetValue dos campos para replicar os valores do
desdobramento pós pagamento para o lançamento.

@param oModel      => Modelo da tabela a ser verificada
@param cCampo      => Campo para setar o valor
@param xValue      => Valor para ser inserido no campo

@author Jorge Martins
@since 21/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurSetVal(oModel, cCampo, xValue)

If oModel:GetValue(cCampo) != xValue
	If oModel:CanSetValue(cCampo)
		oModel:SetValue(cCampo, xValue)
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValOHB()
Faz o cálculo do valor do Lançamento que será gerado a partir da baixa,
com base no valor do desdobramento.

@author Cristina Cintra/Jorge Martins
@since 22/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurValOHB(nValBx, nValTit, nValDesd)
Local nVal   := 0
Local nProp  := 0

nProp := nValDesd / nValTit
nVal  := nProp * nValBx

Return nVal

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetInfOHB
Retorna informações do lançamento OHB referente ao filtro indicado

@param  cInfo     , Indica campo que deseja ter o valor
@param  aCampos   , {cCampo,cValor} // Indica campo e valor para busca
@param  lCpoOHBAgl, Existência do campo de Faturas a Pagar/Aglutinação FINA290

@return aSQL      , Código do Lançamento (OHB)

@author Jorge Martins
@since  23/02/2018
/*/
//-------------------------------------------------------------------
Function JGetInfOHB(cInfo, aCampos, lCpoOHBAgl)
Local aSQL      := {}
Local cQuery    := 0
Local nI        := 0
Local cFatPag   := ""

Default cInfo      := ""
Default aCampos    := {}
Default lCpoOHBAgl := OHB->(ColumnPos("OHB_FATPAG")) > 0 // @12.1.2310

If !Empty(cInfo) .And. Len(aCampos) > 0
	cQuery := " SELECT " + cInfo + " CINFO "
	cQuery +=   " FROM " + RetSqlName("OHB") + " OHB "
	cQuery +=  " WHERE OHB_FILIAL = '" + xFilial("OHB") + "' "

	For nI := 1 To Len(aCampos)
		cQuery +=" AND " + aCampos[nI][1] + " = '" + aCampos[nI][2] + "' "
	Next
	If lCpoOHBAgl .And. !Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM $ "FINA290 |FINA290M" // Cancelamento de baixa de título oriundo da aglutinação FINA290
		cFatPag := RTrim(SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA)
		cQuery +=" AND TRIM(OHB_FATPAG) = '" + cFatPag + "' "
	EndIf
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	aSQL := JurSQL(cQuery, {"CINFO"})

EndIf

Return aSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsJuTit()
Função para verificar se o titulo é do Jurídico.
Chamada na FINA070 - Contas a Receber.
           FINXBX  - Função fA070Grv - Contas a Receber

@param nRecno  , numerico, Recno do registro SE1
@param lEmisFat, lógico  , Indica se a chamada foi na emissão de fatura

@return lRet, logico, .T. se o titulo for do PFS

@author Luciano Pereira dos Santos
@since 26/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsJuTit(nRecno, lEmisFat)
Local lRet    := .F.
Local aArea   := GetArea()
Local lIntPFS := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

Default lEmisFat := .F. // Indica se é emissão de fatura, para localizar a partir do E1_JURFAT

If lIntPFS
	SE1->(DbGoto(nRecno))
	If !lEmisFat .And. AliasInDic("OHT")
		cQuery := " SELECT 1 FROM " + RetSqlName("OHT") + " OHT"
		cQuery +=  " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT") + "'"
		cQuery +=    " AND OHT.OHT_FILTIT = '" + SE1->E1_FILIAL + "'"
		cQuery +=    " AND OHT.OHT_PREFIX = '" + SE1->E1_PREFIXO + "'"
		cQuery +=    " AND OHT.OHT_TITNUM = '" + SE1->E1_NUM  + "'"
		cQuery +=    " AND OHT.OHT_TITPAR = '" + SE1->E1_PARCELA + "'"
		cQuery +=    " AND OHT.OHT_TITTPO = '" + SE1->E1_TIPO + "'"
		cQuery +=    " AND OHT.D_E_L_E_T_ = ' '"

		aFatOHT := JurSQL(cQuery, {"*"})
		lRet    := Len(aFatOHT) > 0
	Else
		lRet := !SE1->(EOF()) .And. !Empty(SE1->E1_JURFAT)
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurIsDesp(cCodNat)
Verifica se a natureza tem o centro de custo de despesa para cliente.

@param cTab        => Tabela que será verificada
@param cCodNat     => Código da Natureza

@Return lIsDespesa => Se o centro de custo é despesa para cliente

@author Jorge Martins
@since 10/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurIsDesp(cTab, cCodNat)
	Local oModel     := FWModelActive()
	Local oModelTab  := oModel:GetModel( cTab + "DETAIL" )
	Local nLine      := oModelTab:GetLine()
	Local lIsDespesa := .F.
	Local cTipoNat   := ''

	Default cCodNat  := ''

	If Empty(cCodNat)
		cTipoNat  := JurGetDados('SED', 1, xFilial('SED') + oModelTab:GetValue( cTab + '_CNATUR', nLine), 'ED_CCJURI')
		lIsDespesa := cTipoNat == '5'
	Else
		lIsDespesa := JurGetDados('SED', 1, xFilial('SED') + cCodNat, 'ED_CCJURI') == '5'
	EndIf

Return lIsDespesa

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBolFat
Emissão de boleto de fatura SIGAPFS via financeiro SIGAFIN

@param   nSE1Recno, numerico, RECNO do título a receber

@author  Jonatas Martins / Jorge Martins
@since   18/04/2018
@version 1.0
@obs     Função chamada no menu do FINA040 e FINA740
/*/
//-------------------------------------------------------------------
Function JurBolFat( nSE1Recno )
Local cJurFat     := ""
Local cResult     := ""
Local aAreaSE1    := SE1->( GetArea() )
Local nTamFil     := 0
Local nTamEsc     := 0
Local nTamFat     := 0
Local aResult     := {}
Local cEscrit     := ""
Local cFatura     := ""
Local cParcela    := ""
Local lParcPos    := .F. // Indica se fará a impressão somente da parcela posicionada
Local lRelat      := .F. // Indica que a geração de boleto é feito pelo módulo financeiro
Local lExistOHT   := AliasInDic("OHT")

Default nSE1Recno := 0

	SE1->( DbGoTo( nSE1Recno ) )

	If JurVldBol()
		aResult  := JurGetResult()
		cResult  := aResult[1]        // "1 = Impressora, 2 = Tela, 3 = Nenhum"
		lParcPos := aResult[2] == "1" // "1 = Parcela atual, 2 = Todas pendentes"
		If ! Empty( cResult )

			If !Empty(SE1->E1_JURFAT) .Or. !lExistOHT
				nTamFil   := TamSX3("NXA_FILIAL")[1]
				nTamEsc   := TamSX3("NXA_CESCR")[1]
				nTamFat   := TamSX3("NXA_COD")[1]
				cJurFat   := Strtran(SE1->E1_JURFAT, "-", "")
				cEscrit   := Substr(cJurFat, nTamFil+1, nTamEsc)
				cFatura   := Substr(cJurFat, nTamFil+nTamEsc+1, nTamFat)
			ElseIf lExistOHT
				aEscrFat := JurGetDados("OHT", 2, xFilial("OHT") + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM, {"OHT_FTESCR","OHT_CFATUR"})
				If Len(aEscrFat) >= 2
					cEscrit := aEscrFat[01]
					cFatura := aEscrFat[02]
				EndIf
			EndIf
			cParcela := IIf(lParcPos, SE1->E1_PARCELA, "")

			FWMsgRun(, {|| JurBoleto(cEscrit, cFatura, cResult, cParcela, lRelat) }, STR0066, STR0067) // "Processando" # "Gerando boleto aguarde..."
		EndIf
	EndIf

	RestArea( aAreaSE1 )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldBol
Validações para emissão de boleto via financeiro

@return  lVldBol, logico, Verdadeiro/Falso

@author  Jonatas Martins / Jorge Martins
@since   18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurVldBol()
Local cTpImposto := MVABATIM
Local lVldBol    := .F.
Local lExistOHT  := AliasInDic("OHT")

	Do Case
		Case SE1->( Eof() )
			JurMsgErro( STR0050, , STR0051 ) // "Título não entrado no banco de dados!" # "Contate o Administrador do sistema."

		Case SE1->E1_TIPO $ cTpImposto
			JurMsgErro( STR0065, , STR0053 ) // "Não é possível gerar boletos dos títulos de impostos!" # "Somente títulos de faturas podem gerar boletos."

		Case Empty(SE1->E1_JURFAT) .And. (!lExistOHT .Or. Empty(JurGetDados("OHT", 2, xFilial("OHT") + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "OHT_CFATUR")))
			JurMsgErro( STR0052, , STR0053 ) // "O título não está vinculado a fatura do SIGAPFS!" # "Somente títulos de faturas podem gerar boletos."

		Case SE1->E1_BOLETO <> '1'
			JurMsgErro( STR0054, , STR0055 ) // "O título não está configurado para geração de boleto!" # "Verifique o campo E1_BOLETO."

		Case SE1->E1_VALOR <> SE1->E1_SALDO
			 JurMsgErro( STR0063, , STR0064 ) // "O título possui movimentações!" # "Somente títulos sem movimentações podem gerar boletos."

		Case Empty(SE1->E1_PORTADO) .Or. Empty(SE1->E1_AGEDEP) .Or. Empty(SE1->E1_CONTA)
			JurMsgErro(STR0138, , STR0139) // "O título não possui dados bancários!" # "Verifique no título os dados de banco, agência e conta."

		OtherWise
			lVldBol := .T.
	EndCase

Return ( lVldBol )

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetResult
Monta tela para escolha do tipo de impressão do boleto

@return  cCbResult, carater, Tipo da impressão escolhida

@author  Jonatas Martins / Jorge Martins
@since   18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurGetResult()
	Local aResult    := {}
	Local cCbResult  := Space( 25 )
	Local aCbResult  := {}
	Local cCbParcela := STR0068 // "Somente atual"
	Local aCbParcela := {}
	Local oDlg       := Nil
	Local lCancel    := .T.

	aCbResult  := { STR0056, STR0057, STR0058 } // "Impressora, Tela, Nenhum"
	aCbParcela := { STR0068, STR0069 } // "Somente atual, Todas pendentes"

	DEFINE MSDIALOG oDlg TITLE STR0059 FROM 0,0 TO 100,252  PIXEL //"Tipo de Impressão"

	@ 005, 005 Say STR0060 Size 030,008 PIXEL OF oDlg //"Resultado:"
	@ 015, 005 ComboBox cCbResult Items aCbResult Size 050, 012 Pixel Of oDlg

	@ 005, 065 Say STR0070 Size 030,008 PIXEL OF oDlg // "Parcela(s):"
	@ 015, 065 ComboBox cCbParcela Items aCbParcela Size 060, 012 Pixel Of oDlg

	@ 033, 044 Button STR0061 Size 037,012 PIXEL OF oDlg  Action  ( lCancel := .F., oDlg:End() )  //"Emitir"
	@ 033, 087 Button STR0062 Size 037,012 PIXEL OF oDlg  Action  ( lCancel := .T., oDlg:End() )  //"Cancelar"

	ACTIVATE MSDIALOG oDlg CENTERED

	If lCancel
		cCbResult  := ""
		cCbParcela := ""
	EndIf

	If !Empty( cCbResult )
		Do Case
			Case cCbResult == STR0056 // "Impressora"
				cCbResult := "1"

			Case cCbResult == STR0057 // "Tela"
				cCbResult := "2"

			OtherWise
				cCbResult := "3" // "Nenhum"
		EndCase
	EndIf

	If !Empty( cCbParcela )
		Do Case
			Case cCbParcela == STR0068 // "Somente atual"
				cCbParcela := "1"

			Case cCbParcela == STR0069 // "Todas pendentes"
				cCbParcela := "2"

		EndCase
	EndIf

	aResult := {cCbResult, cCbParcela}

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JAVLESCRIT
Valida o escritório para relacionar ao banco em MATA070 (OHK)

@author  Bruno Ritter
@since   24/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAVLESCRIT(cEscrit, lValBloq, lValFat)
Local aRetNS7    := {}
Local lRet       := .T.

Default lValBloq := .T.
Default lValFat  := .T.

aRetNS7 := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, {"NS7_ATIVO", "NS7_EMITEF"})

If Empty(aRetNS7)
	lRet := JurMsgErro(STR0071,, STR0072) //#"O código do escritório não é válido." ## "Selecione um escritório válido."
EndIf

If lRet .And. aRetNS7[1] == "2" .And. lValBloq
	lRet := JurMsgErro(STR0073,, STR0072) // "O escritório selecionado não está ativo." ## "Selecione um escritório válido."
EndIf

If lRet .And. aRetNS7[2] == "2" .And. lValFat
	lRet := JurMsgErro(STR0074,, STR0072) // "O escritório selecionado não emite fatura." ## "Selecione um escritório válido."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JATdOkOHK
Pós valid da linha do modelo OHK "Bancos x Escritório"

@author  Bruno Ritter
@since   24/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JATdOkOHK(oGrid)
Local lRet := .T.

	If Empty( oGrid:GetValue("OHK_CESCRI") )
		lRet := JurMsgErro(STR0075,, STR0076) //"O código do Escritório é obrigatório" "Informe o código do Escritório."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIncTitCP
Realiza as operações referente ao módulo SIGAPFS logo após a inclusão
dos títulos do contas a pagar no financeiro.

@param  nSE1Recno, numerico, Recno do registro SE1

Uso nas funções F050AtuPFS (FINA050) - Operações da Integração SIGAPFS x SIGAFIN
                Fa381GrvE2 (FINA381) - Gera o novo título de imposto com o valor aglutinado (Aglutinação IR e PCC)
                FA376GrvE2 (FINA376) - Gera o novo título de imposto com o valor aglutinado (Aglutinação IR)

@author Bruno Ritter
@since 25/04/2018
/*/
//-------------------------------------------------------------------
Function JIncTitCP( nSE2Recno, nRecSE5 )
Local aArea       := GetArea()
Local lRet        := .T.
Local lIntPFS     := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cTipoCP     := ""
Local lAglutImp   := FwIsInCallStack("FA376GRVE2") .Or. FwIsInCallStack("FA378GRVE2") .Or. FwIsInCallStack("Fa381GrvE2")

Default nSE2Recno := 0

If lIntPFS

	SE2->(DbGoTo(nSE2Recno))
	cTipoCP := SE2->E2_TIPO

	If FindFunction("J246AtuOHF") .And. JVldTipoCp(cTipoCP, .F.)
		lRet := J246AtuOHF(.T., nSE2Recno)
	EndIf

	If FindFunction("J246IncOHF") .And. (cTipoCP $ JTipoTitImp())
		lRet := J246IncOHF(nSE2Recno,"TX")
	EndIf

	If FindFunction("J246IncOHF") .And. cTipoCP $ MVPAGANT
		lRet := J246IncOHF(nSE2Recno,"PA")
	EndIf

	If lRet .And. !lAglutImp .And. FindFunction("J241InsAD");
	   .And. (mv_par09 == 1; // Gera movimento sem cheque == Sim
	   .Or. mv_par05 == 1) // Gera Chq. para Adiantamento == Sim

		lRet := J241InsAD(, nSE2Recno, nRecSE5)
	EndIf

	JCriaCalend(SE2->E2_VENCTO) // Cria período no Calendário Contábil quando não existir

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JDesdFilho
Realiza as operações referente ao módulo SIGAPFS logo após a inclusão/alteração
ou exclusão de filhos dos títulos do contas a pagar no financeiro.

@param  nSE2Recno, numerico, Recno do registro SE2.

Uso nas funções F050AtuPFS (FINA050) - Operações da Integração SIGAPFS x SIGAFIN
                FGrvImpPcc (MATXATU) - Gravacao dos titulos de impostos de PCC na baixa do título
                F340GrvImp (FINA340) - Gravacao dos titulos de impostos de PCC na compensação

@author Luciano Pereira dos Santos / Anderson Carvalho
@since 25/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JDesdFilho(nOper, nSE2RecPai, aRecImpos)
Local aArea        := GetArea()
Local aAreaSE2     := SE2->(GetArea())
Local lRet         := .T.
Local nI           := 0
Local lIntPFS      := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

Default nOper      := 0
Default nSE2RecPai := 0
Default aRecImpos  := JRecFilho(nSE2RecPai)

If lIntPFS .And. nOper > 0
	For nI := 1 To Len(aRecImpos)
		Do Case
			Case nOper == 3
				lRet := J246IncOHF(aRecImpos[nI][2], "TX")
			Case nOper == 4
				lRet := J246IncOHF(aRecImpos[nI][2], "TX")
			Case nOper == 5
				lRet := JDelTitCP(aRecImpos[nI][2])
		EndCase
		If !lRet
			Exit
		EndIf
	Next

	lRet := IIF(lRet .And. nOper == 4, JVldNat290(SE2->E2_NATUREZ, .F., "FINXFIN"), lRet) // Valida alteração da Natureza no CP
EndIf

RestArea(aAreaSE2)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRecFilho
Retorna um array com os titulos filhos do contas a pagar no financeiro.

@param  nSE2RecPai       Recno do registro do titulo pai da SE2.
@param  cSeqSE5          Sequência da baixa da SE5.
@Return aRecImpos[n][1]  Tabela "SE2" (Compatibilidade)
        aRecImpos[n][2]  Recno do titulo filho

@author Jorge Martins
@since 06/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRecFilho(nSE2RecPai, cSeqSE5)
Local aArea        := GetArea()
Local aAreaSE2     := SE2->(GetArea())
Local cChavePai    := ""
Local aRecImpos    := {}

Default nSE2RecPai := 0
Default cSeqSE5    := SE5->E5_SEQ

If nSE2RecPai > 0
	SE2->(DbGoTo(nSE2RecPai))
	cChavePai   := SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA

	SE2->(DbSetOrder(17)) //E2_FILIAL + E2_TITPAI
	If (SE2->(Dbseek(cChavePai)))
		While SE2->(!EOF()) .And. Alltrim(SE2->E2_FILIAL + SE2->E2_TITPAI) == Alltrim(cChavePai)
				AADD(aRecImpos, {"SE2", SE2->(Recno())})
			SE2->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea(aAreaSE2)
RestArea(aArea)

Return aRecImpos

//-------------------------------------------------------------------
/*/{Protheus.doc} JAltTitCP
Realiza as operações referente ao módulo SIGAPFS logo após a alteração
dos títulos do contas a pagar no financeiro.

@param  nSE2Recno, numerico, Recno do registro SE2

Uso na função F050AtuPFS (FINA050) - Operações da Integração SIGAPFS x SIGAFIN

@author Bruno Ritter
@since 25/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JAltTitCP( nSE2Recno )
Local aArea       := GetArea()
Local lRet        := .T.
Local lIntPFS     := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cTipoCP     := ""

Default nSE2Recno := 0

If lIntPFS

	SE2->(DbGoTo(nSE2Recno))
	cTipoCP := SE2->E2_TIPO

	If FindFunction("J246AtuOHF") .And. JVldTipoCp(cTipoCP, .F.)
		lRet := J246AtuOHF(.F., nSE2Recno)
	EndIf

	If FindFunction("J246IncOHF") .And. (cTipoCP $ JTipoTitImp())
		lRet := J246IncOHF(nSE2Recno, "TX")
	EndIf

	JCriaCalend(SE2->E2_VENCTO) // Cria período no Calendário Contábil quando não existir

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JDelTitCP
Realiza as operações referente ao módulo SIGAPFS logo após a exclusão
dos títulos do contas a pagar no financeiro.

@param  nSE2Recno, Recno do registro SE2

Uso nas funções F050AtuPFS (FINA050) - Operações da Integração SIGAPFS x SIGAFIN
                FA050AxAlt (FINA050) - Exclusão de títulos de impostos
                FA080Can   (FINA080) - Exclusão de títulos de impostos no cancelamento da baixa
                FDelTxBx   (FINA080) - Exclusão de títulos de impostos no cancelamento da baixa
                fa381Can   (FINA381) - Cancela o titulo gerado pela aglutinação de impostos

@author Bruno Ritter
@since 25/04/2018
/*/
//-------------------------------------------------------------------
Function JDelTitCP(nSE2Recno)
Local aArea      := GetArea()
Local lRet       := .T.
Local lIntPFS    := SuperGetMV("MV_JURXFIN",,.F.) // Integração SIGAPFS x SIGAFIN

If lIntPFS
	SE2->(DbGoTo(nSE2Recno))

	If FindFunction("J246DelOHF")
		lRet := J246DelOHF(nSE2Recno) //Deleta o desdobramento.
		If lRet .And. SE2->E2_TIPO $ MVPAGANT //Executa apenas quando for PA
			lRet := J241DelLan(, , , nSE2Recno) //Deleta lançamento gerado pelo PA
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JExitLanc
Verifica se existe o Lançamento na alteração da natureza

@author Nivia Ferreira
@since 03/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JExitLanc()
Local aArea      := GetArea()
Local lRet       := .T.

cQuery :=  " SELECT COUNT(OHB.R_E_C_N_O_) RECNO"
cQuery +=  " FROM " + RetSqlName("OHB") + " OHB "
cQuery +=     " WHERE OHB_FILIAL= '" + xFilial("OHB") + "'"
cQuery +=     " AND D_E_L_E_T_ = ' '"
cQuery +=     " AND (OHB_NATORI = '" + SED->ED_CODIGO  + "' OR OHB_NATDES = '" + SED->ED_CODIGO + "')"

cQryRes := GetNextAlias()
cQuery  := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

lRet     := ((cQryRes)->RECNO == 0)
(cQryRes)->( dbcloseArea() )

RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JInTtsSED(oModel)
Método que é chamado pelo MVC da SED - FINA110 quando ocorrer as ações do commit após as gravações, porém antes do final da transação.

@param  oModel, Model da SED

@author Bruno Ritter
@since 25/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JInTtsSED(oModel)

	JFILASINC(oModel:GetModel(), "SED", "SEDMASTER", "ED_CODIGO") // Grava na fila de sincronização - Integração LegalDesk SIGAPFS

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JFiltPrj()
Filtro para as consultas padrão OHM de Itens de Projeto/Finalidade.

@Return cRet      Comando para filtro

@author Cristina Cintra
@since 25/06/2018
/*/
//-------------------------------------------------------------------
Function JFiltPrj()
Local cRet       := "@#@#"
Local lHasPrjDes := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))

If IsInCallStack('J246DIALOG') .Or. IsInCallStack('J281Dialog')
	cRet := "@#OHM->OHM_CPROJE == '" + J246RetPrj() + "'@#"

ElseIf IsInCallStack('JURA246')
	cRet := "@#OHM->OHM_CPROJE == '" + FwFldGet("OHF_CPROJE") + "'@#"

ElseIf IsInCallStack('JURA247')
	cRet := "@#OHM->OHM_CPROJE == '" + FWFldGet("OHG_CPROJE") + "'@#"

ElseIf IsInCallStack('JURA281')
	cRet := "@#OHM->OHM_CPROJE == '" + FWFldGet("OHV_CPROJE") + "'@#"

ElseIf IsInCallStack('JURA235C') // Sempre manter antes da JURA235 e JURA235A
	cRet := "@#OHM->OHM_CPROJE == '" + J235CGetPrj() + "'@#"

ElseIf IsInCallStack('JURA235') .Or. IsInCallStack('JURA235A')
	cRet := "@#OHM->OHM_CPROJE == '" + FWFldGet("NZQ_CPROJE") + "'@#"

ElseIf IsInCallStack('JURAPAD034')
	cRet := "@#OHM->OHM_CPROJE == '" + MV_PAR09 + "'@#"

ElseIf IsInCallStack('JURA241')
	If "OHB_CITPRJ" $ ReadVar()
		cRet := "@#OHM->OHM_CPROJE == '" + FWFldGet("OHB_CPROJE") + "'@#"
	Else
		cRet := "@#OHM->OHM_CPROJE == '" + FWFldGet(Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE")) + "'@#"
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCalend()
Efetua as validações de mês fechado e de lacunas no Calendário Contábil
quando ligada a integração entre o SIGAPFS e o SIGAFIN.

@Param   aCols      Informações do Calendário Contábil para validação

@Return  lRet       Retorna se as informações são válidas ou não

@author Cristina Cintra
@since 11/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldCalend(aCols)
Local aArea     := GetArea()
Local lRet      := .T.
Local nCont     := 0
Local nLenCols  := Len(aCols)
Local nMesIni   := 0
Local nMesFin   := 0
Local nDiaIni   := 0
Local nDiaFin   := 0
Local cStatus   := ""
Local lIntPFS   := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

If lIntPFS

For nCont := 1 To nLenCols
	nMesIni := Month(aCols[nCont][nPosDtIni])
	nDiaIni := Day(aCols[nCont][nPosDtIni])
	nMesFin := Month(aCols[nCont][nPosDtFim])
	nDiaFin := Day(aCols[nCont][nPosDtFim])
	cStatus := aCols[nCont][nPosStatus]

	// Valida mês fechado
	If ( nMesIni <> nMesFin ) .Or. ( nDiaIni <> Day(FirstDay(aCols[nCont][nPosDtIni])) ) .Or. ( nDiaFin <> Day(LastDay(aCols[nCont][nPosDtFim])) )
		lRet := JurMsgErro(STR0077,, STR0078) // "Quando o parâmetro de integração entre SIGAPFS e SIGAFIN estiver ativado (MV_JURXFIN), será permitida a utilização apenas do tipo mensal, com meses fechados." # "Ajuste os períodos usando apenas meses fechados."
		Exit
	EndIf
Next nCont

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCriaCalend()
Verifica a existência de período em Calendário Contábil para a data
informada e, caso não exista, efetua a criação.

@Param   dData      Data a ser usada na busca e criação de período contábil

@Return  Nil

@author Cristina Cintra
@since 12/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCriaCalend(dData)
Local aArea        := GetArea()
Local cTbl         := "" 
Local cCalend      := ""
Local cQry         := ""
Local cQryCTE      := ""
Local cPeriodo     := ""
Local cExerc       := Alltrim(Str(Year(dData)))
Local nOpc         := 0
Local nCont        := 0
Local nMesIni      := 0
Local nMesData     := 0
Local dDataPer     := Nil
Local dFirstDay    := Nil
Local dLastDay     := Nil
Local cAlsCTE      := Nil
Local cMoeNac      := SuperGetMv('MV_JMOENAC',, '01')

Private aCols      := {}
Private nPosDtIni  := 0
Private nPosDtFim  := 0
Private nPosStatus := 0
Private nUsado     := 0
Private aHeader[0]

cQry := " SELECT CTG.CTG_CALEND "
cQry +=   " FROM " + RetSqlName("CTG") + " CTG "
cQry +=     " INNER JOIN " + RetSqlName('CTE') + " CTE "
cQry +=        " ON ( CTE.CTE_FILIAL = CTG.CTG_FILIAL AND "
cQry +=             " CTE.CTE_CALEND = CTG.CTG_CALEND AND "
cQry +=             " CTE.CTE_MOEDA  = '" + cMoeNac + "' AND "
cQry +=             " CTE.D_E_L_E_T_ = ' ' "
cQry +=           " ) "
cQry += " WHERE CTG.CTG_DTINI <= '" + DToS(dData) + "'"
cQry +=   " AND CTG.CTG_DTFIM >= '" + DToS(dData) + "'"
cQry +=   " AND CTG.CTG_FILIAL = '" + xFilial("CTG") + "'"
cQry += " AND CTG.D_E_L_E_T_ = ' '"

cTbl := GetNextAlias()
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), cTbl, .T., .T.)

If (cTbl)->(EOF())
	CTG->(DbsetOrder(4)) // CTG_FILIAL+CTG_EXERC+CTG_PERIOD
	If CTG->(DbSeek(xFilial('CTG') + cExerc ))
		While !CTG->(EOF()) .And. CTG->CTG_EXERC == cExerc
			If !Empty(JurGetDados("CTE", 1, xFilial("CTE") + cMoeNac + CTG->CTG_CALEND, "CTE_CALEND"))
		 		nOpc    := 4
				cCalend := CTG->CTG_CALEND
				Exit
			EndIf
			CTG->(DbSkip())
		EndDo
	Else
		nOpc := 3
		cCalend := JNextCod("CTG", "CTG_CALEND")
	EndIf

	If nOpc > 0

		CTB010Ahead()
		Ctb010Acols(nOpc, cExerc, cCalend)

		If nOpc == 3 // Em uma inclusão de calendário, inicia com o mês 1
			nMesIni := 1
		Else // Em uma alteração de calendário, inicia com o mês posterior ao último que existe no calendário
			nMesIni := Len(aCols) + 1
		EndIf

		nMesData := Month(dData) // Mês da data do lançamento

		For nCont := nMesIni To nMesData

			If nCont > 1
				AADD(aCols, Array(nUsado+1))
			EndIf

			cPeriodo  := StrZero(nCont, 2) // Mês em que será incluído o período
			dDataPer  := CTOD("01/" + cPeriodo + '/'+ cExerc) // Data completa desse período
			dFirstDay := FirstDay(dDataPer) // Primeiro dia do mês do período
			dLastDay  := LastDay(dDataPer)  // Último dia do mês do período

			aCols[nCont][1]          := cPeriodo
			aCols[nCont][nPosDtIni]  := dFirstDay
			aCols[nCont][nPosDtFim]  := dLastDay
			aCols[nCont][nPosStatus] := "1"
			aCols[nCont][nUsado+1]   := .F.
		Next

		Ctb010Grava(nOpc, cExerc, cCalend)

		// Carga da tabela de Processos - CQD
		cQryCTE := " SELECT CTE_MOEDA FROM " + RetSqlName("CTE") + " CTE "
		cQryCTE +=  " WHERE CTE_FILIAL = '" + FWXFilial("CTE") + "' "
		cQryCTE +=    " AND CTE_CALEND = '" + cCalend  + "' "
		cQryCTE +=    " AND CTE_MOEDA = '" + cMoeNac  + "' "
		cQryCTE +=    " AND CTE.D_E_L_E_T_ = ' '"

		cQryCTE := ChangeQuery( cQryCTE )
		cAlsCTE := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TcGenQry(,, cQryCTE), cAlsCTE, .T., .F.)

		If (cAlsCTE)->(!Eof())
			// Executa carga da CQD logo após a inclusão do calendário / período
			CT012LOAD()
		EndIf

		(cAlsCTE)->(DbCloseArea())

	EndIf

EndIf

(cTbl)->(DbCloseArea())

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JSX7Natur
Condição do gatilho que limpa os campos após o preenchimento da
natureza nas telas de desdobramento e desdobramento pós pagamento

@Return lRet      Indica se deve executar o gatilho

@author Jorge Martins
@since  12/07/2018
/*/
//-------------------------------------------------------------------
Function JSX7Natur()
	Local oModel    := FwModelActive()
	Local oModelDes := Nil
	Local cIdModel  := ""
	Local cTable    := ""
	Local cNatAtu   := ""
	Local cTpNatAtu := ""
	Local nRecLine  := ""
	Local cNatOld   := ""
	Local cTpNatOld := ""
	Local lRet      := .T.

	If ValType( oModel ) == "O"
		cIdModel  := oModel:GetID()

		If cIdModel $ "JURA246|JURA247|JURA281"
			cTable    := IIF(cIdModel == "JURA246", "OHF", IIF(cIdModel == "JURA247", "OHG", "OHV"))
			oModelDes := oModel:GetModel(cTable + "DETAIL")
			cNatAtu   := oModelDes:GetValue(cTable + "_CNATUR")
			cTpNatAtu := JurGetDados("SED", 1, xFilial("SED") + cNatAtu, "ED_CCJURI")
			nRecLine  := oModelDes:GetDataID()
			cNatOld   := JOldNatDes(cTable, nRecLine)
			cTpNatOld := JurGetDados("SED", 1, xFilial("SED") + cNatOld, "ED_CCJURI")
		EndIf

		lRet := cTpNatAtu <> cTpNatOld
	EndIf
	
Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} JOldNatDes()
Obtem a natureza do desdobramento antes da alteração

@param  cTable   , caractere, Tabela de desdobramento
@param  nRecno   , numerico , Recno do registro na tabela OHF ou OHV
@Return cOldNatur, caractere, Natureza antes da alteração

@author  Jonatas Martins
@since   19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JOldNatDes(cTable, nRecno)
	Local aAreaTab  := (cTable)->(GetArea())
	Local cField    := ""
	Local cOldNatur := ""

	(cTable)->( DbGoTo( nRecno ) )
	If (cTable)->( ! Eof() )
		cField    := cTable + "_CNATUR"
		cOldNatur := (cTable)->(FieldGet(FieldPos(cField)))
	EndIf

	RestArea(aAreaTab)
	
Return (cOldNatur)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurValidCP()
Validação do Tudo Ok do contas a pagar FINA050

@Return lRet, lógico, Se o contas a pagar está valido.

@author Bruno Ritter
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurValidCP(nOpc)
Local aArea      := GetArea()
Local aError     := {}
Local lRet       := .T.
Local lExibeErro := .F.
Local lDetail    := .F.
Local lTransit   := .F.
Local cNatPosPag := ""
Local cRetTit    := ""
Local cBxTPosPag := ""
Local cNatSE2    := M->E2_NATUREZ
Local cNatOld    := SE2->E2_NATUREZ
Local nValSE2    := M->E2_VALOR
Local nValOld    := SE2->E2_VALOR
Local cFilTit    := SE2->E2_FILIAL
Local cTitPai    := SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
Local cTipoSE2   := AllTrim(M->E2_TIPO)
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cTipoImp   := AllTrim(SuperGetMV("MV_TIPIMP",, ""))
Local cTitTpCta  := ""
Local cBoxTpCta  := ""
Local cTitCCJuri := ""
Local lExecAF050 := Type("lF050Auto") == "U" .Or. ( Type("lF050Auto") == "L" .And. !lF050Auto ) // Quando for ExecAuto não devem ser validados os desdobramentos 

If lIntPFS .And. (nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE) .And. lExecAF050
	lTransit   := JurGetDados("SED", 1, xFilial("SED") + cNatSE2, "ED_CCJURI") == "7" // Natureza transitória
	
	cNatPosPag := JurBusNat("6") // Natureza Transitória Pós Pagamento

	If cNatSE2 == cNatPosPag
		cBxTPosPag := JurInfBox("ED_CCJURI", "6", "3")
		lRet       := JurMsgErro(I18N(STR0103, {'"' + cNatSE2 + '"'}), , I18n(STR0104, {'"' + cBxTPosPag + '"'})) // "Natureza #1 inválida!" # "Não é permitido utilizar uma natureza com tipo #1."
	EndIf

	If lRet .And. M->E2_TIPO == MVPAGANT  // Tipo == PA
		If !lTransit
			cRetTit := AllTrim(RetTitle("E2_NATUREZ"))
			lRet    := JurMsgErro(STR0093, , i18n(STR0092, {cRetTit})) // "A natureza selecionada no título deve ser uma transitória de pagamento para um pagamento adiantado." / "No campo '#1' selecione uma natureza cujo centro de custo jurídico é 'transitória de pagamento'."
		EndIf
	EndIf

	If lRet .And. !JurValNat(, "1", cNatSE2, , "8", @aError, lExibeErro)
		lRet := JurMsgErro(i18n(STR0091, {cNatSE2}) + ; // "Natureza '#1' está inválida."
		                   CRLF + CRLF + STR0089 + CRLF + ; // "Detalhes:"
		                   aError[1], , aError[2], lDetail)
	EndIf

	// Validação da natureza para títulos de impostos
	If lRet .And. cTipoSE2 $ cTipoImp
		If SED->ED_TPCOJR <> "6" // 6 - Obrigações
			cTitTpCta  := AllTrim(RetTitle("ED_TPCOJR"))
			cBoxTpCta  := JurInfBox("ED_TPCOJR", "6", "3")
			lRet       := JurMsgErro(I18N(STR0101, {'"' + cNatSE2 + '"'}),, I18N(STR0102, {'"' + cTitTpCta + '"', '"' + cBoxTpCta + '"'})) // "Valor inválido na natureza #1!" # "Altere o campo #1 para #2."
		ElseIf ! Empty(SED->ED_CCJURI)
			cBoxTpCta  := JurInfBox("ED_TPCOJR", "6", "3")
			cTitCCJuri := AllTrim(RetTitle("ED_CCJURI"))
			lRet       := JurMsgErro(I18N(STR0099, {'"' + cBoxTpCta + '"'}),, I18N(STR0100, {'"' + cTitCCJuri + '"', '"' + cNatSE2 + '"'})) // "Naturezas com tipo conta #1 não devem conter centro de custo jurídico!" # "Limpe o conteúdo do campo #1 da natureza #2."
		EndIf
	EndIf

	// Valida se o título possui desdobramentos pós pagamento na alteração da natureza
	If lRet .And. nOpc == MODEL_OPERATION_UPDATE .And. !lTransit
		If JurGetOHG() // Verifica se existe desdobramento pós pagamento
			lRet := JurMsgErro(STR0116, , STR0117, .F.) //#"Não é possivel alterar a natureza do título." ##"Existem desdobramentos pós pagamento que impendem a alteração da natureza."
		EndIf
	EndIf

	// Valida se o título possui desdobramentos contabilizados na alteração da natureza
	If lRet .And. nOpc == MODEL_OPERATION_UPDATE .And. OHG->(ColumnPos("OHG_DTCONT")) > 0
		If cNatSE2 <> cNatOld .And. (JurGetOHF(.T.) .Or. JurGetOHG(.T.))
			lRet := JurMsgErro(STR0116, , STR0118, .F.) //#"Não é possivel alterar a natureza do título."  ##"Existem desdobramentos contabilizados que impendem a alteração da natureza."
		EndIf
	EndIf
EndIf

// Valida se existem títulos de impostos com baixa ou aglutinação para não permitir alteração de natureza e valor do título principal
// Essa função só é necessária até a liberação da issue DSFIN-2216
If lIntPFS .And. lRet .And. nOpc == MODEL_OPERATION_UPDATE .And. !(cTipoSE2 $ cTipoImp)
	lRet := JVldBxImp(cFilTit, cTitPai, cTipoImp, cNatSE2 <> cNatOld, nValSE2 <> nValOld)
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------
/*/ JurBnkNat
Valida a natureza do banco selecionando quando integração
SIGAPFS x SIGAFIN está ativa antes de gerar um lançamento.

@param cBanco  , Código do banco selecionado
@param cAgencia, Agência do banco selecionado
@param cNumCon , Conta do banco selecionado

@author  Bruno Ritter
@since   25/07/2018
/*/
//-------------------------------------------------------
Function JurBnkNat(cBanco, cAgencia, cNumCon)
Local lRet       := .T.
Local aArea      := {}
Local aError     := {}
Local cQAlias    := ""
Local cQuery     := ""
Local cNatur     := ""
Local lExibeErro := .F.
Local lDetail    := .F.

	If !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cNumCon)

		aArea   := GetArea()
		cQAlias := GetNextAlias()

		cQuery  := " SELECT SED.ED_CODIGO "
		cQuery  +=  " FROM " + RetSqlName("SED") + " SED "
		cQuery  += " WHERE SED.D_E_L_E_T_ = ' '"
		cQuery  +=   " AND SED.ED_FILIAL = '" + xFilial( "SED" ) + "'"
		cQuery  +=   " AND SED.ED_CBANCO = '" + cBanco + "'"
		cQuery  +=   " AND SED.ED_CAGENC = '" + cAgencia + "'"
		cQuery  +=   " AND SED.ED_CCONTA = '" + cNumCon + "'"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQAlias, .T., .T.)

		If ( (cQAlias)->( EOF() ))
			lRet := JurMsgErro(STR0086,, STR0087, lDetail) // "Não existe natureza vinculada para esse banco." "Informe um banco valido ou inclua uma natureza para o banco selecionado."
		Else
			cNatur := (cQAlias)->ED_CODIGO
			lRet := JurValNat(, , cNatur, , , @aError, lExibeErro)

			If !lRet
				JurMsgErro(STR0088+CRLF+CRLF+; // "Natureza vinculada ao banco está inválida."
						STR0089+CRLF+; // "Detalhes:"
						aError[1],, aError[2], lDetail)
			EndIf
		EndIf

		(cQAlias)->( dbcloseArea() )
		RestArea(aArea)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldProc()
Validações de Processos (CQD) nos períodos do Calendário Contábil
quando ligada a integração entre o SIGAPFS e o SIGAFIN.

Uso na função Ctb012Pos (CTBA012) - Validação de linha CQDDETAIL
da rotina de Calendário Contábil

@Param   oModel     Modelo de Bloqueio de Processo para validação

@Return  lRet       Retorna se as informações são válidas

@author Jorge Martins
@since 17/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldProc(oModel)
Local aArea      := GetArea()
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lRet       := .T.
Local oModelCTG  := oModel:GetModel("CTGDETAIL")
Local oModelCQD  := oModel:GetModel("CQDDETAIL")
Local nQtdCTG    := oModelCTG:GetQtdLine()
Local cDataIni   := DToS(oModelCTG:GetValue("CTG_DTINI", 1))
Local cDataFim   := DToS(oModelCTG:GetValue("CTG_DTFIM", nQtdCTG))
Local cPeriodo   := AllTrim(oModelCTG:GetValue("CTG_PERIOD"))
Local cStatus    := AllTrim(oModelCQD:GetValue("CQD_STATUS"))
Local cProcesso  := AllTrim(oModelCQD:GetValue("CQD_PROC"  ))
Local cProblema  := ""
Local cSolucao   := ""

If lIntPFS .And. cProcesso $ "FIN001|FIN002|PFS001"

	oModelCTG  := oModel:GetModel("CTGDETAIL")
	oModelCQD  := oModel:GetModel("CQDDETAIL")
	nQtdCTG    := oModelCTG:GetQtdLine()
	cDataIni   := DToS(oModelCTG:GetValue("CTG_DTINI", 1))
	cDataFim   := DToS(oModelCTG:GetValue("CTG_DTFIM", nQtdCTG))
	cPeriodo   := AllTrim(oModelCTG:GetValue("CTG_PERIOD"))
	cStatus    := AllTrim(oModelCQD:GetValue("CQD_STATUS"))
	cProcesso  := AllTrim(oModelCQD:GetValue("CQD_PROC"  ))

	If cStatus == "5" // Bloqueio por período
		cProblema := I18N(STR0094, {cProcesso}) + CRLF + CRLF + ; // "Não é possível utilizar o status de bloqueio por período para processo '#1'."
		             STR0095 // "Quando o parâmetro de integração entre SIGAPFS e SIGAFIN estiver ativado (MV_JURXFIN), não será permitido usar o bloqueio por período para este processo."
		cSolucao  := STR0096 // "Verifique o status do processo."

		lRet      := JurMsgErro(cProblema, , cSolucao)
	EndIf

	// Valida calendário atual
	If lRet
		lRet := JVldCQDAtu(oModel)
	EndIf

	// Valida calendários passados ou futuros
	If lRet
		If ! (lRet := JVldCQDQry(cStatus, cProcesso, cDataIni, cDataFim))
			If cStatus == "1"
				cProblema := I18N(STR0079,{cProcesso,cPeriodo}) + CRLF + CRLF + ; // "Não é possível alterar o status do processo '#1' para o período '#2'."
				             STR0080 // "Quando o parâmetro de integração entre SIGAPFS e SIGAFIN estiver ativado (MV_JURXFIN), não será permitida a abertura do processo para esse período quando o mesmo estiver bloqueado em períodos posteriores."
				cSolucao  := STR0081 // "Verifique o status do processo nos períodos posteriores."
			Else
				cProblema := I18N(STR0079,{cProcesso,cPeriodo}) + CRLF + CRLF + ; // "Não é possível alterar o status do processo '#1' para o período '#2'."
				             STR0082 // "Quando o parâmetro de integração entre SIGAPFS e SIGAFIN estiver ativado (MV_JURXFIN), não será permitido o bloqueio do processo para esse período quando o mesmo estiver aberto em períodos anteriores."
				cSolucao  := STR0083 // "Verifique o status do processo nos períodos anteriores."
			EndIf

			JurMsgErro(cProblema, , cSolucao)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCQDAtu()
Valida processos (CQD) em períodos do calendário atual

Uso na validação de linha CQDDETAIL da rotina de Calendário
Contábil - CTBA010

@Param  oModel     Modelo de Bloqueio de Processo para validação

@return lRet       Indica se o Status do Processo pode ser alterado
                   para o período indicado

@author Jorge Martins
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVldCQDAtu(oModel)
Local lRet       := .T.
Local aSaveLines := FWSaveRows()
Local oModelCTG  := oModel:GetModel("CTGDETAIL")
Local oModelCQD  := oModel:GetModel("CQDDETAIL")
Local nQtdCTG    := oModelCTG:GetQtdLine()
Local nLineCTG   := oModelCTG:GetLine()
Local nLineCQD   := oModelCQD:GetLine()
Local cStatus    := oModelCQD:GetValue("CQD_STATUS", nLineCQD)
Local cPeriodo   := AllTrim(oModelCTG:GetValue("CTG_PERIOD", nLineCTG))
Local cProcesso  := AllTrim(oModelCQD:GetValue("CQD_PROC", nLineCQD))
Local cProblema  := ""

// Valida calendário atual
If nLineCTG > 1 .And. cStatus != "1" // Validação de fechamento de período para processo

	oModelCTG:GoLine(nLineCTG-1)

	If AllTrim(oModelCQD:GetValue("CQD_STATUS", nLineCQD)) == "1"
		cProblema := I18N(STR0079,{cProcesso, cPeriodo}) + CRLF + CRLF + ; // "Não é possível alterar o status do processo '#1' para o período '#2'."
		             STR0082 // "Quando o parâmetro de integração entre SIGAPFS e SIGAFIN estiver ativado (MV_JURXFIN), não será permitido o bloqueio do processo para esse período quando o mesmo estiver aberto em períodos anteriores."
		lRet      := JurMsgErro(cProblema, , STR0083) // "Verifique o status do processo nos períodos anteriores."
	Else
		oModelCTG:GoLine(nLineCTG)
	EndIf

ElseIf nLineCTG + 1 <= nQtdCTG .And. cStatus == "1" // Validação de abertura de período para processo

	oModelCTG:GoLine(nLineCTG+1)

	If AllTrim(oModelCQD:GetValue("CQD_STATUS", nLineCQD)) != "1"
		cProblema := I18N(STR0079, {cProcesso, cPeriodo}) + CRLF + CRLF + ; // "Não é possível alterar o status do processo '#1' para o período '#2'."
		             STR0080 // "Quando o parâmetro de integração entre SIGAPFS e SIGAFIN estiver ativado (MV_JURXFIN), não será permitida a abertura do processo para esse período quando o mesmo estiver bloqueado em períodos posteriores."
		lRet      := JurMsgErro(cProblema, , STR0081) // "Verifique o status do processo nos períodos posteriores."
	Else
		oModelCTG:GoLine(nLineCTG)
	EndIf

EndIf

FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCQDQry
Valida processos (CQD) em períodos de calendários passados ou futuros

Uso na validação de linha CQDDETAIL da rotina de Calendário
Contábil - CTBA010

@param cStatus    Status do Processo atual
@param cProcesso  Processo que será validado
@param cDataIni   Data inicial do período que está sendo alterado
@param cDataIni   Data final do período que está sendo alterado

@return lRet      Indica se o Status do Processo pode ser alterado
                  para o período indicado

@author Jorge Martins
@since  19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVldCQDQry(cStatus, cProcesso, cDataIni, cDataFim)
Local aArea    := GetArea()
Local lRet     := .T.
Local cMoeNac  := SuperGetMv('MV_JMOENAC',, '01') // Moeda Nacional
Local cQuery   := ''
Local cQryRes  := Nil

cQuery := " SELECT CQD.CQD_STATUS "
cQuery +=   " FROM " + RetSqlName('CQD') + " CQD "
cQuery +=     " INNER JOIN " + RetSqlName('CTE') + " CTE "
cQuery +=        " ON ( CTE.CTE_FILIAL = CQD.CQD_FILIAL AND "
cQuery +=             " CTE.CTE_CALEND = CQD.CQD_CALEND AND "
cQuery +=             " CTE.CTE_MOEDA  = '" + cMoeNac + "' AND "
cQuery +=             " CTE.D_E_L_E_T_ = ' ' "
cQuery +=           " ) "
cQuery +=     " INNER JOIN " + RetSqlName('CTG') + " CTG "
cQuery +=        " ON ( CTG.CTG_FILIAL = CQD.CQD_FILIAL AND "
cQuery +=             " CTG.CTG_PERIOD = CQD.CQD_PERIOD AND "
cQuery +=             " CTG.CTG_CALEND = CQD.CQD_CALEND AND "
If cStatus == "1"
	cQuery +=         " CTG.CTG_DTFIM  > '" + cDataFim + "' AND "
Else
	cQuery +=         " CTG.CTG_DTFIM  < '" + cDataIni + "' AND "
EndIf
cQuery +=             " CTG.D_E_L_E_T_ = ' ' "
cQuery +=           " ) "
cQuery += " WHERE CQD.CQD_FILIAL =  '" + xFilial("CQD") + "' AND "
cQuery +=       " CQD.CQD_PROC   =  '" + cProcesso + "' AND "
cQuery +=       " CQD.CQD_STATUS <> '" + cStatus + "' AND "
cQuery +=       " CQD.D_E_L_E_T_ = ' ' "

cQuery  := ChangeQuery(cQuery, .F.)
cQryRes := GetNextAlias()

DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery), cQryRes, .T., .F. )

lRet := (cQryRes)->(EOF())

(cQryRes)->(DbCloseArea())

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JSyncCQD()
Sincronização dos registros da tabela de bloqueio de processos do
calendário contábil (CQD).
Uso no Commit do Modelo de Bloqueio de Processos do calendário
contábil - CTBA012EVPFS (JurEvent)

@Param   oModel     Modelo de Bloqueio de Processo para validação

@Return  lRet       Retorna se as informações são válidas

@author Jorge Martins
@since 17/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JSyncCQD(oModel)
Local aArea      := GetArea()
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lFSinc     := SuperGetMV("MV_JFSINC", .F., '2') == "1" // Indica se utiliza a integração com o Legal Desk (SIGAPFS)
Local cCalend    := ""
Local cExerc     := ""
Local cPeriodo   := ""
Local cDataIni   := ""
Local cDataFim   := ""
Local cProcesso  := ""
Local cChave     := ""
Local cQuery     := ""
Local cOldStatus := ""
Local cNewStatus := ""
Local aLinCTG    := {}
Local aLinCQD    := {}
Local aSQL       := {}
Local nOpc       := 0
Local nCTG       := 0
Local nCQD       := 0
Local nI         := 0
Local oModelCTG  := Nil
Local oModelCQD  := Nil
Local lCQDRecalc := CQD->(ColumnPos("CQD_PFSREC")) > 0 //@12.1.35

If lIntPFS .And. lFSinc

	nOpc       := oModel:GetOperation()
	oModelCTG  := oModel:GetModel("CTGDETAIL")
	oModelCQD  := oModel:GetModel("CQDDETAIL")
	cCalend    := oModelCTG:GetValue("CTG_CALEND")
	cExerc     := oModelCTG:GetValue("CTG_EXERC")
	aLinCTG    := oModelCTG:GetLinesChanged()

	If nOpc == MODEL_OPERATION_UPDATE // Alteração

		For nCTG := 1 To Len(aLinCTG)

			oModelCTG:GoLine(aLinCTG[nCTG])

			cPeriodo   := oModelCTG:GetValue("CTG_PERIOD")
			cDataIni   := DToS(oModelCTG:GetValue("CTG_DTINI"))
			cDataFim   := DToS(oModelCTG:GetValue("CTG_DTFIM"))

			aLinCQD    := oModelCQD:GetLinesChanged()

			For nCQD := 1 To Len(aLinCQD)

				oModelCQD:GoLine(aLinCQD[nCQD])
				cProcesso  := AllTrim(oModelCQD:GetValue("CQD_PROC"))

				cOldStatus := JurGetDados('CQD', 1, xFilial('CQD') + cCalend + cExerc + cPeriodo + cProcesso, "CQD_STATUS")
				cNewStatus := AllTrim(oModelCQD:GetValue("CQD_STATUS"))

				If cOldStatus != cNewStatus
					If lCQDRecalc .And. cNewStatus == '1'
						oModel:SetValue('CQDDETAIL','CQD_PFSREC',"1")
					EndIf
					If cProcesso $ "FIN001|FIN002|PFS001"
						J170GRAVA("CQD", xFilial("CQD") + cCalend + cExerc + cPeriodo + cProcesso, "4")
					EndIf
				EndIf
			Next
		Next

	ElseIf nOpc == MODEL_OPERATION_DELETE // Exclusão

		cChave := oModelCTG:GetValue("CTG_FILIAL") + cCalend + cExerc

		cQuery := " SELECT NYS.NYS_CHAVE "
		cQuery +=   " FROM " + RetSqlName('NYS') + " NYS "
		cQuery +=  " WHERE NYS.NYS_FILIAL = '" + xFilial("NYS") + "' "
		cQuery +=    " AND NYS.NYS_MODELO = 'JURA253' "
		cQuery +=    " AND NYS.NYS_CHAVE LIKE ('" + cChave + "%') "
		cQuery +=    " AND NYS.D_E_L_E_T_ = ' ' "

		cQuery  := ChangeQuery(cQuery, .F.)

		aSQL := JurSQL(cQuery, {"NYS_CHAVE"})

		For nI := 1 To Len(aSQL)
			J170GRAVA("CQD", aSQL[nI][1], "5")
		Next nI

		// Adiciona uma linha na fila de sincronização indicando a exclusão do calendário, sem informar períodos ou processos.
		// Isso é feito para que seja registrada a exclusão de todos os processos do calendário,
		// mesmo os processos que não foram sincronizados na inclusão/alteração.
		J170GRAVA("CQD", cChave, "5")

	EndIf

EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JExcLinCTG()
Indica se as linhas da CTG podem ser excluídas durante uma
inclusão / alteração de calendário

Uso na função Ctb010Cal (CTBA010) - Inclusão/alteração de calendário

@Return  lDeleta    Retorna se as linhas poderão ser excluídas

@author Jorge Martins
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JExcLinCTG()
Local lDeleta := .T.
Local lIntPFS := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

If lIntPFS
	lDeleta := .F.
EndIf

Return lDeleta

//-------------------------------------------------------------------
/*/{Protheus.doc} JLoadCQD()
Realiza carga de processos do calendário contábil (CQD) após inclusão
do calendário via Wizard já com a amarração calendário x moeda (CTE)

Uso na função Ctb010Wiz (CTBA010) - Inclusão do calendário via Wizard

@param cCalendario  Calendário que foi incluído
@param cExercicio   Exercício do calendário

@author Jorge Martins
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JLoadCQD(cCalendario, cExercicio)
Local cQryCTE    := ""
Local cAlsCTE    := Nil
Local cMoeNacPFS := SuperGetMv('MV_JMOENAC',, '01') // Moeda Nacional - SIGAPFS
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

// Integração Jurídico - SIGAPFS x SIGAFIN
If lIntPFS
	cQryCTE := " SELECT CTE_MOEDA FROM " + RetSqlName("CTE") + " CTE " + CRLF
	cQryCTE +=  " WHERE CTE_FILIAL = '" + FWXFilial("CTE") + "' " + CRLF
	cQryCTE +=    " AND CTE_CALEND = '" + cCalendario  + "' " + CRLF
	cQryCTE +=    " AND CTE_MOEDA  = '" + cMoeNacPFS  + "' " + CRLF
	cQryCTE +=    " AND CTE.D_E_L_E_T_ = ''"

	cQryCTE := ChangeQuery( cQryCTE )
	cAlsCTE := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry(,, cQryCTE), cAlsCTE, .T., .F.)

	If (cAlsCTE)->(!Eof())
		CTG->(dbSetOrder(1)) //CTG_FILIAL+CTG_CALEND+CTG_EXERC
		CTG->(dbSeek(xFilial("CTG") + cCalendario + cExercicio))
		// Executa carga da CQD logo após a inclusão do calendário
		CT012LOAD()
	EndIf

	(cAlsCTE)->(DbCloseArea())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryCalLot()
Realiza um filtro na query de alteração de bloqueio de calendário
em lote para que os processos 'FIN001', 'FIN002' e 'PFS001' não sejam
afetados, caso a integração SIGAPFS x SIGAFIN estiver ativa.

Uso na função Ctb010Bloq (CTBA010) - Bloqueio do Calendário em Lote.

@Return  cQry   Filtro da Query de Bloqueio do Calendário em Lote.

@author Jorge Martins
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JQryCalLot()
Local lIntPFS := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cQry    := ""

If lIntPFS
	ApMsgAlert( STR0097, STR0098 ) // "O Bloqueio Automático não altera os processos 'FIN001', 'FIN002' e 'PFS001' devido a integração entre os módulos SIGAPFS e SIGAFIN (parâmetro MV_JURXFIN). Para alterar esses processos acesse a opção Bloqueio de Processo." - "Importante"
	cQry := " AND CQD.CQD_PROC NOT IN ('FIN001','FIN002','PFS001') " + CRLF
EndIf

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} JFtSyncCQD()
Filtra os processos do calendário contábil para sincronização com
Legal Desk.
Uso na função CT012LOAD (CTBA012) - Carga da tabela de Processos

@param cCalend    Calendário Contábil
@param cExerc     Exercício do Calendário
@param cPeriodo   Período do Calendário
@param cProcesso  Processo

@author Jorge Martins
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JFtSyncCQD(cCalend, cExerc, cPeriodo, cProcesso)
Local lIntPFS := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local lFSinc  := SuperGetMV("MV_JFSINC", .F., '2') == "1" // Indica se utiliza a integração com o Legal Desk (SIGAPFS)

If lIntPFS .And. lFSinc
	If cProcesso $ "FIN001|FIN002|PFS001" // Processos da integração
		J170GRAVA("CQD", xFilial("CQD") + cCalend + cExerc + cPeriodo + cProcesso, "3")
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCQDCTE()
Realiza carga de processos do calendário contábil (CQD) após inclusão
da amarração calendário x moeda (CTE)

Uso na função Ctb200Inc (CTBA200) - Inclusão de amarração
Moeda x Calendário

@param cCalend    Calendário Contábil
@param cMoeda     Moeda da amarração

@author Jorge Martins
@since 31/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCQDCTE(cCalend, cMoeda)
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cMoeNacPFS := SuperGetMv('MV_JMOENAC',, '01') // Moeda Nacional

Default cMoeda   := ""

If lIntPFS .And. cMoeda == cMoeNacPFS
	CTG->(dbSetOrder(1)) //CTG_FILIAL+CTG_CALEND+CTG_EXERC
	CTG->(dbSeek(xFilial("CTG") + cCalend))
	// Executa carga da CQD logo após a inclusão do vinculo calendário x moeda
	CT012LOAD()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCompSED(nRecnoSed)
Realiza complemento das informações da natureza referente a integração

Uso na função FGrvImpPcc (MATXATU)

@param nRecnoSED  Recno da tabela de Naturezas

@author Luciano Pereira dos Santos
@since 02/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurCompSED(nRecnoSED)
Local aArea      := GetArea()
Local lIntPFS    := SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
Local cMoeNacPFS := SuperGetMv('MV_JMOENAC',, '01') // Integração SIGAPFS x SIGAFIN - Moeda Nacional
Local lMoedaJur  := SED->(ColumnPos("ED_CMOEJUR")) > 0 // Integração SIGAPFS x SIGAFIN - Proteção

If lIntPFS .And. lMoedaJur
	SED->(DbGoTo(nRecnoSED))

	RecLock("SED",.F.)
	SED->ED_CMOEJUR := cMoeNacPFS
	SED->ED_MSBLQL  := "2"
	SED->ED_TPCOJR  := "6" // Obrigações
	SED->ED_CPJUR   := "1" // Contas a pagar Sim
	SED->ED_CRJUR   := "1" // Contas a Recber Sim
	SED->(MsUnlock())
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetOHF
Verifica se existem desdobramentos vinculados no título

@param  lVldCont, logico , Se .T. filtra desdobramentos contabilizados
@return lExistOHF, logico, Se .T. foram encontrados desdobramentos

@author  Jonatas Martins / Abner Fogaça
@since   06/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurGetOHF(lVldCont)
	Local cQueryOHF    := ""
	Local cDtCont      := Space(TamSx3('OHF_DTCONT')[1])
	Local cAlsOHF      := GetNextAlias()
	Local lExistOHF    := .F.

	Default lVldCont   := .F.

	cQueryOHF := " SELECT SE2.R_E_C_N_O_ SE2REC "
	cQueryOHF +=   " FROM " + RetSqlname('SE2') + " SE2 "
	cQueryOHF +=      " INNER JOIN " + RetSqlname('FK7') + " FK7 "
	cQueryOHF +=          " ON FK7.FK7_FILIAL = SE2.E2_FILIAL "
	cQueryOHF +=         " AND SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA = FK7.FK7_CHAVE "
	cQueryOHF +=         " AND FK7.D_E_L_E_T_ = ' ' "
	cQueryOHF +=      " INNER JOIN " + RetSqlname('OHF') + " OHF "
	cQueryOHF +=          " ON OHF.OHF_FILIAL = SE2.E2_FILIAL "
	cQueryOHF +=         " AND OHF.OHF_IDDOC = FK7.FK7_IDDOC "
	If lVldCont
		cQueryOHF +=         " AND OHF.OHF_DTCONT <> '" + cDtCont + "' "
	EndIf
	cQueryOHF +=         " AND OHF.D_E_L_E_T_ = ' ' "
	cQueryOHF +=  " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
	cQueryOHF +=         " AND SE2.E2_PREFIXO = '" + M->E2_PREFIXO + "' "
	cQueryOHF +=         " AND SE2.E2_NUM = '" + M->E2_NUM + "' "
	cQueryOHF +=         " AND SE2.E2_PARCELA = '" + M->E2_PARCELA + "' "
	cQueryOHF +=         " AND SE2.E2_FORNECE = '" + M->E2_FORNECE + "' "
	cQueryOHF +=         " AND SE2.E2_LOJA = '" + M->E2_LOJA + "' "
	cQueryOHF +=         " AND SE2.D_E_L_E_T_ = ' ' "

	cQueryOHF  := ChangeQuery(cQueryOHF)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryOHF), cAlsOHF, .T., .T.)

	lExistOHF := (cAlsOHF)->(! EOF())

	(cAlsOHF)->(DbCloseArea())

Return (lExistOHF)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGetOHG
Verifica se existem desdobramentos pós pagamentos vinculados no título

@param  lVldCont , logico , Se .T. filtra desdobramentos contabilizados
@return lExistOHG, logico, Se .T. foram encontrados desdobramentos

@author  Jonatas Martins / Abner Fogaça
@since   06/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JurGetOHG(lVldCont)
	Local cQueryOHG    := ""
	Local cDtCont      := ""
	Local cAlsOHG      := GetNextAlias()
	Local lExistOHG    := .F.

	Default lVldCont   := .F.

	cQueryOHG += " SELECT SE2.R_E_C_N_O_ SE2REC "
	cQueryOHG +=   " FROM " + RetSqlname('SE2') + " SE2 "
	cQueryOHG +=      " INNER JOIN " + RetSqlname('FK7') + " FK7 "
	cQueryOHG +=          " ON FK7.FK7_FILIAL = SE2.E2_FILIAL "
	cQueryOHG +=         " AND SE2.E2_FILIAL ||'|'|| SE2.E2_PREFIXO ||'|'|| SE2.E2_NUM ||'|'|| SE2.E2_PARCELA ||'|'|| SE2.E2_TIPO ||'|'|| SE2.E2_FORNECE ||'|'|| SE2.E2_LOJA = FK7.FK7_CHAVE "
	cQueryOHG +=         " AND FK7.D_E_L_E_T_ = ' ' "
	cQueryOHG +=      " INNER JOIN " + RetSqlname('OHG') + " OHG "
	cQueryOHG +=          " ON OHG.OHG_FILIAL = SE2.E2_FILIAL "
	cQueryOHG +=         " AND OHG.OHG_IDDOC = FK7.FK7_IDDOC"
	If OHG->(ColumnPos("OHG_DTCONT")) > 0 .And. lVldCont
		cDtCont   := Space(TamSx3('OHG_DTCONT')[1])
		cQueryOHG +=         " AND OHG.OHG_DTCONT <> '" + cDtCont + "' "
	EndIf
	cQueryOHG +=         " AND OHG.D_E_L_E_T_ = ' ' "
	cQueryOHG +=  " WHERE SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
	cQueryOHG +=         " AND SE2.E2_PREFIXO = '" + M->E2_PREFIXO + "' "
	cQueryOHG +=         " AND SE2.E2_NUM = '" + M->E2_NUM + "' "
	cQueryOHG +=         " AND SE2.E2_PARCELA = '" + M->E2_PARCELA + "' "
	cQueryOHG +=         " AND SE2.E2_FORNECE = '" + M->E2_FORNECE + "' "
	cQueryOHG +=         " AND SE2.E2_LOJA = '" + M->E2_LOJA + "' "
	cQueryOHG +=         " AND SE2.D_E_L_E_T_ = ' ' "

	cQueryOHG  := ChangeQuery(cQueryOHG)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryOHG), cAlsOHG, .T., .T.)

	lExistOHG := (cAlsOHG)->(! EOF())

	(cAlsOHG)->(DbCloseArea())

Return (lExistOHG)

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldCompAd()
Função para validar se pode fazer a compensação do RA gerado pelo
controle de adiantamento.
Só realizará a validação caso a integração entre os módulos
SIGAFIN e SIGAPFS MV_JURXFIN estiver ativada.

@return lRet   .T. Se o RA é valido para ser compensado.

Uso na função fA330Comp (FINA330) - Compensação de Contas a Receber

@author Jorge Martins
@since  11/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldCompAd()
Local lRet := .T.

If NWF->(ColumnPos("NWF_EXCLUS")) > 0 // Proteção
	If JurGetDados('NWF', 3, xFilial('NWF') + SE1->E1_NUM, 'NWF_EXCLUS' ) == "1"
		lRet := JurMsgErro( STR0108, , ; // "Não é possível compensar este título, pois foi gerado a partir de um adiantamento exclusivo."
		                    STR0109 )    // "Verifique o adiantamento deste título no módulo SIGAPFS."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurLancDiv()
Função para retornar os valores dividos da baixa do CR ou CP conforme a Classificação de Naturezas

@param cOrigem  , O tipo de origem dos lançamentos que serão gerados:
                  1 = "Contas a Pagar"
                  2 = "Contas a Receber"
                  3 = "Faturamento"
@param nRecnoSE5, Recno da SE5 que será usada como base para identificar os valores.
@param lEstorno , Indica se é um estorno de baixa

@return lRet    , Se foi realizado corretamente a divisão de lançamentos
@return aLancDiv, Array com dois subArray, dividos entres os lançamentos que devem ser criados na origem[1] e no destino[2].
                  [1]    Dados para ser usados na criação dos lançamentos
                  [1][n][1] Código da naturaza para ser usada na origem do lançamento.
                  [1][n][2] Código da naturaza para ser usada no destino do lançamento.
                  [1][n][3] Valor que deve ser considerado (conforme SE5).
                  [1][n][4] Histórico para ser usado no lançamento (conforme SE5).

@author Bruno Ritter
@since  24/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurLancDiv(cOrigem, nRecnoSE5, lEstorno)
	Local aLancDiv  := {}
	Local aRetDados := {}
	Local aValores  := {}
	Local aAreas    := { SE5->(GetArea()), GetArea() }
	Local cNatTrans := ""
	Local cNatClass := ""
	Local cNatOrig  := ""
	Local cNatDest  := ""
	Local cQuery    := ""
	Local cSE5TpDoc := ""
	Local nValor    := 0
	Local nPos      := 0
	Local nReg      := 0
	Local nSE5Valor := 0
	Local lRet      := .T.

	Default lEstorno := .F.

	If FWAliasInDic("OHP") // Proteção
		OHP->(dbGoTop())
		If OHP->( EOF() )
			lRet := JurMsgErro(STR0112, , STR0113) // "Não é possível realizar a operação." "Complete o cadastro de classificação de naturezas."
		EndIf

		If lRet
			If cOrigem == "1"
				cNatTrans := JGetNatTra() // Transitória de pagamento de impostos, taxas, juros, descontos
			ElseIf cOrigem == "2"
				cNatTrans := JurBusNat("8") // Natureza cujo tipo é o 8-Transitória de Recebimento
			EndIf

			SE5->(DbGoto(nRecnoSE5))

			If lEstorno .And. cOrigem == "2" // Somente estorno de contas a receber
				// Aglutina os valores da SE5 referente ao mesmo tipo de lançamento
				cQuery := " SELECT SUM(SE5.E5_VALOR) E5_VALOR, SE5.E5_TIPODOC "
				cQuery +=   " FROM " + RetSqlName("SE5") + " SE5 "
				cQuery +=  " WHERE SE5.E5_FILIAL  = '" + SE5->E5_FILIAL + "' "
				cQuery +=    " AND (SE5.E5_IDORIG = '" + SE5->E5_IDORIG + "' "
				// No estorno, é gerada uma nova SE5 somente para valor principal
				// Os valores de juros, multa e desconto não tem nova SE5 e estão com E5_IDORIG da baixa original.
				// Por isso é necessário esse trecho de query abaixo para buscar justamente esses registros.
				cQuery +=          " OR (SE5.E5_PREFIXO = '" + SE5->E5_PREFIXO + "' "
				cQuery +=          " AND SE5.E5_NUMERO  = '" + SE5->E5_NUMERO  + "' "
				cQuery +=          " AND SE5.E5_PARCELA = '" + SE5->E5_PARCELA + "' "
				cQuery +=          " AND SE5.E5_TIPO    = '" + SE5->E5_TIPO    + "' "
				cQuery +=          " AND SE5.E5_CLIFOR  = '" + SE5->E5_CLIFOR  + "' "
				cQuery +=          " AND SE5.E5_LOJA    = '" + SE5->E5_LOJA    + "' "
				cQuery +=          " AND SE5.E5_SEQ     = '" + SE5->E5_SEQ     + "' "
				cQuery +=          " AND SE5.E5_TIPODOC <> 'VL'))"
				cQuery +=          " AND SE5.D_E_L_E_T_ = ' ' "
				cQuery +=     " GROUP BY SE5.E5_TIPODOC "
			Else
				// Aglutina os valores da SE5 referente ao mesmo tipo de lançamento
				cQuery := " SELECT SUM(SE5.E5_VALOR) E5_VALOR, SE5.E5_TIPODOC "
				cQuery +=   " FROM " + RetSqlName("SE5") + " SE5 "
				cQuery +=  " WHERE SE5.E5_FILIAL  = '" + SE5->E5_FILIAL + "' "
				cQuery +=    " AND SE5.E5_IDORIG  = '" + SE5->E5_IDORIG + "' "
				cQuery +=    " AND SE5.D_E_L_E_T_ = ' ' "
				cQuery +=  " GROUP BY SE5.E5_TIPODOC "
			EndIf

			aValores := JurSQL(cQuery, {"E5_VALOR", "E5_TIPODOC"})

			If cOrigem == "2" .And. !Empty(SE1->E1_NUMLIQ) .And. FWAliasInDic("OHT")
				JValLiq(@aValores, lEstorno) // Valores de multas, juros, descontos feitos na liquidação
			EndIf

		EndIf

		For nReg := 1 To Len(aValores)

			nSE5Valor := aValores[nReg][1]
			cSE5TpDoc := aValores[nReg][2]

			aRetDados := JurGetDados("OHP", 1, xFilial("OHP") + cOrigem + cSE5TpDoc, {"OHP_CNATUR", "OHP_DEFLAN", "OHP_DESC"} )

			If Empty(aRetDados)
				aRetDados := {"", "", "", ""}
			EndIf

			cNatClass  := aRetDados[1]
			cTipLanc   := aRetDados[2]
			cDescClass := AllTrim(aRetDados[3])

			If Empty(cNatClass) .And. !Empty(cDescClass)
				lRet := JurMsgErro(STR0110,, i18n(STR0111, {cDescClass}) ) // "Cadastro da Classificação de naturezas está incompleto." "Verifique o registro '#1' na classificação de naturezas."
			EndIf

			If lRet .And. !Empty(cNatClass)
				Do Case
					Case cTipLanc == "1" // Origem
						cNatOrig := cNatClass
						cNatDest := cNatTrans
						nValor   := nSE5Valor

					Case cTipLanc == "2" // Destino
						cNatOrig := cNatTrans
						cNatDest := cNatClass
						nValor   := nSE5Valor

					Case cTipLanc == "3" // Conforme o valor (- ou +)
						If (nSE5Valor > 0 .And. cOrigem == "1") .Or. (nSE5Valor < 0 .And. cOrigem == "2")
							cNatOrig := cNatTrans
							cNatDest := cNatClass
							nValor   := Abs(nSE5Valor)
						Else
							cNatOrig := cNatClass
							cNatDest := cNatTrans
							nValor   := Abs(nSE5Valor)
						EndIf
				EndCase

				If cNatOrig != cNatTrans
					nPos := aScan(aLancDiv, { |aNat| aNat[1] == cNatOrig })
				ElseIf cNatDest != cNatTrans
					nPos := aScan(aLancDiv, { |aNat| aNat[2] == cNatDest })
				Else
					nPos := 0
				EndIf

				If nPos > 0
					aLancDiv[nPos][3] += nValor
					aLancDiv[nPos][4] := aLancDiv[nPos][4] + " + " + cDescClass
				Else
					aAdd(aLancDiv, {cNatOrig, cNatDest, nValor, cDescClass} )
				EndIf
			EndIf

		Next nReg
	EndIf

	Aeval( aAreas, {|aArea| RestArea( aArea ) } )
	
Return {lRet, aLancDiv}

//-------------------------------------------------------------------
/*/{Protheus.doc} JCPVlBruto
Soma o valor de retenção do título para retornar o valor bruto
do contas a pagar.

@param nRecSE2   , Recno do SE2 para retornar o valor bruto

@return nValBruto, Valor bruto do contas a pagar

@author Bruno Ritter
@since  29/11/2018
@obs    Aconselhado pelo financeiro usar o valor de base para obter o valor bruto
/*/
//-------------------------------------------------------------------
Function JCPVlBruto(nRecSE2)
	Local nValBruto := 0
	Local nPosOld   := SE2->(Recno())
	
	Default nRecSE2 := 0

	If !Empty(nRecSE2) .AND. VALTYPE(nRecSE2) == "C"
		nRecSE2 := VAL(nRecSE2)
	EndIf

	SE2->(DbGoTo(nRecSE2))

	If SE2->(!EOF())
		nValBruto := JValTitNota(.T.)
	EndIf

	SE2->(dbGoTo(nPosOld))

Return (nValBruto)

//-------------------------------------------------------------------
/*/{Protheus.doc} JCPVlLiqui
Retorna o valor do contas a pagar líquido.

@param nRecSE2    , Recno do SE2 para retornar o valor liquído

@return nValLiquid, Valor líquido do contas a pagar

@author Bruno Ritter
@since  04/12/2018
/*/
//-------------------------------------------------------------------
Function JCPVlLiqui(nRecSE2)
Local nValLiquid  := 0
Local nPosOld     := SE2->(Recno())

	SE2->(dbGoTo(nRecSE2))

	If SE2->(!EOF())
		nValLiquid := JValTitNota(.F.)
	EndIf

	SE2->(dbGoTo(nPosOld))

Return nValLiquid

//-------------------------------------------------------------------
/*/{Protheus.doc} JValTitNota
Retorna o valor do contas a pagar (Bruto ou líquido)

@param cCampo    , Campo que foi chamado pelo inicializador padrão
                   (Ex: E2__VALOR, E2__VLRLIQ)
@param lValBruto , Se .T. retorna o valor bruto do título, se .F.
                   retorna o valor líquido.

@return nValTitNF, Valor do contas a pagar (Bruto ou líquido)

@author Jonatas Martins
@since  04/12/2018
/*/
//-------------------------------------------------------------------
Static Function JValTitNota(lValBruto)
Local nValTitNF   := SE2->E2_VALOR
Local nPosImp     := 0
Local lAbatIssEmi := .F.
Local lAbatPCCEmi := .F.
Local lAbatINSS   := .F.
Local lAbatIRRFEm := .F.
Local aImpCP      := {}
Local aBind       := {}
Local cQuery      := ""
Local cQryRes     := ""

	If cPaisLoc == "BRA" .And. lValBruto
		lAbatIssEmi := SuperGetMv("MV_MRETISS", .F., "1") == "1" // Modo de retenção do ISS nas aquisições de serviços - 1 = Na emissão do título principal ou 2 = Na baixa do título principal
		lAbatPCCEmi := SuperGetMv("MV_BX10925", .F., "1") == "2" // Define momento do tratamento da retencäo dos impostos Pis Cofins e Csll - 1 = Na Baixa ou 2 = Na Emissäo
		lAbatINSS   := JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_DEDINSS") <> "2" // Deduz INSS do título principal - 1 = Sim, 2 = Não
		lAbatIRRFEm := JurGetDados("SA2", 1, xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA, "A2_CALCIRF") <> "2" // Cálculo do IRRF na Emissão - 1 = Normal, 2 = IRRF Baixa, 3 = Simples, 4 = Empresa Individual
		aImpCP      := FinImpConf("1", cFilAnt, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ)
		
		If Len(aImpCP) > 0 // Se teve algum imposto calculado pelo configurador de tributos
			cQuery := " SELECT FK4.FK4_IMPOS, FK4.FK4_VALOR, FKK_FATGER, FKK_VLNOTA, FKK_CART, SE2.E2_PIS, SE2.E2_COFINS, SE2.E2_CSLL"
			cQuery +=   " FROM " + RetSqlName("SE2") + " SE2"
			cQuery +=  " INNER JOIN " + RetSqlName("FK7") + " FK7"
			cQuery +=     " ON FK7.FK7_FILIAL = SE2.E2_FILIAL"
			cQuery +=    " AND FK7.FK7_PREFIX = SE2.E2_PREFIXO"
			cQuery +=    " AND FK7.FK7_NUM = SE2.E2_NUM"
			cQuery +=    " AND FK7.FK7_PARCEL = SE2.E2_PARCELA"
			cQuery +=    " AND FK7.FK7_TIPO = SE2.E2_TIPO"
			cQuery +=    " AND FK7.D_E_L_E_T_ = ?" // #1
			AAdd(aBind, {' ', "S"})
			cQuery +=  " INNER JOIN " + RetSqlName("FK4") + " FK4"
			cQuery +=     " ON FK4.FK4_IDORIG = FK7.FK7_IDDOC"
			cQuery +=    " AND FK4.D_E_L_E_T_ = ?" // #2
			AAdd(aBind, {' ', "S"})
			cQuery +=  " INNER JOIN " + RetSqlName("FOO") + " FOO"
			cQuery +=     " ON FOO.FOO_FILIAL = FK4.FK4_FILIAL"
			cQuery +=    " AND FOO.FOO_CODIGO = FK4.FK4_IMPOS"
			cQuery +=    " AND FOO.D_E_L_E_T_ = ?"
			AAdd(aBind, {' ', "S"}) // #3
			cQuery +=  " INNER JOIN " + RetSqlName("FKK") + " FKK"
			cQuery +=     " ON FKK.FKK_FILIAL = FOO.FOO_FILIAL"
			cQuery +=    " AND FKK.FKK_IDRET = FOO.FOO_IDRET"
			cQuery +=    " AND FKK.FKK_FATGER = ?"
			AAdd(aBind, {'1', "S"}) // #4
			cQuery +=    " AND FKK.D_E_L_E_T_ = ?" // #5
			AAdd(aBind, {' ', "S"})
			cQuery +=  " INNER JOIN " + RetSqlName("FOK") + " FOK"
			cQuery +=     " ON FOK.FOK_CODIGO = FKK.FKK_CODIGO"
			cQuery +=    " AND FOK.FOK_FORNEC = SE2.E2_FORNECE"
			cQuery +=    " AND FOK.FOK_LOJA = SE2.E2_LOJA"
			cQuery +=    " AND FOK.D_E_L_E_T_ = ?"
			AAdd(aBind, {' ', "S"}) // #6
			cQuery +=  " WHERE SE2.E2_FILIAL = ?"  // #7
			AAdd(aBind, {SE2->E2_FILIAL, "S"})
			cQuery +=    " AND SE2.E2_PREFIXO = ?" // #8
			AAdd(aBind, {SE2->E2_PREFIXO, "S"})
			cQuery +=    " AND SE2.E2_NUM = ?"     // #9
			AAdd(aBind, {SE2->E2_NUM, "S"})
			cQuery +=    " AND SE2.E2_PARCELA = ?" // #10
			AAdd(aBind, {SE2->E2_PARCELA, "S"})
			cQuery +=    " AND SE2.E2_TIPO = ?" // #11
			AAdd(aBind, {SE2->E2_TIPO, "S"})
			cQuery +=    " AND SE2.E2_FORNECE = ?" // #12
			AAdd(aBind, {SE2->E2_FORNECE, "S"})
			cQuery +=    " AND SE2.E2_LOJA = ?" // #13
			AAdd(aBind, {SE2->E2_LOJA, "S"})
			cQuery +=    " AND SE2.E2_EMISSAO BETWEEN FKK.FKK_VIGINI AND FKK.FKK_VIGFIM"
			cQuery +=    " AND SE2.D_E_L_E_T_ = ?" // #14
			AAdd(aBind, {' ', "S"})
			
			cQuery := ChangeQuery(cQuery)
			cQuery := JurTRepBin(cQuery, aBind)
			
			cQryRes := GetNextAlias()
			DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQryRes, .T., .T.)
			
			// Imposto calculados pelo configurador de tributos
			While !(cQryRes)->(EOF())
				nPosImp := AScan(aImpCP, {|x| x[1] ==  AllTrim((cQryRes)->(FK4_IMPOS))})
				// Se o imposto foi calculado pelo configurador de tributos, e o regime é Competência e a regra financeira subtrai o imposto do título principal
				// e a carteira é contas a pagar (Regra segundo a função F050VldImp do Financeiro)
				If nPosImp > 0
					If (cQryRes)->(FK4_VALOR) > 0 .And. (cQryRes)->(FKK_FATGER) == '1' .And. (cQryRes)->(FKK_VLNOTA) == '1' .And. (cQryRes)->(FKK_CART) == "1"
						nValTitNF += (cQryRes)->(FK4_VALOR)
					EndIf
				EndIf
				(cQryRes)->(DbSkip())
			EndDo
			
			(cQryRes)->(DbCloseArea())
		EndIf

		// Impostos calculado da forma antiga (Legado)
		If AScan(aImpCP, {|x| x[1] == "IRF"}) == 0
			nValTitNF += IIf(lAbatIRRFEm, SE2->E2_IRRF, 0)
		EndIf
		If (AScan(aImpCP, {|x| x[1] == "PIS"}) == 0 .AND. AScan(aImpCP, {|x| x[1] == "COF"}) == 0 .AND. AScan(aImpCP, {|x| x[1] == "IRF"}) == 0)
			nValTitNF += IIf(lAbatPCCEmi, SE2->E2_PIS + SE2->E2_COFINS + SE2->E2_CSLL, 0)
		EndIf
		If AScan(aImpCP, {|x| x[1] == "INSS"}) == 0
			nValTitNF += IIf(lAbatINSS, SE2->E2_INSS, 0)
		EndIf
		If AScan(aImpCP, { |x| x[1] == "ISS"}) == 0
			nValTitNF += IIf(lAbatIssEmi, SE2->E2_ISS, 0)
		EndIf
	EndIf

Return (nValTitNF)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurQWBorde
Retorna uma condição no where para gerar a tela de seleção
de títulos do bordero.

@return cWhere, Condição de where para a query de títulos

@author Bruno Ritter
@since  16/01/2019
@obs    Uso na função Fa060Borde (FINA060) e Fa061Borde (FINA061)
/*/
//-------------------------------------------------------------------
Function JurQWBorde()

Local lJUSAPOR := SuperGetMV("MV_JUSAPOR",.F.,.F.)
Local cWhere := ""

    If (lJUSAPOR)
        cWhere := " AND E1_PORTADO = '" + cPort060 + "'"
        cWhere += " AND E1_AGEDEP = '" + cAgen060 + "'"
        cWhere += " AND E1_CONTA = '" + cConta060 + "'"
    EndIf

    cWhere += " AND E1_BOLETO = '1'

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} JurClasNat
Retorna a classifcação de uma natureza no cadastro de naturezas conforme o código cCodOHP

@param cCodOHP, Código para buscar a natureza na OHP

@return cNautr, Código da natureza

@author Bruno Ritter / Queizy
@since  27/02/2019
/*/
//-------------------------------------------------------------------
Function JurClasNat(cCodOHP)
	Local aDados := {}
	Local cDesc  := ""
	Local cNatur := ""

	If FWAliasInDic("OHP")
		aDados := JurGetDados("OHP", 2, xFilial("OHP") + cCodOHP, {"OHP_CNATUR", "OHP_DESC"})

		If Empty(aDados)
			JurMsgErro(i18n(STR0121, {cCodOHP}), , STR0122) // "Classificação: '#1' não encontrada!" "Preencha o código da natureza no cadastro de Classificação."
		Else
			cNatur := AllTrim(aDados[1])
			cDesc  := AllTrim(aDados[2])
			If Empty(cNatur)
				JurMsgErro(i18n(STR0121, {cDesc}), , STR0122) // "Classificação: '#1' não encontrada!" "Preencha o código da natureza no cadastro de Classificação."
			EndIf
		EndIf
	Else
		JurMsgErro(STR0119, , STR0120) // "Tabela de Classificação de Naturezas (OHP) não encontrada!" "Por gentileza atualize o dicionário e configure as naturezas."
	EndIf

Return cNatur

//-------------------------------------------------------------------
/*/{Protheus.doc} JurQWRelBx
Retorna uma condição no where para o não demostrar as baixar por
cancelamento de fatura no relatório
Uso na função FA190ImpR4 (FINR190) - Relatório de relação de baixas

@return cWhere, Condição de where para a query do relatório

@author Bruno Ritter
@since  24/02/2019
/*/
//-------------------------------------------------------------------
Function JurQWRelBx()
	Local cWhere := " AND (E5_MOTBX <> 'CNF') "

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldNatDes
Valida se o campo de natureza pode ser alterado quando o desdobramento 
for originado da aprovação de despesas

@author Abner Fogaça de Oliveira
@since 27/03/19
/*/
//-------------------------------------------------------------------
Function JVldNatDes()
	Local oModel      := FWModelActive()
	Local cPrefixo    := IIf(oModel:GetId() == "JURA246", "OHF", "OHG")
	Local lIntFinanc  := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local lRet        := .T.
	Local lSolDespCli := .F.
	Local lNatDespCli := .F.
	Local oSubModel   := Nil
	Local cNatureza   := ""
	Local cNZQCod     := ""

	If lIntFinanc
		If (cPrefixo)->(ColumnPos(cPrefixo + "_NZQCOD")) > 0 // Proteção
			oSubModel := oModel:GetModel(cPrefixo + "DETAIL")
			cNZQCod   := oSubModel:GetValue(cPrefixo + "_NZQCOD")

			If !Empty(cNZQCod)
				cNatureza   := oSubModel:GetValue(cPrefixo + "_CNATUR")
				lSolDespCli := JurGetDados("NZQ", 1, xFilial("NZQ") + cNZQCod, "NZQ_DESPES") == "1" // Solicitação de despesa é "Despesa de Cliente"
				lNatDespCli := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI") == "5" // Nova natureza é despesa de cliente
				If lSolDespCli <> lNatDespCli
					cTpSolic := IIf(lSolDespCli, STR0128, STR0129) // "cliente" / "escritório"
					lRet     := JurMsgErro(I18N(STR0130, {AllTrim(cNatureza), cTpSolic}),, ; // "Não é possível indicar a natureza '#1', pois este desdobramento foi gerado a partir de uma solicitação de despesas de '#2'."
					                       I18N(STR0131, {cTpSolic})) // "Por favor indique uma natureza destinada para despesas de '#1'."
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JTrataComp
Trata os recnos no momento da compensação, para que crie os lançamentos
corretamente independente se o usuário está posicionado no RA ou 
no título a ser compensado.

@param  nSE1Recno, Recno do registro SE1
@param  nSE5Recno, Recno do registro SE5
@param  nRegCmp  , Recno do Título que está sendo usado para compensar

@return lGeraLanc, Indica se deve ser gerado o Lançamento (OHB)

@author Jorge Martins
@since  10/07/2019
/*/
//-------------------------------------------------------------------
Static Function JTrataComp(nSE1Recno, nSE5Recno, nRegCmp)
Local lGeraLanc  := .F.
Local nSE1RecAtu := nSE1Recno // Armazena RECNO posicionado

SE1->(DbGoto(nSE1Recno))
SE5->(DbGoto(nSE5Recno))

If nSE1Recno != nRegCmp          // Só deve gerar lançamentos quando os RECNOS forem diferentes
	If SE5->E5_TIPO != MVRECANT  // E a SE5 posicionada não for a do RA (Deve ser a do título para correta criação da OHB)
		lGeraLanc := .T.
	EndIf
EndIf

If lGeraLanc
	If SE1->E1_TIPO == MVRECANT // Se a compensação está sendo efetuada posicionado no RA
		nSE1Recno := nRegCmp    // Realiza a inversão dos RECNOS, para criar os lanctos corretamente
		nRegCmp   := nSE1RecAtu
	EndIf
EndIf

Return lGeraLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} JIsMovBco
Função que valida se o motivo da baixa movimenta banco

@param cMotBaixa, código do motivo de baixa

@return lMovBanco, logico, Se .T. movimenta banco

@author Jonatas Martins
@since  10/10/2019
/*/
//------------------------------------------------------------------
Function JIsMovBco(cMotBaixa)
	Local lMovBanco := .F.

	Default cMotBaixa := SE5->E5_MOTBX

	If !Empty(cMotBaixa) .And. AllTrim(cMotBaixa) != "LIQ"
		lMovBanco := MovBcoBx(cMotBaixa)
	EndIf

Return (lMovBanco)

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldTipoCp
Indica se o tipo do Contas a pagar permite manipulação dos desdobramentos
de forma manual (pelo usuário)

@param cTipoCP  , E2_TIPO do contas a pagar para validar
@param lExibeMsg, Se deve exibir mensagem de erro

@return lPermite, Se o usuário pode manipular o desdobramento

@author Bruno Ritter / Jorge Martins
@since  05/11/2019
/*/
//------------------------------------------------------------------
Function JVldTipoCp(cTipoCP, lExibeMsg)
	Local lPermite  := .T.
	Local cTipos := ""

	Default cTipoCP   := SE2->E2_TIPO
	Default lExibeMsg := .T.

	cTipos := JTipoTitImp()
	cTipos += MVPAGANT + "|"  // PA
	cTipos += MVPROVIS + "|"  // PR

	If cTipoCP $ cTipos

		lPermite := .F.

		If lExibeMsg
			JurMsgErro(I18n(STR0134, {cTipoCP}), , STR0135) // "Esta opção não está disponível para títulos do tipo '#1'."
		EndIf
	EndIf

Return lPermite

//-------------------------------------------------------------------
/*/{Protheus.doc} JTpTitImp
Retorna todos os tipos de titulo referente a impostos / taxas

@Return cImpostos, todos os tipos de titulo referente a impostos / taxas

@author  Bruno Ritter / Jorge Martins
@since   14/11/2019
/*/
//-------------------------------------------------------------------
Static Function JTipoTitImp()
	Local cImpostos := ""

	cImpostos := MVTAXA   + "|" + MVTXA   + "|" // Taxa
	cImpostos += MVINSS   + "|" + MVINABT + "|" // INS
	cImpostos += MVISS    + "|" + MVISABT + "|" // ISS
	cImpostos += MVCOFINS + "|" + MVCFABT + "|" // COFINS
	cImpostos += MVPIS    + "|" + MVPIABT + "|" // PIS
	cImpostos += MVIRF    + "|" + MVIRABT + "|" // IRRF
	cImpostos += MVCS     + "|" + MVCSABT + "|" // CSS

Return cImpostos

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldExt
Função para validação da natureza do banco na rotina de conciliação
automática.

@param  nSIGRecno , Recno da tabela de arquivos de extrato importados

@return lValExt   , todos os tipos de titulo referente a impostos / taxas

@author  Jonatas Martins
@since   29/11/2019
@obs     Função chamada no fonte FINA473 ao clicar no botão "Conciliar"
/*/
//-------------------------------------------------------------------
Function JurVldExt(nSIGRecno)
	Local aArea    := GetArea()
	Local cBanco   := ""
	Local cAgencia := ""
	Local cConta   := ""
	Local aDados   := {}
	Local lValExt  := .F.

	Default nSIGRecno := 0

	If nSIGRecno > 0
		aDados := JurGetDados("SIG", 1, xFilial("SIG") + SIF->IF_IDPROC, {"IG_AGEEXT", "IG_CONEXT"})
		
		If Len(aDados) == 2
			cBanco    := SIF->IF_BANCO
			cAgencia  := aDados[1]
			cConta    := aDados[2]
			cNatBanco := JurBusNat("", cBanco, cAgencia, cConta, .F.)
			lValExt   := !Empty(cNatBanco)
		EndIf
	EndIf

	If !lValExt
		JurMsgErro(I18N(STR0125, {cBanco, cAgencia, cConta}),, STR0124) //"Não foi encontrado uma natureza para o Banco: '#1', Agência: '#2' e Conta: '#3'." "Favor verifique o cadastro de natureza."
	EndIf

	RestArea(aArea)
	
Return (lValExt)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurConBco
Cria lançamento na efetivação da conciliação do extrato bancário

@param nRecnoSE5 , numérico  , Recno da movimentação bancário no SE5
@param cNaturEfet, caracatere, Natureza escolhida pelo usuário na conciliação
@param cSeqConc  , caracatere, ID da conciliação único por grupo de empresas
@param cBanco    , caracatere, Banco do extrato bancário
@param cAgencia  , caracatere, Agência do extrato bancário
@param cConta    , caracatere, Conta do extrato bancário
@param cTipoMov  , caracatere, Tipo do movimento "R - Receber" - "P - Pagar"
@param dDataExt  , data      , Data da conciliação do movimento
@param nValorMov , numérico  , Valor do movimento
@param cHistor   , caracatere, Histórico digitado pelo usuário

@return lSet     , logico    , Se .T. criu o lançamento com sucesso

@author Jonatas Martins
@since  10/10/2019
/*/
//------------------------------------------------------------------
Function JurConBco(nRecnoSE5, cNaturEfet, cSeqConc, cBanco, cAgencia, cConta, cTipoMov, dDataExt, nValorMov, cHistor)
	Local aArea        := GetArea()
	Local oModelLanc   := Nil
	Local oModelOHB    := Nil
	Local aSetValue    := {}
	Local cNatBanco    := ""
	Local cNatOrig     := ""
	Local cNatDest     := ""
	Local cLog         := ""
	Local nVal         := 0
	Local lSet         := .T.
	
	Default nRecnoSE5  := 0
	Default cNaturEfet := ""
	Default cSeqConc   := ""
	Default cBanco     := ""
	Default cAgencia   := ""
	Default cConta     := ""
	Default cTipoMov   := ""
	Default dDataExt   := CtoD(Space(8))
	Default nValorMov  := 0

	If nRecnoSE5 > 0 .And. !Empty(cNaturEfet) .And. !Empty(cSeqConc)
		cNatBanco := JurBusNat("", cBanco, cAgencia, cConta)

		If !Empty(cNatBanco)
			If cTipoMov == "R" // "R" - Receber
				cNatOrig := cNatBanco
				cNatDest := cNaturEfet
			Else // "P" - Pagar
				cNatOrig := cNaturEfet
				cNatDest := cNatBanco
			EndIf
			
			oModelLanc := FWLoadModel("JURA241") // Lançamentos
			oModelLanc:SetOperation(MODEL_OPERATION_INSERT)
			oModelLanc:Activate()
			oModelOHB  := oModelLanc:GetModel("OHBMASTER")
			
			AAdd(aSetValue, {"OHB_ORIGEM" , "7"      }) // 7-Extrato
			AAdd(aSetValue, {"OHB_NATORI" , cNatOrig })
			AAdd(aSetValue, {"OHB_NATDES" , cNatDest })
			AAdd(aSetValue, {"OHB_DTLANC" , dDataExt })
			AAdd(aSetValue, {"OHB_CMOELC" , "01"     }) // Sempre na moeda nacional
			AAdd(aSetValue, {"OHB_VALOR"  , nValorMov})
			AAdd(aSetValue, {"OHB_HISTOR" , cHistor  })
			AAdd(aSetValue, {"OHB_FILORI" , cFilAnt  })
			AAdd(aSetValue, {"OHB_SEQCON" , cSeqConc })

			For nVal := 1 To Len(aSetValue)
				If !oModelOHB:SetValue(aSetValue[nVal][1], aSetValue[nVal][2])
					lSet := .F.
					Exit
				EndIf
			Next nVal

			If lSet .And. oModelLanc:VldData()
				oModelLanc:CommitData()
				oModelLanc:DeActivate()
			Else
				cLog := cValToChar(oModelLanc:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelLanc:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelLanc:GetErrorMessage()[6])
				JurMsgErro(cLog, , STR0133) // "Ajustes as inconsistências."
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return (lSet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurEstConc
Exclui lançamento no cancelamento da efetivação do extrato bancário

@param nRecnoSE5 , numérico, Recno da movimentação bancário no SE5

@return lDeleted , logico  , Se .T. excluiu o lançamento com sucesso

@author Jonatas Martins
@since  10/10/2019
/*/
//------------------------------------------------------------------
Function JurEstConc(nRecnoSE5, cSeqConSE5)
	Local aArea        := GetArea()
	Local aAreaOHB     := OHB->(GetArea())
	Local oModel       := Nil
	Local cTmpOHB      := ""
	Local cSeqConc     := ""
	Local cLog         := ""
	Local lDeleted     := .F.
	
	Default nRecnoSE5  := 0
	Default cSeqConSE5 := ""

	If nRecnoSE5 > 0 .And. OHB->(ColumnPos("OHB_SEQCON")) > 0 // Proteção
		cTmpOHB  := GetNextAlias()
		cSeqConc := cSeqConSE5
		
		// Nao tem filial pois o SEQCON é único para o grupo da empresa
		BeginSql Alias cTmpOHB
			%noparser%
			SELECT OHB.R_E_C_N_O_ RECOHB
			  FROM %Table:OHB% OHB
			 WHERE OHB.OHB_SEQCON = %Exp:cSeqConc%
			   AND OHB.OHB_ORIGEM = '7' // 7-Extrato
			   AND OHB.%NotDel%
		EndSql

		If (cTmpOHB)->(! Eof())
			OHB->(DbGoTo((cTmpOHB)->RECOHB))
			oModel := FWLoadModel("JURA241")
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			oModel:Activate()

			If oModel:IsActive() .And. oModel:VldData()
				oModel:CommitData()
				oModel:DeActivate()
				lDeleted := .T.
			Else
				cLog := cValToChar(oModelLanc:GetErrorMessage()[4]) + ' - '
				cLog += cValToChar(oModelLanc:GetErrorMessage()[5]) + ' - '
				cLog += cValToChar(oModelLanc:GetErrorMessage()[6])
				JurMsgErro(cLog, , STR0133) // "Ajustes as inconsistências."
			EndIf
		EndIf

		(cTmpOHB)->(DbCloseArea())
	EndIf

	RestArea(aAreaOHB)
	RestArea(aArea)

Return (lDeleted)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCNF
Rotina para verificar faturas canceladas.

@param  nRecno, Recno do título da SE1 (Contas a Receber)

@return lCNF  , Se .T. a fatura está cancelada

@author Reginaldo S Borges
@since  18/12/2019
@obs    Uso na função Fa040Legenda (FINXFIN) 
/*/
//-------------------------------------------------------------------
Function JurCNF(nSE1Recno)
	Local cJurFat  := SE1->E1_JURFAT
	Local lCNF     := .F.
	Local nTamFil  := 0
	Local nTamEsc  := 0
	Local nTamFat  := 0
	Local cFilNXA  := ""
	Local cEscrit  := ""
	Local cFatura  := ""
	
	If !Empty(cJurFat) .And. SE1->E1_SALDO == 0
		cJurFat  := Strtran(cJurFat, "-", "")

		nTamFil  := TamSX3("NXA_FILIAL")[1]
		nTamEsc  := TamSX3("NXA_CESCR")[1]
		nTamFat  := TamSX3("NXA_COD")[1]
		cFilNXA  := Substr(cJurFat, 1, nTamFil)
		cEscrit  := Substr(cJurFat, nTamFil + 1, nTamEsc)
		cFatura  := Substr(cJurFat, nTamFil + nTamEsc + 1, nTamFat)

		lCNF := JurGetDados("NXA", 1, cFilNXA + cEscrit + cFatura, "NXA_SITUAC") == "2" // Cancelado 
	EndIf

Return (lCNF)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTitFat
Efetiva a gravação na tabela OHT (relacionamento Faturas x Títulos)

@param aChaveSE1 array contendo a chave dos título da fatura
@param nRecnoNXA Recno da Fatura posicionada

@author Bruno Ritter | Abner Fogaça de Oliveira
@since 23/04/2020
/*/
//-------------------------------------------------------------------
Function JurTitFat(aChaveSE1, nRecnoNXA)
	Local aArea      := GetArea()
	Local nI         := 0
	Local aNXAValor  := {}
	Local aOHTValor  := {}
	Local nDescNXA   := 0
	Local nPosHon    := 1
	Local nPosDesTot := 2
	Local nPosDesRem := 3
	Local nPosDesTri := 4
	Local nPosTxAdm  := 5
	Local nPosGross  := 6
	Local nValTotFt  := 0
	Local nValTit    := 0
	Local aValSaldo  := {}
	Local aVlBaseFt  := {}
	Local lUltParc   := .F.
	Local nLenSE1    := Len(aChaveSE1)
	Local lCpoGrsHon := NXA->(ColumnPos("NXA_VGROSH")) > 0 .And. NXC->(ColumnPos("NXC_VGROSH")) > 0 // @12.1.2310

	SE1->(DbSetOrder(1)) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	NXA->(DbGoTo(nRecnoNXA))
	
	aAdd(aNXAValor, NXA->NXA_VLFATH + NXA->NXA_VLACRE + IIF(lCpoGrsHon, NXA->NXA_VGROSH, 0))
	aAdd(aNXAValor, NXA->NXA_VLFATD)
	aAdd(aNXAValor, NXA->NXA_VLREMB)
	aAdd(aNXAValor, NXA->NXA_VLTRIB)
	aAdd(aNXAValor, NXA->NXA_VLTXAD)
	aAdd(aNXAValor, NXA->NXA_VLGROS)

	nDescNXA := NXA->NXA_VLDESC

	// Retira os descontos da Fatura
	If nDescNXA > 0
		aVlBaseFt := aClone(aNXAValor)
		nValTotFt := aVlBaseFt[1] + aVlBaseFt[2]
		JDivDescon(aVlBaseFt, @aNXAValor, nDescNXA, nValTotFt)
		JurFreeArr(@aVlBaseFt)
	EndIf

	aValSaldo := aClone(aNXAValor)

	For nI := 1 To nLenSE1
	
		If SE1->(DbSeek(aChaveSE1[nI]))
			lUltParc := nI == nLenSE1
			nValTit  := SE1->E1_VALOR

			aOHTValor := JDivTitFat(aNXAValor, @aValSaldo, nValTit, lUltParc)
			
			RecLock("OHT", .T.)
			OHT->OHT_FILIAL  := xFilial("OHT")
			OHT->OHT_FILFAT  := NXA->NXA_FILIAL
			OHT->OHT_FTESCR  := NXA->NXA_CESCR
			OHT->OHT_CFATUR  := NXA->NXA_COD
			OHT->OHT_FILTIT  := SE1->E1_FILIAL
			OHT->OHT_PREFIX  := SE1->E1_PREFIXO
			OHT->OHT_TITNUM  := SE1->E1_NUM
			OHT->OHT_TITPAR  := SE1->E1_PARCELA
			OHT->OHT_TITTPO  := SE1->E1_TIPO
			OHT->OHT_VLFATH  := aOHTValor[nPosHon]
			OHT->OHT_VLFATD  := aOHTValor[nPosDesTot]
			OHT->OHT_VLREMB  := aOHTValor[nPosDesRem]
			OHT->OHT_VLTRIB  := aOHTValor[nPosDesTri]
			OHT->OHT_VLTXAD  := aOHTValor[nPosTxAdm]
			OHT->OHT_VLGROS  := aOHTValor[nPosGross]
			OHT->OHT_ABATIM  := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,,;
										SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO, SE1->E1_TIPO)
			OHT->(MsUnLock())

		EndIf
	Next nI

	RestArea(aArea)
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDivTitFat
Realiza o rateio de valores de honorários e despesas para cada título da fatura

@param aValBase  valores originais da fatura
@param aValSaldo valores da fatura para abatimento durante rateio tabela OHT
@param nTotTit   valor total do título
@param lUltParc  Indica se é última parcela do título

@author Bruno Ritter | Abner Fogaça de Oliveira
@since 23/04/2020
/*/
//-------------------------------------------------------------------
Static Function JDivTitFat(aValBase, aValSaldo, nTotTit, lUltParc)
	Local aValDiv     := {0, 0, 0, 0, 0, 0}
	Local nPosHon     := 1
	Local nPosDesTot  := 2
	Local nPosDesRem  := 3
	Local nPosDesTri  := 4
	Local nPosTxAdm   := 5
	Local nPosGross   := 6
	Local nI          := 0
	Local nTotalTrib  := 0
	Local nSaldo      := nTotTit
	Local lPrioDesp   := SuperGetMv('MV_JTPRIO',, '1') == '1' //1-Prioriza despesas 2-Proporcional
	Local nValTotFt   := 0

	If lPrioDesp
		aValDiv[nPosDesRem]  += IIF(aValSaldo[nPosDesRem] > nSaldo, nSaldo, aValSaldo[nPosDesRem])
		nSaldo -= aValDiv[nPosDesRem]

		If nSaldo > 0 // Proporcionaliza Despesas Tributaveis, Taxa Adm e Gross Up
			nTotalTrib := aValSaldo[nPosDesTri] + aValSaldo[nPosTxAdm] + aValSaldo[nPosGross]

			If nSaldo > nTotalTrib
				aValDiv[nPosDesTri] += aValSaldo[nPosDesTri]
				aValDiv[nPosTxAdm]  += aValSaldo[nPosTxAdm]
				aValDiv[nPosGross]  += aValSaldo[nPosGross]
			Else
				aValDiv[nPosDesTri] += nSaldo * (aValSaldo[nPosDesTri] / nTotalTrib)
				aValDiv[nPosTxAdm]  += nSaldo * (aValSaldo[nPosTxAdm]  / nTotalTrib)
				aValDiv[nPosGross]  += nSaldo * (aValSaldo[nPosGross]  / nTotalTrib)
			EndIf

			nSaldo -= aValDiv[nPosDesTri]
			nSaldo -= aValDiv[nPosTxAdm]
			nSaldo -= aValDiv[nPosGross]
		EndIf

		aValDiv[nPosHon]  += IIF(aValSaldo[nPosHon] > nSaldo, nSaldo, aValSaldo[nPosHon])
		nSaldo -= aValDiv[nPosHon]

		aValDiv[nPosHon]    := Round(aValDiv[nPosHon]   , 2)
		aValDiv[nPosDesRem] := Round(aValDiv[nPosDesRem], 2)
		aValDiv[nPosDesTri] := Round(aValDiv[nPosDesTri], 2)
		aValDiv[nPosTxAdm]  := Round(aValDiv[nPosTxAdm] , 2)
		aValDiv[nPosGross]  := Round(aValDiv[nPosGross] , 2)

	Else
		nValTotFt           := aValBase[nPosHon] + aValBase[nPosDesTot] // Valor total da fatura
		aValDiv[nPosDesRem] := RatPontoFl(aValBase[nPosDesRem], nValTotFt, nTotTit, TamSX3("OHT_VLREMB")[2])
		aValDiv[nPosDesRem] := IIf(aValDiv[nPosDesRem] > aValBase[nPosDesRem], aValBase[nPosDesRem], aValDiv[nPosDesRem])
		aValDiv[nPosDesTri] := RatPontoFl(aValBase[nPosDesTri], nValTotFt, nTotTit, TamSX3("OHT_VLTRIB")[2])
		aValDiv[nPosDesTri] := IIf(aValDiv[nPosDesTri] > aValBase[nPosDesTri], aValBase[nPosDesTri], aValDiv[nPosDesTri])
		aValDiv[nPosTxAdm]  := RatPontoFl(aValBase[nPosTxAdm] , nValTotFt, nTotTit, TamSX3("OHT_VLTXAD")[2])
		aValDiv[nPosTxAdm]  := IIf(aValDiv[nPosTxAdm] > aValBase[nPosTxAdm], aValBase[nPosTxAdm], aValDiv[nPosTxAdm])
		aValDiv[nPosGross]  := RatPontoFl(aValBase[nPosGross] , nValTotFt, nTotTit, TamSX3("OHT_VLGROS")[2])
		aValDiv[nPosGross]  := IIf(aValDiv[nPosGross] > aValBase[nPosGross], aValBase[nPosGross], aValDiv[nPosGross])
		aValDiv[nPosHon]    := nValTotFt - aValDiv[nPosDesRem] - aValDiv[nPosDesTri] - aValDiv[nPosTxAdm] - aValDiv[nPosGross]
	EndIf
	
	aValDiv[nPosDesTot] := aValDiv[nPosDesRem] + aValDiv[nPosDesTri] + aValDiv[nPosTxAdm] + aValDiv[nPosGross]

	For nI := 1 To Len(aValDiv)
		aValSaldo[nI] -= aValDiv[nI]
	Next nI

	AjustDiv(@aValSaldo, @aValDiv, nTotTit, lUltParc)

Return aValDiv

//-------------------------------------------------------------------
/*/{Protheus.doc} JDivDescon
Realiza o rateio de valores de honorários e despesas para
um determinado valor de desconto

@author Bruno Ritter | Cristina Cintra
@since 29/04/2020
/*/
//-------------------------------------------------------------------
Static Function JDivDescon(aValBase, aValSaldo, nTotTit, nTotFat)
	Local aValDiv    := {0, 0, 0, 0, 0, 0}
	Local nPosHon    := 1
	Local nPosDesTot := 2
	Local nPosDesRem := 3
	Local nPosDesTri := 4
	Local nPosTxAdm  := 5
	Local nPosGross  := 6
	Local nI         := 0
	Local nTotalTrib := 0
	Local nSaldo     := nTotTit

	// Distribui Honorarios
	aValDiv[nPosHon]  += IIF(aValSaldo[nPosHon] > nSaldo, nSaldo, aValSaldo[nPosHon])
	nSaldo -= aValDiv[nPosHon]

	// Distribui Despesa Tributaveis
	If nSaldo > 0 // Proporcionaliza Despesas Tributaveis, Taxa Adm e Gross Up
		nTotalTrib := aValSaldo[nPosDesTri] + aValSaldo[nPosTxAdm] + aValSaldo[nPosGross]

		If nSaldo > nTotalTrib
			aValDiv[nPosDesTri] += aValSaldo[nPosDesTri]
			aValDiv[nPosTxAdm]  += aValSaldo[nPosTxAdm]
			aValDiv[nPosGross]  += aValSaldo[nPosGross]
		Else
			aValDiv[nPosDesTri] += nSaldo * (aValSaldo[nPosDesTri] / nTotalTrib)
			aValDiv[nPosTxAdm]  += nSaldo * (aValSaldo[nPosTxAdm]  / nTotalTrib)
			aValDiv[nPosGross]  += nSaldo * (aValSaldo[nPosGross]  / nTotalTrib)
		EndIf

		nSaldo -= aValDiv[nPosDesTri]
		nSaldo -= aValDiv[nPosTxAdm]
		nSaldo -= aValDiv[nPosGross]
	EndIf

	// Distribui Despesa Reembolsaveis
	aValDiv[nPosDesRem]  += IIF(aValSaldo[nPosDesRem] > nSaldo, nSaldo, aValSaldo[nPosDesRem])
	nSaldo -= aValDiv[nPosDesRem]
	
	aValDiv[nPosDesTot] := aValDiv[nPosDesRem] + aValDiv[nPosDesTri] + aValDiv[nPosTxAdm] + aValDiv[nPosGross]

	For nI := 1 To Len(aValDiv)
		aValSaldo[nI] -= aValDiv[nI]
	Next nI

Return aValDiv

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustDiv
Ajusta o arredondamento dos valores divididos sobre o total do título

@param aValSaldo valores da fatura para abatimento durante rateio tabela OHT
@param aValDiv   valores de honorários e despesas rateados do título
@param nTotTit   valor total do título
@param lUltParc  Indica se é última parcela do título

@author Bruno Ritter | Abner Fogaça de Oliveira
@since 23/04/2020
/*/
//-------------------------------------------------------------------
Static Function AjustDiv(aValSaldo, aValDiv, nTotTit, lUltParc)
	Local nTotalDiv  := 0
	Local nDifCentav := 0
	Local nPosHon    := 1
	Local nPosDesTot := 2
	Local nPosDesRem := 3
	Local nPosDesTri := 4
	Local nPosTxAdm  := 5
	Local nPosGross  := 6
	Local nDifSaldo  := 0
	Local nI         := 0

	nTotalDiv  := aValDiv[nPosHon] + aValDiv[nPosDesTot]
	nDifCentav := Abs(nTotalDiv - nTotTit) * 100

	For nI := 1 to nDifCentav
		If nTotalDiv > nTotTit
			If aValDiv[nPosHon] > 0
				aValDiv[nPosHon] -= 0.01
				aValSaldo[nPosHon] += 0.01

			ElseIf aValDiv[nPosDesTot] > 0
				aValDiv[nPosDesTot] -= 0.01
				aValSaldo[nPosDesTot] += 0.01

				If aValDiv[nPosDesTri] > 0
					aValDiv[nPosDesTri]  -= 0.01
					aValSaldo[nPosDesTri] += 0.01

				ElseIf aValDiv[nPosTxAdm] > 0
					aValDiv[nPosTxAdm]  -= 0.01
					aValSaldo[nPosTxAdm] += 0.01

				ElseIf aValDiv[nPosGross] > 0
					aValDiv[nPosGross]  -= 0.01
					aValSaldo[nPosGross] += 0.01

				ElseIf aValDiv[nPosDesRem] > 0
					aValDiv[nPosDesRem]  -= 0.01
					aValSaldo[nPosDesRem] += 0.01
				EndIf
			EndIf

		ElseIf nTotTit > nTotalDiv
			If aValSaldo[nPosDesTot] > 0
				aValDiv[nPosDesTot]  += 0.01
				aValSaldo[nPosDesTot] -= 0.01

				If aValSaldo[nPosDesRem] > 0
					aValDiv[nPosDesRem]  += 0.01
					aValSaldo[nPosDesRem] -= 0.01

				ElseIf aValSaldo[nPosDesTri] > 0
					aValDiv[nPosDesTri]  += 0.01
					aValSaldo[nPosDesTri] -= 0.01
				
				ElseIf aValSaldo[nPosTxAdm] > 0
					aValDiv[nPosTxAdm]  += 0.01
					aValSaldo[nPosTxAdm] -= 0.01

				ElseIf aValSaldo[nPosGross] > 0
					aValDiv[nPosGross]  += 0.01
					aValSaldo[nPosGross] -= 0.01
				EndIf

			ElseIf aValSaldo[nPosHon] > 0
				aValDiv[nPosHon]  += 0.01
				aValSaldo[nPosHon] -= 0.01
			EndIf
		EndIf
	Next nI

	If lUltParc
		For nI := 1 To Len(aValSaldo)
			nDifSaldo := aValSaldo[nI]
			aValDiv[nI] += nDifSaldo
			aValSaldo[nI] -= nDifSaldo
		Next nI
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurGrvOHT
Gravação na tabela OHT (Relacionamento Faturas x Títulos) a partir
da liquidação (FA460GRV).

@param  cFilLiq , Filial da liquidação
@param  cCodLiq , Código da liquidação
@param  cCliente, Cliente da liquidação
@param  cLoja   , Loja da liquidação

@author Cristina Cintra / Bruno Ritter
@since  23/04/2020
/*/
//-------------------------------------------------------------------
Function JurGrvOHT(cFilLiq, cCodLiq, cCliente, cLoja)
Local aArea        := GetArea()
Local nTitSel      := 0
Local nTitGer      := 0
Local nFatura      := 0
Local aFaturas     := {}
Local aTitLiq      := {}
Local aTitGer      := {}
Local aVlBaseFt    := {}
Local aValSaldo    := {}
Local aOHTValor    := {}
Local aFatSemImp   := {}
Local lUltParc     := .F.
Local nValTotFt    := 0
Local nTotPrcTit   := 0
Local nValBxLiq    := 0
Local nToTitNovo   := 0
Local nTotBaseFt   := 0
Local nAcrePrc     := 0
Local nAcreAntPrc  := 0
Local nDescPrc     := 0
Local lBxParc      := .F.
Local lReliq       := .F.
Local nAcrescimo   := 0
Local nAcreAnt     := 0
Local nAcreUti     := 0
Local nAcreAntUti  := 0
Local nImpTotTit   := 0
Local nImpFat      := 0
Local nImpOHT      := 0
Local nImpTitNovo  := 0
Local nImpUsado    := 0 
Local nTamE1Valor  := TamSX3("E1_VALOR")[2]
Local nTamOHTAcre  := TamSX3("OHT_ACRESC")[2]
Local nTamOHTAbat  := TamSX3("OHT_ABATIM")[2]

// Verifica na SE5 os títulos liquidados
aTitLiq := JurBusLiq(cFilLiq, cCodLiq)

// Verifica as faturas envolvidas na liquidação
For nTitSel := 1 To Len(aTitLiq)
	JurBusFat(@aFaturas, aTitLiq[nTitSel])
Next nTitSel

If Len(aFaturas) > 0
	// Verifica na SE1 os títulos gerados pela liquidação
	aTitGer := JurBusTit(cFilLiq, cCodLiq)
	aEval(aTitGer,  {|aX| nToTitNovo += aX[6], nImpTitNovo += aX[10], }) // nToTitNovo = Total do título novo gerado pela liquidação - nImpTitNovo = Total de impostos do título novo gerado pela liquidação

	lReliq := aScan(aTitLiq, { |aLiq| !Empty(aLiq[11]) }) > 0

	For nFatura := 1 To Len(aFaturas)
		
		nValTotFt   := aFaturas[nFatura][4] + aFaturas[nFatura][5] // Valor total da fatura --> Honorários + Despesas
		nValBxLiq   := aFaturas[nFatura][10]    // Valor líquido da Baixa
		nAcrePrc    := aFaturas[nFatura][13]    // Acréscimo na FO1
		nDescPrc    := aFaturas[nFatura][12][7] // Desconto na FO1
		lBxParc     := aFaturas[nFatura][14]    // Indica se é uma baixa parcial
		nAcreAntPrc := aFaturas[nFatura][16]    // Acréscimo na FO1 de liquidações anteriores (usado nas reliquidações)

		IIf(aFaturas[nFatura][15] == 0, aAdd(aFatSemImp, aFaturas[nFatura]), Nil) // Cria um array novo só com faturas sem impostos

		// Limpa variáveis de controle de acréscimos
		nAcrescimo := 0
		nAcreUti   := 0

		//If lReliq .And. !lBxParc
		//	nValBxLiq := nValTotFt - nDescPrc
		//Else
			nValBxLiq -= nAcrePrc // Retira os acréscimos, pois não serão considerados na OHT
		//EndIf
		
		aVlBaseFt  := JurVlBxCmp(nValBxLiq, aFaturas[nFatura], lBxParc)
		aValSaldo  := aClone(aVlBaseFt)
		nTotBaseFt := aVlBaseFt[1] + aVlBaseFt[2]

		// Cria os registros da OHT para os títulos gerados, considerando também as faturas encontradas
		For nTitGer := 1 To Len(aTitGer)
			
			lUltParc   := nTitGer == Len(aTitGer)
			nTotPrcTit := Round((nTotBaseFt / nToTitNovo) * aTitGer[nTitGer][6], nTamE1Valor)
			
			aOHTValor  := JDivTitFat(aVlBaseFt, @aValSaldo, nTotPrcTit, lUltParc)

			If nAcrePrc > 0 // Tratamento para acréscimos feitos na liquidação
				If lUltParc
					nAcrescimo := nAcrePrc - nAcreUti
				Else
					nAcrescimo := RatPontoFl(nTotPrcTit, nTotBaseFt, nAcrePrc, nTamOHTAcre)
					nAcreUti   += nAcrescimo
				EndIf
			EndIf

			If nAcreAntPrc > 0 // Tratamento para acréscimos de liquidações anteriores
				If lUltParc
					nAcreAnt := nAcreAntPrc - nAcreAntUti
				Else
					nAcreAnt    := RatPontoFl(nTotPrcTit, nTotBaseFt, nAcreAntPrc, nTamOHTAcre)
					nAcreAntUti += nAcreAnt
				EndIf
			EndIf

			If Len(aFaturas) == 1 // Fatura única, todo o imposto do título vai para ela sem precisar proporcionalizar
				nImpOHT := aTitGer[nTitGer][10]
			Else
				nImpOHT := 0
				nImpFat := aFaturas[nFatura][15] // Total de imposto da fatura liquidada

				If nImpFat > 0 // Verifica se a fatura liquidada contém valor de imposto

					// Proporção do valor de imposto da fatura, sobre o imposto total das faturas liquidadas
					// Ex: Estão sendo liquidadas 3 faturas com impostos, que juntas geram um total de R$ 1000 de imposto
					//     nImpFat     --> Terá o valor de imposto da fatura que o "Laço" está percorrendo (Ex. R$ 200 referente a Fatura 1)
					//     nImpTotTit  --> Terá o valor de imposto do título gerado pela liquidação que o "Laço" está percorrendo (que pode ser parcelado). (Ex. R$ 500 referente a parcela A)
					//     nImpTitNovo --> Terá o valor total de imposto total do(s) título(s) gerado pela liquidação (Ex. R$ 1000)
					//     nImpOHT     --> Terá o valor de imposto do título gerado pela liquidação proporcional à fatura que o "Laço" está percorrendo.
					//                     Por exemplo, a liquidação gerou títulos parcelados.
					//                     Parcela A - R$ 500 de imposto
					//                     Parcela B - R$ 300 de imposto
					//                     Parcela C - R$ 200 de imposto
					//                     Estamos gerando a OHT para a parcela A. Então o nImpOHT será:
					//                     A proporção entre o imposto da parcela sobre o total de imposto (500/1000, ou seja, 0,5),
					//                     multiplicado pelo valor da fatura que o "Laço" está percorrendo (R$ 200)

					nImpTotTit  := aTitGer[nTitGer][10] // Total de imposto do título gerado pela liquidação
					nImpOHT     := RatPontoFl(nTotBaseFt, nToTitNovo, nImpTotTit, nTamOHTAbat) // Aplica a proporção da fatura sobre o valor de impostos do título
					nImpOHT     := IIf(nImpOHT < nImpFat, nImpOHT, nImpFat) // Garante que o valor de imposto calculado não seja maior que o valor de imposto original da fatura

					nImpUsado += nImpOHT // Valores de impostos distribuídos na OHT
				
				EndIf
			EndIf

			RecLock("OHT", .T.)
			OHT->OHT_FILFAT  := aFaturas[nFatura][1]
			OHT->OHT_FTESCR  := aFaturas[nFatura][2]
			OHT->OHT_CFATUR  := aFaturas[nFatura][3]
			OHT->OHT_FILTIT  := aTitGer[nTitGer][1]
			OHT->OHT_PREFIX  := aTitGer[nTitGer][2]
			OHT->OHT_TITNUM  := aTitGer[nTitGer][3]
			OHT->OHT_TITPAR  := aTitGer[nTitGer][4]
			OHT->OHT_TITTPO  := aTitGer[nTitGer][5]
			OHT->OHT_FILLIQ  := cFilLiq
			OHT->OHT_NUMLIQ  := cCodLiq
			OHT->OHT_VLFATH  := aOHTValor[1]
			OHT->OHT_VLFATD  := aOHTValor[2]
			OHT->OHT_VLREMB  := aOHTValor[3]
			OHT->OHT_VLTRIB  := aOHTValor[4]
			OHT->OHT_VLTXAD  := aOHTValor[5]
			OHT->OHT_VLGROS  := aOHTValor[6]
			OHT->OHT_ABATIM  := nImpOHT
			OHT->OHT_ACRESC  := nAcrescimo + nAcreAnt // Acréscimo da liquidação atual + Acréscimos de liquidações anteriores
			OHT->(MsUnLock())

			JurFreeArr(@aOHTValor)
		Next nTitSel

		JurFreeArr(@aVlBaseFt)

	Next nFatura

	// Verifica se existem faturas que não tinham impostos que foram liquidadas com uma natureza que gera impostos
	If Len(aFatSemImp) > 0 .And. nImpTitNovo > 0
		// Faz o ajuste no campo OHT_ABATIM nos registros de faturas (que inicialmente não tinham impostos) que foram liquidadas usando natureza que gera imposto. 
		JAjuImpFat(aFatSemImp, aTitGer, nImpTitNovo, nImpTitNovo - nImpUsado)
	EndIf

	For nTitGer := 1 To Len(aTitGer) // Inclusão da OHH para o(s) título(s) novo(s)
		JIncTitCR(aTitGer[nTitGer][9], dDatabase)
	Next
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBusFat
Retorna as faturas relacionadas ao título informado.

@param aFaturas    Array para preenchimento das faturas liquidadas
@param aTitLiq     Array com os títulos liquidados

@return aFaturas   Array recebido por parâmetro e preenchido 
                   com os dados das faturas relacionadas ao título

@author Cristina Cintra / Bruno Ritter
@since 23/04/2020
/*/
//-------------------------------------------------------------------
Static Function JurBusFat(aFaturas, aTitLiq)
Local cFilTit    := aTitLiq[1]
Local cPrefixo   := aTitLiq[2]
Local cNumTit    := aTitLiq[3]
Local cParcela   := aTitLiq[4]
Local cTipo      := aTitLiq[5]
Local nValBxLiq  := aTitLiq[6]
Local nVlTotBx   := aTitLiq[7]
Local nValTit    := aTitLiq[8]
Local nDesconto  := aTitLiq[9]
Local nAcrescimo := aTitLiq[10]
Local nValAcess  := aTitLiq[12] // Valor acessório
Local lBxParc    := nValTit > nVlTotBx
Local nPosFat    := 0
Local nBxAntPrc  := 0
Local nBxLiqPrc  := 0
Local nAcrAntPrc := 0
Local nAcreBxAnt := 0
Local nValTotFt  := 0
Local nBaixaAnt  := 0
Local nDescPrc   := 0
Local nAcrePrc   := 0
Local nSomaAbat  := 0
Local nValTitOHT := 0
Local nOHT       := 0
Local nOHTVlFatH := 0
Local nOHTVlFatD := 0
Local nOHTVlRemb := 0
Local nOHTVlTrib := 0
Local nOHTVlTxAd := 0
Local nOHTVlGros := 0
Local nOHTAbatim := 0
Local nOHTAcresc := 0
Local nDecimal   := TamSX3("E1_VALOR")[2]
Local aDadosSE1  := {}
Local aOHT       := {}
Local cQueryOHT  := ""
Local cOHTFilFat := ""
Local cOHTFtEscr := ""
Local cOHTCFatur := ""
Local lPrioDesp  := SuperGetMv('MV_JTPRIO',, '1') == '1' // 1-Prioriza despesas 2-Proporcional

	If nValAcess > 0
		nAcrescimo += nValAcess
	Else
		nDesconto  += Abs(nValAcess)
	EndIf

	// Tratamento para se tiver acréscimos e descontos, zerar o menor deles e abater essa diferença
	If nAcrescimo >= nDesconto // Se o acréscimo for maior que o desconto
		nAcrescimo := nAcrescimo - nDesconto // Abate o desconto do acréscimo
		nDesconto := 0                       // E zera o desconto
	Else                       // Se o desconto for maior que o acréscimo
		nDesconto := nDesconto - nAcrescimo // Abate o acréscimo do desconto
		nAcrescimo := 0                     // E zera o acréscimo
	EndIf

	cQueryOHT := " SELECT OHT_FILFAT, OHT_FTESCR, OHT_CFATUR, OHT_VLFATH, OHT_VLFATD, "
	cQueryOHT +=        " OHT_VLREMB, OHT_VLTRIB, OHT_VLTXAD, OHT_VLGROS, OHT_ABATIM, "
	cQueryOHT +=        " OHT_ACRESC "
	cQueryOHT +=   " FROM " + RetSqlName("OHT") + " OHT "
	cQueryOHT +=  " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT") + "'"
	cQueryOHT +=    " AND OHT.OHT_FILTIT = '" + cFilTit  + "'"
	cQueryOHT +=    " AND OHT.OHT_PREFIX = '" + cPrefixo + "'"
	cQueryOHT +=    " AND OHT.OHT_TITNUM = '" + cNumTit  + "'"
	cQueryOHT +=    " AND OHT.OHT_TITPAR = '" + cParcela + "'"
	cQueryOHT +=    " AND OHT.OHT_TITTPO = '" + cTipo    + "'"
	cQueryOHT +=    " AND OHT.D_E_L_E_T_ = ' '"

	aOHT := JurSQL(cQueryOHT, "*")

	If Len(aOHT) > 0
		aEval(aOHT, {|aX| nValTitOHT += aX[4] + aX[5]}) // Valor total do título salvo na OHT (considera os descontos e desconsidera acréscimos)

		For nOHT := 1 To Len(aOHT)
			cOHTFilFat := aOHT[nOHT][1]
			cOHTFtEscr := aOHT[nOHT][2]
			cOHTCFatur := aOHT[nOHT][3]
			nOHTVlFatH := aOHT[nOHT][4]
			nOHTVlFatD := aOHT[nOHT][5]
			nOHTVlRemb := aOHT[nOHT][6]
			nOHTVlTrib := aOHT[nOHT][7]
			nOHTVlTxAd := aOHT[nOHT][8]
			nOHTVlGros := aOHT[nOHT][9]
			nOHTAbatim := aOHT[nOHT][10]
			nOHTAcresc := aOHT[nOHT][11] // Usado para considerar os acréscimos da liquidação anterior à reliquidação

			nPosFat := AScan(aFaturas, {|aFat| aFat[1] + aFat[2] + aFat[3] == cOHTFilFat + cOHTFtEscr + cOHTCFatur})

			nBaixaAnt := nVlTotBx - nValBxLiq - nDesconto + nAcrescimo
		
			// Verifica se o nBaixaAnt ficou somente com valor de impostos
			// Isso ocorrerá quando os títulos liquidados tiverem impostos, porém os novos sejam para uma natureza que não calcula impostos.
			If nBaixaAnt <> 0
				aDadosSE1 := JurGetDados("SE1", 1, cFilTit + cPrefixo + cNumTit + cParcela + cTipo, {"E1_CLIENTE", "E1_LOJA", "E1_EMISSAO"})
				If Len(aDadosSE1) > 0
					nSomaAbat := SomaAbat(cPrefixo, cNumTit, cParcela, "R", 1,, aDadosSE1[1], aDadosSE1[2], cFilTit, aDadosSE1[3])
					If nBaixaAnt == nSomaAbat
						nBaixaAnt := 0
					EndIf
				EndIf
			EndIf

			nValTotFt  := nOHTVlFatH + nOHTVlFatD
			nBxAntPrc  := Round((nValTotFt / nValTitOHT) * nBaixaAnt , nDecimal)
			nDescPrc   := Round((nValTotFt / nValTitOHT) * nDesconto , nDecimal)
			nAcrePrc   := Round((nValTotFt / nValTitOHT) * nAcrescimo, nDecimal) // Acréscimo na liquidação atual
			nBxLiqPrc  := Round((nValTotFt / nValTitOHT) * nValBxLiq , nDecimal)
			nAcrAntPrc := Round((nValTotFt / nValTitOHT) * nOHTAcresc, nDecimal) // Acréscimo de liquidações anteriores

			If nBaixaAnt > nValTotFt .And. nOHTAcresc > 0 // Indica que na baixa anterior a reliquidação, o valor da baixa consumiu os acréscimos
				nAcreBxAnt := Round((nValTotFt / nValTitOHT) * (nBaixaAnt - nValTotFt), nDecimal) // Valor de acréscimos considerados nas baixas anteriores a reliquidação
				nAcrAntPrc -= nAcreBxAnt // Subtraí os acréscimos que já foram baixados.
			EndIf

			// Se houver acréscimos de liquidações anteriores e descontos na atual
			// Abate o desconto nos acréscimos antes de aplicar o desconto nos honorários/despesas conforme as regras abaixo
			If nAcrAntPrc > 0 .And. nDescPrc > 0
				If nDescPrc <= nAcrAntPrc     // Se o desconto atual for menor ou igual aos acréscimos de liquidações anteriores
					nAcrAntPrc -= nDescPrc    // abate o desconto direto do acréscimo
					nDescPrc   := 0           // e zera o desconto

				Else                          // Se o desconto atual for maior que acréscimos de liquidações anteriores
					nDescPrc   -= nAcrAntPrc  // abate esse acréscimo no desconto
					nAcrAntPrc := 0           // e zera os acréscimos de liquidações anteriores
				EndIf
			EndIf

			If nPosFat == 0 // Zera os valores para cálculo das novas faturas
				_aDistBxAnt := {0, 0, 0, 0, 0, 0, 0}
				_aDistDesc  := {0, 0, 0, 0, 0, 0, 0}
			EndIf

			// Distribui os valores de baixas anteriores e descontos entre despesas e honorários, conforme parcelas
			JDistBxDes(nBxAntPrc, nDescPrc, nOHTVlRemb, nOHTVlTrib, nOHTVlTxAd, nOHTVlGros, nOHTVlFatH, lPrioDesp)

			If nPosFat == 0
				Aadd(aFaturas, {cOHTFilFat, cOHTFtEscr, cOHTCFatur, nOHTVlFatH, nOHTVlFatD, ;
				                nOHTVlRemb, nOHTVlTrib, nOHTVlTxAd, nOHTVlGros, ;
				                nBxLiqPrc , _aDistBxAnt, _aDistDesc, nAcrePrc , lBxParc, nOHTAbatim, nAcrAntPrc})
			Else
				aFaturas[nPosFat][4]  += nOHTVlFatH
				aFaturas[nPosFat][5]  += nOHTVlFatD
				aFaturas[nPosFat][6]  += nOHTVlRemb
				aFaturas[nPosFat][7]  += nOHTVlTrib
				aFaturas[nPosFat][8]  += nOHTVlTxAd
				aFaturas[nPosFat][9]  += nOHTVlGros
				aFaturas[nPosFat][10] += nBxLiqPrc
				aFaturas[nPosFat][11] := _aDistBxAnt
				aFaturas[nPosFat][12] := _aDistDesc
				aFaturas[nPosFat][13] += nAcrePrc
				aFaturas[nPosFat][14] := lBxParc
				aFaturas[nPosFat][15] += nOHTAbatim
				aFaturas[nPosFat][16] += nAcrAntPrc
			EndIf
		Next
	EndIf

Return aFaturas

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVlBxCmp
Proporcionaliza descontos e baixas anteriores.

@param nValBxLiq    Valor que está sendo baixado pela liquidação
@param aFaturas     Array com os dados das faturas relacionadas aos títulos
@param lBxParc      Indica se os títulos liquidados sofrerão somente 
                    uma baixa parcial

@return aOHTValor   Array com os valores proporcionalizados para OHT

@author Cristina Cintra / Bruno Ritter
@since  28/04/2020
/*/
//-------------------------------------------------------------------
Static Function JurVlBxCmp(nValBxLiq, aFaturas, lBxParc)
Local aVlBaseFt  := {aFaturas[4], aFaturas[5], aFaturas[6], aFaturas[7], aFaturas[8], aFaturas[9]}
Local aValSaldo  := aClone(aVlBaseFt)
Local aOHTValor  := {}

Local aBxAntPrc := aFaturas[11] // Valor de baixas anteriores distribuidos entre despesas e honorários, conforme parcelas
Local aDescPrc  := aFaturas[12] // Valor de desconto distribuidos entre despesas e honorários, conforme parcelas
Local nBxAntPrc := aFaturas[11][7] // Valor total de baixas anteriores
Local nDescPrc  := aFaturas[12][7] // Valor total de desconto

// Simulação das baixas anteriores
If nBxAntPrc > 0
	aValSaldo[1] -= aBxAntPrc[1]
	aValSaldo[2] -= aBxAntPrc[2]
	aValSaldo[3] -= aBxAntPrc[3]
	aValSaldo[4] -= aBxAntPrc[4]
	aValSaldo[5] -= aBxAntPrc[5]
	aValSaldo[6] -= aBxAntPrc[6]
EndIf

// Simula os descontos
If nDescPrc > 0
	aValSaldo[1] -= aDescPrc[1]
	aValSaldo[2] -= aDescPrc[2]
	aValSaldo[3] -= aDescPrc[3]
	aValSaldo[4] -= aDescPrc[4]
	aValSaldo[5] -= aDescPrc[5]
	aValSaldo[6] -= aDescPrc[6]
EndIf

If lBxParc .Or. nBxAntPrc > 0 .Or. (nValBxLiq <> (aValSaldo[1] + aValSaldo[2])) //.Or. nDescPrc > 0
	// Valores gerados para a baixa da liquidação
	aVlBaseFt := aClone(aValSaldo)
	aOHTValor := JDivTitFat(aVlBaseFt, @aValSaldo, nValBxLiq, .F.)
Else
	aOHTValor := aClone(aValSaldo)
EndIf

Return aOHTValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBusLiq
Busca e retorna os títulos selecionados na liquidação, com base nas 
movimentações geradas (SE5).

@param cFilLiq     Filial da liquidação
@param cLiquida    Código da liquidação

@return aTitLiq    Array com os dados dos títulos selecionados na liquidação

@author Cristina Cintra
@since 25/04/2020
/*/
//-------------------------------------------------------------------
Static Function JurBusLiq(cFilLiq, cLiquida)
Local cQuery   := ""
Local aTitLiq  := {}
Local nTamLiq  := TamSx3("E5_DOCUMEN")[1]
// Define a filial das baixas dos titulos liquidados - 1= Filial do Processo (padrao) ou 2 = Filial do titulo
Local lFilLiq  := SuperGetMV("MV_FILLIQ", .F., "1") == "2"

cQuery := "SELECT SE5.E5_FILIAL FILIAL, SE5.E5_PREFIXO PREFIXO, SE5.E5_NUMERO NUM, "
cQuery +=       " SE5.E5_PARCELA PARC, SE5.E5_TIPO TIPO, SE5.E5_VALOR VALOR, "
cQuery +=       " SE1.E1_VALOR - SE1.E1_SALDO TOTBAIXA, SE1.E1_VALOR VALORSE1, SE1.E1_NUMLIQ NUMLIQ, "
cQuery +=       " (SELECT SUM(SE5DESC.E5_VALOR) "
cQuery +=          " FROM " + RetSqlName("SE5") + " SE5DESC "
cQuery +=         " WHERE SE5DESC.E5_FILIAL = SE1.E1_FILIAL "
cQuery +=           " AND SE5DESC.E5_PREFIXO = SE1.E1_PREFIXO "
cQuery +=           " AND SE5DESC.E5_NUMERO = SE1.E1_NUM "
cQuery +=           " AND SE5DESC.E5_PARCELA = SE1.E1_PARCELA "
cQuery +=           " AND SE5DESC.E5_TIPO = SE1.E1_TIPO "
cQuery +=           " AND SE5DESC.D_E_L_E_T_ = ' ' "
cQuery +=           " AND SE5DESC.E5_RECPAG = 'R' "
cQuery +=           " AND SE5DESC.E5_SITUACA <> 'C' "
cQuery +=           " AND SE5DESC.E5_DOCUMEN = SE5.E5_DOCUMEN "
cQuery +=           " AND SE5DESC.E5_TIPODOC = 'DC' "
cQuery +=         " GROUP BY SE5DESC.E5_PREFIXO, SE5DESC.E5_NUMERO, SE5DESC.E5_PARCELA, SE5DESC.E5_TIPO) DESCONTO, "
cQuery +=       " (SELECT SUM(SE5ACRE.E5_VALOR) "
cQuery +=          " FROM " + RetSqlName("SE5") + " SE5ACRE "
cQuery +=         " WHERE SE5ACRE.E5_FILIAL = SE1.E1_FILIAL "
cQuery +=           " AND SE5ACRE.E5_PREFIXO = SE1.E1_PREFIXO "
cQuery +=           " AND SE5ACRE.E5_NUMERO = SE1.E1_NUM "
cQuery +=           " AND SE5ACRE.E5_PARCELA = SE1.E1_PARCELA "
cQuery +=           " AND SE5ACRE.E5_TIPO = SE1.E1_TIPO "
cQuery +=           " AND SE5ACRE.D_E_L_E_T_ = ' ' "
cQuery +=           " AND SE5ACRE.E5_RECPAG = 'R' "
cQuery +=           " AND SE5ACRE.E5_SITUACA <> 'C' "
cQuery +=           " AND SE5ACRE.E5_DOCUMEN = SE5.E5_DOCUMEN "
cQuery +=           " AND SE5ACRE.E5_TIPODOC IN ('JR','MT') "
cQuery +=         " GROUP BY SE5ACRE.E5_PREFIXO, SE5ACRE.E5_NUMERO, SE5ACRE.E5_PARCELA, SE5ACRE.E5_TIPO) ACRESCIMO, "
cQuery +=       " (SELECT SUM(SE5ACESS.E5_VALOR) "
cQuery +=          " FROM " + RetSqlName("SE5") + " SE5ACESS "
cQuery +=         " WHERE SE5ACESS.E5_FILIAL = SE1.E1_FILIAL "
cQuery +=           " AND SE5ACESS.E5_PREFIXO = SE1.E1_PREFIXO "
cQuery +=           " AND SE5ACESS.E5_NUMERO = SE1.E1_NUM "
cQuery +=           " AND SE5ACESS.E5_PARCELA = SE1.E1_PARCELA "
cQuery +=           " AND SE5ACESS.E5_TIPO = SE1.E1_TIPO "
cQuery +=           " AND SE5ACESS.D_E_L_E_T_ = ' ' "
cQuery +=           " AND SE5ACESS.E5_RECPAG = 'R' "
cQuery +=           " AND SE5ACESS.E5_SITUACA <> 'C' "
cQuery +=           " AND SE5ACESS.E5_DOCUMEN = SE5.E5_DOCUMEN "
cQuery +=           " AND SE5ACESS.E5_TIPODOC IN ('VA') "
cQuery +=         " GROUP BY SE5ACESS.E5_PREFIXO, SE5ACESS.E5_NUMERO, SE5ACESS.E5_PARCELA, SE5ACESS.E5_TIPO) VALACESS "
cQuery +=    "FROM " + RetSqlName("SE5") + " SE5 "
cQuery +=  " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery +=        " ON ( SE1.E1_FILIAL = SE5.E5_FILORIG AND "
cQuery +=             " SE1.E1_PREFIXO = SE5.E5_PREFIXO AND "
cQuery +=             " SE1.E1_NUM = SE5.E5_NUMERO AND "
cQuery +=             " SE1.E1_PARCELA = SE5.E5_PARCELA AND "
cQuery +=             " SE1.E1_TIPO = SE5.E5_TIPO AND "
cQuery +=             " SE1.D_E_L_E_T_ = ' ' ) "
cQuery +=   " WHERE "
If !lFilLiq
	cQuery +=     " SE5.E5_FILIAL = '" + xFilial("SE5") + "' AND"
Else
	cQuery +=     " SE5.E5_FILIAL = '" + FWxFilial("SE5", cFilLiq) + "' AND"
EndIf
cQuery +=         " SE5.E5_DOCUMEN = '" + PadR(cLiquida, nTamLiq) + "' AND"
cQuery +=         " SE5.E5_RECPAG = 'R' AND"
cQuery +=         " SE5.E5_SITUACA <> 'C' AND"
cQuery +=         " SE5.E5_TIPODOC = 'BA' AND"
cQuery +=         " SE5.E5_MOTBX = 'LIQ' AND"
cQuery +=         " SE5.D_E_L_E_T_ = ' '"

aTitLiq := JurSQL(cQuery, {"FILIAL", "PREFIXO", "NUM", "PARC", "TIPO", "VALOR", "TOTBAIXA", "VALORSE1", "DESCONTO", "ACRESCIMO", "NUMLIQ", "VALACESS"})

Return aTitLiq

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBusTit
Busca e retorna os títulos gerados pela liquidação, com base na SE1.

@param cFilLiq     Filial da liquidação
@param cLiquida    Código da liquidação

@return aTitGer    Array com os dados dos títulos gerados pela liquidação

@author Cristina Cintra
@since 25/04/2020
/*/
//-------------------------------------------------------------------
Static Function JurBusTit(cFilLiq, cLiquida)
Local aArea    := GetArea()
Local aAreaSE1 := SE1->( GetArea() )
Local cQuery   := ""
Local aTitGer  := {}
Local nTit     := 0

cQuery := "SELECT SE1.E1_FILIAL FILIAL, SE1.E1_PREFIXO PREFIXO, SE1.E1_NUM NUM, "
cQuery +=       " SE1.E1_PARCELA PARC, SE1.E1_TIPO TIPO, SE1.E1_VALOR VALOR, SE1.E1_DECRESC DECRESC, "
cQuery +=       " SE1.E1_ACRESC + (SELECT SE1A.E1_VALOR VALOR "
cQuery +=                           "FROM " + RetSqlName("SE1") + " SE1A "
cQuery +=                         " WHERE SE1A.E1_FILIAL = '" + xFilial("SE1") + "' AND "
cQuery +=                               " SE1A.E1_NUMLIQ = '" + cLiquida + "' AND "
cQuery +=                               " SE1A.E1_TIPO   = 'NCC' AND "
cQuery +=                               " SE1A.D_E_L_E_T_ = ' ') ACRESC, SE1.R_E_C_N_O_ RECNO, 0 IMPOSTOS "
cQuery +=  " FROM " + RetSqlName("SE1") + " SE1 "
cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND "
cQuery +=       " SE1.E1_NUMLIQ = '" + cLiquida + "' AND "
cQuery +=       " SE1.E1_TIPO <> 'NCC' AND "
cQuery +=       " SE1.D_E_L_E_T_ = ' ' "

aTitGer := JurSQL(cQuery, {"FILIAL", "PREFIXO", "NUM", "PARC", "TIPO", "VALOR", "DECRESC", "ACRESC", "RECNO", "IMPOSTOS"})

SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

For nTit := 1 To Len(aTitGer)
	cChaveTit := aTitGer[nTit][1] + aTitGer[nTit][2] + aTitGer[nTit][3] + aTitGer[nTit][4] + aTitGer[nTit][5] // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	SE1->(DbSeek(cChaveTit))
	aTitGer[nTit][10] := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO)
Next

RestArea(aAreaSE1)
RestArea(aArea)

Return aTitGer

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur460Filt
Ponto que monta a query de filtro na tela de liquidação do financeiro
quando a integração está habilitada.

@param  cEscrit, caractere, Código do escritório digitado na tela
@param  cFatura, caractere, Código da fatura digitado na tela
@param  cFiltro, caractere, Query de filtro da liquidação

@return cFilter, caractere, Filtro do SIGAPFS

@author Jonatas Martins
@since  23/04/2020
@obs    Função chamada no fonte FINA460 na função A460ChecF()
/*/
//-------------------------------------------------------------------
Function Jur460Filt(cEscrit, cFatura, cFiltro)
Local lExistOHT  := AliasInDic("OHT")
Local cFilterLiq := ""
Local lFatUnica  := SuperGetMV("MV_JLIQRES",, .F.) // Paramêtro que indica se a liquidação será feita em uma única fatura (essa opção permitirá reliquidação)

Default cEscrit  := ""
Default cFatura  := ""
Default cFiltro  := ""

	If lExistOHT
		If lFatUnica .And. (Empty(cEscrit) .Or. Empty(cFatura))
			cFilterLiq += " AND E1_JURFAT = ' ' "
		Else
			cFilterLiq := JFilterOHT(cEscrit, cFatura)
		EndIf
	Else
		If Empty(cEscrit + cFatura)
			cFilterLiq += " AND E1_JURFAT = '' "
		Else
			cFilterLiq += " AND E1_JURFAT = '" + xFilial('NXA') + '-' + cEscrit + '-' + cFatura + '-' + cFilAnt + "' "
		EndIf
	EndIf

Return (cFilterLiq)

//-------------------------------------------------------------------
/*/{Protheus.doc} JFilterOHT
Monta filtro de títulos a receber relacionando com a tabela de 
relação entre Faturas x Títulos (OHT).

@param  cEscrit   , caractere, Código do escritório digitado na tela
@param  cFatura   , caractere, Código da fatura digitado na tela

@return cFilterOHT, caractere, Filtro do SIGAPFS

@author Jonatas Martins
@since  23/04/2020
/*/
//-------------------------------------------------------------------
Static Function JFilterOHT(cEscrit, cFatura)
	Local cFilterOHT := ""

	cFilterOHT += "AND EXISTS (SELECT 1 FROM " + RetSqlName("OHT") + " OHT"
	cFilterOHT +=             " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT") + "'"
	cFilterOHT +=               " AND OHT.OHT_FILTIT = SE1.E1_FILIAL"
	cFilterOHT +=               " AND OHT.OHT_PREFIX = SE1.E1_PREFIXO"
	cFilterOHT +=               " AND OHT.OHT_TITNUM = SE1.E1_NUM"
	cFilterOHT +=               " AND OHT.OHT_TITPAR = SE1.E1_PARCELA"
	cFilterOHT +=               " AND OHT.OHT_TITTPO = SE1.E1_TIPO"
	If !Empty(cEscrit)
		cFilterOHT +=           " AND OHT.OHT_FTESCR = '" + cEscrit + "'"
	EndIf
	If !Empty(cFatura)
		cFilterOHT +=           " AND OHT.OHT_CFATUR = '" + cFatura + "'"
	EndIf
	cFilterOHT +=               " AND OHT.D_E_L_E_T_ = ' ') "
	
Return (cFilterOHT)

//-------------------------------------------------------------------
/*/{Protheus.doc} JCancLiqCR
Função chamada após o cancelamento de uma liquidação no contas receber

@author Bruno Ritter | Cristina Cintra
@since 29/04/2020
/*/
//-------------------------------------------------------------------
Function JCancLiqCR(cFilLiq, cNumeroLiq)
Local aAreaSE1  := GetArea()
Local cChaveOHT := ""
Local cChaveNXM := ""
Local lNXMTitLiq := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33

	If Chkfile("OHT")
		cChaveOHT := xFilial("OHT") + cFilLiq + cNumeroLiq
		OHT->(DbSetOrder(3)) //OHT_FILIAL + OHT_FILLIQ + OHT_NUMLIQ
		
		If OHT->(DbSeek(cChaveOHT))
			While !OHT->(EOF()) .And. OHT->(OHT_FILIAL + OHT_FILLIQ + OHT_NUMLIQ) == cChaveOHT

				If lNXMTitLiq //@12.1.33
					cChaveNXM := xFilial("NXM") + OHT->(OHT_FILTIT + OHT_PREFIX + OHT_TITNUM)
					NXM->(DbSetOrder(5)) // NXM_FILIAL, NXM_FILTIT, NXM_PREFIX, NXM_TITNUM, NXM_TITPAR, NXM_TITTPO
					
					If NXM->(DbSeek(cChaveNXM))
						
						While !NXM->(Eof()) .And. NXM->(NXM_FILIAL + NXM_FILTIT + NXM_PREFIX + NXM_TITNUM) == cChaveNXM;
											.And. (Empty(NXM->NXM_TITPAR) .Or. NXM->NXM_TITPAR == OHT->OHT_TITPAR);
											.And. NXM->NXM_TITTPO == OHT->OHT_TITTPO
							RecLock("NXM", .F.)
							NXM->(DbDelete())
							NXM->(MsUnlock())
							NXM->(DbSkip())
						EndDo
					EndIf
				EndIf

				RecLock("OHT", .F.)
				OHT->(DbDelete())
				OHT->(MsUnLock())
				OHT->(DbSkip())

			EndDo
		EndIf
	EndIf

	RestArea(aAreaSE1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JLiqDlgBok()
Função utilizada no botão confirmar da tela de filtro de liquidação para atribuir
valor as variáveis private de cliente e loja.

@author Abner Fogaça
@since 30/06/20
/*/
//-------------------------------------------------------------------
Function JLiqDlgBok()
Local lIsPfs    := SuperGetMV("MV_JESCJUR",,.F.) .And. AliasInDic("OHT")
Local lIntPFS	:= SuperGetMV("MV_JURXFIN",,.F.)

If lIntPFS .And. lIsPFS
	cCliAte := cCliDe
	cCli460 := cCliDe
	cLojaAte := cLojaDe
	cLoja    := cLojaDe
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JLiqView
Modifica a view da rotina de liquidação quando habilitado integração 
com SIGAPFS

@param  oView, Objeto da View de dados a ser exibida

@author Abner Fogaça
@since  29/06/20
/*/
//-------------------------------------------------------------------
Function JLiqView(oView)
Local oStruFO0	 := oView:GetViewStruct("VIEW_FO0")
Local oStruFO1	 := oView:GetViewStruct("VIEW_FO1")
Local oStruFO2	 := oView:GetViewStruct("VIEW_FO2")
Local oStruct    := Nil
Local aRemoveF00 := {}
Local aRemoveF01 := {}
Local aRemoveF02 := {}
Local aStruct    := {}
Local aCampos    := {}
Local nI         := 0
Local nJ         := 0

If !Empty(oView) .And. oView:GetModel():GetID() == "FINA460A"

	aRemoveF00 := {"FO0_CALJUR", "FO0_TXJUR" , "FO0_TXMUL"}
	aRemoveF01 := {"FO1_TXJUR" , "FO1_TXMUL" , "FO1_VLMUL", "FO1_VLJUR" , "FO1_ACRESC", "FO1_DECRES", "FO1_TOTAL", "FO1_VLADIC"}
	aRemoveF02 := {"FO2_VLJUR" , "FO2_ACRESC", "FO2_TXCALC", "FO2_VLRJUR"}

	aAdd(aStruct, {oStruFO0, aRemoveF00})
	aAdd(aStruct, {oStruFO1, aRemoveF01})
	aAdd(aStruct, {oStruFO2, aRemoveF02})

	For nI := 1 To Len(aStruct)
		oStruct := aStruct[nI][1]
		If Valtype(oStruct) == "O"
			aCampos := aStruct[nI][2]

			For nJ := 1 To Len(aCampos)
				If oStruct:HasField(aCampos[nJ])
					If aCampos[nJ] $ "FO1_TOTAL|FO1_TXJUR|FO1_VLJUR|FO2_VALOR|FO1_ACRESC|FO1_DECRES"
						oStruct:SetProperty(aCampos[nJ], MVC_VIEW_CANCHANGE, .F.)
					Else
						oStruct:RemoveField(aCampos[nJ])
					EndIf
				EndIf
			Next nJ
		EndIf
	Next nI
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPVldLiq
Função chamada na pós validação do modelo de liquidação, quando 
integração SIGAPFS x SIGAFIN está habilitada.

@param  oModel , Objeto do modelo de dados

@return lPosVld, Pós validação executada com sucesso

@author Abner Fogaça | Jonatas Martins
@since  30/06/20
@Obs    Chamada no fonte FINA460a na função F460APosVld
/*/
//-------------------------------------------------------------------
Function JurPVldLiq(oModel)
Local oModelFO1 := oModel:GetModel('TITSELFO1')
Local oModelFO2 := oModel:GetModel('TITGERFO2')
Local cLine     := ""
Local lPosVld   := .T.
Local nLine     := 0
Local nTotFO1   := 0
Local nTotFO2   := 0

If oModelFO2:SeekLine({{"FO2_BANCO", AvKey("", "FO2_BANCO")}})
	lPosVld := .F.
	cLine   := CValToChar(oModelFO2:GetLine())
	oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0138, STR0140 + cLine,,) // "O título não possui dados bancários!" # "Verifique no título os dados de banco, agência e conta da linha:"#
EndIf

If lPosVld
	For nLine := 1 To oModelFO1:GetQtdLine()
		nTotFO1 += IIf(oModelFO1:GetValue("FO1_MARK", nLine), oModelFO1:GetValue("FO1_TOTAL", nLine), 0)
	Next

	For nLine := 1 To oModelFO2:GetQtdLine()
		If !oModelFO2:IsDeleted(nLine)
			nTotFO2 += oModelFO2:GetValue("FO2_VALOR", nLine)
		EndIf
	Next

	If nTotFO2 <> nTotFO1
		lPosVld := .F.
		oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0141, STR0142,,) // "A soma dos valores das parcelas deve ser igual ao total a ser liquidado." # "Verifique o valor total dos títulos que serão liquidados."
	EndIf

EndIf

Return lPosVld

//-------------------------------------------------------------------
/*/{Protheus.doc} JurBtnReli()
Retira botão da reliquidação caso necessário

@param  aRot460  - Array com botões da parte de liquidação do MenuDef

@author Abner Fogaça | Jorge Martins
@since  01/07/20
@Obs    Chamada no fonte FINA460 e FINA740 (MenuDef)
/*/
//-------------------------------------------------------------------
Function JurBtnReli(aRot460, cText)
Local nTamARot  := Len(aRot460)
Local nPos      := 0
Local lFatUnica := SuperGetMV("MV_JLIQRES",, .F.) // Paramêtro que indica se a liquidação será feita em uma única fatura (essa opção permitirá reliquidação)

	If AliasInDic("OHT") .And. !lFatUnica
		If nTamARot > 0
			nPos := aScan(aRot460, { |x| UPPER(x[1]) = UPPER(cText)})
			If nPos > 0
				ADel(aRot460, nPos)
				aSize(aRot460, nTamARot - 1)
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIncAdiant()
Inclui adiantamento através do Retorno de Cobranças (FINA200).

Caso o cliente pague o título com valor maior, ou pague um título 
que já se encontrava baixado, será gerado um RA para informar o 
crédito a mais na conta bancaria e ao mesmo tempo será  
disponibilizado o crédito ao cliente para posterior devolução 
ou compensação. 
Este processo será "startado" somente se for num retorno CNAB 
e se for parametrizado para tal (MV_REC2TIT = "1")

@param  nRecnoSE1 - Recno do título da fatura que está sendo pago novamente
@param  cBanco    - Banco do adiantamento
@param  cAgencia  - Agência do adiantamento
@param  cConta    - Conta do adiantamento
@param  cHist     - Histórico do adiantamento
@param  nValorRA  - Valor do adiantamento
@param  dDataRA   - Data do adiantamento

@author Jorge Martins
@since  07/07/20
@Obs    Chamada no fonte FINXBX - Função fA070Grv
/*/
//-------------------------------------------------------------------
Function JIncAdiant(nRecnoSE1, cBanco, cAgencia, cConta, cHist, nValorRA, dDataRA)
	Local aArea     := GetArea()
	Local aAreaSE1  := SE1->( GetArea() )
	Local oModel    := FWLoadModel("JURA069") // Adiantamentos
	Local oModelNWF := Nil
	Local aSetValue := {}
	Local nVal      := 0
	Local lSet      := .T.
	Local cLog      := ""
	Local aDadosFat := {}
	Local aChvFatur := {}
	Local cEscFat   := ""
	Local cCliFat   := ""
	Local cLojaFat  := ""
	Local cCasoFat  := ""
	Local cChvFatur := ""
	Local cNatureza := ""
	
	SE1->(DbGoto(nRecnoSE1))
	
	// Localiza um caso da fatura para amarrar ao adiantamento
	If AliasInDic("OHT")
		aChvFatur := JurGetDados("OHT", 2, xFilial("OHT") + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, {"OHT_FILFAT", "OHT_FTESCR", "OHT_CFATUR"}) // OHT_FILIAL+OHT_FILTIT+OHT_PREFIX+OHT_TITNUM+OHT_TITPAR+OHT_TITTPO
		cChvFatur := IIF(Len(aChvFatur) == 3, aChvFatur[1] + aChvFatur[2] + aChvFatur[3], "")
	Else
		cChvFatur := Substr(StrTran(SE1->E1_JURFAT, "-", ""), 1, TamSX3("NXA_FILIAL")[1] + TamSX3("NXA_CESCR")[1] + TamSX3("NXA_COD")[1])
	EndIf

	aDadosFat := JurGetDados("NXC", 1, cChvFatur, {"NXC_CESCR", "NXC_CCLIEN", "NXC_CLOJA", "NXC_CCASO"})
	
	If Len(aDadosFat) == 4
		cEscFat   := aDadosFat[1]
		cCliFat   := aDadosFat[2]
		cLojaFat  := aDadosFat[3]
		cCasoFat  := aDadosFat[4]

		cNatureza := SE1->E1_NATUREZ

		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModelNWF := oModel:GetModel("NWFMASTER")
		
		AAdd(aSetValue, {"NWF_DATAIN" , dDataRA         })
		AAdd(aSetValue, {"NWF_CCLIEN" , cCliFat         })
		AAdd(aSetValue, {"NWF_CLOJA"  , cLojaFat        })
		AAdd(aSetValue, {"NWF_CCASO"  , cCasoFat        })
		AAdd(aSetValue, {"NWF_CCLIAD" , SE1->E1_CLIENTE }) // Cliente do título da Fatura
		AAdd(aSetValue, {"NWF_CLOJAD" , SE1->E1_LOJA    }) // Loja do título da Fatura
		AAdd(aSetValue, {"NWF_TPADI"  , "3"             }) // Ambos
		AAdd(aSetValue, {"NWF_EXCLUS" , "2"             }) // Não exclusivo
		AAdd(aSetValue, {"NWF_CMOE"   , "01"            })
		AAdd(aSetValue, {"NWF_HIST"   , cHist           })
		AAdd(aSetValue, {"NWF_CESCR"  , cEscFat         })
		AAdd(aSetValue, {"NWF_VENCTO" , dDataRA         })
		AAdd(aSetValue, {"NWF_BANCO"  , cBanco          })
		AAdd(aSetValue, {"NWF_AGENCI" , cAgencia        })
		AAdd(aSetValue, {"NWF_CONTA"  , cConta          })
		AAdd(aSetValue, {"NWF_VALOR"  , nValorRA        })

		For nVal := 1 To Len(aSetValue)
			If !oModelNWF:SetValue(aSetValue[nVal][1], aSetValue[nVal][2])
				lSet := .F.
				Exit
			EndIf
		Next nVal

		JurFreeArr(@aSetValue)

		If lSet .And. oModel:VldData()
			oModel:CommitData()
			oModel:DeActivate()

			JA069FIN(oModel, .T., dDataRA, cNatureza) // Cria o RA no Contas a Receber

		Else
			cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModel:GetErrorMessage()[6])
			JurMsgErro(cLog, , STR0133) // "Ajustes as inconsistências."
		EndIf
	EndIf
	
	RestArea(aAreaSE1)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDistBxDes
Distribui valores de baixas feitas antes da liquidação e de descontos
aplicados nos títulos no momento da liquidação (FO1).

A distribuição será feita sobre os valores de honorários e despesas.
Isso é necessário pois o desconto pode ter sido aplicado em uma parcela
que só contemplava valores de despesas. Logo os descontos dessa parcela
não poderão ser direcionados para os honorários no momento da liquidação.

@param  nBxAnt    - Valor de baixas anteriores da parcela
@param  nDesconto - Valor de desconto da parcela
@param  nVlRemb   - Valor de despesa reembolsável da parcela
@param  nVlTrib   - Valor de despesa tributável da parcela
@param  nVlTxAd   - Valor de taxa administrativa da parcela
@param  nVlGros   - Valor de gross up da parcela
@param  nVlHon    - Valor de honorários da parcela
@param  lPrioDesp - Indica se usa priorização de despesas

@author Jorge Martins / Jonatas Martins
@since  31/08/20
/*/
//-------------------------------------------------------------------
Static Function JDistBxDes(nBxAnt, nDesconto, nVlRemb, nVlTrib, nVlTxAd, nVlGros, nVlHon, lPrioDesp)
Local nSldBxAnt   := nBxAnt
Local nSldDesc    := nDesconto
Local nBxAntHon   := 0
Local nBxAntRemb  := 0
Local nBxAntTrib  := 0
Local nBxAntTxAd  := 0
Local nBxAntGros  := 0
Local nDescHon    := 0
Local nDescRemb   := 0
Local nDescTrib   := 0
Local nDescTxAd   := 0
Local nDescGros   := 0
Local nValTotFt   := 0
Local nDif        := 0

	If nBxAnt > 0
		If lPrioDesp
			nBxAntRemb := IIF(nVlRemb > nSldBxAnt, nSldBxAnt, nVlRemb)
			nSldBxAnt  -= nBxAntRemb

			If nSldBxAnt > 0 // Proporcionaliza Despesas Tributaveis, Taxa Adm e Gross Up
				nTotalTrib := nVlTrib + nVlTxAd + nVlGros

				If nSldBxAnt > nTotalTrib
					nBxAntTrib += nVlTrib
					nBxAntTxAd += nVlTxAd
					nBxAntGros += nVlGros
				Else
					nBxAntTrib += nSldBxAnt * (nVlTrib / nTotalTrib)
					nBxAntTxAd += nSldBxAnt * (nVlTxAd / nTotalTrib)
					nBxAntGros += nSldBxAnt * (nVlGros / nTotalTrib)
				EndIf

				nSldBxAnt := nSldBxAnt - nBxAntTrib - nBxAntTxAd - nBxAntGros
			EndIf

			If nSldBxAnt > 0
				nBxAntHon += IIF(nVlHon > nSldBxAnt, nSldBxAnt, nVlHon)
				nSldBxAnt -= nBxAntHon
			EndIf
		Else
			nValTotFt  := nVlHon + nVlRemb + nVlTrib + nVlTxAd + nVlGros // Valor total da fatura
			nBxAntHon  := RatPontoFl(nVlHon , nValTotFt, nBxAnt, TamSX3("OHT_VLFATH")[2])
			nBxAntRemb := RatPontoFl(nVlRemb, nValTotFt, nBxAnt, TamSX3("OHT_VLREMB")[2])
			nBxAntTrib := RatPontoFl(nVlTrib, nValTotFt, nBxAnt, TamSX3("OHT_VLTRIB")[2])
			nBxAntTxAd := RatPontoFl(nVlTxAd, nValTotFt, nBxAnt, TamSX3("OHT_VLTXAD")[2])
			nBxAntGros := RatPontoFl(nVlGros, nValTotFt, nBxAnt, TamSX3("OHT_VLGROS")[2])
		EndIf
	EndIf

	If nDesconto > 0
		nVlHon  -= nBxAntHon  // Abate os valores das baixas sobre o original para calcular os descontos
		nVlRemb -= nBxAntRemb // Abate os valores das baixas sobre o original para calcular os descontos
		nVlTrib -= nBxAntTrib // Abate os valores das baixas sobre o original para calcular os descontos
		nVlTxAd -= nBxAntTxAd // Abate os valores das baixas sobre o original para calcular os descontos
		nVlGros -= nBxAntGros // Abate os valores das baixas sobre o original para calcular os descontos

		nDescHon += IIF(nVlHon > nSldDesc, nSldDesc, nVlHon)
		nSldDesc -= nDescHon
	
		If nSldDesc > 0 // Proporcionaliza Despesas Tributaveis, Taxa Adm e Gross Up
			nTotalTrib := nVlTrib + nVlTxAd + nVlGros

			If nSldDesc > nTotalTrib
				nDescTrib += nVlTrib
				nDescTxAd += nVlTxAd
				nDescGros += nVlGros
			Else
				nDescTrib += nSldDesc * (nVlTrib / nTotalTrib)
				nDescTxAd += nSldDesc * (nVlTxAd / nTotalTrib)
				nDescGros += nSldDesc * (nVlGros / nTotalTrib)
			EndIf

			nSldDesc := nSldDesc - nDescTrib - nDescTxAd - nDescGros
		EndIf

		If nSldDesc > 0
			nDescRemb := IIF(nVlRemb > nSldDesc, nSldDesc, nVlRemb)
			nSldDesc  -= nDescRemb
		EndIf
	EndIf

	_aDistBxAnt[1] += nBxAntHon
	_aDistBxAnt[2] += nBxAntRemb + nBxAntTrib + nBxAntTxAd + nBxAntGros // Total distribuido nas despesas
	_aDistBxAnt[3] += nBxAntRemb
	_aDistBxAnt[4] += nBxAntTrib
	_aDistBxAnt[5] += nBxAntTxAd
	_aDistBxAnt[6] += nBxAntGros
	_aDistBxAnt[7] += nBxAnt

	If nDescTrib  + nDescTxAd + nDescGros <> Round(nDescTrib, 2) + Round(nDescTxAd, 2) + Round(nDescGros, 2) // Arredondamento faltando/sobrando 0,01
		nDif := (nDescTrib  + nDescTxAd + nDescGros) - (Round(nDescTrib, 2) + Round(nDescTxAd, 2) + Round(nDescGros, 2))

		// Se positivo, deve ser adicionada a diferença no maior
		// Se negativo, deve ser subtraído a diferença no maior
		IIf(nDescTrib >= nDescTxAd .And. nDescTrib >= nDescGros, nDescTrib += nDif, IIf(nDescTxAd >= nDescGros, nDescTxAd += nDif, nDescGros += nDif))

	EndIf

	_aDistDesc[1] += nDescHon
	_aDistDesc[2] += nDescRemb + nDescTrib  + nDescTxAd  + nDescGros // Total distribuido nas despesas
	_aDistDesc[3] += nDescRemb
	_aDistDesc[4] += nDescTrib
	_aDistDesc[5] += nDescTxAd
	_aDistDesc[6] += nDescGros
	_aDistDesc[7] += nDesconto

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JValLiq
Distribui valores de baixas feitas antes da liquidação e de descontos
aplicados nos títulos no momento da liquidação (FO1).

A distribuição será feita sobre os valores de honorários e despesas.
Isso é necessário pois o desconto pode ter sido aplicado em uma parcela
que só contemplava valores de despesas. Logo os descontos dessa parcela
não poderão ser direcionados para os honorários no momento da liquidação.

@param  aValores, Valores da baixa atual
@param  lEstorno, Indica se é um estorno de baixa

@author Jorge Martins / Jonatas Martins
@since  02/12/20
/*/
//-------------------------------------------------------------------
Static Function JValLiq(aValores, lEstorno)
	Local aValLiq      := {}
	Local aValAcreOHT  := {}
	Local cQuery       := ""
	Local cSE5TpDoc    := ""
	Local cChaveSE1    := ""
	Local cNatClass    := ""
	Local nPropTipo    := 0
	Local nTipo        := 0
	Local nValor       := 0
	Local nPos         := 0
	Local nSE5Valor    := 0
	Local nSE5Total    := 0
	Local nPropBx      := 0
	Local nValAcres    := 0
	Local nTotBaixado  := 0
	Local nTotFatura   := 0
	Local nAcresBx     := 0
	Local nValEst      := 0
	Local nValorBx     := SE5->E5_VALOR // Valor da baixa

	cQuery := " SELECT SUM(OHT_VLFATH + OHT_VLFATD), SUM(OHT_ACRESC) FROM " + RetSqlName("OHT") + " OHT"
	cQuery +=  " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT") + "'"
	cQuery +=    " AND OHT.OHT_FILTIT = '" + SE1->E1_FILIAL + "'"
	cQuery +=    " AND OHT.OHT_PREFIX = '" + SE1->E1_PREFIXO + "'"
	cQuery +=    " AND OHT.OHT_TITNUM = '" + SE1->E1_NUM  + "'"
	cQuery +=    " AND OHT.OHT_TITPAR = '" + SE1->E1_PARCELA + "'"
	cQuery +=    " AND OHT.OHT_TITTPO = '" + SE1->E1_TIPO + "'"
	cQuery +=    " AND OHT.D_E_L_E_T_ = ' '"

	aValAcreOHT := JurSQL(cQuery, {"*"})

	If Len(aValAcreOHT) > 0

		nTotBaixado := SE1->E1_VALOR - SE1->E1_SALDO // Valor total das baixas efetuadas
		nTotFatura  := aValAcreOHT[1][1] // Valor total da fatura (honorários + despesas)
		nValAcres   := aValAcreOHT[1][2] // Valor de acréscimo por parcela gerada na liquidação

		// Recompõe o valor original da baixa atual (abate os acréscimos e adiciona os descontos)
		If Len(aValores)
			For nTipo := 1 To Len(aValores)
				cSE5TpDoc := aValores[nTipo][2]
				If cSE5TpDoc $ "DC/D2" // Descontos
					nValorBx += aValores[nTipo][1]
				ElseIf !(cSE5TpDoc $ "V2/BA/VL/LJ") // Outros tipos de valores que não sejam o registro principal da baixa
					nValorBx -= aValores[nTipo][1]
				EndIf
			Next
		EndIf

		If nTotBaixado > nTotFatura // Se o total baixado do título é maior que o valor da fatura, é sinal que existem acréscimos para o título
			If nValorBx > (nTotBaixado - nTotFatura)
				nAcresBx := nTotBaixado - nTotFatura
			Else
				nAcresBx := nValorBx
				If SE1->E1_SALDO == 0
					// Valor de impostos e abatimentos dos títulos - Usado somente se o saldo estiver zerado
					// É necessário fazer isso, pois o valor da baixa na SE5 não contempla o valor dos impostos
					nAcresBx += SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO)
				EndIf
			EndIf
		EndIf
		
		If nAcresBx > 0 .Or. (lEstorno .And. nValAcres > 0) // Baixa ou Estorno com acréscimo
			// Aglutina os valores da SE5 referente ao mesmo tipo de lançamento
			cQuery := " SELECT SUM(SE5.E5_VALOR) E5_VALOR, SE5.E5_TIPODOC "
			cQuery +=   " FROM " + RetSqlName("SE5") + " SE5 "
			cQuery +=  " WHERE SE5.E5_FILIAL  = '" + SE5->E5_FILIAL + "' "
			cQuery +=    " AND SE5.E5_DOCUMEN = '" + SE1->E1_NUMLIQ + "' "
			cQuery +=    " AND SE5.E5_TIPODOC NOT IN ('BA','VL','V2','LJ','DC','D2')" // Valores que não sejam valor principal ou descontos
			cQuery +=    " AND SE5.D_E_L_E_T_ = ' ' "
			cQuery +=  " GROUP BY SE5.E5_TIPODOC "

			aValLiq := JurSQL(cQuery, {"E5_VALOR", "E5_TIPODOC"})

			If Len(aValLiq) > 0

				If lEstorno
					cChaveSE1  := SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO
					For nTipo := 1 To Len(aValLiq)
						// Busca a natureza na classificação para o tipo de documento (juros/multa)
						cNatClass := JurGetDados("OHP", 1, xFilial("OHP") + "2" + aValLiq[nTipo][2], "OHP_CNATUR")
						If JEstLanSE1(cNatClass, cChaveSE1, .T., @nValEst) // Indica se deve ser feito o estorno
							// Verifica se existe algum registro pro mesmo tipo de documento no array principal de valores...
							nPos := AScan(aValores, {|aValores| aValores[2] == aValLiq[nTipo][2]})
							If nPos > 0 // ... Se existir sobrescreve o valor, pois a função JEstLanSE1 tem o valor total
								aValores[nPos][1] := nValEst
							Else // Caso não exista, adiciona a nova posição no array
								aAdd(aValores, {nValEst, aValLiq[nTipo][2]})
							EndIf
						EndIf
					Next
				Else

					// Total aglutinado (Soma do valor de todos os tipos de documentos), considerando somente valores positivos.
					// Obs: Valores Acessórios (VA) podem ser negativos, e caso isso aconteça, seu valor será abatido dos 
					//      honorários e despesas do título da fatura.
					aEval(aValLiq, {|aSE5Valor| nSE5Total += IIf(aSE5Valor[1] > 0, aSE5Valor[1], 0)}) 
					nPropBx := nAcresBx / nValAcres // Proporção do valor da baixa sobre o título

					For nTipo := 1 To Len(aValLiq)
						nSE5Valor := aValLiq[nTipo][1] // Valor referente ao Tipo do Documento
						cSE5TpDoc := aValLiq[nTipo][2] // Tipo do Documento (JR, MT, DC, VA, etc.)

						If nSE5Valor > 0
							nPropTipo := nSE5Valor / nSE5Total // Proporção do valor por tipo sobre o total (soma do valor de todos os tipos de documentos)

							nValor := nValAcres * nPropTipo * nPropBx // Valor do acréscimo da parcela * Proporção do Tipo * Proporção da Baixa

							// Verifica se existe algum registro pro mesmo tipo de documento no array principal de valores...
							nPos := AScan(aValores, {|aValores| aValores[2] == cSE5TpDoc})

							If nPos > 0 // ... Se existir soma o valor
								aValores[nPos][1] += nValor
							Else // Caso não exista, adiciona a nova posição no array
								aAdd(aValores, {nValor, aValLiq[nTipo][2]})
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		EndIf
	EndIf

	JurFreeArr(@aValLiq)
	JurFreeArr(@aValAcreOHT)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCanUltBx
Indica se será permitido cancelar somente a última baixa feita.

Isso é necessário pois o rastreio dos valores de títulos que contém 
impostos ficam incorretos caso as baixas sejam canceladas fora de ordem.

Uso na função fa070can (FINA070) - Canc. de Baixa (Contas a Receber)

@return lCancUltBx, Permite cancelar somente a ultima baixa realizada

@author Jorge Martins
@since  16/06/2021
/*/
//-------------------------------------------------------------------
Function JCanUltBx()
Local lCancUltBx := .F.

	// Se for um título com imposto, permitirá cancelar/excluir somente a última baixa efetuada
	lCancUltBx := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO, SE1->E1_TIPO) > 0

Return lCancUltBx

//-------------------------------------------------------------------
/*/{Protheus.doc} JFatLiq
Indica se a fatura foi liquidada

@param cFilFat, Filial da Fatura
@param cEscrit, Escritório da Fatura
@param cFatura, Código da Fatura

@return lFatLiq, Indica se a fatura foi liquidada

@author Jorge Martins
@since  06/07/2021
/*/
//-------------------------------------------------------------------
Function JFatLiq(cFilFat, cEscrit, cFatura)
Local lOHTInDic  := FWAliasInDic("OHT")
Local cSpaceNumL := IIf(lOHTInDic, Space(TamSx3('OHT_NUMLIQ')[1]), "")
Local cFilterOHT := ""
Local lFatLiq    := .F.
Local aFatLiq    := {}

Default cFilFat  := xFilial("NXA")

	If lOHTInDic
		cFilterOHT += " SELECT DISTINCT 1 FROM " + RetSqlName("OHT") + " OHT"
		cFilterOHT +=  " WHERE OHT.OHT_FILIAL = '"  + xFilial("OHT")  + "'"
		cFilterOHT +=    " AND OHT.OHT_FILFAT = '"  + cFilFat + "'"
		cFilterOHT +=    " AND OHT.OHT_FTESCR = '"  + cEscrit + "'"
		cFilterOHT +=    " AND OHT.OHT_CFATUR = '"  + cFatura + "'"
		cFilterOHT +=    " AND OHT.OHT_NUMLIQ <> '" + cSpaceNumL + "'"
		cFilterOHT +=    " AND OHT.D_E_L_E_T_ = ' ' "

		aFatLiq := JurSQL(cFilterOHT, {"*"})
		lFatLiq := Len(aFatLiq) > 0
	EndIf

Return lFatLiq

//-------------------------------------------------------------------
/*/{Protheus.doc} JFilBorPag
Monta filtro da query do borderô a pagar permitindo apenas os títulos 
totalmente a pagar totalmente desdobrados.

@param lBordImp, Se verdadeiro a função é chamada na rotina de borderô 
                 a pagar com impostos (FINA241)

@return cFiltro, Expressão com filtro da query de borderô a pagar

@author Jorge Martins / Jonatas Martins
@since  09/08/2021
@obs    Função chamada nos fontes FINA240 (f240QryA) e FINA241 (f241QryA)
/*/
//-------------------------------------------------------------------
Function JFilBorPag(lBordImp)
Local cFiltro     := ""
Local lColPrf     := FK7->(ColumnPos("FK7_PREFIX")) > 0

Default lBordImp  := .F. // Borderô de pagamento com impostos

	cFiltro += " INNER JOIN " +  RetSqlName("SED") + " SED "
	cFiltro +=    " ON SE2.E2_NATUREZ = SED.ED_CODIGO "
	cFiltro += "   AND SED.ED_FILIAL = '"+ xFilial("SED") + "'"
	cFiltro += "   AND SED.D_E_L_E_T_ = ' ' " 
	cFiltro += " INNER JOIN " +  RetSqlName("SA2") + " SA2 "
	cFiltro +=    " ON SE2.E2_FORNECE = SA2.A2_COD "
	cFiltro += "   AND SE2.E2_LOJA = SA2.A2_LOJA "
	cFiltro += "   AND SA2.A2_FILIAL = '"+ xFilial("SA2") + "'"
	cFiltro += "   AND SA2.D_E_L_E_T_ = ' ' " 
	// Se for imposto ou título de fatura a pagar (aglutinação) ou título normal totalmente desdobrado
	cFiltro += " WHERE (E2_TITPAI <> ' ' OR LTRIM(RTRIM(E2_ORIGEM)) IN ('FINA290', 'FINA290M') OR "
	cFiltro +=        " EXISTS( SELECT 1 FROM " + RetSqlName("FK7") + " FK7 "
	cFiltro +=                 " WHERE FK7.FK7_FILIAL = SE2.E2_FILIAL "
	If !lColPrf
		cFiltro +=               " AND FK7.FK7_CHAVE = E2_FILIAL ||'|'|| E2_PREFIXO ||'|'|| E2_NUM  ||'|'|| E2_PARCELA ||'|'|| E2_TIPO ||'|'|| E2_FORNECE ||'|'|| E2_LOJA "
	Else
		cFiltro +=               " AND FK7_FILTIT = E2_FILIAL "  // Filial
		cFiltro +=               " AND FK7_PREFIX = E2_PREFIXO " // Prefixo
		cFiltro +=               " AND FK7_NUM = E2_NUM "        // Numero
		cFiltro +=               " AND FK7_PARCEL = E2_PARCELA " // Parcela
		cFiltro +=               " AND FK7_TIPO = E2_TIPO "      // Tipo
		cFiltro +=               " AND FK7_CLIFOR = E2_FORNECE " // Fornecedor
		cFiltro +=               " AND FK7_LOJA = E2_LOJA "      // Loja
	EndIf
	cFiltro +=                   " AND FK7.D_E_L_E_T_ = ' ' "
	cFiltro +=                   " AND (SELECT SUM(OHF.OHF_VALOR) "
	cFiltro +=                          " FROM " + RetSqlName("OHF") + " OHF "
	cFiltro +=                         " WHERE OHF_FILIAL = '" + xFilial("OHF") + "' "
	cFiltro +=                           " AND OHF.OHF_IDDOC = FK7.FK7_IDDOC "
	cFiltro +=                           " AND OHF.D_E_L_E_T_ = ' ' "
	cFiltro +=                         " GROUP BY OHF.OHF_IDDOC) = ( SELECT MAX( CASE "
	cFiltro +=                                                       " WHEN (E2_BASEIRF >= E2_BASEPIS "
	cFiltro +=                                                        " AND E2_BASEIRF >= E2_BASECOF "
	cFiltro +=                                                        " AND E2_BASEIRF >= E2_BASECSL "
	cFiltro +=                                                        " AND E2_BASEIRF >= E2_BASEISS "
	cFiltro +=                                                        " AND E2_BASEIRF >= E2_BASEINS )"
	cFiltro +=                                                       " THEN E2_BASEIRF "
	cFiltro +=                                                       " WHEN (E2_BASEPIS >= E2_BASEIRF "
	cFiltro +=                                                        " AND E2_BASEPIS >= E2_BASECOF "
	cFiltro +=                                                        " AND E2_BASEPIS >= E2_BASECSL "
	cFiltro +=                                                        " AND E2_BASEPIS >= E2_BASEISS "
	cFiltro +=                                                        " AND E2_BASEPIS >= E2_BASEINS) "
	cFiltro +=                                                       " THEN E2_BASEPIS "
	cFiltro +=                                                       " WHEN (E2_BASECOF >= E2_BASEIRF "
	cFiltro +=                                                        " AND E2_BASECOF >= E2_BASEPIS "
	cFiltro +=                                                        " AND E2_BASECOF >= E2_BASECSL "
	cFiltro +=                                                        " AND E2_BASECOF >= E2_BASEISS "
	cFiltro +=                                                        " AND E2_BASECOF >= E2_BASEINS) "
	cFiltro +=                                                       " THEN E2_BASECOF "
	cFiltro +=                                                       " WHEN (E2_BASECSL >= E2_BASEIRF "
	cFiltro +=                                                        " AND E2_BASECSL >= E2_BASEPIS "
	cFiltro +=                                                        " AND E2_BASECSL >= E2_BASECOF "
	cFiltro +=                                                        " AND E2_BASECSL >= E2_BASEISS "
	cFiltro +=                                                        " AND E2_BASECSL >= E2_BASEINS) "
	cFiltro +=                                                       " THEN E2_BASECSL "
	cFiltro +=                                                       " WHEN (E2_BASEISS >= E2_BASEIRF "
	cFiltro +=                                                        " AND E2_BASEISS >= E2_BASEPIS "
	cFiltro +=                                                        " AND E2_BASEISS >= E2_BASECOF "
	cFiltro +=                                                        " AND E2_BASEISS >= E2_BASECSL "
	cFiltro +=                                                        " AND E2_BASEISS >= E2_BASEINS) "
	cFiltro +=                                                        " THEN E2_BASEISS "
	cFiltro +=                                                        " WHEN (E2_BASEINS >= E2_BASEIRF "
	cFiltro +=                                                         " AND E2_BASEINS >= E2_BASEPIS "
	cFiltro +=                                                         " AND E2_BASEINS >= E2_BASECOF "
	cFiltro +=                                                         " AND E2_BASEINS >= E2_BASECSL "
	cFiltro +=                                                         " AND E2_BASEINS >= E2_BASEISS) "
	cFiltro +=                                                        " THEN E2_BASEINS "
	cFiltro +=                                                         " END ) AS MAIOR_VALOR "
	cFiltro +=                                                        " FROM " + RetSqlName("SE2") 
	cFiltro +=                                                       " WHERE E2_FILIAL = SE2.E2_FILIAL "
	cFiltro +=                                                         " AND E2_NUM = SE2.E2_NUM "
	cFiltro +=                                                         " AND E2_PREFIXO = SE2.E2_PREFIXO  "
	cFiltro +=                                                         " AND E2_TIPO = SE2.E2_TIPO  "
	cFiltro +=                                                         " AND E2_PARCELA = SE2.E2_PARCELA  "
	cFiltro +=                                                         " AND E2_FORNECE = SE2.E2_FORNECE  "
	cFiltro +=                                                         " AND E2_LOJA = SE2.E2_LOJA  "
	cFiltro +=                                                         " AND D_E_L_E_T_ = ' '  "
	cFiltro +=" ))) "

	// Se a integraçao com SigaPFS estiver ativa.
	If SuperGetMV("MV_JURXFIN",.F.,.F.) .Or. SuperGetMV("MV_JESCJUR",.F.,.F.)

		If Type(cPort240) == "U"
			cPort240 := ""
		EndIf
		
		If cModPgto <> "99"
			// Se não for boleto, os campos banco, agência e conta corrente devem ser preenchidos 
			If Empty(SE2->E2_CODBAR) .And. ;
				(Empty( SE2->E2_FORBCO ) .Or. Empty( SE2->E2_FORAGE ) .Or. Empty( SE2->E2_FORCTA ) )
				cFiltro += " AND 1=2 "
			EndIf

			// Se for Tranferência bancária, nao permite bancos diferentes
			If cModPgto = "01"
				cFiltro += " AND SE2.E2_FORBCO = '" + cPort240 + "'"

			// Se for DOC ou TED, nao permite bancos iguais
			ElseIf cModPgto $ "03 | 43"
				cFiltro += " AND SE2.E2_FORBCO <> '" + cPort240 + "'"
			EndIf
		EndIf
	EndIf

	cFiltro += " AND "

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} DocOrigPFS
Verificar se os títulos do módulo SIGAPFS estão relacionados a um 
documento ficsal, ao processar a apuração EFD-Contribuições, FISA001, 
quando utilizado regime de caixa.

@param  cFilTit , Filial do título
@param  cPrefixo, Prefixo do título
@param  cNumTit , Número do título
@param  cParcela, Parcela do título
@param  cTipo   , Tipo do título
@param  aDocPFS , Array para retornar as informações do documento fiscal
                    aDocPFS[1] - Número do documento fiscal
                    aDocPFS[2] - Série do documento fiscal
                    aDocPFS[3] - Emissão do documento fiscal

@author Reginaldo Borges
@since  13/06/2022
@obs    Função chamada no fonte FINXSPD(TrbF500)
/*/
//-------------------------------------------------------------------
Function DocOrigPFS(cFilTit, cPrefixo, cNumTit, cParcela, cTipo, aDocPFS)
Local aArea     := GetArea()
Local cAliasNXA := GetNextAlias()
Local nTamFil   := TamSX3("NXA_FILIAL")[1]
Local nTamEsc   := TamSX3("NXA_CESCR")[1]
Local nTamFat   := TamSX3("NXA_COD")[1]
Local cJurFat   := ""
Local cEscrit   := ""
Local cFatura   := ""
Local cQuery    := ""
Local cE1JurFat := ""

Default cFilTit  := ""
Default cPrefixo := ""
Default cNumTit  := ""
Default cParcela := ""
Default cTipo    := ""
Default aDocPFS  := {}

	aDocPFS  := {}	
	
	cE1JurFat := JurGetDados("SE1", 1, cFilTit + cPrefixo + cNumTit + cParcela + cTipo, "E1_JURFAT")
	cJurFat   := Strtran(cE1JurFat, "-", "")
	cEscrit   := Substr(cJurFat, nTamFil + 1, nTamEsc)
	cFatura   := Substr(cJurFat, nTamFil + nTamEsc + 1, nTamFat)
	
	// Verifica se Fatura do Título tem vínculo com Documento Fiscal
	cQuery += " SELECT SF2.F2_DOC , SF2.F2_SERIE, SF2.F2_EMISSAO "
	cQuery +=   " FROM " + RetSqlName("NXA") + " NXA "
	cQuery +=  " INNER JOIN " + RetSqlName("SF2") + " SF2 "
	cQuery +=     " ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
	cQuery +=    " AND SF2.F2_DOC = NXA.NXA_DOC "
	cQuery +=    " AND SF2.F2_SERIE = NXA.NXA_SERIE "
	cQuery +=    " AND SF2.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQuery +=    " AND NXA.NXA_CESCR = '" + cEscrit + "' "
	cQuery +=    " AND NXA.NXA_COD = '" + cFatura + "' "
	cQuery +=    " AND NXA.NXA_SITUAC = '1' "
	cQuery +=    " AND NXA.D_E_L_E_T_ = ' ' "

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasNXA, .T., .T.)

	If !(cAliasNXA)->(Eof())
		AAdd(aDocPFS, (cAliasNXA)->F2_DOC)
		AAdd(aDocPFS, (cAliasNXA)->F2_SERIE)
		AAdd(aDocPFS, (cAliasNXA)->F2_EMISSAO)
	EndIf

	(cAliasNXA)->(DbcloseArea())

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JAjuImpFat
Ajusta o valor de impostos (OHT_ABATIM) nos registros gerados pela 
liquidação, para faturas que na sua emissão não tinham impostos, 
mas na liquidação foi utilizada uma natureza que tem impostos.

@param  aFatSemImp , Faturas que não tinham impostos na sua emissão
@param  aTitGer    , Títulos gerados pela liquidação
@param  nTotImp    , Valor total de impostos do título gerado pela liquidação
@param  nImpDist   , Valor de impostos que devem ser distribuídos nas faturas

@author Jorge Martins
@since  25/08/2022
/*/
//-------------------------------------------------------------------
Static Function JAjuImpFat(aFatSemImp, aTitGer, nTotImp, nImpDist)
Local aArea      := GetArea()
Local aAreaOHT   := OHT->( GetArea() )
Local nValorBase := 0
Local nValorFat  := 0
Local nImpTit    := 0
Local nValImp    := 0
Local nImpOHT    := 0
Local nFat       := 0
Local nTit       := 0
Local nDec       := TamSX3("OHT_ABATIM")[2]
Local cFilOHT    := xFilial("OHT")
Local cQryRes    := ""
Local cQueryOHT  := ""

	// Valor base total das faturas para calculo do imposto
	// Honorários + Despesa Tributável + Taxa Adm. + GrossUp de Despesas
	aEval(aFatSemImp,  {|aX| nValorBase += aX[4] + aX[7] + aX[8] + aX[9]}) 

	OHT->(DbSetOrder(3)) //OHT_FILIAL + OHT_FILLIQ + OHT_NUMLIQ

	For nFat := 1 To Len(aFatSemImp)
		nValorFat := aFatSemImp[nFat][4] + aFatSemImp[nFat][7] + aFatSemImp[nFat][8] + aFatSemImp[nFat][9] // Valor base da fatura para calculo do imposto

		For nTit := 1 To Len(aTitGer)
			nImpTit := aTitGer[nTit][10] // Valor de impostos do título

			nValImp := RatPontoFl(nImpTit, nTotImp, nImpDist, nDec)     // Calcula a proporção o imposto que deve ser aplicado na parcela (necessário por conta de parcelamento)
			nImpOHT := RatPontoFl(nValorFat, nValorBase, nValImp, nDec) // Calcula o valor de imposto da fatura por parcela

			cQueryOHT := " SELECT R_E_C_N_O_ RECNO"
			cQueryOHT +=   " FROM " + RetSqlName("OHT") + " OHT "
			cQueryOHT +=  " WHERE OHT.OHT_FILIAL = '" + cFilOHT + "'"
			cQueryOHT +=    " AND OHT.OHT_FILTIT = '" + aTitGer[nTit][1] + "'"
			cQueryOHT +=    " AND OHT.OHT_PREFIX = '" + aTitGer[nTit][2] + "'"
			cQueryOHT +=    " AND OHT.OHT_TITNUM = '" + aTitGer[nTit][3] + "'"
			cQueryOHT +=    " AND OHT.OHT_TITPAR = '" + aTitGer[nTit][4] + "'"
			cQueryOHT +=    " AND OHT.OHT_TITTPO = '" + aTitGer[nTit][5] + "'"
			cQueryOHT +=    " AND OHT.OHT_FILFAT = '" + aFatSemImp[nFat][1] + "'"
			cQueryOHT +=    " AND OHT.OHT_FTESCR = '" + aFatSemImp[nFat][2] + "'"
			cQueryOHT +=    " AND OHT.OHT_CFATUR = '" + aFatSemImp[nFat][3] + "'"
			cQueryOHT +=    " AND OHT.D_E_L_E_T_ = ' '"
		
			cQryRes := GetNextAlias()

			dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryOHT), cQryRes, .T., .T.)

			If !((cQryRes)->RECNO == 0) // Posiciona na nova OHT que foi gerada e ajusta o imposto.
				OHT->(DbGoto((cQryRes)->RECNO))
				RecLock("OHT", .F.)
				OHT->OHT_ABATIM  := nImpOHT
				OHT->(MsUnLock())
			EndIf

			(cQryRes)->( dbCloseArea() )
		Next
	Next

	RestArea(aAreaOHT)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JNextCod
Retorna o próximo código da tabela, para campos que não usam controle
de numeração.

Usado para: CTG - Calendário Contábil

@param  cTabela, Tabela que o campo pertence
@param  cCampo , Campo que receberá o código

@Return - cNextCod - Número válido para ser usado em uma inclusão

@author Jorge Martins
@since  07/10/2022
/*/
//-------------------------------------------------------------------
Static Function JNextCod(cTabela, cCampo)
Local cQuery    := ""
Local cNextCod  := ""
Local cAliasCod := GetNextAlias()

	cQuery := " SELECT MAX(" + cCampo + ") VALOR "
	cQuery +=   " FROM " + RetSqlName(cTabela) + " "
	cQuery +=  " WHERE " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasCod, .F., .F. )

	If (cAliasCod)->( !Eof() ) .And. !Empty((cAliasCod)->VALOR) .And. ValType((cAliasCod)->VALOR) == "C"
		cNextCod := Soma1((cAliasCod)->VALOR)
	EndIf

	(cAliasCod)->(DbCloseArea())

Return cNextCod

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetNatTra
Pega a natureza transitória de pagamento indicada na classificação 
de natureza. Caso não exista a classificação ou não esteja preenchida,
faz o cadastro e já preenche a natureza.

@return cNatTrans, Natureza transitória da classificação

@author Jorge Martins
@since  31/10/2022
/*/
//-------------------------------------------------------------------
Static Function JGetNatTra()
Local cNatTrans := ""
Local aDadosOHP := {}

	cNatTrans := JurGetDados("OHP", 1, xFilial("OHP") + "1" + "TP", "OHP_CNATUR")

	If Empty(cNatTrans)
		JA266Carga(.F.) // Carga inicial da classificação de naturezas

		aDadosOHP := JurGetDados("OHP", 1, xFilial("OHP") + "1" + "TP", {"OHP_COD", "OHP_CNATUR"})

		If !Empty(aDadosOHP) .And. !Empty(aDadosOHP[1]) .And. Empty(AllTrim(aDadosOHP[2])) // Valida se a nova classificação foi criada
			JurOperacao(4, "OHP", 1, xFilial("OHP") + "1" + "TP", {"OHP_CNATUR"}, {JurBusNat("7")}) // Se a natureza estiver vazia, preenche com a natureza transitória de pagamento que existe
		EndIf

		cNatTrans := JurGetDados("OHP", 1, xFilial("OHP") + "1" + "TP", "OHP_CNATUR")
	EndIf

	// Pega o JurBusNat em último caso, como por exemplo, rodou a carga mas fonte JURA266 está desatualizado e não tem a classificação da transitória
	cNatTrans := IIf(Empty(cNatTrans), JurBusNat("7"), cNatTrans)

Return cNatTrans

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetNatDes
Pega a natureza de despesa de cliente indicada na classificação 
de natureza. Caso não exista a classificação ou não esteja preenchida,
faz o cadastro e já preenche a natureza.

@return cNatDesp, Natureza de despesa de cliente

@author Jorge Martins
@since  31/10/2022
/*/
//-------------------------------------------------------------------
Function JGetNatDes()
Local cNatDesp  := ""
Local aDadosOHP := {}

	cNatDesp := JurGetDados("OHP", 1, xFilial("OHP") + "3" + "DP", "OHP_CNATUR")

	If Empty(cNatDesp)
		JA266Carga(.F.) // Carga inicial da classificação de naturezas

		aDadosOHP := JurGetDados("OHP", 1, xFilial("OHP") + "3" + "DP", {"OHP_COD", "OHP_CNATUR"})

		If !Empty(aDadosOHP) .And. !Empty(aDadosOHP[1]) .And. Empty(AllTrim(aDadosOHP[2])) // Valida se a nova classificação foi criada
			JurOperacao(4, "OHP", 1, xFilial("OHP") + "3" + "DP", {"OHP_CNATUR"}, {JurBusNat("5")}) // Se a natureza estiver vazia, preenche com a natureza transitória de pagamento que existe
		EndIf

		cNatDesp := JurGetDados("OHP", 1, xFilial("OHP") + "3" + "DP", "OHP_CNATUR")

	EndIf

	// Pega o JurBusNat em último caso, como por exemplo, rodou a carga mas fonte JURA266 está desatualizado e não tem a classificação de despesa
	cNatDesp := IIf(Empty(cNatDesp), JurBusNat("5"), cNatDesp)

Return cNatDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTit290
Busca os desdobramentos dos títulos a pagar de origem que gerou os 
títulos aglutinados

@return  aTitulos, Array com os títulos de origem que gerou a aglutinação

@author Jonatas Martins
@since  28/10/2022
/*/
//-----------------------------------
Static Function JurTit290(lDelLanc)
Local aTitulos := {}
Local cCampos  := ""
Local cFatPag  := ""

Default lDelLanc   := .F.

	cCampos := IIF(lDelLanc, "OHB.OHB_CPAGTO, OHB.OHB_SE5SEQ", "FK7.FK7_IDDOC, FK7.FK7_CHAVE, SUM(SE2.E2_VALOR) VLSE2DES")

	cQuery := "SELECT " + cCampos
	cQuery +=  " FROM " + RetSqlName("FK7") + " FK7, " + RetSqlName("FI8") + " FI8" + IIF(lDelLanc, ", " + RetSqlName("OHB") + " OHB", ", " + RetSqlName("SE2") + " SE2")
	cQuery += " WHERE FK7.FK7_FILIAL = '" + SE2->E2_FILIAL + "'"
	cQuery +=   " AND FK7.FK7_CHAVE = FI8.FI8_FILIAL || '|' || FI8.FI8_PRFORI || '|' || FI8.FI8_NUMORI || '|' || FI8.FI8_PARORI || '|' || FI8.FI8_TIPORI || '|' || FI8.FI8_FORORI || '|' || FI8.FI8_LOJORI"
	cQuery +=   " AND FK7.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND FI8.FI8_FILIAL = '" + SE2->E2_FILIAL + "'"
	cQuery +=   " AND FI8.FI8_PRFDES = '" + SE2->E2_PREFIXO + "'"
	cQuery +=   " AND FI8.FI8_NUMDES = '" + SE2->E2_NUM + "'"
	cQuery +=   " AND FI8.FI8_PARDES = '" + SE2->E2_PARCELA + "'"
	cQuery +=   " AND FI8.FI8_TIPDES = '" + SE2->E2_TIPO + "'"
	cQuery +=   " AND FI8.FI8_FORDES = '" + SE2->E2_FORNECE + "'"
	cQuery +=   " AND FI8.FI8_LOJDES = '" + SE2->E2_LOJA + "'"
	cQuery +=   " AND FI8.D_E_L_E_T_ = ''"
	If lDelLanc
		cFatPag := RTrim(SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA)
		cQuery += " AND OHB.OHB_FILIAL = '" + SE2->E2_FILIAL + "'"
		cQuery += " AND OHB.OHB_CPAGTO = FK7.FK7_CHAVE"
		cQuery += " AND TRIM(OHB_FATPAG) = '" + cFatPag + "' "
		cQuery += " AND OHB.D_E_L_E_T_ = ' '"
	Else
		cQuery += " AND SE2.E2_FILIAL = '" + SE2->E2_FILIAL + "'"
		cQuery += " AND SE2.E2_PREFIXO = FI8.FI8_PRFORI"
		cQuery += " AND SE2.E2_NUM = FI8.FI8_NUMORI"
		cQuery += " AND SE2.E2_TIPO = FI8.FI8_TIPORI"
		cQuery += " AND SE2.E2_PARCELA = FI8.FI8_PARORI"
		cQuery += " AND SE2.E2_FORNECE = FI8.FI8_FORORI"
		cQuery += " AND SE2.E2_LOJA = FI8.FI8_LOJORI"
		cQuery += " AND SE2.D_E_L_E_T_ = ' '"
	EndIf
	cQuery += " GROUP BY " + IIF(lDelLanc, cCampos, "FK7.FK7_IDDOC, FK7.FK7_CHAVE")

	cQuery   := ChangeQuery(cQuery)
	aTitulos := JurSQL(cQuery, "*")

Return aTitulos

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldNat290
Função para validar natureza na tela de Faturas a Pagar/Aglutinação

@param  cNatureza , Código da Natureza
@param  lPosiciona, Se verdadeiro indica que precisar ser feito o
                    posicionamento na tabela de natureza

@return  lNatOk   , Retorna se a natureza é válida

@author Jonatas Martins
@since  28/10/2022
@obs    Rotina chamada na função FA290NAT do fonte FINA290
        e na função FinVldNat do FINXFIN
/*/
//-----------------------------------
Function JVldNat290(cNatureza, lPosiciona, cRotina)
Local aArea        := {}
Local lNatOk       := .T.
Local lIntPFS      := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local cNatOld      := AllTrim(cNatureza)
Local cNatSE2      := AllTrim(M->E2_NATUREZ)

Default cNatureza  := ""
Default lPosiciona := .F.
Default cRotina    := ""

	If lIntPFS
		If lPosiciona .And. !Empty(cNatureza)
			aArea := GetArea()
			DbSelectArea("SED")
			SED->(DbSeek(xFilial("SED") + cNatureza))
		EndIf

		If cRotina == "FINA290" .Or. ; // Validação do campo da tela de filtro da rotina de Faturas a Pagar/Aglutinação FINA290
			(cRotina == "FINXFIN" .And. Type("ALTERA") == "L" .And. ALTERA .And. !Empty(SE2->E2_FATURA) .And. SE2->E2_ORIGEM $ "FINA290 |FINA290M") // Validação do campo E2_NATUREZ no Contas a Pagar
			lNatOk := SED->ED_CCJURI == "7" // Transitória de Pagamento
		EndIf

		If !lNatOk
			JurMsgErro(STR0143,, I18N(STR0144, {JurInfBox("ED_CCJURI", "7", "3")})) // "Natureza inválida!" # "Só é permitido natureza com centro de custo jurídico igual a: #1"
		EndIf

		// Não permitir que a Natureza do Título com E2_ORIGEM(JURCTORC) seja alterada, quando o CCJURI ou DESFAT forem diferentes.
		If (lNatOk .And. AllTrim(SE2->E2_ORIGEM) == "JURCTORC" .And. Type("ALTERA") == "L" .And. ALTERA) // Integração Controle Orçamentário SIGAPFS x SIGAFIN
			lNatOk := JVlNatCtOrc(cNatOld, cNatSE2, STR0147) // "Não é pfssível alterar a natureza desse Título."
		EndIf

		IIF(lPosiciona, RestArea(aArea), Nil)
	EndIf

Return (lNatOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} JImpLanc
Monta o array com valores de impostos para criação dos lançamentos
(OHB) no momento da baixa do título principal

@param  aLancDiv , Array com estrutura para geração da OHB
@param  cNatTrans, Natureza transitória usada na OHB
@param  nRecnoSE2, Recno do título principal
@param  nOpc     , Operação da chamada no financeiro (utilizado para o
                   controle do estorno ou exclusão da compensação - FINA340)
@param lCompensac, Indica se é compensação
@param lConsulta , Indica se é apenas uma consulta e não limpa os 
                   dados na função JGetImpLan

@author Jorge Martins
@since  16/12/2022
/*/
//-----------------------------------
Static Function JImpLanc(aLancDiv, cNatTrans, nRecnoSE2, nOpc, lCompensac, lConsulta)
Local aArea       := GetArea()
Local aAreaSE2    := SE2->(GetArea())
Local aAreaOHF    := OHF->(GetArea())
Local aRecImp     := JRecFilho(nRecnoSE2, SE5->E5_SEQ)
Local cHistLanc   := ""
Local cNatImp     := ""
Local nImp        := 0
Local aGetImpLan  := {} // Array com valores setados via JSetImpLan
Local lPrimeiraBx := SE2->E2_SALDO == SE2->E2_VALOR .Or. (lCompensac .And. !JLancImpCP())
Local lIncluiOHB  := .F.
Local lExclusao   := FwIsInCallStack("fa080Exc") .Or. (FwIsInCallStack("FA340Can") .And. nOpc == 4) // Não seta os impostos que estão sendo excluídos no array _aImpLanc.
Local lImpBaixa   := SA2->A2_CALCIRF == "2" .Or. SuperGetMv("MV_BX10925", .F., "1") == "1" .Or. SuperGetMv("MV_MRETISS", .F., "1") == "2" // IR, PCC ou ISS regime de caixa (Baixa do Título).

Default nOpc       := 0
Default lCompensac := .F.

	// JGetImpLan retorna estrutura do aLancDiv já preenchida (só faltando ajustar a natureza transitória) 
	// em casos de baixa/compensação ou cancelamento de baixa/compensação.
	// Isso é necessário, pois na chamada da JGrvBxPag no cancelamento da baixa (FINA080) ou cancelamento de compensação (FINA340), 
	// os títulos de impostos já foram excluídos, e essa função não encontrará eles quando tentar posicionar.
	// Por isso antes da exclusão dos títulos de impostos é executada a função JSetImpLan (nos fonte FINA080/FINA340) para já armazenar os dados
	// dos títulos de impostos. E agora serão somente reaproveitados.
	aGetImpLan := JGetImpLan(lConsulta)

	If !lExclusao
		If Len(aGetImpLan) == 0 // Se não foi preenchido executa o trecho abaixo
			If Len(aRecImp) > 0
				OHF->(DbSetOrder(1)) // OHF_FILIAL+OHF_IDDOC+OHF_CITEM
				For nImp := 1 To Len(aRecImp)
					SE2->(DbGoTo(aRecImp[nImp][2]))
					cIdDocPag := FINGRVFK7("SE2", SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA)
					If !lImpBaixa .And. OHF->(DbSeek(SE2->E2_FILIAL + cIdDocPag))
						lIncluiOHB := .T.
					ElseIf lImpBaixa .And. ((IIf(lCompensac, lPrimeiraBx, .T.) .And. Empty(SE2->E2_SEQBX)) .Or. (!Empty(SE2->E2_SEQBX) .And. SE2->E2_SEQBX == SE5->E5_SEQ)) .And. OHF->(DbSeek(SE2->E2_FILIAL + cIdDocPag))
						lIncluiOHB := .T.
					Else 
						// Entra no Else em cenários de várias baixas com algum imposto sob regime de caixa. 
						// Nesse cenário serão criados OHB de impostos a cada baixa, porém o aRecImp vem com tudo acumulado, ou seja,
						// com os impostos da baixa atual e das anteriores. 
						// Então nesse trecho indica que não serão incluídos OHBs para impostos criados em baixas anteriores.
						lIncluiOHB := .F.
					EndIf
					
					If lIncluiOHB
						cNatImp := OHF->OHF_CNATUR // Pega a natureza da OHF de imposto, pois nela tem a que está na classificação de natureza
						cHistLanc := JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_DESCRIC")
						aAdd(aLancDiv, {cNatImp, cNatTrans, SE2->E2_VALOR, cHistLanc, aRecImp[nImp][2]})
					EndIf
				Next
			EndIf
		Else
			// Faz o repasse para o aLancDiv, ajustando a natureza transitória
			For nImp := 1 To Len(aGetImpLan)
				SE2->(DbGoTo(aGetImpLan[nImp][5]))
				
				// Caso nenhum imposto esteja configurado para regime de caixa (na baixa do título), não precisa consultar sequência de baixa.
				If !lImpBaixa
					lIncluiOHB := .T.
				
				// Caso tenha algum imposto no regime de caixa é necessário consultar a sequência de baixa.
				// Os impostos que estão sob regime de competência (na emissão) não gravam a sequência de baixa na SE2 (campo E2_SEQBX). Além disso 
				// eles serão gerados apenas na primeira baixa. Criado a variável lPrimeiraBx para controlar quando será necessário gerar uma movimentação
				// de estorno caso seja um cancelamento de baixa ou cancelamento de uma compensação.
				// O INSS sempre será sob regime de competência, o parâmetro MV_INSBXCP foi descontinuado.
				ElseIf lImpBaixa .And. ((lPrimeiraBx .And. Empty(SE2->E2_SEQBX)) .Or. (!Empty(SE2->E2_SEQBX) .And. SE2->E2_SEQBX == SE5->E5_SEQ))
					lIncluiOHB := .T.
				EndIf
				
				If lIncluiOHB
					aAdd(aLancDiv, {aGetImpLan[nImp][1], cNatTrans, aGetImpLan[nImp][3], aGetImpLan[nImp][4], aGetImpLan[nImp][5]})
				EndIf
			Next
		EndIf
	EndIf

	RestArea(aAreaOHF)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JExImpLanc
Valida se já existe lançamento OHB de Imposto(Origem) -> Transitória(Destino)

@param  cNatImp   , Natureza de imposto definida na classificação (OHP)
@param  cNatTrans , Natureza transitória usada na OHB
@param  cChvTitP  , Chave do título principal
@param  aChvSE2Pai, Array com a chave do título principal

@return lExistLanc, Indica se já existe lançamento de imposto
@Obs    Função mantida por compatilibidade por conta das movimentações 
        (Lançamentos OHB) no formato antigo.
@author Jorge Martins
@since  16/12/2022
/*/
//-----------------------------------
Static Function JExImpLanc(cNatImp, cNatTrans, cChvTitP, aChvSE2Pai)
Local aArea      := GetArea()
Local aAreaSE5   := SE5->(GetArea())
Local cQryRes    := GetNextAlias()
Local lExistLanc := .F.
Local cAlsSE5    := RetSqlName("SE5")
Local cSeqSE5    := ""
Local cQuery     := ""

	// Busca sequência da baixa do título principal (somente baixa válida)
	// para validar se a OHB do imposto foi gerada no momento da baixa do título principal.
	// Esse é o novo comportamento
	cQuery := " SELECT A.E5_SEQ SE5SEQ"
	cQuery +=   " FROM " + cAlsSE5 + " A"
	cQuery +=  " WHERE A.E5_FILIAL  = '" + aChvSE2Pai[1] + "'"
	cQuery +=    " AND A.E5_PREFIXO = '" + aChvSE2Pai[2] + "'"
	cQuery +=    " AND A.E5_NUMERO  = '" + aChvSE2Pai[3] + "'"
	cQuery +=    " AND A.E5_PARCELA = '" + aChvSE2Pai[4] + "'"
	cQuery +=    " AND A.E5_TIPO    = '" + aChvSE2Pai[5] + "'"
	cQuery +=    " AND A.E5_CLIFOR  = '" + aChvSE2Pai[6] + "'"
	cQuery +=    " AND A.E5_LOJA    = '" + aChvSE2Pai[7] + "'"
	cQuery +=    " AND A.E5_SITUACA <> 'C'"
	cQuery +=    " AND A.E5_TIPODOC <> 'ES'"
	cQuery +=    " AND A.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS(SELECT 1"
	cQuery +=                     " FROM " + cAlsSE5 + " B"
	cQuery +=                    " WHERE B.E5_FILIAL  = A.E5_FILIAL"
	cQuery +=                      " AND B.E5_PREFIXO = A.E5_PREFIXO"
	cQuery +=                      " AND B.E5_NUMERO  = A.E5_NUMERO"
	cQuery +=                      " AND B.E5_PARCELA = A.E5_PARCELA"
	cQuery +=                      " AND B.E5_TIPO    = A.E5_TIPO"
	cQuery +=                      " AND B.E5_CLIFOR  = A.E5_CLIFOR"
	cQuery +=                      " AND B.E5_LOJA    = A.E5_LOJA"
	cQuery +=                      " AND B.E5_SEQ     = A.E5_SEQ"
	cQuery +=                      " AND B.E5_SITUACA <> 'C'"
	cQuery +=                      " AND B.E5_TIPODOC = 'ES'"
	cQuery +=                      " AND B.D_E_L_E_T_ = ' ')"
	cQuery +=    " ORDER BY A.E5_SEQ"

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

	If (cQryRes)->( !Eof() )
		cSeqSE5 := (cQryRes)->SE5SEQ
	EndIf

	(cQryRes)->(DbCloseArea())

	// Se não existir baixa no título principal, indica que está baixando o imposto primeiro.
	// Com isso, pode usar o comportamento novo, já que depois quando baixar o principal, vai usar a regra nova.
	If Empty(cSeqSE5)
		lExistLanc := .T.
	Else

		// Busca pela OHB de imposto com E5_SEQ da baixa do título principal
		// para saber se usará o novo comportamento para gerar as OHB's de impostos
		cQuery := " SELECT COUNT(OHB_CODIGO) QTDLANC "
		cQuery +=   " FROM " + RetSqlName("OHB")
		cQuery +=  " WHERE TRIM(OHB_CPAGTO) = '" + cChvTitP + "' "
		cQuery +=    " AND OHB_NATORI = '" + cNatImp + "' "
		cQuery +=    " AND OHB_NATDES = '" + cNatTrans + "' "
		cQuery +=    " AND OHB_SE5SEQ = '" + cSeqSE5 + "' "
		cQuery +=    " AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

		// Se encontrou o lançamento, lExistLanc será .T.
		lExistLanc := (cQryRes)->( !Eof() ) .And. (cQryRes)->QTDLANC > 0

		(cQryRes)->(DbCloseArea())
	
	EndIf

	RestArea(aAreaSE5)
	RestArea(aArea)

Return lExistLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} JLancImpCP
Indica se existe lançamentos de impostos do contas a pagar.

@return lLancImpCP, Se verdadeiro indica que existe lançamento
                    de baixa para o imposto

@author Jonatas Martins
@since  27/12/2022
/*/
//-------------------------------------------------------------------
Static Function JLancImpCP()
Local aArea      := GetArea()
Local cAlsTemp   := GetNextAlias()
Local cChaveSE2  := SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
Local lLancImpCP := .F.

	BeginSql Alias cAlsTemp
		%NoParser%
		SELECT SUM(A.BAIXA) BAIXA, SUM(A.ESTORNO) ESTORNO
		  FROM (SELECT COUNT(OHB_CODIGO) BAIXA, 0 ESTORNO
		          FROM %Table:OHB%
		         WHERE OHB_FILIAL = %xFilial:OHB%
		           AND OHB_CPAGTO = %Exp:cChaveSE2%
		           AND OHB_NATORI IN (SELECT OHP_CNATUR
		                                FROM %Table:OHP%
		                               WHERE OHP_FILIAL = %xFilial:OHP%
		                                 AND OHP_ORIGEM = '1' // Contas a Pagar
		                                 AND OHP_DEFLAN = '1'
		                                 AND OHP_TIPOMV IN ('IR', 'IS', 'IN', 'PI', 'CO', 'CS')
		                                 AND %NotDel%)
		           AND %NotDel%
		         UNION ALL
		        SELECT 0 BAIXA, COUNT(OHB_CODIGO) ESTORNO
		          FROM %Table:OHB%
		         WHERE OHB_FILIAL = %xFilial:OHB%
		           AND OHB_CPAGTO = %Exp:cChaveSE2%
		           AND OHB_NATDES IN (SELECT OHP_CNATUR
		                                FROM %Table:OHP%
		                               WHERE OHP_FILIAL = %xFilial:OHP%
		                                 AND OHP_ORIGEM = '1' // Contas a Pagar
		                                AND OHP_DEFLAN = '1'
		                                AND OHP_TIPOMV IN ('IR', 'IS', 'IN', 'PI', 'CO', 'CS')
		                                AND %NotDel%)
		           AND %NotDel%) A
	EndSql

	// Caso tenham mais lançamentos de baixa de impostos do que estorno indica que deve realizar o estorno.
	// Caso a quantidade seja a mesma, entende-se que o estorno para a baixa do imposto já foi realizada.
	lLancImpCP := (cAlsTemp)->(!Eof()) .And. (cAlsTemp)->BAIXA > (cAlsTemp)->ESTORNO

	(cAlsTemp)->(DbCloseArea())
	RestArea(aArea)

Return (lLancImpCP)

//-------------------------------------------------------------------
/*/{Protheus.doc} JEstLanSE1
Indica se deve executar o estorno dos lançamentos de impostos/juros/multa
do contas a receber (SE1)

@param cNatureza , Natureza do Imposto/Juros/Multa
@param cChaveSE1 , Chave do título a receber
@param lBxOri    , Indica se na baixa a natureza fica na origem na OHB
                   Obs: Na geração da OHB na baixa, os impostos ficam no destino porém juros/multa ficam na origem
@param nValEst   , Variável passada por referência, usada para indicar o valor do estorno

@return lExecEst, Se .T. indica que existe lançamento de baixa para o imposto

@author Jorge Martins
@since  27/12/2022
/*/
//-------------------------------------------------------------------
Function JEstLanSE1(cNatureza, cChaveSE1, lBxOri, nValEst)
Local aArea      := GetArea()
Local aAreaSE1   := SE1->(GetArea())
Local cQuery     := ""
Local cQryRes    := GetNextAlias()
Local lExecEst   := .F.

Default nValEst  := 0

	cQuery := " SELECT SUM(A.BAIXA) BAIXA, SUM(A.ESTORNO) ESTORNO, SUM(A.VALBAIXA) VALBAIXA, SUM(A.VALEST) VALEST "
	cQuery +=   " FROM ( SELECT COUNT(OHB_CODIGO) BAIXA, 0 ESTORNO, SUM(OHB_VALOR) VALBAIXA, 0 VALEST "
	cQuery +=            " FROM " + RetSqlName("OHB")
	cQuery +=           " WHERE OHB_CRECEB = '" + cChaveSE1 + "'"
	If lBxOri
		cQuery +=         " AND OHB_NATORI = '" + cNatureza + "'"
	Else
		cQuery +=         " AND OHB_NATDES = '" + cNatureza + "'"
	EndIf
	cQuery +=             " AND D_E_L_E_T_ = ' ' "
	cQuery +=           " UNION ALL "
	cQuery +=          " SELECT 0 BAIXA, COUNT(OHB_CODIGO) ESTORNO, 0 VALBAIXA, SUM(OHB_VALOR) VALEST "
	cQuery +=            " FROM " + RetSqlName("OHB")
	cQuery +=           " WHERE OHB_CRECEB = '" + cChaveSE1 + "'"
	If lBxOri
		cQuery +=         " AND OHB_NATDES = '" + cNatureza + "'"
	Else
		cQuery +=         " AND OHB_NATORI = '" + cNatureza + "'"
	EndIf
	cQuery +=             " AND D_E_L_E_T_ = ' ') A "

	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

	// Caso tenham mais lançamentos de baixa de impostos do que estorno indica que deve realizar o estorno.
	// Caso a quantidade seja a mesma, entende-se que o estorno para a baixa do imposto já foi realizada.
	lExecEst := (cQryRes)->(!Eof()) .And. (cQryRes)->BAIXA > (cQryRes)->ESTORNO

	If lExecEst
		nValEst := (cQryRes)->VALBAIXA - (cQryRes)->VALEST
	EndIf

	(cQryRes)->(DbCloseArea())

	RestArea(aAreaSE1)
	RestArea(aArea)

Return lExecEst

//-------------------------------------------------------------------
/*/{Protheus.doc} JVlNatCtOrc
Valida alteração de natureza de títulos/desdobramento gerados pelo 
controle orçamentário (E2_ORIGEM = "JURCTORC")

@param  cNatOld, Código da natureza antiga
@param  cNatSE2, Código da natureza nova (digitado)

@return lNatOk, Indica se já a natureza é válida

@author Reginaldo Borges
@since  12/01/2023
/*/
//-----------------------------------
Function JVlNatCtOrc(cNatOld, cNatSE2, cMsgErro)
Local lNatOk       := .T.
Local aCCJDeFatOld := {}
Local aCCJDeFatNew := {}
Local lExistDesFat := SED->(ColumnPos("ED_DESFAT")) > 0 // @12.1.2310

Default cMsgErro   := STR0147 // "Não é possível alterar a natureza desse Título."

	If lExistDesFat
		aCCJDeFatOld := JurGetDados("SED", 1, xFilial("SED") + cNatOld, {"ED_CCJURI", "ED_DESFAT"})
		aCCJDeFatNew := JurGetDados("SED", 1, xFilial("SED") + cNatSE2, {"ED_CCJURI", "ED_DESFAT"})
	Else
		aCCJDeFatOld := {JurGetDados("SED", 1, xFilial("SED") + cNatOld, "ED_CCJURI")}
		aCCJDeFatNew := {JurGetDados("SED", 1, xFilial("SED") + cNatSE2, "ED_CCJURI")}
	EndIf
	
	If Len(aCCJDeFatOld) > 0
		If Len(aCCJDeFatNew) == 0 .Or. aCCJDeFatOld[1] != aCCJDeFatNew[1] // CCJURI diferentes
			lNatOk := .F.
			If !IsBlind()
				JurMsgErro(cMsgErro,, i18n(STR0148, {AllTrim(cNatOld)}) ) // "Indique uma natureza que possua o mesmo centro de custo jurídico da natureza '#1'."
			EndIf
		ElseIf lExistDesFat .And. Len(aCCJDeFatOld) == 2 .And. Len(aCCJDeFatNew) == 2 .And. !Empty(aCCJDeFatOld[2]) .And. aCCJDeFatOld[2] != aCCJDeFatNew[2] // DESFAT diferentes
			lNatOk := .F.
			If !IsBlind()
				If aCCJDeFatOld[2] == "1" // Natureza antiga gera despesa
					JurMsgErro(cMsgErro,, i18n(STR0149, {AllTrim(cNatOld)}) ) // "Indique uma natureza que gere despesa no faturamento assim como a natureza '#1'."
				Else // Natureza antiga NÃO gera despesa
					JurMsgErro(cMsgErro,, i18n(STR0150, {AllTrim(cNatOld)}) ) // "Indique uma natureza que não gere despesa no faturamento assim como a natureza '#1'."
				EndIf
			EndIf
		EndIf
	EndIf

Return lNatOk

//-------------------------------------------------------------------
/*/{Protheus.doc} JurVldPIX
Valida forma de pagamento para PIX e e-mail do cliente

@param oModel    , Objeto do modelo de dados de Clientes

@return lVldPIX  , Se verdadeiro a forma de pagamento é válida 
                   e existe e-mail cadastrato

@author Jonatas Martins, Victor Hayashi
@since  25/11/2022
/*/
//-------------------------------------------------------------------
Function JurVldPIX(oModel)
Local aArea     := {}
Local aAreaSA6  := {}
Local aAreaF70  := {}
Local aAreaAI0  := {}
Local cModelID  := ""
Local cFPagto   := ""
Local cCodCli   := ""
Local cLojaCli  := ""
Local cChaveBco := ""
Local cEmail    := ""
Local lVldPIX   := .T.

Default oModel  := FWModelActive()

	If OH1->(ColumnPos("OH1_TIPREL")) > 0 .And. ValType(oModel) == "O" // @12.1.2310 - O campo OH1_TIPREL foi criado junto com a opção de pagamento 3=Pix
		cModelID := oModel:GetID()

		If cModelID == "JURA148" // Cliente
			cFPagto   := oModel:GetValue("NUHMASTER", "NUH_FPAGTO")
			cCodCli   := oModel:GetValue("SA1MASTER", "A1_COD")
			cLojaCli  := oModel:GetValue("SA1MASTER", "A1_LOJA")
			cChaveBco := oModel:GetValue("NUHMASTER", "NUH_CBANCO") + oModel:GetValue("NUHMASTER", "NUH_CAGENC") + oModel:GetValue("NUHMASTER", "NUH_CCONTA")
			cEmail    := AllTrim(oModel:GetValue("NUHMASTER", "NUH_CEMAIL"))
			cEmail    := IIF(Empty(cEmail), AllTrim(oModel:GetValue("SA1MASTER", "A1_EMAIL")), cEmail)
		ElseIf cModelID $ "JURA096|JURA056" // Cliente Pagador do Contrato ou Junção
			cFPagto   := oModel:GetValue("NXPDETAIL", "NXP_FPAGTO")
			cCodCli   := oModel:GetValue("NXPDETAIL", "NXP_CLIPG")
			cLojaCli  := oModel:GetValue("NXPDETAIL", "NXP_LOJAPG")
			cChaveBco := oModel:GetValue("NXPDETAIL", "NXP_CBANCO") + oModel:GetValue("NXPDETAIL", "NXP_CAGENC") + oModel:GetValue("NXPDETAIL", "NXP_CCONTA")
		ElseIf cModelID $ "JURA202|JURA203" // Clinete Pagador da Pré-Fatura ou da Fila de Emissão
			cFPagto   := oModel:GetValue("NXGDETAIL", "NXG_FPAGTO")
			cCodCli   := oModel:GetValue("NXGDETAIL", "NXG_CLIPG")
			cLojaCli  := oModel:GetValue("NXGDETAIL", "NXG_LOJAPG")
			cChaveBco := oModel:GetValue("NXGDETAIL", "NXG_CBANCO") + oModel:GetValue("NXGDETAIL", "NXG_CAGENC") + oModel:GetValue("NXGDETAIL", "NXG_CCONTA")
		ElseIf cModelID == "JURA204" // Cliente da Fatura
			cFPagto   := oModel:GetValue("NXAMASTER", "NXA_FPAGTO")
			cCodCli   := oModel:GetValue("NXAMASTER", "NXA_CLIPG")
			cLojaCli  := oModel:GetValue("NXAMASTER", "NXA_LOJPG")
			cChaveBco := oModel:GetValue("NXAMASTER", "NXA_CBANCO") + oModel:GetValue("NXAMASTER", "NXA_CAGENC") + oModel:GetValue("NXAMASTER", "NXA_CCONTA")
			If cFPagto == "3"
				cEmail  := AllTrim(oModel:GetValue("NXAMASTER", "NXA_EMAIL"))
				cEmail  := IIf(Empty(cEmail), AllTrim(JurGetDados("NUH", 1, xFilial("NUH") + cCodCli + cLojaCli, "NUH_CEMAIL")), cEmail)
				cEmail  := IIf(Empty(cEmail), AllTrim(JurGetDados("SA1", 1, xFilial("SA1") + cCodCli + cLojaCli, "A1_EMAIL"  )), cEmail)
				lVldPIX := IIf(Empty(cEmail), JurMsgErro(STR0179, , STR0180), .T.) // "Endereço de e-mail não encontrado." # "Para uso da forma de pagamento igual a: 3=PIX, preencha o e-mail na fatura ou no cadastro do cliente"
			EndIf
		EndIf

		If lVldPIX .And. cFPagto == "3" // Pagar em PIX
			aArea    := GetArea()
			aAreaSA6 := SA6->(GetArea())
			aAreaF70 := F70->(GetArea())
			aAreaAI0 := AI0->(GetArea())

			SA6->(DbSetOrder(1)) // A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON
			If (SA6->(DbSeek(xFilial("SA6") + cChaveBco)))
				F70->(DbSetOrder(1)) // F70_FILIAL + F70_COD + F70_AGENCI + F70_DVAGE + F70_NUMCON + F70_DVCTA
				If !(F70->(DbSeek(xFilial("F70") + SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_DVAGE + SA6->A6_NUMCON + SA6->A6_DVCTA)))
					lVldPIX := JurMsgErro(STR0145, , STR0146) // "Banco não configurado para Pagamento em PIX." # "Para uso da forma de pagamento igual a: 3=PIX, preencha as chaves PIX no cadastro do banco."
				EndIf
			EndIf
		
			If lVldPIX
				If (AI0->(DbSeek(xFilial("AI0") + cCodCli + cLojaCli)))
					If !(AI0->AI0_RECPIX $ "1|2")
						RecLock("AI0", .F.)
						AI0->AI0_RECPIX := '1'
						AI0->(MsUnLock())
					EndIf
				Else
					RecLock("AI0", .T.)
					AI0->AI0_FILIAL := xFilial("AI0")
					AI0->AI0_CODCLI := cCodCli
					AI0->AI0_LOJA   := cLojaCli
					AI0->AI0_RECPIX := '1'
					If !Empty(cEmail)
						AI0->AI0_EMAPIX := cEmail
					EndIf
					AI0->(MsUnLock())
				EndIf
			EndIf

			RestArea(aArea)
			RestArea(aAreaSA6)
			RestArea(aAreaF70)
			RestArea(aAreaAI0)
		EndIf
	EndIf

Return (lVldPIX)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTitAgl
Busca os desdobramentos dos títulos a pagar de origem que gerou os 
títulos aglutinados

@return  aTitulos, Array com os títulos de da aglutinação

@Obs    Função mantida por compatilibidade por conta das movimentações 
        (Lançamentos OHB) no formato antigo.
@author Jorge Martins
@since  16/11/2022
/*/
//-----------------------------------
Static Function JurTitAgl()
Local aArea      := GetArea()
Local aAreaSE2   := SE2->( GetArea() )
Local aTitulos   := {}
Local cTmpSE2    := ""
Local cTmpOHF    := ""
Local cQuery     := ""
Local nValTitPri := 0
Local nValDesd   := 0
Local oStateSE2  := Nil
Local oStateOHF  := Nil

	// Busca os títulos de imposto que foram aglutinados e indica o título de origem (pai) desse imposto
	cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_TITPAI, E2_VALOR "
	cQuery +=   " FROM " + RetSqlName("SE2")
	cQuery +=  " WHERE E2_FILIAL  = ? "
	cQuery +=    " AND E2_AGLIMP  = ? "
	cQuery +=    " AND E2_NATUREZ = ? "
	cQuery +=    " AND D_E_L_E_T_ = ' '"

	oStateSE2 := FWPreparedStatement():New(cQuery)
	oStateSE2:SetString(1, SE2->E2_FILIAL)
	oStateSE2:SetString(2, SE2->E2_NUM)
	oStateSE2:SetString(3, SE2->E2_NATUREZ)
	cQuery  := oStateSE2:GetFixQuery()
	cTmpSE2 := GetNextAlias()
	
	MPSysOpenQuery(cQuery, cTmpSE2)

	SE2->(DbSetOrder(1)) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
	cChvTitP := SE2->E2_FILIAL + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA

	While (cTmpSE2)->( ! Eof() )

		If (SE2->(Dbseek((cTmpSE2)->E2_FILIAL + (cTmpSE2)->E2_TITPAI)))
			nValTitPri := JCPVlBruto(SE2->(Recno())) // Valor Bruto do titulo principal que foi aglutinado.
			cIdDocTit  := FINGRVFK7("SE2", SE2->E2_FILIAL + "|" +  SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA)

			// Busca o valor de cada desdobramento do título para criar os lançamentos de imposto
			cQuery := " SELECT OHF_CITEM, OHF_VALOR VALOR "
			cQuery +=   " FROM " + RetSqlName("OHF") + " OHF "
			cQuery +=  " WHERE OHF.OHF_FILIAL = ? "
			cQuery +=    " AND OHF.OHF_IDDOC = ? "
			cQuery +=    " AND OHF.D_E_L_E_T_ = ' ' "
			
			oStateOHF := FWPreparedStatement():New(cQuery)
			oStateOHF:SetString(1, (cTmpSE2)->E2_FILIAL)
			oStateOHF:SetString(2, cIdDocTit)
			cQuery  := oStateOHF:GetFixQuery()
			cTmpOHF := GetNextAlias()
			
			MPSysOpenQuery(cQuery, cTmpOHF)

			While (cTmpOHF)->( ! Eof() )
				
				nValDesd := (cTmpOHF)->VALOR / nValTitPri * (cTmpSE2)-> E2_VALOR
				
				If Len(aTitulos) == 0 .Or. aScan(aTitulos, {|nTit| nTit[1] ==  cIdDocTit .And. nTit[4] == (cTmpOHF)->OHF_CITEM}) == 0
					aAdd(aTitulos, {cIdDocTit, cChvTitP, nValDesd, (cTmpOHF)->OHF_CITEM})
				EndIf
				(cTmpOHF)->(DbSkip())
			End
			
			(cTmpOHF)->(DbCloseArea())
		EndIf

		(cTmpSE2)->(DbSkip())
	End

	If ValType(oStateOHF) == "O"
		oStateOHF:Destroy()
		FwFreeObj(oStateOHF)
	EndIf
	
	oStateSE2:Destroy()
	FwFreeObj(oStateSE2)

	(cTmpSE2)->(DbCloseArea())

	RestArea(aAreaSE2)
	RestArea(aArea)

Return aTitulos

//-------------------------------------------------------------------
/*/{Protheus.doc} JBuscTitPai
Busca a chave (E2_TITPAI) dos títulos que foram aglutinados com base 
no título de imposto gerado pela aglutinação.

@param cCodFilTit, Filial do título da aglutinação.
@param cCodAglut , Código da aglutinação.
@param cCodNatur , Código da natureza do título da aglutinação.

@return cSE2TitPai, Chave do título pai aglutinado

@Obs    Função mantida por compatilibidade por conta das movimentações 
        (Lançamentos OHB) no formato antigo.
@author Abner Fogaça de Oliveira
@since  13/02/2023
/*/
//-----------------------------------
Static Function JBuscTitPai(cCodFilTit, cCodAglut, cCodNatur)
Local aArea      := GetArea()
Local aAreaSE2   := SE2->(GetArea())
Local cQryRes    := GetNextAlias()
Local cSE2TitPai := ""
Local cQuery     := ""
Local oStateSE2  := Nil 

	cQuery := " SELECT E2_TITPAI"
	cQuery +=  "  FROM " + RetSqlName("SE2")
	cQuery +=  " WHERE E2_FILIAL = ?"
	cQuery +=  "   AND E2_AGLIMP = ? "
	cQuery +=  "   AND E2_NATUREZ = ? "
	cQuery +=  "   AND D_E_L_E_T_ = ' ' "

	oStateSE2 := FWPreparedStatement():New(cQuery)
	oStateSE2:SetString(1, cCodFilTit)
	oStateSE2:SetString(2, cCodAglut)
	oStateSE2:SetString(3, cCodNatur)
	cQuery := oStateSE2:GetFixQuery()

	MPSysOpenQuery(cQuery, cQryRes)

	If (cQryRes)->( !Eof() )
		cSE2TitPai := (cQryRes)->E2_TITPAI
	EndIf
	
	oStateSE2:Destroy()
	FwFreeObj(oStateSE2)

	(cQryRes)->(DbCloseArea())

	RestArea(aAreaSE2)
	RestArea(aArea)

Return cSE2TitPai

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldBxImp
Valida se os títulos de impostos foram pagos ou aglutinados, para barrar
a alteração do título pai.

@param cFilTit , Filial do título pai.
@param cTitPai , Chave do título pai.
@param cTipoImp, Tipo utilizado em títulos de impostos (Ex: TX)
@param lDifNat , Indica se houve alteração da natureza.
@param lDifVal , Indica se houve alteração de valor.

@return lRet, Indica .T. se os campos de natureza e valor NÃO foram alterados

@author Jorge Martins
@since  24/03/2023
/*/
//-----------------------------------
Static Function JVldBxImp(cFilTit, cTitPai, cTipoImp, lDifNat, lDifVal)
Local lRet        := .T.
Local cQuery      := ""
Local cTmpSE2     := ""
Local cMsgErro    := ""
Local cMsgSolucao := ""
Local aTipoImp    := StrTokArr(AllTrim(cTipoImp), "|")
Local cAglutImp   := Space(TamSx3('E2_AGLIMP')[1])
Local oStateSE2   := Nil
	
	If lDifNat .Or. lDifVal

		// Busca se existem títulos de imposto que já tiveram baixa ou que foram aglutinados
		cQuery := " SELECT E2_AGLIMP, E2_VALOR, E2_SALDO "
		cQuery +=   " FROM " + RetSqlName("SE2")
		cQuery +=  " WHERE E2_FILIAL = ? "
		cQuery +=    " AND E2_TITPAI = ? "
		cQuery +=    " AND E2_TIPO IN( ? ) "
		cQuery +=    " AND (E2_SALDO <> E2_VALOR OR E2_AGLIMP <> ?)"
		cQuery +=    " AND D_E_L_E_T_ = ' '"

		oStateSE2 := FWPreparedStatement():New(cQuery)
		oStateSE2:SetString(1, cFilTit)
		oStateSE2:SetString(2, cTitPai)
		oStateSE2:SetIn(3, aTipoImp)
		oStateSE2:SetString(4, cAglutImp)
		cQuery  := oStateSE2:GetFixQuery()
		cTmpSE2 := GetNextAlias()

		MPSysOpenQuery(cQuery, cTmpSE2)

		If (cTmpSE2)->(!Eof())

			If lDifNat
				cMsgErro := STR0151 // "Não é possivel alterar a natureza do título,"
			Else
				cMsgErro := STR0152 // "Não é possivel alterar o valor do título."
			EndIf

			If !Empty((cTmpSE2)->E2_AGLIMP)
				cMsgErro    += STR0153 // "pois um ou mais títulos de impostos foram aglutinados."
				cMsgSolucao := STR0154 // "Para alterar as informações do título será necessário cancelar a aglutinação dos impostos, de forma que todos os títulos de impostos fiquem em aberto."
			ElseIf (cTmpSE2)->E2_VALOR <> (cTmpSE2)->E2_SALDO
				cMsgErro    += STR0155 // "pois um ou mais títulos de impostos estão baixados."
				cMsgSolucao := STR0156 // "Para alterar as informações do título será necessário cancelar as baixas dos impostos, de forma que todos os títulos de impostos fiquem em aberto."
			EndIf

			lRet := JurMsgErro(cMsgErro,, cMsgSolucao)

		EndIf
		
		(cTmpSE2)->(DbCloseArea())

		oStateSE2:Destroy()
		FwFreeObj(oStateSE2)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurUplCnab
Tela fazer upload do arquivo de retorno do CNAB via WebApp

@author Jonatas Martins
@since  24/03/2023
@Obs    Função chamada no fonte FINA426.prw, FINA740.prw e FINA750
/*/
//-----------------------------------
Function JurUplCnab(cTabFin)
Local aButtons   := {}
Local cDirDestin := ""
Local cNameFile  := ""
Local lRet       := .T.

Local oDlg       := Nil
Local oLayer     := Nil
Local oBanco     := Nil
Local oAgenc     := Nil
Local oConta     := Nil
Local oSubCta    := Nil
Local oArquivo   := Nil
Local oBtDir     := Nil

Local cBanco      := ""
Local cAgenc      := ""
Local cConta      := ""
Local cSubCta     := ""
Local cArquivo    := ""
Local cCpoDir     := ""

Default cTabFin := "SE1"
	
	DEFINE MSDIALOG oDlg TITLE STR0157 FROM 010,0 TO 250,500 PIXEL // "Upload do arquivo CNAB"

		oLayer := FWLayer():New()
		oLayer:init(oDlg, .F.)
		oLayer:addCollumn("MainColl", 100, .F.)

		// Banco
		oBanco := TJurPnlCampo():New(05, 20, 42, 20, oLayer:GetColPanel("MainColl"), STR0158, "A6_COD", {||}, {|| cBanco := oBanco:GetValue(), cAgenc := oAgenc:GetValue(), cConta := oConta:GetValue()},,,, "SA6") // "Banco"
		oBanco:SetHelp(STR0159) // "Código do banco."

		// Agência
		oAgenc := TJurPnlCampo():New(05, 70, 42, 20, oLayer:GetColPanel("MainColl"),, "A6_AGENCIA", {||}, {|| cAgenc := oAgenc:GetValue()},,,, "")
		oAgenc:SetHelp(STR0160) // "Código da agência bancária."
		
		// Conta
		oConta := TJurPnlCampo():New(05, 120, 42, 20, oLayer:GetColPanel("MainColl"),, "A6_NUMCON", {||}, {|| cConta := oConta:GetValue()},,,, "")
		oConta:SetValid({|| Empty(oConta:GetValue()) .Or. ExistCpo("SA6", oBanco:GetValue() + oAgenc:GetValue() + oConta:GetValue(), 1)})
		oConta:SetChange({|| IIF(Empty(cSubCta), oSubCta:SetValue(JurGetDados("SEE", 1, xFilial("SEE") + oBanco:GetValue() + oAgenc:GetValue() + oConta:GetValue(), "EE_SUBCTA")), Nil), cSubCta := oSubCta:GetValue()})
		oConta:SetHelp(STR0161) // "Número da conta."

		// Sub-Conta
		oSubCta := TJurPnlCampo():New(05, 170, 42, 20, oLayer:GetColPanel("MainColl"),, "EE_SUBCTA", {||}, {|| cSubCta := oSubCta:GetValue()},,,, "") // "Sub-Conta:"
		oSubCta:SetValid({|| Empty(oSubCta:GetValue()) .Or. ExistCpo("SEE", oBanco:GetValue() + oAgenc:GetValue() + oConta:GetValue() + oSubCta:GetValue(), 1)})
		oSubCta:SetHelp(STR0162) // "Número da Sub Conta."

		// Arquivo
		oArquivo := TJurPnlCampo():New(35, 20, 200, 20, oLayer:GetColPanel("MainColl"), STR0163,, {||}, {|| cArquivo := oArquivo:GetValue()}, Space(50),,,) // "Informe o caminho, nome  e extenção do arquivo:"
		oArquivo:Disable()
		oArquivo:SetHelp(STR0164) // "Indique o diretório e nome do arquivo de retorno do CNAB."
		
		// Botão do diretório
		oBtDir := TButton():New(44, 220, "...", oLayer:GetColPanel("MainColl"), {|| oArquivo:SetValue(AllTrim(cGetFile(STR0165 + "|*.*", STR0166,, "C:\", .F., GETF_LOCALHARD, .F., .T.)))}, 10, 10,,,, .T.) // "Todos os arquivos" # "Selecione o Arquivo"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {|| Iif(ExistCpo("SEE", oBanco:GetValue() + oAgenc:GetValue() + oConta:GetValue() + oSubCta:GetValue(), 1),;
	                                                            Iif(Empty(oArquivo:GetValue()), Alert(STR0167), oDlg:End()), Nil)},; // "Selecione o arquivo!"
	                                                        {||lRet := .F., oDlg:End()},, aButtons)
	
	If lRet
		cArquivo   := oArquivo:GetValue()
		cCpoDir    := IIF(cTabFin == "SE1", "EE_DIRREC", "EE_DIRPAG")
		cDirDestin := AllTrim(JurGetDados("SEE", 1, xFilial("SEE") + cBanco + cAgenc + cConta + cSubCta, cCpoDir))

		If Empty(cDirDestin)
			lRet := JurMsgErro(STR0168, "JurUplCnab", I18N(STR0169, {GetSx3Cache(cCpoDir, "X3_TITULO")})) // "Diretório de destino inválido." # "No cadastro de parâmetros de banco, verifique o conteúdo do campo: '#1'."
		Else
			If File(cArquivo) .Or. FErase(cArquivo,, .T.) <> 0
				cNameFile := SubStr(cArquivo, RAT("\", cArquivo) + 1, Len(cArquivo))
				lRet      := __CopyFile(cArquivo, cDirDestin + cNameFile)
			EndIf

			If lRet
				ApMsgInfo(I18N(STR0170, {cDirDestin})) // "Arquivo copiado para a pasta: #1"
			Else
				lRet := JurMsgErro(STR0171, , STR0172) // "Falha ao copiar arquivo!" # "Tente novamente."
			EndIf
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurCriaDir
Informa para o usuário se deseja criar o novo diretório a ser 
utilizado no retorno do CNAB a Pagar e a Receber

@param cCampo, Campo para o qual será validado o diretório
@param cDir  , Diretório do arquivo de pagamento a ser validado

@return lRet, Se verdadeiro o diretório foi criado com sucesso

@author Reginaldo.Borges
@since  24/04/2023
@Obs    Função chamada no fonte FINA205.PRW
/*/
//-------------------------------------------------------------------
Function JurCriaDir(cCampo, cDir)
Local lRet  := .F.

	If cCampo $ "EE_DIRPAG" .And. MsgYesNo(STR0175, STR0020) // "Diretório de retorno automatico de Pagamento não encontrado. Deseja criar novo diretório.?"##, STR0020
		lRet := .T.
	ElseIf cCampo $ "EE_BKPPAG" .And. MsgYesNo(STR0177, STR0020) // "Diretório de backup não encontrado. Deseja criar novo diretório.?"##,"Atenção"
		lRet := .T.
	ElseIf cCampo $ "EE_DIRREC" .And. MsgYesNo(STR0176, STR0020) // "Diretório de retorno automático de Recebimento não encontrado. Deseja criar novo diretório.?"##,"Atenção"
		lRet := .T.
	ElseIf cCampo $ "EE_BKPREC" .And. MsgYesNo(STR0177, STR0020) // "Diretório de backup não encontrado. Deseja criar novo diretório.?"##,"Atenção"
		lRet := .T.
	EndIf

	If lRet .And. Makedir(cDir) == 0
		MsgInfo(STR0178) // Diretório criado com sucesso.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPixMail
Função para retornar o e-mail na emissão do Pix.

@return cMailPix, E-mail para geração do Pix.

@author Jonatas Martins
@since  02/06/2023
@Obs    Função chamada no fonte FINA892.PRW no método
        LinkPaymentTransaction
/*/
//-------------------------------------------------------------------
Function JurPixMail()
Local aArea    := GetArea()
Local aAreaOHT := {}
Local aAreaNUH := {}
Local cMailPix := ""

	// Execução na emissão da fatura (JURA203) ou alteração da fatura (JURA204)
	If (FWIsInCallStack("JurPIX") .Or. FWIsInCallStack("J203UpdPix")) .And. !Empty(NXA->NXA_EMAIL)
		cMailPix := AllTrim(NXA->NXA_EMAIL)
	ElseIf AliasIndic("OHT") .And. OHT->(ColumnPos("OHT_CFATUR")) > 0 // Execução via SIGAFIN ou monitor PIX
		aAreaOHT := OHT->(GetArea())
		OHT->(DbSetOrder(2)) // OHT_FILIAL + OHT_FILTIT + OHT_PREFIX + OHT_TITNUM + OHT_TITPAR + OHT_TITTPO
		If OHT->(DbSeek(FwXFilial("OHT") + SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)) ;
			.And. NXA->(DbSeek(xFilial("NXA") + OHT->OHT_FTESCR + OHT->OHT_CFATUR)) .And. !Empty(NXA->NXA_EMAIL)
			cMailPix := AllTrim(NXA->NXA_EMAIL)
		EndIf
		RestArea(aAreaOHT)
	EndIf

	// A fatura não possui e-mail
	If Empty(cMailPix)
		aAreaNUH := NUH->(GetArea())
		NUH->(DbSetOrder(1)) // NUH_COD + NUH_LOJA
		If (NUH->(DbSeek(FwXFilial("NUH") + SE1->(E1_CLIENTE+E1_LOJA)))) .And. !Empty(NUH->NUH_CEMAIL)
			cMailPix := AllTrim(NUH->NUH_CEMAIL)
		Else
			cMailPix := AllTrim(SA1->A1_EMAIL)
		EndIf
		RestArea(aAreaNUH)
	EndIf

	RestArea(aArea)
Return cMailPix


//-------------------------------------------------------------------
/*/{Protheus.doc} JurCpoF040
Função para bloquear campos na alteração de títulos a receber

@param aCpos, Campos liberados para alteração no título a receber
              Passado por referência

@author Jorge Martins
@since  19/04/2024

@Obs    Função chamada no fonte FINA040.PRW na função fa040MCpo
/*/
//-------------------------------------------------------------------
Function JurCpoF040(aCpos)
Local aBlqCpo := {}
Local nPosCpo := 0
Local nCpo    := 0

	If AllTrim(SE1->E1_ORIGEM) == "JURA203"
		aBlqCpo := {"E1_VALOR", "E1_VLCRUZ", "E1_NATUREZ", "E1_IRRF", "E1_ISS", "E1_INSS", "E1_PIS", "E1_COFINS", "E1_CSLL", "E1_CODIRRF", "E1_TPDESC"}
		For nCpo := 1 to Len(aBlqCpo)
			nPosCpo := Ascan(aCpos, aBlqCpo[nCpo])
			If nPosCpo > 0
				Adel(aCpos, nPosCpo)
				Asize(aCpos, Len(aCpos) - 1)
			EndIf
		Next
		JurFreeArr(aBlqCpo)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JBxCancPFS
Verifica qual o tipo de baixa e dos títulos do PFS 
(E1_ORIGEM = 'JURA203') para não registrar baixas por CNF nos 
blocos M220 e M620 (cancelamentos/devoluções) da EFD.

Isso deve ser feito, pois os registros de cancelamentos serão registrados
através do cancelamento do documento fiscal.

@param  cMotBx  , Motivo de baixa do título

@return lRegistra, Indica se deve registrar a movimentação na EFD

@author Jorge Martins
@since  15/07/2024
@obs    Função chamada no fonte FINXSPD(FinSpdM220)
/*/
//-------------------------------------------------------------------
Function JBxCancPFS(cMotBx)
Local lRegistra := .T.

	If AllTrim(cMotBx) == "CNF"
		lRegistra := .F.
	EndIf

Return lRegistra

//-------------------------------------------------------------------
/*/{Protheus.doc} JSetImpLan
Preenche o array estático _aImpLanc com a estrutura para geração 
da OHB da parte de impostos do contas a pagar.

Essa função será utilizada somente em cancelamentos de baixas,
e é necessária, pois na chamada da JGrvBxPag no cancelamento da baixa (FINA080)
os títulos de impostos já foram excluídos.

Seu objetivo é deixar armazenado no _aImpLanc os valores dos impostos 
antes dos títulos de impostos já serem excluídos, para serem 
utilizados na função JImpLanc, durante a criação das OHBs via JGrvBxPag 

@param  nRecnoSE2, Recno do título principal
@param  nOpc,      Operação da chamada no financeiro (utilizado para o
                   controle do estorno ou exclusão da compensação - FINA340)

@author Jorge Martins
@since  19/07/2024
@obs    Uso nas funções fa080Can (FINA080) - Cancelamento e baixa
                        FA340Can (FINA340) - Cancelamento de compensação
/*/
//-------------------------------------------------------------------
Function JSetImpLan(nRecnoSE2, nOpc)

Default nOpc := 0

	Iif(nRecnoSE2 == 0, _aImpLanc := {}, JImpLanc(@_aImpLanc, "", nRecnoSE2, nOpc))
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetImpLan
Obtém os valores do array estático _aImpLanc e já faz a limpeza dele
para não ter problemas.

@param  lConsulta, Indica que vai fazer apenas uma consulta pra ver se
                   tem impostos, sem executar a JSetImpLan para limpar

@return aImpLanc, Array com a estrutura para geração das OHBs da 
                  parte de impostos do contas a pagar.

@author Jorge Martins
@since  19/07/2024
/*/
//-------------------------------------------------------------------
Static Function JGetImpLan(lConsulta)
Local aImpLanc := _aImpLanc

Default lConsulta := .F.

	If Len(aImpLanc) > 0 .And. !lConsulta
		JSetImpLan(0) // Faz a limpeza do array estático
	EndIf

Return aImpLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} JFilCompen
Concatena query do filtro da tela de compensação para títulos a pagar
apenas os títulos totalmente desdobrados.

@param cQry, trecho da query montado pela rotina do Financeiro.

@return cFiltro, Expressão com filtro da query

@author Abner Fogaça de Oliveira
@since  04/02/2025
@obs    Função chamada nos fontes FINA340 (FA340QryTi)
/*/
//-------------------------------------------------------------------
Function JFilCompen(cQry)
Local cFiltro := ""

    cFiltro += "AND (SELECT MAX( CASE "
	cFiltro +=                  "WHEN (E2_BASEIRF >= E2_BASEPIS "
	cFiltro +=                   "AND E2_BASEIRF >= E2_BASECOF "
	cFiltro +=                   "AND E2_BASEIRF >= E2_BASECSL "
	cFiltro +=                   "AND E2_BASEIRF >= E2_BASEISS "
	cFiltro +=                   "AND E2_BASEIRF >= E2_BASEINS )"
	cFiltro +=                  "THEN E2_BASEIRF "
	cFiltro +=                  "WHEN (E2_BASEPIS >= E2_BASEIRF "
	cFiltro +=                   "AND E2_BASEPIS >= E2_BASECOF "
	cFiltro +=                   "AND E2_BASEPIS >= E2_BASECSL "
	cFiltro +=                   "AND E2_BASEPIS >= E2_BASEISS "
	cFiltro +=                   "AND E2_BASEPIS >= E2_BASEINS) "
	cFiltro +=                  "THEN E2_BASEPIS "
	cFiltro +=                  "WHEN (E2_BASECOF >= E2_BASEIRF "
	cFiltro +=                   "AND E2_BASECOF >= E2_BASEPIS "
	cFiltro +=                   "AND E2_BASECOF >= E2_BASECSL "
	cFiltro +=                   "AND E2_BASECOF >= E2_BASEISS "
	cFiltro +=                   "AND E2_BASECOF >= E2_BASEINS) "
	cFiltro +=                  "THEN E2_BASECOF "
	cFiltro +=                  "WHEN (E2_BASECSL >= E2_BASEIRF "
	cFiltro +=                   "AND E2_BASECSL >= E2_BASEPIS "
	cFiltro +=                   "AND E2_BASECSL >= E2_BASECOF "
	cFiltro +=                   "AND E2_BASECSL >= E2_BASEISS "
	cFiltro +=                   "AND E2_BASECSL >= E2_BASEINS) "
	cFiltro +=                  "THEN E2_BASECSL "
	cFiltro +=                  "WHEN (E2_BASEISS >= E2_BASEIRF "
	cFiltro +=                   "AND E2_BASEISS >= E2_BASEPIS "
	cFiltro +=                   "AND E2_BASEISS >= E2_BASECOF "
	cFiltro +=                   "AND E2_BASEISS >= E2_BASECSL "
	cFiltro +=                   "AND E2_BASEISS >= E2_BASEINS) "
	cFiltro +=                  "THEN E2_BASEISS "
	cFiltro +=                  "WHEN (E2_BASEINS >= E2_BASEIRF "
	cFiltro +=                   "AND E2_BASEINS >= E2_BASEPIS "
	cFiltro +=                   "AND E2_BASEINS >= E2_BASECOF "
	cFiltro +=                   "AND E2_BASEINS >= E2_BASECSL "
	cFiltro +=                   "AND E2_BASEINS >= E2_BASEISS) "
	cFiltro +=                  "THEN E2_BASEINS "
	cFiltro +=                   "END ) AS MAIOR_VALOR "
	cFiltro +=                  "FROM " + RetSqlName("SE2") "
	cFiltro +=                 "WHERE E2_FILIAL = SE2.E2_FILIAL "
	cFiltro +=                   "AND E2_NUM = SE2.E2_NUM "
	cFiltro +=                   "AND E2_PREFIXO = SE2.E2_PREFIXO "
	cFiltro +=                   "AND E2_TIPO = SE2.E2_TIPO  "
	cFiltro +=                   "AND E2_PARCELA = SE2.E2_PARCELA "
	cFiltro +=                   "AND E2_FORNECE = SE2.E2_FORNECE "
	cFiltro +=                   "AND E2_LOJA = SE2.E2_LOJA  "
	cFiltro +=                   "AND D_E_L_E_T_ = ' ') "
	cFiltro += " = (SELECT SUM(OHF.OHF_VALOR) FROM " + RetSqlName("OHF") + " OHF "
	cFiltro += "WHERE OHF_FILIAL = '" + xFilial("OHF") + "' AND OHF.OHF_IDDOC = FK7.FK7_IDDOC "
	cFiltro += "AND OHF.D_E_L_E_T_ = ' ' GROUP BY OHF.OHF_IDDOC) "
Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} JBusFK4Imp
Retorna os dados dos impostos retidos no título pelo configurador
de tributos (CFGTRIB)

@param cCarteira , Define que irá buscar os impostos no 
                   Contas a Receber (SE1) ou
                   Contas a Pagar (SE2)
@param cIDTitpai , ID do titulo principal (FK7_IDPAI)
@param cIdBxAtual, ID da baixa atual no financeiro

@obs Chamada nos fontes JURA203 e JURA255.

@author Abner Fogaça de Oliveira
@since 05/09/2025
/*/
//-------------------------------------------------------------------
Function JBusFK4Imp(cCarteira,cIDTitpai,cIdBxAtual)
Local oQuery    := Nil
Local cQuery    := ""
Local cAlias    := ""
Local aDadosImp := {}
Local aParams   := {}

Default cCarteira  := ""
Default cIDTitpai  := ""
Default cIdBxAtual := ""

	cQuery := " SELECT FK4.FK4_IMPOS, FK4.FK4_BASIMP, FK4.FK4_VALOR"
	cQuery +=   " FROM " + RetSqlName("FK4") + " FK4"
	cQuery +=  " INNER JOIN " + RetSqlName("FK3") + " FK3 "
	cQuery +=     " ON FK3_FILIAL = FK4_FILIAL
	cQuery +=    " AND FK3_IDRET = FK4_IDFK4"
	cQuery +=    " AND FK3.FK3_TABORI = ? "
	aAdd(aParams, {"C", cCarteira})
	cQuery +=    " AND FK3.FK3_STATUS = ?"
	aAdd(aParams, {"C", "1"})
	cQuery +=    " AND FK3.D_E_L_E_T_ = ?"
	aAdd(aParams, {"C", " "})
	cQuery +=  " WHERE FK4.FK4_IDORIG IN (?)"
	aAdd(aParams, {"IN", {cIdBxAtual, cIDTitpai}})
	cQuery +=    " AND FK4.FK4_STATUS = ?"
	aAdd(aParams, {"C", "1"})
	cQuery +=    " AND FK4.D_E_L_E_T_ = ?"
	aAdd(aParams, {"C", " "})
	
	oQuery  := FWPreparedStatement():New(cQuery)
	oQuery  := JQueryPSPr(oQuery, aParams)
	cQuery  := oQuery:GetFixQuery()
	cAlias  := GetNextAlias()
	
	MpSysOpenQuery(cQuery,cAlias)
	
	While !(cAlias)->(Eof())
		aAdd(aDadosImp, {(cAlias)->FK4_IMPOS, (cAlias)->FK4_BASIMP, (cAlias)->FK4_VALOR})
		(cAlias)->(DbSkip())
	EndDo
	
	(cAlias)->(dbCloseArea())
	
Return aDadosImp
