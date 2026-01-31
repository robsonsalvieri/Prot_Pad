#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/{Protheus.doc} GFEC020
	 
@author siegklenes.beulke
@since 08/07/2013
@version 1.0
		
@description 
	Consulta de Cidades, Mostrando ao visualizar as regiões, Clientes, 
Fornecedores e Transportadores Relacionados

/*/

Function GFEC020(lBrowse)
	Local oBrowse
	Private oBrowseGUA, oBrowseCli, oBrowseFor, oBrowseTrp
	Private cAliasGUA, cAliasCli, cAliasFor, cAliasTrp
	Default lBrowse := .T.
	if lBrowse
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("GU7")							// documentos de carga
		oBrowse:SetMenuDef("GFEC020")					// Nome do fonte onde esta a função MenuDef
		oBrowse:SetDescription("Consulta de Cidades")   	// Descrição do browse //"Alíquotas de ICMS"
		
		oBrowse:Activate()
	Else
		FWExecView(,"GFEC020",,,{|| .T.})
	EndIf
	
	GFEDelTab(cAliasGUA)
	GFEDelTab(cAliasCli)
	GFEDelTab(cAliasFor)
	GFEDelTab(cAliasTrp)
		
Return (Nil)

Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	AAdd(aRotina, {"Pesquisar"                , 'AxPesqui'       , 0, 1 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Visualizar"               , 'VIEWDEF.GFEC020', 0, 2 , 0, .F. /*Habilita Menu Funcional*/})
	AAdd(aRotina, {"Imprimir"                 , 'VIEWDEF.GFEC020', 0, 8 , 0, .F. /*Habilita Menu Funcional*/})
Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStructGU7 := FWFormStruct(1,"GU7") //Cidades
	Local oStructGXM := FWFormStruct(1,"GXM") //ISS outros serviços
	
	// cID     Identificador do modelo ad
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New("GFEC020", /*bPre*/, /*bPost*/, /*bCommit*/,)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição

	oModel:AddFields("GFEC020_GU7",Nil,oStructGU7)
	oModel:AddGrid("GFEA020_GXM","GFEC020_GU7",oStructGXM)
	oModel:SetRelation( 'GFEA020_GXM', { { 'GXM_FILIAL', 'xFilial("GXM")' }, { 'GXM_NRCID','GU7_NRCID' } }, GXM->( IndexKey( 1 ) ) )
	oModel:SetPrimaryKey({"GU7_FILIAL","GU7_NRCID"})
	oModel:GetModel("GFEA020_GXM"):SetDelAllLine(.T.)
	oModel:SetOptional("GFEA020_GXM", .T. )
	oModel:GetModel("GFEA020_GXM"):SetUniqueLine({"GXM_CDTIPO"})
	
