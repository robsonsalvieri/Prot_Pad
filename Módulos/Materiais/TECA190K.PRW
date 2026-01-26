#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA190K.ch"

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

Static cSitABB	:= "BR_VERDE" 
Static lDelConf	:= .F.
Static aValALC	:= {}
Static aAlocRES	:= {}

Default oMeter := nil

/* --------------------------------------------------------------------------

// -- ABA ATENDENTES -- //
[AA1] - AA1MASTER - Atendente - VIEW_MASTER

	//Aba Alocação
		[TGY] - TGYMASTER - Configuração de Alocação - VIEW_TGY
		[DTA] - DTAMASTER - Período de Alocação - VIEW_DTA
		[ALC] - ALCDETAIL - Projeção das agendas - DETAIL_ALC
 --------------------------------------------------------------------------*/

/* --------------------------------------------------------------------------
{Protheus.doc} TECA190k - Mesa Operacional - Realocação Reciclagem
 	ModelDef
 		Definição do modelo de Dados

@author flavio.vicco
@since	12/02/2024
--------------------------------------------------------------------------*/

Static Function ModelDef()
Local oModel
Local oStrAA1	:= FWFormModelStruct():New()
Local oStrTGY	:= FWFormModelStruct():New()
Local oStrALC	:= FWFormModelStruct():New()
Local oStrDTA	:= FWFormModelStruct():New()
Local aFields	:= {}
Local nX		:= 0
Local nY		:= 0
Local aTables 	:= {}
Local xAux
Local bCommit	:= { |oModel| At190KYCmt( oModel ) }

oStrAA1:AddTable("   ",{}, STR0001) //"Realocação"
oStrTGY:AddTable("   ",{}, "   ")
oStrALC:AddTable("   ",{}, "   ")
oStrDTA:AddTable("   ",{}, "   ")

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrTGY, "TGY"})
AADD(aTables, {oStrALC, "ALC"})
AADD(aTables, {oStrDTA, "DTA"})

For nY := 1 To LEN(aTables)
	aFields := AT190KDef(aTables[nY][2])

	For nX := 1 TO LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_TITULO_DO_CAMPO],;
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

xAux := FwStruTrigger( 'AA1_CODTEC', 'AA1_NOMTEC',;
	'Posicione("AA1",1,xFilial("AA1") + FwFldGet("AA1_CODTEC"),"AA1_NOMTEC")', .F. )
	oStrAA1:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

xAux := FwStruTrigger( 'TGY_TIPALO', 'TGY_DESMOV',;
	'Posicione("TCU",1,xFilial("TCU", FwFldGet("TGY_FILIAL")) + FwFldGet("TGY_TIPALO"),"TCU_DESC")', .F. )
	oStrTGY:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel := MPFormModel():New('TECA190K',/*bPreValidacao*/,,bCommit,/*bCancel*/)
oModel:SetDescription(STR0001) //"Realocação" 

oModel:addFields('AA1MASTER',,oStrAA1)
oModel:SetPrimaryKey({"AA1_FILIAL","AA1_CODTEC"})

oModel:addFields('TGYMASTER','AA1MASTER',oStrTGY, {|oMdlTGY,cAction,cField,xValue| PreLinTGY(oMdlTGY,cAction,cField,xValue)})
oModel:addFields('DTAMASTER','AA1MASTER',oStrDTA)
oModel:addGrid('ALCDETAIL','TGYMASTER', oStrALC)

oModel:GetModel('TGYMASTER'):SetOnlyQuery(.T.)
oModel:GetModel('ALCDETAIL'):SetOnlyQuery(.T.)
oModel:GetModel('DTAMASTER'):SetOnlyQuery(.T.)

oModel:GetModel('TGYMASTER'):SetOptional(.T.)
oModel:GetModel('ALCDETAIL'):SetOptional(.T.)
oModel:GetModel('DTAMASTER'):SetOptional(.T.)

oModel:GetModel('AA1MASTER'):SetDescription(STR0002) //"Atendente"
oModel:GetModel('TGYMASTER'):SetDescription(STR0003) //"Configuração de Alocação"
oModel:GetModel('ALCDETAIL'):SetDescription(STR0004) //"Projeção de Alocação"
oModel:GetModel('DTAMASTER'):SetDescription(STR0005) //"Data de Alocação"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Definição da interface

@author flavio.vicco
@since 12/02/2024
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= ModelDef()
Local oView
Local aTables 		:= {}
Local oStrAA1		:= FWFormViewStruct():New()
Local oStrTGY		:= FWFormViewStruct():New()
Local oStrDTA		:= FWFormViewStruct():New()
Local oStrALC		:= FWFormViewStruct():New()
Local nX
Local nY
Local nC
Local lMV_MultFil	:= TecMultFil()

AADD(aTables, {oStrAA1, "AA1"})
AADD(aTables, {oStrTGY, "TGY"})
AADD(aTables, {oStrALC, "ALC"})
AADD(aTables, {oStrDTA, "DTA"})

For nY := 1 to LEN(aTables)
	aFields := AT190KDef(aTables[nY][2])

	For nX := 1 to LEN(aFields)
		aTables[nY][1]:AddField(aFields[nX][DEF_IDENTIFICADOR],;
						aFields[nX][DEF_ORDEM],;
						aFields[nX][DEF_TITULO_DO_CAMPO],;
						aFields[nX][DEF_TOOLTIP_DO_CAMPO],;
						aFields[nX][DEF_HELP],;
						aFields[nX][DEF_TIPO_CAMPO_VIEW],;
						aFields[nX][DEF_PICTURE],;
						aFields[nX][DEF_PICT_VAR],;
						aFields[nX][DEF_LOOKUP],;
						aFields[nX][DEF_CAN_CHANGE],;
						aFields[nX][DEF_ID_FOLDER],;
						aFields[nX][DEF_ID_GROUP],;
						aFields[nX][DEF_COMBO_VAL],;
						aFields[nX][DEF_TAM_MAX_COMBO],;
						aFields[nX][DEF_INIC_BROWSE],;
						aFields[nX][DEF_VIRTUAL],;
						aFields[nX][DEF_PICTURE_VARIAVEL],;
						aFields[nX][DEF_INSERT_LINE],;
						aFields[nX][DEF_WIDTH])
		If aTables[nY][2] == "AA1" .AND. !(aFields[nX][DEF_IDENTIFICADOR] $ "AA1_CODTEC|AA1_NOMTEC")
			aTables[nY][1]:RemoveField(aFields[nX][DEF_IDENTIFICADOR])
		EndIf
	Next nX
