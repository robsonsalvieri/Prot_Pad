#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#DEFINE SEP_FIELDS ";"
#DEFINE SEP_RECORDS CHR(30)
#DEFINE SEP_GROUP CHR(28)
#DEFINE NULL_VALUE CHR(31)

// Devido ao GFEPREPAREIN não inicializar as variáveis de ambiente para o WebService do Datasul, 
// as chamadas de função SuperGetMv deverão ser utilizadas em variáveis locais no início de cada função. 
// Portanto, não deve-se utilizar variáveis estáticas para esta chamada.

// Função responsavel por iniciar o ambiente e retornar o array com as informações
Function GFEWSInit()
	Local aPrepareIn
	Local cMsgIni := ""
	Local lReturn := .T.
	Local cEnvSource

	If Type("cEmpAnt")=="U"
		cPrepareIn := GetPvProfString(GetWebJob() , "GFEPREPAREIN" , "ERROR" , GetAdv97() )
		aPreparein := StrTokArr(cPreparein,",")

		IF aPreparein[1] == "ERROR"
			cMsgIni := "CHAVE [GFEPREPAREIN] NAO ENCONTRADA NA SECAO ["+GetWebJob()+"] DO ARQUIVO DE CONFIGURACAO ["+GetAdv97()+"]"
			lReturn := .F.
		EndIf

		if lReturn
			SetsDefault()
			// Armazena em memória que o ambiente foi carregado pelo GFEPREPAREIN (Não consome licença)
			PutGlbValue("GFE_WS_ENV_SOURCE", "GFEPREPAREIN")
			RpcsetType(3)
			If RpcSetEnv(aPrepareIn[1],aPrepareIn[2])
				SetModulo("SIGAGFE","GFE")
				GFEConout("INFO", "[WSGFE.GFEWSInit] Instância do WebService para uso padrão. ")
			Else
				cMsgIni := "GFE-FALHA INICILIZACAO AMBIENTE - OpenSM0()"
				lReturn := .F.
			EndIf
		EndIf
	Else
		cEnvSource := GetGlbValue("GFE_WS_ENV_SOURCE")
		// Verifica qual a origem de carregamento do ambiente PREPAREIN ou GFEPREPAREIN
		If Empty(cEnvSource)
			cPrepareIn := GetPvProfString(GetWebJob() , "GFEPREPAREIN" , "" , GetAdv97() )
			If Empty(cPrepareIn)
				PutGlbValue("GFE_WS_ENV_SOURCE", "PREPAREIN")
				GFEConout("INFO", "[WSGFE.GFEWSInit] Instância do WebService para uso de métodos customizado.")
			Else
				PutGlbValue("GFE_WS_ENV_SOURCE", "GFEPREPAREIN")
				GFEConout("INFO", "[WSGFE.GFEWSInit] Instância do WebService para uso padrão.")
			EndIf
		EndIF
	EndIf

	If !lReturn
		GFEConout("ERROR", "[WSGFE.GFEWSInit] Falha na inicialização do ambiente. Motivo: " + cMsgIni, .F.)
	EndIf

Return {lReturn,cMsgIni}

// Função que trata a string recebida em Code64 e retorna em array
Function GFEWSDados(cDados,lDecode)
	Local nCont, aDados 	:= {}
	Default lDecode 		:= .T.

	If lDecode
		cDados := Decode64(cDados)
	EndIf

	// Tratamento para campos com valor nulo
	cDados := UPPER(cDados) + ';'
	If SubStr(cDados, 1, 1)  == ";"
		cDados := "$" + cDados
	EndIf

	While ';;' $ cDados
		cDados := STRTRAN(cDados , ';;' , ';$;')
	EndDo

	aDados := STRTOKARR( cDados , ';' )
	While ASCAN(aDados, {|x| x == '$'}) != 0
		nCont := ASCAN(aDados, {|x| x == '$'})
		aDados[nCont] := ''
	EndDo

Return aDados

// Função responsável por realizar o tratamento de dados em array
Function GFEWSMultiDados(cDados, lDecode)
	Local nCont, nI, cRecord
	Local aDados := {}
	Default lDecode 			:= .T.

	If lDecode
		cDados := Decode64(cDados)
	EndIf

	// Tratamento para campos com valor nulo
	cDados := UPPER(cDados)
	aDados := STRTOKARR( cDados , SEP_RECORDS )

	For nI := 1 To Len(aDados)
		cRecord := aDados[nI]
		If SubStr(cRecord, 1, 1)  == SEP_FIELDS
			cRecord := NULL_VALUE + cRecord
		EndIf

		While SEP_FIELDS + SEP_FIELDS $ cRecord
			cRecord := STRTRAN(cRecord, SEP_FIELDS + SEP_FIELDS, SEP_FIELDS + NULL_VALUE + SEP_FIELDS)
		EndDo

		aDados[nI] := STRTOKARR(cRecord, SEP_FIELDS )
		While ASCAN(aDados[nI], {|x| x == NULL_VALUE}) != 0
			nCont := ASCAN(aDados[nI], {|x| x == NULL_VALUE})
			aDados[nI][nCont] := ''
		EndDo
	Next

Return aDados

// Busca o conteudo do parametro pela filial informada, caso esteja vazio, busca sem a filial.
Static Function BuscaParam(cParam,cFil,xPadrao)
	Local xConteudo

	xConteudo := GETNEWPAR(cParam, xPadrao ,cFil )

	If Empty(xConteudo)
		xConteudo := GETNEWPAR(cParam, "" )
	EndIf

Return xConteudo

//Função responsavel por incluir registros na tabela Grupo de emitente
Function GFEInsGU1(aDados)

	dbSelectArea('GU1')
	dbSetOrder(1)
	// Se encontrar registro, então Altera
	If dbSeek(xFilial('GU1')+PADR(Alltrim(aDados[1]) , TamSX3("GU1_CDGREM" )[1],''))
		RecLock('GU1',.F.)
		GU1->GU1_DSGREM := aDados[2]
		GU1->GU1_SIT    := '1'
		MsUnlock()
	Else
		//Senão cria  o registro
		RecLock('GU1',.T.)
		GU1->GU1_FILIAL := xFilial('GU1')
		GU1->GU1_CDGREM := Alltrim(aDados[1])
		GU1->GU1_DSGREM := Alltrim(aDados[2])
		GU1->GU1_SIT    := '1'
		GU1->GU1_TPGRP  := '1'
		GU1->GU1_ORIGEM := '2'
		MsUnlock()
	EndIf

Return

// Função responsavel por incluir registros na tabela cidades
Function GFEInsGU7(aDados)
	Local cTab := 'GU7' // Armazena a tabela
	Local cCDPAIS := ""
	Local cNRCID := ''

	dbSelectArea("SYA")
	dbSetOrder(2)
	If dbSeek(xFilial("SYA") + PADR(Alltrim(aDados[6]) , TamSX3("YA_DESCR" )[1],''))
		cCDPAIS := SYA->YA_CODGI
	Else
		cCDPAIS := Alltrim(aDados[4])
	EndIf

	// Verifica se não existe uma cidade com o mesmo codigo
	dbSelectArea("GU7")
	dbSetOrder(1)
	If !dbSeek( xFilial("GU7") + PADR(Alltrim(aDados[1]) , TamSX3("GU7_NRCID" )[1],'') )
		cNRCID := Alltrim(aDados[1])
	Else
		cNRCID := GETSXENUM("GU7","GU7_NRCID")
		ConfirmSx8()
	EndIf

	dbSelectArea("GU7")
	dbSetOrder(3)
	If !dbSeek( xFilial("GU7") + PADR(Alltrim(aDados[2]) , TamSX3("GU7_NMCID" )[1],'') + PADR(Alltrim(aDados[3]) , TamSX3("GU7_CDUF" )[1],''))

		If "'" $ aDados[2] //"tratamento para retirar apóstrofo do nome da cidade"
			aDados[2] := StrTran(aDados[2],"'"," ",1)
		EndIf

		//Senão cria  o registro
		RecLock(cTab,.T.)
		GU7->GU7_FILIAL := xFilial(cTab)
		GU7->GU7_NRCID  := cNRCID
		GU7->GU7_NMCID  := aDados[2]
		GU7->GU7_CDUF   := Alltrim(aDados[3])
		GU7->GU7_CDPAIS := cCDPAIS
		GU7->GU7_SIGLA  := Alltrim(aDados[5])
		GU7->GU7_SIT    := '1'
		MsUnlock()
	Else
		// Ativa novamente a cidade
		If GU7->GU7_NMCID == PADR(Alltrim(aDados[2]) , TamSX3("GU7_NMCID" )[1],'') .And. GU7->GU7_CDUF == PADR(Alltrim(aDados[3]) , TamSX3("GU7_CDUF" )[1],'') .And. GU7->GU7_SIT == '2'
			RecLock(cTab,.F.)
			GU7->GU7_SIT := '1'
			MsUnlock()
		EndIf
	EndIf

Return

// Função responsavel por incluir registros na tabela unitizadores
Function GFEInsGUG(aDados)
	Local cTab := 'GUG' // Armazena a tabela

	dbSelectArea(cTab)
	// Se encontrar registro, então Altera
	If dbSeek(xFilial(cTab)+PADR(Alltrim(aDados[1]) , TamSX3("GUG_CDUNIT" )[1],''))
		RecLock(cTab,.F.)
		GUG->GUG_DSUNIT := aDados[2]
		GUG->GUG_TARA   := VAL(STRTRAN ( aDados[3] , "," , "."  ) )
		GUG->GUG_VOLUME := VAL(STRTRAN ( aDados[4] , "," , "."  ) )
		GUG->GUG_SIT    := '1'
		MsUnlock()
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GUG->GUG_FILIAL := xFilial(cTab)
		GUG->GUG_CDUNIT := Alltrim(aDados[1])
		GUG->GUG_DSUNIT := aDados[2]
		GUG->GUG_TARA   := VAL(STRTRAN ( aDados[3] , "," , "."  ) )
		GUG->GUG_VOLUME := VAL(STRTRAN ( aDados[4] , "," , "."  ) )
		GUG->GUG_SIT    := '1'
		MsUnlock()
	EndIf

Return

// Função responsavel por incluir registros na tabela Contas Contábeis
Function GFEInsGUE(aDados)
	Local cTab := 'GUE' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(xFilial(cTab)+PADR(Alltrim(aDados[1]) , TamSX3("GUE_CTACTB" )[1],''))  	//Se encontrar registro, então Altera
		RecLock(cTab,.F.)
		GUE->GUE_TITULO  := aDados[2]
		GUE->GUE_SIT     := '1'
		MsUnlock()
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GUE->GUE_FILIAL  := xFilial(cTab)
		GUE->GUE_CTACTB  := Alltrim(aDados[1])
		GUE->GUE_TITULO  := aDados[2]
		GUE->GUE_SIT     := '1'
		MsUnlock()
	EndIf

Return

// Função responsavel por incluir registros na tabela Centro de Custo
Function GFEInsGUH(aDados)
	Local cTab := 'GUH' // Armazena a tabela

	dbSelectArea(cTab)
	// Se encontrar registro, então Altera
	If dbSeek(xFilial(cTab)+PADR(Alltrim(aDados[1]) , TamSX3("GUH_CCUSTO" )[1],''))
		RecLock(cTab,.F.)
		GUH->GUH_DESC   := aDados[2]
		GUH->GUH_SIT    := '1'
		MsUnlock()
	Else
		//Senão cria  o registro
		RecLock(cTab,.T.)
		GUH->GUH_FILIAL := xFilial(cTab)
		GUH->GUH_CCUSTO := aDados[1]
		GUH->GUH_DESC   := aDados[2]
		GUH->GUH_SIT    := '1'
		MsUnlock()
	EndIf

Return

// Função responsavel por incluir registros na tabela Romaneios
Function GFEInsGWN(aDados)
	Local cTab := 'GWN' // Armazena a tabela
	Local cPlaca := ""
	Local cMotorista := ""
	Local cOBS := ""
	Local cSkip
	Local cGU8CdTpOp := ""

	// Início Ponto de Entrada Procomp
	If ExistBlock("GFEXWS03")
		cSkip := ExecBlock("GFEXWS03",.f.,.f.,{aDados})
		If cSkip == 'ok'
			Return
		EndIF
	EndIf
	// Fim Ponto de Entrada Procomp


	// Busca se a placa pertence a um veiculo do sistema
	DbSelectArea("GU8")
	dbSetOrder(2)
	If DbSeek(xFilial("GU8")+ PADR(Alltrim(aDados[4]), TamSX3("GU8_PLACA")[1],'') )
		cPlaca  := Alltrim(aDados[4])
		If GFXCP12117("GU8_CDTPOP")
			cGU8CdTpOp := GU8->GU8_CDTPOP
		EndIf
	Else
		if Alltrim(aDados[4]) != ""
			cOBS := "PLACA: " +Transform(Alltrim(aDados[4]), PESQPICT("GWN","GWN_PLACAD"))
		EndIf
	EndIf

	// Busca se o motorista está cadastrado no sistema
	DbSelectArea("GUU")
	dbSetOrder(3)
	If DbSeek(xFilial("GUU")+ PADR(Alltrim(aDados[5]), TamSX3("GUU_NMMTR")[1],''))
		cMotorista := GUU->GUU_CDMTR
	Else
		if Alltrim(aDados[5]) != ""
			cOBS := cOBS + CRLF + "MOTORISTA: " + Alltrim(aDados[5])
		EndIf
	Endif

	dbSelectArea(cTab)
	// Se encontrar registro, então Altera
	If dbSeek(	PADR(Alltrim(aDados[1]) , TamSX3("GWN_FILIAL" )[1],'') + ;
			PADR(Alltrim(aDados[2]) , TamSX3("GWN_NRROM" )[1],''))
		If GWN->GWN_SIT == "1"
			RecLock(cTab,.F.)
			GWN->GWN_CDTRP   := Alltrim(aDados[3])
			GWN->GWN_OBS     := cOBS
			GWN->GWN_PLACAD  := cPlaca
			GWN->GWN_CDMTR   := cMotorista

			If GWN->GWN_CALC == "1"
				GWN->GWN_CALC := '4'
			EndIf

			If Len(aDados) >= 6
				GWN->GWN_CDTPVC := aDados[6]
			EndIf

			If Len(aDados) >= 7
				GWN->GWN_DTIMPL := StoD(aDados[7])
			EndIf

			If !Empty(cGU8CdTpOp) .And. AllTrim(cGU8CdTpOp) != GWN->GWN_CDTPOP // Tipo de operação do romaneio e veículo são incompatíveis
				GWN->GWN_CDTPOP := cGU8CdTpOp
			EndIf
			MsUnlock()

			If GWN->GWN_CALC == '4' .And. !Empty(GWN->GWN_VIAGEM)
				GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM)
			EndIf
		EndIf
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GWN->GWN_FILIAL  := Alltrim(aDados[1])
		GWN->GWN_NRROM   := Alltrim(aDados[2])
		GWN->GWN_CDTRP   := Alltrim(aDados[3])
		If !Empty(cGU8CdTpOp) // Tipo de operação do veículo prevalece sobre o tipo do romaneio
			GWN->GWN_CDTPOP := cGU8CdTpOp
		Else
			GWN->GWN_CDTPOP  := BuscaParam("MV_TPOPEMB",Alltrim(aDados[1]),"")
		EndIf
		GWN->GWN_HRIMPL  := TIME()
		GWN->GWN_OBS     := cOBS
		GWN->GWN_PLACAD  :=  cPlaca
		GWN->GWN_CDMTR   := cMotorista
		GWN->GWN_SIT     := '1'
		GWN->GWN_CALC    := '2'
		GWN->GWN_AGRUP   := '2'
		GWN->GWN_BLOQPF  := '2'
		GWN->GWN_ORI     := '1'
		GWN->GWN_USUIMP  := USRRETNAME(RETCODUSR())
		If Len(aDados) >= 6
			GWN->GWN_CDTPVC := aDados[6]
		EndIf
		If Len(aDados) >= 7
			GWN->GWN_DTIMPL := StoD(aDados[7])
		Else
			GWN->GWN_DTIMPL  := DATE()
		EndIf
		MsUnlock()
	EndIf

	// Ponto de entrada permitirá gravar dados em campos específicos do registro de
	// Romaneio através da rotina de webservice de importação de romaneios
	If ExistBlock("GFEYWS01")
		ExecBlock("GFEYWS01",.F.,.F.,{aDados})
	EndIf

Return

// Função responsavel por incluir registros na tabela Emitentes
Function GFEInsGU3(aDados)
	Local cTab := 'GU3' // Armazena a tabela
	Local cNRCID := ''
	Local nLenADados := Len(aDados)

	dbSelectArea("GU7")
	dbSetOrder(3)
	If dbSeek( xFilial("GU7") + PADR(Alltrim(aDados[26]) , TamSX3("GU7_NMCID" )[1],'') + PADR(Alltrim(aDados[27]) , TamSX3("GU7_CDUF" )[1],''))
		cNRCID := GU7->GU7_NRCID
	Else
		cNRCID := Alltrim(aDados[14])
	EndIf

	dbSelectArea(cTab)
	// Se encontrar registro, então Altera
	If dbSeek(xFilial(cTab)+ PADR(Alltrim(aDados[1]) , TamSX3("GU3_CDEMIT" )[1],'') )
		RecLock(cTab,.F.)
		GU3->GU3_NMEMIT   := aDados[2]
		GU3->GU3_NMFAN	  := aDados[2]
		GU3->GU3_NMABRV   := aDados[3]
		GU3->GU3_NATUR    := Alltrim(aDados[4])
		GU3->GU3_CDGREM   := Alltrim(aDados[5])
		GU3->GU3_DTIMPL   := If(!empty(StoD(aDados[6])),StoD(aDados[6]),DDATABASE)
		GU3->GU3_TRANSP   := Alltrim(aDados[7])
		GU3->GU3_CLIEN    := Alltrim(aDados[8])
		GU3->GU3_FORN     := Alltrim(aDados[9])
		GU3->GU3_AUTON    := Alltrim(aDados[10])
		GU3->GU3_ENDER    := aDados[11]
		GU3->GU3_BAIRRO   := aDados[12]
		GU3->GU3_CEP      := Alltrim(aDados[13])
		GU3->GU3_NRCID    := cNRCID
		GU3->GU3_IDFED    := Alltrim(aDados[15])
		GU3->GU3_IE       := Alltrim(aDados[16])
		GU3->GU3_IM       := Alltrim(aDados[17])
		GU3->GU3_CXPOS    := Alltrim(aDados[18])
		GU3->GU3_EMAIL    := Alltrim(aDados[19])
		GU3->GU3_FONE1    := Alltrim(aDados[20])
		GU3->GU3_RAMAL1   := VAL( SUBSTRING( aDados[21],1,4 ))
		GU3->GU3_FAX      := Alltrim(aDados[22])
		GU3->GU3_WSITE    := Alltrim(aDados[23])
		GU3->GU3_ACAOVC   := If(!Empty(aDados[24]),aDados[24],GU3->GU3_ACAOVC)
		GU3->GU3_CTE      := If(!Empty(aDados[25]),aDados[25],GU3->GU3_CTE)
		If Len(aDados) >= 30
			GU3->GU3_SIT := Alltrim(aDados[30])
		Else
			GU3->GU3_SIT := "1"
		EndIf
		If Alltrim(aDados[28]) == "2" .Or. GU3->GU3_CONICM != "3"
			GU3->GU3_CONICM   := Alltrim(aDados[28])
		EndIf
		If nLenADados >= 29
			GU3->GU3_CDTERP   := Alltrim(aDados[29])
		EndIf
		If GFEWSFUNLG() .And. SuperGetMv("MV_EMITMP",.F.,"1") == '1'
			GFEWSEmit()
		EndIf
		GU3->(MsUnlock())
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GU3->GU3_FILIAL   := xFilial(cTab)
		GU3->GU3_CDEMIT   := Alltrim(aDados[1])
		GU3->GU3_NMEMIT   := aDados[2]
		GU3->GU3_NMFAN	  := aDados[2]
		GU3->GU3_NMABRV   := Alltrim(aDados[3])
		GU3->GU3_NATUR    := Alltrim(aDados[4])
		GU3->GU3_CDGREM   := Alltrim(aDados[5])
		GU3->GU3_DTIMPL   := If(!empty(StoD(aDados[6])),StoD(aDados[6]),DDATABASE)
		GU3->GU3_ORIGEM   := '2'
		If Len(aDados) >= 30
			GU3->GU3_SIT := Alltrim(aDados[30])
		Else
			GU3->GU3_SIT := "1"
		EndIf
		GU3->GU3_TRANSP   := Alltrim(aDados[7])
		GU3->GU3_CLIEN    := Alltrim(aDados[8])
		GU3->GU3_FORN     := Alltrim(aDados[9])
		GU3->GU3_AUTON    := Alltrim(aDados[10])
		GU3->GU3_ENDER    := Alltrim(aDados[11])
		GU3->GU3_BAIRRO   := aDados[12]
		GU3->GU3_CEP      := Alltrim(aDados[13])
		GU3->GU3_NRCID    := cNRCID
		GU3->GU3_IDFED    := Alltrim(aDados[15])
		GU3->GU3_EMFIL    := A030CLIFIL(GU3->GU3_IDFED)
		GU3->GU3_TPTRIB   := '1'
		GU3->GU3_CONICM   := Alltrim(aDados[28])
		GU3->GU3_CONISS   := Iif( GU3->GU3_NATUR == "J" .Or. GU3->GU3_NATUR == "j", "1", "2") //tratamento para o caso de ser integrado um emitente pessoa física.
		GU3->GU3_IE       := Alltrim(aDados[16])
		GU3->GU3_IM       := Alltrim(aDados[17])
		GU3->GU3_CXPOS    := Alltrim(aDados[18])
		GU3->GU3_EMAIL    := Alltrim(aDados[19])
		GU3->GU3_FONE1    := Alltrim(aDados[20])
		GU3->GU3_RAMAL1   := VAL( SUBSTRING( aDados[21],1,4 ))
		GU3->GU3_FAX      := Alltrim(aDados[22])
		GU3->GU3_WSITE    := Alltrim(aDados[23])
		GU3->GU3_MVTERC   := '2'
		GU3->GU3_FRCOMB   := '2'
		GU3->GU3_MAXDOC   := 999
		GU3->GU3_AGRDOC   := '2'
		GU3->GU3_ACOCO    := '1'
		GU3->GU3_PFFIL    := '2'
		GU3->GU3_PFUF     := '2'
		GU3->GU3_PFCLAS   := '2'
		GU3->GU3_PFTPFR   := '2'
		GU3->GU3_PFNORM   :=  1
		GU3->GU3_PFCPVL   :=  1
		GU3->GU3_PFCPIC   :=  1
		GU3->GU3_PFDEV    :=  1
		GU3->GU3_PFREDE   :=  1
		GU3->GU3_PFREEN   :=  1
		GU3->GU3_PFSERV   :=  1
		GU3->GU3_ENTOBR   := '2'
		GU3->GU3_CALCVC   := '2'
		GU3->GU3_ACAOVC   := If(!Empty(aDados[24]),aDados[24],'2')
		GU3->GU3_TPFREQ   := '0'
		GU3->GU3_SEGUN    := '2'
		GU3->GU3_TERCA    := '2'
		GU3->GU3_QUARTA   := '2'
		GU3->GU3_QUINTA   := '2'
		GU3->GU3_SEXTA    := '2'
		GU3->GU3_ICMPRE   := '2'
		GU3->GU3_SBTRIB   := '2'
		GU3->GU3_APUICM   := '1'
		GU3->GU3_APUISS   := '1'
		If GFXCP1212410("GU3_APISSO")
			GU3->GU3_APISSO   := '1'
		EndIf
		GU3->GU3_CTE      := If(!Empty(aDados[25]),aDados[25],'2')
		GU3->GU3_FATAUT   := CriaVar("GU3_FATAUT",.T.) /* Busca o Inicializador Padrão do Dicionário. */
		GU3->GU3_CAUTPF   := '2'
		GU3->GU3_PFCALC   := '2'
		GU3->GU3_MODAL    := '1'
		If GU3->GU3_TRANSP == '1'
			GU3->GU3_CATTRP := '1'
		ElseIf GU3->GU3_AUTON == '1'
			GU3->GU3_CATTRP := '2'
		Else
			GU3->GU3_CATTRP := '8'
		EndIf
		If nLenADados >= 29
			GU3->GU3_CDTERP   := Alltrim(aDados[29])
		EndIf
		If GFEWSFUNLG() .And. SuperGetMv("MV_EMITMP",.F.,"1") == '1'
			GFEWSEmit()
		EndIf
		GU3->(MsUnlock())
	EndIf

Return

// Função responsavel por incluir registros na tabela tipo de veículo
Function GFEInsGV3(aDados)

	Local cTab := 'GV3' // Armazena a tabela

	dbSelectArea(cTab)
	dbSetOrder(1)

	// Se encontrar registro, então Altera
	If dbSeek(xFilial(cTab)+ PADR(Alltrim(aDados[1]) , TamSX3("GV3_CDTPVC" )[1],'') )
		RecLock(cTab,.F.)
		// Senão cria  o registro
	Else
		RecLock(cTab,.T.)
		GV3->GV3_CDTPVC 	:= Alltrim(aDados[1])
		// Campos com conteúdo padrão
		GV3->GV3_EIXOS 	:= 2
		GV3->GV3_POSCOM 	:= "1"
	EndIf

	GV3->GV3_DSTPVC := Alltrim(aDados[2])
	GV3->GV3_CARGUT := Round(Val( StrTran( aDados[3], ",", "." ) ),TamSX3("GV3_CARGUT")[2])
	GV3->GV3_VOLUT  := Round(Val( StrTran( aDados[4], ",", "." ) ),TamSX3("GV3_VOLUT" )[2])
	GV3->GV3_SIT    := "1"
	MsUnlock()

Return

// Função responsavel por alterar registros na tabela de fatura de frete
Function GFEInsGW6(aDados)

	Local cTab := 'GW6' // Armazena a tabela

	(cTab)->(dbSelectArea(cTab))
	(cTab)->(dbSetOrder(1)) //GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+DTOS(GW6_DTEMIS)

	If (cTab)->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GW6_FILIAL")[1],'') +;
			PADR(Alltrim(aDados[2]) , TamSX3("GW6_EMIFAT")[1],'') +;
			PADR(Alltrim(aDados[3]) , TamSX3("GW6_SERFAT")[1],'') +;
			PADR(Alltrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1],'')  +;
			aDados[5] ) )

		RecLock(cTab,.F.)
		If aDados[6] = "99991231"
			GW6->GW6_DTLIQD := CToD("  /  /    ")
		Else
			GW6->GW6_DTLIQD := StoD(aDados[6])
		EndIf
		MsUnlock()
	EndIf

Return

Function GFEInsGXT(aDados)

	Local cTab := ''
	Local cFilGXT := ''

	If GFXCP12127("GXT_NRCT")

		cTab := 'GXT' // Armazena a tabela
		cFilGXT := PADR('' , TamSX3("GXT_FILIAL" )[1],'')

		// verifica se a tabela está como exclusiva ou compartilhada
		If FWModeAccess("GXT",1) == "E"
			cFilGXT := PADR(Alltrim(aDados[1]) , TamSX3("GXT_FILIAL" )[1],'')
		EndIf

		(cTab)->(dbSetOrder(1))

		// Se encontrar registro Altera
		If (cTab)->(dbSeek(cFilGXT +;
				PADR(Alltrim(aDados[2]) , TamSX3("GXT_NRCT" )[1]  ,'')))

			RecLock(cTab,.F.)
		Else
			RecLock(cTab,.T.)
			GXT->GXT_FILIAL := cFilGXT
			GXT->GXT_NRCT   := PADR(Alltrim(aDados[2]), TamSX3("GXT_NRCT" )[1],'')

		EndIf

		GXT->GXT_DTCT   := StoD(Alltrim(aDados[3]))
		GXT->GXT_CDTRP  := Alltrim(aDados[4])
		GXT->GXT_USUAR  := "Integração ERP Datasul"
		GXT->GXT_DTIRET := StoD(Alltrim(aDados[5]))
		GXT->GXT_DTFRET := StoD(Alltrim(aDados[6]))
		GXT->GXT_SIT    := Alltrim(aDados[7])
		GXT->GXT_VLLIM  := VAL(STRTRAN( aDados[8] , "," , "."  ))
		GXT->GXT_VLSDO  := GXT->GXT_VLLIM - VAL(STRTRAN( aDados[9] , "," , "."  ))
		GXT->GXT_TOMFRT := "1"

		GXT->(MsUnlock())

	Endif


Return


// Função responsavel por incluir registros na tabela Contatos
Function GFEInsGU2(aDados)
	Local cTab := 'GU2' // Armazena a tabela

	// Se encontrar registro, então Altera
	dbSelectArea(cTab)
	If dbSeek(	 xFilial(cTab) +;
			PADR(Alltrim(aDados[1]) , TamSX3("GU2_CDEMIT" )[1],'') + ;
			PADR(Alltrim(aDados[2]) , TamSX3("GU2_SEQ" )[1]   ,''))
		RecLock(cTab,.F.)
		GU2->GU2_NOME 	:= aDados[3]
		GU2->GU2_SETOR 	:= aDados[4]
		GU2->GU2_CARGO 	:= aDados[5]
		GU2->GU2_EMAIL 	:= Alltrim(aDados[6])
		GU2->GU2_FONE1 	:= Alltrim(aDados[7])
		GU2->GU2_RAMAL1 := VAL( SUBSTRING( aDados[8],1,4 ))
		GU2->GU2_FAX 	:= Alltrim(aDados[9])
		GU2->GU2_RAMALF := VAL(aDados[10])
		GU2->GU2_OBS 	:= aDados[11]
		GU2->GU2_SIT 	:= '1'
		MsUnlock()
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GU2->GU2_FILIAL 	:= xFilial(cTab)
		GU2->GU2_CDEMIT 	:= Alltrim(aDados[1])
		GU2->GU2_SEQ 		:= Alltrim(aDados[2])
		GU2->GU2_SIT 		:= '1'
		GU2->GU2_NOME 	:= aDados[3]
		GU2->GU2_SETOR 	:= aDados[4]
		GU2->GU2_CARGO 	:= aDados[5]
		GU2->GU2_EMAIL 	:= Alltrim(aDados[6])
		GU2->GU2_FONE1 	:= Alltrim(aDados[7])
		GU2->GU2_RAMAL1 	:= VAL( SUBSTRING( aDados[8],1,4 ))
		GU2->GU2_FAX 		:= Alltrim(aDados[9])
		GU2->GU2_RAMALF 	:= VAL(aDados[10])
		GU2->GU2_OBS 		:= aDados[11]
		MsUnlock()
	EndIf

Return

// Função responsavel por incluir registros na tabela Documentos de Carga
Function GFEInsGW1(aDados)
	Local cTab 			:= 'GW1' // Armazena a tabela
	Local cNRCID		:= ""
	Local nLenADados	:= Len(aDados)
	Local cDtIntFat		:= SuperGetMV("MV_GFEI20", .F., "2")	// SAMSUNG
	Local lRet 			:= ''
	Local cFilBkp 		:= cFilAnt
	Local cGWUAux		:= ""
	Local cGU3Aux		:= ""
	Local lGFEXWS19		:= ExistBlock("GFEXWS19")
	Local cNrCidOri		:= ""

	cFilAnt := PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'')

	// Início Ponto de Entrada Procomp
	If ExistBlock("GFEXWS04")
		lRet := ExecBlock("GFEXWS04",.f.,.f.,{aDados})
		If lRet = 'ok'
			Return
		Endif
	EndIf
	// Fim Ponto de Entrada Procomp

	GU7->(dbSetOrder(3))
	If GU7->(dbSeek(xFilial("GU7") + PADR(Alltrim(aDados[24]),TamSX3("GU7_NMCID" )[1],'') + PADR(Alltrim(aDados[25]),TamSX3("GU7_CDUF" )[1],'')))
		cNRCID := GU7->GU7_NRCID
	Else
		cNRCID := Alltrim(aDados[20])
	EndIf

	GWU->(dbSetOrder(1))
	GWU->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GWU_FILIAL" )[1],'') + ;
		PADR(Alltrim(aDados[2]) , TamSX3("GWU_CDTPDC" )[1],'') + ;
		PADR(Alltrim(aDados[3]) , TamSX3("GWU_EMISDC" )[1],'') + ;
		PADR(Alltrim(aDados[4]) , TamSX3("GWU_SERDC" )[1] ,'') + ;
		PADR(Alltrim(aDados[5]) , TamSX3("GWU_NRDC" )[1] ,'')  + ;
		"01"))
	While !GWU->(EoF()) .And. GWU->GWU_FILIAL == PADR(Alltrim(aDados[1]) , TamSX3("GWU_FILIAL" )[1],'');
			.And. GWU->GWU_CDTPDC == PADR(Alltrim(aDados[2]) , TamSX3("GWU_CDTPDC" )[1],'');
			.And. GWU->GWU_EMISDC == PADR(Alltrim(aDados[3]) , TamSX3("GWU_EMISDC" )[1],'');
			.And. GWU->GWU_SERDC  == PADR(Alltrim(aDados[4]) , TamSX3("GWU_SERDC" )[1],'');
			.And. GWU->GWU_NRDC   == PADR(Alltrim(aDados[5]) , TamSX3("GWU_NRDC" )[1],'')

		If GWU->GWU_SEQ == "01"
			If lGFEXWS19
				cNrCidOri := ExecBlock("GFEXWS19",.F.,.F.,{xFilial("GU3"),Alltrim(aDados[16])})
				If ValType(cNrCidOri) == 'C' .And. !Empty(cNrCidOri)
					RecLock("GWU",.F.)
					GWU->GWU_NRCIDO := cNrCidOri
					GWU->(MsUnlock())
				EndIf
			Else
				cGU3Aux := GetNextAlias()

				BeginSQL Alias cGU3Aux
					SELECT GU3.GU3_NRCID
					FROM %Table:GU3% GU3
					WHERE GU3.GU3_FILIAL = %xFilial:GU3%
					AND GU3.GU3_CDEMIT = %Exp:Alltrim(aDados[16])%
					AND GU3.%NotDel%
				EndSQL

				If (cGU3Aux)->(!EoF())
					RecLock("GWU",.F.)
					GWU->GWU_NRCIDO := (cGU3Aux)->GU3_NRCID
					GWU->(MsUnlock())
				EndIf

				(cGU3Aux)->(dbCloseArea())
			EndIf
		Else
			cGWUAux := GetNextAlias()

			BeginSQL Alias cGWUAux
				SELECT GWU.GWU_NRCIDD
				FROM %Table:GWU% GWU
				WHERE GWU.GWU_FILIAL = %Exp:GWU->GWU_FILIAL%
				AND GWU.GWU_CDTPDC = %Exp:GWU->GWU_CDTPDC%
				AND GWU.GWU_EMISDC = %Exp:GWU->GWU_EMISDC%
				AND GWU.GWU_SERDC = %Exp:GWU->GWU_SERDC%
				AND GWU.GWU_NRDC = %Exp:GWU->GWU_NRDC%
				AND GWU.GWU_SEQ = %Exp:StrZero(Val(GWU->GWU_SEQ) - 1, 2)%
				AND GWU.%NotDel%
			EndSQL

			If (cGWUAux)->(!EoF())
				RecLock("GWU",.F.)
				GWU->GWU_NRCIDO := (cGWUAux)->GWU_NRCIDD
				GWU->(MsUnlock())
			EndIf

			(cGWUAux)->(dbCloseArea())
		EndIf

		GWU->(dbSkip())
	EndDo

	(cTab)->(dbSetOrder(1))
	If !(cTab)->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'') +;
			PADR(Alltrim(aDados[2]) , TamSX3("GW1_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GW1_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GW1_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GW1_NRDC" )[1]  ,'')))
		// Cria  o registro
		RecLock(cTab,.T.)
		GW1->GW1_FILIAL    := Alltrim(aDados[1])
		GW1->GW1_CDTPDC    := Alltrim(aDados[2])
		GW1->GW1_EMISDC    := Alltrim(aDados[3])
		GW1->GW1_SERDC     := Alltrim(aDados[4])
		GW1->GW1_NRDC      := Alltrim(aDados[5])
		GW1->GW1_DTEMIS    := StoD(Alltrim(aDados[6]))
		GW1->GW1_CDDEST    := Alltrim(aDados[7])
		GW1->GW1_SIT       := Alltrim(aDados[8])
		GW1->GW1_DTIMPL    := DDATABASE
		GW1->GW1_TPFRET    := Alltrim(aDados[10])
		GW1->GW1_NRROM     := Alltrim(aDados[11])
		GW1->GW1_DSESP     := Alltrim(aDados[12])
		GW1->GW1_REGCOM    := Alltrim(aDados[13])
		GW1->GW1_REPRES    := Alltrim(aDados[14])
		GW1->GW1_USO       := Alltrim(aDados[15])
		GW1->GW1_CDREM     := Alltrim(aDados[16])
		GW1->GW1_ENTEND    := Alltrim(aDados[17])
		GW1->GW1_ENTBAI    := Alltrim(aDados[18])
		GW1->GW1_ENTCEP    := Alltrim(aDados[19])
		GW1->GW1_ENTNRC    := cNRCID
		GW1->GW1_DTPENT    := StoD(Alltrim(aDados[21]))
		GW1->GW1_DTPSAI    := StoD(Alltrim(aDados[22]))
		GW1->GW1_HRPSAI    := If(len(Alltrim(aDados[23]) ) == 4 , '0' + Alltrim(aDados[23]), Alltrim(aDados[23]))
		GW1->GW1_ORIGEM    := '2'  // ERP
		GW1->GW1_HRIMPL    := TIME()
		GW1->GW1_ENVEDI    := '2'
		GW1->GW1_ICMSDC    := '1'
		GW1->GW1_HRPENT    := TIME()
		GW1->GW1_AUTSEF    := Alltrim(aDados[26])
		GW1->GW1_DANFE     := Alltrim(aDados[27])
		If Len(aDados) >= 32
			GW1->GW1_QTVOL	:= Val(Alltrim(aDados[32]))
		EndIf
		If  GfeVerCmpo({"GW1_ROMTV"})
			GW1->GW1_ROMTV	 := If(nLenADados >= 28, Alltrim(aDados[28]), '')
			GW1->GW1_ROMCF	 := If(nLenADados >= 29, Alltrim(aDados[29]), '')
			GW1->GW1_ROMTO	 := If(nLenADados >= 30, Alltrim(aDados[30]), '')
		Endif
		If GfeVerCmpo({"GW1_SITFT"})
			GW1->GW1_SITFT     := '1'
		Endif
		If GFXCP12117("GW1_SITFRE") == .T.
			If SuperGetMV('MV_INTFRE',.F.,'1') == '2'
				GW1->GW1_SITFRE     := '1'
			Else
				GW1->GW1_SITFRE     := '6'
			EndIf
		EndIf
		// SAMSUNG - Na criação do registro da GW1 - Atribui ao campo GW1_SITFT2 o valor 1 (Não enviado)
		If GfeVerCmpo({"GW1_SITFT2"})
			If cDtIntFat == '1'
				GW1->GW1_SITFT2 := '1'	// Não Enviado - FWFldGet("MV_GFEI20") = '1=Automática': Na criação do registro da GW1 - Atribui ao campo GW1_SITFT2 o valor 1 (Não enviado)
			ElseIf cDtIntFat == '2'
				GW1->GW1_SITFT2 := '6'	// Não se aplica - FWFldGet("MV_GFEI20") = '2=Não integrar': Atribui ao campo GW1_SITFT2 o valor 6 (Não se aplica).
			EndIf
		Endif
		// Valor inicial (vazio) no Datasul = 0, no GFE = vazio
		If AllTrim(GW1->GW1_NRROM) == '0'
			GW1->GW1_NRROM := ''
		EndIf
		If Len(aDados) >= 33 .and. GFXCP12117("GW1_PEDCLI") == .T.
			GW1->GW1_PEDCLI    := Alltrim(aDados[33])
		EndIf
		// Atribui para filial do romaneio a filial do documento de carga
		If !Empty(GW1->GW1_NRROM) .And. GFXCP1212210("GW1_FILROM")
			GW1->GW1_FILROM := GW1->GW1_FILIAL
		EndIf
		// Início Ponto de Entrada Procomp
		If ExistBlock("GFEXWS01")
			ExecBlock("GFEXWS01",.F.,.F.,{nLenADados,aDados})
		EndIf
		// Fim Ponto de Entrada Procomp
		// Início Ponto de Entrada LordPlastics
		If ExistBlock("GFEYWS03")
			ExecBlock("GFEYWS03",.F.,.F.,{aDados})
		EndIf
		(cTab)->(MsUnlock())

		// Verificando numeração do romaneio
		If !Empty(GW1->GW1_NRROM)
			If GfeVerCmpo({"GW1_ROMTV"})
				dbSelectArea("GWN")
				dbSetOrder(1)
				If dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM)
					RecLock("GWN", .F.)
					If !Empty(GW1->GW1_ROMCF)
						GWN->GWN_CDCLFR := GW1->GW1_ROMCF
					EndIf
					If !Empty(GW1->GW1_ROMTV)
						GWN->GWN_CDTPVC := GW1->GW1_ROMTV
					EndIf
					If !Empty(GW1->GW1_ROMTO)
						GWN->GWN_CDTPOP	:= PadR(AllTrim(GW1->GW1_ROMTO),10)
					EndIf
					GWN->(MsUnlock())
				EndIf
			EndIf
		EndIf

		// Execução Automática da função de liberação do documento de carga
		If Len(aDados) >= 31
			If Alltrim(aDados[31]) == 'Y'
				GFEX101REG()
			EndIf
		EndIf
	Else
		// Modifica  o registro
		If Empty(GW1->GW1_DANFE)
			RecLock(cTab,.F.)
			GW1->GW1_AUTSEF    := Alltrim(aDados[26])
			GW1->GW1_DANFE     := Alltrim(aDados[27])
			(cTab)->(MsUnlock())
		EndIf
	EndIf

	If ExistBlock("GFEYWS02")
		ExecBlock("GFEYWS02",.F.,.F.,{aDados})
	EndIf

	cFilant := cFilBkp
Return

// Função responsavel por incluir registros na tabela Trechos do Documentos de Carga
Function GFEInsGWU(aDados)
	Local cTab 		:= "GWU" // Armazena a tabela
	Local cNRCID 	:= ""
	Local cNRCIDO	:= ""
	Local cSeq	   	:= AllTrim(aDados[6])

	cSeq 			:= StrZero(Val(cSeq), 2)

	GU7->(dbSetOrder(3))
	If GU7->(dbSeek( xFilial("GU7") + PADR(Alltrim(aDados[10]) , TamSX3("GU7_NMCID" )[1],'') + PADR(Alltrim(aDados[11]) , TamSX3("GU7_CDUF" )[1],'')))
		cNRCID := GU7->GU7_NRCID
	Else
		cNRCID := Alltrim(aDados[8])
	EndIf

	(cTab)->(dbSetOrder(1))
	If (cTab)->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GWU_FILIAL" )[1],'') +;
			PADR(Alltrim(aDados[2]) , TamSX3("GWU_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GWU_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GWU_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GWU_NRDC" )[1] ,'') + ;
			PADR(cSeq , TamSX3("GWU_SEQ" )[1]  ,'')))

		GW1->(dbSetOrder(1))
		GW1->(dbSeek(GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC))
		If Empty(GW1->GW1_NRROM)
			RecLock(cTab,.F.)
			GWU->GWU_CDTRP     := Alltrim(aDados[7])
			GWU->GWU_NRCIDD    := cNRCID
			GWU->GWU_PAGAR     := Alltrim(aDados[9])
			(cTab)->(MsUnlock())
		EndIf
	Else
		RecLock(cTab,.T.)
		GWU->GWU_FILIAL    := Alltrim(aDados[1])
		GWU->GWU_CDTPDC    := Alltrim(aDados[2])
		GWU->GWU_EMISDC    := Alltrim(aDados[3])
		GWU->GWU_SERDC     := Alltrim(aDados[4])
		GWU->GWU_NRDC      := Alltrim(aDados[5])
		GWU->GWU_SEQ       := cSeq
		GWU->GWU_CDTRP     := Alltrim(aDados[7])
		GWU->GWU_NRCIDO	   := cNRCIDO
		GWU->GWU_NRCIDD    := cNRCID
		GWU->GWU_PAGAR     := Alltrim(aDados[9])
		If Len(aDados) >= 12
			GWU->GWU_CDTPVC 	 := Alltrim(aDados[12])
		EndIf
		(cTab)->(MsUnlock())
	EndIf

Return

// Função responsavel por incluir registros na tabela Unitizadores do Documentos de Carga
Function GFEInsGWB(aDados)
	Local cTab := 'GWB' // Armazena a tabela

	(cTab)->(dbSetOrder(2))
	If (cTab)->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GWB_FILIAL" )[1],'') +;
			PADR(Alltrim(aDados[2]) , TamSX3("GWB_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GWB_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GWB_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GWB_NRDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[6]) , TamSX3("GWB_CDUNIT" )[1]  ,'')))
		RecLock(cTab,.F.)
		GWB->GWB_QTDE      := Val(aDados[7])
		(cTab)->(MsUnlock())
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GWB->GWB_FILIAL    := Alltrim(aDados[1])
		GWB->GWB_CDTPDC    := Alltrim(aDados[2])
		GWB->GWB_EMISDC    := Alltrim(aDados[3])
		GWB->GWB_SERDC     := Alltrim(aDados[4])
		GWB->GWB_NRDC      := Alltrim(aDados[5])
		GWB->GWB_CDUNIT    := Alltrim(aDados[6])
		GWB->GWB_QTDE      := VAL(STRTRAN ( aDados[7] , "," , "."  ) )
		(cTab)->(MsUnlock())
	EndIf

Return

// Função responsavel por incluir registros na tabela Itens do Documentos de Carga
Function GFEInsGW8(aDados)
	Local cTab 		:= 'GW8' // Armazena a tabela
	Local cClassFRT := BuscaClasFrete( PADR(Alltrim(aDados[7]), TamSX3("GW8_ITEM")[1], ''), PADR(Alltrim(aDados[1]), TamSX3("GW8_FILIAL" )[1], ''))
	Local cCDTI		:= BuscaTpIt( PADR(Alltrim(aDados[7]), TamSX3("GW8_ITEM")[1], ''), PADR(Alltrim(aDados[1]) , TamSX3("GW8_FILIAL" )[1],'')  )

	(cTab)->(dbSetOrder(2))
	If (cTab)->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GW8_FILIAL" )[1],'') +;
			PADR(Alltrim(aDados[2]) , TamSX3("GW8_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GW8_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GW8_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GW8_NRDC" )[1]  ,'') + ;
			PADR(Alltrim(aDados[6]) , TamSX3("GW8_SEQ" )[1]  ,'')))

		GW1->(dbSetOrder(1))
		GW1->(dbSeek(GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC))
		If Empty(GW1->GW1_NRROM)
			RecLock(cTab,.F.)
			GW8->GW8_QTDE    	:= VAL(STRTRAN ( aDados[8] , "," , "."  ) )
			GW8->GW8_VALOR   	:= VAL(STRTRAN ( aDados[9] , "," , "."  ) )
			GW8->GW8_PESOR   	:= VAL(STRTRAN ( aDados[10] , "," , "."  ) )
			GW8->GW8_INFO1   	:= Alltrim(aDados[11])
			GW8->GW8_UNINEG  	:= Alltrim(aDados[12])
			GW8->GW8_DSITEM  	:= aDados[13]
			GW8->GW8_VOLUME  	:= VAL(STRTRAN ( aDados[14] , "," , "."  ) )
			GW8->GW8_INFO3   	:= Alltrim(aDados[15])
			GW8->GW8_INFO4   	:= Alltrim(aDados[16])
			GW8->GW8_INFO5   	:= Alltrim(aDados[17])
			GW8->GW8_CDCLFR  	:= cClassFRT
			GW8->GW8_RATEIO 	:= Iif(Len(aDados)>20, aDados[21], '1')
			GW8->GW8_TPITEM	:= cCDTI
			GW8->GW8_TRIBP	:= Iif(Len(aDados)>19, aDados[20], '1')
			GW8->GW8_INFO2	:= Alltrim(aDados[18])
			GW8->GW8_CRDICM  	:= Alltrim(aDados[22])
			GW8->GW8_DIFICM  	:= 0
			GW8->GW8_QTDALT	:= VAL(STRTRAN ( aDados[19] , "," , "."  ) )
			If Len(aDados) > 22
				GW8->GW8_CFOP  	:= Alltrim(aDados[23])
			EndIf
			If GFXCP12118("GW8_VALLIQ") .AND. Len(aDados) > 23
				GW8->GW8_VALLIQ := VAL(STRTRAN ( aDados[24] , "," , "."  ) )
			EndIf

			If GFXCP12123("GW8_UNIMED") .AND. Len(aDados) > 24
				GW8->GW8_UNIMED	:= Alltrim(aDados[25])
			EndIf

			(cTab)->(MsUnlock())
		EndIf
	Else
		// Senão cria  o registro
		RecLock(cTab,.T.)
		GW8->GW8_FILIAL  	:= Alltrim(aDados[1])
		GW8->GW8_CDTPDC  	:= Alltrim(aDados[2])
		GW8->GW8_EMISDC  	:= Alltrim(aDados[3])
		GW8->GW8_SERDC   	:= Alltrim(aDados[4])
		GW8->GW8_NRDC    	:= Alltrim(aDados[5])
		GW8->GW8_SEQ     	:= Alltrim(aDados[6])
		GW8->GW8_ITEM    	:= Alltrim(aDados[7])
		GW8->GW8_QTDE    	:= VAL(STRTRAN ( aDados[8] , "," , "."  ) )
		GW8->GW8_VALOR   	:= VAL(STRTRAN ( aDados[9] , "," , "."  ) )
		GW8->GW8_PESOR   	:= VAL(STRTRAN ( aDados[10] , "," , "."  ) )
		GW8->GW8_INFO1   	:= Alltrim(aDados[11])
		GW8->GW8_UNINEG  	:= Alltrim(aDados[12])
		GW8->GW8_DSITEM  	:= aDados[13]
		GW8->GW8_VOLUME  	:= VAL(STRTRAN ( aDados[14] , "," , "."  ) )
		GW8->GW8_INFO3   	:= Alltrim(aDados[15])
		GW8->GW8_INFO4   	:= Alltrim(aDados[16])
		GW8->GW8_INFO5   	:= Alltrim(aDados[17])
		GW8->GW8_CDCLFR  	:= cClassFRT
		GW8->GW8_RATEIO  	:= Iif(Len(aDados)>20, aDados[21], '1')
		GW8->GW8_TPITEM  	:= cCDTI
		GW8->GW8_TRIBP   	:= Iif(Len(aDados)>19, aDados[20], '1')
		GW8->GW8_INFO2 	:= Alltrim(aDados[18])
		GW8->GW8_CRDICM  	:= Alltrim(aDados[22])
		GW8->GW8_DIFICM  	:= 0
		GW8->GW8_QTDALT	:= VAL(STRTRAN ( aDados[19] , "," , "."  ) )
		If Len(aDados) > 22
			GW8->GW8_CFOP  	:= Alltrim(aDados[23])
		EndIf
		If GFXCP12118("GW8_VALLIQ") .AND. Len(aDados) > 23
			GW8->GW8_VALLIQ := VAL(STRTRAN ( aDados[24] , "," , "."  ) )
		EndIf
		If GFXCP12123("GW8_UNIMED") .AND. Len(aDados) > 24
			GW8->GW8_UNIMED	:= Alltrim(aDados[25])
		EndIf

		(cTab)->(MsUnlock())
	EndIf

Return

// Função responsavel por incluir registros na tabela Documentos de Carga de Entrada
Function GFEInsGW1Ent(aDados)
	Local cRet 		 := ""
	Local cTab 		 := 'GW1' // Armazena a tabela
	Local nLenADados := Len(aDados)
	Local lGFEXWS19	 := ExistBlock("GFEXWS19")
	Local cNrCidOri	 := ""

	(cTab)->(dbSetOrder(1))
	If !(cTab)->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'') +; //
		PADR(Alltrim(aDados[2]) , TamSX3("GW1_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GW1_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GW1_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GW1_NRDC" )[1]  ,'')))
		RecLock(cTab,.T.)
		GW1->GW1_FILIAL    := Alltrim(aDados[1])
		GW1->GW1_CDTPDC    := Alltrim(aDados[2])
		GW1->GW1_EMISDC    := Alltrim(aDados[3])
		GW1->GW1_SERDC     := Alltrim(aDados[4])
		GW1->GW1_NRDC      := Alltrim(aDados[5])
		GW1->GW1_DTEMIS    := FormataData(aDados[6])
		GW1->GW1_CDREM     := Alltrim(aDados[7])
		GW1->GW1_CDDEST    := Alltrim(aDados[8])
		GW1->GW1_SIT       := '2'
		GW1->GW1_DTIMPL    := DDATABASE
		GW1->GW1_TPFRET    := Alltrim(aDados[10])
		GW1->GW1_ORIGEM    := '2'  //ERP
		GW1->GW1_HRIMPL    := TIME()
		GW1->GW1_ENVEDI    := '2'
		GW1->GW1_USO       := If(nLenADados >= 11, aDados[11], '1')
		GW1->GW1_ICMSDC    := '1'
		GW1->GW1_HRPENT    := TIME()
		If GfeVerCmpo({"GW1_SITFT"})
			GW1->GW1_SITFT     := '6'
		EndIf
		If GFXCP12117("GW1_SITFRE") == .T.
			GW1->GW1_SITFRE     := '6'
		EndIf
		If GfeVerCmpo({"GW1_ROMTV"})
			GW1->GW1_ROMTV	   := If(nLenADados >= 12, Alltrim(aDados[12]), '')
			GW1->GW1_ROMCF	   := If(nLenADados >= 13, Alltrim(aDados[13]), '')
			GW1->GW1_ROMTO	   := If(nLenADados >= 14, Alltrim(aDados[14]), '')
		EndIf
		GW1->GW1_CARREG    := If(nLenADados >= 15, Alltrim(aDados[15]), '')
		GW1->GW1_DANFE	   := Alltrim(aDados[16])
		// Valor inicial (vazio) no Datasul = 0, no GFE = vazio
		If AllTrim(GW1->GW1_CARREG) == '0'
			GW1->GW1_CARREG := ''
		EndIf
		// Execução Automática da função de liberação do documento de carga
		If Alltrim(aDados[17]) == 'Y'
			cRet := GFEX101REG()
		EndIf
		// Início Ponto de Entrada LordPlastics
		If ExistBlock("GFEYWS04")
			ExecBlock("GFEYWS04",.F.,.F.,{aDados})
		EndIf
		(cTab)->(MsUnlock())
		// Início Ponto de Entrada Procomp
		If ExistBlock("GFEXWS10")
			ExecBlock("GFEXWS10",.f.,.f.,{nLenADados,aDados})
		EndIf
		// Fim Ponto de Entrada Procomp
	EndIf

	GWU->(dbSetOrder(1))
	GWU->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GWU_FILIAL" )[1],'') + ;
		PADR(Alltrim(aDados[2]) , TamSX3("GWU_CDTPDC" )[1],'') + ;
		PADR(Alltrim(aDados[3]) , TamSX3("GWU_EMISDC" )[1],'') + ;
		PADR(Alltrim(aDados[4]) , TamSX3("GWU_SERDC" )[1] ,'') + ;
		PADR(Alltrim(aDados[5]) , TamSX3("GWU_NRDC" )[1] ,'')  + ;
		"01"))
	If GWU->GWU_FILIAL    == PADR(Alltrim(aDados[1]) , TamSX3("GWU_FILIAL" )[1],'');
			.And. GWU->GWU_CDTPDC == PADR(Alltrim(aDados[2]) , TamSX3("GWU_CDTPDC" )[1],'');
			.And. GWU->GWU_EMISDC == PADR(Alltrim(aDados[3]) , TamSX3("GWU_EMISDC" )[1],'');
			.And. GWU->GWU_SERDC  == PADR(Alltrim(aDados[4]) , TamSX3("GWU_SERDC" )[1],'');
			.And. GWU->GWU_NRDC   == PADR(Alltrim(aDados[5]) , TamSX3("GWU_NRDC" )[1],'');
			.And. GWU->GWU_SEQ    == "01"

		If lGFEXWS19
			cNrCidOri := ExecBlock("GFEXWS19",.F.,.F.,{xFilial("GU3"),Alltrim(aDados[7])})
			If ValType(cNrCidOri) == 'C' .And. !Empty(cNrCidOri)
				RecLock("GWU",.F.)
				GWU->GWU_NRCIDO := cNrCidOri
				GWU->(MsUnlock())
			EndIf
		EndIf
	EndIf

	If cRet == ""
		dbSelectArea("GWN")
		dbSetOrder(1)
		If dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM)
			// 	Retornar situação do cálculo automático (conteúdo do campo GWN_CALC) + "observação do cálculo do Romaneio" (GWN_MTCALC)
			//	1=Calculado com Sucesso;2=Nao Calculado;3=Tentativa sem Sucesso;4=Necessita Recalculo
			If GWN->GWN_CALC == '1'
				cRet := NoAcento(AnsiToOem( "#GWN|Calculado com Sucesso|" 	+ StrTran(GWN->GWN_MTCALC,CRLF," ") )) + "|"
			ElseIf GWN->GWN_CALC == '2'
				cRet := NoAcento(AnsiToOem( "#GWN|Não Calculado|" 			+ StrTran(GWN->GWN_MTCALC,CRLF," ") )) + "|"
			ElseIf GWN->GWN_CALC == '3'
				cRet := NoAcento(AnsiToOem( "#GWN|Tentativa sem Sucesso|" 	+ StrTran(GWN->GWN_MTCALC,CRLF," ") )) + "|"
			ElseIf GWN->GWN_CALC == '4'
				cRet := NoAcento(AnsiToOem( "#GWN|Necessita Recálculo|" 	+ StrTran(GWN->GWN_MTCALC,CRLF," ") )) + "|"
			EndIf
		EndIf
	EndIf
	If Empty(cRet)
		cRet := "TRUE"
	EndIf
Return cRet

// Função responsavel por incluir registros na tabela Trechos do Documentos de Carga
Function GFEInsGWUEnt(aDados)
	Local cNRCID 	:= ''
	Local cSeq	   	:= AllTrim(aDados[6])
	cSeq 			:= StrZero(Val(cSeq), 2)

	GU7->(dbSetOrder(3))
	If GU7->(dbSeek(xFilial("GU7") + PADR(Alltrim(aDados[10]) , TamSX3("GU7_NMCID" )[1]  ,'') + PADR(Alltrim(aDados[11]) , TamSX3("GU7_CDUF" )[1]  ,'')))
		cNRCID := GU7->GU7_NRCID
	Else
		cNRCID := Alltrim(aDados[8])
	EndIf

	GWU->(dbSetOrder(1))
	If GWU->(!dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GWU_FILIAL" )[1],'') +;
			PADR(Alltrim(aDados[2]) , TamSX3("GWU_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GWU_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GWU_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GWU_NRDC" )[1] ,'') + ;
			PADR(cSeq , TamSX3("GWU_SEQ" )[1]  ,'')))
		RecLock('GWU', .T.)
		GWU->GWU_FILIAL := Alltrim(aDados[1])
		GWU->GWU_CDTPDC := Alltrim(aDados[2])
		GWU->GWU_EMISDC := Alltrim(aDados[3])
		GWU->GWU_SERDC  := Alltrim(aDados[4])
		GWU->GWU_NRDC   := Alltrim(aDados[5])
		GWU->GWU_SEQ    := cSeq
		GWU->GWU_CDTRP  := Alltrim(aDados[7])
		GWU->GWU_NRCIDD := cNRCID
		GWU->GWU_PAGAR  := Alltrim(aDados[9])
		GWU->GWU_CDTPVC := Alltrim(aDados[12])
		GWU->(MsUnlock())
	EndIf

Return

// Função responsavel por incluir registros na tabela Itens do Documentos de Carga de Entrada
Function GFEInsGW8Ent(aDados)
	Local cClasFrt   := BuscaClasFrete( PADR(Alltrim(aDados[7]), TamSX3("GW8_ITEM")[1], '') , PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'')  )
	Local cTPITEM    := BuscaTpIt( PADR(Alltrim(aDados[7]), TamSX3("GW8_ITEM")[1], '') , PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'')  )
	Local cSeqItem   := PadL("1", TamSX3("GW8_SEQ")[1], "0")
	Local nLenAdados := Len(aDados)

	GW8->(dbSetOrder(1))
	If GW8->(dbSeek(PadR(aDados[1] , TamSX3("GW1_FILIAL"  )[1]) + ;
			PadR(aDados[2] , TamSX3("GW1_CDTPDC"  )[1]) + ;
			PadR(aDados[3] , TamSX3("GW1_EMISDC"  )[1]) + ;
			PadR(aDados[4] , TamSX3("GW1_SERDC"   )[1]) + ;
			PadR(aDados[5] , TamSX3("GW1_NRDC"    )[1]) + ;
			PadR(aDados[7] , TamSX3("GW8_ITEM"    )[1]) + ; // GW8_ITEM
		PadR(aDados[18], TamSX3("GW8_UNINEG"  )[1]) + ; // GW8_UNINEG
		PadR(aDados[14], TamSX3("GW8_INFO1"   )[1])))   // GW8_INFO1
		Return
	EndIf

	GW8->(dbSetOrder(2))
	GW8->(dbSeek(PadR(aDados[1], TamSX3("GW1_FILIAL")[1]) + ;
		PadR(aDados[2], TamSX3("GW1_CDTPDC")[1]) + ;
		PadR(aDados[3], TamSX3("GW1_EMISDC")[1]) + ;
		PadR(aDados[4], TamSX3("GW1_SERDC")[1] ) + ;
		PadR(aDados[5], TamSX3("GW1_NRDC")[1]  ) + ;
		Replicate("z" , TamSX3("GW8_SEQ")[1]   ), .T.))
	GW8->(dbSkip(-1))

	If !GW8->( Eof() ) .And. GW8->GW8_FILIAL == PadR(aDados[1], TamSX3("GW1_FILIAL")[1]);
			.And. GW8->GW8_CDTPDC == PadR(aDados[2], TamSX3("GW1_CDTPDC")[1]);
			.And. GW8->GW8_EMISDC == PadR(aDados[3], TamSX3("GW1_EMISDC")[1]);
			.And. GW8->GW8_SERDC  == PadR(aDados[4], TamSX3("GW1_SERDC")[1] );
			.And. GW8->GW8_NRDC   == PadR(aDados[5], TamSX3("GW1_NRDC")[1])

		cSeqItem := StrZero(Val(GW8->GW8_SEQ) + 1, TamSX3("GW8_SEQ")[1])
	EndIf

	RecLock("GW8", .T.)
	GW8->GW8_FILIAL   := Alltrim(aDados[1])
	GW8->GW8_CDTPDC   := Alltrim(aDados[2])
	GW8->GW8_EMISDC   := Alltrim(aDados[3])
	GW8->GW8_SERDC    := Alltrim(aDados[4])
	GW8->GW8_NRDC     := Alltrim(aDados[5])
	GW8->GW8_SEQ      := cSeqItem
	GW8->GW8_ITEM     := Alltrim(aDados[7])
	GW8->GW8_DSITEM   := Alltrim(aDados[8])
	GW8->GW8_QTDE     := VAL(STRTRAN ( aDados[9]  , "," , "."  ) )
	GW8->GW8_VALOR    := VAL(STRTRAN ( aDados[10] , "," , "."  ) )
	GW8->GW8_VOLUME   := VAL(STRTRAN ( aDados[11] , "," , "."  ) )
	GW8->GW8_PESOR    := VAL(STRTRAN ( aDados[12] , "," , "."  ) )
	GW8->GW8_PESOC    := VAL(STRTRAN ( aDados[13] , "," , "."  ) )
	GW8->GW8_INFO1    := Alltrim(aDados[14])
	GW8->GW8_INFO3    := Alltrim(aDados[15])
	GW8->GW8_INFO5    := Alltrim(aDados[16])
	GW8->GW8_UNINEG   := Alltrim(aDados[18])
	// Validação para tamanho de array recebido do ERP
	// Se existir não existir a posição do array aDados, atribui o valor do inicializador padrão
	GW8->GW8_CRDICM   := IIF(nLenAdados >= 19, aDados[19], "1")
	GW8->GW8_DIFICM   := IIF(nLenAdados > 19,  VAL(STRTRAN( aDados[20] , "," , "." )),  0 )
	GW8->GW8_TRIBP    := Alltrim(aDados[17])
	GW8->GW8_CDCLFR   := cClasFrt
	GW8->GW8_RATEIO   := Iif(Len(aDados)>20, aDados[21], '1')
	GW8->GW8_TPITEM   := cTPITEM
	If GFXCP12123("GW8_UNIMED") .AND. Len(aDados) > 21
		GW8->GW8_UNIMED := Alltrim(aDados[22])
	EndIf
	GW8->GW8_QTDALT   := Iif(nLenAdados > 22, Val(StrTran(aDados[23], ",", ".")), 0)
	GW8->(MsUnlock())

	// Quando adiciona itens a um documento de carga já existente que possui cálculo automático
	// e o mesmo já foi efetuado, deve deixar a situação do cálculo automático como pendente
	// para que seja realizado novamente
	If GfeVerCmpo({"GW1_CALCAT"})
		cChaveGW1 := PadR(aDados[1], TamSX3("GW1_FILIAL")[1]) + ;
			PadR(aDados[2], TamSX3("GW1_CDTPDC")[1]) + ;
			PadR(aDados[3], TamSX3("GW1_EMISDC")[1]) + ;
			PadR(aDados[4], TamSX3("GW1_SERDC")[1]) + ;
			PadR(aDados[5], TamSX3("GW1_NRDC")[1])

		If Posicione("GW1",1,cChaveGW1,"GW1_CALCAT") $ "2;3"
			GW1->(dbSetOrder(1))
			If GW1->(dbSeek(cChaveGW1))
				RecLock("GW1",.F.)
				GW1->GW1_CALCAT := "1"
				GW1->GW1_SIT    := "2"
				GW1->(MsUnlock())
			EndIf
		EndIf
	EndIf
Return

// Função responsavel por incluir registros de cálculo Combinado
Function GFEInsGWF(aDados)
	// Estrutura aDados
	// 1.  GW1_FILIAL
	// 2.  GW1_SERDC
	// 3.  GW1_NRDC
	// 4.  GW1_CDTPDC
	// 5.  GW1_CDDEST
	// 6.  GW1_EMISDC
	// 7.  GWG_NRTAB
	// 8.  GWG_CDCLFR
	// 9.  GWG_DTVALI
	// 10. GWG_NRROTA
	// 11. GWG_CDTPOP
	// 12. GWG_CDTPVC
	// 13. GWU_SEQ
	// 14. GW1_DTPREN
	// 15. GWI_CDCOMP
	// 16. GWI_VLFRET
	// 17. {Repete componentes}

	Local aTam := {	TamSX3("GW1_FILIAL")[1]	,;
		TamSX3("GW1_SERDC")[1]	,;
		TamSX3("GW1_NRDC")[1]	,;
		TamSX3("GW1_CDTPDC")[1]	,;
		TamSX3("GW1_CDDEST")[1]	,;
		TamSX3("GW1_EMISDC")[1]	,;
		TamSX3("GWG_NRTAB")[1]	,;
		TamSX3("GWG_CDCLFR")[1]	,;
		TamSX3("GWG_DTVALI")[1]	,;
		TamSX3("GWG_NRROTA")[1]	,;
		TamSX3("GWG_CDTPOP")[1]	,;
		TamSX3("GWG_CDTPVC")[1]	,;
		TamSX3("GWU_SEQ")[1]	,;
		TamSX3("GWI_CDCOMP")[1]	,;
		TamSX3("GWI_VLFRET")[1] ,;
		TamSX3("GWG_NRNEG")[1]  ,;
		TamSX3("GWG_CDFXTV")[1]}


	Local cChaveGW1 := PadR(aDados[1], aTam[1]) + ;
		PadR(aDados[4], aTam[4]) + ;
		PadR(aDados[6], aTam[6]) + ;
		PadR(aDados[2], aTam[2]) + ;
		PadR(aDados[3], aTam[3])

	Local cChaveGV9 := ""
	Local cChaveGVA := ""
	Local lCalcCot  := .F. // Tem cálculo combinado
	Local oModel  	:= FwLoadModel("GFEA084")
	Local oModelGWH := oModel:GetModel("GFEA084_GWH")
	Local oModelGWI := oModel:GetModel("GFEA084_GWI")
	Local oModelGWG := oModel:GetModel("GFEA084_GWG")
	Local aComp 	:= {} // Armazena os trechos para teste de agrupamento em unidades de cálculo
	Local cChaveGWH := ""
	Local nCompoIni := 14 // Posição de início dos componentes
	Local nCompoTam := 2 // Quantidade de posição do componente
	Local nDados 	:= Len(aDados)
	Local cSeq 		:= StrZero(Val(aDados[13]),aTam[13])
	Local cSeqTre 	:= PadR(StrZero(Val(aDados[13]),aTam[13]),TamSx3("GWF_SEQTRE")[1])
	Local cNrRota 	:= PadR(StrZero(Val(aDados[10]),aTam[10]),TamSx3("GWG_NRROTA")[1])
	Local aCalcDel 	:= {}
	Local nX
	Local cFilAtu 	:= cFilAnt
	Local cCdFxTv
	Local cTransp
	Local nQtPeso := 0
	Local nQtItem := 0
	Local nValMer := 0
	Local nPes3   := 0
	Local nQtM3   := 0

	Private NR_CALC
	Private GFELogWSF

	//Suavização da data de previsão de entrega
	If SubStr(aDados[14], 1, 1) = "&"
		nCompoIni := 15
	EndIf

	If SubStr(aDados[15], 1, 1) = "&" .And. SubStr(aDados[16], 1, 1) = "&"
		nCompoIni := 17
	EndIf

	cFilAnt := GW1->GW1_FILIAL

	GW1->(dbSetOrder(1))
	If !GW1->(dbSeek(cChaveGW1))
		Return
	EndIf

	GWU->(dbSetOrder(1))
	If !GWU->(dbSeek(cChaveGW1))
		Return
	EndIf

	// Verifica se já existe um calcúlo ORIGEM 3 para o documento/trecho e exclui-o
	GWH->(dbSetOrder(2))
	GWF->(dbSetOrder(1))
	If GWH->(dbSeek(cChaveGW1))
		While !GWH->(Eof()) .And. cChaveGW1 == GWH->(GWH_FILIAL+GWH_CDTPDC+GWH_EMISDC+GWH_SERDC+GWH_NRDC)
			If GWF->(dbSeek(GWH->(GWH_FILIAL+GWH_NRCALC))) .And. GWF->GWF_SEQTRE == cSeqTre .And. GWF->GWF_ORIGEM == '4'
				aAdd(aCalcDel,{GWF->GWF_NRCALC,GWF->GWF_FILIAL})
			EndIf
			GWH->(dbSkip())
		EndDo
	EndIf

	For nX := 1 to Len(aCalcDel)
		GFEDelCalc(aCalcDel[nX][1],aCalcDel[nX][2],.T.)
	Next nX

	aComp := GFEXGrupTre(cChaveGW1,cSeq)

	GWN->(dbSetOrder(1))
	If !Empty(GW1->GW1_NRROM) .And. GWN->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM))
		GWF->(dbSetOrder(4))
		GWH->(dbSetOrder(1))

		//Pelo Romaneio
		While !GWF->(Eof()) .And. GWF->GWF_FILIAL + GWF->GWF_NRROM == GW1->GW1_FILIAL + GW1->GW1_NRROM
			If  GWF->GWF_ORIGEM == "4" ;
					.And. GWH->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
				// Verifica se é possível agrupar no mesmo cálculo do documento posicionado
				cChaveGWH := GWH->(GWH_FILIAL + GWH_CDTPDC + GWH_EMISDC + GWH_SERDC + GWH_NRDC)

				If GFEXAGRUPC(cChaveGWH,cChaveGW1,GFEXGrupTre(cChaveGWH,GWH->GWH_TRECHO),aComp)
					lCalcCot:= .T.
					Exit
				EndIF

			EndIf
			GWF->(dbSkip())
		EndDo
	EndIf

	If lCalcCot
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
	Else
		oModel:SetOperation(MODEL_OPERATION_INSERT)
	EndIf

	oModel:Activate()

	If !lCalcCot
		oModel:GetModel("GFEA084_GWF"):LoadValue("GWF_OBS","Frete gerado através de simulação selecionada no Datasul."+CHR(13)+CHR(10)+;
			"Dados utilizados para cálculo:"+CHR(13)+CHR(10)+;
			"Tabela: " + AllTrim(aDados[7]) +CHR(13)+CHR(10)+;
			"Rota: " + AllTrim(aDados[10]) +CHR(13)+CHR(10)+;
			"Cl. Frete: " + If(AllTrim(aDados[8]) == "0","0",AllTrim(aDados[8])) +CHR(13)+CHR(10)+;
			"Dt. Vig.: " + AllTrim(aDados[9]) +CHR(13)+CHR(10)+;
			"Cód. Operação: " + AllTrim(aDados[11])+CHR(13)+CHR(10)+;
			"Tipo de Veículo: " + AllTrim(aDados[12]))
		oModel:GetModel("GFEA084_GWF"):LoadValue("GWF_ORIGEM","4")
		oModel:GetModel("GFEA084_GWF"):LoadValue("GWF_USUCRI","INTEGRACAO")
		If SubStr(aDados[14], 1, 1) = "&"
			oModel:GetModel("GFEA084_GWF"):LoadValue("GWF_DTPREN", StoD(SubStr(aDados[14], 2)))
		EndIf
	EndIf

	If !Empty(oModelGWH:GetValue("GWH_NRDC",1))
		oModelGWH:AddLine(.T.)
	EndIf


	oModelGWH:LoadValue("GWH_FILIAL",PadR(aDados[1], aTam[1]))
	oModelGWH:LoadValue("GWH_CDTPDC",PadR(aDados[4], aTam[4]))
	oModelGWH:LoadValue("GWH_EMISDC",PadR(aDados[6], aTam[6]))
	oModelGWH:LoadValue("GWH_SERDC"	,PadR(aDados[2], aTam[2]))
	oModelGWH:LoadValue("GWH_NRDC"	,PadR(aDados[3], aTam[3]))
	oModelGWH:LoadValue("GWH_TRECHO",cSeq)
	oModelGWH:VldLineData()


	While (nCompoIni+nCompoTam-1) <= nDados .And. !Empty(aDados[nCompoIni])
		If !oModelGWI:SeekLine({{"GWI_CDCOMP", PadR(aDados[nCompoIni], aTam[14])}})
			If !Empty(oModelGWI:GetValue("GWI_CDCOMP",1))
				oModelGWI:AddLine(.T.)
			EndIf
			oModelGWI:LoadValue("GWI_CDCOMP",PadR(aDados[nCompoIni], aTam[14]))
			oModelGWI:LoadValue("GWI_BASICM","1")
			oModelGWI:LoadValue("GWI_BASPIS","1")
		EndIF
		oModelGWI:LoadValue("GWI_VLFRET",oModelGWI:GetValue("GWI_VLFRET") + Val(STRTRAN(aDados[nCompoIni+1],",",".")))
		nCompoIni+=nCompoTam
	EndDo

	If SubStr(aDados[15], 1, 1) = "&" .and. SubStr(aDados[16], 1, 1) = "&"

		GWU->(dbSetOrder(1))
		If GWU->(dbSeek(cChaveGW1+cSeq))
			cTransp := GWU->GWU_CDTRP
		EndIf


		cChaveGV9 := XFILIAL("GV9") + ;
			PadR(cTransp, TamSX3("GWF_TRANSP")[1]) + ;
			PadR(aDados[7], aTam[7]) + ;
			SubStr(aDados[15],2,aTam[16])


		GV9->(dbSetOrder(1))
		If !GV9->(dbSeek(cChaveGV9))
			GFEConout("INFO", "[WSGFE.GFEInsGWF] - Localizada tabela de vínculo.")

			cChaveGVA := XFILIAL("GV9") + ;
				PadR(cTransp, TamSX3("GWF_TRANSP")[1]) + ;
				PadR(aDados[7], aTam[7])

			GFEConout("INFO", "[WSGFE.GFEInsGWF] cChaveGVA: " + cChaveGVA)

			GVA->(dbSetOrder(1))
			If GVA->(dbSeek(cChaveGVA))
				GFEConout("INFO", "[WSGFE.GFEInsGWF] - Localizou tab. vinc. Alterando cChaveGV9. ")

				cChaveGV9 := xFilial("GV9") + ;
					PadR(GVA->GVA_EMIVIN, TamSX3("GWF_TRANSP")[1]) +;
					PadR(GVA->GVA_TABVIN,aTam[7]) + ;
					SubStr(aDados[15],2,aTam[16])

				GFEConout("INFO", "[WSGFE.GFEInsGWF] cChaveGV9: " + cChaveGV9)
			EndIF
		EndIf

		If GV9->(dbSeek(cChaveGV9))


			dbSelectArea("GW8")
			GW8->(dbSetOrder(1))
			If GW8->(dbSeek(cChaveGW1))

				While !GW8->(Eof()) .And. ;
						GW8->GW8_FILIAL == GW1->GW1_FILIAL .And. ;
						GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .And. ;
						GW8->GW8_EMISDC == GW1->GW1_EMISDC .And. ;
						GW8->GW8_SERDC == GW1->GW1_SERDC .And. ;
						GW8->GW8_NRDC == GW1->GW1_NRDC

					nQtPeso += GW8->GW8_PESOR
					nQtItem += GW8->GW8_QTDE
					nValMer += GW8->GW8_VALOR
					nPes3     += GW8->GW8_PESOC
					nQtM3     += GW8->GW8_VOLUME

					GW8->( dbSkip() )
				EndDo
			EndIf

			IF !Empty(cChaveGVA)
				oModelGWG:LoadValue("GWG_CDEMIT",GVA->GVA_CDEMIT)
				oModelGWG:LoadValue("GWG_NRTAB",GVA->GVA_NRTAB)
			Else
				oModelGWG:LoadValue("GWG_CDEMIT",GV9->GV9_CDEMIT)
				oModelGWG:LoadValue("GWG_NRTAB",GV9->GV9_NRTAB)
			EndIf

			oModelGWG:LoadValue("GWG_FILIAL",PadR(aDados[1], aTam[1]))
			oModelGWG:LoadValue("GWG_CDCLFR",GV9->GV9_CDCLFR)
			oModelGWG:LoadValue("GWG_CDTPOP",GV9->GV9_CDTPOP)

			oModelGWG:LoadValue("GWG_NRNEG",GV9->GV9_NRNEG)

			cCdFxTv := SubStr(aDados[16],2,aTam[16])
			oModelGWG:LoadValue("GWG_CDFXTV",cCdFxTv)

			oModelGWG:LoadValue("GWG_NRROTA",cNrRota)
			oModelGWG:LoadValue("GWG_DTVALI",GV9->GV9_DTVALI)

			oModelGWG:LoadValue("GWG_QTPESO",nQtPeso)
			oModelGWG:LoadValue("GWG_QTITEM",nQtItem)
			oModelGWG:LoadValue("GWG_VLMERC",nValMer)
			oModelGWG:LoadValue("GWG_PESCUB",nPes3)
			oModelGWG:LoadValue("GWG_QTM3",nQtM3)

			oModelGWG:VldLineData()

		EndIf
	EndIf

	If oModel:VldData()
		oModel:CommitData()
		GW1->(dbSetOrder(1))
		GW1->(dbSeek(cChaveGW1))
		RecLock("GW1",.F.)
		If POSICIONE("GV5",1,XFILIAL("GV5")+GW1_CDTPDC,"GV5_CALC") == "2"
			GW1->GW1_CALCAT := "1"
		Else
			GW1->GW1_CALCAT := "0"
		EndIf
		If SubStr(aDados[14], 1, 1) = "&"
			GW1->GW1_DTPENT := StoD(SubStr(aDados[14], 2))
		EndIf
		GW1->(MsUnlock())
	Else
		If Type("GFELogWSF") == "U"
			GFELogWSF := GFELog():New("Calculo_Combinado", "Cálculo Combinado - Importação Datasul", SuperGetMV('MV_GFEEDIL',,'1'))
		EndIf
		GFELogWSF:Add("Documento" + CRLF + Replicate("-", 20))

		GFELogWSF:Add("Filial..........: " + aDados[1])
		GFELogWSF:Add("Tipo de Docto...: " + aDados[4])
		GFELogWSF:Add("Emitente Docto..: " + aDados[6])
		GFELogWSF:Add("Série Docto.....: " + aDados[2])
		GFELogWSF:Add("Número Docto....: " + aDados[3])

		GFELogWSF:NewLine()
		GFELogWSF:Add("Mensagem de erro" + CRLF + Replicate("-", 20))
		GFELogWSF:Add("Campo.: " + oModel:GetErrorMessage()[4])
		GFELogWSF:Add("Erro..: " + oModel:GetErrorMessage()[6])
	EndIf

	If Type("GFELogWSF") != "U"
		GFELogWSF:EndLog()
	EndIf

	cFilAnt := cFilAtu
	oModel:DeActivate()

Return GWF->GWF_NRCALC

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela Grupo de emitente
Function GFEDelGU1(aDados)

	dbSelectArea('GU1')
	If dbSeek(xFilial('GU1')+PADR(Alltrim(aDados[1]) , TamSX3("GU1_CDGREM" )[1],''))
		RecLock('GU1',.F.)
		GU1->GU1_SIT 	:= '2'
		MsUnlock()
	EndIf

Return

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela cidades
Function GFEDelGU7(aDados)
	Local cTab := 'GU7' // Armazena a tabela
	Local cSeek := ''

	dbSelectArea(cTab)
	If Len(aDados) > 1
		dbsetOrder(3)
		cSeek := xFilial(cTab)+ PADR(Alltrim(aDados[2]) , TamSX3("GU7_NMCID" )[1],'')
		cSeek += PADR(Alltrim(aDados[3]) , TamSX3("GU7_CDUF" )[1],'')
	Else
		dbsetOrder(1)
		cSeek := xFilial(cTab)+ PADR(Alltrim(aDados[1]) , TamSX3("GU7_NRCID" )[1],'')
	EndIf

	If dbSeek(cSeek)
		RecLock(cTab,.F.)
		GU7->GU7_SIT    := '2'
		MsUnlock()
	EndIf
Return

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela unitizadores
Function GFEDelGUG(aDados)
	Local cTab := 'GUG' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(xFilial(cTab)+PADR(Alltrim(aDados[1]) , TamSX3("GUG_CDUNIT" )[1],''))
		RecLock(cTab,.F.)
		GUG->GUG_SIT    := '2'
		MsUnlock()
	EndIf

Return

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela Contas Contábeis
Function GFEDelGUE(aDados)
	Local cTab := 'GUE' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(xFilial(cTab)+PADR(Alltrim(aDados[1]) , TamSX3("GUE_CTACTB" )[1],''))
		RecLock(cTab,.F.)
		GUE->GUE_SIT     := '2'
		MsUnlock()
	EndIf

Return

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela Centro de Custo
Function GFEDelGUH(aDados)
	Local cTab := 'GUH' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(xFilial(cTab)+PADR(Alltrim(aDados[1]) , TamSX3("GUH_CCUSTO" )[1],''))
		RecLock(cTab,.F.)
		GUH->GUH_SIT    := '2'
		MsUnlock()
	EndIf

Return

//Função responsavel por 'excluir'(Seta como inativo) registros na tabela Romaneios
Function GFEDelGWN(aDados)
	Local cTab := 'GWN' // Armazena a tabela
	Local oModel
	Local aErro := {}
	Local cBkpFilAnt := cFilAnt
	cFilAnt := PADR(Alltrim(aDados[1]) , TamSX3("GWN_FILIAL" )[1],'')

	oModel:= FWLoadModel("GFEA050")
	oModel:SetOperation( 5 ) //Exclusão

	// Início Ponto de Entrada Procomp
	If ExistBlock("GFEXWS14")
		lRet := ExecBlock("GFEXWS14",.f.,.f.,{aDados, oModel})
		If lRet == 'ok'
			Return .T.
		EndIF
	EndIf
	// Fim Ponto de Entrada Procomp

	dbSelectArea(cTab)
	If dbSeek(	PADR(Alltrim(aDados[1]) , TamSX3("GWN_FILIAL" )[1],'') + ;
			PADR(Alltrim(aDados[2]) , TamSX3("GWN_NRROM" )[1],''))

		oModel:Activate()
		lRet:= oModel:VldData()
		If (lRet)
			oModel:CommitData()
		Else
			//  A estrutura do vetor aErro com erro é:
			//  [1] Id do formulário de origem
			//  [2] Id do campo de origem
			//  [3] Id do formulário de erro
			//  [4] Id do campo de erro
			//  [5] Id do erro
			//  [6] mensagem do erro
			//  [7] mensagem da solução
			//  [8] Valor atribuido
			//  [9] Valor anterior
			aErro := oModel:GetErrorMessage()
			GFEConout("ERROR", "[SEM AMBIENTE ] [WSGFE.GFEDelGWN] Erro na exclusão do registro. Motivo: " + aErro[6], .F.)
		EndIf

	EndIf

	oModel:DeActivate()
	oModel:Destroy()

	cFilAnt := cBkpFilAnt

Return

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela Emitentes
Function GFEDelGU3(aDados)
	Local cTab := 'GU3' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(xFilial(cTab)+ PADR(Alltrim(aDados[1]) , TamSX3("GU3_CDEMIT" )[1],'') )
		RecLock(cTab,.F.)
		GU3->GU3_SIT      := '2'
		MsUnlock()
	EndIf

Return

// Função responsavel por 'excluir'(Seta como inativo) registros na tabela Tipo de Veículo
Function GFEDelGV3(aDados)
	Local cTab := 'GV3' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(xFilial(cTab)+ PADR(Alltrim(aDados[1]) , TamSX3("GV3_CDTPVC" )[1],'') )
		RecLock(cTab,.F.)
		GV3->GV3_SIT      := '2'
		MsUnlock()
	EndIf

Return

// Função responsavel por excluir registros na tabela Contatos
Function GFEDelGU2(aDados)
	Local cTab := 'GU2' // Armazena a tabela

	dbSelectArea(cTab)
	If dbSeek(	 xFilial(cTab) +;
			PADR(Alltrim(aDados[1]) , TamSX3("GU2_CDEMIT" )[1],'') + ;
			PADR(Alltrim(aDados[2]) , TamSX3("GU2_SEQ" )[1]   ,''))

		RecLock(cTab,.F.)
		dbDelete()
		MsUnlock()
	EndIf

Return

// Função responsavel por 'excluir'registro da tabela de contratos - GXT
Function GFEDelGXT(aDados)

	If GFXCP12127("GXT_NRCT")

		GXT->(dbSetOrder(1))
		If GXT->(dbSeek(PADR(Alltrim(aDados[1]) , TamSX3("GXT_FILIAL" )[1],'') + ;
				PADR(Alltrim(aDados[2]) , TamSX3("GXT_NRCT" )[1]  ,'') ))

			Return "Contrato integrado com o GFE. Por favor, elimine-o primeiramente no GFE para depois eliminá-lo no ERP."

		EndIf

	Endif

Return "TRUE"


// Função responsavel por 'excluir'(Seta como inativo) registros na tabela Nota fiscal
Function GFEDelGW1(aDados)

	dbSelectArea("GW1")
	dbSetOrder(1)
	If dbSeek(	PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'') + ;
			PADR(Alltrim(aDados[2]) , TamSX3("GW1_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GW1_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GW1_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GW1_NRDC" )[1]  ,'') )

		If !Empty(GW1->GW1_NRROM)
			dbSelectArea("GWN")
			dbSetOrder(1)
			If (dbSeek(GW1->GW1_FILIAL + GW1->GW1_NRROM) .AND. GWN->GWN_SIT == '1')
				RecLock("GW1",.F.)
				GW1->GW1_SIT    := '7'
				GW1->GW1_DTCAN  := DATE()
				GW1->GW1_HRCAN  := TIME()
				GW1->GW1_USUCAN := "ERP"
				MsUnlock()

				RecLock("GWN", .F.)
				GWN->GWN_CALC   := "4" //Necessita Recalcular
				GWN->GWN_MTCALC := "Um Documento de Carga relacionado ao Romaneio foi cancelado."
				GWN->GWN_DTCALC := CToD("  /  /    ")
				GWN->GWN_HRCALC := ""
				GWN->( MsUnlock() )

				If GWN->GWN_CALC == '4' .And. !Empty(GWN->GWN_VIAGEM)
					GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
				EndIf

				dbSelectArea("GWH")
				dbSetOrder(2)
				If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
					dbSelectArea("GWF")
					dbSetOrder(1)
					If dbSeek( GWH->GWH_FILIAL + GWH->GWH_NRCALC)
						GFEDelCalc(GWF->GWF_NRCALC)
					EndIf
				EndIf
			Else
				Return "Nao e possivel cancelar a nota fiscal pois a mesma esta vinculada a um Romaneio com situacao diferente de digitado no GFE(Gestao de Frete Embarcador)."
			EndIf
		Else
			dbSelectArea("GWH")
			dbSetOrder(2)
			If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
				dbSelectArea("GWF")
				dbSetOrder(1)
				If dbSeek( GWH->GWH_FILIAL + GWH->GWH_NRCALC) .And. GWF->GWF_TPCALC == "8"
					GFEDelCalc(GWF->GWF_NRCALC)
				EndIf
			EndIf

			RecLock("GW1",.F.)
			GW1->GW1_SIT    := '7'
			GW1->GW1_DTCAN  := DATE()
			GW1->GW1_HRCAN  := TIME()
			GW1->GW1_USUCAN := "ERP"
			GW1->( MsUnlock() )
		EndIf
	EndIf

Return "TRUE"

// Função responsável por excluir os registros de notas fiscais de entrada
Function GFEDelGW1Ent(aDados)
	Local lRetGWN 	:= .F.
	Local cFilGW1
	Local cTipoGW1
	Local cEmisGW1
	Local cSerGW1
	Local cNumGW1
	Private cTexto1	:= 'Reabertura automatica realizado pelo Modulo DATASUL'

	dbSelectArea("GW1")
	dbSetOrder(1)
	If dbSeek(	PADR(Alltrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1],'') + ;
			PADR(Alltrim(aDados[2]) , TamSX3("GW1_CDTPDC" )[1],'') + ;
			PADR(Alltrim(aDados[3]) , TamSX3("GW1_EMISDC" )[1],'') + ;
			PADR(Alltrim(aDados[4]) , TamSX3("GW1_SERDC" )[1] ,'') + ;
			PADR(Alltrim(aDados[5]) , TamSX3("GW1_NRDC" )[1]  ,'') )

		dbSelectArea("GW4")
		dbSetOrder(2)
		If dbSeek(GW1->GW1_FILIAL+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+GW1->GW1_CDTPDC)
			Return "Nao e possivel excluir a nota fiscal pois a mesma esta vinculada a um Documento de Frete no GFE(Gestao de Frete Embarcador)."
		EndIf

		// Validação
		If !Empty(GW1->GW1_NRROM)
			dbSelectArea("GWN")
			dbSetOrder(1)
			If dbSeek(GW1->GW1_FILIAL+GW1->GW1_NRROM)
				// Validar se o romaneio possui cálculos vinculados a contrato com autônomo
				dbSelectArea("GWF")
				GWF->( dbSetOrder(4) )
				GWF->( dbSeek(xFilial("GWF") + GWN->GWN_NRROM) )
				While !GWF->( Eof() ) .And. GWF->GWF_FILIAL == xFilial("GWF") .And. GWF->GWF_NRROM == GWN->GWN_NRROM
					If !Empty(GWF->GWF_NRCONT)
						Return "Romaneio possui calculos vinculados a contrato e nao pode ser reaberto"
					EndIF

					dbSelectArea("GWJ")
					GWJ->( dbSetOrder(1) )
					If GWJ->( dbSeek(GWF->GWF_FILPRE + GWF->GWF_NRPREF) ).And. GWJ->GWJ_SIT <> "4"
						Return "Romaneio vinculado a uma Pre-fatura ainda ativa"
					EndIf

					GWF->( dbSkip() )
				EndDo

				If GWN->GWN_SIT == '4'
					Return "Nao e possivel excluir a nota fiscal pois a mesma esta vinculada a um Romaneio com situacao de encerrado no GFE(Gestao de Frete Embarcador)."
				EndIf

				If GWN->GWN_SIT == '3'
					lRetGWN := GFEABTREA()
					If lRetGWN
						cFilGW1  := GW1->GW1_FILIAL
						cTipoGW1 := GW1->GW1_CDTPDC
						cEmisGW1 := GW1->GW1_EMISDC
						cSerGW1  := GW1->GW1_SERDC
						cNumGW1  := GW1->GW1_NRDC
						ProcRoman(GWN->GWN_FILIAL, GWN->GWN_NRROM)
					EndIf
				ElseIf GWN->GWN_SIT < '3'
					cFilGW1  := GW1->GW1_FILIAL
					cTipoGW1 := GW1->GW1_CDTPDC
					cEmisGW1 := GW1->GW1_EMISDC
					cSerGW1  := GW1->GW1_SERDC
					cNumGW1  := GW1->GW1_NRDC
					ProcRoman(GWN->GWN_FILIAL, GWN->GWN_NRROM)
				EndIf
			EndIf
		Else
			cFilGW1  := GW1->GW1_FILIAL
			cTipoGW1 := GW1->GW1_CDTPDC
			cEmisGW1 := GW1->GW1_EMISDC
			cSerGW1  := GW1->GW1_SERDC
			cNumGW1  := GW1->GW1_NRDC
		EndIf

		dbSelectArea("GW1")
		dbSetOrder(1)
		If dbSeek(cFilGW1+cTipoGW1+cEmisGW1+cSerGW1+cNumGW1)
			dbSelectArea("GWU")
			dbSetOrder(1)
			dbSeek( GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC )
			While !Eof() .AND. GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC == ;
					GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC
				RecLock("GWU",.F.)
				dbDelete()
				MsUnlock()

				dbSkip()
			EndDo

			dbSelectArea("GW8")
			dbSetOrder(1)
			dbSeek( GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC )
			While !Eof() .AND. GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC == ;
					GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC

				RecLock("GW8",.F.)
				dbDelete()
				MsUnlock()

				dbSkip()
			EndDo

			dbSelectArea("GWH")
			dbSetOrder(2)
			If dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
				dbSelectArea("GWF")
				dbSetOrder(1)
				If dbSeek( GWH->GWH_FILIAL + GWH->GWH_NRCALC) .And. GWF->GWF_TPCALC == "8"
					GFEDelCalc(GWF->GWF_NRCALC)
				EndIf
			EndIf

			RecLock("GW1",.F.)
			dbDelete()
			MsUnlock()
		EndIf
	EndIf

Return "TRUE"

// Função responsável por realizar a exclusão a mudanção de situação do romaneio
Static Function ProcRoman(cFilRom, cNrRom)
	Local nContGW1 := 0
	Local cNumRom  := cNrRom
	Local cFilialRom := cFilRom

	dbSelectArea("GWN")
	dbSetOrder(1)
	If dbSeek(cFilialRom+cNumRom)
		dbSelectArea("GW1")
		dbSetOrder(9)
		If dbSeek(GWN->GWN_FILIAL+GWN->GWN_NRROM)
			While !Eof() .And. GW1->GW1_FILIAL + GW1->GW1_NRROM == GWN->GWN_FILIAL + GWN->GWN_NRROM
				nContGW1 += 1
				GW1->(dbSkip())
			EndDo
		EndIf
	EndIf

	GWF->(dbSetOrder(4))
	If GWF->(dbSeek(GWN->GWN_FILIAL + GWN->GWN_NRROM))
		GFEDelCalc(GWF->GWF_NRCALC, GWF->GWF_FILIAL)
	EndIf

	If nContGW1 > 1
		RecLock("GWN",.F.)
		GWN->GWN_CALC := "4"
		MsUnlock()
		If !Empty(GWN->GWN_VIAGEM)
			GFE58ATVG(GWN->GWN_VIAGEM,GWN->GWN_CALC,GWN->GWN_MTCALC,GWN->GWN_DTCALC,GWN->GWN_HRCALC,GWN->GWN_FILIAL,GWN->GWN_NRROM,.T.)
		EndIf
	Else
		RecLock("GWN",.F.)
		dbDelete()
		MsUnlock()
	EndIf

Return Nil

// Realiza o retorno do tipo de Item
Static Function BuscaTpIt(cChave,cFil)
	Local cCDTI1

	dbSelectArea("GUK")
	dbSetorder(1)
	If dbSeek( xFilial("GUK") + cChave ) .AND. !Empty(GUK->GUK_TPITEM)
		cCDTI1 := GUK->GUK_TPITEM
	EndIf

Return cCDTI1

// Realiza o retorno da classificação de frete
Static Function BuscaClasFrete(cChave,cFil)
	Local cCDCF := BuscaParam("MV_CDCLFR",cFil,"")

	dbSelectArea("GUK")
	dbSetorder(1)
	If dbSeek( xFilial("GUK") + cChave ) .AND. !Empty(GUK->GUK_CDCLFR)
		cCDCF := GUK->GUK_CDCLFR
	EndIf

Return cCDCF

// Função responsavel por contar o numero de registro de uma tabela que sejam de origem ERP e ativos caso a tabela possua essas opções
Function GFEX101CON(cTabela)
	Local cCont, cQuery, cTmp

	cQuery := ""
	cQuery += "SELECT COUNT(*) QTD FROM " + RetSQLName( cTabela ) + " TAB "
	cQuery += "WHERE TAB.D_E_L_E_T_ = ' ' "

	If cTabela $ "GU1/GU7/GUG/GUE/GUH/GWN/GU3/GU2/GW1/GV3"
		cQuery += "AND TAB."+cTabela+"_SIT = '1' "
	EndIf
	If cTabela $ "GW1/GU1"
		cQuery += "AND TAB."+cTabela+"_ORIGEM = '2' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	cTmp := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .T. )

	cCont :=  (cTmp)->QTD

	(cTmp)->(dbCloseArea())

Return cCont

// Função responsável por realizar o envio das integrações para o Datasul (CD0433)
Function GFEWSGETDATA(cTabela,cCodInt,cFil,cParte)
	Local nTemp 		:= 0
	Local nValorGWJ 	:= 0
	Local cValorPed		:= ""
	Local cDtDip
	Local cDtSit
	Local nValorFrete
	Local nCriRat 		:= GetNewPar("MV_CRIRAT", "1")
	Local nValorIcmsCred := 0
	Local cAdcINEM 		:= SuperGetMV('MV_ADINEM',,'2')
	Local nValorDoc
	Local cAliasQry 		:= ""
	Local cFilEnvi 		:= ""
	Local cObsCot  		:= ""
	Local cData			:= ""
	Local cHora			:= ""
	Local cNrPF 			:= ""
	Local lIntDocF 		:= SuperGetMv('MV_DSCTB',, '1') == "2"
	Local cCdEmitDoc 		:= ""
	Local cAliasGW8
	Local cAliasGW1
	Local aParamGW1	:= {}
	Local cPcPIS
	Local cPcCOFINS
	// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP(SuperGetMV)
	Local s_NRPF	:= SuperGetMv("MV_NRPF", .F., "1")
	Local s_VLCNPJ	:= SuperGetMV('MV_VLCNPJ',,'1')
	Local cString	:= ""
	Local cQuery	:= ""
	Local cTmp		:= ""
	Local nDINDEN   := 0

	Local nVlCalc
	Local nVlDif
	Local lGFEXWS16	:= ExistBlock("GFEXWS16")
	Local lGFEXWS17 := ExistBlock("GFEXWS17")

	Local cUltReg 	:= ""
	Local cAliasAux := ""
	Local cAliasCnt := ""
	Local cAliasGV5 := ""

	Local nCont     := 0
	Local aCidImp	:= {}
	Local aCidades	:= {}

	Local cTpImp    := ""
	Local nPos		:= 0

	Local cQueryGXF := ""
	Local cAliasGXF := ""
	Local nUltReg   := 0

	Local cNomCid	:= ""
	Local cUFCid	:= ""
	Local cAliasGU7 := ""

	Local cAliasGWM			:= ""
	Local cCampos			:= ""
	Local nVlTotIsento		:= 0
	Local nVlTotTributado	:= 0

	Local cBcoDados := Alltrim(TCGETDB())

	Local nBaseIRRF 	:= 0
	Local nMV_IRFPRED 	:= 0
	
	Local cImposto
	Local iPcImpGWF := 0	
	Local iPcImpDif	:= 0
	Local nVlImpGWF := 0	
	Local nVlImpDif := 0

	Private nVLPFat 		:= 0

	Default cParte := "1"

	If (cTabela == "GV8" .Or. cTabela == "GV7" .Or. cTabela == "GV1" .Or. cTabela == "GV6" .Or. cTabela == "GVQ" .Or. cTabela == "GVA")
		cQuery := QueryBase("GV9",cFil)
	Else
		cQuery := QueryBase(cTabela,cFil)
	EndIf

	// Início Ponto de Entrada Procomp
	If ExistBlock("GFEXWS07")
		cQuery += ExecBlock("GFEXWS07",.f.,.f.,{cTabela,cCodInt})
	EndIf
	// Fim Ponto de Entrada Procomp

	Do Case //Situação Pendente ou Pendente Desatualização
	Case cTabela == "GWJ" .AND. cCodInt == '2'
		// Pré-Fatura e Cod integração seja Financeiro
		cQuery += " AND (TAB.GWJ_SITFIN = '2' OR TAB.GWJ_SITFIN = '5') "
	Case cTabela == "GW6"  .AND. cCodInt == '2'
		// Fatura e Cod integração seja Financeiro
		cQuery += " AND (TAB.GW6_SITFIN = '2' OR TAB.GW6_SITFIN = '5') "
	Case cTabela == "GW6" .AND. cCodInt == '6' // PCREQ-9324
		// Fatura e Integração com MLA (8=Atualizar;2=Pendente;Desatualizar)
		cQuery += " AND (TAB.GW6_SITMLA = '8' OR TAB.GW6_SITMLA = '2' OR TAB.GW6_SITMLA = '5') "
	Case cTabela == "GW3" .AND. cCodInt == '1'
		// Doc Frete e Cod integração seja Fiscal
		cQuery += " AND (TAB.GW3_SITFIS = '2' OR TAB.GW3_SITFIS = '5') "
	Case cTabela == "GW3" .AND. cCodInt == '3'
		// Doc Frete e Cod integração seja Recebimento
		cQuery += " AND (TAB.GW3_SITREC = '2' OR TAB.GW3_SITREC = '5') "
	Case cTabela == "GW3" .AND. cCodInt == '6' // PCREQ-9324
		// Doc Frete e Integração com MLA (8=Atualizar;2=Pendente;Desatualizar)
		cQuery += " AND (TAB.GW3_SITMLA = '8' OR TAB.GW3_SITMLA = '2' OR TAB.GW3_SITMLA = '5') "
	Case cTabela == "GW2" .AND. cCodInt == '2'
		// Contratos e Cod integração seja Financeiro
		cQuery += " AND (TAB.GW2_SITFIN = '2' OR TAB.GW2_SITFIN = '5') "
	Case cTabela == "GW2" .AND. cCodInt == '3'
		// Contratos e Cod integração seja Recebimento
		cQuery += " AND (TAB.GW2_SITREC = '2' OR TAB.GW2_SITREC = '5') "
	Case cTabela == "GW2" .AND. cCodInt == '4'
		// Contratos e Cod integração seja RH
		cQuery += " AND (TAB.GW2_SITRH = '2' OR TAB.GW2_SITRH = '5') "
	Case cTabela == "GW1" .AND. cCodInt == '5' .AND. GfeVerCmpo({"GW1_SITFT"})
		// Integração com o Faturamento / Data de saída
		cQuery += " AND (TAB.GW1_SITFT = '2' OR TAB.GW1_SITFT = '5') "
	Case cTabela == "GW1" .AND. cCodInt == '6' .AND. GfeVerCmpo({"GW1_SITFT2"})
		// Integração com o Faturamento / Data de entrega
		cQuery += " AND (TAB.GW1_SITFT2 = '2' OR TAB.GW1_SITFT2 = '5') "
		// Integração com MLA (Aprovação de Tabelas de Frete)
	Case (cTabela == "GV9" .Or. cTabela == "GV8" .Or. cTabela == "GV7" .Or. cTabela == "GV1" .Or. cTabela == "GV6" .Or. cTabela == "GVQ" .Or. cTabela == "GVA");
			.And. cCodInt == "6"
		// Negociação e Integração com MLA (8=Atualizar;2=Pendente;5=Desatualizar)
		cQuery += " AND (TAB.GV9_SITMLA = '8' OR TAB.GV9_SITMLA = '2' OR TAB.GV9_SITMLA = '5') "
	Case (cTabela == "GV9" .Or. cTabela == "GV8" .Or. cTabela == "GV7" .Or. cTabela == "GV1" .Or. cTabela == "GV6" .Or. cTabela == "GVQ" .Or. cTabela == "GVA");
			.And. cCodInt == "7" .And. GFXCP12117("GV9_SITCON") == .T.
		// Integração da Negociação de Frete para Consulta Datasul (2=Pendente)
		cQuery += " AND (TAB.GV9_SITCON = '2' OR TAB.GV9_SITCON = '5') "
	Case cTabela == "GW1" .And. cCodInt == "7" .And. GFXCP12117("GW1_SITFRE") == .T.
		cQuery += " AND GW1_SITFRE = '2'"
	EndCase

	cQuery += " ) "

	// Início Ponto de Entrada Procomp
	If lGFEXWS17
		cQuery := ExecBlock("GFEXWS17",.f.,.f.,{cTabela,cFil,cCodInt,cQuery})
	EndIf
	// Fim Ponto de Entrada Procomp

	cQuery := ChangeQuery(cQuery)
	cTmp   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

	If (cTmp)->(Eof())
		// Provisão de frete, caso não tenha pré-faturas para integrar, procurar por Lotes de provisão
		If cTabela == "GWJ" .AND. cCodInt == '2' .And. TemTabProv()
			(cTmp)->(dbCloseArea())

			cTabela := "GXE"

			cQuery := QueryBase(cTabela,cFil)
			cQuery += " AND (TAB.GXE_SIT = '2' OR TAB.GXE_SIT = '5' OR TAB.GXE_SIT = '7')  ) "

			cQuery := ChangeQuery(cQuery)
			cTmp   := GetNextAlias()
			dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

			If (cTmp)->(Eof())
				(cTmp)->(dbCloseArea())
				Return "#NRD#" // Nenhum registro disponivel
			EndIf

		Else
			(cTmp)->(dbCloseArea())
			Return "#NRD#" // Nenhum registro disponivel
		EndIf
	EndIf

	// Início Ponto de Entrada Procomp
	If ExistBlock("GFEXWS08")
		cString := ExecBlock("GFEXWS08",.f.,.f.,{cTabela,cQuery})
	EndIf
	// Fim Ponto de Entrada Procomp

	Do Case
		// Documento de Carga
	Case cTabela == "GW1" .AND. cCodInt == '5'
		cString := "#GW1|"
		cString += (cTmp)->GW1_FILIAL + "|"
		cString += (cTmp)->GW1_CDTPDC + "|"
		cString += (cTmp)->GW1_EMISDC + "|"
		cString += (cTmp)->GW1_SERDC  + "|"
		cString += (cTmp)->GW1_NRDC   + "|"
		cString += (cTmp)->GW1_DTEMIS + "|"
		cString += (cTmp)->GW1_SITFT  + "|"
		cString += (cTmp)->GW1_DTSAI  + "|"
		cString += (cTmp)->GW1_HRSAI  + "|"
		// Documento de Carga (Data Entrega)
	Case cTabela == "GW1" .AND. cCodInt == '6'
		// INI - Pega Data e Hora do Ultimo Trecho
		dbSelectArea("GWU")
		GWU->( dbSetOrder(1) )
		GWU->( dbSeek( (cTmp)->GW1_FILIAL + (cTmp)->GW1_CDTPDC + (cTmp)->GW1_EMISDC + (cTmp)->GW1_SERDC + (cTmp)->GW1_NRDC ) )
		While !GWU->( Eof() ) .AND.	(cTmp)->GW1_FILIAL + (cTmp)->GW1_CDTPDC + (cTmp)->GW1_EMISDC + (cTmp)->GW1_SERDC + (cTmp)->GW1_NRDC == ;
				GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC

			If !Empty(GWU->GWU_DTENT)
				cData := DTOS(GWU->GWU_DTENT)
			EndIf

			If !Empty(StrTran(GWU->GWU_HRENT,":",""))
				cHora := GWU->GWU_HRENT
			EndIf

			GWU->( dbSkip() )
		EndDo
		// FIM - Pega Data e Hora do Ultimo Trecho

		cString := "#GW1|"
		cString += (cTmp)->GW1_FILIAL + "|"
		cString += (cTmp)->GW1_CDTPDC + "|"
		cString += (cTmp)->GW1_EMISDC + "|"
		cString += (cTmp)->GW1_SERDC  + "|"
		cString += (cTmp)->GW1_NRDC   + "|"
		cString += (cTmp)->GW1_DTEMIS + "|"
		cString += (cTmp)->GW1_SITFT2 + "|"
		cString += cData + "|"
		cString += cHora + "|"
		// Fatura de Frete integrando com o Financeiro
	Case cTabela == "GW6" .And. cCodInt != "6"
		nTemp := 0

		GW3->(dbSetOrder(8)) //GW3_FILFAT+GW3_EMIFAT+GW3_SERFAT+GW3_NRFAT+DTOS(GW3_DTEMFA)
		If GW3->(dbSeek((cTmp)->GW6_FILIAL + (cTmp)->GW6_EMIFAT + (cTmp)->GW6_SERFAT + (cTmp)->GW6_NRFAT + (cTmp)->GW6_DTEMIS))
			While !GW3->(Eof()) .And. GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DToS(GW3->GW3_DTEMFA) == (cTmp)->GW6_FILIAL + (cTmp)->GW6_EMIFAT + (cTmp)->GW6_SERFAT + (cTmp)->GW6_NRFAT + (cTmp)->GW6_DTEMIS
				If GW3->GW3_TPDF == '3' .And. GW3->GW3_TPIMP == '2'
					nTemp += GW3->GW3_VLIMP
				EndIf

				//Envio dos dados de impostos retidos acumulados
				cTpImp := Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP")

				    /* Array com dados da Cidade e UF da Origem e Destino dos TRECHOS - Ato Cotepe 48
				    aCidades[1][1] - Cidade Origem do Transporte
				    aCidades[1][2] - Cidade Destino do Transporte */

					If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
		   			   !(Empty(GW3->GW3_MUNINI) .And. Empty(GW3->GW3_UFINI) .And. Empty(GW3->GW3_MUNFIM) .And. Empty(GW3->GW3_UFFIM))   			   					   
						  
						aAdd(aCidades, {GW3->GW3_MUNINI, GW3->GW3_MUNFIM})
					Else			
						aCidades := (GFEWSCITY( GW3->GW3_FILIAL, GW3->GW3_EMISDF, GW3->GW3_CDESP, GW3->GW3_SERDF, GW3->GW3_NRDF, DTOS(GW3->GW3_DTEMIS), GW3->GW3_TPDF))
					EndIf

					nPos := 0

					If cTpImp == "1"
						nPos := aScan(aCidImp, {|x| x[1] == "1"})

						If nPos == 0
							//Array contendo as cidades onde ocorreram as movimenteações 
							aAdd(aCidImp,{cTpImp , AllTrim(aCidades[1][1]), AllTrim(aCidades[1][2]), cValToChar(GW3->GW3_BASIMP), cValToChar(GW3->GW3_PCRET), cValToChar(GW3->GW3_IMPRET)} ) 
						Else
							aCidImp[nPos][4] := cValToChar(Val(aCidImp[nPos][4]) + GW3->GW3_BASIMP)
							aCidImp[nPos][6] := cValToChar(Val(aCidImp[nPos][6]) + GW3->GW3_IMPRET) 
						EndIf
					Else
						nPos := aScan(aCidImp, {|x| x[2] + x[3] == AllTrim(aCidades[1][1]) + AllTrim(aCidades[1][2])})

						If nPos == 0
							//Array contendo as cidades onde ocorreram as movimenteações 
							aAdd(aCidImp,{cTpImp , AllTrim(aCidades[1][1]), AllTrim(aCidades[1][2]), cValToChar(GW3->GW3_BASIMP), cValToChar(GW3->GW3_PCRET), cValToChar(GW3->GW3_IMPRET)} ) 
						Else
							aCidImp[nPos][4] := cValToChar(Val(aCidImp[nPos][4]) + GW3->GW3_BASIMP)
							aCidImp[nPos][6] := cValToChar(Val(aCidImp[nPos][6]) + GW3->GW3_IMPRET) 
						EndIf
					EndIf
								 			
					GW3->(DbSkip())
				EndDo
			EndIf
				
			If GFXCP12118("GW6_DINDEN") 
				nDINDEN := (cTmp)->GW6_DINDEN			
			EndIf

			cString := "#GW6|"
			cString += (cTmp)->GW6_FILIAL 			+ "|"
			cString += (cTmp)->GW6_EMIFAT 			+ "|"
			cString += (cTmp)->GW6_SERFAT 			+ "|"
			cString += (cTmp)->GW6_NRFAT  			+ "|"
			cString += (cTmp)->GW6_DTEMIS 			+ "|"
			cString += (cTmp)->GW6_DTVENC 			+ "|"
			cString += STR((cTmp)->GW6_VLFATU) 		+ "|"
			cString += STR((cTmp)->GW6_VLICRE) 		+ "|"
			cString += STR((cTmp)->GW6_VLISRE) 		+ "|"
			cString += (cTmp)->GW6_SITFIN 			+ "|"
			cString += (cTmp)->GW6_DTFIN   			+ "|"
			cString += BuscaParam("MV_MATREX",(cTmp)->GW6_FILIAL,"")    + "|"
			cString += IIF( (cTmp)->GW6_ORIGEM=="3" ,BuscaParam("MV_DSESCT",(cTmp)->GW6_FILIAL,""), GETNEWPAR("MV_DSESPF","") )   + "|"
			cString += BuscaParam("MV_DSICCD",(cTmp)->GW6_FILIAL,"")  	+ "|"
			cString += BuscaParam("MV_DSICCL",(cTmp)->GW6_FILIAL,"")	+ "|"
			cString += BuscaParam("MV_DSISCD",(cTmp)->GW6_FILIAL,"")	+ "|"
			cString += BuscaParam("MV_DSISCL",(cTmp)->GW6_FILIAL,"")    + "|"
			cString += cvaltochar((cTmp)->GW6_VLDESC + nDINDEN)			+ "|"
	
			If GFXCP12137('GW6_FILTOM')
				cString += (cTmp)->GW6_FILTOM   	+ "|"
			Else
				cString += " |"
			EndIf

			If GFXCP12137("GW6_VLIRRF")
				If (cTmp)->GW6_VLIRRF > 0
					nMV_IRFPRED := BuscaParam("MV_IRFPRED",(cTmp)->GW6_FILIAL,"")
					nBaseIRRF 	:= (cTmp)->GW6_VLFATU - ((cTmp)->GW6_VLFATU * (nMV_IRFPRED / 100))

					cString += cValToChar((cTmp)->GW6_VLIRRF) + "|"
					cString += cValToChar(nBaseIRRF) + "|"
					cString += BuscaParam("MV_DSIRCD",(cTmp)->GW6_FILIAL,"")   		+ "|"
					cString += BuscaParam("MV_DSIRCL",(cTmp)->GW6_FILIAL,"")     	+ "|"
				Else
					cString += "0|0|||"
				EndIf
			Else
				cString += "0|0|||"
			EndIf

			For nCont := 1 to len(aCidImp)
				cAliasGU7 := GetNextAlias()

				BeginSQL Alias cAliasGU7
					SELECT GU7.GU7_NMCID, GU7.GU7_CDUF
					FROM %Table:GU7% GU7
					WHERE GU7.GU7_NRCID = %Exp:aCidImp[nCont][2]%
					AND GU7.%NotDel%
				EndSQL

				If (cAliasGU7)->(!EoF())
					cNomCid := AllTrim((cAliasGU7)->GU7_NMCID)
					cUFCid	:= (cAliasGU7)->GU7_CDUF
				EndIf

				(cAliasGU7)->(dbCloseArea())			

			    cString += "#GW3|" + aCidImp[nCont][1] + "|" + aCidImp[nCont][2] + "|" + aCidImp[nCont][3] + "|" + aCidImp[nCont][4] + "|" + aCidImp[nCont][5] + "|" + aCidImp[nCont][6] + "|" + cNomCid + "|" + cUFCid	    
		    next ncont   
	
			If BuscaParam("MV_GFEI15",(cTmp)->GW6_FILIAL,"3") != "3" // Se integrar a pré-fatura
				dbSelectArea("GWJ")
				dbSetorder(7)
				dbSeek( (cTmp)->GW6_FILIAL + (cTmp)->GW6_EMIFAT + (cTmp)->GW6_SERFAT + (cTmp)->GW6_NRFAT  + (cTmp)->GW6_DTEMIS )
		
				While !Eof() .AND. (cTmp)->GW6_FILIAL + (cTmp)->GW6_EMIFAT + (cTmp)->GW6_SERFAT + (cTmp)->GW6_NRFAT  + (cTmp)->GW6_DTEMIS == ;
						GWJ->GWJ_FILFAT + GWJ->GWJ_EMIFAT + GWJ->GWJ_SERFAT + GWJ->GWJ_NRFAT + DTOS(GWJ->GWJ_DTEMFA)
		
							// Busca o valor da pré-fatura
					nValorGWJ := 0
					dbSelectArea("GWF")
					dbSetOrder(3)
					dbSeek(GWJ->GWJ_FILFAT + GWJ->GWJ_NRPF)
					While !GWF->( Eof() ) .AND. GWF->GWF_FILPRE == GWJ->GWJ_FILFAT .AND. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
						nValorGWJ += VLTOTFRET()
						GWF->(dbSkip())
					EndDo
							
					If s_NRPF == "2"
						cNrPF := GWJ->GWJ_FILIAL + GWJ->GWJ_NRPF
					Else
						cNrPF := GWJ->GWJ_NRPF
					EndIf
							
					cString += "#GWJ|"+GWJ->GWJ_FILIAL+"|"+BuscaParam("MV_DSEPRO",(cTmp)->GW6_FILIAL,"") + "|" + cNrPF + "|" + AllTrim(STR(nValorGWJ))
					cNrPF := ""
					GWJ->(dbSkip())
				EndDo
			EndIf
			dbSelectArea("GW7")
			dbSetOrder(1)
			dbSeek((cTmp)->GW6_FILIAL  + (cTmp)->GW6_EMIFAT + (cTmp)->GW6_SERFAT + (cTmp)->GW6_NRFAT  + (cTmp)->GW6_DTEMIS )
	
			While !Eof() .AND. (cTmp)->GW6_EMIFAT + (cTmp)->GW6_SERFAT + (cTmp)->GW6_NRFAT  + (cTmp)->GW6_DTEMIS == ;
					GW7->GW7_EMIFAT + GW7->GW7_SERFAT + GW7->GW7_NRFAT + DTOS(GW7->GW7_DTEMIS)
	
				If GW7->GW7_LANCTO == '1'
					cString += "#GW7|"+GW7->GW7_CCUSTO+"|"+GW7->GW7_CTACTB+"|"+GW7->GW7_UNINEG+"|"+STR(GW7->GW7_VLMOV)
				EndIf
	
				GW7->(dbSkip())
			EndDo
		// Fatura de Frete integrando com o MLA
		Case cTabela == "GW6" .And. cCodInt == "6"
			If SuperGetMv("MV_FTMLA",.F.,"1") == "3" // Considera a diferença na aprovação do documento de frete por MLA
					// Carrega a variável Private nVLPFat
				(cTmp)->(GFEA071PF(RetFilTab("GW6",GW6_FILIAL),GW6_EMIFAT,GW6_SERFAT,GW6_NRFAT,StoD(GW6_DTEMIS)))
					
				nValorEnv := ((cTmp)->GW6_VLFATU - nVLPFat)
			Else
				nValorEnv := (cTmp)->GW6_VLFATU
			EndIf
				
			If GFXCP12118("GW6_DINDEN") 
				nDINDEN := (cTmp)->GW6_DINDEN			
			EndIf	
				
			cString := "#GW6|"
			cString += (cTmp)->GW6_FILIAL + "|"
			cString += (cTmp)->GW6_EMIFAT + "|"
			cString += (cTmp)->GW6_SERFAT + "|"
			cString += (cTmp)->GW6_NRFAT  + "|"
			cString += (cTmp)->GW6_DTEMIS + "|"
			cString += cValtoChar(nValorEnv) + "|"
			cString += cValtoChar((cTmp)->GW6_VLDESC + nDINDEN) + "|"
			cString += cValtoChar((cTmp)->GW6_VLICMS) + "|"
			cString += cValtoChar((cTmp)->GW6_VLICRE) + "|"
			cString += cValtoChar((cTmp)->GW6_VLISS)  + "|"
			cString += cValtoChar((cTmp)->GW6_VLISRE) + "|"
			cString += cValtoChar((cTmp)->GW6_VLJURO) + "|"
			cString += (cTmp)->GW6_DTCRIA + "|"
			cString += (cTmp)->GW6_DTVENC + "|"
			cString += (cTmp)->GW6_ORIGEM + "|"
			cString += (cTmp)->GW6_SITAPR + "|"
			cString += (cTmp)->GW6_DTBLOQ + "|"
			cString += (cTmp)->GW6_HRBLOQ + "|"
			cString += Iif(BuscaParam("MV_FTMLA",(cTmp)->GW6_FILIAL,"1")=="4",AllTrim((cTmp)->GW6_USUIMP),AllTrim((cTmp)->GW6_USUBLO)) + "|" // Código do usuário
			// Posiciona para pegar os campos tipo MEMO, o select não traz.
			GW6->(dbGoto( (cTmp)->R_E_C_N_O_ ))
			cString += FwCutOff(GW6->GW6_MOTBLO,.T.) + "|"
			cString += FwCutOff(GW6->GW6_OBS,.T.)    + "|"
			cString += (cTmp)->GW6_SITMLA + "|"	
			cString += BuscaParam("MV_FTMLA",(cTmp)->GW6_FILIAL,"1") + "|" 
			
			If GFXCP12137('GW6_FILTOM')
				cString += (cTmp)->GW6_FILTOM   	+ "|"
			EndIf

			// Início Ponto de Entrada Ellece
			If ExistBlock("GFEXWS12")
				cString += ExecBlock("GFEXWS12",.F.,.F.,{(cTmp)->GW6_FILIAL, (cTmp)->GW6_EMIFAT, (cTmp)->GW6_SERFAT, (cTmp)->GW6_NRFAT, (cTmp)->GW6_DTEMIS})
			EndIf
			// Fim Ponto de Entrada Ellece	  
			
		// Pré-fatura com o Financeiro		
		Case cTabela == "GWJ" .AND. cCodInt == "2"
			//	Busca o valor do parâmetro para verificar se será contabilizado pelo valor bruto ou pelo valor líquido.
			// "1=Despesa Total","2=Despesa menos Impostos Recuperáveis","3=Despesa menos Impostos","4=Despesa e Impostos Recuperáveis"
			cParamCont := SuperGetMv("MV_PROVCON",.F., "1")
				
			dbSelectArea("GWJ")
			dbSetOrder(1)
			If dbSeek((cTmp)->GWJ_FILIAL + (cTmp)->GWJ_NRPF )
				nTemp := GFEA055VL()
			Else
				nTemp := 0
			EndIf
				
			If SuperGetMv("MV_NRPF", .F., "1") == "2"
				cNrPF := (cTmp)->GWJ_FILIAL + (cTmp)->GWJ_NRPF
			Else
				cNrPF := (cTmp)->GWJ_NRPF
			EndIf
	
			cString :=  "#GWJ|"
			cString +=  (cTmp)->GWJ_FILIAL        	+ "|"
			cString +=  (cTmp)->GWJ_CDTRP         	+ "|"
			cString +=  cNrPF 	         		   	+ "|"
			cString +=  (cTmp)->GWJ_DTIMPL  		+ "|"
			cString +=  (cTmp)->GWJ_DTVCTO  		+ "|"
			cString +=  cValToChar(GFEValPF(Alltrim((cTmp)->GWJ_FILIAL), Alltrim((cTmp)->GWJ_NRPF))) + "|"
			cString +=  (cTmp)->GWJ_DTFIN	   		+ "|"
			cString +=  (cTmp)->GWJ_SITFIN       	+ "|"
			cString +=  BuscaParam("MV_DSEPRO",(cTmp)->GWJ_FILIAL ,"") + "|"
			cString +=  BuscaParam("MV_MATREX",(cTmp)->GWJ_FILIAL ,"")
				
			cNrPF := ""
				
			dbSelectArea("GWK")
			dbSetOrder(1)
			dbSeek( (cTmp)->GWJ_FILIAL + (cTmp)->GWJ_NRPF )
				
			While !Eof() .AND. (cTmp)->GWJ_FILIAL + (cTmp)->GWJ_NRPF == GWK->GWK_FILIAL + GWK->GWK_NRPF
				If GWK->GWK_LANCTO == '1'
					cString += "#GWK|"+GWK->GWK_CCUSTO+"|"+GWK->GWK_CTACTB+"|"+GWK->GWK_UNINEG+"|"+STR(GWK->GWK_VLMOV)
				EndIf
					
				GWK->(dbSkip())
			EndDo		
		// Lote de Provisão
		Case cTabela == "GXE" .AND. cCodInt == "2"

			lNotExGXN := .T.

			// Devido a uma validação no DATASUL, a data de transação não pode ser menor que a data de emissão 
	    	cDtDip := DTOS(GFEA096DIP((cTmp)->GXE_PERIOD))
	    	If (cTmp)->GXE_DTSIT < cDtDip
	    		cDtSit := (cTmp)->GXE_DTSIT
	    	Else
	    		cDtSit := cDtDip
	    	EndIf
	    	
	    	// Quando for estorno, cDtDip é usado no lugar de cDtSit.
	    	// A data do estorno deve ser o último dia do mês seguinte ao período do lote e menor que a DDATABASE
	    	
	    	cDtDip := DTOS(GFEA096DIP((cTmp)->GXE_PERIOD,1))
	    	
	    	If DTOS(DDATABASE) < cDtDip
	    		cDtDip := DTOS(DDATABASE)
	    	EndIf
	    	
	    	If (cTmp)->GXE_SIT == "2" .OR. (cTmp)->GXE_SIT == "5" 
		    	cString := "#GWJ|"
		    	cString += (cTmp)->GXE_FILIAL 									+ "|"
		    	cString += (cTmp)->GXE_CDEMIT 									+ "|"
		    	cString += (cTmp)->GXE_CODLOT 									+ "|"
		    	cString += cDtSit								  				+ "|" //Ultimo dia do período,Data de Emissão
		    	cString += DTOS(GFEA096DIP((cTmp)->GXE_PERIOD,1))				+ "|" //Ultimo dia do período do próximo mes,Data de Vencimento
		    	cString += STR(GFEA096VL((cTmp)->GXE_FILIAL,(cTmp)->GXE_CODLOT))+ "|"
		    	cString += If((cTmp)->GXE_SIT == '5',cDtDip,cDtSit)				+ "|" //Data de Transação
		    	cString += (cTmp)->GXE_SIT	 									+ "|"
		    	cString +=  BuscaParam("MV_DSEPRO",(cTmp)->GXE_FILIAL ,"")  	+ "|"
				cString +=  BuscaParam("MV_MATREX",(cTmp)->GXE_FILIAL ,"")

				cQueryGXF := "SELECT TOP 100"			
				cQueryGXF += " GXF.R_E_C_N_O_ GXFRECNO," 
				cQueryGXF += " GXF.GXF_CCUSTO,"
				cQueryGXF += " GXF.GXF_CONTA,"
				cQueryGXF += " GXF.GXF_UNINEG,"
				cQueryGXF += " GXF.GXF_VALOR"
				cQueryGXF += " FROM " + RetSQLName("GXF") + " GXF"
				cQueryGXF += " WHERE GXF.GXF_FILIAL = '" + (cTmp)->GXE_FILIAL + "'"
				cQueryGXF += " AND GXF.GXF_CODLOT = '" + (cTmp)->GXE_CODLOT + "'"
				If !(cParte == "1")
					cQueryGXF += " AND GXF.R_E_C_N_O_ > '" + cParte + "' "
				EndIf
				cQueryGXF += " AND GXF.D_E_L_E_T_ = ' '"
				cQueryGXF += " ORDER BY GXF.R_E_C_N_O_"					

				cQueryGXF := ChangeQuery(cQueryGXF)
				cAliasGXF := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQueryGXF), cAliasGXF, .T., .F. )

				Do While (cAliasGXF)->(!Eof())
					cString += "#GWK|"+(cAliasGXF)->GXF_CCUSTO+"|"+(cAliasGXF)->GXF_CONTA+"|"+(cAliasGXF)->GXF_UNINEG+"|"+STR((cAliasGXF)->GXF_VALOR)+"|"

					nUltReg := (cAliasGXF)->GXFRECNO

					(cAliasGXF)->(dbSkip())
				EndDo

				(cAliasGXF)->(dbCloseArea())
				
				cQueryGXF := " SELECT TOP 1 GXF.R_E_C_N_O_ GXFRECNO"				
				cQueryGXF += " FROM " + RetSqlName("GXF") + " GXF"
				cQueryGXF += " WHERE GXF.GXF_FILIAL = '" + (cTmp)->GXE_FILIAL + "'"
				cQueryGXF += " AND GXF.GXF_CODLOT = '" + (cTmp)->GXE_CODLOT + "'"
				cQueryGXF += " AND GXF.R_E_C_N_O_ > '" + cValToChar(nUltReg) + "' "
				cQueryGXF += " AND GXF.D_E_L_E_T_ = ' '"
				cQueryGXF += " ORDER BY GXF.R_E_C_N_O_"
				
				cQueryGXF := ChangeQuery(cQueryGXF)
				
				cAliasAux := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TcGenQry(,,cQueryGXF), cAliasAux, .T., .F. )
				
				If (cAliasAux)->(!EoF())
					cString += "$" + cValToChar(nUltReg) + "$"
				EndIf
				
				(cAliasAux)->(dbCloseArea())

				lNotExGXN := .F.
			EndIf
			
			If (cTmp)->GXE_SIT == "7" .And. GFXTB12117("GXN") == .T. .And. GFXTB12117("GXO") == .T.
				cString := ""
				//Atribui os sublotes de estorno
				dbSelectArea( "GXN" )
				dbSetorder( 01 )
				If GXN->(dbSeek( (cTmp)->GXE_FILIAL + (cTmp)->GXE_CODLOT ))
					While GXN->(!Eof()) .AND. GXN->GXN_FILIAL == (cTmp)->GXE_FILIAL .And. GXN->GXN_CODLOT == (cTmp)->GXE_CODLOT
					
						IF GXN->GXN_SIT == '2' .Or. GXN->GXN_SIT == '5'
						
							cString +=  "#GXN|"
							cString +=  AllTrim(GXN->GXN_FILIAL) + "|"
							
							aArea := GetArea()
							
							dbSelectArea( "GXE" )
							dbSetOrder( 01 )
							If dbSeek( GXN->GXN_FILIAL + GXN->GXN_CODLOT )
								cString +=  AllTrim(GXE->GXE_CDEMIT) + "|"
							EndIf
							
							RestArea ( aArea )
							
							cString += AllTrim(GXN->GXN_CODLOT) + "|"
							cString += DTOS(GXN->GXN_DTCRIA) + "|"
							cDtDip := DTOS(GFEA096DIP(GXN->GXN_PERIES))
					    	If DTOS(GXN->GXN_DTCRIA) < cDtDip
					    		cDtSit := DTOS(GXN->GXN_DTCRIA)
					    	Else
					    		cDtSit := cDtDip
					    	EndIf
				
					    	cDtDip := DTOS(GFEA096DIP(GXN->GXN_PERIES,1))
					    	
					    	If DTOS(DDATABASE) < cDtDip
					    		cDtDip := DTOS(DDATABASE)
					    	EndIf
				
					    	cString +=  If(GXN->GXN_SIT == '5',cDtDip,cDtSit) + "|" //Data de Transação
							cString +=  STR(GFEA105VL( GXN->GXN_FILIAL,GXN->GXN_CODLOT, GXN->GXN_CODEST)) + "|"
							cString +=  AllTrim(GXN->GXN_SIT) + "|"
							cString +=	BuscaParam("MV_DSEPRO",GXN->GXN_FILIAL,"") + "|"
							cString +=	BuscaParam("MV_MATREX",GXN->GXN_FILIAL,"") + "|"
							cString +=  AllTrim(GXN->GXN_CODEST) + "|"
							
							//Atribui os lançamentos de estorno
							dbSelectArea( "GXO" )
							dbSetorder( 01 )
							If GXO->(dbSeek( GXN->GXN_FILIAL + GXN->GXN_CODLOT ))
								While GXO->(!Eof()) .AND. GXO->GXO_FILIAL == GXN->GXN_FILIAL .And. GXO->GXO_CODLOT == GXN->GXN_CODLOT .And. GXO->GXO_CODEST == GXN->GXN_CODEST
									cString +=  "#GXO|"
									cString +=  AllTrim(GXO->GXO_CCUSTO) + "|"
									cString +=  AllTrim(GXO->GXO_CONTA) + "|"
									cString +=  AllTrim(GXO->GXO_UNINEG) + "|"
									cString +=  AllTrim(STR(GXO->GXO_VALOR)) + "|"
									GXO->(dbSkip())
								EndDo
							EndIf
							lNotExGXN := .F.
						EndIf
						
						GXN->(dbSkip())
					EndDo
					
				EndIf
				
				If lNotExGXN //Se não encontrar registro
					cString += "#NRD#" //Nenhum registro disponivel
				EndIf
					
			EndIf
		// Documento de Frete integrando com o Fiscal
		Case cTabela == "GW3" .AND. cCodInt == "1"
		
		   //DEFINIÇÃO DOS VALORES PIS COFINS
		   	GU3->( dbSetOrder(1) )
			GU3->( DBSeek(xFilial("GU3") + (cTmp)->GW3_EMISDF) )	
				
		   If GU3->GU3_TPTRIB == "2"  //Percentual reduzido de PIS/COFINS para transp. com reg. SIMPLES		    
			   cPcPIS := STR(GetNewPar('MV_PISDIF',0))
			   cPcCOFINS := STR(GetNewPar('MV_COFIDIF',0))
		   Else 
		   	   cPcPIS := STR(GetNewPar('MV_PCPIS',0))
		   	   cPcCOFINS := STR(GetNewPar('MV_PCCOFI',0))
		   EndIf		
		
			cString := "#GW3|"
			cString += (cTmp)->GW3_FILIAL        + "|"
			cString += (cTmp)->GW3_CDESP         + "|"
			cString += (cTmp)->GW3_EMISDF        + "|"
			cString += (cTmp)->GW3_SERDF         + "|"
			cString += (cTmp)->GW3_NRDF          + "|"
			cString += (cTmp)->GW3_DTEMIS  		 + "|"
			cString += (cTmp)->GW3_DTFIS    		 + "|" //Alteração de GW3_DTENT para GW3_DTFIS
			cString += (cTmp)->GW3_CFOP          + "|"
			cString += (cTmp)->GW3_CTE           + "|"
			cString += (cTmp)->GW3_NATFRE        + "|"
			cString += GetNewPar('MV_DSOFIT','',(cTmp)->GW3_FILIAL) + "|"
			cString += POSICIONE("GVT",1,XFILIAL("GVT")+(cTmp)->GW3_CDESP,"GVT_TPIMP")          + "|"
			cString += (cTmp)->GW3_TRBIMP        + "|"
			cString += STR((cTmp)->GW3_VLDF  )   + "|"
			cString += STR((cTmp)->GW3_BASIMP)   + "|"
			cString += STR((cTmp)->GW3_PCIMP )   + "|"
			cString += STR((cTmp)->GW3_VLIMP )   + "|"
			cString += STR((cTmp)->GW3_PEDAG)    + "|"
			cString += (cTmp)->GW3_PDGFRT        + "|"
			cString += (cTmp)->GW3_ICMPDG        + "|"
			cString += (cTmp)->GW3_CRDPC         + "|"
			cString += STR((cTmp)->GW3_BASPIS)   + "|"
			cString += cPcPIS 					  + "|"
			cString += STR((cTmp)->GW3_VLPIS )   + "|"
	        cString += STR((cTmp)->GW3_BASCOF)   + "|"
			cString += cPcCOFINS				     + "|"
			cString += STR((cTmp)->GW3_VLCOF )   + "|" 
			cString += (cTmp)->GW3_SITFIS + "|"
			cString += (cTmp)->GW3_CRDICM + "|"
			cString += STR((cTmp)->GW3_IMPRET) + "|"
			cString += (cTmp)->GW3_TPCTE			+ "|"
			cString += (cTmp)->GW3_NATFRE       + "|"
				
			dbSelectArea("GW4")
			GW4->( dbSetOrder(1) )
			GW4->( dbSeek((cTmp)->GW3_FILIAL + (cTmp)->GW3_EMISDF + (cTmp)->GW3_CDESP + (cTmp)->GW3_SERDF + (cTmp)->GW3_NRDF) )
				
			dbSelectArea("GV5")
			GV5->( dbSetOrder(1) )
				
			If GV5->( dbSeek(xFilial("GV5") + GW4->GW4_TPDC) ) .And. GV5->GV5_SENTID == "2"
				cCdEmitDoc := (cTmp)->GW3_CDDEST				
			Else 			
				cCdEmitDoc := (cTmp)->GW3_CDREM				
			EndIf
			
			If GV5->( dbSeek(xFilial("GV5") + GW4->GW4_TPDC) ) .And. GV5->GV5_SENTID == "3" //Externo
			   cString += "3|"
			Else
			   cString += "1|"			
			EndIf
				   
			dbSelectArea("GWM")
			dbSetOrder(1)
			If dbSeek((cTmp)->GW3_FILIAL + "2" + (cTmp)->GW3_CDESP + (cTmp)->GW3_EMISDF + (cTmp)->GW3_SERDF + (cTmp)->GW3_NRDF + (cTmp)->GW3_DTEMIS)
				While !EoF() .And. GWM->GWM_FILIAL+GWM->GWM_TPDOC+GWM->GWM_CDESP+GWM->GWM_CDTRP+GWM->GWM_SERDOC+GWM->GWM_NRDOC+DTOS(GWM->GWM_DTEMIS) == ;
						(cTmp)->GW3_FILIAL+"2"+(cTmp)->GW3_CDESP+(cTmp)->GW3_EMISDF+(cTmp)->GW3_SERDF+(cTmp)->GW3_NRDF+(cTmp)->GW3_DTEMIS
					Do Case
						Case nCriRat == "1"
							nValorIcmsCred := nValorIcmsCred + GWM->GWM_VLICMS
						Case nCriRat == "2"
							nValorIcmsCred := nValorIcmsCred + GWM->GWM_VLICM1
						Case nCriRat == "3"
							nValorIcmsCred := nValorIcmsCred + GWM->GWM_VLICM3
						Case nCriRat == "4"
							nValorIcmsCred := nValorIcmsCred + GWM->GWM_VLICM2
						Otherwise
							nValorIcmsCred := nValorIcmsCred + 0
					EndCase
					GWM->(dbSkip())
				EndDo
			EndIf
			
			cString += STR(nValorIcmsCred) + "|"

			If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
				!(Empty((cTmp)->GW3_MUNINI) .And. Empty((cTmp)->GW3_UFINI) .And. Empty((cTmp)->GW3_MUNFIM) .And. Empty((cTmp)->GW3_UFFIM))   			   					   
					
				aAdd(aCidades, {(cTmp)->GW3_MUNINI, (cTmp)->GW3_MUNFIM})
			Else			
				aCidades := (GFEWSCITY((cTmp)->GW3_FILIAL, (cTmp)->GW3_EMISDF, (cTmp)->GW3_CDESP, (cTmp)->GW3_SERDF, (cTmp)->GW3_NRDF,(cTmp)->GW3_DTEMIS, (cTmp)->GW3_TPDF))
			EndIf
		
			//Estado GIA
			if cCdEmitDoc == (cTmp)->GW3_CDDEST   //Venda - usa o estado destino do Trecho
			   cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][2],"GU7_CDUF"))       + "|"			
			Else   // Compra - usa o estado origem do Trecho
			   cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][1],"GU7_CDUF"))       + "|"	
			EndIf			
	
			// Início Ponto de Entrada Procomp
			If ExistBlock("GFEXWS06")
				cString += ExecBlock("GFEXWS06",.F.,.F.,{(cTmp)->GW3_CDREM , (cTmp)->GW3_CDDEST })
			EndIf
			// Fim Ponto de Entrada Procomp	    
			
			   
			cString += aCidades[1][1]         + "|"
			cString += aCidades[1][2]         + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][1],"GU7_NMCID"))      + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][1],"GU7_CDUF"))       + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][2],"GU7_NMCID"))      + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][2],"GU7_CDUF"))       + "|"
					
			cString += BuscaParam("MV_DSICCD",(cTmp)->GW3_FILIAL,"")  	+ "|" //Imposto ICMS Retido
			cString += BuscaParam("MV_DSICCL",(cTmp)->GW3_FILIAL,"")	+ "|" //Classificação ICMS Retido
			cString += BuscaParam("MV_DSISCD",(cTmp)->GW3_FILIAL,"")	+ "|" //Imposto ISS Retido
			cString += BuscaParam("MV_DSISCL",(cTmp)->GW3_FILIAL,"")    + "|" //Classificação ISS Retido
			
			If GFXCP12137('GW3_FILTOM')
				cString += (cTmp)->GW3_FILTOM   	+ "|"
			EndIf

			cString += BuscaParam("MV_ICMBAPI",(cTmp)->GW3_FILIAL,"") + "|"          //Indica se o ICMS Retido está na base de PIS/COFINS
			
			If GFXCP2510('GW3_CTESUB')
				cString += (cTmp)->GW3_CTESUB   	+ "|"
			Else
				cString += "|"
			EndIf
			// **** IMPORTANTE: Manter o ponto de entrada no final do envio da GW3
			If lGFEXWS16
				cString += ExecBlock("GFEXWS16",.F.,.F.,{(cTmp)->GW3_FILIAL, (cTmp)->GW3_CDESP, (cTmp)->GW3_EMISDF, (cTmp)->GW3_SERDF, (cTmp)->GW3_NRDF, (cTmp)->GW3_DTEMIS, cString })
			EndIf
			// Fim Ponto de Entrada  				
	
			// Verifica se está parametrizado para integrar o Documento de Frete com o Fiscal
			If lIntDocF .And. (cTmp)->GW3_ACINT == "1"
				dbSelectArea("GWA")
				GWA->(dbSetOrder(1)) // GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)
				If GWA->(dbSeek((cTmp)->GW3_FILIAL+"2" +(cTmp)->GW3_CDESP+(cTmp)->GW3_EMISDF+(cTmp)->GW3_SERDF+(cTmp)->GW3_NRDF+ (cTmp)->GW3_DTEMIS))
					While GWA->(!Eof()) .AND. GWA->GWA_FILIAL == (cTmp)->GW3_FILIAL;
							.AND. GWA->GWA_TPDOC  == "2"; // Docto Frete
							.AND. GWA->GWA_CDESP  == (cTmp)->GW3_CDESP;
							.AND. GWA->GWA_CDEMIT == (cTmp)->GW3_EMISDF;
							.AND. GWA->GWA_SERIE  == (cTmp)->GW3_SERDF;
							.AND. GWA->GWA_NRDOC  == (cTmp)->GW3_NRDF;
							.AND. DTOS(GWA->GWA_DTEMIS) == (cTmp)->GW3_DTEMIS

						Do Case
							Case nCriRat == "1"
								cCampos := "GWM.GWM_VLFRET VLFRET, GWM.GWM_VLPIS  VLPIS, GWM.GWM_VLCOFI VLCOFI"
							Case nCriRat == "2"
								cCampos := "GWM.GWM_VLFRE1 VLFRET, GWM.GWM_VLPIS1  VLPIS, GWM.GWM_VLCOF1 VLCOFI"
							Case nCriRat == "3"
								cCampos := "GWM.GWM_VLFRE3 VLFRET, GWM.GWM_VLPIS3  VLPIS, GWM.GWM_VLCOF3 VLCOFI"
							Case nCriRat == "4"
								cCampos := "GWM.GWM_VLFRE2 VLFRET, GWM.GWM_VLPIS2  VLPIS, GWM.GWM_VLCOF2 VLCOFI"
							Otherwise
								cCampos := "GWM.GWM_VLFRET VLFRET, GWM.GWM_VLPIS  VLPIS, GWM.GWM_VLCOFI VLCOFI"
						EndCase

						cCampos := "%" + cCampos + "%"

						cAliasGWM := GetNextAlias()

						BeginSQL Alias cAliasGWM
							SELECT %Exp:cCampos%
							FROM %Table:GWM% GWM
							WHERE GWM.GWM_FILIAL = %Exp:GWA->GWA_FILIAL%
							AND GWM.GWM_TPDOC = %Exp:GWA->GWA_TPDOC%
							AND GWM.GWM_CDESP = %Exp:GWA->GWA_CDESP%
							AND GWM.GWM_CDTRP = %Exp:GWA->GWA_CDEMIT%
							AND GWM.GWM_SERDOC = %Exp:GWA->GWA_SERIE%
							AND GWM.GWM_NRDOC = %Exp:GWA->GWA_NRDOC%
							AND GWM.GWM_DTEMIS = %Exp:GWA->GWA_DTEMIS%
							AND GWM.GWM_CTFRET = %Exp:GWA->GWA_CTADEB%
							AND GWM.GWM_CCFRET = %Exp:GWA->GWA_CCDEB%
							AND GWM.GWM_UNINEG = %Exp:GWA->GWA_UNINEG%
							AND GWM.%NotDel%
						EndSQL

						nVlTotIsento	:= 0
						nVlTotTributado	:= 0

						Do While (cAliasGWM)->(!Eof())

							If (cAliasGWM)->VLPIS == 0 .And. (cAliasGWM)->VLCOFI == 0
								nVlTotIsento += (cAliasGWM)->VLFRET
							Else
								nVlTotTributado += (cAliasGWM)->VLFRET
							EndIf

							(cAliasGWM)->(dbSkip())
						EndDo

						(cAliasGWM)->(dbCloseArea())

						If nVlTotTributado > 0
							cString += "#GWA|" + GWA->GWA_CTADEB	+ "|" + GWA->GWA_CCDEB	+ "|" + GWA->GWA_UNINEG	+ "|" + cValToChar(nVlTotTributado) + "|1"
						EndIf
							
						If nVlTotIsento > 0
							cString += "#GWA|" + GWA->GWA_CTADEB	+ "|" + GWA->GWA_CCDEB	+ "|" + GWA->GWA_UNINEG	+ "|" + cValToChar(nVlTotIsento) + "|2"
						EndIf

						GWA->(DbSkip())
					EndDo
				EndIf
					
				dbSelectArea("GW4")
				GW4->(dbSetOrder(3)) // GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)
				If GW4->(dbSeek((cTmp)->(GW3_FILIAL+GW3_EMISDF+GW3_CDESP+GW3_SERDF+GW3_NRDF+GW3_DTEMIS)))
					While GW4->(!EoF()) .And.  GW4->GW4_FILIAL == (cTmp)->GW3_FILIAL;
							.And. GW4->GW4_EMISDF == (cTmp)->GW3_EMISDF;
							.And. GW4->GW4_CDESP  == (cTmp)->GW3_CDESP;
							.And. GW4->GW4_SERDF  == (cTmp)->GW3_SERDF;
							.And. GW4->GW4_NRDF   == (cTmp)->GW3_NRDF;
							.And. DTOS(GW4->GW4_DTEMIS) == (cTmp)->GW3_DTEMIS
	
						cString += "#GW4|" + GW4->GW4_SERDC + "|" + GW4->GW4_NRDC + "|" + GW4_TPDC
	
						GW4->(DbSkip())
					EndDo
				EndIf
						
				If GFXCP12127("GXZ_NRCT")						
					GXZ->( dbSetOrder(2) )	
					If GXZ->(dbSeek((cTmp)->GW3_FILIAL + (cTmp)->GW3_CDESP + (cTmp)->GW3_EMISDF + (cTmp)->GW3_SERDF + (cTmp)->GW3_NRDF))
						
						cString += "#GXZ|" + GXZ->GXZ_FILIAL + "|" + GXZ->GXZ_NRCT
						
					Endif
				Endif				
			Else
				cString += "#GWA||||" + cValToChar((cTmp)->GW3_VLDF) + "|1"			
			EndIf
		// Documento de Frete integrando com o Recebimento
		Case cTabela == "GW3" .AND. cCodInt == "3"
			cString := "#GW3|"
			cString += (cTmp)->GW3_FILIAL			+ "|"
			cString += (cTmp)->GW3_CDESP			+ "|"
			cString += (cTmp)->GW3_EMISDF			+ "|"
			cString += (cTmp)->GW3_SERDF			+ "|"
			cString += (cTmp)->GW3_NRDF		   		+ "|"
			cString += (cTmp)->GW3_DTEMIS  			+ "|"
			cString += (cTmp)->GW3_CFOP		  		+ "|"
			cString += POSICIONE("GVT",1,XFILIAL("GVT")+(cTmp)->GW3_CDESP,"GVT_TPIMP") 			+ "|"
			cString += (cTmp)->GW3_TRBIMP			+ "|"
			cString += STR((cTmp)->GW3_VLDF	)  		+ "|"
			cString += STR((cTmp)->GW3_BASIMP	)	+ "|"
			cString += STR((cTmp)->GW3_PCIMP	)	+ "|"
			cString += STR((cTmp)->GW3_VLIMP	)	+ "|"
			cString += STR((cTmp)->GW3_BASPIS	)	+ "|"
			cString += STR((cTmp)->GW3_VLPIS	)	+ "|"
			cString += STR((cTmp)->GW3_BASCOF	)	+ "|"
			cString += STR((cTmp)->GW3_VLCOF	)	+ "|"
			cString += (cTmp)->GW3_SITREC			+ "|"
			cString += (cTmp)->GW3_DTREC			+ "|"
			cString += (cTmp)->GW3_CTE		    	+ "|"
			cString += (cTmp)->GW3_TPCTE			+ "|"
			cString += (cTmp)->GW3_NATFRE			+ "|"
		
			If GFXCP12131("GW3_MUNINI") .And. GFXCP12131("GW3_UFINI") .And. GFXCP12131("GW3_MUNFIM") .And. GFXCP12131("GW3_UFFIM") .And. ;
		   	   !(Empty((cTmp)->GW3_MUNINI) .And. Empty((cTmp)->GW3_UFINI) .And. Empty((cTmp)->GW3_MUNFIM) .And. Empty((cTmp)->GW3_UFFIM))   			   					   
						  
				aAdd(aCidades, {(cTmp)->GW3_MUNINI, (cTmp)->GW3_MUNFIM})
			Else			
				aCidades := (GFEWSCITY((cTmp)->GW3_FILIAL, (cTmp)->GW3_EMISDF, (cTmp)->GW3_CDESP, (cTmp)->GW3_SERDF, (cTmp)->GW3_NRDF,(cTmp)->GW3_DTEMIS, (cTmp)->GW3_TPDF))
			EndIf			
			
			//Estado GIA
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][1],"GU7_CDUF"))       + "|"	
						
			cString += (cTmp)->GW3_USUIMP + "|"
			 
			cString += aCidades[1][1]         + "|"
			cString += aCidades[1][2]         + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][1],"GU7_NMCID"))      + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][1],"GU7_CDUF"))       + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][2],"GU7_NMCID"))      + "|"
			cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+aCidades[1][2],"GU7_CDUF"))       + "|"
				
			cString += (cTmp)->GW3_PDGFRT			+ "|"
			cString += (cTmp)->GW3_ICMPDG			+ "|"
			cString += STR((cTmp)->GW3_IMPRET)		+ "|"			
					
			cString += BuscaParam("MV_DSICCD",(cTmp)->GW3_FILIAL,"")  	+ "|"
			cString += BuscaParam("MV_DSICCL",(cTmp)->GW3_FILIAL,"")	+ "|"
			cString += BuscaParam("MV_DSISCD",(cTmp)->GW3_FILIAL,"")	+ "|"
			cString += BuscaParam("MV_DSISCL",(cTmp)->GW3_FILIAL,"")    + "|"
			
			If GFXCP12137('GW3_FILTOM')
				cString += (cTmp)->GW3_FILTOM   	+ "|"
			EndIf

			GW4->(dbSetOrder(1))
			GW4->(dbSeek((cTmp)->GW3_FILIAL + (cTmp)->GW3_EMISDF + (cTmp)->GW3_CDESP + (cTmp)->GW3_SERDF + (cTmp)->GW3_NRDF + (cTmp)->GW3_DTEMIS))
			While GW4->(!Eof()) .AND. GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS) == (cTmp)->GW3_FILIAL + (cTmp)->GW3_EMISDF + (cTmp)->GW3_CDESP + (cTmp)->GW3_SERDF + (cTmp)->GW3_NRDF + (cTmp)->GW3_DTEMIS

				cAliasGW8 := GetNextAlias()
					
				cQuery := "SELECT GW8.GW8_FILIAL, GW8.GW8_CDTPDC, GW8.GW8_EMISDC, GW8.GW8_SERDC, GW8.GW8_NRDC, GW8.GW8_INFO1,"
				cQuery += " GWM.GWM_TPDOC, GWM.GWM_CDESP, GWM.GWM_CDTRP, GWM.GWM_SERDOC, GWM.GWM_NRDOC," 
				cQuery += " SUM(GW8.GW8_PESOR) AS GW8_PESOR, SUM(GW8.GW8_VALOR) AS GW8_VALOR, SUM(GW8.GW8_VOLUME) AS GW8_VOLUME, SUM(GW8.GW8_QTDE) AS GW8_QTDE,"  
				If nCriRat == "1" // Peso carga
					cQuery += " SUM(GWM.GWM_VLFRET) AS GWM_VLFRET, SUM(GWM.GWM_VLPIS) AS GWM_VLPIS, SUM(GWM.GWM_VLCOFI) AS GWM_VLCOFI, SUM(GWM.GWM_VLICMS) AS GWM_VLICMS," 
				ElseIf nCriRat == "2" // Valor carga
					cQuery += " SUM(GWM.GWM_VLFRE1) AS GWM_VLFRET, SUM(GWM.GWM_VLPIS1) AS GWM_VLPIS, SUM(GWM.GWM_VLCOF1) AS GWM_VLCOFI, SUM(GWM.GWM_VLICM1) AS GWM_VLICMS,"
				ElseIf nCriRat == "3" // Volume carga
					cQuery += " SUM(GWM.GWM_VLFRE2) AS GWM_VLFRET, SUM(GWM.GWM_VLPIS2) AS GWM_VLPIS, SUM(GWM.GWM_VLCOF2) AS GWM_VLCOFI, SUM(GWM.GWM_VLICM2) AS GWM_VLICMS,"
				ElseIf nCriRat == "4" // Qtde Itens
					cQuery += " SUM(GWM.GWM_VLFRE3) AS GWM_VLFRET, SUM(GWM.GWM_VLPIS3) AS GWM_VLPIS, SUM(GWM.GWM_VLCOF3) AS GWM_VLCOFI, SUM(GWM.GWM_VLICM3) AS GWM_VLICMS,"
				EndIf
				cQuery += " SUM(GWM.GWM_PEDAG) AS GWM_PEDAG, SUM(GWM.GWM_PEDAG1) AS GWM_PEDAG, SUM(GWM.GWM_PEDAG2) AS GWM_PEDAG, SUM(GWM.GWM_PEDAG3) AS GWM_PEDAG FROM "
				cQuery += RetSQLName("GW8") + " GW8 INNER JOIN " + RetSQLName("GWM") + " GWM " 
				cQuery += " ON GW8.GW8_FILIAL = GWM.GWM_FILIAL " 
				cQuery += " AND GW8.GW8_CDTPDC = GWM.GWM_CDTPDC " 
				cQuery += " AND GW8.GW8_EMISDC = GWM.GWM_EMISDC  "
				cQuery += " AND GW8.GW8_SERDC = GWM.GWM_SERDC " 
				cQuery += " AND GW8.GW8_NRDC = GWM.GWM_NRDC "
				cQuery += " AND GW8.GW8_SEQ = GWM.GWM_SEQGW8 "
				cQuery += " AND GWM.D_E_L_E_T_ = ' ' "
				cQuery += " AND GWM.GWM_TPDOC  = '2' "
				cQuery += " WHERE "
				cQuery += " GW8.GW8_FILIAL = '"+ GW4->GW4_FILIAL +	"' AND "
				cQuery += " GW8.GW8_CDTPDC = '"+ GW4->GW4_TPDC +		"' AND "
				cQuery += " GW8.GW8_EMISDC = '"+ GW4->GW4_EMISDC +	"' AND "
				cQuery += " GW8.GW8_SERDC  = '"+ GW4->GW4_SERDC +	"' AND "
				cQuery += " GW8.GW8_NRDC   = '"+ GW4->GW4_NRDC +		"' AND "
				cQuery += " GWM.GWM_CDESP  = '"+ GW4->GW4_CDESP +	"' AND "
				cQuery += " GWM.GWM_CDTRP  = '"+ GW4->GW4_EMISDF +	"' AND "
				cQuery += " GWM.GWM_SERDOC = '"+ GW4->GW4_SERDF +	"' AND "
				cQuery += " GWM.GWM_NRDOC  = '"+ GW4->GW4_NRDF + 	"' AND "	
				cQuery += " GW8.D_E_L_E_T_ = ' '"
				cQuery += " GROUP BY GW8.GW8_FILIAL, GW8.GW8_CDTPDC, GW8.GW8_EMISDC, GW8.GW8_SERDC, GW8.GW8_NRDC, GW8.GW8_INFO1, GWM.GWM_TPDOC, GWM.GWM_CDESP, GWM.GWM_CDTRP, GWM.GWM_SERDOC, GWM.GWM_NRDOC"
	
				If nCriRat == "1" //Peso
					cQuery += " ORDER BY SUM(GW8.GW8_PESOR)	"
				ElseIf nCriRat == "2" //Valor
					cQuery += " ORDER BY SUM(GW8.GW8_VALOR) "
				ElseIf nCriRat == "3" //Volume
					cQuery += " ORDER BY SUM(GW8.GW8_VOLUME)"
				ElseIf nCriRat == "4" //Qtde
					cQuery += " ORDER BY SUM(GW8.GW8_QTDE)	"
				EndIf				
					
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW8, .F., .T.)
								
				(cAliasGW8)->( dbGoTop() )
	
				While !(cAliasGW8)->( Eof() )
					
					// Se o pedagio frete for sim e a informação de pedágio for não no ICMS ou no PIS/COFINS
					If ((cTmp)->GW3_PDGFRT = '1' .And. ((cTmp)->GW3_ICMPDG = '2' .Or. (cTmp)->GW3_PDGPIS = '2'))
						cValorPed := cValToChar((cAliasGW8)->GWM_PEDAG)
					EndIf
						
					// Envio das informações do item
					cString  += "#GW8|" + ""	 + "|" + (cAliasGW8)->GW8_SERDC	+ "|" + (cAliasGW8)->GW8_NRDC	+ "|" + (cAliasGW8)->GW8_EMISDC	+ "|" + (cAliasGW8)->GW8_INFO1 + "|" + cValToChar((cAliasGW8)->GWM_VLFRET) + "|" + cValorPed			
											
					(cAliasGW8)->( dbSkip() )
				EndDo
						
				(cAliasGW8)->( dbCloseArea() )
				GW4->(dbSkip())				
			EndDo
			
			If GFXCP12127("GXZ_NRCT")											
				GXZ->( dbSetOrder(2) )	
				If GXZ->(dbSeek((cTmp)->GW3_FILIAL + (cTmp)->GW3_CDESP + (cTmp)->GW3_EMISDF + (cTmp)->GW3_SERDF + (cTmp)->GW3_NRDF))
					
					cString += "#GXZ|" + GXZ->GXZ_FILIAL + "|" + GXZ->GXZ_NRCT					
				Endif										
			Endif	
			
		// Documento de Frete integrando com o MLA
		Case cTabela == "GW3" .And. cCodInt == "6"
			GW3->(dbGoto( (cTmp)->R_E_C_N_O_ ))			
			
			cQuery := "SELECT"
				
			If SuperGetMV('MV_VLCNPJ',,'1') == "2"
				cQuery += " CALC.GWF_TRANSP,"
			EndIf
				
			cQuery += " SUM(GWI.GWI_VLFRET) + CALC.GWF_VLAJUS VAL_FRETE,"
			cQuery += " CALC.GWF_VLAJUS, CALC.GWF_IMPOST, CALC.GWF_PCICMS, CALC.GWF_VLICMS, CALC.GWF_PCISS, CALC.GWF_VLISS"
			cQuery += " FROM " + RetSqlName("GWI") + " GWI "
			cQuery += " INNER JOIN"
			cQuery += " (SELECT"
				
			If SuperGetMV('MV_VLCNPJ',,'1') == "2"
				cQuery += " GWF.GWF_TRANSP,"
			EndIf
				
			cQuery += " GWF.GWF_NRCALC, GWF.GWF_VLAJUS, GWF.GWF_IMPOST, GWF.GWF_PCICMS, GWF.GWF_VLICMS, GWF.GWF_PCISS, GWF.GWF_VLISS "
			cQuery += "		FROM " + RetSqlName("GWF") + " GWF"
			cQuery += "		INNER JOIN  " + RetSqlName("GWH") + " GWH"
			cQuery += "		ON GWF.GWF_FILIAL = '" + RetFilTab("GWF",(cTmp)->GW3_FILIAL) + "'"
			cQuery += "		   AND GWF.GWF_NRCALC = GWH.GWH_NRCALC"
			cQuery += "		   AND GWF.GWF_TPCALC = '" + (cTmp)->GW3_TPDF + "'"
			
			If (cTmp)->GW3_TPDF == "7"
			    GWF->(dbSetOrder(6))
			    If GWF->(dbseek((cTmp)->GW3_FILIAL+(cTmp)->GW3_CDESP+(cTmp)->GW3_EMISDF+(cTmp)->GW3_SERDF+(cTmp)->GW3_NRDF+(cTmp)->GW3_DTEMIS))
			       cQuery += "		   AND GWF.GWF_FILIAL = '" + (cTmp)->GW3_FILIAL + "'"
			       cQuery += "		   AND GWF.GWF_CDESP  = '" + (cTmp)->GW3_CDESP + "'"
			       cQuery += "		   AND GWF.GWF_EMISDF = '" + (cTmp)->GW3_EMISDF + "'"
			       cQuery += "		   AND GWF.GWF_SERDF  = '" + (cTmp)->GW3_SERDF  + "'"
			       cQuery += "		   AND GWF.GWF_NRDF   = '" + (cTmp)->GW3_NRDF  + "'"
			       cQuery += "		   AND GWF.GWF_DTEMDF = '" + (cTmp)->GW3_DTEMIS + "'"       				       			    
				Else				
				   cQuery += "		   AND GWF.GWF_CDTPSE = '" + (cTmp)->GW3_CDTPSE + "'"
				EndIf
			EndIf	
			
			If SuperGetMV('MV_VLCNPJ',,'1') != "2"
				cQuery += "		   AND GWF.GWF_TRANSP = '" + (cTmp)->GW3_EMISDF + "'"
			EndIf
				
			cQuery += "		   and GWF.d_e_l_e_t_ = ''"
			cQuery += "		   and GWH.d_e_l_e_t_ = ''"
			cQuery += "		INNER JOIN " + RetSqlName("GW4") + " GW4"
			cQuery += "		ON GW4.D_E_L_E_T_ = ''"
			cQuery += "		   AND GW4.GW4_FILIAL = '" + RetFilTab("GW4",(cTmp)->GW3_FILIAL) + "'"
			cQuery += "		   AND GW4.GW4_TPDC   = GWH.GWH_CDTPDC"
			cQuery += "		   AND GW4.GW4_EMISDC = GWH.GWH_EMISDC"
			cQuery += "		   AND GW4.GW4_SERDC  = GWH.GWH_SERDC"
			cQuery += "		   AND GW4.GW4_NRDC   = GWH.GWH_NRDC"
			cQuery += "		WHERE GW4.GW4_EMISDF  = '" + (cTmp)->GW3_EMISDF + "'"
			cQuery += "		   AND GW4.GW4_CDESP  = '" + (cTmp)->GW3_CDESP  + "'"
			cQuery += "		   AND GW4.GW4_SERDF  = '" + (cTmp)->GW3_SERDF  + "'"
			cQuery += "		   AND GW4.GW4_NRDF   = '" + (cTmp)->GW3_NRDF   + "'"
			cQuery += "		   AND GW4.GW4_DTEMIS = '" + (cTmp)->GW3_DTEMIS + "'"
			cQuery += "	GROUP BY "
				
			If SuperGetMV('MV_VLCNPJ',,'1') == "2"
				cQuery += " GWF.GWF_TRANSP,"
			EndIf
			
			cQuery += " GWF.GWF_NRCALC, GWF.GWF_VLAJUS, GWF.GWF_IMPOST, GWF.GWF_PCICMS, GWF.GWF_VLICMS, GWF.GWF_PCISS, GWF.GWF_VLISS ) CALC"
			cQuery += "	ON GWI.GWI_FILIAL = '" + RetFilTab("GWI",(cTmp)->GW3_FILIAL) + "'"
			cQuery += "	AND GWI.D_E_L_E_T_ = ''"
			cQuery += " AND GWI.GWI_TOTFRE = '1'"
			cQuery += "	AND CALC.GWF_NRCALC = GWI.GWI_NRCALC"
			cQuery += "	GROUP BY "
				
			If SuperGetMV('MV_VLCNPJ',,'1') == "2"
				cQuery += " CALC.GWF_TRANSP,"
			EndIf
				
			cQuery += "CALC.GWF_VLAJUS, CALC.GWF_IMPOST, CALC.GWF_PCICMS, CALC.GWF_VLICMS, CALC.GWF_PCISS, CALC.GWF_VLISS"
	
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"VAL_FRETE","N",TamSx3("GWI_VLFRET")[1],TamSx3("GWI_VLFRET")[2])
				
			nValorEnv := 0 //Valor enviado na msg para aprovação no MLA
			nVlCalc := 0    //Valor calculado do frete
			nVlDif  := 0   // Valor da diferença realizado(GW3) x calculado

			cImposto := ''
			iPcImpGWF := 0			
			iPcImpDif := 0
			nVlImpGWF := 0						
			nVlImpDif := 0

			While (cAliasQry)->(!Eof())
				If s_VLCNPJ == "2"
					If SubStr(Posicione("GU3", 1, RetFilTab("GU3",(cTmp)->GW3_FILIAL) + (cTmp)->GW3_EMISDF, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, RetFilTab("GU3",(cTmp)->GW3_FILIAL) + (cAliasQry)->GWF_TRANSP, "GU3->GU3_IDFED"), 1, 8)
						nVlCalc  += (cAliasQry)->VAL_FRETE
				 	    cImposto := (cAliasQry)->GWF_IMPOST
						//Cidade de origem e destino é a mesma, então o calculo é de ISS
						//Grava os valores de Aliquota e de imposto
						If (cAliasQry)->GWF_IMPOST == "2"
							//ISS
							iPcImpGWF := (cAliasQry)->GWF_PCISS
							nVlImpGWF += (cAliasQry)->GWF_VLISS
						Else 
							//ICMS
							iPcImpGWF := (cAliasQry)->GWF_PCICMS
							nVlImpGWF += (cAliasQry)->GWF_VLICMS
						EndIf
					EndIf
				Else
					nVlCalc  += (cAliasQry)->VAL_FRETE
					cImposto := (cAliasQry)->GWF_IMPOST
					//Cidade de origem e destino é a mesma, então o calculo é de ISS
					//Grava os valores de Aliquota e de imposto
					If (cAliasQry)->GWF_IMPOST == "2"
						//ISS
						iPcImpGWF := (cAliasQry)->GWF_PCISS
						nVlImpGWF += (cAliasQry)->GWF_VLISS
					Else 
						//ICMS
						iPcImpGWF := (cAliasQry)->GWF_PCICMS
						nVlImpGWF += (cAliasQry)->GWF_VLICMS
					EndIf
				EndIf										 
				(cAliasQry)->(dbSkip())
			EndDo

			nVlDif    := (cTmp)->GW3_VLDF  - nVlCalc
			iPcImpDif := (cTmp)->GW3_PCIMP - iPcImpGWF
			nVlImpDif := (cTmp)->GW3_VLIMP - nVlImpGWF

			(cAliasQry)->(dbCloseArea())						
				
				
			If SuperGetMv("MV_DFMLA",.F.,"1") == "2" 
			   nValorEnv := (cTmp)->GW3_VLDF  
			Else
			   nValorEnv := cValtoChar(nVlDif)   
			EndIf	
				
				
			cString :=  "#GW3|"
			cString +=  (cTmp)->GW3_FILIAL + "|"
			cString +=  (cTmp)->GW3_CDESP  + "|"
			cString +=  (cTmp)->GW3_EMISDF + "|"
			cString +=  (cTmp)->GW3_SERDF  + "|"
			cString +=  (cTmp)->GW3_NRDF   + "|"
			cString +=  (cTmp)->GW3_DTEMIS + "|"
			cString +=  (cTmp)->GW3_TPDF   + "|"
			cString +=  (cTmp)->GW3_DTENT  + "|"
			cString +=  (cTmp)->GW3_CFOP   + "|"
			cString +=  (cTmp)->GW3_SIT    + "|"
			cString +=  AllTrim((cTmp)->GW3_USUIMP) + "|"
			cString +=  (cTmp)->GW3_CDREM  + "|"
			cString +=  (cTmp)->GW3_CDDEST + "|"
			cString += cValtoChar(nValorEnv) + "|"   
			cString +=  cValtoChar((cTmp)->GW3_TAXAS)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_FRPESO) + "|"
			cString +=  cValtoChar((cTmp)->GW3_FRVAL)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_PEDAG)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_QTDCS)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_QTVOL)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_VOLUM)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_PESOR)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_PESOC)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_VLCARG) + "|"
			cString +=  POSICIONE("GVT",1,xFilial("GVT")+(cTmp)->GW3_CDESP,"GVT_TPIMP") + "|"
			cString +=  (cTmp)->GW3_TRBIMP + "|"
			cString +=  cValtoChar((cTmp)->GW3_BASIMP) + "|"
			cString +=  cValtoChar((cTmp)->GW3_PCIMP)  + "|"
			cString +=  cValtoChar((cTmp)->GW3_VLIMP)  + "|"
			cString +=  (cTmp)->GW3_CTE    + "|"
			cString +=  FwCutOff(GW3->GW3_MOTBLQ,.T.) + "|"
			cString +=  (cTmp)->GW3_DTBLQ  + "|"
				
			If !Empty((cTmp)->GW3_USUBLQ)
				cString += AllTrim((cTmp)->GW3_USUBLQ) + "|" // Código do usuário
			Else
				cString += "|"
			EndIf
				
			cString +=  (cTmp)->GW3_ORIGEM + "|"
			cString +=  (cTmp)->GW3_TPCTE  + "|"
			cString +=  (cTmp)->GW3_SITMLA + "|"
			cString +=  cValtoChar(nVlCalc) + "|"
			cString +=  cValtoChar(nVlDif)  + "|"
			
			If GFXCP12137('GW3_FILTOM')
				cString += (cTmp)->GW3_FILTOM   	+ "|"
			Else
				cString += "|"
			EndIf			

			cString += FwCutOff(GW3->GW3_OBS,.T.)  + "|"
			cString += AllTrim((cTmp)->GW3_MUNINI) + "|"
			cString += AllTrim((cTmp)->GW3_UFINI)  + "|"
			cString += AllTrim((cTmp)->GW3_MUNFIM) + "|"
			cString += AllTrim((cTmp)->GW3_UFFIM)  + "|"
			cString += AllTrim(cImposto)           + "|"
			cString += cValtoChar(iPcImpGWF)   + "|"
			cString += cValtoChar(iPcImpDif)   + "|"
			cString += cValtoChar(nVlImpGWF)   + "|"
			cString += cValtoChar(nVlImpDif)   + "|"

		// Contrato com Autônomo integrando com o Financeiro
		Case cTabela == "GW2" .AND. cCodInt == "2"
			
			nValorFrete := (cTmp)->GW2_VLFRET
				
			dbSelectArea("GW5")
			dbSetOrder(1)
			dbSeek((cTmp)->GW2_FILIAL+(cTmp)->GW2_NRCONT)
			While !Eof() .AND. (cTmp)->GW2_FILIAL+(cTmp)->GW2_NRCONT == GW5->GW5_FILIAL + GW5->GW5_NRCONT
				If GW5->GW5_OPERAC == "1"
					nValorFrete := nValorFrete + GW5->GW5_VALOR
				Else
					nValorFrete := nValorFrete - GW5->GW5_VALOR
				EndIf
				GW5->(DbSkip())
			EndDo
				
			cString := "#GW2|"
			cString += (cTmp)->GW2_FILIAL									+ "|"
			cString += (cTmp)->GW2_NRCONT									+ "|"
			cString += (cTmp)->GW2_CDPROP									+ "|"
			cString += (cTmp)->GW2_DTCRIA									+ "|"
			cString += (cTmp)->GW2_DTVENC									+ "|"
			cString += STR(nValorFrete)			   							+ "|"
			cString += STR((cTmp)->GW2_VLINEM)								+ "|"
			cString += STR((cTmp)->GW2_VLISS )	   							+ "|"
			cString += STR((cTmp)->GW2_VLIRRF)	   							+ "|"
			cString += STR((cTmp)->GW2_VLINSS)								+ "|"
			cString += STR((cTmp)->GW2_VLSEST) 	   	        				+ "|"
			cString += (cTmp)->GW2_SITFIN	   								+ "|"
			cString += (cTmp)->GW2_DTFIN									+ "|"
			cString += BuscaParam("MV_DSESCO",(cTmp)->GW2_FILIAL,"") 		+ "|"
			cString += BuscaParam("MV_DSINCD",(cTmp)->GW2_FILIAL,"")    	+ "|"
			cString += BuscaParam("MV_DSINCL",(cTmp)->GW2_FILIAL,"") 		+ "|"
			cString += BuscaParam("MV_DSIACD",(cTmp)->GW2_FILIAL,"") 		+ "|"
			cString += BuscaParam("MV_DSIACL",(cTmp)->GW2_FILIAL,"")  		+ "|"
			cString += BuscaParam("MV_DSSSCD",(cTmp)->GW2_FILIAL,"")   		+ "|"
			cString += BuscaParam("MV_DSSSCL",(cTmp)->GW2_FILIAL,"")   		+ "|"
			cString += BuscaParam("MV_DSIRCD",(cTmp)->GW2_FILIAL,"")   		+ "|"
			cString += BuscaParam("MV_DSIRCL",(cTmp)->GW2_FILIAL,"")     	+ "|"
			cString += BuscaParam("MV_DSISCD",(cTmp)->GW2_FILIAL,"") 		+ "|"
			cString += BuscaParam("MV_DSISCL",(cTmp)->GW2_FILIAL,"") 		+ "|"
			cString += BuscaParam("MV_MATREX",(cTmp)->GW2_FILIAL,"")		+ "|"
			
			If (cTmp)->GW2_VLIRRF > 0
				cString += STR((cTmp)->GW2_VLDEDP) 	   	        				
			Else
				cString += "0"
			EndIf
	
			dbSelectArea("GW9")
			dbSetOrder(1)
			dbSeek((cTmp)->GW2_FILIAL+(cTmp)->GW2_NRCONT)
			While !Eof() .AND. (cTmp)->GW2_FILIAL+(cTmp)->GW2_NRCONT == GW9->GW9_FILIAL + GW9->GW9_NRCONT
	
				cString += "#GW9|"+GW9->GW9_CCUSTO+"|"+GW9->GW9_CTACTB+"|"+GW9->GW9_UNINEG+"|"+STR(GW9->GW9_VLMOV)
	
				GW9->(DbSkip())
			EndDo
		// Contrato com Autônomo integrando com o Recebimento
		Case cTabela == "GW2" .AND. cCodInt == "3"
			// Verificação do parâmetro referente a soma do valor de INSS Embarcador ao valor Total. */
			If cAdcINEM == "1"
				nValorDoc := (cTmp)->GW2_VLFRET + (cTmp)->GW2_VLINEM
			Else
				nValorDoc := (cTmp)->GW2_VLFRET
			EndIf
	
			cString := "#GW2|"
			cString += (cTmp)->GW2_FILIAL			+ "|"
			cString += (cTmp)->GW2_NRCONT			+ "|"
			cString += (cTmp)->GW2_CDPROP			+ "|"
			cString += (cTmp)->GW2_DTIMPR			+ "|"
			cString += STR(nValorDoc)  			+ "|"
			cString += (cTmp)->GW2_SITREC			+ "|"
			cString += (cTmp)->GW2_DTREC			+ "|"
			cString += (cTmp)->GW2_USUREC
	
			dbSelectArea("GWF")
			dbSetOrder(2)
			dbSeek((cTmp)->GW2_FILIAL+(cTmp)->GW2_NRCONT )
			While !Eof() .AND. (cTmp)->GW2_FILIAL+(cTmp)->GW2_NRCONT == GWF->GWF_FILIAL+GWF->GWF_NRCONT
				dbSelectArea("GWH")
				dbSetOrder(1)
				dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC)
				While !Eof() .AND. GWF->GWF_FILIAL+GWF->GWF_NRCALC == GWH->GWH_FILIAL+GWH->GWH_NRCALC
					DbSelectArea("GW8")
					dbSetOrder(1)
					dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
					While !Eof() .AND. GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC == GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC
	
						cString += "#GW8|"+GW8->GW8_SEQ+"|"+GW8->GW8_SERDC+"|"+GW8->GW8_NRDC+"|"+GW8->GW8_EMISDC+"|"+GW8->GW8_INFO1
	
						GW8->(dbSkip())
					EndDo
	
					GWH->(dbSkip())
				EndDo
	
				GWF->(dbSkip())
			EndDo
		// Contrato com Autônomo integrando com o RH (HCM Datasul)
		Case cTabela == "GW2" .AND. cCodInt == "4"
			cString := "#GW2|"
			cString += (cTmp)->GW2_FILIAL			+ "|"
			cString += (cTmp)->GW2_NRCONT 			+ "|"
			cString += Posicione("GU3",1,xFilial("GU3")+(cTmp)->GW2_CDPROP, "GU3_IDFED" )			+ "|"
			cString += (cTmp)->GW2_DTCRIA			+ "|"
			cString += (cTmp)->GW2_DTIMPR 			+ "|"
			cString += STR((cTmp)->GW2_VLLIQ)  		+ "|"
			cString += STR((cTmp)->GW2_VLINSS) 		+ "|"
			cString += STR((cTmp)->GW2_VLSEST) 		+ "|"
			cString += STR((cTmp)->GW2_VLISS ) 		+ "|"
			cString += STR((cTmp)->GW2_VLDEDP) 		+ "|"
			cString += STR((cTmp)->GW2_VLINSS) 		+ "|"
			cString += STR((cTmp)->GW2_QTDEIR) 		+ "|"
			cString += STR((cTmp)->GW2_VLBAIR) 		+ "|"
			cString += STR((cTmp)->GW2_VLIRRF)		+ "|"
			cString += (cTmp)->GW2_SITRH 	        + "|"
			cString += STR((cTmp)->GW2_VLBAIN)		+ "|"
			cString += (cTmp)->GW2_DTVENC			+ "|"
				
			GWA->(dbSetOrder(3))
			If GWA->(dbSeek((cTmp)->GW2_FILIAL+"3"+(cTmp)->GW2_NRCONT))
				cString += GWA->GWA_CTADEB	+ "|"
				cString += GWA->GWA_CCDEB	+ "|"
				cString += GWA->GWA_UNINEG  + "|"
			Else
				cString += "|"
				cString += "|"
				cString += "|"
			EndIf
			
			cString += (cTmp)->GW2_USURH + "|"
			
			cAliasGV5 := GetNextAlias()
			
			BeginSql Alias cAliasGV5
				SELECT DISTINCT COUNT(GV5.GV5_SENTID) COUNTGV5
				FROM %Table:GWF% GWF
				INNER JOIN %Table:GWH% GWH
				ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
				AND GWH.GWH_NRCALC = GWF.GWF_NRCALC
				AND GWH.%NotDel%
				INNER JOIN %Table:GV5% GV5
				ON GV5.GV5_FILIAL = %xFilial:GV5%
				AND GV5.GV5_CDTPDC = GWH.GWH_CDTPDC
				AND GV5.%NotDel%
				WHERE GWF.GWF_FILIAL = %Exp:(cTmp)->GW2_FILIAL%
				AND GWF.GWF_NRCONT = %Exp:(cTmp)->GW2_NRCONT%
				AND GWF.%NotDel%
			EndSql
			
			If (cAliasGV5)->(!EoF())
				If (cAliasGV5)->COUNTGV5 > 1
					cString += "9"
				Else
					cAliasCnt := GetNextAlias()
				
					BeginSql Alias cAliasCnt
						SELECT DISTINCT GV5.GV5_SENTID
						FROM %Table:GWF% GWF
						INNER JOIN %Table:GWH% GWH
						ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
						AND GWH.GWH_NRCALC = GWF.GWF_NRCALC
						AND GWH.%NotDel%
						INNER JOIN %Table:GV5% GV5
						ON GV5.GV5_FILIAL = %xFilial:GV5%
						AND GV5.GV5_CDTPDC = GWH.GWH_CDTPDC
						AND GV5.%NotDel%
						WHERE GWF.GWF_FILIAL = %Exp:(cTmp)->GW2_FILIAL%
						AND GWF.GWF_NRCONT = %Exp:(cTmp)->GW2_NRCONT%
						AND GWF.%NotDel%
					EndSql
					
					If (cAliasCnt)->(!EoF())
						cString += (cAliasCnt)->GV5_SENTID
					EndIf
					
					(cAliasCnt)->(dbCloseArea())
				EndIf
			Else
				cString += ""
			EndIf
			
			(cAliasGV5)->(dbCloseArea())
		// Negociação da Tabela de Frete integrando com o MLA
		Case cTabela == "GV9" .And. cCodInt == "7"
			// Filial que será enviada na string
			If !Empty(cFil) .And. FWModeAccess("GV9",1) == "E"
				cFilEnvi := cFil
			Else
				cFilEnvi := cFilAnt
			EndIf
			
			cString := "#GV9|" // Negociação tabela de frete
			cString += AllTrim(cFilEnvi) + "|"
			cString += AllTrim((cTmp)->GV9_CDEMIT) + "|"
			cString += AllTrim((cTmp)->GV9_NRTAB)  + "|"
			cString += AllTrim((cTmp)->GV9_NRNEG)  + "|"
			cString += AllTrim((cTmp)->GV9_CDCLFR) + "|"
			cString += AllTrim(Posicione("GUB",1,xFilial("GUB")+(cTmp)->GV9_CDCLFR,"GUB_DSCLFR")) + "|"
			cString += AllTrim((cTmp)->GV9_CDTPOP) + "|"
			cString += AllTrim(Posicione("GV4",1,xFilial("GV4")+(cTmp)->GV9_CDTPOP,"GV4_DSTPOP")) + "|"
			cString += AllTrim((cTmp)->GV9_DTVALI) + "|"
			cString += AllTrim((cTmp)->GV9_DTVALF) + "|"
			cString += AllTrim((cTmp)->GV9_TPLOTA) + "|"
			cString += AllTrim((cTmp)->GV9_DTCRIA) + "|"
			cString += AllTrim((cTmp)->GV9_USUCRI) + "|"
			cString += AllTrim((cTmp)->GV9_SITMLA) + "|"
			cString += AllTrim((cTmp)->GV9_SIT)    + "|"
			cString += AllTrim((cTmp)->GV9_SITCON) + "|"			
			cString := FwNoAccent(cString)
			
		Case cTabela == "GV8" .And. cCodInt == "7"
			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := "SELECT TOP 200"
			EndIf
			cQuery += 		 " GV8.GV8_NRROTA,"
			cQuery +=        " GV8.GV8_TPORIG,"
			cQuery +=        " GV8.GV8_NRCIOR,"
			cQuery +=        " GV8.GV8_DSTORI,"
			cQuery +=        " GV8.GV8_DSTORF,"
			cQuery +=        " GV8.GV8_NRREOR,"
			cQuery +=        " GV8.GV8_CDPAOR,"
			cQuery +=        " GV8.GV8_CDUFOR,"
			cQuery +=        " GV8.GV8_TPDEST,"
			cQuery +=        " GV8.GV8_NRCIDS,"
			cQuery +=        " GV8.GV8_DSTDEI,"
			cQuery +=        " GV8.GV8_DSTDEF,"
			cQuery +=        " GV8.GV8_NRREDS,"
			cQuery +=        " GV8.GV8_CDPADS,"
			cQuery +=        " GV8.GV8_CDUFDS,"
			cQuery +=        " GV8.GV8_CDREM,"
			cQuery +=        " GV8.GV8_CDDEST"
			cQuery +=   " FROM "+RetSqlName("GV8")+" GV8"
			cQuery +=  " WHERE GV8.GV8_FILIAL = '"+RetFilTab("GV8",cFil)+"'"
			cQuery +=    " AND GV8.GV8_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV8.GV8_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV8.GV8_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			If cParte != "1"
				cQuery += " AND GV8.GV8_NRROTA > '" + cParte + "' "
			EndIf
			cQuery +=    " AND GV8.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GV8.GV8_NRROTA"
			If cBcoDados == "ORACLE"
				cQuery += ") WHERE ROWNUM < 200"
			EndIf		
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"GV8_DSTORI","N",TamSx3("GV8_DSTORI")[1],TamSx3("GV8_DSTORI")[2])
			tcSetField(cAliasQry,"GV8_DSTORF","N",TamSx3("GV8_DSTORF")[1],TamSx3("GV8_DSTORF")[2])
			tcSetField(cAliasQry,"GV8_DSTDEI","N",TamSx3("GV8_DSTDEI")[1],TamSx3("GV8_DSTDEI")[2])
			tcSetField(cAliasQry,"GV8_DSTDEF","N",TamSx3("GV8_DSTDEF")[1],TamSx3("GV8_DSTDEF")[2])
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV8|" // Rota da tabela de frete
				cString += AllTrim((cAliasQry)->GV8_NRROTA) + "|"
				cString += AllTrim((cAliasQry)->GV8_TPORIG) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRCIOR) + "|"
				cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+(cAliasQry)->GV8_NRCIOR,"GU7_NMCID")) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTORI) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTORF) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRREOR) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDPAOR) + "|"
				cString += AllTrim(Posicione("SYA",1,XFILIAL("SYA")+(cAliasQry)->GV8_CDPAOR,"YA_DESCR")) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDUFOR) + "|"
				cString += AllTrim(Posicione("GU3",1,XFILIAL("GU3")+(cAliasQry)->GV8_CDREM,"GU3_NMEMIT"))  + "|"
				cString += AllTrim((cAliasQry)->GV8_TPDEST) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRCIDS) + "|"
				cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+(cAliasQry)->GV8_NRCIDS,"GU7_NMCID")) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTDEI) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTDEF) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRREDS) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDPADS) + "|"
				cString += AllTrim(Posicione("SYA",1,XFILIAL("SYA")+(cAliasQry)->GV8_CDPADS,"YA_DESCR")) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDUFDS) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDDEST) + "|"
				cString += AllTrim(Posicione("GU3",1,XFILIAL("GU3")+(cAliasQry)->GV8_CDDEST,"GU3_NMEMIT"))  + "|"
				cString += AllTrim((cAliasQry)->GV8_CDREM) + "|"
				cString += AllTrim(Posicione("GU9",1,XFILIAL("GU9")+(cAliasQry)->GV8_NRREOR,"GU9_NMREG")) + "|"
				cString += AllTrim(Posicione("GU9",1,XFILIAL("GU9")+(cAliasQry)->GV8_NRREDS,"GU9_NMREG")) + "|"
				
				cUltReg := AllTrim((cAliasQry)->GV8_NRROTA)
				
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbCloseArea())
			
			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := " SELECT TOP 1"
			EndIf
			cQuery += " GV8.GV8_NRROTA"
			cQuery +=   " FROM " + RetSqlName("GV8") + " GV8"
			cQuery +=  " WHERE GV8.GV8_FILIAL = '" + RetFilTab("GV8",cFil) + "'"
			cQuery +=    " AND GV8.GV8_CDEMIT = '" + (cTmp)->GV9_CDEMIT + "'"
			cQuery +=    " AND GV8.GV8_NRTAB  = '" + (cTmp)->GV9_NRTAB + "'"
			cQuery +=    " AND GV8.GV8_NRNEG  = '" + (cTmp)->GV9_NRNEG + "'"
			cQuery +=    " AND GV8.GV8_NRROTA > '" + cUltReg + "' "
			cQuery +=    " AND GV8.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GV8.GV8_NRROTA"

			If cBcoDados == "ORACLE"
				cQuery += ") WHERE  ROWNUM < 1"
			EndIf
						
			cQuery := ChangeQuery(cQuery)
			cAliasAux := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasAux, .T., .F. )
			
			If (cAliasAux)->(!EoF())
				cString += "$" + cUltReg + "$"
			EndIf
			
			(cAliasAux)->(dbCloseArea())			
		Case cTabela == "GV7" .And. cCodInt == "7"
		
			cQuery := " SELECT GV7.GV7_CDFXTV,"
			cQuery +=        " GV7.GV7_CDTPVC,"
			cQuery +=        " CASE WHEN GV3.GV3_DSTPVC IS NULL THEN '' ELSE GV3.GV3_DSTPVC END GV7_DSTPVC,"
			cQuery +=        " GV7.GV7_QTFXFI,"
			cQuery +=        " GV7.GV7_UNICAL,"
			cQuery +=        " GV7.GV7_VLALUG,"
			cQuery +=        " GV7.GV7_FRQKM,"
			cQuery +=        " GV7.GV7_VLKMEX"
			cQuery +=   " FROM "+RetSqlName("GV7")+" GV7"
			cQuery +=   " LEFT JOIN "+RetSqlName("GV3")+" GV3"
			cQuery +=     " ON GV3.GV3_FILIAL = '"+RetFilTab("GV3",cFil)+"'"
			cQuery +=    " AND GV3.GV3_CDTPVC = GV7.GV7_CDTPVC"
			cQuery +=    " AND GV3.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE GV7.GV7_FILIAL = '"+RetFilTab("GV7",cFil)+"'"
			cQuery +=    " AND GV7.GV7_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV7.GV7_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV7.GV7_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			cQuery +=    " AND GV7.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"GV7_QTFXFI","N",TamSx3("GV7_QTFXFI")[1],TamSx3("GV7_QTFXFI")[2])
			tcSetField(cAliasQry,"GV7_VLALUG","N",TamSx3("GV7_VLALUG")[1],TamSx3("GV7_VLALUG")[2])
			tcSetField(cAliasQry,"GV7_FRQKM" ,"N",TamSx3("GV7_FRQKM" )[1],TamSx3("GV7_FRQKM" )[2])
			tcSetField(cAliasQry,"GV7_VLKMEX","N",TamSx3("GV7_VLKMEX")[1],TamSx3("GV7_VLKMEX")[2])
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV7|" // Faixa/Tp veic tabela de frete
				cString += AllTrim((cAliasQry)->GV7_CDFXTV) + "|"
				cString += AllTrim((cAliasQry)->GV7_CDTPVC) + "|"
				cString += AllTrim((cAliasQry)->GV7_DSTPVC) + "|"
				cString += CValtoChar((cAliasQry)->GV7_QTFXFI) + "|"
				cString += AllTrim((cAliasQry)->GV7_UNICAL) + "|"
				cString += CValtoChar((cAliasQry)->GV7_VLALUG) + "|"
				cString += CValtoChar((cAliasQry)->GV7_FRQKM)  + "|"
				cString += CValtoChar((cAliasQry)->GV7_VLKMEX) + "|"
					
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			
		Case cTabela == "GV1" .And. cCodInt == "7"
		
			cQuery := " SELECT GV1.GV1_CDFXTV,"
			cQuery +=        " GV1.GV1_NRROTA,"
			cQuery +=        " GV1.GV1_CDCOMP,"
			cQuery +=        " GV1.GV1_VLFIXN,"
			cQuery +=        " GV1.GV1_PCNORM,"
			cQuery +=        " GV1.GV1_VLUNIN,"
			cQuery +=        " GV1.GV1_VLFRAC,"
			cQuery +=        " GV1.GV1_VLMINN,"
			cQuery +=        " GV1.GV1_VLLIM,"
			cQuery +=        " GV1.GV1_VLFIXE,"
			cQuery +=        " GV1.GV1_PCEXTR,"
			cQuery +=        " GV1.GV1_VLUNIE,"
			cQuery +=        " GV1.GV1_CALCEX"
			cQuery +=   " FROM "+RetSqlName("GV1")+" GV1"
			cQuery +=  " WHERE GV1.GV1_FILIAL = '"+RetFilTab("GV1",cFil)+"'"
			cQuery +=    " AND GV1.GV1_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV1.GV1_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV1.GV1_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			cQuery +=    " AND GV1.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"GV1_VLFIXN","N",TamSx3("GV1_VLFIXN")[1],TamSx3("GV1_VLFIXN")[2])
			tcSetField(cAliasQry,"GV1_PCNORM","N",TamSx3("GV1_PCNORM")[1],TamSx3("GV1_PCNORM")[2])
			tcSetField(cAliasQry,"GV1_VLUNIN","N",TamSx3("GV1_VLUNIN")[1],TamSx3("GV1_VLUNIN")[2])
			tcSetField(cAliasQry,"GV1_VLFRAC","N",TamSx3("GV1_VLFRAC")[1],TamSx3("GV1_VLFRAC")[2])
			tcSetField(cAliasQry,"GV1_VLMINN","N",TamSx3("GV1_VLMINN")[1],TamSx3("GV1_VLMINN")[2])
			tcSetField(cAliasQry,"GV1_VLLIM" ,"N",TamSx3("GV1_VLLIM" )[1],TamSx3("GV1_VLLIM" )[2])
			tcSetField(cAliasQry,"GV1_VLFIXE","N",TamSx3("GV1_VLFIXE")[1],TamSx3("GV1_VLFIXE")[2])
			tcSetField(cAliasQry,"GV1_PCEXTR","N",TamSx3("GV1_PCEXTR")[1],TamSx3("GV1_PCEXTR")[2])
			tcSetField(cAliasQry,"GV1_VLUNIE","N",TamSx3("GV1_VLUNIE")[1],TamSx3("GV1_VLUNIE")[2])
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV1|" // Componenete tarifa tabela de frete
				cString += AllTrim((cAliasQry)->GV1_CDFXTV) + "|"
				cString += AllTrim((cAliasQry)->GV1_NRROTA) + "|"
				cString += AllTrim(NOACENTO((cAliasQry)->GV1_CDCOMP)) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLFIXN) + "|"
				cString += CValtoChar((cAliasQry)->GV1_PCNORM) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLUNIN) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLFRAC) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLMINN) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLLIM)  + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLFIXE) + "|"
				cString += CValtoChar((cAliasQry)->GV1_PCEXTR) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLUNIE) + "|"
				cString += AllTrim((cAliasQry)->GV1_CALCEX) + "|"
					
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			
		Case cTabela == "GVQ" .And. cCodInt == "7"
		
			// Realiza o dbSeek por causa do campo Memo
			GVQ->(dbSetOrder(1)) // GVQ_FILIAL+GVQ_TPCOT+GVQ_CODCOT+GVQ_SEQCOT
			If GVQ->(dbSeek(xFilial("GVQ")+"1"+(cTmp)->(GV9_CODCOT+GV9_SEQCOT)))
				cString += "#GVQ|" // Cotação de Frete
				cString += AllTrim(GVQ->GVQ_CODCOT) + "|"
				cString += AllTrim(GVQ->GVQ_SEQCOT) + "|"
				cObsCot := StrTran( GVQ->GVQ_OBSCOT, Chr(13)+Chr(10), "][")
				cString += FwCutOff(cObsCot,.T.) + "|"
				cString += cValtoChar(GVQ->GVQ_VALCOT) + "|"
			EndIf	
			cString := FwNoAccent(cString)
			
		Case cTabela == "GV6" .And. cCodInt == "7"
		
			// Envio da tabela GV6
			cQuery := " SELECT GV6.GV6_CDEMIT,"
			cQuery += 		   " GV6.GV6_NRTAB,"
			cQuery += 		   " GV6.GV6_NRNEG,"
			cQuery += 		   " GV6.GV6_CDFXTV,"
			cQuery += 		   " GV6.GV6_NRROTA,"
			cQuery += 		   " GV6.GV6_CONSPZ,"
			cQuery +=        " GV6.GV6_QTPRAZ,"
			cQuery +=        " GV6.GV6_TPPRAZ,"
			cQuery +=        " GV6.GV6_CONTPZ"
			cQuery +=   " FROM "+RetSqlName("GV6")+" GV6 "
			cQuery +=  " WHERE GV6.GV6_FILIAL = '"+RetFilTab("GV6",cFil)+"'"
			cQuery +=    " AND GV6.GV6_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV6.GV6_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV6.GV6_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			cQuery +=    " AND GV6.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV6|" // Componenete tarifa tabela de frete
				cString += AllTrim((cAliasQry)->GV6_CDEMIT) + "|"
				cString += AllTrim((cAliasQry)->GV6_NRTAB) + "|"
				cString += AllTrim((cAliasQry)->GV6_NRNEG) + "|"
				cString += AllTrim((cAliasQry)->GV6_CDFXTV) + "|"
				cString += AllTrim((cAliasQry)->GV6_NRROTA) + "|"
				cString += AllTrim((cAliasQry)->GV6_CONSPZ) + "|"
				cString += CValtoChar((cAliasQry)->GV6_QTPRAZ) + "|"
				cString += AllTrim((cAliasQry)->GV6_TPPRAZ) + "|"
				cString += AllTrim((cAliasQry)->GV6_CONTPZ)
					
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
			
		Case cTabela == "GVA" .And. cCodInt == "7"
		
			// Envio das tabelas Vinculadas
			cQuery := " SELECT GVA.GVA_FILIAL,"
			cQuery += 		   " GVA.GVA_CDEMIT,"
			cQuery += 		   " GVA.GVA_EMIVIN,"
			cQuery += 		   " GVA.GVA_TABVIN,"
			cQuery += 		   " GVA.GVA_NRTAB,"
			cQuery +=        " GVA.GVA_DSTAB,"
			cQuery +=        " GVA.GVA_DTATU,"
			cQuery +=        " GVA.GVA_HRATU,"
			cQuery +=        " GVA.GVA_VLMULT,"
			cQuery +=        " GVA.GVA_VLADIC"
			cQuery +=   " FROM "+RetSqlName("GVA")+" GVA"
			cQuery +=  " WHERE GVA.GVA_FILIAL = '"+RetFilTab("GVA",cFil)+"'"
			cQuery +=    " AND GVA.GVA_EMIVIN = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GVA.GVA_TABVIN = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GVA.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
						
			Do While (cAliasQry)->(!Eof())
				cString += "|#GVA|"
				cString += AllTrim((cAliasQry)->GVA_CDEMIT) + "|"
				cString += AllTrim((cAliasQry)->GVA_NRTAB)  + "|"
				cString += AllTrim((cAliasQry)->GVA_DSTAB)  + "|"
				cString += AllTrim((cAliasQry)->GVA_DTATU)  + "|"
				cString += AllTrim((cAliasQry)->GVA_HRATU)  + "|"
				cString += AllTrim(cValToChar((cAliasQry)->GVA_VLMULT)) + "|"
				cString += AllTrim(cValToChar((cAliasQry)->GVA_VLADIC))
					
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbCloseArea())
			
		Case cTabela == "GV9" .And. cCodInt == "6"
			// Filial que será enviada na string
			If !Empty(cFil) .And. FWModeAccess("GV9",1) == "E"
				cFilEnvi := cFil
			Else
				cFilEnvi := cFilAnt
			EndIf
			
			cString := "#GV9|" // Negociação tabela de frete
			cString += AllTrim(cFilEnvi) + "|"
			cString += AllTrim((cTmp)->GV9_CDEMIT) + "|"
			cString += AllTrim((cTmp)->GV9_NRTAB)  + "|"
			cString += AllTrim((cTmp)->GV9_NRNEG)  + "|"
			cString += AllTrim((cTmp)->GV9_CDCLFR) + "|"
			cString += AllTrim(Posicione("GUB",1,xFilial("GUB")+(cTmp)->GV9_CDCLFR,"GUB_DSCLFR")) + "|"
			cString += AllTrim((cTmp)->GV9_CDTPOP) + "|"
			cString += AllTrim(Posicione("GV4",1,xFilial("GV4")+(cTmp)->GV9_CDTPOP,"GV4_DSTPOP")) + "|"
			cString += AllTrim((cTmp)->GV9_DTVALI) + "|"
			cString += AllTrim((cTmp)->GV9_DTVALF) + "|"
			cString += AllTrim((cTmp)->GV9_TPLOTA) + "|"
			cString += AllTrim((cTmp)->GV9_DTCRIA) + "|"
			cString += AllTrim((cTmp)->GV9_USUCRI) + "|"
			cString += AllTrim((cTmp)->GV9_SITMLA) + "|"
			cString += AllTrim((cTmp)->GV9_SIT)    + "|"
			cString += AllTrim((cTmp)->GV9_SITCON) + "|"
			cString := FwNoAccent(cString)
			
		Case cTabela == "GV8" .And. cCodInt == "6"
			cString := ""
			
			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := " SELECT TOP 200"
			EndIf 
			cQuery +=        " GV8.GV8_NRROTA,"
			cQuery +=        " GV8.GV8_TPORIG,"
			cQuery +=        " GV8.GV8_NRCIOR,"
			cQuery +=        " GV8.GV8_DSTORI,"
			cQuery +=        " GV8.GV8_DSTORF,"
			cQuery +=        " GV8.GV8_NRREOR,"
			cQuery +=        " GV8.GV8_CDPAOR,"
			cQuery +=        " GV8.GV8_CDUFOR,"
			cQuery +=        " GV8.GV8_TPDEST,"
			cQuery +=        " GV8.GV8_NRCIDS,"
			cQuery +=        " GV8.GV8_DSTDEI,"
			cQuery +=        " GV8.GV8_DSTDEF,"
			cQuery +=        " GV8.GV8_NRREDS,"
			cQuery +=        " GV8.GV8_CDPADS,"
			cQuery +=        " GV8.GV8_CDUFDS,"
			cQuery +=        " GV8.GV8_CDREM,"
			cQuery +=        " GV8.GV8_CDDEST"
			cQuery +=   " FROM "+RetSqlName("GV8")+" GV8"
			cQuery +=  " WHERE GV8.GV8_FILIAL = '"+RetFilTab("GV8",cFil)+"'"
			cQuery +=    " AND GV8.GV8_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV8.GV8_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV8.GV8_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			If cParte != "1"
				cQuery += " AND GV8.GV8_NRROTA > '" + cParte + "' "
			EndIf
			cQuery +=    " AND GV8.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GV8.GV8_NRROTA"
			If cBcoDados == "ORACLE"
				cQuery += ") WHERE ROWNUM < 200"
			EndIf
			
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"GV8_DSTORI","N",TamSx3("GV8_DSTORI")[1],TamSx3("GV8_DSTORI")[2])
			tcSetField(cAliasQry,"GV8_DSTORF","N",TamSx3("GV8_DSTORF")[1],TamSx3("GV8_DSTORF")[2])
			tcSetField(cAliasQry,"GV8_DSTDEI","N",TamSx3("GV8_DSTDEI")[1],TamSx3("GV8_DSTDEI")[2])
			tcSetField(cAliasQry,"GV8_DSTDEF","N",TamSx3("GV8_DSTDEF")[1],TamSx3("GV8_DSTDEF")[2])
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV8|" // Rota da tabela de frete
				cString += AllTrim((cAliasQry)->GV8_NRROTA) + "|"
				cString += AllTrim((cAliasQry)->GV8_TPORIG) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRCIOR) + "|"
				cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+(cAliasQry)->GV8_NRCIOR,"GU7_NMCID")) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTORI) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTORF) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRREOR) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDPAOR) + "|"
				cString += AllTrim(Posicione("SYA",1,XFILIAL("SYA")+(cAliasQry)->GV8_CDPAOR,"YA_DESCR")) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDUFOR) + "|"
				cString += AllTrim(Posicione("GU3",1,XFILIAL("GU3")+(cAliasQry)->GV8_CDREM,"GU3_NMEMIT"))  + "|"
				cString += AllTrim((cAliasQry)->GV8_TPDEST) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRCIDS) + "|"
				cString += AllTrim(Posicione("GU7",1,XFILIAL("GU7")+(cAliasQry)->GV8_NRCIDS,"GU7_NMCID")) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTDEI) + "|"
				cString += CValtoChar((cAliasQry)->GV8_DSTDEF) + "|"
				cString += AllTrim((cAliasQry)->GV8_NRREDS) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDPADS) + "|"
				cString += AllTrim(Posicione("SYA",1,XFILIAL("SYA")+(cAliasQry)->GV8_CDPADS,"YA_DESCR")) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDUFDS) + "|"
				cString += AllTrim((cAliasQry)->GV8_CDDEST) + "|"
				cString += AllTrim(Posicione("GU3",1,XFILIAL("GU3")+(cAliasQry)->GV8_CDDEST,"GU3_NMEMIT"))  + "|"
				cString += AllTrim((cAliasQry)->GV8_CDREM) + "|"
				cString += AllTrim(Posicione("GU9",1,XFILIAL("GU9")+(cAliasQry)->GV8_NRREOR,"GU9_NMREG")) + "|"
				cString += AllTrim(Posicione("GU9",1,XFILIAL("GU9")+(cAliasQry)->GV8_NRREDS,"GU9_NMREG")) + "|"

				cUltReg := AllTrim((cAliasQry)->GV8_NRROTA)
									
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT" 
			Else
				cQuery := " SELECT TOP 1"
			EndIf
			cQuery += " GV8.GV8_NRROTA"
			cQuery +=   " FROM " + RetSqlName("GV8") + " GV8"
			cQuery +=  " WHERE GV8.GV8_FILIAL = '" + RetFilTab("GV8",cFil) + "'"
			cQuery +=    " AND GV8.GV8_CDEMIT = '" + (cTmp)->GV9_CDEMIT + "'"
			cQuery +=    " AND GV8.GV8_NRTAB  = '" + (cTmp)->GV9_NRTAB + "'"
			cQuery +=    " AND GV8.GV8_NRNEG  = '" + (cTmp)->GV9_NRNEG + "'"
			cQuery +=    " AND GV8.GV8_NRROTA > '" + cUltReg + "' "
			cQuery +=    " AND GV8.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GV8.GV8_NRROTA"

			If cBcoDados == "ORACLE"
				cQuery += " ) WHERE ROWNUM < 1"
			EndIf
						
			cQuery := ChangeQuery(cQuery)
			cAliasAux := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasAux, .T., .F. )
			
			If (cAliasAux)->(!EoF())
				cString += "$" + cUltReg + "$"
			EndIf
			
			(cAliasAux)->(dbCloseArea())

		Case cTabela == "GV7" .And. cCodInt == "6"
			cString := ""
			
			cQuery := " SELECT GV7.GV7_CDFXTV,"
			cQuery +=        " GV7.GV7_CDTPVC,"
			cQuery +=        " CASE WHEN GV3.GV3_DSTPVC IS NULL THEN '' ELSE GV3.GV3_DSTPVC END GV7_DSTPVC,"
			cQuery +=        " GV7.GV7_QTFXFI,"
			cQuery +=        " GV7.GV7_UNICAL,"
			cQuery +=        " GV7.GV7_VLALUG,"
			cQuery +=        " GV7.GV7_FRQKM,"
			cQuery +=        " GV7.GV7_VLKMEX"
			cQuery +=   " FROM "+RetSqlName("GV7")+" GV7"
			cQuery +=   " LEFT JOIN "+RetSqlName("GV3")+" GV3"
			cQuery +=     " ON GV3.GV3_FILIAL = '"+RetFilTab("GV3",cFil)+"'"
			cQuery +=    " AND GV3.GV3_CDTPVC = GV7.GV7_CDTPVC"
			cQuery +=    " AND GV3.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE GV7.GV7_FILIAL = '"+RetFilTab("GV7",cFil)+"'"
			cQuery +=    " AND GV7.GV7_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV7.GV7_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV7.GV7_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			cQuery +=    " AND GV7.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"GV7_QTFXFI","N",TamSx3("GV7_QTFXFI")[1],TamSx3("GV7_QTFXFI")[2])
			tcSetField(cAliasQry,"GV7_VLALUG","N",TamSx3("GV7_VLALUG")[1],TamSx3("GV7_VLALUG")[2])
			tcSetField(cAliasQry,"GV7_FRQKM" ,"N",TamSx3("GV7_FRQKM" )[1],TamSx3("GV7_FRQKM" )[2])
			tcSetField(cAliasQry,"GV7_VLKMEX","N",TamSx3("GV7_VLKMEX")[1],TamSx3("GV7_VLKMEX")[2])
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV7|" // Faixa/Tp veic tabela de frete
				cString += AllTrim((cAliasQry)->GV7_CDFXTV) + "|"
				cString += AllTrim((cAliasQry)->GV7_CDTPVC) + "|"
				cString += AllTrim((cAliasQry)->GV7_DSTPVC) + "|"
				cString += CValtoChar((cAliasQry)->GV7_QTFXFI) + "|"
				cString += AllTrim((cAliasQry)->GV7_UNICAL) + "|"
				cString += CValtoChar((cAliasQry)->GV7_VLALUG) + "|"
				cString += CValtoChar((cAliasQry)->GV7_FRQKM)  + "|"
				cString += CValtoChar((cAliasQry)->GV7_VLKMEX) + "|"
					
				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

		Case cTabela == "GV1" .And. cCodInt == "6"
			cString := ""

			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := " SELECT TOP 600"
			EndIf
			cQuery += 		 " GV1.GV1_CDFXTV,"
			cQuery +=        " GV1.GV1_NRROTA,"
			cQuery +=        " GV1.GV1_CDCOMP,"
			cQuery +=        " GV1.GV1_VLFIXN,"
			cQuery +=        " GV1.GV1_PCNORM,"
			cQuery +=        " GV1.GV1_VLUNIN,"
			cQuery +=        " GV1.GV1_VLFRAC,"
			cQuery +=        " GV1.GV1_VLMINN,"
			cQuery +=        " GV1.GV1_VLLIM,"
			cQuery +=        " GV1.GV1_VLFIXE,"
			cQuery +=        " GV1.GV1_PCEXTR,"
			cQuery +=        " GV1.GV1_VLUNIE,"
			cQuery +=        " GV1.GV1_CALCEX,"
			cQuery +=        " GV1.R_E_C_N_O_"
			cQuery +=   " FROM "+RetSqlName("GV1")+" GV1"
			cQuery +=  " WHERE GV1.GV1_FILIAL = '"+RetFilTab("GV1",cFil)+"'"
			cQuery +=    " AND GV1.GV1_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV1.GV1_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV1.GV1_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			
			If Val(cParte) != 1
				cQuery += " AND GV1.R_E_C_N_O_ > '" + cParte + "'"
			EndIf
			
			cQuery +=    " AND GV1.D_E_L_E_T_ = ' '"
			cQuery += 	 " ORDER BY GV1.R_E_C_N_O_"

			If cBcoDados == "ORACLE"
				cQuery += " ) WHERE ROWNUM < 600"
			EndIf			
			
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			tcSetField(cAliasQry,"GV1_VLFIXN","N",TamSx3("GV1_VLFIXN")[1],TamSx3("GV1_VLFIXN")[2])
			tcSetField(cAliasQry,"GV1_PCNORM","N",TamSx3("GV1_PCNORM")[1],TamSx3("GV1_PCNORM")[2])
			tcSetField(cAliasQry,"GV1_VLUNIN","N",TamSx3("GV1_VLUNIN")[1],TamSx3("GV1_VLUNIN")[2])
			tcSetField(cAliasQry,"GV1_VLFRAC","N",TamSx3("GV1_VLFRAC")[1],TamSx3("GV1_VLFRAC")[2])
			tcSetField(cAliasQry,"GV1_VLMINN","N",TamSx3("GV1_VLMINN")[1],TamSx3("GV1_VLMINN")[2])
			tcSetField(cAliasQry,"GV1_VLLIM" ,"N",TamSx3("GV1_VLLIM" )[1],TamSx3("GV1_VLLIM" )[2])
			tcSetField(cAliasQry,"GV1_VLFIXE","N",TamSx3("GV1_VLFIXE")[1],TamSx3("GV1_VLFIXE")[2])
			tcSetField(cAliasQry,"GV1_PCEXTR","N",TamSx3("GV1_PCEXTR")[1],TamSx3("GV1_PCEXTR")[2])
			tcSetField(cAliasQry,"GV1_VLUNIE","N",TamSx3("GV1_VLUNIE")[1],TamSx3("GV1_VLUNIE")[2])
			
			cUltReg := ""

			Do While (cAliasQry)->(!Eof())
				cString += "#GV1|" // Componenete tarifa tabela de frete
				cString += AllTrim((cAliasQry)->GV1_CDFXTV) + "|"
				cString += AllTrim((cAliasQry)->GV1_NRROTA) + "|"
				cString += AllTrim(NOACENTO((cAliasQry)->GV1_CDCOMP)) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLFIXN) + "|"
				cString += CValtoChar((cAliasQry)->GV1_PCNORM) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLUNIN) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLFRAC) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLMINN) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLLIM)  + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLFIXE) + "|"
				cString += CValtoChar((cAliasQry)->GV1_PCEXTR) + "|"
				cString += CValtoChar((cAliasQry)->GV1_VLUNIE) + "|"
				cString += AllTrim((cAliasQry)->GV1_CALCEX) + "|"
					
				cUltReg := cValToChar((cAliasQry)->R_E_C_N_O_)

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())
		
			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := " SELECT TOP 1"
			EndIf 
			cQuery += " GV1.R_E_C_N_O_"
			cQuery +=   " FROM " + RetSqlName("GV1") + " GV1"
			cQuery +=  " WHERE GV1.GV1_FILIAL = '" + RetFilTab("GV8",cFil) + "'"
			cQuery +=    " AND GV1.GV1_CDEMIT = '" + (cTmp)->GV9_CDEMIT + "'"
			cQuery +=    " AND GV1.GV1_NRTAB  = '" + (cTmp)->GV9_NRTAB + "'"
			cQuery +=    " AND GV1.GV1_NRNEG  = '" + (cTmp)->GV9_NRNEG + "'"
			cQuery +=    " AND GV1.R_E_C_N_O_ > '" + cUltReg + "' "
			cQuery +=    " AND GV1.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GV1.R_E_C_N_O_"	
			
			If cBcoDados == "ORACLE"
				cQuery += " ) WHERE ROWNUM < 1"
			EndIf
					
			cQuery := ChangeQuery(cQuery)
			cAliasAux := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasAux, .T., .F. )
			
			If (cAliasAux)->(!EoF())
				cString += "$" + cUltReg + "$"
			EndIf
			
			(cAliasAux)->(dbCloseArea())
			
		Case cTabela == "GVQ" .And. cCodInt == "6"
			cString := ""

			// Realiza o dbSeek por causa do campo Memo
			GVQ->(dbSetOrder(1)) // GVQ_FILIAL+GVQ_TPCOT+GVQ_CODCOT+GVQ_SEQCOT
			If GVQ->(dbSeek(xFilial("GVQ")+"1"+(cTmp)->(GV9_CODCOT+GV9_SEQCOT)))
				cString += "#GVQ|" // Cotação de Frete
				cString += AllTrim(GVQ->GVQ_CODCOT) + "|"
				cString += AllTrim(GVQ->GVQ_SEQCOT) + "|"
				cObsCot := StrTran( GVQ->GVQ_OBSCOT, Chr(13)+Chr(10), "][")
				cString += FwCutOff(cObsCot,.T.) + "|"
				cString += cValtoChar(GVQ->GVQ_VALCOT) + "|"
			EndIf	
			cString := FwNoAccent(cString)
			
		Case cTabela == "GV6" .And. cCodInt == "6"
			cString := ""
						
			// Envio da tabela GV6
			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := " SELECT TOP 600"
			EndIf
			cQuery +=          " GV6.GV6_CDEMIT,"
			cQuery += 		   " GV6.GV6_NRTAB,"
			cQuery += 		   " GV6.GV6_NRNEG,"
			cQuery += 		   " GV6.GV6_CDFXTV,"
			cQuery += 		   " GV6.GV6_NRROTA,"
			cQuery += 		   " GV6.GV6_CONSPZ,"
			cQuery +=          " GV6.GV6_QTPRAZ,"
			cQuery +=          " GV6.GV6_TPPRAZ,"
			cQuery +=          " GV6.GV6_CONTPZ,"
			cQuery +=		   " GV6.R_E_C_N_O_"
			cQuery +=   " FROM "+RetSqlName("GV6")+" GV6 "
			cQuery +=  " WHERE GV6.GV6_FILIAL = '"+RetFilTab("GV6",cFil)+"'"
			cQuery +=    " AND GV6.GV6_CDEMIT = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GV6.GV6_NRTAB  = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GV6.GV6_NRNEG  = '"+(cTmp)->GV9_NRNEG+"'"
			
			If Val(cParte) != 1
				cQuery += " AND GV6.R_E_C_N_O_ > '" + cParte + "'"
			EndIf
			
			cQuery +=    " AND GV6.D_E_L_E_T_ = ' '"
			cQuery +=	 " ORDER BY GV6.R_E_C_N_O_"

			If cBcoDados == "ORACLE"
				cQuery += " ) WHERE ROWNUM < 600"
			EndIf
			
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
			
			Do While (cAliasQry)->(!Eof())
				cString += "#GV6|" // Componenete tarifa tabela de frete
				cString += AllTrim((cAliasQry)->GV6_CDEMIT) + "|"
				cString += AllTrim((cAliasQry)->GV6_NRTAB) + "|"
				cString += AllTrim((cAliasQry)->GV6_NRNEG) + "|"
				cString += AllTrim((cAliasQry)->GV6_CDFXTV) + "|"
				cString += AllTrim((cAliasQry)->GV6_NRROTA) + "|"
				cString += AllTrim((cAliasQry)->GV6_CONSPZ) + "|"
				cString += CValtoChar((cAliasQry)->GV6_QTPRAZ) + "|"
				cString += AllTrim((cAliasQry)->GV6_TPPRAZ) + "|"
				cString += AllTrim((cAliasQry)->GV6_CONTPZ)
					
				cUltReg := cValToChar((cAliasQry)->R_E_C_N_O_)

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			If cBcoDados == "ORACLE"
				cQuery := " SELECT * FROM (SELECT"
			Else
				cQuery := " SELECT TOP 1"
			EndIf
			cQuery += " GV6.R_E_C_N_O_"
			cQuery +=   " FROM " + RetSqlName("GV6") + " GV6"
			cQuery +=  " WHERE GV6.GV6_FILIAL = '" + RetFilTab("GV8",cFil) + "'"
			cQuery +=    " AND GV6.GV6_CDEMIT = '" + (cTmp)->GV9_CDEMIT + "'"
			cQuery +=    " AND GV6.GV6_NRTAB  = '" + (cTmp)->GV9_NRTAB + "'"
			cQuery +=    " AND GV6.GV6_NRNEG  = '" + (cTmp)->GV9_NRNEG + "'"
			cQuery +=    " AND GV6.R_E_C_N_O_ > '" + cUltReg + "' "
			cQuery +=    " AND GV6.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GV6.R_E_C_N_O_"

			If cBcoDados == "ORACLE"
				cQuery += " ) WHERE ROWNUM < 1"
			EndIf
						
			cQuery := ChangeQuery(cQuery)
			cAliasAux := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasAux, .T., .F. )
			
			If (cAliasAux)->(!EoF())
				cString += "$" + cUltReg + "$"
			EndIf
			
			(cAliasAux)->(dbCloseArea())
		
		Case cTabela == "GVA" .And. cCodInt == "6"
			cString := ""

			// Envio das tabelas Vinculadas
			cQuery := " SELECT GVA.GVA_FILIAL,"
			cQuery += 		   " GVA.GVA_CDEMIT,"
			cQuery += 		   " GVA.GVA_EMIVIN,"
			cQuery += 		   " GVA.GVA_TABVIN,"
			cQuery += 		   " GVA.GVA_NRTAB,"
			cQuery +=        " GVA.GVA_DSTAB,"
			cQuery +=        " GVA.GVA_DTATU,"
			cQuery +=        " GVA.GVA_HRATU,"
			cQuery +=        " GVA.GVA_VLMULT,"
			cQuery +=        " GVA.GVA_VLADIC"
			cQuery +=   " FROM "+RetSqlName("GVA")+" GVA"
			cQuery +=  " WHERE GVA.GVA_FILIAL = '"+RetFilTab("GVA",cFil)+"'"
			cQuery +=    " AND GVA.GVA_EMIVIN = '"+(cTmp)->GV9_CDEMIT+"'"
			cQuery +=    " AND GVA.GVA_TABVIN = '"+(cTmp)->GV9_NRTAB+"'"
			cQuery +=    " AND GVA.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )
					
			Do While (cAliasQry)->(!Eof())
				cString += "|#GVA|"
				cString += AllTrim((cAliasQry)->GVA_CDEMIT) + "|"
				cString += AllTrim((cAliasQry)->GVA_NRTAB)  + "|"
				cString += AllTrim((cAliasQry)->GVA_DSTAB)  + "|"
				cString += AllTrim((cAliasQry)->GVA_DTATU)  + "|"
				cString += AllTrim((cAliasQry)->GVA_HRATU)  + "|"
				cString += AllTrim(cValToChar((cAliasQry)->GVA_VLMULT)) + "|"
				cString += AllTrim(cValToChar((cAliasQry)->GVA_VLADIC))
				
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbCloseArea())
		
    Case cTabela == "GW1" .And. cCodInt == "7"
			aAdd(aParamGW1, {(cTmp)->GW1_FILIAL, (cTmp)->GW1_CDTPDC, (cTmp)->GW1_EMISDC, (cTmp)->GW1_SERDC, (cTmp)->GW1_NRDC })
			cAliasGW1 := GFEBIDISPF({},aParamGW1)	
			
			cString := "#GW1;" // Documentos de Carga
			cString += AllTrim((cTmp)->GW1_FILIAL) + ";" //Filial do documento
			cString += AllTrim((cTmp)->GW1_CDTPDC) + ";" //Tipo do documento
			cString += Alltrim((cTmp)->GW1_EMISDC) + ";" //Emissor do documento
			cString += Alltrim((cTmp)->GW1_SERDC) + ";" //Série do documento
			cString += Alltrim((cTmp)->GW1_NRDC) + ";" //Numero do documento
			cString += CValtoChar((cAliasGW1)->Re_TotFrt) + ";" //Frete total realizado 
			cString += CValtoChar((cAliasGW1)->VALORFRETE + (cAliasGW1)->VL_DIARIA) + ";" //Frete total previsto
			cString += CValtoChar((cAliasGW1)->Pr_VlFrtNr + (cAliasGW1)->Pr_Redesp) + ";" //Frete previsto
			cString += CValtoChar((cAliasGW1)->Re_FrtNorm + (cAliasGW1)->Re_VlRedes) + ";" //Frete realizado
			cString += CValtoChar((cAliasGW1)->VL_DIARIA) + ";" //Previsto Serviço
			cString += CValtoChar((cAliasGW1)->Pr_VlReen) + ";" //Previsto Reentrega
			cString += CValtoChar((cAliasGW1)->Pr_VlDevol) + ";" //Previsto Devolução
			cString += CValtoChar((cAliasGW1)->Re_VlDiari) + ";" //Realizado Serviço
			cString += CValtoChar((cAliasGW1)->Re_VlTotRe) + ";" //Realizado Reentrega
			cString += CValtoChar((cAliasGW1)->Re_VlTotDe) + ";" //Realizado Devolução
			cString += Alltrim((cTmp)->GW1_NRROM) + ";" //Numero do Romaneio
			
			//Romaneio, usar o numero de romanio query com o indice 1 retorna o nome do motorista GUU, placa tem na mesma tabela GWN
			GWN->(dbSetOrder(1))
			If GWN->(dbSeek((cTmp)->GW1_FILIAL+(cTmp)->GW1_NRROM))
				GUU->(dbSetOrder(1))
				GUU->(dbSeek(xFilial("GUU")+GWN->GWN_CDMTR))
				cString += Alltrim(GUU->GUU_NMMTR) + ";" //Nome do motorista
				cString += Alltrim(GWN->GWN_PLACAD) //Placa dianteira
			Else
				cString += ";" 
			EndIf				
					
			GWL->(dbSetOrder(5))  
           If GWL->(dbSeek((cTmp)->GW1_FILIAL + (cTmp)->GW1_EMISDC + (cTmp)->GW1_CDTPDC + (cTmp)->GW1_SERDC + (cTmp)->GW1_NRDC))
	           While !GWL->(Eof()) .And. ;
	                        (cTmp)->GW1_FILIAL == GWL->GWL_FILDC .And. ;
	                        (cTmp)->GW1_EMISDC == GWL->GWL_EMITDC .And. ; 
	                        (cTmp)->GW1_CDTPDC == GWL->GWL_TPDC .AND. ; 
	                        (cTmp)->GW1_SERDC == GWL->GWL_SERDC .And. ; 
	                        (cTmp)->GW1_NRDC == GWL->GWL_NRDC
                       
	              GWD->(dbSetOrder(1))
	              If GWD->(dbSeek(GWL->GWL_FILIAL + GWL->GWL_NROCO))
	              
						cString += "|#GWD;" // Ocorrências
						cString += Alltrim(GWD->GWD_NROCO) + ";" //Numero Ocorrência
						cString += Alltrim(GWD->GWD_CDTIPO) + ";"
						GU5->(dbSetOrder(1))
						GU5->(dbSeek(xFilial("GU5")+GWD->GWD_CDTIPO))
						cString += Alltrim(GU5->GU5_DESC) + ";" //Descrição do tipo de ocorrência
						
						cString += Alltrim(GWD->GWD_CDMOT) + ";" 
						GU6->(dbSetOrder(1))
						GU6->(dbSeek(xFilial("GU6")+GWD->GWD_CDMOT))
						cString += Alltrim(GU6->GU6_DESC) + ";" //Descrição do motivo da ocorrência
			
						cString += DtoS(GWD->GWD_DTOCOR) + ";" //Data da ocorrência
						Do Case
							Case GWD->GWD_SIT == "1"
								cString += "Pendente" //Situação
							Case GWD->GWD_SIT == "2"
								cString += "Aprovada" //Situação
							Case GWD->GWD_SIT == "3"
								cString += "Reprovada"//Situação
						EndCase
						
					EndIf
				GWL->(dbSkip())
				EndDo
			EndIf
			
			GWU->(dbSetOrder(1))
			If GWU->(dbSeek(xFilial("GWU")+(cTmp)->GW1_CDTPDC+(cTmp)->GW1_EMISDC+(cTmp)->GW1_SERDC+(cTmp)->GW1_NRDC))
				While !GWU->(Eof()) .And. xFilial("GWU") == GWU->GWU_FILIAL .And. (cTmp)->GW1_CDTPDC == GWU->GWU_CDTPDC .And. ;
					(cTmp)->GW1_EMISDC == GWU->GWU_EMISDC .And. (cTmp)->GW1_SERDC == GWU->GWU_SERDC .And. (cTmp)->GW1_NRDC == GWU->GWU_NRDC
					
					If !Empty(GWU->GWU_DTENT)
						cString += "|#GWU;" // Entregas
						cString += Alltrim(GWU->GWU_SEQ)   + ";" // Número do Trecho
						cString += Alltrim(GWU->GWU_CDTRP) + ";" // Código da Transportadora
						cString += DtoS(GWU->GWU_DTENT) + ";" // Data de Entrega
						GWU->(dbSkip())
						If GWU->(Eof()) .Or. xFilial("GWU") != GWU->GWU_FILIAL .Or. (cTmp)->GW1_CDTPDC != GWU->GWU_CDTPDC .Or. ;
							(cTmp)->GW1_EMISDC != GWU->GWU_EMISDC .Or. (cTmp)->GW1_SERDC != GWU->GWU_SERDC .Or. (cTmp)->GW1_NRDC != GWU->GWU_NRDC
							cString += "Sim"
						Else
							cString += "Nao"
						EndIf						
					Else
						GWU->(dbSkip())
					EndIf
				Enddo
			EndIf
			
			cString := FwNoAccent(cString)
			(cAliasGW1)->(dbCloseArea())
	EndCase

	(cTmp)->(dbCloseArea())
	GWN->(dbCloseArea())
	GUU->(dbCloseArea())
	GWL->(dbCloseArea())
	GWD->(dbCloseArea())
	GU5->(dbCloseArea())
	GU6->(dbCloseArea())

Return cString

// Função responsável por realizar o envio das integrações para o Datasul (CD0433)
Function GFEWSGETDC(cTabela,cCodInt,cFil,cChaveFt,cParte)
	Local cAliasQry := ""
	Local cString	:= ""		
	Local cQuery	:= ""
	Local cTmp		:= "" 
	
	Local cUltReg 	:= ""
	Local cAliasAux := ""
	Local aChaveFt	:= []
	Local cBcoDados := Alltrim(TCGETDB())
	
	aChaveFt := StrTokArr(cChaveFt,"|")	
	
	cQuery := QueryBase(cTabela,cFil)

	Do Case 
		Case cTabela == "GW3"  .AND. cCodInt == '2'
			 // Fatura e Cod integração seja Financeiro
			 If len(aChaveFt) > 0
			 	cQuery += " AND TAB.GW3_FILFAT = '" + aChaveFt[1] + "' " 
			 	cQuery += " AND TAB.GW3_EMIFAT = '" + aChaveFt[2] + "' " 
			 	cQuery += " AND TAB.GW3_SERFAT = '" + aChaveFt[3] + "' "
			 	cQuery += " AND TAB.GW3_NRFAT  = '" + aChaveFt[4] + "' " 
			 	cQuery += " AND TAB.GW3_DTEMFA = '" + aChaveFt[5] + "' "
			 EndIf
			 
			 If cParte != ""
				cQuery += " AND TAB.GW3_NRDF > '" + cParte + "' "
			EndIf
	EndCase

	cQuery += " ) "
	
	cQuery := ChangeQuery(cQuery)
	
	cTmp   := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

	If (cTmp)->(Eof())
		(cTmp)->(dbCloseArea())
		Return "#NRD#" // Nenhum registro disponivel
	EndIf
 
	Do Case
		// Documentos de frete da Fatura de Frete integrando com o Financeiro
		Case cTabela == "GW3" .And. cCodInt != "6"
			
			cQuery := " SELECT"
			If cBcoDados != 'POSTGRES' .AND. cBcoDados != 'ORACLE'
				cQuery += " TOP 200 "
			ElseIf cBcoDados == 'ORACLE'
				cQuery += " * FROM (SELECT"
			EndIf	

			cQuery +=        " GW3.GW3_NRDF	 ," 
			cQuery +=        " GW3.GW3_FILIAL,"
			cQuery +=        " GW3.GW3_CDESP ,"
			cQuery +=        " GW3.GW3_EMISDF,"
			cQuery +=        " GW3.GW3_SERDF ,"
			cQuery +=        " GW3.GW3_DTEMIS "
			cQuery +=   " FROM "+RetSqlName("GW3")+" GW3" 
			cQuery +=  " WHERE GW3.GW3_FILFAT = '" + PADR(Rtrim((cTmp)->GW3_FILFAT) , TamSX3("GW3_FILFAT" )[1]	,'') + "'"  
			cQuery +=    " AND GW3.GW3_EMIFAT = '" + PADR(Rtrim((cTmp)->GW3_EMIFAT) , TamSX3("GW3_EMIFAT" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_SERFAT = '" + PADR(Rtrim((cTmp)->GW3_SERFAT) , TamSX3("GW3_SERFAT" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_NRFAT  = '" + PADR(Rtrim((cTmp)->GW3_NRFAT)  , TamSX3("GW3_NRFAT" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_DTEMFA = '" + PADR(Rtrim((cTmp)->GW3_DTEMFA) , TamSX3("GW3_DTEMFA" )[1]	,'') + "'"
			If cParte != ""
				cQuery += " AND GW3.GW3_NRDF > '" + cParte + "' "
			EndIf
			cQuery +=    " AND GW3.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GW3.GW3_NRDF"		

			If cBcoDados == 'POSTGRES'
				cQuery += " LIMIT 200"
			ElseIf cBcoDados == 'ORACLE'
				cQuery += " ) WHERE ROWNUM < 200"
			EndIf

			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .F. )

			Do While (cAliasQry)->(!Eof())
				cString += "#GW3|" + 	AllTrim((cAliasQry)->GW3_FILIAL) + "|" + ;
			 							AllTrim((cAliasQry)->GW3_CDESP)  + "|" + ;
			 							AllTrim((cAliasQry)->GW3_EMISDF) + "|" + ;
			 							AllTrim((cAliasQry)->GW3_SERDF)  + "|" + ;
			 							AllTrim((cAliasQry)->GW3_NRDF)   + "|" + ;
			 							(cAliasQry)->GW3_DTEMIS
			
				cUltReg := AllTrim((cAliasQry)->GW3_NRDF)
				
				(cAliasQry)->(dbSkip())
			EndDo
			
			(cAliasQry)->(dbCloseArea())
						
			cQuery := " SELECT"
			If cBcoDados != 'POSTGRES' .AND. cBcoDados != 'ORACLE'
				cQuery += " TOP 1"
			ElseIf cBcoDados == 'ORACLE'
				cQuery += " * FROM (SELECT"
			EndIf		

			cQuery += " GW3.GW3_NRDF"
			cQuery +=   " FROM " + RetSqlName("GW3") + " GW3"
			cQuery +=  " WHERE GW3.GW3_FILFAT = '" + PADR(Rtrim((cTmp)->GW3_FILFAT) , TamSX3("GW3_FILFAT" )[1]	,'') + "'"  
			cQuery +=    " AND GW3.GW3_EMIFAT = '" + PADR(Rtrim((cTmp)->GW3_EMIFAT) , TamSX3("GW3_EMIFAT" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_SERFAT = '" + PADR(Rtrim((cTmp)->GW3_SERFAT) , TamSX3("GW3_SERFAT" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_NRFAT  = '" + PADR(Rtrim((cTmp)->GW3_NRFAT)  , TamSX3("GW3_NRFAT" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_DTEMFA = '" + PADR(Rtrim((cTmp)->GW3_DTEMFA) , TamSX3("GW3_DTEMFA" )[1]	,'') + "'"
			cQuery +=    " AND GW3.GW3_NRDF > '" + cUltReg + "' "
			cQuery +=    " AND GW3.D_E_L_E_T_ = ' '"
			cQuery +=    " ORDER BY GW3.GW3_NRDF "
			
			If cBcoDados == 'POSTGRES'
				cQuery += " LIMIT 1"
			ElseIf cBcoDados == 'ORACLE'
				cQuery += " ) WHERE ROWNUM < 1"
			EndIf

			cQuery := ChangeQuery(cQuery)
			cAliasAux := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasAux, .T., .F. )
			
			If (cAliasAux)->(!EoF())
				cString += "$" + cUltReg + "$"
			EndIf
			
			(cAliasAux)->(dbCloseArea())
	EndCase

	(cTmp)->(dbCloseArea())

Return cString

// Função responsável por alterar a situação do documento quando retornado da integração Datasul
Function GFEWSSETDATA(cTabela,cCodInt,aDados)
	Local cMV_GFEI13	:= ""
	Local cMV_GFEI14	:= ""
	Local cMV_DSDTRE	:= ""
	Local cMV_DSOFDT	:= ""
	Local cNrPF 	   	:= ""
	Local nQtdFil	   	:= 0
	Local nLenDados		:= 0
	Local aAreaAnt		:= {}
	Local cFilBkp 		:= ""
	Local cIntegRH   	:= SuperGetMV('MV_GFEI19',,'1')
	Local cNrNeg		:= ""
	Local cMsgMotAprov  := "Documento de Frete aprovado no módulo MLA Datasul." // Mensagem padrão para quando o Motivo da Aprovação não for informado no Datasul.
	Local cMV_DSCTB 	:= SuperGetMv('MV_DSCTB',, '1')

	// Variável private criada para que não ocorra erro ao chamar a função GFEA066OK
	Private cSitTab 	:= SuperGetMV("MV_GFEDCFA", .F., "2")   
	
	cMV_GFEI13 := SuperGetMV('MV_GFEI13',,'1')
	cMV_GFEI14 := SuperGetMV('MV_GFEI14',,'1')
	cMV_DSDTRE := SuperGetMV('MV_DSDTRE',,'1')
	cMV_DSOFDT := SuperGetMV("MV_DSOFDT",,"1")

	// Início Ponto de Entrada Procomp
	If ExistBlock("GFEXWS09")
		ExecBlock("GFEXWS09",.f.,.f.,{cTabela,aDados,cCodInt})
	EndIf
	// Fim Ponto de Entrada Procomp
	
	Do Case
		// Documento de Carga
		Case cTabela == "GW1"
			dbSelectArea("GW1")
			dbSetOrder(1)
			If DbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW1_FILIAL" )[1]	,'') +;
					PADR(Rtrim(aDados[2]) , TamSX3("GW1_CDTPDC" )[1]	,'') +;
					PADR(Rtrim(aDados[3]) , TamSX3("GW1_EMISDC" )[1]	,'') +;
					PADR(Rtrim(aDados[4]) , TamSX3("GW1_SERDC"  )[1]	,'') +;
					PADR(Rtrim(aDados[5]) , TamSX3("GW1_NRDC"   )[1]	,'') )
								
				If cCodInt == "5" .AND. GfeVerCmpo({"GW1_SITFT"})
					RecLock("GW1",.F.)
					GW1->GW1_SITFT := aDados[6]
					GW1->GW1_MOTFT := aDados[7]
					MsUnlock()
				EndIf
	
				// SAMSUNG
				If cCodInt == "6" .AND. GfeVerCmpo({"GW1_SITFT2"})
					RecLock("GW1",.F.)
					GW1->GW1_SITFT2 := aDados[6]
					GW1->GW1_MOTFT2 := aDados[7]
					MsUnlock()
				EndIf	
				
				If cCodInt == "7" .And. GFXCP12117("GW1_SITFRE") == .T. .And. GFXCP12117("GW1_MOTFRE") == .T.
					RecLock("GW1",.F.)
					GW1->GW1_SITFRE := aDados[6]
					GW1->GW1_MOTFRE := aDados[7]
					MsUnlock()
				EndIf
			EndIf
		// Documento de Frete		
		Case cTabela == "GW3"
			If Len(aDados) > 6
				dbSelectArea("GW3")
				dbSetOrder(1)
				If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW3_FILIAL" )[1]	,'') +;
							PADR(Rtrim(aDados[8]) , TamSX3("GW3_CDESP"  )[1] ,'') +;
							PADR(Rtrim(aDados[2]) , TamSX3("GW3_EMISDF" )[1]	,'') +;
							PADR(Rtrim(aDados[3]) , TamSX3("GW3_SERDF"  )[1] ,'') +;
							PADR(Rtrim(aDados[4]) , TamSX3("GW3_NRDF"   )[1] ,'') +;
							PADR(Rtrim(aDados[7]) , TamSX3("GW3_DTEMIS" )[1] ,''))
					If cCodInt == '1' // Fiscal
						RecLock("GW3",.F.)
							GW3->GW3_SITFIS := aDados[5]
							GW3->GW3_MOTFIS := aDados[6]
							If aDados[5] == "1"
								GW3->GW3_DTFIS  := StoD("        ")
							EndIf
						MsUnlock()
					ElseIf cCodInt == '3'  // Recebimento
						RecLock("GW3",.F.)
							GW3->GW3_SITREC := aDados[5]
							GW3->GW3_MOTREC := aDados[6]
							If aDados[5] == "1"
								GW3->GW3_DTREC  := StoD("        ")
							EndIf
						MsUnlock()
					ElseIf cCodInt == "6" // Documento de Frete MLA
						RecLock("GW3",.F.)
							GW3->GW3_SITMLA := aDados[5] // Situação da integração
							GW3->GW3_MOTMLA := aDados[6] // Motivo aprovação rejeição
						GW3->(MsUnlock())
												
						nLenDados := Len(aDados)
						If AllTrim(aDados[5]) == "4" 
						   IF GW3->GW3_SIT == "2" // Situação MLA = atualizado e situação documento de frete = bloqueado
						       						       								
								If GW3->GW3_SITFIS != "4" //Se o documento já integrou com o fiscal não deve passar novamente pela auditoria
									// Executa o processo de aprovação (auditoria) de documentos de fretes
									
									cFilBkp := cFilAnt			// cFilAnt = Variavel Publica, Utilizado na consulta xFilial("G...")
									cFilAnt := GW3->GW3_FILIAL
										
									GFEA066OK(.T.,; //lMotivo
											IIf(nLenDados >= 09,CtoD(aDados[09]),Date()),; // dtAprov
											IIf(nLenDados >= 10,aDados[10],Time()),; // cHrAprov
											IIf(nLenDados >= 11,aDados[11],IIf(GFXCP12117("GW3_USUCRI") == .T.,GW3->GW3_USUCRI,"")),; // cUsrAprov
											IIf(nLenDados >= 12,aDados[12],cMsgMotAprov))  // cMotAprov
											
									cFilAnt := cFilBkp							    
							    Else // Aprova o documento de frete sem passar pela rotina de auditoria							       
							       RecLock("GW3",.F.)
							           GW3->GW3_SIT := "4" //Aprovado Usuário
										GW3->GW3_MOTAPR := IIf(nLenDados >= 12,aDados[12],"")
										GW3->GW3_USUAPR := IIf(nLenDados >= 11,aDados[11],IIf(GW3->(FieldPos("GW3_USUCRI")) > 0,GW3->GW3_USUCRI,""))
										GW3->GW3_DTAPR  := IIf(nLenDados >= 09,CtoD(aDados[09]),Date())
										GW3->GW3_HRAPR  := IIf(nLenDados >= 10,aDados[10],Time())
								   GW3->(MsUnlock())
							    							    
						       EndIf
					       Else // Aprovado via MLA e situação do documento de frete já Aprovado (sistema ou usuário)  
								RecLock("GW3",.F.)
									GW3->GW3_MOTAPR := IIf(nLenDados >= 12,aDados[12],"")
									GW3->GW3_USUAPR := IIf(nLenDados >= 11,aDados[11],IIf(GW3->(FieldPos("GW3_USUCRI")) > 0,GW3->GW3_USUCRI,""))
									GW3->GW3_DTAPR  := IIf(nLenDados >= 09,CtoD(aDados[09]),Date())
									GW3->GW3_HRAPR  := IIf(nLenDados >= 10,aDados[10],Time())
								GW3->(MsUnlock())
						    EndIf
						Else 
							RecLock("GW3",.F.)
								GW3->GW3_DTAPR  := IIf(nLenDados >= 09,CtoD(aDados[09]),CToD("  /  /    "))
								GW3->GW3_HRAPR  := IIf(nLenDados >= 10,aDados[10],"")
								GW3->GW3_USUAPR := IIf(nLenDados >= 11,aDados[11],"")
								GW3->GW3_MOTMLA := IIf(nLenDados >= 12,aDados[12],"")
							GW3->(MsUnlock())
						EndIf						
					EndIf
				EndIf
			Else
				dbSelectArea("GW3")
				dbSetOrder(10)
				If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW3_FILIAL" )[1],'') +;
							PADR(Rtrim(aDados[2]) , TamSX3("GW3_EMISDF" )[1]	,'') + ;
							PADR(Rtrim(aDados[3]) , TamSX3("GW3_SERDF" )[1] 	,'') + ;
							PADR(Rtrim(aDados[4]) , TamSX3("GW3_NRDF" )[1] 	,'') )
					If cCodInt == '1' // Fiscal
						RecLock("GW3",.F.)
							GW3->GW3_SITFIS := aDados[5]
							GW3->GW3_MOTFIS := aDados[6]
							If aDados[5] == "1"
								GW3->GW3_DTFIS  := StoD("        ")
							EndIf
						MsUnlock()
					ElseIf cCodInt == '3' // Recebimento
						RecLock("GW3",.F.)
							GW3->GW3_SITREC := aDados[5]
							GW3->GW3_MOTREC := aDados[6]
							If aDados[5] == "1"
								GW3->GW3_DTREC  := StoD("        ")
							EndIf
						MsUnlock()
					EndIf
				EndIf
			EndIf
		// Fatura de Frete		
		Case cTabela == "GW6"
			If Len(aDados) > 6
				dbSelectArea("GW6")
				dbSetOrder(1)
				If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1]	,'') + ;
							PADR(Rtrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') + ;
							PADR(Rtrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') + ;
							PADR(Rtrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') + ;
							PADR(Rtrim(aDados[7]) , TamSX3("GW6_DTEMIS")[1]  ,'') )
					If cCodInt == '2' // Financeiro
						// Início Ponto de Entrada Britania
						If ExistBlock("XGFEWGW6")
							aRotAdic := ExecBlock("XGFEWGW6",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS, aDados[5]})
						EndIf
						// Fim Ponto de Entrada Britania

						If cMV_DSCTB == "1"
							GFESitCtb(1, GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS, aDados[5])
						EndIf
	
						RecLock("GW6",.F.)
							GW6->GW6_SITFIN := aDados[5]
							GW6->GW6_MOTFIN := aDados[6]
							If aDados[5] == "1"
								GW6->GW6_DTFIN  := StoD("        ")
								GW6->GW6_HRFIN  := "     "
								GW6->GW6_USUFIN := " "
							EndIf
						MsUnlock()

						// Chamado TTLANW
						If aDados[5] == "4"
							aAreaGW3 := GetArea()
							
							If (cMV_GFEI13 == "2" .And. cMV_DSOFDT == "2") .Or.  (cMV_GFEI14 == "2" .And. cMV_DSDTRE == "4") //Fiscal Automático ou Recebimento Automático
								dbSelectArea("GW3")
								dbSetOrder(8)
								If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1]	,'') + ;
											PADR(Rtrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') + ;
											PADR(Rtrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') + ;
											PADR(Rtrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') + ;
											PADR(Rtrim(aDados[7]) , TamSX3("GW6_DTEMIS")[1]  ,'') )
									While  PADR(Rtrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1]	,'') == GW3->GW3_FILFAT .AND. ;
											PADR(Rtrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') == GW3->GW3_EMIFAT .AND. ;
											PADR(Rtrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') == GW3->GW3_SERFAT .AND. ;
											PADR(Rtrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') == GW3->GW3_NRFAT .AND. ;
											PADR(Rtrim(aDados[7]) , TamSX3("GW6_DTEMIS")[1]	,'') == DTOS(GW3->GW3_DTEMFA)
										
										If cMV_GFEI13 == "2" .And. cMV_DSOFDT == "2"
											If GW3->GW3_SITFIS $ "1;3"
												RecLock("GW3",.F.)
													GW3->GW3_SITFIS := "2"
													GW3->GW3_DTFIS  := GW6->GW6_DTFIN
												MsUnlock()
											EndIf
										EndIf
										
										If cMV_GFEI14 == "2" .And. cMV_DSDTRE == "4"
											If GW3->GW3_SITREC $ "1;3"
												RecLock("GW3",.F.)
													GW3->GW3_SITREC := "2"
													GW3->GW3_DTREC  := GW6->GW6_DTFIN
												MsUnlock()
											EndIf
										EndIf
										
										GW3->( dbSkip() )
									EndDo
								EndIf
							EndIf
						
							RestArea(aAreaGW3)
						EndIf
					ElseIf cCodInt == '6' // MLA
						RecLock("GW6",.F.)
						GW6->GW6_SITMLA := aDados[5] // Situação da integração
						GW6->GW6_MOTMLA := aDados[6] // Motivo aprovação rejeição
						GW6->(MsUnlock())
						nLenDados := Len(aDados)
						If AllTrim(aDados[5]) == "4" // Situação atualizado
							aAreaAnt := GetArea()
							
							// Executar o processo de aprovação (auditoria) da fatura apenas
							// se não estiver parametrizado para 4 - Liberação de Pagamento
							If BuscaParam("MV_FTMLA",GW6->GW6_FILIAL,"1") != "4"
								GFEA071OK(IIf(nLenDados >= 11,aDados[11],""),; //cMemo
								          IIf(nLenDados >= 08,CtoD(aDados[08]),CToD("  /  /    ")),; //dDataAprov
								          IIf(nLenDados >= 09,aDados[09],""),; //cHRAprov
								          IIf(nLenDados >= 10,aDados[10],"")) //cUserAprov
							EndIf
							
							// Atualização automática da fatura com o Financeiro
							If BuscaParam('MV_GFEI16',GW6->GW6_FILIAL,'1') == '2'
								GFEA070X(.T.)
							EndIf
						
							RestArea(aAreaAnt)
						Else
							RecLock("GW6",.F.)
							GW6->GW6_DTAPR  := IIf(nLenDados >= 08,CtoD(aDados[08]),CToD("  /  /    "))
							GW6->GW6_HRAPR  := IIf(nLenDados >= 09,aDados[09],"")
							GW6->GW6_USUAPR := IIf(nLenDados >= 10,aDados[10],"")
							GW6->GW6_MOTMLA := IIf(nLenDados >= 11,aDados[11],"")
							If Empty(GW6->GW6_MOTMLA)
								GW6->GW6_MOTMLA := aDados[6]
							EndIf
							GW6->(MsUnlock())
						EndIf
					EndIf
				EndIf
			Else
				dbSelectArea("GW6")
				dbSetOrder(1)
				If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1],'') +;
							PADR(Rtrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') + ;
							PADR(Rtrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') + ;
							PADR(Rtrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') )
					
					If cCodInt == '2' // Financeiro
						// Início Ponto de Entrada Britania
						If ExistBlock("XGFEWGW6")
							aRotAdic := ExecBlock("XGFEWGW6",.f.,.f.,{GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS, aDados[5]})
						EndIf
						// Fim Ponto de Entrada Britania
	
						If cMV_DSCTB == "1"
							GFESitCtb(1, GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS, aDados[5])
						EndIf

						RecLock("GW6",.F.)
							GW6->GW6_SITFIN := aDados[5]
							GW6->GW6_MOTFIN := aDados[6]
							If aDados[5] == "1"
								GW6->GW6_DTFIN  := StoD("        ")
								GW6->GW6_HRFIN  := "     "
								GW6->GW6_USUFIN := " "
							EndIf
						MsUnlock()
						
						// Chamado TTLANW
						If aDados[5] == "4"
							aAreaGW3 := GetArea()
						
							If (cMV_GFEI13 == "2" .And. cMV_DSOFDT == "2") .Or.  (cMV_GFEI14 == "2" .And. cMV_DSDTRE == "4") //Fiscal Automático ou Recebimento Automático
								
								dbSelectArea("GW3")
								dbSetOrder(8)
								If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1]	,'') + ;
											PADR(Rtrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') + ;
											PADR(Rtrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') + ;
											PADR(Rtrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') )
									While  PADR(Rtrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1]	,'') == GW3->GW3_FILFAT .AND. ;
											PADR(Rtrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') == GW3->GW3_EMIFAT .AND. ;
											PADR(Rtrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') == GW3->GW3_SERFAT .AND. ;
											PADR(Rtrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') == GW3->GW3_NRFAT
										
										If cMV_GFEI13 == "2" .And. cMV_DSOFDT == "2"
											If GW3->GW3_SITFIS $ "1;3"
												RecLock("GW3",.F.)
													GW3->GW3_SITFIS := "2"
													GW3->GW3_DTFIS  := GW6->GW6_DTFIN
												MsUnlock()
											EndIf
										EndIf
										
										If cMV_GFEI14 == "2" .And. cMV_DSDTRE == "4"
											If GW3->GW3_SITREC $ "1;3"
												RecLock("GW3",.F.)
													GW3->GW3_SITREC := "2"
													GW3->GW3_DTREC  := GW6->GW6_DTFIN
												MsUnlock()
											EndIf
										EndIf
										
										GW3->( dbSkip() )
									EndDo
								EndIf
							EndIf
						
							RestArea(aAreaGW3)
						EndIf
					EndIf
				EndIf
			EndIf
		// Contrato com Autônomo
		Case cTabela == "GW2"
			dbSelectArea("GW2")
			dbSetOrder(1)
			If dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GW2_FILIAL" )[1],'') +;
						PADR(Rtrim(aDados[2]) , TamSX3("GW2_NRCONT" )[1],'') )
				If cCodInt == '2' // Financeiro
					RecLock("GW2",.F.)
						GW2->GW2_SITFIN := aDados[3]
						GW2->GW2_MOTFIN := aDados[4]
						If aDados[3] == "1"
							GW2->GW2_DTFIN  := StoD("        ")
							GW2->GW2_HRFIN  := "     "
							GW2->GW2_USUFIN := " "
						EndIf
					MsUnlock()

					// Envia o contrato automaticamente para o RH caso o sistema esteja parametrizado para isso.
					// Pré-requisito: o contrato precisa antes ser integrado com o financeiro.
					If cIntegRH == "2" .AND. GW2->GW2_SITFIN == "4" .AND. GW2->GW2_SITRH $ "1;3"
						RecLock("GW2",.F.)
						GW2->GW2_SITRH := '2'		// Pendente
						GW2->GW2_MOTRH := ''
						GW2->GW2_DTRH  := Date()
						GW2->GW2_HRRH  := SubStr(Time(), 1, 5)
						GW2->GW2_USURH := GW2->GW2_USUFIN
						MsUnlock()
					EndIf             					
				ElseIf cCodInt == '3' // Recebimento
					RecLock("GW2",.F.)
						GW2->GW2_SITREC := aDados[3]
						GW2->GW2_MOTREC := aDados[4]
						If aDados[3] == "1"
							GW2->GW2_DTREC  := StoD("        ")
							GW2->GW2_HRREC  := "     "
							GW2->GW2_USUREC := " "
						EndIf
					MsUnlock()
				ElseIf cCodInt == '4' // RH (HCM Datasul)
					RecLock("GW2",.F.)
						GW2->GW2_SITRH := aDados[3]
						GW2->GW2_MOTRH := aDados[4]
						If aDados[3] == "1"
							GW2->GW2_DTRH  := StoD("        ")
							GW2->GW2_HRRH	 := "     "
							GW2->GW2_USURH := " "
						EndIf
					MsUnlock()
				EndIf
			EndIf
		// Pré-fatura/Lote Provisão integrando com o Financeiro
		Case cTabela == "GWJ" .And. cCodInt == '2'
			nQtdFil := Len(xFilial("GWJ"))
			
			If SuperGetMv("MV_NRPF", .F., "1") == "2"
				cNrPF := Substr(Rtrim(aDados[2]),nQtdFil + 1)
			Else
				cNrPF := Rtrim(aDados[2])
			EndIf
			
			dbSelectArea("GWJ")
			dbSetOrder(1)
			If dbSeek(	 PADR(Rtrim(aDados[1]) , TamSX3("GWJ_FILIAL" )[1]	,'') +;
					PADR(cNrPF , TamSX3("GWJ_NRPF" )[1]	,'') )
	
				RecLock("GWJ",.F.)
					GWJ->GWJ_SITFIN := aDados[3]
					GWJ->GWJ_MOTFIN := aDados[4]
					If aDados[3] == "1"
						GWJ->GWJ_DTFIN  := StoD("        ")
					EndIf
				MsUnlock()
			ElseIf TemTabProv() // Procurar por um lote de provisão contábil caso não encontrar préfatura
				dbSelectArea("GXE")
				GXE->(dbSetOrder(1))
				If GXE-> (dbSeek(	PADR(Rtrim(aDados[1]) , TamSX3("GXE_FILIAL" )[1]	,'') +;
							PADR(Rtrim(aDados[2]) , TamSX3("GXE_CODLOT" )[1]	,'') ) )
					
					RecLock("GXE",.F.)
						If GXE->GXE_SIT == "5" .And. AllTrim(aDados[3]) == "1" // Estorno Ok
							GXE->GXE_SIT	:= "6"
						Else
							GXE->GXE_SIT	:= aDados[3]
						EndIf
					GXE->GXE_MOTIVO	:= aDados[4]
					MsUnlock("GXE")
				
				EndIf
			EndIf
		
		cNrPF := ""
		// Negociação da Tabela de Frete integrando com o MLA
		Case cTabela == "GV9"

			cNrNeg := Rtrim(aDados[04])
			cNrTab := Rtrim(aDados[03])

			While Len(cNrtab) <= TamSX3("GV9_NRTAB")[1] 

				dbSelectArea("GV9")
				GV9->(dbSetOrder(1)) // GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG
				If GV9->(dbSeek( PadR(Rtrim(RetFilTab("GV9",aDados[01])),TamSx3("GV9_FILIAL")[1],"")+;
								PadR(Rtrim(aDados[02]),TamSx3("GV9_CDEMIT")[1],"")+;
								PadR(cNrtab,TamSx3("GV9_NRTAB" )[1],"")+;
								PadR(cNrNeg,TamSx3("GV9_NRNEG" )[1],"") ))
					
					nLenDados := Len(aDados)
					
					If cCodInt == '6'
						RecLock("GV9",.F.)
						If AllTrim(aDados[05]) == "4" // Atualizado
							GV9->GV9_SIT := "2" // Liberada
						ElseIf AllTrim(aDados[05]) == "3" // Rejeitado
							GV9->GV9_SIT    := "1" // Em negociacao
							GV9->GV9_ENVAPR := "2" // Não
						ElseIf AllTrim(aDados[05]) == "1" // Não Enviado (Utilizado quando deleta no MLA)
							GV9->GV9_SIT    := "1" // Em negociacao
							GV9->GV9_ENVAPR := "2" // Não
						EndIf
						GV9->GV9_SITMLA := aDados[05] // Situação MLA
						GV9->GV9_MOTMLA := IIf(nLenDados >= 06,aDados[06],"") // Motivo MLA
						GV9->GV9_DTAPR  := IIf(nLenDados >= 07,CtoD(aDados[07]),CToD("  /  /    ")) // Data Aprovação
						GV9->GV9_HRAPR  := IIf(nLenDados >= 08,aDados[08],"") // Hora Aprovação
						GV9->GV9_USUAPR := IIf(nLenDados >= 09,aDados[09],"") // Usuário Aprovação
						GV9->GV9_MTVRPR := IIf(nLenDados >= 10,aDados[10],"") // Motivo Reprovação
						MsUnlock("GV9")
					ElseIf cCodInt == '7' .And. GFXCP12117("GV9_SITCON") == .T. .And. GFXCP12117("GV9_MOTCON") == .T. .And. GFXCP12117("GV9_DTCON") == .T.
						RecLock("GV9",.F.)
						GV9->GV9_SITCON := aDados[05]
						GV9->GV9_MOTCON := aDados[06]
						GV9->GV9_DTCON  := Date()
						MsUnlock("GV9")
					EndIf
				
					Exit

				EndIf

				cNrTab := PADL(cNrTab, Len(cNrTab) + 1)				
			EndDo					

			While Len(cNrNeg) <= TamSX3("GV9_NRNEG")[1] 

				dbSelectArea("GV9")
				GV9->(dbSetOrder(1)) // GV9_FILIAL+GV9_CDEMIT+GV9_NRTAB+GV9_NRNEG
				If GV9->(dbSeek( PadR(Rtrim(RetFilTab("GV9",aDados[01])),TamSx3("GV9_FILIAL")[1],"")+;
								PadR(Rtrim(aDados[02]),TamSx3("GV9_CDEMIT")[1],"")+;
								PadR(Rtrim(aDados[03]),TamSx3("GV9_NRTAB" )[1],"")+;
								PadR(cNrNeg,TamSx3("GV9_NRNEG" )[1],"") ))
					
					nLenDados := Len(aDados)
					
					If cCodInt == '6'
						RecLock("GV9",.F.)
						If AllTrim(aDados[05]) == "4" // Atualizado
							GV9->GV9_SIT := "2" // Liberada
						ElseIf AllTrim(aDados[05]) == "3" // Rejeitado
							GV9->GV9_SIT    := "1" // Em negociacao
							GV9->GV9_ENVAPR := "2" // Não
						ElseIf AllTrim(aDados[05]) == "1" // Não Enviado (Utilizado quando deleta no MLA)
							GV9->GV9_SIT    := "1" // Em negociacao
							GV9->GV9_ENVAPR := "2" // Não
						EndIf
						GV9->GV9_SITMLA := aDados[05] // Situação MLA
						GV9->GV9_MOTMLA := IIf(nLenDados >= 06,aDados[06],"") // Motivo MLA
						GV9->GV9_DTAPR  := IIf(nLenDados >= 07,CtoD(aDados[07]),CToD("  /  /    ")) // Data Aprovação
						GV9->GV9_HRAPR  := IIf(nLenDados >= 08,aDados[08],"") // Hora Aprovação
						GV9->GV9_USUAPR := IIf(nLenDados >= 09,aDados[09],"") // Usuário Aprovação
						GV9->GV9_MTVRPR := IIf(nLenDados >= 10,aDados[10],"") // Motivo Reprovação
						MsUnlock("GV9")
					ElseIf cCodInt == '7' .And. GFXCP12117("GV9_SITCON") == .T. .And. GFXCP12117("GV9_MOTCON") == .T. .And. GFXCP12117("GV9_DTCON") == .T.
						RecLock("GV9",.F.)
						GV9->GV9_SITCON := aDados[05]
						GV9->GV9_MOTCON := aDados[06]
						GV9->GV9_DTCON  := Date()
						MsUnlock("GV9")
					EndIf
				
					Exit
				EndIf

				cNrNeg := PADL(cNrNeg, Len(cNrNeg) + 1)				
			EndDo
		Case cTabela == "GXN" .And. cCodInt == '2' .And. GFXTB12117("GXN") == .T.
		
			//Altera Status dos Sublotes Contábeis Situação alterada para 2-Pendente
			dbSelectArea( "GXN" )
			dbSetOrder( 01 )
			If GXN->(dbSeek( PADR(Rtrim(aDados[1]),TamSX3("GXN_FILIAL" )[1]	,'') + PADR(Rtrim(aDados[2]),TamSX3("GXN_CODLOT" )[1],'') + PADR(Rtrim(aDados[3]),TamSX3("GXN_CODEST" )[1],'')))
				RecLock( "GXN", .F. )
				GXN->GXN_SIT := aDados[4] //Altera status para Rejeitado, Atualizado ou Não enviado.
				MsUnLock( "GXN" )
			EndIf
			
			dbSelectArea( "GXE" )
			GXE->( dbSetOrder(1) )
			cSituacao := ""
			If GXE->(dbSeek( PADR(Rtrim(aDados[1]),TamSX3("GXE_FILIAL" )[1]	,'') + PADR(Rtrim(aDados[2]),TamSX3("GXE_CODLOT" )[1],'')))
				
				If aDados[4] == "1" .Or. aDados[4] == "3"
					
					cAliasQry := GetNextAlias()
					cQuery := " SELECT GXN_CODLOT FROM " + RetSQLName( "GXN" )
					cQuery += " WHERE GXN_FILIAL = '" + GXN->GXN_FILIAL + "' AND GXN_CODLOT = '" + GXN->GXN_CODLOT + "' AND "
					cQuery += " GXN_CODEST != '" + GXN->GXN_CODEST + "' AND GXN_SIT = '4' AND D_E_L_E_T_ = ' '"
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
					If (cAliasQry)->(!Eof())
						cSituacao := "8" //Estornado Parcial
					Else
						cSituacao := "4" //Atualizado
					EndIf
					
				Else
					dbSelectArea( "GXN" ) 
					GXN->(dbSetOrder(1))
					If dbSeek( GXE->GXE_FILIAL + GXE->GXE_CODLOT )
						While GXN->(!Eof()) .AND. GXN->GXN_FILIAL == GXE->GXE_FILIAL .And. GXN->GXN_CODLOT == GXE->GXE_CODLOT
		
							If GXN->GXN_SIT == '4' //Se o sublote estiver atualizado
								dbSelectArea( "GXD" )
								GXD->(dbSetOrder( 03 ))
								If GXD->(dbSeek( GXN->GXN_FILIAL + GXN->GXN_CODLOT + Space(Len(GXN->GXN_CODEST))))
									cSituacao := "8" //Pelo menos uma GXD possui GXD_CODEST vazio, gxe_sit é 8
									Exit
								Else
									cSituacao := "6" //Todas as gxd possui GXD_CODEST preenchido, gxe_sit é 6
								EndIf
							EndIf
							
							GXN->(dbSkip())
						EndDo
					EndIf
				ENDIF
				
				If !Empty( cSituacao )
					//Atualiza a situação do lote.
					dbSelectArea( "GXE" )
					RecLock( "GXE",.F. )
					GXE->GXE_SIT    := cSituacao
					GXE->GXE_MOTIVO := aDados[5]
					MsUnlock( "GXE" )
				EndIf				
			EndIf		
	Endcase

Return "TRUE"

// Função responsavel por restaurar a situação de um registro já integrado ao seu estado inicial, ou seja "não integrado"
Function GFEWSUndo(cTabela,cCodInt,aDados)
	Local cMV_DSCTB 	:= SuperGetMv('MV_DSCTB',, '1')

	Do Case
		Case cCodInt == '1' // Fiscal
			dbSelectArea("GW3")
			dbSetOrder(10)
			If dbSeek(	 PADR(Alltrim(aDados[1]) , TamSX3("GW3_FILIAL" )[1]	,'') +;
					PADR(Alltrim(aDados[2]) , TamSX3("GW3_EMISDF" )[1]	,'') + ;
					PADR(Alltrim(aDados[3]) , TamSX3("GW3_SERDF" )[1] 	,'') + ;
					PADR(Alltrim(aDados[4]) , TamSX3("GW3_NRDF" )[1] 	,'') )
	
				RecLock("GW3",.F.)
					GW3->GW3_SITFIS := "1"
					GW3->GW3_MOTFIS := ""
					GW3->GW3_DTFIS  := StoD("        ")
				MsUnlock()	
			EndIf
		Case cCodInt == '2' // Financeiro
	
			If cTabela == "GW6" // Fatura de Frete
				dbSelectArea("GW6")
				dbSetOrder(1)
	
				If dbSeek(	 PADR(Alltrim(aDados[1]) , TamSX3("GW6_FILIAL" )[1]	,'') +;
						PADR(Alltrim(aDados[2]) , TamSX3("GW6_EMIFAT" )[1]	,'') + ;
						PADR(Alltrim(aDados[3]) , TamSX3("GW6_SERFAT" )[1]	,'') + ;
						PADR(Alltrim(aDados[4]) , TamSX3("GW6_NRFAT" )[1] 	,'') )
	
					If cMV_DSCTB == "1"
						GFESitCtb(1, GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT, GW6->GW6_DTEMIS, "1")	
					EndIf

					RecLock("GW6",.F.)
						GW6->GW6_SITFIN := "1"
						GW6->GW6_MOTFIN := ""
						GW6->GW6_DTFIN  := StoD("        ")
					MsUnlock()
				EndIf	
			ElseIf cTabela == "GW2" // Contrato com Autônomo
				dbSelectArea("GW2")
				dbSetOrder(1)
				If dbSeek(	 PADR(Alltrim(aDados[1]) , TamSX3("GW2_FILIAL" )[1]	,'') +;
						PADR(Alltrim(aDados[2]) , TamSX3("GW2_NRCONT" )[1]	,'') )
					RecLock("GW2",.F.)
						GW2->GW2_SITFIN 	:= "1"
						GW2->GW2_MOTFIN 	:= ""
						GW2->GW2_DTFIN	:= StoD("        ")
					MsUnlock()
				Endif
			ElseIf cTabela == "GWJ" // Pré-fatura/Lote de Provisão
				dbSelectArea("GWJ")
				dbSetOrder(1)
				If dbSeek(	 PADR(Alltrim(aDados[1]) , TamSX3("GWJ_FILIAL" )[1]	,'') +;
						PADR(Alltrim(aDados[2]) , TamSX3("GWJ_NRPF" )[1]	,'') )
					RecLock("GWJ",.F.)
						GWJ->GWJ_SITFIN := "1"
						GWJ->GWJ_MOTFIN := ""
						GWJ->GWJ_DTFIN  := StoD("        ")
					MsUnlock()
				ElseIf TemTabProv()
					dbSelectArea("GXE")
					GXE->(dbSetOrder(1))
					If GXE-> (dbSeek(	PADR(Alltrim(aDados[1]) , TamSX3("GXE_FILIAL" )[1]	,'') +;
							PADR(Alltrim(aDados[2]) , TamSX3("GXE_CODLOT" )[1]	,'') ) )
						
						RecLock("GXE",.F.)
							If GXE->GXE_SIT == "5" // Estorno Ok
								GXE->GXE_SIT	:= "6"
							Else
								GXE->GXE_SIT	:= "1"
							EndIf
							GXE->GXE_MOTIVO	:= ""
							GXE->GXE_DTSIT	:= StoD("        ")
						MsUnlock("GXE")
					EndIf
				EndIf
			EndIf
		Case cCodInt == '3' // Recebimento
			If cTabela == "GW3" // Documento de Frete
				dbSelectArea("GW3")
				dbSetOrder(10)
				If dbSeek(	PADR(Alltrim(aDados[1]) , TamSX3("GW3_FILIAL" )[1]	,'') +;
							PADR(Alltrim(aDados[2]) , TamSX3("GW3_EMISDF" )[1]	,'') + ;
							PADR(Alltrim(aDados[3]) , TamSX3("GW3_SERDF" )[1] 	,'') + ;
							PADR(Alltrim(aDados[4]) , TamSX3("GW3_NRDF" )[1] 	,'') )
					RecLock("GW3",.F.)
						GW3->GW3_SITREC := "1"
						GW3->GW3_MOTREC := ""
						GW3->GW3_DTFIS  := StoD("        ")
					MsUnlock()
				EndIf
			ElseIf cTabela == "GW2" // Contrato com Autônomo
				dbSelectArea("GW2")
				dbSetOrder(1)
				If dbSeek(	 PADR(Alltrim(aDados[1]) , TamSX3("GW2_FILIAL" )[1]	,'') +;
						PADR(Alltrim(aDados[2]) , TamSX3("GW2_NRCONT" )[1]	,'') )
					RecLock("GW2",.F.)
						GW2->GW2_SITREC := "1"
						GW2->GW2_MOTREC := ""
						GW2->GW2_DTREC	:= StoD("        ")
					MsUnlock()
				EndIf
			EndIf
	EndCase

Return "TRUE"

// Função que converte a data de DD/MM/AAAA para AAAAMMDD
Static Function FormataData(cData)
	Local aData := {}, dRetorno

	aData := STRTOKARR( cData + '/' , '/' )

	dRetorno := StoD('20' + aData[3] + aData[2] + aData[1])

Return dRetorno


/*/{Protheus.doc} GFEValPF

Busca o valor para provisionamento da pré-fatura, levando em consideração o parâmetro MV_PROVCON

@author Alan Victor Lamb
@since 06/08/2014
@version 1.0
@param cFilPref, character, Filial da pré-fatura
@param cNRPref, character, Número da pré-fatura
@return nVal, valor da pré-fatura
/*/
Function GFEValPF(cFilPref, cNRPref)
	Local nVal := 0
	
	dbSelectArea("GWF")
	GWF->(dbSetOrder(3))
	If GWF->(dbSeek(PadR(cFilPref, TamSX3("GWF_FILPRE")[1])+PadR(cNrPref, TamSX3("GWF_NRPREF")[1])))
		While GWF->(!Eof()) .And.;
				GWF->GWF_FILPRE == PadR(cFilPref, TamSX3("GWF_FILPRE")[1]) .And.;
				GWF->GWF_NRPREF == PadR(cNrPref, TamSX3("GWF_NRPREF")[1])
			nVal += VLFRTPROV()
			GWF->( dbSkip() )
		EndDo
	EndIf
	
Return nVal

// Função para realizar o retorno do valor líquido da pré-fatura
Static Function GFEValLiq(cFilPref, cNrPref)
	Local nValLiq := 0

	dbSelectArea("GWK")
	dbSetOrder(1)
	If dbSeek(PadR(cFilPref, TamSX3("GWK_FILIAL")[1])+PadR(cNrPref, TamSX3("GWK_NRPF")[1]))
		While !Eof() .And. GWK->GWK_FILIAL == PadR(cFilPref, TamSX3("GWK_FILIAL")[1]) .And. GWK->GWK_NRPF == PadR(cNrPref, TamSX3("GWK_NRPF")[1])
			
			// A partir das melhorias realizadas no IRM001821 e nos chamados TPXSR9 e TQCGWO
			// a tabela GWK só é gerada para os valores que são provisionados, não sendo 
			// necessária a verificação do campo GWK_TRANS 
			If GWK->GWK_LANCTO == '1'
				nValLiq += GWK->GWK_VLMOV
			EndIf
			
			GWK->( dbSkip() )
		EndDo
	EndIf

	GWK->( dbCloseArea() )

Return cValToChar(nValLiq)

// Função para retornar a query de consulta de uma tabela
Static Function QueryBase(cTabela,cFil)
	Local cQuery := "",aFil := {}, nCont := 1
	
	cQuery += "SELECT * FROM " + RetSQLName( cTabela ) + " "
	cQuery += "WHERE R_E_C_N_O_ =  ( "
	cQuery += " 	SELECT MIN(R_E_C_N_O_) "
	cQuery += "      FROM " +  RetSQLName( cTabela ) + " TAB "
	cQuery += "     WHERE TAB.D_E_L_E_T_ = ' ' "

	// Verifica se o parametro Filial tem conteudo
	If !Empty(cFil) .And. FWModeAccess(cTabela,1) == "E"
		// Transforma a string enviada com os codigos das filiais em um array
		aFil := GFEWSDados(cFil,.F.)
		cQuery += "AND ("

		For nCont := 1 to len(aFil)
			If !Empty(aFil[nCont])

				If nCont > 1
					cQuery += " OR "
				EndIf

				cQuery += " TAB."+cTabela+"_FILIAL = '"+ aFil[nCont] + "' "
			EndIf

		Next nCont

		cQuery += " ) "
	EndIf
	
Return cQuery

// Função para verificar a existência da tabela de provisão
Static Function TemTabProv()

Return GFXCP12117("GXE_SIT")

/*/{Protheus.doc} GFEXAGRUPC
Função que retorna se o documento passado no primeiro parâmetro pode ser agrupado no cálculo do documento
do cálculo posicionado
@param cChaveDoc, char, Chave do documento a ser comparado
@param cChaveAdd, char, Chave do documento a ser agrupado
@param aCompGWU, Array, Retorno da função GFEXGrupTre do documento a ser comparado
@param aCompAdd, Array, Retorno da função GFEXGrupTre do documento a ser agrupado

@author Siegklenes.Beulke
@since 03/10/2013
@version 1.8
/*/
Function GFEXAGRUPC(cChaveDoc,cChaveAdd,aCompGWU,aCompAdd)
	Local aAreaGW1 := GW1->(GetArea())
	Local cCompDoc := ""
	Local cCompAdd := ""
	Local nX := 0
	Local aCompDoc := {}
	Local aCompAddDc := {}
	Local s_GFEEDIL	:= SuperGetMV('MV_GFEEDIL',,'1')// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
	
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	
	GW1->(dbSeek(cChaveDoc))
	cCompDoc := GW1->GW1_CDREM+GW1->GW1_CDDEST+ GW1->GW1_CDTPDC+GW1->GW1_TPFRET+;
		GW1->GW1_NRREG+GW1->GW1_USO+GW1->GW1_ENTNRC+GW1->GW1_ENTBAI+GW1->GW1_ENTEND
	
	aCompDoc := {GW1->GW1_CDREM,GW1->GW1_CDDEST, GW1->GW1_CDTPDC,GW1->GW1_TPFRET,;
		GW1->GW1_NRREG,GW1->GW1_USO,GW1->GW1_ENTNRC,GW1->GW1_ENTBAI,GW1->GW1_ENTEND,;
		GW1->GW1_FILIAL,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC}
	
	GW1->(dbSeek(cChaveAdd))
	cCompAdd := GW1->GW1_CDREM+GW1->GW1_CDDEST+ GW1->GW1_CDTPDC+GW1->GW1_TPFRET+;
		GW1->GW1_NRREG+GW1->GW1_USO+GW1->GW1_ENTNRC+GW1->GW1_ENTBAI+GW1->GW1_ENTEND
	
	aCompAddDc := {GW1->GW1_CDREM,GW1->GW1_CDDEST, GW1->GW1_CDTPDC,GW1->GW1_TPFRET,;
		GW1->GW1_NRREG,GW1->GW1_USO,GW1->GW1_ENTNRC,GW1->GW1_ENTBAI,GW1->GW1_ENTEND,;
		GW1->GW1_FILIAL,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC}
	
	If cCompDoc != cCompAdd
		GFELogWSF := GFELog():New("Calculo_Combinado", "Cálculo Combinado - Importação Datasul", SuperGetMV('MV_GFEEDIL',,'1'))
		GFELogWSF:Add("Não é possivel agrupar o documento" + CRLF + Replicate("-", 20))
		
		GFELogWSF:Add("Filial..........: " + aCompAddDc[10])
		GFELogWSF:Add("Tipo de Docto...: " + aCompAddDc[3])
		GFELogWSF:Add("Emitente Docto..: " + aCompAddDc[11])
		GFELogWSF:Add("Série Docto.....: " + aCompAddDc[12])
		GFELogWSF:Add("Número Docto....: " + aCompAddDc[13])
		GFELogWSF:NewLine()
		GFELogWSF:Add("Ao cálculo com o documento" + CRLF + Replicate("-", 20))
		GFELogWSF:Add("Filial..........: " + aCompDoc[10])
		GFELogWSF:Add("Tipo de Docto...: " + aCompDoc[3])
		GFELogWSF:Add("Emitente Docto..: " + aCompDoc[11])
		GFELogWSF:Add("Série Docto.....: " + aCompDoc[12])
		GFELogWSF:Add("Número Docto....: " + aCompDoc[13])
		GFELogWSF:NewLine()
		GFELogWSF:Add("Informações comparadas" + CRLF + Replicate("-", 20))
		GFELogWSF:Add( PadR("Remetente ",Len(GW1->GW1_CDREM)) + PadR("Destinatário ",Len(GW1->GW1_CDDEST)) + "Tipo DC " + "Tipo Frete " + "Região " + "Uso " + "Nr Cidade Entrega " + PadR("Bairro Entrega",Len(GW1->GW1_ENTBAI)) + "Endereço Entrega")
		GFELogWSF:Add( aCompAddDc[1] + aCompAddDc[2] + PadR(aCompAddDc[3],8) + PadR(aCompAddDc[4],11) + PadR(aCompAddDc[5],7) + PadR(aCompAddDc[6],4) + PadR(aCompAddDc[7],18) + aCompAddDc[8] + AllTrim(aCompAddDc[9]))
		GFELogWSF:Add( aCompDoc[1] + aCompDoc[2] + PadR(aCompDoc[3],8) + PadR(aCompDoc[4],11) + PadR(aCompDoc[5],7) + PadR(aCompDoc[6],4) + PadR(aCompDoc[7],18) + aCompDoc[8] + AllTrim(aCompDoc[9]))
		Return .F.
	EndIf
	
	// Procura por trechos similiares do documento atual com os aque já existes
	For nX := 1 to Len(aCompGWU)
		If aScan(aCompAdd,{|x| x == aCompGWU[nX]}) == 0
			GFELogWSF := GFELog():New("Calculo_Combinado", "Cálculo Combinado - Importação Datasul", s_GFEEDIL)
			GFELogWSF:Add("Não é possivel agrupar o documento" + CRLF + Replicate("-", 20))
			
			GFELogWSF:Add("Filial..........: " + aCompAddDc[10])
			GFELogWSF:Add("Tipo de Docto...: " + aCompAddDc[3])
			GFELogWSF:Add("Emitente Docto..: " + aCompAddDc[11])
			GFELogWSF:Add("Série Docto.....: " + aCompAddDc[12])
			GFELogWSF:Add("Número Docto....: " + aCompAddDc[13])
			GFELogWSF:NewLine()
			GFELogWSF:Add("Ao cálculo com o documento" + CRLF + Replicate("-", 20))
			GFELogWSF:Add("Filial..........: " + aCompDoc[10])
			GFELogWSF:Add("Tipo de Docto...: " + aCompDoc[3])
			GFELogWSF:Add("Emitente Docto..: " + aCompDoc[11])
			GFELogWSF:Add("Série Docto.....: " + aCompDoc[12])
			GFELogWSF:Add("Número Docto....: " + aCompDoc[13])
			GFELogWSF:NewLine()
			GFELogWSF:Add("Informações comparadas" + CRLF + Replicate("-", 20))
			GFELogWSF:Add("Trecho " + "Cidade Origem " + "Cidade Destino " + "Transportador")
			GFELogWSF:Add(PadR(SubStr(aCompAdd[nX],1,2),7) + PadR(SubStr(aCompAdd[nX],3,7),14) + PadR(SubStr(aCompAdd[nX],10,7),15) + SubStr(aCompAdd[nX],17))
			GFELogWSF:Add(PadR(SubStr(aCompGWU[nX],1,2),7) + PadR(SubStr(aCompGWU[nX],3,7),14) + PadR(SubStr(aCompGWU[nX],10,7),15) + SubStr(aCompGWU[nX],17))
			Return .F.
		EndIf
	Next nX
	
	RestArea(aAreaGW1)
	
Return .T.

// Função responsável por retornar as informações de trecho para agrupamento
Function GFEXGrupTre(cChave,cSeq)
	Local aTre := {}
	Local cCidDest := ""
	Local cOrigem := ""
	Local aAreaGW1 := GW1->(GetArea())
	Local aAreaGWU := GWU->(GetArea())
	Local nRecTRE
	
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
	GW1->(dbSeek(cChave))
	
	dbSelectArea("GWU")
	GWU->(dbSetOrder(1))
	GWU->(dbSeek(cChave+cSeq))
	If !GWU->(Eof())
		// A origem do 1o trecho sempre é o remetente do documento de carga
		// A partir do 2o trecho, a origem do trecho é o destino do trecho anterior
		nRecTRE := GWU->(RecNo())
		If cSeq == "01"
			
			dbSelectArea("GWN")
			dbSetOrder(1)
			If dbSeek(xFilial("GWN")+GW1->GW1_NRROM) .AND.  GFEVerCmpo({"GWN_NRCIDO"}) .AND. !Empty(GWN->GWN_NRCIDO)
				cOrigem := GWN->GWN_NRCIDO
			Else
				cOrigem := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDREM,"GU3_NRCID")
			EndIf
			cCidDest := GWU->GWU_NRCIDD
		Else
			GWU->(dbSkip(-1))
			cOrigem := GWU->GWU_NRCIDD
			GWU->(dbSkip(2))
			If !GWU->(Eof()) .And. GWU->GWU_FILIAL+GWU->GWU_CDTPDC+GWU->GWU_EMISDC+GWU->GWU_SERDC+GWU->GWU_NRDC == cChave
			    // Se houver destino informado no trecho assume a cidade destino informado, caso contrario assume a cidade do
			    // transportador do trecho seguinte, exceto o ultimo trecho, que tem outro tratamento
				cCidDest := Posicione("GU3",1,xFilial("GU3")+GWU->GWU_CDTRP,"GU3_NRCID")
			Else
				// Ultimo trecho
				If !Empty(GW1->GW1_ENTNRC) .AND. GW1->GW1_ENTNRC != PADR("0",50)
					// Se a cidade de entrega do documento foi informada, esta sera a cidade de destino
					cCidDest := GW1->GW1_ENTNRC
				Else
					// Senao assume a cidade destino do destinatario do documento
					cCidDest := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDDEST,"GU3_NRCID")
				EndIf
			EndIf
		EndIf
		GWU->(dbgoTo(nRecTRE))
		aAdd(aTre,cSeq+cOrigem+cCidDest+If(Empty(GWU->GWU_CDTRP),GWN->GWN_CDTRP,GWU->GWU_CDTRP))
	EndIf
	
	RestArea(aAreaGW1)
	RestArea(aAreaGWU)
Return aTre

/*/{Protheus.doc} GFEWSSIMULATION
Realiza a simulação de frete via WebService. 

Param
	@cOrigem	Origem dos dados (PD4000
	@aParamSim	Array com os parâmetros de simulação
	@aDadosGW1	Array com os dados do cabeçalho da nota
	@aDadosGW8	Array com os itens da nota
	@aDadosGWU	Array com os trechos da nota


@author Israel Alcantara Possoli
@since 20/08/2013
@version 1.8
/*/
Function GFEWSSIMULATION(cOrigem, aParamSim, aDadosGW1, aDadosGW8, aDadosGWU)
	Local cWsReturn    := ""
	Local nI
	Local lLog 		   := IIF(SuperGetMv("MV_LOGCALC",,'1') == '2',.F., .T.)
	Local aAgrFrt  	   := {}	// Agrupadores de frete
	Local aDocCarg 	   := {}	// Documento de carga
	Local aItDoc 	   := {}	// Itens do Documento
	Local aTrchDoc 	   := {}	// Trechos
	Local cErroSim
	Local cNrCidd
	Local cNmCidd
	Local cUfd
	Local cCdClFr
	Local cDescTrechos 	:= ""
	Local nTrechosPago 	:= 0
	Local nTimeCalc 	:= 0 // Tempo da simulação da rotina calculo de frete
	Local lConsNeg
	Local aCpPE 		:= {}
	Local lGFEXWS18 	:= ExistBlock("GFEXWS18")
	Local s_CDCLFR		:= SuperGetMv("MV_CDCLFR",.F.,"") // SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
	
	Private dDtCalcPed  := STOD("")	

	Private cTRBCCF, cTRBITE, cTRBTRE, cTRBTCF, cTRBUNC, cTRBDOC, cTRBAGRU, cTRBSIM // Variaveis utilizadas na rotina de calculo de frete

	Private aTRBUNC  := {}
	Private aTRBCCF3 := {}
	Private lTabTemp := .F.
	
	Private aTRBGRB
	Private aTRBSIM

	Private idpGRU := 1 // posição do array de agrupamento cTRBAGRU
	Private idxGRU := 1 // Indice da array de agrupamento cTRBAGRU
	Private _aCmpGRU := {"NRAGRU",;	//Numero do Agrupador
							"CDTRP" ,;	//Transportador
							"CDTPVC",;	//Tipo de Veiculo
							"CDCLFR",;	//Classificacao de Frete
							"CDTPOP",;	//Tipo de Operacao
							"DISTAN",;	//Distancia Percorrida
							"NRCIDD",;	//Cidade Destino
							"CEPD"  ,;	//CEP Destino
							"ERRO"  }	//Parametro criado para verificação de erro no momento da montagem do cálculo do romaneio
	
	Private idpUNC 	:= 1
	Private idxUNC 	:= 1
	Private _aCmpUNC := {"NRCALC",; // 1
						"TIPO"  ,; // 2
						"FINALI",; // 3
						"DTPREN",; // 4
						"HRPREN",; // 5
						"TPTRIB",; // 6
						"BASICM",; // 7
						"PCICMS",; // 8
						"VLICMS",; // 9
						"ICMRET",; // 10
						"BASISS",; // 11
						"PCISS" ,; // 12
						"VLISS" ,; // 13
						"BAPICO",; // 14
						"VLPIS" ,; // 15
						"VLCOFI",; // 16
						"PCREIC",; // 17
						"VALTAB",; // 18
						"NRAGRU",; // 19
						"IDFRVI",; // 20
						"SEQTRE",; // 21
						"CALBAS",; // 22
						"ADICIS",; // 23
						"CHVGWU",; // 24
						"DELETADO",; // 25
						"NRLCENT",;  // 26
						"GRURAT"}    // 27 
						 
	Private aTRBTCF
	Private idpTCF := 1 // posição do array cTRBTCF
	Private idxTCF := 1 // Indice da array cTRBTCF
	Private _aCmpTCF := {"NRCALC"   ,; //1
						 "CDCLFR"   ,; //2
						 "CDTPOP"   ,; //3
						 "SEQ"      ,; //4
						 "DTVIGE"   ,; //5
						 "ITEM"     ,; //6
						 "CDTRP"    ,; //7
						 "NRTAB"    ,; //8
						 "NRNEG"    ,; //9
						 "CDFXTV"   ,; //10
						 "CDTPVC"   ,; //11
						 "NRROTA"   ,; //12
						 "QTCALC"   ,; //13
						 "QTDE"     ,; //14
						 "PESOR"    ,; //15
						 "PESCUB"   ,; //16
						 "QTDALT"   ,; //17
						 "VALOR"    ,; //18
						 "VOLUME"   ,; //19
						 "NRGRUP"   ,; //20
						 "CDEMIT"   ,; //21
						 "PEDROM"   ,; //22
						 "PESPED"   ,; //23
						 "PRAZO"    ,; //24
						 "DELETADO" ,;
						 "PERCOUT"  ,; //26
						 "PESORORG"  ,;//27
						 "PESCUBORG" ,;//28
						 "VALORORG"  ,;//29
						 "VOLUMEORG" ,;//30
						 "QTDEORG"   }//31
						 
	Private idpCCF := 1 // posição do array cTRBCCF
	Private idxCCF := 1 // Indice  da array cTRBCCF
	Private _aCmpCCF := {"NRCALC" ,; // 1
						"CDCLFR" ,; // 2
						"CDTPOP" ,; // 3
						"SEQ"    ,; // 4
						"CDCOMP" ,; // 5
						"CATVAL" ,; // 6
						"QTDE"   ,; // 7
						"VALOR"  ,; // 8
						"TOTFRE" ,; // 9
						"BASIMP" ,; // 10
						"BAPICO" ,; // 11
						"FREMIN" ,; // 12
						"IDMIN"  ,; // 13
						"VLFRMI" ,; // 14
						"DELETADO" ,; // 15
						"NRLCENT",; // 16
						"CPEMIT"}   // 17
												 
	Private aTRBTRE := {} // Indice 1
	Private idpTRE := 1 // posição do array cTRBTRE
	Private idxTRE := 1 // Indice  da array cTRBTRE
	Private _aCmpTRE := {"EMISDC",;  // 1
						"SERDC" ,;  // 2
						"NRDC"  ,;  // 3
						"CDTPDC",;  // 4
						"SEQ"   ,;  // 5
						"CDTRP" ,;  // 6
						"NRCIDD",;  // 7
						"CDTPVC",;  // 8
						"PAGAR" ,;  // 9
						"NRCIDO",;  // 10
						"CEPO"  ,;  // 11
						"CEPD"  ,;  // 12
						"CDCLFR",;  // 13
						"CDTPOP",;  // 14
						"ORIGEM",;  // 15
						"DESTIN",;  // 16
						"NRGRUP",;  // 17
						"NRCALC",;  // 18
						"DELETADO"} // 19 
	
	If cOrigem == "PD4000" .OR. cOrigem == "CUSTOM"
		// Estrutura aParamSim
		// [1] GWN_CDTPVC
		// [2] GWN_CDCLFR
		// [3] GWN_CDTPOP
		// [4] Considera tabelas em negociação (Opcional, suavizar caso não seja passado como parâmetro)
		// [5] Data Base Calculo (Opcional, suavizar caso não seja passado como parâmetro)
		
		// Validação do tipo de veículo
		If !dbFind("GV3", aParamSim[1])
			cWsReturn := GFEWSRetError("Código '" + cValToChar(aParamSim[1]) + "' do tipo de veículo inválido.", "WSGFE:SIMULATION")
			
			Return(cWsReturn)
		EndIf
		
		// Validação da classificação de frete
		If !dbFind("GUB", aParamSim[2])
			cWsReturn := GFEWSRetError("Código '" + cValToChar(aParamSim[2]) + "' da classificação de frete inválido.", "WSGFE:SIMULATION")
			
			Return(cWsReturn)
		EndIf
		
		// Validação da classificação de frete
		If !dbFind("GV4", aParamSim[3])
			cWsReturn := GFEWSRetError("Código '" + cValToChar(aParamSim[3]) + "' do tipo de operação inválido.", "WSGFE:SIMULATION")			
			Return(cWsReturn)
		EndIf
		
		If ExistBlock("GFEXWS13")
			aParamSim := ExecBlock("GFEXWS13",.f.,.f.,{aParamSim})
		EndIf	
		
		//Se não for informado parâmetro, considerará tabelas com e sem negociação
		If Len(aParamSim) <= 3
			Aadd(aParamSim, '1')
		EndIf
		
		IIf(aParamSim[4] == '1', lConsNeg := .T., lConsNeg := .F.)

		if aParamSim[5] <> ""
		    dDtCalcPed := stod(aParamSim[5])
		endif
		
		// Busca a classificação de frete padrão caso não seja recebida pelos parâmetros
		cCdClFr := aParamSim[2]
		
		If Empty(cCdClFr)
			cCdClFr := SuperGetMv("MV_CDCLFR",.F.,"")
		EndIf
		
		If Empty(cCdClFr)
			cWsReturn := GFEWSRetError("Classificação de Frete não informada. Verifique o parâmetro MV_CDCLFR no Frete Embarcador.", "WSGFE:SIMULATION")
			
			Return(cWsReturn)
		EndIf
		
		GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] aAgrFrt:")
		AAdd(aAgrFrt, {;
			GetValue("99999999"	 , "GWN_NRROM"),;  // GWN_NRROM
		GetValue(""		   	 , "GWN_CDTRP")	,;  // GWN_CDTRP
		GetValue(aParamSim[1] , "GWN_CDTPVC"),;	// GWN_CDTPVC
		GetValue(cCdClFr		 , "GWN_CDCLFR"),; 	// GWN_CDCLFR
		GetValue(aParamSim[3] , "GWN_CDTPOP"),;	// GWN_CDTPOP
		0					 ,;     					// GWN_DISTAN
		PADR("",TamSx3("GWN_NRCIDD")[1]),;   		// GWN_NRCIDD
		PADR("",8)					 ,;   				// GWN_CEPD
		"0"					 ,;							// Erro
		})
			
		// Estrutura aDadosGW1 
		// [1] GW1_EMISDC 
		// [2] GW1_SERDC 
		// [3] GW1_NRDC  
		// [4] GW1_CDTPDC
		// [5] GW1_CDREM 
		// [6] GW1_CDDEST
		// [7] GW1_ENTEND
		// [8] GW1_ENTBAI
		// [9] GW1_ENTNRC
		// [10] GW1_ENTCEP
		// [11] GW1_NRREG 
		// [12] GW1_TPFRET
		// [13] GW1_ICMSDC
		// [14] GW1_USO   
		// [15] GW1_CARREG
		// [16] GW1_ENTCID
		// [17] GW1_ENTUF		

		// Ponto de Entrada refêrente a utilização do pedágio na Usina Colombo.
		If  lGFEXWS18
			aCpPE := ExecBlock("GFEXWS18",.F.,.F.,{aDadosGW1})
			If ValType(aCpPE) == "A" .And. !Empty(aCpPE)
				aDadosGW1 := aCpPE
			EndIf
		EndIf
		
		// Define o código da cidade a ser utilizado na simulação		
		cNrCidd 	:= AllTrim(Upper(aDadosGW1[9]))
		cNmCidd 	:= AllTrim(Upper(aDadosGW1[16]))
		cUfd		:= AllTrim(Upper(aDadosGW1[17]))
		
		dbSelectArea("GU7")
		dbSetOrder(1)
		If Empty(cNrCidd) .Or. !GU7->(dbSeek(xFilial("GU7") + cNrCidd))
			If !Empty(cNmCidd) .And. !Empty(cUfd)
				dbSetOrder(3)
				If dbSeek(xFilial("GU7") + PadR(cNmCidd, TamSx3("GU7_NMCID")[1]) + PadR(cUfd, TamSx3("GU7_CDUF")[1]))
					cNrCidd := GU7->GU7_NRCID
				Else
					cWsReturn := GFEWSRetError("Cidade '" + cNmCidd + "/" + cUfd + "' não encontrada no cadastro de cidade do Frete Embarcador.", "WSGFE:SIMULATION")
					
					Return(cWsReturn)
				EndIf
			EndIf
			
			If Empty(cNrCidd)
				cWsReturn := GFEWSRetError("Cidade de entrega não informada.", "WSGFE:SIMULATION")
					
				Return(cWsReturn)
			EndIf
		EndIf
		
		// Validação do código do tipo de documento de carga
		If !dbFind("GV5", aDadosGW1[4], .F.)
			cWsReturn := GFEWSRetError("Código do tipo do Documento de Carga inválido.", "WSGFE:SIMULATION")
			
			Return(cWsReturn)
		EndIf
		
		GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] aDocCarg:")
		aAdd(aDocCarg, {;
			GetValue(aDadosGW1[1] , "GW1_EMISDC"),;		// GW1_EMISDC
		GetValue(aDadosGW1[2] , "GW1_SERDC") ,; 	// GW1_SERDC
		GetValue(aDadosGW1[3] , "GW1_NRDC")  ,; 	// GW1_NRDC
		GetValue(aDadosGW1[4] , "GW1_CDTPDC"),; 	// GW1_CDTPDC
		GetValue(aDadosGW1[5] , "GW1_CDREM") ,; 	// GW1_CDREM
		GetValue(aDadosGW1[6] , "GW1_CDDEST"),;		// GW1_CDDEST
		GetValue(aDadosGW1[7] , "GW1_ENTEND"),; 	// GW1_ENTEND
		GetValue(aDadosGW1[8] , "GW1_ENTBAI"),; 	// GW1_ENTBAI
		GetValue(cNrCidd 	  , "GW1_ENTNRC"),; 	// GW1_ENTNRC
		GetValue(aDadosGW1[10], "GW1_ENTCEP"),; 	// GW1_ENTCEP
		GetValue(aDadosGW1[11], "GW1_NRREG") ,; 	// GW1_NRREG
		GetValue(aDadosGW1[12], "GW1_TPFRET"),; 	// GW1_TPFRET - Tipo de Frete
		GetValue(aDadosGW1[13], "GW1_ICMSDC"),; 	// GW1_ICMSDC - ICMS?
		GetValue(aDadosGW1[14], "GW1_USO")   ,; 	// GW1_USO - Finalidade da mercadoria
		GetValue(aDadosGW1[15], "GW1_CARREG"),; 	// GW1_CARREG - Número do carregamento
		GetValue("99999999"   , "GW1_NRROM") ,; 	// GW1_NRROM - Numero do Agrupador
		1			 						  ; 	// GW1_QTUNI ou GW1_QTVOL - Quantidade de Unitizadores ou qtde de volumes do documento de carga
		})

		// Estrutura aDadosGW8
		// [1] GW8_ITEM  
		// [2] GW8_CDCLFR
		// [3] GW8_QTDE  
		// [4] GW8_PESOR 
		// [5] GW8_PESOC 
		// [6] GW8_VALOR 
		// [7] GW8_VOLUME
		GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] aItDoc:")
		For nI := 1 To Len(aDadosGW8)
			GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] #" + cValToChar(nI))
			
			// Trecho responsável por buscar a classificação de frete padrão, caso a mesma não seja preenchida no Datasul
			cCdClFr := aDadosGW8[nI][2]
			
			If Empty(cCdClFr)
				cCdClFr := s_CDCLFR
			EndIf
		
			aAdd(aItDoc, {;
				GetValue(aDadosGW1[1]	 , "GW8_EMISDC"),;	// GW8_EMISDC
			GetValue(aDadosGW1[2]	 , "GW8_SERDC"),;		// GW8_SERDC
			GetValue(aDadosGW1[3]	 , "GW8_NRDC"),;		// GW8_NRDC
			GetValue(aDadosGW1[4]	 , "GW8_CDTPDC"),;	// GW8_CDTPDC
			GetValue(aDadosGW8[nI][1], "GW8_ITEM"),;		// GW8_ITEM
			GetValue(cCdClFr			 , "GW8_CDCLFR"),;	// GW8_CDCLFR
			SPACE(TamSX3("GW8_TPITEM")[1]),;				// GW8_TPITEM
			GetValue(aDadosGW8[nI][3], "GW8_QTDE", "N"),;			// GW8_QTDE
			GetValue(aDadosGW8[nI][4], "GW8_PESOR", "N"),;			// GW8_PESOR
			GetValue(aDadosGW8[nI][5], "GW8_PESOC", "N"),;			// GW8_PESOC
			0,;													// GW8_QTDALT
			GetValue(aDadosGW8[nI][6], "GW8_VALOR", "N"),;			// GW8_VALOR
			GetValue(aDadosGW8[nI][7], "GW8_VOLUME", "N"),;			// GW8_VOLUME
			"1";												// GW8_TRIBP
			})
		Next
		
		// Estrutura aDadosGWU
		// [1] GWU_SEQ   
		// [2] GWU_CDTRP 
		// [3] GWU_NRCIDD
		// [4] GWU_PAGAR 
		// [5] GWU_NMCIDD
		// [6] GWU_UFD
		
		GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] aTrchDoc:")
		For nI := 1 To Len(aDadosGWU)
			GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] #" + cValToChar(nI))
		
			// Define o código da cidade a ser utilizado na simulação		
			cNrCidd := AllTrim(Upper(aDadosGWU[nI][3]))
			cNmCidd := AllTrim(Upper(aDadosGWU[nI][5]))
			cUfd	:= AllTrim(Upper(aDadosGWU[nI][6]))
			
			dbSelectArea("GU7")
			dbSetOrder(1)
			If Empty(cNrCidd) .OR. !GU7->(dbSeek(xFilial("GU7") + cNrCidd))
				If !Empty(cNmCidd) .And. !Empty(cUfd)
					dbSetOrder(3)
					If dbSeek(xFilial("GU7") + PadR(cNmCidd, TamSx3("GU7_NMCID")[1]) + PadR(cUfd, TamSx3("GU7_CDUF")[1]))
						cNrCidd := GU7->GU7_NRCID
					Else
						cWsReturn := GFEWSRetError("Cidade '" + cNmCidd + "/" + cUfd + "' não encontrada no cadastro de cidade do Frete Embarcador para o trecho: " + cValToChar(nI), "WSGFE:SIMULATION")
						
						Return(cWsReturn)
					EndIf
				EndIf
				
				If Empty(cNrCidd)
					cWsReturn := GFEWSRetError("Cidade de entrega não informada.", "WSGFE:SIMULATION")
						
					Return(cWsReturn)
				EndIf
			EndIf
		
			aAdd(aTrchDoc, {;
				GetValue(aDadosGW1[1]    , "GWU_EMISDC"),;	// GWU_EMISDC
				GetValue(aDadosGW1[2]    , "GWU_SERDC")	,;	// GWU_SERDC
				GetValue(aDadosGW1[3]    , "GWU_NRDC")	,;	// GW8_NRDC
				GetValue(aDadosGW1[4]    , "GWU_CDTPDC"),;	// GWU_CDTPDC
				GetValue(aDadosGWU[nI][1], "GWU_SEQ")	,;	// GWU_SEQ
				GetValue(aDadosGWU[nI][2], "GWU_CDTRP")	,;	// GWU_CDTRP
				GetValue(aDadosGWU[nI][3], "GWU_NRCIDD"),;	// GWU_NRCIDD
				SPACE(TamSX3("GWU_CDTPVC")[1])			,;	// GWU_CDTPVC
				GetValue(aDadosGWU[nI][4], "GWU_PAGAR") ,;	// GWU_PAGAR
				""                                      ,;  // GWU_NRCIDO Não implementado na simulação de frete datasul
				""                                      ,;  // GWU_CEPO   Não implementado na simulação de frete datasul
				""                                      ,;  // GWU_CEPD   Não implementado na simulação de frete datasul
				""                                      ,;  // GWU_CDCLFR Não implementado na simulação de frete datasul
				""                                      ;  // GWU_CDTPOP Não implementado na simulação de frete datasul
			})			
			
			cDescTrechos += "[#" + cValToChar(nI) + ", Transp: " + aDadosGWU[nI][2] + ", Destino: " + aDadosGWU[nI][3] + " (" + aDadosGWU[nI][5] + "/" + aDadosGWU[nI][6] + ") " + Iif(aTrchDoc[nI, 9] == "1", "PAGO", "NÃO PAGO") + "] "
			
			If aTrchDoc[nI, 9] == "1" // GWU_PAGAR
				nTrechosPago++
			EndIf
		Next
	EndIf
	
	// Não realiza o cálculo caso não exista nenhum trecho pago
	If nTrechosPago == 0
		cWsReturn := GFEWSRetError("Nenhum trecho a ser pago, verificar o campo Cidade Cif.", "WSGFE:SIMULATION")
					
		Return(cWsReturn)
	EndIf
	
	nTimeCalc := SECONDS()

	aAgrFrt2 := aClone(aAgrFrt)
	aDocCarg2 := aClone(aDocCarg)
	aTrchDoc2 := aClone(aTrchDoc) 
	aItDoc2 := aClone(aItDoc)
	XFUNBTRB()

	aRet := GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc,,.F., 0,, lConsNeg,/*iTpSimul*/,/*lCalcLote*/, /*lHideProgress*/, lLog, /*lServ*/,/*pServTpImp*/,/*pCalcDataBase*/,/*aNoCalc*/,/*lShowTabFr*/,dDtCalcPed)
	
	GFETrace(GFETraceCfg(), "[WSGFE:SIMULATION] [" + cOrigem + "] Emissor: " + AllTrim(aDocCarg[1, 1]) + ", Trechos: " + cDescTrechos + " [Tempo total da simulação: " + PrintElapsed(nTimeCalc) + "]")
	
	If aRet[1]
		aTRBGRB 	:= aRet[05]
		aTRBTCF 	:= aRet[06]
		lTabTemp	:= aRet[07]
		aTRBUNC		:= aRet[08]
		aTRBTRE		:= aRet[09]
		aTRBCCF3	:= aRet[10]
		aTRBSIM		:= aRet[11]
		
		cWsReturn := Sim_GeraMsgRetorno(cOrigem)
				
	Else
		cErroSim := GFERomErro(aRet[3], "99999999")
		cWsReturn := GFEWSRetError(cErroSim)
	EndIf
	
	If lTabTemp
		GFEDelTab(cTRBTCF)
		GFEDelTab(cTRBUNC)
		GFEDelTab(cTRBTRE)
		GFEDelTab(cTRBCCF)
		GFEDelTab(cTRBDOC)
		GFEDelTab(cTRBAGRU)
		GFEDelTab(cTRBSIM)
	Else
		IIF(aTRBTCF == NIL,,aSize(aTRBTCF, 0))
		IIF(aTRBUNC == NIL,,aSize(aTRBUNC, 0))
		IIF(aTRBTRE == NIL,,aSize(aTRBTRE, 0))
		IIF(aTRBCCF3== NIL,,aSize(aTRBCCF3,0))
		IIF(aTRBSIM == NIL,,aSize(aTRBSIM ,0))
		aTRBTCF := Nil
		aTRBUNC := Nil
		aTRBTRE := Nil
		aTRBCCF3:= Nil
		aTRBSIM := Nil
	EndIf
	
	// Os Grupos de Entrega sempre são controlados por array,
	// mesmo quando o cálculo é parametrizado para ser por tabtemp
	IIF(aTRBGRB ==NIL,,aSize(aTRBGRB, 0))
	aTRBGRB := Nil
	
	GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION] Mensagem de retorno: " + cWsReturn)
	
Return(cWsReturn)

// Função GetValue
// Retorna o valor de um determinado campo, fazendo os tratamentos necessários com o dicionário de dados e tipo de valor.
Static Function GetValue(cValue, cCampo, cTipo)
	Default cTipo := "C"
	Default cCampo := ""
	
	GFETraceVerbose(GFETraceCfg(), "[WSGFE:SIMULATION]   > " + cCampo + " = " + AllTrim(cValToChar(cValue)))
	
	If Empty(cCampo)
		Return cValue
	EndIf
	
	If cTipo == "C"
		Return PadR(cValue, TamSX3(cCampo)[1])
	ElseIf cTipo == "N"
		Return Val(AllTrim(cValue))
	EndIf
Return(cValue)

/* Função Sim_GeraMsgRetorno
Uso Iterno
Gera a mensagem de retorno da simulação, com base nas informações 
do cálculo de frete


@author Israel Alcantara Possoli
@since 21/08/2013
@version 1.8
*/
Static Function Sim_GeraMsgRetorno(cOrigem)
	Local cRetorno := ".T." + SEP_GROUP
	Local cComponentes := ""
	Local cCompName
	Local cCompCat
	Local nCompValor
	Local cRotaOri, cRotaDest
	Local cPrevisaoDias
	Local aUniCalc := {}
	Local cSelTabFrt := SUPERGETMV("MV_ESCTBAT",.F.,"1") // Escolha da negociação
	Local nIdTrbUnc, nIdMelhorNeg
	Local nI
	Local cNrCalc
	Local dDtPrEn
	Local cNrDc
	Local cDsTab
	Local lGFEXWS15	:= ExistBlock("GFEXWS15")
	Local dDtPrev

	// Totaliza o valor do frete para cada unidade de cálculo
	GFEXFB_BORDER(lTabTemp, cTRBUNC, 01, 6) // dbSetOrder(1)
	GFEXFB_2TOP(lTabTemp  , cTRBUNC, @aTRBUNC, 6) // dbGoTop()

	While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC, 6) // ((cTRBUNC)->(Eof()))
		cNrCalc := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6, "NRCALC")
		nTotFrete := 0

		GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) // dbSetOrder(1)
		If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5, {cNrCalc}) // dbSeek((cTRBUNC)->NRCALC)
			GFEXFB_BORDER(lTabTemp, cTRBCCF, 03, 9) // dbSetOrder(3)
			If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF3, 9, {cNrCalc}) // dbSeek()
				While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF3, 9) .AND. ;
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"NRCALC") == cNrCalc

					cCompCat	:= GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CATVAL")
					cCompName   := AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCOMP"))
					nCompValor  := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"VALOR")

					IF !Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDTPOP")) .AND. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"TOTFRE") == "1"
						cComponentes += cNrCalc + SEP_FIELDS + cCompName + SEP_FIELDS + cCompCat + SEP_FIELDS + cValToChar(nCompValor) + SEP_RECORDS
						nTotFrete := nTotFrete + nCompValor
					ElseIf Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"CDTPOP")) .AND. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF3, 9,"TOTFRE") == "1"
						cComponentes += cNrCalc + SEP_FIELDS + cCompName + SEP_FIELDS + cCompCat + SEP_FIELDS + cValToChar(nCompValor) + SEP_RECORDS
						nTotFrete := nTotFrete + nCompValor
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) // dbSkip()
				EndDo
			EndIf
		EndIf

		aAdd(aUniCalc, {cNrCalc, nTotFrete, GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6, "DTPREN"), .F. })
		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) // dbSkip()
	EndDo

	If Len(aUniCalc) < 1
		cWsReturn := GFEWSRetError("Erro no resultado da simulação (COD 01). Verifique o arquivo de log do cálculo no GFE.", "WSGFE:SIMULATION")
		Return(cRetorno)
	EndIf

	// Define qual a melhor negociação
	nIdMelhorNeg := 1

	For nI := 1 To Len(aUniCalc)
		If cSelTabFrt == "1"	// Menor Valor
			If aUniCalc[nI][2] < aUniCalc[nIdMelhorNeg][2]
				nIdMelhorNeg := nI
			EndIf
		ElseIf cSelTabFrt == "2"	// Menor Prazo
			If !Empty(aUniCalc[nI][3])
				If Empty(aUniCalc[nIdMelhorNeg][3])
					nIdMelhorNeg := nI
				EndIf

				If aUniCalc[nI][3] < aUniCalc[nIdMelhorNeg][3]
					nIdMelhorNeg := nI
				EndIf
			EndIf
		EndIf
	Next

	aUniCalc[nIdMelhorNeg][4] := .T.

	If cOrigem = "PD4000" .OR. cOrigem = "CUSTOM"
		GFEXFB_BORDER(lTabTemp, cTRBUNC, 01, 6)
		GFEXFB_2TOP(lTabTemp  , cTRBUNC, @aTRBUNC, 6)

		While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC, 6)
			cNrCalc := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6, "NRCALC")

			nIdTrbUnc 	:= aScan(aUniCalc, {|x| x[1] == cNrCalc})
			If nIdTrbUnc == 0
				cWsReturn := GFEWSRetError("Erro no resultado da simulação (COD 02). Não foi possível obter os dados da unidade de cálculo da simulação.", "WSGFE:SIMULATION")
				Return(cRetorno)
			EndIF

			AddMsg(@cRetorno, "NRCALC", cNrCalc)
			AddMsg(@cRetorno, "MELHOR_NEG", IIf(aUniCalc[nIdTrbUnc][4], "T", "F"))
			AddMsg(@cRetorno, "SEQTRE", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6, "SEQTRE"))

			cNrDc := 0
			GFEXFB_BORDER(lTabTemp,cTRBTRE, 01, 7)
			If !GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 7,{cNrCalc})
				If !GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6,"CALBAS")})
					cWsReturn := GFEWSRetError("Erro no resultado da simulação (COD 03). Verifique o arquivo de log do cálculo no GFE.", "WSGFE:SIMULATION")
					Return(cRetorno)
				EndIf
			Else
				cNrDc := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7, "NRDC")
			EndIf
			GFEXFB_BORDER(lTabTemp,cTRBTCF, 01, 5) // dbSetOrder(1)
			If !GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF, 5, {cNrCalc}) // dbSeek( Alltrim((cTRBCal01)->NRCALC) )
				cWsReturn := GFEWSRetError("Erro no resultado da simulação (COD 04). Verifique o arquivo de log do cálculo no GFE.", "WSGFE:SIMULATION")
				Return(cRetorno)
			EndIf

			AddMsg(@cRetorno, "CDTRP", GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDTRP"))
			AddMsg(@cRetorno, "NRTAB", GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRTAB"))

			cDsTab := Posicione("GVA",1,xFilial("GVA")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRTAB"),"GVA_DSTAB")

			// Criação de novos componentes relacionados a tabela utilizada para a simulação
			If lGFEXWS15
				cComponentes := ExecBlock("GFEXWS15",.F.,.F.,{cComponentes, cNrCalc, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDTRP"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRTAB"),  GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRNEG"),  GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDFXTV"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRROTA") })
			EndIf

			cRotaOri  := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7, "ORIGEM"),"GU7_NMCID"))
			cRotaDest := AllTrim(POSICIONE("GU7",1,XFILIAL("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE, 7, "DESTIN"),"GU7_NMCID"))

			AddMsg(@cRetorno, "ROTA_ORIGEM", cRotaOri)
			AddMsg(@cRetorno, "ROTA_DESTINO", cRotaDest)
			AddMsg(@cRetorno, "NR_ROTA", GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRROTA"))
			AddMsg(@cRetorno, "DS_ROTA", cRotaOri + " x " + cRotaDest)

			dDtPrEn := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6, "DTPREN")
			AddMsg(@cRetorno, "PREVISAO_ENT", DTOC(dDtPrEn))

			dDtPrev := DATE()
			if !Empty(dDtCalcPed)
				dDtPrev := dDtCalcPed
			endif

			cPrevisaoDias := ""
			If !Empty(dDtPrEn)
				If dDtPrEn > dDtPrev
					cPrevisaoDias := cValToChar(dDtPrEn - dDtPrev)
				Else
					cPrevisaoDias := cValToChar(dDtPrev - dDtPrEn)
				EndIf
			EndIf

			AddMsg(@cRetorno, "PREVISAO_DIAS"  , cPrevisaoDias)
			AddMsg(@cRetorno, "VALOR_FRETE"    , cValToChar(aUniCalc[nIdTrbUnc][2]))
			AddMsg(@cRetorno, "VALOR_FRETECOMB", cValToChar(aUniCalc[nIdTrbUnc][2]))
			AddMsg(@cRetorno, "TIPO_VEICULO"   , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDTPVC"))
			AddMsg(@cRetorno, "TIPO_OPERACAO"  , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDTPOP"))
			AddMsg(@cRetorno, "CLASS_FRETE"    , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDCLFR"))
			AddMsg(@cRetorno, "DT_VALIDADE"    , DTOC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "DTVIGE")))
			AddMsg(@cRetorno, "VLICMS", cValToChar(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC, 6, "VLICMS")))
			AddMsg(@cRetorno, "DSTAB", cDsTab)
			AddMsg(@cRetorno, "NRDC"		   , cNrDc)

			AddMsg(@cRetorno, "NRNEG", cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "NRNEG")))
			AddMsg(@cRetorno, "CDFXTV", cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF, 5, "CDFXTV")))

			cRetorno := cRetorno + SEP_RECORDS
			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
		EndDo
	EndIf

	// Componentes de Frete
	cRetorno += SEP_GROUP + cComponentes

Return(cRetorno)

// Função AddMsg
// Adiciona dados na variável 'cVar'  fazendo os tratamentos e adicionando separador
Static Function AddMsg(cVar, cCampo, cValue)

	cVar := cVar + AllTrim(cValue) + SEP_FIELDS
Return

/* Função dbFind
Verifica se um determinado código de registro existe
Uso Iterno

lEmpty (.T.) Permite ou não o código estar em branco

@author 
@since 21/08/2013
@version 1.8
*/
Static Function dbFind(cTable, cCodigo, lEmpty)
	Default lEmpty := .T.

	// Código em branco - Permite
	If lEmpty .AND. Empty(cCodigo)
		Return .T.
	EndIf

	// Código em branco - Não Permite
	If !lEmpty .AND. Empty(cCodigo)
		Return .F.
	EndIf

	// Código contém valor - Verifica se existe
	dbSelectArea(cTable)
	dbSetOrder(1)
Return dbSeek(xFilial(cTable) + cCodigo)

// Função PrintElapsed
// Retorna o tempo decorrido com base em um tempo inicial e o tempo atual
Static Function PrintElapsed(nTempoIni)
	Local nTempoTotal
	Local cRet := ""

	nTempoTotal := SECONDS() - nTempoIni

	If nTempoTotal > 60
		cRet := cValToChar(NoRound(nTempoTotal / 60, 1)) + " Minutos"
	Else
		cRet := cValToChar(NoRound(nTempoTotal, 1)) + " Segundos"
	EndIf

Return(cRet)

// Função RetFilTab
// Retorna a filial para utilizar na pesquisa com base na filial passada por parâmetro
Static Function RetFilTab(cTabela,cFilPar)
	Local cFilTab := ""

	If Empty(xFilial(cTabela))
		cFilTab := Space(TamSx3(Iif(SubStr(cTabela,1,1)=="S",SubStr(cTabela,2,2),cTabela)+"_FILIAL")[1])
	Else
		If !Empty(cFilPar)
			cFilTab := PadR(cFilPar,TamSx3(Iif(SubStr(cTabela,1,1)=="S",SubStr(cTabela,2,2),cTabela)+"_FILIAL")[1])
		Else
			cFilTab := xFilial(cTabela)
		EndIf
	EndIf
Return cFilTab

/*/{Protheus.doc} GFEWSRetError
Gera a mensagem de retorno de erro do WebService, com geração de log

@param  cError		Mensagem de erro a ser retornada
@param  cFunction   Nome da função do WebService que causou a exceção (Opcional)
@param  lEncode   	Codifica a mensagem em Base64 (Opcional). Default: .F.
@param  lLog   		Gera log do erro (De acordo com o configurado no GFETrace) (Opcional). Default: .T.


@author Israel A Possoli
@since 15/01/2016
@version 1.0
/*/
Function GFEWSRetError(cError, cFunction, lEncode, lLog)
	Local cRet
	Default lEncode := .F.
	Default lLog := .T.
	Default cFunction := ""

	If !Empty(cFunction)
		cFunction := "[" + cFunction + "]"
	EndIf

	If lLog
		GFETraceErro(GFETraceCfg(), cFunction + " ** " + cError)
	EndIf

	cRet := ".F." + SEP_GROUP + cError

	If (lEncode)
		cRet := Encode64(cRet)
	EndIF
Return (cRet)

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEWSEmit
Função que realiza a busca de Clientes, Fornecedores e Tranportadores (Emitentes) através 
do CNPJ/CPF e Inscrição Estadual.
A integração estará ativa somente quando for Operador Logístico, desta forma é necessário:
- GFE estar integrado ao ERP Datasul;
- GFE estar integrado ao TMS Protheus;

@author Leonardo Ribas Jimenez Hernandez
@since 07/12/2016
@version 1.0
/*/
//---------------------------------------------------------------------------------------
Static Function GFEWSEmit()

	Local cAliasSA1 := ""
	Local cAliasSA2 := ""
	Local cAliasSA4 := ""

	If GU3->GU3_FORN == '1' // Fornecedor
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))

		If !Empty(GU3->GU3_IDFED)
			cAliasSA2 := GetNextAlias()

			cQuery := "    SELECT A2_COD, A2_LOJA"
			cQuery += "     FROM "+RetSqlName("SA2")+" SA2 "
			cQuery += "    WHERE SA2.D_E_L_E_T_ = '' "
			cQuery += "   AND A2_CGC = '"+ AllTrim(GU3->GU3_IDFED) +"' "
			cQuery += "   AND A2_INSCR = '" +  AllTrim(GU3->GU3_IE) +"' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSA2,.T.,.T.)

			(cAliasSA2)->(dbGoTop())

			IF !(cAliasSA2)->(Eof())
				GU3->GU3_CDERP  := (cAliasSA2)->A2_COD
				GU3->GU3_CDCERP := (cAliasSA2)->A2_LOJA
			Else
				DbSelectArea("SA2")
				SA2->(DbSetOrder(3))
				If SA2->(dbSeek(xFilial("SA1")+GU3->GU3_IDFED))
					GU3->GU3_CDERP  := SA2->A2_COD
					GU3->GU3_CDCERP := SA2->A2_LOJA
				Else
					SA2->(DbSetOrder(2))
					If SA2->(dbSeek(xFilial("SA2")+PadR(GU3->GU3_NMEMIT,TamSx3("A2_NOME")[1]) ))
						GU3->GU3_CDERP  := SA2->A2_COD
						GU3->GU3_CDCERP := SA2->A2_LOJA
					EndIf
				EndIf
			EndIf
		Else
			SA2->(DbSetOrder(2))
			If SA2->(dbSeek(xFilial("SA2")+PadR(GU3->GU3_NMEMIT,TamSx3("A2_NOME")[1]) ))
				GU3->GU3_CDERP  := SA2->A2_COD
				GU3->GU3_CDCERP := SA2->A2_LOJA
			EndIf
		EndIf
		(cAliasSA2)->(dbCloseArea())

	ElseIf GU3->GU3_CLIEN == '1' //Cliente

		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))

		If !Empty(GU3->GU3_IDFED)
			cAliasSA1 := GetNextAlias()

			cQuery := "    SELECT A1_COD, A1_LOJA"
			cQuery += "     FROM "+RetSqlName("SA1")+" SA1 "
			cQuery += "    WHERE SA1.D_E_L_E_T_ = '' "
			cQuery += "   AND A1_CGC = '"+ AllTrim(GU3->GU3_IDFED) +"' "
			cQuery += "   AND A1_INSCR = '" +  AllTrim(GU3->GU3_IE) +"' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSA1,.T.,.T.)

			(cAliasSA1)->(dbGoTop())

			If !(cAliasSA1)->(Eof())
				GU3->GU3_CDERP  := (cAliasSA1)->A1_COD
				GU3->GU3_CDCERP := (cAliasSA1)->A1_LOJA
			Else
				DbSelectArea("SA1")
				SA1->(DbSetOrder(3))
				If SA1->(dbSeek(xFilial("SA1")+GU3->GU3_IDFED))
					GU3->GU3_CDERP  := SA1->A1_COD
					GU3->GU3_CDCERP := SA1->A1_LOJA
				Else
					SA1->(DbSetOrder(5))
					If SA1->(dbSeek(xFilial("SA1")+PadR(GU3->GU3_NMFAN,TamSx3("A1_NREDUZ")[1]) ))
						GU3->GU3_CDERP  := SA1->A1_COD
						GU3->GU3_CDCERP := SA1->A1_LOJA
					EndIf
				EndIf
			EndIf
		Else
			SA1->(DbSetOrder(5))
			If SA1->(dbSeek(xFilial("SA1")+PadR(GU3->GU3_NMFAN,TamSx3("A1_NREDUZ")[1]) ))
				GU3->GU3_CDERP  := SA1->A1_COD
				GU3->GU3_CDCERP := SA1->A1_LOJA
			EndIf
		EndIf
		(cAliasSA1)->(dbCloseArea())
	EndIf

	// Cliente pode ser Fornecedor e Transportador ou Cliente e Transportador
	If (GU3->GU3_TRANSP == '1' .OR. GU3->GU3_AUTON == '1') .And. !Empty(AllTrim(StrTran(GU3->GU3_IDFED, "0", "")))//Transportador ou Autônomo
		dbSelectArea("SA4")
		SA4->(dbSetOrder(1))

		If !Empty(GU3->GU3_IDFED)
			cAliasSA4 := GetNextAlias()

			cQuery := "    SELECT A4_COD"
			cQuery += "     FROM "+RetSqlName("SA4")+" SA4 "
			cQuery += "    WHERE SA4.D_E_L_E_T_ = '' "
			cQuery += "   AND A4_CGC = '"+ AllTrim(GU3->GU3_IDFED) +"' "
			cQuery += "   AND A4_INSEST = '" +  AllTrim(GU3->GU3_IE) +"' "

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSA4,.T.,.T.)

			(cAliasSA4)->(dbGoTop())

			If !(cAliasSA4)->(Eof())
				GU3->GU3_CDTERP := (cAliasSA4)->A4_COD
			Else
				DbSelectArea("SA4")
				SA4->(DbSetOrder(3))
				If SA4->(dbSeek(xFilial("SA4")+GU3->GU3_IDFED))
					GU3->GU3_CDTERP := SA4->A4_COD
				Else
					dbSelectArea("SA4")
					SA4->(DbSetOrder(2))
					If SA4->(dbSeek(xFilial("SA4")+PadR(GU3->GU3_NMEMIT,TamSx3("A4_NOME")[1]) ))
						GU3->GU3_CDTERP := SA4->A4_COD
					EndIf
				EndIf
			EndIf
		Else
			dbSelectArea("SA4")
			SA4->(DbSetOrder(2))
			If SA4->(dbSeek(xFilial("SA4")+PadR(GU3->GU3_NMEMIT,TamSx3("A4_NOME")[1]) ))
				GU3->GU3_CDTERP := SA4->A4_COD
			EndIf
		EndIf
		(cAliasSA4)->(dbCloseArea())
	EndIf

Return

/*/{Protheus.doc} GFEWSFUNLG
Verifca as condições dos paramêtros de integração da plataforma logística:
GFE+DATASUL+TMSPROTHEUS+numeração própria+integração direta

@author Leonardo Ribas Jimenez Hernandez
@since 13/12/2016
@version 1.0
/*/
Function GFEWSFUNLG()
	Local lRet := .F.

	If SuperGetMv("MV_ERPGFE",.F.,"1") == '1' .And. SuperGetMv("MV_INTTMS",.F.,.F.) == .T. .And. SuperGetMv("MV_CADERP",.F.,"1") == '1';
			.And. SuperGetMv("MV_INTGFE",.F.,.F.)  ==  .T. .And. SuperGetMv("MV_INTGFE2",.F.,"2") == '1'
		lRet := .T.
	EndIf

Return lRet


/*/{Protheus.doc} GFEWSCITY
Envio de Cidade Origem e Destino para a integração.
@author Adm Fretes
@since 21/11/2017
/*/
Function GFEWSCITY(cFILIAL,cEMISDF, cCDES, cSERDF, cNRDF, cDTEMIS, cTPDF)
	Local cOrigem 		:= ""
	Local cCidDest 		:= ""
	Local aCity			:= {}
	Local cChaveGW1		:= ""
	Local aTrechos 		:= {}
	Local cMV_DPSERV	:= SuperGetMV("MV_DPSERV", .F., "1")

	Local cAliasGWF		:= ""
	Local cAliasGW4		:= ""
	Local cAliasGWU		:= ""

	If cMV_DPSERV == "1"
		cAliasGWF := GetNextAlias()

		BeginSQL Alias cAliasGWF
			SELECT GWF.GWF_CIDORI, GWF.GWF_CIDDES
			FROM %Table:GWF% GWF
			WHERE GWF.GWF_FILIAL = %Exp:cFILIAL%
			AND GWF.GWF_EMISDF IN (%Exp:GFEGetEmRz(cEMISDF)%)
			AND GWF.GWF_CDESP = %Exp:cCDES%
			AND GWF.GWF_SERDF = %Exp:cSERDF%
			AND GWF.GWF_NRDF = %Exp:cNRDF%
			AND GWF.GWF_DTEMDF = %Exp:cDTEMIS%
			AND GWF.%NotDel%
		EndSQL

		If (cAliasGWF)->(!EoF())
			cOrigem 	:= (cAliasGWF)->GWF_CIDORI
			cCidDest 	:= (cAliasGWF)->GWF_CIDDES
		EndIf

		(cAliasGWF)->(dbCloseArea())
	Else
		cAliasGW4 := GetNextAlias()
		BeginSQL Alias cAliasGW4
			SELECT GWF.GWF_CIDORI, GWF.GWF_CIDDES
			FROM %Table:GW4% GW4
			INNER JOIN %Table:GW1% GW1
			ON GW1.GW1_FILIAL = GW4.GW4_FILIAL
			AND GW1.GW1_CDTPDC = GW4.GW4_TPDC 
			AND GW1.GW1_EMISDC = GW4.GW4_EMISDC
			AND GW1.GW1_SERDC = GW4.GW4_SERDC
			AND GW1.GW1_NRDC = GW4.GW4_NRDC
			AND GW1.%NotDel%
			INNER JOIN %Table:GWH% GWH
			ON GWH.GWH_FILIAL = GW1.GW1_FILIAL
			AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC
			AND GWH.GWH_EMISDC = GW1.GW1_EMISDC
			AND GWH.GWH_SERDC = GW1.GW1_SERDC
			AND GWH.GWH_NRDC = GW1.GW1_NRDC
			AND GWH.%NotDel%
			INNER JOIN %Table:GWF% GWF
			ON GWF.GWF_FILIAL = GWH.GWH_FILIAL
			AND GWF.GWF_NRCALC = GWH.GWH_NRCALC
			AND GWF.%NotDel%
			WHERE GW4.GW4_FILIAL = %Exp:cFILIAL%
			AND GW4.GW4_EMISDF IN (%Exp:GFEGetEmRz(cEMISDF)%)
			AND GW4.GW4_CDESP = %Exp:cCDES%
			AND GW4.GW4_SERDF = %Exp:cSERDF%
			AND GW4.GW4_NRDF = %Exp:cNRDF%
			AND GW4.GW4_DTEMIS = %Exp:cDTEMIS%
			AND GW4.%NotDel%
		EndSQL

		If !((cAliasGW4)->(Eof()))
			cOrigem 	:= (cAliasGW4)->GWF_CIDORI
			cCidDest 	:= (cAliasGW4)->GWF_CIDDES
		EndIf

		(cAliasGW4)->(dbCloseArea())
	EndIf

	If Empty(cOrigem)
		cAliasGWU := GetNextAlias()

		BeginSQL Alias cAliasGWU
			SELECT GWU.GWU_FILIAL, 
				   GWU.GWU_CDTPDC,
				   GWU.GWU_EMISDC,
				   GWU.GWU_SERDC,
				   GWU.GWU_NRDC,
				   GWU.GWU_SEQ
			FROM %Table:GW4% GW4
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW4.GW4_FILIAL
			AND GWU.GWU_CDTPDC = GW4.GW4_TPDC
			AND GWU.GWU_EMISDC = GW4.GW4_EMISDC
			AND GWU.GWU_SERDC = GW4.GW4_SERDC
			AND GWU.GWU_NRDC = GW4.GW4_NRDC
			AND GWU.%NotDel%
			WHERE GW4.GW4_FILIAL = %Exp:cFILIAL%
			AND GW4.GW4_EMISDF IN (%Exp:GFEGetEmRz(cEMISDF)%)
			AND GW4.GW4_CDESP = %Exp:cCDES%
			AND GW4.GW4_SERDF = %Exp:cSERDF%
			AND GW4.GW4_NRDF = %Exp:cNRDF%
			AND GW4.GW4_DTEMIS = %Exp:cDTEMIS%
			AND GW4.%NotDel%
		EndSQL

		If !((cAliasGWU)->(Eof()))
			cChaveGW1 	:= (cAliasGWU)->GWU_FILIAL + (cAliasGWU)->GWU_CDTPDC + (cAliasGWU)->GWU_EMISDC + (cAliasGWU)->GWU_SERDC + (cAliasGWU)->GWU_NRDC

			aTrechos 	:= GFEXGrupTre(cChaveGW1,(cAliasGWU)->GWU_SEQ)

			cOrigem 	:= PadR(SubStr(aTrechos[1],3,7),14)
			cCidDest 	:= PadR(SubStr(aTrechos[1],10,7),15)
		EndIf

		(cAliasGWU)->(dbCloseArea())
	EndIf

	aAdd(aCity,{cOrigem,cCidDest})
Return aCity

//"Função para inclusão de registros"
Function GFEWSPUTD (cTabela,aDados)
	Local cRetorno
	Local aRetIni

	aRetIni := GFEWSInit()

	If aRetIni[1]

		// Ponto de entrada que permite a manipulação do array aDados
		If ExistBlock("GFEXWS05")
			aDados := ExecBlock("GFEXWS05",.F.,.F.,{cTabela,aDados})
		EndIf

		DO CASE
		CASE cTabela == "GU1" ; GFEInsGU1(aDados) //Grupo de Emitente
		CASE cTabela == "GU7" ; GFEInsGU7(aDados) //Cidades
		CASE cTabela == "GUG" ; GFEInsGUG(aDados) //Unitizadores
		CASE cTabela == "GUE" ; GFEInsGUE(aDados) //Contas Contábeis
		CASE cTabela == "GUH" ; GFEInsGUH(aDados) //Centro de Custo
		CASE cTabela == "GWN" ; GFEInsGWN(aDados) //Romaneios
		CASE cTabela == "GU3" ; GFEInsGU3(aDados) //Emitentes
		CASE cTabela == "GU2" ;	GFEInsGU2(aDados) //Contatos do Emitente
		CASE cTabela == "GW1" ;	GFEInsGW1(aDados) //Documentos de Carga
		CASE cTabela == "GWB" ;	GFEInsGWB(aDados) //Unitizadores de carga
		CASE cTabela == "GWU" ;	GFEInsGWU(aDados) //Trechos
		CASE cTabela == "GW8" ;	GFEInsGW8(aDados) //Itens
		CASE cTabela == "GWF" ; GFEInsGWF(aDados) //Cálculo Combinado
		CASE cTabela == "GV3" ; GFEInsGV3(aDados) //Tipo de Veículo(TipoCarga)
		CASE cTabela == "GXT" ; GFEInsGXT(aDados) //Contrato
		Case cTabela == "GW6" .And. GFXCP12127("GW6_DTLIQD")
			GFEInsGW6(aDados) //Faturas de Frete
		CASE cTabela == "GW1Ent" ;  cRetorno := GFEInsGW1Ent(aDados) //Documentos de Carga de Entrada
		CASE cTabela == "GWUEnt" ;	GFEInsGWUEnt(aDados) //Trechos do Documentos de Carga de Entrada
		CASE cTabela == "GW8Ent" ;	GFEInsGW8Ent(aDados) //Itens   do Documentos de Carga de Entrada
		ENDCASE

		If cTabela != "GW1Ent"
			cRetorno := "TRUE"
		EndIf

		// Início Ponto de Entrada Procomp
		If ExistBlock("GFEXWS02")
			cRetorno := ExecBlock("GFEXWS02",.f.,.f.,{aDados,cTabela})
		EndIf
		// Fim Ponto de Entrada Procomp

	Else
		cRetorno := aRetIni[2]
	EndIf
Return cRetorno

Function GFEWSDELD(cTabela,aDados)
	Local aRetIni

	aRetIni := GFEWSInit()
	cBkpFilAnt := cFilAnt

	IF aRetIni[1]

		cFilAnt := aDados[1]
		DO CASE

		CASE cTabela == "GU1" ; GFEDelGU1(aDados) //Grupo de Emitente
		CASE cTabela == "GU7" ; GFEDelGU7(aDados) //Cidades
		CASE cTabela == "GUG" ; GFEDelGUG(aDados) //Unitizadores
		CASE cTabela == "GUE" ; GFEDelGUE(aDados) //Contas Contábeis
		CASE cTabela == "GUH" ; GFEDelGUH(aDados) //Centro de Custo
		CASE cTabela == "GWN" ; GFEDelGWN(aDados) //Romaneios
		CASE cTabela == "GU3" ; GFEDelGU3(aDados) //Emitentes
		CASE cTabela == "GU2" ;	GFEDelGU2(aDados) //Contatos do Emitente
		CASE cTabela == "GV3" ;	GFEDelGV3(aDados) //Tipo de Veículo
		CASE cTabela == "GW1" ;	cRetorno := GFEDelGW1(aDados) //Documentos de Carga
		CASE cTabela == "GW1Ent" ; cRetorno := GFEDelGW1Ent(aDados) //Documentos de Carga
		CASE cTabela == "GXT" ;	cRetorno := GFEDelGXT(aDados) //Documentos de Carga
		OTHERWISE

			// Início Ponto de Entrada Vicunha
			If ExistBlock("GFEXWS11")
				cRetorno  := ExecBlock("GFEXWS11",.f.,.f.,{cTabela,aDados})
			EndIf
			// Fim Ponto de Entrada Vicunha
		ENDCASE

		If cTabela != "GW1Ent" .And. cTabela != "GW1"
			cRetorno := "TRUE"
		EndIf
	Else
		cRetorno := aRetIni[2]
	EndIf
	cFilAnt = cBkpFilAnt
Return cRetorno

