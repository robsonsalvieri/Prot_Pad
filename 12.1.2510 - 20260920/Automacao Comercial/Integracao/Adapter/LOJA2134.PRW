#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFINTEGRA.CH"
#INCLUDE "LOJA2134.CH"

Function LOJA2134 ; Return  // "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCAdapXmlRecSB1  บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em processar o XML de recebimento da entidade SB1บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCAdapXmlRecSB1 From LJAAdapXMLRec
    
	Data oCamposSB1										//Estrutura do dicionario SB1
	Data oCamposSB0										//Estrutura do dicionario SB0
	Data oCamposSLK										//Estrutura do dicionario SLK
	Data lPreco											//Indica que tem preco para o produto SB0
	Data lCodBarra										//Indica que tem codigo de barra para o produto SLK
	Data lProduto										//Indica se o produto ja esta cadastrado
	Data aEnvSB1										//Dados a serem enviados do SB1
	Data aEnvSB0										//Dados a serem enviados do SB0
	Data aEnvSLK										//Dados a serem enviados do SLK
	Data oListSLK										//Lista com os dados em array's que serao enviados do SLK
	Data cOperSB1										//Tipo de operacao do SB1
	Data cTipTrib										//Tipo de tributacao do produto
	
	Method New()					                   	//Metodo construtor
	Method Processar(cXml)    							//Metodo que ira processar os dados da integracao SB1
	Method Destrutor()									//Limpa os objetos que foram criados
	
	//Metodos internos
	Method LerDic()										//Le o dicionario
	Method PrepDados()									//Prepara os dados para serem enviados
	Method EnvDados()									//Envia os dados para rotina automatica
	Method ConsistDad()									//Consiste os dados recebidos
	Method FormatCamp(cCampo, cValor, oCampos)			//Formata o campo
	Method ExisteSB1()									//Verifica se o produto ja existe na base de dados
	Method ValDefault()									//Seta os valores default
	Method PrepDadSB1()									//Prepara os dados para serem enviados SB1
	Method PrepDadSLK()									//Prepara os dados para serem enviados SLK
	
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCAdapXmlRecSB1.	                  บฑฑ
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
Method New() Class LJCAdapXmlRecSB1
    
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::oCamposSB1	:= NIL
	::oCamposSB0	:= NIL
	::oCamposSLK	:= NIL
	::lPreco		:= .F.
	::lCodBarra		:= .F.
	::lProduto		:= .F.
	::aEnvSB1		:= {}
	::aEnvSB0		:= {}
	::aEnvSLK		:= {}
	::cOperSB1		:= ""
	::oListSLK		:= NIL
	::cTipTrib		:= ""
		
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณProcessar บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em processar o XML SA1.				  		  บฑฑ
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
Method Processar(cXml) Class LJCAdapXmlRecSB1

	Local lRetorno 	:= .T.					//Retorno do metodo
        
    ::cXml := cXml
    
    //Le o dicionario
    ::LerDic()
    
    //Carrega a estrutura do xml recebido
    lRetorno := ::LerXml(_DELIMIT)
	    
    If lRetorno
		//Consistir dados
       	lRetorno := ::ConsistDad()    	
    EndIf
	    
    If lRetorno 
    	//Prepara dados para envio
       	lRetorno := ::PrepDados()
    EndIf
	    
    If lRetorno
		//Seta os valores default
       	lRetorno := ::ValDefault()    	
    EndIf
	    
    If lRetorno 
    	//Envia dados para rotina automatica
	   	lRetorno := ::EnvDados()
    EndIf
		            
	Self:Destrutor()
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
Method LerDic() Class LJCAdapXmlRecSB1
	
	::oCamposSB1	:= LJCCampos():New("SB1")
	::oCamposSB0	:= LJCCampos():New("SB0")
	::oCamposSLK	:= LJCCampos():New("SLK")
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepDadSB1บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel preparar os dados para serem enviados SB1.	  บฑฑ
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
Method PrepDadSB1() Class LJCAdapXmlRecSB1
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local cNode		:= ""					//String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					//Descricao do campo
	Local oRetorno	:= NIL					//Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					//Valor da tag
	Local nCount	:= 0 					//Variavel auxiliar contador
	Local aPreco	:= {}					//Array auxiliar para guarda as informacoes do preco
	
	Private oNode	:= Nil					//Usado para execucao da macro
	
	oNode := ::oEstruXml
	
	//Verifica se os campos do XML existem no dicionario		
	For nCount := 1 to ::oCamposSB1:Count()
	    
	    //Nome do campo
		cCampo := ::oCamposSB1:Elements(nCount):cNome
		
		//Verifica se o campo existe no XML
		oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO, _DELIMIT + cCampo)
		
		//Trata retorno		
		If oRetorno <> Nil
			//String para ser executada via macro
			cNode := "oNode:_FORMMODEL_PRODUTO:_PRODUTO:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
			
			//Pega o conteudo da tag via macro
		    cValor := &cNode
		    
		    //Converte o campo
			::ConverCamp(cCampo, @cValor, ::oCamposSB1)
		    
		    //Adiciona os dados no array de envio
		    AADD(::aEnvSB1, {cCampo, cValor, NIL})
		EndIf
	Next 
	
	If ::lPreco
		//Verifica se os campos do XML existem no dicionario		
		For nCount := 1 to ::oCamposSB0:Count()
		    
		    //Nome do campo
			cCampo := ::oCamposSB0:Elements(nCount):cNome
			
			//Verifica se o campo existe no XML
			oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_PRECO, _DELIMIT + cCampo)
			
			//Trata retorno		
			If oRetorno <> Nil
				//String para ser executada via macro
				cNode := "oNode:_FORMMODEL_PRODUTO:_PRODUTO:_PRECO:" + _DELIMIT + cCampo + ":_VALUE:TEXT"
				
				//Pega o conteudo da tag via macro
			    cValor := &cNode
			    
			    //Converte o campo
				::ConverCamp(cCampo, @cValor, ::oCamposSB0)
			    
			    //Adiciona os dados no array de envio
			    AADD(aPreco, {cCampo, cValor, NIL})
			EndIf
		Next 
		
		//Adiciona os dados no array de envio
		If Len(aPreco) > 0
			AADD(::aEnvSB0, aPreco)
		EndIf
	EndIf
	
	Do Case
		
		//INCLUSAO
		Case ::cOperacao = _INCLUSAO     
	    	
	    	//Verifica se o produto ja esta cadastrado
	    	::lProduto := ::ExisteSB1() 
	    	    	
	    	If ::lProduto .AND. ::lCodBarra //.OR. ::lAcessorio)
   				//Se o produto ja existir no SB1 e no XML existir SLK ou SUG; neste caso nao
				//precisa preparar os dados de envio do SB1 porque se trata de uma inclusao do SLK ou SUG.
	    		::aEnvSB0 := NIL	
	    		::aEnvSB1 := NIL
	    		
	    	ElseIf ::lProduto .AND. ::lPreco 
           		//Se o produto ja existir no SB1 e no XML existir SB0, fazer a alteracao do SB0.
            	//Enviar o produto e preco como alteracao
            	::cOperSB1 := _ALTERACAO
            	 
	    	ElseIf ::lProduto .AND. !::lPreco
    			//Produto ja cadastrado
    			lRetorno := .F.
    			::cError := "LOJA2134:" + STR0001 //"Produto jแ cadastrado."
	    	Else
	    		//Sempre incluir SB1 e SB0.
	    		If !::lPreco
	    		
				    aPreco := {}
					
					//Adiciona os dados no array de envio
				    AADD(aPreco, {"B0_COD", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_B1_COD:_VALUE:TEXT, NIL})
				    AADD(aPreco, {"B0_PRV1", 0, NIL})					
					AADD(::aEnvSB0, aPreco)
	    		EndIf
	    		
	    		//Enviar o produto como inclusao
	    		::cOperSB1 := _INCLUSAO 
	    	EndIf
	    
		//ALTERACAO		
		Case ::cOperacao == _ALTERACAO
			
			If ::lCodBarra //.OR. ::lAcessorio)
   				//Se no XML existir SLK ou SUG; neste caso nao
				//precisa preparar os dados de envio do SB1 porque se trata de uma alteracao/exclusao do SLK ou SUG.
	    		::aEnvSB0 := NIL	
	    		::aEnvSB1 := NIL
	    		
	    		::cOperSB1 := ::cOperacao
	    	Else
	    		//Verifica se o produto ja esta cadastrado
		    	::lProduto := ::ExisteSB1()
		    	
		    	If !::lProduto
		    		//Enviar o produto como inclusao
		    		::cOperSB1 := _INCLUSAO 
		    	Else
		    		::cOperSB1 := ::cOperacao
		    	EndIf 
	    	EndIf
	    	
	   	//EXCLUSAO		
		Case ::cOperacao == _EXCLUSAO
		
			::cOperSB1 := ::cOperacao
		
	EndCase

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณPrepDadSLKบAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel preparar os dados para serem enviados SLK.	  บฑฑ
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
Method PrepDadSLK() Class LJCAdapXmlRecSB1
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	Local cNode		:= ""					//String com o noh onde esta o conteudo da tag
	Local cCampo	:= ""					//Descricao do campo
	Local oRetorno	:= NIL					//Objeto com o retorno se a tag foi encontrada no XML
	Local cValor	:= ""					//Valor da tag
	Local nCount	:= 0 					//Variavel auxiliar contador dos campos
	Local nCount1	:= 0 					//Variavel auxiliar contador dos codigos de barras.
    Local nQtde		:= 0					//Quantidade de codigo de barras no XML
	
	Private nAux	:= 0					//Variavel auxiliar contador dos codigos de barras, foi criado como private para execucao de macro
	Private oNode	:= Nil					//Usado para execucao da macro
		
	If ::lCodBarra
	    
		If ValType(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM) == 'O'
			nQtde := 1
		Else
		   	nQtde := Len(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM)
		EndIf
	
		oNode := ::oEstruXml
		
		For nCount1 := 1 To nQtde
		    
			//Inicializa
			::aEnvSLK := {}
		
			//Verifica se os campos do XML existem no dicionario		
			For nCount := 1 to ::oCamposSLK:Count()
			    
			    //Nome do campo
				cCampo := ::oCamposSLK:Elements(nCount):cNome
				
				//Verifica se o campo existe no XML
				If nQtde == 1
					oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM, _DELIMIT + cCampo)
				Else
					oRetorno := ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM[nCount1], _DELIMIT + cCampo)
				EndIf
				
				//Trata retorno		
				If oRetorno <> Nil
					
					//Atribui o valor do contador a variavel private, porque execucao de macro nao funciona como local
					nAux := nCount1
					
					//String para ser executada via macro
					If nQtde == 1
						cNode := "oNode:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM:" + _DELIMIT + cCampo + ":TEXT"
					Else
						cNode := "oNode:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM[nAux]:" + _DELIMIT + cCampo + ":TEXT"
					EndIf
					
					//Pega o conteudo da tag via macro
				    cValor := &cNode
				    
				    //Converte o campo
					::ConverCamp(cCampo, @cValor, ::oCamposSLK)
				    
				    //Adiciona os dados no array de envio
				    AADD(::aEnvSLK, {cCampo, cValor, NIL})
				    
				EndIf
			Next
			
			//Lista de codigo de barra
		    ::oListSLK:ADD(::aEnvSLK) 
		Next
	EndIf
	
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
Method PrepDados() Class LJCAdapXmlRecSB1
	
	Local lRetorno 	:= .T.					//Retorno do metodo
	
	//Prepara os dados do produto
	lRetorno := ::PrepDadSB1()
	
	//Prepara os dados do codigo de barra	
	If lRetorno
		lRetorno := ::PrepDadSLK()
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
Method EnvDados() Class LJCAdapXmlRecSB1
    
	Local lRetorno 	:= .F.					//Retorno do metodo
	Local nCount	:= 0					//Variavel do tipo contador    

    Private lMsErroAuto := .F.				//Cria a variavel do retorno da rotina automatica
    Private lAutoErrNoFile := .T.			//Habilita a gravacao do erro da rotina automatica
    
    
    //Rotina automatica de produto
    If ::aEnvSB1 <> NIL .OR. ::aEnvSB0 <> NIL
		If Empty(::cOperSB1)
			//Faz a verificacao para saber se a opercao chegou vazio. Isso pode ser problema no MAPA do Produto que nao esta conseguindo ler o conteudo do XML enviado pelo RM
			::cError := "LOJA2134:" + STR0008 //"O conte๚do do tipo de opera็ใo chegou vazio. Verifique se o mapa estแ configurado corretamente ou se existe a opera็ใo informada no XML."
			lRetorno := .F.
		Else
	    	//Executa a rotina automatica
			LOJA110(::aEnvSB1, ::aEnvSB0, Val(::cOperSB1))
			
			If lMsErroAuto
				//Busca o erro da rotina automatica
				::cError := ::ErroRotAut()
			Else
				lRetorno := .T.
			EndIf
		EndIf
    Else
    	lRetorno := .T.
    EndIf
    
    //Rotina automatica de codigo de barra
    If lRetorno .AND. ::lCodBarra
    	//Processa todos os codigos de barra
    	For nCount := 1 To ::oListSLK:Count()
	    	//Executa a rotina automatica
			LOJA210(::oListSLK:Elements(nCount), Val(::cOperacao))
			
			If lMsErroAuto
				//Busca o erro da rotina automatica
				::cError := ::ErroRotAut()
				lRetorno := .F.
				Exit
			Else
				lRetorno := .T.
			EndIf
		Next
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
Method ConsistDad() Class LJCAdapXmlRecSB1
	
	Local lRetorno 	:= .T.							//Retorno do metodo
	Local nCount	:= 0							//Variavel auxiliar contador
			
	//Verifica o tipo de operacao a ser executada
	::cOperacao := ::oEstruXml:_FORMMODEL_PRODUTO:_OPERATION:TEXT
	
	//Verifica se existe o Node PRECO
	If ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO, _DELIMIT + "PRECO")	<> NIL 
		::lPreco := .T.
	EndIf
	
	//Verifica o tipo de tributacao do produto
	If ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO, _DELIMIT + "B1_TIPTRIB")	<> NIL 	
		::cTipTrib := ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_B1_TIPTRIB:_VALUE:TEXT 
	EndIF
	
	//Verifica se existe o Node CODIGOBARRAS
	If ::oXml:NodeExiste(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO, _DELIMIT + "CODIGOBARRAS")	<> NIL 
		
		::lCodBarra := .T.
		
		//Instancia o objeto LJCList
		::oListSLK	:= LJCList():New()
	EndIf
	
	//Formata os campos da chave com os devidos tamanhos
	::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_B1_COD:_VALUE:TEXT := ::FormatCamp("B1_COD", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_B1_COD:_VALUE:TEXT, ::oCamposSB1) 
			
	If ::lPreco
		::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_PRECO:_B0_COD:_VALUE:TEXT := ::FormatCamp("B0_COD", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_PRECO:_B0_COD:_VALUE:TEXT, ::oCamposSB0) 
	EndIf

	If ::lCodBarra		
		//Transforma o node em array
		::oXml:TransNodAr(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS, "_ITEMS")
		
		If ValType(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM) == 'O'
			//Transforma os dados
			::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM:_LK_CODBAR:TEXT := ::FormatCamp("LK_CODBAR", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM:_LK_CODBAR:TEXT, ::oCamposSLK) 
			::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM:_LK_CODIGO:TEXT := ::FormatCamp("LK_CODIGO", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM:_LK_CODIGO:TEXT, ::oCamposSLK) 
		Else
		   	For nCount := 1 TO Len(::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM)
				//Transforma os dados
				::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM[nCount]:_LK_CODBAR:TEXT := ::FormatCamp("LK_CODBAR", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM[nCount]:_LK_CODBAR:TEXT, ::oCamposSLK) 
				::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM[nCount]:_LK_CODIGO:TEXT := ::FormatCamp("LK_CODIGO", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_CODIGOBARRAS:_ITEMS[1]:_ITEM[nCount]:_LK_CODIGO:TEXT, ::oCamposSLK) 
			Next
		EndIf
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
Method FormatCamp(cCampo, cValor, oCampos) Class LJCAdapXmlRecSB1
	
	Local oRetorno := Nil					//Retorno do metodo
		
	Do Case

		Case cCampo == "B1_COD" .OR. cCampo == "B0_COD" .OR. ;
			 cCampo == "LK_CODBAR" .OR. cCampo == "LK_CODIGO"		     
		
			oRetorno := PadR(cValor, oCampos:ElementKey(cCampo):nTamanho , " ") 
		
	End Case
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณExisteSB1 บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
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
Method ExisteSB1() Class LJCAdapXmlRecSB1
	
	Local lRetorno 	:= .F.							//Retorno do metodo
	Local oProduto	:= NIl							//Objeto do tipo LJCEntProduto
	Local oRet		:= NIL							//Retorno da consulta
	
	//Instancia o objeto LJCEntProduto
	oProduto := LJCEntProduto():New()
	
	//Atribui os valores da chave
	oProduto:DadosSet("B1_COD", ::oEstruXml:_FORMMODEL_PRODUTO:_PRODUTO:_B1_COD:_VALUE:TEXT)
	
	//Consulta os dados	
	oRet := oProduto:Consultar(1)
	
	//Trata retorno
	If oRet:Count() > 0 
		lRetorno := .T.
	EndIf	
	
	FreeObj(oProduto)
	oProduto := Nil
	
	FreeObj(oRet)
	oRet := Nil
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
Method ValDefault() Class LJCAdapXmlRecSB1
	
	Local lRetorno 	:= .T.   				//Retorno do metodo
	Local nCount	:= 0					//Variavel auxiliar contador
	Local aDados	:= {}					//Array auxiliar
	Local oParamInt	:= Nil					//Objeto do tipo LJCEntParamInt 
	Local oRet		:= Nil					//Objeto de retorno da consulta da entidade MDQ
	Local cTs		:= ""					//Utilizada para guardar o valor da TES cadastrado nos parametros da integracao
	Local cInfo		:= ""					//Indica a mensagem de erro 
	Local aSB0		:= {}					//Array com os dados do SB0
	
	//Somente seta os valores default se a operacao for de INCLUSAO ou ALTERACAO
	If ::cOperSB1 != _EXCLUSAO
	
		//Trata os campos default do codigo de barra
		If ::lCodBarra 
			For nCount := 1 To ::oListSLK:Count()
				
				aDados := ::oListSLK:Elements(nCount)

				If Ascan(aDados, {|x| x[1] == "LK_QUANT"}) == 0
					AADD(aDados, {"LK_QUANT", 1, NIL})
				EndIF
			Next
		EndIf
		
		//Trata os campos default de preco
		If ::lPreco .AND. ::aEnvSB0 <> NIL
			//Adiciona os dados no array de envio
		    AADD(::aEnvSB0[1], {"B0_DATA1", CTOD("  /  /  "), NIL})
  		    AADD(::aEnvSB0[1], {"B0_DATA2", CTOD("  /  /  "), NIL})
   		    AADD(::aEnvSB0[1], {"B0_DATA3", CTOD("  /  /  "), NIL})
		    AADD(::aEnvSB0[1], {"B0_DATA4", CTOD("  /  /  "), NIL})
  		    AADD(::aEnvSB0[1], {"B0_DATA5", CTOD("  /  /  "), NIL})
   		    AADD(::aEnvSB0[1], {"B0_DATA6", CTOD("  /  /  "), NIL})
		    AADD(::aEnvSB0[1], {"B0_DATA7", CTOD("  /  /  "), NIL})
  		    AADD(::aEnvSB0[1], {"B0_DATA8", CTOD("  /  /  "), NIL})
   		    AADD(::aEnvSB0[1], {"B0_DATA9", CTOD("  /  /  "), NIL})
		EndIf

		//Tratar os campos default de produto
		If ::aEnvSB1 <> NIl
			
			//Instancia o Objeto LJCEntParamInt
			oParamInt := LJCEntParamInt():New()
			//Informa os campos chave 
			oParamInt:DadosSet("MDQ_CODIGO", "001")
			//Efetua a consulta		
			oRet := oParamInt:Consultar(1)
			
			If oRet:Count() > 0
				
				Do Case
					//Tributado
					Case ::cTipTrib == "T"
						cTs 	:= oRet:Elements(1):DadosGet("MDQ_TSTRIB")
						cInfo 	:= "LOJA2134:" + STR0002 //"Favor configurar a TES do produto tributado no cadastro de parโmetros de integra็ใo."
						
					//Substituido
					Case ::cTipTrib == "F"
						cTs := oRet:Elements(1):DadosGet("MDQ_TSSUBS")
						cInfo 	:= "LOJA2134:" + STR0003 //"Favor configurar a TES do produto substituido no cadastro de parโmetros de integra็ใo."
															
					//Nao Tributado								
					Case ::cTipTrib == "N"
						cTs := oRet:Elements(1):DadosGet("MDQ_TSNTRI")
						cInfo 	:= "LOJA2134:" + STR0004 //"Favor configurar a TES do produto nใo tributado no cadastro de parโmetros de integra็ใo."
										
					//Isento
					Case ::cTipTrib == "I"
						cTs := oRet:Elements(1):DadosGet("MDQ_TSISEN")
						cInfo 	:= "LOJA2134:" + STR0005 //"Favor configurar a TES do produto isento no cadastro de parโmetros de integra็ใo."
						
					//Redu็ใo de ICMS
					Case ::cTipTrib == "R" 
						If MDQ->( FieldPos("MDQ_TSREDU") ) > 0
							cTs 	:= oRet:Elements(1):DadosGet("MDQ_TSREDU")
							cInfo 	:= "LOJA2134:" + STR0009 //"Favor configurar a TES do produto de Redu็ใo de ICMS no cadastro de parโmetros de integra็ใo."
						Else
							cInfo 	:= "LOJA2134:" + STR0010 + " U_UpdLoj35 " + STR0011//"Campo MDQ_TSREDU nใo existe. Deve ser executado o update"### " U_UpdLoj35 " ###"para cria็ใo do campo."
						EndIf
					
					OtherWise
						
						cInfo 	:= "LOJA2134:" + STR0006 //"A mensagem recebida nใo esta com o conte๚do correto da tag B1_TIPTRIB."
						
				EndCase
				
				If Empty(cTs)
					lRetorno := .F.
					::cError := cInfo
				Else
					//Adiciona os dados no array de envio
				    AADD(::aEnvSB1, {"B1_TS", cTs, NIL})
			    EndIF
			Else
				lRetorno := .F.
				::cError := "LOJA2134:" + STR0007 //"Favor cadastrar os parโmetros de integra็ใo."
			EndIf				
			
		EndIf
	EndIf
	
	If oParamInt <> Nil
		FreeObj(oParamInt)
		oParamInt := Nil
	EndIf
	
	If oRet <> Nil
		FreeObj(oRet)
		oRet := Nil
	EndIf
		
Return lRetorno
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณDestrutor บAutor  ณVendas Clientes     บ Data ณ  26/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLimpa os objetos que foram criados	         			  บฑฑ
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
Method Destrutor() Class LJCAdapXmlRecSB1
	
   	_Super:Destrutor()
	
   	If Self:oCamposSB1 <> Nil
		FreeObj(Self:oCamposSB1)
		Self:oCamposSB1	:= NIL
	EndIf
	
	If Self:oCamposSB0 <> Nil	
		FreeObj(Self:oCamposSB0)
		Self:oCamposSB0	:= NIL
	EndIf

	If Self:oCamposSLK <> Nil	
		FreeObj(Self:oCamposSLK)
		Self:oCamposSLK	:= NIL
	EndIf

 	If Self:oListSLK <> Nil
		FreeObj(Self:oListSLK)
		Self:oListSLK	:= NIL
   	EndIf

Return Nil
