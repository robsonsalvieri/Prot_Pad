#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136.CH"

#DEFINE IND_ORIGEM_BROWSE      1
#DEFINE IND_ORIGEM_MODEL       2
#DEFINE IND_ORIGEM_ATUALIZACAO 3
#DEFINE MVPAR15_SIM            1
#DEFINE MVPAR16_COLOCADOS      1
#DEFINE MVPAR16_FATURADOS      2
#DEFINE MVPAR16_AMBOS          3
#DEFINE MVPAR16_NAO            4
#DEFINE MVPAR17_DIARIO         1
#DEFINE MVPAR17_SEMANAL        2
#DEFINE MVPAR17_QUINZENAL      3
#DEFINE MVPAR17_MENSAL         4
#DEFINE MVPAR18_PARA_FRENTE    1
#DEFINE MVPAR20_DTENTREGA      1
#DEFINE MVPAR20_DTFATURA       2
#DEFINE VOL_BUFFER           200

Static _aDelDem     := {}                //Array com as demandas deletadas para integrar com o MRP
Static _aMensagem   := {}                //Mensagens de erro na validação das demandas
Static _l136AtuAuto := .F.               //Indica se está sendo executado pela rotina automática do pcpa136atu
Static _lIntMrp     := .F.               //Variáveis de controle para a integração do MRP
Static _lOnline     := .F.               //Variáveis de controle para a integração do MRP
Static _lTemErro    := .F.               //Identifica se tem erro na integração
Static _lParLocal   := .F.               //Proteção para as novas perguntas (Armazém De/Até)
Static _lUsaBZ      := .F.               //Indica se deve usar a SBZ (MV_ARQPROD)
Static _lVRRev      := Nil               //Indica se o campo VR_REV esta no dicionario de dados.
Static _oTmpInMrp   := Nil               //Tabela temporária para integração de demandas com o MRP
Static _oTmpPrevs   := Nil               //Tabela temporária para utilizar no desconto de Pedidos de venda com Previsões de venda
Static _nOrigImp    := IND_ORIGEM_BROWSE //Indica a origem da importação (Browse, Model, Atualização)


/*/{Protheus.doc} PCPA136Imp
Função para importar documentos para a tabela de demandas (SVR)
@type  Function
@author lucas.franca
@since 24/01/2019
@param  oModel , Object , Modelo de dados. Utilizado quando a importação é realizada dentro da edição das demandas.
@return lStatus, Logical, Identifica se a importação foi executada ou não.
@version P12
/*/
Function PCPA136Imp(oModel)
	Local aArea      := GetArea()
	Local lStatus    := .T.
	Local cDemanda   := ""
	Local nMinSeq    := 0
	Local nIndex     := 0
	Local dDataIni   := Date()
	Local dDataFim   := Date()

	//Se receber o modelo de dados, utiliza as informações do modelo.
	If oModel != Nil
		P136SetOri(IND_ORIGEM_MODEL)
		cDemanda := oModel:GetModel("SVB_MASTER"):GetValue("VB_CODIGO")
		dDataIni := oModel:GetModel("SVB_MASTER"):GetValue("VB_DTINI")
		dDataFim := oModel:GetModel("SVB_MASTER"):GetValue("VB_DTFIM")

		//Pega a maior sequência já utilizada.
		For nIndex := 1 To oModel:GetModel("SVR_DETAIL"):Length()
			If oModel:GetModel("SVR_DETAIL"):IsDeleted(nIndex)
				Loop
			EndIf
			If oModel:GetModel("SVR_DETAIL"):GetValue("VR_SEQUEN",nIndex) > nMinSeq
				nMinSeq := oModel:GetModel("SVR_DETAIL"):GetValue("VR_SEQUEN",nIndex)
			EndIf
		Next nIndex
	Else
		cDemanda := SVB->VB_CODIGO
		dDataIni := SVB->VB_DTINI
		dDataFim := SVB->VB_DTFIM
		nMinSeq  := 1
	EndIf

	/*
		Valores do pergunte PCP136IMP:
		MV_PAR01 - Importa pedidos de venda?	- 1-Sim; 2-Não.
		MV_PAR02 - Importa previsão de vendas?	- 1-Sim; 2-Não.
		MV_PAR03 - Importa plano mestre?		- 1-Sim; 2-Não.
		MV_PAR04 - Importa empenhos de projeto?	- 1-Sim; 2-Não.
		MV_PAR05 - Data inicial?				- Range inicial de data.
		MV_PAR06 - Data final?					- Range final de data.
		MV_PAR07 - De produto?					- Range inicial de produto.
		MV_PAR08 - Até produto?					- Range final de produto.
		MV_PAR09 - De tipo de material?			- Range inicial de tipo de produto. (B1_TIPO)
		MV_PAR10 - Até tipo de material?		- Range final de tipo de produto.   (B1_TIPO)
		MV_PAR11 - De grupo de material?		- Range inicial de grupo de produto.(B1_GRUPO)
		MV_PAR12 - Até grupo de material?		- Range final de grupo de produto.  (B1_GRUPO)
		MV_PAR13 - De documento PV/PMP?			- Range inicial de documentos.
		MV_PAR14 - Até documento PV/PMP?		- Range final de documentos.
		MV_PAR15 - Considera PV Bloq. Crédito?	- Considera pedidos com bloqueio de crédito? 1-Sim; 2-Não.
		MV_PAR16 - Desconta PV da Previsão?		- Se desconta Pedido de venda da previsão. 1-Colocados;2-Faturados;3-Ambos;4-Não.
		MV_PAR17 - Periodicidade				- 1-Diário; 2-Semanal; 3-Quinzenal; 4-Mensal; 5-Trimestral; 6-Semestral.
		MV_PAR18 - Direção						- 1-Para frente; 2-Ambas.
		MV_PAR19 - Exibe inconsistências?		- Abre a tela com os registros que não serão importados? 1-Sim; 2-Não.
		MV_PAR20 - Considera Data?              - 1-Entrega;2-Faturamento
		MV_PAR21 - Utiliza armazém origem?      - 1-Sim;2-Não
		MV_PAR22 - Do Armazém?					- Range inicial do Armazém
		MV_PAR23 - Ate o Armazém?				- Range final do Armazém
	*/

	lStatus := Pergunte("PCP136IMP")

	If ValType(MV_PAR20) != "N"
		MV_PAR20 := 1 //Default do MV_PAR20
	EndIf

	If lStatus
		//Só permite continuar se as datas informadas estiverem corretas.
		While lStatus
			If MV_PAR05 < dDataIni .Or. MV_PAR06 > dDataFim
				Help(' ',1,"Help" ,,STR0045 + AllTrim(cDemanda) + ".",; //"Data inicial/final não estão dentro do período da demanda "
				     2,0,,,,,, {STR0046 + DtoC(dDataIni) + STR0027 + DtoC(dDataFim) + "."}) //"Informe a data inicial e final que esteja entre os dias " XXX " e " XXX.
				lStatus := Pergunte("PCP136IMP")
			ElseIf (MV_PAR05 > MV_PAR06)
				Help(' ',1,"Help" ,,STR0047,; //"Data inicial não pode ser maior que a data final."
				     2,0,,,,,, {STR0048}) //"Informe a data inicial inferior à data final."
				lStatus := Pergunte("PCP136IMP")
			Else
				Exit
			EndIf
		End
	EndIf

	If lStatus
		//Executa a importação
		Processa({|| P136Import(cDemanda, @lStatus, nMinSeq)}, STR0049, STR0050, .F.) //"Importando Demandas" - "Aguarde..."
	EndIf

	RestArea(aArea)

Return lStatus

