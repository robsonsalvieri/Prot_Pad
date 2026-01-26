#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC041
Monitor de Entregas

@sample
GFEC041()

@author Alan Victor Lamb
@since 08/07/13
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function GFEC041()
	Local nF        := 0
	Local nI        := 0
	Local nCont     := 0
	Local aCampos   := {}
	Local cSem1     := "Sem previsão"
	Local cSem2     := "Em andamento atrasado"
	Local cSem3     := "Concluído atrasado"
	Local cSem4     := "Em andamento no prazo"
	Local cSem5     := "Concluído no prazo"
	Local cSemCor1  := "WHITE"
	Local cSemCor2  := "YELLOW"
	Local cSemCor3  := "RED"
	Local cSemCor4  := "BLUE"
	Local cSemCor5  := "GREEN"

	Private cAliasGW1 	//Alias da tabela temporária com os dados
	Private cFields
	Private oBrowse
	Private oTempTable

	// Parâmetros
	Private cFilIni
	Private cFilFin
	Private cSitDoc
	Private cDtEmisIni
	Private cDtEmisFin
	Private cDtPrvSaIni
	Private cDtPrvSaFin
	Private cDtSaIni
	Private cDtSaFin
	Private cDtPrvEnIni
	Private cDtPrvEnFin
	Private cDtEnIni
	Private cDtEnFin
	Private cSitEnt
	Private cTrpIni
	Private cTrpFin

	Private aCpoPE    := {}
	Private lGFEC0412 := ExistBlock("GFEC0412")
	Private s_MULFIL  := SuperGetMV("MV_MULFIL",.F.,"2")

	If !CarrParam()
		Return
	EndIf

	// Cria tabela temporária e carrega os dados
	cAliasGW1 := CriaTab()
	Processa({|| ProcRegua(0), CarregaDados()}, "Carregando", "Aguarde, carregando dados...",.F.)

	aCampos := {{"Filial"  			, "GW1_FILIAL", "C", 04, 0, "@!"},;
			    {"Emissor"  		, "GW1_NMEMIS", "C", 15, 0, "@!"},;
				{"Tipo"				, "GW1_CDTPDC", "C", 05, 0, "@!"},;
				{"Série"			, "GW1_SERDC" , "C", 03, 0, "!!!"},;
				{"Nr Documento"		, "GW1_NRDC"  , "C", 09, 0, "@!"},;
				{"Dt Emissão"		, "GW1_DTEMIS", "D", 08, 0, ""},;
				{"Prev Saída"		, "GW1_DTPSAI", "D", 08, 0, ""},;
				{"Saída Real"		, "GW1_DTSAI" , "D", 08, 0, ""},;
				{"Prev Entrega Emb" , "GW1_DTPENT", "D", 08, 0, ""},;
				{"Prev Entrega Trp"	, "DTPENT"	  , "D", 08, 0, ""},;
				{"Entrega Real"		, "DTENT"	  , "D", 08, 0, ""},;
				{"Cidade Dest"		, "GU7_NMCID" , "C", 15, 0, "@!"},;
				{"UF Dest"			, "GU7_CDUF"  , "C", 02, 0, "@!"},;
				{"Qtd Ocor"			, "QTD_OCO"	  , "N", 10, 0, ""},;
				{"Transportador"	, "NMEMIT_1"  , "C", 15, 0, "@!"},;
				{"Redespachante 1"	, "NMEMIT_2"  , "C", 15, 0, "@!"},;
				{"Redespachante 2"	, "NMEMIT_3"  , "C", 15, 0, "@!"},;
				{"Cod Rastreamento"	, "GWN_RASTR" , "C", 10, 0, "@!"},;
				{"Romaneio"			, "GW1_NRROM" , "C", 10, 0, "@!"}}
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		aadd(aCampos, {"Fil.Romaneio", "GW1_FILROM", "C", 10, 0, "@!"})		
	EndIf

	If lGFEC0412
		aCpoPE := ExecBlock("GFEC0412",.F.,.F.)
		If ValType(aCpoPE) == 'A' .And. !Empty(aCpoPE)
			nF := Len(aCpoPE)
			For nI := 1 To nF
				Aadd(aCampos,aCpoPE[nI])
			Next nI
		EndIf
	EndIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasGW1)					   		// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEC041")			   			// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Monitor de Entregas")		// Descrição do browse
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetLocate()
	oBrowse:DisableDetails()
	oBrowse:DisableConfig()
	oBrowse:AddLegend("GW1_SIT=='1'", "WHITE" ,"Digitado ","SIT")
	oBrowse:AddLegend("GW1_SIT=='2'", "YELLOW","Bloqueado","SIT")
	oBrowse:AddLegend("GW1_SIT=='3'", "GRAY"  ,"Liberado ","SIT")
	oBrowse:AddLegend("GW1_SIT=='4'", "BLUE"  ,"Embarcado","SIT")
	oBrowse:AddLegend("GW1_SIT=='5'", "GREEN" ,"Entregue ","SIT")
	oBrowse:AddLegend("GW1_SIT=='6'", "ORANGE","Retornado","SIT")
	oBrowse:AddLegend("GW1_SIT=='7'", "RED"   ,"Cancelado","SIT")
	oBrowse:AddLegend("GW1_SIT=='8'", "BLACK" ,"Sinistrado","SIT")

	For nCont := 1 To Len(aCampos)
		oBrowse:AddColumn({aCampos[nCont][1], &("{|| (cAliasGW1)->" + aCampos[nCont][2] + "}"),aCampos[nCont][3],aCampos[nCont][6],1,aCampos[nCont][4],aCampos[nCont][5],.T.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.T.,{} } )

		If nCont == 6 // Semáforo Expedição
			oBrowse:AddLegend(CriaRegraSemaforo(1,"GW1_DTPSAI","GW1_DTSAI"),cSemCor1,cSem1,"EXP")
			oBrowse:AddLegend(CriaRegraSemaforo(2,"GW1_DTPSAI","GW1_DTSAI"),cSemCor2,cSem2,"EXP")
			oBrowse:AddLegend(CriaRegraSemaforo(3,"GW1_DTPSAI","GW1_DTSAI"),cSemCor3,cSem3,"EXP")
			oBrowse:AddLegend(CriaRegraSemaforo(4,"GW1_DTPSAI","GW1_DTSAI"),cSemCor4,cSem4,"EXP")
			oBrowse:AddLegend(CriaRegraSemaforo(5,"GW1_DTPSAI","GW1_DTSAI"),cSemCor5,cSem5,"EXP")
		ElseIf nCont == 8 // Semáforo Comercial
			oBrowse:AddLegend(CriaRegraSemaforo(1,"GW1_DTPENT","DTENT"),cSemCor1,cSem1,"COM")
			oBrowse:AddLegend(CriaRegraSemaforo(2,"GW1_DTPENT","DTENT"),cSemCor2,cSem2,"COM")
			oBrowse:AddLegend(CriaRegraSemaforo(3,"GW1_DTPENT","DTENT"),cSemCor3,cSem3,"COM")
			oBrowse:AddLegend(CriaRegraSemaforo(4,"GW1_DTPENT","DTENT"),cSemCor4,cSem4,"COM")
			oBrowse:AddLegend(CriaRegraSemaforo(5,"GW1_DTPENT","DTENT"),cSemCor5,cSem5,"COM")
		ElseIf nCont == 9 // Semáforo Logística
			oBrowse:AddLegend(CriaRegraSemaforo(1,"DTPENT","DTENT"),cSemCor1,cSem1,"LOG")
			oBrowse:AddLegend(CriaRegraSemaforo(2,"DTPENT","DTENT"),cSemCor2,cSem2,"LOG")
			oBrowse:AddLegend(CriaRegraSemaforo(3,"DTPENT","DTENT"),cSemCor3,cSem3,"LOG")
			oBrowse:AddLegend(CriaRegraSemaforo(4,"DTPENT","DTENT"),cSemCor4,cSem4,"LOG")
			oBrowse:AddLegend(CriaRegraSemaforo(5,"DTPENT","DTENT"),cSemCor5,cSem5,"LOG")
		ElseIf nCont == 14 // Semáforo Trecho 1
			oBrowse:AddLegend("PAGAR_1=='2'","BLACK","Trecho por conta do cliente","T1")
			oBrowse:AddLegend(CriaRegraSemaforo(1,"DTPENT_1","DTENT_1"),cSemCor1,cSem1,"T1")
			oBrowse:AddLegend(CriaRegraSemaforo(2,"DTPENT_1","DTENT_1"),cSemCor2,cSem2,"T1")
			oBrowse:AddLegend(CriaRegraSemaforo(3,"DTPENT_1","DTENT_1"),cSemCor3,cSem3,"T1")
			oBrowse:AddLegend(CriaRegraSemaforo(4,"DTPENT_1","DTENT_1"),cSemCor4,cSem4,"T1")
			oBrowse:AddLegend(CriaRegraSemaforo(5,"DTPENT_1","DTENT_1"),cSemCor5,cSem5,"T1")
		ElseIf nCont == 15 // Semáforo Trecho 2
			oBrowse:AddLegend("!Empty(CDTRP_2) .AND. PAGAR_2=='2'","BLACK","Trecho por conta do cliente","T2")
			oBrowse:AddLegend("Empty(CDTRP_2)   .OR. Empty(DTPENT_2)","WHITE","Sem trecho de redespacho 1 ou sem previsão","T2")
			oBrowse:AddLegend(CriaRegraSemaforo(2,"DTPENT_2","DTENT_2"),cSemCor2,cSem2,"T2")
			oBrowse:AddLegend(CriaRegraSemaforo(3,"DTPENT_2","DTENT_2"),cSemCor3,cSem3,"T2")
			oBrowse:AddLegend(CriaRegraSemaforo(4,"DTPENT_2","DTENT_2"),cSemCor4,cSem4,"T2")
			oBrowse:AddLegend(CriaRegraSemaforo(5,"DTPENT_2","DTENT_2"),cSemCor5,cSem5,"T2")
		ElseIf nCont == 16 // Semáforo Trecho 3
			oBrowse:AddLegend("!Empty(CDTRP_3) .AND. PAGAR_3=='2'","BLACK","Trecho por conta do cliente","T3")
			oBrowse:AddLegend("Empty(CDTRP_3)   .OR. Empty(DTPENT_3)","WHITE","Sem trecho de redespacho 2 ou sem previsão","T3")
			oBrowse:AddLegend(CriaRegraSemaforo(2,"DTPENT_3","DTENT_3"),cSemCor2,cSem2,"T3")
			oBrowse:AddLegend(CriaRegraSemaforo(3,"DTPENT_3","DTENT_3"),cSemCor3,cSem3,"T3")
			oBrowse:AddLegend(CriaRegraSemaforo(4,"DTPENT_3","DTENT_3"),cSemCor4,cSem4,"T3")
			oBrowse:AddLegend(CriaRegraSemaforo(5,"DTPENT_3","DTENT_3"),cSemCor5,cSem5,"T3")
		EndIf
	Next nCont

	oBrowse:Activate()

	GFEDelTab(cAliasGW1)
