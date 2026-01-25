#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA120.CH"
#INCLUDE "FWEDITPANEL.CH"

/*/{Protheus.doc} PCPA120Imp
Abre uma tela para pesquisar e importar os componentes de uma estrutura
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 oViewPai, object, objeto da View Principal
@return Nil
/*/
Function PCPA120Imp(oViewPai)

	Local oModelPai := oViewPai:GetModel()
	Local nLineGrid := oModelPai:GetModel("SVGDETAIL"):Length()
	Local lImportou := .F.
	Local aButtons  := { {.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0038},; //"Importar"
	                     {.T.,STR0028},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil    } } //"Cancelar"

	FWExecView(STR0039                                                     , ; //Titulo da janela - "Importar Estrutura"
	           "PCPA120Imp"                                                , ; //Nome do programa-fonte
	           MODEL_OPERATION_UPDATE                                      , ; //Indica o código de operação
	           NIL                                                         , ; //Objeto da janela em que o View deve ser colocado
	           {|oView| SetModify(oView:GetModel(),lImportou)}             , ; //Bloco de validação do fechamento da janela
	           {|oView| lImportou := BotaoOk(oView:GetModel(),oModelPai)}  , ; //Bloco de validação do botão OK
	           65                                                          , ; //Percentual de redução da janela
	           aButtons                                                    , ; //Botões que serão habilitados na janela
	           {|oView| lImportou := .F., SetModify(oView:GetModel(),.F.)} , ; //Bloco de validação do botão Cancelar
	           NIL                                                         , ; //Identificador da opção do menu
	           NIL                                                         , ; //Indica o relacionamento com os botões da tela
	           NIL                                                         )   //Model que será usado pelo View

	If lImportou
		oViewPai:Refresh()
		oModelPai:GetModel("SVGDETAIL"):GoLine(nLineGrid)
	EndIf