/*/{Protheus.doc} ModelDef
Definição do Modelo (Log de Importação)

@type  Static Function
@author Marcelo Neumann
@since 23/04/2019
@version P12
@return oModel
/*/
Static Function ModelDef()

	Local oStruCab := FWFormStruct(1, "SVB")
	Local oStruDet := FWFormStruct(1, "SVR", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|VR_TIPO|VR_PROD|VR_QUANT|VR_DATA|"})
	Local oModel   := MPFormModel():New('PCPA136Imp')

	oStruDet:SetProperty("VR_PROD" , MODEL_FIELD_OBRIGAT, .F.)
	oStruDet:SetProperty("VR_QUANT", MODEL_FIELD_OBRIGAT, .F.)
	oStruDet:SetProperty("VR_DATA" , MODEL_FIELD_OBRIGAT, .F.)
	oStruDet:AddField(STR0077  , ; // [01]  C   Titulo do campo  - "Motivo"
	                  STR0077  , ; // [02]  C   ToolTip do campo - "Motivo"
	                  "CMOTIVO", ; // [03]  C   Id do Field
	                  "C"      , ; // [04]  C   Tipo do campo
	                  100      , ; // [05]  N   Tamanho do campo
	                  0        , ; // [06]  N   Decimal do campo
	                  NIL, NIL, NIL, .F., NIL, .F., .F., .T.)

	//FLD_MASTER - Modelo do cabeçalho (não visível)
	oModel:AddFields("FLD_MASTER", /*cOwner*/, oStruCab)
	oModel:GetModel("FLD_MASTER"):SetDescription(STR0078) //"Cabeçalho - Tela de Log"
	oModel:GetModel("FLD_MASTER"):SetOnlyQuery(.T.)

	//GRID_LOG - Grid com o Log
	oModel:AddGrid("GRID_LOG", "FLD_MASTER", oStruDet)
	oModel:GetModel("GRID_LOG"):SetDescription(STR0079) //"Logs"
	oModel:SetRelation("GRID_LOG", { { 'VR_FILIAL', 'xFilial("SVR")' },{ 'VR_CODIGO', 'VB_CODIGO' } }, SVR->( IndexKey( 1 ) ) )
	oModel:GetModel("GRID_LOG"):SetOptional(.T.)
	oModel:GetModel("GRID_LOG"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_LOG"):SetMaxLine(50000)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View (Log de Importação)
@type  Static Function
@author Marcelo Neumann
@since 22/04/2019
@version P12
@return oView
/*/
Static Function ViewDef()

	Local oView    := FWFormView():New()
	Local oStruCab := FWFormStruct(2, "SVB")
	Local oStruDet := FWFormStruct(2, "SVR", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|VR_TIPO|VR_PROD|VR_QUANT|VR_DATA|"})

	oStruDet:SetProperty("VR_TIPO" , MVC_VIEW_ORDEM, "01")
	oStruDet:SetProperty("VR_PROD" , MVC_VIEW_ORDEM, "02")
	oStruDet:SetProperty("VR_QUANT", MVC_VIEW_ORDEM, "03")
	oStruDet:SetProperty("VR_DATA" , MVC_VIEW_ORDEM, "04")
	oStruDet:AddField("CMOTIVO",; // [01]  C   Nome do Campo
	                  "05"     ,; // [02]  C   Ordem
	                  STR0077  ,; // [03]  C   Titulo do campo    - "Motivo"
	                  STR0077  ,; // [04]  C   Descricao do campo - "Motivo"
	                  NIL      ,; // [05]  A   Array com Help
	                  "C"      ,; // [06]  C   Tipo do campo
	                  NIL, NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T.)

	oView:SetModel(FWLoadModel("PCPA136Imp"))

	//V_FLD_MASTER - View do Cabeçalho
	oView:AddField("V_FLD_MASTER", oStruCab, "FLD_MASTER")
	oView:CreateHorizontalBox("BOX_HEADER", 0)
	oView:SetOwnerView("V_FLD_MASTER", 'BOX_HEADER')

	//V_GRID_LOG - View da Grid de Log
	oView:AddGrid("V_GRID_LOG", oStruDet ,"GRID_LOG")
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_LOG", 'BOX_GRID')

Return oView

/*/{Protheus.doc} P136Import
Função principal da importação. A partir desta função são disparadas as funções para importar as tabelas parametrizadas.

@type Function
@author lucas.franca
@since 25/01/2019
@version P12
@param 01 cDemanda   , character, Código da demanda que será utilizada para importar os registros.
@param 02 lStatus    , logical  , Parâmetro por referência. Identifica se a importação foi executada.
@param 03 nMinSeq    , numeric  , Sequêncial mínimo da SVR.
@param 04 cMensagem  , character, Parâmetro por referência. Retorna a mensagem de erro caso ocorra.
@param 05 l136AtuAuto, logical  , Parâmetro para indicar se está sendo processando o execauto do PCPA136Atu
@return Nil
/*/
Function P136Import(cDemanda, lStatus, nMinSeq, cMensagem, aMsgImp, l136AtuAuto)

	Local oModelImp     := FWLoadModel("PCPA136Imp")
	Local cQuery        := ""
	Local nCount        := 0
	Local nTotal        := 0
	Local nTotExcl      := 0
	Local lHouveErro    := .F.
	Local lImpArmz      := .T.

	Default aMsgImp     :={}
	Default l136AtuAuto := .F.

	_l136AtuAuto := l136AtuAuto

	If MV_PAR16 != MVPAR16_NAO
		//Se irá descontar pedidos de venda das previsões, cria a temporária para controle dos dados
		NewTmpPrev()
	EndIf

	//Verifica se irá integrar com o MRP
	_lIntMrp := .F.
	_lOnline := .F.

	_lIntMrp := IntNewMRP("MRPDEMANDS", @_lOnline)
	If _lIntMrp .And. _lOnline
		//Cria tabela temporária para integração dos dados do MRP.
		_oTmpInMrp := P136APITMP()
		//Inicializa o array de demandas deletadas para a integração com o MRP.
		_aDelDem := {}
	EndIf

	_lParLocal := P136ParExt("PCP136IMP", 22) .And. P136ParExt("PCP136IMP", 23)
	_lUsaBZ    := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"

	//Inicia transação para manter a base íntegra em caso de erros.
	BEGIN TRANSACTION

	//Trava o registro para não ser alterado por outro usuário
	If _nOrigImp <> IND_ORIGEM_MODEL
		//Somente é necessário travar o registro quando a importação estiver sendo feita pela opção do Browse.
		SoftLock("SVB")
	EndIf

	If !l136AtuAuto
		oModelImp:SetOperation(MODEL_OPERATION_INSERT)
		oModelImp:Activate()
	EndIf

	If MV_PAR01 == 1 //Importa pedido de venda
		nTotal++
	EndIf
	If MV_PAR02 == 1 //Importa previsão de venda
		nTotal++
	EndIf
	If MV_PAR03 == 1 //Importa plano mestre
		nTotal++
	EndIf
	If MV_PAR04 == 1 //Importa Empenhos de Projeto.
		nTotal++
	EndIf

	If !_l136AtuAuto
		//Total da barra de progresso
		ProcRegua(nTotal*2)
	EndIf

	//Valida pedido de venda.
	If MV_PAR01 == 1
		If !_l136AtuAuto
			IncreBarra(STR0051)  //"Validando informações dos Pedidos de Venda."
		EndIf
		If !VldImpPDV(cDemanda)
			lHouveErro := .T.
		EndIf
	EndIf

	//Valida previsão de venda
	If MV_PAR02 == 1
		If !_l136AtuAuto
			IncreBarra(STR0052) //"Validando informações das Previsões de Venda."
		EndIf
		If !VldImpPRV(cDemanda)
			lHouveErro := .T.
		EndIf
	EndIf

	//Valida plano mestre
	If MV_PAR03 == 1
		If !_l136AtuAuto
			IncreBarra(STR0053) //"Validando informações do Plano Mestre de Produção."
		EndIf
		If !VldImpPMP(cDemanda)
			lHouveErro := .T.
		EndIf
	EndIf

	//Valida Empenhos de projeto
	If MV_PAR04 == 1
		If !_l136AtuAuto
			IncreBarra(STR0054) //"Validando informações dos Empenhos de Projeto."
		EndIf
		If !VldImpEMP(cDemanda)
			lHouveErro := .T.
		EndIf
	EndIf

	//Se não foi possível importar todas as demandas, exibe mensagem.
	If lHouveErro
		//Exibe inconsistências?
		If MV_PAR19 == 1 .And. !_l136AtuAuto
			Help(' ',1,"Help",,STR0055,2,0,,,,,,) //"Alguns registros não serão importados pois não atendem todos os critérios de validação deste programa."

			oModelImp:nOperation := MODEL_OPERATION_VIEW
			FWExecView(STR0071             , ; //Titulo da janela - "Registros inconsistentes"
					   'PCPA136Imp'        , ; //Nome do programa-fonte
					   MODEL_OPERATION_VIEW, ; //Indica o código de operação
					   NIL                 , ; //Objeto da janela em que o View deve ser colocado
					   NIL                 , ; //Bloco de validação do fechamento da janela
					   NIL                 , ; //Bloco de validação do botão OK
					   55                  , ; //Percentual de redução da janela
					   NIL                 , ; //Botões que serão habilitados na janela
					   NIL                 , ; //Bloco de validação do botão Cancelar
					   NIL                 , ; //Identificador da opção do menu
					   NIL                 , ; //Indica o relacionamento com os botões da tela
					   oModelImp)              //Model que será usado pelo View
		EndIf

		_lTemErro := .T.
	Else
		_lTemErro := .F.
	EndIf

	//Executa a importação
	nTotExcl := VldDeleted(cDemanda)
	nTotal   := 0

	If P136ParExt("PCP136IMP", 21)
		lImpArmz := MV_PAR21 == 1
	EndIf

	//Importa pedido de venda.
	If MV_PAR01 == 1
		If !_l136AtuAuto
			IncreBarra(STR0056) //"Importando Pedidos de Venda."
		EndIf
		nTotal += ImportaPDV(cDemanda,nMinSeq,lImpArmz)
	EndIf

	//Importa previsão de venda
	If MV_PAR02 == 1 .And. nTotal > -1
		If !_l136AtuAuto
			IncreBarra(STR0057) //"Importando Previsões de Venda."
		EndIf
		nTotal += ImportaPRV(cDemanda,nMinSeq,lImpArmz)
	EndIf

	//Importa plano mestre
	If MV_PAR03 == 1 .And. nTotal > -1
		If !l136AtuAuto
			IncreBarra(STR0058) //"Importando Plano Mestre de Produção."
		EndIf
		nTotal += ImportaPMP(cDemanda,nMinSeq,lImpArmz)
	EndIf

	//Importa Empenhos de projeto
	If MV_PAR04 == 1 .And. nTotal > -1
		If !l136AtuAuto
			IncreBarra(STR0059) //"Importando Empenhos de Projeto."
		EndIf
		nTotal += ImportaEMP(cDemanda,nMinSeq,lImpArmz)
	EndIf

	If nTotal >= 1 .Or. nTotExcl > 0
		//Verifica se existem registros na demanda. Se não existir, a demanda será deletada.
		cQuery := " SELECT DISTINCT SVR.VR_CODIGO "
		cQuery +=   " FROM " + RetSqlName("SVR") + " SVR "
		cQuery +=  " WHERE SVR.VR_FILIAL  = '" + xFilial("SVR") + "' "
		cQuery +=    " AND SVR.VR_CODIGO  = '" + cDemanda + "' "
		cQuery +=    " AND SVR.D_E_L_E_T_ = ' ' "

		nCount := CountRegs(cQuery)
		If nCount < 1
			nTotal := 0
			//Não existem registros de demanda. Exclui a tabela mestre do cadastro da demanda.
			SVB->(dbSetOrder(1))
			If SVB->(dbSeek(xFilial("SVB")+cDemanda))
				RecLock("SVB",.F.)
					SVB->(dbDelete())
				SVB->(MsUnLock())
			EndIf
		EndIf
	EndIf

	If nTotal < 1
		If nTotal == 0
			If nTotExcl > 0
				If nCount < 1
					cMensagem := STR0092 //"A demanda foi excluída pois os registros importados não existem mais na origem."
					If _nOrigImp <> IND_ORIGEM_ATUALIZACAO
						Help(' ', 1, "Help", , STR0092, 2,0) //"A demanda foi excluída pois os registros importados não existem mais na origem."
					EndIf
				EndIf
			Else
				//Se teve registro com erro e não abriu a tela de inconsistência, informa na mensagem que alguns registros não foram importados
				If _lTemErro .And. MV_PAR19 == 2
					If _nOrigImp <> IND_ORIGEM_ATUALIZACAO
						Help(' ', 1, "Help", , STR0064 + ; //"Não existem registros para importação com os filtros selecionados."
							 CHR(13)+CHR(10) + STR0080,  ; //"Alguns registros foram desconsiderados por não atenderem todos os critérios de validaçao deste programa."
							 1, 0, , , , , ,  {STR0081})   //"Revise os parâmetros ou marque a opção 'Exibe inconsistências?' na importação para verificar os registros que foram desconsiderados."
					EndIf
				Else
					If _nOrigImp <> IND_ORIGEM_ATUALIZACAO
						Help(' ', 1, "Help", , STR0064, 2, 0) //"Não existem registros para importação com os filtros selecionados."
					EndIf
				EndIf
				cMensagem := STR0064 //"Não existem registros para importação com os filtros selecionados."
			EndIf
		EndIf

		lStatus := .F.
	EndIf

	//Libera o registro para edição.
	If _nOrigImp <> IND_ORIGEM_MODEL
		SVB->(MsUnLock())
	EndIf

	//Finaliza a transação.
	END TRANSACTION

	//Importação realizada, irá integrar estas demandas com o MRP.
	If _lIntMrp .And. _lOnline
		intDemMrp(cDemanda)
	EndIf

	If MV_PAR16 != MVPAR16_NAO
		//Se desconta pedidos de venda das previsões, delete a temporária de controle dos dados
		DelTmpPrev()
	EndIf

	//Apaga a tabela temporária de integração com o MRP
	If _lIntMrp .And. _lOnline
		_oTmpInMrp:Delete()
		_oTmpInMrp := Nil
	EndIf

	If ExistBlock("P136FIM")
		ExecBlock("P136FIM",.F.,.F.,{cDemanda})
	EndIf

	If _l136AtuAuto
		aMsgImp := aClone(_aMensagem)
	EndIf

Return Nil

/*/{Protheus.doc} VldImpPMP
Função para validar se todos os registros poderão ser importados.
@type  Static Function
@author lucas.franca
@since 28/01/2019
@version P12
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@return lRet   , logical  , Identifica se todos os registros podem ser importados.
/*/
Static Function VldImpPMP(cDemanda)
	Local lRet       := .T.
	Local cQueryBase := getQryPMP("INSERT", .T.) //Estrutura da query

	//Valida se todos os dados retornados pela query são válidos.
	lRet := VldImport(cQueryBase,"SHC.HC_DATA","SHC.R_E_C_N_O_","3",cDemanda,"SHC.HC_PRODUTO","SHC.HC_QUANT", "SVR.VR_CODIGO")
Return lRet

/*/{Protheus.doc} getQryPMP
Retorna a query com os filtros para importação do PMP
@type  Static Function
@author lucas.franca
@since 28/01/2019
@version P12
@param cOperacao, character, tipo de operação realizada
@param lValid, lógico, define se a query é montada para validação
@return cQuery , Character, Query com os filtros para importação do PMP
/*/
Static Function getQryPMP(cOperacao, lValid)
	Local cBanco    := AllTrim(Upper(TcGetDb()))
	Local cQuery    := ""
	Local cRetPe    := ""
	Default lValid  := .F.

	cQuery := " SELECT 'FIELDS' FLD "

	If cBanco == "ORACLE" .And. cOperacao == "UPDATE"
		cQuery +=   " FROM " + RetSqlName("SVR")
		cQuery +=  " INNER JOIN " + RetSqlName("SHC") + " SHC"
		cQuery +=     " ON SHC.HC_FILIAL  = '" + xFilial("SHC") + "'"
		cQuery +=    " AND SHC.D_E_L_E_T_ = ' '"
		cQuery +=    " AND SHC.HC_OP      = ' '"
		cQuery +=    " AND SHC.HC_STATUS  = ' '"
		cQuery +=    " AND SHC.HC_QUANT   > 0"
		cQuery +=    " AND SHC.HC_DATA    BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'"
		cQuery +=    " AND SHC.HC_PRODUTO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"
		cQuery +=    " AND SHC.HC_DOC     BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "'"
		cQuery +=    " AND " + RetSqlName("SVR") + ".D_E_L_E_T_ = ' '"
		cQuery +=    " AND " + RetSqlName("SVR") + ".VR_FILIAL  = '" + xFilial("SVR") + "'"
		cQuery +=    " AND " + RetSqlName("SVR") + ".VR_REGORI  = SHC.R_E_C_N_O_"
		cQuery +=  " WHERE EXISTS (SELECT 1"
		cQuery +=                  " FROM "+ RetSqlName("SB1") + " SB1"
		If _lUsaBZ
			cQuery +=              " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ"
			cQuery +=                " ON SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "'"
			cQuery +=               " AND SBZ.BZ_COD = SB1.B1_COD"
			cQuery +=               " AND SBZ.D_E_L_E_T_ = ' '"
		EndIf
		cQuery +=                 " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cQuery +=                   " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=                   " AND SB1.B1_COD     = SHC.HC_PRODUTO "
		cQuery +=                   " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"
		If _lParLocal
			cQuery +=               " AND (CASE
			cQuery +=                       " WHEN SHC.HC_LOCAL <> ' ' THEN SHC.HC_LOCAL"
			If _lUsaBZ
				cQuery +=                   " WHEN SBZ.BZ_LOCPAD <> ' ' THEN SBZ.BZ_LOCPAD"
			EndIf
			cQuery +=                       " ELSE SB1.B1_LOCPAD"
			cQuery +=                    " END) BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "'"
		EndIf
		cQuery +=                   " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "')"
	Else
		cQuery +=   " FROM " + RetSqlName("SHC") + " SHC "
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB1.B1_COD     = SHC.HC_PRODUTO "
		cQuery +=    " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		cQuery +=    " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
		If lValid
			cQuery += " INNER JOIN " + RetSqlName("SVR") + " SVR "
			cQuery +=    " ON SHC.HC_PRODUTO = SVR.VR_PROD"
			cQuery +=   " AND SHC.HC_DATA = SVR.VR_DATA"
			cQuery +=   " AND SVR.VR_REGORI = SHC.R_E_C_N_O_"
			cQuery +=   " AND SVR.D_E_L_E_T_ = ' '"
		EndIf
		If _lUsaBZ
			cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ"
			cQuery +=    " ON SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "' "
			cQuery +=   " AND SBZ.BZ_COD = SB1.B1_COD"
			cQuery +=   " AND SBZ.D_E_L_E_T_ = ' '"
		EndIf
		cQuery += " WHERE SHC.HC_FILIAL  = '" + xFilial("SHC") + "' "
		cQuery +=   " AND SHC.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND SHC.HC_OP      = ' ' "
		cQuery +=   " AND SHC.HC_QUANT   > 0 "
		cQuery +=   " AND SHC.HC_STATUS  = ' ' "
		cQuery +=   " AND SHC.HC_DATA    BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
		cQuery +=   " AND SHC.HC_PRODUTO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery +=   " AND SHC.HC_DOC     BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "

		If _lParLocal
			cQuery += " AND (CASE
			cQuery +=         " WHEN SHC.HC_LOCAL <> ' ' THEN SHC.HC_LOCAL"
			If _lUsaBZ
				cQuery +=     " WHEN SBZ.BZ_LOCPAD <> ' ' THEN SBZ.BZ_LOCPAD"
			EndIf
			cQuery +=         " ELSE SB1.B1_LOCPAD"
			cQuery +=      " END) BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "'"
		EndIf
	EndIf

	// Ponto de entrada para o usuário adicionar seus filtros na importação
	If ExistBlock("P136FIL")
		cRetPe := ExecBlock("P136FIL", .F., .F., "SHC")
		If !Empty(cRetPe)
			cQuery += " AND " + cRetPe
		EndIf
	EndIf

Return cQuery

/*/{Protheus.doc} getSqlSeq
Gera query SQL para geração do campo VR_SEQUEN

@param cField	- Campo da consulta para gerar o contador de registros.
@param cDemanda - Código da demanda que será utilizada.
@param nMinSeq  - Sequêncial mínimo da SVR
@return cSqlRecno	- Query montada para busca do RECNO das tabelas.
@author lucas.franca
@since 28/01/2019
@version 1.0
@return Nil
@example
	getSqlSeq(SHC.R_E_C_N_O_","DEMANDA01",1)
/*/
Static Function getSqlSeq(cField,cDemanda,nMinSeq)
	Local cSqlRecno := ""

	Default nMinSeq := 1

	cSqlRecno += "("
	cSqlRecno += " ( " + ChangeQuery("SELECT ISNULL(MAX(SVRCNT.VR_SEQUEN),"+cValToChar(nMinSeq)+") " +;
	                            " FROM "+RetSqlName("SVR") + " SVRCNT " +;
							   " WHERE SVRCNT.VR_FILIAL  = '" + xFilial("SVR") + "' " +;
							     " AND SVRCNT.D_E_L_E_T_ = ' ' " +;
	                             " AND SVRCNT.VR_CODIGO  = '" + cDemanda + "'" ) + " ) "
	cSqlRecno +=              " + ROW_NUMBER() OVER ( ORDER BY "+cField+" ) "
	cSqlRecno += ") "

Return cSqlRecno

/*/{Protheus.doc} VldImport
Função para validar os dados que serão importados, identificando se existem registros que não atendem as regras de validação.
@type  Static Function
@author lucas.franca
@since 28/01/2019
@version P12
@param cQuery   , character, Query de consulta que irá trazer os registros para a importação
@param cFldRecno, character, TABELA.CAMPO que contém a informação do RECNO do registro (Ex: SHC.R_E_C_N_O_).
@param cFldData , character, TABELA.CAMPO que contém a informação da data da demanda (Ex: SHC.HC_DATA).
@param cTipo    , character, Tipo de registro da SVR (VR_TIPO)
@param cDemanda , character, Código da demanda que será utilizada para importar os registros.
@param cFldProd , character, TABELA.CAMPO que contém a informação do código do produto (Ex: SHC.HC_PRODUTO).
@param cFldQuant, character, TABELA.CAMPO que contém a informação da quantidade (Ex: SHC.HC_QUANT).
@return lRet, logical, Identifica se existem registros que não serão importados.
/*/
Static Function VldImport(cQuery, cFldData, cFldRecno, cTipo, cDemanda, cFldProd, cFldQuant, cFldDemand)

	Local lRet      := .T.
	Local nDemUtil  := SuperGetMv("MV_DEMUTIL",.F.,1)
	Local cAliasQry := "VLDINFO"
	Local cQryOrig  := StrTran(cQuery, "'FIELDS' FLD", cFldProd + " PROD, " + cFldQuant + " QUANT, " + cFldData + " DATA, "+cFldDemand+" COD ")
	Local cTexto    := ""

	//Verifica se a data da demanda está dentro do calendário do MRP.
	If nDemUtil == 2
		cQuery := cQryOrig
		cQuery += " AND NOT EXISTS (SELECT 1 "
		cQuery +=                   " FROM " + RetSqlName("SVZ") + " SVZ "
		cQuery +=                  " WHERE SVZ.VZ_FILIAL  = '" + xFilial("SVZ") + "' "
		cQuery +=                    " AND SVZ.D_E_L_E_T_ = ' ' "
		cQuery +=                    " AND SVZ.VZ_DATA    = " + cFldData
		cQuery +=                    " AND SVZ.VZ_HORAFIM <> '00.00' ) "

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		While (cAliasQry)->(!Eof())
			If !_l136AtuAuto
				GravaLog(cTipo, (cAliasQry)->PROD, (cAliasQry)->QUANT, SToD((cAliasQry)->DATA), STR0075) //"A data da demanda não está dentro do calendário do MRP."
			Else
				cTexto := STR0075 + "(" + RTrim((cAliasQry)->PROD) + "|" + cTipo + "|" + cValToChar(SToD((cAliasQry)->DATA)) + "|" + cValToChar((cAliasQry)->QUANT) + ")"
				aAdd(_aMensagem, {cTexto})
			End If
			lRet := .F.
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

	//Verifica se existem registros desta importação, que já estão importados em outra demanda.
	If lRet
		cQuery := cQryOrig
		cQuery += " AND EXISTS( SELECT 1 "
		cQuery +=               " FROM " + RetSqlName("SVR") + " SVRAUX "
		cQuery +=              " WHERE SVRAUX.VR_FILIAL  = '" + xFilial("SVR") + "' "
		cQuery +=                " AND SVRAUX.D_E_L_E_T_ = ' ' "
		cQuery +=                " AND SVRAUX.VR_TIPO    = '" + cTipo + "' "
		cQuery +=                " AND SVRAUX.VR_REGORI  = " + cFldRecno
		cQuery +=                " AND SVRAUX.VR_CODIGO  <> '" + cDemanda + "' )"

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		While (cAliasQry)->(!Eof())
			If !_l136AtuAuto
				GravaLog(cTipo, (cAliasQry)->PROD, (cAliasQry)->QUANT, SToD((cAliasQry)->DATA), STR0076+(cAliasQry)->COD) //"Esse registro já está importado na demanda: "
			Else
				cTexto := STR0076 + "(" + RTrim((cAliasQry)->PROD) + "|" + cTipo + "|" + cValToChar(SToD((cAliasQry)->DATA)) + "|" + cValToChar((cAliasQry)->QUANT) + ")"
				aAdd(_aMensagem, {cTexto})
			End If
			lRet := .F.
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} ImportaPMP
Faz a importação dos planos mestres de produção para a tabela de Demandas do MRP (SVR)

@type  Static Function
@author lucas.franca
@since 24/01/2019
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@param nMinSeq , numeric  , Sequêncial mínimo da SVR
@oaram lImpAmz , logico   , Indica que deve importar o armazém para a demanda.
@return nTotal , numeric  , Quantidade total de registros atualizados
@version P12
/*/
Static Function ImportaPMP(cDemanda,nMinSeq,lImpAmz)
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cConcatIdG := IIf("MSSQL" $ cBanco, " '3' + SHC.HC_IDGRADE", " CONCAT('3',SHC.HC_IDGRADE)") //O comando CONCAT não roda em todas as versões do SQLSERVER
	Local cQueryFlds := ""
	Local cQryBaseIn := ""
	Local cQryBaseUp := getQryPMP("UPDATE", .F.)
	Local cSqlStmt   := ""
	Local cSVRName   := AllTrim(RetSqlName("SVR"))
	Local cUpdate	 := ""
	Local cWhereBase := ""
	Local nDemUtil   := SuperGetMv("MV_DEMUTIL", .F., 1)
	Local nTotal     := 0

	If cBanco == "ORACLE"
		cQryBaseIn := getQryPMP("INSERT", .F.)
	Else
		cQryBaseIn := cQryBaseUp
	EndIf

	//Monta os campos que serão importados pela query.
	cQueryFlds := " SELECT '" + xFilial("SVR") + "',"                           //Filial da SVR
	cQueryFlds +=          getSqlSeq("SHC.R_E_C_N_O_", cDemanda, nMinSeq) + "," //Sequencial da SVR
	cQueryFlds +=        " '" + cDemanda + "',"                                 //Código da demanda
	cQueryFlds +=        " SHC.HC_DATA,"                                        //Data da demanda
	cQueryFlds +=        " '3',"                                                //Tipo da demanda
	cQueryFlds +=        " SHC.HC_PRODUTO,"                                     //Produto da demanda
	cQueryFlds +=        " SHC.HC_QUANT,"                                       //Quantidade da demanda
	If lImpAmz
		cQueryFlds +=    " CASE"
		cQueryFlds +=       " WHEN SHC.HC_LOCAL <> ' ' THEN SHC.HC_LOCAL"
		If _lUsaBZ
			cQueryFlds +=   " WHEN SBZ.BZ_LOCPAD <> ' ' THEN SBZ.BZ_LOCPAD"
		EndIf
		cQueryFlds +=       " ELSE SB1.B1_LOCPAD"
		cQueryFlds +=    " END LOCPAD,"                                         //Armazém da demanda
	Else
		cQueryFlds +=    " ' ' LOCPAD,"
	EndIf
	cQueryFlds +=        " SHC.HC_DOC,"                                         //Documento da demanda
	cQueryFlds +=        " SHC.HC_OPC,"                                         //Opcional da demanda
	cQueryFlds +=        " SHC.HC_MOPC,"                                        //Opcional MEMO da demanda
	cQueryFlds +=        " SHC.HC_GRADE,"
	cQueryFlds +=        " SHC.HC_ITEMGRD,"
	cQueryFlds +=        " CASE"
	cQueryFlds +=           " WHEN SHC.HC_IDGRADE <> ' ' THEN " + cConcatIdG    //CONCAT('3',SHC.HC_IDGRADE)
	cQueryFlds +=           " ELSE ' '"
	cQueryFlds +=        " END,"
	cQueryFlds +=        " 'SHC' ORIGEM,"                                       //Origem do registro
	cQueryFlds +=        " ' ',"                                                //Número do MRP
	cQueryFlds +=        " SHC.R_E_C_N_O_,"                                     //Registro origem da demanda
	cQueryFlds +=        " '3',"                                                //Indicador de demanda integrada com o MRP                                    //Indicador de demanda integrada com o MRP
	If x3VRRev()
		cQueryFlds +=    " SHC.HC_REVISAO,"
	EndIf
	cQueryFlds +=        " ' ',"                                                //D_E_L_E_T_
	cQueryFlds +=        " 0"                                                   //R_E_C_D_E_L_

	//Adiciona os demais filtros na query, após a validação dos registros.
	If nDemUtil == 2
		cWhereBase += " AND EXISTS (SELECT 1"
		cWhereBase +=               " FROM " + RetSqlName("SVZ") + " SVZ"
		cWhereBase +=              " WHERE SVZ.VZ_FILIAL  = '" + xFilial("SVZ") + "'"
		cWhereBase +=                " AND SVZ.D_E_L_E_T_ = ' '"
		cWhereBase +=                " AND SVZ.VZ_DATA    = SHC.HC_DATA"
		cWhereBase +=                " AND SVZ.VZ_HORAFIM <> '00.00')"
	EndIf

	cWhereBase += " AND NOT EXISTS( SELECT 1"
	cWhereBase +=                   " FROM " + RetSqlName("SVR") + " SVRAUX"
	cWhereBase +=                  " WHERE SVRAUX.VR_FILIAL  = '" + xFilial("SVR") + "'"
	cWhereBase +=                    " AND SVRAUX.D_E_L_E_T_ = ' '"
	cWhereBase +=                    " AND SVRAUX.VR_TIPO    = '3'"
	cWhereBase +=                    " AND SVRAUX.VR_REGORI  = SHC.R_E_C_N_O_"
	cWhereBase +=                    " AND SVRAUX.VR_DATA    = SHC.HC_DATA "
	cWhereBase +=                    " AND SVRAUX.VR_CODIGO  <> '" + cDemanda + "')"

	cQryBaseUp += cWhereBase
	cQryBaseIn += cWhereBase

	//Identifica quantos registros serão atualizados.
	nTotal := CountRegs(cQryBaseUp)
	If nTotal > 0
		If !MsgImporta()
			Return -1
		EndIf
	EndIf

	If cBanco == "ORACLE"
		//Atualiza os registros que já estão na SVR.
		cUpdate := "UPDATE (SELECT " + cSVRName + ".VR_DATA  AS DATAOLD,  SHC.HC_DATA    AS DATANEW,"
		cUpdate +=                     cSVRName + ".VR_PROD  AS PRODOLD,  SHC.HC_PRODUTO AS PRODNEW,"
		cUpdate +=                     cSVRName + ".VR_QUANT AS QUANTOLD, SHC.HC_QUANT   AS QUANTNEW,"

		If lImpAmz
			cUpdate +=                 cSVRName + ".VR_LOCAL AS LOCALOLD, CASE"
			cUpdate +=                                                     " WHEN SHC.HC_LOCAL <> ' ' THEN SHC.HC_LOCAL"
			cUpdate +=                                                     " ELSE ("
			If _lUsaBZ
				cUpdate +=                                                    " SELECT CASE"
				cUpdate +=                                                              " WHEN SBZ.BZ_LOCPAD <> ' ' THEN SBZ.BZ_LOCPAD"
				cUpdate +=                                                              " ELSE SB1.B1_LOCPAD"
				cUpdate +=                                                           " END"
				cUpdate +=                                                      " FROM " + RetSqlName("SB1") + " SB1"
				cUpdate +=                                                      " LEFT JOIN " + RetSqlName("SBZ") + " SBZ"
				cUpdate +=                                                        " ON SBZ.BZ_FILIAL  = '" + xFilial("SBZ") + "'"
				cUpdate +=                                                       " AND SBZ.BZ_COD     = SB1.B1_COD"
				cUpdate +=                                                       " AND SBZ.D_E_L_E_T_ = ' '"
			Else
				cUpdate +=                                                    " SELECT SB1.B1_LOCPAD"
				cUpdate +=                                                      " FROM " + RetSqlName("SB1") + " SB1"
			EndIf
			cUpdate +=                                                         " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
			cUpdate +=                                                           " AND SB1.B1_COD     = SHC.HC_PRODUTO"
			cUpdate +=                                                           " AND SB1.D_E_L_E_T_ = ' ')"
			cUpdate +=                                                  " END AS LOCALNEW,"
		Else
			cUpdate +=                 cSVRName + ".VR_LOCAL AS LOCALOLD, ' ' AS LOCALNEW,"
		EndIf

		cUpdate +=                     cSVRName + ".VR_DOC     AS DOCOLD,     SHC.HC_DOC  AS DOCNEW,"
		cUpdate +=                     cSVRName + ".VR_OPC     AS OPCOLD,     SHC.HC_OPC  AS OPCNEW,"
		cUpdate +=                     cSVRName + ".VR_MOPC    AS MOPCOLD,    SHC.HC_MOPC AS MOPCNEW,"
		cUpdate +=                     cSVRName + ".VR_GRADE   AS GRADEOLD,   SHC.HC_GRADE AS GRADENEW,"
		cUpdate +=                     cSVRName + ".VR_ITEMGRD AS ITEMGRDOLD, SHC.HC_ITEMGRD AS ITEMGRDNEW,"
		cUpdate +=                     cSVRName + ".VR_IDGRADE AS IDGRADEOLD, CASE WHEN SHC.HC_IDGRADE <> ' ' THEN " + cConcatIdG + " ELSE ' ' END AS IDGRADENEW,"
		cUpdate +=                     cSVRName + ".VR_NRMRP   AS NRMRPOLD,"
		cUpdate +=                     cSVRName + ".VR_INTMRP  AS INTMRPOLD"

		If x3VRRev()
			cUpdate +=          ", " + cSVRName + ".VR_REV     AS REVOLD,     SHC.HC_REVISAO AS REVNEW"
		EndIf

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD",cUpdate)
	Else
		//Atualiza os registros que já estão na SVR.
		cSqlStmt := " UPDATE " + cSVRName
		cSqlStmt +=    " SET VR_DATA    = SHC.HC_DATA,"
		cSqlStmt +=        " VR_PROD    = SHC.HC_PRODUTO,"
		cSqlStmt +=        " VR_QUANT   = SHC.HC_QUANT,"

		If lImpAmz
			cSqlStmt +=    " VR_LOCAL   = CASE"
			cSqlStmt +=                    " WHEN SHC.HC_LOCAL  <> ' ' THEN SHC.HC_LOCAL"
			If _lUsaBZ
				cSqlStmt +=                " WHEN SBZ.BZ_LOCPAD <> ' ' THEN SBZ.BZ_LOCPAD"
			EndIf
			cSqlStmt +=                    " ELSE SB1.B1_LOCPAD"
			cSqlStmt +=                 " END,"
		Else
			cSqlStmt +=    " VR_LOCAL   = ' ',"
		EndIf

		cSqlStmt +=        " VR_DOC     = SHC.HC_DOC,"
		cSqlStmt +=        " VR_OPC     = SHC.HC_OPC,"
		cSqlStmt +=        " VR_MOPC    = SHC.HC_MOPC,"
		cSqlStmt +=        " VR_GRADE   = SHC.HC_GRADE,"
		cSqlStmt +=        " VR_ITEMGRD = SHC.HC_ITEMGRD,"
		cSqlStmt +=        " VR_IDGRADE = CASE"
		cSqlStmt +=                        " WHEN SHC.HC_IDGRADE <> ' ' THEN " + cConcatIdG
		cSqlStmt +=                        " ELSE ' '"
		cSqlStmt +=                     " END,"
		cSqlStmt +=        " VR_NRMRP   = ' ',"
		cSqlStmt +=        " VR_INTMRP  = '3'"

		If x3VRRev()
			cSqlStmt +=   ", VR_REV     = SHC.HC_REVISAO"
		EndIf

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD"," ")
	EndIf

	//Adiciona o relacionamento da SVR com a SHC
	cSqlStmt += " AND " + cSVRName + ".VR_FILIAL  = '" + xFilial("SVR") + "'"
	cSqlStmt += " AND " + cSVRName + ".D_E_L_E_T_ = ' '"
	cSqlStmt += " AND " + cSVRName + ".VR_CODIGO  = '" + cDemanda + "'"
	cSqlStmt += " AND " + cSVRName + ".VR_TIPO    = '3'"

	If cBanco == "ORACLE"
		cSqlStmt += " ) T"
		cSqlStmt += " SET T.DATAOLD    = T.DATANEW,"
		cSqlStmt +=     " T.PRODOLD    = T.PRODNEW,"
		cSqlStmt +=     " T.QUANTOLD   = T.QUANTNEW,"
		cSqlStmt +=     " T.LOCALOLD   = T.LOCALNEW,"
		cSqlStmt +=     " T.DOCOLD     = T.DOCNEW,"
		cSqlStmt +=     " T.OPCOLD     = T.OPCNEW,"
		cSqlStmt +=     " T.MOPCOLD    = T.MOPCNEW,"
		cSqlStmt +=     " T.GRADEOLD   = T.GRADENEW,"
		cSqlStmt +=     " T.ITEMGRDOLD = T.ITEMGRDNEW,"
		cSqlStmt +=     " T.IDGRADEOLD = T.IDGRADEOLD,"
		cSqlStmt +=     " T.NRMRPOLD   = ' ',"
		cSqlStmt +=     " T.INTMRPOLD  = '3'"
		If x3VRRev()
			cSqlStmt += ", T.REVOLD  = T.REVNEW"
		EndIf
	Else
		cSqlStmt += " AND " + cSVRName + ".VR_REGORI = SHC.R_E_C_N_O_"
	EndIf

	//Executa o UPDATE
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0060,TCSqlError() + cSqlStmt) //"Erro na importação do Plano Mestre de Produção."
	EndIf

	//Verifica quantos registros serão incluidos
	If nTotal == 0
		nTotal := CountRegs(cQryBaseIn)
	EndIf

	//Adiciona os registros que ainda não existem na SVR
	//Monta o comando de Insert.
	cSqlStmt := " INSERT INTO " + RetSqlName("SVR")
	cSqlStmt +=               " (VR_FILIAL,"
	cSqlStmt +=                " VR_SEQUEN,"
	cSqlStmt +=                " VR_CODIGO,"
	cSqlStmt +=                " VR_DATA,"
	cSqlStmt +=                " VR_TIPO,"
	cSqlStmt +=                " VR_PROD,"
	cSqlStmt +=                " VR_QUANT,"
	cSqlStmt +=                " VR_LOCAL,"
	cSqlStmt +=                " VR_DOC,"
	cSqlStmt +=                " VR_OPC,"
	cSqlStmt +=                " VR_MOPC,"
	cSqlStmt +=                " VR_GRADE,"
	cSqlStmt +=                " VR_ITEMGRD,"
	cSqlStmt +=                " VR_IDGRADE,"
	cSqlStmt +=                " VR_ORIGEM,"
	cSqlStmt +=                " VR_NRMRP,"
	cSqlStmt +=                " VR_REGORI,"
	cSqlStmt +=                " VR_INTMRP,"
	if x3VRRev()
		cSqlStmt +=            " VR_REV,"
	EndIf
	cSqlStmt +=                " D_E_L_E_T_,"
	cSqlStmt +=                " R_E_C_D_E_L_)"

	//Adiciona os campos no SELECT.
	cSqlStmt += StrTran(cQryBaseIn, "SELECT 'FIELDS' FLD", cQueryFlds)

	//Adiciona as condições na query para a Inserção.
	cSqlStmt += " AND NOT EXISTS (SELECT 1"
	cSqlStmt +=                   " FROM " + RetSqlName("SVR") + " SVRINS"
	cSqlStmt +=                  " WHERE SVRINS.VR_FILIAL  = '" + xFilial("SVR") + "'"
	cSqlStmt +=                    " AND SVRINS.D_E_L_E_T_ = ' '"
	cSqlStmt +=                    " AND SVRINS.VR_CODIGO  = '" + cDemanda + "'"
	cSqlStmt +=                    " AND SVRINS.VR_TIPO    = '3'"
	cSqlStmt +=                    " AND SVRINS.VR_REGORI  = SHC.R_E_C_N_O_ )"

	//Executa o INSERT.
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0060, TCSqlError() + cSqlStmt) //"Erro na importação do Plano Mestre de Produção."
	EndIf

Return nTotal

/*/{Protheus.doc} CountRegs
Conta a quantidade de registros que serão atualizados de acordo com a query da busca dos dados.
@type  Static Function
@author lucas.franca
@since 29/01/2019
@version P12
@param cQuery , character, Query que será utilizada na busca dos dados
@return nTotal, numeric  , Quantidade de registros que serão atualizados
/*/
Static Function CountRegs(cQuery)
	Local nTotal    := 0
	Local cQryCount := ""
	Local cAliasCnt := "COUNTTBL"

	cQryCount := " SELECT COUNT(*) TOTAL "
	cQryCount +=   " FROM (" + cQuery + ") tmpcount "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryCount),cAliasCnt,.T.,.T.)
	nTotal := (cAliasCnt)->(TOTAL)
	(cAliasCnt)->(dbCloseArea())