Return

Static Function CriaRegraSemaforo(nRegra,cCampoPrev,cCampoEnt)
	Local cRet := ""

	Do Case
		Case nRegra == 1
			cRet := "Empty(" + cCampoPrev+ ")"
		Case nRegra == 2
			cRet := "!Empty(" + cCampoPrev + ") .AND. Empty(" + cCampoEnt + ") .AND. " + cCampoPrev+ " < DATE()"
		Case nRegra == 3
			cRet := "!Empty(" + cCampoPrev + ") .AND. !Empty(" + cCampoEnt + ") .AND. " + cCampoPrev+ " < " + cCampoEnt
		Case nRegra == 4
			cRet := "!Empty(" + cCampoPrev + ") .AND. Empty(" + cCampoEnt + ")  .AND. " + cCampoPrev+ " >= DATE()"
		Case nRegra == 5
			cRet := "!Empty(" + cCampoPrev + ") .AND. !Empty(" + cCampoEnt + ") .AND. " + cCampoPrev+ " >= " + cCampoEnt
	EndCase

Return cRet

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Atualizar" 				 ACTION "GFEC041OPT(0)" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Doc Carga" 		 ACTION "GFEC041OPT(1)" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Cliente" 		 ACTION "GFEC041OPT(2)" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Transportador" 	 ACTION "GFEC041OPT(3)"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Redespachante 1" ACTION "GFEC041OPT(4)"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Redespachante 2" ACTION "GFEC041OPT(5)"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Romaneio" 		 ACTION "GFEC041OPT(6)"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Registrar Ocorrência" 	 ACTION "GFEC041OPT(7)"	OPERATION 3 ACCESS 0

	//Ponto de Entrada
	If ExistBlock("GFEC0411")
		aRotAdic := ExecBlock("GFEC0411",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic, {|x| AAdd(aRotina ,x)})
		EndIf
	EndIf

