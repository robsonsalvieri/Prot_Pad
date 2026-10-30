#INCLUDE 'PROTHEUS.CH'
#INCLUDE "DBINFO.CH"

// [Gestão de Fontes] Teste acesso e usabilidade - Em chamado da 12.1.7, utilizar fontes da 12.1.7 e da 12.1.6
 
//-------------------------------------------------------------------
/*{Protheus.doc} GFEA021A

Cria o vínculo entre as cidades e a região.

@author Hercilio Henning Neto
@since 09/04/2014
@version 1.0
/*/
Function GFEA021A(oModel)

	Local cEstado  := oModel:GetValue("GFEA021_GU9","GU9_CDUF")
	Local cPais	   := oModel:GetValue("GFEA021_GU9","GU9_CDPAIS")
	//Carrega o pergunte sem mostrar em tela filtrando pelo estado e país
	//informados na tela.
	Local nOpc     := oModel:GetOperation()
	Local oSize
	Local aPos
	Local aSeeks   := {}
	Local aSeekRel := {}
	
	Private aGU7View
	Private aGUAView
	Private aTTGUA
	Private aTTGU7
	Private cGU7Temp	:= DefGU7Temp()
	Private cGUATemp	:= DefGUATemp()
	Private cNrReg	:= oModel:GetValue("GFEA021_GU9","GU9_NRREG")
	
	Static oDlgCid
	
	If nOpc != 4 .And. nOpc != 3
		Help(,,'HELP',,"Esta ação não está disponível durante a visualização ou exclusão de um registro",1,0)	
		Return .F.
	EndIf
	
	If oModel:GetValue("GFEA021_GU9","GU9_DEMCID") == "1"
		Help(,,'HELP',,"Não é possível relacionar cidades quando o campo Demais Cidades está igual a Sim.",1,0)	
		Return .F.
	EndIf
	
	aNewButton := {}
	
	SetMVValue("GFEA021","MV_PAR01",'')
	SetMVValue("GFEA021","MV_PAR02",'')
	SetMVValue("GFEA021","MV_PAR03",cEstado)
	SetMVValue("GFEA021","MV_PAR04",cPais)
	SetMVValue("GFEA021","MV_PAR05",'')
	SetMVValue("GFEA021","MV_PAR06",'')
	
	//Não mostra o pergunte em tela.
	Pergunte("GFEA021", .F.)
	
	GUALoad(cNrReg)
	GFEA21GVMO(oModel)
	GU7Load()
	
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

	/*aSeeks*/
	
	Aadd(aSeeks, {Alltrim(aGU7View[2][1])+'+'+Alltrim(aGU7View[3][1])+'+'+Alltrim(aGU7View[4][1]), ;
		{{'', aGU7View[2][3], aGU7View[2][4], aGU7View[2][5], aGU7View[2][1], Nil},;
		{'', aGU7View[3][3], aGU7View[3][4], aGU7View[3][5], aGU7View[3][1], Nil},;
		{'', aGU7View[4][3], aGU7View[4][4], aGU7View[4][5], aGU7View[4][1], Nil};
		}, 1 }) 
	
	Aadd(aSeeks, {Alltrim(aGU7View[1][1])+'+'+Alltrim(aGU7View[2][1])+'+'+Alltrim(aGU7View[3][1])+'+'+Alltrim(aGU7View[4][1]), ;
		{{'', aGU7View[1][3], aGU7View[1][4], aGU7View[1][5], aGU7View[1][1], Nil},; 
		{'', aGU7View[2][3], aGU7View[2][4], aGU7View[2][5], aGU7View[2][1], Nil},;
		{'', aGU7View[3][3], aGU7View[3][4], aGU7View[3][5], aGU7View[3][1], Nil},;
		{'', aGU7View[4][3], aGU7View[4][4], aGU7View[4][5], aGU7View[4][1], Nil};
		}, 2 }) 
		
	Aadd(aSeeks, {Alltrim(aGU7View[7][1])+'+'+Alltrim(aGU7View[8][1]), ;
		{{'', aGU7View[7][3], aGU7View[7][4], aGU7View[7][5], aGU7View[7][1], Nil},;
		{'', aGU7View[8][3], aGU7View[8][4], aGU7View[8][5], aGU7View[8][1], Nil};
		}, 3 }) 
		
	/*aSeekRel*/
	
	Aadd(aSeekRel, {Alltrim(aGU7View[2][1])+'+'+Alltrim(aGU7View[3][1])+'+'+Alltrim(aGU7View[4][1]), ;
		{{'', aGU7View[2][3], aGU7View[2][4], aGU7View[2][5], aGU7View[2][1], Nil},;
		{'', aGU7View[3][3], aGU7View[3][4], aGU7View[3][5], aGU7View[3][1], Nil},;
		{'', aGU7View[4][3], aGU7View[4][4], aGU7View[4][5], aGU7View[4][1], Nil};
		}, 1 }) 
	
	Aadd(aSeekRel, {Alltrim(aGU7View[1][1])+'+'+Alltrim(aGU7View[2][1])+'+'+Alltrim(aGU7View[3][1])+'+'+Alltrim(aGU7View[4][1]), ;
		{{'', aGU7View[1][3], aGU7View[1][4], aGU7View[1][5], aGU7View[1][1], Nil},; 
		{'', aGU7View[2][3], aGU7View[2][4], aGU7View[2][5], aGU7View[2][1], Nil},;
		{'', aGU7View[3][3], aGU7View[3][4], aGU7View[3][5], aGU7View[3][1], Nil},;
		{'', aGU7View[4][3], aGU7View[4][4], aGU7View[4][5], aGU7View[4][1], Nil};
		}, 2 }) 
		
	Aadd(aSeekRel, {Alltrim(aGU7View[7][1])+'+'+Alltrim(aGU7View[8][1]), ;
		{{'', aGU7View[7][3], aGU7View[7][4], aGU7View[7][5], aGU7View[7][1], Nil},;
		{'', aGU7View[8][3], aGU7View[8][4], aGU7View[8][5], aGU7View[8][1], Nil};
		}, 3 }) 
		
			
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 100, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 470, 1200})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	DEFINE MSDIALOG oDlgCid TITLE "Relacionamento de Cidades" ;
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
	oFWLayer:AddCollumn('CIDADE', 65, .T., 'TOP') //Cidade 
	oFWLayer:AddCollumn('Espaco2', 2, .T., 'TOP')
	oFWLayer:AddCollumn('CIDADEREL', 31, .T., 'TOP') // Cidade Relacionada
	oLayerCid := oFWLayer:GetColPanel('CIDADE', 'TOP')
	oLayerCidRel := oFWLayer:GetColPanel('CIDADEREL', 'TOP')
	
	oMark := FWMBrowse():New()
	oMark:SetOwner(oLayerCid)
	oMark:SetDescription("Cidades")
	oMark:SetTemporary(.T.)
	oMark:SetAlias(cGU7Temp)
	oMark:SetFields(aGU7View)
	oMark:SetSeek(.T., aSeeks)
	oMark:ForceQuitButton(.F.)
	oMark:SetAmbiente(.F.)
	oMark:SetWalkthru(.F.)
	oMark:DisableReport()
	oMark:DisableSaveConfig()
	oMark:DisableConfig()
	oMark:GetFilterDefault()
	oMark:DisableDetails()
	oMark:SetMenuDef("")
	oMark:SetDoubleClick({|| GFERELCID()})
	oMark:AddButton('Relacionar',{|| GFERELCID()},,2,,.F.)
	oMark:AddButton('Filtrar',{|| GFEFILCID()},,2,,.F.)
	oMark:AddButton('Relacionar Todos',{|| GFEA21ALMK()},,2,,.F.)
    oMark:Activate() 
   
    oMarkCR := FWMBrowse():New()
	oMarkCR:SetOwner(oLayerCidRel)
	oMarkCR:SetDescription("Cidades Relacionadas")
	oMarkCR:SetTemporary(.T.)
	oMarkCR:SetAlias(cGUATemp)
	oMarkCR:SetFields(aGUAView)
	oMarkCR:ForceQuitButton(.F.)
	oMarkCR:SetSeek(.T., aSeekRel)
	oMarkCR:SetAmbiente(.F.)
	oMarkCR:SetWalkthru(.F.)
	oMarkCR:DisableReport()
	oMarkCR:DisableSaveConfig()
	oMarkCR:DisableConfig()
	oMarkCR:DisableDetails()
	oMarkCR:GetFilterDefault()
	oMarkCR:SetMenuDef("")
	oMarkCR:SetDoubleClick({|| GFEREMCID()})
	oMarkCR:AddButton('Remover',{|| GFEREMCID()},,2,,.F.)
	oMarkCR:AddButton('Remover Todos',{|| GFEA21DLMK()},,2,,.F.)
    oMarkCR:Activate() 
    
    GFEA21GVMO(oModel)
    oMarkCR:Refresh()
    oMarkCR:GoTop()
    oMarkCR:Refresh()
  
  ACTIVATE MSDIALOG oDlgCid ON INIT EnchoiceBar(oDlgCid,{||If(GFEA21CFCD(oModel),oDlgCid:End(),NIL)},{||oDlgCid:End()},,aNewButton) CENTERED 
	
	GFEDelTab(cGUATemp)
	GFEDelTab(cGU7Temp)

