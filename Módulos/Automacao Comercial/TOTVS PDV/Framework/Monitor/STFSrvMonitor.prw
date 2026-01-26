#Include "Protheus.ch"
#include "tbiconn.ch"
#include "STFSrvMonitor.ch"

Static cFuncLog 	:= "Monitor_PDVs"  //Identificacao da funcionalidade nos Logs   
Static aCFG 		:= {} 		 //Array de configuracoes gerais

#DEFINE CFG_MAXREPROC		1	//Quantidade maxima de tentativa de reprocessar a venda
#DEFINE CFG_SHOWPDVOFF		2	//Mostra Pdvs Off-Line
#DEFINE CFG_STATUS			3 	//Avalia vendas no PDV com estes Status 
#DEFINE CFG_QTDDIAS			4 	//Quantidade de dias a avaliar a partir da data do dia descrescente 


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSrvMonitor
Servico para monitorar vendas represadas nos PDVs

@param   nQtdDias      Quantidade de dias a analisar 
@author  rafael.pessoa
@version P11.8
@since   16/05/2016
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSrvMonitor( nQtdDias )

Local aMD3 			:= {}	 //array de configuracoes
Local nX   			:= 0    //Contador
Local lConect 		:= .F.  //Status conexao
Local cDestinat  		:= SuperGetMv("MV_LJMMAIL",,"") //Destinatários do email separado por (;) ponto e virgula 
Local nSeconds 		:= 0 	// Armazena segundos inicial
Local lDiverg			:= .F. // Encontrou divergencias
Local aRetPdv			:= {}	// Retorno dos PDVs
Local cMsgEmail 		:= ""	// Mensagem email
Local nSalesNoSend	:= 0	// Quantidade de vendas nao enviadas
Local nSalesErro		:= 0	// Quantidade de vendas com erros
Local cPDV 			:= ""	// Numero do PDV

Default nQtdDias		:= 0   //Quantidade de dias sobrescreve os parametro

LjGrvLog( cFuncLog , "ID_INICIO" )

nSeconds := Seconds() // Armazena segundos inicial

//Atencao - Deixar no começo da funcao
//Carrega configuracoes gerais 
aCFG := STFMonitCfg()

//Carrega dados da MD3(Configuracoes de comunicacao)
aMD3 := STFLoadMD3()

If Len(aMD3) > 0 
	  
	For nX := 1 To Len(aMD3)
		lConect        := .F.
		lDiverg        := .F.
		nSalesNoSend   := 0
		nSalesErro   	 := 0
		cPDV           := ""		
		
		aRetPdv := STFTestRpc( 	aMD3[nX] 		, @lConect , @lDiverg , @nSalesNoSend ,;
								 	@nSalesErro 	, @cPDV    , nQtdDias   	 )
		
		aMD3[nX][7] 	:= lConect 		// 7 - Status conexao
		aMD3[nX][8] 	:= lDiverg 		// 8 - Divergencia encontrada
		aMD3[nX][9] 	:= nSalesNoSend 	// 9 - Vendas Pendentes
		aMD3[nX][10] 	:= nSalesErro		// 10 - Vendas com Erro
		aMD3[nX][11] 	:= cPDV			// 11 - Numero do PDV
		aMD3[nX][12] 	:= aRetPdv 		// 12 - Array de vendas Retornadas do PDV
		
	Next nX
	
	//Prepara email formatado
	cMsgEmail := STFFormtMail(aMD3)
		
	//Envia Email para responsavel
	If Empty( cMsgEmail )
		Conout("Não existem mensagens a enviar")
		LjGrvLog( cFuncLog , "Não existem mensagens a enviar" )
	Else

		//Envia Email para responsavel	
		If !Empty(cDestinat) .AND. ExistFunc("STFMail")	 	
			
			If STFMail( STR0001 , cMsgEmail, .F. , cDestinat) //"Monitor de PDVs"
				Conout("Email enviado com sucesso")
				LjGrvLog( cFuncLog , "Email enviado com sucesso" )
				LjGrvLog( cFuncLog , cMsgEmail )
			Else
				Conout("Email não enviado, verifique as configurações")
				LjGrvLog( cFuncLog , "Email não enviado, verifique as configurações" )
				LjGrvLog( cFuncLog , cMsgEmail )
			EndIf	
		Else
			If Empty(cDestinat)
				Conout("Destinatários não informados no parâmetro MV_LJMMAIL")
				LjGrvLog( cFuncLog , "Destinatários não informados no parâmetro MV_LJMMAIL" )	
			Else
				Conout("Função STFMail não encontrada no ambiente. Favor Atualizar.")
				LjGrvLog( cFuncLog , "Função STFMail não encontrada no ambiente. Favor Atualizar." )	
			EndIf	
		EndIf
						
	EndIf		

