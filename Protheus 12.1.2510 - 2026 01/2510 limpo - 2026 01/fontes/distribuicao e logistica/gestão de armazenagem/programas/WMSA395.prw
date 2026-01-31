#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA395.CH"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSA395 - Geração de Pedido Cross-Docking Monitor                 |
+---------+--------------------------------------------------------------------+
|Objetivo | Permite efetuar a seleção de uma listagem de volumes cross-docking |
|         | para efetuar a geração de um pedido de vendas integrado com o WMS  |
|         | de forma direta a partir dos itens do volume via monitor.          |
+---------+--------------------------------------------------------------------+
*/

#DEFINE WMSA39501 "WMSA39501"
#DEFINE WMSA39502 "WMSA39502"
#DEFINE WMSA39503 "WMSA39503"

//------------------------------------------------------------------------------
// Função para aparecer no inspetor de objetos
//------------------------------------------------------------------------------
Static cAliasTmp := GetNextAlias()
Static oBrowse   := Nil
Static oTabTmp   := Nil 
Function WMSA395()
Local nTime := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local aArqTmp     := {}
Local aArqTab     := {}
Local aColsSX3    := {}
Local aColsLocal  := {}
Local aColsEnder  := {}
Local aColumns    := {}
Local aSeeks      := {}
Local aIndex      := {}
Local aFields     := {}
Local nX          := 0
Local aTamD14     := TamSX3("D14_QTDEST")

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf
	
	If Pergunte('WMSA395',.T.)

		BuscarSX3("BE_LOCAL"  , ,aColsLocal)
		BuscarSX3("BE_LOCALIZ"  , ,aColsEnder)

		AAdd(aSeeks, {; // Armazém + Endereço
					AllTrim(aColsLocal[1])+' + '+AllTrim(aColsEnder[1]),;
					{; //,;
						{'NNR',"C",aColsLocal[3],aColsLocal[4],aColsLocal[1],Nil},;
						{'SBE',"C",aColsEnder[3],aColsEnder[4],aColsEnder[1],Nil};
					}})
		AAdd(aSeeks, {; // Endereço
					AllTrim(aColsEnder[1]),;
					{; //,;
						{'SBE',"C",aColsEnder[3],aColsEnder[4],aColsEnder[1],Nil};
					}})

		Aadd( aIndex, "TMP_LOCAL+TMP_ENDER" )
		Aadd( aIndex, "TMP_ENDER" )

		AAdd(aArqTmp,{"TMP_LOCAL" ,BuscarSX3("BE_LOCAL"  , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTmp,{"TMP_ENDER" ,BuscarSX3("BE_LOCALIZ", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTmp,{"TMP_DESEND",BuscarSX3("BE_DESCRIC", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTmp,{"TMP_CLIENT",BuscarSX3("D10_CLIENT", ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})
		AAdd(aArqTmp,{"TMP_LOJA"  ,BuscarSX3("D10_LOJA"  , ,aColsSX3),"C",aColsSX3[3],aColsSX3[4],aColsSX3[2]})

		For nX := 1 To Len(aArqTmp)
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[nX]:SetData( &("{||"+aArqTmp[nX][1]+"}") )
			aColumns[nX]:SetTitle(aArqTmp[nX][2])
			aColumns[nX]:SetType(aArqTmp[nX][3])
			aColumns[nX]:SetSize(aArqTmp[nX][4])
			aColumns[nX]:SetDecimal(aArqTmp[nX][5])
			aColumns[nX]:SetPicture(aArqTmp[nX][6])
			AAdd(aArqTab,{aArqTmp[nX][1],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5]})
			AAdd(aFields,{aArqTmp[nX][1],aArqTmp[nX][2],aArqTmp[nX][3],aArqTmp[nX][4],aArqTmp[nX][5],aArqTmp[nX][6]})
		Next nX
		AAdd(aArqTab,{"TMP_QTDEST","N",aTamD14[1],aTamD14[2]})
		AAdd(aArqTab,{"TMP_QTDDIS","N",aTamD14[1],aTamD14[2]})
		AAdd(aArqTab,{"TMP_QTDVOL","N",10,0})
		CriaTabTmp(aArqTab,aIndex,cAliasTmp,@oTabTmp)
		LoadData(cAliasTmp,oTabTmp)

		// Instanciamento da Classe de FWBrowse
		oBrowse := FWMBrowse():New()
		// Titulo da Browse
		oBrowse:SetDescription(STR0001) // Monitor de Volume Crossdocking
		oBrowse:SetTemporary(.T.)
		// Definição da legenda
		oBrowse:AddLegend( "TMP_QTDEST == 0 .And. TMP_QTDVOL == 0", "RED"   , "Endereço vazio")
		oBrowse:AddLegend( "TMP_QTDEST > 0  .And. TMP_QTDVOL == 0 .And. TMP_QTDDIS > 0", "GREEN" , "Saldo disponível")
		oBrowse:AddLegend( "TMP_QTDEST > 0  .And. TMP_QTDVOL > 0 .And. TMP_QTDDIS > 0" , "BLUE"  , "Saldo disponível com volumes montados")
		oBrowse:AddLegend( "TMP_QTDEST > 0  .And. TMP_QTDVOL > 0 .And. TMP_QTDDIS == 0", "YELLOW", "Volumes montados sem saldo disponível")
		oBrowse:AddLegend( "TMP_QTDEST > 0  .And. TMP_QTDVOL == 0 .And. TMP_QTDDIS == 0" , "BLACK" , "Saldo indisponível")

		oBrowse:SetAlias(cAliasTmp)
		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetColumns(aColumns)
		oBrowse:SetMenuDef('WMSA395')
		oBrowse:SetSeek(.T.,aSeeks)
		oBrowse:SetFieldFilter( aFields )
		oBrowse:SetUseFilter()
		oBrowse:SetParam({|| SelFiltro() })
		oBrowse:SetTimer({|| RefreshBrw() }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR05 < 4)})

		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetProfileID('SBE')

		// Opcionalmente pode ser desligado a exibição dos detalhes
		oBrowse:DisableDetails()

		// Ativação da Classe
		oBrowse:Activate()
		DelTabTmp(cAliasTmp,oTabTmp)
	EndIf
Return Nil

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION "WMS395Mtor()"   OPERATION 2 ACCESS 0 // Monitor
	ADD OPTION aRotina TITLE STR0012 ACTION "WMS395GVol()"   OPERATION 2 ACCESS 0 // Gerar Volume
	ADD OPTION aRotina TITLE STR0003 ACTION "WMS395GPed()"   OPERATION 2 ACCESS 0 // Gerar Pedido
Return aRotina

//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro()
Local nPos := oBrowse:At()
Local lRet := .T.

	If (lRet := Pergunte('WMSA395',.T.))
		LoadData(oBrowse:Alias(),oTabTmp)
		oBrowse:oTimer:lActive := (MV_PAR05 < 4)
		oBrowse:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw()
Local nPos := oBrowse:At()

	Pergunte('WMSA395',.F.) // Força recarregar as perguntas
	LoadData(oBrowse:Alias(),oTabTmp)
	If MV_PAR05 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR05 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:GoTo(nPos)
	EndIf
Return .T.

//------------------------------------------------------------------------------
// SQL para listagem dos dados no browse
//------------------------------------------------------------------------------
Static Function QuerySBE()
Local cQuery := ""

	cQuery := " SELECT SBE.BE_LOCAL TMP_LOCAL,"
	cQuery +=        " SBE.BE_LOCALIZ TMP_ENDER,"
	cQuery +=        " SBE.BE_DESCRIC TMP_DESEND,"
	cQuery +=        " CASE WHEN D10.D10_CLIENT IS NULL THEN ' ' ELSE D10.D10_CLIENT END TMP_CLIENT,"
	cQuery +=        " CASE WHEN D10.D10_LOJA IS NULL THEN ' ' ELSE D10.D10_LOJA END TMP_LOJA,"
	cQuery +=        " CASE WHEN SUM(D14.D14_QTDEST) IS NULL THEN 0 ELSE SUM(D14.D14_QTDEST) END TMP_QTDEST,"
	cQuery +=        " CASE WHEN SUM(D14.D14_QTDEST-(D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDEMP)) IS NULL THEN 0 ELSE SUM(D14.D14_QTDEST-(D14.D14_QTDSPR + D14.D14_QTDBLQ + D14.D14_QTDEMP)) END TMP_QTDDIS,"
	cQuery +=        " (SELECT COUNT(D0N.D0N_CODVOL)"
	cQuery +=           " FROM "+RetSQLName("D0N")+" D0N"
	cQuery +=          " WHERE D0N.D0N_FILIAL = '"+xFilial("D0N")+"'"
	cQuery +=            " AND D0N.D0N_LOCAL = SBE.BE_LOCAL"
	cQuery +=            " AND D0N.D0N_ENDER = SBE.BE_LOCALIZ"
	cQuery +=            " AND D0N.D_E_L_E_T_ = ' ' ) TMP_QTDVOL"
	cQuery +=  " FROM "+RetSQLName("SBE")+" SBE"
	cQuery += " INNER JOIN "+RetSQLName("DC8")+" DC8"
	cQuery +=    " ON DC8.DC8_FILIAL = '"+xFilial("DC8")+"'"
	cQuery +=   " AND DC8.DC8_CODEST = SBE.BE_ESTFIS"
	cQuery +=   " AND DC8.DC8_TPESTR = '3'"
	cQuery +=   " AND DC8.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN "+RetSQLName("D10")+" D10"
	cQuery +=    " ON D10.D10_FILIAL = '"+xFilial("D10")+"'"
	cQuery +=   " AND D10.D10_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND D10.D10_ENDER = SBE.BE_LOCALIZ"
	cQuery +=   " AND D10.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN "+RetSQLName("D14")+" D14"
	cQuery +=    " ON D14.D14_FILIAL = '"+xFilial("D14")+"'"
	cQuery +=   " AND D14.D14_LOCAL = SBE.BE_LOCAL"
	cQuery +=   " AND D14.D14_ENDER = SBE.BE_LOCALIZ"
	cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SBE.BE_FILIAL = '"+xFilial("SBE")+"'"
	cQuery +=   " AND SBE.BE_LOCAL >= '"+MV_PAR01+"'"
	cQuery +=   " AND SBE.BE_LOCAL <= '"+MV_PAR02+"'"
	cQuery +=   " AND SBE.BE_LOCALIZ >= '"+MV_PAR03+"'"
	cQuery +=   " AND SBE.BE_LOCALIZ <= '"+MV_PAR04+"'"
	cQuery +=   " AND SBE.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY SBE.BE_LOCAL,"
	cQuery +=          " SBE.BE_LOCALIZ,"
	cQuery +=          " SBE.BE_DESCRIC,"
	cQuery +=          " D10.D10_CLIENT,"
	cQuery +=          " D10.D10_LOJA"

Return cQuery

//------------------------------------------------------------------------------
// Efetua a carga dos dados numa temporária para utilizar no browse
//------------------------------------------------------------------------------
Static Function LoadData(cAliasTab,oTabTmp)
Local cQuery := QuerySBE()
	WmsQry2Tmp(cAliasTab,oTabTmp:oStruct:aFields,cQuery,oTabTmp)
Return

//-------------------------------------------------------------------//
//-----------------------------Monitor-------------------------------//
//-------------------------------------------------------------------//
Function WMS395Mtor()
Local aCoors := FWGetDialogSize(oMainWnd)
Local oDlg, oMaster,oSize
Local oLayer,oPanelLeft,oPanelRight,oRel,oPanel2
Local aButtons := {}
Local aPosSize := {}
Local nOpcA    := 0
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oBrwD0N, oBrwD0O

	SBE->(dbSetOrder(1))
	SBE->(dbSeek(xFilial("SBE")+(cAliasTmp)->TMP_LOCAL+(cAliasTmp)->TMP_ENDER))

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 40, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	Define MsDialog oDlg TITLE STR0001 FROM ; // Monitor de Volume Crossdocking
		oSize:aWindSize[1],oSize:aWindSize[2] TO ;
		oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as variáveis de memória usadas pela Enchoice
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
				oSize:GetDimension("MASTER","COLINI"),;
				oSize:GetDimension("MASTER","LINEND"),;
				oSize:GetDimension("MASTER","COLEND")}
	oMaster := MsMGet():New("SBE",SBE->(Recno()),2,,,,{"BE_LOCAL","BE_LOCALIZ","BE_DESCRIC"},aPosSize,,3,,,,oDlg,,,,,.T./*lNoFolder*/)

	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
				oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
				oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
				oSize:GetDimension("DETAIL","YSIZE")}   // Size.y

	oPanel2       := TPanel():New(aPosSize[1],aPosSize[2],'',oDlg,, .T., .T.,, ,aPosSize[3],aPosSize[4],.T.,.T. )
	oPanel2:Align := CONTROL_ALIGN_BOTTOM

	oLayer := FWLayer():New()
	oLayer:Init(oPanel2,.F.,.T.)

	oLayer:AddCollumn("LEFT",50,.F.)
	oLayer:AddCollumn("RIGHT",50,.F.)

	oPanelLeft := oLayer:GetColPanel('LEFT')
	oPanelRight := oLayer:GetColPanel('RIGHT')

	// Define Browse Volume (D0N)
	oBrwD0N := FWMBrowse():New()
	oBrwD0N:SetOwner(oPanelLeft)
	oBrwD0N:SetDescription(STR0004) // Volume Crossdoking
	oBrwD0N:SetAlias('D0N')
	oBrwD0N:SetAmbiente(.F.)
	oBrwD0N:SetWalkThru(.F.)
	oBrwD0N:SetMenuDef('')
	oBrwD0N:DisableDetails()
	oBrwD0N:SetFixedBrowse(.T.)
	oBrwD0N:SetProfileID('D0N')
	oBrwD0N:SetFilterDefault("@D0N_FILIAL = '"+xFilial('D0N')+"' AND D0N_LOCAL = '"+(cAliasTmp)->TMP_LOCAL+"' AND D0N_ENDER = '"+(cAliasTmp)->TMP_ENDER+"'")
	oBrwD0N:AddButton(STR0005, {|| oTimer:DeActivate(), MntVolume(oBrwD0N), oTimer:Activate()},, MODEL_OPERATION_INSERT, 0) // Montar Volume
	oBrwD0N:AddButton(STR0006, {|| oTimer:DeActivate(), EstVolume(oBrwD0N), oTimer:Activate()},, MODEL_OPERATION_DELETE, 0) // Estornar Volume
	oBrwD0N:Activate()

	// Define Browse Produtos (D0O)
	oBrwD0O := FWMBrowse():New()
	oBrwD0O:SetOwner(oPanelRight)
	oBrwD0O:SetAlias('D0O')
	oBrwD0O:SetAmbiente(.F.)
	oBrwD0O:SetWalkThru(.F.)
	oBrwD0O:SetMenuDef(' ')
	oBrwD0O:DisableDetails()
	oBrwD0O:SetFixedBrowse(.T.)
	oBrwD0O:SetDescription(STR0007) // Itens do Volume
	oBrwD0O:SetProfileID('D0O')
	oBrwD0O:AddButton(STR0008, {|| oTimer:DeActivate(), EstItemVol(oBrwD0N,oBrwD0O), oTimer:Activate()},, MODEL_OPERATION_UPDATE, 0) // Est. Item Volume
	oBrwD0O:Activate()

	// Relacionamento browse Itens com Pedidos
	oRel := FWBrwRelation():New()
	oRel:AddRelation(oBrwD0N,oBrwD0O,{ {"D0O_FILIAL","xFilial('D0O')"},{"D0O_CODVOL","D0N_CODVOL"} })
	oRel:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| oBrwD0N:Refresh(), oBrwD0O:Refresh() },oDlg)
	oTimer:Activate()

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)
	RefreshBrw()
