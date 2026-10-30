#INCLUDE 'PROTHEUS.CH'
#INCLUDE "DBINFO.CH"
 
//-------------------------------------------------------------------
/*{Protheus.doc} GFEA021B

Cria o vínculo entre as Região e regiões.
Baseado no GFEA021A
@author Siegklenes Rolland Beulke
@since 25/11/2016
@version 1.0
/*/
Function GFEA021B(oModel)
	Local nOpc	   := oModel:GetOperation()
	Local aSeeks   := {}
	Local aSeekRel := {}
	Local aPos
	Local oSize
	
	Private aGU9View
	Private aGVRView
	Private aTTGVR
	Private aTTGU9
	Private cGVRTemp	:= DefGVRTemp()
	Private cGU9Temp	:= DefGU9Temp()
	Private cNrReg	:= oModel:GetValue("GFEA021_GU9","GU9_NRREG")
	Private aDtMod := {}
	
	Static oDlgCid
	
	If nOpc != 4 .And. nOpc != 3
		Help(,,'HELP',,"Esta ação não está disponível durante a visualização ou exclusão de um registro",1,0)	
		Return .F.
	EndIf
	
	If oModel:GetValue("GFEA021_GU9","GU9_DEMCID") == "1"
		Help(,,'HELP',,"Não é possível relacionar regiões quando o campo Demais Cidades está igual a Sim.",1,0)	
		Return .F.
	EndIf
	
	aNewButton := {}
	
	GVRLoad(cNrReg)
	GFEA21BRR(oModel)
	GU9Load()
	
		/*Array do SetSeek()
		  [n,1] Título da pesquisa
		  [n,2,1] LookUp
		  [n,2,2] Tipo de dados
		  [n,2,3] Tamanho
		  [n,2,4] Decimal
		  [n,2,5] Título do campo
		  [n,2,6] Máscara
		  [n,3] Ordem da pesquisa
		  [n,4] Exibe na pesquisa*/

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 470, 1200})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	DEFINE MSDIALOG oDlgCid TITLE "Relacionamento de Regiões" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							PIXEL
	//Array com as posições dinamicas se quiser alterar o tamnho da tela é so alterar o tamanho do SetWindowSize
	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
            oSize:GetDimension("ENCHOICE","COLINI"),;
            oSize:GetDimension("ENCHOICE","XSIZE"),;
            oSize:GetDimension("ENCHOICE","YSIZE")}

	/* -- Layers -- */
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgCid, .F., .T.)
	
	// Cidades
	oFWLayer:AddLine('TOP', 87, .T.)
	oFWLayer:AddCollumn('Espaco1', 1, .T., 'TOP') 
	oFWLayer:AddCollumn('REGIAO', 65, .T., 'TOP') //Cidade 
	oFWLayer:AddCollumn('Espaco2', 2, .T., 'TOP')
	oFWLayer:AddCollumn('REGIAOREL', 31, .T., 'TOP') // Cidade Relacionada
	oLayerCid := oFWLayer:GetColPanel('REGIAO', 'TOP')
	oLayerCidRel := oFWLayer:GetColPanel('REGIAOREL', 'TOP')
	
	oMark := FWMBrowse():New()
	oMark:SetOwner(oLayerCid)
	oMark:SetDescription("Regiões")
	oMark:SetTemporary(.T.)
	oMark:SetAlias(cGU9Temp)
	oMark:SetFields(aGU9View)
//	oMark:SetSeek(.T., aSeeks)
	oMark:ForceQuitButton(.F.)
	oMark:SetAmbiente(.F.)
	oMark:SetWalkthru(.F.)
	oMark:DisableReport()
	oMark:DisableSaveConfig()
	oMark:DisableConfig()
	oMark:GetFilterDefault()
	oMark:DisableDetails()
	oMark:SetMenuDef("")
	oMark:SetDoubleClick({|| GFERELREG()})
	oMark:AddButton('Relacionar',{|| GFERELREG()},,2,,.F.)
	oMark:AddButton('Filtrar',{|| GFEFILREG()},,2,,.F.)
	oMark:AddButton('Relacionar Todos',{|| GFEA21BLMK()},,2,,.F.)
    oMark:Activate() 
   
    oMarkCR := FWMBrowse():New()
	oMarkCR:SetOwner(oLayerCidRel)
	oMarkCR:SetDescription("Regiões Relacionadas")
	oMarkCR:SetTemporary(.T.)
	oMarkCR:SetAlias(cGVRTemp)
	oMarkCR:SetFields(aGVRView)
	oMarkCR:ForceQuitButton(.F.)
//	oMarkCR:SetSeek(.T., aSeekRel)
	oMarkCR:SetAmbiente(.F.)
	oMarkCR:SetWalkthru(.F.)
	oMarkCR:DisableReport()
	oMarkCR:DisableSaveConfig()
	oMarkCR:DisableConfig()
	oMarkCR:DisableDetails()
	oMarkCR:GetFilterDefault()
	oMarkCR:SetMenuDef("")
	oMarkCR:SetDoubleClick({|| GFEREMREG()})
	oMarkCR:AddButton('Remover',{|| GFEREMREG()},,2,,.F.)
	oMarkCR:AddButton('Remover Todos',{|| GFEA21BDLMK()},,2,,.F.)
    oMarkCR:Activate() 
    
    oMarkCR:Refresh()
    oMarkCR:GoTop()
    oMarkCR:Refresh()
  
  ACTIVATE MSDIALOG oDlgCid ON INIT EnchoiceBar(oDlgCid,{||If(GFEA21BCFCD(oModel),oDlgCid:End(),NIL)},{||oDlgCid:End()},,aNewButton) CENTERED 
	
	GFEDelTab(cGVRTemp)
	GFEDelTab(cGU9Temp)
	aSize(aDtMod,0)
Return


/*Monta a estrutura da tabela temporária de cidades relacionadas*/
Function DefGVRTemp()

	aTTGVR :=  {{"NRREG"  , "C", 06, 0},;
			    {"NMREG"  , "C", 50, 0},;
			    {"CDUF"   , "C", 02, 0},;
			    {"CDPAIS" , "C", 03, 0},;
			    {"NMPAIS" , "C", 50, 0},;
			    {"SIGLA"  , "C", 05, 0}}
			  
Return GFECriaTab({aTTGVR, {"NRREG", "NMREG+NRREG" , "CDUF+NRREG" , "SIGLA+NRREG"}})

/*Monta a estrutura da tabela temporária de cidades*/
Function DefGU9Temp()

	aTTGU9 :=  aClone(aTTGVR)
	
Return GFECriaTab({aTTGU9, {"NRREG", "NMREG+NRREG" , "CDUF+NRREG" , "SIGLA+NRREG"}})

/*Carrega as informações da tabela de região.*/
Function GU9Load()
	
	dbSelectArea(cGU9Temp)
	(cGU9Temp)->( dbSetorder(1) )
	ZAP
	
	aGU9View :=  aClone(aGVRView)
	
	cQuery := "SELECT GU9.GU9_NRREG NRREG, GU9.GU9_NMREG NMREG, GU9.GU9_CDUF CDUF, "
	cQuery += "GU9.GU9_CDPAIS CDPAIS, SYA.YA_DESCR, GU9.GU9_SIGLA SIGLA "
	cQuery += "FROM " + RetSQLName("GU9") + " GU9 "
	cQuery += "LEFT JOIN " + RetSQLName("SYA") + " SYA ON "
	cQuery += "SYA.YA_FILIAL = '" + xFilial("SYA") + "' AND "
	cQuery += "GU9.GU9_CDPAIS = SYA.YA_CODGI "
	cQuery += "LEFT JOIN " + RetSQLName("GVR") + " GVR ON "
	cQuery += "GU9.GU9_FILIAL = '" + xFilial("GU9") + "' AND "
	cQuery += "GVR.GVR_FILIAL = '" + xFilial("GVR") + "' AND "
	cQuery += "GU9.GU9_NRREG = GVR.GVR_NRREG AND "
	cQuery += "GVR.D_E_L_E_T_ = ' '"
	cQuery += "WHERE GU9.D_E_L_E_T_ = ' ' "
	cQuery += "AND GVR.GVR_NRREG IS NULL " // Não entra região agrupadora
	cQuery += "AND GU9.GU9_SIT='1' "
	cQuery += "AND GU9.GU9_DEMCID='2' "
	cQuery += "AND GU9.GU9_NRREG NOT " + GetInSql(aDtMod)

	SqlToTrb(cQuery, aTTGU9, cGU9Temp)
	
Return .T.

/*Carrega as informações para a tabela de Regiões relacionadas.*/
Function GVRLOAD(cNrReg)

	Default cNrReg := ""

//	dbSelectArea(cGVRTemp)
//	(cGVRTemp)->( dbSetorder(2) )
//	ZAP

	aGVRView :=  {{"Nr. Região"	    , "NRREG" 		, "C", 06, 0, "999999"},;
				  {"Nome Região"	, "NMREG" 		, "C", 50, 0, "!@"},;
				  {"UF"				, "CDUF" 		, "C", 02, 0, "!@"},;
				  {"País"			, "CDPAIS"		, "C", 03, 0, "!@"},;
				  {"Nome País"		, "NMPAIS" 		, "C", 50, 0, "!@"},;
				  {"Sigla"			, "SIGLA" 		, "C", 05, 0, "!@"}}
	
//	cQuery := "SELECT GU9.GU9_NRREG NRREG, GU9.GU9_NMREG NMREG, GU9.GU9_CDUF CDUF, "
//	cQuery += "GU9.GU9_CDPAIS CDPAIS, SYA.YA_DESCR GU9.GU9_SIGLA SIGLA"
//	cQuery += "FROM " + RetSQLName("GU9") + " GU9 "
//	cQuery += "INNER JOIN " + RetSQLName("GVR") + " GVR ON "
//	cQuery += "(GU9.GU9_FILIAL = '" + xFilial("GU 9") + "') AND "
//	cQuery += "(GVR.GVR_FILIAL = '" + xFilial("GVR") + "') AND "
//	cQuery += "(GU9.GU7_NRREG = GVR.GVR_NRREG) "
//	cQuery += "WHERE GVR.D_E_L_E_T_ = ' ' AND GU9.D_E_L_E_T_ = ' ' "
//	If !Empty(cNrReg)
//		cQuery += "AND GVR.GVR_NRREG = " + PadR(cNrReg, TamSX3("GVR_NRREG")[1])
//	EndIf
//	
//	SqlToTrb(cQuery, aTTGVR, cGVRTemp) 

Return .T.

/*Função que passa o registro da tabela de cidade para a tabela de cidade relacionada.*/
Function GFERELREG()

	If Empty((cGU9Temp)->NRREG)
		Return .F.
	EndIf
	
	dbSelectArea(cGVRTemp)
	(cGVRTemp)->( dbSetOrder(1) )
	If (cGVRTemp)->( dbSeek((cGU9Temp)->NRREG) )
		Alert("Não é possível vincular uma região que já está vinculada.")
		Return .F.
	EndIf
	dbSelectArea(cGU9Temp)
	RecLock(cGVRTemp, .T.)
		(cGVRTemp)->NRREG  := (cGU9Temp)->NRREG 
	  	(cGVRTemp)->NMREG  := (cGU9Temp)->NMREG 
	  	(cGVRTemp)->CDUF   := (cGU9Temp)->CDUF  
	  	(cGVRTemp)->CDPAIS := (cGU9Temp)->CDPAIS
	  	(cGVRTemp)->NMPAIS := (cGU9Temp)->NMPAIS
	  	(cGVRTemp)->SIGLA  := (cGU9Temp)->SIGLA 
	MsUnlock(cGVRTemp)
		
	RecLock(cGU9Temp, .F.)
		(cGU9Temp)->( dbDelete() )
	MsUnlock(cGU9Temp)
	
	oMark:Refresh()
	oMarkCR:Refresh()
	//oMark:GoTop()
	oMark:GoUp()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMarkCR:ChangeTopBot(.T.)
	oMarkCR:Refresh()
	oMark:ChangeTopBot(.T.)
	oMark:Refresh()

Return

/*Função que chama o pergunte e recarrega as informações da tabela de cidade.*/
Function GFEFILREG()

	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()

Return

/*Função que relaciona todas as Regiões do browse.*/
Function GFEA21BLMK()

	oMark:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	
	dbSelectArea(cGU9Temp)
	(cGU9Temp)->( dbGoTop() )
	While !(cGU9Temp)->( EOF() )
			dbSelectArea(cGVRTemp)
			(cGVRTemp)->( dbSetOrder(1) )
			If (cGVRTemp)->( dbSeek((cGU9Temp)->NRREG) )
				Alert("Não é possível vincular uma região que já está vinculada.")
				Return .F.
			EndIf
			dbSelectArea(cGVRTemp)
			RecLock(cGVRTemp, .T.)
				(cGVRTemp)->NRREG  := (cGU9Temp)->NRREG 
			  	(cGVRTemp)->NMREG  := (cGU9Temp)->NMREG 
			  	(cGVRTemp)->CDUF   := (cGU9Temp)->CDUF  
			  	(cGVRTemp)->CDPAIS := (cGU9Temp)->CDPAIS
			  	(cGVRTemp)->NMPAIS := (cGU9Temp)->NMPAIS
			  	(cGVRTemp)->SIGLA  := (cGU9Temp)->SIGLA 
			MsUnlock(cGVRTemp)
	(cGU9Temp)->( dbSkip() )
	EndDo
	
	(cGU9Temp)->( dbGoTop() )
	While !(cGU9Temp)->( Eof() )
		RecLock(cGU9Temp, .F.)
			(cGU9Temp)->( dbDelete() )
		MsUnlock(cGU9Temp)
		(cGU9Temp)->( dbSkip() )
	EndDo
	
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:UpdateBrowse()
    oMark:Refresh(.T.)
    oMarkCR:UpdateBrowse()
    oMarkCR:Refresh(.T.)
Return

/*Função para remover uma Regiçao do relacionamento.*/
Function GFEREMREG()

	Local aAreaAnt := (cGU9Temp)->( GetArea() )	
	
	If Vazio((cGVRTemp)->NRREG)
		Return .F.
	EndIf
		
	dbSelectArea(cGU9Temp)
	(cGU9Temp)->( dbSetOrder(1) )
	If (cGU9Temp)->( dbSeek((cGVRTemp)->NRREG) )
		RecLock(cGU9Temp, .F.)
			(cGU9Temp)->( dbDelete() )
		MsUnlock(cGU9Temp)
	EndIf
	RestArea(aAreaAnt)	
	
	dbSelectArea(cGU9Temp)
	RecLock(cGU9Temp, .T.)
		(cGU9Temp)->NRREG  := (cGVRTemp)->NRREG 
	  	(cGU9Temp)->NMREG  := (cGVRTemp)->NMREG 
	  	(cGU9Temp)->CDUF   := (cGVRTemp)->CDUF  
	  	(cGU9Temp)->CDPAIS := (cGVRTemp)->CDPAIS
	  	(cGU9Temp)->NMPAIS := (cGVRTemp)->NMPAIS
	  	(cGU9Temp)->SIGLA  := (cGVRTemp)->SIGLA 
	MsUnlock(cGU9Temp)
	
	dbSelectArea(cGVRTemp)
	RecLock(cGVRTemp, .F.)
		(cGVRTemp)->( dbDelete() )
	MsUnlock(cGVRTemp)
	
//	GU9Load()
	
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	//oMarkCR:GoTop()
	oMarkCR:GoUp()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMarkCR:ChangeTopBot(.T.)
	oMarkCR:Refresh()
	oMark:ChangeTopBot(.T.)
	oMark:Refresh()

Return

/*Função que remove o relacionamento de todas as cidades.*/
Function GFEA21BDLMK()
	
	oMark:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	
	dbSelectArea(cGVRTemp)
	(cGVRTemp)->( dbGoTop() )
	While !(cGVRTemp)->( EOF() )
			dbSelectArea(cGU9Temp)
			RecLock(cGU9Temp, .T.)
				(cGU9Temp)->NRREG  := (cGVRTemp)->NRREG 
			  	(cGU9Temp)->NMREG  := (cGVRTemp)->NMREG 
			  	(cGU9Temp)->CDUF   := (cGVRTemp)->CDUF  
			  	(cGU9Temp)->CDPAIS := (cGVRTemp)->CDPAIS
			  	(cGU9Temp)->NMPAIS := (cGVRTemp)->NMPAIS
			  	(cGU9Temp)->SIGLA  := (cGVRTemp)->SIGLA 
			MsUnlock(cGU9Temp)
	(cGVRTemp)->( dbSkip() )
	EndDo
	
	(cGVRTemp)->( dbGoTop() )
	While !(cGVRTemp)->( Eof() )
		RecLock(cGVRTemp, .F.)
			(cGVRTemp)->( dbDelete() )
		MsUnlock(cGVRTemp)
		(cGVRTemp)->( dbSkip() )
	EndDo

//	GU9Load()

	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:UpdateBrowse()
    oMark:Refresh(.T.)
    oMarkCR:UpdateBrowse()
    oMarkCR:Refresh(.T.)
	
Return

/*Função que adiciona o conteudo da tabela temporária para a tabela GUA, pelo Model.*/
Function GFEA21BCFCD(oModel)

	Local oModelGVR  := oModel:GetModel("GFEA021_GVR")
	Local lFirst := .T.
	Local nI

	If (oModelGVR:Length() > 1 .Or. !oModelGVR:IsEmpty())
		For nI := 1 To oModelGVR:Length()
			oModelGVR:GoLine(nI)
			oModelGVR:DeleteLine()
		Next nI
	EndIf
	
	dbSelectArea(cGVRTemp)
	(cGVRTemp)->( dbGoTop() )
	While !(cGVRTemp)->( Eof() )
		If lFirst .And. oModelGVR:Length() == 1 .And. !oModelGVR:IsDeleted()
			lFirst := .F.
			oModelGVR:GoLine(1)
		Else
			lFirst := .F.
			oModelGVR:AddLine()
		EndIf
		oModelGVR:LoadValue("GVR_NRREGR",(cGVRTemp)->NRREG)
		oModelGVR:LoadValue("GVR_NMREGR",(cGVRTemp)->NMREG)	
	(cGVRTemp)->( dbSkip() )
	EndDo

Return .T.

/*Função que carrega as Regiões relacionadas. Mesmo que ainda não tenha sido salvo.*/
Function GFEA21BRR(oModel)

	Local oModelGVR  := oModel:GetModel("GFEA021_GVR")
	Local nI
	
	dbSelectArea(cGVRTemp)
		(cGVRTemp)->( dbSetorder(1) )
	ZAP
	
	aGVRView :=  {{"Nr. Região"	    , "NRREG" 		, "C", 06, 0, "999999"},;
				  {"Nome Região"	, "NMREG" 		, "C", 50, 0, "!@"},;
				  {"UF"				, "CDUF" 		, "C", 02, 0, "!@"},;
				  {"País"			, "CDPAIS"		, "C", 03, 0, "!@"},;
				  {"Nome País"		, "NMPAIS" 		, "C", 50, 0, "!@"},;
				  {"Sigla"			, "SIGLA" 		, "C", 05, 0, "!@"}}
	
	For nI := 1 To oModelGVR:Length()
		oModelGVR:GoLine(nI)
		If !oModelGVR:IsDeleted() .And. !Empty(oModelGVR:GetValue("GVR_NRREGR"))
			dbSelectArea(cGVRTemp)
			RecLock(cGVRTemp, .T.)
					(cGVRTemp)->NRREG	:= oModelGVR:GetValue("GVR_NRREGR")
				  	(cGVRTemp)->NMREG	:= oModelGVR:GetValue("GVR_NMREGR")
				  	(cGVRTemp)->CDUF	:= Posicione("GU9", 1, xFilial("GU9")+oModelGVR:GetValue("GVR_NRREGR"), "GU9_CDUF")
				  	(cGVRTemp)->CDPAIS	:= GU9->GU9_CDPAIS
				  	(cGVRTemp)->NMPAIS	:= Posicione("SYA", 1, xFilial("SYA")+GU9->GU9_CDPAIS, "YA_DESCR")
				  	(cGVRTemp)->SIGLA	:= GU9->GU9_SIGLA
			MsUnlock(cGVRTemp)
			aAdd(aDtMod,(cGVRTemp)->NRREG)
		EndIf
	Next nI
	If aScan(aDtMod,{|x|x == cNrReg}) == 0
		aAdd(aDtMod,cNrReg)
	EndIf

Return

Static Function GetInSql(aData)
	Local cIn := "IN ("
	Local nX
	
	For nX := 1 To Len(aData)
		cIn += "'" + AllTrim(aData[nX]) + "'" + ','
	Next nX
	
	cIn := SubStr(cIn,1,Len(cIn)-1)
	cIn += ")"
Return cIn
