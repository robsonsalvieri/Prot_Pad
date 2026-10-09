#INCLUDE "MSOBJECT.CH"
#include "FiveWin.ch"

User Function LOJA0025 ; Return  // "dummy" function - Internal Use 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCTopConnect		บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse responsavel em executar os comandos para top connect         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCTopConnect From LJADataBase
	
	Method New(oEntidade)						//Metodo construtor
	Method Consultar()							//Metodo que ira consultar os dados da tabela atraves do indice especificado
	Method Alterar()				   			//Metodo que ira alterar os dados da tabela atraves do indice especificado
	Method Incluir()							//Metodo que ira incluir um registro na tabela
	Method Excluir()							//Metodo que ira excluir os dados da tabela atraves do indice especificado						
    
    //Metodos internos
	Method MontCampos()							//Metodo que ira montar os campos do select
	Method MontaWhere(cWhere)					//Metodo que ira montar a clausula where
	Method FormataVal(cTipo, oValor, nTamanho)	//Metodo que ira formatar um valor, Subscrito da classe LJADataBase
	Method MontaOrdBy()							//Metodo que ira montar o order by
	Method MontaSet(cSet)						//Metodo que ira montar o set com os campos que serao alterados
	Method FormataRet(cTipo, oValor)			//Metodo que ira formatar o retorno da consulta
			
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJAEntidade.		                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 (1 - oEntidade) - Entidade.			                  บฑฑ															  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(oEntidade) Class LJCTopConnect
	
	//Executa o metodo construtor da classe pai
	_Super:New()
	
	::oEntidade := oEntidade

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณConsultar บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em consultar os dados da tabela atraves 		  บฑฑ
ฑฑบ			 ณdo indice especificado.									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ							    							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto   									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Consultar() Class LJCTopConnect	

	Local cQuery	:= ""							//Query que sera executada
	Local nCount	:= 0							//Varivel de controle contador
	Local oRecodSet := Nil							//Objeto do tipo LJCRegistrosEntidade, retorno do metodo
	Local oCloneEnt := Nil							//Objeto do tipo LJAEntidade
	Local nRegistro := 1							//Variavel do tipo contador
	Local oValor 	:= Nil							//Valor do campo consultado
	Local cWhere	:= ""							//Clausula where montada pelo indice
	Local lQuery	:= .T.							//Verifica se o comando foi montado corretamente
	Local lContinua	:= .T.							//Sinaliza que deverแ parar o while, evitando problemas quando possuir muitas transa็๕es
	Local nBytes	:= 0							//Sinaliza quantos bytes tem a transa็ใo
	Local aArea     := GetArea()
	Local lBuscaMD6 := .T.                          // Sinaliza se precisa buscar informa็ใo na MD6
	//Estancia o objeto LJCRegistrosEntidade
	oRecodSet := LJCRegistrosEntidade():New()
	
	//Monta a query
	cQuery := "SELECT " + ::MontCampos()
	cQuery += " FROM " + RetSqlName(::oEntidade:cTabela)
	
	//Monta a clausula where
	lQuery := ::MontaWhere(@cWhere)
	cQuery += " WHERE " + cWhere
	
	//Monta o order by
	If lQuery
		cQuery += " ORDER BY " + ::MontaOrdBy()
	EndIf
	
	//Se for falso, he porque os dados do indice foram informados incorretamente
	//porem a consulta nao sera efetuada
	If lQuery
		
		cQuery := ChangeQuery(cQuery)
		
		//Executa a query
		DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TCN", .T., .F. )
		
		//Seleciona o arquivo
		DbSelectArea("TCN")
		
		//Posiciona no primeiro registro
		TCN->(dbGoTop())
		
		//Verifica se e final de arquivo
		nBytes := 0 
		While !TCN->(EOF()) .AND. lContinua
			If ::oEntidade:cTabela == "MD7" 
				If MD7->(FieldPos("MD7_TAMMD6")) > 0 
					If Val(TCN->MD7_TAMMD6) > 0 
						nBytes +=Val(TCN->MD7_TAMMD6)
						lBuscaMD6 := .F.
					EndIf	
	 			EndIf
	 			// se o campo nใo existir ou MD7_TAMMD6 estiver zerado
	 			If lBuscaMD6 
	 				aArea := GetArea()
	 				dbSelectArea("MD6")
	 				MD6->(dbSetOrder(1))
	 				If MD6->(msSeek(xFilial("MD6")+TCN->MD7_TRANS))
	 					While MD6->(!EOF() .AND. TCN->MD7_TRANS == MD6->MD6_TRANS )
							nBytes +=  MD6->(RECSIZE())
							MD6->(dbSkip())
	 					End
	 				EndIf             
					RestArea(aArea)
				EndIf	
 			EndIf

			//Limita o processamento para no mแximo 1000 transacoes(MD7), para evitar queda do WebService
			If ((nRegistro >= 1000 ) .AND. ::oEntidade:cTabela == "MD7" ) .OR. ;
			   ((nBytes   >= 500000) )
				lContinua := .F.
			EndIf		
			
			//Faz um clone da entidade
			oCloneEnt := ::oEntidade:Clonar()
			
			//Carrega os campos da entidade clonada		
			For nCount := 1 To oCloneEnt:Campos():Count() 	
				//Verifica se o campo nao e do tipo Memo, pois caso ele contenha valor ele nao estara no Alias temporario "TCN"
				If oCloneEnt:Campos():Elements(nCount):cTipo != "M"
					//Pega o nome do campo da entidade
					cCampo := oCloneEnt:Campos():Elements(nCount):cNome
					//Formata o valor consultado
					oValor := ::FormataRet(oCloneEnt:Campos():Elements(nCount):cTipo, &(("TCN")->(cCampo)))
					//Atribui o valor a entidade
					oCloneEnt:DadosSet(cCampo, oValor)
				EndIf					
			Next
			
			//Adiciona o registro na colecao	
			oRecodSet:ADD("R" + AllTrim(Str(nRegistro)), oCloneEnt)    
			nRegistro++    
			
			//Vai para o proximo registro    
			TCN->(DbSkip())
			
		End
		
		//Fecha a area do arquivo
		DbCloseArea()
	EndIf
					
