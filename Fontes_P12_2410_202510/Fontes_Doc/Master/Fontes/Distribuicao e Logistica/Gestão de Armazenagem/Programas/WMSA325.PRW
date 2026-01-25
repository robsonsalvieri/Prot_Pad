#INCLUDE "WMSA325.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA32501 "WMSA32501"
#DEFINE WMSA32502 "WMSA32502"
#DEFINE WMSA32503 "WMSA32503"
#DEFINE WMSA32504 "WMSA32504"
#DEFINE WMSA32505 "WMSA32505"
#DEFINE WMSA32506 "WMSA32506"
#DEFINE WMSA32507 "WMSA32507"
#DEFINE WMSA32508 "WMSA32508"
#DEFINE WMSA32509 "WMSA32509"
#DEFINE WMSA32510 "WMSA32510"
#DEFINE WMSA32511 "WMSA32511"
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325
Distribuição de produtos
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA325()
Local aCoors := FWGetDialogSize (oMainWnd )
Local oFWLayerMAS
Local oFWLayerDET
Local oPnlCapa
Local oPnlDetail
Local oFolder
Local oPnlD06
Local oPlnD09
Local oPlnGrf
Local oDlgPrinc
Local oRelD07
Local oRelD08
Local oRelD09

Private oBrwD06, oBrwD07, oBrwD08, oBrwD09, oTmpGrf
Private cResLeg := ""

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	If pergunte('WMSA325',.T.)

		Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors [2] To aCoors[3], aCoors[4] Pixel // Montagem Distribuição de Produtos

		// Cria conteiner para os browses
		oFWLayerMAS := FWLayer():New()
		oFWLayerMAS:Init( oDlgPrinc, .F., .T.)

		// Define painel Master
		oFWLayerMAS:AddLine( 'UP', 48.5, .T.)
		oPnlCapa := oFWLayerMAS:GetLinePanel('UP')

		oLayerSeq := FWLayer():New()
		oLayerSeq:Init(oPnlCapa, .F., .T.)

		oLayerSeq:AddLine('UP', 100, .F.)
		oPnlD06 := oLayerSeq:GetLinePanel ('UP')

		oBrwD06 := FWMBrowse():New()
		oBrwD06:SetOwner(oPnlD06)
		oBrwD06:SetAlias('D06')
		oBrwD06:SetMenuDef('WMSA325')
		oBrwD06:SetDescription(STR0002) // Distribuição de Produtos
		oBrwD06:DisableDetails()
		oBrwD06:SetFilterDefault(WMSA325Fil() )
		oBrwD06:AddLegend("D06_SITDIS=='1'",'GREEN', STR0003)  // Aberta
		oBrwD06:AddLegend("D06_SITDIS=='2'",'RED', STR0004)    // Distribuida
		oBrwD06:AddLegend("D06_SITDIS=='3'",'YELLOW', STR0005) // Cancelada
		oBrwD06:ForceQuitButton()
		oBrwD06:SetFixedBrowse(.T.)
		oBrwD06:SetParam({|| SelFiltro() })
		oBrwD06:Activate()
		// Define painel Detail
		oFWLayerMAS:AddLine( 'DOWN', 51.5, .T.)
		oPnlDetail := oFWLayerMAS:GetLinePanel ('DOWN')
		// Documento|Produto|Conferência
		oFolder := TFolder():New( 0, 0, {STR0006,STR0007,STR0008}, {STR0006,STR0007,STR0008}, oPnlDetail,,,, .T.,,oPnlDetail:NCLIENTWIDTH/2,oPnlDetail:NCLIENTHEIGHT/2) //Produtos#Documentos#Pedidos/Plano

		oFWLayerDET := FWLayer():New()
		oFWLayerDET:Init( oFolder:aDialogs[1], .F., .T.)
		oFWLayerDET:AddLine( 'DOWN', 100, .T.)

		oPnlDwn := oFWLayerDET:GetLinePanel('DOWN')

		oFWLayerDET:AddColumn( 'DOWNLEFT', 70, .T., 'DOWN' )
		oFWLayerDET:AddColumn( 'DOWNRIGHT', 30, .T., 'DOWN' )

		oPlnD09 := oFWLayerDET:GetColPanel('DOWNLEFT','DOWN')
		oPlnGrf := oFWLayerDET:GetColPanel('DOWNRIGHT','DOWN')

		oTmpGrf := FWChartFactory():New()   // Cria o objeto grafico em uma variavel temp
		oTmpGrf := oTmpGrf:getInstance(PIECHART)
		oTmpGrf:SetTitle(STR0009, CONTROL_ALIGN_CENTER) // Distribuição
		oTmpGrf:SetPicture('@E 9999,999,999')
		oTmpGrf:SetLegend(CONTROL_ALIGN_BOTTOM)

		oTmpGrf:Init(oPlnGrf,.T.,.T.)
		UpdGraf()
		oTmpGrf:oFWChartColor:SetColor("Random")

		oBrwD09 := FWMBrowse():New()
		oBrwD09:SetOwner(oPlnD09)
		oBrwD09:SetAlias('D09') // Produto
		oBrwD09:SetMenuDef('')  // Nome do fonte onde esta a função MenuDef
		oBrwD09:AddLegend("D09_QTDDIS == 0",'RED'   ,STR0010)          // Não distribuido
		oBrwD09:AddLegend("D09_QTDDIS <> D09_QTDADI",'YELLOW',STR0011) // Saldo a distribuir
		oBrwD09:AddLegend("D09_QTDDIS == D09_QTDADI",'BLUE' ,STR0012)  // Distribuido
		oBrwD09:SetDescription(STR0006) // Produtos
		oBrwD09:DisableDetails()
		oBrwD09:SetFixedBrowse(.T.)
		oBrwD09:SetChange( { || UpdGraf() } )
		oBrwD09:ForceQuitButton()
		oBrwD09:Activate()

		// Define Browse Documento
		oBrwD07 := FWMBrowse():New()
		oBrwD07:SetOwner(oFolder:aDialogs[2])
		oBrwD07:SetDescription(STR0007) // Documentos
		oBrwD07:SetAlias('D07')
		oBrwD07:SetMenuDef('')
		oBrwD07:AddLegend("WMSA325SDE() == '1'",'GREEN'	,STR0027) // NF Nao Classificada
		oBrwD07:AddLegend("cResLeg == '2'",'RED'		,STR0028) // NF Normal
		oBrwD07:AddLegend("cResLeg == '3'",'ORANGE'	,STR0029) // NF Bloqueada
		oBrwD07:AddLegend("cResLeg == '4'",'VIOLET'	,STR0030) // NF Bloqueada s/classf.
		oBrwD07:AddLegend("cResLeg == '5'",'BLUE'	,STR0031) // NF de Compl. IPI
		oBrwD07:AddLegend("cResLeg == '6'",'BROWN'	,STR0032) // NF de Compl. ICMS
		oBrwD07:AddLegend("cResLeg == '7'",'PINK'	,STR0033) // NF de Compl. Preco/Frete
		oBrwD07:AddLegend("cResLeg == '8'",'GRAY'	,STR0034) // NF de Beneficiamento
		oBrwD07:AddLegend("cResLeg == '9'",'YELLOW'	,STR0035) // NF de Devolução
		oBrwD07:AddLegend("cResLeg == '10'",'BLACK'	,STR0036) // NF Bloq. para Conferência
		oBrwD07:AddLegend("cResLeg == '11'",'WHITE'	,STR0037) // Cancelada
		oBrwD07:DisableDetails()
		oBrwD07:SetFixedBrowse(.T.)
		oBrwD07:Activate()
		// Define Browse Pedido/Planos
		oBrwD08 := FWMBrowse():New()
		oBrwD08:SetOwner(oFolder:aDialogs[3])
		oBrwD08:SetDescription(STR0008) // Pedidos/Planos
		oBrwD08:SetAlias('D08')
		oBrwD08:SetMenuDef('')
		oBrwD08:AddLegend("D08_QTDDIS == 0",'RED'   ,STR0010)          // Não distribuido
		oBrwD08:AddLegend("D08_QTDDIS <> D08_QTDVEN",'YELLOW',STR0011) // Saldo a distribuir
		oBrwD08:AddLegend("D08_QTDDIS == D08_QTDVEN",'BLUE' ,STR0012)  // Distribuido
		oBrwD08:DisableDetails()
		oBrwD08:SetFixedBrowse(.T.)
		oBrwD08:Activate()
		// Relacionamento Documento
		oRelD07 := FWBrwRelation():New()
		oRelD07:AddRelation(oBrwD06, oBrwD07, {{"D07_FILIAL","xFilial('D07')"},{"D07_CODDIS","D06_CODDIS"}})
		oRelD07:Activate()
		// Relacionamento Pedido/Planos
		oRelD08 := FWBrwRelation():New()
		oRelD08:AddRelation(oBrwD06, oBrwD08, {{"D08_FILIAL","xFilial('D08')"},{"D08_CODDIS","D06_CODDIS"}})
		oRelD08:Activate()
		// Relacionamento Produto
		oRelD09 := FWBrwRelation():New()
		oRelD09:AddRelation (oBrwD06, oBrwD09, {{"D09_FILIAL","xFilial('D09')"},{"D09_CODDIS","D06_CODDIS"}})
		oRelD09:Activate()

		Activate MsDialog oDlgPrinc Center

		delTabTmp('SELSD1')
		delTabTmp('SELSC9')
	EndIf
