#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include "TAFXDERJ.ch"

#Define cObrig "DECLAN-RJ"

//--------------------------------------------------------------------------
/*/{Protheus.doc} TAFXDERJ

Esta rotina tem como objetivo a geracao do Arquivo DECLAN - RJ

@Author Marcos.Vecki
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------------
Function TAFXDERJ()
Local cNomWiz    := cObrig + FWGETCODFILIAL 
Local lEnd       := .F.
Local cFunction  := ProcName()
Local nOpc       := 2 //View
Local cCode		:= "LS006"
Local cUser		:= RetCodUsr()
Local cModule	:= "84"
Local cRoutine  := ProcName()

Private oProcess := Nil

//Função para gravar o uso de rotinas e enviar ao LS (License Server)
Iif(FindFunction('FWLsPutAsyncInfo'),FWLsPutAsyncInfo(cCode,cUser,cModule,cRoutine),)

Iif(FindFunction('FwPDLogUser'),FwPDLogUser(cFunction, nOpc), )

//Cria objeto de controle do processamento
oProcess := TAFProgress():New( { |lEnd| ProcDeclRj( @lEnd, @oProcess, cNomWiz ) }, "Processando DECLAN - RJ" )
oProcess:Activate()

//Limpando a memória
DelClassIntf()

Return()

/*{Protheus.doc} ProcDeclRj

Inicia o processamento para geracao da DECLAN - RJ


@Param lEnd      -> Verifica se a operacao foi abortada pelo usuario 
		oProcess  -> Objeto da barra de progresso da emissao da DECLAN-RJ 
		cNomWiz   -> Nome da Wizard criada para a DECLAN

       
@Return ( Nil )

@Author Marcos Buschmann
@Since 27/08/2015
@Version 1.0
*/

Static Function ProcDeclRj( lEnd, oProcess, cNomWiz )

Local cErrorDECL	:=	""
Local cErrorTrd	:=	""
Local nProgress1	:=	0
Local aWizard		:=	{}
Local aJobAux		:=	{}
Local nValor   	:= 0
Local nCont   	:= 0
Local lProc		:=	.T.

Private cItens  := ""  /*Utilizado na query do 0300*/

//Carrega informações na wizard
If !xFunLoadProf( cNomWiz , @aWizard )
	Return( Nil )
EndIf

If aWizard[2][10] == "1 - Sim"  //Grid com itens do tipo 99 - Outros
	lProc := TAFCadAdic(LTRIM(aWizard[2][1]))
EndIf
	
If lProc
	
	//Alimentando a variável de controle da barra de status do processamento
	nProgress1 := 2
	oProcess:Set1Progress( nProgress1 )

	//Iniciando o Processamento
	oProcess:Inc1Progress(STR0062) //"Preparando o Ambiente..."
	oProcess:Inc1Progress(STR0063) //"Executando o Processamento..."
	
	//Geração Declan-RJ
	TAFDE0001(aWizard)
	TAFDE0100(aWizard)
	TAFDE0200(aWizard, @nValor, @nCont)
	TAFDE0300(aWizard, @nValor, @nCont)
	TAFDE0400(aWizard, @nValor, @nCont)
	TAFDE0500(aWizard, @nValor, @nCont)
	TAFDE9999(aWizard, @nValor, @nCont)

Else
	oProcess:Inc1Progress( STR0064 ) //"Processamento cancelado"
	oProcess:Inc2Progress( STR0065 ) //"Clique em Finalizar"
	oProcess:nCancel = 1

EndIf

