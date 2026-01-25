#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136.CH"

Static __lDicAtu := Nil

/*/{Protheus.doc} PCPA136Csv
Importação de Demandas via CSV
@type Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param oModel  , Objeto, Modelo de dados. Utilizado quando a importação é realizada dentro da edição das demandas.
@return lStatus, Lógico, Identifica se a importação foi executada ou não.
/*/
Function PCPA136Csv(oModel)

	Local aArea   := GetArea()
	Local lStatus := .F.

	If AbrePergun()
		//Executa a importação
		Processa({|| lStatus := ProcImport(oModel)}, STR0049, STR0050, .F.) //"Importando Demandas" - "Aguarde..."
	EndIf

	RestArea(aArea)

Return lStatus

/*/{Protheus.doc} PCPDirOpen
Função da Consulta Padrão 'PCPDIR' que abre janela para selecionar um arquivo
@type Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@return .T.
/*/
Function PCPDirOpen()

	Local cType    := STR0103 + " (*.csv) |*.csv|" //"Arquivo CSV"
	Local cArquivo := ""
	Default lAutoMacao := .F.

	IF !lAutoMacao
		cArquivo := cGetFile(cType, STR0102, , , .T.) //"Selecione o arquivo para importação"
	ENDIF

	If !Empty(cArquivo)
		MV_PAR01 := AllTrim(cArquivo)
	EndIf

Return .T.

/*/{Protheus.doc} PCPDirRet
Função de retorno da Consulta Padrão 'PCPDIR'
@type Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@return MV_PAR01, Caracter, Identifica se a importação foi executada ou não.
/*/
Function PCPDirRet()

Return MV_PAR01

