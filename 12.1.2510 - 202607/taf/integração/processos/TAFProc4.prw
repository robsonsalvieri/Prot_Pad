#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFPROC4.CH"

#DEFINE TAMMAXXML 0750000  // Tamanho Maximo do XML
#DEFINE TAMMSIGN  0040000  // Tamanho médio da assinatura

STATIC MAX_TENTATIVAS := 20
Static lVersaoFwt := GetVersao(.F.) >= '12'

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc4 
Chama rotina responsavel por verificar os registros que devem ser 
transmitidos.

@return Nil 

@author Evandro dos Santos Oliveira
@since 07/11/2013  
@version 1.0
@obs - Rotina separada do fonte TAFAINTEG e realizado tratamentos especificos
		para a utilização do Job4 realizando a chamada individualmente e utilizando
		o schedDef para a execução no schedule.
/*/
//-----------------------------------------------------------------------------   
Function TAFProc4(lPrepare, cEmp, cFil, lTryPost,cEventos)

	Local lJob			:= .F.
	Local lFim			:= .F.
	Local aErrosJob		:= {}

	Default lPrepare	:= .F.
	Default lTryPost	:= .T.
	Default cEventos	:= ""
	If lPrepare
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil,,,"TAF","TAFPROC4")
	EndIf

	lJob := IsBlind()

	If TAFAtualizado(!lJob)

		TafConOut('Rotina de Transmissão de eventos e-Social - Empresa: ' + cEmpAnt + ' Filial: ' + cFilAnt)

		If lJob
			aErrosJob := TAFProc4TSS(lJob,,"' ','0'",,,,@lFim,,,,,,,,,,,,,cEventos)
			TAFMErrT0X(aErrosJob,lJob)
		Else
			Processa( {|lCancel|TAFProc4TSS(lJob,,,,,,@lFim,,,,,,@lCancel,,,lTryPost,,,cEventos)}, "Aguarde...", "Executando rotina de Transmissão",  )
		EndIf

		If lFim .And. !lJob
			MsgInfo("Processo finalizado.")
		EndIf
	EndIf

	If lPrepare
		RpcClearEnv()
	EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc4Tss 
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
@param lCancel 	-> Variavel que indica que o processamento foi cancelado.
@param lMV		-> Indica se deverá considerar os eventos com múltiplos vínculos
@param lSemAcesso -> variável recebida por referência para registrar se houve filtro de um ou mais registros de outra filial referente rotina sem acesso do usuário corrente
@param lTryPost	-> Informa se o programa deve tentar reenviar as informações em caso de falha.
@param lApi ->
@param cPeriod ->
@param cEventos ->
@param cUser ->
@param aMotiveCode -> Motivos de afastamendo do evento S-2230
@param aRetErro -> Retorno do tipo de erro para o frontend 
 
@return Nil 

@author Evandro dos Santos O. Teixeira
@since 07/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------    
Function TAFProc4Tss(lJob , aEvtsESoc, cStatus, cPathXml, aIdTrab, cRecNos, lNoErro, cMsgRet,lForce,aFiliais,dDataIni,dDataFim,lCancel, lMV, oTabFilSel, lSemAcesso,lTryPost,lApi,cPeriod,cEventos, cUser,aMotiveCode, aRetErro)

	Local cQry			:= ""
	Local cFunction		:= ""
	Local cXml			:= ""
	Local cMsg			:= ""
	Local cId			:= ""
	Local cTabOpen		:= ""
	Local cMsgProc		:= ""
	Local cSelect		:= ""
	Local cAliasRegs	:= GetNextAlias()
	Local cAliasTrb		:= GetNextAlias()
	Local cBancoDB		:= Upper(AllTrim(TcGetDB()))
	Local cVerSchema 	:= GetMv("MV_TAFVLES")
	Local cHoraIni		:= Time()
	Local cTempoTr		:= ""
	Local cMsgAux		:= ""
	Local cTimeProc		:= Time()
	Local cLog			:= ""
	Local cIdThread		:= StrZero(ThreadID(), 10 )
	Local cAlsEvt		:= ""
	Local nTopSlct		:= GetNewPar("MV_TAFQPRC",0)
	Local nSeq			:= 0
	Local nQtdRegs		:= 0
	Local nByteXML		:= 0
	Local nRegsOk		:= 0
	Local nContador		:= 0
	Local lAllEventos	:= .F.
	Local aXmls			:= {}
	Local aEvenGrp		:= {}
	Local aArea			:= GetArea()
	Local aAuxRet		:= {}
	Local aRetEvts		:= {}
	Local aHoraIni		:= {}
	Local lErroSch		:= .F.
	Local lErroSrv		:= .F.
	Local lErroPred		:= .F.
	Local lTransFil		:= .F.
	Local lPredS1000	:= .F.
	Local nQtdLote		:= 0
	Local cCheckURL		:= ""
	Local nRegErro		:= 0
	Local cFilBkp		:= ""
	Local cIdEnt		:= ""
	Local cUrl			:= ""
	Local lTabTmpExt	:= oTabFilSel <> Nil //Avalia se a tabela temporaria veio da TAFMontES para não deletar
	Local lValAccRot	:= ValType(lSemAcesso) == "L"	//Valida acessos das rotinas sempre que lSemAcesso for recebido como parâmetro lógico
	Local nSeqXML	 	:= ThreadID()
	Local aArquivos		:= {}
	Local cLayout		:= ""
	Local lInfoRPT		:= .F. //Relatório de Conferência de Valores
	Local lErroToken  	:= .F.

	Default cStatus		:= ""
	Default aEvtsESoc	:= {}
	Default aIdTrab		:= {}
	Default aFiliais	:= {}
	Default cRecNos		:= ""
	Default cPathXml	:= ""
	Default cMsgRet		:= ""
	Default lForce		:= .F.
	Default lJob		:= .F.
	Default lCancel		:= .F.
	Default lMV			:= .F.
	Default oTabFilSel	:= Nil
	Default lSemAcesso	:= .F.
	Default lApi		:= .F.
	Default cEventos	:= ""
	Default cUser 		:= ""
	Default aMotiveCode	:= {}

	cAmbES	:= SuperGetMv('MV_TAFAMBE',.F.,"2")
	cStatus	:= IIf(Empty(cStatus),'0',cStatus)
	lJob 	:= isBlind()

	cURL 	:= PadR(TafGetUrlTSS(), 250)
	cURL 	:= AllTrim(cURL)

	lTransFil := TAFTransFil(lJob,@cStatus,lApi)

	If lJob
		cTimeProc := Time()
	EndIf

	If !("TSSWSSOCIAL.APW" $ Upper(cUrl)) 
		cCheckURL := cUrl
		cUrl += "/TSSWSSOCIAL.apw"
	Else
		cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
	EndIf

	If !lJob
		ProcRegua(20) 
	Endif

	If nSeqXML > 10000
		//Se o numero da Thread retornar um numero acima de 10000 deve-se gerar um numero aleatório para o controle da sequencial final do ID do XML
		//isso se faz necessário para que seja possivel a transmissão de pelo menos 89.999 por execução
		nSeqXML	:= Val(SubStr( StrTran( cValToChar( Seconds() ), ".","" ) , Len(StrTran( cValToChar( Seconds() ), ".","" )) - 2) + cValToChar( Randomize(10, 100)))
	EndIf

	If VerificaEntidade(@cIdEnt,lTransFil,cCheckURL,@cMsgRet,lJob,@lCancel,lTryPost, lApi, cUser, @lErroToken) .OR. !EMPTY(cPathXml)

		lAllEventos  := Empty(aEvtsESoc) //Se aEvtsESoc for vazio devo considerar todos os eventos na query de transmissão

		// Tratamento para funcionalidade via Job/Schedule
		If lJob

			cLog := "* Inicio Transmissão TAFProc4 TheadId: " + cIdThread
			TafConOut(cLog)
		EndIf

		If !Empty(cPathXml)
			cMsgProc := STR0001 //"Selecionando registros para a geração dos XMLs. "
		Else
			cMsgProc := STR0002 //"Verificando itens pendentes para transmissao na tabela: "
		EndIf

		if TAFAlsInDic( 'T0X' )
			dbSelectArea("T0X")
			T0X ->(DbSetOrder(3))
		endif

		If lJob .And. Type("MV_PAR02") <> "U" .And. ValType(MV_PAR02) == "C"  .And. !Empty(MV_PAR02)
			cSelect := "SELECT LE8_ID, C8E_CODIGO FROM " + RetSqlName("LE8") + " LE8 "
			cSelect += "INNER JOIN " + RetSqlName("C8E") + " C8E ON C8E.C8E_ID = LE8.LE8_IDEVEN AND C8E.D_E_L_E_T_ = '' "
			cSelect += "WHERE LE8_ID = '" + MV_PAR02 + "'"

			cSelect := ChangeQuery(cSelect)
			TcQuery cSelect New Alias (cAliasTrb)

			( cAliasTrb )->( dbgotop() )
			While ( cAliasTrb )->(!Eof())
				nPos 	  := aScan(aEvtsESoc,{|x| Alltrim(x[4]) == Alltrim((cAliasTrb)->C8E_CODIGO)})
				If nPos > 0
					AADD(aEvenGrp,aEvtsESoc[nPos])
				Endif
				( cAliasTrb )->( dbSkip() )
			End

			( cAliasTrb )->( dbCloseArea() )

			aEvtsESoc := AClone( aEvenGrp )

		Endif

		If lJob

			If IsInCallStack("TAFDEMAND")
				cStatus := "' ','0'"
			EndIf

			cQry := TAFQryXMLeSocial(cBancoDB,nTopSlct,,cStatus,aEvtsESoc,,cRecNos, cMsgProc,,aFiliais,,lJob,,,,@oTabFilSel,,cPeriod,cEventos,lApi,aMotiveCode,,,,dDataIni,dDataFim)
		Else
			cQry := TAFQryMonTSS(cBancoDB,nTopSlct,,cStatus,aEvtsESoc,aIdTrab,cRecNos, cMsgProc,,aFiliais,lAllEventos,dDataIni,dDataFim,lMV,@oTabFilSel)
		EndIf

		If cBancoDB $ ( "INFORMIX|ORACLE|POSTGRES|OPENEDGE" )
			cQry := ChangeQuery(cQry)
		Endif
		TcQuery cQry New Alias (cAliasRegs)
		Count To nQtdRegs

		If !lJob
			ProcRegua(nQtdRegs)
		Endif

		If nQtdRegs > 0

			(cAliasRegs)->(dbGoTop())

			While (cAliasRegs)->(!Eof()) .And. !lCancel .And. !lPredS1000

				If !lValAccRot .OR. FPerAcess(cAliasRegs, (cAliasRegs)->LAYOUT, ""/*cMsg*/, 0/*nMark*/, ""/*cRotina*/, .T./*lJob*/, .F./*lMarkAll*/, (cAliasRegs)->FILIAL/*cFilAccCFG*/)
					cAlsEvt := Alltrim( ( cAliasRegs )->ALIASEVT )

					lInfoRPT := AllTrim( ( cAliasRegs )->LAYOUT ) $ "S-1200|S-2299|S-2399"

					If TAFAlsInDic(cAlsEvt)

						cFunction := AllTrim( (cAliasRegs)->FUNCXML )

						If !(cAlsEvt $ cTabOpen)
							dbSelectArea(cAlsEvt)
							cTabOpen += "|" + cAlsEvt
						EndIf

						(cAlsEvt)->(DbGoTo((cAliasRegs)->RECTAB))

						cId := AllTrim ( STRTRAN( ( cAliasRegs )->LAYOUT , "-" , "" ) ) + AllTrim( ( cAliasRegs )->ID ) + AllTrim( (cAlsEvt)->&(cAlsEvt+"_VERSAO") )

						If !lJob
							nContador++
							IncProc("Processando " + AllTrim(Str(nContador)) + "/" + AllTrim(Str(nQtdRegs))  + "  - Id: " + cId)
						EndIf

						cKeyId 	:= (cAliasRegs)->FILIAL + AllTrim( ( cAliasRegs )->ID ) + AllTrim( ( cAliasRegs )->VERSAO )

						//Ajusta para Filial do evento
						cFilBkp := cFilAnt

						If !Empty((cAliasRegs)->FILIAL)
							cFilAnt := (cAliasRegs)->FILIAL
						EndIf

						nSeq++
						nSeqXML++
						cSeqXML := StrZero(nSeqXML,5)

						If Empty(cPathXml)

							cXml := &cFunction.( cAlsEvt, ( cAliasRegs )->RECTAB,, .T.,, cSeqXML, lInfoRPT )

							aAdd( aXmls , { EncodeUTF8( cXml ) , cId , ( cAliasRegs )->RECTAB , AllTrim( ( cAliasRegs )->LAYOUT ) , cAlsEvt } )
							nByteXML += Len( cXML ) + TAMMSIGN

							/*+-----------------------------------------------------------------------------------------------------+
							| Quando alcançar o limite, faço o envio do que já tenho  e zero o Array de XMLs                      |
							| Só é permitido o envio de 50 registros por lote (Manual de Orientação do Desenvolvedor e-Social 1.4)|
							| A	Variavel nSeq é utilizada para controle do lote e para o sequenciamento do ID do evento.          |
							+-----------------------------------------------------------------------------------------------------+*/ 
							If nSeq == 50 //nByteXML >= TAMMAXXML .Or. nSeq == 50

								nQtdLote++
								aAuxRet := TAFEvXml(aXmls,cAmbES,@nRegsOk,lJob,cIdThread,@lErroSch,@lErroSrv,cIdEnt,cVerSchema,nQtdLote,cUrl,@nRegErro,lTryPost)
								aAdd(aRetEvts,aClone(aAuxRet))
								aSize(aAuxRet,0)
								aSize(aXmls,0)
								aXmls 	 := {}
								aAuxRet  := {}
								nByteXML := 0
								nSeq	 := 0
								//Quando ocorre um Erro no Servidor aborto a operação.
								If lErroSrv
									Exit
								EndIf
							EndIf
						Else
							cXml := &cFunction.( cAlsEvt, ( cAliasRegs )->RECTAB,, .T.,, cSeqXML, lInfoRPT )
							cMsg := xTafGerXml( cXml , Substr( ( cAliasRegs )->LAYOUT , 3 , 4 ) , cPathXml , .T.  , /*lRetMsg*/, nSeq, /*cFile*/, /*cSigla*/,/*cFil */,/*lXmlErp*/, aArquivos)
							cLayout := ( cAliasRegs )->LAYOUT 
						EndIf

						cFilAnt := cFilBkp		

					EndIf
				Else
					lSemAcesso	:= .T.
				EndIf
				(cAliasRegs)->(dbSkip())
			EndDo

			If (getRemoteType() == REMOTE_HTML)
				TAFSmartXML(cPathXml, aArquivos, cLayout)
			EndIf
		
			If Len(aXmls) > 0
				nQtdLote++
				aAuxRet := TAFEvXml(aXmls,cAmbES,@nRegsOk,lJob,cIdThread,@lErroSch,@lErroSrv,cIdEnt,cVerSchema,nQtdLote,cUrl,@nRegErro,lTryPost) 
				aAdd(aRetEvts,aClone(aAuxRet)) 
				aSize(aAuxRet,0)
				aSize(aXmls,0)
				aXmls := {}
				aAuxRet := {}
			EndIf

			aHoraIni := StrTokArr(cHoraIni,":")
			cTempoTr := DecTime( Time() , Val(aHoraIni[1]) , Val(aHoraIni[2]) , Val(aHoraIni[3]) ) 
		
			If nQtdRegs > 1
				cMsgAux := STR0007 //"os eventos foram vinculados"  
			Else
				cMsgAux := STR0008 //"o evento foi vinculado"
			EndIf
		
			If !lErroSch .AND. !lErroSrv .AND. !lErroPred .AND. !lCancel
				cMsgRet := STR0009 + cMsgAux + STR0010 + CRLF + CRLF //"Você concluiu com sucesso a transmissão para o TSS. Verifique se "#" ao ambiente e-Social (RET) utilizando a rotina de detalhamento." 	
			ElseIf lErroSch
				cMsgRet := "Ocorreu(ram) erro(s) de schema(s) em 1 ou mais registros. Verifique as inconssistências utilizando a rotina de detalhamento." + CRLF + CRLF
			
				If nRegsOK == 0
					lNoErro := .F.
				EndIf
		
			ElseIf lErroSrv
				cMsgRet := "Não foi possivel efetuar o envio do(s) lote(s) para o servidor TSS. " + "Descrição do Erro: " 
				If Len(aAuxRet) > 1
					cMsgRet += aAuxRet[2] 
				EndIf
				cMsgRet += CRLF + CRLF
				lNoErro := .F.
			ElseIf lCancel

				cMsgRet := "Rotina interrompida pelo usuário. " 

				If nRegsOK > 0
					cMsgRet += "Os eventos transmitidos antes da ação de cancelamento já estão na base do TSS. "
				Else
					cMsgRet += "Não houve registros transmitidos para o TSS. "
					lNoErro := .F.
				EndIf
 
				cMsgRet += CRLF + CRLF
			Else
				If nRegsOK == 0
					lNoErro := .F.
				EndIf
				cMsgRet += CRLF 
			EndIf
		
			If !lErroSrv
				cMsgRet += AllTrim(Str(nRegsOK)) + "/" + AllTrim(Str(nQtdRegs)) + STR0011 + cTempoTr + "." //" evento(s) transmido(s) em "
			Else
				cMsgRet += "Tempo de Processamento: " + cTempoTr
			EndIf
		Else
			cMsgRet := STR0012 // "Não há eventos pendentes de transmissão a serem transmitidos considerando as opções selecionadas. "
		EndIf

		If lJob

			cLog := "* Fim Transmissão TAFProc4 TheadId: " + cIdThread +  " Tempo de processamento: " + ElapTime(cTimeProc,Time())  + " - Quantidade de Registros: " + AllTrim(Str(nRegsOK)) + "/" + AllTrim(Str(nQtdRegs))
			TafConOut(cLog)
		EndIf
	Else
		If lCancel
			aHoraIni := StrTokArr(cHoraIni,":")
			cTempoTr := DecTime( Time() , Val(aHoraIni[1]) , Val(aHoraIni[2]) , Val(aHoraIni[3]) ) 
		
			cMsgRet := "Rotina interrompida pelo usuário. Tempo de Execução: " + cTempoTr			
		EndIf

		lNoErro := .F.
	EndIf

	//--------------------------------------------------------------------
	// Deleta a tabela temporaria desde que não seja chamada da TAFMontES
	//--------------------------------------------------------------------
	If !lTabTmpExt .And. oTabFilSel <> NIL
		oTabFilSel:Delete()
	EndIf

	//Preciso desses valores no array retornado para mostrar o tipo de erro no PO UI.
	If lApi
		aAdd(aRetErro, lErroSch		) // Erro de schema
		aAdd(aRetErro, lErroSrv		) // Erro para se conectar no TSS
		aAdd(aRetErro, lErroPred	) // Erro de predecessão
		aAdd(aRetErro, lErroToken	) // Erro autenticação TSS
	EndIf

	RestArea(aArea)

