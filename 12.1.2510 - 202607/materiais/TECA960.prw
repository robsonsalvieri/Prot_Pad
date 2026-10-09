#INCLUDE 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'TECA960.CH' 

Static aCentCusto := {}
Static cFolder    := ""
Static lTrocaCC   := .F.
Static nEnv       := 0
Static nNEnv      := 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA960
	Programacao de Rateio

@sample 	TECA960() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA960(lJob, aParams, aAtendentes)

Local aRet       :={.T., {}}
Local aTemp      := {}
Local cCliAt     := ""
Local cCliDe     := ""
Local cCompt     := ""
Local cDirArq    := At960RHD()
Local cMsg       := ""
Local cPE        := "At960PrRt"
Local cPerg      := "TECA960"
Local cTpExp     := SuperGetMV("MV_GSOUT", .F., "1") //1 - Integracao RH protheus(Default) - 2 Ponto de Entrada - 3 Arquivo CSV
Local dDtFim     := CTOD("")
Local dDtIni     := CTOD("")
Local lCont      := .F.
Local lFolder    := TecHasPerg("MV_PAR10",cPerg)
Local lOk        := .F.
Local lPergRtCt  := TecHasPerg("MV_PAR09", cPerg) // Verifique se existe o pergunte (SX1) "Rateia Contrato?"
Local lRateiaCtr := .F.
Local lRhRM      := SuperGetMv("MV_GSXINT",,"2") == "3"
Local nGerLg     := 0
Local nHandle    := 0
Local nProc      := 0
Local nSobrR     := 0
Local oProcess   := Nil

Default aAtendentes := {}
Default aParams     := {}
Default lJob        := IsBlind()

While Pergunte(cPerg, !lJob)

	If lJob
		MV_PAR01 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR01"})][2]
		MV_PAR02 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR02"})][2]
		MV_PAR03 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR03"})][2]
		MV_PAR04 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR04"})][2]
		MV_PAR05 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR05"})][2]
		MV_PAR06 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR06"})][2]
		MV_PAR07 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR07"})][2]
		MV_PAR08 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR08"})][2]
		If lPergRtCt 
			MV_PAR09 := aParams[ASCAN(aParams, {|d| d[1] == "MV_PAR09"})][2]
		EndIf
	EndIf

	cCliDe  := MV_PAR01 // Cliente de:
	cCliAt	:= MV_PAR02 // Cliente ate:
	dDtIni	:= MV_PAR03 // Data de:
	dDtFim	:= MV_PAR04 // Data ate:
	cCompt	:= MV_PAR05 // Competencia da folha:
	nSobrR	:= MV_PAR06 // Sobrescrever Rateio:
	nProc	:= MV_PAR07 // Processamento (envio/estorno)
	nGerLg	:= MV_PAR08 // Gera Log?

	If lPergRtCt 
		IF VALTYPE(MV_PAR09) == 'N' .AND. MV_PAR09 == 1
			lRateiaCtr := .T.
		ELSE
			lRateiaCtr := .F.
		ENDIF
	EndIf
	
	If lFolder
		cFolder := AllTrim(MV_PAR10) // Local do Arquivo de Log:
		If !Empty(cFolder) .And. ExistDir(cFolder)
			// Tratamento de path caso necessário:
			If Subs(cFolder,Len(cFolder),1) <> "\"
				cFolder += "\"
			EndIf
		Else
			cFolder := ""
		EndIf
	EndIf
	
	If At960VlPrg(dDtIni,dDtFim,cCompt, @aRet[2])	//Valida os campos do pergunte
		lCont := .T.
		If !lRhRM
			cCompt	:= At960Cfol(MV_PAR05)
		EndIf
		If nProc == 2
			cPE := "At960EsRt
		Else
			If "3" $ cTpExp
				nHandle := At960RHF("at960", cDirArq, .T., 3)
			
				If nHandle == -1
					lCont := .F.
					cMsg := STR0039 //"Problemas na criacao do arquivo CSV."
					Help(,, "TECA960", cMsg,, 1, 0)				
					Exit
				EndIf
			EndIf		
		EndIf
		

		If  "2" $ cTpExp .and. !ExistBlock(cPE)
			cMsg := STR0040+cPE+STR0041 //"Ponto de Entrada "##" nao compilado."
			Help(,,"TECA960",cMsg , ,1, 0)
			cTpExp := StrTran(cTpExp, "2", )
		EndIf		

		Exit
	ElseIf lJob
		lCont := .F.
		Exit
	EndIf

End	
lCont := lCont .AND. ( "2" $ cTpExp .OR. "1" $ cTpExp .or. "3" $ cTpExp)

If !Empty(cMsg)
	aAdd(aRet[2], cMsg)
EndIf

If lCont .AND. nProc == 2 //Estorno
	If !lRhRM
		lCont := lJob .OR. MsgNoYes(STR0001+;			//"A realizacao do estorno excluira as programacoes de rateio existentes no modulo de Gestao de Pessoal"
					 STR0002+CHR(13)+CHR(10)+STR0003)	//" para os atendentes na competencia informada."+##+##+"Deseja continuar com a operacao?"
	Else
		lCont := lJob .OR. MsgNoYes(STR0043+; 			//"A realizacao do estorno excluira as programacoes de rateio existentes no modulo de Gestao de Pessoal do sistema RM"
							CHR(13)+CHR(10)+STR0003)	//"Deseja continuar com a operacao?"
	EndIf
EndIf

// Valida o tipo do parametro de atendentes
If ValType(aAtendentes) == "C" .AND. !Empty(aAtendentes)
	aTemp := {}
	aAdd(aTemp,aAtendentes)
	aAtendentes := aClone(aTemp)
EndIf

aRet[1] := lCont

If lCont		

	aCentCusto := {}
	lTrocaCC   := at960TRCC()

	If !lJob
		oProcess := MSNewProcess():New( { | lEnd | lOk := A960ProgRt( @lEnd,cCliDe,cCliAt,dDtIni,dDtFim,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle, aAtendentes,lRateiaCtr) }, STR0036, IIf(nProc==1,STR0037,STR0038), .F. )	//"Aguarde, gerando Programacao de rateio...",("Enviando","Excluindo") 
		oProcess:Activate()
	Else
		lOk := A960ProgRt( .f.,cCliDe,cCliAt,dDtIni,dDtFim,cCompt,nSobrR,nProc,nGerLg,NIL, cTpExp, nHandle, aAtendentes,lRateiaCtr)
	EndIf

EndIf

If lOk
	If nProc == 1  //Processamento Envio
		At960GrLg(,,,,,,,.T.)
		
		If nEnv == 0 .And. nNEnv == 0
			cMsg := STR0005
			Aviso(STR0004,cMsg,{STR0006},2)		//"Atencao","Nao ha registros para envio da programacao de rateio.",{"OK"}
		Else
			cMsg := STR0008+cValToChar(nEnv)+CRLF;    //"Envio da Programacao de Rateio","Programacoes enviadas: " 
					+STR0009+cValToChar(nNEnv)+CRLF;									//"Programacoes nao enviadas: "
					+STR0010+TxLogPath("ProgRateio")  //"Foi gerado o log no arquivo "{"OK"} (SERVIDOR)
			If !Empty(cFolder)
				cMsg += CRLF+STR0010+cFolder		  //"Foi gerado o log no arquivo "{"OK"} (PATH LOCAL ESCOLHIDO NO PERGUNTE)
			EndIf
			Aviso(STR0007,cMsg,{STR0006},2)						
		EndIf
		
		aAdd(aRet[2], cMsg)
	Else	////Processamento Estorno
		If nNEnv > 0
			cMsg := STR0011+CRLF;					 //"Atencao","Programacoes excluidas com sucesso"
					+STR0010+TxLogPath("ProgRateio") //"Foi gerado o log no arquivo "{"OK"} (SERVIDOR)
			If !Empty(cFolder)
				cMsg += CRLF+STR0010+cFolder 		 //"Foi gerado o log no arquivo "{"OK"} (PATH LOCAL ESCOLHIDO NO PERGUNTE)
			EndIf
			Aviso(STR0004,cMsg,{STR0006},2)						
			nNEnv := 0
			aAdd(aRet[2], cMsg)
		Else
			cMsg := STR0005
			Aviso(STR0004,cMsg,{STR0006},2)		//"Atencao","Nao ha registros para envio da programacao de rateio.",{"OK"}
		EndIf	
	EndIf
