#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSMRHPSH02.CH"



//******************** Funções auxiliares do Push Notification ********************

Function fGravTokPush(cBranchVld, cMatSRA, cDeviceTok)
	
	Local aAreaRUY     := RUY->(GetArea())
	Local cCPF         := ""

    DEFAULT cBranchVld := ""
	DEFAULT cMatSRA    := ""
	DEFAULT cDeviceTok := ""

	If(!Empty(cBranchVld) .And. !Empty(cMatSRA) .And. !Empty(cDeviceTok))
		
		cCPF := fSraVal(cBranchVld, cMatSRA, "RA_CIC", cEmpAnt)

		DbSelectArea("RUY")
		RUY->(dbSetOrder(1))
		
		Begin Transaction
			//Se já existe registro do funcionário e houve troca do token
			//Atualiza o token
			If RUY->(dbSeek(cBranchVld + cMatSRA))
				If(AllTrim(RUY->RUY_TOKEN) != AllTrim(cDeviceTok))
					Reclock("RUY", .F.)
					RUY->RUY_TOKEN	:= cDeviceTok
					RUY->RUY_DTATUA := dDataBase
					RUY->(MsUnLock())
				EndIf				
			//Se o token ainda não existe, cria o token.	
			Else
				Reclock("RUY", .T.)
				RUY->RUY_FILIAL	 := cBranchVld
				RUY->RUY_MAT	 := cMatSRA
				RUY->RUY_CPF     := cCPF
				RUY->RUY_TOKEN	 := cDeviceTok
				RUY->RUY_DTCRIA  := dDataBase
				RUY->(MsUnLock())
			EndIf
		End Transaction
	EndIf

	RestArea(aAreaRUY)

Return .T.

Function MrhPushNot(aRequest, lSolic, lApprove, lTCFA040, lJob, cUID)

	Local cNivel 	:= ""
	Local lPush		:= .F.
	Local cTipoSoli	:= ""
	Local aDados    := {}
	
	DEFAULT lJob	:= .F.
	DEFAULT cUID	:= ""

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		// Se a solicitação ainda estiver em aprovação, inicia o job com os dados do prox aprovador.
		// Caso seja aprovação RH ou reprovação, abre o JOB com a filial do funcionário
		If aRequest[8] == "1"
			RPCSetType( 3 )
			RPCSetEnv( aRequest[4], aRequest[5] )
		Else
			RPCSetType( 3 )
			RPCSetEnv( aRequest[1], aRequest[2] )
		EndIf
	EndIf

	If ( lPush := SuperGetMv("MV_MRHPUSH", .F. , .F.) )
		cNivel 		:= aRequest[8]
		cTipoSoli 	:= aRequest[9]
		// Preenche os dados
		aDados := SetDados(aRequest, lSolic, lApprove, lTCFA040)		
		// Somente processa se estiver em aprovação.
		If cNivel == "1"
			// Férias.
			If cTipoSoli == "B"
				MrhPushFer(aDados, lSolic, lApprove, lTCFA040)
			EndIf
		// Aprovação RH
		ElseIf cNivel == "2"
			// Férias.
			If cTipoSoli == "B"
				MrhPushFer(aDados, lSolic, lApprove, lTCFA040)
			EndIf
		// Reprovação
		ElseIf cNivel == "3"
			// Férias.
			If cTipoSoli == "B"
				MrhPushFer(aDados, lSolic, lApprove, lTCFA040)
			EndIf
		EndIf
	EndIf
	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf
Return