Return Nil
//----------------------------------------------------------
// MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
	//----------------------------------------------------------
	// Adiciona botões do browse
	//----------------------------------------------------------
	ADD OPTION aRotina TITLE STR0013 ACTION 'AxPesqui'   OPERATION 1 ACCESS 0 DISABLE MENU // Pesquisar
	ADD OPTION aRotina TITLE STR0016 ACTION 'WMSA325VIS' OPERATION 2 ACCESS 0 DISABLE MENU // Visualizar
	ADD OPTION aRotina TITLE STR0014 ACTION 'WMSA325MON' OPERATION 3 ACCESS 0 DISABLE MENU // Montagem
	ADD OPTION aRotina TITLE STR0015 ACTION 'WMSA325MAN' OPERATION 4 ACCESS 0 DISABLE MENU // Manutenção
	ADD OPTION aRotina TITLE STR0017 ACTION 'WMSA325CAN' OPERATION 4 ACCESS 0 DISABLE MENU // Cancelar
	ADD OPTION aRotina TITLE STR0018 ACTION 'WMSA325EXC' OPERATION 5 ACCESS 0 DISABLE MENU // Excluir
Return aRotina
//----------------------------------------------------------
// ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel  	 := Nil
Local oStructD06 := FWFormStruct(1,'D06')
Local oStructD07 := FWFormStruct(1,'D07')
Local oStructD08 := FWFormStruct(1,'D08')
Local oStructD09 := FWFormStruct(1,'D09')
Local oStructD0F := FWFormStruct(1,'D0F')

	oStructD07:AddField('' ,'','D07_STATUS' , 'C',15,0,,,,.T.,{|| StatusView('D07')},,,.T.) // STATUS
	oStructD08:AddField('' ,'','D08_STATUS' , 'C',15,0,,,,.T.,{|| StatusView('D08')},,,.T.) // STATUS
	oStructD09:AddField('' ,'','D09_STATUS' , 'C',15,0,,,,.T.,{|| StatusView('D09')},,,.T.) // STATUS

	If D07->(FieldPos('D07_SDOC'))>0
		oStructD07:RemoveField('D07_SDOC')
	EndIf
	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('WMSA325', /*bPre*/, /*bPost*/, {|oModel| CommitMdl(oModel) }/*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields('325D06', Nil, oStructD06,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:AddGrid( '325D07', '325D06'	, oStructD07, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( '325D07', {{'D07_FILIAL',"xFilial('D07')"},{'D07_CODDIS','D06_CODDIS'}} , D07->( IndexKey(1) ) )
	oModel:GetModel('325D07'):SetOptional(.T.)

	oModel:AddGrid( '325D08', '325D06'	, oStructD08, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( '325D08', {{'D08_FILIAL',"xFilial('D08')"},{'D08_CODDIS','D06_CODDIS'}} , D08->( IndexKey(1) ) )
	oModel:GetModel('325D08'):SetOptional(.T.)

	oModel:AddGrid( '325D09', '325D06'	, oStructD09, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( '325D09', {{'D09_FILIAL',"xFilial('D09')"},{'D09_CODDIS','D06_CODDIS'}} , D09->( IndexKey(1) ) )
	oModel:GetModel('325D09'):SetOptional(.T.)

	oModel:AddGrid( '325D0F', '325D06'	, oStructD0F, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( '325D0F', {{'D0F_FILIAL',"xFilial('D0F')"},{'D0F_CODDIS','D06_CODDIS'}} , D0F->( IndexKey(1) ) )
	oModel:GetModel('325D0F'):SetOptional(.T.)

	oModel:SetPrimaryKey({'D06_FILIAL', 'D06_CODDIS'})
Return oModel
//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel('WMSA325')
Local oStructD06 := FWFormStruct(2,'D06',,.F.)
Local oStructD07 := FWFormStruct(2,'D07',,.F.)
Local oStructD08 := FWFormStruct(2,'D08',,.F.)
Local oStructD09 := FWFormStruct(2,'D09',,.F.)
Local oView  := Nil

	oStructD07:AddField('D07_STATUS','00','' ,'',Nil,'GET','@BMP',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructD08:AddField('D08_STATUS','00','' ,'',Nil,'GET','@BMP',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
	oStructD09:AddField('D09_STATUS','00','' ,'',Nil,'GET','@BMP',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)

	oStructD07:RemoveField('D07_SDOC')
	oStructD09:RemoveField('D09_QTQAD2') // Campo não usado

	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessário caso estamos mundando o ID no View.

	oView:AddField('325D06' ,oStructD06)
	oView:CreateHorizontalBox('MASTER' , 15,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox('DETAIL' , 85,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	oView:CreateFolder('IDFOLDER','DETAIL')

	oView:AddSheet('IDFOLDER', 'IDSHEET01', STR0006) // Produtos
	oView:CreateHorizontalBox('DETAIL_1', 100,,,'IDFOLDER', 'IDSHEET01')
	oView:AddGrid('325D09', oStructD09)
	oView:SetOwnerView('325D09', 'DETAIL_1')

	oView:AddSheet('IDFOLDER', 'IDSHEET02', STR0007) // Documentos
	oView:CreateHorizontalBox('DETAIL_2', 100,,,'IDFOLDER', 'IDSHEET02')
	oView:AddGrid('325D07', oStructD07)
	oView:SetOwnerView('325D07', 'DETAIL_2')

	oView:AddSheet('IDFOLDER', 'IDSHEET03', STR0008) // Pedidos/Planos
	oView:CreateHorizontalBox('DETAIL_3', 100,,,'IDFOLDER', 'IDSHEET03')
	oView:AddGrid('325D08', oStructD08)
	oView:SetOwnerView('325D08', 'DETAIL_3')

	// Associa um View a um box
	oView:SetOwnerView('325D06', 'MASTER')

	oView:SetUseCursor(.F.)
Return oView
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325Fil
Filtro de seleção do browse
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA325Fil()
Local cFiltro := ""
	cFiltro := "@ D06_CODDIS >= '"+MV_PAR01+"' AND D06_CODDIS <= '"+MV_PAR02+"' "
	cFiltro += " AND D06_DTGDIS >= '"+DTOS(MV_PAR03)+"' AND D06_DTGDIS <= '"+DTOS(MV_PAR04)+"'"

	If MV_PAR05 != 4
		cFiltro += " AND D06_SITDIS = '"+AllTrim(Str(MV_PAR05))+"' "
	EndIf
Return cFiltro

Static Function CommitMdl(oModel)
Local lRet := .T.
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		lRet := WMS325UPD1(oModel:GetModel('325D07'),.F.)
		If lRet
			lRet := WMS325UPPL(oModel:GetModel('325D08'),.F.)
		EndIf
	EndIf
	If lRet
		FwFormCommit(oModel)
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} SelFiltro
Selecionar filtro F12
@author felipe.m
@since 12/12/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
//----------------------------------------------------------
Static Function SelFiltro()
	Pergunte('WMSA325',.T.)
	oBrwD06:SetFilterDefault(WMSA325Fil() )
	oBrwD06:Refresh()
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} StatusView
Status de documentos/pedidos/produtos relacionados a distribuição
@author felipe.m
@since 19/09/2014
@version 1.0
@param cTab, character, (Tabela [D07,D08,09])
/*/
//----------------------------------------------------------
Static Function StatusView(cTab)
Local cStatus := ""
	Do Case
		Case cTab == "D07"
			If WMSA325SDE() == "1"     // NF Nao Classificada
				cStatus := "BR_VERDE"
			ElseIf WMSA325SDE() == "2" // NF Normal
				cStatus := "BR_VERMELHO"
			ElseIf WMSA325SDE() == "3" // NF Bloqueada
				cStatus := "BR_LARANJA"
			ElseIf WMSA325SDE() == "4" // NF Bloqueada s/classf.
				cStatus := "BR_VIOLETA"
			ElseIf WMSA325SDE() == "5" // NF de Compl. IPI
				cStatus := "BR_AZUL"
			ElseIf WMSA325SDE() == "6" // NF de Compl. ICMS
				cStatus := "BR_MARROM"
			ElseIf WMSA325SDE() == "7" // NF de Compl. Preco/Frete
				cStatus := "BR_ROSA"
			ElseIf WMSA325SDE() == "8" // NF de Beneficiamento
				cStatus := "BR_CINZA"
			ElseIf WMSA325SDE() == "9" // NF de Devolucao
				cStatus := "BR_AMARELO"
			ElseIf WMSA325SDE() == "10" // NF Bloq. para Conferencia
				cStatus := "BR_PRETO"
			ElseIf WMSA325SDE() == "11" // Cancelada
				cStatus := "BR_BRANCO"
			EndIf

		Case cTab == "D08"
			If D08->D08_QTDDIS == 0 // Não distribuido
				cStatus := "BR_VERMELHO"
			ElseIf D08->D08_QTDDIS <> D08->D08_QTDVEN // Saldo a distribuir
				cStatus := "BR_AMARELO"
			ElseIf D08->D08_QTDDIS == D08->D08_QTDVEN // Distribuido
				cStatus := "BR_AZUL"
			EndIf

		Case cTab == "D09"
			If D09->D09_QTDDIS == 0 // Não distribuido
				cStatus := "BR_VERMELHO"
			ElseIf D09->D09_QTDDIS <> D09->D09_QTDADI // Saldo a distribuir
				cStatus := "BR_AMARELO"
			ElseIf D09->D09_QTDDIS == D09->D09_QTDADI // Distribuido
				cStatus := "BR_AZUL"
			EndIf
	EndCase
Return cStatus
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325MAN
Manutenção permitida somente para distribuições em aberto.
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA325MON()
Local aAreaD06 := D06->( GetArea() )
Local aAreaD07 := D07->( GetArea() )
Local aAreaD08 := D08->( GetArea() )
Local aAreaD09 := D09->( GetArea() )

	Processa({ || ProcRegua(0),FWExecView(STR0014,"WMSA325A", MODEL_OPERATION_INSERT ) },STR0038) // Montagem // Processando Pré-Notas...
	
	If Select("SELD08") > 0
		DelTabTmp("SELD08")
	EndIf
	
	If Select("SELSD1") > 0
		DelTabTmp("SELSD1")
	EndIf
	
	RefreshBrw()

	// Reposiciona cursor
	RestArea(aAreaD06)
	RestArea(aAreaD07)
	RestArea(aAreaD08)
	RestArea(aAreaD09)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325MAN
Manutenção permitida somente para distribuições em aberto.
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA325MAN()
Local aAreaD06 := D06->( GetArea() )
Local aAreaD07 := D07->( GetArea() )
Local aAreaD08 := D08->( GetArea() )
Local aAreaD09 := D09->( GetArea() )
Local lOk := .F.

	If D06->D06_SITDIS != "1"
		WmsMessage(STR0020,WMSA32501,5/*MSG_HELP*/)// Somente distribuições 'Abertas' permitem manutenção!
	Else

		FWExecView(STR0015,"WMSA325A", MODEL_OPERATION_UPDATE ,, { || lOk := .T. } ,, ) // Manutenção

		If lOk
			RefreshBrw()
		EndIf

	EndIf

	// Reposiciona cursor
	RestArea(aAreaD06)
	RestArea(aAreaD07)
	RestArea(aAreaD08)
	RestArea(aAreaD09)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325VIS
Visualização da montagem da distribuição
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//---------------------------------------------------------
Function WMSA325VIS()
Local aAreaD06 := D06->( GetArea() )
Local aAreaD07 := D07->( GetArea() )
Local aAreaD08 := D08->( GetArea() )
Local aAreaD09 := D09->( GetArea() )
Local lOk := .F.

	FWExecView(STR0016, 'WMSA325', MODEL_OPERATION_VIEW, , { || lOk := .T. },,,,{ || .T. } ) // Visualizar

	If lOk
		RefreshBrw()
	EndIf

	RestArea(aAreaD06)
	RestArea(aAreaD07)
	RestArea(aAreaD08)
	RestArea(aAreaD09)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325CAN
Cancelamento permitido somente para montagens distribuidas.
@author felipe.m
@since 19/09/2014
@version 2.0
/*/
//----------------------------------------------------------
Function WMSA325CAN()
Local aAreaD06 := D06->( GetArea() )
Local aAreaD07 := D07->( GetArea() )
Local aAreaD08 := D08->( GetArea() )
Local aAreaD09 := D09->( GetArea() )
Local aAreaSF1 := SF1->( GetArea() )
Local lRet     := .T.
Local oModel   := FwLoadModel('WMSA325')
Local oModelD07:= Nil

	If D06->D06_SITDIS != "2"
		WmsMessage(STR0022,WMSA32502,5/*MSG_HELP*/) // Somente montagens 'Distribuídas' podem ser 'Canceladas'!
	Else
		cQuery := " SELECT D07.D07_DOC"
		cQuery += "   FROM "+RetSqlName('D07')+" D07"
		cQuery += "  INNER JOIN "+RetSqlName('SD1')+" SD1"
		cQuery += "     ON SD1.D1_FILIAL  = '"+xFilial('SD1')+"'"
		cQuery += "    AND SD1.D1_DOC     = D07.D07_DOC"
		cQuery += "    AND SD1.D1_SERIE   = D07.D07_SERIE"
		cQuery += "    AND SD1.D1_FORNECE = D07.D07_FORNEC"
		cQuery += "    AND SD1.D1_LOJA    = D07.D07_LOJA"
		cQuery += "    AND SD1.D1_COD     = D07.D07_PRODUT"
		cQuery += "    AND SD1.D1_ITEM    = D07.D07_ITEM"
		cQuery += "    AND SD1.D1_TES    <> ' '"
		cQuery += "    AND SD1.D_E_L_E_T_ = ' '"
		cQuery += "  WHERE D07.D07_FILIAL = '"+xFilial('D07')+"'"
		cQuery += "    AND D07.D07_CODDIS = '"+D06->D06_CODDIS+"'"
		cQuery += "    AND D07.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSD1 := GetNextAlias()
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSD1,.F.,.T.)
		If (cAliasSD1)->(!EoF())
			WmsMessage(STR0044,WMSA32510,5/*MSG_HELP*/) //Não é possível cancelar distribuições de documentos já classificados.
			lRet := .F.
		EndIf
		If lRet
			If WmsQuestion(STR0023,WMSA32503) // Os documentos/pedidos vinculados à distribuição poderão ser utilizados em outra montagem!
				oModel:SetOperation( MODEL_OPERATION_UPDATE )
				oModel:Activate()
				If oModel:GetModel("325D08"):Length() > 0
					Processa({ || ProcRegua(0), RetSD1Orig(oModel:GetModel('325D07'))}, STR0039) // Cancelando distribuição...
				EndIf
				oModel:DeActivate()
				RefreshBrw()
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaD06)
	RestArea(aAreaD07)
	RestArea(aAreaD08)
	RestArea(aAreaD09)
	RestArea(aAreaSF1)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325EXC
