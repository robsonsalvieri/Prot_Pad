#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
//-------------------------------------------------------------------
//Inclusão Pátios 12.1.4
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001O
Painel Gerencial - Informações sobre Reprovações

Uso Restrito.
 
Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001O(aParam)

@author siegklenes.beulke
@since 04/04/2014
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC001O(aParam)
	Local aCoors 			:= FWGetDialogSize(oMainWnd)
	Local cTitulo 		:= 'Painel Gerencial - Reprovações do Transportador'
	Local aAreaGX5 		:= GX5->(GetArea())
	Private oBrowseRep
	Private cFilialDe  	:= aParam[1]
	Private cFilialAte	:= aParam[2]
	Private dDataDe    	:= If(Empty(aParam[3]),DDATABASE - 30 ,aParam[3])
	Private dDataAte   	:= If(Empty(aParam[4]),DDATABASE      ,aParam[4])  
	Private cCodEmit   	:= aParam[5]
	Private cFiltro		:= ''
	Private aFiltros
	Private cAliasGX3
	Private aGrfPtoCto
	Private aGrfOper
	Private oDLGC001O
	
	dbSelectArea("SIX") // Ativa o índice para pesquisa
	If SIX->(dbSeek("GX52"))
		dbSelectArea("GX5")
		GX5->(dbSetOrder(2))
	EndIf
	
	aFiltros := {{"GX3","GX3_CDEMIT" ,"=" ,cCodEmit		},;
				  {"GX3","GX3_FILIAL",">=",cFilialDe		},;
				  {"GX3","GX3_FILIAL","<=",cFilialAte	 	},;   
				  {"GX3","GX3_DTCRIA",">=",Dtos(dDataDe)  },;
				  {"GX3","GX3_DTCRIA","<=",Dtos(dDataAte) }}  
	
	cFiltro += "AND GX4.GX4_DTENTR <> '' "
	cFiltro += "AND GX3.GX3_SIT IN ('5','6') "	// GX3_SIT ==== 1=Aberto 2=Movimentado 3=Em Fila 4=Endereçado 5=Cancelado 6=Concluido

	Define MsDialog oDLGC001O Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLGC001O,.F.)
	
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddWindow('COL_LEFT','WIN_LEFT','Reprovações por Ponto de Controle',100,.F.,.F.,,'LINE_MIDDLE',)
  	oFWLayer:AddWindow('COL_RIGHT','WIN_RIGHT','Reprovações por Operação',100,.F.,.F.,,'LINE_MIDDLE',)
    
	oWIN_TOP	:= oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
	oWIN_LEFT 	:= oFWLayer:GetWinPanel('COL_LEFT','WIN_LEFT','LINE_MIDDLE')
	oWIN_RIGHT	:= oFWLayer:GetWinPanel('COL_RIGHT','WIN_RIGHT','LINE_MIDDLE')

    oDLGC001O:Activate(,,,.T.,,,{||Processa({||Iniciar()})})

    GFEDelTab(cAliasGX3)
    RestArea(aAreaGX5)
Return 

