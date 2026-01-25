#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA135.CH"
#INCLUDE 'FILEIO.CH'

Static sPrefLock
Static scCRLF     := Chr(13) + Chr(10)

/*/{Protheus.doc} PCPA135EVDEF
Eventos padrões do Cadastro de Pré-Estrutura
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
/*/
CLASS PCPA135EVDEF FROM FWModelEvent

	DATA aAreaGGAnt
	DATA oRecNo
	DATA oBlqOther
	DATA lCopia
	DATA lExecutaPreValid
	DATA lExpandindo
	DATA lOperacAprovacao
	DATA lOperacCriaEstr
	DATA lValidLista
	DATA mvlOrigemPreEstrutura
	DATA mvcEstruturaOrigem
	DATA mvcRevisaoOrigem
	DATA mvcProdutoDestino
	DATA mvclCopiaTodosNiveis
	DATA mvclExcluiPreExistente
	DATA nExibeInvalidos

	METHOD New() CONSTRUCTOR
	METHOD VldActivate()
	METHOD Activate()
	METHOD DeActivate()
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
	METHOD ModelPosVld()
	METHOD InTTS()
	METHOD FieldPreVld()
	METHOD AfterTTS()

	METHOD GravaAlteracoes()
	METHOD ConverteCampos()
	METHOD PerguntaPCPA135C()
	METHOD ValPergPCPA135C()
	METHOD SetaValor()
	METHOD SolicitaNivel()
	METHOD PermiteAlterar()

	//Tratativas de lock dos registros
	METHOD Lock()
	METHOD UnLock()
	METHOD LockNew()
	METHOD UnLockNew()

ENDCLASS

METHOD New() CLASS  PCPA135EVDEF

	::aAreaGGAnt       := Nil
	::oRecNo           := JsonObject():New() //Array de controle dos bloqueios de registros da SGG
	::oBlqOther        := JsonObject():New() //Indica necessidade de recarga referente bloqueio em outra thread
	::lExecutaPreValid := .T.
	::lExpandindo      := .F.
	::lValidLista      := .F.
	::lCopia           := .F.
	::lOperacAprovacao := .F.
	::lOperacCriaEstr  := .F.

Return

/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@author Marcelo Neumann
@since 08/01/2019
@version 1.0
/*/
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS  PCPA135EVDEF

	Local lOk := .T.
	Local oModel := oSubModel:GetModel()

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		If cAction == "SETVALUE" .And. cId = "GG_COD"
			SGG->(dbSetOrder(1))
			If SGG->(dbSeek(xFilial('SGG') + xValue, .F.))
				Help( , , 'Help', , STR0180, 1, 0) //"Já existe pré-estrutura para este produto."
				lOk := .F.
			EndIf
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} VldActivate
Método executado antes da ativação do modelo
@author Marcelo Neumann
@since 08/01/2019
@version 1.0
@param oModel  , object , modelo principal
@param cModelId, logical, código do submodelo
@return lOk, logical, indica se o modelo poderá ser ativado
/*/
METHOD VldActivate(oModel, cModelId) CLASS PCPA135EVDEF

	Local cUsuario    := RetCodUsr()
	Local lReturn     := .T.
	Local lEditRepli  := FunName() == "PCPA120" .and. IsInCallStack(Upper("updEstrut"))
	Local lMvAPRESTR  := SuperGetMV("MV_APRESTR", .F., .F.)
	Local lPCPA135    := FunName() == "PCPA135"
	Local nOperation  := oModel:GetOperation()

	If oModel:GetOperation() == MODEL_OPERATION_INSERT;
	   .And. lMvAPRESTR .And. Empty(UsrGrEng(cUsuario))

		//"O acesso e a utilização desta rotina é destinada apenas aos usuários cadastrados como engenheiros."
		Help( , , 'Help', , STR0170, 1, 0)
		lReturn := .F.

	ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		lReturn := ::PermiteAlterar(oModel:GetOperation())

	EndIf

	If lReturn .AND. (lPCPA135 .OR. lEditRepli) .AND.;
		nOperation != MODEL_OPERATION_VIEW .AND.;
		nOperation != MODEL_OPERATION_INSERT

		lReturn := ::Lock(SGG->GG_COD,,,,oModel,.F.)
	Endif

Return lReturn

/*/{Protheus.doc} Activate
Método executado quando ocorrer a ativação do modelo
@author Marcelo Neumann
@since 09/11/2018
@version 1.0
@param oModel, object , modelo principal
@param lCopy , logical, indica se é uma cópia
@return Nil
/*/
METHOD Activate(oModel, lCopy) CLASS PCPA135EVDEF

	::aAreaGGAnt := SGG->(GetArea())

	Pergunte("PCPA135", .F.)

	If oModel:GetModel("FLD_MASTER"):GetValue("CEXECAUTO") == "S"
		::nExibeInvalidos := 1
	Else
		::nExibeInvalidos := mv_par01
	EndIf

Return Nil

/*/{Protheus.doc} DeActivate
Método executado quando ocorrer a desativação do modelo
@author Marcelo Neumann
@since 19/11/2018
@version 1.0
@param oModel, object , modelo principal
@return Nil
/*/
METHOD DeActivate(oModel) CLASS PCPA135EVDEF

	If ::aAreaGGAnt == Nil .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		SGG->(dbSetOrder(1))
		SGG->(dbGoTop())
	Else
		SGG->(RestArea(::aAreaGGAnt))
	EndIf

	//Remove lock's manuais
	::UnLock()

	sPrefLock := Nil

Return Nil

