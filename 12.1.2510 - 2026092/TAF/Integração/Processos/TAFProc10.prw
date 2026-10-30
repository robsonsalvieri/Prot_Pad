#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAMMAXXML 075000  //Tamanho Maximo do XML
#DEFINE TAMMSIGN  004000  //Tamanho mÃ©dio da assinatura 

static oModel497 as Object
static oModel501 as Object
static oModel604 as Object //TAFA604 - MVC R-9005
static oModel606 as Object //R-4099 R9015 V9F

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc10
Chama rotina responsavel por verificar os registros que devem ser Consultados

@return Nil 

@author Evandro dos Santos Oliveira
@since 07/11/2013 - Alterado 18/05/2015
@version 1.0
@obs - Rotina separada do fonte TAFAINTEG e realizado tratamentos especificos
		para a utilizaÃ§Ã£o do Job5 realizando a chamada individualmente e utilizando
		o schedDef para a execuÃ§Ã£o no schedule.
/*/
//----------------------------------------------------------------------------  
Function TAFProc10( aAlias , aEvt  )

Local lJob as logical
Local lEnd as logical
Default aAlias := {} 
Default aEvt   := {}

lJob := lEnd := .F.
lJob := IsBlind()

If TAFAtualizado(!lJob)
	TAFConOut('Rotina de Monitoramento de eventos REINF - Empresa: ' + cEmpAnt + ' Filial: ' + cFilAnt, 1, .T., "PROC10" )
	If lJob
		TAFProc10TSS(lJob,aEvt,/*3*/,/*4*/,/*5*/,@lEnd,/*7*/,/*8*/,/*9*/,/*10*/,/*11*/,/*12*/,aAlias,/*14*/)
	Else
		Processa( {||TAFProc10TSS(lJob,,,,,@lEnd)}, "Aguarde...", "Executando rotina de TransmissÃ£o",  )
	EndIf
	If lEnd .And. !lJob; MsgInfo("Processo finalizado."); EndIf
EndIf

Return Nil 

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc10Tss 
Processo responsavel por verificar os registros que devem ser consultados no
TSS.

@param	lJob - Flag para IdentificaÃ§Ã£o da chamada de FunÃ§Ã£o por Job
@param 	aEvtsReinf 	- Array com os Eventos a serem considerados, quando vazio sÃ£o considerados 
		todos os eventos contidos no TAFROTINAS. 
		Obs: Quando informados os eventos devem seguir a mesma estrutura dos eventos REINF
		contidos no TAFROTINAS.
@param 	cStatus - Status dos eventos que devem ser transmitidos, quando vazio  o sistema usa o 0 
        para tranmissÃ£o e o 2 para consulta; o parÃ¢metro pode conter mais de 1 status par isso
        passar os status separados por virgula ex: "1,3,4"
@param cRecNos - Filtra os registro pelo RecNo do Evento, pode ser utilizado um range de recnos
		ex;"1,5,40,60"
@param lEnd - Verifica o fim do processamento(variÃ¡vel referenciada) 
@param cMsgRet - Mensagem de retorno do WS (referÃªncia)
@param aFiliais - Array de Filiais
@param dDataIni	-> Data Inicial dos eventos
@param dDataFim	-> Data Fim dos dos eventos    
@param lEvtInicial -> Informa se o parÃ¢metro de evento inicial foi marcado. 	
@param lCommit -> Indica se serÃ¡ comitado na tabela

@return Nil 

@author Evandro dos Santos Oliveira
@since 07/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------    
Function TAFProc10Tss(lJob, aEvtsReinf, cStatus, aIdTrab, cRecNos, lEnd, cMsgRet,aFiliais,dDataIni,dDataFim,lEvtInicial,lCommit,aRecREINF,cIdEnt,lGrvRet)

Local nTopSlct 		as numeric
Local cQry			as char
Local cMaxRegs 		as char
Local lMultSts 		as logical
Local nX,nY	 		as numeric
Local nQtdRegs		as numeric
Local cFunction		as char
Local cAliasRegs	as char
Local cXml			as char
Local cMsg			as char
Local cAliasTb  	as char
Local cLayout		as char
Local cIdTrab		as char
Local lEvtTrb		as logical
Local cId			as char
Local cTabOpen		as char
Local cRegNode		as char
Local nByteXML		as numeric
Local oXml			as object
Local cMsgProc   	as char
Local aRetorno		as array
Local cAmbte		as char
Local cBancoDB 		as char
Local cUrl			as char
Local cCheckURL		as char
Local cTimeProc		as char
Local cAliasEve		as char
Local cIdThread		as char
Local lAllEventos	as logical
Local nQtdPorLote	as numeric
Local aXmlsLote		as array
Local nItem			as numeric
Local aXmls			as array 

Default cStatus 	:= ""
Default aEvtsReinf	:= {}
Default aIdTrab 	:= {}
Default aRecREINF	:= {}
Default cRecNos		:= ""
Default cMsgRet 	:= ""
Default lEnd		:= .T.
Default dDataIni	:= dDataBase
Default dDataFim	:= dDataBase
Default lCommit		:= .T.
Default lGrvRet     := .T.

nTopSlct 		:= 999999
cQry			:= ""
cMaxRegs 		:= ""
lMultSts 		:= .F.
nX		 		:= 0
nY		 		:= 0
nQtdRegs		:= 0
cFunction		:= ""
cAliasRegs		:= GetNextAlias()
cXml			:= ""
cMsg			:= ""
cAliasTb  		:= ""
cLayout			:= ""
cIdTrab			:= ""
lEvtTrb			:= .F.
cId				:= ""
cTabOpen		:= ""
cRegNode		:= ""
cAliasEve		:= ""
nByteXML		:= 0
oXml			:= Nil 
cMsgProc   		:= ""
aRetorno		:= {}
cAmbte			:= SuperGetMv('MV_TAFAMBR',.F.,"2")
cBancoDB 		:= Upper(AllTrim(TcGetDB()))
cUrl			:= GetMv("MV_TAFSURL")
cTimeProc		:= Time() 
cIdThread	 	:= StrZero(ThreadID(), 10 )
nQtdPorLote		:= 50
aXmls			:= {}
aXmlsLote		:= {}
nItem 			:= 0

If Empty(AllTrim(cUrl))
	If lJob
		TAFConOut("O parâmetro MV_TAFSURL não está preenchido", 2, .T., "PROC10" )
	Else
		cMsgRet := "O parâmetro MV_TAFSURL não está preenchido"
	EndIf
Else
	If lJob; TAFConOut("* Inicio Consulta TAFProc10 TheadId: " + cIdThread + " - Data de Inicio: " + DTOC(dDataBase) + " - " + cTimeProc, 2, .T., "PROC10" ); EndIf
	If !("TSSWSREINF.APW" $ Upper(cUrl)) 
		cCheckURL := cUrl
		cUrl += "/TSSWSREINF.apw"
	Else
		cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
	EndIf

	If TAFCTSpd(cCheckURL)
		cStatus 	:= IIf(Empty(cStatus),'2',cStatus)
		cAliasEve	:= AllTrim( aEvtsReinf[3] )
		lAllEventos	:= Empty(aRecREINF) //Quando nÃ£o vem eventos selecionados devo considerar todos por que nÃ£o houve marcaÃ§Ã£o no browse
		If Len(aRecREINF) > 0
			cAliasEve := AllTrim( aEvtsReinf[3] )
			For nX:= 1 to Len(aRecREINF)
				( cAliasEve )->(dbGoTo( aRecREINF[nX] ) )
				cId := AllTrim ( STRTRAN( aEvtsReinf[4] , "-" , "" ) ) + &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_ID") + &(AllTrim(cAliasEve)+"->"+AllTrim(cAliasEve)+"_VERSAO")
				aAdd(aXmls,{"",cId, aRecREINF[nX], AllTrim( aEvtsReinf[4] ) , cAliasEve})
				nItem++
				If nItem == nQtdPorLote
					aAdd(aXmlsLote,aClone(aXmls))
					aSize(aXmls,0)
					nItem := 0
				EndIf
			Next
			If Len(aXmls) > 0 //Se houver, adiciono o residuo no array de lote
				aAdd(aXmlsLote,aClone(aXmls))
				aSize(aXmls,0)
			EndIf
		EndIf
		If Len(aXmlsLote) > 0
			aRetorno := TAFConRg(aXmlsLote,cAmbte,lGrvRet,cUrl,lJob,cIdEnt)
		EndIf
	Else
		If lJob
			TAFConOut("Não foi possivel conectar com o servidor TSS", 2, .T., "PROC10" )
			cMsgRet := "Não foi possivel conectar com o servidor TSS"
		Else
			cMsgRet := "Não foi possivel conectar com o servidor TSS"
		EndIf
	EndIf
EndIf
Return (aRetorno)

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFConRg  
Realiza consulta dos registros transmitidos.

@param	aXmlsLote  	- Array com os dados do Xml    
		cAmbiente	- Ambiente de TransmissÃ£o/Consulta 		  
					  [x][1] - Xml do Evento
					  [x][2] - Id(chave para transmissÃ£o)
					  [x][3] - RecNo do Evento na sua respectiva tabela
					  [x][4] - Layout que correspondente ao evento
					  [x][5] - Alias correspondente ao Evento
		lGrvRet		- Determina se deve ocorrer a gravaÃ§Ã£o dos status    
		cUrl		- Url - Url do servidor TSS para o Ambiente REINF
		lJob		- Identifica se a rotina estÃ¡ sendo executada por Job ou tela

@author Evandro dos Santos Oliveira
@since 19/11/2013
@version 1.0
/*/
//---------------------------------------------------------------------------    
Static Function TAFConRg(aXmlsLote,cAmbiente,lGrvRet,cUrl,lJob,cIdEnt,cEvento)

Local oReinf 		as object
Local lRet			as logical
Local cStatus   	as char
Local cUserTk		as char
Local cMsgRet		as char
Local oHashXML		as object
Local cIdAux		as char
Local aRetorno  	as array
Local aAreaC9V		as array
Local cAuxSts		as char
Local aCampos		as array
Local cExclCmp		as char
Local cAliasTb		as char
Local aInfRegs		as array
Local cTabOpen 		as char
Local cLayOut		as char
Local cRecAnt		as char 
Local cRecibo		as char
Local cFilErp		as char
Local cPerApur		as char
Local nQtdPorLote	as numeric
Local nNumLote	    as numeric
Local nQtdLotes		as numeric 
Local nY			as numeric 
Local nItemLote		as numeric
Local nLote 		as numeric 
Local aLoteRetorno  as array
Local dDateProc		as Date
Local xRetXML		
Local lErroToken	as logical

Default cAmbiente	 := ""
Default aXmlsLote    := {}
Default lGrvRet 	 := .T.  

Private aRetXML  as array

oReinf	 	 := Nil
lRet		 := .F.
cStatus   	 := ""
cIdEnt		 := TAFRIdEnt(,,,,,.T.)
cUserTk		 := ""
cMsgRet		 := ""
oHashXML	 := Nil 
cIdAux		 := ""
aRetorno  	 := {}
aAreaC9V	 := {}
cAuxSts		 := ""
aCampos		 := {}
cExclCmp	 := ""
cAliasTb	 := ""
aInfRegs	 := {}
cTabOpen 	 := ""
cLayOut		 := ""
cRecAnt		 := ""
cRecibo		 := ""
cFilErp 	 := ""
cPerApur     := ""
dDateProc    := CtoD("  /  /    ")
nY			 := 0
nItemLote	 := 0
nNumLote     := 0
nTotEventos  := 0
nLote 		 := 0
nQtdPorLote	 := 50
aLoteRetorno := {}
aRetXML		 := {}
xRetXML		 := Nil
cUserTk 	 := "TOTVS"
nQtdLotes 	 := Len(aXmlsLote)
lErroToken	 := .f.

If lJob
	TAFConOut("Quantidade de Lotes a serem enviados: " + AllTrim(Str(nQtdLotes)), 1, .T., "PROC10" )
Else
	ProcRegua(Len(aXmlsLote))
EndIf

dbSelectArea("T0X")
T0X->(dbSetOrder(3))

dbSelectArea("C1E")
C1E->(dbSetOrder(3))
C1E->(MsSeek(xFilial("C1E")+cFilAnt+"1"))
cFilErp := AllTrim(C1E->C1E_CODFIL) 

oModel497 := FWLoadModel("TAFA497")	
oModel501 := FWLoadModel("TAFA501")
oModel604 := FWLoadModel("TAFA604")
oModel606 := FWLoadModel("TAFA606")

For nLote := 1 To nQtdLotes
	oReinf 											:= WSTSSWSREINF():New()
	oReinf:oWSREINFCONSULTA:oWSCABEC				:= WsClassNew("TSSWSREINF_REINFCABECCONSULTA")
	oReinf:_Url 									:= cUrl
	oReinf:oWSREINFCONSULTA:oWSCABEC:cENTIDADE		:= cIdEnt
	oReinf:oWSREINFCONSULTA:oWSCABEC:cUSERTOKEN		:= cUserTk
	oReinf:oWSREINFCONSULTA:oWSCABEC:cAMBIENTE		:= cAmbiente
	oReinf:oWSREINFCONSULTA:oWSCABEC:lRETORNAXML	:= .T.
	oReinf:oWSREINFCONSULTA:oWSEVENTOS	:= WsClassNew("TSSWSREINF_ARRAYOFREINFID")
	oReinf:oWSREINFCONSULTA:oWSEVENTOS:oWSREINFID 	:= {}

	xTAFMsgJob("Processando Lote: " + AllTrim(Str(nLote)) + "/" +  AllTrim(Str(nQtdLotes))) 

	For nItemLote := 1 To Len(aXmlsLote[nLote])
		aAdd(oReinf:oWSREINFCONSULTA:oWSEVENTOS:oWSREINFID,WsClassNew("TSSWSREINF_REINFID"))
		Atail(oReinf:oWSREINFCONSULTA:oWSEVENTOS:oWSREINFID):CID := aXmlsLote[nLote][nItemLote][2]
	Next nItemLote

	lRet := oReinf:CONSULTAREVENTOS()
	If ValType(lRet) == "L"
		If lRet
			oHashXML := AToHM(aXmlsLote[nLote], 2, 3 )
			aLoteRetorno := oReinf:oWSCONSULTAREVENTOSRESULT:oWSREINFRETCONSULTA
			If (lGrvRet)
				For nY := 1 To Len(aLoteRetorno)
					cIdAux := AllTrim(aLoteRetorno[nY]:CID)
					HMGet( oHashXML , cIdAux ,@xRetXML )
					If ValType(xRetXML[1][3]) == "N"
						cAliasTb := xRetXML[1][5]
						If !(cAliasTb $ cTabOpen)
							cTabOpen += "|" + cAliasTb
						EndIf
						dbSelectArea(cAliasTb)
						(cAliasTb)->(dbGoTo(xRetXML[1][3]))
						BEGIN TRANSACTION
							cLayOut   := xRetXML[1][4]
							cStatus   := aLoteRetorno[nY]:CSTATUS
							cRecibo	  := AllTrim(aLoteRetorno[nY]:CRECIBO) //Retorno do NÃºmero do Recibo de TransmissÃ£o do TSS
							dDateProc := aLoteRetorno[nY]:DDTPROC
							If cStatus == "6"
								limpaRegT0X(cIdAux)
							ElseIf cStatus == "5"
								limpaRegT0X(cIdAux)
							EndIf
							cAuxSts := TAFStsXTSS(cStatus)
							If !Empty(cAuxSts) //Gravo o status do registro de retorno
								RecLock((cAliasTb),.F.)
								(cAliasTb)->&(cAliasTb+"_STATUS") := cAuxSts
								If !Empty(cRecibo) //Gravo o numero do protocolo de transmissÃ£o do TSS
									(cAliasTb)->&(cAliasTb+"_PROTUL") := cRecibo
								EndIf
								(cAliasTb)->(MsUnlock())
								cRecAnt := (cAliasTb)->&(cAliasTb+"_PROTPN") //Armazeno o nÃºmero do protocolo anterior
								If TAFColumnPos( cAliasTb+"_PERAPU" )
									cPerApur := (cAliasTb)->&(cAliasTb+"_PERAPU")
								EndIf
								aRetXML := aLoteRetorno[nY] //Retorno para tratar tipo
								If cLayOut $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010|R-2099|R-2098|" .And. cStatus == "6" .And. Type("aRetXML:CXMLRETEVEN") <> "U"
									GeraEvtTot(aRetXML:CXMLRETEVEN, cLayOut, cAliasTb, (cAliasTb)->&(cAliasTb+"_FILIAL"), cRecibo, cRecAnt, aRetXML:CVERSAO, ,aRetXML:CRECIBO)
									IF cLayOut $ "R-2099|R-2098"
										Taf503Grv(cLayOut, cPerApur, dDateProc, Time(), cRecibo,"20")
										If cLayOut $ "R-2098"
											//Altero o campo V0C_ATIVO (R-9011) para 2
											Status2098(cPerApur)
										EndIf
									EndIf
								ElseIf ( (cLayOut $ "R-4010|R-4020|R-4040|R-4080|") .Or. (cLayOut == "R-4099" .And. V3W->V3W_SITPER == '0') ); 
									.And. cStatus == "6" .And. Type("aRetXML:CXMLRETEVEN") <> "U" //Nao gravar totalizador quando V3W_SITPER = 1 Reabertura
									GeraEvTot40(aRetXML:CXMLRETEVEN, cLayOut, cAliasTb, (cAliasTb)->&(cAliasTb+"_FILIAL"), cRecibo, cRecAnt, aRetXML:CVERSAO, ,aRetXML:CRECIBO)
								ElseIf cLayOut == "R-4099" .And. V3W->V3W_SITPER == '1' .And. cStatus == "6" .And. Type("aRetXML:CXMLRETEVEN") <> "U"
									EstornaEvTot40(cPerApur)
								EndIf
								If cLayOut $ "R-9000" .And. cStatus == "6" .And. Type("aRetXML:CXMLRETEVEN") <> "U"
									cEvento := Posicione( "T9B", 1, xFilial( "T9B" ) + T9D->T9D_IDTPEV, "T9B_CODIGO" )
									cProtEvt:= T9D->T9D_NRRECI
									cProtExc:= T9D->T9D_PROTUL
									cMsgRet += TafSetEvExc( cEvento , cProtEvt , cStatus , cProtExc )[02]
								EndIf
							EndIf
						END TRANSACTION
					Else
						cMsgRet := "Id " + cIdAux +" não encontrado no lote de envio. "
					EndIf
				Next nY
			EndIf
		Else
			cMsgRet := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) //SOAPFAULT
		EndIf
	Else
		//Guardo código de retorno do webservice
		cCodFault := GetWscError(2)
		
		if TAFVldTokenTSS(@cMsgRet, @lErroToken,cCodFault,.t.)
			cMsgRet := "Retorno do WS não é do Tipo Lógico." //"Retorno do WS não é do Tipo Lógico."
			cMsgRet += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		else
			if lJob .and. lErroToken
				//Troco msg da função TAFVldTokenTSS se for job, pois o poNotication não trabalha legal com quebras de linhas e mensagens grandes
				cMsgRet := "Token TSS não informado ou inválido - Autenticação obrigatório TAF X TSS"
			Endif
		Endif
		
	EndIf
	oHashXML := Nil
	aAdd(aRetorno,aClone(aLoteRetorno))
	aSize(aLoteRetorno,0)
Next nLote

oModel497:Destroy()
oModel497 := Nil

oModel501:Destroy()
oModel501 := Nil

oModel604:Destroy()
oModel604 := Nil

oModel606:Destroy()
oModel606 := Nil

aSize(aXmlsLote,0)
If !Empty(cMsgRet); TAFConOut(cMsgRet, 1, .T., "PROC10" ); EndIf

Return aRetorno 

//---------------------------------------------------------------------
/*/{Protheus.doc} TafSetEvExc