Return aRotina

//
// Função responsável pelas ações relacionadas do browse
//
Function GFEC041OPT(nOption)
	Local cFilAntB

	Do Case
		Case nOption == 0 // Atualizar
			If CarrParam()
				Processa({|| CarregaDados()}, "Carregando", "Aguarde, carregando dados...",.F.)
				oBrowse:UpdateBrowse()
			EndIf

		Case nOption == 1 // Consultar Doc Carga
			If PosGW1()
				FWExecView("Visualizar", "GFEC040", 1,, {||.T.})
			EndIf

		Case nOption == 2 // Consultar Cliente
			ConsGU3((cAliasGW1)->GW1_CDDEST)

		Case nOption == 3 // Consultar Transportador
			ConsGU3((cAliasGW1)->CDTRP_1)

		Case nOption == 4 // Consultar Redespachante 1
			If !Empty((cAliasGW1)->CDTRP_2)
				ConsGU3((cAliasGW1)->CDTRP_2)
			Else
				MsgStop("O Documento de Carga não possui Redespachante 1.")
			EndIf

		Case nOption == 5 // Consultar Redespachante 2
			If !Empty((cAliasGW1)->CDTRP_3)
				ConsGU3((cAliasGW1)->CDTRP_3)
			Else
				MsgStop("O Documento de Carga não possui Redespachante 2.")
			EndIf

		Case nOption == 6 // Consultar Romaneio
			If Empty((cAliasGW1)->GW1_NRROM)
				MsgStop( "O Documento de Carga precisa estar vinculado a um Romaneio.")
			Else
				dbSelectArea("GWN")
				GWN->(dbSetOrder(1))
				If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
					GWN->(dbSeek((cAliasGW1)->(GW1_FILROM+GW1_NRROM)))
				Else
					GWN->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_NRROM)))
				EndIf
				FWExecView("Visualizar", "GFEC050", 1,, {||.T.})
			EndIf

		Case nOption == 7 // Registrar Ocorrência
			If PosGW1()
				cFilAntB := cFilAnt
				cFilAnt  := (cAliasGW1)->GW1_FILIAL
				GFEA044OCO()
				cFilAnt := cFilAntB
			EndIf
	EndCase
