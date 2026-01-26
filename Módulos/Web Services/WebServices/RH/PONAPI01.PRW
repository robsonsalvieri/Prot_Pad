#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PONAPI01.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWLIBVERSION.CH"

Static __oSt01		:= Nil //fBuscaNSR()
Static __oSt02		:= Nil //fProxRegVal()
Static __oSt03		:= Nil //fValidaNSR()
Static __oSt04		:= Nil //fValidaNSR()
Static cDataExec	:= Nil
Static aFiliais		:= {}
Static cLastFil		:= ""
Static cLastCPF		:= ""
Static nLenFil		:= 0
Static oStaClkIn	:= Nil

/*/{Protheus.doc} PONAPI01
//Realiza a busca pelas marcações da API Clock In da Carol e grava as informações na tabela de TSA do Protheus.
@author Wesley Alves Pereira
@since 13/09/2019
@version undefined
@return return, return_description
/*/
Function PONAPI01(oProcess)
Local aTitle    	:= {OemToAnsi(STR0024)}//"Erro na integração com a API Clockin da Carol"
Local aDisps		:= {} //Array de dispositivos da Carol
Local aDados    	:= {} //Array de Marcações da Carol
Local aRetDisps		:= {}
Local aTempss   	:= {}
Local aLogs		   	:= {}
Local aLogTitle	   	:= {}
Local aLogPerg	   	:= {}
Local cDtIni    	:= ""
Local cDtFim    	:= ""
Local cTempDisp 	:= ""
Local cCoDisp 		:= ""
Local cPerg 		:= "PNAPI01"
Local nCoutDisp 	:= 0
Local nI		 	:= 0
Local nLoopFor	 	:= 0
Local nOpcA		 	:= 0
Local nPosDados 	:= 3
Local nTpIntegr		:= 1
Local lIntRR1Sur	:= SuperGetMv("MV_APISUR", .F., .F.) 
Local lIntRR1Car	:= SuperGetMv("MV_APICLOD", .F., .F.) 
Local lTsRep    	:= SuperGetMV("MV_TSREP",.F.,.F.)
Local lIntegCar		:= .F.
Local lProcIni  	:= .F.
Local lVldNSR	  	:= .F.
Local lMsa671	  	:= .F.
Local lExistPerg 	:= fExistPerg(cPerg)
Local lExib2Plan	:= FwLibVersion() >= "20240520"
Local lWorkFlow		:= FWGetRunSchedule()

Local cLockName 	:= "PONAPI01"+DTOS(DATE())

Private aLog		:= {{}}
Private aLogIntegC	:= {}
Private aLogTecInt	:= {}
Private lApiToken	:= .F.
Private lGeraTokn	:= .F.
Private lTemRR1		:= .F.
Private aParams		:= {}
Private nTotMarc	:= 0

Default oProcess	:= Nil

If !lWorkFlow .And. oProcess == Nil
	TNewProcess():New("PONAPI01", STR0099 , {|oSelf| PONAPI01(oSelf)}, STR0096 + " " + STR0097 + " " + STR0098, cPerg, NIL, NIL, NIL, NIL, .T., .F., lExib2Plan) // "Integração Carol" "Este programa tem como objetivo realizar a integração" "de marcações realizadas no Clock In." "Obs.: Verifique os parâmetros de integração antes de executar a rotina"

	If nOpca == 0
		Return
	EndIf
ElseIf oProcess == Nil
	oProcess := TNewProcess():New("PONAPI01", STR0099 , {|| Nil}, STR0096 + " " + STR0097 + " " + STR0098, cPerg, NIL, NIL, NIL, NIL, .T., .F., lExib2Plan) // "Integração Carol" "Este programa tem como objetivo realizar a integração" "de marcações realizadas no Clock In." "Obs.: Verifique os parâmetros de integração antes de executar a rotina"
EndIf

lTemRR1	:= AliasInDic("RR1")

If lExistPerg
	
	If(ValType(mv_par01) == "N",nTpIntegr := mv_par01, nTpIntegr := 1)
	
	If cPaisLoc <> "BRA"
		nTpIntegr := mv_par01
	EndIf

	If nTpIntegr <> 1
		lVldNSR := .T.
	EndIf 

	If nTpIntegr == 2
		cDtIni := dToS(FirstDate(FirstDate(Date())-1))
		cDtFim := dToS(LastDate(LastDate(Date())+1))
		cDtIni := Substr(cDtIni,1,4) + '-' + Substr(cDtIni,5,2) + '-' + Substr(cDtIni,7,2)
		cDtFim := Substr(cDtFim,1,4) + '-' + Substr(cDtFim,5,2) + '-' + Substr(cDtFim,7,2)
	ElseIf nTpIntegr == 3
		If Empty(mv_par02)
			mv_par02 := dDataBase
		EndIf

		If Empty(mv_par03)
			mv_par03 := dDataBase
		EndIf

		If mv_par03 < mv_par02
			cDtIni := dToS(mv_par03)
			cDtFim := dToS(mv_par02)
		Else
			cDtIni := dToS(mv_par02)
			cDtFim := dToS(mv_par03)
		EndIf
		
		cDtIni := Substr(cDtIni,1,4) + '-' + Substr(cDtIni,5,2) + '-' + Substr(cDtIni,7,2)
		cDtFim := Substr(cDtFim,1,4) + '-' + Substr(cDtFim,5,2) + '-' + Substr(cDtFim,7,2)
	EndIf
EndIf

aParams		:= fBuscaParam()
lIntegCar	:= aParams[1]
lProcIni	:= aParams[14]

aFiliais := FWLoadSM0(.T.,.F.)
nLenFil := Len(aFiliais)

If lTemRR1
	If lTsRep .And. lIntegCar
		If lIntRR1Car <> lIntRR1Sur
			Help("", 1, OemToAnsi(STR0094),, OemToAnsi(STR0095), 1, 0) // Se houver integração com a Carol e Suricato os parâmetros MV_APICLOD e MV_APISUR precisam estar com o mesmo conteúdo.
			Return .F.
		Else 
			lTemRR1 := If(lIntRR1Car, .T., .F.)
		EndIf
	ElseIf lTsRep .And. !lIntegCar
		lTemRR1 := If(lIntRR1Sur, .T., .F.)
	ElseIf lIntegCar .And. !lTsRep
		lTemRR1 := If(lIntRR1Car,.T.,.F.)
	EndIf
EndIf

If !LockByName(cLockName,.F.,.F.,.T.)
 		If ! lWorkFlow
 			Help( ,, 'HELP',, STR0020, 1, 0) //"Esta rotina já está sendo utilizada em outro processo!"
		Else
			ConsoleJob(STR0020) //"Esta rotina já está sendo utilizada em outro processo!"
		EndIf
		
		Return (.F.)
EndIf

If !lTemRR1 .And. !fTemTabMSA()
 	If ! fCriaTab(lWorkFlow)
 		If ! lWorkFlow
 			Help( ,, 'HELP',, STR0018, 1, 0) //"Não foi possível criar a tabela do processo de integração! Verifique as permissões necessárias."
		Else
			ConsoleJob(STR0018) //"Não foi possível criar a tabela do processo de integração! Verifique as permissões necessárias."
		EndIf
		
		UnLockByName(cLockName,.F.,.F.,.T.)
		
		Return (.F.)
	
	EndIf
ElseIf !lTemRR1 .And. fTemTabMSA()
	lMsa671 := fVldMSA671()
EndIf

If oProcess <> Nil
	// Inclui a informação no log do tNewProcess
	oProcess:SaveLog(STR0111) // "Iniciado a integração com a Carol"
EndIf

If Empty(cCoDisp) 
	aDisps := fDispBusc()
Else
	aAdd(aTempss,cCoDisp)
	aDisps := {.T.,,aTempss}
EndIf

If aDisps[1] .and. Len(aDisps[nPosDados]) > 0
	
	If lTemRR1
		dbSelectArea("RR1")
		If !fMigrRR1()
			If !lWorkFlow
				MsgAlert(STR0045)//"Erro na migração dos registros da tabela MSA_CONTROL_MARCAC para a tabela RR1. Será necessário reinicializar a tabela RR1 e reiniciar o processo. A integração será abortada"
			Else
				ConsoleJob(STR0045)//"Erro na migração dos registros da tabela MSA_CONTROL_MARCAC para a tabela RR1. Será necessário reinicializar a tabela RR1 e reiniciar o processo. A integração será abortada"
			EndIf				
			Return .F.
		EndIf
	EndIf
	
	For nCoutDisp := 1 To Len(aDisps[nPosDados])
		If lProcIni
			nLoopFor := Len(aDisps[nPosDados,nCoutDisp])
		Else
			nLoopFor := 1
		EndIf
		
		For nI := 1 To nLoopFor
			If oProcess <> Nil
				If nI == 1 
					// Define a quantidade de registros para a regua de processamento
					oProcess:SetRegua1(nLoopFor)
				EndIf
			
				// Obrigatorio chamar o incremento da regua, a quantidade de chamadas do IncRegua1 precisa ser exatamente a mesma da quantidade definida na regua (SetRegua1)
				oProcess:IncRegua1(STR0112) // "Processando os dispositivos encontrados..."
			EndIf

			If lProcIni
				aRetDisps := {aDisps[nPosDados,nCoutDisp,nI]}
			Else
				aRetDisps := aDisps[nPosDados,nCoutDisp]
			EndIf

			aDados := fMarcBusc(cTempDisp, aRetDisps, nTpIntegr, cDtIni, cDtFim)
			
			If aDados[1] .AND. Len (aDados[nPosDados]) > 0		
				fProcessa( cTempDisp, aDados[nPosDados], lWorkFlow, lVldNSR, @oProcess)			
			Else		
				If aDados[2] <> Nil
					If ! aDados[1] .AND. AT("code",aDados[2]) > 0				
						If ! lWorkFlow
							fMakeLog( aLog, aTitle, Nil, Nil, , OemToAnsi(STR0025), "M", "L",, .F.) //"Log de Ocorrências"
							UnLockByName(cLockName,.F.,.F.,.T.)
							Return (.F.)
						Else
							ConsoleJob(STR0007 + "  " + aDados[2]) //"Não foi possível acessar a API Clockin da Carol. "
						EndIf
					EndIf
				Else
					If ! lWorkFlow
						Help( ,, 'HELP',, STR0007 + "  " + STR0011, 1, 0) //"Não foi possível acessar a API Clockin da Carol. " + "Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
						UnLockByName(cLockName,.F.,.F.,.T.)
						Return (.F.)
					Else
						ConsoleJob(STR0007 + "  " + STR0011) //"Não foi possível acessar a API Clockin da Carol. " + "Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol." 
					EndIf
				EndIf
			EndIf
		Next
	Next
Else
	If ! aDisps[1]
		If at("code",aDisps[2]) > 0		
			If ! lWorkFlow
				fMakeLog( aLog, aTitle, Nil, Nil, , OemToAnsi(STR0025), "M", "L",, .F.) //"Log de Ocorrências"
			Else
				ConsoleJob(STR0007 + "  " + aDisps[2]) //"Não foi possível acessar a API Clockin da Carol. "
			EndIf			
		Else
			If !Empty(aDisps[2])
				If ! lWorkFlow
					fMakeLog( aLog, aTitle, Nil, Nil, , OemToAnsi(STR0025), "M", "L",, .F.) //"Log de Ocorrências"
				Else
					ConsoleJob(aDisps[2]) //Mensagem de erro da API.
				EndIf
			EndIf
		EndIf
	EndIf
	
	UnLockByName(cLockName,.F.,.F.,.T.)
	
	Return (.F.)
EndIf

UnLockByName(cLockName,.F.,.F.,.T.)

If oProcess <> Nil
	// Inclui a informação no log do tNewProcess
	oProcess:SaveLog(STR0075) // "Finalizada a integração com a Carol"
EndIf

aAdd(aLogTitle, STR0115) // "MARCAÇÔES INTEGRADAS"
aAdd(aLogs, {STR0116 + cValToChar(nTotMarc)}) // "Total de marcações gravadas: "

If !lWorkFlow
	RetPergLog(aLogPerg, cPerg)

	fMakeLog(aLogs, aLogTitle, cPerg,,,,,,,,aLogPerg)
Else
	// Formata os parâmetros da pergunta
	aLogPerg := fParFrtLog(cPerg)

	// Gera o resultado dos array no console.log
	fGrvLog2Pl(aLogs, aLogTitle, aLogPerg, STR0050)
EndIf

Return .T.

/*/{Protheus.doc} fProcessa
Processa os dados recebidos gravando na tabela de referencia.
@author Wesley Alves Pereira
@since 17/09/2019
/*/
Static Function fProcessa(cDispo, aInfor, lWorkFlow, lVldNSR, oTNewProc)
Local nRegCount 	:= 0
Local nHoraMarc 	:= 0
Local nProxireg 	:= 0
Local nNumDirec 	:= 3
Local nNumFeder 	:= 2
Local cQuery 		:= ''
Local cDataMarc 	:= ''
Local cNumdoPis 	:= ''
Local cNumdoCPF		:= ''
Local cNumdoNSR 	:= ''
Local cTempHora 	:= ''
Local cCodclien 	:= ''
Local clatitude 	:= ''
Local cLongitude	:= ''
Local cGeofence 	:= ''
Local cCodCCT		:= ''
Local cFilialMar	:= ''
Local cNomeSGDB 	:= Upper(TCGetDB())
Local lProcIni		:= .F.
Local lMSACCT		:= .F.
Local lExtFilMsa		:= .F.
Local lProcNew		:= Empty(cDispo)
Local lGeoFence		:= RR1->( ColumnPos("RR1_LATITU") ) > 0
Local lRR1CCT		:= RR1->( ColumnPos("RR1_CCTREP") ) > 0
Local lRR1CPF		:= RR1->( ColumnPos("RR1_CODCPF") ) > 0
Local nDuplicadas 	:= 0
Local nIncluidas 	:= 0

Default lVldNSR		:= .F.
Default oTNewProc	:= Nil

cCodclien := aParams[4]
lProcIni  := aParams[14]