/*/{Protheus.doc} GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oSubModel    , Objeto  , Modelo principal
@param 02 cModelId     , Caracter, Id do submodelo
@param 03 nLine        , Numérico, Linha do grid
@param 04 cAction      , Caracter, Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param 05 cId          , Caracter, nome do campo
@param 06 xValue       , Variável, Novo valor do campo
@param 07 xCurrentValue, Variável, Valor atual do campo
@return lOK
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA135EVDEF

	Local aSaveArea  := GetArea()
	Local aAreaSGG   := SGG->(GetArea())
	Local oModel     := FwModelActive()
	Local oView      := FwViewActive()
	Local cCargoPai  := oModel:GetModel("FLD_SELECT"):GetValue("CARGO")
	Local cCargoComp := oSubModel:GetValue("CARGO")
	Local cComp      := oSubModel:GetValue("GG_COMP")
	Local cTrt       := oSubModel:GetValue("GG_TRT")
	Local cPai     	 := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local lEditln	 := SuperGetMV("MV_PCPRLEP",.F., 2 )
	Local lRunAuto   := oModel:GetModel("FLD_MASTER"):GetValue("CEXECAUTO") == "S"
	Local lComTela   := oView != Nil .And. oView:IsActive() .And. !lRunAuto
	Local nLin       := 0
	Local nX		 := 0
	Local nLinha     := 0
	Local lOK 		 := .T.
	Local lEmiteMsg	 := .F.

	If !::lExecutaPreValid
		Return lOk
	EndIf

	If ::lOperacCriaEstr .And. !IsInCallStack("WizCriacao")
		Help( ,  , 'Help', ,  STR0274,; //"Não é permitido alterar uma pré-estrutura através da opção Criar Estrutura."
			     1, 0, , , , , , {STR0275}) //"Utilize o processo padrão de alteração."
		Return .F.
	EndIf

	If cModelID == "GRID_DETAIL"
		//Bloqueia nivel de produtos
		If cAction == "DELETE" .And. !oSubModel:IsInserted()
			lOk := ::Lock(oSubModel:GetModel():GetModel("FLD_SELECT"):GetValue("GG_COD"), oView, .T., .F.)
		ElseIf cAction == "CANSETVALUE"
			lOk := ::Lock(oSubModel:GetModel():GetModel("FLD_SELECT"):GetValue("GG_COD"), oView)
		ElseIf cAction == "ADDLINE"
			lOk := ::Lock(oSubModel:GetModel():GetModel("FLD_SELECT"):GetValue("GG_COD"), oView)
		EndIf

		If lOk .AND. Empty(cPai)
			Help( ,  , 'Help', ,  STR0057,; //"Edição dos componentes não é permitida antes de informar o produto pai."
			     1, 0, , , , , , {STR0058}) //"Informe o código do produto PAI antes de informar os componentes da estrutura."
			lOK := .F.
		ElseIf lOk
			//Posiciona no produto e valida se o mesmo pode ser alterado
			SGG->(dbSetOrder(1))
			If SGG->(dbSeek(xFilial('SGG') + oModel:GetModel("FLD_SELECT"):GetValue("GG_COD"), .F.))
				If !::PermiteAlterar(oModel:GetOperation())
					lOK := .F.
					If lComTela .And. cAction <> "DELETE"
						oView:ShowLastError()
					EndIf
				EndIf
			EndIf
			SGG->(RestArea(aAreaSGG))
		EndIf

		If lOk
			//Lista de Componentes
			If lEditln == 1 .And. !::lValidLista .And. (cAction == "DELETE" .Or. cAction == "UNDELETE") .And. !Empty(oSubModel:GetValue("GG_LISTA"))
				cLista 	:= oSubModel:GetValue("GG_LISTA")
				nLinha  := oSubModel:GetLine()

				//Percorre a Grid para deletar todos os componentes pertencentes à lista do componente deletado
				::lValidLista := .T.
				For nX := 1 to oSubModel:Length()
					If cLista == oSubModel:GetValue("GG_LISTA",nX)
						oSubModel:GoLine(nX)
						If cAction == "DELETE"
							If nX <> nLinha
								lEmiteMsg := .T.
	         				EndIf
							oSubModel:DeleteLine()
						Else
							oSubModel:UnDeleteLine()
						EndIf
					EndIf
				Next nX
				oSubModel:GoLine(nLinha)
				::lValidLista := .F.

				If lComTela
					P135Refr(oView, "V_GRID_DETAIL")
			    	If lEmiteMsg
						MsgInfo(StrTran(STR0045, "cLista", AllTrim(cLista)), ; //"Por se tratar da exclusão de um item da Lista 'cLista', serão excluídas todas as operações relacionadas a lista 'cLista'"
						        STR0046)                                       //"Informação"
			    	EndIf
				EndIf
			Else
				If cAction == "DELETE"
					If !Empty(cCargoComp)
						P135DelIt(cCargoPai, cCargoComp)
					EndIf

				ElseIf cAction == "UNDELETE"
					//Se o componente já existe na Grid não permite recuperar
					If oSubModel:SeekLine({ {"GG_COMP", cComp} , {"GG_TRT", cTrt} }, .F., .T.)
						nLin := oSubModel:GetLine()
						Help( ,  , "Help", ,  STR0018 + AllTrim(cValToChar(nLin)) + ".",;  //"Esse componente já existe na linha: "
							 1, 0, , , , , , {STR0019})                                    //"Remova o componente existente para recuperar essa linha."
		 				lOK := .F.
					Else
						oSubModel:GoLine(nLine)
						lOK := P135ValCpo("GG_COMP", .T.)
					EndIf

				ElseIf cAction == "CANSETVALUE"
					If cId == "GG_COMP"
						If !Empty(oSubModel:GetValue("CARGO"))
							lOK := .F.
						EndIf
					ElseIf cId == "GG_LISTA"
						lOK := .F.
					Else
						If !Empty(oSubModel:GetValue("GG_LISTA"))
							If lEditln = 1
								If !Empty(GetSx3Cache(::ConverteCampos(cId, .T.),"X3_CAMPO"))
									lOK := .F.
								EndIf
							Else
								If cId == "GG_LISTA"
									lOK := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aSaveArea)

Return lOK

/*/{Protheus.doc} GridLinePosVld
Valida linha da grid principal da operação preenchida
@author Marcelo Neumann
@since 13/11/2018
@version 1.0
@param oSubModel, object    , modelo de dados
@param cModelId	, characters, ID do modelo de dados
@param nLine    , numeric   , linha do grid
@return lOK, logical, indica se a linha está válida
/*/
METHOD GridLinePosVld(oSubModel, cModelId, nLine) CLASS PCPA135EVDEF

	Local lOK := .T.

	If cModelId == "GRID_DETAIL" .And. oSubModel:GetOperation() != MODEL_OPERATION_DELETE
		//Bloqueia nivel de produtos
		lOK := ::Lock(oSubModel:GetModel():GetModel("FLD_SELECT"):GetValue("GG_COD"))

		//Valida as datas de validade
		If lOK .and. Empty(oSubModel:GetValue("GG_FIM")) .Or. Empty(oSubModel:GetValue("GG_INI"))
			Help( ,  , 'Help', ,  STR0060,; //"Data de validade não preenchida."
			     1, 0, , , , , , {STR0059}) //"As datas de validade inicial e final do componente são obrigatórias. Preencha estes campos."
			lOK := .F.
		EndIf

		If lOK .And. oSubModel:GetValue("GG_FIM") < oSubModel:GetValue("GG_INI")
			Help( ,  , 'Help', ,  STR0039,; //"Data final não pode ser menor que a data inicial."
			     1, 0, , , , , , {STR0061}) //"Informe uma data final que seja maior ou igual a data inicial."
			lOK := .F.
		EndIf

		//Valida grupo de opcionais e item de opcionais
		If AliasInDic("SVC") .And. lOK .And. (!Empty(oSubModel:GetValue("GG_GROPC")) .Or. !Empty(oSubModel:GetValue("GG_OPC")))
			dbSelectArea("SVC")
			dbSetOrder(1)
			If SVC->(DbSeek(xFilial("SVC")))
				Help( ,  , "Help", ,  STR0271,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
		 		1, 0, , , , , , {STR0272})  //"Para a utilização dos opcionais, não pode haver versão de produção cadastrada."
				lOK := .F.
			EndIf
		EndIf
		If lOK .And. ((!Empty(oSubModel:GetValue("GG_GROPC")) .And. Empty(oSubModel:GetValue("GG_OPC"  ))) .Or. ;
	     	 		  (!Empty(oSubModel:GetValue("GG_OPC"  )) .And. Empty(oSubModel:GetValue("GG_GROPC"))))
			Help(' ', 1, 'A202OPCOBR')
			lOK := .F.
		EndIf
	EndIf

Return lOK

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oModel  , Objeto  , Modelo principal
@param 02 cModelId, Caracter, Id do submodelo
@return lOK
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA135EVDEF

	Local lOK := .T.
	Local lAltQtde := .F.
	Local nQtdBase := oModel:GetModel("FLD_MASTER"):GetValue("NQTBASE")
	Local cProduto := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local lRunAuto := oModel:GetModel("FLD_MASTER"):GetValue("CEXECAUTO") == "S"

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	If RetFldProd(cProduto,"B1_QBP") != nQtdBase
		lAltQtde := .T. //quantidade base alterada
	EndIf

	P135GravAl(oModel)

	If (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And. !lRunAuto
		If (oModel:GetModel("GRAVA_SGG"):IsEmpty() .Or. oModel:GetModel("GRAVA_SGG"):Length(.T.) == 0) .And. ;
		   !lAltQtde .And. !::lOperacAprovacao

			Help( ,  , "Help", , STR0020, 1, 0)	//"Não existem alterações a serem salvas."
			oModel:lModify := .F.
			lOK := .F.
		EndIf
	EndIf

Return lOK

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 oModel  , Objeto  , Modelo principal
@param 02 cModelId, Caracter, Id do submodelo
@return lOK
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA135EVDEF

	Local aAreaSGG   := SGG->(GetArea())
	Local oModelGrid := oModel:GetModel("GRAVA_SGG")
	Local nOperation := 0
	Local nInd       := 0
	Local nRecno     := 0
	Local cCod       := ""
	Local cComp      := ""
	Local cTrt       := ""
	Local lOK        := .T.
	Local nQtdBase   := oModel:GetModel("FLD_MASTER"):GetValue("NQTBASE")
	Local cProduto   := oModel:GetModel("FLD_MASTER"):GetValue("GG_COD")
	Local lDadosSBZ  := RetArqProd(cProduto)
	Local lAltNivel	 := .F.

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	If RetFldProd(cProduto,"B1_QBP") != nQtdBase
		If !lDadosSBZ
			RecLock('SBZ')
			Replace SBZ->BZ_QBP With nQtdBase
			MsUnlock()
		Else
			RecLock('SB1')
			Replace SB1->B1_QBP With nQtdBase
			MsUnlock()
		EndIf
	EndIf

	SGG->(dbSetOrder(1))
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cCod  := SGG->GG_COD

		If SGG->(dbSeek(xFilial('SGG') + cCod, .F.))
			//Exclui todos os componentes do Produto Pai
			While SGG->(!Eof())                    .And. ;
			      SGG->GG_FILIAL == xFilial("SGG") .And. ;
			      SGG->GG_COD    == cCod

				::GravaAlteracoes(MODEL_OPERATION_DELETE, oModelGrid)

				SGG->(DbSkip())
			End
			lAltNivel := .T.
		EndIf
	Else
		If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
			For nInd := 1 To oModelGrid:Length()
				If oModelGrid:IsDeleted(nInd)
					Loop
				EndIf

				//Proteção para não gravar um registro que tenha ficado inválido
				If Empty(oModelGrid:GetValue("GG_COD")) .Or. Empty(oModelGrid:GetValue("GG_COMP"))
					Loop
				EndIf

				oModelGrid:GoLine(nInd)

				//Posiciona no registro
				nRecno := oModelGrid:GetValue("NREG")
				If nRecno > 0
					SGG->(dbGoTo(nRecno))
				Else
					cCod   := oModelGrid:GetValue("GG_COD")
					cComp  := oModelGrid:GetValue("GG_COMP")
					cTrt   := oModelGrid:GetValue("GG_TRT")
					SGG->(dbSetOrder(1))
					SGG->(dbSeek(xFilial('SGG') + cCod + cComp + cTrt))
				EndIf

				If !SGG->(Eof())
					//Se o registro existe e foi excluído, ativa o modelo na operação DELETE
					If oModelGrid:GetValue("DELETE")
						nOperation := MODEL_OPERATION_DELETE
						lAltNivel := .T.
					Else
						nOperation := MODEL_OPERATION_UPDATE
					EndIf
				Else
					//Se o registro não está na base e está deletado na Grid, desconsidera
					If oModelGrid:GetValue("DELETE")
						Loop
					EndIf

					//Se o registro não existe, cria um novo
					nOperation := MODEL_OPERATION_INSERT
					lAltNivel := .T.
				EndIf

				::GravaAlteracoes(nOperation, oModelGrid)

			Next nInd
		EndIf
	EndIf

	If lAltNivel
		PutMV('MV_NIVALTP','S')
	EndIf

	SGG->(RestArea(aAreaSGG))

Return lOK

/*/{Protheus.doc} GravaAlteracoes
Método para efetivar a gravação dos dados na tabela SGG
@author Marcelo Neumann
@since 05/11/2018
@version 1.0
@param 01 nOperation, Numérico, Indica a operação
@param 02 oModelGrid, Objeto  , Modelo principal
@return lOK
/*/
METHOD GravaAlteracoes(nOperation, oModelGrid) CLASS PCPA135EVDEF

	Local aAreaGG   := SGG->(GetArea())
	Local oModel    := FWLoadModel("PCPA135Grv")
	Local oModelGrv := oModel:GetModel("MODEL_COMMIT")
	Local nIndCps   := 0
	Local aFields   := oModelGrid:oFormModelStruct:aFields
	Local lOK       := .T.

	oModel:SetOperation(nOperation)
	oModel:Activate()

	If nOperation == MODEL_OPERATION_INSERT
		oModelGrv:LoadValue("GG_COD", oModelGrid:GetValue("GG_COD"))
	EndIf

	If nOperation != MODEL_OPERATION_DELETE
		//Carrega os campos do modelo
		For nIndCps := 1 to Len(aFields)
			If oModelGrv:oFormModelStruct:HasField(aFields[nIndCps][3])
				oModelGrv:LoadValue(aFields[nIndCps][3], oModelGrid:GetValue(aFields[nIndCps][3]))
			EndIf
		Next nIndCps

		oModelGrv:LoadValue("GG_STATUS", oModelGrid:GetValue("CSTATUS"))
	Else
		SGN->(dbSeek(xFilial("SGN")+"SGG"+SGG->GG_COD))
		While !SGN->(EOF()) .And. SGN->GN_NUM == SGG->GG_COD
			RecLock("SGN",.F.)
			SGN->(dbDelete())
			SGN->(MsUnLock())
			SGN->(dbSkip())
		End
	EndIf

	lOK := FWFormCommit(oModel)
	oModel:DeActivate()
	SGG->(RestArea(aAreaGG))



Return lOK

/*/{Protheus.doc} ConverteCampos
Método que faz a conversão da nomenclatura de campos entre SVG e SGG
@author Carlos Alexandre da Silveira
@since 19/11/2018
@version 1.0
@param 01 cCampoSVG, Caracter, campo a ser convertido
@param 02 lReverso, Lógico, indica se a reversão será inversa (da SGG para a SVG)
@return cCampoSGG, Caracter, campo covertido
/*/
METHOD ConverteCampos(cCampoSVG, lReverso) CLASS PCPA135EVDEF

	Local cCampoSGG  := ""
	Default lReverso := .F.

	cCampoSVG := AllTrim(cCampoSVG)

	If !lReverso
		Do Case
			Case cCampoSVG == "VG_COD"
				cCampoSGG := "GG_LISTA"
			Otherwise
				cCampoSGG := Strtran(cCampoSVG,"VG_","GG_")
		EndCase
	Else
		Do Case
			Case cCampoSVG == "GG_LISTA"
				cCampoSGG := "VG_COD"
			Otherwise
				cCampoSGG := Strtran(cCampoSVG,"GG_","VG_")
		EndCase
	EndIf

Return cCampoSGG

/*/{Protheus.doc} ::PerguntaPCPA135C
Chama pergunte PCPA135C e converte em propriedades
@author brunno.costa
@since 14/12/2018
@version 1.0
@param lExibe, lógico, indica se exibe o pergunte em tela
@return Nil
/*/
METHOD PerguntaPCPA135C(lExibe, lRecursiva) CLASS PCPA135EVDEF
	Local lReturn
	Local aOpcoes      := {}
	Local nInd         := 1
	Local lParamBox    := .T.
	Default lExibe     := .F.
	Default lRecursiva := .F.

	If !lParamBox
		lReturn := Pergunte('PCPA135C', lExibe)
	Else
		//Cria Array aOpcoes padrão
		For nInd := 1 to 6
			aAdd(aOpcoes, Array(9))
		Next nInd

		//Corrige Inicializadores Padrão de GET
		aOpcoes[2][3] := SGG->GG_COD	//Preenche o Produto Origem Selecionado no Browse
		aOpcoes[3][3] := Space(GetSx3Cache("G1_REVINI","X3_TAMANHO"))
		aOpcoes[4][3] := Space(GetSx3Cache("G1_COD"   ,"X3_TAMANHO"))

		//Altera F3 da Pergunta (Pré) Estrutura Origem
		aOpcoes[2][6] := "SB1PCP"

		//Altera F3 da Pergunta Revisão da Estrutura Origem
		aOpcoes[3][6] := "SG5"

		//Altera F3 da Pergunta Produto Destino
		aOpcoes[4][6] := "SB1"

		//Ajuste das Pictures dos GET's
		aOpcoes[2][4] := GetSx3Cache("G1_COD"   	,"X3_PICTURE")
		aOpcoes[3][4] := GetSx3Cache("G21_REVINI"   ,"X3_PICTURE")
		aOpcoes[4][4] := GetSx3Cache("G1_COD"   	,"X3_PICTURE")

		//Alteração do Conteúdo dos Combos para Utilização de STR
		aOpcoes[1][4] := {STR0100, STR0101}//{'Pré-Estrutura','Estrutura'}
		aOpcoes[6][4] := {STR0102, STR0103}//{'Exclui Componentes Existentes','Mantém Componentes Existentes'}

		//Altera Modo de Edição dos Perguntes Específicos de Estrutura
		aOpcoes[3][7] := "Iif(ValType(MV_PAR01)=='C',MV_PAR01 == '"+STR0101+"',MV_PAR01 == 2)" //Estrutura
		aOpcoes[5][8] := "Iif(ValType(MV_PAR01)=='C',MV_PAR01 == '"+STR0101+"',MV_PAR01 == 2)" //Estrutura
		aOpcoes[6][8] := "Iif(ValType(MV_PAR01)=='C',MV_PAR01 == '"+STR0101+"',MV_PAR01 == 2)" //Estrutura

		Private cCadastro := STR0001    //"Cadastro de Pré-Estrutura"
		lReturn := PCPCnvPerg('PCPA135C', lExibe, aOpcoes, lRecursiva)
	EndIf

	If lReturn
		::mvlOrigemPreEstrutura  := MV_PAR01 == 1
		::mvcEstruturaOrigem     := MV_PAR02
		::mvcRevisaoOrigem       := MV_PAR03
		::mvcProdutoDestino      := MV_PAR04
		::mvclCopiaTodosNiveis   := MV_PAR05 == 1
		::mvclExcluiPreExistente := MV_PAR06 == 1
		lReturn := ::ValPergPCPA135C()
		If !lReturn
			lReturn := ::PerguntaPCPA135C(lExibe, .T.)
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} ValPergPCPA135C
Valida respostas da pergunta PCPA135C
@author brunno.costa
@since 14/12/2018
@version 1.0
@return Nil
/*/
METHOD ValPergPCPA135C() CLASS PCPA135EVDEF

	Local aAreaAnt := GetArea()
	Local aAreaSB1
	Local aAreaSGG
	Local lReturn := .T.
	Local cQuery
	Local cBanco  := TCGetDB()

	DbSelectArea("SGG")
	DbSelectArea("SG1")

	If Empty(::mvcEstruturaOrigem)
		Help(NIL, NIL, "Help", NIL, STR0104, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0105}) //"Estrutura origem em branco." -"Preencha o código do produto da estrutura origem."
		lReturn := .F.
	ElseIf Empty(::mvcProdutoDestino)
		Help(NIL, NIL, "Help", NIL, STR0106, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0107}) //"Produto destino em branco." - "Preencha o código do produto destino."
		lReturn := .F.
	Else
		aAreaSB1   := SB1->(GetArea())
		aAreaSGG   := SGG->(GetArea())

		SB1->(dbSetOrder(1))
		SGG->(DbSetOrder(2))
		If !SB1->(dbSeek(xFilial('SB1') + ::mvcEstruturaOrigem))
			Help(NIL, NIL, "Help", NIL, STR0108, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0109}) //"Código do produto origem inexistente." - "Utilize um código de produto válido."
			lReturn := .F.

		ElseIf !SB1->(dbSeek(xFilial('SB1') + ::mvcProdutoDestino))
			Help(NIL, NIL, "Help", NIL, STR0110, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0109}) //"Código do produto destino inexistente." - "Utilize um código de produto válido."
			lReturn := .F.

		ElseIf ::mvlOrigemPreEstrutura
			SGG->(DbSetOrder(1))
			If !SGG->(DbSeek(xFilial("SGG") + ::mvcEstruturaOrigem))
				Help(NIL, NIL, "Help", NIL, STR0111, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0112}) //"Pré-estrutura origem inexistente." - "Utilize um código de produto de pré-estrutura válido."
				lReturn := .F.
			EndIf

		ElseIf !::mvlOrigemPreEstrutura
			IF "MSSQL" $ cBanco
				cQuery :=  " SELECT TOP 1 G1_COD "
			Else
				cQuery :=  " SELECT G1_COD "
			EndIf
			cQuery +=  " FROM " + RetSqlName("SG1")
			cQuery +=  " WHERE D_E_L_E_T_=' ' "
			cQuery +=        " AND G1_FILIAL ='" + xFilial("SG1") + "' "
			cQuery +=        " AND G1_COD ='" + ::mvcEstruturaOrigem + "' "
			cQuery +=        " AND G1_REVINI <= '" + ::mvcRevisaoOrigem + "' "
			cQuery +=        " AND G1_REVFIM >= '" + ::mvcRevisaoOrigem + "' "
			IF "ORACLE" $ cBanco
				cQuery +=        " AND ROWNUM = 1 "
			ElseIF "POSTGRES" $ cBanco
				cQuery +=        " ORDER BY 1 LIMIT 1 "
			EndIf
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SG1PAI",.F.,.F.)
			If SG1PAI->(Eof())
				Help(NIL, NIL, "Help", NIL, STR0113, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0114}) //"Estrutura origem inexistente." - "Utilize código de produto de estrutura e revisão válidos."
				lReturn := .F.
			EndIf
			SG1PAI->(DbCloseArea())
		EndIf

		If lReturn
			SGG->(DbSetOrder(1))
			If SGG->(DbSeek(xFilial("SGG") + ::mvcProdutoDestino))
				Help(NIL, NIL, "Help", NIL, STR0115, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0116}) //"Já existe pré-estrutura para este produto destino." - "Exclua a pré-estrutura existente ou utilize outro produto destino."
				lReturn := .F.
			EndIf
		EndIf

		If lReturn
			//Verifica se o produto original não contem o produto destino em sua Pre-estrutura.
			If PCPExisCmp(::mvlOrigemPreEstrutura, ::mvcEstruturaOrigem, ::mvcProdutoDestino, ::mvcRevisaoOrigem)
				Help(NIL, NIL, "Help", NIL, STR0117, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0118}) //"A estrutura origem é inválida pois possui o produto destino como componente." - "Utilize uma estrutura origem válida."
				lReturn := .F.
			EndIf
		EndIf

		//Restaura Area de trabalho.
		RestArea(aAreaSGG)
		RestArea(aAreaSB1)
		RestArea(aAreaAnt)
	EndIf

