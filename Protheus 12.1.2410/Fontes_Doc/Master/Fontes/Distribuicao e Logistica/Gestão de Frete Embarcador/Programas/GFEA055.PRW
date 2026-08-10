#INCLUDE "GFEA055.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __lLogIntP := IIF(SuperGetMv("MV_GFELPR",,'1') == '2',.F., .T.)//Indica se será gerado ou não o log da integração com o ERP Protheus

// Constante usada na função AddToLog()
#DEFINE _LOG_END   2

/*-------------------------------------------------------------------
{Protheus.doc} GFEA055

Geração de Pré-faturas

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
-------------------------------------------------------------------*/

Function GFEA055()
	Local oBrowse
	Private aRotina := MenuDef()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GWJ")				// Alias da tabela utilizada
	oBrowse:SetMenuDef("GFEA055")		// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001)	    // Descrição do browse //"Geração Pré-faturas"

	oBrowse:AddLegend( "GWJ_SIT=='1'", "GRAY" , STR0002 )  // Legenda //"Pendente"
	oBrowse:AddLegend( "GWJ_SIT=='2'", "BLUE" , STR0003 )  // Legenda //"Enviada"
	oBrowse:AddLegend( "GWJ_SIT=='3'", "GREEN", STR0004 )  // Legenda //"Confirmada"
	oBrowse:AddLegend( "GWJ_SIT=='4'", "RED"  , STR0005 )  // Legenda //"Cancelada"

	oBrowse:Activate()
Return Nil