Return nTotal

/*/{Protheus.doc} VldImpPRV
Função para validar se todos os registros poderão ser importados.
@type  Static Function
@author Carlos Alexandre da Silveira
@since 07/02/2019
@version P12
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@return lRet   , logical  , Identifica se todos os registros podem ser importados.
/*/
Static Function VldImpPRV(cDemanda)
	Local lRet       := .T.
	Local cQueryBase := getQryPRV("INSERT", .T.) //Estrutura da query

	//Valida se todos os dados retornados pela query são válidos.
	lRet := VldImport(cQueryBase,"SC4.C4_DATA","SC4.R_E_C_N_O_","2",cDemanda,"SC4.C4_PRODUTO","SC4.C4_QUANT", "SVR.VR_CODIGO")

Return lRet

/*/{Protheus.doc} getQryPRV
Retorna a query com os filtros para importação das Previsões de Venda.
@type  Static Function
@author Carlos Alexandre da Silveira
@since 07/02/2019
@version P12
@param cOperacao, character, tipo de operação realizada
@param lValid, lógico, define se a query é montada para validação
@return cQuery , Character, Query com os filtros para importação do PMP
/*/
Static Function getQryPRV(cOperacao, lValid)
	Local cBanco := AllTrim(Upper(TcGetDb()))
	Local cQuery := ""
	Local cRetPe := ""
	Default lValid := .F.

	cQuery := " SELECT 'FIELDS' FLD "
	If cBanco == "ORACLE" .And. cOperacao == "UPDATE"
		cQuery +=    " FROM " + RetSqlName("SVR") + " INNER JOIN " + RetSqlName("SC4") + " SC4 "
		cQuery +=      " ON SC4.C4_FILIAL  = '" + xFilial("SC4") + "' "
		cQuery +=     " AND SC4.D_E_L_E_T_ = ' ' "
		cQuery +=     " AND SC4.C4_DATA    BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
		cQuery +=     " AND SC4.C4_PRODUTO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery +=     " AND SC4.C4_DOC     BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "

		If _lParLocal
			cQuery += " AND SC4.C4_LOCAL   BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "' "
		EndIf

		cQuery +=     " AND " + RetSqlName("SVR") + ".VR_REGORI  = SC4.R_E_C_N_O_ "
		cQuery +=     " AND " + RetSqlName("SVR") + ".D_E_L_E_T_ = ' ' "
		cQuery +=     " AND " + RetSqlName("SVR") + ".VR_FILIAL  = '" + xFilial("SVR") + "' "
		cQuery +=   " WHERE EXISTS (SELECT 1 FROM "+ RetSqlName("SB1") + " SB1
		cQuery +=                  " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=                    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=                    " AND SB1.B1_COD     = SC4.C4_PRODUTO "
		cQuery +=                    " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		cQuery +=                    " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "') "
	Else
		cQuery +=   " FROM " + RetSqlName("SC4") + " SC4 "
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB1.B1_COD     = SC4.C4_PRODUTO "
		cQuery +=    " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		cQuery +=    " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
		If lValid
			cQuery += " INNER JOIN " + RetSqlName("SVR") + " SVR "
			cQuery +=    " ON SC4.C4_PRODUTO = SVR.VR_PROD AND SC4.C4_DATA = SVR.VR_DATA "
			cQuery +=   " AND SVR.VR_REGORI = SC4.R_E_C_N_O_ AND SVR.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery +=  " WHERE SC4.C4_FILIAL  = '" + xFilial("SC4") + "' "
		cQuery +=    " AND SC4.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SC4.C4_DATA    BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
		cQuery +=    " AND SC4.C4_PRODUTO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery +=    " AND SC4.C4_DOC     BETWEEN '" + MV_PAR13 + "' AND '" + MV_PAR14 + "' "

		If _lParLocal
			cQuery += " AND SC4.C4_LOCAL   BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "' "
		EndIf
	EndIf

	// Ponto de entrada para o usuário adicionar seus filtros na importação
	If ExistBlock("P136FIL")
		cRetPe := ExecBlock("P136FIL", .F., .F., "SC4")
		If !Empty(cRetPe)
			cQuery += " AND " + cRetPe
		EndIf
	EndIf

