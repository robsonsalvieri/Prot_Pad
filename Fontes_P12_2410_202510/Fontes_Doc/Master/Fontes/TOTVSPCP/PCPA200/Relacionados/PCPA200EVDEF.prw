#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA200.CH"
#INCLUDE 'FILEIO.CH'

#DEFINE INT_SFC "SFC"
#DEFINE INT_MES "MES"

Static lPCPREVTAB := FindFunction('PCPREVTAB')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
Static lPCPREVATU := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
Static lSOWInDic  := AliasInDic("SOW")
Static sPrefLock
Static scCRLF     := Chr(13) + Chr(10)
Static slP200PRD  := ExistBlock("PA200PRD")

/*/{Protheus.doc} PCPA200EVDEF
Eventos padrões da manutenção de estruturas

@author Lucas Konrad França
@since 05/11/2018
@version P12.1.17
/*/
CLASS PCPA200EVDEF FROM FWModelEvent

	DATA aAreaG1Ant
	DATA aRecnos
	DATA aRevAtualizadas
	DATA aRevisoes 					//{lNovo, Revisão Atual, Data Revisão, cProduto}	
	DATA cRevisaoMaster
	DATA lCopia
	DATA lExecutaPreValid
	DATA lExpandindo
	DATA lGeraRevisao
	DATA lIntegraMRP
	DATA lIntegraOnline
	DATA lIntegraProdutoOnLine
	DATA lIntgPPI
	DATA lIntgSFC
	DATA lModeloAuxiliar
	DATA lMostrandoTodos
	DATA lRefresh
	DATA lValidLista
	DATA mvcEstruturaOrigem
	DATA mvcProdutoDestino
	DATA mvcRevisaoOrigem
	DATA mvcRevProdDestino
	DATA mvlArquivoRevisao
	DATA mvlDataRevisao
	DATA mvlRevisaoAutomatica
	DATA mvlRevisaoPIManual
	DATA mvlSubstituiNaOP
	DATA nExibeInvalidos
	DATA oBlqOther
	DATA oDadosCommit
	DATA oPaiIntegrado
	DATA oRecNo

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD DeActivate()
	METHOD VldActivate()
	METHOD FieldPreVld()
	METHOD GridLinePreVld()
	METHOD GridLinePosVld()
	METHOD ModelPosVld()
	METHOD AfterTTS()
	METHOD InTTS()
	METHOD TriggerVld()

	METHOD AtualizaRevisao()
	METHOD AtualizaPIsRevisao()
	METHOD AvlCampoRevisao()
	METHOD ConverteCampos()
	METHOD DeletaHistoricoRevisoes()
	METHOD GravaAlteracoes()
	METHOD PerguntaPCPA200()
	METHOD PergPCPA200C()
	METHOD SetaValor()
	METHOD SetGeraRevisao()
	METHOD TratMsgErr()
	METHOD ValidaTrt()
	METHOD ValPergPCPA200C()

	//Tratativas de lock dos registros
	METHOD Lock()
	METHOD UnLock()
	METHOD LockNew()
	METHOD UnLockNew()

ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe.

@author Lucas Konrad França
@since 05/11/2018
@version P12.1.17
/*/
METHOD New() CLASS PCPA200EVDEF
	//Reinicializa as variáveis Static do PCPA200.
	//P200IniStc()

	::aAreaG1Ant           	        := Nil
	::oRecNo                        := JsonObject():New() //Array de controle dos bloqueios de registros da SG1
	::oBlqOther                     := JsonObject():New() //Indica necessidade de recarga referente bloqueio em outra thread	
	::lCopia                        := .F.
	::lExecutaPreValid              := .T.
	::lExpandindo                   := .F.
	::lMostrandoTodos               := .F.
	::lGeraRevisao         	        := .T.
	::lValidLista                   := .F.
	::lModeloAuxiliar               := .F.
	::lRefresh						:= .F.
	::mvlRevisaoAutomatica 	        := SuperGetMv("MV_REVAUT",.F.,.F.) //Revisão Automática
	::mvlRevisaoPIManual   	        := SuperGetMv("MV_ALTREV",.F.,.F.) //Revisão para todos os PI's
	::aRevisoes            	        := {}
	::aRevAtualizadas				:= {}
	::cRevisaoMaster       	        := ""
	::oDadosCommit                  := JsonObject():New()
	::oDadosCommit["oLinDel"]       := JsonObject():New()
	::oDadosCommit["oLines"]        := JsonObject():New()
	::oDadosCommit["oQLinAlt"]      := JsonObject():New()
	::oDadosCommit["oProdutos"]     := JsonObject():New()
	::oDadosCommit["oRecnos"]       := JsonObject():New()
	::oDadosCommit["oErros"]        := JsonObject():New()

	::lIntegraMRP            := .F.
	::lIntegraOnline         := .F.
	::lIntegraProdutoOnLine  := .F.

	::lIntgSFC               := IntegraSFC()
	::lIntgPPI               := PCPIntgPPI()
	::oPaiIntegrado          := JsonObject():New()
	::oPaiIntegrado[INT_SFC] := JsonObject():New()
	::oPaiIntegrado[INT_MES] := JsonObject():New()

	If FindFunction("IntNewMRP")
		::lIntegraMRP := IntNewMRP("MRPPRODUCT", @::lIntegraProdutoOnLine)
		::lIntegraMRP := IntNewMRP("MRPBILLOFMATERIAL", @::lIntegraOnline)
	EndIf

	::PerguntaPCPA200(.F.)
Return Nil

/*/{Protheus.doc} Activate
Método executado quando ocorrer a ativação do modelo.

@author Lucas Konrad França
@since 09/11/2018
@version P12.1.17

@param oModel	- Modelo principal.
@param lCopy	- Indica se é uma cópia.
@return Nil.
/*/
METHOD Activate(oModel,lCopy) CLASS PCPA200EVDEF
	::aAreaG1Ant := SG1->(GetArea())

	::PerguntaPCPA200(.F.)

	If oModel:GetModel("SG1_MASTER"):GetValue("CEXECAUTO") == "S"
		::nExibeInvalidos := 1
	Else
		::nExibeInvalidos := MV_PAR04
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		If Empty(oModel:GetModel("SG1_MASTER"):GetValue("CREVABERTA"))
			oModel:GetModel("SG1_MASTER"):LoadValue("CREVABERTA",oModel:GetModel("SG1_MASTER"):GetValue("CREVPAI"))
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} DeActivate
Método executado quando ocorrer a desativação do modelo.

@author Lucas Konrad França
@since 19/11/2018
@version P12.1.17

@param oModel	- Modelo principal.
@return Nil.
/*/
METHOD DeActivate(oModel) CLASS PCPA200EVDEF
	If ::aAreaG1Ant == Nil .Or. oModel:GetOperation() == MODEL_OPERATION_DELETE
		SG1->(dbSetOrder(1))
		SG1->(dbGoTop())
	Else
		SG1->(RestArea(::aAreaG1Ant))
	EndIf

	aSize(::aRevisoes,0)

	//Remove lock's manuais
	::UnLock()

	sPrefLock := Nil

	::cRevisaoMaster := ""

	If ValType(::oPaiIntegrado) != "U"
		FreeObj(::oPaiIntegrado[INT_MES])
		FreeObj(::oPaiIntegrado[INT_SFC])
		FreeObj(::oPaiIntegrado)
	EndIf

	P200Atalho(.F.)
Return Nil

/*/{Protheus.doc} FieldPreVld
Pré-validação dos modelos

@author Lucas Konrad França
@since 14/11/2018
@version 1.0

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param cAction		- Ação executada no field, podendo ser: SETVALUE, CANSETVALUE
@param cId			- Nome do campo
@param xValue		- Novo valor do campo
@return lRet		- Indica se o field está válido
/*/
METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS PCPA200EVDEF
	Local lRet := .T.

	If cModelID == "SG1_MASTER" .And. cId == "CEXECAUTO" .And. cAction == "SETVALUE" .And. xValue == "S"
		//Quando é execução automática, sempre carrega os componentes vencidos no modelo.
		::nExibeInvalidos := 1
	EndIf
Return lRet

/*/{Protheus.doc} GridLinePreVld
Pré-validação dos modelos

@author Lucas Konrad França
@since 14/11/2018
@version 1.0

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param nLine		- Linha do grid
@param cAction		- Ação que está sendo realizada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId			- Nome do campo
@param xValue		- Novo valor do campo
@param xCurrentValue- Valor atual do campo
@return lRet		- Indica se a linha está válida
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS PCPA200EVDEF
	Local lRet     := .T.
	Local oView    := FwViewActive()

	If ::lExecutaPreValid;
	   .AND. (FunName() != "PCPA200" .Or. !IsIncallStack("ButtonOkAction") .OR. IsIncallStack("ConfirmLis"))
		lRet := GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue, Self)
	EndIf

	If cModelID == "SG1_DETAIL" .And. cAction == "CANSETVALUE"
		If P200AltPai(.F.) != .F.
			IF oView != Nil .And. oView:IsActive() .And. !(oSubModel:GetModel():GetModel("SG1_MASTER"):GetValue("CEXECAUTO") == "S")
	   	    	oView:Refresh("SG1_MASTER")
			EndIf
		EndIf	
	EndIF

Return lRet

/*/{Protheus.doc} TriggerVld
Verifica se o campo tem gatilho ou não

@author Fábio Boarini
@since 11/06/2024
@version 1.0

@param oModel - Modelo de dados
@param cCampo - Campo a ser verificado
@return lRet  - Retorna .T. se o campo tiver gatilho
/*/
METHOD TriggerVld(oModel,cCampo) CLASS PCPA200EVDEF
	Local oModelGrid := oModel:GetModel("SG1_DETAIL")
	Local aGatilho   := oModelGrid:GetStruct():GetTriggers()
	Local lRet		 := .T.

	If aScan(aGatilho,{|x| x[2] == cCampo}) == 0
		lRet := .F.
	Endif
Return lRet

/*/{Protheus.doc} GridLinePreVld
Pré-validação dos modelos

