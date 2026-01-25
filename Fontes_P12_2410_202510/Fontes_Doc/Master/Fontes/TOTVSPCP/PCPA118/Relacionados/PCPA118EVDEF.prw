#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA118.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TbIconn.ch"

/*/{Protheus.doc} PCPA118EVDEF
Eventos padrões do cadastro de roteiros
@author Douglas Heydt
@since 25/04/2018
@version P12.1.17
/*/

Static lSoSelecionado		:= .F.
Static oModel118
Static aDiPCPA124			:= {}
Static aDivergencias		:= {}
Static aItensDivergencias	:= {}
Static aModelsSG2			:= {}
Static aOkRoteiros			:= {}
Static aRoteiros			:= {}
Static nButton				:= 0

CLASS PCPA118EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD Activate(oModel, lCopy)
	METHOD GridLinePosVld(oSubModel, cModelID)
	METHOD ModelPosVld(oSubModel, cModelId)
	METHOD BeforeTTS(oModel, cModelId)
	METHOD InTTS(oSubModel, cModelId)
	METHOD Destroy()
	METHOD VldActivate(oModel, cModelId)

ENDCLASS

METHOD New() CLASS  PCPA118EVDEF

Return

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author lucas.franca
@since 16/01/2019
@version P12
@return Nil
@param oModel, object , Modelo principal
@param lCopy , logical, Informa se o model deve carregar os dados do registro posicionado em operações de inclusão. Essa opção é usada quando é necessário fazer uma operação de cópia.
@type method
/*/
METHOD Activate(oModel, lCopy) CLASS PCPA118EVDEF
	Local lUniLin  := SuperGetMV("MV_UNILIN",.F.,.F.)

	If lUniLin .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		/*
			Limpa as informações de Linha Produção no cabeçalho quando MV_UNILIN = .T.
		*/

		oModel:ClearField("SMXMASTER","MX_LINHAPR")
		oModel:ClearField("SMXMASTER","MX_TPLINHA")
	EndIf
Return Nil

/*/{Protheus.doc} GridLinePosVld
Validacoes de linha padrao
@author Douglas Heydt
@since 03/05/2018
@version 1.0
@return .T.
/*/
METHOD GridLinePosVld(oModel, cID) CLASS PCPA118EVDEF
	Local lReturn	:= .T.
	Local lIntSfc 	:= ExisteSFC("SG2")
	Local nOpc    	:= oModel:GetOperation()

	If cID == "SVHDETAIL"
		If !oModel:IsDeleted()
			If Empty(oModel:GetValue("VH_TEMPAD"))
				Help(" ",1,"A630SEMTMP")
				lReturn := .F.
			EndIf
			If lReturn .And. Empty(oModel:GetValue("VH_OPERAC"))
				Help(" ",1,"A630VZ")
				lReturn := .F.
			EndIf
			If lReturn .And. Empty(oModel:GetValue("VH_TEMPSOB"))
				If !Empty(oModel:GetValue("VH_TPSOBRE"))
					If oModel:GetValue("VH_TPSOBRE") != "1" .Or. (oModel:GetValue("VH_TPSOBRE") == "1" .And. SuperGetMV("MV_APS",.F.,"") == "TOTVS")
						Help(" ",1,"A124TIPSOB")
						lReturn := .F.
					EndIf
				EndIf
			EndIf
			If lReturn .And. Empty(oModel:GetValue("VH_TPSOBRE"))
				If !Empty( oModel:GetValue("VH_TEMPSOB"))
					Help(" ",1,"A124TMPSOB")
					lReturn := .F.
				EndIf
			EndIf
			If lReturn .And. Empty(oModel:GetValue("VH_TEMPDES"))
				If !Empty( oModel:GetValue("VH_TPDESD"))
					Help(" ",1,"A124TIPDES")
					lReturn := .F.
				EndIf
			EndIf
			If lReturn .And. Empty(oModel:GetValue("VH_TPDESD"))
				If !Empty( oModel:GetValue("VH_TEMPDES"))
					Help(" ",1,"A124TMPDES")
					lReturn := .F.
				EndIf
			EndIf
			If lReturn .And. (TipoAps(.F.,"DRUMMER") .Or. SuperGetMV("MV_APS",.F.,"") == "TOTVS" .Or. IntegraSFC()) .And. Empty(oModel:GetValue("VH_CTRAB"))
				Help(" ",1,"OBRIGAT2",,RetTitle("VH_CTRAB"),04,01) // OBRIGAT2 - Um ou alguns campos obrigatorios não foram preenchidos no objeto Grid.
				lReturn := .F.
			EndIf

			If lReturn .And. lIntSfc .AND. (nOpc == 3 .OR. nOpc == 4)
				// Validar se a máquina informada pertence ao CT da operação
				SH1->(dbSetOrder(1))
				If SH1->(dbSeek(xFilial("SH1")+oModel:GetValue('VH_RECURSO'))) .And. AllTrim(SH1->H1_CTRAB) != AllTrim(oModel:GetValue("VH_CTRAB"))
					Help(" ",1,"A124RECCT") // A124RECCT - O recurso informado não pertence ao centro de trabalho da operação.
					lReturn := .F.
				EndIf
			EndIf

			If lReturn .And. oModel:GetValue("VH_TPLINHA") == "D"
				If !SuperGetMV("MV_UNILIN",.F.,.F.) .And. oModel:nLine # 1
					If Empty(oModel:GetValue("VH_LINHAPR",oModel:nLine - 1))
						//A124TPLIND - Quando o Campo Tipo de Linha estiver preenchido com Dependente, é obrigatório preenchimento do Campo Linha de Produção da Operação anterior.
						Help(" ",1,"A124TPLIND")
						lReturn := .F.
					EndIf
				ElseIf Empty(oModel:GetValue("VH_LINHAPR"))
					//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
					Help(" ",1,"A124TPLINO")
					lReturn := .F.
				EndIf
				If Empty(oModel:GetValue("VH_LINHAPR"))
					//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
					Help(" ",1,"A124TPLINO")
					lReturn := .F.
				EndIf
			ElseIf lReturn .And. oModel:GetValue("VH_TPLINHA") $ "OP"
				If Empty(oModel:GetValue("VH_LINHAPR"))
					//A124TPLINO - Para que o Tipo de Linha seja Obrigatório, Preferencial ou Dependente é necessário realizar o preenchimento do campo Linha de Produção.
					Help(" ",1,"A124TPLINO")
					lReturn := .F.
				EndIf
			EndIf

			If lReturn .And. !Empty(oModel:GetValue("VH_TPALOCF")) .And. Empty(oModel:GetValue("VH_FERRAM"))
				Help(,,"Help",,STR0056,; //"O campo ferramenta não foi informado."
				     1,0,,,,,,{STR0057}) //"Quando o tipo de alocação da ferramenta estiver preenchido, o código da ferramenta é obrigatório. Informe o código da ferramenta ou altere o valor do campo Tipo Alocação Ferramenta."
				lReturn := .F.
			EndIf

			//Faz a validação das horas informadas
			If lReturn .And. !Empty(oModel:GetValue("VH_TEMPSOB")) .And. !A118Tempo(oModel:GetValue("VH_TEMPSOB"),"VH_TEMPSOB")
				lReturn := .F.
			EndIf
			If lReturn .And. !Empty(oModel:GetValue("VH_TEMPDES")) .And. !A118Tempo(oModel:GetValue("VH_TEMPDES"),"VH_TEMPDES")
				lReturn := .F.
			EndIf
			If lReturn .And. !Empty(oModel:GetValue("VH_TEMPAD")) .And. !A118Tempo(oModel:GetValue("VH_TEMPAD"),"VH_TEMPAD")
				lReturn := .F.
			EndIf
			If lReturn .And. !Empty(oModel:GetValue("VH_SETUP")) .And. !A118Tempo(oModel:GetValue("VH_SETUP"),"VH_SETUP")
				lReturn := .F.
			EndIf
			If lReturn .And. !Empty(oModel:GetValue("VH_TEMPEND")) .And. !A118Tempo(oModel:GetValue("VH_TEMPEND"),"VH_TEMPEND")
				lReturn := .F.
			EndIf
		Else
			If lReturn .And. oModel:GetValue("VH_TPLINHA") != "D"
				If oModel:GetLine()+1 <= oModel:Length()
					If oModel:GetValue("VH_TPLINHA",(oModel:GetLine()+1)) == "D"
						Help( ,  , "Help", ,  STR0058,; //"Quando o Tipo de Linha da operação for do tipo Dependente, é necessário que a operação anterior possua linha de produção informada."
						     1, 0, , , , , , {STR0059}) //"Verifique se a operação anterior possui Linha de Produção informado, ou altere o Tipo de Linha de Dependente para outro tipo."
						lReturn := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return lReturn