Return Nil

//
// Preenche as variáveis do programa com respostas do pergunte
//
Static Function CarrParam()
	Local lRet := .F.

	lRet := Pergunte("GFEC041",.T.)
	If lRet
		cFilIni 	:= MV_PAR01
		cFilFin 	:= MV_PAR02
		cSitDoc 	:= MV_PAR03
		cDtEmisIni  := If(!Empty(MV_PAR04), DtoS(MV_PAR04),Space(8))
		cDtEmisFin  := If(!Empty(MV_PAR05), DtoS(MV_PAR05),Space(8))
		cDtPrvSaIni := If(!Empty(MV_PAR06), DtoS(MV_PAR06),Space(8))
		cDtPrvSaFin := If(!Empty(MV_PAR07), DtoS(MV_PAR07),Space(8))
		cDtSaIni 	:= If(!Empty(MV_PAR08), DtoS(MV_PAR08),Space(8))
		cDtSaFin 	:= If(!Empty(MV_PAR09), DtoS(MV_PAR09),Space(8))
		cDtPrvEnIni := If(!Empty(MV_PAR10), DtoS(MV_PAR10),Space(8))
		cDtPrvEnFin := If(!Empty(MV_PAR11), DtoS(MV_PAR11),Space(8))
		cDtEnIni 	:= If(!Empty(MV_PAR12), DtoS(MV_PAR12),Space(8))
		cDtEnFin 	:= If(!Empty(MV_PAR13), DtoS(MV_PAR13),Space(8))
		cSitEnt 	:= MV_PAR14
		cTrpIni 	:= MV_PAR15
		cTrpFin 	:= MV_PAR16
	EndIf
Return lRet

//
// Posiciona em registro da GW1 conforme item do browse
//
Static Function PosGW1()
	dbSelectArea("GW1")
	GW1->(dbSetOrder(1))
Return GW1->(dbSeek((cAliasGW1)->(GW1_FILIAL+GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC)))

//
// Executa consulta de Emitente
//
Static Function ConsGU3(cCdEmit)
	dbSelectArea("GU3")
	GU3->(dbSetOrder(1))
	GU3->(dbSeek(xFilial("GU3") + cCdEmit))
	FWExecView("Visualizar", "GFEA015", 1,, {||.T.})
Return Nil