@author brunno.costa
@since 14/05/2019
@version 1.0

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param nLine		- Linha do grid
@param cAction		- Ação que está sendo realizada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId			- Nome do campo
@param xValue		- Novo valor do campo
@param xCurrentValue- Valor atual do campo
@param oEvent       - Instancia da classe EVDEF
@return lRet		- Indica se a linha está válida
/*/
Static Function GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue, oEvent)
	Local cCargoPai   	:= ""
	Local cComp       	:= ""
	Local cCompon       := ""
	Local cProdMaster
	Local cProdPai    	:= ""
	Local cTrt        	:= ""
	Local nScan
	Local nOldLine
	Local nInd
	Local nLin          := 0
	Local lEditln       := SuperGetMV("MV_PCPRLEP",.F., 2)
	Local lEmiteMsg     := .F.
	Local lRet        	:= .T.
	Local lRevAtu       := .T. 
	Local nX            := 0
	Local nY            := 0
	Local nLinha        := 0
	Local oModel
	Local oView         := FwViewActive()

	If cModelID == "SG1_DETAIL"
		//Bloqueia nivel de produtos
		cProduto := fAjustaStr(oSubModel:GetModel():GetModel("SG1_COMPON"):GetValue("G1_COD"))
		If cAction == "DELETE" .And. !oSubModel:IsInserted()
			lRet := oEvent:Lock(cProduto, oView, .T., .F.)
		ElseIf cAction == "CANSETVALUE"
			lRet := oEvent:Lock(cProduto, oView)
		ElseIf cAction == "ADDLINE"
			lRet := oEvent:Lock(cProduto, oView)
		EndIf

		If lRet .AND. Empty(oSubModel:GetModel():GetModel("SG1_MASTER"):GetValue("G1_COD"))
			Help(,,'Help',,STR0040,; //"Edição dos componentes não é permitida antes de informar o produto pai."
			     1,0,,,,,,{STR0041}) //"Informe o código do produto PAI antes de informar os componentes da estrutura."
			lRet := .F.
		ElseIf lRet
			//Lista de Componentes
			If lEditln == 1 .And. !oEvent:lValidLista .And. (cAction == "DELETE" .Or. cAction == "UNDELETE") .And. !Empty(oSubModel:GetValue("G1_LISTA"))
				cLista 	:= oSubModel:GetValue("G1_LISTA")
				nLinha  := oSubModel:GetLine()

		 		If cAction == "UNDELETE"
					// Percorre os itens que serão recuperados
					nQtdGrid := oSubModel:Length(.F.)
					For nY := 1 To nQtdGrid
						If cLista <> oSubModel:GetValue("G1_LISTA",nY)
						  	Loop
						EndIf
					  	If oSubModel:SeekLine({ {"G1_COMP",oSubModel:GetValue("G1_COMP",nY)},{"G1_TRT",oSubModel:GetValue("G1_TRT", nY)} }, .F., .F. )
					  		If !Empty(oSubModel:GetValue("G1_COMP"))
					  			If !Empty(cCompon)
					  				cCompon += ", "
					  			EndIf
					  			//If !oSubModel:IsDeleted(nY)
					  			If Empty(oSubModel:GetValue("G1_TRT", nY))
					  				cCompon += AllTrim(oSubModel:GetValue("G1_COMP", nY))
					  			Else
					  				cCompon += AllTrim(oSubModel:GetValue("G1_COMP", nY)) + " - " + AllTrim(oSubModel:GetValue("G1_TRT", nY))
					  			EndIf
						  		//EndIf
					  			lRet := .F.
					  		EndIf
					 	EndIf
					Next nY

					If lRet = .F.
						Help( , , "Help", , STR0120 + " (" + AllTrim(cCompon) + ")", 1, 0) //"Este componente já está cadastrado na estrutura."
					EndIf
				EndIf

				If lRet
					//Percorre a Grid para deletar todos os componentes pertencentes à lista do componente deletado
					oEvent:lValidLista := .T.
					For nX := 1 to oSubModel:Length()
						If cLista == oSubModel:GetValue("G1_LISTA",nX)
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
					oEvent:lValidLista := .F.

					If oView != Nil .And. oView:IsActive() .And. FunName() == "PCPA200"
						oGridView := oView:GetSubView("VIEW_COMPONENTES")
			        	oGridView:DeActivate(.T.)
				    	oGridView:Activate()
				    	If lEmiteMsg
							MsgInfo(StrTran(STR0126, "cLista", AllTrim(cLista)), ; //"Por se tratar da exclusão de um item da Lista 'cLista', serão excluídos todos os componentes relacionados a lista 'cLista'"
									STR0127)                                       //"Informação"
				    	EndIf
					EndIf
				EndIf
			Else
				If cAction == "DELETE"
					If !Empty(oSubModel:GetValue("CARGO"))
						//Recupera o cargo PAI
						cCargoPai := oSubModel:GetModel():GetModel("SG1_COMPON"):GetValue("CARGO")
						P200DelIt(cCargoPai,oSubModel:GetValue("CARGO"))
					EndIf
				ElseIf cAction == "UNDELETE"
					cComp := oSubModel:GetValue("G1_COMP")
					cTrt  := oSubModel:GetValue("G1_TRT")
					//Se o componente já existe na Grid não permite recuperar
					If oSubModel:SeekLine({ {"G1_COMP", cComp} , {"G1_TRT", cTrt} }, .F., .T.)
						If !oEvent:ValidaTrt(oSubModel, oSubModel:GetModel():GetModel("SG1_COMPON"):GetValue("G1_COD"), cComp, cTrt)
							nLin := oSubModel:GetLine()
							Help(,,"Help",,STR0033 + cValToChar(nLin) + ".",; //"Esse componente já existe na linha: "
								1,0,,,,,,{STR0034})                          //"Remova o componente existente para recuperar essa linha."
							lRet := .F.
						EndIf
					Else
						oSubModel:GoLine(nLine)
						lRet := P200ValCpo("G1_COMP", .T.)
					EndIf
				ElseIf cAction == "CANSETVALUE"
					If cId == "G1_COMP"
						If !Empty(oSubModel:GetValue("CARGO"))
							lRet := .F.
						EndIf
					ElseIf cId <> "G1_LISTA"
						If !Empty(oSubModel:GetValue("G1_LISTA"))
							If lEditln = 1
								If !Empty(GetSx3Cache(oEvent:ConverteCampos(cId, .T.),"X3_CAMPO"))
									lRet := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf cAction == "SETVALUE" .AND. cId == "G1_TRT"
					cComp := oSubModel:GetValue("G1_COMP")
					cTrt  := xValue
					lRet := oEvent:ValidaTrt(oSubModel, oSubModel:GetModel():GetModel("SG1_COMPON"):GetValue("G1_COD"), cComp, cTrt)
				EndIf
			EndIf
		EndIf

		If lRet .And. cAction == 'CANSETVALUE'
			If cId $ "G1_REVINI|G1_REVFIM" .And. oEvent:mvlRevisaoAutomatica
				lRet := .F. //Não permite alterar os campos de revisão quando MV_REVAUT = T
			EndIf
		EndIf

		If lRet .and. cAction $ "SETVALUE|DELETE"
			oModel      := oSubModel:GetModel()
			cProdMaster := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
			oModelGrid  := oModel:GetModel("SG1_DETAIL")
			cProdPai    := oModel:GetModel("SG1_COMPON"):GetValue("G1_COD")

			//Revisão Automática
			If (oEvent:mvlRevisaoAutomatica);
				.AND. ((cAction == "DELETE" .AND. !Empty(oModelGrid:GetValue("G1_COMP")));
				.OR. oModelGrid:GetValue("NREG") == 0;
			    .OR. oEvent:AvlCampoRevisao(oModelGrid:GetValue("NREG"), cId, xValue))

				//Avalia Próxima Revisão
				nScan := aScan(oEvent:aRevisoes, {|x| x[4] == cProdPai .AND. x[1] })
				If nScan == 0
					//Avalia a próxima Revisão - Sem tela
					cRevisao := oEvent:AtualizaRevisao( cProdPai, .F., .F.,,oModel)

					//Atualiza Revisão do Produto Master e Selecionado
					If cProdPai == cProdMaster
						oModel:GetModel("SG1_MASTER"):LoadValue("CREVPAI", cRevisao)
					EndIf
					oModel:GetModel("SG1_COMPON"):LoadValue("CREVCOMP", cRevisao)

				Else
					cRevisao := oEvent:aRevisoes[nScan,2]

				EndIf
 				
				lRevAtu := aScan(oEvent:aRevAtualizadas,{|x| x == cProdPai}) == 0

				If oModelGrid:GetValue("G1_REVINI") != cRevisao .or. IsInCallStack("ConfirmLis")

					//Atualiza Revisão do Componente Atual 
					oModelGrid:LoadValue("G1_REVINI", cRevisao)
					oModelGrid:LoadValue("G1_REVFIM", cRevisao)

					//Atualiza Revisão dos Outros Componentes
					If lRevAtu
						nOldLine    := oModelGrid:GetLine()
						For nInd := 1  to oModelGrid:Length(.F.)
							oModelGrid:GoLine(nInd)
							If (Val(cRevisao) - Val(oModelGrid:GetValue("G1_REVFIM"))) > 1
								oModelGrid:LoadValue("G1_REVINI", cRevisao)
							EndIf
								oModelGrid:LoadValue("G1_REVFIM", cRevisao)
						Next nInd
						oModelGrid:GoLine(nOldLine)			
					EndIf
				EndIf

				If cId == "G1_COMP" .And. !Empty(xValue) .And. cAction == "SETVALUE"
					lRet := ExistCpo("SB1",xValue,1)
					If lRet .And. slP200PRD
						lRet := ExecBlock("PA200PRD", .F., .F., {cProdPai, xValue})
					Endif
				EndIf	

				If lRet .And. lRevAtu .And. !oEvent:lModeloAuxiliar 
					//Refresh da Grid - VIEW_COMPONENTES
					oView := FwViewActive()
					If oView != Nil .AND. oView:oModel:cID == "PCPA200" .And. !IsInCallStack("ListaComp")
						//If nOldLine != Nil .AND. nOldLine > 1000
							//Forca refresh devido bug da solucao abaixo em alguns computadores - Issue DFRM1-17268
							//Ira posicionar na ultima linha e sera exibida apenas ela na Grid logo apos o cabecalho
							oView:GetSubView("VIEW_COMPONENTES"):Refresh()
							aAdd(oEvent:aRevAtualizadas, cProdPai)
							//oView:GetSubView("VIEW_COMPONENTES"):DeActivate(.T.)
							//oView:GetSubView("VIEW_COMPONENTES"):Activate()
						/*Else
							//Solucao alternativa para refresh sem desposicionar
							oView:GetSubView("VIEW_COMPONENTES"):DeActivate(.T.)
							oView:GetSubView("VIEW_COMPONENTES"):Activate()							
							aAdd(oEvent:aRevAtualizadas, cProdPai)
							oEvent:lRefresh := .T.
						EndIf*/
					EndIf
					FwViewActive(oView)						
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} GridLinePosVld
Valida linha da grid principal da operação preenchida

@author Lucas Konrad França
@since 13/11/2018
@version 1.0

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param nLine		- Linha do grid
@return lRet		- Indica se a linha está válida
/*/
METHOD GridLinePosVld(oSubModel, cModelId, nLine) CLASS PCPA200EVDEF

	Local lRet  := .T.

	If !IsIncallStack("P200GRAVAL");
	   .AND. (!IsIncallStack("ButtonOkAction") .OR. IsIncallStack("ConfirmLis"));
	   .AND. !IsIncallStack("RecupAlter");
	   .AND. !IsIncallStack("P200TreeCh")      //Inibe execucao de validacao desnecessaria (duplicada)
		lRet := GridLinePosVld(oSubModel, cModelId, nLine, Self)
	EndIf

Return lRet

/*/{Protheus.doc} GridLinePosVld
Valida linha da grid principal da operação preenchida

@author brunno.costa
@since 14/05/2019
@version 1.0