Atualiza registros excluidos de acordo com o retorno do R-9000
Obs. O registro R-9000 deve estar posicionado.

@Param  cStatus - Status de retorno do TSS
@return x - [1] - Status da gravaÃ§Ã£o (logico)
		    [2] - DescriÃ§Ã£o efetividade da gravaÃ§Ã£o

@Author		Evandro dos Santos O. Teixeira
@Since		13/08/2017
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function TafSetEvExc( cEvtExcluido , cProtEvt , cStatus , cProtExc )

	Local cAliasExclu  	as char
	Local nOrdRecibo   	as numeric 
	Local aEvtExc	 	as array
	Local lGravaOk		as logical
	Local cMsgRet		as char
	Local Nx 			as numeric
	Local aArea			as array

	Default	cEvtExcluido	:= ""
	Default	cProtEvt		:= ""
	Default	cStatus			:= ""
	Default	cProtExc		:= ""

	Nx 		 	:= 1	
	lGravaOk 	:= .T.
	cMsgRet		:= ""
	cMsgErro 	:= ""
	aEvtExc		:= TAFRotinas(cEvtExcluido,4,.F.,5)
	aArea 		:= GetArea()

	If Len( aEvtExc ) > 1
		cAliasExclu  := aEvtExc[3]
		nOrdRecibo	 := aEvtExc[13]
		
		cQryExc := "SELECT R_E_C_N_O_, "+cAliasExclu+"_ID FROM "+RetSqlName(cAliasExclu)+ " WHERE D_E_L_E_T_ = ' ' AND ("+cAliasExclu+"_PROTPN ='"+cProtEvt+"' OR "+cAliasExclu+"_PROTUL ='"+cProtEvt+"' )"
		aRecnos := TafQryarr( cQryExc )

		DbSelectArea(cAliasExclu)
		For Nx := 1 To Len( aRecnos )
			(cAliasExclu)->( DbGoTo( aRecnos[Nx][01] ) )
			If (cAliasExclu)->&(cAliasExclu+"_EVENTO") == "E" .And. (cAliasExclu)->&(cAliasExclu+"_STATUS") == "6"
				RecLock( cAliasExclu, .F. )
				(cAliasExclu)->&(cAliasExclu+"_STATUS") := TAFStsEXTSS(cStatus)
				(cAliasExclu)->&(cAliasExclu+"_PROTUL") := cProtExc
				(cAliasExclu)->(MsUnlock())
				cMsgRet := "Atualização do Status de exclusão do evento " + cEvtExcluido + " realizado com sucesso."
				//Limpa o PERAPU da tabela V3U quando evento R-4010 ou R-4020
				If cAliasExclu $ 'V5C|V4Q' .And. (cAliasExclu)->( Recno() ) > 0 .And. TAFColumnPos("V3U_PERAPU")
					TAFLimpPer(cAliasExclu, (cAliasExclu)->( Recno() ))
				EndIf				

                If (cAliasExclu)->&(cAliasExclu+"_STATUS") == "7" .And. !Empty((cAliasExclu)->&(cAliasExclu+"_PROTUL"))

                    If cEvtExcluido $ "R-4010|R-4020|R-4040|R-4080"

                        DbSelectArea("V9D")
                        V9D->(DbSetOrder(5))

                        If V9D->(DbSeek(xFilial("V9D") + (cAliasExclu)->&(cAliasExclu+"_PROTPN"),.f.))

                            RecLock("V9D",.f.)
                            V9D->V9D_ATIVO := "2"
                            V9D->(MsUnLock())

                        EndIf

                    ElseIf cEvtExcluido $ "R-2010|R-2020|R-2030|R-2040|R-2050|R-2055|R-2060|R-3010"

                        DbSelectArea("V0W")
                        V0W->(DbSetOrder(5))

                        If V0W->(DbSeek(xFilial("V0W") + (cAliasExclu)->&(cAliasExclu+"_PROTPN"),.f.))

                            RecLock("V0W",.f.)
                            V0W->V0W_ATIVO := "2"
                            V0W->(MsUnLock())

                        EndIf

                    EndIf

                EndIf

			Else
				lGravaOk := .F.
				cMsgRet := "Evento não encontrado para atualização do Status de exclusão."
			EndIf
		Next
	Else
		lGravaOk := .F.
		cMsgRet := "Evento não encontrado para atualização do Status de exclusão."
	EndIf
	RestArea( aArea ) 

Return( { lGravaOk, cMsgRet} )

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraEvtTot
GeraÃ§Ã£o dos eventos totalizadores (5001|5011) no retorno do 2010/2020/2030
@Return  Mensagem com status 
@author Victor Andrade
@since  17/05/2016
@version 1.0

/*///----------------------------------------------------------------
Static Function GeraEvtTot( cXmlTot as character, cLayout as character, cAliasTb as character, cFilErp as character, cRecibo as character, cRecAnt as character, cVsReinf as character, lJob as logical, cProtul as character )

	Local nX	  		as numeric
	Local cErrorXML 	as character
	Local cWarningXML 	as character
	Local cMsgRetorno	as character
	
	Default cXmlTot  := ""
	Default cLayout  := ""
	Default cFilErp	 := ""
	Default cAliasTb := "C1E"
	Default cRecAnt	 := ""
	Default lJob	 := .F.
	Default cProtul  := ""

	Private oXmlTot 	as object

	nX := 0
	oXmlTot := Nil
	cErrorXML := ""
	cWarningXML := ""
	cMsgRetorno := ""

	oXmlTot := XmlParser( cXmlTot,"", @cErrorXML, @cWarningXML ) //Parse XML pega somente o bloco do REINF, pois a tag possui o retorno do governo completo
	If Empty(cErrorXML) .And. oXmlTot <> Nil
		If cLayOut $ "R-2099" .And. TAFColumnPos( "V0F_VLRSUS" )
			dbSelectArea('V0C')
	    	V0C->(dbSetOrder(5))
			If V0C->(dbSeek(xFilial('V0C') + PadR(cProtul,TamSX3('V0C_PROTUL')[1]) + '1')) == .F.
				cMsgRetorno := grvTotFecha(oXmlTot,cFilErp,cLayout,cRecibo, cRecAnt, cVsReinf, lJob) + CRLF
			EndIf
			V0C->(dbCloseArea())
		Else
			If Type("oXmlTot:_REINF:_EVTTOTAL") <> "U" .And. !(cLayOut $ "R-2098")
				dbSelectArea('V0W')
	    		V0W->(dbSetOrder(5))
				If V0W->(dbSeek(xFilial('V0W') + PadR(cProtul,TamSX3('V0W_PROTUL')[1]) + '1')) == .F.
					cMsgRetorno := gravaTotalizador(oXmlTot:_REINF:_EVTTOTAL,cFilErp,cLayout,cRecibo, cRecAnt, cVsReinf, lJob) + CRLF
				EndIf
				V0W->(dbCloseArea())
			EndIf
		EndIf
	Else
		cMsgRetorno := cErrorXML
	EndIf

Return (cMsgRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraEvTot40
Geração dos eventos totalizadores (9005|9015) no retorno do R-4010, R-4020, R-4040 e R-4080
@Return  Mensagem com status 
@author  Rafael Leme / Denis Souza /Riquelmo
@since   12/12/2022
@version 1.0

/*///----------------------------------------------------------------
Static Function GeraEvTot40( cXmlTot as character, cLayout as character, cAliasTb as character, cFilErp as character, cRecibo as character, cRecAnt as character, cVsReinf as character, lJob as logical, cProtul as character )

	Local nX	  		as numeric
	Local cErrorXML 	as character
	Local cWarningXML 	as character
	Local cMsgRetorno	as character
	
	Default cXmlTot  := ""
	Default cLayout  := ""
	Default cFilErp	 := ""
	Default cAliasTb := "C1E"
	Default cRecAnt	 := ""
	Default lJob	 := .F.
	Default cProtul  := ""

	Private oXmlTot 	as object

	nX          := 0
	oXmlTot     := Nil
	cErrorXML   := ""
	cWarningXML := ""
	cMsgRetorno := ""

	oXmlTot := XmlParser( cXmlTot,"", @cErrorXML, @cWarningXML ) //Parse XML pega somente o bloco do REINF, pois a tag possui o retorno do governo completo

	If Empty(cErrorXML) .And. oXmlTot <> Nil
		If cLayOut $ "R-4099"
			dbSelectArea('V9F') //V9C_FILIAL+V9C_PROTUL+V9C_ATIVO
	    	V9F->(dbSetOrder(5))
			If V9F->(dbSeek(xFilial('V9F') + PadR(cProtul,TamSX3('V9F_PROTUL')[1]) + '1')) == .F.
				cMsgRetorno := grvTot4099(oXmlTot,cFilErp,cLayout,cRecibo, cRecAnt, cVsReinf, lJob) + CRLF
			EndIf
			V9F->(dbCloseArea())
		Else
			If Type("oXmlTot:_REINF:_EVTRET") <> "U"
				dbSelectArea('V9D')
				V9D->(dbSetOrder(5))
				If V9D->(dbSeek(xFilial('V9D') + PadR(cProtul,TamSX3('V9D_PROTUL')[1]) + '1')) == .F.
					cMsgRetorno := grvTot9005(oXmlTot:_REINF:_EVTRET,cFilErp,cLayout,cRecibo, cRecAnt, cVsReinf, lJob) + CRLF
				EndIf
				V9D->(dbCloseArea())
			EndIf
		EndIf
	Else
		cMsgRetorno := cErrorXML
	EndIf

Return (cMsgRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} gravaTotalizador
Grava evento totalizador utilizado a API de integraÃ§Ã£o TafPrepIntrava evento totalizador utilizado a API de integraÃ§Ã£o TafPrepInt

