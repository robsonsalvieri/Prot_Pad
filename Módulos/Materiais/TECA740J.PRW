#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA740J.CH"

#DEFINE DEF_TITULO_DO_CAMPO		01	//Titulo do campo
#DEFINE DEF_TOOLTIP_DO_CAMPO	02	//ToolTip do campo
#DEFINE DEF_IDENTIFICADOR		03	//identificador (ID) do Field
#DEFINE DEF_TIPO_DO_CAMPO		04	//Tipo do campo
#DEFINE DEF_TAMANHO_DO_CAMPO	05	//Tamanho do campo
#DEFINE DEF_DECIMAL_DO_CAMPO	06	//Decimal do campo
#DEFINE DEF_CODEBLOCK_VALID		07	//Code-block de validação do campo
#DEFINE DEF_CODEBLOCK_WHEN		08	//Code-block de validação When do campo
#DEFINE DEF_LISTA_VAL			09	//Lista de valores permitido do campo
#DEFINE DEF_OBRIGAT				10	//Indica se o campo tem preenchimento obrigatório
#DEFINE DEF_CODEBLOCK_INIT		11	//Code-block de inicializacao do campo
#DEFINE DEF_CAMPO_CHAVE			12	//Indica se trata de um campo chave
#DEFINE DEF_RECEBE_VAL			13	//Indica se o campo pode receber valor em uma operação de update.
#DEFINE DEF_VIRTUAL				14	//Indica se o campo é virtual
#DEFINE DEF_VALID_USER			15	//Valid do usuario

#DEFINE DEF_ORDEM				16	//Ordem do campo
#DEFINE DEF_HELP				17	//Array com o Help dos campos
#DEFINE DEF_PICTURE				18	//Picture do campo
#DEFINE DEF_PICT_VAR			19	//Bloco de picture Var
#DEFINE DEF_LOOKUP				20	//Chave para ser usado no LooKUp
#DEFINE DEF_CAN_CHANGE			21	//Logico dizendo se o campo pode ser alterado
#DEFINE DEF_ID_FOLDER			22	//Id da Folder onde o field esta
#DEFINE DEF_ID_GROUP			23	//Id do Group onde o field esta
#DEFINE DEF_COMBO_VAL			24	//Array com os Valores do combo
#DEFINE DEF_TAM_MAX_COMBO		25	//Tamanho maximo da maior opção do combo
#DEFINE DEF_INIC_BROWSE			26	//Inicializador do Browse
#DEFINE DEF_PICTURE_VARIAVEL	27	//Picture variavel
#DEFINE DEF_INSERT_LINE			28	//Se verdadeiro, indica pulo de linha após o campo
#DEFINE DEF_WIDTH				29	//Largura fixa da apresentação do campo
#DEFINE DEF_TIPO_CAMPO_VIEW		30	//Tipo do campo

#DEFINE QUANTIDADE_DEFS			30	//Quantidade de DEFs

Static aTCXCarga:= {} //Array de carga de dados no grid (INITDADOS)
Static cCodTFF	:= "" //Código do Posto (TFF)
Static cConfCal := "" //Código da Configuração de cálculo
Static cXMLPla  := "" //Código da Planilha do Posto ou da configuração de cálculo
Static oPlanXml := Nil//Objeto da Planilha XML
Static oMdl740  := Nil//Modelo orçamento
Static lAparece	:= .T.//Define se aparece o botão de "Confirmar" na tela

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740J

@description  Configuração de Verbas Adicionais - FOLHA da Planilha do Posto (TFF)
@where	Outras ações do orçamento
@Param  oModel - Modelo RH (TFF)

