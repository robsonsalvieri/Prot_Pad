/*/
	ATENCAO!!!
	TODOS OS DEFINES DO "POS" DEVEM SER CRAIDOS NESTE FONTE
/*/


/*/
	Registro de Itens
/*/
#DEFINE  ITEM_ENCONTRADO        	1	// 01 - Encontrou Item?
#DEFINE  ITEM_CODIGO	        	2	// 02 - Codigo do Item encontrado
#DEFINE  ITEM_CODBAR				3	// 03 - Codigo de Barras do Item encontrado
#DEFINE  ITEM_BLOQUEADO				4	// 04 - Item esta bloqueado para venda?
#DEFINE  ITEM_QTDE					5	// 05 - Quantidade do item
#DEFINE  ITEM_TES					6	// 06 - TES do item
#DEFINE  ITEM_BALANCA				7	// 07 - Tipo produto de balanca
#DEFINE  ITEM_DESCRICAO				8	// 08 - Descrição do item
#DEFINE  ITEM_UNID_MEDIDA			9	// 09 - Unidade de Medida do item
#DEFINE  ITEM_ARMAZEMPAD			10	// 10 - Armazem Padrão do item
#DEFINE  ITEM_TIPO					11	// 11 - Tipo do Produto
#DEFINE  ITEM_SITTRIB				12	// 12 - ST do item 
#DEFINE  ITEM_IAT					13	// 13 - IAT do item
#DEFINE  ITEM_IPPT					14	// 14 - PPT do item
#DEFINE  ITEM_TOTIMP    		    15 	// 15 - Impostos - Lei dos impostos	
#DEFINE  ITEM_ORIGEM				16	// 16 - Origem produto
#DEFINE  ITEM_CODISS				17	// 17 - Codigo ISS
#DEFINE  ITEM_POSIPI				18	// 18 - POIPI
#DEFINE  ITEM_INT_ICM				19	// 19 - PPT do item
#DEFINE  ITEM_EX_NCM				20	// 20 - Extensao do codigo NCM			
#DEFINE  ITEM_TOTFED               	21 	// 21 - Impostos - Lei dos impostos Federal	
#DEFINE  ITEM_TOTEST               	22 	// 22 - Impostos - Lei dos impostos Estadual	
#DEFINE  ITEM_TOTMUN               	23 	// 23 - Impostos - Lei dos impostos Municipal
#DEFINE  ITEM_RECNO					24	// 24 - Recno do Produto na tabela SB1

#DEFINE  ITEM_TOTAL_ARRAY			24	// TOTAL de defines no array		

/*/	
	 Regra de Desconto
/*/   
#DEFINE  LRULEAPPLY		   				1 // Alguma regra foi aplicada?
#DEFINE  NNEWTOTAL			 			2 // Valor total despois da aplicada(s) a(s) regra(s)
#DEFINE  NDESCTOTAL			 			3 // Valor total do desconto aplicada(s) a(s) regra(s)
#DEFINE  NPERDESCTO						4 // Percentual de desconto total aplicado em relacao ao valor total antigo
#DEFINE  NOLDTOTAL						5 // Valor total antes da aplicada(s) a(s) regra(s) 

#DEFINE  MEI_CODREG                		1 // Codigo da Regra
#DEFINE  MEJ_PRINUM	  					2 // Prioridade da Regra
#DEFINE  MEI_ACUMUL						3 // Indica se a regra é acumulativa    
#DEFINE  MEI_DESCRI						4 // Descrição da Regra
#DEFINE  MB8_DESCPR						5 // Percentual de desconto
#DEFINE  MB8_DESCVL						6 // Valor de desconto


/*/
	Abertura Fechamento de caixa
/*/

#DEFINE  CAIXA_FECHADO        			1 // Caixa foi fechado pelo operador
#DEFINE  TROCOU_OPERADOR	        	2 // Houve troca de operador
#DEFINE  ULTIMO_OPERADOR				3 // Ultimo operador que usou o sistema e nao fechou caixa


