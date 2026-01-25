#include 'totvs.ch'
#include 'PROTHEUS.CH'
#include 'TAFA621.CH'

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

aParam := {'P', 'PARAMDEF', '', {}, ''}

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
    lCreatedFields := IntAtiva( @cMsgStamp )
endif

//Mensagem de falha\sucesso na criação dos campos stamp.
TAFConOut(@cMsgStamp)	 

return lCreatedFields

