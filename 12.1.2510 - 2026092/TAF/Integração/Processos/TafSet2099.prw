#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE TAMMAXXML 075000  //Tamanho Maximo do XML
#DEFINE TAMMSIGN  004000  //Tamanho médio da assinatura 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafSet2099
Rotina para consistencia do fechamento do periodo 05-2018

@author Roberto Souza
@since 14/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafSet2099( cPeriodo )

	Local aCoord 	as array
	Local a2099 	as array

	Default cPeriodo := "062018"
	aCoord 		:= {000,000,500,900}
	a2099 		:= {}	
	 
	If cPeriodo $ "052018/062018/072018" .And. !R2099ok( @a2099, cPeriodo )
		ProcConsult( a2099 )
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} R2099ok
Rotina para consistencia do fechamento do periodo 05-2018

@author Roberto Souza
@since 14/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function R2099ok( a2099 , cPeriodo )
	Local lOk 		as logical
	Local aRet 		as Array
	Local cAlias2099 as character

	Default a2099 := {}
	Default cPeriodo := "062018"

	lOk := .F.
	aRet := {}
	cAlias2099 := GetNextAlias()

	BeginSql ALIAS cAlias2099
		SELECT V0B_ID, V0B_VERSAO, V0B_ATIVO, V0B_STATUS, D_E_L_E_T_ V0BDELET, R_E_C_N_O_ V0BRECNO
			FROM %table:V0B% 
		WHERE V0B_PERAPU = %Exp:cPeriodo% AND
		      V0B_FILIAL = %Exp:cFilAnt% 
	EndSql
	While (cAlias2099)->(!Eof())
		If (cAlias2099)->V0B_STATUS == '4' .And. (cAlias2099)->V0B_ATIVO == '1' .And. Empty((cAlias2099)->V0BDELET)
			lOk := .T.
		EndIf
		AADD(a2099,{;
			(cAlias2099)->V0B_ID,; 
			(cAlias2099)->V0B_VERSAO,;
			(cAlias2099)->V0B_ATIVO,;
			(cAlias2099)->V0B_STATUS,;
			(cAlias2099)->V0BDELET,;
			(cAlias2099)->V0BRECNO,;
			"R2099"+(cAlias2099)->V0B_ID+(cAlias2099)->V0B_VERSAO })

		(cAlias2099)->(DbSkip())
	EndDo
Return( lOk )

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcConsult
Rotina para consistencia do fechamento do periodo 05-2018

@author Roberto Souza
@since 14/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcConsult( a2099 )
	Local Nx 			:= 1
	Local aXmls			:= {}
	Local aXmlsLote 	:= {}
	Local lJob 			:= IsBlind()
	Local cIdEnt  		:= TAFRIdEnt()
	Local cAmbR			:= AllTrim(SuperGetMv('MV_TAFAMBR',.F.,"2"))
	Private aRetorno 	:= {}
	
	cAmbte				:= SuperGetMv('MV_TAFAMBR',.F.,"2")
	cUrl				:= GetMv("MV_TAFSURL")
	nQtdPorLote			:= 50
	aXmls				:= {}
	aXmlsLote			:= {}
	nItem 				:= 0

	If !Empty(AllTrim(cUrl))
		If !("TSSWSREINF.APW" $ Upper(cUrl)) 
			cCheckURL := cUrl
			cUrl += "/TSSWSREINF.apw"
		Else
			cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
		EndIf

		For Nx := 1 To Len(a2099 )
		
			aAdd(aXmls,{"",a2099[Nx][07], a2099[Nx][06], "R-2099" , "V0B"})
			If Len(aXmls) > 0
				aAdd(aXmlsLote,aClone(aXmls))
				aSize(aXmls,0)
			EndIf
		Next

		If Len(aXmlsLote) > 0
			aRetorno := TAFxConsTSS(aXmlsLote,cAmbte,,cUrl,lJob,cIdEnt)

			If Len( aRetorno ) > 0
				nScanAut := 0
				nScanRec := 0
				For Nx :=1 To Len( aRetorno )
					If Len( aRetorno[Nx] )
						If aRetorno[Nx][01]:cSTATUS == "6" .And. aRetorno[Nx][01]:cAMBIENTE == cAmbR
							nScanAut := Nx
						EndIf
					EndIf
				Next

				// Evento autorizado
				If nScanAut > 0
					// Ajusta cadastro
					cProt 	:= aRetorno[nScanAut][01]:cPROTOCOLO
					cRec  	:= aRetorno[nScanAut][01]:cRECIBO
					cStat 	:= aRetorno[nScanAut][01]:cSTATUS
					cChave	:= aRetorno[nScanAut][01]:cCHAVE
					cId		:= AllTrim(aRetorno[nScanAut][01]:cID)
