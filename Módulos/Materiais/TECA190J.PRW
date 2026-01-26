#INCLUDE "TOTVS.CH"
#INCLUDE "TECA190J.CH"
#INCLUDE "FWMVCDEF.CH"

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

Static cRetResT     := ""
Static aAlocRES 	:= {}

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190J

@description Funcao complementar Mesa operacional TECA190D

@author	Vitor kwon
@since	01/11/2022
/*/
//------------------------------------------------------------------------------

Function TECA190J(cTipo)

Local  nAux 		:= 0
Local  aRet		:= {}
Local  nC  := 0
local  lPermLim := .F.
Local lMV_MultFil := TecMultFil()

If cTipo == "RTE"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0001	//"Agenda"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0001		//"Agenda"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_SITABB"
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
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0002	//"Status"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0002	//"Status"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_SITALO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
    aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERDE"}
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .T. )  //"Grupo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .F. ) //"Grupo"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_GRUPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@E 999"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0003}	//"Preencher com grupo do atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )  //"Código do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. )  //"Código do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0004}	//"Código do Atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )  //"Nome do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. )  //"Nome do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0005}	//"Nome do Atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0006	//"Dt. Referência"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0006	//"Dt. Referência"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_DATREF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0007}	//"Data da alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0008	//"Data"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0008	//"Data"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_DATA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0007}	//"Data da alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0009	//"Dia da Semana"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0009	//"Dia da Semana"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_SEMANA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 15
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0009}	//"Dia da semana."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0010	//"Hora de Entrada"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0010	//"Hora de Entrada"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_ENTRADA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0010}	//"Hora de Entrada"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0011	//"Hora de Saída"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0011	//"Hora de Saída"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_SAIDA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0011}	//"Hora de Saída"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0012	//"Sequencia"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0012	//"Sequencia"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 2
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_HELP] := {STR0013}	//"Preencher com Sequencia do Turno."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014//"Tipo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014	//"Tipo"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_TIPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LISTA_VAL] := { "S="+STR0015, "C="+STR0016, "D="+STR0017, "E="+STR0018,"I="+STR0019,"N="+STR0020} //"S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado"
	aRet[nAux][DEF_COMBO_VAL] := { "S="+STR0015, "C="+STR0016, "D="+STR0017, "E="+STR0018,"I="+STR0019,"N="+STR0020} //"S=Trabalhado;C=Compensado;D=D.S.R.;E=Hora Extra;I=Intervalo;N=Nao Trabalhado"
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0021}	//"Tipo de dia: Trabalhado, não trabalhado, folga ou DSR."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0022
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0022
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_KEYTGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ESCALA")[1] + TamSX3("TGY_CODTDX")[1] + TamSX3("TGY_CODTFF")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "13"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0023 //"ItemTGY"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0023 //"ItemTGY"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_ITTGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_ITEM")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "14"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0024
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0024
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_EXSABB"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "15"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0025	//"Turno"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0025	//"Turno"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_TURNO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_TURNO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "16"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0026}	//"Preencher com o Código do Turno."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0027 //"Item"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0027 //"Item"
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_ITEM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 6
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "17"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0028
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0028
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_DSCONF"
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

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := 'Tipo Movi'
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := 'Tipo Movi'
	aRet[nAux][DEF_IDENTIFICADOR] := "RTE_TIPTCU"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 35
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "19"
	aRet[nAux][DEF_CAN_CHANGE] := .F.

 Elseif cTipo == "GRE"

 	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0002 //"Status"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0002 //"Status"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_STATUS"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "BT"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "BT"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190JGRE()}
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| "BR_VERMELHO"}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0014 //"Tipo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0014 //"Tipo"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_TIPOAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| 1}
	aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0118/*, "2=Cobertura"*/} //TODO Cobertura
	aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0118/*, "2=Cobertura"*/} //TODO Cobertura
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0067} //"Indica o tipo de alocação: 1= Efetivo tabela TGY ou 2=Cobertura, TGX"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .T. )  //"Codigo do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_CODTEC", .F. ) //"Codigo do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_CODTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_CODTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
    aRet[nAux][DEF_LOOKUP] := "T19AA1"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0068}	//"Código do atendente cadastrado no 'Gestão de Serviços'"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .T. )  //"Nome do Atendente"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "AA1_NOMTEC", .F. )  //"Nome do Atendente"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_NOMTEC"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("AA1_NOMTEC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0069}	//"Nome do Atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0029	//"Alocação de?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0029	//"Alocação de?"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_DTINI"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0030}	//"Inicio do periodo de Alocação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0031	//"Alocação até?"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0031 //"Alocação até?"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_DTFIM"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "D"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "D"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 8
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "06"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0032}	//"Fim do periodo de alocação"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_FILIAL", .T. )  //"Numero do Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_FILIAL", .F. ) //"Numero do Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_FILIAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "07"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "SM0"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
	aRet[nAux][DEF_HELP] := {STR0033} //"Filial utilizada para alocar o atendente"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0034 //"Descrição da Filial"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0034 //"Descrição da Filial"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_DSCFIL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := LEN(FWFilialName())
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "08"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| Alltrim(FWFilialName(,cFilAnt))}
	aRet[nAux][DEF_CAN_CHANGE] := .F.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0073  //Orçamento
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0073 //Orçamento
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_CONTRT"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("CN9_NUMERO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "09"
	aRet[nAux][DEF_PICTURE] := "@!"
    aRet[nAux][DEF_LOOKUP] := "CONSR1"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0035}	//"Número do contrato."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0036	//"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0036	//"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_CODTFL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "10"
	aRet[nAux][DEF_PICTURE] := "@!"
    aRet[nAux][DEF_LOOKUP] := "CONSR5"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0037}	//"Código do Local de Atendimento."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0038	//"Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0038	//"Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_CODTFF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dPosto("RESDETAIL","GRE_FILIAL","GRE_CODTFF")}
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "11"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CONSR7"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0039}	//"Código de recursos humanos."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .T. )  //"Código da Escala"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_ESCALA", .F. ) //"Código da Escala"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_ESCALA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_ESCALA")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "12"
	aRet[nAux][DEF_PICTURE] := "@!"
	If !lMV_MultFil
		aRet[nAux][DEF_LOOKUP] := "TDW"
	Else
		aRet[nAux][DEF_LOOKUP] := "T19ESY"
	EndIf
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0040}	//"Preencher com Código da Escala."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TDW_DESC", .T. )
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TDW_DESC", .F. )
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_DSCTDW"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDW_DESC")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "13"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0041}//"Descrição da Escala"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0042	//"Seq. Inicial"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0042	//"Seq. Inicial"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_SEQ"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_SEQ")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "14"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
    aRet[nAux][DEF_LOOKUP] := 'T19RE1'
	aRet[nAux][DEF_HELP] := {STR0043}	//"Preencher com Sequencia do Turno."

    If TFF->( ColumnPos('TFF_REGRA') ) > 0
		lPermLim := At680Perm( Nil, __cUserID, "069" )
        AADD(aRet, ARRAY(QUANTIDADE_DEFS))
        nAux := LEN(aRet)
        aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TFF_REGRA", .T. )
        aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TFF_REGRA", .F. )
        aRet[nAux][DEF_IDENTIFICADOR] := "GRE_REGRA"
        aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
        aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
        aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_REGRA")[1]
        aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
        aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| lPermLim }
        aRet[nAux][DEF_CODEBLOCK_VALID] := {|| .T.}
        aRet[nAux][DEF_OBRIGAT] := .F.
        aRet[nAux][DEF_RECEBE_VAL] := .T.
        aRet[nAux][DEF_VIRTUAL] := .T.
        aRet[nAux][DEF_ORDEM] := "15"
        aRet[nAux][DEF_PICTURE] := "99"
        aRet[nAux][DEF_LOOKUP] := "SPA"
        aRet[nAux][DEF_CAN_CHANGE] := .T.
        aRet[nAux][DEF_HELP] := {STR0045} //"Informe a Regra de Apontamento"
    EndIf

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_TIPALO", .T. )  //"Tipo Movimentação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_TIPALO", .F. ) //"Tipo Movimentação"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_TIPTCU"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TIPALO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "16"
	aRet[nAux][DEF_PICTURE] := "@!"
	If !lMV_MultFil
		aRet[nAux][DEF_LOOKUP] := "CONSR2"
	Else
		aRet[nAux][DEF_LOOKUP] := "CONSR2"
	EndIf
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0046}	//"Informe o tipo de movimentação."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .T. )  //"Grupo"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "TGY_GRUPO", .F. ) //"Grupo"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_GRUPO"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_GRUPO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "17"
	aRet[nAux][DEF_PICTURE] := "@E 999"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
    aRet[nAux][DEF_LOOKUP] := "T19LGR"
	aRet[nAux][DEF_CODEBLOCK_INIT] := {||1}
	aRet[nAux][DEF_HELP] := {STR0047}	//"Preencher com grupo do atendente."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := "RECNO"	//"RECNO"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := "RECNO"	//"RECNO"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_RECLGY"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "N"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "N"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 16
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.F.}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "18"
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0048 //"Configuração de Alocação"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0048 //"Configuração de Alocação"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_CONFAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TDX_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .T.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "19"
	aRet[nAux][DEF_PICTURE] := "@!"
   	aRet[nAux][DEF_LOOKUP] := "CONSR3"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0049} //"Configuração de Tabela de Horário e Sequência para efetivos ou do tipo de Cobertura"

	cOrdem := "19"

	For nC := 1 to 4
		cOrdem := Soma1(cOrdem)
		cCampoE := "GRE_ENTRA" + Str(nC,1)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0050 + Str(nC,1)	//"Hora Ini "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0051 + Str(nC,1)	//"Horário de Entrada "
		aRet[nAux][DEF_IDENTIFICADOR] := cCampoE
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0051}

		cCampoS := "GRE_SAIDA" + Str(nC,1)
		cOrdem := Soma1(cOrdem)
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] :=  STR0052 + Str(nC,1)	//"Hora Fim "
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0053 + Str(nC,1)	//"Horário de Saída "
		aRet[nAux][DEF_IDENTIFICADOR] := cCampoS
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 5
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_OBRIGAT] := .F.
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := cOrdem
		aRet[nAux][DEF_PICTURE] := "99:99"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_HELP] := {STR0053}
	Next nC

    If TGY->( ColumnPos("TGY_PROXFE")) > 0
		AADD(aRet, ARRAY(QUANTIDADE_DEFS))
		nAux := LEN(aRet)
		aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0054
		aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0054
		aRet[nAux][DEF_IDENTIFICADOR] := "GREY_PROXFE"
		aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
		aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
		aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 1
		aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
		aRet[nAux][DEF_CODEBLOCK_WHEN] := {||.T.}
		aRet[nAux][DEF_RECEBE_VAL] := .T.
		aRet[nAux][DEF_VIRTUAL] := .T.
		aRet[nAux][DEF_ORDEM] := "28"
		aRet[nAux][DEF_PICTURE] := "9"
		aRet[nAux][DEF_CAN_CHANGE] := .T.
		aRet[nAux][DEF_LISTA_VAL] := { "1="+STR0055, "2="+STR0056, "3="+STR0057}
		aRet[nAux][DEF_COMBO_VAL] := { "1="+STR0055, "2="+STR0056, "3="+STR0057}
		aRet[nAux][DEF_CODEBLOCK_INIT] := {||'3'}
    Endif

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0058 //"Detalhes"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0058 //"Detalhes"
	aRet[nAux][DEF_IDENTIFICADOR] := "GRE_DETALH"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 185
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .F. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "29"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_CAN_CHANGE] := .F.
	aRet[nAux][DEF_HELP] := {STR0059} //"Detalhes da alocação"

