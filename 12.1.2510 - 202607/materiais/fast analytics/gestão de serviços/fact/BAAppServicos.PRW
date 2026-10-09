#INCLUDE "BADEFINITION.CH"

NEW APP SERVICO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppServicos
Modelagem da area de Gestao de Servicos.

@author  henrique.cesar
@since   23/03/2018
/*/
//-------------------------------------------------------------------
Class BAAppServicos
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome unico para a area. 

@author  henrique.cesar
@since   23/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppServicos
	::cApp := "Serviços"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  henrique.cesar
@since   23/03/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppServicos
Return	{   "CONTRATO", + ; //fact BAContrato
			"CONTVENDEDOR", + ; //fact BAContratVend
			"REGISTROCUSTO", + ; //fact BARegistroCusto
			"POSTOFUNC", + ; //fact BAPostoFunc
			"ATENDALOCACAO", + ; // fact BAAtendAlocacao
			"ATENDAUSENCIA", + ; // fact BAAtendAusencia
			"ATENDENTE", + ; // dimension BAAtendente
			"CALENDARIO", + ; // dimension BACalendario
			"CARGO", + ; // dimension BACargo
			"ESCALA", + ; // dimension BAEscala
			"ITEM", + ; // dimension BAItem
			"LOCALATENDIMENTO", + ; // dimension BALocalAtendimento
			"OPORTUNIDADE", + ; // dimension BAOportunidade
			"PROPOSTA", + ; // dimension BAProposta
			"RHORCAMENTO", + ; // dimension BARHOrcamento
			"TIPOCONTRATO", + ; // dimension BATipoContrato
			"CLIENTE", + ; // dimension BACliente
			"VENDEDORREPST", + ; // dimension BAVendedorRepst
			"TURNO", + ; // dimension BATurno
			"FUNCAO", + ; // dimension BAFuncao
			"MOTMANUTENCAO", + ; // dimension BAMotManutencao
			"FILIAL", + ; // dimension BAFilial
			"SITCONTRATO", + ; // dimension BASitContrato
			"SEGMENTO", + ; // dimension BASegmentos
			"REGIAO", + ; // dimension BARegiao
			"EMPRESA" + ; // dimension BAEmpresa
			"MOEDA" + ;
			"COTACAO" } 
			