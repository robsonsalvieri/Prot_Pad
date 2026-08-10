#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
 
/*/ GFEC054
@author siegklenes.beulke
@since 12/12/2013   
@version 1.0	  	

@description
Monitor de Integração SIGATMS X SIGAGFE
/*/
Function GFEC054()
	Local aCoors := FWGetDialogSize(oMainWnd)
	Private oFWLayer, oPanelUp, oPanelDown
	Private oBrowseGWE, oBrowseGWU, oRelation
	Private oDlg
	Private aFieldsGWE, aFieldsGWU
	Private cAliasGWE, cAliasGWU
	Private aGWE_STATUS := {"1=Não está apto à integração","2=Apto à integração","3=Integrado"}
	Private nDocTrp := 0
	Private lCpoChvExt := FieldPos("GWD_CHVEXT")

	Pergunte("GFEC054",.T.)

	Define MsDialog oDlg Title 'Monitor de Integração SIGAGFE x SIGATMS' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .T.)

	oFWLayer:AddLine('UP',40,.F.)
	oFWLayer:AddLine('DOWN',60,.F.)
	oFWLayer:AddCollumn('ALL',100,.T.,'UP')
	oFWLayer:AddCollumn('ALL',100,.T.,'DOWN')

	oPanelUp   := oFWLayer:GetColPanel('ALL','UP')
	oPanelDown := oFWLayer:GetColPanel('ALL','DOWN')

	oDlg:Activate(,,,.T.,,,{||RptStatus({||Iniciar()}, "Carregando", "Aguarde, carregando dados...")})

	GFEDelTab(cAliasGWE)
	GFEDelTab(cAliasGWU)

Return Nil