Next nY


oStrTGY:RemoveField("TGY_RECNO")
oStrALC:RemoveField("ALC_KEYTGY")
oStrALC:RemoveField("ALC_ITTGY")
oStrALC:RemoveField("ALC_TURNO")
oStrALC:RemoveField("ALC_EXSABB")
oStrALC:RemoveField("ALC_ITEM")
oStrALC:RemoveField("ALC_GRUPO")

If !lMV_MultFil
	oStrTGY:RemoveField("TGY_FILIAL")
EndIf

For nC := 1 to 4
	oStrTGY:RemoveField("TGY_ENTRA"+ Str(nC, 1))
	oStrTGY:RemoveField("TGY_SAIDA"+ Str(nC, 1))
Next

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_MASTER', oStrAA1, 'AA1MASTER')
oView:AddField('VIEW_TGY',  oStrTGY, 'TGYMASTER')
oView:AddField('VIEW_DTA',  oStrDTA, 'DTAMASTER')
oView:AddGrid('DETAIL_ALC', oStrALC, 'ALCDETAIL')

oView:CreateHorizontalBox( 'REALOC_AA1' , 16 )
oView:CreateHorizontalBox( 'REALOC_TGY', 26)
oView:CreateHorizontalBox( 'REALOC_DTA', 17)
oView:CreateHorizontalBox( 'REALOC_BTN', 8)
oView:CreateHorizontalBox( 'REALOC_ALOC', 33)

oView:CreateVerticalBox( 'V_ABA02_2', 9, 'REALOC_BTN' )
oView:CreateVerticalBox( 'V_ABA04_2', 82, 'REALOC_BTN' )

oView:AddOtherObject("PROCONF",{|oPanel| at190KConf(oPanel) }) 
oView:SetOwnerView("PROCONF","V_ABA02_2")

oView:SetOwnerView('VIEW_MASTER','REALOC_AA1')
oView:SetOwnerView('VIEW_TGY','REALOC_TGY')
oView:SetOwnerView('VIEW_DTA','REALOC_DTA')
oView:SetOwnerView('DETAIL_ALC','REALOC_ALOC')

oView:SetContinuousForm()

oView:EnableTitleView('VIEW_MASTER',	STR0002) //"Atendente"
oView:EnableTitleView('VIEW_TGY',		STR0003) //"Configuração de Alocação"
oView:EnableTitleView('VIEW_DTA',		STR0006) //"Período de Alocação"

oView:SetDescription(STR0001) //"Realocação"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190KDef

@description Retorna em forma de Array as definições dos campos
@param cTable, string, define de qual tabela devem ser os campos retornados
@return aRet, array, definição dos campos

@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Function AT190KDef(cTable)
Local aRet		:= {}
Local nAux 		:= 0
Local cOrdem 	:= "01"
Local nC 		:= 1
Local cCampoE 	:= "TGY_ENTRA"
Local cCampoS 	:= "TGY_SAIDA"
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