If aParams[15]
	aAdd(aLogIntegC,STR0090 + cValToChar(Len(aInfor)) + STR0091) //"Foram encontradas " " marcações"
	aAdd(aLogIntegC,STR0092) //"Incluindo as marcações na tabela"
	aAdd(aLogTecInt,STR0090 + cValToChar(Len(aInfor)) + STR0091) //"Foram encontradas " " marcações"
	aAdd(aLogTecInt,STR0092) //"Incluindo as marcações na tabela"
EndIf

// Chama da função para a criação dos novos campos na MSA_CONTROL_MARCAC
If !lTemRR1
	lMSACCT := fVldMSA671()
	lExtFilMsa := fVldMSAFil()
EndIf

For nRegCount := 1 To Len(aInfor)

	If oTNewProc <> Nil
		If nRegCount == 1
			// Define o numero de registros da regua de processamento
			oTNewProc:SetRegua2(Len(aInfor))
		EndIf

		// Altera a mensagem da regua 2
		oTNewProc:IncRegua2(STR0113 + cValToChar(aInfor[nRegCount][2]) + STR0114 + aInfor[nRegCount][9]) // "Processando a NSR " " do dispositivo "
	EndIf
	
	nProxireg	:= 0
	cTempHora	:= ''
	nHoraMarc	:= 0
	cNumdoPis	:= ''
	cNumdoCPF	:= ''
	cNumdoNSR	:= ''
	cDataMarc	:= ''	
	nNumDirec	:= 0
	nNumFeder	:= 0
	clatitude	:= ''
	cLongitude	:= ''
	cGeofence	:= ''
	cCodCCT		:= ''

	If lProcNew
		cDispo := aInfor[nRegCount][9]
	EndIf
	
	If lProcIni .Or. lVldNSR
		If !fValidaNSR(cDispo,aInfor[nRegCount][2]) 
			nDuplicadas++
			If aParams[15]
				aAdd(aLogIntegC,STR0084 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo + STR0089) //"A marcação com NSR " " do dispositivo " " está duplicada e não será processada"
				aAdd(aLogTecInt,STR0084 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo + STR0089) //"A marcação com NSR " " do dispositivo " " está duplicada e não será processada"
			EndIf
			loop
		EndIf
	EndIf
	
	If aInfor[nRegCount][8] <> Nil
		cTempHora := SubStr(aInfor[nRegCount][8],At("T",aInfor[nRegCount][8])+1,5)
		nHoraMarc := (( Val(SubStr(cTempHora,4,2))/60) + (Val(SubStr(cTempHora,1,2)))) * 3600		
		cDataMarc := SubStr(aInfor[nRegCount][8],1,At('.',aInfor[nRegCount][8])-1)
		If Alltrim(cNomeSGDB) == "ORACLE" 
			cDataMarc :=  StrTran(StrTran(cDataMarc,'T',''),'Z','')
		EndIf 
	EndIf		
	
	If aInfor[nRegCount][1] <> Nil
		cNumdoPis := aInfor[nRegCount][1]
		cNumdoPis := StrTran(cNumdoPis,".","")
		cNumdoPis := StrTran(cNumdoPis,"-","")
	EndIf

	If aInfor[nRegCount][5] <> Nil
		cNumdoCPF := aInfor[nRegCount][5]
		cNumdoCPF := StrTran(cNumdoCPF,".","")
		cNumdoCPF := StrTran(cNumdoCPF,"-","")
	EndIf

	If aInfor[nRegCount][10] <> Nil
		cCodCCT := aInfor[nRegCount][10]
		cCodCCT := StrTran(cCodCCT,".","")
		cCodCCT := StrTran(cCodCCT,"-","")
	EndIf
	
	If aInfor[nRegCount][1] <> Nil .Or. aInfor[nRegCount][5] <> Nil
		cNumdoNSR := cValToChar(aInfor[nRegCount][2]) 
	EndIf
	
	If aInfor[nRegCount][11] <> Nil
		cLongitude := If(!Empty(aInfor[nRegCount][11]), cValToChar(aInfor[nRegCount][11]), "")
		clatitude := If(!Empty(aInfor[nRegCount][12]), cValToChar(aInfor[nRegCount][12]), "")
		cGeofence := If(!Empty(aInfor[nRegCount][13]), cValToChar(aInfor[nRegCount][13]), "")
	EndIf
	
	If lTemRR1 .And. !lRR1CPF .And. aInfor[nRegCount][1] == Nil
		If aParams[15]
			aAdd(aLogIntegC,STR0088 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo) //"Erro ao tentar gravar na tabela a marcação com NSR " " do dispositivo "
			aAdd(aLogIntegC,STR0100) //"A marcação possui apenas o CPF e a tabela RR1 não está com o campo RR1_CODCPF criado."
			aAdd(aLogTecInt,STR0088 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo) //"Erro ao tentar gravar na tabela a marcação com NSR " " do dispositivo "
			aAdd(aLogTecInt,STR0100) //"A marcação possui apenas o CPF e a tabela RR1 não está com o campo RR1_CODCPF criado."
			Loop
		EndIf
	EndIf 
	
	nProxireg := fProxRegVal()

	If aInfor[nRegCount][14] <> Nil
		If Empty(aInfor[nRegCount, 14]) .Or. Empty(cNumdoCPF)
			cFilialMar	:= ""
			cLastFil	:= ""
			cLastCPF	:= ""
		ElseIf !Empty(aInfor[nRegCount, 14]) .And. (cLastFil <> aInfor[nRegCount, 14] .Or. cLastCPF <> cNumdoCPF)
			cFilialMar	:= fBuscaFil(aInfor[nRegCount, 14], cNumdoCPF)
			cLastFil	:= aInfor[nRegCount, 14]
			cLastCPF	:= cNumdoCPF
		EndIf
	EndIf

	If !lTemRR1
		cQuery := " INSERT INTO MSA_CONTROL_MARCAC "
		
		If (lMSACCT, cQuery += "(VAL_CONTROL_MARCAC, COD_REP, COD_PIS_MSA, COD_NSR, LOG_IMPORT_PRODUT, DAT_MARCAC_ACES,NUM_HORAR_MARCAC_ACES, NUM_DIRECAO_ACES, COD_ID_FEDER, COD_RELOGIO_EXT_CHAVE, COD_UNID_EXT_CHAVE, COD_CPF_FUNC, COD_CCT ",;
			cQuery += "(VAL_CONTROL_MARCAC, COD_REP, COD_PIS_MSA, COD_NSR, LOG_IMPORT_PRODUT, DAT_MARCAC_ACES,NUM_HORAR_MARCAC_ACES, NUM_DIRECAO_ACES, COD_ID_FEDER, COD_RELOGIO_EXT_CHAVE, COD_UNID_EXT_CHAVE ")

		If (lExtFilMsa, cQuery += ", COD_FIL_MARC )", cQuery += ")")
		
		cQuery += " VALUES("+"'"+cValToChar(nProxireg)+"' ,"
		cQuery += " '"+'00001'+"' ," 
		cQuery += " '"+cNumdoPis +"' ,"
		cQuery += " '"+cNumdoNSR +"' ,"
		cQuery += " '"+'0' +"' ,"
		If Alltrim(cNomeSGDB) == "ORACLE"  
			cQuery += " to_date('"+cDataMarc+"' ,'YYYY-MM-DDHH24:MI:SS'),"
		Else
			cQuery += " '"+cDataMarc +"' ,"
		EndIf
		cQuery += " '"+cValToChar(nHoraMarc) +"' ,"
		cQuery += " '"+cValToChar(nNumDirec) +"' ,"	
		cQuery += " '"+cValToChar(nNumFeder) +"' ,"
		cQuery += " '"+cDispo+"' ,"
		
		If (lMSACCT, cQuery += " '"+cCodclien+"', '" + SubStr(cNumdoCPF,0,11) + "', '"+cCodCCT+"'", cQuery += " '"+cCodclien+"'")
		
		If (lExtFilMsa, cQuery += ", '" +  cFilialMar + "')", cQuery += ")")

		If TCSQLExec( cQuery ) < 0
			
			If ! lWorkFlow
				MsgStop("STR0014" + " - " +  TcSqlError() ) //"Ocorreu erro ao tentar atualizar a tabela 'MSA_CONTROL_MARCAC'"
			Else
				ConsoleJob("STR0014" + " - " +  TcSqlError()) //"Ocorreu erro ao tentar atualizar a tabela 'MSA_CONTROL_MARCAC'"
			EndIf
			If aParams[15]
				aAdd(aLogIntegC,STR0088 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo) //"Erro ao tentar gravar na tabela a marcação com NSR " " do dispositivo "
				aAdd(aLogTecInt,STR0088 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo) //"Erro ao tentar gravar na tabela a marcação com NSR " " do dispositivo "
				aAdd(aLogTecInt,STR0086 + cQuery) //"Query: "
				aAdd(aLogTecInt,STR0087 + TcSqlError()) //"Erro: "
			EndIf 
		Else
			nIncluidas++
			If aParams[15]
				aAdd(aLogIntegC,STR0084 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo + STR0085) //"A marcação com NSR " " do dispositivo " " foi incluida com sucesso"
				aAdd(aLogTecInt,STR0086 + cQuery) //"Query: "
				aAdd(aLogTecInt,STR0084 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo + STR0085) //"A marcação com NSR " " do dispositivo " " foi incluida com sucesso"
			EndIf
		EndIf
	Else
		If RR1->( Reclock("RR1", .T.) )
			If !Empty(cFilialMar)
				RR1->RR1_FILIAL	:= cFilialMar
			EndIf

			RR1->RR1_VALCON		:= nProxireg
			RR1->RR1_CODREL		:= cDispo
			RR1->RR1_LOGIP		:= "0"
			RR1->RR1_CODNSR		:= Val(cNumdoNSR)
			RR1->RR1_CODPIS		:= cNumdoPis
			RR1->RR1_DATMAR		:= sToD( StrTran( SubStr(cDataMarc, 1, 10), "-" ) )
			RR1->RR1_NUMMAR		:= nHoraMarc
			RR1->RR1_CODREP		:= "00001"
			RR1->RR1_CODUNI		:= cCodclien

			If lRR1CPF
				RR1->RR1_CODCPF		:= cNumdoCPF
			EndIf

			If lRR1CCT
				RR1->RR1_CCTREP		:= cCodCCT
			EndIf

			If lGeoFence
				RR1->RR1_LATITU := clatitude
				RR1->RR1_LONGIT := cLongitude
				RR1->RR1_GEOFEN := cGeofence
			EndIf

			RR1->( MsUnlock() )
			nIncluidas++
			If aParams[15]
				aAdd(aLogIntegC,STR0084 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo + STR0085) //"A marcação com NSR " " do dispositivo " " foi incluida com sucesso"
				aAdd(aLogTecInt,STR0084 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo + STR0085) //"A marcação com NSR " " do dispositivo " " foi incluida com sucesso"
			EndIf
		Else
			If !lWorkFlow
				MsgStop(STR0046) //"Ocorreu erro ao tentar atualizar a tabela RR1"
			Else
				ConsoleJob(STR0046) //"Ocorreu erro ao tentar atualizar a tabela RR1"
			EndIf
			If aParams[15]
				aAdd(aLogIntegC,STR0082 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo) //"Erro ao tentar gravar na tabela a marcação com NSR " " do dispositivo "
				aAdd(aLogTecInt,STR0082 + cValToChar(aInfor[nRegCount][2]) + STR0083 + cDispo) //"Erro ao tentar gravar na tabela a marcação com NSR " " do dispositivo "
			EndIf		
		EndIf
	EndIf
	
Next nRegCount

If aParams[15]
	
	aAdd(aLogIntegC, cValToChar(nIncluidas) + " " + STR0103) 
	aAdd(aLogTecInt, cValToChar(nIncluidas) + " " + STR0103) 
	
	aAdd(aLogIntegC, cValToChar(nDuplicadas) + " " + STR0104)
	aAdd(aLogTecInt, cValToChar(nDuplicadas) + " " + STR0104)
	
	aAdd(aLogIntegC,STR0075) //"Finalizada a integração com a Carol"
	aAdd(aLogIntegC,dToC(Date())+" "+Time())
	fGeraLog(@aLogIntegC,STR0050) //"Integração Carol"
	aAdd(aLogTecInt,STR0075) //"Finalizada a integração com a Carol"
	aAdd(aLogTecInt,dToC(Date())+" "+Time())
	fGeraLog(@aLogTecInt,STR0051) //"Log Técnico Integração Carol"
EndIf

nTotMarc += nIncluidas
	
Return (.T.)

/*/{Protheus.doc} fMarcBusc
Busca a listagem de marcações de um determinado dispositivo.
@author Wesley Alves Pereira
@since 13/09/2019
/*/
Function fMarcBusc(cAccesCod, aRetDisp, nTpIntegr, cDtIni, cDtFim, lDashBoard, aFilFiltro)
Local cSiteW    := '' 
Local aAccess	:= {} //AUTENTICAÇÃO DE USUÁRIO
Local aHeader	:= {} //ARRAY CONTENDO O AUTHORIZATION
Local oClient 	
Local cPageSize	:= "&pageSize=500"
Local cURL		:= '' 
Local cURLQry	:= '/api/v3/queries/filter' 
Local cAsort	:= "?indexType=MASTER&sortBy=mdmCounterForEntity,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate&sortOrder=ASC&scrollable=false" 
Local cAsortNew	:= "?indexType=MASTER&sortBy=mdmCounterForEntity,mdmGoldenFieldAndValues.devicecode.raw,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate&sortOrder=ASC" 
Local cBody		:= ''
Local cFields	:= '&fields=mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmpersonid,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicedescription,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode,mdmGoldenFieldAndValues.coordinates,mdmGoldenFieldAndValues.isuserinsidegeofenceenum,mdmGoldenFieldAndValues.collectiveagreement,mdmGoldenFieldAndValues.mdmtaxid,mdmGoldenFieldAndValues.multipleemploymentdevicetaxid'
Local cFieldsQry:= '?fields=mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmpersonid,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicedescription,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode,mdmGoldenFieldAndValues.coordinates,mdmGoldenFieldAndValues.isuserinsidegeofenceenum,mdmGoldenFieldAndValues.collectiveagreement,mdmGoldenFieldAndValues.mdmtaxid,mdmGoldenFieldAndValues.multipleemploymentdevicetaxid'
Local cOffset	:= '&offset=0'
Local cRet		:= ''
Local cRetCarol	:= ''
Local cScroll	:= "&scrollable=true"
Local cScrollID	:= ""
Local aMarcac	:= {} //ARRAY CONTENDO TODAS AS MARCAÇÕES DE UM DISPOSITIVO
Local cAuthlg	:= '' //CHECAGEM DE SUCESSÃO NA CONEXÃO 
Local cDataBase	:= dToC(dDataBase)
Local oErro     := JsonObject():New()
Local oJson     := JsonObject():New()
Local lProcIni	:= .F.
Local lRet 		:= .F.
Local lProcNew	:= .F.
Local lRepost	:= .F.
Local lRepostF	:= .T.
Local nContDisp	:= 0
Local nUltNSR	:= 0
Local nI		:= 0

