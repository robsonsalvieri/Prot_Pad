#include 'protheus.ch'

static cStGrpComp	:=	GetSrvProfString( 'TAFSTByGrpCompany' , '0' ) //variável de controle que verifica se a integração será feita multi-empresa
static cSt2Name		:=	nil
static cXErpName	:=	nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSt2Name

Função criada para retornar o nome da tabela TAFST2 conforme configuração
da chave TAFSTByGrpCompany no arquivo appserver.ini
Caso a chave esteja habilitada, o nome da tabela será acrescido do código da
empresa que está operando o sistema, por exemplo TAFST2_99.
Isso se faz necessário para avaliar a carga da tabela TAFST2 pensando na utilização
do TAF in Cloud.

@return cSt2Name -> Nome da tabela TAFST2, caso a chave TAFSTByGrpCompany esteja habilitada
 					o nome será retornado acrescido do código da empresa, por exemplo
 					TAFST2_99.

@author Luccas Curcio
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFSt2Name()

if cSt2Name == nil 

	cSt2Name	:=	'TAFST2'
	
	if cStGrpComp == '1'
		cSt2Name := cSt2Name + '_' + cEmpAnt
	endif

endif

return cSt2Name

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFXErpName

Função criada para retornar o nome da tabela TAFXERP conforme configuração
da chave TAFSTByGrpCompany no arquivo appserver.ini
Caso a chave esteja habilitada, o nome da tabela será acrescido do código da
empresa que está operando o sistema, por exemplo TAFXERP_99.
Isso se faz necessário para avaliar a carga da tabela TAFXERP pensando na utilização
do TAF in Cloud.

@return cXErpName -> Nome da tabela TAFXERP, caso a chave TAFSTByGrpCompany esteja habilitada
 					 o nome será retornado acrescido do código da empresa, por exemplo
 					 TAFXERP_99.

@author Luccas Curcio
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFXErpName()

if cXErpName == nil

	cXErpName	:=	'TAFXERP'
	
	if cStGrpComp == '1'
		cXErpName := cXErpName + '_' + cEmpAnt
	endif

endif

return cXErpName

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSTByGrpComp

Verifica se o ambiente está configurado para trabalhar com as tabelas transacionais do TAF
por Grupo de Empresa.

@return lreturn ->	Indica se o ambiente está configurado para trabalhar com as tabelas transacionais do TAF
					por Grupo de Empresa.

@author Luccas Curcio
@since 03/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFSTByGrpComp()

return ( cStGrpComp == '1' )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGetPriority

Retorna array bidimensional contendo os códigos e descrições válidas para prioridades
de registros na tabela TAFST2

@return aPriority ->	Array contendo códigos e descrições válidas para prioridades de registros

@author Luccas Curcio
@since 08/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFGetPriority()

local	aPriority	as	array

aPriority := {	{ '0' , 'Urgente' 			} ,; 
				{ '1' , 'Prioridade Crítica'} ,;
				{ '2' , 'Prioridade Alta' 	} ,;
				{ '3' , 'Prioridade Média' 	} ,;
				{ '4' , 'Prioridade Baixa' 	} ,;
				{ '5' , 'Não Prioritário' 	} }

return aPriority

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIsPriority

Valida se código de prioridade enviado como parâmetro é válido.

@return lValid ->	Código válido ( .T. ) ou inválido ( .F. )

@author Luccas Curcio
@since 08/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
function TAFIsPriority( cCodePriority )

local	lValid	as	logical

lValid := aScan( TAFGetPriority() , { |x| x[1] ==  allTrim( cCodePriority ) } ) > 0

return lValid