/*/{Protheus.doc} ModelPosVld
Método de pós validação do modelo de dados
@author lucas.franca
@since 19/06/2018
@version 1.0

@param oModel	- Modelo de dados que será validado
@param cModelId	- ID do modelo de dados que está sendo validado.

@return lReturn	- Indica se o modelo foi validado com sucesso.
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS PCPA118EVDEF

	Local lReturn   := .T.
	Local lIntSfc   := ExisteSFC("SG2")
	Local lUniLin   := SuperGetMV("MV_UNILIN",.F.,.F.)
	Local cKey      := ""
	Local nOpc      := oModel:GetOperation()
	Local nI        := 0
	Local nJ        := 0
	Local nLineVH   := 0
	Local nLineMY   := 0
	Local cCodLista
	Local oModelSMX := oModel:GetModel("SMXMASTER")
	Local oModelSVH := oModel:GetModel("SVHDETAIL")
	Local oModelSMY := oModel:GetModel("SMYDETAIL_R")
	Local nMVPCPRLPP:= SuperGetMV("MV_PCPRLPP", .F., 2)

	If cModelId == "PCPA118"
		oModel118 := Iif(oModel118 == Nil, FwModelActive(), oModel118)
	EndIf

	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
		For nI := 1 To oModelSVH:Length()
			oModelSVH:GoLine(nI)
			lReturn := ::GridLinePosVld(oModelSVH, oModelSVH:GetId())
			If !lReturn
				Exit
			EndIf
		Next nI

		//Quando MV_UNILIN = .T., faz a validação do Linha Produção que está no cabeçalho.
		If lUniLin .And. lReturn
			lReturn := A118TpLin()
		EndIf
	EndIf

	If nOpc == 5 .And. lReturn
		cCodLista :=  oModelSMX:GetValue("MX_CODIGO")
		If PCPA118Lis(cCodLista)
			Help( Nil, Nil, "A118EXCLU" , Nil, STR0054, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0055})
			lReturn := .F.
		EndIf
	EndIf

	If lReturn .And. lIntSfc .AND. (nOpc == 3 .OR. nOpc == 4)
		//Guarda as linhas posicionadas atualmente para reposicionar após a validação
		nLineVH := oModelSVH:GetLine()
		nLineMY := oModelSMY:GetLine()

		// Validar os recursos alternativos e secundários. Devem possuir o mesmo CT da operação.
		For nI := 1 To oModelSVH:GetQtdLine()
			//Se já encontrou erro em outro registro, sai do loop.
			If !lReturn
				Exit
			EndIf

			oModelSVH:GoLine(nI)

			If !oModelSVH:IsDeleted()
				//Busca todos os recursos alternativos/secundários relacionados à operação
				For nJ := 1 to oModelSMY:GetQtdLine()
					oModelSMY:GoLine(nJ)

					If !oModelSMY:IsDeleted() .And. !Empty(oModelSMY:GetValue('MY_RECALTE'))
						SH1->(dbSetOrder(1))
						If SH1->(dbSeek(xFilial("SH1")+oModelSMY:GetValue('MY_RECALTE'))) .And. SH1->H1_CTRAB != oModelSVH:GetValue("VH_CTRAB")
							cKey := " " + STR0016 + " " //Operação:
							cKey += AllTrim(oModelSVH:GetValue("VH_OPERAC"))
							cKey += " " + STR0017 + " " //"Recurso alternativo/secundário: "
							cKey += AllTrim(oModelSMY:GetValue('MY_RECALTE')) + "."

							Help(" ",1,"A124RECCT",,cKey,04,01) //O recurso informado não pertence ao centro de trabalho da operação.
							lReturn := .F.
							Exit
						EndIf
					EndIf
				Next nJ
			EndIf
		Next nI
		//Reposiciona o modelo nas linhas selecionadas antes de fazer a validação
		oModelSVH:GoLine(nLineVH)
		oModelSMY:GoLine(nLineMY)
	EndIf

	If lReturn .AND. cModelId == "PCPA118" .AND. nMVPCPRLPP == 1 .AND. oModel118:GetOperation() != MODEL_OPERATION_INSERT .AND. oModel:GetModel("SMXMASTER"):GetValue("ValidDivergencias")
		//Atualiza Roteiro de Operações conforme alterações da Lista
		lReturn := ValidaSG2(1)
	EndIf

Return lReturn

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author lucas.franca
@since 16/01/2019
@version P12
@return Nil
@param oModel  , object, modelo
@param cModelId, characters, id do Modelo
@type method
/*/
METHOD BeforeTTS(oModel, cModelId) CLASS PCPA118EVDEF
	Local lUniLin   := SuperGetMV("MV_UNILIN",.F.,.F.)
	Local nIndex    := 0
	Local cLinhaPr  := ""
	Local cTpLinha  := ""
	Local oModelSVH := oModel:GetModel("SVHDETAIL")

	If lUniLin .And. oModel:GetOperation() != MODEL_OPERATION_DELETE
		/*
			Carrega as informações de linha de produção
			no modelo da SVH quando o parâmetro MV_UNILIN = .T.
		*/
		cLinhaPr := oModel:GetModel("SMXMASTER"):GetValue("MX_LINHAPR")
		cTpLinha := oModel:GetModel("SMXMASTER"):GetValue("MX_TPLINHA")
		For nIndex := 1 To oModelSVH:Length()
			oModelSVH:GoLine(nIndex)
			oModelSVH:LoadValue("VH_LINHAPR",cLinhaPr)
			oModelSVH:LoadValue("VH_TPLINHA",cTpLinha)
		Next nIndex
	EndIf

Return Nil

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author brunno.costa
@since 13/06/2018
@version 6
@return .T.
@param oSubModel, object, modelo
@param cModelId, characters, id do Modelo
@type function
/*/

METHOD InTTS(oSubModel, cModelId) CLASS PCPA118EVDEF
	Local nIndRot	:= 0

	For nIndRot := 1 to Len(aRoteiros)
		If aRoteiros[nIndRot][3]
			FwFormCommit(aModelsSG2[nIndRot][3])
		EndIf
	Next nIndRot

	//Avalia necessidade de limpeza do campo G2_LISTA e limpa.
	LimpG2LIST(oSubModel:GetModel("SVHDETAIL"):GetValue("VH_CODIGO",1))
Return

/*/{Protheus.doc} Destroy
Destrutor da classe
Caso o evento utilize atributos como array,objetos é boa prática o desenvolvedor
limpar esses atributos da memória.
@author brunno.costa
@since 13/06/2018
@version 6
@return .T.
@param oSubModel, object, modelo
@param cModelId, characters, id do Modelo
@type function
/*/

METHOD Destroy() CLASS PCPA118EVDEF
	DestroyObj(1, "")
	oModel118	:= Nil
Return

/*/{Protheus.doc} ValidaSG2
Validação dos registros divergentes para exibição de tela - SG2 x SH3
@author brunno.costa
@since 14/06/2018
@version 6
@param nOpc, logic
1 - ModelPosVld
2 - UpdRoteiro
3 - Revisa Lista
4 - Visualiza Replicado (1) - Visualiza como ficará o roteiro COM divergências replicado.
5 -  Visualiza Replicado (1) - Visualiza como ficará o roteiro SEM divergências replicado.
@return lReturn, logic, lógico se prossegue com a gravação ou retorna para exibição da lista