Return cQuery

/*/{Protheus.doc} ImportaPRV
Faz a importação das previsões de venda para a tabela de Demandas do MRP (SVR)
@type  Static Function
@author Carlos Alexandre da Silveira
@since 07/02/2019
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@param nMinSeq , numeric  , Sequêncial mínimo da SVR
@param lImpAmz , logico   , Indica que deve importar o armazem para a demanda.
@return nTotal , numeric  , Quantidade total de registros atualizados
@version P12
/*/
Static Function ImportaPRV(cDemanda,nMinSeq,lImpAmz)
	Local cQueryFlds := ""
	Local cQryBaseUp := getQryPRV("UPDATE", .F.)	//Estrutura da query.
	Local cQryBaseIn := ""					//Estrutura da query.
    Local cSVRName   := AllTrim(RetSqlName("SVR"))
	Local cSqlStmt   := ""
	Local nDemUtil   := SuperGetMv("MV_DEMUTIL",.F.,1)
	Local nTotal     := 0
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cUpdate	 := ''
	Local cWhereBase := ""

	If cBanco == "ORACLE"
		cQryBaseIn := getQryPRV("INSERT", .F.)
	Else
		cQryBaseIn := cQryBaseUp
	EndIf

	//Monta os campos que serão importados pela query.
	cQueryFlds := " SELECT '"+xFilial("SVR")+"', "                        //Filial da SVR
	cQueryFlds +=          getSqlSeq("SC4.R_E_C_N_O_",cDemanda,nMinSeq) + " SEQ, " //Sequêncial da SVR
	cQueryFlds +=        " '"+cDemanda+"', "                              //Código da demanda
	cQueryFlds +=        " SC4.C4_DATA, "                                 //Data da demanda
	cQueryFlds +=        " '2', "                                         //Tipo da demanda
	cQueryFlds +=        " SC4.C4_PRODUTO, "                              //Produto da demanda
	cQueryFlds +=        " SC4.C4_QUANT, "                                //Quantidade da demanda

	If lImpAmz
		cQueryFlds +=    " CASE WHEN SC4.C4_LOCAL <> ' ' "
		cQueryFlds +=         " THEN SC4.C4_LOCAL "
		cQueryFlds +=         " ELSE SB1.B1_LOCPAD "
		cQueryFlds +=    " END C4LOCAL, "                                 //Armazém da demanda
	Else
		cQueryFlds +=    " ' ' C4LOCAL, "
	EndIf

	cQueryFlds +=        " SC4.C4_DOC, "                                  //Documento da demanda
	cQueryFlds +=        " SC4.C4_OPC, "                                  //Opcional da demanda
	cQueryFlds +=        " SC4.C4_MOPC, "                                 //Opcional MEMO da demanda
 	cQueryFlds +=        " SC4.C4_GRADE, "
	cQueryFlds +=        " SC4.C4_ITEMGRD, "
	cQueryFlds +=        " CASE WHEN SC4.C4_IDGRADE <> ' ' "

	//Trata o banco SQLSERVER, pois o comando CONCAT não roda em todas as versões do SQL
	If cBanco == "MSSQL"
		cQueryFlds +=     " THEN '2' + SC4.C4_IDGRADE "
	Else
		cQueryFlds +=     " THEN CONCAT('2',SC4.C4_IDGRADE) "
	EndIf

	cQueryFlds +=         " ELSE ' ' END, "
	cQueryFlds +=         " 'SC4' ORIGEM, "                                //Origem do registro
	cQueryFlds +=         " ' ', "                                         //Número do MRP
	cQueryFlds +=         " SC4.R_E_C_N_O_ RECNO, "                        //Registro origem da demanda
	cQueryFlds +=         " '3', "                                         //Indicador de demanda integrada com o MRP
	If x3VRRev()
		cQueryFlds +=     " SC4.C4_REVISAO, "
	EndIf
	cQueryFlds +=         " ' ', "                                         //D_E_L_E_T_
	cQueryFlds +=         " 0 "                                            //R_E_C_D_E_L_

	//Adiciona os demais filtros na query, após a validação dos registros.
	If nDemUtil == 2
		cWhereBase += " AND EXISTS (SELECT 1 "
		cWhereBase +=               " FROM " + RetSqlName("SVZ") + " SVZ "
		cWhereBase +=              " WHERE SVZ.VZ_FILIAL  = '" + xFilial("SVZ") + "' "
		cWhereBase +=                " AND SVZ.D_E_L_E_T_ = ' ' "
		cWhereBase +=                " AND SVZ.VZ_DATA    = SC4.C4_DATA "
		cWhereBase +=                " AND SVZ.VZ_HORAFIM <> '00.00' ) "
	EndIf

	cWhereBase += " AND NOT EXISTS( SELECT 1 "
	cWhereBase +=                   " FROM " + RetSqlName("SVR") + " SVRAUX "
	cWhereBase +=                  " WHERE SVRAUX.VR_FILIAL  = '" + xFilial("SVR") + "' "
	cWhereBase +=                    " AND SVRAUX.D_E_L_E_T_ = ' ' "
	cWhereBase +=                    " AND SVRAUX.VR_TIPO    = '2' "
	cWhereBase += 					 " AND SVRAUX.VR_PROD = SC4.C4_PRODUTO "
	cWhereBase +=                    " AND SVRAUX.VR_REGORI  = SC4.R_E_C_N_O_ "
	cWhereBase +=                    " AND SVRAUX.VR_DATA    = SC4.C4_DATA "
	cWhereBase +=                    " AND SVRAUX.VR_CODIGO  <> '" + cDemanda + "' )"

	cQryBaseUp += cWhereBase
	cQryBaseIn += cWhereBase

	//Identifica quantos registros serão atualizados.
	nTotal := CountRegs(cQryBaseUp)
	If nTotal > 0
		If !MsgImporta()
			Return -1
		EndIf
	EndIf

	If MV_PAR16 != MVPAR16_NAO
		//Se irá descontar Pedidos de venda das Previsões de venda, armazena as previsões que devem ser verificadas.
		GuardaPrev(cQryBaseUp)
	EndIf

	IF cBanco == "ORACLE"
		//Atualiza os registros que já estão na SVR.
		cUpdate := "UPDATE (SELECT " +cSVRName + ".VR_DATA  AS DATAOLD,  SC4.C4_DATA    AS DATANEW,"
		cUpdate +=                    cSVRName + ".VR_PROD  AS PRODOLD,  SC4.C4_PRODUTO AS PRODNEW,"
		cUpdate +=                    cSVRName + ".VR_QUANT AS QUANTOLD, SC4.C4_QUANT   AS QUANTNEW,"

		If lImpAmz
			cUpdate +=                cSVRName + ".VR_LOCAL AS LOCALOLD, CASE WHEN SC4.C4_LOCAL <> ' '"
			cUpdate +=                                                 " THEN SC4.C4_LOCAL"
			cUpdate +=                                                 " ELSE (SELECT SB1.B1_LOCPAD"
			cUpdate +=                                                 " FROM " + RetSqlName("SB1") + " SB1"
			cUpdate +=                                                " WHERE SB1.B1_FILIAL  = '  '"
			cUpdate +=                                                  " AND SB1.D_E_L_E_T_ = ' '"
			cUpdate +=                                                  " AND SB1.B1_COD     = SC4.C4_PRODUTO)"
			cUpdate +=                                                  " END AS LOCALNEW,"
		Else
			cUpdate +=                cSVRName + ".VR_LOCAL AS LOCALOLD, ' ' AS LOCALNEW, "
		EndIf

		cUpdate +=                    cSVRName + ".VR_DOC     AS DOCOLD,     SC4.C4_DOC     AS DOCNEW,"
		cUpdate +=                    cSVRName + ".VR_OPC     AS OPCOLD,     SC4.C4_OPC     AS OPCNEW,"
		cUpdate +=                    cSVRName + ".VR_MOPC    AS MOPCOLD,    SC4.C4_MOPC    AS MOPCNEW,"
		cUpdate +=                    cSVRName + ".VR_GRADE   AS GRADEOLD  , SC4.C4_GRADE   AS GRADENEW  ,"
		cUpdate +=                    cSVRName + ".VR_ITEMGRD AS ITEMGRDOLD, SC4.C4_ITEMGRD AS ITEMGRDNEW,"
		cUpdate +=                    cSVRName + ".VR_IDGRADE AS IDGRADEOLD, CASE WHEN SC4.C4_IDGRADE <> ' ' THEN CONCAT('2',SC4.C4_IDGRADE) ELSE ' ' END AS IDGRADENEW,"
		cUpdate +=                    cSVRName + ".VR_NRMRP   AS NRMRPOLD,"
		cUpdate +=                    cSVRName + ".VR_INTMRP  AS INTMRPOLD"

		If x3VRRev()
			cUpdate +=         ", " + cSVRName + ".VR_REV     AS REVOLD,     SC4.C4_REVISAO AS REVNEW"
		EndIf

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD",cUpdate)
	Else
		//Atualiza os registros que já estão na SVR.
		cSqlStmt := " UPDATE " + cSVRName
		cSqlStmt +=    " SET VR_DATA    = SC4.C4_DATA, "
		cSqlStmt +=        " VR_PROD    = SC4.C4_PRODUTO, "
		cSqlStmt +=        " VR_QUANT   = SC4.C4_QUANT, "

		If lImpAmz
			cSqlStmt +=    " VR_LOCAL   = CASE WHEN SC4.C4_LOCAL <> ' ' "
			cSqlStmt +=                      " THEN SC4.C4_LOCAL "
			cSqlStmt +=                      " ELSE SB1.B1_LOCPAD "
			cSqlStmt +=                 " END, "
		Else
			cSqlStmt +=    " VR_LOCAL = ' ', "
		EndIf

		cSqlStmt +=        " VR_DOC     = SC4.C4_DOC,"
		cSqlStmt +=        " VR_OPC     = SC4.C4_OPC,"
		cSqlStmt +=        " VR_MOPC    = SC4.C4_MOPC,"
 		cSqlStmt +=        " VR_GRADE   = SC4.C4_GRADE,"
		cSqlStmt +=        " VR_ITEMGRD = SC4.C4_ITEMGRD,"
		cSqlStmt +=        " VR_IDGRADE = CASE WHEN SC4.C4_IDGRADE <> ' '"

		//Trata o banco SQLSERVER, pois o comando CONCAT não roda em todas as versões do SQL
		If cBanco == 'MSSQL'
			cSqlStmt += " THEN '2' + SC4.C4_IDGRADE "
		Else
			cSqlStmt += " THEN CONCAT('2',SC4.C4_IDGRADE) "
		EndIf

		cSqlStmt +=        " ELSE ' ' END, "
		cSqlStmt +=        " VR_NRMRP   = ' ', "
		cSqlStmt +=        " VR_INTMRP  = '3' "

		If x3VRRev()
			cSqlStmt +=   ", VR_REV     = SC4.C4_REVISAO "
		EndIf

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD"," ")
	EndIf

	//Adiciona o relacionamento da SVR com a SC4
	cSqlStmt += " AND " + cSVRName + ".VR_FILIAL  = '" + xFilial("SVR") + "' "
	cSqlStmt += " AND " + cSVRName + ".D_E_L_E_T_ = ' ' "
	cSqlStmt += " AND " + cSVRName + ".VR_CODIGO  = '" + cDemanda + "' "
	cSqlStmt += " AND " + cSVRName + ".VR_TIPO    = '2' "

	If cBanco == "ORACLE"
		cSqlStmt += " ) T"
		cSqlStmt += " SET T.DATAOLD    = T.DATANEW,"
		cSqlStmt +=     " T.PRODOLD    = T.PRODNEW,"
		cSqlStmt +=     " T.QUANTOLD   = T.QUANTNEW,"
		cSqlStmt +=     " T.LOCALOLD   = T.LOCALNEW,"
		cSqlStmt +=     " T.DOCOLD     = T.DOCNEW,"
		cSqlStmt +=     " T.OPCOLD     = T.OPCNEW,"
		cSqlStmt +=     " T.MOPCOLD    = T.MOPCNEW,"
		cSqlStmt +=     " T.GRADEOLD   = T.GRADENEW,"
		cSqlStmt +=     " T.ITEMGRDOLD = T.ITEMGRDNEW,"
		cSqlStmt +=     " T.IDGRADEOLD = T.IDGRADENEW,"
		cSqlStmt +=     " T.NRMRPOLD   = ' ',"
		cSqlStmt +=     " T.INTMRPOLD  = '3'"
		If x3VRRev()
			cSqlStmt += ", T.REVOLD  = T.REVNEW "
		EndIf
	Else
		cSqlStmt += " AND " + cSVRName + ".VR_REGORI  = SC4.R_E_C_N_O_ "
	EndIf

	//Executa o UPDATE.
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0069,TCSqlError() + cSqlStmt) //"Erro na importação das previsões de venda. "
	EndIf

	//Verifica quantos registros serão incluidos
	If nTotal == 0
		nTotal := CountRegs(cQryBaseIn)
	EndIf

	//Adiciona os registros que ainda não existem na SVR
	//Monta o comando de Insert.
	cSqlStmt := " INSERT INTO " + RetSqlName("SVR")
	cSqlStmt +=               " (VR_FILIAL,"
	cSqlStmt +=                " VR_SEQUEN,"
	cSqlStmt +=                " VR_CODIGO,"
	cSqlStmt +=                " VR_DATA,"
	cSqlStmt +=                " VR_TIPO,"
	cSqlStmt +=                " VR_PROD,"
	cSqlStmt +=                " VR_QUANT,"
	cSqlStmt +=                " VR_LOCAL,"
	cSqlStmt +=                " VR_DOC,"
	cSqlStmt +=                " VR_OPC,"
	cSqlStmt +=                " VR_MOPC,"
	cSqlStmt +=                " VR_GRADE,"
	cSqlStmt +=                " VR_ITEMGRD,"
	cSqlStmt +=                " VR_IDGRADE,"
	cSqlStmt +=                " VR_ORIGEM,"
	cSqlStmt +=                " VR_NRMRP,"
	cSqlStmt +=                " VR_REGORI,"
	cSqlStmt +=                " VR_INTMRP,"
	if x3VRRev()
		cSqlStmt +=            " VR_REV,"
	EndIf
	cSqlStmt +=                " D_E_L_E_T_,"
	cSqlStmt +=                " R_E_C_D_E_L_)"

	//Adiciona os campos no SELECT.
	cSqlStmt += StrTran(cQryBaseIn, "SELECT 'FIELDS' FLD", cQueryFlds)

	//Adiciona as condições na query para a Inserção.
	cSqlStmt += " AND NOT EXISTS (SELECT 1"
	cSqlStmt +=                   " FROM " + RetSqlName("SVR") + " SVRINS"
	cSqlStmt +=                  " WHERE SVRINS.VR_FILIAL  = '" + xFilial("SVR") + "'"
	cSqlStmt +=                    " AND SVRINS.D_E_L_E_T_ = ' '"
	cSqlStmt +=                    " AND SVRINS.VR_CODIGO  = '" + cDemanda + "'"
	cSqlStmt +=                    " AND SVRINS.VR_TIPO    = '2'"
	cSqlStmt +=                    " AND SVRINS.VR_REGORI  = SC4.R_E_C_N_O_ )"

	If MV_PAR16 != MVPAR16_NAO
		//Se irá descontar Pedidos de venda das Previsões de venda, armazena as previsões que devem ser verificadas.
		GuardaPrev(cQryBaseIn)
	EndIf

	//Executa o INSERT.
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0069, TCSqlError() + cSqlStmt) //"Erro na importação das previsões de venda. "
	EndIf

	If MV_PAR16 != MVPAR16_NAO
		//Processa os descontos de quantidade dos pedidos de venda das previsões de venda importadas.
		PrcQtdPrev(cDemanda)
	EndIf

Return nTotal

/*/{Protheus.doc} GuardaPrev
Armazena os dados da SC4 que serão importados para processar
posteriormente as quantidades descontadas dos pedidos de venda.

@type  Static Function
@author lucas.franca
@since 27/03/2019
@version P12.1.25
@param cQueryBase, Character, Query utilizada para buscar os dados da SC4
@return Nil
/*/
Static Function GuardaPrev(cQueryBase)
	Local cSqlStmt := ""
	Local cQryFlds := ""

	cSqlStmt := " INSERT INTO " + _oTmpPrevs:GetRealName() + " (RECPRV, D_E_L_E_T_, R_E_C_D_E_L_) "

	cQryFlds := " SELECT SC4.R_E_C_N_O_, ' ', 0 "

	cSqlStmt += StrTran(cQueryBase,"SELECT 'FIELDS' FLD",cQryFlds)

	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0069, TCSqlError() + cSqlStmt) //"Erro na importação das previsões de venda. "
	EndIf

Return Nil