@author	jack.junior
@since	17/05/2023
/*/
//------------------------------------------------------------------------------
Function TECA740J(oModel)
Local oView 	:= FwViewActive()
Local aFldPai	:= oView:GetFolderActive("ABAS", 2) //1-Local de Atendimento, 2-RH, 4-Totais
Local aSaveLines:= FWSaveRows()
Local aButtons  := {}
Local cCodPla	:= ""
Local cCodRev	:= ""
Local nOk		:= 2 //0-Confirmar, 1-Cancelar
Local lRet		:= .T.
Local lGsVerb	:= TableInDic("ABZ") //Verbas de Folha
Local nOpc 		:= 0
Local cTitle	:= STR0001

If aFldPai[1] == 2 //Verifica se está na Aba de RH - Postos

	cCodPla := oModel:GetValue("TFF_RH","TFF_PLACOD")
	cCodRev := oModel:GetValue("TFF_RH","TFF_PLAREV")
	cXMLPla := oModel:GetValue("TFF_RH","TFF_CALCMD")
	cCodTFF := oModel:GetValue("TFF_RH","TFF_COD")

	oMdl740 := oModel

	If !Empty(cCodPla) .And. !Empty(cXMLPla) //Verifica se há planilha no Posto

		nOpc := oMdl740:GetOperation()

		//Se for visualização retira o botão de "Confirmar"
		If nOpc == 1
			lAparece := .F.
			cTitle += " - "+STR0017 //"Visualizar"
		EndIf

		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{lAparece,Nil}/*Confirmar*/,{.T.,Nil}/*Cancelar*/,{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

		cConfCal:= Posicione("ABW",1,xFilial("ABW")+cCodPla+cCodRev,"ABW_CODTCW") //Cód. Configuração de cálculo

		FwMsgRun(Nil,{||nOk := FwExecView(cTitle,; //cTitulo - "Ajuste de Mão de Obra"
										 "VIEWDEF.TECA740J",; //cPrograma
										MODEL_OPERATION_INSERT,; //nOperation
										/*oOwner*/,; //oDlg
										{|| TecModFalse(!lAparece)},; //bCloseOnOK
										/*bOk*/,; //bOk
										55,; //nPercReducao
										aButtons,; //aEnableButtons
										{|| TecModFalse(.T.)},)}; //bCancel
				,Nil, STR0002)//"Carregando dados..."
	Else
		lRet := .F.
   		MsgAlert(STR0003)//"Carregue a planilha de preço para o posto selecionado."
	EndIf
Else
	lRet := .F.
    MsgAlert(STR0004)//"É necessário selecionar um posto para utilização dessa função."
EndIf

If nOk == 1 .Or. !lAparece
	lRet := .F.
EndIf

If nOk == 0 .And. lRet
	//Update da TFF (Recursos Humanos)
	FwMsgRun(Nil,{||at740JUpdt(oModel)},Nil, STR0016)//"Salvando dados..."
	oView:Refresh('VIEW_RH') //Refresh da view necessário caso tenha usado atalho F8
	If lGsVerb
		oView:Refresh('ABZDETAIL') //Refresh da view - Verbas de Folha
	EndIf
EndIf

at740JLimp() //Limpa variáveis estáticas

FWRestRows(aSaveLines,oModel)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc}

@description  ModelDef

@author	jack.junior
@since	17/05/2023
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruTCW	:= FWFormModelStruct():New()
Local oStruTCX	:= FWFormModelStruct():New()
Local aFields	:= {}
Local aTables 	:= {}
Local bCmtModel := {|oModel| at740JCmmt( oModel )}
Local bPreLinTCX:= {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue|preLinTCX(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
Local nX		:= 0
Local nY		:= 0

oStruTCW:AddTable("   ",{}, STR0001) //"Ajuste de Mão de Obra"
oStruTCX:AddTable("   ",{}, "   ")

AADD(aTables, {oStruTCW, "TCW"})
AADD(aTables, {oStruTCX, "TCX"})

For nY := 1 To LEN(aTables)

	aFields := at740JDef(aTables[nY][2]) //Definições de campos

	For nX := 1 TO LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO ],;
								aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
								aFields[nX][DEF_IDENTIFICADOR	],;
								aFields[nX][DEF_TIPO_DO_CAMPO	],;
								aFields[nX][DEF_TAMANHO_DO_CAMPO],;
								aFields[nX][DEF_DECIMAL_DO_CAMPO],;
								aFields[nX][DEF_CODEBLOCK_VALID	],;
								aFields[nX][DEF_CODEBLOCK_WHEN	],;
								aFields[nX][DEF_LISTA_VAL		],;
								aFields[nX][DEF_OBRIGAT			],;
								aFields[nX][DEF_CODEBLOCK_INIT	],;
								aFields[nX][DEF_CAMPO_CHAVE		],;
								aFields[nX][DEF_RECEBE_VAL		],;
								aFields[nX][DEF_VIRTUAL			],;
								aFields[nX][DEF_VALID_USER		])
	Next nX