//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0006 ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEC055" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0008 ACTION "GFEA055PRE"      OPERATION 3 ACCESS 0 //"Gerar"
	ADD OPTION aRotina TITLE STR0009 ACTION "GFEA55ALT"       OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE "Atualizar Financeiro ERP" ACTION "GFEA055X()"   OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Desatualiz Financeiro ERP" ACTION "GFEA055DX()" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.GFEA055" OPERATION 8 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE "Excluir" ACTION "VIEWDEF.GFEA055" OPERATION 5 ACCESS 0 //Excluir pré-faturas com situação pendente.
	ADD OPTION aRotina TITLE "Anexos" ACTION "MsDocument('GWJ',GWJ->(RecNo()), 3)"  OPERATION 4 ACCESS 0  // "Anexo"

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel
	Local oStructGWJ := FWFormStruct(1,"GWJ")
	Local oStructGWK := FWFormStruct(1,"GWK")
	Local oStructGWF := FWFormStruct(1,"GWF")
	Local oEvent	 := GFEA55EVT():New()

	oStructGWJ:AddField("Valor Pré-Fatura"    , "Valor Pré-Fatura"   , "GWJ_VLPF" , "N", 12, 2           , /*bVALID*/,{||IsInCallStack("GFEA099")}/*bWHEN*/,/*@aVALUES*/,,{|a,b,c| FWInitCpo(a,b,c),lRetorno:=(IIF(INCLUI,0,GFEA055VL())),FWCloseCpo(a,b,c,.t.),lRetorno }        /*bINIT*/,/*lKEY*/,/*lNOUPD*/,.T./*lVIRTUAL*/)
	oStructGWJ:AddField("Espécie de Provisão" , "Espécie de Provisão", "MV_DSEPRO", "C", 10, /*nDECIMAL*/, /*bVALID*/,{||IsInCallStack("GFEA099")}/*bWHEN*/,/*@aVALUES*/,,{|a,b,c| FWInitCpo(a,b,c),lRetorno:=(SuperGetMv("MV_DSEPRO",,"")),FWCloseCpo(a,b,c,.t.),lRetorno } /*bINIT*/,/*lKEY*/,/*lNOUPD*/,.T./*lVIRTUAL*/)
	oStructGWJ:AddField("Espécie de Provisão" , "Espécie de Provisão", "MV_DSEPRE", "C", 10, /*nDECIMAL*/, /*bVALID*/,{||IsInCallStack("GFEA099")}/*bWHEN*/,/*@aVALUES*/,,{|a,b,c| FWInitCpo(a,b,c),lRetorno:=(SuperGetMv("MV_DSEPRE",,"")),FWCloseCpo(a,b,c,.t.),lRetorno } /*bINIT*/,/*lKEY*/,/*lNOUPD*/,.T./*lVIRTUAL*/)

	oModel := MPFormModel():New("GFEA055", /*bPre*/, { |oX| GFEA055POS(oX)}, /*bCommit*/, /*bCancel*/)
	oModel:SetVldActivate ( { |oModel| GFEA055EP( oModel ) } )

	oModel:AddFields("GFEA055_GWJ", Nil, oStructGWJ,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:AddGrid("GFEA055_GWK","GFEA055_GWJ",oStructGWK,/*bLinePre*/,/**/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA055_GWK",{{"GWK_FILIAL",'GWJ_FILIAL'},{"GWK_NRPF","GWJ_NRPF"}},"GWK_FILIAL+GWK_NRPF")
	oModel:SetOptional("GFEA055_GWK", .T. )

	oModel:AddGrid("GFEA055_GWF","GFEA055_GWJ",oStructGWF,/*bLinePre*/,/**/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA055_GWF",{{"GWF_FILIAL",'GWJ_FILIAL'},{"GWF_NRPREF","GWJ_NRPF"}},"GWF_FILIAL+GWF_NRPREF")
	oModel:GetModel("GFEA055_GWF"):SetOnlyQuery(.T.)

	oModel:SetPrimaryKey({"GWJ_FILIAL", "GWJ_NRPF"})

	oModel:GetModel("GFEA055_GWF"):SetMaxLine(9999)

	oModel:InstallEvent("GFEA55EVT", /*cOwner*/, oEvent)
Return oModel

//-------------------------------------------------------------------------

Static Function ViewDef()

	Local oModel := FWLoadModel("GFEA055")
	Local oView  := Nil
	Local oStructGWJ := FWFormStruct(2,"GWJ")

	oStructGWJ:AddField("GWJ_VLPF"  ,"30" ,"Valor Pré-Fatura"  ,"" ,{"Valor Pré-Fatura"}    ,"N" ,"@E 999,999,999.99",/*bPICTVAR*/,/*cLOOKUP*/,/*lCANCHANGE*/,"1"/*cFOLDER*/,/*cGRUP*/,/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/,"1",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/)
	oStructGWJ:AddField("MV_DSEPRO" ,"" ,"Espécie de Provisão" ,"" ,{"Espécie de Provisão"} ,"C" ,"@!",/*bPICTVAR*/,/*cLOOKUP*/,/*lCANCHANGE*/,/*cFOLDER*/,/*cGRUP*/,/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/," ",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/)
	oStructGWJ:AddField("MV_DSEPRE" ,"" ,"Espécie de Previsão" ,"" ,{"Espécie de Previsão"} ,"C" ,"@!",/*bPICTVAR*/,/*cLOOKUP*/,/*lCANCHANGE*/,/*cFOLDER*/,/*cGRUP*/,/*@aCOMBOVALUES*/,/*nMAXLENCOMBO*/," ",/*lVIRTUAL*/,/*cPICTVAR*/,/*lINSERTLIN*/)

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField( "GFEA055_GWJ" , oStructGWJ , /*cLinkID*/ )

	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	oView:SetOwnerView( "GFEA055_GWJ" , "MASTER" )

Return oView

/*-------------------------------------------------------------------
{Protheus.doc} GFEA055PRE

Processamento da geração da pre-fatura

@author Jorge Matos Valcanaia
@since 27/10/09
@version 1.0
-------------------------------------------------------------------*/
Function GFEA055PRE()
	Local dValidade
	Local cTransp
	Local cNrCalc
	Local dData
	Local cFili
	Local cUf
	Local cClass
	Local cCidaUf
	Local cNUMPREF
	Local cNRPF
	Local cAlias
	Local cGerarLog
	Local cHrapr
	Local cCautpf
	Local cTranspft
	Local cFilAntOld    := cFilAnt
	Local nI 			:= 0
	Local nPos 			:= 0
	Local cAliasQry 	:= ""
	Local cCdTpSe   	:= ""
	Local cCondicoes 	:= ""
	Local cQuery    	:= ""
	Local cGrupo 		:= "0"
	Local lDcEntregue 	:= .F.	// Verificação se o DC está entregue, usado juntamente com o parâmetro MV_PFENTR
	Local lExec 		:= .T.
	Local lExigeEntrega := .F.
	Local lExistCamp 	:= GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
	Local lTemCdTpSe 	:= GFXCP12117("GWF_CDTPSE")
	Local aTrpDtVc 		:= {}
	Local aPreFat  		:= {}
	Local aPreFatFin    := {} // Pré Faturas atualizadas no financeiro
	Local aExcTransp 	:= {}
	Local oModel
	Local oModelGWJ
	Local oModelGWF
	Local c_GFEI15   	:= SuperGetMV('MV_GFEI15',,'1')	
	Local c_PFENTR   	:= SuperGetMV('MV_PFENTR',,'0')

	Private LogPreFat	
	Private cAliMKB
	Private s_GFEA0551 	:= ExistBlock("GFEA0551")
	Private s_GFEA0552 	:= ExistBlock("GFEA0552")
	Private c_TPGERA   	:= SuperGetMV("MV_TPGERA",,"2")


	//----------------------------------------------
	// Criacao da tabela temporaria
	//----------------------------------------------
	aMKB := {{"FILIAL", "C", Len(cFilAnt),0},;
			 {"GRUPO" , "C", 01,0},;
			 {"TRANSP", "C", TAMSX3("GU3_CDEMIT")[1],0},;
			 {"CLASSI", "C", 04,0},;
			 {"UF"    , "C", 02,0},;
			 {"FILI"  , "C", Len(cFilAnt),0},;
			 {"NRPF"  , "C", TAMSX3("GWJ_NRPF")[1],0},;
			 {"CDTRP" , "C", TAMSX3("GU3_CDEMIT")[1],0},;
			 {"SIT"   , "C", 01,0},;
			 {"DTVENC", "D", 08,0},;
			 {"DTIMPL", "D", TAMSX3("GWJ_DTIMPL")[1],0},;
			 {"HRIMPL", "C", 05,0},;
			 {"USUIMP", "C", 50,0},;
			 {"OK"    , "C", 02,0},;
			 {"CALC"  , "C", TAMSX3("GWF_NRCALC")[1],0};
			}

	If lTemCdTpSe
		aAdd(aMKB,{"CDTPSE"   ,"C",TAMSX3("GWF_CDTPSE")[1],0})
	EndIf

	cAliMKB := GFECriaTab( {aMKB , {"GRUPO+TRANSP+CLASSI+FILI+UF+CALC"+If(lTemCdTpSe,"+CDTPSE","")}} )

	CursorWait()

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aMKB2 :=   {{"FILIAL", "C", Len(cFilAnt),0},;
				{"GRUPO" , "C", 01,0},;
				{"FILI"  , "C", Len(cFilAnt),0},;
				{"UF"    , "C", 02,0},;
				{"CLASSI", "C", 04,0},;
				{"CALC"  , "C", TAMSX3("GWF_NRCALC")[1],0},;
				{"EMIREM", "C", TAMSX3("GU3_CDEMIT")[1],0},;
				{"EMIDES", "C", TAMSX3("GU3_CDEMIT")[1],0},;
				{"TRANSP", "C", TAMSX3("GU3_CDEMIT")[1],0},;
				{"NRCALC", "C", TAMSX3("GWF_NRCALC")[1],0};
				}

	If lTemCdTpSe
		aAdd(aMKB2,{"CDTPSE"   ,"C",TAMSX3("GWF_CDTPSE")[1],0})
	EndIf
	cAliMKB2 := GFECriaTab( {aMKB2 , {"GRUPO", "TRANSP+GRUPO+UF+CLASSI+FILI+CALC"+If(lTemCdTpSe,"+CDTPSE","")}} )

	CursorWait()

	//----------------------------------------------
	If IsBlind()
		dData := DATE()
	Else
		dData := DDATABASE
	EndIf

	If !IsBlind()
		If !Pergunte("GFEA055", .T.)
			Return Nil
		EndIf
	EndIf

	If MV_PAR15 == 1
		cCondicoes += "'1',"
	EndIf

	If MV_PAR16 == 1
		cCondicoes += "'2',"
	EndIf

	If MV_PAR17 == 1
		cCondicoes += "'3',"
	EndIf

	If MV_PAR18 == 1
		cCondicoes += "'4',"
	EndIf

	If MV_PAR19 == 1
		cCondicoes += "'5',"
	EndIf

	If MV_PAR20 == 1
		cCondicoes += "'6',"
	EndIf

	If MV_PAR21 == 1
		cCondicoes += "'7',"
	EndIf


	If !Empty(MV_PAR25) .or. MV_PAR25 != ""
		aExcTransp := StrToKArr(MV_PAR25, ";")
		nPos := Len(aExcTransp)
		If Empty(aExcTransp[nPos])
			aDel(aExcTransp, nPos)
			aSize(aExcTransp, nPos-1)
		EndIf
	EndIf

	cGerarLog := If(MV_PAR22 == 1 .AND. MV_PAR01 == 2, "2", "1")

	cCondicoes := SubStr(cCondicoes,1,Len(cCondicoes)-1)

	LogPreFat := GFELog():New("PreFat_Geracao", "Geração de Pré-Faturas", cGerarLog)

	LogPreFat:Add("Parâmetros -------------------------")
	LogPreFat:Add("Filial de.......: " + MV_PAR02)
	LogPreFat:Add("Filial até......: " + MV_PAR03)
	LogPreFat:Add("Transp de.......: " + MV_PAR04)
	LogPreFat:Add("Transp até......: " + MV_PAR05)
	LogPreFat:Add("Tp Operacao de..: " + MV_PAR06)
	LogPreFat:Add("Tp Operacao até.: " + MV_PAR07)
	LogPreFat:Add("Class Frete de..: " + MV_PAR08)
	LogPreFat:Add("Class Frete até.: " + MV_PAR09)
	LogPreFat:Add("Data Cálculo de.: " + cValToChar(MV_PAR10))
	LogPreFat:Add("Data Cálculo até: " + cValToChar(MV_PAR11))
	LogPreFat:Add("Romaneio de.....: " + cValToChar(MV_PAR12))
	LogPreFat:Add("Romaneio até....: " + cValToChar(MV_PAR13))
	LogPreFat:Add("Data Lim Ent/Sai: " + cValToChar(MV_PAR14))
	LogPreFat:Add("Tipo de Cálculos:")
	LogPreFat:Add("Normal..........: " + If(MV_PAR15 == 1, "Sim", "Não"), 1)
	LogPreFat:Add("Compl Valor.....: " + If(MV_PAR16 == 1, "Sim", "Não"), 1)
	LogPreFat:Add("Compl Impostos..: " + If(MV_PAR17 == 1, "Sim", "Não"), 1)
	LogPreFat:Add("Reentrega.......: " + If(MV_PAR18 == 1, "Sim", "Não"), 1)
	LogPreFat:Add("Devolução.......: " + If(MV_PAR19 == 1, "Sim", "Não"), 1)
	LogPreFat:Add("Redespacho......: " + If(MV_PAR20 == 1, "Sim", "Não"), 1)
	LogPreFat:Add("Serviço.........: " + If(MV_PAR21 == 1, "Sim", "Não"), 1)

	If lTemCdTpSe
		LogPreFat:Add("Tipo de Serviço de..: " + MV_PAR23)
		LogPreFat:Add("Tipo de Serviço até.: " + MV_PAR24)
	EndIf

	LogPreFat:NewLine()
	If c_PFENTR == "1"
		LogPreFat:Add("# Só serão considerados os cálculos onde o trecho do transportador foi entregue. Consultar parâmetro MV_PFENTR (aba Pré-Faturas).")
	EndIf
	LogPreFat:NewLine()

	If !Empty(MV_PAR25) .or. MV_PAR25 != ""
		LogPreFat:Add("# Os transportadores informados no item 'Exceto Transportadores' não serão considerados na geração. São eles: " + Alltrim(MV_PAR25) + ".")
	EndIf
	LogPreFat:NewLine()
	LogPreFat:Save()

	cAlias := GetNextAlias()

	cQuery := " SELECT GWF.*"
	cQuery += " FROM " + RetSQLName("GWF") + " GWF"
	cQuery += "	INNER JOIN " + RetSQLName("GWN") + " GWN ON GWN.GWN_FILIAL = GWF.GWF_FILROM AND GWN.GWN_NRROM = GWF.GWF_NRROM"
	cQuery += " LEFT JOIN " + RetSQLName("GU3") + " GU3 ON GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3.GU3_CDEMIT = GWF.GWF_TRANSP AND GU3.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSQLName("GU7") + " GU7 ON GU7.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7.GU7_NRCID  = GWF.GWF_CIDDES AND GU7.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GWF.GWF_FILIAL >= '" + MV_PAR02 + "' AND GWF.GWF_FILIAL <= '" + MV_PAR03 + "'"
	cQuery += "   AND GWF.GWF_TRANSP >= '" + MV_PAR04 + "' AND GWF.GWF_TRANSP <= '" + MV_PAR05 + "'"
	cQuery += "   AND GWF.GWF_TPCALC IN (" + cCondicoes + ")"
	cQuery += "   AND GWF.GWF_DTCRIA >= '" + DToS(MV_PAR10) + "' AND GWF.GWF_DTCRIA <= '" + DToS(MV_PAR11) + "'"
	//Seleção por faixa de romaneio
	If !Empty(MV_PAR12)
		cQuery += " AND GWF.GWF_NRROM >= '" + MV_PAR12 + "'"
	EndIf
	If	!Empty(MV_PAR13)
		cQuery += " AND GWF.GWF_NRROM <= '" + MV_PAR13 + "'"
	EndIf
	cQuery += " AND	GWF.GWF_NRPREF = ''"
	If MV_PAR21 == 1 .And. lTemCdTpSe
		cQuery += " AND ((GWF.GWF_CDTPSE >= '" + MV_PAR23 + "' AND GWF.GWF_CDTPSE <= '" + MV_PAR24 + "') OR GWF.GWF_TPCALC <> '7')"
	EndIf
	cQuery += " AND GU3.GU3_AUTON <> '1'"
	cQuery += " AND GWF.D_E_L_E_T_ = ' '"
	cQuery += "	AND GWN.GWN_BLOQPF = '2'"
	cQuery += " AND GWN.GWN_CDTPOP >= '" + MV_PAR06 + "' AND GWN.GWN_CDTPOP <= '" + MV_PAR07 + "'"
	cQuery += " AND GWN.GWN_CDCLFR >= '" + MV_PAR08 + "' AND GWN.GWN_CDCLFR <= '" + MV_PAR09 + "'"
	/*Exceto Transportadores*/
	For nI := 1 To Len(aExcTransp)
		cQuery += " AND GWF.GWF_TRANSP <> '" + aExcTransp[nI] + "'"
	Next

	//Ponto de entrada Marba - Ch: TTKNQO
	If  s_GFEA0552
		cQuery := ExecBlock( "GFEA0552",.F.,.F., {cQuery} )
	EndIf
	//Fim Ponto de entrada Marba

	cQuery += " ORDER BY GWF.GWF_TRANSP"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

	dbSelectArea((cAlias))
	(cAlias)->( dbGoTop() )
	While !(cAlias)->( Eof() )
		lDocFat := .T.
		LogPreFat:Add("Filial: " + (cAlias)->GWF_FILIAL + ", Calculo: " + (cAlias)->GWF_NRCALC + ", Transp: " + (cAlias)->GWF_TRANSP)
		LogPreFat:Save()

		cGrupo  := "0"
		cFili   := Replicate("0", Len(cFilAnt))
		cUf     := "00"
		cClass  := "0000"
		cNrCalc	:= Replicate("0", TAMSX3("GWF_NRCALC")[1])

		cCidaUf := POSICIONE("GU7",1,xFilial("GU7")+(cAlias)->GWF_CIDDES,"GU7_CDUF")
		If lTemCdTpSe
			cCdTpSe := Space(TAMSX3("GWF_CDTPSE")[1])
		Else
			cCdTpSe := ''
		EndIf

		// Somente busca o grupo da classificação de frete se a origem for Calculado
		// Desconsidera frete combinado
		If (cAlias)->GWF_ORIGEM == "1" 
			dbSelectArea("GWG")
			GWG->( dbSetOrder(1) )
			dbSeek((cAlias)->GWF_FILIAL+(cAlias)->GWF_NRCALC)
			While !GWG->( Eof() ) .AND. GWG->GWG_FILIAL == (cAlias)->GWF_FILIAL .AND. GWG->GWG_NRCALC == (cAlias)->GWF_NRCALC
				If GWG->GWG_CDTPOP >= MV_PAR06 .AND. GWG->GWG_CDTPOP <= MV_PAR07 .AND. GWG->GWG_CDCLFR >= MV_PAR08 .AND. GWG->GWG_CDCLFR <= MV_PAR09
					cClass := GWG->GWG_CDCLFR
				EndIf
				
				dbSelectArea("GWG")
				GWG->( dbSkip() )
			EndDo
		EndIf

		lDocFat := .T.
		If lExistCamp //Utiliza novos campos disponíveis na tabela de cálculo para encontrar o documento de frete e fatura 
			//Verifica se o cálculo está associado à fatura
			cQuery := " SELECT GW6.GW6_EMIFAT,GW6.GW6_NRFAT"
			cQuery += " FROM " + RetSqlName('GW3') + " GW3"
			cQuery += " INNER JOIN " + RetSqlName('GW6') + " GW6"
			cQuery += " ON GW6.GW6_FILIAL = GW3.GW3_FILFAT"
			cQuery += " AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
			cQuery += " AND GW6.GW6_SERFAT = GW3.GW3_SERFAT"
			cQuery += " AND GW6.GW6_NRFAT = GW3.GW3_NRFAT"
			cQuery += " AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA"
			cQuery += " AND GW6.GW6_SITFIN = '4'"
			cQuery += " AND GW6.D_E_L_E_T_ = ' '"
			cQuery += " WHERE GW3.GW3_FILIAL = '" + (cAlias)->GWF_FILIAL + "'"
			cQuery += " AND GW3.GW3_CDESP = '" + (cAlias)->GWF_CDESP + "'"
			cQuery += " AND GW3.GW3_EMISDF = '" + (cAlias)->GWF_EMISDF + "'"
			cQuery += " AND GW3.GW3_SERDF = '" + (cAlias)->GWF_SERDF + "'"
			cQuery += " AND GW3.GW3_NRDF = '" + (cAlias)->GWF_NRDF + "'"
			cQuery += " AND GW3.GW3_DTEMIS = '" + (cAlias)->GWF_DTEMDF + "'"
			cQuery += " AND GW3.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

			If (cAliasQry)->(!EoF())
				LogPreFat:Add("** Desconsiderando cálculo associado a fatura. Transportador: " + AllTrim(GWF->GWF_TRANSP) + ", Cálculo: " + AllTrim(GWF->GWF_NRCALC) + " | Emissor: " + AllTrim((cAliasQry)->GW6_EMIFAT) + ", Fatura: " +  AllTrim((cAliasQry)->GW6_NRFAT))
				lDocFat := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		Else
			// VERIFICA SE NO CALCULO, COM MAIS DE UM DOC CARGA  NAO EXISTE NENHUM DOC DE CARGA RELACIONADO A UMA FATURA ATUALIZADA
			dbSelectArea("GWH")// DOC CARGA X CALCULO
			GWH->( dbSetOrder(1) )
			dbSeek((cAlias)->GWF_FILIAL+(cAlias)->GWF_NRCALC)
			While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == (cAlias)->GWF_FILIAL .And. GWH->GWH_NRCALC == (cAlias)->GWF_NRCALC
				dbSelectArea("GW1") // DOC CARGA
				GW1->( dbSetOrder(1) )
				If GW1-> (dbSeek((cAlias)->GWF_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
					//>>> VALIDAÇÃO PARA NÃO VINCULAR CALCULOS ASSOCIADOS A FATURAS E DOCUMENTOS DE FRETE PENDENTES DE ATUALIZAÇÃO FISCAL
					dbSelectArea("GW4") // DOC FRETE X DOC CARGA
					GW4->( dbSetOrder(2) )
					If GW4->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC + GWH->GWH_CDTPDC))
						While !GW4->(Eof()) .AND. ;
						GW4->GW4_FILIAL == GWH->GWH_FILIAL .AND. ;
						GW4->GW4_EMISDC == GWH->GWH_EMISDC .AND. ;
						GW4->GW4_SERDC  == GWH->GWH_SERDC  .AND. ;
						GW4->GW4_NRDC   == GWH->GWH_NRDC   .AND. ;
						GW4->GW4_TPDC   == GWH->GWH_CDTPDC

							dbSelectArea("GW3") // DOCUMENTO DE FRETE
							GW3->( dbSetOrder(1) ) //TROCAR INDICE, COLOCAR DENTRO DE UM BLOCO
							If GW3->(dbSeek(GW4->GW4_FILIAL + GW4->GW4_CDESP+GW4->GW4_EMISDF+GW4->GW4_SERDF+GW4->GW4_NRDF+DTOS(GW4->GW4_DTEMIS)))
								// SE O TIPO DO DOCUMENTO DE FRETE FOR IGUAL AO TIPO DO CALCULO, VERIFICA SE JÁ ESTA ATUALIZADO NO FINANCEIRO
								If GW3->GW3_TPDF == (cAlias)->GWF_TPCALC
									dbSelectArea("GW6") // FATURA DE FRETE
									GW6->( dbSetOrder(1) )
									If GW6->(dbSeek(GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DTOS(GW3->GW3_DTEMFA)))
										If GW6->GW6_SITFIN = '4'
											LogPreFat:Add("** Desconsiderando cálculo com documento de carga associado a fatura. Transportador: " + AllTrim(GWF->GWF_TRANSP) + ", Cálculo: " + AllTrim(GWF->GWF_NRCALC) + " | Doc. Carga: " + AllTrim(GW4->GW4_NRDC) + " | Emissor: " + AllTrim(GW6->GW6_EMIFAT) + ", Fatura: " +  AllTrim(GW6->GW6_NRFAT))
											lDocFat := .F.
											Exit
										EndIf
									EndIf
								Endif
							EndIf

							GW4->(dbSkip())
						EndDo
					EndIf
				EndIf
				If lDocFat
					Exit
				EndIf

				GWH->( dbSkip() )
				Loop
			EndDo
		EndIf

		// SE O CALCULO NÃO TIVER NENHUM DOCUMENTO DE CARGA RELACIONADO A FATURAS DE FRETE, GERA A PRÉ-FATURA
		If lDocFat

			dbSelectArea("GWH")// DOC CARGA X CALCULO
			GWH->( dbSetOrder(1) )
			dbGoTop()
			dbSeek((cAlias)->GWF_FILIAL+(cAlias)->GWF_NRCALC)
			While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == (cAlias)->GWF_FILIAL .And. GWH->GWH_NRCALC == (cAlias)->GWF_NRCALC

				lExec := .T.
				dbSelectArea("GW1") // DOCUMENTO DE CARGA
				GW1->( dbSetOrder(1) )
				If GW1-> (dbSeek((cAlias)->GWF_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
					// Verifica se a data do parâmetro "Data Limite Entrada/Saída" está dentro do limite informado
					If !Empty(MV_PAR14) .AND. (GW1->GW1_DTSAI > MV_PAR14  .or. Empty(GW1->GW1_DTSAI))
						LogPreFat:Add(" ** Desconsiderando cálculo com documento de carga fora da data limite. Filial: " + (cAlias)->GWF_FILIAL + ", Nr: " + (cAlias)->GWF_NRCALC)
						GWH->( dbSkip() )
						Loop
					EndIf

					If s_GFEA0551
						lExec := ExecBlock("GFEA0551",.f.,.f.,{(cAlias)->GWF_NRCALC, (cAlias)->GWF_TPCALC})
					EndIf

					If GFXCP12130("GWU_FLGENT") .And. c_PFENTR == "0"
						lExigeEntrega := .T.
					EndIf

					/* Verifica a obrigatoriedade da entrega do trecho do transportador
					Se o documento de carga está entregue, não necessita fazer a validação */
					If (c_PFENTR == "1" .And. GW1->GW1_SIT != "5" .And. lExec) .Or. (lExigeEntrega)
						lDcEntregue := .T.

						GWU->( dbSetOrder(1) )
						GWU->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC) )
						While !GWU->( Eof() ) .And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. ;
						GWU->GWU_SERDC == GW1->GW1_SERDC .And. GWU->GWU_NRDC == GW1->GW1_NRDC
							If lExigeEntrega
								If GWU->GWU_CDTRP == (cAlias)->GWF_TRANSP;
								.And. GWU->GWU_SEQ == AllTrim((cAlias)->GWF_SEQTRE);
								.And. (Empty(GWU->GWU_DTENT) .Or. GWU->GWU_FLGENT == .F.)
									lDcEntregue := .F. 
									Exit
								EndIf	
							Else 
								If GWU->GWU_CDTRP == (cAlias)->GWF_TRANSP;
								.And. GWU->GWU_SEQ == AllTrim((cAlias)->GWF_SEQTRE);
								.And. Empty(GWU->GWU_DTENT)
									lDcEntregue := .F. 
									Exit
								EndIf
							EndIf
							GWU->( dbSkip() )
						EndDo

						If !lDcEntregue
							LogPreFat:Add(" ** Desconsiderando cálculo onde o trecho não foi entregue. Filial: " + (cAlias)->GWF_FILIAL + ", Nr: " + (cAlias)->GWF_NRCALC)
							GWH->( dbSkip() )
							Loop
						EndIf
					EndIf
					/* Grava os valores dos agrupamentos (Cálculo, Filial, Uf, Classificação de Frete, Tipo de Frete)
					Se o tipo de agrupamento for por cálculo, desconsidera os outros tipo. */
					dbSelectArea("GU3")
					GU3->( dbSetOrder(1) )
					If dbSeek(xFilial("GU3")+(cAlias)->GWF_TRANSP)
						If GU3->GU3_PFCALC == "1"
							cFili   := (cAlias)->GWF_FILIAL
							cNrCalc	:= GWH->GWH_NRCALC
							LogPreFat:Add("# Agrupamento por Cálculo. Filial: " + cFili + ", Nr: " + cNrCalc, 1)
						Else
							If GU3->GU3_PFFIL == "1"
								cFili := (cAlias)->GWF_FILIAL
								LogPreFat:Add("# Agrupamento por Filial: " + cFili, 1)
							EndIf
							If GU3->GU3_PFUF == "1"
								cUf := cCidaUf
								LogPreFat:Add("# Agrupamento por UF: " + cUf , 1)
							EndIf
							If GU3->GU3_PFCLAS == "1"
								LogPreFat:Add("# Agrupamento por Classificação de frete: " + cClass, 1)
							Else
								cClass := "0000"
							EndIf
							If GU3->GU3_PFTPFR == "1"
								LogPreFat:Add("# Agrupamento por Tipo de Cálculo: " + (cAlias)->GWF_TPCALC, 1)
								If (cAlias)->GWF_TPCALC == "1"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFNORM))
								ElseIf (cAlias)->GWF_TPCALC == "2"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFCPVL))
								ElseIf (cAlias)->GWF_TPCALC == "3"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFCPIC))
								ElseIf (cAlias)->GWF_TPCALC == "4"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFDEV))
								ElseIf (cAlias)->GWF_TPCALC == "5"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFREDE))
								ElseIf (cAlias)->GWF_TPCALC == "6"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFREEN))
								ElseIf (cAlias)->GWF_TPCALC == "7"
									cGrupo := ALLTRIM(STR(GU3->GU3_PFSERV))
								EndIf
							EndIf
							If lTemCdTpSe .And. GU3->GU3_PFTPSE == "1"
								cCdTpSe := (cAlias)->GWF_CDTPSE
								LogPreFat:Add("# Agrupamento por Serviço: " + cCdTpSe, 1)
							EndIf
						EndIf

						LogPreFat:Save()

						// Verifica se foi utilizado um transportador diferente para o faturamento
						If !Empty(GU3->GU3_CDEMFT)
							cTransp := GU3->GU3_CDEMFT
							LogPreFat:Add("- Transportador de Faturamento: " + cTransp, 1)
						Else
							cTransp := (cAlias)->GWF_TRANSP
						EndIf

						dValidade := GFECalcVc(dData,cTransp)

						If Empty(dValidade)
							LogPreFat:Add("** Data de validade não calculada.", 1)
						EndIf

						If (MV_PAR01 == 1 .Or. !Empty(dValidade))
							LogPreFat:AddDebug("- Armazenando registro do cálculo.", 1)
							dbSelectArea(cAliMKB)
							(cAliMKB)->( dbSetOrder(1) )
							If !dbSeek(cGrupo+cTransp+cClass+cFili+cUf+cNrCalc+cCdTpSe)

								RecLock((cAliMKB),.T.)
								
								CFILANT  := (cAlias)->GWF_FILIAL
								cNUMPREF := GETSXENUM("GWJ","GWJ_NRPF")
								cNUMPREF := VAL(cNUMPREF)  

								(cAliMKB)->FILIAL := (cAlias)->GWF_FILIAL	//(cAlias)->GWF_FILIAL
								(cAliMKB)->GRUPO  := cGrupo
								(cAliMKB)->TRANSP := cTransp
								(cAliMKB)->FILI   := cfili
								(cAliMKB)->UF     := cUf
								(cAliMKB)->CLASSI := cCLASS
								(cAliMKB)->CALC   := cNrCalc
								(cAliMKB)->NRPF   := STRZERO(cNUMPREF,TAMSX3("GWJ_NRPF")[1])
								(cAliMKB)->CDTRP  := (cAlias)->GWF_TRANSP
								(cAliMKB)->DTVENC := dValidade
								(cAliMKB)->SIT    := "1"
								(cAliMKB)->DTIMPL := dData
								(cAliMKB)->HRIMPL := TIME()
								(cAliMKB)->USUIMP := cUserName
								If lTemCdTpSe
									(cAliMKB)->CDTPSE := cCdTpSe
								EndIf

								MsUnLock(cAliMKB)

								RecLock((cAliMKB2),.T.)

								(cAliMKB2)->FILIAL := (cAlias)->GWF_FILIAL 	//(cAlias)->GWF_FILIAL
								(cAliMKB2)->GRUPO  := cGrupo
								(cAliMKB2)->TRANSP := cTransp
								(cAliMKB2)->FILI   := cfili
								(cAliMKB2)->UF     := cUf
								(cAliMKB2)->CLASSI := cCLASS
								(cAliMKB2)->CALC   := cNrCalc
								(cAliMKB2)->NRCALC := (cAlias)->GWF_NRCALC
								(cAliMKB2)->EMIREM := (cAlias)->GWF_EMIREM
								(cAliMKB2)->EMIDES := (cAlias)->GWF_EMIDES
								If lTemCdTpSe
									(cAliMKB2)->CDTPSE := cCdTpSe
								EndIf
								MsUnLock(cAliMKB2)

								ConfirmSX8()
								cFilAnt := cFilAntOld 
							Else

								If (cAliMKB2)->NRCALC <> (cAlias)->GWF_NRCALC

									RecLock((cAliMKB2),.T.)
									(cAliMKB2)->FILIAL  := (cAlias)->GWF_FILIAL
									(cAliMKB2)->GRUPO  := cGrupo
									(cAliMKB2)->TRANSP := cTransp
									(cAliMKB2)->FILI   := cfili
									(cAliMKB2)->UF     := cUf
									(cAliMKB2)->CLASSI  := cCLASS
									(cAliMKB2)->CALC   := cNrCalc
									(cAliMKB2)->NRCALC := (cAlias)->GWF_NRCALC
									(cAliMKB2)->EMIREM := (cAlias)->GWF_EMIREM
									(cAliMKB2)->EMIDES := (cAlias)->GWF_EMIDES
									If lTemCdTpSe
										(cAliMKB2)->CDTPSE := cCdTpSe
									EndIf

									MsUnLock(cAliMKB2)

								EndIf
							EndIf

						Else
							If AScan(aTrpDtVc, {|x| x == cTransp}) == 0
								AAdd(aTrpDtVc, cTransp)
							EndIf
						EndIf
					EndIf
				EndIf
				dbselectArea("GWH")
				GWH->( dbSkip() )
			EndDo
		EndIf
		dbSelectArea((cAlias))
		(cAlias)->( dbSkip() )
	EndDo

	If MV_PAR01 == 1 .And. !IsBlind()

		GFEA55SIM()

	Else
		LogPreFat:NewLine()
		LogPreFat:Add(Replicate("-", 30))
		LogPreFat:NewLine()
		LogPreFat:Add("Geração das pré-faturas.")
		LogPreFat:Save()

		dbSelectArea(cAliMKB)
		dbSetOrder(1)
		dbGoTop()

		oModel    := FWLoadModel("GFEA055")
		oModelGWJ := oModel:GetModel("GFEA055_GWJ")
		oModelGWF := oModel:GetModel("GFEA055_GWF") 
		If cFilAnt == GW1->GW1_FILIAL
			While !Eof()
			cFilAnt := (cAliMKB)->FILIAL
			oModel:SetOperation(3)
			oModel:Activate()
			
			If !Empty((cAliMKB)->NRPF)
				cNRPF := (cAliMKB)->NRPF
			Else
				cNRPF := GetSXENum("GWJ","GWJ_NRPF")
			EndIf
			cNRPF := VAL(cNRPF)
			cNRPF := STRZERO(cNRPF, TAMSX3("GWJ_NRPF")[1])

			LogPreFat:Add("# Pré-fatura: " + cNRPF )
			LogPreFat:Save()

			dbSelectArea(cAliMKB2)
			dbSetOrder(2)
			dbSeek((cAliMKB)->TRANSP + (cAliMKB)->GRUPO + (cAliMKB)->UF + (cAliMKB)->CLASSI + (cAliMKB)->FILI + (cAliMKB)->CALC + If(lTemCdTpSe,(cAliMKB)->CDTPSE,""))
			While !(cAliMKB2)->(Eof()) .And. (cAliMKB2)->TRANSP == (cAliMKB)->TRANSP;
									   .And. (cAliMKB2)->GRUPO == (cAliMKB)->GRUPO;
									   .And. (cAliMKB2)->UF == (cAliMKB)->UF;
									   .And. (cAliMKB2)->CLASSI == (cAliMKB)->CLASSI;
									   .And. (cAliMKB2)->FILI == (cAliMKB)->FILI;
									   .And. (cAliMKB2)->CALC == (cAliMKB)->CALC;
									   .And. (!lTemCdTpSe .Or. (cAliMKB2)->CDTPSE == (cAliMKB)->CDTPSE)


				dbSelectArea("GWF")
				dbSetOrder(1)
				If dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->NRCALC)
					oModelGWF:AddLine()
					oModelGWF:LoadValue("GWF_NRPREF",cNRPF)
					oModelGWF:LoadValue("GWF_FILPRE",xFilial("GWJ", (cAliMKB)->FILIAL))
					oModelGWF:LoadValue("GWF_NRCALC",GWF->GWF_NRCALC)
					oModelGWF:LoadValue("GWF_EMIREM",GWF->GWF_EMIREM)
					oModelGWF:LoadValue("GWF_EMIDES",GWF->GWF_EMIDES)
					oModelGWF:LoadValue("GWF_EMIPAG",GWF->GWF_EMIPAG)
					oModelGWF:LoadValue("GWF_TRANSP",GWF->GWF_TRANSP)
					oModelGWF:LoadValue("GWF_ORIGEM",GWF->GWF_ORIGEM)
					oModelGWF:LoadValue("GWF_TPCALC",GWF->GWF_TPCALC)
					oModelGWF:LoadValue("GWF_TPFRET",GWF->GWF_TPFRET)
					oModelGWF:LoadValue("GWF_FINCAL",GWF->GWF_FINCAL)
					oModelGWF:LoadValue("GWF_CIDORI",GWF->GWF_CIDORI)
					oModelGWF:LoadValue("GWF_CIDDES",GWF->GWF_CIDDES)
					oModelGWF:LoadValue("GWF_ENDENT",GWF->GWF_ENDENT)
					oModelGWF:LoadValue("GWF_BAIENT",GWF->GWF_BAIENT)
					oModelGWF:LoadValue("GWF_CIDENT",GWF->GWF_CIDENT)
					oModelGWF:LoadValue("GWF_DTCRIA",GWF->GWF_DTCRIA)
					oModelGWF:LoadValue("GWF_HRCRIA",GWF->GWF_HRCRIA)
					oModelGWF:LoadValue("GWF_USUCRI",GWF->GWF_USUCRI)
					oModelGWF:LoadValue("GWF_DTPREN",GWF->GWF_DTPREN)
					oModelGWF:LoadValue("GWF_HRPREN",GWF->GWF_HRPREN)
					oModelGWF:LoadValue("GWF_CARREG",GWF->GWF_CARREG)
					oModelGWF:LoadValue("GWF_NRROM" ,GWF->GWF_NRROM )
					oModelGWF:LoadValue("GWF_VLAJUS",GWF->GWF_VLAJUS)
					oModelGWF:LoadValue("GWF_TPTRIB",GWF->GWF_TPTRIB)
					oModelGWF:LoadValue("GWF_BASISS",GWF->GWF_BASISS)
					oModelGWF:LoadValue("GWF_PCISS" ,GWF->GWF_PCISS )
					oModelGWF:LoadValue("GWF_VLISS" ,GWF->GWF_VLISS )
					oModelGWF:LoadValue("GWF_BASICM",GWF->GWF_BASICM)
					oModelGWF:LoadValue("GWF_PCICMS",GWF->GWF_PCICMS)
					oModelGWF:LoadValue("GWF_PCREIC",GWF->GWF_PCREIC)
					oModelGWF:LoadValue("GWF_VLICMS",GWF->GWF_VLICMS)
					oModelGWF:LoadValue("GWF_ICMRET",GWF->GWF_ICMRET)
					oModelGWF:LoadValue("GWF_BAPICO",GWF->GWF_BAPICO)
					oModelGWF:LoadValue("GWF_VLPIS" ,GWF->GWF_VLPIS )
					oModelGWF:LoadValue("GWF_VLCOFI",GWF->GWF_VLCOFI)
					oModelGWF:LoadValue("GWF_NRCONT",GWF->GWF_NRCONT)
					oModelGWF:LoadValue("GWF_IDFRVI",GWF->GWF_IDFRVI)
					oModelGWF:LoadValue("GWF_AGRUP" ,GWF->GWF_AGRUP )
					oModelGWF:LoadValue("GWF_SEQTRE",GWF->GWF_SEQTRE)
					oModelGWF:LoadValue("GWF_OBS"   ,GWF->GWF_OBS   )
					oModelGWF:LoadValue("GWF_IMPOST",GWF->GWF_IMPOST)
					oModelGWF:LoadValue("GWF_CRDICM",GWF->GWF_CRDICM)
					oModelGWF:LoadValue("GWF_CRDPC" ,GWF->GWF_CRDPC )
					oModelGWF:LoadValue("GWF_NROCO" ,GWF->GWF_NROCO )
					oModelGWF:LoadValue("GWF_ADICIS",GWF->GWF_ADICIS)
				Else
					LogPreFat:Add(" ** Cálculo não encontrado. Filial: " + (cAliMKB2)->FILIAL + ", Nr: " + (cAliMKB2)->NRCALC, 1)
				EndIf

				dbSelectArea(cAliMKB2)
				dbSkip()
			EndDo

			cTranspft := POSICIONE("GU3",1,xFilial("GU3")+(cAliMKB)->CDTRP,"GU3_CDEMFT")
			dbSelectArea("GWJ")
			dbSetOrder(1)

			AAdd(aPreFat, {cNRPF, IIF(!Empty(cTranspft),cTranspft, (cAliMKB)->CDTRP)})

			oModelGWJ:LoadValue("GWJ_FILIAL", (cAliMKB)->FILIAL)
			oModelGWJ:LoadValue("GWJ_NRPF"  , cNRPF)
			oModelGWJ:LoadValue("GWJ_CDTRP" , IIF(!Empty(cTranspft),cTranspft, (cAliMKB)->CDTRP))
			oModelGWJ:LoadValue("GWJ_DTVCTO", (cAliMKB)->DTVENC)
			oModelGWJ:LoadValue("GWJ_SIT"   , (cAliMKB)->SIT)
			oModelGWJ:LoadValue("GWJ_DTIMPL", (cAliMKB)->DTIMPL)
			oModelGWJ:LoadValue("GWJ_HRIMPL", (cAliMKB)->HRIMPL)
			oModelGWJ:LoadValue("GWJ_USUIMP", (cAliMKB)->USUIMP)
			oModelGWJ:LoadValue("GWJ_SITFIN", "1")

			ConfirmSX8()

			cCautpf := ""
			dbSelectArea( "GU3" )
			GU3->( dbSetOrder( 1 ) )
			If GU3->( dbSeek( xFilial("GU3") + (cAliMKB)->CDTRP ) )
				cCautpf := GU3->GU3_CAUTPF
				If cCautpf == "1"
					cHrapr := SUBSTR(TIME(),1,5)
					oModelGWJ:LoadValue("GWJ_SIT" ,"3")
					oModelGWJ:LoadValue("GWJ_DTAPR" ,dData)
					oModelGWJ:LoadValue("GWJ_HRAPR" ,cHrapr)
					oModelGWJ:LoadValue("GWJ_USUAPR" ,cUserName )

				EndIf
			EndIf

			If  oModel:VldData()
				oModel:CommitData()
			EndIf

			oModel:DeActivate()

			If cCautpf == "1" .AND. c_TPGERA == "1"
				GFEACTBPRE((cAliMKB)->FILIAL , cNRPF)
			EndIf
			cCautpf := ""

			If GWJ->( dbSeek( (cAliMKB)->FILIAL + cNRPF ) ) .AND. GU3->GU3_CAUTPF == "1"
				If c_GFEI15 == '2' //Financeiro
					AADD(aPreFatFin, GFEA055X(.T.,oModel))
				EndIf
			EndIf

			dbSelectArea(cAliMKB)
			dbSkip()
			cFilAnt := cFilAntOld
			EndDo
		EndIf
		
		oModel:Destroy()
		If Empty(aPreFat) .And. Empty(aTrpDtVc)
			LogPreFat:Add("- Não foi gerada nenhuma Pré-fatura. Verifique se existem Cálculos de Frete que satisfaçam aos critérios de seleção informados.")
		EndIf

		LogPreFat:Save()

		GFEA055LOG(aPreFat, aTrpDtVc, If(cGerarLog == "2", "Arquivo de log gerado: '" + LogPreFat:cFullFile + "'", ""), aPreFatFin)

	EndIf

	LogPreFat:EndLog()

	GFEDelTab(cAliMKB)
	GFEDelTab(cAliMKB2)
	(cAlias)->(dbCloseArea())

	aSize(aTrpDtVc, 0)
	aTrpDtVc := nil
	aSize(aPreFat, 0)
	aPreFat := nil
	aSize(aPreFatFin, 0)
	aPreFatFin := nil
	aSize(aExcTransp, 0)
	aExcTransp := nil

	FreeObj(oModel)
	FreeObj(oModelGWJ)
	FreeObj(oModelGWF)
