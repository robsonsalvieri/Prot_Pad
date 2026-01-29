//Processos da integracao
#DEFINE _CADASTROCLIENTE 				"001"  	// Cadastro de cliente SA1
#DEFINE _CADASTROVENDEDOR 				"002"  	// Cadastro de vendedor SA3
#DEFINE _CADASTROESTACAO 				"003"  	// Cadastro de estacao SLG
#DEFINE _CADASTROCLICONT 				"004"  	// Cadastro de cliente X contato AC8-SUG
#DEFINE _REDUCAOZ		 				"005"  	// Mapa resumo (ReducaoZ) SFI
#DEFINE _CUPOMFISCAL	 				"006"  	// Cupom fiscal SF2-SD2-SE1-SE5-SEF
#DEFINE _SANGRIA		 				"007"  	// Sangria SE5
#DEFINE _SUPRIMENTO					"008"  	// Suprimento SE5
#DEFINE _PEDIDOVENDAENTREGA			"009"  	// Pedido de venda entrega SC5-SC6-SE1-SE5-SEF
#DEFINE _CONTASRECEBER					"010"  	// Contas a receber SE1
#DEFINE _MOVIMENTOBANCARIO				"011"  	// Movimento bancario SE5
#DEFINE _NOTAFISCAL					"012"  	// Nota Fiscal SF2-SD2
#DEFINE _PEDIDO						"013"  	// Pedido de venda SC5-SC6
#DEFINE _CHEQUES						"014"  	// Cheques SEF
#DEFINE _ITEMCANCELADO					"015"  	// Log de cancelamento de item SLX
#DEFINE _ITENSCFCANCELADO				"016"	// Itens do cupom fiscal cancelado durante a venda SLX
#DEFINE _TABELASGENERICAS				"017"	// Tabelas genéricas SX5
#DEFINE _GRUPODEPRODUTO  				"018"	// Grupo de produtos SBM
#DEFINE _CABECALHO_DA_TABELA_DE_PRECO	"019"	// Cabeçalho da tabela de preço DA0
#DEFINE _ITENS_DA_TABELA_DE_PRECO		"020"	// Itens da tabela de preço DA1
#DEFINE _CONDICAO_DE_PAGAMENTO    		"021"	// Condição de pagamento SE4   
#DEFINE _UNIDADE_DE_NEGOCIO       		"022"	// Unidade de negócio          
#DEFINE _CADASTROPRODUTO          		"023"	// Cadastro de produtos        
#DEFINE _EMPRESASFILIAIS          		"024"	// Cadastro de empresas e filiais
#DEFINE _PRODUTOEGRUPO					"025"	// Cadastro de produtos e grupo do produto
#DEFINE _SALDOFISICOFINANCEIRO			"026"	// Saldos Físico e Financeiro
#DEFINE _CADASTROTRANSPORTADORA		"027"	// Transportadoras

//Modo de envio das mensagens
#DEFINE _SINCRONA		 		"1"		//Sincrona
#DEFINE _ASSINCRONA			"2"  	//Assincrona

//Tipo de processamento da mensagem
#DEFINE _INCLUSAO		 		"3"		//Inclusao
#DEFINE _ALTERACAO				"4"  	//Alteracao
#DEFINE _EXCLUSAO				"5"  	//Exclusao

//Delimitador utilizado para criacao da estrutura do XML
#DEFINE _DELIMIT "_"