/*/{Protheus.doc} VldImpEMP
Função para validar se todos os registros poderão ser importados.
@type  Static Function
@author Carlos Alexandre da Silveira
@since 07/02/2019
@version P12
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@return lRet   , logical  , Identifica se todos os registros podem ser importados.
/*/
Static Function VldImpEMP(cDemanda)
	Local lRet       := .T.
	Local cQueryBase := getQryEMP("INSERT", .T.) //Estrutura da query

	//Valida se todos os dados retornados pela query são válidos.
	lRet := VldImport(cQueryBase,"AFJ.AFJ_DATA","AFJ.R_E_C_N_O_","4",cDemanda,"AFJ.AFJ_COD","(AFJ.AFJ_QEMP - AFJ.AFJ_QATU)", "SVR.VR_CODIGO")

Return lRet

/*/{Protheus.doc} getQryEMP
Retorna a query com os filtros para importação das Previsões de Venda.
@type  Static Function
@author Carlos Alexandre da Silveira
@since 07/02/2019
@version P12
@param cOperacao, character, tipo de operação realizada
@param lValid, lógico, define se a query é montada para validação
@return cQuery , Character, Query com os filtros para importação do PMP
/*/
Static Function getQryEMP(cOperacao, lValid)
	Local cBanco := AllTrim(Upper(TcGetDb()))
	Local cQuery := ""
	Local cRetPe := ""
	Default lValid := .F.

	cQuery := " SELECT 'FIELDS' FLD "
	If cBanco == "ORACLE" .And. cOperacao == "UPDATE"
		cQuery +=    " FROM " + RetSqlName("SVR") + " INNER JOIN " + RetSqlName("AFJ") + " AFJ "
		cQuery +=      " ON AFJ.AFJ_FILIAL  = '" + xFilial("AFJ") + "' "
		cQuery +=     " AND AFJ.D_E_L_E_T_ = ' ' "
		cQuery +=     " AND AFJ.AFJ_DATA  BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
		cQuery +=     " AND AFJ.AFJ_COD   BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "

		If _lParLocal
			cQuery += " AND AFJ.AFJ_LOCAL BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "' "
		EndIf

		cQuery +=     " AND AFJ.AFJ_QATU  < AFJ.AFJ_QEMP "
		cQuery +=     " AND " + RetSqlName("SVR") + ".VR_REGORI  = AFJ.R_E_C_N_O_ "
		cQuery +=     " AND " + RetSqlName("SVR") + ".D_E_L_E_T_ = ' ' "
		cQuery +=     " AND " + RetSqlName("SVR") + ".VR_FILIAL  = '" + xFilial("SVR") + "' "
		cQuery +=   " WHERE EXISTS (SELECT 1 FROM "+ RetSqlName("SB1") + " SB1
		cQuery +=                  " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=                    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=                    " AND SB1.B1_COD     = AFJ.AFJ_COD "
		cQuery +=                    " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		cQuery +=                    " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "') "
	Else
		cQuery +=   " FROM " + RetSqlName("AFJ") + " AFJ "
		cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery +=     " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SB1.B1_COD     = AFJ.AFJ_COD "
		cQuery +=    " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		cQuery +=    " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
		If lValid
			cQuery += " INNER JOIN " + RetSqlName("SVR") + " SVR "
			cQuery +=    " ON AFJ.AFJ_COD = SVR.VR_PROD AND AFJ.AFJ_DATA = SVR.VR_DATA "
			cQuery +=   " AND SVR.VR_REGORI = AFJ.R_E_C_N_O_ AND SVR.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery +=  " WHERE AFJ.AFJ_FILIAL  = '" + xFilial("AFJ") + "' "
		cQuery +=    " AND AFJ.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND AFJ.AFJ_DATA  BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "' "
		cQuery +=    " AND AFJ.AFJ_COD   BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery +=    " AND AFJ.AFJ_QATU < AFJ.AFJ_QEMP "

		If _lParLocal
			cQuery += " AND AFJ.AFJ_LOCAL BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "' "
		EndIf
	EndIf

	// Ponto de entrada para o usuário adicionar seus filtros na importação
	If ExistBlock("P136FIL")
		cRetPe := ExecBlock("P136FIL", .F., .F., "AFJ")
		If !Empty(cRetPe)
			cQuery += " AND " + cRetPe
		EndIf
	EndIf

Return cQuery

/*/{Protheus.doc} ImportaEMP
Faz a importação das previsões de venda para a tabela de Demandas do MRP (SVR)
@type  Static Function
@author Carlos Alexandre da Silveira
@since 07/02/2019
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@param nMinSeq , numeric  , Sequêncial mínimo da SVR
@param lImpAmz , logico   , Indica que deve importar o armazem para a demanda.
@return nTotal , numeric  , Quantidade total de registros atualizados
@version P12
/*/
Static Function ImportaEMP(cDemanda,nMinSeq,lImpAmz)
	Local cQueryFlds := ""
	Local cQryBaseUp := getQryEMP("UPDATE", .F.)	//Estrutura da query.
	Local cQryBaseIn := ""					//Estrutura da query.
	Local cSVRName   := AllTrim(RetSqlName("SVR"))
	Local cSqlStmt   := ""
	Local nDemUtil   := SuperGetMv("MV_DEMUTIL",.F.,1)
	Local nTotal     := 0
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cUpdate	 := ''
	Local cWhereBase := ""

	If cBanco == "ORACLE"
		cQryBaseIn := getQryEMP("INSERT", .F.)
	Else
		cQryBaseIn := cQryBaseUp
	EndIf

	//Monta os campos que serão importados pela query.
	cQueryFlds := " SELECT '"+xFilial("SVR")+"', "                    //Filial da SVR
	cQueryFlds += getSqlSeq("AFJ.R_E_C_N_O_",cDemanda,nMinSeq) + ", " //Sequêncial da SVR
	cQueryFlds +=        " '"+cDemanda+"', "                          //Código da demanda
	cQueryFlds +=        " AFJ.AFJ_DATA, "                            //Data da demanda
	cQueryFlds +=        " '4', "                                     //Tipo da demanda
	cQueryFlds +=        " AFJ.AFJ_COD, "                             //Produto da demanda
	cQueryFlds +=        " AFJ.AFJ_QEMP - AFJ.AFJ_QATU, "             //Quantidade da demanda

	If lImpAmz
		cQueryFlds +=    " CASE WHEN AFJ.AFJ_LOCAL <> ' ' "
		cQueryFlds +=         " THEN AFJ.AFJ_LOCAL "
		cQueryFlds +=         " ELSE SB1.B1_LOCPAD "
		cQueryFlds +=    " END, "                                     //Armazém da demanda
	Else
		cQueryFlds +=    " ' ' LOCAL, "
	EndIf

	cQueryFlds +=        " AFJ.AFJ_PROJET, "                          //Documento da demanda
	cQueryFlds +=        " 'AFJ' ORIGEM, "                            //Origem do registro
	cQueryFlds +=        " ' ', "                                     //Número do MRP
	cQueryFlds +=        " AFJ.R_E_C_N_O_, "                          //Registro origem da demanda
	cQueryFlds +=        " '3', "                                     //Indicador de demanda integrada com o MRP
	cQueryFlds +=        " ' ', "                                     //D_E_L_E_T_
	cQueryFlds +=        " 0 "                                        //R_E_C_D_E_L_

	//Adiciona os demais filtros na query, após a validação dos registros.
	If nDemUtil == 2
		cWhereBase += " AND EXISTS (SELECT 1 "
		cWhereBase +=               " FROM " + RetSqlName("SVZ") + " SVZ "
		cWhereBase +=              " WHERE SVZ.VZ_FILIAL  = '" + xFilial("SVZ") + "' "
		cWhereBase +=                " AND SVZ.D_E_L_E_T_ = ' ' "
		cWhereBase +=                " AND SVZ.VZ_DATA    = AFJ.AFJ_DATA "
		cWhereBase +=                " AND SVZ.VZ_HORAFIM <> '00.00' ) "
	EndIf

	cWhereBase += " AND NOT EXISTS( SELECT 1 "
	cWhereBase +=                   " FROM " + RetSqlName("SVR") + " SVRAUX "
	cWhereBase +=                  " WHERE SVRAUX.VR_FILIAL  = '" + xFilial("SVR") + "' "
	cWhereBase +=                    " AND SVRAUX.D_E_L_E_T_ = ' ' "
	cWhereBase +=                    " AND SVRAUX.VR_TIPO    = '4' "
	cWhereBase +=                    " AND SVRAUX.VR_REGORI  = AFJ.R_E_C_N_O_ "
	cWhereBase +=                    " AND SVRAUX.VR_CODIGO  <> '" + cDemanda + "' )"

	cQryBaseUp += cWhereBase
	cQryBaseIn += cWhereBase

	//Identifica quantos registros serão atualizados.
	nTotal := CountRegs(cQryBaseUp)
	If nTotal > 0
		If !MsgImporta()
			Return -1
		EndIf
	EndIf

	If cBanco == "ORACLE"
		//Atualiza os registros que já estão na SVR.
		cUpdate := "UPDATE (SELECT " + cSVRName + ".VR_DATA  AS DATAOLD,  AFJ.AFJ_DATA AS DATANEW,"
		cUpdate +=                     cSVRName + ".VR_PROD  AS PRODOLD,  AFJ.AFJ_COD  AS PRODNEW,"
		cUpdate +=                     cSVRName + ".VR_QUANT AS QUANTOLD, AFJ.AFJ_QEMP - AFJ.AFJ_QATU AS QUANTNEW,"

		If lImpAmz
			cUpdate +=                 cSVRName + ".VR_LOCAL AS LOCALOLD, CASE WHEN AFJ.AFJ_LOCAL <> ' ' "
			cUpdate +=                                                  " THEN AFJ.AFJ_LOCAL "
			cUpdate +=                                                  " ELSE (SELECT SB1.B1_LOCPAD "
			cUpdate +=                                                  " FROM " + RetSqlName("SB1") + " SB1 "
			cUpdate +=                                                 " WHERE SB1.B1_FILIAL  = '  ' "
			cUpdate +=                                                   " AND SB1.D_E_L_E_T_ = ' ' "
			cUpdate +=                                                   " AND SB1.B1_COD     = AFJ.AFJ_COD ) "
			cUpdate +=                                                   " END AS LOCALNEW,"
		Else
			cUpdate +=                 cSVRName + ".VR_LOCAL AS LOCALOLD, ' ' AS LOCALNEW,"
		EndIf

		cUpdate +=                     cSVRName + ".VR_DOC AS DOCOLD, AFJ.AFJ_PROJET AS DOCNEW,"
		cUpdate +=                     cSVRName + ".VR_NRMRP  AS NRMRPOLD,"
		cUpdate +=                     cSVRName + ".VR_INTMRP AS INTMRPOLD"

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD",cUpdate)
	Else
		//Atualiza os registros que já estão na SVR.
		cSqlStmt := " UPDATE " + cSVRName
		cSqlStmt +=    " SET VR_DATA   = AFJ.AFJ_DATA, "
		cSqlStmt +=        " VR_PROD   = AFJ.AFJ_COD, "
		cSqlStmt +=        " VR_QUANT  = AFJ.AFJ_QEMP - AFJ.AFJ_QATU, "

		If lImpAmz
			cSqlStmt +=        " VR_LOCAL  = CASE WHEN AFJ.AFJ_LOCAL <> ' ' "
			cSqlStmt +=                         " THEN AFJ.AFJ_LOCAL "
			cSqlStmt +=                         " ELSE SB1.B1_LOCPAD "
			cSqlStmt +=                    " END, "
		Else
			cSqlStmt += " VR_LOCAL = ' ', "
		EndIf

		cSqlStmt +=        " VR_DOC    = AFJ.AFJ_PROJET, "
		cSqlStmt +=        " VR_NRMRP  = ' ', "
		cSqlStmt +=        " VR_INTMRP = '3' "

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD"," ")
	EndIf

	//Adiciona o relacionamento da SVR com a AFJ
	cSqlStmt += " AND " + cSVRName + ".VR_FILIAL  = '" + xFilial("SVR") + "' "
	cSqlStmt += " AND " + cSVRName + ".D_E_L_E_T_ = ' ' "
	cSqlStmt += " AND " + cSVRName + ".VR_CODIGO  = '" + cDemanda + "' "
	cSqlStmt += " AND " + cSVRName + ".VR_TIPO    = '4' "

	If cBanco == "ORACLE"
		cSqlStmt += " ) T"
		cSqlStmt += " SET T.DATAOLD   = T.DATANEW,"
		cSqlStmt +=     " T.PRODOLD   = T.PRODNEW,"
		cSqlStmt +=     " T.QUANTOLD  = T.QUANTNEW,"
		cSqlStmt +=     " T.LOCALOLD  = T.LOCALNEW,"
		cSqlStmt +=     " T.DOCOLD    = T.DOCNEW,"
		cSqlStmt +=     " T.NRMRPOLD  = ' ',"
		cSqlStmt +=     " T.INTMRPOLD = '3'"
	Else
		cSqlStmt += " AND " + cSVRName + ".VR_REGORI  = AFJ.R_E_C_N_O_ "
	EndIf

	//Executa o UPDATE.
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0068,TCSqlError() + cSqlStmt) //"Erro na importação de Empenhos de Projeto."
	EndIf

	//Verifica quantos registros serão incluidos
	If nTotal == 0
		nTotal := CountRegs(cQryBaseIn)
	EndIf

	//Adiciona os registros que ainda não existem na SVR
	//Monta o comando de Insert.
	cSqlStmt := " INSERT INTO " + RetSqlName("SVR")
	cSqlStmt +=               " (VR_FILIAL,"
	cSqlStmt +=                " VR_SEQUEN,"
	cSqlStmt +=                " VR_CODIGO,"
	cSqlStmt +=                " VR_DATA,"
	cSqlStmt +=                " VR_TIPO,"
	cSqlStmt +=                " VR_PROD,"
	cSqlStmt +=                " VR_QUANT,"
	cSqlStmt +=                " VR_LOCAL,"
	cSqlStmt +=                " VR_DOC,"
	cSqlStmt +=                " VR_ORIGEM,"
	cSqlStmt +=                " VR_NRMRP,"
	cSqlStmt +=                " VR_REGORI,"
	cSqlStmt +=                " VR_INTMRP,"
	cSqlStmt +=                " D_E_L_E_T_,"
	cSqlStmt +=                " R_E_C_D_E_L_)"

	//Adiciona os campos no SELECT.
	cSqlStmt += StrTran(cQryBaseIn, "SELECT 'FIELDS' FLD", cQueryFlds)

	//Adiciona as condições na query para a Inserção.
	cSqlStmt += " AND NOT EXISTS (SELECT 1"
	cSqlStmt +=                   " FROM " + RetSqlName("SVR") + " SVRINS"
	cSqlStmt +=                  " WHERE SVRINS.VR_FILIAL  = '" + xFilial("SVR") + "'"
	cSqlStmt +=                    " AND SVRINS.D_E_L_E_T_ = ' '"
	cSqlStmt +=                    " AND SVRINS.VR_CODIGO  = '" + cDemanda + "'"
	cSqlStmt +=                    " AND SVRINS.VR_TIPO    = '4'"
	cSqlStmt +=                    " AND SVRINS.VR_REGORI  = AFJ.R_E_C_N_O_ )"

	//Executa o INSERT.
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0068,TCSqlError() + cSqlStmt)  //"Erro na importação de Empenhos de Projeto."
	EndIf

Return nTotal

/*/{Protheus.doc} NewTmpPrev
Cria uma temp table para controle das informações de previsões de venda.

@type  Static Function
@author lucas.franca
@since 27/03/2019
@version P12.1.25
@return Nil
/*/
Static Function NewTmpPrev()
	Local cAlias  := GetNextAlias()
	Local aFields := {}

	aAdd(aFields, {"RECPRV", "N", 10, 0})

	_oTmpPrevs := FwTemporaryTable():New(cAlias, aFields)

	_oTmpPrevs:AddIndex("01",{"RECPRV"})

	_oTmpPrevs:Create()
Return Nil

/*/{Protheus.doc} DelTmpPrev
Exclui a tabela temporária de controle das previsões de venda.

@type  Static Function
@author lucas.franca
@since 27/03/2019
@version P12.1.25
@return Nil
/*/
Static Function DelTmpPrev()
	_oTmpPrevs:Delete()
	_oTmpPrevs := Nil
Return Nil