@param oSubModel	- Modelo de dados
@param cModelId		- ID do modelo de dados
@param nLine		- Linha do grid
@param oEvent		- Instancia da classe EVDEF
@return lRet		- Indica se a linha está válida
/*/
Static Function GridLinePosVld(oSubModel, cModelId, nLine, oEvent)

	Local aAreaB1  := SB1->(GetArea())
	Local aAreaG1  := SG1->(GetArea())
	Local oMdlPai  := oSubModel:GetModel()
	Local cCodigo  := oMdlPai:GetModel("SG1_COMPON"):GetValue("G1_COD")
	Local cRevisao := ""
	Local cSeqInc
	Local lRet     := .T.
	Local nScan

	If cModelId == "SG1_DETAIL" .And. oSubModel:GetOperation() != MODEL_OPERATION_DELETE
		//Bloqueia nivel de produtos
		
		lRet := oEvent:Lock(fAjustaStr(oSubModel:GetModel():GetModel("SG1_COMPON"):GetValue("G1_COD")))

		//Valida as datas de validade
		If lRet .and. Empty(oSubModel:GetValue("G1_FIM")) .Or. Empty(oSubModel:GetValue("G1_INI"))
			Help(,,'Help',,STR0038,; //"Data final não pode ser menor que a data inicial."
				1,0,,,,,,{STR0039}) //"As datas de validade inicial e final do componente são obrigatórias. Preencha estes campos."
			lRet := .F.
		EndIf
		If lRet .And. oSubModel:GetValue("G1_FIM") < oSubModel:GetValue("G1_INI")
			Help(,,'Help',,STR0028,; //"Data final não pode ser menor que a data inicial."
				1,0,,,,,,{STR0029}) //"Informe uma data final que seja maior ou igual a data inicial."
			lRet := .F.
		EndIf

		//Valida grupo de opcionais e item de opcionais
		If lRet .And. (!Empty(oSubModel:GetValue("G1_GROPC")) .Or. !Empty(oSubModel:GetValue("G1_OPC")))
		 	If AliasInDic("SVC")
				SVC->(dbSetOrder(1))
				If SVC->(DbSeek(xFilial("SVC")))
					Help( ,  , "Help", ,  STR0210,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
					1, 0, , , , , , {STR0211})  //"Para a utilização dos opcionais, não pode haver versão de produção cadastrada."
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If lRet .And. ((!Empty(oSubModel:GetValue("G1_GROPC")) .And. Empty(oSubModel:GetValue("G1_OPC"  ))) .Or. ;
	     	 		  (!Empty(oSubModel:GetValue("G1_OPC"  )) .And. Empty(oSubModel:GetValue("G1_GROPC"))))
			Help(' ', 1, 'A200OPCOBR')
			lRet := .F.
		EndIf

		//Valida a revisão
		If lRet .And. oSubModel:GetOperation() == MODEL_OPERATION_UPDATE
			//Busca a revisão do PAI direto.
			If cCodigo == oMdlPai:GetModel("SG1_MASTER"):GetValue("G1_COD")
				cRevisao := oMdlPai:GetModel("SG1_MASTER"):GetValue("CREVPAI")
			Else
				nScan := aScan(oEvent:aRevisoes, {|x| x[4] == cCodigo .AND. x[1] })
				If nScan == 0
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial('SB1') + cCodigo, .F.))
						cRevisao := IIf(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
					EndIf
				Else
					cRevisao := oEvent:aRevisoes[nScan,2]
				EndIf
			EndIf

			If !oEvent:mvlRevisaoAutomatica
				If oSubModel:GetValue("G1_REVINI") > oSubModel:GetValue("G1_REVFIM")
					Help( ,  , 'Help', ,  STR0163,; //"Revisão Final não pode ser menor que a revisão Inicial."
						1, 0, , , , , , {STR0036}) //"Verifique a revisão inicial e final do componente."
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lRet
			If !oEvent:ValidaTrt(oSubModel, cCodigo, oSubModel:GetValue("G1_COMP"), oSubModel:GetValue("G1_TRT"))
				lRet := .F.
			EndIf
		EndIf

		//Ajusta Sequência com Base em Registro do Banco - Evita chave duplicada
		If lRet //.And. Empty(oSubModel:GetValue("G1_LISTA"))
			cSeqInc := oSubModel:GetValue("G1_TRT")
			DbSelectArea("SG1")
			SG1->(DbSetOrder(1))	//G1_FILIAL+G1_COD+G1_COMP+G1_TRT
			SG1->(DbSeek(xFilial("SG1")+cCodigo+oSubModel:GetValue("G1_COMP")+oSubModel:GetValue("G1_TRT")))
			While !SG1->(Eof()) .AND. SG1->G1_FILIAL     == xFilial("SG1");
				.AND. SG1->G1_COD     == cCodigo;
				.AND. SG1->G1_COMP    == oSubModel:GetValue("G1_COMP")

				//SX2_UNIQ = G1_FILIAL+G1_COD+G1_COMP+G1_TRT+DTOS(G1_INI)+DTOS(G1_FIM)+G1_REVINI+G1_REVFIM
				If SG1->G1_FILIAL     == xFilial("SG1");
				.AND. SG1->G1_COD     == cCodigo;
				.AND. SG1->G1_COMP    == oSubModel:GetValue("G1_COMP");
				.AND. SG1->G1_TRT     == cSeqInc;
				.AND. SG1->G1_REVINI  == oSubModel:GetValue("G1_REVINI");
				.AND. SG1->G1_REVFIM  == oSubModel:GetValue("G1_REVFIM");
				.AND. SG1->(Recno())  != oSubModel:GetValue("NREG")

				//Desconsidera Validades - Comportamento Padrão MATA200
				//.AND. SG1->G1_INI     == oSubModel:GetValue("G1_INI");
				//.AND. SG1->G1_FIM     == oSubModel:GetValue("G1_FIM");

					If (Empty(SG1->G1_TRT) .AND. Empty(cSeqInc));
						.OR. (!Empty(SG1->G1_TRT) .AND. SG1->G1_TRT >= cSeqInc)

						cSeqInc := SG1->G1_TRT
						If Empty(cSeqInc)
							cSeqInc := StrZero(1,Len(cSeqInc))
						Else
							cSeqInc := Soma1(cSeqInc)
						EndIf
						oSubModel:LoadValue("G1_TRT",cSeqInc)
						SG1->(DbSeek(xFilial("SG1")+cCodigo+oSubModel:GetValue("G1_COMP")+cSeqInc))
					Else
						SG1->(DbSkip())
					EndIf
				Else
					SG1->(DbSkip())
				EndIf
			EndDo

		EndIf

	EndIf

	SG1->(RestArea(aAreaG1))
	SB1->(RestArea(aAreaB1))

Return lRet

/*/{Protheus.doc} ModelPosVld
Método para validação do modelo

@author Lucas Konrad França
@since 16/11/2018
@version 1.0

@param oModel	- Modelo de dados
@param cModelId	- ID do modelo de dados
@return lRet	- Indica se o modelo de dados está válido
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA200EVDEF

	Local lRet      := .T.
	Local oView

	If !oModel:GetModel("SG1_MASTER"):GetValue("LPESQUISA")
		oView := FwViewActive()
		If oView != Nil
			FWMsgRun(, {|| lRet := ModelPosVld(oModel, cModelId, Self) }, STR0053, STR0206) //"Aguarde..." + "Validando a operação..."
		Else
			lRet := ModelPosVld(oModel, cModelId, Self)
		EndIf
		FwViewActive(oView)
	EndIf

Return lRet

/*/{Protheus.doc} ModelPosVld
Método para validação do modelo

@author brunno.costa
@since 4/05/2019
@version 1.0

@param oModel	- Modelo de dados
@param cModelId	- ID do modelo de dados
@param oEvent	- Instancia da classe EVDEF
@return lRet	- Indica se o modelo de dados está válido
/*/
Static Function ModelPosVld(oModel, cModelId, oEvent)
	Local aNames    := {}
	Local cProduto  := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local lRet      := .T.
	Local lRetPE    := .T.
	Local lAltQtde  := .F.
	Local lRunAuto  := oModel:GetModel("SG1_MASTER"):GetValue("CEXECAUTO") == "S"
	Local lGrava    := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local nQtdBase  := oModel:GetModel("SG1_MASTER"):GetValue("NQTBASE")
	Local oLines    := oEvent:oDadosCommit["oLines"]

	If lRunAuto .Or. IsIncallStack("ButtonCancelAction")
		P200AvaRev()
	EndIf

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	If RetFldProd(cProduto,"B1_QB") != nQtdBase
		lAltQtde := .T. //quantidade base alterada
	EndIf

	P200GravAl(oModel)

	If !lAltQtde .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE) .And. !lRunAuto
		aNames := oLines:GetNames()
		nTotal := Len(aNames)
		For nIndex := 1 To nTotal
			If oLines[aNames[nIndex]] != Nil
				lGrava := .T.
				Exit
			EndIf
		Next nIndex
		aSize(aNames, 0)
		If !lGrava
			Help(,,"Help",,STR0037,1,0)	//"Não existem alterações a serem salvas."
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. ExistBlock('P200VALID')
		lRetPE := ExecBlock('P200VALID',.F.,.F.,{oModel, oEvent:oDadosCommit})
		If ValType(lRetPE) == 'L'
			lRet := lRetPE
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} AfterTTS
Metodo que e chamado pelo MVC quando ocorrer as acoes do commit apos a transacao.
Esse evento ocorre uma vez no contexto do modelo principal.

@author brunno.costa
@since 08/04/2019
@version 1.0

@param oModel	- Modelo principal
@param cModelId	- Id do submodelo
@return Nil
/*/
METHOD AfterTTS(oModel, cModelId) CLASS PCPA200EVDEF

	Local aProdutos  := {}
	Local aLinNames  := {}
	Local lRunAuto   := oModel:GetModel("SG1_MASTER"):GetValue("CEXECAUTO") == "S"
	Local lIntegra   := .T.
	Local lPCPREVATU := FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
	Local nIndex     := 1
	Local nTotal     := 0
	Local nX         := 1
	Local nTot       := 0
	Local nIndRev    := 0
	Local oLines     := Self:oDadosCommit["oLines"]
	Local oFields    := Self:oDadosCommit["oFields"]

	//Integração com o Totvs MES
	If ::lIntgPPI
		aProdutos := ::oPaiIntegrado[INT_MES]:GetNames()
		nTotal    := Len(aProdutos)
		aLinNames := oLines:GetNames()
		nTot := Len(aLinNames)
		For nIndex := 1 To nTotal
			If oModel:GetOperation() != MODEL_OPERATION_DELETE
				lIntegra := .F.
				For nX := 1 To nTot
					If oLines[aLinNames[nX]] != Nil .And. oLines[aLinNames[nX]][oFields["G1_COD"]] == aProdutos[nIndex]
						nIndRev := aScan(Self:aRevisoes, {|x| x[4] == aProdutos[nIndex] .AND. x[1] })
						If nIndRev > 0
							cRevAtu := Self:aRevisoes[nIndRev][2]
						Else
							cRevAtu := IIF(lPCPREVATU, PCPREVATU(aProdutos[nIndex]), Posicione("SB1",1,xFilial("SB1")+aProdutos[nIndex],"B1_REVATU"))
						EndIf
						If oLines[aLinNames[nX]][oFields["G1_REVINI"]] <= cRevAtu .AND. oLines[aLinNames[nX]][oFields["G1_REVFIM"]] >= cRevAtu
							lIntegra := .T.
							Exit
						EndIf					
					EndIf
				Next nX
			Endif
			If lIntegra
				PCPA200PPI(/*cXml*/, aProdutos[nIndex], oModel:GetOperation(), .T., .T.)
			EndIf
		Next nIndex

		//Mensagem de erro da Integração com o Totvs MES
		If ::lIntgPPI .And. !lRunAuto
			P200ErrPPI()
		EndIf
	EndIf

	//Remove lock's manuais
	::UnLock()

Return

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.

@author Lucas Konrad França
@since 16/11/2018
@version 1.0

@param oModel	- Modelo principal
@param cModelId	- Id do submodelo
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA200EVDEF
	Local oView := FwViewActive()
	If oView != Nil
		FWMsgRun(, {|| InTTS(oModel, cModelId, Self) }, STR0053, STR0208) //"Aguarde..." + "Gravando alterações..."
		FwViewActive(oView)
	Else
		InTTS(oModel, cModelId, Self)
	EndIf
Return Nil