@author Evandro dos Santos Oliveira	
@since  19/08/2017
@version 1.0
/*///----------------------------------------------------------------
Static Function gravaTotalizador(oXmlTot,cFilErp,cLayout,cRecibo, cRecAnt, cVsReinf,lJob)

	Local cEvento		as char 
	Local cErro			as char
	Local cId			as char
	Local cPerApur		as char
	Local cProTPN		as char
	Local cSeq			as char 
	Local cVerAnt		as char
	Local dDtProcess	as date
	Local dDtRecepcao	as date
	Local lNewTot		as logical
	Local lVSup13		as logical
	Local nInfoTotal	as numeric
	Local nRegOcorrs	as numeric
	Local oModelV0X		as object
	Local oModelV0Y 	as object
	Local oModelV0Z 	as object
	Local oModelV6B		as object
	Local lIdeEstab     as Logical // tags de identificaÃ§Ã£o do estabelecimento -> REINF v 1.4.0 ( tpInsc e nrInsc )
	Local lReinf15		as Logical
	Local cHrProcess	as char
	Local cHrRecepcao	as char

	Private aInfo       as array
	Private oXmlInfoTot	as object

	Default cRecAnt := ""
	Default lJob 	:= .F.
	
	oModelV6B	:= Nil
	aInfo		:= {}
	cEvento		:= "I"
	cErro		:= ""
	cId			:= ""
	cPerApur	:= ""
	cProTPN		:= ""
	cSeq		:= "001"
	cVerAnt		:= ""
	dDtProcess	:= CTOD("  /  /    ")
	dDtRecepcao	:= CTOD("  /  /    ")
	cHrProcess	:= ""
	cHrRecepcao	:= ""
	lNewTot		:= TAFColumnPos("V0W_CRTOM")
	nRegOcorrs	:= 0
	if (lJob .And. (isInCallStack("PROC10_003") .or. isInCallStack("PROC10_004") ) .And. type("oModel501") == "U"); oModel501 := FWLoadModel("TAFA501"); endif
	oModelV0X 	:= oModel501:GetModel("MODEL_V0X")
	oModelV0Y 	:= oModel501:GetModel("MODEL_V0Y")
	oModelV0Z	:= oModel501:GetModel("MODEL_V0Z")
	lVSup13     := IIf( "1_03" $ AllTrim(cVsReinf), .F., .T. )
	lReinf15    := alltrim(StrTran( cVsReinf ,'_','')) >= '10500' .and. TAFAlsInDic("V5S")
	lIdeEstab   := IIf( TafColumnPos( "V0W_TPINSE" ) .and. TafColumnPos( "V0W_NRINSE" ), .T., .F. )
	oXmlInfoTot := oXmlTot
	cPerApur	:= SubStr(oXmlInfoTot:_ideEvento:_perApur:TEXT,6,2)+SubStr(oXmlInfoTot:_ideEvento:_perApur:TEXT,1,4)
	dDtProcess	:= StoD(SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,1,4)+SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,6,2)+SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,9,2))
	cHrProcess	:= SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,12,2)+SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,15,2)

	If Type("oXmlInfoTot:_infoRecEv:_DHRECEPCAO") <> "U"
		dDtRecepcao	:= StoD(SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,1,4)+SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,6,2)+SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,9,2))
		cHrRecepcao	:= SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,12,2)+SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,15,2)
	EndIf

	V0W->(DbSetOrder(5))
	If !Empty(cRecAnt) .And. V0W->(DbSeek(xFilial("V0W") + cRecAnt))
		FAltRegAnt('V0W', '2', .F.)
		cVerAnt := V0W->V0W_VERSAO
		cProTPN	:= cRecAnt
		cId 	:= V0W->V0W_ID
		cEvento := 'A'
	EndIf
 	oModel501:SetOperation(MODEL_OPERATION_INSERT)
	oModel501:Activate()
	oModel501:GetModel( 'MODEL_V0W' )
	oModel501:LoadValue('MODEL_V0W', "V0W_FILIAL"	, xFilial("V0W"))
	If !Empty(cId); oModel501:LoadValue('MODEL_V0W', "V0W_ID"	, cId); EndIf
	oModel501:LoadValue('MODEL_V0W', "V0W_VERSAO"	, xFunGetVer()) 
	oModel501:LoadValue('MODEL_V0W', "V0W_PERAPU"	, cPerApur )
	oModel501:LoadValue('MODEL_V0W', "V0W_CODRET"	, oXmlInfoTot:_ideRecRetorno:_ideStatus:_cdRetorno:TEXT)
	oModel501:LoadValue('MODEL_V0W', "V0W_DSCRET"	, oXmlInfoTot:_ideRecRetorno:_ideStatus:_descRetorno:TEXT)
	oModel501:LoadValue('MODEL_V0W', "V0W_DTPROC"	, dDtProcess)
	oModel501:LoadValue('MODEL_V0W', "V0W_HRPROC"	, cHrProcess )
	oModel501:LoadValue('MODEL_V0W', "V0W_TPEVEN"	, oXmlInfoTot:_infoRecEv:_tpEv:TEXT)
	oModel501:LoadValue('MODEL_V0W', "V0W_IDEVEN"	, oXmlInfoTot:_infoRecEv:_idEv:TEXT)
	oModel501:LoadValue('MODEL_V0W', "V0W_HASH"		, oXmlInfoTot:_infoRecEv:_hash:TEXT)
	//Reinf 2.1.2
	If TAFColumnPos("V0W_DTRECE")
		oModel501:LoadValue('MODEL_V0W', "V0W_DTRECE"	, dDtRecepcao )
		oModel501:LoadValue('MODEL_V0W', "V0W_HRRECE"	, cHrRecepcao )
	EndIf

	If Type("oXmlInfoTot:_infoTotal:_nrRecArqBase") <> "U"
		oModel501:LoadValue('MODEL_V0W', "V0W_NRRECB"	, oXmlInfoTot:_infoTotal:_nrRecArqBase:TEXT)
		oModel501:LoadValue('MODEL_V0W', "V0W_PROTUL"	, oXmlInfoTot:_infoTotal:_nrRecArqBase:TEXT)
	ElseIf Type("oXmlInfoTot:_infoRecEv:_nrRecArqBase") <> "U"
		oModel501:LoadValue('MODEL_V0W', "V0W_NRRECB"	, oXmlInfoTot:_infoRecEv:_nrRecArqBase:TEXT)
		oModel501:LoadValue('MODEL_V0W', "V0W_PROTUL"	, oXmlInfoTot:_infoRecEv:_nrRecArqBase:TEXT)
	EndIf

	oModel501:LoadValue('MODEL_V0W', "V0W_ATIVO"	, "1")
	oModel501:LoadValue('MODEL_V0W', "V0W_EVENTO"	, cEvento)
	oModel501:LoadValue('MODEL_V0W', "V0W_PROTPN"	, cProTPN)
	oModel501:LoadValue('MODEL_V0W', "V0W_VERANT"	, cVerAnt)
	If TAFColumnPos("V0W_LEIAUT"); oModel501:LoadValue('MODEL_V0W', "V0W_LEIAUT", AllTrim(cVsReinf)); EndIf
		
	If lVSup13 //Mantem o devido funcionamento na versao 1.4.0
		If lReinf15
			oModelV6B	:= oModel501:GetModel("MODEL_V6B")
		EndIf
		R1405001DT( cLayout, lNewTot, lIdeEstab, oModel501, oModelV0X, oModelV0Y, oModelV0Z, oModelV6B )
	Else //Mantem o devido funcionamento ate a versao 1.3.2
		If cLayout == "R-2010"
			oModel501:LoadValue('MODEL_V0W', "V0W_CNPJ10"	, oXmlInfoTot:_infoTotal:_RTom:_cnpjPrestador:TEXT)
			oModel501:LoadValue('MODEL_V0W', "V0W_VLTTBR"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RTom:_vlrTotalBaseRet:TEXT,",",".")))
			If ValType(oXmlInfoTot:_infoTotal:_RTom:_infoCrTom) == "A"
				aInfo := oXmlInfoTot:_infoTotal:_RTom:_infoCrTom
			Else 
				aInfo := aClone({oXmlInfoTot:_infoTotal:_RTom:_infoCrTom})
			EndIf
			For nInfoTotal := 1 to Len(aInfo)
				If lNewTot; oModel501:LoadValue('MODEL_V0W', "V0W_CRTOM", aInfo[nInfoTotal]:_CRTOM:TEXT ); EndIf
				If aInfo[nInfoTotal]:_CRTOM:TEXT == "116201"
					If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCRTom") <> "U"
						oModel501:LoadValue('MODEL_V0W', "V0W_VLTTRP", Val(StrTran(aInfo[nInfoTotal]:_vlrCRTom:TEXT,",",".")) )
					EndIf
					If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCRTomSusp") <> "U"
						oModel501:LoadValue('MODEL_V0W', "V0W_VLTTNP", Val(StrTran(aInfo[nInfoTotal]:_vlrCRTomSusp:TEXT,",",".")) )
					EndIf
				Else
					If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCRTom") <> "U"
						oModel501:LoadValue('MODEL_V0W', "V0W_VLTTRA", Val(StrTran(aInfo[nInfoTotal]:_vlrCRTom:TEXT,",",".")) )
					EndIf
					If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCRTomSusp") <> "U"
						oModel501:LoadValue('MODEL_V0W', "V0W_VLTTNA", Val(StrTran(aInfo[nInfoTotal]:_vlrCRTomSusp:TEXT,",",".")) )
					EndIf
				EndIf
			Next nInfoTotal
		ElseIf cLayout == "R-2020"
			oModel501:LoadValue('MODEL_V0W', "V0W_TPINST"	, oXmlInfoTot:_infoTotal:_RPrest:_tpInscTomador:TEXT )
			oModel501:LoadValue('MODEL_V0W', "V0W_NRINST"	, oXmlInfoTot:_infoTotal:_RPrest:_nrInscTomador:TEXT )
			oModel501:LoadValue('MODEL_V0W', "V0W_VLPTBR"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalBaseRet:TEXT,",",".")) )
			oModel501:LoadValue('MODEL_V0W', "V0W_VLPTRP"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalRetPrinc:TEXT,",",".")) )
			If Type("oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalRetAdic") <> "U"
				oModel501:LoadValue('MODEL_V0W', "V0W_VLPTRA"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalRetAdic:TEXT,",",".")) )
			EndIf
			If Type("oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalNRetPrinc") <> "U"
				oModel501:LoadValue('MODEL_V0W', "V0W_VLPTNP"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalNRetPrinc:TEXT,",",".")) )
			EndIf
			If Type("oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalNRetAdic") <> "U"
				oModel501:LoadValue('MODEL_V0W', "V0W_VLPTNA"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RPrest:_vlrTotalNRetAdic:TEXT,",",".")) )
			EndIf
		ElseIf cLayout == "R-2040"
			If ValType(oXmlInfoTot:_infoTotal:_RRecRepAD) == "A"
				aInfo := oXmlInfoTot:_infoTotal:_RRecRepAD
			Else
				aInfo := {oXmlInfoTot:_infoTotal:_RRecRepAD}
			EndIf
			For nInfoTotal := 1 to Len(aInfo)
				If nInfoTotal > 1; oModelV0Y:AddLine(); EndIf
				If lNewTot; oModel501:LoadValue('MODEL_V0Y', "V0Y_CRRECR", aInfo[nInfoTotal]:_CRRecRepAD:TEXT ); EndIf
				oModel501:LoadValue('MODEL_V0Y', "V0Y_CNPJAD"	, aInfo[nInfoTotal]:_cnpjAssocDesp:TEXT )
				oModel501:LoadValue('MODEL_V0Y', "V0Y_VLTREP"	, Val(StrTran(aInfo[nInfoTotal]:_vlrTotalRep:TEXT,",",".")) )
				oModel501:LoadValue('MODEL_V0Y', "V0Y_VLTRET"	, Val(StrTran(aInfo[nInfoTotal]:_vlrCrRecRepAD:TEXT,",",".")) )
				If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCrRecRepADSusp") <> "U"
					oModel501:LoadValue('MODEL_V0Y', "V0Y_VLTNRT"	, Val(StrTran(aInfo[nInfoTotal]:_vlrCrRecRepADSusp:TEXT,",",".")) )
				EndIf
			Next nInfoTotal
		ElseIf cLayout == "R-2050"
			If lNewTot
				If ValType(oXmlInfoTot:_infoTotal:_RComl) == "A"
					aInfo := oXmlInfoTot:_infoTotal:_RComl
				Else
					aInfo := {oXmlInfoTot:_infoTotal:_RComl}
				EndIf
				For nInfoTotal := 1 to Len(aInfo)
					If nInfoTotal > 1
						oModelV0X:AddLine()
						cSeq := Soma1(cSeq)
					EndIf
					oModel501:LoadValue('MODEL_V0X', "V0X_SEQUEN"	, cSeq )
					oModel501:LoadValue('MODEL_V0X', "V0X_CRCOML"	, aInfo[nInfoTotal]:_CRComl:TEXT )
					oModel501:LoadValue('MODEL_V0X', "V0X_VLCOML"	, Val(StrTran(aInfo[nInfoTotal]:_vlrCRComl:TEXT,",",".")) )
					If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCRComlSusp") <> "U"
						oModel501:LoadValue('MODEL_V0X', "V0X_VLSUSP"	, Val(StrTran(aInfo[nInfoTotal]:_vlrCRComlSusp:TEXT,",",".")) )
					EndIf
				Next nInfoTotal
			EndIf
		ElseIf cLayout == "R-2060"
			If ValType(oXmlInfoTot:_infoTotal:_RCPRB) == "A"
				aInfo := oXmlInfoTot:_infoTotal:_RCPRB
			Else
				aInfo := {oXmlInfoTot:_infoTotal:_RCPRB}
			EndIf
			For nInfoTotal := 1 to Len(aInfo)
				If nInfoTotal > 1; oModelV0Z:AddLine(); EndIf
				oModel501:LoadValue('MODEL_V0Z', "V0Z_CODREC"	, aInfo[nInfoTotal]:_CRCPRB:TEXT)
				oModel501:LoadValue('MODEL_V0Z', "V0Z_VLCPAT"	, Val(StrTran(aInfo[nInfoTotal]:_vlrCRCPRB:TEXT,",",".")) )
				If Type("aInfo["+cValToChar(nInfoTotal)+"]:_vlrCRComlSusp") <> "U"
					oModel501:LoadValue('MODEL_V0Z', "V0Z_VLCSUS"	, Val(StrTran(aInfo[nInfoTotal]:_vlrCRCPRBSusp:TEXT,",",".")) )
				EndIf
			Next nInfoTotal
		ElseIf cLayout == "R-3010"
			If lNewTot; oModel501:LoadValue('MODEL_V0W', "V0W_CRESPE", oXmlInfoTot:_infoTotal:_RRecEspetDesp:_CRRecEspetDesp:TEXT); EndIf
			oModel501:LoadValue('MODEL_V0W', "V0W_VLRCTT"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RRecEspetDesp:_vlrReceitaTotal:TEXT,",",".")) )
			oModel501:LoadValue('MODEL_V0W', "V0W_VLCPTT"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RRecEspetDesp:_vlrCRRecEspetDesp:TEXT,",",".")) )
			If Type("oXmlInfoTot:_infoTotal:_RRecEspetDesp:_vlrCRRecEspetDespSusp") <> "U"
				oModel501:LoadValue('MODEL_V0W', "V0W_VLCPST"	, Val(StrTran(oXmlInfoTot:_infoTotal:_RRecEspetDesp:_vlrCRRecEspetDespSusp:TEXT,",",".")) )
			EndIf
		EndIf
	Endif
	If oModel501:VldData()
		FwFormCommit( oModel501 )
	Else
		cErro := TafRetEMsg( oModel501 )
	EndIf
	oModel501:DeActivate()

Return (cErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} grvTotFecha
Grava evento totalizador utilizado a API de integraÃ§Ã£o TafPrepInt

@author Evandro dos Santos Oliveira	
@since  19/08/2017
@version 1.0
/*///----------------------------------------------------------------
Static Function grvTotFecha(oXmlTot,cFilErp,cLayout,cRecibo, cRecAnt, cVsReinf, lJob)

	Local aInfo			as array
	Local nLine			as numeric
	Local nLinCrTom		as numeric
	Local cErro			as char
	Local cEvento		as char 
	Local cId			as char
	Local cProTPN		as char 
	Local cVerAnt		as char
	Local cNrRecibo		as char
	Local dDtProcess	as date
	Local dDtRecepcao	as date
	Local lVSup13       as logical
	Local cHrProcess	as char
	Local cHrRecepcao	as char

	Private oXml		as object 
	Private oXmlInfoTot	as object

	Default cRecAnt		:= ""
	Default lJob		:= .F.

	aInfo		:= {}
	oXml		:= oXmlTot
	cErro		:= ""
	cEvento		:= "I"
	cId			:= ""
	cNrRecibo	:= ""
	cProTPN		:= ""
	cVerAnt		:= ""
	dDtProcess	:= CtoD("  /  /    ")
	dDtRecepcao := CtoD("  /  /    ")
	nLine		:= 0
	nLinCrTom	:= 0 
	cHrProcess	:= ""
	cHrRecepcao := ""

	cPerApur	:= SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_IDEEVENTO:_PERAPUR:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_IDEEVENTO:_PERAPUR:TEXT,1,4)
	dDtProcess	:= StoD(SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHPROCESS:TEXT,1,4)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHPROCESS:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHPROCESS:TEXT,9,2))
	cHrProcess	:= SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHPROCESS:TEXT,12,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHPROCESS:TEXT,15,2)
	lVSup13     := IIf( "1_03" $ AllTrim(cVsReinf), .F., .T. )
	
	//Tratamento feito pois a partir da versao 2.01.02 da reinf a tag nrRecArqBase é devolvida no grupo infoRecEv
	If Type ("oXml:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB:_NRRECARQBASE") <> "U"
		cNrRecibo := oXml:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB:_NRRECARQBASE:TEXT
	ElseIf Type ("oXml:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_NRRECARQBASE") <> "U"
		cNrRecibo := oXml:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_NRRECARQBASE:TEXT
	EndIf

	If Type("oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DTRECEPCAO") <> "U"
		dDtRecepcao	:= StoD(SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DTRECEPCAO:TEXT,1,4)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DTRECEPCAO:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DTRECEPCAO:TEXT,9,2))
		cHrRecepcao	:= SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DTRECEPCAO:TEXT,12,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DTRECEPCAO:TEXT,15,2)
	ElseIf Type("oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHRECEPCAO") <> "U"
		dDtRecepcao	:= StoD(SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHRECEPCAO:TEXT,1,4)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHRECEPCAO:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHRECEPCAO:TEXT,9,2))
		cHrRecepcao	:= SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHRECEPCAO:TEXT,12,2)+SubStr(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_DHRECEPCAO:TEXT,15,2)
	EndIf

	V0C->(DbSetOrder(2))
	If !Empty(cRecAnt) .And. V0C->(DbSeek(xFilial("V0C") + cPerApur))
		FAltRegAnt('V0C', '2', .F.)
		cVerAnt := V0C->V0C_VERSAO
		cProTPN	:= cRecAnt
		cId 	:= V0C->V0C_ID
		cEvento := 'A'
	Endif
	if lJob .And. ( isInCallStack("R2099_004") .Or. Upper(Alltrim(FunName())) == "RPC" ) .And. type("oModel497") == "U"
		oModel497 := FWLoadModel("TAFA497")
	endif
	oModel497:SetOperation(MODEL_OPERATION_INSERT)
	oModel497:Activate()
	oModel497:GetModel( 'MODEL_V0C' )
	oModel497:LoadValue('MODEL_V0C', "V0C_FILIAL"	, xFilial("V0C") )
	If !Empty(cId)
		oModel497:LoadValue('MODEL_V0C', "V0C_ID"	, cId )
	EndIf
	oModel497:LoadValue('MODEL_V0C', "V0C_VERSAO"	, xFunGetVer() )
	oModel497:LoadValue('MODEL_V0C', "V0C_PERAPU"	, cPerApur )
	oModel497:LoadValue('MODEL_V0C', "V0C_CODRET"	, oXmlTot:_REINF:_EVTTOTALCONTRIB:_IDERECRETORNO:_IDESTATUS:_CDRETORNO:TEXT )
	oModel497:LoadValue('MODEL_V0C', "V0C_DESCRE"	, oXmlTot:_REINF:_EVTTOTALCONTRIB:_IDERECRETORNO:_IDESTATUS:_DESCRETORNO:TEXT )
	oModel497:LoadValue('MODEL_V0C', "V0C_PROTEN"	, oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_NRPROTENTR:TEXT )
	oModel497:LoadValue('MODEL_V0C', "V0C_DTPROC"	, dDtProcess )
	oModel497:LoadValue('MODEL_V0C', "V0C_HRPROC"	, cHrProcess )
	oModel497:LoadValue('MODEL_V0C', "V0C_TPEVT"	, oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_TPEV:TEXT )
	oModel497:LoadValue('MODEL_V0C', "V0C_IDEVT"	, oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_IDEV:TEXT )
	oModel497:LoadValue('MODEL_V0C', "V0C_HASH"	    , oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFORECEV:_HASH:TEXT )
	oModel497:LoadValue('MODEL_V0C', "V0C_ATIVO"	, "1" )
	oModel497:LoadValue('MODEL_V0C', "V0C_EVENTO"	, cEvento )
	oModel497:LoadValue('MODEL_V0C', "V0C_PROTUL"	, AllTrim(cRecibo) )
	oModel497:LoadValue('MODEL_V0C', "V0C_PROTPN"	, cProTPN )
	oModel497:LoadValue('MODEL_V0C', "V0C_VERANT"	, cVerAnt )
	If TAFColumnPos("V0C_LEIAUT")
		oModel497:LoadValue('MODEL_V0C', "V0C_LEIAUT"	, AllTrim(cVsReinf) )
	EndIf
	//Reinf 2.1.2
	If TAFColumnPos("V0C_DTRECE")
		oModel497:LoadValue('MODEL_V0C', "V0C_DTRECE"	, dDtRecepcao )
		oModel497:LoadValue('MODEL_V0C', "V0C_HRRECE"	, cHrRecepcao )
	EndIf
	If Type("oXML:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB") <> "U"
		oXmlInfoTot := oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB
		If ValType(oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB) == "A"
			aInfo := oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB
		Else 
			aInfo := {oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB}
		EndIf
		For nLine := 1 To Len(aInfo)
			If nLine > 1; oModel497:GetModel('MODEL_V0E'):AddLine(); EndIf
			oModel497:GetModel( 'MODEL_V0E' )
			oModel497:LoadValue('MODEL_V0E', "V0E_NRREC"	, cNrRecibo )
			oModel497:LoadValue('MODEL_V0E', "V0E_INDEXI"	, oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB:_INDEXISTINFO:TEXT )
			if StrTran( Alltrim(cVsReinf),'_' ,'' ) >= "10501" .And. TafColumnPos( "V0E_IDDCTF" )
				If Type("oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB:_IDENTESCRITDCTF") <> "U"
					oModel497:LoadValue('MODEL_V0E', "V0E_IDDCTF", oXmlTot:_REINF:_EVTTOTALCONTRIB:_INFOTOTALCONTRIB:_IDENTESCRITDCTF:TEXT )
				EndIf
			endif
		Next nLine
	EndIf

	If Type("oXmlInfoTot:_RTOM") <> "U"
		If ValType(oXmlInfoTot:_RTOM) == "A"
			For nLine := 1 To Len(oXmlInfoTot:_RTOM)
				If nLine > 1
					oModel497:GetModel( "MODEL_V0F" ):lValid:= .T.
					oModel497:GetModel( "MODEL_V0F" ):AddLine()
				EndIf
				oModel497:GetModel( 'MODEL_V0F' )
				oModel497:LoadValue('MODEL_V0F', "V0F_CNPJPR"	, oXmlInfoTot:_RTOM[nLine]:_CNPJPRESTADOR:TEXT )
				if lVSup13 .and. TAFColumnPos( "V0F_CNO" )
					If Type( "oXmlInfoTot:_RTOM[" + cValToChar(nLine) + "]:_CNO" ) <> "U"
						oModel497:LoadValue( "MODEL_V0F", "V0F_CNO", oXmlInfoTot:_RTOM[nLine]:_CNO:TEXT )
					Endif
				EndIf
				oModel497:LoadValue('MODEL_V0F', "V0F_VLRBRE"	, Val(StrTran(oXmlInfoTot:_RTOM[nLine]:_VLRTOTALBASERET:TEXT,",",".")) )

				If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM") <> "U"
					If ValType(oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM) == "A"
						For nLinCrTom := 1 to Len(oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM)
							If nLinCrTom > 1 
								oModel497:GetModel( "MODEL_V0F" ):lValid := .T.
								oModel497:GetModel( "MODEL_V0F" ):AddLine()
								oModel497:GetModel( 'MODEL_V0F' )
								oModel497:LoadValue('MODEL_V0F', "V0F_CNPJPR"	, oXmlInfoTot:_RTOM[nLine]:_CNPJPRESTADOR:TEXT )
								oModel497:LoadValue('MODEL_V0F', "V0F_VLRBRE"	, Val(StrTran(oXmlInfoTot:_RTOM[nLine]:_VLRTOTALBASERET:TEXT,",",".")) )
							EndIf
							If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM["+cValToChar(nLinCrTom)+"]:_CRTOM") <> "U"
								oModel497:LoadValue('MODEL_V0F', "V0F_CRTOM"	, oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM[nLinCrTom]:_CRTOM:TEXT)
							EndIf
							If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM["+cValToChar(nLinCrTom)+"]:_VLRCRTOM") <> "U"
								oModel497:LoadValue('MODEL_V0F', "V0F_VLRTOM"	, Val(StrTran(oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM[nLinCrTom]:_VLRCRTOM:TEXT,",",".")) )
							EndIf
							If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM["+cValToChar(nLinCrTom)+"]:_VLRCRTOMSUSP") <> "U"
								oModel497:LoadValue('MODEL_V0F', "V0F_VLRSUS"	, Val(StrTran(oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM[nLinCrTom]:_VLRCRTOMSUSP:TEXT,",",".")) )
							EndIf
						Next nLinCrTom
					Else 				
						If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM:_CRTOM") <> "U"
							oModel497:LoadValue('MODEL_V0F', "V0F_CRTOM"	, oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM:_CRTOM:TEXT							)
						EndIf				
						If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM:_VLRCRTOM") <> "U"
							oModel497:LoadValue('MODEL_V0F', "V0F_VLRTOM"	, Val(StrTran(oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM:_VLRCRTOM:TEXT,",","."))	)
						EndIf 
						If Type("oXmlInfoTot:_RTOM["+cValToChar(nLine)+"]:_INFOCRTOM:_VLRCRTOMSUSP") <> "U"
							oModel497:LoadValue('MODEL_V0F', "V0F_VLRSUS"	, Val(StrTran(oXmlInfoTot:_RTOM[nLine]:_INFOCRTOM:_VLRCRTOMSUSP:TEXT,",",".")))
						EndIf
					EndIf 
				EndIf 
			Next nLine
		Else
			oModel497:GetModel( 'MODEL_V0F' )															
			oModel497:LoadValue('MODEL_V0F', "V0F_CNPJPR"	, oXmlInfoTot:_RTOM:_CNPJPRESTADOR:TEXT )
			if lVSup13 .and. TAFColumnPos( "V0F_CNO" )
				If Type( "oXmlInfoTot:_RTOM:_CNO" ) <> "U"
					oModel497:LoadValue( "MODEL_V0F", "V0F_CNO", oXmlInfoTot:_RTOM:_CNO:TEXT )
				Endif
			EndIf
			oModel497:LoadValue('MODEL_V0F', "V0F_VLRBRE"	, Val(StrTran(oXmlInfoTot:_RTOM:_VLRTOTALBASERET:TEXT,",",".")) )
			If Type("oXmlInfoTot:_RTOM:_INFOCRTOM") <> "U"
				If ValType(oXmlInfoTot:_RTOM:_INFOCRTOM) == "A"
					For nLinCrTom := 1 to Len(oXmlInfoTot:_RTOM:_INFOCRTOM)
						If nLinCrTom > 1
							oModel497:GetModel( "MODEL_V0F" ):lValid:= .T.
							oModel497:GetModel( "MODEL_V0F" ):AddLine()
							oModel497:GetModel( 'MODEL_V0F' )
							oModel497:LoadValue('MODEL_V0F', "V0F_CNPJPR"	, oXmlInfoTot:_RTOM:_CNPJPRESTADOR:TEXT )
							oModel497:LoadValue('MODEL_V0F', "V0F_VLRBRE"	, Val(StrTran(oXmlInfoTot:_RTOM:_VLRTOTALBASERET:TEXT,",",".")) )
						EndIf
						If Type("oXmlInfoTot:_RTOM:_INFOCRTOM["+cValToChar(nLinCrTom)+"]:_CRTOM") <> "U"
							oModel497:LoadValue('MODEL_V0F', "V0F_CRTOM"	, oXmlInfoTot:_RTOM:_INFOCRTOM[nLinCrTom]:_CRTOM:TEXT )
						EndIf
						If Type("oXmlInfoTot:_RTOM:_INFOCRTOM["+cValToChar(nLinCrTom)+"]:_VLRCRTOM") <> "U"
							oModel497:LoadValue('MODEL_V0F', "V0F_VLRTOM"	, Val(StrTran(oXmlInfoTot:_RTOM:_INFOCRTOM[nLinCrTom]:_VLRCRTOM:TEXT,",",".")) )
						EndIf
						If Type("oXmlInfoTot:_RTOM:_INFOCRTOM["+cValToChar(nLinCrTom)+"]:_VLRCRTOMSUSP") <> "U"
							oModel497:LoadValue('MODEL_V0F', "V0F_VLRSUS"	, Val(StrTran(oXmlInfoTot:_RTOM:_INFOCRTOM[nLinCrTom]:_VLRCRTOMSUSP:TEXT,",",".")) )
						EndIf
					Next nLinCrTom
				Else
					If Type("oXmlInfoTot:_RTOM:_INFOCRTOM:_CRTOM") <> "U"
						oModel497:LoadValue('MODEL_V0F', "V0F_CRTOM"	, oXmlInfoTot:_RTOM:_INFOCRTOM:_CRTOM:TEXT )
					EndIf
					If Type("oXmlInfoTot:_RTOM:_INFOCRTOM:_VLRCRTOM") <> "U"
						oModel497:LoadValue('MODEL_V0F', "V0F_VLRTOM"	, Val(StrTran(oXmlInfoTot:_RTOM:_INFOCRTOM:_VLRCRTOM:TEXT,",",".")) )
					EndIf
					If Type("oXmlInfoTot:_RTOM:_INFOCRTOM:_VLRCRTOMSUSP") <> "U"
						oModel497:LoadValue('MODEL_V0F', "V0F_VLRSUS"	, Val(StrTran(oXmlInfoTot:_RTOM:_INFOCRTOM:_VLRCRTOMSUSP:TEXT,",",".")) )
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If Type("oXmlInfoTot:_RPREST") <> "U"
		If ValType(oXmlInfoTot:_RPREST) == "A"
			For nLine := 1 To Len(oXmlInfoTot:_RPREST)
				If nLine > 1
					oModel497:GetModel( "MODEL_V0G" ):lValid:= .T.
					oModel497:GetModel( "MODEL_V0G" ):AddLine()
				EndIf
				oModel497:GetModel( 'MODEL_V0G' )
				oModel497:LoadValue('MODEL_V0G', "V0G_TPINST"	, oXmlInfoTot:_RPREST[nLine]:_TPINSCTOMADOR:TEXT )
				oModel497:LoadValue('MODEL_V0G', "V0G_NRINST"	, oXmlInfoTot:_RPREST[nLine]:_NRINSCTOMADOR:TEXT )
				oModel497:LoadValue('MODEL_V0G', "V0G_VLRBRE"	, Val(StrTran(oXmlInfoTot:_RPREST[nLine]:_VLRTOTALBASERET:TEXT,",",".")) )
				oModel497:LoadValue('MODEL_V0G', "V0G_VLRPRI"	, Val(StrTran(oXmlInfoTot:_RPREST[nLine]:_VLRTOTALRETPRINC:TEXT,",",".")) )
				If Type("oXmlInfoTot:_RPREST["+cValToChar(nLine)+"]:_VLRTOTALRETADIC") <> "U"
					oModel497:LoadValue('MODEL_V0G', "V0G_VLRADI"	, Val(StrTran(oXmlInfoTot:_RPREST[nLine]:_VLRTOTALRETADIC:TEXT,",",".")) )
				EndIf
				If Type("oXmlInfoTot:_RPREST["+cValToChar(nLine)+"]:_VLRTOTALNRETPRINC") <> "U"
					oModel497:LoadValue('MODEL_V0G', "V0G_VLRNPR"	, Val(StrTran(oXmlInfoTot:_RPREST[nLine]:_VLRTOTALNRETPRINC:TEXT,",",".")) )
				EndIf
				If Type("oXmlInfoTot:_RPREST["+cValToChar(nLine)+"]:_VLRTOTALNRETADIC") <> "U"
					oModel497:LoadValue('MODEL_V0G', "V0G_VLRNAD"	, Val(StrTran(oXmlInfoTot:_RPREST[nLine]:_VLRTOTALNRETADIC:TEXT,",",".")) )
				EndIf
			Next nLine
		Else
			oModel497:GetModel( 'MODEL_V0G' )
			oModel497:LoadValue('MODEL_V0G', "V0G_TPINST"	, oXmlInfoTot:_RPREST:_TPINSCTOMADOR:TEXT )
			oModel497:LoadValue('MODEL_V0G', "V0G_NRINST"	, oXmlInfoTot:_RPREST:_NRINSCTOMADOR:TEXT )
			oModel497:LoadValue('MODEL_V0G', "V0G_VLRBRE"	, Val(StrTran(oXmlInfoTot:_RPREST:_VLRTOTALBASERET:TEXT,",",".")) )
			oModel497:LoadValue('MODEL_V0G', "V0G_VLRPRI"	, Val(StrTran(oXmlInfoTot:_RPREST:_VLRTOTALRETPRINC:TEXT,",",".")) )
			If Type("oXmlInfoTot:_RPREST:_VLRTOTALRETADIC") <> "U"
				oModel497:LoadValue('MODEL_V0G', "V0G_VLRADI"	, Val(StrTran(oXmlInfoTot:_RPREST:_VLRTOTALRETADIC:TEXT,",",".")) )
			EndIf
			If Type("oXmlInfoTot:_RPREST:_VLRTOTALNRETPRINC") <> "U"
				oModel497:LoadValue('MODEL_V0G', "V0G_VLRNPR"	, Val(StrTran(oXmlInfoTot:_RPREST:_VLRTOTALNRETPRINC:TEXT,",",".")) )
			EndIf
			If Type("oXmlInfoTot:_RPREST:_VLRTOTALNRETADIC") <> "U"
				oModel497:LoadValue('MODEL_V0G', "V0G_VLRNAD"	, Val(StrTran(oXmlInfoTot:_RPREST:_VLRTOTALNRETADIC:TEXT,",",".")) )
			EndIf
		EndIf
	EndIf

	If Type("oXmlInfoTot:_RRECREPAD") <> "U"
		If ValType(oXmlInfoTot:_RRECREPAD) == "A"
			For nLine := 1 To Len(oXmlInfoTot:_RRECREPAD)
				If nLine > 1
					oModel497:GetModel( "MODEL_V0H" ):lValid:= .T.
					oModel497:GetModel( "MODEL_V0H" ):AddLine()
				EndIf
				oModel497:GetModel( 'MODEL_V0H' )
				oModel497:LoadValue('MODEL_V0H', "V0H_CNPJAD"	, oXmlInfoTot:_RRECREPAD[nLine]:_CNPJASSOCDESP:TEXT )
				oModel497:LoadValue('MODEL_V0H', "V0H_VLRREP"	, Val(StrTran(oXmlInfoTot:_RRECREPAD[nLine]:_VLRTOTALREP:TEXT,",",".")) )
				If TAFColumnPos("V0H_CRRECR"); oModel497:LoadValue('MODEL_V0H', "V0H_CRRECR", oXmlInfoTot:_RRECREPAD[nLine]:_CRRecRepAD:TEXT ); EndIf
				oModel497:LoadValue('MODEL_V0H', "V0H_VLRRET"	, Val(StrTran(oXmlInfoTot:_RRECREPAD[nLine]:_VLRCRRECREPAD:TEXT,",",".")) )
				If Type("oXmlInfoTot:_RRECREPAD["+cValToChar(nLine)+"]:_VLRCRRECREPADSUSP") <> "U"
					oModel497:LoadValue('MODEL_V0H', "V0H_VLRNRE"	, Val(StrTran(oXmlInfoTot:_RRECREPAD[nLine]:_VLRCRRECREPADSUSP:TEXT,",",".")) )
				EndIf
			Next nLine
		Else
			oModel497:GetModel( 'MODEL_V0H' )
			oModel497:LoadValue('MODEL_V0H', "V0H_FILIAL"	, xFilial("V0H") )
			If !lVSup13 // Campos abaixo foram retirados a partir da versÃ£o 1.4
				oModel497:LoadValue('MODEL_V0H', "V0H_CNPJAD"	, oXmlInfoTot:_RRECREPAD:_CNPJASSOCDESP:TEXT )
				oModel497:LoadValue('MODEL_V0H', "V0H_VLRREP"	, Val(StrTran(oXmlInfoTot:_RRECREPAD:_VLRTOTALREP:TEXT,",",".")) )
			Endif
			If TAFColumnPos("V0H_CRRECR"); oModel497:LoadValue('MODEL_V0H', "V0H_CRRECR", oXmlInfoTot:_RRECREPAD:_CRRecRepAD:TEXT ); EndIf
			oModel497:LoadValue('MODEL_V0H', "V0H_VLRRET"	, Val(StrTran(oXmlInfoTot:_RRECREPAD:_VLRCRRECREPAD:TEXT,",",".")) )
			If Type("oXmlInfoTot:_RRECREPAD:_VLRCRRECREPADSUSP") <> "U"
				oModel497:LoadValue('MODEL_V0H', "V0H_VLRNRE"	, Val(StrTran(oXmlInfoTot:_RRECREPAD:_VLRCRRECREPADSUSP:TEXT,",",".")) )
			EndIf
		EndIf
	EndIf

	If Type("oXmlInfoTot:_RCOML") <> "U"
		If ValType(oXmlInfoTot:_RCOML) == "A"
			For nLine := 1 To Len(oXmlInfoTot:_RCOML)
				If nLine > 1
					oModel497:GetModel( "MODEL_V0I" ):lValid:= .T.
					oModel497:GetModel( "MODEL_V0I" ):AddLine()
				EndIf
				oModel497:GetModel( 'MODEL_V0I' )
				oModel497:LoadValue('MODEL_V0I', "V0I_FILIAL"	, xFilial("V0I") )
				oModel497:LoadValue('MODEL_V0I', "V0I_SEQUEN"	, StrZero(nLine,3) )
				oModel497:LoadValue('MODEL_V0I', "V0I_CRCOML"	, oXmlInfoTot:_RCOML[nLine]:_CRCOML:TEXT )
				oModel497:LoadValue('MODEL_V0I', "V0I_VRCOML"	, Val(StrTran(oXmlInfoTot:_RCOML[nLine]:_VLRCRCOML:TEXT,",",".")) )
				If Type("oXmlInfoTot:_RCOML["+cValToChar(nLine)+"]:_VLRCRCOMLSUSP") <> "U"
					oModel497:LoadValue('MODEL_V0I', "V0I_VRCOMS"	, Val(StrTran(oXmlInfoTot:_RCOML[nLine]:_VLRCRCOMLSUSP:TEXT,",",".")) )
				EndIf
			Next nLine
		Else
			oModel497:GetModel( 'MODEL_V0I' )
			oModel497:LoadValue('MODEL_V0I', "V0I_FILIAL"	, xFilial("V0I") )
			oModel497:LoadValue('MODEL_V0I', "V0I_SEQUEN"	, StrZero(nLine,3) )
			oModel497:LoadValue('MODEL_V0I', "V0I_CRCOML"	, oXmlInfoTot:_RCOML:_CRCOML:TEXT )
			oModel497:LoadValue('MODEL_V0I', "V0I_VRCOML"	, Val(StrTran(oXmlInfoTot:_RCOML:_VLRCRCOML:TEXT,",",".")) )
			If Type("oXmlInfoTot:_RCOML:_VLRCRCOMLSUSP") <> "U"
				oModel497:LoadValue('MODEL_V0I', "V0I_VRCOMS"	, Val(StrTran(oXmlInfoTot:_RCOML:_VLRCRCOMLSUSP:TEXT,",",".")) )
			EndIf
		EndIf
	EndIf

	If Type("oXmlInfoTot:_RCPRB") <> "U"
		If ValType(oXmlInfoTot:_RCPRB) == "A"
			For nLine := 1 To Len(oXmlInfoTot:_RCPRB)
				If nLine > 1
					oModel497:GetModel( "MODEL_V0J" ):lValid:= .T.
					oModel497:GetModel( "MODEL_V0J" ):AddLine()
				EndIf
				oModel497:GetModel( 'MODEL_V0J' )
				oModel497:LoadValue('MODEL_V0J', "V0J_FILIAL"	, xFilial("V0J") )
				oModel497:LoadValue('MODEL_V0J', "V0J_CODREC"	, oXmlInfoTot:_RCPRB[nLine]:_CRCPRB:TEXT )
				oModel497:LoadValue('MODEL_V0J', "V0J_VLRCPT"	, Val(StrTran(oXmlInfoTot:_RCPRB[nLine]:_VLRCRCPRB:TEXT,",",".")) )
				If Type("oXmlInfoTot:_RCPRB["+cValToChar(nLine)+"]:_VLRCRCPRBSUSP") <> "U"
					oModel497:LoadValue('MODEL_V0J', "V0J_VLRCPS"	, Val(StrTran(oXmlInfoTot:_RCPRB[nLine]:_VLRCRCPRBSUSP:TEXT,",",".")) )
				EndIf
			Next nLine
		Else
			oModel497:GetModel( 'MODEL_V0J' )
			oModel497:LoadValue('MODEL_V0J', "V0J_FILIAL"	, xFilial("V0J") )
			oModel497:LoadValue('MODEL_V0J', "V0J_CODREC"	, oXmlInfoTot:_RCPRB:_CRCPRB:TEXT )
			oModel497:LoadValue('MODEL_V0J', "V0J_VLRCPT"	, Val(StrTran(oXmlInfoTot:_RCPRB:_VLRCRCPRB:TEXT,",",".")) )
			If Type("oXmlInfoTot:_RCPRB:_VLRCRCPRBSUSP") <> "U"
				oModel497:LoadValue('MODEL_V0J', "V0J_VLRCPS"	, Val(StrTran(oXmlInfoTot:_RCPRB:_VLRCRCPRBSUSP:TEXT,",",".")) )
			EndIf
		EndIf
	EndIf

	If Type("oXmlInfoTot:_RAQUIS") <> "U" .and. TAFAlsInDic( "V6C" )
		If ValType(oXmlInfoTot:_RAQUIS) == "A"
			For nLine := 1 To Len(oXmlInfoTot:_RAQUIS)
				If nLine > 1
					oModel497:GetModel( "MODEL_V6C" ):lValid:= .T.
					oModel497:GetModel( "MODEL_V6C" ):AddLine()
				EndIf
				oModel497:GetModel( 'MODEL_V6C' )
				oModel497:LoadValue('MODEL_V6C', "V6C_FILIAL"	, xFilial( "V6C" ) )
				oModel497:LoadValue('MODEL_V6C', "V6C_CODREC"	, oXmlInfoTot:_RAQUIS[nLine]:_CRAQUIS:TEXT )
				oModel497:LoadValue('MODEL_V6C', "V6C_VRAQUI"	, Val(StrTran(oXmlInfoTot:_RAQUIS[nLine]:_VLRCRAQUIS:TEXT,",",".")) )

				If Type("oXmlInfoTot:_RAQUIS["+cValToChar(nLine)+"]:_VLRCRAQUISSUSP") <> "U"
					oModel497:LoadValue('MODEL_V6C', "V6C_VLSUSP"	, Val(StrTran(oXmlInfoTot:_RAQUIS[nLine]:_VLRCRAQUISSUSP:TEXT,",",".")) )
				EndIf
			Next nLine
		Else
			oModel497:GetModel( 'MODEL_V6C' )
			oModel497:LoadValue('MODEL_V6C', "V6C_FILIAL"	, xFilial( "V6C" ) )
			oModel497:LoadValue('MODEL_V6C', "V6C_CODREC"	, oXmlInfoTot:_RAQUIS:_CRAQUIS:TEXT )
			oModel497:LoadValue('MODEL_V6C', "V6C_VRAQUI"	, Val(StrTran(oXmlInfoTot:_RAQUIS:_VLRCRAQUIS:TEXT,",",".")) )

			If Type("oXmlInfoTot:_RAQUIS:_VLRCRAQUISSUSP") <> "U"
				oModel497:LoadValue('MODEL_V6C', "V6C_VLSUSP"	, Val(StrTran(oXmlInfoTot:_RAQUIS:_VLRCRAQUISSUSP:TEXT,",",".")) )
			EndIf
		EndIf
	EndIf

	If oModel497:VldData()
		FwFormCommit( oModel497 )
	Else
		cErro := TafRetEMsg( oModel497 )
	EndIf
	oModel497:DeActivate()