EndIf	


//Grava tempo de execução apenas no Log
LjGrvLog(cFuncLog , "Tempo total de análise realizada pelo Monitor de PDVs: " + AllTrim(Str(Seconds() - nSeconds) ) + " segundos.")
LjGrvLog( cFuncLog , "ID_FIM" )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFFormtMail
Formata email para envio

@param 	  aMD3 - Array com as informacoes colhidas nos PDVs 
@author  rafael.pessoa
@version P11.8
@since   16/05/2016
@return  cMsgEmail - Email Formatado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFFormtMail(aMD3)

Local cMsgEmail 	:= "" 	//Retorna Email formatado
Local cMsgAux 	:= "" 	//Msg aux p compor email principal
Local nX   		:= 0   //Contador
Local cData		:= AllTrim(DTOC( date()) )	//Guarda data e hora formatada
Local cTime		:= Time()	//Guarda data e hora formatada
Local ctipoExec 	:= STR0002 	//Tipo execucao // "Menu"  
Local cStatusPdv 	:= "" 		//Msg aux p compor email principal

Default aMD3 		:= {}	 //array de configuracoes

//Verifica se é Schedule/Job
If IsBlind()
	ctipoExec 	:= STR0003  //Schedule/Job
EndIf

For nX := 1 To Len(aMD3)           

	If aMD3[nX][7] // 7 - Status conexao
		cStatusPdv := STR0004 + aMD3[nX][6] + STR0006 + aMD3[nX][5] //"Conectado Ip: " // " Porta: "
	Else
		cStatusPdv := STR0005 + aMD3[nX][6] + STR0006 + aMD3[nX][5]	//"Não Conectado Ip: " // " Porta: "
	EndIf
			
	//Se tem divergencia ou nao conseguiu conectar		
	If aMD3[nX][8] .OR. (!aMD3[nX][7] .AND. aCfg[CFG_SHOWPDVOFF] == "S")	// 8 - Divergencia encontrada // 7 - Status conexao
						
		cMsgAux 	+=	'<tr style="height: 30px;">'+;
						'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + aMD3[nX][2] + '</td>'+; // 'Código da Filial'
						'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + FWFilialName(,aMD3[nX][2],2) + '</td>'+; // Nome da Filial
						'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + aMD3[nX][11] + '</td>'+;//'Código do Pdv'
						'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + cStatusPdv + '</td>'+;//'Status da Conexão'
						'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + Alltrim(STR(aMD3[nX][9]+aMD3[nX][10])) + '</td>'+;//'Vendas pendentes no PDV'
						'</tr>'
	EndIf

Next nX

//Se Encontrou mensagem de mail a enviar formata
//cabecalho junto do corpo do email
If !Empty(cMsgAux)

	//Add Cabecalho principal
	cMsgEmail :=	'<table style="border-color: black; float: left;" border="0" width="800">'+;
					'<tbody>'+;
					'<tr style="height: 30px;">'+;
					'<td style="text-align: center; background-color: #0070c0;" colspan="2"><span style="color: #ffffff;"><strong> ' + STR0007 + ' </strong></span></td>'+;  //"Analise de Processamento de Vendas"
					'</tr>'+;
					'<tr style="height: 30px;">'+;
					'<td style="width: 200px; background-color: #d0cece;">&nbsp;' + STR0008 + '</td>'+; //"Data de Analise:"
					'<td style="background-color: #d0cece;">&nbsp;' + cData + '</td>'+;
					'</tr>'+;
					'<tr style="height: 30px;">'+;
					'<td style="width: 200px; background-color: #d0cece;">&nbsp;' + STR0009 + '</td>'+; //"Hora de Analise:"
					'<td style="background-color: #d0cece;">&nbsp;' + cTime + '</td>'+;
					'</tr>'+;
					'<tr style="height: 30px;">'+;
					'<td style="width: 200px; background-color: #d0cece;">&nbsp;' + STR0010 + '</td>'+;// "Tipo de Execucao"
					'<td style="background-color: #d0cece;">&nbsp;' + ctipoExec + '</td>'+;
					'</tr>'+;
					'</tbody>'+;
					'</table>'+;
					'<br>'+;
					'<table style="width: 800px;">'+;
					'<tbody>'+;
					'<tr style="height: 30px;">'+;
					'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0011		+ '</strong></span></td>'+;  //"Código da Filial"
					'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0012 	+ '</strong></span></td>'+;  //"Nome da filial"' 
					'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0013 	+ '</strong></span></td>'+;  //"Código do Pdv" 
					'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0014	 	+ '</strong></span></td>'+;  //"Status da Conexão"
					'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0015 	+ '</strong></span></td>'+;  //"Vendas pendentes no PDV"				
					'</tr>'
					
	cMsgEmail +=	cMsgAux +;
					'</tbody>'+;
					'</table>'+;
					'<br>'+;
					IIf(!Empty(aCfg[CFG_STATUS]), STR0016 + aCfg[CFG_STATUS], STR0017 ) //"Verifique nestes PDVs vendas com status cujo campo L1_SITUA = " ### //"Verifique as vendas nestes PDVs "
							
