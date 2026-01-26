#INCLUDE "TOTVS.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "PONM450.CH"

/*/{Protheus.doc} PONM450
Gera o arquivo AEJ de acordo com a portaria 671/2021
@type  Function
@author Cícero Alves
@since 23/08/2022
/*/
Function PONM450()
	
	Local aArea			:= GetArea()
	Local cDescricao 	:= STR0001 // "Essa rotina realiza a Geração do Arquivo Eletrônico de Jornada - AEJ, seguindo o leiaute e definições da portaria 671/2021"
	Local cBkpFil		:= cFilAnt
	
	Private lBlind 		:= IsBlind()
	Private aLogTitle	:= {}
	Private aLogAEJ 	:= {{}}
	Private nTipo01		:= 0
	Private nTipo03		:= 0
	Private nTipo05		:= 0
	Private nTipo06		:= 0
	Private nTipo07		:= 0
	Private oTmpAEJ
	
	If !fExistPerg("PONM450")
		//"Funcionalidade não disponível para esta versão do sistema."
		Help(,, "Help",, STR0002, 1, 0,,,,,, {STR0003}) // "Para utilizar a rotina de geração do arquivo AEJ é necessário atualizar o sistema."
		Return
	EndIf
	
	Pergunte("PONM450", .F.)
	
	If !lBlind
		tNewProcess():New( "PONM450", STR0004, {|oSelf| PNM450Proc(oSelf) }, cDescricao, "PONM450",,,,,,.T.) // "Geração do arquivo AEJ"
	Else
		PNM450Proc()
	EndIf
	
	MsAguarde({|| fMakeLog( aLogAEJ, aLogTitle, "PONM450", , "PONM450", STR0005 )}, STR0005) // "Ocorrências na geração do arquivo AEJ"
	
	cFilAnt := cBkpFil
	
	RestArea(aArea)
	
	If oTmpAEJ <> Nil
		oTmpAEJ:Delete()
		Freeobj(oTmpAEJ)
    EndIf
	
Return