/*/{Protheus.doc} InTTS
Funcao que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.

@author brunno.costa
@since 14/05/2019
@version 1.0

@param oModel	- Modelo principal
@param cModelId	- Id do submodelo
@param oEvent   - Instancia da classe EVDEF
@return Nil
/*/
Static Function InTTS(oModel, cModelId, oEvent)
	Local aAreaSG1   := SG1->(GetArea())
	Local nOperation := 0
	Local nInd       := 0
	Local nRecno     := 0
	Local cCod       := ""
	Local cComp      := ""
	Local cTrt       := ""
	Local nQtdBase   := oModel:GetModel("SG1_MASTER"):GetValue("NQTBASE")
	Local cProduto   := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local lDadosSBZ  := RetArqProd(cProduto)
	Local cRevisao
	Local lAltNivel	 := .F.
	Local lMudouQB   := .F.
	Local lLimpaLine := .F.
	Local oLinDel    := oEvent:oDadosCommit["oLinDel"]
	Local oLines     := oEvent:oDadosCommit["oLines"]
	Local oFields    := oEvent:oDadosCommit["oFields"]
	Local aChaves    := oLines:GetNames()

	oEvent:aRecnos := {0, {}}		// {Operação realizada na tela, {{Operação realizada no registro, recno do registro}....}}

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	If RetFldProd(cProduto,"B1_QB") != nQtdBase
		If !lDadosSBZ
			RecLock('SBZ')
			Replace SBZ->BZ_QB With nQtdBase
			MsUnlock()

			If oEvent:lIntegraProdutoOnLine .And. !Empty(GetSx3Cache("HWE_QB", "X3_TAMANHO"))
				M018IntMrp()
			EndIf
		Else
			RecLock('SB1')
			Replace SB1->B1_QB With nQtdBase
			MsUnlock()
			
			If oEvent:lIntegraProdutoOnLine .And. !Empty(GetSx3Cache("HWA_QB", "X3_TAMANHO"))
				A010IntPrd(Nil, Nil, "INSERT", "SB1", Nil)
			EndIf
		EndIf
		lMudouQB := .T.
	EndIf

	//Chama pergunte PCPA200 e converte em propriedades - Sem tela
	oEvent:PerguntaPCPA200(.F.)
	If oEvent:lGeraRevisao .AND. oModel:GetOperation() != MODEL_OPERATION_DELETE
		nInd := aScan(oEvent:aRevisoes, {|x| x[4] == cProduto .AND. x[1] })
		If nInd > 0 .OR. !oEvent:mvlRevisaoAutomatica
			
	        	    //Gera SG5 e grava alteração na SB1 - Produto Master - Sem tela
					cRevisao := oEvent:AtualizaRevisao(cProduto, .F., .T., oEvent:cRevisaoMaster,oModel)
				EndIf
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or. oModel:GetOperation() == MODEL_OPERATION_INSERT
			//Gera SG5 e grava alteração na SB1 - Produtos Intermediários
			oEvent:AtualizaPIsRevisao(cRevisao)
		Endif
	EndIf

	SG1->(dbSetOrder(1))
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cCod  := SG1->G1_COD

		If SG1->(dbSeek(xFilial('SG1') + cCod, .F.))
			//Exclui todos os componentes do Produto Pai
			While SG1->(!Eof())                    .And. ;
			      SG1->G1_FILIAL == xFilial("SG1") .And. ;
			      SG1->G1_COD    == cCod
				
				oEvent:GravaAlteracoes(MODEL_OPERATION_DELETE, SG1->(G1_COD + G1_COMP + G1_TRT))

				SG1->(DbSkip())
			End
			lAltNivel := .T.
		EndIf
	Else
		If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
			For nInd := 1 To Len(aChaves)
				cChave := aChaves[nInd]

				//Proteção para não gravar um registro que tenha ficado inválido
				If oLines[cChave] == Nil;
				   .OR. Empty(oLines[cChave][oFields["G1_COD"]]);
				   .Or. Empty(oLines[cChave][oFields["G1_COMP"]])
					Loop
				EndIf

				//Posiciona no registro
				nRecno := oLines[cChave][oFields["NREG"]]
				If nRecno > 0
					SG1->(dbGoTo(nRecno))
				Else
					cCod   := oLines[cChave][oFields["G1_COD"]]
					cComp  := oLines[cChave][oFields["G1_COMP"]]
					cTrt   := oLines[cChave][oFields["G1_TRT"]]
					// Posiciona no registro da SG1 e valida se já existe o registro gravado
					// DMANSMARTSQUAD1-27542 Error log rotina PCPA200
					//if xFilial("SG1")+POSICIONE("SG1",1,xFilial("SG1")+cCod+cComp+cTrt,"G1_COD");
					//   +cComp+cTrt==SG1->(G1_FILIAL+G1_COD+G1_COMP+G1_TRT)
					//	Loop
					//Endif
				EndIf

				If nRecno > 0 .And. !SG1->(Eof())
					//Se o registro existe e foi excluído, ativa o modelo na operação DELETE
					If oLinDel[cChave] != Nil .AND. oLinDel[cChave]
						nOperation := MODEL_OPERATION_DELETE
						lAltNivel := .T.
					Else
						nOperation := MODEL_OPERATION_UPDATE
					EndIf
				Else
					//Se o registro não está na base e está deletado na Grid, desconsidera
					If oLinDel[cChave] != Nil .AND. oLinDel[cChave]
						Loop
					EndIf

					//Se o registro não existe, cria um novo
					nOperation := MODEL_OPERATION_INSERT
					lAltNivel := .T.
				EndIf
				oEvent:GravaAlteracoes(nOperation, cChave)
			Next nInd
		EndIf
	EndIf

	If oEvent:lIntegraMRP .And. oEvent:lIntegraOnline
		If lMudouQB
			//Se mudou a quantidade base, e o produto pai não está na lista de alterações
			//irá adicionar no "oLines" uma linha do produto pai para integrar a estrutura
			//com a quantidade base atualizada.
			If aScan(aChaves, {|x| PadR(x, Len(cProduto)) == cProduto .And. oLines[x] != Nil }) < 1 .And. oLines[cProduto] == Nil
				oLines[cProduto] := Array(Len(oFields:GetNames()))
				oLines[cProduto][oFields["G1_FILIAL"]] := xFilial("SG1")
				oLines[cProduto][oFields["G1_COD"   ]] := cProduto
				oLines[cProduto][oFields["G1_COMP"  ]] := cProduto

				lLimpaLine := .T.
			EndIf
		EndIf
		PCPA200MRP(oEvent, oModel)

		If lLimpaLine
			aSize(oLines[cProduto], 0)
			oLines[cProduto] := Nil
		EndIf
	EndIf

	//Exclui Histórico de Revisões
	If oModel:GetOperation() == MODEL_OPERATION_DELETE .and. oEvent:mvlArquivoRevisao
		oEvent:DeletaHistoricoRevisoes(cProduto)
	EndIf

	If lAltNivel
		PutMV('MV_NIVALT','S')
	EndIf

	oEvent:aRecnos[1] := oModel:GetOperation()
	If ExistBlock("P200GRAV")
		ExecBlock("P200GRAV", .F., .F., oEvent:aRecnos)
	EndIf
	aSize(oEvent:aRecnos, 0)

	RestArea(aAreaSG1)
Return

/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.

@author brunno.costa
@since 08/04/2019
@version 1.0

@param 01 - oModel   , objeto  , objeto do modelo
@param 02 - cModelId , caracter, nome do modelo
@return lReturn		- Indica se os dados sao validos para ativacao
/*/
METHOD VldActivate(oModel, cModelId) CLASS PCPA200EVDEF
	Local lReturn    := .T.
	Local nOperation := oModel:GetOperation()
	Local lPCPA200   := FunName() == "PCPA200"
	Local lEditRepli := FunName() == "PCPA120" .and. IsInCallStack(Upper("updEstrut"))

	If (lPCPA200 .OR. lEditRepli) .AND.;
		nOperation != MODEL_OPERATION_VIEW .AND.;
		nOperation != MODEL_OPERATION_INSERT

		lReturn  := ::Lock(fAjustaStr(SG1->G1_COD),,,,,.F.)
	Endif

Return lReturn

/*/{Protheus.doc} GravaAlteracoes
Método para efetivar a gravação dos dados na tabela SG1

@author Lucas Konrad França
@since 16/11/2018
@version 1.0

