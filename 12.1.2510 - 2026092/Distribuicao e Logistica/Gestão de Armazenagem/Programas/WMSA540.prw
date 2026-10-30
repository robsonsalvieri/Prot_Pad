#INCLUDE "PROTHEUS.CH"   
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA540.CH"

Function WMSA540()
Local nTime := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local oBrowse
	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If Pergunte("WMSA540",.T.)
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("D0D")         // Alias da tabela utilizada
		oBrowse:SetMenuDef("WMSA540")   // Nome do fonte onde esta a função MenuDef
		oBrowse:SetDescription(STR0001) // Descrição do browse "Monitor de Distribuição da Separação
		oBrowse:DisableDetails()        // Desabilita detalhes do Browse
		oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
		oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:AddLegend("D0D->D0D_STATUS=='1'.And.D0D->D0D_QTDDIS==0", "RED"   , STR0002) // Pendente
		oBrowse:AddLegend("D0D->D0D_STATUS=='1'.And.D0D->D0D_QTDDIS>0" , "YELLOW", STR0003) // Em Andamento
		oBrowse:AddLegend("D0D->D0D_STATUS=='2'"                       , "GREEN" , STR0004) // Finalizada
		oBrowse:SetProfileID("D0D")
		oBrowse:SetParam({|| SelFiltro(oBrowse) })
		oBrowse:SetTimer({|| RefreshBrw(oBrowse) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrowse:SetIniWindow({||oBrowse:oTimer:lActive := (MV_PAR07 < 4)})
	
		oBrowse:Activate()
	EndIf
Return
//-----------------------------------------------------------
// Função MenuDef
//-----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
   ADD OPTION aRotina TITLE STR0005 ACTION "WMS540DDS()" OPERATION 2 ACCESS 0 // Monitor
Return aRotina

Function WMSA540MNT()
Return WMS540DDS()

Function WMS540DDS()
Local oSize, oDlg, oLayer, oMaster, oPanel, oCombo, oTimer
Local aPosSize := {}
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local nPos     := 0
Local cStatus  := ""

	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar

	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 60, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 60, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()
	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ;
	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
 	oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	D0D->( dbSetOrder(1) )
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
					 oSize:GetDimension("MASTER","COLINI"),;
					 oSize:GetDimension("MASTER","LINEND"),;
					 oSize:GetDimension("MASTER","COLEND")}
   oMaster := MsMGet():New("D0D",D0D->(Recno()),2,,,,,aPosSize,,3,,,,oDlg)
   // Força a combo a ler de forma separada, pois o campo da tabela só tem as opções 1 e 2
   If (nPos:=AScan(oMaster:oBox:Cargo,{|oCmp| "D0D_STATUS" $ oCmp:cReadVar})) > 0
      oCombo := oMaster:oBox:Cargo[nPos]
      oCombo:aItems := {"1="+STR0002,"2="+STR0003,"3="+STR0004," "}
      oCombo:cReadVar := "cStatus"
      oCombo:bSetGet := {|u| Iif(ValType(u) <> 'U',cStatus:=u,Iif(D0D->D0D_STATUS=="1".And.D0D->D0D_QTDDIS==0,"1",Iif(D0D->D0D_STATUS=="1".And.D0D->D0D_QTDDIS>0,"2","3")))}
      oCombo:Refresh()
   EndIf

   aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
                oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
                oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
                oSize:GetDimension("DETAIL","YSIZE")}   // Size.y

	oPanel := TPanel():New(aPosSize[1],aPosSize[2],"",oDlg,,,,,,aPosSize[3],aPosSize[4],.F.,.F.)
	SX2->(dbSetOrder(1))
	SX2->(dbSeek("D0E"))
	oBrwD0E := FWMBrowse():New()
	oBrwD0E:SetOwner(oPanel)
	oBrwD0E:SetDescription(Capital(X2Nome())) // Itens da Distribuição
	oBrwD0E:SetAlias("D0E")
	oBrwD0E:SetMenuDef('')
	oBrwD0E:SetProfileID("D0E")
	oBrwD0E:DisableDetails()
	oBrwD0E:SetFixedBrowse(.T.)
	oBrwD0E:SetAmbiente(.F.)
	oBrwD0E:SetWalkThru(.F.)
	oBrwD0E:SetFilterDefault("@D0E_FILIAL='"+xFilial('D0E')+"' AND D0E_CODDIS='"+D0D->D0D_CODDIS+"' AND D0E_CARGA='"+D0D->D0D_CARGA+"' AND D0E_PEDIDO='"+D0D->D0D_PEDIDO+"'")
	oBrwD0E:AddLegend("D0E->D0E_STATUS=='1'.And.D0E->D0E_QTDDIS==0", "RED"   , STR0002) // Pendente
	oBrwD0E:AddLegend("D0E->D0E_STATUS=='1'.And.D0E->D0E_QTDDIS>0" , "YELLOW", STR0003) // Em Andamento
	oBrwD0E:AddLegend("D0E->D0E_STATUS=='2'"                       , "GREEN" , STR0004) // Finalizada
	oBrwD0E:Activate()

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| BrwRefresh(oMaster,oBrwD0E) },oDlg)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()})
Return Nil
//-----------------------------------------------------------
// Função ModelDef
//-----------------------------------------------------------
Static Function ModelDef()
Local oModel     := oModel := MPFormModel():New('WMSA540')
Local oStructD0D := FWFormStruct(1,'D0D')
Local oStructD0E := FWFormStruct(1,'D0E')
Local bStatus    := {||,Iif(D0E->D0E_STATUS=='1'.And.D0E->D0E_QTDDIS==0,'BR_VERMELHO',Iif(D0E->D0E_STATUS=='2','BR_VERDE','BR_AMARELO'))}
   oStructD0E:AddField(STR0006,STR0007,'D0E_VSTATUS','C',11,0,,,,,bStatus,,,.T.) // Situação // Situação da Distribuição do Item

   oModel:AddFields('MdFieldD0D',,oStructD0D)

   oModel:AddGrid('MdGridD0E','MdFieldD0D',oStructD0E)
   
   oModel:SetRelation( 'MdGridD0E', {{'D0E_FILIAL',"xFilial('D0E')"},{'D0E_CODDIS','D0D_CODDIS'}} , D0E->( IndexKey(1) ) )

   oModel:SetPrimaryKey({'D0D_FILIAL', 'D0D_CODDIS'})
   
   oModel:SetDescription(STR0001) // Monitor de Distribuição da Separação