Return

//--------------------------Função para mostrar uma tela com as Pré-faturas geradas.

Static Function GFEA055LOG(aPreFat, aTrpDtVc, cTextoAux, aPreFatFin)

	Local nI
	Local cTexto := ""
	Local oDlg
	Local lPreFatEle // Elemento do array de pré faturas atualizadas no financeiro
	Default aTrpDtVc := {}
	Default cTextoAux := ""


	If Empty(aPreFat) .And. Empty(aTrpDtVc)

		cTexto := "- Não foi gerada nenhuma Pré-fatura. Verifique se existem Cálculos de Frete que satisfaçam aos critérios de seleção informados."

	Else

		If !Empty(aPreFat)

			cTexto := "- Foram criadas as seguintes Pré-faturas: " + CRLF + CRLF

			For nI := 1 To Len(aPreFat)

				cTexto += "Nr: " + AllTrim(aPreFat[nI][1]) + "  Transp: " + AllTrim(aPreFat[nI][2]) + " - " + AllTrim(Posicione("GU3", 1, xFilial("GU3") + aPreFat[nI][2], "GU3_NMEMIT")) + CRLF

			Next

			If Len(aPreFatFin)> 0
				//lPreFatEle[1] == .T. pré-faturas atualizadas com sucesso no financeiro
				If ASCAN(aPreFatFin,{|lPreFatEle| lPreFatEle[1] == .T.}) != 0 .AND. ;
				ASCAN(aPreFatFin,{|lPreFatEle| Empty(lPreFatEle[2]) == .F.}) != 0
					cTexto += CRLF + CRLF+"- Foram atualizadas no financeiro as seguintes Pré-faturas: " + CRLF + CRLF
					For nI := 1 To Len(aPreFatFin)
						If (aPreFatFin[nI][1])
							cTexto += "Nr: " + AllTrim(aPreFatFin[nI][2]) + CRLF
						EndIf
					Next
				EndIf

				If ASCAN(aPreFatFin,{|lPreFatEle| lPreFatEle[1] == .F.}) != 0 .AND. ;
				ASCAN(aPreFatFin,{|lPreFatEle| Empty(lPreFatEle[2]) == .F.}) != 0
					cTexto += CRLF + CRLF+"- Não foi possível atualizar no financeiro as seguintes Pré-faturas: " + CRLF + CRLF
					For nI := 1 To Len(aPreFatFin)
						If (!aPreFatFin[nI][1])
							cTexto += "Nr: " + AllTrim(aPreFatFin[nI][2]) + CRLF
						EndIf
					Next
				EndIf

			EndIf
			cTexto += CRLF

		EndIf

		If !Empty(aTrpDtVc)

			cTexto += "- Os seguintes transportadores não geraram Pré-fatura, pois, não estão marcados para calcular data de vencimento: " + CRLF + CRLF

			For nI := 1 To Len(aTrpDtVc)

				cTexto += "Transportador: " + AllTrim(aTrpDtVc[nI]) + " - " + AllTrim(Posicione("GU3", 1, xFilial("GU3") + aTrpDtVc[nI], "GU3_NMEMIT")) + CRLF

			Next

		EndIf

	EndIf

	If !Empty(cTextoAux)
		cTexto += CRLF + CRLF + cTextoAux
	EndIF

	If !IsBlind()
		DEFINE MSDIALOG oDlg TITLE "Pré-faturas" From 0,0 To 18,70 OF oMainWnd
		@ 4, 006 SAY "Resumo: " SIZE 130,7 PIXEL OF oDlg

		oTMultiget1 := TMultiget():New(13,06,{|u|If(Pcount()>0,cTexto:=u,cTexto)},;
		oDlg,265,105,,,,,,.T.,,,,,,.T.)

		oButtonOK   := tButton():New(125,5,'OK',oDlg,{|| oDlg:End()},25,10,,,,.T.)

		ACTIVATE MSDIALOG oDlg CENTER
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55SIM