Static Function Iniciar()
	Local aIndGWE, aIndGWU

	SetRegua(5)

	aFieldsGWE := { ;
		{"Status"				,"GWE_STATUS" 	,	"C", 1 ,0,,1,2,.F.},;
		{"Filial"				,"GWE_FILIAL"	,	"C", FWSizeFilial() ,0,,1,2,.F.},;
		{"Fil Doc Transp"		,"GWE_FILDT"	,	"C", FWSizeFilial() ,0,,1,2,.T.},;
		{"No.Doc Transp"		,"GWE_NRDT"		,	"C", TamSx3("GWE_NRDT")[1] ,0,,1,6,.T.},;
		{"Série Doc Transp"		,"GWE_SERDT"	,	"C", TamSx3("GWE_SERDT")[1] ,0,,1,3,.T.},;
		{"Data Emissão"			,"DT6_DATEMI"	,	"D", TamSx3("DT6_DATEMI")[1] ,0,,1,4,.T.},;
		{"Prazo de Entrega"		,"DT6_PRZENT"	,	"D", TamSx3("DT6_PRZENT")[1] ,0,,1,4,.T.},;
		{"Remetente"			,"DT6_CLIREM"	,	"C", TamSx3("DT6_CLIREM")[1] ,0,,1,3,.T.},;
		{"Loja Remetente"		,"DT6_LOJREM"	,	"C", TamSx3("DT6_LOJREM")[1] ,0,,1,3,.T.},;
		{"Nome Remetente"		,"DT6_NOMREM"	,	"C", TamSx3("DT6_NOMREM")[1],0,,1,10,.T.},;
		{"Destinatário"			,"DT6_CLIDES"	,	"C", TamSx3("DT6_CLIDES")[1] ,0,,1,3,.T.},;
		{"Loja Dest"			,"DT6_LOJDES"	,	"C", TamSx3("DT6_LOJDES")[1] ,0,,1,3,.T.},;
		{"Nome Dest"			,"DT6_NOMDES"	,	"C", TamSx3("DT6_NOMDES")[1],0,,1,10,.T.},;
		{"Qtde Doc. Carga"		,"QTD_DOC" 		,	"N", 3,0,,1,2,.T.},;
		{"Qtde Doc. com Ocor."	,"QTD_OCO" 		,	"N", 3,0,,1,2,.T.},;
		{"Vol.Orig"				,"DT6_VOLORI"	,	"N", TamSx3("DT6_VOLORI")[1] ,0,,1,2,.T.},;
		{"Qtde. Volume"			,"DT6_QTDVOL"	,	"N", TamSx3("DT6_QTDVOL")[1] ,0,,1,2,.T.},;
		{"Peso Real"			,"DT6_PESO"		,	"N", TamSx3("DT6_PESO")[1],TamSx3("DT6_PESO")[2],PESQPICT("DT6","DT6_PESO"),2,6,.T.};
		}
	aIndGWE := {"GWE_FILDT+GWE_NRDT+GWE_SERDT"}
	cAliasGWE := CriaTab(aFieldsGWE, aIndGWE)

	IncRegua()

	aFieldsGWU := { ;
		{"Sit Aprovação"		,"GWD_SIT"		,	"C", 01,0,,,,.F.},;
		{"Sit Integração"		,"GWD_SITTMS"	,	"C", 01,0,,,,.F.},;
		{"Mot Rejeição"			,"GWD_MOTTMS"	,	"M", 10,0,,,,.F.},;
		{"Sit Tem Ocor."		,"TEMOCO"		,	"C", 01,0,,,,.F.},;
		{"Filial"				,"GWU_FILIAL"	,	"C", FWSizeFilial(),0,,,,.F.},;
		{"Filial Docto Transp"	,"GWU_FILDT"	,	"C", FWSizeFilial(),0,,,,.F.},;
		{"No.Docto Transp"		,"GWU_NRDT"		,	"C", TamSx3("GWE_NRDT")[1] ,0,,,,.F.},;
		{"Série Docto Transp"	,"GWU_SERDT"	,	"C", TamSx3("GWE_SERDT")[1] ,0,,,,.F.},;
		{"Série Docto "			,"GWU_SERDC"	,	"C", TamSx3("GWE_SERDC")[1],0,"!!!",1,3,.T.},;
		{"Nr.Doc.Carga"				,"GWU_NRDC"		,	"C", 16,0,/*cpicture*/,1,8,.T.},;
		{"Tipo Docto Carga"			,"GWU_CDTPDC"	,	"C", 05,0,/*cpicture*/,1,3,.T.},;
		{"Transportador"			,"GWU_CDTRP"	,	"C", 14,0,/*cpicture*/,1,7,.T.},;
		{"Transp Ocor"			,"GWD_CDTRP"	,	"C", 14,0,/*cpicture*/,1,7,.F.},;
		{"Trecho"					,"GWU_SEQ"		,	"C", TamSx3("GWU_SEQ")[1],0,/*cpicture*/,1,2,.T.},;
		{"Nome Transp"				,"GWU_NMTRP"	,	"C", 80,0,/*cpicture*/,1,20,.T.},;
		{"Emissor Docto"			,"GWU_EMISDC"	,	"C", 14,0,/*cpicture*/,1,7,.T.},;
		{"Fiial Ocorrência"			,"GWD_FILIAL"	,	"C", FWSizeFilial(),0,,,,.T.},;
		{"Nr. Ocorrência"			,"GWD_NROCO"	,	"C", 8,0,/*cpicture*/,1,8,.T.},;
		{"Integra SIGATMS"			,"GU5_INTTMS"	,	"C", 03,0,/*cpicture*/,1,7,.T.},;
		{"Qtde. Volumes"			,"GW1_QTVOL"	,	"N", 5 ,0,/*cpicture*/,1,2,.T.},;
		{"Peso Real"				,"GW8_PESOR"	,	"N", 13,5,PESQPICT("GW8","GW8_PESOR"),2,6,.T.},;
		{"Chave Externa"			,"GWD_CHVEXT"	,	"C", 200,0,,,,.T.};
		}

	aIndGWU := {"GWU_FILDT+GWU_NRDT+GWU_SERDT+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ+GWD_FILIAL+GWD_NROCO"}
	cAliasGWU := CriaTab(aFieldsGWU, aIndGWU)

	IncRegua()
	CarregarDados()
	dbSelectArea(cAliasGWE)
	(cAliasGWE)->(dbSetOrder(1))

	dbSelectArea(cAliasGWU)
	(cAliasGWU)->(dbSetOrder(1))

	IncRegua()
	oPanelDown:SetUpdatesEnabled(.F.)
	//
	// Trechos Documentos de Carga x Ocorrências'
	//
	oBrowseGWU:= FWMBrowse():New()
	oBrowseGWU:SetOwner(oPanelDown)
	oBrowseGWU:SetDescription('Trechos Documentos de Carga x Ocorrências')
	oBrowseGWU:DisableDetails()
	oBrowseGWU:SetAlias(cAliasGWU)
	oBrowseGWU:SetMenuDef('GFEC054A')
	oBrowseGWU:SetAmbiente(.F.)
	oBrowseGWU:SetFixedBrowse(.T.)
	oBrowseGWU:SetWalkthru(.F.)
	oBrowseGWU:SetProfileID('2')
	oBrowseGWU:SetFields(GetFields(aFieldsGWU, "cAliasGWU"))
	oBrowseGWU:AddLegend("GWD_SIT == '1'","BLUE", "Pendente","1")
	oBrowseGWU:AddLegend("GWD_SIT == '2'","GREEN", "Aprovada","1")
	oBrowseGWU:AddLegend("GWD_SIT == '3'","RED", "Reprovada","1")

	oBrowseGWU:AddLegend("GWD_SITTMS == '0'","BLACK", "Não se aplica","2")
	oBrowseGWU:AddLegend("GWD_SITTMS == '1'","WHITE", "Situação pendente","2")
	oBrowseGWU:AddLegend("GWD_SITTMS == '2'","GREEN", "Envio pendente","2")
	oBrowseGWU:AddLegend("GWD_SITTMS == '3'","YELLOW", "Rejeitado SIGATMS","2")
	oBrowseGWU:AddLegend("GWD_SITTMS == '4'","BLUE", "Integrado","2")

	oBrowseGWU:Activate()

	IncRegua()

	//
	// Documentos de Transporte
	//
	oBrowseGWE:= FWMBrowse():New()
	oBrowseGWE:SetOwner(oPanelUp)
	oBrowseGWE:SetDescription('Documentos de Transporte')
	oBrowseGWE:DisableDetails()
	oBrowseGWE:SetAlias(cAliasGWE)
	oBrowseGWE:SetMenuDef('GFEC054')
	oBrowseGWE:SetProfileID('1')
	oBrowseGWE:ForceQuitButton()
	oBrowseGWE:SetAmbiente(.F.)
	oBrowseGWE:SetWalkthru(.F.)
	oBrowseGWE:SetFixedBrowse(.T.)

	oBrowseGWE:SetFields(GetFields(aFieldsGWE, "cAliasGWE"))

	oBrowseGWE:AddLegend("GWE_STATUS == '1'","WHITE", "Não está apto à integração")
	oBrowseGWE:AddLegend("GWE_STATUS == '2'","GREEN", "Apto à integração")
	oBrowseGWE:AddLegend("GWE_STATUS == '3'","BLUE", "Integrado")
	oBrowseGWE:Activate()

	IncRegua()

	oRelation := FWBrwRelation():New()
	oRelation:AddRelation(oBrowseGWE, oBrowseGWU, {{"GWU_FILDT",'GWE_FILDT'},{"GWU_NRDT",'GWE_NRDT'},{"GWU_SERDT",'GWE_SERDT'}})
	oRelation:Activate()
	oPanelDown:SetUpdatesEnabled(.T.)
	IncRegua()
Return Nil

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Incluir Ocorrência" 		ACTION "GFEC054OCO()" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Pendências" 	ACTION "GFEC054PEN()" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Integrar Documento" 		ACTION "GFEC054INT()" OPERATION 13 ACCESS 0
	ADD OPTION aRotina TITLE "Integrar Todos" 			ACTION "GFEC054TOD()" OPERATION 13 ACCESS 0
	ADD OPTION aRotina TITLE "Desatualizar Documento" 	ACTION "GFEC054DES()" OPERATION 14 ACCESS 0
	ADD OPTION aRotina TITLE "Desatualizar Todos" 		ACTION "GFEC054DTO()" OPERATION 14 ACCESS 0
	ADD OPTION aRotina TITLE "Parâmetros" 				ACTION "GFEC054PAR()" OPERATION 3 ACCESS 0
Return aRotina