Next nY

oModel := MPFormModel():New("TECA740J", /*<bPre>*/, /*bPosModel*/, bCmtModel, /*<bCancel>*/)
oModel:SetDescription(STR0001) //"Ajuste de Mão de Obra"

oModel:AddFields("TCWMASTER",/*cOwner*/,oStruTCW, /*<bPre>*/, /*<bPost>*/, /*bLoadField*/)
oModel:GetModel("TCWMASTER"):SetDescription(STR0001) //"Ajuste de Mão de Obra"
oModel:SetPrimaryKey({"TCW_FILIAL","TCW_CODIGO"})

oModel:AddGrid("TCXDETAIL", "TCWMASTER", oStruTCX, bPreLinTCX, /*<bLinePost>*/, /*<bPre>*/, /*<bLinePost>*/, /*bLoadGrid*/)
oModel:GetModel("TCXDETAIL"):SetDescription(STR0005) //"Verbas"

If (TCW->(ColumnPos('TCW_REVISA')) > 0)
    oModel:SetRelation("TCXDETAIL", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}, {"TCX_REVISA","TCW_REVISA"}}, TCX->(IndexKey(1)))
Else
    oModel:SetRelation("TCXDETAIL", {{"TCX_FILIAL","xFilial('TCX')"}, {"TCX_CODTCW","TCW_CODIGO"}}, TCX->(IndexKey(1)))
EndIf

oModel:GetModel('TCXDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('TCXDETAIL'):SetOptional(.T.)

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc}

@description  ViewDef

@author	jack.junior
@since	17/05/2023
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= ModelDef()
Local oStruTCW	:= FWFormViewStruct():New()
Local oStruTCX	:= FWFormViewStruct():New()
Local oView     := Nil
Local aTables 	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStruTCW, "TCW"})
AADD(aTables, {oStruTCX, "TCX"})

For nY := 1 to LEN(aTables)

	aFields := at740JDef(aTables[nY][2]) //Definições de campos

	For nX := 1 to LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR	],;
								aFields[nX][DEF_ORDEM			],;
								aFields[nX][DEF_TITULO_DO_CAMPO	],;
								aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
								aFields[nX][DEF_HELP			],;
								aFields[nX][DEF_TIPO_CAMPO_VIEW	],;
								aFields[nX][DEF_PICTURE			],;
								aFields[nX][DEF_PICT_VAR		],;
								aFields[nX][DEF_LOOKUP			],;
								aFields[nX][DEF_CAN_CHANGE		],;
								aFields[nX][DEF_ID_FOLDER		],;
								aFields[nX][DEF_ID_GROUP		],;
								aFields[nX][DEF_COMBO_VAL		],;
								aFields[nX][DEF_TAM_MAX_COMBO	],;
								aFields[nX][DEF_INIC_BROWSE		],;
								aFields[nX][DEF_VIRTUAL			],;
								aFields[nX][DEF_PICTURE_VARIAVEL],;
								aFields[nX][DEF_INSERT_LINE		],;
								aFields[nX][DEF_WIDTH			])
	Next nX