/*/{Protheus.doc} PrcQtdPrev
Faz o processamento das previsões de venda que devem ter a quantidade descontada dos pedidos de venda.

@type  Static Function
@author lucas.franca
@since 27/03/2019
@version P12.1.25
@param cDemanda, Character, Código da demanda que está sendo processada.
@return Nil
/*/
Static Function PrcQtdPrev(cDemanda)
	Local cAliasEnt    := GetNextAlias()
	Local cAliasFat    := GetNextAlias()
	Local cQuery       := ""
	Local cOrder       := ""
	Local cQueryEnt    := ""
	Local cQueryFat    := ""
	Local cWhereSC6    := ""
	Private oPedidos   := JsonObject():New()

	cQuery := " SELECT TMP.RECPRV RECPREVISAO, SVR.R_E_C_N_O_ RECDEMANDA "
	cQuery +=   " FROM " + RetSqlName("SVR") + " SVR, "
	cQuery +=          _oTmpPrevs:GetRealName() + " TMP, "
	cQuery +=              RetSqlName("SC4") + " SC4 "
	cQuery +=  " WHERE SVR.VR_FILIAL  = '" + xFilial("SVR") + "' "
	cQuery +=    " AND SVR.VR_CODIGO  = '" + cDemanda + "' "
	cQuery +=    " AND SVR.VR_TIPO    = '2' "
	cQuery +=    " AND SVR.VR_REGORI  = TMP.RECPRV "
	cQuery +=    " AND SVR.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SC4.R_E_C_N_O_ = SVR.VR_REGORI "
	cQuery +=    " AND EXISTS( SELECT 1 "
	cQuery +=                  " FROM " + RetSqlName("SC6") + " SC6, "
	cQuery +=                             RetSqlName("SF4") + " SF4 "
	cQuery +=                 " WHERE "

	cQueryEnt := cQuery
	cWhereSC6 := WhereDtSC6("C6_ENTREG")

	If MV_PAR20 == MVPAR20_DTFATURA .And. (MV_PAR16 == MVPAR16_FATURADOS .Or. MV_PAR16 == MVPAR16_AMBOS)
		cWhereSC6 += " AND (SC6.C6_DATFAT IS NULL OR SC6.C6_DATFAT = ' ') "
	EndIf
	cQueryEnt += cWhereSC6

	cQueryEnt +=    " ) "

	cOrder += " ORDER BY SVR.VR_FILIAL, SVR.VR_CODIGO, SVR.VR_DATA, SVR.VR_PROD"
	cQueryEnt += cOrder

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryEnt),cAliasEnt,.T.,.T.)

	While (cAliasEnt)->(!Eof())
		AtuDemanda((cAliasEnt)->(RECPREVISAO),(cAliasEnt)->(RECDEMANDA),cWhereSC6)
		(cAliasEnt)->(dbSkip())
	End
	(cAliasEnt)->(dbCloseArea())

	If MV_PAR20 == MVPAR20_DTFATURA .And. (MV_PAR16 == MVPAR16_FATURADOS .Or. MV_PAR16 == MVPAR16_AMBOS)
		cQueryFat := cQuery
		cWhereSC6 := WhereDtSC6("C6_DATFAT")
		cWhereSC6 += " AND (SC6.C6_DATFAT IS NOT NULL AND SC6.C6_DATFAT <> ' ') "
		cQueryFat += cWhereSC6
		cQueryFat +=    " ) "
		cQueryFat += cOrder
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryFat),cAliasFat,.T.,.T.)
		While (cAliasFat)->(!Eof())
			AtuDemanda((cAliasFat)->(RECPREVISAO),(cAliasFat)->(RECDEMANDA),cWhereSC6)
			(cAliasFat)->(dbSkip())
		End
		(cAliasFat)->(dbCloseArea())
	EndIf

Return Nil

/*/{Protheus.doc} WhereDtSC6
Monta o Where da query para descontar os pedidos de venda das previsões de venda

@type  Static Function
@author renan.roeder
@since 22/05/2020
@version P12.1.30
@param cCampo, Character, Campo data da tabela SC6 pelo qual será comparado com a data da previsão de venda.
@return cQuery, Character, condição Where para a query.
/*/
Static Function WhereDtSC6 (cCampo)
	Local cQuery     := ""
	Local cBanco     := AllTrim(Upper(TcGetDb()))
	Local cComp1     := CriaVar("C6_BLQ")
	Local cComp2     := "N"+Space(Len(cComp1)-1)
	Local cQryAno    := ""
	Local cQryMes    := ""

	cQuery :=               " SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
	cQuery +=               " AND SC6.C6_PRODUTO = SC4.C4_PRODUTO "
	cQuery +=               " AND (SC6.C6_BLQ    = '" + cComp1 + "' "
	cQuery +=               "  OR  SC6.C6_BLQ    = '" + cComp2 + "') "
	If MV_PAR16 == MVPAR16_COLOCADOS
		cQuery +=           " AND SC6.C6_QTDENT < SC6.C6_QTDVEN "
	EndIf
	cQuery +=               " AND SC6.D_E_L_E_T_ = ' ' "
	cQuery +=               " AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
	cQuery +=               " AND SF4.F4_CODIGO  = SC6.C6_TES "
	cQuery +=               " AND SF4.F4_ESTOQUE = 'S' "
	cQuery +=               " AND SF4.D_E_L_E_T_ = ' ' "
	cQuery +=               " AND ((SC6.C6_MOPC IS NULL AND SC4.C4_MOPC IS NULL) "
	cQuery +=               "  OR  (SC6.C6_OPC   = SC4.C4_OPC) "
	If cBanco == "ORACLE"
		cQuery +=           "  OR  (dbms_lob.compare(SC6.C6_MOPC,SC4.C4_MOPC)=0) ) "
	Else
		cQuery +=           "  OR  (SC6.C6_MOPC  = SC4.C4_MOPC) ) "
	EndIf

	//Se considera pedidos com bloqueio de crédito.
	If MV_PAR15 != MVPAR15_SIM
		cQuery +=           " AND SC6.C6_OP <> '02' "
	EndIf

	//Se considera somente os pedidos com data >= que a data da previsão de vendas
	If MV_PAR17 != MVPAR17_DIARIO .And. MV_PAR18 == MVPAR18_PARA_FRENTE
		cQuery +=           " AND SC6." + cCampo + " >= SC4.C4_DATA "
	EndIf

	//Faz o filtro dos pedidos de acordo com a periodicidade definida no MV_PAR17
	If cBanco == "POSTGRES"
		cQryAno := " AND DATE_PART('YEAR' , TO_DATE(SC4.C4_DATA,'YYYYMMDD')) = DATE_PART('YEAR' , TO_DATE(SC6." + cCampo + ",'YYYYMMDD')) "
		cQryMes := " AND DATE_PART('MONTH', TO_DATE(SC4.C4_DATA,'YYYYMMDD')) = DATE_PART('MONTH', TO_DATE(SC6." + cCampo + ",'YYYYMMDD')) "
	ElseIf cBanco == "ORACLE"
		cQryAno := " AND EXTRACT(YEAR  FROM TO_DATE(SC4.C4_DATA,'YYYYMMDD')) = EXTRACT(YEAR  FROM TO_DATE(NULLIF(SC6." + cCampo + ",' '),'YYYYMMDD')) "
		cQryMes := " AND EXTRACT(MONTH FROM TO_DATE(SC4.C4_DATA,'YYYYMMDD')) = EXTRACT(MONTH FROM TO_DATE(NULLIF(SC6." + cCampo + ",' '),'YYYYMMDD')) "
	Else
		cQryAno := " AND YEAR( CAST(SC4.C4_DATA   AS DATE)) = YEAR( CAST(SC6." + cCampo + " AS DATE)) "
		cQryMes := " AND MONTH(CAST(SC4.C4_DATA   AS DATE)) = MONTH(CAST(SC6." + cCampo + " AS DATE)) "
	EndIf
	Do Case
		Case MV_PAR17 == MVPAR17_DIARIO
			cQuery +=         " AND SC6." + cCampo + " = SC4.C4_DATA "
		Case MV_PAR17 == MVPAR17_QUINZENAL
			cQuery += cQryAno //Compara o ANO da SC6 e da SC4
			cQuery += cQryMes //Compara o MÊS da SC6 e da SC4
			If cBanco == "POSTGRES"
				cQuery +=   " AND ((DATE_PART('DAY', TO_DATE(SC4.C4_DATA,'YYYYMMDD'))   BETWEEN 1  AND 15 "  //Compara se os dias da SC6 e SC4 estão na primeira quinzena do mês
				cQuery +=   " AND   DATE_PART('DAY', TO_DATE(SC6." + cCampo + ",'YYYYMMDD')) BETWEEN 1  AND 15) " //Compara se os dias da SC6 e SC4 estão na primeira quinzena do mês
				cQuery +=   "  OR  (DATE_PART('DAY', TO_DATE(SC4.C4_DATA,'YYYYMMDD'))   BETWEEN 16 AND 31 "   //Compara se os dias da SC6 e SC4 estão na segunda quinzena do mês
				cQuery +=   " AND   DATE_PART('DAY', TO_DATE(SC6." + cCampo + ",'YYYYMMDD')) BETWEEN 16 AND 31)) " //Compara se os dias da SC6 e SC4 estão na segunda quinzena do mês
			ElseIf cBanco == "ORACLE"
				cQuery +=   " AND ((EXTRACT(DAY FROM TO_DATE(SC4.C4_DATA  ,'YYYYMMDD')) BETWEEN 1  AND 15 "  //Compara se os dias da SC6 e SC4 estão na primeira quinzena do mês
				cQuery +=   " AND   EXTRACT(DAY FROM TO_DATE(SC6." + cCampo + ",'YYYYMMDD')) BETWEEN 1  AND 15) " //Compara se os dias da SC6 e SC4 estão na primeira quinzena do mês
				cQuery +=   "  OR  (EXTRACT(DAY FROM TO_DATE(SC4.C4_DATA  ,'YYYYMMDD')) BETWEEN 16 AND 31 "   //Compara se os dias da SC6 e SC4 estão na segunda quinzena do mês
				cQuery +=   " AND   EXTRACT(DAY FROM TO_DATE(SC6." + cCampo + ",'YYYYMMDD')) BETWEEN 16 AND 31)) " //Compara se os dias da SC6 e SC4 estão na segunda quinzena do mês
			Else
				cQuery +=   " AND ((DAY(CAST(SC4.C4_DATA   AS DATE)) BETWEEN 1  AND 15 "  //Compara se os dias da SC6 e SC4 estão na primeira quinzena do mês
				cQuery +=   " AND   DAY(CAST(SC6." + cCampo + " AS DATE)) BETWEEN 1  AND 15) " //Compara se os dias da SC6 e SC4 estão na primeira quinzena do mês
				cQuery +=   "  OR  (DAY(CAST(SC4.C4_DATA   AS DATE)) BETWEEN 16 AND 31 "   //Compara se os dias da SC6 e SC4 estão na segunda quinzena do mês
				cQuery +=   " AND   DAY(CAST(SC6." + cCampo + " AS DATE)) BETWEEN 16 AND 31)) " //Compara se os dias da SC6 e SC4 estão na segunda quinzena do mês
			EndIf
		Case MV_PAR17 == MVPAR17_SEMANAL
			If cBanco $ "POSTGRES|ORACLE"
				// A conversão TO_CHAR(TO_DATE(SC4.C4_DATA,'YYYYMMDD'), 'IYYY-IW') retorna
				// o valor do ANO + Número da semana.
				//Exemplo: Data '20190101'. A conversão irá retornar o valor 2019-01, sendo '01' o número da semana no ano.
				cQuery +=   " AND TO_CHAR(TO_DATE(SC4.C4_DATA,'YYYYMMDD'), 'IYYY-IW') = TO_CHAR(TO_DATE(SC6." + cCampo + ",'YYYYMMDD'), 'IYYY-IW') " //Compara se a data da SC4 e SC6 estão na mesma semana.
			Else
				cQuery += cQryAno //Compara o ANO da SC6 e da SC4
				cQuery +=   " AND DATEPART(WEEK, CAST(SC4.C4_DATA AS DATE)) = DATEPART(WEEK, CAST(SC6." + cCampo + " AS DATE)) " // Compara se a data da SC4 e SC6 estão na mesma semana do ano.
			EndIf
		Case MV_PAR17 == MVPAR17_MENSAL
			cQuery += cQryAno //Compara o ANO da SC6 e da SC4
			cQuery += cQryMes //Compara o MÊS da SC6 e da SC4
	EndCase

Return cQuery

/*/{Protheus.doc} AtuDemanda
Realiza a atualização da demanda conforme a quantidade atualizada da previsão de vendas

@type  Static Function
@author renan.roeder
@since 22/05/2020
@version P12.1.30
@param nRecPrev , Character, Recno da previsão de vendas (SC4).
@param nRecDem  , Character, Recno da demanda (SVR).
@param cWhereSC6, Character, Condição where para a query da atualização da demanda.
@return Nil.
/*/
Static Function AtuDemanda(nRecPrev,nRecDem,cWhereSC6)
	Local cAliasC6   := ""
	Local cRecPedido := ""
	Local cSqlStmt   := ""
	Local nQtdPedido := 0
	Local nPos       := 0

	cQuery := " SELECT SC6.C6_QTDVEN, "
	cQuery +=        " SC6.C6_QTDENT, "
	cQuery +=        " SC6.R_E_C_N_O_ RECSC6, "
	cQuery +=        " SC4.C4_QUANT "
	cQuery +=  " FROM " + RetSqlName("SC6") + " SC6, "
	cQuery +=             RetSqlName("SF4") + " SF4, "
	cQuery +=             RetSqlName("SC4") + " SC4  "
	cQuery += " WHERE " + cWhereSC6
	cQuery +=   " AND SC4.R_E_C_N_O_ = " + cValToChar(nRecPrev)
	cQuery += " ORDER BY SC6.C6_FILIAL,SC6.C6_ENTREG,SC6.C6_NUM,SC6.C6_ITEM	"

	cAliasC6 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasC6,.T.,.T.)
	While (cAliasC6)->(!Eof())
		cRecPedido := cValToChar((cAliasC6)->(RECSC6))
		If oPedidos[cRecPedido] == Nil
			nQtdPedido := 0

			If MV_PAR16 == MVPAR16_COLOCADOS
				nQtdPedido := (cAliasC6)->(C6_QTDVEN)-(cAliasC6)->(C6_QTDENT)
			EndIf
			If MV_PAR16 == MVPAR16_FATURADOS
				nQtdPedido := (cAliasC6)->(C6_QTDENT)
			EndIf
			If MV_PAR16 == MVPAR16_AMBOS
				nQtdPedido := (cAliasC6)->(C6_QTDVEN)
			EndIf

			oPedidos[cRecPedido] := nQtdPedido
		EndIf

		If oPedidos[cRecPedido] > 0
			SVR->(dbGoTo(nRecDem))

			If oPedidos[cRecPedido] >= SVR->VR_QUANT
				//Quantidade do pedido de venda atende totalmente a previsão de venda.

				//Marca esta demanda no array de registros deletados para integrar com o MRP
				If _lIntMrp .And. _lOnline
					aAdd(_aDelDem, Array(A136APICnt("ARRAY_DEMAND_SIZE")))
					nPos := Len(_aDelDem)

					_aDelDem[nPos][A136APICnt("ARRAY_DEMAND_POS_FILIAL")] := SVR->VR_FILIAL
					_aDelDem[nPos][A136APICnt("ARRAY_DEMAND_POS_CODE")  ] := SVR->VR_CODIGO
					_aDelDem[nPos][A136APICnt("ARRAY_DEMAND_POS_SEQUEN")] := SVR->VR_SEQUEN
				EndIf

				//Excluir a previsão de venda da demanda.
				oPedidos[cRecPedido] -= SVR->VR_QUANT
				cSqlStmt := " DELETE FROM " + RetSqlName("SVR")
				cSqlStmt +=  " WHERE R_E_C_N_O_ = " + cValToChar(nRecDem)
				If TcSqlExec(cSqlStmt) < 0
					Final(STR0069, TCSQLError() + cQuery) //"Erro na importação das previsões de venda. "
				EndIf
				//Demanda já atendida e excluída, termina o LOOP dos pedidos e vai para a próxima demanda.
				Exit
			Else
				//Quantidade do pedido de venda atende parcialmente a previsão de venda.
				//Atualizar a quantidade da demanda.
				cSqlStmt := " UPDATE " + RetSqlName("SVR")
				cSqlStmt +=    " SET VR_QUANT   = VR_QUANT - " + cValToChar(oPedidos[cRecPedido]) + ", "
				cSqlStmt +=        " VR_INTMRP  = '3' "
				cSqlStmt +=  " WHERE R_E_C_N_O_ = " + cValToChar(nRecDem)
				If TcSqlExec(cSqlStmt) < 0
					Final(STR0069, TCSQLError() + cQuery) //"Erro na importação das previsões de venda. "
				EndIf
				oPedidos[cRecPedido] := 0
			EndIf
		EndIf

		(cAliasC6)->(dbSkip())
	End
	(cAliasC6)->(dbCloseArea())

Return Nil


/*/{Protheus.doc} VldImpPDV
Função para validar se todos os registros poderão ser importados.
@type  Static Function
@author marcelo.neumann
@since 08/04/2019
@version P12
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@return lRet   , logical  , Identifica se todos os registros podem ser importados.
/*/
Static Function VldImpPDV(cDemanda)
	Local lRet       := .T.
	Local cQueryBase := getQryPDV("INSERT", .T.) //Estrutura da query

	//Valida se todos os dados retornados pela query são válidos.
	lRet := VldImport(cQueryBase,"SC6.C6_ENTREG","SC6.R_E_C_N_O_","1",cDemanda,"SC6.C6_PRODUTO","(SC6.C6_QTDVEN - SC6.C6_QTDENT)", "SVR.VR_CODIGO")

Return lRet