Elseif cTipo == "RES"

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := TecTituDes( "CN9_FILIAL", .T. )  //"Numero do Contrato"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := TecTituDes( "CN9_FILIAL", .F. ) //"Numero do Contrato"
	aRet[nAux][DEF_IDENTIFICADOR] := "RES_FILIAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := Len(cFilAnt)
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "01"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "SM0"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_CODEBLOCK_INIT] := {|| cFilAnt}
	aRet[nAux][DEF_HELP] := {STR0060} //"Filial utilizada para buscar o contrato"

    AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0061		//"Orçamento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0061		//"Orçamento"
	aRet[nAux][DEF_IDENTIFICADOR] := "RES_ORCA"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := 11
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_LOOKUP] := "CONSR1"
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "02"
	aRet[nAux][DEF_PICTURE] := ""
	aRet[nAux][DEF_CAN_CHANGE] := .T.

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0036	//"Local de Atendimento"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0036	//"Local de Atendimento"
	aRet[nAux][DEF_IDENTIFICADOR] := "RES_LOCAL"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFL_LOCAL")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "03"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CONSR4"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0062}	//"Código do Local de Atendimento."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO]  := STR0038	//"Posto"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0038	//"Posto"
	aRet[nAux][DEF_IDENTIFICADOR] := "RES_CODTFF"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TFF_COD")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_CODEBLOCK_VALID] := {||At190dPosto("RESMASTER","RES_FILIAL","RES_CODTFF")}
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "04"
	aRet[nAux][DEF_PICTURE] := "@!"
	aRet[nAux][DEF_LOOKUP] := "CONSR6"
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0063}	//"Código de recursos humanos."

	AADD(aRet, ARRAY(QUANTIDADE_DEFS))
	nAux := LEN(aRet)
	aRet[nAux][DEF_TITULO_DO_CAMPO] := STR0064	//"Tp.Movim"
	aRet[nAux][DEF_TOOLTIP_DO_CAMPO] := STR0064	//"Tp.Movim"
	aRet[nAux][DEF_IDENTIFICADOR] := "RES_TIPMOV"
	aRet[nAux][DEF_TIPO_DO_CAMPO] := "C"
	aRet[nAux][DEF_TIPO_CAMPO_VIEW] := "C"
	aRet[nAux][DEF_TAMANHO_DO_CAMPO] := TamSX3("TGY_TIPALO")[1]
	aRet[nAux][DEF_DECIMAL_DO_CAMPO] := 0
	aRet[nAux][DEF_CODEBLOCK_WHEN] := {|| .T. }
	aRet[nAux][DEF_OBRIGAT] := .F.
	aRet[nAux][DEF_RECEBE_VAL] := .T.
	aRet[nAux][DEF_VIRTUAL] := .T.
	aRet[nAux][DEF_ORDEM] := "05"
	aRet[nAux][DEF_PICTURE] := "@!"
	If !lMV_MultFil
		aRet[nAux][DEF_LOOKUP] := "CONSR2"
	Else
		aRet[nAux][DEF_LOOKUP] := "CONSR2"
	EndIf
	aRet[nAux][DEF_CAN_CHANGE] := .T.
	aRet[nAux][DEF_HELP] := {STR0065} //"Busca apenas atendentes com o Tipo de Movimentação informado neste campo (TGY_TIPALO = LCA_TIPTCU)"

 Endif

Return aRet


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConsRES

@description Retorno da Consulta Especifica da Reserva Técnica
@author Vitor kwon
@since  01/11/2022
/*/
//--------------------------------------------------------------------------------
Function ConsRES(cTipo,cItem,cContrato,cEntOri,cOrigem,cEntDest,cDestino,lNew)
Local aArea       := GetArea()
Local aIndex      := {}
Local aSeek       := {}
Local cAls        := "TECRES"
Local cCodSub     := ""
Local cCodTFL     := ""
Local cCodUser    := PswRet(1)[1,1]
Local cCond       := "1"
Local cDest       := ""
Local cItMun      := ""
Local cQry        := ""
Local cRevCtr     := ""
Local cTcuRes     := "1"
Local cTitle      := STR0070
Local lArmMultFil := TecMtFlArm()
Local lExstRev    := TFQ->(ColumnPos("TFQ_CONREV")) > 0
Local lGsOrcArma  := FindFunction("TecGsArma") .And. TecGsArma()
Local lMovInterna := Empty(FwFldGet("TFQ_CONTRT"))
Local lMV_MultFil := TecMultFil() //Indica se a Mesa considera multiplas filiais
Local lOK         := .T.
Local nDireita    := 0
Local nEsquerda   := 0
Local nInferior   := 0
Local nSuperior   := 0
local oBrowse     := Nil
local oColumn     := nil
Local oModel      := FwModelActive()
Local cExecView   := oModel:GetId()

Default cContrato := ""
Default cDestino  := ""
Default cEntDest  := ""
Default cEntOri   := ""
Default cItem	  := ""
Default cOrigem   := ""
Default cTipo     := ""
Default lNew      := .F.

	IF cTipo == "LOCAL"

	    cTitle := STR0070 //"Configuração de Alocação"

	    cAls := cTipo

		Aadd( aSeek, { STR0036,  {{"","C",6   ,0,STR0036,,"RES_LOCAL"}}})   //"Local"

		cQry := " SELECT  TFL_CODIGO,TFL_LOCAL, TFL_CODPAI, ABS_DESCRI"
		cQry += " FROM " + RetSqlName("TFL") + " TFL "
		cQry += " INNER JOIN "+RetSqlName("ABS")+" ABS ON ABS_LOCAL = TFL_LOCAL AND ABS_FILIAL = '"+xFilial("ABS")+"'"
		cQry += " WHERE TFL.D_E_L_E_T_ = ' ' AND TFL_FILIAL = '"+xFilial("TFL")+"'"
		IF cItem == "C"
			iF Empty(FwFldGet("RES_ORCA"))
				If cExecView == "TECA190K"
					cQry += " AND TFL_CODPAI = '"+FwFldGet("TGY_CODIGO")+" ' AND ABS.D_E_L_E_T_ = ' ' "
				Else
					cQry += " AND TFL_CODPAI != ' ' AND ABS.D_E_L_E_T_ = ' ' "
				EndIf
			ElseIf !Empty(FwFldGet("RES_ORCA"))
				cQry += " AND TFL_CODPAI = '"+FwFldGet("RES_ORCA")+"' AND ABS.D_E_L_E_T_ = ' ' "
			Endif
		elseif cItem == "G"
			iF Empty(FwFldGet("GRE_CONTRT"))
				cQry += " AND TFL_CODPAI != ' ' AND ABS.D_E_L_E_T_ = ' ' "
			ElseIf !Empty(FwFldGet("GRE_CONTRT"))
				cQry += " AND TFL_CODPAI = '"+FwFldGet("GRE_CONTRT")+"' AND ABS.D_E_L_E_T_ = ' ' "
			Endif
		Endif
		cQry += " ORDER BY TFL_LOCAL

	Elseif cTipo $ "|ORCA|"

		cTitle := STR0073 // Orçamento

		Aadd( aSeek, { STR0044,{{"","C",TamSX3("TFJ_CODIGO")[1]  ,0, STR0044,,"TFJ_CODIGO"}}})
		Aadd( aSeek, { "Nome Cliente", {{"","C",TamSX3("A1_NOME")[1],0,"Nome Cliente",,"A1_NOME"}} } ) //"Nome"

		Aadd( aIndex, "TFJ_CODIGO" )
		Aadd( aIndex, "A1_NOME" )

		cQry := " SELECT TFJ_FILIAL, TFJ_CODIGO , TFJ_CODENT, TFJ_LOJA, A1_NOME  "
		cQry += " FROM " + RetSqlName("TFJ") + " TFJ "
		cQry += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
		If !lMV_MultFil
			cQry += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		Else
			cQry += " ON " + FWJoinFilial("SA1" , "TFJ" , "SA1", "TFJ", .T.) + " "
		EndIf
		cQry += " AND SA1.D_E_L_E_T_ = ' ' "
		cQry += " AND SA1.A1_COD = TFJ.TFJ_CODENT "
		cQry += " AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
		cQry += " WHERE TFJ.D_E_L_E_T_ = ' ' "
		cQry += " AND TFJ_FILIAL = '"+xFilial("TFJ")+"'"
		cQry += " AND TFJ_RESTEC = '"+cCond+"' "
		If TFJ->(ColumnPos("TFJ_TREINA"))>0
			If cExecView == "TECA190K"
				cQry += " AND TFJ_TREINA = '1' "
			Else
				cQry += " AND TFJ_TREINA <> '1' "
			EndIf
		EndIf

	Elseif cTipo $ "|POSTO|"

		cTitle := STR0038 //"Posto"

		Aadd( aSeek, { "Posto",{{"","C",TamSX3("TFF_COD")[1]  ,0, "Posto",,"TFF_COD"}}})
		Aadd( aSeek, { "Local de Atendimento", {{"","C",TamSX3("ABS_DESCRI")[1],0,"Local de Atendimento",,"ABS_DESCRI"}} } )	//"Descrição do Posto" # "Descrição do Posto"

		Aadd( aIndex, "TFF_CODs" )
		Aadd( aIndex, "ABS_DESCRI" )

		cQry := " SELECT TFF_COD , TFF_PRODUT, TFF_LOCAL, TFL_CODPAI, B1_DESC, ABS_DESCRI, TFF_PERINI, TFF_PERFIM, TFF_QTDVEN, TFF_FUNCAO, TFF_TURNO, TFF_ESCALA, TFF_FILIAL,TFF_CODPAI, "
		cQry += " CASE WHEN RJ_DESC IS NOT NULL THEN RJ_DESC ELSE ' ' END RJ_DESC, "
		cQry += " CASE WHEN R6_DESC IS NOT NULL THEN R6_DESC ELSE ' ' END R6_DESC, "
		cQry += " CASE WHEN TDW_DESC IS NOT NULL THEN TDW_DESC ELSE ' ' END TDW_DESC "
		cQry += " FROM " + RetSqlName("TFF") + " TFF "
		cQry += " INNER JOIN "+RetSqlname("TFL")+" TFL ON TFL_CODIGO = TFF_CODPAI AND TFL_FILIAL = '"+xFilial("TFL")+"'"
		cQry += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON TFL.TFL_LOCAL = ABS.ABS_LOCAL AND "
		If !lMV_MultFil
			cQry += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
		Else
			cQry += " " + FWJoinFilial("ABS" , "TFL" , "ABS", "TFL", .T.) + " "
		EndIf
		cQry += " INNER JOIN "+RetSqlname("SB1")+" B1  ON B1_COD = TFF_PRODUT AND B1_FILIAL = '"+xFilial("SB1")+"'"
		cQry += " LEFT JOIN " + RetSqlName( "SRJ" ) + " SRJ "
		If !lMV_MultFil
			cQry += " ON SRJ.RJ_FILIAL = '" + xFilial("SRJ") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "SRJ" , "TFF", "SRJ", .T.) + " "
		EndIf
		cQry += " AND SRJ.D_E_L_E_T_ = ' ' "
		cQry += " AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
		cQry += " LEFT JOIN " + RetSqlName( "SR6" ) + " SR6 "
		If !lMV_MultFil
			cQry += " ON SR6.R6_FILIAL = '" + xFilial("SR6") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "SR6" , "TFF", "SR6", .T.) + " "
		EndIf
		cQry += " AND SR6.D_E_L_E_T_ = ' ' "
		cQry += " AND SR6.R6_TURNO = TFF.TFF_TURNO " 
		cQry += " LEFT JOIN " + RetSqlName( "TDW" ) + " TDW "
		If !lMV_MultFil
			cQry += " ON TDW.TDW_FILIAL = '" + xFilial("TDW") + "' "
		Else
			cQry += " ON " + FWJoinFilial("TFF" , "TDW" , "TFF", "TDW", .T.) + " "
		EndIf
		cQry += " AND TDW.D_E_L_E_T_ = ' ' "
		cQry += " AND TDW.TDW_COD = TFF.TFF_ESCALA "   
		cQry += " WHERE TFF.D_E_L_E_T_ = ' ' AND TFL.D_E_L_E_T_ = ' ' AND TFF_FILIAL = '"+xFilial("TFF")+"' AND B1.D_E_L_E_T_ = ' ' "
		cQry += " AND ABS.D_E_L_E_T_ = ' ' "

		IF cItem == "G"
			IF Empty(FwFldGet("GRE_CONTRT"))
				cQry += " AND TFL_CODPAI != ' ' "
			ElseIf !Empty(FwFldGet("GRE_CONTRT"))
				cQry += " AND TFL_CODPAI = '"+FwFldGet("GRE_CONTRT")+"'"
			Endif
		ElseIF cItem == "C"
			If cExecView == "TECA190K"
				cQry += " AND TFL_CODPAI = '"+FwFldGet("TGY_CODIGO")+"'"
			Else
				IF Empty(FwFldGet("RES_ORCA"))
					cQry += " AND TFL_CODPAI != ' ' "
				ElseIf !Empty(FwFldGet("RES_ORCA"))
					cQry += " AND TFL_CODPAI = '"+FwFldGet("RES_ORCA")+"'"
				Endif
			Endif
		Else
			If FwFldGet("TFQ_ENTORI") == '2'
				cQry += " AND TFF_LOCAL = '" + FwFldGet("TFQ_ORIGEM") + "'"
			ElseIf FwFldGet("TFQ_ENTDES") == '1'
				cQry += " AND TFF_LOCAL = '" + FwFldGet("TFQ_DESTIN") + "'"
			EndIf
	   		cQry += " AND TFF_CONTRT = '" + FwFldGet("TFQ_CONTRT") + "'"
			If lExstRev
	   			cQry += " AND TFF_CONREV = '" + FwFldGet("TFQ_CONREV") + "'"
			endIf
		Endif

		cQry += " ORDER BY TFF_COD"

	Elseif cTipo $ "|TIPO|"

		cTitle := STR0014

		Aadd( aSeek, { "Tipo",{{"","C",TamSX3("TCU_COD")[1]  ,0, "Tipo",,}}})

		cQry := " SELECT TCU.TCU_FILIAL, TCU.TCU_COD, TCU.TCU_DESC, TCU.TCU_RESTEC "
		cQry += " FROM " + RetSqlName("TCU") + " TCU "
		cQry += " WHERE TCU.D_E_L_E_T_ = ' ' AND TCU_FILIAL = '"+xFilial("TCU")+"'"
		cQry += " AND TCU_RESTEC = '"+cTcuRes+"'"
		cQry += " ORDER BY TCU_COD "

	Elseif cTipo $ "|CONFAL|"

		cTitle := STR0074 // "Configuração de Alocação"

		Aadd( aSeek, { "Turno", {{"","C",TamSX3("TDX_TURNO")[1],0,"Turno",,"TDX_TURNO"}} } ) //"Turno"
		Aadd( aSeek, { "Descrição", {{"","C",TamSX3("R6_DESC")[1],0,"Descrição",,"R6_DESC"}} } ) //"Descrição"

		Aadd( aIndex, "TDX_TURNO" )
		Aadd( aIndex, "R6_DESC" )
		Aadd( aIndex, "TDX_FILIAL")

		cQry := " SELECT TDX.TDX_COD COD, TDX.TDX_TURNO TURNO, TDX.TDX_SEQTUR, SR6.R6_DESC, TDX.TDX_FILIAL "
		cQry += " FROM " + RetSqlName("TDX") + " TDX "
		cQry += " INNER JOIN " + RetSqlName("SR6") + " SR6 ON "
		cQry += " SR6.R6_TURNO = TDX.TDX_TURNO AND "
		cQry += " SR6.R6_FILIAL = '" + xFilial("SR6") + "' AND "
		cQry += " SR6.D_E_L_E_T_ = ' ' "
		cQry += " WHERE TDX.TDX_FILIAL = '" + xFilial("TDX") + "' AND "
		cQry += " TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_CODTDW = '" + FwFldGet("GRE_ESCALA") + "' "

	Elseif lGsOrcArma .And. cTipo $ "|LOCTXQ|"

		cTitle := STR0036  //  Local de Atendimento

		Aadd( aSeek, { STR0143, {{"","C",TamSX3("TFL_LOCAL")[1],0 ,STR0143,,"TFL_LOCAL"}} } ) //"Local"
		Aadd( aSeek, { STR0079, {{"","C",TamSX3("ABS_DESCRI")[1],0,STR0079,,"ABS_DESCRI"}} } ) //"Descrição"

		cRevCtr := Posicione("CN9",7,xFilial("CN9")+cContrato+"05","CN9_REVISA")

		cQry := " SELECT DISTINCT TFL_LOCAL,ABS_DESCRI,TFL_CODIGO "
		cQry += " FROM " + RetSqlName("TFF") + " TFF "
		cQry += " INNER JOIN " + RetSqlName("TFJ") + " TFJ ON TFJ.TFJ_FILIAL = '"+xFilial("TFJ")+"' AND TFJ.TFJ_CONTRT = '"+cContrato+"' AND TFJ.TFJ_STATUS='1' AND TFJ.D_E_L_E_T_ = ' '
		cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL ON TFL.TFL_FILIAL = '"+xFilial("TFL")+"' AND TFL.TFL_CODIGO = TFF.TFF_CODPAI AND TFL.D_E_L_E_T_ = ' ' "
		cQry += " INNER JOIN " + RetSqlName("ABS") + " ABS ON ABS.ABS_FILIAL = '"+xFilial("ABS")+"' AND ABS.ABS_LOCAL  = TFL.TFL_LOCAL  AND ABS.D_E_L_E_T_ = ' ' "
		cQry += " INNER JOIN " + RetSqlName("TXQ") + " TXQ ON TXQ.TXQ_FILIAL = '"+xFilial("TXQ")+"' AND TXQ.TXQ_CODTFF = TFF.TFF_COD    AND TXQ.D_E_L_E_T_ = ' ' "
		cQry += " WHERE TFF.TFF_FILIAL = '" + xFilial("TFF")+"'"
		cQry += " AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
		If FwFldGet("TFQ_MOTIVO") == '1' .And. FwFldGet("TFQ_STATUS") == '1'
			cQry += " AND TFF.TFF_ENCE <> '1' "
			cQry += " AND '" + DtoS(dDataBase)+"' < TFF.TFF_PERFIM "
		ElseIf FwFldGet("TFQ_MOTIVO") == '5'
			cQry += " AND (TFF.TFF_ENCE <> '1' OR TFF.TFF_ENCE = '1') "
		Else
			cQry += " AND (TFF.TFF_ENCE <> '1' OR (TFF.TFF_ENCE = '1' AND TFF.TFF_DTENCE >= '" + DtoS(dDataBase)+"')) "
			cQry += " AND '" + DtoS(dDataBase)+"' BETWEEN TFF.TFF_PERINI AND TFF.TFF_PERFIM "
		EndIf
		cQry += " AND TFF.D_E_L_E_T_ = ' ' "
		cQry += " ORDER BY TFL_LOCAL "

	Elseif lGsOrcArma .And. cTipo $ "|CONTRATO|"

		cTitle := STR0035 //"Número do contrato."

		Aadd( aSeek, { STR0132, {{"","C",TamSX3("CN9_NUMERO")[1],0,STR0132,,"CN9_NUMERO"}} } ) //"Contrato"

	    cQry := " SELECT DISTINCT TFJ_CONTRT, TFJ_CONREV "
		cQry += " FROM " + RetSqlName("TFJ") + " TFJ "
		cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL ON TFL_CODPAI = TFJ_CODIGO AND TFL_FILIAL = '"+xFilial("TFF")+"' "
		cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF ON TFF_CODPAI = TFL_CODIGO AND TFL_FILIAL = '"+xFilial("TFL")+"' "
		If !At680Perm( Nil, cCodUser, "074" ) // Define regras de restrição
			cQry += " AND TFF_CODSUB = ' ' "
		EndIf
		cQry += " INNER JOIN " + RetSqlName("TXQ") + " TXQ ON TXQ_CODTFF = TFF_COD    AND TXQ_FILIAL = '"+xFilial("TXQ")+"' "
		cQry += " INNER JOIN " + RetSqlName("CN9") + " CN9 ON CN9.CN9_FILIAL = '" + xFilial("CN9") + "' AND CN9.CN9_NUMERO = TFF.TFF_CONTRT AND CN9.CN9_REVISA = TFF.TFF_CONREV AND CN9.CN9_SITUAC = '05' AND CN9.D_E_L_E_T_ = ' ' "
		cQry += " WHERE TFJ.D_E_L_E_T_ = ' ' "
		cQry += " AND TXQ.D_E_L_E_T_ = ' ' "
		cQry += " AND TFF.D_E_L_E_T_ = ' ' "
		cQry += " AND TFF.D_E_L_E_T_ = ' ' "
		cQry += " AND TFJ.TFJ_FILIAL = '"+xFilial("TFJ")+"' "
		cQry += " AND TFF.TFF_CONTRT <> ' ' "
		cQry += " AND TFJ_STATUS = '1' " //1=Ativo
		cQry += " AND (TFF.TFF_ENCE <> '1' OR (TFF.TFF_ENCE = '1' AND TFF.TFF_DTENCE >= '" + DtoS(dDataBase)+"')) "

	ElseIf lGsOrcArma .And. cTipo $ "|ARMA|"

		cTitle := STR0131  //"Armamento x Orçamento"

		Aadd( aSeek, { "Posto",{{"","C",TamSX3("TFF_COD")[1],0,"Posto",,}}})

		cQry := "SELECT DISTINCT TE0_COD, B1_DESC"
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			cQry += ", TXQ_CODIGO, TXQ_ITEARM"
		EndIf
		// Armas
		cQry += " FROM " + RetSqlName("TE0") + " TE0 "
		// Produtos
		cQry += " INNER JOIN " + RetSqlName("SB1") + " B1 "
		cQry +=        "  ON B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry +=        " AND B1_COD = TE0_CODPRO "
		cQry +=        " AND B1.D_E_L_E_T_ = ' ' "
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			// Locais de Atendimento
			cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQry +=        "  ON TFL_FILIAL = '" + xFilial("TFL") + "'"
			cQry +=        " AND TFL_CODIGO = '" + FwFldGet("TFQ_CODTFL")+"' "
			cQry +=        " AND TFL_CONTRT = '" + FwFldGet("TFQ_CONTRT") + "' ""
			If lExstRev
				cQry +=    " AND TFL_CONREV = '" + FwFldGet("TFQ_CONREV") + "' ""
			EndIf
			cQry +=        " AND TFL.D_E_L_E_T_ = ' ' "
			// Postos de Trabalho
			cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQry +=        "  ON TFF_FILIAL = '" + xFilial("TFF") + "' "
			cQry +=        " AND TFF_CODPAI = TFL_CODIGO "
			cQry +=        " AND TFF_CONTRT = TFL_CONTRT "
			cQry +=        " AND TFF_CONREV = TFL_CONREV "
			cQry +=        " AND TFF.D_E_L_E_T_ = ' ' "
			// Armamentos - Armas
			cCodSub := Space( FWSX3Util():GetFieldStruct( "TXQ_CODSUB" )[3] )
			cQry += " INNER JOIN " + RetSqlName("TXQ") + " TXQ "
			cQry +=        "  ON TXQ_FILIAL = '" + xFilial("TXQ") + "' "
			cQry +=        " AND TXQ_CODTFF = TFF_COD"
			cQry +=        " AND TXQ_CODPRD = TE0_CODPRO "
			cQry +=        " AND TXQ_ITEARM = '1' " // 1 = Armas
			cQry +=        " AND TXQ_CODSUB = '" + cCodSub + "' "
			cQry +=        " AND TXQ.D_E_L_E_T_ = ' ' "
			If  cEntOri == "2" .And. cEntDest ==  "2"
				// Itens de Movimentação
				cQry += " INNER JOIN " + RetSqlName("TFO") + " TFO "
				cQry +=        "  ON TFO_FILIAL = '"+xFilial("TFO")+"' "
				cQry +=        " AND TFO_ITCOD = TE0_COD "
				cQry +=        " AND TFO.D_E_L_E_T_ = ' '"
			EndIf
		EndIf
		// Armas (Where)
		cQry +=   " WHERE TE0.D_E_L_E_T_ = ' '"
		cQry +=     " AND TE0_FILIAL  = '"+xFilial("TE0")+"' "
		If cEntOri == "1"
			cQry += " AND TE0_LOCAL = '" + cOrigem + "'"
			cQry += " AND TE0_SITUA = '1' " //1=Ativa
			cQry += " AND TE0_ENTIDA = 'TER'" 
		ElseIf cEntOri == "2"
			cQry += " AND TE0_SITUA = '2' " // 2=Implantada
			cQry += " AND TE0_ENTIDA = 'ABS' "
		EndIf
		// Ordem por Codigo do Colete
		cQry += " ORDER BY TE0_COD"
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			cQry += ", TXQ_CODIGO"
		EndIf

	ElseIf lGsOrcArma .And. cTipo $ "|COLETE|"

		cQry := "SELECT DISTINCT TE1_CODCOL, B1_DESC"
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			cQry += ", TXQ_CODIGO, TXQ_ITEARM"
		EndIf
		// Coletes
		cQry += " FROM " + RetSqlName("TE1") + " TE1 "
		// Produtos
		cQry += " INNER JOIN " + RetSqlName("SB1") + " B1 "
		cQry +=        "  ON B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry +=        " AND B1_COD = TE1_CODPRO "
		cQry +=        " AND B1.D_E_L_E_T_ = ' ' "
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			// Locais de Atendimento
			cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQry +=        "  ON TFL_FILIAL = '" + xFilial("TFL") + "'"
			cQry +=        " AND TFL_CODIGO = '" + FwFldGet("TFQ_CODTFL")+"' "
			cQry +=        " AND TFL_CONTRT = '" + FwFldGet("TFQ_CONTRT") + "' ""
			If lExstRev
				cQry +=    " AND TFL_CONREV = '" + FwFldGet("TFQ_CONREV") + "' ""
			EndIf
			cQry +=        " AND TFL.D_E_L_E_T_ = ' ' "
			// Postos de Trabalho
			cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQry +=        "  ON TFF_FILIAL = '" + xFilial("TFF") + "' "
			cQry +=        " AND TFF_CODPAI = TFL_CODIGO "
			cQry +=        " AND TFF_CONTRT = TFL_CONTRT "
			cQry +=        " AND TFF_CONREV = TFL_CONREV "
			cQry +=        " AND TFF.D_E_L_E_T_ = ' ' "
			// Armamentos - Coletes
			cCodSub := Space( FWSX3Util():GetFieldStruct( "TXQ_CODSUB" )[3] )
			cQry += " INNER JOIN " + RetSqlName("TXQ") + " TXQ "
			cQry +=        "  ON TXQ_FILIAL = '" + xFilial("TXQ") + "' "
			cQry +=        " AND TXQ_CODTFF = TFF_COD"
			cQry +=        " AND TXQ_CODPRD = TE1_CODPRO "
			cQry +=        " AND TXQ_ITEARM = '2' " // 2 = Colete
			cQry +=        " AND TXQ_CODSUB = '" + cCodSub + "' "
			cQry +=        " AND TXQ.D_E_L_E_T_ = ' ' "
			If cEntOri == "2" .And. cEntDest ==  "2"
				// Itens de Movimentação
				cQry += " INNER JOIN " + RetSqlName("TFO") + " TFO "
				cQry +=        "  ON TFO_FILIAL = '"+xFilial("TFO")+"' "
				cQry +=        " AND TFO_ITCOD = TE1_CODCOL "
				cQry +=        " AND TFO.D_E_L_E_T_ = ' '"
			EndIf
		EndIf
		// Coletes (Where)
		cQry +=   " WHERE TE1.D_E_L_E_T_ = ' '"
		cQry +=     " AND TE1_FILIAL  = '"+xFilial("TE1")+"' "
		If cEntOri == "1"
			cQry += " AND TE1_LOCAL = '" + cOrigem + "'"
			cQry += " AND TE1_SITUA = '1' " //1=Ativa
			cQry += " AND TE1_ENTIDA = 'TER'" 
		ElseIf cEntOri == "2"
			cQry += " AND TE1_SITUA = '2' " // 2=Implantada
			cQry += " AND TE1_ENTIDA = 'ABS' "
		EndIf
		// Ordem por Codigo do Colete
		cQry += " ORDER BY TE1_CODCOL"
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			cQry += ", TXQ_CODIGO"
		EndIf

	ElseIf lGsOrcArma .And. cTipo $ "|MUNI|"

		cTitle := STR0141  //"Munições"

		cQry := "SELECT DISTINCT TE2_CODMUN, B1_DESC, TE2_CODPRO"
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			cQry += ", TXQ_CODIGO, TXQ_ITEARM"
		EndIf
		// Munições
		cQry += " FROM " + RetSqlName("TE2") + " TE2 "
		// Produtos
		cQry += " INNER JOIN " + RetSqlName("SB1") + " B1 "
		cQry +=        "  ON B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry +=        " AND B1_COD = TE2_CODPRO "
		cQry +=        " AND B1.D_E_L_E_T_ = ' ' "
		// Historico Movimentação Munições
		cQry += " INNER JOIN " + RetSqlName("TFP") + " TFP "
		cQry +=        "  ON TFP_FILIAL = '" + xFilial("TFP") + "'"
		cQry +=        " AND TFP_PRODUT = TE2_CODPRO "
		If cEntOri == '1'
			cQry +=   " AND TFP_ENTIDA = '1' AND TFP_CODINT = '" + cOrigem + "'" 
		Else
			cQry +=   " AND TFP_ENTIDA = '2' AND TFP_CODLOC = '" + cOrigem + "'"
		EndIf
		cQry +=       " AND TFP.D_E_L_E_T_ = ' ' "
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			// Locais de Atendimento
			cQry += " INNER JOIN " + RetSqlName("TFL") + " TFL "
			cQry +=        "  ON TFL_FILIAL = '" + xFilial("TFL") + "'"
			cQry +=        " AND TFL_CODIGO = '" + FwFldGet("TFQ_CODTFL")+"' "
			cQry +=        " AND TFL_CONTRT = '" + FwFldGet("TFQ_CONTRT") + "' ""
			If lExstRev
				cQry +=    " AND TFL_CONREV = '" + FwFldGet("TFQ_CONREV") + "' ""
			EndIf
			cQry +=        " AND TFL.D_E_L_E_T_ = ' ' "
			// Postos de Trabalho
			cQry += " INNER JOIN " + RetSqlName("TFF") + " TFF "
			cQry +=        "  ON TFF_FILIAL = '" + xFilial("TFF") + "' "
			cQry +=        " AND TFF_CODPAI = TFL_CODIGO "
			cQry +=        " AND TFF_CONTRT = TFL_CONTRT "
			cQry +=        " AND TFF_CONREV = TFL_CONREV "
			cQry +=        " AND TFF.D_E_L_E_T_ = ' ' "
			// Armamentos - Coletes
			cCodSub := Space( FWSX3Util():GetFieldStruct( "TXQ_CODSUB" )[3] )
			cQry += " INNER JOIN " + RetSqlName("TXQ") + " TXQ "
			cQry +=        "  ON TXQ_FILIAL = '" + xFilial("TXQ") + "' "
			cQry +=        " AND TXQ_CODTFF = TFF_COD"
			cQry +=        " AND TXQ_CODPRD = TE2_CODPRO "
			cQry +=        " AND TXQ_ITEARM = '3' " // 3 = Munição
			cQry +=        " AND TXQ_CODSUB = '" + cCodSub + "' "
			cQry +=        " AND TXQ.D_E_L_E_T_ = ' ' "
			If !lNew
				// Itens de Movimentação
				cQry += " INNER JOIN " + RetSqlName("TFO") + " TFO "
				cQry +=        "  ON TFO_FILIAL = '"+xFilial("TFO")+"' "
				cQry +=        " AND TFO_ITCOD = TE2_CODMUN "
				cQry +=        " AND TFO.D_E_L_E_T_ = ' '"
			EndIf
		EndIf
		// Munições (Where)
		cQry +=   " WHERE TE2.D_E_L_E_T_ = ' '"
		cQry +=     " AND TE2_FILIAL  = '"+xFilial("TE2")+"' "
		// Ordem por Codigo do Colete
		cQry += " ORDER BY TE2_CODMUN"
		If !( lArmMultFil .And. cEntOri == "1" .And. cEntDest == "2" .And. lMovInterna )
			cQry += ", TXQ_CODIGO"
		EndIf
	EndIf

	nSuperior := 0
	nEsquerda := 0
	nInferior := GetScreenRes()[2] * 0.6
	nDireita  := GetScreenRes()[1] * 0.65
	cRetResT  := ""
	cCodTFL   := ""

	DEFINE MSDIALOG oDlgEscTela TITLE OemToAnsi(cTitle) FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL

		oBrowse := FWFormBrowse():New()
		oBrowse:SetOwner(oDlgEscTela)
		oBrowse:SetDataQuery(.T.)
		oBrowse:SetAlias(cAls)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetQuery(cQry)
		oBrowse:SetSeek(,aSeek)
		If cTipo == "LOCAL"
			oBrowse:SetDescription(STR0036) //Local de Atendimento
		Elseif cTipo == "CONTRATO"
			oBrowse:SetDescription(STR0132) //"Contrato"
		Elseif cTipo == "ARMA"
			oBrowse:SetDescription(STR0131) //Armamento x Orçamento
		Elseif cTipo == "COLETE"
			oBrowse:SetDescription(STR0133) //Colete x Orçamento
		Elseif cTipo == "LOCTXQ"
			oBrowse:SetDescription(STR0036) //Local de Atendimento
		Elseif cTipo == "MUNI"
			oBrowse:SetDescription(STR0134) //Munições x Orçamento
		Elseif !IsInCallStack("TECA880")
			oBrowse:SetDescription(STR0070) //"Alocação de Reserva"
		Endif
		oBrowse:SetMenuDef("")
		TECSetFlt(aSeek, @oBrowse)
		oBrowse:DisableDetails()
		oBrowse:SetUseFilter(.T.)
		oBrowse:SetProfileID(cAls)

		if cTipo $ "|LOCAL|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TFL_LOCAL, lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TFL_LOCAL, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()

			ADD COLUMN oColumn DATA { || TFL_CODIGO  } TITLE STR0044 SIZE TamSX3("TFL_CODIGO")[1] OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || TFL_LOCAL   } TITLE STR0036 SIZE TamSX3("TFF_LOCAL")[1]  OF oBrowse //"Local de atendimento"
			ADD COLUMN oColumn DATA { || ABS_DESCRI  } TITLE STR0079 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Descricao"
			ADD COLUMN oColumn DATA { || TFL_CODPAI  } TITLE STR0073 SIZE TamSX3("TFL_CODPAI")[1] OF oBrowse //"Orçamento"
		ElseIF cTipo $ "|ORCA|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TFJ_CODIGO, lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TFJ_CODIGO, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || TFJ_FILIAL  } TITLE STR0075 SIZE TamSX3("TFJ_FILIAL")[1] OF oBrowse //"Filial"
			ADD COLUMN oColumn DATA { || TFJ_CODIGO  } TITLE STR0044 SIZE TamSX3("TFJ_CODIGO")[1] OF oBrowse //"Codigo"
			ADD COLUMN oColumn DATA { || TFJ_CODENT  } TITLE STR0076 SIZE TamSX3("TFJ_CODENT")[1] OF oBrowse //"Cliente"
			ADD COLUMN oColumn DATA { || TFJ_LOJA    } TITLE STR0077 SIZE TamSX3("TFJ_LOJA")[1]   OF oBrowse //"Loja"
			ADD COLUMN oColumn DATA { || A1_NOME     } TITLE STR0159 SIZE TamSX3("A1_NOME")[1]    OF oBrowse //"Nome Cliente"
		ElseIF cTipo $ "|POSTO|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TFF_COD, cCodTFL := (oBrowse:Alias())->TFF_CODPAI, lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TFF_COD,  cCodTFL := (oBrowse:Alias())->TFF_CODPAI , lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()

			ADD COLUMN oColumn DATA { || TFF_FILIAL  } TITLE STR0149 SIZE TamSX3("TFF_FILIAL")[1] OF oBrowse //"Filial"
			ADD COLUMN oColumn DATA { || TFF_COD     } TITLE STR0038 SIZE TamSX3("TFF_COD")[1]    OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || TFF_PRODUT  } TITLE STR0078 SIZE TamSX3("TFF_PRODUT")[1] OF oBrowse //"Produto"
			ADD COLUMN oColumn DATA { || B1_DESC     } TITLE STR0079 SIZE TamSX3("B1_DESC")[1]    OF oBrowse //"Descrição do Produto"
			ADD COLUMN oColumn DATA { || ABS_DESCRI  } TITLE STR0150 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Código do Orçamento"
			ADD COLUMN oColumn DATA { || STOD(TFF_PERINI ) } TITLE STR0151 SIZE TamSX3("TFF_PERINI")[1] OF oBrowse //"Período Inicial"
			ADD COLUMN oColumn DATA { || STOD(TFF_PERFIM ) } TITLE STR0152 SIZE TamSX3("TFF_PERFIM")[1] OF oBrowse //"Período Final"
			ADD COLUMN oColumn DATA { || TFF_QTDVEN  } TITLE TecTituDes( "TFF_QTDVEN", .F. ) SIZE TamSX3("TFF_QTDVEN")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || TFF_FUNCAO  } TITLE STR0153 SIZE TamSX3("TFF_FUNCAO")[1] OF oBrowse //"Codigo da Função"
			ADD COLUMN oColumn DATA { || RJ_DESC     } TITLE STR0154 SIZE TamSX3("RJ_DESC")[1]    OF oBrowse //"Descrição da Função"
			ADD COLUMN oColumn DATA { || TFF_TURNO   } TITLE STR0155 SIZE TamSX3("TFF_TURNO")[1]  OF oBrowse //"Código do Turno"
			ADD COLUMN oColumn DATA { || R6_DESC     } TITLE STR0156 SIZE TamSX3("R6_DESC")[1]    OF oBrowse //"Descrição do Turno"
			ADD COLUMN oColumn DATA { || TFF_ESCALA  } TITLE STR0157 SIZE TamSX3("TFF_ESCALA")[1] OF oBrowse //"Codigo da Escala"
			ADD COLUMN oColumn DATA { || TDW_DESC    } TITLE STR0158 SIZE TamSX3("TDW_DESC")[1]   OF oBrowse //"Descrição da Escala"

		ElseIF cTipo $ "|TIPO|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TCU_COD, lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TCU_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || TCU_COD  } TITLE STR0044 SIZE TamSX3("TFF_LOCAL")[1]  OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || TCU_DESC } TITLE STR0079 SIZE TamSX3("TFF_PRODUT")[1] OF oBrowse //"Descrição do Produto"
		ElseIF cTipo $ "|CONFAL|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->COD, lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT  := (oBrowse:Alias())->COD, lRet := .T., oDlgEscTela:End() } ,, 2 )	//"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || COD   } TITLE STR0044 SIZE TamSX3("TDX_COD")[1]   OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || TURNO } TITLE STR0025 SIZE TamSX3("TDX_TURNO")[1] OF oBrowse //"Turno"
		ElseIF cTipo $ "|LOCTXQ|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TFL_LOCAL,  lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TFL_LOCAL, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || TFL_LOCAL  } TITLE STR0036 SIZE TamSX3("TFL_LOCAL")[1]  OF oBrowse //"Local de Atendimento"
			ADD COLUMN oColumn DATA { || ABS_DESCRI } TITLE STR0079 SIZE TamSX3("ABS_DESCRI")[1] OF oBrowse //"Descrição"
		ElseIF cTipo $ "|CONTRATO|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TFJ_CONTRT, At190JRev((oBrowse:Alias())->TFJ_CONREV, oModel), lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TFJ_CONTRT, At190JRev((oBrowse:Alias())->TFJ_CONREV, oModel), lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", At190JRev('', oModel), oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || TFJ_CONTRT } TITLE STR0132 SIZE TamSX3("TFF_CONTRT")[1] OF oBrowse //"Contrato"
			ADD COLUMN oColumn DATA { || TFJ_CONREV } TITLE STR0135 SIZE TamSX3("TFJ_CONREV")[1] OF oBrowse //"Revisão"
		Elseif cTipo $ "|ARMA|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TE0_COD, IIF(!lMovInterna, cDest := (oBrowse:Alias())->TXQ_CODIGO, cDest := ""), lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TE0_COD, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || TE0_COD } TITLE STR0136 SIZE TamSX3("TE0_COD")[1] OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || B1_DESC } TITLE STR0079 SIZE TamSX3("B1_DESC")[1] OF oBrowse //"Descrição"
			If !lMovInterna
				ADD COLUMN oColumn DATA { || TXQ_CODIGO } TITLE STR0138 SIZE TamSX3("TXQ_CODIGO")[1] OF oBrowse	//"Cod Arm Orc"
			EndIf
		Elseif cTipo $ "|COLETE|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TE1_CODCOL, IIF(!lMovInterna, cDest := (oBrowse:Alias())->TXQ_CODIGO, cDest := ""), lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TE1_CODCOL, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { || TE1_CODCOL } TITLE STR0137 SIZE TamSX3("TE1_CODCOL")[1] OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { || B1_DESC    } TITLE STR0079 SIZE TamSX3("B1_DESC")[1]    OF oBrowse //"Descrição"
			If !lMovInterna
				ADD COLUMN oColumn DATA { || TXQ_CODIGO } TITLE STR0139 SIZE TamSX3("TXQ_CODIGO")[1] OF oBrowse	//"Cod Col Orc"
			EndIf
		Elseif cTipo $ "|MUNI|"
			oBrowse:SetDoubleClick({ || cRetResT := (oBrowse:Alias())->TE2_CODMUN, IIF(!lMovInterna, cDest := (oBrowse:Alias())->TXQ_CODIGO, cDest := ""),cItMun := (oBrowse:Alias())->TE2_CODPRO , lRet := .T. ,oDlgEscTela:End()})
			oBrowse:AddButton( OemTOAnsi(STR0071), {|| cRetResT := (oBrowse:Alias())->TE2_CODMUN, lRet := .T., oDlgEscTela:End() } ,, 2 ) //"Confirmar"
			oBrowse:AddButton( OemTOAnsi(STR0072), {|| cRetResT := "", oDlgEscTela:End() } ,, 2 ) //"Cancelar"
			oBrowse:DisableDetails()
			ADD COLUMN oColumn DATA { ||  TE2_CODMUN } TITLE STR0137 SIZE TamSX3("TE2_CODMUN")[1] OF oBrowse //"Código"
			ADD COLUMN oColumn DATA { ||  B1_DESC    } TITLE STR0079 SIZE TamSX3("B1_DESC")[1]    OF oBrowse //"Descrição"
			If !lMovInterna
				ADD COLUMN oColumn DATA { ||  TXQ_CODIGO } TITLE STR0140 SIZE TamSX3("TXQ_CODIGO")[1] OF oBrowse //"Cod Mun Orc"
			EndIf
		Endif

		oBrowse:Activate()

	ACTIVATE MSDIALOG oDlgEscTela CENTERED

	If  lGsOrcArma .And. !Empty(cRetResT) .And. IsInCallStack("TECA880")
		At880Ret(cRetResT, cDest, cCodTFL, cItMun)
	else
		At880Ret("")
	Endif

	RestArea(aArea)

Return lOK

//-------------------------------------------------------------------
/*/{Protheus.doc} F3Restec()
Retorno da consulta especifica