/*/{Protheus.doc} PNM450Proc
Busca as informações e gera o arquivo de texto
@type  Static Function
@author Cícero Alves
@since 23/08/2022
@param oProcess, Objeto, instância da classe tNewProcess
/*/
Static Function PNM450Proc(oProcess)
	
	Local cAcessaSRA	:= fSFiltrSQL(ChkRH("PONM450", "SRA", "2"))
	Local cQrySRA 		:= GetNextAlias()
	Local cLastFil		:= "*"
	Local cLastCPF		:= "*"
	Local cLastCod		:= ""
	Local cWhereSRA		:= ""
	Local cWhereSP8		:= ""
	Local cWhereSPG		:= ""
	Local cWhereRFF		:= ""
	Local cWhereRFG		:= ""
	Local aInfo			:= {}
	Local LGeraFil		:= .F.
	Local l1Vinculo		:= .T.
	Local nRegua		:= 0
	
	Private dPerIni		:= cToD("//")
	Private dPerFim		:= cToD("//")
	Private dDataIni	:= MV_PAR08
	Private dDataFim	:= MV_PAR09
	Private aHorarios	:= {}
	Private aRelogios	:= {}
	Private aFiliais	:= {}
	Private cRegraIn 	:= ""
	Private cCentroCIn 	:= ""
	Private cTurnoIn 	:= ""
	Private lVldRegra	:= .F.
	Private lVldCentC	:= .F.
	Private lVldTurno	:= .F.
	
	dbSelectArea("SRA")
	
	MV_PAR06	:= fSqlIn(StrTran(MV_PAR06, '*'), 1)
	MV_PAR07	:= fSqlIn(StrTran(MV_PAR07, '*'), 1)
	
	MakeSqlExp("PONM450")
	
	cWhereSRA := "RA_ADMISSA <= '" + dToS(dDataFim) + "' " 
	cWhereSRA += "AND ( RA_DEMISSA = '        ' OR RA_DEMISSA > '" + dToS(dDataIni) + "' )"
	cWhereSRA += If(!Empty(MV_PAR06), " AND RA_SITFOLH IN (" + MV_PAR06 + ")", "") // Situações
	cWhereSRA += If(!Empty(MV_PAR07), " AND RA_CATFUNC IN (" + MV_PAR07 + ")", "") // Categorias
	
	// Controle de Acesso
	cWhereSRA += If(!Empty(cAcessaSRA) .And. cAcessaSRA != ".T.", " AND " + cAcessaSRA, "")
	cWhereSRA := "%" + cWhereSRA + "%"
	
	cWhereSP8 := "( P8_DATAAPO BETWEEN '" + dToS(dDataIni) + "' AND '" + dToS(dDataFim) + "'"
	cWhereSP8 += " OR (P8_DATAAPO = '        ' AND P8_DATA BETWEEN '" + dToS(dDataIni) + "' AND '" + dToS(dDataFim) + "')) "
	cWhereSP8 += If(!Empty(MV_PAR01), " AND " + StrTran(MV_PAR01, "RA_FILIAL", "P8_FILIAL"), "") 	// Filiais
	cWhereSP8 += If(!Empty(MV_PAR02), " AND " + StrTran(MV_PAR02, "RA_CC", "P8_CC"), "") 			// Centros de Custo
	cWhereSP8 += If(!Empty(MV_PAR04), " AND " + StrTran(MV_PAR04, "RA_MAT", "P8_MAT"), "") 			// Matrículas
	cWhereSP8 += If(!Empty(MV_PAR03), " AND " + StrTran(MV_PAR03, "RA_TNOTRAB", "P8_TURNO"), "")	// Turnos
	cWhereSP8 := "%" + cWhereSP8 + "%"
	
	cWhereSPG := StrTran(cWhereSP8, "P8_", "PG_")
	
	cWhereRFF := "RFF_DATA BETWEEN '" + dToS(dDataIni) + "' AND '" + dToS(dDataFim) + "'"
	cWhereRFF += If(!Empty(MV_PAR01), " AND " + StrTran(MV_PAR01, "RA_FILIAL", "RFF_FILIAL"), "")	// Filiais
	cWhereRFF += If(!Empty(MV_PAR02), " AND " + StrTran(MV_PAR02, "RA_CC", "RFF_CC"), "") 			// Centros de Custo
	cWhereRFF += If(!Empty(MV_PAR04), " AND " + StrTran(MV_PAR04, "RA_MAT", "RFF_MAT"), "") 		// Matrículas
	cWhereRFF := "%" + cWhereRFF + "%"
	
	cWhereRFG := StrTran(cWhereRFF, "RFF_", "RFG_")
	
	BeginSQL ALIAS cQrySRA
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_NOMECMP, RA_CIC, RA_CODUNIC, R_E_C_N_O_ AS RECNO
		FROM %Table:SRA% SRA
		INNER JOIN (
			SELECT DISTINCT P8_FILIAL, P8_MAT
			FROM %Table:SP8% SP8
			WHERE %Exp:cWhereSP8%
			AND SP8.%NotDel%
			UNION 
			SELECT DISTINCT PG_FILIAL, PG_MAT
			FROM %Table:SPG% SPG
			WHERE %Exp:cWhereSPG%
			AND SPG.%NotDel%
			UNION
			SELECT DISTINCT RFF_FILIAL, RFF_MAT 
			FROM %Table:RFF% RFF
			WHERE %Exp:cWhereRFF%
			AND RFF.%NotDel%
			UNION
			SELECT DISTINCT RFG_FILIAL, RFG_MAT 
			FROM %Table:RFG% RFG 
			WHERE %Exp:cWhereRFG%
			AND RFG.%NotDel%
		) SP8_TMP
		ON SRA.RA_FILIAL = SP8_TMP.P8_FILIAL
		AND SRA.RA_MAT = SP8_TMP.P8_MAT
		WHERE %Exp:cWhereSRA%
		AND SRA.%NotDel%
		ORDER BY SRA.RA_CIC
	EndSQL
	
	If !lBlind
		(cQrySRA)->(dbEval({|| nRegua++ }))
		(cQrySRA)->(dbGoTop())
		oProcess:SetRegua1(nRegua)
	EndIf
	
	// Guardas as expressões em AdvPL para posterior validação
	MakeAdvplExpr("PONM450")
	cRegraIn := If(!Empty(MV_PAR05), StrTran(MV_PAR05, "RA_REGRA", "aTabCalend[nPosCalend][23]"), "")
	lVldRegra := !Empty(cRegraIn)
	
	cCentroCIn := If(!Empty(MV_PAR02), StrTran(MV_PAR02, "RA_CC", "cCentroC"), "")
	lVldCentC := !Empty(cCentroCIn)
	
	cTurnoIn := If(!Empty(MV_PAR03), StrTran(MV_PAR03, "RA_TNOTRAB", "aTabCalend[nPosCalend][14]"), "")
	lVldTurno := !Empty(cTurnoIn)
	
	MakeSqlExp("PONM450")
	
	While (cQrySRA)->(!EoF())
		
		If !lBlind
			oProcess:IncRegua1("Processando funcionário " + (cQrySRA)->RA_MAT )
		EndIf
		
		// Adiciona no Log os funcionários com CPF em branco
		If (cQrySRA)->(Empty(RA_CIC))
			If(Empty(aLogTitle))
				Aadd(aLogTitle, STR0006) // "Funcionários não enviados"
			EndIf
			Aadd(aLogAEJ[1], (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT + ": " + STR0007) // "CPF inválido."
			(cQrySRA)->(dbSkip())
			LOOP
		EndIf
		
		// Verifica se Houve Troca de Filial
		If !((cQrySRA)->RA_FILIAL == cLastFil)
			
			cLastFil := (cQrySRA)->RA_FILIAL
			cFilAnt := cLastFil
			
			If (nPosFil := aScan(aFiliais, {|x| x == (cQrySRA)->RA_FILIAL})) > 0
				nTipo01 := nPosFil
			Else
				nTipo01 := Len(aFiliais) + 1
				LGeraFil := .T.
			EndIf
			
			// Obtem as datas do Periodo em Aberto
			GetPonMesDat( @dPerIni, @dPerFim, cLastFil )
			
		EndIf
		
		nTipo03++ // Controla a quantidade de funcionários enviados
		
		//Posiciona no Funcionário
		SRA->(dbGoTo((cQrySRA)->RECNO))
		
		// Gera as informações sobre horários, REPs e marcações. Tipos 02, 04, 05 e 07
		If !GeraMarc()
			If(Empty(aLogTitle))
				Aadd(aLogTitle, STR0006) //"Funcionários não enviados"
			EndIf
			Aadd(aLogAEJ[1], (cQrySRA)->RA_FILIAL + " - " + (cQrySRA)->RA_MAT + ": " + STR0008) // "Funcionário sem marcações."
			(cQrySRA)->(dbSkip())
			nTipo03-- // Controle da quantidade de funcionários enviados
			LOOP
		EndIf
		
		//Gera o cabeçalho apenas quando o funcionário tem informações
		If LGeraFil
			// Busca as informações do cadastro de empresas
			fInfo(@aInfo, (cQrySRA)->RA_FILIAL)
			
			// Grava as informações do cabeçalho na tabela temporária
			Tipo01(aInfo)
			
			aAdd(aFiliais, (cQrySRA)->RA_FILIAL)
			LGeraFil := .F.
		EndIf
		
		// Grava as informações do Vínculo do funcionário
		(cQrySRA)->(Tipo03(RA_CIC, If(!Empty(RA_NOMECMP), RA_NOMECMP, RA_NOME)))
		
		// Tratamento para funcionários com múltiplos vínculos
		If (cQrySRA)->RA_CIC == CLastCPF
			// Grava informações do vínculo no eSocial (Funcionário anterior)
			If l1Vinculo
				Tipo06(CLastCod, .T.)
			EndIf
			// Grava informações do vínculo no eSocial (Funcionário Atual)
			Tipo06((cQrySRA)->RA_CODUNIC, .F.)
			l1Vinculo := .F.
		Else
			l1Vinculo := .T.
		EndIf
		
		CLastCPF := (cQrySRA)->RA_CIC
		CLastCod := (cQrySRA)->RA_CODUNIC
		
		
		(cQrySRA)->(dbSkip())
		
	EndDo
	
	(cQrySRA)->(dbCloseArea())
	
	// Grava as informações do programa
	Tipo8()
	
	// Grava o Trailer do arquivo
	Tipo99()
	
	// Gera as informações da assinatura eletrônica
	Assina()
	
	// Grera o arquivo de texto
	GeraArq()
	
Return 

/*/{Protheus.doc} GeraMarc
Gera as informações sobre horários, REPs e marcações. Tipos 02, 04, 05 e 07 (DSR)
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@return lRet, Lógico, Verdadeiro quando o funcionário possui marcações no período selecionado
/*/
Static Function GeraMarc()
	
	Local aPeriodos 	:= {}
	Local aTabCalend 	:= {} 
	Local aTurnos		:= {}
	Local aMarcacoes	:= {}
	Local aTabPadrao	:= {}
	Local lRet			:= .F.
	Local nMarcacoes	:= 0
	Local nI			:= 0
	
	aPeriodos := Monta_per( dDataIni, dDataFim, SRA->RA_FILIAL, SRA->RA_MAT, dPerIni, dPerFim )
	
	For nI := 1 To Len(aPeriodos)
		
		aTabCalend 	:= {}
		aTurnos		:= {}
		aMarcacoes	:= {}
		aTabPadrao	:= {}
		
		GetMarc(@aMarcacoes, SRA->RA_FILIAL, SRA->RA_MAT, aPeriodos[nI, 1], aPeriodos[nI, 2])
		
		If !CriaCalend(	aPeriodos[nI, 1] 	,;	//01 -> Data Inicial do Periodo
		   			   	aPeriodos[nI, 2]	,;	//02 -> Data Final do Periodo
				   		SRA->RA_TNOTRAB		,;	//03 -> Turno Para a Montagem do Calendario
				   		SRA->RA_SEQTURN		,;	//04 -> Sequencia Inicial para a Montagem Calendario
				   		@aTabPadrao			,;	//05 -> Array Tabela de Horario Padrao
				   		@aTabCalend			,;	//06 -> Array com o Calendario de Marcacoes
				   		SRA->RA_FILIAL     	,;	//07 -> Filial para a Montagem da Tabela de Horario
				   		SRA->RA_MAT   		,;	//08 -> Matricula para a Montagem da Tabela de Horario
				   		SRA->RA_CC   		,;	//09 -> Centro de Custo para a Montagem da Tabela
				   		@aTurnos			,;	//10 -> Array com as Trocas de Turno
						NIL					,;	//11 -> Array com Todas as Excecoes do Periodo
						NIL					,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
						.T.					,;	//13 -> Se executa a funcao se sincronismo do calendario
						NIL			 		;	//14 -> Se Forca a Criacao de Novo Calendario
					)
			
			If(Empty(aLogTitle))
				Aadd(aLogTitle, STR0006) // "Funcionários não enviados"
			EndIf
			Aadd(aLogAEJ[1], SRA->RA_FILIAL + " - " + SRA->RA_MAT + ": " + STR0009) // "Não foi possível criar o calendário para o funcionário."
			LOOP
		EndIf
		
		// Marcações
		If !Tipo05(aMarcacoes, aTabCalend, @nMarcacoes)
			LOOP
		EndIf
		
		// Gera a movimentação de DSR. Tipo 07
		GeraDSR(aTabCalend, aMarcacoes)
		
		// Gera informações sobre os apontamentos. Tipo 07
		GeraApo(aPeriodos[nI, 1], aPeriodos[nI, 2], aTabCalend)
		
	Next nI
	
	If nMarcacoes > 0
		nTipo05 += nMarcacoes
		lRet := .T.
	EndIf
	
Return lRet

/*/{Protheus.doc} GeraApo
Busca os apontamentos gravados nas tabelas de pré-ACJEF e acumulado de ACJEF
@type  Static Function
@author Cícero Alves
@since 26/08/2022
/*/
Static Function GeraApo(dIniData, dFimData, aTabCalend)
	
	Local cAliasRFF		:= GetNextAlias()
	Local cEvDSR		:= PosSP9("002A", SRA->RA_FILIAL, "P9_CODIGO", 2) // Desconsidera o evento de DRS se houver
	Local dDataQryI		:= Max(dIniData, dDataIni)
	Local dDataQryF		:= Min(dFimData, dDataFim)
	Local cWhereRFF 	:= "%%"
	Local cWhereRFG 	:= "%%"
	Local cSinal		:= ""
	Local nPosCalend	:= 0
	
	If lVldCentC
		cWhereRFF := "% " + StrTran(MV_PAR02, "RA_CC", "RFF_CC") + " AND %"
		cWhereRFG := "% " + StrTran(MV_PAR02, "RA_CC", "RFG_CC") + " AND %"
	EndIf
	
	BeginSQL ALIAS cAliasRFF
		COLUMN RFF_DATA AS DATE
		SELECT RFF_DATA, RFF_PD, RFF_TIPO, RFF_QUANTC, P9_TIPOCOD
		FROM %Table:RFF% RFF
		INNER JOIN %Table:SP9% SP9J
		ON RFF_PD = SP9J.P9_CODIGO
		AND SP9J.P9_FILIAL = %Exp:xFilial("SP9", SRA->RA_FILIAL)%
		WHERE RFF_FILIAL = %Exp:SRA->RA_FILIAL% AND 
		RFF_MAT = %Exp:SRA->RA_MAT% AND
		RFF_DATA >= %Exp:dToS(dDataQryI)% AND
		RFF_DATA <= %Exp:dToS(dDataQryF)% AND
		RFF_PD != %Exp:cEvDSR% AND
		( RFF_TIPO = '2' OR 
		RFF_PD IN (
			SELECT P9_CODIGO 
			FROM %Table:SP9% SP9 
			WHERE P9_FILIAL = %Exp:xFilial("SP9", SRA->RA_FILIAL)% AND 
			P9_CLASEV = '02' AND
			SP9.%NotDel% ) ) AND
		%Exp:cWhereRFF%
		RFF.%NotDel% AND
		SP9J.%NotDel%
		UNION ALL
		SELECT RFG_DATA, RFG_PD, RFG_TIPO, RFG_QUANTC, P9_TIPOCOD
		FROM %Table:RFG% RFG
		INNER JOIN %Table:SP9% SP9J
		ON RFG_PD = SP9J.P9_CODIGO
		AND SP9J.P9_FILIAL = %Exp:xFilial("SP9", SRA->RA_FILIAL)%
		WHERE RFG_FILIAL = %Exp:SRA->RA_FILIAL% AND
		RFG_MAT = %Exp:SRA->RA_MAT% AND 
		RFG_DATA >= %Exp:dToS(dDataQryI)% AND
		RFG_DATA <= %Exp:dToS(dDataQryF)% AND
		RFG_PD != %Exp:cEvDSR% AND
		( RFG_TIPO = '2' OR 
		RFG_PD IN (
			SELECT P9_CODIGO 
			FROM %Table:SP9% SP9 
			WHERE P9_FILIAL = %Exp:xFilial("SP9", SRA->RA_FILIAL)% AND 
			P9_CLASEV = '02' AND
			SP9.%NotDel% ) ) AND
		%Exp:cWhereRFG%
		RFG.%NotDel% AND
		SP9J.%NotDel%
		ORDER BY RFF_DATA
	EndSQL
	
	While (cAliasRFF)->(!EoF())
		
		// Valida se o turno e regra estão entre os selecionados nas perguntas
		If (lVldRegra .Or. lVldTurno) .And. (nPosCalend := AScan(aTabCalend, {|x| x[CALEND_POS_DATA_APO] == (cAliasRFF)->RFF_DATA})) > 0
			If (lVldRegra .And. !(&(cRegraIn))) .Or. (lVldTurno .And. !(&(cTurnoIn)))
				(cAliasRFF)->(dbSkip())
				LOOP
			EndIf
		EndIf
		
		If (cAliasRFF)->RFF_TIPO == 2 // Movimentação de banco de horas
			cSinal := If((cAliasRFF)->P9_TIPOCOD $ "1|3", "1", "2")
			(cAliasRFF)->(Tipo07(RFF_DATA, RFF_QUANTC, cSinal, "3"))
		Else
			// Faltas
			(cAliasRFF)->(Tipo07(RFF_DATA, If(RFF_QUANTC > 1, RFF_QUANTC, NIL),, "2"))
		EndIf
		
		(cAliasRFF)->(dbSkip())
	EndDo
	
	(cAliasRFF)->(dbCloseArea())
	
Return

/*/{Protheus.doc} Tipo01
Grava as informações do cabeçalho na tabela temporária
@type  Static Function
@author Cícero Alves
@since 24/08/2022
@param aInfo, Array, Informações do cadastro de empesas
/*/
Static Function Tipo01(aInfo)
	
	Local cTipoReg	:= "01"
	Local cVersao	:= "001"
	Local cRazaoS	:= ""
	Local cTipoInsc	:= ""
	Local cCPFCNPJ	:= ""
	Local cTexto	:= ""
	Local cDataIni	:= Transforma(dDataIni)
	Local cDataFim	:= Transforma(dDataFim)
	Local cDataGera	:= FWTimeStamp(5)
	Local cChave	:= StrZero(nTipo01, 6)
	
	// Remove os últimos : para ficar de acordo com o leiaute do governo
	cDataGera := Left(cDataGera, 22) + Right(cDataGera, 2)
	
	//TODO Terá tratamento para CEI?
	
	// Tipo de inscrição da empresa "1" = CNPJ, "2" = CPF, "3" = CEI
	cTipoInsc := If(aInfo[15] == 1, "3", If(aInfo[15] == 3, "2", "1"))
	
	cCPFCNPJ := AllTrim(aInfo[8])
	
	//TODO buscar CAEPF
	cCAEPF := ""
	
	//TODO buscar CNO
	cCNO := ""
	
	cRazaoS := FSubst(AllTrim(aInfo[3]))
	
	//Monta a linha do Registro do tipo 01 - Cabeçalho
	cTexto += cTipoReg 	+ "|" 	// Tipo de registro
	cTexto += cTipoInsc + "|" 	// Tipo de identificador do empregador
	cTexto += cCPFCNPJ 	+ "|" 	// CNPJ ou CPF do empregador
	cTexto += cCAEPF 	+ "|" 	// CAEPF
	cTexto += cCNO 		+ "|" 	// CNO
	cTexto += cRazaoS 	+ "|" 	// Razão Social ou nome do empregador
	cTexto += cDataIni 	+ "|" 	// Data Inicial
	cTexto += cDataFim 	+ "|" 	// Data Final
	cTexto += cDataGera	+ "|" 	// Data e Hora da Geração
	cTexto += cVersao	+ CRLF	// Versão do Leiaute
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
Return

/*/{Protheus.doc} Tipo02
Busca as informações do REP e grava na tabela temporária
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param cFilSP0, Caractere, Filial do cadastro de relógios
@param cCodRel, Caractere, Código do relógio
@param cNumREP, Caractere, Código REP vinculado ao relógio
@param cCCTREP, Caractere, Código do da CCT vinculada a marcação
@return cIdREP, Caractere, Identificador do REP no AEJ
/*/
Static Function Tipo02(cFilSP0, cCodRel, cNumREP, cCCTREP)
	
	Local aArea		:= GetArea()
	Local cTipoReg	:= "02"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIdREP	:= ""
	Local cTipoREP	:= "1"
	Local cTexto	:= ""
	Local lTipoREP	:= SP0->(ColumnPos("P0_TPREP")) > 0
	Local nPos		:= 0
	
	DEFAULT cCCTREP := ""
	
	DbSelectArea("SP0")
	DbSetOrder(1)
	
	If Empty(cCCTREP)
		
		If SP0->(dbSeek(cFilSP0 + cCodRel))
			
			If Empty(SP0->P0_REP) .Or. (lTipoREP .And. SP0->P0_TPREP == "2")// Relógio do Clock in ou REP-A
				cNumREP := Replicate("9", 17)
				cTipoREP := "2"
				// Verifica se já existe no array com os relógios
				If (nPos := aScan(aRelogios, {|x| x[1] == cNumREP})) > 0
					Return cValToChar(nPos)
				EndIf
			Else
				cTipoREP := If(SP0->P0_TPREP == "4", "3", cTipoREP)
			EndIf
			
		EndIf
	Else
		// Relógio Tipo A (Clock in ou Suricato)
		cNumREP := cCCTREP
		cTipoREP := "2"
	EndIf
	
	// Adiciona no array aRelogios para controle de duplicidade
	aAdd(aRelogios, {cNumREP, SP0->P0_FILIAL + cCodRel})
	
	cIdREP := cValToChar(Len(aRelogios))
	
	cNumREP := Transform(cNumREP, "99999999999999999")
	cNumREP := StrTran(cNumREP, " ", "")
	cNumREP := StrTran(cNumREP, "-", "")
	cNumREP := Right( Replicate("0", 17) + cNumREP, 17)
	
	cTexto := cTipoReg	+ "|"
	cTexto += cIdREP	+ "|"
	cTexto += cTipoREP	+ "|"
	cTexto += cNumREP	+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
	RestArea(aArea)
	
Return cIdREP

/*/{Protheus.doc} Tipo03
Grava as informações do Vínculo do funcionário
@type  Static Function
@author Cícero Alves
@since 24/08/2022
@param cCPF, Caractere, CPF do funcionário
@param cNome, Caractere, Nome do Funcionário
/*/
Static Function Tipo03(cCPF, cNome)
	
	Local cTipoReg	:= "03"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIDVinc	:= CValToChar(nTipo03)
	Local cTexto	:= ""
	
	cCPF := AllTrim(cCPF)
	cNome := AllTrim(cNome)
	
	cTexto += cTipoReg	+ "|"
	cTexto += cIDVinc	+ "|"
	cTexto += cCPF		+ "|"
	cTexto += cNome		+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
Return

/*/{Protheus.doc} Tipo04
Grava o horário contratual na tabela temporária
@type  Static Function
@author user
@since 26/08/2022
@version version
@param aHDia, Array, Horários de entrada e saída progrmados para o dia
@param nJornada, param_type, Duração da jornada de trabalho em horas
@return cIDJorn, Caractere, Código do horário contratual no AEJ
/*/
Static Function Tipo04(aHDia, nJornada)
	
	Local cTipoReg	:= "04"
	Local cChave	:= StrZero(nTipo01, 6)
	Local nI		:= 0
	Local cIDJorn	:= ""
	Local cDuracao	:= CValToChar(__Hrs2Min(nJornada))
	Local cTexto	:= ""
	
	// Adiciona no array aHorarios para controle de duplicidade
	aAdd(aHorarios, aHDia)
	
	cIDJorn := CValToChar(Len(aHorarios))
	
	cTexto += cTipoReg	+ "|"
	cTexto += cIDJorn	+ "|"
	cTexto += cDuracao	+ "|"
	
	For nI := 1 To Len(aHDia)
		cTexto += aHDia[nI]	+ "|"
	Next nI
	
	cTexto := Left(cTexto, Len(cTexto) - 1) // Retira a última /
	cTexto += CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	
Return cIDJorn

/*/{Protheus.doc} Tipo05
Grava as marcações realizadas pelo funcionário no período na tabela temporária
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param aMarcacoes, Array, Marcações do funcionário, incluindo as marcações desconsideradas
@param aTabCalend, Array, Calendário do ponto
@param nMarcacoes, Numérico, Variável para controle do total de registros do tipo 05 foram gerados no arquivo
@return lRet, Lógico, Indica se o funcionário tem alguma marcação no período selecionado
/*/
Static Function Tipo05(aMarcacoes, aTabCalend, nMarcacoes)
	
	Local cTipoReg		:= "05"
	Local cChave		:= StrZero(nTipo01, 6)
	Local cIDVinc		:= CValToChar(nTipo03) // Código do funcionário no arquivo
	Local cHorario		:= ""
	Local cSeqMarc		:= ""
	Local cDHMarc		:= ""
	Local cHoraMarc		:= ""
	Local cTipoMarc		:= ""
	Local cMotivo		:= ""
	Local cLastOrder	:= ""
	Local cOrigem		:= ""
	Local cIdREP		:= ""
	Local cTexto		:= ""
	Local lRet			:= .F.
	Local nMarcPer		:= 0
	Local nI 			:= 0
	Local nPosCalend	:= 0
	
	For nI := 1 To Len(aMarcacoes)
		
		// Consiste as datas, pois são carregadas as marcações do período de apontamento inteiro
		If aMarcacoes[nI][AMARC_DATA] < dDataIni .Or. aMarcacoes[nI][AMARC_DATA] > dDataFim
			LOOP
		EndIf
		
		If lVldRegra .And. !Empty(aMarcacoes[nI][AMARC_ORDEM]) .And. (nPosCalend := AScan(aTabCalend, {|x| x[CALEND_POS_ORDEM] == aMarcacoes[nI][AMARC_ORDEM]})) > 0
			If !(&(cRegraIn))
				LOOP
			EndIf
		EndIf
		
		cHoraMarc := StrTran(StrZero(aMarcacoes[nI][AMARC_HORA], 5, 2), ".", ":") + ":00" // Adiciona os segundos como 00
		
		cDHMarc := FWTimeStamp(5, aMarcacoes[nI][AMARC_DATA], cHoraMarc) 
		
		// Remove os últimos : para ficar de acordo com o leiaute do governo
		cDHMarc := Left(cDHMarc, 22) + Right(cDHMarc, 2)
		
		If !Empty(aMarcacoes[nI][AMARC_RELOGIO])
			cIdREP := GetIdREP(aMarcacoes[nI][AMARC_FILORG], aMarcacoes[nI][AMARC_RELOGIO], aMarcacoes[nI][AMARC_NUMREP], aMarcacoes[nI][AMARC_CCTREP])
		Else
			cIdREP := ""
		EndIf
		
		If aMarcacoes[nI][AMARC_TPMCREP] == "D" // Marcação desconsiderada
			cTipoMarc := "D"
			cSeqMarc := ""
		Else
			cTipoMarc := Right(aMarcacoes[nI][AMARC_TIPOMARC], 1)
			cSeqMarc := StrZero(Val(Left(aMarcacoes[nI][AMARC_TIPOMARC], 1)), 3)
		EndIf
		
		cOrigem := aMarcacoes[nI][AMARC_TIPOREG]
		
		If cOrigem == "I" .Or. cTipoMarc == "D"
			cMotivo := AllTrim(aMarcacoes[nI][AMARC_MOTIVRG])
		Else 
			cMotivo := ""
		EndIf
		
		If !Empty(aMarcacoes[nI][AMARC_ORDEM]) .And. aMarcacoes[nI][AMARC_ORDEM] != cLastOrder
			cHorario := GetHorario(aTabCalend, aMarcacoes[nI][AMARC_ORDEM])
			cLastOrder := aMarcacoes[nI][AMARC_ORDEM]
		EndIf
		
		cTexto := cTipoReg	+ "|"
		cTexto += cIDVinc	+ "|"
		cTexto += cDHMarc	+ "|"
		cTexto += cIdREP	+ "|"
		cTexto += cTipoMarc	+ "|"
		cTexto += cSeqMarc	+ "|"
		cTexto += cOrigem	+ "|"
		cTexto += cHorario	+ "|"
		cTexto += cMotivo	+ CRLF
		
		GravaAEJ(cTipoReg, cChave, cTexto)
		nMarcPer++
		
	Next nI
	
	If nMarcPer > 0
		lRet := .T.
		nMarcacoes += nMarcPer
	EndIf
	
Return lRet

/*/{Protheus.doc} Tipo06
Identificação da matrícula do vínculo no eSocial, para empregados com múltiplos vínculos
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param cCodUnico, Caractere, Matrícula do funcionário no eSocial
@param lAnterior, Lógico, Indica se a geração é referente ao funcionário anterior
/*/
Static Function Tipo06(cCodUnico, lAnterior)
	
	Local cTipoReg	:= "06"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIDVinc	:= If(lAnterior, CValToChar(nTipo03 - 1), CValToChar(nTipo03))
	Local cTexto	:= ""
	
	cTexto += cTipoReg	+ "|"
	cTexto += cIDVinc	+ "|"
	cTexto += cCodUnico	+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	nTipo06++
	
Return

/*/{Protheus.doc} Tipo07
Ausências e Banco de Horas
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param dData, Data, Data da ocorrência
@param nHoras, Numérico, Duração do evento em horas
@param cSinal, Caractere, Define se o evento é de provento ou desconto quando referente a movimentação do banco de horas
@param cTipo, cTipo, Tipo da movimentação. "1": DSR; "2": Falta; "3": movimento no banco de horas
/*/
Static Function Tipo07(dData, nHoras, cSinal, cTipo)
	
	Local cTipoReg	:= "07"
	Local cChave	:= StrZero(nTipo01, 6)
	Local cIDVinc	:= CValToChar(nTipo03)
	Local cTexto	:= ""
	Local cData		:= Transforma(dData)
	Local cMinutos	:= ""
	
	DEFAULT cSinal := ""
	DEFAULT nHoras := 0
	
	cMinutos := If(nHoras > 0, CValToChar(__Hrs2Min(nHoras)), "")
	
	cTexto := cTipoReg	+ "|"
	cTexto += cIDVinc	+ "|"
	cTexto += cTipo		+ "|"
	cTexto += cData		+ "|"
	cTexto += cMinutos	+ "|"
	cTexto += cSinal	+ CRLF
	
	GravaAEJ(cTipoReg, cChave, cTexto)
	nTipo07++
	
Return

/*/{Protheus.doc} Tipo8
Identificação do Programa de Tratamento de Registro de Ponto
@type  Static Function
@author Cícero Alves
@since 26/08/2022
/*/
Static Function Tipo8()
	
	Local cTipoReg	:= "08"
	Local cVersao	:= GetRPORelease()
	Local cPrograma	:= "ERP TOTVS Protheus"
	Local cTipoInsc	:= "1" // CNPJ
	Local cCNPJ		:= "53113791000122"
	Local cRazaoS	:= "TOTVS S.A."
	Local cEmail	:= "MSIGA@MICROSIGA.COM.BR"
	Local cTexto	:= ""
	
	If Len(cVersao) > 8
		cVersao := StrTran(cVersao, ".1", "")
	EndIf
	
	cTexto += cTipoReg	+ "|"
	cTexto += cPrograma	+ "|"
	cTexto += cVersao	+ "|"
	cTexto += cTipoInsc	+ "|"
	cTexto += cCNPJ		+ "|"
	cTexto += cRazaoS	+ "|"
	cTexto += cEmail	+ CRLF
	
	GravaAEJ(cTipoReg, "999999", cTexto)
	
Return

/*/{Protheus.doc} Tipo99
Trailer com o resumo do arquivo
@type  Static Function
@author Cícero Alves
@since 26/08/2022
/*/
Static Function Tipo99()
	
	Local cTipoReg	:= "99"
	Local cTexto	:= ""
	Local cQnt01	:= cValToChar(nTipo01)
	Local cQnt02	:= cValToChar(Len(aRelogios))
	Local cQnt03	:= cValToChar(nTipo03)
	Local cQnt04	:= cValToChar(Len(aHorarios))
	Local cQnt05	:= cValToChar(nTipo05)
	Local cQnt06	:= cValToChar(nTipo06)
	Local cQnt07	:= cValToChar(nTipo07)
	Local cQnt08	:= "1" // Sempre 1
	
	cTexto := cTipoReg	+ "|"
	cTexto += cQnt01	+ "|"
	cTexto += cQnt02	+ "|"
	cTexto += cQnt03	+ "|"
	cTexto += cQnt04	+ "|"
	cTexto += cQnt05	+ "|"
	cTexto += cQnt06	+ "|"
	cTexto += cQnt07	+ "|"
	cTexto += cQnt08	+ CRLF
	
	GravaAEJ(cTipoReg, "999999", cTexto)
	
Return

/*/{Protheus.doc} Assina()
Grava a informação sobre a assinatura eletrônica na tabela temporária
@type  Static Function
@author Cícero Alves
@since 26/08/2022
/*/
Static Function Assina()
	Local cAssinatura := "ASSINATURA_DIGITAL_EM_ARQUIVO_P7S" // Texto leteral do leiaute
	
	cAssinatura := cAssinatura + Space(100 - Len(cAssinatura)) + CRLF
	
	GravaAEJ("ZZ", "999999", cAssinatura)
	
Return

/*/{Protheus.doc} Pn450Cria()
Cria a tabela temporária que armazenará os dados antes de gravar no arquivo de texto
@type  Static Function
@author Cícero Alves
@since 24/08/2022
/*/
Static Function Pn450Cria()
	
	Local aStruct	:= {}
	Local aIndices	:= {}
	
	Static cAliasAEJ := GetNextAlias()
	
	Aadd(aStruct, {"TIPO" , "C",   2, 0})
	Aadd(aStruct, {"CHAVE", "C",   6, 0})
	Aadd(aStruct, {"TEXTO", "C", 255, 0})
	
	Aadd(aIndices, {"CHAVE", "TIPO"})
	
	oTmpAEJ := RhCriaTrab(cAliasAEJ, aStruct, aIndices)
	
Return

/*/{Protheus.doc} GravaAEJ
Realiza a gravação das informações na tabela temporária
@type  Static Function
@author Cícero Alves
@since 24/08/2022
@param cTipoReg, Caractere, Tipo do registro de acordo com o leiaute. Usado para ordenação
@param cChave, Caractere, Chave da filial atual. Usado para ordenação
@param cTexto, Caractere, Texto da linha do arquivo
/*/
Static Function GravaAEJ(cTipoReg, cChave, cTexto)
	
	If oTmpAEJ == NIL
		Pn450Cria()
	EndIf
	
	(cAliasAEJ)->(RecLock(cAliasAEJ, .T. ))
		(cAliasAEJ)->TIPO := cTipoReg
		(cAliasAEJ)->CHAVE := cChave
		(cAliasAEJ)->TEXTO := cTexto
	(cAliasAEJ)->(MsUnlock())
	
Return

/*/{Protheus.doc} GeraArq
Gera o arquivo de texto com as informações gravadas na tabela temporária
@type  Static Function
@author Cícero Alves
@since 24/08/2022
/*/
Static Function GeraArq()
	
	Local cLocFile 	:= Alltrim(MV_PAR10)
	Local cFile		:= ""
	Local cArqtmp	:= GetNextAlias()
	Local nHandle	:= 0
	
	cFile := Upper(GetPvProfString( GetEnvServer(), "StartPath", "", GetAdv97()))
	cFile := AllTrim(cFile + cArqtmp)
	
	nHandle := MsFCreate(cFile)
	
	(cAliasAEJ)->(dbGoTop())
	
	While (cAliasAEJ)->(!EoF())
		FWrite(nHandle, RTrim((cAliasAEJ)->TEXTO))
		(cAliasAEJ)->(!dbSkip())
	EndDo
	
	fClose(nHandle)
	__CopyFile(cFile, cLocFile)
	fErase(cFile)
	
Return

/*/{Protheus.doc} Transforma
Formata uma data para "AAAA-MM-dd"
@type Static Function
@author Cícero Alves
@since 26/08/2022
@param dData, Data, Data que será formatada
@return cRet, Character, Data com o formato "AAAA-MM-dd"
/*/
Static Function Transforma(dData)
Return (Right(Str(Year(dData)), 4) + "-" + StrZero(Month(dData), 2) + "-" + StrZero(Day(dData), 2))

/*/{Protheus.doc} Monta_Per
Monta os períodos de apontamento de acordo com as datas passadas
@type Function
@author Cícero Alves
@since 26/08/2022
@param dDataIni, Date, Data inicial solicitada
@param dDataFim, Date, Data final solicitada
@param cFil, Character, Filial do funcionário
@param cMat, Character, Matrícula do funcionário
@param dIniAtu, Date, Data inicial do período de apontamento atual
@param dFimAtu, Date, Data final do período de apontamento atual
@return aPeriodos, array, Períodos de apontamento compreendidos entre as datas solicitadas
/*/
Function Monta_Per( dDataIni, dDataFim, cFil, cMat, dIniAtu, dFimAtu )
	
	Local aPeriodos := {}
	Local cFilSPO	:= xFilial("SPO", cFil)
	Local dAdmissa	:= SRA->RA_ADMISSA
	Local dPerIni   := CToD("//")
	Local dPerFim   := CToD("//")
	Local dData		:= CToD("//")
	
	SPO->(dbSetOrder( 1 ))
	SPO->(dbSeek(cFilSPO, .F.))
	
	While SPO->( !Eof() .And. PO_FILIAL == cFilSPO )
		
		dPerIni := SPO->PO_DATAINI
		dPerFim := SPO->PO_DATAFIM  
		
		//-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
		If dPerFim < dDataIni .Or. dPerIni > dDataFim
			SPO->(dbSkip())
			LOOP
		EndIf
		
    	//-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
		If dPerFim >= dAdmissa
			aAdd(aPeriodos, {dPerIni, dPerFim, Max(dPerIni, dDataIni), Min(dPerFim, dDataFim)})
		Else
			SPO->(dbSkip())
			LOOP
		EndIF
		
		SPO->(dbSkip())
		
	EndDo
	
	If aScan( aPeriodos, {|x| x[1] == dIniAtu .And. x[2] == dFimAtu }) == 0
		dPerIni := dIniAtu
		dPerFim	:= dFimAtu 
		If !(dPerFim < dDataIni .Or. dPerIni > dDataFim)
			If dPerFim >= dAdmissa
				aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni, dDataIni), Min(dPerFim, dDataFim)})
			EndIf
		EndIf
	EndIF
	
	If !Empty(aPeriodos)
		dData	:= aPeriodos[ Len(aPeriodos), 2 ] + 1
		dPerIni	:= aPeriodos[ Len(aPeriodos), 1 ]
		dPerFim	:= aPeriodos[ Len(aPeriodos), 2 ]
	Else
		dData	:= dDataIni
		dPerIni	:= dIniAtu
		dPerFim	:= dFimAtu
	endif
	
	//Inclui periodos futuros se estiverem compreendidos pelo periodo solicitado
	If dData > dFimAtu 
		While .T.
			PerAponta(@dPerIni, @dPerFim, dData, Nil, Nil, .T., Nil, Nil, .T.)
			
			// Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
			If dPerFim >= dAdmissa .And. !(dPerFim < dDataIni .Or. dPerIni > dDataFim)
				Aadd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni, dDataIni), Min(dPerFim, dDataFim)})
			EndIf
			
			If dDataFim > dPerFim
				dData := dPerFim + 1
			Else
				EXIT
			EndIf
			
		EndDo
	EndIf
	
