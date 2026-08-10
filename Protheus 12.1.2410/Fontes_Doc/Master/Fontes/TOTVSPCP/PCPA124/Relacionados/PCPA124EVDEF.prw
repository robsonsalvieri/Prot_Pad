#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA124.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TbIconn.ch"

Static _lNewMRP   := Nil

/*/{Protheus.doc} PCPA120EVDEF
Eventos padrões da manutenção dos processos produtivos
@author Carlos Alexandre da Silveira
@since 02/05/2018
@version P12.1.17

/*/
CLASS PCPA124EVDEF FROM FWModelEvent

	DATA aModelosSFC
	DATA aMRPxJson
	DATA cFileSFC
	DATA lIntNewMRP
	DATA lMA630VLE
	DATA lHasErrorSFC
	DATA lExecutaPreVld
	DATA oTempSHY

	METHOD New() CONSTRUCTOR

	METHOD Activate()
	METHOD DeActivate()
	METHOD VldActivate()
	METHOD ModelPosVld()
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
	METHOD Before()
	METHOD BeforeTTS()
	METHOD InTTS()

	METHOD ValidaDelete()
	METHOD limpaModelosSFC()
	METHOD VldRotUsado()

ENDCLASS

METHOD New() CLASS  PCPA124EVDEF

	::cFileSFC       := ""
	::lHasErrorSFC   := .F.
	::lIntNewMRP     := FindFunction("Ma637MrpOn") .AND. FWAliasInDic( "HW9", .F. )
	::lMA630VLE      := ExistBlock("MA630VLE")
	::lExecutaPreVld := .F.
	::aModelosSFC    := {}
	::oTempSHY       := Nil
Return

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author Carlos Alexandre da Silveira
@since 04/06/2018
@version 1.0
@return .T.
/*/
METHOD Activate(oModel, cModelId) Class PCPA124EVDEF
	Local oModelG2   	:= oModel:GetModel("PCPA124_SG2")
	Local oCab			:= oModel:GetModel("PCPA124_CAB")
	Local nOperation	:= oModel:GetOperation()
	Local lRet 			:= .T.
	Local nX 			:= 0

	If nOperation # 3 .And. Empty(oCab:GetValue("G2_PRODUTO")) .And. nOperation # 5
		oCab:LoadValue("G2_PRODUTO",PadR(SG2->G2_REFGRD,TamSX3("G2_PRODUTO")[1]))
	EndIf

	If nOperation == 4
		For nX := 1 To oModelG2:Length()
			oModelG2:GoLine(nX)
			oModelG2:SetValue("COPERAC", oModelG2:GetValue("G2_OPERAC"))
		Next nX
		oModelG2:GoLine(1)
	EndIf

Return lRet

/*/{Protheus.doc} DeActivate
Método que é chamado pelo MVC quando ocorrer a desativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author Marcelo Neumann
@since 19/10/2018
@version 1.0
@return .T.
/*/
METHOD DeActivate(oModel) Class PCPA124EVDEF

	//oModel:SetLoadXML( {|| } )

Return

/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author Carlos Alexandre da Silveira
@since 04/06/2018
@version 1.0
@return .T.
/*/
METHOD VldActivate(oModel, cModelId) Class PCPA124EVDEF
	Local lRet		:= .T.
	Local aSaveArea	:= GetArea()
	Local cProduto	:= SG2->G2_PRODUTO
	Local cRoteiro	:= SG2->G2_CODIGO

	//Se a variável private não tiver sido declarada, atribui padrão .F.
	lBrowse := If(Type("lBrowse")=="U", .F., lBrowse)

	If lBrowse .And. (oModel:GetOperation() == 4 .Or. oModel:GetOperation() == 5) .And. IsProdProt(SG2->G2_PRODUTO)
		lRet := .F.
		Help(" ",1,"ISPRODPROT") //Este produto é um protótipo e de uso reservado do módulo Desenvolvedor de Produtos (DPR).
	EndIf

	//Validacoes do Quality
	If lRet .And. IntQIP(cProduto) .And. oModel:GetOperation() == 5
		lRet := QIPValDOpr(cProduto,cRoteiro,NIL,0)
	EndIf

	If GetSx3Cache("H3_ORDEM", "X3_TAMANHO") > 0
		geraOrdem(cRoteiro, cProduto)
	EndIf

	RestArea(aSaveArea)
Return lRet

/*/{Protheus.doc} ModelPosVld
Pós validação do modelo
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return .T.
/*/
METHOD ModelPosVld(oModel, cModelId) Class PCPA124EVDEF
	Local aSaveArea	:= GetArea()
	Local cNameFile := "OPER-" + Dtos(Date()) + ".log"
	Local cProduto	:= oModel:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")
	Local cRoteiro	:= oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")
	Local lIntSFC   := ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")
	Local lProces   := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. lIntSFC .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T. .Or. PCPIntgPPI()
	Local lRet		:= .T.
	Local nI        := 0
	Local nLineSG2  := 0
	Local nOpc      := oModel:GetOperation()
	Local oModelOrd := Nil
	Local oModelSG2 := oModel:GetModel("PCPA124_SG2")
	Local oTemp     := Nil


	//Variáveis Private utilizadas pelos modelos do SIGASFC
	Private _lErrSFC  := .F.
	Private _nHndSFC  := Iif(lIntSFC,FCreate(cNameFile),-1)

	//Carrega as informações do arquivo de LOG do SFC nos atributos da classe, para utilizar no fim do commit.
	::cFileSFC     := cNameFile
	::lHasErrorSFC := .F.
	If oModel:GetOperation() == 4
		For nI := 1 to oModelSG2:Length()
			oModelSG2:GoLine(nI)
			//Faz as validações de linha
			lRet := ::GridLinePosVld(oModelSG2,oModelSG2:GetId())
			If !lRet
				Exit
			EndIf
		Next
	EndIf

	If lRet .And. oModel:GetOperation() == 5
		//Não deve permitir a Exclusão se tiver algum componente (MVC não está validando a SX9 na Exclusão)
		SGF->(dbSetOrder(1))
		If SGF->(DbSeek(xFilial("SGF") + cProduto + cRoteiro))
			If !SGF->(Eof())						.And. ;
				SGF->GF_FILIAL  == xFilial("SGF")	.And. ;
				SGF->GF_PRODUTO == cProduto 		.And. ;
				SGF->GF_ROTEIRO == cRoteiro

				lRet := .F.
				Help( ,  , STR0074, ,  STR0024,;	//STR0074 - Help - STR0024 - Roteiro/Operação não poderá ser excluído. Existem Componentes relacionados à esse Roteiro/Operação
					 1, 0, , , , , , {STR0025}) //STR0025 - Exclua os componentes no cadastro Operação X Componente
			EndIf
		EndIf

		If lRet
			If ! ::VldRotUsado(cProduto, cRoteiro)
				lRet := .F.
				Help( ,  , STR0074, ,  STR0075,;	//STR0074 - Help - STR0075 - "Este roteiro está associado a ordens de produção e não poderá ser excluído."
					 1, 0, , , , , ,)
			EndIf
		EndIf

		If lRet
			lRet := ::ValidaDelete(cProduto, cRoteiro)
		EndIf
	EndIf

	If lRet .And. (nOpc == 3 .OR. nOpc == 4) .And. (SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. IntegraSFC())
		nLineSG2 := oModelSG2:GetLine()
		// Validar os recursos alternativos e secundários. Devem possuir o mesmo CT da operação.
		For nI := 1 to oModelSG2:Length()
			If !lRet
				Exit
			EndIf
			oModelSG2:GoLine(nI)

			//Faz as validações de linha
			lRet := ::GridLinePosVld(oModelSG2,oModelSG2:GetId())
			If !lRet
				Exit
			EndIf
		Next
		oModelSG2:GoLine(nLineSG2)
	EndIf


	/*
	 * Este trecho do código, referente às validações com SFC e geração da SHY sempre deve
	 * ser feita no final do ModelPosVld, para garantir que o LOG do SFC seja gerado
	 * somente quando for necessário, e também por se tratar da validação mais demorada.
	*/
	If lRet .And. (oModel:GetOperation() == 4 .Or. oModel:GetOperation() == 5)  .And. lProces
		//A abertura da tela com as ordens impactadas pela alteração
		//deve ser executada sempre após validar todos os dados, pois a abertura
		//desta tela pode demorar dependendo da quantidade de ordens que existir.
		abreTelaOP(oModel)

		oModelOrd := oModel:GetModel("PCPA124_ORD")

		//Limpa os modelos do SFC da classe.
		::limpaModelosSFC(oModel)

		//Varre as ordens que devem ser integradas com o SFC ou necessitam gerar a SHY
		For nI := 1 To oModelOrd:Length()
			oModelOrd:GoLine(nI)
			If oModelOrd:GetValue("ORDSELEC") //Se o usuário marcou para processar esta OP
				oTemp := GeraSHY(oModelOrd:GetValue("ORDOP"),;
								oModel:GetValue("PCPA124_CAB","G2_PRODUTO"),;
								oModelOrd:GetValue("ORDROTEIRO"),;
								oModelOrd:GetValue("ORDQUANT"),;
								.T.,;
								oModel,;
								@oTemp,;
								oModelOrd:GetValue("ORDFIL"))

				If lIntSFC
					aAdd(::aModelosSFC,NIL) //Novo modelo para o SFC

					//Faz a carga e validação dos dados de operações para integração com o SFC.
					If !OPSFCOper(@::aModelosSFC[Len(::aModelosSFC)],;
								oModelOrd:GetValue("ORDOP"),;
								oTemp,;
								oModel:GetValue("PCPA124_CAB","G2_PRODUTO"),;
								oModelOrd:GetValue("ORDROTEIRO"),;
								oModel)
						lRet := .F.
						Exit
					EndIf

					//Faz a carga e validação dos dados de necessidades para integração com o SFC.
					If !OPSFCNece(@::aModelosSFC[Len(::aModelosSFC)],;
								oModelOrd:GetValue("ORDOP"),;
								oTemp,;
								oModel:GetValue("PCPA124_CAB","G2_PRODUTO"),;
								oModelOrd:GetValue("ORDROTEIRO"),;
								oModel)
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nI
		If lRet .And. oTemp <> Nil
			::oTempSHY := oTemp
		EndIf
		//Se ocorreu algum erro apaga o arquivo de LOG do SFC, pois ele será desconsiderado.
		If !lRet
			If lIntSFC
				//Fecha o arquivo de LOG
				FClose(_nHndSFC)
				FErase(cNameFile)
			EndIf
		Else
			//Carrega as informações do arquivo de LOG do SFC nos atributos da classe, para utilizar no fim do commit.
			::lHasErrorSFC := _lErrSFC
			If lIntSFC
				//Fecha o arquivo de LOG
				FClose(_nHndSFC)
				//Se não ocorreu nenhum erro, apaga o arquivo de log.
				If !_lErrSFC
					FErase(cNameFile)
				EndIf
			EndIf
		EndIf
	Else
		oModel:GetModel("PCPA124_ORD"):ClearData(.F.,.T.)
	EndIf

	If !lRet
		If ::oTempSHY <> Nil
			If Select(::oTempSHY:GetAlias()) > 0
				::oTempSHY:Delete()
				::oTempSHY := Nil
			EndIf
		EndIf
		//Faz a limpeza dos modelos do SFC.
		::limpaModelosSFC(oModel)
	EndIf

	RestArea(aSaveArea)