@author Vitor kwon
@since  01/11/2022
/*/
//------------------------------------------------------------------
Function F3Restec()

Return cRetResT

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrelinRES()

Função de Prevalidacao dos fields de alocação RES

@author Vitor kwon
@since 08/11/2022
/*/
//------------------------------------------------------------------------------

Function PrelinRES(oMdlRES,cAction,cField,xValue)

local lRet	:= .T.
local lCont	:= .T.

  if VALTYPE(oMdlRES) == 'O' .AND. oMdlRES:GetId() == "RESMASTER"

	If cAction == "SETVALUE"

		If cField == "RES_ORCA"
			If Empty(xValue)
				oMdlRES:SetValue("RES_LOCAL", "")
				oMdlRES:SetValue("RES_CODTFF", "")
				oMdlRES:SetValue("RES_TIPMOV", "")
			EndIf
		  	lCont := AT190JOrca(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil, STR0081, 1 ) //"O orçamento digitado nao existe. Verifique e refaça a operação"
			Endif
		Elseif 	cField == "RES_LOCAL"
			If Empty(xValue)
				oMdlRES:SetValue("RES_CODTFF", "")
				oMdlRES:SetValue("RES_TIPMOV", "")
			EndIf
			lCont := AT190JLocal(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil, STR0082 , 1 ) //"O Local de atendimento digitado nao existe. Verifique e refaça a operação"
			Endif
		Elseif 	cField == "RES_CODTFF"
			If Empty(xValue)
				oMdlRES:SetValue("RES_TIPMOV", "")
			EndIf
			lCont := AT190JPosto(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil, STR0083, 1 ) //"O Posto digitado nao existe. Verifique e refaça a operação"
			Endif
		Elseif 	cField == "RES_TIPMOV"
			lCont := AT190Jtipo(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "PrelinRES", Nil,STR0084  , 1 ) //"O Tipo digitado nao existe. Verifique e refaça a operação"
			Endif
		Endif
	Endif

Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190JConSOrc()