//
// Retorna estrutura de campos/colunas para browse com tabela temporária
//
Static Function GetFields(aStruct, cAlias)
	Local aFields := {}
	Local nCount

	For nCount := 1 To Len(aStruct)
		If aStruct[nCount, 9]
			aAdd(aFields, {aStruct[nCount,1],;
				&("{|| ("+cAlias+")->" + aStruct[nCount,2] + "}"),;
				aStruct[nCount,3],;
				aStruct[nCount,6],;
				aStruct[nCount,7],;
				aStruct[nCount,8],;
				aStruct[nCount,5],;
				.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})
		EndIf
	Next nCount
Return aFields

Static Function GetStruct(aFields)
	Local nCont
	Local aStruct := {}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
		aFields[nCont][3],;  //Tipo
		aFields[nCont][4],;  //Tamanho
		aFields[nCont][5]}) //Decimal
	Next nCont

Return aStruct

// Cria tabela temporária
Static Function CriaTab(aFields, aIndices)
	Local cAlias
	Local nCont
	Local aStruct := {}

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
		aFields[nCont][3],;  //Tipo
		aFields[nCont][4],;  //Tamanho
		aFields[nCont][5]}) //Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})
Return cAlias

Static Function CarregarDados()

	Local cQuery := ''
	Local nI := 0
	Local lOpenEdge := .F.
	Local aAreaGWU, aAreaGWU2
	Local cChaveGWU, cChaveGWD := ''
	
	If TCGETDB() = 'OPENEDGE'
		lOpenEdge := .T.
	EndIf

	IncRegua()

	dbSelectArea(cAliasGWE)
	ZAP

	dbSelectArea(cAliasGWU)
	ZAP

	cQuery += "SELECT GWE.GWE_FILIAL as GWE_FILIAL, DT6.DT6_FILDOC as GWE_FILDT, DT6.DT6_DOC as GWE_NRDT, DT6.DT6_SERIE as GWE_SERDT, DT6.DT6_DATEMI, DT6.DT6_PRZENT, DT6.DT6_CLIREM, DT6.DT6_LOJREM, "
	cQuery += "SA1.A1_NOME as DT6_NOMREM, DT6.DT6_CLIDES, DT6.DT6_LOJDES, SA12.A1_NOME as DT6_NOMDES, DT6.DT6_VOLORI, DT6.DT6_QTDVOL, DT6.DT6_PESO, "
	cQuery += "'' as GWE_STATUS
	If !lOpenEdge
		cQuery += ", (SELECT DISTINCT COUNT(*) FROM " + RetSQLName("GW1") + " GW1 "
		cQuery += "INNER JOIN " + RetSQLName("GWE") + " GWE "
		cQuery += "ON  GWE.GWE_FILDT = 'DT6.DT6_FILDOC' "
		cQuery += "AND GWE.GWE_NRDT  = 'DT6.DT6_DOC' "
		cQuery += "AND GWE.GWE_SERDT = 'DT6.DT6_SERIE' "
		cQuery += "AND GWE.D_E_L_E_T_ = '' "
		cQuery += "AND GW1.GW1_FILIAL = GWE.GWE_FILIAL "
		cQuery += "AND GW1.GW1_CDTPDC = GWE.GWE_CDTPDC "
		cQuery += "AND GW1.GW1_EMISDC = GWE.GWE_EMISDC "
		cQuery += "AND GW1.GW1_SERDC = GWE.GWE_SERDC "
		cQuery += "AND GW1.GW1_NRDC = GWE.GWE_NRDC "
		cQuery += "AND GW1.D_E_L_E_T_ = ''
		cQuery += "AND EXISTS (SELECT GWL_FILIAL FROM " + RetSQLName("GWL") + " GWL "
		cQuery += "WHERE GWL.GWL_FILDC = GW1.GW1_FILIAL "
		cQuery += "AND GWL.GWL_TPDC = GW1.GW1_CDTPDC "
		cQuery += "AND GWL.GWL_EMITDC = GW1.GW1_EMISDC "
		cQuery += "AND GWL.GWL_SERDC = GW1.GW1_SERDC "
		cQuery += "AND GWL.GWL_NRDC = GW1.GW1_NRDC "
		cQuery += "AND GWL.D_E_L_E_T_ = '') ) QTD_OCO "
		cQuery += ", (SELECT DISTINCT COUNT(*) FROM " + RetSQLName("GW1") + " GW1 "
		cQuery += "INNER JOIN " + RetSQLName("GWE") + " GWE "
		cQuery += "ON  GWE.GWE_FILDT = 'DT6.DT6_FILDOC' "
		cQuery += "AND GWE.GWE_NRDT  = 'DT6.DT6_DOC' "
		cQuery += "AND GWE.GWE_SERDT = 'DT6.DT6_SERIE' "
		cQuery += "AND GWE.D_E_L_E_T_ = '' "
		cQuery += "WHERE GW1.GW1_FILIAL = GWE.GWE_FILIAL "
		cQuery += "AND GW1.GW1_CDTPDC = GWE.GWE_CDTPDC "
		cQuery += "AND GW1.GW1_EMISDC = GWE.GWE_EMISDC "
		cQuery += "AND GW1.GW1_SERDC = GWE.GWE_SERDC "
		cQuery += "AND GW1.GW1_NRDC = GWE.GWE_NRDC "
		cQuery += "AND GW1.D_E_L_E_T_ = '') QTD_DOC "
	Else
		cQuery += ", 0 AS QTD_DOC, 0 AS QTD_OCO"
	EndIf
	cQuery += "FROM " + RetSQLName("DT6") + " DT6 "
	cQuery += "LEFT JOIN " + RetSQLName("GWE") + " GWE "
	cQuery += "ON  GWE.GWE_FILDT = 'DT6.DT6_FILDOC' "
	cQuery += "AND GWE.GWE_NRDT  = 'DT6.DT6_DOC' "
	cQuery += "AND GWE.GWE_SERDT = 'DT6.DT6_SERIE' "
	cQuery += "AND GWE.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN " + RetSQLName("SA1") + " SA1 "
	cQuery += "ON  SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "AND SA1.A1_COD    = 'DT6.DT6_CLIREM' "
	cQuery += "AND SA1.A1_LOJA   = 'DT6.DT6_LOJREM' "
	cQuery += "AND SA1.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN " + RetSQLName("SA1") + " SA12 "
	cQuery += "ON  SA12.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += "AND SA12.A1_COD    = 'DT6.DT6_CLIDES' "
	cQuery += "AND SA12.A1_LOJA   = 'DT6.DT6_LOJDES' "
	cQuery += "AND SA12.D_E_L_E_T_ = '' "
	cQuery += "WHERE DT6.D_E_L_E_T_ = '' "
	//Retorna o filtro do SQL
	cQuery += C054FILSQL()
	
	cQuery += "ORDER BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE "
	//cQuery += "ORDER BY DT6.DT6_FILIAL, DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE "

	cQuery := ChangeQuery(cQuery)
	SqlToTrb(cQuery, GetStruct(aFieldsGWE), cAliasGWE)

	cQuery := ""

	cQuery += "SELECT GWU_FILIAL, GWE.GWE_FILDT AS GWU_FILDT, GWE.GWE_NRDT AS GWU_NRDT, GWE.GWE_SERDT AS GWU_SERDT, GWU_CDTPDC, "
	cQuery += "GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_CDTRP, GWU_SEQ, GU3.GU3_NMEMIT AS GWU_NMTRP, GW1.GW1_QTVOL as GW1_QTVOL, "
	cQuery += "GWD.GWD_FILIAL as GWD_FILIAL, GWD.GWD_NROCO as GWD_NROCO, GWD.GWD_SIT as GWD_SIT, "
	cQuery += "GWD.GWD_SITTMS as GWD_SITTMS, GWD.GWD_CDTRP, " + If(lCpoChvExt > 0, "GWD.GWD_CHVEXT,","")
	cQuery += "CASE GU5.GU5_INTTMS WHEN '1' THEN 'Não' "
	cQuery += "WHEN '2' THEN 'Sim' END as GU5_INTTMS, "
	cQuery += "GWD.GWD_MOTTMS as GWD_MOTTMS "
	/*If !lOpenEdge
		cQuery += ",(SELECT SUM(GW8.GW8_PESOR) FROM " + RetSqlName("GW8") + " GW8 " 
		cQuery += "WHERE GW8.GW8_FILIAL = GWU.GWU_FILIAL "
		cQuery += "AND GW8.GW8_CDTPDC = GWU.GWU_CDTPDC "
		cQuery += "AND GW8.GW8_EMISDC = GWU.GWU_EMISDC "
		cQuery += "AND GW8.GW8_SERDC  = GWU.GWU_SERDC "
		cQuery += "AND GW8.GW8_NRDC   = GWU.GWU_NRDC "
		cQuery += "AND GW8.D_E_L_E_T_ = '') GW8_PESOR "
	Else 
		cQuery += ", 0 AS GW8_PESOR"
	EndIf*/
	cQuery += "FROM " + RetSQLName("GWU") + " GWU "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3 "
	cQuery += "ON  GU3.GU3_FILIAL = '" + xFilial("GU3") + "' "
	cQuery += "AND GU3.GU3_CDEMIT = GWU.GWU_CDTRP "
	cQuery += "AND GU3.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN " + RetSQLName("GW1") + " GW1 "
	cQuery += "ON  GW1.GW1_FILIAL = GWU.GWU_FILIAL "
	cQuery += "AND GW1.GW1_CDTPDC = GWU.GWU_CDTPDC "
	cQuery += "AND GW1.GW1_EMISDC = GWU.GWU_EMISDC "
	cQuery += "AND GW1.GW1_SERDC  = GWU.GWU_SERDC "
	cQuery += "AND GW1.GW1_NRDC   = GWU.GWU_NRDC "
	cQuery += "AND GW1.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN " + RetSQLName("GWE") + " GWE "
	cQuery += "ON  GWE.GWE_FILIAL = GWU.GWU_FILIAL "
	cQuery += "AND GWE.GWE_EMISDC = GWU.GWU_EMISDC "
	cQuery += "AND GWE.GWE_CDTPDC = GWU.GWU_CDTPDC "
	cQuery += "AND GWE.GWE_SERDC  = GWU.GWU_SERDC "
	cQuery += "AND GWE.GWE_NRDC   = GWU.GWU_NRDC "
	cQuery += "AND GWE.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN " + RetSQLName("DT6") + " DT6 "
	cQuery += "ON  DT6.DT6_FILDOC = GWE.GWE_FILDT "
	cQuery += "AND DT6.DT6_DOC    = GWE.GWE_NRDT "
	cQuery += "AND DT6.DT6_SERIE  = GWE.GWE_SERDT "
	cQuery += "AND DT6.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN " + RetSQLName("GWL") + " GWL "
	cQuery += "ON  GWL.GWL_FILDC  = GWU.GWU_FILIAL "
	cQuery += "AND GWL.GWL_TPDC   = GWU.GWU_CDTPDC "
	cQuery += "AND GWL.GWL_EMITDC = GWU.GWU_EMISDC "
	cQuery += "AND GWL.GWL_SERDC  = GWU.GWU_SERDC "
	cQuery += "AND GWL.GWL_NRDC   = GWU.GWU_NRDC "
	cQuery += "AND GWL.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN " + RetSQLName("GWD") + " GWD "
	cQuery += "ON  GWD.GWD_FILIAL = GWL.GWL_FILIAL "
	cQuery += "AND GWD.GWD_NROCO  = GWL.GWL_NROCO "
	cQuery += "AND GWD.GWD_CDTRP  = GWU.GWU_CDTRP "
	cQuery += "AND GWD.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN " + RetSQLName("GU5") + " GU5 "
	cQuery += "ON  GU5.GU5_FILIAL = '" + xFilial("GU5") + "'"
	cQuery += "AND GU5.GU5_CDTIPO = GWD.GWD_CDTIPO "
	cQuery += "AND GU5.D_E_L_E_T_ = '' "
	cQuery += "WHERE GWU.D_E_L_E_T_ = ''   "
	//Retorna o filtro do SQL
	cQuery += C054FILSQL()
	
	cQuery += "ORDER BY GWU_FILDT, GWU_NRDT, GWU_SERDT, GWU_FILIAL, GWU_CDTPDC, GWU_EMISDC, GWU_SERDC, GWU_NRDC, GWU_SEQ, GWD_FILIAL, GWD_NROCO"
	
	cQuery := ChangeQuery(cQuery)
	SqlToTrb(cQuery, GetStruct(aFieldsGWU), cAliasGWU)

	cQuery := ""

	//RecCount
	SetRegua((cAliasGWE)->(RecCount()))
	
	(cAliasGWE)->( dbGoTop())
	While !(cAliasGWE)->(Eof())

		IncRegua()

		If lOpenEdge
	
			GWE->(dbSetOrder(02))
			If GWE->(dbSeek(xFilial("GWE")+(cAliasGWE)->GWE_FILDT+(cAliasGWE)->GWE_NRDT+(cAliasGWE)->GWE_SERDT))
				While !GWE->(Eof()) .And. xFilial("GWE")+(cAliasGWE)->GWE_FILDT+(cAliasGWE)->GWE_NRDT+(cAliasGWE)->GWE_SERDT == ;
						GWE->(GWE_FILIAL+GWE_FILDT+GWE_NRDT+GWE_SERDT)
											
					RecLock(cAliasGWE, .F.)
					
					GWL->(dbSetOrder(03))
					If GWL->(dbSeek(GWE->(GWE_FILIAL+GWE_EMISDC+GWE_CDTPDC+GWE_SERDC+GWE_NRDC)))
						(cAliasGWE)->QTD_OCO += 1
					EndIf

					(cAliasGWE)->QTD_DOC += 1
						
					MsUnlock(cAliasGWE)
					
					GWE->(dbSkip())
				EndDo
			EndIf
			
		EndIf

		/*1-Elimina os registros duplicados/inválidos.
		  Como há left join com GWD/GWL, precisa haver exclusão por 2 motivos.		   
		  1: DC com 2 trechos, um com mais de 1 ocorrência e outro sem, é necessário eliminar as linhas duplicadas do trecho sem ocorrência;			          
		  2: DC com 2 trechos, um com mais de 1 ocorrência e outro com 1 ocorrência, é necessário eliminar as linhas sem ocorrência para que
		     não ocorra de ter um trecho com uma ocorrência e mais uma linha com ocorrência em branco.*/			
		(cAliasGWU)->(dbSetOrder(01))
		(cAliasGWU)->(dbSeek((cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT)))

		While !(cAliasGWU)->(Eof())	.And. (cAliasGWE)->GWE_FILDT == (cAliasGWU)->GWU_FILDT ;
				.And. (cAliasGWE)->GWE_NRDT == (cAliasGWU)->GWU_NRDT ;
				.And. (cAliasGWE)->GWE_SERDT == (cAliasGWU)->GWU_SERDT
	
			cChaveGWU := (cAliasGWU)->(GWU_FILDT+GWU_NRDT+GWU_SERDT+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)
			cChaveGWD := (cAliasGWU)->(GWD_FILIAL+GWD_NROCO)
			aAreaGWU  := (cAliasGWU)->(GetArea())
			
			(cAliasGWU)->(dbSkip())
			While !(cAliasGWU)->(Eof())	.And. (cAliasGWE)->GWE_FILDT == (cAliasGWU)->GWU_FILDT ;
					.And. (cAliasGWE)->GWE_NRDT == (cAliasGWU)->GWU_NRDT ;
					.And. (cAliasGWE)->GWE_SERDT == (cAliasGWU)->GWU_SERDT;
					.And. cChaveGWU == (cAliasGWU)->(GWU_FILDT+GWU_NRDT+GWU_SERDT+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)
											
				If ((Empty((cAliasGWU)->(GWD_FILIAL+GWD_NROCO)) .And. Empty(cChaveGWD)) .Or.;
						(Empty(cChaveGWD) .And. !Empty((cAliasGWU)->(GWD_FILIAL+GWD_NROCO))))
					aAreaGWU2 := (cAliasGWU)->(GetArea())
					
					RestArea(aAreaGWU)
					RecLock(cAliasGWU, .F.)
					(cAliasGWU)->(dbDelete())
					MsUnlock(cAliasGWU)
					
					RestArea(aAreaGWU2)
					cChaveGWU := (cAliasGWU)->(GWU_FILDT+GWU_NRDT+GWU_SERDT+GWU_FILIAL+GWU_CDTPDC+GWU_EMISDC+GWU_SERDC+GWU_NRDC+GWU_SEQ)
					cChaveGWD := (cAliasGWU)->(GWD_FILIAL+GWD_NROCO)
					aAreaGWU  := (cAliasGWU)->(GetArea())					
				EndIf

				(cAliasGWU)->(dbSkip())
			EndDo
		EndDo
			
		/*2-Após eliminar os registros duplicados/inválidos, faz a lógica para determinar a situação do documento de frete.*/
		(cAliasGWU)->(dbSeek((cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT)))
		While !(cAliasGWU)->(Eof())	.And. (cAliasGWE)->GWE_FILDT == (cAliasGWU)->GWU_FILDT ;
				.And. (cAliasGWE)->GWE_NRDT  == (cAliasGWU)->GWU_NRDT ;
				.And. (cAliasGWE)->GWE_SERDT == (cAliasGWU)->GWU_SERDT
			RecLock(cAliasGWE, .F.)
			GWL->(dbSetOrder(03))
			If GWL->(dbSeek((cAliasGWU)->(GWU_FILIAL+GWU_EMISDC+GWU_CDTPDC+GWU_SERDC+GWU_NRDC))) // Documentos sem ocorrencia
				(cAliasGWE)->GWE_STATUS := "1"
			EndIf
			If (Empty((cAliasGWU)->GWD_CHVEXT) .And. (cAliasGWU)->GWD_SIT != "2")
				(cAliasGWE)->GWE_STATUS := "1"
			EndIf
			If (cAliasGWE)->GWE_STATUS != "1" .And. (cAliasGWU)->GU5_INTTMS == "Sim" .And. (cAliasGWU)->GWD_SIT = "2" .And. (cAliasGWU)->GWD_SITTMS $ "2;3"
				(cAliasGWE)->GWE_STATUS := "2"
			EndIf
			If Empty((cAliasGWE)->GWE_STATUS)
				(cAliasGWE)->GWE_STATUS := "3"
			EndIf
			MsUnlock(cAliasGWE)

			/*If lOpenEdge
				RecLock(cAliasGWU, .F.)
				GW8->(dbSetOrder(1))
				GW8->(dbSeek((cAliasGWU)->GWU_FILIAL + (cAliasGWU)->GWU_CDTPDC + (cAliasGWU)->GWU_EMISDC + (cAliasGWU)->GWU_SERDC + (cAliasGWU)->GWU_NRDC))
				While !GW8->(Eof()) .And. (cAliasGWU)->GWU_FILIAL + (cAliasGWU)->GWU_CDTPDC + (cAliasGWU)->GWU_EMISDC + (cAliasGWU)->GWU_SERDC + (cAliasGWU)->GWU_NRDC == GW8->GW8_FILIAL + GW8->GW8_CDTPDC + GW8->GW8_EMISDC + GW8->GW8_SERDC + GW8->GW8_NRDC
					(cAliasGWU)->GW8_PESOR += GW8->GW8_PESOR
					GW8->(dbSkip())
				EndDo
				MsUnlock(cAliasGWU)
			EndIf*/

			(cAliasGWU)->(dbSkip())
		EndDo

		/*If !(MV_PAR07 == 3 .Or. ( MV_PAR07 == 1 .And. (cAliasGWE)->GWE_STATUS $ '1;2') .Or. ( MV_PAR07 == 2 .And. (cAliasGWE)->GWE_STATUS = '3') )
			RecLock(cAliasGWE,.F.)
				(cAliasGWE)->(dbDelete())
			MsUnlock(cAliasGWE)
		EndIf*/
		DbSelectArea(cAliasGWE)
		MsUnlock(cAliasGWE)
		If !(MV_PAR07==2 .Or.(cAliasGWE)->GWE_STATUS $ '1;2')
			RecLock(cAliasGWE,.F.)
			(cAliasGWE)->(dbDelete())
			MsUnlock(cAliasGWE)

		EndIf
		(cAliasGWE)->(dbSkip())
	EndDo

