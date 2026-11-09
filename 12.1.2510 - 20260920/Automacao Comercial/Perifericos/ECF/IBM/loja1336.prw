#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFECF.CH"
#INCLUDE "AUTODEF.CH"
 
#DEFINE _BYTESLINHANF  492	
                                                                                                              
Function LOJA1336 ; Return  // "dummy" function - Internal Use                                                
                                                                                               
/*                                                                                              
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJAIBM           บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ              
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse abstrata, possui as funcoes comuns para todos os ECF'S do   บฑฑ
ฑฑบ			 ณmodelo IBM													     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ                              
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                            
Class LJAIBM From LJAEcf                                    
	
	Data oFormasVen																//Formas da venda, objeto do tipo LJCFormasEcf
		                                                    
	Method New(oTotvsApi)														//Metodo construtor   
	
	//Metodos da interface
	Method AbrirPorta(cPorta)							   						//Abre a porta serial para comunicacao com o ECF  
	Method FechaPorta(cPorta)								  					//Fechar a porta serial
	
	//Operacoes Fiscais
	Method AbrirCF(cCnpj, cCliente, cEndereco)							 		//Abri o cupom fiscal
	Method CancelaCF()															//Cancela o cupom fiscal 
	Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
							nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
	    					cUniMed)											//Vende item no ecf
	Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
					nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    			cUniMed)													//Cancela item no ecf
	Method DescItem(nValor)														//Aplica desconto no item do cupom
	Method DescTotal(nValor)													//Aplica desconto no total do cupom
	Method AcresItem(nValor)													//Aplica acrescimo no item do cupom
	Method AcresTotal(nValor)													//Aplica acrescimo no total do cupom
    Method IniFecha()															//Subtotaliza o cupom fiscal, permite acrescimo e desconto no mesmo
	Method EfetuaPgto(cForma, nValor)											//Efetua pagamento
	Method FecharCF(oMsgPromo)													//Fechar cupom fiscal    
	Method TotalizaCF()															//Totaliza o cupom   
	
	//Operacoes nao fiscais
	Method AbrirCNFV(cForma, nValor)											//Abre cupom nao fiscal vinculado
	Method FecharCNFV()															//Fecha cupom nao fiscal vinculado
	Method CancCNFV(cCupom, cForma, nValor)										//Cancela cupom nao fiscal vinculado	
	Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor)			    //Abre cupom nao fiscal
	Method FecharCNF()															//Fecha cupom nao fiscal
	Method PgtoCNF(cForma, nValor)												//Efetua pagamento nao fiscal
	Method CancCNF()															//Cancela cupom nao fiscal
	Method AbrirRG(cRelatorio)													//Abri relatorio gerencial
	Method UsarRG(cTexto)														//Usa o relatorio gerencial
	Method FecharRG()															//Fecha relatorio gerencial   
	Method ConfPGNF(nIndice, cDescr)											//Configura forma de pagamento nao fiscal
	Method ImpTxtNF(oRelatorio, lLinha)											//Imprime texto em cupom nao fiscal  
	Method TxtLivre(cTexto)														//Imprime texto livre
	Method Sangria(oFormas, cTotaliz)								   			//Efetua sangria de caixa
	Method Suprimento(oFormas, cTotaliz)   										//Efetua suprimentro de caixa (entrada de troco)
	Method ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem)		        //Configura o codigo de barras
	Method CodBarras(cString)													//Imprime o codigo de barras 
	Method Teste(cTotaliz, cForma, nValor)
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)			//Efetua o estorno do comprovante de credito e debito
			
	//Relatorios fiscais
	Method LeituraX()															//Emite uma leituraX
	Method ReducaoZ()															//Emite uma Reducao Z
	Method AbrirDia()															//Emite Abertura Dia de inicio de dia
  	Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)							//Leitura da memoria fiscal por data
	Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)						//Leitura da memoria fiscal por reducao
    Method MFDData(dDtInicio, dDtFim)											//Leitura da memoria fita detalhe por data
    Method MFDCoo(cCooInicio, cCooFim)											//Leitura da memoria fita detalhe por Coo  
    Method ConvArq(cArqOri, cArqDes, cTpDado, cTprel, cPar1, ;
   					cPar2, cUser) 												//Converte o arquivo MFD
    Method TipoEData(cDatInicio, cDatFim,cPathArq,cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Data
	Method TipoECrz(cCrzInicio, cCrzFim, cBinario)										//Gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Crz
    
    //Autenticacao e cheque
	Method Autenticar(cLinha, cTexto)											//Autentica documento / cheque
	Method ImpCheque(cBanco	, cValor, cData 	, cFavorecid 	, ;
					 cCidade, cTexto, cExtenso	, cMoedaS 		, ;
					 cMoedaP)													//Imprime cheque 
					 
	Method LeCMC7() 				                                            //Executa a leitura do c๓digo CMC7
	Method DownMF()															//DownLoad da Mem๓ria Fiscal
	Method RedZDado()															//Dados da redu็ใo Z
	   					
	//Configuracoes
	Method ConfigPgto(cForma, cOper)											//Configura forma de pgto
	Method ConfTotNF(cIndice, cTotaliz)							   					//Configura totalizador nao fiscal	
	Method ConfigAliq(nAliq, cTipoIss)											//Configura aliquota		
	Method ConfVerao(cTipo)												   		//Configura a impressora para entrada / saida do horario de verao
	Method ConfRelGer(cIndice, cRelGer)											//Configura relatario gerencial
	
	//Gaveta
	Method AbrirGavet()															//Abre a gaveta
	
	//Informacoes ECF
	Method GetFabric()															//Retorna o fabricante do ecf 
    Method GetModelo()															//Retorna o modelo do ecf
    Method GetVerFirm()															//Retorna a versao do firmeware
    Method GetCNPJ()															//Retorna o CNPJ
    Method GetInsEst()														  	//Retorna a inscricao estadual
    Method GetInsMun()															//Retorna a inscricao municipal
	Method GetNumLj()															//Retorna o numero da loja
	Method GetOper()															//Retorna o operador	
	Method GetRzSoc()															//Retorna a razao social
    Method GetFantas()															//Retorna o nome fantasia
    Method GetEnd1()															//Retorna o endereco 1
  	Method GetEnd2()															//Retorna o endereco 2
    Method GetDadRedZ()															//Retorna os dados da reducao
	Method GetMFTXT()															//Retorna se a impressora gera memoria fiscal em txt    
    Method GetMFSerial()														//Retorna se a impressora gera memoria fiscal serial    
    Method GetHrVerao()														  	//Retorna se a impresora esta em horario de verao
	Method GetAliq()													  		//Retorna as aliquotas cadastradas
	Method GetFormas()															//Retorna as formas cadastradas	
	Method GetTotNF()															//Retorna os totalizadores nao fiscais cadastrados
	Method GetRelGer()														  	//Retorna os relatorios gerenciais cadastrados
	Method GetNrSerie()															//Retorna o numero de serie
	Method GetNumCup()															//Retorna o numero do cupom
	Method GetNumEcf()															//Retorna o numero do ECF
	Method GetNumItem()															//Retorna a qtde de itens impressos no cupom fiscal
	Method GetSubTot()															//Retorna o SubTotal
	Method GetDatHora()															//Retorna a data e hora
	Method GetDesItem()															//Retorna se o ecf permite desconto no item
	Method GetImpFisc()															//Retorna se eh uma impressora fiscal
	Method GetTrunAre()															//Retorna se o ecf trunca ou arredonda
	Method GetChqExt()															//Retorna se o cheque necessita do extenso
	Method GetVdBruta()															//Retorna a venda bruta
	Method GetGranTot()															//Retorna o grande total
    Method GetTotDesc()															//Retorna o valor total de desconto	
  	Method GetDescIss()															//Retorna o valor total de desconto	ISS
    Method GetTotAcre()															//Retorna o valor total de acrescimos
    Method GetAcreIss()															//Retorna o valor total de acrescimos ISS
    Method GetTotCanc()															//Retorna o valor total de cancelados
	Method GetCancIss()															//Retorna o valor total de cancelados ISS
    Method GetIsentos()															//Retorna o valor de isentos
    Method GetNaoTrib()															//Retorna o valor de nao tributados
    Method GetSubstit()															//Retorna o valor de substituidos
    Method GetNumRedZ()															//Retorna o numero de reducoes
    Method GetCancela()															//Retorna o numero de documentos cancelados
	Method GetInterve()															//Retorna o numero de intervencoes CRO
	Method GetDtUltRe()															//Retorna a data da ultima reducao
	Method GetTotIss()															//Retorna o valor total de ISS
	Method GetDataMov()															//Retorna a data do movimento	
	Method GetFlagsFi()															//Retorna as flags fiscais
    Method GetCancIt()															//Retorna se pode cancelar todos os itens
    Method GetVlSupr()														  	//Retorna o valor de suprimento
    Method GetItImp()															//Retorna se todos os itens foram impressos
    Method GetPosFunc()														  	//Se o ecf retorna o Subtotal e o numero de itens impressos no cupom fiscal.
    Method GetPathMFD()                                                         //Retorna o caminho e nome do arquivo de Memoria Fita Detalhe   
    Method GetLetMem()															//Retorna a letra indicativa de MF adicional
    Method GetTipEcf()															//Retorna Tipo de ECF
    Method GetDatSW()		 													//Retorna a Data de instalacao da versao atual do Software Bแsico gravada na Memoria Fiscal do ECF
	Method GetHorSW()			                                                //Retorna o Horario de instalacao da versao atual do Software Bแsico gravada na Memoria Fiscal do ECF
	Method GetGrTIni()															//Retorna o Grande total incicial			
	Method GetNumCnf()															//Retorna o Contador Geral de Opera็ใo Nใo Fiscal
	Method GetNumCrg() 															//Retorna o Contador Geral de Relat๓rio Gerencial
	Method GetNumCcc()															//Retorna o Contador de Comprovante de Cr้dito ou D้bito 
	Method GetDtUDoc()															//Retorna a Data e Hora do ultimo Documento Armazenado na MFD
    Method GetCodEcf() 															//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CำDIGOS DE IDENTIFICAวรO DE ECF
    Method GetPathMF()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal
    Method GetPathMFBin()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal Binแrio
   	Method GetPathTipoE(cBinario)														//Retorna o caminho e nome do arquivo de registro Tipo E Ato Cotepe 17/04 PAF-ECF
    Method BuscInfEcf()															//Busca as informacoes para o funcionamento do sistema (aliquotas, formas de pagto, numero serie, etc...) 
                                        										
	//Metodos internos                                                                              
	Method ObterEst(cRetorno)							//Obtem o status de execucao do ultimo comando
	Method CarregMsg()									//Carrega as mensagens de retorno do ecf	
	Method LeDadoUsu()									//Carrega o C.N.P.J e I.E
	Method LeModelo()                                   //Carrega o Modelo do ECF
	Method LeFrmWare()                                  //Carrega o Firmware do ECF
	Method LeInscMun()                                  //Carrega a I.M.
	Method LeDadImp()									//Carrega o N๚mero de S้rie e Fabricante do ECF
	Method LeCliche()                                 	//Carrega a Razao Social, Nome Fantasia, Endereco 1 & Endereco 2
	Method LeOperador()									//Carrega o nome do Operador - NAO TEM FUNCAO IBM      
	Method LeNumLoja()									//Carrega o numero da Loja
	Method LeECFLoja()									//Carrega o numero do ECF
	Method LeAliq()										//Carrega as aliquotas cadastradas no ECF
	Method LeTotNF()									//Carrega os Totalizadores Nao Fiscais cadastrados no ECF
	Method LeRelGer()									//Carrega os Relatorios Gerenciais cadastrados no ECF
	Method LeFinaliz()									//Carrega as Formas de Pagamento cadastradas no ECF
	Method LeDataJor()								 	//Le a data e hora de abertura da jornada
	Method LeGT()										//Le o Grand Total da impressora
	Method LeCOO()									 	//Le o coo do ultimo documento impresso pela impressora
	Method LeTotCanc()									//Le o total cancelado durante a jornada
	Method LeTotCanISS()									//Le o total de cancelado para ISS
	Method LeTotDesc()								  	//Le o total de desconto durante a jornada
	Method LeTotDesISS()									//Le o total de desconto para ISS
 	Method LeTotIsent()								  	//Le o total isento durante a jornada
  	Method LeTotNTrib()									//Le o total nao tributado durante a jornada
    Method LeTotIss()									//Le o total de ISS durante a jornada
	Method LeVndLiq()									//Le o total de venda liquida durante a jornada
	Method LeVndBrut()									//Le o total de venda bruta durante a jornada		
	Method LeFaseCP() 		  							//Le a fase do cupom fiscal em andamento
	Method LeDadJorn()									//Le os dados da jornada									
	Method LeCupIni()									//Le o cupom inicial do dia
	Method HexToDec(cHex)                               //Converte hexa para decimal
	Method BuscaAliq(cTribut, nAliquota)				//Busca a aliquota para ser enviada a impressora  
 	Method InicVar()									//Inicializando variaveis
    Method GuardarPgt(cForma, nValor)					//Guarda as formas da venda 
    Method TratParam(cRetorno)								//Metodo que tira caracteres dos parametros      
    Method CorrigRet(cRetorno)                              //Metodo que corrige o retorno
	Method TrataTags( cMensagem )							//Trata as tags enviadas para a mensagem promocional
    Method GetCodDllECF()										//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE CำDIGOS DE IDENTIFICAวรO DE ECF
	Method GetNomeECF()										//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Versใo do Firmware                                                                                                              
	Method IdCliente(cCNPJ, cNome, cEnd)
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJAIBM.     			    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/         
Method New(oTotvsApi) Class LJAIBM                                                         
   
	//Executa o metodo construtor da classe pai
	_Super:New(oTotvsApi)
	
	//Inicializando variaveis
    ::oFormasVen := Nil  
    ::cPathMFD   := "C:\RELMFD.TXT" 
    ::cPathMF    := AllTrim(GetPvProfString("Sistema", "Path", "C:\LeituraMF.txt", GetClientDir() + "IBMFI32.INI"))
    If Right(::cPathMF,1) <> "\" 
    	::cPathMF  := ::cPathMF  + "\"
    EndIf                                                         
    //Carrega as mensagens
	::CarregMsg()
	
Return Self            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1335  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura da porta serial.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNumero da porta COM (nao utilizado)						  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AbrirPorta(cPorta) Class LJAIBM
	                                                                                           
/*  	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
 

	//Prepara os parametros de envio                                      
	oParams := ::PrepParam({IBM, "IBM_FI_AbrePortaSerial"})
 
    //Envia o comando                                         
    cRetorno := ::EnviarCom(oParams)                                       

    //Trata o retorno       
    oRetorno := ::TratarRet(cRetorno)   */      
    oRetorno := ::TratarRet("0000")

Return oRetorno      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo fechamento da porta serial.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNumero da porta COM (nao utilizado)						  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FechaPorta(cPorta) Class LJAIBM

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       	//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil      	//Objeto que sera retornado pela funcao
			
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaPortaSerial"})
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    //Trata o retorno   
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura do cupom fiscal            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCnpj) - C.N.P.J/C.P.F do cliente.			   	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cCliente) - Nome do cliente.   				  บฑฑ
ฑฑบ			 ณEXPC3 (3 - cEndereco) - Endereco do cliente.			   	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf									      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method AbrirCF(cCnpj, cCliente, cEndereco) Class LJAIBM

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	

	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AbreCupomMFD", Left(cCnpj,20), Left(cCliente,30), Left(cEndereco,80)})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)	
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes	 บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo cancelamento do cupom fiscal        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CancelaCF() Class LJAIBM   

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao	

	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaCupom"})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)                 
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVenderItemบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela venda de um item no cupom fiscal    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                    	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCodigo) - Codigo do item vendido.			   	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cDescricao) - Descricao do item.  			  	  บฑฑ
ฑฑบ			 ณEXPC3 (3 - cTribut) - Tipo da tributacao.				      บฑฑ
ฑฑบ			 ณEXPN1 (4 - nAliquota) - Aliquota do item.			   	 	  บฑฑ
ฑฑบ			 ณEXPN2 (5 - nQtde) - Quantidade do item vendido.	 	      บฑฑ
ฑฑบ			 ณEXPN3 (6 - nVlUnit) - Valor unitario do item.			   	  บฑฑ
ฑฑบ			 ณEXPN4 (7 - nDesconto) - Valor do desconto do item.	      บฑฑ
ฑฑบ			 ณEXPC4 (8 - cComplemen) - Complemento da descricao.          บฑฑ
ฑฑบ			 ณEXPC5 (9 - cUniMed) - Unidade de medida do item.		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
						nQtde	, nVlUnit	, nDesconto	, cComplemen, ;
	    				cUniMed ) Class LJAIBM   
					
	Local oParams 		:= Nil	//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil	//Objeto que sera retornado pela funcao		
	Local cAliquota	:= ""		//String temporaria que guarda o indice da aliquota
	Local cQtde			:= ""		//Qantidade
	Local cVlUnit		:= ""		//Valor unitario   
	Local cTipoDesc   := Nil   //Valor do Desconto
	Local cValorDesc  := Nil   //Valor do Acrescimo      
	Local cValorAcres  := ""
	
	//Busca aliquota 
   cAliquota := ::BuscaAliq(cTribut, nAliquota)	
	
  	If Empty(cAliquota) 
		//Aliquota nao cadastrada no ECF
		oRetorno := ::TratarRet("0521")
	Else 
		//Prepara os valores
		cCodigo := AllTrim(Substr(cCodigo, 1, 14))
		cQtde := Transform(nQtde, "@E 9,999.999")
		cVlUnit := Transform(nVlUnit, "@E 99,999.99")
	
		cDescricao = AllTrim(SubStr(AllTrim(cDescricao), 1, 200 ))
		
		//Desconto serแ efetuado em outro m้todo especifico.
		cTipoDesc := "%" 
		cValorDesc := cValorAcres := "0000"
		                   
		
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_VendeItemDepartamento", cCodigo, cDescricao, cAliquota,cVlUnit, ;
								cQtde,  cValorAcres, cValorDesc, "0",Left(cUniMed,2)})  
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)                                
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
		
		If( ( nDesconto > 0) .AND. ( oRetorno:cAcao <> ERRO ) )				
			oRetorno := ::DescItem(nDesconto)		//Efetua o desconto sobre o item.
		EndIf
  	EndIf 
	
	/**************************************************************************/
	//DEFINO MANUALMENTE A FASE DO CF, IBM  NAO TEM ESTA FUNCAO DE RETORNO
	::oFlagsFisc:lCFItem  := .T. 
	::oFlagsFisc:lCFPagto := .F. 
	::oFlagsFisc:lCFTot   := .F. 
	oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
	/**************************************************************************/
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancItem  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo cancelamento item no cupom fiscal   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cItem) - Numero do item vendido.			   	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cCodigo) - Codigo do item vendido.			  	  บฑฑ
ฑฑบ			 ณEXPC3 (3 - cDescricao) - Descricao do item.  			  	  บฑฑ
ฑฑบ			 ณEXPC4 (4 - cTribut) - N/A.		  						  บฑฑ
ฑฑบ			 ณEXPN1 (5 - nAliquota) - Aliquota do item.			   	 	  บฑฑ
ฑฑบ			 ณEXPN2 (6 - nQtde) - Quantidade do item vendido.	 	      บฑฑ
ฑฑบ			 ณEXPN3 (7 - nVlUnit) - Valor unitario do item.			   	  บฑฑ
ฑฑบ			 ณEXPN4 (8 - nDesconto) - Valor do desconto do item.	      บฑฑ
ฑฑบ			 ณEXPC9 (9 - cUniMed) - Unidade de medida do item.		      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CancItem(cItem) Class LJAIBM
	    			
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao
	Local cNItem 	:= Nil
	
	cNItem := AllTrim(cItem)
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaItemGenerico", cNItem})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)    			

Return oRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDescItem  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo desconto em um item do cupom fiscal บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nValor) - Valor do desconto.			   	  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
                  
