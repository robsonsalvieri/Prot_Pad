#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA413.CH"

Static oBrwD0Z := Nil
Static oBrwD16 := Nil
Static oBrowse := Nil

#DEFINE WMSA41301 "WMSA41301"
#DEFINE WMSA41302 "WMSA41302"
#DEFINE WMSA41303 "WMSA41303"
#DEFINE WMSA41304 "WMSA41304"
#DEFINE WMSA41305 "WMSA41305"

//--------------------------------------------------
/*/{Protheus.doc} WMSA413
Monitor do Embarque de Expedição
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Function WMSA413()
Local nTime   := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)

	If Pergunte("WMSA413",.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("D0X")
		oBrowse:SetMenuDef("WMSA413")
		oBrowse:SetDescription(STR0001) // "Embarque de Expedição"
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:AddLegend("D0X_STATUS=='1'", "RED"   , STR0002) // "Não iniciado"
		oBrowse:AddLegend("D0X_STATUS=='2'", "YELLOW", STR0003) // "Em andamento"
		oBrowse:AddLegend("D0X_STATUS=='3'", "GREEN" , STR0004) // "Embarcado"
		oBrowse:SetParam({|| SelFiltro(oBrowse) }) // F12
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime <= 0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({|| oBrowse:oTimer:lActive := (MV_PAR06 < 4) })
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:DisableDetails()
		oBrowse:Activate()
	EndIf

Return

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0005 ACTION "WMS413Mtor()" OPERATION 2 ACCESS 0 // Monitor
	ADD OPTION aRotina TITLE STR0011 ACTION "WMS413ECof()" OPERATION 5 ACCESS 0 DISABLE MENU // Excluir
	
	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("WMS413MNU")
		ExecBlock("WMS413MNU",.F.,.F.)
	EndIf

Return aRotina

//--------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de dados
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function ModelDef()
Local oModel  := MPFormModel():New("WMSA413",/*{|oModel| BeforeCMdl(oModel) }*/,{|oModel| ValidMdl(oModel) },/*{|oModel| CommitMdl(oModel)}*/)
Local oStrD0X := FWFormStruct(1,"D0X")
Local oStrD0Z := FWFormStruct(1,"D0Z")
Local oStrD16 := FWFormStruct(1,"D16")
Local oStrD17 := FWFormStruct(1,"D17")
Local bStatusD0Z  := Nil

	// Legenda de status para os itens do embarque
	bStatusD0Z  := {||,Iif(D0Z->D0Z_STATUS=="1","BR_VERMELHO",Iif(D0Z->D0Z_STATUS=="2","BR_AMARELO","BR_VERDE"))}
	oStrD0Z:AddField("", "", "D0Z_VSTATUS", "C", 11, 0,,,,,bStatusD0Z,,,.T.)

	oModel:AddFields("A413D0X",,oStrD0X)

	oModel:AddGrid("A413D0Z","A413D0X",oStrD0Z)
	oModel:SetRelation("A413D0Z", { { "D0Z_FILIAL", "xFilial('D0Z')" }, { "D0Z_EMBARQ", "D0X_EMBARQ" } }, D0Z->(IndexKey(1)) )

	oModel:AddGrid("A413D16","A413D0X",oStrD16)
	oModel:SetRelation("A413D16", { { "D16_FILIAL", "xFilial('D16')" }, { "D16_EMBARQ", "D0X_EMBARQ" } }, D16->(IndexKey(1)) )

	oModel:AddGrid("A413D17","A413D0X",oStrD17)
	oModel:SetRelation("A413D17", { { "D17_FILIAL", "xFilial('D17')" }, { "D17_EMBARQ", "D0X_EMBARQ" } }, D17->(IndexKey(1)) )

Return oModel

