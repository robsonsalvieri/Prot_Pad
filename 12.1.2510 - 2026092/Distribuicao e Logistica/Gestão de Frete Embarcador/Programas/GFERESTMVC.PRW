#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static IsRest := .F.
 
//-------------------------------------------------------------------
/*/{Protheus.doc} GFERESTMVC

Publicação dos modelos que devem ficar disponíveis no REST.
Vide classe FwRestModel.

@author Andre Luis Wisnheski
@since 05/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Class GFERestModel From FwRestModel
    Method Activate()
    Method DeActivate()
EndClass

Method Activate() Class GFERestModel
    IsRest := .T.
Return _Super:Activate()

Method DeActivate() Class GFERestModel
    IsRest := .F.
Return _Super:DeActivate()

Function GFEIsRest()
Return IsRest 

/* Publicação dos modelos que são disponibilizados no REST */

PUBLISH MODEL REST NAME GFEA010 SOURCE GFEA010 RESOURCE OBJECT GFERestModel       // Cadastro do Contato do Emitente
PUBLISH MODEL REST NAME GFEA011 SOURCE GFEA011 RESOURCE OBJECT GFERestModel       // Cadastro do Grupo de Emitentes
PUBLISH MODEL REST NAME GFEA012 SOURCE GFEA012 RESOURCE OBJECT GFERestModel       // Cadastro de Motorista e Ajudante
PUBLISH MODEL REST NAME GFEA013 SOURCE GFEA013 RESOURCE OBJECT GFERestModel       // Cadastro de Alíquota de ICMS
PUBLISH MODEL REST NAME GFEA014 SOURCE GFEA014 RESOURCE OBJECT GFERestModel       // Cadastro de Tipos de Itens
PUBLISH MODEL REST NAME GFEA015 SOURCE GFEA015 RESOURCE OBJECT GFERestModel       // Cadastro de Emitentes de Transporte
PUBLISH MODEL REST NAME GFEA017 SOURCE GFEA017 RESOURCE OBJECT GFERestModel       // Cadastro de Espécie de Documento
PUBLISH MODEL REST NAME GFEA018 SOURCE GFEA018 RESOURCE OBJECT GFERestModel       // Cadastro de Praças de Pedágio
PUBLISH MODEL REST NAME GFEA019 SOURCE GFEA019 RESOURCE OBJECT GFERestModel       // Cadastro de Tabelas de Prazo
PUBLISH MODEL REST NAME GFEA020 SOURCE GFEA020 RESOURCE OBJECT GFERestModel       // Cadastro de Cidades
PUBLISH MODEL REST NAME GFEA021 SOURCE GFEA021 RESOURCE OBJECT GFERestModel       // Cadastro de Regioes
PUBLISH MODEL REST NAME GFEA022 SOURCE GFEA022 RESOURCE OBJECT GFERestModel       // Cadastro de Distância entre Cidades
PUBLISH MODEL REST NAME GFEA029 SOURCE GFEA029 RESOURCE OBJECT GFERestModel       // Cadastro de Frete Referência
PUBLISH MODEL REST NAME GFEA030 SOURCE GFEA030 RESOURCE OBJECT GFERestModel       // Cadastro de Tipos de Ocorrência
PUBLISH MODEL REST NAME GFEA031 SOURCE GFEA031 RESOURCE OBJECT GFERestModel       // Cadastro de Motivos de Ocorrência
PUBLISH MODEL REST NAME GFEA032 SOURCE GFEA032 RESOURCE OBJECT GFERestModel       // Cadastro de Ocorrências
PUBLISH MODEL REST NAME GFEA033 SOURCE GFEA033 RESOURCE OBJECT GFERestModel       // Cadastro de Tabelas de Prazo
PUBLISH MODEL REST NAME GFEA039 SOURCE GFEA039 RESOURCE OBJECT GFERestModel       // Cadastro de Observações do Contrato de Transporte
PUBLISH MODEL REST NAME GFEA041 SOURCE GFEA041 RESOURCE OBJECT GFERestModel		  // Cadastro de Tipos de Documentos de Carga
PUBLISH MODEL REST NAME GFEA042 SOURCE GFEA042 RESOURCE OBJECT GFERestModel		  // Cadastro de Classificação de Frete
PUBLISH MODEL REST NAME GFEA043 SOURCE GFEA043 RESOURCE OBJECT GFERestModel		  // Cadastro de Unitizadores de Carga
PUBLISH MODEL REST NAME GFEA044 SOURCE GFEA044 RESOURCE OBJECT GFERestModel		  // Documentos de Cargas
PUBLISH MODEL REST NAME GFEA045 SOURCE GFEA045 RESOURCE OBJECT GFERestModel       // Cadastro de Tipo de Veículo
PUBLISH MODEL REST NAME GFEA046 SOURCE GFEA046 RESOURCE OBJECT GFERestModel       // Cadastro de Veículos
PUBLISH MODEL REST NAME GFEA047 SOURCE GFEA047 RESOURCE OBJECT GFERestModel       // Cadastro de Tipo de Operação
PUBLISH MODEL REST NAME GFEA048 SOURCE GFEA048 RESOURCE OBJECT GFERestModel       // Cadastro de Filtro de Documento de Carga
PUBLISH MODEL REST NAME GFEA049 SOURCE GFEA049 RESOURCE OBJECT GFERestModel       // Cadastro de Exceção de Item Embarcador
PUBLISH MODEL REST NAME GFEA059 SOURCE GFEA059 RESOURCE OBJECT GFERestModel       // Requisição de Negociação de Frete
PUBLISH MODEL REST NAME GFEA060 SOURCE GFEA060 RESOURCE OBJECT GFERestModel       // Cadastro de Componente de Frete
PUBLISH MODEL REST NAME GFEA063 SOURCE GFEA063 RESOURCE OBJECT GFERestModel       // Cadastro de Aprovadores da Tabela de Frete
PUBLISH MODEL REST NAME GFEA064 SOURCE GFEA064 RESOURCE OBJECT GFERestModel       // Cadastro de Aprovação da Tabela de Frete
PUBLISH MODEL REST NAME GFEA068 SOURCE GFEA068 RESOURCE OBJECT GFERestModel       // Cadastro da Tabela de Taxa Suframa
PUBLISH MODEL REST NAME GFEA079 SOURCE GFEA079 RESOURCE OBJECT GFERestModel       // Contratos de Transporte
PUBLISH MODEL REST NAME GFEA080 SOURCE GFEA080 RESOURCE OBJECT GFERestModel       // Cadastro de Conversoes de Unidade de Medida
PUBLISH MODEL REST NAME GFEA083 SOURCE GFEA083 RESOURCE OBJECT GFERestModel       // Cadastro de Relacionamento da Tabela x Contrato
PUBLISH MODEL REST NAME GFEA084 SOURCE GFEA084 RESOURCE OBJECT GFERestModel       // Frete Combinado
PUBLISH MODEL REST NAME GFEA089 SOURCE GFEA089 RESOURCE OBJECT GFERestModel       // Cadastro de Centro de Custo
PUBLISH MODEL REST NAME GFEA090 SOURCE GFEA090 RESOURCE OBJECT GFERestModel       // Cadastro de Contas Contabeis
PUBLISH MODEL REST NAME GFEA092 SOURCE GFEA092 RESOURCE OBJECT GFERestModel       // Cadastro de Contas Contabeis x Centro de Custo
PUBLISH MODEL REST NAME GFEA096 SOURCE GFEA096 RESOURCE OBJECT GFERestModel       // Lotes de Provisão
PUBLISH MODEL REST NAME GFEA103 SOURCE GFEA103 RESOURCE OBJECT GFERestModel       // Cadastro de Tabela de IR
PUBLISH MODEL REST NAME GFEA120 SOURCE GFEA120 RESOURCE OBJECT GFERestModel       // Cadastro de Tipos de Serviço de Frete
PUBLISH MODEL REST NAME GFEA510 SOURCE GFEA510 RESOURCE OBJECT GFERestModel       // Cadastro de Operações
PUBLISH MODEL REST NAME GFEA511 SOURCE GFEA511 RESOURCE OBJECT GFERestModel       // Cadastro de Visitantes
PUBLISH MODEL REST NAME GFEA512 SOURCE GFEA512 RESOURCE OBJECT GFERestModel       // Cadastro de Recorrencia
PUBLISH MODEL REST NAME GFEA513 SOURCE GFEA513 RESOURCE OBJECT GFERestModel       // Cadastro de Restriçoes
PUBLISH MODEL REST NAME GFEA514 SOURCE GFEA514 RESOURCE OBJECT GFERestModel       // Cadastro de Endereços de Mercadoria
PUBLISH MODEL REST NAME GFEA515 SOURCE GFEA515 RESOURCE OBJECT GFERestModel       // Cadastro de Ponto de Controle
PUBLISH MODEL REST NAME GFEA516 SOURCE GFEA516 RESOURCE OBJECT GFERestModel       // Cadastro de Perguntas
PUBLISH MODEL REST NAME GFEA517 SOURCE GFEA517 RESOURCE OBJECT GFERestModel       // Agendamento de Entradas e Saidas
PUBLISH MODEL REST NAME GFEA518 SOURCE GFEA518 RESOURCE OBJECT GFERestModel       // Configuração de Operação
PUBLISH MODEL REST NAME GFEX021 SOURCE GFEX021 RESOURCE OBJECT GFERestModel       // Cadastro de Configuração de Tipo de Operação
PUBLISH MODEL REST NAME GFEX201 SOURCE GFEX201 RESOURCE OBJECT GFERestModel       // Integração GFE X FreteBras
PUBLISH MODEL REST NAME GFEX300 SOURCE GFEX300 RESOURCE OBJECT GFERestModel       // Romaneios e Documentos de Carga