Return

/*Monta a estrutura da tabela temporária de cidades*/
Function DefGU7Temp()

	aTTGU7 :=  {{"NRCID" , "C", 07, 0},;
			  {"NMCID" , "C", 50, 0},;
			  {"CDUF" , "C", 02, 0},;
			  {"CDPAIS" , "C", 03, 0},;
			  {"SIGLA" , "C", 05, 0},;
			  {"SUFRAMA" , "C", 01, 0},;
			  {"CEPINI" , "C", 08, 0},;
			  {"CEPFIM" , "C", 08, 0}}
	
Return GFECriaTab({aTTGU7, {"NMCID+CDUF+CDPAIS", "NRCID+NMCID+CDUF+CDPAIS" , "CEPINI+CEPFIM", "SIGLA"}})

/*Monta a estrutura da tabela temporária de cidades relacionadas*/
Function DefGUATemp()

	aTTGUA :=  {{"NRCID" , "C", 07, 0},;
			  {"NMCID" , "C", 50, 0},;
			  {"CDUF" , "C", 02, 0},;
			  {"CDPAIS" , "C", 03, 0},;
			  {"SIGLA" , "C", 05, 0},;
			  {"SUFRAMA" , "C", 01, 0},;
			  {"CEPINI" , "C", 08, 0},;
			  {"CEPFIM" , "C", 08, 0},;
			  {"REGIAO", "C", 06, 0}}