@param nOperation	- Indica a operação
@param cChave    	- Chave do registro para gravacao
@return lRet		- Indica se os dados foram commitados
/*/
METHOD GravaAlteracoes(nOperation, cChave) CLASS PCPA200EVDEF
	Local cProduto  := ""
	Local cRevisao  := ""
	Local cRevAnt   := ""
	Local oModel    := FWLoadModel("PCPA200Grv")
	Local oModelGrv := oModel:GetModel("SG1_MASTER")
	Local aFields   := oModelGrv:oFormModelStruct:aFields
	Local aAreaG1   := SG1->(GetArea())
	Local aAreaB1   := SB1->(GetArea())
	Local lRet      := .T.
	Local lAtualiza := .T.
	Local nIndCps   := 0
	Local nPosCampo := 0
	Local nRecAtu   := 0
	Local oLines    := ::oDadosCommit["oLines"]
	Local oFields   := ::oDadosCommit["oFields"]

	oModel:SetOperation(nOperation)
	oModel:Activate()

	If nOperation == MODEL_OPERATION_INSERT
		oModelGrv:LoadValue("G1_COD", oLines[cChave][oFields["G1_COD"]])
	EndIf

	//Ajustes referente Nova Revisão
	If ::mvlRevisaoAutomatica;
	   .AND. nOperation != MODEL_OPERATION_INSERT;
	   .AND. oLines[cChave] != Nil;
	   .AND. oLines[cChave][oFields["NovaRevisao"]]

		//Se operação DELETE, muda para UPDATE
		If nOperation == MODEL_OPERATION_DELETE
			oModel:DeActivate()
			oModel:SetOperation(MODEL_OPERATION_UPDATE)
			oModel:Activate()
		EndIf

		cRevisao  := oLines[cChave][oFields["G1_REVINI"]]
		cRevAnt   := PadL(Val(cRevisao) - 1, Len(cRevisao), '0' )
		nRecAtu := oLines[cChave][oFields["NREG"]]

		If oLines[cChave][oFields["NREG"]] > 0
			If SG1->(Recno()) != oLines[cChave][oFields["NREG"]]
				nRecAtu := SG1->(Recno())
				SG1->(dbGoTo(oLines[cChave][oFields["NREG"]]))
			EndIf
			If SG1->G1_REVFIM < cRevAnt
				lAtualiza := .F.
			EndIf
			If nRecAtu != oLines[cChave][oFields["NREG"]]
				SG1->(dbGoTo(nRecAtu))
			EndIf
		EndIf
		If lAtualiza
			If oLines[cChave][oFields["G1_REVFIM"]] > cRevAnt
				oModelGrv:LoadValue("G1_REVFIM", cRevAnt)
			EndIf

			lRet := FWFormCommit(oModel)
			Aadd(Self:aRecnos[2], {oModel:GetOperation(), SG1->(Recno())})
		EndIf
		oModel:DeActivate()

		//Insere novo Registro - Chamada Recursiva
		If nOperation != MODEL_OPERATION_DELETE
			oLines[cChave][oFields["NovaRevisao"]] := .F.
			::GravaAlteracoes(MODEL_OPERATION_INSERT, cChave)
		EndIf
	Else
		If nOperation != MODEL_OPERATION_DELETE
			//Carrega os campos do modelo
			For nIndCps := 1 to Len(aFields)
				nPosCampo := oFields[aFields[nIndCps][3]]
				oModelGrv:LoadValue(aFields[nIndCps][3], oLines[cChave][nPosCampo] )
			Next nIndCps
		EndIf

		lRet := FWFormCommit(oModel)
		Aadd(Self:aRecnos[2], {oModel:GetOperation(), SG1->(Recno())})
		oModel:DeActivate()
	EndIf

	//Atualiza o campo B1_UREV
	If oLines[cChave] != Nil
		A200UpDRev(::mvlDataRevisao, oLines[cChave][oFields["G1_COD"]], oLines[cChave][oFields["CARGO"]])
	EndIf

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		cProduto := oLines[cChave][oFields["G1_COD"]]
	Else
		cProduto := Left(cChave, GetSx3Cache("G1_COD","X3_TAMANHO"))
	EndIf

	If lRet
		//Integração com o Chão de Fábrica
		If ::lIntgSFC
			If ::oPaiIntegrado[INT_SFC][cProduto] == Nil
				::oPaiIntegrado[INT_SFC][cProduto]:= .T.
				If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
					SFCIntSFC(cProduto, '2')
				Else
					SFCIntSFC(cProduto, '1')
				EndIf
			EndIf
		EndIf

		//Integração com o Totvs MES
		If ::lIntgPPI
			If ::oPaiIntegrado[INT_MES][cProduto] == Nil
				::oPaiIntegrado[INT_MES][cProduto] := .T.
			EndIf
		EndIf
	EndIf

	SB1->(RestArea(aAreaB1))
	SG1->(RestArea(aAreaG1))
Return lRet

/*/{Protheus.doc} ::PerguntaPCPA200
Chama pergunte PCPA200 e converte em propriedades
@author brunno.costa
@since 11/12/2018
@version 1.0
@param lExibe, lógico, indica se exibe o pergunte em tela
@return Nil
/*/
METHOD PerguntaPCPA200(lExibe) CLASS PCPA200EVDEF

	Default lExibe := .F.

	If P200Pergun(lExibe) == 'PCPA200'
		::mvlDataRevisao    := MV_PAR01 == 1
		::mvlArquivoRevisao := MV_PAR02 == 1
		::mvlSubstituiNaOP  := MV_PAR03 == 1
		::nExibeInvalidos   := MV_PAR04
	Else
		::mvlDataRevisao    := MV_PAR01 == 1
		::mvlArquivoRevisao := MV_PAR02 == 1
		::mvlSubstituiNaOP  := MV_PAR04 == 1
		::nExibeInvalidos   := 1
	EndIf

Return Nil

/*/{Protheus.doc} AtualizaRevisao
Atualiza cadastro de revisao de componentes
@author brunno.costa
@since 11/12/2018
@version 1.0
@param  cProduto  , caracter, código do componente
@param  lShow     , lógico  , indica se deve exibir a tela de seleção da revisão atual
@param  lAltera   , lógico  , indica se deve gerar SG5 e atualizar SB1
@param  cRevAtual , caracter, código da revisão atual do produto pai, enviado somente para o produto pai de revisão manual - TELA DE SELEÇÃO MANUAL
@param  oModel    , object  , objeto do modelo de dados.
@return cRevisao  , caracter, código da revisão atual
/*/
METHOD AtualizaRevisao(cProduto, lShow, lAltera, cRevAtual, oModel) CLASS PCPA200EVDEF

	Local aArea      := GetArea()
	Local aAreaSG5   := SG5->(GetArea())
	Local aAreaSB1   := {}
	Local cRevSB
	Local cRevisao   := ""
	Local snTamRev   := GetSx3Cache("G1_REVINI" ,"X3_TAMANHO")

	Default lShow	 := .T.
	Default lAltera  := .T.
	Default cRevAtual  := ""

	If Empty(cRevAtual)
		nIndScan := aScan(::aRevisoes, {|x| x[4] == cProduto .AND. x[1] })
		If nIndScan > 0
			cRevisao := ::aRevisoes[nIndScan][2]
		Else
			If ::mvlRevisaoAutomatica
				cRevisao := PadR(" " , snTamRev)
			Else
				cRevisao := CriaVar("G1_REVINI")
			EndIf	
			dbSelectArea("SG5")
			SG5->(dbSetOrder(1))
			If SG5->(dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))))
				Do While SG5->(!Eof()) .And. SG5->(G5_FILIAL+G5_PRODUTO) == xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))
					AADD(::aRevisoes, {.F., SG5->G5_REVISAO, DTOC(SG5->G5_DATAREV), cProduto})
					cRevisao := SG5->G5_REVISAO
					SG5->(dbSkip())
				EndDo
			EndIf

			dbSelectArea("SB1")
			aAreaSB1 := SB1->(GetArea())
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProduto))
				cRevSB := IIf(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
				If (cRevSB > cRevisao)
					cRevisao :=	 cRevSB
				EndIf
			EndIf
			RestArea(aAreaSB1)

			cRevisao := Soma1(cRevisao)
			AADD(::aRevisoes, {.T., cRevisao, DTOC(dDataBase), cProduto})

			If lShow
				cRevisao := A200SelRev(::aRevisoes, !P200IsAuto(oModel) .AND. ::mvlRevisaoAutomatica, cProduto, oModel)
			Endif
		EndIf
	Else
		cRevisao := cRevAtual
	EndIf

	If lAltera
		If !Empty(cRevisao)
			If ::mvlArquivoRevisao
				dbSelectArea("SG5")
				SG5->(dbSetOrder(1))

				If SG5->(dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(G5_PRODUTO))+cRevisao))
					RecLock("SG5",.F.)
				Else
					RecLock("SG5",.T.)
					SG5->G5_FILIAL  := xFilial("SG5")
					SG5->G5_PRODUTO := cProduto
					SG5->G5_REVISAO := cRevisao
				Endif

				SG5->G5_DATAREV := dDataBase
				SG5->G5_USER    := RetCodUsr()

				//Quando Controle de Revisao estiver ativo, grava os campos conforme
				//realizado na A201AtuAx() para Revisao de Estruturas
				If SuperGetMv("MV_REVPROD",.F.,.F.) .And. DPosicione("SB5",1,xFilial("SB5")+cProduto,"B5_REVPROD") == "1"
					SG5->G5_STATUS := "2"
					SG5->G5_MSBLQL := "1"
				EndIf

				If ExistBlock("M200REVI")
					ExecBlock("M200REVI",.f.,.f.)
				EndIf

				SG5->(MsUnlock())
			EndIf

			dbSelectArea("SB1")
			aAreaSB1 := SB1->(GetArea())
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProduto))
				IF lPCPREVTAB
					PCPREVTAB(cProduto, cRevisao)
				Else
					RecLock("SB1",.F.)
					Replace B1_REVATU With cRevisao
					MsUnlock()
				EndIf

				If ::lIntegraProdutoOnLine
					A010IntPrd( , , "INSERT", "SB1")
				EndIf
			EndIf
			RestArea(aAreaSB1)
		EndIf

	EndIf
	RestArea(aAreaSG5)
	RestArea(aArea)
Return cRevisao

/*/{Protheus.doc} DPosicione
Função para posicionamento em um arquivo específico com DbSeek
- Sem proteção de posicionamento no cAlias
- Sem desposicionar o Alias() corrente
@author brunno.costa
@since 18/12/2018
@version 1.0
@param cAlias    , caracter, alias a ser posicionado
@param nOrdem    , numérico, indice de pesquisa numérico da tabela
@param cExpr     , caracter, expressão de pesquisa da tabela
@param cCampo    , caracter, campo a ser retornado
@return oReturn  , variavel, conteúdo do campo cCampo no cAlias após DbSeek
/*/
Static Function DPosicione(cAlias, nOrdem, cExpr, cCampo)
	Local oReturn
	(cAlias)->(DbSetOrder(nOrdem))
	(cAlias)->(DbSeek(cExpr))
	oReturn := (cAlias)->&(cCampo)
Return oReturn

/*/{Protheus.doc} AtualizaPIsRevisao
Atualiza o Cadastro de Revisões de Todos os Produtos Intermediários com Estrutura Alterada
@author brunno.costa
@since 11/12/2018
@version 1.0
@param cRevMaster, caracter, código da revisão do produto Master
/*/
METHOD AtualizaPIsRevisao(cRevMaster) CLASS PCPA200EVDEF

	Local oModel		:= FwModelActive()
	Local aArea			:= GetArea()
	Local aAreaSG1		:= SG1->(GetArea())
	Local aFields		:= oModel:GetModel("SG1_DETAIL"):oFormModelStruct:aFields
	Local cProdPai		:= ""
	Local cProdMaster	:= oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
	Local cAliasQry		:= ""
	Local cRevPai		:= ""
	Local cCargo		:= ""
	Local cRevisao
	Local nInd		    := 0
	Local nIndCps	    := 0
	Local nTamDesc	    := GetSx3Cache("G1_DESC","X3_TAMANHO")
	Local nScan
	Local oLinDel       := ::oDadosCommit["oLinDel"]
	Local oLines        := ::oDadosCommit["oLines"]
	Local oFields       := ::oDadosCommit["oFields"]
	Local aChaves       := oLines:GetNames()
	Local cChave
	Local cChaveAux		:= ""

	Default cRevMaster := CriaVar("G1_REVINI")

	If lSOWInDic
		SOW->(dbSelectArea("SOW"))
		SOW->(dbSetOrder(1))
	EndIf

	DbSelectArea("SG1")

	For nInd := 1  to Len(aChaves)
		cChave   := aChaves[nInd]
		If oLines[cChave] == Nil .OR. Empty(oLines[cChave])
			Loop
		EndIf
		cProdPai := oLines[cChave][oFields["G1_COD"]]

		//Revisão Automática
		If ::mvlRevisaoAutomatica
			nScan := aScan(::aRevisoes, {|x| x[4] == cProdPai .AND. x[1] })
			If nScan > 0 .and. ::aRevisoes[nScan,2] == oLines[cChave][oFields["G1_REVINI"]] 
				oLines[cChave][oFields["NovaRevisao"]] := .T.
				cCargo                                 := oLines[cChave][oFields["CARGO"]]
				cRevPai                                := Tira1(::aRevisoes[nScan,2])

				If ::nExibeInvalidos == 2
					cQuery := " SELECT "
					For nIndCps := 1 To Len(aFields)
						If aFields[nIndCps][14] == .F. //Se é um campo do tipo Virtual, não adiciona na Query
							If nIndCps > 1
								cQuery += ","
							EndIf
							cQuery += " SG1." + AllTrim(aFields[nIndCps][3])
						ElseIf aFields[nIndCps][3] == "G1_DESC"
							If nIndCps > 1
								cQuery += ","
							EndIf
							cQuery += " SB1.B1_DESC "
						EndIf
					Next nIndCps

					cQuery += ", SG1.R_E_C_N_O_ RECSG1 "
					cQuery +=   " FROM " + RetSqlName("SG1") + " SG1, "
					cQuery +=              RetSqlName("SB1") + " SB1 "
					cQuery +=  " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "' "
					cQuery +=    " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
					cQuery +=    " AND SG1.G1_COD     = '" + cProdPai + "' "
					cQuery +=    " AND SB1.B1_COD     = SG1.G1_COMP "
					cQuery +=   "  AND (SG1.G1_INI > '" + DToS(dDataBase) + "' OR SG1.G1_FIM < '" + DToS(dDataBase) + "')"
					cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "
					cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
					cQuery += " AND SG1.G1_REVINI <= '" + cRevPai + "' "
					cQuery += " AND (SG1.G1_REVFIM >= '" + cRevPai + "' OR SG1.G1_REVFIM = ' ')"

					cQuery += " ORDER BY " + SqlOrder(SG1->(IndexKey(1)))

					cQuery := ChangeQuery(cQuery)

					cAliasQry := GetNextAlias()
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

					//Faz a conversão dos campos Data, Lógico e Numérico.
					For nIndCps := 1 To Len(aFields)
						If aFields[nIndCps][14] == .F. //Se é um campo do tipo Virtual, não adiciona na Query
							If aFields[nIndCps][4] $ "N|L|D"
								// aFields[nIndCps][3] - Nome do campo
								// aFields[nIndCps][4] - Tipo de dado do campo
								// aFields[nIndCps][5] - Tamanho do campo
								// aFields[nIndCps][6] - Precisão do campo
								TcSetField(cAliasQry,aFields[nIndCps][3],aFields[nIndCps][4],aFields[nIndCps][5],aFields[nIndCps][6])
							EndIf
						EndIf
					Next nIndCps

					While (cAliasQry)->(!Eof())
						If ::oDadosCommit["oRecnos"][cValToChar((cAliasQry)->(RECSG1))] == Nil
							cChaveAux         := (cAliasQry)->(G1_COD+G1_COMP+G1_TRT)
							oLines[cChaveAux] := aClone(oLines[cChave])
							For nIndCps := 1 To Len(aFields)
								nCampo := oFields[aFields[nIndCps][3]]
								If aFields[nIndCps][14] == .F. //Verifica se é campo virtual
									oLines[cChaveAux][nCampo] := (cAliasQry)->(&(aFields[nIndCps][3]))

								ElseIf AllTrim(aFields[nIndCps][3]) == "G1_DESC"
									oLines[cChaveAux][nCampo] := PadR((cAliasQry)->(B1_DESC),nTamDesc)

								ElseIf AllTrim(aFields[nIndCps][3]) == "NREG"
									oLines[cChaveAux][nCampo] := (cAliasQry)->(RECSG1)

								ElseIf AllTrim(aFields[nIndCps][3]) == "CARGO"
									oLines[cChaveAux][nCampo] := P200Cargo((cAliasQry)->(G1_COD), (cAliasQry)->(G1_COMP), (cAliasQry)->(G1_TRT), cCargo, (cAliasQry)->(RECSG1))

								ElseIf AllTrim(aFields[nIndCps][3]) == "CSEQORIG"
									oLines[cChaveAux][nCampo] := (cAliasQry)->(G1_TRT)

								EndIf
							Next nIndCps
							oLines[cChaveAux][oFields["G1_REVFIM"]] := ::aRevisoes[nScan,2]
						EndIf
						(cAliasQry)->(dbSkip())
					End
					(cAliasQry)->(dbCloseArea())
				EndIf

				//Gera SG5 e grava alteração na SB1 - PI Específico - Sem tela
				::AtualizaRevisao( cProdPai, .F. ,,,oModel)
			EndIf

		//Revisão Manual
		Else
			If (::mvlRevisaoPIManual .OR. cProdPai == cProdMaster)
				If cProdPai == cProdMaster .AND. !Empty(cRevMaster)
					cRevisao := cRevMaster

				Else
					nScan := aScan(::aRevisoes, {|x| x[4] == cProdPai .AND. x[1] })
					If nScan == 0
						//Gera SG5 e grava alteração na SB1 - PI Específico - Sem tela
						cRevisao := ::AtualizaRevisao( cProdPai, .F. ,,,oModel)
					Else
						cRevisao := ::aRevisoes[nScan,2]
					EndIf
				EndIf

				If oLines[cChave][oFields["G1_REVINI"]] > cRevisao;
				   .OR. (oLinDel[cChave] != Nil .AND. oLinDel[cChave])
					oLines[cChave][oFields["G1_REVINI"]]     := cRevisao
					oLines[cChave][oFields["NovaRevisao"]]   := .T.
					If oLines[cChave][oFields["G1_REVFIM"]] < cRevisao
						oLines[cChave][oFields["G1_REVFIM"]] := CriaVar("G1_REVFIM")
					EndIf
				EndIf
			EndIf
		EndIf
	Next nInd

	RestArea( aAreaSG1 )
	RestArea( aArea )
Return

/*/{Protheus.doc} AvlCampoRevisao
Avalia se um campo específico está configurado para geração de revisão e sofreu alteração
@author brunno.costa
@since 11/12/2018
@version 1.0
@param  nRecno    , numero    , identificador do registro no banco
@param  cCampo    , cartacter , nome do campo
@param  oNewValue , modelo    , conteúdo novo do campo
@return lReturn   , lógico    , .T. para gerar revisão e .F. para não gerar revisão
/*/
METHOD AvlCampoRevisao(nRecno, cCampo, oNewValue) CLASS PCPA200EVDEF
	Local lReturn   := .F.
	If lSOWInDic .AND. cCampo != Nil
		SG1->(DbGoto(nRecno))
		If SG1->(FieldPos(cCampo)) > 0 .AND. SG1->&(cCampo) != oNewValue
			If SOW->(dbSeek(xFilial("SOW")+cCampo))
				If SOW->OW_REVISA == "2"
					lReturn := .T.
				EndIf
			EndIf
		EndIf
	EndIf
Return lReturn

/*/{Protheus.doc} DeletaHistoricoRevisoes()
Deleta Histórico de Revisões - Tabela SG5