Return Nil

//----------------------------------------------------------------------------------//
//--Gerar Volume Cross Docking Automático a Partir da Seleção de Saldo do Endereço--//
//----------------------------------------------------------------------------------//
Function WMS395GVol()
Local lRet := .T.

	If Empty(SuperGetMv("MV_WMSNVOL",.F.,""))
		WmsMessage(STR0010,WMSA39501,1) // Parâmetro MV_CODVOL inexistente! Avise o Administrador do sistema!
		lRet := .F.
	EndIf

	If lRet .And. QtdComp((cAliasTmp)->TMP_QTDDIS) <= 0
		WmsMessage(STR0011,WMSA39502,1) // Endereço não possui saldo disponível para montagem de volumes.
		lRet := .F.
	EndIf

	If lRet
		SBE->(dbSetOrder(1))
		SBE->(dbSeek(xFilial("SBE")+(cAliasTmp)->TMP_LOCAL+(cAliasTmp)->TMP_ENDER))
		lRet := FWExecView(STR0012,'WMSA395D',MODEL_OPERATION_INSERT,,{ || .T. },,,,{ || .T. }) // Gerar Volume
		RefreshBrw()
	EndIf
Return lRet

//-------------------------------------------------------------------//
//--Gerar pedido de Venda a Partir da Seleção de Volume do Endereço--//
//-------------------------------------------------------------------//
Function WMS395GPed()
Local lRet := .T.

	If QtdComp((cAliasTmp)->TMP_QTDVOL) <= 0
		WmsMessage(STR0009,WMSA39503,1) // Endereço não possui nenhum volume montado para gerar pedido.
		lRet := .F.
	EndIf

	If lRet
		SBE->(dbSetOrder(1))
		SBE->(dbSeek(xFilial("SBE")+(cAliasTmp)->TMP_LOCAL+(cAliasTmp)->TMP_ENDER))
		lRet := FWExecView(STR0003,'WMSA395C',MODEL_OPERATION_INSERT,,{ || .T. },,,,{ || .T. }) // Gerar Pedido
		RefreshBrw()
		//Apaga tabela temporária criada na view do WMSA395C
		If !Empty(__cAlias) .And. !Empty(__oTabTmp)
			DelTabTmp(__cAlias,__oTabTmp)
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------//
//-------------Efetua a Montagem de Volumes no Endereço--------------//
//-------------------------------------------------------------------//
Static Function MntVolume(oBrowse)
Local lRet := .T.

	If Empty(SuperGetMv("MV_WMSNVOL",.F.,""))
		WmsMessage(STR0010,WMSA39501,1) // Parâmetro MV_CODVOL inexistente! Avise o Administrador do sistema!
		lRet := .F.
	EndIf

	If lRet .And. QtdComp((cAliasTmp)->TMP_QTDDIS) <= 0
		WmsMessage(STR0011,WMSA39502,1) // Endereço não possui saldo disponível para montagem de volumes.
		lRet := .F.
	EndIf

	If lRet
		SBE->(dbSetOrder(1))
		SBE->(dbSeek(xFilial("SBE")+(cAliasTmp)->TMP_LOCAL+(cAliasTmp)->TMP_ENDER))
		lRet := FWExecView(STR0005,'WMSA395A',MODEL_OPERATION_INSERT,,{ || .T. },,30,,{ || .T. }) // Montar Volume
		oBrowse:Refresh(.T.)
	EndIf
