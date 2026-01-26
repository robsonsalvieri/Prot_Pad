#INCLUDE "MSOBJECT.CH" 

Function LOJA1301 ; Return  	// "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJIEcf           บAutor  ณVendas Clientes     บ Data ณ  05/05/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface que devera ser implementada nas classes dos ECF'S        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJIEcf
			
	Method AbrirPorta(cPorta)													//Abri a porta de comunicacao com o ECF
	Method FechaPorta(cPorta)													//Fechar a porta serial
	
	//Operacoes fiscais
	Method AbrirCF(cCnpj, cCliente, cEndereco)							   		//Abri o cupom fiscal
	Method CancelaCF()															//Cancela o cupom fiscal
	Method VenderItem(cCodigo	, cDescricao, cTribut	, nAliquota	, ;
	                  nQtde		, nVlUnit	, nDesconto	, cComplemen, ;
	                  cUniMed)													//Vende item no ecf
	Method CancItem(cItem		, cCodigo	, cDescricao, cTribut	, ;
					nAliquota	, nQtde		, nVlUnit	, nDesconto	, ;
	    			cUniMed)													//Cancela item no ecf
	Method DescItem(nValor)														//Aplica desconto no item do cupom
	Method DescTotal(nValor)													//Aplica desconto no total do cupom
	Method AcresItem(nValor)													//Aplica acrescimo no item do cupom
	Method AcresTotal(nValor)													//Aplica acrescimo no total do cupom
	Method EfetuaPgto(cForma, nValor)											//Efetua pagamento
	Method FecharCF(oMsgPromo)													//Fechar cupom fiscal    
	Method TotalizaCF()															//Totaliza o cupom    
    
	//Operacoes nao fiscais
	Method AbrirCNFV(cForma, nValor)											//Abri cupom nao fiscal vinculado
	Method FecharCNFV()															//Fecha cupom nao fiscal vinculado
	Method CancCNFV(cCupom, cForma, nValor)										//Cancela cupom nao fiscal vinculado		
	Method AbrirCNF(cCnpj, cCliente, cEndereco, cTotaliz, nValor)				//Abri cupom nao fiscal
	Method FecharCNF()															//Fecha cupom nao fiscal
	Method PgtoCNF(cForma, nValor)												//Efetua pagamento nao fiscal
	Method CancCNF()															//Cancela cupom nao fiscal
	Method AbrirRG(cRelatorio)													//Abri relatorio gerencial
	Method FecharRG()															//Fecha relatorio gerencial
	Method ImpTxtNF(oRelatorio, lLinha)											//Imprimi texto em cupom nao fiscal 
	Method Sangria(nValor, cForma)												//Efetua sangria de caixa	
	Method Suprimento(nValor, cForma)											//Efetua suprimentro de caixa (entrada de troco)
	Method EstNFiscVinc(cCPFCNPJ,cCliente,cEndereco,cMensagem,cCOOCCD)			//Efetua o estorno do comprovante de credito e debito
	
	//Relatorios fiscais
	Method LeituraX()															//Emite uma leituraX
	Method ReducaoZ()															//Emite uma leituraX
	Method AbrirDia()															//Emite leituraX de inicio de dia
   	Method MFData(dDtInicio, dDtFim, cTipo, cTipoArq)							//Leitura da memoria fiscal por data
   	Method MFReducao(cRedInicio, cRedInicio, cTipo, cTipoArq)					//Leitura da memoria fiscal por reducao
    Method MFDData(dDtInicio, dDtFim)											//Leitura da memoria fita detalhe por data
   	Method MFDCoo(cCooInicio, cCooFim)											//Leitura da memoria fita detalhe por Coo
   	Method TipoEData(cDatInicio, cDatFim, cPathArq, cBinario)								//Gera arquivo com os registro Tipo E Ato Cotepe 17/04 PAF-ECF por Data
   	Method TipoECrz(cCrzInicio, cCrzFim, cBinario)										//Gera arquivo com os registro Tipo E Ato Cotepe 17/04 PAF-ECF por Crz
    Method DownMF()																			//Gera arquivo da mem๓ria fiscal em formato binแrio
    Method RedZDado()	
    
	//Autenticacao e cheque
	Method Autenticar(cTexto)													//Autentica documento / cheque
	Method ImpCheque(cBanco	, nValor, cData 	, cFavorecid 	, ;
					 cCidade, cTexto, cExtenso	, cMoedaS 		, ;
					 cMoedaP)													//Imprime cheque
	Method LeCMC7() 															//Efetura a leitura do CMC7
	   					
	//Configuracoes
	Method ConfigPgto(cForma)								//Configura forma de pgto
	Method ConfTotNF(cIndice, cTotaliz)							   				//Configura totalizador nao fiscal	
	Method ConfigAliq(nAliq, cTipoIss)											//Configura aliquota		
	Method ConfVerao(cTipo)														//Configura a impressora para entrada / saida do horario de verao
	Method ConfRelGer(cIndice, cRelGer)											//Configura relatario gerencial
	
	//Gaveta
	Method AbrirGavet()															//Abri a gaveta
	
	//Informacoes ECF
	Method GetFabric()															//Retorna o fabricante do ecf 
   	Method GetModelo()															//Retorna o modelo do ecf
   	Method GetVerFirm()															//Retorna a versao do firmeware
   	Method GetCNPJ()															//Retorna o CNPJ
   	Method GetInsEst()															//Retorna a inscricao estadual
   	Method GetInsMun()															//Retorna a inscricao municipal
	Method GetNumLj()															//Retorna o numero da loja
	Method GetOper()															//Retorna o operador	
	Method GetRzSoc()															//Retorna a razao social
   	Method GetFantas()															//Retorna o nome fantasia
   	Method GetEnd1()															//Retorna o endereco 1
	Method GetEnd2()															//Retorna o endereco 2
    Method GetDadRedZ()															//Retorna os dados da reducao
	Method GetMFTXT()															//Retorna se a impressora gera memoria fiscal em txt    
   	Method GetMFSer()															//Retorna se a impressora gera memoria fiscal serial    
   	Method GetHrVerao()															//Retorna se a impresora esta em horario de verao
	Method GetAliq()															//Retorna as aliquotas cadastradas
	Method GetFormas()															//Retorna as formas cadastradas	
	Method GetTotNF()															//Retorna os totalizadores nao fiscais cadastrados
	Method GetRelGer()															//Retorna os relatorios gerenciais cadastrados
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
    Method GetVlSupr()															//Retorna o valor de suprimento
    Method GetItImp()															//Retorna se todos os itens foram impressos
    Method GetPosFunc()															//Se o ecf retorna o Subtotal e o numero de itens impressos no cupom fiscal.
    Method GetPathMFD()                                                         //Retorna o caminho e nome do arquivo de Memoria Fita Detalhe
    Method GetPathMF()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal
    Method GetPathMFBin()                                                          //Retorna o caminho e nome do arquivo de Memoria Fiscal Binแrio  
    Method GetPathTipoE(cBinario)														//Retorna o caminho e nome do arquivo de registro Tipo E Ato Cotepe 17/04 PAF-ECF
    Method BuscInfEcf()															//Busca as informacoes para o funcionamento do sistema (aliquotas, formas de pagto, numero serie, etc...) 
    Method GetCodDllECF()														//Busca na DLL do Fabricante o Codigo da Impressora Referente a TABELA NACIONAL DE CำDIGOS DE IDENTIFICAวรO DE ECF
	Method GetNomeECF()															//Busca na DLL do Fabricante o nome composto pela: Marca + Modelo + " - V. " + Versใo do Firmware
	Method IdCliente(cCNPJ, cNome, cEnd)
	Method DownloadMFD(cBinario,cTipo,cInicio,cFinal)
EndClass