Return (cErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} limpaRegT0X
Limpa inconsistÃªnca da tabela T0X.

@Return cIdAux - Chave da inconsistÃªncia a ser excluida 

@author Evandro dos Santos Oliveira	
@since  15/01/2018
@version 1.0

/*///----------------------------------------------------------------
Static Function limpaRegT0X(cIdAux,lJob)
	Default lJob := .F.
	If TcSqlExec("DELETE FROM " + RetSqlName("T0X") + " WHERE T0X_IDCHVE = '" + cIdAux + "' AND (T0X_USER = '" + cUserName + "' OR T0X_USER = '__Schedule')") < 0
		If lJob
			TAFConOut("Erro na limpeza das inconsistências: " + TCSQLError(), 2, .T., "PROC10" )
		Else
			MsgStop(TCSQLError(),"Erro na limpeza das inconsistências")
		EndIf
	EndIf
Return

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
	Local aParam as array
	aParam := {"P","TAFESXTSS",,"SM0",} //#Tipo R para relatorio P para processo #Pergunte do relatorio, caso nao use passar ParamDef #Alias #Array de ordens #Titulo
Return ( aParam )

//-------------------------------------------------------------------
/*/{Protheus.doc} R145001Det
Reinf 1.4.0 Grava Detalhe Do Totalizador 5001
@Return
@author Denis Souza
@since  04/10/2018
@version 1.0
/*///----------------------------------------------------------------

Static Function R1405001DT( cLay, lTom, lEstab, oMdl, oMdlV0X,  oMdlV0Y, oMdlV0Z, oMdlV6B )

Local cSeq	  as char
Local cTpInsc as char
Local nInfTT  as numeric

Default oMdlV6B := Nil
    	
nInfTT 	:= 0
cSeq	:= "001"
cTpInsc := " "

If lEstab
	If Type( "oXmlInfoTot:_infoTotal:_ideEstab" ) <> "U"
		If Type( "oXmlInfoTot:_infoTotal:_ideEstab:_tpInsc" ) <> "U"
			cTpInsc := oXmlInfoTot:_infoTotal:_ideEstab:_tpInsc:TEXT
			if Valtype( cTpInsc ) == "C" .And. ( cTpInsc == "1" .Or. cTpInsc == "4" )
				oMdl:LoadValue( "MODEL_V0W", "V0W_TPINSE", cTpInsc )
			elseif Valtype( cTpInsc ) == "C" .And. cTpInsc == "0"
				oMdl:LoadValue( "MODEL_V0W", "V0W_TPINSE", " " )
			endif
		endif
		If Type( "oXmlInfoTot:_infoTotal:_ideEstab:_nrInsc" ) <> "U"
			oMdl:LoadValue( "MODEL_V0W", "V0W_NRINSE", oXmlInfoTot:_infoTotal:_ideEstab:_nrInsc:TEXT )
		endif
	EndIf
EndIf
If cLay == "R-2010"
	oMdl:LoadValue( 'MODEL_V0W', "V0W_CNPJ10"	, oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_cnpjPrestador:TEXT )
	If TafColumnPos( "V0W_CNOEST" )
		If Type( "oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_CNO" ) <> "U"
			oMdl:LoadValue( "MODEL_V0W", "V0W_CNOEST", oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_CNO:TEXT )
		EndIf
	EndIf
	oMdl:LoadValue( 'MODEL_V0W', "V0W_VLTTBR"	, Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_vlrTotalBaseRet:TEXT,",",".")) )
	If ValType( oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_infoCrTom ) == "A"
		aInfo := oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_infoCrTom
	Else
		aInfo := aClone( { oXmlInfoTot:_infoTotal:_ideEstab:_RTom:_infoCrTom } )
	EndIf
	For nInfTT := 1 to Len(aInfo)
		If lTom; oMdl:LoadValue('MODEL_V0W', "V0W_CRTOM", aInfo[nInfTT]:_CRTOM:TEXT); EndIf
		If aInfo[nInfTT]:_CRTOM:TEXT == "116201"
			If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRTom") <> "U"
				oMdl:LoadValue('MODEL_V0W', "V0W_VLTTRP", Val(StrTran(aInfo[nInfTT]:_vlrCRTom:TEXT,",",".")) )
			EndIf
			If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRTomSusp") <> "U"
				oMdl:LoadValue('MODEL_V0W', "V0W_VLTTNP", Val(StrTran(aInfo[nInfTT]:_vlrCRTomSusp:TEXT,",",".")) )
			EndIf
		Else
			If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRTom") <> "U"
				oMdl:LoadValue('MODEL_V0W', "V0W_VLTTRA", Val(StrTran(aInfo[nInfTT]:_vlrCRTom:TEXT,",",".")) )
			EndIf
			If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRTomSusp") <> "U"
				oMdl:LoadValue('MODEL_V0W', "V0W_VLTTNA", Val(StrTran(aInfo[nInfTT]:_vlrCRTomSusp:TEXT,",",".")) )
			EndIf
		EndIf
	Next nInfTT
ElseIf cLay == "R-2020"
	oMdl:LoadValue('MODEL_V0W', "V0W_TPINST"	, oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_tpInscTomador:TEXT )
	oMdl:LoadValue('MODEL_V0W', "V0W_NRINST"	, oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_nrInscTomador:TEXT )
	oMdl:LoadValue('MODEL_V0W', "V0W_VLPTBR"	, Val( StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalBaseRet:TEXT,",",".")) )
	oMdl:LoadValue('MODEL_V0W', "V0W_VLPTRP"	, Val( StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalRetPrinc:TEXT,",",".")) )
	If Type("oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalRetAdic") <> "U"
		oMdl:LoadValue('MODEL_V0W', "V0W_VLPTRA", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalRetAdic:TEXT,",",".")) )
	EndIf
	If Type("oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalNRetPrinc") <> "U"
		oMdl:LoadValue('MODEL_V0W', "V0W_VLPTNP", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalNRetPrinc:TEXT,",",".")) )
	EndIf
	If Type("oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalNRetAdic") <> "U"
		oMdl:LoadValue('MODEL_V0W', "V0W_VLPTNA", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RPrest:_vlrTotalNRetAdic:TEXT,",",".")) )
	EndIf
ElseIf cLay == "R-2040"
	If ValType( oXmlInfoTot:_infoTotal:_ideEstab:_RRecRepAD ) == "A"
		aInfo := oXmlInfoTot:_infoTotal:_ideEstab:_RRecRepAD
	Else
		aInfo := { oXmlInfoTot:_infoTotal:_ideEstab:_RRecRepAD }
	EndIf
	For nInfTT := 1 to Len(aInfo)
		If nInfTT > 1; oMdlV0Y:AddLine(); EndIf
		oMdl:LoadValue('MODEL_V0Y', "V0Y_CNPJAD"	, aInfo[nInfTT]:_cnpjAssocDesp:TEXT)
		oMdl:LoadValue('MODEL_V0Y', "V0Y_VLTREP"	, Val(StrTran(aInfo[nInfTT]:_vlrTotalRep:TEXT,",",".")) )
		If lTom; oMdl:LoadValue('MODEL_V0Y', "V0Y_CRRECR", aInfo[nInfTT]:_CRRecRepAD:TEXT ); EndIf
		oMdl:LoadValue('MODEL_V0Y', "V0Y_VLTRET"	, Val(StrTran(aInfo[nInfTT]:_vlrCrRecRepAD:TEXT,",",".")) )
		If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCrRecRepADSusp") <> "U"
			oMdl:LoadValue('MODEL_V0Y', "V0Y_VLTNRT", Val(StrTran(aInfo[nInfTT]:_vlrCrRecRepADSusp:TEXT,",",".")) )
		EndIf
	Next nInfTT
ElseIf cLay == "R-2050"
	If lTom
		If XmlChildEx(oXmlInfoTot:_infoTotal:_ideEstab,"_RCOML") != NIL
			If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_RComl) == "A"
				aInfo := oXmlInfoTot:_infoTotal:_ideEstab:_RComl
			Else
				aInfo := { oXmlInfoTot:_infoTotal:_ideEstab:_RComl }
			EndIf
		EndIf	
		For nInfTT := 1 to Len(aInfo)
			If nInfTT > 1 
				oMdlV0X:AddLine()
				cSeq := Soma1(cSeq)
			EndIf
			oMdl:LoadValue('MODEL_V0X', "V0X_SEQUEN"	, cSeq )
			oMdl:LoadValue('MODEL_V0X', "V0X_CRCOML"	, aInfo[nInfTT]:_CRComl:TEXT )
			oMdl:LoadValue('MODEL_V0X', "V0X_VLCOML"	, Val(StrTran(aInfo[nInfTT]:_vlrCRComl:TEXT,",",".")) )
			If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRComlSusp") <> "U"
				oMdl:LoadValue('MODEL_V0X', "V0X_VLSUSP", Val(StrTran(aInfo[nInfTT]:_vlrCRComlSusp:TEXT,",",".")) )
			EndIf
		Next nInfTT
	EndIf
ElseIf !Empty(oMdlV6B) .and. cLay == "R-2055"
	If lTom
		If XmlChildEx(oXmlInfoTot:_infoTotal,"_IDEESTAB") != Nil;
			.And. XmlChildEx(oXmlInfoTot:_infoTotal:_ideEstab,"_RAQUIS")!= Nil 
			If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_RAquis) == "A"
				aInfo := oXmlInfoTot:_infoTotal:_ideEstab:_RAquis	
			Else
				aInfo := { oXmlInfoTot:_infoTotal:_ideEstab:_RAquis }
			EndIf
		Endif
		For nInfTT := 1 to Len(aInfo)
			If nInfTT > 1 
				oMdlV6B:AddLine()
			EndIf
			oMdl:LoadValue('MODEL_V6B', "V6B_CRAQUI"	, aInfo[nInfTT]:_CRAquis:TEXT )
			oMdl:LoadValue('MODEL_V6B', "V6B_VLRCRA"	, Val(StrTran(aInfo[nInfTT]:_vlrCRAquis:TEXT,",",".")) )
			If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRAquisSusp") <> "U"
				oMdl:LoadValue('MODEL_V6B', "V6B_VLRCRS", Val(StrTran(aInfo[nInfTT]:_vlrCRAquisSusp:TEXT,",",".")) )
			EndIf
		Next nInfTT
	EndIf	
ElseIf cLay == "R-2060"
	If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_RCPRB) == "A"
		aInfo := oXmlInfoTot:_infoTotal:_ideEstab:_RCPRB
	Else
		aInfo := { oXmlInfoTot:_infoTotal:_ideEstab:_RCPRB }
	EndIf
	For nInfTT := 1 to Len(aInfo)
		If nInfTT > 1; oMdlV0Z:AddLine(); EndIf
		oMdl:LoadValue('MODEL_V0Z', "V0Z_CODREC"	, aInfo[nInfTT]:_CRCPRB:TEXT )
		oMdl:LoadValue('MODEL_V0Z', "V0Z_VLCPAT"	, Val(StrTran(aInfo[nInfTT]:_vlrCRCPRB:TEXT,",",".")) )
		If Type("aInfo["+cValToChar(nInfTT)+"]:_vlrCRComlSusp") <> "U"
			oMdl:LoadValue('MODEL_V0Z', "V0Z_VLCSUS", Val(StrTran(aInfo[nInfTT]:_vlrCRCPRBSusp:TEXT,",",".")) )
		EndIf
	Next nInfTT
ElseIf cLay == "R-3010"
	If lTom; oMdl:LoadValue('MODEL_V0W', "V0W_CRESPE", oXmlInfoTot:_infoTotal:_ideEstab:_RRecEspetDesp:_CRRecEspetDesp:TEXT ); EndIf
	oMdl:LoadValue('MODEL_V0W', "V0W_VLRCTT"	, Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RRecEspetDesp:_vlrReceitaTotal:TEXT,",",".")) )
	oMdl:LoadValue('MODEL_V0W', "V0W_VLCPTT"	, Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RRecEspetDesp:_vlrCRRecEspetDesp:TEXT,",",".")) )
	If Type("oXmlInfoTot:_infoTotal:_RRecEspetDesp:_vlrCRRecEspetDespSusp") <> "U"
		oMdl:LoadValue('MODEL_V0W', "V0W_VLCPST", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_RRecEspetDesp:_vlrCRRecEspetDespSusp:TEXT,",",".")) )
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} grvTot4099
Grava evento totalizador

@author Denis Souza / Riquelmo
@since  07/12/2022
@version 1.0
/*///----------------------------------------------------------------
Static Function grvTot4099(oXmlTot as object, cFilErp as character, cLayout as character, cRecibo as character, cRecAnt as character, cVsReinf as character, lJob as logical) as character

