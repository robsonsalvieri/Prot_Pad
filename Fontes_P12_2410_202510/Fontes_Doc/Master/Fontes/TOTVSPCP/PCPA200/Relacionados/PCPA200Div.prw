#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEDITPANEL.CH"
#INCLUDE "PCPA200.CH"

#DEFINE FOLDER_OK  "FWSKIN_SUCCES_ICO_CHK"
#DEFINE FOLDER_NOK "FWSKIN_ERROR_ICO_CHK"

Static _oDbTree   := Nil
Static _oDiverg   := Nil
Static _oTreeData := Nil
Static _lMvRevFil := SuperGetMv("MV_REVFIL" , .F., .F.)
Static _lMvArqPrd := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"

/*/{Protheus.doc} P200Diverg
Mapa de Divergências

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@return Nil
/*/
Function P200Diverg(cProduto, cRevisao)
	Local aButtons  := {{.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                    {.T.,STR0242},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
	Local oModelDiv := FWLoadModel("PCPA200Div")

	SG1->(dbSetOrder(1))
	oModelDiv:SetOperation(MODEL_OPERATION_VIEW)
	oModelDiv:Activate()
	oModelDiv:GetModel("CABECALHO"):LoadValue("G1_COD" , cProduto)
	oModelDiv:GetModel("CABECALHO"):LoadValue("CREVPAI", cRevisao)

	FWExecView(STR0243             , ; //Titulo da janela - "Mapa de Divergências"
	           'PCPA200Div'        , ; //Nome do programa-fonte
	           MODEL_OPERATION_VIEW, ; //Indica o código de operação (usará a do modelo oModelDiv)
	           NIL                 , ; //Objeto da janela em que o View deve ser colocado
	           NIL                 , ; //Bloco de validação do fechamento da janela
	           NIL                 , ; //Bloco de validação do botão OK
	           55                  , ; //Percentual de redução da janela
	           aButtons            , ; //Botões que serão habilitados na janela
	           NIL                 , ; //Bloco de validação do botão Cancelar
	           NIL                 , ; //Identificador da opção do menu
	           NIL                 , ; //Indica o relacionamento com os botões da tela
	           oModelDiv)              //Model que será usado pelo View

	oModelDiv:DeActivate()
	oModelDiv:Destroy()

	FwFreeObj(_oTreeData)
	FreeObj(_oDiverg)
	FreeObj(_oDbTree)
	FwFreeArray(aButtons)

Return Nil

/*/{Protheus.doc} ModelDef
Definição do Modelo

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@return oModel, Objeto, Instância do modelo
/*/
Static Function ModelDef()
	Local oModel   := MPFormModel():New('PCPA200Div')
	Local oStruCab := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})

	//Altera os campos da estrutura
	AltStruMod(@oStruCab)

	//CABECALHO - Modelo do cabeçalho
	oModel:AddFields("CABECALHO", /*cOwner*/, oStruCab)
	oModel:GetModel("CABECALHO"):SetDescription(STR0243) //"Mapa de Divergências"
	oModel:GetModel("CABECALHO"):SetOnlyQuery()
	oModel:GetModel("CABECALHO"):SetOnlyView()

	oModel:SetDescription(STR0243) //"Mapa de Divergências"
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@return oView, Objeto, Instância da view
/*/
Static Function ViewDef()
	Local oStruCab := FWFormStruct(2, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oView    := FWFormView():New()

	//Altera os campos da estrutura para a view
	AltStrView(@oStruCab)

	oView:SetModel(FWLoadModel("PCPA200Div"))

	//V_CABECALHO - View do Cabeçalho
	oView:AddField("V_CABECALHO", oStruCab, "CABECALHO")

	//V_TREE - View da Tree com a Estrutura
	oView:AddOtherObject("V_TREE", {|oPanel| CriaTree(oPanel)})

	//Divisão da tela
	oView:CreateHorizontalBox("BOX_HEADER", 70, , .T.)
	oView:CreateHorizontalBox("BOX_TREE"  , 100)

	//Relaciona a SubView com o Box
	oView:SetOwnerView("V_CABECALHO", 'BOX_HEADER')
	oView:SetOwnerView("V_TREE"     , 'BOX_TREE')

	oView:SetViewProperty("V_CABECALHO", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 3 } )

	//Adiciona botões na tela
	oView:AddUserButton(STR0069, "", {|| BtnLegenda()}, STR0069, , , .T.) //"Legenda"

	//Eventos de ativação da View
	oView:SetAfterViewActivate({|oView| AfterView(oView)})

Return oView

/*/{Protheus.doc} AltStruMod
Altera os campos da estrutura do Model

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param oStruCab, Objeto, Estrutura do modelo (CABECALHO)
@return Nil
/*/
Static Function AltStruMod(oStruCab)

	oStruCab:SetProperty("G1_COD", MODEL_FIELD_INIT , FWBuildFeature(STRUCT_FEATURE_INIPAD, " "))
 	oStruCab:SetProperty("G1_COD", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID , " "))

	oStruCab:AddField(RetTitle("B1_DESC")                  ,; // [01]  C   Titulo do campo
	                  RetTitle("B1_DESC")                  ,; // [02]  C   ToolTip do campo
	                  "CDESCPAI"                           ,; // [03]  C   Id do Field
	                  "C"                                  ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("B1_DESC","X3_TAMANHO")  ,; // [05]  N   Tamanho do campo
	                  0                                    ,; // [06]  N   Decimal do campo
	                  NIL                                  ,; // [07]  B   Code-block de validação do campo
	                  NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                  .T.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                  .T.)                                    // [14]  L   Indica se o campo é virtual

	oStruCab:AddField(STR0015                              ,; // [01]  C   Titulo do campo  //"Revisão"
	                  STR0015                              ,; // [02]  C   ToolTip do campo //"Revisão"
	                  "CREVPAI"                            ,; // [03]  C   Id do Field
	                  "C"                                  ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("B1_REVATU","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                  0                                    ,; // [06]  N   Decimal do campo
	                  {||.T.}                              ,; // [07]  B   Code-block de validação do campo
	                  NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                  NIL                                  ,; // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	                  .T.)                                    // [14]  L   Indica se o campo é virtual

	oStruCab:AddField(STR0017                              ,; // [01]  C   Titulo do campo  //"Quantidade Base"
	                  STR0017                              ,; // [02]  C   ToolTip do campo //"Quantidade Base"
	                  "NQTBASE"                            ,; // [03]  C   Id do Field
	                  "N"                                  ,; // [04]  C   Tipo do campo
	                  GetSx3Cache("B1_QB","X3_TAMANHO")    ,; // [05]  N   Tamanho do campo
	                  GetSx3Cache("B1_QB","X3_DECIMAL")    ,; // [06]  N   Decimal do campo
	                  NIL                                  ,; // [07]  B   Code-block de validação do campo
	                  NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                  NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                  .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                  NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                  NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                  .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                  .T.)                                    // [14]  L   Indica se o campo é virtual

Return Nil

/*/{Protheus.doc} AltStrView
Edita os campos da estrutura da View

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param oStruCab, Objeto, Estrutura da View V_CABECALHO
@return Nil
/*/
Static Function AltStrView(oStruCab)

	oStruCab:SetProperty("G1_COD", MVC_VIEW_TITULO   , STR0011) //"Produto"
	oStruCab:SetProperty("G1_COD", MVC_VIEW_LOOKUP   , Nil)

	If GetSx3Cache("G1_COD", "X3_TAMANHO") > 15
		oStruCab:SetProperty("G1_COD", MVC_VIEW_PICT, "@S10")
	EndIf

	oStruCab:AddField("CDESCPAI"                 ,; // [01]  C   Nome do Campo
	                  "3"                        ,; // [02]  C   Ordem
	                  STR0018                    ,; // [03]  C   Titulo do campo    //"Descrição"
	                  STR0018                    ,; // [04]  C   Descricao do campo //"Descrição"
	                  NIL                        ,; // [05]  A   Array com Help
	                  "C"                        ,; // [06]  C   Tipo do campo
	                  NIL                        ,; // [07]  C   Picture
	                  NIL                        ,; // [08]  B   Bloco de Picture Var
	                  NIL                        ,; // [09]  C   Consulta F3
	                  .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                  NIL                        ,; // [11]  C   Pasta do campo
	                  NIL                        ,; // [12]  C   Agrupamento do campo
	                  NIL                        ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL                        ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL                        ,; // [15]  C   Inicializador de Browse
	                  .T.                        ,; // [16]  L   Indica se o campo é virtual
	                  NIL                        ,; // [17]  C   Picture Variavel
	                  NIL                        )  // [18]  L   Indica pulo de linha após o campo

	oStruCab:AddField("CREVPAI"                  ,; // [01]  C   Nome do Campo
	                  "4"                        ,; // [02]  C   Ordem
	                  STR0015                    ,; // [03]  C   Titulo do campo    //"Revisão"
	                  STR0015                    ,; // [04]  C   Descricao do campo //"Revisão"
	                  NIL                        ,; // [05]  A   Array com Help
	                  "C"                        ,; // [06]  C   Tipo do campo
	                  PesqPict('SB1','B1_REVATU'),; // [07]  C   Picture
	                  NIL                        ,; // [08]  B   Bloco de Picture Var
	                  NIL                        ,; // [09]  C   Consulta F3
	                  .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                  NIL                        ,; // [11]  C   Pasta do campo
	                  NIL                        ,; // [12]  C   Agrupamento do campo
	                  NIL                        ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL                        ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL                        ,; // [15]  C   Inicializador de Browse
	                  .T.                        ,; // [16]  L   Indica se o campo é virtual
	                  NIL                        ,; // [17]  C   Picture Variavel
	                  NIL                        )  // [18]  L   Indica pulo de linha após o campo

	oStruCab:AddField("NQTBASE"                  ,; // [01]  C   Nome do Campo
	                  "5"                        ,; // [02]  C   Ordem
	                  STR0017                    ,; // [03]  C   Titulo do campo    //"Quantidade Base"
	                  STR0017                    ,; // [04]  C   Descricao do campo //"Quantidade Base"
	                  NIL                        ,; // [05]  A   Array com Help
	                  "N"                        ,; // [06]  C   Tipo do campo
	                  PesqPict('SB1','B1_QB')    ,; // [07]  C   Picture
	                  NIL                        ,; // [08]  B   Bloco de Picture Var
	                  NIL                        ,; // [09]  C   Consulta F3
	                  .F.                        ,; // [10]  L   Indica se o campo é alteravel
	                  NIL                        ,; // [11]  C   Pasta do campo
	                  NIL                        ,; // [12]  C   Agrupamento do campo
	                  NIL                        ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                  NIL                        ,; // [14]  N   Tamanho maximo da maior opção do combo
	                  NIL                        ,; // [15]  C   Inicializador de Browse
	                  .T.                        ,; // [16]  L   Indica se o campo é virtual
	                  NIL                        ,; // [17]  C   Picture Variavel
	                  NIL                        )  // [18]  L   Indica pulo de linha após o campo

Return Nil

/*/{Protheus.doc} BtnLegenda
Abre a tela com a legenda

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@return Nil
/*/
Static Function BtnLegenda()
	Local oDlg  := Nil
	Local oBmp1 := Nil
	Local oBmp2 := Nil
	Local oBut1 := Nil

	DEFINE MSDIALOG oDlg TITLE STR0069 OF oMainWnd PIXEL FROM 0,0 TO 172,360 //"Legenda"

	@ 003, 003 TO 065,178 LABEL STR0069 PIXEL //"Legenda"
	@ 019, 010 BITMAP oBmp1 RESNAME FOLDER_OK SIZE 16,16 NOBORDER PIXEL
	@ 019, 024 SAY OemToAnsi(STR0245) OF oDlg PIXEL //"Sem divergência"
	@ 033, 010 BITMAP oBmp2 RESNAME FOLDER_NOK SIZE 16,16 NOBORDER PIXEL
	@ 033, 024 SAY OemToAnsi(STR0246) OF oDlg PIXEL //"Com divergência"

	DEFINE SBUTTON oBut1 FROM 070, 152 TYPE 1 ACTION (oDlg:End()) ENABLE of oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

Return Nil

/*/{Protheus.doc} CriaTree
Cria o objeto da Tree no painel

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param oPanel, Objeto, Painel onde será criada a Tree
@return Nil
/*/
Static Function CriaTree(oPanel)
	Local cHeader := PadR(STR0013, 120) + ";" + ; //"Estrutura"
	                 PadR(STR0082, 20)  + ";" + ; //"Quantidade"
	                 PadR(STR0244, 20)  + ""      //"Unidade de Medida"

	_oTreeData := JsonObject():New()
	_oDbTree   := DbTree():New(0, 0, 100, 100, oPanel, {|| TreeChange()}, , .T., , , cHeader)
	_oDbTree:Align := CONTROL_ALIGN_ALLCLIENT

Return Nil

/*/{Protheus.doc} AfterView
Função executada após ativar a view

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param oView, Objeto, Instância da View
@return Nil
/*/
Static Function AfterView(oView)
	Local cProduto   := ""
	Local cQtdBase   := ""
	Local cRevisao   := ""
	Local cUniMedida := ""
	Local nQtdBase   := 0
	Local oModel     := oView:GetModel()

	cProduto := oModel:GetModel("CABECALHO"):GetValue("G1_COD")
	cRevisao := oModel:GetModel("CABECALHO"):GetValue("CREVPAI")

	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1") + cProduto))
		oModel:GetModel("CABECALHO"):LoadValue("CDESCPAI", SB1->B1_DESC)
		cUniMedida := SB1->B1_UM
	EndIf

	nQtdBase := RetFldProd(cProduto, "B1_QB")
	cQtdBase := cValToChar(nQtdBase)
	oModel:GetModel("CABECALHO"):LoadValue("NQTBASE", nQtdBase)

	BuscaDiver(cProduto, cRevisao, cQtdBase)

	//Insere os dados na Tree
	MontaTree(cProduto, cQtdBase, cUniMedida, cRevisao)

	//Atualiza a view
	oView:Refresh()
	_oDbTree:SetFocus()

Return Nil

/*/{Protheus.doc} BuscaDiver
Busca as divergências na estrutura do produto passado (query recursiva) e carrega a variável _oDiverg

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param 01 cProduto, Caracter, Código do produto
@param 02 cRevisao, Caracter, Revisão do produto
@param 03 cQtdBase, Caracter, Quantidade base do produto
@return Nil
/*/
Static Function BuscaDiver(cProduto, cRevisao, cQtdBase)
	Local cAliasQry := GetNextAlias()
	Local cBanco    := Upper(TCGetDB())
	Local cQuery    := ""
	Local cRecno    := ""
	Local nIndex    := 1
	Local nTotal    := 0

	cQuery := "WITH RastroRecursivo(G1_COD, G1_COMP, G1_QUANT, Qtd_Pai, Nivel, R_E_C_N_O_, PathPai)"
	cQuery +=  " AS ("
	cQuery +=     " SELECT SG1_Base.G1_COD,"
	cQuery +=            " SG1_Base.G1_COMP,"
	cQuery +=            " SG1_Base.G1_QUANT,"
	cQuery +=            " Cast(" + cQtdBase + " As Double Precision) Qtd_Pai,"
	cQuery +=            " 1 AS Nivel,"
	cQuery +=            " SG1_Base.R_E_C_N_O_,"
	cQuery +=            " Cast( 0 AS VarChar(4000) ) AS PathPai"
	cQuery +=       " FROM " + RetSqlName( "SG1" ) + " SG1_Base"
	cQuery +=      " WHERE SG1_Base.G1_FILIAL  = '" + xFilial("SG1")  + "'"
	cQuery +=        " AND SG1_Base.D_E_L_E_T_ = ' '"
	cQuery +=        " AND SG1_Base.G1_COD     = '" + cProduto        + "'"
	cQuery +=        " AND SG1_Base.G1_INI    <= '" + DToS(dDataBase) + "'"
	cQuery +=        " AND SG1_Base.G1_FIM    >= '" + DToS(dDataBase) + "'"
	cQuery +=        " AND '" + cRevisao + "' BETWEEN SG1_Base.G1_REVINI AND SG1_Base.G1_REVFIM"
	cQuery +=      " UNION ALL"
	cQuery +=     " SELECT SG1_Filho.G1_COD,"
	cQuery +=            " SG1_Filho.G1_COMP,"
	cQuery +=            " SG1_Filho.G1_QUANT,"
	cQuery +=            " Qry_Recurs.G1_QUANT Qtd_Pai,"
	cQuery +=            " Qry_Recurs.Nivel + 1 AS Nivel,"
	cQuery +=            " SG1_Filho.R_E_C_N_O_,"
	cQuery +=            " Cast(Qry_Recurs.PathPai || ' -> ' || Cast(Qry_Recurs.R_E_C_N_O_ AS VarChar(4000)) AS VarChar(4000)) PathPai"
	cQuery +=       " FROM " + RetSqlName( "SG1" ) + " SG1_Filho"
	cQuery +=      " INNER JOIN RastroRecursivo Qry_Recurs"
	cQuery +=         " ON Qry_Recurs.G1_COMP = SG1_Filho.G1_COD"
	cQuery +=      " INNER JOIN " + RetSqlName( "SB1" ) + " SB1_Pai"
	cQuery +=         " ON SB1_Pai.B1_COD = SG1_Filho.G1_COD"
	cQuery +=        " AND SB1_Pai.D_E_L_E_T_ = ' '"
	cQuery +=        " AND SB1_Pai.B1_FILIAL  = '" + xFilial("SB1") + "'"

	If _lMvRevFil .And. _lMvArqPrd
		cQuery +=   " LEFT OUTER JOIN " + RetSqlName('SBZ') + " SBZ_Pai"
		cQuery +=     " ON SBZ_Pai.BZ_COD     = SB1_Pai.B1_COD"
		cQuery +=    " AND SBZ_Pai.BZ_FILIAL  = '" + xFilial("SBZ") + "'"
		cQuery +=    " AND SBZ_Pai.D_E_L_E_T_ = ' '"		
	EndIf

	cQuery +=        " AND SG1_Filho.D_E_L_E_T_ = ' '"
	cQuery +=        " AND SG1_Filho.G1_FILIAL  = '" + xFilial("SG1")  + "'"
	cQuery +=        " AND SG1_Filho.G1_INI    <= '" + DToS(dDataBase) + "'"
	cQuery +=        " AND SG1_Filho.G1_FIM    >= '" + DToS(dDataBase) + "'"
	cQuery +=   " )"
	cQuery += " SELECT PathPai, Qtd_Pai, Quantidade "
	cQuery +=   " FROM (SELECT PathPai,"
	cQuery +=                " Qtd_Pai,"
	cQuery +=                " SUM(G1_QUANT) Quantidade"
	cQuery +=           " FROM RastroRecursivo Resultado"
	cQuery +=          " GROUP BY PathPai , Qtd_Pai) RastroRec"
	cQuery +=  " WHERE Quantidade <> Qtd_Pai"

	//Realiza ajustes da Query para cada banco
	If "POSTGRES" $ cBanco
		//Altera sintaxe da clausula WITH
		cQuery := StrTran(cQuery, 'WITH ', 'WITH recursive ')

		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf "MSSQL" $ cBanco
		//Substitui concatenação || por +
		cQuery := StrTran(cQuery, '||', '+')
	EndIf

	_oDiverg := JsonObject():New()

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasQry, .T., .T.)
	While !(cAliasQry)->(Eof())
		If ((cAliasQry)->Qtd_Pai == (cAliasQry)->Quantidade)
			Exit
		EndIf
		
		aPaths := StrToKArr2(Trim((cAliasQry)->PathPai), " -> ")
		nTotal := Len(aPaths)

		For nIndex := 1 To nTotal
			cRecno := cValToChar(aPaths[nIndex])

			If nIndex == nTotal
				_oDiverg[cRecno] := .T.
			Else
				If !_oDiverg:HasProperty(cRecno)
					_oDiverg[cRecno] := .F.
				EndIf
			EndIf
		Next nIndex

		aSize(aPaths,0)
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} MontaTree
Monta a Tree com o produto pai e seus filhos (primeiro nível apenas)

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param 01 cProduto  , Caracter, Código do produto Pai
@param 02 cQtdBase  , Caracter, Quantidade base do produto Pai
@param 03 cUniMedida, Caracter, Unidade de medida do produto Pai
@param 04 cRevisao  , Caracter, Revisão do produto Pai
@return Nil
/*/
Static Function MontaTree(cProduto, cQtdBase, cUniMedida, cRevisao)
	Local cCargo     := PadR("0", 100)
	Local cPrompt    := PadR(cProduto + ";" + cQtdBase + ";" + cUniMedida, 200)
	Local lDivergent := (Len(_oDiverg:GetNames()) > 0)

	_oDbTree:BeginUpdate()
	_oDbTree:AddTree(cPrompt, .T.                          , ;
	                 IIf(lDivergent, FOLDER_NOK, FOLDER_OK), ;
					 IIf(lDivergent, FOLDER_NOK, FOLDER_OK), , , cCargo)

	_oTreeData[cCargo] := JsonObject():New()
	_oTreeData[cCargo]["PRODUTO"]  := cProduto
	_oTreeData[cCargo]["QUANT"]    := cQtdBase
	_oTreeData[cCargo]["RECNO"]    := "0"
	_oTreeData[cCargo]["TEM_FAKE"] := .F.

	If AddFilhos(cProduto, _oTreeData[cCargo]["RECNO"], cRevisao)
		cPrompt := I18N(STR0247, {Trim(cProduto)}) + ";" + cQtdBase //"Quantidade do produto pai (#1[ATRIBUTO]#)"
		_oDbTree:AddItem(cPrompt, "QTD_PAI", "", "", , , 2)
	EndIf

	_oDbTree:EndTree()
	_oDbTree:EndUpdate()
	_oDbTree:Refresh()