Return lRet

/*/{Protheus.doc} GridLinePreVld
Método chamado na pré validação da linha do Grid
@author Marcelo Neumann
@since 28/06/2018
@version 1.0
@return .T.
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class PCPA124EVDEF
	Local aSaveArea := GetArea()
	Local oView     := FwViewActive()
	Local lEditln	:= SuperGetMV("MV_PCPRLPP",.F., 2 )
	Local lUniLin	:= SuperGetMV("MV_UNILIN",.F.,.F.)
	Local oModelPai := oSubModel:GetModel()
	Local cProduto  := oModelPai:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")
	Local cRoteiro  := oModelPai:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")
	Local cOperac	:= oModelPai:GetModel("PCPA124_SG2"):GetValue("G2_OPERAC")
	Local cLista    := ""
	local lRet      := .T.
	Local nX        := 0
	Local nLinha    := 0
	Local lDeltAllOk := .T.
	Local oGridView

	//Verifica se está na View Principal
	If oView != NIL .And. oView:aViews != Nil .And. Len(oView:aViews) >= 2 .AND. AllTrim(oView:aViews[1][1]) != "HEADER_SG2" .and. AllTrim(oView:aViews[2][1]) != "HEADER_SG2"
		Return .T.
	EndIf

	If cModelID == "PCPA124_SGF_G" .AND. cAction == "DELETE"
		HELP(' ',1,"Help", , STR0084,; //"Operação não permitida"
		     2,0, , , , , , {STR0085}) //"Utilize o cadastro de operações por componente."
		Return .F.
	EndIf

	If oSubModel:GetOperation() == 4
		If cAction == "DELETE" .And. !oSubModel:IsInserted(nLine)
			lRet := ::ValidaDelete(cProduto, cRoteiro, cOperac)
		EndIf
	EndIf

	If lRet .And. lEditln == 1 .And. !::lExecutaPreVld .And. cModelID == "PCPA124_SG2" .And. (cAction == "DELETE" .Or. cAction == "UNDELETE") .And. !Empty(oSubModel:GetValue("G2_LISTA"))
		cLista 	:= oSubModel:GetValue("G2_LISTA")
		nLinha  := oSubModel:GetLine()

		//Quando parametrizado para replicar a lista e MV_UNILIN = .T., a Linha Produção da lista sempre deve ser igual a Linha Produção que está em tela.
		If cAction == "UNDELETE" .And. lUniLin .And. !Empty(cLista)
			If oSubModel:GetValue("G2_LINHAPR") != oModelPai:GetModel("PCPA124_CAB"):GetValue("G2_LINHAPR") .Or. ;
			   oSubModel:GetValue("G2_TPLINHA") != oModelPai:GetModel("PCPA124_CAB"):GetValue("G2_TPLINHA")
				HELP(' ',1,"Help", , STR0082,; //"Não será possível recuperar este registro. A Linha Produção/Tipo Linha das operações desta lista são diferentes da Linha Produção/Tipo Linha que está informado no roteiro."
				     2,0, , , , , , {STR0083})//"Para recuperar as operações desta lista, ajuste a Linha Produção/Tipo Linha do roteiro para possuírem a mesma informação das operações da Lista."
				lRet := .F.
			EndIf
		EndIf

		::lExecutaPreVld := .T.
		If lRet .And. cAction $ "DELETE|UNDELETE"
			For nX := 1 to oSubModel:Length()
				If cLista == oSubModel:GetValue("G2_LISTA",nX) .And. nX <> nLinha
					oSubModel:GoLine(nX)
					If cAction == "DELETE"
						If !oSubModel:DeleteLine()
							//Inserida linha abaixo para impedir execução duplicada
							HelpInDark( .T. )	//Desabilita a apresentação do Help
							lDeltAllOk := .F.
							/*Problema: "Por se tratar da tentativa de exclusão de item da Lista 'cLista', todos os itens da lista 'cLista' devem ser excluídos. A operação 'G2_OPERAC' deste roteiro não pode ser excluída."
							Solução: "Verifique o motivo da falha ao excluir diretamente a operação 'G2_OPERAC' e trate-o."*/
							Help(NIL, NIL, STR0074, NIL, StrTran(StrTran(STR0065,"cLista",cLista),"G2_OPERAC",oSubModel:GetValue("G2_OPERAC")),;
							1, 0, NIL, NIL, NIL, NIL, NIL, {StrTran(STR0066,"G2_OPERAC",oSubModel:GetValue("G2_OPERAC"))})
						EndIf
					Else
						If !oSubModel:UnDeleteLine()
							lDeltAllOk := .F.
						EndIf
					EndIf
				ElseIf  cLista == oSubModel:GetValue("G2_LISTA",nX) .And. nX == nLinha
					oSubModel:GoLine(nX)
					If cAction == "DELETE"
						If !oSubModel:DeleteLine()
							lDeltAllOk := .F.
						EndIf
						oSubModel:UnDeleteLine()
					Else
						If !oSubModel:UnDeleteLine()
							lDeltAllOk := .F.
						EndIf
						oSubModel:DeleteLine()
					EndIf
				EndIf
			Next nX
			oSubModel:GoLine(nLinha)
			If !lDeltAllOk	//DESFAZ OPERAÇÃO
				lRet	:= .F.
				For nX := 1 to oSubModel:Length()
					If cLista == oSubModel:GetValue("G2_LISTA",nX) .And. nX <> nLinha
						oSubModel:GoLine(nX)
						If cAction != "DELETE"
							oSubModel:DeleteLine()
						Else
							oSubModel:UnDeleteLine()
						EndIf
					EndIf
				Next nX
			Else
				If cAction $ "DELETE"
					If oView != Nil .AND. oView:IsActive()
						//Por se tratar da exclusão de um item da Lista 'cLista', serão excluídas todas as operações relacionadas a lista 'cLista'. - Informação
         				MsgInfo(StrTran(STR0057,"cLista",cLista),STR0071)
					EndIf
				Else
					//UNDELETE
				EndIf
			EndIf
		EndIf
		::lExecutaPreVld := .F.
		oSubModel:GoLine(nLinha)
		If oView != Nil .And. oView:IsActive()
			//oView:Refresh()
			 oGridView := oView:GetSubView("GRID_SG2")
             oGridView:DeActivate(.T.)
             oGridView:Activate()
		EndIf
	EndIf

	IF cModelID == "PCPA124_SG2" .And. lRet
		If !Empty(oSubModel:GetValue("G2_LISTA")) .And. cAction == "CANSETVALUE" .And. lEditln <> 1 .And. ( cId == "G2_OPERAC" .Or. cId == "G2_LISTA" )
			lret := .F.
		ElseIf !Empty(oSubModel:GetValue("G2_LISTA")) .And. cAction == "CANSETVALUE" .And. lEditln == 1 .And. !Empty(GetSx3Cache(CampoSG2(cId, .T.),"X3_CAMPO"))
			lret := .F.
		Else
			If cAction == "CANSETVALUE" .And. cId == "G2_LISTA"
				lret := .F.
			EndIf
		EndIf
	ElseIF cModelID == "PCPA124_SH3_R" .OR. cModelID == "PCPA124_SH3_F" .And. lRet
		If !Empty(oModelPai:GetModel("PCPA124_SG2"):GetValue("G2_LISTA")) .And. cAction == "CANSETVALUE" .And. lEditln == 1 .And. !Empty(GetSx3Cache(CampoSH3(cId, .T.),"X3_CAMPO"))
			lret := .F.
		EndIf
	EndIf

	RestArea(aSaveArea)

