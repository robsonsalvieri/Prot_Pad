#include 'totvs.ch'
#include 'dmsapimessages.ch'

class OFIMensagensPadrao from LongNameClass
	public data ERR_SEM_PERMISSAO
	public data ERR_ID_NAO_INFORMADO
	public data ERR_SEM_PERMISSAO_DESCONTO
	public data ERR_SEM_PERMISSAO_APROVAR_ATENDIMENTO
	public data ERR_DADOS_NAO_ENCONTRADOS
	public data ERR_ERRO_LIBERACAO_DESCONTO
	public data ERR_ERRO_LIBERACAO
	public data ERR_ERRO_CONCLUSAO_REJEICAO
	public data ERR_PECAS_APROVACAO
	public data ERR_SERVICOS_APROVACAO_NAO_ENCONTRADOS
	public data ERR_SEM_ALCADA
	public data ERR_REABERTURA
	public data ERR_ERRO_LIBERA
	public data ERR_BAD_REQUEST
	public data SUCCESS_APROVACAO
	public data SUCCESS_REQUEST_CONCLUIDO
	public data ERR_APROVACAO_NAO_ENCONTRADA
	public data ERR_SEM_PERMISSAO_REPROVAR_ATENDIMENTO
	public data ERR_SEM_ACESSO_EMPRESA_FILIAL
	public data ERR_CONFIGURACAO_NAO_ENCONTRADA

	public method new() constructor
endClass

Method new() class OFIMensagensPadrao
	::ERR_SEM_PERMISSAO := STR0001 //Usuário não possui permissão para o acesso a essa rotina
	::ERR_SEM_PERMISSAO_APROVAR_ATENDIMENTO := STR0002 //Usuário não possui permissão para aprovar o atendimento
	::ERR_ID_NAO_INFORMADO := STR0003 //Erro, id não foi informado
	::ERR_SEM_PERMISSAO_DESCONTO := STR0004 //Atenção, usuário não autorizado a realizar liberações ou reprovações de desconto
	::ERR_DADOS_NAO_ENCONTRADOS := STR0005 //Nenhum registro foi encontrado
	::ERR_ERRO_LIBERACAO_DESCONTO := STR0006 //"Erro ao liberar desconto"
	::ERR_ERRO_LIBERACAO := STR0007 //Erro ao liberar
	::ERR_ERRO_CONCLUSAO_REJEICAO := STR0008 //Não foi possível concluir a rejeição no momento
	::ERR_PECAS_APROVACAO := STR0009 //Não foi possível buscar as peças para aprovação
	::ERR_SERVICOS_APROVACAO_NAO_ENCONTRADOS := STR0010 //Não foi possível buscar os serviços da aprovação
	::ERR_SEM_ALCADA := STR0011 //Alcada de crédito não é suficiente para essa liberação
	::ERR_REABERTURA := STR0012 //Nao foi possivel realizar a reabertura no momento
	::ERR_ERRO_LIBERA := STR0013 //Nao foi não foi possivel concluir a liberação
	::ERR_BAD_REQUEST := STR0014 //Ocorreu um erro ao processar a requisicao
	::SUCCESS_REQUEST_CONCLUIDO := STR0015 //Concluído com sucesso!
	::SUCCESS_APROVACAO := STR0016 //Aprovação concluída com sucesso!
	::ERR_APROVACAO_NAO_ENCONTRADA := STR0017 //Aprovação não encontrada.
	::ERR_SEM_PERMISSAO_REPROVAR_ATENDIMENTO := STR0018 //Usuário não possui permissão para reprovar o atendimento
	::ERR_SEM_ACESSO_EMPRESA_FILIAL := STR0019 //Usuário sem acesso a empresa/filial.
	::ERR_CONFIGURACAO_NAO_ENCONTRADA := STR0020 //Nenhuma configuração encontrada.
return self

