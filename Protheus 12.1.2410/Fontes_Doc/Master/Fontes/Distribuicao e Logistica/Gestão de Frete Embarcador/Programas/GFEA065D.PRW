#INCLUDE "GFEA065.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"   
#DEFINE TOTVS_COLAB_ONDEMAND 3100 // TOTVS Colaboracao 2.0
 
/*----------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA065D
Consulta de Documentos de Frete por Situação no Financeiro

@sample
GFEA065D()

@author Carlos Augusto Pereira
@since 14/10/2016
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function GFEA065D(cParam)
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local cTitulo := 'Consulta de Documentos de Frete por Situação no Financeiro'

	Private aBrowse := {}
	Private cSitFin  := cParam
	Private aFiltros
	Private cAliasGW3

	aFiltros := {{"GW6","GW6_SITFIN" ,"=" , cSitFin}}  

	Define MsDialog oDlg Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.)
	oFWLayer:AddCollumn('COL',100,,)

	oWIN   := oFWLayer:GetColPanel('COL',)

	oDlg:Activate(,,,.T.,,,{||Processa({||Iniciar()})})

	GFEDelTab(cAliasGW3) 
Return 


Static Function Iniciar()
	Local aFieldsGW3
	Local nCount 
	Local cSituac   := ""
	Local aLegenda 	:= {}
	Local nI

	cSituac := SitGW3()

	If cSituac <> ""
		cSituac = StrTokArr(cSituac,";")[Val(cSitFin)]
	EndIf

	aFieldsGW3 := ;
	{{"Espécie"      	,"{|| (cAliasGW3)->GW3_CDESP}"								,"C"	,TamSX3("GW3_CDESP")[1]		,0,"",1,	TamSX3("GW3_CDESP")[1]},;
	{"Emissor"     		,"{|| (cAliasGW3)->GW3_EMISDF}"								,"C"	,TamSX3("GW3_EMISDF")[1]	,0,"",1,	TamSX3("GW3_EMISDF")[1]},;
	{"Nome Emissor"     ,"{|| (cAliasGW3)->GW3_NMEMIS}"								,"C"	,TamSX3("GU3_NMEMIT")[1]	,0,"",1,	TamSX3("GU3_NMEMIT")[1]},;
	{"Série"      		,"{|| (cAliasGW3)->GW3_SERDF}"								,"C"	,TamSX3("GW3_SERDF")[1]		,0,"",1,	TamSX3("GW3_SERDF")[1]},;
	{"Nr Documento" 	,"{|| (cAliasGW3)->GW3_NRDF}" 								,"C"	,TamSX3("GW3_NRDF")[1]  	,0,"",1,	TamSX3("GW3_NRDF")[1]},;
	{"Dt Emissão"  		,"{|| (cAliasGW3)->GW3_DTEMIS}"								,"D"	,TamSX3("GW3_DTEMIS")[1]  	,0,"",1,	TamSX3("GW3_DTEMIS")[1]},;
	{"Tipo"  			,"{|| NGRETSX3BOX('GW3_TPDF',(cAliasGW3)->GW3_TPDF)  }"		,"C"	,TamSX3("GW3_TPDF")[1]  	,0,"",1,	20},;
	{"Data Entrada"		,"{|| (cAliasGW3)->GW3_DTENT}"								,"D"	,TamSX3("GW3_DTENT")[1]  	,0,"",1,	TamSX3("GW3_DTENT")[1]},;
	{"Remetente"		,"{|| (cAliasGW3)->GW3_CDREM}"								,"C"	,TamSX3("GW3_CDREM")[1]  	,0,"",1,	TamSX3("GW3_CDREM")[1]},;
	{"Destinatário"		,"{|| (cAliasGW3)->GW3_CDDEST}"								,"C"	,TamSX3("GW3_CDDEST")[1]  	,0,"",1,	TamSX3("GW3_CDDEST")[1]},;
	{"Valor Docto"		,"{|| (cAliasGW3)->GW3_VLDF}"								,"N"	,TamSX3("GW3_VLDF")[1]  	,0,"@E 999,999,999.99",1,	TamSX3("GW3_VLDF")[1]},;
	{"Tributação"		,"{|| NGRETSX3BOX('GW3_TRBIMP',(cAliasGW3)->GW3_TRBIMP)  }"	,"C"	,TamSX3("GW3_TRBIMP")[1]  	,0,"",1,	20},;
	{"Aliq Imposto"		,"{|| (cAliasGW3)->GW3_PCIMP}"								,"N"	,TamSX3("GW3_PCIMP")[1]  	,0,"@E 999,999,999.99",1,	TamSX3("GW3_PCIMP")[1]},;
	{"Vl Imposto"		,"{|| (cAliasGW3)->GW3_VLIMP}"								,"N"	,TamSX3("GW3_VLIMP")[1]  	,0,"@E 999,999,999.99",1,	TamSX3("GW3_VLIMP")[1]},;
	{"Nr Fatura"		,"{|| (cAliasGW3)->GW3_NRFAT}"								,"C"	,TamSX3("GW3_NRFAT")[1]  	,0,"",1,	TamSX3("GW3_NRFAT")[1]},;
	{"Sit Fiscal"		,"{|| NGRETSX3BOX('GW3_SITFIS',(cAliasGW3)->GW3_SITFIS)  }"	,"C"	,TamSX3("GW3_SITFIS")[1]  	,0,"",1,	20},;
	{"Sit Receb"		,"{|| NGRETSX3BOX('GW3_SITREC',(cAliasGW3)->GW3_SITREC)  }"	,"C"	,TamSX3("GW3_SITREC")[1]  	,0,"",1,	20},;
	{"Tipo do CT-e"		,"{|| NGRETSX3BOX('GW3_TPCTE',(cAliasGW3)->GW3_TPCTE)  }"	,"C"	,TamSX3("GW3_TPCTE")[1]  	,0,"",1,	TamSX3("GW3_TPCTE")[1]},;
	{"Dt Env Finan"		,"{|| (cAliasGW3)->GW3_DTFIN}"								,"D"	,TamSX3("GW6_DTFIN")[1]  	,0,"",1,	TamSX3("GW6_DTFIN")[1]},;
	{"Mot Rej Fin"		,"{|| (cAliasGW3)->GW3_MOTFIN}"								,"C"	,TamSX3("GW6_MOTFIN")[1] 	,0,"",1,20}}

	cAliasGW3 := CriaTab()

	oBrowseDoc:= FWMBrowse():New() 
	oBrowseDoc:SetOwner(oWIN)  
	oBrowseDoc:SetDescription("Situação no Financeiro: " + cSituac) 
	oBrowseDoc:SetAlias(cAliasGW3)
	oBrowseDoc:SetLocate()
	oBrowseDoc:DisableDetails()
	oBrowseDoc:DisableConfig()
	oBrowseDoc:SetAmbiente(.F.)
	oBrowseDoc:SetWalkthru(.F.)
	oBrowseDoc:SetProfileID("1") 
	oBrowseDoc:SetMenuDef("")
	oBrowseDoc:AddButton("Visualizar",{|| VisualGW3() },,2)
	oBrowseDoc:AddButton("Fechar",{|| oDlg:End() },,2)

	aAdd(aLegenda, {"GW3_SIT=='1'", "BLACK", STR0002}) //"Digitado"
	aAdd(aLegenda, {"GW3_SIT=='2'", "RED"  , STR0003}) //"Bloqueado"
	aAdd(aLegenda, {"GW3_SIT=='3'", "GREEN", STR0004}) //"Aprovado pelo Sistema"
	aAdd(aLegenda, {"GW3_SIT=='4'", "BLUE" , STR0005}) //"Aprovado pelo Usuário"
	aAdd(aLegenda, {"GW3_SIT=='5'", "YELLOW", "Bloqueado por Entrega"}) //"Bloqueado por Entrega"


	// Ponto de entrada para customizar as legendas do Browse
	If ExistBlock("GFE065LG")
		aLegenda := ExecBlock("GFE065LG",.f.,.f.,{aLegenda})
	EndIf

	For nI := 1 To Len(aLegenda)
		oBrowseDoc:AddLegend(aLegenda[nI][1], aLegenda[nI][2], aLegenda[nI][3])
	Next

	For nCount := 1 To Len(aFieldsGW3)
		oBrowseDoc:AddColumn({aFieldsGW3[nCount][1],;
		&(aFieldsGW3[nCount][2]),;
		aFieldsGW3[nCount][3],;
		aFieldsGW3[nCount][6],;
		aFieldsGW3[nCount][7],;
		aFieldsGW3[nCount][8],;
		aFieldsGW3[nCount][5],;
		.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})						     
	Next nCount

	oBrowseDoc:Activate()
	Define Font oFont Name 'Courier New' Size 0, -12

Return Nil


Static Function CriaTab()
	Local cQuery := ""
	Local cAlias
	Local aFields, aIndices
	Local nCont
	Local cTmp
	Local aStruct := {}

	aFields := ;
	{{"Filial"	    	,"GW3_FILIAL"		,"C"	,TamSX3("GW3_FILIAL")[1],0,"",1,TamSX3("GW3_FILIAL")[1]},;
	{"Situação"      	,"GW3_SIT"			,"C"	,TamSX3("GW3_SIT")[1]	,0,"",1,TamSX3("GW3_FILIAL")[1]},;
	{"Espécie"      	,"GW3_CDESP"		,"C"	,TamSX3("GW3_CDESP")[1]	,0,"",1,TamSX3("GW3_CDESP")[1]},;
	{"Emissor"     		,"GW3_EMISDF"		,"C"	,TamSX3("GW3_EMISDF")[1],0,"",1,TamSX3("GW3_EMISDF")[1]},;
	{"Nome Emissor"     ,"GW3_NMEMIS"		,"C"	,TamSX3("GU3_NMEMIT")[1],0,"",1,TamSX3("GW3_NMEMIS")[1]},;
	{"Série"      		,"GW3_SERDF"		,"C"	,TamSX3("GW3_SERDF")[1]	,0,"",1,TamSX3("GW3_SERDF")[1]},;
	{"Nr Documento" 	,"GW3_NRDF" 		,"C"	,TamSX3("GW3_NRDF")[1]  ,0,"",1,TamSX3("GW3_NRDF")[1]},;
	{"Dt Emissão"  		,"GW3_DTEMIS"		,"D"	,TamSX3("GW3_DTEMIS")[1],0,"",1,TamSX3("GW3_DTEMIS")[1]},;
	{"Tipo"  			,"GW3_TPDF"			,"C"	,TamSX3("GW3_TPDF")[1]  ,0,"",1,TamSX3("GW3_TPDF")[1]},;
	{"Data Entrada"		,"GW3_DTENT"		,"D"	,TamSX3("GW3_DTENT")[1] ,0,"",1,TamSX3("GW3_DTENT")[1]},;
	{"Remetente"		,"GW3_CDREM"		,"C"	,TamSX3("GW3_CDREM")[1] ,0,"",1,TamSX3("GW3_CDREM")[1]},;
	{"Destinatário"		,"GW3_CDDEST"		,"C"	,TamSX3("GW3_CDDEST")[1],0,"",1,TamSX3("GW3_CDDEST")[1]},;
	{"Valor Docto"		,"GW3_VLDF"			,"N"	,TamSX3("GW3_VLDF")[1]  ,0,"",1,TamSX3("GW3_VLDF")[1]},;
	{"Tributação"		,"GW3_TRBIMP"		,"C"	,TamSX3("GW3_TRBIMP")[1],0,"",1,TamSX3("GW3_TRBIMP")[1]},;
	{"Aliq Imposto"		,"GW3_PCIMP"		,"N"	,TamSX3("GW3_PCIMP")[1] ,0,"",1,TamSX3("GW3_PCIMP")[1]},;
	{"Vl Imposto"		,"GW3_VLIMP"		,"N"	,TamSX3("GW3_VLIMP")[1] ,0,"",1,TamSX3("GW3_VLIMP")[1]},;
	{"Nr Fatura"		,"GW3_NRFAT"		,"C"	,TamSX3("GW3_NRFAT")[1] ,0,"",1,TamSX3("GW3_NRFAT")[1]},;
	{"Sit Fiscal"		,"GW3_SITFIS"		,"C"	,TamSX3("GW3_SITFIS")[1],0,"",1,TamSX3("GW3_SITFIS")[1]},;
	{"Sit Receb"		,"GW3_SITREC"		,"C"	,TamSX3("GW3_SITREC")[1],0,"",1,TamSX3("GW3_SITREC")[1]},;
	{"Tipo do CT-e"		,"GW3_TPCTE"		,"C"	,TamSX3("GW3_TPCTE")[1] ,0,"",1,TamSX3("GW3_TPCTE")[1]},;
	{"Dt Env Finan"		,"GW3_DTFIN"		,"D"	,TamSX3("GW6_DTFIN")[1]	,0,"",1,TamSX3("GW3_DTFIN")[1]},;
	{"Mot Rej Fin"		,"GW3_MOTFIN"		,"M"	,TamSX3("GW6_MOTFIN")[1],0,"",1,TamSX3("GW3_MOTFIN")[1]}}

	aIndices := {"GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DtoS(GW3_DTEMIS)"} 

	For nCont := 1 To Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
		aFields[nCont][3],;  //Tipo
		aFields[nCont][4],;  //Tamanho
		aFields[nCont][5]}) //Decimal
	Next nCont

	cAlias := GFECriaTab({aStruct,aIndices})

	cQuery := " SELECT GW3.GW3_SIT, GW3.GW3_FILIAL, GW3.GW3_CDESP, GW3.GW3_EMISDF, GW3.GW3_SERDF, GW3.GW3_NRDF, GW3.GW3_DTEMIS, " 
	cQuery += " GW3.GW3_TPDF, GW3.GW3_DTENT, GW3.GW3_CDREM, GW3.GW3_CDDEST, GW3.GW3_VLDF ,GW3.GW3_TRBIMP, GW3.GW3_PCIMP, "
	cQuery += " GW3.GW3_VLIMP, GW3.GW3_NRFAT, GW3.GW3_SITFIS, GW3.GW3_SITREC, GW3.GW3_TPCTE, "
	cQuery += " GW3.GW3_FILFAT, GW3.GW3_EMIFAT, GW3.GW3_SERFAT, GW3.GW3_NRFAT, GW3.GW3_DTEMFA "
	cQuery += " FROM "+RetSqlName('GW3')+" GW3  "
	cQuery += "  INNER JOIN " + RetSQLName("GW6") + " GW6 ON GW6.GW6_FILIAL = GW3.GW3_FILFAT"
	cQuery += "    AND GW6.GW6_EMIFAT = GW3.GW3_EMIFAT"
	cQuery += "    AND GW6.GW6_SERFAT = GW3.GW3_SERFAT"
	cQuery += "    AND GW6.GW6_NRFAT  = GW3.GW3_NRFAT"
	cQuery += "    AND GW6.GW6_DTEMIS = GW3.GW3_DTEMFA"
	cQuery += "    AND '"+ xFilial("GW6") + "' =  '" + xFilial("GW3") + "'" 
	cQuery += "    AND GW6.GW6_SITFIN = '" + cSitFin + "' "
	cQuery += "    AND GW6.D_E_L_E_T_ = ' '"
	cQuery += "    AND GW3.D_E_L_E_T_ = ' '"

	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())

	While (cTmp)->(!Eof())
		RecLock(cAlias,.T.)
		(cAlias)->GW3_FILIAL   := (cTmp)->GW3_FILIAL
		(cAlias)->GW3_CDESP    := (cTmp)->GW3_CDESP
		(cAlias)->GW3_SIT	   := (cTmp)->GW3_SIT
		(cAlias)->GW3_EMISDF   := (cTmp)->GW3_EMISDF	
		(cAlias)->GW3_NMEMIS   := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GW3_EMISDF,"GU3_NMEMIT")
		(cAlias)->GW3_SERDF    := (cTmp)->GW3_SERDF
		(cAlias)->GW3_NRDF     := (cTmp)->GW3_NRDF
		(cAlias)->GW3_DTEMIS   := StoD((cTmp)->GW3_DTEMIS)
		(cAlias)->GW3_TPDF	   := (cTmp)->GW3_TPDF	
		(cAlias)->GW3_DTENT    := StoD((cTmp)->GW3_DTENT)
		(cAlias)->GW3_CDREM    := (cTmp)->GW3_CDREM 
		(cAlias)->GW3_CDDEST   := (cTmp)->GW3_CDDEST
		(cAlias)->GW3_VLDF	   := (cTmp)->GW3_VLDF	
		(cAlias)->GW3_TRBIMP   := (cTmp)->GW3_TRBIMP
		(cAlias)->GW3_PCIMP    := (cTmp)->GW3_PCIMP 
		(cAlias)->GW3_VLIMP    := (cTmp)->GW3_VLIMP 
		(cAlias)->GW3_NRFAT    := (cTmp)->GW3_NRFAT 
		(cAlias)->GW3_SITFIS   := (cTmp)->GW3_SITFIS
		(cAlias)->GW3_SITREC   := (cTmp)->GW3_SITREC
		(cAlias)->GW3_TPCTE    := (cTmp)->GW3_TPCTE
		(cAlias)->GW3_DTFIN	   := Posicione("GW6",1,(cTmp)->GW3_FILFAT+(cTmp)->GW3_EMIFAT+(cTmp)->GW3_SERFAT+(cTmp)->GW3_NRFAT+(cTmp)->GW3_DTEMFA,"GW6_DTFIN")
		(cAlias)->GW3_MOTFIN   := Posicione("GW6",1,(cTmp)->GW3_FILFAT+(cTmp)->GW3_EMIFAT+(cTmp)->GW3_SERFAT+(cTmp)->GW3_NRFAT+(cTmp)->GW3_DTEMFA,"GW6_MOTFIN")
		MsUnlock(cAlias)
		(cTmp)->(dbSkip())
	EndDo

	(cTmp)->(dbCloseArea())
Return cAlias

Function SitGW3()
	Local cCampo, cCombo
	dbSelectArea("SX3")
	dbSetOrder(2)
	cCampo := "GW3_SITFIN"
	If dbSeek(cCampo)  
		cCombo  := X3Cbox()
	EndIf
Return cCombo

Static Function VisualGW3()
	Local aOldAreaGW := GetArea()

	dbSelectArea("GW3")
	GW3->(dbSetOrder(1))
	If GW3->(dbSeek((cAliasGW3)->GW3_FILIAL + (cAliasGW3)->GW3_CDESP + (cAliasGW3)->GW3_EMISDF + (cAliasGW3)->GW3_SERDF + (cAliasGW3)->GW3_NRDF + DTOS((cAliasGW3)->GW3_DTEMIS)))
		FWExecView("Frete Embarcador",'GFEC065', 1, , {|| .F. },{|| .F.},,,{|| .T.})
	EndIf 
	RestArea(aOldAreaGW)	

Return Nil