Return aPeriodos

/*/{Protheus.doc} GetIdREP
Retorna o Identificador do REP no AEJ
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param cFilOrigem, Caractere, Filial para busca no cadastro de relógios
@param cCodRel, Caractere, Código do relógio para busca no cadastro de relógios
@param cNumREP, Caractere, Número do REP ou CCT vinculada a marcação
@return cIdREP, Caractere, dentificador do REP no AEJ
/*/
Static Function GetIdREP(cFilOrigem, cCodRel, cNumREP, cCCTREP)
	
	Local cIdREP 	:= ""
	Local nPos		:= 0
	Local cBusca	:= If(!Empty(cCCTREP), cCCTREP, cNumREP)
	
	If !Empty(cBusca)
		nPos := aScan(aRelogios, {|x| x[1] == cBusca})
	Else
		nPos := aScan(aRelogios, {|x| x[2] == xFilial("SP0", cFilOrigem) + cCodRel})
	EndIf
	
	If nPos > 0
		cIdREP := cValToChar(nPos)
	Else
		cIdREP := Tipo02(cFilOrigem, cCodRel, cNumREP, cCCTREP)
	EndIf
	
Return cIdREP

/*/{Protheus.doc} GetHorario
Retorna o Identificador do horário no AEJ
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param aTabCalend, Array, Calendário do ponto
@param cOrdem, Caractere, Ordem do dia dentro do calendário
@return cHorario, Caractere, Identificador do horário no AEJ
/*/
Static Function GetHorario(aTabCalend, cOrdem)
	
	Local cHorario	:= ""
	Local nI		:= AScan(aTabCalend, {|x| x[CALEND_POS_ORDEM] == cOrdem})
	Local nHrTrab	:= 0
	Local nPosH		:= 0
	Local aAux		:= {}
	
	While nI > 0 .And. nI <= Len(aTabCalend) .And. aTabCalend[nI][CALEND_POS_ORDEM] == cOrdem
		Aadd(aAux, StrTran(StrZero(aTabCalend[nI][CALEND_POS_HORA], 5, 2), "."))
		nHrTrab += aTabCalend[nI][CALEND_POS_HRS_TRABA]
		nI++
	EndDo
	
	If (nPosH := Ascan(aHorarios, {|x| ArrayCompare( aAux, x)})) > 0
		cHorario := CValToChar(nPosH)
	ElseIf nHrTrab > 0
		cHorario := Tipo04(aAux, nHrTrab)
	EndIf
	