Simulação feita se a opção do usuario for de "simulação"

@author Jorge Matos Valcanaia
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA55SIM()
	Local oDlg
	Local nAlt := (GetScreenRes()[2])
	Local nLrg := (GetScreenRes()[1]-100)

	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf

	aNewButton := {}
	Aadd(aNewButton,{"novacelula" ,{||GFEA55GER()},STR0014,STR0014}) //"Gerar Pré-Fatura"###"Gerar Pré-Fatura"
	Aadd(aNewButton,{"vernota" ,{||GFEA55CAL()},STR0015,STR0015}) //"Cálculos"###"Cálculos"

	Private cCadastro := STR0016 //"Simulação"
	Private cMarca1 := GetMark()
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aMKB1 :=    {{"OK"      ,"C",02,0},;
	{"NRPF"      ,"C",TAMSX3("GWJ_NRPF")[1],0},;
	{"TRANSP"    ,"C",TAMSX3("GU3_CDEMIT")[1],0},;
	{"GRUPO"     ,"C",01,0},;
	{"FILI"      ,"C",Len(cFilAnt),0},;
	{"UF"        ,"C",02,0},;
	{"CLASSI"     ,"C",04,0},;
	{"CALC"      ,"C",TAMSX3("GWF_NRCALC")[1],0},;
	{"DESTRANSP" ,"C",50,0},;
	{"DTVENC"    ,"D",04,0},;
	{"VLTOTAL"   ,"N",12,2}}

	aCpMKB1  := {{"OK"        ,NIL,"",""},;
	{"NRPF"       ,NIL,STR0017 ,"@!"},; //"Número da Pré-Fatura"
	{"TRANSP"     ,NIL,STR0018 ,"@!"},; //"Código do Transportador"
	{"DESTRANSP"  ,NIL,STR0019 ,"@!"},; //"Descrição do Transportador"
	{"DTVENC"     ,NIL,STR0020 ,""  },; //"Data de Vencimento"
	{"VLTOTAL"    ,NIL,STR0021 ,"@E 999,999,999.99"}} //"Valor Total"

	cAliMKB1 := GFECriaTab({aMKB1,{"NRPF"}})

	CursorWait()

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cAliMKB1)
	dbSetOrder(01)
	dbGoTop()
	oMark1 := MsSelect():New(cAliMKB1,"OK",,aCpMKB1,,@cMarca1,{0,0,0,0},,,oPnlB)
	oMark1:oBrowse:bLDblClick := { || GFEA55CHC()}
	oMark1:oBrowse:cToolTip := STR0022 //"Visualização"
	oMark1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Processa({|lEnd| GFEA55CRG()},STR0023,STR0038) //"Processando informações" //"Aguarde"

	CursorArrow()


	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||ODlg:End()},;
	{||ODlg:End()},,aNewButton) CENTERED

	GFEDelTab(cAliMKB1)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55CRG

Carrega a tabela temporaria da tela de simulação

@author Jorge Matos Valcanaia
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEA55CRG()
	Local cDESTRANSP
	Local nVlFrNo := 0

	dbSelectArea(cAliMKB1)
	ZAP

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	While !Eof()
		nVlFrNo := 0
		If ALLTRIM((cAliMKB)->NRPF) <> ""

			dbSelectArea("GU3")
			GU3->( dbSetOrder(1) )
			dbSeek(xFilial("GU3")+(cAliMKB)->CDTRP)
			If !Empty(GU3->GU3_CDEMFT)
				dbSelectArea(cAliMKB1)
				cDESTRANSP := POSICIONE("GU3",1,xFilial("GU3")+(cAliMKB)->TRANSP,"GU3_NMEMIT")
			Else
				cDESTRANSP := POSICIONE("GU3",1,xFilial("GU3")+(cAliMKB)->CDTRP,"GU3_NMEMIT")
			EndIf

			dbSelectArea(cAliMKB2)
			dbSetOrder(1)
			dbGoTop()

			While !Eof()

				If (cAliMKB)->CDTRP == (cAliMKB2)->TRANSP .AND. ;
				(cAliMKB)->GRUPO == (cAliMKB2)->GRUPO  .AND. ;
				(cAliMKB)->UF    == (cAliMKB2)->UF     .AND. ;
				(cAliMKB)->CLASSI == (cAliMKB2)->CLASSI  .AND. ;
				(cAliMKB)->FILI  == (cAliMKB2)->FILI   .AND. ;
				(cAliMKB)->CALC  == (cAliMKB2)->CALC


					dbSelectArea("GWF")
					GWF->( dbSetOrder(1) )
					If GWF->( dbSeek((cAliMKB2)->FILIAL + (cAliMKB2)->NRCALC)  )

						nVlFrNo += VLTOTFRET()

					EndIf

				EndIf

				dbSelectArea(cAliMKB2)
				dbSkip()

			EndDO


			RecLock((cAliMKB1), .T.)

			(cAliMKB1)->NRPF      := (cAliMKB)->NRPF
			(cAliMKB1)->TRANSP    := (cAliMKB)->TRANSP
			(cAliMKB1)->DESTRANSP := cDESTRANSP
			(cAliMKB1)->GRUPO     := (cAliMKB)->GRUPO
			(cAliMKB1)->FILI      := (cAliMKB)->FILI
			(cAliMKB1)->UF        := (cAliMKB)->UF
			(cAliMKB1)->CLASSI     := (cAliMKB)->CLASSI
			(cAliMKB1)->CALC	    := (cAliMKB)->CALC
			(cAliMKB1)->DTVENC    := (cAliMKB)->DTVENC
			(cAliMKB1)->VLTOTAL   := nVlFrNo

			MsUnLock(cAliMKB1)

			RollBackSX8()

		Endif

		dbSelectArea(cAliMKB)
		dbSkip()

	EndDo

	dbSelectArea(cAliMKB1)
	dbGoTOp()
	oMark1:oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55CAL

Tela de visualização de Cálculos que estao vinculados a pré-fatura simulada

@author Jorge Matos Valcanaia
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA55CAL()
	Local oDlg
	Local nAlt  := (GetScreenRes()[2])
	Local nLrg  := (GetScreenRes()[1]-100)
	Local aArea := GetArea()
	Private cCadastro := STR0025 //"Cálculos Vinculados"

	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf

	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------
	aMKB3 :=    {{"NRCALC"   ,"C",08,0},;
	{"CDEMIREM"  ,"C",TAMSX3("GU3_CDEMIT")[1],0},;
	{"NMEMIREM"  ,"C",50,0},;
	{"CDEMIDEST" ,"C",TAMSX3("GU3_CDEMIT")[1],0},;
	{"NMEMIDEST" ,"C",50,0},;
	{"CDCIDORI"  ,"C",06,0},;
	{"NMCIDORI"  ,"C",50,0},;
	{"CDCIDDEST" ,"C",06,0},;
	{"NMCIDDEST" ,"C",50,0},;
	{"NMTPFRETE" ,"C",20,0},;
	{"NMTPCALC"  ,"C",20,0},;
	{"VLCALC"    ,"N",12,2}}

	aCpMKB3  := {{"NRCALC"   ,NIL,STR0026,"@!"},; //"Número do Cálculo"
	{"CDEMIREM"  ,NIL,STR0027        ,"@!"},; //"Remetente"
	{"NMEMIREM"  ,NIL,STR0028   ,"@!"},; //"Nome Remetente"
	{"CDEMIDEST" ,NIL,STR0029     ,"@!"},; //"Destinatario"
	{"NMEMIDEST" ,NIL,STR0030,"@!"},; //"Nome Destinatario"
	{"CDCIDORI"  ,NIL,STR0031       ,"@!"},; //"Cid Origem"
	{"NMCIDORI"  ,NIL,STR0032  ,"@!"},; //"Nome Cid Origem"
	{"CDCIDDEST" ,NIL,STR0033         ,"@!"},; //"Cid Dest"
	{"NMCIDDEST" ,NIL,STR0034    ,"@!"},; //"Nome Cid Dest"
	{"NMTPFRETE" ,NIL,STR0035    ,"@!"},;			 //"Tipo de Frete"
	{"NMTPCALC"  ,NIL,STR0036  ,"@!"},; //"Tipo de Calculo"
	{"VLCALC"    ,NIL,STR0037    ,"@E 999,999,999.99"}} //"Valor Cálculo"

	cAliMKB3 := GFECriaTab({aMKB3,{"NRCALC"}})

	CursorWait()

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 600,160 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	dbSelectArea(cAliMKB2)
	dbSetOrder(01)
	dbGoTop()
	oMark2 := MsSelect():New(cAliMKB3,,,aCpMKB3,,ThisMark(),{0,0,0,0},,,oPnlB)
	oMark2:oBrowse:cToolTip := STR0022 //"Visualização"
	oMark2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	Processa({|lEnd| GFEA55CRA()},STR0023,STR0038) //"Processando informações"###"Aguarde"

	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||ODlg:End()},;
	{||ODlg:End()},,)  CENTERED

	GFEDelTab(cAliMKB3)

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55CRA

Carrega a tabela temporaria de visualização de Cálculos vinculados a pré-fatura

@author Jorge Matos Valcanaia
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEA55CRA()
	Local cTPCALC
	Local cTPFRT
	Local cVLNRCALC

	dbSelectArea(cAliMKB3)
	ZAP

	dbSelectArea(cAliMKB1)
	dbSetOrder(1)

	dbSelectArea(cAliMKB2)
	dbSetOrder(1)
	dbGoTop()
	While !Eof()

		IF (cAliMKB1)->TRANSP == (cAliMKB2)->TRANSP .AND. ;
		(cAliMKB1)->GRUPO  == (cAliMKB2)->GRUPO  .AND. ;
		(cAliMKB1)->UF     == (cAliMKB2)->UF     .AND. ;
		(cAliMKB1)->CLASSI  == (cAliMKB2)->CLASSI  .AND. ;
		(cAliMKB1)->FILI   == (cAliMKB2)->FILI   .AND. ;
		(cAliMKB1)->CALC   == (cAliMKB2)->CALC

			dbSelectArea("GWF")
			dbSetOrder(1)
			dbGoTop()
			dbSeek((cAliMKB2)->FILI + (cAliMKB2)->NRCALC)

			If GWF->GWF_TPCALC == "1"
				cTPCALC := STR0039	 //"Normal"
			ElseIf GWF->GWF_TPCALC == "2"
				cTPCALC := STR0040 //"Compl Valor"
			ElseIf GWF->GWF_TPCALC == "3"
				cTPCALC := STR0041 //"Compl Imposto"
			ElseIf GWF->GWF_TPCALC == "4"
				cTPCALC := STR0042 //"Reentrega"
			ElseIf GWF->GWF_TPCALC == "5"
				cTPCALC := STR0043 //"Devolucao"
			ElseIf GWF->GWF_TPCALC == "6"
				cTPCALC := STR0044 //"Redespacho"
			ElseIf GWF->GWF_TPCALC == "7"
				cTPCALC := STR0045 //"Servico"
			ElseIf GWF->GWF_TPCALC == "8"
				cTPCALC := STR0046 //"Provisao"
			EndIf

			If GWF->GWF_TPFRET == "1"
				cTPFRT := STR0047 //"CIF"
			ElseIf GWF->GWF_TPFRET == "2"
				cTPFRT := STR0048 //"CIF Redesp."
			ElseIf GWF->GWF_TPFRET == "3"
				cTPFRT := STR0049 //"FOB"
			ElseIf GWF->GWF_TPFRET == "4"
				cTPFRT := STR0050 //"FOB Redesp."
			ElseIf GWF->GWF_TPFRET == "5"
				cTPFRT := STR0051 //"Consignado"
			ElseIf GWF->GWF_TPFRET == "6"
				cTPFRT := STR0058 //"Consig. Redesp."
			EndIf

			dbSelectArea("GWF")
			GWF->( dbSetOrder(1) )
			If GWF->( dbSeek((cAliMKB2)->FILIAL +(cAliMKB2)->NRCALC) )
				cVLNRCALC := VLTOTFRET()

			EndIf

			RecLock((cAliMKB3),.T.)

			(cAliMKB3)->NRCALC    := (cAliMKB2)->NRCALC
			(cAliMKB3)->CDEMIREM  := (cAliMKB2)->EMIREM
			(cAliMKB3)->NMEMIREM  := POSICIONE("GU3",1,XFILIAL("GU3")+(cAliMKB2)->EMIREM,"GU3_NMEMIT")
			(cAliMKB3)->CDEMIDEST := (cAliMKB2)->EMIDES
			(cAliMKB3)->NMEMIDEST := POSICIONE("GU3",1,XFILIAL("GU3")+(cAliMKB2)->EMIDES,"GU3_NMEMIT")
			(cAliMKB3)->CDCIDORI  := GWF->GWF_CIDORI
			(cAliMKB3)->NMCIDORI  := POSICIONE("GU7",1,XFILIAL("GU7")+GWF->GWF_CIDORI,"GU7_NMCID")
			(cAliMKB3)->CDCIDDEST := GWF->GWF_CIDDES
			(cAliMKB3)->NMCIDDEST := POSICIONE("GU7",1,XFILIAL("GU7")+GWF->GWF_CIDDES,"GU7_NMCID")
			(cAliMKB3)->NMTPFRETE := cTPFRT
			(cAliMKB3)->NMTPCALC  := cTPCALC
			(cAliMKB3)->VLCALC    := cVLNRCALC

			MsUnLock(cAliMKB3)
		ENDIF

		dbSelectArea(cAliMKB2)
		dbSkip()
	endDo

	dbSelectArea(cAliMKB3)
	dbGoTop()
	oMark2:oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55ALT

Abre uma tela de alteracao para que possa ser excluidos os calculos da pre-fatura