EndIf

aRet[1] := aRet[1] .AND. lOK

If nHandle > 0
	fClose(nHandle)
EndIf
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} A960ProgRt
	Consulta as alocacoes

@sample 	A960ProgRt() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function A960ProgRt(lEnd,cCliDe,cCliAt,dDtIni,dDtFim,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle, aAtendentes, lRateiaCtr)

Local aAtend    := {}
Local aTot      := {}
Local aTotal    := {}
Local cAliasA   := GetNextAlias()
Local cAtend    := ""
Local cAtendOld := ""
Local cCC       := ""
Local cFunc     := ""
Local cLoc      := ""
Local cQuery    := ""
Local lCab      := .T.
Local lContabil := TecEntCtb("ABS")
Local lIntRH    := SuperGetMv("MV_GSXINT",,"2") == "2"
Local lMultiFil := TecMultRat()
Local lMVGerOS  := SuperGetMV("MV_GSGEROS",.F.,"1") == "1"
Local nAux      := 0
Local nHoraAux  := 0
Local nPos      := 0
Local nQtdProc  := 0
Local nTotLc    := 0
Local nX        := 0

Default aAtendentes := {}
Default cTpExp      := "1"
Default lRateiaCtr  := .F.
Default nHandle     := 0
Default oProcess    := Nil

cQuery := At960qry(lRateiaCtr, lMVGerOS, lContabil, lMultiFil, lIntRH, aAtendentes, cCliDe, cCliAt, dDtIni, dDtFim)

MPSysOpenQuery(cQuery, cAliasA)

(cAliasA)->(dbGoTop())
While !(cAliasA)->(EOF())
	// Desconsidera Agendas de FOLGA TRABALHADA:
	If (cAliasA)->TCU_ALOCEF <> '2'
		If !lMVGerOS
			nHoraAux := Round(HoraToInt(SubStr((cAliasA)->TOTAL,6,10)),2)
		Else
			nHoraAux := (cAliasA)->TOTAL
		EndIf
		If (nAux := ASCAN(aTotal, {|a| a[1] == (cAliasA)->ABB_CODTEC .AND.;
													a[2] == (cAliasA)->CNB_CC .AND.;
													a[3] == (cAliasA)->AA1_CDFUNC .AND.;
													a[4] == (cAliasA)->ABB_LOCAL .AND.;
													a[5] == (cAliasA)->AA1_FUNFIL})) == 0
			AADD(aTotal, {(cAliasA)->ABB_CODTEC,;
						(cAliasA)->CNB_CC,;
						(cAliasA)->AA1_CDFUNC,;
						(cAliasA)->ABB_LOCAL,;
						(cAliasA)->AA1_FUNFIL,;
						nHoraAux,;
						IIF(lContabil, (cAliasA)->CNB_ITEMCT, ""),;
						IIF(lContabil, (cAliasA)->CNB_CLVL, "")})
		ElseIf nAux > 0
			aTotal[nAux][6] += nHoraAux
		EndIf
		
	EndIf
	// Para troca de CC pode ser de agendas FT também:
	If lTrocaCC
		If (cAliasA)->TCU_TRCC == "1" .And. !Empty((cAliasA)->AA1_CDFUNC) // Se Troca de CC e Funcionario SRA:
			// Faz a troca se o centro de custo estiver preenchido.
			If !Empty((cAliasA)->CNB_CC)
				// Faz a busca se o Funcionario ja esta no array de troca:
				nPos := aScan(aCentCusto,{|x| x[1] == (cAliasA)->AA1_FUNFIL .And. x[2] == (cAliasA)->AA1_CDFUNC})
				If nPos > 0
					// Considera o Ultimo CC que o Funcionario esteve.
					aCentCusto[nPos,3] := (cAliasA)->CNB_CC	 	 // Centro de Custo do Local ABS (A ser trocado na SRA)
					aCentCusto[nPos,4] := (cAliasA)->TDV_DTREF	 // Data de Referencia da Agenda
				Else
					AADD(aCentCusto, {(cAliasA)->AA1_FUNFIL, ;   //Filial do Funcionario
										(cAliasA)->AA1_CDFUNC, ; // Matricula do Funcionario
										(cAliasA)->CNB_CC, ;	 // Centro de Custo do Local ABS (A ser trocado na SRA)
										(cAliasA)->TDV_DTREF ;	 // Data de Referencia da Agenda
									})
				EndIf
			EndIf
		EndIf
	EndIf

	
	(cAliasA)->(DBSkip())
End
(cAliasA)->(dbCloseArea())

If !EMPTY(aTotal)
	nQtdProc := LEN(aTotal)
	If oProcess <> Nil
		oProcess:SetRegua1(nQtdProc)
	EndIf
	
	cAtendOld := aTotal[1][1]
	
	For nX := 1 To LEN(aTotal)
		cAtend  := aTotal[nX][1]
		nTotLc	:= aTotal[nx][6] 
		cLoc 	:= aTotal[nX][4]
		cCC		:= aTotal[nX][2]
		cFunc	:= aTotal[nX][3]
		
		If cAtendOld !=  aTotal[nX][1] .AND. cAtendOld != ""
			A960VldPrR(@aAtend,aTot,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle,  lCab )
			
			 lCab  := .F.
			aAtend := {}
		EndIF
		
		cAtendOld :=  aTotal[nX][1]	
		
		If oProcess <> Nil
			oProcess:IncRegua2(STR0012 +  aTotal[nX][1] + STR0013 )			//"Aguarde... Processando o rateio do "#'...'
		EndIf
		
		nPos := aScan(aAtend,{|x| x[1] ==  aTotal[nX][1].AND. x[4] ==  aTotal[nX][2] })
		If nPos > 0 //Se encontrar o mesmo atendente com o mesmo centro de custo, soma os valores
			aAtend[nPos][2] += nTotLc			
		Else		
			aAdd(aAtend,{cAtend,nTotLc,cLoc,cCC,cFunc, aTotal[nX][5], aTotal[nX][7], aTotal[nX][8]})
		EndIf
		
		nPos := aScan(aTot,{|x| x[1] ==  aTotal[nX][1] })
		If nPos > 0
			aTot[nPos][2] += nTotLc
		Else
			aAdd(aTot,{cAtend,nTotLc})//controle do total do atendente
		EndIf
								
	Next nX
	
	//Processa o ultimo atendente
	A960VldPrR(@aAtend,aTot,cCompt,nSobrR,nProc,nGerLg,oProcess, cTpExp, nHandle,  lCab )
	lCab := .f.
	aAtend := {}
		
EndIf

Return .T.

