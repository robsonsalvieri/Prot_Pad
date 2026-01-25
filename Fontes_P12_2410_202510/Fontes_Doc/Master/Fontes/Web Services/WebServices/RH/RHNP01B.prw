#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PONCALEN.CH"

/*/{Protheus.doc} haveAttPoints
	Função recebe filial e matrícula do funcionário
	e uma data inicial e uma final.
	Retorna .T. caso o funcionário tenha batidas ímpares ou atrasos/faltas
	no período pesquisado.
	@author alberto.ortiz
	@since 08/12/2023
/*/
Function fHvAttPnts(cFil, cMatSRA, dInitPeriod, dEndPeriod)

	Local aArea          := {}
	Local lHaveAttPoints := .F.
	Local cTnoTrab       := ""
	Local cSeqTurn       := ""
	Local cRaCC          := ""

	Default cFil		    := ""
	Default cMatSRA			:= ""
	Default dInitPeriod   	:= Ctod("//")
	Default dEndPeriod   	:= Ctod("//")

	
	If !Empty(cFil) .And. !Empty(cMatSRA)

		aArea := GetArea()

		dbSelectArea("SRA")
		SRA->(dbSetOrder(1))
			
		If SRA->(dbSeek(cFil+cMatSRA))

			dInitPeriod := If(!Empty(dInitPeriod), dInitPeriod, dDataBase - 30)
			dEndPeriod  := If(!Empty(dEndPeriod) , dEndPeriod , dDataBase)

			lHaveAttPoints := fHvAtrssFlts(cFil, cMatSRA, dInitPeriod, dEndPeriod)

			If !lHaveAttPoints

				cTnoTrab := SRA->RA_TNOTRAB	
				cSeqTurn := SRA->RA_SEQTURN
				cRaCC    := SRA->RA_CC

				lHaveAttPoints := fHvBtdsImprs(cFil, cMatSRA, dInitPeriod, dEndPeriod, cTnoTrab, cSeqTurn, cRaCC)
			EndIf
		EndIf

		RestArea(aArea)
	EndIf

Return(lHaveAttPoints)

/*/{Protheus.doc} fHvAtrssFlts
	Função recebe filial e matrícula do funcionário
	e uma data inicial e uma final.
	Retorna .T. caso o funcionário tenha atrasos/faltas
	no período pesquisado.
	@author alberto.ortiz
	@since 08/12/2023
/*/
Static Function fHvAtrssFlts(cFil, cMatSRA, dInitPeriod, dEndPeriod)

	Local aArea			 := {}
	Local cAliasQry		 := ""
	Local cWhere 		 := ""
	Local cJoinFil 		 := ""
	Local cIdFeA 		 := "'02','03','04','05'" //IDS Faltas e Atrasos
	Local lHaveAttPoints := .F.

	Default cFil		    := ""
	Default cMatSRA			:= ""
	Default dInitPeriod   	:= Ctod("//")
	Default dEndPeriod   	:= Ctod("//")

	If !Empty(dInitPeriod) .And. !Empty(dEndPeriod)

		aArea		:= GetArea()
		cAliasQry	:= GetNextAlias()
	
		cWhere += "%"
		cWhere += "PC_FILIAL = '" + cFil + "' AND "
		cWhere += "PC_MAT = '" + cMatSRA + "' AND "
		cWhere += "PC_DATA >= '" + dToS(dInitPeriod) + "' AND "
		cWhere += "PC_DATA <= '" + dToS(dEndPeriod) + "' AND "
		cWhere += "P9_CLASEV IN (" + cIdFeA + ") AND "
		cWhere += "(PC_QTABONO = 0 OR PC_QTABONO < PC_QUANTC)"
		cWhere += "%"

		cJoinFil:= "%" + FWJoinFilial("SPC", "SP9") + "%"

		BEGINSQL ALIAS cAliasQry
			SELECT COUNT(*) QTDREG
			FROM %Table:SPC% SPC
			INNER JOIN %Table:SP9% SP9
			ON %exp:cJoinFil% AND 
			SP9.%NotDel% AND 
			SPC.%NotDel% AND
			SPC.PC_PD = SP9.P9_CODIGO
			WHERE
				%Exp:cWhere%  AND SPC.%NotDel%
		EndSql 	
		
		lHaveAttPoints := (cAliasQry)->(QTDREG) > 0

		(cAliasQry)->(DbCloseArea())

		RestArea(aArea)
	EndIf

Return(lHaveAttPoints)