Return lRet

/*/{Protheus.doc} GridLinePosVld
Valida linha da grid principal da operação preenchida
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return lRet ( Continua )
/*/
METHOD GridLinePosVld(oModel, cModelId) CLASS PCPA124EVDEF
	Local cAlias    := Alias()
	Local cOperNew 	:= FwFldGet("G2_OPERAC",,oModel:GetModel())
	Local lIntSfc  	:= ExisteSFC("SG2") .And. !IsInCallStack("AUTO650")
	Local lRet     	:= .T.
	Local nOpc     	:= oModel:GetOperation()

	If !oModel:IsDeleted()
		If cModelId == "PCPA124_SG2"
			If Empty(FwFldGet("G2_TEMPAD",,oModel:GetModel()))
				Help(" ",1,"A124SEMTMP") // A124SEMTMP - Não é permitido o Cadastramento de Operação com Tempo Padrão zerado.
				lRet := .F.
			EndIf
			If lRet .And. Empty(cOperNew)
				Help(" ",1,"A124VZ") // A124VZ - Os campos Operação e Recurso não podem estar vazios.
				lRet := .F.
			EndIf
			If lRet .And. Empty(FwFldGet("G2_TEMPSOB",,oModel:GetModel()))
				If !Empty(FwFldGet("G2_TPSOBRE",,oModel:GetModel()))
					If FwFldGet("G2_TPSOBRE",,oModel:GetModel()) != "1" .Or. (FwFldGet("G2_TPSOBRE",,oModel:GetModel()) == "1" .And. SuperGetMV("MV_APS",.F.,"") == "TOTVS")
						Help(" ",1,"A124TIPSOB") // A124TIPSOB - Quando é preenchido o campo Tipo de Sobreposição, é obrigatório o preenchimento do campo Tempo de Sobreposição.
						lRet := .F.
					EndIf
				EndIf
			EndIf
			If lRet .And. Empty(FwFldGet("G2_TPSOBRE",,oModel:GetModel()))
				If !Empty( FwFldGet("G2_TEMPSOB",,oModel:GetModel()))
					Help(" ",1,"A124TMPSOB") // A124TMPSOB - Quando é preenchido o campo Tempo de Sobreposição é obrigatório o preenchimento do campo Tipo de Sobreposição.
					lRet := .F.
				EndIf
			EndIf
			If lRet .And. Empty(FwFldGet("G2_TEMPDES",,oModel:GetModel()))
				If !Empty( FwFldGet("G2_TPDESD",,oModel:GetModel()))
					Help(" ",1,"A124TIPDES") // A124TIPDES - Quando é preenchido o campo Tipo de Desdobramento, é obrigatório o preenchimento do campo Tempo de Desdobramento.
					lRet := .F.
				EndIf
			EndIf
			If lRet .And. Empty(FwFldGet("G2_TPDESD",,oModel:GetModel()))
				If !Empty( FwFldGet("G2_TEMPDES",,oModel:GetModel()))
					Help(" ",1,"A124TMPDES") // A124TMPDES - Quando é preenchido o campo Tempo de Desdobramento é obrigatório o preenchimento do campo Tipo de Desdobramento.
					lRet := .F.
				EndIf
			EndIf
			If empty(cAlias)
				dbSelectArea('SB1')
			EndIf

			If lRet .And. (TipoAps(.F.,"DRUMMER") .Or. SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. IntegraSFC()) .And. Empty(oModel:GetValue("G2_CTRAB"))
				Help(" ",1,"OBRIGAT2",,RetTitle("G2_CTRAB"),04,01) // OBRIGAT2 - Um ou alguns campos obrigatorios não foram preenchidos no objeto Grid.
				lRet := .F.
			EndIf

			If lRet .And. !Empty(FwFldGet("G2_DTINI",,oModel:GetModel())) .And. !Empty(FwFldGet("G2_DTFIM",,oModel:GetModel())) .And. FwFldGet("G2_DTINI",,oModel:GetModel()) > FwFldGet("G2_DTFIM",,oModel:GetModel())
				Help( ,, 'Help',, STR0010, 1, 0 ) //STR0010 - Data de validade inicial não pode ser maior que a data de validade final.
				lRet := .F.
			EndIf

			If lRet .And. oModel:GetValue("G2_TPLINHA") == "D"
				If !SuperGetMV("MV_UNILIN",.F.,.F.) .And. oModel:nLine # 1
					If Empty(oModel:GetValue("G2_LINHAPR",oModel:nLine - 1))
						//A124TPLIND - Quando o Campo Tipo de Linha estiver preenchido com Dependente, é obrigatório preenchimento do Campo Linha de Produção da Operação anterior.
						Help(" ",1,"A124TPLIND")
						lRet := .F.
					EndIf
				ElseIf Empty(oModel:GetValue("G2_LINHAPR"))
					//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
					Help(" ",1,"A124TPLINO")
					lRet := .F.
				EndIf
				If Empty(oModel:GetValue("G2_LINHAPR"))
					//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
					Help(" ",1,"A124TPLINO")
					lRet := .F.
				EndIf
			ElseIf lRet .And. oModel:GetValue("G2_TPLINHA") $ "OP"
				If Empty(oModel:GetValue("G2_LINHAPR"))
					//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
					Help(" ",1,"A124TPLINO")
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. !Empty(oModel:GetValue("G2_TPALOCF")) .And. Empty(oModel:GetValue("G2_FERRAM"))
				Help(" ",1,"VAZIO",,STR0017,1) //STR0017 - O campo ferramenta nao foi informado
				lRet := .F.
			EndIf

			If lRet .And. !Empty(oModel:GetValue('G2_TPOPER'))
				If !A124Tempo("M->G2_TEMPAD")
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. !Empty(oModel:GetValue('G2_SETUP'))
				If !A124Tempo("M->G2_SETUP")
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. !Empty(oModel:GetValue('G2_TEMPEND'))
				If !A124Tempo("M->G2_TEMPEND")
					lRet := .F.
				EndIf
			EndIf

			If lRet .And. lIntSfc .AND. (nOpc == 3 .OR. nOpc == 4)
				// Validar se a máquina informada pertence ao CT da operação
				If !Empty(oModel:GetValue('G2_RECURSO')) .And. !Empty(oModel:GetValue("G2_CTRAB"))
					SH1->(dbSetOrder(1))
					If SH1->(dbSeek(xFilial("SH1")+oModel:GetValue('G2_RECURSO'))) .And. AllTrim(SH1->H1_CTRAB) != AllTrim(oModel:GetValue("G2_CTRAB"))
						Help(" ",1,"A124RECCT") // A124RECCT - O recurso informado não pertence ao centro de trabalho da operação.
						lRet := .F.
					EndIf
				EndIf

				// Validar se foi informado roteiro alternativo
				If lRet .And. !Empty(oModel:GetValue("G2_ROTALT"))
					Help(" ",1,"PCPA124_SFCRTA") // PCPA124_SFCRTA - Quando integração com SIGASFC ativa, não é possivel utilizar roteiro alternativo.
					lRet := .F.
				EndIf
			Endif
		Endif
	Else
		If lRet .And. oModel:GetValue("G2_TPLINHA") != "D"
			If oModel:GetLine()+1 <= oModel:Length()
				If oModel:GetValue("G2_TPLINHA",(oModel:GetLine()+1)) == "D"
					Help( ,, 'Help',,STR0064, 1, 0 ) // STR0064 - Operações que possuam dependentes não podem ser excluídas, verifique a relação entre as operações
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} Before
No momento do commit do modelo
@author Carlos Alexandre da Silveira
@since 07/05/2018
@version 1.0
@return Nil
/*/
METHOD Before(oModel, cModelId) Class PCPA124EVDEF
	Local aAreaG2 		:= {}
	Local aRecno  		:= {}
	Local cOperOld 		:= ""
	Local cProduto 		:= oModel:GetModel():GetValue("PCPA124_CAB","G2_PRODUTO")
	Local cRoteiro 		:= oModel:GetModel():GetValue("PCPA124_CAB","G2_CODIGO")
	Local lRefer 		:= .F.
	Local nI 			:= 0
	Local nOperation	:= oModel:GetOperation()

	//Chama a função MRPIntOp, para caso a integração esteja configurada
	//para ser online, já crie a tabela temporária utilizada
	//na geração das pendências.
	If Self:lIntNewMRP .And. Self:aMRPxJson == Nil
		Self:aMRPxJson := {{}, JsonObject():New()} //{aDados para commit, JsonObject() com RECNOS} - Integracao Novo MRP
	EndIf

	//Se referência de grade, troca produto com referência
	If (nOperation == 3 .Or. nOperation == 4) .And. (lRefer := MatGrdPrrf(@cProduto,.T.) .And. AllTrim(FwFldGet("G2_PRODUTO",,oModel:GetModel())) == AllTrim(cProduto)) .And. cModelId == "PCPA124_CAB"
		oModel:LoadValue("G2_REFGRD",PadR(cProduto,TamSX3("G2_REFGRD")[1]))
		//oModel:LoadValue("G2_PRODUTO",CriaVar("G2_PRODUTO",.F.))
	EndIf

	//Faz a atualização da tabela SGF, se for necessário.
	If nOperation == 4 .And. cModelId == "PCPA124_SG2" .And. oModel:IsUpdated()
		aAreaG2 := SG2->(GetArea())
		SG2->(dbGoTo(oModel:GetDataId()))

		cOperOld := SG2->G2_OPERAC

		SGF->(dbSetOrder(1))
		IF SGF->(dbSeek(xFilial("SGF")+cProduto+cRoteiro+cOperOld))
			While SGF->(!EOF())                           .AND.;
				  SGF->GF_FILIAL  == xFilial('SGF')       .AND.;
				  SGF->GF_PRODUTO == cProduto             .AND.;
				  SGF->GF_ROTEIRO == cRoteiro             .AND.;
				  SGF->GF_OPERAC  == cOperOld

				aAdd(aRecno,SGF->(RecNo()))

				SGF->(dbSkip())
			EndDo
		EndIf

		For nI := 1 to Len(aRecno)
			SGF->(dbGoTo(aRecno[nI]))

			If Self:lIntNewMRP
				A637AddJIn(@Self:aMRPxJson, "DELETE")
			EndIf

			RecLock('SGF',.F.)
			SGF->GF_OPERAC := oModel:GetValue("G2_OPERAC")
			SGF->(MsUnLock())

			If Self:lIntNewMRP
				A637AddJIn(@Self:aMRPxJson, "INSERT")
			EndIf
		Next

		SG2->(RestArea(aAreaG2))
	EndIf
Return Nil

/*/{Protheus.doc} BeforeTTS()
No momento do commit do modelo
@author Lucas Konrad França
@since 25/06/2018
@version 1.0
@return Nil
/*/
METHOD BeforeTTS(oModel, cModelId) Class PCPA124EVDEF
	Local cProduto	 := oModel:GetModel():GetValue("PCPA124_CAB","G2_PRODUTO")
	Local cRoteiro	 := oModel:GetModel():GetValue("PCPA124_CAB","G2_CODIGO")
	Local cLinhaPr   := ""
	Local cTpLinha   := ""
	Local oModelFer  := oModel:GetModel("PCPA124_SH3_F")
	Local oModelRec  := oModel:GetModel("PCPA124_SH3_R")
	Local oModelG2   := oModel:GetModel("PCPA124_SG2")
	Local lIntegMES  := PCPIntgPPI()
	Local lUniLin    := SuperGetMV("MV_UNILIN",.F.,.F.)
	Local nI         := 0
	Local nX         := 0

	//Integração TOTVS MES para a exclusão do roteiro
	If lIntegMES .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
		If !PCPA124PPI(, AllTrim(cRoteiro)+"+"+AllTrim(cProduto), .T., .T., .T.)
			Help( ,, 'Help',, STR0041 + AllTrim(cRoteiro) + STR0042, 1, 0 ) //"Não foi possível realizar a integração com o TOTVS MES para o roteiro 'XX'. Foi gerada uma pendência de integração para este roteiro."
		EndIf
	EndIf

	//Apaga os registros que não são necessários de recursos e ferramentas alternativos.
	If oModel:GetOperation() != MODEL_OPERATION_DELETE
		For nI := 1 To oModelG2:Length()
			oModelG2:GoLine(nI)
			For nX := 1 To oModelFer:Length()
				oModelFer:GoLine(nX)
				If !oModelFer:IsDeleted() .And. Empty(oModelFer:GetValue("H3_FERRAM"))
					oModelFer:SetNoDeleteLine(.F.)
					oModelFer:DeleteLine()
				EndIf
			Next nX
			For nX := 1 To oModelRec:Length()
				oModelRec:GoLine(nX)
				If !oModelRec:IsDeleted() .And. Empty(oModelRec:GetValue("H3_RECALTE"))
					oModelRec:SetNoDeleteLine(.F.)
					oModelRec:DeleteLine()
				EndIf
			Next nX
			If lUniLin .And. !oModelG2:IsDeleted()
				//Se MV_UNILIN = .T., atualiza a Linha Produção e Tipo Linha de todas as operações.
				cLinhaPr := oModel:GetModel():GetValue("PCPA124_CAB","G2_LINHAPR")
				cTpLinha := oModel:GetModel():GetValue("PCPA124_CAB","G2_TPLINHA")
				oModelG2:LoadValue("G2_LINHAPR", cLinhaPr)
				oModelG2:LoadValue("G2_TPLINHA", cTpLinha)
			EndIf
		Next nI
	EndIf

	If ::lIntNewMRP
		::lIntNewMRP := Ma637MrpOn(@_lNewMRP)
	EndIf

Return Nil

/*/{Protheus.doc} InTTS
Método executado após as gravações do modelo, e antes de fazer o COMMIT. Utilizado para disparar integrações