Method DescItem(nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao			
	Local cValor	 := ""			//Valor do desconto     
	Local	cItem 	 := ""         //Descricao do item
	Local	cNumItem  := ""         //Numero do item
	Local cAcrDes   := "D"        //Se ้ acrescimo ou desconto
	Local cTpAcrDes := "$"        //porcentagem ou real
   

	//Busca o numero do ultimo item lan็ado
	cItem 	:= ::GetNumItem()	
	cNumItem :=  substr(cItem, 2, 3)
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AcrescimoDescontoItemMFD", cNumItem, cAcrDes, cTpAcrDes, cValor})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDescTotal บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo desconto no subtotal do cupom fiscalบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nValor) - Valor do desconto.			   	  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DescTotal(nValor) Class LJAIBM

	Local oRetorno := Nil				//Objeto que sera retornado pela funcao			
	Local	cAcre    := "D"   			//Indica se ้ A=Acrescimo, D=Desconto
	Local	cTpAcre  := "$"            //Indica se ้ Percentual(%) ou valor ($)
	Local	cValAcre := "0000"         //Valor do Acrescimo
	Local	cValDesc := Nil            //Valor do Desconto    

	cValDesc := AllTrim(Str(nValor * 100))       
	
	//Inicio o fechamento do cupom para creditar ou debitar valor 
	oRetorno := ::IniFecha(cAcre, cTpAcre, cValAcre, cValDesc)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcresItem บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo acrescimo em um item do  			  บฑฑ
ฑฑบ          ณcupom fiscal                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nValor) - Valor do acrescimo.			   	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AcresItem(nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao			
	Local cValor	 := ""			//Valor do desconto     
	Local	cItem 	 := ""         //Descricao do item
	Local cNumItem  := ""         //Numero do item
	Local cAcrDes   := "A"        //Acrescimo ou Desconto
	Local cTpAcrDes := "$"        //Real ou percentual
   

	//Busca o numero do ultimo item lan็ado
	cItem := ::GetNumItem()	
	cNumItem :=  substr(cItem, 2, 3)
	
	cValor := AllTrim(Str(nValor * 100))
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AcrescimoDescontoItemMFD", cNumItem, cAcrDes, cTpAcrDes, cValor})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcresTotalบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo acrescimo no subtotal do cupom	  	  บฑฑ
ฑฑบ          ณfiscal                                                	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nValor) - Valor do acrescimo.			   	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AcresTotal(nValor) Class LJAIBM

	Local oRetorno := Nil		//Objeto que sera retornado pela funcao			
	Local	cAcre    := "A"   	//Indica se ้ A=Acrescimo, D=Desconto
	Local	cTpAcre  := "$"      //Indica se ้ Percentual(%) ou valor ($)
	Local	cValAcre :=  Nil     //Valor do Acrescimo
	Local	cValDesc := "0000"   //Valor do Desconto

	cValAcre := AllTrim(Str(nValor * 100))       
	
	//Inicio o fechamento do cupom para creditar ou debitar valor
	oRetorno := ::IniFecha(cAcre, cTpAcre, cValAcre, cValDesc)

Return oRetorno  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAcresTotalบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel ppor subtotalizar o cupom fiscal		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ																				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method IniFecha(cAcre, cTpAcre, cValAcre, cValDesc) Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao			
   
		//Prepara os parametros de envio
		oParams := ::PrepParam({ IBM, "IBM_FI_IniciaFechamentoCupomMFD", cAcre, cTpAcre, cValAcre, cValDesc})
		
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)		 
		
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEfetuaPgtoบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo pagamento do cupom fiscal			  บฑฑ
ฑฑบ          ณ                                                 			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  บฑฑ
ฑฑบ          ณEXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EfetuaPgto(cForma, nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao		
	Local cValor	 := ""			//Valor do pagamento         
	Local cParcela  := Nil      	//Numero de parcelas da forma de pagamento
	Local cDescfPg  := Nil 	  		//Descricao da forma de pagamento       
	Local cAcre     := "X" 			//Indica se haverแ acresicmo(A), desconto(D) ou ambos(X) no Cupom fiscal no total
	Local cTpAcre   := "%" 			//tipo de acr้scimo ou desconto ($)valor, (%)percentual no total
	Local cValAcre  := "0000" 		//Valor do acrescimo no total
	Local cValDesc  := "0000" 		//valor do desconto no total

	//Verifica se a forma esta cadastrada no ecf                                    
	oRetorno := ::TratarRet("0000")
	
	If oRetorno:cAcao <> ERRO                                        
      
      	//Inicio o fechamento do cupom para creditar ou debitar valor
   		::IniFecha(cAcre, cTpAcre, cValAcre, cValDesc)    
   		
      If oRetorno:cAcao <> ERRO

			//cIndice := oRetorno:oRetorno:cIndice                                       
			//Prepara o valor
			cValor := AllTrim(Str(nValor * 100)) 
			
			cParcela := "1" //somente para comprovante nao fiscal vinculado
			cDescfPg := ""     
			//Prepara os parametros de envio
			oParams := ::PrepParam({ IBM, "IBM_FI_EfetuaFormaPagamentoMFD", substr(cForma, 1, 16), cValor, cParcela, cDescfPg})
			//Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
			//Trata o retorno    
			oRetorno := ::TratarRet(cRetorno)
			                                        
		EndIf
		
		If oRetorno:cAcao <> ERRO
			//Guarda forma de pagto
			::GuardarPgt(cForma, nValor)
		EndIf
	EndIf   
	
	/**************************************************************************/
	//DEFINO MANUALMENTE A FASE DO CF, IBM  NAO TEM ESTA FUNCAO DE RETORNO
	::oFlagsFisc:lCFItem  := .F. 
	::oFlagsFisc:lCFPagto := .T. 
	::oFlagsFisc:lCFTot   := .F. 
	oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
	/**************************************************************************/

Return oRetorno
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFecharCF  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo fechamento do cupom fiscal          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oMsgPromo) - Mensagem promocional				  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FecharCF(oMsgPromo) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil	//Objeto que sera retornado pela funcao		
	Local nDX		:= 1			//Contador utilizado no comando "For"
	Local nLinhas	:= 8			//Numero de linhas promocionais
	Local cMsgPro  := ""	

		//Limita o numero de linhas promocionais a 8
		If( oMsgPromo:Count() < 8)
			nLinhas := oMsgPromo:Count()
		EndIf
	
		//Copia as linhas recebidas pela funcao, truncando (se necessario) a linha em 48 caracteres.	
		For nDX := 1 To nLinhas
			cMsgPro += ::TrataTags(Substr(oMsgPromo:Elements(nDX), 1, 48))
		Next nDX		
                                                                                         
		//Prepara os parametros de envio
		
		oParams := ::PrepParam({IBM, "IBM_FI_TerminaFechamentoCupom", cMsgPro})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
	                                                    
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
	
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)       
		
		/**************************************************************************/
		//DEFINO MANUALMENTE A FASE DO CF, IBM  NAO TEM ESTA FUNCAO DE RETORNO
		::oFlagsFisc:lCFItem  := .F. 
		::oFlagsFisc:lCFPagto := .F. 
		::oFlagsFisc:lCFTot   := .T. 
		oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
		/**************************************************************************/
			

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por totalizar o cupom.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TotalizaCF()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//NOTA: As impressoras IBM nao precisam receber o comando de totalizacao de cupom.

	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณAbrirCNFV บAutor  ณVendas Clientes     บ Data ณ  20/06/11  	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura de um cupom nao fiscal     	  บฑฑ
ฑฑบ          ณvinculado													  	 			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  	  บฑฑ
ฑฑบ          ณEXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  	  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AbrirCNFV(cForma, nValor) Class LJAIBM                                      '

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao		
	Local cValor	 := ""			//Valor do desconto
	Local cNumCupom := Nil			//Numero do Cupom	
	Local cCPF 		 := space(29)  //CPF do cliente
	Local cNome		 := space(30)  //Nome do cliente
	Local cEndereco := space(80)  //Endereco do cliente  
	Local nCount    := 0

	//Verifica se a forma esta cadastrada no ecf                                      
  	oRetorno := ::TratarRet("0000")         

	//Verifica as formas da venda anterior para pegar o valor correto
	If ::oFormasVen != Nil
		For nCount := 1 To ::oFormasVen:Count()
	    	If AllTrim(Upper(::oFormasVen:Elements(nCount):cForma)) == AllTrim(Upper(cForma))
	    		nValor := ::oFormasVen:Elements(nCount):nValor
	    		Exit
	    	EndIf
		Next
	EndIf
	
	If oRetorno:cAcao <> ERRO                
	
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100)) 
		                                                 
		cNumCupom := ::GetNumCup():oRetorno       

     	//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_AbreComprovanteNaoFiscalVinculadoMFD", substr(cForma, 1, 16), cValor, substr(cNumCupom, 1, 6),  cCPF, cNome, cEndereco})
	
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
	
		//Obtem o Estado da impressora                   
		cRetorno := ::ObterEst(cRetorno)                 
	
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFecharCNFVบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo fechamento de um cupom nao fiscal   บฑฑ
ฑฑบ          ณvinculado													  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FecharCNFV() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaComprovanteNaoFiscalVinculado"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณCancCNFV  บAutor  ณVendas Clientes     บ Data ณ  20/06/11     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo cancelamento de um cupom nao fiscal    บฑฑ
ฑฑบ          ณvinculado													     			     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     	  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCupom) - Coo do cupom fiscal relativo ao pagamento.บฑฑ
ฑฑบ          ณEXPC2 (2 - cForma) - Nome da forma de pagamento utilizada.  	  บฑฑ
ฑฑบ          ณEXPN1 (3 - nValor) - Valor do pagamento efetuado.   	  	  	  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  	 			  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CancCNFV(cCupom, cForma, nValor) Class LJAIBM       

	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao 
	Local cCPF        := space(29)
	Local cNome			:= space(30)
	Local cEndereco	:= space(80)

	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaRecebimentoNaoFiscalMFD", cCPF, cNome, cEndereco})

	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)

	//Obtem o Estado da impressora             
	cRetorno := ::ObterEst(cRetorno)

	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAbrirCNF  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura de um cupom nao fiscal nao บฑฑ
ฑฑบ          ณvinculado													  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCnpj) - C.N.P.J do cliente.					  		  บฑฑ
ฑฑบ          ณEXPC2 (2 - cCliente) - Nome do cliente.  					     บฑฑ
ฑฑบ          ณEXPC3 (3 - cEndereco) - Endereco do cliente.   	  	  	     บฑฑ
ฑฑบ          ณEXPC4 (4 - cTotaliz) - Totalizador nao fiscal utilizado. 	  บฑฑ
ฑฑบ          ณEXPN1 (5 - nValor) - Valor do item nao fiscal. 	  		     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ                 
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor) Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao	
	Local cCPFCNPJ	 := cCnpj
	Local cNome		 := cCliente
	Local cEnd 		 := cEndereco       
	Local cIndice   := Nil                                               
    
  	//Verifica se o totalizador esta cadastrado no ecf
	oRetorno := ::GetTotaliz(cTotaliz) 
	
	If oRetorno:cAcao == OK
		//Pega o indice do totalizador
		cIndice := oRetorno:oRetorno:cIndice
		//Prepara o valor
		cValor := AllTrim(Str(nValor * 100))
		
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_AbreRecebimentoNaoFiscalMFD", cCPFCNPJ, cNome, cEnd})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)	 
		
			If oRetorno:cAcao <> ERRO	                  
	
				//Prepara os parametros de envio
				oParams := ::PrepParam({IBM, "IBM_FI_EfetuaRecebimentoNaoFiscalMFD", cIndice, cValor})    
				//Envia o comando    	
				cRetorno := ::EnviarCom(oParams)
				//Obtem o Estado da impressora                
				cRetorno := ::ObterEst(cRetorno)
				//Trata o retorno    
				oRetorno := ::TratarRet(cRetorno) 
				
			EndIF
		
	EndIF

Return oRetorno