Static Function SetDados(aRequest, lSolic, lApprove, lTCFA040)

	Local aDados 		:= {}
	Local cEmpFunc		:= aRequest[1]
	Local cFilFunc	    := aRequest[2]
	Local cMatFunc		:= aRequest[3]
	Local cFilAprv	    := aRequest[5]
	Local cMatAprv		:= aRequest[6]
	Local cCodRH3		:= aRequest[7]

	// Se for solicitação
	If ( lSolic )
		aDados := {;
				cFilAprv										,; // 01 - Filial
				cFilAprv										,; // 02 - Filial
				cMatAprv										,; // 03 - Matricula
				cMatAprv										,; // 04 - Matricula
				""                           					,; // 05 - Centro de Custo
				"ZZZZZZZZZZZZZZ"			 					,; // 06 - Centro de Custo
				""                           					,; // 07 - Departamento
				"ZZZZZZZZZZZZZZ"             					,; // 08 - Departamento
				""							 					,; // 09 - Roteiro de Cálculo
				NIL							 					,; // 10 - Tipo de Mensagem ( 002 = Férias )
				NIL					 							,; // 11 - Título.
				NIL												,; // 12 - Mensagem
				cCodRH3											,; // 13 - Código RH3
				cFilFunc 										,; // 14 - Filial RH3
				cMatFunc										,; // 15 - Matrícula RH3
				cEmpFunc									    }  // 16 - Empresa RH3
	Else
		// Se for aprovação.
		If ( lApprove )
			// Se for aprovação do TCFA040 (aprovação do RH), notifica o funcionário que recebeu a ação.
			If ( lTCFA040 )
				aDados := {;
							cFilFunc								,; // 01 - Filial
							cFilFunc								,; // 02 - Filial
							cMatFunc								,; // 03 - Matricula
							cMatFunc								,; // 04 - Matricula
							""                           			,; // 05 - Centro de Custo
							"ZZZZZZZZZZZZZZ"			 			,; // 06 - Centro de Custo
							""                           			,; // 07 - Departamento
							"ZZZZZZZZZZZZZZ"             			,; // 08 - Departamento
							""							 			,; // 09 - Roteiro de Cálculo
							NIL							 			,; // 10 - Tipo de Mensagem ( 002 = Férias )
							NIL					 					,; // 11 - Título.
							NIL										,; // 12 - Mensagem
							cCodRH3									,; // 13 - Código RH3
							cFilFunc								,; // 14 - Filial RH3
							cMatFunc								,; // 15 - Matrícula RH3
							cEmpFunc								}  // 16 - Empresa RH3
			Else
				aDados := {;
						cFilAprv								,; // 01 - Filial
						cFilAprv								,; // 02 - Filial
						cMatAprv								,; // 03 - Matricula
						cMatAprv								,; // 04 - Matricula
						""                           			,; // 05 - Centro de Custo
						"ZZZZZZZZZZZZZZ"			 			,; // 06 - Centro de Custo
						""                           			,; // 07 - Departamento
						"ZZZZZZZZZZZZZZ"             			,; // 08 - Departamento
						""							 			,; // 09 - Roteiro de Cálculo
						NIL							 			,; // 10 - Tipo de Mensagem ( 002 = Férias )
						NIL					 					,; // 11 - Título.
						NIL										,; // 12 - Mensagem
						cCodRH3									,; // 13 - Código RH3
						cFilFunc								,; // 14 - Filial RH3
						cMatFunc								,; // 15 - Matrícula RH3
						cEmpFunc								}  // 16 - Empresa RH3
			EndIf
		Else
			// Reprovação, notifica o funcionário que sofreu a ação.
			aDados := {;
							cFilFunc										,; // 01 - Filial
							cFilFunc										,; // 02 - Filial
							cMatFunc										,; // 03 - Matricula
							cMatFunc										,; // 04 - Matricula
							""                           					,; // 05 - Centro de Custo
							"ZZZZZZZZZZZZZZ"			 					,; // 06 - Centro de Custo
							""                           					,; // 07 - Departamento
							"ZZZZZZZZZZZZZZ"             					,; // 08 - Departamento
							""							 					,; // 09 - Roteiro de Cálculo
							NIL							 					,; // 10 - Tipo de Mensagem ( 002 = Férias )
							NIL					 							,; // 11 - Título.
							NIL												,; // 12 - Mensagem
							cCodRH3											,; // 13 - Código RH3
							cFilFunc										,; // 14 - Filial RH3
							cMatFunc										,; // 15 - Matrícula RH3
							cEmpFunc	 									}  // 16 - Empresa RH3
		EndIf
	ENdiF

Return aDados

Static Function MrhPushFer(aDados, lSolic, lApprove, lTCFA040)

	Local cTipMsg  := ""
	Local cTitulo  := ""
	Local cMsg	   := "" 
	Local lPushFer := SuperGetMv("MV_MRHPFER", .F., .F.)

	DEFAULT lSolic 		:= .F. // Identifica se é solicitação. Caso seja .T. é solicitação, caso contrário
	DEFAULT lApprove	:= .F. // Identifica se é aprovação. Caso seja .T. é aprovação, caso contrário, reprovação.
	DEFAULT lTCFA040	:= .F. // Identifica se é aprovação/reprovação do RH pela rotina do TCFA040.

	If lPushFer
		// Atualiza as mensagens.
		If ( lSolic ) 
			 cTipMsg := "002"
			 cTitulo := EncodeUTF8(STR0001) // Tem funcionário pedindo férias!
			 cMsg    := EncodeUTF8(STR0002) // Clique aqui e finalize a pendência de aprovação de férias!
		Else
			If ( lApprove )
				If ( lTCFA040 )
					cTipMsg := "003"
					cTitulo := EncodeUTF8(STR0005) // Ótima notícia!
					cMsg    := EncodeUTF8(STR0006) // Suas férias foram aprovadas! Aproveite cada momento de suas férias e volte renovado! 
				Else
					cTipMsg := "002"
					cTitulo := EncodeUTF8(STR0001) // Tem funcionário pedindo férias!
					cMsg    := EncodeUTF8(STR0002) // Clique aqui e finalize a pendência de aprovação de férias!
				EndIf
			Else
				cTipMsg := "004"
			 	cTitulo := EncodeUTF8(STR0003) // Suas férias não foram aprovadas.
			 	cMsg    := EncodeUTF8(STR0004) // Veja com o seu gestor ou RH o motivo da não aprovação.
			EndIf
		EndIf
		// Atualiza os dados do array referente à aprovação.
		aDados[10] := cTipMsg
		aDados[11] := cTitulo
		aDados[12] := cMsg
		// Processa Push ( Rotina do TCFA 160 )
		fProcPush(NIL, aDados)
	EndIf
Return