@author lucas.franca
@since 21/06/2018
@version 1.0
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA124EVDEF
	Local cProduto	 := oModel:GetModel("PCPA124_CAB"):GetValue("G2_PRODUTO")
	Local cGrade	 := oModel:GetModel("PCPA124_CAB"):GetValue("G2_REFGRD")
	Local cRoteiro	 := oModel:GetModel("PCPA124_CAB"):GetValue("G2_CODIGO")
	Local cMsg       := ""
	Local nX         := 0
	Local nOperation := oModel:GetOperation()
	Local lRet       := .T.
	Local lQipMat    := IntQIP(cProduto) // Indica a Integracao com o Inspecao de Processos (SIGAQIP)
	Local lIntSFC    := ExisteSFC("SC2") .And. !IsInCallStack("AUTO650")
	Local lProces    := SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. lIntSFC .OR. SuperGetMV("MV_PCPATOR",.F.,.F.) == .T.
	Local lLite      := .F.
	Local lIntegMES  := PCPIntgPPI("SC2", @lLite)
	Local aDelQQK    := {}
	Local oModelOP   := oModel:GetModel("PCPA124_ORD")

	Private aIntegPPI := {}

	If nOperation == 4
		For nX := 1 To oModel:GetModel("PCPA124_SG2"):Length()
			oModel:GetModel("PCPA124_SG2"):GoLine(nX)
			If oModel:GetModel("PCPA124_SG2"):IsDeleted()
				AADD(aDelQQK, {oModel:GetValue("PCPA124_CAB","G2_CODIGO"), oModel:GetValue("PCPA124_SG2","G2_OPERAC")})
			EndIf
		Next nX
	EndIf

	If lQipMat .And. (nOperation == 3 .Or. nOperation == 4)
		QAtuMatQIP(cProduto,Nil,cRoteiro,"PCP",Nil,"1",Nil,aDelQQK)
	EndIf

	//Exclusao da Integracao PCP x QIP
	If lQipMat .And. nOperation == 5
		QAtuMatQIP(cProduto,,cRoteiro,"PCP",.T.)
	EndIf

	//Atualização do campo B1_OPERPAD
	If nOperation == 3 .And. SuperGetMV("MV_G2ATUB1",.F.,.F.)
		if Empty(cProduto)
			cProduto := cGrade
		Endif
		If MatGrdPrrf(@cProduto,.T.)
			cProduto := AllTrim(cProduto) //-- Remove brancos para atualizar todos os itens da referencia
		EndIf
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		While !SB1->(EOF()) .And. SB1->(B1_FILIAL+PadR(B1_COD,Len(cProduto))) == xFilial("SB1")+cProduto
			RecLock("SB1",.F.)
			SB1->B1_OPERPAD := cRoteiro
			SB1->(MsUnLock())

			SB1->(dbSkip())
		End
	EndIf

	//Integração TOTVS MES
	If lIntegMES .And. !lLite .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
		lRet := PCPA124PPI(, AllTrim(cRoteiro)+"+"+AllTrim(cProduto), .F., .T., .T.)
		If !lRet
			aSize(aIntegPPI,0)
			lRet := .T.
			Help( ,, 'Help',, STR0041 + AllTrim(cRoteiro) + STR0042, 1, 0 ) //"Não foi possível realizar a integração com o TOTVS MES para o roteiro 'XX'. Foi gerada uma pendência de integração para este roteiro."
		EndIf
	EndIf

	If lProces
		If ::oTempSHY <> Nil
			GravaSHY(@::oTempSHY)
		EndIf

		If lIntSFC
			For nX := 1 To Len(::aModelosSFC)
				OPSFCCmmMd(::aModelosSFC[nX])
				::aModelosSFC[nX] := Nil
			Next nX
			aSize(::aModelosSFC,0)
		Endif
	EndIf

	Iif(IsBlind(), atuOrdens(oModelOP, cRoteiro, lIntegMES, lRet),;
	               FwMsgRun(, {|| atuOrdens(oModelOP, cRoteiro, lIntegMES, lRet)}, STR0093, STR0094)) //"Processando" # "Atualizando ordens, aguarde..."

	//teste - atualiza campos do código do produto de tabelas relacionadas a SG2 quando for um cadastro de grade.
	a124ClProd(oModel)

	//Se ocorreram erros na integração com o PCFactory, exibe quais foram as ordens em que ocorreu erro.
	If lIntegMES .And. Len(aIntegPPI) > 0
		cMsg := STR0043 + CHR(10) //"Ocorreram erros na integração com o TOTVS MES."
		For nX := 1 To Len(aIntegPPI)
			cMsg += STR0044 + AllTrim(aIntegPPI[nX,1]) + " - " + AllTrim(aIntegPPI[nX,2]) + CHR(10) //"OP: "
		Next nX
		Help( ,, 'Help',, cMsg, 1, 0 )
	EndIf

	If lIntSFC
		If ::lHasErrorSFC
			Help( ,, 'Help',, STR0046 + ::cFileSFC + STR0047, 1, 0 ) // "Algumas das ordens geradas no SIGASFC(Chão de Fábrica) não possuem operação reportada e portanto foi trocado o parametro das ordens para reporte por operação. Um log(" ##
		EndIf
	EndIf

	//Integra as operações por componente com o MRP
	If ::lIntNewMRP
		IntegraMRP(Self:aMRPxJson, oModel:GetOperation() == MODEL_OPERATION_DELETE)
	EndIf

