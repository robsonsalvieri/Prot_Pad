#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFPROC4.CH"

#DEFINE TAMMAXXML 0750000  //Tamanho Maximo do XML
#DEFINE TAMMSIGN  0040000  //Tamanho médio da assinatura

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc9 
Chama rotina responsavel por verificar os registros que devem ser 
transmitidos.

@return Nil 

@author Leonardo Kichitaro
@since 09/03/2018
@version 1.0
@obs - Rotina separada do fonte TAFAINTEG e realizado tratamentos especificos
		para a utilização do Job4 realizando a chamada individualmente e utilizando
		o schedDef para a execução no schedule.
/*/
//-----------------------------------------------------------------------------   
Function TAFProc9( aAlias , aEvt )

	Local lJob := IsBlind()
	Local lEnd := .F.
	Local aErrosJob := {}

	Default aAlias := {}
	Default aEvt   := {}

	If TAFAtualizado(!lJob)
		TAFConOut('Rotina de Transmissão de eventos REINF - Empresa: ' + cEmpAnt + ' Filial: ' + cFilAnt, 2, .T., "PROC9" )

		If lJob
			aErrosJob := TAFProc9TSS(lJob, aEvt ,/*3*/,/*4*/,/*5*/,/*6*/,@lEnd,/*8*/,/*9*/,/*10*/,/*11*/,/*12*/,/*13*/, aAlias ,/*15*/ )
			TAFMErrT0X(aErrosJob,lJob)
		Else
			Processa( {||TAFProc9TSS(lJob,,,,,,@lEnd)}, "Aguarde...", "Executando rotina de Transmissão",  )
		EndIf

		If lEnd .And. !lJob
			MsgInfo("Processo finalizado.")
		EndIf
	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc9Tss 
Processo responsavel por verificar os registros que devem ser transmitidos no
TSS.

Alteração: Evandro dos Santos
Data: 05/04/2016 
Descrição: - Alterado a forma de geração dos registros, para a rotina possibilitar
a geração de XMLs em disco, foram incluidos uma série de parâmetros que permitem 
a geração de layouts especificos e filtros por status, recno e Id.
- Alterado a Origem do array dos layouts, antes os mesmos eram baseados no array 
aTafSocial deste fonte, agora os layouts considerados são os especificados no
fonte TAFROTINAS.

@param	lJob - Flag para Identificação da chamada de Função por Job
@param 	aEvtsESoc 	- Array com os Eventos a serem considerados, quando vazio são considerados 
		todos os eventos contidos no TAFROTINAS. 
		Obs: Quando informados os eventos devem seguir a mesma estrutura dos eventos e-Social
		contidos no TAFROTINAS.
@param 	cStatus - Status dos eventos que devem ser transmitidos, quando vazio  o sistema usa o 0 
        para tranmissão e o 2 para consulta; o parâmetro pode conter mais de 1 status par isso
        passar os status separados por virgula ex: "1,3,4"
@param cPathXml - Path para a geração dos XMls, quando esse parâmetro é informado e o cEvOrCon é
        vazio o sistema gera os XMLs em disco.	
@param aIdTrab - Array com o Id dos trabalhadores (para filtro dos eventos que tem relação com o 
	    trabalhador)
@param cRecNos - Filtra os registro pelo RecNo do Evento, pode ser utilizado um range de recnos
		ex;"1,5,40,60"
@param lNoErro - Determina se houve erros no processamento (variável referenciada) 
@param cMsgRet - Mensagem de retorno do WS (referência)
@param lForce - Força a geracao do XML nao respeitando o cadastro de predecessão 
@param aFiliais - Array de Filiais     	
@param dDataIni	-> Data Inicial dos eventos
@param dDataFim	-> Data Fim dos dos eventos
@param lEvtInicial -> Informa se o parâmetro de evento inicial foi marcado.

@return Nil 