Return cHorario

/*/{Protheus.doc} GeraDSR
Gera os dias de DSR com base no calendário e nas marcações realizadas
@type  Static Function
@author Cícero Alves
@since 26/08/2022
@param aTabCalend, Array, Calendário do ponto
@param aMarcacoes, Array, Marcações do funcionário no período
/*/
Static Function GeraDSR(aTabCalend, aMarcacoes)
	
	Local nPosCalend := 0
	Local cLastOrder := ""
	Local cCentroC 	 := ""
	
	For nPosCalend := 1 To Len(aTabCalend)
		// O dia é um DSR e não houve marcações
		If aTabCalend[nPosCalend][CALEND_POS_TIPO_DIA] == "D" .And. aTabCalend[nPosCalend][CALEND_POS_ORDEM] != cLastOrder
			
			// Consiste as datas, pois é carregado o período inteiro
			If aTabCalend[nPosCalend][CALEND_POS_DATA] < dDataIni .Or. aTabCalend[nPosCalend][CALEND_POS_DATA] > dDataFim
				LOOP
			EndIf
			
			// Valida se o turno e regra estão entre os selecionados nas perguntas
			If (lVldRegra .And. !(&(cRegraIn))) .Or. (lVldTurno .And. !(&(cTurnoIn)))
				LOOP
			EndIf
			
			// Valida o centro de custo
			If lVldCentC 
				If Empty(aTabCalend[nPosCalend][CALEND_POS_CC])
					fBuscaCC(aTabCalend[nPosCalend][CALEND_POS_DATA], @cCentroC)
				Else
					cCentroC := aTabCalend[nPosCalend][CALEND_POS_CC]
				EndIf
				
				If !(&(cCentroCIn))
					LOOP
				EndIf
			EndIf
			
			If AScan(aMarcacoes, {|x| x[AMARC_ORDEM] == aTabCalend[nPosCalend][CALEND_POS_ORDEM]}) == 0
				Tipo07(aTabCalend[nPosCalend][CALEND_POS_DATA],,, "1")
			EndIf
			cLastOrder := aTabCalend[nPosCalend][CALEND_POS_ORDEM]
		EndIf
	Next nPosCalend
	