Next nY

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_CAB", oStruTCW, "TCWMASTER")
oView:AddGrid("VIEW_GRID", oStruTCX, "TCXDETAIL")

oView:CreateHorizontalBox("CONFIG_TCW", 15 )
oView:CreateHorizontalBox("CONFIG_TCX", 85 )

oView:SetOwnerView("VIEW_CAB" ,"CONFIG_TCW")
oView:SetOwnerView("VIEW_GRID","CONFIG_TCX")

oView:SetDescription(STR0005) //"Verbas"

oStruTCX:RemoveField("TCX_NICK"  )
oStruTCX:RemoveField("TCX_NICKPO")
oStruTCX:RemoveField("TCX_FORMUL")
oStruTCX:RemoveField("TCX_TIPTBL")
oStruTCX:RemoveField("TCX_CODTBL")
oStruTCX:RemoveField("TCX_CODTCW")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} at740JDef
	Define os campos da tela

@author 	jack.junior
@since	    19/05/2023
/*/
//-------------------------------------------------------------------
Static Function at740JDef(cTable)
Local aRet	:= {}
Local nAux	:= 0

If cTable == "TCW"
    //--TCW_CODIGO
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCW_CODIGO", .T. ) //"Código"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCW_CODIGO", .T. ) //"Código"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCW_CODIGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCW_CODIGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    //--TCW_DESCRI
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCW_DESCRI", .T. ) //"Descrição"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCW_DESCRI", .T. ) //"Descrição"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCW_DESCRI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCW_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    //--TCW_CODCCT
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCW_CODCCT", .T. )//"Codigo CCT"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCW_CODCCT", .T. )//"Codigo CCT"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCW_CODCCT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCW_CODCCT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

ElseIf cTable == "TCX"
    //--TCX_DESCRI
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0005 //"Verbas"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0005 //"Verbas"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_DESCRI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	//--TCX_OBRGT  - Obrigatório na planilha ?
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015 //"Obrigatório?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015 //"Obrigatório?"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_OBRGT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "9"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0013, "2="+STR0014} //"Sim"#"Não"
    aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0013, "2="+STR0014} //"Sim"#"Não"
    //--TCX_TIPTBL
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
    aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0006 //"Tipo de taxa"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0006 //"Tipo de taxa"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_TIPTBL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_TIPTBL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TCX_PORCEN
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 //"Valor CCT"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007 //"Valor CCT"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_PORCEN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_PORCEN")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@E 99,999,999,999.99"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TCX_PORALT
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008 //"Vl. Alterável"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008 //"Vl. Alterável"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_PORALT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_PORALT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@E 99,999,999,999.99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    //--TCX_NICKPO - oculto da view
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCX_NICKPO", .T. ) //"Nome Porcent"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCX_NICKPO", .T. ) //"Nome Porcent"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_NICKPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_NICKPO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TCX_NICK - oculto da view
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCX_NICK", .T. ) //"Nome Celula "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCX_NICK", .F. ) //"Nome Celula "
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_NICK"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_NICK")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	//--TCX_FORMUL - Fórmula oculto da view
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCX_FORMUL", .T. ) //"Formula Vlr."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCX_FORMUL", .F. ) //"Formula Vlr."
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_FORMUL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_FORMUL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	//--TCX_CODTBL - Cod. Tabela - VERBA SRV
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCX_CODTBL", .T. ) //"Cod. Tabela"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCX_CODTBL", .F. ) //"Cod. Tabela"
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_CODTBL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_CODTBL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	//--TCX_CODTCW - Cód Configuração de Cálculo
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TCX_CODTCW", .T. ) //"Cod. Config "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TCX_CODTCW", .F. ) //"Cod. Config "
	aRet[nAux][DEF_IDENTIFICADOR] := "TCX_CODTCW"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCX_CODTCW")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação

@author	jack.junior
@since	23/05/2023
/*/
//-------------------------------------------------------------------
Static Function InitDados(oModel)
Local aDados 	:= {}
Local cFilTCW	:= xFilial('TCW')
Local nLinha	:= 1
Local nX		:= 0
Local oMdlTCW 	:= oModel:GetModel('TCWMASTER')
Local oMdlTCX 	:= oModel:GetModel('TCXDETAIL')

