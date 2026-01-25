#Include 'Protheus.ch'
#Include "TbiConn.ch"
#Include "AP5MAIL.CH"

Static aEmails 	:= {} //Endereço de emails que receberam a mensagem
Static aConexao := {} //PDVs que não conseguiram acesso

/*/{Protheus.doc} CargaMon
	Job de Monitoramento das Cargas Offline x Online
	@type  Function
	@author Bruno Almeida
	@since 05/10/2023
	@version 12
	@param cEmpLocal, caractere, codigo da empresa
	@param cFilLocal, caractere, codigo da filial
	@param cEmail, caractere, emails que serão enviados as mensagens 
	@param cInterval, caractere, tempo que sera executada novamente a rotina
	@param cQtdCarga, caractere, quantidade de pacotes pendentes de atualização para disparar o e-mail

/*/
Function CargaMon(cEmpLocal, cFilLocal, cEmail, cInterval, cQtdCarga)
Local nMaxRet		:= 0
Local lAviso		:= .F.
Local aAmbOff		:= {}             
Local cTime			:= ""            
Local nTempo		:= 0    
Local nMaxPacotes 	:= 0

Default cInterval := "600000" //Tempo defaul 10 minutos
Default cQtdCarga := "5"

cFilLocal := PadR(cFilLocal,FWSizeFilial())

RPCSetType(3) 
PREPARE ENVIRONMENT EMPRESA cEmpLocal FILIAL cFilLocal TABLES "MBU" MODULO "LOJ"

aEmails 	:= StrTokArr(cEmail,";")
nTempo 		:= Val(cInterval)
nMaxPacotes := Val(cQtdCarga)

While !KillApp()
	
	cTime := Subs(Time(),1,5)     
       
	nMaxRet := RetMaxNum()  // Retorna o maior valor gerado pela carga da Retaguarda (já convertido em número)
	Conout("Iniciando o JOB de monitoramento das cargas - Hora: " + Time())

	lAviso := ValOffNum(nMaxRet,@aAmbOff,nMaxPacotes)
	
	If lAviso // Avisa que as cargas estao sem sincronismo
		CargaMail("1",aAmbOff,nMaxRet)
	Endif

	lAviso := Len(aConexao) > 0

	If lAviso // Ambientes que nao foi possivel conectar para monitorar a carga
		CargaMail("2")
	Endif

	aAmbOff  := {}
	lAviso   := .F.
	nMaxRet  := 0

	Conout("Finalizando o JOB de monitoramento das cargas - Hora: " + Time())
	Conout('')

	Sleep(nTempo)

End

Return Nil       

/*/{Protheus.doc} RetMaxNum
	Retorna a Carga mais nova gerada no Online
	@type  Function
	@author Bruno Almeida
	@since 05/10/2023
	@version 12
	@return nLastCarga, numeric, codigo da ultima carga gerada
/*/
Static Function RetMaxNum()

Local cQuery		:= ""
Local nLastCarga	:= 0 
Local cLastCarga	:= ""


//verifica o total de cargas (considera somente registros do tipo carga (2). Nao considera os templates(1)
cQuery := " SELECT MAX(MBU_CODIGO)  AS ULTIMA FROM " + RetSqlName('MBU') + " WHERE MBU_TIPO = '2' AND D_E_L_E_T_ = ' ' " 
cQuery := ChangeQuery(cQuery)					
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TMPCRG', .F., .T.)
cLastCarga := TMPCRG->ULTIMA
TMPCRG->(dbCloseArea()) 
                                                   
nLastCarga := Val(cLastCarga)

Return nLastCarga                                     


/*/{Protheus.doc} ValOffNum
	Retorna as ultimas cargas recebidas nos ambiente offline
	@type  Function
	@author Bruno Almeida
	@since 05/10/2023
	@version 12
	@param nMaxRet, numeric, número maximo de cargas que pode ficar pendentes
	@param aAmbOff, array, parâmetro de referência com os ambientes que não receberam as cargas
	@return lAviso, logico, retorna .T. se caso algum ambiente tem mais de X cargas sem receber.
/*/
Static Function ValOffNum(nMaxRet,aAmbOff,nMaxPacotes) 

Local lAviso	:= .F.
Local aPdvs		:= {}					//Armazena todos os PDVÂ´s cadastrados na Retaguarda
Local aAreaMD4	:= MD4->(GetArea())
Local aAreaMD3	:= MD3->(GetArea())
Local nCount	:= 1
Local nx 		:= 0
Local oServer      
Local aMBYPdv	:= {}					// Retorno da consulta no Pdv com base na Tabela MBY
Local aMbyGeral	:= {}
Local bOldError		// variÃ¡vel de backup de erro de execucao para proteger a comunicacao RPC caso algum PDV caia durante a consulta.

