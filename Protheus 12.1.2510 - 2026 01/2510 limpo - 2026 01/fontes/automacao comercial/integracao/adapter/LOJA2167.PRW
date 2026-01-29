#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"
#INCLUDE "LOJA2134.CH"

/*#DEFINE _INCLUSAO		 		"3"		//Inclusao
#DEFINE _ALTERACAO				"4"  	//Alteracao
#DEFINE _EXCLUSAO				"5"  	//Exclusao

#DEFINE _DELIMIT "_"*/

Function LOJA2167 ; Return  // "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCAdapXmlRecSC5  บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em processar o XML de recebimento da entidade SC5บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCAdapXmlRecSC5 From LJAAdapXMLRec
    
	Data oCamposSC5										// Estrutura do dicionario SC5
	Data oCamposSC6										// Estrutura do dicionario SC6
	Data lPedido										// Indica se o pedido jแ estแ cadastrado
	Data aEnvSC5										// Dados a serem enviados do SC5
	Data aEnvSC6										// Dados a serem enviados do SC6
	Data oListSC6										// Lista com os dados do SC6
	
	Method New()					                   	// Metodo construtor
	Method Processar(cXml)    							// Metodo que ira processar os dados da integracao SC5
	
	//Metodos internos
	Method LerDic()										// Le o dicionario
	Method PrepDados()									// Prepara os dados para serem enviados
	Method EnvDados()									// Envia os dados para rotina automatica
	Method ConsistDad()									// Consiste os dados recebidos
	Method FormatCamp(cCampo, cValor, oCampos)			// Formata o campo
	Method ExisteSC5()									// Verifica se o produto ja existe na base de dados
	Method ValDefault()									// Seta os valores default
	Method PrepDadSC5()									// Prepara os dados para serem enviados SC5
	Method PrepDadSC6()									// Prepara os dados para serem enviados SC6		
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCAdapXmlRecSC5.	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJCAdapXmlRecSC5
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	Self:oCamposSC5	:= NIL
	Self:oCamposSC6	:= NIL
	Self:lPedido  	:= .F.
	Self:aEnvSC5	:= {}
	Self:aEnvSC6	:= {}
	Self:oListSC6	:= LJCList():New()
		
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณProcessar บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em processar o XML SC5.				  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cXml) - XML recebido.	    				  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Processar(cXml) Class LJCAdapXmlRecSC5

	Local lRetorno 	:= .T.					//Retorno do metodo

	// Armazena no objeto o XML a ser processado        
    Self:cXml := cXml
    
    // Le o dicionario
    Self:LerDic()
    
    // Carrega a estrutura do xml recebido
    lRetorno := Self:LerXml(_DELIMIT)
	    
    If lRetorno
		//Consistir dados
       	lRetorno := Self:ConsistDad()    	
    EndIf
	    
    If lRetorno 
    	//Prepara dados para envio
       	lRetorno := Self:PrepDados()
    EndIf
	    
    If lRetorno
		//Seta os valores default
       	lRetorno := Self:ValDefault()    	
    EndIf
	    
    If lRetorno 
    	//Envia dados para rotina automatica
	   	lRetorno := Self:EnvDados()
    EndIf
		            
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณLerDic    บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel ler a estrutura do dicionario.		  		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ											   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method LerDic() Class LJCAdapXmlRecSC5
	
	Self:oCamposSC5	:= LJCCampos():New("SC5")
	Self:oCamposSC6	:= LJCCampos():New("SC6")
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepDadSC5บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel preparar os dados para serem enviados SC5.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepDadSC5() Class LJCAdapXmlRecSC5
	
	Local lRetorno 	:= .T.					// Retorno do metodo
	Local cNode		:= ""					// String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					// Descricao do campo
	Local oRetorno	:= NIL					// Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					// Valor da tag
	Local nCount	:= 0 					// Variavel auxiliar contador
	Local aPreco	:= {}					// Array auxiliar para guarda as informacoes do preco
	
	Private oNode	:= Nil					// Usado para execucao da macro
	
	oNode := Self:oEstruXml
	
	//Verifica se os campos do XML existem no dicionario		
	For nCount := 1 to Self:oCamposSC5:Count()
	    
	    //Nome do campo
		cCampo := Self:oCamposSC5:Elements(nCount):cNome
		
		//Verifica se o campo existe no XML
		oRetorno := Self:oXml:NodeExiste(Self:oEstruXml:_FORMMODEL_PEDIDO:_CAB_PEDIDO, _DELIMIT + cCampo)
		
		//Trata retorno		
		If oRetorno <> Nil
			//String para ser executada via macro
			cNode := "oNode:_FORMMODEL_PEDIDO:_CAB_PEDIDO:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
			
			//Pega o conteudo da tag via macro
		    cValor := &cNode
		    
		    //Converte o campo
			Self:ConverCamp(cCampo, @cValor, Self:oCamposSC5)
		    
		    //Adiciona os dados no array de envio
		    aAdd(Self:aEnvSC5, {cCampo, cValor, NIL})
		EndIf
	Next 
	
	// Todo: Verificar a necessidade do c๓digo abaixo
	/*	
	Do Case
		
		//INCLUSAO
		Case Self:cOperacao = _INCLUSAO     
	    	
	    	//Verifica se o produto ja esta cadastrado
	    	Self:lProduto := Self:ExisteSB1() 
	    	    	
	    	If Self:lProduto .AND. Self:lCodBarra //.OR. Self:lAcessorio)
   				//Se o produto ja existir no SB1 e no XML existir SLK ou SUG; neste caso nao
				//precisa preparar os dados de envio do SB1 porque se trata de uma inclusao do SLK ou SUG.
	    		Self:aEnvSB0 := NIL	
	    		Self:aEnvSB1 := NIL
	    		
	    	ElseIf Self:lProduto .AND. Self:lPreco 
           		//Se o produto ja existir no SB1 e no XML existir SB0, fazer a alteracao do SB0.
            	//Enviar o produto e preco como alteracao
            	Self:cOperSB1 := _ALTERACAO
            	 
	    	ElseIf Self:lProduto .AND. !Self:lPreco
    			//Produto ja cadastrado
    			lRetorno := .F.
    			Self:cError := STR0001 //"Produto jแ cadastrado."
	    	Else
	    		//Sempre incluir SB1 e SB0.
	    		If !Self:lPreco
	    		
				    aPreco := {}
					
					//Adiciona os dados no array de envio
				    AADD(aPreco, {"B0_COD", Self:oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_B1_COD:_VALUE:TEXT, NIL})
				    AADD(aPreco, {"B0_PRV1", 0, NIL})					
					AADD(Self:aEnvSB0, aPreco)
	    		EndIf
	    		
	    		//Enviar o produto como inclusao
	    		Self:cOperSB1 := _INCLUSAO 
	    	EndIf
	    
		//ALTERACAO ou EXCLUSAO		
		Case Self:cOperacao == _ALTERACAO .OR. Self:cOperacao == _EXCLUSAO
			
			If Self:lCodBarra //.OR. Self:lAcessorio)
   				//Se no XML existir SLK ou SUG; neste caso nao
				//precisa preparar os dados de envio do SB1 porque se trata de uma alteracao/exclusao do SLK ou SUG.
	    		Self:aEnvSB0 := NIL	
	    		Self:aEnvSB1 := NIL
	    	EndIf
	    	
	    	Self:cOperSB1 := Self:cOperacao
	EndCase   
	*/

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepDadSC6บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel preparar os dados para serem enviados SC6.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepDadSC6() Class LJCAdapXmlRecSC5
	
	Local lRetorno 	:= .T.					// Retorno do metodo
	Local cNode		:= ""					// String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					// Descricao do campo
	Local oRetorno	:= NIL					// Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					// Valor da tag
	Local nCount	:= 0 					// Variavel auxiliar contador dos campos
	Local nCount1	:= 0 					// Variavel auxiliar contador dos codigos de barras.
    Local nQtde		:= 0					// Quantidade de codigo de barras no XML
	
	Private nAux	:= 0					// Variavel auxiliar contador dos codigos de barras, foi criado como private para execucao de macro
	Private oNode	:= Nil					// Usado para execucao da macro
		
	If ValType(Self:oEstruXml:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_ITEM_PEDIDO:_ITEMS:_ITEM) == 'O'
		nQtde := 1
	Else
	   	nQtde := Len(Self:oEstruXml:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_ITEM_PEDIDO:_ITEMS:_ITEM)
	EndIf

	oNode := Self:oEstruXml
	
	For nCount1 := 1 To nQtde
	    
		//Inicializa
		Self:aEnvSC6 := {}
	
		//Verifica se os campos do XML existem no dicionario		
		For nCount := 1 to Self:oCamposSC6:Count()
		    
		    //Nome do campo
			cCampo := Self:oCamposSC6:Elements(nCount):cNome
			
			//Verifica se o campo existe no XML
			If nQtde == 1
				oRetorno := Self:oXml:NodeExiste(Self:oEstruXml:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_ITEM_PEDIDO:_ITEMS:_ITEM, _DELIMIT + cCampo)
			Else
				oRetorno := Self:oXml:NodeExiste(Self:oEstruXml:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_ITEM_PEDIDO:_ITEMS:_ITEM[nCount1], _DELIMIT + cCampo)
			EndIf
			
			//Trata retorno		
			If oRetorno <> Nil
				
				//Atribui o valor do contador a variavel private, porque execucao de macro nao funciona como local
				nAux := nCount1
				
				//String para ser executada via macro
				If nQtde == 1
					cNode := "oNode:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_ITEM_PEDIDO:_ITEMS:_ITEM:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
				Else
					cNode := "oNode:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_ITEM_PEDIDO:_ITEMS:_ITEM[nAux]:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
				EndIf
				
				//Pega o conteudo da tag via macro
			    cValor := &cNode
			    
			    //Converte o campo
				Self:ConverCamp(cCampo, @cValor, Self:oCamposSC6)
			    
			    //Adiciona os dados no array de envio
			    AADD(Self:aEnvSC6, {cCampo, cValor, NIL})
			    
			EndIf
		Next
		
	    Self:oListSC6:Add(Self:aEnvSC6) 
	Next
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepDados บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel preparar os dados para serem enviados.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method PrepDados() Class LJCAdapXmlRecSC5
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	
	// Prepara os dados do cabe็alho do pedido
	lRetorno := Self:PrepDadSC5()
	
	// Prepara os dados do item do pedido
	If lRetorno
		lRetorno := Self:PrepDadSC6()
	EndIf 
		
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณEnvDados  บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel enviar os dados para rotina automatica.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnvDados() Class LJCAdapXmlRecSC5
	Local lRetorno 			:= .F.			// Retorno do metodo
    Private lMsErroAuto 	:= .F.			// Cria a variavel do retorno da rotina automatica
    Private lAutoErrNoFile	:= .F.			// Habilita a gravacao do erro da rotina automatica
    
    //Rotina automatica de produto
    If Self:aEnvSC5 <> NIL .OR. Self:aEnvSC6 <> NIL
    	//Executa a rotina automatica
    	MATA410( Self:aEnvSC5, Self:oListSC6:ToArray(), Val(Self:cOperacao) )
		
		If lMsErroAuto
			//Busca o erro da rotina automatica
			Self:cError := Self:ErroRotAut()
			MostraErro()
		Else
			lRetorno := .T.
		EndIf
    Else
    	lRetorno := .T.
    EndIf
    
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConsistDadบAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel fazer a consistencia dos dados recebidos.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ConsistDad() Class LJCAdapXmlRecSC5
	
	Local lRetorno 	:= .T.							//Retorno do metodo
	
	//Verifica o tipo de operacao a ser executada
	Self:cOperacao := Self:oEstruXml:_FORMMODEL_PEDIDO:_OPERATION:TEXT
	
	// Se for solicitada altera็ใo, mas nใo existir o item informado, assume que ้ inclusใo, pois por exemplo, a integra็ใo com a Crit้rium s๓ ้ informado se ้ Inclusใo/Altera็ใo e Exclusใo, ou seja, somente dois status.
	If Self:cOperacao == "4" .And. !Self:ExisteSC5()
		Self:cOperacao := "3"
	EndIf
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFormatCampบAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em formatar o campo.							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cCampo) - Campo a ser formatado.			  	  บฑฑ
ฑฑบ			 ณExpC2 (2 - cValor) - Valor a ser formatado.			  	  บฑฑ
ฑฑบ			 ณExpO1 (3 - oCampos) - Objeto com os campos da entidade.  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณVariant									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FormatCamp(cCampo, cValor, oCampos) Class LJCAdapXmlRecSC5
	
	Local oRetorno := Nil					//Retorno do metodo
		
	Do Case
		Case cCampo == "B1_COD"
			oRetorno := PadR(cValor, oCampos:ElementKey(cCampo):nTamanho , " ") 
	End Case
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณExisteSC5 บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel verificar se o produto ja existe				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExisteSC5() Class LJCAdapXmlRecSC5
	
	Local lRetorno 	:= .F.							// Retorno do metodo
	Local oProduto	:= NIl							// Objeto do tipo LJCEntProduto
	Local oFactory	:= LJCEntidadeFactory():New()	// Fแbrica que retorna a classe LCAEntidade adequada para tabela SC5
	
	//Instancia o objeto LJCEntProduto
	oProduto := oFactory:Create("SC5")
	
	//Atribui os valores da chave   	
	oProduto:DadosSet("C5_NUM", Self:oEstruXml:_FORMMODEL_PEDIDO:_CAB_PEDIDO:_C5_NUM:_VALUE:TEXT)
	
	//Consulta os dados	
	oRet := oProduto:Consultar(1)
	
	//Trata retorno
	If oRet:Count() > 0 
		lRetorno := .T.
	EndIf	
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณValDefaultบAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em atribuir os valores default    			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ValDefault() Class LJCAdapXmlRecSC5
	
	Local lRetorno 	:= .T.   				//Retorno do metodo
	Local nCount	:= 0					//Variavel auxiliar contador
	Local aDados	:= {}					//Array auxiliar
	Local nPos		:= 0
	Local aAreaSA1	:= SA1->(GetArea())
	
	//Somente seta os valores default se a operacao for de INCLUSAO ou ALTERACAO
	If Self:cOperacao != _EXCLUSAO    
	
		// Campo obrigat๓rio, tipo de cliente
		If AScan(Self:aEnvSC5, {|x| x[1] == "C5_LOJACLI"}) == 0
			If ( nPos := AScan(Self:aEnvSC5, {|x| x[1] == "C5_CLIENTE"}) ) > 0
				DbSelectArea( "SA1" )
				DbSetOrder( 1 )
				If DbSeek( xFilial( "SA1" ) + PadR(Self:aEnvSC5[nPos][2],TamSX3("A1_COD")[1] ) )
					aAdd(Self:aEnvSC5, {"C5_LOJACLI", SA1->A1_LOJA, NIL})
				EndIf
			Else
				aAdd(Self:aEnvSC5, {"C5_LOJACLI", "01", NIL})
			EndIf
		EndIF		
	
		// Campo obrigat๓rio, tipo de cliente
		If AScan(Self:aEnvSC5, {|x| x[1] == "C5_TIPO"}) == 0
			aAdd(Self:aEnvSC5, {"C5_TIPO", "N", NIL})
		EndIF						
		
		// Campo obrigat๓rio, tipo de cliente
		If AScan(Self:aEnvSC5, {|x| x[1] == "C5_TIPOCLI"}) == 0
			aAdd(Self:aEnvSC5, {"C5_TIPOCLI", "F", NIL})
		EndIF
		
		// Campo obrigat๓rio, condi็ใo de pagamento
		// Todo: Precisa confirmar como serแ tratado o campo de condi็ใo de pagamento
		If AScan(Self:aEnvSC5, {|x| x[1] == "C5_CONDPAG"}) == 0
			aAdd(Self:aEnvSC5, {"C5_CONDPAG", "001", NIL})
		EndIF	
		
		// Informa os campos padr๕es nos itens do pedido
		For nCount := 1 To Self:oListSC6:Count()
			aDados := Self:oListSC6:Elements(nCount)
			
			/*
			// Campo obrigat๓rio, tipo de cliente
			If AScan(aDados, {|x| x[1] == "C6_"}) == 0
				aAdd(aDados, {"C6_", "N", NIL})
			EndIF						
			*/
		Next

	EndIf
	
	RestArea( aAreaSA1 )
		
Return lRetorno