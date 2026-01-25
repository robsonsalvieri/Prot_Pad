#Include 'Protheus.ch'

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} AddDataMex
Popula a tabela MEX (Wizard)

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STCommuPopula()

Local aFields 	:= LoadFields()

RecData( aFields )

Conout("")	
Conout("")	
Conout("")	
Conout("")	
Conout("Tabela de comunicaçõ (XXY) Populada!!!")
Conout("")	
Conout("")	
Conout("")	
Conout("")	

MsgAlert("Tabela de comunicaçõ (XXY) Populada!!!")
			
// Finaliza Ambiente
RPCClearEnv()

Return Nil


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} LoadFields
Popula a tabela XXY

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function LoadFields()

Local aFields	:= {}

//					XXY_ID				XXY_DESC							   				 			  			XXY_FUNC						XXY_STATUS					
AADD( aFields , { 	'STWRECEIPT'	,	'Contigencia do Recebimento'						 		  			,	'STRecProcessContingency'	,	2			} )
AADD( aFields , { 	'STRECLOAD'	,	'Carrega Recebimento'	  		   				   			  			,	'STRecLoad'					,	2			} )
AADD( aFields , { 	'STDROPTITL'	,	'Baixa os titulos'	   			   				   			  			,	'STDropTitles'				,	2			} )
AADD( aFields , { 	'STREVERSED'	,	'Estorno de baixa de titulos'	   				   			   			,	'STReverseDropTitles'		,	2			} )
AADD( aFields , { 	'STBIMPORTR'	,	'Importa Orcamento'		  				   			  			,	'STBImportR'				,	2			} )
AADD( aFields , { 	'STBISGETOP'	,	'Pesquisa Orçamento'		   				   			   			,	'STBISGetOp'				,	2			} )
AADD( aFields , { 	'STDSEARCHC'	,	'Busca o cliente'				  				  			   			,	'STDSearchC'				,	2			} )
AADD( aFields , { 	'STDCUSTOME'	,	'Recebe dados do cliente'		   				  				 		,	'STDCustome'				,	2			} )
AADD( aFields , { 	'STDFINDNCC'	,	'Busca NCC do Cliente'  				  			   			,	'STDFindNCC'				,	2			} )
AADD( aFields , { 	'LJ7SLDEST'	,	'Verifica saldo em estoque'						   				  			   			,	'Lj7SldEst'					,	2			} )
AADD( aFields , { 	'LJ7GERASC0'	,	'Gera Solicitação de Compra'					  										,	'Lj7GeraSC0'				,	2			} )
AADD( aFields , { 	'LJ7CSRESDB'	,	'Consulta Reserva'					  					 			 		,	'Lj7CsResDB'				,	2			} )
AADD( aFields , { 	'LJ7CANCRES'	,	'Cancela Reserva'					  				   				 		,	'Lj7CancRes'				,	2			} )
AADD( aFields , { 	'GERAL1L2L4'	,	'Gera Venda'					   				   				 		,	'GeraL1L2L4'				,	2			} )
AADD( aFields , { 	'CONFL1L2L4'	,	'Confirma Venda'					  				   						,	'ConfL1L2L4'				,	2			} )
AADD( aFields , { 	'STDCANCREC'	,	'Cancela Venda'					  				   						,	'STDCancRec'				,	2			} )
AADD( aFields , { 	'GERAMBZ'  	,	'Gera Estorno'				 		  				   						,	'GeraMBZ'			   		,	2			} )
AADD( aFields , { 	'CONFMBZ'  	,	'Confirma Estorno'				 		   								 		,	'ConfMBZ'			 		,	2			} )
AADD( aFields , { 	'CA280CART'  	,	'Valida cartao fidelidade '		   					   			 		,	'Ca280Cart'			 		,	2			} )
AADD( aFields , { 	'CA280ISLD'  	,	'Realiza a inclusao de saldo do cartao fidelidade'	   			 		,	'CA280ISLD'			 		,	2			} )
AADD( aFields , { 	'CA280CALC'  	,	'Realiza consulta para verificar se o cartao tem saldo disponivel'		,	'Ca280Calc'			 		,	2			} )
AADD( aFields , { 	'WSCRD010'  	,	'Realiza a transacao de venda, quando ouver integracao com o SIGACRD'	,	'WSCRD010'			 		,	2			} )
AADD( aFields , { 	'WSCRD011'  	,	'Desfaz a transacao de credito, quando ouver integracao com o SIGACRD'	,	'WSCRD011'			 		,	2			} )
AADD( aFields , { 	'WSCRD012'  	,	'Confirma a transacao de credito, quando ouver integracao com o SIGACRD',	'WSCRD012'			 		,	2			} )
AADD( aFields , { 	'STBNCCINC'  	,	'Rotina de inclusao de NCCs.'											,	'STBNCCInc'			 		,	2			} )
AADD( aFields , { 	'STBINCLUIC'  	,	'Rotina de inclusao de titulo do tipo CR.'								,	'STBIncluiC'		 		,	2			} )
AADD( aFields , { 	'FRTINMOVNC'  	,	'Inclui movimento de compensacao'										,	'FrtInMovNC'		 		,	2			} )
AADD( aFields , { 	'CA280ASLD'  	,	'Atualiza saldo do cartao fidelidade.'									,	'Ca280ASld'		 	 		,	2			} )
AADD( aFields , { 	'GERASFI'  	,	'Gera dados da Redução Z'																,	'GeraSFI'		 	  		,	2			} )
AADD( aFields , { 	'GERAE5'  		,	'Gera dados Financeiro'																,	'GeraE5'		 	  		,	2			} )
AADD( aFields , { 	'GERASLX'  	,	'Gera LOG de Cancelmento'																,	'GeraSLX'		 	  		,	2			} )
AADD( aFields , { 	'FRT020ABR' 	,	'Faz abertura no server'												,	'FRT020ABR'		 	  		,	2			} )
AADD( aFields , { 	'FRT020FCH' 	,	'Faz fechamento no server'												,	'FRT020FCH'		 	  		,	2			} )
AADD( aFields , { 	'GERASZ'	 	,	'Gera movimento por ECF'																,	'GeraSZ'		 	  		,	2			} )
AADD( aFields , { 	'STDRECXDAT' 	,	'Gera tabela genérica'										,	'STDRecXDat'	 	  		,	2			} )
AADD( aFields , { 	'STDCONFREC' 	,	'Confirma recno no Server'									,	'STDConfRec'	 	  		,	2			} )
AADD( aFields , { 	'STFCOMMUOK' 	,	'Realiza teste de comunicacao'											,	'STFCommuOk'	 	  		,	2			} )
AADD( aFields , { 	'LJVLDVP'  	,	'Valida o vale presente '										   		,	'LjVldVP'	 	  	   		,	2			} )
AADD( aFields , { 	'LJVPVALOR'  	,	'Valor do vale presente '										   		,	'LjVPValor'	 	  	   		,	2			} )
AADD( aFields , { 	'LJGRRVP'  	,	'Atualiza vale presente '										   		,	'LjGrRVP'	 	  	   		,	2			} )
AADD( aFields , { 	'FINA040'  	,	'Gravacao da SE1 Recarga de Celular '							   		,	'Fina040'	 	  	   		,	2			} )
AADD( aFields , { 	'LJRECGRVCH'	,	'Gravacao dos dados do cheque '									   		,	'LJRecGrvCH' 	  	   		,	2			} )
AADD( aFields , { 	'FINA070'  	,	'Baixa de titulos a receber '									   		,	'FINA070'	 	  	   		,	2			} )
AADD( aFields , { 	'FR271HARQ'  	,	'Gera Arquivo de controle para nao permitir importar novamente'			,	'FR271HARQ'	 	  	   		,	2			} )
AADD( aFields , { 	'CA280ESLD'  	,	'Estorna o movimento e atualiza o saldo do cartao fidelidade'	   		,	'CA280ESLD'	 	  	   		,	2			} )
AADD( aFields , { 	'GERAA1'  		,	'Recebe o pacote de SA1 do Server Local '						   		,	'GERAA1'	 	  	   		,	2			} )
AADD( aFields , { 	'STBVLDRETC'  	,	'Valida se o cliente que sera cadastrado ja existe na base '	   		,	'STBVLDRETC'	  	   		,	2			} )
AADD( aFields , { 	'LJVPATIVA'  	,	'Volta o status do vale presente, durante o cancelamento da venda '		,	'LJVPATIVA'	  	   			,	2			} )
AADD( aFields , {  	'LJULTMOVAB'  	,	'Verifica o ultimo movimento aberto'  														,	'LjUltMovAb'  		   		,	2			} )
AADD( aFields , {  	'LJTEFGRVCB'  			,	'Grava dados do Correspondente Bancário'  														,	'LjTefGrvCB'  		   		,	2			} )
AADD( aFields , { 	'STDCUSTOMERDATA' 	,	'Cadastro do Cliente'  													,	'STDCustomerData'  	   		,	2			} )
AADD( aFields , { 	'STDSEARCHCOSTUMER' 	,	'Busca Cliente' 												,	'STDSearchCostumer'    		,	2			} )
AADD( aFields , {  	'LJGERTITNV'  			,	'Gera Título'  														,	'LJGerTitNV'  		   		,	2			} )
AADD( aFields , { 	'STBVLDRETCLI' 	 	,	'Valida se o Cliente existe na Retaguarda'  													,	'STBVldRETCli'  	   		,	2			} )
AADD( aFields , {  	'STBINCLUICR'  		,	'Gera Crédito'  														,	'STBIncluiCR'  		   		,	2			} )
AADD( aFields , { 	'FRTINMOVNCC'  		,	'Incluir movimento de conta a receber'  														,	'FrtInMovNCC'  		   		,	2			} )
AADD( aFields , { 	'STDRECXDATA'  		,	'Grava tabela Genérica'  														,	'STDRecXData'  				,	2			} )
AADD( aFields , { 	'STFCOMMUCP'  		,	'Testa comunicação com a Central'  									,	'STFCOMMUCP'  				,	2			} )
AADD( aFields , { 	'LJ600ESTOR'  		,	'Realiza Estorno de Venda'		  									,	'LJ600ESTOR'  				,	2			} )
AADD( aFields , { 	'_GeraL1L2L'  		,	'Sobe venda para Central de PDV'		  					 		,	'_GeraL1L2L'  				,	2			} )
AADD( aFields , { 	'_CONFL1L2L'  		,	'Confirma Venda para Central de PDV'		  			    		,	'_ConfL1L2L'  				,	2			} )
AADD( aFields , { 	'_STDCANCRE'  		,	'Cancelamento de Venda Central de PDV'		  			    		,	'_STDCANCRE'  				,	2			} )
AADD( aFields , { 	'STBGDATPRE'  		,	'Busca Vale Presente'		  							    		,	'STBGDATPRE'  				,	2			} )
AADD( aFields , { 	'STDQUERYDB'  		,	'Executa query no banco de dados da Retaguarda.'		    		,	'STDQUERYDB'  				,	2			} )

Return(aFields)


Static Function RecData( aFields )

Local nI		:= 0

Default aFields := {}

If Len(aFields) > 0 

	If Select("XXY") == 0
		FWOpenXXY()
	EndIf
	
	DbSelectArea("XXY")
	//DbSetOrder(1)
	
	For nI := 1 To Len(aFields)
	       
		If !(XXY->(DbSeek(AllTrim( aFields[nI][1] ))))
		      
			RecLock("XXY",.T.)
				
			REPLACE XXY_ID 		WITH aFields[nI][1]
			REPLACE XXY_DESC 	WITH aFields[nI][2]
			REPLACE XXY_FUNC	WITH aFields[nI][3]
			REPLACE XXY_STATUS	WITH aFields[nI][4]
		
			MsUnlock() 
			
		EndIf
	
	Next nI

EndIf

Return