//--------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da visualização de dados
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function ViewDef()
Local oModel  := ModelDef()
Local oView   := FWFormView():New()
Local oStrD0X := FWFormStruct(2,"D0X")
Local oStrD0Z := FWFormStruct(2,"D0Z")
Local oStrD16 := FWFormStruct(2,"D16")

	oStrD0X:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
	oStrD0Z:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
	oStrD16:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)

	oStrD0Z:AddField("D0Z_VSTATUS", "01","","", , "GET", "@BMP", Nil, /*cLookUp*/,.F., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) // Status de Embarque do Item
	oStrD0Z:RemoveField("D0Z_STATUS")

	oView:SetModel(oModel)
	oView:AddField("VIEWD0X", oStrD0X, "A413D0X")
	oView:AddGrid( "VIEWD0Z", oStrD0Z, "A413D0Z")
	oView:AddGrid( "VIEWD16", oStrD16, "A413D16")

	oView:CreateHorizontalBox( "SUPERIOR", 25 )
	oView:CreateHorizontalBox( "INFERIOR", 75 )

	oView:CreateFolder( "FOLDER", "INFERIOR")

	oView:AddSheet("FOLDER" ,"SHEET1", STR0006) // "Itens do Embarque"
	oView:AddSheet("FOLDER" ,"SHEET2", STR0007) // "Conferência do Embarque"

	oView:CreateHorizontalBox( "BOXD0Z", 100, /*owner*/, /*lUsePixel*/, "FOLDER", "SHEET1")
	oView:CreateHorizontalBox( "BOXD16", 100, /*owner*/, /*lUsePixel*/, "FOLDER", "SHEET2")

	oView:SetOwnerView("VIEWD0X", "SUPERIOR")
	oView:SetOwnerView("VIEWD0Z", "BOXD0Z"  )
	oView:SetOwnerView("VIEWD16", "BOXD16"  )
	
Return oView