/*/
	Sangria e Suplimento
/*/
#DEFINE  TYPEOPERATION        			1 	// 01 - Tipo da rotina: (1) Sangria / Entrada de troco (2) 
#DEFINE  CASHIER_ORIGIN        			2 	// 02 - Codigo do caixa de origem
#DEFINE  CASHIER_DESTINY	        	3 	// 03 - Codigo do caixa de destino
#DEFINE  VALUE_MONEY					4 	// 04 - Valor em dinheiro
#DEFINE  VALUE_CHECK       				5 	// 05 - Valor em cheque
#DEFINE  VALUE_CREDITCARD      			6 	// 06 - Valor em cartao de credito
#DEFINE  VALUE_DEBITCARD				7 	// 07 - Valor em cartao de debito
#DEFINE  VALUE_FINANCED    				8 	// 08 - Valor em financiado
#DEFINE  VALUE_COVENANT        			9 	// 09 - Valor em convenio
#DEFINE  VALUE_COUPONS					10 	// 10 - Valor em vales
#DEFINE  VALUE_OTHERS        			11 	// 11 - Valor em outros 
#DEFINE  AGENCY							12  // 12 - Agencia	
#DEFINE  DV_AGENCY						13  // 13 - Dv. Agencia	
#DEFINE  ACCOUNT						14  // 14 - Conta	
#DEFINE  DV_ACCOUNT						15  // 15 - Dv. Conta	
#DEFINE  VALUE_PD						16  // 16 - Valor Pagamento Digital
#DEFINE  VALUE_PIX						17  // 17 - Valor PIX
/*/	
	 REGRA DE DESCONTO  aRules - Retorno da funcao STDTotRlDi - ( STDRULEDISCOUNTTOTAL )
/*/   
#DEFINE  MEI_CODREG             	1 // Caixa foi fechado pelo operador
#DEFINE  MEJ_PRINUM	  				2 // Prioridade da Regra
#DEFINE  MEI_ACUMUL					3 // Indica se a regra é acumulativa    
#DEFINE  MEI_DESCRI					4 // Descrição da Regra


/*/	
	 aRange - Retorno da Funcao STDRangRul - ( STDRULEDISCOUNTTOTAL )
/*/   
#DEFINE  nMB2_VLRINI	   	  		1 // Valor inicial
#DEFINE  nMB2_VLRFIM	   		 	2 // Valor final
#DEFINE  nMB2_PDESC					3 // Percentual de desconto
#DEFINE  nMB2_VLRFX					4 // Valor de desconto 

#DEFINE  MB2_VLRINI		   			1 // Valor inicial
#DEFINE  MB2_VLRFIM			 		2 // Valor final
#DEFINE  MB2_PDESC					3 // Percentual de desconto
#DEFINE  MB2_VLRFX					4 // Valor de desconto 


/*/	
	 aRet - Retorno da Funcao STBTotRlDi - ( STBRULEDISCOUNTTOTAL ) (desse fonte)
/*/   
#DEFINE  LRULETOTAP		   			1 // Alguma regra foi aplicada?
#DEFINE  NNEWTOTAL			 		2 // Valor total despois da aplicada(s) a(s) regra(s)
#DEFINE  NPERDESCTO					3 // Percentual de desconto total aplicado em relacao ao valor total antigo
#DEFINE  NOLDTOTAL					4 // Valor total antes da aplicada(s) a(s) regra(s) 


/*/	
	 aRet da Funcao STDTotRlDi
/*/   
#DEFINE  CODREG                	1 // Caixa foi fechado pelo operador
#DEFINE  PRINUM	  				2 // Prioridade da Regra
#DEFINE  ACUMUL					3 // Indica se a regra é acumulativa
#DEFINE  DESCRI					4 // Descrição da Regra
	


/*/
	Recebimentos de Titulos
/*/

#DEFINE TIT_SELE  1		 						// Posicao logica.
#DEFINE TIT_PREF  2		 						// Prefixo do titulo.
#DEFINE TIT_NUME  3		 						// Titulo.
#DEFINE TIT_PARC  4	 							// Parcela.
#DEFINE TIT_VREA  5		 						// Vencimento real.
#DEFINE TIT_VALO  6		 						// Valor.
#DEFINE TIT_MULT  7		 						// Multa.
#DEFINE TIT_JURO  8		 						// Juros.
#DEFINE TIT_DESC  9		 						// Desconto.
#DEFINE TIT_RECE 10		 						// Recebimento.
#DEFINE TIT_TIPO 11 	 						// Tipo.
#DEFINE TIT_CONT 12		 						// Contrato.
#DEFINE TIT_CLIE 13		 						// Cliente.
#DEFINE TIT_LOJA 14		 						// Loja.
#DEFINE TIT_FILI 15       					 	// Filial.
#DEFINE TIT_RECN 16		 						// Recno.
#DEFINE TIT_ACRS 17		 						// Acrescimo financeiro.
#DEFINE TIT_CACR 18		 						// Posicao logica.
#DEFINE TIT_ABAT 19		 						// Abatimentos.    
#DEFINE TIT_VENC 20		 						// Vencimento original.
#DEFINE TIT_LOCK 21		 						// Cod de uso do Registro
#DEFINE TIT_MOED 22	 							// Codigo da moeda do titulo
#DEFINE TIT_INTE 23	 							// Interes (Juros) - Posicao reservada
#DEFINE TIT_DTBX 24								// Dt. da baixa
#DEFINE TIT_SALD 25								// Saldo do titulo