If cTable == "AA1"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FILIAL", .T. )  //"Filial do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FILIAL", .F. ) //"Filial do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FILIAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FILIAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| xFilial("AA1")}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. ) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19AA1" //At190dCons("AA1")
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0033} //"Código do atendente cadastrado no 'Gestão de Serviços'"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )  //"Nome Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. ) //"Nome Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FONE", .T. )  //"Telefone p/ contato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FONE", .F. ) //"Telefone p/ contato"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FONE"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FONE")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0007 //"Matrícula do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0007 //"Matrícula do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_CDFUNC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CDFUNC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_FUNCAO", .T. )  //"Função do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_FUNCAO", .F. ) //"Função do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_FUNCAO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_FUNCAO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "RJ_DESC", .T. )  //"Descricao da Funcao"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "RJ_DESC", .F. ) //"Descricao da Funcao"
	aRet[nAux][DEF_IDENTIFICADOR] := "AA1_DESFUN"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("RJ_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

ElseIf cTable == "DTA"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008 //"Alocação de?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008 //"Alocação de?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DTINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0034} //"Inicio do periodo de Alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009 //"Alocação até?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009 //"Alocação até?"
	aRet[nAux][DEF_IDENTIFICADOR] := "DTA_DTFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0035} //"Fim do periodo de alocação"

ElseIf cTable == "TGY"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "CN9_FILIAL", .T. )  //"Numero do Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "CN9_FILIAL", .F. ) //"Numero do Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_FILIAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||!Empty(FwFldGet("AA1_CODTEC"))}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "SM0"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
	aRet[nAux][DEF_HELP] := {STR0036} //"Filial utilizada para buscar o contrato"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010 //"Orçamento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFJ_CODIGO", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_CODIGO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFJ_CODIGO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||!Empty(FwFldGet("AA1_CODTEC"))}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190KOrcam("TGYMASTER","TGY_FILIAL","TGY_CODIGO")}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"  
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CONSR1" // At190dCons("CONTRATO") // T19DCN
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0037} //"Número do Orçamento."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011 //"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011 //"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_CODTFL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_LOCAL")[1] 
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CONSR4" //At190dCons("LOCAL_TGY")
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0038} //"Código do Local de Atendimento."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .T. )  //"Descrição do Local"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "ABS_DESCRI", .F. ) //"Descrição do Local"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_DESLOC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("ABS_DESCRI")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012 //"Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012 //"Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_TFFCOD"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||!Empty(FwFldGet("AA1_CODTEC"))} // {|| .F. }
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190KPosto("TGYMASTER","TGY_FILIAL","TGY_TFFCOD")}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CONSR6" //At190dCons("POSTO") 
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0039} //"Código de recursos humanos."

	If TFF->( ColumnPos('TFF_REGRA') ) > 0
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_REGRA", .T. )
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_REGRA", .F. )
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_REGRA"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_REGRA")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_CODEBLOCK_VALID] := {|| .T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "07"
		aRet[nAux][DEF_PICTURE] := "99"
		aRet[nAux][DEF_LOOKUP] := "SPA"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0040} //"Informe a Regra de Apontamento"
	EndIf

	If TecABBPRHR()
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0013 //"Horas Totais"
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0013 //"Horas Totais"
		aRet[nAux][DEF_IDENTIFICADOR] := "TGY_TFFHRS"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_QTDHRS")[1]
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "08"
		aRet[nAux][DEF_PICTURE] := PesqPict("TFF","TFF_QTDHRS")
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0041} //"Horas Totais do Orçamento."
	EndIf

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .T. )  //"Código da Escala"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .F. ) //"Código da Escala"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_ESCALA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "TDW"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0042} //"Preencher com Código da Escala."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_TIPALO", .T. )  //"Tipo Movimentação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_TIPALO", .F. ) //"Tipo Movimentação"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_TIPALO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TIPALO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	If !lMV_MultFil
		aRet[nAux][DEF_LOOKUP] := "TCUALC"
	Else
		aRet[nAux][DEF_LOOKUP] := "T19TCU" //At190dCons("TCU")
	EndIf
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0043} //"Informe o tipo de movimentação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 //"Desc. Movim."
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Desc. Movim."
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_DESMOV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TCU_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0044} //"Descrição do tipo de movimentação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0015 //"Seq. Inicial"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0015 //"Seq. Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_LOOKUP] := "T19SEQ" //At190dCons("SEQ")
	aRet[nAux][DEF_HELP] := {STR0045} //"Preencher com Sequencia do Turno."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .T. )  //"Grupo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .F. ) //"Grupo"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_GRUPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T. 
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "13"
	aRet[nAux][DEF_PICTURE] := "@E 999"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_LOOKUP] := "T19GRP" //At190dCons("TGY_GRUPO")
	aRet[nAux][DEF_HELP] := {STR0046} //"Preencher com grupo do atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0003 //"Configuração de Alocação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0003 //"Configuração de Alocação"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_CONFAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDX_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. } 
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "14"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "T19CFA" //At190dCons("TGY_CONFAL")
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0047} //"Configuração de Tabela de Horário e Sequência para efetivos ou do tipo de Cobertura"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0016 //"Dt. Última Alocação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0016 //"Dt. Última Alocação"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_ULTALO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "15"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "RECNO"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "RECNO"
	aRet[nAux][DEF_IDENTIFICADOR] := "TGY_RECNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "16"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	cOrdem := "15"
	For nC := 1 to 4
		cOrdem := Soma1(cOrdem)
		cCampoE := "TGY_ENTRA" + Str(nC,1)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0017 + Str(nC,1) //"Hora Ini "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0018 + Str(nC,1) //"Horário de Entrada "
		aRet[nAux][DEF_IDENTIFICADOR] := cCampoE
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.

		cCampoS := "TGY_SAIDA" + Str(nC,1)
		cOrdem := Soma1(cOrdem)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0019 + Str(nC,1) //"Hora Fim "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0020 + Str(nC,1) //"Horário de Saída "
		aRet[nAux][DEF_IDENTIFICADOR] := cCampoS
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "@!"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
	Next nC

