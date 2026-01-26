#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA453.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA453
Cadastro MVC da Tabela de Itens UF Índice de Participação dos Municípios

Revisão 26/08/2024

Foram atualizados:
(01) Minas Gerais (02) Rio Grande do Norte (03) São Paulo (04) Espírito Santo
(05) Rio Grande do Sul (06) Bahia (07) Santa Catarina

Foram incluídos:
(08) Rio de Janeiro, (09) Piauí, (10) Paraná (11) Pará (12) Maranhão
(13) Acre (14) Tocantins (15) Pernambuco (16) Alagoas

Não foram encontrados:
(17) Paraíba, (18) Goiás, (19) Rondônia, (20) Roraima, (21) Sergipe, (22) Amapá, 
(23) Amazonas, (24) Ceará, (25) Distrito Federal, (26) Mato Grosso e (27) Mato Grosso do Sul.

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA453()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Tabela de Itens UF Índice de Participação dos Municípios"
oBrw:SetAlias( 'LF0')
oBrw:SetMenuDef( 'TAFA453' )

LF0->(DbSetOrder(1))

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA453" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruLF0 	:= 	FWFormStruct( 1, 'LF0' )
Local oModel 	:= 	MPFormModel():New( 'TAFA453' )

oModel:AddFields('MODEL_LF0', /*cOwner*/, oStruLF0)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 	:= 	FWLoadModel( 'TAFA453' )
Local 	oStruLF0 	:= 	FWFormStruct( 2, 'LF0' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_LF0', oStruLF0, 'MODEL_LF0' )

oView:EnableTitleView( 'VIEW_LF0', STR0001 )	//"Cadastro dos Modelos de Documentos Fiscais"
oView:CreateHorizontalBox( 'FIELDSLF0', 100 )
oView:SetOwnerView( 'VIEW_LF0', 'FIELDSLF0' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader := {}
Local aBody	  := {}
Local aRet	  := {}
Local cCodIpm := ''
Local cDesCod := ''

//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
nVerAtu := 1033.66

If nVerEmp < nVerAtu

	aAdd( aHeader, "LF0_FILIAL" )
	aAdd( aHeader, "LF0_ID" )
	aAdd( aHeader, "LF0_CODIGO" )
	aAdd( aHeader, "LF0_DESCRI" )
	aAdd( aHeader, "LF0_DTINI" )
	aAdd( aHeader, "LF0_DTFIN" )
	aAdd( aHeader, "LF0_UF" )
	aAdd( aHeader, "LF0_ALTCON" )
	
	////////////////////////////////////////////////////////////////////
	//01. Minas Gerais - 000012 //versão=3 (tb14028) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "COOPERATIVAS"
	cDesCod := "Cooperativas"
	aAdd( aBody, {"", "4c7a5671-36eb-1e0b-008b-956355c90988", cCodIpm, cDesCod, "20150101", ""		  , "000012"} )

	cCodIpm := "GERACAO_DE_ENERGIA_ELETRICA"
	cDesCod := "Geração de Energia Elétrica"
	aAdd( aBody, {"", "d30a0ecb-f9f0-4440-577d-df63252bb619", cCodIpm, cDesCod, "20150101", ""		  , "000012"} )

	cCodIpm := "MUDANCA_DE_MUNICIPIO"
	cDesCod := "Mudança de Município"
	aAdd( aBody, {"", "414721b1-bd67-cbca-be92-c4c767044ecb", cCodIpm, cDesCod, "20170101", "20200531", "000012", 1033.66} )

	cCodIpm := "OUTRAS_ENTRADAS_A_DETALHAR_POR_MUNICIPIO"
	cDesCod := "Outras Entradas a Detalhar por município"
	aAdd( aBody, {"", "8cc80b91-38d4-86b6-0f3f-1550c7f99a98", cCodIpm, cDesCod, "20150101", ""		  , "000012"} )

	cCodIpm := "PRESTACAO_DE_SERVICO_DE_TRANSPORTE_RODOVIARIO"
	cDesCod := "Prestação de Serviço de Transporte Rodoviário"
	aAdd( aBody, {"", "522d1100-163a-67e8-46e9-a595099692b5", cCodIpm, cDesCod, "20150101", ""		  , "000012"} )

	cCodIpm := "PRODUTOS_AGROPECUARIOS"
	cDesCod := "Produtos Agropecuários/Hortifrutigranjeiros"
	aAdd( aBody, {"", "0ecf4576-f078-d693-12dd-212bc4694f5f", cCodIpm, cDesCod, "20150101", ""		  , "000012"} )

	cCodIpm := "TRANSPORTE_TOMADO"
	cDesCod := "Transporte Tomado"
	aAdd( aBody, {"", "f0fbc990-44ec-b629-4748-2dcbf1af987e", cCodIpm, cDesCod, "20150101", ""		  , "000012"} )

	////////////////////////////////////////////////////////////////////
	//02. Rio Grande do Norte - 000021 //versão=4 (tb14174) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "IPM 3.1"
	cDesCod := "Produtos Agropecuários/Hortifrutigranjeiros"
	aAdd( aBody, {"", "715c6b7e-6638-8c32-c11e-43dfe43d4e23", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 3.2"
	cDesCod := "Transporte Tomado de Transportador Autônomo ou Empresa Transportadora não Inscrita no Estado"
	aAdd( aBody, {"", "f4f3338f-6485-3d43-a4d9-1d74a2f06085", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 3.3"
	cDesCod := "Cooperativas"
	aAdd( aBody, {"", "a8063ff4-ccb6-5e9d-56ab-0b83727362b0", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 3.4"
	cDesCod := "Geração de Energia Elétrica para Utilização Própria (Autogeração)"
	aAdd( aBody, {"", "7e36d39a-3584-0203-0cfb-db3c421de872", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 3.5"
	cDesCod := "Vendas em Outros Municípios Fora da Sede do Estabelecimento, com Retenção do ICMS por Substituição Tributária, Inclusive Marketing Porta a Porta a Consumidor Final"
	aAdd( aBody, {"", "d577a0ec-05f6-0539-51d2-93e6f27db4b0", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 3.6"
	cDesCod := "Escrituração Centralizada"
	aAdd( aBody, {"", "a20c1bad-7b5f-6f90-cc21-8f3bebcecff0", cCodIpm, cDesCod, "20200101", ""		  , "000021", 1033.66} )

	cCodIpm := "IPM 4.1"
	cDesCod := "Prestação de Serviço de Transporte Rodoviário de Cargas"
	aAdd( aBody, {"", "ed538573-0046-0363-a9e8-24c359d52c62", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.2"
	cDesCod := "Prestação de Serviço de Transporte Aéreo de Cargas"
	aAdd( aBody, {"", "14bac2eb-6c0b-869f-b241-293b9e37f799", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.3"
	cDesCod := "Prestação de Serviço de Transporte Aquaviário de Cargas"
	aAdd( aBody, {"", "9f72137f-f78b-d06c-4f0e-4279753a6738", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.4"
	cDesCod := "Extração de Substâncias Minerais - Na Hipótese da Jazida se Estender por Mais de um Município"
	aAdd( aBody, {"", "95a98788-d39f-5351-e945-1dc2a63744d0", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.5"
	cDesCod := "Atividades de Distribuição de Energia Elétrica"
	aAdd( aBody, {"", "3f5f690f-b810-1cd7-2e3e-d74734c70ea3", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.6"
	cDesCod := "Atividades de Prestação de Serviços de Comunicação/Telecomunicação"
	aAdd( aBody, {"", "a86a6305-0602-9b86-d2ed-4a43af9e6c64", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.7"
	cDesCod := "Produção de Petróleo e Gás Natural - Na Hipótese da Produção se Estender por Mais de um Município"
	aAdd( aBody, {"", "3be749b0-522a-33cb-461c-6a3746d4eb4d", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 4.8"
	cDesCod := "Distribuição de Água Canalizada"
	aAdd( aBody, {"", "c4b0a6e1-2d97-12d0-2dfe-c3c15d4a966a", cCodIpm, cDesCod, "20160101", "20201031", "000021", 1033.66} )

	cCodIpm := "IPM 4.9"
	cDesCod := "Distribuição de Gás Natural Canalizado"
	aAdd( aBody, {"", "72b70beb-108c-aaeb-c4f6-f03056c20daf", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 5.1"
	cDesCod := "Atividades de Prestação de Serviço de Transporte Dutoviário/Ferroviário"
	aAdd( aBody, {"", "fdcca1cb-2e6e-8a38-0b94-cc708d6dcc24", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 5.2"
	cDesCod := "Sistemas de Integração entre Empresário, Sociedade Empresária ou Empresa Individual de Responsabilidade Limitada e Produtores Rurais"
	aAdd( aBody, {"", "0d092cff-4934-b44f-2cfd-ed33f61e4567", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 5.3"
	cDesCod := "Atividades do Estabelecimento do Contribuinte que se estenderem pelos Territórios de mais de um Município"
	aAdd( aBody, {"", "6b5ee4cf-9678-82a4-4628-581dd3f8849c", cCodIpm, cDesCod, "20160101", ""	      , "000021"} )

	cCodIpm := "IPM 5.4"
	cDesCod := "Atividades de Geração/Transmissão de Energia Elétrica"
	aAdd( aBody, {"", "13bd7810-c6fe-7a64-1cc3-5d3b633edd42", cCodIpm, cDesCod, "20160101", ""	      , "000021"} )

	cCodIpm := "IPM 5.5"
	cDesCod := "Atividade de Fornecimento de Refeição Industrial para Município Distinto daquele da Circunscrição do Contribuinte"
	aAdd( aBody, { "", "1c604cfb-6da4-b415-4ea3-c22ef672ed6b", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	cCodIpm := "IPM 5.6"
	cDesCod := "Mudança do Estabelecimento do Contribuinte para Outro Município"
	aAdd( aBody, {"", "c35a9dfd-62bd-ac79-dedb-8a8543eddcec", cCodIpm, cDesCod, "20160101", ""	      , "000021"} )

	cCodIpm := "IPM 5.7"
	cDesCod := "Outras Hipóteses em que Haja Necessidade de Atribuição de Valor Adicionado Fiscal (VAF) a mais de um Município"
	aAdd( aBody, {"", "d59b647d-f01b-38ea-4f75-45f5a670f3d1", cCodIpm, cDesCod, "20160101", ""		  , "000021"} )

	////////////////////////////////////////////////////////////////////
	//03. São Paulo - 000027 //versão=4 (tb12548) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "SPDIPAM11"
	cDesCod := "Compras escrituradas de mercadorias de produtores agropecuários paulistas por município de origem."
	aAdd( aBody, {"", "97fa4e11-4188-0f1c-6dd4-d24e120ac2ae", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM12"
	cDesCod	:= "Compras não escrituradas de mercadorias de agropecuários paulistas por município de origem e outros ajustes determinados pela SEFAZ-SP."
	aAdd( aBody, {"", "e65361ee-766a-5dd4-2881-3b018baad9b2", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM13"
	cDesCod	:= "Recebimentos, por cooperativas, de mercadorias remetidas por produtores rurais deste Estado, desde que ocorra a efetiva transmissão da propriedade para a cooperativa. Excluem-se as situações em que haja previsão de retorno da mercadoria ao cooperado, como quando a cooperativa é simples depositária."
	aAdd( aBody, {"", "4d21b580-7abe-7b1d-fcf7-9e57573f2dba", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM22"
	cDesCod	:= "Vendas efetuadas por revendedores ambulantes autônomos em outros municípios paulistas; Refeições preparadas fora do município do declarante, em operações autorizadas por Regime Especial; operações realizadas por empresas devidamente autorizadas a declarar por meio de uma única Inscrição Estadual; Outros ajustes determinados pela Secretaria da Fazenda mediante instrução expressa e específica."
	aAdd( aBody, {"", "16680874-fca6-9107-a382-cbca9bad1cb9", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM23"
	cDesCod	:= "Rateio dos serviços de transporte intermunicipal e interestadual iniciados em municípios paulistas."
	aAdd( aBody, {"", "830292a4-aa98-1dd7-8c7a-8e72046dcf4d", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM24"
	cDesCod	:= "Rateio dos serviços de comunicação aos municípios paulistas onde tenham sido prestados."
	aAdd( aBody, {"", "640085e1-2c8c-9835-b908-1c4fd2d13822", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM25"
	cDesCod	:= "Rateio de energia elétrica - Estabelecimento Distribuidor de Energia."
	aAdd( aBody, {"", "8017836c-4896-ef35-d365-4777dd87c741", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM26"
	cDesCod	:= "Informar o Valor Adicionado (deduzidos os custos de insumos) referente à produção própria ou arrendada nos estabelecimentos nos quais o contribuinte não possua Inscrição Estadual inscrita."
	aAdd( aBody, {"", "02cef896-3a94-4229-ea86-03efba9d09d7", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM27"
	cDesCod	:= "Informar: (i) o valor das operações de saída de mercadorias cujas transações comerciais tenham sido realizadas em outro estabelecimento localizado neste Estado, excluídas as transações comerciais não presenciais; e (ii) os respectivos municípios onde as transações comerciais foram realizadas."
	aAdd( aBody, {"", "bcacfe83-5136-5692-ae8d-a88d5f56714d", cCodIpm, cDesCod, "20170701", "20171231", "000027"} )

	cCodIpm := "SPDIPAM27"
	cDesCod	:= "Vendas presenciais com saídas/vendas efetuadas em estabelecimento diverso de onde ocorreu a transação/negociação inicial."
	aAdd( aBody, {"", "ea11f96a-4702-d686-df95-abcc6358e191", cCodIpm, cDesCod, "20180101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM31"
	cDesCod	:= "Saídas não escrituradas e outros ajustes determinados pela SEFAZ-SP."
	aAdd( aBody, {"", "fc5a2c4f-a107-c2ab-3927-a209bd8af9ea", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM35"
	cDesCod	:= "Entradas não escrituradas e outros ajustes determinados pela SEFAZ-SP."
	aAdd( aBody, {"", "45f4a04d-5c24-c149-2b06-a88ee424fc0b", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	cCodIpm := "SPDIPAM36"
	cDesCod	:= "Entradas não escrituradas de produtores não equiparados."
	aAdd( aBody, {"", "04551faa-91c2-0dc8-5752-30a82c991562", cCodIpm, cDesCod, "20150101", ""		  , "000027"} )

	////////////////////////////////////////////////////////////////////
	//04. Espirito Santo - 000008 //versão=1 (tb1183) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "ESIPM01"
	cDesCod := "PRODUÇÃO RURAL PRÓPRIA - Entradas para comercialização ou industrialização, de produtos agropecuários produzidos em propriedade rural que o contribuinte é responsável, inclusive as entradas por retorno de animal em sistema de integração."
	aAdd( aBody, {"", "4553de70-c658-d65e-f32f-535dca61c8bd", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM02"
	cDesCod := "COOPERATIVAS E CONTRIBUINTES QUE POSSUAM REOA - Valor dos produtos agropecuários adquiridos por cooperativas ou contribuintes que possuam Regime Especial de Obrigação Acessória - REOA - para emitir a NFe referente à entrada de produtos."
	aAdd( aBody, {"", "5e4a80b6-c632-47fb-4fac-254824baf65f", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM03"
	cDesCod := "AQUISIÇÕES DE PESSOAS FÍSICAS - Valor correspondente às aquisições de mercadorias de pessoas físicas, tais como sucatas e veículos usados. Não consideraras aquisições de produtores rurais que tenham emitido nota fiscal de produtor."
	aAdd( aBody, {"", "b409689b-e9c7-d5f5-658f-23c2125bce23", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM04"
	cDesCod := "GERAÇÃO DE ENERGIA ELÉTRICA - Receita referente à produção de energia elétrica, deduzidos os custos de produção. Detalhando para o Município de localização do estabelecimento produtor, que é onde está instalado o motor primário."
	aAdd( aBody, {"", "36ac86ae-86fb-bb01-ebc4-fab01875f3cd", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM05"
	cDesCod := "DISTRIBUIÇÃO DE ENERGIA ELÉTRICA - Receita de energia elétrica distribuída, deduzido o valor da compra de energia elétrica, utilizando o critério de rateio proporcional e considerando o valor total do fornecimento."
	aAdd( aBody, {"", "d8ce139a-12c3-108f-c16e-320583c9ae91", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM06"
	cDesCod := "PRESTAÇÃO SERVIÇO DE TRANSPORTE - Valor das prestações de serviços de transporte intermunicipal e interestadual, para o Município que tenha iniciado o transporte. Se iniciado em outro Estado, registra-se para o Município sede da transportadora."
	aAdd( aBody, {"", "09c717ca-f890-f5b8-8898-7b34838f01a3", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM07"
	cDesCod := "SERVIÇOS DE COMUNICAÇÃO E TELECOMUNICAÇÃO -Valor correspondente para cada Município nos quais foram realizadas prestações de serviços de comunicação e telecomunicação, não considerando o faturamento referente à comercialização de equipamentos."
	aAdd( aBody, {"", "fee22f7e-a96a-abfc-5a3b-74e76a8ef451", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM08"
	cDesCod := "PRODUÇÃO DE PETRÓLEO E GÁS NATURAL - Valor referente às atividades de produção de petróleo ou gás natural, considerando para o rateio do Município o critério “cabeça do poço”, que é onde estão instalados os equipamentos de extração."
	aAdd( aBody, {"", "c29dd290-025a-958a-b036-ca6b0ebecd48", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM09"
	cDesCod := "DISTRIBUIÇÃO DE ÁGUA CANALIZADA - Valor relativo ao faturamento de água tratada, considerando o fornecimento para cada Município individualmente e rateando os custos proporcionalmente. Sendo vedada a inclusão do faturamento relativo ao esgoto."
	aAdd( aBody, {"", "9b81f1a9-e831-130d-b232-92b33e3f13b0", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM10"
	cDesCod := "DISTRIBUIÇÃO DE GÁS NATURAL CANALIZADO - Valor do faturamento com gás natural canalizado, deduzido por critério de rateio as compras de gás natural e os tributos incidentes."
	aAdd( aBody, {"", "1e65a649-3687-2069-d175-c00391b7c63f", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM11"
	cDesCod := "COZINHAS INDUSTRIAIS E SISTEMA DE INSCRIÇÃO CENTRALIZADA - Faturamento não incluídos nos itens anteriores, realizados por contribuintes com inscrição centralizada, legislação do ICMS ou regime especial, como cozinhas industriais."
	aAdd( aBody, {"", "2d0e68e3-23d2-e0ec-7e22-682af4d52985", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM12"
	cDesCod := "FOMENTOS AGROPECUÁRIOS - Valor correspondente ao fomento agropecuário realizados pelo contribuinte."
	aAdd( aBody, {"", "cb3f7474-32b8-1df2-3267-82d061a1ba2c", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	cCodIpm := "ESIPM13"
	cDesCod := "MUDANÇA PARA OUTRO MUNICÍPIO - Será informado para o Município onde o contribuinte estava localizado, o valor referente ao estoque final de mercadorias constantes no dia da mudança para outro Município."
	aAdd( aBody, {"", "cf45eab3-bd16-cf1e-c769-9a41e62e29b1", cCodIpm, cDesCod, "20151001", ""		  , "000008"} )

	////////////////////////////////////////////////////////////////////
	//05. Rio Grande do Sul - 000024 //versão=1 (tb1846) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "01"
	cDesCod := "Transporte: serviço de transporte por município de origem deste Estado, na hipótese de transportadores e de responsáveis por substituição tributária"
	aAdd( aBody, {"", "3a6fe33a-bb80-3cb9-852e-7d0b65e645e6", cCodIpm, cDesCod, "20161001", ""		  , "000024"} )

	cCodIpm := "02"
	cDesCod := "Energia Elétrica - Distribuição: distribuição de energia elétrica em cada município"
	aAdd( aBody, {"", "108293fc-4880-f93a-ea77-b5f114e94853", cCodIpm, cDesCod, "20161001", ""        , "000024"} )

	cCodIpm := "03"
	cDesCod := "Comunicação: prestação de serviços de comunicação em cada município"
	aAdd( aBody, {"", "39501407-864f-545c-6f6f-b6eebaae101c", cCodIpm, cDesCod, "20161001", ""        , "000024"} )

	cCodIpm := "05"
	cDesCod := "Vendas Fora do Estabelecimento: vendas realizadas por contribuinte deste Estado fora do seu estabelecimento"
	aAdd( aBody, {"", "7de8a973-f65d-e358-6d77-332015f1bcdd", cCodIpm, cDesCod, "20161001", ""        , "000024"} )

	cCodIpm := "06"
	cDesCod := "Energia Elétrica - Geração: geração de energia elétrica produzida em município distinto do domicílio fiscal do estabelecimento informante"
	aAdd( aBody, {"", "d124c96d-49bf-8c4a-23fd-c8cf8a733c74", cCodIpm, cDesCod, "20161001", ""        , "000024"} )

	cCodIpm := "09"
	cDesCod := "Regime Especial - ver necessidade de apresentar também registro E115 (código RS160087) para entradas/custos; e registro E115 (código RS160001) para a identificação do Ato Declaratório do regime especial"
	aAdd( aBody, {"", "214f9fb5-b372-f474-26af-e4351bb547d0", cCodIpm, cDesCod, "20161001", ""        , "000024"} )

	////////////////////////////////////////////////////////////////////
	//06. Bahia - 000005 //versão=1 (tb16544) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "BAE06"
	cDesCod := "Operações não dedutíveis nas entradas - Informar, para o município de localização do estabelecimento, caso tenham ocorrido, as operações realizadas com os CFOPs genéricos 1949, 2949 e 3949, e que representem uma real movimentação econômica para a empresa, ou seja, gerem valor adicionado (agregado)"
	aAdd( aBody, {"", "9b1d3c66-1d28-1865-f073-ecc64bb0336f", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAS06"
	cDesCod := "Operações não dedutíveis nas saídas - Informar, para o município de localização do estabelecimento, caso tenham ocorrido, as operações realizadas com os CFOPs genéricos 5949, 6949 e 7949, e que representem uma real movimentação econômica para a empresa, ou seja, gerem valor adicionado (agregado)"
	aAdd( aBody, {"", "eb963ade-2242-9159-381b-07a9d7200238", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE07"
	cDesCod := "Aquisição de produto diferido - Eucalipto - valor das aquisições internas de EUCALIPTO oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "8edbc146-6c3c-981b-b101-b3e90c147cd8", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE08"
	cDesCod := "Aquisição de produto diferido - Animais vivos - valor das aquisições internas de GADO BOVINO, SUÍNO, BUFALINO, ASININO, EQUINO E MUAR EM PÉ, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "ba1064f5-c282-4c90-1e47-61e343b9256b", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE09"
	cDesCod := "Aquisição de produto diferido - Leite fresco - valor das aquisições internas de LEITE FRESCO oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "700dadd6-491e-b8d9-6b4f-1f09271b0224", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE10"
	cDesCod := "Aquisição de produto diferido - Mariscos/Peixes - valor das aquisições internas de LAGOSTA, CAMARÕES E PEIXES, oriundas de contribuintes não inscritos, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "99716e3d-1b62-46d3-1743-d311e1ed27a5", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE11"
	cDesCod := "Aquisição de produto diferido - Sucatas - valor das aquisições internas de SUCATAS METÁLICAS, SUCATAS NÃO METÁLICAS, SUCATAS DE ALUMÍNIO, FRAGMENTOS, RETALHOS DE PLASTICOS E TECIDOS, SUCATAS DE PNEUS E BORRACHAS - RECICLÁVEIS, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "7561eaf2-ae7c-1704-1e7b-9509b7824328", cCodIpm, cDesCod, "20180101", ""		  , "000005", 1033.66} )

	cCodIpm := "BAE12"
	cDesCod := "Aquisição de produto diferido - Couros e Peles - valor das aquisições internas de COUROS E PELES, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "1396d3b6-5d6c-515f-68fb-ae81a0eecf34", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE13"
	cDesCod := "Aquisição de produto diferido - Materiais para combustão - valor das aquisições internas de LENHA E OUTROS MATERIAIS PARA COMBUSTÃO INDUSTRIAL, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "6a8bd1bd-f777-cc3d-27ee-304deeca0e4f", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE14"
	cDesCod := "Aquisição de produto diferido - Embalagens e insumos - valor das aquisições internas de EMBALAGENS E INSUMOS oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "9df24656-8115-50ea-3b9c-23ba581caaa6", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE15"
	cDesCod := "Aquisição de produto diferido - Cravo da Índia - valor das aquisições internas de CRAVO DA ÍNDIA, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "fe81654e-f0de-af8c-b5f1-7c31d0d4a08e", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE16"
	cDesCod := "Aquisição de produto diferido - Bambu - valor das aquisições internas de BAMBU, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "f292c807-17df-fd3d-f6fd-b99e595815ca", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE17"
	cDesCod := "Aquisição de produto diferido - Resíduo papel/papelão - valor das aquisições internas de RESÍDUOS DE PAPEL E PAPELÃO, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "e637fbe8-3acd-154b-bf07-9b9e800247cf", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE18"
	cDesCod := "Aquisição de produto diferido - Sebo, osso, chifre e casco - valor das aquisições internas de SEBO, OSSOS, CHIFRES E CASCO, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "949a3b24-a740-630a-e1a0-ee7ec1b39eb4", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE19"
	cDesCod := "Aquisição de produto diferido - Argila - valor das aquisições internas de ARGILA, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "01b5aa11-2962-35e6-78db-f38f6bcadfc0", cCodIpm, cDesCod, "20180101", ""		  , "000005"} )

	cCodIpm := "BAE21"
	cDesCod := "Aquisição de Serviços de Transporte - valor da operação das entradas e aquisições de serviço de transporte intermunicipal e/ou interestadual, por município baiano, proporcionalmente às saídas informadas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "cdd0e017-aad1-bee2-ac07-7ee0f7bbd736", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS21"
	cDesCod := "Prestação de Serviços de Transporte - valor da operação das saídas e prestações de serviço de transporte intermunicipal e/ou interestadual, por município baiano de início (origem) da prestação, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "cb45737a-f004-c927-5adb-790ac24a1a62", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE22"
	cDesCod := "Aquisição de serviços de Comunicação/Telecomunicação - valor da operação das entradas e aquisições de serviço de comunicação, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "1cc6f7ca-c20c-4c50-2eef-3a4adbb9c3a0", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS22"
	cDesCod := "Prestação de serviços de Comunicação/Telecomunicação - valor da operação das saídas e prestações de serviço de comunicação, por município baiano onde ocorreu a prestação, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "110f990a-e389-e0e3-549a-a94bf2ef9d95", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE23"
	cDesCod := "Geração e Distribuição de Energia Elétrica e Água - Entradas - valor da operação das entradas  e insumos utilizados na geração e distribuição de energia elétrica ou água, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "133ace20-1740-544a-fe6e-0fafd1affde1", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS23"
	cDesCod := "Geração e Distribuição de Energia Elétrica e Água - Saídas - valor da operação das saídas de geração e distribuição de energia elétrica ou água, por município baiano onde ocorreu o fato gerador ou, no caso da distribuição, por município baiano onde ocorreu o fornecimento, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "654f86e3-02c8-9795-0a91-4c6f60708392", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE24"
	cDesCod := "Regimes Especiais - Entradas - valor da operação das entradas, por município baiano, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime"
	aAdd( aBody, {"", "8f2658da-ee34-056f-256e-2d1e24e1096d", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS24"
	cDesCod := "Regimes Especiais - Saídas - valor da operação das saídas, por município baiano de ocorrência do fato gerador, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime"
	aAdd( aBody, {"", "17e577fe-10f4-efb4-b0a8-db4c3887d04f", cCodIpm, cDesCod, "20240701", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE80"
	cDesCod := "ICMS/ST nas Entradas - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária"
	aAdd( aBody, {"", "ceb87efa-02be-5797-e896-121e06f02902", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS80"
	cDesCod := "ICMS/ST nas Saídas - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária"
	aAdd( aBody, {"", "300e8dcb-c198-9f47-8152-0a4c4b414a2c", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE81"
	cDesCod := "IPI nas Entradas - Informar, para o município de localização do estabelecimento, a parcela do IPI que não integra a base de cálculo do ICMS"
	aAdd( aBody, {"", "18b61782-b595-cd61-13b7-fd53f55e7f5b", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS81"
	cDesCod := "IPI nas Saídas - Informar, para o município de localização do estabelecimento, a parcela do IPI que não integra a base de cálculo do ICMS"
	aAdd( aBody, {"", "f98704f5-8989-60b4-828f-a1d8e3867f11", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE82"
	cDesCod := "Exclusões das Entradas - Informar outros ajustes específicos necessários, que devam reduzir os valores de entrada"
	aAdd( aBody, {"", "2d5db61a-a4fd-4827-68b1-32d34a95721a", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS82"
	cDesCod := "Exclusões das Saídas - Informar outros ajustes específicos necessários, que devam reduzir os valores de saída"
	aAdd( aBody, {"", "0aeee798-6164-5d9a-4f47-b724db5a479e", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE83"
	cDesCod := "Inclusões das Entradas - Informar outros ajustes específicos necessários, que devam aumentar os valores de entrada"
	aAdd( aBody, {"", "06c54cdc-168d-c431-310b-43f920086fba", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAS83"
	cDesCod := "Inclusões das Saídas - Informar outros ajustes específicos necessários, que devam aumentar os valores de saída"
	aAdd( aBody, {"", "1abab432-d2a8-e7aa-7998-5df0a96fef07", cCodIpm, cDesCod, "20220101", ""	  	  , "000005", 1033.66} )

	cCodIpm := "BAE01"
	cDesCod := "Aquisição de Serviços de Transporte - valor contábil das entradas e aquisições de serviço de transporte intermunicipal e/ou interestadual, por município baiano, proporcionalmente às saídas informadas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "c1794766-55ad-7f49-1725-5513fceb6b67", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAS01"
	cDesCod := "Prestação de Serviços de Transporte - valor contábil das saídas e prestações de serviço de transporte intermunicipal e/ou interestadual, por município baiano de início (origem) da prestação, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "c018af05-4f94-034d-5c66-54ee813b205c", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAE02"
	cDesCod := "Aquisição de serviços de Comunicação/Telecomunicação -  valor contábil das entradas e aquisições de serviço de comunicação, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "38396e1f-ffca-6f16-7ded-669d81c44010", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAS02"
	cDesCod := "Prestação de serviços de Comunicação/Telecomunicação - valor contábil das saídas e prestações de serviço de comunicação, por município baiano onde ocorreu a prestação, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "d828110e-87ad-ba84-5065-fbf86dd36105", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAE03"
	cDesCod := "Geração e Distribuição de Energia Elétrica e Água - Entradas - valor contábil das entradas  e insumos utilizados na geração e distribuição de energia elétrica ou água, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "516b1486-a55f-4c1b-17b4-8904c8fe470a", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAS03"
	cDesCod := "Geração e Distribuição de Energia Elétrica e Água - Saídas - valor contábil das saídas de geração e distribuição de energia elétrica ou água, por município baiano onde ocorreu o fato gerador ou, no caso da distribuição, por município baiano onde ocorreu o fornecimento, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "af95e789-0db7-f10b-26ad-be10544531b9", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAE04"
	cDesCod := "Regimes Especiais - Entradas - valor contábil das entradas, por município baiano, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime"
	aAdd( aBody, {"", "43d65f0e-c021-e99b-df65-ed666cb0b1c5", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAS04"
	cDesCod := "Regimes Especiais - Saídas - valor contábil das saídas, por município baiano de ocorrência do fato gerador, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime"
	aAdd( aBody, {"", "20b40930-e8f7-a6e6-ed35-f3291a2ab68e", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAE05"
	cDesCod := "Exclusões nas entradas - IPI e ICMS/ST - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária e a parcela do IPI que não integra a base de cálculo do ICMS"
	aAdd( aBody, {"", "fc3e9031-4351-e719-fc51-364fea36b2d4", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAS05"
	cDesCod := "Exclusões nas saídas - IPI e ICMS/ST - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária e a parcela do IPI que não integre a base de cálculo do ICMS"
	aAdd( aBody, {"", "b684bcb0-89e7-b3df-4034-7104111c27ef", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAE01"
	cDesCod := "Aquisição de Serviços de Transporte - valor da operação das entradas e aquisições de serviço de transporte intermunicipal e/ou interestadual, por município baiano, proporcionalmente às saídas informadas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "4e48ee86-2207-bf22-f260-d0efada76e76", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAS01"
	cDesCod := "Prestação de Serviços de Transporte - valor da operação das saídas e prestações de serviço de transporte intermunicipal e/ou interestadual, por município baiano de início (origem) da prestação, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "1423b904-9c7b-0605-08dc-143b870ee8a6", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAE02"
	cDesCod := "Aquisição de serviços de Comunicação/Telecomunicação - valor da operação das entradas e aquisições de serviço de comunicação, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "bd30d361-1d6d-0987-3c66-82f7ba7c4cb6", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAS02"
	cDesCod := "Prestação de serviços de Comunicação/Telecomunicação - valor da operação das saídas e prestações de serviço de comunicação, por município baiano onde ocorreu a prestação, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "449cb809-5b11-1117-0101-6bf17a8e288a", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAE03"
	cDesCod := "Geração e Distribuição de Energia Elétrica e Água - Entradas - valor da operação das entradas  e insumos utilizados na geração e distribuição de energia elétrica ou água, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "b25fe06e-4dda-e959-f958-97f7c5ecd246", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAS03"
	cDesCod := "Geração e Distribuição de Energia Elétrica e Água - Saídas - valor da operação das saídas de geração e distribuição de energia elétrica ou água, por município baiano onde ocorreu o fato gerador ou, no caso da distribuição, por município baiano onde ocorreu o fornecimento, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "57ded3fa-c985-9b56-063e-93c45aad2e3c", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAE04"
	cDesCod := "Regimes Especiais - Entradas - valor da operação das entradas, por município baiano, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime"
	aAdd( aBody, {"", "548db69b-1556-7c08-7893-3869f65200e9", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAS04"
	cDesCod := "Regimes Especiais - Saídas - valor da operação das saídas, por município baiano de ocorrência do fato gerador, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime"
	aAdd( aBody, {"", "9777747f-2cc9-b764-c398-d608fd3ed775", cCodIpm, cDesCod, "20220101", "20240630", "000005", 1033.66} )

	cCodIpm := "BAE20"
	cDesCod := "Aquisição de produto diferido - Outros - valor das aquisições internas de outros produtos não especificados nas linhas anteriores, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento"
	aAdd( aBody, {"", "b04768e3-1504-279b-0e52-b3b869a5af6e", cCodIpm, cDesCod, "20180101", "20220531", "000005", 1033.66} )

	cCodIpm := "BAE99"
	cDesCod := "Outros ajustes nas entradas - outros ajustes específicos determinados pela Sefaz BA"
	aAdd( aBody, {"", "9148e538-5c37-94c6-c12e-700a169bc059", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	cCodIpm := "BAS99"
	cDesCod := "Outros ajustes nas saídas - outros ajustes específicos determinados pela Sefaz BA"
	aAdd( aBody, {"", "8a9cb272-0f0d-7517-c690-a3c1f7a7a97c", cCodIpm, cDesCod, "20180101", "20211231", "000005", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//07. Santa Catarina  - 000025 //versão=7 (tb16399) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "01"
	cDesCod := "Extração mineral do subsolo realizada em unidades de exploração da própria empresa quando o minério ou a boca da mina se localizarem em município diverso da sede do estabelecimento do contribuinte"
	aAdd( aBody, {"", "ad70b0a2-2327-200b-9296-519fea444b8d", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "02"
	cDesCod := "Transferências recebidas de estabelecimento do mesmo titular a preço de venda a varejo"
	aAdd( aBody, {"", "360639ca-eb50-8572-e0e0-3fc218380f47", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "03"
	cDesCod := "Transferências enviadas a estabelecimento do mesmo titular a preço de venda a varejo"
	aAdd( aBody, {"", "704bf221-4231-0122-52b3-3b2ac94eaa7a", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "04"
	cDesCod := "Subsídios concedidos por órgãos dos governos federal, estadual ou municipal, sobre entradas"
	aAdd( aBody, {"", "11b71c96-f65f-6fbc-de1a-1b31a5a8cf45", cCodIpm, cDesCod, "20200101", ""		  , "000025"} )

	cCodIpm := "05"
	cDesCod := "Saída de mercadoria realizada pelo sistema de marketing direto e que destine mercadorias a revendedores que operem na modalidade de venda porta-a- porta"
	aAdd( aBody, {"", "a175cb02-3fd9-a937-877e-3af801fb2767", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "06"
	cDesCod := "Saída de mercadoria realizada por estabelecimento diverso daquele no qual as transações foram efetivadas, desde que:a) ambos estejam localizados no território catarinense, eb) o estabelecimento onde ocorreu a efetiva venda não tenha emitido a NF-e da venda."
	aAdd( aBody, {"", "4a19b344-06a5-62ab-470f-13777fde30dc", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )

	cCodIpm := "07"
	cDesCod := "Saída de mercadorias ao varejo realizada através de entreposto ou posto de abastecimento, situados no Estado (Exige TTD)"
	aAdd( aBody, {"", "6bae3e5a-eef7-31d7-a20e-2ea1a7633147", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )

	cCodIpm := "08"
	cDesCod := "Saída de partes e peças de um todo realizada por detentor de TTD (Tratamento Tributário Diferenciado código 998) autorizando lançar a operação nos CFOP 5.949 ou 6.949 e desde que a posterior transmissão de propriedade do produto final seja lançada nos CFOP 5.116, 5.117, 6.116 ou 6.117."
	aAdd( aBody, {"", "72d97348-85a5-f177-d146-bec6b730bc1b", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )

	cCodIpm := "09"
	cDesCod := "Saída para informar a transmissão da propriedade de parte ou do todo realizada por detentor de TTD (998) autorizando lançar a operação no CFOP 5.116, 5.117, 6.116 ou 6.117, relativo as saídas das partes e peças anteriormente registradas nos CFOP 5.949 ou 6949."
	aAdd( aBody, {"", "c52c16c8-8f5b-dbd5-9fdb-33fc72a408b4", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )

	cCodIpm := "10"
	cDesCod := "Entrada na Trading de mercadoria importada por conta e ordem de terceiros e registrada nos CFOP 1949, 2949, 3949 e desde que não registrada nos CFOP 1101, 1102, 2101, 2102,3101 ou 3102 e não se trate de simples remessa, devolução, retorno ou anulações. (É Exigido TTD 998)"
	aAdd( aBody, {"", "88b988a7-ae9c-3bc8-b821-8d869921dda0", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )

	cCodIpm := "11"
	cDesCod := "Saída da Trading de mercadoria importada por conta e ordem de terceiros com destino ao adquirente e registrada nos CFOP 5949 ou 6949 e desde que não registradas nos CFOP  5101, 5102, 6101, 6102 e não se trate de simples remessa, devolução, retorno ou anulações.  (É Exigido TTD 998)"
	aAdd( aBody, { "", "c34239b0-65fe-ca32-c538-c2097b3aa176", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )

	cCodIpm := "12"
	cDesCod := "Exportação de produtos recebidos em transferência ou para fim específico de exportação a preço inferior ao da efetiva exportação, nos termos do disposto no art. 10-B do RICMS-SC."
	aAdd( aBody, { "", "25eebe16-26e6-fbf6-894b-8e27463939c9", cCodIpm, cDesCod, "20200101", ""		  , "000025", 1033.17} )
	
	cCodIpm := "13"
	cDesCod := "Exportação de produtos através de estabelecimento do mesmo titular localizado em outra UF, desde que o produto tenha sido transferido para a unidade exportadora a preço inferior ao da efetiva exportação, nos termos do disposto no art. 10-C do RICMS-SC."
	aAdd( aBody, {"", "ded3f22d-7d4f-d4db-7d25-6b9fe8140d32", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "14"
	cDesCod := "Geração de Energia Elétrica por fonte Hidráulica"
	aAdd( aBody, {"", "2deea585-f0a5-4df6-0c73-5f687024ea27", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "15"
	cDesCod := "Venda de energia elétrica adquirida de terceiros, realizada por estabelecimento gerador de energia elétrica por fonte hidráulica"
	aAdd( aBody, {"", "03323a22-2719-4d87-2fae-a662568df6bd", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "16"
	cDesCod := "Entrada da energia elétrica em estabelecimento gerador de energia elétrica por fonte hidráulica adquirida de terceiros, para comercialização."
	aAdd( aBody, {"", "2e5b17f6-458c-bb6d-5c65-45141830f1e4", cCodIpm, cDesCod, "20200101", "20240331", "000025", 1033.66} )

	cCodIpm := "17"
	cDesCod := "Índice de rateio do Valor Adicionado (VA) decorrente de Convenio ou Acordo entre municípios, mesmo que por ordem judicial."
	aAdd( aBody, {"", "5771ceaf-7a9b-750e-9d69-389ef94e779e", cCodIpm, cDesCod, "20200101", ""		  , "000025"} )

	cCodIpm := "18"
	cDesCod := "Prestação de serviço de telecomunicações, exceto os serviços previstos no art. 91 do Anexo 6 do RICMS/SC-01."
	aAdd( aBody, {"", "ec70f8b1-fcc5-7a31-f224-882e1e65613f", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "19"
	cDesCod := "Venda de energia elétrica por não distribuidor a consumidor independente, inclusive da parcela relativa à demanda contratada."
	aAdd( aBody, {"", "c29beb79-1e22-0e8f-4b06-764f85403c4d", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "20"
	cDesCod := "Distribuição de energia elétrica a consumidor pessoa física ou jurídica, inclusive a consumidor independente, também da demanda contratada."
	aAdd( aBody, {"", "833f9b5f-35a3-7db9-6b25-2075e6698185", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "21"
	cDesCod := "Fornecimento de gás natural."
	aAdd( aBody, {"", "dacc424d-0b96-7e51-af37-71746157d931", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "22"
	cDesCod := "Fornecimento de alimentos preparados (CNAE 5620101)."
	aAdd( aBody, {"", "4afd4910-bfc0-3bca-68c7-0d7550f4cba6", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "23"
	cDesCod := "Prestação de serviço de transporte de passageiros."
	aAdd( aBody, {"", "61cd043b-e4b0-c850-9598-47a9e76e04d2", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "24"
	cDesCod := "Produção ou extração primária própria acobertada por nota fiscal de transferência CFOP 1101 ou 1102 (Exige TTD)."
	aAdd( aBody, {"", "88a249fd-fe66-8884-65b6-df8697da784e", cCodIpm, cDesCod, "20240101", "20240430", "000025", 1033.66} )

	cCodIpm := "25"
	cDesCod := "Compra de insumos utilizados na prestação de serviço sujeito exclusivamente ao ISS, quando não especificados com os CFOP 1.933, 2.933, 1.128, 2.128 e 3.128."
	aAdd( aBody, {"", "ad89901c-2b0c-2b81-bff0-a6a86a7dd0cb", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	cCodIpm := "26"
	cDesCod := "Produção ou extração primária própria acobertada por nota fiscal de transferência CFOP 1151 ou 1152 (Exige TTD)."
	aAdd( aBody, {"", "aa8aaaa6-3dd1-9f1d-6e20-43dfc24f4246", cCodIpm, cDesCod, "20240101", ""		  , "000025", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//08. Rio de Janeiro  - 000020 //versão=12 (tb16440) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "RJREC00001"
	cDesCod := "Receita bruta anual do estabelecimento"
	aAdd( aBody, {"", "9482dd8b-824f-d166-2178-fbb877805b5c", cCodIpm, cDesCod, "20230501", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF20001"
	cDesCod := "Valor adicionado por operações e prestações não escrituradas, denunciadas espontaneamente ou apuradas em ação fiscal"
	aAdd( aBody, {"", "0e054b49-6670-6d23-cc82-87f7964eed4b", cCodIpm, cDesCod, "20190101", "20211231", "000020", 1033.66} )

	cCodIpm := "RJVAF20002"
	cDesCod := "Valor adicionado por aquisições de produtos agrícolas, pastoris, extrativos minerais, pescados ou outros produtos extrativos ou agropecuários sem nota fiscal de produtor"
	aAdd( aBody, {"", "97042238-4725-cc15-b923-b7b3f0140408", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF20003"
	cDesCod := "Valor adicionado pela prestação de serviço de transporte intermunicipal e interestadual"
	aAdd( aBody, {"", "62a25deb-9f3a-39b2-c306-0159547db405", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF20004"
	cDesCod := "Valor adicionado pelo fornecimento de energia elétrica por geradora hidrelétrica"
	aAdd( aBody, {"", "36f85f0b-3297-51ee-ce17-12c820a4af8d", cCodIpm, cDesCod, "20190101", "20211231", "000020", 1033.66} )

	cCodIpm := "RJVAF00005"
	cDesCod := "Prestação de serviço de comunicação ou telecomunicação oneroso para consumidor final - Valor das entradas"
	aAdd( aBody, {"", "df365e41-5b3f-1972-26b5-d2ce81f96740", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10005"
	cDesCod := "Prestação de serviço de comunicação ou telecomunicação oneroso para consumidor final - Valor das saídas"
	aAdd( aBody, {"", "a369672e-606d-a4cc-356d-a2f94a0a6420", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00006"
	cDesCod := "Inscrição estadual centralizada - Valor das entradas"
	aAdd( aBody, {"", "6dacae9c-6d08-fcfc-99e4-3de1f36381e6", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10006"
	cDesCod := "Inscrição estadual centralizada - Valor das saídas"
	aAdd( aBody, {"", "a5d545f7-401f-afce-9d7c-710d3cf6bd15", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00007"
	cDesCod := "Fornecimento de energia elétrica por distribuidora - Valor das entradas"
	aAdd( aBody, {"", "46a0b1f3-a079-a29b-5e56-1d06feeef14e", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10007"
	cDesCod := "Fornecimento de energia elétrica por distribuidora - Valor das saídas"
	aAdd( aBody, {"", "99af94f1-1f01-b843-728a-702fe712c221", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00008"
	cDesCod := "Fornecimento de água natural canalizada - Valor das entradas"
	aAdd( aBody, {"", "2e03045f-a997-9a8f-0c79-39f586ed44a4", cCodIpm, cDesCod, "20190101", "20191231", "000020", 1033.66} )

	cCodIpm := "RJVAF10008"
	cDesCod := "Fornecimento de água natural canalizada - Valor das saídas"
	aAdd( aBody, {"", "c03dac6d-ffe9-ac1b-1344-29c884753264", cCodIpm, cDesCod, "20190101", "20191231", "000020", 1033.66} )

	cCodIpm := "RJVAF00009"
	cDesCod := "Fornecimento de gás natural canalizado - Valor das entradas"
	aAdd( aBody, {"", "7bc04005-0d5e-a03f-fde6-aa3c77da8fd5", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10009"
	cDesCod := "Fornecimento de gás natural canalizado - Valor das saídas"
	aAdd( aBody, {"", "0645540c-331e-a07d-89a6-c2e4582ae0f9", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAR00010"
	cDesCod := "Fornecimento por geradora de energia elétrica gerada em modalidade distinta da hidrelétrica - Valor das entradas"
	aAdd( aBody, {"", "704637a3-02f0-2048-7a95-2dac67671e1c", cCodIpm, cDesCod, "20190101", "20240319", "000020", 1033.66} )

	cCodIpm := "RJVAF00010"
	cDesCod := "Fornecimento por geradora de energia elétrica gerada em modalidade distinta da hidrelétrica - Valor das entradas"
	aAdd( aBody, {"", "421b8027-7c6c-58da-ec81-e0adbb570ba1", cCodIpm, cDesCod, "20240320", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAR10010"
	cDesCod := "Fornecimento por geradora de energia elétrica gerada em modalidade distinta da hidrelétrica - Valor das saídas"
	aAdd( aBody, {"", "8188dcd3-5e0d-5be7-6267-b584483bddff", cCodIpm, cDesCod, "20190101", "20211231", "000020", 1033.66} )

	cCodIpm := "RJVAF10010"
	cDesCod := "Fornecimento por geradora de energia elétrica gerada em modalidade distinta da hidrelétrica - Valor das saídas"
	aAdd( aBody, {"", "4879e7c8-2e19-86a0-3bd1-ef5b5254d405", cCodIpm, cDesCod, "20220101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00011"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BLOCO DE EXPLORAÇÃO - Valor das entradas"
	aAdd( aBody, {"", "d58299f1-f84f-3552-5811-73896b498c6f", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10011"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BLOCO DE EXPLORAÇÃO - Valor das saídas"
	aAdd( aBody, {"", "04d7d22b-6da4-a62a-a915-1e609e64524f", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ALBACORA - Valor das entradas"
	aAdd( aBody, {"", "0f55772e-ad0c-66cc-9a41-b93a863dfbc1", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ALBACORA - Valor das saídas"
	aAdd(aBody, {"", "8e7a21c1-accb-63b5-bc70-f4355662d10d", cCodIpm, cDesCod, "20190101", ""         , "000020", 1033.66} )

	cCodIpm := "RJVAF00212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ALBACORA LESTE - Valor das entradas"
	aAdd(aBody, {"", "fc66d6c9-89c4-9093-eecb-8535360d95be", cCodIpm, cDesCod, "20190101", ""         , "000020", 1033.66} )

	cCodIpm := "RJVAF10212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ALBACORA LESTE - Valor das saídas"
	aAdd(aBody, {"", "485fa32e-2ed5-ae7a-033e-2a21db19e6b0", cCodIpm, cDesCod, "20190101", ""         , "000020", 1033.66} )

	cCodIpm := "RJVAF00312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ANEQUIM - Valor das entradas"
	aAdd(aBody, {"", "b7900a09-a38e-0cf4-0023-7ba734b8c433", cCodIpm, cDesCod, "20190101", ""         , "000020", 1033.66} )

	cCodIpm := "RJVAF10312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ANEQUIM - Valor das saídas"
	aAdd(aBody, {"", "4f193629-2f71-ea67-4a06-69e071326d3d", cCodIpm, cDesCod, "20190101", ""         , "000020", 1033.66} )

	cCodIpm := "RJVAF05812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ATAPU - Valor das entradas"
	aAdd(aBody, {"", "b68d2f8a-e392-9f23-c8bf-c3a897a92728", cCodIpm, cDesCod,  "20211011", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ATAPU - Valor das saídas"
	aAdd(aBody, {"", "e20dec63-5a2b-81a7-f636-a4bbaebdad69", cCodIpm, cDesCod, "20211011", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ATLANTA - Valor das entradas"
	aAdd(aBody, {"", "dad0d3fe-5c02-6676-51d4-9eef0913266f", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ATLANTA - Valor das saídas"
	aAdd(aBody, {"", "014a8341-f778-b1e7-0551-d3f6dc9169ac", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BADEJO - Valor das entradas"
	aAdd(aBody, {"", "78ea64e8-536a-d875-ae7e-aea1d5f96f83", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BADEJO - Valor das saídas"
	aAdd(aBody, {"", "f662b813-3b94-3d17-d238-f86552ee5b28", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BAGRE - Valor das entradas"
	aAdd(aBody, {"", "03b96c2a-9905-a8d4-1a7d-a52c150f7014", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BAGRE - Valor das saídas"
	aAdd(aBody, {"", "8f826ef1-3942-2c47-a06f-3421b733b8ab", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BARRACUDA - Valor das entradas"
	aAdd(aBody, {"", "ab2896c9-5264-a3d5-9ff0-53c6819d0d67", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BARRACUDA - Valor das saídas"
	aAdd(aBody, {"", "469611c3-b8ad-1849-0d4e-48f32c494eec", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BERBIGÃO - Valor das entradas"
	aAdd(aBody, {"", "d125cdb5-1957-4849-03b4-836ed633fecb", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BERBIGÃO - Valor das saídas"
	aAdd(aBody, {"", "9fdc0e2a-4e3e-2aee-0a30-69a58f0b77ef", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BICUDO - Valor das entradas"
	aAdd(aBody, {"", "3262e621-c658-f3ea-8827-989a78bc70aa", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BICUDO - Valor das saídas"
	aAdd(aBody, {"", "6fa86a38-c635-bcad-30d0-1d6cbdde3147", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BIJUPIRÁ - Valor das entradas"
	aAdd(aBody, {"", "fa92c77e-1f55-8d92-6080-30f22d9a66f1", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BIJUPIRÁ - Valor das saídas"
	aAdd( aBody, {"", "c34a8d10-df64-231d-d0d8-4dd0922f245e", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BONITO - Valor das entradas"
	aAdd( aBody, {"", "2806a9d4-23b2-e1ab-d39f-263905556df8", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BONITO - Valor das saídas"
	aAdd( aBody, {"", "70cef180-a468-ee9a-e40c-79a5244776d5", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BÚZIOS - Valor das entradas"
	aAdd( aBody, {"", "b6e8d82e-0376-c004-a3bd-56006ce67d6f", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BÚZIOS - Valor das saídas"
	aAdd( aBody, {"", "bc517165-1254-abdc-300a-4747605ca148", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CARAPEBA - Valor das entradas"
	aAdd( aBody, {"", "b45b1943-be20-a9cb-96e3-fcf0d7711f41", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11312"
	cDesCod := "Atividades de extração e produção de petróleo e gás -CARAPEBA - Valor das saídas"
	aAdd( aBody, {"", "2fe46201-c191-d379-cde9-de268d914428", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01412"
	cDesCod := "Atividades de extração e produção de petróleo e gás -CARATINGA - Valor das entradas"
	aAdd( aBody, {"", "c074daa7-55d0-12a3-a2c5-d790323f536d", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CARATINGA - Valor das saídas"
	aAdd( aBody, {"", "f0da2830-8c74-0190-6ec5-9ff8ef615022", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CHERNE - Valor das entradas"
	aAdd( aBody, {"", "9fe18653-d4e2-df52-ede5-1e64281cf1d1", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CHERNE - Valor das saídas"
	aAdd( aBody, {"", "801fb85c-630d-db14-81a4-1574e4926f9b", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CONGRO - Valor das entradas"
	aAdd( aBody, {"", "bf4b1e94-8461-9004-7fb2-ad61b927133a", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CONGRO - Valor das saídas"
	aAdd( aBody, {"", "fbf1868f-7a73-6be9-c206-63fd568ea9c9", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CORVINA - Valor das entradas"
	aAdd( aBody, {"", "b7598482-0ec8-b6a2-186d-5a68bf0e248e", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - CORVINA - Valor das saídas"
	aAdd( aBody, {"", "5b877dd6-dce1-ff13-5eeb-622899d25b8f", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ENCHOVA - Valor das entradas"
	aAdd( aBody, {"", "5968e3d0-b325-e0b6-b584-0543db5ec52b", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ENCHOVA - Valor das saídas"
	aAdd( aBody, {"", "bc9e8877-954f-1608-9a27-61362fa90434", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF01912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ENCHOVA OESTE - Valor das entradas"
	aAdd( aBody, {"", "e620242b-828d-f80e-dae3-16a98177ac3e", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF11912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ENCHOVA OESTE - Valor das saídas"
	aAdd( aBody, {"", "af80ff58-f22e-f617-d8b5-ac496bfd16db", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ESPADARTE - Valor das entradas"
	aAdd( aBody, {"", "0c4d7619-ca88-9d5e-596b-e95a0a5f5131", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12012"
	cDesCod := "Atividades de extração e produção de petróleo e gás -ESPADARTE - Valor das saídas"
	aAdd( aBody, {"", "ef85d3d3-dd0f-9f4c-adc1-2a523a63c240", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - FRADE - Valor das entradas"
	aAdd( aBody, {"", "1c087e10-efb8-aa4a-0654-34c1677653f8", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - FRADE - Valor das saídas"
	aAdd( aBody, {"", "5ed76729-d882-9842-3e30-5be02f927090", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - GAROUPA - Valor das entradas"
	aAdd( aBody, {"", "6c27d167-c81d-fabe-8cd2-f4177ab40c95", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - GAROUPA - Valor das saídas"
	aAdd( aBody, {"", "f6e752ab-214f-4dec-c2a7-4de92fc69a52", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - GAROUPINHA - Valor das entradas"
	aAdd( aBody, {"", "402a5217-5217-c433-bedd-ede315efff99", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - GAROUPINHA - Valor das saídas"
	aAdd( aBody, {"", "0dbb7af0-45a4-dc2f-2ef0-66f90950c54d", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ITAPU - Valor das entradas"
	aAdd( aBody, {"", "d3b38333-a6bc-c82e-971e-5ebb1d118882", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ITAPU - Valor das saídas"
	aAdd( aBody, {"", "0a5dda7a-8123-9b91-c67b-2a702c80a526", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - LINGUADO - Valor das entradas"
	aAdd( aBody, {"", "61c1b959-7001-7c0e-a564-37b89fe7992c", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - LINGUADO - Valor das saídas"
	aAdd( aBody, {"", "c3cb2af0-0a60-dbc7-289c-34b3963844e2", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - LULA - Valor das entradas"
	aAdd( aBody, {"", "dc6849bf-c2f2-af5a-3520-0bd4a521d890", cCodIpm, cDesCod, "20190101", "20210930", "000020", 1033.66} )

	cCodIpm := "RJVAF12612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - LULA - Valor das saídas"
	aAdd( aBody, {"", "82bd9be0-24c2-c277-5176-2b15412176ed", cCodIpm, cDesCod, "20190101", "20210930", "000020", 1033.66} )

	cCodIpm := "RJVAF02712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MALHADO - Valor das entradas"
	aAdd( aBody, {"", "11fe33d7-5a29-f782-1a29-12e59ca47b38", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MALHADO - Valor das saídas"
	aAdd( aBody, {"", "3187aa05-41ac-aec0-3e86-c34010221af1", cCodIpm, cDesCod,  "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARIMBÁ - Valor das entradas"
	aAdd( aBody, {"", "53cf71bb-be64-7ae6-89f6-155033e16a1e", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARIMBÁ - Valor das saídas"
	aAdd( aBody, {"", "fcaf8ecf-5913-0de3-03f4-13d107b20db9", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARLIM - Valor das entradas"
	aAdd( aBody, {"", "ca76d4e1-838f-ebe1-b829-416f548c08f7", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARLIM - Valor das saídas"
	aAdd( aBody, {"", "55aad130-d4fb-dc8d-fc1d-0e6c3650a9fa", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARLIM LESTE - Valor das entradas"
	aAdd( aBody, {"", "f8284ba9-a923-a88b-9ef6-14b782523221", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARLIM LESTE - Valor das saídas"
	aAdd( aBody, {"", "e9a88561-f474-b547-4928-f1553825c609", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARLIM SUL - Valor das entradas"
	aAdd( aBody, {"", "f214dcba-8fa0-015c-e77e-791d36930025", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MARLIM SUL - Valor das saídas"
	aAdd( aBody, {"", "d3b2d770-8d4e-d27b-b710-e7a9fe994a25", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MORÉIA - Valor das entradas"
	aAdd( aBody, {"", "87eedb69-1646-dff0-1a11-0380c4f32322", cCodIpm, cDesCod, "20190101", "20210930", "000020", 1033.66} )

	cCodIpm := "RJVAF13212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MORÉIA - Valor das saídas"
	aAdd( aBody, {"", "fe1b8d38-a1cf-f27e-e00e-a1059e1a8511", cCodIpm, cDesCod, "20190101", "20210930", "000020", 1033.66} )

	cCodIpm := "RJVAF03212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MOREIA - Valor das entradas"
	aAdd( aBody, {"", "2faba896-162c-1998-6a0b-fa1abbe95df3", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MOREIA - Valor das saídas"
	aAdd( aBody, {"", "47118443-ca96-7a13-1996-bc6b68588425", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NAMORADO - Valor das entradas"
	aAdd( aBody, {"", "1b6d0cbe-a9ec-cda4-5331-60a15047b306", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NAMORADO - Valor das saídas"
	aAdd( aBody, {"", "787ecc1a-8481-ac37-fcea-7655e1c488c7", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NE NAMORADO - Valor das entradas"
	aAdd( aBody, {"", "84fa02d1-2694-bd54-0fb9-f82609956674", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NE NAMORADO - Valor das saídas"
	aAdd( aBody, {"", "dfb45bb4-b994-cc7a-905a-b227117eeffd", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NORDESTE DE SAPINHOA - Valor das entradas"
	aAdd( aBody, {"", "8418408a-7cbb-da74-6677-5b756aa65f6e", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NORDESTE DE SAPINHOA - Valor das saídas"
	aAdd( aBody, {"", "3b46f6b5-0a0d-46ef-838b-18f67ba08235", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - OESTE DE ATAPU - Valor das entradas"
	aAdd( aBody, {"", "a2886c33-855b-b6ed-fe98-69c9bff0c83c", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - OESTE DE ATAPU - Valor das saídas"
	aAdd( aBody, {"", "26c8ff51-3c76-7da6-6c69-430f441e8ea3", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PAMPO - Valor das entradas"
	aAdd( aBody, {"", "5f9c0243-9d80-505d-008e-5d1f355447a8", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PAMPO - Valor das saídas"
	aAdd( aBody, {"", "c7e3e2d6-4a0d-3dff-38ae-9e1568b751fb", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PAPA-TERRA - Valor das entradas"
	aAdd( aBody, {"", "ec8106e1-fd19-d2f9-18c0-86a82c24385d", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PAPA-TERRA - Valor das saídas"
	aAdd( aBody, {"", "87ad0823-c23c-8158-ec32-927e24c3ffbc", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PARATI - Valor das entradas"
	aAdd( aBody, {"", "240f8f5b-31db-5f23-38b1-73179f77b393", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PARATI - Valor das saídas"
	aAdd( aBody, {"", "4e0d631c-eb92-0024-3bde-72ece9853eac", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PARGO - Valor das entradas"
	aAdd( aBody, {"", "669f1d92-f297-1fcc-39a8-4c1b54634de1", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PARGO - Valor das saídas"
	aAdd( aBody, {"", "6cd96037-7287-3506-68cf-9a3139a992df", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF03912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PEREGRINO - Valor das entradas"
	aAdd( aBody, {"", "63e6f103-1ce0-a7ec-63e2-536e8a812fe1", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF13912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PEREGRINO - Valor das saídas"
	aAdd( aBody, {"", "7df55424-10f6-8e5f-7188-4085c69418d4", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PIRAÚNA - Valor das entradas"
	aAdd( aBody, {"", "f81bb887-2c35-8d4d-1c9f-d18135c04c21", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PIRAÚNA - Valor das saídas"
	aAdd( aBody, {"", "a552e271-66b4-e931-f63f-a5dfa0c8aad9", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - POLVO - Valor das entradas"
	aAdd( aBody, {"", "14308053-cfcc-507f-8184-366f64b83af3", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - POLVO - Valor das saídas"
	aAdd( aBody, {"", "e5506504-c94c-579a-bf6f-8cd36791066b", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - RONCADOR - Valor das entradas"
	aAdd( aBody, {"", "7dbc36e8-c974-4b15-bdca-40d7e3162b5e", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - RONCADOR - Valor das saídas"
	aAdd( aBody, {"", "8d0320a7-8930-87aa-2651-c5d232bcea18", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SALEMA - Valor das entradas"
	aAdd( aBody, {"", "daa976b5-01af-6eb0-6a54-1ca26838517b", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SALEMA - Valor das saídas"
	aAdd( aBody, {"", "84589617-8d0c-780d-236a-7bbc5fed4169", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SAPINHOÁ - Valor das entradas"
	aAdd( aBody, {"", "7de6735a-94da-8517-49dc-1260cf75e5fd", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SAPINHOÁ - Valor das saídas"
	aAdd( aBody, {"", "cd146daa-3633-00a4-d661-96d6ddeaa562", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SÉPIA - Valor das entradas"
	aAdd( aBody, {"", "bf61f032-b461-0809-1288-5e75cc6d8de3", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SÉPIA - Valor das saídas"
	aAdd( aBody, {"", "81f2240f-89d0-0fc1-e943-0630f52cbb7a", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE LULA - Valor das entradas"
	aAdd( aBody, {"", "69f7cd17-0239-a72a-709e-5c96e4d2b03c", cCodIpm, cDesCod, "20190101", "20210930", "000020", 1033.66} )

	cCodIpm := "RJVAF14612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE LULA - Valor das saídas"
	aAdd( aBody, {"", "b2f6e8f2-9f5a-325e-db7e-2bb00b1a3486", cCodIpm, cDesCod, "20190101", "20210930", "000020", 1033.66} )

	cCodIpm := "RJVAF04612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE TUPI - Valor das entradas"
	aAdd( aBody, {"", "23827375-b004-3210-8ab7-4b7503d278fd", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE TUPI - Valor das saídas"
	aAdd( aBody, {"", "77e5a1b4-c985-a663-d98b-d0d85261d4cb", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SURURU - Valor das entradas"
	aAdd( aBody, {"", "807e8298-7fb9-3379-25d6-9866b71a5d0a", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SURURU - Valor das saídas"
	aAdd( aBody, {"", "eded6659-c3e9-4da6-3856-88819bb3fa46", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TAMBAÚ - Valor das entradas"
	aAdd( aBody, {"", "51c0d729-0ed6-672e-ee4c-0475229f38dc", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TAMBAÚ - Valor das saídas"
	aAdd( aBody, {"", "c0ac77a0-92f5-cb28-fb97-c413f62ca3ef", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TARTARUGA VERDE - Valor das entradas"
	aAdd( aBody, {"", "d92e710a-a62e-74da-a73a-36efbda3a068", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TARTARUGA VERDE - Valor das saídas"
	aAdd( aBody, {"", "578d15ed-6739-ac23-5548-eb91eb893390", cCodIpm, cDesCod,  "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF04912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TRILHA - Valor das entradas"
	aAdd( aBody, {"", "74f6dfea-ef9c-32b0-83df-ee44879d537c", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF14912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TRILHA - Valor das saídas"
	aAdd( aBody, {"", "d3ff9a76-2df3-834e-74b1-47bb9eca0de2", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TUBARÃO AZUL - Valor das entradas"
	aAdd( aBody, {"", "a6da9f39-b39e-bb9a-050e-5c1cd4de61c4", cCodIpm, cDesCod,  "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TUBARÃO AZUL - Valor das saídas"
	aAdd( aBody, {"", "6e2dc93e-f5a6-4551-876d-445445dd9512", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TUBARÃO MARTELO - Valor das entradas"
	aAdd( aBody, {"", "3e008f38-a8f8-7b80-a70f-08b5d340b067", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TUBARÃO MARTELO - Valor das saídas"
	aAdd( aBody, {"", "f808da01-1e41-6484-306e-e412eab50d57", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - URUGUÁ - Valor das entradas"
	aAdd( aBody, {"", "ab92297a-349b-2451-9308-4ff091736153", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - URUGUÁ - Valor das saídas"
	aAdd( aBody, {"", "3391d1a5-5d1d-e603-844f-04f0068a84de", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - VERMELHO - Valor das entradas"
	aAdd( aBody, {"", "942acedf-0258-cc6f-7876-0cac8358d59d", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - VERMELHO - Valor das saídas"
	aAdd( aBody, {"", "a74d8185-173b-25e9-f144-6de2e51697c7", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - VIOLA - Valor das entradas"
	aAdd( aBody, {"", "2d9c9a6c-b0a0-620d-4063-d0005ddf64da", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - VIOLA - Valor das saídas"
	aAdd( aBody, {"", "2119855d-435d-7305-e614-df93f73ba709", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - VOADOR - Valor das entradas"
	aAdd( aBody, {"", "604ac698-9a08-7ff7-584e-95bbb67b833c", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - VOADOR - Valor das saídas"
	aAdd( aBody, {"", "96251abe-b74a-8826-1d2b-99196fbfc9ec", cCodIpm, cDesCod, "20190101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MERO - Valor das entradas"
	aAdd( aBody, {"", "bea95098-63ab-bcba-b3e9-a37d16d2cae0", cCodIpm, cDesCod, "20200101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MERO - Valor das saídas"
	aAdd( aBody, {"", "688c902e-66bf-f252-cf3c-abe2f38236c0", cCodIpm, cDesCod, "20200101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF05712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TAMBUATÁ - Valor das entradas"
	aAdd( aBody, {"", "bb4d2ebc-39d6-1153-85c3-f86dd073b470", cCodIpm, cDesCod, "20200101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF15712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TAMBUATÁ - Valor das saídas"
	aAdd( aBody, {"", "20adff2a-134c-75f3-83bb-ecf33f93bbbe", cCodIpm, cDesCod,  "20200101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TARTARUGA VERDE SUDOESTE - Valor das entradas"
	aAdd( aBody, {"", "3e350dcc-d570-74da-d9c5-fb95ca1549cd", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TARTARUGA VERDE SUDOESTE - Valor das saídas"
	aAdd( aBody, {"", "ae0590d9-fbab-7a6c-1057-89df6c7db9a0", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF02612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TUPI - Valor das entradas"
	aAdd( aBody, {"", "4636bebf-dd59-4923-8bd2-e6887367d52f", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF12612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - TUPI - Valor das saídas"
	aAdd( aBody, {"", "e945eef7-e239-bf1b-7db3-3d4492509048", cCodIpm, cDesCod, "20211001", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ATAPU_ECO - Valor das entradas"
	aAdd( aBody, {"", "e31ce2bf-ca0b-0ae6-8b54-54ff69ae948b", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ATAPU_ECO - Valor das saídas"
	aAdd( aBody, {"", "54a36b14-27c4-257a-25c1-d5be3c4f20d7", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BUZIOS_ECO - Valor das entradas"
	aAdd( aBody, {"", "2264b5d5-8e47-1c7e-817a-1c043e508679", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - BUZIOS_ECO - Valor das saídas"
	aAdd( aBody, {"", "ad91d714-c094-ea16-b9e1-1d281745f1d9", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ESPADIM - Valor das entradas"
	aAdd( aBody, {"", "5be412ec-3280-fa02-3396-dc0f26f4a772", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ESPADIM - Valor das saídas"
	aAdd( aBody, {"", "a476ff21-1d54-064b-ecda-af068781a003", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ITAPU_ECO - Valor das entradas"
	aAdd( aBody, {"", "acfc15a0-df43-c6b8-9e9f-c40ab93c7829", cCodIpm, cDesCod,  "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - ITAPU_ECO - Valor das saídas"
	aAdd( aBody, {"", "9977bb52-1313-551e-08da-5d466607e941", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MANJUBA - Valor das entradas"
	aAdd( aBody, {"", "cf20ab60-db24-269d-8031-925dc595354d", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16712"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MANJUBA - Valor das saídas"
	aAdd( aBody, {"", "b63e8ee2-f9f7-f37e-0117-ff8d676547d2", cCodIpm, cDesCod,  "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NORTE DE BERBIGÃO - Valor das entradas"
	aAdd( aBody, {"", "abd4ab4b-e300-2656-48fd-fb750a7293ad", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16812"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NORTE DE BERBIGÃO - Valor das saídas"
	aAdd( aBody, {"", "a60e69f7-a1ea-4499-f499-1742ec682825", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF06912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NORTE DE SURURU - Valor das entradas"
	aAdd( aBody, {"", "38630704-80b6-b478-95d1-317f7ce2cccd", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF16912"
	cDesCod := "Atividades de extração e produção de petróleo e gás - NORTE DE SURURU - Valor das saídas"
	aAdd( aBody, {"", "0e602ed8-5886-46eb-e0c0-fc3d65a0efa9", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - OLIVA - Valor das entradas"
	aAdd( aBody, {"", "b9420eaa-4979-aab4-2fd7-948bae42fb85", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17012"
	cDesCod := "Atividades de extração e produção de petróleo e gás - OLIVA - Valor das saídas"
	aAdd( aBody, {"", "9e9d3813-1a89-091b-f977-7ed8dabf30fd", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PITANGOLA - Valor das entradas"
	aAdd( aBody, {"", "fc3ea2ad-c167-281f-2c33-26273f24ea45", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17112"
	cDesCod := "Atividades de extração e produção de petróleo e gás - PITANGOLA - Valor das saídas"
	aAdd( aBody, {"", "ade174e7-198a-9466-12c8-d03fe688f817", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SÉPIA LESTE - Valor das entradas"
	aAdd( aBody, {"", "67e8391d-4b06-37a1-a831-14fc3becd1a8", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17212"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SÉPIA LESTE - Valor das saídas"
	aAdd( aBody, {"", "93ae0462-f71b-8f29-b7d4-59d0430b77eb", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SÉPIA_ECO - Valor das entradas"
	aAdd( aBody, {"", "b5ac4808-e141-84f5-c503-ad85f48a051d", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17312"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SÉPIA_ECO - Valor das saídas"
	aAdd( aBody, {"", "06b57618-6d79-f167-6284-f53ebc0c7da1", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE BERBIGÃO - Valor das entradas"
	aAdd( aBody, {"", "e59098e0-b819-25d9-caae-cd8c4643e696", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17412"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE BERBIGÃO - Valor das saídas"
	aAdd( aBody, {"", "992820bb-df9b-f35b-e35f-c57bef00d815", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE SURURU - Valor das entradas"
	aAdd( aBody, {"", "78a221d5-608e-0046-576f-52e5da5347b0", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17512"
	cDesCod := "Atividades de extração e produção de petróleo e gás - SUL DE SURURU - Valor das saídas"
	aAdd( aBody, {"", "718cc99c-c01b-a64f-8cb9-5a6fbfb6c052", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF07612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MAROMBA - Valor das entradas"
	aAdd( aBody, {"", "0118b4a9-4c4e-ca94-afd4-2ed07c52564b", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF17612"
	cDesCod := "Atividades de extração e produção de petróleo e gás - MAROMBA - Valor das saídas"
	aAdd( aBody, {"", "cd700ad7-3427-a4b0-2937-18aff3940126", cCodIpm, cDesCod, "20240401", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00013"
	cDesCod := "Prestação de Serviço de comunicação ou telecomunicação gratuito para consumidor final - Valor das entradas"
	aAdd( aBody, {"", "bec8717a-e660-2c7b-319d-2995d7fa520f", cCodIpm, cDesCod, "20200101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10013"
	cDesCod := "Prestação de Serviço de comunicação ou telecomunicação gratuito para consumidor final - Valor das saídas"
	aAdd( aBody, {"", "8506b1d1-66a5-1e53-93b5-1969b360dddf", cCodIpm, cDesCod, "20200101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10014"
	cDesCod := "Fornecimento por geradora de energia elétrica gerada em modalidade hidrelétrica - Valor das saídas"
	aAdd( aBody, {"", "8609afdb-c73c-d892-3f90-1e803f418522", cCodIpm, cDesCod, "20220101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10015"
	cDesCod := "Prestação de serviço de transporte intermunicipal e interestadual por contribuinte enquadrado na Lei 2.778/97 - Valor das saídas"
	aAdd( aBody, {"", "e29c4c90-8018-6d36-8fe0-80efee219cad", cCodIpm, cDesCod, "20240101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00015"
	cDesCod := "Prestação de serviço de transporte intermunicipal e interestadual por contribuinte enquadrado na Lei 2.778/97 - Valor das entradas"
	aAdd( aBody, {"", "92dfe421-37f5-efdc-b086-11161d9556eb", cCodIpm, cDesCod, "20240101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10016"
	cDesCod := "Prestação de serviço de transporte intermunicipal e interestadual por contribuinte enquadrado na Lei 2.804/97 - Valor das saídas"
	aAdd( aBody, {"", "d405c849-9042-5a5f-3fb2-f2631b0e3301", cCodIpm, cDesCod, "20240101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00016"
	cDesCod := "Prestação de serviço de transporte intermunicipal e interestadual por contribuinte enquadrado na Lei 2.804/97 - Valor das entradas"
	aAdd( aBody, {"", "b78db7d3-e635-d9ef-b676-4322c52a7b3b", cCodIpm, cDesCod, "20240101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF10017"
	cDesCod := "Prestação de serviço de transporte intermunicipal e interestadual por contribuinte enquadrado na Lei 2.869/97 - Valor das saídas"
	aAdd( aBody, {"", "e4ea9427-f89e-e175-2654-ae89bdea9e0f", cCodIpm, cDesCod, "20240101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF00017"
	cDesCod := "Prestação de serviço de transporte intermunicipal e interestadual por contribuinte enquadrado na Lei 2.869/97 - Valor das entradas"
	aAdd( aBody, {"", "7b662494-1cff-35a4-4166-d443abe90162", cCodIpm, cDesCod, "20240101", ""        , "000020", 1033.66} )

	cCodIpm := "RJVAF30001"
	cDesCod := "Revendedor autônomo - venda porta a porta"
	aAdd( aBody, {"", "2df52d90-cfc3-a695-6768-4d9d5326c371", cCodIpm, cDesCod, "20240101", "20240101", "000020", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//09. Piaui  - 000018 //versão=1 (tb14524) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "PI001"
	cDesCod := "Geradoras de energia solar ou eólica com geração em município(s) diverso(s) de sua sede"
	aAdd( aBody, {"", "10e971fa-b48a-ddf8-0a10-6e46c584a955", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI002"
	cDesCod := "Distribuidoras de energia elétrica"
	aAdd( aBody, {"", "c37665f6-36f5-48a4-989a-817b2b8cea29", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI003"
	cDesCod := "Prestadores de serviços de comunicação e telecomunicação"
	aAdd( aBody, {"", "85d0cd0d-1124-462f-6154-122b12a822bf", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI004"
	cDesCod := "Prestadores de serviço de transporte rodoviário intermunicipal e interestadual de passageiros e de cargas"
	aAdd( aBody, {"", "efcf3c23-0d3e-e34d-3237-299cb8c5171a", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI005"
	cDesCod := "Prestadores de serviços de transporte ferroviário intermunicipal e interestadual"
	aAdd( aBody, {"", "dbd3ba8e-ecfc-5b17-4418-084c96c2d904", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI006"
	cDesCod := "Produtores e industriais que realizem operações com produtos agropecuários ou hortifrutigranjeiros adquiridos/recebidos de produtor rural sem a emissão da respectiva nota fiscal pelo remetente"
	aAdd( aBody, {"", "00889981-5ddf-8911-0d41-f6deb65712db", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI007"
	cDesCod := "Produtores rurais, extratores, ou industriais que efetuem, total ou parcialmente sua produção ou extração em município(s) diverso(s) de sua sede"
	aAdd( aBody, {"", "47a16036-d0ba-5cf3-702f-fae119d0a144", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI008"
	cDesCod := "Mineradoras, na hipótese de a jazida se estender por mais de um município piauiense"
	aAdd( aBody, {"", "2e7429e1-2040-4841-1a49-f85e104167a4", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI009"
	cDesCod := "Contribuintes que realizem saídas de mercadorias em estabelecimento localizado em município diverso daquele onde ocorreu a efetiva comercialização"
	aAdd( aBody, {"", "414a6c78-d5ed-24b9-3ccf-a03ad9b6e5f2", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI010"
	cDesCod := "Contribuintes que realizem operações de marketing porta a porta a consumidor final"
	aAdd( aBody, {"", "a10b6e99-dbe1-d159-ddd5-1f66cc3198f9", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	cCodIpm := "PI011"
	cDesCod := "Cooperativas que realizem operações com mercadorias recebidas para depósito"
	aAdd( aBody, {"", "ab0f73d0-2fff-875d-44c3-76be9d83e146", cCodIpm, cDesCod, "20201201", ""        , "000018", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//10. Paraná  - 000019 //versão=4 (tb16089)
	////////////////////////////////////////////////////////////////////
	cCodIpm := "PRGERAEE01"
	cDesCod := "Geração de Energia, efetuada por contribuinte com CNAE principal 3511-5/01. O valor correspondente ao total mensal da energia gerada pela usina hidrelétrica deve ser informado para o município onde se encontra a casa de máquinas, conforme § 14 do artigo 3º da Lei Complementar n.º 63/1990 ou como determinado em decisão judicial transitada em julgado."
	aAdd( aBody, {"", "3d75ec8b-10ec-d859-8a76-8af87370b54e", cCodIpm, cDesCod, "20210501", ""        , "000019", 1033.66} )

	cCodIpm := "PRTRANSMEE01"
	cDesCod := "Transmissão de Energia, efetuada por contribuinte com CNAE principal 3512-3/00. O valor correspondente aos encargos devidos pelo uso dos sistemas de transmissão e de conexão deve ser informado para o município ao qual estiver conectado o destinatário, de acordo com Convênio ICMS n.º 117/2004."
	aAdd( aBody, {"", "18bb0696-f6d5-675c-3568-54b2be15000e", cCodIpm, cDesCod, "20210501", ""        , "000019", 1033.66} )

	cCodIpm := "PRDISTRIBEE01"
	cDesCod := "Distribuição de Energia, efetuada por contribuinte com CNAE principal 3514-0/00. O valor correspondente ao total mensal do produto fornecido deve ser informado para o município onde ocorreu o fornecimento."
	aAdd( aBody, {"", "f210d700-2342-5e30-463d-1119b31dc3f4", cCodIpm, cDesCod, "20210501", ""        , "000019", 1033.66} )

	cCodIpm := "PRCOMERCEE01"
	cDesCod := "Comercialização de Energia, efetuada por contribuinte com CNAE principal 3513-1/00. O valor correspondente ao total mensal do produto comercializado deve ser informado para o município onde estiver conectado o destinatário."
	aAdd( aBody, {"", "c3b80ce7-cec3-f32e-1b16-fd02f0af331b", cCodIpm, cDesCod, "20210501", ""        , "000019", 1033.66} )

	cCodIpm := "PRCOMUNIC01"
	cDesCod := "Prestação de serviço de Comunicação ou Telecomunicação, efetuada por contribuinte com CNAE principal 6022-5/01 a 6190-6/99. O valor correspondente às prestações de serviço deve ser informado para o município onde o serviço foi prestado."
	aAdd( aBody, {"", "2423f62d-2f86-5680-3fa8-290735c83d50", cCodIpm, cDesCod, "20210501", ""        , "000019", 1033.66} )

	cCodIpm := "PREPPP01"
	cDesCod := "Contribuinte com CNAE principal 0111-3/01 a 0322-1/99; 1011-2/01 a 1322-7/00; 1610-2/01 a 1749-4/00; 1931-4/00; 4621-4/00 a 4634-6/99 ou 4671-1/00, informar ENTRADAS DE PRODUTOS PRÓPRIOS PRIMÁRIOS - EPPP - por ele produzidos em propriedade rural da qual é responsável, para o município onde ocorreu a produção, INCLUSIVE QUANDO A ENTRADA SE DER A PARTIR DO MUNICÍPIO SEDE DO ESTABELECIMENTO. NÃO INFORMAR OPERAÇÕS DE PARCERIA, INTEGRAÇÃO OU AQUISIÇÃO DE PRODUTOS PRIMÁRIOS DE PRODUTORES RURAIS."
	aAdd( aBody, {"", "6bb65be8-244c-2421-380a-1e67f616fc13", cCodIpm, cDesCod, "20210501", ""        , "000019", 1033.66} )

	cCodIpm := "PREPPPSEMNF01"
	cDesCod := "Para contribuintes com os mesmos CNAE do código PREPPP01, INFORMAR SOMENTE QUANDO NÃO FOI EMITIDO DOCUMENTO FISCAL DE ENTRADA, para Entradas de Produtos Próprios Primários - EPPP -  por ele produzidos em propriedade rural da qual é responsável, para o município onde ocorreu a produção, INCLUSIVE QUANDO A ENTRADA SE DER A PARTIR DO MUNICÍPIO SEDE DO ESTABELECIMENTO. NÃO INFORMAR OPERAÇÕS DE PARCERIA, INTEGRAÇÃO OU AQUISIÇÃO DE PRODUTOS PRIMÁRIOS DE PRODUTORES RURAIS."
	aAdd( aBody, {"", "88620397-485a-41f7-7df1-9992791cf084", cCodIpm, cDesCod, "20210501", "20231231", "000019", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//11. Pará 000015 -  //versão=1 (tb16336) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "PACOME01"
	cDesCod := "Aquisição de serviços de Comunicação/Telecomunicação - valor contábil das entradas e aquisições de serviço de comunicação, por município paraense, proporcionalmente às saídas, excluindo-se as operações dedutíveis."
	aAdd( aBody, {"", "4289c5dd-1494-c881-4472-0dfbbca5d9de", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PACOMS01"
	cDesCod := "Prestação de serviços de Comunicação/Telecomunicação - valor contábil das saídas e prestações de serviço de comunicação, por município paraense onde ocorreu a prestação, excluindo-se as operações dedutíveis."
	aAdd( aBody, {"", "a4724f28-93dd-b52f-f534-1c334c96e1bf", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAGEEE01"
	cDesCod := "Geração de Energia, exceto hidrelétricas - Entradas - valor contábil das operações das entradas e insumos utilizados na geração de energia elétrica, por município paraense, proporcionalmente às saídas, excluindo-se as operações dedutíveis."
	aAdd( aBody, {"", "f9f79a2d-e7ac-8865-3758-785dae1ec415", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAGEES01"
	cDesCod := "Geração de Energia, exceto hidrelétrica - Saídas - valor contábil das operação das saídas de geração de energia, exceto hidrelétrica, por município paraense onde ocorreu o fato gerador, excluindo-se as operações dedutíveis."
	aAdd( aBody, {"", "7935e3d7-d65e-ea66-b647-0eb0de23aa23", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PADEEE01"
	cDesCod := "Distribuição de Energia Elétrica - Entradas - valor contábil das operações das entradas e insumos utilizados na distribuição de energia elétrica, por município paraense, proporcionalmente às saídas, excluindo-se as operações dedutíveis."
	aAdd( aBody, {"", "3cf9cac3-e8e6-2f10-50ce-b315ac876cfc", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PADEES01"
	cDesCod := "Distribuição de Energia Elétrica - Saídas - valor contábil das operação das saídas de distribuição de energia elétrica, por município paraense onde ocorreu o fornecimento, excluindo-se as operações dedutíveis."
	aAdd( aBody, {"", "b492e684-6c93-7b69-b90d-63cdbe07f8ba", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEE99"
	cDesCod := "Exclusões das Entradas - Informar outros ajustes específicos necessários, que devam reduzir os valores de entrada, definidos pela SEFA-PA."
	aAdd( aBody, {"", "513fa76a-63f5-62ef-029a-5928278114e0", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAES99"
	cDesCod := "Exclusões das Saídas - Informar outros ajustes específicos necessários, que devam reduzir os valores de saída, definidos pela SEFA-PA."
	aAdd( aBody, {"", "ac72269e-26cd-dc27-7fee-0f44aa7ee104", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAIE99"
	cDesCod := "Inclusões das Entradas - Informar outros ajustes específicos necessários, que devam aumentar os valores de entrada, definidos pela SEFA-PA."
	aAdd( aBody, {"", "463f66ef-7397-01d8-edf2-a21aacbd512a", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAIS99"
	cDesCod := "Inclusões das Saídas - Informar outros ajustes específicos necessários, que devam aumentar os valores de saída, definidos pela SEFA-PA."
	aAdd( aBody, {"", "83f42fd0-f119-6a66-7b11-99845e8768c9", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAESPE01"
	cDesCod := "Entradas - Empresas que possuam inscrição centralizada, concedida mediante regime especial e que não estejam relacionadas nos demais códigos."
	aAdd( aBody, {"", "f44b39b3-916b-e4c8-c6e9-ac0006ae1182", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAESPS01"
	cDesCod := "Saídas - Empresas que possuam inscrição centralizada, concedida mediante regime especial e que não estejam relacionadas nos demais códigos."
	aAdd( aBody, {"", "762961a8-bbdf-84a0-4875-de23323d36b3", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXTE01"
	cDesCod := "Entradas - Extração de minério e de substâncias minerais para empresas que possuam mina situada, geograficamente, em mais de um Município."
	aAdd( aBody, {"", "1220b28f-96d2-c13a-5e7c-fbea4120c0ed", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXTS01"
	cDesCod := "Saídas - Extração de minério e de substâncias minerais para empresas que possuam mina situada, geograficamente, em mais de um Município."
	aAdd( aBody, {"", "a193a163-182f-c3ec-1bde-ab51e93bb73f", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT01"
	cDesCod := "Mão de Obra Direta."
	aAdd( aBody, {"", "b1a8f05a-93d6-8560-a1ad-28d842dfb0d2", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT02"
	cDesCod := "Mão de obra indireta."
	aAdd( aBody, {"", "4ee03fe8-d935-5cc3-6245-86cb56633bc4", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT03"
	cDesCod := "Custo com transporte na mina."
	aAdd( aBody, {"", "c875cc64-c939-8e0f-2bf1-ab38f56dfbb7", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT04"
	cDesCod := "Depreciação."
	aAdd( aBody, {"", "4a614e18-15d6-0412-93c5-0b39835e96d6", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT05"
	cDesCod := "Amortização."
	aAdd( aBody, {"", "b9a86278-d37e-9794-6a1c-636e9092adf4", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT06"
	cDesCod := "Exaustão."
	aAdd( aBody, {"", "982009aa-dd49-c5f9-dd4b-228547b7f35b", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT07"
	cDesCod := "CFEM."
	aAdd( aBody, {"", "351c8f82-da27-0e75-691f-7bcdeec3b6ef", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT08"
	cDesCod := "TFRM."
	aAdd( aBody, {"", "a85b44ff-1b39-a2c3-417f-a620c7af55fc", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT09"
	cDesCod := "Estocagem."
	aAdd( aBody, {"", "e967f7ba-9ac9-a1bd-e3a0-34592f4b22c5", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT10"
	cDesCod := "Expedição."
	aAdd( aBody, {"", "74770f61-6cbe-6c35-25aa-ad5a52a004da", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT11"
	cDesCod := "Transporte próprio para entrega ao comprador."
	aAdd( aBody, {"", "cc5b3076-8428-cfec-4755-4f437a704cb4", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT12"
	cDesCod := "Transporte contratado com terceiros para entrega ao comprador."
	aAdd( aBody, {"", "38d28872-b904-96d8-7eb7-f8fba12583be", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT13"
	cDesCod := "Custos portuários."
	aAdd( aBody, {"", "4f5569b3-2f97-2adb-ab13-2c8ad7ebf97d", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT14"
	cDesCod := "Quantidade de toneladas produzidas."
	aAdd( aBody, {"", "0d1b82f0-376c-09cd-382d-26966c351bfe", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT15"
	cDesCod := "Quantidade de toneladas vendidas."
	aAdd( aBody, {"", "50d23c46-f305-1156-8952-e09ae06b6a52", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT16"
	cDesCod := "Quantidade de toneladas transferidas."
	aAdd( aBody, {"", "9c71446e-8573-d669-f7bd-6f5a35ca10fc", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT17"
	cDesCod := "COMBUSTÍVEIS."
	aAdd( aBody, {"", "ec30a3e3-04c4-5e47-e59b-1559522760d4", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT18"
	cDesCod := "GRAXAS E LUBRIFICANTES."
	aAdd( aBody, {"", "0918f886-551c-9427-8e53-03b9e88cbea1", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT19"
	cDesCod := "ENERGIA ELÉTRICA."
	aAdd( aBody, {"", "4dc9f69a-abcd-a3bf-5868-8575efddfe25", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT20"
	cDesCod := "PRODUTOS QUÍMICOS E REAGENTES."
	aAdd( aBody, {"", "52d34e3a-ef35-8de5-5111-ee8326583b88", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT21"
	cDesCod := "EXPLOSIVOS."
	aAdd( aBody, {"", "e53880ba-7025-a8a9-6937-a0901a808c5e", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT22"
	cDesCod := "CORREIAS TRANSPORTADORAS."
	aAdd( aBody, {"", "493e668b-c0cc-abe0-7b6c-2c717fb8bc6c", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT23"
	cDesCod := "PEÇAS."
	aAdd( aBody, {"", "93adcbad-520d-a627-6c22-2791ca74f205", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT24"
	cDesCod := "ACESSÓRIOS."
	aAdd( aBody, {"", "a039e874-3cf4-5bb5-86a4-6fc9d7cda6b4", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT25"
	cDesCod := "PNEUMÁTICOS."
	aAdd( aBody, {"", "575d4d5f-4e45-f33e-9aee-dd8181baa714", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT26"
	cDesCod := "TUBULAÇÕES."
	aAdd( aBody, {"", "553ba5f2-63e0-9418-ec79-b50752c392b1", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT27"
	cDesCod := "SOBRESSALENTES PARA BOMBAS."
	aAdd( aBody, {"", "a5348f7b-81c0-46e4-8503-ab1603891dbf", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT28"
	cDesCod := "MATERIAIS ELÉTRICOS."
	aAdd( aBody, {"", "d10ffed0-ed22-ce2b-a759-9d95748e6873", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT29"
	cDesCod := "GASES INDUSTRIAIS."
	aAdd( aBody, {"", "15f5ca11-9f09-225e-1adc-5d2114f8a1b5", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT30"
	cDesCod := "TELAS DE PENEIRAS."
	aAdd( aBody, {"", "75e29abe-2065-cabb-bc3c-189863fe7408", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT31"
	cDesCod := "MATERIAIS DE FIXAÇÃO."
	aAdd( aBody, {"", "f9e5392a-bfff-2ffc-8ce5-14adf810439f", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT32"
	cDesCod := "CORPOS MOEDORES."
	aAdd( aBody, {"", "3518794e-9f44-7093-e630-91c6d2cd18f0", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	cCodIpm := "PAEXT33"
	cDesCod := "OUTROS MATERIAIS E DEMAIS MATERIAIS."
	aAdd( aBody, {"", "f8db9f0f-497e-e1d4-6f4a-7c6b90111dfe", cCodIpm, cDesCod, "20220101", ""        , "000015", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//12. Maranhão 000011 //versão=1 (tb13915) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "MAVAF001"
	cDesCod := "Atividades de Distribuição de Energia Elétrica"
	aAdd( aBody, {"", "8d6c781b-f9b2-9017-8860-2ab3a384748f", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	cCodIpm := "MAVAF002"
	cDesCod := "Atividades de Prestação de Serviços de Comunicação/Telecomunicação"
	aAdd( aBody, {"", "461f2f4f-1ef9-d3c1-6ce0-706c8906a1d0", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	cCodIpm := "MAVAF003"
	cDesCod := "Produção de Petróleo e Gás Natural - Na Hipótese da Produção se Estender por Mais de um Município"
	aAdd( aBody, {"", "13b92b67-3178-fe7c-4af6-1a3bbb0ee213", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	cCodIpm := "MAVAF004"
	cDesCod := "Atividades de Prestação de Serviço de Transporte Ferroviário de Passageiros"
	aAdd( aBody, {"", "35ab5a2d-cb8e-2207-4a14-9bd41951dd17", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	cCodIpm := "MAVAF005"
	cDesCod := "Prestação de Serviço de Transporte Rodoviário Intermunicipal e Interestadual de Passageiros"
	aAdd( aBody, {"", "8377fbf0-7645-5fd9-a261-d2022d662444", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	cCodIpm := "MAVAF006"
	cDesCod := "Prestação de Serviço de Transporte Aquaviário de Passageiros"
	aAdd( aBody, {"", "f923a9f9-01ea-6c28-6154-dd6d7e597f75", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	cCodIpm := "MAVAF007"
	cDesCod := "Aquisições de produtos agrícolas, pastoris, extrativos minerais, pescados ou outros produtos extrativos ou agropecuários sem NFA-e do produtor"
	aAdd( aBody, {"", "97189250-4429-8788-b310-87e6ccb5af1a", cCodIpm, cDesCod, "20200101", ""        , "000011", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//13. Acre 000001 //versão=2 (tb15222) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "ACIPME01"
	cDesCod := "Agricultura - Valor Contábil das Entradas de insumos para produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "9243fd17-5293-7fe4-a4bb-de8d9f5a721b", cCodIpm, cDesCod, "20190101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS01"
	cDesCod := "Agricultura - Valor Contábil das Saídas para comercialização ou industrialização de produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "d8970aa0-4c3e-3113-cbf8-25f6d4536a7e", cCodIpm, cDesCod, "20190101", "20191231", "000001", 1033.66} )

	cCodIpm := "ACIPMS01"
	cDesCod := "Agricultura - Valor Contábil das Saídas para comercialização ou industrialização de produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "8e0a5cbc-4c50-ca5d-2680-17c82812e7bf", cCodIpm, cDesCod, "20200101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME02"
	cDesCod := "Pecuária - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção pecuária, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "1d07d298-33ff-97b1-f365-b2fc1483dd9a", cCodIpm, cDesCod, "20190101", "20201231", "000001", 1033.66} )

	cCodIpm := "ACIPME02"
	cDesCod := "Pecuária - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção pecuária, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "b0f8d77a-04b3-3758-854f-188cbdc36f1e", cCodIpm, cDesCod, "20210101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS02"
	cDesCod := "Pecuária - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços de produção pecuária, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "a99c230f-f733-bfc1-3229-27abd6b74a42", cCodIpm, cDesCod, "20190101", "20211231", "000001", 1033.66} )

	cCodIpm := "ACIPMS02"
	cDesCod := "Pecuária - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços de produção pecuária, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "33de1125-c30e-e997-77a9-ece24c22ad73", cCodIpm, cDesCod, "20220101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME03"
	cDesCod := "Pesca - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção de pescado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "16c5f9d0-9766-1a82-cf25-5fb760240978", cCodIpm, cDesCod, "20190101", "20221231", "000001", 1033.66} )

	cCodIpm := "ACIPME03"
	cDesCod := "Pesca - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção de pescado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "0efe7236-ad2c-5443-343b-ab8ed7d9fb18", cCodIpm, cDesCod, "20230101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS03"
	cDesCod := "Pesca - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da produção de pescado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "00cce47c-4b93-c36c-27dc-4aaf10527443", cCodIpm, cDesCod, "20190101", "20231231", "000001", 1033.66} )

	cCodIpm := "ACIPMS03"
	cDesCod := "Pesca - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da produção de pescado, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "9a6bba79-06fb-6b34-e862-34222ae0f8bf", cCodIpm, cDesCod, "20240101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME04"
	cDesCod := "Transporte - Valor Contábil das Entradas provenientes das aquisições de serviços de Transporte por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "842d3368-79fa-a58f-86fb-699ebdf4da52", cCodIpm, cDesCod, "20190101", "20241231", "000001", 1033.66} )

	cCodIpm := "ACIPME04"
	cDesCod := "Transporte - Valor Contábil das Entradas provenientes das aquisições de serviços de Transporte por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "6cc870f8-94bd-714c-098b-4fb8eec3d6e4", cCodIpm, cDesCod, "20250101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS04"
	cDesCod := "Transporte - Valor Contábil das Saídas referente a prestações de serviços de Transporte por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "efd10f81-2f8e-2209-7d9e-1ddd4c953536", cCodIpm, cDesCod, "20190101", "20251231", "000001", 1033.66} )

	cCodIpm := "ACIPMS04"
	cDesCod := "Transporte - Valor Contábil das Saídas referente a prestações de serviços de Transporte por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "e976f71a-495b-a4d6-1e76-1d0114505f28", cCodIpm, cDesCod, "20260101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME05"
	cDesCod := "Produção de Energia Elétrica (Usinas) - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços utilizados na geração de energia elétrica, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "9b4ea8e5-73a0-806c-bbee-87cbe599733f", cCodIpm, cDesCod, "20190101", "20261231", "000001", 1033.66} )

	cCodIpm := "ACIPME05"
	cDesCod := "Produção de Energia Elétrica (Usinas) - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços utilizados na geração de energia elétrica, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "86e79f43-5763-a426-129d-bf9feb3048dd", cCodIpm, cDesCod, "20270101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS05"
	cDesCod := "Produção de Energia Elétrica (Usinas) - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da geração de energia elétrica, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "f395e051-a8c7-4212-14cb-421c4b35bd04", cCodIpm, cDesCod, "20190101", "20271231", "000001", 1033.66} )

	cCodIpm := "ACIPMS05"
	cDesCod := "Produção de Energia Elétrica (Usinas) - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da geração de energia elétrica, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "3bccb2e2-26de-0ab5-fce1-40261cbba3ed", cCodIpm, cDesCod, "20280101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME06"
	cDesCod := "Energia Elétrica - Valor Contábil das Entradas de energia elétrica e insumos utilizados na transmissão, distribuição e comercialização de energia elétrica, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "bcd7e22b-fc7d-3fd2-9de8-a6dc61c803d3", cCodIpm, cDesCod, "20190101", "20281231", "000001", 1033.66} )

	cCodIpm := "ACIPME06"
	cDesCod := "Energia Elétrica - Valor Contábil das Entradas de energia elétrica e insumos utilizados na transmissão, distribuição e comercialização de energia elétrica, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "7b8cda54-4a42-8c0b-e961-a6d9e6c5bdf3", cCodIpm, cDesCod, "20290101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS06"
	cDesCod := "Energia Elétrica - Valor Contábil das Saídas de energia elétrica transmitida, distribuída e comercializada, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "43c12afe-64b2-3892-98da-260f2fef66fe", cCodIpm, cDesCod, "20190101", "20291231", "000001", 1033.66} )

	cCodIpm := "ACIPMS06"
	cDesCod := "Energia Elétrica - Valor Contábil das Saídas de energia elétrica transmitida, distribuída e comercializada, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "386b37f2-8b4b-9845-2018-b506fa5a8396", cCodIpm, cDesCod, "20300101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME07"
	cDesCod := "Comunicação e Telecomunicação - Valor Contábil das Entradas e aquisições de serviços de comunicação e telecomunicação, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "e912c93d-c6d8-1750-4ccc-6709a7b9ff14", cCodIpm, cDesCod, "20190101", "20301231", "000001", 1033.66} )

	cCodIpm := "ACIPME07"
	cDesCod := "Comunicação e Telecomunicação - Valor Contábil das Entradas e aquisições de serviços de comunicação e telecomunicação, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "e938db00-06e7-2a75-26b7-430d7de1645d", cCodIpm, cDesCod, "20310101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS07"
	cDesCod := "Comunicação e Telecomunicação - Valor Contábil das Saídas e prestações de serviços de comunicação e telecomunicação, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "98031aac-9515-c862-ae32-c55d61923b25", cCodIpm, cDesCod, "20190101", "20311231", "000001", 1033.66} )

	cCodIpm := "ACIPMS07"
	cDesCod := "Comunicação e Telecomunicação - Valor Contábil das Saídas e prestações de serviços de comunicação e telecomunicação, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "e87728a4-f523-285a-1089-44ba1d02cf1b", cCodIpm, cDesCod, "20320101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME08"
	cDesCod := "Combustível - Valor Contábil das Entradas de mercadorias para produção e comercialização de combustíveis, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "ba9438c9-26d0-bbfe-144c-1a395bbb29fa", cCodIpm, cDesCod, "20190101", "20321231", "000001", 1033.66} )

	cCodIpm := "ACIPME08"
	cDesCod := "Combustível - Valor Contábil das Entradas de mercadorias para produção e comercialização de combustíveis, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "a20625e5-f5e9-8ffd-843a-ec5abf32a41f", cCodIpm, cDesCod, "20330101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS08"
	cDesCod := "Combustível - Valor Contábil das Saídas relativas da produção e comercialização de combustíveis, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "22478faa-c17e-dbb4-34be-7f0e34b8c607", cCodIpm, cDesCod, "20190101", "20331231", "000001", 1033.66} )

	cCodIpm := "ACIPMS08"
	cDesCod := "Combustível - Valor Contábil das Saídas relativas da produção e comercialização de combustíveis, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "5a7c6f5d-af55-c358-5694-e01369636464", cCodIpm, cDesCod, "20340101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME09"
	cDesCod := "Comércio - Valor Contábil das Entradas de mercadorias para comercialização, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "8a50642c-642f-fdb2-5b58-d7efd3c0b28c", cCodIpm, cDesCod, "20190101", "20341231", "000001", 1033.66} )

	cCodIpm := "ACIPME09"
	cDesCod := "Comércio - Valor Contábil das Entradas de mercadorias para comercialização, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "86a558e8-ba4d-09f9-b244-c83bb9a3b6af", cCodIpm, cDesCod, "20350101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS09"
	cDesCod := "Comércio - Valor Contábil das Saídas de mercadorias, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "d9c1f37a-64b2-12c7-40d8-c4c35061e062", cCodIpm, cDesCod, "20190101", "20351231", "000001", 1033.66} )

	cCodIpm := "ACIPMS09"
	cDesCod := "Comércio - Valor Contábil das Saídas de mercadorias, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "5266d7d7-1dc8-eed7-41a8-6f4f822b151b", cCodIpm, cDesCod, "20360101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPME10"
	cDesCod := "Indústria - Valor Contábil das Entradas mercadorias e insumos utilizadas na produção industrial, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "f54172dd-9afe-52ff-266a-8b0a9e5671b4", cCodIpm, cDesCod, "20190101", "20361231", "000001", 1033.66} )

	cCodIpm := "ACIPME10"
	cDesCod := "Indústria - Valor Contábil das Entradas mercadorias e insumos utilizadas na produção industrial, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "3e3dd730-7468-8d20-3e74-726d155c20a7", cCodIpm, cDesCod, "20370101", ""        , "000001", 1033.66} )

	cCodIpm := "ACIPMS10"
	cDesCod := "Indústria - Valor Contábil das Saídas de mercadorias industrializadas, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "1fd95bd4-7f5b-c63c-ec1e-c92ed25d3667", cCodIpm, cDesCod, "20190101", "20371231", "000001", 1033.66} )

	cCodIpm := "ACIPMS10"
	cDesCod := "Indústria - Valor Contábil das Saídas de mercadorias industrializadas, por município acreano, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "a15ba0f7-4800-ce64-5ad8-9fc77337fb92", cCodIpm, cDesCod, "20380101", ""        , "000001", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//14. Tocantins 000028 //versão=1 (tb12756) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "TOIPME01"
	cDesCod := "Agricultura - Valor Contábil das Entradas de insumos para produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "dc1336fa-46ef-1d78-056c-fdcf3acab98e", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS01"
	cDesCod := "Agricultura - Valor Contábil das Saídas para comercialização ou industrialização de produção própria de produtos agrícolas, produzidos em propriedade rural de responsabilidade do contribuinte, ainda que no sistema integrado, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "09b782c5-1332-1668-4135-f8007ffd8b01", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME02"
	cDesCod := "Pecuária - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção pecuária, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "eeca5f7e-38bc-4bf0-193e-c6b48eee76f6", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS02"
	cDesCod := "Pecuária - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços de produção pecuária, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "71b11450-c4d3-f990-1299-3f21321a7886", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME03"
	cDesCod := "Pesca - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços para produção de pescado, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "94e6208a-325f-0aaf-1de6-d4a145c92b0b", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS03"
	cDesCod := "Pesca - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da produção de pescado, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "514f9df4-eb27-74c6-b767-5b62cb57d0cb", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME04"
	cDesCod := "Transporte - Valor Contábil das Entradas provenientes das aquisições de serviços de Transporte por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "9473cc74-222b-6814-1648-47185c250cbd", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS04"
	cDesCod := "Transporte - Valor Contábil das Saídas referente a prestações de serviços de Transporte por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "da4a5eb3-f136-ceb0-9fc0-4a0a0358290f", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME05"
	cDesCod := "Produção de Energia Elétrica (Usinas) - Valor Contábil das Entradas de mercadorias e/ou aquisições de serviços utilizados na geração de energia elétrica, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "59da8a79-2aec-772f-a043-5de2ebc23174", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS05"
	cDesCod := "Produção de Energia Elétrica (Usinas) - Valor Contábil das Saídas de mercadorias e/ou prestações de serviços da geração de energia elétrica, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "01df4812-813b-d29a-d53c-4d440e97c5ed", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME06"
	cDesCod := "Energia Elétrica - Valor Contábil das Entradas de energia elétrica e insumos utilizados na transmissão, distribuição e comercialização de energia elétrica, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "1efd836f-1e27-165d-f223-f8a6aebe4379", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS06"
	cDesCod := "Energia Elétrica - Valor Contábil das Saídas de energia elétrica transmitida, distribuída e comercializada, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "4887483a-7cb5-2479-52cf-8ad91579904d", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME07"
	cDesCod := "Água Canalizada - Valor Contábil das Entradas e insumos utilizados na Captação, tratamento e distribuição de água canalizada, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "3b95fa43-f428-ac52-a41a-cc94cf311f69", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS07"
	cDesCod := "Água Canalizada - Valor Contábil das Saídas referente à distribuição de água canalizada, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "a114a0f5-4e07-1772-4db7-1474fb377dd8", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME08"
	cDesCod := "Comunicação e Telecomunicação - Valor Contábil das Entradas e aquisições de serviços de comunicação e telecomunicação, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "e29e30c0-a169-ab9b-0d3b-d1bbc5c46254", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS08"
	cDesCod := "Comunicação e Telecomunicação - Valor Contábil das Saídas e prestações de serviços de comunicação e telecomunicação, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "444b1063-48b4-aa92-5f5e-ff5b422a1e5a", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME09"
	cDesCod := "Combustível - Valor Contábil das Entradas de mercadorias para produção e comercialização de combustíveis, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "dfde9712-ff1a-8cf5-0f1a-dcd4aed8c8d4", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS09"
	cDesCod := "Combustível - Valor Contábil das Saídas relativas da produção e comercialização de combustíveis, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "07b3423a-468d-59e2-9e3c-73b98ecbc2f8", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME10"
	cDesCod := "Comércio - Valor Contábil das Entradas de mercadorias para comercialização, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "9316d8be-2014-a465-ea22-aab37d87194b", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS10"
	cDesCod := "Comércio - Valor Contábil das Saídas de mercadorias, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "882c93ae-8858-5729-8010-03a3741776c5", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPME11"
	cDesCod := "Indústria - Valor Contábil das Entradas mercadorias e insumos utilizadas na produção industrial, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "f7f2510f-7f24-b17e-689e-d4f969759459", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	cCodIpm := "TOIPMS11"
	cDesCod := "Indústria - Valor Contábil das Saídas de mercadorias industrializadas, por município tocantinense, excluindo-se as operações dedutíveis"
	aAdd( aBody, {"", "d79cc54c-4c81-18ce-69d4-975218460513", cCodIpm, cDesCod, "20180401", ""        , "000028", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//15. Pernambuco 000017 //versão=1 (tb13539)
	////////////////////////////////////////////////////////////////////
	cCodIpm := "PEIPMS0"
	cDesCod := "Prestação de serviço de transporte intermunicipal ou interestadual"
	aAdd( aBody, {"", "d051f658-423e-d1b3-d08d-2e5993b991df", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPMS1"
	cDesCod := "Prestação de serviço oneroso de comunicação"
	aAdd( aBody, {"", "e6adab77-c933-18bc-585e-31933b348d9f", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPMS2"
	cDesCod := "Substituição pelas entradas, nas operações não documentadas por nota avulsa"
	aAdd( aBody, {"", "3d0010c9-82f4-619f-4d52-197016cac3c2", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPME3"
	cDesCod := "Substituição pelas saídas, nas operações com não-inscrito (ENTRADAS: ST Saída)"
	aAdd( aBody, {"", "03e43b3e-73a5-9418-bc73-5c2ec48f1975", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPMS3"
	cDesCod := "Substituição pelas saídas, nas operações com não-inscrito (SAÍDAS: ST projetada Saídas)"
	aAdd( aBody, {"", "ba60d59d-8167-2131-31a5-20b1f5858639", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPMS4"
	cDesCod := "Distribuição de mercadoria de fornecimento continuado"
	aAdd( aBody, {"", "fb5efc6a-1920-5fd8-7577-3d402cca80e6", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPMS5"
	cDesCod := "Escrituração centralizada, autorizada por regime especial"
	aAdd( aBody, {"", "95edfa66-cc9e-1fc3-b2ac-5b8df79c1084", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	cCodIpm := "PEIPMS6"
	cDesCod := "Escrituração centralizada, vinculada a estabelecimento sem inscrição"
	aAdd( aBody, {"", "1cb2639a-d8e0-39cb-eb84-e8208c96e952", cCodIpm, cDesCod, "20190801", ""        , "000017", 1033.66} )

	////////////////////////////////////////////////////////////////////
	//16. Alagoas 000002 //versão=2 (tb16555) 
	////////////////////////////////////////////////////////////////////
	cCodIpm := "1001"
	cDesCod := "AVES(GALINÁCIOS)_UN"
	aAdd( aBody, {"", "c5baaefd-dbd5-f64c-fbde-27ac046c9c99", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1002"
	cDesCod := "OUTRAS_AVES_UN"
	aAdd( aBody, {"", "e64c46c0-136c-b47d-510b-84a8aadb723e", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1003"
	cDesCod := "BOVINO_PARA_ABATE_UN"
	aAdd( aBody, {"", "55215995-cb2b-c3de-8415-e25a73a0b5a6", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1004"
	cDesCod := "BOVINO_PARA_ENGORDA_UN"
	aAdd( aBody, {"", "2b3c54a3-cc7b-7784-32c4-55b730b00f20", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1005"
	cDesCod := "CAPRINO_PARA_ABATE_UN"
	aAdd( aBody, {"", "72d09f81-1297-4ca2-2929-cb4fd70c94a6", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1006"
	cDesCod := "CAPRINO_PARA_ENGORDA_UN"
	aAdd( aBody, {"", "3ec34a66-a74b-4cdf-41ed-f549f88d2b8d", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1007"
	cDesCod := "EQUINO_UN"
	aAdd( aBody, {"", "6be75562-44db-2d36-4945-96c22d363ebe", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1008"
	cDesCod := "OVINO_UN"
	aAdd( aBody, {"", "087065c8-6fd2-3478-ba51-bd4a21637fbc", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1009"
	cDesCod := "SUÍNOS_PARA_ABATE_UN"
	aAdd( aBody, {"", "c2c74aed-e865-42d6-d036-7b0953c53aa3", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1010"
	cDesCod := "SUÍNO_PARA_ENGORDA_UN"
	aAdd( aBody, {"", "bae6272d-9bee-9670-d86f-9617513bb2fb", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1011"
	cDesCod := "CAMARÃO_KG"
	aAdd( aBody, {"", "62f3e12d-0bb9-ea66-3b70-830b1d1362d4", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1012"
	cDesCod := "CRUSTÁCEOS_E_MOLUSCOS(OUTROS)_KG"
	aAdd( aBody, {"", "b43499a0-2da2-3a8c-b31c-a516150869f3", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1013"
	cDesCod := "LAGOSTA_KG"
	aAdd( aBody, {"", "2d457a55-e9c4-cf75-617b-31008c7afe45", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1014"
	cDesCod := "PESCADO(PEIXE)_KG"
	aAdd( aBody, {"", "f333f59d-25f2-bf6e-1979-06bdb859352e", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1015"
	cDesCod := "OUTROS_PRODUTOS_DE_PESCA_KG"
	aAdd( aBody, {"", "37dc727c-e0cb-d232-3ed1-50b008893900", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1016"
	cDesCod := "COUROS_E_PELES_UN"
	aAdd( aBody, {"", "65410b11-39e4-c4bb-6053-030a963a529e", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1017"
	cDesCod := "OVOS_UN"
	aAdd( aBody, {"", "fe891405-88f1-6850-aac1-0bfc2b3d61ff", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1018"
	cDesCod := "LEITE_L"
	aAdd( aBody, {"", "1bc6ed5c-6b56-c1ea-a4c8-a8cd05970e76", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1019"
	cDesCod := "MANTEIGA_KG"
	aAdd( aBody, {"", "df1da978-4c78-2ece-ad44-6835c8026c78", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1020"
	cDesCod := "QUEIJO_KG"
	aAdd( aBody, {"", "f35d3eac-1ae1-3abe-6341-b444e2b52ddb", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1021"
	cDesCod := "MEL_KG"
	aAdd( aBody, {"", "265de2f2-f6d2-4b7a-8a9c-422044a17fe0", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1022"
	cDesCod := "MEL_RICO_KG"
	aAdd( aBody, {"", "5c0b082f-11d4-4623-bb6d-ad96624e8fa5", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1023"
	cDesCod := "OUTROS_PRODUTOS_DE_ORIGEM_ANIMAL_KG"
	aAdd( aBody, {"", "5ec43aaf-fc3a-01d9-0fd2-e6fcce50b745", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1050"
	cDesCod := "ABACAXI_MIL"
	aAdd( aBody, {"", "e79514c2-8156-0570-be9a-65ce3f4a1b66", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1051"
	cDesCod := "ALGODÃO_KG"
	aAdd( aBody, {"", "13afafc9-c631-4968-4865-e5418d18bad0", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1052"
	cDesCod := "AMENDOIM_KG"
	aAdd( aBody, {"", "e2fba12b-e178-0bca-1bf2-96bc14a741d7", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1053"
	cDesCod := "ARROZ_KG"
	aAdd( aBody, {"", "f2256cef-da69-8c18-6f40-bae6377c9ea7", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1055"
	cDesCod := "BATATA_DOCE_KG"
	aAdd( aBody, {"", "68b610fd-c63c-f0c0-04e6-31e0791c953b", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1056"
	cDesCod := "CAJU_KG"
	aAdd( aBody, {"", "7223f38f-b543-df1c-8515-61fb839fa04b", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1057"
	cDesCod := "CANA_TON"
	aAdd( aBody, {"", "0558acab-fac0-9953-ca4b-e6e1644cb126", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1058"
	cDesCod := "CARVÃO_VEGETAL_KG"
	aAdd( aBody, {"", "f1c61fe7-66bc-e54d-2c0f-c51d5512b2af", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1059"
	cDesCod := "CASTANHA_DE_CAJU_KG"
	aAdd( aBody, {"", "68afe175-c69b-0eb9-97e6-c1b3753ed56b", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1060"
	cDesCod := "COCO_MIL"
	aAdd( aBody, {"", "2af29790-6e4b-ffc6-32e7-d562c4d42030", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1061"
	cDesCod := "CORDA_DE_AGAVE_KG"
	aAdd( aBody, {"", "36bbe151-bddc-b971-d23f-80ccfb0499bb", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1062"
	cDesCod := "FARINHA_DE_MANDIOCA_KG"
	aAdd( aBody, {"", "fa8f8649-31a0-274b-996c-bf61359a3717", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1063"
	cDesCod := "FEIJÃO_KG"
	aAdd( aBody, {"", "8b61aa3d-91f3-a590-8b40-b19fc4fafa01", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1064"
	cDesCod := "FUMO_KG"
	aAdd( aBody, {"", "e6052244-8a2c-2951-19f5-8d3be8e0b0aa", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1065"
	cDesCod := "GOMA_DE_MANDIOCA_KG"
	aAdd( aBody, {"", "8fbd21e1-addf-e4c7-45c0-987c656b9256", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1066"
	cDesCod := "INHAME_KG"
	aAdd( aBody, {"", "9a33e048-e3e3-27c0-2f01-0b50b062fca0", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1067"
	cDesCod := "LARANJA_MIL"
	aAdd( aBody, {"", "348f9631-d099-5935-1dcd-0174c377e0a1", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1068"
	cDesCod := "LEGUMES_HORTALIÇAS_E_VERDURAS_KG"
	aAdd( aBody, {"", "4fa0201c-b414-59fd-726c-d7cae3fd75a1", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1069"
	cDesCod := "MAÇÃ_KG"
	aAdd( aBody, {"", "71d70c61-0354-a463-6f6f-f2a56b6fe284", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1070"
	cDesCod := "MACAXEIRA_KG"
	aAdd( aBody, {"", "9727b7e8-6a39-6f4d-db09-c7b61a64e085", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1071"
	cDesCod := "MADEIRA_KG"
	aAdd( aBody, {"", "a028d433-889d-9124-48d5-1d8b8f792351", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1072"
	cDesCod := "MANGABA_KG"
	aAdd( aBody, {"", "7cfca0c3-7bbf-4561-d921-4183324fe755", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1073"
	cDesCod := "MAMÃO_KG"
	aAdd( aBody, {"", "4e5d6efa-391f-6f55-369c-7858eb21d2d2", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1074"
	cDesCod := "MAMONA_KG"
	aAdd( aBody, {"", "dcdff910-83e0-9cf6-e53f-46fa1478ee03", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1075"
	cDesCod := "MANGA_KG"
	aAdd( aBody, {"", "5fb24e58-8f7e-7aad-e20a-c55389d13da4", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1076"
	cDesCod := "MELANCIA_KG"
	aAdd( aBody, {"", "6dba2316-5cc1-b9e0-01a4-80fa7fbb49e8", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1077"
	cDesCod := "MILHO_EM_GRÃO_KG"
	aAdd( aBody, {"", "89acc555-9381-203a-e5b0-573fe9eaa554", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1078"
	cDesCod := "MILHO_VERDE_MIL"
	aAdd( aBody, {"", "5560dde2-bafb-8f92-991a-985838c98091", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1079"
	cDesCod := "UVA_KG"
	aAdd( aBody, {"", "2aca5d99-ec0d-6d81-456c-3e17bd576b51", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1080"
	cDesCod := "CANA_PRÓPRIA_TON"
	aAdd( aBody, {"", "12cfdd94-49fa-d444-abda-7fe2a618ea85", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1081"
	cDesCod := "CANA_FORNECEDORES_TON"
	aAdd( aBody, {"", "01f7613b-f29c-2435-42f9-ea661c8c7c2d", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1082"
	cDesCod := "OUTROS_PRODUTO_DE_ORIGEM_VEGETAL_KG"
	aAdd( aBody, {"", "6db6a6f6-114c-fc1a-08f7-5008b0c81dec", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1100"
	cDesCod := "AÇÚCAR_TON"
	aAdd( aBody, {"", "5c3e9119-730f-79e0-efab-8c69759269f9", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1101"
	cDesCod := "AGUARDENTE_L"
	aAdd( aBody, {"", "8655e67b-a5c4-d33e-6e32-0936cdb68675", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1102"
	cDesCod := "ÁLCOOL_L"
	aAdd( aBody, {"", "30988e6a-2a70-6456-4c41-c038229876d9", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1103"
	cDesCod := "MELAÇO_TON"
	aAdd( aBody, {"", "30f87418-270b-b493-ea5d-a95789d029dc", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1125"
	cDesCod := "CAL_VIRGEM_M3"
	aAdd( aBody, {"", "3784a292-4489-86ce-d70d-bcb86681854f", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1126"
	cDesCod := "CERÂMICAS(PEÇAS_ARTESANAIS)_UN"
	aAdd( aBody, {"", "af1e9f3e-e980-345c-0cde-36edd75a31d8", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1127"
	cDesCod := "TELHA_MIL"
	aAdd( aBody, {"", "2c455bc6-8ea2-f38a-53b3-cd579d703380", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1128"
	cDesCod := "TIJOLO_MIL"
	aAdd( aBody, {"", "28808794-4d30-42c4-9cf9-b3e0b1cd4575", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1129"
	cDesCod := "GARRAFA_VAZIA_MIL"
	aAdd( aBody, {"", "84c89c7b-e8be-05b4-9d11-1d30411bfdcb", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1130"
	cDesCod := "LITRO_VAZIO_MIL"
	aAdd( aBody, {"", "5ce7b865-9c65-13f5-519c-3d11398b0c8e", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1131"
	cDesCod := "SUCATA_DE_COBRE_KG"
	aAdd( aBody, {"", "24b2912f-87ce-c7b5-3d4c-c506a786e81a", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1132"
	cDesCod := "SUCATA_DE_FERRO_KG"
	aAdd( aBody, {"", "9ad927fc-cb17-7604-b3d1-3d37cbcc1633", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1133"
	cDesCod := "SUCATA_DE_PLÁSTICO_KG"
	aAdd( aBody, {"", "c1704dad-6b09-9cdf-9bde-7a09abf0c871", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1134"
	cDesCod := "OUTRAS_SUCATAS_KG"
	aAdd( aBody, {"", "c9a3bf68-01f5-3f68-79c1-b584dd82aee4", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1150"
	cDesCod := "PETRÓLEO_M3"
	aAdd( aBody, {"", "fbb151bf-a983-c493-ce33-d8b2a0448b0c", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1151"
	cDesCod := "GÁS_NATURAL_M3"
	aAdd( aBody, {"", "458490e2-0bcf-bb77-2b38-824bdb7ec496", cCodIpm, cDesCod, "20220101", "20240708", "000002", 1033.66} )

	cCodIpm := "1151"
	cDesCod := "GÁS_NATURAL(valor_total_do_fornecimento_menos_o_custo)"
	aAdd( aBody, {"", "5e7ef91c-0091-cf2f-b9f2-75e9c0da19a2", cCodIpm, cDesCod, "20240709", ""        , "000002", 1033.66} )

	cCodIpm := "1152"
	cDesCod := "PRODUTOS_DE_ORIGEM_MINERAL_TON"
	aAdd( aBody, {"", "1a5a5b2b-854d-dd76-0312-4162b88d35ad", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1200"
	cDesCod := "ENERGIA_ELÉTRICA(valor_total_do_fornecimento_menos_o_custo)"
	aAdd( aBody, {"", "2b0797c4-bd1a-e4b4-718a-cd3732fc79da", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1201"
	cDesCod := "COMUNICAÇÃO(valor_total_do_fornecimento_menos_o_custo)"
	aAdd( aBody, {"", "e8c0d584-d323-5fd1-1997-59c61f508750", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	cCodIpm := "1202"
	cDesCod := "TRANSPORTE(Qualquer_modal_valor_/_total_da_prestacao_menos_o_custo)"
	aAdd( aBody, {"", "7f25ef7c-25ea-6df6-9f2e-65f1d8d26e07", cCodIpm, cDesCod, "20220101", ""        , "000002", 1033.66} )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