@author Evandro dos Santos O. Teixeira
@since 07/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------    
Function TAFProc9Tss(lJob , aEvtsReinf, cStatus, cPathXml, aIdTrab, cRecNos, lNoErro, cMsgRet,lForce,aFiliais,dDataIni,dDataFim,lEvtInicial,aRecREINF,lConexTSS,lApi,aRetErro,lAut)

	Local cFunction	  := ""
	Local cXml		  := ""
	Local cId		  := ""
	Local cMsgProc    := ""
	Local cAliasEve   := {}
	Local cHoraIni	  := Time()
	Local cTempoTr	  := ""
	Local cMsgAux	  := ""
	Local cTimeProc	  := Time()
	Local cLog		  := ""
	Local cIdThread   := StrZero(ThreadID(), 10 )
	Local nSeq		  := 0
	Local nX          := 0
	Local nQtdRegs	  := 0
	Local nByteXML	  := 0
	Local nRegsOk	  := 0
	Local lAllEventos := .F.
	Local aXmls		  := {}
	Local aAuxRet     := {}
	Local aRetEvts    := {}
	Local aHoraIni	  := {}
	Local lErroSch	  := .F.
	Local lErroSrv	  := .F.
	Local lErroPred	  := .F.
	Local lErroToken  := .F.
	Local cAmbES      := SuperGetMv('MV_TAFAMBR',.F.,"2")

	Default cStatus 	:= ""
	Default aEvtsReinf	:= {}
	Default aIdTrab 	:= {}
	Default aFiliais	:= {}
	Default aRecREINF	:= {}
	Default cRecNos		:= ""
	Default cPathXml	:= ""
	Default cMsgRet 	:= ""
	Default	lForce		:= .F.
	Default dDataIni	:= dDataBase
	Default dDataFim	:= dDataBase
	Default lJob		:= .F.
	Default lApi		:= .F.
	Default lAut        := .F.

	cStatus 	 := IIf(Empty(cStatus),'0',cStatus)

	lAllEventos  := Empty(aRecREINF) //Se aEvtsESoc for vazio devo considerar todos os eventos na query de transmissão

	// Tratamento para funcionalidade via Job/Schedule 
	If lJob
		cLog := "* Inicio Transmissão TAFProc9 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeProc
		TAFConOut(cLog, 1, .T., "PROC9" )
	Else
		ProcRegua(Len(aRecREINF))
	EndIf

	cMsgProc := "Selecionando registros para a geração dos XMLs. " //"Selecionando registros para a geração dos XMLs. "

	if TAFAlsInDic( 'T0X' )
		dbSelectArea("T0X")
		T0X ->(DbSetOrder(3))
	endif

	If Len(aRecREINF) > 0
		cAliasEve	:= AllTrim( aEvtsReinf[3] )
		nQtdRegs	:= Len(aRecREINF)

		For nX:= 1 to Len(aRecREINF)
			( cAliasEve )->(dbGoTo( aRecREINF[nX] ) )
			cId			:= AllTrim ( STRTRAN( aEvtsReinf[4] , "-" , "" ) ) + &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_ID") + &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_VERSAO")
			cFunction	:= AllTrim( aEvtsReinf[8] )
			cKeyId		:= &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_FILIAL") + &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_ID") + &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_VERSAO")

			If cFunction == 'TAF496Xml' //Fechamento R2099
				cXml := &cFunction.( cAliasEve , aRecREINF[nX] , , .T. , lApi)
			elseif cFunction == 'TAF494Xml' //Contribuinte R1000
				cXml := &cFunction.( cAliasEve , aRecREINF[nX] , , .T. , , lApi)
			else
				cXml := &cFunction.( cAliasEve , aRecREINF[nX] , , .T.)
			EndIF

			nSeq++
			aAdd( aXmls , { EncodeUTF8( cXml ) , cId , aRecREINF[nX] , AllTrim( aEvtsReinf[4] ) , cAliasEve } )

			nByteXML += Len( cXML ) + TAMMSIGN

			/*+-----------------------------------------------------------------------------------------------------+
			| Quando alcançar o limite, faço o envio do que já tenho  e zero o Array de XMLs                      |
			| Só é permitido o envio de 50 registros por lote (Manual de Orientação do Desenvolvedor e-Social 1.4)|
			| A Variavel nSeq é utilizada para controle do lote e para o sequenciamento do ID do evento.          |
			+-----------------------------------------------------------------------------------------------------+*/ 
			If nByteXML >= TAMMAXXML .Or. nSeq == 50
				aAuxRet := TAFEvXml(aXmls,cAmbES,@nRegsOk,lJob,cIdThread,@lErroSch,@lErroSrv,@lErroToken)
				aAdd(aRetEvts,aClone(aAuxRet))
				aXmls		:= {}
				nByteXML	:= 0
				nSeq		:= 0
				lConexTSS	:= Iif(lErroSrv,.F.,.T.)
				//Quando ocorre um Erro no Servidor aborto a operação.
				If lErroSrv
					Exit
				EndIf
			EndIf
		Next

		If Len(aXmls) > 0
			If lAut
				aAuxRet := Iif(!Empty(aXmls[1][1]), {.T.,"","R-4010"}, {.F.,"Erro ao gerar XML","R-4010"})	
			Else
				aAuxRet := TAFEvXml(aXmls,cAmbES,@nRegsOk,lJob,cIdThread,@lErroSch,@lErroSrv,@lErroToken)
				lConexTSS := Iif(lErroSrv,.F.,.T.)
			EndIf
			aAdd(aRetEvts,aClone(aAuxRet))
		EndIf

		aHoraIni := StrTokArr(cHoraIni,":")
		cTempoTr := DecTime( Time() , Val(aHoraIni[1]) , Val(aHoraIni[2]) , Val(aHoraIni[3]) ) 
	
		If nQtdRegs > 1
			cMsgAux := "os eventos foram vinculados" //"os eventos foram vinculados"  
		Else
			cMsgAux := "o evento foi vinculado" //"o evento foi vinculado"
		EndIf
	
		If !lErroSch .And. !lErroSrv .And. !lErroPred .and. !lErroToken
			cMsgRet := "Você concluiu com sucesso a transmissão para o TSS. Verifique se " + cMsgAux + " ao ambiente REINF utilizando a rotina de detalhamento." + CRLF + CRLF //"Você concluiu com sucesso a transmissão para o TSS. Verifique se "#" ao ambiente e-Social (RET) utilizando a rotina de detalhamento." 	
		ElseIf lErroSch
			cMsgRet := "Ocorreu(ram) erro(s) de schema(s) em 1 ou mais registros. Verifique as inconssistências utilizando a rotina de detalhamento." + CRLF + CRLF
		ElseIf lErroSrv
			cMsgRet := "Não foi possivel efetuar o envio do(s) lote(s) para o servidor TSS. " + "Descrição do Erro: " + aAuxRet[2] + CRLF + CRLF
		ElseIf lErroToken
			cMsgRet := aAuxRet[2] + CRLF + CRLF
		Else
			cMsgRet += CRLF 
		EndIf
	
		If !lErroSrv .and. !lErroToken
			cMsgRet += AllTrim(Str(nRegsOK)) + "/" + AllTrim(Str(nQtdRegs)) + " evento(s) transmido(s) em " + cTempoTr + "." //" evento(s) transmido(s) em "
		Else
			cMsgRet += "Tempo de Processamento: " + cTempoTr
		EndIf
	Else
		cMsgRet := "Não há eventos pendentes de transmissão a serem transmitidos considerando as opções selecionadas. " // "Não há eventos pendentes de transmissão a serem transmitidos considerando as opções selecionadas. "
	EndIf

	If lJob
		cTimeProc := Time()
		TAFConOut(cMsgRet, 2, .T., "PROC9" )
		cLog := "* Fim Transmissão TAFProc9 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + Time() + " - Tempo de processamento: " + ElapTime(cTimeProc,Time())  + " - Quantidade de Registros: " + AllTrim(Str(nQtdRegs))
		TAFConOut(cLog, 1, .T., "PROC9" )
	EndIf

	//Preciso desses valores no array retornado para mostrar o tipo de erro no Portinari.
	if lApi
		AADD(aRetErro,lErroSch) // Erro de schema
		AADD(aRetErro,lErroSrv) // Erro para se conectar no TSS
		AADD(aRetErro,lErroPred)// Erro de predecessão.
		AADD(aRetErro,lErroToken)// Erro autenticação TSS
	EndIf