//Preenchimento Field (Cabeçalho)
oMdlTCW:LoadValue("TCW_CODIGO", AllTrim(Posicione('TCW',1,cFilTCW+cConfCal,'TCW_CODIGO')))
oMdlTCW:LoadValue("TCW_DESCRI", AllTrim(Posicione('TCW',1,cFilTCW+cConfCal,'TCW_DESCRI')))
oMdlTCW:LoadValue("TCW_CODCCT", AllTrim(Posicione('TCW',1,cFilTCW+cConfCal,'TCW_CODCCT')))

//Preenchimento Grid
aDados := GetDataTCX()

oMdlTCX:SetNoInsertLine(.F.)
oMdlTCX:SetNoDeleteLine(.F.)

If !Empty(aDados)
	If Len(aDados) > 0
		For nX := 1 To Len(aDados)
			If nX > 1
				nLinha := oMdlTCX:AddLine()
			EndIf
			oMdlTCX:GoLine(nLinha)
			oMdlTCX:LoadValue("TCX_DESCRI", aDados[nX][1][1])
			oMdlTCX:LoadValue("TCX_OBRGT" , aDados[nX][1][2])
			oMdlTCX:LoadValue("TCX_TIPTBL", aDados[nX][1][3])
			oMdlTCX:LoadValue("TCX_PORCEN", aDados[nX][1][4])
			oMdlTCX:LoadValue("TCX_PORALT", aDados[nX][1][5])
			oMdlTCX:LoadValue("TCX_NICKPO", aDados[nX][1][6])
			oMdlTCX:LoadValue("TCX_NICK"  , aDados[nX][1][7])
			oMdlTCX:LoadValue("TCX_FORMUL", aDados[nX][1][8])
			oMdlTCX:LoadValue("TCX_CODTBL", aDados[nX][1][9])
			oMdlTCX:LoadValue("TCX_CODTCW", aDados[nX][1][10])
		Next nX
	EndIf
EndIf

oMdlTCX:SetNoInsertLine(.T.)
oMdlTCX:SetNoDeleteLine(.T.)
oMdlTCX:SetNoUpdateLine(.F.)

If !lAparece
	oMdlTCX:SetNoUpdateLine(.T.)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataTCX
@description Bloco de código load do GRID executado no activate
@param oModel, obj, modelo em ativação

TABELA TCX - GRID DA CONFIGURAÇÃO DE CÁLCULO