EndIf			

Return cMsgEmail


//-------------------------------------------------------------------
/*/{Protheus.doc} STFTestRpc
Realiza Analise diretamente nos PDVs via RPC

@param aConfigPdv  	// Array de configuracoes
@param lConect     	// Retorno de RPC fez comunicação
@param lDiverg			// Encontrou divergencias
@param nSalesNoSend	// Quantidade de vendas nao enviadas
@param nSalesErro		// Quantidade de vendas com erros
@param cPDV			// Numero do PDV
@param nQtdDias		// Quantidade de dias a analisar 

@author  rafael.pessoa
@version P11.8
@since   16/05/2016
@return  lConect - Retorna se conectou ou nao 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFTestRpc( aConfigPdv , lConect , lDiverg 	, nSalesNoSend ,;
 								nSalesErro , cPDV    , nQtdDias )

Local aArea			:= GetArea()	// Armazena alias corrente 
Local oServer     	:= Nil 		// Objeto que chama Classe de RPC
Local cEmpresa 		:= ""   		// Empresa
Local cFilPDV 		:= ""   		// Filial do PDV
Local nPorta  		:= 0   		// Porta Rpc do PDV
Local cAmb 			:= ""   		// Ambiente PDV
Local cIPPdv 			:= ""   		// IP do PDV
Local aStruSL1Pdv		:= {}   		// Estrutura da Tabela SL1 do PDV
Local nPosL1Fil		:= 0   		// Posicao Filial do SL1
Local nPosL1Num		:= 0   		// Posicao Num do SL1
Local nPosL1Pdv		:= 0   		// Posicao PDV do SL1
Local nPosL1Situa		:= 0   		// Posicao Situa do SL1
Local nPosL1Doc     	:= 0	   		// Posicao Doc do SL1
Local nPosL1Serie    := 0   		// Posicao Serie do SL1
Local nPosL1Cliente  := 0   		// Posicao Cliente do SL1
Local nPosL1VlrLiq   := 0   		// Posicao Valor Liquido do SL1	
Local cL1Serie 		:= ""			// serie da Venda do PDV
Local cL1Doc   		:= ""			// Doc da Venda do PDV
Local cL1Num   		:= ""			// Num da Venda do PDV
Local cL1Situa 		:= ""			// Situa da Venda do PDV
Local cL1Cliente 		:= ""			// Cliente da Venda do PDV
Local nL1VlrLiq 		:= 0			// Valor Liquido da Venda do PDV
Local aL1Error		:={}			// Array vendas com erros marcar p reprocessar
Local aL1Pendentes	:={}			// Array vendas pendentes
Local nX   			:= 0    		// Contador
Local nY   			:= 0    		// Contador
Local cSituaReproc	:= "00"		// Situa para Reprocessar
Local cMsgAux   	   	:= ""			// Mensagem auxiliar para compor Email principal
Local nSalesReproc	:= 0			// Quantidade de vendas marcadas para reprocessar
Local cPictVlrLiq		:= PesqPict("SL1","L1_VLRLIQ")//Picture do valor liquido
Local cMoedaSimb		:= SuperGetMV( "MV_SIMB" + Str(1 ,1 ) ) //Simbolo da Moeda
Local aTables 		:= {"SL1"}  	// Tabelas abertas por RPC
Local aSL1 			:= {}  	 	// Campos da SL1 que ira trazer na busca
Local aRetServer		:= {}			// Retorno do Servidor
Local cNso				:= ""			// Usamos o campo L1_NSO para gravar qtd de tentativas de reprocessamento
Local nMaxReproc     := Val(aCfg[CFG_MAXREPROC])		// Numero maximo de tentativas de reprocessar venda
Local cStatusVenda	:= aCfg[CFG_STATUS]	// Estatus de vendas que se quer buscar no PDV 
Local cValid 			:= ""			// Valores da validacao opcional
Local cData			:= ""			// Data a ser analisada

Default aConfigPdv  	:= {} 			// Array de configuracoes
Default lConect     	:= .F. 		// Retorno de RPC fez comunicação
Default lDiverg		:= .F. 		// Encontrou divergencias
Default nSalesNoSend	:= 0			// Quantidade de vendas nao enviadas
Default nSalesErro	:= 0			// Quantidade de vendas com erros
Default cPDV			:= ""			// Numero do PDV
Default nQtdDias		:= 0			// Quantidade de Dias para Analise 


cEmpresa := aConfigPdv[01]
cFilPDV  := aConfigPdv[02]
nPorta	  := Val( aConfigPdv[05] )
cAmb 	  := aConfigPdv[04]
cIPPdv   := AllTrim(aConfigPdv[06])

//Valida o periodo recebido
If nQtdDias < 1 .OR. nQtdDias > 90
	nQtdDias := Val(aCfg[CFG_QTDDIAS]) //quantidade padrao do Param	
	//Garante que o usuario nao preencheu parametro correto 
	If nQtdDias < 1 .OR. nQtdDias > 90
		nQtdDias := 1
	EndIf
EndIf

//Campos da SL1 que serao retornados dos PDVs
aSL1 := {"L1_FILIAL","L1_NUM","L1_DOC","L1_SERIE","L1_PDV","L1_SITUA","L1_CLIENTE","L1_VLRLIQ","L1_NSO"}

//Abre Conexao com o PDV destino
oServer := TRPC():New( cAmb )
lConect := oServer:Connect( cIPPdv, nPorta )

If lConect
		
	LjGrvLog( cFuncLog ,"[V] Conectou na Filial: " + cFilPDV + ", Ambiente: " + cAmb )	
			
	If !Empty(cStatusVenda)
		cValid := "SL1->L1_SITUA $ "+ "'" + cStatusVenda + "'" 
	EndIf	
			
	//Prepara Amb diretamente no PDV Conectado
	oServer:CallProc("RPCSetType", 3 )
	oServer:CallProc("RPCSetEnv", cEmpresa, cFilPDV,,,'FRT',,{"SL1"})//aTables
	
	If oServer:CallProc("ExistFunc", "STFPesqTab" )
		//Busca vendas
		For nY := nQtdDias To 1 Step -1
		
			cData := DTOS( date() - (nY-1)  )
			aRetServer := oServer:CallProc("STFPesqTab","SL1", 7 , "SL1->L1_FILIAL + DTOS(SL1->L1_EMISSAO)",xFilial("SL1") + cData , aSL1 , .F. , cValid  )
						
			If ValType(aRetServer) == "A" .AND. Len(aRetServer) > 0		

				dbSelectarea("SL1")
				dbSetorder(2)//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
				
				For nX := 1 To Len(aRetServer)
				
					cFilPDV		:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_FILIAL"})][2] 
					cL1Serie 		:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_SERIE"})][2]
					cL1Doc   		:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_DOC"})][2]
					cL1Num   		:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_NUM"})][2]
					cL1Situa 		:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_SITUA"})][2] 
					cL1Cliente 	:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_CLIENTE"})][2] 
					nL1VlrLiq 		:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_VLRLIQ"})][2]
					cPDV			:= aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_PDV"})][2]
					cNso			:= AllTrim(aRetServer[nX][Ascan( aRetServer[1] , {|x| x[1] == "L1_NSO"})][2]) 
				
					If cL1Situa <> "07"
					
						//Se Nao encontrar venda
						If !SL1->( DbSeek( cFilPDV + cL1Serie + cL1Doc ) ) //Nao considera cancelamento "07"
							
							lDiverg := .T. //Marca que encontrou divergencias
							
							//Guarda vendas com erro para remarcar para reprocessar
							If cL1Situa == "ER"	
								nSalesErro ++		
								Aadd( 	aL1Error 		,; 
									{ 	cFilPDV		,;	// 1
										cL1Num			,;	// 2
										cL1Serie		,;	// 3
										cL1Doc			,;	// 4
										cL1Situa		,;	// 5
										cL1Cliente		,;	// 6
										nL1VlrLiq 		,;	// 7
										cNso			} )	// 8		
							Else
							
								nSalesNoSend ++
							
								Aadd( 	aL1Pendentes 		,; 
									{ 	cFilPDV		,;	// 1
										cL1Num			,;	// 2
										cL1Serie		,;	// 3
										cL1Doc			,;	// 4
										cL1Situa		,;	// 5
										cL1Cliente		,;	// 6
										nL1VlrLiq 		} )	// 7	
													
							EndIf
						EndIf
						
					EndIf	
					
				Next nX
				
			Else	
				//Nao Conectou no ambientes especificado
				LjGrvLog( cFuncLog , "Não existem informações na data solicitado " + cData )
			EndIf
			
		Next nY	
	Else
		Conout("PDV não preparado para executar função STFPesqTab. Atualizar. ")
		LjGrvLog( cFuncLog ,"PDV não preparado para executar função STFPesqTab. Atualizar. " )		
	EndIf
Else
	LjGrvLog( cFuncLog ,"[X] Não Conectou na Filial: " + cFilPDV + ", Ambiente: " + cAmb )	
EndIf

// Vendas com Erro Marca para reprocessar diretamente no PDV
If Len(aL1Error) > 0 .AND. nMaxReproc > 0
	
	cMsgAux := ""
	  
	For nX := 1 To Len(aL1Error)
	
		cNso := aL1Error[nX][8]
		IIf( Empty(cNso) , cNso := "1" , cNso := Soma1(cNso) )
	
		//Busca a venda no PDV e alterar para reprocessar
		If Val(cNso) <= nMaxReproc .AND. oServer:CallProc("STFAltTab", "SL1" , 2 , aL1Error[nX][1] + aL1Error[nX][3] + aL1Error[nX][4] , { {"L1_SITUA", "00"},{"L1_NSO",cNso} } )
		
			nSalesReproc ++
			If Val(cNso) < 1
				nSalesErro --
			EndIf	
			
			//Mensagem apenas para o Log
			cMsgAux += 	"A venda de número: " + aL1Error[nX][2] + " da Filial: "  	+ aL1Error[nX][1]    	+;
							" Serie: " + aL1Error[nX][3] + " Doc: "    	+ aL1Error[nX][4] 	 	+;
							" Cliente: " + aL1Error[nX][6] +;
							" Valor: " + cMoedaSimb+" "+AllTrim(Transform(aL1Error[nX][7],cPictVlrLiq))+;
				 			" . L1_SITUA Alterado de " + aL1Error[nX][5] + " para 00." + CRLF 

		EndIf

	Next nX
	
	//Se encontrou vendas no PDv que não existem 
	//na retaguarda add msg de email
	If nSalesReproc > 0
		LjGrvLog( cFuncLog , cMsgAux )
	EndIf
	
EndIf	

If lConect

	oServer:CallProc("RpcClearEnv") //Limpa Thread do server conectado
	oServer:Disconnect()//Disconecta do server
	FreeObj(oServer)//Limpa Obj
	
	//Se nao houve divergencia
	If !lDiverg
		LjGrvLog( cFuncLog , "PDV Filial: " + cFilPDV + " Sem divergência." )
	EndIf
	
EndIf
	
RestArea(aArea)
 
Return aL1Pendentes


//-------------------------------------------------------------------
/*/{Protheus.doc} STFLoadMD3
Retorna Configuracoes de comunicacao Alias MD3