Return

Static Function C054FILSQL()

	Local aFilPerm := FwUsrEmp(__cUserID)
	Local cQuery := ""
	Local nI := 0

	If !Empty(MV_PAR01)
		cQuery += "AND DT6.DT6_FILDOC >= '" + MV_PAR01 + "' "
	EndIf
	If !Empty(MV_PAR02)
		cQuery += "AND DT6.DT6_FILDOC <= '" + MV_PAR02 + "' "
	EndIf
	If !Empty(MV_PAR03)
		cQuery += "AND DT6.DT6_DOC >= '" + MV_PAR03 + "' "
	EndIf
	If !Empty(MV_PAR04)
		cQuery += "AND DT6.DT6_DOC <= '" + MV_PAR04 + "' "
	EndIf
	If !Empty(MV_PAR05)
		cQuery += "AND DT6." + SerieNfId("DT6",3,"DT6_SERIE") + " >= '" + MV_PAR05 + "' "
	EndIf
	If !Empty(MV_PAR06)
		cQuery += "AND DT6." + SerieNfId("DT6",3,"DT6_SERIE") + " <= '" + MV_PAR06 + "' "
	EndIf
	If !Empty(MV_PAR08)
		cQuery += "AND DT6.DT6_DATEMI >= '" + DtoS(MV_PAR08) + "' "
	EndIf
	If !Empty(MV_PAR09)
		cQuery += "AND DT6.DT6_DATEMI <= '" + DtoS(MV_PAR09) + "' "
	EndIf
	If !Empty(MV_PAR10)
		cQuery += "AND DT6.DT6_PRZENT >= '" + DtoS(MV_PAR10) + "' "
	EndIf
	If !Empty(MV_PAR11)
		cQuery += "AND DT6.DT6_PRZENT <= '" + DtoS(MV_PAR11) + "' "
	EndIf
	If AScan(aFilPerm,"@@@@") <= 0
		cQuery += "AND DT6.DT6_FILDOC IN (
		For nI := 1 to Len(aFilPerm)
			cQuery += "'" + SubStr(aFilPerm[nI], Len(cEmpAnt)+1) + "'" + If(nI == Len(aFilPerm), "", ", ")
		Next nI
		cQuery += " ) "
	EndIf