//					cXml 	:= aRetorno[nScanAut][01]:cXmlEvento
//					cXml 	:= Substr(cXml,1,nAt1 -1 )+"</Reinf>"

					n2099	:= aScan( a2099 ,{|x| AllTrim(x[07]) == cId })
					// Verifica um valido e
					n2099Vld := aScan( a2099 ,{|x| AllTrim(x[03]) == "1" .And. Empty(x[05]) })
					// Verifica um evento já autorizado antes amarrado
					n2099Pre := aScan( a2099 ,{|x| AllTrim(x[07]) == cId .And. AllTrim(x[03]) == "2"  .And. AllTrim(x[04]) == "4"  })
					
					If n2099Vld > 0 .And. n2099Pre == 0	
						nRec2099 := a2099[n2099Vld][06]
						DbSelectArea("V0B")
						DbGoTo( nRec2099 )
						RecLock("V0B",.F.)
						V0B->V0B_ID 	:= a2099[n2099][01]
						V0B->V0B_VERSAO := a2099[n2099][02]
						MsUnlock()
					EndIf
				Else
					// Retransmite
					For Nx :=1 To Len( aRetorno )
						If Len( aRetorno[Nx] ) .And. aRetorno[Nx][01]:cAMBIENTE == cAmbR
							aAuxRet := ProcSend( aRetorno[Nx],a2099 )
						EndIf
					Next				
				EndIf	
			EndIf
		EndIf
	EndIf



Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFxConsTSS
Rotina para consistencia do fechamento do periodo 05-2018