Return oModel
//-----------------------------------------------------------
// Função ViewDef
//-----------------------------------------------------------
Static Function ViewDef()
Local oView      := FWFormView():New()
Local oModel     := FWLoadModel('WMSA540')
Local oStructD0D := FWFormStruct(2,'D0D')
Local oStructD0E := FWFormStruct(2,'D0E')
   oView:SetModel(oModel)
   
   oStructD0E:AddField('D0E_VSTATUS','01',STR0006,STR0007 + '.',{STR0007},'GET','@BMP',,,.F.,,,,,,.T.) // Situação da Distribuição do Item
   oStructD0E:RemoveField('D0E_STATUS')
   
   oView:AddField('VwFieldD0D',oStructD0D,'MdFieldD0D')
   
   oView:AddGrid('VwGridD0E',oStructD0E,'MdGridD0E')
   
   oView:CreateHorizontalBox('SUPERIOR',30)
   oView:CreateHorizontalBox('INFERIOR',70)
   
   oView:SetOwnerView('VwFieldD0D','SUPERIOR')
   oView:SetOwnerView('VwGridD0E','INFERIOR')
Return oView

Static Function Filtro()
Local cFiltro := ""
	cFiltro := " D0D_CARGA >= '"+MV_PAR01+"' AND D0D_CARGA <= '"+MV_PAR02+"'"
	cFiltro += " AND D0D_PEDIDO >= '"+MV_PAR03+"' AND D0D_PEDIDO <= '"+MV_PAR04+"'"
	cFiltro += " AND D0D_DATA >= '"+DTOS(MV_PAR05)+"' AND D0D_DATA <= '"+DTOS(MV_PAR06)+"'"
Return cFiltro

//-------------------------------------------------------------------//
//--------------------Seleção do filtro tecla F12--------------------//
//-------------------------------------------------------------------//
Static Function SelFiltro(oBrowse)
Local lRet := .T.

	If (lRet := Pergunte('WMSA540',.T.))
	   oBrowse:oTimer:lActive := (MV_PAR07 < 4)
		oBrowse:SetFilterDefault("@"+Filtro())
		oBrowse:Refresh(.T.)
	EndIf
Return lRet
//-------------------------------------------------------------------//
//------------Refresh do Browse para Recarregar a Tela---------------//
//-------------------------------------------------------------------//
Static Function RefreshBrw(oBrowse)
Local nPos := oBrowse:At()

	Pergunte('WMSA540', .F.)
	oBrowse:SetFilterDefault("@"+Filtro())
	If MV_PAR07 == 1
		oBrowse:Refresh(.T.)
	ElseIf MV_PAR07 == 2
		oBrowse:Refresh(.F.)
		oBrowse:GoBottom()
	Else
		oBrowse:Refresh(.F.)
		oBrowse:GoTo(nPos)
	EndIf
Return .T.
//-----------------------------------------------------------
// Função responsável por efetuar a atualização da tela
//-----------------------------------------------------------
Static Function BrwRefresh(oMaster,oBrwD0E)
Local aAreaD0D := D0D->(GetArea())
	// Força a releitura da situação da distribuição da separação
	D0D->( DbSeek(xFilial('D0D')+D0D->D0D_CODDIS+D0D->D0D_CARGA+D0D->D0D_PEDIDO) )
	oMaster:Refresh()
	D0E->(dbSetOrder(1))
	oBrwD0E:Refresh()
	RestArea(aAreaD0D)
Return .T.