@param 
@author  rafael.pessoa
@version P11.8
@since   16/05/2016
@return  aRet - Retorna configuracao dos PDVs disponiveis
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFLoadMD3()

Local	aArea		:= GetArea()	// Armazena alias corrente
Local 	aRet 		:= {} 			// Retorno

LjGrvLog( cFuncLog , "Carrega PDVs: MD4,MD3")

DbSelectArea( "MD4" )
DbSetOrder(1)//MD4_FILIAL+MD4_CODIGO		
If MD4->(DbSeek(xFilial("MD4")))
				
	While MD4->MD4_FILIAL == xFilial( "MD4" ) .AND. MD4->(!EOF())
	
	 	If !Empty(MD4->MD4_AMBPAI)
			DbSelectArea( "MD3" )
			DbSetOrder( 1 )//MD3_FILIAL+MD3_CODAMB+MD3_TIPO
			If MD3->(DbSeek( xFilial( "MD3" ) + MD4->MD4_CODIGO ))						
				While MD3->(!EOF()) .AND. MD3->MD3_CODAMB == MD4->MD4_CODIGO
					If AllTrim(MD3->MD3_TIPO) == "R" //Somente ambientes RPC
					
				 		Aadd( aRet, { MD3->MD3_EMP	,;	// 1 - Empresa
						MD3->MD3_FIL					,;	// 2 - Filial
						MD3->MD3_CODAMB				,;	// 3 - Cod Ambiente
						AllTrim(MD3->MD3_NOMAMB)		,;	// 4 - Nome ambiente
						MD3->MD3_PORTA				,;	// 5 - Porta RPC
						AllTrim(MD3->MD3_IP) 		,;	// 6 - Ip
						.F.								,;	// 7 - Status conexao
						.F.						 		,;	// 8 - Divergencia encontrada
						.F.						 		,;	// 9 - Divergencia encontrada
						.F.						 		,;	// 10 - Divergencia encontrada
						""						 		,;	// 11 - Numero do PDV
						{}						 		} )	// 12 - Array de vendas Retornadas do PDV
						
				 	EndIf
			 		MD3->(DbSkip())
			 	End
		 	EndIf
	 	EndIf
	 	
		MD4->(DbSkip())
	End

