#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEC001L
Painel Gerencial - Informações sobre Negociações

Uso Restrito. 
 
Param:
aParam[1] := Filial de
aParam[2] := Filial ate
aParam[3] := Data de
aParam[4] := Data ate
aParam[5] := Codigo do Emitente     

@sample
GFEC001L(aParam)

@author Alan Victor Lamb
@since 18/06/13
@version 1.0
--------------------------------------------------------------------------------------------------/*/  
Function GFEC001L(aParam, dData)   
	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := 'Painel Gerencial - Transportador'     
	
	Private oBrowseNeg, oBrowseCla, oBrowseTip, oBrowseCid
	Private aDados, aFiltros, aBrowse
	Private oGrfSit, oGrfHor
	Private cFilialDe  := aParam[1]
	Private cFilialAte := aParam[2]
	Private dDataDe  := If(Empty(aParam[3]),DDATABASE -30 ,aParam[3])
	Private dDataAte := If(Empty(aParam[4]),DDATABASE     ,aParam[4])     
	Private dDataNeg := dData // Data base utilizada para as negociações             
	Private cCodEmit := aParam[5]
	Private cAliasGV9, cAliasCid
	Private aFieldsGV9, aIndicGV9, aFieldsCid, aIndicCid
		
	aFieldsGV9 := ;
	{{"Transportador"	       ,"GV9_CDEMIT","C",14,0,"",1},;
	{"Nome do Transp."	   ,"GV9_NMEMIT","C",30,0,"",1},;
	{"Tabela"  		  	   ,"GV9_NRTAB" ,"C",6,0,"",1},;
	{"Desc Tabela"  		   ,"GV9_DSTAB" ,"C",50,0,"",1},;
	{"Negociação"            ,"GV9_NRNEG" ,"C",6,0,"",1},;
	{"Class Frete"           ,"GV9_CDCLFR","C",10,0,"",1},;
	{"Desc Class Frete"     ,"GV9_DSCLFR","C",50,0,"",1},;
	{"Tipo Oper"			   ,"GV9_CDTPOP","C",10,0,"",1},;
	{"Desc Tipo Oper"		   ,"GV9_DSTPOP","C",30,0,"",1},;
	{"Vigência de"	       ,"GV9_DTVALI","D",10,0,"",1},;
	{"Vigência até"          ,"GV9_DTVALF","D",10,0,"",1},;
	{"Class"	               ,"GV9_TPLOTA","C",10,0,"",1},;
	{"Data Criação"		   ,"GV9_DTCRIA" ,"D",10,0,"",1},;
	{"Hora Criação"		   ,"GV9_HRCRIA" ,"C",10,0,"",1}}
	
	aIndicGV9 := {"GV9_CDEMIT","GV9_CDCLFR","GV9_CDTPOP"}
	
	aFieldsCid := ;
	{{"UF"	         ,"GU7_CDUF" ,"C",2,0,"",1},;
	{"Cidade"	   	 ,"GU7_NMCID","C",30,0,"",1},;
	{"Qtd Entregas","QTD"       ,"N",15,0,"",1},;
	{"Ult Entrega" ,"GWU_DTENT","D",10,0,"",1}}
	
	aIndicCid := {"GU7_CDUF+GU7_NMCID"}
	
	//Cria tabelas temporárias
	cAliasGV9 := CriaTab(aFieldsGV9, aIndicGV9)
	cAliasCid := CriaTab(aFieldsCid, aIndicCid)
	
	aFiltros := {{"GWV","GWV_CDEMIT","=" ,cCodEmit},;
				   {"GWV","GWV_FILIAL",">=",cFilialDe},;
				   {"GWV","GWV_FILIAL","<=",cFilialAte},;   
				   {"GWV","GWV_DTAGEN",">=",Dtos(dDataDe)},;
				   {"GWV","GWV_DTAGEN","<=",Dtos(dDataAte)}}  
	
	Define MsDialog oDLG Title cTitulo From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDLG,.F.)
	oFWLayer:AddLine('LINE_TOP',50,.F.)
	oFWLayer:AddLine('LINE_MIDDLE',50,.F.)
	oFWLayer:AddCollumn('COL_TOP',100,.T.,'LINE_TOP')
	oFWLayer:AddCollumn('COL_LEFT',50,.T.,'LINE_MIDDLE')
	oFWLayer:AddCollumn('COL_RIGHT',50,.T.,'LINE_MIDDLE')
    
    oWIN_TOP   := oFWLayer:GetColPanel('COL_TOP','LINE_TOP')
    oWIN_LEFT  := oFWLayer:GetColPanel('COL_LEFT','LINE_MIDDLE')
    oWIN_RIGHT := oFWLayer:GetColPanel('COL_RIGHT','LINE_MIDDLE')
	
	oDLG:Activate(,,,.T.,,,{||Processa({||Iniciar()})})
	
	GFEDelTab(cAliasCid)
	GFEDelTab(cAliasGV9)
Return 

Static Function Iniciar()
	Local cBrowseFiltro  
	Local nCont := 0
	
	CarregaDados(aFiltros)
	
	// Negociações
	oBrowseNeg:= FWMBrowse():New()
	oBrowseNeg:SetOwner(oWIN_TOP)
	oBrowseNeg:SetAlias(cAliasGV9)
	oBrowseNeg:SetDescription("Negociações")
	oBrowseNeg:SetLocate()
	oBrowseNeg:SetAmbiente(.F.)
	oBrowseNeg:SetWalkthru(.F.)
	oBrowseNeg:DisableDetails()
	oBrowseNeg:DisableConfig()
	oBrowseNeg:SetMenuDef("")
	oBrowseNeg:AddButton("Visualizar","GFEC001LVI()",,2)
	oBrowseNeg:ForceQuitButton(.T.)
	oBrowseNeg:SetProfileID("1")
	
	For nCont := 1 To Len(aFieldsGV9)
		oBrowseNeg:AddColumn({aFieldsGV9[nCont][1],&("{|| (cAliasGV9)->" + aFieldsGV9[nCont][2] + "}"),aFieldsGV9[nCont][3],aFieldsGV9[nCont][6],aFieldsGV9[nCont][7],aFieldsGV9[nCont][4],aFieldsGV9[nCont][5],.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{} } )
	Next nCont
	
	oBrowseNeg:Activate()
		
	oFolder := TFolder():New(0,0,{"Tipos de operação","Classificações de frete"},,oWIN_LEFT,,,,.T.,,(oWIN_LEFT:nwidth/2),(oWIN_LEFT:nHeight/2))
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT
	
	//
	// Tipos de Operação das Negociações vigentes
	//
	oBrowseTip := FWMBrowse():New()
	oBrowseTip:SetOwner(oFolder:aDialogs[1])
	oBrowseTip:SetDescription("Tipos de Operação das Negociações Vigentes")
	oBrowseTip:SetAlias("GV4")
	oBrowseTip:SetProfileID("3")
	oBrowseTip:DisableConfig()
	oBrowseTip:DisableDetails()
	oBrowseTip:SetMenuDef("")
	oBrowseTip:SetFilterDefault("GFEC001LTP()")
	oBrowseTip:Activate()
	
	//
	// Classificações de Frete das Negociações vigentes
	//
	oBrowseCla := FWMBrowse():New()
	oBrowseCla:SetOwner(oFolder:aDialogs[2])
	oBrowseCla:SetDescription("Classificações de Frete das Negociações Vigentes") 
	oBrowseCla:SetAlias("GUB")
	oBrowseCla:SetProfileID("2")
	oBrowseCla:DisableDetails()
	oBrowseCla:DisableConfig()
	oBrowseCla:SetMenuDef("")
	oBrowseCla:SetFilterDefault("GFEC001LCL()")
	oBrowseCla:Activate()
	
	//
	// Cidades atendidas pelo Transportador (quando o tipo de destino é região ou UF mostra as cidades relacionadas) 
 	// com quantidade de Entregas, data da última Entrega 
	//
	oBrowseCid := FWMBrowse():New()
	oBrowseCid:SetOwner(oWIN_RIGHT)
	oBrowseCid:SetDescription("Cidades") 
	oBrowseCid:SetAlias(cAliasCid)
	oBrowseCid:SetProfileID("2")
	oBrowseCid:DisableDetails()
	oBrowseCid:SetMenuDef("")
	oBrowseCid:DisableConfig()
	
	For nCont := 1 To Len(aFieldsCid)
		oBrowseCid:AddColumn({aFieldsCid[nCont][1],&("{|| (cAliasCid)->" + aFieldsCid[nCont][2] + "}"),aFieldsCid[nCont][3],aFieldsCid[nCont][6],aFieldsCid[nCont][7],aFieldsCid[nCont][4],aFieldsCid[nCont][5],.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{} } )
	Next nCont
	
	oBrowseCid:Activate()
Return Nil

//
// Filtro browse Classificações de Frete
//
Function GFEC001LCL()
	Local aAreaAlias := (cAliasGV9)->(GetArea())
	Local aAreaGUB   := GUB->(GetArea())
	Local lRet := .F.
	
	dbSelectArea(cAliasGV9)
	(cAliasGV9)->(dbSetOrder(2))
	
	If (cAliasGV9)->(dbSeek(GUB->GUB_CDCLFR))
		lRet := .T.	
	EndIf
	
	RestArea(aAreaAlias)
	RestArea(aAreaGUB)
Return lRet

//
// Filtro browse Tipos de Operação
//
Function GFEC001LTP()
	Local aAreaAlias := (cAliasGV9)->(GetArea())
	Local aAreaGV4   := GV4->(GetArea())
	Local lRet := .F.
	
	dbSelectArea(cAliasGV9)
	(cAliasGV9)->(dbSetOrder(3))
	
	If (cAliasGV9)->(dbSeek(GV4->GV4_CDTPOP))
		lRet := .T.
	EndIf
	
	RestArea(aAreaAlias)
	RestArea(aAreaGV4)
Return lRet

//
// Chama a ViewDef das Negociações
//
Function GFEC001LVI()
	Local aAreaGV4   := GV4->(GetArea())
	Local aAreaGUB   := GUB->(GetArea())
	
	//
	// Variáveis utilizadas no programa GFEA061A.
	// Devem ser definidas para que a view funcione
	//
	Private cTB_CDEMIT
	Private cTB_NRTAB
	cTB_CDEMIT = (cAliasGV9)->GV9_CDEMIT
	cTB_NRTAB  = (cAliasGV9)->GV9_NRTAB
	GV9->(dbGoTo((cAliasGV9)->RECNO))
	FWExecView("Visualizar", "GFEA061A", 1,, {||.T.})	
	
	RestArea(aAreaGV4)
	RestArea(aAreaGUB)
Return Nil

Static Function CarregaDados(aFiltros,cBrwFiltro)
	Local cQuery := ''
	Local cTmp   := ''
	Default cBrwFiltro := ''
	
	dbSelectArea(cAliasGV9)
	ZAP
	dbSelectArea(cAliasCid)
	ZAP
	
	//
	// Retorna negociações vigentes do transportador para a data informada (Normal/Vínculo)
	// 
	cQuery += " SELECT GV9.GV9_CDEMIT, GV9.GV9_NRTAB, GV9.GV9_NRNEG, GV9.GV9_CDCLFR, GV9.GV9_CDTPOP, GV9.GV9_DTVALI, GV9.GV9_DTVALF, GV9.GV9_TPLOTA, GV9.GV9_DTCRIA, GV9.GV9_HRCRIA, GV9.R_E_C_N_O_ GV9_RECNO "
	cQuery += "   FROM " + RetSQLName("GV9") + " GV9 "
	cQuery += "  INNER JOIN (SELECT GV9.GV9_FILIAL, GV9.GV9_CDEMIT, GV9.GV9_NRTAB, GV9.GV9_NRNEG, MAX(GV9_DTVALI) GV9_DTVALI "
	cQuery += " 			   FROM " + RetSQLName("GVA") + " GVA "
	cQuery += " 			  INNER JOIN " + RetSQLName("GV9") + " GV9 ON GV9.GV9_FILIAL = GVA.GVA_FILIAL "
	cQuery += " 			                       AND ((GVA.GVA_TPTAB = '1' AND "
	cQuery += " 			                             GV9.GV9_CDEMIT = GVA.GVA_CDEMIT  "
	cQuery += " 			                             AND GV9.GV9_NRTAB  = GVA.GVA_NRTAB) OR "
	cQuery += " 			                            (GVA.GVA_TPTAB = '2' AND  "
	cQuery += " 			                             GV9.GV9_CDEMIT = GVA.GVA_EMIVIN AND  "
	cQuery += " 			                             GV9.GV9_NRTAB  = GVA.GVA_TABVIN)) "
	cQuery += " 			 WHERE GVA.GVA_CDEMIT = '" + cCodEmit + "' "
	cQuery += " 			   AND GV9.GV9_DTVALI <= '" + DtoS(dDataNeg) + "' "
	cQuery += " 			   AND (GV9.GV9_DTVALF = '' OR GV9.GV9_DTVALF >= '" + DtoS(dDataNeg) + "') "
	cQuery += " 			   AND GVA.D_E_L_E_T_ = ' ' "
	cQuery += " 			   AND GV9.D_E_L_E_T_ = ' ' "
	cQuery += " 			 GROUP BY GV9_FILIAL, GV9_CDEMIT, GV9_NRTAB, GV9_NRNEG ) GV92 ON GV9.GV9_FILIAL = GV92.GV9_FILIAL "
	cQuery += " 			                                                             AND GV9.GV9_CDEMIT = GV92.GV9_CDEMIT "
	cQuery += " 			                                                             AND GV9.GV9_NRTAB  = GV92.GV9_NRTAB "
	cQuery += " 			                                                             AND GV9.GV9_NRNEG  = GV92.GV9_NRNEG "
	cQuery += " 			                                                             AND GV9.GV9_DTVALI = GV92.GV9_DTVALI "
	cQuery += "  WHERE GV9.D_E_L_E_T_ = ' ' "
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	While (cTmp)->(!Eof())
		RecLock(cAliasGV9, .T.)
		(cAliasGV9)->GV9_CDEMIT  := (cTmp)->GV9_CDEMIT
		(cAliasGV9)->GV9_NMEMIT  := Posicione("GU3",1,xFilial("GU3")+(cTmp)->GV9_CDEMIT,"GU3_NMEMIT")
		(cAliasGV9)->GV9_NRTAB   := (cTmp)->GV9_NRTAB
		(cAliasGV9)->GV9_DSTAB   := POSICIONE("GVA",1,XFILIAL("GVA")+(cTmp)->GV9_CDEMIT+(cTmp)->GV9_NRTAB,"GVA_DSTAB")    
		(cAliasGV9)->GV9_NRNEG   := (cTmp)->GV9_NRNEG
		(cAliasGV9)->GV9_CDCLFR   := (cTmp)->GV9_CDCLFR
		(cAliasGV9)->GV9_DSCLFR   := POSICIONE("GUB",1,XFILIAL("GUB")+(cTmp)->GV9_CDCLFR,"GUB_DSCLFR")		
		(cAliasGV9)->GV9_CDTPOP   := (cTmp)->GV9_CDTPOP
		(cAliasGV9)->GV9_DSTPOP   := POSICIONE("GV4",1,XFILIAL("GV4")+(cTmp)->GV9_CDTPOP,"GV4_DSTPOP")
		(cAliasGV9)->GV9_DTVALI  := SToD((cTmp)->GV9_DTVALI)
		(cAliasGV9)->GV9_DTVALF  := SToD((cTmp)->GV9_DTVALF)
		(cAliasGV9)->GV9_TPLOTA  := (cTmp)->GV9_TPLOTA
		(cAliasGV9)->GV9_DTCRIA  := SToD((cTmp)->GV9_DTCRIA)
		(cAliasGV9)->GV9_HRCRIA  := (cTmp)->GV9_HRCRIA
		(cAliasGV9)->RECNO  	 := (cTmp)->GV9_RECNO		
		MsUnlock()
		(cTmp)->(dbSkip())
	EndDo
	
	(cTmp)->(dbCloseArea())
	
	
	//
	// Retorna as cidades atendidas pelo Transportador, quantidade de entregas na cidade e data da última entrega
	//
	cQuery := ""
	cQuery += "SELECT DISTINCT GU7_CDUF, "
	cQuery += "       GU7.GU7_NMCID, "
	cQuery += "       GWU.QTD, "
	cQuery += "       GWU.GWU_DTENT "
	cQuery += "  FROM " + RetSQLName("GV9") + " GV9 "
	cQuery += " INNER JOIN (SELECT GV9.GV9_CDEMIT, GV9.GV9_NRTAB, GV9.GV9_NRNEG, MAX(GV9_DTVALI) GV9_DTVALI "
	cQuery += "			   FROM " + RetSQLName("GVA") + " GVA "
	cQuery += "			  INNER JOIN " + RetSQLName("GV9") + " GV9 ON GV9.GV9_FILIAL = GVA.GVA_FILIAL "
	cQuery += "			                       AND ((GVA.GVA_TPTAB = '1' AND "
	cQuery += "			                             GV9.GV9_CDEMIT = GVA.GVA_CDEMIT "
	cQuery += "			                             AND GV9.GV9_NRTAB  = GVA.GVA_NRTAB) OR "
	cQuery += "			                            (GVA.GVA_TPTAB = '2' AND "
	cQuery += "			                             GV9.GV9_CDEMIT = GVA.GVA_EMIVIN AND " 
	cQuery += "			                             GV9.GV9_NRTAB  = GVA.GVA_TABVIN)) "
	cQuery += "			 WHERE GVA.GVA_CDEMIT = '" + cCodEmit + "' "
	cQuery += "			   AND GV9.GV9_DTVALI <= '" + DtoS(dDataNeg) + "' "
	cQuery += "			   AND (GV9.GV9_DTVALF = '' OR GV9.GV9_DTVALF >= '" + DtoS(dDataNeg) + "') "
	cQuery += "			   AND GVA.D_E_L_E_T_ = ' ' "
	cQuery += "			   AND GV9.D_E_L_E_T_ = ' ' "
	cQuery += "			 GROUP BY GV9_CDEMIT, GV9_NRTAB, GV9_NRNEG ) GV92 ON GV9.GV9_CDEMIT = GV92.GV9_CDEMIT "
	cQuery += "			                                                             AND GV9.GV9_NRTAB  = GV92.GV9_NRTAB "
	cQuery += "			                                                             AND GV9.GV9_NRNEG  = GV92.GV9_NRNEG "
	cQuery += "			                                                             AND GV9.GV9_DTVALI = GV92.GV9_DTVALI "
	cQuery += " INNER JOIN " + RetSQLName("GV8") + " GV8 ON GV8.GV8_CDEMIT = GV9.GV9_CDEMIT "
	cQuery += "                      AND GV8.GV8_NRTAB  = GV9.GV9_NRTAB "
	cQuery += "                      AND GV8.GV8_NRNEG  = GV9.GV9_NRNEG "
	cQuery += "                      AND GV8.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN " + RetSQLName("GUA") + " GUA ON GUA.GUA_NRREG  = GV8.GV8_NRREDS  "
	cQuery += "  				      AND GUA.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSQLName("GU7") + " GU7 ON ((GV8.GV8_TPDEST = '1' AND GU7.GU7_NRCID = GV8.GV8_NRCIDS) OR "
	cQuery += " 			  		      (GV8.GV8_TPDEST = '4' AND GU7.GU7_CDUF = GV8.GV8_CDUFDS) OR "
	cQuery += " 			  		      (GV8.GV8_TPDEST = '3' AND GU7.GU7_NRCID = GUA.GUA_NRCID)) "
	cQuery += " 			  		  AND GU7.D_E_L_E_T_ = ' ' "
	cQuery += "  LEFT JOIN (SELECT GWU_NRCIDD, GWU_CDTRP, COUNT(*) QTD, MAX(GWU_DTENT) GWU_DTENT   "
	cQuery += "               FROM " + RetSQLName("GWU")
	cQuery += "  			  WHERE D_E_L_E_T_ = ' ' "
	cQuery += "  			    AND GWU_DTENT != '' "
	cQuery += "  			  GROUP BY GWU_NRCIDD, GWU_CDTRP) GWU ON GWU.GWU_CDTRP  = GV9.GV9_CDEMIT "
	cQuery += "  			    				   				 AND GWU.GWU_NRCIDD = GU7.GU7_NRCID " 
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	While (cTmp)->(!Eof())
		RecLock(cAliasCid, .T.)
		(cAliasCid)->GU7_CDUF   := (cTmp)->GU7_CDUF
		(cAliasCid)->GU7_NMCID  := (cTmp)->GU7_NMCID
		(cAliasCid)->QTD         := (cTmp)->QTD
		(cAliasCid)->GWU_DTENT  := SToD((cTmp)->GWU_DTENT)   
		MsUnlock()
		(cTmp)->(dbSkip())
	EndDo
	(cTmp)->(dbCloseArea())
	
Return Nil

Static Function CriaTab(aFields, aIndices)
	Local cAlias
	Local nCont
	Local aStruct := {}
	               
	For nCont := 1 to Len(aFields)
		aADD(aStruct,{aFields[nCont][2],;  //Nome do campo
						aFields[nCont][3],;  //Tipo
						aFields[nCont][4],;  //Tamanho
						aFields[nCont][5]}) //Decimal
	Next nCont
	
	aADD(aStruct,{"RECNO",;  //Nome do campo
						"N",;  //Tipo
						15,;  //Tamanho
						0}) //Decimal
	
	cAlias := GFECriaTab({aStruct,aIndices})
Return cAlias