@type function
/*/

Static Function ValidaSG2(nOpc)

	Local aArea 		:= GetArea()
	Local aFieldsSVH	:= oModel118:GetModel("NOK_OLD_SVH"):oFormModelStruct:aFields
	Local cOperacao		:= ""
	Local cLista
	Local nIndSVH		:= 0
	Local nIndRot		:= 0
	Local nIndCps		:= 0
	Local nIndSG2		:= 0
	Local nRecDivAux	:= 0
	Local nRecSG2		:= 0
	Local nRecno		:= 0
	Local oModelSVH		:= oModel118:GetModel("SVHDETAIL")
	Local oModelSMX		:= oModel118:GetModel("SMXMASTER")
	Local oNovoCont		:= ""
	Local oModelSG2
	Local lErrorSVH		:= .F.
	Local lReturn		:= .T.
	Local lTodosLista	:= .T.
	Local lUpdate		:= oModel118:GetOperation() == MODEL_OPERATION_UPDATE
	Local lUpdate124	:= .F.
	Local lDelete		:= oModel118:GetOperation() == MODEL_OPERATION_DELETE
	Local lUniLin		:= SuperGetMV("MV_UNILIN",.F.,.F.)
	Local lPergunta		:= .F.

	cLista	:= oModelSVH:GetValue("VH_CODIGO",1)
	DestroyObj(2, cLista)

	DbSelectArea("SG2")
	SG2->(DbSetOrder(1))

	For nIndRot := 1  to Len(aRoteiros)
		lTodosLista	:= .T.
		SG2->(DbSeek(xFilial("SG2")+aRoteiros[nIndRot][2]+aRoteiros[nIndRot][1]))
		nRecSG2 := SG2->(Recno())
		//Cria Modelo para Validação Padrão da PCPA124
		aAdd(aModelsSG2, {SG2->G2_CODIGO, SG2->G2_PRODUTO, FWLoadModel( 'PCPA124' )})
		If lDelete
			While xFilial("SG2")+aRoteiros[nIndRot][2]+aRoteiros[nIndRot][1] == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) .AND. SG2->(!Eof())
				If SG2->G2_LISTA != cLista
					lTodosLista	:= .F.
				EndIf
				SG2->(DbSkip())
			EndDo
			SG2->(DbGoTo(nRecSG2))
			If lTodosLista
				aModelsSG2[nIndRot][3]:SetOperation(MODEL_OPERATION_DELETE)
				lUpdate124	:= .F.
			Else
				aModelsSG2[nIndRot][3]:SetOperation(MODEL_OPERATION_UPDATE)
				lUpdate124	:= .T.
			EndIf
		Else
			aModelsSG2[nIndRot][3]:SetOperation(MODEL_OPERATION_UPDATE)
			lUpdate124	:= .T.
		EndIf
		aModelsSG2[nIndRot][3]:Activate()
		oModelSG2	:= aModelsSG2[nIndRot][3]:GetModel("PCPA124_SG2")

		//Validação em Loop da SVH
		For nIndSVH := 1 to oModelSVH:Length()
			nRecDivAux	:= 0
			lErrorSVH	:= .F.
			oModelSVH:GoLine(nIndSVH)
			SVH->(DbGoTo(oModelSVH:GetDataId(nIndSVH)))
			cOperacao	:= oModelSVH:GetValue("VH_OPERAC",nIndSVH)

			//Se uma linha foi inserida e excluída na mesma operação, desconsidera.
			If oModelSVH:IsInserted(nIndSVH) .And. oModelSVH:IsDeleted(nIndSVH)
				Loop
			EndIf

			//Validação de Registro Deletado
			If  lUpdate .OR. lUpdate124
				If oModelSVH:IsDeleted(nIndSVH) .AND. !SVH->(Eof()) .OR. lDelete
					If oModelSG2:SeekLine( {{"G2_OPERAC", SVH->VH_OPERAC}, {"G2_LISTA",cLista}}, .T. )
						nRecDivAux	:= oModelSG2:GetDataID(oModelSG2:nLine)
						If !oModelSG2:DeleteLine()
							lErrorSVH	:= .T.
							UpdDiverge(1, nIndSVH, nIndRot, cLista, oModelSVH, oModelSG2, 0)
						EndIf
					EndIf

				Else
					//Validação de Registro Alterado ou Inclusão de Operação Nova
					If oModelSVH:IsInserted(nIndSVH)
						If oModelSG2:SeekLine( {{"G2_OPERAC", cOperacao}}, .T. )
							nRecDivAux	:= oModelSG2:GetDataID(oModelSG2:nLine)
						EndIf
						oModelSG2:AddLine()
					ElseIf !oModelSG2:SeekLine( {{"G2_OPERAC", SVH->VH_OPERAC}, {"G2_LISTA",cLista}}, .T. );
					.AND. !oModelSG2:SeekLine( {{"G2_OPERAC", cOperacao}, {"G2_LISTA",cLista}}, .T. )
						If oModelSG2:SeekLine( {{"G2_OPERAC", cOperacao }}, .T. )
							nRecDivAux	:= oModelSG2:GetDataID(oModelSG2:nLine)
						Else
							If oModelSG2:SeekLine( {{"G2_OPERAC", SVH->VH_OPERAC }}, .T. )
								nRecDivAux	:= oModelSG2:GetDataID(oModelSG2:nLine)
							EndIf
						EndIf
						oModelSG2:AddLine()
					Else
						oModelSG2:SeekLine( {{"G2_OPERAC", SVH->VH_OPERAC}, {"G2_LISTA", cLista}}, .T. )
					EndIf

					//Atualização dos campos
					For nIndCps := 1 to Len(aFieldsSVH)
						If !("|"+AllTrim(aFieldsSVH[nIndCps][3])+"|" $ "|VH_FILIAL|VH_ROTEIRO|VH_PRODUTO|RECNO|_FALHA|VH_ROTALT|")
							oNovoCont	:= oModelSVH:GetValue(aFieldsSVH[nIndCps][3], nIndSVH)
							If ValType(oNovoCont) == "C"
								oNovoCont := AllTrim(oNovoCont)
							EndIf
							If aFieldsSVH[nIndCps][3] == "VH_CODIGO"
								oModelSG2:LoadValue(CampoSG2(aFieldsSVH[nIndCps][3]), cLista)
							Else
								oModelSG2:LoadValue(CampoSG2(aFieldsSVH[nIndCps][3]), oNovoCont)
							EndIf
						EndIf
					Next nIndCps

					If !oModelSG2:VldLineData()
						lErrorSVH	:= .T.
						UpdDiverge(1, nIndSVH, nIndRot, cLista, oModelSVH, oModelSG2, nRecDivAux)
						oModelSG2:DeleteLine()
					EndIf

					If !lErrorSVH
						//Valida Recursos
						ValidaSH3(1, xFilial("SH3")+aRoteiros[nIndRot][2]+aRoteiros[nIndRot][1], nIndRot, oModelSG2:nLine, nIndSVH, oModelSG2, oModelSVH, cLista)

						//Valida Ferramentas
						ValidaSH3(2, xFilial("SH3")+aRoteiros[nIndRot][2]+aRoteiros[nIndRot][1], nIndRot, oModelSG2:nLine, nIndSVH, oModelSG2, oModelSVH, cLista)
					EndIf
				EndIf
			EndIf

		Next nIndSVH

		If aRoteiros[nIndRot][3] .OR. lDelete
			//Exclusão Itens da SG2 Inexistentes na Lista
			For nIndSG2 := 1 to oModelSG2:GetQTDLine()
				If cLista == oModelSG2:GetValue("G2_LISTA",nIndSG2)
					cOperacao	:= oModelSG2:GetValue("G2_OPERAC",nIndSG2)
					If !oModelSVH:SeekLine( {{"VH_OPERAC",cOperacao}}, .T. ) .OR. oModelSVH:IsDeleted()
						oModelSG2:GoLine(nIndSG2)
						If !oModelSG2:IsDeleted() .AND. aModelsSG2[nIndRot][3]:GetOperation() == MODEL_OPERATION_UPDATE
							If !oModelSG2:DeleteLine()
								UpdDiverge(2, oModelSVH:nLine, nIndRot, cLista, oModelSVH, oModelSG2, 0)
							EndIf
						EndIf
					Endif
				Endif
			Next nIndSG2

			//Validação de todo o Model da PCPA124
			If !aModelsSG2[nIndRot][3]:VldData()
				UpdDiverge(3, 1, nIndRot, cLista, oModelSVH, oModelSG2, 0)
			ElseIf lUniLin
				//Se utiliza a Linha Produção única para todo o roteiro, verifica se será possível alterar.
				lPergunta := .F.
				//Pega um RECNO da SG2 que possua esta lista.
				nRecno := 0
				For nIndSG2 := 1 To oModelSG2:Length()
					If oModelSG2:IsDeleted(nIndSG2)
						Loop
					EndIf
					If oModelSG2:GetValue("G2_LISTA",nIndSG2) == cLista
						nRecno := oModelSG2:GetDataID(nIndSG2)
						Exit
					EndIf
				Next nIndSG2

				For nIndSG2 := 1 To oModelSG2:Length()
					If oModelSG2:IsDeleted(nIndSG2)
						Loop
					EndIf
					If !Empty(oModelSG2:GetValue("G2_LISTA",nIndSG2)) .And. ;
					   (oModelSG2:GetValue("G2_LINHAPR",nIndSG2) != oModelSMX:GetValue("MX_LINHAPR") .Or. ;
						oModelSG2:GetValue("G2_TPLINHA",nIndSG2) != oModelSMX:GetValue("MX_TPLINHA"))
						//Verifica se existe operação de outra lista com o LINHA PRODUÇÃO/TIPO LINHA diferentes.
						cHelp := STR0060 //"Existem outras listas neste roteiro que possuem Linha Produção/Tipo Linha diferentes do que foi informado nesta lista de operações. Não será possível realizar a réplica das operações."
						oModelSG2:GetModel():SetErrorMessage("PCPA124_CAB","G2_LINHAPR","PCPA124_CAB","G2_LINHAPR","",cHelp,"","","")
						UpdDiverge(3, 1, nIndRot, cLista, oModelSVH, oModelSG2, 0, nRecno)
					ElseIf Empty(oModelSG2:GetValue("G2_LISTA",nIndSG2)) .And. ;
					   (oModelSG2:GetValue("G2_LINHAPR",nIndSG2) != oModelSMX:GetValue("MX_LINHAPR") .Or. ;
						oModelSG2:GetValue("G2_TPLINHA",nIndSG2) != oModelSMX:GetValue("MX_TPLINHA"))
						//Verifica se existe operações incluídas manualmente com o LINHA PRODUÇÃO/TIPO LINHA diferentes.
						lPergunta := .T.
					EndIf
				Next nIndSG2
				If lPergunta .And. aRoteiros[nIndRot][3]
					If !ApMsgYesNo(STR0061 + AllTrim(cLista) + STR0062,STR0063) //"A réplica da lista " ### " irá alterar a Linha de Produção/Tipo Linha de operações incluídas manualmente. Confirma a réplica?" //"Réplica"
						cHelp := STR0064 //"Existem outras operações neste roteiro que possuem Linha Produção/Tipo Linha diferentes do que foi informado nesta lista de operações. Não será possível realizar a réplica das operações."
						oModelSG2:GetModel():SetErrorMessage("PCPA124_CAB","G2_LINHAPR","PCPA124_CAB","G2_LINHAPR","",cHelp,"","","")
						UpdDiverge(3, 1, nIndRot, cLista, oModelSVH, oModelSG2, 0, nRecno)
					EndIf
				EndIf
				If aRoteiros[nIndRot][3]
					//Se validou corretamente, seta as informações da Linha de Produção e Tipo Linha no modelo.
					oModelSG2:GetModel():GetModel("PCPA124_CAB"):LoadValue("G2_LINHAPR",oModelSMX:GetValue("MX_LINHAPR"))
					oModelSG2:GetModel():GetModel("PCPA124_CAB"):LoadValue("G2_TPLINHA",oModelSMX:GetValue("MX_TPLINHA"))
				EndIf
			EndIf
		Endif

		//Reordena oModelSG2
		If !aRoteiros[nIndRot][3]
			For nIndSG2 := 1 to oModelSG2:Length()
				oModelSG2:GoLine(nIndSG2)
				If (nIndSG2 + 1 <= oModelSG2:Length()) .AND. oModelSG2:GetValue("G2_OPERAC", nIndSG2) > oModelSG2:GetValue("G2_OPERAC", nIndSG2 + 1)
					oModelSG2:LineShift( nIndSG2, nIndSG2 + 1 )
					nIndSG2 := 0
				EndIf
			Next nIndSG2
		EndIf

	Next nIndRot

	For nIndRot := 1  to Len(aRoteiros)
		If aRoteiros[nIndRot][3]
			aAdd(aOkRoteiros,{0,{aRoteiros[nIndRot][1], aRoteiros[nIndRot][2], Posicione("SB1",1,xFilial("SB1")+aRoteiros[nIndRot][2],"B1_DESC")}})
		EndIf
	Next nIndRot

	lReturn	:= ViewDiverg(oModel118, nOpc, Len(aDivergencias) > 0 .OR. nOpc == 2)	//Se possui divergências ou acabou de sair de edição do Roteiro

	RestArea(aArea)
Return lReturn


/*/{Protheus.doc} ValidaSH3
Validação dos registros divergentes para exibição de tela - SH3
@author brunno.costa
@since 10/07/2018
@version 6
@return NIL
@param nOrdSH3, numeric, ordem da tabela SH3, indica 1 para Recurso e 2 para Ferramenta
@param cChaveSH3, characters, chave de posicionamento na SH3
@param nIndRot, numeric, linha do array aRoteiros
@param nIndSG2, numeric, indica qual a linha do modelo da SG2 avaliada no momento
@param nIndSVH, numeric, indica qual a linha do modelo da SVH avaliada no momento
@param oModelSG2, object, objego da SG2
@param oModelSVH, object, objeto da SVH
@param cLista, characters, lista atual
@type function
/*/

Static Function ValidaSH3(nOrdSH3, cChaveSH3, nIndRot, nIndSG2, nIndSVH, oModelSG2, oModelSVH, cLista)

	Local aArea 		:= GetArea()
	Local aCampos
	Local cColPK
	Local cPK
	Local nIndCps		:= 0
	Local nIndSMY		:= 0
	Local nIndSH3		:= 0
	Local oNovoCont		:= ""
	Local oModelSMY
	Local oModelSH3

	/*DbSelectArea("SH3")
	SH3->(DbSetOrder(nOrdSH3))
	SH3->(DbSeek(cChaveSH3))*/

	If nOrdSH3 == 1		//Recurso
		oModelSMY	:= oModel118:GetModel("SMYDETAIL_R")
		oModelSH3	:= aModelsSG2[nIndRot][3]:GetModel("PCPA124_SH3_R")
		cColPK		:= "MY_RECALTE"
		aCampos		:= {"MY_RECALTE","MY_TIPO","MY_EFICIEN"}

	ElseIf nOrdSH3 == 2	//Ferramenta
		oModelSMY	:= oModel118:GetModel("SMYDETAIL_F")
		oModelSH3	:= aModelsSG2[nIndRot][3]:GetModel("PCPA124_SH3_F")
		cColPK		:= "MY_FERRAM"
		aCampos		:= {"MY_FERRAM"}
	EndIf

	//Validação em Loop da SVH
	For nIndSMY := 1 to oModelSMY:Length()
		oModelSMY:GoLine(nIndSMY)
		SMY->(DbGoTo(oModelSMY:GetDataId(nIndSMY)))
		cPK	:= oModelSMY:GetValue(cColPK, nIndSMY)

		If !Empty(cPK)
			//Validação de Registro Deletado
			If oModelSMY:IsDeleted(nIndSMY) .AND. !SMY->(Eof())
				If oModelSH3:SeekLine( {{CampoSH3(cColPK), SMY->(&cColPK)}}, .T. )
					If !oModelSH3:DeleteLine()
						UpdDiverge(4, nIndSMY, nIndRot, cLista, oModelSVH, oModelSG2)
					EndIf
				EndIf

			Else
				//Validação de Registro Alterado ou Inclusão de Operação Nova
				If oModelSMY:IsInserted(nIndSMY)
					oModelSH3:AddLine()
				ElseIf !oModelSH3:SeekLine( {{CampoSH3(cColPK), SMY->(&cColPK)}}, .T. );
				.AND. !oModelSH3:SeekLine( {{CampoSH3(cColPK), cPK }}, .T. )
					oModelSH3:AddLine()
				Else
					oModelSH3:SeekLine( {{CampoSH3(cColPK), SMY->(&cColPK)}}, .T. )
				EndIf

				//Atualização dos campos
				For nIndCps := 1 to Len(aCampos)
					oNovoCont	:= oModelSMY:GetValue(aCampos[nIndCps], nIndSMY)
					If ValType(oNovoCont) == "C"
						oNovoCont := AllTrim(oNovoCont)
					EndIf
					oModelSH3:LoadValue(CampoSH3(aCampos[nIndCps]), oNovoCont)
				Next nIndCps

				If !Empty(oModelSH3:GetValue(CampoSH3(cColPK), oModelSH3:nLine));
				.AND. !oModelSH3:VldLineData()
					UpdDiverge(4, nIndSMY, nIndRot, cLista, oModelSVH, oModelSG2)
				EndIf
			EndIf
		EndIf

	Next nIndSMY

	If aRoteiros[nIndRot][3]
		//Exclusão Itens da SH3 Inexistentes na Lista
		For nIndSH3 := 1 to oModelSH3:GetQTDLine()
			cPK	:= oModelSH3:GetValue(CampoSH3(cColPK), nIndSH3)
			If !Empty(cPK) .AND. (!oModelSMY:SeekLine( {{cColPK, cPK}}, .T. ) .OR. oModelSMY:IsDeleted())
				oModelSH3:GoLine(nIndSH3)
				If !oModelSH3:IsDeleted()
					If !oModelSH3:DeleteLine()
						UpdDiverge(5, nIndSMY, nIndRot, cLista, oModelSVH, oModelSH3)
					EndIf
				EndIf
			Endif
		Next nIndSH3

	Endif

	RestArea(aArea)