/*/{Protheus.doc} At960qry
Realiza a chamada da funcionade de replica para data na aba de multiplas alocacoes

@author		Diego Bezerra
@since		17/08/2021
@param lRateiaCtr, logico, indica se ira ou nao (.T. ou .F.) realizar rateio POR POSTO DE TRABALHO. Valor obtido do pergunte (SX1) MV_PAR09 do TECA960
@param lMVGerOS, logico, indica se o atendimento das agendas se deu com a geracao de ordens de servico  ou nao (.T. ou .F). Valor obtido do parametro MV_GSGEROS
@param lContabil, logico
@param lMultiFil, logico, .T. = Modo multifilial ativo - .F. = Modo multifilial desativado
@param lIntRH, logico, .T. = 
@param cWhereAtt, caractere
@param cCliDe, caractere, opcao do pergunte (SX1) cliente de?. Obtido do parametro MV_PAR01
@param cCliAt, caractere, opcao do pergunte (SX1) cliente ate?. Obtido do parametro MV_PAR02
@param dDtIni, data, opcao obtida do pergunte (SX1) data de?. Obtido do parametro MV_PAR03
@param dDtFim, data, opcao obtida do pergunte (SX1) data ate?. Obtido do parametro MV_PAR04

/*/
//------------------------------------------------------------------------------
Function At960qry(lRateiaCtr, lMVGerOS, lContabil, lMultiFil, lIntRH, aAtendentes, cCliDe, cCliAt, dDtIni, dDtFim)

	Local cQuery := ""
	Local oQry   := Nil
	Local nOrder := 1
	Local cWhere := TECStrExpBlq("ABB")

	cQuery += "SELECT ABB.ABB_CODTEC, "
	cQuery +=       "AA1.AA1_CDFUNC, "
	cQuery +=       "AA1.AA1_FUNFIL, "
	cQuery +=       "ABB.ABB_LOCAL, "
	cQuery +=       "COALESCE(CNB.CNB_CC,ABS_CCUSTO) CNB_CC, "
	If lTrocaCC
		cQuery +=   "TCU.TCU_TRCC, "
	EndIf
	cQuery +=       "TCU.TCU_ALOCEF, "
	cQuery +=       "TDV.TDV_DTREF, "
	If lMVGerOS
		cQuery += "ABA_QUANT AS TOTAL " 
	Else
		cQuery += "ABB_HRTOT AS TOTAL " 
	EndIf
	If lContabil
		cQuery += ", COALESCE(CNB.CNB_ITEMCT,ABS_ITEM) CNB_ITEMCT, COALESCE(CNB.CNB_CLVL,ABS_CLVL) CNB_CLVL "
	EndIf
	cQuery += "FROM ? ABB "

	// Tipos de Alocacao
	cQuery += "INNER JOIN ? TCU "
	cQuery += " ON "
	If lMultiFil
		cQuery += " ? "
	Else
		cQuery += " TCU.TCU_FILIAL = ? "
	EndIf
	cQuery +=     " AND TCU.TCU_COD = ABB.ABB_TIPOMV "
	cQuery +=     " AND TCU.D_E_L_E_T_ = ' ' "

	// Atendentes
	cQuery += "INNER JOIN ? AA1 "
	cQuery +=         "ON AA1.AA1_CODTEC = ABB.ABB_CODTEC "
	
	If lMultiFil
		cQuery += " AND ? "
	Else
		cQuery += " AND AA1.AA1_FILIAL = ? "
	EndIf
	cQuery +=     " AND AA1.D_E_L_E_T_ = ' ' "

	// Data de Referencia da Agenda
	cQuery += " INNER JOIN ? TDV "
	If !lMultiFil
        cQuery += " ON TDV.TDV_FILIAL = ? "
    Else
        cQuery += " ON ? "
    EndIf
	cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
    cQuery += " AND TDV.TDV_DTREF BETWEEN ? AND ? "
    cQuery += " AND TDV.D_E_L_E_T_ = ' ' "

	// Cfg Agendas
	cQuery += "INNER JOIN ? ABQ "
	cQuery +=         "ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM "
	
	If lMultiFil
		cQuery += " AND ? "
	Else
		cQuery += " AND ABQ.ABQ_FILIAL = ? "
	EndIf
	cQuery +=     "AND ABQ.D_E_L_E_T_ = ' ' "

	// Posto
	cQuery += "INNER JOIN ? TFF "
	cQuery +=         "ON TFF.TFF_FILIAL = ABQ.ABQ_FILTFF "
	cQuery +=         "AND TFF.TFF_COD = ABQ.ABQ_CODTFF "
	cQuery +=     "AND TFF.D_E_L_E_T_ = ' ' "

	// Local de atendimento do contrato
	cQuery += "INNER JOIN ? TFL "
	If !lMultiFil
        cQuery += " ON TFL.TFL_FILIAL = ? "
    Else
        cQuery += " ON ? "
    EndIf
	cQuery +=         "AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
	cQuery +=     "AND TFL.D_E_L_E_T_ = ' ' "

	// Itens Planilhas dos Contratos
	cQuery += "LEFT JOIN ? CNB "
	If !lMultiFil
        cQuery += " ON CNB.CNB_FILIAL = ? "
    Else
        cQuery += " ON ? "
    EndIf
	cQuery += " AND CNB.CNB_CONTRA = TFF.TFF_CONTRT "
	cQuery += " AND CNB.CNB_REVISA = TFF.TFF_CONREV "
	cQuery += " AND CNB.CNB_NUMERO = TFL.TFL_PLAN "
	cQuery += " AND CNB.CNB_ITEM= TFF.TFF_ITCNB "
	cQuery += " AND CNB.D_E_L_E_T_ = ' ' "

	// Local de Atendimento
	cQuery += "INNER JOIN ? ABS "
	cQuery +=         "ON ABS.ABS_LOCAL = ABB.ABB_LOCAL "
	
	If lMultiFil
		cQuery += " AND ? "
	Else
		cQuery += " AND ABS.ABS_FILIAL = ? "
	EndIf
	cQuery +=     " AND ABS.D_E_L_E_T_ = ' ' "

	If lIntRH
		// Funcionarios
		cQuery += " INNER JOIN ? SRA "
		cQuery += " ON (SRA.RA_FILIAL = AA1.AA1_FUNFIL AND SRA.RA_MAT = AA1.AA1_CDFUNC AND SRA.D_E_L_E_T_ = ' ' ) "
	EndIf

	If lMVGerOS
		// Apontamento Atendimento OS
		cQuery += " INNER JOIN ? AB9 "
		cQuery +=         " ON AB9.AB9_NUMOS = ABB.ABB_CHAVE "

		If lMultiFil
			cQuery += " AND ? "
		Else
			cQuery += " AND AB9.AB9_FILIAL = ? "
		EndIf
		cQuery +=     " AND AB9.AB9_CODTEC = ABB.ABB_CODTEC "
		cQuery +=     " AND AB9.AB9_ATAUT = ABB.ABB_CODIGO "
		cQuery +=     " AND AB9.D_E_L_E_T_ = ' ' "
		// Itens Apontamento Atendimento OS
		cQuery += " INNER JOIN ? ABA "
		cQuery +=         " ON ABA.ABA_NUMOS = AB9.AB9_NUMOS "
		If lMultiFil
			cQuery += " AND ? "
		Else
			cQuery += " AND ABA.ABA_FILIAL = ? " 
		EndIf
		cQuery +=     " AND ABA.ABA_CODTEC = AB9.AB9_CODTEC "
		cQuery +=     " AND ABA.ABA_SEQ = AB9.AB9_SEQ "
		cQuery +=     " AND ABA.ABA_NUMOS = AB9.AB9_NUMOS "
		cQuery +=     " AND ABA.D_E_L_E_T_ = ' ' "
	EndIf

	// Agendas
	cQuery += "WHERE ABB.ABB_CODTEC BETWEEN ? AND ? " 
	If !lMultiFil
		cQuery += " AND ABB.ABB_FILIAL = ? " 
	EndIf
	If Len(aAtendentes) > 0
		cQuery += " AND AA1.AA1_CODTEC IN (?) " 
	EndIf
	If !lMVGerOS
		cQuery += " AND ABB.ABB_CHEGOU = 'S' "
	EndIf
	cQuery += "AND ABB.ABB_ATENDE = '1' "
	cQuery += "AND ABB.ABB_ATIVO = '1' "
	cQuery += "AND ABB.ABB_LOCAL <> ' ' "
	If !Empty(cWhere)
		cQuery += " ? " 
	EndIf
	cQuery += "AND ABB.D_E_L_E_T_ = ' ' "
	
	cQuery += "ORDER BY AA1.AA1_FUNFIL,AA1.AA1_CDFUNC,ABB.ABB_LOCAL,ABB.ABB_DTFIM "
	
	cQuery := ChangeQuery(cQuery)
	oQry := FwPreparedStatement():New(cQuery)

	oQry:SetUnsafe( nOrder++, RetSqlName( "ABB" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TCU" ) )
	If lMultiFil
		oQry:SetUnsafe( nOrder++, FWJoinFilial("ABB" , "TCU" , "ABB", "TCU", .T.) )
	Else
		oQry:SetString( nOrder++, xFilial("TCU") )
	EndIf
	oQry:SetUnsafe( nOrder++, RetSqlName( "AA1" ) )
	If lMultiFil
		oQry:SetUnsafe( nOrder++, FWJoinFilial("AA1" , "ABB" , "AA1", "ABB", .T.))
	Else
		oQry:SetString( nOrder++, xFilial("AA1") )
	EndIf
	oQry:SetUnsafe( nOrder++, RetSqlName( "TDV" ) )
	If !lMultiFil
        oQry:SetString( nOrder++, xFilial("TDV") )
    Else
        oQry:SetUnsafe( nOrder++, FWJoinFilial("TDV" , "ABB" , "TDV", "ABB", .T.) )
    EndIf
	oQry:SetDate( nOrder++, dDtIni )
	oQry:SetDate( nOrder++, dDtFim )
	oQry:SetUnsafe( nOrder++, RetSqlName( "ABQ" ) )
	If lMultiFil
		oQry:SetUnsafe( nOrder++, FWJoinFilial("ABQ" , "ABB" , "ABQ", "ABB", .T.))
	Else
		oQry:SetString( nOrder++, xFilial("ABQ") )
	EndIf
	oQry:SetUnsafe( nOrder++, RetSqlName( "TFF" ) )
	oQry:SetUnsafe( nOrder++, RetSqlName( "TFL" ) )
	If !lMultiFil
        oQry:SetString( nOrder++, xFilial("TFL") )
    Else
        oQry:SetUnsafe( nOrder++, FWJoinFilial("TFL" , "TFF" , "TFL", "TFF", .T.) )
    EndIf
	oQry:SetUnsafe( nOrder++, RetSqlName( "CNB" ) )
	If !lMultiFil
        oQry:SetString( nOrder++, xFilial("CNB") )
    Else
        oQry:SetUnsafe( nOrder++, FWJoinFilial("CNB" , "TFF" , "CNB", "TFF", .T.) )
    EndIf
	oQry:SetUnsafe( nOrder++, RetSqlName( "ABS" ) )
	If lMultiFil
		oQry:SetUnsafe( nOrder++, FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.))
	Else
		oQry:SetString( nOrder++, xFilial("ABS") )
	EndIf
	If lIntRH
		oQry:SetUnsafe( nOrder++, RetSqlName( "SRA" ) )
	EndIf
	If lMVGerOS
		oQry:SetUnsafe( nOrder++, RetSqlName( "AB9" ) )
		If lMultiFil
			oQry:SetUnsafe( nOrder++, FWJoinFilial("ABB" , "AB9" , "ABB", "AB9", .T.))
		Else
			oQry:SetString( nOrder++, xFilial("AB9") )
		EndIf
		oQry:SetUnsafe( nOrder++, RetSqlName( "ABA" ) )
		If lMultiFil
			oQry:SetUnsafe( nOrder++, FWJoinFilial("AB9" , "ABA" , "AB9", "ABA", .T.))
		Else
			oQry:SetString( nOrder++, xFilial("ABA") )
		EndIf
	EndIf
	//where
	oQry:SetString( nOrder++, AllTrim(cCliDe) )
	oQry:SetString( nOrder++, AllTrim(cCliAt) )
	If !lMultiFil
		oQry:SetString( nOrder++, xFilial("ABB") )
	EndIf
	If Len(aAtendentes) > 0
		oQry:SetIn( nOrder++, aAtendentes ) //Remove a ultima virgula
	EndIf
	
	If !Empty(cWhere)
		oQry:SetUnsafe( nOrder++, cWhere )
	EndIf

	cQuery := oQry:GetFixQuery()

Return cQuery


//------------------------------------------------------------------------------
/*/{Protheus.doc} A960VldPrR
	Valida a Programacao de Rateio

@sample 	A960VldPrR() 

@since		25/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function A960VldPrR(aAtend,aTot,cCompt,nSobrR,nProc,nGerLg,oProcess,cTpExp, nHandle, lCab)

Local aRat		:= {}
Local nX		:= 0
Local nZ		:= 0
Local cPerc	:= "99."
Local lAdd		:= .T.

Default cTpExp := "1"
Default nHandle := 0
Default lCab := .F.

For nZ := 1 to (TamSx3("RHQ_PERC")[2])
 cPerc += '9'
Next

If nProc == 1 //Envio

	For nX := 1 to Len(aAtend)
		
		If oProcess <> Nil
			oProcess:SetRegua1(nX)
		EndIf
		
		nPos := aScan(aTot,{|x| x[1] == aAtend[nX][1]})
		If nPos > 0
			nTotal := ((aAtend[nX][2]*100)/aTot[nPos][2])
			If nTotal <> 100
				nPos := aScan(aRat,{|x| x[1] == aAtend[nX][5] .AND. x[2] == aAtend[nX][6] })
				If nPos > 0
					aAdd(aRat[nPos][3],{cCompt,aAtend[nX][4],nTotal,;
			                            aAtend[nX][7],;
										aAtend[nX][8]})
				Else
					aAdd(aRat,{aAtend[nX][5], aAtend[nX][6],{{cCompt,aAtend[nX][4],nTotal,;
					                                          aAtend[nX][7],;
															  aAtend[nX][8]}}})
				EndIf
			Else
				lAdd := .T.
				If ("1" $ cTpExp)
					lAdd := .F.
					DbSelectArea("SRA")
					DbSetOrder(1)//RA_FILIAL + RA_MAT
					If SRA->(DbSeek(aAtend[nX][6]+aAtend[nX][5]))
						lAdd :=  aAtend[nX][4] <> SRA->RA_CC
					EndIf
				Else
					lAdd := .T.
				EndIf
				If lAdd
					aAdd(aRat,{aAtend[nX][5], aAtend[nX][6],{{cCompt,aAtend[nX][4],Val(cPerc),;
															 aAtend[nX][7],;
															 aAtend[nX][8]}}})
				EndIf
			EndIf
		EndIf
	
	Next nX

	A960ProRat(aRat,nSobrR,cCompt,nGerLg,nProc,oProcess,cTpExp, nHandle, lCab)
	
	
ElseIf nProc == 2 //Estorno

	BEGIN TRANSACTION 

		If "1" $ cTpExp
			At960EstRt(aAtend,cCompt,nProc,nGerLg)
		EndIf
		
		If "2" $ cTpExp
			ExecBlock("At960EsRt", .F., .F., {MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05,MV_PAR06, MV_PAR07, MV_PAR08, aAtend, lCab })
		EndIf

	END TRANSACTION

EndIf

aAtend := {}

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} A960ProRat
	Envio da Programacao de Rateio

@sample 	A960ProRat() 

@since		26/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function A960ProRat(aRat,nSobrR,cCompt,nGerLg,nProc,oProcess,cTpExp, nHandle, lCab)

	Local aAutoItens  := {}
	Local aCab        := {}
	Local aCampos     := {}
	Local aEmpFil     := {}
	Local aErro       := {}
	Local aErroPe     := {}
	Local aItens      := {}
	Local aItensT     := {}
	Local aRetPE      := {}
	Local aRMnoProc   := {}
	Local cAuxCC      := ""
	Local cCustoSRA   := ""
	Local cError      := ""
	Local cFilBkp     := cFilAnt
	Local cMsg        := ""
	Local cProgRt     := ""
	Local cXML        := ""
	Local dDataTransf := CtoD("//")
	Local lContabil   := TecEntCtb("ABS")
	Local lErrorRM    := .F.
	Local lErroTroca  := .F.
	Local lExist      := .F.
	Local lRet        := .T.
	Local lRetVl      := .T.
	Local lRh         := SuperGetMv("MV_GSXINT",,"2") == "2"
	Local lRhRM       := SuperGetMv("MV_GSXINT",,"2") == "3"
	Local lSobrEs     := .F.
	Local nAux        := 0
	Local nAuxCC      := 0
	Local nDiff       := 0
	Local nPos        := 0
	Local nT          := 0
	Local nTamPer     := TamSx3("RHQ_PERC")[2]
	Local nW          := 0
	Local nY          := 0
	Local oModel      := Nil //FwLoadModel("GPEA056")
	Local oWS         := nil
	Private lMsErroAuto := .F.

	Default cTpExp := "1"
	Default nHandle := 0
	Default lCab := .F.

	cFilBkp := cFilAnt

	For nY := 1 To Len(aRat)

		If oProcess <> Nil
			oProcess:IncRegua2(STR0012 + aRat[nY][1] + STR0013 ) ////"Aguarde... Processando o rateio do "#'...'
		EndIf

		// Restaura variaveis importantes:
		cError      := ""
		cMsg        := ""
		dDataTransf := CtoD("//")
		lErrorRM    := .F.
		lErroTroca  := .F.
		lMsErroAuto := .F.
		lRet        := .T.
		
		// Faz a troca do CC na SRA: (nao foi possivel fazer o EXECAUTO do GPE dentro da transaction)
		If lTrocaCC
			If Len(aCentCusto) > 0
				// Faz a busca se o Funcionario esta no array de troca:
				nPos := aScan(aCentCusto,{|x| x[1] == aRat[nY][2] .And. x[2] == aRat[nY][1]}) // Filial + Matricula
				If nPos > 0
					cCustoSRA := Posicione("SRA", 1, aCentCusto[nPos,1]+aCentCusto[nPos,2], "RA_CC")
					If cCustoSRA <> aCentCusto[nPos,3] .And. !Empty(aCentCusto[nPos,3])

						If !Empty(aCentCusto[nPos,4])
							aAutoItens := {}
							aCampos    := {}

							// Centro de Custo Destino a ser Alterado na SRA:
							aAdd( aCampos, { "RA_CC", aCentCusto[nPos,3] } ) 
							// Filail e Matricula origem + aCampos a serem alterados:
							aAdd( aAutoItens, { aCentCusto[nPos,1], aCentCusto[nPos,2], aCampos } ) 

							dDataTransf := StoD(aCentCusto[nPos,4])
							dDataTransf := checkDates(dDataTransf, MV_PAR04)

							// Chamada ExecAuto GPE:
							MSExecAuto( {|x,y,z,w| GPEA180(x,y,z,w)}, 6, aAutoItens, dDataTransf, .T. )

							// Se houver erro na ExecAuto:
							If lMsErroAuto
								cMsg	   := STR0048 // "Erro de troca de Centro de Custo na SRA do Funcionario."
								cError     := MostraErro( 'Null' )
								cError     := At960Trim(cError)
								lErroTroca := .T.
								lRet       := .F.
							EndIf
						EndIf
						
					EndIf
				EndIf
			EndIf
		EndIf	

		BEGIN TRANSACTION
					
			If lRet .And. "1" $ cTpExp	
				If !lRhRM
					DbSelectArea("RHQ")
					DbSetOrder(1) //RHQ_FILIAL+RHQ_MAT+RHQ_DEMES
					If RHQ->(DbSeek(aRat[nY][2]+aRat[nY][1]+cCompt))
						cProgRt := aRat[nY][2]+aRat[nY][1]+cCompt
						lExist := .T.
						If nSobrR == 1 //Sim
							lSobrEs := .T.
						ElseIf nSobrR == 2 //nao
							lSobrEs := .F.	
						EndIf
					EndIf
				
					If lSobrEs //Se Sobreescreve sim
						While RHQ->(!EOF()) .AND. cProgRt == RHQ_FILIAL+RHQ_MAT+RHQ_DEMES
							RecLock("RHQ",.F.)
							RHQ->(DbDelete())			//deleta item
							RHQ->(MsUnLock())
							RHQ->(DbSkip())
						End
					Else
						If lExist //Se Existe
							lRet := .F.
							lExist := .F.
						EndIf
					EndIf
				Else
					cError := ""
					aEmpFil := GSItEmpFil(, ,  'RM', .T., .F., @cError)
					If !EMPTY(aEmpFil)
						lExist := .F.
						If oWS == nil
							oWS :=  GSItRMWS('RM', .F., @cError)
							oWS:cDataServerName := "FopRateioFixoData"
						EndIf
						oWS:cFiltro := "PFRATEIOFIXO.Chapa='" + Alltrim(aRat[nY][1]) + "'"
						If oWS:ReadView()
							cXML:= oWS:cReadViewResult
							If !EMPTY(cXML)
								If Empty(cError)
									If AT("PFRATEIOFIXO", UPPER(cXML)) > 0
										lExist := .T.
										If nSobrR == 1
											oWS:cFiltro := ""
											oWS:cXML := oWS:cReadViewResult
											If !(oWS:DeleteRecord())
												AADD(aRMnoProc, aRat[nY][1])
												lRet := .F.
												lErrorRM := .T.
											EndIf
										EndIf
									Else
										lExist := .F.
									EndIf
								Else
									AADD(aRMnoProc, aRat[nY][1])
									lRet := .F.
									lErrorRM := .T.
								EndIf
							Else
								AADD(aRMnoProc, aRat[nY][1])
								lRet := .F.
								lErrorRM := .T.
							EndIf
							cXML := ""
						Else
							AADD(aRMnoProc, aRat[nY][1])
							lRet := .F.
							lErrorRM := .T.
						EndIf
						FreeObj(oWS)
						oWS := NIL
					Else
						lRet := .F.
					EndIf
				EndIf
			EndIf
			
			If lRet
				
				aCab := {}
				aItens := {}
				aErroPE := {}
				If !Empty(aRat[nY][2])
					cFilAnt := aRat[nY][2]
				EndIf
				lRetVl := .T.
				
				aAdd(aCab,{ "RA_MAT", aRat[nY][1] })
				aAdd(aCab, { "RA_FILIAL", aRat[nY][2]})
			
				For nW := 1 To Len(aRat[nY][3])	
					aItensT := {}		
					aAdd( aItensT, {"RHQ_DEMES",aRat[nY][3][nW][1]})//cCompt)
					aAdd( aItensT, {"RHQ_AMES" ,aRat[nY][3][nW][1]})//cCompt)
					

					If Empty(aRat[nY][3][nW][2])
						cCustoSRA:= Posicione("SRA", 1, xFilial("SRA")+aRat[nY][1], "RA_CC")
						aAdd( aItensT, {"RHQ_CC" ,cCustoSRA})//cCentCust)
					Else
						aAdd( aItensT, {"RHQ_CC" ,aRat[nY][3][nW][2]})//cCentCust)
					EndIf


					aAdd( aItensT, {"RHQ_PERC" ,aRat[nY][3][nW][3]})//nTotal)	
					If lContabil
						aAdd( aItensT, {"RHQ_ITEM" ,aRat[nY][3][nW][4]})//nTotal)	
						aAdd( aItensT, {"RHQ_CLVL" ,aRat[nY][3][nW][5]})//nTotal)	
					EndIf
					
					aAdd(aItens, aClone(aItensT))
				Next nW

				If lRhRM
					For nW := 1 To LEN(aItens)
						aItens[nW][4][2] := ROUND(aItens[nW][4][2],2)
						nAuxCC += aItens[nW][4][2]
					Next nW
					If nAuxCC != 100
						nDiff := ABS(nAuxCC - 100)
						nAux := 1
						While nDiff != 0
							If nAuxCC < 100
								aItens[nAux][4][2] += 0.01
							Else
								aItens[nAux][4][2] -= 0.01
							EndIf
							nAux++
							If nAux > LEN(aItens)
								nAux := 1
							EndIf
							nDiff -= 0.01
						End
					EndIf
				EndIf

				If lRh
					For nW := 1 To LEN(aItens)
						aItens[nW][4][2] := ROUND(aItens[nW][4][2],nTamPer)
						nAuxCC += aItens[nW][4][2]
					Next nW
					If nAuxCC != 100
						nDiff := ABS(nAuxCC - 100)
						nAux := 1
						While nDiff != 0 .And. nAux <= Len(aItens)
							If nAuxCC < 100
								aItens[nAux][4][2] += 10 ^ ( - nTamPer )
							EndIf
							nAux++
							nDiff -= 10 ^ ( - nTamPer )
						End
					EndIf
				EndIf

				If "1" $ cTpExp	
					If !lRhRM
						DbSelectArea("SRA")
						SRA->(DbSetOrder(1)) //RA_FILIAL + RA_MAT
						SRA->(DbSeek(aRat[nY][2]+aRat[nY][1]))
			
						Inclui := .F.
						Altera := .T.

						oModel := FwLoadModel("GPEA056")
				
						oModel:SetOperation(MODEL_OPERATION_UPDATE)
						oModel:Activate()

						//realiza o filtro da competencia
						FiltraGrid(oModel, cCompt )

						If oModel:GetModel( "RHQDETAIL" ):Length() > 1 .OR. !Empty(oModel:GetValue("RHQDETAIL", "RHQ_DEMES"))
							oModel:GetModel("RHQDETAIL"):AddLine()
						EndIf
					
						For nW := 1 To Len(aItens)
							If nW > 1
								If oModel:GetModel("RHQDETAIL"):AddLine() <> nW
									lRetVl := .F.
									Exit
								EndIf
							EndIf			
							For nT := 1 to Len(aItens[nT])
								oModel:SetValue("RHQDETAIL", aItens[nW][nT][01], aItens[nW][nT][02])//cCompt)
							Next nT	
						Next nW
						
						If ( lRetVl := oModel:VldData() ) //Validacao dos dados
							
							// Se o dados foram validados faz-se a gravacao efetiva dos
							// dados (commit)
							oModel:CommitData()
							
							aErro := {}
						EndIf
					
						If !lRetVl
							aErro := oModel:GetErrorMessage()
						EndIf
					
						oModel:DeActivate()
						
						lRet := lRetVl
					Else
						If ((lExist .AND. nSobrR == 1) .OR. !lExist) .AND. !EMPTY(aItens)
							If !lErrorRM
								cXml := "<FopRateioFixo>"
								For nW := 1 to LEN(aItens)
									cXml += "<PFRATEIOFIXO>"
										cXml += "<CODCOLIGADA>" + aEmpFil[1] + "</CODCOLIGADA>"
										cXml += "<CHAPA>" + ALLTRIM(aCab[ASCAN(aCab, {|a| a[1] == "RA_MAT"})][2]) + "</CHAPA>"
										cXml += "<CODCCUSTO>"
										cAuxCC := Alltrim(GSItCC(,,'RM', aItens[nW][ASCAN(aItens[nW], {|a| a[1] == "RHQ_CC"})][2], .F., @cError))
										If rAT("|", cAuxCC) > 0
											cAuxCC := SUBSTR(cAuxCC, RAT("|",cAuxCC)+1 )
										EndIf
										cXml += (cAuxCC+"</CODCCUSTO>")
										cXml += "<VALOR>" + STRTRAN(cValToChar(aItens[nW][ASCAN(aItens[nW], {|a| a[1] == "RHQ_PERC"})][2]),".",",") + "</VALOR>"
										cXml += "<Descricao>" + Alltrim(POSICIONE("CTT",1,xFilial("CTT") + aItens[nW][ASCAN(aItens[nW], {|a| a[1] == "RHQ_CC"})][2], "CTT_DESC01")) + "</Descricao>"
									cXml += "</PFRATEIOFIXO>"
								Next nW
								cXml += "</FopRateioFixo>"
								oWS :=  GSItRMWS('RM', .F., @cError)
								If EMPTY(cError) .AND. VALTYPE(oWS) == 'O' 
									oWS:cDataServerName := "FopRateioFixoData"
									oWS:cXML := cXml
									If !(oWS:SaveRecord())
										AADD(aRMnoProc, ALLTRIM(aCab[ASCAN(aCab, {|a| a[1] == "RA_MAT"})][2]))
										lErrorRM := .T.
									ElseIf AT(REPLICATE("=",4), oWS:cSaveRecordResult ) > 0
										AADD(aRMnoProc, ALLTRIM(aCab[ASCAN(aCab, {|a| a[1] == "RA_MAT"})][2]))
										cError := STRTRAN(LEFT(oWS:cSaveRecordResult, AT(REPLICATE("=",4), oWS:cSaveRecordResult )-1), CRLF)
										lErrorRM := .T.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				
				If "2" $ cTpExp
					aRetPE := ExecBlock("At960PrRt", .F., .f., {aCab,aItens,3,lCab , @aErroPE}) 
					If ValType(aRetPE) = "A" .AND. Len(aRetPE) >= 1 .AND. !aRetPE[1] 
						lRet := .F.
						If Len(aErro) = 0
							aErro := Array(9)
							aFill(aErro, "")
							aErro[1] := "GPEA056"
						EndIf
						If ValType(aRetPE[2])== "C"
							aErro[6] += IIF( !Empty(aErro[6]),  CRLF, "") + aRetPE[2]
						EndIf
					EndIf
				EndIf
			
				If "3" $ cTpExp
					lRet := At960MCSV(aCab, aItens, nHandle, lCab) .AND. lRet
				EndIf
			
			Else
				If lErroTroca .And. !Empty(cError)
					aErro := Array(9)
					aFill(aErro, "")
					aErro[1] := "GPEA180"
					aErro[6] := cError
				Else
					If EMPTY(cError)
						cError := STR0042//"Erro ao processar Integracao RH Protheus."
					EndIf
					aErro := Array(9)
					aFill(aErro, "")
					aErro[1] := "GPEA056"
					aErro[6] := {cError}
				EndIf
			EndIf
			
			If lRet .AND. lErrorRM
				If EMPTY(cError)
					cError := STR0042//"Erro ao processar Integracao RH Protheus."
				EndIf
				aErro := Array(9)
				aFill(aErro, "")
				aErro[1] := "GPEA056"
				aErro[6] := {cError}
			EndIf

			If Empty(cMsg)
				If lRet
					cMsg := STR0014 // "Programacao de Rateio Enviada com sucesso"
				Else
					cMsg := STR0015 // "Erro no envio da Programacao de Rateio"
				EndIf
			EndIf
			
			At960GrLg(aErro,aRat[nY][2],aRat[nY][1],cMsg,nGerLg,cCompt,nProc,.F.,aRMnoProc,aItens) 
			
			If !lRet
				DisarmTransaction()
			EndIf	

		END TRANSACTION

	Next nY

	If cFilBkp <> cFilAnt
		cFilAnt := cFilBkp
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960EstRt
	Estorno da Programacao de Rateio

@sample 	At960EstRt() 

@since		26/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At960EstRt(aAtend,cCompt,nProc,nGerLg,oProcess)

Local nX := 0
Local aErro := {}
Local oModel	:= FwLoadModel("GPEA056")
Local lOk 	:= .T.
Local lRhRM := SuperGetMv("MV_GSXINT",,"2") == "3"
Local oWS := nil
Local cError := ""
Local aProcs := {}
Local cFilBkp := ""

DbSelectArea("RHQ")
DbSelectArea("SRA")

cFilBkp := cFilAnt

For nX := 1 To Len(aAtend)
	
	cError := ""
	
	If oProcess <> Nil
		oProcess:IncRegua2(STR0016 + aAtend[nX][5] + STR0013 )		//"Aguarde... Excluindo a Programacao de rateio do "#'...'
	EndIf

	RHQ->( DbSetOrder(1) ) //RHQ_FILIAL+RHQ_MAT+RHQ_DEMES
	SRA->( DbSetOrder(1) ) // RA_FILIAL + RA_MAT
	
	Inclui := .F.
	Altera := .F.
	If !lRhRM

        cFilAnt := aAtend[nX][6]

		If SRA->(DbSeek(aAtend[nX][6]+aAtend[nX][5]))  .And. ;
			RHQ->(DbSeek(cFilAnt+aAtend[nX][5]+cCompt))
			
			cAtend := aAtend[nX][6]+aAtend[nX][5]+cCompt
			nNEnv++
			aErro := {}
			
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			lOk := oModel:Activate()
			
			If lOk 
				lOk := oModel:VldData() .And. oModel:CommitData()
				
				If !lOk 
					aErro := oModel:GetErrorMessage()
				EndIf
				
				At960GrLg(aErro,aAtend[nX][6],aAtend[nX][5],STR0017,nGerLg,cCompt,nProc,.F.)		//"Programacao de Rateio Excluida com sucesso"
				
				oModel:DeActivate()	
			EndIf
		EndIf
	Else
		aErro := {}
		
		If ASCAN(aProcs, Alltrim(aAtend[nX][5])) == 0
			If oWS == nil
				oWS :=  GSItRMWS('RM', .F., @cError)
				oWS:cDataServerName := "FopRateioFixoData"
			EndIf
			oWS:cFiltro := "PFRATEIOFIXO.Chapa='" + Alltrim(aAtend[nX][5]) + "'"
			If oWS:ReadView()
				oWS:cFiltro := ""
				If AT("PFRATEIOFIXO", UPPER(oWS:cReadViewResult)) > 0
					oWS:cXML := oWS:cReadViewResult
					If oWS:DeleteRecord()
						nNEnv++
					Else
						cError := STR0045 + Alltrim(aAtend[nX][5]) //"Erro ao executar o metodo 'DeleteRecord' para o atendente de Matricula " 
					EndIf
				EndIf
				FreeObj(oWS)
				oWS := NIL
			Else
				cError := STR0044 + Alltrim(aAtend[nX][5]) //"Erro ao executar o metodo 'ReadView' para o atendente de Matricula " 
			EndIf
			AADD(aProcs, Alltrim(aAtend[nX][5]))
			If !EMPTY(cError)
				aErro := Array(9)
				aFill(aErro, "")
				aErro[1] := "GPEA056"
				aErro[6] := {cError}
			EndIf
			At960GrLg(aErro,aAtend[nX][6],aAtend[nX][5],STR0017,nGerLg,cCompt,nProc,.F.)		//"Programacao de Rateio Excluida com sucesso"
		EndIf
	EndIf

Next nX

cFilant := cFilBkp
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960Cfol
	Realiza a conversao da competencia na folha

@sample 	At960Cfol() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At960Cfol(cCompFolh)

Local cAno		:= ""
Local cMes		:= ""
Local cRet		:= ""

cAno := SubStr(cCompFolh,4,7)
cMes := SubStr(cCompFolh,1,2)

cRet := cMes+cAno

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960VlPrg
	Validacao dos perguntes

@sample 	At960VlPrg() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At960VlPrg(dDtIni,dDtFim,cCompt, aErro)

	Local cMsg := ""
	Local lRet := .T.

	If Empty(dDtIni)
		cMsg += (CRLF + STR0019)		//"Preencha a data inicial"
		lRet := .F.
	EndIf

	If Empty(dDtFim)
		cMsg += (CRLF + STR0020)			//"Preencha a data final"
		lRet := .F.
	EndIf

	If Alltrim(cCompt) == "/" 
		cMsg += (CRLF + STR0021)		//"Preencha o campo competencia"
		lRet := .F.
	EndIf

	If !lRet
		cMsg := Substr(cMsg, Len(CRLF))
		Help("", 1, "At960VlPrg",, cMsg,  1, 0)
		aAdd(aErro, cMsg)
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At960GrLg
	geracao dos Logs

@sample 	At960GrLg() 

@since		24/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function At960GrLg(aErro,cFilFun, cCodFunc,cMsg,nGerLg,cCompt,nProc,lFim, aRMnoProc,aItens)

	Local cTexto	:= ""		
	Local cNome		:= ""
	Local nX		:= 0
	Local nT		:= 0

	Default aErro 		:= {}
	Default cCodFunc	:= ""
	Default aRMnoProc 	:= {}
	Default aItens		:= {}

	If !Empty(cCodFunc)
		cNome	:= Alltrim(Posicione("SRA",1,cFilFun+cCodFunc,"SRA->RA_NOME"))
	EndIf

	If !lFim
		
		cTexto := STR0022+cFilFun+"/"+cCodFunc+STR0023+cNome+" "+STR0035+cCompt+CRLF		//"Funcionario: "##" - "##"competencia: "##
		
		If nProc == 1		////Processamento Envio
		
			If Len(aErro) > 0
				nNEnv++
				cTexto +=	" "+CRLF+cMsg+CRLF;
							+" "+CRLF+STR0024+'['+ AllToChar( aErro[1] )+']'+CRLF;	//"Id do formulario de origem:"
							+" "+STR0025+'['+ AllToChar( aErro[2] ) +']'+CRLF;		//"Id do campo de origem: "
							+" "+STR0026+'['+ AllToChar( aErro[3] ) +']'+CRLF;		//"Id do formulario de erro: "
							+" "+STR0027+'['+ AllToChar( aErro[4] ) +']'+CRLF;		//"Id do campo de erro: "
							+" "+STR0028+'['+ AllToChar( aErro[5] ) +']'+CRLF;		//"Id do erro: "
							+" "+STR0029+'['+ AllToChar( aErro[6] ) +']'+CRLF;		//"Mensagem do erro: "
							+" "+STR0030+'['+ AllToChar( aErro[7] ) +']'+CRLF;		//"Mensagem da solucao: "
							+" "+STR0031+'['+ AllToChar( aErro[8] ) +']'+CRLF;		//"Valor atribuido: "
							+" "+STR0032+'['+ AllToChar( aErro[9] ) +']'+CRLF;		//"Valor anterior: "
							+CRLF+"---------------------------------------------------"+CRLF+CRLF
				For nX := 1 To Len(aItens)	
					cTexto += "---------------------------------------------------"+CRLF+CRLF		
					For nT := 1 to Len(aItens[nX])
						If Alltrim(aItens[nX][nT][01]) == "RHQ_CC" .And. Empty(AllToChar( aItens[nX][nT][02] ))
							cTexto += aItens[nX][nT][01] +'['+ AllToChar( aItens[nX][nT][02] )+']' +" - "+ STR0047 + CRLF //"Verifique o centro de custo no local de atendimento"
						Else
							cTexto += aItens[nX][nT][01] +'['+ AllToChar( aItens[nX][nT][02] )+']'+CRLF
						EndIf	
					Next nT	
					cTexto += +CRLF+"---------------------------------------------------"+CRLF+CRLF
				Next nX 				
			Else
			
				nEnv++
				If nGerLg == 1
					cTexto +=	" "+CRLF+cMsg+CRLF;
								+CRLF+"---------------------------------------------------"+CRLF+CRLF
				EndIf
				
			EndIf
			
		Else	//Processamento Estorno
			
			cTexto +=	" "+CRLF+cMsg+CRLF;
			+CRLF+"---------------------------------------------------"+CRLF+CRLF
		
		EndIf

	Else
		cTexto :=	STR0033+cValToChar(nEnv)+CRLF;			//"Enviadas: "
					+STR0034+cValToChar(nNEnv)+CRLF;		//"nao Enviadas: "
					+CRLF+"---------------------------------------------------"+CRLF+CRLF	
	EndIf	
	
	If !EMPTY(aRMnoProc)
		cTexto += CRLF+"---------------------------------------------------"
		cTexto += STR0046 + CRLF + CRLF //"As seguintes Matriculas nao foram processadas: " 
		For nX := 1 TO LEN(aRMnoProc)
			cTexto += aRMnoProc[nX] + CRLF
		Next nX
	EndIf
	
	TxLogFile("ProgRateio",cTexto)

	If !Empty(cFolder)
		// Cria o mesmo Log na pasta selecionada no pergunte:
		TxLogFile("ProgRateio",cTexto,.T.,.T.,.T.,cFolder)
	EndIf

Return


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960MCSV
@description Gera o Arquivo CSV das Marcacoes
@param aCabec: Array Contendo a filial e matricula do atendente
@param aItens:Array de Marcacoes do atendende do Atendimento que sera atualizado
@param nHandle:Handle do Arquivo
@param lCab:Gera o cabecalho da marcacao
@return aRetInc: Array de Retorno da Inclusao onde 
		aRetInc[1]  - .t. //sUCESSO
		aRetInc[2]  - Array contendo a mensagem de sucesso/ erro
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960MCSV(aCabec, aItens, nHandle, lCab)
Local cCab 		:= ""
Local cDetCab 	:= ""
Local cLinha 	:= ""
Local cDetLinha := ""
Local nC 		:= 0
Local nY 		:= 0

For nC := 1 to len(aCabec)
	cCab += AllTrim(aCabec[nC, 01]) +";"
	cDetCab += Alltrim(IIF( ValType(aCabec[nC, 02])<> "D",cValToChar(aCabec[nC, 02])  , DtoS(aCabec[nC, 02])))+";"
Next nC 

For nC := 1 to Len(aItens)

	cLinha := cCab
	cDetLinha := cDetCab 
	For nY := 1 to Len(aItens[nC])
		cLinha += AllTrim(aItens[nC, nY, 01])+";"
		cDetLinha +=  Alltrim(IIF( ValType(aItens[nC, nY, 02])<> "D",cValToChar(aItens[nC, nY, 02])  , DtoS(aItens[nC, nY, 02])))+";"	
	Next nY
	If lCab	
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF		
		fWrite(nHandle, cLinha)
		lCab := .f.
	EndIf
	
	cDetLinha := Substr(cDetLinha, 1, Len(cDetLinha)-1) + CRLF
	fWrite(nHandle, cDetLinha)
Next nC

Return .T.

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960RHD
@description  Retorna o Diretorio de Exportacao do Arquivo CSV da Integracao RH
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@return cDirArq - Diretorio do server a ser gerado o arquivo
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960RHD()
Local cDirArq := SuperGetMV("MV_GSRHDIR", .F., "")

If !Empty(cDirArq) .AND. Right(cDirArq, 1) <> "\"
	cDirArq += "\"
EndIf

If !Empty(cDirArq) .AND. Left(cDirArq, 1) <> "\"
	cDirArq := "\" +cDirArq
EndIf

Return cDirArq
//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960RHF
@description Gera o Arquivo CSV das Marcacoes
@author 		fabiana.silva
@since 			03.05.2019
@version 		12.1.25
@param cRotina: Prefixo da rotina/aquivo
@param cDirArq:Diretorio de gravacao do arquivo
@param lDelete: Exclui arquivo caso ele exista?
@param nOpc: Opcao da Rotina Automatica 
@return nHandle - Handle do Arquivo Gerado
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960RHF(cRotina, cDirArq, lDelete, nOpc)
Local nHandle 	:= 0
Local aDir 		:= {}
Local nC 		:= 0
Local cDirTmp 	:= ""


If !ExistDir(cDirArq)
	aDir := StrTokArr(cDirArq, "\")
	For nC := 1 to Len(aDir)
		cDirTmp += "\" +aDir[nC] +"\"
		MakeDir(cDirTmp)
	Next nC 
EndIf
	
cNomeArq := cDirArq+cRotina+"_"+LTrim(Str(nOpc))+"_"+Dtos(Date())+"_"+StrTran(Time(), ":")+".csv" 

If File(cNomeArq)
	If lDelete
		fErase(cNomeArq)
	Else
		nHandle := FOpen(cNomeArq, FO_READWRITE)
		FSeek(nHandle, 0, 2)
	EndIf
EndIf
If nHandle = 0
	nHandle := fCreate(cNomeArq)
EndIf

Return nHandle

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960RHD
@description  Realiza o filtro do grid da RHQ para manter o comportamento da rotina padrao e melhorar a performance
assim nao validando periodos anteriores
@author 		Luiz Gabriel
@since 			20/02/2023
@version 		12.1.2210
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function FiltraGrid(oModel, cCompt)
	
	Local cFiltro := ""
	Local cIni    := Right(cCompt, 4) + Left(cCompt, 2) 
	Local cFim    := Right(cCompt, 4) + Left(cCompt, 2)
	Local oQry    := Nil
	Local nOrder  := 1

	cFiltro := "SELECT * FROM ? "
	cFiltro += "WHERE ( ( SUBSTRING(RHQ_DEMES, 3, 4) "
	cFiltro +=           "|| SUBSTRING(RHQ_DEMES, 1, 2) >= ? "
	cFiltro +=           "AND SUBSTRING(RHQ_DEMES, 3, 4) "
	cFiltro +=               "|| SUBSTRING(RHQ_DEMES, 1, 2) <= ?) "
	cFiltro +=         "OR ( SUBSTRING(RHQ_AMES, 3, 4) "
	cFiltro +=              "|| SUBSTRING(RHQ_AMES, 1, 2) >= ? "
	cFiltro +=              "AND SUBSTRING(RHQ_AMES, 3, 4) "
	cFiltro +=                  "|| SUBSTRING(RHQ_AMES, 1, 2) <= ?) "
	cFiltro +=         "OR ( SUBSTRING(RHQ_DEMES, 3, 4) "
	cFiltro +=              "|| SUBSTRING(RHQ_DEMES, 1, 2) <= ? "
	cFiltro +=              "AND SUBSTRING(RHQ_AMES, 3,4) "
	cFiltro +=                  "|| SUBSTRING(RHQ_AMES, 1,2) >= ?) "
	cFiltro +=         "OR ( SUBSTRING(RHQ_DEMES, 3, 4) "
	cFiltro +=              "|| SUBSTRING(RHQ_DEMES, 1, 2) <= ? "
	cFiltro +=              "AND RHQ_AMES = '      ')) "
		
	cFiltro := ChangeQuery(cFiltro)
	oQry := FwPreparedStatement():New(cFiltro)

	oQry:SetUnsafe( nOrder++, RetSqlName( "RHQ" ) )
	oQry:SetString( nOrder++, cIni)
	oQry:SetString( nOrder++, cFim)
	oQry:SetString( nOrder++, cIni)
	oQry:SetString( nOrder++, cFim)
	oQry:SetString( nOrder++, cFim)
	oQry:SetString( nOrder++, cIni)
	oQry:SetString( nOrder++, cIni)
	
	cFiltro := oQry:GetFixQuery()

	cFiltro := SubStr(cFiltro, At("(", cFiltro))
	cFiltro := SubStr(cFiltro, 0, RAt(")", cFiltro))

	oModel:DeActivate()
	oModel:GetModel("RHQDETAIL"):ClearData( .F., .F.) 
	oModel:GetModel('RHQDETAIL'):SetLoadFilter( {}, cFiltro)
	oModel:Activate()
	
Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} at960TRCC
@description  Verifica se o ambiente fara Troca do Turno do Funcionario na SRA
@author 		Jack Junior
@since 			18/03/2026
@version 		12.1.2510
/*/
//--------------------------------------------------------------------------------------------------------------------
Function at960TRCC()

Return TCU->(ColumnPos("TCU_TRCC")) > 0 .AND. SuperGetMV('MV_GSTRCC', ,.F.)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At960Trim
@description  Remove Espacos desnecessarios de uma String
@author 		Jack Junior
@since 			24/03/2026
@version 		12.1.2510
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At960Trim(cTexto)

	If ValType(cTexto) == "C"
		// Remove CRLF da String se houver:
		cTexto := FwCutOff(cTexto)

		// Remove Espacos das extremidades (inicio e fim)
		cTexto := AllTrim(cTexto) 

		// Loop para substituir duplos Espacos por um espaco simples
		While "  " $ cTexto // Enquanto houver 2 Espacos juntos
			cTexto := StrTran(cTexto, "  ", " ") // Substitui por 1 espaco
		EndDo
	EndIf
Return cTexto

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} checkDates
@description Verifica se a data da troca está dentro do mes do Período. Se não estiver, 
			 troca para o primeiro dia do mês.

@author 		Jack Junior
@since 			29/04/2026
@version 		12.1.2510
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function checkDates(dDataTroca, dDataParam)
	Local dRet := dDataTroca
	Local nAno1 := 0
	Local nAno2 := 0
	Local nMes1 := 0
	Local nMes2 := 0

	If ValType(dDataTroca) == "D" .And. ValType(dDataTroca) == "D"

		nAno1 := Year(dDataTroca)
		nAno2 := Year(dDataParam)
		nMes1 := Month(dDataTroca)
		nMes2 := Month(dDataParam)

		If dDataTroca < dDataParam .And. (nAno1 < nAno2 .Or. (nAno1 == nAno2 .And. nMes1 < nMes2))
			dRet := StoD(StrZero(Year(dDataParam), 4) + StrZero(Month(dDataParam), 2) + "01")
		EndIf

	EndIf

Return dRet