//Tratamento para quando o processamento tem problemas
If oProcess:nCancel == 1 .or. !Empty( cErrorDECL ) .or. !Empty( cErrorTrd )

	//Cancelado o processamento
	If oProcess:nCancel == 1

		Aviso( STR0001, STR0066, { STR0067 } )  //"Atenção!", "A geração do arquivo foi cancelada com sucesso!", { "Sair" }

	//Erro na inicialização das threads
	ElseIf !Empty( cErrorTrd )

		Aviso( STR0001, cErrorTrd, { STR0067 } )	 //"Atenção!", { "Sair" }

	//Erro na execução dos Blocos
	Else

		cErrorDECL := STR0068 + SubStr( cErrorDECL, 2, Len( cErrorDECL ) ) 	//Ocorreu um erro fatal durante a geração do(s) Registro(s) 
		cErrorDECL += STR0069 + Chr( 10 ) + Chr( 10 ) 						//da DECLAN-RJ 
		cErrorDECL += STR0070												//Favor efetuar o reprocessamento da DECLAN-RJ, caso o erro persista entre em contato 
		cErrorDECL += STR0071 + Chr( 10 ) + Chr( 10 )						//com o administrador de sistemas / suporte Totvs

		Aviso( STR0001, cErrorDECL, { STR0067 } )  //"Atenção!", { "Sair" }

	EndIf

Else

	//Atualizando a barra de processamento
	oProcess:Inc1Progress( STR0072 )  						//Informações processadas
	oProcess:Inc2Progress( STR0073 ) //Consolidando as informações e gerando arquivo...


	If GerTxtCons( aWizard )
		//Atualizando a barra de processamento
		oProcess:Inc2Progress( STR0074 )	//Arquivo gerado com sucesso.
		msginfo(STR0074)	  			  	//Arquivo gerado com sucesso.
	Else
		oProcess:Inc2Progress( STR0075 ) //Falha na geração do arquivo.
	EndIf

EndIf

//Zerando os arrays utilizados durante o processamento
aSize( aJobAux, 0 )

//Zerando as Variaveis utilizadas
aJobAux := Nil

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} getObrigParam

@author Marcos Buschmann
@since	27/08/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getObrigParam()

	Local	cNomWiz	:= cObrig+FWGETCODFILIAL
	Local 	cNomeAnt 	:= ""
	Local	aTxtApre	:= {}
	Local	aPaineis	:= {}

	Local	aItens1	:= {}
	Local	aItens2	:= {}
	Local	aItens3	:= {}
	Local	aItens4	:= {}
	Local	aItens5	:= {}
	Local	aItens6	:= {}
	Local	aItens7	:= {}
	Local	aItens8	:= {}
	Local	aItens9	:= {}
	Local	aItens10	:= {}
	Local	aItens11	:= {}
	Local	aItens12	:= {}
	Local	aItens13	:= {}
	Local	aItens14	:= {}
	
	
	Local	cTitObj1	:= ""
	Local	aRet		:= {}

	aAdd (aTxtApre, STR0002) //"Processando Empresa."
	aAdd (aTxtApre, "")
	aAdd (aTxtApre, STR0003 ) // "Preencha corretamente as informações solicitadas."
	aAdd (aTxtApre, STR0004 ) //"Informações necessárias para a geração do meio-magnético DECLAN-RJ."

//ÚÄÄÄÄÄÄÄÄ¿
//³Painel 0³
//ÀÄÄÄÄÄÄÄÄÙ
//aAdd (aPaineis[nPos][3], {0,"",,,,,,}) Coluna de espaços


	aAdd (aPaineis, {})
	nPos :=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0003)
	aAdd (aPaineis[nPos], STR0004)
	aAdd (aPaineis[nPos], {})


	//Coluna1														//Coluna 2
	cTitObj1	:=	STR0005; /*"Diretório do Arquivo Destino" */	cTitObj2	:=	STR0006   						 /*"Nome do Arquivo Destino"*/     
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})		

	cTitObj1	:=	Replicate ("X", 100);					    	cTitObj2	:=	Replicate ("X", 100)           
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50});				aAdd (aPaineis[nPos][3], {2,,cTitObj2,1,,,,50})
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
                                                        
	cTitObj1	:=	STR0007 /*"Versão da DECLAN-IPM"*/											
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});					aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
                                                                                                                                                               
	cTitObj1	:=	Replicate ("X", 10)									                     
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,50})					                     