@author brunno.costa
@since 12/12/2018
@version 1.0

@param cProduto, caracter, código do produto
/*/
METHOD DeletaHistoricoRevisoes(cProduto) CLASS PCPA200EVDEF

	Local aArea    := GetArea()
	Local aAreaSG5 := SG5->(GetArea())
	Local aAreaSB1 := SG1->(GetArea())

	dbSelectArea("SG5")
	SG5->(dbSetOrder(1))

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))

	If Len(cProduto) > Len(SG5->G5_PRODUTO)
		cProduto := SubStr(cProduto,1,Len(SG5->G5_PRODUTO))
	EndIf

	If SG5->(dbSeek(xFilial("SG5")+cProduto))
		Do While SG5->(!Eof());
			.And. SG5->G5_FILIAL == xFilial("SG5");
			.And. SG5->G5_PRODUTO == cProduto

			RecLock('SG5',.F.)
			SG5->(dbDelete())
			SG5->(MsUnlock())
			SG5->(dbSkip())
		EndDo
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaSG5)
	RestArea(aArea)
Return nil

/*/{Protheus.doc} TratMsgErr
Trata a mensagem de erro do modelo para o Help (ExecAuto)
@author lucas.franca
@since  21/12/2018
@version 1
@param oModel, object, modelo principal
@return Nil
/*/
METHOD TratMsgErr(oModel) CLASS PCPA200EVDEF
	Local aError   := oModel:GetErrorMessage()
	Local cMsg     := ""
	Local cErro    := AllTrim(aError[MODEL_MSGERR_MESSAGE])
	Local cCampo   := AllTrim(aError[MODEL_MSGERR_IDFIELDERR])
	Local cValor   := AllTrim(aError[MODEL_MSGERR_VALUE])
	Local cSolucao := AllTrim(aError[MODEL_MSGERR_SOLUCTION])

	cMsg := cErro

	If !Empty(cCampo)
		cMsg += " (" + cCampo

		If !Empty(cValor)
			cMsg += " = " + cValor
		EndIf

		cMsg += ")"
	Else
		If !Empty(cValor)
			cMsg += " (" + cValor + ")"
		EndIf
	EndIf

	cMsg += ". " + cSolucao

	Help( , , "Help", , cMsg, 1, 0, , , , , , {} )
Return

/*/{Protheus.doc} P200SetVal
Verifica se é possível setar o valor em um campo do modelo, e executa o SetValue

@author lucas.franca
@since 21/12/2018
@version P12
@param oSubModel, object   , Submodelo que irá receber o valor
@param cField   , character, ID do field que irá receber o valor
@param xValue   , any      , Valor que será atribuído ao campo.
@return lRet    , logical  , True caso o valor tenha sido atribuído corretamente ao campo.
/*/
METHOD SetaValor(oSubModel, cField, xValue) CLASS PCPA200EVDEF
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

/*/{Protheus.doc} A200SelRev
Seleciona revisao atual do produto
@author brunno.costa
@since 11/12/2018
@version 1.0
@param  aRevisoes , array   , array com as revisões para alteração
@param  lSemTela  , lógico  , indica se deve exibir a tela de seleção da revisão atual do produto
@param  cProduto  , caracter, código do produto relacionado a revisão
@param  oModel    , object  , objeto do modelo de dados.
@return cRevisao  , caracter, código da revisão atual
/*/
Static Function A200SelRev(aRevisoes, lSemTela, cProduto, oModel)
	Local cRevisao := CriaVar("B1_REVATU")
	Local cTitle   := OemToAnsi(STR0088)	//"Seleção da Revisão Atual"
	Local cVarQ    := "   "
	Local lRunAuto := P200IsAuto(oModel)
	Local nAchou   := 0
	Local nOpca    := 1
	Local oQual
	Local oOk      := LoadBitmap( GetResources(), "LBOK")
	Local oNo      := LoadBitmap( GetResources(), "LBNO")
	Local oDlg

	Default lSemTela := .T.

	If lRunAuto
		lSemTela := .T.
	EndIf

	If Len(aRevisoes) > 0
		If !lSemTela
			DEFINE MSDIALOG oDlg TITLE cTitle From 145, 070 To 400, 337 OF oMainWnd PIXEL
			@ 002, 002 TO 107, 127 LABEL STR0090 + " '" + AllTrim(cProduto) + "':" OF oDlg  PIXEL //"Revisões"
			@ 010, 005 LISTBOX oQual VAR cVarQ Fields HEADER "",OemToAnsi(STR0015), STR0089  SIZE 120, 095 ON DBLCLICK (aRevisoes := MA200Troca(oQual:nAt,@aRevisoes), oQual:Refresh()) NOSCROLL OF oDlg PIXEL	//"Revisão"###"Data"
			oQual:SetArray(aRevisoes)
			oQual:bLine := { || { If(aRevisoes[oQual:nAt,1],oOk,oNo), aRevisoes[oQual:nAt,2], aRevisoes[oQual:nAt,3]} }
			DEFINE SBUTTON FROM 110, 050 TYPE 1 Action IF(MA200Valida(aRevisoes), (nOpca:=2,oDlg:End()), .F.) ENABLE OF oDlg PIXEL
			ACTIVATE MSDIALOG oDlg ON INIT oQual:GoBottom()
		Else
			If (lRunAuto .And. oModel:GetModel():GetModel("SG1_MASTER"):GetValue("ATUREVSB1") == "S") .Or. !lRunAuto
				nOpca := 2
			EndIf
		EndIf
		If nOpca == 2
			nAchou := aScan(aRevisoes, {|x| x[4] == cProduto .and. x[1] })
			If nAchou > 0
				cRevisao := aRevisoes[nAchou,2]
			EndIf
		EndIf
	EndIf
Return cRevisao

/*/{Protheus.doc} MA200Valida
Verifica se selecionou alguma revisão
@author brunno.costa
@since 11/12/2018
@version 1.0
@param  aRevisoes , array   , array com as revisões para alteração
@return lReturn   , lógico  , False se não selecionu revisão, true se selecionou
/*/
Static Function MA200Valida(aRevisoes)
	Local lRet := .F.
	If aScan(aRevisoes, { |x| x[1] }) > 0
		lRet := .T.
	EndIf
	If !lRet
		Help(,,'Help',,STR0099,; //"Nenhuma revisão foi selecionada."
			     1,0,,,,,,{STR0091}) //"Selecione uma revisão."
	EndIf
Return lRet

/*/{Protheus.doc} MA200Troca
Marca X Desmarca revisão utilizada
@author brunno.costa
@since 11/12/2018
@version 1.0
@param  nIndAtual , numérico, indice do array de revisões
@param  aRevisoes , array   , array com as revisões
@return aRevisoes , array   , array com as revisões atualizado
/*/
Static Function MA200Troca(nIndAtual, aRevisoes)
	Local nIndAux := 0
	aRevisoes[nIndAtual,1] := !aRevisoes[nIndAtual,1]
	For nIndAux := 1 to Len(aRevisoes)
		If nIndAtual # nIndAux
			aRevisoes[nIndAux,1] := .F.
		EndIf
	Next nIndAux
Return aRevisoes

/*/{Protheus.doc} P200IsAuto
Identifica se o programa está sendo executado por rotina automática ou por tela.