Return Nil

/*/{Protheus.doc} atuOrdens
Executa processo de atualização das ordens

@type  Static Function
@author lucas.franca
@since 27/11/2024
@version P12
@param 01 oModelOP , Object  , Modelo da modal de atualização de ordens
@param 02 cRoteiro , Caracter, Código do roteiro
@param 03 lIntegMES, Logic   , Indica se integra com TOTVS MES
@param 04 lIntOK   , Logic   , Indica se as integrações anteriores foram executadas corretamente
@return Nil
/*/
Static Function atuOrdens(oModelOP, cRoteiro, lIntegMES, lIntOK)
	Local cFilBkp := cFilAnt
	Local nTamOP  := TamSx3('D4_OP')[1]
	Local nX      := 0

	SC2->(dbSetOrder(1))
	For nX := 1 To oModelOP:Length()
		oModelOP:GoLine(nX)
		If oModelOP:GetValue("ORDSELEC")

			cFilAnt := oModelOP:GetValue("ORDFIL")

			If SC2->(dbSeek(xFilial("SC2")+oModelOP:GetValue("ORDOP")))
				SD4->(dbSetOrder(2))
				If SD4->(dbSeek(xFilial('SD4')+Padr(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),nTamOP)))
					While SD4->(!EOF()) .AND. SD4->D4_OP == Padr(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),nTamOP)
						SGF->(dbSetOrder(2))
						If SGF->(dbSeek(xFilial('SGF')+SC2->C2_PRODUTO+cRoteiro+SD4->D4_COD+SD4->D4_TRT))
							RecLock('SD4',.F.)
							SD4->D4_ROTEIRO := cRoteiro
							SD4->D4_OPERAC  := SGF->GF_OPERAC
							SD4->(MsUnLock())
						Else
							RecLock('SD4',.F.)
							SD4->D4_ROTEIRO := ''
							SD4->D4_OPERAC  := ''
							SD4->(MsUnLock())
						Endif

						SD4->(dbSkip())
					End
				EndIf
				//Integração PCFactory
				If lIntOK .And. lIntegMES
					mata650PPI( , , .T., .T., .F.)
				EndIf
			EndIf

			cFilAnt := cFilBkp
		EndIf
	Next nX
Return Nil

/*/{Protheus.doc} ValidaDelete
Verifica se o registro pode ser excluído
@author Carlos Alexandre da Silveira
@since 17/05/2018
@version 1.0
/*/
METHOD ValidaDelete(cProduto,cRoteiro,cOperac) CLASS PCPA124EVDEF
	Local lRet  	:= .T.
	Local aArea 	:= GetArea()
	Local cAliasQry := ""
	Local cQuery    := ""
	Local oModel	:= FWModelActive()
	Local cGrade	:= oModel:GetModel("PCPA124_CAB"):GetValue("G2_REFGRD")
	Default cOperac := ""

	//Ponto de entrada - Indica se será possível ou não excluir o processo
	If ::lMA630VLE
		lRet := ExecBlock("MA630VLE",.F.,.F.)
		If ValType(lRet) # "L"
			lRet := .T.
		EndIf

		Return lRet	//No MATA630 esse PE já estava sendo excutado dessa forma (ignorando a execução da próxima validação)
	EndIf

	//Verifica se existem Ops Abertas utilizando o Roteiro de Operacoes, com apontamentos parciais na tabela SH6.
	cQuery := "SELECT SH6.H6_OP"
	cQuery +=  " FROM " + RetSqlName("SC2") + " SC2"
	cQuery +=  " JOIN " + RetSqlName("SH6") + " SH6"
	cQuery +=    " ON SH6.H6_FILIAL  = '" + xFilial("SH6") + "'"
	cQuery += 	" AND SH6.D_E_L_E_T_ = ''"
	cQuery += 	" AND SH6.H6_OP      = SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD"
	if !Empty(cOperac)
		cQuery += " AND SH6.H6_OPERAC = '" + cOperac + "'"
	EndIf
	cQuery += " WHERE SC2.D_E_L_E_T_ = ''"
	cQuery +=   " AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"

	If !Empty(cProduto) .AND. (Empty(cGrade) .OR. (MatGrdPrrf(cProduto, .T.) .AND. AllTrim(cProduto)!=AllTrim(cGrade)))
		cQuery +=   " AND SC2.C2_PRODUTO = '" + cProduto + "'"
	Else
		MatGrdPrrf(@cGrade, .T.)
		cQuery +=   " AND SC2.C2_PRODUTO LIKE '" + cGrade + "%'"
	EndIf

	cQuery +=   " AND (SC2.C2_ROTEIRO = '" + cRoteiro + "'" + Iif(cRoteiro == "01"," OR SC2.C2_ROTEIRO = '')",")")

	cQuery +=   " AND SC2.C2_DATRF   = ''"

	cQuery		:= ChangeQuery(cQuery)
	cAliasQry	:= GetNextAlias()

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(!Eof())
		Help(,,'Help',,STR0008,1,0) //Roteiro/Operação não poderá ser excluído. Existem produções em andamento utilizando esse Roteiro/Operação.
		lRet := .F.
	EndIf

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} limpaModelosSFC
Limpa da memória todos os modelos do SFC que estiverem instanciados no array aModelosSFC.