Return oModel

Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oModel := FWLoadModel("GFEC020")
	Local oStructGU7 := FWFormStruct(2,"GU7") //Cidades
	Local oStructGXM := FWFormStruct(2,"GXM") //ISS outros serviços	
		
	oView:SetModel(oModel)
	oView:AddField("GFEC020_GU7", oStructGU7)
	oView:AddGrid( "GFEA020_GXM" , oStructGXM, 'GFEA020_GXM' )
	
	oView:CreateHorizontalBox("MESTRE",30)
	oView:CreateHorizontalBox("DETALHE",70)
	
	oView:CreateFolder("SHEET01","DETALHE")
	oView:AddSheet("SHEET01","IDSHEET01", "Clientes")
	oView:AddSheet("SHEET01","IDSHEET02", "Fornecedores")
	oView:AddSheet("SHEET01","IDSHEET03", "Transportadores")
	oView:AddSheet("SHEET01","IDSHEET04", "Regiões")
	oView:AddSheet("SHEET01","IDSHEET05", "%ISS Outros Serviços")
	
	oView:CreateHorizontalBox( "SHEETCLI",100,,,"SHEET01","IDSHEET01")//Clientes
	oView:CreateHorizontalBox( "SHEETFOR",100,,,"SHEET01","IDSHEET02")//Fornecedores
	oView:CreateHorizontalBox( "SHEETTRP",100,,,"SHEET01","IDSHEET03")//Transportadores
	oView:CreateHorizontalBox( "SHEETREG",100,,,"SHEET01","IDSHEET04")//Regiões
	oView:CreateHorizontalBox( "SHEETISS",100,,,"SHEET01","IDSHEET05")//%ISS Outros Serviços
	
	oView:AddOtherObject("GFEC020_GUA", {|oPanel, oObj| GFEC020GUA(oPanel, oObj)},,{|oPanel| oBrowseGUA:Refresh()})
	
	oView:AddOtherObject("GFEC020_CLI", {|oPanel, oObj| GFEC020BRW(oPanel, oObj,  "Clientes", { { "Visualizar","GFEC020VW('2')",,2,0 } },@oBrowseCli,"2" ) },,;
							{|oPanel| oBrowseCli:Refresh()})
	oView:AddOtherObject("GFEC020_FOR", {|oPanel, oObj| GFEC020BRW(oPanel, oObj, "Fornecedores", { { "Visualizar","GFEC020VW('3')",,2,0 } },@oBrowseFor,"3" ) },,;
							{|oPanel| oBrowseFor:Refresh()})
	oView:AddOtherObject("GFEC020_TRP", {|oPanel, oObj| GFEC020BRW(oPanel, oObj,  "Transportadores", { { "Visualizar","GFEC020VW('4')",,2,0 } },@oBrowseTrp,"4" ) },,;
							{|oPanel| oBrowseTrp:Refresh()})

	oView:SetOwnerView("GFEC020_GU7","MESTRE")
	oView:SetOwnerView("GFEC020_GUA", "SHEETREG")
	oView:SetOwnerView("GFEC020_CLI", "SHEETCLI")
	oView:SetOwnerView("GFEC020_FOR", "SHEETFOR")
	oView:SetOwnerView("GFEC020_TRP", "SHEETTRP")
	oView:SetOwnerView("GFEA020_GXM", "SHEETISS")
	
Return oView

Static Function CriaTabBrw()
	Local cQuery := ''
	Local aArea := GetArea()
	Local cAliasRegCid  := GetNextAlias()
	Local aStructTb, aHeaderTb
	If !Empty(Select(cAliasGUA))
		GFEDelTab(cAliasGUA)
	EndIf
	aStructTb := {	   {"GU9_NRREG","C",TamSX3("GU9_NRREG" )[1],TamSX3("GU9_NRREG" )[2]},;
					   {"GU9_NMREG","C",TamSX3("GU9_NMREG" )[1],TamSX3("GU9_NMREG" )[2]}}
	aHeaderTb := {;
					{"Código","GU9_NRREG","C",TamSX3("GU9_NRREG" )[1],TamSX3("GU9_NRREG" )[2],},;
					{"Região","GU9_NMREG","C",TamSX3("GU9_NMREG" )[1],TamSX3("GU9_NMREG" )[2],};
					}
	
	cAliasGUA := GFECriaTab({aStructTb, {"GU9_NRREG"}})
	
	cQuery += "SELECT"
	cQuery += "	GU9_NRREG, GU9_NMREG"
	cQuery += "	FROM " + RetSQLName("GU9") + " GU9 INNER JOIN " + RetSQLName("GUA") + " GUA ON GU9_NRREG = GUA_NRREG"
	cQuery += "	AND GU9_FILIAL = GUA_FILIAL"
	cQuery += "	WHERE GU9.D_E_L_E_T_ =  ' ' AND GUA.D_E_L_E_T_ =  ' ' AND GU9_FILIAL = '" + xFilial("GU9") + "' AND GUA_NRCID = '" + GU7->GU7_NRCID + "'" 
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasRegCid, .F., .T.)
	dbSelectArea((cAliasRegCid))
	(cAliasRegCid)->( dbGoTop() )
		
	While !(cAliasRegCid)->( Eof() )
		RecLock((cAliasGUA), .T.)
		(cAliasGUA)->GU9_NRREG := (cAliasRegCid)->GU9_NRREG
		(cAliasGUA)->GU9_NMREG := (cAliasRegCid)->GU9_NMREG
		MsUnlock((cAliasGUA))
		(cAliasRegCid)->(dbskip())
	Enddo
	(cAliasGUA)->( dbGoTop() )
	(cAliasRegCid)->( dbCloseArea() )
	
	RestArea(aArea)
Return {cAliasGUA,aHeaderTb}