Return lReturn

/*/{Protheus.doc} SetaValor
Verifica se é possível setar o valor em um campo do modelo, e executa o SetValue

@author ricardo.prandi
@since 26/12/2018
@version P12
@param oSubModel, object   , Submodelo que irá receber o valor
@param cField   , character, ID do field que irá receber o valor
@param xValue   , any      , Valor que será atribuído ao campo.
@return lRet    , logical  , True caso o valor tenha sido atribuído corretamente ao campo.
/*/
METHOD SetaValor(oSubModel, cField, xValue) CLASS PCPA135EVDEF
	Local lRet := .T.

	If oSubModel:CanSetValue(cField)
		If !oSubModel:SetValue(cField,xValue)
			lRet := .F.
		EndIf
	Else
		If oSubModel:GetModel():HasErrorMessage()
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} SolicitaNivel
Abre a tela solicitando o nível de aprovação (1o nível ou todos os níveis)
@author Marcelo Neumann
@since 08/01/2019
@version 1.0
@return cNivelApro, characters, indica o nível selecionoado:
                                '0' - A tela foi cancelada
								'1' - Primeiro nível
								'2' - Todos os nívels
/*/
METHOD SolicitaNivel() CLASS PCPA135EVDEF

	Local aBackVar   := Array(2)
	Local cNivelApro := '1'
	Local aOpcoes    := {"1=" + STR0136, ; //"Primeiro nível"
	                     "2=" + STR0137}   //"Todos os níveis"
	Local lRet       := .F.

	DEFINE MSDIALOG oDlg FROM 000,000 TO 150,400 TITLE STR0139 PIXEL  //"Nível de Aprovação"

	TComboBox():New(45,                                          ; //(01) Coordenada vertical
	                30,                                          ; //(02) Coordenada horizontal
	                {|u|if(PCount()>0,cNivelApro:=u,cNivelApro)},; //(03) Bloco de código que atualiza a variável
	                aOpcoes,                                     ; //(04) Lista de itens que serão apresentados - "Primeiro nível","Todos os níveis"
	                80,                                          ; //(05) Largura do objeto
	                15,                                          ; //(06) Altura do objeto
	                oDlg,,,,,,.T.,                               ; //(13) Coordenadas passadas em pixels
					,,,,,,,,'cNivelApro',                        ; //(22) Nome da variável
					STR0138)                                       //(23) Label - "Escolha uma opção: "

	//Variáveis INCLUI e ALTERA definidas como .F. para a função EnchoiceBar criar os botões com as descrições Confirmar/Cancelar
	aBackVar[1] := Iif(Type("INCLUI")=="L",INCLUI,Nil)
	aBackVar[2] := Iif(Type("ALTERA")=="L",ALTERA,Nil)
	INCLUI := .F.
	ALTERA := .F.
	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {||(lRet:=.T.,oDlg:End())}, {||(lRet:=.F.,oDlg:End())}, , , , , .F., .F., .F., .T., .F.)
	INCLUI := aBackVar[1]
	ALTERA := aBackVar[2]

	If !lRet
		cNivelApro := '0'
	EndIf

Return cNivelApro



/*/{Protheus.doc} AfterTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após a transação.
@author douglas.heydt
@since 11032019
@version 1.0
@param 01 oModel  , Objeto  , Modelo principal
@param 02 cModelId, Caracter, Id do submodelo
/*/
METHOD AfterTTS(oModel, cModelId) CLASS PCPA135EVDEF

	Local cOP := oModel:GetOperation()

	//-----------------------------------------------------
	// Executa Ponto de Entrada após a Gravacao da Pre-Estrutura
	//-----------------------------------------------------
	If (cOP == MODEL_OPERATION_INSERT .Or. cOp == MODEL_OPERATION_UPDATE .Or. cOp == MODEL_OPERATION_DELETE) ;
												.And.  !::lOperacAprovacao .And. !::lOperacCriaEstr
		If ExistBlock('A202GrvE')
			Execblock('A202GrvE',.F.,.F.)
		EndIf
	EndIf

	//Remove lock's manuais
	::UnLock()

Return


/*/{Protheus.doc} Lock
Bloqueia os componentes de determinado nivel da PRE-estrutura com base no produto Pai
@author brunno.costa
@since 12/04/2019
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto
@param 02 - oView     , objeto  , objeto da view
@param 03 - lHelp     , logico  , indica se informa ou nao o help
@param 04 - lForcaHelp, logico  , forca exibicao de help, executa HelpInDark(.F.) - Necessario pois GridLinePreVld, cAction = "CANSETVALUE", nao exibe Help
@param 05 - oModel    , objeto  , objeto da model
@param 06 - lReload   , logico  , indica se deve recarregar a grid/tree caso o registro tenha sido liberado
@return lReturn - indica se conseguiu bloquear todos os componentes deste pai
/*/
METHOD Lock(cProduto, oView, lHelp, lForcaHelp, oModel, lReload) CLASS PCPA135EVDEF

	Local aAreaSGG    := SGG->(GetArea())
	Local lReturn     := .T.
	Local cFunName    := FunName()
	Local lPCPA135    := cFunName == "PCPA135"
	Local lPCPA120    := cFunName == "PCPA120"
	Local lEditRepli  := lPCPA120 .and. IsInCallStack(Upper("updEstrut"))
	Local lReplicando := IsInCallStack(Upper("ReplicarEstrutura"))

	Default oView     := FwViewActive()
	Default lHelp     := Iif(lPCPA135 .OR. lPCPA120 .OR. lReplicando, .T., .F.)
	Default lReload   := Iif(lReplicando, .F., .T.)

	//Ajustes durante replica da lista de componentes
	lHelp       := Iif(lPCPA120 .and. !lReplicando, .F., lHelp)
	lForcaHelp  := Iif(lForcaHelp == Nil, oView <> Nil .And. oView:IsActive() .And. lHelp .AND. (!lReplicando .OR. lEditRepli), lForcaHelp)

	If ::oRecNo[cProduto] == Nil
		::oRecNo[cProduto] := {.F., {}}
	EndIf

	If lForcaHelp                                               //Habilita a apresentacao do Help
		HelpInDark(.F.)
	EndIf

	If !::oRecNo[cProduto][1]			                        //Se nao esta bloqueado por esta Thread
		SGG->(dbSetOrder(1))
		If SGG->(dbSeek(xFilial("SGG")+cProduto))               //Produtos COM estrutura na SGG - SimpleLock
			While !SGG->(Eof());
			       .And. SGG->GG_FILIAL == xFilial("SGG");
			       .And. SGG->GG_COD    == cProduto

				If SGG->(SimpleLock())                          //Bloqueou registro atual da SGG
					aAdd(::oRecNo[cProduto][2], SGG->(RecNo()))
					::oRecNo[cProduto][1] := .T.

				Else                                            //NAO Bloqueou registro atual da SGG
					lReturn               := .F.
					::oBlqOther[cProduto] := StrTokArr(TCInternal(53),"|")
					If lHelp
						//Esta estrutura 'X' está bloqueada para o usuário: Y
						Help( ,  , "Help", ,  STR0256 + AllTrim(cProduto) + STR0257 + ::oBlqOther[cProduto][1] + scCRLF + scCRLF + " [" + ::oBlqOther[cProduto][2] + "]";
						    , 1, 0, , , , , , {STR0258})	//"Entre em contato com o usuário ou tente novamente."
					EndIf
					Exit
				EndIf
				SGG->(DbSkip())
			EndDo

		ElseIf !Empty(cProduto)                                  //Produtos SEM estrutura na SGG - LockByName
			lReturn := ::LockNew(cProduto)
			If lHelp .AND. !lReturn
				//Esta estrutura 'X' está bloqueada para o usuário: Y
				Help( ,  , "Help", ,  STR0256 + AllTrim(cProduto) + STR0257 + ::oBlqOther[cProduto][1] + scCRLF + scCRLF + " [" + ::oBlqOther[cProduto][2] + "]";
					, 1, 0, , , , , , {STR0258})	//"Entre em contato com o usuário ou tente novamente."
			EndIf

		EndIf
	EndIf

	If lReturn .AND. ::oBlqOther[cProduto] != Nil                //Avalia necessidade de Refresh da Grid
		If lHelp
			If lReload
				lReturn    := .F.
				//Houve bloqueio da estrutura 'X' pelo usuário: Y
				Help( ,  , "Help", ,  STR0259 + AllTrim(cProduto) + STR0260 + ::oBlqOther[cProduto][1] + " [" + ::oBlqOther[cProduto][2] + "]" + scCRLF + scCRLF + STR0270 ,; //"A estrutura será atualizada automaticamente."
					1, 0, , , , , , {STR0261})	//"Tente novamente."
				P135Reload()
			EndIf
			::oBlqOther[cProduto] := Nil
		EndIf
	EndIf

	If !lReturn                                                  //Remove lock's realizados
		::UnLock(cProduto)
    	::oRecNo[cProduto][1] := .F.

	EndIf

	If lForcaHelp                                                //Desabilita a apresentacao do Help
		HelpInDark(.T.)
		oView:GetModel():GetErrorMessage(.T.)                    //Limpa help do modelo

	ElseIf !lHelp .AND. oView != Nil .AND. oView:HasError()
		oView:GetModel():GetErrorMessage(.T.)                    //Limpa help do modelo

	ElseIf oView == Nil
		If oModel == Nil
			oModel := FwModelActive()
		EndIf
		If oModel != Nil
			oModel:GetErrorMessage(.T.)
		EndIf

	EndIf

	RestArea(aAreaSGG)
Return lReturn

/*/{Protheus.doc} UnLock
Libera os Recnos de componentes bloqueados
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto   , caracter, codigo do produto pai
@param 02 - lProtegeSGG, logico  , indica se deve realizar protecao de alias da SGG
/*/
METHOD UnLock(cProduto, lProtegeSGG) CLASS PCPA135EVDEF

	Local aAreaSGG
	Local aLocksPai
	Local nIndRec       := 0
	Local nIndPai       := 0

	Default cProduto    := ""
	Default lProtegeSGG := .T.

	If lProtegeSGG
		aAreaSGG      := SGG->(GetArea())
	EndIf

	SGG->(DbSetOrder(1))
	If Empty(cProduto)
		aLocksPai   := ::oRecno:GetNames()
		For nIndPai := 1 to Len(aLocksPai)                       //Loop pais alterados
			If !Empty(aLocksPai[nIndPai])
				::UnLock(aLocksPai[nIndPai], .F.)
			EndIf
		Next

	Else
		If ::oRecno != Nil .and. ::oRecno[cProduto] != Nil .and. ::oRecno[cProduto][1] //Se esta bloqueado por esta Thread
			//Produtos SEM estrutura na SGG - LockByName
			If !Empty(cProduto)
				lReturn := ::UnLockNew(cProduto)
			EndIf

			//Produtos COM estrutura na SGG - SimpleLock
			For nIndRec := 1 to Len(::oRecno[cProduto][2])   //Loop componentes do pai
				SGG->(dbGoTo(::oRecno[cProduto][2][nIndRec]))
				SGG->(MsUnLock())
			Next
			aSize(::oRecno[cProduto][2], 0)
			::oRecno[cProduto][1] := .F.
		EndIf

	EndIf

	If lProtegeSGG
		RestArea(aAreaSGG)
	EndIf

Return

/*/{Protheus.doc} SGGUnLockR
Desbloqueia registros da SGG - Por Recno
@author brunno.costa
@since 11/04/2019
@version 1.0
@param 01 - nRecno  , numerico, recno a ser liberado, caso em branco, libera todos do objeto oRecNo
@param 02 - lProtege, logico  , indica se realiza protecao do alias SG1
@param 03 - oRecno  , objeto  , objeto Json com os recnos bloqueados
/*/
Function SGGUnLockR(nRecno, lProtege, oRecNo)
	Local aArea
	Local aAreaSGG
	Local nInd
	Local aLocks

	Default lProtege := .T.

	If lProtege
		aArea      := GetArea()
		aAreaSGG   := SGG->(GetArea())
	EndIf

	If nRecno == Nil
		oRecNo := Iif(oRecNo == Nil, JsonObject():New(), oRecNo)
		aLocks   := oRecNo:GetNames()
		For nInd := 1 to Len(aLocks)
			If oRecNo[aLocks[nInd]]						//Se RECNO flagado
				SGGUnLockR(Val(aLocks[nInd]), .F.)
			EndIf
		Next

	ElseIf nRecno > 0
		SGG->(dbGoTo(nRecno))
		SGG->(MsUnLock())

	EndIf

	If lProtege
		RestArea(aAreaSGG)
		RestArea(aArea)
	EndIf
Return

/*/{Protheus.doc} LockNew
Cria LockByName + TXT para bloquear inclusao de novas estruturas de produtos ou intermediarios
(Inexistem registros anteriores na SGG)
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto , caracter, codigo do produto
@return lReturn - indica se conseguiu bloquear
/*/
METHOD LockNew(cProduto) CLASS PCPA135EVDEF
	Local cFileName
	Local lReturn   := .T.
	Local nHandle
	Local cMsgError := ""

	sPrefLock := Iif(sPrefLock == Nil, "\SEMAFORO\" + FWGrpCompany() + FWCodEmp() + FWCodFil() + "_PCPA135_PRD_" , sPrefLock)
	cFileName := Lower(sPrefLock + AllTrim(FwNoAccent(PCPCarEsp(cProduto))))

	If LockByName(cFileName, .F., .F., .T.)									//Conseguiu bloquear
		If File(cFileName + ".tmp", 0 ,.T.)
			If fErase(cFileName + ".tmp") == -1
				//"Falha na exclusao do arquivo '"
				Help( ,  , "Help", ,  STR0262 + cFileName + ".tmp'. (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0263}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
			Endif
		EndIf
		nHandle := fCreate(cFileName + ".tmp", FC_NORMAL)
		If nHandle == -1
			//"Falha na criação do arquivo '\RootPath\Semaforo\"
				Help( ,  , "Help", ,  STR0264 + cFileName + ".tmp': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0263}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
			lReturn := .F.

		Else
			fWrite(nHandle, UsrRetName(RetCodUsr())  + "| " + FunName() + " - LockByName - ThreadID(" + cValToChar(ThreadID()) + ") (" + GetServerIP() + ":" + GetPvProfString( "TCP", "Port", "1234","appserver.ini") + ")")
			If fError() # 0
				//"Falha na escrita do arquivo '\RootPath\Semaforo\"
				Help( ,  , "Help", ,  STR0265 + cFileName + ".tmp': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0263}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
			EndIf
			::oRecNo[cProduto][1] := .T.

		EndIf
		fClose(nHandle)

	Else																	//NAO Conseguiu bloquear
		lReturn :=.F.
		nHandle := fOpen(cFileName + ".tmp")
		fRead( nHandle, @cMsgError, 100 )
		If !Empty(cMsgError)
			::oBlqOther[cProduto] := StrTokArr(cMsgError,"|")
			If Empty(::oBlqOther[cProduto])
				::oBlqOther[cProduto] := Nil
			EndIf
		EndIf
		fClose(nHandle)
	EndIf

Return lReturn

/*/{Protheus.doc} UnLockNew
Elimina LockByName + TXT para liberar inclusao de novas estruturas de produtos ou intermediarios
(Inexistem registros anteriores na SGG)
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto, caracter, codigo do produto
/*/
METHOD UnLockNew(cProduto) CLASS PCPA135EVDEF
	Local cFileName

	sPrefLock := Iif(sPrefLock == Nil, "\SEMAFORO\" + FWGrpCompany() + FWCodEmp() + FWCodFil() + "_PCPA135_PRD_" , sPrefLock)
	cFileName := Lower(sPrefLock + AllTrim(FwNoAccent(PCPCarEsp(cProduto))))

	If ::oRecNo[cProduto][1]											//Ha bloqueio realizado por esta Thread
		UnLockByName(cFileName, .F., .F., .T.)
		If File(cFileName + ".tmp", 0 ,.T.)
			If fErase(cFileName + ".tmp") != -1
				::oRecNo[cProduto][1] := .F.
			Else
				//"Falha na exclusao do arquivo '"
				Help( ,  , "Help", ,  STR0262 + cFileName + ".tmp'. (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0263}) //"Contate o departamento de TI e verifique as configurações de acesso ao diretório '\RootPath\SEMAFORO\.'"
			Endif
		Endif
	EndIf

Return

/*/{Protheus.doc} PermiteAlterar
Verifica se a pré-estrutura posicionada no alias SGG pode ser alterada
@author marcelo.neumann
@since 24/04/2019
@version 1.0
@param 01 - nOperacao, numeric, indica a operação que está sendo usada
/*/
METHOD PermiteAlterar(nOperacao) CLASS PCPA135EVDEF

	Local cUsuario   := RetCodUsr()
	Local lCriaEstru := SubStr(cAcesso, 132, 1) == "S"
	Local lAprova    := SubStr(cAcesso, 131, 1) == "S"
	Local lMvAPRESTR := SuperGetMV("MV_APRESTR", .F., .F.)

	//Se utiliza alçada de aprovação para a pré-estrutura, valida o usuário
	If lMvAPRESTR
		If Empty(UsrGrEng(cUsuario))
			Help( , , 'Help', , STR0170, 1, 0) //"O acesso e a utilização desta rotina é destinada apenas aos usuários cadastrados como engenheiros."
			Return .F.
		ElseIf !(GrpEng(cUsuario, SGG->GG_USUARIO))
			Help( , , 'Help', , STR0171, 1, 0) //"A realização desta ação é restrita aos usuários de um grupo de engenharia específico."
			Return .F.
		EndIf
	EndIf

	//Se a operação for Criar Estrutura
	If ::lOperacCriaEstr
		If !lCriaEstru
			Help( , , "Help", , STR0172, 1, 0) //"Usuário sem permissão para criar estruturas."
			Return .F.
		EndIf

		If lMvAPRESTR
			If SGG->GG_STATUS <> '2'
				Help( ,  , "Help", ,  STR0173, ; //"Pré-estrutura não aprovada."
					1, 0, , , , , , {STR0174} ) //"Aprove a pré-estrutura para criar uma estrutura."
				Return .F.
			EndIf
		EndIf

	//Se a operação for Aprovar, Rejeitar ou Enc.Aprovação
	ElseIf ::lOperacAprovacao
		If !lMvAPRESTR
			If !lAprova
				Help( ,  , "Help", , STR0175 , 1, 0) //"Usuario não pode aprovar ou rejeitar pré-estruturas."
				Return .F.
			EndIf
		EndIf

	//Demais operações
	Else
		If SGG->GG_STATUS == '5' .And. nOperacao <> MODEL_OPERATION_DELETE
			Help( , , 'Help', , STR0255, 1, 0) //"Pré-estruturas em aprovação não podem ser alteradas."
			Return .F.
		EndIf

		If !lMvAPRESTR
			If SGG->GG_STATUS <> '1' .And. nOperacao <> MODEL_OPERATION_DELETE
				Help( ,  , "Help", ,  STR0178, ; //"Pré-estrutura não está em criação."
						1, 0, , , , , , {STR0179})  //"Crie uma pré-estrutura similar ou inclua uma nova pré-estrutura."
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PCPCARESP
Função para validar caracteres especiais.
@author Eder Luciano
@since 02/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static function PCPCarEsp(cTexto)

	DEFAULT cTexto := ""

		aEsp := {'*','!','?','<','>',':','\','/','|','"'}
		Aeval(aEsp,{|c| cTexto := StrTran(cTexto,c,'')})

Return(cTexto)