Função de Prevalidacao  do campo Orçamento da tabela RES - Alocaçao de Reserva

@author Vitor kwon
@since 08/11/2022
/*/
//------------------------------------------------------------------------------


Function AT190JOrca(cOrca)

Local cQry      := ""
local cAliasTFJ := GetNextAlias()
local lRet      := .F.
local cCond     := "1"

	cQry := " SELECT 1   "
	cQry += " FROM " + RetSqlName("TFJ") + " TFJ"
	cQry += " WHERE TFJ.D_E_L_E_T_ = ' ' "
	cQry += " AND TFJ_FILIAL = '"+xFilial("TFJ")+"'"
	cQry += " AND TFJ_CODIGO = '"+cOrca+"' "
	cQry += " AND TFJ_RESTEC = '"+cCond+"'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFJ,.T.,.T.)

	If (cAliasTFJ)->(!Eof())
		lRet := .T.
	Endif

(cAliasTFJ)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190JLocal()

Função de Prevalidacao  do campo local de Atendimento da tabela RES - Alocaçao de Reserva

@author Vitor kwon
@since 08/11/2022
/*/
//------------------------------------------------------------------------------


Function AT190JLocal(cLocal)

Local cQry      := ""
local cAliasTFL := GetNextAlias()
local lRet      := .F.

		cQry := " SELECT  1 "
		cQry += " FROM " + RetSqlName("TFL") + " TFL "
		cQry += " WHERE TFL.D_E_L_E_T_ = ' ' AND TFL_FILIAL = '"+xFilial("TFL")+"'"
		cQry += " AND TFL_LOCAL = '"+cLocal+"'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFL,.T.,.T.)

	If (cAliasTFL)->(!Eof())
		lRet := .T.
	Endif

(cAliasTFL)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190JPosto()

Função de Prevalidacao  do campo Posto da tabela RES - Alocaçao de Reserva

@author Vitor kwon
@since 09/11/2022
/*/
//------------------------------------------------------------------------------


Function AT190JPosto(cPosto)

Local cQry      := ""
local cAliasTFF := GetNextAlias()
local lRet      := .F.

		cQry := " SELECT 1"
		cQry += " FROM " + RetSqlName("TFF") + " TFF "
		cQry += " WHERE TFF.D_E_L_E_T_ = ' ' AND TFF_FILIAL = '"+xFilial("TFF")+"'"
		cQry += " AND TFF_COD = '"+cPosto+"'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTFF,.T.,.T.)

	If (cAliasTFF)->(!Eof())
		lRet := .T.
	Endif

(cAliasTFF)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190JTip()

Função de Prevalidacao  do campo Tipo da tabela RES - Alocaçao de Reserva

@author Vitor kwon
@since 09/11/2022
/*/
//------------------------------------------------------------------------------


Function AT190JTipo(cTipo)