Return aRetEvts

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFEvXml 
Realiza a Transmissão dos documentos.

@param aXmls  	- Array com os dados do Xml    
		  [x][1] - Xml do Evento
		  [x][2] - Id(chave do evento no TSS)
		  [x][3] - RecNo do Evento na sua respectiva tabela
		  [x][4] - Layout que correspondente ao evento
		  [x][5] - Alias correspondente ao Evento 
@param cAmbES	 - Ambiente de Transmissão/Consulta 		  
@param nRegsOk   - Numero de registros Integrados com sucesso   
@param cIdThread - Id da Thread que está executando o processamento (Job)
@param lErroSch  - Informa se houve erro de erro de Schema
@param lErroSrv  - Informa se houve erro no envio para o servidor TSS
@param cIdEnt	 - Id da Entidade TSS
@param cVerSchema - Versão do Schemas
@param nQtdLote - Quantidade de Lotes Enviados
@param cUrl - Url do Servidor TSS
@param nRegErro - Numero de eventos com erros
@param lTryPost	- Informa se o programa deve tentar reenviar as informações em caso de falha.

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
Static Function TAFEvXml(aXmls,cAmbES,nRegsOk,lJob,cIdThread,lErroSch,lErroSrv,cIdEnt,cVerSchema,nQtdLote,cUrl,nRegErro,lTryPost)

	Local oSocial		:= Nil
	Local nY			:= 1
	Local aRetEvts		:= {}
	Local lOk			:= .T.
	Local oHashXML		:= Nil
	Local xRetXML		:= Nil
	Local cDescErro		:= ""
	Local cErroTSS		:= ""
	Local cTabOpen		:= ""
	Local cAliasTb		:= ""
	Local cCodErro		:= ""
	Local dData			:= STOD("")
	Local cHora			:= ""
	Local nCtGrpXML		:= 0
	Local aGrpXmls		:= {}

	Default cAmbES		:= "2"
	Default aXmls		:= {}
	Default nRegsOk		:= 0
	Default nRegErro	:= 0
	Default cIdThread	:= ""
	Default cIdEnt		:= ""
	Default cVerSchema	:= ""
	Default cUrl		:= ""
	Default nQtdLote	:= 1
	Default lTryPost	:= .T.

	If Empty(cUrl)
		cUrl := PadR(TafGetUrlTSS(),250)
	EndIf

	cURL 		:= AllTrim(cURL)
	cUserTk 	:= "TOTVS"

	If Empty(AllTrim(cUrl))
		cDescErro 	:= "O parâmetro MV_TAFSURL não está preenchido"
		lOk 		:= .F.
	Else
		fAgrpXml(aXmls,@aGrpXmls,cVerSchema,cAmbES) //AGRUPANDO DADOS DO AXMLS
		aSize(aXmls,0)
		aXmls := {}

		for nCtGrpXML:=1 to len(aGrpXmls)
			nQtdLote 	:= Len(aGrpXmls[nCtGrpXML][2])
			cVerSchema 	:= aGrpXmls[nCtGrpXML][1]

			If EnviaDocumentos(@oSocial,aGrpXmls[nCtGrpXML][2],cUrl,cUserTk,cIdEnt,cAmbES,@cDescErro,cVerSchema,nQtdLote,lTryPost)

				If lVersaoFwt
					oHashXML := AToHM(aGrpXmls[nCtGrpXML][2],2,3)
				Else
					oHashXML :=	TafXAToHM(aGrpXmls[nCtGrpXML][2],2,3)
				EndIf

				BEGIN TRANSACTION

					For nY := 1 To Len(oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC)

						cIdAux := AllTrim(oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:CID)

						If lVersaoFwt
							HMGet(oHashXML,cIdAux,@xRetXML)
						Else
							TafXHMGet(oHashXML,cIdAux,@xRetXML )
						EndIf

						If !Empty(xRetXML[1][3])
							cAliasTb := xRetXML[1][5]
							If !(cAliasTb $ cTabOpen)
								cTabOpen += "|" + cAliasTb
								dbSelectArea(cAliasTb)
							EndIf
							(cAliasTb)->(dbGoTo(xRetXML[1][3]))
							RecLock((cAliasTb),.F.)

							If oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:lSucesso

								aAdd(aRetEvts,{.T.,xRetXML[1][4],cIdAux,STR0015,"", (cAliasTb)->&(cAliasTb+"_FILIAL"),cCodErro,dData,cHora})
								(cAliasTb)->&(cAliasTb+"_STATUS") := '2'
									If TafColumnpos(cAliasTb+"_DTRANS") .OR. TafColumnpos(cAliasTb+"_DTRAN")
										If cAliasTb != "V7C"
											(cAliasTb)->&(cAliasTb+"_DTRANS") := DATE()
										Else
											//Issue aberta para a correção do nome do campo e exclusão da linha após war room
											//remover as alterações desse checkin.
											(cAliasTb)->&(cAliasTb+"_DTRAN") := DATE()
										EndIf

										(cAliasTb)->&(cAliasTb+"_HTRANS") := TIME()
									EndIf 
								nRegsOK++
								TafConOut("ID " + AllTrim(cIdAux) + " Transmitido com Sucesso. Numero de Registros Transmitidos com Sucesso: " +  AllTrim(Str(nRegsOK)))
							Else

								//---------------------------------------------------------------------------------------------------------------------------------------------
								// 26/08/18 - Avaliação necessária pois estes campos dependem da atualização do TSS (TSSESOCIAL.PRW e TSSWSSOCIAL.PRW) e do TAF (WSSOCIAL.PRW)
								// As funções Type() e Len() não funcionam diretamente no objeto, necessitando do uso da ClassDataArr()
								//---------------------------------------------------------------------------------------------------------------------------------------------
								If Len(ClassDataArr(oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY])) > 4
									cCodErro	:= oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:CCODRECEITA
									dData		:= oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:DDTENTRADA
									cHora		:= oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:CHRENTRADA
								EndIf

								cErroTSS := oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:CDESCRICAO 

								cLog := "* Retorno Com Erro Lote " + AllTrim(Str(nQtdLote)) + " Id: " + cIdAux + " idThread: " + cIdThread + " - Hora: " + DTOC(dDataBase) + " - " + Time() + CRLF
								cLog += oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS:oWSSAIDAENVDOC[nY]:CDESCRICAO
								nRegErro++

								TafConOut(cLog)
								TafConOut("ID " + AllTrim(cIdAux) + " .Numero de Registros Transmitidos e retornados com inconssistencia no POST: " +  AllTrim(Str(nRegErro)))

								If isErrorRetransmission(cErroTSS)
									//registro ja transmitido para o TSS
									(cAliasTb)->&(cAliasTb+"_STATUS") := '2'
								Else 
									(cAliasTb)->&(cAliasTb+"_STATUS") := '3'
									//evento com inconsistência.
									aAdd(aRetEvts,{.F.,xRetXML[1][4],cIdAux,cErroTSS,"S", (cAliasTb)->&(cAliasTb+"_FILIAL"),cCodErro,dData,cHora})
									lErroSch := .T.
								Endif
							EndIf

							(cAliasTb)->(MsUnlock())
						Else
							aAdd(aRetEvts,{.F.,xRetXML[1][4],cIdAux,STR0016,"A", cFilAnt }) //"Não encontrado no lote de envio"
						EndIf

					Next nY

				END TRANSACTION
			Else
				lOk 		:= .F.
				lErroSrv 	:= !lOK //Se retorna false é por que houve erro na tentativa de envio para o TSS.
			EndIf

			FreeObj(oSocial)
			oSocial := Nil

			If ValType("oHashXML") == "O"
				FreeObj(oHashXML)
				oHashXML := Nil
			EndIf
		Next nCtGrpXML
	EndIf

