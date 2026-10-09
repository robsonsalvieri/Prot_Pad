#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA040.CH"

/*/{Protheus.doc} GPEA040F
Substituição das verbas de férias conforme nova natureza de rubrica do eSocial
Essa rotina tem como objetivo auxiliar o usuário na criação de novas verbas que substituirão as verbas da SRR, no XML "FER"
@Author.....: isabel.noguti
@Since......: 06.11.2025
@Version....: S-1.3
/*/
Function GPEA040F()
	Local aArea			:= GetArea()
	Local nX			:= 0
	Local nOpcA			:= 0
	Local oSize			:= FwDefSize():New(.T.)
	Local aColsSRV		:= {}
	Local aHeaderSRV	:= {}
	Local cQrySRV		:= ""
	Local cTotSRV		:= ""
	Local aTitle		:= {}
	Local cFilSrv		:= xFilial( "SRV" )
	Local dDtMV			:= GetMv("MV_DTINFER", .F., StoD(""))
	Local nTotal		:= 0
	Local nTamVb		:= FWSX3Util():GetFieldStruct("RV_COD")[3]
	Local nTamDesc		:= FWSX3Util():GetFieldStruct("RV_DESCDET")[3]
	Local cPdAux		:= Space(nTamVb)
	Local cPdAuxA		:= Space(nTamVb)
	Local cDescAux		:= ""
	Local aAlterSRV		:= {"TAB_DESCN","TAB_DESCA","TAB_PDN","TAB_PDA"}
	Local cTitle		:= ""
	Local aLogProc		:= {}
	Local lAutoCod		:= .F.
	Local cUltPD		:= ""
    Local aCodFol       := {}
    Local aIgnoraVb     := ""
    Local cCod0065      := ""
    Local cCod0168      := ""
	Local oButton1
	Local aIdsDifFer	:= {'0088','0089','0090','0091','0092','0093','0094','0095','0096','0097','0098','0099','0227','0228','0838','0839','0840','0841','0101'}
	Local cQueryPrin	:= ""
	Local cQryTot 		:= ""
	Local cQryVerb		:= ""
	Local nParamOrd 	:= 1
	Local oStmtTot 		:= Nil
	Local oStmtSRV		:= Nil

	Private lMsErroAuto	:= .F.
	Private cVigencia	:= ""
    Private cCondPd     := ""

	If !Empty(dDtMV)	//"Processo concluído - "Processamento já efetuado para esta filial"
		Help(,, STR0470,, STR0471, 1,,,,,,, {STR0472}) //"Verifique as configurações das verbas e o conteúdo do parâmetro MV_DTINFER"
		Return
	EndIf

    Fp_CodFol( @aCodFol , xFilial( "SRV" ), .F., .F. )

    //Identifica se deve acrescentar a verba de Id 0065 na query das verbas a serem substituídas
    If Len(aCodFol) > 0
        cCod0065 := aCodFol[65][1]
        cCod0168 := aCodFol[168][1]
        If RetValSrv(cCod0065, cFilAnt, 'RV_INCIRF') <> '43' .And. RetValSrv(cCod0065, cFilAnt, 'RV_INCCP') $ '31|33' .And. ;
         (RetValSrv(cCod0168, cFilAnt, 'RV_INCIRF') == '43' .Or. !Empty(RetValSrv(cCod0168, cFilAnt, 'RV_FERXML')))
            cCondPd := cCod0065
        EndIf
    EndIf

    //Identifica quais verbas devem ser desprezadas para a substituição devido já ser a subsituta de outra
    aIgnoraVb := fIgnoraVb()

	cQryTot := "SELECT COUNT(RV_COD) TOTAL, MAX(RV_COD) ULTIMO"
	cQueryPrin := " FROM "+ RetSqlName("SRV") + " SRV"
	cQueryPrin += " WHERE SRV.RV_FILIAL = ? "
	cQueryPrin += " AND SRV.RV_REFFER = ? "
	cQueryPrin += " AND (SRV.RV_INCIRF IN ('13  ','33  ','43  ','53  ','48  ') OR (SRV.RV_COD = ? ) )"
	cQueryPrin += " AND SRV.RV_FERXML= ? "
	cQueryPrin += " AND SRV.RV_FERAXML= ? "
	cQueryPrin += " AND SRV.D_E_L_E_T_ = ? "
	If !Empty(aIgnoraVb)
		cQueryPrin += " AND SRV.RV_COD NOT IN (?) "
	EndIf
	If !Empty(aIdsDifFer)
		cQueryPrin += " AND SRV.RV_CODFOL NOT IN (?)"
	EndIf
	cQryTot += cQueryPrin

	cQryTot := ChangeQuery(cQryTot)
	oStmtTot := FwExecStatement():New(cQryTot)
	oStmtTot:SetString(nParamOrd++, cFilSrv )	
	oStmtTot:SetString(nParamOrd++, "S" )	
	oStmtTot:SetString(nParamOrd++, cCondPd )
	oStmtTot:SetString(nParamOrd++, '' )
	oStmtTot:SetString(nParamOrd++, '' )
	oStmtTot:SetString(nParamOrd++, ' ' )
	If !Empty(aIgnoraVb)
		oStmtTot:SetIn(nParamOrd++, aIgnoraVb )
	EndIf
	If !Empty(aIdsDifFer)
		oStmtTot:SetIn(nParamOrd++, aIdsDifFer )
	EndIf

    cTotSRV := oStmtTot:OpenAlias()
	(cTotSRV)->(DBGoTop())
	
	nTotal := (cTotSRV)->TOTAL
	cUltPD := (cTotSRV)->ULTIMO
	(cTotSRV)->(DbCloseArea())
	If nTotal > 0
		lAutoCod := MsgYesNo(STR0446 + cValtoChar(nTotal) + STR0447 + CRLF + STR0448, STR0449)//"Na filial atual foram encontradas XX verbas a serem substituídas. Deseja que o processamento defina os novos códigos com base no controle de numeração automática?" "Em caso negativo, deverá informar manualmente." //"Sugestão de códigos"
		If lAutoCod
			cPdAux := cUltPD
		EndIf
	Else
		Help( , , STR0362, , STR0450, 1, 0 ) //"Não foram encontradas verbas de férias conforme a configuração definida para processar a substituição."
		Return
	EndIf

	DbSelectArea("SRV")
	DbSetOrder(1)

	cQryVerb := "SELECT SRV.RV_COD, SRV.RV_DESC, SRV.RV_CODFOL, SRV.RV_INCIRF, SRV.RV_NATUREZ, SRV.RV_DESCDET"
	cQryVerb += cQueryPrin
	cQryVerb += " ORDER BY SRV.RV_COD"

	cQryVerb := ChangeQuery(cQryVerb)
	oStmtSRV := FwExecStatement():New(cQryVerb)
	nParamOrd := 1
	oStmtSRV:SetString(nParamOrd++, cFilSrv )	
	oStmtSRV:SetString(nParamOrd++, "S" )	
	oStmtSRV:SetString(nParamOrd++, cCondPd )
	oStmtSRV:SetString(nParamOrd++, '' )
	oStmtSRV:SetString(nParamOrd++, '' )
	oStmtSRV:SetString(nParamOrd++, ' ' )
	If !Empty(aIgnoraVb)
		oStmtSRV:SetIn(nParamOrd++, aIgnoraVb )
	EndIf
	If !Empty(aIdsDifFer)
		oStmtSRV:SetIn(nParamOrd++, aIdsDifFer )
	EndIf

    cQrySRV := oStmtSRV:OpenAlias()
	(cQrySRV)->(DBGoTop())

	While !(cQrySRV)->(EoF())
		If lAutoCod
			cPdAux	:= Soma1(cPdAux)
			while SRV->(dbSeek(cFilSrv + cPdAux))
				cPdAux := Soma1(cPdAux)
			EndDo
		EndIf

		cDescAux := AllTrim( If(Empty((cQrySRV)->RV_DESCDET), (cQrySRV)->RV_DESC, (cQrySRV)->RV_DESCDET) )
		If (cQrySRV)->RV_NATUREZ $ "1016|1017"
			If lAutoCod
				cPdAuxA	:= Soma1(cPdAux)
				while SRV->(dbSeek(cFilSrv + cPdAuxA))
					cPdAuxA := Soma1(cPdAuxA)
				EndDo
			EndIf
			aAdd( aColsSRV, { (cQrySRV)->RV_COD, (cQrySRV)->RV_CODFOL , (cQrySRV)->RV_DESC, (cQrySRV)->RV_INCIRF, (cQrySRV)->RV_NATUREZ, cPdAux, Pad(cDescAux + " PG MES", nTamDesc), cPdAuxA, Pad(cDescAux + " PG MES ANT", nTamDesc), .F.})
			cPdAux := cPdAuxA
		Else//string vazia impede preencher FerA
			aAdd( aColsSRV, { (cQrySRV)->RV_COD, (cQrySRV)->RV_CODFOL , (cQrySRV)->RV_DESC, (cQrySRV)->RV_INCIRF, (cQrySRV)->RV_NATUREZ, cPdAux, Pad(cDescAux + " PG MES", nTamDesc), "", "", .F.})
		EndIf
		(cQrySRV)->(dbSkip())
	EndDo

	If !Empty(aColsSRV)
		oSize:AddObject( "MSG", 70, 20, .T., .F. )
		oSize:AddObject( "GETDADOS", 100, 100, .T., .T. )
		oSize:Process()
		cTitle := STR0445 + If(lAutoCod, STR0451, STR0452) + STR0453 //"Substituição Verbas de Férias - Verifique/Informe as informações das novas verbas a serem criadas"
		Define MsDialog oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] Title cTitle Pixel style DS_MODALFRAME
			@ oSize:GetDimension("MSG","LININI"), oSize:GetDimension("MSG","COLINI") SAY OemToAnsi(STR0474+CRLF+STR0475+CRLF+STR0476) SIZE 800, 030 Of oDlg PIXEL 	//"Este procedimento fará a substituição das verbas de férias listadas abaixo, criando novos registros para indicação da incidência de IRRF. Para mais informações acesse a documentação técnica. Nota: Se a verba ID 0168 utilizar o código RV_INCIRF = 43, será criada uma verba substituta para o ID 0065, evitando a dedução de INSS no demonstrativo de férias enviado no evento S-1200. "
			@ oSize:GetDimension("MSG","LININI"), oSize:GetDimension("MSG","COLEND")-200 BUTTON oButton1 PROMPT OemToAnsi("Link TDN") SIZE 040, 010 OF oDlg PIXEL	//"Antes de executá-lo, certifique-se de que a tabela S047-Naturezas de Rubrica (em Manutenção de Tabelas) esteja atualizada, possuindo o código 1015."

			aAdd( aHeaderSRV , { STR0454, "TAB_PD",		"@!", nTamVb,	0, 				,	, "C" })		//1-"Cód.Original"
			aAdd( aHeaderSRV , { STR0455, "TAB_CODFOL",	"@!", 4,		0,				,	, "C" })		//2-"Id.Cálculo"
			aAdd( aHeaderSRV , { STR0456, "TAB_DESC",	"@!", 20,		0,				,	, "C" })		//3-"Desc.Verba Original"
			aAdd( aHeaderSRV , { STR0457, "TAB_INCIR","9999", 4,		0,				,	, "C" })		//4-"Inc.IRRF"
			aAdd( aHeaderSRV , { STR0458, "TAB_NAT",  "9999", 4,		0,				,	, "C" })		//5-"Natureza"
			aAdd( aHeaderSRV , { STR0459, "TAB_PDN",	"@!", nTamVb,	0, "fVldPd40F()",	, "C" })		//6-"Novo Cód.Verba"
			aAdd( aHeaderSRV , { STR0460, "TAB_DESCN",	"@!", nTamDesc, 0, "naovazio()",	, "C" })		//7-"Desc.Detalhada-Verba Substituta de Férias"
			aAdd( aHeaderSRV , { STR0461, "TAB_PDA",	"@!", nTamVb,	0, "fVldPd40F(.T.)",, "C" })		//8-"Verba PG MES ANT"
			aAdd( aHeaderSRV , { STR0462, "TAB_DESCA",	"@!", nTamDesc, 0, 				,	, "C" })		//9-"Desc.Detalhada-Verba Subst.Férias Pag.Mês Anterior"

			oGetSRV := MsNewGetDados():New(oSize:GetDimension("GETDADOS","LININI")			,;	// 1  nTop
											oSize:GetDimension("GETDADOS","COLINI")			,;	// 2  nLelft
											oSize:GetDimension("GETDADOS","LINEND") - 10	,;	// 3  nBottom
											oSize:GetDimension("GETDADOS","COLEND")	- 10	,;	// 4  nRright
											GD_UPDATE										,;	// 5  Controle do que podera ser realizado na GetDado - nstyle
											'fVldLin40F'									,;	// 6  Funcao para validar a edicao da linha - ulinhaOK
											'F40FTDOK'										,;	// 7  Funcao para validar todas os registros da GetDados - uTudoOK
											Nil												,;	// 8  cIniCPOS
											aAlterSRV										,;	// 9  aAlter
											0												,;	// 10 nfreeze
											999												,;	// 11 nMax
											Nil												,;	// 12 cFieldOK
											Nil												,;	// 13 usuperdel
											Nil												,;	// 14 udelOK
											@oDlg											,;	// 15 Objeto de dialogo - oWnd
											@aHeaderSRV										,;	// 16 Vetor com Colunas - AparHeader
											@aColsSRV										)	// 17 Vetor com Header - AparCols
			oButton1:bLClicked := { || ShellExecute("open","https://tdn.totvs.com/x/UHeZP","","",1) }
			bSet15 := { || nOpcA := 1 , aColsSRV := oGetSRV:aCols, If(oGetSRV:TudoOK(),oDlg:End(), .F.) }
			bSet24 := { || nOpcA := 0 , oDlg:End() }
		Activate MsDialog oDlg Centered ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

		If nOpcA == 1
			nTotal := SetMaxCodes(nTotal * 2)
			Processa({|| aLogProc := fProcessa(aColsSRV)})
			nTotal := SetMaxCodes(nTotal)
			If Len(aLogProc) > 0
				aAdd( aTitle, STR0463 ) //"Verbas processadas e integradas na execução da substituição"
			Else
				aAdd(aTitle, STR0465 )//"Verbas com a configuração definida para processamento da substituição"

				aAdd( aLogProc,{} )
				aAdd( aLogProc[Len(aLogProc)], Padr(STR0464,16) + Padr(STR0454,15) + Padr(STR0455,15) + STR0456 ) //"Filial###Cod###Id###Desc

				For nX := 1 to Len(aColsSRV)
					aAdd( aLogProc[Len(aLogProc)], Padr(cFilSRV,16) + Padr(aColsSRV[nX,1],15) + Padr(aColsSRV[nX,2],15) + aColsSRV[nX,3] )
				Next
			EndIf
			fMakeLog( aLogProc , aTitle , NIL  , .T. , "GPEA040F" , NIL , NIL, NIL, NIL, .F. )

		EndIf

	EndIf

	(cQrySRV)->(DbCloseArea())
	RestArea(aArea)