Return (aRetEvts)

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFEvXml 
Realiza a Transmissão dos documentos.

@param aXmls  	  - Array com os dados do Xml    
		  [x][1]  - Xml do Evento
		  [x][2]  - Id(chave do evento no TSS)
		  [x][3]  - RecNo do Evento na sua respectiva tabela
		  [x][4]  - Layout que correspondente ao evento
		  [x][5]  - Alias correspondente ao Evento 
@param cAmbES	  - Ambiente de Transmissão/Consulta 		  
@param nRegsOk    - Numero de registros Integrados com sucesso   
@param cIdThread  - Id da Thread que está executando o processamento (Job)
@param lErroSch   - Informa se houve erro de erro de Schema
@param lErroSrv   - Informa se houve erro no envio para o servidor TSS
@param lErroToken - Informa se houve na autenticação com o TOKEN TSS

		 
@return lRegs [x][1] - Determina se o lote foi processado com sucesso (logico)
			  [x][2] - Descrição do erro  (Caso houver)
			  [x][3] - Status dos eventos
			  	 [3][x][1] - Determina se o evento foi transmitido com sucesso (logico)
			  	 [3][x][2] - Layout do evento
			  	 [3][x][3] - Id (chave do evento no TSS)
			  	 [3][x][4] - Descrição do Resultado
	     lJob - Informa se o processo está sendo executado via JOB.
			  	 
