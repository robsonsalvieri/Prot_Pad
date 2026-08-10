#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "RPTDEF.CH" 

#INCLUDE "RHNP06.CH"
#INCLUDE "PONCALEN.CH"

STATIC oSPISummary
STATIC cLtEmpSumm
STATIC cMeurhLog  := GetConfig("RESTCONFIG","meurhLog", "0")
STATIC lMrHExtr   := ExistBlock("MRHExtBh")


Function fSetClocking(aUrlParam, cBody, aDataLogin, aIdFunc, cFilJob, cEmpJob, lJob, cUID)
    
	Local oItemDetail			:= Nil
	Local cRD0Cod				:= Nil
    Local cApprover				:= ""
    Local cVision	 			:= ""
    Local cEmpApr				:= ""
    Local cFilApr				:= ""
	Local cFilToReq 			:= ""
	Local cMatToReq 			:= ""
	Local cEmpToReq 			:= ""
    Local cMsgLog				:= ""
    Local cBranchVld			:= ""
	Local nSupLevel				:= 99
    Local aVision				:= {}
    Local aGetStruct			:= {}
    Local aMSToHour 			:= Array(02)
    Local cTypeReq				:= "Z"
    Local cRoutine				:= "W_PWSA400.APW" //Marcação de Ponto: Utilizada para buscar a VISÃO a partir da rotina; (AI8_VISAPV) na função GetVisionAI8().
    Local oRequest				:= Nil
    Local oAttendControlRequest	:= Nil
    Local lRet                  := .T.
	Local lOnlySup				:= .T.
    Local cAllJustify           := ""
    Local cAllReason            := ""
    Local cEntry                := STR0069 //"Entrada"
    Local cExit                 := STR0070 //"Saída"
    Local aTrab                 := {}
	Local aDataRet				:= Array(3)
    Local nA                    := 0
    Local lGestor               := .F.
	Local lRobot				:= .F.
	Local lSUPAprove			:= .F.	
	Local dDate 	 			:= cToD("//")
	Local dPerIni 	 			:= cToD("//")
	Local dPerFim 	 			:= cToD("//")
	Local dHoje					:= cToD("//")

    Default aUrlParam			:= {}
    Default cBody				:= ""
    Default aDataLogin			:= {}
    Default aIdFunc             := {}
    Default cEmpJob				:= cEmpAnt
    Default cFilJob				:= FwCodFil()
    Default lJob				:= .F.
    Default cUID				:= ""

	//Instancia o ambiente para a empresa onde a funcao sera executada
	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpJob, cFilJob )
	EndIf

	cEmpToReq := cEmpAnt
    
	dHoje 					:= dDataBase
	oRequest				:= WSClassNew("TRequest")
    oRequest:RequestType	:= WSClassNew("TRequestType")
    oRequest:Status			:= WSClassNew("TRequestStatus")
    oAttendControlRequest	:= WSClassNew("TAttendControl")
	oItemDetail				:= JsonObject():New()

	If Len(aDataLogin) > 0
		cMatSRA	   := cMatToReq := aDataLogin[1]
		cRD0Cod	   := aDataLogin[3]
		cBranchVld := cFilToReq := aDataLogin[5]	
	EndIf
	
	If !Empty(aIdFunc)
		cFilToReq := aIdFunc[1]
	    cMatToReq := aIdFunc[2]
		cEmpToReq := aIdFunc[3]
		lGestor     := .T.
		lSUPAprove	:= SuperGetMv("MV_SUPTORH", NIL, .F.)
	EndIf

    If !Empty(cBody)
        oItemDetail:FromJson(cBody)
        
        //Em a justificativa tiver sido informada para todas as batidas 
        cAllJustify := If(oItemDetail:hasProperty("justify"),oItemDetail["justify"],"")
        cAllReason  := If(oItemDetail:hasProperty("reason"),oItemDetail["reason"],"")
		lRobot		:= If(oItemDetail:hasProperty("execRobo"), oItemDetail["execRobo"], "0") == "1"

		//Na execucao do Robo atualiza a database conforme a data que veio na requisicao
		If lRobot .And. !Empty(oItemDetail["dDatabase"])			
			dHoje := cTod( Format8601(.T., oItemDetail["dDatabase"]) )
		EndIf
        
        If oItemDetail:hasProperty("clockings") .And. ValType(oItemDetail["clockings"]) == "A"
            For nA := 1 To len(oItemDetail["clockings"])

                //Verifica se a justificativa para multiplas marcações foi preenchida.
                If Empty(cAllJustify) .And. If( oItemDetail["clockings"][nA]:hasProperty("justify"), Empty(oItemDetail["clockings"][nA]["justify"]), .T. )
                  lRet := .F.
                  Exit
                EndIf
            
                AAdd(aTrab,{;
                    Iif(oItemDetail["clockings"][nA]:hasProperty("hour"),oItemDetail["clockings"][nA]["hour"]," "),;
                    Iif(oItemDetail["clockings"][nA]:hasProperty("date"),oItemDetail["clockings"][nA]["date"]," "),;
                    Iif(!Empty(cAllJustify), cAllJustify, oItemDetail["clockings"][nA]["justify"] ),;
                    Iif(oItemDetail["clockings"][nA]:hasProperty("referenceDate"),oItemDetail["clockings"][nA]["referenceDate"]," "),;
                    Iif(oItemDetail["clockings"][nA]:hasProperty("direction"),oItemDetail["clockings"][nA]["direction"]," "),;
                    Iif(oItemDetail["clockings"][nA]:hasProperty("origin"),oItemDetail["clockings"][nA]["origin"]," "),;
                    Iif(!Empty(cAllReason), cAllReason, oItemDetail["reason"]);                    
                })
				dDate := STOD( SubSTR(aTrab[nA,2], 1, 4) + SubSTR(aTrab[nA,2], 6, 2) + SubSTR(aTrab[nA,2], 9, 2) )
            Next nA
        Else

	       	//Verifica se o motivo e a justificativa da marcação individual foram preenchidos.
	       	lRet := If( oItemDetail:hasProperty("justify"), !Empty(oItemDetail["justify"]), .F.)
        
            AAdd(aTrab,{;
                Iif(oItemDetail:hasProperty("hour"),oItemDetail["hour"]," "),;
                Iif(oItemDetail:hasProperty("date"),oItemDetail["date"]," "),;
                oItemDetail["justify"],;
                Iif(oItemDetail:hasProperty("referenceDate"),oItemDetail["referenceDate"]," "),;
                Iif(oItemDetail:hasProperty("direction"),oItemDetail["direction"]," "),;
                Iif(oItemDetail:hasProperty("origin"),oItemDetail["origin"]," "),;
                Iif(oItemDetail:hasProperty("reason"),oItemDetail["reason"]["id"]," ");
            })
			dDate := STOD( SubSTR(aTrab[1,2], 1, 4) + SubSTR(aTrab[1,2], 6, 2) + SubSTR(aTrab[1,2], 9, 2) ) 
        EndIf
        
        //-- Verifica se o campo motivo foi informado
        If lRet .And. !Empty(aTrab[1][7])
           	// ---------------------------------------------- 
            // - A Função GetVisionAI8() devolve por padrão
            // - Um Array com a seguinte estrutura:
            // - aVision[1][1] := "" - AI8_VISAPV
            // - aVision[1][2] := 0  - AI8_INIAPV
            // - aVision[1][3] := 0  - AI8_APRVLV
            // - Por isso as posição podem ser acessadas
            // - Sem problemas, ex: cVision := aVision[1][1]
            // ----------------------------------------------
            aVision := GetVisionAI8(cRoutine, cBranchVld)
            cVision := aVision[1][1]

            // -------------------------------------------------------------------------------------------
            // - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicitação.
            // - Obs.: Quando o gestor inclui uma solicitação para um subordinado a aprovação pode ir direto
            // - para o RH, caso o parametro MV_SUPTORH esteja definido com valor .T.
            //- -------------------------------------------------------------------------------------------
            If !lGestor .Or. (lGestor .And. !lSUPAprove)				
				cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
	            aGetStruct   := APIGetStructure(cRD0Cod, ;
								SUPERGETMV("MV_ORGCFG"), ;
								cVision, ;
								cBranchVld, ;
								cMatSRA, ;
								NIL, ;
								NIL, ;
								NIL,;
								cTypeReq, ;
								cBranchVld, ;
								cMatSRA, ;
								NIL, ;
								NIL, ;
								NIL, ;
								NIL, ;
								.T., ;
								{cEmpAnt},;
								NIL,;
								NIL,;
								lOnlySup) // SOMENTE SUPERIOR. 

				If valtype(aGetStruct[1]) == "L" .and. !aGetStruct[1]
					cMsgLog := AllTrim( EncodeUTF8(aGetStruct[2]) +" - " +EncodeUTF8(aGetStruct[3]) )
					lRet 	:= .F.
				Else
					If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
						cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
						cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
						nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
						cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
					EndIf
				EndIf
            EndIf
			
			// Busca o período de apontamento conforme a data da batida.
			// Caso a data da batida seja superior ao MV_PONMES, será criado o período futuro automaticamente.
			PerAponta( @dPerIni, @dPerFim, dDate, .F., cFilToReq, .T., , , , .F. )

            If Len(aTrab) > 0 .And. lRet
				//Valida se as marcações não estão com data inferior ao período em aberto no MV_PONMES.
				lRet := fVldMarc(aTrab, cFilToReq, dPerFim, @cMsgLog, dHoje)
                If lRet 
					For nA := 1 To Len(aTrab)
						aMsToHour	:= milisSecondsToHour(aTrab[nA][1],aTrab[nA][1])
						dDate 		:= STOD( SubSTR(aTrab[nA][2], 1, 4) + SubSTR(aTrab[nA][2], 6, 2) + SubSTR(aTrab[nA][2], 9, 2) )

						If !( lRet := fValidAdm( cFilToReq, cMatToReq, dDate, @cMsgLog ) )
							Exit
						EndIf
						//-- Verifica se data da batida é menor/igual data atual
						If dDate <= dHoje
							oRequest:Branch						:= cFilToReq
							oRequest:StarterBranch				:= cBranchVld
							oRequest:StarterRegistration		:= cMatSRA
							oRequest:Registration				:= cMatToReq
							oRequest:ApproverBranch				:= cFilApr
							oRequest:ApproverRegistration		:= cApprover
							oRequest:EmpresaAPR					:= cEmpApr
							oRequest:Empresa					:= cEmpToReq
							oRequest:ApproverLevel				:= nSupLevel
							oRequest:Vision						:= cVision

							oAttendControlRequest:Branch  		:= cFilToReq
							oAttendControlRequest:Registration	:= cMatToReq
							oAttendControlRequest:Name			:= Alltrim(Posicione('SRA',1,cFilToReq+cMatToReq,'SRA->RA_NOME'))
							oAttendControlRequest:EntryExit     := If(Alltrim(aTrab[nA][5])=="entry", cEntry, cExit)
							oAttendControlRequest:Observation  	:= GetMotDesc(aTrab[nA][7], ,cFilToReq)
							oAttendControlRequest:Motive        := aTrab[nA][3]
							oAttendControlRequest:Date			:= Format8601(.T.,aTrab[nA][2])
							oAttendControlRequest:Hour			:= cValToChar(aMsToHour[1])

							lRet := AddAttendControlRequest(oRequest, oAttendControlRequest, .T., @cMsgLog, STR0038 ) //"MEURH"
						Else
							cMsgLog := STR0024
							lRet    := .F.
							Exit
						EndIf
					Next nA
				EndIf
            EndIf
        Else
            cMsgLog := STR0071 //"Os campos 'Motivo' e 'Justificativa' devem ser informados!"
            lRet    := .F.
        EndIf
    EndIf

	aDataRet[1] := lRet
	aDataRet[2] := cMsgLog
	aDataRet[3] := lRobot

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return( aDataRet )

Function fGlobalClocks(cBody, aRequest, lJob, cUID)
    
	Local oBody					:= Nil
	Local oRequest				:= Nil
    Local oAttend				:= Nil
	Local oError				:= NIL
	Local oRet					:= NIL
    Local cBranchVld			:= aRequest[2]
	Local cMatSRA				:= aRequest[3]
	Local cEmpToReq 			:= aRequest[4]
	Local cFilToReq 			:= aRequest[5]
	Local cMatToReq 			:= aRequest[6]
	Local cDate					:= ""
    Local cApprover				:= ""
    Local cVision	 			:= ""
    Local cEmpApr				:= ""
    Local cFilApr				:= ""
    Local cMsgLog				:= ""
    Local cRoutine				:= "W_PWSA400.APW" //Marcação de Ponto: Utilizada para buscar a VISÃO a partir da rotina; (AI8_VISAPV) na função GetVisionAI8().
    Local cAllJustify           := ""
    Local cAllReason            := ""
	Local cOccDay				:= ""
	Local cDirection			:= ""
	Local cOrigin				:= ""
	Local cJustify				:= ""
	Local cOperation			:= ""
	Local cId					:= ""
	Local cRD0Cod				:= aRequest[7]
	Local nSupLevel				:= 99
	Local nErrors				:= 0
	Local nSuccess				:= 0
    Local nA, nB	            := 0
	Local nHour					:= 0
    Local aVision				:= {}
    Local aGetStruct			:= {}
	Local aMessages				:= {}
    Local aTrab                 := {}
	Local aDel					:= {}
    Local aMSToHour 			:= Array(02)
    Local cEntry                := STR0069 //"Entrada"
    Local cExit                 := STR0070 //"Saída"
    Local lGestor               := aRequest[8]
	Local dDate 	 			:= cToD("//")
	Local dPerIni 	 			:= cToD("//")
	Local dPerFim 	 			:= cToD("//")
	Local dHoje					:= cToD("//")
	Local lRobot				:= .F.
	Local lSUPAprove			:= .F.	
	Local lPost					:= .F.
	Local lJustify				:= .F.
	Local lGrava				:= .T.

    DEFAULT lJob				:= .F.
    DEFAULT cUID				:= ""

	//Instancia o ambiente para a empresa onde a funcao sera executada
	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpToReq, cFilToReq )
	EndIf
    
	dHoje 					:= dDataBase
	oRequest				:= NIL
    oAttend					:= NIL
	oBody					:= NIL

    If !Empty(cBody)
		
		lSUPAprove := SuperGetMv("MV_SUPTORH", NIL, .F.)
		
		oBody := JsonObject():New()
        oBody:FromJson(cBody)
        
        //Em a justificativa tiver sido informada para todas as batidas 
        cAllJustify := If(oBody:hasProperty("globalJustify"),oBody["globalJustify"],"")
        cAllReason  := If(oBody:hasProperty("reason"),oBody["reason"]["id"],"")
		lRobot		:= If(oBody:hasProperty("execRobo"), oBody["execRobo"], "0") == "1"

		//Na execucao do Robo atualiza a database conforme a data que veio na requisicao
		If lRobot .And. !Empty(oBody["dDatabase"])			
			dHoje := cTod( Format8601(.T., oBody["dDatabase"]) )
		EndIf
        
        //-- Verifica se o campo motivo foi informado
        If !Empty(cAllReason) .And. ;
			oBody:hasProperty("date") .And. ;
			ValType(oBody["date"]) == "A" .And. ;
			Len(oBody["date"]) > 0

			For nA := 1 To len(oBody["date"])
				cDate := oBody["date"][nA]["date"]
				dDate := STOD( SubSTR(cDate, 1, 4) + SubSTR(cDate, 6, 2) + SubSTR(cDate, 9, 2) )
				cOccDay	:= AllTrim(oBody["date"][nA]["occasionalDay"])
		
				// Busca período de apontamento.
				If Empty(dPerIni) .Or. Empty(dPerFim)
					PerAponta( @dPerIni, @dPerFim, dDate, .F., cFilToReq, .T., , , , .F. )
				EndIf

				For nB := 1 To Len(oBody["date"][nA]["clocks"])
					lGrava      := .T.
					aTrab		:= {}
					nHour 		:= oBody["date"][nA]["clocks"][nB]["hour"]
					cDirection 	:= AllTrim(oBody["date"][nA]["clocks"][nB]["direction"])
					cOrigin 	:= AllTrim(oBody["date"][nA]["clocks"][nB]["origin"])
					cJustify 	:= AllTrim(oBody["date"][nA]["clocks"][nB]["justify"])
					cOperation 	:= AllTrim(lower(oBody["date"][nA]["clocks"][nB]["operation"]))
					cId 		:= oBody["date"][nA]["clocks"][nB]["id"]
					lPost		:= !lPost .And. cOperation == "post"
					lJustify	:= !Empty(cJustify)

					aAdd( aTrab , { ;
								nHour,;
								cDate } )

					// valida se tem dia ocasional e é férias ou afastamento.
					If !Empty(cOccDay) .And. !(cOccDay == "holiday")
						nErrors++
						lGrava := .F.
						oError := JsonObject():New()
						oError["code"] := "2"
						oError["date"] := cDate
						oError["hour"] := nHour
						oError["description"] := EncodeUTF8(STR0134)// "Não é possível inserir marcações durante férias ou afastamentos"

						aAdd(aMessages, oError)
						FreeObj(oError)
					EndIf
					// Valida data de admissão em relação à batida.
					If !fValidAdm( cFilToReq, cMatToReq, dDate, @cMsgLog )
						nErrors++
						lGrava := .F.
						oError := JsonObject():New()
						oError["code"] := "3"
						oError["date"] := cDate
						oError["hour"] := nHour
						oError["description"] := EncodeUTF8(cMsgLog)

						aAdd(aMessages, oError)
						FreeObj(oError)
					EndIf

					// Batida data da marcação e hora das marcações.
					If !fVldMarc(aTrab, cFilToReq, dPerFim, @cMsgLog, dHoje)
						nErrors++
						lGrava := .F.
						oError := JsonObject():New()
						oError["code"] := "4"
						oError["date"] := cDate
						oError["hour"] := nHour
						oError["description"] := EncodeUTF8(cMsgLog)

						aAdd(aMessages, oError)
						FreeObj(oError)
					EndIf

					//Valida justificativa vazia.
					If Empty(cAllJustify) .And. !lJustify
						nErrors++
						lGrava := .F.
						oError := JsonObject():New()
						oError["code"] := "5"
						oError["date"] := cDate
						oError["hour"] := nHour
						oError["description"] := EncodeUTF8(STR0089) // "Informe uma justificativa!"

						aAdd(aMessages, oError)
						FreeObj(oError)
					EndIf

					IF lGrava

						oRequest				:= WSClassNew("TRequest")
						oRequest:RequestType	:= WSClassNew("TRequestType")
						oRequest:Status			:= WSClassNew("TRequestStatus")
						oAttend					:= WSClassNew("TAttendControl")

						// Somente carrega estrutura se houver inclusão. Alteração e exclusão não é necessário.
						// Não é necessário chamar a apigetstructure a cada novo post. uma vez carregado, mantem-se as informações.
						If lPost
							aVision := GetVisionAI8(cRoutine, cBranchVld)
							cVision := aVision[1][1]

							// -------------------------------------------------------------------------------------------
							// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicitação.
							// - Obs.: Quando o gestor inclui uma solicitação para um subordinado a aprovação pode ir direto
							// - para o RH, caso o parametro MV_SUPTORH esteja definido com valor .T.
							//- -------------------------------------------------------------------------------------------
							If !lGestor .Or. (lGestor .And. !lSUPAprove)				
								cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
								aGetStruct   := APIGetStructure(cRD0Cod, ;
																SUPERGETMV("MV_ORGCFG"), ;
																cVision, ;
																cBranchVld, ;
																cMatSRA,;
																NIL ,;
																NIL ,;
																NIL ,;
																NIL,;
																cBranchVld, ;
																cMatSRA,;
																NIL ,;
																NIL ,;
																NIL ,;
																NIL ,;
																.T.,;
																{cEmpAnt},;
																NIL,;
																NIL,;
																.T.) 
								If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
									cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
									cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
									nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
									cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
								EndIf
							EndIf
						EndIf

						// Coleta hora da batida.
						aMsToHour	:= milisSecondsToHour(nHour,nHour)
						// Gravação
						If cOperation == "post"
							//-- Verifica se data da batida é menor/igual data atual
							If dDate <= dHoje
								oRequest:Branch				  := cFilToReq
								oRequest:StarterBranch		  := cBranchVld
								oRequest:StarterRegistration  := cMatSRA
								oRequest:Registration		  := cMatToReq
								oRequest:ApproverBranch		  := cFilApr
								oRequest:ApproverRegistration := cApprover
								oRequest:EmpresaAPR			  := cEmpApr
								oRequest:Empresa			  := cEmpToReq
								oRequest:ApproverLevel		  := nSupLevel
								oRequest:Vision				  := cVision

								oAttend:Branch  			  := cFilToReq
								oAttend:Registration		  := cMatToReq
								oAttend:Name				  := Alltrim(Posicione('SRA',1,cFilToReq+cMatToReq,'SRA->RA_NOME'))
								oAttend:EntryExit     		  := If(cDirection=="entry", cEntry, cExit)
								oAttend:Observation  	      := GetMotDesc(cAllReason, ,cFilToReq)
								oAttend:Motive        		  := Iif(lJustify, cJustify, cAllJustify)
								oAttend:Date			      := Format8601(.T.,cDate)
								oAttend:Hour				  := cValToChar(aMsToHour[1])

								AddAttendControlRequest(oRequest, oAttend, .T., @cMsgLog, STR0038 ) //"MEURH"
								nSuccess++
							Else
								nErrors++
								oError := JsonObject():New()
								oError["code"] := "6"
								oError["date"] := cDate
								oError["hour"] := nHour
								oError["description"] := EncodeUTF8(STR0024) // Não é possível incluir batidas em datas futuras!

								aAdd(aMessages, oError)
								FreeObj(oError)
							EndIf
						ElseIF cOperation == "put"
							aIdReq := StrTokArr(cId,"|")
							IF Len(aIdReq) > 1
								If RH3->(DbSeek( cFilToReq + aIdReq[2] ))
									If RH3->RH3_STATUS == '1' .Or. (lGestor .And. RH3->RH3_STATUS == "4")
										nSuccess++
										oRequest:Branch       := cFilToReq
										oAttend:Branch        := cFilToReq
										oAttend:Registration  := cMatToReq
										oAttend:Name          := Alltrim(Posicione('SRA',1,cFilToReq+cMatToReq,'SRA->RA_NOME'))
										oAttend:EntryExit     := If(cDirection=="entry", cEntry, cExit)
										oAttend:Date          := Format8601(.T.,cDate)
										oAttend:Hour          := cValToChar(aMsToHour[1])
										oAttend:Observation   := GetMotDesc( cAllReason, aIdReq[2], cFilToReq )
										oAttend:Motive        := Iif(lJustify, cJustify, cAllJustify)
										oAttend:codeRequest   := aIdReq[2]

										AddAttendControlRequest(oRequest, oAttend, .T., @cMsgLog, STR0038 ) //"MEURH")
									Else
										nErrors++
										oError := JsonObject():New()
										oError["code"] := "7"
										oError["date"] := cDate
										oError["hour"] := nHour
										oError["description"] := Iif( RH3->RH3_STATUS == '2'	 , ;
																	  EncodeUTF8(STR0135)		 , ; // Esta batida não pode ser alterada pois está aprovada pelo RH.
																	  Iif( RH3->RH3_STATUS == '3', ;
																	  EncodeUTF8(STR0135)		 , ; // Esta batida não pode ser alterada pois está reprovada.
																	  EncodeUTF8(STR0032)))			// "Esta batida não poderá ser excluída porque o processo de aprovação já foi iniciado."

										aAdd(aMessages, oError)
										FreeObj(oError)
									EndIf
								EndIf
							EndIf
						// Deleção.
						ElseIf cOperation == "delete"
							aIdReq := StrTokArr(cId,"|")
							If Len(aIdReq) > 1
								aDel := DelBatida(cFilToReq, ;
										cMatToReq, ;
										aIdReq[2], ;
										{ cMatSRA, NIL, NIL, NIL, cBranchVld  } )
								If aDel[1]
									nSuccess++
								Else
									nErrors++
									oError := JsonObject():New()
									oError["code"] := "8"
									oError["date"] := cDate
									oError["hour"] := nHour
									oError["description"] := aDel[2] // //"Esta batida não poderá ser excluída porque o processo de aprovação já foi iniciado."

									aAdd(aMessages, oError)
									FreeObj(oError)
								EndIf
							EndIf
						EndIf
					EndIf
					FreeObj(oRequest)
					FreeObj(oAttend)
				Next nB
			Next nA
        Else
			nErrors++
			oError := JsonObject():New()
			oError["date"] 		  := ""
			oError["hour"] 		  := 0
			oError["description"] := EncodeUTF8(STR0027) // "Motivo não informado!"
			oError["code"]		  := "1"

			aAdd(aMessages, oError)
			FreeObj(oError)
        EndIf
    EndIf

	oRet := JsonObject():New()
	oRet["errorTotalizer"] 	 := nErrors
	oRet["successTotalizer"] := nSuccess
	oRet["messages"] 		 := aMessages

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return( oRet )


/*/{Protheus.doc}GetAllowances
@author:	Matheus Bizutti
@since:		18/08/2017
/*/
Function GetAllowances(cEmp, cBranchVld, lJob, cUID)

Local cQuery     := ""
Local cBrchSP6   := ""
Local cTabSP6    := ""
Local aProps     := fGetPropAllowance()
Local aData		 := {}
Local oAllowType := JsonObject():New()
Local lCposSP6   := .F.
Local cCposQuery := "%SP6.P6_CODIGO, SP6.P6_DESC"
LOcal cWhere     := ""
Local lCpoExibe	 := .F.

Default cEmp        := ""
Default cBranchVld	:= ""
Default lJob        := .F.
Default cUID        := ""

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv(cEmp, cBranchVld)
EndIf

cBranchVld	:= If(Empty(cBranchVld), FwCodFil(), cBranchVld)
cEmp        := If(Empty(cEmp), cEmpAnt, cEmp)

cQuery     := GetNextAlias()
lCpoExibe  := SP6->(ColumnPos("P6_STATUS")) > 0
lCposSP6   := CpoUsado("P6_MEURH") .And. CpoUsado("P6_ANEXMRH") .And. GetRpoRelease() >= "12.1.027"

cWhere += If( lCposSP6, "SP6.P6_MEURH <> '2' AND ", "" )
cWhere += If( lCpoExibe, "SP6.P6_STATUS <> '2' AND ", "" )
cWhere := "%" + cWhere + "%"

cTabSP6 := "%" + RetFullName("SP6", cEmp) + "%"

cBrchSP6 := xFilial("SP6", cBranchVld)

cCposQuery += If(lCposSP6, ", SP6.P6_MEURH, SP6.P6_ANEXMRH%", "%")

BEGINSQL ALIAS cQuery

	SELECT %exp:cCposQuery%
	FROM
		%exp:cTabSP6% SP6
	WHERE
		SP6.P6_FILIAL = %Exp:cBrchSP6% AND
		SP6.P6_PREABO = 'S' AND
		%exp:cWhere%
		SP6.%NotDel%
ENDSQL

If !Empty(cQuery)
	While !(cQuery)->(Eof())
		oAllowType := JsonObject():New()

		oAllowType["id"]  		  			:= EncodeUTF8((cQuery)->P6_CODIGO)
		oAllowType["description"] 			:= EncodeUTF8( AllTrim((cQuery)->P6_DESC) )
		oAllowType["type"]        			:= "hour"
		oAllowType["requiredAttachment"]	:= lCposSP6 .And. (cQuery)->P6_ANEXMRH == "1"
		oAllowType["props"]		  			:= aProps

		aAdd(aData, oAllowType)

	(cQuery)->(dbSkip())

	EndDo