@param oMdl124	- Modelo de dados do PCPA124, para restaurar o modelo ativo caso seja feito o Destroy dos modelos do SFC.

@author lucas.franca
@since 16/07/2018
@version 1.0
@return Nil
/*/
METHOD limpaModelosSFC(oMdl124) CLASS PCPA124EVDEF
	Local nI := 0

	For nI := 1 To Len(::aModelosSFC)
		If ::aModelosSFC[nI] <> Nil
			If ::aModelosSFC[nI]:IsActive()
				::aModelosSFC[nI]:DeActivate()
			EndIf
			::aModelosSFC[nI]:Destroy()
		EndIf
	Next nI
	aSize(::aModelosSFC,0)

	//Restaura o modelo ativo para o modelo do PCPA124
	If oMdl124 <> Nil
		FWModelActive(oMdl124)
	EndIf
Return Nil

/*/{Protheus.doc} VldRotUsado
Verifica se o roteiro poderá ser excluído, de acordo com o relacionamento com a SC2
@type  METHOD
@author lucas.franca
@since 15/01/2019
@version 12
@param cProduto, character, Código do produto
@param cRoteiro, character, Código do roteiro
@return lRet, Logical, Indica se o roteiro poderá ser excluído
/*/
METHOD VldRotUsado(cProduto, cRoteiro) CLASS PCPA124EVDEF
	Local lRet := .T.
	Local cQuery    := ""
	Local cAliasQry := "VLDSG2SC2"
	Local aArea     := GetArea()

	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
	cQuery +=  " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SC2.C2_PRODUTO = '" + cProduto + "' "
	cQuery +=    " AND SC2.C2_ROTEIRO = '" + cRoteiro + "' "
	cQuery +=    " AND NOT EXISTS ( SELECT 1 "
	cQuery +=                       " FROM " + RetSqlName("SHY") + " SHY "
	cQuery +=                      " WHERE SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery +=                        " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery +=                        " AND SHY.HY_OP      = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD ) "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	If (cAliasQry)->(TOTAL) > 0
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} abreTelaOP
Abre tela para seleção das ordens de produção que devem ser atualizadas de acordo com a alteração efetuada no roteiro.

@author lucas.franca
@since 21/06/2018
@version 1.0
@param oModel	- Modelo de dados da tela.
@return Nil
/*/
Static Function abreTelaOP(oModel)
	Local oViewModal := Nil
	Local oStruOPs   := FWFormViewStruct():New()
	Local oViewExec  := FWViewExec():New()
	Local oView      := FWViewActive()
	Local aButtons   := {}
	Local lOpen      := .T.

	If ExistBlock("M632GOPABR")
		If !ExecBlock("M632GOPABR",.F.,.F.)
			oModel:GetModel("PCPA124_ORD"):ClearData(.F.,.T.)
			Return
		Else
			lOpen := .F.
		EndIf
	EndIf

	If !buscaOrdens(oModel)
		Return
	EndIf

	If lOpen .And. !IsInCallStack("FWMILEMVC")
		A124FldOrd(@oStruOPs,.F.)

		oViewModal := FWFormView():New(oView)
		oViewModal:SetModel(oModel)
		oViewModal:SetOperation(oView:GetOperation())

		oViewModal:AddGrid("GRIDORDENS",oStruOPs,"PCPA124_ORD")
		oViewModal:AddOtherObject("VIEWLABEL", {|oPanel,oView| criaLabel(oPanel,oView:GetModel())})
		oViewModal:AddOtherObject("VIEWMARK" , {|oPanel,oView| criaMark(oPanel,oView:GetModel())})

		oViewModal:CreateHorizontalBox("BOX_LABEL",12)
		oViewModal:CreateHorizontalBox("BOX_MARK" ,5)
		oViewModal:CreateHorizontalBox("BOX_GRID" ,83)

		oViewModal:SetOwnerView('VIEWLABEL' ,'BOX_LABEL')
		oViewModal:SetOwnerView('VIEWMARK'  ,'BOX_MARK')
		oViewModal:SetOwnerView("GRIDORDENS","BOX_GRID")

		oViewModal:AddUserButton(STR0038,"",{|oView|a124Detal(oView)} ,STR0035,,,.T.) //"Detalhar"###"Detalhar ordem posicionada"
		oViewModal:AddUserButton(STR0037,"",{|oView|a124Cancel(oView)},STR0036,,,.T.) //"Cancelar"###"Cancela a operação"

		If oModel != Nil .And. oModel:isActive()
			aAdd(aButtons,{.F.,Nil}) //Copiar
			aAdd(aButtons,{.F.,Nil}) //Recortar
			aAdd(aButtons,{.F.,Nil}) //Colar
			aAdd(aButtons,{.F.,Nil}) //Calculadora
			aAdd(aButtons,{.F.,Nil}) //Spool
			aAdd(aButtons,{.F.,Nil}) //Imprimir
			aAdd(aButtons,{.T.,STR0039}) //Confirmar
			aAdd(aButtons,{.F.,STR0037}) //Cancelar
			aAdd(aButtons,{.F.,Nil}) //WalkTrhough
			aAdd(aButtons,{.F.,Nil}) //Ambiente
			aAdd(aButtons,{.F.,Nil}) //Mashup
			aAdd(aButtons,{.F.,Nil}) //Help
			aAdd(aButtons,{.F.,Nil}) //Formulário HTML
			aAdd(aButtons,{.F.,Nil}) //ECM

			oViewExec:setModel(oModel)
			oViewExec:setView(oViewModal)
			oViewExec:setTitle(STR0033) //"Ordens de produção do roteiro alterado"
			oViewExec:setOperation(oView:GetOperation())
			oViewExec:setReduction(70)
			oViewExec:setButtons(aButtons)
			oViewExec:SetCloseOnOk({|| .t.})
			oViewExec:SetCloseOnCancel({|| .t.})
			oViewExec:openView(.F.)

			If oViewExec:getButtonPress() != VIEW_BUTTON_OK
				oModel:GetModel("PCPA124_ORD"):ClearData(.F.,.T.)
			Endif
		EndIf
	EndIf

	If !IsInCallStack("FWMILEMVC")
		// ALTERAÇÃO MATEUS HENGLE - 31/07/2023
		FwViewActive(oView)
	Endif

Return Nil

/*/{Protheus.doc} filtroFil
	(long_description)
	@type  jair.colognese
	@since 05/04/2024
	@param 01 cFieldFil, Caracter, Nome do campo filial para fazer o filtro.
	@param 02 cAlias   , Caracter, Alias da tabela para realizar o xFilial.
	@return cFiltro, Caracter, Filtro de filial IN ou = para a query.
	/*/
 Static Function filtroFil()
 	Local aSC2 		:= {}
	Local aSC2Val   := {}
	Local cFiltro	:= ""
 	Local nIndex	:= 0
 	Local nTotFils  := 0

	aSC2 := FwLoadSM0()
	nTotFils := len(aSC2)

	//Inclui no array aSC2Val as filiais que o usuário tem acesso
	For nIndex := 1 To nTotFils
		If aSC2[nIndex,11]
			aAdd(aSC2Val, aSC2[nIndex,2])
		EndIf
	Next nIndex

	nTotFils := len(aSC2Val)
	If nTotFils > 1
		cFiltro := " IN ( "

		For nIndex := 1 To nTotFils
			If nIndex > 1
				cFiltro += ","
			EndIf
			cFiltro += "'" + aSC2Val[nIndex] + "'"
		Next nIndex
		cFiltro += ")"
	Else
		cFiltro := " = '" + xFilial("SC2") + "'"
	EndIf


Return cFiltro