Local cQry      := ""
local cAliasTCU := GetNextAlias()
local lRet      := .F.
local cCond  := "1"

	cQry := " SELECT TCU.TCU_FILIAL, TCU.TCU_COD, TCU.TCU_DESC, TCU.TCU_RESTEC "
	cQry += " FROM " + RetSqlName("TCU") + " TCU "
	cQry += " WHERE TCU.D_E_L_E_T_ = ' ' AND TCU_FILIAL = '"+xFilial("TCU")+"'"
	cQry += " AND TCU_COD = '"+cTipo+"' AND TCU_RESTEC = '"+cCond+"'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTCU,.T.,.T.)

	If (cAliasTCU)->(!Eof())
		lRet := .T.
	Endif

(cAliasTCU)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT190JEsc()

Função de Prevalidacao do campo Escala da tabela RES - Alocaçao de Reserva

@author Vitor kwon
@since 09/11/2022
/*/
//------------------------------------------------------------------------------


Function AT190JEsc(cCodigo)

Local cQry      := ""
local cAliasTDW := GetNextAlias()
local lRet      := .F.

	cQry := " SELECT TDW_COD CODIGO "
	cQry += " FROM " + RetSqlName("TDW") + " TDW "
	cQry += " WHERE TDW.D_E_L_E_T_ = ' ' AND TDW_FILIAL = '"+xFilial("TDW")+"'"
	cQry += " AND TDW_COD = '"+cCodigo+"'"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTDW,.T.,.T.)

	If (cAliasTDW)->(!Eof())
		lRet := .T.
	Endif

(cAliasTDW)->(DbCloseArea())

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} At19dVGRE

@description preValid da grid GRE

@author	Vitor Kwon
@since	09/11/2022
/*/
//------------------------------------------------------------------------------
Function At19dVGRE(oMdlGRE, nLine, cAcao, cCampo, xValue, xOldValue)
Local cContrt := ""
Local cCodTfl := ""
Local cEscala := ""
Local lRet := .T.
local lCont := .T.
Local oView


If cAcao == "SETVALUE" .AND. VALTYPE(oMdlGRE) == "O"
	iF 	cCampo == "GRE_FILIAL"
		If EMPTY(xValue) .OR. !(ExistCpo("SM0", cEmpAnt+xValue))
			lRet := .F.
			Help( " ", 1, "At19dVGRE", Nil, STR0085, 1 ) //"O campo filial deve ser preenchido com uma filial válida"
		EndIf
	Elseif cCampo == "GRE_CODTEC"
		If !(EMPTY(xValue)) .AND. !(ExistCpo("AA1", xValue))
			lRet := .F.
			Help(,,"At19dVGRE",,STR0086,1,0) //"Código do atendente " # " não localizado."
		EndIf
	Elseif cCampo == "GRE_DTINI"
		If xValue > oMdlGRE:GetValue("GRE_DTFIM") .AND. !EMPTY(oMdlGRE:GetValue("GRE_DTFIM")) .AND. !EMPTY(xValue)
			lRet := .F.
			Help(,,"At19dVGRE",,STR0087,1,0) //"A data de início da alocação deve ser menor ou igual a data final de alocação"
		EndIf
	ElseIF cCampo == "GRE_DTFIM"
		If xValue < oMdlGRE:GetValue("GRE_DTINI") .AND. !EMPTY(oMdlGRE:GetValue("GRE_DTINI")) .AND. !EMPTY(xValue)
			lRet := .F.
			Help(,,"At19dVGRE",,STR0088,1,0) //"A data final da alocação deve ser maior ou igual a data inicial de alocação"
		EndIf
	ElseIf cCampo == "GRE_CONTRT"
			If EMPTY(xValue)
				oMdlGRE:SetValue("GRE_CODTFL", "")
				oMdlGRE:SetValue("GRE_CODTFF", "")
				oMdlGRE:SetValue("GRE_ESCALA", "")
				oMdlGRE:SetValue("GRE_DSCTDW", "")
			EndIf
		  	lCont := AT190JOrca(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "At19dVGRE", Nil, STR0089, 1 ) //"O orçamento digitado nao existe. Verifique e refaça a operação"
			Endif
	Elseif 	cCampo == "GRE_CODTFL"
			If EMPTY(xValue)
				oMdlGRE:SetValue("GRE_CODTFF", "")
				oMdlGRE:SetValue("GRE_ESCALA", "")
			EndIf
			lCont := AT190JLocal(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "At19dVGRE", Nil, STR0090, 1 ) //"O Local de atendimento digitado nao existe. Verifique e refaça a operação"
			Endif
	Elseif 	cCampo == "GRE_CODTFF"
			If EMPTY(xValue)
				oMdlGRE:SetValue("GRE_ESCALA", "")
			EndIf
			lCont := AT190JPosto(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "At19dVGRE", Nil, STR0091, 1 ) //"O Posto digitado nao existe. Verifique e refaça a operação"
			Endif

			If Empty(oMdlGRE:GetValue("GRE_CONTRT"))
				cContrt := Posicione("TFF",1,xFilial("TFF",oMdlGRE:GetValue("GRE_FILIAL")) + xValue, "TFF_CONTRT")
			else
				cContrt := oMdlGRE:GetValue("GRE_CONTRT")
			EndIf

			If Empty(oMdlGRE:GetValue("GRE_CODTFL"))
				cCodTfl := Posicione("TFF",1,xFilial("TFF",oMdlGRE:GetValue("GRE_FILIAL")) + xValue, "TFF_CODPAI")
			else
				cCodTfl := oMdlGRE:GetValue("GRE_CODTFL")
			EndIf
			
			If lRet .AND. !EMPTY(xValue)
				oMdlGRE:LoadValue("GRE_CONTRT",cContrt)
				oMdlGRE:LoadValue("GRE_CODTFL",cCodTfl)
				If !EMPTY( (cEscala := Posicione("TFF",1,xFilial("TFF",oMdlGRE:GetValue("GRE_FILIAL"))+xValue,"TFF_ESCALA") ) )
					oMdlGRE:LoadValue("GRE_ESCALA", cEscala)
					oMdlGRE:LoadValue("GRE_DSCTDW", Posicione("TDW",1,xFilial("TDW",oMdlGRE:GetValue("GRE_FILIAL")) + cEscala, "TDW_DESC"))
				EndIf
			EndIf
	Elseif 	cCampo == "GRE_TIPTCU"
			lCont := AT190Jtipo(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "At19dVGRE", Nil, STR0092, 1 ) //"O Tipo digitado nao existe. Verifique e refaça a operação"
			Endif
	Elseif 	cCampo == "GRE_ESCALA"
			If (Empty(oMdlGRE:GetValue("GRE_CODTFF")) .OR. Empty(oMdlGRE:GetValue("GRE_CODTFL")) .OR. Empty(oMdlGRE:GetValue("GRE_CONTRT"))) .AND. !EMPTY(xValue)
				lRet := .F.
				Help(,,"At19dVGRE",,STR0093,1,0) //"Para informar a Escala, é necessário preencher os campos Contrato, Código do Local e Código do Posto."
			EndIf
			lCont := AT190JEsc(xValue)
			If !lCont .And. !Empty(xValue)
		  		lRet := .F.
				Help( " ", 1, "At19dVGRE", Nil, STR0119, 1 ) //"Código de escala inválido."
			Endif
			If lRet
				If !EMPTY((cEscala := Posicione("TFF",1,xFilial("TFF",oMdlGRE:GetValue("GRE_FILIAL"))+oMdlGRE:GetValue("GRE_CODTFF"),"TFF_ESCALA"))) .AND. !EMPTY(xValue) .AND.;
						!EMPTY(xOldValue) .AND. xValue != cEscala
					lRet := .F.
					Help(,,"PRELINTGY",,STR0147 + cEscala + STR0148 + oMdlGRE:GetValue("GRE_CODTFF") + "). ",1,0) //"A escala "#" já está vinculada a este posto (" #"). Para modifica-lá, utiliza a rotina Posto x Escala no Gestão de Escalas."
				EndIf

				If lRet .AND. cEscala != xValue .AND. !EMPTY(xValue) .AND. !EMPTY(cEscala)
					lRet := .F.
					Help(,,"PRELINTGY",,STR0147 + cEscala + STR0148  + oMdlGRE:GetValue("GRE_CODTFF") + ").",1,0) //"A escala "#" já está vinculada a este posto (" #"). Para modifica-lá, utiliza a rotina Posto x Escala no Gestão de Escalas."
				EndIf
			EndIf
	Elseif cCampo == "GRE_SEQ"
			If !EMPTY(xValue)
				If oMdlGRE:GetValue("GRE_TIPOAL") == '1'
					lCont := At190JSeq(xValue)
					If !lCont .And. !Empty(xValue)
						lRet := .F.
						Help( " ", 1, "At19dVGRE", Nil, STR0120, 1 ) //"Código sequencial inválido."
					Endif
				EndIf
			EndIf
	ElseIf cCampo == "GRE_CONFAL"
				lCont := AT190JConfal(xValue)
				If !lCont .And. !Empty(xValue)
					lRet := .F.
					Help( " ", 1, "At19dVGRE", Nil, STR0121, 1 ) //"Código de alocação inválido."
				Endif
	Endif
	If !isBlind()
		oView := FwViewActive()
		oView:Refresh("DETAIL_RES")
		oView:Refresh("DETAIL_RTE")
	EndIf
Endif

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} At190JGRE

@description Legenda do campo GRE_STATUS

@author	Vitor kwon
@since	10/11/2022
/*/
//------------------------------------------------------------------------------
Static Function At190JGRE()

Local	oLegABB := FwLegend():New()

oLegABB:Add( "", "BR_VERMELHO", STR0111)//"Não processado"
oLegABB:Add( "", "BR_AMARELO" , STR0112) //"Agenda projetada"
oLegABB:Add( "", "BR_VERDE"	  , STR0113) //"Agenda gravada"
oLegABB:Add( "", "BR_PRETO"	  , STR0114) //"Conflito de Alocação"
oLegABB:Add( "", "BR_LARANJA" , STR0115) //"Falha na alocação"
oLegABB:Add( "", "BR_CANCEL"  , STR0116) //"Falha na projeção"
oLegABB:Add( "", "BR_PINK"    , STR0117) //"Atendente com Restrição"
oLegABB:View()
DelClassIntf()
Return(.T.)

//--------------

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190jPrjLAC

@description Executa a projeção das agendas de reserva técnica dentro de uma barra de progresso

@author	Vitor Kwon
@since	16/11/2022
/*/
//------------------------------------------------------------------------------
Function At190jPrjLAC(oDlg,oMeter,cMsg)
Local oModel := FwModelActive()
Local oMdlRTE := oModel:GetModel("RTEDETAIL")
Local oMdlGRE := oModel:GetModel("RESDETAIL")
Local nX
Local nY
Local nAux
Local nCount := 0
Local lLoadBar := .F.
Local lJaProj := .F.
Local oView := FwViewActive()

Default cMsg := ""
Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