Return

/*/{Protheus.doc} UpdDiverge
Atualização dos Array's de controle de divergências
@author brunno.costa
@since 09/07/2018
@version 6
@return NIL
@param nOpc, numeric,
1 - Validação de Linha SG2
2 - Exclusão Itens da SG2 Inexistentes na Lista
3 - Validação de todo o modelo da PCPA124
@param nInd118, numeric, linha do model oModel118
@param nIndRot, numeric, linha do array aRoteiros
@param cLista, characters, código da lista atual
@param oModel118, object, modelo de dados da SVH - PCPA118,
@param oModel124, object, modelo de dados da SG2 - PCPA124,
@param nRecDivAux, numeric,  recno auxiliar para cadastramento de falha
@param nRecSG2   , numeric, Recno da SG2.
@type function
/*/

Static Function UpdDiverge(nOpc, nIndSVH, nIndRot, cLista, oModelSVH, oModelSG2, nRecDivAux, nRecSG2)

	Local nSG2Rec
	Local nIndLoc	:= 0
	Local lExiste	:= .F.
	Local nLinha	:= oModelSG2:nLine
	Local aError

	Default nRecDivAux := 0
	Default nRecSG2    := 0

	aDiPCPA124 := Iif(aDiPCPA124 == Nil,{},aDiPCPA124)

	If nOpc == 1 .OR. nOpc == 2 //Validações por Linha da PCPA124 - SG2
		nSG2Rec	:= oModelSG2:GetDataID(oModelSG2:nLine)
		nSG2Rec := Iif(nSG2Rec == 0, nRecDivAux, nSG2Rec)
		If aScan(aDiPCPA124,{|x| x[1] == nSG2Rec}) != 0
			lExiste	:= .T.
		EndIf

	ElseIf nOpc == 3//Validação de todo o modelo da PCPA124
		If nRecSG2 > 0
			nSG2Rec := nRecSG2
			If aScan(aDiPCPA124,{|x| x[1] == nSG2Rec}) != 0
				lExiste	:= .T.	//Existe falha em pelo menos uma linha
			EndIf
		Else
			For nIndLoc := 1 to oModelSG2:GetQtdLine()
				nSG2Rec	:= oModelSG2:GetDataID(nIndLoc)
				nSG2Rec := Iif(nSG2Rec == 0, nRecDivAux, nSG2Rec)
				If aScan(aDiPCPA124,{|x| x[1] == nSG2Rec}) != 0
					nIndRot	:= nIndLoc
					lExiste	:= .T.	//Existe falha em pelo menos uma linha
					Exit
				EndIf
			Next nIndLoc
		EndIf

	ElseIf nOpc == 4 .OR. nOpc == 5 //Validações por Linha da PCPA124 - SH3
		nSG2Rec	:= oModelSG2:GetDataID(oModelSG2:nLine)
		nSG2Rec := Iif(nSG2Rec == 0, nRecDivAux, nSG2Rec)
		If aScan(aDiPCPA124,{|x| x[1] == nSG2Rec}) != 0
			lExiste	:= .T.
		EndIf
	EndIf

	aError := aModelsSG2[nIndRot][3]:GetErrorMessage()
	If !Empty(aError)
		aAdd(aDiPCPA124,{nSG2Rec, aClone(aError)})

		//Se AINDA não existe falha no aDiPCPA124
		If (!lExiste .AND. nSG2Rec > 0)
			//Bloqueia chamada do FwFormCommit da PCPA124 para este modelo
			aRoteiros[nIndRot][3]	:= .F.

			If aScan(aItensDivergencias,{|x| x == nIndSVH}) == 0
				aAdd(aItensDivergencias,nIndSVH)
				aAdd(aDivergencias,{0,oModelSVH:aDataModel[nIndSVH][1][1]})
				aDivergencias[Len(aDivergencias)][2][2] := cLista
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} ViewDiverg
Função responsável por exibição de tela de divergências
@author brunno.costa
@since 14/06/2018
@version 6
@return lReturn, logic, lógico se deseja prosseguir mesmo assim ou retornar a tela de lista
@param oSubModel, object, modelo utilizado
@param nOpc, logic, 1 - ModelPosVld / 2 - UpdRoteiro / 3 - Operação inválida em confirmação da ViewDiverg
@param lExibe, logic, criado para contornar problema:
array out of bounds ( 1 of 0 )  on EXFORMCOMMIT(PROTHEUSFUNCTIONMVC.PRX) 08/06/2018 15:11:08 line : 2088
@type function
/*/

Static Function ViewDiverg(oSubModel, nOpc, lExibe)

	Local oViewPai		:= FWViewActive()
	Local aSaveLines 	:= FWSaveRows()
	Local oStruSVH		:= FWFormStruct( 2, 'SVH' ,{|cCampo| !("|"+AllTrim(cCampo)+"|" $ "|VH_ROTALT|")})
	Local oStruOldSVH	:= FWFormStruct( 2, 'SVH' )
	Local oStruSG2		:= FWFormStruct( 2, 'SG2' ,{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|G2_CODIGO|G2_PRODUTO|"})
	Local oView 		:= Nil
	Local oViewExec 	:= FWViewExec():New()
	Local oModelNEW		:= oModel118:GetModel("NOK_NEW_SVH")
	Local oModelOLD		:= oModel118:GetModel("NOK_OLD_SVH")
	Local oModelOk		:= oModel118:GetModel("OK_SG2")
	Local lReturn 		:= .T.
	Local lRoteiroOk	:= Len(aOkRoteiros) 	> 0
	Local lRoteiroNOk	:= Len(aDivergencias) 	> 0

	Default lExibe := .T.

	nButton			:= 0

	oStruSVH:RemoveField('VH_CODIGO')

	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel118)
	oView:SetOperation(1)
	//oView:SetOperation(4)

	A118AddCol(2, @oStruOldSVH)
	oStruOldSVH:SetProperty( "VH_CODIGO", MVC_VIEW_TITULO, RetTitle("G2_LISTA") )
	oStruOldSVH:SetProperty( "VH_CODIGO", MVC_VIEW_DESCR,  RetTitle("G2_LISTA") )

	//-- Campo descrição do produto
	oStruSG2:AddField("B1_DESC"	,;	// [01]  C   Nome do Campo
	"99"						,;	// [02]  C   Ordem
	STR0021						,;	// [03]  C   Titulo do campo	- "Descrição"
	STR0022						,;	// [04]  C   Descricao do campo	- "Descrição do Produto"
	NIL, "C", "", NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T., NIL, NIL)

	oView:AddGrid("V_NOK_NEW_SVH" 	, oStruSVH		, "NOK_NEW_SVH")
	oView:AddGrid("V_NOK_OLD_SVH" 	, oStruOldSVH	, "NOK_OLD_SVH")
	oView:AddGrid("V_OK_SG2" 		, oStruSG2		, "OK_SG2")

	oView:CreateHorizontalBox("BOX_GRID_L1",30)
	oView:CreateHorizontalBox("BOX_GRID_L2",7)
	oView:CreateHorizontalBox("BOX_GRID_L3",30)
	oView:CreateHorizontalBox("BOX_GRID_L4",3)
	oView:CreateHorizontalBox("BOX_GRID_L5",30)

	oView:AddOtherObject("V_CHECK", {|oPanel| MontaCheck(oPanel, oModel118, oView)})
	oView:SetOwnerView("NOK_NEW_SVH", 'BOX_GRID_L1')
	oView:SetOwnerView("V_CHECK" 	, 'BOX_GRID_L2')
	oView:SetOwnerView("NOK_OLD_SVH", 'BOX_GRID_L3')
	oView:SetOwnerView("OK_SG2"		, 'BOX_GRID_L5')

	oView:EnableTitleView("NOK_NEW_SVH"	, STR0011)	//Itens da Lista com Divergência
	oView:EnableTitleView("NOK_OLD_SVH"	, STR0012 + Iif(lRoteiroNOk	," (1)","") )	//Roteiros de Operação relacionados a divergência
	oView:EnableTitleView("OK_SG2"		, STR0023 + Iif(lRoteiroOk	," (2)","") )	//Roteiros sem divergências

	oModelNEW:SetNoDeleteLine( .F. )
	oModelOLD:SetNoDeleteLine( .F. )
	oModelOk:SetNoDeleteLine( .F. )

	oModelNEW:ClearData( .F., .T. )
	oModelNEW:DeActivate()
	oModelNEW:lForceLoad := .T.
	oModelNEW:Activate()

	oModelNEW:LineShift( 1, oModelNEW:Length() )
	oModelNEW:GoLine( oModelNEW:Length() )
	If oModel118:GetOperation() != MODEL_OPERATION_DELETE
		oModelNEW:DeleteLine( .T. )
	EndIf
	oModelNEW:GoLine( 1 )

	oModelOk:ClearData( .F., .T. )
	oModelOk:DeActivate()
	oModelOk:lForceLoad := .T.
	oModelOk:Activate()

	oModelOk:LineShift( 1, oModelOk:Length() )
	oModelOk:GoLine( oModelOk:Length() )
	If oModel118:GetOperation() != MODEL_OPERATION_DELETE
		oModelOk:DeleteLine( .T. )
	EndIf
	oModelOk:GoLine( 1 )

	//Proteção para execução com View ativa.
	If oModel118 != Nil .And. oModel118:isActive()
		If nOpc == 1 .AND. lExibe//Se chamado de ModelPosVld
			HelpInDark( .F. )	//Habilita a apresentação do Help
			//Help( Nil, Nil, STR0024, Nil, STR0025, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0026})
			Help( Nil, Nil, STR0024, Nil, STR0025, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0030})
			//DIVERGÊNCIAS!
			//Existem roteiros de processos produtivos que não poderão ser atualizados devido a existência de operações da lista no roteiro que não fazem parte desta lista.
			//Revise as operações desta lista ou dos roteiros relacionados.
			HelpInDark( .T. )	//Desabilita a apresentação do Help
		EndIf

		oView:GetViewObj("V_NOK_NEW_SVH")[3]:bChangeLine := {|| ChgNewSVH(oView, oModel118) }

		oViewExec:setModel(oModel118)
		oViewExec:setView(oView)
		oViewExec:setTitle(STR0015)
		oViewExec:setOperation(1)
		oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0013 /*"Confirmar"*/},{.T.,STR0014 /*"Cancelar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
		oViewExec:SetCloseOnOk({|| .t.})
		oView:AddUserButton(STR0027,"",{|| nButton := 1, oView:CloseOwner() }, STR0027,,,.T.)				//Retornar
		If lRoteiroNOk
			oView:AddUserButton(STR0032 + " (1)","",{|| nButton := 2, oView:CloseOwner() },STR0032,,,.T.)	//Editar Roteiro
			oView:AddUserButton(STR0036 + " (1)","",{|| nButton := 3, VisRoteiro(.F.) },STR0044,,,.T.)	//Visualiza Replicado (1) - Visualiza como ficará o roteiro COM divergências replicado.
		EndIf

		If lRoteiroOk
			oView:AddUserButton(STR0036 + " (2)","",{|| nButton := 4, VisRoteiro(.T.) },STR0045,,,.T.)	//Visualiza Replicado (2) - Visualiza como ficará o roteiro SEM divergências replicado.
		EndIf

		//Realiza Carga Inicial da Grid Old SG2
		LoadOldSG2(oView, oModel118)

		If lExibe

			oModelNEW:SetNoDeleteLine( .T. )
			oModelOLD:SetNoDeleteLine( .T. )
			oModelOk:SetNoDeleteLine( .T. )

			If !oModel118:GetModel("SMXMASTER"):GetValue("SemTela")
				//Abertura da View em tela
				oViewExec:openView(.F.)

				If cValToChar(nButton) $ "034"
					/*If lRoteiroOk .AND. lRoteiroNOk
					If lRoteiroNOk
					If ApMsgYesNo(STR0046,STR0047)	//"Você tem certeza que deseja replicar a lista somente para os roteiros sem divergências?" - "Replicar apenas em roteiros sem divergências?"
					nButton		:= 8
					lReturn 	:= .T.
					Else
					nButton		:= 9
					lReturn 	:= .F.
					//Help Exibido Após Retorno da Lista
					Help( Nil, Nil, STR0028, Nil, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0030})	//Revise a lista! - Existem roteiros de processos produtivos que não poderão ser atualizados devido a existência de operações da lista no roteiro que não fazem parte desta lista. - Revise as operações desta lista ou dos roteiros relacionados.
					EndIf
					EndIf
					DestroyVie(nButton, lExibe, oViewExec, oView)
					EndIf*/
					If lRoteiroNOk
						lReturn	:= .F.
						//DestroyVie(nButton, .F., oViewExec, oView)
						//Help Exibido Após Retorno da Lista
						Help( Nil, Nil, STR0028, Nil, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0030})	//Revise a lista! - Existem roteiros de processos produtivos que não poderão ser atualizados devido a existência de operações da lista no roteiro que não fazem parte desta lista. - Revise as operações desta lista ou dos roteiros relacionados.
					EndIf

				ElseIf nButton == 1	//Revisa Lista
					DestroyVie(nButton, lExibe, oViewExec, oView)

				ElseIf nButton == 2	//Update Roteiro
					UpdRoteiro(oModel118, oView)
					DestroyVie(nButton, lExibe, oViewExec, oView)
					lReturn     := ValidaSG2(2)
					lRoteiroOk	:= Len(aOkRoteiros) 	> 0
					lRoteiroNOk	:= Len(aDivergencias) 	> 0
					/*Caso necessário após visualização recriar a tela de divergências,
					descomentar as linhas abaixo e alterar bloco removendo a chamada da VisRoteiro após atribuir o nButton
					ElseIf nButton == 3	//Visualiza Replicado (1) - Visualiza como ficará o roteiro COM divergências replicado.
					VisRoteiro(oModel118, oView, .F.)
					DestroyVie(nButton, lExibe, oViewExec, oView)
					lReturn := ValidaSG2(4)
					ElseIf nButton == 4	//Visualiza Replicado (2) - Visualiza como ficará o roteiro SEM divergências replicado.
					VisRoteiro(oModel118, oView, .T.)
					DestroyVie(nButton, lExibe, oViewExec, oView)
					lReturn := ValidaSG2(5)*/

				Endif
			Else
				If !lRoteiroOk .AND. lRoteiroNOk
					lReturn	:= .F.
					Help( Nil, Nil, STR0037, Nil, STR0038, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0039})	// Operação Inválida! - Não existem roteiros aptos para replicação da lista. - Realize o tratamento das divergências antes de prosseguir.

				ElseIf lRoteiroOk .AND. lRoteiroNOk
					lReturn	:= .F.
					Help( Nil, Nil, STR0028, Nil, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0030})	//Revise a lista! - Existem roteiros de processos produtivos que não poderão ser atualizados devido a existência de operações da lista no roteiro que não fazem parte desta lista. - Revise as operações desta lista ou dos roteiros relacionados.

				EndIf
			EndIf

			If nButton == 9 .OR. nButton == 1	//ApMsgYesNo -> Não ou Revisa Lista
				lReturn	:= .F.
				//Help Exibido Após Retorno da Lista
				Help( Nil, Nil, STR0028, Nil, STR0029, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0030})	//Revise a lista! - Existem roteiros de processos produtivos que não poderão ser atualizados devido a existência de operações da lista no roteiro que não fazem parte desta lista. - Revise as operações desta lista ou dos roteiros relacionados.

			ElseIf (cValToChar(nButton) $ "034") .AND. lReturn .AND. !lRoteiroOk
				HelpInDark( .F. )	//Habilita a apresentação do Help
				Help( Nil, Nil, STR0037, Nil, STR0038, 1, 0, Nil, Nil, Nil, Nil, Nil, {STR0039})	// Operação Inválida! - Não existem roteiros aptos para replicação da lista. - Realize o tratamento das divergências antes de prosseguir.
				HelpInDark( .T. )	//Desabilita a apresentação do Help
				DestroyVie(nButton, lExibe, oViewExec, oView)
				lReturn	:= ValidaSG2(3)
			EndIf
		EndIf

		FWRestRows( aSaveLines )
	EndIf

	FwModelActive(oSubModel)