@author Evandro dos Santos Oliveira
@since 07/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------   
Static Function TAFEvXml(aXmls,cAmbES,nRegsOk,lJob,cIdThread,lErroSch,lErroSrv,lErroToken)

	Local oReinf 		:= Nil
	Local cUrl			:= GetMv("MV_TAFSURL")
	Local cVerSchema	:= SuperGetMv('MV_TAFVLRE',.F.,"1_03_00")
	Local cCheckURL		:= ""
	Local cMsgRetEnv	:= ""
	Local nY 			:= 1
	Local lRetWS		:= .F.
	Local aRetEvts		:= {}
	Local lOk			:= .T.
	Local oHashXML		:= Nil
	Local xRetXML		:= Nil
	Local cDescErro		:= ""
	Local cTabOpen		:= ""
	Local cAliasTb		:= ""
	Local lSchema 		:= .F.
	Default cAmbES		:= "2"
	Default aXmls  		:= {}
	Default nRegsOk 	:= 0
	Default cIdThread 	:= ""

	if type("_CTProc9") == "L" .And. _CTProc9
		lSchema := .T.
	endif

	cIdEnt  := TAFRIdEnt(,,,,,.T.)
	cUserTk := "TOTVS"

	If Empty(AllTrim(cUrl))
		cDescErro := "O parâmetro MV_TAFSURL não está preenchido"
		lOk := .F.
	Else
		If !("TSSWSREINF.APW" $ Upper(cUrl))
			cCheckURL := cUrl
			cUrl += "/TSSWSREINF.apw"
		Else
			cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
		EndIf

		If TAFCTSpd(cCheckURL)
			oReinf 	   											:= WSTSSWSREINF():New()
			oReinf:oWSREINFENVIO:oWSCABEC						:= WsClassNew("TSSWSREINF_REINFCABEC")
			oReinf:_Url 										:= cUrl
			oReinf:oWSREINFENVIO:oWSCABEC:cUSERTOKEN 			:= cUserTk
			oReinf:oWSREINFENVIO:oWSCABEC:cENTIDADE    			:= cIdEnt
			oReinf:oWSREINFENVIO:oWSCABEC:cAMBIENTE   			:= cAmbES
			oReinf:oWSREINFENVIO:oWSCABEC:cVERSAO				:= cVerSchema

			oReinf:oWSREINFENVIO:oWSEVENTOS						:= WsClassNew("TSSWSREINF_ARRAYOFREINFENVIOEVENTO")
			oReinf:oWSREINFENVIO:oWSEVENTOS:oWSREINFENVIOEVENTO	:= {}

			For nY := 1 To Len(aXmls)
				xTAFMsgJob("Iniciando Transmissao - Layout " + aXmls[nY][4] + " - " + "Id" + aXmls[nY][2]) //"Iniciando Transmissao - Layout "#"Id"
				aAdd(oReinf:oWSREINFENVIO:oWSEVENTOS:oWSREINFENVIOEVENTO,WsClassNew("TSSWSREINF_REINFENVIOEVENTO"))
				Atail(oReinf:oWSREINFENVIO:oWSEVENTOS:oWSREINFENVIOEVENTO):CCODIGO	:= aXmls[nY][4]
				Atail(oReinf:oWSREINFENVIO:oWSEVENTOS:oWSREINFENVIOEVENTO):CID		:= aXmls[nY][2]
				Atail(oReinf:oWSREINFENVIO:oWSEVENTOS:oWSREINFENVIOEVENTO):CXML		:= aXmls[nY][1] //Encode64(aXmls[nY][1])
			Next nY

			lRetWS := oReinf:ENVIAREVENTOS()
			If ValType(lRetWS) == "L"
				If lRetWS
					oHashXML :=	AToHM(aXmls, 2, 3 )
					aXmls := {}
					If ValType(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO) <> "U"
						For nY := 1 To Len(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO)
							cIdAux := AllTrim(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CID)
							HMGet( oHashXML , cIdAux ,@xRetXML )
							If !Empty(xRetXML[1][3])
								cAliasTb := xRetXML[1][5]
								If !(cAliasTb $ cTabOpen)
									cTabOpen += "|" + cAliasTb
									dbSelectArea(cAliasTb)
								EndIf
								(cAliasTb)->(dbGoTo(xRetXML[1][3]))
								RecLock((cAliasTb),.F.)

								If oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:lSucesso .And. !lSchema
									aAdd(aRetEvts,{.T.,xRetXML[1][4],cIdAux,STR0015,""}) //"Transmitido com Sucesso."
									(cAliasTb)->&(cAliasTb+"_STATUS") := '2'
									nRegsOK++
								Else
									If AllTrim(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CCODIGO) $ "203" .Or. lSchema
										cMsgRetEnv := TafValSche(xRetXML[1][1], xRetXML[1][4], cIdAux, cUrl, cUserTk, cIdEnt, cAmbES, cVerSchema)
									Else
										cMsgRetEnv := oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CDESCRICAO
									EndIf
									aAdd(aRetEvts,{.F.,xRetXML[1][4],cIdAux,cMsgRetEnv,"S"}) //evento com inconsistência
									If lJob
										cLog := "* Retorno Com Erro : " + cIdThread + " - Hora: " + DTOC(dDataBase) + " - " + Time() + CRLF
										cLog += oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CDESCRICAO
										TAFConOut(cLog, 2, .T., "PROC9" )
									Endif
									(cAliasTb)->&(cAliasTb+"_STATUS") := '3'
									lErroSch := .T.
									lOk := .F.
								EndIf
								(cAliasTb)->(MsUnlock())
							Else
								aAdd(aRetEvts,{.F.,xRetXML[1][4],cIdAux,STR0016,"A"}) //"Não encontrado no lote de envio"
							EndIf
						Next nY
					Else
						cDescErro := "Tipo de dado Indefinido no retorno do WS." //"Tipo de dado Indefinido no retorno do WS."
						lOk := .F.
						lErroSrv := .T.
					EndIf
				Else
					cDescErro := "Servidor TSS não conseguiu processar a requisição."
					cDescErro += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
					lOk := .F.
					lErroSrv := .T.
				EndIf
			Else
				cCodFault := GetWscError(2)

				if !TAFVldTokenTSS(@cDescErro, @lErroToken,cCodFault,.T.)
					lOk 	 := .F.
					lErroSrv := .T.
				else
					cDescErro := "Retorno do WS não é do Tipo Lógico." //"Retorno do WS não é do Tipo Lógico."
					cDescErro += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
					lOk		 := .F.
					lErroSrv := .T.
				Endif
				
			EndIf
		Else
			cDescErro := "Não foi possivel conectar com o servidor TSS"	  //"Não foi possivel conectar com o servidor TSS"
			lOk := .F.
			lErroSrv := .T.
		EndIf
	EndIf
	TAFConOut(cDescErro, 2, .T., "PROC9" )