/*                                   
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFecharCNF บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo fechamento de um cupom nao fiscal   บฑฑ
ฑฑบ          ณnao vinculado											      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FecharCNF() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cMsg     := ""		
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaRecebimentoNaoFiscalMFD", cMsg})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)           
	//Obtem o Estado da impressora                                                                      
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPgtoCNF   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo pagamento do cupom nao fiscal nao   บฑฑ
ฑฑบ          ณvinculado                                        			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cForma) - Nome da forma de pagamento utilizada.  บฑฑ
ฑฑบ          ณEXPN1 (2 - nValor) - Valor do pagamento efetuado.   	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PgtoCNF(cForma, nValor) Class LJAIBM

	Local oParams 	 := Nil		 //Objeto para passagem dos parametros
	Local cRetorno  := ""		 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil		 //Objeto que sera retornado pela funcao		
	Local cValor	 := space(14) //Valor do pagamento  
	Local cAcrdes   := "X" 		  //acrescimo x=ambos d=desconto a=acrescimo
	Local cTpAcrDes := "%"  	  //tipo de acrescimo valor ou percentual 
	Local cValAcr   := "0000"    //valor do acrescimo
	Local cValDes   := "0000"    //valor do desconto    
	Local cParcela  := "1" 		 //somente para comprovante nao fiscal vinculado
	Local	cDescfPg  := ""  		//descricao do pagamento
		
	//Verifica se a forma esta cadastrada no ecf
	oRetorno := ::GetForma(substr(cForma, 1, 16))
	
	If oRetorno:cAcao <> ERRO		   
			
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_IniciaFechamentoRecebimentoNaoFiscalMFD", cAcrdes, cTpAcrDes, cValAcr, cValDes})    
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		//Obtem o Estado da impressora                
		cRetorno := ::ObterEst(cRetorno)
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
				
				If oRetorno:cAcao <> ERRO		      
					
					//Prepara o valor
					cValor := AllTrim(Str(nValor * 100))
					
					//Prepara os parametros de envio
					oParams := ::PrepParam({ IBM, "IBM_FI_EfetuaFormaPagamentoMFD", substr(cForma, 1, 16), cValor, cParcela, cDescfPg})
					//Envia o comando    	
					cRetorno := ::EnviarCom(oParams)
					//Obtem o Estado da impressora
					cRetorno := ::ObterEst(cRetorno)
					//Trata o retorno    
					oRetorno := ::TratarRet(cRetorno)
			
				EndIF			
	
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancCNF   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo cancelamento do cupom nao fiscal    บฑฑ
ฑฑบ          ณnao vinculado                                        		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CancCNF() Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
	Local cCpf        := space(29)			
	Local cNome       := space(30)			
	Local cEnde       := space(80)				
		                                
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CancelaCupomMFD", cCpf,	cNome, cEnde}) 

	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
 	
 	cRetorno := ::ObterEst(cRetorno)                                           
	
	//Trata o retorno         
	oRetorno := ::TratarRet(cRetorno)  

Return oRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAbrirRG   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura de um relatorio gerencial  บฑฑ
ฑฑบ          ณ		                                        			  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cRelatorio) - Indice do relatorio.  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AbrirRG(cRelatorio) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao		
	Local cIndice	:= ""		//String temporaria que guarda o indice do relatorio
	                 
	cIndice := "01"

	If ( !(cRelatorio == Nil) .OR. !Empty(AllTrim(cRelatorio)) )  //Quando a impressใo ้ feita por titulo de relatorio gerencial
		cIndice := AllTrim(cRelatorio)
	EndIf
                 
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AbreRelatorioGerencialMFD", cIndice})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUsaRG  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por escrever no relatorio gerencial   	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcTexto = texto a ser impresso										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method UsarRG(cTexto) Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
	Local cTextoEnv   := Nil
	
	cTextoEnv := substr(cTexto, 1, 492) 	 		                              
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_UsaRelatorioGerencialMFD", cTextoEnv})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora                
	cRetorno := ::ObterEst(cRetorno)                   
	//Trata o retorno                                       
	oRetorno := ::TratarRet(cRetorno) 
	
	                                               
Return oRetorno                                                   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFecharRG  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo fechamento do relatorio gerencial   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FecharRG() Class LJAIBM                     

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao			
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FechaRelatorioGerencial"})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFecharRG  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por configurar pagamento nao fiscal		  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfPGNF(nIndice, cDescr) Class LJAIBM                     

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao			
	                                                                                  
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NomeiaTotalizadorNaoSujeitoIcms", nIndice, cDescr})
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno                                                                              
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpTxtNF  บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelimpressao de linhas nao fiscais   	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oRelatorio) - Linhas nao fiscais.			  	  บฑฑ
ฑฑบ			 ณExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf									      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImpTxtNF(oRelatorio, lLinha) Class LJAIBM

	Local oParams 	:= Nil					//Objeto para passagem dos parametros
	Local cRetorno 	:= ""       			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil         			//Objeto que sera retornado pela funcao
	Local nCont     := 1           			//Contador do For...
	Local lPrint	:= .T.					//Flag responsavel por bloquear o envio da linha, caso tenha acontecido algum erro no comando anterior
	
	If !lLinha 
		oRelatorio := Self:PrepRel(oRelatorio, CHR(10), _BYTESLINHANF)
	EndIf
	
	//Copia as linhas recebidas pela funcao, truncando (se necessario) a linha em 56 caracteres.	
	For nCont := 1 To oRelatorio:Count()
                   
		oParams  := Self:PrepParam({IBM, "IBM_FI_UsaComprovanteNaoFiscalVinculado", ::TratParam(oRelatorio:Elements(nCont)) })	
		                        
		If (lPrint == .T.)
			//Envia o comando    	
			cRetorno := Self:EnviarCom(oParams)
			//Trata o retorno    
			oRetorno := Self:TratarRet(cRetorno)
			
			If( oRetorno:cAcao <> OK )
				lPrint := .F.
			EndIf
		EndIf
	Next nCont
	
Return oRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpTxtNF  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelimpressao de linhas nao fiscais   	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oRelatorio) - Linhas nao fiscais.				  	  บฑฑ
ฑฑบ			 ณExpL1 (2 - lLinha) - Se vai ser impresso linha a linha.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TxtLivre(cTexto) Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao		
	Local cDados	:= Space(492)	//Contador utilizado no comando "For"	

   cDados := Substr(cTexto,1,492)
   
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_UsaComprovanteNaoFiscalVinculado", cDados})			

	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
			                                                     
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSangria   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a Sangria  				  บฑฑ
ฑฑบ          ณ		                                        			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamentoบฑฑ
ฑฑบ			 ณEXPC1 (2 - cTotaliz) - Totalizador da sangria.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf			  	     			          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Sangria(oFormas, cTotaliz) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao		
	Local cValor	:= ""		//Valor da sangria
	Local nCount	:= 1		//Contador utilizado no For...
	Local nValor	:= 0		//Valor total da sangria
		
	//Pega o valor da sangria
	For nCount:=1 To oFormas:Count()
		nValor += oFormas:Elements(nCount):nValor
	Next nCont
	
	cValor := AllTrim(Str(nValor * 100,13,0))
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_Sangria", cValor})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSuprimentoบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar o Fundo de Troco.			  บฑฑ
ฑฑบ          ณ		                                        			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPO1 (1 - oFormas) - LJCFORMASECF com as fomas de pagamentoบฑฑ
ฑฑบ			 ณEXPC1 (2 - cTotaliz) - Totalizador da suprimento.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Suprimento(oFormas, cTotaliz) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao		
	Local cValor	:= ""		//Valor da sangria
	Local nCount	:= 1		//Contador utilizado no For...
    Local cForma    := space(16)
    Local nFormas   := oFormas:Count() 	//Quantidade de formas de pagamento       //Contador das formas de pagamento
    
    
    For nCount:=1 To nFormas
		//Efetua o pagamento do cupom nao fiscal
		cValor := AllTrim(Str(oFormas:Elements(nCount):nValor * 100,13,0 )) 
		cForma := Left(oFormas:Elements(nCount):cForma, 16)  
		oParams := ::PrepParam({IBM, "IBM_FI_Suprimento", cValor, cForma})            
		
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
		//Trata o retorno    
		oRetorno := ::TratarRet(cRetorno)
	    If(oRetorno:cAcao <> OK) 	
			Exit    
	    EndIf
    Next nCont   

Return oRetorno     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por configurar o codigo de barras		  บฑฑ
ฑฑบ          ณ		                                        			  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nAltura) - Altura do codigo de barras  		     บฑฑ
ฑฑบ			 ณEXPN2 (2 - nLargura) - Largura do codigo de barras 		     บฑฑ
ฑฑบ			 ณEXPN3 (3 - nPosicao) - Posicao do codigo de barras 		     บฑฑ
ฑฑบ			 ณEXPN4 (4 - nFonte) - Fonte do codigo de barras  			     บฑฑ
ฑฑบ			 ณEXPN5 (5 - nMargem) - Margem do codigo de barras 			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfCodBar(nAltura, nLargura, nPosicao, nFonte, nMargem) Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao		
 	Local cAltura  	:= Nil      //Altura do codigo de barras
   Local cLargura 	:= Nil      //Largura do codigo de barras
   Local cPosicao 	:= Nil      //Posicao do codigo de barras
   Local cFonte   	:= Nil      //Fonte do codigo de barras
   Local cMargem  	:= Nil      //Margem do codigo de barras
   
	cAltura  := AllTrim(str(nAltura))
   cLargura := AllTrim(str(nLargura))
   cPosicao := AllTrim(str(nPosicao))
   cFonte   := AllTrim(str(nFonte))
   cMargem  := AllTrim(str(nMargem))             

	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ConfiguraCodigoBarrasMFD", cAltura, cLargura, cPosicao, cFonte, cMargem})
	
	//Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336 บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por configurar o codigo de barras		  บฑฑ
ฑฑบ          ณ		                                        			  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ EXPC1 (1 - cString) - Valor do codigo de barras.  		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     

Method CodBarras(cString) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao		

 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_CodigoBarrasCODE128MFD", cString})
  
	//Envia o comando    	                                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno    
	oRetorno := ::TratarRet(cRetorno)

Return oRetorno


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณEstNFiscVincบAutor  ณVendas Clientes     บ Data ณ  13/03/14 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em abrir um cupom nao fiscal. 			  บฑฑ
ฑฑบ          ณ								                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - cCPFCNPJ) - CPF/CNPJ do cliente		  		  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cCliente) - Nome do Cliente					  บฑฑ
ฑฑบ			 ณEXPC3 (3 - cEndereco) - Endere็o do cliente			      บฑฑ
ฑฑบ			 ณEXPC4 (4 - cMensagem) - Mensagem para o cupom de cancelamntoบฑฑ
ฑฑบ			 ณEXPC5 (5 - cCOOCCD) - COO do Comprovante de Credito e Debitoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto													  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD) Class LJAIBM
Local oParams 	:= Nil		//Objeto para passagem dos parametros
Local cRetorno 	:= ""		//String contendo o retorno da funcao que envia o comando para a serial
Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao
		           
//Prepara os parametros de envio
oParams := ::PrepParam({IBM, "IBM_FI_EstornoNaoFiscalVinculadoMFD", cCPFCNPJ,cCliente,cEndereco})

//Envia o comando    	
cRetorno := ::EnviarCom(oParams)

//Obtem o Estado da impressora
cRetorno := ::ObterEst(cRetorno)

//Trata o retorno    
oRetorno := ::TratarRet(cRetorno)

If oRetorno:cAcao == OK
	oRetorno := ::TxtLivre(cMensagem)
	
	If oRetorno:cAcao == OK
		oRetorno := ::FecharCNFV()
	EndIf
EndIf
        
Return oRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReducaoZ  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a Reducao Z.	  			  	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ReducaoZ() Class LJAIBM            

  	Local oParams 		:= Nil							 //Objeto para passagem dos parametros
	Local cRetorno 	:= ""		   					 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		   				 //Objeto que sera retornado pela funcao
	Local oRedZ			:= LJCDadosReducaoZ():New() //Objeto contendo os dados da reducao Z  
	Local nDX			:= 1								 //Contador utilizado no comando "For"
	Local nImposto		:= 0								 //Valor do imposto devido.
	Local cDados1  	:= Space(79)  					 //String que receber a tabela de aliquotas cadastradas no ECF
	Local cDados2  	:= Space(48)  					 //String que receber a tabela de aliquotas ISS cadastradas no ECF
	Local cDados3  	:= Space(889)  				 //String que receber a tabela de aliquotas ISS cadastradas no ECF
	Local cDados4     := Space(1278)
	Local nAliTmp   	:= 0
	Local nVlrTmp     := 0
	Local cIndAliqISS := NIL
	Local aArrAli     := {}
	Local cTotal      := Nil
	Local aArrVlr     := {}
	Local cData       := ""
	Local cHora			:= ""
	
	//Inicia o preenchimento do objeto LJCDadosReducaoZ             
	oRedZ:cNumEcf	:= ::cNumEcf                                                      
   oRedZ:cNrSerie	:= ::cNrSerie
   	    
	oRetorno := ::LeDataJor()                                                   
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:dDataMov := CTOD(oRetorno:oRetorno)            
		oRetorno := ::LeGT()    
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nGranTotal := Val(oRetorno:oRetorno) / 100
		oRetorno := ::LeCOO()  
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:cNumCupFim := oRetorno:oRetorno
		oRetorno := ::LeTotCanc()
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotCancel := oRetorno:oRetorno
		oRetorno := ::LeTotCanISS()
	EndIf

	If ( oRetorno:cAcao <> ERRO )
		oRedZ:nTotCanISS := oRetorno:oRetorno
		oRetorno := ::LeTotDesc() 
	EndIf
	   		
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotDesc := oRetorno:oRetorno
		oRetorno := ::LeTotDesISS()
	EndIf

	If ( oRetorno:cAcao <> ERRO )
		oRedZ:nTotDesISS := oRetorno:oRetorno
		oRetorno := ::LeTotIsent() 
	EndIf
	
   	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotIsent	:= oRetorno:oRetorno
		oRetorno := ::LeTotNTrib()  
	EndIf
	
  	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotNTrib := oRetorno:oRetorno
		oRetorno := ::LeTotIss()    
	EndIf
	
 	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotIss := oRetorno:oRetorno
		oRetorno := ::LeVndLiq()   
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nVendaLiq := oRetorno:oRetorno
		oRetorno := ::LeVndBrut()   
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nVendaBrut := oRetorno:oRetorno
		oRetorno := ::GetSubstit()     
	EndIf
	
	If( oRetorno:cAcao <> ERRO )
		oRedZ:nTotSubst := oRetorno:oRetorno
		oRetorno := ::GetDatHora()    
	EndIf
    
	If( oRetorno:cAcao <> ERRO )
		oRedZ:dDataRed := CTOD(Substr(oRetorno:oRetorno, 1, 10))
		oRetorno := ::GetInterve() 
	EndIf
	
	If( oRetorno:cAcao <> ERRO )                                      
		oRedZ:cCro := oRetorno:oRetorno
	    oRetorno := ::GetNumCup() 
	EndIf

	If( oRetorno:cAcao <> ERRO )
		oRedZ:cNumCupIni := strzero((val(oRetorno:oRetorno)+1),6, 0)
	EndIf
    
	oRedZ:cCoo := StrZero(Val(oRedZ:cNumCupFim) + 1, 6)
	                                                                        
	//Tabela de totalizadores parciais		                                    
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados3})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)  
    
	     cTotal := substr(Alltrim(oParams:Elements(3):cParametro), 1, 224)
		  aArrVlr := {}   
		   
		   For nDx := 1 To 224 Step 14
		   	aAdd(aArrVlr, Val(SubStr(cTotal, nDx, 14)))
		   Next	                                          
    
		    //Todas as aliquotas cadastradas serao retornadas com "," como delimitador  
	  		//Prepara os parametros de envio 
			oParams := ::PrepParam({IBM, "IBM_FI_RetornoAliquotas", cDados1})
		
		   //Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
		
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
		
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)

		   If(oRetorno:cAcao <> ERRO) 
		  
		  		aArrAli := strtokarr(AllTrim(oParams:Elements(3):cParametro), ",")
		    
			    
	   	 	//Verfico as aliqutoas de ISS para serem descartadas
			   //Prepara os parametros de envio 
				oParams := ::PrepParam({IBM, "IBM_FI_VerificaIndiceAliquotasIss", cDados2})
		
		    	//Envia o comando    	
				cRetorno := ::EnviarCom(oParams)
				
				//Obtem o Estado da impressora
				cRetorno := ::ObterEst(cRetorno)
				
			    //Trata o retorno                                 
			    oRetorno := ::TratarRet(cRetorno)  
		    
		    
		    	If(oRetorno:cAcao <> ERRO) 
		    
			    	cIndAliqISS := AllTrim(oParams:Elements(3):cParametro)
			                           
    		  			For nDX := 1 To Len(aArrAli)
    			
		    			    nAliTmp := Val(aArrAli[nDx])
		    			    nVlrTmp := aArrVlr[nDx]
    			    
		    			    If nAliTmp == 0 .Or. StrZero(nDX, 2) $ cIndAliqISS
		    			    	Loop
		    			    EndIf
	    
							nImposto := NoRound(((nAliTmp / 100) * (nVlrTmp / 100)) /100, 2)
					  		oRedZ:AdicImp(nAliTmp / 100, nVlrTmp / 100, nImposto)
	    	  			Next nDX
	   	 	EndIf

  			EndIf	 
  			                                             
    EndIf                                                  

			   
	//Prepara os parametros de envio                                                                   
	 oParams := ::PrepParam({IBM, "IBM_FI_ReducaoZ", cData, cHora})
	//Envia o comando    	
    cRetorno := ::EnviarCom(oParams)
	//Obtem o Estado da impressora
	 cRetorno := ::ObterEst(cRetorno)
	//Trata o retorno                                                  
    oRetorno := ::TratarRet(cRetorno) 
     
                                                                                 
	If( oRetorno:cAcao <> ERRO )
		 
		 //Prepara os parametros de envio
		 oParams := ::PrepParam({IBM, "IBM_FI_DadosUltimaReducaoMFD", cDados4})
		 
		 //Envia o comando    	
	    cRetorno := ::EnviarCom(oParams)
	 
		 //Obtem o Estado da impressora
		 cRetorno := ::ObterEst(cRetorno)
		 
		 //Trata o retorno                                              
	    oRetorno := ::TratarRet(cRetorno)    
    
	    If( oRetorno:cAcao <> ERRO )  
		    
		    aArrDados := strtokarr(AllTrim(oParams:Elements(3):cParametro), ",")
		    
    		 oRedZ:cNumRedZ := aArrDados[3]
			::oDadosRedZ := oRedZ
		
			//Inicializa variaveis
			::InicVar() 
			
		 EndIf
		                                                                                         
	EndIf                                       
		 
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAbrirDia  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a Abertura do dia.			  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AbrirDia()Class LJAIBM
	Local oRetorno := nil

	oRetorno := ::TratarRet("0000")
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMFData    บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a impressao da Leitura da    บฑฑ
ฑฑบ          ณMemoria Fiscal por Data.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                    	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). บฑฑ
ฑฑบ			 ณEXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).  	  บฑฑ
ฑฑบ          ณEXPC1 (3 - cTipo) - Tipo da Leitura						  บฑฑ
ฑฑบ			 ณ					  (I- impressao / A - arquivo).			  บฑฑ
ฑฑบ			 ณEXPC2 (4 - cTipoArq) - (C - completa / S - simplificada).	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf									      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)	Class LJAIBM

	Local oParams 	:= Nil	//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil	//Objeto que sera retornado pela funcao
	Local cFlag 	:=  Right(cTipoArq, 1) 	//c=completa s=simplificada      
	Local cArquivo  := ::cPathMF + "RETORNO.TXT" //Nome do arquivo origem	 
	Local cArqDes   := "" //Arquivo de Destino
	
	
	
	If Left(cTipo,1) == "A" 
	   If FindFunction("LjxGerPath")
	   	LjxGerPath( @cArqDes ) 
	   	cArqDes += "LMF" + cFlag + ".txt" 
	   EndIf
	   oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalSerialDataMFD",dtoc(dDtInicio),dtoc(dDtFim),cFlag})
	Else
	
		//Prepara os parametros de envio 
		oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalDataMFD",dtoc(dDtInicio),dtoc(dDtFim),cFlag})
	EndIf 
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)	
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)    

	
   //Trata o retorno    
   oRetorno := ::TratarRet(cRetorno)

   
   If Left(cTipo, 1) == "A" .and. !Empty(cArqDes)
   	__CopyFile(cArquivo,cArqDes)
   EndIf
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMFReducao บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a impressao da Leitura da    บฑฑ
ฑฑบ          ณMemoria Fiscal por Reducao Z.	                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cRedInicio) - Reducao Z inicial do periodo. 	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cRedFim) - Reducao Z final do periodo.			  บฑฑ
ฑฑบ          ณEXPC3 (3 - cTipo) - Tipo da Leitura						  บฑฑ
ฑฑบ			 ณ					  (I- impressao / A - arquivo).			  บฑฑ
ฑฑบ			 ณEXPC4 (4 - cTipoArq) - (C - completa / S - simplificada).	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MFReducao(cRedInicio, cRedFim, cTipo, cTipoArq)	 Class LJAIBM

	Local oParams 	:= Nil	//Objeto para passagem dos parametros
	Local cRetorno := ""		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil	//Objeto que sera retornado pela funcao 
	Local cFlag 	:=  Right(cTipoArq, 1) 	//c=completa s=simplificada      
	Local cArquivo  := ::cPathMF + "RETORNO.TXT" //Nome do arquivo origem
	Local cArqDes   := "" //Arquivo de Destino   

			
	If Left(cTipo,1) == "A"
		If FindFunction("LjxGerPath")
			LjxGerPath( @cArqDes ) 
	   		cArqDes += "LMF" + cFlag + ".txt"  
	    EndIf
		oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalSerialReducaoMFD",PadR(AllTrim(cRedInicio),4),PadR(AllTrim(cRedFim),4),cFlag})
	Else

		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_LeituraMemoriaFiscalReducaoMFD",Left(cRedInicio,4),Left(cRedFim,4),cFlag})
	EndIf
		
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora  
	cRetorno := ::ObterEst(cRetorno)    
	
   //Trata o retorno    
   	oRetorno := ::TratarRet(cRetorno)  

    If Left(cTipo, 1) == "A" .and. !Empty(cArqDes)
   		__CopyFile(cArquivo,cArqDes)
   	EndIf
	    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAutenticarบAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a autenticacao.		  	  บฑฑ
ฑฑบ          ณ								                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                   	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cTexto) - Texto a ser impresso na autenticacao.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Autenticar(cLinha, cTexto) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao     
   
    Default cLinha := space(2)
    Default cTexto := space(50)
   			 	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AutenticacaoMFD", Left(cLinha,2), Left(cTexto,50)})
				
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpCheque บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a impressao de cheque.		  บฑฑ
ฑฑบ          ณ								                              		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cBanco) - Numero do banco.						  	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cValor) - Valor do cheque.						  	  บฑฑ
ฑฑบ			 ณEXPC3 (3 - cData) - Data do cheque (ddmmaaaa).		 	  	  บฑฑ
ฑฑบ			 ณEXPC4 (4 - cFavorecid) - Nome do favorecido.			   	  บฑฑ
ฑฑบ			 ณEXPC5 (5 - cCidade) - Cidade a ser impressa no cheque.  	  บฑฑ
ฑฑบ			 ณEXPC6 (6 - cTexto) - Texto adicional impresso no cheque.    บฑฑ
ฑฑบ			 ณEXPC7 (7 - cExtenso) - Valor do cheque por extenso.	 	  บฑฑ
ฑฑบ			 ณEXPC8 (8 - cMoedaS) - Moeda por extenso no singular.	  	  บฑฑ
ฑฑบ			 ณEXPC9 (9 - cMoedaP) - Moeda por extenso no plural.	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImpCheque(cBanco	, nValor, cData    , cFavorecid , ;
				 cCidade, cTexto, cExtenso , cMoedaS    , ;
				 MoedaP) Class LJAIBM
					 
		Local oParams 	:= Nil			//Objeto para passagem dos parametros
		Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
		Local oRetorno := Nil		//Objeto que sera retornado pela funcao
   		Local cValor   := ""// Valor do Cheque
   		
   		cValor := AllTrim(Str(nValor,14,2))	  
   		
   		cData := Right(cData,2) + Substr(cData,5,2) + Left(cData,4)		

    	//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_ImprimeChequeMFD"    , SubStr(cBanco,1,3)     , cValor ,;
															   SubStr(cFavorecid,1,45), SubStr(cCidade,1,27),;
															   cData , SubStr(cTexto,1,120), "0", "0"})
		//Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
	
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
	
    	//Trata o retorno    
    	oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfigPgtoบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a inclusao de uma forma de	  บฑฑ
ฑฑบ          ณpagamento.					                              	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cVincula) - Flag que indica se a forma de		  บฑฑ
ฑฑบ			 ณ		pagamento sera vinculada (S - Sim, N - Nao ).		  	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cForma) - Nome da forma de pagamento.			     บฑฑ
ฑฑบ			 ณEXPC3 (3 - cIndice) - Indice da forma de pagamento.		     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfigPgto(cForma, cOper) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
 	                                
 	DEFAULT cOper := "1"
 	                                
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ProgramaFormaPagamentoMFD", SubStr(cForma,1,16), cOper})	

	//Envia o comando    	                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a inclusao de um totalizador บฑฑ
ฑฑบ          ณnao fiscal.					                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cIndice) - Indice do totalizador		  		  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cTotaliz) - Descricao do totalizador.		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfTotNF(cIndice, cTotaliz)Class LJAIBM

	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao
 	                                
	//NOTA: O indice do totalizador sera gerado pela impressora, por este motivo, o parametro cIndice e ignorado.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_NomeiaTotalizadorNaoSujeitoIcms", cIndice, Left(cTotaliz,16)})	 	

    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfigAliqบAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a inclusao de uma aliquota.  บฑฑ
ฑฑบ          ณ								                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cAliq) - Valor da aliquota.			  		  บฑฑ
ฑฑบ			 ณEXPN1 (2 - nTipoIss) - Flag que indica se a aliquota sera   บฑฑ
ฑฑบ			 ณ		referente a ISS (1 - Sim, 0 - Nao(ICMS) ).	 	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf									      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                             
Method ConfigAliq(nAliq, cTipoIss) Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
	Local cAliq		:= ""			//Valor da aliquota
	
	cAliq := StrZero(nAliq*100 , 4,0)
	 	                                
 	If(cTipoIss == "S")                                                
 		cVinc := "1"
 	Else         
	 	cVinc := "0"
	EndIf
 	
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ProgramaAliquota", SubStr(cAliq,1,4), cVinc})
 
   //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfVerao บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a entrada / saida do horario บฑฑ
ฑฑบ          ณde verao.						                              	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cTipo) - Tipo da configuracao.			  		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConfVerao(cTipo)Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
 	                                
	//NOTA: Caso seja possivel, a entrada ou saida de intervencao sera feita sem a necessidade do envio de parametro.
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_ProgramaHorarioVerao"})	 	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a inclusao de um relatorio   บฑฑ
ฑฑบ          ณgerencial.					                              	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cIndice) - Indice do totalizador		  		  	  บฑฑ
ฑฑบ			 ณEXPC2 (2 - cRelGer) - Descricao do relatorio gerencial.  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                       
Method ConfRelGer(cIndice, cRelGer)Class LJAIBM

	Local oParams 		:= Nil		//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil		//Objeto que sera retornado pela funcao 

 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_NomeiaRelatorioGerencialMFD", cIndice, cRelGer})	 	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAbrirGavetบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a abertura da gaveta.   	  บฑฑ
ฑฑบ          ณ					                              			  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum.													  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method AbrirGavet()Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   			
 	                                
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_AcionaGaveta"})	 	
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
	                                                             
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o fabricante da impressora. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf contendo o nome do fabricante		  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetFabric()Class LJAIBM

	Local oRet 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRet := ::TratarRet("0000")
    
    oRet:oRetorno := ::cFabric	//Copia o valor da propriedade da classe
    
Return oRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o modelo da impressora.	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf contendo o nome do fabricante		  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetModelo()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cModelo	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a versao do firmware		  บฑฑ
ฑฑบ          ณda impressora.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetVerFirm()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cFirmWare	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o C.N.P.J. do usuario cadas-บฑฑ
ฑฑบ          ณtrado no ECF.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCNPJ()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cCnpj	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a inscicao estadual do 	  บฑฑ
ฑฑบ          ณusuario cadastrado no ECF.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetInsEst()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cIE	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a inscicao municipal do 	  บฑฑ
ฑฑบ          ณusuario cadastrado no ECF.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetInsMun()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cIM	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero da loja cadastrado บฑฑ
ฑฑบ          ณno ECF.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumLj()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cLoja	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o nome do operador  		  บฑฑ
ฑฑบ          ณcadastrado no ECF.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetOper()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cOperador	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a razao social cadastrada	  บฑฑ
ฑฑบ          ณno ECF.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetRzSoc()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cRazaoSoc	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o nome fantasia cadastrado  บฑฑ
ฑฑบ          ณno ECF.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetFantas()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cFantasia	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o nome endereco 1 cadastra- บฑฑ
ฑฑบ          ณdo no ECF.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetEnd1()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cEndereco1	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o nome endereco 2 cadastra- บฑฑ
ฑฑบ          ณdo no ECF.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetEnd2()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cEndereco2	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetDadRedZบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar os dados capturados na  	  บฑฑ
ฑฑบ          ณexecucao do ultimo comando de ReducaoZ                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDadRedZ() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oDadosRedZ	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetMFTXT  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar um flag indicando se sera	  บฑฑ
ฑฑบ          ณpossivel gerar um arquivo a partir da leitura da MF.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetMFTXT() Class LJAIBM
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetMFSerialบAutor  ณVendas Clientes     บ Data ณ  20/06/11 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar um flag indicando se sera	  บฑฑ
ฑฑบ          ณpossivel gerar a leitura da MF serial.			          	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetMFSerial() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetHrVeraoบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o flag que indica horario deบฑฑ
ฑฑบ          ณverao no ECF.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetHrVerao() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(1)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_FlagsFiscais", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro == "4"
	EndIf
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetAliq   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a tabela de aliquotas cadas-บฑฑ
ฑฑบ          ณtradas no ECF.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetAliq() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oAliquotas	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a tabela de formas de paga- บฑฑ
ฑฑบ          ณmento cadastradas no ECF.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetFormas()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oFormas	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a tabela de totalizadores	  บฑฑ
ฑฑบ          ณnao fiscais cadastrados no ECF.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                  
Method GetTotNF()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oTotsNF	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a tabela de relatorios 	  บฑฑ
ฑฑบ          ณgerenciais cadastrados no ECF.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetRelGer()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::oGerencial	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero de serie do ECF.	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNrSerie()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cNrSerie	//Copia o valor da propriedade da classe
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero do ultimo COO.	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumCup()Class LJAIBM   

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCupom", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 6)
	EndIf
    
Return oRetorno
                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero do ECF.	 	 	  	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumEcf()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ::cNumEcf	//Copia o valor da propriedade da classe

Return oRetorno                                                                    
                                                                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNumItemบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero do ultimo item 	  บฑฑ
ฑฑบ          ณvendido pelo ECF.                                           บฑฑ
ฑฑบ          ณDesconsiderar os itens cancelados.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumItem()Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera a numero do item
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_UltimoItemVendido", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		//oRetorno:oRetorno := oParams:Elements(3):cParametro
		cRetorno := AllTrim(oParams:Elements(3):cParametro)
	EndIf

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetSubTot บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o valor do subtotal do cupomบฑฑ
ฑฑบ          ณfiscal.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetSubTot()Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(14)	//String que recebera subtotal do cupom
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_SubTotal", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := (Val(oParams:Elements(3):cParametro) / 100)
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a data e hora atual do ECF. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf contendo a data e hora atual do ECF    บฑฑ
ฑฑบ			 ณno formato dd/mm/aaaa hh:mm:SS (19 bytes)					  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDatHora()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cData  	:= Space(6)		//String que recebera a data do cupom
	Local cHora  	:= Space(6)		//String que recebera a hora do cupom
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraImpressora", cData, cHora})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)                         
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno                                     
    oRetorno := ::TratarRet(cRetorno)

    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

		oRetorno:oRetorno :=	Substr(AllTrim(oParams:Elements(3):cParametro),1,2)  + "/" +;
								Substr(Alltrim(oParams:Elements(3):cParametro),3,2)  + "/" +;
							  	"20"+Substr(AllTrim(oParams:Elements(3):cParametro),5,2)  + " " +;
							  	Substr(Alltrim(oParams:Elements(4):cParametro),1,2)  + ":" +;
							  	Substr(Alltrim(oParams:Elements(4):cParametro),3,2) + ":" +;
							  	Substr(Alltrim(oParams:Elements(4):cParametro),5,2)

	EndIf
	
Return oRetorno                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar se o ecf permite desconto   บฑฑ
ฑฑบ          ณsobre o item vendido.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDesItem()Class LJAIBM
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por verificar se a impressora e fiscal.  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetImpFisc()Class LJAIBM
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .T.

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se a impressora trunca ou arredonda.    บฑฑ
ฑฑบ          ณT - trunca / A - Arredonda                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetTrunAre()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := "T"
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se a impressora necessita do valor do   บฑฑ
ฑฑบ          ณCheque por extenso.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetChqExt()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := .F.
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a Venda Bruta atual do ECF. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetVdBruta()Class LJAIBM
	Local oRetorno 	:= ::LeVndBrut()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o Grand Total atual do ECF. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetGranTot()Class LJAIBM
	Local oRetorno 	:= ::LeGT()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de descontos do ECF.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetTotDesc()Class LJAIBM
	Local oRetorno 	:= ::LeTotDesc()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de descontos de ISS บฑฑ
ฑฑบ          ณdo ECF.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDescIss()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			   //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[11]) / 100 //ISSQN 

	EndIf
		
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de acrescimos do ECFบฑฑ
ฑฑบ          ณ                                                     		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetTotAcre()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			   //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[09]) / 100 + ; //ICMS 
								Val(aDados[12]) / 100  	  //ISSQN 

	EndIf

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de acrescimos em ISSบฑฑ
ฑฑบ          ณdo ECF.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetAcreIss()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno := Val(aDados[12]) / 100  //ISSQN 

	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de cancelamentos do บฑฑ
ฑฑบ          ณECF.                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetTotCanc()Class LJAIBM
	Local oRetorno 	:= ::LeTotCanc()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de cancelamentos de บฑฑ
ฑฑบ          ณISS no ECF.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCancIss()Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais cancelados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno := Val(aDados[13]) / 100 //ISSQN 

	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de Isentos do ECF.  บฑฑ
ฑฑบ          ณ		 													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetIsentos()Class LJAIBM
	Local oRetorno 	:= ::LeTotIsent()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de nao tributados   บฑฑ
ฑฑบ          ณdo ECF.                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNaoTrib()Class LJAIBM
	Local oRetorno 	:= ::LeTotNTrib()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetSubstitบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de substituicoes    บฑฑ
ฑฑบ          ณtributarias do ECF.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetSubstit() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que receber a tabela de aliquotas cadastradas no ECF

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
      If(oRetorno:cAcao <> ERRO)    	
		
			aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
			oRetorno:oRetorno := Val(aDados[04]) / 100 + ;//Substituicao tributแria de ICMS
			   					 Val(aDados[07]) / 100    //Substituicao tributแria de ISSQN 

		EndIf

	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero da ultima reducao  บฑฑ
ฑฑบ          ณZ executada pelo ECF.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumRedZ()Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroReducoes", cDados})
	                                            
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero de cupons 		  	  บฑฑ
ฑฑบ          ณcancelados pelo ECF.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCancela() Class LJAIBM
	
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera os contadores da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCuponsCancelados", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(3):cParametro
	EndIf
	
Return oRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetInterveบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o numero de intervencoes	  บฑฑ
ฑฑบ          ณexecutadas no ECF.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetInterve() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(4)	//String que recebera os contadores da impressora

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroIntervencoes", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := AllTrim(oParams:Elements(3):cParametro)
	EndIf

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a data da ultima reducao  Z บฑฑ
ฑฑบ          ณexecutada pelo ECF.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDtUltRe()Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    If(::oDadosRedZ <> Nil)
    	oRetorno:oRetorno := ::oDadosRedZ:dDataMov	//Copia o valor da propriedade da classe
    EndIf
    
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar o total de ISS vendido pelo บฑฑ
ฑฑบ          ณECF.                                         				  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetTotIss()Class LJAIBM
	Local oRetorno 	:= ::LeTotIss()
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetDataMovบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar a data de abertura do movi- บฑฑ
ฑฑบ          ณmento atual do ECF.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDataMov()Class LJAIBM
	
	Local oRetorno 	:= ::LeDataJor()	

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar os flags fiscais do ECF.	  บฑฑ
ฑฑบ          ณ                                         				  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetFlagsFi()Class LJAIBM
    
   Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""			   //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados1	:= Space(1)		//String que recebera o retorno da funcao 
	Local cDados2	:= Space(1)		//String que recebera o retorno da funcao 
    
   Local cAckFlag := Space(1)		//String que recebera o retorno da funcao 
   Local cST1Flag := Space(1)		//String que recebera o retorno da funcao 
   Local cST2Flag := Space(1)		//String que recebera o retorno da funcao 
   Local cST3Flag := Space(1)		//String que recebera o retorno da funcao     
   Local cStatus  := Space(1)		//String que recebera o retorno da funcao     
   Local cStatus1 := Space(1)		//String que recebera o retorno da funcao
   
    
   Local cDataMov := Space(6)		//String que recebera o retorno da funcao  
   Local cData  	:= Space(6)		//String que recebera o retorno da funcao  
   Local cHora  	:= Space(6)		//String que recebera o retorno da funcao            

	Local nRes1 	:= 0
	Local nRes2 	:= 0
	Local nRes3 	:= 0 
	Local nRes4 	:= 0 	
	Local nRes5 	:= 0 
	Local nRes6 	:= 0
	Local cDataImp := Nil
    Local nRedPend  := 0 		//Verifica o status da reducao Z Pendente
    
		::oFlagsFisc:lEcfOff    := .F.  
   	::oFlagsFisc:lCFAberto  := .F.                              
  		::oFlagsFisc:lCFItem    := .F. 
		::oFlagsFisc:lCFPagto   := .F. 
		::oFlagsFisc:lCFTot     := .F. 
		::oFlagsFisc:lCVAberto  := .F.  
		::oFlagsFisc:lFimPapel  := .F.   
		::oFlagsFisc:lNFAberto  := .F. 
		::oFlagsFisc:lPapelAcab := .F.                                             
		::oFlagsFisc:lRGAberto  := .F. 
		::oFlagsFisc:lTampAbert := .F. 
				
		/***************************************************************************/
		//TRATO O RETORNO ST1 e ST3
		//*ST1 - verifico se esta sem papel
		//*ST1 - verifico se ha pouco papel
		//*ST1 - verifico se tampa superior esta aberta (impressora com erro)
		//*ST1 - verifico se o cupom fiscal esta aberto
		//*ST3 - verifico se impressora esta off-line (retorno 13)
		//*ST3 - verifico tem reducao z pendente (retorno 66)
		//*Verifico se tem cupom fiscal Aberto
		/***************************************************************************/
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_VerificaEstadoImpressora", cAckFlag, cST1Flag, cST2Flag, cST3Flag })
		
	   //Envia o comando
	   cRetorno := ::EnviarCom(oParams)
	    	
		  	//Retorno do ST1                                    
			nRes3 := val(oParams:Elements(4):cParametro) 
			//Retorno do ST2
			nRes4 := val(oParams:Elements(5):cParametro)  
			//Retorno do ST3
			nRes6 := val(oParams:Elements(6):cParametro)
		
		
			/***************************************************************************/
			//TRATO RETORNO DO ST1
			/***************************************************************************/	
			If (nRes3 >= 128)
				//Sem papel
				::oFlagsFisc:lFimPapel := .T. 
	   		nRes3 := nRes3 - 128
			EndIF
			
			IF (nRes3 >= 64)
	         //Pouco papel
				::oFlagsFisc:lPapelAcab := .T.  
	   		nRes3 := nRes3 - 64  
	   	EndIF
	   	
	   	IF (nRes3 >= 32)
	           //Erro no relogio 
	           nRes3 := nRes3 - 32 
		  	EndIF
		  	
		  	IF (nRes3 >= 16)
		  	
	         //Impressora em erro (Retorno da funcao)
				//Tampa superior aberta (Nao ha funcao especifica IBM para esta verificacao)
				::oFlagsFisc:lTampAbert := .T.
	          nRes3 := nRes3 - 16 
	          
	   	EndIF
	   	
	   	IF (nRes3 >= 8)
        		//Primeiro dado de cmd nao foi ESC
            nRes3 := nRes3 - 8
		  	EndIF
		  	
		  	IF (nRes3 >= 4)
	    		//Comando Inexistente
	          nRes3 := nRes3 - 4
		  	EndIF
		  	
		  	IF (nRes3 >= 2)
				//Cupom Fiscal aberto
	   		::oFlagsFisc:lCFAberto := .T. 
	          nRes3 := nRes3 - 2  
		  	EndIF
		  	
		  	IF (nRes3 >= 1)
	      	//Numero de parametro CMD Invalido
	     	EndIf   
		

		/***************************************************************************/
		//TRATO O RETORNO DO ST3
		/***************************************************************************/
		If nRes6 == 13
			//Impressora Online 
			::oFlagsFisc:lEcfOff := .T.
		EndIf

		If nRes6 == 66
			::oFlagsFisc:lInicioDia := .T.
			::oFlagsFisc:lDiaFechad := .F.                            
			::oFlagsFisc:lRedZPend  := .T.
		Else
		
			//Tratamento de bug do modelo SJ6
			//Enviar comando de verifica็ใo de redu็ใo z Pendente		
			//Prepara os parametros de envio
			oParams := ::PrepParam({IBM, "IBM_FI_VerificaZPendente", Str(nRedPend) })
		
	   		//Envia o comando
	   		cRetorno := ::EnviarCom(oParams)
	   		
	   		nRedPend := val(oParams:Elements(3):cParametro) 
	   		
	   		If nRedPend == 1
				::oFlagsFisc:lInicioDia := .T.
				::oFlagsFisc:lDiaFechad := .F.                            
				::oFlagsFisc:lRedZPend  := .T.
	   		EndIf 
	   		
		EndIf		
		
			                                                  
	/***************************************************************************/
	//TRATO O RETORNO DAS FLAGS FISCAIS
	//*Verifico se ouve reducao Z
	//*Verifico se tem cupom fiscal Aberto
	/***************************************************************************/
		
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FlagsFiscais", cDados1})          
	
    //Envia o comando
    cRetorno := ::EnviarCom(oParams)
    
	//Erro de comunicacao, ou seja impressora esta offline, excessao para verificar em outros modulos
    If(val(cRetorno)==0)
    	::oFlagsFisc:lEcfOff := .T.
    EndIf  
    	
  		nRes1 := val(oParams:Elements(3):cParametro)

		If (nRes1 >= 128)
         //Mem๓ria fiscal sem espa็o
          nRes1 := nRes1 - 128
		EndIF
		
		IF (nRes1 >= 64)
        	//Nใo utilizado 
         nRes1 := nRes1 - 64  
   	EndIF
   	
   	IF (nRes1 >= 32)
        	//Permite cancelar cupom fiscal 
         nRes1 := nRes1 - 32 
	  	EndIF
	  	
	  	IF (nRes1 >= 16)
        	//Nใo utilizado 
         nRes1 := nRes1 - 16 
   	EndIF

   	IF (nRes1 >= 8)
        	//Jแ houve redu็ใo Z no dia 
         ::oFlagsFisc:lInicioDia := .T.
         ::oFlagsFisc:lDiaFechad := .T.
         ::oFlagsFisc:lRedZPend  := .F.
         nRes1 := nRes1 - 8
      EndIF
	   
	   IF (nRes1 >= 4)
        	//Horแrio de verใo selecionado 
   		nRes1 := nRes1 - 4
      EndIF
	   
	   IF (nRes1 >= 2)
        	//Fechamento de formas de pagamento iniciado
         nRes1 := nRes1 - 2  
      EndIF
	   
	   IF (nRes1 >= 1)
        //Cupom fiscal aberto
         ::oFlagsFisc:lCFAberto := .T.  
		 EndIf   

		/***************************************************************************/
		//TRATO O ESTADO DA GAVETA
		/***************************************************************************/   
		
	    //Prepara os parametros de envio
		 oParams := ::PrepParam({IBM, "IBM_FI_VerificaEstadoGaveta", cDados2})
		
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    	
	 	nRes2 := val(oParams:Elements(3):cParametro) 
			
			If nRes2 == 0  
				//Estado da gaveta - Aberta        
				::oFlagsFisc:lGavAberta := .T.
			Else
				//Estado da gaveta - Fechada                              
				::oFlagsFisc:lGavAberta := .F.
			EndIF

	
		/***************************************************************************/
		//TRATO RETORNO ESTENDIDO            
		/*verifico se relatorio gerencial esta aberto
		/*verifico se comprovante de credito ou debito esta aberto
		/*verifico se comprovante NAO fiscal esta aberto
		/***************************************************************************/
		//Prepara os parametros de envio
		oParams := ::PrepParam({IBM, "IBM_FI_StatusEstendidoMFD", cStatus })
		
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    	
			//Retorno do ST1
			nRes5 := val(oParams:Elements(3):cParametro) 
		
		
			If (nRes5 >= 128)
				 nRes5 := nRes5 - 128
			EndIF
			
			IF (nRes5 >= 64)
	      	//Estorno de Comprovante de D้bito ou Cr้dito permitido
				nRes5 := nRes5 - 64  
	   	EndIF
	   	
	   	IF (nRes5 >= 32)
	      	//Permite cancelamento do CNF 
	          nRes5 := nRes5 - 32 
			EndIF
			
		  	IF (nRes5 >= 16)
	          nRes5 := nRes5 - 16 
	   	EndIF
	   	
	   	IF (nRes5 >= 8)
	        	//Totalizando Cupom
         	nRes5 := nRes5 - 8
   	  	EndIF
   	  	
   	  	IF (nRes5 >= 4)
	        //Relat๓rio Gerencial Aberto 
				::oFlagsFisc:lRGAberto := .T.       
	          nRes53 := nRes5 - 4
		  	EndIF
		  	
		  	IF (nRes5 >= 2)
				//Comprovante de D้bito ou Cr้dito Aberto
				::oFlagsFisc:lCVAberto := .T. 
	   		nRes5 := nRes5 - 2  
		  	EndIF
		  	
		  	IF (nRes5 >= 1)
	      	//Comprovante Nใo-Fiscal Aberto
				::oFlagsFisc:lNFAberto := .T.
	      EndIf   
		
		/***************************************************************************/
		//TRATO RETORNO DA INTERVENCAO TECNICA
		/***************************************************************************/  
		
 		 //Prepara os parametros de envio
		 oParams := ::PrepParam({IBM, "IBM_FI_VerificaModoOperacao", cStatus1 })
		
	    //Envia o comando
	    cRetorno := ::EnviarCom(oParams)
	    	
	                                      
    		//Retorno do ST1
			nRes6 := val(oParams:Elements(3):cParametro) 
			
			If nRes6 == 0
				//Esta em intervencao tecnica
				::oFlagsFisc:lIntervenc := .T.
			Else
				//Esta em modo normal
				::oFlagsFisc:lIntervenc := .F.
			EndIf
			
		 /***************************************************************************/
		//TRATO RETORNO PARA VERIFICAR SE O DIA Jม FOI INICIADO
		/***************************************************************************/
   		//Prepara os parametros de envio
			oParams := ::PrepParam({IBM, "IBM_FI_DataMovimento", cDataMov })
		
	    	//Envia o comando
	    	cRetorno := ::EnviarCom(oParams)
	    	
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
	
			//Trata o retorno    
			oRetorno := ::TratarRet(cRetorno)
	
	   		 
    	   	cDataRet := AllTrim(oParams:Elements(3):cParametro)
			
				//Prepara os parametros de envio
				oParams := ::PrepParam({IBM, "IBM_FI_DataHoraImpressora",  cData, cHora })
		
			    //Envia o comando
	    		cRetorno := ::EnviarCom(oParams)
	    	
				cDataImp := AllTrim(oParams:Elements(3):cParametro)

			//Se a data de movimento for igual a data da impressora, o dia foi iniciado			
			If cDataRet == cDataImp

				::oFlagsFisc:lInicioDia := .T.
				::oFlagsFisc:lDiaFechad := .F.
				::oFlagsFisc:lRedZPend  := .F.

			Else
		
				::oFlagsFisc:lInicioDia := .F.
				::oFlagsFisc:lDiaFechad := .F.
				

				If  Val(cDataRet) > 0 .and. CtoD(Left(cDataRet,2) + "/" + SubsTr(cDataRet,3,2) + "/" + Right(cDataRet,2)) < CtoD(Left(cDataImp,2) + "/" + SubsTr(cDataImp,3,2) + "/" + Right(cDataImp,2))
					::oFlagsFisc:lRedZPend  := .T.  //Se a data do movimento for inferior เ data do dia, redu็ใo z pendente
				Else
					::oFlagsFisc:lRedZPend  := .F.
                EndIf

			EndIf                                                 
			
		oRetorno:oRetorno := ::oFlagsFisc	//Copia o valor da propriedade da classe
                	    	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscInfEcf() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao       
	
	//Habilito o uso do retorno estendido ST3
   	//Prepara os parametros de envio                                                    
	oParams := ::PrepParam({IBM, "IBM_FI_HabilitaDesabilitaRetornoEstendidoMFD", "1"})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
 	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)   
    
    If(oRetorno:cAcao <> ERRO) 
	    oRetorno:= ::LeDadoUsu()
	 EndIF
	      
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeDadImp()	                  
	 EndIF
		 
	If(oRetorno:cAcao <> ERRO) 
		 	oRetorno:= ::LeCliche()   
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeOperador()  
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeECFLoja()                                           
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeAliq()      
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
	 	 oRetorno:= ::LeTotNF()     
 	 EndIF
 	 
 	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeRelGer()    
	 EndIF
	 
	 If(oRetorno:cAcao <> ERRO) 
		 oRetorno:= ::LeFinaliz()    
	 EndIF
	
	::oFlagsFisc:lCFItem  := .F. 
	::oFlagsFisc:lCFPagto := .F. 
	::oFlagsFisc:lCFTot   := .F.   
	oRetorno:oRetorno := ::oFlagsFisc
	
