#Include "Protheus.ch"
#include "tbiconn.ch"
#include "STFCompDic.ch"

Static cFuncLog 	:= "Comparador_Bases"  //Identificacao da funcionalidade nos Logs   
Static aSX2 		:= {}	// Campos do SX2 avaliados  
Static aSX3 		:= {}	// Campos do SX3 avaliados   
Static aTables 		:= {}	// Tabelas avaliadas 
Static cMsgHTML 	:= ""	// html retorno para envio de email
Static lPDV			:= .F.	// Verifica se eh um PDV ou Front
Static cTipoExec 	:= STR0003  //Schedule/Job

//-------------------------------------------------------------------
/*/{Protheus.doc} STFCompDic
Compara dicionarios Retaguarda x PDV

@param    
@author  R.P.R
@version P12
@since   16/05/2016
@return  Nil
@obs     
@sampleq
/*/
//-------------------------------------------------------------------
Function STFCompDic()

Local lRet				:= .T.	// Retorno
Local cMsg				:= ""	//Mensagem execucao

lPDV := nModulo == 23 //Iniciado aqui pois no startjob nao é alimentado

If !IsBlind()//Se nao for Job ou servico exibe tela de aviso
	
	cTipoExec 	:= STR0002	//"Menu"  // Tipo de execução
	
	cMsg :=	STR0023 + CRLF +; //"Atenção, a rotina será executada em segundo plano(nova Thread). "
				STR0024 + CRLF +; //"O tempo de execução dependerá da quantidade de PDVs e disponibilidade de rede. "
				STR0025 + AllTrim(SuperGetMv("MV_LJMMAIL",,"")) + CRLF +; //"O resultado da análise será enviada para o E-mail: "
				STR0026 + CRLF +; //" configurado no parâmetro MV_LJMMAIL."
				STR0027 + "STFMailTes. " + CRLF  +; //" Caso não consiga receber o e-mail, realize um teste pela rotina "
				STR0028 + "tdn.totvs.com " + CRLF + CRLF +; //"Para mais informações acesse "
				STR0029 //"Gostaria de prosseguir?"
	
	
	If FWAlertYesNo(	cMsg , STR0001) //"Comparador de dicionários"
		FWAlertSuccess(STR0030, STR0031)//"Feche esta janela e aguarde o recebimento do e-mail." "Processo iniciado com sucesso"
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	
	
EndIf	

If lRet
	StartJob("STFSrvComp", GetEnvServer(), .F. ,cEmpAnt, cFilAnt , lPDV ,cTipoExec )
EndIf	

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSrvComp
Servico para comparar dicionarios Retaguarda x PDV

@param   cEmp - Empresa
@param   cFil - Filial
@param   lIsPDV - Eh PDV ou Front
@param   cTpExec - Tipo de execucao job/Menu
@author  R.P.R
@version P12
@since   16/05/2016
@return  lRet - Retorno se executou com sucesso.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSrvComp(cEmp, cFil , lIsPDV , cTpExec)

Local lRet			:= .F.	// Retorno
Local aHosts 		:= {}	// Array de configuracoes dos aHosts
Local nX   			:= 0	// Contador
Local cDestinat 	:= ""	// Destinatários do email separado por (;) ponto e virgula 
Local nSeconds 		:= 0 	// Armazena segundos inicial
Local cMsgHTML 		:= ""	// Mensagem email

Default cEmp 	:= ""
Default cFil 	:= ""
Default lIsPDV	:= .F.
Default cTpExec	:= STR0003  //Schedule/Job

LjGrvLog( cFuncLog , "ID_INICIO" )
nSeconds := Seconds() // Armazena segundos inicial

lPDV := lIsPDV
cTipoExec := cTpExec

If !Empty(cEmp) .AND. !Empty(cEmp)
	RPCSetType(3)
	// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
	RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")
EndIf  

MsgHTML 	:= "" //Zera statica

//Carrega dados da Configuracoes de comunicacao 
aHosts := STFLoadComunic()

