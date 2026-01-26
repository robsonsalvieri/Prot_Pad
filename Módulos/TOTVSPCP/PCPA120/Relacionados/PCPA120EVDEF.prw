#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA120.CH"
#INCLUDE "FWMVCDEF.CH"

Static nButton := 0

/*/{Protheus.doc} PCPA120EVDEF
Eventos padrão do cadastro de roteiros
@author Douglas Heydt
@since 25/04/2018
@version P12.1.17
/*/
CLASS PCPA120EVDEF FROM FWModelEvent

	DATA aModelsSG            AS ARRAY
	DATA aListaDivergencia    AS ARRAY
	DATA aEstrutDivergencia   AS ARRAY
	DATA aEstrutOk            AS ARRAY
	DATA lMvRevisaoAutomatica
	DATA lMvRevisaoFilial
	DATA lMvArqProd
	DATA nMvGeraNovaRevisao

	METHOD New() CONSTRUCTOR
	METHOD VldActivate()
	METHOD Activate()
	METHOD DeActivate()
	METHOD GridLinePosVld(oSubModel, cModelID)
	METHOD ModelPosVld(oSubModel, cModelId)
	METHOD InTTS(oSubModel, cModelId)

	METHOD AltStructDivergencia()
	METHOD CargaModelosDivergencia()
	METHOD InicializaVar()
	METHOD ProcessaDivergencias()
	METHOD ReplicarEstrutura()
	METHOD UpdateDivergencias()

ENDCLASS

METHOD New() CLASS  PCPA120EVDEF

Return

/*/{Protheus.doc} VldActivate
Método executado antes da ativação do modelo
@author Marcelo Neumann
@since 10/04/2019
@version 1.0
@param oModel, object , modelo principal
@param lCopy , logical, indica se é uma cópia
@return Nil
/*/
METHOD VldActivate(oModel, lCopy) CLASS  PCPA120EVDEF

	Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		If PCPA120Lis(SMW->MW_CODIGO, .T.)
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} Activate
Método executado quando ocorrer a ativação do modelo
@author Douglas Heydt
@since 22/01/2019
@version 1.0
@param oModel, object , modelo principal
@param lCopy , logical, indica se é uma cópia
@return Nil
/*/
METHOD Activate(oModel, lCopy) CLASS  PCPA120EVDEF

	//Inicializa as variáveis utilizadas para réplica.
	::InicializaVar()

	Pergunte("PCPA120", .F.)
	::nMvGeraNovaRevisao   := IIf(Empty(mv_par01), 2, mv_par01)
	::lMvRevisaoAutomatica := SuperGetMv("MV_REVAUT" ,.F.,.F.) //Revisão Automática
	::lMvRevisaoFilial     := SuperGetMv("MV_REVFIL" ,.F.,.F.) //Revisão da estrutura por Filial SBZ
	::lMvArqProd           := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"

Return Nil

/*/{Protheus.doc} DeActivate
Método executado quando ocorrer a desativação do modelo.

@author Lucas Konrad França
@since 03/01/2020
@version P12.1.29

@param oModel	- Modelo principal.
@return Nil.
/*/
METHOD DeActivate(oModel) CLASS PCPA120EVDEF
	Local nX := 0

	//Necessário desativar os modelos para liberar os locks, caso tenham ficado.
	For nX := 1 to Len(::aModelsSG)
		::aModelsSG[nX][1]:DeActivate()
		FreeObj(::aModelsSG[nX][1])
	Next nX

	aSize(::aModelsSG, 0)

	If ::aListaDivergencia != Nil
		aSize(::aListaDivergencia, 0)
	EndIf
	If ::aEstrutDivergencia != Nil
		aSize(::aEstrutDivergencia, 0)
	EndIf
	If ::aEstrutOk != Nil
		aSize(::aEstrutOk, 0)
	EndIf

Return Nil

/*/{Protheus.doc} InicializaVar
Método que inicializa as propriedades utilizadas desta classe
@author lucas.franca
@since 12/02/2019
@version 1.0
@return Nil
/*/
METHOD InicializaVar() CLASS PCPA120EVDEF
	::aModelsSG          := {}
	::aListaDivergencia  := {}
	::aEstrutDivergencia := {}
	::aEstrutOk          := {}
Return Nil

/*/{Protheus.doc} GridLinePosVld
Valida linha da grid principal da operação preenchida
@author Douglas.Heydt
@since 21/01/2019
@version 1.0
@param oSubModel, object    , modelo de dados
@param cModelId	, characters, ID do modelo de dados
@param nLine    , numeric   , linha do grid
@return lRet, logical, indica se a linha está válida
/*/
METHOD GridLinePosVld(oModel, cID, nLine) CLASS PCPA120EVDEF
	Local lRet    := .T.
	If cID == "SVGDETAIL" .And. !oModel:IsDeleted()
		If (Empty(oModel:GetValue("VG_GROPC")) .And. !Empty(oModel:GetValue("VG_OPC"))) .Or. ( !Empty(oModel:GetValue("VG_GROPC")) .And. Empty(oModel:GetValue("VG_OPC")))
			Help(" ",1,"A120VLDIT")
			lRet := .F.
		EndIf
		If !A120VldIt()
			lRet := .F.
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model
@author Douglas.Heydt
@since 21/01/2019
@version 1.0
@param 01 oModel  , Objeto  , Modelo principal
@param 02 cModelId, Caracter, Id do submodelo
@return lRet
/*/
METHOD ModelPosVld(oSubModel, cModelId) CLASS PCPA120EVDEF

	Local oModel := oSubModel:GetModel()
	Local lRet   := .T.

	//Executa a replicação da lista
	lRet := ::ReplicarEstrutura(oModel,1)

Return lRet

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author douglas.heydt
@since 16/01/2019
@version 1
@param 01 oSubModel, Objeto  , Modelo principal
@param 02 cModelId , Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTS(oSubModel, cModelId) CLASS PCPA120EVDEF

	Local nX        := 0
	Local oModelOld := FwModelActive()
	Local oEvent

	For nX := 1 to Len(::aModelsSG)
		If ::aModelsSG[nX][3]
			FwModelActive(::aModelsSG[nX][1])

			//Se for na ESTRUTURA (PCPA200) e a Revisão for Manual (MV_REVAUT)
			If ::aModelsSG[nX][4] == "1" .And. !::lMvRevisaoAutomatica
				//Verifica o parâmetro (F12) do PCPA120
				If ::nMvGeraNovaRevisao == 1
					::aModelsSG[nX][1]:GetModel("SG1_MASTER"):LoadValue("ATUREVSB1","S")
					P200AvaRev()
				Else
					oEvent := GetMdlEveD(::aModelsSG[nX][1], "PCPA200EVDEF")
					oEvent:SetGeraRevisao(.F.)
				EndIf
			EndIf

			FwFormCommit(::aModelsSG[nX][1])
		EndIf
	Next nX

	//Limpa as variáveis utilizadas para réplica.
	::InicializaVar()

	//Volta o modelo ativo para o modelo do PCPA120
	FwModelActive(oModelOld)
Return