For nX := 1 To oMdlGRE:Length()
	oMdlGRE:GoLine(nX)
	If oMdlGRE:GetValue("GRE_STATUS") == "BR_CANCEL" .OR. oMdlGRE:GetValue("GRE_STATUS") == "BR_VERDE"
		If lLoadBar
			oMeter:Set(++nCount)
			oMeter:Refresh()
		EndIf
		Loop
	EndIf
	lJaProj := .F.
	For nY := 1 To LEN(aAlocRES)
		lJaProj := .F.
		If VALTYPE(aAlocRES[nY]) == 'O'
			If aAlocRES[nY]:defCob() == (oMdlGRE:GetValue("GRE_TIPOAL") == '2')     .AND.;
						aAlocRES[nY]:defEscala()  == oMdlGRE:GetValue("GRE_ESCALA") .AND.;
						aAlocRES[nY]:defPosto()   == oMdlGRE:GetValue("GRE_CODTFF") .AND.;
						aAlocRES[nY]:defSeq()     == oMdlGRE:GetValue("GRE_SEQ")    .AND.;
						aAlocRES[nY]:defTec()     == oMdlGRE:GetValue("GRE_CODTEC") .AND.;
						aAlocRES[nY]:defGrupo()   == oMdlGRE:GetValue("GRE_GRUPO")  .AND.;
						aAlocRES[nY]:defConfal()  == oMdlGRE:GetValue("GRE_CONFAL") .AND.;
						aAlocRES[nY]:defDate()[1] == oMdlGRE:GetValue("GRE_DTINI")  .AND.;
						aAlocRES[nY]:defDate()[2] == oMdlGRE:GetValue("GRE_DTFIM")
				If TecXHasEdH()
					If aAlocRES[nY]:defGeHor()[1][1]      == oMdlGRE:GetValue("GRE_ENTRA1") .AND.;
							aAlocRES[nY]:defGeHor()[1][2] == oMdlGRE:GetValue("GRE_SAIDA1") .AND.;
							aAlocRES[nY]:defGeHor()[2][1] == oMdlGRE:GetValue("GRE_ENTRA2") .AND.;
							aAlocRES[nY]:defGeHor()[2][2] == oMdlGRE:GetValue("GRE_SAIDA2") .AND.;
							aAlocRES[nY]:defGeHor()[3][1] == oMdlGRE:GetValue("GRE_ENTRA3") .AND.;
							aAlocRES[nY]:defGeHor()[3][2] == oMdlGRE:GetValue("GRE_SAIDA3") .AND.;
							aAlocRES[nY]:defGeHor()[4][1] == oMdlGRE:GetValue("GRE_ENTRA4") .AND.;
							aAlocRES[nY]:defGeHor()[4][2] == oMdlGRE:GetValue("GRE_SAIDA4")
						lJaProj := .T.
					EndIf
				Else
					lJaProj := .T.
				EndIf
			EndIf
		EndIf
		If lJaProj
			Exit
		EndIf
	Next nY
	If lJaProj
		Loop
	EndIf

	oMdlRTE:ClearData()
	oMdlRTE:InitLine()
	If !EMPTY(oMdlGRE:GetValue("GRE_ESCALA"))
		AADD(aAlocRES, {})
		nAux := LEN(aAlocRES)
		aAlocRES[nAux] := GsAloc():New()
		If TecMultFil()
			aAlocRES[nAux]:defFil(oMdlGRE:GetValue("GRE_FILIAL"))
		EndIf
		aAlocRES[nAux]:defEscala(oMdlGRE:GetValue("GRE_ESCALA"))
		aAlocRES[nAux]:defPosto(oMdlGRE:GetValue("GRE_CODTFF"))
		aAlocRES[nAux]:defTec(oMdlGRE:GetValue("GRE_CODTEC"))
		aAlocRES[nAux]:defGrupo(oMdlGRE:GetValue("GRE_GRUPO"))
		aAlocRES[nAux]:defConfal(oMdlGRE:GetValue("GRE_CONFAL"))
		aAlocRES[nAux]:defDate(oMdlGRE:GetValue("GRE_DTINI"),oMdlGRE:GetValue("GRE_DTFIM"))
		aAlocRES[nAux]:defSeq(oMdlGRE:GetValue("GRE_SEQ"))
		aAlocRES[nAux]:defTpAloca(oMdlGRE:GetValue("GRE_TIPTCU"))
		aAlocRES[nAux]:defTpAlo(oMdlGRE:GetValue("GRE_TIPTCU"))
		aAlocRES[nAux]:defCob((oMdlGRE:GetValue("GRE_TIPOAL") == '2'))
		aAlocRES[nAux]:defResTec("1") //Reserva Tecnica
		If TecXHasEdH()
			aAlocRES[nAux]:defGeHor	({;
									{oMdlGRE:GetValue("GRE_ENTRA1"),;
									oMdlGRE:GetValue("GRE_SAIDA1")},;
									{oMdlGRE:GetValue("GRE_ENTRA2"),;
									oMdlGRE:GetValue("GRE_SAIDA2")},;
									{oMdlGRE:GetValue("GRE_ENTRA3"),;
									oMdlGRE:GetValue("GRE_SAIDA3")},;
									{oMdlGRE:GetValue("GRE_ENTRA4"),;
									oMdlGRE:GetValue("GRE_SAIDA4")};
									})
		EndIf
		If TFF->( ColumnPos('TFF_REGRA') ) > 0
			aAlocRES[nAux]:defRegra(oMdlGRE:GetValue("GRE_REGRA"))
		EndIf
		aAlocRES[nAux]:projAloc()
		If !EMPTY( aAlocRES[nAux]:defMessage() )
			oMdlGRE:LoadValue("GRE_DETALH", LEFT(aAlocRES[nAux]:defMessage(), 185))
		Endif
		If aAlocRES[nAux]:getConfl()
			oMdlGRE:LoadValue("GRE_STATUS", "BR_PRETO")
		ElseIf aAlocRES[nAux]:temBloqueio() .OR. aAlocRES[nAux]:temAviso()
			oMdlGRE:LoadValue("GRE_STATUS", "BR_PINK")
		Else
			oMdlGRE:LoadValue("GRE_STATUS", "BR_AMARELO")
		EndIf


		For nY := 1 To LEN(aAlocRES[nAux]:getProj())
			If oMdlRTE:GetMaxLines() < LEN(aAlocRES[nAux]:getProj())
				oMdlRTE:SetMaxLine(LEN(aAlocRES[nAux]:getProj()))
			EndIf
			If nY != 1
				oMdlRTE:AddLine()
			EndIf

			oMdlRTE:LoadValue("RTE_SITABB", aAlocRES[nAux]:getProj()[nY][1])
			oMdlRTE:LoadValue("RTE_SITALO", At330ACLgS(aAlocRES[nAux]:getProj()[nY][11]))
			oMdlRTE:LoadValue("RTE_GRUPO", 	aAlocRES[nAux]:getProj()[nY][3])
			oMdlRTE:LoadValue("RTE_DATREF", aAlocRES[nAux]:getProj()[nY][4])
			oMdlRTE:LoadValue("RTE_DATA", 	aAlocRES[nAux]:getProj()[nY][5])
			oMdlRTE:LoadValue("RTE_SEMANA", aAlocRES[nAux]:getProj()[nY][6])
			oMdlRTE:LoadValue("RTE_ENTRADA",aAlocRES[nAux]:getProj()[nY][7])
			oMdlRTE:LoadValue("RTE_SAIDA", 	aAlocRES[nAux]:getProj()[nY][8])
			oMdlRTE:LoadValue("RTE_TIPO",	aAlocRES[nAux]:getProj()[nY][11])
			oMdlRTE:LoadValue("RTE_SEQ",	aAlocRES[nAux]:getProj()[nY][15])
			oMdlRTE:LoadValue("RTE_EXSABB", aAlocRES[nAux]:getProj()[nY][19])
			oMdlRTE:LoadValue("RTE_KEYTGY",	aAlocRES[nAux]:getProj()[nY][17])
			oMdlRTE:LoadValue("RTE_ITTGY",	aAlocRES[nAux]:getProj()[nY][18])
			oMdlRTE:LoadValue("RTE_TURNO",	aAlocRES[nAux]:getProj()[nY][14])
			oMdlRTE:LoadValue("RTE_ITEM", 	aAlocRES[nAux]:getProj()[nY][16])
			oMdlRTE:LoadValue("RTE_CODTEC",	aAlocRES[nAux]:getProj()[nY][9])
			oMdlRTE:LoadValue("RTE_NOMTEC",	aAlocRES[nAux]:getProj()[nY][10])
			oMdlRTE:LoadValue("RTE_TIPTCU",	aAlocRES[nAux]:getProj()[nY][24])
			oMdlRTE:LoadValue("RTE_DSCONF", LEFT(aAlocRES[nAux]:getProj()[nY][23],35))
		Next nY
	EndIf
	If lLoadBar
		oMeter:Set(++nCount)
		oMeter:Refresh()
	EndIf

	oView:Refresh("DETAIL_RES")
	oView:Refresh("DETAIL_RTE")

Next nX
If lLoadBar
	oDlg:End()
EndIf
Return


//-----------------------------------------------------------------------------
/*/{Protheus.doc} remDeleted

@description Remove linhas deletadas de um grid MVC

@author	Vitor kwon
@since	21/11/2022
/*/
//------------------------------------------------------------------------------
Static Function remDeleted(oMdlGrid, cTable, oMdlChild, cTbChild)
Local nX
Local nY
Local nZ
Local nK
Local aValues := {}
Local aValChild := {}
Local aAux := AT190DDef(cTable)
Local aAuxChild := {}
Local aResChild := {}
Local aCpos := {}
Local aCposChild := {}
Local lExecuta := .F.

Default oMdlChild := NIL
Default cTbChild := ""

For nX := 1 To oMdlGrid:Length()
	oMdlGrid:GoLine(nX)
	If (lExecuta := oMdlGrid:isDeleted())
		Exit
	EndIf
Next nX

If lExecuta
	For nX := 1 To oMdlGrid:Length()
		aCpos := {}
		oMdlGrid:GoLine(nX)
		If !oMdlGrid:isDeleted()
			For nY := 1 TO LEN(aAux)
				AADD(aCpos, { aAux[nY][DEF_IDENTIFICADOR] ,oMdlGrid:GetValue(aAux[nY][DEF_IDENTIFICADOR])})
			Next nY
			If !EMPTY(cTbChild)
				aAuxChild := AT190DDef(cTbChild)
				aValChild := {}
				For nZ := 1 To oMdlChild:Length()
					oMdlChild:GoLine(nZ)
					aCposChild := {}
					For nY := 1 TO LEN(aAuxChild)
						AADD(aCposChild, { aAuxChild[nY][DEF_IDENTIFICADOR] ,oMdlChild:GetValue(aAuxChild[nY][DEF_IDENTIFICADOR]) })
					Next nY
					AADD(aValChild, aCposChild)
				Next nZ
				AADD(aResChild, aValChild)
			EndIF
			AADD(aValues, aCpos)

		ElseIf !Empty(aAlocRES) .AND. cTable == "GRE"
			For nY := 1 TO LEN(aAlocRES)
				If VALTYPE(aAlocRES[nY]) == 'O'
					If aAlocRES[nY]:defCob() == (oMdlGrid:GetValue("GRE_TIPOAL") == '2') .AND.;
							aAlocRES[nY]:defEscala() == oMdlGrid:GetValue("GRE_ESCALA") .AND.;
							aAlocRES[nY]:defPosto() == oMdlGrid:GetValue("GRE_CODTFF") .AND.;
							aAlocRES[nY]:defSeq() == oMdlGrid:GetValue("GRE_SEQ") .AND.;
							aAlocRES[nY]:defTec() == oMdlGrid:GetValue("GRE_CODTEC") .AND.;
							aAlocRES[nY]:defGrupo() == oMdlGrid:GetValue("GRE_GRUPO") .AND.;
							aAlocRES[nY]:defConfal() == oMdlGrid:GetValue("GRE_CONFAL") .AND.;
							aAlocRES[nY]:defDate()[1] == oMdlGrid:GetValue("GRE_DTINI") .AND.;
							aAlocRES[nY]:defDate()[2] == oMdlGrid:GetValue("GRE_DTFIM")
						If TecXHasEdH()
							If aAlocRES[nY]:defGeHor()[1][1] == oMdlGrid:GetValue("GRE_ENTRA1") .AND.;
									aAlocRES[nY]:defGeHor()[1][2] == oMdlGrid:GetValue("GRE_SAIDA1") .AND.;
									aAlocRES[nY]:defGeHor()[2][1] == oMdlGrid:GetValue("GRE_ENTRA2") .AND.;
									aAlocRES[nY]:defGeHor()[2][2] == oMdlGrid:GetValue("GRE_SAIDA2") .AND.;
									aAlocRES[nY]:defGeHor()[3][1] == oMdlGrid:GetValue("GRE_ENTRA3") .AND.;
									aAlocRES[nY]:defGeHor()[3][2] == oMdlGrid:GetValue("GRE_SAIDA3") .AND.;
									aAlocRES[nY]:defGeHor()[4][1] == oMdlGrid:GetValue("GRE_ENTRA4") .AND.;
									aAlocRES[nY]:defGeHor()[4][2] == oMdlGrid:GetValue("GRE_SAIDA4")
								aAlocRES[nY]:deActivate()
							EndIf
						Else
							aAlocRES[nY]:deActivate()
						EndIf
					EndIf
				EndIf
			Next nY
		EndIf
	Next nX

	oMdlGrid:ClearData()
	oMdlGrid:InitLine()

	For nX := 1 TO LEN(aValues)
		If nX != 1
			oMdlGrid:AddLine()
		EndIf
		For nY := 1 TO LEN(aValues[nX])
			oMdlGrid:LoadValue(aValues[nX][nY][1], aValues[nX][nY][2])
		Next nY
		If !EMPTY(cTbChild)
			For nZ := 1 TO LEN(aResChild[nX])
				If nZ != 1
					oMdlChild:AddLine()
				EndIf
				For nK := 1 To LEN(aResChild[nX][nZ])
					oMdlChild:LoadValue(aResChild[nX][nZ][nK][1], aResChild[nX][nZ][nK][2])
				Next nK
			Next nZ
		EndIf
	Next nX