Local nCont		:= 1

DEFAULT cAccesCod 	:= ""
DEFAULT aRetDisp 	:= {}
DEFAULT nTpIntegr 	:= 1
DEFAULT cDtIni		:= Substr(cDataBase,7,4) + '-' + Substr(cDataBase,4,2) + '-' + Substr(cDataBase,1,2)
DEFAULT cDtFim		:= Substr(cDataBase,7,4) + '-' + Substr(cDataBase,4,2) + '-' + Substr(cDataBase,1,2)
DEFAULT lDashBoard	:= .F.
DEFAULT aFilFiltro	:= {}

cSiteW 		:= aParams[2]
cURL   		:= aParams[9] 
lProcIni	:= aParams[14]

oClient := FwRest():New(cSiteW)

AAdd( aHeader, "Accept: application/json" )
AAdd( aHeader, "content-type: application/json" ) 
AAdd( aHeader, "charset: UTF-8" )  

aAccess	:= fConnCarol()
	
cAuthlg	:= IIF(Len(aAccess) > 2 .And. aAccess[2] != NIL ,aAccess[2],"") 

If !Empty(cAuthlg) .Or. lApiToken
	If !lApiToken
		aHeader[1] := "Authorization:" +cAuthlg
	Else
		AAdd( aHeader, "X-Auth-Key: " + aParams[12] )
		AAdd( aHeader, "X-Auth-ConnectorId: " + aParams[4] )
	EndIf
	
	If aParams[15]
		aAdd(aLogIntegC,"")
		aAdd(aLogIntegC,STR0081) //"Solicitando as marcações para os dispositivos encontrados"
		aAdd(aLogIntegC,dToC(Date())+" "+Time())
		aAdd(aLogTecInt,"")
		aAdd(aLogTecInt,STR0081) //"Solicitando as marcações para os dispositivos encontrados"
		aAdd(aLogTecInt,dToC(Date())+" "+Time())
	EndIf
	
	If Empty(aRetDisp)
		cBody := ""		
		cBody += '{' 
		cBody +=	'"deviceCode": "'+cAccesCod+'",'
		cBody +=	'"nsrCode": "'+fBuscaNSR(cAccesCod, lProcIni)+'",'
		cBody += '}'
	Else
		cBody := ""
		cBody += '{'
		cBody +=	'"minimumShouldMatch": 1,'
		cBody +=	'"resolveRelationships": false,'
		cBody +=	'"mustList": ['
		cBody +=		'{'
		cBody +=			'"mdmFilterType": "TYPE_FILTER",'
		cBody +=			'"mdmValue": "clockinrecordsGolden"'
		cBody +=		'},'
		cBody +=		'{'
		cBody +=			'"mdmFilterType": "TERM_FILTER",'
		cBody +=			'"mdmKey": "mdmMergePending",'
		cBody +=			'"mdmValue": false'
		cBody +=		'}'
		cBody +=	'],'
		cBody +=	'"mustNotList": ['
		cBody +=		'{'
		cBody +=			'"mdmFilterType": "TYPE_FILTER",'
		cBody +=			'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
		cBody +=			'"mdmValue": "0"'
		cBody +=		'}'
		cBody +=	'],'
		cBody +=	'"shouldList": ['
		For nContDisp := 1 To Len(aRetDisp)
			cBody +=		'{'
			cBody +=			'"mdmFilterType": "BOOL_FILTER",'
			cBody +=			'"mdmValue": '
			cBody +=				'{'
			cBody +=					'"mustList": ['
			If (nTpIntegr == 2 .Or. nTpIntegr == 3) .And. !lProcIni
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "TERM_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.devicecode.raw",'
				cBody +=								'"mdmValue": "' + aRetDisp[nContDisp]  + '"'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
				cBody +=								'"mdmValue": ['
				cBody +=										'"1"'
				cBody +=								']'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.mdmeventdate",'
				cBody +=								'"mdmRangeValues": ['
				cBody +=									'"' + cDtIni + '",'
				cBody +=									'"' + cDtFim + '",'
				cBody +=								'],'
				cBody +=								'"rangeStartOperator" : "GREATER_THAN_OR_EQUAL_TO",'
				cBody +=								'"rangeEndOperator" : "LESS_THAN_OR_EQUAL_TO"'
				cBody +=							'}'
			ElseIf lDashBoard
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "TERM_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.devicecode.raw",'
				cBody +=								'"mdmValue": "' + aRetDisp[nContDisp]  + '"'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
				cBody +=								'"mdmValue": ['
				cBody +=										'"0"'
				cBody +=								']'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.mdmeventdate",'
				cBody +=								'"mdmRangeValues": ['
				cBody +=									'"' + cDtIni + '",'
				cBody +=									'"' + cDtFim + '"'
				cBody +=								'],'
				cBody +=								'"rangeStartOperator" : "GREATER_THAN_OR_EQUAL_TO",'
				cBody +=								'"rangeEndOperator" : "LESS_THAN_OR_EQUAL_TO"'
				If !Empty(aFilFiltro)
					cBody +=							'},'
					cBody +=							'{'
					cBody +=								'"mdmFilterType": "MATCH_ANY_TERM_FILTER",'
					cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.mdmtaxid",'
					cBody +=								'"mdmValue": ['
					cBody +=									'"' + ArrTokStr(aFilFiltro,'","') + '"'
					cBody +=								']'
					cBody +=							'}'
				Else
					cBody +=							'}'
				EndIf
			Else
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "TERM_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.devicecode.raw",'
				cBody +=								'"mdmValue": "' + aRetDisp[nContDisp]  + '"'
				cBody +=							'},'
				cBody +=							'{'
				cBody +=								'"mdmFilterType": "RANGE_FILTER",'
				cBody +=								'"mdmKey": "mdmGoldenFieldAndValues.nsrcode",'
				cBody +=								'"mdmValue": ['
				cBody +=										fBuscaNSR(aRetDisp[nContDisp], lProcIni)
				cBody +=								']'
				cBody +=							'}'
			EndIf
			cBody +=					']'
			cBody +=				'}'
			If nContDisp < Len(aRetDisp)
				cBody +=	'},'
			Else
				cBody +=	'}'
			EndIf
		Next nContDisp
		cBody +=	']'
		cBody +='}'
		lProcNew := .T.
	EndIf
	
	oClient:SetPostParams(cBody)
	
	If !lProcNew
		oClient:SetPath(cURL + cAsort + cPageSize + cFields)
		If aParams[15]
			aAdd(aLogIntegC,STR0053 + aParams[2]) //"URL Base: "
			aAdd(aLogIntegC,STR0054 + cURL) //"URL Requisição: "
			aAdd(aLogTecInt,STR0056 + aParams[2]) //" - URL: "
			aAdd(aLogTecInt,STR0057 + cURL) //" - Patch: "
			aAdd(aLogTecInt,STR0058 + cAsort + cPageSize + cFields) //" - Parâmetros: "
			For nI := 1 To Len(aHeader)
				aAdd(aLogTecInt,STR0059 + aHeader[nI]) //" - Header"
			Next
			aAdd(aLogTecInt,STR0080 + cBody) //" - Body: "
		EndIf
	Else
		If lProcIni
			cPageSize := "&pageSize=-1"

			If lDashBoard
				cFields	:= '&fields=mdmGoldenFieldAndValues.piscode,mdmGoldenFieldAndValues.nsrcode,mdmGoldenFieldAndValues.mdmeventdate,mdmGoldenFieldAndValues.eventdatestr,mdmGoldenFieldAndValues.mdmname,mdmGoldenFieldAndValues.devicecode'
			EndIf
			oClient:SetPath(cURLQry + cAsortNew + cPageSize + cFields + cScroll)
		Else
			oClient:SetPath(cURLQry + cAsortNew + cPageSize + cFields + cOffset + cScroll)
		EndIf
		
		If aParams[15]
			aAdd(aLogIntegC,STR0053 + aParams[2]) //"URL Base: "
			aAdd(aLogIntegC,STR0054 + cURLQry) //"URL Requisição: "
			aAdd(aLogTecInt,STR0056 + aParams[2]) //" - URL: "
			aAdd(aLogTecInt,STR0057 + cURLQry) //" - Patch: "
			
			If lProcIni
				aAdd(aLogTecInt,STR0058 + cAsortNew + cPageSize + cFields + cScroll) //" - Parâmetros: "
			Else
				aAdd(aLogTecInt,STR0058 + cAsortNew + cPageSize + cFields + cOffset + cScroll) //" - Parâmetros: "
			EndIf
			
			For nI := 1 To Len(aHeader)
				aAdd(aLogTecInt,STR0059 + aHeader[nI]) // " - Header: "
			Next
			aAdd(aLogTecInt,STR0080 + cBody) //" - Body: "
		EndIf
	EndIf
	
	// Caso não tenha um retorno da API o sistema envia novamente a requisição, com um limite de 5 tentativas
	nCont := 1
	While nCont <= 5
		oClient:Post(aHeader)
		If !oClient:GetResult() == NIL .And. at("totalHits", oClient:GetResult()) > 0
			If aParams[15]
				aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0106) // "Tentativa /5 Estabelecida com sucesso a conexao com a API Carol para obter as marcacoes."
				aAdd(aLogTecInt,STR0063) //"Retorno da API:"
				aAdd(aLogTecInt,oClient:GetResult())
			EndIf
			Exit
		EndIf
		If aParams[15]
			aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0108) //"Tentativa /5. Nao foi possivel conectar com a API da Carol para obter as marcacoes."
			
			If (oClient:GetResult() == Nil, If(!Empty(oClient:cInternalError), cRetCarol := oClient:cInternalError, cRetCarol := STR0107), cRetCarol := oClient:GetResult())
			
			aAdd(aLogTecInt, cRetCarol)
		EndIf
		nCont++
	EndDo
	
	If oClient:GetResult() != Nil .And. at("totalHits", oClient:GetResult()) > 0
		lRet := .T.
		cRet := oClient:GetResult()
		oJson:fromJson(cRet)
		
		If oJson["scrollId"] <> Nil
			cScrollID := oJson["scrollId"]
		EndIf
		
		If aParams[15]
			aAdd(aLogTecInt, STR0063 + cRet)//"Retorno da API:"
			aAdd(aLogTecInt, STR0101 + cScrollID) //" - cScrollID: "
		EndIf

		If oJson["count"] > 0
			fAddMarc(oJson, @aMarcac, @nUltNSR, lDashBoard)
		EndIf

		If oJson["count"] < oJson["totalHits"] 
			lRepost := .T.
			While lRepost
				If !lProcNew
					cBody   := ""					
					cBody 	+= '{' 
					cBody 	+=	'"deviceCode": "'+cAccesCod+'",'
					cBody 	+=	'"nsrCode": "'+cValToChar(nUltNSR+1)+'"'
					cBody 	+= '}'
					cPageSize	:= "&pageSize="+cValToChar(oJson["totalHits"])
					oClient:SetPostParams(cBody)
					oClient:SetPath(cURL + cAsort + cPageSize + cFields)
				ElseIf lRepostF
					oClient:SetPath(cURLQry + "/" + cScrollID + cFieldsQry)
					oClient:SetPostParams("")

					If aParams[15]
						aAdd(aLogTecInt, STR0102 + cURLQry + "/" + cScrollID + cFieldsQry)
					EndIf
				EndIf
				
				// Caso não tenha um retorno da API o sistema envia novamente a requisição, com um limite de 5 tentativas
				nCont := 1
				While nCont <= 5
					oClient:Post(aHeader)
					If !oClient:GetResult() == NIL
						If aParams[15]
							aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0106) // "Tentativa /5 Estabelecida com sucesso a conexao com a API Carol para obter as marcacoes."
							aAdd(aLogTecInt,STR0063) //"Retorno da API:"
							aAdd(aLogTecInt,oClient:GetResult())
						EndIf
						Exit
					EndIf
					If aParams[15]
						aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0108) // "Tentativa /5. Nao foi possivel conectar com a API da Carol para obter as marcacoes."
						
						If (oClient:GetResult() == Nil, If(!Empty(oClient:cInternalError), cRetCarol := oClient:cInternalError, cRetCarol := STR0107), cRetCarol := oClient:GetResult())
						
						aAdd(aLogTecInt, cRetCarol)
					EndIf
					nCont++
				EndDo
				
				If oClient:GetResult() != Nil .And. at("totalHits",oClient:GetResult()) > 0
					cRet := oClient:GetResult()
					oJson:fromJson(cRet)

					If oJson["count"] > 0
						fAddMarc(oJson, @aMarcac, @nUltNSR,lDashBoard)
					Else
						lRepost := .F.
					EndIf
				Else
					lRepost := .F.
				EndIf
			End
		EndIf
		If Empty(aMarcac) .And. aParams[15]
			aAdd(aLogIntegC,STR0078) //"Nenhuma marcação encontrada"
			aAdd(aLogIntegC,STR0075) //"Finalizada a integração com a Carol"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			aAdd(aLogTecInt,STR0063) //"Retorno da API:"
			aAdd(aLogTecInt,cRet)
			aAdd(aLogTecInt,STR0093) //"Nenhuma marcação nova encontrada"
			aAdd(aLogTecInt,STR0075) //"Finalizada a integração com a Carol"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			fGeraLog(@aLogIntegC,STR0050) //"Integração Carol"
			fGeraLog(@aLogTecInt,STR0051) //"Log Técnico Integração Carol"
		EndIf
	Else	
		lRet 		:= .F.
		cRetCarol	:= oClient:GetResult()

		If (cRetCarol == Nil, If(!Empty(oClient:cInternalError), cRetCarol := oClient:cInternalError, cRetCarol := STR0107), Nil)

		cRet 		:= "code:" + cRetCarol
		aMarcac 	:= {}
		oErro:fromJSON( cRetCarol )
		oErro:toJSON( cRetCarol )
		
		If Empty(aMarcac) .And. aParams[15]
			aAdd(aLogIntegC,STR0079) //"Erro na integração"
			aAdd(aLogIntegC,STR0032) //"Verifique se o path da API clockinrecordsList está informado corretamente no parâmetro MV_APICLO8."
			aAdd(aLogIntegC,STR0075) //"Finalizada a integração com a Carol"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			aAdd(aLogTecInt,STR0079) //"Erro na integração"
			aAdd(aLogTecInt,STR0032) //"Verifique se o path da API clockinrecordsList está informado corretamente no parâmetro MV_APICLO8."
			aAdd(aLogTecInt,STR0063) //"Retorno da API:"
			aAdd(aLogTecInt,cRetCarol)
			aAdd(aLogTecInt,STR0075) //"Finalizada a integração com a Carol"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			fGeraLog(@aLogIntegC,STR0050) //"Integração Carol"
			fGeraLog(@aLogTecInt,STR0051) //"Integração Carol"
		EndIf
		
		aAdd( aLog[1], STR0032 )//"Verifique se o path da API clockinrecordsList está informado corretamente no parâmetro MV_APICLO8."
		aAdd( aLog[1], "")
		If !Empty( oErro:getJSONText( "code" ) ) .And. oErro:getJSONText( "code" ) != "null"
			aAdd( aLog[1], STR0027 + oErro:getJSONText( "code" ) )//"Código do erro retornado pela API: "
		EndIf
		If !Empty( oErro:getJSONText( "message" ) ) .And. oErro:getJSONText( "message" ) != "null"
			aAdd( aLog[1], STR0028 + oErro:getJSONText( "message" ) )//"Mensagem de erro retornado pela API: "
		EndIf
		aAdd( aLog[1], "")
		aAdd( aLog[1], STR0031 )//"Configuração dos parâmetros: "
		aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
		aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
		aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
		aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
		aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
		aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
		aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
		aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
		aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )
		
		If aParams[13]
			aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )
		EndIf
		aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )
		
		aAdd( aLog[1], "")
		aAdd( aLog[1], STR0033)//"Erro completo retornado pela API da Carol: "
		FiltraLog( aLog[1], cRetCarol)
	EndIf