Else
	LjGrvLog( cFuncLog , "Registros não encontrados na tabela MD4")
EndIf	

If Len(aRet) > 0
	LjGrvLog( cFuncLog , "Registros encontrados nas tabelas MD3,MD4" , aRet)
Else
	LjGrvLog( cFuncLog , "Registros não encontrados na tabela MD3,MD4")	
EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFMonitCfg
Retorna Configuracoes gerais do Monitor 

@param 
@author  rafael.pessoa
@version P11.8
@since   03/06/2016
@return  aRet - Retorna configuracao gerais
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFMonitCfg()

Local 	nTamArray	:= 4 										// Define o tamanho do array de configuracoes, deixar essa como primeira variavael
Local 	aRet 		:= Array(nTamArray) 						// Retorno
Local  cCfg		:= AllTrim(SuperGetMv("MV_LJMOCFG",,""))// Configuracoes do Monitor  tamanho max param 250 caracteres
Local  aParam		:= {}										// Guarda informacoes do parametro quebrado em array por ponto e virgula
Local  lParamOK	:= .F. 									// Valida se os parametros estao integros

LjGrvLog( cFuncLog , "Configurações MV_LJMOCFG: ", cCfg)

If Len(aRet) >= nTamArray //Respeitar sempre o tamanho da declaração nTamArray

	If !Empty(cCfg) 
		aParam := STRTOKARR(cCfg,";")      
		lParamOK := ValType(aParam) == "A" .AND. Len(aParam) >= nTamArray
	EndIf  

	If !lParamOK .OR. Empty(cCfg)
		LjGrvLog( cFuncLog , "MV_LJMOCFG não reipeitou tamanho minimo de " + Alltrim(STR(nTamArray)) +  "parametros será redefinido para 0;S;ER|DU;1")
	EndIf

	//Carrega Parametros Padroes
	aRet[CFG_MAXREPROC] 		:= IIf(lParamOK,aParam[CFG_MAXREPROC]		,"0") 					//01 - Quantidade maxima de tentativa de reprocessar a venda
	aRet[CFG_SHOWPDVOFF] 	:= IIf(lParamOK,aParam[CFG_SHOWPDVOFF]		,"S") 					//02 - Mostra Pdvs Off-Line ou nao preparados no email
	aRet[CFG_STATUS] 			:= IIf(lParamOK,aParam[CFG_STATUS]			,"ER|DU")      		//03 - Avalia vendas no PDV com estes Status
	aRet[CFG_QTDDIAS] 		:= IIf(lParamOK,aParam[CFG_QTDDIAS]		,"1")   				//04 - Quantidade de dias a avaliar a partir da data do dia descrescente
	
EndIf	


Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.
@return aReturn			Array com os parametros
@author  rafael.pessoa
@since   03/06/2016
@version 11.8
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "ParamDef",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            }				//Titulo

Return aParam