Return

/*/{Protheus.doc} fProcessa
Função responsável pelo processamento + barra de progresso
@author isabel.noguti
@since 18.11.2025
@version 1.0
/*/
Static Function fProcessa(aColsSRV)
	Local aStruct	:= FWSX3Util():GetAllFields( "SRV" , .F. )
	Local oModel	:= FwLoadModel("GPEA040")
	Local nX, nY	:= 0
	Local aCabOri	:= {}
	Local xContAux	:= Nil
	Local aLogNew	:= {}
	Local cFilSrv	:= xFilial( "SRV" )
	Local cIgnorar	:= "RV_CODFOL|RV_DESCDET|RV_INCCP|RV_INCFGTS|RV_INCPIS|RV_FGTS|RV_CODMSEG|RV_CONTRAP|RV_SUBST|RV_IMPRIPD|RV_CODABO|RV_CODBASE|RV_CODCOM_|RV_CODCORR|RV_CODDSR|RV_CODMPA|RV_CODMSEG|RV_CODPRTR|RV_CODREMU|RV_FERDESC|RV_FERSEG|RV_GRAMED|RV_HOMOLOG|RV_LCTOP|RV_TAREFA|RV_HECOMIS|RV_COMPL_"

	Default aColsSRV := {}

	ProcRegua(Len(aColsSRV))

	aAdd( aLogNew,{} )			//Cod.Original##Desc##Novo Cod##DescDet##Novo Cod A##DescDetA
	aAdd( aLogNew[Len(aLogNew)], Padr(STR0454,15) + Padr(FWSX3Util():GetDescription("RV_DESC"),25) + Padr(STR0459,16) + Padr(FWSX3Util():GetDescription("RV_DESCDET"), 55) + Padr(STR0461,17) + Padr(STR0462,50) )
	Begin Transaction

		For nX := 1 to Len(aColsSRV)
			If SRV->(dbSeek(xFilial("SRV") + aColsSRV[nX,1]))
				IncProc(STR0473 + aColsSRV[nX,1])//"Processando Verba xxx

				For nY := 1 to Len(aStruct)//posicionando na verba original, pegar o conteudo por array p/criar as novas antes de alterar a original
					If !aStruct[nY] $ cIgnorar
						If !Empty(xContAux := SRV->&(aStruct[nY]))
							aAdd( aCabOri, { aStruct[nY], xContAux, Nil })
						EndIf
					EndIf
				Next

				If fCriaNova(oModel, aCabOri, aColsSRV[nX,3], aColsSRV[nX,6], aColsSRV[nX,7])

					If Empty(aColsSRV[nX,8]) .Or. fCriaNova(oModel, aCabOri, aColsSRV[nX,3], aColsSRV[nX,8], aColsSRV[nX,9], "1015" )

						aCabOri	:= {}
                        aAdd( aCabOri, { "RV_COD"	,	aColsSRV[nX,1], Nil } )

                        //Não é preciso alterar o INCIRF da verba de Id 0065
                        If aColsSRV[nX,1] <> cCondPd
                            aAdd( aCabOri, { "RV_INCIRF",	"9   ",			Nil } )
                        EndIf

                        aAdd( aCabOri, { "RV_FERXML",	aColsSRV[nX,6], Nil } )
						If !Empty(aColsSRV[nX,8])
							aAdd( aCabOri, { "RV_FERAXML", aColsSRV[nX,8], Nil } )
						EndIf

						FWMVCRotAuto(oModel,'SRV', 4,{{'SRVMASTER',aCabOri}},.F.,.T.)
					EndIf
				EndIf

				If lMsErroAuto
					mostraerro()
					aLogNew := {}
					DisarmTransaction()
					Break
				Else
					aAdd( aLogNew[Len(aLogNew)], Padr(SRV->RV_COD,15) + Padr(SRV->RV_DESC,25) + Padr(aColsSRV[nX,6],16) + Padr(aColsSRV[nX,7],55) + Padr(aColsSRV[nX,8],16) + Padr(aColsSRV[nX,9],50))
				EndIf

			EndIf
			aCabOri	:= {}
		Next nX

	End Transaction

	If !lMsErroAuto
		If !Empty(cVigencia)
			dDtMV := StoD(cVigencia + "01")
			If !Empty(cFilSrv)
				FWSX6Util():ReplicateParam( "MV_DTINFER", ({cFilAnt}), FWModeAccess("SRV",2)=="C", FWModeAccess("SRV",3)=="C" )
			EndIf
			putmv("MV_DTINFER", dDtMV)
		EndIf
	EndIf