@author	jack.junior
@since	22/05/2023
/*/
//-------------------------------------------------------------------
Static Function GetDataTCX()
Local cAbaTCX 	:= '1' //Aba de mão de obra - Configuração de cálculo
Local cAliasTCX := GetNextAlias()
Local aLoadTCX 	:= {}

BeginSql Alias cAliasTCX
	SELECT TCX.TCX_DESCRI,;
           TCX.TCX_TIPTBL,;
           TCX.TCX_PORCEN,;
           TCX.TCX_PORALT,;
           TCX.TCX_NICKPO,;
           TCX.TCX_NICK,;
		   TCX.TCX_FORMUL,;
		   TCX.TCX_OBRGT,;
		   TCX.TCX_CODTBL,;
		   TCX.TCX_CODTCW
    		FROM  %table:TCX% TCX
            WHERE TCX.TCX_FILIAL = %xFilial:TCX%
                AND TCX.TCX_CODTCW = %Exp:cConfCal%
                AND TCX.TCX_TIPOPE = %Exp:cAbaTCX%
                AND TCX.%notDel%
EndSql

If (cAliasTCX)->(!Eof())
    While (cAliasTCX)->(!Eof())
		If AllTrim((cAliasTCX)->TCX_NICK) <> 'TOTAL_MAO_DE_OBRA' .And.;
			AllTrim((cAliasTCX)->TCX_NICK) <> 'SLBS'

			aAdd(aLoadTCX,{{(cAliasTCX)->TCX_DESCRI,; //aTCXCarga[nX][1][1]
							(cAliasTCX)->TCX_OBRGT ,; //aTCXCarga[nX][1][2]
							(cAliasTCX)->TCX_TIPTBL,; //aTCXCarga[nX][1][3]
							(cAliasTCX)->TCX_PORCEN,; //aTCXCarga[nX][1][4]
							(cAliasTCX)->TCX_PORALT,; //aTCXCarga[nX][1][5]
							(cAliasTCX)->TCX_NICKPO,; //aTCXCarga[nX][1][6]
							(cAliasTCX)->TCX_NICK  ,; //aTCXCarga[nX][1][7]
							(cAliasTCX)->TCX_FORMUL,; //aTCXCarga[nX][1][8]
							(cAliasTCX)->TCX_CODTBL,; //aTCXCarga[nX][1][9]
							(cAliasTCX)->TCX_CODTCW}})//aTCXCarga[nX][1][10]

		EndIf
        (cAliasTCX)->(DbSkip())
    EndDo
EndIf

(cAliasTCX)->(DbCloseArea())

If Len(aLoadTCX) > 0
	aTCXCarga := UpdateLoad(aLoadTCX) //Atualiza com os dados da planilha do posto.
EndIf

Return aTCXCarga

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateLoad
@description Atualiza array de load com dados atualizados da planilha

@author	jack.junior
@since	22/05/2023
/*/
//-------------------------------------------------------------------
Static Function UpdateLoad(aLoadTCX)
Local nX		:= 0
Local nValPlan 	:= 0

	oPlanXml := FWUIWorkSheet():New(,.F.,,11,"PLAN_LOAD")
	oPlanXml:LoadXmlModel(cXMLPla)

	For nX := 1 To Len(aLoadTCX)
		If oPlanXml:CellExists(AllTrim(aLoadTCX[nX][1][6]))
			nValPlan := oPlanXml:GetCellValue(aLoadTCX[nX][1][6])
			If ValType(nValPlan) != "N" //Tratamento para typemismatch:
				nValPlan := Val(nValPlan)
			EndIf
			aLoadTCX[nX][1][5] := nValPlan
		Else
			//Obrigatório = Não -> Carrega o valor TCX_PORALT zerado
			If aLoadTCX[nX][1][2] != "1"
				aLoadTCX[nX][1][5] := 0
			EndIf
		EndIf
	Next nX

Return aLoadTCX

//-------------------------------------------------------------------
/*/{Protheus.doc} preLinTCX
@description Pré validação da linha Grid TCX

@Param: oGridModel - Modelo do GRID
		nLine - Número da linha atual
		cAction - Ação ("UNDELETE"/"DELETE"/"SETVALUE"/"CANSETVALUE")
		cIDField - ID do campo que está tentando ser atualizado
		xValue - Valor que está sendo atribuido
		xCurrentValue - Valor que está atualmente no campo

@author	jack.junior
@since	23/05/2023
/*/
//-------------------------------------------------------------------
Static Function preLinTCX(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lObrigat	:= .T.
Local lRet		:= .T.
Local nTaxaCCT	:= 0

If cAction == "SETVALUE"
	If cIDField == "TCX_PORALT"
		If aTCXCarga[nLine][1][2] != "1" //Obrigatório = Não e valor igual a 0 não valida nada.
			If xValue == 0
				lObrigat := .F.
			EndIf
		EndIf
		nTaxaCCT := oGridModel:GetValue("TCX_PORCEN")
		If nTaxaCCT != 0 .And. lObrigat
			If xValue < nTaxaCCT
				lRet := .F.
				Help(NIL, NIL, "preLinTCX", NIL, STR0009, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010+cValtoChar(nTaxaCCT)+"."})//"O Valor do campo não pode ser menor do que o estabelecido na CCT."#"O valor deve ser igual ou maior que X."
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740JCmmt
	Realizar a gravação dos dados na planilha - XML Planilha nova no posto (TFF)