Local aInfo			as array
Local aTotAlias		as array
Local nLinMen		as numeric
Local nLinQui		as numeric
Local nLinDec		as numeric
Local nLinSem		as numeric
Local nLinDia		as numeric
Local nLinCRMen		as numeric
Local nLinCRQui		as numeric
Local nLinCRDec		as numeric
Local nLinCRSem		as numeric
Local nLinCRDia		as numeric
Local cErro			as char
Local cEvento		as char 
Local cProTPN		as char 
Local cVerAnt		as char
Local cNrRecibo		as char
Local dDtProcess	as date
Local dDtRecepcao	as date
Local cHrProcess	as char
Local cHrRecepcao	as char
Local cFechRet		as char

Private oXml		as object 
Private oXmlInfoTot	as object
Private oMdlMen  	as object
Private oMdlQui  	as object
Private oMdlDec  	as object
Private oMdlSem  	as object
Private oMdlDia  	as object

Default cRecAnt		:= ""
Default lJob		:= .F.

aInfo		:= {}
aTotAlias	:= {"V9Q", "V9R"}
oXml		:= oXmlTot
cErro		:= ""
cEvento		:= "I"
cNrRecibo	:= ""
cProTPN		:= ""
cVerAnt		:= ""
dDtProcess	:= CtoD("  /  /    ")
dDtRecepcao	:= CtoD("  /  /    ")
nLinMen		:= 0
nLinQui		:= 0
nLinDec		:= 0
nLinSem		:= 0
nLinDia		:= 0
nLinCRMen	:= 0	
nLinCRQui	:= 0	
nLinCRDec	:= 0	
nLinCRSem	:= 0	
nLinCRDia	:= 0	
cHrProcess	:= ""
cHrRecepcao := ""
cFechRet	:= ""