Static Function GFEC020GUA(oPanel,oObj)
	Local aCfgBrw := CriaTabBrw() 
	
	oBrowseGUA := FWMBrowse():New()
	oBrowseGUA:SetDescription("Regiões") 
	oBrowseGUA:SetTemporary(.T.)
	oBrowseGUA:DisableDetails()
	oBrowseGUA:SetAlias(aCfgBrw[1])
	oBrowseGUA:SetFields(aCfgBrw[2])
	oBrowseGUA:SetProfileID("1")
	oBrowseGUA:SetMenuDef("")
	oBrowseGUA:AddButton("Visualizar","GFEC020VW('1')",,2,0) 
	oBrowseGUA:SetOwner(oPanel)
	oBrowseGUA:Activate()
Return Nil

Static Function GFEC020BRW(oPanel,oObj,cDescricao,aButtons,oBrowse,cProfId)
	Local  nCount
	Local aCfgBrw
	
	Default aButtons:={}
	/*aButtons
		[1] - < cTitle >
		[2] - < xAction >Ação do botão, podendo ser uma função ou Code-Block
		[3] - < uParam1 >Reservado
		[4] - < nOption >Tipo de operação (1=Visualizar, 2=Visualizar, 3=Incluir, 4=Alterar, 5=Excluir, 6=Alterar sem inclusão de novas linhas, 7=Cópia e 8=Impressão da regra de negócios)
		[5] - < nVerify >Posição a ser validada no acesso de usuário
	*/
	
	aCfgBrw := CriaBrwGu3(cProfId)
	oBrowse := FWMBrowse():New()
	oBrowse:SetTemporary(.T.)
	oBrowse:DisableDetails()
	oBrowse:SetAlias(aCfgBrw[1])
	oBrowse:SetFields(aCfgBrw[2])
	oBrowse:SetProfileID(cProfId)
	oBrowse:SetMenuDef("")
	For nCount := 1 to Len(aButtons)
		oBrowse:AddButton(aButtons[nCount][1],aButtons[nCount][2],aButtons[nCount][3],aButtons[nCount][4],aButtons[nCount][5])
	Next nCount
	oBrowse:SetOwner(oPanel)
	oBrowse:Activate()  
Return Nil