Return lReturn

/*/{Protheus.doc} DestroyVie
Destrói a View de Divergências
@author brunno.costa
@since 12/07/2018
@version 6
@return Nil
@param nButton, numeric, descricao
@param lExibe, logical, descricao
@param oViewExec, object, descricao
@param oView, object, descricao
@type function
/*/

Static Function DestroyVie(nButton, lExibe, oViewExec, oView)

	Local cLista	:= oModel118:GetModel("SVHDETAIL"):GetValue("VH_CODIGO",1)
	Local oModelNEW	:= oModel118:GetModel("NOK_NEW_SVH")
	Local oModelOLD	:= oModel118:GetModel("NOK_OLD_SVH")
	Local oModelOk	:= oModel118:GetModel("OK_SG2")

	If cValToChar(nButton) $ "10" //Revisa Lista
		DestroyObj(1, cLista)
	Else
		If lExibe
			oViewExec:DeActivate()
			oView:DeActivate()
			oView:Destroy()
		EndIf
	EndIf

	oModelNEW:ClearData( .F., .T. )
	oModelOLD:ClearData( .F., .T. )
	oModelOk:ClearData( .F., .T. )

Return

/*/{Protheus.doc} ChgNewSVH
Executada ao trocar de linha no grid NOK_NEW_SVH
@author brunno.costa
@since 14/06/2018
@version 6
@return NIL
@param oView, object, objeto de view
@param oModel, object, objeto da model
@type function
/*/
Static Function ChgNewSVH(oView, oModel)
	LoadOldSG2(oView, oModel)