cPerApur	:= SubStr(oXmlTot:_REINF:_EVTRETCONS:_IDEEVENTO:_PERAPUR:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_IDEEVENTO:_PERAPUR:TEXT,1,4)

dDtProcess	:= StoD(SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHPROCESS:TEXT,1,4)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHPROCESS:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHPROCESS:TEXT,9,2))

cHrProcess	:= SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHPROCESS:TEXT,12,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHPROCESS:TEXT,15,2)

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHRECEPCAO") <> "U"
	dDtRecepcao	:= StoD(SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHRECEPCAO:TEXT,1,4)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHRECEPCAO:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHRECEPCAO:TEXT,9,2))
	cHrRecepcao	:= SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHRECEPCAO:TEXT,12,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DHRECEPCAO:TEXT,15,2)
Elseif Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DTRECEPCAO") <> "U"
	dDtRecepcao	:= StoD(SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DTRECEPCAO:TEXT,1,4)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DTRECEPCAO:TEXT,6,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DTRECEPCAO:TEXT,9,2))
	cHrRecepcao	:= SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DTRECEPCAO:TEXT,12,2)+SubStr(oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_DTRECEPCAO:TEXT,15,2)
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_FECHRET") <> "U"
	cFechRet := oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_FECHRET:TEXT
EndIf
If Type("oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR:_NRRECARQBASE") <> "U"
	cNrRecibo := oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR:_NRRECARQBASE:TEXT
Elseif Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_NRRECARQBASE") <> "U"
	cNrRecibo := oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_NRRECARQBASE:TEXT
EndIf

oMdlMen := Nil
oMdlQui := Nil
oMdlDec := Nil
oMdlSem := Nil
oMdlDia := Nil

//Apos a reabertura ser protocoloda, o registro ja foi inativado. Ver funcao EstornaEvTot40.
//Portanto a nova inclusao do totalizador, deverá ser como alteração.
V9F->(DbSetOrder(2)) //V9F_FILIAL+V9F_PERAPU+V9F_CODRET+V9F_ATIVO
If V9F->(DbSeek(xFilial("V9F") + cPerApur) )
	cEvento := 'A'
Endif

if type("oModel606") == "U" 
	oModel606 := FWLoadModel("TAFA606") //Coberto pelo CT PROC10_005
endif

oModel606:SetOperation(MODEL_OPERATION_INSERT)
oModel606:Activate()
oModel606:GetModel( 'MODEL_V9F' )
oModel606:LoadValue('MODEL_V9F', "V9F_FILIAL"	, xFilial("V9F") )
oModel606:LoadValue('MODEL_V9F', "V9F_VERSAO"	, xFunGetVer() )
oModel606:LoadValue('MODEL_V9F', "V9F_PERAPU"	, cPerApur )

If Type("oXmlTot:_REINF:_EVTRETCONS:_IDERECRETORNO:_IDESTATUS:_CDRETORNO") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_CODRET"	, oXmlTot:_REINF:_EVTRETCONS:_IDERECRETORNO:_IDESTATUS:_CDRETORNO:TEXT )
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_IDECONTRI:_TPINSC") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_TPINSC"	, oXmlTot:_REINF:_EVTRETCONS:_IDECONTRI:_TPINSC:TEXT )
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_IDECONTRI:_NRINSC") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_NRINSC"	, oXmlTot:_REINF:_EVTRETCONS:_IDECONTRI:_NRINSC:TEXT )
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_IDERECRETORNO:_IDESTATUS:_DESCRETORNO") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_DSCRET"	, oXmlTot:_REINF:_EVTRETCONS:_IDERECRETORNO:_IDESTATUS:_DESCRETORNO:TEXT ) //V9F_DSCRET = campo memo?
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_NRPROTLOTE") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_PROTEN"	, oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_NRPROTLOTE:TEXT )
EndIf

oModel606:LoadValue('MODEL_V9F', "V9F_DTPROC"	, dDtProcess )
oModel606:LoadValue('MODEL_V9F', "V9F_HRPROC"	, cHrProcess )
If TafColumnPos("V9F_DTRECE")
	oModel606:LoadValue('MODEL_V9F', "V9F_DTRECE"	, dDtRecepcao )
	oModel606:LoadValue('MODEL_V9F', "V9F_HRRECE"	, cHrRecepcao )
	oModel606:LoadValue('MODEL_V9F', "V9F_FECHRE"	, cFechRet )
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_TPEV") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_TPEVEN"	, oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_TPEV:TEXT )
EndIf
If Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_IDEV") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_IDEVEN"	, oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_IDEV:TEXT )
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_HASH") <> "U"	
	oModel606:LoadValue('MODEL_V9F', "V9F_HASH"	    , oXmlTot:_REINF:_EVTRETCONS:_INFORECEV:_HASH:TEXT )
EndIf 

oModel606:LoadValue('MODEL_V9F', "V9F_ATIVO"	, "1" )
oModel606:LoadValue('MODEL_V9F', "V9F_EVENTO"	, cEvento )
oModel606:LoadValue('MODEL_V9F', "V9F_PROTUL"	, AllTrim(cRecibo) )
oModel606:LoadValue('MODEL_V9F', "V9F_NRRECB"	, cNrRecibo )

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR:_INDEXISTINFO") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_INDTRI"	, oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR:_INDEXISTINFO:TEXT )
EndIf

If Type("oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR:_IDENTESCRITDCTF") <> "U"
	oModel606:LoadValue('MODEL_V9F', "V9F_INDDCT"	, oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR:_IDENTESCRITDCTF:TEXT )
EndIf 

oModel606:LoadValue('MODEL_V9F', "V9F_PROTPN"	, cProTPN )
oModel606:LoadValue('MODEL_V9F', "V9F_VERANT"	, cVerAnt )
oModel606:LoadValue('MODEL_V9F', "V9F_LEIAUT"	, AllTrim(cVsReinf) )


If Type("oXML:_REINF:_EVTRETCONS:_INFOCR_CNR") <> "U"
	oXmlInfoTot := oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR
	If ValType(oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR) == "A"
		aInfo := oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR
	Else 
		aInfo := {oXmlTot:_REINF:_EVTRETCONS:_INFOCR_CNR}
	EndIf
	If Len(aInfo) > 0	

		oMdlMen := oModel606:GetModel( "MODEL_V9Q_MENSAL"    )
		oMdlQui := oModel606:GetModel( "MODEL_V9Q_QUINZENAL" )
		oMdlDec := oModel606:GetModel( "MODEL_V9Q_DECENDIAL" )
		oMdlSem := oModel606:GetModel( "MODEL_V9Q_SEMANAL"   )
		oMdlDia := oModel606:GetModel( "MODEL_V9Q_DIARIO"    )

		//totApurMen 1=Mensal
		If Type("oXmlInfoTot:_TOTAPURMEN") <> "U"
			if ValType(oXmlInfoTot:_TOTAPURMEN) == "A"
				for nLinMen := 1 to Len(oXmlInfoTot:_TOTAPURMEN)
					GrvApuPer(nLinMen, "1", aTotAlias[1])
				next 
			else
				GrvApuPer(0, "1", aTotAlias[1])
			endif	
		EndIf 

		//totApurQui 2=Quinzenal
		If Type("oXmlInfoTot:_TOTAPURQUI") <> "U"
			if ValType(oXmlInfoTot:_TOTAPURQUI) == "A"
				for nLinQui := 1 to Len(oXmlInfoTot:_TOTAPURQUI)
					GrvApuPer(nLinQui, "2", aTotAlias[1])
				next 
			else
				GrvApuPer(0, "2", aTotAlias[1])
			endif	
		EndIf 

		//totApurDec 3=Decendial
		If Type("oXmlInfoTot:_TOTAPURDEC") <> "U"
			if ValType(oXmlInfoTot:_TOTAPURDEC) == "A"
				for nLinDec := 1 to Len(oXmlInfoTot:_TOTAPURDEC)
					GrvApuPer(nLinDec, "3", aTotAlias[1])
				next 
			else
				GrvApuPer(0, "3", aTotAlias[1])
			endif
		EndIf 
		
		//totApurSem 4=Semanal
		if Type("oXmlInfoTot:_TOTAPURSEM") <> "U"
			if ValType(oXmlInfoTot:_TOTAPURSEM) == "A"
				for nLinSem := 1 to Len(oXmlInfoTot:_TOTAPURSEM)
					GrvApuPer(nLinSem, "4", aTotAlias[1])
				next 
			else
				GrvApuPer(0, "4", aTotAlias[1])
			endif
		endif 

		//totApurDia 5=Diário
		if Type("oXmlInfoTot:_TOTAPURDIA") <> "U"
			if ValType(oXmlInfoTot:_TOTAPURDIA) == "A"
				for nLinDia := 1 to Len(oXmlInfoTot:_TOTAPURDIA)
					GrvApuPer(nLinDia, "5", aTotAlias[1])
				next
			else
				GrvApuPer(0, "5", aTotAlias[1])
			endif	
		endif 

	EndIf