EndIf

(cQuery)->(dbCloseArea())

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

FreeObj(oAllowType)

Return(aData)



Function AllowanceRequest(aUrlParam,cBody,oItem,oItemDetail,cToken,cStatus,aIdFunc,cKeyId)

Local oMessages		:= Nil
Local oRequest		:= Nil
Local cApprover		:= ""
Local cVision	 	:= ""
Local cEmpApr		:= ""
Local cFilApr		:= ""
Local nSupLevel		:= 99
Local aGetStruct	:= {}
Local aDataLogin	:= {}
Local cTypeReq		:= "8"
Local aVision		:= {}
Local cRoutine		:= "W_PWSA160.APW" // Justifica de Abono: Utilizada para buscar a VISÃO a partir da rotina; (AI8_VISAPV) na função GetVisionAI8().
Local cReason		:= ""
Local cBranchVld	:= FwCodFil()
Local cMatSRA		:= ""
Local cFilToReq		:= ""
Local cMatToReq		:= ""
Local cInitDate		:= ""
Local cEndDate		:= ""
Local cFileType		:= ""
Local cFileContent	:= ""
Local cJustify		:= ""
Local dDtIniPonMes	:= Ctod("//")
Local dDate			:= cTod("//")
Local cEmpToReq		:= cEmpAnt
Local cMsgReturn 	:= EncodeUTF8(STR0029) //"Dados atualizados com sucesso."
Local aMSToHour 	:= Array(02)
Local aPeriods      := {}
Local cRD0Cod	 	:= ""
Local cBkpMod		:= cModulo
Local lIncAbono		:= .F.
Local lRet			:= .T.
Local lGestor       := .F.
Local lSUPAprove    := .F.
Local oScheduleJustificationRequest := Nil

Default aUrlParam		:= {}
Default cBody			:= ""
Default oItem 	 		:= JsonObject():New()
Default oItemDetail		:= JsonObject():New()
Default cToken			:= ""
Default aIdFunc			:= {}
Default cKeyId			:= ""

cModulo := "GPE" // Atribui o módulo GPE para consultar corretamente as fotos no banco de dados.

oMessages 						:= JsonObject():New()
oRequest						:= WSClassNew("TRequest")
oRequest:RequestType			:= WSClassNew("TRequestType")
oRequest:Status					:= WSClassNew("TRequestStatus")
oScheduleJustificationRequest	:= WSClassNew("TScheduleJustification")

aDataLogin := GetDataLogin(cToken,,cKeyId)
If Len(aDataLogin) > 0
	cRD0Cod		:= aDataLogin[3]
	cMatSRA		:= cMatToReq := aDataLogin[1]
	cBranchVld	:= cFilToReq := aDataLogin[5]	
EndIf

If !Empty(cBody)

	oItemDetail:FromJson(cBody)

	// ----------------------------------------------
	// - A Função GetVisionAI8() devolve por padrão
	// - Um Array com a seguinte estrutura:
	// - aVision[1][1] := "" - AI8_VISAPV
	// - aVision[1][2] := 0  - AI8_INIAPV
	// - aVision[1][3] := 0  - AI8_APRVLV
	// - Por isso as posição podem ser acessadas
	// - Sem problemas, ex: cVision := aVision[1][1]
	// ----------------------------------------------
	aVision := GetVisionAI8(cRoutine, cBranchVld)
	cVision := aVision[1][1]

	// ---------------------------------------------------------------------------------------
	// - Quando o gestor inclui uma solicitação para um subordinado a aprovação pode ir direto
	// - para o RH, caso o parametro MV_SUPTORH esteja definido com valor .T.
	//- --------------------------------------------------------------------------------------
	lGestor		:= Len(aIdFunc) > 0
	lSUPAprove	:= SuperGetMv("MV_SUPTORH", NIL, .T.)

	// -------------------------------------------------------------------------------------------
	// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicitação.
	//- -------------------------------------------------------------------------------------------
	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
	aGetStruct := APIGetStructure(cRD0Cod, SUPERGETMV("MV_ORGCFG"), cVision, cBranchVld, cMatSRA, , , ,cTypeReq , cBranchVld, cMatSRA, , , , , .T., {cEmpAnt})

	If Valtype(aGetStruct[1]) == "L" .And. !aGetStruct[1]
		cMsgReturn := AllTrim( EncodeUTF8(aGetStruct[2]) +" - " +EncodeUTF8(aGetStruct[3]) )
		lRet := .F.
	Else
		If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1]) .And. (!lGestor .Or. (lGestor .And. !lSUPAprove))
			cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
			cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
			nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
			cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
		EndIf
	EndIf

	cJustify := Alltrim(FwCutOff(oItemDetail["justify"]))

	If !Empty(cJustify)
		If Len(cJustify) > 50
			lRet		:= .F.
			// Conteúdo da Justificativa deve possuir tamanho até no máximo 50 caracteres para que a solicitação seja realizada!"
			cMsgReturn	:=  EncodeUTF8(STR0081)
		ElseIf Len(cJustify) < 3
			lRet		:= .F.
			// Conteúdo da Justificativa deve possuir tamanho mínimo de 3 caracteres para que a solicitação seja realizada!"
			cMsgReturn	:=  EncodeUTF8(STR0090)
		EndIf
	Else
		cMsgReturn := EncodeUTF8(STR0089) //"Informe uma justificativa!"
		lRet := .F.
	EndIf
	
	If lRet
		// -------------------------------------------------------------------------------------------
		// Ajusta o solicitante caso a solicitacao esteja sendo feita de um gestor para o subordinado 
		//- -------------------------------------------------------------------------------------------
		If Len(aIdFunc) > 0
			cFilToReq	:= aIdFunc[1]
			cMatToReq	:= aIdFunc[2]
			cEmpToReq	:= aIdFunc[3]
		EndIf

		oRequest:Branch					:= cFilToReq
		oRequest:StarterBranch			:= cBranchVld
		oRequest:Registration           := cMatToReq
		oRequest:StarterRegistration	:= cMatSRA
		oRequest:Observation            := cJustify
		oRequest:ApproverBranch			:= cFilApr
		oRequest:ApproverRegistration   := cApprover
		oRequest:EmpresaAPR				:= cEmpApr
		oRequest:Empresa                := cEmpToReq
		oRequest:ApproverLevel			:= nSupLevel
		oRequest:Vision                 := cVision

		// --------------------------------
		// - CONVERTE O VALOR QUE VEM EM
		// - DATE TIME ISO 8601 DO CLIENT.
		// --------------------------------
		cInitDate	:= Iif(oItemDetail:hasProperty("initDate"),Format8601(.T.,oItemDetail["initDate"]),"")
		dDate		:= Iif( !Empty( cInitDate ),;
							 StoD( SubStr( cInitDate, 7, 4 ) + ;
							 SubStr( cInitDate, 4, 2 ) 		 + ;
							 SubStr( cInitDate, 1, 2 ) ) 	 , ;
							 cTod("//") )
		cEndDate	:= Iif(oItemDetail:hasProperty("endDate"),Format8601(.T.,oItemDetail["endDate"]),"")
		cReason 	:= Iif(oItemDetail:hasProperty("allowanceType"),oItemDetail["allowanceType"]["id"]," ")

		//Verifica se a data inicial do abono é anterior ao período aberto.
		aPeriods := GetDataForJob( "1", { cFilToReq, NIL, 1, dDate }, cEmpToReq )
		If Len(aPeriods) > 0
			dDtIniPonMes := aPeriods[1,1]
		EndIf

		If(cToD(cInitDate) < dDtIniPonMes .Or. Empty(dDtIniPonMes))
			cStatus := "400"
			oItem["code"] 	 := cStatus
			oItem["message"] := EncodeUTF8(STR0088) //"Data inicial anterior ao período aberto."  
		Else
			If !ValType( oItemDetail["file"] ) == "U"
				cFileType	:= oItemDetail["file"]["type"]
				cFileContent:= oItemDetail["file"]["content"]
			EndIf

			aMsToHour := milisSecondsToHour(oItemDetail["initHour"],oItemDetail["endHour"])

			oScheduleJustificationRequest:Reason  		:= cReason
			oScheduleJustificationRequest:InitialDate	:= CToD(cInitDate)
			oScheduleJustificationRequest:FinalDate		:= CToD(cEndDate)
			oScheduleJustificationRequest:InitialTime	:= aMsToHour[1]
			oScheduleJustificationRequest:FinalTime		:= aMsToHour[2]
			oScheduleJustificationRequest:FileType		:= cFileType
			oScheduleJustificationRequest:FileContent	:= cFileContent

			//Verifica se não existe abono cadastrado para a mesma data e hora
			lIncAbono := GetJustification( cFilToReq, cMatToReq, CToD(cInitDate), CToD(cEndDate), aMsToHour[1], aMsToHour[2] )

			//Funcao que efetua a gravação da requisição no Protheus.
			If lIncAbono
				AddScheduleJustificationRequest(oRequest, oScheduleJustificationRequest, STR0038, .T., @cMsgReturn) //"MEURH"
			Else
				cStatus := "400"
				oItem["code"] 		:= cStatus
				oItem["message"]	:= EncodeUTF8(STR0007) //"Já existe abono cadastrado para essa data/hora"
			EndIf			
		EndIf
	Else
		cStatus := "400"
		oItem["code"] 		:= cStatus
		oItem["message"]	:= cMsgReturn
	EndIf
EndIf

cModulo := cBkpMod

Return(Nil)



Function getClockings(cBranchVld, cMatSRA, dPerIni, dPerFim, lDivergent, cEmpJob, lJob, cUID, lOnlyDiv)

Local oLabelDiv			:= Nil
Local oClockings		:= Nil
Local cQueryAlias 		:= Nil
Local nI				:= 0
Local nA                := 0
Local nCount			:= 0
Local nPos              := 0
Local nPosRH4			:= 0
Local nSoma1            := 1
Local cID 				:= ""
Local oStatus 			:= ""
Local cRetStatus		:= ""
Local cLabStatus		:= ""
Local cRH3Status		:= ""
Local cChave			:= ""
Local cRH3Cod			:= ""
Local cFilRS3			:= ""
Local cTnoSRA			:= ""
Local cAliasMarc		:= "SP8"
Local cFilSRA           := ""
Local cIdAprv			:= ""
Local cNomeAprv			:= ""
Local aCposRH4			:= {}
Local aIdReq			:= {}
Local aDateGMT			:= {}
Local aAux				:= {}
Local aMarcRS3			:= {}
Local aMarcOrd			:= {}
Local aAddMarc			:= {}
Local aDivergent		:= {}
Local aLabelDiv			:= {}
Local aSequen           := {}
Local aPeriods			:= {}
Local aMarcGet			:= {}
Local aData				:= {}
Local dDtRef			:= Ctod("//")
Local dLastDt			:= Ctod("//")
Local dLastDiv			:= Ctod("//")
Local dAuxIniPer   		:= Ctod("//")
Local dAuxFimPer   		:= Ctod("//")
Local lIsGeo			:= .F.
Local lRegRS3			:= .F.
Local lContinua			:= .F.
Local lPeriodo 			:= dPerIni != dPerFim
Local lAtulizRFE		:= .F.
Local lGetMarcAuto		:= "S"
Local nPosEmp			:= ( ELEMENTOS_AMARC + 1 )
Local nPosFil			:= ( ELEMENTOS_AMARC + 2 )
Local nPosMat			:= ( ELEMENTOS_AMARC + 3 )

Private aMarcacoes		:= {}
Private aTabCalend  	:= {}
Private aTabPadrao		:= {}
Private aRecsMarcAutDele:= {}

DEFAULT cBranchVld		:= FwCodFil()
DEFAULT cMatSRA			:= ""
DEFAULT dPerIni     	:= Ctod("//")
DEFAULT dPerFim     	:= Ctod("//")
DEFAULT lDivergent		:= .F.
DEFAULT cEmpJob			:= cEmpAnt
DEFAULT lJob			:= .F.
DEFAULT lOnlyDiv	:= .F.

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( cEmpJob, cBranchVld )
EndIf

lGetMarcAuto	:= ( SuperGetMv( "MV_GETMAUT" , NIL , "S" , cFilAnt ) == "S" )

dbSelectArea("SRA")
SRA->(dbSetOrder(1))
If SRA->(dbSeek(cBranchVld+cMatSRA))

	cFilSRA := SRA->RA_FILIAL

	cTnoSRA := SRA->RA_TNOTRAB

	//Verifica se esta sendo solicitado o periodo ou um data especifica
	If lPeriodo
		dAuxIniPer	:= dPerIni
		dAuxFimPer	:= dPerFim
	Else
		dDtRef	 := dPerIni
		aPeriods := GetPeriodApont(cBranchVld, cMatSRA, 1, dDtRef, cEmpAnt, .F.)
		If Len(aPeriods) > 0
			dAuxIniPer := aPeriods[1,1]
			dAuxFimPer := aPeriods[1,2]
		EndIf
	EndIf

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega o Calendario de Marcacoes do Funcionario            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	GetMarcacoes(	@aMarcGet			,;	//01 -> Marcacoes do Funcionario
					@aTabCalend			,;	//02 -> Calendario de Marcacoes
					@aTabPadrao			,;	//03 -> Tabela Padrao
					NIL     			,;	//04 -> Turnos de Trabalho
					dAuxIniPer			,;	//05 -> Periodo Inicial
					dAuxFimPer			,;	//06 -> Periodo Final
					SRA->RA_FILIAL		,;	//07 -> Filial
					SRA->RA_MAT			,;	//08 -> Matricula
					SRA->RA_TNOTRAB		,;	//09 -> Turno
					SRA->RA_SEQTURN		,;	//10 -> Sequencia de Turno
					SRA->RA_CC			,;	//11 -> Centro de Custo
					cAliasMarc			,;	//12 -> Alias para Carga das Marcacoes
					.T.					,;	//13 -> Se carrega Recno em aMarcacoes
					.T.		 			,;	//14 -> Se considera Apenas Ordenadas
					NIL					,;  //15 -> Verifica as Folgas Automaticas
					NIL  				,;  //16 -> Se Grava Evento de Folga Mes Anterior
					lGetMarcAuto		,;	//17 -> Se Carrega as Marcacoes Automaticas
					@aRecsMarcAutDele	,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
					NIL					,;	//19
					NIL					,;	//20
					NIL					,;	//21
					NIL					,;	//22
					.T.					,;	//23 -> Se carrega as marcacoes das duas tabelas SP8 e SPG
					)

	//Quando for uma data especifica considera somente as marcacoes dessa data
	If lPeriodo
		aMarcacoes := aClone( aMarcGet )
	ElseIf !Empty(aMarcGet)
		For nA := 1 To Len(aMarcGet)
			If aMarcGet[nA][25] == dPerIni
				Aadd(aMarcacoes, aMarcGet[nA])
			EndIf
		Next nA
	EndIf
	
	cQueryAlias := GetNextAlias()

	//A tabela da RS3 só guarda a data da batida, então considera 1 dia antes e um dia (nSoma1) depois para que as marcacoes 
	//noturnas possam ser obtidas também. No final, após a classificação o sistema irá apresentar somente as batidas do dia.
	BEGINSQL ALIAS cQueryAlias
		SELECT 
			RS3_DATA, 
			RS3_HORA, 
			RS3_STATUS, 
			RS3_JUSTIF, 
			RS3_CODIGO, 
			RH3_STATUS, 
			RS3_FILIAL, 
			RS3_LATITU, 
			RS3_LONGIT,
			RH3_EMPAPR,
			RH3_FILAPR,
			RH3_MATAPR
		FROM %table:RS3% RS3
		INNER JOIN %table:RH3% RH3 ON
			RS3_FILIAL = RH3_FILIAL AND
			RS3_CODIGO = RH3_CODIGO
		WHERE RS3_FILIAL = %exp:SRA->RA_FILIAL% AND
			RS3_MAT = %exp:SRA->RA_MAT% AND
			RS3_DATA >= %exp:DtoS(dPerIni - nSoma1)% AND
			RS3_DATA <= %exp:DtoS(dPerFim + nSoma1)% AND
			RS3.%notDel% AND RH3.%notDel% AND
			RS3_STATUS NOT IN ('3')
		ORDER BY RS3_FILIAL, RS3_MAT, RS3_DATA, RS3_HORA
	ENDSQL

	While (cQueryAlias)->(!Eof())

		//Nao considera as Marcacoes ja aprovadas pelo RH porque ja vieram em aMarcacoes
		If !(cQueryAlias)->RH3_STATUS == "2"
			aAddMarc := Array( 01, Array( ELEMENTOS_AMARC + 3 ) )

			//O atributo MOTIVRG será utilizado para guardar uma chave contendo as informacoes da requisicao
			cChave := If(RH3_STATUS $ "1|4","01","99") +"|"+ (cQueryAlias)->RS3_CODIGO +"|"+ (cQueryAlias)->RH3_STATUS +"|"+ If((cQueryAlias)->RS3_STATUS=="0","P",If((cQueryAlias)->RS3_STATUS=="2","R","A"))
			cChave += "|" + (cQueryAlias)->RS3_FILIAL

			aAddMarc[ 01, AMARC_DATA	] 	:= StoD((cQueryAlias)->RS3_DATA)
			aAddMarc[ 01, AMARC_HORA	] 	:= (cQueryAlias)->RS3_HORA
			aAddMarc[ 01, AMARC_FLAG	] 	:= "P"
			aAddMarc[ 01, AMARC_MOTIVRG	] 	:= cChave
			aAddMarc[ 01, AMARC_DTHR2STR] 	:= ""	
			aAddMarc[ 01, AMARC_TIPOREG	] 	:= ""	
			aAddMarc[ 01, AMARC_DATAAPO	] 	:= StoD((cQueryAlias)->RS3_DATA)
			aAddMarc[ 01, AMARC_LATITU ] 	:= AllTrim((cQueryAlias)->RS3_LATITU)
			aAddMarc[ 01, AMARC_LONGIT ] 	:= AllTrim((cQueryAlias)->RS3_LONGIT)
			aAddMarc[ 01, nPosEmp ] 	   	:= (cQueryAlias)->RH3_EMPAPR
			aAddMarc[ 01, nPosFil ] 	   	:= (cQueryAlias)->RH3_FILAPR
			aAddMarc[ 01, nPosMat ] 	   	:= (cQueryAlias)->RH3_MATAPR

			aAdd( aMarcRS3, aAddMarc[1] )
		EndIf

		(cQueryAlias)->(DbSkip())
	EndDo

	(cQueryAlias)->(DbCloseArea())

	//Adiciona as marcacoes manuais que ainda nao foram para o ponto
	If Len(aMarcRS3) > 0

		//Define as marcacoes que vieram do ponto como validas (01)
		aEval(aMarcacoes ,{|x| x[AMARC_MOTIVRG] := "01"})

		aMarcOrd := aClone(aMarcRS3)
		PutOrdMarc(@aMarcOrd, aTabCalend, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, lAtulizRFE)
		
		aMarcacoes := fAddMarc(aMarcRS3, aMarcOrd, aMarcacoes, aTabCalend)
	EndIf

	If !Empty(dDtRef)
		For nI := 1 To Len(aMarcacoes)
			If aMarcacoes[nI,AMARC_DATAAPO] == dDtRef
				aAdd( aAux, aMarcacoes[nI] )
			EndIf
		Next nI
		aMarcacoes := aClone(aAux)
	EndIf	

	If lDivergent
		aDivergent := fChkDivergent(cBranchVld, cMatSRA, cTnoSRA, @aMarcacoes, dAuxIniPer, dAuxFimPer, lOnlyDiv)
		lContinua  := Len(aDivergent) > 0
	Else
		lContinua  := Len(aMarcacoes) > 0
	EndIf

	//Fecha as tabelas do ponto após utilização
	Pn090Close()
EndIf

If lContinua
	
	For nI := 1 To Len(aMarcacoes)

		//Remoção de lançamentos com data de apontamento não preenchidas (AMARC_DATAAPO)
		If Empty(aMarcacoes[nI][25])
			Loop
		EndIf

		aLabelDiv := {}

		//Atribui os dados de divergencia das marcacoes (os dados irao somente na primeira batida do dia)
		If lDivergent 
			If !(dLastDiv == aMarcacoes[nI][AMARC_DATAAPO])
				If ( nPos := aScan( aDivergent, {|x| x[1] == aMarcacoes[nI][25] } ) ) == 0
					Loop
				Else
					dLastDiv := aDivergent[nPos,1]
					
					For nA := nPos To Len( aDivergent )					
						If aDivergent[nA,1] == aMarcacoes[nI][25]
							oLabelDiv := JsonObject():New()
							oLabelDiv["type"]  := aDivergent[nA,2]
							oLabelDiv["label"] := aDivergent[nA,3] 
							aAdd( aLabelDiv, oLabelDiv )
						Else
							Exit
						EndIf
					Next nA				
				EndIf
			EndIf			
		EndIf

		If ( lRegRS3 := Empty( aMarcacoes[nI, AMARC_TIPOREG] ) )
			aIdReq 		:= STRTOKARR(aMarcacoes[nI, AMARC_MOTIVRG], "|")
			cRH3Cod 	:= aIdReq[2]
			cRH3Status 	:= aIdReq[3]
			cRS3Status 	:= aIdReq[4]
			cFilRS3		:= aIdReq[5]
			cID 		:= cValToChar(nI) + If( !Empty(cRH3Cod), "|"+ cRH3Cod, "" )
		Else
			cRH3Cod 	:= ""
			cRH3Status 	:= ""
			cRS3Status 	:= ""
			cID 		:= cValToChar(nI)
		EndIf

		cLatitu	:= AllTrim( aMarcacoes[nI][AMARC_LATITU] )
		cLongit	:= AllTrim( aMarcacoes[nI][AMARC_LONGIT] )
		lIsGeo 	:= !Empty(cLatitu)

		If Len(aMarcacoes[nI]) < ( ELEMENTOS_AMARC + 3 )
			aAdd( aMarcacoes[nI], NIL ) // Adiciona posição da empresa do aprovador
			aAdd( aMarcacoes[nI], NIL ) // Adiciona posição da filial do aprovador
			aAdd( aMarcacoes[nI], NIL ) // Adiciona posição da matrícula do aprovador
		EndIf

		oClockings := JsonObject():New()

		oClockings["id"]			:= cID

		aDateGMT 					:= LocalToUTC( DTOS(aMarcacoes[nI][AMARC_DATAAPO]), "12:00:00" )
		oClockings["date"]			:= Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		aDateGMT := {}

		oClockings["origin"] 		:= fRetTpFlag( aMarcacoes[nI][AMARC_FLAG], lIsGeo )

		oClockings["hasCoordinates"]:= lIsGeo

		If lIsGeo
			oClockings["latitude"]		:= cLatitu
			oClockings["longitude"]		:= cLongit
		EndIf

		//Caso tenha dados da RH3 busca a justificativa.
		If !Empty(cRH3Cod) .And. cRH3Status == "3"
			oClockings["reasonReproved"] := AllTrim(GetRGKJustify(xFilial("RGK", cFilSRA), cRH3Cod, ,.T.))
		EndIf

		aDateGMT 					:= LocalToUTC( DTOS(aMarcacoes[nI][AMARC_DATAAPO]), "12:00:00" )
		oClockings["referenceDate"] := Iif(Empty(aDateGMT),"",Substr(aDateGMT[1],1,4) + "-" + Substr(aDateGMT[1],5,2) + "-" + Substr(aDateGMT[1],7,2) + "T" + "12:00:00" + "Z")
		aDateGMT := {}

		oClockings["hour"]			:= iif( aMarcacoes[nI][AMARC_HORA] == NIL,;
											NIL,;
											HourToMs(strZero(aMarcacoes[nI][AMARC_HORA], 5, 2) ) )
		
		oClockings["justify"] 		:= NIL
		If Len( aCposRH4 := fGetRH4Cpos(cFilRS3, cRH3Cod) ) > 0
			If ( nPosRH4 := aScan( aCposRH4, { |x| AllTrim(x[1]) == "TMP_TEXT" } ) ) > 0
				oClockings["justify"] := EncodeUTF8( AlLTrim(aCposRH4[nPosRH4,2]) )
			EndIf
		EndIf

		//Controle de direcao e sequencia da batida (sequencia por pares)
		//1E e 1S ==> sequencia 1,1 respectivamente (sequencia por pares)
		//2E e 2S ==> sequencia 2,2 respectivamente
		If !dLastDt == aMarcacoes[nI, AMARC_DATAAPO]
			nCount  := 1
			aSequen := {}
			aAdd( aSequen, { "1", "" } )
		Else
			nCount ++
			nPos   := Len( aSequen )
			
			If nPos > 0 .And. Empty( aSequen[nPos,2] )
				aSequen[nPos,2] := "1"
			Else
				aAdd( aSequen, { "1", "" } )
			EndIf
		EndIf
		
		oClockings["direction"]	:= If( nCount % 2 == 0, "exit", "entry" )
		oClockings["sequence"]  := Len( aSequen )

		//Dados do aprovador, caso exista.
		If !Empty( aMarcacoes[nI,nPosFil] ) .And. ;
		   !Empty( aMarcacoes[nI,nPosMat] )
			cIdAprv := If( !Empty(aMarcacoes[nI,nPosEmp]),;
							aMarcacoes[nI,nPosEmp], ;
							cEmpAnt);
							+ "|" + aMarcacoes[nI,nPosFil] + "|" + ;
							aMarcacoes[nI,nPosMat]
			cNomeAprv := fGetRANome( aMarcacoes[nI,nPosFil], aMarcacoes[nI,nPosMat], aMarcacoes[nI,nPosEmp] )
			oClockings["responsableId"] := cIdAprv
			oClockings["responsableName"] := cNomeAprv
		Else
			oClockings["responsableId"] := NIL
			oClockings["responsableName"] := NIL
		EndIf

		If lRegRS3
			//Solicitacao em processo de aprovacao
			If !cRH3Status == "3"
				Do Case
					Case cRS3Status == "P"
						cRetStatus	:= "approving"
						cLabStatus	:= STR0013 //"Aguardando aprovação"
					Case cRS3Status == "A"
						cRetStatus	:= "approved"
						cLabStatus	:= STR0014 //"Aprovada"
				End Case
			Else
				//Somente as solicitacoes reprovadas pelo gestor ficam demonstradas no App
				cRetStatus	:= "reproved"
				cLabStatus	:= STR0015 //"Reprovada"
			EndIf
		Else
			//Incluido status para todas as demais marcacoes para desabilitar as opcoes de edicao
			cRetStatus	:= "approved"
			cLabStatus	:= STR0014 //"Aprovada"
		EndIf
	
		oStatus := JsonObject():New()
		oStatus["id"]        := if( oClockings["hour"] <> NIL, cID, NIL )
		oStatus["status"]    := If( oClockings["hour"] <> NIL, EncodeUTF8(cRetStatus), NIL )
		oStatus["label"]     := If( oClockings["hour"] <> NIL, EncodeUTF8(cLabStatus), NIL )
		oClockings["status"] := oStatus

		oClockings["divergent"] := aLabelDiv

		dLastDt	:= aMarcacoes[nI, AMARC_DATAAPO]

		Aadd(aData,oClockings)

	Next nI

	FreeObj(oStatus)
	FreeObj(oClockings)
EndIf

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

Return(aData)