//PAINEL 2
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0003) //"Preencha corretamente as informacoes solicitadas.")
	aAdd (aPaineis[nPos], STR0008) //"Informações necessárias para a geração do meio-magnético DECLAN-RJ - Registro 0100.")
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//Coluna 1															//Coluna 2
	cTitObj1	:=	STR0009 	;	/*"Ano Referência:"*/		   		cTitObj2	:=  STR0010  				/*"Declaração Retificadora:"*/   		
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                 		aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	
	cTitObj1	:=	Replicate ("X", 04);                           		aAdd (aItens1, STR0011)  /*"0 - Não"*/                                 
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,4});           	   		aAdd (aItens1, STR0012)  /*"1 - Sim"*/                  
	                                                               		aAdd (aPaineis[nPos][3], {3,,,,,aItens1,,,,,})
	                                                               
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
	
	cTitObj1	:=	STR0013; /*"Contabilista" */			 			cTitObj2	:=  STR0014  /*"Decl.Baixa Inscrição"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})
	                                                                                              		                                                                                                    
	cTitObj1	:=	Replicate ("X", 36);														aAdd (aItens2, STR0011) /*"0 - Não"*/                                     
	aAdd (aPaineis[nPos][3], {2,,cTitObj1,1,,,,36,,,"C2JFIL",{"xValWizCmp",1,{"C2J","5"}}} );	aAdd (aItens2, STR0012) /*"1 - Sim"*/                           
																								aAdd (aPaineis[nPos][3], {3,,,,,aItens2,,,,,})
																								

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha


 	cTitObj1	:=	STR0015 ; /*"Data de Encerramento das Atividades"*/ cTitObj2	:=	STR0016 /*"Estab. Principal ou Único no Estado:"*/	
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})			
	
																		aAdd (aItens3, STR0011) /*"0 - Não"*/     											
																		aAdd (aItens3, STR0012) /*"1 - Sim"*/       							
	aAdd (aPaineis[nPos][3], {2,,,3,,,,});								aAdd (aPaineis[nPos][3], {3,,,,,aItens3,,,,,})		
	              
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=  STR0017;/*"Estab. Único em Territ. Nacional:"*/		cTitObj2	:=	STR0018 /*"Estab. sem Receita Ano-Base:"*/	
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
                                                                                                               
	aAdd (aItens4, STR0011);  	/*"0 - Não"*/     		 				aAdd (aItens5, STR0011) /*"0 - Não"*/     		 						
	aAdd (aItens4, STR0012);	/*"1 - Sim"*/   						aAdd (aItens5, STR0012) /*"1 - Sim"*/       							
	aAdd (aPaineis[nPos][3], {3,,,,,aItens4,,,,,});						aAdd (aPaineis[nPos][3], {3,,,,,aItens5,,,,,})	
            
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
    
	cTitObj1	:=  STR0019; /*"Empresa sem Receita Ano-Base:"*/  	   	cTitObj2	:=	STR0020 /*"Considerar Tipo do Item 'Outros' no estoque?"*/	                 
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});						aAdd (aPaineis[nPos][3], {1, cTitObj2,,,,,,})	
                                                                                                              
	aAdd (aItens6, STR0011);  /*"0 - Não"*/                             aAdd (aItens7, STR0011) /*"0 - Não"*/     								
	aAdd (aItens6, STR0012);  /*"1 - Sim"*/                             aAdd (aItens7, STR0012)	/*"1 - Sim"*/       						
	                                                                	
	aAdd (aPaineis[nPos][3], {3,,,,,aItens6,,,,,});               		aAdd (aPaineis[nPos][3], {3,,,,,aItens7,,,,,})

//PAINEL 3
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	aAdd (aPaineis, {})
	nPos	:=	Len (aPaineis)
	aAdd (aPaineis[nPos], STR0003) //"Preencha corretamente as informacoes solicitadas."
	aAdd (aPaineis[nPos], STR0021) //Informações necessárias para a geração do meio-magnético DECLAN-RJ - Registro 0200.
	aAdd (aPaineis[nPos], {})