Return {lOk,cDescErro,aRetEvts}

//-------------------------------------------------------------------
/*/{Protheus.doc} TafValSche
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira	
@since  17/05/2016
@version 1.0

/*///----------------------------------------------------------------
Function TafValSche( cXml, cCodReinf, cIdReinf, cUrl, cUserTk, cIdEnt, cAmbES, cVerSchema )

	Local oReinfSche	:= Nil
	Local cMsgRetEnv	:= ""

	oReinfSche 	   							:= WSTSSWSREINF():New()
	oReinfSche:_Url							:= cUrl
	oReinfSche:oWSREINFSCHEMA:cAMBIENTE		:= cAmbES
	oReinfSche:oWSREINFSCHEMA:cCODIGO		:= cCodReinf
	oReinfSche:oWSREINFSCHEMA:cENTIDADE		:= cIdEnt
	oReinfSche:oWSREINFSCHEMA:cID			:= cIdReinf
	oReinfSche:oWSREINFSCHEMA:cUSERTOKEN	:= cUserTk
	oReinfSche:oWSREINFSCHEMA:cVERSAO		:= cVerSchema
	oReinfSche:oWSREINFSCHEMA:cXML			:= cXml

	lRetWS := oReinfSche:VALIDARSCHEMA()
	If ValType(lRetWS) == "L"
		If lRetWS
			If ValType(oReinfSche:oWSVALIDARSCHEMARESULT) <> "U"
				If !oReinfSche:oWSVALIDARSCHEMARESULT:lSTATUS
					cMsgRetEnv := oReinfSche:oWSVALIDARSCHEMARESULT:cERRO
				EndIf
			EndIf
		EndIf
	EndIf