/*/{Protheus.doc} buscaOrdens
Busca as ordens de produção que são impactadas pela alteração do roteiro.
@author lucas.franca
@since 21/06/2018
@version 1.0
@return lAchou	- Identifica se foram encontrados registros de ordens para alteração.
@param oModel	- Modelo de dados do roteiro de operações
/*/
Static Function buscaOrdens(oModel)
	Local cProduto  := oModel:GetValue("PCPA124_CAB","G2_PRODUTO")
	Local cRoteiro  := oModel:GetValue("PCPA124_CAB","G2_CODIGO")
	Local cGrade	:= oModel:GetModel("PCPA124_CAB"):GetValue("G2_REFGRD")
	Local cChavSC2  := ""
	Local cAliasQry := ""
	Local cQuery    := ""
	Local cFiltroFil:= ""
	Local lOPAberta := .F.
	Local lOPPrevis	:= .F.
	Local lAchou    := .F.
	Local lExclusao := .F.
	Local lRet      := .F.
	Local oModelOP  := oModel:GetModel("PCPA124_ORD")

	If oModel:GetOperation() == 5
		oModelOP:DeActivate()
		oModelOP:oFormModel:nOperation := 4
		oModelOP:Activate()
		lExclusao := .T.
	EndIf

	SD3->(DbSetOrder(1))
	SH6->(DbSetOrder(1))
	SB1->(dbSetOrder(1))
	SC2->(dbSetOrder(1))

	oModelOP:SetNoInsertLine(.F.)
	oModelOP:SetNoDeleteLine(.F.)

	//SG2 compartilhada e SC2 exclusiva -- Deve considerar todas filiais
	If FWModeAccess("SG2", 3) == 'C' .And. FWModeAccess("SC2", 3) == 'E'
		lRet = .T.
	Else
		lRet = .F.
	EndIf

	If lRet
 		cFiltroFil := filtroFil()
	Else
		cFiltroFil := xFilial("SC2")
	EndIf
	oModelOP:ClearData(.F.,.T.)

	//Verifica se possui OPs com situação das regras abaixo.
	cQuery := "SELECT SC2.C2_FILIAL, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_TPOP, SC2.C2_DATRF, SC2.C2_DATPRI, SC2.C2_DIASOCI, SC2.C2_PRODUTO, SC2.C2_QUANT, SC2.C2_DATPRF "
	cQuery += " FROM " + RetSqlName("SC2") + " SC2 "

	cQuery += " LEFT JOIN (SELECT H6_OP "
	cQuery += 				" FROM " + RetSqlName("SH6") + " SH6_1 "
	cQuery += 				" WHERE SH6_1.H6_FILIAL = '"+xFilial("SH6")+"' "
	cQuery +=  				" AND SH6_1.D_E_L_E_T_ = ' ') SH6 "
	cQuery += 	" ON SH6.H6_OP = SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD "

	cQuery += " LEFT JOIN (SELECT SD3_2.D3_OP, SD3_2.D3_IDENT "
	cQuery += " FROM (SELECT SD3_2.D3_OP, SD3_2.D3_IDENT "
	cQuery += 		" FROM  " + RetSqlName("SD3") + " SD3_2 "
	cQuery += 		" WHERE D_E_L_E_T_ = ' ' "
	cQuery += 			" AND SD3_2.D3_ESTORNO <> 'S' "
	cQuery += 			" AND SD3_2.D3_OP <> ' ') SD3_2 "
	cQuery += 		" LEFT JOIN  "
	cQuery += 			" (SELECT SD3_3.D3_OP, SD3_3.D3_IDENT "
	cQuery += 			" FROM  " + RetSqlName("SD3") + " SD3_3 "
	cQuery += 			" WHERE D_E_L_E_T_ = ' ' "
	cQuery += 				" AND SD3_3.D3_ESTORNO = 'S' "
	cQuery += 				" AND SD3_3.D3_OP <> ' ') SD3_3 "
	cQuery += 		" ON SD3_3.D3_OP = SD3_3.D3_OP "
	cQuery += 			" AND SD3_2.D3_IDENT = SD3_3.D3_IDENT "
	cQuery += " WHERE SD3_3.D3_IDENT IS NULL) SD3 "
	cQuery += 	" ON SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD = SD3.D3_OP AND SD3.D3_OP IS NULL "

	cQuery += " WHERE SC2.D_E_L_E_T_ = ''"

	If lRet
		cQuery += " 	AND SC2.C2_FILIAL " + cFiltroFil
	Else
		cQuery += " 	AND SC2.C2_FILIAL = '" + cFiltroFil + "' "
	EndIf

	cQuery += "		AND SH6.H6_OP IS NULL "


	If !Empty(cProduto) .AND. (Empty(cGrade) .OR. (MatGrdPrrf(cProduto, .T.) .AND. AllTrim(cProduto)!=AllTrim(cGrade)))
		cQuery +=   " AND SC2.C2_PRODUTO = '" + cProduto + "'"
	Else
		MatGrdPrrf(@cGrade, .T.)
		cQuery +=   " AND SC2.C2_PRODUTO LIKE '" + cGrade + "%'"
	EndIf

	cQuery +=   " AND (SC2.C2_ROTEIRO = '" + cRoteiro + "'" + Iif(cRoteiro == "01"," OR SC2.C2_ROTEIRO = '')",")")
	cQuery +=   " AND SC2.C2_DATRF   = ''"

	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T.)

	While (cAliasQry)->(!EOF())
		//Atribui as informações do indice na variavel
		cChavSC2 := (cAliasQry)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)

		//Verifica se a OP esta aberta
		lOPAberta	:= ((cAliasQry)->(C2_TPOP) == "F" .And. Empty((cAliasQry)->(C2_DATRF)) .And. (Max(dDataBase - SToD((cAliasQry)->(C2_DATPRI)),0) < If((cAliasQry)->(C2_DIASOCI)==0,1,(cAliasQry)->(C2_DIASOCI))))

		//Verifica se a OP esta prevista
		lOPPrevis	:= (cAliasQry)->C2_TPOP == "P"

		If lOPAberta .OR. lOPPrevis
			lAchou := .T.
			If !Empty(oModelOP:GetValue("ORDOP"))
				oModelOP:AddLine()
			EndIf
			SB1->(dbSeek(xFilial("SB1")+(cAliasQry)->C2_PRODUTO))
			oModelOP:SetValue("ORDSELEC"  , .T.)
			oModelOP:SetValue("ORDFIL"  , (cAliasQry)->C2_FILIAL)
			oModelOP:SetValue("ORDOP"     , cChavSC2)
			oModelOP:SetValue("ORDPROD"   , SB1->B1_DESC)
			oModelOP:SetValue("ORDROTEIRO", cRoteiro)
			oModelOP:SetValue("ORDENTREGA", SToD( (cAliasQry)->C2_DATPRF ))
			oModelOP:SetValue("ORDQUANT"  , (cAliasQry)->C2_QUANT)
		EndIf

		(cAliasQry)->(dbSkip())
   	End
	(cAliasQry)->(dbCloseArea())

	If lAchou
		oModelOP:GoLine(1)
	EndIf

	oModelOP:SetNoInsertLine(.T.)
	oModelOP:SetNoDeleteLine(.T.)

	If lExclusao
		oModelOP:oFormModel:nOperation := 5
	EndIf

Return lAchou

/*/{Protheus.doc} criaLabel
Monta o label para exibir a mensagem na tela de ordens para atualização.

@author lucas.franca
@since 22/06/2018
@version 1.0
@return Nil
@param oPanel	- Painel criado pelo método AddOtherObject
@param oModel	- Modelo de dados do programa.
/*/
Static Function criaLabel(oPanel,oModel)
	Local cTexto := ""
	Local oSay
	Local oFont

	oFont := TFont():New(,,,.T.,.T.)

	cTexto := STR0028 //"Este roteiro possui "
	cTexto += AllTrim(Str(oModel:GetModel("PCPA124_ORD"):Length()))
	cTexto += STR0029 //" ordens de produção com situação ''Em Aberto'' e ''Prevista'' associadas. Selecione a(s) ordem(s) de produção que deverão ser atualizadas."

	oSay := TSay():New(01,01,{||cTexto},oPanel,,oFont,,,,.T.,,,oPanel:nWidth/2,oPanel:nHeight/2)
	oSay:lWordWrap = .F.
Return

/*/{Protheus.doc} criaMark
Cria checkbox para marcar ou desmarcar todas as ordens da GRID.
@author lucas.franca
@since 25/06/2018
@version 1.0
@return Nil
@param oPanel	- Painel criado pelo método AddOtherObject
@param oModel	- Modelo de dados do programa.
/*/
Static Function criaMark(oPanel,oModel)
	Local oCheck
	Local lCheck := .T.

	oCheck := TCheckBox():New(01,01,STR0040,,oPanel,100,210,,,,,,,,.T.,,,) //'Seleciona todas as ordens'
	oCheck:bSetGet := {|| lCheck }
	oCheck:bLClicked := {|| changeOP(oModel,lCheck), lCheck:=!lCheck }