EndIf

oMdlGrid:GoLine(1)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At190jYAgen

@description Executa a alocação de acordo com os dados na RES

@author	Vitor
@since	19/11/2022
/*/
//------------------------------------------------------------------------------
Function At190jYAgen()
Local oModel := FwModelActive()
Local oMdlGRE := oModel:GetModel("RESDETAIL")
Local oMdlRTE := oModel:GetModel("RTEDETAIL")
Local oView := FwViewActive()
Local oDlg := nil
Local oSayMtr := nil
Local oMeter := nil
Local nMeter := 0
Local cMsg	 := ""

	oMdlRTE:SetNoInsertLine(.F.)
	oMdlRTE:SetNoDeleteLine(.F.)
	If checkGRE(@cMsg) //Valida as linhas da LGY
		FwMsgRun(Nil,{|| remDeleted(@oMdlGRE, "GRE", @oMdlRTE, "RTE")}, Nil, STR0108) //"Iniciando a projeção . . ."

		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0109 Style 128 //"Projetar alocações"
			oSayMtr := tSay():New(10,10,{||STR0110},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde..."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},oMdlGRE:Length(),oDlg,220,10,,.T.)

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (At190jPrjLAC(@oDlg,@oMeter,cMsg))

		oMdlGRE:GoLine(1)
	EndIf

	oMdlRTE:SetNoInsertLine(.T.)
	oMdlRTE:SetNoDeleteLine(.T.)

	FwModelActive(oModel)

	oMdlRTE:GoLine(1)

	oView:Refresh("DETAIL_RES")
	oView:Refresh("DETAIL_RTE")

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} At190jYCmt

@description Grava as agendas instanciadas em GsAloc

@author	Vitor Kwon
@since	01/12/2022
/*/
//------------------------------------------------------------------------------
Function At190jYCmt()
Local oDlg := nil
Local oSayMtr := nil
Local oMeter := NIL
Local oView := FwViewActive()
Local nMeter := 0

		DEFINE MSDIALOG oDlg FROM 0,0 TO 5,60 TITLE STR0129 Style 128
			oSayMtr := tSay():New(10,10,{||STR0130},oDlg,,,,,,.T.,,,220,20) //"Processando, aguarde...."
			oMeter  := tMeter():New(20,10,{|u|if(Pcount()>0,nMeter:=u,nMeter)},LEN(aAlocRES),oDlg,220,10,,.T.)

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (GravRES(@oDlg,@oMeter))

	oView:Refresh("DETAIL_RES")
	oView:Refresh("DETAIL_RTE")

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GravRES

@description Executa o save das agendas dentro de uma barra de progresso

@author	Vitor kwon
@since	 29/11/2022
/*/
//------------------------------------------------------------------------------
Static Function GravRES(oDlg,oMeter)
Local nX
Local nY
Local nCount := 0
Local nPos := 0
Local oModel := FwModelActive()
Local oMdlRES := oModel:GetModel("RESDETAIL")
Local oMdlRTE := oModel:GetModel("RTEDETAIL")
Local lLoadBar := .F.
Local lContinua := .T.
Local lAlocConf := .F.
Local nAviso := 0
Default oDlg := nil
Default oMeter := nil

lLoadBar := !isBlind() .AND. oMeter != nil .AND. oDlg != nil

For nX := 1 To oMdlRES:Length()
	oMdlRES:GoLine(nX)
	If oMdlRES:GetValue("GRE_STATUS") == "BR_PRETO"
		nAviso := Aviso(STR0124,; //Atenção
				STR0125,; //"Um ou mais dias possuem conflito de alocação. Deseja alocar todos os atendentes mesmo com os conflitos ou alocar apenas nos dias disponíveis? Esta opção será aplicada em todos os atendentes."
				{STR0126,; //"Apenas disponiveis"
				STR0127,; //"Todos os dias"
				STR0128},2) //
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

For nX := 1 To oMdlRES:Length()
	oMdlRES:GoLine(nX)
	If oMdlRES:GetValue("GRE_STATUS") == "BR_PINK"
		lContinua := MsgYesNo(STR0123) //"Um ou mais atendentes possuem restrições no período. Deseja continuar?"
		Exit
	EndIf
Next nX


If lContinua
	For nX := 1 To oMdlRES:Length()
		nPos := 0
		oMdlRES:GoLine(nX)
		For nY := 1 TO Len(aAlocRES)
			If VALTYPE(aAlocRES[nY]) == 'O' .AND.;
					aAlocRES[nY]:defCob() == (oMdlRES:GetValue("GRE_TIPOAL") == '2') .AND.;
					aAlocRES[nY]:defEscala() == oMdlRES:GetValue("GRE_ESCALA") .AND.;
					aAlocRES[nY]:defPosto() == oMdlRES:GetValue("GRE_CODTFF") .AND.;
					aAlocRES[nY]:defSeq() == oMdlRES:GetValue("GRE_SEQ") .AND.;
					aAlocRES[nY]:defTec() == oMdlRES:GetValue("GRE_CODTEC") .AND.;
					aAlocRES[nY]:defGrupo() == oMdlRES:GetValue("GRE_GRUPO") .AND.;
					aAlocRES[nY]:defConfal() == oMdlRES:GetValue("GRE_CONFAL") .AND.;
					aAlocRES[nY]:defDate()[1] == oMdlRES:GetValue("GRE_DTINI") .AND.;
					aAlocRES[nY]:defDate()[2] == oMdlRES:GetValue("GRE_DTFIM")
				If TecXHasEdH()
					If aAlocRES[nY]:defGeHor()[1][1] == oMdlRES:GetValue("GRE_ENTRA1") .AND.;
							aAlocRES[nY]:defGeHor()[1][2] == oMdlRES:GetValue("GRE_SAIDA1") .AND.;
							aAlocRES[nY]:defGeHor()[2][1] == oMdlRES:GetValue("GRE_ENTRA2") .AND.;
							aAlocRES[nY]:defGeHor()[2][2] == oMdlRES:GetValue("GRE_SAIDA2") .AND.;
							aAlocRES[nY]:defGeHor()[3][1] == oMdlRES:GetValue("GRE_ENTRA3") .AND.;
							aAlocRES[nY]:defGeHor()[3][2] == oMdlRES:GetValue("GRE_SAIDA3") .AND.;
							aAlocRES[nY]:defGeHor()[4][1] == oMdlRES:GetValue("GRE_ENTRA4") .AND.;
							aAlocRES[nY]:defGeHor()[4][2] == oMdlRES:GetValue("GRE_SAIDA4")
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
			If !(oMdlRES:isDeleted())
				aAlocRES[nPos]:alocaConflitos(lAlocConf)
				If aAlocRES[nPos]:gravaAloc()
					oMdlRES:LoadValue("GRE_STATUS","BR_VERDE")
					If !Empty(aAlocRES[nPos]:getLastSeq())
						oMdlRES:LoadValue("GRE_SEQ",aAlocRES[nPos]:getLastSeq())
					EndIf
				Else
					oMdlRES:LoadValue("GRE_STATUS","BR_LARANJA")
				EndIf
				oMdlRES:LoadValue("GRE_DETALH",LEFT(aAlocRES[nPos]:defMessage(), 185))
			EndIf
			oMdlRTE:GoLine(1)
			oMdlRTE:ClearData()
			oMdlRTE:InitLine()
		EndIf
		If lLoadBar
			oMeter:Set(++nCount)
			oMeter:Refresh()
		EndIf
	Next nX

	For nX := 1 To LEN(aAlocRES)
		If VALTYPE(aAlocRES[nX]) == 'O'
			aAlocRES[nX]:destroy()
			aAlocRES[nX] := nil
		EndIf
	Next nX
	aAlocRES := {}
Else
	MsgAlert(STR0122) //"Operação Cancelada"
EndIf

If lLoadBar
	oDlg:End()
EndIf

At190dDtPj(,.T.)
Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At190JSeq
@description Verifica se a sequencia escolhida é valida
@author Vitor kwon
@since  23/11/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At190JSeq(cSeq)
Local lRet		:= .T.
Local cAliasQry := GetNextAlias()
Local cQry		:= ""

cQry := " SELECT 1 FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.D_E_L_E_T_ = ' ' AND TDX.TDX_FILIAL = '" +  xFilial('TDX') + "' AND "
cQry += " TDX.TDX_CODTDW = '" + FwFldGet("GRE_ESCALA") + "' "
cQry += " AND TDX.TDX_SEQTUR = '" + cSeq + "' "

cQry := ChangeQuery(cQry)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)

If (cAliasQry)->(EOF())
	lRet := .F.
EndIf

(cAliasQry)->(DbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AT190JConfal
@description  Verifica se existe registro na tabela TDX
@return lRet
@author Vitor Kwon
@since  23/11/2022
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function AT190JConfal(xValue)
Local cQry
Local lRet := .T.
Local cAliasQry := GetNextAlias()

cQry := " SELECT 1 "
cQry += " FROM " + RetSqlName("TDX") + " TDX "
cQry += " WHERE TDX.TDX_FILIAL = '" +  xFilial('TDX') + "' AND "
cQry += " TDX.D_E_L_E_T_ = ' ' "
cQry += " AND TDX.TDX_COD = '" + xValue + "' "

cQry := ChangeQuery(cQry)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cAliasQry, .F., .T.)

If (cAliasQry)->(EOF())
	lRet := .F.
EndIf

(cAliasQry)->(DbCloseArea())

Return  lRet
Static Function checkGRE(cMsg)
Local oModel 		:= FwModelActive()
Local oMdglGRE 		:= oModel:GetModel("RESDETAIL")
Local aSaveLines 	:= FWSaveRows( oModel )
Local lRet 			:= .T.
Local nX            := 0

Default cMsg		:= ""

If lRet
	For nX := 1 To oMdglGRE:Length()
		oMdglGRE:GoLine(nX)

		If (Empty(oMdglGRE:GetValue("GRE_CODTFF")) .OR.;
				Empty(oMdglGRE:GetValue("GRE_GRUPO")) .OR.;
				Empty(oMdglGRE:GetValue("GRE_DTINI")) .OR.;
				Empty(oMdglGRE:GetValue("GRE_DTFIM")) .OR.;
				Empty(oMdglGRE:GetValue("GRE_SEQ")) .OR.;
				Empty(oMdglGRE:GetValue("GRE_ESCALA")) .OR.;
				Empty(oMdglGRE:GetValue("GRE_TIPTCU"));
			)
			oMdglGRE:LoadValue("GRE_DETALH", STR0144) //"Os campos 'Posto', 'Escala', 'Sequência' ,'Grupo' e o Período de Alocação são obrigatórios para a projeção da agenda"
			oMdglGRE:LoadValue("GRE_STATUS", "BR_CANCEL")
			Loop
		EndIf

	Next nX
EndIf
FWRestRows( aSaveLines )
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At190JRev
Função utilizada para preencher o campo de revisão do contrato selecionado
@author	Breno.gomes
@since	26/03/2025
@param cRevisa - código da revisão do contrato
@param oModel - Modelo

@return Nil
/*/
//------------------------------------------------------------------------------
Static Function At190JRev(cRevisa, oModel)
Local lExstRev    := TFQ->(ColumnPos("TFQ_CONREV")) > 0

If lExstRev .And. ValType(oModel) == "O" .And. IsInCallStack("TECA880")
	oModel:GetModel("TFQMASTER"):SetValue("TFQ_CONREV", cRevisa)
EndIf

Return
