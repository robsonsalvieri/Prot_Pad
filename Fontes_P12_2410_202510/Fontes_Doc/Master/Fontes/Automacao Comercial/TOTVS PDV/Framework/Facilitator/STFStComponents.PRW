#INCLUDE "STFStComponents.ch"
#INCLUDE "Protheus.ch"   
#INCLUDE "AP5MAIL.CH"   
#INCLUDE "STFSTCFG.CH" 
#INCLUDE "STFSTCOMPONENTS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStComponentes
Retorna os processos da árvore cadastrados
@param nTamSX3  Tamanho do nó		
@version P11.8
@since   26/04/2013
@return  aData := Array com os nós
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STFStComponentes(nTamSX3)  
Local aData := {}      //Retorno da Função    
Local nUltimo := 42 //ultimo no

DEFAULT nTamSX3 := TamSX3("MF7_NODE")[1] //Tamanho do nó

     
		              //1    //2                //3                //4  //5      //6   //7    //8    //9 //10 //11 //12 //13
	aAdd(aData, {"",StrZero(1, nTamSX3) , STR0001, 1, "1/2/3/4", .T., .F., space(1),    ,  , .F., .F.,,}) //"Configurador Loja"
		
		aAdd(aData, {StrZero(1, nTamSX3), StrZero(41, nTamSX3), STR0183, 1, "3",.T., .F., space(1),   ,  , .F., .F.,,})  //"Cor da Janela de Atendimento"

		
		aAdd(aData, {StrZero(1, nTamSX3), StrZero(2, nTamSX3), STR0002, 2, "1/2/3",.T., .F., space(1),   ,  , .F., .F.,,})  //"Estação"
			
			aAdd(aData, {StrZero(2, nTamSX3), StrZero(5, nTamSX3), STR0003, 1, "1/2/3", .T., .F., space(1),   ,   , .T., .T.,,})  //"Periféricos"

				aAdd(aData, {StrZero(5, nTamSX3), StrZero(19, nTamSX3), STR0004, 1, "1/2", .T., .F., space(1),  ,   , .T., .T.,,})  //"Comunicação DLL"

				aAdd(aData, {StrZero(5, nTamSX3), StrZero(6, nTamSX3), STR0005, 2, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,,})  //"Impressora Fiscal"

				aAdd(aData, {StrZero(5, nTamSX3), StrZero(13, nTamSX3), STR0006, 3, "1/2/3", .T., .F., space(1),   ,   , .T., .T.,,})  //"Impressora de Cupom"

				aAdd(aData, {StrZero(5, nTamSX3), StrZero(14, nTamSX3), STR0007, 4, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,"Lj121WIni(, , ,cLG_CODIGO)",})  //"Pin-Pad"
				
				aAdd(aData, {StrZero(5, nTamSX3), StrZero(7, nTamSX3), STR0008, 5, "1/2/3", .T., .F., space(1),   ,   , .T., .T.,,})  //"Balança"
				aAdd(aData, {StrZero(5, nTamSX3), StrZero(8, nTamSX3), STR0009, 6, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,,})  //"Leitores Opticos"
				aAdd(aData, {StrZero(5, nTamSX3), StrZero(09, nTamSX3), STR0010, 7, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,,})  //"Gaveta"
				aAdd(aData, {StrZero(5, nTamSX3), StrZero(10, nTamSX3), STR0011, 8, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,,})  //"Impressora de Cheques"
				aAdd(aData, {StrZero(5, nTamSX3), StrZero(11, nTamSX3), STR0012, 9, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,,})  //"CMC7"
				aAdd(aData, {StrZero(5, nTamSX3), StrZero(18, nTamSX3), STR0013, 10, "1/2", .T., .F., space(1),  ,   , .T., .T.,,})  //"Display"



			aAdd(aData, {StrZero(2, nTamSX3), StrZero(4, nTamSX3), STR0014, 2, , .T., .F., space(1), ,   , .T., .T.,,})  //"Integrações"
 
				aAdd(aData, {StrZero(4, nTamSX3), StrZero(15, nTamSX3), STR0015, 2,"1/2" , .T., .F., space(1), ,   , .T., .T.,,"LjGrvJob(cIdAmb, aDadosL, cLG_CODIGO)"})  //"Back Office/PDV"
				
				aAdd(aData, {StrZero(4, nTamSX3), StrZero(16, nTamSX3), "Cheque-Pre.com", 2,"1/2" , .T., .F., space(1), ,   , .T., .T.,,}) 
				
				aAdd(aData, {StrZero(4, nTamSX3), StrZero(17, nTamSX3), "Outros", 2, "1/2/3", .T., .F., space(1), ,   , .T., .T.,,}) 
                
	   		aAdd(aData, {StrZero(2, nTamSX3), StrZero(3, nTamSX3), STR0016, 3, "1/2/3", .T., .F., space(1),  ,   , .T., .T.,,})  //"Número de Série"


			aAdd(aData, {StrZero(2, nTamSX3), StrZero(12, nTamSX3), STR0017, 3, "1/2/3", .T., .F.,, , , .T., .T.,,})  //"TEF - Transferência Eletrônica de Fundos"

 
					aAdd(aData, {StrZero(12, nTamSX3), StrZero(22, nTamSX3), STR0018, 1, "1/2/3", .T., .F.,"ValidaTEF20(__NODE_LOG)", , , .T., .T.,"Lj121WIni(, , ,cLG_CODIGO),GravaTEF20(cIdAmb)",})  //"Cadastro"

					aAdd(aData, {StrZero(12, nTamSX3), StrZero(23, nTamSX3), STR0019, 2, "1/2/3", .T., .F.,, , , .T., .T.,,})  //"Parametros"
		
		aAdd(aData, {StrZero(1, nTamSX3), StrZero(20, nTamSX3), STR0020, 3, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Caixa"

 		aAdd(aData, {StrZero(1, nTamSX3), StrZero(37, nTamSX3), STR0021, 4,"1/2/4" ,.T., .F., space(1),   ,  , .F., .F.,,}) 		 //"Cenário de Vendas"
  			
  			aAdd(aData, {StrZero(38, nTamSX3), StrZero(38, nTamSX3), STR0022, 2, ,.T., .F., space(1),   ,  , .F., .F.,,}) 		 //"Multinegociação"

				
		aAdd(aData, {StrZero(1, nTamSX3), StrZero(29, nTamSX3), STR0023, 5, "1",.T., .F., space(1),   ,  , .F., .F.,,})  //"Orçamento"

 		aAdd(aData, {StrZero(1, nTamSX3), StrZero(33, nTamSX3), STR0024, 6, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Venda"

 	 		aAdd(aData, {StrZero(33, nTamSX3), StrZero(34, nTamSX3), STR0025, 1, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Item"

  	 		aAdd(aData, {StrZero(33, nTamSX3), StrZero(35, nTamSX3), STR0026, 2, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Desconto/Acréscimo"

  	 		aAdd(aData, {StrZero(33, nTamSX3), StrZero(36, nTamSX3), STR0027, 3, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Parcelas"
 
		aAdd(aData, {StrZero(1, nTamSX3), StrZero(24, nTamSX3), STR0028, 7, "1",.T., .F., space(1),   ,  , .F., .F.,,})  //"Pedido de Vendas"
 
		aAdd(aData, {StrZero(1, nTamSX3), StrZero(27, nTamSX3), STR0029, 8, "1",.T., .F., space(1),   ,  , .F., .F.,,})  //"Nota sobre Cupom"

		aAdd(aData, {StrZero(1, nTamSX3), StrZero(21, nTamSX3), STR0030, 9, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Recebimento de Títulos"

		aAdd(aData, {StrZero(1, nTamSX3), StrZero(26, nTamSX3), STR0031, 10, "1/2/3",.T., .F., space(1),   ,  , .F., .F.,,})  //"Garantia Estendida"
 		
 		aAdd(aData, {StrZero(1, nTamSX3), StrZero(28, nTamSX3), STR0032, 11, "1",.T., .F., space(1),   ,  , .F., .F.,,})  //"Troca Devolução"

		aAdd(aData, {StrZero(1, nTamSX3), StrZero(25, nTamSX3), STR0033, 12, "1",.T., .F., space(1),   ,  , .F., .F.,,})  //"Nota de Crédito"

 		aAdd(aData, {StrZero(1, nTamSX3), StrZero(30, nTamSX3), STR0034, 13, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Conferência e Transferência de Caixa"

			aAdd(aData, {StrZero(30, nTamSX3), StrZero(31, nTamSX3), STR0019, 1, ,.T., .F., space(1),   ,  , .F., .F.,,})  //"Parametros"

			aAdd(aData, {StrZero(30, nTamSX3), StrZero(32, nTamSX3), STR0035, 2, "1",.T., .F., space(1),   ,  , .F., .F.,,})  //"Ações Conferência Fechamento de Caixa"

 		aAdd(aData, {StrZero(1, nTamSX3), StrZero(39, nTamSX3), STR0036, 14,"1" ,.T., .F., space(1),   ,  , .F., .F.,,})  //"PAF-ECF"
				aAdd(aData, {StrZero(39, nTamSX3), StrZero(40, nTamSX3), STR0037, 2,"1" , .T., .F., space(1), ,   , .T., .T.,,"LjGrvJob(cIdAmb, aDadosL, cLG_CODIGO, 'LOJA1115','LOJA1115')"})  //"PAF-ECF"

 		aAdd(aData, {StrZero(1, nTamSX3), StrZero(42, nTamSX3), STR0185, 14,"1" ,.T., .F., space(1),   ,  , .F., .F.,,"LjGrvJob(cIdAmb,aDadosL,'','Integracao_ERP','LJGRVBATCH')"})  //"Integração ERP"
		
Return aData      
//-------------------------------------------------------------------
/*/{Protheus.doc} STFStItens
Retorna os componentes dos processos da árvore cadastrados
@param nTamSX3  Tamanho do nó		
@param nTamID  Tamanho do item
@version P11.8
@since   26/04/2013
@return  aData := Array com os componentes
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STFStItensComponents(nTamSX3, nTamID) 
	Local aComps := {} //array de componentes  
	Local nConta  := 0 //Contador dos itens
		
	DEFAULT nTamSX3 := TamSX3("MF7_NODE")[1] //Tamanho do nó
	DEFAULT nTamID := TamSX3("MF8_ID")[1]   //Tamanho do Id  
	


	aAdd(aComps, { StrZero(03, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_SERIE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| !Empty(This) }" ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(03, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TAMSER",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 
 
	aAdd(aComps, { StrZero(03, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJSRAUT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  
				   
	aAdd(aComps, { StrZero(03, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_NSRDISP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    "{ |This| This > 0 }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   ,;
				   } ) 
				   
		aAdd(aComps, { StrZero(03, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCTSER",;  //_COMP_NAME 05        //Nome do componente
				   STR0181,;  //_COMP_TITLE 06       //titulo do componente   //"Gera número de série a cada alteração de:"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'0'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| Val(This) > 0 }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0182 , ; // _COMP_LIST 15 // lISTA DE vALORES   //"0=Estouro COO;1=CRO;2=CRO+COO"
				   "N",;
				   ,;
				   } )
     
    nConta := 0
 	aAdd(aComps, { StrZero(19, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_AUTOCOM",;  //_COMP_NAME 05        //Nome do componente
				   STR0038,;  //_COMP_TITLE 06       //titulo do componente //"Forma de Comunicação da DLL com os equipamentos"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| This >= 0 .AND. This <= 2}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   1, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 
    nConta := 0
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IMPFISC",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LIF(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 

	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTIF",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PDV",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )



	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_MSGCUP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_LARGCOL",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "40",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    "{|This|  This >= 35 .AND. This <= 60  }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_JOURNAL",;  //_COMP_NAME 05        //Nome do componente
				   STR0039,;  //_COMP_TITLE 06       //titulo do componente //"Path e arquivo para gravação do cupom"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "POR|EUA",;
				   } )
 
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJFISMS",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   STR0040,;  //_COMP_DEFAULT 08     //valor default do componente //"'Obrigado! Volte Sempre'"
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   , ;
				   ,;
				   } )


	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJNSECF",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )
 
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJGRVVB",;  //_COMP_NAME 05        //Nome do componente
				   STR0041,;  //_COMP_TITLE 06       //titulo do componente //"Habilita a validação da venda bruta, através do arquivo criptografado conforme Anexo 09 do RICMS01 - Santa Catarina"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )

 
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_ALIQISS",;  //_COMP_NAME 05        //Nome do componente
				   STR0042,;  //_COMP_TITLE 06       //titulo do componente //"Alíquota do ISS em caso de prestação de serviços, usando percentuais definidos pelo usuário."
				   ,;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   ,;
				   } )
 
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPAGTO",;  //_COMP_NAME 05        //Nome do componente
				   STR0043,;  //_COMP_TITLE 06       //titulo do componente //"Indica a origem da descrição da forma de pagamento utilizada pelo ECF."
				   ,;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '1-Tabela 24 do SX5', '2=Cadastro de Adm Financeiras'} } ", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   ,;
				   } )


	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FRTQTTK",;  //_COMP_NAME 05        //Nome do componente
				   STR0044,;  //_COMP_TITLE 06       //titulo do componente //"Quantidade de cópias do cupom a serem impressas."
				   ,;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   "ANG/EQU/HAI/MEX/PTG",;
				   } )
	
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_SCRCUP",;  //_COMP_NAME 05        //Nome do componente
				   STR0045,;  //_COMP_TITLE 06       //titulo do componente //"Arquivo com script de impressão do cupom de venda"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'BOLETO'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   ,;
				   } )
				   
	aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJQTTK",;  //_COMP_NAME 05        //Nome do componente
				   STR0046,;  //_COMP_TITLE 06       //titulo do componente //"Quantidade de segunda via"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   "ARG",;
				   } )    
				   
		aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_IMPTIFA",;  //_COMP_NAME 05        //Nome do componente
				   STR0047,;  //_COMP_TITLE 06       //titulo do componente //"Impresssora imprime ticket e fatura?"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   "ARG",;
				   } )      
				   
		aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_IMPSIVA",;  //_COMP_NAME 05        //Nome do componente
				   STR0048,;  //_COMP_TITLE 06       //titulo do componente //"Codigo dos impostos que somam no IVA"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'IVA|'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } ) 
				   				   
			aAdd(aComps, { StrZero(06, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LIMFACT",;  //_COMP_NAME 05        //Nome do componente
				   STR0049,;  //_COMP_TITLE 06       //titulo do componente //"Limite para impressão de ticket/fatura e conversão para moedas estrangeiras."
				   ,;  //_COMP_F3 07          //f3 do componente
				   "10000",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   "ARG",;
				   } )
    nConta := 0
	aAdd(aComps, { StrZero(13, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IMPCUP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LINF(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(13, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTICP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 
    nConta := 0
	aAdd(aComps, { StrZero(14, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PINPAD",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LPinPad(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(14, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTPAD",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(14, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PADMSG",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

    nConta := 0
	aAdd(aComps, { StrZero(07, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_BALANCA",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LBal(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(07, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DIRBAL",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(07, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTBAL",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				   
				   
	aAdd(aComps, { StrZero(07, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TIMEBAL",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| Empty(This) .OR. Val(This) > 0  } ",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )						
	nConta := 0					
	aAdd(aComps, { StrZero(08, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_OPTICO",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LLOpt(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(08, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTOPT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 
    nConta := 0
	aAdd(aComps, { StrZero(09, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_GAVETA",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LGav(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(09, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTGAV",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','LPT1','LPT2','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(09, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_GAVSAT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


    nConta := 0
	aAdd(aComps, { StrZero(10, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IMPCHQ",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LChq(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(10, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTCHQ",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	nConta := 0
	aAdd(aComps, { StrZero(11, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CMC7",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LCMC7(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(11, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTMC7",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 

	aAdd(aComps, { StrZero(11, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CMC7DIR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0177, ; // _COMP_LIST 15 // lISTA DE vALORES   //"{ || { '','1=Sim','2=Nao'}} "
				   ,;
				   ,;
				   } )
	
	nConta := 0
	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_ROTINA,;  // _COMP_TYPE  04       //tipo do componente
				   "STFStTEF20(M->oPanel2)",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )	


	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TIPTEF",;  //_COMP_NAME 05        //Nome do componente
				   STR0050,;  //_COMP_TITLE 06       //titulo do componente //"Tipo do TEF"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| IIF(cPaisLoc == 'MEX', This == '1' .OR. This == '7', .T. )}" ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{||{ " + STR0051 + "," + STR0052+ "," + STR0053 + "," + STR0054 + "," + STR0055 + "," + STR0056 + "," + STR0057 + "}}", ; // _COMP_LIST 15 // "'1=Nao Utiliza'"#"'2=Dedicado sem cliente'"# "'3=Sitef Modular'"#"'4=Discado'"#"'5=Lote'"#"'6=CliSitef'"#"'7=Centro de Pagos'"
				   ,;
				   "BRA/MEX",;
				   } ) 
 
 
 

 
	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IMPTEF",;  //_COMP_NAME 05        //Nome do componente
				   STR0058,;  //_COMP_TITLE 06       //titulo do componente //"Comprovante Impressora"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "" ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "N="+STR0059+";F="+STR0060+";C="+STR0061, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"Não Imprime"###"Fiscal"###"Cupom"
				   ,;
				   "BRA",;
				   } )  
				   
		aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFVIAS",;  //_COMP_NAME 05        //Nome do componente
				   STR0062,;  //_COMP_TITLE 06       //titulo do componente //"Numero de vias"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |this| This >= 0 .AND. This <= 9 } " ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   1, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   "BRA",;
				   } )   


 	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_EMPTEF",;  //_COMP_NAME 05        //Nome do componente
				   STR0050,;  //_COMP_TITLE 06       //titulo do componente //"Tipo do TEF"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   8, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 
				   
		aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TERMTEF",;  //_COMP_NAME 05        //Nome do componente
				   STR0063,;  //_COMP_TITLE 06       //titulo do componente //"Terminal"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   3, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   "BRA",;
				   } ) 

		aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_REDES",;  //_COMP_NAME 05        //Nome do componente
				   STR0064,;  //_COMP_TITLE 06       //titulo do componente //"Recarga de Celular"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   "BRA",;
				   3} ) 
  

		aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IMPTEFC",;  //_COMP_NAME 05        //Nome do componente
				   STR0065,;  //_COMP_TITLE 06       //titulo do componente //"Impressão de Consulta"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   3, ; //_COMP_LEN   14 
				   "S=" + STR0066 + ";N="+STR0067, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"Sim;"###"Não"
				   ,;
				   "BRA",;
				   } ) 

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0068,;  //_COMP_TITLE 06       //titulo do componente //"Consulta SERASA / As.Comercial"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=" + STR0066 + ";N="+STR0067, ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   1} )

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0069,;  //_COMP_TITLE 06       //titulo do componente //"Consulta TeleCheque"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=" + STR0066 + ";N="+STR0067, ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   2} )


	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0071,;  //_COMP_TITLE 06       //titulo do componente //"Consulta Cheque TecBan"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=Sim;N=Não", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   3} ) 
				   

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0072,;  //_COMP_TITLE 06       //titulo do componente //"Consulta GDC"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=Sim;N=Não", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   4} )  
				   

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0073,;  //_COMP_TITLE 06       //titulo do componente //"Consulta SPC/TeleCheque"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=Sim;N=Não", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   5} )
 
 	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0074,;  //_COMP_TITLE 06       //titulo do componente //"Consulta AVS"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0070, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"S=Sim;N=Não"
				   ,;
				   "BRA",;
				   6} )

 	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0075,;  //_COMP_TITLE 06       //titulo do componente //"Consulta Cheque Papel Tecban"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=Sim;N=Não", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   7} ) 
				   

 	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TEFCONS",;  //_COMP_NAME 05        //Nome do componente
				   STR0076,;  //_COMP_TITLE 06       //titulo do componente //"Consulta Cheque Redecard"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0070, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"S=Sim;N=Não"
				   ,;
				   "BRA",;
				   8} )
				   

 	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DIRTTX",;  //_COMP_NAME 05        //Nome do componente
				   STR0077,;  //_COMP_TITLE 06       //titulo do componente //"Diretório de Envio dos Arquivos"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    "{ |This| Empty(This) .OR. Right(AllTrim(This),1) $ '\' }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )
 
 
  	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DIRTRX",;  //_COMP_NAME 05        //Nome do componente
				   STR0078,;  //_COMP_TITLE 06       //titulo do componente //"Diretório de Retorno dos Arquivos"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    "{ |This| Empty(This) .OR. Right(AllTrim(This),1) $ '\' }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 
                         
  	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IPSITEF",;  //_COMP_NAME 05        //Nome do componente
				   STR0079,;  //_COMP_TITLE 06       //titulo do componente //"IP do Servidor Sitef"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )    
				          
				   
  	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_IPSITEF",;  //_COMP_NAME 05        //Nome do componente
				   STR0079,;  //_COMP_TITLE 06       //titulo do componente //"IP do Servidor Sitef"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )    


//MEXICO 
	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_COMPANY",;  //_COMP_NAME 05        //Nome do componente
				   STR0080,;  //_COMP_TITLE 06       //titulo do componente //"Companhia"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } ) 
   

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_BRANCH",;  //_COMP_NAME 05        //Nome do componente
				   STR0081,;  //_COMP_TITLE 06       //titulo do componente //"Unid Negócio CP"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } ) 
` 				   
	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_COUNTRY",;  //_COMP_NAME 05        //Nome do componente
				   STR0082,;  //_COMP_TITLE 06       //titulo do componente //"Nome país"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } ) 

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_MERCHAN",;  //_COMP_NAME 05        //Nome do componente
				   STR0083,;  //_COMP_TITLE 06       //titulo do componente //"Num Afiliação"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } ) 
    
				   
	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_OPTYPE",;  //_COMP_NAME 05        //Nome do componente
				   STR0084,;  //_COMP_TITLE 06       //titulo do componente //"Tipo de Operação"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } ) 

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CURRENC",;  //_COMP_NAME 05        //Nome do componente
				   STR0085,;  //_COMP_TITLE 06       //titulo do componente //"Moeda"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { " + STR0086 + " , " + STR0087 + "}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //'1=MXN -Pagamento em Peso'#'2=USD - Pagamento em dólar'
				   ,;
				   "MEX",;
				   } )       

	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_USERCP",;  //_COMP_NAME 05        //Nome do componente
				   STR0088,;  //_COMP_TITLE 06       //titulo do componente //"Usuário Centro de Pagos"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } )
				   			   
	aAdd(aComps, { StrZero(22, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_SETURL",;  //_COMP_NAME 05        //Nome do componente
				   STR0089,;  //_COMP_TITLE 06       //titulo do componente //"URL Servidor"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'http://'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "MEX",;
				   } )				   	 


    nConta := 0
	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPRSIT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'MS'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )    
				   	
	
					        
  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_TEFPEND",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'0'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| Val(This) >= 0 .AND. Val(This) <= 2}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )    
				   				   
				   
				   
				   
  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_TEFMULT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )    				   
                                
  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_TEFMILH",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 
 
  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_MESFECH",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'S'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "S=" + STR0066 + ";N="+STR0067, ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 


  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJATVGP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 

  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_NATTEF",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'TEF'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 

  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_TEFMANU",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 


  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJLECB",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 
 
  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCUPRE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )   
				   

  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPREC",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "SB1",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 

  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FTTEFLI",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "8",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |this| this > 0 .and. this < 99 }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 


  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FTTEFGU",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )    
				   

  	aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCUP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "8",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |this| this > 0 .and. this < 99 }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } ) 

				   

		aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Totalizador",;  //_COMP_NAME 05        //Nome do componente
				   "Totalizador do Comprovante Não-Fiscal de Recarga de Celular Sitef",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Recarga Celular",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  


		aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Totalizador",;  //_COMP_NAME 05        //Nome do componente
				   "Totalizador do Comprovante Não-Fiscal de Transaçã TEF",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Comprovante TEF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

		aAdd(aComps, { StrZero(23, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "FormaPgto",;  //_COMP_NAME 05        //Nome do componente
				   "Forma de Pagamento do Comprovante Fiscal da Recarga de Celular",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'R$'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Recarga Celular",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  				   

    nConta := 0
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_RPCSRV",;  //_COMP_NAME 05        //Nome do componente
				   "IP Conexão Servidor",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_RPCPORT",;  //_COMP_NAME 05        //Nome do componente
				   "Porta de Conexão do Servidor",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_RPCENV",;  //_COMP_NAME 05        //Nome do componente
				   "Ambiente de Conexão do Servidor",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  
				   
		aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_RPCEMP",;  //_COMP_NAME 05        //Nome do componente
				   "Empresa de Conexão do Servidor",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  
				   
		aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_RPCFIL",;  //_COMP_NAME 05        //Nome do componente
				   "Filial de Conexão do Servidor",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )     
				   				    				   
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_RPCINT",;  //_COMP_NAME 05        //Nome do componente
				   "Intervalo de  Conexão do Servidor",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "5",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| This >= 0} ",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   ,;
				   } )
 
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Environment",;  //_COMP_NAME 05        //Nome do componente
				   "Nome do Ambiente Local",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "APFrontLoja",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   20, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	

	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Parm1",;  //_COMP_NAME 05        //Nome do componente
				   "Empresa do Ambiente Local",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "APFrontLoja",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	 
				   
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Parm2",;  //_COMP_NAME 05        //Nome do componente
				   "Filial do Ambiente Local",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "APFrontLoja",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   FWGETTAMFILIAL, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	
				   

				   
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJOFFLN",;  //_COMP_NAME 05        //Nome do componente
				   "Loja Off-Line?",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )  
				   
				   
	aAdd(aComps, { StrZero(15, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_WSSRVMT",;  //_COMP_NAME 05        //Nome do componente
				   "Endereço do Server da Retaguarda http://",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				    

    nConta := 0
	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_INTCNS",;  //_COMP_NAME 05        //Nome do componente
				   STR0090,;  //_COMP_TITLE 06       //titulo do componente //"Habilita Cheque-pré"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DIRORI",;  //_COMP_NAME 05        //Nome do componente
				   STR0091,;  //_COMP_TITLE 06       //titulo do componente //"Diretório de Origem"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DIRDES",;  //_COMP_NAME 05        //Nome do componente
				   STR0092,;  //_COMP_TITLE 06       //titulo do componente //"Diretório de Destino"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )     
				   

	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DIRDES",;  //_COMP_NAME 05        //Nome do componente
				   STR0093,;  //_COMP_TITLE 06       //titulo do componente //"Diretório do Executável"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_REDECNS",;  //_COMP_NAME 05        //Nome do componente
				   STR0094,;  //_COMP_TITLE 06       //titulo do componente //"Código da Rede"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_LOJACNS",;  //_COMP_NAME 05        //Nome do componente
				   STR0095,;  //_COMP_TITLE 06       //titulo do componente //"Código da Loja"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )



	aAdd(aComps, { StrZero(16, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CTCNS",;  //_COMP_NAME 05        //Nome do componente
				   STR0096,;  //_COMP_TITLE 06       //titulo do componente //"Código do Contrato"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				   
				   
    nConta := 0
	aAdd(aComps, { StrZero(17, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CRDXINT",;  //_COMP_NAME 05        //Nome do componente
				   STR0097,;  //_COMP_TITLE 06       //titulo do componente //"Integrar com o SigaCRD?"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				   
	aAdd(aComps, { StrZero(17, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CRDIMP",;  //_COMP_NAME 05        //Nome do componente
				   STR0098,;  //_COMP_TITLE 06       //titulo do componente //"Comprovante SigaCRD"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				   		
	aAdd(aComps, { StrZero(17, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_CRDVIAS",;  //_COMP_NAME 05        //Nome do componente
				   STR0099,;  //_COMP_TITLE 06       //titulo do componente //"Número de Vias"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )				   		


	aAdd(aComps, { StrZero(17, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_WSSRV",;  //_COMP_NAME 05        //Nome do componente
				   STR0100,;  //_COMP_TITLE 06       //titulo do componente //"Ip e Porta do WebService Fornecedor"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

    nConta := 0
	aAdd(aComps, { StrZero(18, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DISPLAY",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LDis(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(18, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTDISP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(18, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_DISPTOR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || Lj121LTDis(, cIdAmb == '3')}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

 

	aAdd(aComps, { StrZero(18, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_PORTTOR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "{ || { '','COM1','COM2', 'COM3', 'COM4', 'COM5', 'COM6'}}", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
			


	aAdd(aComps, { StrZero(18, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TIPTELA",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0101, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=DeskTop;2=Touch Screen"
				   ,;
				   ,;
				   } )	   
				   
	aAdd(aComps, { StrZero(18, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_CAMPO,;  // _COMP_TYPE  04       //tipo do componente
				   "LG_TOUCH",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   "SLG",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   01,;  //_COMP_INDEX 10        //indice da tabela 
				   "xFilial() + M->cLG_CODIGO",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "Waytec", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )			
 
	nConta := 0
	aAdd(aComps, { StrZero(20, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_ROTINA,;  // _COMP_TYPE  04       //tipo do componente
				   "Lj120Alt()",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )		
	nConta := 0	 
	
	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRECEB",;  //_COMP_NAME 05        //Nome do componente
				   STR0103,;  //_COMP_TITLE 06       //titulo do componente //"Tipo de utilizacao da funcao de recebimentos LjReceb"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   1, ; //_COMP_LEN   14 
				   STR0178, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Financeiro;2=G.E.;3=Fidelizacao;4=EMS"
				   ,;
				   ,;
				   } )	
		
	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRECFI",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )	

	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_VLBXREC",;  //_COMP_NAME 05        //Nome do componente
				   STR0104,;  //_COMP_TITLE 06       //titulo do componente //"Baixar os tít menor que os valrs de multa, corr., jurs e desc?"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   1, ; //_COMP_LEN   14 
				   STR0179, ; // _COMP_LIST 15 // lISTA DE vALORES   //"1=Permite;2=Avisa;2=Não"
				   ,;
				   ,;
				   } )	

	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTPREC",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'FI'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )	


	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJICMJR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJMULTA",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJJUROS",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJFSEMA",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'0'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
					"{ |This| Val(This) >= 0 .AND. Val(This) <= 3 }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )   
				   
				   
	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCALJM",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
					,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 
		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRCABT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
					,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJSITTI",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
					,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  
				   
		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CRDLCAR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
					,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 
	
			aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_RECVIAS",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "2",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| This >= 0 }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
	

			aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCTRET",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'RI|RG|RB|RS'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )


			aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRMPAG",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'LJPAGLOC'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )   
				   



	aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_NATRECE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
				   
		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CRDAUT",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
	

		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTITGR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'REC'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   TAMSX3("E1_PREFIXO")[1], ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  
				   

		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJOPEST",;  //_COMP_NAME 05        //Nome do componente
				   STR0105,;  //_COMP_TITLE 06       //titulo do componente //"Habilita a pergunta sobre estorno de compensação no Estorno de Baixa"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   1, ; //_COMP_LEN   14 
				   STR0106, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Sempre estorna;2=Pergunta se estorna;3=Nao estorna as compensações"
				   ,;
				   ,;
				   } )  
				   

		aAdd(aComps, { StrZero(21, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Totalizadores",;  //_COMP_NAME 05        //Nome do componente
				   STR0107,;  //_COMP_TITLE 06       //titulo do componente //"Totalizador do Comprovante Não-Fiscal do Recebimento"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
				   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Recebimento Titulos",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  
				   

    nConta := 0
    aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_ROTINA,;  // _COMP_TYPE  04       //tipo do componente
				   "Loja080()",;  //_COMP_NAME 05        //Nome do componente
				   STR0108,;  //_COMP_TITLE 06       //titulo do componente //"Cadastro de Loja"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				   

    aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPEDVE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )    
   
			
  aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				 StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTESPE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "SF4",;  //_COMP_F3 07          //f3 do componente
				   "'501'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )    
				   
  aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				 StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCONDP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "SE4",;  //_COMP_F3 07          //f3 do componente
				   "'001'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )    	
				   
				   
  aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTPPED",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   1, ; //_COMP_LEN   14 
				   "{ || RetLTPPed() } ", ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )  		
								
  
  aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				 StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LOJAPED",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'PED'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )   
				   
  aAdd(aComps, { StrZero(24, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				 StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_USACRED",;  //_COMP_NAME 05        //Nome do componente
				   STR0109,;  //_COMP_TITLE 06       //titulo do componente //"1 posicao NCC troca por valor a menor, 2 posicao exibe tela para selecao da NCC, 3 posicao utiliza saldo NCC resumo de caixa"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'SS'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| Left(AllTrim(this),1) $ 'SN'  .AND. Substr(AllTrim(this),2, 1)  .AND. Right(AllTrim(this),1) $ 'SN' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
				   
				   
  nConta := 0
  aAdd(aComps, { StrZero(25, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCPNCC",;  //_COMP_NAME 05        //Nome do componente
				   STR0110,;  //_COMP_TITLE 06       //titulo do componente //"Tratamento para compensacao de NCC"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0111, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Compens Atual;2=Nova Compens;3=Total;4=Com troco"
				   ,;
				   ,;
				   } )    
				   
  nConta := 0
  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTPGAR",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "02",;  //_COMP_F3 07          //f3 do componente
				   "'GE'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )    
   
  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJDESGE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				  	,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )   
				   
  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJIMPGF",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				  	,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_RELGART",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				  	,;  //_COMP_F3 07          //f3 do componente
				   "'U_LOJR600A'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{ |This| FindFunction(This) } "	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
				   

  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJSERGE",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				  	,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTISE1",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "05"	,;  //_COMP_F3 07          //f3 do componente
				   "'DP'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				  "{ || AliasInDic('MBJ')}"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
				   
  aAdd(aComps, { StrZero(26, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJGARFP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   	,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				  "{ || AliasInDic('MBF') .AND. AliasInDic('MBL') }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
	
	
	nConta := 0
 	aAdd(aComps, { StrZero(27, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LOJANF",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   	,;  //_COMP_F3 07          //f3 do componente
				   "'UNI'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )	
 
	 	aAdd(aComps, { StrZero(27, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_TESNOTA",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "SF4"	,;  //_COMP_F3 07          //f3 do componente
				   "'501'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )		

 
	 	aAdd(aComps, { StrZero(27, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJNCUPS",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   "SF4"	,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )
 
	 	aAdd(aComps, { StrZero(27, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_SCRNFCP",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'LJNFISCA'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )

	 	aAdd(aComps, { StrZero(27, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CONTNF",;  //_COMP_NAME 05        //Nome do componente
				   STR0112,;  //_COMP_TITLE 06       //titulo do componente //"Numeração das notas de crédito ou débito"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'I'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "I="	+STR0113+";M="+STR0114, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"Independentes"###"Sequencial"
				   ,;
				   "BRA",;
				   } ) 
				   
	aAdd(aComps, { StrZero(27, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CONTNFI",;  //_COMP_NAME 05        //Nome do componente
				   STR0115,;  //_COMP_TITLE 06       //titulo do componente //"Numeração das notas de crédito ou débito quando utiliza impressora Fiscal"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'I'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   "I="	+STR0113+";M="+STR0114, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"Independentes"###"Sequencial"
				   ,;
				   "BRA",;
				   } )
    nConta := 0
	aAdd(aComps, { StrZero(28, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJ720FC",;  //_COMP_NAME 05        //Nome do componente
				   "",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this| this > 0}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 


	aAdd(aComps, { StrZero(28, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJDVACR",;  //_COMP_NAME 05        //Nome do componente
				   STR0116,;  //_COMP_TITLE 06       //titulo do componente //"Considera acrescimo financeiro na devolucao"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 


	aAdd(aComps, { StrZero(28, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCMPCR",;  //_COMP_NAME 05        //Nome do componente
				   STR0117,;  //_COMP_TITLE 06       //titulo do componente //"Utiliza a NCC da Devol para compensar com o  Tit da NF original vem marcada ou não na troca."
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 


	aAdd(aComps, { StrZero(28, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCMPCR",;  //_COMP_NAME 05        //Nome do componente
				   STR0117,;  //_COMP_TITLE 06       //titulo do componente //"Utiliza a NCC da Devol para compensar com o  Tit da NF original vem marcada ou não na troca."
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 


	aAdd(aComps, { StrZero(28, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCMPCR",;  //_COMP_NAME 05        //Nome do componente
				   STR0118,;  //_COMP_TITLE 06       //titulo do componente //"Permite ou não modificar a opção para compensar a NCC com o titulo da NF original (0-não permite 1-permite)"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| AllTrim(This) $ '01'}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
 	aAdd(aComps, { StrZero(28, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCHGDV",;  //_COMP_NAME 05        //Nome do componente
				   STR0119,;  //_COMP_TITLE 06       //titulo do componente //"Permite ou não modificar a forma de devolução ao cliente (0-não permite 1-permite)"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| AllTrim(This) $ '01'}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				            
	nConta++
	//29 - Orçamento   
 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FRLMORC",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   "300",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| This > 0}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 	

	
 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FRTIMP",;  //_COMP_NAME 05        //Nome do componente
				   STR0120,;  //_COMP_TITLE 06       //titulo do componente //"Método de importaçao do orçamento"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0180, ; // _COMP_LIST 15 // lISTA DE vALORES   //"1=String;2=Array"
				   ,;
				   ,;
				   } ) 		

 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJDTORC",;  //_COMP_NAME 05        //Nome do componente
				   STR0121,;  //_COMP_TITLE 06       //titulo do componente //"Define o ajuste das datas do orçamento"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'N'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0122, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"N=Nunca ajsuta;S=Sempre ajusta;P=Pergunta se deseja ajustar"
				   ,;
				   ,;
				   } ) 

 

 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJMLTOC",;  //_COMP_NAME 05        //Nome do componente
				   STR0123,;  //_COMP_TITLE 06       //titulo do componente //"Fecha automaticamente a tela de 'Carregamento de Orçamentos'?"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJIPDES",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

 
 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJMLTOR",;  //_COMP_NAME 05        //Nome do componente
				   STR0124,;  //_COMP_TITLE 06       //titulo do componente //"Habilita a importação de multiplos orçamentos"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )        
				   

 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_SCRORC",;  //_COMP_NAME 05        //Nome do componente
				   STR0125,;  //_COMP_TITLE 06       //titulo do componente //"Arquivo com script de impressao do orcamento"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'ORCAM'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 

 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FRTIMP",;  //_COMP_NAME 05        //Nome do componente
				   STR0126,;  //_COMP_TITLE 06       //titulo do componente //"Metodo de importacao do orcamento"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0180, ; // _COMP_LIST 15 // lISTA DE vALORES   //"1=String;2=Array"
				   ,;
				   ,;
				   } )
				   
 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FRLMORC",;  //_COMP_NAME 05        //Nome do componente
				   STR0127,;  //_COMP_TITLE 06       //titulo do componente //"Limite de orcamentos a serem carregados"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "300",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )				   

 	aAdd(aComps, { StrZero(29, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_DTLIMIT",;  //_COMP_NAME 05        //Nome do componente
				   STR0128,;  //_COMP_TITLE 06       //titulo do componente //"Número de dias de validade de um orcamento no SigaLoja"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
  

	nConta := 0
 	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCONFF",;  //_COMP_NAME 05        //Nome do componente
				   STR0129,;  //_COMP_TITLE 06       //titulo do componente //"Executar a conferência no fechamento de caixa?"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|| AliasIndic('FRA')}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )     
				   
				   
 	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJEXAPU",;  //_COMP_NAME 05        //Nome do componente
				   STR0130,;  //_COMP_TITLE 06       //titulo do componente //"Exibir a coluna de valores apurados no fechamento?"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )         
				   
	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJDESM",;  //_COMP_NAME 05        //Nome do componente
				   STR0131,;  //_COMP_TITLE 06       //titulo do componente //"Imprime relatorio desmembrado por administradora financeira"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )    
				   
				   
	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJNRPEN",;  //_COMP_NAME 05        //Nome do componente
				   STR0132,;  //_COMP_TITLE 06       //titulo do componente //"Número de reprocessamento de pendências"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "5",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )    
				   
	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTRANSF",;  //_COMP_NAME 05        //Nome do componente
				   STR0133,;  //_COMP_TITLE 06       //titulo do componente //"Ativa a transferência de carteira e portador - Loja"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTRNAT",;  //_COMP_NAME 05        //Nome do componente
				   STR0133,;  //_COMP_TITLE 06       //titulo do componente //"Ativa a transferência de carteira e portador - Loja"
				   "SED",;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } ) 
				   
	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTRMVD",;  //_COMP_NAME 05        //Nome do componente
				   STR0134,;  //_COMP_TITLE 06       //titulo do componente //"Determina se o mov. detalhado por transferência de portador e situação será utilizado."
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
 

	aAdd(aComps, { StrZero(31, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJOBGCF",;  //_COMP_NAME 05        //Nome do componente
				   STR0135,;  //_COMP_TITLE 06       //titulo do componente //"Confirmar a Conferência de Caixa, para que a abertura do caixa possa ser realizada"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )
	nConta := 0  
	aAdd(aComps, { StrZero(32, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_ROTINA,;  // _COMP_TYPE  04       //tipo do componente
				   "LOJA076()",;  //_COMP_NAME 05        //Nome do componente
				   "",;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|| AliasIndic('MBH') .AND.  AliasIndic('MBI')}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )

	nConta := 0  
	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CLIPAD",;  //_COMP_NAME 05        //Nome do componente
				   STR0136,;  //_COMP_TITLE 06       //titulo do componente //"Código do Cliente Padrão"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'000001'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this|  !Empty(this)}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )

	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LOJAPAD",;  //_COMP_NAME 05        //Nome do componente
				   STR0137,;  //_COMP_TITLE 06       //titulo do componente //"Loja do Cliente Padrão"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this|  !Empty(this)}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )  
				   
	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LOJAPAD",;  //_COMP_NAME 05        //Nome do componente
				   STR0137,;  //_COMP_TITLE 06       //titulo do componente //"Loja do Cliente Padrão"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this|  !Empty(this)}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )  
				   
	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_VENDPAD",;  //_COMP_NAME 05        //Nome do componente
				   STR0138,;  //_COMP_TITLE 06       //titulo do componente //"Vendedor Padrão"
				   "SA3",;  //_COMP_F3 07          //f3 do componente
				   "'000001'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this|  !Empty(this)}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )  
				   
		   
	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CXLOJA",;  //_COMP_NAME 05        //Nome do componente
				   STR0139,;  //_COMP_TITLE 06       //titulo do componente //"Caixa/Agencia/Conta do Caixa Geral"
				   "SA6",;  //_COMP_F3 07          //f3 do componente
				   "'000001'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this|  !Empty(this)}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )  

	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CONDPAD",;  //_COMP_NAME 05        //Nome do componente
				   STR0140,;  //_COMP_TITLE 06       //titulo do componente //"Condição de pagamento padrão"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'001'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this|  !Empty(this)}",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )
    				   
	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJVACC",;  //_COMP_NAME 05        //Nome do componente
				   STR0141,;  //_COMP_TITLE 06       //titulo do componente //"Impressao concomitante dos itens"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this| this .OR. !this }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )              
				   
	aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_TABPAD",;  //_COMP_NAME 05        //Nome do componente
				   STR0142,;  //_COMP_TITLE 06       //titulo do componente //"Preço padrão para digitação de vendass"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this| this .OR. !this }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )				   
				   
			   
	
		aAdd(aComps, { StrZero(33, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJMDORC",;  //_COMP_NAME 05        //Nome do componente
				   STR0143,;  //_COMP_TITLE 06       //titulo do componente //"Moeda padrão utilizada na venda"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "1",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   ,;
				   } ) 
				   
	nConta := 0
	aAdd(aComps, { StrZero(34, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJVACC",;  //_COMP_NAME 05        //Nome do componente
				   STR0141,;  //_COMP_TITLE 06       //titulo do componente //"Impressao concomitante dos itens"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this| this .OR. !this }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } ) 
				   
	aAdd(aComps, { StrZero(34, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPRDSV",;  //_COMP_NAME 05        //Nome do componente
				   STR0144,;  //_COMP_TITLE 06       //titulo do componente //"Ativa a implementacao de venda de produto e servico em Notas Separadas"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this| this .OR. !this }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )   
				   
	aAdd(aComps, { StrZero(34, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_CODBAR",;  //_COMP_NAME 05        //Nome do componente
				   STR0145,;  //_COMP_TITLE 06       //titulo do componente //"Indica se imprime codigo de barras no cupom ao inves do codigo do produto"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'N'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|this| This $ 'SN' }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } ) 
				
	aAdd(aComps, { StrZero(34, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRGMID",;  //_COMP_NAME 05        //Nome do componente
				   STR0146,;  //_COMP_TITLE 06       //titulo do componente //"Define uso e obrigatoriedade de registro de mídia"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "0",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   "{|This| Str(This,1) $ '012' }",;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "N",;
				   ,;
				   } ) 
				   
	nConta := 0
	aAdd(aComps, { StrZero(35, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJFORMD",;  //_COMP_NAME 05        //Nome do componente
				   STR0147,;  //_COMP_TITLE 06       //titulo do componente //"Define como os produtos de Automação Comercial irá tratar  o desconto no total"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0148, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Validar percentual ou valor;2=Validar percentual e também valor"
				   "C",;
				   ,;
				   } ) 

	aAdd(aComps, { StrZero(35, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJTIPOD",;  //_COMP_NAME 05        //Nome do componente
				   STR0149,;  //_COMP_TITLE 06       //titulo do componente //"Define a forma de validação da permissão do desconto no total da venda"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'1'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0150, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Percentual;2=Valor"
				   "C",;
				   ,;
				   } ) 

	aAdd(aComps, { StrZero(35, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_FRTACRE",;  //_COMP_NAME 05        //Nome do componente
				   "Acréscimo",;  //_COMP_TITLE 06       //titulo do componente
				   "",;  //_COMP_F3 07          //f3 do componente
				   "2",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0151, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Considera acrescimo;2=Desconsidera o acrescimo;3=Pergunta"
				   "N",;
				   ,;
				   } ) 
	
	nConta := 0
	aAdd(aComps, { StrZero(36, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPARFA",;  //_COMP_NAME 05        //Nome do componente
				   STR0152,;  //_COMP_TITLE 06       //titulo do componente //"Verifica se as parcela seguirão sequência do faturamento."
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } ) 	
				   
	aAdd(aComps, { StrZero(36, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_1DUP",;  //_COMP_NAME 05        //Nome do componente
				   STR0153,;  //_COMP_TITLE 06       //titulo do componente //"Inicializacao da parcela do primeiro titulo gerado"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'A'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )
	nConta := 0			    
	aAdd(aComps, { StrZero(37, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJCNVDA",;  //_COMP_NAME 05        //Nome do componente
				   STR0154,;  //_COMP_TITLE 06       //titulo do componente //"Habilita integração com o Cenário de Vendas"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )

	aAdd(aComps, { StrZero(37, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRETVL",;  //_COMP_NAME 05        //Nome do componente
				   STR0155,;  //_COMP_TITLE 06       //titulo do componente //"Valor da tabela de preco"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'3'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   STR0156, ; // _COMP_LIST 15 // lISTA DE vALORES   // //"1=Menor preço;2=Maior preço;3=Tabela config. MV_TABPAD"
				   "C",;
				   ,;
				   } )

	aAdd(aComps, { StrZero(37, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRGDES",;  //_COMP_NAME 05        //Nome do componente
				   STR0157,;  //_COMP_TITLE 06       //titulo do componente //"Habilita novo modelo de regra de desconto"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )
 
 	aAdd(aComps, { StrZero(37, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRGDES",;  //_COMP_NAME 05        //Nome do componente
				   STR0157,;  //_COMP_TITLE 06       //titulo do componente //"Habilita novo modelo de regra de desconto"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   } )    
				   
    
	nConta := 0
	aAdd(aComps, { StrZero(38, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJMULTN",;  //_COMP_NAME 05        //Nome do componente
				   STR0158,;  //_COMP_TITLE 06       //titulo do componente //"Habilita Multinegociação"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  )       
 
	aAdd(aComps, { StrZero(38, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_ROTINA,;  // _COMP_TYPE  04       //tipo do componente
				   "Loja760()",;  //_COMP_NAME 05        //Nome do componente
				   ,;  //_COMP_TITLE 06       //titulo do componente
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   ,;
				   } )	 
	
	nConta := 0  
	
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPAFEC",;  //_COMP_NAME 05        //Nome do componente
				   STR0159,;  //_COMP_TITLE 06       //titulo do componente //"Habilita o PAF-ECF"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  )


	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJOFFLN",;  //_COMP_NAME 05        //Nome do componente
				   STR0160,;  //_COMP_TITLE 06       //titulo do componente //"Abiente Off-Line"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  )
 

	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJIMAUT",;  //_COMP_NAME 05        //Nome do componente
				   STR0161,;  //_COMP_TITLE 06       //titulo do componente //"Importação dos dados para o PDV automatica"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  )   
				   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJRPAUT",;  //_COMP_NAME 05        //Nome do componente
				   STR0162,;  //_COMP_TITLE 06       //titulo do componente //"Replicação automatica"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".F.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  )  
				   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJMATOF",;  //_COMP_NAME 05        //Nome do componente
				   STR0163,;  //_COMP_TITLE 06       //titulo do componente //"Ambiente Retaguarda"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  )    
	
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJPRVEN",;  //_COMP_NAME 05        //Nome do componente
				   STR0164,;  //_COMP_TITLE 06       //titulo do componente //"PAF-ECF trabalha com Pré-Venda"
				   "",;  //_COMP_F3 07          //f3 do componente
				   ".T.",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "L",;
				   ,;
				   }  ) 
				   

	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1/2/4",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJAMBIE",;  //_COMP_NAME 05        //Nome do componente
				   STR0165,;  //_COMP_TITLE 06       //titulo do componente //"Código do Ambiente"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'001'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   }  )

	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJSERDA",;  //_COMP_NAME 05        //Nome do componente
				   STR0166,;  //_COMP_TITLE 06       //titulo do componente //"Série do DAV"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'DAV'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   }  ) 
				   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				  StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				  	_PARAMETRO,;  // _COMP_TYPE  04       //tipo do componente
				   "MV_LJSERPR",;  //_COMP_NAME 05        //Nome do componente
				   STR0167,;  //_COMP_TITLE 06       //titulo do componente //"Série da Pré-Venda"
				   "",;  //_COMP_F3 07          //f3 do componente
				   "'PRE'",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				   ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   ,; //_COMP_LEN   14 
				   ,; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   }  )


	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
			   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
			  "1/2/3" ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
			  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
			   "Patharquivo",;  //_COMP_NAME 05        //Nome do componente
			   STR0168,;  //_COMP_TITLE 06       //titulo do componente //"Localização de Gravaç]ao dos Arquivos"
			   ,;  //_COMP_F3 07          //f3 do componente
			   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
			   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
			   ,;  //_COMP_INDEX 10        //indice da tabela 
			   "PAF-ECF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
			   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
			   "{ |T| !Empty(T)}"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
			   , ; //_COMP_LEN   14 
			   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
			   ,;
			   ,;
			   } )	

				   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
			   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
			  "1/2/3" ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
			  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
			   "Dav",;  //_COMP_NAME 05        //Nome do componente
			   STR0169,;  //_COMP_TITLE 06       //titulo do componente //"Indice do Relatorio DAV"
			   ,;  //_COMP_F3 07          //f3 do componente
			   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
			   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
			   ,;  //_COMP_INDEX 10        //indice da tabela 
			   "PAF-ECF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
			   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
			   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
			   2, ; //_COMP_LEN   14 
			   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
			   ,;
			   ,;
			   } )	
			  			   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
			   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
			  "1/2/3" ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
			  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
			   "MeiosPagto",;  //_COMP_NAME 05        //Nome do componente
			   STR0170,;  //_COMP_TITLE 06       //titulo do componente //"Indice do Relatorio Meios de Pagamento"
			   ,;  //_COMP_F3 07          //f3 do componente
			   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
			   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
			   ,;  //_COMP_INDEX 10        //indice da tabela 
			   "PAF-ECF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
			   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
			   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
			   2, ; //_COMP_LEN   14 
			   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
			   ,;
			   ,;
			   } )
			   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
			   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
			  "1/2/3" ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
			  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
			   "ParamConfig",;  //_COMP_NAME 05        //Nome do componente
			   STR0171,;  //_COMP_TITLE 06       //titulo do componente //"Indice do Relatorio de Parametros de Configuração"
			   ,;  //_COMP_F3 07          //f3 do componente
			   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
			   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
			   ,;  //_COMP_INDEX 10        //indice da tabela 
			   "PAF-ECF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
			   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
			   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
			   2, ; //_COMP_LEN   14 
			   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
			   ,;
			   ,;
			   } ) 
			   
	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
			   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
			  "1/2/3" ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
			  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
			   "IdPaf",;  //_COMP_NAME 05        //Nome do componente
			   STR0172,;  //_COMP_TITLE 06       //titulo do componente //"Indice do Relatorio de Indentificação do PAF-ECF"
			   ,;  //_COMP_F3 07          //f3 do componente
			   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
			   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
			   ,;  //_COMP_INDEX 10        //indice da tabela 
			   "PAF-ECF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
			   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
			   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
			   2, ; //_COMP_LEN   14 
			   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
			   ,;
			   ,;
			   } )				   

	aAdd(aComps, { StrZero(39, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
			   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
			  "1/2/3" ,;  // _COMP_ENVIRONMENT 03 //ambiente do componente
			  	_ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
			   "DavEcf",;  //_COMP_NAME 05        //Nome do componente
			   STR0173,;  //_COMP_TITLE 06       //titulo do componente //"Indice do Relatorio de DAV-ECF"
			   ,;  //_COMP_F3 07          //f3 do componente
			   "'01'",;  //_COMP_DEFAULT 08     //valor default do componente
			   "SIGALOJA.INI",;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
			   ,;  //_COMP_INDEX 10        //indice da tabela 
			   "PAF-ECF",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
			   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
			   "{ |T| Val(T) > 0.AND.Val(T)< 99 .and. T >'00' .AND. T < '99' }"	,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
			   2, ; //_COMP_LEN   14 
			   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
			   ,;
			   ,;
			   } )

    nConta := 0
 	aAdd(aComps, { StrZero(40, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Environment",;  //_COMP_NAME 05        //Nome do componente
				   STR0174,;  //_COMP_TITLE 06       //titulo do componente //"Nome do Ambiente Local"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "LOJA1115",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   20, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	

	aAdd(aComps, { StrZero(40, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Parm1",;  //_COMP_NAME 05        //Nome do componente
				   STR0175,;  //_COMP_TITLE 06       //titulo do componente //"Empresa do Ambiente Local"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "LOJA1115",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	 
				   
	aAdd(aComps, { StrZero(40, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Parm2",;  //_COMP_NAME 05        //Nome do componente
				   STR0176,;  //_COMP_TITLE 06       //titulo do componente //"Filial do Ambiente Local"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "LOJA1115",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   FWGETTAMFILIAL, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	
				   
   
    
	nConta := 0
	aAdd(aComps, { StrZero(41, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "3",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   	_ROTINA,;  // _COMP_TYPE  04       //tipo do componente
				   "STFScreenColor()",;  //_COMP_NAME 05        //Nome do componente
				   STR0184,;  //_COMP_TITLE 06       //titulo do componente"Cor da Janela do POS"
				   ,;  //_COMP_F3 07          //f3 do componente
				   ,;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   ,;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   ,;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   , ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   ,;
				   "BRA",;
				   } )	


    nConta := 0
 	aAdd(aComps, { StrZero(42, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Environment",;  //_COMP_NAME 05        //Nome do componente
				   STR0174,;  //_COMP_TITLE 06       //titulo do componente //"Nome do Ambiente Local"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Integracao_ERP",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "2",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   20, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	

	aAdd(aComps, { StrZero(42, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Parm1",;  //_COMP_NAME 05        //Nome do componente
				   STR0175,;  //_COMP_TITLE 06       //titulo do componente //"Empresa do Ambiente Local"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Integracao_ERP",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   2, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	 
				   
	aAdd(aComps, { StrZero(42, nTamSX3),; //_COMP_NODE	01 //codigo do nó 
				   StrZero(nConta++, nTamID),;  //_COMP_ID 02     //id do componentes
				   "1",;  // _COMP_ENVIRONMENT 03 //ambiente do componente
				   _ARQUIVO_INI,;  // _COMP_TYPE  04       //tipo do componente
				   "Parm2",;  //_COMP_NAME 05        //Nome do componente
				   STR0176,;  //_COMP_TITLE 06       //titulo do componente //"Filial do Ambiente Local"
				   ,;  //_COMP_F3 07          //f3 do componente
				   "''",;  //_COMP_DEFAULT 08     //valor default do componente
				   ,;  //_COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG  //tipo de arquivo de configuração
				   ,;  //_COMP_INDEX 10        //indice da tabela 
				   "Integracao_ERP",;  //_COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL //chave da tabela/arquivo de configuração 
				   "1",;//_COMP_INITYPE 12     //tipo de arquivo.ini C - lient / S - erver
				    ,;//_COMP_VALID	13 //eXPRESSÃO DE VALIDAÇÃO
				   FWGETTAMFILIAL, ; //_COMP_LEN   14 
				   , ; // _COMP_LIST 15 // lISTA DE vALORES   //
				   "C",;
				   ,;
				   } )	
				   

	
				   
	Return aComps