If Len(aHosts) > 0 
	  
	For nX := 1 To Len(aHosts)
		
		aHosts[nX][10] := STFTestRpc( 	@aHosts[nX] )
		
	Next nX
	
	//Prepara/Formata email antes do envio
	cMsgHTML := STFFormtMail(aHosts)
		
	//Envia Email para responsavel
	If Empty( cMsgHTML )
		Conout("Não existem mensagens a enviar")
		LjGrvLog( cFuncLog , "Não existem mensagens a enviar" )
	Else
		
		cDestinat	:= SuperGetMv("MV_LJMMAIL",,"")
		
		//Envia Email para responsavel	
		If !Empty(cDestinat) .AND. ExistFunc("STFMail")	 	
			
			If STFMail( STR0001 , cMsgHTML, .F. , cDestinat) //"Comparador de dicionários"
				lRet := .T.
				Conout("Email enviado com sucesso")
				LjGrvLog( cFuncLog , "Email enviado com sucesso" )
				LjGrvLog( cFuncLog , cMsgHTML )
			Else
				Conout("Email não enviado, verifique as configurações")
				LjGrvLog( cFuncLog , "Email não enviado, verifique as configurações" )
				LjGrvLog( cFuncLog , cMsgHTML )
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
LjGrvLog(cFuncLog , "Tempo total de análise realizada pelo Comparador de Bases: " + AllTrim(Str(Seconds() - nSeconds) ) + " segundos.")
LjGrvLog( cFuncLog , "ID_FIM" )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFTestRpc
Realiza Analise diretamente nos hosts via RPC

@param aHosts  	// Array de configuracoes

@author  R.P.R
@version P12
@since   16/05/2016
@return  lConect - Retorna se conectou ou nao 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFTestRpc( aHosts )

Local aArea			:= GetArea()	// Armazena alias corrente 
Local aRet			:={}			// Array de retorno da funcao
Local oServer     	:= Nil 			// Objeto que chama Classe de RPC
Local cEmpresa 		:= ""   		// Empresa
Local cFilHost 		:= ""   		// Filial do Host
Local nPorta  		:= 0   			// Porta Rpc do Host
Local cAmb 			:= ""   		// Ambiente do Host
Local cIPHost 		:= ""   		// IP do Host
Local nPosSX       	:= 0	   		// Posicao do campo
Local nY   			:= 0    		// Contador
Local nX   			:= 0    		// Contador
Local nZ   			:= 0    		// Contador
Local aSX3Ret		:= {}  	 		// Campos busca Retaguarda
Local aRetHost		:= {}			// Retorno do Host 
Local cValid 		:= ""			// Valores da validacao opcional
Local cHost_M_EMP 	:= ""			// Modo tabela Host
Local cHost_M_UN 	:= ""			// Modo tabela unidade Host
Local cHost_M_FIL 	:= ""			// Modo tabela empresa Host
Local cLoc_M_EMP 	:= ""			// Modo tabela Local
Local cLoc_M_UN 	:= ""			// Modo tabela unidade Local
Local cLoc_M_FIL 	:= ""			// Modo tabela empresa Local
Local cCampo 		:= ""			// Campo para analise
Local xValHost		:= Nil			// Valor campo no Host para comparacao
Local xValLocal		:= Nil			// Valor campo Local para comparacao
Local lConect     	:= .F. 			// Retorno de RPC fez comunicação

Default aHosts  	:= {} 			// Array de configuracoes

cEmpresa	:= aHosts[01]
cFilHost  	:= aHosts[02]
nPorta	  	:= Val( aHosts[05] )
cAmb 	  	:= aHosts[04]
cIPHost   	:= AllTrim(aHosts[06])

//Campos que serao retornados dos Hosts
If Len(aSX2) <= 0
	aSX2 := {"X2_CHAVE","X2_MODO","X2_MODOUN","X2_MODOEMP"}
EndIf

If Len(aSX3) <= 0	
	aSX3 := {"X3_ARQUIVO","X3_CAMPO","X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_PICTURE","X3_VALID","X3_VLDUSER","X3_USADO","X3_RELACAO","X3_CBOX"}
EndIf

If Len(aTables) <= 0 
	aTables := {"SL1","SL2","SL4","SFI","SB1","SB0","DA0","DA1","SBI","SLK","SA1","SA3","SAE","SE4","SF4","SF7","SA6","SLF","SLG"}
EndIf	