Return oRecodSet
			
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณAlterar   บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em alterar os dados da tabela atraves do indice บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ							    							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico   									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Alterar() Class LJCTopConnect

	Local lRetorno 	:= .F.						//Retorno do metodo
	Local cQuery	:= ""						//Query que sera executada
	Local cWhere	:= ""						//Clausula where montada pelo indice
	Local cSet		:= ""						//String com o s campos que serao alterados
	Local lQuery	:= .T.							//Verifica se o comando foi montado corretamente	
	
	//Monta a query
	cQuery := "UPDATE " + RetSqlName(::oEntidade:cTabela)
	
	//Monta a string com os campos que serao alterados
	lQuery := ::MontaSet(@cSet) 
	cQuery += " SET " + cSet
	
	//Monta a clausula where
	If lQuery
		lQuery := ::MontaWhere(@cWhere)
		cQuery += " WHERE " + cWhere
	EndIf
	
	//Se for falso, he porque os dados do indice foram informados incorretamente ou nao foi
	//informado nenhum campo para alteracao, porem o update nao sera efetuado
	If lQuery
		If TcSqlExec(cQuery) >= 0
			lRetorno := .T.	
		EndIf
	EndIf
			
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณIncluir   บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em incluir um registro na tabela				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ							    							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico   									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Incluir() Class LJCTopConnect

	Local lRetorno 	:= .F.						//Retorno do metodo
	Local oCodeBase	:= Nil						//Objeto do tipo LJCCodeBase
	
	//Estancia o objeto LJCCodeBase
	oCodeBase := LJCCodeBase():New(::oEntidade)
	
	lRetorno := oCodeBase:Incluir() 
	
	//Obs: Nao foi criado o comando de insert via top, porque o top na trata o recno
			
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณExcluir   บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em excluir os dados da tabela atraves do indice บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ							 								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico   									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Excluir() Class LJCTopConnect

	Local lRetorno := .F.						//Retorno do metodo
	Local cQuery	:= ""						//Query que sera executada
	Local cWhere	:= ""						//Clausula where montada pelo indice
	Local lQuery	:= .T.						//Verifica se o comando foi montado corretamente	
	
	//Monta a query
	cQuery := "UPDATE " + RetSqlName(::oEntidade:cTabela)
	cQuery += " SET D_E_L_E_T_ = '*'"
	
	//Monta a clausula where
	lQuery := ::MontaWhere(@cWhere)
	cQuery += " WHERE " + cWhere
		
	//Se for falso, he porque os dados do indice foram informados incorretamente
	//porem o update nao sera efetuado
	If lQuery
		If TcSqlExec(cQuery) >= 0
			lRetorno := .T.	
		EndIf
	EndIf
			
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMontCamposบAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em montar os campos do select					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ							 								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString 									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MontCampos() Class LJCTopConnect

	Local cRetorno := "" 						//Retorno do metodo
	Local nCount	:= 0						//Varivel de controle contador
	
	//Pega todos os campos para fazer o select
	For nCount := 1 To ::oEntidade:Campos():Count()
		cRetorno += ::oEntidade:Campos():Elements(nCount):cNome + ", "
	Next

	//Tira a virgula do final da string
	cRetorno := Substr(cRetorno, 1, Len(cRetorno) - 2)	
	