@author Jorge Matos Valcanaia
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA55ALT()

	Local oDlg
	Local nAlt := (GetScreenRes()[2]-150)
	Local nLrg := (GetScreenRes()[1]-100)
	Local cDSTRANSP

	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf

	If GWJ->GWJ_SIT == "2" .OR. GWJ->GWJ_SIT == "4" .Or. GWJ->GWJ_SIT == "3"
		msgInfo(STR0052,STR0013) //"Está Pré-Fatura não pode ser alterada."###"Aviso"
		Return .F.
	endif

	aNewButton := {}
	Aadd(aNewButton,{"bmpdel" ,{||GFEA55DEL()},STR0053,STR0053}) //"Excluir Vinculo"###"Excluir Vinculo"


	Private cCadastro := STR0054 //"Alteração"
	Private cMarca := GetMark()
	//----------------------------------------------
	// Criacao da tabela temporaria p/ Markbrowse
	//----------------------------------------------

	aMKB :=    {{"OK"        ,"C",02,0},;
				{"NRCALC"    ,"C",08,0},;
				{"CDEMIREM"  ,"C",TAMSX3("GU3_CDEMIT")[1],0},;
				{"NMEMIREM"  ,"C",50,0},;
				{"CDEMIDEST" ,"C",TAMSX3("GU3_CDEMIT")[1],0},;
				{"NMEMIDEST" ,"C",50,0},;
				{"CDCIDORI"  ,"C",06,0},;
				{"NMCIDORI"  ,"C",50,0},;
				{"CDCIDDEST" ,"C",06,0},;
				{"NMCIDDEST" ,"C",50,0},;
				{"NMTPFRETE" ,"C",20,0},;
				{"NMTPCALC"  ,"C",20,0},;
				{"FILIAL"    ,"C",TAMSX3("GWF_FILIAL")[1],0}}

	aCpMKB  := {{"OK"        ,NIL,""       ,"" },;
				{"NRCALC"    ,NIL,STR0026  ,"@!"},; //"Número do Cálculo"
				{"CDEMIREM"  ,NIL,STR0027  ,"@!"},; //"Remetente"
				{"NMEMIREM"  ,NIL,STR0028  ,"@!"},; //"Nome Remetente"
				{"CDEMIDEST" ,NIL,STR0029  ,"@!"},; //"Destinatario"
				{"NMEMIDEST" ,NIL,STR0030  ,"@!"},; //"Nome Destinatario"
				{"CDCIDORI"  ,NIL,STR0031  ,"@!"},; //"Cid Origem"
				{"NMCIDORI"  ,NIL,STR0032  ,"@!"},; //"Nome Cid Origem"
				{"CDCIDDEST" ,NIL,STR0033  ,"@!"},; //"Cid Dest"
				{"NMCIDDEST" ,NIL,STR0034  ,"@!"},; //"Nome Cid Dest"
				{"NMTPFRETE" ,NIL,STR0035  ,"@!"},; //"Tipo de Frete"
				{"NMTPCALC"  ,NIL,STR0036  ,"@!"}}  //"Tipo de Calculo"

	cAliMKB := GFECriaTab({aMKB,{"NRCALC"}})

	CursorWait()

	//--------------------------
	// Montagem da tela
	//--------------------------
	Define MsDialog oDlg Title cCadastro From 500,120 To nAlt,nLrg Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel
	oDlg:lEscClose := .F.

	oPnlA := tPanel():New(00,00,,oDlg,,,,,,30,35,.F.,.F.)
	oPnlA:Align := CONTROL_ALIGN_TOP

	oPnlB := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlB:Align := CONTROL_ALIGN_ALLCLIENT

	cDSTRANSP := posicione("GU3",1,xFilial("GU3")+GWJ->GWJ_CDTRP,"GU3_NMEMIT")

	@ 07,15  Say STR0055 Of oPnlA COLOR CLR_BLACK Pixel //"Número Pré-Fatura: "
	@ 05,63  MSGET GWJ->GWJ_NRPF Picture "@!" Of oPnlA When .F.   Pixel

	@ 07,120 Say STR0056              Of oPnlA COLOR CLR_BLACK Pixel //"Situação: "
	@ 05,144 MSGET GWJ->GWJ_SIT  Picture "@!" Of oPnlA When .F.   Pixel

	@ 21,27 Say STR0057  Of oPnlA COLOR CLR_BLACK Pixel //"Transportador: "
	@ 19,63 MSGET cDSTRANSP Picture "@!" Of oPnlA When .F.   Pixel

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	oMark := MsSelect():New(cAliMKB,"OK",,aCpMKB,,@cMarca,{0,0,0,0},,,oPnlB)
	oMark:oBrowse:bLDblClick := { || GFEA55CHK() }
	oMark:oBrowse:cToolTip := STR0022 //"Visualização"
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	Processa({|lEnd| GFEA55CGA()},STR0023,STR0038) //"Processando informações"###"Aguarde"

	CursorArrow()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||ODlg:End()},;
	{||If(APMSGYESNO(STR0024),ODlg:End(),)},,aNewButton) CENTERED  //"Deseja cancelar esse processo?"

	GFEDelTab(cAliMKB)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55CGA

Carrega a tabela temporaria com os calculos vinculados a Pre-fatura

@author Jorge Matos Valcanaia
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEA55CGA()
	Local cTPCALC, cTPFRT

	dbSelectArea(cAliMKB)
	ZAP

	dbSelectArea("GWF")
	dbSetOrder(03)
	dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF)
	While !Eof() .AND. GWF->GWF_FILPRE == GWJ->GWJ_FILIAL .AND. GWF->GWF_NRPREF == GWJ->GWJ_NRPF

		dbSelectArea(cAliMKB)

		If GWF->GWF_TPCALC == "1"
			cTPCALC := STR0039	 //"Normal"
		ElseIf GWF->GWF_TPCALC == "2"
			cTPCALC := STR0040 //"Compl Valor"
		ElseIf GWF->GWF_TPCALC == "3"
			cTPCALC := STR0041 //"Compl Imposto"
		ElseIf GWF->GWF_TPCALC == "4"
			cTPCALC := STR0042 //"Reentrega"
		ElseIf GWF->GWF_TPCALC == "5"
			cTPCALC := STR0043 //"Devolucao"
		ElseIf GWF->GWF_TPCALC == "6"
			cTPCALC := STR0044 //"Redespacho"
		ElseIf GWF->GWF_TPCALC == "7"
			cTPCALC := STR0045 //"Servico"
		ElseIf GWF->GWF_TPCALC == "8"
			cTPCALC := STR0046 //"Provisao"
		EndIf

		If GWF->GWF_TPFRET == "1"
			cTPFRT := STR0047 //"CIF"
		ElseIf GWF->GWF_TPFRET == "2"
			cTPFRT := STR0048 //"CIF Redesp."
		ElseIf GWF->GWF_TPFRET == "3"
			cTPFRT := STR0049 //"FOB"
		ElseIf GWF->GWF_TPFRET == "4"
			cTPFRT := STR0050 //"FOB Redesp."
		ElseIf GWF->GWF_TPFRET == "5"
			cTPFRT := STR0051 //"Consignado"
		ElseIf GWF->GWF_TPFRET == "6"
			cTPFRT := STR0058 //"Consig. Redesp."
		EndIf

		RecLock(cAliMKB, .T.)
		(cAliMKB)->FILIAL    := GWF->GWF_FILIAL
		(cAliMKB)->NRCALC    := GWF->GWF_NRCALC
		(cAliMKB)->CDEMIREM  := GWF->GWF_EMIREM
		(cAliMKB)->NMEMIREM  := POSICIONE("GU3",1,XFILIAL("GU3")+GWF->GWF_EMIREM,"GU3_NMEMIT")
		(cAliMKB)->CDEMIDEST := GWF->GWF_EMIDES
		(cAliMKB)->NMEMIDEST := POSICIONE("GU3",1,XFILIAL("GU3")+GWF->GWF_EMIDES,"GU3_NMEMIT")
		(cAliMKB)->CDCIDORI  := GWF->GWF_CIDORI
		(cAliMKB)->NMCIDORI  := POSICIONE("GU7",1,XFILIAL("GU7")+GWF->GWF_CIDORI,"GU7_NMCID")
		(cAliMKB)->CDCIDDEST := GWF->GWF_CIDDES
		(cAliMKB)->NMCIDDEST := POSICIONE("GU7",1,XFILIAL("GU7")+GWF->GWF_CIDDES,"GU7_NMCID")
		(cAliMKB)->NMTPFRETE := cTPFRT
		(cAliMKB)->NMTPCALC  := cTPCALC
		(cAliMKB)->( MsUnLock() )


		dbSelectArea("GWF")
		dbSkip()

	EndDo

	dbSelectArea(cAliMKB)
	dbGoTOp()
	oMark:oBrowse:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55CHK

Verifica se já existe um registro marcado

@author Jorge Matos Valcanaia
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEA55CHK()

	Local lMArk := .T.
	Local nREc  := (cAliMKB)->(RecNo())

	dbSelectArea(cAliMKB)
	dbSetOrder(01)

	dbGoTo(nRec)
	If lMArk
		RecLock(cAliMKB,.F.)
		(cAliMKB)->OK := If(IsMark('OK',ThisMark()),"  ",ThisMark())
		MsUnLock(cAliMKB)

	EndIf

	oMark:oBrowse:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55DEL

Exclui o vinculo entre o calculo e a pré-fatura

@author Jorge Matos Valcanaia
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA55DEL()

	Local lRet  := .T.
	Local cCont := 0
	Local oModel := FWLoadModel("GFEA055")
	Local oModelGWJ
	Local oModelGWF


	oModelGWJ := oModel:GetModel("GFEA055_GWJ")
	oModelGWF := oModel:GetModel("GFEA055_GWF")

	dbSelectArea(cAliMKB)
	dbSetOrder(01)
	dbGoTop()
	While !Eof()

		If IsMark('OK',ThisMark())
			cCont = cCont + 1
		endif

		dbSelectArea(cAliMKB)
		dbSkip()
	enddo

	If (cAliMKB)->(reccount()) == cCont
		msgInfo("Não é permitido excluir todos os Cálculos Vinculados.") 
		lRet  := .F.
	EndIF

	oModel:Deactivate()
	oModel:SetOperation(4)
	oModel:Activate()

	If lRet == .T.
		dbSelectArea(cAliMKB)
		dbSetOrder(01)
		dbGoTop()

		While !Eof()
			If IsMark('OK',ThisMark())
				dbSelectArea("GWF")
				dbSetOrder(1)
				IF dbSeek( (cAliMKB)->FILIAL + (cAliMKB)->NRCALC )

					oModelGWF:AddLine()
					oModelGWF:LoadValue("GWF_NRPREF","")
					oModelGWF:LoadValue("GWF_FILPRE","")
					oModelGWF:LoadValue("GWF_NRCALC",GWF->GWF_NRCALC)
					oModelGWF:LoadValue("GWF_EMIREM",GWF->GWF_EMIREM)
					oModelGWF:LoadValue("GWF_EMIDES",GWF->GWF_EMIDES)
					oModelGWF:LoadValue("GWF_EMIPAG",GWF->GWF_EMIPAG)
					oModelGWF:LoadValue("GWF_TRANSP",GWF->GWF_TRANSP)
					oModelGWF:LoadValue("GWF_ORIGEM",GWF->GWF_ORIGEM)
					oModelGWF:LoadValue("GWF_TPCALC",GWF->GWF_TPCALC)
					oModelGWF:LoadValue("GWF_TPFRET",GWF->GWF_TPFRET)
					oModelGWF:LoadValue("GWF_FINCAL",GWF->GWF_FINCAL)
					oModelGWF:LoadValue("GWF_CIDORI",GWF->GWF_CIDORI)
					oModelGWF:LoadValue("GWF_CIDDES",GWF->GWF_CIDDES)
					oModelGWF:LoadValue("GWF_ENDENT",GWF->GWF_ENDENT)
					oModelGWF:LoadValue("GWF_BAIENT",GWF->GWF_BAIENT)
					oModelGWF:LoadValue("GWF_CIDENT",GWF->GWF_CIDENT)
					oModelGWF:LoadValue("GWF_DTCRIA",GWF->GWF_DTCRIA)
					oModelGWF:LoadValue("GWF_HRCRIA",GWF->GWF_HRCRIA)
					oModelGWF:LoadValue("GWF_USUCRI",GWF->GWF_USUCRI)
					oModelGWF:LoadValue("GWF_DTPREN",GWF->GWF_DTPREN)
					oModelGWF:LoadValue("GWF_HRPREN",GWF->GWF_HRPREN)
					oModelGWF:LoadValue("GWF_CARREG",GWF->GWF_CARREG)
					oModelGWF:LoadValue("GWF_NRROM" ,GWF->GWF_NRROM )
					oModelGWF:LoadValue("GWF_VLAJUS",GWF->GWF_VLAJUS)
					oModelGWF:LoadValue("GWF_TPTRIB",GWF->GWF_TPTRIB)
					oModelGWF:LoadValue("GWF_BASISS",GWF->GWF_BASISS)
					oModelGWF:LoadValue("GWF_PCISS" ,GWF->GWF_PCISS )
					oModelGWF:LoadValue("GWF_VLISS" ,GWF->GWF_VLISS )
					oModelGWF:LoadValue("GWF_BASICM",GWF->GWF_BASICM)
					oModelGWF:LoadValue("GWF_PCICMS",GWF->GWF_PCICMS)
					oModelGWF:LoadValue("GWF_PCREIC",GWF->GWF_PCREIC)
					oModelGWF:LoadValue("GWF_VLICMS",GWF->GWF_VLICMS)
					oModelGWF:LoadValue("GWF_ICMRET",GWF->GWF_ICMRET)
					oModelGWF:LoadValue("GWF_BAPICO",GWF->GWF_BAPICO)
					oModelGWF:LoadValue("GWF_VLPIS" ,GWF->GWF_VLPIS )
					oModelGWF:LoadValue("GWF_VLCOFI",GWF->GWF_VLCOFI)
					oModelGWF:LoadValue("GWF_NRCONT",GWF->GWF_NRCONT)
					oModelGWF:LoadValue("GWF_IDFRVI",GWF->GWF_IDFRVI)
					oModelGWF:LoadValue("GWF_AGRUP" ,GWF->GWF_AGRUP )
					oModelGWF:LoadValue("GWF_SEQTRE",GWF->GWF_SEQTRE)
					oModelGWF:LoadValue("GWF_OBS"   ,GWF->GWF_OBS   )
					oModelGWF:LoadValue("GWF_IMPOST",GWF->GWF_IMPOST)
					oModelGWF:LoadValue("GWF_CRDICM",GWF->GWF_CRDICM)
					oModelGWF:LoadValue("GWF_CRDPC" ,GWF->GWF_CRDPC )
					oModelGWF:LoadValue("GWF_NROCO" ,GWF->GWF_NROCO )
					oModelGWF:LoadValue("GWF_ADICIS",GWF->GWF_ADICIS)


				EndIf
			EndIf
			dbSelectArea(cAliMKB)
			dbSkip()
		EndDo

		oModelGWJ:LoadValue("GWJ_SIT","1")

		If oModel:VldData()
			oModel:CommitData()
		EndIf

	Endif


	Processa({|lEnd| GFEA55CGA()},STR0023,STR0038) //"Processando informações"###"Aguarde"

Return (lREt)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55CHC

Verifica se já existe um registro marcado

@author Jorge Matos Valcanaia
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GFEA55CHC()

	If Empty((cAliMKB1)->DTVENC)
		Help(,, 'Help',, "A pré-fatura não possui data de vencimento, portanto, não poderá ser selecionada.", 1, 0 )
		Return
	EndIf

	RecLock(cAliMKB1, .F.)
	(cAliMKB1)->OK := IIf(IsMark('OK', cMarca1),"  ", cMarca1)
	(cAliMKB1)->( MsUnLock() )

	oMark1:oBrowse:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA55GER

Grava na tabela  os registros selecionados pelo usuario na tela de Simulação.