@author Roberto Souza
@since 14/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFxConsTSS( aXmlsLote,cAmbiente,lGrvRet,cUrl,lJob,cIdEnt,cEvento )
	
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

	Default cAmbiente	 := ""
	Default aXmlsLote    := {}
	Default lGrvRet 	 := .T.  
	Default cIdEnt		 := TAFRIdEnt()

	Private aRetXML  as array

	oReinf	 	 := Nil
	lRet		 := .F.
	cStatus   	 := ""

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

	cUserTk := "TOTVS" 

	nQtdLotes := Len(aXmlsLote)

	dbSelectArea("T0X")
	T0X->(dbSetOrder(3))

	dbSelectArea("C1E")
	C1E->(dbSetOrder(3))
	C1E->(MsSeek(xFilial("C1E")+cFilAnt+"1"))
	cFilErp := AllTrim(C1E->C1E_CODFIL) 

	For nLote := 1 To nQtdLotes

		oReinf 											:= WSTSSWSREINF():New() 
		oReinf:oWSREINFCONSULTA:oWSCABEC				:= WsClassNew("TSSWSREINF_REINFCABECCONSULTA")
		oReinf:_Url 									:= cUrl
		oReinf:oWSREINFCONSULTA:oWSCABEC:cENTIDADE		:= cIdEnt
		oReinf:oWSREINFCONSULTA:oWSCABEC:cUSERTOKEN		:= cUserTk
		oReinf:oWSREINFCONSULTA:oWSCABEC:cAMBIENTE		:= cAmbiente
		oReinf:oWSREINFCONSULTA:oWSCABEC:lRETORNAXML	:= .T.
		
		oReinf:oWSREINFCONSULTA:oWSEVENTOS	:= WsClassNew("TSSWSREINF_ARRAYOFREINFID")
		oReinf:oWSREINFCONSULTA:oWSEVENTOS:oWSREINFID :={} 

		xTAFMsgJob("Processando Lote: " + AllTrim(Str(nLote)) + "/" +  AllTrim(Str(nQtdLotes))) 

		For nItemLote := 1 To Len(aXmlsLote[nLote])

			aAdd(oReinf:oWSREINFCONSULTA:oWSEVENTOS:oWSREINFID,WsClassNew("TSSWSREINF_REINFID"))
			Atail(oReinf:oWSREINFCONSULTA:oWSEVENTOS:oWSREINFID):CID := aXmlsLote[nLote][nItemLote][2] 

		Next nItemLote 
																																
		lRet := oReinf:CONSULTAREVENTOS() 

		If ValType(lRet) == "L"   
			If lRet
				oHashXML	:=	AToHM(aXmlsLote[nLote], 2, 3 )
				aLoteRetorno := oReinf:oWSCONSULTAREVENTOSRESULT:oWSREINFRETCONSULTA
				
				If (lGrvRet)	
					For nY := 1 To Len(aLoteRetorno)
		
						cIdAux := AllTrim(aLoteRetorno[nY]:CID) 
						HMGet( oHashXML , cIdAux ,@xRetXML )	
						
						If ValType(xRetXML[1][3]) == "N"
						
							cLayOut := xRetXML[1][4]  
								
							// |Status de Retorno dos Documentos	 
							// |
							//1 – Recebido
							//2 – Assinado
							//3 – Erro de schema
							//4 – Aguardando transmissão
							//5 – Rejeição
							//6 – Autorizado
					
							cStatus :=  aLoteRetorno[nY]:CSTATUS 
							
							//Retorno do Número do Recibo de Transmissão do TSS.
							cRecibo		:= AllTrim(aLoteRetorno[nY]:CRECIBO)
							cProtocolo	:= AllTrim(aLoteRetorno[nY]:CPROTOCOLO)
							dDateProc	:= aLoteRetorno[nY]:DDTPROC

							If cStatus == "6"
								//Autorizado
								// Voltar Registro V0B
							ElseIf cStatus == "5"
								If !Empty( cProtocolo )
									// Retransmitir
									// Voltar Registro V0B
								EndIf 
								//rejeitado
							EndIf
							
							cAuxSts := TAFStsXTSS(cStatus) 
						Else
							cMsgRet := "Id " + cIdAux +" não encontrado no lote de envio. "
						EndIf
					Next nY
				EndIf
			Else
				cMsgRet := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) //SOAPFAULT
			EndIf
		Else
			cMsgRet := "Retorno do WS não é do tipo lógico."
			cMsgRet += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		EndIf

		oSocial  := Nil 
		oHashXML := Nil 
		aAdd(aRetorno,aClone(aLoteRetorno))
		aSize(aLoteRetorno,0)
		
	Next nLote

	aSize(aXmlsLote,0)

Return( aRetorno )


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSend
Rotina para consistencia do fechamento do periodo 05-2018

@author Roberto Souza
@since 14/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcSend( aEventos , a2099 )

	Local aXmls := {}
	Local cXml := ""
	Local Nx := 01
	Local cIdThread	 := StrZero(ThreadID(), 10 )
	Local nRegsOk := 1
	Local lErroSch := .F.
	Local lErroSrv := .F.
	Local lXmlTSS  := .F.
	Local cFunction := "TAF496Xml"

	cProt 	:= aEventos[01]:cPROTOCOLO
	cRec  	:= aEventos[01]:cRECIBO
	cStat 	:= aEventos[01]:cSTATUS
	cChave	:= aEventos[01]:cCHAVE
	cId		:= AllTrim(aEventos[01]:cID)
	cXml 	:= aEventos[01]:cXmlEvento

	nAt1 	:= At("<Signature", cXml)
	nAt2 	:= At("</Signature>", cXml)	
	cXml 	:= Substr(cXml,1,nAt1 -1 )+"</Reinf>"
	n2099	:= aScan( a2099 ,{|x| AllTrim(x[07]) == cId })

	If n2099 > 0
		If lXmlTSS
			aAdd(aXmls,{EncodeUTF8( cXml ),a2099[n2099][07], a2099[n2099][06], "R-2099" , "V0B"})
		Else
			Set(_SET_DELETED, .F.)
			DbSelectArea("V0B")
			V0B->( DbGoTo( a2099[n2099][06] ) )
			cXml := &cFunction.( "V0B" , a2099[n2099][06] , , .T. ) 
			Set(_SET_DELETED, .T.)
			aAdd(aXmls,{EncodeUTF8( cXml ),a2099[n2099][07], a2099[n2099][06], "R-2099" , "V0B"})
		EndIf
		aAuxRet := TAFxEnvTSS(aXmls, ,@nRegsOk,.T.,cIdThread,@lErroSch,@lErroSrv)
	EndIf