Return 

/*/{Protheus.doc} fExistPerg
Verifica se o grupo de perguntas existe no ambiente
@type static function
@author Cícero Alves
@since 26/08/2022
@param cPergunte, Caractere, Código do grupo de perguntas
@return lRet, Lógico, Indica se o grupo de perguntas existe ou não
/*/
Function fExistPerg(cPergunte)
	
	Local lRet	:= .F.
	Local oSX1	:= FWSX1Util():New()
	
	oSX1:AddGroup(cPergunte)
	oSX1:SearchGroup()
	
	If !Empty(oSX1:aGrupo[1, 2])
		lRet:= .T.
	EndIf
	
	FreeObj(oSX1)
	
Return lRet

/*/{Protheus.doc} fGetAEJ
Abre a interface para a seleção do diretório de geração doarquivo
@type  Function
@author Cícero Alves
@since 30/08/2022
@return lRet, Lógico, Retorna falso quando o caminho estiver em branco
/*/
Function fGetAEJ()
	
	Local mvRet := Alltrim(ReadVar())
	
	oWnd := GetWndDefault()
	
	cFile := MV_PAR10
	
	If Empty(cFile)
		cFile := cGetFile(, OemToAnsi(STR0010))  //"Selecione Arquivo"
	EndIf
	
	If Empty(cFile)
		Return .F.
	EndIf
	
	&mvRet := cFile
	
	If oWnd != Nil
		GetdRefresh()
	EndIf
	