Static Function Iniciar()
	Local aFieldsGX3
	Local nCount 
	Local cQuery := ""
	Local nTam
	Do Case
		Case TCGetDB() == "ORACLE" // Temporária para oracle cria como CHAR, que suporta 2000 Caracteres
			nTam := 2000
		OtherWise
			nTam := 4000
	EndCase
	
	aFieldsGX3 := ;
	{{"Filial"			,"GX5_FILIAL"	,"C",TamSX3("GW1_FILIAL")[1],0,"",1,TamSX3("GW1_FILIAL")[1],.T.},;
	{"Nr Mov"			,"GX5_NRMOV" 	,"C",TamSX3("GX3_NRMOV")[1]	,0,"",1,8,.T.},;
	{"Transportador"	,"GX3_CDEMIT"	,"C",TamSX3("GX3_CDEMIT")[1],0,"",1,8,.T.},;
	{"Cód. Operação"	,"GVI_CDOPER"	,"C",TamSX3("GVI_CDOPER")[1],0,"",1,8,.T.},;
	{"Sequência"		,"GVI_SEQ"	 	,"C",TamSX3("GVI_SEQ")[1]	,0,"",1,2,.T.},;
	{"Desc. Config"	,"GVI_DSCONF"	,"C",TamSX3("GVI_DSCONF")[1],0,"",1,10,.T.},;
	{"Pto Controle"	,"GX5_CDPTCT"	,"C",TamSX3("GX4_CDPTCT")[1],0,"",1,10,.T.},;
	{"Pergunta"		,"GVG_DSPERG"	,"C",TamSX3("GVG_DSPERG")[1],0,"",1,10,.T.},;
	{"Observação"		,"OBSERVA"		,"C",nTam,0,"",1,10,.T.,{||GX5->(dbGoto((cAliasGX3)->GX5_OBS)), AllTrim(PadR(GX5->GX5_OBS,nTam))}},;
	{"Observação"		,"GX5_OBS"		,"N",15						,0,"",1,10,.F.},;
	{"Seq"				,"GX5_SEQ"		,"C",TamSX3("GX5_SEQ")[1]	,0,"",1,10,.F.};
	}
	
	cQuery +="SELECT 	GX5.GX5_FILIAL, GX5.GX5_NRMOV, GX5.GX5_SEQ, GX5.GX5_CDPTCT, GX5.R_E_C_N_O_ GX5_OBS,"
	cQuery +="			GX3.GX3_CDEMIT, GVI.GVI_CDOPER, GVI.GVI_SEQ, GVI.GVI_DSCONF, GVG.GVG_DSPERG"
	cQuery +="  FROM " + RetSqlName("GX3") + " GX3"
	cQuery +=" INNER JOIN " + RetSqlName("GX4") + " GX4"
	cQuery +="    ON GX4.D_E_L_E_T_ = ''"
	cQuery +="   AND GX3.GX3_FILIAL	= GX4.GX4_FILIAL"
	cQuery +="   AND GX3.GX3_NRMOV	= GX4.GX4_NRMOV"

	cQuery +=" INNER JOIN " + RetSqlName("GVI") + " GVI"
	cQuery +="		ON GVI.D_E_L_E_T_ = ''"
	cQuery +="   AND GX3.GX3_FILIAL	= GVI.GVI_FILIAL"
	cQuery +="   AND GX3.GX3_CDOPER	= GVI.GVI_CDOPER"
	cQuery +="   AND GX3.GX3_SEQ		= GVI.GVI_SEQ"

	cQuery +=" INNER JOIN " + RetSqlName("GX5") + " GX5"
	cQuery +="		ON GX5.D_E_L_E_T_ 	= ''"
	cQuery +="   AND GX3.GX3_FILIAL	= GX5.GX5_FILIAL"
	cQuery +="   AND GX3.GX3_NRMOV		= GX5.GX5_NRMOV"
	cQuery +="   AND GX4.GX4_CDPTCT	= GX5.GX5_CDPTCT"
	cQuery +="   AND GX4.GX4_SEQ		= GX5.GX5_SEQ"
	cQuery +="   AND GX5.GX5_RESPOS	= '2'"

	cQuery +=" INNER JOIN " + RetSqlName("GVG") + " GVG"
	cQuery +="		ON GVG.D_E_L_E_T_ = ''"
	cQuery +="   AND GX5.GX5_CDPERG = GVG.GVG_CDPERG"
	cQuery +=" WHERE GX3.D_E_L_E_T_ = '' " + CriaQueryCondicao(aFiltros,"")
	cQuery += cFiltro
	
	cAliasGX3 := CriaTab(cQuery,aFieldsGX3,{"GX5_FILIAL+GX5_NRMOV+GX5_SEQ+GX5_CDPTCT"})
	
	CarregaDados() // Array dos gráficos

	oBrowseRep:= FWMBrowse():New() 
	oBrowseRep:SetOwner(oWIN_TOP)  
	oBrowseRep:SetDescription("Reprovações")
	oBrowseRep:SetAlias(cAliasGX3)
	oBrowseRep:DisableDetails()
	oBrowseRep:SetFixedBrowse(.T.)
	oBrowseRep:DisableConfig()
	oBrowseRep:SetAmbiente(.F.)
	oBrowseRep:SetWalkthru(.F.)
	oBrowseRep:SetProfileID("1")
	oBrowseRep:SetMenuDef("GFEC001O")
	oBrowseRep:ForceQuitButton()
	
	
	For nCount := 1 To Len(aFieldsGX3)
		If aFieldsGX3[nCount][9]
			oBrowseRep:AddColumn({aFieldsGX3[nCount][1],;
									If (Len(aFieldsGX3[nCount]) != 10,;
								     &("{|| (cAliasGX3)->" + aFieldsGX3[nCount][2] + "}"),;
								     aFieldsGX3[nCount][10]),;
								     aFieldsGX3[nCount][3],;
								     aFieldsGX3[nCount][6],;
								     aFieldsGX3[nCount][7],;
								     aFieldsGX3[nCount][8],;
								     aFieldsGX3[nCount][5],;
								     .F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}})
		EndIf						     
	Next nCount
	
	oBrowseRep:Activate()
	
    // Gráfico - Reprovações Ponto
	GFEC001GRC("oGrfPtoCto", "", oWIN_LEFT, aGrfPtoCto)
	
	// Gráfico - Reprovações Operação
	GFEC001GRC("oGrfOper", "", oWIN_RIGHT, aGrfOper)