DbSelectArea("MD4")
DbSetOrder(1)
IF DbSeek(xFilial("MD4")) // Posiciona no primeiro registro com Filial + CÃ³digo
	While !Eof()
		If !Empty(MD4->MD4_AMBPAI) // SÃ³ processo ambiente PDV
			Aadd(aPdvs,MD4->MD4_CODIGO)
		Endif
		DbSkip()
	End
Endif

// Pega os dados de cada PDV para realizar a pesquisa das cargas processadas
DbSelectArea("MD3") 
DbSetOrder(1)
If Len(aPdvs) > 0
	aConexao := {}
	For nCount := 1 To Len(aPdvs) // realiza a leitura de todos os PDVÂ´s encontrados
		If DbSeek(xFilial("MD3") + aPdvs[nCount])
			oServer := TRPC():New( MD3->MD3_NOMAMB )          // Cria objeto da conexÃ£o RPC
			If oServer:Connect( Alltrim(MD3->MD3_IP), Val(MD3->MD3_PORTA) )
				bOldError := ErrorBlock( {|x| TrataErro(x) } ) // muda code-block de erro
				// este tratamento protege o JOB caso a comunicaÃ§Ã£o caia durante este processo de consulta. Do contrÃ¡rio o JOB ficaria inativo
				
				Begin Sequence
				
				oServer:CallProc("RPCSetType", 3 ) // Tipo de LicenÃ§a consumida
				oServer:CallProc("RPCSetEnv", MD3->MD3_EMP, MD3->MD3_FIL,Nil,Nil,"FRT","", {'MBY'}) // Abre conexÃ£o com outra empresa
				
				aMBYPdv := oServer:CallProc("LastMBY")     // Retorna as Cargas Liberadas neste PDV
				
				oServer:CallProc('RpcClearEnv') // Limpa Thread
				oServer:Disconnect() // Encerra conexÃ£o

				If Len(aMBYPdv) > 0
					aAdd( aMbyGeral, {aMBYPdv[1][1],aMBYPdv[1][2]} ) // Filial + Última Carga
				EndIf
				
				Recover
					Conout('JOB CargaMon: Ocorreu um erro inesperado durante a consulta do ambiente ' + MD3->MD3_NOMAMB)
					Conout('JOB CargaMon: Detalhes do ambiente OFFLINE : MD3_IP ' + Alltrim(MD3->MD3_IP) + ' | MD3_PORTA : ' + MD3->MD3_PORTA )
				End Sequence
				
				ErrorBlock( bOldError ) // Restaura rotina de erro anterior
			Else
				aAdd(aConexao,{'JOB CargaMon: Não foi possivel estabelecer uma conexão com o ambiente' + ' ' + AllTrim(MD3->MD3_NOMAMB) + ' ' + 'para monitorar as cargas!' + Chr(10) + Chr(13) + 'Detalhes do ambiente IP:' + ' ' + Alltrim(MD3->MD3_IP) + ' ' + '| PORTA:' + ' ' + MD3->MD3_PORTA + ' | ' + 'Empresa:' + ' ' + AllTrim(MD3->MD3_EMP) + ' | ' + 'Filial:' + ' ' + AllTrim(MD3->MD3_FIL)})
			EndIf
		EndIf
	Next nCount
EndIf

If Len(aMbyGeral) > 0
	For nx:= 1 To Len(aMbyGeral)
		If (nMaxRet - aMbyGeral[nx][2]) > nMaxPacotes // Se a carga da retaguarda for maior que duas sequenências do Offline, envia o e-mail 
			lAviso := .T.
			aadd(aAmbOff,{aMbyGeral[nx][1],aMbyGeral[nx][2]})
		Endif
	Next nx
EndIf 

RestArea(aAreaMD4)
RestArea(aAreaMD3)

Return lAviso                        

/*/{Protheus.doc} LastMBY
	Ultima carga recebida no Offline da Filial Pesquisada
	@type  Function
	@author Bruno Almeida
	@since 05/10/2023
	@version 12
	@param nMaxRet, numeric, número maximo de cargas que pode ficar pendentes
	@param aAmbOff, array, parâmetro de referência com os ambientes que não receberam as cargas
	@return aMBYPdv, array, retorna a filial e a ultima carga recebida neste ambiente offline
/*/
Function LastMBY()

Local aMBYPdv 	 := {}
Local cQuery	 := ""
Local nLastCarga := 0 
Local cLastCarga := ""

//verifica o total de cargas (considera somente registros do tipo carga (2). Nao considera os templates(1)
cQuery := " SELECT MAX(MBY_CODGRP)  AS ULTIMA FROM " + RetSqlName('MBY') + " WHERE MBY_STATUS = '2' AND D_E_L_E_T_ = ' ' " 
cQuery := ChangeQuery(cQuery)					
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TMPMBY', .F., .T.)
cLastCarga := TMPMBY->ULTIMA
TMPMBY->(dbCloseArea()) 
                                                   