Return	GFECriaTab({aTTGUA, {"NMCID+CDUF+CDPAIS", "NRCID+NMCID+CDUF+CDPAIS" , "CEPINI+CEPFIM" , "SIGLA"}})

/*Carrega as informações da tabela de cidade.*/
Function GU7Load()
	
		dbSelectArea(cGU7Temp)
		(cGU7Temp)->( dbSetorder(2) )
		ZAP
		
		aGU7View :=  {{"Nr. Cidade"		, "NRCID" 		, "C", 07, 0, "9999999"},;
					  {"Nome Cidade"	, "NMCID" 		, "C", 50, 0, "!@"},;
					  {"UF"				, "CDUF" 		, "C", 02, 0, "!@"},;
					  {"País"			, "CDPAIS"		, "C", 03, 0, "!@"},;
					  {"Sigla"			, "SIGLA" 		, "C", 05, 0, "!@"},;
					  {"Suframa"		, "SUFRAMA"	, "C", 01, 0, "!@"},;
					  {"CEP Inicial"	, "CEPINI" 	, "C", 08, 0, "@R 99.999-999"},;
					  {"CEP Final"		, "CEPFIM" 	, "C", 08, 0, "@R 99.999-999"}}
	
	cQuery := "SELECT GU7.GU7_NRCID NRCID, GU7.GU7_NMCID NMCID, GU7.GU7_CDUF CDUF, "
	cQuery += "GU7.GU7_CDPAIS CDPAIS, GU7.GU7_SIGLA SIGLA, GU7.GU7_SUFRAM SUFRAMA, "
	cQuery += "GU7.GU7_CEPINI CEPINI, GU7.GU7_CEPFIM CEPFIM "
	cQuery += "FROM " + RetSQLName("GU7") + " GU7 "
	cQuery += "WHERE GU7.D_E_L_E_T_ = ' ' AND GU7.GU7_SIT = '1' "
	If !Empty(MV_PAR01)
		cQuery += "AND GU7.GU7_NRCID >= '" + MV_PAR01 + "' " 
	EndIf
	If !Empty(MV_PAR02)
		cQuery += "AND GU7.GU7_NRCID <= '" + MV_PAR02 + "' "
	EndIf
	If !Empty(MV_PAR03)
		cQuery += "AND GU7.GU7_CDUF = '" + MV_PAR03 + "' "
	EndIf
	If !Empty(MV_PAR04)
		cQuery += "AND GU7.GU7_CDPAIS = '" + MV_PAR04 + "' "
	EndIf
	If !Empty(MV_PAR05)
		cQuery += "AND GU7.GU7_CEPINI >= '" + MV_PAR05 + "' " 
	EndIf
	If !Empty(MV_PAR06)
		cQuery += " AND GU7.GU7_CEPFIM <= '" + MV_PAR06 + "' "
	EndIf

	SqlToTrb(cQuery, aTTGU7, cGU7Temp)
	
	dbSelectArea(cGUATemp)
	(cGUATemp)->( dbGoTop() )
	While !(cGUATemp)->( EOF() ) 
		dbSelectArea(cGU7Temp)
		(cGU7Temp)->( dbSetOrder(1) )
		If (cGU7Temp)->( dbSeek((cGUATemp)->NMCID+(cGUATemp)->CDUF+(cGUATemp)->CDPAIS) )
			RecLock(cGU7Temp, .F.)
				(cGU7Temp)->( dbDelete() )
			MsUnlock(cGU7Temp)	
		EndIf
	(cGUATemp)->( dbSkip() )
	EndDo
	