ElseIf cTable == "ALC"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0021 //"Agenda"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0021 //"Agenda"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SITABB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLA()}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0022 //"Status"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0022 //"Status"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SITALO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At330AGtLS()}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .T. )  //"Grupo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .F. ) //"Grupo"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_GRUPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@E 999"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0048} //"Preencher com grupo do atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 //"Dt. Referência"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0023 //"Dt. Referência"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DATREF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0024} //"Data da alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024 //"Data da Alocação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024 //"Data da Alocação"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DATA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0024} //"Data da alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0025 //"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025 //"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SEMANA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0025} //"Dia da Semana"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0026 //"Hora de Entrada"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0026 //"Hora de Entrada"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ENTRADA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0026} //"Hora de Entrada"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027 //"Hora de Saída"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027 //"Hora de Saída"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SAIDA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {|oMdl,cField,xNewValue| At190dHora(oMdl,cField,xNewValue)}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0027} //"Hora de Saída"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0028 //"Sequencia"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0028 //"Sequencia"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_HELP] := {STR0049} //"Preencher com Sequencia do Turno."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0029 //"Tipo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0029 //"Tipo"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TIPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| !Empty( At190dGVal("ALCDETAIL", "ALC_DATREF"))}
	aRet[nAux][DEF_LISTA_VAL] := {"S=Trabalhado","C=Compensado","D=D.S.R.","E=Hora Extra","I=Intervalo","N=Nao Trabalhado"}
	aRet[nAux][DEF_COMBO_VAL] := {"S=Trabalhado","C=Compensado","D=D.S.R.","E=Hora Extra","I=Intervalo","N=Nao Trabalhado"}
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0050} //"Tipo de dia: Trabalhado, não trabalhado, folga ou DSR."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "KeyTGY"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "KeyTGY"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_KEYTGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ESCALA")[1] + TamSX3("TGY_CODTDX")[1] + TamSX3("TGY_CODTFF")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "ItemTGY"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "ItemTGY"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ITTGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ITEM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "EXSABB"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "EXSABB"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_EXSABB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "13"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_TURNO", .T. ) //"Turno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_GRUPO", .T. ) //"Codigo do Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "14"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0051} //"Preencher com o Código do Turno."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0030 //"Item"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0030 //"Item"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_ITEM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "15"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031 //"Saída intervalo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031 //"Saída intervalo"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_INTERV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LISTA_VAL] := {"S=Sim","N=Não"}
	aRet[nAux][DEF_COMBO_VAL] := {"S=Sim","N=Não"}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "N" }
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_ORDEM] := "16"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T.}
	aRet[nAux][DEF_HELP] := {STR0052} //"Este campo replica a funcionalidade do campo 1a.S.Interb na Tabela de Horários. Marque-o como SIM caso exista outra alocação avulsa e o período entre as duas alocações represente o intervalo. Ex: 08 as 12 / 13 as 18 Se das 12 as 13 não for intervalo, deve-se informar NÃO"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0032 //"Desc. Conflito"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0032 //"Desc. Conflito"
	aRet[nAux][DEF_IDENTIFICADOR] := "ALC_DSCONF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 35
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "18"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados
@description Bloco de código executado no activate
@param oModel, obj, modelo em ativação
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function InitDados(oModel)
Local oMdl190d := FwModelActive()
Local oMdlAA1 := oModel:GetModel("AA1MASTER")
Local oMdlDTA := oModel:GetModel("DTAMASTER")
Local oStrAA1 := oMdlAA1:GetStruct() 
Local nX
Local aMarks := ACLONE(At190DSMar())
Local dDataDe
Local dDataAte

	oMdlAA1:SetValue("AA1_CODTEC", oMdl190d:GetValue("AA1MASTER","AA1_CODTEC"))
	oStrAA1:SetProperty("AA1_CODTEC", MODEL_FIELD_WHEN, {|| .F.})
	oStrAA1:SetProperty("AA1_NOMTEC", MODEL_FIELD_WHEN, {|| .F.})
	For nX := 1 TO LEN(aMarks)
		If !EMPTY(aMarks[nX][1])
			If EMPTY(dDataDe)
				dDataDe := aMarks[nX][9]
			EndIf
			If EMPTY(dDataAte)
				dDataAte := aMarks[nX][9]
			EndIf
			If aMarks[nX][9] > dDataAte
				dDataAte := aMarks[nX][9] 
			EndIf
		EndIf
	Next nX
	oMdlDTA:SetValue("DTA_DTINI",dDataDe)
	oMdlDTA:SetValue("DTA_DTFIM",dDataAte)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinTGY
@description Função de Prevalidacao dos fields de alocação RES
@param 
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function PreLinTGY(oMdlTGY,cAction,cField,xValue)
Local lRet			:= .T.
local lCont			:= .T.
// Local nQTDV			:= 0
// Local lMV_MultFil	:= TecMultFil() //Indica se a Mesa considera multiplas filiais

If ValType(oMdlTGY) == 'O' .AND. oMdlTGY:GetId() == "TGYMASTER"

	If cAction == "SETVALUE"

		If cField == "TGY_CODIGO"
			If Empty(xValue)
				oMdlTGY:SetValue("TGY_CODTFL", "")
				oMdlTGY:SetValue("TGY_TFFCOD", "")
				//oMdlTGY:SetValue("TGY_TIPMOV", "")
			EndIf
		  	lCont := CheckOrcam(xValue, oMdlTGY:GetValue("TGY_FILIAL"))
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil, STR0053, 1 ) //"O orçamento digitado nao existe. Verifique e refaça a operação"
			Endif
		Elseif 	cField == "TGY_CODTFL"
			If Empty(xValue)
				oMdlTGY:SetValue("TGY_TFFCOD", "")
				//oMdlTGY:SetValue("TGY_TIPALO", "")
			EndIf
			lCont := CheckTFL(xValue, oMdlTGY:GetValue("TGY_CODIGO"), oMdlTGY:GetValue("TGY_FILIAL"))
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil, STR0054, 1 ) //"O Local de atendimento digitado nao existe. Verifique e refaça a operação"
			Endif
		Elseif 	cField == "TGY_TFFCOD"
			If Empty(xValue)
				//oMdlTGY:SetValue("TGY_TIPALO", "")
			EndIf
			lCont := CheckTFF(xValue, oMdlTGY:GetValue("TGY_CODIGO"), oMdlTGY:GetValue("TGY_CODTFL"), oMdlTGY:GetValue("TGY_FILIAL"))
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil, STR0055, 1 ) //"O Posto digitado nao existe. Verifique e refaça a operação."
			Endif
		ElseIf cField == "TGY_ESCALA"
			If !EMPTY(xValue)
				lRet := CheckTDW(xValue, oMdlTGY:GetValue("TGY_FILIAL"))
			EndIf
		ElseIf cField == "TGY_TIPALO"
			If !EMPTY(xValue)
				lRet := CheckTCU(xValue,oMdlTGY:GetValue("TGY_FILIAL"))
			EndIf
		ElseIf cField == "TGY_SEQ"
			If !EMPTY(xValue)
				lRet := CheckTDX(xValue, oMdlTGY:GetValue("TGY_ESCALA"), oMdlTGY:GetValue("TGY_FILIAL"))
			EndIf
		ElseIf cField == "TGY_GRUPO"
			// If !EMPTY(xValue)
			// 	nQTDV := Posicione("TFF", 1, xFilial("TFF",IIF(lMV_MultFil,oMdlTGY:GetValue("TGY_FILIAL"),cFilAnt)) + oMdlTGY:GetValue("TGY_TFFCOD"), "TFF_QTDVEN")
			// 	If nQTDV < xValue
			// 		If TCU->( FieldPos('TCU_TIPOMV') ) > 0	
			// 			If At680Perm( Nil, __cUserID, "005" ) 
			// 				If Posicione("TCU",1,xFilial("TCU")+oMdlTGY:GetValue("TGY_TIPALO"),"TCU_TIPOMV") <> "2"
			// 					Help( " ", 1, "PRELINTGY", Nil, "Tipo de Movimentação não permite alocar quantidade excedente para atendentes.", 1, 0,,,,,,{"Utilizar tipo de movimentação com o excedente igual a sim."}) //"Tipo de Movimentação não permite alocar quantidade excedente para atendentes." - "Utilizar tipo de movimentação com o excedente igual a sim."
			// 					lRet	:= .F.
			// 				EndIf
			// 			Else 
			// 				Help( " ", 1, "PRELINTGY", Nil, "Usuário sem permissão para alocar mais atendentes que a quantidade vendida (excedente).", 1 ) // "Usuário sem permissão para alocar mais atendentes que a quantidade vendida (excedente)."
			// 				lRet	:= .F.
			// 			EndIf
			// 		Else
			// 			If !(At680Perm( Nil, __cUserID, "005" )) 
			// 				Help( " ", 1, "PRELINTGY", Nil, "A quantidade de atendentes (grupos) ultrapassou o permitido no posto (limite de " + cValToChar(nQTDV) + ")", 1 ) //"A quantidade de atendentes (grupos) ultrapassou o permitido no posto (limite de "
			// 				lRet	:= .F.
			// 			EndIf
			// 		EndIf
			// 	EndIf
			// EndIf
		Elseif cField == "TGY_CONFAL" 
			If !EMPTY(xValue)
				lRet := ChkConfal(xValue,oMdlTGY:GetValue("TGY_ESCALA"),oMdlTGY:GetValue("TGY_SEQ"),oMdlTGY:GetValue("TGY_FILIAL") )
			EndIf	
		EndIf
	Endif
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckOrcam
@description Verifica se o valor xValue é um Orcamento válido
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function CheckOrcam(xValue, cFilCtr)
Local cQry := ""
Local lRet := .T.