Else
	lRet := .F.
	If(Len(aAccess) > 3 .AND. aAccess[3] != NIL)
		cRet := "code:"+aAccess[3]
		aMarcac := {}
	Else
		If aAccess[5] <> Nil .AND. !Empty(aAccess[5])
			cRet := "code:"+aAccess[5]
			aMarcac := {}
		Endif		 
	EndIf
EndIf 

Return ( {lRet,cRet,aMarcac} )

/*/{Protheus.doc} fDispBusc
Função que retorna a lista de dispositivos.
@author edvf8
@since 12/09/2019
@version undefined
/*/
Function fDispBusc()
Local cAuthlg	:= ""																//TOKEN DE ACESSO 
Local cPageSize	:= "&pageSize=500" 													//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(QUANTIDADE DE REGISTROS QUE DEVERÃO RETORNAR)
Local cAsort	:= "&sortOrder=ASC"  												//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(ORDENAÇÃO DOS REGISTROS)
Local cIndexType:= "?indexType=MASTER" 												//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(TIPO DE INDICE)
Local cFields	:= "&fields=mdmGoldenFieldAndValues.devicecode"  					//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(CAMPOS)
Local cFieldsQry:= "?fields=mdmGoldenFieldAndValues.devicecode"  					//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(CAMPOS)
Local cScroll	:= "&scrollable=true"  												//PARAMETRIZAÇÃO PADRÃO DA API DEVICELIST(Scrollable ID)
Local cURL		:= "" 																//URL DE ACESSO A CAROL
Local cURLQry	:= "/api/v3/queries/filter/" 										//URL DE ACESSO A CAROL
Local cBody		:= "" 																//CORPO DA REQUISIÇÃO CASO NECESSÁRIO, NESTA DEVICELIST NÃO POSSUI.
Local cRet		:= "" 																//ARMAZENA O RETORNO EM TEXTO DA API COM A LISTA DE DISPOSITIVOS
Local cScrollID	:= ""
Local cRetCarol	:= "" 																//ARMAZENA O RETORNO EM TEXTO DA API COM A LISTA DE DISPOSITIVOS
Local lRepost	:= .F.
Local lRepostF	:= .T.
Local lSucess	:= .T.
Local nContIds	:= 0 																//VARIAVEL DE CONTROLE PARA USO EM ESTRUTURA DE REPETIÇÃO
Local nI		:= 0

Local aAccess	:= fConnCarol()														//AUTENTICAÇÃO DE USUÁRIO
Local aHeader	:= {} 																//ARRAY CONTENDO O AUTHORIZATION
Local aDisp		:= {} 																//ARRAY CONTENDO OS IDS DOS DISPOSITIVOS

Local oJson     := JsonObject():New()												//JSON QUE RECEBERÁ O RETORNO DA API
Local oErro     := JsonObject():New()												//JSON QUE RECEBERÁ O RETORNO DA API
Local oClient 	:= nil 																//OBJETO REST QUE SERÁ USADO NA REQUISIÇÃO

Local nCont 	:= 1

 	cAuthlg	:= IIF(Len(aAccess) > 2 .And. aAccess[2] != NIL ,aAccess[2],"") 		//CHECAGEM DE SUCESSO NA CONEXÃO E RETORNO DE TOKEN

	If !Empty(cAuthlg) .Or. lApiToken
		oClient 	:= FwRest():New(aParams[2])
		cURL		:= aParams[8] 
		
		If aParams[15]
			aAdd(aLogIntegC,"")
			aAdd(aLogIntegC,STR0071) //"Iniciando a integração com a Carol"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			aAdd(aLogIntegC,STR0072) //"Buscando os dispositivos"
			aAdd(aLogIntegC,STR0053 + aParams[2]) //"URL Base: "
			aAdd(aLogIntegC,STR0054 + cURL) //"URL Requisição: "
			aAdd(aLogTecInt,"")
			aAdd(aLogTecInt,STR0071) //"Iniciando a integração com a Carol"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			aAdd(aLogTecInt,STR0072) //"Buscando os dispositivos"
			aAdd(aLogTecInt,STR0056 + aParams[2]) //" - URL: "
			aAdd(aLogTecInt,STR0057 + cURL) //" - Path: "
			aAdd(aLogTecInt,STR0058 + cIndexType + cPageSize + cAsort + cFields + cScroll) //" - Parâmetros: "
		EndIf

		oClient:SetPath(cURL + cIndexType + cPageSize + cAsort + cFields + cScroll)
		
		If !lApiToken
			aHeader:= { "Authorization: Bearer " + cAuthlg,;
					"Content-Type: application/json; charset=UTF-8";
					}
		Else
			aHeader:= { "X-Auth-Key: " + aParams[12],;
					"X-Auth-ConnectorId: " + aParams[4],;
					"Content-Type: application/json; charset=UTF-8";
					}			
			If aParams[15]
				For nI := 1 To Len(aHeader)
					aAdd(aLogTecInt,STR0059 + aHeader[nI]) //" - Header: "
				Next
			EndIf
		EndIf

		oClient:SetPostParams(cBody)

		// Caso não tenha um retorno da API o sistema envia novamente a requisição, com um limite de 5 tentativas
		nCont := 1
		While nCont <= 5
			oClient:Post(aHeader)
			If !oClient:GetResult() == NIL .And. at("hits", oClient:GetResult()) > 0
				If aParams[15]
					aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0109) // "Tentativa /5. Estabelecida com sucesso a conexao com a API Carol para obter os dispositivos."
					aAdd(aLogTecInt,STR0063) //"Retorno da API:"
					aAdd(aLogTecInt,oClient:GetResult())
				EndIf
				Exit
			EndIf
			If aParams[15]
				aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0110) // "Tentaiva /5. Nao foi possivel conectar com a API da Carol para obter os dispositivos."
				
				If (oClient:GetResult() == Nil, If(!Empty(oClient:cInternalError), cRetCarol := oClient:cInternalError, cRetCarol := STR0107), cRetCarol := oClient:GetResult())
				
				aAdd(aLogTecInt, cRetCarol)
			EndIf
			nCont++
		EndDo
		
		If oClient:GetResult() != Nil .And. at("hits", oClient:GetResult()) > 0
			cRet := oClient:GetResult()
			
			oJson:fromJson(cRet)
			cScrollID	:= oJson["scrollId"]

			If oJson["count"] > 0
				aAdd(aDisp, {})
				If aParams[15]
					aAdd(aLogIntegC,STR0073 + cValToChar(oJson["totalHits"])) //"Dispositivos encontrados: "
					aAdd(aLogTecInt,STR0073 + cValToChar(oJson["totalHits"])) //"Dispositivos encontrados: "
					aAdd(aLogTecInt,STR0063) //"Retorno da API:"
					aAdd(aLogTecInt,cRet)
				EndIf
				For nContIds:= 1 to Len(oJson["hits"])
					// Agrupa os dispositivos a cada 100 para busca das marcações
					If nContIds % 100 == 0
						aAdd(aDisp[Len(aDisp)], oJson["hits"][nContIds]["mdmGoldenFieldAndValues"]["devicecode"])

						If (nContIds < Len(oJson["hits"]), aAdd(aDisp, {}), Nil)

						Loop
					Else
						aAdd(aDisp[Len(aDisp)], oJson["hits"][nContIds]["mdmGoldenFieldAndValues"]["devicecode"])
					EndIf
				Next
			EndIf

			If oJson["count"] < oJson["totalHits"]
				lRepost := .T.
				While lRepost
					If lRepostF
						oClient:SetPath(cURLQry + cScrollID + cFieldsQry)
						lRepostF := .F.
					EndIf
					
					// Caso não tenha um retorno da API o sistema envia novamente a requisição, com um limite de 5 tentativas
					nCont := 1
					While nCont <= 5
						oClient:Post(aHeader)
						If !oClient:GetResult() == NIL .And. at("hits", oClient:GetResult()) > 0
							If aParams[15]
								aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0109) // "Tentativa /5. Estabelecida com sucesso a conexao com a API Carol para obter os dispositivos."
								aAdd(aLogTecInt,STR0063) //"Retorno da API:"
								aAdd(aLogTecInt,oClient:GetResult())
							EndIf
							Exit
						EndIf
						If aParams[15]
							aAdd(aLogTecInt, STR0105 + " " + cValToChar(nCont) + STR0110) // "Tentativa /5. Nao foi possivel conectar com a API da Carol para obter os dispositivos."
							
							If (oClient:GetResult() == Nil, If(!Empty(oClient:cInternalError), cRetCarol := oClient:cInternalError, cRetCarol := STR0107), cRetCarol := oClient:GetResult())
							
							aAdd(aLogTecInt, cRetCarol)
						EndIf
						nCont++
					EndDo
					
					If oClient:GetResult() != Nil .And. at("hits", oClient:GetResult()) > 0
						cRet := oClient:GetResult()
						oJson:fromJson(cRet)
						If oJson["count"] > 0
							aAdd(aDisp, {})
							For nContIds := 1 to Len(oJson["hits"])
								// Agrupa os dispositivos a cada 100 para busca das marcações
								If nContIds % 100 == 0
									aAdd(aDisp[Len(aDisp)], oJson["hits"][nContIds]["mdmGoldenFieldAndValues"]["devicecode"])
									
									If (nContIds < Len(oJson["hits"]), aAdd(aDisp, {}), Nil)

									Loop
								Else
									aAdd(aDisp[Len(aDisp)], oJson["hits"][nContIds]["mdmGoldenFieldAndValues"]["devicecode"])
								EndIf
							Next
						Else
							lRepost := .F.
						EndIf
					Else
						lRepost := .F.
					EndIf
				EndDo
			EndIf

			lSucess:= .T.
			
			If aParams[15]
				If Len(aDisp[Len(aDisp)]) == 0
					aAdd(aLogIntegC,STR0074) //"Nenhum dispositivo encontrado"
					aAdd(aLogIntegC,STR0075) //"Finalizada a integração com a Carol"
					aAdd(aLogIntegC,dToC(Date())+" "+Time())
					aAdd(aLogTecInt,STR0074) //"Nenhum dispositivo encontrado"
					aAdd(aLogTecInt,STR0075) //"Finalizada a integração com a Carol"
					aAdd(aLogTecInt,dToC(Date())+" "+Time())
				EndIf
			EndIf
			
		Else
			cRet:= oClient:GetResult()
			lRet 		:= .F.
			cRetCarol	:= oClient:GetResult()

			If (cRetCarol == Nil, If(!Empty(oClient:cInternalError), cRetCarol := oClient:cInternalError, cRetCarol := ""), Nil)

			cRet 		:= "code:" + cRetCarol
			oErro:fromJSON( cRetCarol )
			oErro:toJSON( cRetCarol )

			aAdd( aLog[1], STR0009 )//"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
			aAdd( aLog[1], "")

			If aParams[15]
				aAdd(aLogIntegC,STR0009) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
				aAdd(aLogIntegC,STR0075) //"Finalizada a integração com a Carol"
				aAdd(aLogIntegC,dToC(Date())+" "+Time())
				aAdd(aLogTecInt,STR0009) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
				aAdd(aLogTecInt,STR0063) //"Retorno da API:"
				aAdd(aLogTecInt,cRetCarol) 
				aAdd(aLogTecInt,STR0075) //"Finalizada a integração com a Carol"
				aAdd(aLogTecInt,dToC(Date())+" "+Time())
				fGeraLog(@aLogIntegC,STR0050) //"Integração Carol"
				fGeraLog(@aLogTecInt,STR0051) //"Log Técnico Integração Carol"
			EndIf

			If !Empty( oErro:getJSONText( "code" ) ) .And. oErro:getJSONText( "code" ) != "null"
				aAdd( aLog[1], STR0027 + oErro:getJSONText( "code" ) )//"Código do erro retornado pela API: "
			EndIf
			If !Empty( oErro:getJSONText( "message" ) ) .And. oErro:getJSONText( "message" ) != "null"
				aAdd( aLog[1], STR0028 + oErro:getJSONText( "message" ) )//"Mensagem de erro retornado pela API: "
			EndIf
			aAdd( aLog[1], "")
			aAdd( aLog[1], STR0031 )//"Configuração dos parâmetros: "
			aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
			aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
			aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
			aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
			aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
			aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
			aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
			aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
			aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )

			If aParams[13]
				aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )
			EndIf
			aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )

			aAdd( aLog[1], "")
			aAdd( aLog[1], STR0033)//"Erro completo retornado pela API da Carol: "
			FiltraLog( aLog[1], cRetCarol)
			lSucess:= .F.
		EndIf

	Else
		lSucess:= .F.
		cRet:= aAccess[5]
	EndIf 
	