Return {lOk, cDescErro, aRetEvts}

//---------------------------------------------------------------------------
/*/{Protheus.doc} enviaDocumentos 
Executa o método de transmisão dos eventos e-Social

@param oSocial  - Objeto WSTSSWSSOCIAL
@param aXmls  	- Array com os dados do Xml    
		  [x][1] - Xml do Evento
		  [x][2] - Id(chave do evento no TSS)
		  [x][3] - RecNo do Evento na sua respectiva tabela
		  [x][4] - Layout que correspondente ao evento
		  [x][5] - Alias correspondente ao Evento 
@param cUrl - Url do Servidor TSS
@param cUserTk - User Token
@param cIdEnt	 - Id da Entidade TSS
@param cAmbES	 - Ambiente de Transmissão/Consulta 	
@param cDescrErro  - Descrição do Erro	  
@param cVerSchema - Versão do Schemas
@param nQtdLote - Quantidade de Lotes Enviados
@param lTryPost	- Informa se o programa deve tentar reenviar as informações em caso de falha.
		  	 
@author Evandro dos Santos Oliveira
@since 15/05/2018
@version 1.0
/*/
//---------------------------------------------------------------------------   
Static Function enviaDocumentos(oSocial,aXmls,cUrl,cUserTk,cIdEnt,cAmbES,cDescrErro,cVerSchema,nQtdLote,lTryPost)

	Local lRetEnvio := .F.
	Local nTentativas := 0
	Local nY := 0
	Local lOk := .F.

	Default nQtdLote := 1

	While !lOk .And. nTentativas <= MAX_TENTATIVAS

		oSocial 	   						:= WSTSSWSSOCIAL():New()
		oSocial:_Url 						:= cUrl
		oSocial:oWSENTENVDADOS:cUSERTOKEN 	:= cUserTk
		oSocial:oWSENTENVDADOS:cID_ENT    	:= cIdEnt
		oSocial:oWSENTENVDADOS:cAMBIENTE   	:= cAmbES

		oSocial:oWSENTENVDADOS:oWSENTENVDOCS 				:= WsClassNew("TSSWSSOCIAL_ARRAYOFENTENVDOC")
		oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC 	:= {}

		For nY := 1 To Len(aXmls)

			xTAFMsgJob(STR0013 + aXmls[nY][4] + " - " + STR0014 + aXmls[nY][2]) //"Iniciando Transmissao - Layout "#"Id"
			aAdd(oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC,WsClassNew("TSSWSSOCIAL_ENTENVDOC"))
			Atail(oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC):CCODIGO	:= aXmls[nY][4]
			Atail(oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC):CID		:= aXmls[nY][2]
			Atail(oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC):CXML		:= aXmls[nY][1] //Encode64(aXmls[nY][1])
			Atail(oSocial:oWSENTENVDADOS:oWSENTENVDOCS:OWSENTENVDOC):CVERSAO	:= cVerSchema //Versao do schema
		Next nY

		lRetEnvio := oSocial:EnviarDocumentos()

		If ValType(lRetEnvio) == "L"
			If lRetEnvio
				If ValType(oSocial:oWSENVIARDOCUMENTOSRESULT:oWSSAIDAENVDOCS) <> "U"
					lOk := .T.
					Exit
				Else
					cDescrErro := STR0017 //"Tipo de dado Indefinido no retorno do WS."
					nTentativas++
				EndIf

			Else
				cDescrErro := "Servidor TSS não conseguiu processar a requisição."
				nTentativas++
			EndIf
		Else
			cDescrErro := STR0018 //"Retorno do WS não é do Tipo Lógico."
			nTentativas++
		EndIf

		If !lOK
			If nTentativas < MAX_TENTATIVAS  .And. lTryPost

				TafConOut("Tentando Conectar com o Servidor TSS. Lote " +   AllTrim(Str(nQtdLote)) + " Tentativa : " + AllTrim(Str(nTentativas)))
				Sleep(5000)
			Else
				TafConOut("Nao foi possivel conectar no servidor TSS.")
				Exit
			EndIf
		Else

			TafConOut("Lote  " + AllTrim(Str(nQtdLote)) + " transmitido com Sucesso: Tentativas: " + AllTrim(Str(nTentativas)))
		EndIf

	EndDo

	If !lOk

		cDescrErro += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		TafConOut(cDescrErro)
	EndIf