Return .T.

/*Carrega as informações para a tabela de cidades relacionadas.*/
Function GUALoad(cNrReg)

	Default cNrReg := ""

	dbSelectArea(cGUATemp)
	(cGUATemp)->( dbSetorder(2) )
	ZAP

		aGUAView :=  {{"Nr. Cidade"	, "NRCID" 		, "C", 07, 0, "9999999"},;
					  {"Nome Cidade"	, "NMCID" 		, "C", 50, 0, "!@"},;
					  {"UF"				, "CDUF" 		, "C", 02, 0, "!@"},;
					  {"País"			, "CDPAIS"		, "C", 03, 0, "!@"},;
					  {"Sigla"			, "SIGLA" 		, "C", 05, 0, "!@"},;
					  {"Suframa"		, "SUFRAMA"	, "C", 01, 0, "!@"},;
					  {"CEP Inicial"	, "CEPINI" 	, "C", 08, 0, "@R 99.999-999"},;
					  {"CEP Final"		, "CEPFIM" 	, "C", 08, 0, "@R 99.999-999"},;
					  {"Região"		, "REGIAO" 	, "C", TamSX3("GUA_NRREG")[1], 0, "!@"}}
	
	cQuery := "SELECT GU7.GU7_NRCID NRCID, GU7.GU7_NMCID NMCID, GU7.GU7_CDUF CDUF, "
	cQuery += "GU7.GU7_CDPAIS CDPAIS, GU7.GU7_SIGLA SIGLA, GU7.GU7_SUFRAM SUFRAMA, "
	cQuery += "GU7.GU7_CEPINI CEPINI, GU7.GU7_CEPFIM CEPFIM, GUA.GUA_NRREG REGIAO "
	cQuery += "FROM " + RetSQLName("GU7") + " GU7 "
	cQuery += "INNER JOIN " + RetSQLName("GUA") + " GUA ON (GU7.GU7_FILIAL = GUA.GUA_FILIAL) AND "
	cQuery += "(GU7.GU7_NRCID = GUA.GUA_NRCID) "
	cQuery += "WHERE GUA.D_E_L_E_T_ = ' ' AND GU7.D_E_L_E_T_ = ' ' AND GU7.GU7_SIT = '1' "
	If !Empty(cNrReg)
		cQuery += "AND GUA.GUA_NRREG = '" + PadR(cNrReg, TamSX3("GUA_NRREG")[1]) + "'"
	EndIf
	
	SqlToTrb(cQuery, aTTGUA, cGUATemp) 