Return

/*/{Protheus.doc} LoadOldSG2
Recarrega o grid NOK_OLD_SVH
@author brunno.costa
@since 28/06/2018
@version 6
@return NIL
@param oView, object, objeto de view
@param oModel, object, objeto da model
@type function
/*/
Static Function LoadOldSG2(oView, oModel)

	Local oModelOLD	:= oModel:GetModel("NOK_OLD_SVH")

	oModelOLD:ClearData(.F., .F.)
	oModelOLD:DeActivate()
	oModelOLD:lForceLoad := .T.
	oModelOLD:bLoad := {|| BLoadOld(oModel, oView) }
	oModelOLD:Activate()

	If oView:isActive()
		oView:Refresh("V_NOK_OLD_SVH")
	EndIf

Return

/*/{Protheus.doc} LoadNewSG2
Monta array de Dados do grid NOK_NEW_SVH
@author brunno.costa
@since 14/06/2018
@version 6
@return aDivergencias, array, Array com os dados que serão exibidos no GRID NOK_NEW_SVH
@param nTamanho, numeric, tamanho padrão da grid
@type function
/*/
Function LoadNewSG2(nTamanho)

	Local aAux		:= {}
	Local nX		:= 0

	If aDivergencias == NIL
		aItensDivergencias := {}
		For nX := 1 to nTamanho
			aAdd(aAux,"")
		Next nX
		aDivergencias := {}
		aAdd(aDivergencias,{0,aAux})
	EndIf

Return aClone(aDivergencias)

/*/{Protheus.doc} LoadSG2Ok
Monta array de Dados do grid OK_SG2
@author brunno.costa
@since 14/06/2018
@version 6
@return aOkRoteiros, array, Array com os dados que serão exibidos no GRID OK_SG2
@param nTamanho, numeric, tamanho padrão da grid
@type function
/*/
Function LoadSG2Ok(nTamanho)

	Local aAux		:= {}
	Local nX		:= 0

	If Empty(aOkRoteiros)
		For nX := 1 to nTamanho
			aAdd(aAux,"")
		Next nX
		aOkRoteiros := {}
		aAdd(aOkRoteiros,{0,aAux})
	EndIf

Return aClone(aOkRoteiros)