EndIf

If Type("oXML:_REINF:_EVTRETCONS:_INFOTOTALCR") <> "U"
	oXmlInfoTot := oXmlTot:_REINF:_EVTRETCONS:_INFOTOTALCR
	If ValType(oXmlTot:_REINF:_EVTRETCONS:_INFOTOTALCR) == "A"
		aInfo := oXmlTot:_REINF:_EVTRETCONS:_INFOTOTALCR
	Else 
		aInfo := {oXmlTot:_REINF:_EVTRETCONS:_INFOTOTALCR}
	EndIf
	If Len(aInfo) > 0
	
		oMdlMen := oModel606:GetModel( "MODEL_V9R_MENSAL" )
		oMdlQui := oModel606:GetModel( "MODEL_V9R_QUINZENAL" )
		oMdlDec := oModel606:GetModel( "MODEL_V9R_DECENDIAL" )
		oMdlSem := oModel606:GetModel( "MODEL_V9R_SEMANAL" )
		oMdlDia := oModel606:GetModel( "MODEL_V9R_DIARIO" )

		//totApurMen 1=Mensal
		If Type("oXmlInfoTot:_TOTAPURMEN") <> "U"
			If ValType(oXmlInfoTot:_TOTAPURMEN) == "A"
				For nLinCRMen := 1 to Len(oXmlInfoTot:_TOTAPURMEN)
					GrvApuPer(nLinCRMen, "1", aTotAlias[2])
				
				Next nLinCRMen
			Else
				GrvApuPer(0, "1", aTotAlias[2])	
			EndIf
		EndIf 

		//totApurQui 2=Quinzenal
		If Type("oXmlInfoTot:_TOTAPURQUI") <> "U"
			If ValType(oXmlInfoTot:_TOTAPURQUI) == "A"
				For nLinCRQui := 1 to Len(oXmlInfoTot:_TOTAPURQUI)
					GrvApuPer(nLinCRQui, "2", aTotAlias[2])								
				Next nLinCRQui
			Else
				GrvApuPer(0, "2", aTotAlias[2])
			EndIf
		EndIf

		//totApurDec 3=Decendial
		If Type("oXmlInfoTot:_TOTAPURDEC") <> "U"
			If ValType(oXmlInfoTot:_TOTAPURDEC) == "A"
				For nLinCRDec := 1 to Len(oXmlInfoTot:_TOTAPURDEC)
					GrvApuPer(nLinCRDec, "3", aTotAlias[2])						
				Next nLinCRDec
			Else
				GrvApuPer(0, "3", aTotAlias[2])
			EndIf
		EndIf 

		//totApurSem 4=Semanal
		If Type("oXmlInfoTot:_TOTAPURSEM") <> "U"   
			If ValType(oXmlInfoTot:_TOTAPURSEM) == "A" 
				For nLinCRSem := 1 to Len(oXmlInfoTot:_TOTAPURSEM)
					GrvApuPer(nLinCRSem, "4", aTotAlias[2])
				Next nLinCRSem 
			Else
				GrvApuPer(0, "4", aTotAlias[2])
			EndIf
		EndIf 

		//totApurDia 5=Diário
		If Type("oXmlInfoTot:_TOTAPURDIA") <> "U"  
			If ValType(oXmlInfoTot:_TOTAPURDIA) == "A"
				For nLinCRDia := 1 to Len(oXmlInfoTot:_TOTAPURDIA)
					GrvApuPer(nLinCRDia, "5", aTotAlias[2])
				Next nLinCRDia
			Else
				GrvApuPer(0, "5", aTotAlias[2])
			EndIf
		EndIf		
	EndIf 
EndIf
If oModel606:VldData()
	FwFormCommit( oModel606 )
Else
	cErro := TafRetEMsg( oModel606 )
EndIf

oModel606:DeActivate()

Return (cErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} EstornaEvTot40
Estorna totalizador quando autorizado uma reabertura.
Se a reabertura for protocolado, estorna o totalizador R-9015

@author Denis Souza / Riquelmo
@since  12/12/2022
@version 1.0
/*///----------------------------------------------------------------
Static Function EstornaEvTot40(cPerApur)

Local aArea As Array

Default cPerApur := ''

aArea := GetArea()

dbSelectArea("V9F")
V9F->(DbSetOrder(2)) //V9F_FILIAL+V9F_PERAPU+V9F_CODRET+V9F_ATIVO
If V9F->(DbSeek(xFilial("V9F") + cPerApur ) )
	FAltRegAnt('V9F', '2', .F.)
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Status2098
Estorna totalizador quando autorizado uma reabertura.
Se a reabertura for protocolado, estorna o totalizador R-9011

@author Rafael Leme
@since  26/03/2024
@version 1.0
/*///----------------------------------------------------------------
Static Function Status2098(cPerApur)

Local aArea As Array

Default cPerApur := ''

aArea := GetArea()

dbSelectArea("V0C")
V0C->(DbSetOrder(2)) //V0C_FILIAL+V0C_PERAPU+V0C_CODRET+V0C_ATIVO                                                                                                                      
If V0C->(DbSeek(xFilial("V0C") + cPerApur ) )
	FAltRegAnt('V0C', '2', .F.)
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} grvTot9005
Grava evento totalizador R-9005 -  Retorno dos eventos R-4010, R-4020, R-4040 e R-4080.