/*/{Protheus.doc} ReplicarEstrutura
Efetua a replicação para a estrutura/pré-estrutura.
@type  METHOD
@author lucas.franca
@since 11/02/2019
@version P12
@param  oModel , Object , Modelo de dados da lista de componentes.
@param  nOpc   , Numeric, 1 - Chamada pelo ModelPosVld; 2 - Chamada após realizar alteração do roteiro.
@return lStatus, Logical, Indica se a replicação das estruturas/pré-estruturas foi realizada.
/*/
METHOD ReplicarEstrutura(oModel, nOpc) CLASS PCPA120EVDEF
	Local aFullLine  := {}
	Local nX         := 0
	Local nPos       := 0
	Local nIndex     := 0
	Local nLineAtu   := 0
	Local nReplica   := SuperGetMV("MV_PCPRLEP", .F., 2)
	Local lRet       := .T.
	Local lStatus    := .T.
	Local lDuplicado := .F.
	Local cQuery     := ""
	Local dDataIni   := Date()
	Local dDataFin   := CTOD("31/12/2049")
	Local oGridSVG	 := oModel:GetModel("SVGDETAIL")
	Local oModelSMW  := oModel:GetModel("SMWMASTER")
	Local oModel135

	If nReplica == 1 .AND. oModel:GetOperation() != MODEL_OPERATION_INSERT

		//Inicializa as propriedades utilizadas no processamento.
		::InicializaVar()

		For nX := 1 To oGridSVG:Length()
			oGridSVG:GoLine(nX)

			If oGridSVG:IsInserted() .And. oGridSVG:IsDeleted()
				Loop
			EndIf

			aFullLine := {  oGridSVG:GetValue("VG_TRT"),;
							oGridSVG:GetValue("VG_QUANT"),;
							/*DATA INICIAL*/ ,;
							/*DATA FINAL*/ ,;
							oGridSVG:GetValue("VG_FIXVAR"),;
							oGridSVG:GetValue("VG_GROPC"),;
							oGridSVG:GetValue("VG_OPC"),;
							oGridSVG:GetValue("VG_POTENCI"),;
							oGridSVG:GetValue("VG_TIPVEC"),;
							oGridSVG:GetValue("VG_VECTOR"),;
							oGridSVG:GetValue("VG_LOCCONS")}

			//Verifica se a linha foi alterada e qual o tipo da alteração (Inclusão, Alteração, Exclusão)
			If oGridSVG:IsUpdated(nX) .And. !oGridSVG:IsDeleted(nX) .And. !oGridSVG:IsInserted(nX)
				cOper := "UPDATE"
				aFullLine[3] := oGridSVG:GetValue("VG_INI")
				aFullLine[4] := oGridSVG:GetValue("VG_FIM")

			ElseIf oGridSVG:IsInserted(nX)
				cOper := "INSERT"
				aFullLine[3] := IIf(Empty(oGridSVG:GetValue("VG_INI")), dDataIni, oGridSVG:GetValue("VG_INI") )
				aFullLine[4] := IIf(Empty(oGridSVG:GetValue("VG_FIM")), dDataFin, oGridSVG:GetValue("VG_FIM") )

			ElseIf oGridSVG:IsDeleted(nX)
				cOper := "DELETE"
				aFullLine[3] := IIf(Empty(oGridSVG:GetValue("VG_INI")), dDataIni, oGridSVG:GetValue("VG_INI") )
				aFullLine[4] := IIf(Empty(oGridSVG:GetValue("VG_FIM")), dDataFin, oGridSVG:GetValue("VG_FIM") )
			Else
				Loop
			EndIf

			lRet := .T.

			//Busca as Estruturas e Pré-Estruturas que utilizam a lista
			cQuery := " SELECT DISTINCT '1'  AS TIPO,"
			cQuery +=        " SG1.G1_FILIAL AS FILIAL,"
			cQuery +=        " SG1.G1_COD    AS COD"
			cQuery +=   " FROM " + RetSqlName('SG1') + " SG1"
			cQuery +=  " INNER JOIN " + RetSqlName('SB1') + " SB1"
			cQuery +=     " ON SB1.B1_COD     = SG1.G1_COD"
			cQuery +=    " AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
			cQuery +=    " AND SB1.D_E_L_E_T_ = ' '"

			If ::lMvRevisaoFilial .And. ::lMvArqProd
				cQuery += " LEFT OUTER JOIN " + RetSqlName('SBZ') + " SBZ"
				cQuery +=    " ON SBZ.BZ_COD     = SB1.B1_COD"
				cQuery +=   " AND SBZ.BZ_FILIAL  = '" + xFilial("SBZ") + "'"
				cQuery +=   " AND SBZ.D_E_L_E_T_ = ' '"
				cQuery += " WHERE COALESCE(SBZ.BZ_REVATU, SB1.B1_REVATU) BETWEEN SG1.G1_REVINI AND SG1.G1_REVFIM"
			Else
				cQuery += " WHERE SB1.B1_REVATU BETWEEN SG1.G1_REVINI AND SG1.G1_REVFIM"
			EndIf

			cQuery +=    " AND SG1.G1_FILIAL  = '" + xFilial("SG1") + "'"
			cQuery +=    " AND SG1.D_E_L_E_T_ = ' '"
			cQuery +=    " AND SG1.G1_LISTA   = '" + oModelSMW:GetValue("MW_CODIGO") + "'"

			If cOper <> "INSERT"
				cQuery += " AND SG1.G1_COMP   = '" + oGridSVG:GetValue("VG_COMP")   + "'"
				cQuery += " AND SG1.G1_TRT    = '" + oGridSVG:GetValue("VG_OLDTRT") + "'"
			EndIf

			cQuery +=  " UNION ALL"
			cQuery += " SELECT DISTINCT '2'  AS TIPO,"
			cQuery +=        " SGG.GG_FILIAL AS FILIAL,"
			cQuery +=        " SGG.GG_COD    AS COD"
			cQuery +=   " FROM " + RetSqlName('SGG') + " SGG"
			cQuery +=  " WHERE SGG.GG_FILIAL  = '" + xFilial("SGG") + "'"
			cQuery +=    " AND SGG.GG_LISTA   = '" + oModelSMW:GetValue("MW_CODIGO") + "'"
			cQuery +=    " AND SGG.D_E_L_E_T_ = ' '"

			If cOper <> "INSERT"
				cQuery += " AND SGG.GG_COMP   = '" + oGridSVG:GetValue("VG_COMP")   + "'"
				cQuery += " AND SGG.GG_TRT    = '" + oGridSVG:GetValue("VG_OLDTRT") + "'"
			EndIf

			cQuery +=  " ORDER BY 1, 2, 3"
			cQuery := ChangeQuery(cQuery)

			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYSGAUTO",.F.,.T.)
			While !QRYSGAUTO->(Eof())
				lRet := .T.

				//SG1 - ESTRUTURA
				If QRYSGAUTO->TIPO == "1"
					cPrograma  := "PCPA200"
					cFldMaster := "SG1_MASTER"
					cGrdDetail := "SG1_DETAIL"

					DbSelectArea("SG1")
					SG1->(DbSetOrder(1))
					SG1->(DbSeek(xFilial("SG1") + QRYSGAUTO->COD ))
				Else
					cPrograma  := "PCPA135"
					cFldMaster := "FLD_MASTER"
					cGrdDetail := "GRID_DETAIL"

					DbSelectArea("SGG")
					SGG->(DbSetOrder(1))
					SGG->(DbSeek(xFilial("SGG") + QRYSGAUTO->COD ))
				EndIf

				nPos := aScan(::aModelsSG, {|x| x[2] == QRYSGAUTO->COD .And. x[4] == QRYSGAUTO->TIPO} )
				If nPos > 0
					oModel135 := ::aModelsSG[nPos][1]
					If !::aModelsSG[nPos][3]
						//Limpa a mensagem de erro antiga
						oModel135:GetErrorMessage(.T.)
					EndIf
					FwModelActive(oModel135)
				Else
					//Cria Modelo para Validação Padrão da PCPA135
					oModel135 := Nil
					oModel135 := FWLoadModel(cPrograma)
					oModel135:setOperation(MODEL_OPERATION_UPDATE)
					
					//Verifica se a operação é permitida
					If !oModel135:CanActivate()
						QRYSGAUTO->(DbSkip())
						Loop
					EndIf

					oModel135:Activate()
					If cPrograma == "PCPA200"
						oModel135:GetModel("SG1_MASTER"):LoadValue("CREVABERTA", P200IniRev(QRYSGAUTO->COD))
					EndIf
					oModel135:GetModel(cFldMaster):SetValue("CEXECAUTO", "S")

					//Chamada de funções de controle do fonte
					If QRYSGAUTO->TIPO == "1"
						P200TreeCh(.T., P200AddPai(QRYSGAUTO->COD))
					Else
						P135TreeCh(.T., P135AddPai(QRYSGAUTO->COD), .T.)
					EndIf
				EndIf

				oGridDetail := oModel135:GetModel(cGrdDetail)

				If cOper == "DELETE"
					If oGridDetail:SeekLine({{ConverteG1("GG_COD" , QRYSGAUTO->TIPO), QRYSGAUTO->COD },;
					                         {ConverteG1("GG_COMP", QRYSGAUTO->TIPO), oGridSVG:GetValue("VG_COMP")},;
											 {ConverteG1("GG_TRT" , QRYSGAUTO->TIPO), oGridSVG:GetValue("VG_OLDTRT")}})

						oGridDetail:LoadValue(ConverteG1("GG_LISTA", QRYSGAUTO->TIPO), " ")
						oGridDetail:DeleteLine()
					Endif

					lRet := oGridDetail:VldLineData()
					If !lRet
						::UpdateDivergencias(.F., oModel135, oModel, .F., QRYSGAUTO->TIPO)
					EndIf

				ElseIf cOper == "INSERT"
					//Verifica se irá duplicar o componente na estrutura
					lDuplicado := .F.

					For nIndex := 1 To oGridDetail:Length()
						oGridDetail:GoLine(nIndex)

						If oGridDetail:IsDeleted()
							Loop
						EndIf

						//Verifica se o componente já existe na nova sequência informada.
						If oGridDetail:GetValue(ConverteG1("GG_COD" , QRYSGAUTO->TIPO)) == QRYSGAUTO->COD .And. ;
						   oGridDetail:GetValue(ConverteG1("GG_COMP", QRYSGAUTO->TIPO)) == oGridSVG:GetValue("VG_COMP") .And. ;
						   oGridDetail:GetValue(ConverteG1("GG_TRT" , QRYSGAUTO->TIPO)) == oGridSVG:GetValue("VG_TRT")

							If QRYSGAUTO->TIPO == "1"
								//Atualiza dados do modelo do pcpa200
								PCPA200JIncrementa( QRYSGAUTO->COD, oGridSVG:GetValue("VG_COMP") + oGridSVG:GetValue("VG_TRT"))
							EndIf

							//Adiciona mensagem de erro no modelo.
							oModel135:SetErrorMessage(oModel135:GetId(),;
							                          ConverteG1("GG_TRT", QRYSGAUTO->TIPO),;
							                          oGridDetail:GetId(),;
							                          ConverteG1("GG_TRT", QRYSGAUTO->TIPO),;
							                          "MESMASEQ",;
							                          STR0016,; //"Não é possível informar o mesmo componente com a mesma sequência mais de uma vez na mesma estrutura."
							                          STR0017,; //"Informe outra sequência para este componente, ou informe outro componente."
							                          aFullLine[1],;
							                          " ")

							//Cria a divergência para o registro duplicado.
							::UpdateDivergencias(.F., oModel135, oModel, .T., QRYSGAUTO->TIPO)
							//Sai do loop
							lDuplicado := .T.
							Exit
						EndIf
					Next nIndex

					oGridDetail:AddLine()
					oGridDetail:SetValue(ConverteG1("GG_FILIAL", QRYSGAUTO->TIPO), QRYSGAUTO->FILIAL)
					oGridDetail:SetValue(ConverteG1("GG_COD"   , QRYSGAUTO->TIPO), QRYSGAUTO->COD)
					lRet := SetaValor(oGridDetail, oGridSVG:GetValue("VG_COMP"), aFullLine, oModelSMW:GetValue("MW_CODIGO"), QRYSGAUTO->TIPO)

					If lDuplicado
						lRet := .F.
					Else
						lRet := lRet .And. oGridDetail:VldLineData()
						If !lRet
							::UpdateDivergencias(.F., oModel135, oModel, .F., QRYSGAUTO->TIPO)
						EndIf
					EndIf

				ElseIf cOper == "UPDATE"
					lDuplicado := .F.

					If oGridDetail:SeekLine({{ConverteG1("GG_COD" , QRYSGAUTO->TIPO), QRYSGAUTO->COD },;
					                         {ConverteG1("GG_COMP", QRYSGAUTO->TIPO), oGridSVG:GetValue("VG_COMP")},;
											 {ConverteG1("GG_TRT" , QRYSGAUTO->TIPO), oGridSVG:GetValue("VG_OLDTRT") }})

						//Se mudou a sequência, verifica se não irá duplicar o registro.
						If oGridDetail:GetValue(ConverteG1("GG_TRT", QRYSGAUTO->TIPO)) != aFullLine[1]
							nLineAtu := oGridDetail:GetLine()

							For nIndex := 1 To oGridDetail:Length()
								If nIndex == nLineAtu .Or. oGridDetail:IsDeleted()
									//Se é a mesma linha que será alterada ou uma linha deletada pula.
									Loop
								EndIf

								oGridDetail:GoLine(nIndex)

								//Verifica se o componente já existe na nova sequência informada.
								If oGridDetail:GetValue(ConverteG1("GG_COD" , QRYSGAUTO->TIPO)) == QRYSGAUTO->COD .And. ;
								   oGridDetail:GetValue(ConverteG1("GG_COMP", QRYSGAUTO->TIPO)) == oGridSVG:GetValue("VG_COMP") .And. ;
								   oGridDetail:GetValue(ConverteG1("GG_TRT" , QRYSGAUTO->TIPO)) == oGridSVG:GetValue("VG_TRT" )

									If QRYSGAUTO->TIPO == "1"
										//Atualiza dados do modelo do pcpa200
										PCPA200JIncrementa( QRYSGAUTO->COD, oGridSVG:GetValue("VG_COMP") + oGridSVG:GetValue("VG_TRT"))
									EndIf

									//Adiciona mensagem de erro no modelo.
									oModel135:SetErrorMessage(oModel135:GetId(),;
									                          ConverteG1("GG_TRT", QRYSGAUTO->TIPO),;
									                          oGridDetail:GetId(),;
									                          ConverteG1("GG_TRT", QRYSGAUTO->TIPO),;
									                          "MESMASEQ",;
									                          STR0016,; //"Não é possível informar o mesmo componente com a mesma sequência mais de uma vez na mesma estrutura."
									                          STR0017,; //"Informe outra sequência para este componente, ou informe outro componente."
									                          aFullLine[1],;
									                          oGridDetail:GetValue(ConverteG1("GG_TRT", QRYSGAUTO->TIPO)))

									//Cria a divergência para o registro duplicado.
									::UpdateDivergencias(.F., oModel135, oModel, .T., QRYSGAUTO->TIPO)
									//Sai do loop
									lDuplicado := .T.
									Exit
								EndIf
							Next nIndex
							oGridDetail:GoLine(nLineAtu)
						EndIf

						lRet := SetaValor(oGridDetail, Nil, aFullLine, oModelSMW:GetValue("MW_CODIGO"), QRYSGAUTO->TIPO)
					EndIf

					If lDuplicado
						lRet := .F.
					Else
						lRet := lRet .And. oGridDetail:VldLineData()
						If !lRet
							::UpdateDivergencias(.F., oModel135, oModel, .F., QRYSGAUTO->TIPO)
						EndIf
					EndIf
				EndIf

				If nPos > 0
					//Atualiza o status deste modelo caso tenha acontecido algum erro
					If ::aModelsSG[nPos][3] != .F.
						::aModelsSG[nPos][3] := lRet
					EndIf
				Else
					Aadd(::aModelsSG, {oModel135,  QRYSGAUTO->COD, lRet, QRYSGAUTO->TIPO})
				EndIf

				QRYSGAUTO->(DbSkip())
			End

			QRYSGAUTO->(dbCloseArea())
		Next nX

		For nX := 1 To Len(::aModelsSG)
			//Verifica se o modelo está válido, e executa a pós validação do modelo.
			If ::aModelsSG[nX][3]
				FwModelActive(::aModelsSG[nX][1])
				lRet := ::aModelsSG[nX][1]:VldData(,.T.)
				::UpdateDivergencias(lRet, ::aModelsSG[nX][1], oModel, , ::aModelsSG[nX][4])
			EndIf
		Next nX

		//Restaura o modelo ativo.
		FwModelActive(oModel)

		//Se existir divergências ou for reprocesso após alterar a estrutura, abre a tela de divergências.
		If Len(::aEstrutDivergencia) > 0 .Or. Len(::aListaDivergencia) > 0 .Or. nOpc == 2
			lStatus := ::ProcessaDivergencias(oModel, nOpc)
		EndIf
	EndIf

	FwModelActive(oModel)