/*/{Protheus.doc} fRetTpFlag
Retorna a descrição do tipo da marcação conforme o Flag
@author:	Marcelo Silveira
@since:		04/04/2019
@param:		cFlag - Flag da marcacao;
			lIsGeo - Verdadeiro se a marcacao foi incluida por Geolocalizacao;
@return:	cRet - descricao do tipo da marcacao conforme o flag.
/*/
Function fRetTpFlag( cFlag, lIsGeo )

Local cRet := "empty"

DEFAULT cFlag := ""
DEFAULT lIsGeo  := .F.

//Tipo da marcação conforme o Flag
If !Empty(cFlag)

	//Quando incluída via App o tipo sempre será manual
	If lIsGeo
		cRet := "geolocation"
	Else
		Do Case
			Case cFlag $ "E"
				 cRet := "clock" 	//Lidas e gravadas através do relógio.
			Case cFlag $ "I|P"
				cRet := "manual" 	//Informadas (manual)
			Case cFlag $ "A|G"
				cRet := "automatic" //Automática ou Gerada.
			OtherWise
				cRet := "empty"
		End Case
	EndIf
EndIf

Return(cRet)

/*/{Protheus.doc} GetPeriodApont
Retorna os periodos de apontamento
@author:	Matheus Bizutti
@since:		12/04/2017
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			nNumPer - Numero de períodos que serao retornados;
@return:	Array - periodos de apontamento.
/*/
Function GetPeriodApont(cBranchVld, cMatSRA, nNumPer, dDate, cEmpJob, lJob, cUID )

	Local aData 		:= {}
	Local aPerSPO 		:= {}
	Local nLenPer		:= 0
	Local nDiasSum		:= 0
	Local dDtIni		:= cTod("//")
	Local dDtFim		:= cTod("//")

	Private dDtRobot	:= Ctod("//")
	
	Default cBranchVld	:= FwCodFil()
	Default cMatSRA		:= Nil
	Default nNumPer		:= 1
	Default cEmpJob		:= cEmpAnt
	Default lJob		:= .F.
	Default dDate		:= cTod("//")

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cEmpJob, cBranchVld )
	EndIf

	//Ao retornar o historico de periodos considera dados da SPO
	If nNumPer > 1
		aPerSPO	:= fPerSPO(cEmpJob, cBranchVld)
	EndIf

	dDate := If( Empty(dDate), dDataBase, dDate )

	dDate := Iif( !Empty( dDtRobot ), dDtRobot, dDate )

	aData := GetPerAponta( nNumPer, cBranchVld, cMatSRA, .F., , , aPerSPO )

	nLenPer := Len(aData)

	nDiasSum := GetMvMrh("MV_MRHDPER", .F., 0, cBranchVld) // Conteudo do parâmetro

	If nDiasSum > 0 .And. nLenPer > 0 .And. dDate >= DaySum( aData[nLenPer,2] , nDiasSum ) 
		If PerAponta(@dDtIni, @dDtFim, dDate, .F., cBranchVld, .T., , , , .F. )
			aAdd(aData, { dDtIni, dDtFim })
			aDel(aData, 1)
			aSize(aData, IIf(nLenPer < nNumPer, nLenPer, nNumPer) )
		EndIf
	EndIf

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Pn090Close()

Return( aData )


/*/{Protheus.doc}GetJustification
Verifica se ja existe abono cadastrado para o dia o funcionario no dia/hora informado
@author:	Marcelo Silveira
@since:		18/02/2019
@param:		cFilSra - Filial;
			cMatSra - Matrícula;
			cInitDate - Data inícial do Abono;
			cEndDate - Data final do Abono;
			cInitHour - Hora inicial do Abono
			cEndHour - Hora final do Abono;
			cKeyUpd - Codigo do registro que esta sendo alterado (nao considera esse registro);
@return:	lRet - Se não tiver abono cadastrado será verdadeiro.
/*/
Function GetJustification( cFilSra, cMatSra, cInitDate, cEndDate, cInitHour, cEndHour, cKeyUpd )

Local cAliasQry  := GetNextAlias()
Local cAliasAux1 := GetNextAlias()
Local lRet 	   	 := .T.
Local nHorIni	 := ''
Local nHorFim    := ''
Local dDataIni	 := ''
Local dDataFim	 := ''
Local cFiltro	 := '%%'

DEFAULT cKeyUpd	 := ''

If !Empty( cKeyUpd )
	cFiltro := "% AND RH3_CODIGO <> '" + cKeyUpd +"' %"
EndIf

BeginSql alias cAliasQry
	SELECT RH3.RH3_FILIAL, RH3.RH3_CODIGO, RH3.RH3_STATUS
	FROM  %table:RH3% RH3
	WHERE
		RH3.RH3_FILIAL = %exp:cFilSra% AND
		RH3.RH3_MAT = %exp:cMatSra% AND
    	RH3.RH3_TIPO = '8' AND
		RH3.%notDel% AND
		RH3.RH3_STATUS != '3'
		%exp:cFiltro%
EndSql

If !Empty(cAliasQry)
	While !(cAliasQry)->(Eof())

		BeginSql alias cAliasAux1
			SELECT *
			FROM  %table:RH4% RH4
			WHERE
				RH4.RH4_CODIGO = %exp:(cAliasQry)->RH3_CODIGO% AND
				(RH4.RH4_CAMPO = "RF0_DTPREI" OR
				RH4.RH4_CAMPO = "RF0_DTPREF" OR
				RH4.RH4_CAMPO = "RF0_HORINI" OR
				RH4.RH4_CAMPO = "RF0_HORFIM") AND
				RH4.%notDel%
		EndSql

		dDataIni	:= ''
		dDataFim	:= ''
		nHorIni	    := ''
		nHorFim	    := ''
		If !Empty(cAliasAux1)
			While !(cAliasAux1)->(Eof())
				If (cAliasAux1)->RH4_CAMPO = "RF0_DTPREI"
					dDataIni := CTOD((cAliasAux1)->(RH4_VALNOV))
				EndIf
				If (cAliasAux1)->RH4_CAMPO = "RF0_DTPREF"
					dDataFim := CTOD((cAliasAux1)->(RH4_VALNOV))
				EndIf
				If (cAliasAux1)->RH4_CAMPO = "RF0_HORINI"
					nHorIni := Val((cAliasAux1)->(RH4_VALNOV))
				EndIf

				If (cAliasAux1)->RH4_CAMPO = "RF0_HORFIM"
					nHorFim := Val((cAliasAux1)->(RH4_VALNOV))
				EndIf

				(cAliasAux1)->(DBSkip())
			Enddo
		EndIf

		If (cInitDate >= dDataIni .AND. cEndDate <= dDataFim) .OR. ;
		(cEndDate >= dDataIni .AND. cEndDate <= dDataFim)
			If (cInitHour >= nHorIni .AND. cInitHour <= nHorFim) .OR. ;
			(cEndHour > nHorIni .AND. cEndHour <= nHorFim)
				lRet := .F.
				(cAliasAux1)->(DBCloseArea())
				Exit
			EndIf
		EndIf
		(cAliasAux1)->(DBCloseArea())
		(cAliasQry)->(DBSkip())
	Enddo
	(cAliasQry)->(DBCloseArea())
EndIf

Return(lRet)


/*/{Protheus.doc} fGetClockType
Carrega os motivos para inclusao de marcacao manual
@author:	Marcelo Silveira
@since:		18/02/2019
@param:		cBranchVld - Filial;
			aData - Matriz de referencia para retorno dos dados;
@return:	Nulo
/*/
Function fGetClockType(cEmp, cBranchVld, cType, lJob, cUID)

	Local cBrchRFD		:= ""
	Local oClockType	:= Nil
	Local aData         := {}
	Local cQuery		:= ""
	Local lAllReason	:= .T.
	Local cAplic		:= "1"
	Local cSistem		:= "2"
	Local cAliasRFD		:= ""

	Default cBranchVld	:= FwCodFil()
	Default cType       := "1"
	Default cEmp        := cEmpAnt
	Default cUID        := ""
	Default lJob        := .F.

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cEmp, cBranchVld )
	EndIf

	cAliasRFD  := GetNextAlias()
	cBrchRFD   := xFilial("RFD", cBranchVld)
	lAllReason := SuperGetMv("MV_MRHRFD", NIL , .T., cBranchVld )

	cQuery := "SELECT RFD_CODIGO, RFD_DESC"
	cQuery += " FROM" + RetFullName("RFD", cEmp) + " RFD"
	cQuery += " WHERE RFD.RFD_FILIAL = '" + cBrchRFD + "'"
	cQuery += " AND RFD.RFD_APLIC = '" + cAplic + "'"
	cQuery += " AND RFD.RFD_TIPO = '" + cType + "'"
	If !lAllReason
		cQuery += " AND RFD.RFD_SISTEM = '" + cSistem + "'"
	EndIf
	cQuery += " AND RFD.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRFD,.T.,.T.)

	If !Empty(cAliasRFD)
		While !(cAliasRFD)->(Eof())

			oClockType 					:= JsonObject():New()
			oClockType["id"]			:= EncodeUTF8((cAliasRFD)->RFD_CODIGO)
			oClockType["description"]	:= EncodeUTF8( AllTrim((cAliasRFD)->RFD_DESC) )

			aAdd(aData, oClockType)
			oClockType := Nil

			(cAliasRFD)->(dbSkip())
		EndDo
	EndIf

	(cAliasRFD)->(dbCloseArea())

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return aData


Function fSetGeoClocking(cBody,oItem,oItemDetail,cToken,cMsg,cKeyId)

Local cApprover				:= ""
Local cVision	 			:= ""
Local cEmpApr				:= ""
Local cFilApr				:= ""
Local cTitTurno				:= ""
Local cTitSeq				:= ""
Local cTitRegra				:= ""
local cDtMarc				:= ""
Local cJustify				:= ""
Local nSupLevel				:= 0
Local nRet					:= 0
Local aVision				:= {}
Local aGetStruct			:= {}
Local aHorTmz				:= {}
Local aMSToHour 			:= Array(02)
Local aMSToHourRefer		:= Array(02)
Local aDataLogin			:= {}
Local cTypeReq				:= "Z"
Local cRoutine				:= "W_PWSA400.APW" //Marcação de Ponto: Utilizada para buscar a VISÃO a partir da rotina; (AI8_VISAPV) na função GetVisionAI8().
Local cMsgReturn 			:= EncodeUTF8(STR0029) //"Dados atualizados com sucesso."
Local cBranchVld			:= FwCodFil()
Local oRequest				:= Nil
Local oAttendControlRequest	:= Nil
Local nHour                 := Seconds()*1000
Local lRet                  := .T.
Local lUpdRH3				:= .T.
Local lRobot				:= .F.
Local lCamposTZ				:= RS3->(ColumnPos("RS3_TMZ")) > 0 .And. RS3->(ColumnPos("RS3_DTREF")) > 0 .And. RS3->(ColumnPos("RS3_HRREF")) > 0 // Novos campos timezone
Local dDate					:= ctod("//")

Default cBody				:= ""
Default oItem 	 			:= JsonObject():New()
Default oItemDetail			:= JsonObject():New()
Default cToken				:= ""
Default cMsg				:= ""
Default cKeyId				:= ""

oRequest					:= WSClassNew("TRequest")
oRequest:RequestType		:= WSClassNew("TRequestType")
oRequest:Status				:= WSClassNew("TRequestStatus")
oAttendControlRequest		:= WSClassNew("TAttendControl")

aDataLogin := GetDataLogin(cToken,,cKeyId)
If Len(aDataLogin) > 0
	cMatSRA	   := aDataLogin[1]
	cRD0Cod    := aDataLogin[3]
	cBranchVld := aDataLogin[5]	
EndIf

If !Empty(cBody)

	//Verifica se existem inconsistencias no cadastro do funcionario
	DbSelectArea("SRA")
	If ( lRet := SRA->(dbSeek(cBranchVld + cMatSRA)) )
		cNome := AllTrim(SRA->RA_NOME)
		If Empty(SRA->RA_TNOTRAB) .Or. Empty(SRA->RA_SEQTURN) .Or. Empty(SRA->RA_REGRA)
			lRet		:= .F.
			cTitTurno	:= GetSx3Cache("RA_TNOTRAB", "X3_TITULO")
			cTitSeq		:= GetSx3Cache("RA_SEQTURN", "X3_TITULO")
			cTitRegra	:= GetSx3Cache("RA_REGRA", "X3_TITULO")
			cMsg 		:= EncodeUTF8(STR0041) +" ("+ cTitTurno +"), ("+ cTitSeq +"), ("+ cTitRegra + ")" //"O cadastro do funcionario está incompleto. Verifique os campos:"
		EndIf
	EndIf

	If lRet
		oItemDetail:FromJson(cBody)

		// ----------------------------------------------
		// - A Função GetVisionAI8() devolve por padrão
		// - Um Array com a seguinte estrutura:
		// - aVision[1][1] := "" - AI8_VISAPV
		// - aVision[1][2] := 0  - AI8_INIAPV
		// - aVision[1][3] := 0  - AI8_APRVLV
		// - Por isso as posição podem ser acessadas
		// - Sem problemas, ex: cVision := aVision[1][1]
		// ----------------------------------------------
		aVision := GetVisionAI8(cRoutine, cBranchVld)
		cVision := aVision[1][1]
	
		// -------------------------------------------------------------------------------------------
		// - Efetua a busca dos dados referentes a Estrutura Oreganizacional dos dados da solicitação.
		//- -------------------------------------------------------------------------------------------
		 cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
		 aGetStruct := APIGetStructure(cRD0Cod, ;
		 							   SUPERGETMV("MV_ORGCFG"), ;
									   cVision, ;
									   cBranchVld, ;
									   cMatSRA,;
									   NIL ,;
									   NIL ,;
									   NIL ,;
									   cTypeReq,;
									   cBranchVld,;
									   cMatSRA,;
									   NIL ,;
									   NIL ,;
									   NIL ,;
									   NIL ,;
									   .T., ;
									   {cEmpAnt},;
									   NIL,;
									   NIL,;
									   .T.,;
									   NIL)
	
		 If Len(aGetStruct) >= 1 .And. !(Len(aGetStruct) == 3 .And. !aGetStruct[1])
		 	cEmpApr   := aGetStruct[1]:ListOfEmployee[1]:SupEmpresa
		 	cFilApr   := aGetStruct[1]:ListOfEmployee[1]:SupFilial
		 	nSupLevel := aGetStruct[1]:ListOfEmployee[1]:LevelSup
		 	cApprover := aGetStruct[1]:ListOfEmployee[1]:SupRegistration
		 EndIf
	
		//Verifica se o dia mudou para atualizar a variável dDataBase
		FwDateUpd(.F., .T.)		

		cJustify	:= STR0035                     				//"Batida por GeoLocalização"
		aMsToHour	:= milisSecondsToHour(nHour,nHour)
		lRobot		:= If(oItemDetail:hasProperty("execRobo"), oItemDetail["execRobo"], "0") == "1"
		dDate		:= If( !lRobot, dDataBase, ctod(Format8601(.T., oItemDetail["date"]) ) )
		cDtMarc		:= FwTimeStamp(6, dDate, "12:00:00" )	//Data da inclusão
	
		oRequest:Branch						:= cBranchVld
		oRequest:StarterBranch				:= cBranchVld
		oRequest:StarterRegistration		:= cMatSRA
		oRequest:Registration				:= cMatSRA
		oRequest:Empresa					:= cEmpAnt
		oRequest:Vision						:= cVision
	
		oAttendControlRequest:Branch  		:= cBranchVld
		oAttendControlRequest:Registration	:= cMatSRA
		oAttendControlRequest:Name			:= cNome
		oAttendControlRequest:Observation  	:= cJustify
		oAttendControlRequest:Latitude		:= oItemDetail["latitude"]
		oAttendControlRequest:Longitude		:= oItemDetail["longitude"]

		//Na execucao do Robo de testes considera o horario veio no body da requisicao
		If lRobot .And. !Empty(oItemDetail["hour"])
			aMsToHour	:= milisSecondsToHour(oItemDetail["hour"],oItemDetail["hour"])
		EndIf

		If !empty(oItemDetail["timezone"])
			If lCamposTZ 
				aMsToHourRefer := milisSecondsToHour(oItemDetail["hour"],oItemDetail["hour"])

				oAttendControlRequest:Timezone		:= oItemDetail["timezone"]
				oAttendControlRequest:DateRefer		:= Format8601(.T.,oItemDetail["date"])
				oAttendControlRequest:HourRefer		:= cValToChar(NoRound(aMsToHourRefer[1],2))
			EndIf

			If !lRobot
				aHorTmz := fGetTimezone(oItemDetail["timezone"])
			Else
				aAdd(aHorTmz, oItemDetail["date"] )
				aAdd(aHorTmz, oItemDetail["hour"] )
			EndIf
			If empty(aHorTmz)
				lRet := .F.
				cMsg := EncodeUTF8(STR0064) //"Ocorreu um problema na verificação do timezone para marcação"
			Else
				aMsToHour := milisSecondsToHour(aHorTmz[2],aHorTmz[2])
				oAttendControlRequest:Date	:= Format8601(.T.,aHorTmz[1])  
				oAttendControlRequest:Hour	:= cValToChar(NoRound(aMsToHour[1],2))
			EndIf
		Else
			oAttendControlRequest:Date		:= Format8601(.T.,cDtMarc)
			oAttendControlRequest:Hour		:= cValToChar(NoRound(aMsToHour[1],2))
		EndIf

		If lRet
			BEGIN TRANSACTION
				lRet := AddAttendControlRequest(oRequest, oAttendControlRequest, .T., @cMsgReturn, STR0038, .T. ) //"MEURH"
				
				If lRet
					nRet := fAprovPon( cBranchVld, cMatSRA, oRequest:Code, @cMsg, , lUpdRH3 )
					If nRet # 0
						cMsg := If( !Empty(cMsg), EncodeUTF8(cMsg), EncodeUTF8(STR0040) ) //"A batida está fora do período permitido para inclusão!" 
						lRet := .F.
						DisarmTransaction()
						Break
					EndIf
				Else
					cMsg := cMsgReturn
					DisarmTransaction()
					Break
				EndIf
				
			END TRANSACTION
		EndIf	

	EndIf
Else
	lRet := .F.
	cMsg := EncodeUTF8(STR0034) //"Falta recursos para se processar essa requisição. É necessário atualizar o sistema para a expedição mais recente."
EndIf

Pn090Close()

Return lRet


Function GetDayClocks(cBranchVld, cMatSRA )

    Local cAlias      	:= GetNextAlias()
    local aClockings  	:= {}
    Local oClocking   	:= Nil
    Local cDirection  	:= ""
	Local lGetMarcAuto	:= ( SuperGetMv( "MV_GETMAUT" , NIL , "S" , cBranchVld ) == "S" )
	Local aPadrao		:= {}
	Local aCalend		:= {}
	Local aAddMarc		:= {}
	Local aMarcRS3		:= {}
	Local aMarcOrd		:= {}
	Local aMarcacoes	:= {}
	Local nX			:= 0
	Local dIniPer		:= ctod("//")
	Local dFimPer		:= ctod("//")
	Local nCount		:= 0
	Local dDtLast		:= ctod("//")

    Default cBranchVld		:= FwCodFil()
    Default cMatSRA			:= ""

	//Verifica se o dia mudou para atualizar a variável dDataBase
	FwDateUpd(.F., .T.)

    dbSelectArea("SRA")
    SRA->(dbSetOrder(1))
    If SRA->( dbSeek( cBranchVld + cMatSRA ) )
		
		PerAponta(@dIniPer, @dFimPer, dDataBase, .F., cBranchVld, .T., , , , .F. )

		GetMarcacoes(@aMarcacoes		,;	//01 -> Marcacoes do Funcionario
					@aCalend			,;	//02 -> Calendario de Marcacoes
					@aPadrao			,;	//03 -> Tabela Padrao
					NIL     			,;	//04 -> Turnos de Trabalho
					dIniPer				,;	//05 -> Periodo Inicial
					dFimPer				,;	//06 -> Periodo Final
					SRA->RA_FILIAL		,;	//07 -> Filial
					SRA->RA_MAT			,;	//08 -> Matricula
					SRA->RA_TNOTRAB		,;	//09 -> Turno
					SRA->RA_SEQTURN		,;	//10 -> Sequencia de Turno
					SRA->RA_CC			,;	//11 -> Centro de Custo
					"SP8"			    ,;	//12 -> Alias para Carga das Marcacoes
					.T.					,;	//13 -> Se carrega Recno em aMarcacoes
					.T.		 			,;	//14 -> Se considera Apenas Ordenadas
					NIL					,;  //15 -> Verifica as Folgas Automaticas
					NIL  				,;  //16 -> Se Grava Evento de Folga Mes Anterior
					lGetMarcAuto		,;	//17 -> Se Carrega as Marcacoes Automaticas
					NIL					,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
					NIL					,;	//19
					NIL					,;	//20
					NIL					,;	//21
					NIL					,;	//22
					.F.					,;	//23 -> Se carrega as marcacoes das duas tabelas SP8 e SPG
					)


        BEGINSQL ALIAS cAlias
            SELECT  RS3_DATA,
                    RS3_HORA,
                    RS3_STATUS,
                    RS3_JUSTIF,
                    RS3_CODIGO,
                    RS3_LATITU,
                    RS3_LONGIT
                  FROM %table:RS3% RS3
              WHERE RS3_FILIAL = %exp:SRA->RA_FILIAL%
                AND RS3_MAT    = %exp:SRA->RA_MAT%
                AND RS3_DATA   >= %exp:DtoS(DaySub(dDataBase,1))%
				AND RS3_DATA   <= %exp:DtoS(dDataBase)%
                AND RS3_STATUS = '0'
                AND RS3.%notDel%
            ORDER BY RS3_FILIAL, RS3_MAT, RS3_DATA, RS3_HORA
        ENDSQL

        While (cAlias)->(!Eof())
			aAddMarc := Array( 01, Array( ELEMENTOS_AMARC + 3 ) )
			aAddMarc[ 01, AMARC_DATA	] 	:= StoD((cAlias)->RS3_DATA)
			aAddMarc[ 01, AMARC_HORA	] 	:= (cAlias)->RS3_HORA
			aAddMarc[ 01, AMARC_DATAAPO	] 	:= StoD((cAlias)->RS3_DATA)
			aAddMarc[ 01, AMARC_LATITU ] 	:= AllTrim((cAlias)->RS3_LATITU)
			aAddMarc[ 01, AMARC_LONGIT ] 	:= AllTrim((cAlias)->RS3_LONGIT)
			aAddMarc[ 01, AMARC_MOTIVRG]	:= "01" + "|" + (cAlias)->RS3_CODIGO + "|" + (cAlias)->RS3_STATUS + "P"
			aAddMarc[ 01, AMARC_FLAG	] 	:= "P"
			aAddMarc[ 01, AMARC_DTHR2STR] 	:= ""	
			aAddMarc[ 01, AMARC_TIPOREG	] 	:= ""	

			aAdd( aMarcRS3, aAddMarc[1] )
			(cAlias)->(DbSkip())
        EndDo
        (cAlias)->(DbCloseArea())

		If Len(aMarcRS3) > 0
			aEval(aMarcacoes ,{|x| x[AMARC_MOTIVRG] := "01"})
			aMarcOrd := aClone(aMarcRS3)
			PutOrdMarc(@aMarcRS3, aCalend, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL)
			aMarcacoes := fAddMarc(aMarcRS3, aMarcOrd, aMarcacoes, aCalend)
		EndIf

		If Len(aMarcacoes) > 0
			For nX := 1 To Len(aMarcacoes)
				If !( dDtLast == aMarcacoes[nX,AMARC_DATAAPO] )
					nCount := 1
				Else
					nCount ++
				EndIf
				cDirection := if( nCount % 2 == 0, "exit", "entry")
				If aMarcacoes[nX, AMARC_DATA] == dDataBase .And. ;
				   !Empty(aMarcacoes[nX,AMARC_LATITU]) .And. ;
				   !Empty(aMarcacoes[nX,AMARC_LONGIT])
					oClocking := JsonObject():New()
					oClocking["date"]	   := FwTimeStamp(6, aMarcacoes[nX, AMARC_DATA], "12:00:00" )
					oClocking["hour"]	   := HourToMs(StrZero(aMarcacoes[nX, AMARC_HORA], 5, 2))
					oClocking["latitude"]  := aMarcacoes[nX, AMARC_LATITU]
					oClocking["longitude"] := aMarcacoes[nX, AMARC_LONGIT]
					oClocking["direction"] := cDirection

					Aadd( aClockings, oClocking )
				EndIf
				dDtLast := aMarcacoes[nX,AMARC_DATAAPO]
			Next nX
    	EndIf
		Pn090Close()
	EndIf

Return aClockings

Function getGeoClockings(cBranchVld,cMatSRA,dPerIni,dPerFim,cEmpTeam)

    Local cAlias      	:= GetNextAlias()
    local aClockings  	:= {}
    Local oClocking   	:= Nil
	Local __cTabRS3   	:= ""
	Local __cTabRH3   	:= ""
	Local __cTabSP8   	:= ""

    Default cBranchVld	:= FwCodFil()
    Default cMatSRA		:= ""
    Default dPerIni     := Ctod("//")
    Default dPerFim     := Ctod("//")
    Default cEmpTeam    := cEmpAnt

	__cTabRS3   := "%" + RetFullName("RS3", cEmpTeam) + "%"
	__cTabRH3   := "%" + RetFullName("RH3", cEmpTeam) + "%"
	__cTabSP8   := "%" + RetFullName("SP8", cEmpTeam) + "%"

	BEGINSQL ALIAS cAlias
		SELECT RH3_FILIAL,
				RS3_DATA,
				RS3_HORA,
				RS3_STATUS,
				RS3_JUSTIF,
				RS3_CODIGO,
				RH3_STATUS,
				RS3_LATITU,
				RS3_LONGIT,
				P8_TPMCREP,
				P8_MOTIVRG
		FROM %exp:__cTabRS3% RS3
		INNER JOIN %exp:__cTabRH3% RH3			
				ON RS3_FILIAL = RH3_FILIAL
			AND RS3_CODIGO = RH3_CODIGO
			AND RH3.%notDel%
		INNER JOIN %exp:__cTabSP8% SP8			
			ON RS3_FILIAL = P8_FILIAL
			AND RS3_MAT = P8_MAT
			AND RS3_DATA = P8_DATA
			AND RS3_HORA = P8_HORA
			AND SP8.%notDel%
			WHERE RS3_FILIAL  = %exp:cBranchVld%
			AND RS3_MAT     = %exp:cMatSRA%
			AND RS3_DATA   >= %exp:DtoS(dPerIni)%
			AND RS3_DATA   <= %exp:DtoS(dPerFim)%
			AND RS3_LATITU <> ' '
			AND RS3_LONGIT <> ' '
			AND RS3_STATUS NOT IN ('3')
			AND RS3.%notDel%
		ORDER BY RS3_FILIAL, RS3_MAT, RS3_DATA, RS3_HORA
	ENDSQL

	While (cAlias)->(!Eof())

		//So considera os registros rejeitados do Status 2 = Reprovados pelo gestor
		//Registros rejeitados com qualquer outro status nao devem ser exibidos
		If (cAlias)->P8_TPMCREP == "D".And. (cAlias)->RS3_STATUS <> '2'
			(cAlias)->(DbSkip())
			Loop
		EndIf

		oClocking := JsonObject():New()

		oClocking["id"]	          := (cAlias)->RS3_CODIGO
		oClocking["disconsider"]  := ( (cAlias)->RS3_STATUS == "2" .Or. (cAlias)->P8_TPMCREP == 'D' )
		oClocking["date"]	      := FwTimeStamp(6, SToD((cAlias)->RS3_DATA), "12:00:00" )
		oClocking["justify"]	  := EncodeUTF8((cAlias)->RS3_JUSTIF)
		oClocking["latitude"]	  := (cAlias)->RS3_LATITU
		oClocking["longitude"]	  := (cAlias)->RS3_LONGIT
		oClocking["hour"]	      := HourToMs(StrZero((cAlias)->RS3_HORA, 5, 2))

		If oClocking["disconsider"]
			oClocking["justify"] := EncodeUTF8(ALLTRIM( (cAlias)->P8_MOTIVRG ) )
		EndIf

		Aadd( aClockings, oClocking )
		(cAlias)->(DbSkip())
	EndDo

    (cAlias)->(DbCloseArea())

	Pn090Close()

