#INCLUDE "PROTHEUS.CH" 
#INCLUDE "APWIZARD.CH" 
#INCLUDE "LOJA720.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)
#DEFINE TEF_CLISITEF			"6"		//Utiliza a DLL CLISITEF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posicao do array aDevol   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _DESCMOEDA	1	// Descricao da moeda
#DEFINE _SALDO		2	// Saldo a devolver
#DEFINE _VALORDEV	3	// Valor efetivamente devolvido
#DEFINE _SOMADEV	4	// Somatorio da devolucao convertido
#DEFINE _VLRORIG	5	// Valor original da devolucao(backup)
#DEFINE _MOEDA		6	// Moeda

Static lTroca			// Controla se a operacao eh de troca ou devolucao
Static lConfirma		// Controla se usuario confirmou a operacao
Static oGetdDEV			// Objeto da MsGetDb do panel da devolucao
Static oGetdTRC		   	// Objeto da MsGetDb do panel da troca
Static aRecnoSD2		// Array utilizado para enviar o registro do SD2 as funcoes do SIGACUSA.PRX
Static cAmbMatriz  	:= CriaVar("MD4_CODIGO",.F.)
Static cAmbLocal  	:= CriaVar("MD4_CODIGO",.F.)
Static cWebService	:= CriaVar("MD3_CODAMB",.F.)
Static nProxPainel  := 0
Static oWs  := Nil
/*/ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LOJA720   ³ Autor ³ Vendas Cliente        ³ Data ³ 16.08.05  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para realizacao de troca e devolucao de mercadorias. ³±±
±±³          ³                                                             ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LOJA720(ExpC1, ExpC2, EXpL3, EXpA4, ExpN5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1: Codigo do Cliente                                    ³±±
±±³          ³ ExpC2: Loja do Cliente                                      ³±±
±±³          ³ EXpL3: Indica se a rotina foi executada pela Venda Assistida³±±
±±³          ³ EXpA4: Armazena a serie, numero e cliente+loja da NF de     ³±±
±±³          ³ 		  devolucao e o tipo de operacao(1=troca;2=devolucao)  ³±± 
±±³          ³ ExpN5: Opcao selecionada                                    ³±±
±±³          ³ ExpN6: Se a chamada da rotina for da tela de pagamentos da  ³±±
±±³          ³        venda assistida nao podera ser acessada.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA - VENDA ASSISTIDA                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LOJA1132( cCodCli	, cLojaCli		, lVdAssist  , aDocDev  ,;
                  nOpc		, lPanelPgto     )  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao de variaveis locais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea			:= GetArea()  												// Salva a area atual
Local lRet			:= .T.														// Retorno da Funcao
Local cNomeCli		:= CriaVar("A1_NOME",.F.)									// Nome do Cliente
Local cNumDoc       := CriaVar("F1_DOC",.F.)									// Numero do documento quando nao eh formulario proprio para documento de entrada
Local cSerieDoc		:= CriaVar("F1_SERIE",.F.)                                	// Serie  do documento quando nao eh formulario proprio para documento de entrada
Local cFormaDev     := Space(3)													// Numerario para devolucao
Local cNumCaixa 	:= xNumCaixa()												// Codigo do usuario ativo quando caixa
Local dDataIni		:= dDataBase										        // Data Inicial para filtrar as Notas de saida do cliente
Local dDataFim		:= dDataBase										        // Data Final para filtrar as Notas de saida do cliente
Local lMarca  		:= GetMark()	                                         	// Marca da MsSelect
Local cAliasTRB		:= "TRB" 													// Alias do arquivo temporario
Local nTpProc		:= 1      													// Opcao selecionada. 1-Troca ou 2-Devolucao
Local nNfOrig		:= 1  														// Opcao selecionada. 1-Com NF de origem ou 2-Sem NF de origem
Local nI			:= 0														// Contador do FOR
Local nPosProd		:= 0														// Posicao do campo Produto no aHeader
Local nPosTES		:= 0                                                     	// Posicao do campo TES no aHeader
Local aHeaderSD2	:= {}          												// aHeader obrigatorio para o objeto MsGetDB
Local aRecSD2       := {}          												// Contem a Quantidade e o Recno dos produtos na tabela SD2 que estao marcados para carregar na NewGetDados
Local aCpoBrw 		:= {}       												// Campos da tabela SD2 que serao exibidos na MsSelect                                                  
Local aStruTRB		:= {}        												// Campos da estrutura do arquivo temporario
Local aNomeTMP		:= {}   													// Nomes das tabelas temporarias gravadas em disco
Local lFormul 		:= .T.														// Indica se utilizara formulario proprio para a Nota Fiscal de Entrada.                             
Local lCompCR		:= SuperGetMv( "MV_LJCMPCR", NIL, .T. )						// Indica se ira compensar o valor da NCC gerada com o titulo da nota fiscal original
Local cCad	  		:= If( Type("cCadastro") 	== "U",Nil,cCadastro) 			// Salva o cCadastro atual
Local aRots   		:= If( Type("aRotina")   	== "U",Nil,aClone(aRotina))    	// Salva o aRotinas atual	
Local aSavHead  	:= If( Type("aHeader") 		== "U",Nil,aClone(aHeader))    	// Salva o aHeader se existir
Local nBkpLin   	:= If( Type("n") 		    == "U",Nil,n)				   	// Salva o n se existir
Local nRecnoTRB                                                                	// Recno da area de trabalho
Local nFormaDev     := 1 														// Define a forma de devolucao ao cliente: 1-Dinheiro;2-NCC
Local nVlrTotal		:= 0														// Valor total de produtos a serem trocados ou devolvidos
Local cMV_DEVNCC    := AllTrim(SuperGetMV("MV_DEVNCC"))                        	// Define a forma de devolucao default: "1"-Dinheiro;"2"-NCC
Local cMV_LJCHGDV   := AllTrim(SuperGetMV("MV_LJCHGDV",,"1"))                  	// Define se permite ou nao modificar a forma de devolucao ao cliente("0"-nao permite;"1"-permite)
Local cMV_LJCMPNC   := AllTrim(SuperGetMV("MV_LJCMPNC",,"1"))                  	// Define se permite ou nao modificar a opcao para compensar a NCC com o titulo da NF original("0"-nao permite;"1"-permite)
Local lDevMoeda		:= .F.														// Se devolve em outra moeda
Local nTxMoedaTr 	:= 0														// Taxa da moeda
Local nMoedaCorT	:= 1														// Moeda corrente
Local aMoeda		:= {}														// Moedas validas
Local cMoeda		:= ""														// Armazena moeda na digitacao
Local nDecimais		:= 0														// Decimais
Local nX            := 0														// Contador de For
Local nPosLote		:= 0 														// Posicao do Campo Lote no aHeader no Panel3
Local lMv_Rastro	:= (SuperGetMv( "MV_RASTRO", Nil, "N" ) == "S")			// Flag de verificacao do rastro
Local aTamNF        := {} 														// Tamanho do campo de nota fiscal.
Local aTamCupom     := {}														// Tamanho do campo de cupom.
Local cCodDia       := ""                                        // Codigo do Diario
Local cDescrDia     := ""                                        // Descricao do Diario
Local lAliasCVL     := AliasInDic( "CVL" )                       // Verifica existencia da tabela
Local cCodprod      := ""                                        // Guarda o campo do D2_COD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Declaracao dos Objetos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oWizard	   																// Objeto principal do Wizard
Local oTpProc					   												// Tipo do Processo de Troca. Troca ou Devolucao
Local oNfOrig	   				   												// Indica se possui uma nota fiscal de origem 
Local oCodCli 					   												// Codigo do Cliente
Local oLojaCli																	// Loja do Cliente
Local oNomeCli		   															// Nome do cliente
Local oDataIni																	// Data Inicial para filtro das Notas Fiscais de Saida
Local oDataFim        											             	// Data Final para filtro das Notas Fiscais de Saida
Local oNumDoc		                                                    		// Numero do documento quando nao eh formulario proprio para documento de entrada
Local oSerieDoc                                                                	// Serie do documento quando nao eh formulario proprio para documento de entrada
Local oFormaDev																	// Objeto do Radio para forma de devolucao 
Local oCompCR    																// Indica se ira compensar o valor da NCC gerada com o titulo da nota fiscal original
Local oDevMoeda																	// Se devolve em outra moeda
Local oMoeda																	// Moeda
Local oTxMoeda																	// Taxa da moeda
Local oCodDia                                                 					// Codigo do Diario (PTG)
Local oDescrDia                                               					// Descricao do Diario (PTG)
Local cAmbWs 
Local cIp
Local cEmpFil
Local cPorta
Local oDlg := Nil




Default	cCodCli 	:= CriaVar("A1_COD",.F.)									// Codigo do Cliente
Default cLojaCli    := CriaVar("A1_LOJA",.F.) 									// Loja do Cliente
Default	lVdAssist	:= .F.														// Indica se a rotina foi executada pela venda assistida
Default aDocDev     := {}                                                       // Armazena a serie, numero e cliente+loja da NF de devolucao e o tipo de operacao(1=troca;2=devolucao)
Default nOpc        := 3                                                        // Opcao do aRotina
Default lPanelPgto	:= .F.														// Verifica se a rotina esta sendo chamada da tela de pagamento da venda assistida


If !LJ1133ExReg("MD1")
	// Add MD
	LJ1133AdM1()
EndIf

If !LJ1133ExReg("MD2")
	LJ1133AdM2()
EndIf



lRet := .T.
If lRet

	If !Empty(cCodCli) .AND. !Empty(cLojaCli)
		cNomeCli:= Posicione("SA1",1,xFilial("SA1")+cCodCli+cLojaCli,"A1_NOME") 
	Endif
		
	Private cCadastro	:= ""  				            // Cabecalho da tela
	

	Private aHeader := aHeaderSD2                        // Cabecalho do grid de itens devolvidos
		
	//ÚÄÄÄÄÄÄÄ¿
	//³Panel 1³
	//ÀÄÄÄÄÄÄÄÙ
	DEFINE WIZARD oWizard TITLE "Configuração SIGALOJA OFF LINE" HEADER "Definição do Processo" ;	//"Configuração SIGALOJA OFF LINE" ## "Definição do Processo"
			MESSAGE STR0003; 										//"Parametros" 
			TEXT " "; 
			NEXT {||  L720NextPn( 	oWizard:nPanel	, nNfOrig	, cCodCli	, cLojaCli	,;
			 						@oWizard		, nTpProc	) };
			FINISH {||  .T. } NOFIRSTPANEL	PANEL  
			
			oWizard:GetPanel(1)
		    
			@ 05,10  TO 60,130 LABEL STR0004		OF oWizard:GetPanel(1) PIXEL //"Nivel"
			@ 20,20  RADIO oTpProc  		VAR nTpProc ITEMS "MATRIZ", "FILIAL", "ESTAÇÃO"	SIZE 50,10 PIXEL OF oWizard:GetPanel(1) ;
			         ON CHANGE Lj720AltProc( cAliasTRB  ,@aRecSD2  ,oGetdTRC  ,@lFormul  ,;
			                                @lCompCR   ,@nRecnoTRB,nTpProc    ) //"MATRIZ", "FILIAL", "ESTAÇÃO"
			
			
			@ 10,142 	Say "Matriz:" OF oWizard:GetPanel(1) PIXEL SIZE 25,15  	// Forma:
			@ 10,165	MSGET 	oAmbMatriz  	VAR cAmbMatriz  	SIZE 40,10 		Picture "@!" F3 "MD4" OF  oWizard:GetPanel(1) ;
					 	PIXEL  WHEN If(nNfOrig == 1, .T., .F.)
			                                
			@ 30,142 	Say "Local: " OF oWizard:GetPanel(1) PIXEL SIZE 25,15  	// Forma:
			@ 30,165	MSGET 	oAmbLocal  	VAR cAmbLocal  	SIZE 40,10 		Picture "@!"     F3 "MD4" OF  oWizard:GetPanel(1) ;
						PIXEL  WHEN If(nNfOrig == 1, .T., .F.)
		
		// _______	
		//³Panel 2³
		//ÀÄÄÄÄÄÄÄÙ
		CREATE PANEL oWizard  HEADER STR0014 ;  	//"Dados do Documento de Entrada"
			MESSAGE STR0015 ; 					    //"Selecione os produtos da NF de Origem que serão trocados ou devolvidos"
			BACK {|| .T. } ;
			NEXT {||  L720NextPn( oWizard:nPanel ,nNfOrig  ,cCodCli  ,cLojaCli,;
			@oWizard, nTpProc) };
	
			


			oWizard:GetPanel(2)
            
			cAmbWs := cAmbLocal
			
			@ 08,10 	Say "Ambiente" OF oWizard:GetPanel(2) PIXEL SIZE 40,10  	    
			@ 05,40		MSGET	oWs	VAR cAmbLocal 	SIZE 40,10 		   	OF  oWizard:GetPanel(2) ;
					 	PIXEL  WHEN .F.
		   
			@ 28,10 	Say "IP" OF oWizard:GetPanel(2) PIXEL SIZE 40,10  	    
			@ 25,40		MSGET	oIp	VAR cIp 	SIZE 40,10 		 	OF  oWizard:GetPanel(2) ;
					 	PIXEL  WHEN .T.
		
			@ 48,10 	Say "Porta" OF oWizard:GetPanel(2) PIXEL SIZE 23,15  	    
			@ 45,40		MSGET	oPorta	VAR cPorta 	SIZE 40,10 		OF  oWizard:GetPanel(2) ;
					 	PIXEL  WHEN .T.
		
			@ 67,10 	Say "Empresa Filial" OF oWizard:GetPanel(2) PIXEL SIZE 23,15  	    
			@ 65,40		MSGET	oEmpFil	VAR cEmpFil 	SIZE 40,10 		 OF  oWizard:GetPanel(2) ;
					 	PIXEL  WHEN .T.

		// _______	
		//³Panel 3³
		//ÀÄÄÄÄÄÄÄÙ
		CREATE PANEL oWizard  HEADER STR0014 ;  	//"Dados do Documento de Entrada"
			MESSAGE STR0003; 										//"Parametros" 
			NEXT {|| .F.};
			FINISH {||  .T. } 
			oWizard:GetPanel(3)
		
			//aAdd(aCpoBrw,{"MD1_OK"		        ,," "	  ," "})		
			aAdd(aCpoBrw,{"MD1_CODIGO" 			,,"CODIGO"   ," "})  								//"Documento de Saida"
			aAdd(aCpoBrw,{"MD1_DESCRICAO"		,,"DESCRICAO"," "})									//"Série"
		
			DbSelectArea("MD1")
			oMark := MsSelect():New("MD1","MD1_OK","MD1_OK",aCpoBrw,.F.,lMarca,{05,02,115,280},"MD1->(DbGotop())","MD1->(DbGoBottom())",oWizard:GetPanel(3))
			oMark:oBrowse:lhasMark    := .T.
			oMark:oBrowse:lCanAllmark := .F.						//Indica se pode marcar todos de uma vez

		

	
	ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }


Endif
                                                                                                         
RestArea(aArea)
                                  

Return(Nil)  