Return( aAuxRet )




//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSend
Rotina para consistencia do fechamento do periodo 05-2018

@author Roberto Souza
@since 14/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TAFxEnvTSS(aXmls,cAmbR,nRegsOk,lJob,cIdThread,lErroSch,lErroSrv)

	Local oReinf 		as object
	Local cUrl			as character
	Local cVerSchema	as character
	Local cCheckURL		as character
	Local cMsgRetEnv	as character
	Local nY 			as numeric
	Local lRetWS		as logical
	Local aRetEvts		as logical
	Local lOk			as logical 
	Local oHashXML		as object
	Local xRetXML		as object
	Local cDescRet		as character
	Local cDescErro		as character
	Local cTabOpen		as character
	Local cAliasTb		as character

	Default cAmbR		:= SuperGetMv('MV_TAFAMBR',.F.,"2")
	Default aXmls  		:= {} 
	Default nRegsOk 	:= 0
	Default cIdThread 	:= ""

	oReinf	 		:= Nil
	cUrl			:= GetMv("MV_TAFSURL")
	cVerSchema		:= SuperGetMv('MV_TAFVLRE',.F.,"1_03_02")
	cCheckURL		:= "" 
	nY 				:= 1 
	lRetWS			:= .F.
	oHashXML		:= Nil 
	xRetXML			:= Nil
	cDescRet		:= ""
	cDescErro		:= ""
	cTabOpen		:= ""
	cAliasTb		:= ""
	cMsgRetEnv		:= ""
	aRetEvts		:= {}
	lOk				:= .T.
		
	cIdEnt  := TAFRIdEnt()     
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
			oReinf:oWSREINFENVIO:oWSCABEC:cAMBIENTE   			:= cAmbR    
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
				
					oHashXML	:=	AToHM(aXmls, 2, 3 )
					aXmls := {}
					
					If ValType(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO) <> "U"
						For nY := 1 To Len(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO)
						
							cIdAux := AllTrim(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CID)
							HMGet( oHashXML , cIdAux ,@xRetXML )	
							
							If !Empty(xRetXML[1][3])
							
								cAliasTb := xRetXML[1][5]
								If oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:lSucesso
									aAdd(aRetEvts,{.T.,xRetXML[1][4],cIdAux,"Transmitido com Sucesso.",""}) //"Transmitido com Sucesso."
									nRegsOK++
								Else
									If AllTrim(oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CCODIGO) $ "203"
										If FindFunction("TafValSche")
											cMsgRetEnv := TafValSche(xRetXML[1][1], xRetXML[1][4], cIdAux, cUrl, cUserTk, cIdEnt, cAmbR, cVerSchema)
										Else
											cMsgRetEnv := "Evento com erro de schema."
										EndIf
									Else
										cMsgRetEnv := oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CDESCRICAO
									EndIf

									//evento com inconsistência.
									aAdd(aRetEvts,{.F.,xRetXML[1][4],cIdAux,cMsgRetEnv,"S"})
									If lJob
										cLog := "* Retorno Com Erro : " + cIdThread + " - Hora: " + DTOC(dDataBase) + " - " + Time() + CRLF
										cLog += oReinf:oWSENVIAREVENTOSRESULT:oWSREINFRETENVIO[nY]:CDESCRICAO
									Endif
									lErroSch := .T. 
								EndIf 
							Else
								aAdd(aRetEvts,{.F.,xRetXML[1][4],cIdAux,"Não encontrado no lote de envio","A"}) //"Não encontrado no lote de envio"
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
				cDescErro := "Retorno do WS não é do Tipo Lógico." //"Retorno do WS não é do Tipo Lógico."
				cDescErro += CRLF + IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				lOk := .F.
				lErroSrv := .T.
			EndIf
		Else  
			cDescErro := "Não foi possivel conectar com o servidor TSS"	  //"Não foi possivel conectar com o servidor TSS"	 
			lOk := .F.
			lErroSrv := .T.
		EndIf
	EndIf

Return( {lOk,cDescErro,aRetEvts} ) 