Return oRetorno

//******************************************************************//
//						Metodos internos										    //                 
//******************************************************************//                                                                     
Method ObterEst(cRetorno) Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local oRetorno	:= Nil			//Objeto que sera retornado pela funcao	
	//(06h ou 6d) NAK=(15h ou 21d)
	Local cEstado  := "1"   
	Local cMsg	   := space(200)
	Local cCodErr  := space(3) 

	//SE FOR RETORNO ESTENDIDO	                
	If	(val(cRetorno) == -27 .or. val(cRetorno) == 0) //Erro de Comunica็ใo	                                        
			
		//Prepara os parametros de envio


		//Trata outo estado da impressora 
		oParams := ::PrepParam({IBM, "IBM_FI_RetornoImpressoraPadraoIBM", cCodErr,  cMsg}) 
			
		cRetorno := ::EnviarCom(oParams)		  

		oRetorno := ::TratarRet(cRetorno)    
			 
		cCodErr :=  AllTrim(::CorrigRet(oParams:Elements(3):cParametro))
			    	
    	If ( oRetorno:cAcao <> ERRO ) 
    	       
    	   If !Empty( cCodErr)
    	   
    	   		cEstado := "IBM-" +  cCodErr
    	   Else
    	   		cEstado := "-99" //ST1=0;ST2=0;ST3=0 Executou com sucesso	
    	   
    	   EndIf    
    	   
    	EndIf   

	
   Else
       
    	cEstado := cRetorno
    
   EndIF	                                            