@sample 	at740JCmmt()
@since		23/05/2023
@return 	oModel, Object, instância do modelo de dados MpFormModel
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740JCmmt(oModel)
Local cFormula	:= "=0"
Local lRet		:= .T.
Local lUpdate 	:= .F.
Local nLine 	:= 0
Local nX		:= 0
Local oMdlTCX 	:= oModel:GetModel('TCXDETAIL')
Local lGsVerb	:= TableInDic("ABZ") //Verbas de Folha

For nX := 1 To oMdlTCX:Length()
	oMdlTCX:GoLine(nX)
	If oMdlTCX:GetValue("TCX_PORALT") != aTCXCarga[nX][1][5]
		lUpdate := .T.
		//ALTERA REGISTROS EXISTENTES
		If oPlanXml:CellExists(oMdlTCX:GetValue("TCX_NICKPO"))
			oPlanXml:SetCellValue(oMdlTCX:GetValue("TCX_NICKPO"),oMdlTCX:GetValue("TCX_PORALT"))
		//CRIA REGISTROS QUE NÃO EXISTEM - COLUNAS I, J, K
		Else
			nLine := 3 //Registros à partir da terceira linha da planilha
			While ValType(oPlanXml:GetCell("I"+cValToChar(nLine))) == 'O' //Valida se existe registro na linha
				nLine ++
			EndDo

			If !Empty(oMdlTCX:GetValue("TCX_FORMUL"))
				cFormula := "="+Alltrim(oMdlTCX:GetValue("TCX_FORMUL"))
			EndIf

			//DESCRIÇÃO - COLUNA I
			oPlanXml:SetCellValue("I"+cValTochar(nLine), oMdlTCX:GetValue("TCX_DESCRI"), , .T.)
			//VALOR - COLUNA J
			oPlanXml:SetNickName("J"+cValTochar(nLine), oMdlTCX:GetValue("TCX_NICKPO"))
			oPlanXml:SetCellValue("J"+cValTochar(nLine), oMdlTCX:GetValue("TCX_PORALT"), , .T.)
			//FORMULA - COLUNA K
			oPlanXml:SetNickName("K"+cValTochar(nLine), oMdlTCX:GetValue("TCX_NICK"))
			oPlanXml:SetCellValue("K"+cValTochar(nLine), cFormula, , .T.)

		EndIf
		If lGsVerb .And. oPlanXml:GetCellValue(oMdlTCX:GetValue("TCX_NICK")) > 0
			at740JABZ(oMdlTCX)
		EndIf
	EndIf
Next nX

If lUpdate
	cXMLPla := oPlanXml:GetXmlModel(,,,,.F.,.T.,.F.)

	If ExistBlock("at740JXml")
		ExecBlock("at740JXml",.F.,.F.,{oMdlTCX,cXMLPla})
	EndIf
EndIf

oModel:DeActivate()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740JLimp
	Limpa variáveis estáticas
@sample 	at740JLimp()
@since		24/05/2023
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740JLimp()

aTCXCarga := {}
cXMLPla	  := ""
cConfCal  := ""
cCodTFF	  := ""
oPlanXml  := Nil
oMdl740	  := Nil
lAparece  := .T.

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} at740JUpdt
	Realiza a atualização dos totais e xml da planilha (POSTO TFF - RH)