/*/{Protheus.doc} BLoadOld
Monta array de Dados do grid NOK_OLD_SVH
@author brunno.costa
@since 28/06/2018
@version 6
@return aLoad, array, array com os dados do grid NOK_OLD_SVH
@param oView, object, descricao
@param oModel, object, descricao
@type function
/*/
Static Function BLoadOld(oModel, oView)
	Local oModelNEW		:= oModel:GetModel("NOK_NEW_SVH")
	Local nLinNEW		:= 0
	Local aLoad			:= {}
	Local nRecSVH		:= 0

	If lSoSelecionado
		nRecSVH := oModelNEW:GetValue("RECNO",oModelNEW:nLine)
		If!Empty(nRecSVH)
			If ValType(nRecSVH) == "C"
				nRecSVH	:= 0
			EndIf
			SVH->(DbGoTo(nRecSVH))
		EndIf
		LLoadOld(oView, oModel, @aLoad)
	Else
		For nLinNEW := 1 to oModelNEW:GetQTDLine()
			nRecSVH := oModelNEW:GetValue("RECNO",nLinNEW)
			If !Empty(nRecSVH)
				If ValType(nRecSVH) == "C"
					nRecSVH	:= 0
				EndIf
				SVH->(DbGoTo(nRecSVH))
			EndIf
			LLoadOld(oView, oModel, @aLoad, nLinNEW)
		Next nLinNEW
	EndIf
Return aClone(aLoad)

/*/{Protheus.doc} LLoadOld
Monta array de Dados do grid NOK_OLD_SVH - Loop
@author brunno.costa
@since 03/07/2018
@version 6
@param oView, object, modelo utilizado
@param oModel, object, view utilizada
@param aLoad, array, variável aLoad utilizada
@param nLinha, numeric, linha do registro na NOK_NEW_SVH
@type function
/*/
Static Function LLoadOld(oView, oModel, aLoad, nLinha)

	Local oModelNEW		:= oModel:GetModel("NOK_NEW_SVH")
	Local oModelOLD 	:= oModel:GetModel("NOK_OLD_SVH")
	Local aDefDados
	Local nIndRot		:= 0
	Local nIndCps		:= 0
	Local aFields		:= oModelOLD:oFormModelStruct:aFields
	Local nAddFields
	Local nIndAux		:= 0
	Local cNewOperacao
	Local nSG2RecNew	:= 0
	Local nSG2RecOld	:= 0

	DEFAULT nLinha		:= oModelNEW:nLine

	cNewOperacao	:= oModelNEW:GetValue("VH_OPERAC", nLinha)

	aDefDados	:= aClone(oModelNEW:aDataModel[nLinha][1][1])
	nAddFields	:= (Len(aFields) - Len(aDefDados))

	For nIndCps := 1 to nAddFields
		aAdd(aDefDados,Nil)
	Next nIndCps

	For nIndRot := 1  to Len(aRoteiros)
		If !aRoteiros[nIndRot][3] .AND. !Empty(cNewOperacao)
			If SG2->(DbSeek(xFilial("SG2")+aRoteiros[nIndRot][2]+aRoteiros[nIndRot][1]+SVH->VH_OPERAC))
				nSG2RecOld	:= SG2->(Recno())
			Else
				nSG2RecOld	:= 0
			EndIf
			If SG2->(DbSeek(xFilial("SG2")+aRoteiros[nIndRot][2]+aRoteiros[nIndRot][1]+cNewOperacao))
				nSG2RecNew 	:= SG2->(Recno())
				nSG2RecOld	:= Iif(nSG2RecOld == 0, nSG2RecNew, nSG2RecOld)
			Else
				nSG2RecNew	:= nSG2RecOld
			EndIf
			//Posiciona no recno referente cOperacao nova, se não existir posiciona no referente operação anterior
			If nSG2RecNew > 0
				SG2->(DbGoTo(nSG2RecNew))
				For nIndCps := 1 to Len(aFields)
					If aFields[nIndCps][3] == "RECNO"
						aDefDados[nIndCps]	:= nSG2RecOld
					ElseIf aFields[nIndCps][3] == "_FALHA"
						//Pesquisa pelo recno referente cOperacao anterior, se for 0 pesquisa pelo novo
						nIndAux	:= aScan(aDiPCPA124,{|x| x[1] == nSG2RecOld })
						If nIndAux == 0
							If Empty(SG2->G2_LISTA)
								aDefDados[nIndCps]	:= STR0040 + " - " + STR0053		//Itens do Roteiro - Linha Duplicada
							Else
								aDefDados[nIndCps]	:= STR0043							//Erro desconhecido
							EndIf
						Else
							cIdFormErro	:= aDiPCPA124[nIndAux][2][MODEL_MSGERR_IDFORMERR]

							If "SG2" $ cIdFormErro .Or. cIdFormErro == "PCPA124_CAB"
								aDefDados[nIndCps] := STR0040 + " - " //Itens do Roteiro
							ElseIf "_R" $ cIdFormErro
								aDefDados[nIndCps] := STR0041 + " - " //Recursos Alternativos
							Else
								aDefDados[nIndCps] := STR0042 + " - " //Ferramentas Alternativas
							EndIf
							aDefDados[nIndCps] += aDiPCPA124[nIndAux][2][MODEL_MSGERR_MESSAGE]+ Chr(13) + Chr(10) +;
							                      aDiPCPA124[nIndAux][2][MODEL_MSGERR_SOLUCTION]+ Chr(13) + Chr(10)
						EndIf
					ElseIf aFields[nIndCps][3] == "VH_CODIGO"
						If Empty(SG2->(&(CampoSG2(aFields[nIndCps][3]))))
							aDefDados[nIndCps]	:= STR0031								//SEM LISTA
						Else
							aDefDados[nIndCps]	:= SG2->(&(CampoSG2(aFields[nIndCps][3])))
						EndIf
					Else
						aDefDados[nIndCps]	:= SG2->(&(CampoSG2(aFields[nIndCps][3])))
					EndIf
				Next nIndCps
				aAdd(aLoad,{0,aClone(aDefDados)})
			EndIf
		EndIf
	Next nIndRot

Return

/*/{Protheus.doc} GetRoteiro
Carregamento do array de controle dos roteiros relacionados a lista.
@author brunno.costa
@since 13/06/2018
@version 6
@return aRoteiros, lista dos códigos de roteiros relacionados a lista
@param cLista, characters, código da lista relacionada
@type function
/*/
Static Function GetRoteiro(cLista)

	Local aRoteiros := {}
	Local cQuery 	:= ""
	Local cAliasTmp	:= GetNextAlias()

	cQuery += " SELECT DISTINCT G2_CODIGO, G2_PRODUTO "
	cQuery += " FROM " + RetSqlName("SG2") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 	AND G2_LISTA = '" + cLista + "' "
	cQuery += " 	AND G2_FILIAL = '" + xFilial("SG2") + "' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	(cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(Eof())
		aAdd(aRoteiros,{(cAliasTmp)->G2_CODIGO,(cAliasTmp)->G2_PRODUTO,.T.})
		(cAliasTmp)->(DbSkip())
	EndDo

	(cAliasTmp)->(DbCloseArea())

Return aRoteiros

/*/{Protheus.doc} UpdRoteiro
Chama ExecView da PCPA124 permitindo editar os roteiros e realiza refresh da tela de divergências
@author brunno.costa
@since 03/07/2018
@version 6
@return NIL
@param oModel, object, modelo utilizado
@param oView, object, view utilizada
@type function
/*/

Static Function UpdRoteiro(oModel, oView)

	Local oModelOLD		:= oModel:GetModel("NOK_OLD_SVH")
	Local nLinha		:= oModelOLD:nLine
	Local oModel124
	Local nRet

	SG2->(DbGoTo(oModelOLD:GetValue("RECNO",nLinha)))
	oModel124	:= FWLoadModel("PCPA124")
	nRet 		:= FWExecView(STR0050, "PCPA124", OP_ALTERAR, /*oDlg*/, {|| .T. }, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel124) //Alterar Roteiro Divergente

Return

/*/{Protheus.doc} VisRoteiro
Chama ExecView da PCPA124 permitindo Visualizar o roteiro com a divergência
@author brunno.costa
@since 03/07/2018
@version 6
@return NIL
@param lRotSemDiverg, object, indica se exive visualização com ou sem divergência
@type function
/*/