/*/{Protheus.doc} ProcImport
Processa a importação do arquivo CSV
@type Static Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param oModel, Objeto, Modelo de dados. Se não for passado, será ativado sem view.
@return Nil
/*/
Static Function ProcImport(oModel)

	Local aError     := {}
	Local aLinhas    := {}
	Local aRegistro  := {}
	Local cDocum     := ""
	Local cMOpc      := ""
	Local cOpc       := ""
	Local cProduto   := ""
	Local cRevisao   := ""
	Local cTipo      := ""
	Local dData      := ""
	Local lBrowse    := .F.
	Local lContinua  := .T.
	Local lErro      := .F.
	Local lImpArmz   := .T.
	Local nIndLin    := 1
	Local nLenGrid   := 0
	Local nLenReg    := 0
	Local nLinAtual  := 0
	Local nLinErro   := 0
	Local nQuant     := 0
	Local nTotal     := 0
	Local oFile      := FWFileReader():New(MV_PAR01)
	Local oModelErr  := Nil
	Local oModelGrid := Nil
	Default lAutoMacao := .F.

	//Se houver erro de abertura abandona processamento
	IF !lAutoMacao
		If !oFile:Open()
			Help(' ', 1, "Help", , STR0104, ; //"Falha na abertura do arquivo."
				2, 0, , , , , ,  {STR0105})  //"Verifique se o arquivo informado é válido."
			Return .F.
		EndIf
	ENDIF

	//Recupera todas as linhas do arquivo
	aLinhas := oFile:getAllLines()
	oFile:Close()
	FreeObj(oFile)

	nTotal := Len(aLinhas)
	If nTotal == 0
		Return .F.
	EndIf

	//Total da barra de progresso
	ProcRegua(nTotal)

	//Se não receber o modelo de dados, ativa na demanda posicionada no browse
	If oModel == Nil
		lBrowse := .T.
		oModel  := FWLoadModel("PCPA136")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		IF !lAutoMacao
			oModel:Activate()
		ENDIF
	EndIf

	oModelGrid := oModel:GetModel("SVR_DETAIL")

	//Inicia o modelo para listar os registros inconsistentes
	oModelErr  := FWLoadModel("PCPA136Imp")
	oModelErr:SetOperation(MODEL_OPERATION_INSERT)
	oModelErr:Activate()
	
	If P136ParExt("PCP136CSV", 9)
		lImpArmz := MV_PAR09 == 1
	EndIf

	//Percorre todas as linhas do arquivo
	For nIndLin := 1 To nTotal
		IncProc(STR0107 + cValToChar(nIndLin) + STR0108 + cValToChar(nTotal) + ".") //"Importando" "de"

		aSize(aRegistro, 0)
		aLinhas[nIndLin] := CorrigeLin(aLinhas[nIndLin])
		aRegistro        := StrTokArr(aLinhas[nIndLin], ";")
		nLenReg          := Len(aRegistro)

		If nLenReg > 0
			//Verifica se a linha atual está válida
			If !oModelGrid:IsEmpty()
				nLenGrid  := oModelGrid:Length()
				nLinAtual := oModelGrid:AddLine()
				If nLinAtual == nLenGrid .And. nLinAtual <> nLinErro
					GravaLog(oModelErr, oModel)
					oModelGrid:DeleteLine(.T.,.T.)
				EndIf
			EndIf

			lErro := .F.

			//Tratamento para não abortar caso seja informada uma posição inexistente
			If MV_PAR02 <> 0 .And. nLenReg >= MV_PAR02
				cTipo := aRegistro[MV_PAR02]
			EndIf
			If !cTipo $ "12349"
				cTipo := '5'
			EndIf

			If nLenReg >= MV_PAR03
				cProduto := aRegistro[MV_PAR03]
			EndIf

			If nLenReg >= MV_PAR04
				If cPaisLoc # "EUA"
					nQuant := StrTran(aRegistro[MV_PAR04], ".", "" )
					nQuant := StrTran(aRegistro[MV_PAR04], ",", ".")
				EndIf
				nQuant := Val(nQuant)
			EndIf

			If MV_PAR05 <> 0 .And. nLenReg >= MV_PAR05 .And. !Empty(aRegistro[MV_PAR05])
				dData := CToD(aRegistro[MV_PAR05])
			Else
				dData := MV_PAR06
			EndIf

			If MV_PAR07 <> 0 .And. nLenReg >= MV_PAR07 .And. !Empty(aRegistro[MV_PAR07])
				cDocum := AllTrim(aRegistro[MV_PAR07])
			Else
				cDocum := MV_PAR08
			EndIf

			If P136ParExt("PCP136CSV", 10)
				If MV_PAR10 <> 0 .And. nLenReg >= MV_PAR10 .And. !Empty(aRegistro[MV_PAR10])
					cRevisao := AllTrim(aRegistro[MV_PAR10])
				EndIf
			EndIf

			//Verifica se o valor pode ser atribuído nos devidos campos
			//Data
			If Empty(dData)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0100) //"Data não informada."
				lErro := .T.
			Else
				If !oModelGrid:SetValue("VR_DATA", dData)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
			EndIf
			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Produto
			If Empty(cProduto)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0101) //"Produto não informado."
				lErro := .T.
			Else
				If !oModelGrid:SetValue("VR_PROD", cProduto)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
			EndIf
			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Quantidade
			If Empty(nQuant)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0109) //"Quantidade não informada."
				lErro := .T.
			Else
				If !oModelGrid:LoadValue("VR_QUANT", nQuant)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
			EndIf
			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Busca informações do Produto
			If !GetInfoPrd(cProduto, @cOpc, @cMopc)
				GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, STR0110) //"Produto não encontrado."
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf
 
			// Se parâmetrizado para não importar o armazém padrão na demadnda limpa o campo VR_LOCAL
			// Se importa o armazém padrão deixa o valor preenchido pela trigger do campo VR_PROD
			If !lImpArmz
				oModelGrid:SetValue("VR_LOCAL", "")
			EndIf

			If lErro
				nLinErro := oModelGrid:GetLine()
				oModelGrid:DeleteLine(.T.,.T.)
				Loop
			EndIf

			//Carrega demais informações
			oModelGrid:LoadValue("VR_TIPO"  , cTipo)
			oModelGrid:LoadValue("VR_DOC"   , cDocum)
			oModelGrid:LoadValue("VR_OPC"   , cOpc)
			oModelGrid:LoadValue("VR_MOPC"  , cMopc)
			oModelGrid:LoadValue("VR_REGORI", 0)
			If GetSx3Cache("VR_REV", "X3_TAMANHO") > 0
			  	If !oModelGrid:SetValue("VR_REV", cRevisao)
					GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData)
					lErro := .T.
				EndIf
				If lErro
					nLinErro := oModelGrid:GetLine()
					oModelGrid:DeleteLine(.T.,.T.)
					Loop
				EndIf
			EndIf
			If __lDicAtu
				oModelGrid:LoadValue("VR_ORIGEM", 'CSV')
			EndIf
		EndIf
	Next nIndLin

	//Se ocorreu algum erro alerta o usuário e abre a tela de registros inconsistentes
	If nLinErro > 0
		oModelGrid:VldData()

		Help(' ',1,"Help",,STR0055,2,0,,,,,,) //"Alguns registros não serão importados pois não atendem todos os critérios de validação deste programa."

		oModelErr:nOperation := MODEL_OPERATION_VIEW
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
				   oModelErr)              //Model que será usado pelo View

		If lBrowse
			lContinua := MsgYesNo(STR0073,STR0072) //"Deseja importar os registros válidos?" - "Continuar a importação?"
		EndIf
	EndIf

	If lContinua
		If lBrowse
			IF !lAutoMacao
				If !oModel:VldData( ,.T.) .Or. !oModel:CommitData()
					aError := oModel:GetErrorMessage()
					Help(' ', 1, "Help", , aError[MODEL_MSGERR_MESSAGE], 1, 0, , , , , ,  {aError[MODEL_MSGERR_SOLUCTION]})
					aSize(aError, 0)
					aError := Nil
				EndIf

				oModel:DeActivate()
			ENDIF
		Else
			oModelGrid:GoLine(1)
		EndIf
	EndIf

	//Limpa os arrays da memória
	aSize(aRegistro, 0)
	aRegistro := Nil
	aSize(aLinhas, 0)
	aLinhas := Nil

