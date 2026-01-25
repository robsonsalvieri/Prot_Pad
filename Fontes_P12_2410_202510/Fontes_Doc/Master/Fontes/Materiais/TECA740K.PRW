#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA740K.CH"

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

Static aTXOCarga:= {}  //Array de carga de dados no grid (INITDADOS)
Static cPosto	:= ""  //Código do Posto (TFF)
Static cConfigC := ""  //Código da Configuração de cálculo
Static cPlanXML := ""  //Código da Planilha do Posto ou da configuração de cálculo
Static oPlanTFF := Nil //Objeto da Planilha XML
Static oModelOrc:= Nil //Modelo orçamento
Static lAparece	:= .T. //Define se aparece o botão de "Confirmar" na tela
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA740K

@description  Configuração de Verbas Adicionais da Planilha do Posto (TFF)
@where	Outras ações do orçamento
@Param  oModel - Modelo RH (TFF)

@author	jack.junior
@since	02/06/2023
/*/
//------------------------------------------------------------------------------
Function TECA740K(oModel)
Local oView 	:= FwViewActive()
Local aFldPai	:= oView:GetFolderActive("ABAS", 2) //1-Local de Atendimento, 2-RH, 4-Totais
Local aSaveLines:= FWSaveRows()
Local aButtons  := {}
Local cCodPla	:= ""
Local cCodRev	:= ""
Local nOk		:= 2 //0-Confirmar, 1-Cancelar
Local lRet		:= .T.
Local nOpc 		:= 0
Local cTitle	:= STR0001

If aFldPai[1] == 2 //Verifica se está na Aba de RH - Postos

	oModelOrc := oModel
	oModelTFF := oModel:GetModel("TFF_RH")
	cCodPla   := oModelTFF:GetValue("TFF_PLACOD")
	cCodRev   := oModelTFF:GetValue("TFF_PLAREV")
	cPlanXML  := oModelTFF:GetValue("TFF_CALCMD")
	cPosto	  := oModelTFF:GetValue("TFF_COD") 

	If !Empty(cCodPla) .And. !Empty(cPlanXML) //Verifica se há planilha no Posto

		nOpc := oModelOrc:GetOperation()

		//Se for visualização retira o botão de "Confirmar"
		If nOpc == 1
			lAparece := .F.
			cTitle += " - "+STR0009 //"Visualizar"
		EndIf

		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{lAparece,Nil}/*Confirmar*/,{.T.,Nil}/*Cancelar*/,{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

		cConfigC:= Posicione("ABW",1,xFilial("ABW")+cCodPla+cCodRev,"ABW_CODTCW") //Cód. Configuração de cálculo

		FwMsgRun(Nil,{||nOk := FwExecView(cTitle,; //cTitulo - "Ajuste de Verbas Adicionais"
									"VIEWDEF.TECA740K",; //cPrograma
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
	FwMsgRun(Nil,{||at740KUpdt(oModel)},Nil, STR0005 )//"Salvando dados..." 
	oView:Refresh('VIEW_RH') //Refresh da view necessário caso tenha usado atalho F9
	oView:Refresh('ABP_BENEF') //Refresh da view
EndIf

at740KLimp() //Limpa variáveis estáticas

FWRestRows(aSaveLines,oModel)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc}

@description  ModelDef

@author	jack.junior
@since	02/06/2023
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStruTCW	:= FWFormModelStruct():New()
Local oStruTXO	:= FWFormModelStruct():New()
Local aFields	:= {}
Local aTables 	:= {}
Local bCmtModel := {|oModel| at740KCmmt( oModel )}
Local nX		:= 0
Local nY		:= 0

oStruTCW:AddTable("   ",{}, STR0001) //"Ajuste de Verbas Adicionais"
oStruTXO:AddTable("   ",{}, "   ")

AADD(aTables, {oStruTCW, "TCW"})
AADD(aTables, {oStruTXO, "TXO"})

For nY := 1 To LEN(aTables)

	aFields := at740KDef(aTables[nY][2]) //Definições de campos

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

oModel := MPFormModel():New("TECA740K", /*<bPre>*/, /*bPosModel*/, bCmtModel, /*<bCancel>*/)
oModel:SetDescription(STR0001) //"Ajuste de Verbas Adicionais"

oModel:AddFields("TCWMASTER",/*cOwner*/,oStruTCW, /*<bPre>*/, /*<bPost>*/, /*bLoadField*/)
oModel:GetModel("TCWMASTER"):SetDescription(STR0001) //"Ajuste de Verbas Adicionais"
oModel:SetPrimaryKey({"TCW_FILIAL","TCW_CODIGO"})

oModel:AddGrid("TXODETAIL", "TCWMASTER", oStruTXO, , /*<bLinePost>*/, /*<bPre>*/, /*<bLinePost>*/, /*bLoadGrid*/)
oModel:GetModel("TXODETAIL"):SetDescription(STR0006) //"Verbas Adicionais"

If (TXO->(ColumnPos('TXO_REVISA')) > 0)
	oModel:SetRelation("TXODETAIL", {{"TXO_FILIAL","xFilial('TXO')"}, {"TXO_CODTCW","TCW_CODIGO"}, {"TXO_REVISA","TCW_REVISA"}}, TXO->(IndexKey(1)))
Else
	oModel:SetRelation("TXODETAIL", {{"TXO_FILIAL","xFilial('TXO')"}, {"TXO_CODTCW","TCW_CODIGO"}}, TXO->(IndexKey(1)))
EndIf

oModel:GetModel('TXODETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('TXODETAIL'):SetOptional(.T.)

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc}

@description  ViewDef

@author	jack.junior
@since	02/06/2023
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= ModelDef()
Local oStruTCW	:= FWFormViewStruct():New()
Local oStruTXO	:= FWFormViewStruct():New()
Local oView     := Nil
Local aTables 	:= {}
Local nX		:= 0
Local nY		:= 0

AADD(aTables, {oStruTCW, "TCW"})
AADD(aTables, {oStruTXO, "TXO"})

For nY := 1 to LEN(aTables)

	aFields := at740KDef(aTables[nY][2]) //Definições de campos

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
oView:AddGrid("VIEW_GRID", oStruTXO, "TXODETAIL")

oView:CreateHorizontalBox("CONFIG_TCW", 15 )
oView:CreateHorizontalBox("CONFIG_TXO", 85 )

oView:SetOwnerView("VIEW_CAB" ,"CONFIG_TCW")
oView:SetOwnerView("VIEW_GRID","CONFIG_TXO")

oView:SetDescription(STR0006) //"Verbas Adicionais"

oStruTXO:RemoveField("TXO_BENEFI")
oStruTXO:RemoveField("TXO_VERBA")
oStruTXO:RemoveField("TXO_FORMUL")
oStruTXO:RemoveField("TXO_NICKPO")
oStruTXO:RemoveField("TXO_NICK")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} at740KDef
	Define os campos da tela

@author 	jack.junior
@since	    19/05/2023
/*/
//-------------------------------------------------------------------
Static Function at740KDef(cTable)
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

ElseIf cTable == "TXO"

    //MARKBROWSE
    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := ""	//"Mark"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := ""	//"Mark"
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_MARK"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "L"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "CHECK"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    //--TXO_DESCRI
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007//"Descr. Plan."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007//"Descr. Plan."
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_DESCRI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TXO_BENEFI
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_BENEFI", .T. ) //"Cod Benefici"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_BENEFI", .T. ) //"Cod Benefici"
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_BENEFI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_BENEFI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TXO_DSBENE
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_DSBENE", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_DSBENE", .T. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_DSBENE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_DSBENE")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TXO_VERBA 
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_VERBA", .T. ) //"Verba de Pag"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_VERBA", .T. ) //"Verba de Pag"
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_VERBA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TXO_DSVERB
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008 //"Verba de Pagto."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008 //"Verba de Pagto."
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_DSVERB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_DSVERB")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    //--TXO_TPVERB
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_TPVERB", .T. ) //"Tipo Verba  "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_TPVERB", .T. ) //"Tipo Verba  "
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_TPVERB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    aRet[nAux][DEF_LISTA_VAL] := { "1="+"Horas", "2="+"Valor", "3="+"Dias"} //1=Horas;2=Valor;3=Dias
    aRet[nAux][DEF_COMBO_VAL] := { "1="+"Horas", "2="+"Valor", "3="+"Dias"} //"1=Horas;2=Valor;3=Dias
       //--TXO_PORALT
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_PORALT", .T. ) //"Valor       "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_PORALT", .T. ) //"Valor       "
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_PORALT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_PORALT")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 2
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@E 99,999,999,999.99"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
        //--TXO_NICKPO
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_NICKPO", .T. ) //"Nome Valor  "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_NICKPO", .T. ) //"Nome Valor  "
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_NICKPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_NICKPO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
        //--TXO_NICK  
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_NICK  ", .T. ) //"Nome Celula "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_NICK  ", .T. ) //"Nome Celula "
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_NICK"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_NICK  ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
        //--TXO_FORMUL
	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TXO_FORMUL", .T. ) //"Formula     "
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TXO_FORMUL", .T. ) //"Formula     "
	aRet[nAux][DEF_IDENTIFICADOR] := "TXO_FORMUL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TXO_FORMUL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
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
Local oMdlTXO 	:= oModel:GetModel('TXODETAIL')

//Preenchimento Field (Cabeçalho)
oMdlTCW:LoadValue("TCW_CODIGO", AllTrim(Posicione('TCW',1,cFilTCW+cConfigC,'TCW_CODIGO')))
oMdlTCW:LoadValue("TCW_DESCRI", AllTrim(Posicione('TCW',1,cFilTCW+cConfigC,'TCW_DESCRI')))
oMdlTCW:LoadValue("TCW_CODCCT", AllTrim(Posicione('TCW',1,cFilTCW+cConfigC,'TCW_CODCCT')))

//Preenchimento Grid
aDados := GetDataTXO()

oMdlTXO:SetNoInsertLine(.F.)
oMdlTXO:SetNoDeleteLine(.F.)

If !Empty(aDados)
	If Len(aDados) > 0
		For nX := 1 To Len(aDados)
			If nX > 1
				nLinha := oMdlTXO:AddLine()
			EndIf
			oMdlTXO:GoLine(nLinha)
            oMdlTXO:LoadValue("TXO_MARK"  , aDados[nX][1][1])
			oMdlTXO:LoadValue("TXO_DESCRI", aDados[nX][1][2])
			oMdlTXO:LoadValue("TXO_BENEFI", aDados[nX][1][3])
			oMdlTXO:LoadValue("TXO_DSBENE", aDados[nX][1][4])
			oMdlTXO:LoadValue("TXO_VERBA" , aDados[nX][1][5])
			oMdlTXO:LoadValue("TXO_DSVERB", aDados[nX][1][6])
			oMdlTXO:LoadValue("TXO_TPVERB", aDados[nX][1][7])
			oMdlTXO:LoadValue("TXO_PORALT", aDados[nX][1][8])
			oMdlTXO:LoadValue("TXO_NICKPO", aDados[nX][1][9])
			oMdlTXO:LoadValue("TXO_NICK"  , aDados[nX][1][10])
            oMdlTXO:LoadValue("TXO_FORMUL", aDados[nX][1][11])    
		Next nX
	EndIf
EndIf

oMdlTXO:SetNoInsertLine(.T.)
oMdlTXO:SetNoDeleteLine(.T.)
oMdlTXO:SetNoUpdateLine(.F.)

If !lAparece
	oMdlTXO:SetNoUpdateLine(.T.)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataTXO
@description Bloco de código load do GRID executado no activate
@param oModel, obj, modelo em ativação

TABELA TXO - GRID DA CONFIGURAÇÃO DE CÁLCULO - VERBAS ADICIONAIS

@author	jack.junior
@since	02/06/2023
/*/
//-------------------------------------------------------------------
Static Function GetDataTXO()
Local cAliasTXO := GetNextAlias()
Local aLoadTXO 	:= {}

BeginSql Alias cAliasTXO
	SELECT TXO.TXO_DESCRI,;
           TXO.TXO_BENEFI,;
           TXO.TXO_DSBENE,;
           TXO.TXO_VERBA,;
           TXO.TXO_DSVERB,;
		   TXO.TXO_TPVERB,;
           TXO.TXO_PORALT,;
		   TXO.TXO_NICKPO,;
           TXO.TXO_NICK,;
		   TXO_FORMUL
    		FROM  %table:TXO% TXO
            WHERE TXO.TXO_FILIAL = %xFilial:TXO%
                AND TXO.TXO_CODTCW = %Exp:cConfigC%
                AND TXO.TXO_ITEM != "01"
                AND TXO.%notDel%
EndSql

If (cAliasTXO)->(!Eof())
    While (cAliasTXO)->(!Eof())
        aAdd(aLoadTXO,{{.F.,;                       //MARK - aTXOCarga[nX][1][1]
                        AllTrim((cAliasTXO)->TXO_DESCRI),; //aTXOCarga[nX][1][2]
						(cAliasTXO)->TXO_BENEFI,;          //aTXOCarga[nX][1][3]
                        AllTrim((cAliasTXO)->TXO_DSBENE),; //aTXOCarga[nX][1][4]
                        (cAliasTXO)->TXO_VERBA,;           //aTXOCarga[nX][1][5]
                        AllTrim((cAliasTXO)->TXO_DSVERB),; //aTXOCarga[nX][1][6]
						(cAliasTXO)->TXO_TPVERB,; 		   //aTXOCarga[nX][1][7]
                        (cAliasTXO)->TXO_PORALT,;          //aTXOCarga[nX][1][8]
                        (cAliasTXO)->TXO_NICKPO,;          //aTXOCarga[nX][1][9]
                        (cAliasTXO)->TXO_NICK,;            //aTXOCarga[nX][1][10]
					    (cAliasTXO)->TXO_FORMUL}})         //aTXOCarga[nX][1][11]
                        
        (cAliasTXO)->(DbSkip())
    EndDo
EndIf

(cAliasTXO)->(DbCloseArea())

If Len(aLoadTXO) > 0
	aTXOCarga := UpdateLoad(aLoadTXO) //Atualiza com os dados da planilha do posto.
EndIf

Return aTXOCarga

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateLoad
@description Atualiza array de load com dados atualizados da planilha

@author	jack.junior
@since	02/06/2023
/*/
//-------------------------------------------------------------------
Static Function UpdateLoad(aLoadTXO)
Local nX		:= 0
Local nValPlan 	:= 0

	oPlanTFF := FWUIWorkSheet():New(,.F.,,20,"PLAN_LOAD")
	oPlanTFF:LoadXmlModel(cPlanXML)
	oPlanTFF:AddColumn() //ADICIONA COLUNA "P"

	For nX := 1 To Len(aLoadTXO)
		If oPlanTFF:CellExists(AllTrim(aLoadTXO[nX][1][9]))
			nValPlan := oPlanTFF:GetCellValue(aLoadTXO[nX][1][9])
			If ValType(nValPlan) != "N" //Tratamento para typemismatch:
				nValPlan := Val(nValPlan)
			EndIf
			aLoadTXO[nX][1][8] := nValPlan
		EndIf
	Next nX

Return aLoadTXO

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740KCmmt
	Realizar a gravação dos dados na planilha - XML Planilha nova no posto (TFF)
@sample 	at740KCmmt()
@since		02/06/2023
@return 	oModel, Object, instância do modelo de dados MpFormModel
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740KCmmt(oModel)
Local cFormula	:= "=0"
Local cFormTot  := "=0"
Local lRet		:= .T.
Local lUpdate 	:= .F.
Local nLine 	:= 0
Local nX		:= 0
Local oMdlTXO 	:= oModel:GetModel('TXODETAIL')
Local oMdlABP	:= oModelOrc:getModel('ABP_BENEF')

For nX := 1 To oMdlTXO:Length()
	oMdlTXO:GoLine(nX)
	If oMdlTXO:GetValue("TXO_MARK") //Box marcado
		lUpdate := .T.
		//ALTERA REGISTROS EXISTENTES
		If oPlanTFF:CellExists(oMdlTXO:GetValue("TXO_NICKPO"))
			oPlanTFF:SetCellValue(oMdlTXO:GetValue("TXO_NICKPO"),oMdlTXO:GetValue("TXO_PORALT"))
		//CRIA REGISTROS QUE NÃO EXISTEM - COLUNAS M, N, O
		Else
			nLine := 3 //Registros à partir da terceira linha da planilha
			While ValType(oPlanTFF:GetCell("M"+cValToChar(nLine))) == 'O' //Valida se existe registro na linha
				nLine ++
			EndDo

			If !Empty(oMdlTXO:GetValue("TXO_FORMUL"))
				cFormula := "="+Alltrim(oMdlTXO:GetValue("TXO_FORMUL"))
			EndIf

			//DESCRIÇÃO - COLUNA M
			oPlanTFF:SetCellValue("M"+cValTochar(nLine), oMdlTXO:GetValue("TXO_DESCRI"), , .T.)
			//VALOR - COLUNA N
			oPlanTFF:SetNickName("N"+cValTochar(nLine), oMdlTXO:GetValue("TXO_NICKPO")) 
			oPlanTFF:SetCellValue("N"+cValTochar(nLine), oMdlTXO:GetValue("TXO_PORALT"), , .T.)
			//FORMULA - COLUNA O
			oPlanTFF:SetNickName("O"+cValTochar(nLine), oMdlTXO:GetValue("TXO_NICK")) 
			oPlanTFF:SetCellValue("O"+cValTochar(nLine), cFormula, , .T.)

		EndIf

		If oMdlABP:SeekLine({{"ABP_BENEFI",AllTrim(oMdlTXO:GetValue("TXO_BENEFI"))}})
			oMdlABP:SetValue("ABP_VALOR",oMdlTXO:GetValue("TXO_PORALT"))
			oMdlABP:SetValue("ABP_BENEFI",AllTrim(oMdlTXO:GetValue("TXO_BENEFI")))
			oMdlABP:SetValue("ABP_VERBA",AllTrim(oMdlTXO:GetValue("TXO_VERBA")))
			oMdlABP:SetValue("ABP_NICKPO",AllTrim(oMdlTXO:GetValue("TXO_NICKPO")))
			oMdlABP:SetValue("ABP_CONFCA","1")
		Else
			nLine := oMdlABP:Length(.T.)
			oMdlABP:GoLine(nLine)
			If !Empty(oMdlABP:GetValue("ABP_BENEFI")) .And. !Empty(oMdlABP:GetValue("ABP_VERBA"))
				oMdlABP:AddLine()
			EndIf
			oMdlABP:SetValue("ABP_VALOR",oMdlTXO:GetValue("TXO_PORALT"))
			oMdlABP:SetValue("ABP_BENEFI",AllTrim(oMdlTXO:GetValue("TXO_BENEFI")))
			oMdlABP:SetValue("ABP_VERBA",AllTrim(oMdlTXO:GetValue("TXO_VERBA")))
			oMdlABP:SetValue("ABP_NICKPO",AllTrim(oMdlTXO:GetValue("TXO_NICKPO")))
			oMdlABP:SetValue("ABP_CONFCA","1")
		EndIf
	EndIf
Next nX

If lUpdate //Monta Descrição M, N, O e TOTAL - Caso ainda não tenha
	If !(ValType(oPlanTFF:GetCell("P2")) == 'O')

		oPlanTFF:SetCellValue("N1", "%PORCENTAGEM", , .T.)
		oPlanTFF:SetCellValue("O1", "VALOR", , .T.)
		oPlanTFF:SetCellValue("P1", "TOTAL", , .T.)

		oPlanTFF:SetCellValue("M2", "VERBAS ADICIONAIS", , .T.)
		oPlanTFF:SetCellValue("P2", "TOTAL", , .T.)

		cFormTot := "="+(AllTrim(Posicione("TXO",2,xFilial("TXO")+cConfigC+"TOT_VERAD","TXO_FORMUL"))) //Fórmula do total

		oPlanTFF:SetNickName("P2", "TOT_VERAD") 
		oPlanTFF:SetCellValue("P2", cFormTot, , .T.)

	EndIf
EndIf

If lUpdate
	cPlanXML := oPlanTFF:GetXmlModel(,,,,.F.,.T.,.F.)
	
	If ExistBlock("at740KXml")
		ExecBlock("at740KXml",.F.,.F.,{oMdlTXO,cPlanXML})
	EndIf
EndIf

oModel:DeActivate()

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at740KLimp
	Limpa variáveis estáticas
@sample 	at740KLimp()
@since		02/06/2023
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740KLimp()

aTXOCarga := {}
cPlanXML  := ""
cConfigC  := ""
cPosto	  := ""
oPlanTFF  := Nil 
oModelOrc := Nil
lAparece  := .T.

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} at740KUpdt
	Realiza a atualização dos totais e xml da planilha (POSTO TFF - RH)
@sample 	at740KUpdt()
@since		02/06/2023
@author 	jack.junior
/*/
//------------------------------------------------------------------------------
Static Function at740KUpdt(oModel)
	Local nTotRh	:= 0
	Local nTotPlan	:= 0
	Local oMdlRh  	:= oModel:GetModel("TFF_RH")

	oPlanTFF:LoadXMLModel(cPlanXML) //"Refresh" da planilha - atualiza totais

	If oPlanTFF:CellExists("TOTAL_CUSTOS")
		nTotRh := oPlanTFF:GetCellValue("TOTAL_CUSTOS")
	Elseif oPlanTFF:CellExists("TOTAL_CUSTO")
		nTotRh := oPlanTFF:GetCellValue("TOTAL_CUSTO")
	Endif
	If oPlanTFF:CellExists("TOTAL_BRUTO")
		nTotPlan := oPlanTFF:GetCellValue("TOTAL_BRUTO")
	Endif

	//Pega planilha atualizada
	oPlanTFF:Refresh(.T.)
	cPlanXML := oPlanTFF:GetXmlModel(,,,,.F.,.T.,.F.)

	oMdlRh:SetValue("TFF_CALCMD",cPlanXML)
	oMdlRh:SetValue("TFF_PRCVEN",Round(nTotRh, TamSX3("TFF_PRCVEN")[2]))
	oMdlRh:SetValue("TFF_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))

	If ExistBlock("at740KUpd")
		ExecBlock("at740KUpd",.F.,.F.,{oMdlRh,oPlanTFF})
	EndIf
Return