Return cEstado  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pelo carregamento das mensagens de    	  บฑฑ
ฑฑบ          ณresposta possiveis da impressora.			  		  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                   	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum												      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณnenhum													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CarregMsg() Class LJAIBM
	
	//FUNCOES
	::AdicMsgECF("0000", "Resultado sem erro", OK)     
	::AdicMsgECF("0521", "Alํquota nใo cadastrada no sistema.", ERRO)     
	::AdicMsgECF("-997", "Forma de Pagamento Cadastrada", OK)     
	::AdicMsgECF("-998", "Forma de Pagamento nใo Cadastrada", ERRO)   
	::AdicMsgECF("0066", "Nใo disponํvel op็ใo em Disco", ERRO)  
	::AdicMsgECF("999", "Fun็ใo nใo disponํvel para este modelo de ECF", ERRO)  
	  
	
	//RETORNO PADRAO
	::AdicMsgECF("0", "Erro de comunica็ใo.", ERRO)
	::AdicMsgECF("1", "Comando OK", OK)
	::AdicMsgECF("-2", "Parโmetro invแlido na fun็ใo.", ERRO)
	::AdicMsgECF("-3", "Alํquota nใo programada.", ERRO)
	::AdicMsgECF("-4", "O arquivo de inicializa็ใo BemaFI32.ini nใo foi encontrado no diret๓rio de sistema do Windows.", ERRO)
	::AdicMsgECF("-5", "Erro ao abrir a porta de comunica็ใo.", ERRO)
	::AdicMsgECF("-7", "Banco nใo localizado no arquivo de configura็ใo BemaFi32.ini.", ERRO)
	::AdicMsgECF("-8", "Erro ao criar ou gravar no arquivo STATUS.TXT ou RETORNO.TXT.", ERRO)    
	::AdicMsgECF("-9", "Time-out na leitura do cheque.", ERRO)
	::AdicMsgECF("-27", "Status da impressora diferente de 6,0,0,0 (ACK, ST1, ST2 e ST3)", ERRO)
	::AdicMsgECF("-99", "Erro ao tratar retorno.", ERRO) 
	
	//RETORNO FUNCAO IBM
	::AdicMsgECF("IBM-1", "Overflow inesperado.", ERRO)
	::AdicMsgECF("IBM-2", "Overflow inesperado.", ERRO)
	::AdicMsgECF("IBM-22", "Pagamento nao permitido.", ERRO)
	::AdicMsgECF("IBM-23", "Operacao Nao Fiscal nao permitida.", ERRO)
	::AdicMsgECF("IBM-24", "Total = 0 nao permitido.", ERRO)
	::AdicMsgECF("IBM-29", "Pagamento nao finalizado.", ERRO)
	::AdicMsgECF("IBM-30", "Operacao nao permitida.", ERRO)
	::AdicMsgECF("IBM-31", "Operacao CDC nao permitida.", ERRO)
	::AdicMsgECF("IBM-32", "Retorno de Pagamento NF nao permitido.", ERRO)
	::AdicMsgECF("IBM-33", "Cupom Adicional nao permitido.", ERRO)
	::AdicMsgECF("IBM-37", "Alcancado numero maximo de relatorio de MFD em intervencao tecnica.", ERRO)
	::AdicMsgECF("IBM-38", "Numero Max de itens atingido.", ERRO)
	::AdicMsgECF("IBM-42", "Aliquota nao permitida.", ERRO)
	::AdicMsgECF("IBM-44", "Categoria de Aliquota desabilitada.", ERRO)
	::AdicMsgECF("IBM-53", "Data/Hora invalida.", ERRO)
	::AdicMsgECF("IBM-54", "Cancelamento da ultima transacao nao permitido.", ERRO)
	::AdicMsgECF("IBM-55", "Tamanho de comando muito pequeno ou invalido.", ERRO)
	::AdicMsgECF("IBM-56", "Overflow diแrio.", ERRO)
	::AdicMsgECF("IBM-59", "Valor da transa็ใo muito pequeno.", ERRO)
	::AdicMsgECF("IBM-60", "Estouro do contador de Transacao.", ERRO)
	::AdicMsgECF("IBM-61", "Estouro do Contador Diario.", ERRO)
	::AdicMsgECF("IBM-62", "Necessario emitir Reducao Z.", ERRO)
	::AdicMsgECF("IBM-63", "Contribuinte nใo cadastrado.", ERRO)
	::AdicMsgECF("IBM-64", "Estouro de transa็ใo.", ERRO)
	::AdicMsgECF("IBM-65", "Comando invalido.", ERRO)
	::AdicMsgECF("IBM-66", "Extensao de comando invalido", ERRO)
	::AdicMsgECF("IBM-67", "Comando OK.", ERRO)
	::AdicMsgECF("IBM-68", "Numero ECF nao programado.", ERRO)
	::AdicMsgECF("IBM-69", "Atingido numero maximo de Linhas de Impressao.", ERRO)
	::AdicMsgECF("IBM-70", "Codificacao do GT nao programada.", ERRO)
	::AdicMsgECF("IBM-71", "Impressao de linhas nao permitida.", ERRO)
	::AdicMsgECF("IBM-72", "Impressao de Codigo de Barras nao permitida.", ERRO)
	::AdicMsgECF("IBM-77", "Grafico corrompido.", ERRO)
	::AdicMsgECF("IBM-78", "Grafico com mesmo numero ja carregado na flash.", ERRO)
	::AdicMsgECF("IBM-79", "Sequencia invalida no download grafico.", ERRO)
	::AdicMsgECF("IBM-80", "Logo nao abaixado.", ERRO)
	::AdicMsgECF("IBM-82", "Comprovante Nao Fiscal nao aberto.", ERRO)
	::AdicMsgECF("IBM-84", "Erro MFD/Pegue o erro extendido para apurar o erro.", ERRO)
	::AdicMsgECF("IBM-86", "Senha Invalida.", ERRO)
	::AdicMsgECF("IBM-88", "Operacao invalida de habilitar/desabilitar porta de comunicacao.", ERRO)
	::AdicMsgECF("IBM-89", "Memoria Fiscal Cheia - Favor substituir.", ERRO)
	::AdicMsgECF("IBM-90", "CRZ nao encontrado.", ERRO)
	::AdicMsgECF("IBM-96", "Dados invalidos - Caracteres nao permitidos.", ERRO)
	::AdicMsgECF("IBM-98", "Modo de interven็ใo tecnica nao necessario.", ERRO)
	::AdicMsgECF("IBM-99", "Memoria Fiscal Cheia - Favor usar dados da ultima MF.", ERRO)
	::AdicMsgECF("IBM-100", "Erro leitura MF.", ERRO)
	::AdicMsgECF("IBM-101", "Erro escrita MF.", ERRO)
	::AdicMsgECF("IBM-103", "Dados fora do intervalo permitido.", ERRO)
	::AdicMsgECF("IBM-104", "Dados de c๓digo de barras deve ser terminados por NULL.", ERRO)
	::AdicMsgECF("IBM-105", "C๓digo de barras/tamanho do grแfico invแlido.", ERRO)
	::AdicMsgECF("IBM-107", "Comprovante CDC nao aberto.", ERRO)
	::AdicMsgECF("IBM-108", "Comprovante CDC aberto.", ERRO)
	::AdicMsgECF("IBM-109", "Memoria Fiscal desconectada.", ERRO)
	::AdicMsgECF("IBM-111", "Programacao Horario Verao invalida.", ERRO)
	::AdicMsgECF("IBM-112", "Reinicio da impressora fiscal.", ERRO)
	::AdicMsgECF("IBM-113", "Erro fatal na impressora.", ERRO)
	::AdicMsgECF("IBM-114", "Erro de comunicao com impressora fiscal.", ERRO)
	::AdicMsgECF("IBM-116", "Movimento nao pode ser aberto.", ERRO)
	::AdicMsgECF("IBM-118", "Parametro de Relatorio / Indice Nao Fiscal / Pagamento invalido.", ERRO)
	::AdicMsgECF("IBM-119", "Dados invalidos - valor nao permitido.", ERRO)
	::AdicMsgECF("IBM-120", "Tempo limite excedido.", ERRO)
	::AdicMsgECF("IBM-124", "Faltam informacoes do cheque.", ERRO)
	::AdicMsgECF("IBM-125", "Nao ha Relatorio Gerencial aberto.", ERRO)
	::AdicMsgECF("IBM-126", "Relatorio Gerencial aberto.", ERRO)
	::AdicMsgECF("IBM-127", "MFD ja inicializada.", ERRO)
	::AdicMsgECF("IBM-128", "Memoria Fiscal nao serializada.", ERRO)
	::AdicMsgECF("IBM-129", "MFD nao inicializada.", ERRO)
	::AdicMsgECF("IBM-130", "Autenticacao nao permitida.", ERRO)
	::AdicMsgECF("IBM-134", "ECF nao esta pronto.", ERRO)
	::AdicMsgECF("IBM-140", "Cupom Fiscal nao aberto.", ERRO)
	::AdicMsgECF("IBM-141", "Fora do modo de pagamento.", ERRO)
	::AdicMsgECF("IBM-142", "Cupom Fiscal/Nao Fiscal nao pode ser cancelado.", ERRO)
	::AdicMsgECF("IBM-145", "Necessแrio Modo de Interven็ใo T้cnica.", ERRO)
	::AdicMsgECF("IBM-146", "Inicio de Interven็ใo Tecnica em curso.", ERRO)
	::AdicMsgECF("IBM-158", "Data e hora nao programadas.", ERRO)
	::AdicMsgECF("IBM-167", "Comando nao aceito com Dia Aberto.", ERRO)
	::AdicMsgECF("IBM-172", "Cupom Fiscal Aberto.", ERRO)
	::AdicMsgECF("IBM-184", "Comprovante Nao Fiscal Aberto.", ERRO)
	::AdicMsgECF("IBM-186", "Nao ha Estorno do meio de pagamento aberto.", ERRO)
	::AdicMsgECF("IBM-187", "Estorno do meio de pagamento aberto.", ERRO)
	::AdicMsgECF("IBM-188", "Impressao de cheque nao esta sendo realizada.", ERRO)
	::AdicMsgECF("IBM-189", "Impressao de cheque esta sendo realizada.", ERRO)
	::AdicMsgECF("IBM-192", "Erro de placa l๓gica da impressora.", ERRO)
	::AdicMsgECF("IBM-194", "Erro de posicionamento da cabeca de impressao.", ERRO)
	::AdicMsgECF("IBM-200", "Tampa aberta ou sem papel.", ERRO)
	::AdicMsgECF("IBM-203", "Tampa da estacao de cheque aberta.", ERRO)
	::AdicMsgECF("IBM-204", "Erro interno impressora.", ERRO)
	::AdicMsgECF("IBM-205", "Botao do ECF pressionado.", ERRO)
	::AdicMsgECF("IBM-207", "Problema na geracao do PDF417.", ERRO)
	::AdicMsgECF("IBM-208", "Download Logo/grafico/conjunto de caracteres esta corrompido.", ERRO)
	::AdicMsgECF("IBM-210", "Alavanca automatica esta aberta.", ERRO)
	::AdicMsgECF("IBM-214", "Erro ao avan็ar papel.", ERRO)
	::AdicMsgECF("IBM-235", "Erro na carga da EPROM.", ERRO)       

	
	//RETORNO ST1
	::AdicMsgECF("ST1-128", "Fim de papel.", ERRO)
	::AdicMsgECF("ST1-64", "Pouco papel.", ALERTA)                                        
	::AdicMsgECF("ST1-32", "Erro no rel๓gio.", ERRO)
	::AdicMsgECF("ST1-16", "Impressora sem erro.", OK)
	::AdicMsgECF("ST1-8", "Primeiro dado de cmd nใo foi esc(1bh).", ERRO)
	::AdicMsgECF("ST1-4", "Comando inexistente.", ERRO)
	::AdicMsgECF("ST1-2", "Cupom fiscal aberto.", ERRO)
	::AdicMsgECF("ST1-1", "Numero de parโmetro de cmd invalido.", ERRO)
	
	//RETORNO ST2
	::AdicMsgECF("ST2-128", "Tipo de parโmetro de cmd invalido.", ERRO)
	::AdicMsgECF("ST2-64", "Mem๓ria fiscal lotada.", ERRO)
	::AdicMsgECF("ST2-32", "Erro na mem๓ria RAM cmos nใo volแtil.", ERRO)
	::AdicMsgECF("ST2-16", "Alํquota nใo programada.", ERRO)
	::AdicMsgECF("ST2-8", "Capacidade de alํquotas esgotadas.", ERRO)
	::AdicMsgECF("ST2-4", "Cancelamento nใo permitido.", ERRO)
	::AdicMsgECF("ST2-2", "CNPJ/ie do proprietแrio nใo programado.", ERRO)
	::AdicMsgECF("ST2-1", "Comando nใo executado.", ERRO)
	
	//RETORNO ST3
	::AdicMsgECF("ST3-0","COMANDO OK", OK)
	::AdicMsgECF("ST3-1","COMANDO INVมLIDO", ERRO)
	::AdicMsgECF("ST3-2","ERRO DESCONHECIDO", ERRO)
	::AdicMsgECF("ST3-3","NฺMERO DE PARยMETRO INVมLIDO", ERRO)
	::AdicMsgECF("ST3-4","TIPO DE PARยMETRO INVมLIDO", ERRO)
	::AdicMsgECF("ST3-5","TODAS ALอQUOTAS Jม PROGRAMADAS", ERRO)
	::AdicMsgECF("ST3-6","TOTALIZADOR NรO FISCAL Jม PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-7","CUPOM FISCAL ABERTO", ERRO)
	::AdicMsgECF("ST3-8","CUPOM FISCAL FECHADO", ERRO)
	::AdicMsgECF("ST3-9","ECF OCUPADO", ERRO)
	::AdicMsgECF("ST3-10","IMPRESSORA EM ERRO", ERRO)
	::AdicMsgECF("ST3-11","IMPRESSORA SEM PAPEL", ERRO)
	::AdicMsgECF("ST3-12","IMPRESSORA COM CABEวA LEVANTADA", ERRO)
	::AdicMsgECF("ST3-13","IMPRESSORA OFF LINE", ERRO)
	::AdicMsgECF("ST3-14","ALอQUOTA NรO PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-15","TERMINADOR DE STRING FALTANDO", ERRO)
	::AdicMsgECF("ST3-16","ACRษSCIMO OU DESCONTO MAIOR QUE O TOTAL DO CUPOM FISCAL", ERRO)
	::AdicMsgECF("ST3-17","CUPOM FISCAL SEM ITEM VENDIDO", ERRO)
	::AdicMsgECF("ST3-18","COMANDO NรO EFETIVADO", ERRO)
	::AdicMsgECF("ST3-19","SEM ESPAวO PARA NOVAS FORMAS DE PAGAMENTO", ERRO)
	::AdicMsgECF("ST3-20","FORMA DE PAGAMENTO NรO PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-21","อNDICE MAIOR QUE NฺMERO DE FORMA DE PAGAMENTO", ERRO)
	::AdicMsgECF("ST3-22","FORMAS DE PAGAMENTO ENCERRADAS", ERRO)
	::AdicMsgECF("ST3-23","CUPOM NรO TOTALIZADO", ERRO)
	::AdicMsgECF("ST3-24","COMANDO MAIOR QUE 7Fh (127d)", ERRO)
	::AdicMsgECF("ST3-25","CUPOM FISCAL ABERTO E SEM อTEM", ERRO)
	::AdicMsgECF("ST3-26","CANCELAMENTO NรO IMEDIATAMENTE APำS", ERRO)
	::AdicMsgECF("ST3-27","CANCELAMENTO Jม EFETUADO", ERRO)
	::AdicMsgECF("ST3-28","COMPROVANTE DE CRษDITO OU DษBITO NรO PERMITIDO OU Jม EMITIDO", ERRO)
	::AdicMsgECF("ST3-29","MEIO DE PAGAMENTO NรO PERMITE TEF", ERRO)
	::AdicMsgECF("ST3-30","SEM COMPROVANTE NรO FISCAL ABERTO", ERRO)
	::AdicMsgECF("ST3-31","COMPROVANTE DE CRษDITO OU DษBITO Jม ABERTO", ERRO)
	::AdicMsgECF("ST3-32","REIMPRESSรO NรO PERMITIDA", ERRO)
	::AdicMsgECF("ST3-33","COMPROVANTE NรO FISCAL Jม ABERTO", ERRO)
	::AdicMsgECF("ST3-34","TOTALIZADOR NรO FISCAL NรO PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-35","CUPOM NรO FISCAL SEM อTEM VENDIDO", ERRO)
	::AdicMsgECF("ST3-36","ACRษSCIMO E DESCONTO MAIOR QUE TOTAL CNF", ERRO)
	::AdicMsgECF("ST3-37","MEIO DE PAGAMENTO NรO INDICADO", ERRO)
	::AdicMsgECF("ST3-38","MEIO DE PAGAMENTO DIFERENTE DO TOTAL DO RECEBIMENTO", ERRO)
	::AdicMsgECF("ST3-39","NรO PERMITIDO MAIS DE UMA SANGRIA OU SUPRIMENTO", ERRO)
	::AdicMsgECF("ST3-40","RELATำRIO GERENCIAL Jม PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-41","RELATำRIO GERENCIAL NรO PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-42","RELATำRIO GERENCIAL NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-43","MFD NรO INICIALIZADA", ERRO)
	::AdicMsgECF("ST3-44","MFD AUSENTE", ERRO)
	::AdicMsgECF("ST3-45","MFD SEM NฺMERO DE SษRIE", ERRO)
	::AdicMsgECF("ST3-46","MFD Jม INICIALIZADA", ERRO)
	::AdicMsgECF("ST3-47","MFD LOTADA", ERRO)
	::AdicMsgECF("ST3-48","CUPOM NรO FISCAL ABERTO", ERRO)
	::AdicMsgECF("ST3-49","MEMำRIA FISCAL DESCONECTADA", ERRO)
	::AdicMsgECF("ST3-50","MEMำRIA FISCAL SEM NฺMERO DE SษRIE DA MFD", ERRO)
	::AdicMsgECF("ST3-51","MEMำRIA FISCAL LOTADA", ERRO)
	::AdicMsgECF("ST3-52","DATA INICIAL INVมLIDA", ERRO)
	::AdicMsgECF("ST3-53","DATA FINAL INVมLIDA", ERRO)
	::AdicMsgECF("ST3-54","CONTADOR DE REDUวรO Z INICIAL INVมLIDO", ERRO)
	::AdicMsgECF("ST3-55","CONTADOR DE REDUวรO Z FINAL INVมLIDO", ERRO)
	::AdicMsgECF("ST3-56","ERRO DE ALOCAวรO", ERRO)
	::AdicMsgECF("ST3-57","DADOS DO RTC INCORRETOS", ERRO)
	::AdicMsgECF("ST3-58","DATA ANTERIOR AO ฺLTIMO DOCUMENTO EMITIDO", ERRO)
	::AdicMsgECF("ST3-59","FORA DE INTERVENวรO TษCNICA", ERRO)
	::AdicMsgECF("ST3-60","EM INTERVENวรO TษCNICA", ERRO)
	::AdicMsgECF("ST3-61","ERRO NA MEMำRIA DE TRABALHO", ERRO)
	::AdicMsgECF("ST3-62","Jม HOUVE MOVIMENTO NO DIA", ERRO)
	::AdicMsgECF("ST3-63","BLOQUEIO POR RZ", ERRO)
	::AdicMsgECF("ST3-64","FORMA DE PAGAMENTO ABERTA", ERRO)
	::AdicMsgECF("ST3-65","AGUARDANDO PRIMEIRO PROPRIETมRIO", ERRO)
	::AdicMsgECF("ST3-66","AGUARDANDO RZ", ALERTA)
	::AdicMsgECF("ST3-67","ECF OU LOJA IGUAL A ZERO", ERRO)
	::AdicMsgECF("ST3-68","CUPOM ADICIONAL NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-69","DESCONTO MAIOR QUE TOTAL VENDIDO EM ICMS", ERRO)
	::AdicMsgECF("ST3-70","RECEBIMENTO NรO FISCAL NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-71","ACRษSCIMO OU DESCONTO MAIOR QUE TOTAL NรO FISCAL", ERRO)
	::AdicMsgECF("ST3-72","MEMำRIA FISCAL LOTADA PARA NOVO CARTUCHO", ERRO)
	::AdicMsgECF("ST3-73","ERRO DE GRAVAวรO NA MF", ERRO)
	::AdicMsgECF("ST3-74","ERRO DE GRAVAวรO NA MFD", ERRO)
	::AdicMsgECF("ST3-75","DADOS DO RTC ANTERIORES AO ฺLTIMO DOC ARMAZENADO", ERRO)
	::AdicMsgECF("ST3-76","MEMำRIA FISCAL SEM ESPAวO PARA GRAVAR LEITURAS DA MFD", ERRO)
	::AdicMsgECF("ST3-77","MEMำRIA FISCAL SEM ESPAวO PARA GRAVAR VERSAO DO SB", ERRO)
	::AdicMsgECF("ST3-78","DESCRIวรO IGUAL A DEFAULT NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-79","EXTRAPOLADO NฺMERO DE REPETIวีES PERMITIDAS", ERRO)
	::AdicMsgECF("ST3-80","SEGUNDA VIA DO COMPROVANTE DE CRษDITO OU DษBITO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-81","PARCELAMENTO FORA DA SEQUสNCIA", ERRO)
	::AdicMsgECF("ST3-82","COMPROVANTE DE CRษDITO OU DษBITO ABERTO", ERRO)
	::AdicMsgECF("ST3-83","TEXTO COM SEQUสNCIA DE ESC INVมLIDA", ERRO)
	::AdicMsgECF("ST3-84","TEXTO COM SEQUสNCIA DE ESC INCOMPLETA", ERRO)
	::AdicMsgECF("ST3-85","VENDA COM VALOR NULO", ERRO)
	::AdicMsgECF("ST3-86","ESTORNO DE VALOR NULO", ERRO)
	::AdicMsgECF("ST3-87","FORMA DE PAGAMENTO DIFERENTE DO TOTAL DA SANGRIA", ERRO)
	::AdicMsgECF("ST3-88","REDUวรO NรO PERMITIDA EM INTERVENวรO TษCNICA", ERRO)
	::AdicMsgECF("ST3-89","AGUARDANDO RZ PARA ENTRADA EM INTERVENวรO TษCNICA", ERRO)
	::AdicMsgECF("ST3-90","FORMA DE PAGAMENTO COM VALOR NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-91","ACRษSCIMO E DESCONTO MAIOR QUE VALOR DO อTEM", ERRO)
	::AdicMsgECF("ST3-92","AUTENTICAวรO NรO PERMITIDA", ERRO)
	::AdicMsgECF("ST3-93","TIMEOUT NA VALIDAวรO", ERRO)
	::AdicMsgECF("ST3-94","COMANDO NรO EXECUTADO EM IMPRESSORA BILHETE DE PASSAGEM", ERRO)
	::AdicMsgECF("ST3-95","COMANDO NรO EXECUTADO EM IMPRESSORA DE CUPOM FISCAL", ERRO)
	::AdicMsgECF("ST3-96","CUPOM NรO FISCAL FECHADO", ERRO)
	::AdicMsgECF("ST3-97","PARยMETRO NรO ASCII EM CAMPO ASCII", ERRO)
	::AdicMsgECF("ST3-98","PARยMETRO NรO ASCII NUMษRICO EM CAMPO ASCII NUMษRICO", ERRO)
	::AdicMsgECF("ST3-99","TIPO DE TRANSPORTE INVมLIDO", ERRO)
	::AdicMsgECF("ST3-100","DATA E HORA INVมLIDA", ERRO)
	::AdicMsgECF("ST3-101","SEM RELATำRIO GERENCIAL OU COMPROVANTE DE CRษDITO OU DษBITO ABERTO", ERRO)
	::AdicMsgECF("ST3-102","NฺMERO DO TOTALIZADOR NรO FISCAL INVมLIDO", ERRO)
	::AdicMsgECF("ST3-103","PARยMETRO DE ACRษSCIMO OU DESCONTO INVมLIDO", ERRO)
	::AdicMsgECF("ST3-104","ACRษSCIMO OU DESCONTO EM SANGRIA OU SUPRIMENTO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-105","NฺMERO DO RELATำRIO GERENCIAL INVมLIDO", ERRO)
	::AdicMsgECF("ST3-106","FORMA DE PAGAMENTO ORIGEM NรO PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-107","FORMA DE PAGAMENTO DESTINO NรO PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-108","ESTORNO MAIOR QUE FORMA PAGAMENTO", ERRO)
	::AdicMsgECF("ST3-109","CARACTER NUMษRICO NA CODIFICAวรO GT NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-110","ERRO NA INICIALIZAวรO DA MF", ERRO)
	::AdicMsgECF("ST3-111","NOME DO TOTALIZADOR EM BRANCO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-112","DATA E HORA ANTERIORES AO ฺLTIMO DOC ARMAZENADO", ERRO)
	::AdicMsgECF("ST3-113","PARยMETRO DE ACRษSCIMO OU DESCONTO INVมLIDO", ERRO)
	::AdicMsgECF("ST3-114","อTEM ANTERIOR AOS TREZENTOS ฺLTIMOS", ERRO)
	::AdicMsgECF("ST3-115","อTEM NรO EXISTE OU Jม CANCELADO", ERRO)
	::AdicMsgECF("ST3-116","CำDIGO COM ESPAวOS NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-117","DESCRICAO SEM CARACTER ALFABษTICO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-118","ACRษSCIMO MAIOR QUE VALOR DO อTEM", ERRO)
	::AdicMsgECF("ST3-119","DESCONTO MAIOR QUE VALOR DO อTEM", ERRO)
	::AdicMsgECF("ST3-120","DESCONTO EM ISS NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-121","ACRษSCIMO EM อTEM Jม EFETUADO", ERRO)
	::AdicMsgECF("ST3-122","DESCONTO EM อTEM Jม EFETUADO", ERRO)
	::AdicMsgECF("ST3-123","ERRO NA MEMำRIA FISCAL CHAMAR CREDENCIADO", ERRO)
	::AdicMsgECF("ST3-124","AGUARDANDO GRAVAวรO NA MEMำRIA FISCAL", ERRO)
	::AdicMsgECF("ST3-125","CARACTER REPETIDO NA CODIFICAวรO DO GT", ERRO)
	::AdicMsgECF("ST3-126","VERSรO Jม GRAVADA NA MEMำRIA FISCAL", ERRO)
	::AdicMsgECF("ST3-127","ESTOURO DE CAPACIDADE NO CHEQUE", ERRO)
	::AdicMsgECF("ST3-128","TIMEOUT NA LEITURA DO CHEQUE", ERRO)
	::AdicMsgECF("ST3-129","MสS INVมLIDO", ERRO)
	::AdicMsgECF("ST3-130","COORDENADA INVมLIDA", ERRO)
	::AdicMsgECF("ST3-131","SOBREPOSIวรO DE TEXTO", ERRO)
	::AdicMsgECF("ST3-132","SOBREPOSIวรO DE TEXTO NO VALOR", ERRO)
	::AdicMsgECF("ST3-133","SOBREPOSIวรO DE TEXTO NO EXTENSO", ERRO)
	::AdicMsgECF("ST3-134","SOBREPOSIวรO DE TEXTO NO FAVORECIDO", ERRO)
	::AdicMsgECF("ST3-135","SOBREPOSIวรO DE TEXTO NA LOCALIDADE", ERRO)
	::AdicMsgECF("ST3-136","SOBREPOSIวรO DE TEXTO NO OPCIONAL", ERRO)
	::AdicMsgECF("ST3-137","SOBREPOSIวรO DE TEXTO NO DIA", ERRO)
	::AdicMsgECF("ST3-138","SOBREPOSIวรO DE TEXTO NO MสS", ERRO)
	::AdicMsgECF("ST3-139","SOBREPOSIวรO DE TEXTO NO ANO", ERRO)
	::AdicMsgECF("ST3-140","USANDO MFD DE OUTRO ECF", ERRO)
	::AdicMsgECF("ST3-141","PRIMEIRO DADO DIFERENTE DE ESC OU 1C", ERRO)
	::AdicMsgECF("ST3-142","NรO PERMITIDO ALTERAR SEM INTERVENวรO TษCNICA", ERRO)
	::AdicMsgECF("ST3-143","DADOS DA ฺLTIMA RZ CORROMPIDOS", ERRO)
	::AdicMsgECF("ST3-144","COMANDO NรO PERMITIDO NO MODO INICIALIZAวรO", ERRO)
	::AdicMsgECF("ST3-145","AGUARDANDO ACERTO DE RELำGIO", ERRO)
	::AdicMsgECF("ST3-146","MFD Jม INICIALIZADA PARA OUTRA MF", ERRO)
	::AdicMsgECF("ST3-147","AGUARDANDO ACERTO DO RELำGIO OU DESBLOQUEIO PELO TECLADO", ERRO)
	::AdicMsgECF("ST3-148","VALOR FORMA DE PAGAMENTO MAIOR QUE MมXIMO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-149","RAZรO SOCIAL EM BRANCO", ERRO)
	::AdicMsgECF("ST3-150","NOME DE FANTASIA EM BRANCO", ERRO)
	::AdicMsgECF("ST3-151","ENDEREวO EM BRANCO", ERRO)
	::AdicMsgECF("ST3-152","ESTORNO DE CDC NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-153","DADOS DO PROPRIETมRIO IGUAIS AO ATUAL", ERRO)
	::AdicMsgECF("ST3-154","ESTORNO DE FORMA DE PAGAMENTO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-155","DESCRIวรO FORMA DE PAGAMENTO IGUAL Jม PROGRAMADA", ERRO)
	::AdicMsgECF("ST3-156","ACERTO DE HORมRIO DE VERรO Sำ IMEDIATAMENTE APำS RZ", ERRO)
	::AdicMsgECF("ST3-157","IT NรO PERMITIDA MF RESERVADA PARA RZ", ERRO)
	::AdicMsgECF("ST3-158","SENHA CNPJ INVมLIDA", ERRO)
	::AdicMsgECF("ST3-159","TIMEOUT NA INICIALIZAวรO DA NOVA MF", ERRO)
	::AdicMsgECF("ST3-160","NรO ENCONTRADO DADOS NA MFD", ERRO)
	::AdicMsgECF("ST3-161","SANGRIA OU SUPRIMENTO DEVEM SER ฺNICOS NO CNF", ERRO)
	::AdicMsgECF("ST3-162","อNDICE DA FORMA DE PAGAMENTO NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-163","UF DESTINO INVมLIDA", ERRO)
	::AdicMsgECF("ST3-164","TIPO DE TRANSPORTE INCOMPATอVEL COM UF DESTINO", ERRO)
	::AdicMsgECF("ST3-165","DESCRIวรO DO PRIMEIRO อTEM DO BILHETE DE PASSAGEM DIFERENTE DE TARIFA", ERRO)
	::AdicMsgECF("ST3-166","AGUARDANDO IMPRESSรO DE CHEQUE OU AUTENTICAวรO", ERRO)
	::AdicMsgECF("ST3-167","NรO PERMITIDO PROGRAMAวAO CNPJ IE COM ESPAวOS EM BRANCO", ERRO)
	::AdicMsgECF("ST3-168","NรO PERMITIDO PROGRAMAวรO UF COM ESPAวOS EM BRANCO", ERRO)
	::AdicMsgECF("ST3-169","NฺMERO DE IMPRESSีES DA FITA DETALHE NESTA INTERVENวรO TษCNICA ESGOTADO", ERRO)
	::AdicMsgECF("ST3-170","CF Jม SUBTOTALIZADO", ERRO)
	::AdicMsgECF("ST3-171","CUPOM NรO SUBTOTALIZADO", ERRO)
	::AdicMsgECF("ST3-172","ACRษSCIMO EM SUBTOTAL Jม EFETUADO", ERRO)
	::AdicMsgECF("ST3-173","DESCONTO EM SUBTOTAL Jม EFETUADO", ERRO)
	::AdicMsgECF("ST3-174","ACRษSCIMO NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-175","DESCONTO NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-176","CANCELAMENTO DE ACRษSCIMO OU DESCONTO EM SUBTOTAL NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-177","DATA INVมLIDA", ERRO)
	::AdicMsgECF("ST3-178","VALOR DO CHEQUE NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-179","VALOR DO CHEQUE INVมLIDO", ERRO)
	::AdicMsgECF("ST3-180","CHEQUE SEM LOCALIDADE NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-181","CANCELAMENTO ACRษSCIMO EM อTEM NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-182","CANCELAMENTO DESCONTO EM อTEM NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-183","NฺMERO MมXIMO DE อTENS ATINGIDO", ERRO)
	::AdicMsgECF("ST3-184","NฺMERO DE อTEM NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-185","MAIS QUE DUAS ALอQUOTAS DIFERENTES NO BILHETE DE PASSAGEM NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-186","ACRษSCIMO OU DESCONTO EM ITEM NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-187","CANCELAMENTO DE ACRษSCIMO OU DESCONTO EM ITEM NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-188","CLICHE Jม IMPRESSO", ERRO)
	::AdicMsgECF("ST3-189","TEXTO OPCIONAL DO CHEQUE EXCEDEU O MมXIMO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-190","IMPRESSรO AUTOMมTICA NO VERSO NรO PERMITIDO NESTE EQUIPAMENTO", ERRO)
	::AdicMsgECF("ST3-191","TIMEOUT NA INSERวรO DO CHEQUE", ERRO)
	::AdicMsgECF("ST3-192","OVERFLOW NA CAPACIDADE DE TEXTO DO COMPROVANTE DE CRษDITO OU DษBITO", ERRO)
	::AdicMsgECF("ST3-193","PROGRAMAวรO DE ESPAวOS ENTRE CUPONS MENOR QUE O MอNIMO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-194","EQUIPAMENTO NรO POSSUI LEITOR DE CHEQUE", ERRO)
	::AdicMsgECF("ST3-195","PROGRAMAวรO DE ALอQUOTA COM VALOR NULO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-196","PARยMETRO BAUD RATE INVมLIDO", ERRO)
	::AdicMsgECF("ST3-197","CONFIGURAวรO PERMITIDA SOMENTE PELA PORTA DOS FISCO", ERRO)
	::AdicMsgECF("ST3-198","VALOR TOTAL DO ITEM EXCEDE 11 DอGITOS", ERRO)
	::AdicMsgECF("ST3-199","PROGRAMAวรO DA MOEDA COM ESPAวOS EM BRACO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-200","CASAS DECIMAIS DEVEM SER PROGRAMADAS COM 2 OU 3", ERRO)
	::AdicMsgECF("ST3-201","NรO PERMITE CADASTRAR USUมRIOS DIFERENTES NA MESMA MFD", ERRO)
	::AdicMsgECF("ST3-202","IDENTIFICAวรO DO CONSUMIDOR NรO PERMITIDA PARA SANGRIA OU SUPRIMENTO", ERRO)
	::AdicMsgECF("ST3-203","CASAS DECIMAIS EM QUANTIDADE MAIOR DO QUE A PERMITIDA", ERRO)
	::AdicMsgECF("ST3-204","CASAS DECIMAIS DO UNITมRIO MAIOR DO QUE O PERMITIDA", ERRO)
	::AdicMsgECF("ST3-205","POSIวรO RESERVADA PARA ICMS", ERRO)
	::AdicMsgECF("ST3-206","POSIวรO RESERVADA PARA ISS", ERRO)
	::AdicMsgECF("ST3-207","TODAS AS ALอQUOTAS COM A MESMA VINCULAวรO NรO PERMITIDO", ERRO)
	::AdicMsgECF("ST3-208","DATA DE EMBARQUE ANTERIOR A DATA DE EMISSรO", ERRO)
	::AdicMsgECF("ST3-209","ALอQUOTA DE ISS NรO PERMITIDA SEM INSCRIวรO MUNICIPAL", ERRO)
	::AdicMsgECF("ST3-210","RETORNO PACOTE CLICHE FORA DA SEQUสNCIA", ERRO)
	::AdicMsgECF("ST3-211","ESPAวO PARA ARMAZENAMENTO DO CLICHE ESGOTADO", ERRO)
	::AdicMsgECF("ST3-212","CLICHE GRมFICO NรO DISPONอVEL PARA CONFIRMAวรO", ERRO)
	::AdicMsgECF("ST3-213","CRC DO CLICHE GRมFICO DIFERENTE DO INFORMADO", ERRO)
	::AdicMsgECF("ST3-214","INTERVALO INVมLIDO", ERRO)
	::AdicMsgECF("ST3-215","USUมRIO Jม PROGRAMADO", ERRO)
	::AdicMsgECF("ST3-217","DETECTADA ABERTURA DO EQUIPAMENTO", ERRO) 
	::AdicMsgECF("ST3-218","CANCELAMENTO DE ACRษSCIMO/DESCONTO NรO PERMITIDO", ERRO)

	 