/*/{Protheus.doc} fHvBtdsImprs
	Função recebe filial e matrícula do funcionário
	e uma data inicial e uma final.
	Retorna .T. caso o funcionário tenha batidas ímpares
	@author alberto.ortiz
	@since 08/12/2023
/*/
Static Function fHvBtdsImprs(cFil, cMatSRA, dInitPeriod, dEndPeriod, cTnoTrab, cSeqTurn, cRaCC)

	Local aArea          := GetArea()
	Local aMarcRS3	     := {}
	Local aMarcOrd	     := {}
	Local aAddMarc	     := {}
	Local aMarcGet	     := {}
	Local aNewMarc 	     := {}
	Local cQueryAlias    := Nil
	Local cChave	     := ""
	Local cAliasMarc     := "SP8"
	Local cOrdem	     := ""
	Local lHaveAttPoints := .F.
	Local lAtulizRFE     := .F.
	Local nSoma1	     := 1
	Local nX             := 0
	Local nY             := 0
	Local lGetMarcAuto   := (SuperGetMv( "MV_GETMAUT" , NIL , "S" , cFilAnt ) == "S")
	Local aMarcacoes     := {}
	Local aTabCalend     := {}

	Default cFil         := ""
	Default cMatSRA      := ""
	Default dInitPeriod  := CTOD("//")
	Default dEndPeriod   := CTOD("//")
	Default cTnoTrab     := ""
	Default cSeqTurn     := ""
	Default cRaCC        := ""
	

	//Carrega o Calendario de Marcacoes do Funcionario 
	GetMarcacoes(	@aMarcGet			,;	//01 -> Marcacoes do Funcionario
					@aTabCalend			,;	//02 -> Calendario de Marcacoes
					Nil			        ,;	//03 -> Tabela Padrao
					Nil     			,;	//04 -> Turnos de Trabalho
					dInitPeriod			,;	//05 -> Periodo Inicial
					dEndPeriod			,;	//06 -> Periodo Final
					cFil		        ,;	//07 -> Filial
					cMatSRA		    	,;	//08 -> Matricula
					cTnoTrab			,;	//09 -> Turno
					cSeqTurn			,;	//10 -> Sequencia de Turno
					cRaCC				,;	//11 -> Centro de Custo
					cAliasMarc			,;	//12 -> Alias para Carga das Marcacoes
					.T.					,;	//13 -> Se carrega Recno em aMarcacoes
					.T.		 			,;	//14 -> Se considera Apenas Ordenadas
					Nil					,;  //15 -> Verifica as Folgas Automaticas
					Nil  				,;  //16 -> Se Grava Evento de Folga Mes Anterior
					lGetMarcAuto		,;	//17 -> Se Carrega as Marcacoes Automaticas
					Nil	                ,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Deletados
					Nil					,;	//19
					Nil					,;	//20
					Nil					,;	//21
					Nil					,;	//22
					.T.					,;	//23 -> Se carrega as marcacoes das duas tabelas SP8 e SPG Passar .F.
					)

	aMarcacoes := aClone(aMarcGet)

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
			RS3_FILIAL
		FROM %table:RS3% RS3
		INNER JOIN %table:RH3% RH3 ON
			RS3_FILIAL = RH3_FILIAL AND
			RS3_CODIGO = RH3_CODIGO
		WHERE RS3_FILIAL = %exp:cFil% AND
			RS3_MAT = %exp:cMatSRA% AND
			RS3_DATA >= %exp:DtoS(dInitPeriod - nSoma1)% AND
			RS3_DATA <= %exp:DtoS(dEndPeriod + nSoma1)% AND
			RS3.%notDel% AND RH3.%notDel% AND
			RS3_STATUS <> "3"
		ORDER BY RS3_FILIAL, RS3_MAT, RS3_DATA, RS3_HORA
	ENDSQL

	While (cQueryAlias)->(!Eof())
		IF (cQueryAlias)->RH3_STATUS $ "1/4"
			aAddMarc := Array(01, Array(ELEMENTOS_AMARC))

			//O atributo MOTIVRG será utilizado para guardar uma chave contendo as informacoes da requisicao
			cChave := (cQueryAlias)->RH3_STATUS +"|"+ (cQueryAlias)->RS3_CODIGO +"|"+ (cQueryAlias)->RH3_STATUS +"|"+ "P"

			aAddMarc[01, AMARC_DATA] 	 := StoD((cQueryAlias)->RS3_DATA)
			aAddMarc[01, AMARC_HORA] 	 := (cQueryAlias)->RS3_HORA
			aAddMarc[01, AMARC_FLAG] 	 := "P"
			aAddMarc[01, AMARC_MOTIVRG]  := cChave
			aAddMarc[01, AMARC_DTHR2STR] := ""	
			aAddMarc[01, AMARC_TIPOREG]	 := ""	
			aAddMarc[01, AMARC_DATAAPO]  := StoD((cQueryAlias)->RS3_DATA)

			aAdd(aMarcRS3, aAddMarc[1])
		EndIf

		(cQueryAlias)->(DbSkip())
	EndDo

	(cQueryAlias)->(DbCloseArea())

	//Adiciona as marcacoes manuais que ainda nao foram para o ponto
	If Len(aMarcRS3) > 0

		//Define as marcacoes que vieram do ponto como validas (01)
		aEval(aMarcacoes ,{|x| x[AMARC_MOTIVRG] := "01"})

		aMarcOrd := aClone(aMarcRS3)
		PutOrdMarc(@aMarcOrd, aTabCalend, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, lAtulizRFE)
		
		aMarcacoes := fJntMrccs(aMarcRS3, aMarcOrd, aMarcacoes, aTabCalend)
	EndIf

	//Fecha as tabelas do ponto após utilização
	Pn090Close()

	For nX := 1 To Len(aMarcacoes)
		IF (cOrdem := aMarcacoes[nX, 03]) == "ZZ"
			Loop
		EndIF	
		aAdd(aNewMarc, {})
		For nY := nX To Len(aMarcacoes)
			IF aMarcacoes[nY, 03] == cOrdem .and. aMarcacoes[nY, 03] != "ZZ"
				aAdd(aNewMarc[Len(aNewMarc)], aClone(aMarcacoes[nY]))
				aMarcacoes[nY,03] := "ZZ"
			Else
				Exit
			EndIF
		Next nY
	Next nX

	For nX := 1 to Len(aNewMarc)
		If Len(aNewMarc[nX]) % 2 > 0 //"Marcações Ímpares"
			lHaveAttPoints := .T. 
			Exit
		EndIf
	Next nX

	RestArea(aArea)
 