#DEFINE OP_BAIXA "1"	 						// Baixa de titulos
#DEFINE OP_ESTOR "2"			 				// Estorno de baixa

#DEFINE REMOTE_TITLE_FUNCTION "STRemoteTi"	// Funcao remota do recebimento de titulos para executar na retaguarda


/*/
	Selecao de Clientes
/*/
#DEFINE LSELECTED		1 // Indica True se foi selecionado algum cliente.
#DEFINE MODEL_CLIENTE	1 // Model Cliente

#DEFINE POS_CLIENTE		1 // Indica posicao do codigo do cliente no array
#DEFINE POS_LOJACLI		2 // Indica posicao do codigo da loja do cliente no array

#DEFINE FIELD_NAME		1 // Nome do campo	
#DEFINE FIELD_VALUE		2 // Valor do campo


/*/
	ECF/ TEF / PAF
/*/
#DEFINE TEF_DISCADO          "4"							// TEF Discado
#DEFINE CRLF					Chr(10)						// Control
#DEFINE F_NAME					1							// Nome
#DEFINE EQUIP_DLL_NENHUM		0							// O equipamento nao foi configurado 
#DEFINE EQUIP_DLL_AUTOCOM		1							// O equipamento foi configurado para utilizar a AUTOCOM
#DEFINE EQUIP_DLL_SIGALOJA		2							// O equipamento foi configurado para utilizar a SIGALOJA

// Tipos de equipamentos
#DEFINE EQUIP_IMPFISCAL			1
#DEFINE EQUIP_PINPAD				2
#DEFINE EQUIP_CMC7				3
#DEFINE EQUIP_GAVETA				4
#DEFINE EQUIP_IMPCUPOM			5
#DEFINE EQUIP_LEITOR				6
#DEFINE EQUIP_BALANCA			7
#DEFINE EQUIP_DISPLAY			8
#DEFINE EQUIP_IMPCHEQUE			9
#DEFINE EQUIP_IMPNAOFISCAL		10	

//Menu fiscal
#DEFINE _PICTURE	16											// Picture
#DEFINE _FORMATEF	"CC;CD"								//Formas de pagamento que utilizam operação TEF para validação
#DEFINE _FORMATPD	"PD;PX"								//Formas de pagamento que utilizam operação TOTVS Pagamentos Digitais
#DEFINE _RAZSOC 	"TOTVS S.A."	  							// Denominacao da empresa desenvolvedora do PAF-ECF - Razao social
#DEFINE _CNPJTOT	"53113791000122"							// CNPJ da empresa desenvolvedora do PAF-ECF - Totvs
#DEFINE _ENDTOTVS	"Av Braz Leme,1631 - Sao Paulo-SP"	// Endereco da empresa desenvolvedora do PAF-ECF - Totvs
#DEFINE _CEPTOTVS	"02511-000"							// Endereco da empresa desenvolvedora do PAF-ECF - Totvs
#DEFINE _TELTOTVS	"0800 709 8100"						// Telefone da empresa desenvolvedora do PAF-ECF - Totvs
#DEFINE _CONTOTVS	"Wilson de Godoy"	   					// Contato da empresa desenvolvedora do PAF-ECF - Totvs
#DEFINE _INSCEST	"111010945111"	  						// Inscricao Estadual da empresa desenvolvedora do PAF-ECF, se houver
#DEFINE _INSCMUN	"90814274"		   							// Inscricao Municipal da empresa desenvolvedora do PAF-ECF, se houver
#DEFINE _NUMLAUDO	IIF(nModulo == 12, "POL4232010", "POL4262010")	// Numero do laudo da homologacao *** ajustar
#DEFINE _NOMEXEC	IIF(nModulo == 23, "SIGAFRT_PAF.exe",; 				// Nome do executavel homologado no Frontloja 