Return Nil 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento dos dados   บฑฑ
ฑฑบ          ณdo usuario cadastrado na impressora.			  		  	  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeDadoUsu() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cCNPJ  	:= Space(20)	//String que receber o CNPj
	Local cIE  		:= Space(20)	//String que receber a IE
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_CNPJ_IE", cCNPJ, cIE})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)

	// Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cCnpj := AllTrim(oParams:Elements(3):cParametro)	// Copia o C.N.P.J da impressora
		::cIE := AllTrim(oParams:Elements(4):cParametro) 	// Copia o I.E da impressora
	EndIf
    	
Return oRetorno 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do modelo do ECF   		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeModelo() Class LJAIBM 

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cModelo  := Space(10)	//String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ModeloImpressora", cModelo})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cModelo := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
	EndIf
	
Return oRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do modelo do ECF   		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeFrmWare() Class LJAIBM 

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cFrmWare  := Space(6)	//String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VersaoFirmwareMFD", cFrmWare})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cFirmWare := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura da Inscricao Municiapal 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeInscMun() Class LJAIBM 

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cInsMun  := Space(20) //String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_InscricaoMunicipalMFD", cInsMun})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
		::cIM := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora	
	EndIf
	
Return oRetorno          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento dos dados   บฑฑ
ฑฑบ          ณcadastrados na impressora.			  		  			  			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeDadImp() Class LJAIBM
	
	Local oParams 	:= Nil			 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cNserie  := Space(20) //String que receber os dados da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroSerieMFD", cNserie})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
   If(oRetorno:cAcao <> ERRO)    	
		::cNrSerie := AllTrim(oParams:Elements(3):cParametro)		// Copia o Numero de serie da impressora
		
		//Efetua o corte em 20 caracteres pois pode vir uma sujeira e gerar problema na valida็ใo do LOJA420
		::cNrSerie := SubStr(::cNrSerie,1,20)
	
		::cFabric := AllTrim(substr(oParams:Elements(3):cParametro, 1, 2))		// Copia o Fabricante da impressora, verificar.
	EndIf
	