Return(lHaveAttPoints)

/*/{Protheus.doc} fJntMrccs
	Função auxiliar a fHvBtdsImprs
	Junta as batidas manuais, com as do getMarcações.
	@author alberto.ortiz
	@since 08/12/2023
/*/
Static Function fJntMrccs(aRS3, aRS3Ord, aMarcacoes, aTabCalend)

	Local nX		 := 0
	Local nZ		 := 0
	Local aTemp		 := {}
	Local aNewOrd	 := {}
	Local lAtulizRFE := .F.

	Default aRS3       := {}
	Default aRS3Ord    := {}
	Default aMarcacoes := {}
	Default aTabCalend := {}

	//Identifica as marcacoes da tabela RS3 que ainda nao foram para o Ponto
	If Len(aMarcacoes) > 0
		For nX := 1 To Len(aRS3Ord)
			If aScan(aMarcacoes, {|x| DTOS(x[25]) + STR(x[2],5,2) == DTOS(aRS3Ord[nX,25]) + STR(aRS3Ord[nX,2],5,2)}) == 0
				aAdd(aTemp, aRS3Ord[nX])
			EndIf
		Next nX
	Else
		aTemp := aClone(aRS3Ord)
	EndIf

	If Len(aTemp) > 0

		aNewOrd := aClone(aMarcacoes)

		For nX := 1 To Len(aTemp)
			aAdd(aNewOrd, aTemp[nX])
		Next nX

		aEval(aNewOrd ,{|x| If( Empty(x[AMARC_DTHR2STR]), x[AMARC_L_ORIGEM]:=.F., x[AMARC_L_ORIGEM] := .T.) })
		PutOrdMarc(@aNewOrd, aTabCalend, NIL ,.T., NIL, NIL, NIL, NIL, NIL, NIL, lAtulizRFE)

		//Conserva os dados da solicitacao original
		For nZ := 1 To Len(aRS3)
			nReg := aScan(aNewOrd, {|x| DTOS(x[1]) + STR(x[2],5,2) == DTOS(aRS3[nZ,1]) + STR(aRS3[nZ,2],5,2) })
			If nReg > 0
				aNewOrd[nReg, AMARC_MOTIVRG ] := aRS3[nZ,AMARC_MOTIVRG]
				aNewOrd[nReg, AMARC_TIPOREG ] := ""
			EndIf
		Next nZ	
		aMarcacoes := aClone(aNewOrd)
	EndIf

Return(aMarcacoes)