//--------------------------------------------------------------------------------------------------------------------------------------------------//
	//Coluna 1																	//Coluna 2
	cTitObj1	:=	STR0022 /*"Apresentou Movimento de Operações "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                   		 aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0023	 /*" com Mercadorias ou Prestação" */
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                                                                           
	cTitObj1	:=	STR0024  /*" Serviços alcançada pela incidência do ICMS?"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aItens8	:=	{}
	aAdd (aItens8, STR0011) /*"0 - Não"*/     		
	aAdd (aItens8, STR0012) /*"1 - Sim"*/       
	aAdd (aPaineis[nPos][3], {3,,,,,aItens8,,,,,})
       
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
       
	cTitObj1	:=	STR0025 /*"Praticou Operações ou Prestações não "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0026 /*"registradas ou não acobertadas por "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0027 /*"documentação fiscal, denunciadas " */
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                                                                           
	cTitObj1	:=	STR0028 /*"espontaneamente ou apuradas mediante "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0029 /*"ação fiscal, inclusive em exercícios "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0030 /*"anteriores cujo crédito tributário tenha "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0031 /*" se tornado definitivo no ano-base?"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aAdd (aItens9, STR0011) /*"0 - Não"*/
	aAdd (aItens9, STR0012) /*"1 - Sim"*/
	aAdd (aPaineis[nPos][3], {3,,,,,aItens9,,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});									aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

	cTitObj1	:=	STR0032 /*"Indústria, Comércio, Produção Agropecuária, "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                			aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0033 /*"Extração Vegetal ou Atividade Pesqueira "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aAdd (aItens10, STR0011) /*"0 - Não"*/
	aAdd (aItens10, STR0012) /*"1 - Sim"*/
	aAdd (aPaineis[nPos][3], {3,,,,,aItens10,,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
       
       
	cTitObj1	:=	STR0034 /* "Geração/Distribuição de Energia Elétrica, " */
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0035 /*"Prestação de Serviço de Transporte "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0036 /*"InterEstadual ou Intermunicipal, Prestação "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                   	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0037 /*"onerosa de Serviços de Comunicação e "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                                                                           
	cTitObj1	:=	STR0038 /*"Fornecimento para consumo final "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
			
	cTitObj1	:=	STR0039 /*" de Água Natural e de Gás Canalizado?"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aAdd (aItens11, STR0011) /*"0 - Não"*/
	aAdd (aItens11, STR0012) /*"1 - Sim"*/
	aAdd (aPaineis[nPos][3], {3,,,,,aItens11,,,,,})
       
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});								aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
       
	cTitObj1	:=	STR0040 /*"Produtos Agropecuários ou da Atividade  "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                      aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0041 /*"Pesqueira adquiridos com trânsito  "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                      aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0042 /*"acobertado por nota fiscal emitida pelo "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                      aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                                                                           
	cTitObj1	:=	STR0043 /*"próprio adquirente e não acompanhado "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                      aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0044 /*"por nota fiscal emitida pelo fornecedor?"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aAdd (aItens12, STR0011) /*"0 - Não"*/
	aAdd (aItens12, STR0012) /*"1 - Sim"*/
	aAdd (aPaineis[nPos][3], {3,,,,,aItens12,,,,,})

	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha

       
	cTitObj1	:=	STR0045 /*"Contribuinte autorizado, em processo ou"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0046 /*"legislação específica, a possuir "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0047 /*"estabelecimento dispensado de inscrição "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0048 /*"estadual ou a centralizar operações de"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                    aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                                                                           	
	cTitObj1	:=	STR0049 /*"estabelecimento inscrito?"*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aAdd (aItens13, STR0011) /*"0 - Não"*/
	aAdd (aItens13, STR0012) /*"1 - Sim"*/
	aAdd (aPaineis[nPos][3], {3,,,,,aItens13,,,,,})
        
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,}) //Pula Linha
       
	cTitObj1	:=	STR0050 /*"Contribuinte autorizado, em processo "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                             
	cTitObj1	:=	STR0051 /*"de Regime Especial, a recolher ICMS  "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		
	cTitObj1	:=	STR0052 /*"devido nas operações praticadas por  "*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,});                          aAdd (aPaineis[nPos][3], {0,"",,,,,,})
		                                                                                                                                                                                           	
	cTitObj1	:=	STR0053 /*" revendedores autônomos."*/
	aAdd (aPaineis[nPos][3], {1, cTitObj1,,,,,,})
		
	aAdd (aItens14, STR0011) /*"0 - Não"*/
	aAdd (aItens14, STR0012) /*"1 - Sim"*/
	aAdd (aPaineis[nPos][3], {3,,,,,aItens14,,,,,})


	aAdd(aRet, aTxtApre)
	aAdd(aRet, aPaineis)
	aAdd(aRet, cNomWiz)
	aAdd(aRet, cNomeAnt)
	aAdd(aRet, Nil )
	aAdd(aRet, Nil )
	aAdd(aRet, { || TAFXDERJ() } )