Default cFilCtr := xFilial('TFJ') 

cQry := " SELECT TFJ_FILIAL, TFJ_CODIGO , TFJ_CODENT, TFJ_LOJA, TFJ_TREINA "
cQry += " FROM " + RetSqlName("TFJ") + " TFJ "
cQry += " WHERE TFJ.TFJ_FILIAL = '" +  cFilCtr + "' AND TFJ.TFJ_CODIGO = '" + xValue + "' "
cQry += " AND TFJ.TFJ_TREINA= '1' AND TFJ.TFJ_RESTEC = '1' AND TFJ.D_E_L_E_T_ = ' ' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTFL
@description Verifica se o valor xValue é um Local de Atendimento válido
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function CheckTFL(xValue, cOrcam, cFilTFJ)
Local cQry := ""
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cTamCtr := SPACE(TamSX3("CN9_NUMERO")[1])

Default cFilTFJ := xFilial("TFJ")

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TFL") + " TFL "
cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
If !lMV_MultFil
	cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
Else
	cQry += " ON " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " "
EndIf
cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
cQry += " AND TFJ.TFJ_STATUS = '1' "
cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
cQry += " WHERE TFJ.TFJ_FILIAL = '" + cFilTFJ + "' "
cQry += " AND TFJ.TFJ_CODIGO = '" + cOrcam + "' "
cQry += " AND TFJ.TFJ_CONTRT = '" + cTamCtr + "' "
cQry += " AND TFL.TFL_LOCAL  = '" + xValue + "' "
cQry += " AND TFJ_RESTEC = '1' AND TFJ_TREINA = '1' "
cQry += " AND TFL.D_E_L_E_T_ = ' ' "
If !lMV_MultFil
	cQry += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
EndIf
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTFF
@description Verifica se o valor xValue é um Local de Atendimento válido
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function CheckTFF(xValue, cOrcam, cCodTFL, cFilTFJ)
Local cQry := ""
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais

Default cFilTFJ := xFilial("TFJ")

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TFF") + " TFF "
cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQry += " ON "
cQry += " TFL.D_E_L_E_T_ = ' ' "
cQry += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
If !lMV_MultFil
	cQry += " AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
Else
	cQry += " AND " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " "
EndIf
cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
If !lMV_MultFil
	cQry += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
Else
	cQry += " ON " + FWJoinFilial("TFJ" , "TFL" , "TFJ", "TFL", .T.) + " "
EndIf
cQry += " AND TFJ.D_E_L_E_T_ = ' ' "
cQry += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
cQry += " AND TFJ.TFJ_STATUS = '1' "
cQry += " WHERE "
cQry += " TFF.D_E_L_E_T_ = ' ' "
cQry += " AND TFL.TFL_CODPAI = '" + cOrcam + "' "
cQry += " AND TFF.TFF_COD = '" + xValue + "' "
cQry += " AND TFJ.TFJ_FILIAL = '" + cFilTFJ + "' "
If !lMV_MultFil
	cQry += " AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
