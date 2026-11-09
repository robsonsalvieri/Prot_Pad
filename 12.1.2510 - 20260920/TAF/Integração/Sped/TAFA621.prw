#include 'totvs.ch'
#include 'PROTHEUS.CH'
#include 'TAFA621.CH'

#DEFINE cTAF_USER_ADMIN "000000"
#DEFINE cTAF_MSG_INATV  "Usuario informado em MV_TAFUSCH esta inativo. Assumido o usuario Administrador: "
#DEFINE cTAF_MSG_NEXST  "Usuario informado em MV_TAFUSCH nao existe. Assumido o usuario Administrador: "
#DEFINE cTAF_MSG_NOACC  "Usuario informado em MV_TAFUSCH inconsistente ou nao atende ao pré-requisito. Assumido o usuario Administrador: "

/*----------------------------------------------------------------------
{Protheus.doc} TAFA621
Essa programa é responsavel por chamar a função principal de integração
dos dos dados entre os modulos Escrita fiscal e TAF. O mesmo teve que ser 
criado como .prw porque nele é usada a função Scheddef() e a mesma, até 
então não estava funcionado em fontes .tlpp

@author Carlos Eduardo Nonato
@since 21/02/2024
//----------------------------------------------------------------------*/
Function TAFA621()
	TAFInitInt()
Return

/*--------------------------------------------------------------------------
{Protheus.doc} TAFExecInt
Função chamada no fonte TAFA613 onde é feita a validação se foi aplicado 
o pacote de dados e se foi criado os campos STAMP corretamente para iniciar 
a integração 
@author adilson.roberto
@return	lRet 
@since 21/02/2024
//------------------------------------------------------------------------*/
Function TAFExecInt()
Local lRet := .f.
Local xMV_TAFISCH := GetMV('MV_TAFISCH',, '0' ) 

//Valida tipo e conteudo do parâmetro MV_TAFISCH
do case
	case ValType( xMV_TAFISCH ) == 'C'
		lRet := iif( xMV_TAFISCH == '1', .t., .f. )
	case ValType( xMV_TAFISCH ) == 'L'
		lRet := .F.
endcase

//Valida se os campos necessarios para integração na tabela C20 foram criados
if lRet; lRet := CanInitProcess(); endif

//Valida se o campo s_t_a_m_p_ foi criado nas tabelas usadas na integração
if lRet; lRet := TAFChkInt(); endif


Return lRet

/*-------------------------------------------------------------------------------
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Carlos Eduardo Nonato
@since 21/02/2024
--------------------------------------------------------------------------------*/
Static Function Scheddef()
Local aParam := {}

aParam := {'P', 'PARAMDEF', '', {}, '', '', .T., .F.}

Return aParam

/*--------------------------------------------------------------------------------*/
/*/{Protheus.doc} CanInitProcess
@description Função para validar se o processo de integração dos documentos fiscais pode ser executado
@type static function
@author Adilson Roberto
@since 25/04/2023
@version 1.0
@return	lChkCpC20 
/*--------------------------------------------------------------------------------*/
Static Function CanInitProcess() 

Local lChkCpC20 := .F. as logical

	lChkCpC20 := FWBulk():CanBulk() .And. TAFColumnPos("C20_CLIFOR") .And.;
					TAFColumnPos("C20_LOJA") .And. TAFColumnPos("C20_HORMIS") .And. TAFColumnPos("C20_ESPECI") .And.;
					TAFColumnPos("C20_ATUDOC")

Return lChkCpC20

/*----------------------------------------------------------------------
{Protheus.doc} TafContScd
Função que fará a validação se o Schedule esta ativo e em execução 

@author adilson.roberto
@since 24/07/2024
@return	lRetScd 
//----------------------------------------------------------------------*/
Function TafContScd()
	Local aAmbientes:= {} as Array
	Local cAmbiente:= "" as character
	Local oScheduleInfo as object

	oScheduleInfo   := totvs.framework.schedule.information.ScheduleInformation():New()
	aAmbientes := oScheduleInfo:getEnvironmentsScheduleRunning(2) // Retorna quais ambientes tem Smart Schedule rodando

	If Len(aAmbientes)>0
		cAmbiente := aAmbientes[1]
	Else
		TAFConout(STR0001)	//SmartSchedule não esta ativo ou habilitado, favor contate o administrador!
	EndIf

Return cAmbiente