Return aClockings


Function UpdGeoClock(cBranchVld, cMatSRA, cBody, oItem, cMsg, cEmpSra )
    Local oClocking := JsonObject():New()
    Local cMotivo   := ""
    Local cCodRH3   := ""
    Local lRet      := .F.
	
	DEFAULT cEmpSra	:= cEmpAnt

    oClocking:FromJson( cBody )

    cMotivo := If( oClocking:hasProperty("justify"), oClocking["justify"], "" )
    cCodRH3 := If( oClocking:hasProperty("id"), oClocking["id"], "" )    

    If !Empty( cCodRH3 )
     	If !Empty( cMotivo )
	        If TCFA40Rej( cMotivo, cBranchVld, cCodRH3, cMatSRA, cEmpSra )
	            oItem := oClocking
	            lRet  := .T.
	        EndIf
	    Else
	    	cMsg := EncodeUTF8(STR0039) //"O campo justificativa deve ser informado!"
	    EndIf
    Else
    	cMsg := EncodeUTF8(STR0036) //"Essa batida não foi desconsiderada porque não foram localizados os dados da requisição original."	
    EndIf

Return lRet

/*/{Protheus.doc} fSumOccurPer
Retorna o resumo das ocorrências do período/diario do colaborador.
@author:	Marcelo Silveira
@since:		10/06/2019
@param:		cEmpFunc - Empresa;
			cBranchVld - Filial;
			cMatSRA - Matricula;
			cPerIni - Data inicio do periodo a ser pesquisado;
			cPerFim - Data Fim do periodo a ser pesquisado;
			lSexagenal - Se calcula em formato sexagesimal ou centensimal;
@return:	Array - eventos do banco de horas do periodo
/*/
Function fSumOccurPer( cEmpFunc, cBranchVld, cMatSRA, cPerIni, cPerFim, lSexagenal )

Local aArea			:= {}
Local aEventos		:= {}
Local aPeriods		:= {}
Local cDtIni		:= ""
Local cDtFim		:= ""
Local cCod			:= ""
Local cAliasQry		:= ""
Local cWhere 		:= ""
Local cJoinFil 		:= ""
Local cAliasAux 	:= ""
Local cPrefixo		:= ""
Local cDescEve		:= ""
Local cSPCtab		:= ""
Local cSPHtab		:= ""
Local cSP9tab		:= ""
Local dIniPonMes	:= cToD("//")
Local dFimPonMes	:= cToD("//")
Local nSaldo		:= 0
Local nSaldoAux		:= 0
Local lImpAcum		:= .T.

DEFAULT lSexagenal	:= .T.

cDtIni 		:= StrTran( SubStr(cPerIni, 1, 10), "-", "" )
cDtFim 		:= StrTran( SubStr(cPerFim, 1, 10), "-", "" )

If !Empty(cDtIni) .And. !Empty(cDtFim)

	aArea		:= GetArea()
	cAliasQry	:= GetNextAlias()

	aPeriods := GetDataForJob( "1", {cBranchVld, , 1}, cEmpFunc )
	If Len(aPeriods) > 0
		dIniPonMes := aPeriods[1,1]
		dFimPonMes := aPeriods[1,2]
	EndIf

	lImpAcum := If(sTod(cDtFim) < dIniPonMes, fVerAcum(cEmpFunc, cBranchVld, cMatSRA, cDtIni, cDtFim), .F.)

	cAliasAux 	:= If( lImpAcum, "SPH", "SPC")
	cPrefixo	:= If( lImpAcum, "PH_", "PC_")		

	cWhere += "%"
	cWhere += cPrefixo + "FILIAL = '" + cBranchVld + "' AND "
	cWhere += cPrefixo + "MAT = '" + cMatSRA + "' AND "
	cWhere += cPrefixo + "DATA >= '" + cDtIni + "' AND "
	cWhere += cPrefixo + "DATA <= '" + cDtFim + "' "
	cWhere += "%"
	
	cSP9tab := "%" + RetFullName("SP9", cEmpFunc) + "%"

	If lImpAcum
	
		cJoinFil:= "%" + FWJoinFilial("SPH", "SP9") + "%"
		cSPHtab := "%" + RetFullName("SPH", cEmpFunc) + "%"
	
		BeginSql Alias cAliasQry
		
		 	SELECT             
				SPH.PH_DATA, 
				SPH.PH_PD, 
				SPH.PH_PDI , 
				SPH.PH_QUANTC, 
				SPH.PH_QUANTI,
				SPH.PH_ABONO, 
				SPH.PH_QTABONO, 
				SP9.P9_CODIGO, 
				SP9.P9_DESC
			FROM %exp:cSPHtab% SPH
			INNER JOIN %exp:cSP9tab% SP9
			ON %exp:cJoinFil% AND SP9.%NotDel% AND SPH.PH_PD = SP9.P9_CODIGO		
			WHERE
				%Exp:cWhere% AND SPH.%NotDel%
			ORDER BY SPH.PH_DATA, SPH.PH_PD
		
		EndSql 	
	Else
		cJoinFil:= "%" + FWJoinFilial("SPC", "SP9") + "%"
		cSPCtab := "%" + RetFullName("SPC", cEmpFunc) + "%"

		BeginSql Alias cAliasQry
		
		 	SELECT             
				SPC.PC_DATA, 
				SPC.PC_PD, 
				SPC.PC_PDI,
				SPC.PC_QUANTC, 
				SPC.PC_QUANTI,
				SPC.PC_ABONO, 
				SPC.PC_QTABONO, 
				SP9.P9_CODIGO, 
				SP9.P9_DESC
			FROM %exp:cSPCtab% SPC
			INNER JOIN %exp:cSP9tab% SP9
			ON %exp:cJoinFil% AND SP9.%NotDel% AND SPC.PC_PD = SP9.P9_CODIGO			
			WHERE
				%Exp:cWhere%  AND SPC.%NotDel%
			ORDER BY SPC.PC_DATA, SPC.PC_PD	
		EndSql 	
	EndIf
	
	//Considera todos os eventos: Autorizados/Nao Autorizados
	While !(cAliasQry)->(Eof())

		//Prioriza o Cod Informando, depois o código de abono, depois o código calculado.
		If !Empty((cAliasQry)->&(cPrefixo+"PDI") )
			cCod := (cAliasQry)->&(cPrefixo+"PDI")
		ElseIf !Empty((cAliasQry)->&(cPrefixo+"ABONO") )
			cCod := (cAliasQry)->&(cPrefixo+"ABONO")
			//Se a quantidade calculada for maior que a quantidade abonada, então tem abono parcial.
			If (cAliasQry)->&(cPrefixo+"QUANTC") > (cAliasQry)->&(cPrefixo+"QTABONO")
				nSaldoAux := __TimeSub( (cAliasQry)->&(cPrefixo+"QUANTC") , (cAliasQry)->&(cPrefixo+"QTABONO") )
				//Nesse caso, adiciona o evento com a diferença calculada - qtde abonada.
				If ( nPos := aScan( aEventos, {|x| x[1] == (cAliasQry)->P9_CODIGO .And. x[2] == AllTrim((cAliasQry)->P9_DESC) } ) ) == 0
					aAdd( aEventos, { (cAliasQry)->P9_CODIGO, AllTrim((cAliasQry)->P9_DESC), nSaldoAux } )
				Else
					If lSexagenal
						aEventos[nPos,3] := __TimeSum( aEventos[nPos,3], nSaldoAux )
					Else
						aEventos[nPos,3] := aEventos[nPos,3] + fConvhR(nSaldoAux,"D",,5)				
					EndIf 		
				EndIf
			EndIf
		else
			cCod := (cAliasQry)->P9_CODIGO
		EndIf
		
		//Prioriza o Cod Informando, depois o código de abono, depois o código calculado.
		If !Empty((cAliasQry)->&(cPrefixo+"PDI"))
			cDescEve := GetPdDesc( cEmpFunc, cBranchVld, (cAliasQry)->&(cPrefixo+"PDI") )
		ElseIf !Empty((cAliasQry)->&(cPrefixo+"ABONO"))
			cDescEve := GetAboDesc( cEmpFunc, cBranchVld, (cAliasQry)->&(cPrefixo+"ABONO") )
		else
			cDescEve := AllTrim( (cAliasQry)->P9_DESC )
		EndIf	

		//Prioriza a qtde informada, depois a qtde de abono, depois qtde calculado.
		If (cAliasQry)->&(cPrefixo+"QUANTI") > 0
			nSaldo := (cAliasQry)->&(cPrefixo+"QUANTI")
		ElseIf (cAliasQry)->&(cPrefixo+"QTABONO") > 0
			nSaldo := (cAliasQry)->&(cPrefixo+"QTABONO")			
		else
			nSaldo := (cAliasQry)->&(cPrefixo+"QUANTC")
		EndIf
	
		If ( nPos := aScan( aEventos, {|x| x[1] == cCod .And. x[2] == cDescEve } ) ) == 0
			aAdd( aEventos, { cCod, cDescEve, nSaldo } )
		Else
			If lSexagenal
				aEventos[nPos,3] := __TimeSum( aEventos[nPos,3], nSaldo )
			Else
				aEventos[nPos,3] := aEventos[nPos,3] + fConvhR(nSaldo,"D",,5)				
			EndIf 		
		EndIf
	
		(cAliasQry)->(DbSkip())
	EndDo
	
	(cAliasQry)->(DbCloseArea())

	RestArea( aArea )

	Pn090Close()

EndIf

Return( aEventos )

/*/{Protheus.doc} fBalanceSumPer
Retorna o banco de horas do funcionario conforme o periodo que esta sendo pesquisado.
@author:	Marcelo Silveira
@since:		10/06/2019
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			cPerIni - Data inicio do periodo a ser pesquisado;
			cPerFim - Data Fim do periodo a ser pesquisado;
			lSexagenal - Se calcula em formato sexagesimal ou centensimal;
			Self - Objeto com as informações dos parâmetros;
@return:	Array - banco de horas do periodo
/*/
Function fBalanceSumPer( cBranchVld, cMatSRA, cPerIni, cPerFim, lSexagenal, Self )

Local aSaldoDet   := {}
Local aArea       := GetArea()
Local aEmpresas   := {}
Local aPerAll     := {}
Local aTipoAll    := {}
Local aPeriods	  := {}
Local cDtIni      := ""
Local cDtFim      := ""
Local cTpCod      := ""
Local cEmpAtu     := ""
Local cFilAtu     := ""
Local cMatAtu     := ""
Local cLastEmp    := ""
Local cLastFil    := ""
Local cSPItab     := ""
Local cAliasSPI   := ""
Local cRoutine    := "W_PWSA300.APW" 	//Banco de Horas
Local lRet		  := .T.
Local lPer	  	  := ( !Empty(cPerIni) .And. !Empty(cPerFim) )
Local nX          := 0
Local nPosPer     := 0
Local nPosEve     := 0
Local nValor      := 0
Local nCredito    := 0
Local nDebito     := 0
Local nSaldoAtu   := 0
Local nCurrent	  := 0
Local nSaldoAnt   := 0
Local cOrgCFG     := SuperGetMv("MV_ORGCFG", NIL, "0")
Local lValoriza   := GetMvMrh("MV_TCFBHVL",.F.,.F.,cBranchVld) //Utiliza saldo de BH valorizado .T. ou real .F. (padrao))  

cDtIni 	:= StrTran( SubStr(cPerIni, 1, 10), "-", "" )
cDtFim 	:= StrTran( SubStr(cPerFim, 1, 10), "-", "" )

aVision    := GetVisionAI8(cRoutine, cBranchVld)
cVision    := aVision[1][1]

If cOrgCFG == "2"
	fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
Else
	aEmpresas := {cEmpAnt}
EndIf

cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
aCoordTeam := APIGetStructure("", "", cVision, cBranchVld, cMatSRA, , , , , cBranchVld, cMatSRA, , , , , .T., aEmpresas)