Return .T.

/*Função que passa o registro da tabela de cidade para a tabela de cidade relacionada.*/
Function GFERELCID()

	If Vazio((cGU7Temp)->NRCID)
		Return .F.
	EndIf
	
	dbSelectArea(cGUATemp)
	(cGUATemp)->( dbSetOrder(2) )
	If (cGUATemp)->( dbSeek((cGU7Temp)->NRCID) )
		Alert("Não é possível vincular uma cidade que já está vinculada.")
		Return .F.
	EndIf
	dbSelectArea(cGU7Temp)
	RecLock(cGUATemp, .T.)
		(cGUATemp)->NRCID	:= (cGU7Temp)->NRCID	
	  	(cGUATemp)->NMCID	:= (cGU7Temp)->NMCID
	  	(cGUATemp)->CDUF	:= (cGU7Temp)->CDUF
	  	(cGUATemp)->CDPAIS	:= (cGU7Temp)->CDPAIS
	  	(cGUATemp)->SIGLA	:= (cGU7Temp)->SIGLA	
	  	(cGUATemp)->SUFRAMA	:= (cGU7Temp)->SUFRAMA
	  	(cGUATemp)->CEPINI	:= (cGU7Temp)->CEPINI
	  	(cGUATemp)->CEPFIM	:= (cGU7Temp)->CEPFIM
	  	(cGUATemp)->REGIAO	:= cNrReg
	MsUnlock(cGUATemp)
		
	RecLock(cGU7Temp, .F.)
		(cGU7Temp)->( dbDelete() )
	MsUnlock(cGU7Temp)
	
	oMark:Refresh()
	oMarkCR:Refresh()
	//oMark:GoTop()
	oMark:GoUp()	
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMarkCR:ChangeTopBot(.T.)
	oMarkCR:Refresh(.T.)
	oMarkCR:UpdateBrowse()
 
     
	
Return

/*Função que chama o pergunte e recarrega as informações da tabela de cidade.*/
Function GFEFILCID()

	Pergunte("GFEA021", .T.)
	GU7Load()

	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()

Return

/*Função que relaciona todas as cidades do browse.*/
Function GFEA21ALMK()

	oMark:GoTop()
	
	dbSelectArea(cGU7Temp)
	(cGU7Temp)->( dbGoTop() )
	While !(cGU7Temp)->( EOF() )
			dbSelectArea(cGUATemp)
			(cGUATemp)->( dbSetOrder(2) )
			If (cGUATemp)->( dbSeek((cGU7Temp)->NRCID) )
				Alert("Não é possível vincular uma cidade que já está vinculada.")
				Return .F.
			EndIf
			dbSelectArea(cGU7Temp)
			RecLock(cGUATemp, .T.)
				(cGUATemp)->NRCID		:= (cGU7Temp)->NRCID	
			  	(cGUATemp)->NMCID		:= (cGU7Temp)->NMCID
			  	(cGUATemp)->CDUF		:= (cGU7Temp)->CDUF
			  	(cGUATemp)->CDPAIS	:= (cGU7Temp)->CDPAIS
			  	(cGUATemp)->SIGLA		:= (cGU7Temp)->SIGLA	
			  	(cGUATemp)->SUFRAMA	:= (cGU7Temp)->SUFRAMA
			  	(cGUATemp)->CEPINI	:= (cGU7Temp)->CEPINI
			  	(cGUATemp)->CEPFIM	:= (cGU7Temp)->CEPFIM
			  	(cGUATemp)->REGIAO	:= cNrReg
			MsUnlock(cGUATemp)
	(cGU7Temp)->( dbSkip() )
	EndDo
	
	(cGU7Temp)->( dbGoTop() )
	While !(cGU7Temp)->( Eof() )
		RecLock(cGU7Temp, .F.)
			(cGU7Temp)->( dbDelete() )
		MsUnlock(cGU7Temp)
		(cGU7Temp)->( dbSkip() )
	EndDo
	
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()