Return

/*/{Protheus.doc} GravaLog
Grava o modelo de Log de importação com o erro ocorrido
@type Static Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param 01 oModelErr, Objeto  , Modelo onde serão gravados os registros não importados
@param 02 oModel   , Objeto  , Modelo principal
@param 03 cTipo    , Caracter, Tipo de demanda
@param 04 cProduto , Caracter, Código do produto
@param 05 nQuant   , Numérico, Quantidade da demanda
@param 06 dData    , Caracter, Data da demanda
@return Nil
/*/
Static Function GravaLog(oModelErr, oModel, cTipo, cProduto, nQuant, dData, cMsgErro)

	Local aError     := oModel:GetErrorMessage()
	Default cTipo    := oModel:GetModel("SVR_DETAIL"):GetValue("VR_TIPO")
	Default cProduto := oModel:GetModel("SVR_DETAIL"):GetValue("VR_PROD")
	Default nQuant   := oModel:GetModel("SVR_DETAIL"):GetValue("VR_QUANT")
	Default dData    := oModel:GetModel("SVR_DETAIL"):GetValue("VR_DATA")
	Default cMsgErro := ""
	Default lAutoMacao := .F.

	IF !lAutoMacao
		If !oModelErr:GetModel("GRID_LOG"):IsEmpty()
			oModelErr:GetModel("GRID_LOG"):AddLine()
		EndIf
	ENDIF

	If Empty(cMsgErro)
		cMsgErro := AllTrim(aError[MODEL_MSGERR_MESSAGE])
	EndIf

	IF !lAutoMacao
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_TIPO" , cTipo)
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_PROD" , cProduto)
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_QUANT", nQuant)
		oModelErr:GetModel("GRID_LOG"):LoadValue("VR_DATA" , dData)
		oModelErr:GetModel("GRID_LOG"):LoadValue("CMOTIVO" , cMsgErro)
	ENDIF