Return {lSucess,cRet,aDisp}


/*/{Protheus.doc} fConnCarol
Programa de liberação de Token para acesso a API´s Clock In da Carol
@author Wesley Alves Pereira
@since 12/09/2019
@return return, return_description
/*/
Function fConnCarol()

Local aHeader   := {}
Local aRetorno  := {}
Local cParams   := ""
Local cRet      := ""
Local cRetCarol := ""
Local cPath     := ""
Local ccURL		:= ""
Local cErro     := ""
Local nCont		:= 0
Local nI		:= 0
Local oErro     := JsonObject():New()
Local oRet      := JsonObject():New()
Local lSucess   := .T.
Local lErro		:= .F.
Local lAtuaToken:= .F.
Local oObj		:= Nil
Local oClient   := Nil
Local lGeraLog	:= .F.

lGeraLog := If(aParams[15] .And. FWIsInCallStack("fDispBusc"),.T.,.F.)

If lGeraLog
	aAdd(aLogIntegC,STR0047) //"Início do processo de autenticação"
	aAdd(aLogIntegC,dToC(Date())+" "+Time())
	aLogTecInt := aClone(aLogIntegC)
EndIf

If Empty(aParams[2])
	aAdd( aLog[1], STR0001 ) //"Verifique o parametro MV_APICLO1 pois ele é responsável pelo cadastro da URL de EndPoint para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0001)
		aAdd(aLogTecInt,STR0001)
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[3]) .OR. aParams[3] == "/" 
	aAdd( aLog[1], STR0002 ) //"Verifique o parametro MV_APICLO2 pois ele é responsável pelo cadastro do path da api Token para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0002) //"Verifique o parametro MV_APICLO2 pois ele é responsável pelo cadastro do path da api Token para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0002) //"Verifique o parametro MV_APICLO2 pois ele é responsável pelo cadastro do path da api Token para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[4])
	aAdd( aLog[1], STR0003 ) //"Verifique o parametro MV_APICLO3 pois ele é responsável pelo cadastro do Id Conector para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0003) //"Verifique o parametro MV_APICLO3 pois ele é responsável pelo cadastro do Id Conector para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0003) //"Verifique o parametro MV_APICLO3 pois ele é responsável pelo cadastro do Id Conector para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[7])
	aAdd( aLog[1], STR0006 ) //"Verifique o parametro MV_APICLO6 pois ele é responsável pelo cadastro do Domain Name para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0006) //"Verifique o parametro MV_APICLO6 pois ele é responsável pelo cadastro do Domain Name para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0006) //"Verifique o parametro MV_APICLO6 pois ele é responsável pelo cadastro do Domain Name para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[8]) .OR. aParams[8] == "/" 
	aAdd( aLog[1], STR0009 ) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0009) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0009) //"Verifique o parametro MV_APICLO7 pois ele é responsável pelo cadastro do path da api DeviceList  para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[9]) .OR. aParams[9] == "/" 
	aAdd( aLog[1], STR0011 ) //"Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0011) //"Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0011) //"Verifique o parametro MV_APICLO8 pois ele é responsável pelo cadastro do path da api clockinrecordsList para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If Empty(aParams[10]) 
	aAdd( aLog[1], STR0044 ) //"Verifique o parametro MV_APICLO9 pois ele é responsável pelo cadastro do Organization Name para a integração de Clockin da Carol."
	If lGeraLog
		aAdd(aLogIntegC,STR0044) //"Verifique o parametro MV_APICLO9 pois ele é responsável pelo cadastro do Organization Name para a integração de Clockin da Carol."
		aAdd(aLogTecInt,STR0044) //"Verifique o parametro MV_APICLO9 pois ele é responsável pelo cadastro do Organization Name para a integração de Clockin da Carol."
	EndIf
	lErro := .T.
EndIf

If ( (Empty(aParams[5]) .Or. Empty(aParams[6]) ) .And. Empty(aParams[12]) )
	aAdd( aLog[1], STR0043 ) //"Para realizar a integração será necessário preencher os parâmetros MV_APICLO4 e MV_APICLO5 ou MV_APICLOA."
	If lGeraLog
		aAdd(aLogIntegC,STR0043) //"Para realizar a integração será necessário preencher os parâmetros MV_APICLO4 e MV_APICLO5 ou MV_APICLOA."
		aAdd(aLogTecInt,STR0043) //"Para realizar a integração será necessário preencher os parâmetros MV_APICLO4 e MV_APICLO5 ou MV_APICLOA."
	EndIf
	lErro := .T.
EndIf

If lErro
	lSucess := .F.

	aAdd( aLog[1], "")
	aAdd( aLog[1], STR0031 )//"Configuração dos parâmetros: "
	aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
	aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
	aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
	aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
	aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
	aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
	aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
	aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
	aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )

	If aParams[13]
		aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )	
	EndIf
	aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )	

	aAdd(aRetorno,lSucess)
	aAdd(aRetorno,Nil)
	aAdd(aRetorno,Nil)
	aAdd(aRetorno,"")
	aAdd(aRetorno,STR0042)

	If lGeraLog
		aAdd(aLogIntegC,STR0048) //"Falha na autenticação"
		aAdd(aLogTecInt,STR0048) //"Falha na autenticação"
		aAdd(aLogIntegC,STR0049) //"Fim do processo de autenticação"
		aAdd(aLogTecInt,STR0049) //"Fim do processo de autenticação"
		fGeraLog(@aLogIntegC,STR0050) //"Integração Carol"
		fGeraLog(@aLogTecInt,STR0051) //"Log Técnico Integração Carol"
	EndIf

	Return (aRetorno)
EndIf

// Verifica se a autenticação deve ser realizada via API Token
If !Empty(aParams[12])
	// Faz um teste do Connector Token informado
	ccURL	:= aParams[2]
	cPath	:= "/api/v3/apiKey/details"
	cParams := "apiKey=" + aParams[12] +"&"
	cParams += "connectorId=" + aParams[4]

	AAdd( aHeader, "Accept: application/json" )
	AAdd( aHeader, "X-Auth-Key: " + aParams[12] )
	AAdd( aHeader, "X-Auth-ConnectorId: " + aParams[4] )

	oClient := FwRest():New(ccURL)
	oClient:SetPath(cPath)
	oClient:SetPostParams(cParams)
	oClient:Get(aHeader,cParams)

	If lGeraLog
		aAdd(aLogIntegC,STR0052) //"Validando o API Token"
		aAdd(aLogIntegC,STR0053 + ccURL) //"URL Base: "
		aAdd(aLogIntegC,STR0054 + cPath) //"URL Requisição: "
		aAdd(aLogIntegC,STR0055) //"Iniciando a validação do API Token"
		aAdd(aLogTecInt,STR0052) //"Validando o API Token"
		aAdd(aLogTecInt,STR0056 + ccURL) //" - URL: "
		aAdd(aLogTecInt,STR0057 + cPath) //" - Path: "
		aAdd(aLogTecInt,STR0058 + cParams) //" - Parâmetros: "
		For nI := 1 To Len(aHeader)
			aAdd(aLogTecInt,STR0059 + aHeader[nI]) // " - Header: "
		Next
		aAdd(aLogTecInt,STR0055) //"Iniciando a validação do API Token"
		aAdd(aLogTecInt,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
	EndIf

	If FWJsonDeserialize(oClient:GetResult(),@oObj)
		If oObj <> Nil
			cRet := oClient:GetResult()
			If oRet:fromJson(cRet) == Nil .And. oRet["errorCode"] == Nil
				lApiToken := .T.
				lSucess := .T.
				cErro := "ok"
				If lGeraLog
					aAdd(aLogIntegC,STR0062) //"API Token validado com sucesso"
					aAdd(aLogTecInt,STR0062) //"API Token validado com sucesso"
					aAdd(aLogTecInt,STR0063) //"Retorno da API:"
					aAdd(aLogTecInt,cRet)
				EndIf
			Else
				oErro:fromJSON( cRet )
				oErro:toJSON( cRet )
				If !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) == "404" .And. oErro:getJSONText( "possibleResponsibleField" ) == "apiKey" 
					lAtuaToken := .T.
					If lGeraLog
						aAdd(aLogIntegC,STR0064) //"Erro ao validar a API Token"
						aAdd(aLogIntegC,STR0065) //"API Token inválida"
						aAdd(aLogTecInt,STR0064) //"Erro ao validar a API Token"
						aAdd(aLogTecInt,STR0065) //"API Token inválida"
						aAdd(aLogTecInt,STR0063) //"Retorno da API:"
						aAdd(aLogTecInt,cRet)
					EndIf
				ElseIf !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) == "404" .And. oErro:getJSONText( "possibleResponsibleField" ) == "mdmName" 
					aAdd( aLog[1], STR0038 )//"O Connector Id preenchido no parâmetro MV_APICLO3 está incorreto."
					aAdd( aLog[1], STR0040 )//"Foi realizado uma tentativa de autenticação por usuário e senha."
					aAdd( aLog[1], "")
					If lGeraLog
						aAdd(aLogIntegC,STR0064) //"Erro ao validar a API Token"
						aAdd(aLogIntegC,STR0066) //"Connector Id inválido"
						aAdd(aLogTecInt,STR0064) //"Erro ao validar a API Token"
						aAdd(aLogTecInt,STR0066) //"Connector Id inválido"
						aAdd(aLogTecInt,STR0063) //"Retorno da API:"
						aAdd(aLogTecInt,cRet)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Else
	If Len(aLog) > 0
		If Len(aLog[1]) > 0
			If !aScan(aLog, {|x| x[1] == "Falha na autenticação por API Key (Opcional)."}) > 0
				aAdd( aLog[1], STR0039 )//"Falha na autenticação por API Key (Opcional)."
				aAdd( aLog[1], STR0041 )//"Para utilizar a autenticação por API Key crie o parâmetro MV_APICLOA e preencha com o token gerado pela Carol."
				aAdd( aLog[1], STR0040 )//"Foi realizado uma tentativa de autenticação por usuário e senha."
				aAdd( aLog[1], "" )
			EndIf
		Else
			aAdd( aLog[1], STR0039 )//"Falha na autenticação por API Key (Opcional)."
			aAdd( aLog[1], STR0041 )//"Para utilizar a autenticação por API Key crie o parâmetro MV_APICLOA e preencha com o token gerado pela Carol."
			aAdd( aLog[1], STR0040 )//"Foi realizado uma tentativa de autenticação por usuário e senha."
			aAdd( aLog[1], "" )
		EndIf
	EndIf
EndIf