Return cRetorno					

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMontaWhereบAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em montar a clausula where					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cWhere) - Clausula where que sera retornada	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico 									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MontaWhere(cWhere) Class LJCTopConnect

	Local lRetorno 	:= .T.				//Retorno do metodo
	Local oIndice 	:= Nil				//Objeto do tipo LJCDadosIndice
	Local nCount	:= 0				//Varivel de controle contador
	Local oCampo	:= Nil				//Campos da entidade, objeto do tipo LJCDadosCampo
	Local cCampo	:= ""				//Nome do campo do indice
	Local nCampNulo	:= 0				//Se algum campo do indice esta como nulo
	Local cCampFil	:= ""				//Guarda o nome do campo filial
		
	//Verifica se existe o indice na entidade
	If ::oEntidade:Indices():Contains(::oEntidade:nIndice)
		
		//Pega os dados do indice
		oIndice :=	::oEntidade:Indices():ElementKey(::oEntidade:nIndice) 
		
		//Alimenta o posicao do campo nulo como sendo o ultimo
		nCampNulo := oIndice:Campos():Count()
		
		//Verifica quantos campos tem no indice e pega os valores para montar o where
		For nCount := 1 To oIndice:Campos():Count()
			
			//Pega o campo do indice
			cCampo := oIndice:Campos():Elements(nCount)
			
			//Pega os dados do campo na entidade
			oCampo := ::oEntidade:Campos():ElementKey(cCampo)
			
			//Guarda o nome do campo filial, se a entidade comecar com "S" significa que o campo comeca
			//com as duas ultima letras da entidade, senao, considerar as 3 letras da entidade
			If Substr(::oEntidade:cTabela, 1, 1) == "S"
				cCampFil := Substr(::oEntidade:cTabela, 2, 2) + "_FILIAL"
			Else
				cCampFil := Substr(::oEntidade:cTabela, 1, 3) + "_FILIAL"
			EndIf
			
			//Verifica se o campo e filial e se foi atribuido valor a ele
			If cCampo == cCampFil
				If oCampo:oValor == Nil
					oCampo:oValor := xFilial(::oEntidade:cTabela)				
				EndIf			
			EndIf
			
			If oCampo:oValor != Nil
			//Nao faz a consulta porque a sequencia dos campos informados no indice esta incorreta
				If nCount > nCampNulo
				   cWhere := ""
				   Exit
				EndIf
				
				//Formata o valor e monta a clausula where
				cWhere += cCampo + " = "
				cWhere +=	::FormataVal(oCampo:cTipo, oCampo:oValor, oCampo:nTamanho)
				cWhere += " AND "
			Else
				nCampNulo := nCount
			EndIf
		Next
		
		//Desconsidera os registros excluidos 
		If !Empty(cWhere)
			cWhere += "D_E_L_E_T_ = ' '"
		Else
			lRetorno := .F.
		EndIf
		
	EndIf	
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFormataValบAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em formatar um valor.		                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cTipo) 	- Tipo do campo.		              บฑฑ
ฑฑบ			 ณExpO1 (2 - oValor) 	- Valor a ser formatado.              บฑฑ
ฑฑบ			 ณExpN1 (3 - nTamanho) 	- Tamanho do campo.		              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FormataVal(cTipo, oValor, nTamanho) Class LJCTopConnect
	
	Local oRetorno := Nil					//Retorno do metodo
    	
	Do Case
		//Tipo caracter
		Case cTipo == "C"
			oRetorno := "'" + PadR(oValor, nTamanho , " ") + "'"
			
		//Tipo data
		Case cTipo == "D"
			oRetorno := "'" + DTOS(oValor) + "'"
		
		//Tipo numerico
		Case cTipo == "N"
			oRetorno := cValToChar(oValor)
			
		//Outros tipos		
		OtherWise
			oRetorno := oValor
	EndCase    
	