Return Nil

/*/{Protheus.doc} AddFilhos
Adiciona os filhos na Tree com nó fake caso o mesmo possua estrutura

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@param 01 cCodPai  , Caracter, Código do produto que terá a sua estrutura adicionada
@param 02 cRecnoPai, Caracter, Recno do produto
@param 03 cRevisao , Caracter, Revisão do produto
@return   lTemFilho, Lógico  , Indica se o produto passado possui estrutura
/*/
Static Function AddFilhos(cCodPai, cRecnoPai, cRevisao)
	Local cAliasQry  := GetNextAlias()
	Local cCargo     := ""
	Local cCargoFake := ""
	Local cIdLocPai  := _oDbTree:CurrentNodeId
	Local cPrompt    := ""
	Local cQuery     := ""
	Local cRecno     := ""
	Local lDivergent := .F.
	Local lTemFilho  := .F.
	Local nTotal     := 0

	cQuery :=     "SELECT DISTINCT SG1_Pai.G1_COD Prod_Pai,"
	cQuery +=           " SG1_Pai.R_E_C_N_O_,"
	cQuery +=           " SB1_Filho.B1_COD,"
	cQuery +=           " SB1_Filho.B1_UM,"
	cQuery +=           " SG1_Pai.G1_TRT,"
	cQuery +=           " SG1_Pai.G1_QUANT,"
	cQuery +=           " SG1_Filho.G1_COD Estr_Filho"
	cQuery +=      " FROM " + RetSqlName("SG1") + " SG1_Pai"
	cQuery +=      " LEFT OUTER JOIN " + RetSqlName("SG1") + " SG1_Filho"
	cQuery +=        " ON SG1_Filho.G1_FILIAL  = '" + xFilial("SG1") + "'"
	cQuery +=       " AND SG1_Filho.G1_COD     = SG1_Pai.G1_COMP"
	cQuery +=       " AND SG1_Filho.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN " + RetSqlName("SB1") + " SB1_Filho"
	cQuery +=        " ON SB1_Filho.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery +=       " AND SB1_Filho.B1_COD     = SG1_Pai.G1_COMP"
	cQuery +=       " AND SB1_Filho.D_E_L_E_T_ = ' '"
	cQuery +=     " INNER JOIN " + RetSqlName("SB1") + " SB1_Pai"
	cQuery +=        " ON SB1_Pai.B1_FILIAL  = '" + xFilial("SB1") + "'"
	cQuery +=       " AND SB1_Pai.B1_COD     = SG1_Pai.G1_COD"
	cQuery +=       " AND SB1_Pai.D_E_L_E_T_ = ' '"

	If _lMvRevFil .And. _lMvArqPrd
		cQuery +=  " LEFT OUTER JOIN " + RetSqlName('SBZ') + " SBZ_Pai"
		cQuery +=    " ON SBZ_Pai.BZ_COD     = SB1_Filho.B1_COD"
		cQuery +=   " AND SBZ_Pai.BZ_FILIAL  = '" + xFilial("SBZ") + "'"
		cQuery +=   " AND SBZ_Pai.D_E_L_E_T_ = ' '"
	EndIf

	cQuery +=       " AND SG1_Pai.G1_FILIAL  = '" + xFilial("SG1") + "'"
	cQuery +=       " AND SG1_Pai.G1_COD     = '" + cCodPai + "'"
	cQuery +=       " AND SG1_Pai.D_E_L_E_T_ = ' '"
	cQuery +=       " AND '" + cRevisao        + "' BETWEEN SG1_Pai.G1_REVINI AND SG1_Pai.G1_REVFIM"
	cQuery +=       " AND '" + DToS(dDataBase) + "' BETWEEN SG1_Pai.G1_INI    AND SG1_Pai.G1_FIM"
	cQuery +=     " ORDER BY SB1_Filho.B1_COD, SG1_Pai.G1_TRT"

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasQry, .T., .T.)
	If !(cAliasQry)->(Eof())
		lTemFilho := .T.

		While !(cAliasQry)->(Eof())
			cRecno := cValToChar((cAliasQry)->R_E_C_N_O_)

			If _oDiverg:HasProperty(cRecnoPai) .And. _oDiverg[cRecnoPai]
				lDivergent := .T.
			Else
				If _oDiverg:HasProperty(cRecno)
					lDivergent := .T.
				Else
					lDivergent := .F.
				EndIf
			EndIf

			cPrompt := AllTrim((cAliasQry)->B1_COD)
			If !Empty((cAliasQry)->G1_TRT)
				cPrompt += " (" + AllTrim((cAliasQry)->G1_TRT) + ")"
			EndIf
			cPrompt += ";" + cValToChar((cAliasQry)->G1_QUANT) + ";" + (cAliasQry)->B1_UM

			cCargo := PadR(cRecnoPai + "_" + cRecno, 100)

			_oDbTree:AddItem(cPrompt, cCargo                       , ;
							 IIf(lDivergent, FOLDER_NOK, FOLDER_OK), ;
							 IIf(lDivergent, FOLDER_NOK, FOLDER_OK), , , 2)

			_oTreeData[cCargo] := JsonObject():New()
			_oTreeData[cCargo]["PRODUTO"]  := (cAliasQry)->B1_COD
			_oTreeData[cCargo]["QUANT"]    := cValToChar((cAliasQry)->G1_QUANT)
			_oTreeData[cCargo]["RECNO"]    := cRecno
			_oTreeData[cCargo]["TEM_FAKE"] := !(Empty((cAliasQry)->Estr_Filho))

			If !Empty((cAliasQry)->Estr_Filho)
				cCargoFake := PadR("F_" + cCargo, 100)

				_oDbTree:TreeSeek(cCargo)
				_oDbTree:AddItem("", cCargoFake, "", "", , , 2)

				_oTreeData[cCargoFake] := JsonObject():New()
				_oTreeData[cCargoFake]["PRODUTO"]  := "FAKE"
				_oTreeData[cCargoFake]["QUANT"]    := "0"
				_oTreeData[cCargoFake]["RECNO"]    := ""
				_oTreeData[cCargoFake]["TEM_FAKE"] := .F.

				_oTreeData[cCargo]["CARGOFAKE"] := cCargoFake

				//Foca no item que foi selecionado da Tree
				_oDbTree:PTGotoToNode(cIdLocPai)
				_oDbTree:PTCollapse()
			EndIf

			nTotal += (cAliasQry)->G1_QUANT
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())

		cPrompt := STR0248 + ";" + cValToChar(nTotal) //"Soma dos componentes"
		_oDbTree:AddItem(cPrompt, "SOMA", "", "", , , 2)

		//Foca no item que foi selecionado da Tree
		_oDbTree:PTGotoToNode(cIdLocPai)
	EndIf