@author Jorge Matos Valcanaia
@since 10/12/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA55GER()

	Local lRet      	:= .T.
	Local lRetGrava
	Local cCont 		:= 0
	Local cNRPF
	Local aPreFat 		:= {}
	Local aPreFatFin 	:= {} //Pré faturas atualizadas do financeiro

	Local oModel
	Local oModelGWJ
	Local oModelGWF
	Local cHrapr
	Local cCautpf
	Local cTranspft //Transportador do faturamento
	Local cFilAntOld
	Local dData
	Local c_GFEI15   	:= SuperGetMV('MV_GFEI15',,'1')	

	If IsBlind()
		dData := DATE()
	Else
		dData := DDATABASE
	EndIf

	dbSelectArea(cAliMKB1)
	dbSetOrder(01)
	dbGoTop()
	While !Eof()

		If !IsMark('OK',cMarca1)
			cCont = cCont + 1
		endif

		dbSelectArea(cAliMKB1)
		dbSkip()
	EndDo

	If (cAliMKB1)->(reccount()) == cCont
		MsgInfo(STR0060,STR0013) //"Não existe nenhuma Pré-fatura selecionada para ser Criada."###"Aviso"
		lRet  := .F.
	EndIF

	If lRet == .T.

		dbSelectArea(cAliMKB)
		dbSetOrder(1)
		dbGoTop()
		while !eof()

			dbSelectARea(cAliMKB1)
			dbSetOrder(1)
			dbGoTop()
			While !Eof()

				If (cAliMKB)->NRPF == (cAliMKB1)->NRPF

					recLock((cAliMKB),.F.)

					(cAliMKB)->OK := (cAliMKB1)->OK

					MsUnLock(cAliMKB)


				Endif

				dbSelectArea(cAliMKB1)
				dbSkip()
			EndDo
			dbSelectArea(cAliMKB)
			dbSkip()
		EndDo

		oModel := FWLoadModel("GFEA055")
		oModelGWJ := oModel:GetModel("GFEA055_GWJ")
		oModelGWF := oModel:GetModel("GFEA055_GWF")

		dbSelectArea(cAliMKB)
		dbSetOrder(1)
		dbGoTop()
		while !eof()

			cFilAnt := (cAliMKB)->FILIAL
			lRetGrava := .F.

			oModel:SetOperation(3)
			oModel:Activate()

			cNRPF := GETSXENUM("GWJ","GWJ_NRPF")
			dbSelectArea(cAliMKB2)
			dbSetOrder(1)
			dbGoTop()

			While !(cAliMKB2)->(Eof())

				IF (cAliMKB)->TRANSP == (cAliMKB2)->TRANSP .AND. ;
				(cAliMKB)->GRUPO  == (cAliMKB2)->GRUPO  .AND. ;
				(cAliMKB)->UF     == (cAliMKB2)->UF     .AND. ;
				(cAliMKB)->CLASSI  == (cAliMKB2)->CLASSI  .AND. ;
				(cAliMKB)->FILI   == (cAliMKB2)->FILI   .AND. ;
				(cAliMKB)->CALC   == (cAliMKB2)->CALC

					If  ALLTRIM((cAliMKB)->OK) <> ""

						dbSelectArea("GWF")
						dbSetOrder(1)
						dbSeek((cAliMKB2)->FILIAL+(cAliMKB2)->NRCALC)

						oModelGWF:AddLine()
						oModelGWF:LoadValue("GWF_FILIAL",(cAliMKB)->FILIAL)
						oModelGWF:LoadValue("GWF_NRPREF",cNRPF)
						oModelGWF:LoadValue("GWF_FILPRE",(cAliMKB)->FILIAL)
						oModelGWF:LoadValue("GWF_NRCALC",GWF->GWF_NRCALC)
						oModelGWF:LoadValue("GWF_EMIREM",GWF->GWF_EMIREM)
						oModelGWF:LoadValue("GWF_EMIDES",GWF->GWF_EMIDES)
						oModelGWF:LoadValue("GWF_EMIPAG",GWF->GWF_EMIPAG)
						oModelGWF:LoadValue("GWF_TRANSP",GWF->GWF_TRANSP)
						oModelGWF:LoadValue("GWF_ORIGEM",GWF->GWF_ORIGEM)
						oModelGWF:LoadValue("GWF_TPCALC",GWF->GWF_TPCALC)
						oModelGWF:LoadValue("GWF_TPFRET",GWF->GWF_TPFRET)
						oModelGWF:LoadValue("GWF_FINCAL",GWF->GWF_FINCAL)
						oModelGWF:LoadValue("GWF_CIDORI",GWF->GWF_CIDORI)
						oModelGWF:LoadValue("GWF_CIDDES",GWF->GWF_CIDDES)
						oModelGWF:LoadValue("GWF_ENDENT",GWF->GWF_ENDENT)
						oModelGWF:LoadValue("GWF_BAIENT",GWF->GWF_BAIENT)
						oModelGWF:LoadValue("GWF_CIDENT",GWF->GWF_CIDENT)
						oModelGWF:LoadValue("GWF_DTCRIA",GWF->GWF_DTCRIA)
						oModelGWF:LoadValue("GWF_HRCRIA",GWF->GWF_HRCRIA)
						oModelGWF:LoadValue("GWF_USUCRI",GWF->GWF_USUCRI)
						oModelGWF:LoadValue("GWF_DTPREN",GWF->GWF_DTPREN)
						oModelGWF:LoadValue("GWF_HRPREN",GWF->GWF_HRPREN)
						oModelGWF:LoadValue("GWF_CARREG",GWF->GWF_CARREG)
						oModelGWF:LoadValue("GWF_NRROM" ,GWF->GWF_NRROM )
						oModelGWF:LoadValue("GWF_VLAJUS",GWF->GWF_VLAJUS)
						oModelGWF:LoadValue("GWF_TPTRIB",GWF->GWF_TPTRIB)
						oModelGWF:LoadValue("GWF_BASISS",GWF->GWF_BASISS)
						oModelGWF:LoadValue("GWF_PCISS" ,GWF->GWF_PCISS )
						oModelGWF:LoadValue("GWF_VLISS" ,GWF->GWF_VLISS )
						oModelGWF:LoadValue("GWF_BASICM",GWF->GWF_BASICM)
						oModelGWF:LoadValue("GWF_PCICMS",GWF->GWF_PCICMS)
						oModelGWF:LoadValue("GWF_PCREIC",GWF->GWF_PCREIC)
						oModelGWF:LoadValue("GWF_VLICMS",GWF->GWF_VLICMS)
						oModelGWF:LoadValue("GWF_ICMRET",GWF->GWF_ICMRET)
						oModelGWF:LoadValue("GWF_BAPICO",GWF->GWF_BAPICO)
						oModelGWF:LoadValue("GWF_VLPIS" ,GWF->GWF_VLPIS )
						oModelGWF:LoadValue("GWF_VLCOFI",GWF->GWF_VLCOFI)
						oModelGWF:LoadValue("GWF_NRCONT",GWF->GWF_NRCONT)
						oModelGWF:LoadValue("GWF_IDFRVI",GWF->GWF_IDFRVI)
						oModelGWF:LoadValue("GWF_AGRUP" ,GWF->GWF_AGRUP )
						oModelGWF:LoadValue("GWF_SEQTRE",GWF->GWF_SEQTRE)
						oModelGWF:LoadValue("GWF_OBS"   ,GWF->GWF_OBS   )
						oModelGWF:LoadValue("GWF_IMPOST",GWF->GWF_IMPOST)
						oModelGWF:LoadValue("GWF_CRDICM",GWF->GWF_CRDICM)
						oModelGWF:LoadValue("GWF_CRDPC" ,GWF->GWF_CRDPC )
						oModelGWF:LoadValue("GWF_NROCO" ,GWF->GWF_NROCO )
						oModelGWF:LoadValue("GWF_ADICIS",GWF->GWF_ADICIS)

						lRetGrava := .T.

					Endif
				Endif
				dbSelectArea(cAliMKB2)
				dbSkip()
			EndDo

			ConfirmSX8()

			If lRetGrava == .T.

				dbSelectArea("GWJ")
				dbSetOrder(1)

				cTranspft := POSICIONE("GU3",1,xFilial("GU3")+(cAliMKB)->CDTRP,"GU3_CDEMFT")
				AAdd(aPreFat, {cNRPF, IIF(!Empty(cTranspft),cTranspft, (cAliMKB)->CDTRP)})

				oModelGWJ:LoadValue("GWJ_FILIAL" ,(cAliMKB)->FILIAL)
				oModelGWJ:LoadValue("GWJ_NRPF"   ,cNRPF)
				oModelGWJ:LoadValue("GWJ_CDTRP"  ,IIF(!Empty(cTranspft),cTranspft, (cAliMKB)->CDTRP))
				oModelGWJ:LoadValue("GWJ_DTVCTO" ,(cAliMKB)->DTVENC)
				oModelGWJ:LoadValue("GWJ_SIT"    ,(cAliMKB)->SIT)
				oModelGWJ:LoadValue("GWJ_DTIMPL" ,(cAliMKB)->DTIMPL)
				oModelGWJ:LoadValue("GWJ_HRIMPL" ,(cAliMKB)->HRIMPL)
				oModelGWJ:LoadValue("GWJ_USUIMP" ,(cAliMKB)->USUIMP)
				oModelGWJ:LoadValue("GWJ_SITFIN" ,"1")


				RecLock((cAliMKB1), .T.)

				(cAliMKB)->NRPF := ""
				(cAliMKB)->OK   := ""

				MsUnLock(cAliMKB1)

				cCautpf := ""
				dbSelectArea( "GU3" )
				GU3->( dbSetOrder( 1 ) )
				If GU3->( dbSeek( xFilial("GU3") + (cAliMKB)->CDTRP ) )
					cCautpf := GU3->GU3_CAUTPF
					If cCautpf == "1" //Aprova pré-fatura automático

						cHrapr := SUBSTR(TIME(),1,5)
						oModelGWJ:LoadValue("GWJ_SIT" ,"3")
						oModelGWJ:LoadValue("GWJ_DTAPR" ,dData)
						oModelGWJ:LoadValue("GWJ_HRAPR" ,cHrapr)
						oModelGWJ:LoadValue("GWJ_USUAPR" ,cUserName )

					EndIf
				EndIf

			EndIf

			If  oModel:VldData()
				oModel:CommitData()
			EndIf

			oModel:DeActivate()

			If cCautpf == "1" .AND. c_TPGERA == "1"
				GFEACTBPRE((cAliMKB)->FILIAL , cNRPF)
			EndIf
			cCautpf := ""

			If GWJ->( dbSeek( (cAliMKB)->FILIAL + cNRPF ) ) .AND. GU3->GU3_CAUTPF == "1"
				If c_GFEI15 == '2' //Financeiro
					AADD(aPreFatFin, GFEA055X(.T.,oModel))
				EndIf
			EndIf

			dbSelectArea(cAliMKB)
			dbSkip()
		EndDo

		cFilAnt := cFilAntOld
		oModel:Destroy()
		GFEA055LOG(aPreFat,,, aPreFatFin)

	EndIf

	Processa({|lEnd| GFEA55CRG()},STR0023,STR0038) //"Processando informações"###"Aguarde"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA055VL

Retorna o valor da pré-fatura