@author Rafael de Paula Leme
@since  07/12/2022
@version 1.0
/*///----------------------------------------------------------------
Static Function grvTot9005(oXmlTot, cFilErp, cLayout, cRecibo, cRecAnt, cVsReinf, lJob)

	Local cEvento		as Character
	Local cErro			as Character
	Local cId			as Character
	Local cPerApur		as Character
	Local cProTPN		as Character
	Local cSeq			as Character 
	Local cVerAnt		as Character
	Local dDtProcess	as Date
	Local dDtRecepcao	as Date
	Local nX            as Numeric
	Local oModelV9G 	as Object
	Local cHrProcess	as char
	Local cHrRecepcao	as char
	
	Private aInfo       as Array
	Private oXmlInfoTot	as Object

	Default cRecAnt := ""
	Default lJob 	:= .F.

	oModelV9G	:= Nil
	aInfo		:= {}
	cEvento		:= "I"
	cErro		:= ""
	cId			:= ""
	cPerApur	:= ""
	cProTPN		:= ""
	cSeq		:= "001"
	cVerAnt		:= ""
	dDtProcess	:= CTOD("  /  /    ")
	dDtRecepcao	:= CTOD("  /  /    ")
	cHrProcess	:= ""
	cHrRecepcao	:= ""
	nX := 0

	If lJob  .And. oModel604 == Nil 
		oModel604 := FWLoadModel("TAFA604")
	Endif

	oXmlInfoTot := oXmlTot
	cPerApur	:= SubStr(oXmlInfoTot:_ideEvento:_perApur:TEXT,6,2)+SubStr(oXmlInfoTot:_ideEvento:_perApur:TEXT,1,4)
	dDtProcess	:= StoD(SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,1,4)+SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,6,2)+SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,9,2))
	cHrProcess	:= SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,12,2)+SubStr(oXmlInfoTot:_infoRecEv:_dhProcess:TEXT,15,2)

	If Type("oXmlInfoTot:_infoRecEv:_DHRECEPCAO") <> "U"
		dDtRecepcao	:= StoD(SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,1,4)+SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,6,2)+SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,9,2))
		cHrRecepcao	:= SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,12,2)+SubStr(oXmlInfoTot:_infoRecEv:_DHRECEPCAO:TEXT,15,2)
	EndIf

	V9D->(DbSetOrder(5))
	If !Empty(cRecAnt) .And. V9D->(DbSeek(xFilial("V9D") + cRecAnt))
		FAltRegAnt('V9D', '2', .F.)
		cVerAnt := V9D->V9D_VERSAO
		cProTPN	:= cRecAnt
		cId 	:= V9D->V9D_ID
		cEvento := 'A'
	EndIf
 	
	oModel604:SetOperation(MODEL_OPERATION_INSERT)
	oModel604:Activate()
	oModel604:GetModel('MODEL_V9D')
 	
	oModel604:LoadValue('MODEL_V9D', "V9D_FILIAL", xFilial("V9D"))
	If !Empty(cId)
		oModel604:LoadValue('MODEL_V9D', "V9D_ID", cId)
	EndIf
	oModel604:LoadValue('MODEL_V9D', "V9D_VERSAO", xFunGetVer())
	oModel604:LoadValue('MODEL_V9D', "V9D_VERANT", cVerAnt)
	oModel604:LoadValue('MODEL_V9D', "V9D_PROTPN", cProTPN)
	oModel604:LoadValue('MODEL_V9D', "V9D_EVENTO", cEvento)
	oModel604:LoadValue('MODEL_V9D', "V9D_ATIVO" , "1")
	oModel604:LoadValue('MODEL_V9D', "V9D_LEIAUT", AllTrim(cVsReinf))
	oModel604:LoadValue('MODEL_V9D', "V9D_PERAPU", cPerApur )
	oModel604:LoadValue('MODEL_V9D', "V9D_DTPROC", dDtProcess)
	oModel604:LoadValue('MODEL_V9D', "V9D_HRPROC", SubStr(Time(),1,2)+SubStr(Time(),4,2))

	oModel604:LoadValue('MODEL_V9D', "V9D_TPINSC", oXmlInfoTot:_ideContri:_tpInsc:TEXT )
	oModel604:LoadValue('MODEL_V9D', "V9D_NRINSC", oXmlInfoTot:_ideContri:_nrInsc:TEXT )
	oModel604:LoadValue('MODEL_V9D', "V9D_CODRET", oXmlInfoTot:_ideRecRetorno:_ideStatus:_cdRetorno:TEXT)
	oModel604:LoadValue('MODEL_V9D', "V9D_DSCRET", oXmlInfoTot:_ideRecRetorno:_ideStatus:_descRetorno:TEXT)
	
	oModel604:LoadValue('MODEL_V9D', "V9D_TPEVEN", oXmlInfoTot:_infoRecEv:_tpEv:TEXT)
	oModel604:LoadValue('MODEL_V9D', "V9D_IDEVEN", oXmlInfoTot:_infoRecEv:_idEv:TEXT)
	oModel604:LoadValue('MODEL_V9D', "V9D_HASH"  , oXmlInfoTot:_infoRecEv:_hash:TEXT)

	//Tratamento feito pois a partir da versao 2.01.02 da reinf a tag nrRecArqBase é devolvida no grupo infoRecEv
	If Type("oXmlInfoTot:_infoRecEv:_nrRecArqBase") <> "U"
		oModel604:LoadValue('MODEL_V9D', "V9D_PROTUL", oXmlInfoTot:_infoRecEv:_nrRecArqBase:TEXT)
		oModel604:LoadValue('MODEL_V9D', "V9D_NRRECB", oXmlInfoTot:_infoRecEv:_nrRecArqBase:TEXT)
	ElseIf Type("oXmlInfoTot:_infoTotal:_nrRecArqBase") <> "U"
		oModel604:LoadValue('MODEL_V9D', "V9D_PROTUL", oXmlInfoTot:_infoTotal:_nrRecArqBase:TEXT)
		oModel604:LoadValue('MODEL_V9D', "V9D_NRRECB", oXmlInfoTot:_infoTotal:_nrRecArqBase:TEXT)
	EndIf
	//Reinf 2.1.2
	If TAFColumnPos("V9D_DTRECE")
		oModel604:LoadValue('MODEL_V9D', "V9D_DTRECE"	, dDtRecepcao )
		oModel604:LoadValue('MODEL_V9D', "V9D_HRRECE"	, cHrRecepcao )
	EndIf

	//TRIBUTOS EVENTO R-9005 (V9G)
	If Type("oXmlInfoTot:_infoTotal") <> "U"
		If Type("oXmlInfoTot:_infoTotal:_ideEstab") <> "U"
			oModel604:LoadValue('MODEL_V9D', "V9D_TPINSE", oXmlInfoTot:_infoTotal:_ideEstab:_tpInsc:TEXT)
			oModel604:LoadValue('MODEL_V9D', "V9D_NRINSE", oXmlInfoTot:_infoTotal:_ideEstab:_nrInsc:TEXT)
			
			If Type("oXmlInfoTot:_infoTotal:_ideEstab:_nrInscBenef") <> "U"
				oModel604:LoadValue('MODEL_V9D', "V9D_NRINSB", oXmlInfoTot:_infoTotal:_ideEstab:_nrInscBenef:TEXT)
			EndIf

			//Tag ideEvtAdic adicionada a partir da versão 2.01.02 da reinf.
			If TafColumnPos("V9D_EVADIC") .And. Type("oXmlInfoTot:_infoTotal:_ideEstab:_ideEvtAdic") <> "U"
				oModel604:LoadValue('MODEL_V9D', "V9D_EVADIC", oXmlInfoTot:_infoTotal:_ideEstab:_ideEvtAdic:TEXT)
			EndIf

			//Tributos apuração mensal
			If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen") <> "U"
				oModel604:GetModel('MODEL_V9G_MENSAL')
				If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen) == "A"
					oModelV9G := oModel604:GetModel('MODEL_V9G_MENSAL')
					For nX := 1 to Len(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen)
						If nX > 1
							oModelV9G:AddLine()
						EndIf
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_FILIAL" , xFilial("V9G"))
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_ID"     , cId)
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VERSAO" , xFunGetVer())
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_TPPER"  , "1")
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_CRMen:TEXT)
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_vlrBaseCRMen:TEXT,",",".")))
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[" + cValToChar(nX) + "]:_vlrBaseCRMenSusp") <> "U"
							oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_vlrBaseCRMenSusp:TEXT,",",".")))
						EndIf
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_natRend:TEXT)
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[" + cValToChar(nX) + "]:_totApurTribMen") <> "U"
							oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_totApurTribMen:_vlrCRMenInf:TEXT,",",".")))
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[" + cValToChar(nX) + "]:_totApurTribMen:_vlrCRMenCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_totApurTribMen:_vlrCRMenCalc:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[" + cValToChar(nX) + "]:_totApurTribMen:_vlrCRMenSuspInf") <> "U"
								oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_totApurTribMen:_vlrCRMenSuspInf:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[" + cValToChar(nX) + "]:_totApurTribMen:_vlrCRMenSuspCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen[nX]:_totApurTribMen:_vlrCRMenSuspCalc:TEXT,",",".")))
							EndIf
						EndIf
					Next nX
				ElseIf ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen) == "O"
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_FILIAL" , xFilial("V9G"))
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_ID"     , cId)
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VERSAO" , xFunGetVer())
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_TPPER"  , "1")
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_CRMen:TEXT)
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_vlrBaseCRMen:TEXT,",",".")))
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_vlrBaseCRMenSusp") <> "U"
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_vlrBaseCRMenSusp:TEXT,",",".")))
					EndIf
					oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_natRend:TEXT)
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen") <> "U"
						oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenInf:TEXT,",",".")))
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenCalc:TEXT,",",".")))
						EndIf
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenSuspInf") <> "U"
							oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenSuspInf:TEXT,",",".")))
						EndIf
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenSuspCalc") <> "U"	
							oModel604:LoadValue('MODEL_V9G_MENSAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurMen:_totApurTribMen:_vlrCRMenSuspCalc:TEXT,",",".")))
						EndIf
					EndIf
				EndIf
			EndIf
			//Tributos apuração quinzenal
			If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui") <> "U"
				oModel604:GetModel('MODEL_V9G_QUINZENAL')
				If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui) == "A"
					oModelV9G := oModel604:GetModel('MODEL_V9G_QUINZENAL')
					For nX := 1 to Len(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui)
						If nX > 1
							oModelV9G:AddLine()
						EndIf
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_FILIAL" , xFilial("V9G"))
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_ID"     , cId)
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VERSAO" , xFunGetVer())
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_TPPER"  , "2")
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_perApurQui:TEXT)
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_CRQui:TEXT)
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_vlrBaseCRQui:TEXT,",",".")))
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[" + cValToChar(nX) + "]:_vlrBaseCRQuiSusp") <> "U"
							oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_vlrBaseCRQuiSusp:TEXT,",",".")))
						EndIf
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_natRend:TEXT)
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[" + cValToChar(nX) + "]:_totApurTribQui") <> "U"
							oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_totApurTribQui:_vlrCRQuiInf:TEXT,",",".")))
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[" + cValToChar(nX) + "]:_totApurTribQui:_vlrCRQuiCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_totApurTribQui:_vlrCRQuiCalc:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[" + cValToChar(nX) + "]:_totApurTribQui:_vlrCRQuiSuspInf") <> "U"
								oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_totApurTribQui:_vlrCRQuiSuspInf:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[" + cValToChar(nX) + "]:_totApurTribQui:_vlrCRQuiSuspCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui[nX]:_totApurTribQui:_vlrCRQuiSuspCalc:TEXT,",",".")))
							EndIf
						EndIf
					Next nX
				ElseIf ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui) == "O"
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_FILIAL" , xFilial("V9G"))
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_ID"     , cId)
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VERSAO" , xFunGetVer())
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_TPPER"  , "2")
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_perApurQui:TEXT)
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_CRQui:TEXT)
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_vlrBaseCRQui:TEXT,",",".")))
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_vlrBaseCRQuiSusp") <> "U"
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_vlrBaseCRQuiSusp:TEXT,",",".")))
					EndIf
					oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_natRend:TEXT)
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui") <> "U"
						oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiInf:TEXT,",",".")))
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiCalc:TEXT,",",".")))
						EndIf
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiSuspInf") <> "U"
							oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiSuspInf:TEXT,",",".")))
						EndIf
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiSuspCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_QUINZENAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurQui:_totApurTribQui:_vlrCRQuiSuspCalc:TEXT,",",".")))
						EndIf
					EndIf
				EndIf
			EndIf
			//Tributos apuração decendial
			If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec") <> "U"
				oModel604:GetModel('MODEL_V9G_DECENDIAL')
				If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec) == "A"
					oModelV9G := oModel604:GetModel('MODEL_V9G_DECENDIAL')
					For nX := 1 to Len(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec)
						If nX > 1
							oModelV9G:AddLine()
						EndIf
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_FILIAL" , xFilial("V9G"))
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_ID"     , cId)
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VERSAO" , xFunGetVer())
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_TPPER"  , "3")
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_perApurDec:TEXT)
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_CRDec:TEXT)
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_vlrBaseCRDec:TEXT,",",".")))
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[" + cValToChar(nX) + "]:_vlrBaseCRDecSusp") <> "U"
							oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_vlrBaseCRDecSusp:TEXT,",",".")))
						EndIf
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_natRend:TEXT)
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[" + cValToChar(nX) + "]:_totApurTribDec") <> "U"
							oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_totApurTribDec:_vlrCRDecInf:TEXT,",",".")))
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[" + cValToChar(nX) + "]:_totApurTribDec:_vlrCRDecCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_totApurTribDec:_vlrCRDecCalc:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[" + cValToChar(nX) + "]:_totApurTribDec:_vlrCRDecSuspInf") <> "U"
								oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_totApurTribDec:_vlrCRDecSuspInf:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[" + cValToChar(nX) + "]:_totApurTribDec:_vlrCRDecSuspCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec[nX]:_totApurTribDec:_vlrCRDecSuspCalc:TEXT,",",".")))
							EndIf
						EndIf
					Next nX
				ElseIf ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec) == "O"
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_FILIAL" , xFilial("V9G"))
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_ID"     , cId)
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VERSAO" , xFunGetVer())
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_TPPER"  , "3")
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_CRDec:TEXT)
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_perApurDec:TEXT)
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_vlrBaseCRDec:TEXT,",",".")))
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_vlrBaseCRDecSusp") <> "U"
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_vlrBaseCRDecSusp:TEXT,",",".")))
					EndIf
					oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_natRend:TEXT)
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec") <> "U"
						oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecInf:TEXT,",",".")))			
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecCalc:TEXT,",",".")))
						EndIf
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecSuspInf") <> "U"
							oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecSuspInf:TEXT,",",".")))
						EndIf
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecSuspCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_DECENDIAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDec:_totApurTribDec:_vlrCRDecSuspCalc:TEXT,",",".")))
						EndIf
					EndIf
				EndIf
			EndIf
			//Tributos apuração semanal
			If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem") <> "U"
				oModel604:GetModel('MODEL_V9G_SEMANAL')
				If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem) == "A"
					oModelV9G := oModel604:GetModel('MODEL_V9G_SEMANAL')
					For nX := 1 to Len(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem)
						If nX > 1
							oModelV9G:AddLine()
						EndIf
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_FILIAL" , xFilial("V9G"))
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_ID"     , cId)
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VERSAO" , xFunGetVer())
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_TPPER"  , "4")
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_perApurSem:TEXT)
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_CRSem:TEXT)
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_vlrBaseCRSem:TEXT,",",".")))
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[" + cValToChar(nX) + "]:_vlrBaseCRSemSusp") <> "U"
							oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_vlrBaseCRSemSusp:TEXT,",",".")))
						EndIf
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_natRend:TEXT)
						If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[" + cValToChar(nX) + "]:_totApurTribSem") <> "U"
							oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_totApurTribSem:_vlrCRSemInf:TEXT,",",".")))
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[" + cValToChar(nX) + "]:_totApurTribSem:_vlrCRSemCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_totApurTribSem:_vlrCRSemCalc:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[" + cValToChar(nX) + "]:_totApurTribSem:_vlrCRSemSuspInf") <> "U"
								oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_totApurTribSem:_vlrCRSemSuspInf:TEXT,",",".")))
							EndIf
							If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[" + cValToChar(nX) + "]:_totApurTribSem:_vlrCRSemSuspCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem[nX]:_totApurTribSem:_vlrCRSemSuspCalc:TEXT,",",".")))
							EndIf
						EndIf
					Next nX
				ElseIf ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem) == "O"
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_FILIAL" , xFilial("V9G"))
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_ID"     , cId)
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VERSAO" , xFunGetVer())
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_TPPER"  , "4")
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_perApurSem:TEXT)
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_CRSem:TEXT)
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_vlrBaseCRSem:TEXT,",",".")))
					If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_vlrBaseCRSemSusp") <> "U"
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_vlrBaseCRSemSusp:TEXT,",",".")))
					EndIf
					oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_natRend:TEXT)
					If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem") <> "U"
						oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemInf:TEXT,",",".")))
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemCalc:TEXT,",",".")))
						EndIf'
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemSuspInf") <> "U"
							oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemSuspInf:TEXT,",",".")))
						EndIF
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemSuspCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_SEMANAL', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurSem:_totApurTribSem:_vlrCRSemSuspCalc:TEXT,",",".")))
						EndIf
					EndIf
				EndIf
			EndIf
			//Tributos apuração diario
			If Type("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia") <> "U"
				oModel604:GetModel('MODEL_V9G_DIARIO')
				If ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia) == "A"
					oModelV9G := oModel604:GetModel('MODEL_V9G_DIARIO')
					For nX := 1 to Len(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia)
						If nX > 1
							oModelV9G:AddLine()
						EndIf
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_FILIAL" , xFilial("V9G"))
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_ID"     , cId)
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VERSAO" , xFunGetVer())
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_TPPER"  , "5")
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_perApurDia:TEXT)
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_CRDia:TEXT)
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_vlrBaseCRDia:TEXT,",",".")))
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[" + cValToChar(nX) + "]:_vlrBaseCRDiaSusp") <> "U"
							oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_vlrBaseCRDiaSusp:TEXT,",",".")))
						EndIf
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_natRend:TEXT)
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[" + cValToChar(nX) + "]:_totApurTribDia") <> "U"
							oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_totApurTribDia:_vlrCRDiaInf:TEXT,",",".")))
							If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[" + cValToChar(nX) + "]:_totApurTribDia:_vlrCRDiaCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_totApurTribDia:_vlrCRDiaCalc:TEXT,",",".")))
							EndIf
							If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[" + cValToChar(nX) + "]:_totApurTribDia:_vlrCRDiaSuspInf") <> "U"
								oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_totApurTribDia:_vlrCRDiaSuspInf:TEXT,",",".")))
							EndIf
							If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[" + cValToChar(nX) + "]:_totApurTribDia:_vlrCRDiaSuspCalc") <> "U"
								oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia[nX]:_totApurTribDia:_vlrCRDiaSuspCalc:TEXT,",",".")))
							EndIf
						EndIf
					Next nX
				ElseIf ValType(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia) == "O"
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_FILIAL" , xFilial("V9G"))
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_ID"     , cId)
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VERSAO" , xFunGetVer())
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_TPPER"  , "5")
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_PERTRB" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_perApurDia:TEXT)
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_CR"     , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_CRDia:TEXT)
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_BASECR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_vlrBaseCRDia:TEXT,",",".")))
					If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_vlrBaseCRDiaSusp") <> "U"
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_BSUSCR" , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_vlrBaseCRDiaSusp:TEXT,",",".")))
					EndIf
					oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_NATREN" , oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_natRend:TEXT)
					If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia") <> "U"
						oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VINFO"  , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaInf:TEXT,",",".")))
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VCALC " , Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaCalc:TEXT,",",".")))
						EndIf
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaSuspInf") <> "U"
							oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VSUSPI ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaSuspInf:TEXT,",",".")))
						EndIf
						If Type ("oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaSuspCalc") <> "U"
							oModel604:LoadValue('MODEL_V9G_DIARIO', "V9G_VSUSPC ", Val(StrTran(oXmlInfoTot:_infoTotal:_ideEstab:_totApurDia:_totApurTribDia:_vlrCRDiaSuspCalc:TEXT,",",".")))
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If oModel604:VldData()
		FwFormCommit(oModel604)
	Else
		cErro := TafRetEMsg(oModel604)
	EndIf
	oModel604:DeActivate()

Return (cErro)

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvApuPer
Grava Apuração por periodo

@parametros:
nLinhaXml : Linha que esta sendo gravada no Model
cCodPer   : Código do period: 1-Mensal | 2-Quinzenal | 3-Decendial | 4-Semanal | 5-Diario
cTotAlias : Alias do Totalizador: "V9Q"-Totalizador das bases de cálculo e das retenções dos tributos com período de apuração decendial
								  "V9R"-Totalizador das bases de cálculo e das retenções dos tributos com período de apuração mensal


@author Rafael de Paula Leme/Carlos Eduardo Boy
@since  07/12/2022
@version 1.0
/*///----------------------------------------------------------------
Static Function GrvApuPer(nLinhaXml as numeric, cCodPer as character, cTotAlias as character) as logical
Local lRet 			as logical 
Local cIndXML 		as character 
Local cDadosXml		as character
Local cSubModel		as character
Local cTagPer		as character
Local cPeriodo		as character
Local cXml			as character
Local aXmlField		as array

Default cTotAlias 	:= "V9Q"

lRet 		:= .t.
cIndXML  	:= iif(nLinhaXml > 0, '[' + cValToChar(nLinhaXml) + ']:', ':') //Se for gravar mais de um item, monta o indice do xml
cDadosXml 	:= ''
cSubModel 	:= ''
cTagPer	 	:= ''
cPeriodo 	:= ''
cXml		:= StrTran("oXmlTot:_REINF:_EVTRETCONS:_XXX:", "XXX", IIf(cTotAlias == "V9Q", "INFOCR_CNR", "INFOTOTALCR"))
aXmlField 	:= {'_PERAPURXXX'		,;
				'_CRXXX'			,;
				'_VLRCRXXXINF'		,;
				'_VLRCRXXXCALC'		,;
				'_VLRCRXXXDCTF'		,;
				'_VLRCRXXXSUSPINF' 	,;
				'_VLRCRXXXSUSPCALC'	,;
				'_VLRCRXXXSUSPDCTF'	,;
				'_NATREND'			} //Atributos do Xml que serao gravados nos campos do model, onde XXX pode ser MEN/QUI/DEC/SEM/DIA

//Monta as variaveis que vão compor o Xml conforme informado no parâmetro.
do Case
	case cCodPer == '1'
		cSubModel 	:= 'oMdlMen'
		cTagPer	  	:= '_TOTAPURMEN'

		cPeriodo	:= 'MEN'
	case cCodPer == '2'
		cSubModel 	:= 'oMdlQui'
		cTagPer		:= '_TOTAPURQUI'
		cPeriodo	:= 'QUI'
	case cCodPer == '3'
		cSubModel 	:= 'oMdlDec'
		cTagPer	  	:= '_TOTAPURDEC'
		cPeriodo	:= 'DEC'
	case cCodPer == '4'
		cSubModel 	:= 'oMdlSem'
		cTagPer	  	:= '_TOTAPURSEM'
		cPeriodo	:= 'SEM'
	otherwise
		cSubModel 	:= 'oMdlDia'
		cTagPer	  	:= '_TOTAPURDIA'
		cPeriodo	:= 'DIA'
endcase

//Monta o Xml com seus elementos conforme o periodo passado por parâmentro
cXml := cXml + cTagPer + cIndXML

//Define os atributos conforme o parâmetro trocando "XXX" pelo periodo MEN, QUI e etc...
aEval( aXmlField , { |x,y| aXmlField[y] := strtran(x,'XXX', cPeriodo) }  )

//Se tiver mais de uma linha para gravar no grid
If nLinhaXml > 1
	&(cSubModel):lValid := .T.  
	&(cSubModel):AddLine()
EndIf

//Grava os dados no modelo somando o atributo no Xml conforme rpeocessado anteriormente.
&(cSubModel):LoadValue(cTotAlias + "_TPPER", cCodPer)

cDadosXml := cXml + aXmlField[1]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue(cTotAlias + "_PERTRB" , &(cDadosXml+':TEXT') ); EndIf  

cDadosXml := cXml + aXmlField[2]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue(cTotAlias + "_CR" , &(cDadosXml+':TEXT') ); EndIf

cDadosXml := cXml + aXmlField[3]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue("V9Q_VTRIBI" , val(StrTran(&(cDadosXml+':TEXT'),",",".")) ); EndIf

cDadosXml := cXml + aXmlField[4]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue("V9Q_VTRIBC" , val(StrTran(&(cDadosXml+':TEXT'),",",".")) ); EndIf

cDadosXml := cXml + aXmlField[5]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue(cTotAlias + "_VRDCTF" , val(StrTran(&(cDadosXml+':TEXT'),",",".")) ); EndIf

cDadosXml := cXml + aXmlField[6]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue("V9Q_VSUSPI" , val(StrTran(&(cDadosXml+':TEXT'),",",".")) ); EndIf

cDadosXml := cXml + aXmlField[7]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue("V9Q_VSUSPC" , val(StrTran(&(cDadosXml+':TEXT'),",",".")) ); EndIf

cDadosXml := cXml + aXmlField[8]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue(cTotAlias + "_VSDCTF" , val(StrTran(&(cDadosXml+':TEXT'),",",".")) ); EndIf

cDadosXml := cXml + aXmlField[9]
If Type(cDadosXml) != "U"; &(cSubModel):LoadValue("V9Q_NATREN" , &(cDadosXml+':TEXT') ); EndIf

return lRet