If !lApiToken
	// Autenticação utilizando usuário e senha para gerar o Access Token
	aHeader := {}
	AAdd( aHeader, "Accept: application/json" )
	AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded" )
	ccURL := aParams[2]
	cPath := aParams[3]
	cParams := "grant_type=password&"
	cParams += "connectorId=" + aParams[4] + "&"
	cParams += "username=" + aParams[5] + "&"
	cParams += "password=" + aParams[6] + "&"
	cParams += "subdomain=" + AllTrim(aParams[10]) + "&"
	cParams += "orgSubdomain=" + aParams[7]

	oClient := FwRest():New(ccURL)
	oClient:SetPath(cPath)
	oClient:SetPostParams(cParams)

	If lGeraLog
		aAdd(aLogIntegC,STR0067) //"Inicializando autenticação utilizando usuário e senha"
		aAdd(aLogIntegC,STR0053 + ccURL) //"URL Base: "
		aAdd(aLogIntegC,STR0054 + cPath) //"URL Requisição: "
		aAdd(aLogTecInt,STR0067) //"Inicializando autenticação utilizando usuário e senha"
		aAdd(aLogTecInt,STR0056 + ccURL) //" - URL: "
		aAdd(aLogTecInt,STR0057 + cPath) //" - Path: "
		aAdd(aLogTecInt,STR0058 + cParams) //" - Parâmetros: "
		For nI := 1 To Len(aHeader)
			aAdd(aLogTecInt,STR0059 + aHeader[nI]) // " - Header: "
		Next
	EndIf

	If lSucess .And. oClient:Post(aHeader)
		If lGeraLog
			aAdd(aLogTecInt,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
		EndIf
		If FWJsonDeserialize(oClient:GetResult(),@oObj)
			If oObj <> Nil			
				cRet := oClient:GetResult()
				If oRet:fromJson(cRet) == Nil .And. oRet["access_token"] <> Nil
					lSucess := .T.
					cErro := "ok"
					If lGeraLog
						aAdd(aLogIntegC,STR0068) //"Usuário e senha validado com sucesso"
						aAdd(aLogTecInt,STR0068) //"Usuário e senha validado com sucesso"
						aAdd(aLogTecInt,STR0063) //"Retorno da API:"
						aAdd(aLogTecInt,cRet)
					EndIf
					// Tenta gerar o API Token se não existir, para ser utilizado
					// em integrações futuras
					If ( !lGeraTokn .And. aParams[13] .And. Empty( aParams[12] ) ) .Or. lAtuaToken
						fGeraApiTk(aParams[2], oRet:GetJsonText( "access_token" ), aParams[4], aParams[10], lGeraLog)
					EndIf
				EndIf
			EndIf
		EndIf	
	Else	
		lSucess := .F.
		cRet := oClient:GetResult()

		If lAtuaToken
			aAdd( aLog[1], STR0037 ) //"API Key (Connector Token) inválida, verifique se a API Key está correta ou revogue, gere uma nova API Key e preencha no parâmetro MV_APICLOA."
			aAdd( aLog[1], STR0040 ) //"Foi realizado uma tentativa de autenticação por usuário e senha."
			aAdd( aLog[1], "")			
			If lGeraLog
				aAdd(aLogIntegC,STR0037) //"API Key (Connector Token) inválida, verifique se a API Key está correta ou revogue, gere uma nova API Key e preencha no parâmetro MV_APICLOA."
				aAdd(aLogIntegC,STR0040)
				aAdd(aLogTecInt,STR0037) //"API Key (Connector Token) inválida, verifique se a API Key está correta ou revogue, gere uma nova API Key e preencha no parâmetro MV_APICLOA."
				aAdd(aLogTecInt,STR0040)
			EndIf
		EndIf
		If Empty(cRet)
			aAdd( aLog[1], STR0007) //"Não foi possível acessar a API Clockin da Carol. "
			aAdd( aLog[1], STR0026 ) //"Verifique se a URL de Endpoint da Carol está informada corretamente no parâmetro MV_APICLO1."
			
			If lGeraLog
				aAdd(aLogIntegC,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
				aAdd(aLogIntegC,STR0007) //"Não foi possível acessar a API Clockin da Carol. "
				aAdd(aLogIntegC,STR0026) //"Verifique se a URL de Endpoint da Carol está informada corretamente no parâmetro MV_APICLO1."
				aAdd(aLogTecInt,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
				aAdd(aLogTecInt,STR0007) //"Não foi possível acessar a API Clockin da Carol. "
				aAdd(aLogTecInt,STR0026) //"Verifique se a URL de Endpoint da Carol está informada corretamente no parâmetro MV_APICLO1."
			EndIf
		Else
			cRetCarol := cRet
			oErro:fromJSON( cRet )
			oErro:toJSON( cRet )

			If !Empty( oErro:getJSONText( "code" ) ) .And. oErro:getJSONText( "code" ) != "null" .And. ( Empty( oErro:getJSONText( "errorCode" ) ) .Or. oErro:getJSONText( "errorCode" ) == "null")
				aAdd( aLog[1], STR0034 ) //"Verifique se o path de acesso da API da Carol está informada corretamente no parâmetro MV_APICLO2."
				aAdd( aLog[1], "")
				If lGeraLog
					aAdd(aLogIntegC,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
					aAdd(aLogIntegC,STR0007) //"Não foi possível acessar a API Clockin da Carol"
					aAdd(aLogIntegC,STR0034) //"Verifique se o path de acesso da API da Carol está informada corretamente no parâmetro MV_APICLO2."
					aAdd(aLogTecInt,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
					aAdd(aLogTecInt,STR0007) //"Não foi possível acessar a API Clockin da Carol"
					aAdd(aLogTecInt,STR0034) //"Verifique se o path de acesso da API da Carol está informada corretamente no parâmetro MV_APICLO2."
				EndIf
			EndIf

			If !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) != "null" .And. ( Empty( oErro:getJSONText( "code" ) ) .Or. oErro:getJSONText( "code" ) == "null")
				If lGeraLog
					aAdd(aLogIntegC,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
					aAdd(aLogTecInt,STR0061 + oClient:oResponseh:cStatusCode) //" - Http status code: "
				EndIf
				If oErro:getJSONText( "errorCode" ) == "400" .Or. oErro:getJSONText( "errorCode" ) == "401"
					aAdd( aLog[1], STR0035 ) //"Verifique se o usuário e a senha estão informados corretamente nos parâmetros MV_APICLO4 e MV_APICLO5."
					If lGeraLog
						aAdd(aLogIntegC,STR0035) //"Verifique se o usuário e a senha estão informados corretamente nos parâmetros MV_APICLO4 e MV_APICLO5."
						aAdd(aLogTecInt,STR0035) //"Verifique se o usuário e a senha estão informados corretamente nos parâmetros MV_APICLO4 e MV_APICLO5."
					EndIf
				ElseIf !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) == "404" .And. oErro:getJSONText( "possibleResponsibleField" ) == "mdmSubdomain" 
					aAdd( aLog[1], STR0036 ) //"Verifique se o subdomínio e a organização estão informados corretamente nos parâmetros MV_APICLO6 e MV_APICLO9."
					If lGeraLog
						aAdd(aLogIntegC,STR0036) //"Verifique se o subdomínio e a organização estão informados corretamente nos parâmetros MV_APICLO6 e MV_APICLO9."
						aAdd(aLogTecInt,STR0036) //"Verifique se o subdomínio e a organização estão informados corretamente nos parâmetros MV_APICLO6 e MV_APICLO9."
					EndIf
				ElseIf !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) == "404" .And. oErro:getJSONText( "possibleResponsibleField" ) == "mdmName" 
					aAdd( aLog[1], STR0069) //"Verifique se o Connector Id preenchido no parâmetro MV_APICLO3 está correto."
					If lGeraLog
						aAdd(aLogIntegC,STR0069) //"Verifique se o Connector Id preenchido no parâmetro MV_APICLO3 está correto."
						aAdd(aLogTecInt,STR0069) //"Verifique se o Connector Id preenchido no parâmetro MV_APICLO3 está correto."
					EndIf
				EndIf
				aAdd( aLog[1], "")
			EndIf

			If !Empty( oErro:getJSONText( "errorCode" ) ) .And. oErro:getJSONText( "errorCode" ) != "null"
				aAdd( aLog[1], STR0027 + oErro:getJSONText( "errorCode" ) )//"Código do erro retornado pela API: "
			EndIf
			If !Empty( oErro:getJSONText( "code" ) ) .And. oErro:getJSONText( "code" ) != "null"
				aAdd( aLog[1], STR0027 + oErro:getJSONText( "code" ) )//"Código do erro retornado pela API: "
			EndIf
			If !Empty( oErro:getJSONText( "errorMessage" ) ) .And. oErro:getJSONText( "errorMessage" ) != "null"
				aAdd( aLog[1], STR0028 + oErro:getJSONText( "errorMessage" ) )//"Mensagem de erro retornado pela API: "
				If lGeraLog
					aAdd(aLogIntegC,STR0028) //"Mensagem de erro retornado pela API: "
					aAdd(aLogIntegC,oErro:getJSONText( "errorMessage" )) //"Mensagem de erro retornado pela API: "
				EndIf
			EndIf
			If !Empty( oErro:getJSONText( "message" ) ) .And. oErro:getJSONText( "message" ) != "null"
				aAdd( aLog[1], STR0028 + oErro:getJSONText( "message" ) ) //"Mensagem de erro retornado pela API: "
				If lGeraLog
					aAdd(aLogIntegC,STR0028) //"Mensagem de erro retornado pela API: "
					aAdd(aLogIntegC,oErro:getJSONText( "message" )) //"Mensagem de erro retornado pela API: "
				EndIf
			EndIf
			If !Empty( oErro:getJSONText( "possibleResponsibleField" ) ) .And. oErro:getJSONText( "possibleResponsibleField" ) != "null"
				aAdd( aLog[1], STR0029 + oErro:getJSONText( "possibleResponsibleField" ) ) //"Possível campo responsável pelo erro retornado pela API: "
				If lGeraLog
					aAdd(aLogIntegC,STR0029 + oErro:getJSONText( "possibleResponsibleField" )) //"Possível campo responsável pelo erro retornado pela API: "
				EndIf
			EndIf
			If !Empty( oErro:getJSONText( "applicationErrorCode" ) ) .And. oErro:getJSONText( "applicationErrorCode" ) != "null"
				aAdd( aLog[1], STR0030 + oErro:getJSONText( "applicationErrorCode" ) )//"Código do erro retornado pela aplicação: "
			EndIf
		EndIf
		aAdd( aLog[1], "")
		aAdd( aLog[1], STR0031 )//"Configuração dos parâmetros: "
		aAdd( aLog[1], "  MV_APICLO1: " + aParams[2] )
		aAdd( aLog[1], "  MV_APICLO2: " + aParams[3] )
		aAdd( aLog[1], "  MV_APICLO3: " + aParams[4] )
		aAdd( aLog[1], "  MV_APICLO4: " + aParams[5] )
		aAdd( aLog[1], "  MV_APICLO5: " + aParams[6] )
		aAdd( aLog[1], "  MV_APICLO6: " + aParams[7] )
		aAdd( aLog[1], "  MV_APICLO7: " + aParams[8] )
		aAdd( aLog[1], "  MV_APICLO8: " + aParams[9] )
		aAdd( aLog[1], "  MV_APICLO9: " + aParams[10] )

		If aParams[13]
			aAdd( aLog[1], "  MV_APICLOA: " + aParams[12] )
		EndIf
		aAdd( aLog[1], "  MV_APICLOB: " + cValToChar(aParams[14]) )

		If !Empty(cRetCarol)
			aAdd( aLog[1], "")
			aAdd( aLog[1], STR0033)//"Erro completo retornado pela API da Carol: "
		EndIf
		
		If lGeraLog
			aAdd(aLogIntegC,STR0070) //"Fim do processo de autenticação"
			aAdd(aLogIntegC,dToC(Date())+" "+Time())
			If !Empty(cRet)
				aAdd(aLogTecInt,STR0063) //"Retorno da API:"
				aAdd(aLogTecInt,cRet)
			EndIf
			aAdd(aLogTecInt,STR0070) //"Fim do processo de autenticação"
			aAdd(aLogTecInt,dToC(Date())+" "+Time())
			fGeraLog(@aLogIntegC,STR0050) //"Integração Carol"
			fGeraLog(@aLogTecInt,STR0051) //"Log Técnico Integração Carol"
		EndIf
	EndIf
EndIf    

If cRet == Nil
	cRet := ""
EndIf

aAdd(aRetorno,lSucess)

If lSucess
	If !lApiToken
		aAdd(aRetorno,oRet:GetJsonText("access_token"))
		aAdd(aRetorno,oRet)
	EndIf
Else
	aAdd(aRetorno,Nil)
	aAdd(aRetorno,Nil)

	For nCont := 1 To Len( aLog[1] )
		cErro += aLog[1, nCont] + CRLF
	Next nCont
EndIf


If !lApiToken
	aAdd(aRetorno,cRet)
	aAdd(aRetorno,cErro)
EndIf

If lGeraLog
	aAdd(aLogIntegC,STR0070) //"Fim do processo de autenticação"
	aAdd(aLogIntegC,dToC(Date())+" "+Time())
	aAdd(aLogTecInt,STR0070) //"Fim do processo de autenticação"
	aAdd(aLogTecInt,dToC(Date())+" "+Time())
EndIf

Return (aRetorno)

/*/{Protheus.doc} fBuscaParam
Carregando os parâmetros
@author Wesley Alves Pereira
@since 12/09/2019
/*/
Function fBuscaParam()
Local aParam 	:= {}
Local lTipoI 	:= SUPERGETMV('MV_APICLO0', .F., .F.)
Local cSiteW 	:= Alltrim(SUPERGETMV('MV_APICLO1', .F., ''))
Local cPathW 	:= Alltrim(SUPERGETMV('MV_APICLO2', .F., ''))
Local cConec 	:= Alltrim(SUPERGETMV('MV_APICLO3', .F., ''))
Local cUsern 	:= Alltrim(SUPERGETMV('MV_APICLO4', .F., ''))
Local cPassw 	:= Alltrim(SUPERGETMV('MV_APICLO5', .F., ''))
Local cDomin 	:= Alltrim(SUPERGETMV('MV_APICLO6', .F., ''))
Local cPathD 	:= Alltrim(SUPERGETMV('MV_APICLO7', .F., ''))
Local cPathM 	:= Alltrim(SUPERGETMV('MV_APICLO8', .F., ''))
Local lOrgExist	:= SUPERGETMV('MV_APICLO9',.F.,.F.)
Local cOrg	 	:= Alltrim(SUPERGETMV('MV_APICLO9', .F., ''))
Local lApiExist	:= SUPERGETMV('MV_APICLOA',.F.,.F.)
Local cApiToken	:= Alltrim(SUPERGETMV('MV_APICLOA', .F., ''))
Local lProcIni	:= SUPERGETMV('MV_APICLOB',.F.,.F.)
Local lGeraLog	:= SUPERGETMV('MV_APICLOC',.F.,.F.)

lOrgExist := ValType(lOrgExist) == "C"
lApiExist := ValType(lApiExist) == "C"

aAdd(aParam,lTipoI)
aAdd(aParam,cSiteW)
aAdd(aParam,Iif(Substr(cPathW,1,1) <> '/', '/'+cPathW, cPathW ))
aAdd(aParam,cConec)
aAdd(aParam,cUsern)
aAdd(aParam,cPassw)
aAdd(aParam,cDomin)
aAdd(aParam,Iif(Substr(cPathD,1,1) <> '/', '/'+cPathD, cPathD ))
aAdd(aParam,Iif(Substr(cPathM,1,1) <> '/', '/'+cPathM, cPathM ))
aAdd(aParam,cOrg)
aAdd(aParam,lOrgExist)
aAdd(aParam,cApiToken)
aAdd(aParam,lApiExist)
aAdd(aParam,lProcIni)
aAdd(aParam,lGeraLog)

Return (aParam)

/*/{Protheus.doc} fBuscaNSR
Busca o código NSR do último dispositivo lido.
@author Wesley Alves Pereira
@since 12/09/2019
/*/
Static Function fBuscaNSR(cAccesCod, lProcIni)
Local nContador		:= 0
Local cAliasTMP		:= GetNextAlias()
Local cAliasNSR1	:= ""
Local cSelect		:= ""
Local cTabInteg		:= ""
Local cWhere		:= ""
Local cQuery		:= ""
Local cQueryNSR1	:= ""

Default cAccesCod	:= ""
Default lProcIni	:= .F.

If !lTemRR1
	If !lProcIni
		cSelect 	:= "MAX(COD_NSR) AS MAXIMO"
	Else
		cSelect 	:= "MIN(COD_NSR) AS MAXIMO"
	EndIf
	cTabInteg 		:= "MSA_CONTROL_MARCAC"
	If !lProcIni
		cWhere 		:= "COD_RELOGIO_EXT_CHAVE = ?"
	Else
		cWhere 		:= "COD_RELOGIO_EXT_CHAVE = ? AND COD_NSR+1 NOT IN (SELECT COD_NSR FROM MSA_CONTROL_MARCAC WHERE COD_RELOGIO_EXT_CHAVE = ?)"
	EndIf
Else
	If !lProcIni
		cSelect 	:= "MAX(RR1_CODNSR) AS MAXIMO"
	Else
		cSelect 	:= "MIN(RR1_CODNSR) AS MAXIMO"
	EndIf
	cTabInteg 		:= RetSqlName('RR1')
	If !lProcIni
		cWhere 		:= "RR1_CODREL = ?"
	Else
		cWhere 		:= "RR1_CODREL = ? AND RR1_CODNSR+1 NOT IN (SELECT RR1_CODNSR FROM "+RetSqlName('RR1')+" WHERE RR1_CODREL = ?)"
	EndIf
EndIf

If __oSt01 == Nil
	__oSt01 := FWPreparedStatement():New()

	cQuery := "SELECT " + cSelect
	cQuery += " FROM " + cTabInteg
	cQuery += " WHERE " + cWhere
	cQuery := ChangeQuery(cQuery)
		
	__oSt01:SetQuery(cQuery)
EndIf

__oSt01:SetString(1, cAccesCod)
If lProcIni
	__oSt01:SetString(2, cAccesCod)
EndIf

cQuery := __oSt01:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTMP, .T., .T.)

nContador := (cAliasTMP)->(MAXIMO)
nContador++

// Verifica se exisite a NSR 1, se não existir busca as marcações desde a primeira NSR.
If lProcIni
	If __oSt04 == Nil
		If lTemRR1
			cQueryNSR1 := "SELECT COUNT(*) AS COD_NSR FROM " + RetSqlName('RR1') + " WHERE RR1_CODREL = ? AND RR1_CODNSR = ? "
		Else
			cQueryNSR1 := "SELECT COUNT(*) AS COD_NSR FROM MSA_CONTROL_MARCAC WHERE COD_RELOGIO_EXT_CHAVE = ? AND COD_NSR = ? "
		EndIf
		
		cQueryNSR1 := ChangeQuery(cQueryNSR1)
		__oSt04 := FwExecStatement():New(cQueryNSR1)
	EndIf

	__oSt04:SetString(1, cAccesCod)
	__oSt04:SetNumeric(2, 1)

	cAliasNSR1 := __oSt04:OpenAlias()
	
	If ((cAliasNSR1)->COD_NSR == 0, nContador := 1, Nil)

	(cAliasNSR1)->(dbCloseArea())
EndIf

( cAliasTMP )->(dbCloseArea())

Return (cValToChar(nContador))

/*/{Protheus.doc} fProxRegVal
Busca o proximo registro sequencial da tabela.
@author Wesley Alves Pereira
@since 17/09/2019
/*/
Static Function fProxRegVal()

Local nContador := 0
Local cAliasTMP := GetNextAlias()
Local cSelect	:= ""
Local cTabInteg := ""
Local cQuery 	:= ""

If !lTemRR1
	cSelect 	:= "MAX(VAL_CONTROL_MARCAC) AS MAXIMO"
	cTabInteg 	:= "MSA_CONTROL_MARCAC"
Else
	cSelect 	:= "MAX(RR1_VALCON) AS MAXIMO"
	cTabInteg 	:= RetSqlName('RR1')
EndIf

If __oSt02 == Nil
	__oSt02 := FWPreparedStatement():New()

	cQuery := "SELECT " + cSelect
	cQuery += " FROM " + cTabInteg
	cQuery := ChangeQuery(cQuery)
		
	__oSt02:SetQuery(cQuery)
EndIf

cQuery := __oSt02:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTMP, .T., .T.)

nContador := (cAliasTMP)->(MAXIMO)

( cAliasTMP )->(dbCloseArea())

nContador += 1

Return (nContador)

/*/{Protheus.doc} fValidaNSR
Valida se o NSR Informado já existe na tabela.
@author Wesley Alves Pereira
@since 19/09/2019
/*/
Static Function fValidaNSR(cDispo,cCodNSR) 

Local nContador := 0
Local cAliasTMP := GetNextAlias()
Local cSelect	:= ""
Local cTabInteg := ""
Local cWhere 	:= ""
Local lRetorno 	:= .T.
Local cQuery 	:= ""

If !lTemRR1
	cSelect 	:= "VAL_CONTROL_MARCAC"
	cTabInteg 	:= "MSA_CONTROL_MARCAC
	cWhere 		:= "COD_RELOGIO_EXT_CHAVE = ? AND COD_NSR = ?"
Else
	cSelect 	:= "RR1_VALCON AS VAL_CONTROL_MARCAC"
	cTabInteg 	:= RetSqlName('RR1')
	cWhere 		:= "RR1_CODREL = ? AND RR1_CODNSR = ?"
EndIf

If __oSt03 == Nil
	__oSt03 := FWPreparedStatement():New()

	cQuery := "SELECT " + cSelect
	cQuery += " FROM " + cTabInteg
	cQuery += " WHERE " + cWhere
	cQuery := ChangeQuery(cQuery)
		
	__oSt03:SetQuery(cQuery)
EndIf

__oSt03:SetString(1, cDispo)
__oSt03:SetString(2, cValToChar(cCodNSR))

cQuery := __oSt03:getFixQuery()

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasTMP, .T., .T.)