Return .T.


/*/{Protheus.doc} GetMarc
Busca as marcações do período informado nas tabelas SP8 e SPG
@type  Static Function
@author Cícero Alves
@since 14/03/2023
@param aMarcacoes, Array, Array onde serão carregadas as marcações - Deve ser passado por referência
@param cFilFunc, Caractere, Filial do funcionário
@param cMatFunc, Caractere, Matrícula do funcionário
@param dDataIni, Data, Data inicial para busca das marcações
@param dDataFim, Data, Data final para busca das marcações
/*/
Static Function GetMarc(aMarcacoes, cFilFunc, cMatFunc, dDataIni, dDataFim)
	
	Local cAliasMarc	:= GetNextAlias()
	Local lFuso671		:= SP8->(ColumnPos("P8_FUSO")) > 0
	Local lCCTREP		:= SP8->(ColumnPos("P8_CCTREP")) > 0
	Local cCposP8		:= ""
	Local cCposPG		:= ""
	Local cWhereSP8		:= ""
	Local cWhereSPG		:= ""
	
	Default aMarcacoes := {} 
	Default cFilFunc := "" 
	Default cMatFunc := ""
	Default dDataIni := cToD("")
	Default dDataFim := cToD("")
	
	cCposP8 += If(lFuso671, ", P8_FUSO", "")
	cCposP8 += If(lCCTREP, ", P8_CCTREP", "")
	cCposP8 := "%" + cCposP8 + "%"
	
	cCposPG += If(lFuso671, ", PG_FUSO", "")
	cCposPG += If(lCCTREP, ", PG_CCTREP", "")
	cCposPG := "%" + cCposPG + "%"
	
	cWhereSP8 := If(!Empty(MV_PAR02), " AND " + StrTran(MV_PAR02, "RA_CC", "P8_CC"), "") 			// Centros de Custo
	cWhereSP8 += If(!Empty(MV_PAR03), " AND " + StrTran(MV_PAR03, "RA_TNOTRAB", "P8_TURNO"), "")	// Turnos
	cWhereSP8 := "%" + cWhereSP8 + "%"
	cWhereSPG := StrTran(cWhereSP8, "P8_", "PG_")
	
	BeginSQL ALIAS cAliasMarc
		COLUMN P8_DATA AS DATE
		SELECT P8_FILIAL, P8_MAT, P8_DATA, P8_HORA, P8_ORDEM, P8_RELOGIO, P8_TPMARCA, P8_NUMREP, P8_TPMCREP, P8_TIPOREG, P8_MOTIVRG, P8_FILORG, R_E_C_N_O_ RECNO %Exp:cCposP8%
		FROM %Table:SP8% SP8 
		WHERE
		P8_FILIAL = %Exp:cFilFunc% AND 
		P8_MAT = %Exp:cMatFunc% AND 
		(P8_DATAAPO BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)% 
		OR (P8_DATAAPO = '        ' AND P8_DATA BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)%)) 
		%Exp:cWhereSP8%
		AND SP8.%NotDel%
		UNION
		SELECT PG_FILIAL, PG_MAT, PG_DATA, PG_HORA, PG_ORDEM, PG_RELOGIO, PG_TPMARCA, PG_NUMREP, PG_TPMCREP, PG_TIPOREG, PG_MOTIVRG, PG_FILORG, R_E_C_N_O_ RECNO %Exp:cCposPG%
		FROM %Table:SPG% SPG 
		WHERE  PG_FILIAL = %Exp:cFilFunc% AND 
		PG_MAT = %Exp:cMatFunc% AND 
		(PG_DATAAPO BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)% 
		OR (PG_DATAAPO = '        ' AND PG_DATA BETWEEN %Exp:dToS(dDataIni)% AND %Exp:dToS(dDataFim)%))
		%Exp:cWhereSPG%
		AND SPG.%NotDel%
		ORDER BY P8_FILIAL, P8_MAT, P8_DATA, P8_HORA
	EndSQL
	
	While (cAliasMarc)->(!Eof())
		
		aAdd( aMarcacoes, Array(ELEMENTOS_AMARC))
		
		nLenMarc := Len(aMarcacoes)
		aMarcacoes[nLenMarc, AMARC_DATA   	] := (cAliasMarc)->P8_DATA			//01 - Data
		aMarcacoes[nLenMarc, AMARC_HORA   	] := (cAliasMarc)->P8_HORA			//02 - Hora
		aMarcacoes[nLenMarc, AMARC_ORDEM  	] := (cAliasMarc)->P8_ORDEM			//03 - Ordem
		aMarcacoes[nLenMarc, AMARC_RELOGIO	] := (cAliasMarc)->P8_RELOGIO		//11 - Relogio
		aMarcacoes[nLenMarc, AMARC_TIPOMARC	] := (cAliasMarc)->P8_TPMARCA		//12 - Tipo da Marcacao
		aMarcacoes[nLenMarc, AMARC_NUMREP	] := (cAliasMarc)->P8_NUMREP		//26 - Numero do REP
		aMarcacoes[nLenMarc, AMARC_TPMCREP	] := (cAliasMarc)->P8_TPMCREP		//27 - Tipo de Marcacao no REP
		aMarcacoes[nLenMarc, AMARC_TIPOREG	] := (cAliasMarc)->P8_TIPOREG		//28 - Tipo de Registro
		aMarcacoes[nLenMarc, AMARC_MOTIVRG	] := (cAliasMarc)->P8_MOTIVRG		//29 - Motivo da desconsideracao/inclusao
		aMarcacoes[nLenMarc, AMARC_FILORG	] := (cAliasMarc)->P8_FILORG		//32 - Filial Origem da marcacao
		
		If lFuso671
			aMarcacoes[nLenMarc, AMARC_FUSO	] := (cAliasMarc)->P8_FUSO			//41 - Fuso horário da marcação
		EndIf
		
		If lCCTREP
			aMarcacoes[nLenMarc, AMARC_CCTREP ] := (cAliasMarc)->P8_CCTREP		//42 - Cóigo da convenção coletiva da marção
		EndIf
		
		(cAliasMarc)->(dbSkip())
	EndDo
	
	(cAliasMarc)->(dbCloseArea())
	
Return