@author Felipe Mendes
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA055VL(lFat)

	Local nVLPF := 0
	Default lFat := .F.

	IF lFat .AND.;
	GWJ->GWJ_FILFAT + GWJ->GWJ_EMIFAT + GWJ->GWJ_SERFAT + GWJ->GWJ_NRFAT + DTOS(GWJ->GWJ_DTEMFA) != ;
	GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DTOS(GW6->GW6_DTEMIS)
		Return 0
	EndIf
	dbselectarea("GWF")
	GWF->( dbSetOrder(3) ) //GWF_FILPRE+GWF_NRPREF
	GWF->( dbSeek(GWJ->GWJ_FILIAL + GWJ->GWJ_NRPF) )
	While !GWF->( Eof() ) .And. GWJ->GWJ_FILIAL + GWJ->GWJ_NRPF == GWF->GWF_FILPRE + GWF->GWF_NRPREF

		nVLPF += VLTOTFRET()

		GWF->( dbSkip() )

	EndDo

	Return nVLPF

	//---------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} GFEA055X()
	Integração com EMS
	Generico

	@sample
	GFEA055X(.F.)

	@Param
	lAutom := Identifica se a chamada pertence a um ponto automatizado

	@author Felipe Mendes
	@since 02/02/2012
	@version 1.0
	/*///------------------------------------------------------------------------------------------------
Function GFEA055X(lAutom,oMdl55)
	Local aRet := Array(2)
	Local aRetIn := {}
	Local dData 
	Local lOk := .F.
	Local cParData := SuperGetMV('MV_DSDTAP',,'1') // Parametro Int Origem Data de Integração
	Local cNrPf
	Local cCdTrp
	Local cNmTrp
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local lExistCamp := GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local oModel55
	Local nERPInt := SuperGetMv("MV_ERPGFE")
	Default lAutom:= .F.
	Default oMdl55 := FWLoadModel("GFEA055")
	Private GFEResult := GFEViewProc():New()

	If IsBlind()
		dData := DATE()
	Else 
		dData := DDATABASE	
	EndIf	

	oModel55 := oMdl55

	IF oModel55 == NIL
		oModel55 := FWLoadModel("GFEA055")
	Else
		If oModel55:CID != "GFEA055"
			oModel55 := FWLoadModel("GFEA055")
		EndIf
	EndIF

	aRet[1] := .F.
	aRet[2] := {}

	If GWJ->GWJ_SIT == "3"
		If GWJ->GWJ_SITFIN == "1" .Or. GWJ->GWJ_SITFIN == "3"
			If lExistCamp //Utiliza novo índice entre GWF e GW3 para verificar se os documentos estão vinculados à faturas
				cQuery := " SELECT DISTINCT GW4.GW4_NRDC,GW6.GW6_NRFAT"
				cQuery += "   FROM "+RetSqlName('GWF')+" GWF"
				cQuery += "  INNER JOIN "+RetSqlName('GW3')+" GW3"
				cQuery += "     ON GW3.GW3_FILIAL = GWF.GWF_FILIAL"
				cQuery += "    AND GW3.GW3_CDESP  = GWF.GWF_CDESP"
				cQuery += "    AND GW3.GW3_EMISDF = GWF.GWF_EMISDF"
				cQuery += "    AND GW3.GW3_SERDF  = GWF.GWF_SERDF" 
				cQuery += "    AND GW3.GW3_NRDF   = GWF.GWF_NRDF"
				cQuery += "    AND GW3.GW3_DTEMIS = GWF.GWF_DTEMDF"
				cQuery += "    AND GW3.D_E_L_E_T_ = ' '"
				cQuery += "  INNER JOIN "+RetSqlName('GW4')+" GW4" 
				cQuery += "     ON GW4.GW4_FILIAL = GW3.GW3_FILIAL"
				cQuery += "    AND GW4.GW4_EMISDF = GW3.GW3_EMISDF"
				cQuery += "    AND GW4.GW4_CDESP  = GW3.GW3_CDESP"
				cQuery += "    AND GW4.GW4_SERDF  = GW3.GW3_SERDF" 
				cQuery += "    AND GW4.GW4_NRDF   = GW3.GW3_NRDF"
				cQuery += "    AND GW4.GW4_DTEMIS = GW3.GW3_DTEMIS"
				cQuery += "    AND GW4.D_E_L_E_T_ = ' '"
				cQuery += "  INNER JOIN "+RetSqlName('GW6')+" GW6"
				cQuery += "     ON GW6.GW6_FILIAL = GW3.GW3_FILFAT"
				cQuery += "    AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
				cQuery += "    AND GW6.GW6_SERFAT = GW3.GW3_SERFAT" 
				cQuery += "    AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT"
				cQuery += "    AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA"
				cQuery += "    AND GW6.GW6_SITFIN <> '1'"
				cQuery += "    AND GW6.D_E_L_E_T_ = ' '"
				cQuery += "  WHERE GWF_FILPRE = '"+GWJ->GWJ_FILIAL+"'"
				cQuery += "    AND GWF_NRPREF = '"+GWJ->GWJ_NRPF+"'"
				cQuery += "    AND GWF.D_E_L_E_T_ = ' '" 
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

				While (cAliasQry)->(!EoF())

					GFEResult:Add("Documento: "+ Alltrim((cAliasQry)->GW4_NRDC) +", vinculado a fatura "+ Alltrim((cAliasQry)->GW6_NRFAT))

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
			Else
				dbSelectArea("GWF") // CALCULO DE FRETE
				dbSetOrder(3)
				If GWF->(dbSeek(GWJ->GWJ_FILIAL + GWJ->GWJ_NRPF))
					While !GWF->(Eof()) .AND. GWF->GWF_FILPRE == GWJ->GWJ_FILIAL .AND. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
						dbSelectArea("GWH") //DOCUMENTO DO CALCULO DE FRETE
						dbSetOrder(1)
						If GWH->(dbseek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
							While !GWH->(Eof()) .AND. GWH->GWH_NRCALC == GWF->GWF_NRCALC
								dbSelectArea("GW1") //DOCUMENTOS DE CARGA
								dbSetOrder(1)
								If GW1->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC))
									dbSelectArea("GW4") //DOCTOS CARGA DOS DOCTOS FRETE
									GW4->( dbSetOrder(2) )
									If GW4->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC + GW1->GW1_CDTPDC))
										dbSelectArea("GW3") //DOCUMENTOS DE FRETE
										GW3->( dbSetOrder(1) )
										If GW3->(dbSeek(GW4->GW4_FILIAL + GW4->GW4_CDESP + GW4->GW4_EMISDF + GW4->GW4_SERDF + GW4->GW4_NRDF + DTOS(GW4->GW4_DTEMIS)))
											// SE TIPO FOR IGUAL, VERIFICA SE JÁ ESTÁ VINCULADO A FATURA
											IF GW3->GW3_TPDF = GWF->GWF_TPCALC
												dbSelectArea("GW6") //FATURA DE FRETE
												GW6->( dbSetOrder(1) )
												If GW6->(dbSeek(GW3->GW3_FILIAL + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DTOS(GW3->GW3_DTEMFA)))
													If GW6->GW6_SITFIN != '1'
														GFEResult:Add("Documento: "+alltrim(GW4->GW4_NRDC)+", vinculado a fatura "+alltrim(GW6->GW6_NRFAT))
														GWH->(dbSkip())
														Loop
													EndIf
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
								GWH->(dbSkip())
							EndDo
						EndIf
						GWF->(dbSkip())
					EndDo
				EndIf
			EndIf

			If !GFEResult:EmptyMsg()
				GFEResult:Show("Atualização não realizada","Documentos vinculados a faturas enviadas")
				Return (aRet)
			EndIf

			If SuperGetMV("MV_ERPGFE",,"2") == '2' //quando o ERP for Protheus a data de integração/transação será atribuída pelo sistema com a data corrente
				lOk := .T.
			Else
				If cParData == "3" //Informada Usuário
					DEFINE DIALOG oDlg TITLE "Seleciona a Data" FROM 180,180 TO 350,460 PIXEL //
					// Cria objeto
					oMsCalend := MsCalend():New(01,01,oDlg,.F.)

					// Define o dia a ser exibido no calendário
					oMsCalend:dDiaAtu := dData

					// Code-Block para mudança de Dia
					//oMsCalend:bChange := {|| Alert('Dia Selecionado: ' + dtoc(oMsCalend:dDiaAtu)) }
					oMsCalend:bChange := {|| dData := oMsCalend:dDiaAtu}

					// Code-Block para mudança de mes
					//oMsCalend:bChangeMes := {|| alert('Mes alterado') }

					oTButton1 := TButton():New( 070, 30, "Ok"      ,oDlg,{||lOk := .T.,oDlg:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //
					oTButton1 := TButton():New( 070, 75, "Cancelar",oDlg,{||oDlg:End()}           , 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) //

					ACTIVATE DIALOG oDlg CENTERED

				ElseIf cParData == "1" 		//Data Corrente
					lOk := .T.
				ElseIf cParData == "2" 		//Data Criação
					dData := GWJ->GWJ_DTIMPL
					lOk := .T.
				EndIf
			EndIf

			If dData < GWJ->GWJ_DTIMPL .AND. cParData != "2"
				If !lAutom
					Help( ,, 'Help',, "A data de transação deve ser maior que a data de criação", 1, 0 )
				EndIf
				lOk := .F.
			EndIf

			If lOk .And. dData < SuperGetMv("MV_DTULFE",,"20000101")
				If !lAutom
					Help( ,, 'Help',, "Data de transação deve ser posterior à data do último fechamento: " + DToC(SuperGetMv("MV_DTULFE",,"20000101")) + " (Parâmetro MV_DTULFE)", 1, 0 ) // //
				EndIf
				lOk := .F.
			EndIf

			// Não é permitido integrar Pré-fatura sem data de vencimento, mesmo não sendo possível gerar sem data, foi colocado por garantia de ser exceutado por fora.
			If lOk .And. Empty(GWJ->GWJ_DTVCTO)
				If !lAutom
					Help( ,, 'Help',, "Data de Vencimento não pode estar em branco.", 1, 0 )
				EndIf
				lOk := .F.
			EndIf

			If lOk
				// Datasul
				If nERPInt = "1" 
					RecLock("GWJ", .F.)
					GWJ->GWJ_SITFIN := "2"
					GWJ->GWJ_MOTFIN := ""
					GWJ->GWJ_DTFIN  := dData
					GWJ->( MsUnlock() )
				Else
					aRetIn := GFEA055In("2", dData, oModel55)

					cNrPf  := GWJ->GWJ_NRPF
					cCdTrp := GWJ->GWJ_CDTRP
					cNmTrp := POSICIONE("GU3",1,xFILIAL("GU3")+cCdTrp,"GU3_NMEMIT")

					If aRetIn[1]
						If(lAutom)
							aRet[1] := .T.
							aRet[2] := AllTrim(cNrPf)+" Transp: "+AllTrim(cCdTrp)+" - "+AllTrim(cNmTrp)
							Return (aRet)
						Else
							If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
								MsgInfo("Pré-fatura enviada para atualização no Financeiro.")
							EndIf
						EndIf
					Else
						If(lAutom)
							aRet[1] := .F.
							aRet[2] := AllTrim(cNrPf)+" Transp: "+AllTrim(cCdTrp)+" - "+AllTrim(cNmTrp)+CRLF+" - Erro: "+aRetIn[2][6]
							Return (aRet)
						ElseIf !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
							MsgInfo("Pré-fatura não foi enviada para atualização no Financeiro por causa do seguinte erro: " + aRetIn[2][6])
						EndIf
					EndIf
				EndIf

			EndIf

		Else
			If !lAutom
				Help( ,, 'Help',, "Pré-fatura Pendente ou já Atualizada", 1, 0 )
			EndIf
		EndIf
	Else
		If !lAutom
			Help( ,, 'Help',, "Pré-fatura não aprovada", 1, 0 )
		EndIf
	EndIf

Return (aRet)

//------------------------Função para desatualizar a pré-fatura no financeiro

Function GFEA055DX()
	Local aRet
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local oModel55
	Local oMdl55
	Local nERPInt := SuperGetMv("MV_ERPGFE")
	Default oMdl55 := FWLoadModel("GFEA055")

	oModel55 := oMdl55

	IF oModel55 == NIL
		oModel55 := FWLoadModel("GFEA055")
	Else
		If oModel55:CID != "GFEA055"
			oModel55 := FWLoadModel("GFEA055")
		EndIf
	EndIF

	If GWJ->GWJ_SITFIN != "4"
		Help( ,, 'Help',, "A Pré-fatura deve estar atualizada no Financeiro para poder desatualizá-la.", 1, 0 ) //"A Pré-fatura deve estar atualizada no Financeiro"
		Return
	EndIf

	If GWJ->GWJ_DTFIN <= SuperGetMv("MV_DTULFE",,"20000101") //!Empty(GWJ->GWJ_DTFIN) .And.
		Help( ,, 'Help',, "Data de transação deve ser posterior a data do último fechamento: " + DToC(SuperGetMv("MV_DTULFE",,"20000101")) + " (Parâmetro MV_DTULFE).", 1, 0 ) //"Data de transação deve ser posterior a data do último fechamento: " //" (Parâmetro MV_DTULFE)"
		Return
	EndIf

	If !MsgNoYes("Deseja desatualizar a Pré-fatura no Financeiro?", "Aviso")
		Return
	EndIf

	// Datasul
	If nERPInt = "1" 
		RecLock("GWJ", .F.)
		GWJ->GWJ_SITFIN := "5"
		GWJ->GWJ_MOTFIN := ""
		GWJ->( MsUnlock() )
		// Protheus ou Outros
	Else
		aRet := GFEA055In("5",,oModel55)
		If !(lIntGFE == .T. .And. cIntGFE2 $ "1S")
			If aRet[1]
				MsgInfo("Pré-fatura enviada para desatualização no Financeiro.")
			Else
				Alert("Pré-fatura não foi enviada para desatualização no Financeiro por causa do seguinte erro: " + aRet[2][6])
			EndIf
		EndIf
	EndIf

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA055In()
Função utilizada em Integração.
Generico

@sample
GFEA055In()

@author Felipe Mendes
@since 02/03/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEA055In(cSituacao, dData, oModel55)
	Local oModel
	Local aRet   := {.T., {}}
	Local aRetAux := {.T.,"",""}

	Default oModel55 := FWLoadModel("GFEA055")

	oModel := oModel55

	If cSituacao == "5"

		//Desatualização da Pré-Fatura no Protheus. Nova integração.
		//Uso do RecLock pelo confronto do retorno de erro do MsExecAuto com o model

		BeginTran()

		GFEA055IPG("5",, @aRetAux)

		If !Empty(aRetAux[2])

			If aRetAux[1]

				RecLock("GWJ", .F.)
				GWJ->GWJ_SITFIN := "1"
				GWJ->GWJ_MOTFIN := ""
				GWJ->( MsUnlock() )

				EndTran()

				Return {.T., {}}

			Else

				DisarmTransaction()

				RecLock("GWJ", .F.)
				GWJ->GWJ_SITFIN := "4"
				GWJ->GWJ_MOTFIN := aRetAux[3]
				GWJ->( MsUnlock() )

				Return {.F., {,,,,,aRetAux[3]}}

			EndIf

		Else      
			DisarmTransaction()   
		EndIf
	EndIf

	oModel:SetOperation( 4 )
	oModel:Activate()

	If cSituacao != "5"
		oModel:SetValue( 'GFEA055_GWJ', 'GWJ_DTFIN' , dData)
	EndIf
	oModel:SetValue( 'GFEA055_GWJ', 'GWJ_SITFIN', AllTrim(cSituacao))

	// Busca a conta de frete da filial
	If oModel:VldData()
		oModel:CommitData()
	Else
		aRet := {.F., oModel:GetErrorMessage()}
	EndIf

	oModel:Deactivate()

	Return aRet
	//---------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} GFEA055EP()
	Função para não permitir a exclusão de Pré-faturas que estejam com a situação Enviada, Confirmada ou Cancelada.
	Generico

	@sample
	GFEA055EP()

	@author Hercilio Henning Neto
	@since 18/10/2012
	@version 1.0
	/*///------------------------------------------------------------------------------------------------

Function GFEA055EP(oModel)

	Local nOpc := (oModel:GetOperation())

	If ( nOpc == MODEL_OPERATION_DELETE .And. Alltrim(GWJ->GWJ_SIT) $ "2;3;4")
		Help( ,, 'HELP',, "Pré-faturas que estejam com a situação Enviada, Confirmada ou Cancelada não podem ser excluídas.", 1, 0)
		Return .F.
	Endif

	Return .T.

	//---------------------------------------------------------------------------------------------------
	/*/{Protheus.doc} GFEA055POS()
	Generico

	@sample
	GFEA055POS()

	@author Lidiomar Fernando dos Santos Machado
	@since 23/01/2012
	@version 1.0
	/*///------------------------------------------------------------------------------------------------

Function GFEA055POS(oModel)
	Local nOpc := oModel:GetOperation()
	Local aPreFat := {}
	Local nI
	Local aRet := {.T.,"",""}

	If nOpc == MODEL_OPERATION_DELETE
	
		dbSelectArea("GWF")
		dbSetOrder(3)
		If dbSeek(GWJ->GWJ_FILIAL+GWJ->GWJ_NRPF)
			While !(GWF->(EOF())) .AND. GWF->GWF_FILPRE == GWJ->GWJ_FILIAL .AND. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
				AADD(aPreFat,GWF->(RecNo() ))
				GWF->(dbSkip())
			EndDo

			For nI := 1 To Len(aPreFat)
				GWF->(dbGoTo(aPreFat[nI]))
				RecLock("GWF",.F.)
				GWF->GWF_NRPREF := ""
				GWF->GWF_FILPRE := ""
				MsUnLock("GWF")
			Next nI

		EndIf
	EndIf

	//Integração GFE x Protheus
	If nOpc == MODEL_OPERATION_UPDATE

		GFEA055IPG(FWFldGet("GWJ_SITFIN"),oModel,@aRet)

		If !Empty(aRet[2])
			If !aRet[1] //Retorno Falso
				oModel:SetValue( 'GFEA055_GWJ', 'GWJ_SITFIN', "3") //Situação Rejeitado
				oModel:SetValue( 'GFEA055_GWJ', 'GWJ_MOTFIN', AllTrim(aRet[3]) )

			Else //Retorno Verdadeiro
				oModel:SetValue( 'GFEA055_GWJ', 'GWJ_SITFIN', "4") //Situação Atualizado
				oModel:SetValue( 'GFEA055_GWJ', 'GWJ_MOTFIN', " ")
			EndIf
		EndIf

	EndIf

Return .T.

//-----------------------------------------------------
/*/ Integra a pré-fatura no financeiro
@author Felipe Machado de Oliveira
@version P11
@since 28/05/2013
/*/
//------------------------------------------------------
Function GFEA055IPG(cSituacao,oModel,aRet)
	Local cMsg := ""
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE := SuperGetMV("MV_ERPGFE",,"2")

	Private _oGFEXFBFL := GFEXFBFLog():New()

	If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"

		_oGFEXFBFL:setSaveLog(__lLogIntP)
		_oGFEXFBFL:setAgrFrt(GWJ->GWJ_NRPF)

		Do Case

			Case cSituacao == "2"
			If !AtuPreFat(oModel,@cMsg) //Atualização da Pré-Fatura no Financeiro
				aRet := {.F.,"2",cMsg}
			Else
				aRet := {.T.,"2",""}
			EndIf

			Case cSituacao == "5"
			If !DesAtuPreFat(@cMsg) //Desatualização da Pré-Fatura no Financeiro
				aRet := {.F.,"5",cMsg}
			Else
				aRet := {.T.,"5",""}
			EndIf

			Otherwise

			Return

		EndCase

		_oGFEXFBFL:SaveLog()

	EndIf