Return lStatus

/*/{Protheus.doc} UpdateDivergencias
Armazena as informações para exibição das divergências
@type  METHOD
@author lucas.franca
@since 12/02/2019
@version P12
@param 01 lStatus   , Logical   , Identifica se é um erro (.F.), ou se é modificação realizada com sucesso (.T.)
@param 02 oModelSG  , Object    , Modelo de dados da estrutura
@param 03 oModelSVG , Object    , Modelo de dados da lista de componentes (SVG)
@param 04 lDuplicado, Logical   , Identifica se é erro de componente duplicado na estrutura.
@param 05 cTipo     , Characters, Indica se é Estrutura ("1") ou Pré-Estrutura ("2")
@return Nil
/*/
METHOD UpdateDivergencias(lStatus, oModelSG, oModelSVG, lDuplicado, cTipo) CLASS PCPA120EVDEF
	Local nLine      := 0
	Local cCodPai    := ""
	Local cCodCmp    := ""
	Local cSeqCmp    := ""
	Local cFldMaster := ""
	Local cGrdDetail := ""

	//Estrutura
	If cTipo == "1"
		cFldMaster := "SG1_MASTER"
		cGrdDetail := "SG1_DETAIL"
	Else
		cFldMaster := "FLD_MASTER"
		cGrdDetail := "GRID_DETAIL"
	EndIf

	nLine   := oModelSVG:GetModel("SVGDETAIL"):GetLine()
	cCodPai := oModelSG:GetModel(cFldMaster):GetValue(ConverteG1("GG_COD", cTipo))
	cCodCmp := oModelSVG:GetModel("SVGDETAIL"):GetValue("VG_COMP")
	cSeqCmp := oModelSVG:GetModel("SVGDETAIL"):GetValue("VG_TRT")

	If !lStatus
		//Verifica se este componente da lista de componentes já está listado no array de Listas.
		//Se não estiver listado ainda, adiciona.
		If aScan(::aListaDivergencia, {|x| x == nLine}) == 0
			aAdd(::aListaDivergencia, nLine)
		EndIf

		//Adiciona as informações da estrutura onde ocorreu o erro.
		aAdd(::aEstrutDivergencia, {cCodPai,; //Código do produto PAI
		                            cCodCmp,; //Código do componente
									cSeqCmp,; //Sequência do componente
									nLine,;   //Linha do componente na Lista (SVG)
									oModelSG,; //Modelo de dados da estrutura/pré-estrutura
									oModelSG:GetModel(cGrdDetail):GetLine(),; //Linha que ocorreu o erro estrutura
									oModelSG:GetErrorMessage(),; //Mensagem de erro
									lDuplicado,; //Indica se é erro de componente duplicado na estrutura
									cTipo}) //Indica se é Estrutura ou Pré-Estrutura
	Else
		//Verifica se esta estrutura/pré-estrutura já está relacionada no array de estruturas/pré-estruturas sem divergências.
		If aScan(::aModelsSG, {|x| x[2] == cCodPai .And. x[4] == cTipo} )
			aAdd(::aEstrutOk, {cCodPai, oModelSG:GetModel(cFldMaster):GetValue("CDESCPAI"), cTipo})
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} ProcessaDivergencias
Verifica se ocorreram erros nos modelos. Se existirem erros, exibe a tela de divergências.
@type  METHOD
@author lucas.franca
@since 11/02/2019
@version P12
@param  oModel , Object , Modelo de dados da lista de componentes.
@param  nOpc   , Numeric, 1 - Chamada pelo ModelPosVld; 2 - Chamada após realizar alteração do roteiro.
@return lStatus, Logical, Indica se a replicação das estruturas/pré-estruturas deverá ser efetivada.
/*/
METHOD ProcessaDivergencias(oModel, nOpc) CLASS PCPA120EVDEF
	Local lStatus    := .T.
	Local lOkEstrut  := Len(::aEstrutOk) > 0
	Local lNOkEstrut := Len(::aEstrutDivergencia) > 0
	Local oStruSVG   := FWFormStruct(2,"SVG")
	Local oStruSGG   := FWFormStruct(2,"SGG")
	Local oStruOKSGG := FWFormStruct(2,"SGG" ,{|cCampo| '|'+AllTrim(cCampo)+'|' $ "|GG_COD|"})
	Local oView
	Local oViewExec  := FWViewExec():New()
	Local oViewPai   := FWViewActive()

	//Carrega os modelos para exibição da tela de divergências.
	::CargaModelosDivergencia(oModel)

	//Faz as alterações no Struct da view que será exibido na tela de divergências.
	::AltStructDivergencia(2, @oStruSVG, @oStruSGG, @oStruOKSGG)

	nButton := 0

	//Abre nova View;
	oView := FWFormView():New(oViewPai)
	oView:SetModel(oModel)
	oView:SetOperation(1)
	oView:AddGrid("V_SVG_NOK", oStruSVG  , "SVG_NOK" )
	oView:AddGrid("V_SG_NOK", oStruSGG  , "SG_NOK" )
	oView:AddGrid("V_SG_OK" , oStruOKSGG, "SG_OK" )

	oView:SetViewProperty("V_SVG_NOK", "CHANGELINE", {{ |oView| ChgLineSVG(oView:GetModel(), ::aEstrutDivergencia, ::aListaDivergencia, .T.) }} )

	oView:CreateHorizontalBox("BOX_GRID_L1",33)
	oView:CreateHorizontalBox("BOX_GRID_L2",33)
	oView:CreateHorizontalBox("BOX_GRID_L3",34)

	oView:SetOwnerView("SVG_NOK", 'BOX_GRID_L1')
	oView:SetOwnerView("SG_NOK", 'BOX_GRID_L2')
	oView:SetOwnerView("SG_OK" , 'BOX_GRID_L3')

	oView:EnableTitleView("SVG_NOK"	, STR0013) //"Componentes da lista com Divergência"
	oView:EnableTitleView("SG_NOK"	, STR0014 + Iif(lNOkEstrut, " (1)", "")) //"Estruturas relacionadas com a Divergência"
	oView:EnableTitleView("SG_OK"	, STR0015 + Iif(lOkEstrut, " (2)", "")) //"Estruturas sem Divergências"

	//Adiciona os botões de ação na view.
	oView:AddUserButton(STR0018,"",{|| nButton := 1, oView:CloseOwner() }, STR0018,,,.T.) //"Retornar"

	If lNOkEstrut
		oView:AddUserButton(STR0019 + " (1)","",{|| nButton := 2, oView:CloseOwner() },STR0019,,,.T.) //"Editar estrutura"
		oView:AddUserButton(STR0020 + " (1)","",{|| nButton := 3, VisEstrut(oView,::aModelsSG,1) },STR0021,,,.T.) //"Visualiza Replicado" // "Visualiza como ficará a estrutura com divergências replicado."
	EndIf

	If lOkEstrut
		oView:AddUserButton(STR0020 + " (2)","",{|oView| VisEstrut(oView,::aModelsSG,2) },STR0022,,,.T.) //"Visualiza Replicado" //"Visualiza como ficará a estrutura sem divergências"
	EndIf

	//Proteção para execução com View ativa.
	If oModel != Nil .And. oModel:isActive()
		If nOpc == 1
			HelpInDark( .F. )	//Habilita a apresentação do Help
			Help(' ', 1, STR0023,,STR0024, ; //"DIVERGÊNCIAS!" //"Existem Estruturas/Pré-estruturas que não poderão ser atualizados por não atenderem todos os critérios de validação."
				2, 0,,,,,,{STR0025}) //"Revise os componentes desta lista ou das Estruturas/Pré-estruturas relacionadas."
			HelpInDark( .T. )	//Desabilita a apresentação do Help
		EndIf

		oViewExec:setModel(oModel)
		oViewExec:setView(oView)
		oViewExec:setTitle(STR0026) //"Réplica da Lista nas Estruturas"
		oViewExec:setOperation(1)
		oViewExec:setButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0027/*"Confirmar"*/},{.T.,STR0028/*"Cancelar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}})
		oViewExec:SetCloseOnOk({|| .t.})
		oViewExec:openView(.F.)

		HelpInDark( .T. ) //Desabilita a apresentação do Help

		If nButton == 1 .Or. (oViewExec:getButtonPress() == VIEW_BUTTON_OK .And. Len(::aListaDivergencia) > 0)
			//Botão Retornar, ou Confirmou tendo divergências em tela.
			lStatus := .F.
			Help(' ', 1, STR0029,,STR0024, ; //"Revise a lista!" //"Existem Estruturas/Pré-estruturas que não poderão ser atualizados por não atenderem todos os critérios de validação."
		     2, 0,,,,,,{STR0025}) //"Revise os componentes desta lista ou das Estruturas/Pré-estruturas relacionadas."
		ElseIf nButton == 2
			//Botão para alterar uma estrutura. Irá fechar a tela, e quando confirmar a alteração da estrutura vai processar novamente a réplica para buscar as divergências.
			updEstrut(oModel)
			lStatus := ::ReplicarEstrutura(oModel,2)
		EndIf
	EndIf
Return lStatus

/*/{Protheus.doc} CargaModelosDivergencia
Carrega os modelos com os dados das divergências para exibir em tela.
@type  METHOD
@author lucas.franca
@since 12/02/2019
@version P12
@param  oModel, Object, Modelo de dados do PCPA120
@return Nil
/*/
METHOD CargaModelosDivergencia(oModel) CLASS PCPA120EVDEF
	Local nIndex    := 0
	Local nIndCmp   := 0
	Local oModelSVG := oModel:GetModel("SVGDETAIL")
	Local oSVGNOK   := oModel:GetModel("SVG_NOK")
	Local oSGGOK    := oModel:GetModel("SG_OK")
	Local aFldLista := oSVGNOK:oFormModelStruct:aFields

	//Habilita manutenção dos dados da grid NOK
	oSVGNOK:SetNoUpdateLine(.F.)
	oSVGNOK:SetNoInsertLine(.F.)
	oSVGNOK:SetNoDeleteLine(.F.)

	//Habilita manutenção dos dados da grid OK - sem divergências
	oSGGOK:SetNoUpdateLine(.F.)
	oSGGOK:SetNoInsertLine(.F.)
	oSGGOK:SetNoDeleteLine(.F.)

	//Limpa os dados das grids.
	oSVGNOK:ClearData(.F.,.T.)
	oSGGOK:ClearData(.F.,.T.)

	//Carrega os dados no modelo SVG_NOK
	For nIndex := 1 To Len(::aListaDivergencia)
		oModelSVG:GoLine(::aListaDivergencia[nIndex])

		//Adiciona linha no grid da lista.
		If !Empty(oSVGNOK:GetValue("VG_COMP"))
			oSVGNOK:AddLine()
		EndIf

		//Adiciona as informações no modelo de erros da lista.
		For nIndCmp := 1 To Len(aFldLista)
			oSVGNOK:LoadValue(aFldLista[nIndCmp][3], oModelSVG:GetValue(aFldLista[nIndCmp][3]))
		Next nIndCmp
	Next nIndex

	//Carrega os dados do modelo SG_OK
	For nIndex := 1 To Len(::aEstrutOk)
		If !Empty(oSGGOK:GetValue("GG_COD"))
			oSGGOK:AddLine()
		EndIf
		oSGGOK:LoadValue("GG_COD"  , ::aEstrutOk[nIndex][1])
		oSGGOK:LoadValue("CDESCPAI", ::aEstrutOk[nIndex][2])
		oSGGOK:LoadValue("TIPO"   , ::aEstrutOk[nIndex][3])
	Next nIndex

	//Desabilita manutenção dos dados da grid NOK
	oSVGNOK:SetNoUpdateLine(.T.)
	oSVGNOK:SetNoInsertLine(.T.)
	oSVGNOK:SetNoDeleteLine(.T.)

	//Desabilita manutenção dos dados da grid OK- sem divergências
	oSGGOK:SetNoUpdateLine(.T.)
	oSGGOK:SetNoInsertLine(.T.)
	oSGGOK:SetNoDeleteLine(.T.)

	oSVGNOK:GoLine(1)
	oSGGOK:GoLine(1)

	//Carrega os dados da grid de Pré-estruturas com divergências.
	ChgLineSVG(oModel, ::aEstrutDivergencia, ::aListaDivergencia, .F.)
Return

/*/{Protheus.doc} AltStructDivergencia
Faz as alterações nos structs utilizados pela tela de divergências.
@type  METHOD
@author lucas.franca
@since 12/02/2019
@version P12
@param  nTipo    , Numeric, Tipo do struct (1-Model|2-View)
@param  oStrSVG  , Object , Objeto do Struct do modelo SVG_NOK
@param  oStrGGNOK, Object , Objeto do Struct do modelo SG_NOK
@param  oStrGGOK , Object , Objeto do Struct do modelo SG_OK
@return Nil
/*/
METHOD AltStructDivergencia(nTipo, oStrSVG, oStrGGNOK, oStrGGOK) CLASS PCPA120EVDEF
	If nTipo == 1
		//Adiciona o campo de Mensagem de Erro para a grid das estruturas
		oStrGGNOK:AddField(STR0030								,;	// [01]  C   Titulo do campo //"Falha"
		                   STR0030								,;	// [02]  C   ToolTip do campo //"Falha"
		                   "_FALHA"								,;	// [03]  C   Id do Field
		                   "M"									,;	// [04]  C   Tipo do campo
		                   10									,;	// [05]  N   Tamanho do campo
		                   0									,;	// [06]  N   Decimal do campo
		                   Nil									,;	// [07]  B   Code-block de validação do campo
		                   Nil									,;	// [08]  B   Code-block de validação When do campo
		                   Nil									,;	// [09]  A   Lista de valores permitido do campo
		                   .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
		                   Nil									,;	// [11]  B   Code-block de inicializacao do campo
		                   Nil									,;	// [12]  L   Indica se trata-se de um campo chave
		                   Nil									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		                   .T.									)	// [14]  L   Indica se o campo é virtual

		//Adiciona o campo de Tipo para a grid das estruturas (Estrutura/Pré-estrutura)
		oStrGGNOK:AddField(STR0031								,;	// [01]  C   Titulo do campo //"Tipo"
		                   STR0031								,;	// [02]  C   ToolTip do campo //"Tipo"
		                   "TIPO"								,;	// [03]  C   Id do Field
		                   "C"									,;	// [04]  C   Tipo do campo
		                   1									,;	// [05]  N   Tamanho do campo
		                   0									,;	// [06]  N   Decimal do campo
		                   Nil									,;	// [07]  B   Code-block de validação do campo
		                   Nil									,;	// [08]  B   Code-block de validação When do campo
		                   {"1="+STR0032,"2="+STR0033}			,;	// [09]  A   Lista de valores permitido do campo //ESTRUTURA / PRÉ-ESTRUTURA
		                   .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
		                   Nil									,;	// [11]  B   Code-block de inicializacao do campo
		                   Nil									,;	// [12]  L   Indica se trata-se de um campo chave
		                   Nil									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		                   .T.									)	// [14]  L   Indica se o campo é virtual

		//Adiciona o campo de descrição do produto para a grid sem divergências
		oStrGGOK:AddField(STR0034								,;	// [01]  C   Titulo do campo //"Descrição"
		                  STR0034								,;	// [02]  C   ToolTip do campo //"Descrição"
		                  "CDESCPAI"							,;	// [03]  C   Id do Field
		                  "C"									,;	// [04]  C   Tipo do campo
		                  GetSx3Cache("B1_DESC","X3_TAMANHO")	,;	// [05]  N   Tamanho do campo
		                  0										,;	// [06]  N   Decimal do campo
		                  Nil									,;	// [07]  B   Code-block de validação do campo
		                  Nil									,;	// [08]  B   Code-block de validação When do campo
		                  Nil									,;	// [09]  A   Lista de valores permitido do campo
		                  .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
		                  Nil									,;	// [11]  B   Code-block de inicializacao do campo
		                  Nil									,;	// [12]  L   Indica se trata-se de um campo chave
		                  Nil									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		                  .T.									)	// [14]  L   Indica se o campo é virtual

		//Adiciona o campo de Tipo para a grid de estruturas sem divergências (Estrutura/Pré-estrutura)
		oStrGGOK:AddField(STR0031								,;	// [01]  C   Titulo do campo //"Tipo"
		                  STR0031								,;	// [02]  C   ToolTip do campo "Tipo"
		                  "TIPO"								,;	// [03]  C   Id do Field
		                  "C"									,;	// [04]  C   Tipo do campo
		                  1										,;	// [05]  N   Tamanho do campo
		                  0										,;	// [06]  N   Decimal do campo
		                  Nil									,;	// [07]  B   Code-block de validação do campo
		                  Nil									,;	// [08]  B   Code-block de validação When do campo
		                  {"1="+STR0032,"2="+STR0033}			,;	// [09]  A   Lista de valores permitido do campo //ESTRUTURA / PRÉ-ESTRUTURA
		                  .F.									,;	// [10]  L   Indica se o campo tem preenchimento obrigatório
		                  Nil									,;	// [11]  B   Code-block de inicializacao do campo
		                  Nil									,;	// [12]  L   Indica se trata-se de um campo chave
		                  Nil									,;	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		                  .T.									)	// [14]  L   Indica se o campo é virtual

		//Altera as propriedades dos campos.
		oStrGGNOK:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
		oStrGGNOK:SetProperty("*", MODEL_FIELD_INIT   , Nil)

		oStrGGOK:SetProperty("*" , MODEL_FIELD_OBRIGAT, .F.)
		oStrGGOK:SetProperty("*" , MODEL_FIELD_INIT   , Nil)
	Else
		//Remove o código da lista do struct dos componentes da lista.
		oStrSVG:RemoveField("VG_COD")

		//Adiciona o campo de Mensagem de Erro para a grid das estruturas
		oStrGGNOK:AddField("_FALHA"								,;	// [01]  C   Nome do Campo
		                   "00"									,;	// [02]  C   Ordem
		                   STR0030								,;	// [03]  C   Titulo do campo //"Falha"
		                   STR0030								,;	// [04]  C   Descricao do campo //"Falha"
		                   Nil									,;	// [05]  A   Array com Help
		                   "M"									,; 	// [06]  C   Tipo do campo
		                   ""									,;	// [07]  C   Picture
		                   Nil									,;	// [08]  B   Bloco de Picture Var
		                   Nil									,;	// [09]  C   Consulta F3
		                   .T.									,;	// [10]  L   Indica se o campo é alteravel
		                   Nil									,;	// [11]  C   Pasta do campo
		                   Nil									,;	// [12]  C   Agrupamento do campo
		                   Nil									,;	// [13]  A   Lista de valores permitido do campo (Combo)
		                   Nil									,;	// [14]  N   Tamanho maximo da maior opção do combo
		                   Nil									,;	// [15]  C   Inicializador de Browse
		                   .T.									,;	// [16]  L   Indica se o campo é virtual
		                   Nil									,;	// [17]  C   Picture Variavel
		                   Nil									)	// [18]  L   Indica pulo de linha após o campo

		//Adiciona o campo de Tipo para a grid das estruturas (Estrutura/Pré-estrutura)
		oStrGGNOK:AddField("TIPO"								,;	// [01]  C   Nome do Campo
		                   "01"									,;	// [02]  C   Ordem
		                   STR0031								,;	// [03]  C   Titulo do campo //"Tipo"
		                   STR0031								,;	// [04]  C   Descricao do campo //"Tipo"
		                   Nil									,;	// [05]  A   Array com Help
		                   "C"									,; 	// [06]  C   Tipo do campo
		                   ""									,;	// [07]  C   Picture
		                   Nil									,;	// [08]  B   Bloco de Picture Var
		                   Nil									,;	// [09]  C   Consulta F3
		                   .F.									,;	// [10]  L   Indica se o campo é alteravel
		                   Nil									,;	// [11]  C   Pasta do campo
		                   Nil									,;	// [12]  C   Agrupamento do campo
						   {"1="+STR0032,"2="+STR0033}			,;	// [13]  A   Lista de valores permitido do campo //ESTRUTURA / PRÉ-ESTRUTURA
		                   Nil									,;	// [14]  N   Tamanho maximo da maior opção do combo
		                   Nil									,;	// [15]  C   Inicializador de Browse
		                   .T.									,;	// [16]  L   Indica se o campo é virtual
		                   Nil									,;	// [17]  C   Picture Variavel
		                   Nil									)	// [18]  L   Indica pulo de linha após o campo

		//Adiciona o campo de descrição do produto para a grid sem divergências
		oStrGGOK:AddField("CDESCPAI"							,;	// [01]  C   Nome do Campo
		                  "05"									,;	// [02]  C   Ordem
		                  STR0034								,;	// [03]  C   Titulo do campo //"Descrição"
		                  STR0034								,;	// [04]  C   Descricao do campo //"Descrição"
		                  Nil									,;	// [05]  A   Array com Help
		                  "C"									,; 	// [06]  C   Tipo do campo
		                  Nil									,;	// [07]  C   Picture
		                  Nil									,;	// [08]  B   Bloco de Picture Var
		                  Nil									,;	// [09]  C   Consulta F3
		                  .F.									,;	// [10]  L   Indica se o campo é alteravel
		                  Nil									,;	// [11]  C   Pasta do campo
		                  Nil									,;	// [12]  C   Agrupamento do campo
		                  Nil									,;	// [13]  A   Lista de valores permitido do campo (Combo)
		                  Nil									,;	// [14]  N   Tamanho maximo da maior opção do combo
		                  Nil									,;	// [15]  C   Inicializador de Browse
		                  .T.									,;	// [16]  L   Indica se o campo é virtual
		                  Nil									,;	// [17]  C   Picture Variavel
		                  Nil									)	// [18]  L   Indica pulo de linha após o campo

		//Adiciona o campo de Tipo para a grid sem divergências (Estrutura/Pré-estrutura)
		oStrGGOK:AddField("TIPO"								,;	// [01]  C   Nome do Campo
		                  "0"									,;	// [02]  C   Ordem
		                  STR0031								,;	// [03]  C   Titulo do campo //"Tipo"
		                  STR0031								,;	// [04]  C   Descricao do campo //"Tipo"
		                  Nil									,;	// [05]  A   Array com Help
		                  "C"									,; 	// [06]  C   Tipo do campo
		                  ""									,;	// [07]  C   Picture
		                  Nil									,;	// [08]  B   Bloco de Picture Var
		                  Nil									,;	// [09]  C   Consulta F3
		                  .F.									,;	// [10]  L   Indica se o campo é alteravel
		                  Nil									,;	// [11]  C   Pasta do campo
		                  Nil									,;	// [12]  C   Agrupamento do campo
		                  {"1="+STR0032,"2="+STR0033}			,;	// [13]  A   Lista de valores permitido do campo //ESTRUTURA / PRÉ-ESTRUTURA
		                  Nil									,;	// [14]  N   Tamanho maximo da maior opção do combo
		                  Nil									,;	// [15]  C   Inicializador de Browse
		                  .T.									,;	// [16]  L   Indica se o campo é virtual
		                  Nil									,;	// [17]  C   Picture Variavel
		                  Nil									)	// [18]  L   Indica pulo de linha após o campo

		//Remove campos que não devem ser exibidos
		If oStrGGNOK:HasField("GG_FILIAL")
			oStrGGNOK:RemoveField("GG_FILIAL")
		EndIf
		If oStrGGNOK:HasField("GG_NIV")
			oStrGGNOK:RemoveField("GG_NIV")
		EndIf
		If oStrGGNOK:HasField("GG_NIVINV")
			oStrGGNOK:RemoveField("GG_NIVINV")
		EndIf
		If oStrGGNOK:HasField("GG_OK")
			oStrGGNOK:RemoveField("GG_OK")
		EndIf
		If oStrGGNOK:HasField("GG_USUARIO")
			oStrGGNOK:RemoveField("GG_USUARIO")
		EndIf
	EndIf
Return

/*/{Protheus.doc} ConverteG1
Converte o nome do campo de acordo com o tipo (Estrutura ou Pré-Estrutura)
@type  Static Function
@author marcelo.neumann
@since 04/04/2019
@version P12
@param 01 cCampoSGG, Characters, Nome do campo na tabela SGG
@param 02 cTipo    , Characters, Indica se é Estrutura ("1") ou Pré-Estrutura ("2")
@return cCampoSGG, Characters, Nome do campo convertido para o da tabela SG1 quando for cTipo for "1"
/*/
Static Function ConverteG1(cCampoSGG, cTipo)

	If cTipo == "1"
		cCampoSGG := StrTran(cCampoSGG, "GG_", "G1_")
	EndIf

Return cCampoSGG
/*/{Protheus.doc} getMessage
Recupera as informações de erro do array retornado pelo GetErrorMessage, e retorna uma string.
@type  Static Function
@author lucas.franca
@since 12/02/2019
@version P12
@param aError, Array, Array contendo o erro (obtido por oModel:GetErrorMessage())
@return cError, Character, Retorna o erro formatado em uma string.
/*/
Static Function getMessage(aError)
	Local cError := ""
	cError := aError[MODEL_MSGERR_MESSAGE] + CHR(10) + CHR(13) + aError[MODEL_MSGERR_SOLUCTION]
Return cError

/*/{Protheus.doc} ChgLineSVG
Carrega a grid de divergências de acordo com o item da lista selecionado.
@type  Static Function
@author lucas.franca
@since 13/02/2019
@version P12
@param oModel   , Object , Objeto do modelo.
@param aDiverg  , Array  , Array com os dados das divergências encontradas na estrutura.
@param aListaDiv, Array  , Array com os dados do componente da lista com divergência.
@param lRefresh , Logical, Identifica se deverá ser executado o refresh da grid.
@return Nil
/*/
Static Function ChgLineSVG(oModel, aDiverg, aListaDiv, lRefresh)
	Local oMdl
	Local oMdlSVG   := oModel:GetModel("SVG_NOK")
	Local oMdlSG    := oModel:GetModel("SG_NOK")
	Local oView     := FWViewActive()
	Local aFieldsSG := oMdlSG:oFormModelStruct:aFields
	Local nIndex    := 0
	Local nIndCmp   := 0

	//Habilita manutenção dos dados da grid dos componentes NOK
	oMdlSG:SetNoUpdateLine(.F.)
	oMdlSG:SetNoInsertLine(.F.)
	oMdlSG:SetNoDeleteLine(.F.)

	oMdlSG:ClearData(.F.,.T.)

	//Carrega os dados no modelo SG_NOK
	For nIndex := 1 To Len(aDiverg)
		//Carrega somente os itens relacionados ao item da lista que está selecionado.
		If aDiverg[nIndex][2] != oMdlSVG:GetValue("VG_COMP") .Or. ;
		   aDiverg[nIndex][3] != oMdlSVG:GetValue("VG_TRT")
			Loop
		EndIf

		//Adiciona linha no grid da lista.
		If !Empty(oMdlSG:GetValue("GG_COMP"))
			oMdlSG:AddLine()
		EndIf

		//Recupera o modelo da estrutura/pré-estrutura
		If aDiverg[nIndex][9] == "1"
			oMdl := aDiverg[nIndex][5]:GetModel("SG1_DETAIL")
		Else
			oMdl := aDiverg[nIndex][5]:GetModel("GRID_DETAIL")
		EndIf
		oMdl:GoLine(aDiverg[nIndex][6])

		//Adiciona as informações no modelo de erros da lista.
		If aDiverg[nIndex][8]
			//Se é erro de chave duplicada, adiciona os dados do componente que já existe cadastrado na tela de divergências.
			For nIndCmp := 1 To Len(aFieldsSG)
				If oMdl:HasField(ConverteG1(aFieldsSG[nIndCmp][3], aDiverg[nIndex][9]))
					oMdlSG:LoadValue(aFieldsSG[nIndCmp][3], oMdl:GetValue(ConverteG1(aFieldsSG[nIndCmp][3], aDiverg[nIndex][9])))
				EndIf
			Next nIndCmp
		EndIf

		//Adiciona as demais informações do componente.
		oMdlSG:LoadValue("GG_COD" , aDiverg[nIndex][1])
		oMdlSG:LoadValue("GG_COMP", aDiverg[nIndex][2])
		oMdlSG:LoadValue("GG_TRT" , aDiverg[nIndex][3])
		oMdlSG:LoadValue("_FALHA" , getMessage(aDiverg[nIndex][7]))
		oMdlSG:LoadValue("TIPO"  , aDiverg[nIndex][9])

		//Carrega a descrição do componente caso esteja vazia.
		If Empty(oMdlSG:GetValue("GG_DESC"))
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+aDiverg[nIndex][2]))
				oMdlSG:LoadValue("GG_DESC",SB1->B1_DESC)
			EndIf
		EndIf
	Next nIndex

	//Desabilita manutenção dos dados da grid dos componentes NOK
	oMdlSG:SetNoUpdateLine(.T.)
	oMdlSG:SetNoInsertLine(.T.)
	oMdlSG:SetNoDeleteLine(.T.)
	oMdlSG:GoLine(1)

	If lRefresh .And. oView != Nil .And. oView:IsActive()
		oView:Refresh("V_SG_NOK")
	EndIf

Return Nil

/*/{Protheus.doc} VisEstrut
Abre a tela de visualização da estrutura.
@type  Static Function
@author lucas.franca
@since 13/02/2019
@version P12
@param oView  , Object , Objeto da VIEW ativa.
@param aModels, Array  , Array com os modelos já carregados da estrutura.
@param nTipo  , Numeric, Indica se é visualização de estrutura com divergência (1) ou sem divergência (2)
@return Nil
/*/
Static Function VisEstrut(oView, aModels, nTipo)
	Local oModel     := oView:GetModel()
	Local oMdlSG    := oModel:GetModel(Iif(nTipo==1,"SG_NOK","SG_OK"))
	Local oMdlEstrut
	Local aButtons   := {{.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.F.,STR0053},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
	Local nPos       := 0
	Local cTitle     := ""
	Local cPrograma  := ""
	Local cFldMaster := ""

	nPos := aScan(aModels, {|x| x[2] == oMdlSG:GetValue("GG_COD") .And. x[4] == oMdlSG:GetValue("TIPO")})
	If nPos > 0
		//Estrutura
		If oMdlSG:GetValue("TIPO") == "1"
			cPrograma  := "PCPA200"
			cFldMaster := "SG1_MASTER"

			DbSelectArea("SG1")
			SG1->(DbSetOrder(1))
			SG1->(DbSeek(xFilial("SG1") + oMdlSG:GetValue("GG_COD")))
		Else
			cPrograma  := "PCPA135"
			cFldMaster := "FLD_MASTER"
		EndIf

		oMdlEstrut := FWLoadModel(cPrograma)

		If nTipo == 1
			cTitle := STR0035 //"Estrutura (Parcial) com a Replicação da lista com divergências"
		EndIf

		If nTipo == 2
			cTitle := STR0036 //"Estrutura com a Replicação da lista sem divergências"
		EndIf

		//Carrega os dados no novo modelo para exibição
		oMdlEstrut:SetLoadXML( {|| aModels[nPos][1]:GetXMLData(.T., MODEL_OPERATION_UPDATE , , , , , .F. , ) } )
		oMdlEstrut:SetOperation(MODEL_OPERATION_VIEW)
		
		If oMdlSG:GetValue("TIPO") == "1"
			P200FcPesq(.T.)
			atuEventMd(@aModels[nPos][1], @oMdlEstrut)
		EndIf
		
		oMdlEstrut:Activate()
		//Retira a informação de Execauto do modelo, para que a TREE seja carregada.
		oMdlEstrut:GetModel(cFldMaster):LoadValue("CEXECAUTO", "N")

		//Se for do tipo Estrutura, desabilita o botão "Alterar Revisão"
		If oMdlSG:GetValue("TIPO") == "1"
			P200OpcRev(.F.)
		EndIf

		//Abre a tela
		FWExecView(cTitle, cPrograma, MODEL_OPERATION_VIEW,,,,, aButtons,,,, oMdlEstrut)
		//Finaliza o modelo que foi criado.
		oMdlEstrut:DeActivate()
		oMdlEstrut:Destroy()
	EndIf
Return Nil

/*/{Protheus.doc} addMdGrava
Adiciona um registro duplicado no modelo de gravação para exibição na tela de visualização de divergências.
@type  Static Function
@author lucas.franca
@since 19/02/2019
@version P12
@param 01 oMdlGrid, Object    , Modelo de dados da grid do PCPA135/PCPA200
@param 02 cTipo   , Characters, Indica se é Estrutura ("1") ou Pré-Estrutura ("2")
@return Nil
/*/
Static Function addMdGrava(oMdlGrid, cTipo)
	Local oMdlGrava
	Local aFields   := {}
	Local aError    := {}
	Local nIndCps   := 0
	Local cCampo    := ""

	If cTipo == "1"
		P200GravAl(oMdlGrid:GetModel(), .T., oMdlGrid:GetLine())
	Else
		oMdlGrava := oMdlGrid:GetModel():GetModel("GRAVA_SGG")
		
		aFields := oMdlGrid:oFormModelStruct:aFields

		If !oMdlGrava:IsEmpty()
			//Limpa mensagem de erro do modelo.
			aError := oMdlGrid:GetModel():GetErrorMessage()
			oMdlGrid:GetModel():GetErrorMessage(.T.)

			//Adiciona nova linha
			oMdlGrava:AddLine()

			//Restaura a mensagem de erro do modelo.
			oMdlGrid:GetModel():SetErrorMessage(aError[1],aError[2],aError[3],aError[4],aError[5],aError[6],aError[7],aError[8],aError[9])
		EndIf

		oMdlGrava:LoadValue("LINHA" , oMdlGrid:GetLine())
		oMdlGrava:LoadValue("DELETE", oMdlGrid:IsDeleted())

		//Atribui os dados no modelo de gravação
		For nIndCps := 1 to Len(aFields)
			cCampo := AllTrim(aFields[nIndCps][3])
			oMdlGrava:LoadValue( cCampo, oMdlGrid:GetValue(cCampo) )
		Next nIndCps
	EndIf
Return Nil

/*/{Protheus.doc} SetaValor
Seta os valores no modelo da estrutura/pré-estrutura
@type  Static Function
@author lucas.franca
@since 19/02/2019
@version P12
@param 01 oMdlGrid, Object    , Modelo de dados da SG1 (SG1_DETAIL) ou SGG (GRID_DETAIL)
@param 02 cComp   , Character , Código do componente (Apenas para inclusão de linha)
@param 03 aValues , Array     , Array com os valores que serão atribuídos no modelo.
                                [01] - Sequência
                                [02] - Quantidade
                                [03] - Validade inicial
                                [04] - Validade final
                                [05] - Qtd. Fixa
                                [06] - Grupo opcional
                                [07] - Item opcional
                                [08] - Potência
                                [09] - Tipo vetor
                                [10] - Vetor
                                [11] - Local de consumo
@param 04 cLista  , Character , Código da lista
@param 05 cTipo   , Characters, Indica se é Estrutura ("1") ou Pré-Estrutura ("2")
@return lRet      , Logical   , Indica se foi possível atribuir todos os valores
/*/
Static Function setaValor(oMdlGrid, cComp, aValues, cLista, cTipo)

	Local lRet := .T.

	FwModelActive(oMdlGrid:GetModel())

	If !Empty(cComp)
		lRet := oMdlGrid:SetValue(ConverteG1("GG_COMP"   , cTipo), cComp)
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_TRT"    , cTipo), aValues[1])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_QUANT"  , cTipo), aValues[2])
	EndIf
	If lRet .And. !Empty(aValues[3]) .And. !Empty(aValues[4])
		//Se existe data inicial e final, antes de atualizar os dados no modelo
		//limpa os valores já existentes
		oMdlGrid:ClearField(ConverteG1("GG_INI", cTipo))
		oMdlGrid:ClearField(ConverteG1("GG_FIM", cTipo))
	EndIf
	If lRet .And. !Empty(aValues[3])
		lRet := oMdlGrid:SetValue(ConverteG1("GG_INI"    , cTipo), aValues[3])
	EndIf
	If lRet .And. !Empty(aValues[4])
		lRet := oMdlGrid:SetValue(ConverteG1("GG_FIM"    , cTipo), aValues[4])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_FIXVAR" , cTipo), aValues[5])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_GROPC"  , cTipo), aValues[6])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_OPC"    , cTipo), aValues[7])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_POTENCI", cTipo), aValues[8])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_TIPVEC" , cTipo), aValues[9])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_VECTOR" , cTipo), aValues[10])
	EndIf
	If lRet
		lRet := oMdlGrid:SetValue(ConverteG1("GG_LOCCONS", cTipo), aValues[11])
	EndIf
	If lRet
		lRet := oMdlGrid:VldLineData()
	EndIf

	If !lRet
		If !Empty(cComp)
			oMdlGrid:LoadValue(ConverteG1("GG_COMP", cTipo), cComp)
			SB1->(dbSetOrder(1))
			If SB1->(MsSeek(xFilial("SB1")+cComp))
				oMdlGrid:LoadValue(ConverteG1("GG_DESC", cTipo), SB1->B1_DESC)
			EndIf
		EndIf
		oMdlGrid:LoadValue(ConverteG1("GG_TRT"    , cTipo), aValues[1])
		oMdlGrid:LoadValue(ConverteG1("GG_QUANT"  , cTipo), aValues[2])
		If !Empty(aValues[3])
			oMdlGrid:LoadValue(ConverteG1("GG_INI", cTipo), aValues[3])
		EndIf
		If !Empty(aValues[4])
			oMdlGrid:LoadValue(ConverteG1("GG_FIM", cTipo), aValues[4])
		EndIf
		oMdlGrid:LoadValue(ConverteG1("GG_FIXVAR" , cTipo), aValues[5])
		oMdlGrid:LoadValue(ConverteG1("GG_GROPC"  , cTipo), aValues[6])
		oMdlGrid:LoadValue(ConverteG1("GG_OPC"    , cTipo), aValues[7])
		oMdlGrid:LoadValue(ConverteG1("GG_POTENCI", cTipo), aValues[8])
		oMdlGrid:LoadValue(ConverteG1("GG_TIPVEC" , cTipo), aValues[9])
		oMdlGrid:LoadValue(ConverteG1("GG_VECTOR" , cTipo), aValues[10])
		oMdlGrid:LoadValue(ConverteG1("GG_LOCCONS", cTipo), aValues[11])


		oMdlGrid:LoadValue(ConverteG1("GG_LISTA", cTipo), "")
		oMdlGrid:DeleteLine()
		oMdlGrid:LoadValue(ConverteG1("GG_LISTA", cTipo), cLista)

		//Adiciona a linha duplicada no modelo de gravação para exibir na tela de divergências posteriormente.
		addMdGrava(oMdlGrid, cTipo)
	Else
		oGridDetail:LoadValue(ConverteG1("GG_LISTA", cTipo), cLista)
	EndIf
Return lRet

/*/{Protheus.doc} updEstrut
Abre a tela para realizar a modificação da estrutura/pré-estrutura
@type  Static Function
@author lucas.franca
@since 20/02/2019
@version P12
@param oModel, Object, Modelo de dados da tela
@return Nil
/*/
Static Function updEstrut(oModel)

	Local cCod    := ""
	Local oMdl135 := Nil

	//Estrutura
	If oModel:GetModel("SG_NOK"):GetValue("TIPO") == "1"
		cCod := oModel:GetModel("SG_NOK"):GetValue("GG_COD")
		SG1->(dbSetOrder(1))
		If SG1->(dbSeek(xFilial("SG1")+cCod))
			oMdl135 := FWLoadModel("PCPA200")
			oMdl135:setOperation(MODEL_OPERATION_UPDATE)
			
			P200FcPesq(.T.)
			
			If oMdl135:Activate()
				P200OpcRev(.F.)

				oMdl135:GetModel("SG1_MASTER"):LoadValue("CREVABERTA", P200IniRev(cCod))

				FWExecView(STR0054, "PCPA200", MODEL_OPERATION_UPDATE,,,{|| P200AvaRev()},,,,,, oMdl135) //"Alterar Estrutura"
			EndIf
		EndIf
	Else
		SGG->(dbSetOrder(1))
		If SGG->(dbSeek(xFilial("SGG")+oModel:GetModel("SG_NOK"):GetValue("GG_COD")))
			oMdl135 := FWLoadModel("PCPA135")
			FWExecView(STR0037, "PCPA135", OP_ALTERAR,,,,,,,,, oMdl135) //"Alterar Pré-estrutura"
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} GetMdlEveD
Recupera a referência do objeto dos Eventos do modelo.
@type  Static Function
@author marcelo.neumann
@since 04/02/2019
@version P12
@param 01 oModel  , Object   , Modelo de dados
@param 02 cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent, Object   , Referência do evento do modelo de dados.
/*/
Static Function GetMdlEveD(oModel, cIdEvent)

	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent

/*/{Protheus.doc} PCPA120Lis
Verifica se a lista esta em uso por alguma pré-estrutura ou estrutura (independente da revisão)
@author Marcelo Neumann
@since 10/04/2019
@version P12
@param 01 cCodLista, characters, codigo da lista de operacoes
@param 02 lUsaHelp, logico, indica se vai mostrar o help na tela
@return lUsado  , logical, indica se a lista está sendo usada
/*/
Function PCPA120Lis(cCodLista, lUsaHelp)

	Local cAliasTmp	:= GetNextAlias()
	Local cQuery    := ""
	Local lUsado    := .F.

	cQuery := "SELECT DISTINCT 1"
	cQuery +=  " FROM " + RetSqlName("SGG")
	cQuery += " WHERE GG_FILIAL  = '" + xFilial("SGG") + "'"
	cQuery +=   " AND GG_LISTA   = '" + cCodLista      + "'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	If !(cAliasTmp)->(Eof())
		lUsado := .T.
		If lUsaHelp
			Help( ,  , "Help", ,  STR0007, ; //"Impossível excluir, a lista está em uso."
				1, 0, , , , , , {STR0008} ) //"Desvincular a lista das pré-estruturas nas quais esteja sendo usada."
		EndIf
	EndIf
	(cAliasTmp)->(DbCloseArea())

	If !lUsado
		cQuery := "SELECT DISTINCT 1"
		cQuery +=  " FROM " + RetSqlName("SG1")
		cQuery += " WHERE G1_FILIAL  = '" + xFilial("SG1") + "'"
		cQuery +=   " AND G1_LISTA   = '" + cCodLista      + "'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
		If !(cAliasTmp)->(Eof())
			lUsado := .T.
			If lUsaHelp
				Help( ,  , "Help", ,  STR0007, ; //"Impossível excluir, a lista está em uso."
					1, 0, , , , , , {STR0055} ) //"Exclua as estruturas que utilizam essa lista."
			EndIf
		Endif
		(cAliasTmp)->(DbCloseArea())
	EndIf

Return lUsado

/*/{Protheus.doc} atuEventMd
Copia os dados dos eventos de um modelo origem para um modelo destino.

@type  Static Function
@author lucas.franca
@since 03/01/2020
@version P12.1.29
@param oModelOrig, Object, Modelo de dados origem (modelo que possui os dados do evento)
@param oModelDest, Object, Modelo de dados destino (modelo que recebe os dados do evento)
@Return Nil
/*/
Static Function atuEventMd(oModelOrig, oModelDest)
	Local aNames    := {}
	Local nIndex    := 0
	Local nIndData  := 0
	Local nPosOrig  := 0
	Local nPosDest  := 0
	Local nPosDtIni := 0
	Local nPosDtFim := 0
	Local oLines    := Nil
	Local oFields   := Nil


	If (oModelOrig != Nil .And. AttIsMemberOf(oModelOrig, "oEventHandler", .T.) .And. oModelOrig:oEventHandler != NIL) .And.;
	   (oModelDest != Nil .And. AttIsMemberOf(oModelDest, "oEventHandler", .T.) .And. oModelDest:oEventHandler != NIL)

		nPosOrig := aScan(oModelOrig:oEventHandler:aEvents, {|x| x:cIdEvent == "PCPA200EVDEF"})
		nPosDest := aScan(oModelDest:oEventHandler:aEvents, {|x| x:cIdEvent == "PCPA200EVDEF"})

		If nPosOrig > 0 .And. nPosDest > 0
			//Cria um novo objeto JSON no evento de destino
			oModelDest:oEventHandler:aEvents[nPosDest]:oDadosCommit := JsonObject():New()
			//Faz a cópia dos dados do JSON do evento origem para o evento destino.
			oModelDest:oEventHandler:aEvents[nPosDest]:oDadosCommit:FromJson(oModelOrig:oEventHandler:aEvents[nPosOrig]:oDadosCommit:ToJson())

			//Faz o ajuste dos campos que são do tipo DATA, para que fiquem no formato DATA correto.
			//Quando é feita a cópia do objeto JSON, as datas são convertidas para string.
			oFields := oModelDest:oEventHandler:aEvents[nPosDest]:oDadosCommit["oFields"]
			nPosDtIni := oFields["G1_INI"]
			nPosDtFim := oFields["G1_FIM"]

			If nPosDtIni <> Nil .And. nPosDtFim <> Nil
				For nIndData := 1 To 2
					If nIndData == 1
						oLines := oModelDest:oEventHandler:aEvents[nPosDest]:oDadosCommit["oLines"]
					Else
						oLines := oModelDest:oEventHandler:aEvents[nPosDest]:oDadosCommit["oErros"]
					EndIf
					//Recupera todas as chaves dos registros.
					aNames := oLines:GetNames()
					For nIndex := 1 To Len(aNames)
						If oLines[aNames[nIndex]] <> Nil
							//Faz a conversão das datas.
							oLines[aNames[nIndex]][nPosDtIni] := StoD(StrTran(oLines[aNames[nIndex]][nPosDtIni], "/", ""))
							oLines[aNames[nIndex]][nPosDtFim] := StoD(StrTran(oLines[aNames[nIndex]][nPosDtFim], "/", ""))
						EndIf
					Next nIndex
					aSize(aNames, 0)
				Next nIndData
			EndIf

		EndIf

	EndIf
Return Nil
