#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/* Publicação dos modelos RH que são disponibilizados no REST */
// PUBLISH MODEL REST NAME ANOA001 SOURCE ANOA001	//Função para processar a anonimizacao das solicitacoes
// PUBLISH MODEL REST NAME GPEA001 SOURCE GPEA001	//Cadastro de Planos Ativos - Assistência médica e odontológica
// PUBLISH MODEL REST NAME GPEA002 SOURCE GPEA002	//Historico de Alteracoes dos Planos Ativos
PUBLISH MODEL REST NAME GPEA003 SOURCE GPEA003	    //Lancamento de Co-Participacao e Reembolso
// PUBLISH MODEL REST NAME GPEA012 SOURCE GPEA012	//Cadastro de Vale Refeicao
// PUBLISH MODEL REST NAME GPEA016 SOURCE GPEA016	//Cadastro de Período de Gestação
PUBLISH MODEL REST NAME GPEA017 SOURCE GPEA017	    //Locais de convocação
PUBLISH MODEL REST NAME GPEA018 SOURCE GPEA018	    //Convocações
// PUBLISH MODEL REST NAME GPEA019 SOURCE GPEA019	//Cadastro de Beneficiários - Órgãos Públicos eSocial S-2410, S-2416, S-2418, S2420
PUBLISH MODEL REST NAME GPEA020 SOURCE GPEA020	    //Cadastro de Dependentes
// PUBLISH MODEL REST NAME GPEA021 SOURCE GPEA021	//Visualização de Histórico - Órgãos Públicos eSocial
// PUBLISH MODEL REST NAME GPEA040 SOURCE GPEA040	//Cadastro de Verbas
// PUBLISH MODEL REST NAME GPEA040A SOURCE GPEA040A //Cadastro de Verbas em MVC
// PUBLISH MODEL REST NAME GPEA050 SOURCE GPEA050	//Cadastro de Periodos por Empregado
// PUBLISH MODEL REST NAME GPEA051 SOURCE GPEA051	//Controle Dias de Direito (Servidores Orgão Público)
// PUBLISH MODEL REST NAME GPEA053 SOURCE GPEA053	//Férias Programadas em Lote
PUBLISH MODEL REST NAME GPEA060 SOURCE GPEA060	    //Cadastro de Resultados de Exames
PUBLISH MODEL REST NAME GPEA061 SOURCE GPEA061	    //Lancamento de Vinculos
PUBLISH MODEL REST NAME GPEA062 SOURCE GPEA062	    //Cadastro de Agrupamento de Benefícios
// PUBLISH MODEL REST NAME GPEA063 SOURCE GPEA063	//Definição de Planos Médico e Odontológico
PUBLISH MODEL REST NAME GPEA065 SOURCE GPEA065	    //Cadastro de Outros Benefícios
// PUBLISH MODEL REST NAME GPEA066 SOURCE GPEA066	//Histórico Cálculo Outros Benefícios
// PUBLISH MODEL REST NAME GPEA068 SOURCE GPEA068	//Visualização do Cálculo de Outros Benefícios
// PUBLISH MODEL REST NAME GPEA120 SOURCE GPEA120	//Acumulados - Histórico Movimentos
// PUBLISH MODEL REST NAME GPEA132 SOURCE GPEA132	//Histórico de Benefícios
// PUBLISH MODEL REST NAME GPEA133 SOURCE GPEA133	//Atualização Vales
// PUBLISH MODEL REST NAME GPEA133A SOURCE GPEA133A //Visualização do recálculo de benefícios (VA/VR)
PUBLISH MODEL REST NAME GPEA140 SOURCE GPEA140	    //Meios Transporte
// PUBLISH MODEL REST NAME GPEA141 SOURCE GPEA141	//Historico de Reajustes de Meio de Transporte
// PUBLISH MODEL REST NAME GPEA161 SOURCE GPEA161	//Cadastro de Verbas por Processo
// PUBLISH MODEL REST NAME GPEA240 SOURCE GPEA240	//Ausencias
// PUBLISH MODEL REST NAME GPEA250 SOURCE GPEA250	//Historico de Salario
// PUBLISH MODEL REST NAME GPEA261 SOURCE GPEA261	//Consulta dos Treinamentos dos Funcionários
// PUBLISH MODEL REST NAME GPEA281 SOURCE GPEA281	//Manutenção de Cheques
PUBLISH MODEL REST NAME GPEA300 SOURCE GPEA300	    //Cadastro Mnemonicos
PUBLISH MODEL REST NAME GPEA340 SOURCE GPEA340	    //Sindicatos
PUBLISH MODEL REST NAME GPEA340A SOURCE GPEA340A    //Cadastro de Sindicatos em MVC
PUBLISH MODEL REST NAME GPEA371 SOURCE GPEA371	    //Informacoes de Hitorico de Cargos - Audesp
PUBLISH MODEL REST NAME GPEA380 SOURCE GPEA380	    //Cadastro de Agentes de Risco
// PUBLISH MODEL REST NAME GPEA390 SOURCE GPEA390	//Cadastro de Registro Patronal em MVC
PUBLISH MODEL REST NAME GPEA430 SOURCE GPEA430	    //Tipos de Ausências
PUBLISH MODEL REST NAME GPEA641 SOURCE GPEA641	    //Tipos de Disciplina
// PUBLISH MODEL REST NAME GPEA642 SOURCE GPEA642	//Pontuação
// PUBLISH MODEL REST NAME GPEA643 SOURCE GPEA643	//Gestão Disciplinar
// PUBLISH MODEL REST NAME GPEA644 SOURCE GPEA644	//Consulta Disciplinas
// PUBLISH MODEL REST NAME GPEA645 SOURCE GPEA645	//Disciplina
// PUBLISH MODEL REST NAME GPEA760 SOURCE GPEA760	//Cadastro de bloqueio de períodos para o MDT
// PUBLISH MODEL REST NAME GPEA840 SOURCE GPEA840	//RRA
// PUBLISH MODEL REST NAME GPEA850 SOURCE GPEA850	//Complemento Trabalhista
// PUBLISH MODEL REST NAME GPEA900 SOURCE GPEA900	//Historico de Contratos
PUBLISH MODEL REST NAME GPEA920 SOURCE GPEA920	    //Informacoes Exclusivas Estagio
PUBLISH MODEL REST NAME GPEA921 SOURCE GPEA921	    //Agente de Integraçao Estagio
// PUBLISH MODEL REST NAME GPEA923 SOURCE GPEA923	//Periodo de Estabilidade
// PUBLISH MODEL REST NAME GPEA924 SOURCE GPEA924	//Visualização Dados de Múltiplos Vínculos
PUBLISH MODEL REST NAME GPEA925 SOURCE GPEA925	    //Aviso Prévio
PUBLISH MODEL REST NAME GPEA926 SOURCE GPEA926	    //Sucessão Vinculos
PUBLISH MODEL REST NAME GPEA927 SOURCE GPEA927	    //Funcionarios Temporários
PUBLISH MODEL REST NAME GPEA927A SOURCE GPEA927A    //Cadastro das Prorrogações do Contrato de Trabalho, Funcionários Temporários
// PUBLISH MODEL REST NAME GPEA928 SOURCE GPEA928	//Informacoes do e-social
PUBLISH MODEL REST NAME GPEA931 SOURCE GPEA931	    //Dados Agente Publico
PUBLISH MODEL REST NAME GPEA932 SOURCE GPEA932	    //Cadastro de Carreiras Públicas
// PUBLISH MODEL REST NAME GPEA933 SOURCE GPEA933	//Manutenção Obs. Contratuais:
// PUBLISH MODEL REST NAME GPEA934 SOURCE GPEA934	//Cadastro de Lotações para o eSocial
// PUBLISH MODEL REST NAME GPEA934A SOURCE GPEA934A //Cadastramento de Obras Próprias eSocial na tabela RJ4
// PUBLISH MODEL REST NAME GPEA934B SOURCE GPEA934B //Rotina para cadastramento de Obras Próprias eSocial na tabela RJ5
PUBLISH MODEL REST NAME GPEA934C SOURCE GPEA934C    //Cadastro de Entidades Educativas para o eSocial
// PUBLISH MODEL REST NAME GPEA935 SOURCE GPEA935	//Cadastro do Empregador e Dados Softwarehouse
// PUBLISH MODEL REST NAME GPEA936 SOURCE GPEA936	//Configuração das Filiais X Tabelas
// PUBLISH MODEL REST NAME GPEA936A SOURCE GPEA936A //Configuração das Filiais X Tabelas - Copia Tabela
// PUBLISH MODEL REST NAME GPEA937 SOURCE GPEA937	//Alteração CPF
// PUBLISH MODEL REST NAME GPEA939 SOURCE GPEA939	//Cadastro de Identificadores de Rubrica
// PUBLISH MODEL REST NAME GPEA940 SOURCE GPEA940	//Cadastro de versões de modelo do consentimento
// PUBLISH MODEL REST NAME GPEA941 SOURCE GPEA941	//Cadastro dos Processos do Funcionário
// PUBLISH MODEL REST NAME GPEA941A SOURCE GPEA941A	//Cadastro dos Processos da Verba
// PUBLISH MODEL REST NAME GPEA941B SOURCE GPEA941B	//Vínculo de processos - Estabelecimentos/Obras Próprias
// PUBLISH MODEL REST NAME GPEA941C SOURCE GPEA941C	//Processos da Lotação
// PUBLISH MODEL REST NAME GPEA942 SOURCE GPEA942	//Histórico Dados do Funcionário
PUBLISH MODEL REST NAME GPEA943 SOURCE GPEA943   	//Cadastro de de Convenção Coletiva de Trabalho
PUBLISH MODEL REST NAME GPEA944A SOURCE GPEA944A   	//Cadastro de De x Para de Grupos de Cargo para o P&M/Swile
PUBLISH MODEL REST NAME GPEA944B SOURCE GPEA944B   	//Cadastro de De x Para de Cargos para o P&M/Swile
PUBLISH MODEL REST NAME GPEA944C SOURCE GPEA944C   	//Cadastro de De x Para de Departamentos para o P&M/Swile
PUBLISH MODEL REST NAME GPEA945 SOURCE GPEA945	    //Informações Complementares Menor Aprendiz
// PUBLISH MODEL REST NAME GPEA950 SOURCE GPEA950	//Cadastro de Grupo de Beneficios - SWILE
// PUBLISH MODEL REST NAME GPEM017D SOURCE GPEM017D	//Funcionalidades de importação de terceiros para o Middleware
// PUBLISH MODEL REST NAME GPEM035 SOURCE GPEM035	//Cons.Tab.Inic.Esocial
// PUBLISH MODEL REST NAME GPEM360 SOURCE GPEM360	//Manutenção Saldos
// PUBLISH MODEL REST NAME GPEM560A SOURCE GPEM560A	//Informações Complementares DIRF
// PUBLISH MODEL REST NAME GPEM561 SOURCE GPEM561	//Manutenção de Pensao - DIRF
// PUBLISH MODEL REST NAME GPEM562 SOURCE GPEM562	//Previdência Complementar 
// PUBLISH MODEL REST NAME GPEM695 SOURCE GPEM695	//Promoção / Progressão Retroativa
// PUBLISH MODEL REST NAME GPEM696 SOURCE GPEM696	//Lançamentos retroativos de verbas avulsas para serem integradas à folha de pagamento
// PUBLISH MODEL REST NAME GPEM910 SOURCE GPEM910	//Manutenção de RRA - Dissidio
// PUBLISH MODEL REST NAME GPEM921 SOURCE GPEM921	//Monitor de Eventos Middleware
// PUBLISH MODEL REST NAME GPEM922 SOURCE GPEM922	//Realiza a exclusão de eventos Middleware
// PUBLISH MODEL REST NAME GPEM924 SOURCE GPEM924	//Monitor de Processamento da Integração GPE x NG Quirons
// PUBLISH MODEL REST NAME GPEM927 SOURCE GPEM927	//Visualização de Histórico - Integrações Quirons
PUBLISH MODEL REST NAME GPEM939B SOURCE GPEM939B	//Exibe os lotes de integração com o P&M (Performance & Metas)/a Feedz
PUBLISH MODEL REST NAME GPEM940A SOURCE GPEM940A	//Exibe os lotes de integração com a Swile
// PUBLISH MODEL REST NAME GPEW011 SOURCE GPEW011	//WS Fluig Solicitação Desligamento
// PUBLISH MODEL REST NAME VDFA010 SOURCE VDFA010	//Cadastro de Concursos
// PUBLISH MODEL REST NAME VDFA020 SOURCE VDFA020	//Cadastro de Requisitos
// PUBLISH MODEL REST NAME VDFA030 SOURCE VDFA030	//Cadastro de Candidato x Concurso / Controle de Requisitos
// PUBLISH MODEL REST NAME VDFA040 SOURCE VDFA040	//Manutenção dos Candidatos
// PUBLISH MODEL REST NAME VDFA070 SOURCE VDFA070	//Manutenção de Substituições
// PUBLISH MODEL REST NAME VDFA080 SOURCE VDFA080	//Cadastro de Workflow de Aprovacoes
// PUBLISH MODEL REST NAME VDFA090 SOURCE VDFA090	//Controle de Perícias
// PUBLISH MODEL REST NAME VDFA100 SOURCE VDFA100	//Averbações de Tempo de Contribuição
// PUBLISH MODEL REST NAME VDFA110 SOURCE VDFA110	//Abono Permanência Cadastramento do Direito
// PUBLISH MODEL REST NAME VDFA120 SOURCE VDFA120	//Cadastro de Lançamentos Automaticos
// PUBLISH MODEL REST NAME VDFA150 SOURCE VDFA150	//Controle de Promotores Eleitorais
// PUBLISH MODEL REST NAME VDFA220 SOURCE VDFA220	//Histórico de Designações
// PUBLISH MODEL REST NAME VDFC010 SOURCE VDFC010	//Processo de Estágio Probatório e Vitaliciamento
// PUBLISH MODEL REST NAME VDFC020 SOURCE VDFC020	//Historico de Adidos/Cedidos
// PUBLISH MODEL REST NAME VDFM030 SOURCE VDFM030	//Concurso - Itens Atos/Portarias
// PUBLISH MODEL REST NAME VDFM060 SOURCE VDFM060	//Certidão de Tempo de Contribuição

Function GPeRESTModels()

Return .T.
