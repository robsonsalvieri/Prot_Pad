//----------------------------------------------------------
/*/{Protheus.doc} CRMDEF()
 
Fonte que reuni todos os Defines do modulo CRM
Criado para evitar repetiçções de define, impor um padrão para o desenvolvimento

@param	   nehnum
       
@return   verdadeiro/falso

@author   Victor Bitencourt
@since    26/02/2014
@version  12.0
/*/
//----------------------------------------------------------

// Array de informações do usuario do exchange
#DEFINE _PREFIXO    2
#DEFINE _LCRMUSR    3
#DEFINE _Usuario    1
#DEFINE _SenhaUser  2 
#DEFINE _Agenda     3
#DEFINE _DtAgeIni   4
#DEFINE _DtAgeFim   5
#DEFINE _Tarefa     6
#DEFINE _DtTarIni   7
#DEFINE _DtTarFim   8
#DEFINE _EndEmail   9
#DEFINE _Contato    10
#DEFINE _Habilita   11
#DEFINE _TipoPerAge 12
#DEFINE _TipoPerTar 13
#DEFINE _TimeMin    14
#DEFINE _BiAgenda   15
#DEFINE _BiTarefa   16
#DEFINE _BiContato  17	

//Status existentes para Atividades
#DEFINE STNAOINICIADO  "1" 
#DEFINE STEMANDAMENTO  "2"
#DEFINE STCONCLUIDO    "3"
#DEFINE STAGUADOUTROS  "4"
#DEFINE STADIADA       "5"
#DEFINE STPENDENTE     "6"
#DEFINE STENVIADO      "7"
#DEFINE STLIDO         "8"

//Tipos de Atividades
#DEFINE TPTAREFA       "1"
#DEFINE TPCOMPROMISSO  "2"
#DEFINE TPEMAIL        "3"

//Rotinas 
#DEFINE RESPECIFICACAO   1
#DEFINE RATIVIDADE       2
#DEFINE RCONEXAO         3
#DEFINE RANOTACOES       4
#DEFINE REMAIL           5
#DEFINE RCEMAIL          6

// Parâmetros dos Filtros 
#DEFINE ADDFIL_TITULO		1	// Título que será exibido no filtro.
#DEFINE ADDFIL_EXPR			2	// Expressão do filtro em AdvPL ou SQL ANSI.
#DEFINE ADDFIL_NOCHECK		3	// Indica que o filtro não poderá ser marcado/desmarcado.
#DEFINE ADDFIL_SELECTED		4	// Indica que o filtro deverá ser apresentado como marcado/desmarcado. 
#DEFINE ADDFIL_ALIAS			5	// Indica que o filtro é de relacionamento entre as tabelas.
#DEFINE ADDFIL_FILASK		6	// Indica se o filtro pergunta as informações na execução.
#DEFINE ADDFIL_FILPARSER		7	// Array contendo informações parseadas do filtro. 
#DEFINE ADDFIL_ID				8	// Nome do identificador do filtro.