Return Nil

//
// Chama consulta do Movimento
//
Function C001OVisualGX3()
	Local aAreaGX3 := GX3->(GetArea())
	GX3->(dbSetOrder(1))
	GX3->(dbSeek((cAliasGX3)->GX5_FILIAL + (cAliasGX3)->GX5_NRMOV))
	FWExecView("Visualizar","GFEC510",MODEL_OPERATION_VIEW,,{||.T.})
	RestArea(aAreaGX3)
Return Nil

Static Function CarregaDados()
	Local cQuery := ''
	Local cTmp   := ''
	
	aGrfPtoCto := {}
	aGrfOper := {}
	
	cQuery := "SELECT GX4.GX4_CDPTCT, COUNT(*) QTD"
	cQuery += "  FROM " + RetSqlName("GX3") + " GX3"
	cQuery += " INNER JOIN " + RetSqlName("GX4") + " GX4	 ON GX4.GX4_FILIAL = GX3.GX3_FILIAL"
	cQuery += "												AND GX4.GX4_NRMOV  = GX3.GX3_NRMOV"
	cQuery += "											   	AND GX4.D_E_L_E_T_ = '' "
	cQuery += " INNER JOIN " + RetSqlName("GX5") + " GX5	 ON GX5.GX5_FILIAL = GX3.GX3_FILIAL"
	cQuery += "												AND GX5.GX5_NRMOV  = GX3.GX3_NRMOV"
	cQuery += "												AND GX5.GX5_CDPTCT = GX4.GX4_CDPTCT"
	cQuery += "												AND GX5.GX5_SEQ    = GX4.GX4_SEQ"
	cQuery += "												AND GX5.GX5_RESPOS = '2'"
	cQuery += "												AND GX5.D_E_L_E_T_ = ''"
	cQuery += " WHERE GX3.D_E_L_E_T_ = '' " + CriaQueryCondicao(aFiltros,"")
	cQuery += cFiltro
	cQuery += " GROUP BY GX4.GX4_CDPTCT"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	
	While !(cTmp)->(Eof())
		aAdd(aGrfPtoCto,{(cTmp)->GX4_CDPTCT,(cTmp)->QTD})
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
	
	cQuery := "SELECT GX3.GX3_CDOPER, COUNT(*) QTD"
	cQuery += "  FROM " + RetSqlName("GX3") + " GX3"
	cQuery += " INNER JOIN " + RetSqlName("GX4") + " GX4"
	cQuery += "    ON GX4.D_E_L_E_T_ 	= ''"
	cQuery += "	AND GX3.GX3_FILIAL	= GX4.GX4_FILIAL"
	cQuery += "	AND GX3.GX3_NRMOV		= GX4.GX4_NRMOV"
	cQuery += " INNER JOIN " + RetSqlName("GX5") + " GX5"
	cQuery += "    ON GX5.D_E_L_E_T_ 	= ''"
	cQuery += "	AND GX3.GX3_FILIAL	= GX5.GX5_FILIAL"
	cQuery += "	AND GX3.GX3_NRMOV	  	= GX5.GX5_NRMOV"
	cQuery += "	AND GX4.GX4_CDPTCT	= GX5.GX5_CDPTCT"
	cQuery += "	AND GX4.GX4_SEQ		= GX5.GX5_SEQ"
	cQuery += "	AND GX5.GX5_RESPOS	= '2'"
	cQuery += " WHERE GX3.D_E_L_E_T_ = '' " + CriaQueryCondicao(aFiltros,"")
	cQuery += cFiltro
	cQuery += " GROUP BY GX3.GX3_CDOPER"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)	
	(cTmp)->(dbGoTop())
	
	While !(cTmp)->(Eof())
		aAdd(aGrfOper,{(cTmp)->GX3_CDOPER,(cTmp)->QTD})
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
Return


Static Function CriaTab(cQuery,aFields,aIndices)
	Local cTmp
	Local aStruct := {}
	Local nCont 	:= 0
	
	For nCont := 1 To Len(aFields)
		If aFields[nCont][3] != "M"
			aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
							aFields[nCont][3],;  //Tipo
							aFields[nCont][4],;  //Tamanho
							aFields[nCont][5]}) //Decimal
		EndIf
	Next nCont
	
	cTmp := GFECriaTab({aStruct,aIndices})
	
	dbselectarea(cTmp)
	(cTmp)->(dbSetOrder(1))
	(cTmp)->(dbGotop())
	
	SqlToTrb(cQuery, aStruct, cTmp)
	
Return cTmp

Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE "Consultar Movimentação" 	ACTION "C001OVisualGX3()" OPERATION 2 ACCESS 0
Return aRotina