Return oRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMontaOrdByบAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em montar o order by	    					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ							 								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณString 									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MontaOrdBy() Class LJCTopConnect

	Local cRetorno 	:= ""				//Retorno do metodo
	Local oIndice 	:= Nil				//Objeto do tipo LJCDadosIndice
	Local nCount	:= 0				//Varivel de controle contador
	Local oCampo	:= Nil				//Campos da entidade, objeto do tipo LJCDadosCampo
	Local cCampo	:= ""				//Nome do campo do indice
			
	//Pega os dados do indice
	oIndice :=	::oEntidade:Indices():ElementKey(::oEntidade:nIndice) 
	
	//Verifica quantos campos tem no indice e pega os valores para montar o where
	For nCount := 1 To oIndice:Campos():Count()
		
		//Pega o campo do indice
		cCampo := oIndice:Campos():Elements(nCount)
		
		//Pega os dados do campo na entidade
		oCampo := ::oEntidade:Campos():ElementKey(cCampo)
				
		//If oCampo:oValor != Nil
			//Formata o valor e monta a clausula where
			cRetorno += cCampo + ", "
		//EndIf
	Next
	
	//Tira a virgula do final da string
	cRetorno := Substr(cRetorno, 1, Len(cRetorno) - 2)
	
Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณMontaSet  บAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em montar os campos que serao alterado          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cSet) - String de retorno com os campos que seraoบฑฑ
ฑฑบ			 ณ					 serao alterados						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico 									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method MontaSet(cSet) Class LJCTopConnect

	Local lRetorno 	:= .T.				//Retorno do metodo
	Local oIndice 	:= Nil				//Objeto do tipo LJCDadosIndice
	Local nCount	:= 0				//Varivel de controle contador
	Local oCampo	:= Nil				//Campos da entidade, objeto do tipo LJCDadosCampo
			
	//Pega os dados do indice 1 pk
	oIndice :=	::oEntidade:Indices():ElementKey(1) 
	
	//Verifica quantos campos tem na entidade e pega os valores para montar o set
	For nCount := 1 To ::oEntidade:Campos():Count()
		//Pega os dados do campo na entidade
		oCampo := ::oEntidade:Campos():Elements(nCount)
		//Verifica se o campo faz parte do indice 1 pk, esses campos nao podem ser alterados
		If !oIndice:Campos():Contains(oCampo:cNome) 
											
			If oCampo:oValor != Nil
				//Formata o valor e monta a clausula where
				cSet += oCampo:cNome + " = "
				cSet +=	::FormataVal(oCampo:cTipo, oCampo:oValor, oCampo:nTamanho)
				cSet += " ,"
			EndIf
		
		EndIf
	Next
	
	//Tira a virgula do final da string
	If !Empty(cSet)
		cSet := Substr(cSet, 1, Len(cSet) - 2)
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFormataRetบAutor  ณVendas Clientes     บ Data ณ  25/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em formatar o valor retornado da consulta.      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 (1 - cTipo) 	- Tipo do campo.		              บฑฑ
ฑฑบ			 ณExpO1 (2 - oValor) 	- Valor a ser formatado.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method FormataRet(cTipo, oValor) Class LJCTopConnect

	Local oRetorno := Nil				//Retorno do metodo
	
	//Tipo logico
	If cTipo == "L"
		If (ValType(oValor) == "C" .AND. oValor == "T") .OR. (ValType(oValor) == "L" .AND. oValor)
			oRetorno := .T.
		Else
			oRetorno := .F.
		EndIf
	//Tipo data
	ElseIf cTipo == "D" .AND. ValType(oValor) == "C"
		If !Empty(oValor)
			oRetorno := STOD(oValor)
		Else
			oRetorno := oValor
		EndIf
	//Outros
	Else		
		oRetorno := oValor
	EndIf

Return oRetorno