Return

/*/{Protheus.doc} GetInfoPrd
Grava o modelo de Log de importação com o erro ocorrido
@type Static Function
@author marcelo.neumann
@since 01/04/2020
@version P12
@param 01 cProduto, Caracter, Código do produto
@param 02 cOpc    , Caracter, Código do opcional (retorna por referência)
@param 03 cMopc   , Caracter, Memo do opcional (retorna por referência)
@return lExiste, Lógico, Indica se o produto foi encontrado na SB1
/*/
Static Function GetInfoPrd(cProduto, cOpc, cMopc)

	Local aAreaB1 := SB1->(GetArea())
	Local lExiste := .F.

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1") + cProduto))
		cOpc    := SB1->B1_OPC
		cMopc   := SB1->B1_MOPC
		lExiste := .T.
	EndIf
	SB1->(RestArea(aAreaB1))

Return lExiste

/*/{Protheus.doc} CorrigeLin
Corrige a linha para a utilização do StrTokArr
@type Static Function
@author marcelo.neumann
@since 06/04/2020
@version P12
@param  cLinha, Caracter, Linha a ser corrigida
@return cLinha, Caracter, Linha corrigida
/*/
Static Function CorrigeLin(cLinha)

	cLinha := StrTran(cLinha, ";;", "; ;")
	cLinha := StrTran(cLinha, ";;", "; ;")

	If SubStr(cLinha,1,1) == ";"
		cLinha := " " + cLinha
	EndIf

Return cLinha

/*/{Protheus.doc} AbrePergun
Abre a tela com os parâmetros para importação
@type Static Function
@author marcelo.neumann
@since 31/08/2020
@version P12
@return lStatus, Lógico, Indica se a tela de Pergunte foi confirmada
/*/
Static Function AbrePergun()

	Local lStatus := .F.
	Default lAutoMacao := .F.
/*
	Valores do pergunte PCP136IMP:
	MV_PAR01 - Diretório
	MV_PAR02 - Posição Tipo
	MV_PAR03 - Posição Produto
	MV_PAR04 - Posição Quantidade
	MV_PAR05 - Posição Data Previsão
	MV_PAR06 - Data Previsão
	MV_PAR07 - Posição Documento
	MV_PAR08 - Documento
	MV_PAR09 - Utiliza armazém padrão
	MV_PAR10 - Posição Revisão Estrutura
*/
	If ExistePerg()
		IF !lAutoMacao
			While Pergunte("PCP136CSV")
				If ParamOk()
					lStatus := .T.
					Exit
				EndIf
			End
		ENDIF
	Else
		lStatus := InformaPar()
	EndIf

Return lStatus


/*/{Protheus.doc} ExistePerg
Verifica se o dicionário de dados está atualizado com a Pergunta da importação CSV
@type Static Function
@author lucas.franca
@since 03/08/2020
@version P12
@return lRet, Lógico, Indica se a opção de importação CSV deverá utilizar a Pergunte do dicionário
/*/
Static Function ExistePerg()
	Local lRet   := .T.
	Local oPergs := Nil

	If __lDicAtu == Nil
		oPergs := FwSX1Util():New()
		oPergs:AddGroup("PCP136CSV")
		oPergs:SearchGroup()
		__lDicAtu := Len(oPergs:GetGroup("PCP136CSV")[2]) > 0

		FreeObj(oPergs)
	EndIf

	lRet := __lDicAtu

Return lRet