Static Function CriaBrwGu3(cProfId) //Cria struct e header básico para browse a partir do sx3
	Local aStructTb := {}, aHeaderTb := {}
	Local aArea,nX,nPos
	Local aStructGU3
	Local oStructX3	:= GFESeekSX():New()
	Local aCTamX3 := {{"GU3_NATUR",8,{{"J","Jurídica"},{"F","Física"},{"X","Outros"}}},; // Tamanhos para exibição de campos que sejam cbox
						{"GU3_ORIGEM",8,{{"1","Usuário"},{"2","ERP"},{"3","Outros"}}} ,;
						{"GU3_SIT",7},;
						{"GU3_EMFIL",3},;
						{"GU3_TRANSP",3},;
						{"GU3_CLIEN",3},;
						{"GU3_FORN",3},;
						{"GU3_AUTON",3}}

	aStructGU3 := FWFormStruct(3,'GU3')[1]
	For nX := 1 to Len(aStructGU3)
			If GetSx3Cache(aStructGU3[nX,3],"X3_BROWSE") == "S" .AND. GetSx3Cache(aStructGU3[nX,3],"X3_CONTEXT") == "R" .AND. GFEUSADO(aStructGU3[nX,3])
				
				oStructX3:SeekX3(aStructGU3[nX,3])
				nPos := aScan(aCTamX3,{|x| x[1] ==AllTrim(aStructGU3[nX,3])})
				aAdd(aStructTb,{AllTrim(aStructGU3[nX,3]), aStructGU3[nX,4], If(nPos>0,aCTamX3[nPos][2],oStructX3:getX3Tamanho()), oStructX3:getX3Decimal()})
				aAdd(aHeaderTb,{oStructX3:getX3Titulo(),AllTrim(aStructGU3[nX,3]), aStructGU3[nX,4], If(nPos>0,aCTamX3[nPos][2],oStructX3:getX3Tamanho()), oStructX3:getX3Decimal(),oStructX3:getX3Picture()})
			EndIf
	Next nX
	
	oStructX3:Destroy()

	Do Case
		Case cProfId == "2"
			cAliasCli := GFECriaTab({aStructTb, {"GU3_CDEMIT"}})
		Case cProfId == "3"
			cAliasFor := GFECriaTab({aStructTb, {"GU3_CDEMIT"}})
		Case cProfId == "4"
			cAliasTrp := GFECriaTab({aStructTb, {"GU3_CDEMIT"}})
	EndCase
	
	
	dbselectarea("GU3")
	aArea := GetArea()
	GU3->(dbSetOrder(7))
	GU3->(dbGoTop())
	If GU3->(DbSeek(xFilial("GU3") + GU7->GU7_NRCID))
		While GU3->GU3_FILIAL == xFilial("GU3") .And. GU3->GU3_NRCID == GU7->GU7_NRCID
				Do Case
				Case cProfId == "2" .And. GU3->GU3_FILIAL == xFilial("GU3") .And. GU3->GU3_NRCID == GU7->GU7_NRCID .And. GU3->GU3_CLIEN == '1'
					RecLock((cAliasCli),.T.)
					(cAliasCli)->GU3_CDEMIT := GU3->GU3_CDEMIT
					(cAliasCli)->GU3_NMEMIT := GU3->GU3_NMEMIT
					If GetSx3Cache("GU3_NMABRV","X3_BROWSE") == "S"
						(cAliasCli)->GU3_NMABRV := GU3->GU3_NMABRV
					EndIf
					(cAliasCli)->GU3_NATUR := aCTamX3[1][3][aScan(aCTamX3[1][3],{|x|x[1]==GU3->GU3_NATUR})][2]
					(cAliasCli)->GU3_CDGREM := GU3->GU3_CDGREM
					(cAliasCli)->GU3_ORIGEM := aCTamX3[2][3][aScan(aCTamX3[2][3],{|x|x[1]==GU3->GU3_ORIGEM})][2]
					(cAliasCli)->GU3_SIT := If(GU3->GU3_SIT=="1","Ativo","Inativo")
					(cAliasCli)->GU3_EMFIL := If(GU3->GU3_EMFIL=="1","Sim","Nao")
					(cAliasCli)->GU3_TRANSP := If(GU3->GU3_TRANSP=="1","Sim","Nao")
					(cAliasCli)->GU3_CLIEN := If(GU3->GU3_CLIEN=="1","Sim","Nao")
					(cAliasCli)->GU3_FORN := If(GU3->GU3_FORN=="1","Sim","Nao")
					(cAliasCli)->GU3_AUTON := If(GU3->GU3_AUTON=="1","Sim","Nao")
					(cAliasCli)->GU3_IDFED := GU3->GU3_IDFED
					MsUnlock((cAliasCli))
				Case cProfId == "3" .And. GU3->GU3_FILIAL == xFilial("GU3") .And. GU3->GU3_NRCID == GU7->GU7_NRCID .And. GU3->GU3_FORN == '1'
					RecLock((cAliasFor),.T.)
					(cAliasFor)->GU3_CDEMIT := GU3->GU3_CDEMIT
					(cAliasFor)->GU3_NMEMIT := GU3-> GU3_NMEMIT
					If GetSx3Cache("GU3_NMABRV","X3_BROWSE") == "S"
						(cAliasFor)->GU3_NMABRV := GU3-> GU3_NMABRV
					EndIf
					(cAliasFor)->GU3_NATUR := aCTamX3[1][3][aScan(aCTamX3[1][3],{|x|x[1]==GU3->GU3_NATUR})][2]
					(cAliasFor)->GU3_CDGREM := GU3->GU3_CDGREM
					(cAliasFor)->GU3_ORIGEM := aCTamX3[2][3][aScan(aCTamX3[2][3],{|x|x[1]==GU3->GU3_ORIGEM})][2]
					(cAliasFor)->GU3_SIT := If(GU3->GU3_SIT=="1","Ativo","Inativo")
					(cAliasFor)->GU3_EMFIL := If(GU3->GU3_EMFIL=="1","Sim","Nao")
					(cAliasFor)->GU3_TRANSP := If(GU3->GU3_TRANSP=="1","Sim","Nao")
					(cAliasFor)->GU3_CLIEN := If(GU3->GU3_CLIEN=="1","Sim","Nao")
					(cAliasFor)->GU3_FORN := If(GU3->GU3_FORN=="1","Sim","Nao")
					(cAliasFor)->GU3_AUTON := If(GU3->GU3_AUTON=="1","Sim","Nao")
					(cAliasFor)->GU3_IDFED := GU3-> GU3_IDFED
					MsUnlock((cAliasFor))
				Case cProfId == "4" .And. GU3->GU3_FILIAL == xFilial("GU3") .And. GU3->GU3_NRCID == GU7->GU7_NRCID .And. (GU3->GU3_TRANSP == '1' .Or. GU3->GU3_AUTON == '1')
					RecLock((cAliasTrp),.T.)
					(cAliasTrp)->GU3_CDEMIT := GU3->GU3_CDEMIT
					(cAliasTrp)->GU3_NMEMIT := GU3-> GU3_NMEMIT
					If GetSx3Cache("GU3_NMABRV","X3_BROWSE") == "S"
						(cAliasTrp)->GU3_NMABRV := GU3-> GU3_NMABRV
					EndIf
					(cAliasTrp)->GU3_NATUR := aCTamX3[1][3][aScan(aCTamX3[1][3],{|x|x[1]==GU3->GU3_NATUR})][2]
					(cAliasTrp)->GU3_CDGREM := GU3->GU3_CDGREM
					(cAliasTrp)->GU3_ORIGEM := aCTamX3[2][3][aScan(aCTamX3[2][3],{|x|x[1]==GU3->GU3_ORIGEM})][2]
					(cAliasTrp)->GU3_SIT := If(GU3->GU3_SIT=="1","Ativo","Inativo")
					(cAliasTrp)->GU3_EMFIL := If(GU3->GU3_EMFIL=="1","Sim","Nao")
					(cAliasTrp)->GU3_TRANSP := If(GU3->GU3_TRANSP=="1","Sim","Nao")
					(cAliasTrp)->GU3_CLIEN := If(GU3->GU3_CLIEN=="1","Sim","Nao")
					(cAliasTrp)->GU3_FORN := If(GU3->GU3_FORN=="1","Sim","Nao")
					(cAliasTrp)->GU3_AUTON := If(GU3->GU3_AUTON=="1","Sim","Nao")
					(cAliasTrp)->GU3_IDFED := GU3-> GU3_IDFED
					MsUnlock((cAliasTrp))
				EndCase
				
			GU3->(DbSkip())
		EndDo
	EndIf
	RestArea(aArea)
	Do Case
		Case cProfId == "2"
			Return {cAliasCli,aHeaderTb}
		Case cProfId == "3"
			Return {cAliasFor,aHeaderTb}
		Case cProfId == "4"
			Return {cAliasTrp,aHeaderTb}
	EndCase