Return oRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento do cliche   บฑฑ
ฑฑบ          ณcadastrado na impressora.				  		 	 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCliche() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(186)	//String que receber o cliche da impressora
	//Local aDados 	:= {}
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ClicheProprietario", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	 
        
    	
    	//aDados := strtokarr(oParams:Elements(3):cParametro, chr(13)+chr(10))	
    	
		::cRazaoSoc  := AllTrim(Left(oParams:Elements(3):cParametro, 48))			// Copia Razao Social da impressora
		//oParams:Elements(3):cParametro := Alltrim(Substr( oParams:Elements(3):cParametro, At(oParams:Elements(3):cParametro, " ") ) )
		::cFantasia  := AllTrim(Substr(oParams:Elements(3):cParametro, 49, 48)	)			   // Copia o Nome Fantasia da impressora
		::cEndereco1 := AllTrim(Substr(oParams:Elements(3):cParametro, 97, 48)	)	   // Copia o Endereco 1 da impressora
		::cEndereco2 := AllTrim(Substr(oParams:Elements(3):cParametro, 146) )		// Copia o Endereco 2 da impressora
	
	EndIf	 
	
Return oRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento do nome do  บฑฑ
ฑฑบ          ณoperador cadastrado na impressora.				  		  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/      

Method LeOperador() Class LJAIBM 

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
   
		//IBM NAO TEM FUNCAO QUE RETORNA O OPERADOR CADASTRADO NA IMPRESSORA
    	oRetorno    := ::TratarRet("0000")
		::cOperador := ""			// Copia o nome do operador da impressora

Return oRetorno         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do numero da loja 		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeNumLoja() Class LJAIBM	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cLoja  	:= Space(4)		//String que receber o numero da loja e do ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroLoja", cLoja})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
    	::cLoja := AllTrim(oParams:Elements(3):cParametro)		// Copia o numero da Loja
	EndIf	
	
Return oRetorno 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do numero do ECF   		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeECFLoja() Class LJAIBM	
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cNCaixa  := Space(4)	//String que receber o numero da loja e do ECF
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCaixa", cNCaixa})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)

    If(oRetorno:cAcao <> ERRO) 
	  	::cNumEcf := ::CorrigRet(oParams:Elements(3):cParametro)	// Copia o numero do ECF
    EndIF

	
Return oRetorno 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do valor percentual da 	  บฑฑ
ฑฑบ          ณaliquotas.												  			     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeAliq() Class LJAIBM
	
	Local oParams 		:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(79)	//String que receber a tabela de aliquotas cadastradas no ECF
	Local cDados2  	:= Space(48)	//String que receber o indice das aliquotas cadastradas no ECF ISS
	Local aDados  		:= {}				//Array que receber้ todas as aliquotas da string de retorno 
	Local cSimbolo  	:= Nil			//String que retorna o simbolo da aliquota - Nao tem funcao que retorne o simbolo
	Local cIndAliqISS := Nil			//String que receberแ as aliquotas de ISS
	Local nDx 			:= 0


	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_RetornoAliquotas", cDados1})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	 
    
	    //Todas as aliquotas cadastradas serao retornadas com "," como delimitador  
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
	         
	    	//Verfico as aliqutoas de ISS
		   	//Prepara os parametros de envio 
			oParams := ::PrepParam({IBM, "IBM_FI_VerificaIndiceAliquotasIss", cDados2})
		
	    	//Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
			
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
			
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)    
		    
		    If(oRetorno:cAcao <> ERRO) 
		    
			    cIndAliqISS := AllTrim(oParams:Elements(3):cParametro)
			                           
    			For nDX := 1 To Len(aDados)
	    
	    	    	 cValor   :=  AllTrim(aDados[nDX]) 
	    	    	 //indice sequencial
	    	    	 cSimbolo := strzero(nDX, 2, 0)
	    	    	 
	    	    	 If (cSimbolo $ cIndAliqISS)
						::AdicAliq(cSimbolo,Val(cValor) / 100, .T.) //Por enquanto insiro como ISS
					 Else
						::AdicAliq(cSimbolo,Val(cValor) / 100, .F.) //Por enquanto insiro como ICMS	    	    	 
			    	 EndIf  
	    	    	 
	    		Next nDX
	   	 EndIf
	    
	EndIf	
	
Return oRetorno  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento da tabela   บฑฑ
ฑฑบ          ณde totalizadores nao fiscais cadastrados na impressora.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeTotNF() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros.
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial.
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao.
	Local cDados  	:= Space(599)	//String que receber a tabela de Totalizadores Nao Fiscais.
	Local nDX		:= 1				//Contador utilizado no comando "For".
	Local aDados	:= {}				//String temporaria para armazenamento do indice do totalizador.
	Local cIndice 	:= 0

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresNaoFiscaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    
		
		//Transformo em array os dados de retorno    
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
    	 
    	//Para cada totalizados, seleciono o valor e insiro na tabela
   	For nDX := 1 To Len(aDados)   
    	     
	    	If( Alltrim(aDados[nDX]) != "")				
		    	
		    	cIndice := strzero(nDX, 2, 0)
				::AdicTotNf(cIndice,aDados[nDX],"E","") //Insere o totalizador nao fiscal na tabela.
				
			EndIf    
    	
		Next nDX    	
		
	EndIf      
	
Return oRetorno 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento da tabela   	  บฑฑ
ฑฑบ          ณde relatorios gerenciais cadastrados na impressora.		  	 	  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	 	  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum												  		 				     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  	 			  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeRelGer() Class LJAIBM
	Local oParams 	 := Nil			//Objeto para passagem dos parametros
	Local cRetorno  := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno  := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	 := Space(659)	//String que receber a tabela de relatorios gerenciais cadastradas no ECF
	Local nDX		 := 1				//Contador utilizado no comando "For"
	Local cIndice	 := 0				//String temporaria para armazenamento do indice do relatorio
	Local cDesc		 := Space(17)	//String temporaria para armazenamento da descricao do relatorio
	Local cContador := Space(4)	//String temporaria para armazenamento do contador de emissao do relatorio 
	Local aDados 	 := {}
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaRelatorioGerencialMFD", cDados})
	
    //Envia o comando
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno
    oRetorno := ::TratarRet(cRetorno)

	// Caso o comando tenha sido executado com sucesso
    If(oRetorno:cAcao <> ERRO)    	
    	
    	//Transformo em array os dados de retorno    
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
    	 
    	//Para cada totalizados, seleciono o valor e insiro na tabela
    	For nDX := 1 To Len(aDados)   
    	
    		cDesc     := AllTrim(substr(aDados[nDX], 5))
    	    cContador := AllTrim(substr(aDados[nDX], 1, 4))
    	    
	    	//Caso a descricao seja preenchida
			If( AllTrim(cDesc) != "") 
	
				cIndice := strzero(nDX, 2, 0)
				::AdicGerenc(cIndice,cDesc)		//Insere o relatorio gerencial na tabela.
				
			EndIf   
			
		Next nDX    	 	
		
	EndIf
Return oRetorno 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura e preenchimento da tabela   บฑฑ
ฑฑบ          ณde finalizadoras cadastradas na impressora.				  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                                                   
Method LeFinaliz() Class LJAIBM
	Local oParams 	  := Nil				//Objeto para passagem dos parametros
	Local cRetorno   := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno   := Nil				//Objeto que sera retornado pela funcao	
	Local cDados  	  := Space(3016)	//String que receber a tabela de finalizadoras cadastradas no ECF
	Local nDX		  := 1				//Contador utilizado no comando "For"
	Local cIndice	  := 0				//String temporaria para armazenamento do indice da finalizadora
	Local cDesc		  := Space(16)		//String temporaria para armazenamento da descricao da finalizadora
	Local cVendido	  := Space(14)		//String temporaria para armazenamento do valor recebido pela finalizadora
	Local cVinculado := Space(1)		//String temporaria para armazenamento da indicacao de finalizadora vinculada TEF
	Local aDados  	  := {}
		    	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaFormasPagamentoMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno                                   
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
    
    	//Transformo em array os dados de retorno    
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",") 
    	 
    	//Para cada totalizados, seleciono o valor e insiro na tabela
    	For nDX := 1 To Len(aDados)   
    	                                          
    		  
    	    cDesc      := AllTrim(substr(aDados[nDX], 1, 16))
    	    cVendido   := AllTrim(substr(aDados[nDX], 31, 14))                    
    	    cVinculado := AllTrim(substr(aDados[nDX], 45)) 

    	    //Caso a descricao seja preenchida
    	    If(AllTrim(cDesc) != "")    

				cIndice := strzero(nDX, 2, 0)
				
				If cVinculado == "1" 				
					::AdicForma(cIndice,cDesc,.T.)		//Insere a finalizadora vinculada na tabela.
				Else
					::AdicForma(cIndice,cDesc,.F.)		//Insere a finalizadora NAO vinculada na tabela.
				EndIF
				
			EndIf

		Next nDX    	 	
	EndIf
Return oRetorno 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeDataJor บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura da data de abertura da	  	  บฑฑ
ฑฑบ          ณjornada.													  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf contendo a data e hora do movimento do บฑฑ
ฑฑบ			 ณecf no formato dd/mm/aaaa hh:mm:SS (19 bytes)				  	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeDataJor() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cData  	:= Space(6)		//String que recebera a data de abertura da jornada
	Local cHora  	:= Space(6)		//String que recebera a hora de abertura da jornada
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraImpressora", cData, cHora})
	
	 //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
	//Trata o retorno                                 
    oRetorno := ::TratarRet(cRetorno)
   
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

		oRetorno:oRetorno := substr((oParams:Elements(3):cParametro), 1,2)  + "/" +;
									substr((oParams:Elements(3):cParametro), 3,2)  + "/" +;
									"20" + substr((oParams:Elements(3):cParametro), 5,2)  + " " +;
									substr((oParams:Elements(4):cParametro), 1,2)  + ":" +;
									substr((oParams:Elements(4):cParametro), 3,2)  + ":" +;
									substr((oParams:Elements(4):cParametro), 5,2)


	EndIf
	
Return oRetorno
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do GT da impressora.		  บฑฑ
ฑฑบ          ณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeGT() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(18)	//String que recebera GT da impressora
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_GrandeTotal", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := Substr(oParams:Elements(3):cParametro,1,18)
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do ultimo COO impresso.     บฑฑ
ฑฑบ          ณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                 	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf									      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCOO() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cCOOIni  := Space(6)		//String que recebera o contador inicial
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroCupom", cCOOIni})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	                                                  
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := AllTrim(oParams:Elements(3):cParametro)
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeTotCanc บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณcancelamentos executados na impressora ( ICMS + ISS )  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeTotCanc() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais cancelados da impressora
	Local aDados 	:= {}				//Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)
	    aDados := strtokarr(oParams:Elements(3):cParametro, ",")
		oRetorno:oRetorno :=	Val(aDados[10]) / 100   //ICMS
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeTotCanc บAutor  ณVendas Clientes     บ Data ณ  17/06/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณcancelamentos executados na impressora ( ISS )  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LeTotCanIss() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""		  		//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais cancelados da impressora
	Local aDados 	:= {}				//Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)
		aDados := strtokarr(oParams:Elements(3):cParametro, ",")
		oRetorno:oRetorno :=	Val(aDados[13]) / 100     //ISSQN
	EndIf
	
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeTotDesc บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณdescontos executados na impressora ( ICMS + ISS )  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LeTotDesc() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora 
	Local aDados 	:= {}          //Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

	 	aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[08]) / 100   //ICMS
	EndIf

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeTotDesIss บAutor  ณVendas Clientes     บ Data ณ  17/06/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณdescontos executados na impressora ( ISS )  	  	  	      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LeTotDesIss() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora 
	Local aDados 	:= {}          //Array que recebera a string delimitada por ","
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)
	 	aDados := strtokarr(oParams:Elements(3):cParametro, ",")
		oRetorno:oRetorno :=	Val(aDados[11]) / 100     //ISSQN
	EndIf

Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeTotIsentบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio das vendas	  บฑฑ
ฑฑบ          ณIsentas executadas na impressora ( I + IS )  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LeTotIsent() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que receber a tabela de aliquotas cadastradas no ECF
	Local aDados 	:= {}          //Array que recebera a string delimitada por ","
		
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno                                                       
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	

	 	aDados := strtokarr(oParams:Elements(3):cParametro, ",")	
	
		oRetorno:oRetorno :=	Val(aDados[02]) / 100 +;   //Isencao ICMS
							 	Val(aDados[05]) / 100     //Isencao ISSQN
	EndIf
	

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeTotNTribบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณnao tributados vendidos na impressora ( ICMS + ISS  )  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeTotNTrib() Class LJAIBM
	
	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que receber a tabela de aliquotas cadastradas no ECF  
	Local aDados    := {}           //Array contendo os dados da impressora
		
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)   
                                   
    	aDados := strtokarr(oParams:Elements(3):cParametro, ",")
    	oRetorno:oRetorno :=  Val(aDados[03]) / 100 +;   //ICMS
							 	Val(aDados[06]) / 100     //ISSQN
       				
	EndIf

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeTotIss  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณcancelamentos executados na impressora ( ICMS + ISS + NF )  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeTotIss() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(889)	//String que recebera os totais de desconto da impressora    
	Local cTotal    := ""           
	Local aArrVlr   := {}    
	Local nDx		:= 0 
	Local aArrAli   := {}
	Local cIndAliqISS := {}    
	Local nTotISS   := 0   
	
	
	//Tabela de totalizadores parciais		                                    
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VerificaTotalizadoresParciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)  
    
	     cTotal := substr(Alltrim(oParams:Elements(3):cParametro), 1, 224)
		  aArrVlr := {}   
		   
		   For nDx := 1 To 224 Step 14
		   	aAdd(aArrVlr, Val(SubStr(cTotal, nDx, 14)))
		   Next	                                          
    
		    //Todas as aliquotas cadastradas serao retornadas com "," como delimitador  
	  		//Prepara os parametros de envio 
	  		cDados := space(79)
			oParams := ::PrepParam({IBM, "IBM_FI_RetornoAliquotas", cDados})
		
		   //Envia o comando    	
			cRetorno := ::EnviarCom(oParams)
		
			//Obtem o Estado da impressora
			cRetorno := ::ObterEst(cRetorno)
		
		    //Trata o retorno    
		    oRetorno := ::TratarRet(cRetorno)

		   If(oRetorno:cAcao <> ERRO) 
		  
		  		aArrAli := strtokarr(AllTrim(oParams:Elements(3):cParametro), ",")
		    
			    
	   	 	//Verfico as aliqutoas de ISS para serem descartadas
			   //Prepara os parametros de envio      
			    cDados := space(79)
				oParams := ::PrepParam({IBM, "IBM_FI_VerificaIndiceAliquotasIss", cDados})
		
		    	//Envia o comando    	
				cRetorno := ::EnviarCom(oParams)
				
				//Obtem o Estado da impressora
				cRetorno := ::ObterEst(cRetorno)
				
			    //Trata o retorno                                 
			    oRetorno := ::TratarRet(cRetorno)  
		    
		    
		    	If(oRetorno:cAcao <> ERRO) 
		    
			    	cIndAliqISS := AllTrim(oParams:Elements(3):cParametro)
			                           
    		  			For nDX := 1 To Len(aArrAli)
    			    
		    			    If Val(aArrAli[nDx]) == 0 .Or. !StrZero(nDX, 2) $ cIndAliqISS
		    			    	Loop
		    			    EndIf
	    
							nTotISS += aArrVlr[nDx]/100
	    	  			Next nDX
	   	 	     EndIf

  			EndIf	 
  			                                             
    EndIf                                                  

    oRetorno:oRetorno := nTotISS
	
Return oRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeVndLiq  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura do somatorio dos    		  บฑฑ
ฑฑบ          ณcancelamentos executados na impressora ( ICMS + ISS + NF )  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LeVndLiq() Class LJAIBM                                          
Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
Local nVB 	:= 0
Local nDesc := 0
Local nCanc := 0
Local nVIss := 0
Local nCanIss := 0
Local nDesIss := 0
	
oRetorno := ::LeVndBrut()

If(oRetorno:cAcao == OK)
	nVB := oRetorno:oRetorno
	oRetorno := ::LeTotCanc()
EndIf

If(oRetorno:cAcao == OK)
	nCanc := oRetorno:oRetorno
	oRetorno := ::LeTotIss()
EndIf

If(oRetorno:cAcao == OK)
	nVIss := oRetorno:oRetorno
	oRetorno := ::LeTotDesc()
EndIf

If(oRetorno:cAcao == OK)
	nDesc := oRetorno:oRetorno
	oRetorno := ::LeTotDesISS()
EndIf

If(oRetorno:cAcao == OK)
	nDesIss := oRetorno:oRetorno 
	oRetorno:= ::LeTotCanISS()
EndIf

If oRetorno:cAcao == OK
	nCanIss := oRetorno:oRetorno
	oRetorno:oRetorno := nVB - nDesc - nCanc - nVIss - nDesIss - nCanIss
EndIf
		
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeVndBrut บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura da Venda Bruta Atual.		  บฑฑ
ฑฑบ          ณ															  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeVndBrut() Class LJAIBM	

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(18) //String que recebera a venda bruta atual da impressora

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_VendaBruta", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := Val(Substr(oParams:Elements(3):cParametro,1,18)) / 100
	EndIf
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA1336_ บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela leitura da Venda Bruta Atual.		  บฑฑ
ฑฑบ          ณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico		    										  			     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Method LeFaseCP() Class LJAIBM	

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
	
Return oRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCancIt บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar se pode cancelar todos os 	  บฑฑ
ฑฑบ          ณitens														  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCancIt() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := "TODOS"

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetVlSupr บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar o valor do suprimento   	  บฑฑ
ฑฑบ          ณitens														  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetVlSupr()  Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
     oRetorno:oRetorno := 0
   	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetItImp  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar se todos os itens foram   	  บฑฑ
ฑฑบ          ณimpressos													  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  				     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetItImp() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := .T.
   	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPosFuncบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar se ecf retorna o Subtotal e oบฑฑ
ฑฑบ          ณnumero de itens impressos no cupom fiscal.				  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPosFunc() Class LJAIBM

	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
 	 oRetorno:oRetorno := .F.
   	
Return oRetorno   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPathMFDบAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar o caminho e nome do arquivo  บฑฑ
ฑฑบ          ณde Memoria Fita Detalhe.                   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPathMFD() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMFD //Copia o valor da propriedade da classe
   	
Return oRetorno  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPathMF บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar o caminho e nome do arquivo  บฑฑ
ฑฑบ          ณde Memoria Fiscal.		                   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPathMF() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMF  //Copia o valor da propriedade da classe
   	
Return oRetorno   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPathTipoE บAutor  ณVendas Clientes     บ Data ณ  21/07/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar o caminho e nome do arquivo  	 บฑฑ
ฑฑบ          ณregistro Tipo E Ato Cotepe 17/04 PAF-ECF.		   			  	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  	 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPathTipoE(cBinario) Class LJAIBM

	Local oRetorno 	:= Nil			 		//Objeto que sera retornado pela funcao
	
	Default cBinario := "0"
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMF + IIF(cBinario <> "1", "COTEPE1704.txt", "download.bin")				 	//Copia o valor da propriedade da classe
   	
Return oRetorno   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetLetMem บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a letra indicativa de MF adicional  				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetLetMem() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := " "			 //Copia o valor da propriedade da classe

Return oRetorno
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetTipEcf	บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Tipo de ECF  										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetTipEcf() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
    oRetorno:oRetorno := "ECF-IF"			 //Copia o valor da propriedade da classe

Return oRetorno
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetDatSW	บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Data de instalacao da versao atual do Software    บฑฑ
ฑฑบ          ณBแsico gravada na Memoria Fiscal do ECF.    				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDatSW() Class LJAIBM

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(06) //String que recebera a Data/Hora Usuแrio
	Local cDados2  	:= Space(06) //String que recebera a Data/Hora SW

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraSoftwareBasico", cDados1,cDados2})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := PadR(oParams:Elements(3):cParametro,10)
	EndIf
	