//
// Carrega dados do browse principal
//
Static Function CarregaDados()
	Local cQuery    := ""
	Local lGFEC0413 := ExistBlock("GFEC0413")

	Private cTmp

	dbSelectArea(cAliasGW1)
	ZAP

	cQuery := "INSERT INTO " + oTempTable:GetRealName()
	cQuery += " (" + cFields + ") "

	cQuery += "	SELECT GW1.GW1_FILIAL AS GW1_FILIAL,"
	cQuery += "		   GW1.GW1_CDTPDC AS GW1_CDTPDC,"
	cQuery += "        GW1.GW1_EMISDC AS GW1_EMISDC,"
	cQuery += "		   GU3EMI.GU3_NMEMIT AS GW1_NMEMIS,"
	cQuery += "		   GW1.GW1_SERDC AS GW1_SERDC,"
	cQuery += "		   GW1.GW1_NRDC AS GW1_NRDC,"
	cQuery += "		   GW1.GW1_DTEMIS AS GW1_DTEMIS,"
	cQuery += "		   GW1.GW1_DTPSAI AS GW1_DTPSAI,"
	cQuery += "		   GW1.GW1_DTSAI AS GW1_DTSAI,"
	cQuery += "		   GW1.GW1_DTPENT AS GW1_DTPENT,"
	cQuery += "		   GW1.GW1_CDDEST AS GW1_CDDEST,"
	cQuery += "		   GU7.GU7_NMCID AS GU7_NMCID,"
	cQuery += "		   GU7.GU7_CDUF AS GU7_CDUF,"
	cQuery += "		   GWUFIN.GWU_DTPENT AS DTPENT,"
	cQuery += "		   GWUFIN.GWU_DTENT AS DTENT,"
	cQuery += "		   GWU1.GWU_CDTRP AS CDTRP_1,"
	cQuery += "		   CASE WHEN TRP1.GU3_NMEMIT IS NULL THEN ' ' ELSE TRP1.GU3_NMEMIT END AS NMEMIT_1,"
	cQuery += "		   CASE WHEN GWU1.GWU_PAGAR IS NULL THEN ' ' ELSE GWU1.GWU_PAGAR END AS PAGAR_1,"
	cQuery += "		   CASE WHEN GWU1.GWU_DTPENT IS NULL THEN ' ' ELSE GWU1.GWU_DTPENT END AS DTPENT_1,"
	cQuery += "		   CASE WHEN GWU1.GWU_DTENT IS NULL THEN ' ' ELSE GWU1.GWU_DTENT END AS DTENT_1,"
	cQuery += "		   CASE WHEN GWU2.GWU_CDTRP IS NULL THEN ' ' ELSE GWU2.GWU_CDTRP END AS CDTRP_2,"
	cQuery += "		   CASE WHEN TRP2.GU3_NMEMIT IS NULL THEN ' ' ELSE TRP2.GU3_NMEMIT END AS NMEMIT_2,"
	cQuery += "		   CASE WHEN GWU2.GWU_PAGAR IS NULL THEN ' ' ELSE GWU2.GWU_PAGAR END AS PAGAR_2,"
	cQuery += "		   CASE WHEN GWU2.GWU_DTPENT IS NULL THEN ' ' ELSE GWU2.GWU_DTPENT END AS DTPENT_2,"
	cQuery += "		   CASE WHEN GWU2.GWU_DTENT IS NULL THEN ' ' ELSE GWU2.GWU_DTENT END AS DTENT_2,"
	cQuery += "		   CASE WHEN GWU3.GWU_CDTRP IS NULL THEN ' ' ELSE GWU3.GWU_CDTRP END AS CDTRP_3,"
	cQuery += "		   CASE WHEN TRP3.GU3_NMEMIT IS NULL THEN ' ' ELSE TRP3.GU3_NMEMIT END AS NMEMIT_3,"
	cQuery += "		   CASE WHEN GWU3.GWU_PAGAR IS NULL THEN ' ' ELSE GWU3.GWU_PAGAR END AS PAGAR_3,"
	cQuery += "		   CASE WHEN GWU3.GWU_DTPENT IS NULL THEN ' ' ELSE GWU3.GWU_DTPENT END AS DTPENT_3,"
	cQuery += "		   CASE WHEN GWU3.GWU_DTENT IS NULL THEN ' ' ELSE GWU3.GWU_DTENT END AS DTENT_3,"
	cQuery += "		   CASE WHEN OCO.QTD_OCO IS NULL THEN 0 ELSE OCO.QTD_OCO END AS QTD_OCO,"
	cQuery += "		   CASE WHEN GWN.GWN_RASTR IS NULL THEN ' ' ELSE GWN.GWN_RASTR END AS GWN_RASTR,"
 
	If lGFEC0413
		cQryPE := ExecBlock("GFEC0413",.F.,.F.)
		If ValType(cQryPE) == "C" .And. !Empty(cQryPE)
			cQuery += cQryPE
		EndIf
	EndIf

	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += " GW1.GW1_FILROM AS GW1_FILROM,"
	EndIf
	cQuery += "		   GW1.GW1_NRROM AS GW1_NRROM,"
	cQuery += "		   GW1.GW1_SIT AS GW1_SIT"

	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	 INNER JOIN " + RetSQLName("GV5") + " GV5"
	cQuery += "     ON GV5.GV5_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	   AND GV5.GV5_SENTID <> '1'"
	cQuery += "	   AND GV5.GV5_SENTID <> '4'"
	cQuery += "	   AND GV5.D_E_L_E_T_ = ' '"
	cQuery += "	 INNER JOIN " + RetSQLName("GU3") + " GU3"
	cQuery += "     ON GU3.GU3_CDEMIT = GW1.GW1_CDDEST"
	cQuery += "	   AND GU3.D_E_L_E_T_ = ' '"
	cQuery += "	 INNER JOIN " + RetSQLName("GU3") + " GU3EMI"
	cQuery += "     ON GU3EMI.GU3_CDEMIT = GW1.GW1_EMISDC"
	cQuery += "    AND GU3EMI.D_E_L_E_T_ = ' '"
	cQuery += "	 INNER JOIN " + RetSQLName("GU7") + " GU7"
	cQuery += "	    ON GU7.GU7_NRCID = GU3.GU3_NRCID"
	cQuery += "    AND GU7.D_E_L_E_T_ = ' '"
	cQuery += "	 INNER JOIN " + RetSQLName("GWU") + " GWU1"
	cQuery += "	    ON GWU1.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += "	   AND GWU1.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	   AND GWU1.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	   AND GWU1.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += "	   AND GWU1.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	   AND GWU1.GWU_SEQ = '01'"
	cQuery += "	   AND GWU1.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN " + RetSQLName("GWU") + " GWU2"
	cQuery += "     ON GWU2.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += "    AND GWU2.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	   AND GWU2.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "    AND GWU2.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += "    AND GWU2.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "    AND GWU2.GWU_SEQ = '02'"
	cQuery += "    AND GWU2.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN " + RetSQLName("GWU") + " GWU3"
	cQuery += "	    ON GWU3.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += "    AND GWU3.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "    AND GWU3.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "    AND GWU3.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += "    AND GWU3.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "    AND GWU3.GWU_SEQ = '03'"
	cQuery += "	   AND GWU3.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN " + RetSQLName("GU3") + " TRP1"
	cQuery += "     ON TRP1.GU3_CDEMIT = GWU1.GWU_CDTRP"
	cQuery += "    AND TRP1.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN " + RetSQLName("GU3") + " TRP2"
	cQuery += "     ON TRP2.GU3_CDEMIT = GWU2.GWU_CDTRP"
	cQuery += "	   AND TRP2.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN " + RetSQLName("GU3") + " TRP3"
	cQuery += "	    ON TRP3.GU3_CDEMIT = GWU3.GWU_CDTRP"
	cQuery += "	   AND TRP3.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN ( "
	cQuery += "	   			SELECT GWU1.GWU_FILIAL, GWU1.GWU_CDTPDC, GWU1.GWU_EMISDC, GWU1.GWU_SERDC, GWU1.GWU_NRDC, GWU1.GWU_DTENT, GWU1.GWU_DTPENT"
	cQuery += "		  		FROM " + RetSQLName("GWU") + " GWU1"
	cQuery += "		 		INNER JOIN ("
	cQuery += "		 					SELECT GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, MAX(GWU_SEQ) GWU_SEQ"
	cQuery += "		 	  				FROM " + RetSQLName("GWU")
	cQuery += "		 	 				WHERE D_E_L_E_T_ = ' '"
	cQuery += "		 	   				AND GWU_PAGAR = '1'"
	cQuery += "		     				GROUP BY GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC"
	cQuery += "		 					) GWU2"
	cQuery += "		 		ON GWU1.GWU_FILIAL = GWU2.GWU_FILIAL"
	cQuery += "			   	AND GWU1.GWU_CDTPDC = GWU2.GWU_CDTPDC"
	cQuery += "			   	AND GWU1.GWU_EMISDC = GWU2.GWU_EMISDC"
	cQuery += "			   	AND GWU1.GWU_SERDC = GWU2.GWU_SERDC"
	cQuery += "			   	AND GWU1.GWU_NRDC = GWU2.GWU_NRDC"
	cQuery += "			   	AND GWU1.GWU_SEQ = GWU2.GWU_SEQ"
	cQuery += "				WHERE GWU1.D_E_L_E_T_ = ' '"
	cQuery += "		  		AND GWU1.GWU_PAGAR = '1'"
	cQuery += "	  			) GWUFIN"
	cQuery += "	  	ON GWUFIN.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += "	   AND GWUFIN.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "	   AND GWUFIN.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "	   AND GWUFIN.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += "	   AND GWUFIN.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "	  LEFT JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		cQuery += "	ON GWN.GWN_FILIAL = GW1.GW1_FILROM"
	Else
		cQuery += "	ON GWN.GWN_FILIAL = GW1.GW1_FILIAL"
	EndIf
	cQuery += "    AND GWN.GWN_NRROM = GW1.GW1_NRROM"
	cQuery += "	   AND GWN.D_E_L_E_T_ = ' '"
	cQuery += "	  LEFT JOIN ("
	cQuery += "	  			SELECT GWL_NRDC, GWL_FILDC, GWL_EMITDC, GWL_SERDC, GWL_TPDC, COUNT(*) QTD_OCO"
	cQuery += "		  		FROM " + RetSQLName("GWL")
	cQuery += "		 		WHERE D_E_L_E_T_ = ' '"
	cQuery += "		 		GROUP BY GWL_NRDC, GWL_FILDC, GWL_EMITDC, GWL_SERDC, GWL_TPDC"
	cQuery += "	  			) OCO"
	cQuery += "     ON GWL_NRDC = GW1.GW1_NRDC"
	cQuery += "	   AND GWL_FILDC = GW1.GW1_FILIAL"
	cQuery += "	   AND GWL_EMITDC = GW1.GW1_EMISDC"
	cQuery += "	   AND GWL_SERDC = GW1.GW1_SERDC"
	cQuery += "	   AND GWL_TPDC = GW1.GW1_CDTPDC"
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ' '"
	cQuery += "	   AND GW1.GW1_FILIAL >= '" + cFilIni + "' AND GW1.GW1_FILIAL <= '" + cFilFin + "'" 				// Faixa filiais
	cQuery += "	   AND GW1.GW1_DTEMIS >= '" + cDtEmisIni + "' AND GW1.GW1_DTEMIS <= '" + cDtEmisFin + "'"			// Faixa de data de emissão
	cQuery += "	   AND GW1.GW1_DTPSAI >= '" + cDtPrvSaIni + "' AND GW1.GW1_DTPSAI <= '" + cDtPrvSaFin + "'"			// Faixa data previsão de saída
	cQuery += "	   AND GW1.GW1_DTSAI >= '" + cDtSaIni + "' AND GW1.GW1_DTSAI <= '" + cDtSaFin + "'"					// Faixa data de saída
	cQuery += "	   AND GWUFIN.GWU_DTPENT >= '" + cDtPrvEnIni + "' AND GWUFIN.GWU_DTPENT <= '" + cDtPrvEnFin + "'"	// Faixa data previsão de entrega
	
	If !Empty(cSitDoc) .And. cSitDoc == 4 // Entregue
		cQuery += "	   AND GWUFIN.GWU_DTENT >= '" + cDtEnIni + "' AND GWUFIN.GWU_DTENT <= '" + cDtEnFin + "'"			// Faixa data de entrega
	Else
		cQuery += "	   AND ((GWUFIN.GWU_DTENT >= '" + cDtEnIni + "' AND GWUFIN.GWU_DTENT <= '" + cDtEnFin + "') OR GWUFIN.GWU_DTENT = '')"			// Faixa data de entrega
	EndIf
	
	//Faixa de transportadores
	cQuery += "		AND ((GWU1.GWU_CDTRP >= '"+cTrpIni+"' AND GWU1.GWU_CDTRP <= '"+cTrpFin+"') OR"
   	cQuery += "			 (GWU2.GWU_CDTRP >= '"+cTrpIni+"' AND GWU2.GWU_CDTRP <= '"+cTrpFin+"') OR"
   	cQuery += "			 (GWU3.GWU_CDTRP >= '"+cTrpIni+"' AND GWU3.GWU_CDTRP <= '"+cTrpFin+"'))"

	// Situação Documento
	If !Empty(cSitDoc) .And. cSitDoc != 1 // Todos
		Do Case
			Case cSitDoc == 2 // Embarcado
				cQuery += " AND GW1.GW1_SIT = '4' AND GW1.GW1_DTSAI = ''"
			Case cSitDoc == 3 // Em trânsito
				cQuery += " AND GW1.GW1_SIT = '4' AND GW1.GW1_DTSAI != ''"
			Case cSitDoc == 4 // Entregue
				cQuery += " AND GW1.GW1_SIT = '5'"
		EndCase
	EndIf

	// Situação Entrega
	If !Empty(cSitEnt) .And. cSitEnt != 1 // Todas
		Do Case
			Case cSitEnt == 2 // Atrasos embarcador
				cQuery += " AND GW1.GW1_DTPENT != ' '"
				cQuery += " AND GW1.GW1_DTPENT < GWUFIN.GWU_DTENT"
			Case cSitEnt == 3 // Atrasos transportador
				cQuery += " AND GWUFIN.GWU_DTPENT != ' '"
				cQuery += " AND GWUFIN.GWU_DTPENT < GWUFIN.GWU_DTENT"
		EndCase
	EndIf

	//Envia o insert into para o banco de dados, portanto toda a cópia é feita pelo banco de dados, com grande performance!
	If TCSqlExec(cQuery) >= 0
		cAlias := oTempTable:GetAlias()

		(cAlias)->(DBGoTop())
	EndIf