For nX := 1 To Len( aCoordTeam[1]:ListOfEmployee )

	cEmpAtu := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
	cFilAtu := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial
	cMatAtu := aCoordTeam[1]:ListOfEmployee[nX]:Registration

	If !cLastEmp == cEmpAtu
		cSPItab := "%" + RetFullName("SPI", cEmpAtu) + "%"
		cLastEmp := cEmpAtu
	EndIf

	If !( cFilAtu + cMatAtu == cBranchVld + cMatSRA ) //Nao considera a Filial+Matricula do lider/gestor
		If !Empty( Self:employeeName ) .And. !Empty( Self:role )
			lRet := Upper(Self:employeeName) $ aCoordTeam[1]:ListOfEmployee[nX]:Name .And. Upper(Self:role) $ aCoordTeam[1]:ListOfEmployee[nX]:FunctionDesc
		Else
			If !Empty( Self:employeeName )
				lRet := Upper(Self:employeeName) $ aCoordTeam[1]:ListOfEmployee[nX]:Name
			EndIf
			If !Empty( Self:role )
				lRet := Upper(Self:role) $ aCoordTeam[1]:ListOfEmployee[nX]:FunctionDesc
			EndIf
		EndIf
		If lRet
			cAliasSPI := GetNextAlias()
			BeginSql Alias cAliasSPI
			SELECT PI_FILIAL, PI_MAT, PI_PD, PI_QUANT, PI_QUANTV, PI_DATA, PI_STATUS, PI_DTBAIX
			FROM %exp:cSPItab% SPI
			WHERE 	
				SPI.PI_FILIAL=%exp:cFilAtu% AND 
				SPI.PI_MAT=%exp:cMatAtu% AND 
				SPI.%notDel%
			ORDER BY 
				SPI.PI_FILIAL, SPI.PI_MAT, SPI.PI_DATA	
			EndSql
			If (cAliasSPI)->( !Eof() )
				While (cAliasSPI)->( !Eof() )

					If ( cLastFil <> (cAliasSPI)->PI_FILIAL ) .And. !lPer

						//Se nao vier o periodo na requisicao considera o que estiver aberto no ponto
						IF ( nPosPer := aScan(aPerAll, {|x| x[1]+x[2] == cEmpAtu + (cAliasSPI)->PI_FILIAL }) ) > 0
							cPerIni := aPerAll[nPosPer, 3]
							cPerFim := aPerAll[nPosPer, 4]
						Else
							If cEmpAnt == cEmpAtu
								aPeriods := GetPeriodApont( (cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_MAT, 1)
							Else
								aPeriods := GetDataForJob( "1", {(cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_MAT, Nil}, cEmpAtu )
							EndIf

							If Len(aPeriods) > 0
								//Considera o periodo de um ano na pesquisa
								cPerIni := dToS( aPeriods[1,1] )
								cPerFim := dToS( aPeriods[1,2] )
							EndIf

							cLastFil := (cAliasSPI)->PI_FILIAL
							cDtIni 	:= StrTran( SubStr(cPerIni, 1, 10), "-", "" )
							cDtFim 	:= StrTran( SubStr(cPerFim, 1, 10), "-", "" )

							aAdd( aPerAll, { cEmpAtu, (cAliasSPI)->PI_FILIAL, cPerIni, cPerFim } )
						EndIf
					EndIf

					IF ( nPosEve := aScan(aTipoAll, {|x| x[1]+x[2]+x[3] == cEmpAtu + (cAliasSPI)->PI_FILIAL + (cAliasSPI)->PI_PD}) ) > 0
						cTpCod := aTipoAll[nPosEve, 4]
					Else
						cTpCod := GetTpEvent(cEmpAtu, (cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_PD)
						aAdd( aTipoAll, { cEmpAtu, (cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_PD, cTpCod} )
					EndIf

					// Totaliza Saldo Anterior
					If (cAliasSPI)->PI_DATA < cDtIni
						If !((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX < cDtIni)
							If ((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX <= cDtFim)
								If cTpCod $ "1*3"
									nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
									If lSexagenal
										nSaldoAnt := __TimeSum(nSaldoAnt,nValor)  
										nSaldoAtu := __TimeSub(nSaldoAtu,nValor)
									Else
										nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D",,5) 
										nSaldoAtu := nSaldoAtu - fConvhR(nValor,"D",,5)
									EndIf 
								Else
									nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
									If lSexagenal
										nSaldoAnt := __TimeSub(nSaldoAnt,nValor)
										nSaldoAtu := __TimeSum(nSaldoAtu,nValor) 
									Else
										nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D",,5)
										nSaldoAtu := nSaldoAtu + fConvhR(nValor,"D",,5) 
									EndIf
								EndIf
							Else
								If cTpCod $ "1*3"
												
									nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
									If lSexagenal
										nSaldoAnt := __TimeSum(nSaldoAnt,nValor)  
									Else
										nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D",,5) 
									EndIf 
								Else
									nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
									If lSexagenal
										nSaldoAnt := __TimeSub(nSaldoAnt,nValor)  
									Else
										nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D",,5) 
									EndIf
								EndIf
							EndIf
						EndIf
					ElseIf (cAliasSPI)->PI_DATA <= cDtFim
						If !((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX <= cDtFim)
							If cTpCod $ "1*3"			
								nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
								If lSexagenal
									nCredito := __TimeSum(nCredito,nValor)  
								Else
									nCredito := nCredito + fConvhR(nValor,"D",,5) 
								EndIf 
							Else
								nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
								If lSexagenal
									nDebito := __TimeSum(nDebito,nValor)  
								Else
									nDebito := nDebito + fConvhR(nValor,"D",,5) 
								EndIf
							EndIf
						EndIf	
					Endif
					(cAliasSPI)->(DbSkip())
				EndDo
				(cAliasSPI)->( DBCloseArea() )
				If lSexagenal
					nSaldoAtu := __TimeSum(nSaldoAtu, __TimeSub( __TimeSum( nSaldoAnt , nCredito ) , nDebito ))
					nCurrent  := __TimeSub( nCredito, nDebito )
				Else
					nSaldoAtu := ( nSaldoAtu + nSaldoAnt + nCredito ) - nDebito
					nCurrent  := nCredito - nDebito
				EndIf
				aAdd( aSaldoDet, { 	nSaldoAnt, ;
									nSaldoAtu, ;
									nCurrent, ;
									cFilAtu, ;
									cMatAtu, ;
									aCoordTeam[1]:ListOfEmployee[nX]:Name, ;
									aCoordTeam[1]:ListOfEmployee[nX]:FunctionDesc, ;
									cEmpAtu } )
				nSaldoAnt := 0 
				nSaldoAtu := 0
				nCurrent  := 0
				nCredito  := 0
				nDebito   := 0
			Else
				aAdd( aSaldoDet, { 	0, ;
									0, ;
									0, ;
									cFilAtu, ;
									cMatAtu, ;
									aCoordTeam[1]:ListOfEmployee[nX]:Name, ;
									aCoordTeam[1]:ListOfEmployee[nX]:FunctionDesc,; 
									cEmpAtu } )
			EndIf
		EndIf
	EndIf
Next nX
RestArea( aArea )
Pn090Close()

Return( aSaldoDet )


Function fEditClocking(aUrlParam, cBody, aIdFunc, cFilManager, cMatManager, cEmpManager, cEmpFunc, lJob, cUID)
    Local oItemDetail           := Nil
    Local oRequest              := Nil
    Local oAttendControlRequest := Nil
    Local nA                    := 0
    Local cMsgLog               := ""
    Local cCodeReq              := ""
    Local cAllJustify           := ""
	Local aMSToHour             := Array(02)
    Local aTrab                 := {}
    Local aStatus               := {"","",""}
    Local lRet                  := .T.
	Local lContinua				:= .T.
    Local lEmployManager 		:= .F.

    Default aUrlParam           := {}
    Default cBody               := ""
    Default aIdFunc             := {}
    Default cFilManager         := ""
    Default cMatManager         := ""
    Default cEmpManager         := cEmpAnt
    Default cEmpFunc            := cEmpAnt

	If Len(aIdFunc) > 0
		cBranchVld	:= aIdFunc[1]
		cMatSRA		:= aIdFunc[2]
	Else
		cMatSRA     := cMatManager
		cBranchVld	:= cFilManager
	EndIf
	
	//Instancia o ambiente para a empresa onde a funcao sera executada
	If lJob
		RPCSetType( 3 )
		RPCSetEnv( cEmpFunc, cBranchVld )
	EndIf

	oItemDetail                 := JsonObject():New()
    oRequest                    := WSClassNew("TRequest")
    oRequest:RequestType        := WSClassNew("TRequestType")
    oRequest:Status             := WSClassNew("TRequestStatus")
    oAttendControlRequest       := WSClassNew("TAttendControl")

    If !Empty(cBody)
        oItemDetail:FromJson(cBody)

        //Em a justificativa tiver sido informada para todas as batidas 
        cAllJustify := If(oItemDetail:hasProperty("justify"),oItemDetail["justify"],"")

        If oItemDetail:hasProperty("clockings") .And. ValType(oItemDetail["clockings"]) == "A"
            For nA := 1 To len(oItemDetail["clockings"])
				If cTod(Format8601(.T.,oItemDetail["clockings"][nA]["date"])) == dDataBase
					lContinua := fVldHour(oItemDetail["clockings"][nA]["hour"], @cMsgLog)
				EndIf
				If lContinua
					aStatus := {"","",""}
					If oItemDetail["clockings"][nA]:hasProperty("status")
						aStatus[1] := oItemDetail["clockings"][nA]["status"]["status"]
						aStatus[2] := oItemDetail["clockings"][nA]["status"]["id"]
						aStatus[3] := oItemDetail["clockings"][nA]["status"]["label"]
					EndIf
					AADD(aTrab,{;
						Iif(oItemDetail["clockings"][nA]:hasProperty("hour"),oItemDetail["clockings"][nA]["hour"]," "),;
						aStatus,;
						Iif(oItemDetail["clockings"][nA]:hasProperty("date"),oItemDetail["clockings"][nA]["date"]," "),;
						Iif(oItemDetail["clockings"][nA]:hasProperty("sequence"),oItemDetail["clockings"][nA]["sequence"]," "),;
						Iif(!Empty(cAllJustify), cAllJustify, Iif(oItemDetail["clockings"][nA]:hasProperty("justify"),oItemDetail["clockings"][nA]["justify"]," ")),;
						Iif(oItemDetail["clockings"][nA]:hasProperty("id"),oItemDetail["clockings"][nA]["id"]," "),;
						Iif(oItemDetail["clockings"][nA]:hasProperty("referenceDate"),oItemDetail["clockings"][nA]["referenceDate"]," "),;
						Iif(oItemDetail["clockings"][nA]:hasProperty("direction"),oItemDetail["clockings"][nA]["direction"]," "),;
						Iif(oItemDetail["clockings"][nA]:hasProperty("origin"),oItemDetail["clockings"][nA]["origin"]," "),;
						Iif(oItemDetail:hasProperty("reason"),oItemDetail["reason"]," ");
					})
				Else
					lRet := .F.
					Exit
				EndIf
            Next nA
        Else
            aStatus := {"","",""}
            If oItemDetail:hasProperty("status")
                aStatus[1] := oItemDetail["status"]["status"]
                aStatus[2] := oItemDetail["status"]["id"]
                aStatus[3] := oItemDetail["status"]["label"]
            EndIf
			If cTod(Format8601(.T.,oItemDetail["date"])) == dDataBase
				lContinua := fVldHour(oItemDetail["hour"], @cMsgLog)
			EndIf
			If lContinua
				AADD(aTrab,{;
					Iif(oItemDetail:hasProperty("hour"),oItemDetail["hour"]," "),;
					aStatus,;
					Iif(oItemDetail:hasProperty("date"),oItemDetail["date"]," "),;
					Iif(oItemDetail:hasProperty("sequence"),oItemDetail["sequence"]," "),;
					Iif(!Empty(cAllJustify), cAllJustify, Iif(oItemDetail:hasProperty("justify"),oItemDetail["justify"]," ")),;
					Iif(oItemDetail:hasProperty("id"),oItemDetail["id"]," "),;
					Iif(oItemDetail:hasProperty("referenceDate"),oItemDetail["referenceDate"]," "),;
					Iif(oItemDetail:hasProperty("direction"),oItemDetail["direction"]," "),;
					Iif(oItemDetail:hasProperty("origin"),oItemDetail["origin"]," "),;
					""; //-- No request do metodo "Atualiza UMA batida do espelho do ponto" não é enviado o parametro "reason" pois isso é inicializado com ""
				})
			Else
				lRet := .F.
			EndIf
        EndIf

        If Len(aTrab) > 0
			lEmployManager := fGetTeamManager(cFilManager, cMatManager, , , , , cEmpManager)
			
			DbSelectArea("RH3")
			For nA := 1 To len(aTrab)
				cCodeReq    := aTrab[nA][6]
				aMsToHour   := milisSecondsToHour(aTrab[nA][1],aTrab[nA][1])
				If "|" $ cCodeReq
					cCodeReq := STRTOKARR( cCodeReq , "|" )[2]

					RH3->(DbSetOrder(1))
					If RH3->(DbSeek( cBranchVld + cCodeReq ))
						//Altera somente status 1 (Em processo de aprovação) ou 4 (Aguardando aprovacao RH) para quem tem equipe
						If RH3->RH3_STATUS == "1" .Or. (lEmployManager .And. RH3->RH3_STATUS == "4")
							oRequest:Branch                     := cBranchVld
							oAttendControlRequest:Branch        := cBranchVld
							oAttendControlRequest:Registration  := cMatSRA
							oAttendControlRequest:Name          := Alltrim(Posicione('SRA',1,cBranchVld+cMatSRA,'SRA->RA_NOME'))
							oAttendControlRequest:EntryExit     := Iif(Alltrim(aTrab[nA][8])=="entry","Entrada","Saída")
							oAttendControlRequest:Date          := Format8601(.T.,aTrab[nA][3])
							oAttendControlRequest:Hour          := cValToChar(aMsToHour[1])
							oAttendControlRequest:Observation   := GetMotDesc( aTrab[nA][10], cCodeReq, cBranchVld )
							oAttendControlRequest:Motive        := aTrab[nA][5]
							oAttendControlRequest:codeRequest   := cCodeReq

							lRet :=	AddAttendControlRequest(oRequest, oAttendControlRequest, .T., @cMsgLog, STR0038 ) //"MEURH")
						Else //-- Qualquer outro status nao permite alteracao
							cMsgLog := STR0037 //"Essa batida não pode ser alterada. O seu Tipo ou Status atual não permite alteração."
							lRet := .F.
							Exit
						EndIf
					EndIf
				Else
					cMsgLog := STR0026 //"Só é possível editar batidas que foram incluídas manualmente!"
					lRet := .F.
					Exit
				EndIf
			Next nA
        EndIf
    EndIf

	Pn090Close()
	
	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return cMsgLog


Function GetMotDesc(cCodigo, cCodRH3, cBranchVld)
    Local cMotDesc := ""
    Local aArea	:= GetArea()

    If !Empty(cCodigo)
	    dbSelectArea("RFD")
	    RFD->(dbSetOrder(1))
		If RFD->(dbSeek(FWxFilial("RFD", cBranchVld) + cCodigo))   
	        cMotDesc := RFD->RFD_DESC
	    EndIf
	Else
	    dbSelectArea("RH4")
	    RH4->(dbSetOrder(1))
		If RH4->(dbSeek(FWxFilial("RH4", cBranchVld) + cCodRH3)) 
			While !RH4->(Eof())
			    If Alltrim(RH4->RH4_CAMPO) == "P8_MOTIVRG"
					cMotDesc  := AllTrim( RH4->RH4_VALNOV )
					Exit
				EndIf
				RH4->(dbskip())
			Enddo
	    EndIf
    EndIf
	
	RestArea(aArea)

Return cMotDesc


Function DelBatida(cFilialPar, cMatSRA, cCodigo, aDataLogin)
	Local lRet		:= .F.
	Local cFilRH3	:= Iif( FWModeAccess("RH3") == "C", FwxFilial("RH3"), cFilialPar )
	Local cFilRH4	:= Iif( FWModeAccess("RH4") == "C", FwxFilial("RH4"), cFilialPar )
	Local cFilRS3	:= Iif( FWModeAccess("RS3") == "C", FwxFilial("RS3"), cFilialPar )
	Local cMessage	:= ""
	Local lEmployManager := .F.

	DEFAULT aDataLogin := {}
	
	dbSelectArea("RH3")
	RH3->(dbSetOrder(1))
	If RH3->(dbSeek(cFilRH3 + cCodigo))
	
		lEmployManager	:= fGetTeamManager(aDataLogin[5], aDataLogin[1])
		
		//Exclui somente status 1 (Em processo de aprovação) ou 4 (Aguardando aprovacao RH) para quem tem equipe
		If RH3->RH3_STATUS == '1' .Or. (lEmployManager .And. RH3->RH3_STATUS == "4")
			Begin Transaction
				RecLock("RH3",.F.)
				RH3->(dbDelete())
				RH3->(MsUnlock())

				DbSelectArea("RH4")
				RH4->(DbSetOrder(1))
				If RH4->(DbSeek(cFilRH4 + cCodigo))
					While RH4->(!Eof() .and. RH4_FILIAL + RH4_CODIGO == cFilRH4 + cCodigo)
						RecLock("RH4",.F.)
						RH4->(DbDelete())
						RH4->(MsUnLock())
						RH4->(DbSkip())
					EndDo
				EndIf

				DbSelectArea("RS3")
				RS3->(DbSetOrder(1))
				If RS3->(DbSeek(cFilRS3 + cCodigo))
					RecLock("RS3",.F.)
					RS3->(DbDelete())
					RS3->(MsUnLock())
					RS3->(DbSkip())
				EndIf

				DelRGKRDY(cFilRH3, cMatSRA, cCodigo)
				
			End Transaction
			lRet := .T.
		Else
			cMessage := EncodeUTF8(STR0032) //"Esta batida não poderá ser excluída porque o processo de aprovação já foi iniciado."
			lRet := .F.
		EndIf
	EndIf	

Return {lRet, cMessage}


/*/{Protheus.doc} fGetListAllowance
Carrega as solicitacoes de abono do funcionario conforme os parametros
@author:	Marcelo Faria
@since:		23/12/2019
@param:		nType - 1=Solicitacoes pendentes, 2=diferentes de pendentes, 3=Todos;
			cFilSra - Filial;
			cMatSra - Matrícula;
			cEmpFunc - Empresa;
			cCodReq - Codigo da requisicao;
			cPage - Numero da pagina;
			cPageSize - Numero de registros;
			lNextPage - Indica se existe ou nao mais registros;
@return:	aFields - array com o json das solicitacoes			
/*/
Function fGetListAllowance( nType, cBranchVld, cMatSRA, cEmpFunc, cCodReq, cPage, cPageSize, lNextPage, aDataLogin )

Local oFields      	:= JsonObject():New()
Local oType      	:= JsonObject():New()
Local aFields      	:= {}
Local aOrdFields   	:= {}
Local nX     		:= 0
Local nNumRegs 		:= 0
Local nRegCount     := 0
Local nRegIniCount  := 0 
Local nRegFimCount  := 0

Local cCodAbn		:= ""
Local cDscAbn		:= ""
Local cIniReq		:= ""
Local cMatLogin		:= ""
Local cFilLogin		:= ""
Local cRespName     := ""
Local cRespId       := ""

Local cQryRH3		:= ""
Local cQryRH4		:= ""
Local cDataIni		:= ""
Local cJustific     := ""      

Local cWhere 		:= "%"
Local lCount		:= .F.
Local lIniReq		:= .F.
Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.) 
Local lBitMap		:= RH3->(ColumnPos("RH3_BITMAP")) > 0
Local lCposSP6 		:= CpoUsado("P6_MEURH") .And. CpoUsado("P6_ANEXMRH")
Local aProps		:= fGetPropAllowance()

DEFAULT nType       := 3
DEFAULT cEmpFunc	:= cEmpAnt
DEFAULT	cCodReq		:= ""
DEFAULT cPage		:= ""
DEFAULT cPageSize	:= ""
DEFAULT lNextPage	:= .F.
DEFAULT aDataLogin	:= {}

If Len(aDataLogin) > 0
	cMatLogin	:= aDataLogin[1]
	cFilLogin	:= aDataLogin[5]
EndIf

//controle de paginacao
If !Empty(cPage) .And. !Empty(cPageSize)
	If cPage == "1" .Or. cPage == ""
		nRegIniCount := 1 
		nRegFimCount := If( Empty( Val(cPageSize) ), 20, Val(cPageSize) )
	Else
		nRegIniCount := ( Val(cPageSize) * ( Val(cPage) - 1 ) ) + 1
		nRegFimCount := ( nRegIniCount + Val(cPageSize) ) - 1
	EndIf
	lCount := .T.
EndIf

If !empty(cCodReq)
	cWhere += " RH3.RH3_CODIGO = '" + cCodReq + "' AND " 
Else
	If nType == 1 //pending
		cWhere += " RH3.RH3_STATUS IN ('1','4') AND "	
	ElseIf nType == 2 //notpending
		cWhere += " RH3.RH3_STATUS IN ('2','3') AND "
	EndIf
EndIf

If RH3->(ColumnPos("RH3_EMP")) > 0 
	cWhere += " RH3.RH3_EMP = '" + cEmpFunc + "' AND "
EndIf

cWhere += "%"

cQryRH3 := GetNextAlias()
BEGINSQL ALIAS cQryRH3
	SELECT RH3_FILIAL, RH3_MAT, RH3_EMP, RH3_CODIGO, RH3_STATUS, 
	       RH3_BITMAP, RH3_NVLAPR, RH3_NVLINI, RH3_FILINI, 
		   RH3_MATINI, RH3_EMPAPR, RH3_FILAPR, RH3_MATAPR
	FROM %Table:RH3% RH3
	WHERE
		RH3.RH3_TIPO   =  '8'              AND
		RH3.RH3_FILIAL =  %Exp:cBranchVld% AND
		RH3.RH3_MAT    =  %Exp:cMatSRA%    AND
		%Exp:cWhere% 
		RH3.%NotDel%
ENDSQL

While !(cQryRH3)->(Eof()) 
	oFields                    := JsonObject():New() 
	oFields["id"]              := RC4CRYPT( (cQryRH3)->RH3_FILIAL +"|"+ (cQryRH3)->RH3_MAT +"|"+ (cQryRH3)->RH3_EMP +"|"+ (cQryRH3)->RH3_CODIGO, "MeuRH#Allowance")
	oFields["status"]          := If( (cQryRH3)->RH3_STATUS=='2', "approved", If((cQryRH3)->RH3_STATUS=='3', 'rejected', 'pending') )
	oFields["statusLabel"]     := fStatusLabel( (cQryRH3)->RH3_STATUS )
	oFields["hasAttachment"]   := lBitMap .And. !Empty( (cQryRH3)->RH3_BITMAP )
	

	If !Empty((cQryRH3)->RH3_FILAPR) .And. !Empty((cQryRH3)->RH3_MATAPR) .And. !Empty((cQryRH3)->RH3_EMPAPR)
		cRespName   := If(lNomeSoc, fSraVal((cQryRH3)->RH3_FILAPR, (cQryRH3)->RH3_MATAPR, "RA_NSOCIAL", (cQryRH3)->RH3_EMPAPR), "")
		cRespName   := If(Empty(cRespName), fSraVal((cQryRH3)->RH3_FILAPR, (cQryRH3)->RH3_MATAPR, "RA_NOME", (cQryRH3)->RH3_EMPAPR), cRespName)
		cRespId := (cQryRH3)->RH3_FILAPR +"|"+ (cQryRH3)->RH3_MATAPR +"|"+ (cQryRH3)->RH3_EMPAPR
	EndIf

	oFields["responsibleName"] := cRespName
	oFields["responsibleId"]   := cRespId

	cQryRH4 := GetNextAlias()
	BEGINSQL ALIAS cQryRH4
		SELECT RH4_FILIAL, RH4_CODIGO, RH4_CAMPO, RH4_VALNOV
		FROM   %Table:RH4% RH4
		WHERE  RH4.RH4_FILIAL = %Exp:(cQryRH3)->RH3_FILIAL% AND 
				RH4.RH4_CODIGO = %Exp:(cQryRH3)->RH3_CODIGO% AND 
				RH4.%NotDel%
	ENDSQL

	While (cQryRH4)->(!Eof()) 
		cCpoRH4 := AllTrim((cQryRH4)->RH4_CAMPO)		
		
		DO CASE
			CASE cCpoRH4 == "RF0_DTPREI"
				oFields["initDate"]         := cDataIni := formatGMT(Alltrim((cQryRH4)->RH4_VALNOV))
			CASE cCpoRH4 == "RF0_HORINI"
				oFields["initHour"]         := HourToMs(strZero( Val(Alltrim((cQryRH4)->RH4_VALNOV)), 5, 2))
			CASE cCpoRH4 == "RF0_DTPREF"
				If Alltrim((cQryRH4)->RH4_VALNOV) == "/  /"
					oFields["endDate"]      := cTod("//")
				Else
					oFields["endDate"]      := formatGMT(Alltrim((cQryRH4)->RH4_VALNOV))
				EndIf
			CASE cCpoRH4 == "RF0_HORFIM"
				oFields["endHour"]          := HourToMs(strZero( Val(Alltrim((cQryRH4)->RH4_VALNOV)), 5, 2))
			CASE cCpoRH4 == "RF0_CODABO"
				cCodAbn                     := Alltrim((cQryRH4)->RH4_VALNOV)
			CASE cCpoRH4 == "TMP_ABOND"					
				cDscAbn	                    := Alltrim((cQryRH4)->RH4_VALNOV)
		ENDCASE			
		
		(cQryRH4)->(DbSkip())
	EndDo
	(cQryRH4)->( DBCloseArea() )

	//Se a solicitação estiver rejeitada, busca a última justificativa.
	If ((cQryRH3)->RH3_STATUS == '3')
		cJustific := Alltrim( getRGKJustify(xFilial("RGK", (cQryRH3)->RH3_FILIAL), (cQryRH3)->RH3_CODIGO, "", .T.) )
	Else
		cJustific := Alltrim( getRGKJustify(xFilial("RGK", (cQryRH3)->RH3_FILIAL), (cQryRH3)->RH3_CODIGO, "'000001'") )
	EndIf

	oType				     	:= JsonObject():New() 
	oType["id"] 		     	:= cCodAbn 
	oType["description"]     	:= EncodeUTF8(cDscAbn)	
	oType["requiredAttachment"] := If( lCposSP6, fDesc("SP6", cCodAbn, "P6_ANEXMRH") == "1", .F. )
	oType["props"] 		     	:= aProps
	oFields["allowanceType"] 	:= oType
	oFields["justify"]          := cJustific
	
	If (cQryRH3)->RH3_NVLAPR != (cQryRH3)->RH3_NVLINI   
		cIniReq := (cQryRH3)->RH3_FILINI + (cQryRH3)->RH3_MATINI
		lIniReq := !Empty(cIniReq) .And. cIniReq == (cFilLogin + cMatLogin)

		If Val( GetRGKSeq( (cQryRH3)->RH3_CODIGO , .T.) ) == 2 .And. lIniReq
			oFields["canAlter"]	:= .T.
		Else
			oFields["canAlter"]	:= .F.    
		EndIf
	EndIf

	Aadd( aFields, {oFields, cDataIni} )

	//Reiniciando variáveis auxiliares.
	cRespName := ""
	cRespId   := ""

	(cQryRH3)->(dbSkip()) 
EndDo

(cQryRH3)->( DBCloseArea() )


If ( nNumRegs := Len(aFields) ) > 0

	//Reordena os registros conforme a data do abono (mais recente primeiro)
	aSort(aFields,,,{ | x,y | x[2] > y[2] } )

	For nX := 1 To nNumRegs

		nRegCount ++		
		
		If !lCount .Or. ( nRegCount >= nRegIniCount .And. nRegCount <= nRegFimCount )
			Aadd( aOrdFields, aFields[nX,1] )
		Else
			If nRegCount >= nRegFimCount
				lNextPage := .T.
				Exit
			EndIf				
		EndIf

	Next nX
EndIf

FreeObj(oType)
FreeObj(oFields)

Return( aOrdFields )


/*/{Protheus.doc} fGetTimezone
Carrega as solicitacoes de abono do funcionario conforme os parametros
@author:	Marcelo Faria, Jose Marcelo, Henrique Ferreira
@since:		15/04/2020
@param:		cTimezone - timezone da geolocalização;
@return:	aResultTmz - array com data e hora local do timezone			
/*/
Function fGetTimezone( TmzBatida )
Local aResultTmz	:= {}
Local aMSToHour		:= Array(02)
Local nHour			:= Seconds()*1000
Local nMinGMTServer	:= 0
Local nDifMinTmz	:= 0
Local nDifHrTmz		:= 0
Local nDia			:= 0

DEFAULT	TmzBatida := 0

If Valtype(TmzBatida) == "N"
	
	//Verifica se o dia mudou para atualizar a variável dDataBase
	FwDateUpd(.F., .T.)

	// Apura diferença em minutos do horário do servidor para o GMT+0 
	nMinGMTServer :=  Hrs2Min( SUBSTR(  FWTimeStamp(5) , 20 ) )
	aMsToHour := milisSecondsToHour(nHour,nHour)

	TmzBatida := TmzBatida * -1

	// avaliar a diferença em minutos do timezone do servidor e o timezone da marcação
	If TmzBatida == nMinGMTServer
		// os timezones são iguais e retorna o valor padrão do server
		aAdd(aResultTmz, FwTimeStamp(6, dDataBase, "12:00:00" )) 
		aAdd(aResultTmz, Seconds()*1000)
		If cMeurhLog == "1"
			Conout("<<< " + STR0125 + " " + STR0127 + " " + OEMToAnsi(STR0126) + ": " + ; // Timezone Servidor igual Timezone marcação.
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + OEMToAnsi(STR0126) + ": " + cValToChar(TmzBatida) + ": " + ; // Timezone da Marcação
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0125 + ": " + cValToChar(nMinGMTServer) + ": " + ; // Timezone do Servidor.
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0103 + ": " + aResultTmz[1] + ": " + ; // Data
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0128 + " ( " + STR0129 + " ): " + cValToChar(aResultTmz[2]) + ": " + ; // Hora (Milissegundos)
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
		EndIf 

	ElseIf nMinGMTServer < TmzBatida
		//servidor está a leste(direita) da marcação 
		nDifMinTmz := TmzBatida - nMinGMTServer

		// Avaliação do Min2Hrs() com o resultado em minutos sempre positivo
		nDifHrTmz := Min2Hrs( nDifMinTmz )
		nHrTmz    := somaHoras( NoRound(aMsToHour[1],2)  , nDifHrTmz)

		If nHrTmz > 23.59
			nNewHor := somaHoras( 0.00 , SomaHoras( SubHoras( nHrTmz , 23.59 ) , 0.01 ) )
			nHrTmz  := nNewHor
			nDia    := 1
		EndIf

		aAdd(aResultTmz, FwTimeStamp(6, dDataBase + nDia, "12:00:00" )) 
		aAdd(aResultTmz, (Hrs2Min(nHrTmz) * 60) * 1000)
		If cMeurhLog == "1"
			Conout("<<< " + STR0125 + " " + STR0131 + " " + OEMToAnsi(STR0126) + ": " + ; // Timezone Servidor Menor Timezone marcação.
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0125 + ": " + cValToChar(nMinGMTServer) + ": " + ; // Timezone do Servidor.
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + OEMToAnsi(STR0126) + ": " + cValToChar(TmzBatida) + ": " + ; // Timezone da Marcação
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0103 + ": " + aResultTmz[1] + ": " + ; // Data
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0128 + " ( " + STR0129 + " ): " + cValToChar(aResultTmz[2]) + ": " + ; // Hora (Milissegundos)
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
		EndIf

	Elseif nMinGMTServer > TmzBatida
		//servidor está a oeste(esquerda) da marcação 
		nDifMinTmz := nMinGMTServer - TmzBatida

		// Avaliação do Min2Hrs() com o resultado em minutos sempre positivo
		nDifHrTmz := Min2Hrs( nDifMinTmz )
		nHrTmz 	  := SubHoras( NoRound(aMsToHour[1],2)  , nDifHrTmz)

		// batida            server
		// 17/04	      	 18/04
		// 11:00 p.m.   ---  01:00 a.m.

		If negativo(nHrTmz)
			nNewHor := SubHoras( 23.59 , SubHoras(nHrTmz * (-1) , 0.01) )
			nHrTmz  := nNewHor
			nDia    := 1
		EndIf

		aAdd(aResultTmz, FwTimeStamp(6, dDataBase - nDia, "12:00:00" )) 
		aAdd(aResultTmz, (Hrs2Min(nHrTmz) * 60) * 1000) 

		If cMeurhLog == "1"
			Conout("<<< " + STR0125 + " " + STR0130 + " " + OEMToAnsi(STR0126) + ": " + ; // Timezone Servidor Maior Timezone marcação.
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0125 + ": " + cValToChar(nMinGMTServer) + ": " + ; // Timezone do Servidor.
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + OEMToAnsi(STR0126) + ": " + cValToChar(TmzBatida) + ": " + ; // Timezone da Marcação
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0103 + ": " + aResultTmz[1] + ; // Data
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
			Conout("<<< " + STR0128 + " ( " + STR0129 + " ): " + cValToChar(aResultTmz[2]) + ": " + ; // Hora (Milissegundos)
			STR0121 + " : " + AlLTrim(Str(ThreadID())) + " >>> ") // Thread
		EndIf
	EndIf

EndIf	

Return aResultTmz

/*/{Protheus.doc} fGetPropAllowance
Carrega as propriedades dos tipos de abono (fieldProperties)
@author:	Marcelo Silveira
@since:		08/06/2020
@return:	aProps - array com os objetos fieldproperties do allowance			
/*/
Function fGetPropAllowance()

Local oProps   := JsonObject():New()
Local aProps   := {}

	oProps := JsonObject():New()
	oProps["field"]     := "totalHour"
	oProps["visible"]   := .F.
	oProps["editable"]  := .F.
	oProps["required"]  := .F.
	Aadd(aProps, oProps)

	oProps := JsonObject():New()
	oProps["field"]     := "initHour"
	oProps["visible"]   := .T.
	oProps["editable"]  := .T.
	oProps["required"]  := .T.
	Aadd(aProps, oProps)

	oProps := JsonObject():New()
	oProps["field"]     := "endHour"
	oProps["visible"]   := .T.
	oProps["editable"]  := .T.
	oProps["required"]  := .T.
	Aadd(aProps, oProps)

	oProps := JsonObject():New()
	oProps["field"]     := "justify"
	oProps["visible"]   := .T.
	oProps["editable"]  := .T.
	oProps["required"]  := .T.
	Aadd(aProps, oProps)

Return( aProps )

/*/{Protheus.doc} fVldMarc
Valida se as batidas estão dentro do período de apontamento.
@author:	Henrique Ferreira
@since:		22/06/2020
@return:	lRet - Retorna se a batida está dentro do período e pode ser gravada.
/*/
Function fVldMarc(aBatidas, cBranchVld, dPerFim, cMsg, dHoje)

Local nX		:= 0
Local nDAberto	:= 0
Local lRet		:= .T.
Local dData 	:= cTod("//")
Local dPerIni	:= cTod("//")
Local cPonMes	:= ""

DEFAULT aBatidas 	:= {}
DEFAULT cBranchVld  := cFilAnt
DEFAULT dPerFim  	:= cTod("//")
DEFAULT dHoje    	:= dDataBase

If Empty(dPerFim)
	cMsg := STR0073 //Não foi possível carregar o conteúdo o MV_PONMES. Verifique se o paramêtro está preenchido corretamente.
	lRet := .F.
Else
	nDAberto := SuperGetMv("MV_DABERTO" , NIL , 0)
	cHour	 := Time()

	If dHoje > (dPerFim + nDAberto)
		cMsg := STR0075 //O período de apontamento atual encontra-se fechado para a manutenção de batidas.
		lRet := .F.
	Else
		//	Busca o ponmes para saber a data de inicio do apontamento conforme o parâmetro.
		//	Isso é necessário para checar lançamento de marcações anteriores a data de inicio do MV_PONMES.
		cPonMes := GetPonMes(cBranchVld)
		dPerIni := Stod( Left( cPonMes , 08 ) )
		For nX := 1 To Len(aBatidas)
			
			dData := STOD( SubSTR(aBatidas[nX][2], 1, 4) + SubSTR(aBatidas[nX][2], 6, 2) + SubSTR(aBatidas[nX][2], 9, 2) )

			If dData < dPerIni
				cMsg := STR0074 // A data da batida não pode ser inferior à data de início do período de apontamento.
				lRet := .F.
				Exit
			EndIf

			//Valida o horario da batida para impedir inclusao em horario futuro
			If dData == dHoje
				If !fVldHour(aBatidas[nX][1], @cMsg)
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} fVldHour
Valida se as batidas estão dentro do horario permitido.
@author:	Marcelo Silveira
@since:		22/02/2021
@return:	lRet - Retorna se a batida está dentro do horario permitido
/*/
Function fVldHour(cHourCheck, cMsg)

Local lRet		:= .T.
Local nAt		:= 0
Local nHour  	:= 0
Local nHourReq  := 0
Local cMinute  	:= ""
Local cHourAux  := ""
Local cHourReq  := ""
Local cHour	 	:= Time()
Local aHour  	:= {}

Default cMsg  	:= ""

aHour	 := STRTOKARR(cHour, ":")
nHour	 := Val( aHour[1] + aHour[2] )
cHourReq := cValToChar(milisSecondsToHour(cHourCheck,cHourCheck)[1])
nAt		 := AT(".",cHourReq)

If nAt > 0
	cHourAux := SubStr(cHourReq, 1, nAt-1 )
	cHourAux := If( Len(cHourAux) > 1, cHourAux, "0" + cHourAux )
	cMinute	 := SubStr(cHourReq, nAt+1 ) + "0"
	cMinute  := SubStr(cMinute, 1, 2)
	nHourReq := Val( cHourAux + cMinute )
Else
	cHourReq := If( Len(cHourReq) > 1, cHourReq, "0" + cHourReq )
	nHourReq := Val( cHourReq += Replicate("0", 4 - Len(cHourReq)) )
EndIf

If nHourReq > nHour
	cMsg := STR0080 //"Não é possível incluir batidas em hora futura!"
	lRet := .F.
EndIf

Return( lRet )

/*/{Protheus.doc} fUpdGeoClock
Realiza a reprovacao de uma batida que foi incluida por geolocalizao.
@author:	Marcelo Silveira
@since:		25/06/2019
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			cCodRH3 - Codigo da solicitacao;
			cObserva - Motivo da rejeicao para ficar registrado na marcacao
			cEmpRest - Empresa
			lJob - A rotina esta sendo executada via job
			cUID - Identificacao do Job
@return:	lRet - Retorna verdadeiro (.T.) quando a operacao foi realizada com sucesso
/*/			
Function fUpdGeoClock( cBranchVld, cMatSRA, cCodRH3, cObserva, cEmpRest, lJob, cUID )

Local cAliasQry 	:= ""
Local cAliasMarc	:= "SP8"
Local nPos			:= 0
Local lRet			:= .F.
Local dPerIni		:= cTod("//")
Local dPerFim		:= cTod("//")

Private aMarcacoes	:= {}
Private aTabCalend  := {}
Private aTabPadrao	:= {}

DEFAULT lJob		:= .F.
DEFAULT cEmpRest	:= ""
DEFAULT cUID		:= ""

If lJob
	RPCSetType( 3 )
	RPCSetEnv( cEmpRest, cBranchVld )
EndIf

cAliasQry := GetNextAlias()

BeginSql alias cAliasQry
	SELECT * FROM %table:RH4% RH4 WHERE RH4.RH4_CODIGO = %exp:cCodRH3% AND RH4.%notDel%
EndSql

While !(cAliasQry)->(Eof())
	Do Case
		Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_FILIAL"
			cFilMat  := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('P8_FILIAL')[1])
		Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_MAT"
			cMat     := SubStr((cAliasQry)->RH4_VALNOV,1,TamSx3('P8_MAT')[1])
		Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_DATA"
			dData    := STOD( SubSTR( (cAliasQry)->RH4_VALNOV, 7, 4 ) + SubSTR( (cAliasQry)->RH4_VALNOV, 4, 2 ) + SubSTR( (cAliasQry)->RH4_VALNOV, 1, 2 ) )
		Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_HORA"
			nHora    := Val(StrTran((cAliasQry)->RH4_VALNOV,":","."))
		Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_LATITU"
			cLatitu  := AllTrim((cAliasQry)->RH4_VALNOV)						
		Case Alltrim((cAliasQry)->RH4_CAMPO) == "P8_LONGIT"
			cLongit  := AllTrim((cAliasQry)->RH4_VALNOV)
	EndCase
	(cAliasQry)->(dbskip())
Enddo

(cAliasQry)->( DBCloseArea() )

PerAponta(@dPerIni, @dPerFim, dData, .F., cBranchVld, .T., , , , .F.)

If !Empty(dPerIni) .And. !Empty(dPerFim) 

	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cBranchVld+cMatSRA))
	
		GetMarcacoes(	@aMarcacoes			,;	//01 -> Marcacoes do Funcionario
						@aTabCalend			,;	//02 -> Calendario de Marcacoes
						@aTabPadrao			,;	//03 -> Tabela Padrao
						NIL     			,;	//04 -> Turnos de Trabalho
						dPerIni				,;	//05 -> Periodo Inicial
						dPerFim				,;	//06 -> Periodo Final
						SRA->RA_FILIAL		,;	//07 -> Filial
						SRA->RA_MAT			,;	//08 -> Matricula
						SRA->RA_TNOTRAB		,;	//09 -> Turno
						SRA->RA_SEQTURN		,;	//10 -> Sequencia de Turno
						SRA->RA_CC			,;	//11 -> Centro de Custo
						cAliasMarc			,;	//12 -> Alias para Carga das Marcacoes
						.T.					,;	//13 -> Se carrega Recno em aMarcacoes
						.T.		 			,;	//14 -> Se considera Apenas Ordenadas
						NIL					,;  //15 -> Verifica as Folgas Automaticas
						NIL  				,;  //16 -> Se Grava Evento de Folga Mes Anterior
						NIL					,;	//17 -> Se Carrega as Marcacoes Automaticas
						NIL					,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
						NIL					,;	//19
						NIL					,;	//20
						NIL					,;	//21
						NIL					,;	//22
						.F.					,;	//23 -> Se carrega as marcacoes das duas tabelas SP8 e SPG
						)
	
		nPos := aScan( aMarcacoes , { |x| x[AMARC_DATA] == dData .And. x[AMARC_HORA] == nHora .And. AllTrim(x[AMARC_LATITU]) == cLatitu .And. AllTrim(x[AMARC_LONGIT]) == cLongit } ) 
	
		If nPos > 0
			lRet := .T.
			aMarcacoes[ nPos, AMARC_TPMCREP ] := "D"
			aMarcacoes[ nPos, AMARC_MOTIVRG ] := DecodeUTF8( cObserva )
			
			//Atualiza a marcacao que foi desconsiderada pelo gestor
			PutMarcacoes( { aMarcacoes[ nPos ] }, cBranchVld, cMatSRA, "SP8", .F., Nil, Nil, Nil, Nil )
		EndIf
		//Fecha as tabelas do ponto após utilização
		Pn090Close()

		//Atualiza a tabela RS3
		DbSelectArea("RS3")
		DbSetOrder(1)
		If DbSeek( RH3->(cBranchVld + cCodRH3) )
			RecLock("RS3",.F.)
			RS3->RS3_STATUS := "2" //Reprovado
			RS3->( MsUnLock() )
		EndIf

		//Atualiza a tabela RH3
		DbSelectArea("RH3")
		DbSetOrder(1)
		If RH3->( DbSeek(cBranchVld + cCodRH3) )
			RecLock("RH3",.F.)		
			RH3->RH3_STATUS := "3" //Reprovado
			RH3->RH3_DTATEN := dDataBase
			RH3->( MsUnLock() )
		EndIf
	
	EndIf
EndIf

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

Return( lRet )


/*/{Protheus.doc} fPerSPO
Retorna os Periodos de Apontamento da tabela SPO 
@author:	Marcelo Silveira
@since:		12/08/2020
@param:		cEmpSRA - Empresa;
			cFilSRA - Filial;
@return:	aPerSPO - Array com os ultimos 6 periodos de apontamento da SPO
/*/	
Function fPerSPO( cEmpSRA, cFilSRA )

Local nCount	:= 0
Local aPerSPO	:= {}
Local cFilSPO 	:= ""
Local cQrySPO 	:= ""
Local cSPOtab	:= ""
Local cDelete 	:= "% SPO.D_E_L_E_T_ = ' ' %"

If !Empty(cEmpSRA)

	cQrySPO := GetNextAlias()
	cSPOtab := "%" + RetFullName("SPO", cEmpSRA) + "%"
	cFilSPO := xFilial("SPO", cFilSRA)

	BeginSql ALIAS cQrySPO

        COLUMN PO_DATAINI AS DATE
        COLUMN PO_DATAFIM AS DATE

		SELECT PO_DATAINI, PO_DATAFIM 
		FROM %exp:cSPOtab% SPO
		WHERE 
			SPO.PO_FILIAL = %Exp:cFilSPO% AND
			%exp:cDelete%
		ORDER BY 2 DESC
	EndSql

	//Retorna somente os ultimos 6 periodos
	While (cQrySPO)->(!Eof()) .And. (nCount < 7)
		nCount ++
		aAdd( aPerSPO, { (cQrySPO)->PO_DATAINI, (cQrySPO)->PO_DATAFIM } ) 

		(cQrySPO)->( dbSkip() )
	End

	(cQrySPO)->( dbCloseArea() )

EndIf

Return( aPerSPO )


/*/{Protheus.doc} fAddMarc
Adiciona em aMarcacoes as marcacoes que ainda nao estao no Ponto Eletronico
@author:	Marcelo Silveira
@since:		13/01/2021
@param:		aRS3 - Marcacoes que vieram da tabela SR3 do período ou data 
			aRS3Ord - Marcacoes que vieram da tabela SR3 do período ou data (ja ordenadas e classificadas)
			aMarcacoes - Marcacoes oriundas do Ponto Eletronico (ja ordenadas e classificadas)
			aTabCalend - Calendario de marcacoes do Funcionario
@return:	aMarcacoes - Array com as marcacoes do ponto e tambem as que foram adicionadas
/*/	
Static Function fAddMarc(aRS3, aRS3Ord, aMarcacoes, aTabCalend)

Local cReject	:= ""
Local nX		:= 0
Local nZ		:= 0
Local nItens	:= 0
Local aTemp		:= {}
Local aReject	:= {}
Local aNewOrd	:= {}
Local lAtulizRFE := .F.

//Identifica as marcacoes da tabela RS3 que ainda nao foram para o Ponto
If Len(aMarcacoes) > 0
	For nX := 1 To Len(aRS3Ord)
		If aScan( aMarcacoes, {|x| DTOS(x[25]) + STR(x[2],5,2) == DTOS(aRS3Ord[nX,25]) + STR(aRS3Ord[nX,2],5,2) } ) == 0 .Or. ;
			(SubStr(aRS3Ord[nX, AMARC_MOTIVRG],1,2) == "99")
			aAdd( aTemp, aRS3Ord[nX] )
		EndIf
	Next nX
Else
	aTemp := aClone(aRS3Ord)
EndIf

nItens := Len( aTemp )

If nItens > 0

	aNewOrd := aClone(aMarcacoes)

	For nX := 1 To nItens

		cReject	:= SubStr(aTemp[nX, AMARC_MOTIVRG],1,2)

		If cReject == "99" //Batida reprovada
			aAdd( aReject, {} )
			aReject[Len(aReject)] := aClone(aTemp[nX])
		Else
			aAdd( aNewOrd, aTemp[nX] )
		EndIf

	Next nX

	aEval(aNewOrd ,{|x| If( Empty(x[AMARC_DTHR2STR]), x[AMARC_L_ORIGEM]:=.F., x[AMARC_L_ORIGEM] := .T.) } )
	PutOrdMarc( @aNewOrd, aTabCalend, NIL ,.T., NIL, NIL, NIL, NIL, NIL, NIL, lAtulizRFE)

	//Conserva os dados da solicitacao original
	For nZ := 1 To Len(aRS3)
		nReg := aScan( aNewOrd, {|x| DTOS(x[1]) + STR(x[2],5,2) == DTOS(aRS3[nZ,1]) + STR(aRS3[nZ,2],5,2) } )
		If nReg > 0 .And. !(SubStr(aRS3Ord[nZ, AMARC_MOTIVRG],1,2) == "99")
			aNewOrd[nReg, AMARC_MOTIVRG ] := aRS3[nZ,AMARC_MOTIVRG]
			aNewOrd[nReg, AMARC_TIPOREG ] := ""
		EndIf
	Next nZ	

	aMarcacoes := aClone(aNewOrd)

	//As marcacoes rejeitadas são adicionadas no final das marcaoes do dia.
	If Len(aReject) > 0

		//Reorndena as marcacoes rejeitadas para serem adicionadas no dia certo
		PutOrdMarc(@aReject, aTabCalend, NIL, NIL, NIL, NIL, NIL, NIL, NIL, NIL, lAtulizRFE)

		For nZ := 1 To Len(aReject)
			//[1] - Data, [2] - Horário, [3] - ID da requisição.
			nReg := aScan( aRS3, {|x| DTOS(x[1]) + STR(x[2],5,2) + x[29] == DTOS(aReject[nZ,1]) + STR(aReject[nZ,2],5,2) +  aReject[nZ,29]} )
			If nReg > 0
				aReject[nZ, AMARC_MOTIVRG ] := aRS3[nReg,AMARC_MOTIVRG]
				aReject[nZ, AMARC_TIPOREG ] := ""
			EndIf
			aAdd( aMarcacoes, {} )
			aMarcacoes[Len(aMarcacoes)] := aClone(aReject[nZ])
		Next nZ

	EndIf

EndIf

Return( aMarcacoes )

/*/{Protheus.doc} fChkDivergent
Verifica as divergencias de Marcacoes
@author:	Marcelo Silveira
@since:		11/02/2021
@param:		cBranchVld - Filial do funcionario
			cMatSRA - Matricula do funcionario
			cTnoSRA - Turno do funcionario
			aMarcacoes - Marcacoes oriundas do Ponto Eletronico (ja ordenadas e classificadas)
			dDataIni - Data inicio do periodo do ponto
			dDataFim - Data fim do periodo do ponto
@return:	aDados - Array com os dados de divergencias das marcacoes e apontamentos do periodo
/*/	
Static Function fChkDivergent( cBranchVld, cMatSRA, cTnoSRA, aMarcacoes, dDataIni, dDataFim, lOnlyDiv )

Local nX        := 0
Local nY        := 0
Local nLenMarc	:= 0
Local dData		:= CtoD("//")
Local aDados	:= {}
Local aAddMarc	:= {}
Local aNewMarc 	:= {}
Local cStr 		:= " "
Local cOrdem	:= ""
Local cWarning	:= "warning"

DEFAULT lOnlyDiv := .F.

nLenMarc := Len( aMarcacoes )

For nX := 1 To nLenMarc
	IF ( cOrdem := aMarcacoes[ nX, 03 ] ) == "ZZ" .Or. ("|R" $ aMarcacoes[ nX, 29 ])
		Loop
	EndIF	
	aAdd( aNewMarc, {} )
	For nY := nX To nLenMarc
		IF aMarcacoes[ nY, 03 ] == cOrdem .and. aMarcacoes[ nY, 03 ] != "ZZ"
			aAdd( aNewMarc[Len(aNewMarc)], aClone( aMarcacoes[ nY ] ) )
			aMarcacoes[ nY, 03 ] := "ZZ"
		Else
			Exit
		EndIF
	Next nY
Next nX

nLenMarc := Len(aNewMarc)

For nX := 1 to nLenMarc
	dData	:= aNewMarc[nX, 1, 1]

	If Len(aNewMarc[nX]) % 2 > 0 
		aAdd( aDados, { dData, cWarning, EncodeUTF8(STR0079) } ) //"Marcações Ímpares"
	EndIf
Next nX

//Verifica os atrasos e faltas a partir dos apontamentos e adiciona em aDados
fChkApo( cBranchVld, cMatSRA, cTnoSRA, dDataIni, dDataFim, @aDados, lOnlyDiv )

//Verifica se existe algum apontamento sem marcacao (exemplo: falta) e adiciona o registro em aMarcacoes para sair em divergencias
For nX := 1 To Len(aDados)

	IF aScan( aMarcacoes, {|x| x[1] == aDados[nX,1]} ) == 0
		aAddMarc := Array( 01, Array( ELEMENTOS_AMARC + 3 ) )

		aAddMarc[ 01, AMARC_DATA	] := aDados[nX,1]
		aAddMarc[ 01, AMARC_DATAAPO	] := aDados[nX,1]
		aAddMarc[ 01, AMARC_HORA	] := NIL
		aAddMarc[ 01, AMARC_FLAG	] := "P"
		aAddMarc[ 01, AMARC_MOTIVRG	] := "01" + "|" + cStr + "|" + cStr + "|" + cStr + "|" + cStr
		aAddMarc[ 01, AMARC_TIPOREG	] := ""	
		
		aAdd( aMarcacoes, aClone(aAddMarc[1]) )
	EndIf

Next nX

aSort(aDados,,,{ | x,y | x[1] < y[1] })

Return(aDados)

/*/{Protheus.doc} fChkApo
Retorna dados de atrasos e faltas para exibir nas divergencias do espelho de ponto
@author:	Marcelo Silveira
@since:		11/06/2019
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			cTnoSRA - Turno;
			cDtIni - Data inicio do periodo a ser pesquisado;
			cDtFim - Data Fim do periodo a ser pesquisado;
			aDados - Dados de divergencias ja obtidos a partir das marcacoes
/*/
Function fChkApo( cBranchVld, cMatSRA, cTnoSRA, cDtIni, cDtFim, aDados, lOnlyDiv )

Local nX			:= 0
Local aArea			:= {}
Local aEventos		:= {}
Local aCodAut		:= {}
Local lAdd			:= .F.
Local cDanger   	:= ""
Local cDiverg		:= ""
Local cCod			:= ""
Local cCodAbono		:= ""
Local cAliasQry		:= ""
Local cWhere 		:= ""
Local cJoinFil 		:= ""
Local cAliasAux 	:= ""
Local cPrefixo		:= ""
Local cIdFeA 		:= "007N|008A|009N|010A|021N|022A|019N|020A|011N|012A|013N|014A|" //IDS Faltas e Atrasos

Local dData			:= cToD("//")
Local dLastDt		:= cToD("//")
Local dIniPonMes	:= cToD("//")
Local dFimPonMes	:= cToD("//")
Local lImpAcum		:= .T.

DEFAULT lOnlyDiv := .F.

If !Empty(cDtIni) .And. !Empty(cDtFim)

	aArea		:= GetArea()
	cAliasQry	:= GetNextAlias()

	GetPonMesDat( @dIniPonMes , @dFimPonMes , cBranchVld )
	lImpAcum 	:= cDtFim < dIniPonMes
	cAliasAux 	:= If( lImpAcum, "SPH", "SPC")
	cPrefixo	:= If( lImpAcum, "PH_", "PC_")		

	cWhere += "%"
	cWhere += cPrefixo + "FILIAL = '" + cBranchVld + "' AND "
	cWhere += cPrefixo + "MAT = '" + cMatSRA + "' AND "
	cWhere += cPrefixo + "DATA >= '" + dToS(cDtIni) + "' AND "
	cWhere += cPrefixo + "DATA <= '" + dToS(cDtFim) + "' "
	cWhere += "%"

	//Carrega codigos de HE Autorizadas/Não autorizadas
	aCodAut := fGetCodHE(cBranchVld, cTnoSRA)

	If lImpAcum
	
		cJoinFil:= "%" + FWJoinFilial("SPH", "SP9") + "%"
	
		BeginSql Alias cAliasQry
		
		 	SELECT             
				SPH.PH_DATA, 
				SPH.PH_PD, 
				SPH.PH_PDI , 
				SPH.PH_QUANTC, 
				SPH.PH_QUANTI,
				SPH.PH_ABONO, 
				SPH.PH_QTABONO, 
				SP9.P9_CODIGO, 
				SP9.P9_IDPON,
				SP9.P9_DESC
			FROM 
				%Table:SPH% SPH
			INNER JOIN %Table:SP9% SP9
			ON %exp:cJoinFil% AND SP9.%NotDel% AND SPH.PH_PD = SP9.P9_CODIGO		
			WHERE
				%Exp:cWhere% AND SPH.%NotDel%
			ORDER BY SPH.PH_DATA, SPH.PH_PD
		
		EndSql 	
	Else
		cJoinFil:= "%" + FWJoinFilial("SPC", "SP9") + "%"
		
		BeginSql Alias cAliasQry
		
		 	SELECT             
				SPC.PC_DATA, 
				SPC.PC_PD, 
				SPC.PC_PDI,
				SPC.PC_QUANTC, 
				SPC.PC_QUANTI,
				SPC.PC_ABONO, 
				SPC.PC_QTABONO, 
				SP9.P9_CODIGO, 
				SP9.P9_IDPON,
				SP9.P9_DESC
			FROM 
				%Table:SPC% SPC
			INNER JOIN %Table:SP9% SP9
			ON %exp:cJoinFil% AND SP9.%NotDel% AND SPC.PC_PD = SP9.P9_CODIGO			
			WHERE
				%Exp:cWhere%  AND SPC.%NotDel%
			ORDER BY SPC.PC_DATA, SPC.PC_PD	
		EndSql 	
	EndIf
	
	While !(cAliasQry)->(Eof())

		lAdd	:= .F.
		cCod 	:= (cAliasQry)->P9_CODIGO
		dData 	:= sTod((cAliasQry)->&(cPrefixo+"DATA"))
		dLastDt	:= If( Empty(dLastDt), dData, dLastDt )

		If !(dLastDt == dData)
			For nX := 1 To Len( aEventos )
				If aScan( aDados, {|x| x[1] == dLastDt .And. x[3] == aEventos[nX,3] } ) == 0
					aAdd(aDados, {dLastDt, aEventos[nX,2], aEventos[nX,3]} )
				EndIf
			Next nX

			aEventos := {}
			dLastDt  := dData			
		EndIf

		//Prioriza o abono, depois o código informado, depois o código calculado.
		If !Empty((cAliasQry)->&(cPrefixo+"ABONO") )
			//Nao considera o evento de falta/atraso quando abono é igual a quantidade calculada
			If lOnlyDiv .And. (cAliasQry)->&(cPrefixo+"QTABONO") >= (cAliasQry)->&(cPrefixo+"QUANTC")
				(cAliasQry)->(DbSkip())
				Loop
			Else
				cCodAbono := (cAliasQry)->&(cPrefixo+"ABONO")
				If (cAliasQry)->&(cPrefixo+"QTABONO") >= (cAliasQry)->&(cPrefixo+"QUANTC")
					cDanger	:= "success"
					cDiverg := EncodeUTF8( STR0120 ) //"Abono Total"
				Else
					cDanger	:= "success"
					cDiverg := EncodeUTF8( STR0119 ) //"Abono Parcial"
				EndIf
				aAdd( aEventos, { cCodAbono, cDanger, cDiverg } )
			EndIf
		ElseIf !Empty((cAliasQry)->&(cPrefixo+"PDI") )
			cCod := (cAliasQry)->&(cPrefixo+"PDI")
		EndIf

		Do Case
			Case (cAliasQry)->P9_IDPON $ cIdFeA //Atrasos e Faltas
				cDanger	:= "danger"
				cDiverg := EncodeUTF8( STR0078 ) //"Jornada Incompleta"
				lAdd	:= .T.
			Case !lOnlyDiv .And. cCod $ aCodAut[1] //HE Autorizada
				cDanger	:= "authorizedOvertime"
				cDiverg := EncodeUTF8( STR0082 ) //"Hora Extra Autorizada"
				lAdd	:= .T.
			Case !lOnlyDiv .And. cCod $ aCodAut[2] //HE Não Autorizada
				cDanger	:= "unauthorizedOvertime"
				cDiverg := EncodeUTF8( STR0083 ) //"Hora Extra Não Autorizada"
				lAdd	:= .T.
		End Case

		If lAdd .And. aScan( aEventos, {|x| x[1]+x[3] == cCod+cDiverg } ) == 0
			aAdd( aEventos, { cCod, cDanger, cDiverg } )
		EndIf
	
		(cAliasQry)->(DbSkip())
	EndDo

	//Adiciona o ultimo registro processado que nao foi adicionado dentro do laço
	If !Empty(aEventos)
		For nX := 1 To Len(aEventos)
			If aScan( aDados, {|x| x[1] == dLastDt .And. x[3] == aEventos[nX,3] } ) == 0
				aAdd( aDados, {dLastDt, aEventos[nX,2], aEventos[nX,3]} )
			EndIf
		Next nX
	EndIf
	
	(cAliasQry)->(DbCloseArea())

	RestArea( aArea )
EndIf

Return()


/*/{Protheus.doc} fMyBalance
Retorna o banco de horas do funcionario conforme o periodo que esta sendo pesquisado.
@author:	Henrique Ferreira
@since:		18/02/2021
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			cPerIni - Data inicio do periodo a ser pesquisado;
			cPerFim - Data Fim do periodo a ser pesquisado;
			lSexagenal - Se calcula em formato sexagesimal ou centensimal;
@return:	Array - banco de horas do periodo
/*/
Function fMyBalance( cBranchVld, cMatSRA, cIniPer, cFimPer, lSexagenal, cEmpJob, lJob, cUID )
Local aRetSaldo   := {0,0,0}
Local aArea       := {}
Local cDtIni      := ""
Local cDtFim      := ""
Local cTpCod      := ""
Local cAliasSPI   := ""
Local nValor      := 0
Local nCurrent    := 0
Local nCredito    := 0
Local nDebito     := 0
Local nSaldoAtu   := 0
Local nSaldoAnt   := 0
Local lValoriza   := .F. //Utiliza saldo de BH valorizado .T. ou real .F. (padrao))  

Default cEmpJob		:= cEmpAnt
Default lJob		:= .F.

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( cEmpJob, cBranchVld )
EndIf

cDtIni		:= StrTran( SubStr(cIniPer, 1, 10), "-", "" )
cDtFim		:= StrTran( SubStr(cFimPer, 1, 10), "-", "" )
lValoriza   := GetMvMrh("MV_TCFBHVL",.F.,.F.,cBranchVld)

If !Empty(cDtIni) .And. !Empty(cDtFim)
	
	aArea     := GetArea()
	cAliasSPI := GetNextAlias()

	BeginSql alias cAliasSPI
	SELECT PI_FILIAL, PI_MAT, PI_PD, PI_QUANT, PI_QUANTV, PI_DATA, PI_STATUS, PI_DTBAIX
	FROM %table:SPI% SPI
	WHERE 	
		SPI.PI_FILIAL = %exp:cBranchVld% AND 
		SPI.PI_MAT = %exp:cMatSRA% AND
		SPI.%notDel%
	ORDER BY 
		SPI.PI_FILIAL, SPI.PI_MAT, SPI.PI_DATA	
	EndSql

	While (cAliasSPI)->( !Eof() )

		PosSP9((cAliasSPI)->PI_PD, (cAliasSPI)->PI_FILIAL)
		cTpCod := SP9->P9_TIPOCOD 

		// Totaliza Saldo Anterior
		If (cAliasSPI)->PI_DATA < cDtIni
			If !((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX < cDtIni)
				If ((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX <= cDtFim)

					If cTpCod $ "1*3"

						nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
						If lSexagenal
							nSaldoAnt := __TimeSum(nSaldoAnt,nValor)  
							nSaldoAtu := __TimeSub(nSaldoAtu,nValor)
						Else
							nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D",,5) 
							nSaldoAtu := nSaldoAtu - fConvhR(nValor,"D",,5) 
						EndIf 
					Else
						nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
						If lSexagenal
							nSaldoAnt := __TimeSub(nSaldoAnt,nValor)
							nSaldoAtu := __TimeSum(nSaldoAtu,nValor)    
						Else
							nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D",,5)
							nSaldoAtu := nSaldoAtu + fConvhR(nValor,"D",,5)  
						EndIf
					EndIf
				Else
					If cTpCod $ "1*3"
									
						nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
						If lSexagenal
							nSaldoAnt := __TimeSum(nSaldoAnt,nValor)  
						Else
							nSaldoAnt := nSaldoAnt + fConvhR(nValor,"D",,5) 
						EndIf 		
					Else
						nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
						If lSexagenal
							nSaldoAnt := __TimeSub(nSaldoAnt,nValor)  
						Else
							nSaldoAnt := nSaldoAnt - fConvhR(nValor,"D",,5) 
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf (cAliasSPI)->PI_DATA <= cDtFim
			If !((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX <= cDtFim)
				If cTpCod $ "1*3"	
					nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
					If lSexagenal
						nCredito := __TimeSum(nCredito,nValor)  
					Else
						nCredito := nCredito + fConvhR(nValor,"D",,5) 
					EndIf 
				Else
					nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
					If lSexagenal
						nDebito := __TimeSum(nDebito,nValor)  
					Else
						nDebito := nDebito + fConvhR(nValor,"D",,5) 
					EndIf
				EndIf
			EndIf	
		EndIf
		(cAliasSPI)->(DbSkip())
  	EndDo
	(cAliasSPI)->( DBCloseArea() )
	
	If nSaldoAnt <> 0 .or. nCredito > 0 .or. nDebito > 0
		If lSexagenal
			nSaldoAtu := __TimeSum(nSaldoAtu, __TimeSub( __TimeSum( nSaldoAnt , nCredito ) , nDebito ))
			nCurrent  := __TimeSub( nCredito, nDebito )
		Else
			nSaldoAtu := ( nSaldoAtu + nSaldoAnt + nCredito ) - nDebito
			nCurrent  := nCredito - nDebito
		EndIf
		aRetSaldo := { nSaldoAnt, nSaldoAtu, nCurrent }
	EndIf
	RestArea( aArea )
EndIf
Pn090Close()

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

Return( aRetSaldo )


/*/{Protheus.doc} fTeamBalanc
Retorna o banco de horas do funcionario conforme o periodo que esta sendo pesquisado.
@author:	Henrique Ferreira
@since:		18/02/2021
@param:		cBranchVld - Filial;
			cMatSRA - Matricula;
			cPerIni - Data inicio do periodo a ser pesquisado;
			cPerFim - Data Fim do periodo a ser pesquisado;
			lSexagenal - Se calcula em formato sexagesimal ou centensimal;
@return:	Array - banco de horas do periodo
/*/
Function fTeamBalanc(cBranchVld, cMatSRA, cIniPer, cFimPer, lSexagenal)
	Local aRetSaldo   := {0,0}
	Local aVision	  := {}
	Local aPerAll     := {}
	Local aTipoAll    := {}
	Local aPeriods	  := {}
	Local aCoordTeam  := {}
	Local aEmpresas   := {}
	Local cDtIni      := ""
	Local cDtFim      := ""
	Local cTpCod      := ""
	Local cAliasSPI   := ""
	Local cRoutine    := "W_PWSA300.APW" 	//Banco de Horas.
	Local cVision	  := ""
	Local cEmpAtu     := ""
	Local cFilAtu     := ""
	Local cMatAtu     := ""
	Local cLastFil	  := ""
	Local cPerIni     := ""
	Local cPerFim     := ""
	Local cQryObj     := ""
	Local nX          := 0
	Local nPosEve     := 0
	Local nValor      := 0
	Local nCredito    := 0
	Local nDebito     := 0
	Local lValoriza   := GetMvMrh("MV_TCFBHVL",.F.,.F.,cBranchVld) //Utiliza saldo de BH valorizado .T. ou real .F. (padrao))  
	Local cOrgCFG     := SuperGetMv("MV_ORGCFG", NIL, "0")

	cDtIni 	:= StrTran( SubStr(cIniPer, 1, 10), "-", "" )
	cDtFim 	:= StrTran( SubStr(cFimPer, 1, 10), "-", "" )

	//Busca os dados da equipe caso a requisicao seja do saldo do time
	aVision    := GetVisionAI8(cRoutine, cBranchVld)
	cVision    := aVision[1][1]

	If cOrgCFG == "2"
		fGetTeamManager(cBranchVld, cMatSRA, @aEmpresas, cRoutine, cOrgCFG, .T.)
	Else
		aEmpresas := {cEmpAnt}
	EndIf

	cMRrhKeyTree := fMHRKeyTree(cBranchVld, cMatSRA)
	aCoordTeam := APIGetStructure("", "", cVision, cBranchVld, cMatSRA, , , , , cBranchVld, cMatSRA, , , , , .T., aEmpresas)

	If Len(aCoordTeam) > 0 .And. !ValType( aCoordTeam[1] ) == "L"
		For nX := 1 To Len( aCoordTeam[1]:ListOfEmployee )

			cEmpAtu := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeEmp
			cFilAtu := aCoordTeam[1]:ListOfEmployee[nX]:EmployeeFilial
			cMatAtu := aCoordTeam[1]:ListOfEmployee[nX]:Registration


			If !(cFilAtu + cMatAtu == cBranchVld + cMatSRA) //Nao considera a Filial+Matricula do lider/gestor
				
				If oSPISummary == Nil .Or. cLtEmpSumm != cEmpAtu
					cQryObj := "SELECT"
					cQryObj += " PI_FILIAL, PI_MAT, PI_PD, PI_QUANT, PI_QUANTV, PI_DATA, PI_STATUS, PI_DTBAIX"
					cQryObj += " FROM " + RetFullName("SPI", cEmpAtu) + " SPI "
					cQryObj += " WHERE SPI.PI_FILIAL = ? "
					cQryObj += " AND SPI.PI_MAT = ? "
					cQryObj += " AND SPI.D_E_L_E_T_ = ' '"
					cQryObj := ChangeQuery(cQryObj)
					oSPISummary := FWExecStatement():New(cQryObj)
					cLtEmpSumm := cEmpAtu
				EndIf

				//DEFINIÇÃO DOS PARÂMETROS.
				oSPISummary:SetString(1, cFilAtu)
				oSPISummary:SetString(2, cMatAtu)

				cAliasSPI := oSPISummary:OpenAlias()

				While (cAliasSPI)->(!Eof())

					If (cLastFil <> (cAliasSPI)->PI_FILIAL)
						//Se nao vier o periodo na requisicao considera o que estiver aberto no ponto

						IF ( nPosPer := aScan(aPerAll, {|x| x[1] == cEmpAtu .And. x[2] == (cAliasSPI)->PI_FILIAL }) ) > 0
							cPerIni := aPerAll[nPosPer, 3]
							cPerFim := aPerAll[nPosPer, 4]
						Else
							If cEmpAnt == cEmpAtu
								aPeriods := GetPeriodApont( (cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_MAT, 1)
							Else
								aPeriods := GetDataForJob( "1", {(cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_MAT, Nil}, cEmpAtu )
							EndIf						
							
							If Len(aPeriods) > 0
								//Considera o periodo de um ano na pesquisa
								cPerIni := dToS( aPeriods[1,1] )
								cPerFim := dToS( aPeriods[1,2] )
							EndIf
							cLastFil := (cAliasSPI)->PI_FILIAL
							cDtIni 	:= StrTran( SubStr(cPerIni, 1, 10), "-", "" )
							cDtFim 	:= StrTran( SubStr(cPerFim, 1, 10), "-", "" )

							aAdd( aPerAll, { cEmpAtu, (cAliasSPI)->PI_FILIAL, cPerIni, cPerFim } )
						EndIf
					EndIf				

					IF ( nPosEve := aScan(aTipoAll, {|x| x[1]+x[2]+x[3] == cEmpAtu + (cAliasSPI)->PI_FILIAL + (cAliasSPI)->PI_PD}) ) > 0
						cTpCod := aTipoAll[nPosEve, 4]
					Else
						cTpCod := GetTpEvent(cEmpAtu, (cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_PD)
						aAdd( aTipoAll, { cEmpAtu, (cAliasSPI)->PI_FILIAL, (cAliasSPI)->PI_PD, cTpCod} )
					EndIf				

					If (cAliasSPI)->PI_DATA <= cDtFim
						If !((cAliasSPI)->PI_STATUS == 'B' .AND. (cAliasSPI)->PI_DTBAIX <= cDtFim)
							If cTpCod $ "1*3"
										
								nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
								If lSexagenal
									nCredito := __TimeSum(nCredito,nValor)  
								Else
									nCredito := nCredito + fConvhR(nValor,"D",,5) 
								EndIf 
							Else
								nValor := If( lValoriza, (cAliasSPI)->PI_QUANTV, (cAliasSPI)->PI_QUANT )
								If lSexagenal
									nDebito := __TimeSum(nDebito,nValor)  
								Else
									nDebito := nDebito + fConvhR(nValor,"D",,5) 
								EndIf
							EndIf
						EndIf	
					Endif
					(cAliasSPI)->(DbSkip())
				EndDo
				(cAliasSPI)->(DBCloseArea())
			EndIf
		Next nX
	EndIf

	If nCredito > 0 .or. nDebito > 0
		aRetSaldo := { nCredito, nDebito } //Saldo total do time
	EndIf

	Pn090Close()

Return( aRetSaldo )

/*/{Protheus.doc} fGetCodHE
Retorna os Codigos de Hora Extra Autorizadas/Não Autorizadas
@author:	Marcelo Silveira
@since:		07/04/2021
@param:		cFilSRA - Filial;
			cTnoSRA - Turno;
@return:	aCodigos - Array com codigos de HE
/*/	
Static Function fGetCodHE( cFilSRA, cTnoSRA )

Local nX		:= 0
Local nPos		:= 0
Local lRetTno	:= .F.
Local aCodHE	:= {}
Local aCodTno 	:= {"", ""} //Eventos de HE = 1 Autorizada, 2 Não Autorizada
Local aCodigos 	:= {"", ""} //Eventos de HE = 1 Autorizada, 2 Não Autorizada

fTabSP4(@aCodHE, xFilial("SP4", cFilSRA))

For nX := 1 To Len( aCodHE )
	nPos := If( aCodHE[nX, 4] == "A", 1, 2 )

	If aCodHE[nX, 2] == cTnoSRA
		aCodTno[nPos] += aCodHE[nX, 3] + "|"
		lRetTno := .T.
	ElseIf Empty(aCodHE[nX, 2])
		aCodigos[nPos] += aCodHE[nX, 3] + "|"
	EndIf
Next nX 

Return( If( lRetTno, aCodTno, aCodigos )  )


/*/{Protheus.doc} GetTpEvent
Retorna o Tipo do Evento a partir de um codigo
@author:	Marcelo Silveira
@since:		03/09/2021
@param:		xCodEmp - Codigo da empresa para abertura da tabela
			xCodFil - Codigo da Filial
			xCodEve - Codigo do evento
@return:	cRet - Tipo do evento conforme o codigo
/*/	
Function GetTpEvent(xCodEmp, xCodFil, xCodEve)

Local cQuery   := GetNextAlias()
Local cRet     := ""
Local cSP9tab  := "%" + RetFullName("SP9", xCodEmp) + "%"

BEGINSQL ALIAS cQuery

	SELECT DISTINCT
		P9_FILIAL, P9_CODIGO, P9_TIPOCOD
	FROM 
		%exp:cSP9tab% SP9
	WHERE
		SP9.P9_CODIGO = %Exp:xCodEve% AND
		SP9.%NotDel%
ENDSQL

While !(cQuery)->(Eof()) 
	If Empty( AllTrim((cQuery)->P9_FILIAL)) .Or. AllTrim((cQuery)->P9_FILIAL) $ xCodFil
		cRet := (cQuery)->P9_TIPOCOD
		Exit
	EndIf

	(cQuery)->(dbSkip())
EndDo

(cQuery)->(dbCloseArea())

Return(cRet)

/*/{Protheus.doc} GetAboDesc
Retorna a descrição de um motivo de abono a partir do código
@author:	Marcelo Silveira
@since:		17/01/2022
@param:		xCodEmp - Codigo da empresa para abertura da tabela
			xCodFil - Codigo da Filial
			xCodEve - Codigo do evento
@return:	cRet - Descrição do motivo
/*/	
Function GetAboDesc(xCodEmp, xCodFil, xCodEve)

Local cRet		:= ""
Local cSP6tab	:= ""
Local cQrySP6	:= ""

DEFAULT xCodEmp := ""
DEFAULT xCodFil := ""
DEFAULT xCodEve := ""

If !Empty(xCodEve)
	
	cSP6tab	:= "%" + RetFullName("SP6", xCodEmp) + "%"

	cQrySP6	:= GetNextAlias()

	BEGINSQL ALIAS cQrySP6

		SELECT DISTINCT
			P6_FILIAL, P6_CODIGO, P6_DESC
		FROM 
			%exp:cSP6tab% SP6
		WHERE
			SP6.P6_CODIGO = %Exp:xCodEve% AND
			SP6.%NotDel%
	ENDSQL

	While !(cQrySP6)->(Eof()) 
		If Empty( AllTrim((cQrySP6)->P6_FILIAL)) .Or. AllTrim((cQrySP6)->P6_FILIAL) $ xCodFil
			cRet := AllTrim( (cQrySP6)->P6_DESC )
			Exit
		EndIf

		(cQrySP6)->(dbSkip())
	EndDo

	(cQrySP6)->(dbCloseArea())

EndIf

Return(cRet)

/*/{Protheus.doc} GetPdDesc
Retorna a descrição de um evento a partir de um codigo
@author:	Marcelo Silveira
@since:		17/01/2022
@param:		xCodEmp - Codigo da empresa para abertura da tabela
			xCodFil - Codigo da Filial
			xCodEve - Codigo do evento
@return:	cRet - Descrição do evento conforme o codigo
/*/	
Function GetPdDesc(xCodEmp, xCodFil, xCodEve)

Local cQuery   := ""
Local cRet     := ""
Local cSP9tab  := ""

If !Empty(xCodEve)

	cQuery   := GetNextAlias()

	cSP9tab  := "%" + RetFullName("SP9", xCodEmp) + "%"

	BEGINSQL ALIAS cQuery

		SELECT DISTINCT
			P9_FILIAL, P9_CODIGO, P9_DESC
		FROM 
			%exp:cSP9tab% SP9
		WHERE
			SP9.P9_CODIGO = %Exp:xCodEve% AND
			SP9.%NotDel%
	ENDSQL

	While !(cQuery)->(Eof()) 
		If Empty( AllTrim((cQuery)->P9_FILIAL)) .Or. AllTrim((cQuery)->P9_FILIAL) $ xCodFil
			cRet := AllTrim( (cQuery)->P9_DESC )
			Exit
		EndIf

		(cQuery)->(dbSkip())
	EndDo

	(cQuery)->(dbCloseArea())

EndIf

Return(cRet)



/*/{Protheus.doc} FileClocking
Retorna o arquivo PDF do espelho de ponto do Meu RH
@author:	Marcelo Silveira
@since:		28/01/2022
@param:		xCodEmp - Codigo da empresa 
			xCodFil - Codigo da Filial do funcionario
			xMatSRA - Codigo da Matricula do funcionario
			cIniPer - Data inicial do periodo do ponto
			cEndPer - Data final do periodo do ponto
			cFileName - Nome do arquivo
			aProcFun - Funcionarios a serem processados
			lJob - Indica que a execução será feita via job
			cUID - Id da thread quando executado via job
@return:	cRet - Conteudo do arquivo
/*/	
Function FileClocking(xCodEmp, xCodFil, xMatSRA, cIniPer, cEndPer, cFileName, aProcFun, lJob, cUID)

Local oFile			:= Nil
Local cArqLocal		:= ""
Local cExtFile		:= ""
Local cFile			:= ""
Local cPer			:= ""
Local cPDF			:= ".PDF"
Local nX			:= 0
Local nCont			:= 0
Local aPeriods		:= {}
Local lContinua		:= .F.
Local lImpEsp 		:= ExistBlock("IMPESP")

DEFAULT cIniPer		:= ""
DEFAULT cEndPer		:= ""
DEFAULT xCodEmp		:= cEmpAnt
DEFAULT cFileName	:= ""
DEFAULT cUID		:= ""
DEFAULT lJob		:= .F.

If lJob
	//Instancia o ambiente para a empresa onde a funcao sera executada
	RPCSetType( 3 )
	RPCSetEnv( xCodEmp, xCodFil )
EndIf

//Posiciona a tabela SRA na matricula que esta sendo impressa
dbSelectArea("SRA")
dbSetOrder(1)
If dbSeek( xCodFil + xMatSRA )

	cExtFile	:= DTOS( DATE() ) + SubStr( TIME(), 1, 2) //Ano + Mes + Dia + Hora	
	cArqLocal 	:= GetSrvProfString ("STARTPATH","")

	//Se nao vier o periodo na requisicao considera o que estiver aberto no ponto
	If Empty(cIniPer + cEndPer) 
		aPeriods := GetPerAponta( 1, xCodFil , xMatSRA, .F.)
		If Len(aPeriods) > 0
			cPer := dToS( aPeriods[1,1] ) + dToS( aPeriods[1,2] ) //Ex.: 2019070120190731 
		EndIf
	else
		cPer := cIniPer + cEndPer
	EndIf

	//Valida se a admissao eh inferior ao final do periodo do ponto que esta aberto
	If !Empty(cPer) .And. Len(cPer) >= 16
		lContinua := dToS( SRA->RA_ADMISSA ) <= SubStr( cPer, 9, 8 )
	EndIf
	
	If lContinua
		
		//------------------------------------------------------------------------------
		//Existe um problema ainda nao solucionado que o APP envia mais de uma requisicao via mobile
		//Quando isso ocorre o sistema nao gera o arquivo e envia uma resposta sem conteudo. 
		//Solucao paliativa:
		//Caso alguma requisicao falhe tentaremos gerar o arquivo novamente por 5 vezes no maximo
		//Cada nova requisicao ira gerar o arquivo com um nome diferente (Filial + Matricula + nX) 
		//------------------------------------------------------------------------------
		For nX := 1 To 3

			//Se existir o arquivo REL/PDF nao executamos a PONR010 porque indica uma requisicao em andamento
			If !File( cArqLocal + cFileName + cExtFile + '*' )
				//Faz a geracao do arquivo PDF do espelho do ponto
				If lImpEsp
					U_IMPESP( .T., xCodFil, xMatSRA, cPer, , {}, .T., cFileName + cExtFile + cValToChar(nX), aProcFun)
				Else
					PONR010( .T., xCodFil, xMatSRA, cPer, , {}, .T., cFileName + cExtFile + cValToChar(nX), aProcFun)
				EndIf
			EndIf
		
			//Avalia o arquivo gerado no servidor
			While lContinua
				
				If File( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
					oFile := FwFileReader():New( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
					
					If (oFile:Open())
						cFile := oFile:FullRead()
						oFile:Close()
					EndIf
				EndIf
		
				//Em determinados ambientes pode ocorrer demora na geracao do arquivo, entao tentar localizar por 5 segundos no maximo.
				If ( lContinua := Empty(cFile) .And. nCont <= 4 )
					nCont++
					Sleep(1000)
				EndIf
			End
		
			If !Empty(cFile)
				Exit
			Else
				lContinua := .T.
				Conout( EncodeUTF8(">>>"+ STR0042 +"("+ cValToChar(nX) +")") ) //"Aguardando a geracao do espelho do ponto..."
			EndIf

		Next nX
		
		//Fecha as tabelas do ponto após utilização
		Pn090Close()
	EndIf    
EndIf

If lJob
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
EndIf

Return(cFile)

/*/{Protheus.doc} fChkPerTransf
Avalia os periodos do espelho de ponto Meu RH para alterar as datas em caso de transferencias 
@author:	Marcelo Silveira
@since:		25/03/2022
@param:		aIdFunc - Dados do funcionario (Filial, Matricula e Empresa)
			initPeriod - Data inicial do periodo
			endPeriod - Data final do periodo
			aTransf - Array com as transferencias
			aData - Array com a relação de períodos do funcionario
			lPerAtual - Indica se o período está ativo
@return:	cIdPer - Identificação do período conforme a transferencia
/*/	
Function fChkPerTransf( aIdFunc, initPeriod, endPeriod, aTransf, aData, lPerAtual )

	Local nX 			:= 0
	Local nTRFAtu		:= 0
	Local cIdPer		:= ""
	Local aPerSPO		:= {}
	Local dDtTRF		:= cToD("//")
	Local dDataIni		:= initPeriod
	Local dDataFim		:= endPeriod
	Local lMesTRF		:= .F.
	Local lTemSPO		:= .F.

	DEFAULT aTransf 	:= {}
	DEFAULT aData 		:= {}
	DEFAULT lPerAtual	:= .F.

	//cIdPer = FILIAL +|+ MATRICULA +|+ QUANTIDADE
	//----------------------------------------------
	//cIdPer = Se vazio indica que o processamento será conforme a Filial/Matricula atual
	//QUANTIDADE = 1 vai gerar dados da Filial/Matricula que está na chave
	//QUANTIDADE = 2 vai gerar dados da Filial/Matricula que está na chave e também da Filial/Matricula atual  

	For nX := 1 To Len(aTransf)
		If Empty(cIdPer) .Or. !(cIdPer == aTransf[nX,8] +"|"+ aTransf[nX,9] )
			If aTransf[nX,7] >= endPeriod .Or. (aTransf[nX,7] >= initPeriod .And. aTransf[nX,7] <= endPeriod)
				//Obtem a relação de períodos fechados a partir da Filial da transferencia 
				aPerSPO	:= fPerSPO( aTransf[nX,1], aTransf[nX,8] )
				cIdPer	:= rc4crypt( aTransf[nX,8] +"|"+ aTransf[nX,9] + "|1", "MeuRH#PeriodoId" ) //Filial Origem + Matricula origem
				lMesTRF	:= MesAno(aTransf[nX,7]) $ (MesAno(endPeriod) +"|"+ MesAno(initPeriod))
				dDtTRF	:= aTransf[nX,7]
				nTRFAtu := nX
			EndIf
		EndIf
	Next nX

	//Altera o período que será exibido conforme os dados transferencia
	For nX := 1 To Len(aPerSPO)
		If MesAno(aPerSPO[nX,1]) == MesAno(initPeriod) .Or. MesAno(aPerSPO[nX,2]) == MesAno(endPeriod)
			dDataIni := aPerSPO[nX,1]
			dDataFim := aPerSPO[nX,2]
			lTemSPO  := .T.

			//Se cada Filial trabalha com período de apontamento diferente e a transferencia
			//ocorreu numa interseccao de períodos, então apresenta os períodos de ambas as filiais
			If lMesTRF 
				If (!dDataIni == initPeriod .Or. !endPeriod == dDataFim)
					aAdd( aData, {initPeriod, endPeriod, lPerAtual, "" } )
				Else
					cIdPer := If( !Empty(dDtTRF) .And. Day(dDtTRF) > Day(initPeriod), rc4crypt( aTransf[nTRFAtu,8] +"|"+ aTransf[nTRFAtu,9] + "|2", "MeuRH#PeriodoId" ), "")
				EndIf
			EndIf
		EndIf
	Next nX

	If !lTemSPO .And. lMesTRF
		cIdPer := If( !Empty(dDtTRF) .And. Day(dDtTRF) > Day(initPeriod), rc4crypt( aTransf[nTRFAtu,8] +"|"+ aTransf[nTRFAtu,9] + "|2", "MeuRH#PeriodoId" ), "")
	EndIf

	initPeriod	:= dDataIni 
	endPeriod	:= dDataFim

Return( cIdPer )

/*/{Protheus.doc} fMontaOcc
	(long_description)
	@type  Function
	@author user
	@since 02/01/2023
	@version version
	@param aTabCalend, dInicio, dFim, @aData
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function fMontaOcc(cBranchVld, cMatSRA, dInicio, dFim, cEmpJob, lJob, cUID)

	Local oOcc 		 := JsonObject():New()
	Local oItem		 := JsonObject():New()

	Local aTurnos	 := {}
	Local aTabPadrao := {}
	Local aTabCalend := {}
	Local aOcc		 := {}
	Local aArea      := GetArea()

	Local dDtBase    := dFim

	Local nDias		 := 0
	Local nDia		 := 0

	Local cOccur	 := ""

	Default lJob     := .F.
	Default cUID	 := ""

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( cEmpJob, cBranchVld )
	EndIf

	DbSelectArea("SRA")
	DbSetOrder(1)
	If SRA->(dbSeek( cBranchVld + cMatSRA ))

		If SRA->( CriaCalend(	dInicio				,; //01 -> Data Inicial do Periodo
								dFim				,; //02 -> Data Final do Periodo
								SRA->RA_TNOTRAB		,; //03 -> Turno Para a Montagem do Calendario
								SRA->RA_SEQTURN		,; //04 -> Sequencia Inicial para a Montagem Calendario
								@aTabPadrao			,; //05 -> Array Tabela de Horario Padrao
								@aTabCalend			,; //06 -> Array com o Calendario de Marcacoes
								SRA->RA_FILIAL		,; //07 -> Filial para a Montagem da Tabela de Horario
								SRA->RA_MAT			,; //08 -> Matricula para a Montagem da Tabela de Horario
								SRA->RA_CC			,; //09 -> Centro de Custo para a Montagem da Tabela
								@aTurnos		,; //10 -> Array com as Trocas de Turno
								NIL				,; //11 -> Array com Todas as Excecoes do Periodo
								NIL	 			,; //12 -> Se executa Query para a Montagem da Tabela Padrao
								.F.				,; //13 -> Se executa a funcao se sincronismo do calendario
								.F.				,; //14 -> Se Forca a Criacao de Novo Calendario
								NIL  			,; //15 -> Array com marcacoes para tratamento de Turnos Opcionais
								.F.  			,; //16 -> .T. Determina a Criacao/Carga do Calendario Fisico
								NIL				,; //17 -> .T. Caso exista calendario fisico 
								NIL				,; //18 -> Data inicial do calendario fisico
								NIL				,; //19 -> Data final do calendario fisico 
								.F.				,; //20 -> .T. determina que o calendario sera gravado no caso de nao existir
								.F.		 	 	; //21 -> .T. determina que a rotina chamadora eh a Geracao de Calendarios (PONM400)
							);
				)

			nDias := ( dDtBase - dInicio )

			For nDia := 0 To nDias

				//-- Reinicializa Variaveis.
				oOcc 	:= JsonObject():New()
				cOccur  := ""
				dData  	:= dInicio + nDia
				cID		:= cBranchVld + cMatSRA + FormatGMT( DTOS( dData ), .T. )

				//Consite calendário.
				If ( nTab := aScan(aTabCalend, {|x| x[48] == dData .and. x[4] == '1E'}) ) > 0.00
					// Afastamento / Férias
					If ( aTabCalend[ nTab , 24 ] )
						cOccur := If( aTabCalend[ nTab , 25 ] == "F", ;
									EncodeUTF8( "vacation" ), ;
									EncodeUTF8( "workLeave" ) )
						oOcc["id"]   := cID
						oOcc["date"] := FormatGMT( DTOS( dData ), .T. )
						oOcc["description"] := cOccur

						aAdd( aOcc, oOcc )
					//Feriados.
					Elseif aTabCalend[ nTab , 19 ]
						cOccur 		 := EncodeUTF8( "holiday" )
						oOcc["id"]   := cID
						oOcc["date"] := FormatGMT( DTOS( dData ), .T. )
						oOcc["description"] := cOccur

						aAdd( aOcc, oOcc )
					EndIf
				EndIf
			Next nDia
		EndIf
	EndIf

	RestArea( aArea )

	FreeObj(oOcc)

	oItem["items"] := aOcc
	oItem["hasNext"] := .F.

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return oItem


/*/{Protheus.doc} fGetMySchedule
	@author alberto.ortiz
	@since 19/07/2023
	@params: 
	cEmp     - Empresa
	cFil     - Filial
	cMat     - Matrícula
	dInicio  - data início
	dFim     - data fim 
	lJob     - Informa se a função veio via JOB
	cUID     - Variável referente ao JOB.
	@return  - sucesso: objeto no formato oMySchedule. 
	           erro:    oResponse['success'] := .F., oResponse['error']
/*/
Function fGetMySchedule(cEmp, cFil, cMat, dInicio, dFim, lJob, cUID)

	Local aTabPadrao    	  := {}
	Local aTabCalend    	  := {}
	Local aTurnos       	  := {}
	Local aArea         	  := {}
	Local aMScdlDayClockings  := {}
	Local aItens        	  := {}
	Local cTurnDescription    := ""
	Local cTurnCode           := ""
	Local cTurnType           := ""
	Local cPaHrmovel    	  := ""
	Local cEventualDays 	  := ""
	Local cPosRegra           := ""
	Local cDiaSemana		  := ""
	Local dDate               := CTOD("//")
	Local oMScdlDClockings    := Nil
	Local oMScdlD		      := JsonObject():New()
	Local oMySchedule         := JsonObject():New()
	Local nColunas            := 0
	Local nX                  := 0
	Local nMaxColumns         := 0
	Local lTrocouData         := .F.
	Local lRet                := .T.

	DEFAULT cEmp    := ""
	DEFAULT cFil    := ""
	DEFAULT cMat    := ""
	DEFAULT dInicio := CTOD("//")
	DEFAULT dFim    := CTOD("//")
	DEFAULT lJob    := .F.
    DEFAULT cUID 	:= ""

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType(3)
		RPCSetEnv(cEmp, cFil)
	EndIf

	aArea := GetArea()
	DbSelectArea("SRA")
	DbSetOrder(1)

	If lRet := SRA->(dbSeek(cFil + cMat))
	    lRet := SRA->( ;
			CriaCalend(	;
						dInicio			,; //01 -> Data Inicial do Periodo
						dFim			,; //02 -> Data Final do Periodo
						SRA->RA_TNOTRAB	,; //03 -> Turno Para a Montagem do Calendario
						SRA->RA_SEQTURN	,; //04 -> Sequencia Inicial para a Montagem Calendario
						@aTabPadrao		,; //05 -> Array Tabela de Horario Padrao
						@aTabCalend		,; //06 -> Array com o Calendario de Marcacoes
						SRA->RA_FILIAL	,; //07 -> Filial para a Montagem da Tabela de Horario
						SRA->RA_MAT		,; //08 -> Matricula para a Montagem da Tabela de Horario
						SRA->RA_CC		,; //09 -> Centro de Custo para a Montagem da Tabela
						@aTurnos		,; //10 -> Array com as Trocas de Turno
						NIL				,; //11 -> Array com Todas as Excecoes do Periodo
						NIL	 			,; //12 -> Se executa Query para a Montagem da Tabela Padrao
						.F.				,; //13 -> Se executa a funcao se sincronismo do calendario
						.F.				,; //14 -> Se Forca a Criacao de Novo Calendario
						NIL  			,; //15 -> Array com marcacoes para tratamento de Turnos Opcionais
						.T.  			,; //16 -> Considera exceções
						NIL				,; //17 -> .T. Caso exista calendario fisico 
						NIL				,; //18 -> Data inicial do calendario fisico
						NIL				,; //19 -> Data final do calendario fisico 
						.F.				,; //20 -> .T. determina que o calendario sera gravado no caso de nao existir
						.F.		 	 	;  //21 -> .T. determina que a rotina chamadora eh a Geracao de Calendarios (PONM400)
						);
					)
	EndIf

	RestArea(aArea)

	If lRet := (Len(aTabCalend) > 0)
		For nX := 1 To Len(aTabCalend)
			//Inicia as variáveis de controle.
			oMScdlD         := JsonObject():New()
			nColunas      := 0
			cEventualDays := "empty"
			lTrocouData   := .F.
			//Data da batida.
			dDate         := aTabCalend[nX, CALEND_POS_DATA_APO]
			//Só busca R6_DESC se houve troca no CALEND_POS_TURNO.
			cTurnDescription    := If(cTurnCode != aTabCalend[nX, CALEND_POS_TURNO], AllTrim(fDesc('SR6', aTabCalend[nX, CALEND_POS_TURNO], 'R6_DESC', Nil, xFilial("SR6", cFil))), cTurnDescription)
			//Só busca PA_HRMOVEL se houve troca no CALEND_POS_REGRA.
			cPaHrmovel    := If(cPosRegra != aTabCalend[nX, CALEND_POS_REGRA], AllTrim(fDesc('SPA', aTabCalend[nX, CALEND_POS_REGRA], 'PA_HRMOVEL', Nil, xFilial("SPA", cFil))), cPaHrmovel)
			//Tipo de turno de acordo com o PA_HRMOVEL.
			cTurnType     := If(cPaHrmovel == 'S', 'flexible', 'rigid')
			//Dia da semana
			cDiaSemana    := MrhWeekDay(dDate)

			//Atualiza CALEND_POS_TURNO e CALEND_POS_REGRA.
			cTurnCode     := aTabCalend[nX, CALEND_POS_TURNO]
			cPosRegra     := aTabCalend[nX, CALEND_POS_REGRA]

			If aTabCalend[nX, CALEND_POS_TIPO_MARC] == '1E'
				If (aTabCalend[nX, CALEND_POS_AFAST])
					cEventualDays := If(aTabCalend[nX, CALEND_POS_TIP_AFAST] == "F", EncodeUTF8("vacation"), EncodeUTF8("workLeave"))
				ElseIf aTabCalend[nX, CALEND_POS_FERIADO] 
					cEventualDays := EncodeUTF8("holiday")
				ElseIf aTabCalend[nX, CALEND_POS_TIPO_DIA] == "D"
					 cEventualDays := EncodeUTF8("dsr")
				EndIf	
			EndIf

			oMScdlD['date']            := formatGMT(DTOC(dDate))
			oMScdlD['turnCode']        := cTurnCode
			oMScdlD['turnDescription'] := cTurnDescription
			oMScdlD['turnType']        := cTurnType
			oMScdlD['eventualDays']    := cEventualDays
			oMScdlD['weekDay']         := cDiaSemana 

			//Contrução das batidas do dia
			aMScdlDayClockings    := {}

			//Avança no array aTabCalend enquanto não trocou o CALEND_POS_DATA_APO.
			While !lTrocouData
				//Cria o objeto da batida.
				oMScdlDClockings              := JsonObject():New()
				oMScdlDClockings["direction"] := If("E" $ aTabCalend[nX, CALEND_POS_TIPO_MARC], "entry", "exit")
				oMScdlDClockings["hour"]      := HourToMs(strZero(aTabCalend[nX, CALEND_POS_HORA], 5, 2))
				aAdd(aMScdlDayClockings, oMScdlDClockings)
				
				//Controle de quando encerrar o While e quando andar no aTabCalend
				If  (nX < Len(aTabCalend)) .And. ; //Verifica se já está na última posição do aTabCalend 
					dDate == aTabCalend[nX + 1, CALEND_POS_DATA_APO] //Verifica se a próxima posição do aTabCalend continua na mesma data.
					nX++ // Anda no aTabCalend
				Else
					lTrocouData := .T.	//Indica que a próxima posição mudou a CALEND_POS_DATA_APO, ou fim do array.
				EndIf

				//Atualiza Contador de batidas por dia
				nColunas++
			End

			//Adiciona as batidas no dia em questão.
			oMScdlD["clockings"] := aMScdlDayClockings
			//Adiciona os dados do dia em questão.
			aAdd(aItens, oMScdlD)
			//Verifica se o número de colunas do dia, é maior que o máximo de colunas
			nMaxColumns := If(nColunas > nMaxColumns, nColunas, nMaxColumns)
		Next

		FreeObj(oMScdlDClockings)
		FreeObj(oMScdlD)
	EndIf

	If lRet
		oMySchedule['success']          := .T.
		oMySchedule['items']            := aItens
		oMySchedule['numbersOfColumns'] := nMaxColumns
	Else
		oMySchedule['success']          := .F.
		oMySchedule['error']            := STR0116 //"Não foram encontrados horários para os parâmetros informados"
	EndIf
	
	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

Return oMySchedule

/*/{Protheus.doc} fVerAcum
	Retorna .T. se existem registros na SPH para os parâmetros informados.
	@type  Function
	@author alberto.ortiz
	@since 30/01/2023
/*/
Function fVerAcum(cEmpFunc, cFilFunc, cMatFunc, cDtIni, cDtFim)
	
	Local aArea			:= GetArea()
	Local lRet 			:= .F.
	Local cAliasQuery 	:= GetNextAlias()
	Local cSPHtab       := "" 

	DEFAULT cEmpFunc := ""
	DEFAULT cFilFunc := ""
	DEFAULT cMatFunc := ""
	DEFAULT cDate    := ""
	DEFAULT cDtIni   := ""
	DEFAULT cDtFim   := ""

	cSPHtab := "%" + RetFullName("SPH", cEmpFunc) + "%"

	BEGINSQL ALIAS cAliasQuery
		SELECT COUNT(*) QTDAACUM
		FROM %Exp:cSPHtab% SPH
		WHERE 
		PH_FILIAL =  %Exp:cFilFunc% AND
		PH_MAT    =  %Exp:cMatFunc% AND 
		PH_DATA   >= %Exp:cDtIni%   AND
		PH_DATA   <= %Exp:cDtFim%   AND
		SPH.%notDel%
	ENDSQL

	lRet := (cAliasQuery)->(QTDAACUM) > 0

	(cAliasQuery)->(DbCloseArea())

	RestArea(aArea)

Return lRet

/*/
fProcExtBh()
Função responsável por processar o extrato do banco de horas.
@author henrique.ferreira
@since 06/08/2024
@param
/*/

Function fProcExtBh(aParams)

	Local uRet 		:= NIL

	DEFAULT aParams := NIL

	If lMrHExtr
		uRet := ExecBlock("MRHExtBh", .F., .F., aParams)
	Else
		uRet := fMrhExtBh(aParams[1], aParams[2], aParams[3], aParams[4], aParams[5], aParams[6], aParams[7])
	EndIf

Return uRet

/*/
fMrhExtBh
Recebe dados do funcionário, e gera um arquivo .pdf
com o extrato de horas no período informado.
@author alberto.ortiz
@since 27/04/2023
/*/

Function fMrhExtBh(cBranchVld, cMatSRA, cCodEmp, dInicio, dFim, lJob, cUID)

	Local aArea      := GetArea()
	Local aReturn    := {}
	Local aOcorrBH   := {}
	Local cPadrao999 := "9999999.99"
	Local lImpBaixad := .F.
	Local dDtFim	 := cTod("//")
	Local dDtIni	 := dInicio
	Local oFile      := JsonObject():New()
	Local oDetReg    := Nil
	Local oSaldo     := JsonObject():New()

	Private lDtVenc	 := .F.
	
	DEFAULT cBranchVld := ""
	DEFAULT cMatSRA    := ""
	DEFAULT cCodEmp    := ""
	DEFAULT dInicio    := ""
	DEFAULT dFim       := ""
	DEFAULT lJob       := .F.
	DEFAULT cUID       := .F.

	//Caso a data fim não tenha sido preenchida, preenche com a data de hoje.
	dDtFim := If(!Empty(dFim), dFim, DATE())

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType(3)
		RPCSetEnv(cCodEmp, cBranchVld)
	EndIf

	lDtVenc 			 := SPI->(ColumnPos("PI_DTVENC")) > 0
	oSaldo["MV_TCFBHVL"] := If(SuperGetMv("MV_TCFBHVL",.F.,.F.) == .F., 1, 0)
	lImpBaixad	         := SuperGetMv("MV_IMPBHBX",,.T.) // Lista horas baixadas?

	dbSelectArea('SRA')
	dbSetOrder(1)

	If SRA->(dbSeek(cBranchVld + cMatSRA))

		//-- Carrega os Totais de Horas e Abonos.
		oSaldo["Horas_positivas"]           := 0
		oSaldo["Horas_negativas"]           := 0
		oSaldo["Saldo"]                     := 0
		oSaldo["Saldo_anterior"]            := 0 
		oSaldo["Saldo_anterior_valorizado"] := 0

		// Verifica lancamentos no Banco de Horas
		dbSelectArea("SPI")
		dbSetOrder(2)
		dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)

		//Caso a data inicial venha em branco, é utilizada a data de admissão.
		dDtIni := If(!Empty(dDtIni), dDtIni, SRA->RA_ADMISSA)

		//Varre a tabela SPI
		While !Eof() .And. SPI->PI_FILIAL+SPI->PI_MAT == SRA->RA_FILIAL + SRA->RA_MAT

			// Totaliza Saldo Anterior.
			// Busca na SP9 - utilizando SPI.
			If SPI->PI_STATUS == " " .And. SPI->PI_DATA < dDtIni
				If PosSP9(SPI->PI_PD, SRA->RA_FILIAL, "P9_TIPOCOD") $ "1*3" 
					If oSaldo["MV_TCFBHVL"] == 1	// Horas Normais
						oSaldo["Saldo_anterior"]             := SomaHoras(  oSaldo["Saldo_anterior"], SPI->PI_QUANT)
						oSaldo["Saldo_anterior_valorizado"]  := SomaHoras(oSaldo["Saldo_anterior_valorizado"], SPI->PI_QUANTV)
					Else
						oSaldo["Saldo_anterior"] := SomaHoras(oSaldo["Saldo_anterior"], SPI->PI_QUANTV)
					Endif
				Else
					If oSaldo["MV_TCFBHVL"] == 1
						oSaldo["Saldo_anterior"]            := SubHoras(  oSaldo["Saldo_anterior"], SPI->PI_QUANT)
						oSaldo["Saldo_anterior_valorizado"] := SubHoras(oSaldo["Saldo_anterior_valorizado"], SPI->PI_QUANTV)
					Else
						oSaldo["Saldo_anterior"]   := SubHoras(oSaldo["Saldo_anterior"], SPI->PI_QUANTV)
					Endif
				Endif
				oSaldo["Saldo"] := oSaldo["Saldo_anterior"]
			EndIf

			//Valida as datas.
			If	SPI->PI_DATA < dDtIni .Or. SPI->PI_DATA > dDtFim .Or. (SPI->PI_STATUS == "B" .And. !lImpBaixad) 
				dbSkip()
				Loop
			Endif

			PosSP9(SPI->PI_PD, SRA->RA_FILIAL)

			// Acumula os lancamentos de Proventos/Desconto no array aOcorrBH
			If !(SPI->PI_STATUS=="B" .And. SPI->PI_DTBAIX <= dDtFim)
				If SP9->P9_TIPOCOD $ "1*3"
					oSaldo["Saldo"] := SomaHoras(oSaldo["Saldo"], If(oSaldo["MV_TCFBHVL"]==1, SPI->PI_QUANT, SPI->PI_QUANTV))
				Else
					oSaldo["Saldo"] := SubHoras(oSaldo["Saldo"], If(oSaldo["MV_TCFBHVL"]==1, SPI->PI_QUANT, SPI->PI_QUANTV))
				Endif
			EndIf

			oDetReg                                := JsonObject():New()
			oDetReg["Data"]                        := padr(DTOC(SPI->PI_DATA),10)
			oDetReg["Descricao_do_Evento"]         := Left(DescPdPon(SPI->PI_PD, SPI->PI_FILIAL), 20)
			oDetReg["Quantidade_de_Horas_Debito"]  := Transform(If(SP9->P9_TIPOCOD $ "1*3", 0, If(oSaldo["MV_TCFBHVL"]==1, SPI->PI_QUANT, SPI->PI_QUANTV)), cPadrao999)
			oDetReg["Quantidade_de_Horas_Credito"] := Transform(If(SP9->P9_TIPOCOD $ "1*3", If(oSaldo["MV_TCFBHVL"]==1, SPI->PI_QUANT, SPI->PI_QUANTV), 0), cPadrao999)
			oDetReg["Saldo"] 					   := Transform(oSaldo["Saldo"], cPadrao999)
			If lDtVenc
				oDetReg["Data_de_Vencimento"]	   := padr(DTOC(SPI->PI_DTVENC),10)
			EndIf

			aAdd(aOcorrBH, oDetReg)

			//Totaliza horas positivas e negativas
			If !(SPI->PI_STATUS=="B" .And. SPI->PI_DTBAIX <= dDtFim)
				If SP9->P9_TIPOCOD $ "1*3"
					oSaldo["Horas_positivas"] := SomaHoras(oSaldo["Horas_positivas"], If(oSaldo["MV_TCFBHVL"]==1, SPI->PI_QUANT, SPI->PI_QUANTV))
				Else
					oSaldo["Horas_negativas"] := SomaHoras(oSaldo["Horas_negativas"], If(oSaldo["MV_TCFBHVL"]==1, SPI->PI_QUANT, SPI->PI_QUANTV))
				EndIf
			EndIf

			dbSelectArea( "SPI" )
			SPI->(dbSkip())
		Enddo
	EndIf

	If (Len(aOcorrBH) > 0 )
		oFile                 := fImpGraf(dDtIni, dDtFim, oSaldo, aOcorrBH)
		oFile["error"]        := .F.
		oFile["errorMessage"] := ""
	Else
		oFile["error"]        := .T.
		oFile["errorMessage"] := STR0095 + dToC(dDtIni) + " - " + dToC(dDtFim) //"Não foram encontrados saldo de horas para o período "
	Endif

	RestArea(aArea)

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf

	AADD(aReturn, oFile['content'])
	AADD(aReturn, oFile['fileName'])
	AADD(aReturn, oFile['error'])
	AADD(aReturn, oFile['errorMessage'])

	FreeObj(oDetReg)
	FreeObj(oSaldo)
	FreeObj(oFile)

Return aReturn

/*/
fImpGraf
Faz a impressão do extrato de horas.
@author alberto.ortiz
@since 27/04/2023
/*/

Static Function fImpGraf(dDtIni, dDtFim, oSaldo, aOcorrBH)

	Local cLocal 	   := GetSrvProfString("STARTPATH", "")
	Local cFile	 	   := AllTrim(SRA->RA_FILIAL) + "_" + AllTrim(SRA->RA_MAT)
	Local cFileContent := ""
	Local nLin	 	   := 0
	Local oFile        := Nil
	Local oPrint       := Nil
	Local oFileRet     := JsonObject():New()

	DEFAULT aOcorrBH := {}
	DEFAULT dDtIni   := cToD("//")
	DEFAULT dDtFim   := cToD("//")
	DEFAULT oSaldo   := Nil

	//Remove espaços em branco do nome do arquivo.
	cFile  := StrTran( cFile, " ", "_")
	oPrint := FWMSPrinter():New(cFile +".pdf", IMP_PDF, .F., cLocal, .T., Nil, Nil, Nil, .T., Nil, .F., Nil)
	oPrint:SetPortrait()

	//Cabeçalho
	fCabecGrf(@nLin, oPrint)

	//Dados do Periodo
	fPerGrf(@nLin, dDtIni, dDtFim, oPrint)

	//Cabeçalho dos Valores do BH
	fCabBH(@nLin, oPrint)

	//Valores do BH
	fValBH(@nLin, aOcorrBH, oPrint)

	//Saldos Finais
	fSaldosBH(@nLin, oSaldo, oPrint)

	oPrint:EndPage() // Finaliza a pagina
	oPrint:cPathPDF := cLocal 
	oPrint:lViewPDF := .F.
	oPrint:Print()

	//Avalia o arquivo gerado no servidor
	If File( cFile + ".pdf" )
		oFile := FwFileReader():New( cFile + ".pdf" )
		If (oFile:Open())
			cFileContent         := oFile:FullRead()
			oFileRet['content']  := cFileContent
			oFileRet['fileName'] := cFile +".pdf"
			oFile:Close()
		EndIf
	EndIf

	FreeObj(oFile)
	FreeObj(oPrint)

Return oFileRet

/*/
fCabecGrf
Faz a impressão do cabeçalho do extrato de horas..
@author alberto.ortiz
@since 27/04/2023
/*/

Static Function fCabecGrf(nLin, oPrint)

	Local aInfo			:= {}
	Local aDtHr         := {}
	Local cFile			:= ""
	Local cFilDesc      := ""
	Local cDepDesc      := ""
	Local cFuncDesc     := ""
	Local cNome         := ""
	Local cMat          := ""
	Local cPagText      := "Página: "
	Local cStartPath	:= GetSrvProfString("Startpath","")
	Local lNomeSoc      := SuperGetMv("MV_NOMESOC", NIL, .F.) 
	Local oFont15n      := TFont():New("Arial", 15, 15, Nil, .T., Nil, Nil, Nil, .T., .F.) //Normal negrito
	Local oFont12n      := TFont():New("Arial", 12, 12, Nil, .T., Nil, Nil, Nil, .T., .F.) //Normal negrito
	Local oFont10       := TFont():New("Arial", 10, 10, Nil, .F., Nil, Nil, Nil, .T., .F.) //Normal s/ negrito

	DEFAULT nLin   := 0
	DEFAULT oPrint := Nil

	fInfo(@aInfo, SRA->RA_FILIAL)

	cMat      := SRA->RA_MAT
	cFilDesc  := aInfo[1]
	cDepDesc  := AllTrim(fDesc('SQB', SRA->RA_DEPTO, 'QB_DESCRIC', Nil, SRA->RA_FILIAL))
	cNome     := If(lNomeSoc .And. !Empty(SRA->RA_NSOCIAL), AllTrim(SRA->RA_NSOCIAL), AllTrim(SRA->RA_NOME))
	cFuncDesc := AllTrim(fDesc('SRJ', SRA->RA_CODFUNC, 'RJ_DESC', Nil, SRA->RA_FILIAL))
			
	//Inicia uma nova pagina.
	oPrint:StartPage() 

	//Horário da geração do extrato de horas.
	aDtHr := FwTimeUF("SP", Nil, .T.)  
	nLin := 20
	oPrint:Say(nLin, 400, dToC(date()) + Space(1) + Time() + " - " + cPagText + "1", oFont10)
	nLin +=10 
	oPrint:Line(nLin, 10, nLin, 575, 12)

	//Logo
	cFile := cStartPath + "lgrl" + cEmpAnt + ".bmp"
	If File(cFile)
		oPrint:SayBitmap(nLin + 4, 25, cFile, 60, 50) // Tem que estar abaixo do RootPath
		nLin += 40
	Endif

	nLin +=20
	oPrint:Say(nLin,  40, STR0113, oFont15n) //EXTRATO DO BANCO DE HORAS
	nLin +=20
	oPrint:Say(nLin,  40, STR0096, oFont12n) //Empresa
	oPrint:Say(nLin, 200, STR0097, oFont12n) //Filial
	oPrint:Say(nLin, 400, STR0098, oFont12n) //Departamento
	nLin +=10
	oPrint:Say(nLin,  40,  cEmpAnt, oFont10) //Empresa
	oPrint:Say(nLin, 200, cFilDesc, oFont10) //Filial
	oPrint:Say(nLin, 400, cDepDesc, oFont10) //Departamento
	nLin +=30
	oPrint:Say(nLin,  40, STR0099, oFont12n) //Nome
	oPrint:Say(nLin, 200, STR0100, oFont12n) //Matrícula
	oPrint:Say(nLin, 400, STR0101, oFont12n) //Função
	nLin +=10
	oPrint:Say(nLin,  40,     cNome, oFont10) //Nome
	oPrint:Say(nLin, 200,      cMat, oFont10) //Matrícula
	oPrint:Say(nLin, 400, cFuncDesc, oFont10) //Função
	nLin +=10
	oPrint:Line(nLin, 10, nLin, 575, 12)
	nLin +=25

	FreeObj(oFont15n)
	FreeObj(oFont12n)
	FreeObj(oFont10)

Return .T.

/*/
fPerGrf
Faz a impressão do período do extrato de horas.
@author alberto.ortiz
@since 27/04/2023
/*/

Static Function fPerGrf(nLin, dDtIni, dDtFim, oPrint)

	Local oFont12n := TFont():New("Arial", 12, 12, Nil, .T., Nil, Nil, Nil, .T., .F.) //Normal negrito
	Local oFont10  := TFont():New("Arial", 10, 10, Nil, .F., Nil, Nil, Nil, .T., .F.) //Normal s/ negrito

	DEFAULT nLin   := 0
	DEFAULT dDtIni := cToD("//")
	DEFAULT dDtFim := cToD("//")
	DEFAULT oPrint := Nil

	nLin  += 10
	oPrint:Line(nLin, 10, nLin, 575, 12)
	nLin  += 10
	oPrint:Say(nLin, 270, STR0102, oFont12n) //Período.
	nLin  += 15
	oPrint:Say(nLin, 245, DtoC(dDtIni) + " - " + dToC(dDtFim), oFont10) //Valores do período informado.
	nLin  += 5
	oPrint:Line(nLin, 10, nLin, 575, 12)
	nLin  += 40
	
	FreeObj(oFont12n)
	FreeObj(oFont10)

Return .T.

/*/
fCabBH
Faz a impressão do cabeçalho da seção dos eventos do extrato de horas.
@author alberto.ortiz
@since 27/04/2023
@param nLin, oPrint
/*/

Static Function fCabBH(nLin, oPrint)

	Local oFont12n := TFont():New("Arial", 12, 12, Nil, .T., Nil, Nil, Nil, .T., .F.) //Normal negrito

	DEFAULT nLin   := 0
	DEFAULT oPrint := Nil

	oPrint:Line(nLin, 10, nLin, 575, 12)
	nLin += 15
	oPrint:Say(nLin, 40, STR0103, oFont12n) //Data
	oPrint:Say(nLin, 100,STR0104, oFont12n) //Evento
	oPrint:Say(nLin, iif( !lDtVenc, 300, 250), STR0105, oFont12n) //Positivas
	oPrint:Say(nLin, iif( !lDtVenc, 400, 330), STR0106, oFont12n) //Negativas
	If lDtVenc
		oPrint:Say(nLin, 400, STR0137, oFont12n) //Vencimento
	EndIf
	oPrint:Say(nLin, 500, STR0107, oFont12n) //Saldo
	nLin  += 10
	oPrint:Line(nLin, 10, nLin, 575, 12)

	FreeObj(oFont12n)

Return .T.

/*/
fValBH
Faz a impressão dos eventos do extrato de horas.
@author alberto.ortiz
@since 27/04/2023
@param nLin, aOcorrBH, oPrint
/*/

Static Function fValBH(nLin, aOcorrBH, oPrint)

	Local nX	      := 0
	Local nPagina     := 1
	Local nTamPriPag  := 50
	Local nTamPagina  := 75
	Local nRegistros  := 0
	Local cPagText    := "Página: "
	Local oFont10     := TFont():New("Arial", 10, 10, Nil, .F., Nil, Nil, Nil, .T., .F.)	//Normal negrito

	DEFAULT aOcorrBH := {}
	DEFAULT nLin     := 0
	DEFAULT oPrint   := Nil

	nRegistros := Len(aOcorrBH)
	nLin +=10

	For nX := 1 To nRegistros

		//Controle da paginação - Situações em que ocorrem a quebra da página:
		//1 - Não coube na primeira página: - nRegistros > 50 e nPagina ==1
		//2 - Relatório tem mais de uma página e não coube na página atual (mais de 75 registros):
		//    nPagina > 1 .And. nX > (nTamPriPag + (nPagina - 1) * (nTamPagina))
		//3 - Está na última página do relatório e o rodapé não vai caber:
		//    Exemplos onde a o rodapé não cabe na página atual:
		//    40  < nRegistros <= 50  - primeira página
		//    115 < nRegistros <= 125 - segunda página
		//    190 < nRegistros <= 200 - terceira página
		//    3a - (nTamPriPag - 10 + (nPagina - 1) * (nTamPagina)) < nRegistros <= (nTamPriPag + (nPagina - 1) * (nTamPagina))
		//    3b - Faz a quebra quando for o primeiro registro da página seguinte: nX == nTamPriPag - 9 + (nPagina - 1) * (nTamPagina)  

		If (nPagina == 1 .And. nX > nTamPriPag) .Or. ; // - 1.
		   (nPagina > 1 .And. nX > (nTamPriPag + (nPagina - 1) * (nTamPagina))) .Or. ; // - 2.
		   ((nTamPriPag - 10 + (nPagina - 1) * (nTamPagina) < nRegistros) .And. ; // - 3a.
		    (nRegistros <= nTamPriPag + (nPagina - 1) * (nTamPagina)) .And. ;// - 3a.
			nX == nTamPriPag - 9 + (nPagina - 1) * (nTamPagina))// - 3b.
			
			//Encerra a página e começa outra
			oPrint:EndPage()
			oPrint:StartPage()
			nPagina++
			nLin := 20
			//Imprime horário e numeração da página.
			oPrint:Say(nLin, 400, dToC(date()) + Space(1) + Time() + Space(1) + " - " + cPagText + Alltrim(Str(nPagina)), oFont10)
			nLin := 40
			//Imprime o cabeçalho do Banco de horas novamente
			fCabBH(@nLin, @oPrint)
			nLin += 20
		EndIf

		// Impressão da linha
		oPrint:Say(nLin, 40, AllTrim(aOcorrBH[nX]["Data"]), oFont10) // Data
		oPrint:Say(nLin, 100, AllTrim(aOcorrBH[nX]["Descricao_do_Evento"]), oFont10) // Evento
		oPrint:Say(nLin, iif( !lDtVenc, 300, 250), AllTrim(aOcorrBH[nX]["Quantidade_de_Horas_Credito"]), oFont10) // Positivas
		oPrint:Say(nLin, iif( !lDtVenc, 400, 330), AllTrim(aOcorrBH[nX]["Quantidade_de_Horas_Debito"]), oFont10) // Negativas
		If lDtVenc
			oPrint:Say(nLin, 400, AllTrim(aOcorrBH[nX]["Data_de_Vencimento"]), oFont10) // Data de Vencimento
		EndIf
		oPrint:Say(nLin, 500, AllTrim(aOcorrBH[nX]["Saldo"]), oFont10) // Saldo
		nLin += 10
	Next nX

	nLin +=20

	FreeObj(oFont10)
Return .T.

/*/
fSaldosBH
Faz a impressão dos saldos do extrato de horas.
@author alberto.ortiz
@since 27/04/2023
@param nLin, oSaldo, oPrint
/*/

Static Function fSaldosBH(nLin, oSaldo, oPrint)

	Local cSaldoAnterior  := ""
	Local cHorasPositivas := ""
	Local cHorasNegativas := ""
	Local cSaldo          := ""
	Local cPadrao999      := "9999999.99"
	Local oFont12n        := TFont():New("Arial", 12, 12, Nil, .T., Nil, Nil, Nil, .T., .F.) //Normal negrito
	Local oFont10         := TFont():New("Arial", 10, 10, Nil, .F., Nil, Nil, Nil, .T., .F.) //Normal s/ negrito

	DEFAULT nLin   := 0
	DEFAULT oSaldo := Nil
	DEFAULT oPrint := Nil

	cSaldoAnterior  := If(oSaldo["MV_TCFBHVL"] == 1, Transform(oSaldo["Saldo_anterior"], cPadrao999), Transform(oSaldo["Saldo_anterior_valorizado"],cPadrao999))
	cHorasPositivas := Transform(oSaldo["Horas_positivas"], cPadrao999)
	cHorasNegativas := Transform(oSaldo["Horas_negativas"], cPadrao999)
	cSaldo          := Transform(          oSaldo["Saldo"], cPadrao999)

	nLin  += 10
	oPrint:Line(nLin, 10, nLin, 575, 12)
	nLin  += 10

	oPrint:Say(nLin,  40, STR0108, oFont12n) // Saldo Anterior
	oPrint:Say(nLin, 250, STR0109, oFont12n) // Valores do Período
	oPrint:Say(nLin, 500, STR0110, oFont12n) // Saldo Final

	nLin += 10
    oPrint:Say(nLin,     40,            cSaldoAnterior, oFont10) // Saldo Anterior
	oPrint:Say(nLin,    250, STR0111 + cHorasPositivas, oFont10) // Horas positivas: 
	oPrint:Say(nLin+10, 250, STR0112 + cHorasNegativas, oFont10) // Horas Negativas: 
	oPrint:Say(nLin,    500,                    cSaldo, oFont10) // Saldo

	nLin  += 20
	oPrint:Line(nLin, 10, nLin, 575, 12)
	nLin  += 10

	FreeObj(oFont12n)
	FreeObj(oFont10)

Return .T.