nLastCarga := Val(cLastCarga)

Aadd(aMBYPdv,{cFilAnt,nLastCarga})

Return aMBYPdv


/*/{Protheus.doc} CargaMail
	Envio do E-mail com as Filiais com problema
	@type  Function
	@author Bruno Almeida
	@since 05/10/2023
	@version 12
	@param cModo, caractere, tipo da mensagem a ser enviada
	@param aAmbOff, array, ambientes para o qual deveram ser enviadas as mensagens 
/*/
Static Function CargaMail(cModo,aAmbOff,nUltCargaRet)

Local lResult	:= .F.            
Local cMsg		:= ""                
Local cAssunto	:= "" 
Local cError	:= ""
Local nx		:= 0
Local cEmailTo	:= ""

Local cServer   := AllTrim(SuperGetMv("MV_RELSERV"))	// Nome do servidor de envio de e-mail - Ex.: smtp.ig.com.br ou 200.181.100.51
Local cConta    := AllTrim(SuperGetMv("MV_RELACNT"))	// Conta a ser utilizada no envio de e-mail - Ex.: fuladetal@fulano.com.br
Local cPsw      := AllTrim(SuperGetMv("MV_RELPSW"))		// Senha da conta de e-mail;
Local lRelauth  := SuperGetMv("MV_RELAUTH",, .F.)		// Determina se o servidor exige autenticao
Local cCtaAut   := AllTrim(SuperGetMv("MV_RELAUSR")) 	// Usuaio para autenticao no servidor de e-mail (caso servidor assim exigir);
Local cApsw     := AllTrim(SuperGetMv("MV_RELAPSW"))	// Senha para autentica?o no servidor de e-mail (caso servidor assim exigir).
Local cFrom	    := AllTrim(SuperGetMv("MV_RELFROM"))	// E-mail utilizado no campo FROM no envio do e-mail;

Default nUltCargaRet := 0

If cModo == "1"  
	cAssunto 	:= "ATUALIZAÇÃO DAS CARGAS"
	cMsg		:= "JOB CargaMon: As seguintes lojas não estão com as cargas sincronizadas comparando com o ambiente da retaguarda, última carga gerada na retaguarda: " + cValToChar(nUltCargaRet) + Chr(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13)
	For nx := 1 to Len(aAmbOff)
		cMsg += " - Última carga atualizada na Filial:" + " " + aAmbOff[nx][1] + " " + "- Carga:" + " " + Alltrim(Str(aAmbOff[nx][2])) + Chr(10) + Chr(13) + Chr(10) + Chr(13)
	Next nx
ElseIf cModo == "2"
	cAssunto 	:= "AMBIENTE SEM CONEXÃO"
	For nX := 1 To Len(aConexao)           
		cMsg += aConexao[nX][1] + Chr(10) + Chr(13) + Chr(10) + Chr(13) + Chr(10) + Chr(13)
	Next nX
EndIf

For nX := 1 To Len(aEmails)
	
	cEmailTo := AllTrim(aEmails[nX])

	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPsw RESULT lResult

	IF lResult

		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lRelauth
			lResult := Mailauth( cCtaAut, cApsw )
		Endif

		If lResult
			SEND MAIL FROM cFrom TO cEmailTo SUBJECT cAssunto BODY cMsg RESULT lResult 
			
			If !lResult
				GET MAIL ERROR cError
				Conout("Falha no envio do E-mail - Assunto: " + cAssunto + " - Mensagem: " + cMsg)
				Conout(cError)
			EndIf
		Else
			GET MAIL ERROR cError
			Conout("Falha na Autenticação para envio do E-mail - Assunto: " + cAssunto + " - Mensagem: " + cMsg)
			Conout(cError)
			Conout("JOB CargaMon - Verifique a conta e a senha configurados para envio de e-mail.")
		EndIf

	Else
		GET MAIL ERROR cError
		Conout("Falha na Autenticação SMTP para envio do E-mail - Assunto: " + cAssunto + " - Mensagem: " + cMsg)
		Conout(cError)
		Conout("JOB CargaMon - Verifique a conta e a senha configurados para envio de e-mail.")
	Endif

	DISCONNECT SMTP SERVER

Next nX

Return Nil                                                                   

/*/{Protheus.doc} TrataErro
	Tratamento de erro na conexao dos servicos
	@type  Function
	@author Bruno Almeida
	@since 05/10/2023
	@version 12
	@param e, objeto, objeto TRPC
	@return lRet, logico, se houve erro retorna .T.
/*/
Static Function TrataErro( e )
Local lRet := .F.	   		// Retorno da funcao 

If e:gencode > 0  
	Conout( "Ocorreu o erro: " + e:DESCRIPTION ) 
	Conout( "Pilha de chamada: " + e:ERRORSTACK ) 
    lRet := .T.
    Break
Endif  

Return( lRet )