Return cQuery

Function C054Atualizar()
	SetRegua(5)
	oPanelDown:SetUpdatesEnabled(.F.)
	IncRegua()
	Pergunte("GFEC054",.F.)
	CarregarDados()
	IncRegua()
	oBrowseGWE:Refresh()
	IncRegua()
	oBrowseGWU:Refresh()
	IncRegua()
	oRelation:Activate()
	IncRegua()
	oPanelDown:SetUpdatesEnabled(.T.)
Return

/*/{Protheus.doc} GFEC054PEN

@author siegklenes.beulke
@since 16/12/2013
@version 1.0		

@return Nil

@description

Consulta as pendencias de um documento de transporte e apresenta o resultado

@example

GFEC054PEN()

/*/

Function GFEC054PEN()
	Private GFEResult := GFEViewProc():New()
	Private nCountErro := 0
	Processa({|| ProcessaPendencias()},"Consultando...", "")
	GFEResult:Show("Consulta de pêndencias", "Trechos avaliados", "Pendências", "Um ou mais documentos possuem pendências. Clique em 'Pendências' para mais detalhes.")
Return

/*/{Protheus.doc} GFEC054INT

@author siegklenes.beulke
@since 17/12/2013
@version 1.0		

@return Nil

@description

Realiza a tentativa da integração

@example

GFEC054INT()

/*/