Return aLogNew

/*/{Protheus.doc} fVldPd40F
Valid campos código das novas verbas
@author isabel.noguti
@since 06.11.2025
@version 1.0
/*/
Function fVldPd40F(lFerA)
 	Local lRet		:= .T.

	Default lFerA	:= .F.

	If !lFerA .Or. Len(GetmemVar("TAB_PDA")) > 0
		lRet := NaoVazio() .And. existChav( "SRV", GetMemVar(ReadVar()) )
	EndIf

Return lRet

/*/{Protheus.doc} fVldLin40F
Valid linha da grid
@author isabel.noguti
@since 06.11.2025
@version S-1.3
/*/
Function fVldLin40F()
	Local lRet := .T.

	If NaoVazio(aCols[n,6])
		If Len(aCols[n,8]) > 0
			lRet := NaoVazio(aCols[n,9])
			If lRet
				If (aCols[n,6] == aCols[n,8])
					lRet := .F.
					Help(,, STR0090,, STR0345, 1,,,,,,, {STR0468})//"A verba não deve ter ela própria como verba do mês seguinte." - Informe códigos distintos
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} f40FTdOK
tudook Validação grid
@author isabel.noguti
@since 06.11.2025
@version S-1.3
/*/
Function f40FTdOK()
	Local cCod 	:= ""
	Local nPos	:= 1
	Local lRet	:= .T.
	Local nLin 	:= 0
	Local nLinA := 0

	For nPos := 1 to Len(aCols)
		cCod := aCols[nPos,6]
		nLin := aScan( aCols, {|x| x[6] == cCod .Or. x[8] == cCod}, nPos + 1)
		If (nLin == 0) .And. !Empty(aCols[nPos,8])
			cCod := aCols[nPos,8]
			nLinA := aScan( aCols, {|x| x[6] == cCod .Or. x[8] == cCod, nPos + 1 })
		EndIf
		If nLin > 0 .Or. nLinA > 0
			lRet := .F.	//"Cod ### informado nas linhas: # x # -
			Help(,, STR0090,, STR0358 + cCod + STR0469 + cValtoChar(nPos) + " x " + cValtoChar(Max(nLin,nLinA)), 1,,,,,,, {STR0468}) //Informe códigos distintos
			Exit
		EndIf
	Next

Return lRet

/*/{Protheus.doc} fCriaNova
Inclui as novas verbas baseadas na original
@author isabel.noguti
@since 11.11.2025
@version S-1.3
/*/
Static Function fCriaNova(oModel, aCabDest, cDesc, cNovoCod, cDescDet, cNatureza)
	Local aAreaSRV	:= SRV->(GetArea())
	Local aCab		:= {}

	Default oModel		:= FwLoadModel("GPEA040")
	Default aCabDest	:= {}
	Default cDesc		:= ""
	Default cNovoCod	:= ""
	Default cDescDet	:= ""
	Default cNatureza	:= ""

	aCab := aClone(aCabDest)

	aAdd( aCab, { "RV_COD",		cNovoCod,	Nil } )
	aAdd( aCab, { "RV_DESC",	cDesc,		Nil } )
	aAdd( aCab, { "RV_DESCDET", cDescDet,	Nil } )
	If !Empty(cNatureza)//FerA
		aAdd( aCab, { "RV_NATUREZ", cNatureza,	Nil } )//ordem dos campos importa
	EndIf
	aAdd( aCab, { "RV_INCFGTS",	"00",		Nil } )
	aAdd( aCab, { "RV_INCCP",	"00",		Nil } )
	aAdd( aCab, { "RV_FGTS"	,	"N",		Nil } )
	FWMVCRotAuto( oModel, 'SRV', 3, {{'SRVMASTER',aCab}}, .F., .T. )

	RestArea(aAreaSRV)

Return !lMsErroAuto


/*/{Protheus.doc} fIgnoraVb
fIgnoraVb Carrega array com verbas que devem ser ignoradas
@author lidio.oliveira
@since 14.01.2026
@version S-1.3
/*/
Function fIgnoraVb()

    Local aArea     := GetArea()
    Local cFilSrv   := xFilial("SRV")
    Local cQryIgn   := GetNextAlias()
    Local aVerbas   := {}

    //Encontra as verbas com os campos RV_FERXML ou RV_FERAXML preenchidos
	BeginSql alias cQryIgn
		SELECT SRV.RV_COD, SRV.RV_FERXML, SRV.RV_FERAXML
		FROM %table:SRV% SRV
		WHERE SRV.RV_FILIAL = %Exp:cFilSrv%
			AND (SRV.RV_FERXML <> ' ' OR SRV.RV_FERAXML <> ' ')
			AND SRV.%NotDel%
		ORDER BY SRV.RV_COD
	EndSql

    //Inclui as verbas dos campos RV_FERXML ou RV_FERAXML para serem ignoradas
    While !(cQryIgn)->(EoF())
        If !Empty((cQryIgn)->RV_FERXML)
            aAdd(aVerbas, (cQryIgn)->RV_FERXML)
        EndIf

        If !Empty((cQryIgn)->RV_FERAXML)
            aAdd(aVerbas, (cQryIgn)->RV_FERAXML)
        EndIf

        (cQryIgn)->(dbskip())
    EndDo

    (cQryIgn)->(DbCloseArea())

    RestArea(aArea)

Return aVerbas


/*/{Protheus.doc} fDif040F
Checa se foi processada substituição de verbas de diferença de férias para avisar sobre correção
@author isabel.noguti
@since 03.02.2026
@version S-1.3
/*/
Function fDif040F()
	Local cQryDif		:= GetNextAlias()
    Local cFilSrv   	:= xFilial("SRV")
	Local lContinua		:= .T.
	Local oDlg			:= Nil
	Local oGroup		:= Nil
	Local oPanel1		:= Nil
	Local oSay1			:= Nil
	Local oButton		:= Nil
	Local oButton1		:= Nil
	Local oButton2		:= Nil
	Local cLinkTDN		:= "https://tdn.totvs.com/pages/releaseview.action?pageId=1041002093"
	Local nTotal		:= 0
	Local aLogProc		:= {}
	Local cIdsDifFer	:= "0088','0089','0090','0091','0092','0093','0094','0095','0096','0097','0098','0099','0227','0228','0838','0839','0840','0841','0101"

	Private lMsErroAuto	:= .F.
	Private cVigencia	:= AnoMes(GetMv("MV_DTINFER", .F., StoD("")))

	If !Empty(cVigencia)

		BeginSql alias cQryDif
			SELECT SRV.RV_COD, SRV.RV_DESC, SRV.RV_FERXML, SRV.RV_FERAXML, SRVSUB.RV_INCIRF
			FROM %table:SRV% SRV
				INNER JOIN %table:SRV% SRVSUB on SRVSUB.RV_FILIAL=SRV.RV_FILIAL
						AND SRVSUB.RV_COD=SRV.RV_FERXML
						AND SRVSUB.%NotDel%
			WHERE SRV.RV_FILIAL = %Exp:cFilSrv%
				AND SRV.RV_CODFOL IN (%Exp:cIdsDifFer%)
				AND SRV.RV_INCIRF = '9   '
				AND SRV.RV_FERXML <> ''
				AND SRV.%NotDel%
		EndSql

		If !(cQryDif)->(EoF())
			Count to nTotal

			DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0477) FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL //"Verbas de diferença de férias substituídas"

			@ 000, 000 MSPANEL oPanel1 SIZE 300, 150 OF oDlg COLORS 0, 16777215 RAISED
			@ 005, 012 GROUP oGroup TO 065, 237 PROMPT OemToAnsi(STR0028) OF oPanel1 COLOR 0, 16777215 PIXEL //"Atenção"
										//"Após análise do ambiente, verificada nesta filial a necessidade de ajuste em XX verba(s) de diferença de férias para efeitos do eSocial."
			@ 014, 017 SAY oSay1 PROMPT OemToAnsi(STR0478 + cValtoChar(nTotal) + STR0479) SIZE 215, 025 OF oPanel1 COLORS 0, 16777215 PIXEL
			@ 030, 017 SAY oSay1 PROMPT OemToAnsi(STR0422) SIZE 215, 025 OF oPanel1 COLORS 0, 16777215 PIXEL //"Para mais informações, consulte a documentação abaixo:"
			@ 038, 017 BUTTON oButton PROMPT cLinkTDN SIZE 175, 014 OF oPanel1 PIXEL
			@ 055, 017 SAY oSay1 PROMPT OemToAnsi(STR0480) SIZE 215, 025 OF oPanel1 COLORS 0, 16777215 PIXEL //"Confirma o processamento?"

			@ 075, 200 BUTTON oButton1 PROMPT OemToAnsi(STR0001) SIZE 037, 012 OF oPanel1 PIXEL//Confirma
			@ 075, 160 BUTTON oButton2 PROMPT OemToAnsi(STR0362) SIZE 037, 012 OF oPanel1 PIXEL//Cancela

			oButton:bLClicked := {|| ShellExecute( "open", cLinkTDN, "", "", 1 ) }
			oButton2:bLClicked := {|| lContinua:=.F., oDlg:End() }
			oButton1:bLClicked := {|| oDlg:End() }

			ACTIVATE MSDIALOG oDlg CENTERED

			If lContinua
				Processa({|| aLogProc := fProcDFer(cQryDif, nTotal, cFilSrv)})

				If Len(aLogProc) > 0
					fMakeLog( aLogProc , {STR0481} , NIL  , .T. , "GP040FDFER" , NIL, NIL, NIL, NIL, .F. )
				EndIf
			EndIf
		EndIf

		(cQryDif)->(dbCloseArea())
		cVigencia := ""
	EndIf

Return

/*/{Protheus.doc} fProcDFer
Função responsável pelo processamento do ajuste das verbas de diferenca + barra de progresso
@author isabel.noguti
@since 09.02.2026
@version 1.0
/*/
Static Function fProcDFer(cQryDif, nTotal, cFilSrv)
	Local oModel	:= FwLoadModel("GPEA040")
	Local nX		:= 0
	Local aCabOri	:= {}
	Local aLogProc	:= {}
	Local aLogErr	:= {}

	Default cQryDif := ""
	Default nTotal	:= 1
	Default cFilSrv	:= xFilial( "SRV" )

	ProcRegua(nTotal)
	(cQryDif)->(DbGoTop())

	aAdd( aLogProc,{} )
	aAdd( aLogProc[1], STR0482 + cVigencia )//"Competência de envio da alteração S-1010: "
	aAdd( aLogProc[1], "")		//Filial##Cod.OriginalxDesc.Verba processada##Incid.IR alterada##Verbas de substituicao desvinculadas
	aAdd( aLogProc[1], Padr(STR0464,10) + Padr(STR0454,13) + Padr(STR0483,25) + Padr(STR0484,20) + STR0485 )

	While !(cQryDif)->(EoF())
		IncProc(STR0473 + (cQryDif)->RV_COD)//"Processando Verba xxx

		aCabOri	:= {}
		aAdd( aCabOri, { "RV_COD"	, (cQryDif)->RV_COD,	Nil } )
		aAdd( aCabOri, { "RV_INCIRF", (cQryDif)->RV_INCIRF,	Nil } )
		aAdd( aCabOri, { "RV_FERXML", "", Nil } )
		If !Empty((cQryDif)->RV_FERAXML)
			aAdd( aCabOri, { "RV_FERAXML", "", Nil } )
		EndIf

		If FWMVCRotAuto(oModel,'SRV', 4,{{'SRVMASTER',aCabOri}},,.T.)
			aAdd( aLogProc[Len(aLogProc)], Padr(cFilSrv,15) + Padr((cQryDif)->RV_COD,10) + Padr((cQryDif)->RV_DESC,25) + Padr((cQryDif)->RV_INCIRF, 20) + Padr((cQryDif)->RV_FERXML,15) + (cQryDif)->RV_FERAXML )
		Else
			aAdd( aLogErr, Padr(cFilSrv,15) + Padr((cQryDif)->RV_COD,13) + oModel:GetErrorMessage()[6])
		EndIf

		(cQryDif)->(dbSkip())
	EndDo

	If Len(aLogErr) > 0
		aAdd( aLogProc[Len(aLogProc)], "")
		aAdd( aLogProc[Len(aLogProc)], STR0486) //"Verbas não processadas x Verifique os registros:"
		For nX := 1 to Len(aLogErr)
			aAdd( aLogProc[Len(aLogProc)], aLogErr[nX] )
		Next
	EndIf

Return aLogProc