//Abre Conexao com o Host destino
If !Empty(cAmb) .AND. !Empty(cIPHost) 
	oServer := TRPC():New( cAmb )	
	If oServer:Connect( cIPHost, nPorta )  
	
		LjGrvLog( cFuncLog ,"Conectou no Ambiente: " + cAmb  + " IP: " + cIPHost + " Porta:" + aHosts[05])	
			
		//Prepara Amb diretamente no Host Conectado
		oServer:CallProc("RPCSetType", 3 )
		lConect := oServer:CallProc("RPCSetEnv", cEmpresa, cFilHost,,,'FRT')
		lConect := IIF(ValType(lConect) == "L",lConect,.F.)
		
		If lConect
			LjGrvLog( cFuncLog ,"Ambiente preparado com sucesso no Host. Empresa: " + cEmpresa + ", Filial: " + cFilHost )
		Else
			LjGrvLog( cFuncLog ,"Não conseguiu preparar ambiente no Host. Empresa: " + cEmpresa + ", Filial: " + cFilHost )
		EndIf
	Else
		LjGrvLog( cFuncLog ,"Não Conectou no Ambiente: " + cAmb  + " IP: " + cIPHost + " Porta:" + aHosts[05])
		aHosts[7] 	:= .F. 		// 07 - Status conexao	
	EndIf	
	
EndIf	

If lConect 
	
	LjGrvLog( cFuncLog ,"[V] Conectou na Filial: " + cFilHost + " , Empresa: " + cEmpresa + " , Ambiente: " + cAmb + " IP: " + cIPHost + " Porta:" + aHosts[05] )
	aHosts[7] 	:= lConect 		// 07 - Status conexao		
		
	//Manter FindFunction mesmo para versao P12 pois ExistFunc da erro em alguns Bin/Lib
	If oServer:CallProc("FindFunction", "STFPesqTab" )
		
		For nY := 1 To Len(aTables)
		
			//===================
			//Realiza Busca SX2	
			aRetHost := {}			
			aRetHost := oServer:CallProc("STFPesqTab","SX2", 1 , "SX2->X2_CHAVE" , aTables[nY] , aSX2 , .F. , ""  )
						
			If ValType(aRetHost) == "A" .AND. Len(aRetHost) > 0		
				
				For nX := 1 To Len(aRetHost)
					 
					cHost_M_EMP 	:= aRetHost[nX][Ascan( aRetHost[1] , {|x| x[1] == "X2_MODOEMP"})][2]
					cHost_M_UN 		:= aRetHost[nX][Ascan( aRetHost[1] , {|x| x[1] == "X2_MODOUN"})][2]  
					cHost_M_FIL		:= aRetHost[nX][Ascan( aRetHost[1] , {|x| x[1] == "X2_MODO"})][2]
					
					cLoc_M_EMP 	:= FWModeAccess(aTables[nY],1)//1=Empresa
					cLoc_M_UN 		:= FWModeAccess(aTables[nY],2)//2=Unidade de Negócio
					cLoc_M_FIL 	:= FWModeAccess(aTables[nY],3)//3=Filial
					
					//Validacao compartilhamento 					
					If cHost_M_EMP <> cLoc_M_EMP
						Aadd( aRet , {aTables[nY] ,"X2_MODOEMP","X2_MODOEMP",cHost_M_EMP ,cLoc_M_EMP } )
					EndIf
					
					If cHost_M_UN <> cLoc_M_UN
						Aadd( aRet , {aTables[nY] ,"X2_MODOUN","X2_MODOUN",cHost_M_UN ,cLoc_M_UN } )
					EndIf
					
					If cHost_M_FIL <> cLoc_M_FIL
						Aadd( aRet , {aTables[nY] ,"X2_MODO","X2_MODO",cHost_M_FIL ,cLoc_M_FIL } )
					EndIf
					
										
				Next nX			
				
			Else
				LjGrvLog( cFuncLog , "Não conseguiu extrair informações da SX2 no Host solicitado. Alias: " + aTables[nY] )
			EndIf
			
			//=================
			//Realiza Busca SX3
			aRetHost := {}		
			aRetHost := oServer:CallProc("STFPesqTab","SX3", 1 , "SX3->X3_ARQUIVO" , aTables[nY] , aSX3 , .F. , ""  )
			
			If ValType(aRetHost) == "A" .AND. Len(aRetHost) > 0		
				
				//Busca campos na retaguarda para comparacao
				aSX3Ret := STFPesqTab(	"SX3" 	, 1 	, "SX3->X3_ARQUIVO" , aTables[nY] ,;
											aSX3  			, .F. 	, "" )
				
				For nX := 1 To Len(aRetHost)
				
					cCampo := AllTrim(aRetHost[nX][Ascan( aRetHost[nX] , {|x| x[1] == "X3_CAMPO"})][2])

					If !Empty(cCampo)
					    
					   	nPosSX := Ascan( aSX3Ret , {|x| AllTrim(x[2][2]) == cCampo })
						If nPosSX > 0
						
					   		//Compara Base Local x Host
					   		For nZ := 1 To Len(aSX3)

						   		//Conteudo no Host
						   		xValHost := aRetHost[nX][Ascan( aRetHost[nX] , {|x| x[1] == aSX3[nZ] })][2]
						   		
						   		//Conteudo Local
						   		xValLocal := aSX3Ret[nPosSX][Ascan( aSX3Ret[nPosSX] , {|x| x[1] == aSX3[nZ] })][2]

					   			If( ValType(xValHost) == "N" )
					   				xValHost := STR(xValHost)
					   			EndIf
					   			
					   			If( ValType(xValLocal) == "N" )
					   				xValLocal := STR(xValLocal)
					   			EndIf
						   									   		
						   		If xValHost <> xValLocal
						   			//Campo divergente
									Aadd( aRet , { aTables[nY] ,cCampo , aSX3[nZ] , AllTrim(xValHost) ,AllTrim(xValLocal) } )
						   		EndIf
						   		
						   	Next nZ	
					   		
						Else
							//Campo nao existe na Base Local somente no Host
							Aadd( aRet , {aTables[nY] ,cCampo , "X3_CAMPO" , STR0021 ,STR0022 } ) // "Ok"  "Campo não existe"
						EndIf
					Else
						LjGrvLog( cFuncLog , "Campo retornou vazio, verificar na SX2/SX3 Alias: " + aTables[nY] )
					EndIf	
					
				Next nX
				
				For nX := 1 To Len(aSX3Ret)
				
					cCampo := AllTrim(aSX3Ret[nX][Ascan( aSX3Ret[nX] , {|x| x[1] == "X3_CAMPO"})][2])
					
					If !Empty(cCampo)
					 
						If Ascan( aRetHost , {|x| AllTrim(x[2][2]) == cCampo }) <= 0
							//Campo nao existe no Host somente na base Local
							Aadd( aRet , {aTables[nY] ,cCampo,"X3_CAMPO",STR0022 ,STR0021 } ) // "Campo não existe"  "Ok"  
						EndIf
					EndIf	
					
				Next nX					
				
			Else
				LjGrvLog( cFuncLog , "Não conseguiu extrair informações da SX3 no Host solicitado. Alias: " + aTables[nY] )
			EndIf
		
		Next nY
		
	Else
		Conout("Host não preparado para executar função STFPesqTab. Atualizar Host. ")
		LjGrvLog( cFuncLog ,"Host não preparado para executar função STFPesqTab. Atualizar. " )		
	EndIf