Function GFEC054INT()
	Do Case
	Case (cAliasGWE)->GWE_STATUS == "1"
		MsgInfo("Documento de transporte não está apto à integração. Clique em Consultar Pendencias para mais detalhes","Aviso.")
	Case (cAliasGWE)->GWE_STATUS == "2"
		GFE032TMSINT((cAliasGWE)->(xFilial("GWE")+GWE_FILDT+GWE_NRDT+GWE_SERDT))
		RptStatus({||C054Atualizar()}, "Carregando", "Aguarde, atualizando dados...")

	Case (cAliasGWE)->GWE_STATUS == "3"
		MsgInfo("Todas as ocorrências relacionadas ao documento de transporte estão integradas","Aviso.")
	EndCase
Return

/*/{Protheus.doc} GFEC054DES
@author tamyris.g
@since 26/01/2017
@version 1.0		
@return Nil
@description
Realiza a tentativa de desatualizacao
@example
/*/
Function GFEC054DES()
	
	Do Case
	Case (cAliasGWE)->GWE_STATUS == "3"
		GFE032TMSINT((cAliasGWE)->(xFilial("GWE")+GWE_FILDT+GWE_NRDT+GWE_SERDT),,'6')
		RptStatus({||C054Atualizar()}, "Carregando", "Aguarde, atualizando dados...")
	Case (cAliasGWE)->GWE_STATUS <> "3"
		MsgInfo("Todas as ocorrências relacionadas ao documento de transporte estão desatualizadas","Aviso.")
	EndCase
	