Return
//-----------------------------------------------------
/*/	Atualização da pré-fatura no Protheus
@author Felipe Machado de Oliveira
@version P11
@since 28/05/2013
/*/
//------------------------------------------------------
Static Function AtuPreFat(oModel,cMsg)
	Local aPreFat 	:= {}
	Local aRatCont 	:= {}
	Local aRatAll 	:= {}
	Local oModelGWK := oModel:GetModel("GFEA055_GWK")
	Local nI 		:= 1
	Local aFornec 	:= GFEA055GFL(GWJ->GWJ_CDTRP)
	Local lErro 	:= .F.
	Local aErro 	:= {}
	Local nX 		:= 0
	Local oRetPE	// Retorno do ponto de entrada
	Local c_GFEI15  := SuperGetMV('MV_GFEI15',,'1')	
	Default cMsg 	:= ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto := .F.

	If Empty(aFornec[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	EndIf

	If !lErro
		//Dados da Pré-Fatura
		aPreFat := {	{"E2_PREFIXO" , "   "               , Nil },;
		{"E2_NUM"     , GWJ->GWJ_NRPF       , Nil },;
		{"E2_PARCELA" , "1"                  , Nil },;
		{"E2_TIPO"    , "PR"                 , Nil },;
		{"E2_NATUREZ" , SuperGetMv("MV_NTFGFE",,"") , Nil },;
		{"E2_EMISSAO" , GWJ->GWJ_DTIMPL    , Nil },;
		{"E2_VENCTO"  , GWJ->GWJ_DTVCTO    , Nil },;
		{"E2_VENCREA" , GWJ->GWJ_DTVCTO    , Nil },;
		{"E2_VALOR"   , GWJ_VLPF            , Nil },;
		{"E2_VLCRUZ"  , GWJ_VLPF            , Nil },;
		{"E2_FORNECE" , aFornec[1]          , Nil },;
		{"E2_LOJA"    , aFornec[2]          , Nil },;
		{"E2_ORIGEM"  , "TOTVSGFE"          , Nil } }

		For nI := 1 to oModelGWK:Length()

			If nI != 1
				oModelGWK:GoLine( nI )
			EndIf

			If Empty(FWFldGet("GWK_CTACTB"))
				Exit
			EndIf

			If nI == 1
				Aadd(aPreFat, {"E2_RATEIO", "S", Nil} )
			EndIf

			If FWFldGet("GWK_LANCTO") != "1"
				loop
			Endif

			//Dados dos Rateios
			aRatCont := { {"CTJ_DEBITO" , FWFldGet("GWK_CTACTB") , Nil },;
			{"CTJ_VALOR"  , FWFldGet("GWK_VLMOV")  , Nil },;
			{"CTJ_CCD"    , FWFldGet("GWK_CCUSTO") , Nil } }

			Aadd(aRatAll, aRatCont)

		Next
		// Ponto de entrada para customizar os dados de integração
		If ExistBlock("GFE055IN")
			oRetPE := ExecBlock("GFE055IN",.f.,.f.,{aPreFat, aRatAll})
			aPreFat := oRetPE[1]
			aRatAll := oRetPE[2]
		EndIf

		_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus

		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
		AddToLog('Atualização' + CRLF + CRLF)
		AddToLog('Pré-Fatura' + CRLF)

		For nX := 1 To Len(aPreFat)
			AddToLog(aPreFat[nx,1] + " - " + cValToChar(aPreFat[nx,2]) + CRLF)						
		Next nX

		If !Empty(aRatAll)

			AddToLog(CRLF + 'Dados dos Rateios' + CRLF)

			For nX := 1 To Len(aRatAll[1])
				AddToLog(aRatAll[1,nX,1] + " - " + cValToChar(aRatAll[1,nX,2]) + CRLF)
			next nX
		EndIf

		//Execução da operação de inclusão no FINA050
		MsExecAuto({ |a,b,c| FINA050(a,,b,,,,,c)}, aPreFat,3,aRatAll )

		If lMsErroAuto
			aErro := GetAutoGrLog()
			cMsg := ""

			For nX := 1 To Len(aErro)
				cMsg += aErro[nX] + CRLF
			Next nX

			lErro := .T.

			AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
			AddToLog(cMsg + CRLF)
		Else
			AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
		EndIf

		AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "
	EndIf

	If lErro
		If !IsInCallStack("GFEA099") .and. c_GFEI15 != '2'
			MsgInfo("Pré-fatura não enviada para atualização. Verificar motivo no campo 'Mot Rejeição'.")
		EndIf
	Else
		If !IsInCallStack("GFEA099")  .and. c_GFEI15 != '2'
			MsgInfo("Pré-fatura atualizada no Financeiro.")
		EndIf
	EndIf

Return !lErro

//-----------------------------------------------------
/*/	Desatualização da pré-fatura no Protheus
@author Felipe Machado de Oliveira
@version P11
@since 28/05/2013
/*/
//------------------------------------------------------
Static Function DesAtuPreFat(cMsg)
	Local aPreFat := {}
	Local aFornec := GFEA055GFL(GWJ->GWJ_CDTRP)
	Local lErro := .F.
	Local aErro := {}
	Local nX := 0
	Local aRatAll 	:= {}
	Local oRetPE // Retorno do ponto de entrada

	Default cMsg := ""

	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

	//Dados da Pré-Fatura
	aPreFat := {	{"E2_PREFIXO" , Space( TamSX3("E2_PREFIXO")[1])                                                                , Nil },;
	{"E2_NUM"     , AllTrim(GWJ->GWJ_NRPF) + Space( (TamSX3("E2_NUM")[1])-(Len( AllTrim(GWJ->GWJ_NRPF) )) ) , Nil },;
	{"E2_PARCELA" , AllTrim("1")+Space( (TamSX3("E2_PARCELA")[1])-(Len( AllTrim("1") )) )                     , Nil },;
	{"E2_TIPO"    , AllTrim("PR")+Space( (TamSX3("E2_TIPO")[1])-(Len( AllTrim("PR") )) )                      , Nil },;
	{"E2_FORNECE" , aFornec[1]                                                                                        , Nil },;
	{"E2_LOJA"    , aFornec[2]                                                                                        , Nil } }

	// Ponto de entrada para customizar os dados de integração
	If ExistBlock("GFE055IN")
		oRetPE := ExecBlock("GFE055IN",.f.,.f.,{aPreFat, aRatAll})
		aPreFat := oRetPE[1]
		aRatAll := oRetPE[2]
	EndIf

	_oGFEXFBFL:NovoLogInP("FINA050") //Log de integração com ERP Protheus

	AddToLog("LOG DE INTEGRAÇÃO FINA050 - Iniciado em " + DTOC(DATE()) + " às " + TIME() + CRLF + CRLF) //"LOG DE INTEGRAÇÃO FINA050 - Iniciado em "###", as "
	AddToLog('Desatualização' + CRLF + CRLF)
	AddToLog('Pré-Fatura' + CRLF)

	For nX := 1 To Len(aPreFat)
		AddToLog(aPreFat[nx,1] + " - " + cValToChar(aPreFat[nx,2]) + CRLF)						
	Next nX

	//Execução da operação de exclusão no FINA050
	MsExecAuto({ |a,b| FINA050(a,,b)}, aPreFat,5 )

	If lMsErroAuto
		aErro := GetAutoGrLog()
		cMsg := ""

		For nX := 1 To Len(aErro)
			cMsg += aErro[nX] + CRLF
		Next nX

		lErro := .T.

		AddToLog(CRLF + "Integração não realizada." + CRLF + CRLF)
		AddToLog(cMsg + CRLF)
	Else
		AddToLog(CRLF + "Integração realizada com sucesso!" + CRLF)
	EndIf

	AddToLog("LOG DE INTEGRAÇÃO FINA050 - Finalizado em " + DTOC(DATE()) + " às " + TIME()) //"LOG DE INTEGRAÇÃO FINA050 - Finalizado em "###", as "

	If lErro
		If !IsInCallStack("GFEA099")
			MsgInfo("Pré-fatura não enviada para desatualização. Verificar motivo no campo 'Mot Rejeição'.")
		EndIf
	Else
		If !IsInCallStack("GFEA099")
			MsgInfo("Pré-fatura desatualizada no Financeiro.")
		EndIf
	EndIf

Return !lErro
//-----------------------------------------------------
/*/Retorna o código e a Loja correspondente ao fornecedor do ERP
@author Felipe Machado de Oliveira
@version P11
@since 30/05/2013
*/
//-----------------------------------------------------
Function GFEA055GFL(cFornecedor)
	Local cCod     := ""
	Local cLoja    := ""
	Local nTamCod  := TamSX3("A2_COD" )[1]
	Local nTamLoja := TamSx3("A2_LOJA")[1]
	Local cTipoFor := Posicione("GU3", 1, xFilial("GU3") + cFornecedor, "GU3_NATUR")
	Local lNumProp := SuperGetMv("MV_EMITMP",.F.,"1") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"

	If lNumProp
		dbSelectArea("GU3")
		GU3->( dbSetOrder(1) )
		GU3->( dbSeek( xFilial("GU3")+cFornecedor ) )
		If !GU3->( EOF() ) .And. GU3->GU3_FILIAL == xFilial("GU3");
		.And. GU3->GU3_CDEMIT == cFornecedor

			cCod := GU3->GU3_CDERP
			cLoja := GU3->GU3_CDCERP
			
		EndIf
	EndIf


	If Empty(cCod)
		If cTipoFor == "X"
			cCod  := SubStr( cFornecedor, 1, Len(AllTrim(cFornecedor)) - nTamLoja )
			cLoja := SubStr( cFornecedor, Len(AllTrim(cFornecedor)) - nTamLoja, nTamLoja )
		Else	
			dbSelectArea("GU3")
			GU3->( dbSetOrder(1) )
			GU3->( dbSeek( xFilial("GU3")+cFornecedor ) )
			If !GU3->( EOF() ) .And. GU3->GU3_FILIAL == xFilial("GU3");
			.And. GU3->GU3_CDEMIT == cFornecedor


				dbSelectArea("SA2")
				SA2->(DbSetOrder(3)) // Filial + cgc
				SA2->(dbSeek(xFilial("SA2") + GU3->GU3_IDFED))
				while !SA2->(Eof()) .and. xFilial("SA2") + AllTrim(GU3->GU3_IDFED) == SA2->A2_FILIAL + SA2->A2_CGC
					if SA2->A2_MSBLQL <> '1'
						cCOD := SA2->A2_COD
						cLoja := SA2->A2_LOJA		
						Exit 	
					EndIf
					SA2->(DbSkip())
				EndDo	

				If Empty(cCOD) .And. Empty(cLoja)
					dbSelectArea("SA1")
					SA1->(DbSetOrder(3)) // Filial + cgc
					SA1->(dbSeek(xFilial("SA1") + GU3->GU3_IDFED))
					while !SA1->(Eof()) .and. xFilial("SA1") + AllTrim(GU3->GU3_IDFED) == SA1->A1_FILIAL + SA1->A1_CGC
						if SA1->A1_MSBLQL <> '1'
							cCOD := SA1->A1_COD
							cLoja := SA1->A1_LOJA
							Exit				
						EndIf
						SA1->(DbSkip())
					EndDo
				EndIf
			EndIf	

			If Empty(cCOD) .And. Empty(cLoja)
				cAlias := GetNextAlias()
				cQuery := " SELECT SA2.A2_COD, SA2.A2_LOJA FROM "+RetSQLName("SA2")+" SA2 "
				cQuery += " WHERE "
				cQuery += " 	SA2.A2_CGC = '"+cFornecedor+"'       AND "
				cQuery += " 	SA2.A2_MSBLQL  <> '1'	AND "
				cQuery += "	SA2.D_E_L_E_T_ = ' '"	
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

				cCOD := (cAlias)->A2_COD
				cLoja := (cAlias)->A2_LOJA
				(cAlias)->(dbCloseArea())

				If Empty(cCOD) .And. Empty(cLoja)
					cAlias := GetNextAlias()
					cQuery := " SELECT SA1.A1_COD, SA1.A1_LOJA FROM "+RetSQLName("SA1")+" SA1 "
					cQuery += " WHERE "
					cQuery += " 	SA1.A1_CGC = '"+cFornecedor+"'       AND "
					cQuery += " 	SA1.A1_MSBLQL  <> '1'	AND "
					cQuery += "	SA1.D_E_L_E_T_ = ' '"	
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

					cCOD := (cAlias)->A1_COD
					cLoja := (cAlias)->A1_LOJA
					(cAlias)->(dbCloseArea())
				EndIf

			EndIf
		EndIf	

		cCod  := PadR(cCod , nTamCod )
		cLoja := PadR(cLoja, nTamLoja)
	EndIf

Return ({cCod, cLoja})

//-----------------------------------------------------
/*/Retorna o código e a Loja correspondente ao fornecedor do ERP
@author Pedro E.
@version P12
@since 19/02/2018
*/
//-----------------------------------------------------
Function GFEA055DEV(cFornecedor,cCliente)
	Local cCod     := ""
	Local cLoja    := ""
	Local nTamCod  := TamSX3("A2_COD" )[1]
	Local nTamLoja := TamSx3("A2_LOJA")[1]
	Local cTipoFor := Posicione("GU3", 1, xFilial("GU3") + cFornecedor, "GU3_NATUR")
	Local lNumProp := SuperGetMv("MV_EMITMP",.F.,"1") == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
	Local aCliSF1	 := {}

	If lNumProp
		dbSelectArea("GU3")
		GU3->( dbSetOrder(1) )
		GU3->( dbSeek( xFilial("GU3")+cFornecedor ) )
		If !GU3->( EOF() ) .And. GU3->GU3_FILIAL == xFilial("GU3");
		.And. GU3->GU3_CDEMIT == cFornecedor

			cCod  := PadR(GU3->GU3_CDERP, nTamCod )     
			cLoja := PadR(GU3->GU3_CDCERP, nTamLoja)	
			Aadd(aCliSF1,{GU3->GU3_CDERP,GU3->GU3_CDCERP})
			
		EndIf
	EndIf
	// Tratamento por CNPJ
	// Grava no array todos os fornecedores e todos os clientes que tenham o mesmo CGC
	If Empty(cCod)
		If cTipoFor == "X"
			cCod  := SubStr( cFornecedor, 1, nTamCod )
			cLoja := SubStr( cFornecedor, (nTamCod + 1), nTamLoja )
			Aadd(aCliSF1,{cCod,cLoja})
		Else	
			GU3->( dbSetOrder(1) )
			GU3->( dbSeek( xFilial("GU3")+cFornecedor ) )
			If !GU3->( EOF() ) .And. GU3->GU3_FILIAL == xFilial("GU3");
			.And. GU3->GU3_CDEMIT == cFornecedor
				If cCliente <> "C"
					SA2->(DbSetOrder(3)) // Filial + cgc
					SA2->(dbSeek(xFilial("SA2") + GU3->GU3_IDFED))
					While !SA2->( Eof()) .And. Alltrim(SA2->A2_CGC) == Alltrim(GU3->GU3_IDFED)/**INATIVO OU BRANCO/ */
						If SA2->A2_MSBLQL  <> '1'
							cCOD  := PadR(SA2->A2_COD, nTamCod )   
							cLoja := PadR(SA2->A2_LOJA, nTamLoja)
							EXIT 	
						ELSE			
							cCOD  := PadR(SA2->A2_COD, nTamCod )   
							cLoja := PadR(SA2->A2_LOJA, nTamLoja)
						EndIf				
						SA2->(dbSkip())				
					EndDo
					Aadd(aCliSF1,{cCod,cLoja})	
				EndIf	

				SA1->(DbSetOrder(3)) // Filial + cgc
				SA1->(dbSeek(xFilial("SA1") + GU3->GU3_IDFED))
				While !SA1->( Eof()) .And. Alltrim(SA1->A1_CGC) == Alltrim(GU3->GU3_IDFED)
					If SA1->A1_MSBLQL  <> '1'
						cCOD  := PadR(SA1->A1_COD, nTamCod )  
						cLoja := PadR(SA1->A1_LOJA, nTamLoja)	
						EXIT
					ELSE
						cCOD  := PadR(SA1->A1_COD, nTamCod )  
						cLoja := PadR(SA1->A1_LOJA, nTamLoja)	
					EndIf
					SA1->(dbSkip())				
				EndDo		
				Aadd(aCliSF1,{cCod,cLoja})								      
			EndIf
		EndIf
	EndIf
Return (aCliSF1)

/*/{Protheus.doc} AddToLog
Registra o texto de log recebido na variável de log
Caso a variável exceda o limite estabelecido, o conteúdo é gravado em arquivo
@author silvana.torres
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTexto, characters, descricao
@param nPosicao, numeric, descricao
@param lTime, logical, descricao
@type function
/*/
Static Function AddToLog(cTexto, nPosicao, lTime)
	Default lTime	:= .T.
	Default nPosicao := _LOG_END

	If !__lLogIntP
		Return
	EndIf

	_oGFEXFBFL:setPosicao(nPosicao)
	_oGFEXFBFL:setTime(lTime)
	_oGFEXFBFL:setSaveLog(__lLogIntP)
	_oGFEXFBFL:setTexto(cTexto)
Return NIL

Class GFEA55EVT FROM FWModelEvent
	Method New()
	Method After()
End Class

Method New() Class GFEA55EVT
	
Return Nil

Method After(oModel) Class GFEA55EVT
	Local nOpc       := oModel:GetOperation()
	Local oModelGWF  := Nil
	Local nCont      := 1
	Local cNrCalc    := ""
	Local cFilGWF    := ""
	Local lLogPreFat := (Type("LogPreFat") == "O")

	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		oModelGWF := oModel:GetModel():GetModel("GFEA055_GWF")

		If !IsInCallStack("GFEA055IN") .And. lLogPreFat
			LogPreFat:Add("- Vinculando cálculos na pré-fatura:", 1)
		EndIf

		For nCont := 1 To oModelGWF:Length()
			oModelGWF:GoLine(nCont)

			cFilGWF := xFilial("GWF")
			cNrCalc := oModelGWF:GetValue("GWF_NRCALC")

			GWF->(dbSetOrder(01))
			If GWF->(dbSeek(cFilGWF + cNrCalc))
				If !IsInCallStack("GFEA055IN") .And. lLogPreFat
					LogPreFat:Add("> Filial: " + cFilGWF + ", Cálculo: '" + cNrCalc + "'", 2)
				EndIf

				RecLock("GWF",.F.)
					GWF->GWF_NRPREF := oModelGWF:GetValue("GWF_NRPREF")
					GWF->GWF_FILPRE := oModelGWF:GetValue("GWF_FILPRE")
				MsUnLock("GWF")
			EndIf
		Next nCont
	EndIf

Return .T.