Return (lOk)

//--------------------------------------------------------------------
/*/{Protheus.doc} TafTrmLimp
Função utilizada para transmissão do evento S-1000 modificado, com o intuito de remover empregador da base de dados

@param cRetorno - Retorna a resposta da requisição por referência
@param lJob - Informa se a função é chamada via JOB ou API

@return aRetEvts -> Array contendo os erros de transmissão

@Author	anieli.rodrigues
@Since	26/12/2017

@Version 1.0
/*/
//---------------------------------------------------------------------
Function TafTrmLimp(cRetorno, lJob)

	Local aAreaC1E		:= C1E->(GetArea())
	Local aAuxRet		:= {}
	Local aRetEvts		:= {}
	Local aXML			:= {}
	Local cAliasRegs	:= GetNextAlias()
	Local cId			:= ""
	Local cQry			:= ""
	Local cXml			:= ""
	Local cVerSchema	:= ""
	Local cStatus		:= ""
	Local cIdEnt		:= ""
	Local cUrl			:= ""
	Local cCheckURL		:= ""
	Local lErroSch		:= .F.
	Local lErroSrv		:= .F.
	Local lTransFil		:= .F.
	Local nQtdRegs		:= 0
	Local nRegsOk		:= 0
	Local oModel050		:= Nil
	Local cMsgRet		:= ""
	Local lCancel		:= .F.

	Default cRetorno	:= ""
	Default lJob		:= .F.

	cURL := PadR(TafGetUrlTSS(), 250)
	cURL := AllTrim(cURL)

	If lJob .OR. MsgYesNo( STR0021, STR0022) //"Ao selecionar esta opção, todos os eventos enviados ao ambiente de Produção Restrita, inclusive o evento S-1000, serão removidos da base de dados do governo. Deseja continuar?" "ATENÇÃO"

		cQry := "SELECT R_E_C_N_O_ RECTAB, C1E_FILTAF FILTAF "
		cQry += "FROM " + RetSqlName("C1E") + " "
		cQry += "WHERE C1E_FILIAL = '"+xFilial("C1E")+"' "
		cQry += " AND C1E_FILTAF = '"+cFilAnt+"' "
		cQry += " AND C1E_ATIVO  = '1' "
		cQry += " AND C1E_MATRIZ = 'T' "
		cQry += " AND D_E_L_E_T_ <> '*' "

		//Retirada condição de só excluir os transmitidos, para evitar erros caso a rotina de exclusão de periodo tenha rodado antes (Rossi)
		//cQry += "AND C1E_STATUS = '4' " // APENAS STATUS = 4, POIS SÓ POSSO LIMPAR O QUE JÁ FOI TRANSMITIDO (Anieli)

		cQry := ChangeQuery(cQry)

		TcQuery cQry New Alias (cAliasRegs)

		Count To nQtdRegs

		If nQtdRegs > 0

			(cAliasRegs)->(dbGoTop())

			C1E->( dbSetOrder(3) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
			If C1E->( MsSeek(xFilial("C1E")+(cAliasRegs)->FILTAF+"1" ) )

				oModel050 := FWLoadModel("TAFA050")
				oModel050:SetOperation(4)
				oModel050:Activate()
				oModel050:LoadValue( 'MODEL_C1E', 'C1E_VERSAO', xFunGetVer() )
				oModel050:LoadValue( 'MODEL_C1E', 'C1E_EVENTO', "I" )
				FWFormCommit( oModel050 )
				oModel050:DeActivate()

				dbSelectArea("C1E")
				RecLock("C1E", .F.)
				C1E->C1E_STATUS := " "
				C1E->C1E_PROTUL := " "
				C1E->C1E_PROTPN := " "
				MsUnLock()

			EndIf

			cId := "S1000" + C1E->C1E_ID + C1E->C1E_VERSAO

			cXml := TAF050Xml("C1E", C1E->(Recno()), , .T., .T.)

			aAdd(aXml, {EncodeUTF8(cXml), cId, (cAliasRegs)->RECTAB, "S-1000", "C1E"})

			cStatus := '0'
			cVerSchema := SuperGetMv( "MV_TAFVLES", .F., "S_01_00_00" ) //IIF(TafLayESoc("S_01_00_00"),'S_01_00_00','02_05_00')
			lTransFil := TAFTransFil(lJob,@cStatus)

			If !("TSSWSSOCIAL.APW" $ Upper(cUrl))
				cCheckURL := cUrl
				cUrl += "/TSSWSSOCIAL.apw"
			Else
				cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
			EndIf
			
			If VerificaEntidade(@cIdEnt,lTransFil,cCheckURL,@cMsgRet,lJob,@lCancel)
				aAuxRet := TAFEvXml(aXml, "2", @nRegsOk, lJob,, @lErroSch, @lErroSrv, cIdEnt, cVerSchema,, cUrl)

				If !Empty(aAuxRet)

					aAdd(aRetEvts, aClone(aAuxRet))

				EndIf

				If !lErroSch .And. !lErroSrv
					cMsgRet := STR0023 //"Transmissão efetuada com sucesso. Verifique o retorno da transmissão através da opção 'Detalhamento', selecionando o evento S-1000. Se a situação do evento for 'Evento Rejeitado', consulte sua inconsistência. Se o código da inconsistência for '1012', execute a rotina 'Exclusão por Período Fiscal' para remover os dados da base do TAF."
				ElseIf lErroSch
					cMsgRet := STR0024 //"Ocorreu um erro de schema. Verifique as inconsistências utilizando através da opção 'Detalhamento' selecionando o evento S-1000."
				ElseIf lErroSrv
					cMsgRet := STR0025 + aAuxRet[2]
				EndIf

				If !lJob
					
					TAFAviso( STR0026 , cMsgRet , {"OK"}, 3, STR0027) //"Remoção do empregador" "Transmissão do evento"
				
				Else

					cRetorno := cMsgRet
				
				EndIf

			Else

				If !lJob

					cMsgRet := "Entidade não encontrada!"

					TAFAviso(STR0026, cMsgRet, {"OK"}, 3, STR0027)
				
				EndIf

			EndIf

		Else

			If !lJob
			
				TAFAviso(STR0026, STR0028, {"OK"}, 3, STR0027) //"Remoção do empregador" "Não há nenhum registro válido para remoção" "Transmissão do evento"

			Else

				cRetorno := STR0028 // "Não há nenhum registro válido para remoção"

			EndIf
		
		EndIf

		(cAliasRegs)->(dbCloseArea())

	EndIf

	RestArea(aAreaC1E)

Return aRetEvts

//--------------------------------------------------------------------
/*/{Protheus.doc} VerificaEntidade
Tenta conexão com o servidor TSS e executa o método ADMEMPRESAS para
a recuperação da entidade.

@param cIdEnt - Id da Entidade (referencia)
@param lTransFil - determina se o ambiente está habilitado para realizar
tranmissões pela filial.
@parm cUrl - Url com o endereço do servior TSS
@param cMsgRet - Mensagem de Inconsistência (refêrencia) 

@return lConnect - Indica se houve conexão com o TSS

@author	Evandro dos Santos Oliveira

@since	21/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function VerificaEntidade(cIdEnt,lTransFil,cUrl,cMsgRet,lJob,lCancel,lTryPost, lApi, cUser, lErroToken)

	Local nTentativas 	:= 0
	Local lconnect 		:= .F.
	Local lValidErp 	:= .F.
	Local lTSSOk 		:= .F.

	Default lTryPost 	:= .F.
	Default lApi 	 	:= .F.
	Default cUser	 	:= ""
	Default lErroToken	:= .F.

	If lVersaoFwt
		While nTentativas <= MAX_TENTATIVAS .And. !lCancel
			If TAFCTSpd(cUrl,,,@cMsgRet)
				cIdEnt := TAFRIdEnt(lTransFil,.F.,@cMsgRet,@lValidErp,@lTSSOk,.T., lApi, cUser, @lErroToken)
				If lValidErp .And. !lTSSOk //Sem erros de validação ERP e retorno negativo do TSS
					If !lTryPost
						Exit
					EndIf
					waitConnect(@nTentativas,lJob)
				ElseIf !lValidErp //Se houver erros de validação do ERP (TAF)
					lconnect := .F.
					Exit
				Else
					lconnect := .T.
					Exit
				Endif
			Else
				If !lTryPost
					Exit
				EndIf
				waitConnect(@nTentativas,lJob)
			EndIf
		EndDo
	Else
		lconnect := .T.
		cIdEnt    := TAFRIdEnt(lTransFil,,,,,.T.)
	EndIf

Return lconnect

//--------------------------------------------------------------------
/*/{Protheus.doc} waitConnect

@param nTentativas - Numero de tentativas de conexão realizadas. (referencia)

@return Nil 

@author	Evandro dos Santos Oliveira

@since	21/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function waitConnect(nTentativas,lJob)

	nTentativas++
	If nTentativas < MAX_TENTATIVAS

		If lJob

			TafConOut("TAFRIdEnt - Tentando Conectar com o Servidor TSS.  Tentativa : " + AllTrim(Str(nTentativas)))
		Else

			IncProc("Tentando Conectar com o Servidor TSS.  Tentativa : " + AllTrim(Str(nTentativas)))
		EndIf

		Sleep(1000)
	EndIf

Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} fAgrpXml
Função agrupadora de xmls que serão transmitidos
@param aXmls		- Xmls a serem desmembrados
@param aGrpXmls		- Eventos agrupados do XML 
@param cVerSchema	- Versão do Schema
@param cAmb 		- Ambiente de integracao
@return lRet		- lógico 
@author	Eduardo Vicente
@since	20/03/2021
@version 1.0
@example
{ EncodeUTF8( cXml ) , cId ,
 ( cAliasRegs )->RECTAB , AllTrim( ( cAliasRegs )->LAYOUT ) , cAlsEvt }