Exclusão permitida somente para distribuições em aberto.
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA325EXC()
Local aAreaD06 := D06->( GetArea() )
Local aAreaD07 := D07->( GetArea() )
Local aAreaD08 := D08->( GetArea() )
Local aAreaD09 := D09->( GetArea() )
Local aAreaSD1 := SD1->( GetArea() )
Local lOk := .F.

	If D06->D06_SITDIS != "1"
		WmsMessage(STR0024,WMSA32505,5/*MSG_HELP*/) // Somente distribuições 'Abertas' permitem exclusão!
	Else
		FWExecView(STR0025, 'WMSA325', MODEL_OPERATION_DELETE, , { || lOk := .T. },,,,{ || .T. } ) // Exclusão

		If lOk
			RefreshBrw()
		EndIf

	EndIf
	RestArea(aAreaD06)
	RestArea(aAreaD07)
	RestArea(aAreaD08)
	RestArea(aAreaD09)
	RestArea(aAreaSD1)
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} RefreshBrw
Atualiza Browses
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Static Function RefreshBrw()
	oBrwD06:Refresh()
	oBrwD07:Refresh()
	oBrwD08:Refresh()
	oBrwD09:Refresh()
	UpdGraf()
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} UpdGraf
Atualização dos gráficos relacionados a quantidade Distribuída e A Distribuir por produto.
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Static Function UpdGraf()
Local aAreaD09 := D09->(GetArea())
Local cAliD09 := GetNextAlias()
Local nQtdAdi := 0
Local nQtdDis := 0

	cQuery := "SELECT D09_QTDADI, D09_QTDDIS"
	cQuery +=  " FROM "+RETSQLNAME('D09')
	cQuery += " WHERE D09_FILIAL = '"+xFilial("D09")+"'"
	cQuery +=   " AND D09_CODDIS = '"+D09->D09_CODDIS+"'"
	cQuery +=   " AND D09_PRODUT = '"+D09->D09_PRODUT+"'"
	cQuery +=   " AND D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliD09,.F.,.T.)
	If !(cAliD09)->(Eof())
		nQtdAdi := (cAliD09)->D09_QTDADI
		nQtdDis := (cAliD09)->D09_QTDDIS
	EndIf
	(cAliD09)->(dbCloseArea())
	// Força uma area ativa para reconstruir o grafico
	dbSelectArea("D06")
	oTmpGrf:Reset()

	oTmpGrf:AddSerie(STR0012, nQtdDis ) // Distribuído
	oTmpGrf:AddSerie(STR0026, nQtdAdi - nQtdDis ) // A Distribuir

	oTmpGrf:Build()

	RestArea(aAreaD09)
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} WMSA325SDE
Regra do status do documento de entrada
@author felipe.m
@since 19/09/2014
@version 1.0
/*/
//----------------------------------------------------------
Function WMSA325SDE()
Local aAreaAnt := GetArea()
Local cStatus := ""
	dbSelectArea('SF1')
	SF1->(dbSetOrder(1))
	If SF1->( dbSeek(xFilial('SF1')+D07->( D07_DOC+SubStr(D07_SERIE,1,3)+D07_FORNEC+D07_LOJA )) )

		Do Case
			Case Empty(SF1->F1_STATUS) .And.((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON))
				cStatus := "1"

			Case ((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON)) .And. F1_TIPO == "N" .And. (SF1->F1_STATUS <> "B" .And. SF1->F1_STATUS <> "C")
				cStatus := "2"

			Case SF1->F1_STATUS == "B"
				cStatus := "3"

			Case SF1->F1_STATUS == "C"
				cStatus := "4"

			Case ((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON)) .And. SF1->F1_TIPO == "P"
				cStatus := "5"

			Case ((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON)) .And. SF1->F1_TIPO == "I"
				cStatus := "6"

			Case ((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON)) .And. SF1->F1_TIPO == "C"
				cStatus := "7"

			Case ((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON)) .And. SF1->F1_TIPO == "B"
				cStatus := "8"

			Case ((SF1->F1_STATCON $ "1|4") .Or. Empty(SF1->F1_STATCON)) .And. SF1->F1_TIPO == "D"
				cStatus := "9"

			Case !(SF1->F1_STATCON $ "1|4") .And. !Empty(SF1->F1_STATCON)
				cStatus := "10"
		EndCase
	Else
		cStatus := "11"
	EndIf
	RestArea(aAreaAnt)
	cResLeg := cStatus
Return cStatus

Static Function RetSD1Orig(oModelD07)
Local lRet     := .F.
Local oDistrib := Nil

	dbSelectArea('SF1')
	SF1->(dbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA

	//Posiciona no cabeçalho da NF, para a utilização do método de cancelamento da distribuição
	If SF1->(dbSeek(xFilial('SF1')+oModelD07:GetValue("D07_DOC")+oModelD07:GetValue("D07_SERIE")+oModelD07:GetValue("D07_FORNEC")+oModelD07:GetValue("D07_LOJA")))
		oDistrib := WMSDTCDistribuicaoProdutosPedidosItens():New()
		lRet := oDistrib:CancelDist(SF1->(Recno()),D06->D06_CODDIS,.F.)
	EndIf
Return lRet

/*/{Protheus.doc} WMSVldD07
(Realiza validações nos itens da NF para verificar se foram distribuidos pelo WMS)
@author evaldo.cevinscki
@since 17/10/2014
@version 1.0
@param nAcao, numéico, (1= Checa o serviço; 2=Valida alteração da Quantidade; 3=Valida alteração do codigo do produto; 4=Valida alteração do armazém)
@param aDados, array, (Array com aCols a ser validado)
@param nLin, numéico, (Linha do aCols a ser validado)
@param aHeader, array, (Array do Cabeçalho)
/*/
Function WMSVldD07(nAcao,aDados,nLin,aHeader)
Local lRet       := .T.
Local lAchou     := .F.
Local nPosCodDis := aScan(aHeader,{|x|AllTrim(x[2])=="D1_CODDIS"})
Local nPosCod    := aScan(aHeader,{|x|AllTrim(x[2])=="D1_COD"})
Local nPosItem   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_ITEM'})
Local nPosQtd    := aScan(aHeader,{|x|AllTrim(x[2])=="D1_QUANT"})
Local nPosServ   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_SERVIC'})
Local nPosArmz   := aScan(aHeader,{|x|Alltrim(x[2])=='D1_LOCAL'})
Local nQtdDis    := aDados[nLin][nPosQtd]
Local cCodDis    := aDados[nLin][nPosCodDis]
Local cProduto   := aDados[nLin][nPosCod]
Local cItem      := aDados[nLin][nPosItem]
Local cServico   := IIF(nPosServ > 0,aDados[nLin][nPosServ],"") //Tratamento realizado para o projeto de retira de campos da tela
Local cArmazem   := aDados[nLin][nPosArmz]

	D07->(dbSetOrder(1))
	// Verifica se o item do documento est?vinculado a uma distribuição
	// D07_FILIAL+D07_CODDIS+D07_DOC+D07_SERIE+D07_FORNEC+D07_LOJA+D07_PRODUT+D07_ITEM
	If D07->(dbSeek(xFilial("D07")+cCodDis+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cProduto+cItem))
		D06->(dbSetOrder(1))
		D06->(dbSeek(xFilial("D06")+D07->D07_CODDIS))
		// Se a situação da distribuicao for diferente de "Cancelada"
		If D06->D06_SITDIS != "3"
			// Verifica se o item foi separado
			If QtdComp(nQtdDis) == QtdComp(D07->D07_QTDDIS) .AND. D07->D07_QTDDIS != 0
				If nAcao == 1
					If Empty(cServico)
						WmsMessage(STR0040,WMSA32506,1) // Há itens sem serviço informado. Informe um serviço de Distribuição de Cross-Docking de Entrada
						lRet := .F.
					Else
						DC5->(dbSetOrder(1))
						DC5->(dbSeek(xFilial('DC5')+cServico))
						lAchou := .F.
						Do while DC5->(!Eof()) .And. !lAchou .And. DC5->(DC5_FILIAL+DC5_SERVIC) == xFilial("DC5")+cServico
							If DC5->DC5_OPERAC == '2'
								lAchou := .T.
							EndIf
							DC5->(dbSkip())
						EndDo
						If !lAchou
							WmsMessage(STR0041,WMSA32507,1) // Há itens com serviço inválido. Informe um serviço de Distribuição de Cross-Docking de Entrada
							lRet	 := .F.
						EndIf
					EndIf
				ElseIf nAcao == 2
					If QtdComp(GDFieldGet("D1_QUANT",nLin,.T.)) <> QtdComp(nQtdDis)
						WmsMessage(STR0042,WMSA32508,1) // Item foi distribuido e não pode ter a quantidade alterada.
						lRet := .F.
					EndIf
				ElseIf nAcao == 3
					If GDFieldGet("D1_COD",nLin,.T.) <> cProduto
						WmsMessage(STR0043,WMSA32509,1) // Item foi distribuido e não pode ter o produto alterado.
						lRet := .F.
					EndIf
				ElseIf nAcao == 4
					If GDFieldGet("D1_LOCAL",nLin,.T.) <> cArmazem
						WmsMessage(STR0045,WMSA32511,1) // Item foi distribuido e não pode ter o armazém alterado.
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet
