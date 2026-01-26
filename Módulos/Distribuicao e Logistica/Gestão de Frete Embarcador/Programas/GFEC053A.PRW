#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
//---------------------------------------------------------------------------------------------------
/*/GFEC053A
Monitor de Carregamentos 
- MenuDef Browse GW1 do GFEC053 
- Lista de Destinos e Lista de Destinatários dos Documentos de Carga do Romaneio 

@sample
GFEC053A()

@author Alan Victor Lamb
@since 08/07/13
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------

Function GFEC053A()
	/*
	Listar Destinos (mostrar tela com lista de Cidades [nome e UF] e lista de 
	Destinatários dos Documentos de Carga do Romaneio [Código,Nome , Cidade e UF]) 
	*/
	Local aCoors := FWGetDialogSize(oMainWnd)
	Local aIndGU3, aIndGU7
	
	Private oFWLayer, oPanelUp, oPanelDown
	Private oBrowseGU3, oBrowseGU7
	Private oDlg
	Private aFieldsGU3, aFieldsGU7
	Private cAliasGU3, cAliasGU7
	Private cNrRom, cFilRom
	
	cNrRom := GWN->GWN_NRROM
	cFilRom := GWN->GWN_FILIAL
	
	If Empty(cNrRom) .OR. Empty(cFilRom)
		Return
	EndIf
	
	Define MsDialog oDlg Title 'Destinos dos Romaneios' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .T.)
	
	oFWLayer:AddLine('UP',50,.F.)
	oFWLayer:AddLine('DOWN',50,.F.)
	oFWLayer:AddCollumn('ALL',100,.T.,'UP')
	oFWLayer:AddCollumn('ALL',100,.T.,'DOWN')
	
	oPanelUp   := oFWLayer:GetColPanel('ALL','UP')
	oPanelDown := oFWLayer:GetColPanel('ALL','DOWN')
	
	aFieldsGU3 := { ;
	{"Cod Dest	 "   ,"GU3_CDEMIT","C",TamSX3("GU3_CDEMIT")[1],0,,1,10,.T.},;
	{"Destinatário","GU3_NMEMIT","C",TamSX3("GU3_NMEMIT")[1],0,,1,25,.T.},;	
	{"Cidade"	     ,"GU7_NMCID","C",TamSX3("GU7_NMCID")[1],0,,1,25,.T.},;
	{"UF" 		     ,"GU7_CDUF","C",2,0,,1,2,.T.};
	}
	
	aIndGU3 := {"GU3_CDEMIT+GU3_NMEMIT"}
	cAliasGU3 := CriaTab(aFieldsGU3, aIndGU3)
	
	aFieldsGU7 := { ;
	{"Cidade"	 ,"GU7_NMCID","C",TamSX3("GU7_NMCID")[1],0,,1,35,.T.},;
	{"UF" 		 ,"GU7_CDUF","C",2,0,,1,2,.T.};
	}
	
	aIndGU7 := {"GU7_CDUF+GU7_NMCID"}
	cAliasGU7 := CriaTab(aFieldsGU7, aIndGU7)
	
	CarregaDados()
	
	//
	// Destinos
	//
	oBrowseGU7:= FWMBrowse():New()
	oBrowseGU7:SetOwner(oPanelUp)
	oBrowseGU7:SetDescription('Destinos do Romaneio')
	oBrowseGU7:DisableDetails()
	oBrowseGU7:SetAlias(cAliasGU7)
	oBrowseGU7:SetMenuDef('')
	oBrowseGU7:SetProfileID('1')
	oBrowseGU7:AddButton("Sair",{|| oDLG:End()},,1)
	oBrowseGU7:SetAmbiente(.F.)
	oBrowseGU7:SetWalkthru(.F.)
	oBrowseGU7:SetFields(GetFields(aFieldsGU7, "cAliasGU7"))
	oBrowseGU7:Activate()
	
	//
	// Destinatários
	//
	oBrowseGU3:= FWMBrowse():New()
	oBrowseGU3:SetOwner(oPanelDown)
	oBrowseGU3:SetDescription('Destinatários dos Doc Carga')
	oBrowseGU3:DisableDetails()
	oBrowseGU3:SetAlias(cAliasGU3)
	oBrowseGU3:SetMenuDef('')
	oBrowseGU3:SetAmbiente(.F.)
	oBrowseGU3:SetWalkthru(.F.)
	oBrowseGU3:SetProfileID('2')
	oBrowseGU3:SetFields(GetFields(aFieldsGU3, "cAliasGU3"))
	oBrowseGU3:Activate()
	
	oDlg:Activate(,,,.T.,,,)
	
	GFEDelTab(cAliasGU3)
	GFEDelTab(cAliasGU7)