nContador := (cAliasTMP)->(VAL_CONTROL_MARCAC)

( cAliasTMP )->(dbCloseArea())

If nContador > 0
	lRetorno := .F.
EndIf

Return (lRetorno)

/*/{Protheus.doc} ConsoleJob
Exibe uma mensagem no console quando a rotina for via Schedule.
@author Wesley Alves Pereira
@since 18/09/2019
/*/
Static Function ConsoleJob(cMensagem)

Conout(Replicate("-",30))
Conout(FwNoAccent(OemToAnsi(STR0013))) //"Execução da Rotina PONAPI01 - Via Schedule"
Conout(FwNoAccent(OemToAnsi(cMensagem)))
Conout(Replicate("-",30))

Return (.T.)

/*/{Protheus.doc} fTemTabMSA
Verifica a existencia da tabela de integração.
@author Wesley Alves Pereira
@since 21/10/2019
/*/
Function fTemTabMSA()
Local lReto := .T.

If ! TcCanOpen('MSA_CONTROL_MARCAC')
	lReto := .F.
EndIf

Return (lReto) 	

/*/{Protheus.doc} fCriaTab
Realiza a criação da tabela de integração.
@author Wesley Alves Pereira
@since 21/10/2019
/*/
Function fCriaTab(lWorkFlow)
Local lReto := .T.
Local cNomeSGDB := Upper(TCGetDB())

Local cTcQry := ""
Local cReto := ""
Local lTrata := .F.

If Alltrim(cNomeSGDB) == "MSSQL"

	lTrata := .T.
	
	cTcQry := "	CREATE TABLE [dbo].[MSA_CONTROL_MARCAC]( "
	cTcQry += "		[VAL_CONTROL_MARCAC] [bigint] PRIMARY KEY NOT NULL, "
	cTcQry += "		[COD_ID_PREVID_SOCIAL] [varchar](20), "
	cTcQry += "		[COD_RELOGIO_EXT_CHAVE] [varchar](100), "
	cTcQry += "		[NUM_DIRECAO_ACES] [int] NOT NULL, "
	cTcQry += "		[COD_FUNC_MSA] [varchar](100), "
	cTcQry += "		[COD_ID_FEDER] [varchar](50) NOT NULL, "
	cTcQry += "		[COD_HASH] [varchar] (255), "
	cTcQry += "		[LOG_IMPORT_PRODUT] [tinyint], "
	cTcQry += "		[COD_LOTE] [varchar] (100), "
	cTcQry += "		[COD_NSR] [int] NOT NULL, "
	cTcQry += "		[COD_PIS_MSA] [varchar] (12) NOT NULL, "
	cTcQry += "		[VAL_PERF_ACES] [int], "
	cTcQry += "		[DAT_MARCAC_ACES] [datetime] NOT NULL, "
	cTcQry += "		[NUM_HORAR_MARCAC_ACES] [int] NOT NULL, "
	cTcQry += "		[COD_REP] [varchar] (17) NOT NULL, "
	cTcQry += "		COD_UNID_EXT_CHAVE [varchar] (100), "
	cTcQry += "		COD_USUAR_EXT_CHAVE [varchar] (100), "	
	cTcQry += "		[COD_FUSO] [varchar] (5), "
	cTcQry += "		[COD_CPF_FUNC] [varchar] (11), "	
	cTcQry += "		[NUM_VERS_LAYOUT_AFD] [int], "
	cTcQry += "		[COD_INSCR_EMP] [varchar] (14), "
	cTcQry += "		[COD_CCT] [varchar] (17), "
	cTcQry += "		[COD_FIL_MARC] [varchar] (20) "
	cTcQry += ")  "
	
ElseIf Alltrim(cNomeSGDB) == "ORACLE"

	lTrata := .T.
	
	cTcQry := "	CREATE TABLE MSA_CONTROL_MARCAC ( "
	cTcQry += "		VAL_CONTROL_MARCAC NUMBER(19) PRIMARY KEY NOT NULL, "
	cTcQry += "		COD_ID_PREVID_SOCIAL varchar2 (20), "
	cTcQry += "		COD_RELOGIO_EXT_CHAVE varchar2 (100), "
	cTcQry += "		NUM_DIRECAO_ACES NUMBER(10) NOT NULL, "
	cTcQry += "		COD_FUNC_MSA varchar2 (100), "
	cTcQry += "		COD_ID_FEDER varchar2 (50) NOT NULL, "
	cTcQry += "		COD_HASH varchar2 (255), "
	cTcQry += "		LOG_IMPORT_PRODUT NUMBER(3), "
	cTcQry += "		COD_LOTE varchar2 (100), "
	cTcQry += "		COD_NSR NUMBER(10) NOT NULL, "
	cTcQry += "		COD_PIS_MSA varchar2 (12) NOT NULL, "
	cTcQry += "		VAL_PERF_ACES NUMBER(10), "
	cTcQry += "		DAT_MARCAC_ACES DATE NOT NULL, "
	cTcQry += "		NUM_HORAR_MARCAC_ACES NUMBER(10) NOT NULL, "
	cTcQry += "		COD_REP varchar2 (17) NOT NULL, "
	cTcQry += "		COD_UNID_EXT_CHAVE varchar2 (100), "
	cTcQry += "		COD_USUAR_EXT_CHAVE varchar2 (100), "	
	cTcQry += "		COD_FUSO varchar2 (5), "	
	cTcQry += "		COD_CPF_FUNC varchar2 (11), "	
	cTcQry += "		NUM_VERS_LAYOUT_AFD NUMBER (3), "	
	cTcQry += "		COD_INSCR_EMP varchar2 (14), "	
	cTcQry += "		COD_CCT varchar2 (17), "
	cTcQry += "		COD_FIL_MARC varchar2 (20) "	
	cTcQry += ")  "

ElseIf Alltrim(cNomeSGDB) == "POSTGRES"

	lTrata := .T.
	
	cTcQry := "	CREATE TABLE MSA_CONTROL_MARCAC ( "
	cTcQry += "		VAL_CONTROL_MARCAC bigint PRIMARY KEY NOT NULL, "
	cTcQry += "		COD_ID_PREVID_SOCIAL varchar(20), "
	cTcQry += "		COD_RELOGIO_EXT_CHAVE varchar(100), "
	cTcQry += "		NUM_DIRECAO_ACES int NOT NULL, "
	cTcQry += "		COD_FUNC_MSA varchar(100), "
	cTcQry += "		COD_ID_FEDER varchar(50) NOT NULL, "
	cTcQry += "		COD_HASH varchar(255), "
	cTcQry += "		LOG_IMPORT_PRODUT smallint, "
	cTcQry += "		COD_LOTE varchar (100), "
	cTcQry += "		COD_NSR int NOT NULL, "
	cTcQry += "		COD_PIS_MSA varchar (12) NOT NULL, "
	cTcQry += "		VAL_PERF_ACES int, "
	cTcQry += "		DAT_MARCAC_ACES Date NOT NULL, "
	cTcQry += "		NUM_HORAR_MARCAC_ACES int NOT NULL, "
	cTcQry += "		COD_REP varchar (17) NOT NULL, "
	cTcQry += "		COD_UNID_EXT_CHAVE varchar (100), "
	cTcQry += "		COD_USUAR_EXT_CHAVE varchar (100), "
	cTcQry += "		COD_FUSO varchar (5), "
	cTcQry += "		COD_CPF_FUNC varchar (11), "
	cTcQry += "		NUM_VERS_LAYOUT_AFD int, "
	cTcQry += "		COD_INSCR_EMP varchar(14), "
	cTcQry += "		COD_CCT varchar(17), "
	cTcQry += "		COD_FIL_MARC varchar(20) "
	cTcQry += ")  "
	
EndIf

If lTrata
	//Executa a query	
	If TcSqlExec(cTcQry) < 0
		cReto := TcSqlError()
		lReto := .F.
		If !lWorkFlow
			Help( ,, 'HELP',, cReto, 1, 0) //Mensagem de erro na Criação da tabela de integração
		Else
			ConsoleJob(cReto) //Mensagem de erro na Criação da tabela de integração
		EndIf
	EndIf