Return {}


Function GFEC020VW(cProfId)
	Local aArea
	if cProfId $ "234" 
		aArea := GetArea("GU3")
		dbselectarea("GU3")
		GU3->(dbSetOrder(1))
		GU3->(dbGoTop())
	else
		aArea := GetArea("GU9")
		dbselectarea("GU9")
		GU9->(dbSetOrder(1))
		GU9->(dbGoTop())
	EndIf
	
	Do Case 
		Case cProfId == "1" .And. !(cAliasGUA)->(Eof())
			GU9->(DbSeek(xFilial("GU9")+(cAliasGUA)->GU9_NRREG))
			FWExecView(,"GFEA021C",,,{|| .T.})
		Case cProfId == "2" .And. !(cAliasCli)->(Eof())
			GU3->(DbSeek(xFilial("GU3")+(cAliasCli)->GU3_CDEMIT))
			FWExecView(,"GFEA015",,,{|| .T.})
		Case cProfId == "3" .And. !(cAliasFor)->(Eof())
			GU3->(DbSeek(xFilial("GU3")+(cAliasFor)->GU3_CDEMIT))
			FWExecView(,"GFEA015",,,{|| .T.})
		Case cProfId == "4" .And. !(cAliasTrp)->(Eof())
			GU3->(DbSeek(xFilial("GU3")+(cAliasTrp)->GU3_CDEMIT))
			FWExecView(,"GFEA015",,,{|| .T.})
	EndCase
	RestArea(aArea)
Return Nil 