//--------------------------------------------------
/*/{Protheus.doc} Filtro
Filto do browse principal
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function Filtro()
Local cFiltro := ""

	cFiltro :=     " D0X_EMBARQ >= '"+MV_PAR01+"'"
	cFiltro += " AND D0X_EMBARQ <= '"+MV_PAR02+"'"
	cFiltro += " AND D0X_DATGER >= '"+DtoS(MV_PAR03)+"'"
	cFiltro += " AND D0X_DATGER <= '"+DtoS(MV_PAR04)+"'"
	If MV_PAR05 < 4
		cFiltro += " AND D0X_STATUS = " + Str(MV_PAR05)
	EndIf

Return cFiltro

//--------------------------------------------------
/*/{Protheus.doc} SelFiltro
Regra de execução do filtro (tecla F12)
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function SelFiltro(oBrowse)

	If Pergunte("WMSA413",.T.)
		oBrowse:oTimer:lActive := (MV_PAR06 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf

Return

//--------------------------------------------------
/*/{Protheus.doc} RefreshBrw
Refresh do browse principal da rotina
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Static Function RefreshBrw(oBrowse)
Local nPos := oBrowse:At()

	If MV_PAR06 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR06 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} RefreshAll
Função responsável por efetuar a atualização da tela
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//----------------------------------------------------------
Static Function RefreshAll()

	oBrwD0Z:Refresh()
	oBrwD16:Refresh()

Return
//--------------------------------------------------
/*/{Protheus.doc} Monitor / WMS413Mtor
Monitor do Embarque de Expedição
@author  Guilherme A. Metzger
@since   22/02/2019
@version 1.0
/*/
//--------------------------------------------------
Function WMS413Mtor()
Local oSize      := Nil
Local oDlg       := Nil
Local oMaster    := Nil
Local oFolder    := Nil
Local aFolders   := {}
Local aButtons   := {}
Local aPosSize   := {}
Local nTime      := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oTimer     := Nil
Local nOpcA      := 0
Local lD0XTransp := D0X->(ColumnPos("D0X_TRANSP")) > 0

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 100, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0008 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL // "Monitor do Embarque de Expedição"

	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
	             oSize:GetDimension("MASTER","COLINI"),;
	             oSize:GetDimension("MASTER","LINEND"),;
	             oSize:GetDimension("MASTER","COLEND")}

	If lD0XTransp
		oMaster := MsMGet():New("D0X",D0X->(Recno()),2,,,,{'D0X_EMBARQ','D0X_STATUS','D0X_DATGER','D0X_HORGER','D0X_CODUSU','D0X_NOMUSU','D0X_TRANSP','D0X_NOMTRA'},aPosSize,,3,,,,oDlg)
	ELSE
		oMaster := MsMGet():New("D0X",D0X->(Recno()),2,,,,{'D0X_EMBARQ','D0X_STATUS','D0X_DATGER','D0X_HORGER','D0X_CODUSU','D0X_NOMUSU'},aPosSize,,3,,,,oDlg)
	EndIF

	aFolders := {STR0006,STR0007} // "Itens do Embarque" // "Conferência do Embarque"

	// Monta o Objeto Folder
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
	             oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
	             oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
	             oSize:GetDimension("DETAIL","YSIZE")}   // Size.y

	oFolder := TFolder():New(aPosSize[1],aPosSize[2],aFolders,aFolders,oDlg,,,,.T.,.T.,aPosSize[3],aPosSize[4])

	// Define Browse de Itens do Embarque
	oBrwD0Z := FWMBrowse():New()
	oBrwD0Z:SetOwner(oFolder:aDialogs[1])
	oBrwD0Z:SetDescription(STR0009) // "Itens do Embarque de Expedição"
	oBrwD0Z:SetAlias("D0Z")
	oBrwD0Z:SetFilterDefault("@ D0Z_FILIAL = '"+xFilial('D0Z')+"' AND D0Z_EMBARQ = '"+D0X->D0X_EMBARQ+"'")
	oBrwD0Z:SetMenuDef("")
	oBrwD0Z:AddLegend("D0Z_STATUS=='1'", "RED"   ,STR0002) // "Não iniciado"
	oBrwD0Z:AddLegend("D0Z_STATUS=='2'", "YELLOW",STR0003) // "Em andamento"
	oBrwD0Z:AddLegend("D0Z_STATUS=='3'", "GREEN" ,STR0004) // "Embarcado"
	oBrwD0Z:DisableDetails()
	oBrwD0Z:SetAmbiente(.F.)
	oBrwD0Z:SetWalkThru(.F.)
	oBrwD0Z:SetFixedBrowse(.T.)
	oBrwD0Z:SetProfileID("D0Z")
	oBrwD0Z:AddButton(STR0012, {|| oTimer:DeActivate(), EstornaItem(), oTimer:Activate()},, 4, 0) // Estornar Embarque Item
	oBrwD0Z:AddButton(STR0013, {|| oTimer:DeActivate(), ExcluiItem(), oTimer:Activate()},, 5, 0) // Excluir Embarque Item
	oBrwD0Z:Activate()

	// Define Browse da Conferência do Embarque
	oBrwD16 := FWMBrowse():New()
	oBrwD16:SetOwner(oFolder:aDialogs[2])
	oBrwD16:SetDescription(STR0010) // "Conferência do Embarque de Expedição"
	oBrwD16:SetAlias("D16")
	oBrwD16:SetFilterDefault("@ D16_FILIAL = '"+xFilial('D16')+"' AND D16_EMBARQ = '"+D0X->D0X_EMBARQ+"'")
	oBrwD16:SetMenuDef("")
	oBrwD16:SetAmbiente(.F.)
	oBrwD16:SetWalkThru(.F.)
	oBrwD16:DisableDetails()
	oBrwD16:SetFixedBrowse(.T.)
	oBrwD16:SetProfileID("D16")
	oBrwD16:AddButton(STR0014, {|| oTimer:DeActivate(), EstConfOpe(), oTimer:Activate()},, 4, 0) // Estornar Embarque Operador
	oBrwD16:Activate()

	AAdd(aButtons, {'ESTOR',{|| oTimer:DeActivate(), EstConfComp(), oTimer:Activate()}, STR0015}) // Estornar Embarque

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| RefreshAll() },oDlg)
	oTimer:Activate()
	
	If ExistBlock("WMS413BTN")
		aButtons := ExecBlock("WMS413BTN",.F.,.F., {} )              
    Endif	

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)

Return
//--------------------------------------------------
/*/{Protheus.doc} EstornaItem
Realiza estorno da quantidade embarcada.
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Static Function EstornaItem()
Local nRet := 0
	If !(D0Z->D0Z_STATUS == "1")
		WMS413Est(.T.) //Indica que é um processo de estorno

		Begin Transaction
			WmsUpdD00(5,D0Z->D0Z_EMBARQ,D0Z->D0Z_CARGA,D0Z->D0Z_PEDIDO,D0Z->D0Z_ITEM,D0Z->D0Z_SEQUEN,D0Z->D0Z_LOTECT)
			nRet := FWExecView(STR0016,'WMSA413A',4,,{ || .T. },,,,{ || .T. })// Estornar Item Embarque
			If nRet != 0
				Disarmtransaction()
			EndIf
		End Transaction
		RefreshGrids()
	EndIf
Return nRet
//--------------------------------------------------
/*/{Protheus.doc} ExcluiItem
Realiza a exclusão de um item do embarque
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Static Function ExcluiItem()
Local nRet := 0

	If ValExcItem()
		Begin Transaction
			WmsUpdD00(4,D0Z->D0Z_EMBARQ,D0Z->D0Z_CARGA,D0Z->D0Z_PEDIDO,D0Z->D0Z_ITEM,D0Z->D0Z_SEQUEN,D0Z->D0Z_LOTECT)
			nRet := FWExecView(STR0017,'WMSA413A',5,,{ || .T. },,,,{ || .T. })// Estornar Item Embarque
			If nRet != 0
				Disarmtransaction()
			EndIf
		End Transaction
		RefreshGrids()
	EndIf
Return nRet
//--------------------------------------------------
/*/{Protheus.doc} EstConfOpe
Realiza estorno da quantidade embarcada pelo operador
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Static Function EstConfOpe()
Local nRet := 0
	
	Begin Transaction
		WmsUpdD00(5,D16->D16_EMBARQ,D16->D16_CARGA,D16->D16_PEDIDO,D16->D16_ITEM,D16->D16_SEQUEN,D16->D16_LOTECT,D16->D16_NUMLOT,D16->D16_CODVOL)
		nRet := FWExecView(STR0018,'WMSA413B',4,,{ || .T. },,,,{ || .T. })// Estornar Embarque Operador
		If nRet != 0
			Disarmtransaction()
		EndIf
	End Transaction
	RefreshGrids()
Return nRet
//--------------------------------------------------
/*/{Protheus.doc} EstConfComp
Realiza estorno da quantidade embarcada de todos os itens do embarque
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Static Function EstConfComp()
Local lRet:= .T.
Local oEmbarque := Nil
	Begin Transaction
		If !(D0X->D0X_STATUS == "1") .And. WmsQuestion(STR0019) // Confirma o estorno de todo o processo de embarque?
			oEmbarque := WMSDTCEmbarqueExpedicao():New()
			oEmbarque:GoToD0X(D0X->(Recno()))
			If !(lRet := oEmbarque:EstEmbarque())
				WmsMessage(oEmbarque:GetErro(),WMSA41302,1)
			EndIf
			If lRet
				WmsUpdD00(3,oEmbarque:cEmbarque)
			EndIf
			FreeObj(oEmbarque)
			RefreshGrids()
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ExcConfEmb / WMS413ECof
Realiza a exclusão de todo o embarque e suas respectivas tabelas
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Function WMS413ECof()
Local lRet     := .T.

	If (D0X->D0X_STATUS == "1")
		If lRet .And. FWExecView(STR0020,'WMSA413',5,,{ || .T. },,,,{ || .T. }) == 0 // Exclusão
			oBrowse:Refresh(.T.)
		EndIf
	Else
		WmsMessage(STR0021+CRLF+STR0022,WMSA41301,1) // Exclusão permitida somente para embarque não iniciado! //  Estorne todo o processo de embarque, para então excluir o processo.
		lRet := .F.
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} ValidMdl
Valida a exclusão do embarque
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function ValidMdl(oModel)
Local lRet:= .T.
Local oEmbarque := WMSDTCEmbarqueExpedicao():New()

	oEmbarque:GoToD0X(D0X->(Recno()))
	If !(lRet := oEmbarque:CanExcEmb())
		oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSA41303,oEmbarque:GetErro())
	EndIf
	If lRet .And. oModel:GetOperation() ==  MODEL_OPERATION_DELETE
		If lRet
			WmsUpdD00(1,D0X->D0X_EMBARQ)
		EndIf
	EndIf
	FreeObj(oEmbarque)
Return lRet

//--------------------------------------------------
/*/{Protheus.doc} ValExcItem
Valida a exclusão do item do embarque
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Static Function ValExcItem()
Local lRet := .T.
Local nCountD0Z := 0
Local cAliasD0Z := ""

	If !(D0Z->D0Z_STATUS == "1")
		WmsMessage(STR0023+CRLF+STR0024,WMSA41305,1) // Exclusão permitida somente para itens com embarque não iniciado! // Estorne o processo de embarque do item, para então realizar a exclusão.
		lRet := .F.
	EndIf

	If lRet
		cAliasD0Z := GetNextAlias()
		BeginSql Alias cAliasD0Z
			SELECT COUNT(*) AS COUNTD0Z
			  FROM %Table:D0Z% D0Z
			 WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
			   AND D0Z.D0Z_EMBARQ = %Exp:D0Z->D0Z_EMBARQ%
			   AND (D0Z.D0Z_PRDORI <> %Exp:D0Z->D0Z_PRDORI% 
			    OR D0Z.D0Z_SEQUEN <> %Exp:D0Z->D0Z_SEQUEN%
			    OR D0Z.D0Z_PEDIDO <> %Exp:D0Z->D0Z_PEDIDO%)
			   AND D0Z.%NotDel%
		EndSql
		If (cAliasD0Z)->(!EoF())
			nCountD0Z := (cAliasD0Z)->COUNTD0Z
		EndIf
		(cAliasD0Z)->(DbCloseArea())

		If nCountD0Z <= 0
			WmsMessage(STR0025+CRLF+STR0026,WMSA41304,1) // Exclusão documento não permitida, exclua o embarque! //  Não é permitido existir um processo de embarque sem nenhum item associado.
			lRet := .F.
		EndIf
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} RefreshGrids
Atualiza os registros em tela
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Static Function RefreshGrids()
Local oView := FWViewActive()
	oBrwD0Z:Refresh(.T.)
	oBrwD16:Refresh(.T.)
	If !Empty(oView)
		oView:Refresh()
	EndIf