Else
	lReto := .F.
EndIf

Return (lReto)

/*/{Protheus.doc} FiltraLog
//Função que quebra o texto para gravação no log
@author paulo.inzonha
@since 25/07/2019
@version 1.0
@return NIL
@param aLogCalc, array, Array que deve ser preenchido com a mensagem do log
@param cTexto, characters, Texto que deve ser apresentado no log
@type function
/*/
Static Function FiltraLog(aLogCalc, cTexto)
Local nPos := 0

If Len(Alltrim(cTexto)) >= 210
	nPos := At(" ",cTexto,200)
	If nPos > 0
		aAdd(aLogCalc, substr(cTexto,1,nPos))
		aAdd(aLogCalc, substr(cTexto,nPos))
	Else
		aAdd(aLogCalc, substr(cTexto,1,209))
		aAdd(aLogCalc, substr(cTexto,210))
	EndIf
Else
	aAdd(aLogCalc, cTexto)
EndIf

Return( NIL )

/*/{Protheus.doc} fGeraApiTk
//Função para gerar o API Token 
@author marco.nakazawa
@since 26/08/2020
@version 1.0
@return NIL
@param URL Carol, Access Token, Conector Id, Organização
@type function
/*/
Static Function fGeraApiTk( ccURL, cAccesTokn, cConecId, cOrg, lGeraLog)
Local aHeader	:= {}
Local cPath		:= ""
Local cParams	:= ""
Local cRet		:= ""
Local oClient	:= Nil
Local oObj		:= Nil
Local oRet		:= JsonObject():New()
Local nI		:= 0

Default ccURL		:= ""
Default cAccesTokn	:= ""
Default cConecId	:= ""
Default cOrg		:= ""
Default lGeraLog	:= .F.

	If !Empty(cAccesTokn) .And. !Empty(cConecId) .And. !Empty(ccURL) .And. !Empty(cOrg)
		cPath	:= "/api/v1/apiKey/issue"
		cParams := "connectorId=" + cConecId + "&
		cParams += "description=%7B%22en-US%22%3A%22API%20Token%20Protheus%22%7D"

		aAdd( aHeader, "Accept: application/json" )
		aAdd( aHeader, "Authorization:" + cAccesTokn )
		aAdd( aHeader, "Content-type: application/x-www-form-urlencoded" )
		aAdd( aHeader, "Origin:" + ccURL )
		aAdd( aHeader, "Referer:" + ccURL + "/" + cOrg + "/carol-ui/environment/connector-tokens" )

		oClient := FwRest():New(ccURL)
		oClient:SetPath(cPath)
		oClient:SetPostParams(cParams)
		oClient:Post(aHeader)

		If lGeraLog
			aAdd(aLogIntegC,STR0076) //"Iniciado o processo automático para geração da API Token"
			aAdd(aLogIntegC,STR0053 + ccURL) //"URL Base: "
			aAdd(aLogIntegC,STR0054 + cPath) //"URL Requisição: "
			aAdd(aLogTecInt,STR0076) //"Iniciado o processo automático para geração da API Token"
			aAdd(aLogTecInt,STR0056 + ccURL) //" - URL: "
			aAdd(aLogTecInt,STR0057 + cPath) //" - Patch: "
			aAdd(aLogTecInt,STR0058 + cParams) //" - Parâmetros: "
			For nI := 1 To Len(aHeader)
				aAdd(aLogTecInt,STR0059 + aHeader[nI]) //" - Header: "
			Next
		EndIf
		
		If FWJsonDeserialize(oClient:GetResult(),@oObj)
			If oObj <> Nil
				cRet := oClient:GetResult()
				If oRet:fromJson(cRet) == Nil .And. oRet["errorCode"] == Nil
					PutMv("MV_APICLOA",oRet["X-Auth-Key"])
					lGeraTokn := .T.
					If lGeraLog
						aAdd(aLogIntegC,STR0077) //"API Token gerada com sucesso e salvo no parâmetro MV_APICLOA"
						aAdd(aLogTecInt,STR0077) //"API Token gerada com sucesso e salvo no parâmetro MV_APICLOA"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} fAddMarc
//Função para adicionar marcações no array para posterior gravação 
@author allyson.mesashi
@since 14/01/2021
@version 1.0
@return NIL
@type static function
/*/
Static Function fAddMarc(oJson, aMarcac, nUltNSR, lDashBoard)

Local aTemp		:= {}
Local nCoutRegs	:= 0

Default lDashBoard := .F.

For nCoutRegs:= 1 to Len(oJson["hits"])			
	If (!Empty(oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["piscode"]) .Or. !Empty(oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmpersonid"])) .And. !lDashBoard
		aTemp   := {oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["piscode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["nsrcode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmeventdate"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["eventdatestr"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmpersonid"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmname"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["devicedescription"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["eventdatestr"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["devicecode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["collectiveagreement"]}
			
		If ValType(oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["coordinates"]) != "U"
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["coordinates"]["lon"])
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["coordinates"]["lat"])
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["isuserinsidegeofenceenum"])
		Else
			aAdd(aTemp, "")
			aAdd(aTemp, "")
			aAdd(aTemp, "")
		EndIf

		If ValType(oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["multipleemploymentdevicetaxid"]) != "U"
			aAdd(aTemp, oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["multipleemploymentdevicetaxid"])
		Else
			aAdd(aTemp, "")
		EndIf

		nUltNSR := oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["nsrcode"]
		aAdd(aMarcac,aTemp)					
	ElseIf lDashBoard
		aTemp   := {oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["collectiveagreement"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmpersonid"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["piscode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmtaxid"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["mdmname"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["devicecode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["nsrcode"],;
					oJson["hits"][nCoutRegs]["mdmGoldenFieldAndValues"]["eventdatestr"];
				}
		aAdd(aMarcac,aTemp)
	EndIf				
Next nCoutRegs

Return

/*/{Protheus.doc} fGeraLog
//Função para gerar arquivo de log em txt
@author marco.nakazawa
@since 27/09/2021
@version 1.0
@return NIL
@type static function
/*/
Static Function fGeraLog(aLog,cNomeArq)
Local nLenArq		:= 0
Local nI			:= 0
Local nHandle		:= 0
Local cLogPatch		:= GetSrvProfString("Startpath","")
Local cDir			:= "\carol integration\"

DEFAULT aLog		:= {}
DEFAULT cNomeArq	:= ""

If (cDataExec == Nil, cDataExec := dToS(Date()),Nil)

If cNomeArq == STR0050
	cNomeArq := "Carol Integration " + Substr(cDataExec,1,4) + "-" + Substr(cDataExec,5,2) + "-" + Substr(cDataExec,7,2)
ElseIf cNomeArq == STR0051
	cNomeArq := "Carol Integration Technical Log " + Substr(cDataExec,1,4) + "-" + Substr(cDataExec,5,2) + "-" + Substr(cDataExec,7,2)
EndIf

If !ExistDir(cLogPatch + cDir)
	MakeDir( cLogPatch + cDir)
EndIf

If !Empty(aLog) .And. !Empty(cNomeArq)
	nLenArq := Len(aLog)
	If (nHandle := fopen(cLogPatch + cDir + cNomeArq + ".txt",2,Nil,.F.)) == -1
		If (nHandle := FCREATE(cLogPatch + cDir + cNomeArq + ".txt",,Nil,.F.)) != -1
			FSeek(nHandle, 0, 2)
			For nI:=1 To nLenArq
				FWrite(nHandle, aLog[nI] + CRLF )
			Next
			FWrite(nHandle,CRLF)
		EndIf
  	Else
		FSeek(nHandle, 0, 2)
		For nI:=1 To nLenArq
			FWrite(nHandle, aLog[nI] + CRLF )
		Next
		FWrite(nHandle,CRLF)
	EndIf

	fClose(nHandle)
EndIf

aLog := {}
Return

/*/{Protheus.doc} fExistPerg
//Função para verificar se existe o grupo de perguntas
@author marco.nakazawa
@since 06/04/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function fExistPerg(cPergunte)
Local lRet	:= .F.
Local oSX1	:= FWSX1Util():New()

oSX1:AddGroup(cPergunte)
oSX1:SearchGroup()

If !Empty(oSX1:aGrupo[1,2])
	lRet:= .T.
EndIf

FreeObj(oSX1)
Return lRet

/*/{Protheus.doc} fVldMSA671
//Função para validar e criar os campos da 671 na tabela MSA_CONTROL_MARCAC
@author marco.nakazawa
@since 06/04/2022
@version 1.0
@return NIL
@type static function
/*/
Function fVldMSA671()
Local lRet	 	:= .F.
Local cQuery 	:= ""
Local cNomeSGDB := Upper(TCGetDB())

If TCSQLExec("SELECT COD_FUSO, COD_CPF_FUNC, NUM_VERS_LAYOUT_AFD, COD_INSCR_EMP FROM MSA_CONTROL_MARCAC") < 0
	If Alltrim(cNomeSGDB) == "MSSQL" .Or. Alltrim(cNomeSGDB) == "POSTGRES"
		BeginContent var cQuery
			ALTER TABLE MSA_CONTROL_MARCAC ADD COD_FUSO varchar(5); 
			ALTER TABLE MSA_CONTROL_MARCAC ADD COD_CPF_FUNC varchar(11); 
			ALTER TABLE MSA_CONTROL_MARCAC ADD NUM_VERS_LAYOUT_AFD int; 
			ALTER TABLE MSA_CONTROL_MARCAC ADD COD_INSCR_EMP varchar(14); 
		EndContent
	ElseIf Alltrim(cNomeSGDB) == "ORACLE"
		BeginContent var cQuery
			ALTER TABLE MSA_CONTROL_MARCAC 
			ADD COD_FUSO varchar2(5)
			ADD COD_CPF_FUNC varchar2(11)
			ADD NUM_VERS_LAYOUT_AFD NUMBER(3)
			ADD COD_INSCR_EMP varchar2(14)
		EndContent
	EndIf
EndIf

If TCSQLExec("SELECT COD_CCT FROM MSA_CONTROL_MARCAC") < 0
	If Alltrim(cNomeSGDB) == "MSSQL" .Or. Alltrim(cNomeSGDB) == "POSTGRES"
		cQuery += "ALTER TABLE MSA_CONTROL_MARCAC ADD COD_CCT varchar(17)"
	ElseIf Alltrim(cNomeSGDB) == "ORACLE"
		cQuery += If(Empty(cQuery), " ALTER TABLE MSA_CONTROL_MARCAC ADD COD_CCT varchar2(17)", " ADD COD_CCT varchar2(17)") 
	EndIf
EndIf

If !Empty(cQuery)
	If ((TCSQLExec(cQuery) < 0), Conout(STR0014 + TCSQLError()), lRet := .T.)
Else
	lRet := .T.
Endif

Return lRet

/*/{Protheus.doc} fVldMSAFil
Função para validar e criar o campo que irá armazenar a filial da marcação
@author marco.nakazawa
@since 17/04/2022
@version 1.0
@return NIL
@type function
/*/
Function fVldMSAFil()
Local cQuery 	:= ""
Local cNomeSGDB := Upper(TCGetDB())
Local lRet		:= .F.

If TCSQLExec("SELECT COD_FIL_MARC FROM MSA_CONTROL_MARCAC") < 0
	If Alltrim(cNomeSGDB) == "MSSQL" .Or. Alltrim(cNomeSGDB) == "POSTGRES"
		cQuery := "ALTER TABLE MSA_CONTROL_MARCAC ADD COD_FIL_MARC varchar(20)"
	ElseIf Alltrim(cNomeSGDB) == "ORACLE"
		cQuery := "ALTER TABLE MSA_CONTROL_MARCAC ADD COD_FIL_MARC varchar2(20)"
	EndIf
EndIf

If !Empty(cQuery)
	If ((TCSQLExec(cQuery) < 0), Conout(STR0014 + TCSQLError()), lRet := .T.)
Else
	lRet := .T.
EndIf
Return lRet

/*/{Protheus.doc} fBuscaFil
Função para identificar a filial informada na marcação
@author marco.nakazawa
@since 06/04/2022
@version 1.0
@return NIL
@type function
/*/
Function fBuscaFil(cCnpj, cCPF)
Local cQuery	:= ""
Local cAliasQry	:= ""
Local cRet		:= ""
Local nI		:= 0
Local aFilEnct	:= {}

Default cCnpj	:= ""
Default cCPF	:= ""

If !Empty(cCnpj) .And. !Empty(cCPF)
	For nI := 1 To nLenFil
		If AllTrim(aFiliais[nI,18]) == AllTrim(cCnpj)
			aAdd(aFilEnct, aFiliais[nI,2])
		EndIf
	Next
	
	If !Empty(aFilEnct)
		If oStaClkIn == Nil
			cQuery := "SELECT RA_FILIAL "
			cQuery += "FROM " + RetSqlName("SRA") + " SRA "
			cQuery += "WHERE SRA.RA_FILIAL IN (?) "
			cQuery += "AND SRA.RA_CIC = ? "
			cQuery += "AND SRA.D_E_L_E_T_= ' '"
			
			cQuery := ChangeQuery(cQuery)
		
			oStaClkIn := FwExecStatement():New(cQuery)	
		EndIf

		oStaClkIn:SetIn(1, aFilEnct)
		oStaClkIn:SetString(2, cCPF)

		cAliasQry := oStaClkIn:OpenAlias()
			
		If (cAliasQry)->(!EoF())
			cRet := (cAliasQry)->RA_FILIAL

			(cAliasQry)->(dbSkip())
		EndIf
	EndIf
EndIf
Return cRet

/*/{Protheus.doc} SchedDef
Definições utilizadas pelo Schedule
/*/
Static Function Scheddef()
Local aOrd		:= {}
Local aParam	:= {}

aParam := {	"P"			, ; // Tipo R para relatorio P para processo
			"PNAPI01"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
			""			, ; // Alias para o relatório
			aOrd		, ; // Array de ordens para o relatório
			""			}
Return aParam