Static Function VisRoteiro(lRotSemDiverg)

	Local oModelAux
	Local nLinha
	Local cCodRoteiro
	Local cCodProduto
	Local nIndRot
	Local oModel124		:= FWLoadModel("PCPA124")
	Local nRet
	Local cTitulo

	If !lRotSemDiverg
		oModelAux	:= oModel118:GetModel("NOK_OLD_SVH")
		nLinha			:= oModelAux:nLine
		cCodRoteiro		:= oModelAux:GetValue("VH_ROTEIRO", nLinha)
		cCodProduto		:= oModelAux:GetValue("VH_PRODUTO", nLinha)
		nIndRot			:= aScan(aModelsSG2,{|x| x[1] == cCodRoteiro .AND. x[2] == cCodProduto})
		cTitulo			:= STR0048	//Visualização (parcial) de como ficaria o Roteiro Replicado COM Divergência
	Else
		oModelAux	:= oModel118:GetModel("OK_SG2")
		nLinha			:= oModelAux:nLine
		cCodRoteiro		:= oModelAux:GetValue("G2_CODIGO", nLinha)
		cCodProduto		:= oModelAux:GetValue("G2_PRODUTO", nLinha)
		nIndRot			:= aScan(aModelsSG2,{|x| x[1] == cCodRoteiro .AND. x[2] == cCodProduto})
		cTitulo			:= STR0049	//Visualização de como ficará o roteiro replicado SEM Divergência
	EndIf

	oModel124:SetLoadXML( {|| aModelsSG2[nIndRot][3]:GetXMLData(.T./*lDetail*/, MODEL_OPERATION_UPDATE /*nOperation*/, /*lXSL*/, /*lVirtual*/, /*lDeleted*/, /*lEmpty*/, .F. /*lDefinition*/, /*cXMLFile*/) } )
	oModel124:lModify			:= .F.
	oModel124:lVlDactOk			:= .F.
	oModel124:nOperation		:= MODEL_OPERATION_VIEW
	nRet 						:= FWExecView(cTitulo, "PCPA124", MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. }, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/ {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F., STR0013 /*"Confirmar"*/},{.F.,STR0014 /*"Cancelar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} , /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel124) //Visualizar
	oModel124:lModify			:= .T.
	oModel124:lVlDactOk			:= .T.
	oModel124:nOperation		:= MODEL_OPERATION_UPDATE

Return

/*/{Protheus.doc} MontaCheck
Cria CheckBox
@author brunno.costa
@since 03/07/2018
@version 6
@return NIL
@param oPanel, object, painel para adição do checkbox
@param oModel, object, modelo utilizado
@param oView, object, view utilizada
@type function
/*/
Static Function MontaCheck(oPanel, oModel, oView)
	Local oCheck
	oCheck := TCheckBox():New(010,002,STR0033,{|| lSoSelecionado }, oPanel, 200, 030,, {|| bCheckBox(oModel, oView) },,,,,,.T.,,,)	//Exibe apenas operações referente item da lista selecionado
Return

/*/{Protheus.doc} bCheckBox
Função responsável pelo tratamento do checkbox referente operações apenas do registro selecionado
@author brunno.costa
@since 10/07/2018
@version 6
@return lSoSelecionado, logic, inversão do lSoSelecionado
@param oModel, object, modelo utilizado
@param oView, object, view utilizada
@type function
/*/
Static Function bCheckBox(oModel, oView)
	lSoSelecionado := !lSoSelecionado
	LoadOldSG2(oView, oModel)
	If oView:isActive()
		oView:Refresh("V_NOK_OLD_SVH")
	EndIf
Return lSoSelecionado

/*/{Protheus.doc} CampoSG2
Conversão da nomenclatura de campos da SVH para SG2
@author brunno.costa
@since 13/06/2018
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
			Otherwise
			cCampoSG2 := Strtran(cCampoSVH,"G2_","VH_")
		EndCase
	EndIf

Return cCampoSG2

/*/{Protheus.doc} CampoSH3
Conversão da nomenclatura de campos da SVH para SG2
@author brunno.costa
@since 13/06/2018
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

/*/{Protheus.doc} DestroyObj
Destroy Objetos Utilizados pela Validação de Divergências durante a Réplica na PCPA124
@author brunno.costa
@since 10/07/2018
@version 6
@return Nil
@param nOpc, numeric,
1 - Método Destroy do Evento
2 - Inicio da ValidaSG2
@type function
/*/
Static Function DestroyObj(nOpc, cLista)

	Local nIndRot := 0

	If !Empty(aDivergencias)
		aSize(aDivergencias,0)
	EndIf

	If !Empty(aDiPCPA124)
		aSize(aDiPCPA124,0)
	EndIf

	If !Empty(aItensDivergencias)
		aSize(aItensDivergencias,0)
	EndIf

	If !Empty(aOkRoteiros)
		aSize(aOkRoteiros,0)
	EndIf

	If !Empty(aModelsSG2)
		For nIndRot := 1 to Len(aModelsSG2)
			aModelsSG2[nIndRot][3]:DeActivate()
			aModelsSG2[nIndRot][3]:Destroy()
		Next nIndRot
		aSize(aModelsSG2,0)
	EndIf

	If !Empty(aRoteiros)
		aSize(aRoteiros,0)
	EndIf

	aDivergencias		:= {}
	aItensDivergencias	:= {}
	aOkRoteiros			:= {}
	aRoteiros			:= {}
	aModelsSG2			:= {}
	aDiPCPA124			:= {}

	If nOpc == 2
		aRoteiros	:= GetRoteiro(cLista)
	EndIf

Return

/*/{Protheus.doc} LimpG2LIST
Limpa campo G2_LISTA dos registros inexistentes na lista, quando existente e parâmetro MV_PCPRLPP desabilitado
@author brunno.costa
@since 17/07/2018
@version 6
@return NIL

@type function
/*/
Static Function LimpG2LIST(cLista)
	Local nMVPCPRLPP	:= SuperGetMV("MV_PCPRLPP", .F., 2)
	Local cQuery 		:= ""
	If nMVPCPRLPP == 2 .AND. !Empty(cLista)
		/*cQuery := " UPDATE " + RetSqlName("SG2") + " "
		cQuery += " SET G2_LISTA = ' ' "
		cQuery += " WHERE G2_LISTA = '" + cLista + "' AND D_E_L_E_T_ = ' ' "*/
		cQuery := " UPDATE " + RetSqlName("SG2") + " "
		cQuery += " SET G2_LISTA = ' ' "
		cQuery += " WHERE G2_LISTA = '" + cLista + "' AND D_E_L_E_T_ = ' ' AND R_E_C_N_O_ IN (SELECT RECNOSG2 "
		cQuery += " FROM (SELECT SG2.R_E_C_N_O_ RECNOSG2, SVH.R_E_C_N_O_ RECNOSVH "
		cQuery += " 	FROM " + RetSqlName("SG2") + " SG2 LEFT JOIN "
		cQuery += " 		(SELECT * FROM " + RetSqlName("SVH") + " WHERE D_E_L_E_T_=' ') SVH "
		cQuery += " 	ON SG2.D_E_L_E_T_ = ' ' "
		cQuery += " 		AND SG2.G2_LISTA = SVH.VH_CODIGO "
		cQuery += " 		AND SG2.G2_OPERAC = SVH.VH_OPERAC "
		cQuery += " 		AND SG2.G2_LISTA = '" + cLista + "') REC "
		cQuery += " WHERE REC.RECNOSVH IS NULL ) "
		If AllTrim(Upper(TcGetDb())) $ "ORACLE"
			cQuery	:= Strtran(cQuery,"LEFT JOIN","LEFT OUTER JOIN")
		EndIf
		TcSqlExec(cQuery)
	EndIf
Return

/*/{Protheus.doc} PCPA118Lis
Verifica se a lista esta em uso por algum roteiro de processos produtivos
@author douglas.heydt
@since 14/12/2018
@version 1

@param cCodLista :: codigo da lista de operacoes
@return lUsado   :: .T. - lista utilizada / .F. - nao utilizada
/*/
Function PCPA118Lis(cCodLista)

	Local cQuery 	:= ""
	Local cAliasTmp	:= GetNextAlias()
	Local lUsado := .F.

	cQuery += " SELECT DISTINCT G2_CODIGO, G2_PRODUTO "
	cQuery += " FROM " + RetSqlName("SG2") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += " 	AND G2_LISTA = '" + cCodLista + "' "
	cQuery += " 	AND G2_FILIAL = '" + xFilial("SG2") + "' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

	If !(cAliasTmp)->(Eof())
		lUsado := .T.
	EndIf

	(cAliasTmp)->(DbCloseArea())

Return lUsado

/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de validação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author Lucas Fagundes
@since 30/07/2024
@version P12
@param 01 oModel  , Object  , Modelo principal.
@param 02 cModelId, Caracter, Id do submodelo.
@return lOk, Logico, Indica se permite prosseguir.
/*/
Method VldActivate(oModel, cModelId) Class PCPA118EVDEF
	Local lOk := .T.

	If GetSx3Cache("MY_ORDEM", "X3_TAMANHO") > 0
		geraOrdem(SMX->MX_CODIGO)
	EndIf

Return lOk

/*/{Protheus.doc} geraOrdem
Gera ordem dos recursos alternativos, caso não exista.
@type  Static Function
@author Lucas Fagundes
@since 30/07/2024
@version P12
@param cRoteiro, Caracter, Código do roteiro.
@return Nil
/*/
Static Function geraOrdem(cRoteiro)
	Local aArea     := SMY->(GetArea())
	Local cOperacao := ""
	Local cSeek     := xFilial("SMY")+cRoteiro
	Local cSeqOrdem := ""

	SMY->(dbSetOrder(1))
	If SMY->(dbSeek(cSeek)) .And. Empty(SMY->MY_ORDEM)
		While SMY->MY_FILIAL+SMY->MY_CODIGO == cSeek
			If SMY->MY_OPERAC != cOperacao
				cSeqOrdem := "00"
			EndIf
			cOperacao := SMY->MY_OPERAC

			RecLock("SMY", .F.)
				cSeqOrdem := Soma1(cSeqOrdem)
				SMY->MY_ORDEM := cSeqOrdem
			SMY->(MsUnLock())

			SMY->(dbSkip())
		End
	EndIf

	RestArea(aArea)
Return Nil