/*/
//---------------------------------------------------------------------
Static Function fAgrpXml(aXmls as array,aGrpXmls as array,cVerSchema as character,cAmb as character)

	Local lRet			as logical
	Local nCtXml		as numeric
	Local cEvtOrgPub	as character
	
	Default aXmls		:= {}
	Default aGrpXmls	:= {}
	
	lRet		:= .F.
	nCtXml		:= 0
	cEvtOrgPub	:= "S-2500|S-2501|S-3500"

	For nCtXml:= 1 To len(aXmls)
			
		addDadosEvt(cVerSchema, @aGrpXmls,aXmls[nCtXml] )
	
	Next nCtXml

return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} addDadosEvt
Função de inclusão de dados de xml nos arrays agrupadores
@param cPosEvt		- Evento Centralizador
@param aGrpXmls		- Eventos agrupados do XML 
@param aXmls 		- XML Posicionado
@return lRet		- Lógico 
@author	Eduardo Vicente
@since	22/03/2021
@version 1.0
/*/
//---------------------------------------------------------------------

Static Function addDadosEvt(cPosEvt, aGrpXmls,aXmls)
Local nPosVersao	:= 0
Local lRet			:= .T.

if nPosVersao == 0
	nPosVersao := aScan(aGrpXmls, {|x| x[1] == cPosEvt})
endIf

if nPosVersao > 0
	aAdd(aGrpXmls[nPosVersao][2],aXmls)
else
	aAdd(aGrpXmls,{cPosEvt,{aXmls} })
endIf	

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} isErrorRetransmission
Funcao para tratamento temporario dos erros de registro já transmitido para o TSS. 
Ex: "Documento nao pode ser retransmitido pois encontra-se com o status: 6-Evento autorizado"
Nestas situacoes é necessário gravar o status do registro com 2 e não com 3.

@param  - cErroTSS String
@return - Lógico 
@author	Evandro dos Santos Oliveira Teixeira
@since	20/06/2023
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function isErrorRetransmission(cErroTSS as character)

	Local aErros as Array

	aErros := StrToKArr(cErroTSS," ")

	If ValType(aErros) == "A".And. Len(aErros) > 4 //proteção por que não sei se sempre virá informacao na variável cErroTSS
		If aErros[5] == "retransmitido"
			Return .T.
		EndIf
	EndIf 

Return .F. 