Return (aRet)

//---------------------------------------------------------------------
/*/{Protheus.doc} GerTxtDERJ

Geracao do Arquivo TXT da DECLAN-RJ. 
Gera o arquivo de cada registros.

@Param cStrTxt -> Alias da tabela de informacoes geradas pelo DECLAN
        lCons -> Gera o arquivo consolidado ou apenas o TXT de um registro

@Return ( Nil )

@Author Marcos Buschmann
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GerTxtDERJ( nHandle, cTXTSys, cReg)

Local	cDirName		:=	TAFGetPath( "2" , "DECLRJ" )
Local	cFileDest		:=	""
Local	lRetDir		:= .T.
Local	lRet			:= .T.

//Verifica se o diretorio de gravacao dos arquivos existe no RoothPath e cria se necessario
if !File( cDirName )
	
	nRetDir := FWMakeDir( cDirName )

	if !lRetDir

		cDirName	:=	""
		
		Help( ,,"CRIADIR",, STR0054 + cValToChar( FError() ) , 1, 0 ) //Não foi possível criar o diretório \Obrigacoes_TAF\DECLRJ. Erro:
		
		lRet	:=	.F.
	
	endIf

endIf

if lRet
	
	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "/" )
			cDirName += "/"
		EndIf
	Else
		If !Empty( cDirName ) .and. ( SubStr( cDirName, Len( cDirName ), 1 ) <> "\" )
			cDirName += "\"
		EndIf
	EndIf
	
	//Monto nome do arquivo que será gerado
	cFileDest := AllTrim( cDirName ) + cReg
	
	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".TXT"
		cFileDest := cFileDest + ".TXT"
	EndIf
	
	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

endif

Return( lRet )
//---------------------------------------------------------------------
/*/{Protheus.doc} GertxtCons

Geracao do Arquivo TXT da DECLAN RJ. Gera o arquivo dos registros e arquivo 
consolidado

@Return ( Nil )

@Author Marcos Buschmann
@Since 27/08/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GerTxtCons( aWizard )