Return

/*Função para remover uma cidade do relacionamento.*/
Function GFEREMCID()

	Local aAreaAnt := (cGU7Temp)->( GetArea() )	
	
	If Vazio((cGUATemp)->NRCID)
		Return .F.
	EndIf
		
	dbSelectArea(cGU7Temp)
	(cGU7Temp)->( dbSetOrder(2) )
	If (cGU7Temp)->( dbSeek((cGUATemp)->NRCID) )
		RecLock(cGUATemp, .F.)
			(cGUATemp)->( dbDelete() )
		MsUnlock(cGUATemp)
	EndIf
	RestArea(aAreaAnt)	
	
	dbSelectArea(cGU7Temp)
	RecLock(cGU7Temp, .T.)
		(cGU7Temp)->NRCID		:= (cGUATemp)->NRCID	
	  	(cGU7Temp)->NMCID		:= (cGUATemp)->NMCID
	  	(cGU7Temp)->CDUF		:= (cGUATemp)->CDUF
	  	(cGU7Temp)->CDPAIS	:= (cGUATemp)->CDPAIS
	  	(cGU7Temp)->SIGLA		:= (cGUATemp)->SIGLA	
	  	(cGU7Temp)->SUFRAMA	:= (cGUATemp)->SUFRAMA
	  	(cGU7Temp)->CEPINI	:= (cGUATemp)->CEPINI
	  	(cGU7Temp)->CEPFIM	:= (cGUATemp)->CEPFIM
	MsUnlock(cGUATemp)
	
	dbSelectArea(cGUATemp)
	RecLock(cGUATemp, .F.)
		(cGUATemp)->( dbDelete() )
	MsUnlock(cGUATemp)
	
	GU7Load()
	
	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoUp()
	oMark:Refresh()
	oMarkCR:Refresh()
	oMarkCR:ChangeTopBot(.T.)
	oMarkCR:Refresh(.T.)
	oMarkCR:UpdateBrowse()
	oMark:ChangeTopBot(.T.)
	oMark:Refresh(.T.)
	oMark:UpdateBrowse()

Return

/*Função que remove o relacionamento de todas as cidades.*/
Function GFEA21DLMK()
	
	oMark:GoTop()
	
	dbSelectArea(cGUATemp)
	(cGUATemp)->( dbGoTop() )
	While !(cGUATemp)->( EOF() )
			dbSelectArea(cGU7Temp)
			RecLock(cGU7Temp, .T.)
				(cGU7Temp)->NRCID	:= (cGUATemp)->NRCID	
			  	(cGU7Temp)->NMCID	:= (cGUATemp)->NMCID
			  	(cGU7Temp)->CDUF	:= (cGUATemp)->CDUF
			  	(cGU7Temp)->CDPAIS	:= (cGUATemp)->CDPAIS
			  	(cGU7Temp)->SIGLA	:= (cGUATemp)->SIGLA	
			  	(cGU7Temp)->SUFRAMA	:= (cGUATemp)->SUFRAMA
			  	(cGU7Temp)->CEPINI	:= (cGUATemp)->CEPINI
			  	(cGU7Temp)->CEPFIM	:= (cGUATemp)->CEPFIM
			MsUnlock(cGU7Temp)
	(cGUATemp)->( dbSkip() )
	EndDo
	
	(cGUATemp)->( dbGoTop() )
	While !(cGUATemp)->( Eof() )
		RecLock(cGUATemp, .F.)
			(cGUATemp)->( dbDelete() )
		MsUnlock(cGUATemp)
		(cGUATemp)->( dbSkip() )
	EndDo

	GU7Load()

	oMark:Refresh()
	oMarkCR:Refresh()
	oMark:GoTop()
	oMarkCR:GoTop()
	oMark:Refresh()
	oMarkCR:Refresh()
	