@sample 	at740JUpdt()
@since		24/05/2023
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740JUpdt(oModel)
	Local nTotRh	:= 0
	Local nTotPlan	:= 0
	Local oMdlRh  	:= oModel:GetModel("TFF_RH")

	oPlanXml:LoadXMLModel(cXMLPla) //"Refresh" da planilha - atualiza totais

	If oPlanXml:CellExists("TOTAL_CUSTOS")
		nTotRh := oPlanXml:GetCellValue("TOTAL_CUSTOS")
	Elseif oPlanXml:CellExists("TOTAL_CUSTO")
		nTotRh := oPlanXml:GetCellValue("TOTAL_CUSTO")
	Endif
	If oPlanXml:CellExists("TOTAL_BRUTO")
		nTotPlan := oPlanXml:GetCellValue("TOTAL_BRUTO")
	Endif

	//Pega planilha atualizada
	oPlanXml:Refresh(.T.)
	cXMLPla := oPlanXml:GetXmlModel(,,,,.F.,.T.,.F.)

	oMdlRh:SetValue("TFF_CALCMD",cXMLPla)
	oMdlRh:SetValue("TFF_PRCVEN",Round(nTotRh, TamSX3("TFF_PRCVEN")[2]))
	oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))

	If ExistBlock("at740JUpd")
		ExecBlock("at740JUpd",.F.,.F.,{oMdlRh,oPlanXml})
	EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740JABZ
	Preenche o Grid ABZ do orçamento com a verba não obrigatória adicionada
@sample 	at740JABZ()
@since		24/05/2023
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740JABZ(oMdlTCX)
Local oMdlABZ := oMdl740:GetModel("ABZDETAIL")

If oMdlTCX:GetValue("TCX_OBRGT") == '2'
	If !Empty(oMdlTCX:GetValue("TCX_NICKPO"))
		at740ABZ(oMdlABZ,.F.) //Permissão alteração Grid ABZ - Verbas de Folha

		//Adiciona verba ou deleta caso zerar o valor:
		If oMdlTCX:GetValue("TCX_PORALT") == 0
			If oMdlABZ:SeekLine({{"ABZ_FILSRV",xFilial("SRV")},{"ABZ_CODSRV",AllTrim(oMdlTCX:GetValue("TCX_CODTBL"))}})
				oMdlABZ:DeleteLine()
			EndIf
		Else
			If oMdlABZ:SeekLine({{"ABZ_FILSRV",xFilial("SRV")},{"ABZ_CODSRV",AllTrim(oMdlTCX:GetValue("TCX_CODTBL"))}},.T.)
				If oMdlABZ:IsDeleted()
					oMdlABZ:UnDeleteLine()
				EndIf
			Else
				If !Empty(oMdlABZ:GetValue("ABZ_CODSRV"))
					oMdlABZ:AddLine()
				EndIf
				cCodCCT := Posicione("TCW", 1, xFilial("TCW")+oMdlTCX:GetValue("TCX_CODTCW"), "TCW_CODCCT")
				oMdlABZ:LoadValue("ABZ_FILSRV",xFilial("SRV")) 	 //FIL SRV
				oMdlABZ:LoadValue("ABZ_CODSRV",AllTrim(oMdlTCX:GetValue("TCX_CODTBL"))) //CODIGO SERVIÇO
				oMdlABZ:LoadValue("ABZ_DESCRI",AllTrim(oMdlTCX:GetValue("TCX_DESCRI"))) //DESCRICAO
				oMdlABZ:LoadValue("ABZ_FILCCT",xFilial("SWY")) 	 //FIL CCT
				oMdlABZ:LoadValue("ABZ_CCTCOD",cCodCCT) //COD CCT
				oMdlABZ:LoadValue("ABZ_PERC"  ,oMdlTCX:GetValue("TCX_PORCEN")) //PERCENTUAL
			EndIF
		EndIf
		oMdlABZ:GoLine(1)
		at740ABZ(oMdlABZ,.T.) //Retira Permissão de alteração Grid ABZ - Verbas de Folha
	EndIf
EndIf

Return