EndIf
If (QryEOF(cQry)) 
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTDW
@description 
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function CheckTDW(xValue, cFilCtr)
Local cQry := ""
Local lRet := .T.
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt 
cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TDW") + " TDW "
cQry += " WHERE TDW.TDW_FILIAL = '" +  xFilial('TDW', IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " TDW.D_E_L_E_T_ = ' ' "
cQry += " AND TDW.TDW_COD = '" + xValue + "' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTCU
@description 
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function CheckTCU(xValue,cFilCtr)
Local lRet  := .T.
Local cQry  := ""
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TCU") + " TCU "
cQry += " WHERE TCU.TCU_FILIAL = '" +  xFilial('TCU',IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " TCU.D_E_L_E_T_ = ' ' "
cQry += " AND TCU.TCU_COD = '" + xValue + "' "
cQry += " AND TCU.TCU_EXALOC = '1' "
cQry += " AND TCU.TCU_TIPOMV = '4' "
If (QryEOF(cQry))
	 lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CheckTDX
@description 
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function CheckTDX(xValue, cEscala, cFilCtr)
Local lRet := .T.
Local cQry := ""
Local lMV_MultFil := TecMultFil()//Indica se a Mesa considera multiplas filiais
Default cFilCtr := cFilAnt

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.TDX_FILIAL = '" +  xFilial('TDX',IIF(lMV_MultFil,cFilCtr,cFilAnt)) + "' AND "
cQry += " TDX.D_E_L_E_T_ = ' ' "
If !EMPTY(xValue)
	cQry += " AND TDX.TDX_SEQTUR = '" + xValue + "' "
EndIf
cQry += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkConfal
@description 
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function ChkConfal(xValue,cEscala,cSeq,cFilCtr) 
Local cQry := ""
Local lRet := .T.

Default cFilCtr := cFilAnt

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.TDX_FILIAL = '" +  xFilial('TDX',cFilCtr) + "' AND "
cQry += " TDX.D_E_L_E_T_ = ' ' "
If !EMPTY(cEscala)
    cQry += " AND TDX.TDX_CODTDW = '" + cEscala + "' "
Endif
If !EMPTY(xValue)
	cQry += " AND TDX.TDX_COD = '" + xValue + "' "
EndIF
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} at190KConf
@description Cria o botão "Projetar Aloc."
@param oPanel
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Function at190KConf(oPanel)

	TButton():New( (oPanel:nHeight / 2) - 12, 2, STR0056, oPanel, { || FwMsgRun(Nil,{|| At190KYAgen()}, Nil,STR0056)},55,11,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Projetar"

Return Nil

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190KYAgen
@description Executa a alocação de acordo com os dados na RES
@return Nil
@author flavio.vicco
@since  12/02/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190KYAgen()

Local oModel	:= FwModelActive()
Local oView		:= FwViewActive()
Local oMdlALC 	:= oModel:GetModel("ALCDETAIL")
Local oDlg		:= nil
Local oSayMtr	:= nil
Local oMeter	:= nil
Local nMeter	:= 0
Local cMsg		:= ""

oMdlALC:SetNoInsertLine(.F.)
oMdlALC:SetNoDeleteLine(.F.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0057 Style 128 //"Projetar alocações"
	oSayMtr := tSay():New(10,10,{||STR0058},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
	oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},1,oDlg,220,10,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (At190KPrjLAC(@oDlg,@oMeter,cMsg))

oMdlALC:GoLine(1)

oMdlALC:SetNoInsertLine(.T.)
oMdlALC:SetNoDeleteLine(.T.)

FwModelActive(oModel)
oMdlALC:GoLine(1)
oView:Refresh("ALCDETAIL")

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190KYCmt
@description Grava as agendas instanciadas em GsAloc
@return Logico
@author flavio.vicco
@since  12/02/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190KYCmt(oModel)

Local oDlg		:= nil
Local oSayMtr	:= nil
Local oMeter	:= NIL
Local oView		:= FwViewActive()
Local nMeter	:= 0

	DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0059 Style 128 //"Gravar alocações"
		oSayMtr := tSay():New(10,10,{||STR0058},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
		oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},LEN(aAlocRES),oDlg,220,10,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (GravRES(@oDlg,@oMeter))

oView:Refresh("ALCDETAIL")

Return .T.
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190KPrjLAC
@description Executa a projeção das agendas de reserva técnica dentro de uma barra de progresso
@return Nil
@author flavio.vicco
@since  12/02/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190KPrjLAC(oDlg,oMeter,cMsg)

Local oModel	:= FwModelActive()
Local oView		:= FwViewActive()
Local oMdlAA1 	:= oModel:GetModel("AA1MASTER")
Local oMdlTGY 	:= oModel:GetModel("TGYMASTER")
Local oMdlDTA 	:= oModel:GetModel("DTAMASTER")
Local oMdlALC 	:= oModel:GetModel("ALCDETAIL")
Local nCount	:= 0
Local nY		:= 0

oMdlALC:ClearData()
oMdlALC:InitLine()
If !EMPTY(oMdlTGY:GetValue("TGY_ESCALA"))
	AADD(aAlocRES, {})
	nAux := LEN(aAlocRES)
	aAlocRES[nAux] := GsAloc():New()
	If TecMultFil()
		aAlocRES[nAux]:defFil(oMdlTGY:GetValue("TGY_FILIAL"))
	EndIf
	aAlocRES[nAux]:defEscala(oMdlTGY:GetValue("TGY_ESCALA"))
	aAlocRES[nAux]:defPosto(oMdlTGY:GetValue("TGY_TFFCOD"))
	aAlocRES[nAux]:defTec(oMdlAA1:GetValue("AA1_CODTEC"))
	aAlocRES[nAux]:defGrupo(oMdlTGY:GetValue("TGY_GRUPO"))
	aAlocRES[nAux]:defConfal(oMdlTGY:GetValue("TGY_CONFAL"))
	aAlocRES[nAux]:defDate(oMdlDTA:GetValue("DTA_DTINI"),oMdlDTA:GetValue("DTA_DTFIM"))
	aAlocRES[nAux]:defSeq(oMdlTGY:GetValue("TGY_SEQ"))
	aAlocRES[nAux]:defTpAloca(oMdlTGY:GetValue("TGY_TIPALO"))
	aAlocRES[nAux]:defTpAlo(oMdlTGY:GetValue("TGY_TIPALO"))
	aAlocRES[nAux]:defResTec("1") //Reserva Tecnica
	If TecXHasEdH()
		aAlocRES[nAux]:defGeHor	({;
								{oMdlALC:GetValue("ALC_ENTRADA"),;
								oMdlALC:GetValue("ALC_SAIDA")},;
								{" ",;
								" "},;
								{" ",;
								" "},;
								{" ",;
								" "};
								})
	EndIf
	aAlocRES[nAux]:projAloc()
	If !EMPTY(aAlocRES[nAux]:defMessage())
		oMdlAlc:LoadValue("ALC_DSCONF", LEFT(aAlocRES[nAux]:defMessage(), 35))
	Endif
	If aAlocRES[nAux]:getConfl()
		oMdlAlc:LoadValue("ALC_SITALO", "BR_PRETO")
	ElseIf aAlocRES[nAux]:temBloqueio() .OR. aAlocRES[nAux]:temAviso()
		oMdlAlc:LoadValue("ALC_SITALO", "BR_PINK")
	Else
		oMdlAlc:LoadValue("ALC_SITALO", "BR_AMARELO")
	EndIf
EndIf

For nY := 1 To Len(aAlocRES[nAux]:getProj())
	If oMdlALC:GetMaxLines() < LEN(aAlocRES[nAux]:getProj())
		oMdlALC:SetMaxLine(LEN(aAlocRES[nAux]:getProj()))
	EndIf
	If nY != 1
		oMdlALC:AddLine()
	EndIf
	oMdlALC:LoadValue("ALC_SITABB",  aAlocRES[nAux]:getProj()[nY][1])
	oMdlALC:LoadValue("ALC_SITALO",  At330ACLgS(aAlocRES[nAux]:getProj()[nY][11]))
	oMdlALC:LoadValue("ALC_GRUPO",   aAlocRES[nAux]:getProj()[nY][3])
	oMdlALC:LoadValue("ALC_DATREF",  aAlocRES[nAux]:getProj()[nY][4])
	oMdlALC:LoadValue("ALC_DATA",    aAlocRES[nAux]:getProj()[nY][5])
	oMdlALC:LoadValue("ALC_SEMANA",  aAlocRES[nAux]:getProj()[nY][6])
	oMdlALC:LoadValue("ALC_ENTRADA", aAlocRES[nAux]:getProj()[nY][7])
	oMdlALC:LoadValue("ALC_SAIDA",   aAlocRES[nAux]:getProj()[nY][8])
	oMdlALC:LoadValue("ALC_TIPO",    aAlocRES[nAux]:getProj()[nY][11])
	oMdlALC:LoadValue("ALC_SEQ",     aAlocRES[nAux]:getProj()[nY][15])
	oMdlALC:LoadValue("ALC_EXSABB",  aAlocRES[nAux]:getProj()[nY][19])
	oMdlALC:LoadValue("ALC_KEYTGY",  aAlocRES[nAux]:getProj()[nY][17])
	oMdlALC:LoadValue("ALC_ITTGY",   aAlocRES[nAux]:getProj()[nY][18])
	oMdlALC:LoadValue("ALC_TURNO",   aAlocRES[nAux]:getProj()[nY][14])
	oMdlALC:LoadValue("ALC_ITEM",    aAlocRES[nAux]:getProj()[nY][16])
	oMdlALC:LoadValue("ALC_DSCONF",  LEFT(aAlocRES[nAux]:getProj()[nY][23],35))

Next nY

oMeter:Set(++nCount)
oMeter:Refresh()
oView:Refresh("ALCDETAIL")
oDlg:End()

Return

Static Function GravRES(oDlg,oMeter)
Local nX      := 0
Local nY      := 0
Local nCount  := 0
Local nPos    := 0
Local nAviso  := 0
Local oModel  := FwModelActive()
Local oMdlAA1 := oModel:GetModel("AA1MASTER")
Local oMdlTGY := oModel:GetModel("TGYMASTER")
Local oMdlDTA := oModel:GetModel("DTAMASTER")
Local oMdlALC := oModel:GetModel("ALCDETAIL")
Local lContinua := .T.
Local lAlocConf := .F.

Default oDlg   := nil
Default oMeter := nil

For nX := 1 To oMdlALC:Length()
	oMdlALC:GoLine(nX)
	If oMdlALC:GetValue("ALC_SITABB") == "BR_PRETO"
		nAviso := Aviso(STR0060,;
				STR0061,;
				{STR0062,;
				STR0063,;
				STR0064},2) //"Atenção"###"Um ou mais dias possuem conflito de alocação. Deseja alocar todos os atendentes mesmo com os conflitos ou alocar apenas nos dias disponíveis? Esta opção será aplicada em todos os atendentes."###"Apenas disponiveis"###"Todos os dias"###"Cancelar"
		If nAviso == 3 //Cancelar
			lContinua := .F.
		ElseIf nAviso == 1 //Alocar mesmo com conflito
			lAlocConf := .T.
		ElseIf nAviso == 2 //Alocar apenas dias sem conflitos
			lAlocConf := .F.
		EndIf
		Exit
	EndIf
Next nX

For nX := 1 To oMdlALC:Length()
	oMdlALC:GoLine(nX)
	If oMdlALC:GetValue("ALC_SITABB") == "BR_PINK"
		lContinua := MsgYesNo(STR0065) //"Um ou mais atendentes possuem restrições no período. Deseja continuar?"
		Exit
	EndIf
Next nX

If lContinua
	oMdlTGY:GetValue("TGY_ESCALA")

	TFJ->(dbSetOrder(1)) //TFJ_FILIAL+TFJ_CODIGO
	If TFJ->(DbSeek(xFilial("TFJ")+oMdlTGY:GetValue("TGY_CODIGO")))

		For nX := 1 To oMdlALC:Length()
			nPos := 0
			oMdlALC:GoLine(nX)
			For nY := 1 To Len(aAlocRES)
				If VALTYPE(aAlocRES[nY]) == 'O' .AND.;
						aAlocRES[nY]:defEscala() == oMdlTGY:GetValue("TGY_ESCALA") .AND.;
						aAlocRES[nY]:defPosto() == oMdlTGY:GetValue("TGY_TFFCOD") .AND.;
						aAlocRES[nY]:defSeq() == oMdlTGY:GetValue("TGY_SEQ") .AND.;
						aAlocRES[nY]:defTec() == oMdlAA1:GetValue("AA1_CODTEC") .AND.;
						aAlocRES[nY]:defGrupo() == oMdlTGY:GetValue("TGY_GRUPO") .AND.;
						aAlocRES[nY]:defConfal() == oMdlTGY:GetValue("TGY_CONFAL") .AND.;
						aAlocRES[nY]:defDate()[1] == oMdlDTA:GetValue("DTA_DTINI") .AND.;
						aAlocRES[nY]:defDate()[2] == oMdlDTA:GetValue("DTA_DTFIM")
					If TecXHasEdH()
						If  aAlocRES[nY]:getProj()[nY][7] == oMdlALC:GetValue("ALC_ENTRADA").AND.;
							aAlocRES[nY]:getProj()[nY][8] == oMdlALC:GetValue("ALC_SAIDA")
							nPos := nY
							Exit
						Endif
					Else
						nPos := nY
						Exit
					EndIf
				EndIf
			Next nY
			If nPos > 0
				aAlocRES[nPos]:alocaConflitos(lAlocConf)
				If aAlocRES[nPos]:gravaAloc()
					oMdlALC:LoadValue("ALC_SITABB","BR_VERDE")
					If !Empty(aAlocRES[nPos]:getLastSeq())
						oMdlALC:LoadValue("ALC_SEQ",aAlocRES[nPos]:getLastSeq())
					EndIf
				Else
					oMdlALC:LoadValue("ALC_SITABB","BR_LARANJA")
				EndIf
				oMdlALC:LoadValue("ALC_DSCONF",LEFT(aAlocRES[nPos]:defMessage(), 185))
				oMdlALC:GoLine(1)
				oMdlALC:ClearData()
				oMdlALC:InitLine()
			EndIf
			oMeter:Set(++nCount)
			oMeter:Refresh()
		Next nX

		For nX := 1 To LEN(aAlocRES)
			If VALTYPE(aAlocRES[nX]) == 'O'
				aAlocRES[nX]:destroy()
				aAlocRES[nX] := nil
			EndIf
		Next nX
		aAlocRES := {}
	EndIf
Else
	MsgAlert(STR0066) //"Operação Cancelada"
EndIf

oDlg:End()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190KOrcam
@description Verifica se é um Orcamento Reserva Reciclagem válido
@return lRet
@author flavio.vicco
@since	12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function At190KOrcam(cModel,cFilOrcam,cCampo)
Local lRet		:= .T.
Local oModel 	:= FwModelActive()
Local oMdlPosto := oModel:GetModel(cModel)
Local cFilBusc	:= Iif(TecMultFil(),oMdlPosto:GetValue(cFilOrcam),cFilAnt)
Local cOrcam	:= oMdlPosto:GetValue(cCampo)
Local cQry		:= ""

cQry := " SELECT TFJ_FILIAL, TFJ_CODIGO , TFJ_CODENT, TFJ_LOJA, TFJ_TREINA "
cQry += " FROM " + RetSqlName("TFJ") + " TFJ "
cQry += " WHERE TFJ.TFJ_FILIAL = '" +  cFilBusc + "' AND TFJ.TFJ_CODIGO = '" + cOrcam + "' "
cQry += " AND TFJ.TFJ_TREINA= '1' AND TFJ.TFJ_RESTEC = '1' AND TFJ.D_E_L_E_T_ = ' ' "
If (QryEOF(cQry))
	lRet := .F.
EndIf

Return lRet 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190KPosto
@description Verifica se é um Posto válido
@return lRet
@author flavio.vicco
@since  12/02/2024
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At190KPosto(cModel,cFilPosto,cCampo)
Local lRet 			:= .T.
Local cQueryTFF		:= GetNextAlias()
Local oModel 		:= FwModelActive()
Local oMdlPosto 	:= oModel:GetModel(cModel)
Local cFilBusc		:= Iif(TecMultFil(),oMdlPosto:GetValue(cFilPosto),cFilAnt)
Local cPosto		:= oMdlPosto:GetValue(cCampo)

If TecBHasGvg()
	BeginSql Alias cQueryTFF
		SELECT TFF.TFF_COD
			FROM %Table:TFF% TFF
			WHERE TFF.TFF_FILIAL = %exp:cFilBusc%
				AND TFF.TFF_COD = %exp:cPosto%
				AND TFF.TFF_GERVAG = '2'
				AND TFF.%NotDel%
	EndSql
	If (cQueryTFF)->(!EOF())
		lRet := .F.
		oModel:GetModel():SetErrorMessage(oModel:GetId(),STR0012,oModel:GetModel():GetId(),STR0012,STR0012,;
		STR0067, STR0068) //"Posto"###"Não é possivel selecionar Postos que não geram vaga operacional"###"Selecione outro posto"
	Endif
	(cQueryTFF)->(DbCloseArea())
EndIf	

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} QryEOF()
Executa uma qry e retorna se EOF
@author flavio.vicco
@since  12/02/2024
/*/
//------------------------------------------------------------------------------
Static Function QryEOF(cSql, lChangeQry)
Local lRet := .F.
Local cAliasQry := GetNextAlias()

Default lChangeQry := .T.
If lChangeQry
	cSql := ChangeQuery(cSql)
EndIf
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
lRet := (cAliasQry)->(EOF())
(cAliasQry)->(DbCloseArea())

Return lRet