Return

/*/{Protheus.doc} GFEC054PER

@author siegklenes.beulke
@since 18/12/2013
@version 1.0

@description

Atualiza os Parâmetros

@example

GFEC054PER()

/*/


Function GFEC054PAR()
	Pergunte("GFEC054",.T.)
	RptStatus({||C054Atualizar()}, "Carregando", "Aguarde, atualizando dados...")
Return

Static Function ProcessaPendencias()
	Local aAreaCGWU := (cAliasGWU)->(GetArea())
	Local nErros := 0
	(cAliasGWU)->(dbSeek((cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT)))
	ProcRegua((cAliasGWE)->QTD_DOC)
	While !(cAliasGWU)->(Eof()) .And. (cAliasGWE)->GWE_FILDT == (cAliasGWU)->GWU_FILDT;
			.And. (cAliasGWE)->GWE_NRDT ==  (cAliasGWU)->GWU_NRDT;
			.And. (cAliasGWE)->GWE_SERDT == (cAliasGWU)->GWU_SERDT
		IncProc("Processando Doc " + (cAliasGWU)->GWU_NRDC)
		nErros := 0
		If Empty((cAliasGWU)->GWD_NROCO)
			nErros++
			AddPend((cAliasGWU)->GWU_FILIAL, (cAliasGWU)->GWU_CDTPDC, (cAliasGWU)->GWU_CDTRP, (cAliasGWU)->GWU_SERDC, (cAliasGWU)->GWU_NRDC, "Não há ocorrências de transporte para este trecho.")
			nCountErro+=1
		EndIf
		If (cAliasGWU)->GU5_INTTMS == "Não" .Or. !Empty((cAliasGWU)->GWD_CHVEXT)
			nErros++
			AddPend((cAliasGWU)->GWU_FILIAL, (cAliasGWU)->GWU_CDTPDC, (cAliasGWU)->GWU_CDTRP, (cAliasGWU)->GWU_SERDC, (cAliasGWU)->GWU_NRDC, "Ocorrência " + AllTrim((cAliasGWU)->GWD_NROCO) + " não integra com o SIGATMS.")
			nCountErro+=1
		EndIf
		If (cAliasGWU)->GU5_INTTMS == "Sim" .And. Empty((cAliasGWU)->GWD_CHVEXT) .And. (cAliasGWU)->GWD_SIT != "2"
			nErros++
			AddPend((cAliasGWU)->GWU_FILIAL, (cAliasGWU)->GWU_CDTPDC, (cAliasGWU)->GWU_CDTRP, (cAliasGWU)->GWU_SERDC, (cAliasGWU)->GWU_NRDC, "Ocorrência " + AllTrim((cAliasGWU)->GWD_NROCO) + " não está aprovada.")
			nCountErro+=1
		EndIf
		If (cAliasGWU)->GU5_INTTMS == "Sim" .And. Empty((cAliasGWU)->GWD_CHVEXT) .And. (cAliasGWU)->GWD_SIT == "2" .And. (cAliasGWU)->GWD_SITTMS == "3"
			nErros++
			AddPend((cAliasGWU)->GWU_FILIAL, (cAliasGWU)->GWU_CDTPDC, (cAliasGWU)->GWU_CDTRP, (cAliasGWU)->GWU_SERDC, (cAliasGWU)->GWU_NRDC, "Ocorrência " + AllTrim((cAliasGWU)->GWD_NROCO) + " rejeitada pelo SIGATMS, aguardando nova integração.", GWD->GWD_MOTTMS)
			nCountErro+=1
		EndIf
		If nErros == 0
			If (cAliasGWU)->GU5_INTTMS == "Sim" .And. Empty((cAliasGWU)->GWD_CHVEXT) .And. (cAliasGWU)->GWD_SIT == "2" .And. (cAliasGWU)->GWD_SITTMS == "2"
				GFEResult:Add("Doc.Carga: " + AllTrim((cAliasGWU)->GWU_NRDC) + ", Transp: " + AllTrim((cAliasGWU)->GWU_CDTRP) + ", Trecho:" + (cAliasGWU)->GWU_SEQ + ", está apto à integração.")
			Else
				GFEResult:Add("Doc.Carga: " + AllTrim((cAliasGWU)->GWU_NRDC) + ", Transp: " + AllTrim((cAliasGWU)->GWU_CDTRP) + ", Trecho:" + (cAliasGWU)->GWU_SEQ + ", não existem pendencias de integração.")
			EndIf
		Else
			GFEResult:Add("Doc.Carga: " + AllTrim((cAliasGWU)->GWU_NRDC) + ", Transp: " + AllTrim((cAliasGWU)->GWU_CDTRP) + ", Trecho:" + (cAliasGWU)->GWU_SEQ + ", possui pendências de integração.")
		EndIf
		(cAliasGWU)->(dbSkip())
	EndDo
	RestArea(aAreaCGWU)
Return

/*/{Protheus.doc} AddPend
Adiciona a pendecia do documento de carga

@author Siegklenes.Beulke
@since 16/12/2013
@version 1.0
/*/

Static Function AddPend(cFil, cTpDc, cCdTrp, cSerDc, cNrDc, cMot, cLog)
	Default cLog := ""
	If (nCountErro > 0)
		GFEResult:AddErro("")
		GFEResult:AddErro(Replicate("-", 50))
	EndIf

	GFEResult:AddErro("Filial: " + cFil + ", Série: " + AllTrim(cSerDc) +  ", Número: " + AllTrim(cNrDc) + ", Tipo Docto.: " + AllTrim(cTpDc) + ", Transportador: " + AllTrim(cCdTrp))
	GFEResult:AddErro("- Motivo: " + cMot, 1)
	If  !Empty(cLog)
		GFEResult:AddErro("- SIGATMS: " + cLog,1)
	EndIf