Else
	LjGrvLog( cFuncLog ,"[X] Não Conectou na Filial: " + cFilHost + " , Empresa: " + cEmpresa + " , Ambiente: " + cAmb  + " IP: " + cIPHost + " Porta:" + aHosts[05])
	aHosts[7] 	:= .F. 		// 07 - Status conexao	
EndIf


If lConect
	oServer:CallProc("RpcClearEnv") //Limpa Thread do server conectado
	oServer:Disconnect()//Disconecta do server
	FreeObj(oServer)//Limpa Obj
EndIf
	
RestArea(aArea)
 
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFLoadComunic
Retorna Configuracoes de comunicacao 

@param 
@author  R.P.R
@version P12
@since   16/05/2016
@return  aRet - Retorna configuracao de comunicacao disponivel
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFLoadComunic()

Local	aArea		:= GetArea()		// Armazena alias corrente
Local 	aRet 		:= {} 				// Retorno

LjGrvLog( cFuncLog , "Carrega Configurações: MD4,MD3. " + IIF(lPDV,"PDV.","RET."))

DbSelectArea( "MD4" )
DbSetOrder(1)//MD4_FILIAL+MD4_CODIGO		
If MD4->(DbSeek(xFilial("MD4")))
				
	While MD4->MD4_FILIAL == xFilial( "MD4" ) .AND. MD4->(!EOF())
	
	 	//If !Empty(MD4->MD4_AMBPAI)
		DbSelectArea( "MD3" )
		DbSetOrder( 1 )//MD3_FILIAL+MD3_CODAMB+MD3_TIPO
		If MD3->(DbSeek( xFilial( "MD3" ) + MD4->MD4_CODIGO ))						
			While MD3->(!EOF()) .AND. MD3->MD3_CODAMB == MD4->MD4_CODIGO
				If AllTrim(MD3->MD3_TIPO) == "R" //Somente ambientes RPC
				
					If (!lPDV .AND. !Empty(MD4->MD4_AMBPAI)) .OR. (lPDV .AND. Empty(MD4->MD4_AMBPAI))
			
				 		Aadd( aRet, { MD3->MD3_EMP	,;	// 01 - Empresa
						MD3->MD3_FIL					,;	// 02 - Filial
						MD3->MD3_CODAMB				,;	// 03 - Cod Ambiente
						AllTrim(MD3->MD3_NOMAMB)		,;	// 04 - Nome ambiente
						MD3->MD3_PORTA				,;	// 05 - Porta RPC
						AllTrim(MD3->MD3_IP) 		,;	// 06 - Ip
						.F.								,;	// 07 - Status conexao
						.F.						 		,;	// 08 - Divergencia encontrada
						""						 		,;	// 09 - OBS
						{}						 		,;	// 10 - Array de informacoes Retornadas do Host
						AllTrim(MD3->MD3_DESCRI)		} )	// 11 - Descricao
						
				 	EndIf
				 	
			 	EndIf
		 		MD3->(DbSkip())
		 	End
	 		
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
/*/{Protheus.doc} STFFormtMail
Formata html para envio do email

@param 	  aHosts - Array com as informacoes colhidas nos Hosts 
@author  R.P.R
@version P12
@since   16/05/2016
@return  cMsgHTML - html Formatado
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STFFormtMail(aHosts)

Local nY   			:= 0   //Contador
Local nX   			:= 0   //Contador
Local cData			:= AllTrim(DTOC( date()) )	//Guarda data e hora formatada
Local cTime			:= Time()	//Guarda hora formatada
Local cStatusHost 	:= "" 		//Msg aux p compor email principal
Local cMsgFinal  	:= ""     	//Msg para final da mensagem
Local lDiverg 		:= .F.		//Existem divergencias nas bases
Local cListAmbs		:= ""		//Lista de Ambientes analisados
Local nTamMaxStr	:= 0 	//Analisa tamanho max string
Local lExit 		:= .F. 	//Controla saida quando chegou no limite de Str 
Local cSrvStrMax 	:=	AllTrim(GetPvProfString("General","MaxStringSize","1",GetAdv97()) )

Default aHosts 		:= {}	 //array de configuracoes

LjGrvLog( cFuncLog , "Formata Html")

LjGrvLog( cFuncLog , "Tamanho Maximo da String  na seção General. MaxStringSize=" + cSrvStrMax )
nTamMaxStr := Val(cSrvStrMax) * 1000000 //Multiplica por 1000000 para sobra um pouco para o rodapé. o limite é 1048575

//Add Cabecalho principal
cMsgHTML :=	'<table style="border-color: black; float: left;" border="0" width="800">'+;
		'<tbody>'+;
		'<tr style="height: 30px;">'+;
		'<td style="text-align: center; background-color: #0070c0;" colspan="2"><span style="color: #ffffff;"><strong> ' + ; 
			STR0001 + ' </strong></span></td>'+;  //"Comparador de dicionários"
		'</tr>'+;
		'<tr style="height: 30px;">'+;
		'<td style="width: 200px; background-color: #d0cece;">&nbsp;' + STR0004 + '</td>'+; //"Data de Analise:"
		'<td style="background-color: #d0cece;">&nbsp;' + cData + '</td>'+;
		'</tr>'+;
		'<tr style="height: 30px;">'+;
		'<td style="width: 200px; background-color: #d0cece;">&nbsp;' + STR0005 + '</td>'+; //"Hora de Analise:"
		'<td style="background-color: #d0cece;">&nbsp;' + cTime + '</td>'+;
		'</tr>'+;
		'<tr style="height: 30px;">'+;
		'<td style="width: 200px; background-color: #d0cece;">&nbsp;' + STR0006 + '</td>'+;// "Tipo de Execucao"
		'<td style="background-color: #d0cece;">&nbsp;' + cTipoExec + '</td>'+;
		'</tr>'+;
		'</tbody>'+;
		'</table>'+;
		'<br>'
					
	
For nX := 1 To Len(aHosts)           

	//Se nao conectou ou encontrou divergencias
	If !aHosts[nX][7] .OR. Len(aHosts[nX][10]) > 0
	    
	    lDiverg := .T.
	    	    
	    cListAmbs += IIF(Empty(cListAmbs),"",", ") + AllTrim(aHosts[nX][3]) 
	    
		// 07 - Status conexao
		cStatusHost :=  IIf(aHosts[nX][7],"",STR0007) + STR0008 + aHosts[nX][6] + STR0009 + aHosts[nX][5] //" Não" "Conectado IP: " " Porta: "
	
		cMsgHTML +=	'<table style="width: 800px;">'+;
		'<tbody>'+;
		'<tr style="height: 30px;">'+;
		'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + ;
			IIF(lPDV,"",STR0010) + aHosts[nX][11] + STR0011 + aHosts[nX][2] + " - " + FWFilialName(,aHosts[nX][2],2) + " - " + cStatusHost + ;
			'</strong></span></td>'+;  //"PDV: "" Filial: "
		'</tr>' +; 
		'</tbody>'+;
		'</table>'
		
		If aHosts[nX][7] .AND. Len(aHosts[nX][10]) > 0
		
			cMsgHTML +=	'<table style="width: 800px;">'+;
			'<tbody>'+;		
			'<tr style="height: 30px;">'+;
			'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0012 + '</strong></span></td>'+;  //"Tabela" 		
			'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0013 + '</strong></span></td>'+;  //"Campo"  		
			'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + STR0014 + '</strong></span></td>'+;  //"Dicionário" 	
			'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + IIF(lPDV,STR0016,STR0015) + '</strong></span></td>'+;  //"Retaguarda" "PDV" 		
			'<td style="text-align: center; background-color: #0070c0;"><span style="color: #ffffff;"><strong>&nbsp;' + IIF(lPDV,STR0015,STR0016) + '</strong></span></td>'+;  //"PDV" "Retaguarda" 					
			'</tr>'		
		EndIf									
				
	EndIf			
	
	For nY := 1 To Len(aHosts[nX][10]) 	
					 
		cMsgHTML 	+=	'<tr style="height: 30px;">'+;
		'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + aHosts[nX][10][nY][1] + '</td>' + ; // Tabela 
		'<td style="text-align: left;   background-color: #d0cece;">&nbsp;' + aHosts[nX][10][nY][2] + '</td>' + ; // Campo
		'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + aHosts[nX][10][nY][3] + '</td>' + ; // Dicionário
		'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + aHosts[nX][10][nY][4] + '</td>' + ; // PDV/Retaguarda
		'<td style="text-align: center; background-color: #d0cece;">&nbsp;' + aHosts[nX][10][nY][5] + '</td>' + ; // Retaguarda
		'</tr>'

		//Analise tamanho para não estourar limite de strings
		If Len(cMsgHTML) > nTamMaxStr
			LjGrvLog( cFuncLog , "ID_ALERT")
			LjGrvLog( cFuncLog , "Chegou Perto do limite da string. Processo será interrompido.")
			lExit := .T.
			cMsgFinal += 	'<br><p style="color: #ff0808;"><b> ' + STR0035 + cSrvStrMax +" Mb" + CRLF + ; //"ATENÇÃO: Processo interrompido pois foi atingido o limite da string Padrão: "
							STR0036 + "tdn.totvs.com" + ; //"Para mais informações consultar configuração MaxStringSize em "
							'</b></p><br>'
			Exit 
		EndIf					
					
	Next nY				

	cMsgHTML += '</tbody>'+;
				'</table>'+;	 
				'<br>'


	If lExit
		Exit //Forca saida por causa do estouro da string
	EndIf

Next nX
	
If lDiverg
	cMsgFinal += STR0017  //"Verifique a(s) divergência(s) encontrada(s)."
	cMsgFinal += CRLF + STR0032  //"Atenção, Nem todas as diferenças indicam erro. Em alguns casos o sistema pode trabalhar com versões diferentes para PDV e Retaguarda."	
Else
	cMsgFinal := STR0018  //"Nenhuma divergência encontrada!"
EndIf

cMsgFinal +=  CRLF + CRLF + STR0033 + "(MD3_CODAMB)" + STR0034 + CRLF + cListAmbs //"Lista dos Ambientes" " Analisados: "
					
cMsgHTML +=	'<br>'+;
				cMsgFinal
			

Return cMsgHTML


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna as perguntas definidas no schedule.
@return aReturn			Array com os parametros
@author  R.P.R
@since   12/01/2017
@version 11.8
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;		//Tipo R para relatorio P para processo
            "ParamDef",;//Pergunte do relatorio, caso nao use passar ParamDef
            ,;			//Alias
            ,;			//Array de ordens
            }			//Titulo

Return aParam