/*/{Protheus.doc} getQryPDV
Retorna a query com os filtros para importação dos pedidos de venda
@type  Static Function
@author marcelo.neumann
@since 08/04/2019
@version P12
@param cOperacao, character, tipo de operação realizada
@param lValid, lógico, define se a query é montada para validação
@return cQuery , Character, Query com os filtros para importação do PDV
/*/
Static Function getQryPDV(cOperacao, lValid)
	Local cBanco := AllTrim(Upper(TcGetDb()))
	Local cQuery := ""
	Local cRetPe := ""
	Default lValid := .F.

	cQuery := "SELECT 'FIELDS' FLD"
	If cBanco == "ORACLE" .And. cOperacao == "UPDATE"
		cQuery +=    " FROM " + RetSqlName("SVR") + " INNER JOIN " + RetSqlName("SC6") + " SC6 "
		cQuery +=      " ON SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
		cQuery +=     " AND SC6.D_E_L_E_T_ = ' ' "
		cQuery +=     " AND SC6.C6_ENTREG  BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'"
		cQuery +=     " AND SC6.C6_PRODUTO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "

		If _lParLocal
			cQuery += " AND SC6.C6_LOCAL   BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "' "
		EndIf

		cQuery +=     " AND SC6.C6_QTDENT < SC6.C6_QTDVEN"
		cQuery +=     " AND SC6.C6_BLQ <> 'R'"
		cQuery +=     " AND " + RetSqlName("SVR") + ".VR_REGORI  = SC6.R_E_C_N_O_ "
		cQuery +=     " AND " + RetSqlName("SVR") + ".D_E_L_E_T_ = ' ' "
		cQuery +=     " AND " + RetSqlName("SVR") + ".VR_FILIAL  = '" + xFilial("SVR") + "' "
		cQuery +=   " WHERE EXISTS (SELECT 1 FROM "+ RetSqlName("SB1") + " SB1
		cQuery +=                  " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cQuery +=                    " AND SB1.D_E_L_E_T_ = ' ' "
		cQuery +=                    " AND SB1.B1_COD     = SC6.C6_PRODUTO "
		cQuery +=                    " AND SB1.B1_TIPO    BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "' "
		cQuery +=                    " AND SB1.B1_GRUPO   BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "') "
		cQuery +=                    " AND EXISTS (SELECT 1 FROM "+ RetSqlName("SF4") + " SF4
		cQuery +=                                 " WHERE SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
		cQuery +=                                   " AND SF4.D_E_L_E_T_  = ' ' "
		cQuery +=                                   " AND SF4.F4_CODIGO   = SC6.C6_TES "
		cQuery +=                                   " AND SF4.F4_ESTOQUE  = 'S') "
	Else
		cQuery +=  " FROM " + RetSqlName("SC6") + " SC6"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cQuery +=         " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cQuery +=        " AND SB1.D_E_L_E_T_ = ' '"
		cQuery +=        " AND SB1.B1_COD     = SC6.C6_PRODUTO"
		cQuery +=        " AND SB1.B1_TIPO  BETWEEN '" + MV_PAR09 + "' AND '" + MV_PAR10 + "'"
		cQuery +=        " AND SB1.B1_GRUPO BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "'"
		cQuery += " INNER JOIN " + RetSqlName("SF4") + " SF4"
		cQuery +=         " ON SF4.F4_FILIAL  = '" + xFilial("SF4") + "'"
		cQuery += 		 " AND SF4.D_E_L_E_T_ = ' '"
		cQuery += 		 " AND SF4.F4_CODIGO  = SC6.C6_TES"
		cQuery += 		 " AND SF4.F4_ESTOQUE = 'S'"
		If lValid
			cQuery +=	" INNER JOIN " + RetSqlName("SVR") + " SVR "
			cQuery +=	   " ON SC6.C6_PRODUTO = SVR.VR_PROD"
			cQuery +=	  " AND SC6.C6_ENTREG  = SVR.VR_DATA"
			cQuery +=	  " AND SVR.VR_REGORI  = SC6.R_E_C_N_O_"
			cQuery +=	  " AND SVR.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += " WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "'"
		cQuery +=   " AND SC6.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SC6.C6_ENTREG  BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'"
		cQuery +=   " AND SC6.C6_PRODUTO BETWEEN '" + MV_PAR07       + "' AND '" + MV_PAR08       + "'"

		If _lParLocal
			cQuery += " AND SC6.C6_LOCAL BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "' "
		EndIf

		cQuery +=   " AND SC6.C6_QTDENT < SC6.C6_QTDVEN"
		cQuery +=   " AND SC6.C6_BLQ <> 'R'"
	EndIf

	If MV_PAR15 != MVPAR15_SIM
		cQuery += " AND SC6.C6_OP <> '02'"
	EndIf

	// Ponto de entrada para o usuário adicionar seus filtros na importação
	If ExistBlock("P136FIL")
		cRetPe := ExecBlock("P136FIL", .F., .F., "SC6")
		If !Empty(cRetPe)
			cQuery += " AND " + cRetPe
		EndIf
	EndIf

Return cQuery

/*/{Protheus.doc} ImportaPDV
Faz a importação dos pedidos de venda para a tabela de Demandas do MRP (SVR)
@type  Static Function
@author marcelo.neumann
@since 08/04/2019
@param cDemanda, character, Código da demanda que será utilizada para importar os registros.
@param nMinSeq , numeric  , Sequêncial mínimo da SVR
@param lImpAmz , logico   , Indica que deve importar o armazém
@return nTotal , numeric  , Quantidade total de registros atualizados
@version P12
/*/
Static Function ImportaPDV(cDemanda,nMinSeq,lImpAmz)
	Local cQueryFlds := ""
	Local cQryBaseUp := getQryPDV("UPDATE", .F.)	//Estrutura da query.
	Local cQryBaseIn := ""					//Estrutura da query.
	Local cSVRName   := AllTrim(RetSqlName("SVR"))
	Local cSqlStmt   := ""
	Local nDemUtil   := SuperGetMv("MV_DEMUTIL",.F.,1)
	Local nTotal     := 0
	Local cBanco 	 := AllTrim(Upper(TcGetDb()))
	Local cUpdate	 := ''
	Local cWhereBase := ""

	If cBanco == "ORACLE"
		cQryBaseIn := getQryPDV("INSERT", .F.)
	Else
		cQryBaseIn := cQryBaseUp
	EndIf

	//Monta os campos que serão importados pela query.
	cQueryFlds := " SELECT '" + xFilial("SVR") + "', "                    //Filial da SVR
	cQueryFlds +=          getSqlSeq("SC6.R_E_C_N_O_", cDemanda, nMinSeq) + " SEQ, " //Sequencial da SVR
	cQueryFlds +=        " '" + cDemanda + "',"                           //Código da demanda
	cQueryFlds +=        " SC6.C6_ENTREG, "                               //Data da demanda
	cQueryFlds +=        " '1', "                                         //Tipo da demanda
	cQueryFlds +=        " SC6.C6_PRODUTO, "                              //Produto da demanda
	cQueryFlds +=        " (SC6.C6_QTDVEN - SC6.C6_QTDENT), "             //Quantidade da demanda

	If lImpAmz
		cQueryFlds +=        " CASE WHEN SC6.C6_LOCAL <> ' ' "
		cQueryFlds +=             " THEN SC6.C6_LOCAL "
		cQueryFlds +=             " ELSE SB1.B1_LOCPAD "
		cQueryFlds +=        " END C6LOCAL, "                                 //Armazém da demanda
	Else
		cQueryFlds += " ' ' C6LOCAL, "
	EndIf

	cQueryFlds +=        " CONCAT(SC6.C6_NUM,SC6.C6_ITEM), "              //Documento da demanda
	cQueryFlds +=        " SC6.C6_OPC, "                                  //Opcional da demanda
	cQueryFlds +=        " SC6.C6_MOPC, "                                 //Opcional MEMO da demanda
	cQueryFlds +=        " SC6.C6_GRADE, "
	cQueryFlds +=        " SC6.C6_ITEMGRD, "
	cQueryFlds +=        " CASE WHEN SC6.C6_GRADE <> 'S' THEN ' ' "

	//Trata o banco SQLSERVER, pois o comando CONCAT não roda em todas as versões do SQL
	If cBanco == "MSSQL"
		cQueryFlds +=    " ELSE '1SC6' + SC6.C6_NUM  END, "
	Else
		cQueryFlds +=    " ELSE CONCAT('1SC6', SC6.C6_NUM)  END, "
	EndIf
	cQueryFlds +=        " 'SC6' ORIGEM, "                                //Origem do registro
	cQueryFlds +=        " ' ', "                                         //Número do MRP
	cQueryFlds +=        " SC6.R_E_C_N_O_ RECNO, "                        //Registro origem da demanda
	cQueryFlds +=        " '3', "                                         //Indicador de demanda integrada com o MRP
	If x3VRRev()
		cQueryFlds +=    " SC6.C6_REVISAO, "                              //Revisão da estrutura da demanda
	EndIf
	cQueryFlds +=        " ' ', "                                         //D_E_L_E_T_
	cQueryFlds +=        " 0 "                                            //R_E_C_D_E_L_

	//Adiciona os demais filtros na query, após a validação dos registros.
	If nDemUtil == 2
		cWhereBase += " AND EXISTS (SELECT 1 "
		cWhereBase +=               " FROM " + RetSqlName("SVZ") + " SVZ "
		cWhereBase +=              " WHERE SVZ.VZ_FILIAL  = '" + xFilial("SVZ") + "' "
		cWhereBase +=                " AND SVZ.D_E_L_E_T_ = ' ' "
		cWhereBase +=                " AND SVZ.VZ_DATA    = SC6.C6_ENTREG "
		cWhereBase +=                " AND SVZ.VZ_HORAFIM <> '00.00' ) "
	EndIf

	cWhereBase += " AND NOT EXISTS( SELECT 1 "
	cWhereBase +=                   " FROM " + RetSqlName("SVR") + " SVRAUX "
	cWhereBase +=                  " WHERE SVRAUX.VR_FILIAL  = '" + xFilial("SVR") + "' "
	cWhereBase +=                    " AND SVRAUX.D_E_L_E_T_ = ' ' "
	cWhereBase +=                    " AND SVRAUX.VR_TIPO    = '1' "
	cWhereBase +=                    " AND SVRAUX.VR_REGORI  = SC6.R_E_C_N_O_ "
	cWhereBase +=                    " AND SVRAUX.VR_DATA    = SC6.C6_ENTREG "
	cWhereBase +=                    " AND SVRAUX.VR_CODIGO  <> '" + cDemanda + "' )"

	cQryBaseUp += cWhereBase
	cQryBaseIn += cWhereBase

	//Identifica quantos registros serão atualizados.
	nTotal := CountRegs(cQryBaseUp)
	If nTotal > 0
		If !MsgImporta()
			Return -1
		EndIf
	EndIf

	IF cBanco == "ORACLE"
		//Atualiza os registros que já estão na SVR.
		cUpdate := "UPDATE (SELECT " + cSVRName + ".VR_DATA  AS DATAOLD,  SC6.C6_ENTREG  AS DATANEW,"
		cUpdate +=                     cSVRName + ".VR_PROD  AS PRODOLD,  SC6.C6_PRODUTO AS PRODNEW,"
		cUpdate +=                     cSVRName + ".VR_QUANT AS QUANTOLD, (SC6.C6_QTDVEN - SC6.C6_QTDENT) AS QUANTNEW,"

		If lImpAmz
			cUpdate +=                 cSVRName + ".VR_LOCAL AS LOCALOLD, CASE WHEN SC6.C6_LOCAL <> ' ' "
			cUpdate +=                                                  " THEN SC6.C6_LOCAL        "
			cUpdate +=                                                  " ELSE (SELECT SB1.B1_LOCPAD "
			cUpdate +=                                                          " FROM " + RetSqlName("SB1") + " SB1 "
			cUpdate +=                                                         " WHERE SB1.B1_FILIAL  = '  ' "
			cUpdate +=                                                           " AND SB1.D_E_L_E_T_ = ' ' "
			cUpdate +=                                                           " AND SB1.B1_COD     = SC6.C6_PRODUTO ) "
			cUpdate +=                                                   " END AS LOCALNEW, "
		Else
			cUpdate +=                cSVRName + ".VR_LOCAL AS LOCALOLD, ' ' AS LOCALNEW, "
		EndIf

		cUpdate +=                    cSVRName + ".VR_DOC     AS DOCOLD,     SC6.C6_NUM||SC6.C6_ITEM AS DOCNEW,"
		cUpdate +=                    cSVRName + ".VR_OPC     AS OPCOLD,     SC6.C6_OPC     AS OPCNEW,"
		cUpdate +=                    cSVRName + ".VR_MOPC    AS MOPCOLD,    SC6.C6_MOPC    AS MOPCNEW,"
		cUpdate +=                    cSVRName + ".VR_GRADE   AS GRADEOLD  , SC6.C6_GRADE   AS GRADENEW,"
		cUpdate +=                    cSVRName + ".VR_ITEMGRD AS ITEMGRDOLD, SC6.C6_ITEMGRD AS ITEMGRDNEW,"
		cUpdate +=                    cSVRName + ".VR_IDGRADE AS IDGRADEOLD, CASE WHEN SC6.C6_GRADE <> 'S' THEN ' ' ELSE CONCAT('1SC6', SC6.C6_NUM)  END AS IDGRADENEW,"
		cUpdate +=                    cSVRName + ".VR_NRMRP   AS NRMRPOLD,"
		cUpdate +=                    cSVRName + ".VR_INTMRP  AS INTMRPOLD"

		If x3VRRev()
			cUpdate +=         ", " + cSVRName + ".VR_REV     AS REVOLD,     SC6.C6_REVISAO AS REVNEW"
		EndIf

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD",cUpdate)
	Else
		//Atualiza os registros que já estão na SVR.
		cSqlStmt := " UPDATE " + cSVRName
		cSqlStmt +=    " SET VR_DATA    = SC6.C6_ENTREG, "
		cSqlStmt +=        " VR_PROD    = SC6.C6_PRODUTO, "
		cSqlStmt +=        " VR_QUANT   = (SC6.C6_QTDVEN - SC6.C6_QTDENT), "

		If lImpAmz
			cSqlStmt +=    " VR_LOCAL   = CASE WHEN SC6.C6_LOCAL <> ' ' "
			cSqlStmt +=                      " THEN SC6.C6_LOCAL "
			cSqlStmt +=                      " ELSE SB1.B1_LOCPAD "
			cSqlStmt +=                 " END, "
		Else
			cSqlStmt +=    " VR_LOCAL   = ' ', "
		EndIf

		cSqlStmt +=        " VR_DOC     = SC6.C6_NUM || SC6.C6_ITEM,"
		cSqlStmt +=        " VR_OPC     = SC6.C6_OPC,"
		cSqlStmt +=        " VR_MOPC    = SC6.C6_MOPC,"
		cSqlStmt +=        " VR_GRADE   = SC6.C6_GRADE,"
		cSqlStmt +=        " VR_ITEMGRD = SC6.C6_ITEMGRD,"
		cSqlStmt +=        " VR_IDGRADE = CASE WHEN SC6.C6_GRADE <> 'S'  THEN ' ' "

		//Trata o banco SQLSERVER, pois o comando CONCAT não roda em todas as versões do SQL
		If cBanco == "MSSQL"
			cSqlStmt += " ELSE '1SC6' + SC6.C6_NUM END, "
		Else
			cSqlStmt += " ELSE CONCAT('1SC6', SC6.C6_NUM)  END, "
		EndIf

		cSqlStmt +=        " VR_NRMRP   = ' ', "
		cSqlStmt +=        " VR_INTMRP  = '3' "

		If x3VRRev()
			cSqlStmt +=   ", VR_REV     = SC6.C6_REVISAO "
		EndIf

		//Recupera os filtros da query para atualização dos registros
		cSqlStmt += StrTran(cQryBaseUp,"SELECT 'FIELDS' FLD"," ")
	EndIf

	//Adiciona o relacionamento da SVR com a SC6
	cSqlStmt += " AND " + cSVRName + ".VR_FILIAL  = '"+xFilial("SVR")+"' "
	cSqlStmt += " AND " + cSVRName + ".D_E_L_E_T_ = ' ' "
	cSqlStmt += " AND " + cSVRName + ".VR_CODIGO  = '"+cDemanda+"' "
	cSqlStmt += " AND " + cSVRName + ".VR_TIPO    = '1' "

	If cBanco == "ORACLE"
		cSqlStmt += " ) T"
		cSqlStmt += " SET T.DATAOLD    = T.DATANEW,"
		cSqlStmt +=     " T.PRODOLD    = T.PRODNEW,"
		cSqlStmt +=     " T.QUANTOLD   = T.QUANTNEW,"
		cSqlStmt +=     " T.LOCALOLD   = T.LOCALNEW,"
		cSqlStmt +=     " T.DOCOLD     = T.DOCNEW,"
		cSqlStmt +=     " T.OPCOLD     = T.OPCNEW,"
		cSqlStmt +=     " T.MOPCOLD    = T.MOPCNEW,"
		cSqlStmt +=     " T.GRADEOLD   = T.GRADENEW,"
		cSqlStmt +=     " T.ITEMGRDOLD = T.ITEMGRDNEW,"
		cSqlStmt +=     " T.IDGRADEOLD = T.IDGRADENEW,"
		cSqlStmt +=     " T.NRMRPOLD   = ' ',"
		cSqlStmt +=     " T.INTMRPOLD  = '3'"
		If x3VRRev()
			cSqlStmt += ", T.REVOLD  = T.REVNEW "
		EndIf
	Else
		cSqlStmt += " AND " + cSVRName + ".VR_REGORI  = SC6.R_E_C_N_O_ "
	EndIf

	//Executa o UPDATE.
	cSqlStmt := TrataQuery(cSqlStmt)
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0070,TCSqlError() + cSqlStmt) //"Erro na importação dos Pedidos de Venda."
	EndIf

	//Verifica quantos registros serão incluidos
	If nTotal == 0
		nTotal := CountRegs(cQryBaseIn)
	EndIf

	//Adiciona os registros que ainda não existem na SVR
	//Monta o comando de Insert.
	cSqlStmt := " INSERT INTO " + RetSqlName("SVR")
	cSqlStmt +=               " (VR_FILIAL,"
	cSqlStmt +=                " VR_SEQUEN,"
	cSqlStmt +=                " VR_CODIGO,"
	cSqlStmt +=                " VR_DATA,"
	cSqlStmt +=                " VR_TIPO,"
	cSqlStmt +=                " VR_PROD,"
	cSqlStmt +=                " VR_QUANT,"
	cSqlStmt +=                " VR_LOCAL,"
	cSqlStmt +=                " VR_DOC,"
	cSqlStmt +=                " VR_OPC,"
	cSqlStmt +=                " VR_MOPC,"
	cSqlStmt +=                " VR_GRADE,"
	cSqlStmt +=                " VR_ITEMGRD,"
	cSqlStmt +=                " VR_IDGRADE,"
	cSqlStmt +=                " VR_ORIGEM,"
	cSqlStmt +=                " VR_NRMRP,"
	cSqlStmt +=                " VR_REGORI,"
	cSqlStmt +=                " VR_INTMRP,"
	If x3VRRev()
		cSqlStmt +=            " VR_REV,"
	EndIf
	cSqlStmt +=                " D_E_L_E_T_,"
	cSqlStmt +=                " R_E_C_D_E_L_)"

	//Adiciona os campos no SELECT.
	cSqlStmt += StrTran(cQryBaseIn, "SELECT 'FIELDS' FLD", cQueryFlds)

	//Adiciona as condições na query para a Inserção.
	cSqlStmt += " AND NOT EXISTS (SELECT 1"
	cSqlStmt +=                   " FROM " + RetSqlName("SVR") + " SVRINS"
	cSqlStmt +=                  " WHERE SVRINS.VR_FILIAL  = '" + xFilial("SVR") + "'"
	cSqlStmt +=                    " AND SVRINS.D_E_L_E_T_ = ' '"
	cSqlStmt +=                    " AND SVRINS.VR_CODIGO  = '" + cDemanda + "'"
	cSqlStmt +=                    " AND SVRINS.VR_TIPO    = '1'"
	cSqlStmt +=                    " AND SVRINS.VR_REGORI  = SC6.R_E_C_N_O_ )"

	//Executa o INSERT.
	cSqlStmt := TrataQuery(cSqlStmt)
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0070, TCSqlError() + cSqlStmt) //"Erro na importação dos Pedidos de Venda."
	EndIf