Return ( cMsgRetEnv )

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira	
@since  17/05/2016
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()
	Local aParam  := {}

	aParam  := { "P",;			//Tipo R para relatorio P para processo
	"TAFESXTSS",;	//Pergunte do relatorio, caso nao use passar ParamDef
	,"SM0";			//Alias
	,;			//Array de ordens
	}				//Titulo

Return ( aParam )

//--------------------------------------------------------------------
/*/{Protheus.doc} TafLimpRei

Função utilizada para transmissão do evento R-1000 modificado, com o intuito de remover contribuinte da base de dados do Reinf 

@Author	anieli.rodrigues
@Since	24/04/2018

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafLimpRei(lJob, aRetTrans, lApiREINF, cMsgRet)

	Local aAreaT9U		:= T9U->(GetArea())
	Local aAuxRet		:= {}
	Local aRetEvts		:= {}
	Local aXML			:= {}
	Local cAliasRegs	:= GetNextAlias()
	Local cId			:= ""
	Local cQry			:= ""
	Local cXml 			:= ""
	Local lErroSch		:= .F.
	Local lErroSrv		:= .F.
	Local lErroToken	:= .F.
	Local nQtdRegs		:= 0
	Local nRegsOk		:= 0
	Local oModel494		:= Nil
	
	Default lJob		:= .F.
	Default aRetTrans	:= {}
	Default lApiREINF   := .f.
	Default cMsgRet		:= ''

	If lJob .Or. MsgYesNo(STR0029, STR0022) //"Ao selecionar esta opção, todos os eventos enviados ao ambiente de Produção Restrita, inclusive o evento R-1000, serão removidos da base de dados do governo. Deseja continuar?" "ATENÇÃO"

		cQry := "SELECT T9U.R_E_C_N_O_ RECTAB "
		cQry += "FROM " + RetSqlName("C1E") + " C1E "
		cQry += "JOIN " + RetSqlName("T9U") + " T9U "
		cQry += "ON C1E.C1E_ID = T9U.T9U_ID AND "
		cQry += "C1E.C1E_VERSAO = T9U.T9U_VERORI "
		cQry += "WHERE C1E.C1E_FILIAL = '"+xFilial("C1E")+"' "
		cQry += " AND C1E.C1E_FILTAF = '"+cFilAnt+"' "
		cQry += " AND C1E.C1E_ATIVO  = '1' "
		cQry += " AND C1E.C1E_MATRIZ = 'T' "
		cQry += " AND C1E.D_E_L_E_T_ <> '*' "
		cQry += " AND T9U.D_E_L_E_T_ <> '*' "
		cQry += " AND T9U.T9U_ATIVO  = '1' "

		cQry := ChangeQuery(cQry)

		TcQuery cQry New Alias (cAliasRegs)

		Count To nQtdRegs

		If nQtdRegs > 0

			(cAliasRegs)->(dbGoTop())
			T9U->(DbGoTo((cAliasRegs)->RECTAB))

			oModel494 := FWLoadModel("TAFA494")
			oModel494:SetOperation(4)
			oModel494:Activate()
			oModel494:LoadValue( 'MODEL_T9U', 'T9U_VERSAO', xFunGetVer() )
			oModel494:LoadValue( 'MODEL_T9U', 'T9U_EVENTO', "I" )
			FWFormCommit( oModel494 )
			oModel494:DeActivate()

			dbSelectArea("T9U")
			RecLock("T9U", .F.)
			T9U->T9U_STATUS := " "
			T9U->T9U_PROTUL := " "
			T9U->T9U_PROTPN := " "
			MsUnLock()

			cId := "R1000" + T9U->T9U_ID + T9U->T9U_VERSAO

			cXml := TAF494Xml("T9U", T9U->(Recno()), ,.T., .T.)

			aAdd(aXml, {EncodeUTF8(cXml), cId, (cAliasRegs)->RECTAB, "R-1000", "T9U"})

			//Realiza a Transmissão do evento.
			aAuxRet   := TAFEvXml(aXml, "2", @nRegsOk, lJob, , @lErroSch, @lErroSrv,@lErroToken)
			aAdd(aRetEvts, aClone(aAuxRet))

			//Adiciono o RECNO para que a API WSTAF049 não precise fazer novamente a query
			aRetTrans := aClone(aAuxRet)
			aadd(aRetTrans,(cAliasRegs)->RECTAB)

			If !lErroSch .And. !lErroSrv
				cMsgRet := STR0030 //"Transmissão efetuada com sucesso. Verifique o retorno da transmissão através da opção 'Monitorar Transmissões', com o registro R-1000 posicionado e selecionando a opção 'Tabelas'. Se a situação do evento for 'Evento Rejeitado', consulte sua inconsistência. Se a tag 'descRetorno' apresentar o conteudo 'Sucesso', execute a rotina 'Exclusão por Período Fiscal' para remover os dados da base do TAF."
			ElseIf lErroSch
				cMsgRet := STR0024 //"Ocorreu um erro de schema. Verifique as inconsistências utilizando através da opção 'Detalhamento' selecionando o evento S-1000."
			ElseIf lErroSrv
				cMsgRet := STR0025 + aAuxRet[2]
			ElseIf lErroToken
				cMsgRet := aAuxRet[2] + CRLF + CRLF
			EndIf
			if !lJob
				TAFAviso( STR0031 , cMsgRet , {"OK"}, 3, STR0027) //"Remoção do contribuinte" "Transmissão do evento"			
			endif
		Else
			if !lJob
				TAFAviso( STR0031 , STR0028 , {"OK"}, 3, STR0027) //"Remoção do contribuinte" "Não há nenhum registro válido para remoção" "Transmissão do evento"
			else
				aRetTrans := {.f.,STR0028, {}}
			endif
		EndIf

		(cAliasRegs)->(DbCloseArea())

	EndIf

	If Len(aRetEvts) > 0
		TAFMErrT0X(aRetEvts)
	EndIf

	RestArea(aAreaT9U)

Return