Return

/*Função que adiciona o conteudo da tabela temporária para a tabela GUA, pelo Model.*/
Function GFEA21CFCD(oModel)

	Local oModelGUA  := oModel:GetModel("GFEA021_GUA")
	Local nI
	Local nCount := (cGUATemp)->(recCount())
	Local lFirst := .T.
	
	(cGUATemp)->( dbGoTop() )
	While !(cGUATemp)->( Eof() )
		If !oModelGUA:SeekLine({{"GUA_NRCID", (cGUATemp)->NRCID}})
			If lFirst .And. oModelGUA:Length() == 1 .And. Empty(oModelGUA:GetValue("GUA_NRCID", 1))
				lFirst := .F.
				oModelGUA:GoLine(1)
			Else
				oModelGUA:AddLine()
			EndIf
			oModelGUA:SetValue("GUA_NRCID",(cGUATemp)->NRCID)
			oModelGUA:SetValue("GUA_NMCID",(cGUATemp)->NMCID)
		EndIf
		(cGUATemp)->( dbSkip() )
	EndDo
	
	For nI := 1 To oModelGUA:Length()
		(cGUATemp)->( dbSetOrder(2) )
		If !(cGUATemp)->( msSeek(oModelGUA:GetValue("GUA_NRCID", nI)) )
			oModelGUA:GoLine(nI)
			oModelGUA:DeleteLine()
		EndIf
	Next nI

Return .T.

/*Função que carrega as cidades relacionadas. Mesmo que ainda não tenha sido salvo.*/
Function GFEA21GVMO(oModel)

	Local oModelGUA  := oModel:GetModel("GFEA021_GUA")
	Local nI
	
	dbSelectArea(cGUATemp)
		(cGUATemp)->( dbSetorder(2) )
	ZAP
	
	For nI := 1 To oModelGUA:Length()
		oModelGUA:GoLine(nI)
		If !oModelGUA:IsDeleted() .And. !Vazio(oModelGUA:GetValue("GUA_NRCID"))
			dbSelectArea(cGUATemp)
			RecLock(cGUATemp, .T.)
					(cGUATemp)->NRCID		:= oModelGUA:GetValue("GUA_NRCID")
				  	(cGUATemp)->NMCID		:= oModelGUA:GetValue("GUA_NMCID")
				  	(cGUATemp)->CDUF		:= Posicione("GU7", 1, xFilial("GU7")+oModelGUA:GetValue("GUA_NRCID"), "GU7_CDUF")
				  	(cGUATemp)->CDPAIS	:= Posicione("GU7", 1, xFilial("GU7")+oModelGUA:GetValue("GUA_NRCID"), "GU7_CDPAIS")
				  	(cGUATemp)->SIGLA		:= Posicione("GU7", 1, xFilial("GU7")+oModelGUA:GetValue("GUA_NRCID"), "GU7_SIGLA")
				  	(cGUATemp)->SUFRAMA	:= Posicione("GU7", 1, xFilial("GU7")+oModelGUA:GetValue("GUA_NRCID"), "GU7_SUFRAM")
				  	(cGUATemp)->CEPINI	:= Posicione("GU7", 1, xFilial("GU7")+oModelGUA:GetValue("GUA_NRCID"), "GU7_CEPINI")
				  	(cGUATemp)->CEPFIM	:= Posicione("GU7", 1, xFilial("GU7")+oModelGUA:GetValue("GUA_NRCID"), "GU7_CEPFIM")
					(cGUATemp)->REGIAO	:= cNrReg
			MsUnlock(cGUATemp)
		EndIf
	Next nI	

Return