Return lRet

//-------------------------------------------------------------------//
//-------------------Estorna um Volume do Endereço-------------------//
//-------------------------------------------------------------------//
Static Function EstVolume(oBrowse)
Local lRet := .T.
	lRet := FWExecView(STR0006,'WMSA395B',MODEL_OPERATION_DELETE,,{ || .T. },,,,{ || .T. }) // Estornar Volume
	oBrowse:Refresh(.T.)
Return lRet

//-------------------------------------------------------------------//
//---------------Estorna um Item do Volume do Endereço---------------//
//-------------------------------------------------------------------//
Static Function EstItemVol(oBrwD0N,oBrwD0O)
Local lRet := .T.
	WMSA395BIV(.T.)
	lRet := FWExecView(STR0007,'WMSA395B',MODEL_OPERATION_UPDATE,,{ || .T. },,,,{ || .T. }) // Est. Item Volume
	oBrwD0N:Refresh(.T.)
	oBrwD0O:Refresh(.T.)
	WMSA395BIV(.F.)
Return lRet

Static __cAlias := Nil
Function Wms395Tab(cAliasD0N)
	If ValType(cAliasD0N) == "C"
		__cAlias := cAliasD0N
	EndIf
Return __cAlias

Static __oTabTmp := Nil
Function Wms395Ali(oTabTmpD0N)
	If ValType(oTabTmpD0N) == "O"
		__oTabTmp := oTabTmpD0N
	EndIf
Return __oTabTmp