Return

//--------------------------------------------------
/*/{Protheus.doc} WmsUpdD00
Atualiza os registros da D00
@author  Equipe WMS
@since   21/10/2022
@param cEmbarq embarque para pesquisa de todos os itens da D00
@param nOperat operacao a ser realizada na D00. 
nOperat = 1: Quando estornado/excluido o embarque
nOperat = 2: Quando finalizado o embarque
nOperat = 3: Quando estornadas as quantidades do embarque
nOperat = 4: Exclusão de item de embarque
/*/
//--------------------------------------------------
Function WmsUpdD00(nOperat,cEmbarq,cCarga,cPedido,cItem,cSeq,cLote,cNumLote,cVol)
	Local aArea := Nil
	Local cAliD00Upd := Nil
	Local lD00Local := D00->( ColumnPos( "D00_LOCDOC" ) ) > 0
	Local cWhereLoc := "%"
	Local lWMSAltDca:= SuperGetMV('MV_WMSALDC', .F., .F.) //Permite alterar DOCA no enderecamento

	If !lWMSAltDca
		Return 
	EndIf

	If nOperat = 4 .Or. nOperat = 5
		cWhereLoc += " AND D0Z.D0Z_CARGA = '"+cCarga+"'"
		cWhereLoc += " AND D0Z.D0Z_PEDIDO = '"+cPedido+"'"
		cWhereLoc += " AND D00.D00_OPEEMB <> ' ' AND D00.D00_DATEMB <> ' ' AND D00.D00_HOREMB <> ' '"
		If nOperat = 5
			If !Empty(cVol)
				cWhereLoc += " AND D00.D00_CODVOL = '"+cVol+"'"
			EndIf
		EndIf
	EndIf

	If lD00Local 
		cWhereLoc += " AND D00.D00_CODDOC = D0Z.D0Z_ENDER AND D00.D00_LOCDOC = D0Z.D0Z_LOCAL "
	EndIf
	cWhereLoc += "%"
	
	aArea := GetArea()	
	cAliD00Upd := GetNextAlias()

	BeginSql Alias cAliD00Upd
		SELECT D00.R_E_C_N_O_ RECNOD00, COUNT(*) NQTDREG
			FROM %Table:D00% D00
				INNER JOIN %Table:SC9% SC9 
						ON (SC9.C9_FILIAL = %xFilial:SC9%
						AND SC9.C9_PEDIDO = D00.D00_PEDIDO
						AND SC9.C9_CARGA = D00.D00_CARGA
						AND SC9.%NotDel%)
				LEFT JOIN %Table:DCV% DCV 
						ON (DCV.DCV_FILIAL = %xFilial:DCV%
						AND DCV.DCV_PEDIDO = SC9.C9_PEDIDO
						AND DCV.DCV_ITEM = SC9.C9_ITEM
						AND DCV.DCV_SEQUEN = SC9.C9_SEQUEN
						AND DCV.DCV_CODVOL = D00.D00_CODVOL
						AND DCV.%NotDel%)
				LEFT JOIN %Table:SD2% SD2 
						ON (SD2.D2_FILIAL = %xFilial:SD2%
						AND SD2.D2_PEDIDO = SC9.C9_PEDIDO
						AND SD2.D2_ITEMPV = SC9.C9_ITEM
						AND SD2.D2_DOC = SC9.C9_NFISCAL
						AND SD2.D2_SERIE = SC9.C9_SERIENF
						AND SD2.%NotDel%)
				INNER JOIN %Table:D0Z% D0Z
						ON(D0Z.D0Z_FILIAL = %xFilial:D0Z%
						AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
						AND D0Z.D0Z_ITEM  = SC9.C9_ITEM
						AND D0Z.D0Z_SEQUEN = SC9.C9_SEQUEN
						AND D0Z.D0Z_LOTECT = SC9.C9_LOTECTL
						AND D0Z.%NotDel% )
				INNER JOIN %Table:D0X% D0X
						ON(D0X.D0X_FILIAL = %xFilial:D0X%
						AND D0X.D0X_EMBARQ = D0Z.D0Z_EMBARQ
						AND D00.D00_EMBARQ = D0Z.D0Z_EMBARQ
						AND D0X.%NotDel%)
							WHERE D00.D00_FILIAL = %xFilial:D00%
								%Exp:cWhereLoc%
								AND D00.%NotDel%
								AND D0X.D0X_EMBARQ = %Exp:cEmbarq%
				  GROUP BY D00.R_E_C_N_O_
	EndSql
	While(cAliD00Upd)->(!Eof())
		D00->(dbGoTo((cAliD00Upd)->RECNOD00))
			If nOperat = 1 .Or. (nOperat = 4 .And. (cAliD00Upd)->NQTDREG = 1)
				RecLock('D00',.F.)
					D00->D00_OPEEMB := " "
					D00->D00_DATEMB := CtoD("  /  /  ")
					D00->D00_HOREMB := " "
					D00->D00_EMBARQ := " "
				D00->(MsUnLock())
			ElseIf nOperat = 2
				RecLock('D00',.F.)
					D00->D00_DTEMBF := dDatabase
					D00->D00_HREMBF := Time()
				D00->(MsUnLock())
			ElseIf nOperat = 3 .Or. (nOperat = 5 .And. (cAliD00Upd)->NQTDREG = 1)
				RecLock('D00',.F.)
					D00->D00_DTEMBF := CtoD("  /  /  ")
					D00->D00_HREMBF := " "
				D00->(MsUnLock())
			EndIf
		(cAliD00Upd)->(DbSkip())
	EndDo
	(cAliD00Upd)->(DbCloseArea())
	RestArea(aArea)
Return