Return Nil

Static Function MenuDef()
	Local aRotina  := {}
	ADD OPTION aRotina TITLE "Consultar Doc Carga" 			ACTION "GFEC053OPT(9)" 	    	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Consultar Destinatário" 		ACTION "GFEC053OPT(10)" 	    	OPERATION 3 ACCESS 0
Return aRotina

Static Function CarregaDados()
	Local cQuery := ""
	Local cTmp   := ""
	
	//
	// Destinos do romaneio
	//
	cQuery += "	SELECT DISTINCT GU7.GU7_NMCID, GU7.GU7_CDUF "
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	 INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3.D_E_L_E_T_ = ''"
	cQuery += "	                      AND GU3.GU3_FILIAL = ''"
	cQuery += "	                      AND GU3.GU3_CDEMIT = GW1.GW1_CDDEST"
	cQuery += "	 INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7.D_E_L_E_T_ = ''"
	cQuery += "	 				  	  AND GU7.GU7_FILIAL = ''"
	cQuery += "	 				  	  AND GU7.GU7_NRCID  = GU3.GU3_NRCID"
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += "	   AND GW1.GW1_NRROM  = '"+cNrRom+"'"
	cQuery += "	   AND GW1.GW1_FILIAL = '"+cFilRom+"'"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasGU7,.T.)
			(cAliasGU7)->GU7_NMCID := (cTmp)->GU7_NMCID
			(cAliasGU7)->GU7_CDUF  := (cTmp)->GU7_CDUF
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
	
	//
	// Destinatários dos docs do romaneio
	//
	cQuery := ""
	cQuery += "	SELECT DISTINCT GU3.GU3_CDEMIT, GU3.GU3_NMEMIT, GU7.GU7_NMCID, GU7.GU7_CDUF"
	cQuery += "	  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	 INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3.D_E_L_E_T_ = ''"
	cQuery += "	                      AND GU3.GU3_FILIAL = ''"
	cQuery += "	                      AND GU3.GU3_CDEMIT = GW1.GW1_CDDEST"
	cQuery += "	 INNER JOIN " + RetSQLName("GU7") + " GU7 ON GU7.D_E_L_E_T_ = ''"
	cQuery += "	 				  	  AND GU7.GU7_FILIAL = ''"
	cQuery += "	 				  	  AND GU7.GU7_NRCID  = GU3.GU3_NRCID"
	cQuery += "	 WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += "	   AND GW1.GW1_NRROM  = '"+cNrRom+"'"
	cQuery += "	   AND GW1.GW1_FILIAL = '"+cFilRom+"'"
	
	cTmp := GetNextAlias()
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cTmp,.F.,.T.)
	dbSelectArea(cTmp)
	(cTmp)->(dbGoTop())
	If (cTmp)->(Recno()) > 0
		While (cTmp)->(!Eof())
			RecLock(cAliasGU3,.T.)
			(cAliasGU3)->GU3_CDEMIT := (cTmp)->GU3_CDEMIT
			(cAliasGU3)->GU3_NMEMIT := (cTmp)->GU3_NMEMIT
			(cAliasGU3)->GU7_NMCID  := (cTmp)->GU7_NMCID
			(cAliasGU3)->GU7_CDUF   := (cTmp)->GU7_CDUF
			MsUnlock()
			
			(cTmp)->(dbSkip())
		EndDo
	EndIf
	(cTmp)->(dbCloseArea())
Return Nil

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