Local cFileDest  	:=	Alltrim( aWizard[1][1] ) 								//diretorio onde vai ser gerado o arquivo consolidado
Local cPathTxt	:=	TAFGetPath( "2" , "DECLRJ" )		                  //diretorio onde foram gerados os arquivos txt temporarios
Local nx			:=	0
Local cTxtSys		:=	CriaTrab( , .F. ) + ".dcl"
Local nHandle		:=	MsFCreate( cTxtSys )
Local aFiles		:=	{}
Local cStrTxtFIM  := ""

	//Tratamento para Linux onde a barra é invertida
	If GetRemoteType() == 2
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "/" )
			cPathTxt += "/"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "/" )
			cFileDest += "/"
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "/" )
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		EndIf
	Else
		If !Empty( cPathTxt ) .and. ( SubStr( cPathTxt, Len( cPathTxt ), 1 ) <> "\" )
			cPathTxt += "\"
		EndIf
		//Verifica o se Diretório foi digitado sem a barra final e incrementa a barra + nome do arquivo
		If !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) <> "\" )
			cFileDest += "\"
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		elseIf !Empty( cFileDest ) .and. ( SubStr( cFileDest, Len( cFileDest ), 1 ) = "\" )
			cFileDest += Alltrim(aWizard[1][2]) //Incrementa o nome do arquivo de geração
		EndIf
	EndIf

	aFiles := DECLFilesTxt(cPathTxt)
	for nx := 1 to Len( aFiles )
	
		//Verifica se o arquivo foi encontrado no diretorio 
		if File( aFiles[nx][1] ) 
			
			FT_FUSE( aFiles[nx][1] )	//ABRIR
			FT_FGOTOP()				//POSICIONO NO TOPO
			
			while !FT_FEOF()
	   			cBuffer := FT_FREADLN()
	 			cStrTxtFIM += cBuffer + CRLF
				FT_FSKIP()
			endDo
		endif
	next

	If Upper( Right( AllTrim( cFileDest ), 4 ) ) <> ".dcl"
		cFileDest := cFileDest + ".dcl"
	EndIf
	
	WrtStrTxt( nHandle, cStrTxtFIM )
	
	lRet := SaveTxt( nHandle, cTxtSys, cFileDest )

Return( lRet )

// ----------------------------
static function DECLFilesTxt(cPathTxt)

Local aRet	:=	{}

	AADD(aRet,{cPathTxt+"0001.TXT"})
	AADD(aRet,{cPathTxt+"0100.TXT"})
	AADD(aRet,{cPathTxt+"0200.TXT"})
	AADD(aRet,{cPathTxt+"0300.TXT"})
	AADD(aRet,{cPathTxt+"0400.TXT"})
	AADD(aRet,{cPathTxt+"0500.TXT"})
	AADD(aRet,{cPathTxt+"9999.TXT"})

return( aRet )



//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCadAdic

Cadastro adicional para manutenção dos código ANP

@Param
 cPeriodo    - Período de processamento informado na wizard 
 

@Author Rafael Völtz
@Since 09/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFCadAdic(cPeriodo as char)

Local oCheck  := Nil
Local oList   := Nil
Local oOk     := LoadBitmap( GetResources(), "LBOK" )
Local oNo     := LoadBitmap( GetResources(), "LBNO" )
Local nI      := 0
Local aList   := {}
Local lReproc := .F.
Local lCancel := .F.
Local aItens  := getItens(cPeriodo)

//Adiciona os itens a serem exibidos na tela para selecao do usuario
For nI := 1 to Len( aItens )
	aAdd( aList, { .T., aItens[nI,1], aItens[nI,2], aItens[nI,3]  } )
	lReproc := .T.	
Next nI

If lReproc

	Define MsDialog oDlg Title STR0055 STYLE DS_MODALFRAME From 145,0 To 495,638 Of oMainWnd Pixel //"Informações de Estoque"

		oDlg:lEscClose := .F.

		@ 05,15 To 155,310 LABEL STR0056 Of oDlg Pixel //"Itens - Outros"
		@ 20,20 Say STR0057  Of oDlg Pixel 			   //"Selecione os itens a serem considerados no valor de estoque."
		@ 30,20 Say STR0058  Of oDlg Pixel             //'São listados os itens classificados como tipo 99 - Outros.'  
		@ 45,20 CheckBox oCheck	PROMPT STR0059	Size 50,10		On Click( aEval( aList, { |x| x[1] := Iif( x[1] == .T., .F., .T. ) } ), oList:Refresh( .F. ) )	Of oDlg Pixel
		@ 60,20 ListBox oList	Fields HEADER "", STR0060, STR0061	Size 283,090	On DblClick( aList := xFunFClTroca( oList:nAt, aList ), oList:Refresh() ) NoScroll	Of oDlg Pixel // "Código", "Descrição"

		oList:SetArray( aList )
		oList:bLine := { || { Iif( aList[oList:nAt,1], oOk, oNo ), aList[oList:nAt,2], aList[oList:nAt,3] } }

		Define SButton	From 159,255	Type 1	Action oDlg:End()									Enable Of oDlg
		Define SButton	From 159,285	Type 2	Action Iif( lCancel := CancelObr(), oDlg:End(), )	Enable Of oDlg

	Activate MsDialog oDlg Centered

	//Marca apenas os itens selecionados pelo usuario para processamento
	If !lCancel
		
		For nI := 1 to Len( aList )			
			If aList[nI][1] == .F. 
				If Empty(cItens)
					cItens := "'"+ Alltrim(aList[nI][4]) + "'"
				Else
					cItens += ", '"+ Alltrim(aList[nI][4]) + "'"
				EndIf
			EndIf			
		Next nI
		
	EndIf

EndIf

Return ( !lCancel )


//-------------------------------------------------------------------
/*/{Protheus.doc} ItemCols()

ItemCols() - Monta aColsGrid da MsNewGetDados

@Param 
 cAlias  - Alias principal que será alterado
 dIni    - Data inicial informado na wizard
 dFim    - Data final informado na wizard 

@Author Rafael Völtz
@Since 09/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------

Static Function getItens(cPeriodo as char)
Local cAliasQry  as char
Local cPerEstIn1 as char
Local cPerEstIn2 as char
Local cPerEstFn1 as char
Local cPerEstFn2 as char
Local aItens     as array
Local cAnoReg 	 as char
Local cAnoAnt	 as char

 cAnoReg 		:= cPeriodo
 cAnoAnt		:= cValToChar(VAL(cAnoReg)-1)

 aItens := {}

 /* Estoque Inicial */
 cPerEstIn1	:= cAnoAnt+'0101'
 cPerEstIn2	:= cAnoAnt+'1231' 

 /* Estoque Final */	
 cPerEstFn1	:= cAnoReg+'0101'
 cPerEstFn2	:= cAnoReg+'1231'

 nX        := 0
 nY        := 0
 cAliasQry := GetNextAlias() 
 	
	BeginSQL Alias cAliasQry
		SELECT DISTINCT C1L_ID,
						C1L_CODIGO,
			   		    C1L_DESCRI	
  		  FROM %table:C5B% C5B 
   		INNER JOIN %table:C5A% C5A ON C5A.C5A_FILIAL = C5B.C5B_FILIAL AND C5A.C5A_ID = C5B.C5B_ID AND C5A.%NotDel%
   		INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C5B.C5B_FILIAL AND C1L.C1L_ID = C5B.C5B_CODITE AND C1L.%NotDel%
   		INNER JOIN %table:C2M% C2M ON C2M.C2M_ID     = C1L.C1L_TIPITE AND C2M.%NotDel%		 
 		 WHERE C5A.C5A_FILIAL = %xFilial:C5A%
 		   AND C5A.C5A_DTINV BETWEEN %Exp:cPerEstIn1% AND %Exp:cPerEstIn2%
 		   AND C5B.C5B_INDPRO <> 2
   		   AND C2M.C2M_CODIGO = '99'
   		   AND C5B.%NotDel%
   		
   		UNION
   		
   		SELECT DISTINCT C1L_ID,
   						C1L_CODIGO,
			   		    C1L_DESCRI	
  		  FROM %table:C5B% C5B 
   		INNER JOIN %table:C5A% C5A ON C5A.C5A_FILIAL = C5B.C5B_FILIAL AND C5A.C5A_ID = C5B.C5B_ID AND C5A.%NotDel%
   		INNER JOIN %table:C1L% C1L ON C1L.C1L_FILIAL = C5B.C5B_FILIAL AND C1L.C1L_ID = C5B.C5B_CODITE AND C1L.%NotDel%
   		INNER JOIN %table:C2M% C2M ON C2M.C2M_ID     = C1L.C1L_TIPITE AND C2M.%NotDel%		 
 		 WHERE C5A.C5A_FILIAL = %xFilial:C5A%
 		   AND C5A.C5A_DTINV BETWEEN %Exp:cPerEstFn1% AND %Exp:cPerEstFn2%
 		   AND C5B.C5B_INDPRO <> 2
   		   AND C2M.C2M_CODIGO = '99'
   		   AND C5B.%NotDel%		 	
	EndSql
	 
	 While (cAliasQry)->(!Eof())
	 	aAdd(aItens, {Alltrim((cAliasQry)->C1L_CODIGO), Alltrim((cAliasQry)->C1L_DESCRI), (cAliasQry)->C1L_ID })
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())
 
 
Return aItens