Return

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 27/03/2019
@version P12
@return oModel
/*/
Static Function ModelDef()

	Local oModel     := MPFormModel():New('PCPA120Imp')
	Local oStrMaster := FWFormStruct(1, "SG1", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oStrDetail := FWFormStruct(1, "SG1")

	//Altera campos das estruturas
	AltStruMod(@oStrMaster)

	//FLD_PRODUTO - Modelo do Cabeçalho
	oModel:AddFields("FLD_PRODUTO", /*cOwner*/, oStrMaster, , ,{|| LoadProdut()})
	oModel:GetModel("FLD_PRODUTO"):SetDescription(STR0041) //"Produto"
	oModel:GetModel("FLD_PRODUTO"):SetOnlyQuery(.T.)

	//GRID_COMPONENTES - Modelo da Grid
	oModel:AddGrid("GRID_COMPONENTES", "FLD_PRODUTO", oStrDetail)
	oModel:GetModel("GRID_COMPONENTES"):SetDescription(STR0006) //"Componentes"
	oModel:GetModel("GRID_COMPONENTES"):SetOnlyQuery(.T.)

	oModel:SetDescription(STR0039) //"Importar Estrutura"
	oModel:SetPrimaryKey({})

	TravaAlter(oModel, .T.)

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 27/03/2019
@version P12
@return oView
/*/
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("PCPA120Imp")
	Local oStrMaster := FWFormStruct(2, "SG1", {|cCampo|   "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})
	Local oStrDetail := FWFormStruct(2, "SG1", {|cCampo| ! "|" + AllTrim(cCampo) + "|" $ "|G1_COD|"})

	//Altera campos das estruturas
	AltStrView(@oStrMaster, @oStrDetail)

	oView:SetModel(oModel)

	//V_FLD_PRODUTO - View do Cabeçalho
	oView:AddField("V_FLD_PRODUTO", oStrMaster, "FLD_PRODUTO")

	//V_GRID_COMPONENTES - View da Grid com os componentes que serão importados
	oView:AddGrid("V_GRID_COMPONENTES", oStrDetail, "GRID_COMPONENTES")

	//Divisão da tela
	oView:CreateHorizontalBox("BOX_HEADER",  70, , .T.)
	oView:CreateHorizontalBox("BOX_GRID"  , 100)

	//Seta layout para a tela (3 colunas)
	oView:SetViewProperty("V_FLD_PRODUTO", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 3 } )

	//Relaciona a SubView com o Box
	oView:SetOwnerView("V_FLD_PRODUTO"     , "BOX_HEADER")
	oView:SetOwnerView("V_GRID_COMPONENTES", "BOX_GRID")

	//Função chamada ao sair do campo
	oView:SetFieldAction("G1_COD"  , {|oView| SetModify(oView:GetModel(), .F.)})
	oView:SetFieldAction("CREVISAO", {|oView| SetModify(oView:GetModel(), .F.)})

	//Desativa a exibição da mensagem ao confirmar a tela
	oView:ShowUpdateMsg(.F.)

Return oView

/*/{Protheus.doc} AltStruMod
Edita os campos da estrutura do Model
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param oStrMaster, object, estrutura do modelo FLD_PRODUTO
@return Nil
/*/
Static Function AltStruMod(oStrMaster)

	//Adiciona novos campos
	oStrMaster:AddField(STR0042                              ,; // [01]  C   Titulo do campo  - "Revisão"
	                    STR0042                              ,; // [02]  C   ToolTip do campo - "Revisão"
	                    "CREVISAO"                           ,; // [03]  C   Id do Field
	                    "C"                                  ,; // [04]  C   Tipo do campo
	                    GetSx3Cache("B1_REVATU","X3_TAMANHO"),; // [05]  N   Tamanho do campo
	                    0                                    ,; // [06]  N   Decimal do campo
	                    NIL                                  ,; // [07]  B   Code-block de validação do campo
	                    NIL                                  ,; // [08]  B   Code-block de validação When do campo
	                    NIL                                  ,; // [09]  A   Lista de valores permitido do campo
	                    .F.                                  ,; // [10]  L   Indica se o campo tem preenchimento obrigatório
	                    NIL                                  ,; // [11]  B   Code-block de inicializacao do campo
	                    NIL                                  ,; // [12]  L   Indica se trata-se de um campo chave
	                    .F.                                  ,; // [13]  L   Indica se o campo não pode receber valor em uma operação de update
	                    .T.                                  )  // [14]  L   Indica se o campo é virtual

	oStrMaster:AddField(RetTitle("B1_DESC")                  ,; // [01]  C   Titulo do campo  - "Descrição"
	                    RetTitle("B1_DESC")                  ,; // [02]  C   ToolTip do campo - "Descrição"
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
	                    .T.                                  )  // [14]  L   Indica se o campo é virtual

	//Gatilho para preenchimento do campo Revisão
	oStrMaster:AddTrigger("G1_COD", "CREVISAO", , {|| TriggerCod()})

	//Validação do campo Revisão (carrega a Grid)
	oStrMaster:SetProperty("CREVISAO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "P120VldRev()"))

Return

/*/{Protheus.doc} AltStrView
Edita os campos da estrutura da View
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 oStrMaster, object, estrutura da View V_FLD_PRODUTO
@param 02 oStrDetail, object, estrutura da View V_GRID_COMPONENTES
@return Nil
/*/
Static Function AltStrView(oStrMaster, oStrDetail)

	//Adiciona novos campos
	oStrMaster:AddField("CREVISAO"                   ,; // [01]  C   Nome do Campo
	                    "02"                         ,; // [02]  C   Ordem
	                    STR0042                      ,; // [03]  C   Titulo do campo    - "Revisão"
	                    STR0042                      ,; // [04]  C   Descricao do campo - "Revisão"
	                    NIL                          ,; // [05]  A   Array com Help
	                    "C"                          ,; // [06]  C   Tipo do campo
	                    PesqPict('SB1','B1_REVATU',3),; // [07]  C   Picture
	                    NIL                          ,; // [08]  B   Bloco de Picture Var
	                    NIL                          ,; // [09]  C   Consulta F3
	                    .T.                          ,; // [10]  L   Indica se o campo é alteravel
	                    NIL                          ,; // [11]  C   Pasta do campo
	                    NIL                          ,; // [12]  C   Agrupamento do campo
	                    NIL                          ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                          ,; // [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                          ,; // [15]  C   Inicializador de Browse
	                    .T.                          ,; // [16]  L   Indica se o campo é virtual
	                    NIL                          ,; // [17]  C   Picture Variavel
	                    NIL                          )  // [18]  L   Indica pulo de linha após o campo

	oStrMaster:AddField("CDESCPAI"                   ,; // [01]  C   Nome do Campo
	                    "03"                         ,; // [02]  C   Ordem
	                    RetTitle("B1_DESC")          ,; // [03]  C   Titulo do campo    - "Descrição"
	                    RetTitle("B1_DESC")          ,; // [04]  C   Descricao do campo - "Descrição"
	                    NIL                          ,; // [05]  A   Array com Help
	                    "C"                          ,; // [06]  C   Tipo do campo
						"@S15"                       ,; // [07]  C   Picture
	                    NIL                          ,; // [08]  B   Bloco de Picture Var
	                    NIL                          ,; // [09]  C   Consulta F3
	                    .F.                          ,; // [10]  L   Indica se o campo é alteravel
	                    NIL                          ,; // [11]  C   Pasta do campo
	                    NIL                          ,; // [12]  C   Agrupamento do campo
	                    NIL                          ,; // [13]  A   Lista de valores permitido do campo (Combo)
	                    NIL                          ,; // [14]  N   Tamanho maximo da maior opção do combo
	                    NIL                          ,; // [15]  C   Inicializador de Browse
	                    .T.                          ,; // [16]  L   Indica se o campo é virtual
	                    NIL                          ,; // [17]  C   Picture Variavel
	                    NIL                          )  // [18]  L   Indica pulo de linha após o campo

	//Altera propriedades dos campos
	oStrMaster:SetProperty("G1_COD" , MVC_VIEW_ORDEM , "01")
	oStrMaster:SetProperty("G1_COD" , MVC_VIEW_LOOKUP, "SB1PG1")
	oStrMaster:SetProperty("G1_COD" , MVC_VIEW_PICT  , "@!S10")

	oStrDetail:SetProperty("G1_COMP", MVC_VIEW_WIDTH , 150)
	oStrDetail:SetProperty("G1_DESC", MVC_VIEW_WIDTH , 250)

Return

/*/{Protheus.doc} TriggerCod
Função executada após informar o Código do Produto
@author Marcelo Neumann
@since 27/03/2019
@version P12
@return cRevAtu, characters, revisão atual do produto (B1_REVATU)
/*/
Static Function TriggerCod()

	Local oModel   := FwModelActive()
	Local oMdlCab  := oModel:GetModel("FLD_PRODUTO")
	Local oMdlDet  := oModel:GetModel("GRID_COMPONENTES")
	Local cProduto := oMdlCab:GetValue("G1_COD")
	Local cDesc    := ""
	Local cRevAtu  := ""

	If Empty(oMdlCab:GetValue("G1_COD"))
		oMdlCab:LoadValue("CREVISAO", "")
		oMdlDet:ClearData(.F.,.T.)
	Else
		cDesc := GetDescPrd(cProduto, @cRevAtu)
		oMdlCab:LoadValue("CDESCPAI", cDesc)
		If Empty(cRevAtu)
			oMdlCab:LoadValue("CREVISAO", "")
			P120VldRev()
		EndIf
	EndIf

Return cRevAtu

/*/{Protheus.doc} P120VldRev
Função de validação do campo Revisão (carrega a Grid dos componentes)
@author Marcelo Neumann
@since 27/03/2019
@version P12
@return .T.
/*/
Function P120VldRev()

	Local oView    := FwViewActive()
	Local oModel   := FwModelActive()
	Local oMdlDet  := oModel:GetModel("GRID_COMPONENTES")
	Local cProduto := oModel:GetModel("FLD_PRODUTO"):GetValue("G1_COD")

	//Só carrega a Grid se o produto estiver preenchido
	If !Empty(cProduto)
		TravaAlter(oModel, .F.)

		oMdlDet:ClearData(.F.,.F.)
		oMdlDet:DeActivate()
		oMdlDet:Activate()
		LoadComps(oModel)

		TravaAlter(oModel, .T.)
	EndIf

	oView:Refresh("V_GRID_COMPONENTES")

Return .T.

/*/{Protheus.doc} LoadComps
Busca a estrutura e carrega a Grid com os componentes encontrados
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 oModel, object, modelo da tela de importação
@return Nil
/*/
Static Function LoadComps(oModel)

	Local oMdlDet    := oModel:GetModel("GRID_COMPONENTES")
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Local cProduto   := oModel:GetModel("FLD_PRODUTO"):GetValue("G1_COD")
	Local cRevisao   := oModel:GetModel("FLD_PRODUTO"):GetValue("CREVISAO")
	Local cDesc      := ""
	Local cField     := ""
	Local aFields    := oModel:GetModel("GRID_COMPONENTES"):oFormModelStruct:aFields
	Local nIndFields := 0

	cQuery := "SELECT *"
	cQuery +=  " FROM " + RetSqlName("SG1") + " SG1"
	cQuery += " WHERE SG1.G1_FILIAL   = '" + xFilial("SG1") + "'"
	cQuery +=   " AND SG1.G1_COD      = '" + cProduto + "'"
	cQuery +=   " AND SG1.D_E_L_E_T_  = ' '"
	cQuery +=   " AND SG1.G1_REVINI  <= '" + cRevisao + "'"
	cQuery +=   " AND (SG1.G1_REVFIM >= '" + cRevisao + "' OR SG1.G1_REVFIM = ' ')"
	cQuery += " ORDER BY " + SqlOrder(SG1->(IndexKey(1)))

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)

	If (cAliasQry)->(!Eof())
		TravaAlter(oModel, .F.)

		oMdlDet:ClearData(.F.,.T.)
		While (cAliasQry)->(!Eof())
			oMdlDet:AddLine()

			//Percorre todas as colunas da Grid carregando conforme a pesquisa
			For nIndFields := 1 to Len(aFields)
				cField := AllTrim(aFields[nIndFields][3])

				//Se for o campo Componete, busca a descrição do mesmo
				If cField == "G1_COMP"
					oMdlDet:LoadValue(cField, (cAliasQry)->(&(aFields[nIndFields][3])))
					cDesc := GetDescPrd((cAliasQry)->(&(aFields[nIndFields][3])))

				ElseIf cField == "G1_DESC"
					oMdlDet:LoadValue("G1_DESC", cDesc)

				//Verifica se é campo virtual
				ElseIf aFields[nIndFields][14] == .F.
					//Trata os campos de tipo Data
					If ValType(oMdlDet:GetValue(cField)) == "D"
						oMdlDet:LoadValue(cField, SToD( (cAliasQry)->(&(aFields[nIndFields][3])) ))
					Else
						oMdlDet:LoadValue(cField, (cAliasQry)->(&(aFields[nIndFields][3])))
					EndIf
				EndIf
			Next nIndFields

			(cAliasQry)->(dbSkip())
		EndDo

		oMdlDet:GoLine(1)
		TravaAlter(oModel, .T.)
	EndIf

	(cAliasQry)->(dbCloseArea())

Return

/*/{Protheus.doc} GetDescPrd
Busca a descrição do produto
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 cProduto, characters, código do produto
@param 02 cRevAtu , characters, revisão do produto a ser carregada com a Atual (passagem por referência)
@return cDesc, characters, descrição do produto
/*/
Static Function GetDescPrd(cProduto, cRevAtu)

	Local aAreaSB1 := SB1->(GetArea())
	Local cDesc    := CriaVar("B1_DESC")

	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1") + cProduto))
		cDesc   := SB1->B1_DESC
		cRevAtu := SB1->B1_REVATU
	Else
		cRevAtu := CriaVar("B1_REVATU")
	EndIf

	SB1->(RestArea(aAreaSB1))

Return cDesc

/*/{Protheus.doc} BotaoOk
Ação a ser executada ao clicar no botão de Confirmar ("Importar")
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 oModelImp, object, modelo da tela de importação
@param 02 oModelPai, object, modelo da tela principal
@return lOk, logical, indica se a tela pode ser confirmada
/*/
Static Function BotaoOk(oModelImp, oModelPai)

	Local oModImpSG1 := oModelImp:GetModel("GRID_COMPONENTES")
	Local oModPaiSVG := oModelPai:GetModel("SVGDETAIL")
	Local oModelAux
	Local oModAuxSVG
	Local cLoadXML   := ""
	Local cCompErro  := ""
	Local cTitleTrt  := AllTrim(RetTitle("G1_TRT"))
	Local nLinErro   := 0
	Local nIndComp   := 0
	Local nQtdComps  := 0
	Local nLenLisAnt := 0
	Local aError     := {}
	Local lOk        := .T.

	If Empty(oModelImp:GetModel("FLD_PRODUTO"):GetValue("G1_COD"))
		Help( ,  , "Help", ,  STR0051, ; //"Produto não informado."
		     1, 0, , , , , , {STR0046})  //"Informe um produto que possua estrutura para importar."
		Return .F.
	EndIf

	If Empty(oModImpSG1:GetValue("G1_COMP"))
		Help( ,  , "Help", ,  STR0045, ; //"Não existe estrutura para o produto e revisão informados."
		     1, 0, , , , , , {STR0046})  //"Informe um produto que possua estrutura para importar."
		Return .F.
	EndIf

	//Carrega um novo modelo para fazer as validações
	oModelAux  := FWLoadModel("PCPA120")
	oModAuxSVG := oModelAux:GetModel("SVGDETAIL")

	//Copia para o modelo auxiliar os dados do modelo atual
	cLoadXML := oModelPai:GetXMLData( .T. /*lDetail*/, ;
	                                  oModelPai:GetOperation() /*nOperation*/, ;
	                                  /*lXSL*/           , ;
	                                  /*lVirtual*/       , ;
	                                  /*lDeleted*/       , ;
	                                  .F. /*lEmpty*/     , ;
	                                  .F. /*lDefinition*/, ;
	                                  /*cXMLFile*/ )
	If !oModelAux:LoadXMLData( cLoadXML, .T. )
		lOk := .F.
    	Help( , , "Help", , STR0052, 1, 0) //"Ocorreu um erro ao realizar o backup dos dados."
	Else
 		//Percorre os componentes da estrutura buscando por um componente já esteja informado na grid principal
		nQtdComps := oModImpSG1:Length(.F.)
		For nIndComp := 1 To nQtdComps
		  	If oModPaiSVG:SeekLine({ {"VG_COMP", oModImpSG1:GetValue("G1_COMP", nIndComp)},;
			                         {"VG_TRT" , oModImpSG1:GetValue("G1_TRT",  nIndComp)} }, .F., .F. )
		  		If !Empty(oModImpSG1:GetValue("G1_COMP"))
		  			If !Empty(cCompErro)
		  				cCompErro += CHR(10) + CHR(13)
		  			EndIf
		  			cCompErro += AllTrim(oModImpSG1:GetValue("G1_COMP", nIndComp)) + " (" + cTitleTrt + ' "' + AllTrim(oModImpSG1:GetValue("G1_TRT", nIndComp)) + '")'
		  			lOk := .F.
		  		EndIf
		 	EndIf
		Next nIndComp

		If lOk
			FwModelActive(oModAuxSVG)

			nLenLisAnt := oModAuxSVG:Length(.F.)

			//Percorre todos os componentes da estrutura inserindo no modelo auxiliar
			For nIndComp := 1 To nQtdComps
				If oModAuxSVG:IsEmpty()
					nLenLisAnt := 0
				Else
					oModAuxSVG:AddLine()
				EndIf

				//Valida a atribuição dos valores dos campos principais
				If !oModAuxSVG:SetValue("VG_COMP" , oModImpSG1:GetValue("G1_COMP" , nIndComp))
				    nLinErro := nIndComp
					Exit
				EndIf
				If !oModAuxSVG:SetValue("VG_TRT"  , oModImpSG1:GetValue("G1_TRT"  , nIndComp))
				    nLinErro := nIndComp
					Exit
				EndIf
				If !oModAuxSVG:SetValue("VG_QUANT", oModImpSG1:GetValue("G1_QUANT", nIndComp))
				    nLinErro := nIndComp
					Exit
				EndIf
				oModAuxSVG:SetValue("VG_INI"    , oModImpSG1:GetValue("G1_INI"    , nIndComp))
				oModAuxSVG:SetValue("VG_FIM"    , oModImpSG1:GetValue("G1_FIM"    , nIndComp))
				oModAuxSVG:SetValue("VG_FIXVAR" , oModImpSG1:GetValue("G1_FIXVAR" , nIndComp))
				oModAuxSVG:SetValue("VG_GROPC"  , oModImpSG1:GetValue("G1_GROPC"  , nIndComp))
				oModAuxSVG:SetValue("VG_OPC"    , oModImpSG1:GetValue("G1_OPC"    , nIndComp))
				oModAuxSVG:SetValue("VG_POTENCI", oModImpSG1:GetValue("G1_POTENCI", nIndComp))
				oModAuxSVG:SetValue("VG_TIPVEC" , oModImpSG1:GetValue("G1_TIPVEC" , nIndComp))
				oModAuxSVG:SetValue("VG_VECTOR" , oModImpSG1:GetValue("G1_VECTOR" , nIndComp))
				oModAuxSVG:SetValue("VG_LOCCONS", oModImpSG1:GetValue("G1_LOCCONS", nIndComp))

				If !oModAuxSVG:VldLineData(.F.)
				    nLinErro := nIndComp
					Exit
				EndIf
			Next nIndComp
			FwModelActive(oModelPai)

			//Se a estrutura está correta, carrega os dados do modelo Auxiliar no modelo Atual
			If nLinErro = 0
				For nIndComp := nLenLisAnt + 1 To oModAuxSVG:Length(.F.)
					If !oModPaiSVG:IsEmpty()
						oModPaiSVG:AddLine()
					EndIf

					oModPaiSVG:SetValue("VG_COMP"   , oModAuxSVG:GetValue("VG_COMP"   , nIndComp))
					oModPaiSVG:SetValue("VG_TRT"    , oModAuxSVG:GetValue("VG_TRT"    , nIndComp))
					oModPaiSVG:SetValue("VG_INI"    , oModAuxSVG:GetValue("VG_INI"    , nIndComp))
					oModPaiSVG:SetValue("VG_FIM"    , oModAuxSVG:GetValue("VG_FIM"    , nIndComp))
					oModPaiSVG:SetValue("VG_FIXVAR" , oModAuxSVG:GetValue("VG_FIXVAR" , nIndComp))
					oModPaiSVG:SetValue("VG_GROPC"  , oModAuxSVG:GetValue("VG_GROPC"  , nIndComp))
					oModPaiSVG:SetValue("VG_OPC"    , oModAuxSVG:GetValue("VG_OPC"    , nIndComp))
					oModPaiSVG:SetValue("VG_POTENCI", oModAuxSVG:GetValue("VG_POTENCI", nIndComp))
					oModPaiSVG:SetValue("VG_TIPVEC" , oModAuxSVG:GetValue("VG_TIPVEC" , nIndComp))
					oModPaiSVG:SetValue("VG_VECTOR" , oModAuxSVG:GetValue("VG_VECTOR" , nIndComp))
					oModPaiSVG:SetValue("VG_LOCCONS", oModAuxSVG:GetValue("VG_LOCCONS", nIndComp))
					oModPaiSVG:SetValue("VG_QUANT"  , oModAuxSVG:GetValue("VG_QUANT"  , nIndComp))
				Next nIndComp
			Else
				lOk       := .F.
				aError    := oModelAux:GetErrorMessage()
				cCompErro := oModImpSG1:GetValue("G1_COMP", nLinErro)

				If Empty(aError[MODEL_MSGERR_SOLUCTION])
				   aError[MODEL_MSGERR_SOLUCTION] := STR0048 //"Verifique a estrutura informada."
				EndIf

				Help( , , aError[MODEL_MSGERR_ID] + " (" + aError[MODEL_MSGERR_IDFORMERR] + ")", , ;
				     FormatErro(cCompErro, aError), 1, 0, , , , , , { aError[MODEL_MSGERR_SOLUCTION] })
			EndIf
		Else
			Help( , , "Help", , STR0050 + CHR(10) + CHR(13) + AllTrim(cCompErro), 1, 0) //"Componente já cadastrado na lista:"
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} FormatErro
Formata a mensagem de erro
@author Marcelo Neumann
@since 27/03/2019
@version 1.0
@param 01 cCompon, characters, componente com o erro
@param 01 aError , array     , array com a mensagem GetErrorMessage()
@return cMsg, characters, mensagem de erro formatada
/*/
Static Function FormatErro(cCompon, aError)

	Local cMsg := ""

	cMsg := STR0049 + CHR(13) + CHR(10) + ; //"Existem erros que impedem a importação da lista: "
	        AllTrim(RetTitle("G1_COMP")) + " " + AllTrim(cCompon)

	If !Empty( AllTrim(aError[MODEL_MSGERR_IDFIELDERR])) .And. ;
	    Upper( AllTrim(RetTitle(aError[MODEL_MSGERR_IDFIELDERR])) ) <> Upper( AllTrim(RetTitle("G1_COMP")) )

		cMsg += " (" + AllTrim(RetTitle(aError[MODEL_MSGERR_IDFIELDERR])) + ")"
	EndIf

	cMsg += ": " + AllTrim(aError[MODEL_MSGERR_MESSAGE])

Return cMsg

/*/{Protheus.doc} LoadProdut
Função de Load do modelo FLD_PRODUTO para carregá-lo em branco
@author Marcelo Neumann
@since 27/03/2019
@version 1.0
@return aLoad, array, array com os campos em branco
/*/
Static Function LoadProdut()

	Local aLoad := { CriaVar("G1_COD",.F.), CriaVar("B1_DESC",.F.), CriaVar("B1_REVATU",.F.) }

Return aLoad

/*/{Protheus.doc} SetModify
Seta o indicador de modificação do modelo
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 oModel, object, modelo a ter o indicador alterado
@param 02 lMod  , logic , indica se o modelo será setado para modificado ou não
@return .T.
/*/
Static Function SetModify(oModel, lMod)

	oModel:lModify := lMod

Return .T.

/*/{Protheus.doc} TravaAlter
Trava/Destrava as linhas da Grid
@author Marcelo Neumann
@since 27/03/2019
@version P12
@param 01 oModel , object, modelo da tela de importação de estrura
@param 02 lTravar, logic , indica se deve travar (.T.) ou destravar (.F.) a edição do modelo
@return Nil
/*/
Static Function TravaAlter(oModel, lTravar)

	oModel:GetModel("GRID_COMPONENTES"):SetNoUpdateLine(lTravar)
	oModel:GetModel("GRID_COMPONENTES"):SetNoDeleteLine(lTravar)
	oModel:GetModel("GRID_COMPONENTES"):SetNoInsertLine(lTravar)

Return