Return

/*/{Protheus.doc} changeOP
Atualiza o campo CheckBox da grid de ordens
@author lucas.franca
@since 25/06/2018
@version 1.0
@return .T.
@param oModel	- Modelo de dados do programa
@param lCheck	- Valor do check de selecionar todos
/*/
Static Function changeOP(oModel,lCheck)
	Local nX       := 0
	Local nLine    := 0
	Local oModelOP := oModel:GetModel("PCPA124_ORD")
	Local oView    := FwViewActive()

	//Guarda a linha posicionada para restaurar o valor posteriormente
	nLine := oModelOP:GetLine()

	//Atualiza o valor do checkbox da grid
	For nX := 1 To oModelOP:Length()
		oModelOP:GoLine(nX)
		oModelOP:SetValue("ORDSELEC",!lCheck)
	Next nX

	//Restaura a linha posicionada anteriormente.
	oModelOP:GoLine(nLine)
	oView:Refresh()
Return .T.

/*/{Protheus.doc} a124Cancel
Cancela a atualização de ordens afetadas pela modificação do roteiro.
@author lucas.franca
@since 25/06/2018
@version 1.0
@return .T.
@param oView	- Objeto de View da tela.
/*/
Function a124Cancel(oView)
	Local oModel := oView:GetModel()

	//Limpa os dados da tela, para não serem processados.
	oModel:GetModel("PCPA124_ORD"):ClearData(.F.,.T.)

	//Fecha a tela
	oView:CloseOwner()
Return .T.

/*/{Protheus.doc} a124Detal
Abre detalhes da ordem de produção selecionada
@author lucas.franca
@since 25/06/2018
@version 1.0
@return .T.
@param oView	- Objeto de View da tela.
/*/
Function a124Detal(oView)
	Local oModel   := oView:GetModel()
	Local oModelOP := oModel:GetModel("PCPA124_ORD")
	Local cFilBkp    := cFilAnt

	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	SC2->(dbSeek(oModelOP:GetValue("ORDFIL") + oModelOP:GetValue("ORDOP")))

	cFilAnt := oModelOP:GetValue("ORDFIL")
	ViA650b()

	cFilAnt := cFilBkp
Return .T.

/*/{Protheus.doc} CampoSG2
Conversão da nomenclatura de campos da SVH para SG2
@author brunno.costa
@since 18/10/2018
@version 6
@return cCampoSG2
@param cCampoSVH, characters, campo na SVH
@param lReverso, logic, indica conversão reversa
@type function
/*/
Static Function CampoSG2(cCampoSVH, lReverso)

	Local cCampoSG2 := ""

	Default lReverso := .F.

	cCampoSVH := AllTrim(cCampoSVH)

	If !lReverso
		Do Case
			Case cCampoSVH == "VH_CODIGO"
			cCampoSG2 := "G2_LISTA"
			Case cCampoSVH == "VH_DESCOP"
			cCampoSG2 := "G2_DESCRI"
			Case cCampoSVH == "VH_ROTEIRO"
			cCampoSG2 := "G2_CODIGO"
			Otherwise
			cCampoSG2 := Strtran(cCampoSVH,"VH_","G2_")
		EndCase
	Else
		Do Case
			Case cCampoSVH == "G2_LISTA"
			cCampoSG2 := "VH_CODIGO"
			Case cCampoSVH == "G2_DESCRI"
			cCampoSG2 := "VH_DESCOP"
			Case cCampoSVH == "G2_CODIGO"
			cCampoSG2 := "VH_ROTEIRO"
			Case cCampoSVH == "G2_ROTALT"
			cCampoSG2 := "XVH_ROTALTX"		//Não deve existir na lista pois a regra é por produto
			Otherwise
			cCampoSG2 := Strtran(cCampoSVH,"G2_","VH_")
		EndCase
	EndIf

Return cCampoSG2

/*/{Protheus.doc} CampoSH3
Conversão da nomenclatura de campos da SVH para SG2
@author brunno.costa
@since 18/10/2018
@version 6
@return cCampoSG2
@param cCampoSMY, characters, campo na SMY
@param lReverso, logic, indica conversão reversa
@type function
/*/
Static Function CampoSH3(cCampoSMY, lReverso)

	Local cCampoSH3 := ""

	Default lReverso := .F.

	cCampoSMY := AllTrim(cCampoSMY)

	If !lReverso
		cCampoSH3 := Strtran(cCampoSMY,"MY_","H3_")
	Else
		cCampoSH3 := Strtran(cCampoSMY,"H3_","MY_")
	EndIf

Return cCampoSH3

/*/{Protheus.doc} a124ClProd
Limpa G2_PRODUTO em casos de Grade
@author brunno.costa
@since 30/10/2018
@version 6
@type function
/*/
Static Function a124ClProd(oModel)
	Local oMdlPai   := oModel:GetModel("PCPA124_CAB")
	Local oMdlSG2   := oModel:GetModel("PCPA124_SG2")
	Local cRoteiro  := oMdlPai:GetValue("G2_CODIGO")
	Local cProduto  := oMdlPai:GetValue("G2_PRODUTO")
	Local cGrade    := oMdlPai:GetValue("G2_REFGRD")
	Local nIndSG2   := 1
	Local nLine		:= oMdlSG2:nLine
	Local lLock		:= .F.
	Local aAreaSG2	:= SG2->(GetArea())

	If !Empty(cProduto) .And. !Empty(cGrade)
		For nIndSG2 := 1 to oMdlSG2:Length()
			oMdlSG2:GoLine(nIndSG2)
			If oMdlSG2:GetDataID() > 0
				SG2->(DbGoTo(oMdlSG2:GetDataID()))
				lLock := SG2->(SimpleLock())
				SG2->G2_PRODUTO	:= CriaVar("G2_PRODUTO",.F.)
				iF lLock
					MsUnLock("SG2")
				EndIf
			ElseIf oMdlSG2:GetDataID() == 0
				SG2->(DbSeek(xFilial("SG2")+cProduto+cRoteiro))
				While !SG2->(Eof()) .AND. xFilial("SG2")+cProduto+cRoteiro == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)
					lLock := SG2->(SimpleLock())
					SG2->G2_PRODUTO	:= CriaVar("G2_PRODUTO",.F.)
					iF lLock
						MsUnLock("SG2")
					EndIf
					SG2->(DbSkip())
				EndDo
			EndIf
		Next nX
		oMdlSG2:GoLine(nLine)
	EndIf
	RestArea(aAreaSG2)
Return

/*/{Protheus.doc} IntegraMRP
Integra as operações por componente com o MRP

@type  Static Function
@author brunno.costa
@since 09/07/2020
@version P12.1.31
@param 01 - aMRPxJson, Array , Array com os dados para enviar
@param 02 - lDelete  , logico, indica operacao delete
@return Nil
/*/
Static Function IntegraMRP(aMRPxJson, lDelete)

	Local aAreaAtu := GetArea()

	If aMRPxJson != Nil .and. Len(aMRPxJson[1]) > 0
		MATA637INT("INSERT", aMRPxJson[1], , , , lDelete)
		aSize(aMRPxJson[1], 0)
		FreeObj(aMRPxJson[2])
		aMRPxJson[2] := JsonObject():New()
	EndIf

	RestArea(aAreaAtu)
return

/*/{Protheus.doc} geraOrdem
Gera ordem dos recursos alternativos, caso não exista.
@type  Static Function
@author Lucas Fagundes
@since 30/07/2024
@version P12
@param cRoteiro, Caracter, Código do roteiro.
@param cProduto, Caracter, Código do produto.
@return Nil
/*/
Static Function geraOrdem(cRoteiro, cProduto)
	Local aArea     := SH3->(GetArea())
	Local cOperacao := ""
	Local cSeek     := xFilial("SH3")+cProduto+cRoteiro
	Local cSeqOrdem := "00"

	SH3->(dbSetOrder(1))
	If SH3->(dbSeek(cSeek)) .And. Empty(SH3->H3_ORDEM)
		While SH3->H3_FILIAL+SH3->H3_PRODUTO+SH3->H3_CODIGO == cSeek
			If SH3->H3_OPERAC != cOperacao
				cSeqOrdem := "00"
			EndIf
			cOperacao := SH3->H3_OPERAC

			RecLock("SH3", .F.)
				cSeqOrdem := Soma1(cSeqOrdem)
				SH3->H3_ORDEM := cSeqOrdem
			SH3->(MsUnLock())

			SH3->(dbSkip())
		End
	EndIf

	RestArea(aArea)
Return Nil