Return Nil

//---------------------------------------------------------------------------------------------------
/*CriaTab
Cria a estrutura da tabela
Uso restrito

@sample
CriaTab()

@author Alan Victor Lamb
@since 08/07/13
@version 1.0 
/*///------------------------------------------------------------------------------------------------
Static Function CriaTab()
	Local nF        := 0
	Local nI        := 0
	Local cAlias    := ""
	Local aCampos   := {}
	Local lGFEC0414 := ExistBlock("GFEC0414")

	Default cFields := ""

	aCampos := {{"GW1_FILIAL", "C", TamSX3("GW1_FILIAL")[1], 0},;
				{"GW1_CDTPDC", "C", TamSX3("GW1_CDTPDC")[1], 0},;
				{"GW1_EMISDC", "C", TamSX3("GW1_EMISDC")[1], 0},;
				{"GW1_NMEMIS", "C", TamSX3("GU3_NMEMIT")[1], 0},;
				{"GW1_SERDC" , "C", TamSX3("GW1_SERDC")[1] , 0},;
				{"GW1_NRDC"	 , "C", TamSX3("GW1_NRDC")[1]  , 0},;
				{"GW1_DTEMIS", "D", TamSX3("GW1_DTEMIS")[1], 0},;
				{"GW1_DTPSAI", "D", TamSX3("GW1_DTPSAI")[1], 0},;
				{"GW1_DTSAI" , "D", TamSX3("GW1_DTSAI")[1] , 0},;
				{"GW1_DTPENT", "D", TamSX3("GW1_DTPENT")[1], 0},;
				{"GW1_CDDEST", "C", TamSX3("GW1_CDDEST")[1], 0},;
				{"GU7_NMCID" , "C", TamSX3("GU7_NMCID")[1] , 0},;
				{"GU7_CDUF"	 , "C", TamSX3("GU7_CDUF")[1]  , 0},;
				{"DTPENT"	 , "D", TamSX3("GWU_DTPENT")[1], 0},;
				{"DTENT"	 , "D", TamSX3("GWU_DTENT")[1] , 0},;
				{"CDTRP_1"	 , "C", TamSX3("GWU_CDTRP")[1] , 0},;
				{"NMEMIT_1"	 , "C", TamSX3("GU3_NMEMIT")[1], 0},;
				{"PAGAR_1"	 , "C", TamSX3("GWU_PAGAR")[1] , 0},;
				{"DTPENT_1"	 , "D", TamSX3("GWU_DTPENT")[1], 0},;
				{"DTENT_1"	 , "D", TamSX3("GWU_DTENT")[1] , 0},;
				{"CDTRP_2"	 , "C", TamSX3("GWU_CDTRP")[1] , 0},;
				{"NMEMIT_2"	 , "C", TamSX3("GU3_NMEMIT")[1], 0},;
				{"PAGAR_2"	 , "C", TamSX3("GWU_PAGAR")[1] , 0},;
				{"DTPENT_2"	 , "D", TamSX3("GWU_DTPENT")[1], 0},;
				{"DTENT_2"	 , "D", TamSX3("GWU_DTENT")[1] , 0},;
				{"CDTRP_3"	 , "C", TamSX3("GWU_CDTRP")[1] , 0},;
				{"NMEMIT_3"	 , "C", TamSX3("GU3_NMEMIT")[1], 0},;
				{"PAGAR_3"	 , "C", TamSX3("GWU_PAGAR")[1] , 0},;
				{"DTPENT_3"	 , "D", TamSX3("GWU_DTPENT")[1], 0},;
				{"DTENT_3"	 , "D", TamSX3("GWU_DTENT")[1] , 0},;
				{"QTD_OCO" 	 , "N", 10                     , 0},;
				{"GWN_RASTR" , "C", TamSX3("GWN_RASTR")[1] , 0}}
	
	If GFXCP1212210('GW1_FILROM') .And. s_MULFIL == "1"
		aadd(aCampos, {"GW1_FILROM", "C", TamSX3("GW1_FILROM")[1] , 0})
	EndIf

	If lGFEC0414
		aCpoPE := ExecBlock("GFEC0414",.F.,.F.)
		If ValType(aCpoPE) == 'A' .And. !Empty(aCpoPE)
			nF := Len(aCpoPE)
			For nI := 1 To nF
				Aadd(aCampos,aCpoPE[nI])
			Next nI
		EndIf
	EndIf

 	aadd(aCampos, {"GW1_NRROM", "C", TamSX3("GW1_NRROM")[1], 0})
	aadd(aCampos, {"GW1_SIT"  , "C", TamSX3("GW1_SIT")[1]  , 0})

	cAlias := GFECriaTab({aCampos,{"GW1_CDTPDC+GW1_EMISDC+GW1_SERDC+GW1_NRDC+DTOS(GW1_DTEMIS)"}}, @oTempTable)

	//Pega todos os campos para efetuar a cópia dos dados
	For nI := 1 To Len(aCampos)
		cFields += aCampos[nI][1] + ","		//Nome do campo
	Next

	cFields := Left(cFields, Len(cFields) -1) //Remover a ultima vírgula

Return cAlias