/*/{Protheus.doc} InformaPar
Abre tela para informar os parâmetros de processamento (quando não possui a Pergunte no dicionário)
@type Static Function
@author marcelo.neumann
@since 31/08/2020
@version P12
@return lRet, Lógico, Indica se os parâmetros foram informados
/*/
Static Function InformaPar()

	Local aRet       := {}
	Local aParamBox  := {}
	Local lObrigaTip := !__lDicAtu
	Local lRet       := .F.
	Default lAutoMacao := .F.

	aAdd(aParamBox, {6, STR0112, Space(99)     , "" ,     "", "",  80, .T., STR0103 + " (*.csv) |*.csv|"}) //"Diretório" - "Arquivo CSV"
	aAdd(aParamBox, {1, STR0113, 0             , "9",   , "", "",  20, lObrigaTip}) //"Posição Tipo"
	aAdd(aParamBox, {1, STR0114, 0             , "9",   , "", "",  20, .T.}) //"Posição Produto"
	aAdd(aParamBox, {1, STR0115, 0             , "9",   , "", "",  20, .T.}) //"Posição Quantidade"
	aAdd(aParamBox, {1, STR0116, 0             , "9",   , "", "",  20, .F.}) //"Posição Data"
	aAdd(aParamBox, {1, STR0117, CToD(Space(8)), "" , "", "", "",  50, .F.}) //"Data"
	aAdd(aParamBox, {1, STR0118, 0             , "9",   , "", "",  20, .F.}) //"Posição Documento"
	aAdd(aParamBox, {1, STR0119, Space(30)     , "" , "", "", "", 100, .F.}) //"Documento"

	IF !lAutoMacao
		If ParamBox(aParamBox, STR0120, @aRet, {|| ParamOk()}, /*5*/, /*6*/, /*7*/, /*8*/, /*9*/, "PCPA136CSV", .T., .F.) //"Parâmetros -"
			lRet := .T.
		EndIf
	ENDIF

Return lRet

/*/{Protheus.doc} ParamOk
Valida os parâmetros para processamento
@type Static Function
@author marcelo.neumann
@since 31/08/2020
@version P12
@return lRet, Lógico, Indica se os parâmetros estão válidos
/*/
Static Function ParamOk()

	Local lRet := .F.

	If Empty(MV_PAR03) .Or. MV_PAR03 == 0
		Help(' ', 1, "Help", , STR0094, ; //"Não foi informada a posição do produto no arquivo."
			 2, 0, , , , , ,  {STR0095})  //"Informe a posição do produto no arquivo."

	ElseIf Empty(MV_PAR04) .Or. MV_PAR04 == 0
		Help(' ', 1, "Help", , STR0096, ; //"Não foi informada a posição da quantidade no arquivo."
			 2, 0, , , , , ,  {STR0097})  //"Informe a posição da quantidade no arquivo."

	ElseIf Empty(MV_PAR05) .And. Empty(MV_PAR06)
		Help(' ', 1, "Help", , STR0098, ; //"Não foi informada a data ou a posição da data no arquivo."
			 2, 0, , , , , ,  {STR0099})  //"Informe a data a ser utilizada ou a posição da data no arquivo."
	Else
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} validaPar
Verifica se um parâmetro esta presente no grupo de perguntas.
@type  Function
@author Lucas Fagundes
@since 17/02/2023
@version P12
@param 01 cGrupoPerg, Caracter, Nome do grupo de perguntas.
@param 02 nParam    , Numerico, Posição do parâmetro no grupo de perguntas.
@return lRet, Logico, Indica que o parâmetro existe.
/*/
Function P136ParExt(cGrupoPerg, nParam)
	Local lRet     := .F.
	Local oSx1Util := FwSX1Util():New()

	oSx1Util:addGroup(cGrupoPerg)
	oSx1Util:searchGroup()
	
	If Len(oSx1Util:getGroup(cGrupoPerg)[2]) >= nParam
		lRet := .T.
	EndIf

	FwFreeObj(oSx1Util)
Return lRet