Return

Function GFEC054OCO()
	Local aAreaAlGWU := (cAliasGWU)->(GetArea())
	Local aTransport := {} //Transportadores doc transp
	Local cTransp := "" //Transportadora selecionada
	(cAliasGWU)->(dbSeek((cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT)))

	While !(cAliasGWU)->(Eof()) .And. (cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT) == (cAliasGWU)->(GWU_FILDT+GWU_NRDT+GWU_SERDT)
		If aScan(aTransport,{|x| x == (cAliasGWU)->GWU_CDTRP}) == 0
			aAdd(aTransport,(cAliasGWU)->GWU_CDTRP)
		EndIf
		(cAliasGWU)->(dbSkip())
	EndDo
	If Len(aTransport) > 1
		cTransp := aTransport[1]
		DEFINE MSDIALOG oDlg TITLE "Selecione a Transportadora" From 0,0 To 4,30 OF oMainWnd

		oPanelTop := TPanel():New(0,0,,oDlg,,,,,,50,30,,)
		oPanelTop:Align := CONTROL_ALIGN_TOP

		oPanel := TPanel():New(0,0,,oPanelTop,,,,,,50,2,,)
		oPanel:Align := CONTROL_ALIGN_TOP

		oPanel := TPanel():New(0,0,,oPanelTop,,,,,,2,25,,)
		oPanel:Align := CONTROL_ALIGN_LEFT

		oPanel := TPanel():New(0,0,,oPanelTop,,,,,,2,25,,)
		oPanel:Align := CONTROL_ALIGN_RIGHT

		oPanel := TPanel():New(0,0,,oPanelTop,,,,,,50,2,,)
		oPanel:Align := CONTROL_ALIGN_BOTTOM

		oPanel := TPanel():New(0,0,,oPanelTop,,,,,,50,20,,)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelTMeio := TPanel():New(0,0,,oPanel,,,,,,50,10,,)
		oPanelTMeio:Align := CONTROL_ALIGN_TOP

		oSay := TSay():New (2, 0, {|| "Transportadora" }, oPanelTMeio, , , , , , .T., CLR_BLUE, , 40, 10, ,,,,, .T. )
		oSay:lTransparent := .T.
		oSay:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelBMeio := TPanel():New(0,0,,oPanel,,,,,,50,10,,)
		oPanelBMeio:Align := CONTROL_ALIGN_TOP

		oCombo := TComboBox():New(0,0, {|u|If(PCount()>0,cTransp:=u,cTransp)},aTransport,100,10,oPanelBMeio,,/*bChange,bValid,nClrBack,nClrText,lPixel,oFont,,,bWhen,,,,,cReadVar,cLabelText,nLabelPos,oLabelFont,nLabelColor*/)
		oCombo:Align := CONTROL_ALIGN_ALLCLIENT

		oPanel := TPanel():New(0,60,,oPanelBMeio,,,,,,25,10,,)
		oPanel:Align := CONTROL_ALIGN_RIGHT

		oBtn := TButton():New(0,2, "Ok", oPanel, {|| oDlg:End() },23,10,,/*[oFont]*/,,.T.,,,,/*[bWhen]*/)
		ACTIVATE MSDIALOG oDlg
		(cAliasGWU)->(dbSeek((cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT)))
		While !(cAliasGWU)->(Eof()) .And. (cAliasGWE)->(GWE_FILDT+GWE_NRDT+GWE_SERDT) == (cAliasGWU)->(GWU_FILDT+GWU_NRDT+GWU_SERDT)
			If AllTrim((cAliasGWU)->GWU_CDTRP) == AllTrim(cTransp)
				Exit
			EndIf
			(cAliasGWU)->(dbSkip())
		EndDo
	EndIf
	GFEC054AOCO() // Chamada em cascata diferenciará no gfea032
	RestArea(aAreaAlGWU)

Return

Function GFEC054TOD()
	Private GFEResult := GFEViewProc():New()
	Private nCountErro := 0
	If MsgYesNo("Deseja realmente integrar todos os documentos? Este processo pode levar alguns minutos.","Pergunta")
		Processa({|| IntegraTodos()},"Integrando...", "")
		GFEResult:Show("Integração", "Documentos", "Informações", "Um ou mais documentos possuem alertas ou não foram integrados. Clique em 'Informações' para mais detalhes.")
	EndIf
Return

Static Function IntegraTodos()
	(cAliasGWE)->(dbGoTop())
	ProcRegua(nDocTrp)
	While !(cAliasGWE)->(Eof())
		If (cAliasGWE)->GWE_STATUS == "2"
			IncProc("Série " + (cAliasGWE)->GWE_SERDT + ", Documento " + (cAliasGWE)->GWE_NRDT)
			GFE032TMSINT((cAliasGWE)->(xFilial("GWE")+GWE_FILDT+GWE_NRDT+GWE_SERDT),.F.)
		EndIf
		(cAliasGWE)->(dbSkip())
	EndDo
	RptStatus({||C054Atualizar()}, "Carregando", "Aguarde, atualizando dados...")
Return

Function GFEC054DTO()
	Private GFEResult := GFEViewProc():New()
	Private nCountErro := 0
	If MsgYesNo("Deseja realmente desatualizar todos os documentos? Este processo pode levar alguns minutos.","Pergunta")
		Processa({|| DesatuTodos()},"Desatualizando...", "")
		GFEResult:Show("Integração", "Documentos", "Informações", "Um ou mais documentos possuem alertas ou não foram desatualizados. Clique em 'Informações' para mais detalhes.")
	EndIf
Return

Static Function DesatuTodos()
	(cAliasGWE)->(dbGoTop())
	ProcRegua(nDocTrp)
	While !(cAliasGWE)->(Eof())
		If (cAliasGWE)->GWE_STATUS == "3"
			IncProc("Série " + (cAliasGWE)->GWE_SERDT + ", Documento " + (cAliasGWE)->GWE_NRDT)
			GFE032TMSINT((cAliasGWE)->(xFilial("GWE")+GWE_FILDT+GWE_NRDT+GWE_SERDT),.F.,'6')
		EndIf
		(cAliasGWE)->(dbSkip())
	EndDo
	RptStatus({||C054Atualizar()}, "Carregando", "Aguarde, atualizando dados...")
Return