Return nTotal

/*/{Protheus.doc} TrataQuery
Trata a query de acordo com o banco de dados do cliente
@type  Static Function
@author marcelo.neumann
@since 16/04/2019
@param cQuery, character, query para fazer as tratativas de banco de dados
@return cQuery, character, query adaptada para o banco de dados
@version P12
/*/
Static Function TrataQuery(cQuery)

	Local cBanco := Upper(TCGetDB())

	If "MSSQL" $ cBanco
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')
	EndIf

Return cQuery

/*/{Protheus.doc} GravaLog
Grava o modelo de Log de importação com o erro ocorrido
@type  Static Function
@author marcelo.neumann
@since 23/04/2019
@param cTipo   , character, Tipo de demanda
@param cProduto, character, Código do produto
@param nQuant  , numeric  , Quantidade da demanda
@param dData   , character, Data da demanda
@param cErro   , character, Mensagem de inconsistência
@return Nil
@version P12
/*/
Static Function GravaLog(cTipo, cProduto, nQuant, dData, cErro)

	Local oModelImp := FWModelActive()

	If !oModelImp:GetModel("GRID_LOG"):IsEmpty()
		oModelImp:GetModel("GRID_LOG"):AddLine()
	EndIf

	oModelImp:GetModel("GRID_LOG"):LoadValue("VR_TIPO" , cTipo)
	oModelImp:GetModel("GRID_LOG"):LoadValue("VR_PROD" , cProduto)
	oModelImp:GetModel("GRID_LOG"):LoadValue("VR_QUANT", nQuant)
	oModelImp:GetModel("GRID_LOG"):LoadValue("VR_DATA" , dData)
	oModelImp:GetModel("GRID_LOG"):LoadValue("CMOTIVO" , cErro)

Return

/*/{Protheus.doc} MsgImporta
Verifica se deve emitir a mensagem de demandas pendentes
@type  Static Function
@author marcelo.neumann
@since 23/04/2019
@return lContinua, logical, indica se deverá continuar a importação dos registros
@version P12
/*/
Static Function MsgImporta()

	Local lContinua := .T.

	If !IsBlind() .And. _lTemErro .And. _nOrigImp <> IND_ORIGEM_ATUALIZACAO .And. !_l136AtuAuto
		//Exibe inconsistências?
		If MV_PAR19 == 1
			lContinua := MsgYesNo(STR0073,STR0072) //"Deseja importar os registros válidos?" - "Continuar a importação?"
		Else
			lContinua := MsgYesNo(STR0074,STR0072) //"Alguns registros não serão importados pois não atendem todos os critérios de validação deste programa. Deseja importar os registros válidos?" - "Continuar a importação?"
		EndIf
		_lTemErro := .F.
	EndIf

Return lContinua

/*/{Protheus.doc} intDemMrp
Executa a integração das demandas importadas para o MRP

@type  Static Function
@author lucas.franca
@since 16/05/2019
@version P12.1.25
@param  cDemanda, Caracter, Código da demanda que está sendo importada.
@return Nil
/*/
Static Function intDemMrp(cDemanda)
	Local aDadosInc  := {}
	Local cAlias     := GetNextAlias()
	Local cCondTipo  := ""
	Local cQryFields := ""
	Local cRevisao   := ""
	Local cTipos     := ""
	Local nIndex     := 0
	Local cMV_PAR22  := MV_PAR22
 	Local cMV_PAR23  := MV_PAR23

	If !(_lParLocal)
		cMV_PAR22 := Space(GetSx3Cache("VR_LOCAL","X3_TAMANHO"))
		cMV_PAR23 := Replicate("z",GetSx3Cache("VR_LOCAL","X3_TAMANHO"))
	EndIf

	If MV_PAR01 == 1 //Importa pedidos de venda? 1-Sim; 2-Não.
		cTipos += "'1'"
	EndIf

	If MV_PAR02 == 1 //Importa previsão de vendas? 1-Sim; 2-Não.
		If !Empty(cTipos)
			cTipos += ","
		EndIf
		cTipos += "'2'"
	EndIf

	If MV_PAR03 == 1 //Importa plano mestre? 1-Sim; 2-Não.
		If !Empty(cTipos)
			cTipos += ","
		EndIf
		cTipos += "'3'"
	EndIf

	If MV_PAR04 == 1 //Importa empenhos de projeto? 1-Sim; 2-Não.
		If !Empty(cTipos)
			cTipos += ","
		EndIf
		cTipos += "'4'"
	EndIf

	If !Empty(cTipos)
		cCondTipo := "% SVR.VR_TIPO IN (" + cTipos + ") %"
	Else
		cCondTipo := "% 1 = 1 %"
	EndIf

	cQryFields := "SVR.VR_FILIAL, SVR.VR_CODIGO, SVR.VR_SEQUEN, SVR.VR_PROD, SVR.VR_DATA, SVR.VR_TIPO, SVR.VR_DOC, SVR.VR_QUANT, SVR.VR_LOCAL"
	If x3VRRev()
		cQryFields += ", SVR.VR_REV"
	EndIf
	cQryFields += ", SVR.VR_MOPC"

	cQryFields := "%" + cQryFields + "%"

	//Busca na SVR os registros que foram incluídos/atualizados
	//neste processo de importação, e integra com o MRP.
	BeginSql Alias cAlias
		column VR_DATA as Date
		SELECT %Exp:cQryFields%
		  FROM %table:SVR% SVR
		 INNER JOIN %table:SB1% SB1
			ON SB1.B1_FILIAL = %xFilial:SB1%
		   AND SB1.B1_COD    = SVR.VR_PROD
		   AND SB1.B1_TIPO   BETWEEN %exp:MV_PAR09% AND %exp:MV_PAR10%
		   AND SB1.B1_GRUPO  BETWEEN %exp:MV_PAR11% AND %exp:MV_PAR12%
		   AND SB1.%notDel%
		 WHERE SVR.VR_FILIAL = %xFilial:SVR%
		   AND SVR.VR_CODIGO = %exp:cDemanda%
		   AND %exp:cCondTipo%
		   AND SVR.VR_DATA  BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
		   AND SVR.VR_PROD  BETWEEN %exp:MV_PAR07% AND %exp:MV_PAR08%
		   AND SVR.VR_LOCAL BETWEEN %exp:cMV_PAR22% AND %exp:cMV_PAR23%
		   AND (SVR.VR_TIPO IN('1','4') OR SVR.VR_DOC  BETWEEN %exp:MV_PAR13% AND %exp:MV_PAR14%)
		   AND SVR.%notDel%
	EndSql

	While (cAlias)->(!Eof())
		cRevisao := ""

		If x3VRRev()
			cRevisao := (cAlias)->(VR_REV)
		EndIf

		aAdd(aDadosInc, Array(A136APICnt("ARRAY_DEMAND_SIZE")))
		nIndex++

		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_FILIAL")] := (cAlias)->(VR_FILIAL)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_CODE")  ] := (cAlias)->(VR_CODIGO)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_SEQUEN")] := (cAlias)->(VR_SEQUEN)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_PROD")  ] := (cAlias)->(VR_PROD)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_REV")   ] := cRevisao
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_DATA")  ] := (cAlias)->(VR_DATA)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_TIPO")  ] := (cAlias)->(VR_TIPO)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_DOC")   ] := (cAlias)->(VR_DOC)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_QUANT") ] := (cAlias)->(VR_QUANT)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_LOCAL") ] := (cAlias)->(VR_LOCAL)
		aDadosInc[nIndex][A136APICnt("ARRAY_DEMAND_POS_OPC")   ] := (cAlias)->(VR_MOPC)
		(cAlias)->(dbSkip())

		If nIndex == VOL_BUFFER .Or. (cAlias)->(Eof())
			//Executa a integração para inclusão/atualização de demandas.
			PCPA136INT("INSERT", aDadosInc, _oTmpInMrp)
			aSize(aDadosInc, 0)
			nIndex := 0
		EndIf
	End

	//Executa a integração para exclusão de demandas
	If Len(_aDelDem) > 0
		PCPA136INT("DELETE", _aDelDem, _oTmpInMrp)
		aSize(_aDelDem, 0)
	EndIf

Return

/*/{Protheus.doc} VldDeleted
Valida se existe registro importado que foi deletado da origem

@type Static Function
@author marcelo.neumann
@since 02/01/2020
@version P12.1.25
@param 01 cDemanda , Caracter, Código da demanda que está sendo importada
@return   nIndex   , Numeric , Quantidade de registros excluídos
/*/
Static Function VldDeleted(cDemanda)

	Local cAlias     	:= GetNextAlias()
	Local cQryCondic 	:= ""
	Local cQuery     	:= ""
	Local cRecnos    	:= ""
	Local nIndex     	:= 0
	Local nBuffer	    := 0
	Local nQtdDel    	:= Len(_aDelDem)

	If MV_PAR01 <> 1 .And. MV_PAR02 <> 1 .And. MV_PAR03 <> 1 .And. MV_PAR04 <> 1
		Return 0
	EndIf

	cQryCondic := "%" + RetSqlName("SVR") + " SVR"                                                    + ;
	              " WHERE SVR.VR_FILIAL = '" + xFilial("SVR") + "'"                                   + ;
	                " AND SVR.VR_CODIGO = '" + cDemanda + "'"                                         + ;
	                " AND SVR.VR_DATA  BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'" + ;
	                " AND SVR.VR_PROD  BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "'"

	If _lParLocal
		cQryCondic += " AND SVR.VR_LOCAL BETWEEN '" + MV_PAR22 + "' AND '" + MV_PAR23 + "'"
	EndIf

	cQryCondic +=   " AND ("

	//Importa pedido de venda
	If MV_PAR01 == 1
		cQryCondic += "(SVR.VR_TIPO = '1' AND "                                                                                + ;
		              " NOT EXISTS (SELECT 1 "                                                                                 + ;
		                            " FROM " + RetSqlName("SC6") + " SC6"                                                      + ;
				  			       " WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "'"                                          + ;
							         " AND SC6.D_E_L_E_T_ = ' '"                                                               + ;
							         " AND SC6.R_E_C_N_O_ = SVR.VR_REGORI"                                                     + ;
									 " AND SC6.C6_QTDENT  < SC6.C6_QTDVEN"                                                     + ;
									 " AND SC6.C6_BLQ <> 'R'"                                                                  + ;
									 " AND SC6.C6_ENTREG BETWEEN '" + DtoS(MV_PAR05)  + "' AND '" + DtoS(MV_PAR06) + "' )) OR"
	EndIf

	//Importa previsão de venda
	If MV_PAR02 == 1
		cQryCondic += "(SVR.VR_TIPO = '2' AND "                                                                       + ;
		              " NOT EXISTS (SELECT 1 "                                                                        + ;
		                            " FROM " + RetSqlName("SC4") + " SC4"                                             + ;
				  			       " WHERE SC4.C4_FILIAL  = '" + xFilial("SC4") + "'"                                 + ;
							         " AND SC4.D_E_L_E_T_ = ' '"                                                      + ;
									 " AND SC4.C4_DATA BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'" + ;
							         " AND SC4.R_E_C_N_O_ = SVR.VR_REGORI)) OR"
	EndIf

	//Importa plano mestre
	If MV_PAR03 == 1
		cQryCondic += "(SVR.VR_TIPO = '3' AND "                                                                       + ;
		              " NOT EXISTS (SELECT 1 "                                                                        + ;
		                            " FROM " + RetSqlName("SHC") + " SHC"                                             + ;
				  			       " WHERE SHC.HC_FILIAL  = '" + xFilial("SHC") + "'"                                 + ;
							         " AND SHC.D_E_L_E_T_ = ' '"                                                      + ;
							         " AND SHC.R_E_C_N_O_ = SVR.VR_REGORI"                                            + ;
									 " AND SHC.HC_DATA BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'" + ;
									 " AND SHC.HC_STATUS  = ' ')) OR"
	EndIf

	//Importa Empenhos de Projeto
	If MV_PAR04 == 1
		cQryCondic += "(SVR.VR_TIPO = '4' AND "                                                                        + ;
		              " NOT EXISTS (SELECT 1 "                                                                         + ;
		                            " FROM " + RetSqlName("AFJ") + " AFJ"                                              + ;
				  			       " WHERE AFJ.AFJ_FILIAL = '" + xFilial("AFJ") + "'"                                  + ;
							         " AND AFJ.D_E_L_E_T_ = ' '"                                                       + ;
									 " AND AFJ.AFJ_DATA BETWEEN '" + DtoS(MV_PAR05) + "' AND '" + DtoS(MV_PAR06) + "'" + ;
							         " AND AFJ.R_E_C_N_O_ = SVR.VR_REGORI)) OR"
	EndIf

	//Remove o último OR
	cQryCondic := Stuff(cQryCondic, Len(cQryCondic)-2, 3, '') + ")"
	cQryCondic += " AND SVR.D_E_L_E_T_ = ' '%"

	//Busca todos os registros que foram removidos da origem
	BeginSql Alias cAlias
		SELECT SVR.VR_FILIAL,
		       SVR.VR_CODIGO,
		       SVR.VR_SEQUEN,
		       SVR.R_E_C_N_O_
		  FROM %Exp:cQryCondic%
	EndSql

	While (cAlias)->(!Eof())
		//Se a integração é Online, traz as informações para enviar para a API
		If _lIntMrp .And. _lOnline
			aAdd(_aDelDem, Array(A136APICnt("ARRAY_DEMAND_SIZE")))
			nQtdDel++

			_aDelDem[nQtdDel][A136APICnt("ARRAY_DEMAND_POS_FILIAL")] := (cAlias)->(VR_FILIAL)
			_aDelDem[nQtdDel][A136APICnt("ARRAY_DEMAND_POS_CODE")  ] := (cAlias)->(VR_CODIGO)
			_aDelDem[nQtdDel][A136APICnt("ARRAY_DEMAND_POS_SEQUEN")] := (cAlias)->(VR_SEQUEN)
		EndIf

		cRecnos += "," + cValToChar((cAlias)->(R_E_C_N_O_))
		nIndex++
		nBuffer++

		(cAlias)->(dbSkip())
		//se for final de arquivo, ou o index for maior do que 500 registros, realiza o update na SVR
		If ((cAlias)->(Eof()) .or. nBuffer > 500)

			cQuery := "UPDATE " + RetSqlName("SVR")      + ;
						" SET D_E_L_E_T_ = '*',"         + ;
							" R_E_C_D_E_L_ = R_E_C_N_O_" + ;
					" WHERE R_E_C_N_O_ IN (" + Stuff(cRecnos, 1, 1, '') + ")"

			If TcSqlExec(cQuery) < 0
				//Em caso de erro, finaliza o programa.
				Final(STR0001,TCSqlError() + cQuery) //"Erro ao atualizar o STATUS de integração das demandas."
			EndIf
			//reinicia os contadores
			nBuffer := 0
			cRecnos := ''
		EndIf
	End

Return nIndex

/*/{Protheus.doc} IncreBarra
Incrementa a barra de progresso validando a origem da importação

@type Static Function
@author marcelo.neumann
@since 11/02/2021
@version P12.1.33
@param cMensagem, Caracter, Mensagem a ser exibida na barra de progresso
@return Nil
/*/
Static Function IncreBarra(cMensagem)

	If _nOrigImp <> IND_ORIGEM_ATUALIZACAO
		IncProc(cMensagem) //"Validando informações dos Pedidos de Venda."
	EndIf

Return

/*/{Protheus.doc} P136SetOri
Valida se existe registro importado que foi deletado da origem

@type Function
@author marcelo.neumann
@since 11/02/2021
@version P12.1.33
@param nOrigem, Numeric, Indicador da origem da importação (1-Browse; 2-Model; 3-Atualização)
@return Nil
/*/
Function P136SetOri(nOrigem)

	_nOrigImp := nOrigem

Return

/*/{Protheus.doc}
Verifica se o campo para gravar a revisão da estrutura está presente no dicionario de dados.
@type  Static Function
@author Ana Paula dos Santos
@since 14/05/2025
@version P12
@return _lVRRev, Logico, Indica se o campo VR_REV esta no dicionario de dados.
/*/
Static Function x3VRRev()

	If _lVRRev == Nil
		_lVRRev := GetSx3Cache("VR_REV", "X3_TAMANHO") > 0
	EndIf

Return _lVRRev