Return oRetorno
    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetHorSW	บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Hora de instalacao da versao atual do Software    บฑฑ
ฑฑบ          ณBแsico gravada na Memoria Fiscal do ECF.    				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetHorSW() Class LJAIBM

	Local oParams 	:= Nil		 //Objeto para passagem dos parametros
	Local cRetorno := ""			 //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
	Local cDados1  	:= Space(06) //String que recebera a Data/Hora Usuแrio
	Local cDados2  	:= Space(06) //String que recebera a Data/Hora SW

	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_DataHoraSoftwareBasico", cDados1,cDados2})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := oParams:Elements(4):cParametro

	EndIf
	
Return oRetorno
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetGrTIni บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Grande total incicial							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetGrTIni() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe
   	
Return oRetorno  
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNumCnf บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Contador Geral de Opera็ใo Nใo Fiscal			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumCnf() Class LJAIBM
  
	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_NumeroOperacoesNaoFiscais ", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 6)
	EndIf
    


Return oRetorno  
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNumCrg บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Contador Geral de Relat๓rio Gerencial			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumCrg() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ContadorRelatoriosGerenciaisMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 6)
   	EndIf
   	
   	

Return oRetorno  
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNumCcc บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Contador de Comprovante de Cr้dito ou D้bito 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNumCcc() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao	
	Local cDados  	:= Space(6)	//String que recebera a status do horario de verao
	
	//Prepara os parametros de envio 
	oParams := ::PrepParam({IBM, "IBM_FI_ContadorComprovantesCreditoMFD", cDados})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
    // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 4)
   	EndIf

Return oRetorno  
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetDtUDoc บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a Data e Hora do ultimo Documento Armazenado na MFD บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetDtUDoc() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := ""			 //Copia o valor da propriedade da classe

Return oRetorno  
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCodEcf บAutor  ณVendas Clientes     บ Data ณ  10/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o Codigo da Impressora Referente a 				  บฑฑ
ฑฑบ          ณTABELA NACIONAL DE CำDIGOS DE IDENTIFICAวรO DE ECF		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCodEcf() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := Self:TratarRet("0000")
    
   	oRetorno:oRetorno := "      "	//Esta fun็ใo deverแ ser sobrescrita na classe a impressora fiscal

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeDadJorn บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em ler os dados da jornada				  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              

Method LeDadJorn() Class LJAIBM
	    
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	

	//Prepara os parametros de envio
	oRetorno := ::TratarRet("0000")
	
Return oRetorno     



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeCupIni  บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em ler o cupom inicial do dia  		  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  		     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCupIni() Class LJAIBM
	
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao	
	Local cUltCup 		:= Nil
	
	oRetorno := ::LeDadJorn()
	
	 // Caso o comando tenha sido executado com sucesso	
    If(oRetorno:cAcao <> ERRO)   
	 	
	 	cUltCup := ::GetNumCup():oRetorno
	 	oRetorno:oRetorno := str(strzero((val(cUltCup)+1),6, 0))

	 EndIf	

Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMFDData   บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel gerar a Leitura da fita detalhe por data บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPD1 (1 - dDtInicio) - Data inicial do periodo (ddmmaaaa). บฑฑ
ฑฑบ			 ณEXPD2 (2 - dDtFim) - Data final do periodo (ddmmaaaa).	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MFDData(dDtInicio, dDtFim) Class LJAIBM

	Local oParams 	:= Nil				//Objeto para passagem dos parametros
	Local cRetorno := ""				//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil				//Objeto que sera retornado pela funcao
	Local cArqOri  := ::cPathMF + "RELMFDDATA.MFD"  //Nome do arquivo origem
	Local cArqDes  := ::cPathMFD  		//Nome do arquivo destino (TXT)
    Local cDatInicio := DtoC(dDtInicio)				//Data Inicio
    Local cDatFim	 :=	DtoC(dDtFim)				//Data Final
	
	
	
	cDatInicio := Left(cDatInicio, 6) + "20" + Right(cDatInicio,2) 
	cDatInicio := StrTran(cDatInicio, "/", "") 
	cDatFim := Left(cDatFim, 6) + "20" + Right(cDatFim,2) 
	cDatFim := StrTran(cDatFim, "/","")
			
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_DownloadMFD", cArqOri, "1", cDatInicio, cDatFim, "01"})
	
    //Envia o comando    	                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)  
    
	::ConvArq( cArqOri, cArqDes, "0", "1", cDatInicio, cDatFim, "")   
	
	
 Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMFDCoo    บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel gerar a Leitura da fita detalhe por Coo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCooInicio) - Coo inicial						  บฑฑ                                  
ฑฑบ			 ณEXPC2 (2 - cCooFim) - Coo final							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ           
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MFDCoo(cCooInicio, cCooFim) Class LJAIBM                                  

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := ::cPathMF + "RELMFDCOO.MFD" //Nome do arquivo origem
	Local cArqDes  := ::cPathMFD 	  //Nome do arquivo destino (TXT)
			
 	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_DownloadMFD", cArqOri, "2", cCooInicio, cCooFim, "01"})
	
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)    
    
  	::ConvArq(cArqOri, cArqDes, "0", "2", cCooInicio, cCooFim, "")
    
Return oRetorno

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณTipoEData บAutor  ณVendas Clientes     บ Data ณ  21/07/10  			 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Data.บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cDatInicio) - Data inicial						 			 บฑฑ
ฑฑบ			 ณEXPC2 (2 - cDatFim) - Data final							 			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										 			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario) Class LJAIBM

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := space(200) //Nome do arquivo origem
	Local cArqDes  := ""	  //Nome do arquivo destino (TXT)
                    
	Default cBinario := "0"
	Default cPathArq := ""
		
	If cBinario <> "1"
		
		cDatInicio := Left(cDatInicio, 6) + "20" + Right(cDatInicio,2) 
		cDatInicio := StrTran(cDatInicio, "/", "") 
		cDatFim := Left(cDatFim, 6) + "20" + Right(cDatFim,2) 
		cDatFim := StrTran(cDatFim, "/","")
		
		If FindFunction("LjxGerPath")
		   	LjxGerPath( @cArqDes ) 
		  	cArqDes := cArqDes + "ARQ MFD\cotepe1704.txt" 
	  	EndIf
	
		oParams := ::PrepParam({IBM, "IBM_FI_GeraAtoCotepe1704", "1",cDatInicio, cDatFim, cArqOri})
	
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    
	 
	   	//Trata o retorno      
	   	//Obtem o Estado da impressora
	   	cArqOri :=  RTrim(oParams:Elements(3):cParametro) 

	   	
	   	::FechaPorta()
   	
   	Else
   		cArqOri  := "REGTIPOE.MFD" //Nome do arquivo origem
 		oParams := ::PrepParam({IBM, "IBM_FI_GeraAtoCotepe1704", "1",cDatInicio, cDatFim, cArqOri})
   		cArqOri  := ::cPathMF  + "REGTIPOE.MFD" //Nome do arquivo origem
   			
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)    
	      
		oParams := ::GetPathTipoE(cBinario)	
								
		cArqDes := AllTrim(oParams:oRetorno)    
		If Empty(cArqDes)
			cArqDes := "C:\Download.bin"
		EndIf   		
   	
   	EndIf
   	
   	If !Empty(cArqDes)
   		__CopyFile(cArqOri,cArqDes)
   	EndIf 
 	     	 
Return oRetorno  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณTipoECrz  บAutor  ณVendas Clientes     บ Data ณ  21/07/10  			 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel gerar arq. Tipo E Ato Cotepe 17/04 PAF-ECF por Crz. บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCrzInicio) - Crz inicial						 			 บฑฑ
ฑฑบ			 ณEXPC2 (2 - cCrzFim) - Crz final							 			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										 			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TipoECrz(cCrzInicio, cCrzFim, cBinario) Class LJAIBM

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := space(200) //Nome do arquivo origem
	Local cArqDes  := ""	  //Nome do arquivo destino (TXT)                   

	Default cBinario := "0"
	
	If cBinario <> "1"

		If FindFunction("LjxGerPath")
		   	LjxGerPath( @cArqDes ) 
		  	cArqDes := cArqDes + "ARQ MFD\cotepe1704.txt" 
	  	EndIf
	
		oParams := ::PrepParam({IBM, "IBM_FI_GeraAtoCotepe1704", "5",Left(cCrzInicio,4), Left(cCrzFim,4), cArqOri})
	
	    //Envia o comando    	
		cRetorno := ::EnviarCom(oParams)
		
		//Obtem o Estado da impressora
		cRetorno := ::ObterEst(cRetorno)
		
	    //Trata o retorno    
	    oRetorno := ::TratarRet(cRetorno)
	    
	
	    //Trata o retorno      
	    //Obtem o Estado da impressora
	    cArqOri :=  RTrim(oParams:Elements(3):cParametro)
	
	    If !Empty(cArqDes)
	    	__CopyFile(cArqOri,cArqDes)
	    EndIf
	    
	    ::FechaPorta()
	
	Else
		oRetorno := ::TratarRet("999")
	EndIf
     	 
    

Return oRetorno  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConvArq   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel gerar a Leitura da fita detalhe por Coo  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cCooInicio) - Coo inicial  					  บฑฑ                                  
ฑฑบ			 ณEXPC2 (2 - cCooFim) - Coo final		 			  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf							  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ           
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConvArq(cArqOri, cArqDes, cTpDado, cTprel, cPar1, cPar2, cUser) Class LJAIBM                                  

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao   
	
	//Prepara os parametros de envio
	oParams := ::PrepParam({IBM, "IBM_FI_FormatoDadosMFD", cArqOri, cArqDes, cTpDado, cTprel, cPar1, cPar2, cUser})

    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno



Method HexToDec(cHex) Class LJAIBM
local nDec := 0
local nMul := 0
local cDig
local nPos
Local xRet 
	
for nPos := Len(cHex) to 1 step -1
	cDig := Upper(SubStr(cHex,nPos,1))
	nDec += if(cDig $ "ABCDEF", Asc(cDig)-55, Val(cDig)) * (16^nMul)
	nMul ++
next
xRet := Int(nDec)
Return xRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณBuscaAliq บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura do cupom fiscal            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cTribut) - Tributacao          			   	  บฑฑ
ฑฑบ			 ณEXPN1 (2 - nAliquota) - Valor da aliquota   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method BuscaAliq(cTribut, nAliquota) Class LJAIBM
Local cRetorno  := ""     		//Retorno do metodo
Local nCount	 := 0				//Variavel de controle contador
Local oAliquota := Nil			//Objeto com os dados da aliquota

If SubsTr(cTribut,1,2) $ "FS|IS|NS"
	cRetorno := SubsTr(cTribut,1,2) + "1"	

ElseIf SubsTr(cTribut,1,1) == "F"
	//Substituido
	cRetorno := "FF"                                                       
	
ElseIf SubsTr(cTribut,1,1) == "I"
	//Isento	
	cRetorno := "II"
	
ElseIf SubsTr(cTribut,1,1) == "N"
    //Nao tributado
	cRetorno := "NN"	
	
Else
	For nCount := 1 To ::oAliquotas:Count()
		
		oAliquota := ::oAliquotas:Elements(nCount)
		
		If SubsTr(cTribut,1,1) == "T" 
   			//Tributado
   			If !oAliquota:lIss .AND. oAliquota:nAliquota == nAliquota
   				cRetorno := oAliquota:cIndice
   				Exit
   			EndIf
		Else
			//Servico
			If oAliquota:lIss .AND. oAliquota:nAliquota == nAliquota
   				cRetorno := oAliquota:cIndice
   				Exit
   			EndIf
		EndIf
	Next
EndIf

Return cRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLeituraX บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar uma Leitura X impressa.	  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method LeituraX() Class LJAIBM

	Local oParams 	:= Nil		//Objeto para passagem dos parametros
	Local cRetorno := ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil		//Objeto que sera retornado pela funcao
 
	//Prepara os parametros de envio                                                    
	oParams := ::PrepParam({IBM, "IBM_FI_LeituraX"})
	             
    //Envia o comando    	
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
 	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)
    
Return oRetorno	
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณInicVar   บAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em inicializar variaveis                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method InicVar() Class LJAIBM
                                                                            
	::oFormasVen := Nil

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGuardarPgtบAutor  ณVendas Clientes     บ Data ณ  20/06/11  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel pela abertura do cupom fiscal            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cForma) - Descricao da forma      			   	  บฑฑ
ฑฑบ			 ณEXPN1 (2 - nValor) - Valor da forma   				  	  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  			  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GuardarPgt(cForma, nValor) Class LJAIBM
    
	Local oForma := Nil								//Objeto do tipo LJCFormaEcf

	If ::oFormasVen == Nil
		//Instancia o objeto LJCFormasECF
		::oFormasVen := LJCFormasECF():New()	
	EndIf 
    
    //Instancia o objeto LJCFormaEcf
	oForma := LJCFormaEcf():New(Nil, cForma, Nil, nValor)
	//Adiciona a forma na colecao
	::oFormasVen:ADD(1, oForma, .T.)

Return Nil
                                          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLeCMC7	บAutor  ณVendas Clientes     บ Data ณ  10/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por efetuar a leitura do CMC7.			  บฑฑ
ฑฑบ          ณ								                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto 													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LeCMC7() Class LJAIBM

	Local oParams 	:= Nil			//Objeto para passagem dos parametros
	Local cRetorno 	:= ""			//String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno 	:= Nil			//Objeto que sera retornado pela funcao
   	Local cCMC7		:= Space(36)	//Valor do CMC7 lido
   	
	//Prepara os parametros de envio
	oParams := Self:PrepParam({IBM, "IBM_FI_LeituraCheque", cCMC7})
    //Envia o comando    	
	cRetorno := Self:EnviarCom(oParams)
    //Trata o retorno    
    oRetorno := Self:TratarRet(cRetorno)  
     // Caso o comando tenha sido executado com sucesso, retorna o codigo do registrador
    If(oRetorno:cAcao <> ERRO)    	
		oRetorno:oRetorno := substr(oParams:Elements(3):cParametro, 1, 36)
	EndIf	
	
    
Return oRetorno                                                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTratParam บAutor  ณVendas Clientes     บ Data ณ  20/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que trata os parametros a serem enviado.		 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cRetorno) - String com o conteudo analisado	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method TratParam(cRetorno) Class LJAIBM

	Local cRet := ""
	                          
	cRet := StrTran(cRetorno, Chr(13), Chr(10))
	
Return cRet    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCorrigRet บAutor  ณVendas Clientes     บ Data ณ  06/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que tira caracteres NULL e espacos dos retoronos 	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cRetorno) - String com o conteudo analisado	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNumerico													  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method CorrigRet(cRetorno) Class LJAIBM

	Local cRet := ""
	
	cRetorno := AllTrim(cRetorno)    
	
	cRetorno := StrTran(cRetorno, Chr(13), "")
	
	cRetorno := StrTran(cRetorno, Chr(10), "")
	
	cRet := LjAsc2Hex(cRetorno)

	cRet := StrTran(cRet, "00")
	
	cRet := LjHex2Asc(cRet)
	
	cRet := AllTrim(cRet)
	
Return cRet                                                


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณTrataTagsบAutor  ณVendas Clientes     บ Data ณ  17/06/13  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 													          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cMensagem) - Mensagem Promocional 			   	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณcMsg									  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method TrataTags( cMensagem ) Class LJAIBM
Local cMsg := ""

DEFAULT cMensagem := ""

cMsg := cMensagem

//Nao foi encontrado manual para tratar tags

cMsg := RemoveTags( cMsg )

Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetCodDllECF	บAutor  ณVendas Clientes     บ Data ณ  31/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a versใo de instalacao da versao atual do Software      บฑฑ
ฑฑบ          ณBแsico gravada na Memoria Fiscal do ECF.    			     	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                      	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum											    		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetCodDllECF() Class LJAIBM       

	Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ""	//Copia o valor da propriedade da classe
	
Return oRetorno
              
 
/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetNomeECF	บAutor  ณVendas Clientes     บ Data ณ  31/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBusca na DLL do Fabricante o nome composto pela: Marca + Modelo บฑฑ
ฑฑบ          ณ+ " - V. " + Versใo do Firmware                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                      	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum											    		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf											  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetNomeECF() Class LJAIBM       

    Local oRetorno	:= Nil			//Objeto que sera retornado pela funcao          
    Local cMarca	:= space(15)  	//Fabricante do ECF
    Local cModelo	:= space(20) 	//Modelo do ECF
    Local oRet		:= ::LeModelo()	//M้todo que retornarแ o modelo do ECF
    Local cFirmWare	:= ""			//Versใo do Firmware

    oRetorno := ::TratarRet("0000")
    
    oRetorno:oRetorno := ""	//Copia o valor da propriedade da classe


    
    If oRet <> NIL .AND. Valtype(oRet:oRetorno) == "C" 
    
	    cMarca := ::cFabric
	    cModelo :=  oRetorno:oRetorno 
	     

		oRet := ::LeFrmWare()
	    If oRet <> NIL 
	    	oRet := ::GetVerFirm() 
	    	cFirmWare := IIF(oRet <> NIL .AND. Valtype(oRet:oRetorno) == "C" , oRet:oRetorno, "")
	    EndIf	

		
		oRetorno:oRetorno := AllTrim(cMarca) + " " + ;
								AllTrim(cModelo) + " - V. "+;
								AllTrim(cFirmWare)

	
	EndIf

	 
	   
Return oRetorno

//LeModelo() - chamar m้todo
//lefabric() //LeDadImp() :cFabric
//LeFrmWare() - chamar m้todo                                            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPathMFBinบAutor  ณVendas Clientes     บ Data ณ  10/12/13 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel em retornar o caminho e nome do arquivo  บฑฑ
ฑฑบ          ณde Memoria Fiscal.		                   				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณnenhum													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetPathMFBin() Class LJAIBM

	Local oRetorno 	:= Nil			 //Objeto que sera retornado pela funcao
	
	//Trata o retorno    
    oRetorno := ::TratarRet("0000")
    
   	oRetorno:oRetorno := ::cPathMF + "mfiscal.bin" //Copia o valor da propriedade da classe
    

   	
Return oRetorno                                            



/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณDonwMF     บAutor  ณVendas Clientes     บ Data ณ  10//12/2013 			 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel gerar arq. MF Binแrio                              .บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cDatInicio) - Data inicial						 			 บฑฑ
ฑฑบ			 ณEXPC2 (2 - cDatFim) - Data final							 			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										 			 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method DownMF() Class LJAIBM

	Local oParams  := Nil			  //Objeto para passagem dos parametros
	Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	Local cArqOri  := "mfiscal.bin" //Nome do arquivo origem
			
 	//Prepara os parametros de envio
	oParams := ::PrepParam({BEMATECH, "IBM_FI_DownloadMF", cArqOri})
	
    //Envia o comando    	                       
	cRetorno := ::EnviarCom(oParams)
	
	//Obtem o Estado da impressora
	cRetorno := ::ObterEst(cRetorno)
	
    //Trata o retorno    
    oRetorno := ::TratarRet(cRetorno)    
    
Return oRetorno  


/* ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณRedZDado  บAutor  ณVendas Clientes     บ Data ณ  10//12/2013 			 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo responsavel por retornar os dados da Redu็ใo                   .บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                  	  			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cDatInicio) - Data inicial						 			 บฑฑ
ฑฑบ			 ณEXPC2 (2 - cDatFim) - Data final							 			 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto LJCRetornoEcf										 			 บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Method RedZDado() Class LJAIBM

	//Local oParams  := Nil			  //Objeto para passagem dos parametros
	//Local cRetorno := ""			  //String contendo o retorno da funcao que envia o comando para a serial
	Local oRetorno := Nil			  //Objeto que sera retornado pela funcao   
	//Local oRedZ := NIL			  	//Dados da ๚ltima redu็ใo
	
	
	oRetorno := ::TratarRet("0000")     
    
Return oRetorno

//--------------------------------------------------------
/*/{Protheus.doc} IdCliente
Abre o cupom fiscal
@param1		cCNPJ - Indica o cliente do cupom fiscal
@param2		cNome - Nome
@param3		cEnd - Endereco
@author  	Varejo
@version 	P11.8
@since   	28/04/2016
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
/*/
//--------------------------------------------------------
Method IdCliente(cCnpj, cNome, cEnd) Class LJAIBM
Local oRetorno := Nil		 //Objeto que sera retornado pela funcao	
oRetorno := ::TratarRet("0000")

Return oRetorno