/* Definições de Interface do POS */
#DEFINE ALTURAGET	  13				// Altura (tamanho) dos GETS
#DEFINE ALTURABTN	  25				// Altura (tamanho) dos Botoes
#DEFINE ALT_LIST_CONSULT  oPanelMVC:nHeight/4.4865	// Altura (Tamanho) do listbox de consulta
#DEFINE LARG_LIST_CONSULT oPanelMVC:nWidth/2.1621	// Largura (Tamanho) do listbox de consulta
#DEFINE LARGBTN		  80				// Largura (tamanho) dos Botoes
#DEFINE POSHOR_1	  oPanelMVC:nWidth/49.2		// Posicao horizontal 1
#DEFINE POSHOR_2	  oPanelMVC:nWidth/3.55555	// Posicao horizontal 2
#DEFINE POSVERT_CAB	  oPanelMVC:nHeight/100		// Posicao vertical do cabeçalho
#DEFINE POSVERT_LABEL1	  oPanelMVC:nHeight/16.8	// Posicao vertical do label 1
#DEFINE POSVERT_LABEL2	  oPanelMVC:nHeight/7.084	// Posicao vertical do label 2
#DEFINE POSVERT_LABEL3	  oPanelMVC:nHeight/4.4866	// Posicao vertical do label 3
#DEFINE POSVERT_LABEL4	  oPanelMVC:nHeight/3.28292	// Posicao vertical do label 4
#DEFINE POSVERT_LABEL5	  oPanelMVC:nHeight/2.25192	// Posicao vertical do label 5
#DEFINE POSVERT_LABEL6	  oPanelMVC:nHeight/2.15292	// Posicao vertical do label 6
#DEFINE POSVERT_LABEL7	  oPanelMVC:nHeight/2.58292	// Posicao vertical do label 7
#DEFINE POSVERT_GET1	  oPanelMVC:nHeight/11.215	// Posicao vertical do get 1
#DEFINE POSVERT_GET2	  oPanelMVC:nHeight/5.852	// Posicao vertical do get 2
#DEFINE POSVERT_GET3	  oPanelMVC:nHeight/3.95882	// Posicao vertical do get 3

#DEFINE POSVERT_GET4	  oPanelMVC:nHeight/2.99111	// Posicao vertical do get 4
#DEFINE POSVERT_BTNFOCAL  (oPanelMVC:nHeight/2.10312)-ALTURABTN	  	// Posicao horizontal do botao focal
#DEFINE POSHOR_BTNFOCAL	  (oPanelMVC:nWidth/2.07115)-LARGBTN	// Posicao horizontal do botao focal
#DEFINE POSHOR_BTNCANC	  (oPanelMVC:nWidth/2.82115)-LARGBTN	// Posicao horizontal do botao focal

// Interface de Pagamento
#DEFINE POSVERT_BTNPAY	  (oPnlAdconal:nHeight/2.1666) - ALTURABTN // Posicao vertical do botao Efetuar pagamentos
#DEFINE POSHOR_BTNCONFPAY (oPnlAdconal:nWidth/2.06779) - LARGBTN   // Posicao horizontal do botao Efetuar pagamentos
#DEFINE POSVERT_PAYLABEL1 000				// Posicao vertical da segunda linha de labels do pagamento
#DEFINE POSVERT_PAYLABEL2 oPnlAdconal:nHeight/8.3	// Posicao vertical da segunda linha de labels do pagamento
#DEFINE POSVERT_PAYLABEL3 oPnlAdconal:nHeight/4.1	// Posicao vertical da Terceira linha de labels do pagamento
#DEFINE POSVERT_PAYGET1   oPnlAdconal:nHeight/19.5	// Posicao vertical da primeira linha de gets do pagamento
#DEFINE POSVERT_PAYGET2   oPnlAdconal:nHeight/5.7	// Posicao vertical da segunda linha de gets do pagamento
#DEFINE POSVERT_PAYGET3   oPnlAdconal:nHeight/3.5	// Posicao vertical da Terceira linha de gets do pagamento
#DEFINE POSHOR_PAYCOL1	  000  				// Posicao horizontal da segunda coluna de componentes
#DEFINE POSHOR_PAYCOL2	  oPnlAdconal:nWidth/5   	// Posicao horizontal da segunda coluna de componentes
#DEFINE LARG_GET_DATE	  80				// Largura dos labels do pagamento
#DEFINE LARG_GET_VALOR	  80
#DEFINE LARG_SAY	  			200				//Largyra Padrao Para say na tela	

//Chave para saber se esta com conexao ou nao com a retaguarda

#DEFINE CSECAO "CONEXAOPDV"
#DEFINE CCHAVE "CONECTADO"