Return lTemFilho

/*/{Protheus.doc} TreeChange
Evento disparado ao clicar em algum nó da Tree (explode a estrutura)

@author marcelo.neumann
@since 01/08/2022
@version 1.0
@return Nil
/*/
Static Function TreeChange()
	Local cCargClick := _oDbTree:GetCargo()
	Local cCargFake  := ""
	Local cIdClick   := _oDbTree:CurrentNodeId
	Local cProdClick := ""
	Local cPrompt    := ""
	Local cRecno     := ""

	If _oTreeData:HasProperty(cCargClick)
		cProdClick := _oTreeData[cCargClick]["PRODUTO"]
		cRecno     := _oTreeData[cCargClick]["RECNO"]

		If _oTreeData[cCargClick]["TEM_FAKE"]
			cCargFake := _oTreeData[cCargClick]["CARGOFAKE"]
			_oDbTree:TreeSeek(cCargFake)
			_oDbTree:BeginUpdate()
			_oDbTree:DelItem()
			_oTreeData:DelName(cCargFake)
			_oTreeData[cCargClick]["TEM_FAKE"] := .F.

			If AddFilhos(cProdClick, cRecno, PCPREVATU(cProdClick))
				cPrompt := I18N(STR0247, {Trim(cProdClick)}) + ";" + _oTreeData[cCargClick]["QUANT"] //"Quantidade do produto pai (#1[ATRIBUTO]#)"
				_oDbTree:AddItem(cPrompt, "QTD_PAI", "", "", , , 2)
				_oDbTree:AddItem("", "SEPARADOR", "", "", , , 2)
			EndIf

			_oDbTree:PTGotoToNode(cIdClick)
			_oDbTree:EndUpdate()
		EndIf
	EndIf

Return Nil