/*----------------------------------------------------------------------
{Protheus.doc} TAFChkInt
Função que fará a validação se os campos de STAMP foram criados corretamente.
Caso contrário não será executado a integração.

@author Carlos Eduardo Nonato
@since 21/02/2024
//----------------------------------------------------------------------*/
Static Function TAFChkInt()

Local aTablesInt	 := getTblTSI() as array
Local lCreatedFields := .t. as logical
Local cMsgStamp		 as character

//Verifica se o campo s_t_a_m_p_ foi criado para as tabelas que serão integradas.
if Ascan( TCStruct(RetSqlName( aTablesInt[ len(aTablesInt) ] )), {|x| x[1] == 'S_T_A_M_P_' }) == 0
    lCreatedFields := totvs.protheus.backoffice.taf.setupIntegration.IntAtiva( @cMsgStamp )
endif

//Mensagem de falha\sucesso na criação dos campos stamp.
TAFConOut(@cMsgStamp)	 

return lCreatedFields

/*----------------------------------------------------------------------
{Protheus.doc} TafUsrSchd
	Retorna o codigo do usuario que deve ser utilizado na abertura das tasks
	das integracoes do TAF via Smart Schedule.

	Le o parametro MV_TAFUSCH e valida o codigo informado: existencia
	no cadastro de usuarios e situacao (nao inativo/bloqueado).
	Quando o parametro nao existe, esta em branco ou aponta
	para um usuario invalido, retorna o codigo do usuario Administrador
	("000000") e registra o motivo na tabela T01, sem interromper a integracao.

	A existencia e a situacao do usuario sao obtidas em uma unica chamada a
	FWSFAllUsers, que retorna {{RecNo, Id, <campos solicitados>}, ...}. O
	campo USR_MSBLQL igual a "1" indica usuario bloqueado/inativo.

	Esta e a UNICA forma suportada de obter o usuario das tasks do TAF.

	@type      function
	@author    Caique Carlos
	@since     13/08/2026
	@version   1.0
	@return    cUsuario, character, codigo do usuario (6 posicoes) para a task
//----------------------------------------------------------------------*/
Function TafUsrSchd()
	Local aAcesso  := {}                 as array
	Local aUsuario := {}                 as array
	Local cMsgLog  := ""                 as character
	Local cUsuario := cTAF_USER_ADMIN    as character
	Local cUsrPar  := AllTrim(SuperGetMV("MV_TAFUSCH", .F., "")) as character

	If Empty(cUsrPar)
		Return cUsuario
	EndIf

	//Ret: aUsuario[n][1] = RecNo / [2] = Id do usuario / [3] = USR_MSBLQL
	aUsuario := FWSFAllUsers({cUsrPar}, {'USR_MSBLQL'})

	If !(ValType(aUsuario) == "A" .and. Len(aUsuario) > 0)
		cMsgLog := cTAF_MSG_NEXST
	ElseIf ValType(aUsuario[1][3]) == "C" .And. aUsuario[1][3] == "1"
		cMsgLog := cTAF_MSG_INATV
	EndIf

	If Empty(cMsgLog)
		cUsuario := cUsrPar
	Else
		TafLogUsr(cMsgLog)
	EndIf

	FwFreeArray(aAcesso)
	FwFreeArray(aUsuario)

Return cUsuario

/*----------------------------------------------------------------------
{Protheus.doc} TafLogUsr
	Registra na tabela T01 o motivo pelo qual o usuario informado em
	MV_TAFUSCH foi descartado e o Administrador foi assumido na abertura da
	task do Smart Schedule.

	@type      static function
	@author    Caique Carlos
	@since     13/08/2026
	@version   1.0
	@param     cMsg, character, mensagem a ser registrada
	@return    Nil
//----------------------------------------------------------------------*/
Static Function TafLogUsr(cMsg as character)
	Local aDadosLog := {} 		 	as array
	Local cFunc     := "LogIntegra" as character
	Local cMainMsg  := "Não foi possível utilizar usuário da MV_TAFUSCH." as character

	Default cMsg := ""

	Private oStPesquisaLog := Nil

	DbSelectArea("T01")

	aDadosLog := {"SX6", "MV_TAFUSCH", "", cMsg, .F.}

	tlpp.call(cFunc, aDadosLog, "", cMainMsg)

	TAFConout(cMainMsg + cMsg)

	FwFreeArray(aDadosLog)
Return