@author lucas.franca
@since 21/12/2018
@version P12
@param oModel, object, Modelo de dados do programa PCPA200
@return lRet, logical, Indica se o programa está sendo executado por execução automática.
/*/
Function P200IsAuto(oModel)
	Local lRet := .F.
	Local oSubMdl

	If oModel:GetId() != "SG1_MASTER"
		oSubMdl := oModel:GetModel():GetModel("SG1_MASTER")
	Else
		oSubMdl := oModel
	EndIf

	If oSubMdl:GetValue("CEXECAUTO") == "S"
		lRet := .T.
	EndIf
Return lRet

/*/{Protheus.doc} ConverteCampos
Método que faz a conversão da nomenclatura de campos entre SVG e SG1
@author Carlos Alexandre da Silveira
@since 09/01/2019
@version 1.0
@param 01 cCampoSVG, Caracter, campo a ser convertido
@param 02 lReverso, Lógico, indica se a reversão será inversa (da SG1 para a SVG)
@return cCampoSG1, Caracter, campo covertido
/*/
METHOD ConverteCampos(cCampoSVG, lReverso) CLASS PCPA200EVDEF
	Local cCampoSG1  := ""
	Default lReverso := .F.

	cCampoSVG := AllTrim(cCampoSVG)

	If !lReverso
		Do Case
			Case cCampoSVG == "VG_COD"
				cCampoSG1 := "G1_LISTA"
			Otherwise
				cCampoSG1 := Strtran(cCampoSVG,"VG_","G1_")
		EndCase
	Else
		Do Case
			Case cCampoSVG == "G1_LISTA"
				cCampoSG1 := "VG_COD"
			Otherwise
				cCampoSG1 := Strtran(cCampoSVG,"G1_","VG_")
		EndCase
	EndIf

Return cCampoSG1

/*/{Protheus.doc} ValidaTrt
Método que faz a validação do TRT do componente tratando a revisão
@author Marcelo Neumann
@since 12/03/2019
@version 1.0
@param 01 oMdlDet   , Objeto  , modelo da Grid com os componentes
@param 02 cPai      , Caracter, código do produto Pai
@param 03 cComp     , Caracter, código do componente
@param 04 cTrt      , Caracter, sequência (TRT) a ser validada
@return lTrtValido  , Lógico  , indica se o TRT enviado é válido
/*/
METHOD ValidaTrt(oMdlDet, cPai, cComp, cTrt) CLASS PCPA200EVDEF

	Local cRecno     := cValToChar(oMdlDet:GetValue("NREG", oMdlDet:GetLine()))
	Local cRevIni    := oMdlDet:GetValue("G1_REVINI", oMdlDet:GetLine())
	Local cRevFim    := oMdlDet:GetValue("G1_REVFIM", oMdlDet:GetLine())
	Local cQuery     := ""
	Local nInd       := 0
	Local lTrtValido := .T.

	For nInd := 1 To oMdlDet:Length()
		If EstVldStr(Alltrim(cTRT),2)
			If nInd == oMdlDet:GetLine() .Or. ;
			   oMdlDet:IsDeleted(nInd)   .Or. ;
			   oMdlDet:GetValue("G1_COMP",nInd) != cComp .Or. ;
			   (oMdlDet:GetValue("G1_COMP",nInd) == cComp .And. oMdlDet:GetValue("G1_TRT",nInd) != cTrt)
				Loop
			EndIf

			If cRevIni > oMdlDet:GetValue("G1_REVFIM", nInd) .Or. cRevFim < oMdlDet:GetValue("G1_REVINI", nInd)
				Loop
			EndIf

			Help(' ', 1, 'MESMASEQ')
			lTrtValido := .F.
			Exit
		Else
			lTrtValido := .F.
			Exit
		Endif
	Next nInd

	If lTrtValido
		cQuery := "SELECT SG1.G1_INI, SG1.G1_FIM, SG1.G1_REVINI, SG1.G1_REVFIM"
		cQuery +=  " FROM " + RetSqlName('SG1') + " SG1"
		cQuery += " WHERE SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
		cQuery +=   " AND SG1.G1_COD     = '" + cPai  + "'"
		cQuery +=   " AND SG1.G1_COMP    = '" + cComp + "'"
		cQuery +=   " AND SG1.G1_TRT     = '" + cTrt  + "'"
		cQuery +=   " AND SG1.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SG1.R_E_C_N_O_ <> " + cRecno
		cQuery +=   " AND (( '" + cRevIni + "' BETWEEN SG1.G1_REVINI AND SG1.G1_REVFIM AND"
		cQuery +=          " '" + cRevFim + "' BETWEEN SG1.G1_REVINI AND SG1.G1_REVFIM )"
		cQuery +=    " OR  ( SG1.G1_REVINI BETWEEN '" + cRevIni + "' AND '" + cRevFim + "' AND"
		cQuery +=          " SG1.G1_REVFIM BETWEEN '" + cRevIni + "' AND '" + cRevFim + "' ))"
		cQuery := ChangeQuery(cQuery)

		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSG1",.F.,.T.)
		If !QRYSG1->(Eof())
			If ::nExibeInvalidos == 2 .And. (dDataBase < SToD(QRYSG1->G1_INI) .Or. dDataBase > SToD(QRYSG1->G1_FIM))
				Help( ,  , 'Help', ,  STR0042 + ; //"Esta sequência de componente já está sendo utilizada nesta estrutura para o mesmo produto."
				                      STR0142,  ; //"O componente não está sendo exibido pois o parâmetro 'Exibe Componentes Válidos' está desativado."
					 1, 0, , , , , , {STR0143})   //"Para utilizar essa sequência, primeiramente deverá ser desativado o parâmetro 'Exibe Componentes Válidos' dessa rotina e, em seguida, deverá ser realizada a alteração da sequência do componente inválido."
			Else
				Help( ,  , 'Help', ,  STR0042,  ; //"Esta sequência de componente já está sendo utilizada nesta estrutura para o mesmo produto."
					1, 0, , , , , , {STR0043 + ; //"Se deseja alterar a sequência deste componente por uma sequência já utilizada para o mesmo produto, primeiro efetive a alteração de sequência do componente que possui a sequência digitada."
									STR0141})   //"Após efetivar a alteração, será permitido reutilizar esta sequência para o mesmo produto."
			EndIf

			lTrtValido := .F.
		EndIf
		QRYSG1->(dbCloseArea())
	EndIf

Return lTrtValido


/*/{Protheus.doc} ::PergPCPA200C
Chama pergunte PCPA200C e converte em propriedades
@author brunno.costa
@since 14/12/2018
@version 1.0
@param lExibe, lógico, indica se exibe o pergunte em tela
@return Nil
/*/
METHOD PergPCPA200C(lExibe) CLASS PCPA200EVDEF

	Local oView      := FwViewActive()
	Local lReturn    := .T.
	Local aOpcoes    := {}
	Local nInd       := 1
	Local lRecursiva := .F.

	Default lExibe   := .F.

	//Cria Array aOpcoes padrão
	For nInd := 1 to 3
		aAdd(aOpcoes, Array(9))
	Next nInd

	//Corrige Inicializadores Padrão de GET
	aOpcoes[1][3] := SG1->G1_COD	//Preenche o Produto Origem Selecionado no Browse
	aOpcoes[2][3] := P200IniRev(SG1->G1_COD)
	aOpcoes[3][3] := Space(GetSx3Cache("G1_COD"   ,"X3_TAMANHO"))

	//Altera F3 da Pergunta (Pré) Estrutura Origem
	aOpcoes[1][6] := "SB1PG1"

	//Altera F3 da Pergunta Revisão da Estrutura Origem
	aOpcoes[2][6] := "SG5"

	//Altera F3 da Pergunta Produto Destino
	aOpcoes[3][6] := "SB1"

	//Ajuste das Pictures dos GET's
	aOpcoes[1][4] := GetSx3Cache("G1_COD"   	,"X3_PICTURE")
	aOpcoes[2][4] := GetSx3Cache("G1_REVINI"   ,"X3_PICTURE")
	aOpcoes[3][4] := GetSx3Cache("G1_COD"   	,"X3_PICTURE")

	Private cCadastro := STR0179 //"Cadastro de Estrutura"

	While lReturn
		If !PCPCnvPerg('PCPA200C', lExibe, aOpcoes, lRecursiva)
			lReturn := .F.
			Exit
		EndIf

		::mvcEstruturaOrigem := MV_PAR01
		::mvcRevisaoOrigem   := MV_PAR02
		::mvcProdutoDestino  := MV_PAR03
		::mvcRevProdDestino  := P200IniRev(MV_PAR03)

		//Se os parâmetros estão válidos
		If ::ValPergPCPA200C()
			//Se conseguiu lockar o produto destino
			If ::Lock(fAjustaStr(::mvcProdutoDestino), oView, .T., .F., .F.)
				lReturn := .T.
				Exit
			EndIf
		EndIf

		lRecursiva := .T.
	End

Return lReturn

/*/{Protheus.doc} VALPERGPCPA200C
Valida respostas da pergunta PCPA200C
@author brunno.costa
@since 14/12/2018
@version 1.0
@return Nil
/*/
METHOD ValPergPCPA200C() CLASS PCPA200EVDEF

	Local aAreaAnt := GetArea()
	Local aAreaSB1
	Local lReturn := .T.
	Local cQuery
	Local cBanco  := TCGetDB()

	DbSelectArea("SG1")

	If Empty(::mvcEstruturaOrigem)
		Help(NIL, NIL, "Help", NIL, STR0165, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0166}) //"Estrutura origem em branco." -"Preencha o código do produto da estrutura origem."
		lReturn := .F.
	ElseIf Empty(::mvcProdutoDestino)
		Help(NIL, NIL, "Help", NIL, STR0167, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0168}) //"Produto destino em branco." - "Preencha o código do produto destino."
		lReturn := .F.
	Else
		aAreaSB1   := SB1->(GetArea())

		SB1->(dbSetOrder(1))
		If !SB1->(dbSeek(xFilial('SB1') + ::mvcEstruturaOrigem))
			Help(NIL, NIL, "Help", NIL, STR0169, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0170}) //"Código do produto origem inexistente." - "Utilize um código de produto válido."
			lReturn := .F.

		ElseIf !SB1->(dbSeek(xFilial('SB1') + ::mvcProdutoDestino))
			Help(NIL, NIL, "Help", NIL, STR0171, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0172}) //"Código do produto destino inexistente." - "Utilize um código de produto válido."
			lReturn := .F.
		
		ElseIf IsProdProt(::mvcEstruturaOrigem) .And. !IsInCallStack("DPRA340INT")			
			Help(NIL, NIL, "Help", NIL, STR0238, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027}) //"O produto origem é um protótipo."  "Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR)."
			lReturn := .F.

		ElseIf IsProdProt(::mvcProdutoDestino) .And. !IsInCallStack("DPRA340INT")
			Help(NIL, NIL, "Help", NIL, STR0239, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027}) //"O produto destino é um protótipo."  "Protótipos podem ser manipulados somente através do módulo Desenvolvedor de Produtos (DPR)."
			lReturn := .F.

		Else
			IF "MSSQL" $ cBanco
				cQuery :=  " SELECT TOP 1 G1_COD "
			Else
				cQuery :=  " SELECT G1_COD "
			EndIf
			cQuery +=  " FROM " + RetSqlName("SG1")
			cQuery +=  " WHERE D_E_L_E_T_=' ' "
			cQuery +=        " AND G1_FILIAL ='" + xFilial("SG1") + "'  AND G1_COD ='" + ::mvcEstruturaOrigem + "' "
			cQuery +=        " AND G1_REVINI <= '" + ::mvcRevisaoOrigem + "' "
			cQuery +=        " AND G1_REVFIM >= '" + ::mvcRevisaoOrigem + "' "
			IF "ORACLE" $ cBanco
				cQuery +=        " AND ROWNUM = 1 "
			ElseIF "POSTGRES" $ cBanco
				cQuery +=        " ORDER BY 1 LIMIT 1 "
			EndIf

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SG1PAI",.F.,.F.)

			If SG1PAI->(Eof())
				Help(NIL, NIL, "Help", NIL, STR0173, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0174}) //"Estrutura origem inexistente." - "Utilize código de produto de estrutura e revisão válidos."
				lReturn := .F.
			EndIf

			SG1PAI->(DbCloseArea())
		EndIf

		If lReturn
			SG1->(DbSetOrder(1))
			If SG1->(DbSeek(xFilial("SG1") + ::mvcProdutoDestino))
				Help(NIL, NIL, "Help", NIL, STR0175, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0176}) //"Já existe pré-estrutura para este produto destino." - "Exclua a pré-estrutura existente ou utilize outro produto destino."
				lReturn := .F.
			EndIf
		EndIf

		If lReturn
			//Verifica se o produto original não contem o produto destino em sua Pre-estrutura.
			If PCPExisCmp(.F., ::mvcEstruturaOrigem, ::mvcProdutoDestino, ::mvcRevisaoOrigem)
				Help(NIL, NIL, "Help", NIL, STR0177, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0178}) //"A estrutura origem é inválida pois possui o produto destino como componente." - "Utilize uma estrutura origem válida."
				lReturn := .F.
			EndIf
		EndIf

		//Restaura Area de trabalho.
		RestArea(aAreaSB1)
		RestArea(aAreaAnt)
	EndIf

Return lReturn

/*/{Protheus.doc} SetGeraRevisao
Seta um valor para a propriedade ::lGeraRevisao
@author marcelo.neumann
@since 04/04/2019
@version 1.0
@param lGera - Valor a ser atribuído ao ::lGeraRevisao
@return Nil
/*/
METHOD SetGeraRevisao(lGera) CLASS PCPA200EVDEF

	::lGeraRevisao := lGera

Return

/*/{Protheus.doc} Lock
Bloqueia os componentes de determinado nivel da estrutura com base no produto Pai
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto  , caracter, codigo do produto
@param 02 - oView     , objeto  , objeto da view
@param 03 - lHelp     , logico  , indica se informa ou nao o help
@param 04 - lForcaHelp, logico  , forca exibicao de help, executa HelpInDark(.F.) - Necessario pois GridLinePreVld, cAction = "CANSETVALUE", nao exibe Help
@return lReturn - indica se conseguiu bloquear todos os componentes deste pai
/*/
METHOD Lock(cProduto, oView, lHelp, lForcaHelp, lReload) CLASS PCPA200EVDEF

	Local aAreaSG1    := SG1->(GetArea())
	Local lReturn     := .T.
	Local cFunName    := FunName()
	Local lPCPA200    := cFunName == "PCPA200"
	Local lPCPA120    := cFunName == "PCPA120"
	Local lReplicando := IsInCallStack(Upper("ReplicarEstrutura"))
	Local lEditRepli  := lPCPA120 .and. IsInCallStack(Upper("updEstrut"))
	Local oModel

	Default oView     := FwViewActive()
	Default lHelp     := Iif(lPCPA200 .OR. lPCPA120 .OR. lReplicando, .T., .F.)
	Default lReload   := .T.

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
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial("SG1")+cProduto))               //Produtos COM estrutura na SG1 - SimpleLock
			While !SG1->(Eof());
			       .And. SG1->G1_FILIAL == xFilial("SG1");
			       .And. SG1->G1_COD    == cProduto

				If SG1->(SimpleLock())                          //Bloqueou registro atual da SG1
					aAdd(::oRecNo[cProduto][2], SG1->(RecNo()))
					::oRecNo[cProduto][1] := .T.

				Else                                            //NAO Bloqueou registro atual da SG1
					lReturn               := .F.
					::oBlqOther[cProduto] := StrTokArr(TCInternal(53),"|")
					If lHelp
						//Esta estrutura 'X' está bloqueada para o usuário: Y
						Help( ,  , "Help", ,  STR0184 + AllTrim(cProduto) + STR0185 + ::oBlqOther[cProduto][1] + scCRLF + scCRLF + " [" + ::oBlqOther[cProduto][2] + "]";
						    , 1, 0, , , , , , {STR0186})	//"Entre em contato com o usuário ou tente novamente."
					EndIf
					Exit
				EndIf
				SG1->(DbSkip())
			EndDo

		ElseIf !Empty(cProduto)                                  //Produtos SEM estrutura na SG1 - LockByName
			lReturn := ::LockNew(fAjustaStr(cProduto))
			If lHelp .AND. !lReturn .And. ::oBlqOther:hasProperty(cProduto)
				//Esta estrutura 'X' está bloqueada para o usuário: Y
				Help( ,  , "Help", ,  STR0184 + AllTrim(cProduto) + STR0185 + ::oBlqOther[cProduto][1] + scCRLF + scCRLF + " [" + ::oBlqOther[cProduto][2] + "]";
					, 1, 0, , , , , , {STR0186})	//"Entre em contato com o usuário ou tente novamente."
			EndIf

		EndIf
	EndIf

	If lReturn .AND. ::oBlqOther[cProduto] != Nil                //Avalia necessidade de Refresh da Grid
		If lHelp
			If lReload
				lReturn := .F.
				//Houve bloqueio da estrutura 'X' pelo usuário: Y
				Help( ,  , "Help", ,  STR0187 + AllTrim(cProduto) + STR0188 + ::oBlqOther[cProduto][1] + " [" + ::oBlqOther[cProduto][2] + "]" + scCRLF + scCRLF + STR0199 ,; //"A estrutura será atualizada automaticamente."
					1, 0, , , , , , {STR0189})	//"Tente novamente."
				P200Reload()
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
	EndIf

	If lForcaHelp                                                //Desabilita a apresentacao do Help
		HelpInDark(.T.)
		oView:GetModel():GetErrorMessage(.T.)                    //Limpa help do modelo

	ElseIf !lHelp .AND. oView != Nil .AND. oView:isActive() .And. oView:HasError()
		oView:GetModel():GetErrorMessage(.T.)                    //Limpa help do modelo

	ElseIf oView == Nil
		oModel := FwModelActive()
		If oModel != Nil .AND. oModel:HasErrorMessage()
			oModel:GetErrorMessage(.T.)
		EndIf

	EndIf

	RestArea(aAreaSG1)
Return lReturn

/*/{Protheus.doc} UnLock
Libera os Recnos de componentes bloqueados
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto   , caracter, codigo do produto pai
@param 02 - lProtegeSG1, logico  , indica se deve realizar protecao de alias da SG1
/*/
METHOD UnLock(cProduto, lProtegeSG1) CLASS PCPA200EVDEF

	Local aAreaSG1
	Local aLocksPai
	Local nIndRec       := 0
	Local nIndPai       := 0

	Default cProduto    := ""
	Default lProtegeSG1 := .T.

	If lProtegeSG1
		aAreaSG1      := SG1->(GetArea())
	EndIf

	SG1->(DbSetOrder(1))
	If Empty(cProduto)
		aLocksPai   := ::oRecno:GetNames()
		For nIndPai := 1 to Len(aLocksPai)                       //Loop pais alterados
			If !Empty(aLocksPai[nIndPai])
				::UnLock(aLocksPai[nIndPai], .F.)
			EndIf
		Next

	Else
		If ::oRecno != Nil .and. ::oRecno[cProduto] != Nil .and. ::oRecno[cProduto][1]                                 //Se esta bloqueado por esta Thread
			//Produtos SEM estrutura na SG1 - LockByName
			If !Empty(cProduto)
				lReturn := ::UnLockNew(cProduto)
			EndIf

			//Produtos COM estrutura na SG1 - SimpleLock
			For nIndRec := 1 to Len(::oRecno[cProduto][2])   //Loop componentes do pai
				SG1->(dbGoTo(::oRecno[cProduto][2][nIndRec]))
				SG1->(MsUnLock())
			Next
			aSize(::oRecno[cProduto][2], 0)
			::oRecno[cProduto][1] := .F.
		EndIf

	EndIf

	If lProtegeSG1
		RestArea(aAreaSG1)
	EndIf

Return

/*/{Protheus.doc} SG1UnLockR
Desbloqueia registros da SG1 - por Recno
@author brunno.costa
@since 11/04/2019
@version 1.0
@param 01 - nRecno  , numerico, recno a ser liberado, caso em branco, libera todos do objeto oRecNo
@param 02 - lProtege, logico  , indica se realiza protecao do alias SG1
@param 03 - oRecno  , objeto  , objeto Json com os recnos bloqueados
/*/
Function SG1UnLockR(nRecno, lProtege, oRecNo)
	Local aArea
	Local aAreaSG1
	Local nInd
	Local aLocks

	Default lProtege := .T.

	If lProtege
		aArea      := GetArea()
		aAreaSG1   := SG1->(GetArea())
	EndIf

	If nRecno == Nil
		oRecNo := Iif(oRecNo == Nil, JsonObject():New(), oRecNo)
		aLocks   := oRecNo:GetNames()
		For nInd := 1 to Len(aLocks)
			If oRecNo[aLocks[nInd]]						//Se RECNO flagado
				SG1UnLockR(Val(aLocks[nInd]), .F.)
			EndIf
		Next

	ElseIf nRecno > 0
		SG1->(dbGoTo(nRecno))
		SG1->(MsUnLock())

	EndIf

	If lProtege
		RestArea(aAreaSG1)
		RestArea(aArea)
	EndIf
Return

/*/{Protheus.doc} LockNew
Cria LockByName + TXT para bloquear inclusao de novas estruturas de produtos ou intermediarios
(Inexistem registros anteriores na SG1)
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto , caracter, codigo do produto
@return lReturn - indica se conseguiu bloquear
/*/
METHOD LockNew(cProduto) CLASS PCPA200EVDEF
	Local cFileName
	Local lReturn   := .T.
	Local nHandle
	Local cMsgError := ""

	sPrefLock := Iif(sPrefLock == Nil, GetPathSemaforo() + FWGrpCompany() + FWCodEmp() + FWCodFil() + "_PCPA200_PRD_" , sPrefLock)
	cFileName := Lower(sPrefLock + AllTrim(cProduto))

	If LockByName(cFileName, .F., .F., .T.)				//Conseguiu bloquear
		If File(cFileName + ".tmp", 0 ,.T.)
			If !apgArqTmp(cFileName + ".tmp")
				//"Falha na exclusao do arquivo '"
				Help( ,  , "Help", ,  STR0190 + cFileName + ".tmp'. (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0191}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
			Endif
		EndIf

		nHandle := fCreate(cFileName + ".tmp", FC_NORMAL)

		If nHandle == -1
			//"Falha na criação do arquivo '\RootPath\Semaforo\"
			Help( ,  , "Help", ,  STR0192 + cFileName + ".tmp': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
				, 1, 0, , , , , , {STR0191}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
			lReturn := .F.
		Else
			fWrite(nHandle, UsrRetName(RetCodUsr())  + "| " + FunName() + " - LockByName - ThreadID(" + cValToChar(ThreadID()) + ") (" + GetServerIP() + ":" + GetPvProfString( "tcp", "port", "1234", "appserver.ini") + ")")
			If fError() # 0
				//"Falha na escrita do arquivo '\RootPath\Semaforo\"
				Help( ,  , "Help", ,  STR0193 + cFileName + ".tmp': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0191}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
			EndIf
			::oRecNo[cProduto][1] := .T.
		EndIf
		fClose(nHandle)
	Else																					//NAO Conseguiu bloquear
		lReturn :=.F.
		nHandle := fOpen(cFileName + ".tmp")

		If nHandle == -1
			Help( ,  , "Help", , STR0253 + cFileName + ".tmp': " + Str(fError()) + " (" + ProcName() + " - " + cValToChar(ProcLine()) + ")"; // "Falha na leitura do arquivo '\RootPath\Semaforo\"
			    , 1, 0, , , , , , {STR0191}) //"Contate o departamento de TI e verifique as configurações de acesso do AppServer ao diretório '\RootPath\SEMAFORO\.'"
		Else
			fRead( nHandle, @cMsgError, 100 )
			If !Empty(cMsgError)
				::oBlqOther[cProduto] := StrTokArr(cMsgError,"|")
				If Empty(::oBlqOther[cProduto])
					::oBlqOther[cProduto] := Nil
				EndIf
			EndIf

			fClose(nHandle)
		EndIf
	EndIf

Return lReturn

/*/{Protheus.doc} UnLockNew
Elimina LockByName + TXT para liberar inclusao de novas estruturas de produtos ou intermediarios
(Inexistem registros anteriores na SG1)
@author brunno.costa
@since 08/04/2019
@version 1.0
@param 01 - cProduto, caracter, codigo do produto
/*/
METHOD UnLockNew(cProduto) CLASS PCPA200EVDEF
	Local cFileName

	sPrefLock := Iif(sPrefLock == Nil, GetPathSemaforo() + FWGrpCompany() + FWCodEmp() + FWCodFil() + "_PCPA200_PRD_" , sPrefLock)
	cFileName := Lower(sPrefLock + AllTrim(cProduto))

	If ::oRecNo[cProduto][1]											//Ha bloqueio realizado por esta Thread
		UnLockByName(cFileName, .F., .F., .T.)
		If File(cFileName + ".tmp", 0 ,.T.)
			If apgArqTmp(cFileName + ".tmp")
				::oRecNo[cProduto][1] := .F.
			Else
				//"Falha na exclusao do arquivo '"
				Help( ,  , "Help", ,  STR0190 + cFileName + ".tmp'. (" + ProcName() + " - " + cValToChar(ProcLine()) + ")";
					, 1, 0, , , , , , {STR0191}) //"Contate o departamento de TI e verifique as configurações de acesso ao diretório '\RootPath\SEMAFORO\.'"
			Endif
		Endif
	EndIf

Return

/*/{Protheus.doc} apgArqTmp
Apaga um arquivo TXT criado pelo lockNew
@type  Static Function
@author Lucas FAgundes
@since 17/05/2023
@version P12
@param cFileName, Caracter, Arquivo que será apagado.
@return lApagou, Logico, Indica se conseguiu apagar com sucesso o arquivo.
/*/
Static Function apgArqTmp(cFileName)
	Local lApagou    := .F.
	Local nHandle    := 0
	Local nMaxTrys   := 10
	Local nTentativa := 0
	
	While nTentativa < nMaxTrys .And. !lApagou
		nHandle := fErase(cFileName)
		
		lApagou := nHandle != -1
		If !lApagou
			nTentativa++
			LogMsg("PCPA200", 0, 0, 1, "", "", I18N(STR0252, {cFileName, FError(), cValToChar(nTentativa), nMaxTrys})) // "Não foi possivel apagar o arquivo #1[fileName]#. Código de erro: #2[errorCode]#. Tentativa #3[tentativa]#/#4[maxTentativas]#"
			Sleep(300)
		EndIf
	End

Return lApagou
