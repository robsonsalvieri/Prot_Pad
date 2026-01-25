#INCLUDE "PROTHEUS.CH"

#XCOMMAND REGISTER INSIGHT <cInsightName>;
	=>;
   Function <cInsightName>_PI_();;
   Return nil

//-------------------------------------------------------------------
// STATUS DA TABELA DE CONFIGURAÇÃO
//-------------------------------------------------------------------
#DEFINE CONFIG_DISABLE  '0'
#DEFINE CONFIG_ENABLE	'1'


//-------------------------------------------------------------------
// Códigos de erro
//-------------------------------------------------------------------

//-------------------------------------------------------------------
// Generic error
//-------------------------------------------------------------------
#Define INSIGHTSERROR_GENERIC_ERRROR -1

//-------------------------------------------------------------------
// Platform errors
//-------------------------------------------------------------------
#Define INSIGHTSERROR_OPEN_TABLE_ERROR -2
#Define INSIGHTSERROR_PARAMETER_NOT_PRESENT -3
#Define INSIGHTSERROR_REGISTER_NOT_FOUND -4
#Define INSIGHTSERROR_BAD_FORMAT_PARAMETER -5

//-------------------------------------------------------------------
// CONTROLA AS VERSÕES MÍNIMAS DOS PACOTES
//-------------------------------------------------------------------
#DEFINE INSIGHT_LIB        "20250811"
#DEFINE INSIGHT_SMARTLINK  "2.6.5"

//-------------------------------------------------------------------
// Códigos de status para gravação na tabela I21
//-------------------------------------------------------------------
#DEFINE GENERATED   'GEN'
#DEFINE DISCARD	   'DSC'

//-------------------------------------------------------------------
// Indica a versão do pacote de expedição contínua do Protheus Insights
//-------------------------------------------------------------------
#DEFINE INSIGHT_VERSION	   '20251008'

//-------------------------------------------------------------------
// Definição das versões de arquitetura do Protheus Insights
//-------------------------------------------------------------------
#DEFINE OLD_VERSION        1  // Leitura de registros da I14
#DEFINE NEW_ARCHITECTURE   2  // Leitura de registros da I21


//-------------------------------------------------------------------
// Definição com a estrutura de retorno do método Struct dos Insights da Nova Arquitetura
//-------------------------------------------------------------------
#DEFINE STRUCT_PROPERTIE    1  // Posição que indica o nome da propriedade na mensagem do insight
#DEFINE STRUCT_INFO         2  // Posição que indica  Array com a definição da propriedade na tabela temporária
#DEFINE STRUCT_SEARCH       3  // Posição que indica se o campo pode ser usado como filtro
#DEFINE STRUCT_TITLE        4  // Posição que indica o título da coluna no Header do endpoint
#DEFINE STRUCT_ORDER        5  // Posição que indica a ordem da coluna no Header do endpoint
#DEFINE STRUCT_COMPOSITE    6  // Posição que indica se a chave é composta

//-------------------------------------------------------------------
// Definição auxiliar usada na definição do método Struct dos Insights da Nova Arquitetura
//-------------------------------------------------------------------
#DEFINE STRUCT_INVISIBLE 	1000		// Colunas com esta configuração não são retornados pelo serviço.

