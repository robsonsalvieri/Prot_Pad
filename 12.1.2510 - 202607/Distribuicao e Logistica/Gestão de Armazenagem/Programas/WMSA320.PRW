#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "WMSA320.CH"

#DEFINE WMSA32001 "WMSA32001"
#DEFINE WMSA32002 "WMSA32002"
#DEFINE WMSA32003 "WMSA32003"
#DEFINE WMSA32004 "WMSA32004"
#DEFINE WMSA32005 "WMSA32005"
#DEFINE WMSA32006 "WMSA32006"
#DEFINE WMSA32007 "WMSA32007"
#DEFINE WMSA32008 "WMSA32008"
#DEFINE WMSA32009 "WMSA32009"
#DEFINE WMSA32010 "WMSA32010"
#DEFINE WMSA32011 "WMSA32011"
#DEFINE WMSA32012 "WMSA32012"
#DEFINE WMSA32013 "WMSA32013"
#DEFINE WMSA32014 "WMSA32014"
#DEFINE WMSA32015 "WMSA32015"
#DEFINE WMSA32016 "WMSA32016"
#DEFINE WMSA32017 "WMSA32017"
#DEFINE WMSA32018 "WMSA32018"
#DEFINE WMSA32019 "WMSA32019"
#DEFINE WMSA32020 "WMSA32020"
#DEFINE WMSA32021 "WMSA32021"
#DEFINE WMSA32022 "WMSA32022"
#DEFINE WMSA32023 "WMSA32023"
#DEFINE WMSA32024 "WMSA32024"
#DEFINE WMSA32025 "WMSA32025"
#DEFINE WMSA32026 "WMSA32026"
#DEFINE WMSA32027 "WMSA32027"
#DEFINE WMSA32028 "WMSA32028"
#DEFINE WMSA32029 "WMSA32029"
#DEFINE WMSA32030 "WMSA32030"

#DEFINE WMSA32083 "WMSA32083"
#DEFINE WMSA32084 "WMSA32084"
#DEFINE WMSA32085 "WMSA32085"
#DEFINE WMSA32086 "WMSA32086"
#DEFINE WMSA32087 "WMSA32087"
#DEFINE WMSA32088 "WMSA32088"
#DEFINE WMSA32089 "WMSA32089"
#DEFINE WMSA32090 "WMSA32090"
#DEFINE WMSA32091 "WMSA32091"
#DEFINE WMSA32092 "WMSA32092"
#DEFINE WMSA32093 "WMSA32093"
#DEFINE WMSA32094 "WMSA32094"
#DEFINE WMSA32095 "WMSA32095"
#DEFINE WMSA32096 ""
#DEFINE WMSA32097 ""
#DEFINE WMSA32098 "WMSA32098"

Static __lWmsNew  := SuperGetMV("MV_WMSNEW",.F.,.F.)
Static __cWmsLcFt := SuperGetMV('MV_WMSLCFT',.F.,'') // Local de falta
Static __cWmsLcEx := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Static __cWmsEnEx := SuperGetMV('MV_WMSENEX',.F.,"") // Endereço de excesso
Static oBrwDCW, oBrwDCX, oBrwDCY, oBrwDCZ, oTimer
//----------------------------------------------------------
// Embarques
/*/{Protheus.doc} WMSA320
Embarques para conferencia

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/07/12
@version 1.0
@obs     Embarques para conferencia

/*/
//----------------------------------------------------------
Function WMSA320()
Local lWmsCRD  := SuperGetMV("MV_WMSCRD",.F.,.F.)
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)
Local lRefresh := .T.

Private nTipConf  := 1
Private cArmazem  := Space(TamSX3("BE_LOCAL")[1])
Private cEndereco := Space(TamSX3("BE_LOCALIZ")[1])
Private cIdUnit   := "" 
Private cTipUni   := "" 
Private lUnitiza  := .F.
Private lSolEnd   := .T.

	If !IntWMS() .And. !lWmsCRD
		WmsMessage(STR0074,WMSA32028,1) // Permitida utilização somente com Integração com o WMS (MV_INTWMS) ou integração com a conferência de recebimento WMS (MV_WMSCRD)!
		Return
	EndIf

	If __lWmsNew .And. (__cWmsLcFt == __cWmsLcEx) .And. !Empty(__cWmsLcFt)
		WmsMessage(STR0111,WMSA32027,1) // "Armazém de falta e excesso não podem ser iguais. MV_WMSLCFT e MV_WMSLCEX"
		Return
	EndIf
	
	If !WmsX312118("DCY","DCY_LOCAL") .Or. !WmsX312118("DCZ","DCZ_LOCAL")
		WmsMessage("Para o correto funcionamento desta rotina favor seguir os procedimentos descritos em: "+CRLF+"http://tdn.totvs.com/pages/viewpage.action?pageId=286507592",WMSA32084,1) // "Armazém de falta e excesso não podem ser iguais. MV_WMSLCFT e MV_WMSLCEX"
		Return
	EndIf

	cIdUnit := Space(TamSX3("D0R_IDUNIT")[1])
	cTipUni := Space(TamSX3("D0R_CODUNI")[1])

	If Pergunte("WMSA320",.T.)

		// Avalia se os parâmetros estão preenchidos e informa o usuário
		WMSA320Par()

		lRefresh := (MV_PAR05 < 4) // Salva parametros do Pergunte

		// Ajusta o dicionário de dados para tratar a nova opção 4=Conferido com divergência
		oBrwDCW := FWMBrowse():New()
		oBrwDCW:SetAlias('DCW')                               // Alias da tabela utilizada
		oBrwDCW:SetAmbiente(.F.)
		oBrwDCW:SetWalkThru(.F.)
		oBrwDCW:SetMenuDef('WMSA320')                         // Nome do fonte onde esta a função MenuDef
		oBrwDCW:SetDescription(STR0001)                       // Conferência Recebimento
		oBrwDCW:AddLegend("DCW_SITEMB=='1'",'RED'   ,STR0003) // Não iniciado
		If __lWmsNew
			oBrwDCW:AddLegend("DCW_SITEMB=='2'",'ORANGE',STR0004) // Volume em Andamento
			oBrwDCW:AddLegend("DCW_SITEMB=='3'",'VIOLET',STR0005) // Volume Conferido
			oBrwDCW:AddLegend("DCW_SITEMB=='4'",'BROWN' ,STR0039) // Volume Conferido com Divergência
		EndIf
		oBrwDCW:AddLegend("DCW_SITEMB=='5'",'YELLOW',STR0062) // Produto em Andamento
		oBrwDCW:AddLegend("DCW_SITEMB=='6'",'GREEN' ,STR0063) // Produto Conferido
		oBrwDCW:AddLegend("DCW_SITEMB=='7'",'BLUE'  ,STR0064) // Produto Conferido com Divergência de Quantidade
		oBrwDCW:AddLegend("DCW_SITEMB=='8'",'BLACK'  ,STR0123) // Produto conferido com divergência de lote
		oBrwDCW:SetFilterDefault("@"+Filtro())
		oBrwDCW:SetParam({|| SelFiltro(.T.) })
		oBrwDCW:SetTimer({|| Iif(lRefresh,SelFiltro(.F.),.T.) }, Iif(nTime<=0, 3600, nTime) * 1000)
		oBrwDCW:DisableDetails()
		oBrwDCW:SetFixedBrowse(.T.)
		oBrwDCW:SetProfileID('1')
		oBrwDCW:Activate()

	EndIf

Return Nil
//----------------------------------------------------------
Static Function DetRecebto(nOpc)
Local oSize, oDlg, oMaster, oFolder
Local aFolders := {}
Local aButtons := {}
Local aPosSize := {}
Local nTime    := SuperGetMV('MV_WMSREFS', .F., 10) // Tempo em Segundos para Refresh da tela de Execucao de Servicos (Default = 10 segundos)

	DCW->( dbSetOrder(1) )
	// Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar
	// Cria Enchoice
	oSize:AddObject( "MASTER", 100, 60, .T., .F. ) // Adiciona enchoice
	oSize:AddObject( "DETAIL", 100, 70, .T., .T. ) // Adiciona enchoice

	// Dispara o calculo
	oSize:Process()

	// Desenha a dialog
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM ;
	oSize:aWindSize[1],oSize:aWindSize[2] TO ;
	oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	// Cria as variáveis de memória usadas pela Enchoice
	RegToMemory("DCW",.F.,.F.)
	// Monta a Enchoice
	aPosSize := {oSize:GetDimension("MASTER","LININI"),;
				 oSize:GetDimension("MASTER","COLINI"),;
				 oSize:GetDimension("MASTER","LINEND"),;
				 oSize:GetDimension("MASTER","COLEND")}
	oMaster := MsMGet():New("DCW",DCW->(Recno()),2,,,,,aPosSize,,3,,,,oDlg,,.F./*lMemoria*/,.T.)

	// Documentos // Produtos // Operadores
	aFolders := {STR0015,STR0017,STR0020}

	// Monta o Objeto Folder
	aPosSize := {oSize:GetDimension("DETAIL","LININI"),; // Pos.x
					oSize:GetDimension("DETAIL","COLINI"),; // Pos.y
					oSize:GetDimension("DETAIL","XSIZE"),;  // Size.x
					oSize:GetDimension("DETAIL","YSIZE")}   // Size.y
	oFolder := TFolder():New(aPosSize[1],aPosSize[2],aFolders,aFolders,oDlg,,,,.T.,.T.,aPosSize[3],aPosSize[4])

	// Define Browse Documento
	oBrwDCX := FWMBrowse():New()
	oBrwDCX:SetOwner(oFolder:aDialogs[1])
	oBrwDCX:SetDescription(STR0015) // Documento
	oBrwDCX:SetAlias('DCX')
	oBrwDCX:SetAmbiente(.F.)
	oBrwDCX:SetWalkThru(.F.)
	oBrwDCX:SetMenuDef('')
	If nOpc == 2 // Modificação
		oBrwDCX:AddButton(STR0016, {|| AddDocCof()},, 3, 0) // Incluir
		oBrwDCX:AddButton(STR0008, {|| DelDocCof()},, 5, 0) // Excluir
		If __lWmsNew
			oBrwDCX:AddButton(STR0054, {|| InforVolu()},, 4, 0) // Informar Volumes
		EndIf
	EndIf
	oBrwDCX:DisableDetails()
	oBrwDCX:SetFixedBrowse(.T.)
	oBrwDCX:SetProfileID('2')
	oBrwDCX:SetFilterDefault("@DCX_FILIAL='"+xFilial('DCX')+"' AND DCX_EMBARQ='"+DCW->DCW_EMBARQ+"'")
	oBrwDCX:Activate()

	DCY->(DbSetOrder(2))
	// Define Browse Produto
	oBrwDCY := FWMBrowse():New()
	oBrwDCY:SetOwner(oFolder:aDialogs[2])
	oBrwDCY:SetDescription(STR0017) // Produtos
	oBrwDCY:SetAlias('DCY')
	oBrwDCY:SetAmbiente(.F.)
	oBrwDCY:SetWalkThru(.F.)
	oBrwDCY:SetMenuDef('')
	If nOpc == 2 // Modificação
		oBrwDCY:AddButton(STR0035, {|| oTimer:DeActivate(), LibCofPrd(), oTimer:Activate()},, 4, 0) // Liberar produto
		oBrwDCY:AddButton(STR0040, {|| oTimer:DeActivate(), EstCofPrd(), oTimer:Activate()},, 4, 0) // Estornar produto
		oBrwDCY:AddButton(STR0041, {|| oTimer:DeActivate(), EstPrdCof(), oTimer:Activate()},, 4, 0) // Estornar item
		oBrwDCY:AddButton(STR0053, {|| oTimer:DeActivate(), ChkArm(1) , oTimer:Activate()},, 4, 0) // Liberar Arm. Produto
	EndIf
	oBrwDCY:AddLegend("DCY->DCY_QTCONF == 0 .AND. DCW->DCW_SITEMB < '6'",'RED'                  ,STR0003)  // Não iniciado
	oBrwDCY:AddLegend("DCY->DCY_QTORIG <> DCY->DCY_QTCONF .AND. DCW->DCW_SITEMB == '5'",'YELLOW',STR0062)  // Produto em Andamento
	oBrwDCY:AddLegend("DCY->DCY_QTORIG <> DCY->DCY_QTCONF .AND. DCW->DCW_SITEMB >= '6'",'BLUE'  ,STR0064)  // Produto Conferido com Divergência
	oBrwDCY:AddLegend("DCY->DCY_QTORIG == DCY->DCY_QTCONF",'GREEN'                              ,STR0063)  // Produto Conferido
	oBrwDCY:DisableDetails()
	oBrwDCY:SetFixedBrowse(.T.)
	oBrwDCY:SetProfileID('3')
	oBrwDCY:SetFilterDefault("@DCY_FILIAL='"+xFilial('DCY')+"' AND DCY_EMBARQ='"+DCW->DCW_EMBARQ+"'")
	oBrwDCY:Activate()

	// Define Browse Conferência
	DCZ->(dbSetOrder(2))
	oBrwDCZ := FWMarkBrowse():New()
	oBrwDCZ:SetOwner(oFolder:aDialogs[3])
	oBrwDCZ:SetAlias('DCZ')
	oBrwDCZ:SetAmbiente(.F.)
	oBrwDCZ:SetWalkThru(.F.)
	oBrwDCZ:SetMenuDef('')
	If nOpc == 2 // Modificação
		oBrwDCZ:AddButton(STR0042, {|| oTimer:DeActivate(), RegCofOpe(), oTimer:Activate()},, 3, 0) // Conferir Item
		oBrwDCZ:AddButton(STR0041, {|| oTimer:DeActivate(), EstOpeCof(), oTimer:Activate()},, 5, 0) // Estornar Item
		oBrwDCZ:AddButton(STR0043, {|| oTimer:DeActivate(), EstCofOpe(), oTimer:Activate()},, 5, 0) // Estornar Operador
	EndIf
	oBrwDCZ:DisableDetails()
	oBrwDCZ:SetFixedBrowse(.T.)
	oBrwDCZ:SetDescription(STR0020) // Operadores
	oBrwDCZ:SetProfileID('5')
	oBrwDCZ:SetFilterDefault("@DCZ_FILIAL='"+xFilial('DCZ')+"' AND DCZ_EMBARQ='"+DCW->DCW_EMBARQ+"'")
	oBrwDCZ:Activate()

	If nOpc == 2
		AAdd(aButtons, {'FINAL',{|| oTimer:DeActivate(), Wms320FiCo(), oTimer:Activate()}, STR0011}) // Finalizar Conferência
		AAdd(aButtons, {'REABR',{|| oTimer:DeActivate(), Wms320ReCo(), oTimer:Activate()},STR0012}) // Reabrir Conferência
		AAdd(aButtons, {'ESTOR',{|| oTimer:DeActivate(), EstCofRec(), oTimer:Activate()}, STR0014}) // Estornar Conferência
		AAdd(aButtons, {'LIBER',{|| oTimer:DeActivate(), ChkArm(2), oTimer:Activate()}, STR0053})  // Liberar Arm. Produto
	EndIf

	oTimer:= TTimer():New((Iif(nTime <= 0, 3600, nTime) * 1000),{|| BrwRefresh() },oDlg)
	oTimer:Activate()

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpcA := 1,oDlg:End()},{|| nOpcA := 2,oDlg:End()},,aButtons)
Return Nil
//----------------------------------------------------------
//Função responsável por efetuar a atualização da tela
//----------------------------------------------------------
Static Function BrwRefresh(lGoTop)
Local aAreaDCW := DCW->(GetArea())
Default lGoTop := .F.
	// Força a releitura da situação do recebimento
	DCW->( DbSeek(xFilial('DCW')+DCW->DCW_EMBARQ) )
	M->DCW_SITEMB := DCW->DCW_SITEMB
	If __lWmsNew
		M->DCW_QTVOLU := DCW->DCW_QTVOLU
		M->DCW_QTDIFE := DCW->DCW_QTVOLU - DCW->DCW_QTCONF
	EndIf
	oBrwDCX:Refresh(lGoTop)

	DCY->(dbSetOrder(2))
	oBrwDCY:Refresh(lGoTop)

	DCZ->(dbSetOrder(2))
	oBrwDCZ:Refresh(lGoTop)

	RestArea(aAreaDCW)
Return .T.
//----------------------------------------------------------
// MenuDef
//----------------------------------------------------------
Static Function MenuDef()
Private aRotina  := {}

	// Adiciona botões do browse
	ADD OPTION aRotina TITLE STR0006 ACTION 'StaticCall(WMSA320,AddCofRec)'    OPERATION 3  ACCESS 0 DISABLE MENU // Montagem
	ADD OPTION aRotina TITLE STR0008 ACTION 'StaticCall(WMSA320,DelCofRec)'    OPERATION 5  ACCESS 0 DISABLE MENU // Excluir
	ADD OPTION aRotina TITLE STR0007 ACTION 'StaticCall(WMSA320,DetRecebto,2)' OPERATION 2  ACCESS 0 DISABLE MENU // Monitor
	ADD OPTION aRotina TITLE STR0034 ACTION 'StaticCall(WMSA320,DetRecebto,4)' OPERATION 2  ACCESS 0 DISABLE MENU // Visualizar
	ADD OPTION aRotina TITLE STR0013 ACTION 'WMSR325()'                        OPERATION 10 ACCESS 0 DISABLE MENU // Relatório CHECK-OUT
	If __lWmsNew
		ADD OPTION aRotina TITLE STR0055 ACTION 'StaticCall(WMSA320,ConferVolu)'   OPERATION 10 ACCESS 0 DISABLE MENU // Conferir Volumes
	EndIf

	// Ponto de entrada utilizado para manipular as opções do array aRotina
	If ExistBlock("WMSA320M")
		ExecBlock("WMSA320M",.F.,.F.)
	EndIf
Return aRotina
//----------------------------------------------------------
// ModelDef
//----------------------------------------------------------
Static Function ModelDef()
Local oModel    := Nil
Local oStructDCW := FWFormStruct(1,'DCW')
Local oStructDCX := FWFormStruct(1,'DCX')
Local oStructDCY := FWFormStruct(1,'DCY')
Local oStructDCZ := FWFormStruct(1,'DCZ')
Local nMostra    := 0 // Quando mostras todos os dados do embarqye
Local cDocto     := DCX->DCX_DOC
Local cSerie     := DCX->DCX_SERIE
Local cForn      := DCX->DCX_FORNEC
Local cLoja      := DCX->DCX_LOJA
Local cPrdOri    := DCY->DCY_PRDORI
Local cProduto   := DCY->DCY_PROD
Local cLote      := DCY->DCY_LOTE
Local cSubLote   := DCY->DCY_SUBLOT
Local cOperador  := DCZ->DCZ_OPER
Local cPrdOConf  := DCZ->DCZ_PRDORI
Local cProdConf  := DCZ->DCZ_PROD
Local cLoteConf  := DCZ->DCZ_LOTE
Local cSLotConf  := DCZ->DCZ_SUBLOT
Local cIdUnitiz  := DCZ->DCZ_IDUNIT
Local cArmazem   := DCZ->DCZ_LOCAL
	Do Case
		Case IsInCallStack('DelDocCof')
			nMostra := 1 // Regra para mostrar as informações quando elimina documento
		Case IsInCallStack('EstCofPrd')
			nMostra := 2 // Regra para mostrar as informações quando estorno do produto
		Case IsInCallStack('EstPrdCof')
			nMostra := 3 // Regra para mostrar as informações quando estorno do produto/lote/sub-lote
		Case IsInCallStack('EstCofOpe')
			nMostra := 4 // Regra para mostrar as informações quando estorno do operador
		Case IsInCallStack('EstOpeCof')
			nMostra := 5 // Regra para mostrar as informações quando estorno do operador/produto/lote/sub-lote
	EndCase
	// Status Produtos
	oStructDCY:AddField('' ,'','DCY_VSTATUS' , 'C',15,0,,,,.T.,{|| StatusProd()},,,.T.) // STATUS
	oStructDCY:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

	// cID     Identificador do modelo
	// bPre    Code-Block de pre-edição do formulário de edição. Indica se a edição esta liberada
	// bPost   Code-Block de validação do formulário de edição
	// bCommit Code-Block de persistência do formulário de edição
	// bCancel Code-Block de cancelamento do formulário de edição
	oModel := MPFormModel():New('WMSA320', /*bPre*/, /*bPost*/, {|oModel| GravaDados(oModel)}/*bCommit*/, /*bCancel*/)
	// cId          Identificador do modelo
	// cOwner       Identificador superior do modelo
	// oModelStruct Objeto com  a estrutura de dados
	// bPre         Code-Block de pré-edição do formulário de edição. Indica se a edição esta liberada
	// bPost        Code-Block de validação do formulário de edição
	// bLoad        Code-Block de carga dos dados do formulário de edição
	oModel:AddFields('WMSA320DCW', Nil, oStructDCW,/*bPre*/,/*bPost*/,/*bLoad*/)

	oModel:AddGrid( 'WMSA320DCX', 'WMSA320DCW'  , oStructDCX, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( 'WMSA320DCX', {{'DCX_FILIAL',"xFilial('DCX')"},{'DCX_EMBARQ','DCW_EMBARQ'}} , DCX->( IndexKey(1) ) )
	If nMostra == 1
		oModel:GetModel( 'WMSA320DCX' ):SetLoadFilter({{'DCX_DOC' ,"'"+cDocto+"'",1},{'DCX_SERIE' ,"'"+cSerie+"'",1},{'DCX_FORNEC' ,"'"+cForn+"'",1},{'DCX_LOJA' ,"'"+cLoja+"'",1}})
	EndIf
	oModel:GetModel('WMSA320DCX'):SetOnlyView( .T. )
	oModel:GetModel('WMSA320DCX'):SetOptional( .T. )

	oModel:AddGrid( 'WMSA320DCY', 'WMSA320DCW'  , oStructDCY, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( 'WMSA320DCY', {{'DCY_FILIAL',"xFilial('DCY')"},{'DCY_EMBARQ','DCW_EMBARQ'}} , DCY->( IndexKey(1) ) )
	Do Case
		Case nMostra == 2 // Filtra os dados do embarque pelo produto origem/produto selecionado
			oModel:GetModel( 'WMSA320DCY' ):SetLoadFilter({{'DCY_PRDORI' ,"'"+cPrdOri+"'",1},{'DCY_PROD' ,"'"+cProduto+"'",1},{'DCY_QTCONF','0',2}})
		Case nMostra == 3 // Filtra os dados do embarque pelo produto origem/produto/lote/sub-lote selecionado
			oModel:GetModel( 'WMSA320DCY' ):SetLoadFilter({{'DCY_PRDORI' ,"'"+cPrdOri+"'",1},{'DCY_PROD' ,"'"+cProduto+"'",1},{'DCY_LOTE' ,"'"+cLote+"'",1},{'DCY_SUBLOT' ,"'"+cSubLote+"'",1},{'DCY_QTCONF','0',2}})
	EndCase
	oModel:GetModel('WMSA320DCY'):SetOptional( .T. )

	oModel:AddGrid( 'WMSA320DCZ', 'WMSA320DCW'  , oStructDCZ, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	oModel:SetRelation( 'WMSA320DCZ', {{'DCZ_FILIAL',"xFilial('DCZ')"},{'DCZ_EMBARQ','DCW_EMBARQ'}} , DCZ->( IndexKey(1) ) )
	Do Case
		Case nMostra == 2 // Filtra os dados da conferencia do embarque pelo produto selecionado
			If cPrdOri == cProduto
				oModel:GetModel( 'WMSA320DCZ' ):SetLoadFilter({{'DCZ_PRDORI' ,"'"+cPrdOri+"'",1}})
			Else
				oModel:GetModel( 'WMSA320DCZ' ):SetLoadFilter({{'DCZ_PRDORI' ,"'"+cPrdOri+"'",1},{'DCZ_PROD' ,"'"+cProduto+"'",1}})
			EndIf
		Case nMostra == 3 .Or. nMostra == 6 // Filtra os dados da conferencia do embarque pelo produto/lote/sub-lote selecionado
			If cPrdOri == cProduto
				oModel:GetModel( 'WMSA320DCZ' ):SetLoadFilter({{'DCZ_PRDORI' ,"'"+cPrdOri+"'",1},{'DCZ_LOTE' ,"'"+cLote+"'",1},{'DCZ_SUBLOT' ,"'"+cSubLote+"'",1}})
			Else
				oModel:GetModel( 'WMSA320DCZ' ):SetLoadFilter({{'DCZ_PRDORI' ,"'"+cPrdOri+"'",1},{'DCZ_PROD' ,"'"+cProduto+"'",1},{'DCZ_LOTE' ,"'"+cLote+"'",1},{'DCZ_SUBLOT' ,"'"+cSubLote+"'",1}})
			EndIf

		Case nMostra == 4 // Filtra os dados da conferencia do embarque pelo operador selecionado
			oModel:GetModel( 'WMSA320DCZ' ):SetLoadFilter({{'DCZ_OPER' ,"'"+cOperador+"'",1}})
		Case nMostra == 5 // Filtra os dados da conferencia do embarque pelo operador/produto/lote/sub-lote selecionado
			oModel:GetModel( 'WMSA320DCZ' ):SetLoadFilter({{'DCZ_OPER' ,"'"+cOperador+"'",1},{'DCZ_PRDORI' ,"'"+cPrdOConf+"'",1},{'DCZ_PROD' ,"'"+cProdConf+"'",1},{'DCZ_LOTE' ,"'"+cLoteConf+"'",1},{'DCZ_SUBLOT' ,"'"+cSLotConf+"'",1},{'DCZ_IDUNIT' ,"'"+cIdUnitiz+"'",1},{'DCZ_LOCAL',"'"+cArmazem+"'"}})
	EndCase
	oModel:GetModel('WMSA320DCZ'):SetOptional( .T. )

	oModel:SetPrimaryKey({'DCW_FILIAL', 'DCW_EMBARQ'})
	oModel:SetActivate({|oModel| ActiveModel(oModel)})
Return oModel
//----------------------------------------------------------
// ViewDef
//----------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel('WMSA320')
Local oStructDCW := FWFormStruct(2,'DCW',,.F.)
Local oStructDCX := FWFormStruct(2,'DCX',,.F.)
Local oStructDCY := FWFormStruct(2,'DCY',,.F.)
Local oStructDCZ := FWFormStruct(2,'DCZ',,.F.)
Local oView      := FWFormView():New()
Local nMostra    := 0
	Do Case
		Case IsInCallStack('DelDocCof')
			nMostra := 1 // Regras para quando for incluido um documento para o embarque já existente
		Case IsInCallStack('EstCofPrd')
			nMostra := 2 // Regra para quando houver um estorno por produto
		Case IsInCallStack('EstPrdCof')
			nMostra := 3 // Regra para quando houver um estorno por produto/lote/sub-lote
		Case IsInCallStack('EstCofOpe')
			nMostra := 4 // Regra para quando houver um estorno por operador
		Case IsInCallStack('EstOpeCof')
			nMostra := 5 // Regra para quando houver um estorno por operador/produto/lote/sub-lote
	EndCase
	oStructDCW:RemoveField('DCW_FILIAL')
	oStructDCW:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	// Monta Status do produto
	oStructDCY:AddField('DCY_VSTATUS','01','' ,'',Nil,'GET','@BMP',Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)

	oModel:GetModel('WMSA320DCY'):SetOnlyView(.T.)
	oModel:GetModel('WMSA320DCZ'):SetOnlyView(.T.)
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessário caso estamos mundando o ID no View.

	oView:AddField('WMSA320DCW' ,oStructDCW)
	oView:CreateHorizontalBox('MASTER' , 15,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox('DETAIL' , 85,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateFolder('IDFOLDER','DETAIL')
	// Mostra exclusão do documento ou geral
	If nMostra == 0 .Or. nMostra == 1
		oView:AddSheet('IDFOLDER', 'IDSHEET01', STR0015) // Documento
		oView:CreateHorizontalBox('DETAIL_1', 100,,,'IDFOLDER', 'IDSHEET01')
		oView:AddGrid('WMSA320DCX', oStructDCX)
		oView:SetOwnerView('WMSA320DCX', 'DETAIL_1')
	EndIf
	// Mostra se for estorno produto, estorno produto/lote/sub-lote ou geral
	If nMostra == 0 .Or. nMostra == 2 .Or. nMostra == 3
		oView:AddSheet('IDFOLDER', 'IDSHEET02', STR0017) // Produto
		oView:CreateHorizontalBox('DETAIL_2', 100,,,'IDFOLDER', 'IDSHEET02')
		oView:AddGrid('WMSA320DCY', oStructDCY)
		oView:SetOwnerView('WMSA320DCY', 'DETAIL_2')
	EndIf
	// Mostra se for estorno operador, estorno operador/produto/lote/sub-lote ou geral
	If nMostra == 0 .Or. nMostra >= 2
		oView:AddSheet('IDFOLDER', 'IDSHEET03', STR0020) // Operadores
		oView:CreateHorizontalBox('DETAIL_3', 100,,,'IDFOLDER', 'IDSHEET03')
		oView:AddGrid('WMSA320DCZ', oStructDCZ)
		oView:SetOwnerView('WMSA320DCZ', 'DETAIL_3')
	EndIf
	// Associa um View a um box
	oView:SetOwnerView('WMSA320DCW', 'MASTER')
	oView:SetUseCursor(.F.)
Return oView
//----------------------------------------------------------
// Atribuições ativação
/*/{Protheus.doc} ActiveModel
Atribuições ativação

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Atribuições ativação

/*/
//----------------------------------------------------------
Static Function ActiveModel(oModel)
Local nOp := (oModel:getOperation())
	If nOp == 4
		// Atribui o mesmo valor da situação somente para permitir a confirmação - senão da mensagem que não há alteração
		oModel:LoadValue('WMSA320DCW' , 'DCW_SITEMB', oModel:GetValue('WMSA320DCW', 'DCW_SITEMB')) // Para forçar a simulação de alteração
	EndIf
Return .T.
//----------------------------------------------------------
// Gravação dados
/*/{Protheus.doc} GravaDados
Gravação dados

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Gravação dados

/*/
//----------------------------------------------------------
Static Function GravaDados(oModel)
Local nOp         := oModel:getOperation()
Local nCont       := 0
Local nTipo
Local oModelDCY   := oModel:GetModel('WMSA320DCY')
Local oModelDCX   := oModel:GetModel('WMSA320DCX')
Local oModelDCZ   := oModel:GetModel('WMSA320DCZ')
Local lRet        := .T.
Local aEstUnitiz  := {}
	Do Case
		// Eliminar documento
		Case IsInCallStack('DelDocCof')
			nTipo := 4
		// Estorno produto
		Case IsInCallStack('EstCofPrd')
			nTipo := 5
		// Estorno produto/lote/sub-lote
		Case IsInCallStack('EstPrdCof')
			nTipo := 6
		// Estorno operador
		Case IsInCallStack('EstCofOpe')
			nTipo := 7
		// Estorno operador/produto/lote/sub-lote
		Case IsInCallStack('EstOpeCof')
			nTipo := 8
	EndCase
	If nOp == 4 .And. nTipo == 4
		oModelDCX:DeleteLine(.T.,.T.)
	EndIf
	//Estorno
 	If lRet .And. nOp == 4
		If nTipo == 6 //Estorno item
		 	Aadd(aEstUnitiz,{oModelDCY:GetValue("DCY_EMBARQ"),oModelDCY:GetValue("DCY_PRDORI"),oModelDCY:GetValue("DCY_PROD"),oModelDCY:GetValue("DCY_LOTE"),oModelDCY:GetValue("DCY_SUBLOT"),,,,})
		ElseIf nTipo == 5 //Estorna produto
			Aadd(aEstUnitiz,{oModelDCY:GetValue("DCY_EMBARQ"),oModelDCY:GetValue("DCY_PRDORI"),oModelDCY:GetValue("DCY_PROD"),,,,,,})
		ElseIf nTipo == 8  .And. !Empty(oModelDCZ:GetValue("DCZ_IDUNIT")) //Etorna item operador
			Aadd(aEstUnitiz,{oModelDCZ:GetValue("DCZ_EMBARQ"),oModelDCZ:GetValue("DCZ_PRDORI"),oModelDCZ:GetValue("DCZ_PROD"),oModelDCZ:GetValue("DCZ_LOTE"),oModelDCZ:GetValue("DCZ_SUBLOT"),oModelDCZ:GetValue("DCZ_IDUNIT"),oModelDCZ:GetValue("DCZ_OPER"),,})
		ElseIf nTipo == 7 //Estornar Operador
			Aadd(aEstUnitiz,{oModelDCZ:GetValue("DCZ_EMBARQ"),,,,,,oModelDCZ:GetValue("DCZ_OPER"),,})
		EndIf
	EndIf
	// Alteração para estorno de produto ou operador conferido
	// Quando estorna o operador, sempre estorna o produto conferido
 	If nOp == 4 .And. nTipo >= 5
		If !oModelDCZ:IsEmpty()
			For nCont := 1 To oModelDCZ:Length()
				oModelDCZ:SetLine( nCont )
				oModelDCZ:DeleteLine(,.T.)
			Next
		EndIf
	EndIf
	// Deve chamar a função de gravação adicional no bloco de código para garantir a integridade da transação
	lRet := FwFormCommit(oModel, , {|oModel,cID,cAlias| PosAtuMVC(nOp,nTipo,oModel,cID,cAlias,aEstUnitiz)},,{|oModel| InTSAtuMVC(oModel)})
Return lRet
//-------------------------------------------------------------------
// Função para atualização das informações complementares com base no
// documento que está sendo manipulado no processo de conferência
//-------------------------------------------------------------------
Static Function PosAtuMVC(nOp,nTipo,oModel,cID,cAlias,aEstUnitiz)
Local cEmbarque := ""
Local cDocto    := ""
Local cSerie    := ""
Local cFornec   := ""
Local cLoja     := ""
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
Local cAliasConf:= ""
Local cLocExc   := SuperGetMV('MV_WMSLCEX',.F.,'') // Local de excesso
Local lConfFis  := SuperGetMV("MV_CONFFIS",.F.,"N") == "S"
Local aTamSx3   := TamSx3('D1_QUANT')
Local nQtMult   := 0
Local aAreaDCY  := DCY->(GetArea())
Local cSeek     := ""

	// Alterações baseadas no documento
	If cID == 'WMSA320DCX' .And. ;
		(nOp == 5 .Or. (nOp == 4 .And. oModel:IsDeleted())) // Se está excluindo os documentos
		cEmbarque := oModel:GetValue("DCX_EMBARQ")
		cDocto    := oModel:GetValue("DCX_DOC")
		cSerie    := oModel:GetValue("DCX_SERIE")
		cFornec   := oModel:GetValue("DCX_FORNEC")
		cLoja     := oModel:GetValue("DCX_LOJA")
		If __lWmsNew
			nVolume   := oModel:GetValue("DCX_QTVOLU")
		EndIf
		// Se na modificação apenas excluiu um documento
		If (nOp == 4 .And. oModel:IsDeleted())
			// Exclui os itens da conferência, com base no documento excluído
			cQuery := "SELECT D1_ITEM,"
			cQuery +=       " D1_LOCAL,"
			cQuery +=       " D1_COD,"
			cQuery +=       " D1_LOTECTL,"
			cQuery +=       " D1_NUMLOTE,"
			cQuery +=       " D1_QUANT"
			cQuery +=  " FROM "+RetSqlName('SD1')
			cQuery += " WHERE D1_FILIAL  = '"+xFilial('SD1')+"'"
			cQuery +=   " AND D1_DOC = '"+cDocto+"'"
			cQuery +=   " AND D1_SERIE = '"+cSerie+"'"
			cQuery +=   " AND D1_FORNECE = '"+cFornec+"'"
			cQuery +=   " AND D1_LOJA = '"+cLoja+"'"
			If !Empty(cLocExc)
				cQuery += " AND ( D1_TES = '"+PadR("",TamSx3("D1_TES")[1])+"' AND D1_LOCAL <> '"+cLocExc+"' OR D1_TES <> '"+PadR("",TamSx3("D1_TES")[1])+"')" // Não pode ser do local de excesso
			EndIf
			cQuery +=   " AND D1_QUANT > 0"
			cQuery +=   " AND D1_OP = ' '"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY D1_ITEM"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			TCSetField(cAliasQry,'D1_QUANT','N',aTamSx3[1],aTamSx3[2])

			DCY->(DbSetOrder(1)) // DCY_FILIAL+DCY_EMBARQ+DCY_PRDORI+DCY_PROD+DCY_LOTE+DCY_SUBLOT
			D0K->(DbSetOrder(1)) // D0K_FILIAL+D0K_EMBARQ+D0K_DOC+D0K_SERIE+D0K_FORNEC+D0K_LOJA+D0K_PROD+D0K_ITEM
			While lRet .And. (cAliasQry)->(!Eof())
				cAliasConf := GetNextAlias()
				BeginSql Alias cAliasConf
				SELECT DCY.R_E_C_N_O_ RECNODCY
			  	  FROM %Table:DCY% DCY
				 WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
			   	   AND DCY.DCY_EMBARQ = %Exp:DCW->DCW_EMBARQ%
			   	   AND DCY.DCY_PRDORI = %Exp:(cAliasQry)->D1_COD%
				   AND DCY.%NotDel%
				EndSql
				While (cAliasConf)->(!EoF())
					DCY->(DbGoTo((cAliasConf)->RECNODCY))
					If DCY->DCY_PROD+DCY->DCY_LOTE+DCY->DCY_SUBLOT == (cAliasQry)->D1_COD+(cAliasQry)->D1_LOTECTL+(cAliasQry)->D1_NUMLOTE
						RecLock("DCY",.F.)
						If QtdComp(DCY->DCY_QTCONF) == 0 .And. QtdComp(DCY->DCY_QTORIG - (cAliasQry)->D1_QUANT) <= 0
							DCY->(DbDelete())
						Else
							DCY->DCY_QTORIG -= (cAliasQry)->D1_QUANT
						EndIf
						DCY->(MsUnlock())
					ElseIf DCY->DCY_LOTE+DCY->DCY_SUBLOT == (cAliasQry)->D1_LOTECTL+(cAliasQry)->D1_NUMLOTE
						nQtMult := IIf(__lWmsNew,Posicione('D11',3,xFilial('D11')+DCY->DCY_PRDORI+DCY->DCY_PROD,'D11->D11_QTMULT'),1)
						RecLock("DCY",.F.)
						If QtdComp(DCY->DCY_QTCONF) == 0 .And. QtdComp(DCY->DCY_QTORIG - ((cAliasQry)->D1_QUANT*nQtMult)) <= 0
							DCY->(DbDelete())
						Else
							DCY->DCY_QTORIG -= (cAliasQry)->D1_QUANT * nQtMult
						EndIf
						DCY->(MsUnlock())
					EndIf
					(cAliasConf)->(DbSkip())
				EndDo
				(cAliasConf)->(DbCloseArea())
				(cAliasQry)->(DbSkip())
			EndDo
			(cAliasQry)->(DbCloseArea())
		EndIf
		// Exclui o relacionamento dos itens do documento com a conferência
		If lRet .And. D0K->(DbSeek(cSeek:=xFilial('D0K')+DCW->DCW_EMBARQ+cDocto+cSerie+cFornec+cLoja))
			While lRet .And. D0K->(!Eof() .And. D0K_FILIAL+D0K_EMBARQ+D0K_DOC+D0K_SERIE+D0K_FORNEC+D0K_LOJA == cSeek)
				RecLock("D0K",.F.)
				D0K->(DbDelete())
				D0K->(MsUnlock())
				D0K->(DbSkip())
			EndDo
		EndIf
		// Atualizando a situação da nota fiscal para eliminar NF Bloq. para Conferencia
		If lRet .And. (lRet := SF1->(DbSeek(xFilial("SF1")+cDocto+cSerie+cFornec+cLoja)))
			RecLock("SF1",.F.)
			If lConfFis
				SF1->F1_STATCON := "0"
			Else
				SF1->F1_STATCON := " "
			EndIf
			SF1->(MsUnlock())
		EndIf
		//Atualizando as ordens de serviço do WMS para bloquear o processo
		If lRet .And. !DocLibDCF(cDocto,cSerie,cFornec,cLoja)
			lRet := .F.
		EndIf
		//Atualizando a quantidade total de volumes
		If lRet .And. __lWmsNew
			If nVolume > 0
				RecLock('DCW',.F.)
				DCW->DCW_QTVOLU := IIF((DCW->DCW_QTVOLU-nVolume)<0, 0, DCW->DCW_QTVOLU-nVolume)
				DCW->(MsUnlock())
			EndIf
			//Estorna o documento de conferencia nas ordens de serviços do WMS
			If lRet .And. !GrvCofDCFxD12(cDocto,cSerie,cFornec,cLoja,Space(6))
				lRet := .F.
			EndIf
		EndIf
		//Refaz a D0Q quando for um documento de entrada
		If WmsX212118("D0Q")
			If lRet .And. (nOp == 4 .Or. nOp == 5)
				GeraD0Q(cDocto,cSerie,cFornec,cLoja)
			EndIf
		EndIf
	EndIf
	//Estorna unitizador
	If Len(aEstUnitiz) > 0
		WMSA320EST(aEstUnitiz[1][1],aEstUnitiz[1][2],aEstUnitiz[1][3],aEstUnitiz[1][4],aEstUnitiz[1][5],aEstUnitiz[1][6],aEstUnitiz[1][7],aEstUnitiz[1][8],aEstUnitiz[1][9])
	EndIf

	RestArea(aAreaDCY)
Return lRet

Static Function InTSAtuMVC(oModel)
Return A320COFDCY(oModel:GetModel("WMSA320DCZ"):GetValue("DCZ_EMBARQ"),,oModel:getOperation() == 4)
//----------------------------------------------------------
// Montagem embarque de conferencia
/*/{Protheus.doc} AddCofRec
Montagem embarque de conferencia

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Montagem embarque de conferencia

/*/
//----------------------------------------------------------
Static Function AddCofRec()
Local aAreaDCW := DCW->( GetArea() )
Local lOk      := .F.
	// Filtros seleção
	If Pergunte('WMSA320A',.T.)
		nTipConf := MV_PAR09
		If FWExecView(STR0006,'WMSA320A',3,,{ || .T. },,,,{ || .T. }) == 0 // Montagem
			oBrwDCW:Refresh() // Mantém no registro
			oBrwDCW:GoBottom(.F.) // Posiciona na conferência incluída
		EndIf
	EndIf
	// Reposiciona cursor
	RestArea(aAreaDCW)
Return .T.
//----------------------------------------------------------
// Elimina embarque de conferencia
/*/{Protheus.doc} DelCofRec
Elimina embarque de conferencia

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Elimina embarque de conferencia

/*/
//----------------------------------------------------------
Static Function DelCofRec()
Local aAreaDCW := DCW->( GetArea() )
Local lRet     := .T.
	If DCW->DCW_SITEMB <= "4"
		If FWExecView(STR0008,'WMSA320',5,,{ || .T. },,,,{ || .T. }) == 0 // Exclusão
			oBrwDCW:Refresh(.T.)
		EndIf
	Else
		WmsMessage(STR0030+CRLF+STR0049,WMSA32001,1) // Exclusão permitida somente para conferência não iniciada! // Estorne todo o processo de conferência do recebimento, para então excluir o processo.
		lRet := .F.
	EndIf
	// Reposiciona cursor
	RestArea(aAreaDCW)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} InforVolu
Informa a quantidade de volumes por nota fiscal de entrada

@author  Reinaldo Dias
@version P12
@Since   12/09/2015
@version 1.0
@obs     Montagem embarque de conferencia

/*/
//----------------------------------------------------------
Static Function InforVolu()
Local aAreaDCW := DCW->( GetArea() )
Local lOk      := .F.
	If DCW->DCW_SITEMB $ "1|3|4"
		If FWExecView(STR0054,'WMSA320C',MODEL_OPERATION_UPDATE,,{ || .T. },,,,{ || .T. }) == 0 // Informar Volumes
			 M->DCW_SITEMB := DCW->DCW_SITEMB
			 M->DCW_QTVOLU := DCW->DCW_QTVOLU
			 M->DCW_QTDIFE := DCW->DCW_QTVOLU - DCW->DCW_QTCONF
			oBrwDCW:Refresh()
			oBrwDCX:Refresh(.T.)
		EndIf
	ElseIf DCW->DCW_SITEMB == "2" //Volume em Andamento
		WmsMessage(STR0060,WMSA32002,1) //Conferência de volume em andamento. Finalize a conferência de volume primeiro.
		lRet := .F.
	ElseIf DCW->DCW_SITEMB > "4"
		WmsMessage(STR0061,WMSA32003,1) //Estorne a conferênica de produto para possibilitar informar a quantidade de volumes.
		lRet := .F.
	EndIf
	// Reposiciona cursor
	RestArea(aAreaDCW)
Return .T.

//----------------------------------------------------------
// Informa a quantidade de volumes conferida
/*/{Protheus.doc} ConferVolu
Informa a quantidade de volumes conferida

@author  Reinaldo Dias
@version P12
@Since   14/09/2015
@version 1.0
@obs     Montagem embarque de conferencia

/*/
//----------------------------------------------------------
Static Function ConferVolu()
Local oDlg      := Nil
Local oGet      := Nil
Local nQtVolCon := DCW->DCW_QTCONF
Local nOpc      := 0

	If DCW->DCW_SITEMB > "4"
		WmsMessage(STR0061,WMSA32004,1) //Estorne a conferênica de produto para possibilitar informar a quantidade de volumes.
		Return .F.
	EndIf
	
	RecLock('DCW',.F.)
	DCW->DCW_SITEMB := "2" // Volume em Andamento
	DCW->DCW_CODUSU := __cUserId
	DCW->(MsUnlock())
	
	DEFINE MSDIALOG oDlg TITLE STR0056 From 50,50 to 130,340 PIXEL  // Informar a quantidade de volumes conferido
	@ 06,05 SAY STR0057              SIZE 60,08 OF oDlg PIXEL  // Quantidade Volumes:
	@ 05,70 MSGET oGet VAR nQtVolCon SIZE 30,08 PICTURE PesqPict('DCW','DCW_QTCONF') OF oDlg PIXEL Valid(nQtVolCon >= 0)
	DEFINE SBUTTON FROM 21,070 TYPE 1 ACTION (nOpc := 1,oDlg:End()) ENABLE Of oDlg
	DEFINE SBUTTON FROM 21,110 TYPE 2 ACTION (,oDlg:End())          ENABLE Of oDlg
	ACTIVATE DIALOG oDlg CENTERED
	
	If nOpc == 1
		Reclock("DCW",.F.)
		DCW->DCW_QTCONF := nQtVolCon
		DCW->DCW_SITEMB := IIF(QtdComp(DCW->DCW_QTVOLU) == QtdComp(DCW->DCW_QTCONF),"3","4")
		DCW->DCW_CODUSU := __cUserId
		DCW->(MsUnLock())
		WmsMessage(IIF(DCW->DCW_SITEMB=="3",STR0058,STR0059),WMSA32005,1) //Conferência finalizada. // Conferência com divergência.
	 EndIf

Return .T.



//----------------------------------------------------------
// Estorno da conferencia do embarque
/*/{Protheus.doc} EstCofRec
Estorno da conferencia do embarque

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Estorno da conferencia do embarque
/*/
//----------------------------------------------------------
Static Function EstCofRec()
Local aAreaDCW   := DCW->( GetArea() )
Local cAliasConf := ""
Local lRet       := .T.
	If DCW->DCW_SITEMB == "5"
		If WmsQuestion(STR0018) // Confirma o estorno de todo o processo de conferência?
			Begin Transaction

			//Estorna Unitizadores
			WMSA320EST(DCW->DCW_EMBARQ)

			DCW->(DbSetOrder(1)) // DCW_FILIAL+DCW_EMBARQ
			DCY->(DbSetOrder(1)) // DCY_FILIAL+DCY_EMBARQ...
			DCZ->(DbSetOrder(1)) // DCZ_FILIAL+DCZ_EMBARQ...
			// Deleta a conferência do embarque
			If DCZ->(DbSeek(xFilial('DCZ')+DCW->DCW_EMBARQ))
				While DCZ->(!Eof()) .And. DCZ->DCZ_EMBARQ == DCW->DCW_EMBARQ
					RecLock('DCZ',.F.)
					DCZ->(DbDelete())
					DCZ->(MsUnlock())
					DCZ->(DbSkip())
				EndDo
			EndIf
			// Ajusta os itens conferidos do embarque
			cAliasConf := GetNextAlias()
			BeginSql Alias cAliasConf
				SELECT DCY.R_E_C_N_O_ RECNODCY
				  FROM %Table:DCY% DCY
				 WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
				   AND DCY.DCY_EMBARQ = %Exp:DCY->DCY_EMBARQ%
				   AND DCY.%NotDel%
			EndSql
			While (cAliasConf)->(!EoF())
				DCY->(DbGoTo((cAliasConf)->RECNODCY))
				RecLock('DCY',.F.)
				If QtdComp(DCY->DCY_QTORIG) > 0
					DCY->DCY_QTCONF := 0
				Else
					DCY->(DbDelete())
				EndIf
				DCY->(MsUnlock())
				(cAliasConf)->(DbSkip())
			EndDo
			(cAliasConf)->(DbCloseArea())

			// Volta as notas fiscais para o status de não conferidas
			lRet := Wm320BqSF1(DCW->DCW_EMBARQ) //Em Processo Conferencia
			// Marca o embarque como não iniciado
			If lRet
				RecLock('DCW',.F.)
				If !__lWmsNew
					DCW->DCW_SITEMB := "1"
				Else
					DCW->DCW_SITEMB := IIf(DCW->DCW_QTCONF>0,IIf(QtdComp(DCW->DCW_QTVOLU) == QtdComp(DCW->DCW_QTCONF),"3","4"),"1")
				EndIf
				DCW->(MsUnlock())
			EndIf
			If !lRet
				DisarmTransaction()
			EndIf
			DCY->(DBCommit())
			IF lRet 
	   			Atuqtdcy(DCW->DCW_EMBARQ,DCW->DCW_TPCONF)
			EndIf  
			End Transaction
			BrwRefresh(.T.)
		EndIf
		If lRet
			ChkArm(3)
		EndIf
	Else
		WmsMessage(STR0026+CRLF+STR0045,WMSA32006,1) // Estorno permitido somente para embarque em andamento! // Efetue a reabertura da conferência de recebimento para poder estornar o processo.
		lRet := .F.
	EndIf
	RestArea(aAreaDCW)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} Wms320ReCo
Reabertura da conferencia do embarque

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@obs     Reabertura da conferencia do embarque
/*/
//----------------------------------------------------------
Function Wms320ReCo()
Local aAreaDCW  := DCW->(GetArea())
Local aAreaDCY  := DCY->(GetArea())
Local aAreaDCZ  := DCZ->(GetArea())
Local aAreaDCX  := DCX->(GetArea())
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

	If DCW->DCW_SITEMB < "6"
		WmsMessage(STR0027,WMSA32008,1) // Reabertura permitida somente para recebimento conferido!
		lRet := .F.
	EndIf
	If lRet .And. DCW->DCW_TPCONF == '1'
		cQuery := "SELECT SD1.D1_TIPO_NF"
		cQuery +=  " FROM "+RetSqlName('D0K')+" D0K, "+RetSqlName('SD1')+" SD1"
		cQuery += " WHERE D0K.D0K_FILIAL  = '"+xFilial('D0K')+"'"
		cQuery +=   " AND D0K.D0K_EMBARQ  = '"+DCW->DCW_EMBARQ+"'"
		cQuery +=   " AND D0K.D_E_L_E_T_  = ' '"
		cQuery +=   " AND SD1.D1_FILIAL   = '"+xFilial('SD1')+"'"
		cQuery +=   " AND SD1.D1_DOC      = D0K.D0K_DOC"
		cQuery +=   " AND SD1.D1_SERIE    = D0K.D0K_SERIE"
		cQuery +=   " AND SD1.D1_FORNECE  = D0K.D0K_FORNEC"
		cQuery +=   " AND SD1.D1_LOJA     = D0K.D0K_LOJA"
		cQuery +=   " AND SD1.D1_COD      = D0K.D0K_PROD"
		cQuery +=   " AND SD1.D1_ITEM     = D0K.D0K_ITEM"
		cQuery +=   " AND SD1.D1_TES      <> ' '"
		cQuery +=   " AND SD1.D1_QUANT    > 0"
		cQuery +=   " AND SD1.D1_OP       = ' '"
		cQuery +=   " AND SD1.D_E_L_E_T_  = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(EoF())
			// Se for conferência gerada a partir de documentos integrados através do módulo SIGAEIC
			If !Empty((cAliasQry)->D1_TIPO_NF)
				// Este recebimento foi gerado com base em Pré-notas que, posteriormente, foram classificadas.
				// Caso você opte pela sua reabertura, ele passará a ser tratado como uma conferência de documentos classificados.
				// Tem certeza que deseja continuar?
				If WmsQuestion(STR0116+CRLF+CRLF+STR0117,WMSA32089)
					RecLock("DCW",.F.)
					DCW->DCW_TPCONF := "2"
					DCW->(MsUnLock())
				Else
					lRet := .F.
				EndIf
			Else
				WmsMessage(STR0099,WMSA32083,1) // Conferência realizada como Prenota, não permitida a reabertura com o documento classificado.
				lRet := .F.
			EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
	If lRet .And. DCW->DCW_TPCONF == '2'
		cQuery := " SELECT DCF.DCF_ID"
		cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
		cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery +=    " AND DCF.DCF_CODREC = '"+DCW->DCW_EMBARQ+"'"
		cQuery +=    " AND DCF.DCF_STSERV NOT IN ('0','1')"
		cQuery +=    " AND DCF.DCF_ORIGEM = 'D0R'"
		cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(EoF())
			WmsMessage(STR0110,WMSA32098,1) // Conferência possui ordens de serviço executadas, não permitida a reabertura.
			lRet := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

	If lRet
		If !(lRet := ChkArm(4))
			WmsMessage(STR0028,WMSA32007,1) // Reabertura não permitida, recebimento possui documento já armazenado!
		EndIf 
	EndIf
		
	If lRet
	 	If __lAutoma .Or. WmsQuestion(STR0019) // Confirma a reabertura do processo de conferência?
	 		Processa({|| lRet := Wm320RbCof(DCW->DCW_EMBARQ,DCW->DCW_TPCONF)}, STR0068 , STR0067 + "...", .T.) // Reabrindo Conferência // Aguarde
	 	EndIf
		If lRet .And. !__lAutoma
			BrwRefresh(.T.)
		EndIf
	EndIf
	RestArea(aAreaDCX)
	RestArea(aAreaDCZ)
	RestArea(aAreaDCY)
	RestArea(aAreaDCW)
Return lRet
//----------------------------------------------------------
// Finalizar conferencia do embarque
/*/{Protheus.doc} Wms320FiCo
Finalizar conferencia do embarque

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Finalizar conferencia do embarque

/*/
//----------------------------------------------------------
Function Wms320FiCo()
Local aAreaDCW   := DCW->(GetArea())
Local aAreaDCY   := DCY->(GetArea())
Local lEncerra   := .F.
Local lDiverge   := .F.
Local lDiverLote := .F.
Local lRet       := .T.
Local cAliasConf := ""
	If DCW->DCW_SITEMB <> "5"
		WmsMessage(STR0025,WMSA32009,1) // Finalização permitida somente para embarque em andamento!
		Return .F.
	EndIf

	If !__lAutoma
		If !WmsQuestion(STR0022) // Confirma a finalização do processo de conferência?
			Return .F.
		EndIf
	EndIf

	// Força a releitura do registro
	DCW->( DbSeek(xFilial('DCW')+DCW->DCW_EMBARQ) )
	If DCW->DCW_SITEMB $ '6|7|8'
		WmsMessage(STR0032,WMSA32010,1) // Conferencia já finalizada por outro processo!
		Return .F.
	EndIf

	// Verifica se algum item foi conferido
	cAliasConf := GetNextAlias()
	BeginSql Alias cAliasConf
		SELECT DCY.R_E_C_N_O_ RECNODCY
		  FROM %Table:DCY% DCY
		 WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
		   AND DCY.DCY_EMBARQ = %Exp:DCW->DCW_EMBARQ%
		   AND DCY.DCY_QTCONF > 0
		   AND DCY.%NotDel%
	EndSql
	If (cAliasConf)->(!EoF())
		lEncerra := .T.
	EndIf
	(cAliasConf)->(DbCloseArea())

	If !lEncerra
		WmsMessage(STR0023,WMSA32011,1) // Finalização não permitida. Não foi conferido nenhuma quantidade.
		Return .F.
	EndIf

	// Deve verificar se existe algum produto PAI que foi registrado com falta
	// Caso exista deve avaliar se existe algum FILHO que foi conferido com 
	// quantidade a maior que o multiplo necessário para compor o PAI.
	If __lWmsNew
		If !ValCmpExc(DCW->DCW_EMBARQ)
			Return .F.
		EndIf
	EndIf

	// Verifica se algum item foi conferido
	cAliasConf := GetNextAlias()
	BeginSql Alias cAliasConf
		SELECT DCY.R_E_C_N_O_ RECNODCY
		  FROM %Table:DCY% DCY
		 WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
		   AND DCY.DCY_EMBARQ = %Exp:DCW->DCW_EMBARQ%
		   AND DCY.DCY_QTORIG <> DCY.DCY_QTCONF
		   AND DCY.%NotDel%
	EndSql
	If (cAliasConf)->(!EoF())
		lDiverge := .T.
	EndIf
	(cAliasConf)->(DbCloseArea())

	If lDiverge
		// Identifica como uma divergência de lote, quando não existir diferença entre a quantidade conferida com a quantidade esperada para o produto
		cAliasConf := GetNextAlias()
		BeginSql Alias cAliasConf
			SELECT DCY.DCY_PROD
			  FROM %Table:DCY% DCY
			 WHERE DCY.DCY_FILIAL = %xFilial:DCY%
			   AND DCY.DCY_EMBARQ = %Exp:DCW->DCW_EMBARQ%
			   AND DCY.DCY_PROD = DCY.DCY_PRDORI
			   AND DCY.%NotDel%
			 GROUP BY DCY.DCY_PROD
			HAVING SUM(DCY.DCY_QTORIG) <> SUM(DCY.DCY_QTCONF)
		EndSql
		If (cAliasConf)->(EoF())
			lDiverLote := .T.
		EndIf
		(cAliasConf)->(DbCloseArea())
	EndIf

	If lDiverLote .And. !__lAutoma
		If !WmsQuestion(STR0124) // Foram encontradas divergências entre os lotes conferidos, sem diferença entre quantidades. Confirma encerramento?
			RestArea(aAreaDCY)
			RestArea(aAreaDCW)
			Return .F.
		EndIf
	ElseIf lDiverge .And. !__lAutoma
		If !WmsQuestion(STR0125) // Foram encontradas divergencias de quantidades na contagem. Confirma encerramento?
			RestArea(aAreaDCY)
			RestArea(aAreaDCW)
			Return .F.
		EndIf
	EndIf

	// Verifica se todos os parametros estão preechidos quando pelo menos um está parametrizado
	If lDiverge .And. !Wm320ClPar() .And. !(Wm320MovEx() .And. Wm320MovFt()) .And. !__lAutoma
		If !WmsQuestion(STR0112,WMSA32029) // "Os parâmetros da conferência estão incompletos! Os tratamentos de falta e excesso podem não ser realizados. Deseja continuar mesmo assim?"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		Processa({|| lRet := A320FINCOF(DCW->DCW_EMBARQ,DCW->DCW_TPCONF,lDiverge,lDiverLote)}, STR0069, STR0067 + "...", .T.) // Finalizando Conferência // Aguarde
	EndIf

	If !__lAutoma .And. !IsTelNet()
		If lRet
			BrwRefresh(.T.)
		Else
			WmsMessage(STR0044,WMSA32012,2) // Não foi possível finalizar a conferência.
		EndIf
	EndIf

RestArea(aAreaDCY)
RestArea(aAreaDCW)
Return lRet
//----------------------------------------------------------
// Inclusão do documento
/*/{Protheus.doc} AddDocCof
Inclusão do documento

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Inclusão do documento

/*/
//----------------------------------------------------------
Static Function AddDocCof()
Local aAreaDCW := DCW->( GetArea() )
	If DCW->DCW_SITEMB < "6"
		// Filtros seleção
		If Pergunte('WMSA320A',.T.)
			nTipConf := IIF(!Empty(DCW->DCW_TPCONF),Val(DCW->DCW_TPCONF),1)
			If nTipConf <> MV_PAR09
				WmsMessage(STR0094+CRLF+WmsFmtMsg(STR0095,{{"[VAR01]",IIF(nTipConf == 1,STR0096,STR0097)}}),WMSA32030,1) //Tipo da conferência solicitada difere da conferência de recebimento. // Serão filtrados os documentos do tipo [VAR01] //Documento Entrada //Pré-Nota
			Endif
			If FWExecView(STR0006,'WMSA320A',4,,{ || .T. },,,,{ || .T. }) == 0 // Montagem
				BrwRefresh(.T.)
				oBrwDCW:Refresh() // Mantém no registro
			EndIf
		EndIf
	Else
		WmsMessage(STR0024+CRLF+STR0037,WMSA32013,1) // Recebimento conferido, operação não permitida! // Efetue a reabertura da conferência de recebimento para poder incluir um novo documento.
	EndIf
	RestArea(aAreaDCW)
Return .T.
//----------------------------------------------------------
// Exclusão do documento
/*/{Protheus.doc} DelDocCof
Exclusão do documento

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Exclusão do documento

/*/
//----------------------------------------------------------
Static Function DelDocCof()
Local aAreaDCW := DCW->( GetArea() )
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := ""
Local cCountDCX := 0
Local lRet      := .T.
	If DCW->DCW_SITEMB < "6"
		cQuery := "SELECT COUNT(*) DCX_CONT "
		cQuery +=  " FROM "+RetSqlName("DCX")
		cQuery += " WHERE DCX_FILIAL = '"+xFilial("DCX")+"'"
		cQuery +=   " AND DCX_EMBARQ = '"+DCW->DCW_EMBARQ+"'"
		cQuery +=   " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DBUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		cCountDCX := (cAliasQry)->DCX_CONT
		(cAliasQry)->( DbCloseArea() )

		If cCountDCX > 1
			If FWExecView(STR0008, 'WMSA320', 4, , { || .T. },,,,{ || .T. } ) == 0 // Exclusão
				BrwRefresh(.T.)
				oBrwDCW:Refresh() // Mantém no registro
			EndIf
		Else
			WmsMessage(STR0029+CRLF+STR0048,WMSA32014,1) // Exclusão documento não permitida, exclua o recebimento!
			lRet := .F.
		EndIf
	Else
		WmsMessage(STR0024+CRLF+STR0050,WMSA32015,1) // Recebimento conferido, operação não permitida! // Efetue a reabertura da conferência de recebimento para poder excluir o documento atual.
		lRet := .F.
	EndIf

	RestArea(aAreaAnt)
	RestArea(aAreaDCW)
Return lRet
//----------------------------------------------------------
// Estorna conferencia do produto
/*/{Protheus.doc} EstCofPrd
Estorna conferencia do produto

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Estorna conferencia do produto

/*/
//----------------------------------------------------------
Static Function EstCofPrd()
Local aAreaDCW := DCW->( GetArea() )
	If DCW->DCW_SITEMB == "5"
		If DCY->DCY_QTCONF <> 0
			If FWExecView(STR0040, 'WMSA320', 4, , { || .T. },,,,{ || .T. } ) == 0 // Estornar produto
				ChkArm(5)
			EndIf
		Else
			WmsMessage(STR0031+CRLF+STR0047,WMSA32016,1) // Não há quantidade conferida para o produto! // Escolha outro produto que possua quantidade conferida.
		EndIf
	Else
		WmsMessage(STR0026+CRLF+STR0045,WMSA32017,1) // Estorno permitido somente para recebimento em andamento! // Efetue a reabertura da conferência de recebimento para poder estornar o processo.
	EndIf
	BrwRefresh()
	RestArea(aAreaDCW)
Return .T.
//----------------------------------------------------------
// Estorna conferencia do produto, lote e sublote
/*/{Protheus.doc} EstPrdCof
Estorna conferencia do produto, lote e sublote

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Estorna conferencia do produto, lote e sublote

/*/
//----------------------------------------------------------
Static Function EstPrdCof()
Local aAreaDCW := DCW->( GetArea() )
Local lRet  := .T.
	If DCW->DCW_SITEMB == "5"
		If DCY->DCY_QTCONF <> 0
			If FWExecView(STR0041, 'WMSA320', 4, , { || .T. },,,,{ || .T. } ) == 0 // Estornar item
				ChkArm(5)
			EndIf
		Else
			WmsMessage(STR0031+CRLF+STR0047,WMSA32018,1) // Não há quantidade conferida para o produto!
		EndIf
	Else
		WmsMessage(STR0026+CRLF+STR0045,WMSA32019,1) // Estorno permitido somente para recebimento em andamento! // Efetue a reabertura da conferência de recebimento para poder estornar o processo.
	EndIf
	BrwRefresh()
	RestArea(aAreaDCW)
Return lRet
//----------------------------------------------------------
// Registras conferencia manual
/*/{Protheus.doc} RegCofOpe
Registrar conferencia manual

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Registrar conferencia manual

/*/
//----------------------------------------------------------
Static Function RegCofOpe()
Local aAreaDCW    := DCW->( GetArea() )
Local aAreaAnt    := GetArea()
Local nOpc        := 0
Local bOk         := {|| Iif(VldRegCof(cEndereco,cTipUni,cIdUnit),(nOpc := 1, oDlg:End()),.T.) }
Local bCancel     := {|| nOpc := 0, oDlg:End() }
Local oDlg        := Nil
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()

	If DCW->DCW_SITEMB < "6"
		If DCW->DCW_SITEMB == "2" //Volume em Andamento
			WmsMessage(STR0060,WMSA32026,1) //Conferência de volume em andamento. Finalize a conferência de volume primeiro.
			lRet := .F.
		Else

			If Empty(cTipUni)
				oMntUniItem:oUnitiz:oTipUnit:FindPadrao()
				cTipUni := oMntUniItem:oUnitiz:oTipUnit:GetTipUni()
			EndIf

			//Limpa variáveis
			cIdUnit   := Space(TamSX3("D0R_IDUNIT")[1])
			cEndereco := Padr(cEndereco,TamSX3("BE_LOCALIZ")[1])

			DEFINE MSDIALOG oDlg STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE ) FROM 0, 0 TO 220, 300 TITLE STR0101 PIXEL //Conferência Recebimento

			@ 35, 10 SAY   AllTrim(RetTitle('BE_LOCAL')) OF oDlg PIXEL
			@ 35, 50 MSGET cArmazem VALID !Empty(cArmazem) .And. ValArmazem(cArmazem,@cEndereco,@lUnitiza) F3 'NNR' OF oDlg PICTURE '@!' PIXEL

			@ 50, 10 SAY   AllTrim(RetTitle('BE_LOCALIZ'))+':' OF oDlg PIXEL
			@ 50, 50 MSGET cEndereco VALID !Empty(cEndereco) .And. ValEnder(cArmazem,cEndereco) When lUnitiza .And. lSolEnd F3 'SBELOC' OF oDlg PICTURE '@!' PIXEL

			@ 65, 10 SAY   AllTrim(RetTitle('D0R_CODUNI'))+':' OF oDlg PIXEL
			@ 65, 50 MSGET cTipUni VALID !Empty(cTipUni) .And. ValidTpUni(cTipUni) When lUnitiza .And. !Empty(cEndereco) F3 'D0T' OF oDlg PICTURE '@!' PIXEL

			@ 80, 10 SAY   AllTrim(RetTitle('D0R_IDUNIT'))+':' OF oDlg PIXEL
			@ 80, 50 MSGET cIdUnit VALID !Empty(cIdUnit) .And. ValIdUnit(cIdUnit,@cTipUni,cArmazem,cEndereco) When lUnitiza .And. !Empty(cTipUni) .And. !Empty(cEndereco) OF oDlg PICTURE '@!' PIXEL

			ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel,,,,,,,.F.) CENTERED

			If nOpc == 1 .And. FWExecView(STR0042,'WMSA320B',4,,{ || .T. },,10,,{ || .T. } ) == 0  // Conferir Item
				M->DCW_SITEMB := DCW->DCW_SITEMB
				DCY->(DbSetOrder(2))
				oBrwDCY:Refresh(.T.)
				DCZ->(dbSetOrder(2))
				oBrwDCZ:Refresh(.T.)
			EndIf
		Endif
	Else
		WmsMessage(STR0024+CRLF+STR0051,WMSA32020,1) // Recebimento conferido, operação não permitida! // Efetue a reabertura da conferência de recebimento para poder conferir um novo item.
	EndIf
	RestArea(aAreaAnt)
	RestArea(aAreaDCW)
Return .T.
//----------------------------------------------------------
// Estorna conferencia do operador
/*/{Protheus.doc} EstCofOpe
Estorna conferencia do operador

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Estorna conferencia do operador

/*/
//----------------------------------------------------------
Static Function EstCofOpe()
	If DCW->DCW_SITEMB == "5"
		If FWExecView(STR0043, 'WMSA320', 4, , { || .T. },,,,{ || .T. } ) == 0 // Estornar Operador
			ChkArm(6)
		EndIf
	Else
		WmsMessage(STR0026+CRLF+STR0045,WMSA32021,1) // Estorno permitido somente para recebimento em andamento! // Efetue a reabertura da conferência de recebimento para poder estornar o processo.
	EndIf
	BrwRefresh()
Return .T.

//----------------------------------------------------------
// Estorna conferencia operadores e produtos
/*/{Protheus.doc} EstOpeCof
Estorna conferencia operador e produto

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Estorna conferencia operador e produto

/*/
//----------------------------------------------------------
Static Function EstOpeCof()
	If DCW->DCW_SITEMB == "5"
		// Elimina registro das conferencias do operador
		If FWExecView(STR0041, 'WMSA320', 4, , { || .T. },,,,{ || .T. } ) == 0 // Estornar item
			ChkArm(7)
		EndIf
	Else
		WmsMessage(STR0026+CRLF+STR0045,WMSA32022,1) // Estorno permitido somente para recebimento em andamento! // Efetue a reabertura da conferência de recebimento para poder estornar o processo.
	EndIf
	BrwRefresh()
Return .T.
//----------------------------------------------------------
// Liberar conferencia do produto, lote e sublote
/*/{Protheus.doc} LibCofPrd
Liberar conferencia do produto, lote e sublote

@author  Alexsander Burigo Corrêa
@version P12
@Since   01/08/12
@version 1.0
@obs     Liberar conferencia do produto, lote e sublote

/*/
//----------------------------------------------------------
Static Function LibCofPrd()
Local lRet      := .T.
Local nQtConf   := 0
Local cAliasDCY := ""
Local lDtValid  := DCY->(ColumnPos("DCY_DTVAL")) > 0

	If WmsArmUnit(DCY->DCY_LOCAL)
		WmsMessage(STR0108,WMSA32094,1) // Produto não pode ser liberado sem conferência, pois necessita de unitização.
		Return .F.
	EndIf
	If DCW->DCW_SITEMB < "6"
		If DCY->DCY_QTCONF == 0
			If WmsQuestion(STR0010) // Confirma a liberação do produto sem conferência?
				Begin Transaction
					// Efetuando a liberação da quantidade total do produto
					nQtConf := DCY->DCY_QTORIG
					// Se liberou tudo, deve lançar um registro para o usuário
					// Grava conferencia
					cAliasDCY := GetNextAlias()
					cQuery := " SELECT DCY.DCY_PRDORI, DCY.DCY_PROD"
					If __lWmsNew
						cQuery += ", D11.D11_QTMULT "
					EndIf
					cQuery += " FROM "+RetSqlName("DCY")+" DCY"
					If __lWmsNew
						cQuery += ", "+RetSqlName("D11")+" D11"
					EndIf
					cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
					cQuery += " AND DCY.DCY_EMBARQ = '"+DCY->DCY_EMBARQ+"'"
					cQuery += " AND DCY.DCY_PRDORI = '"+DCY->DCY_PROD+"'"
					cQuery += " AND DCY.DCY_PRDORI <> DCY_PROD"
					cQuery += " AND DCY.DCY_LOTE = '"+DCY->DCY_LOTE+"'"
					cQuery += " AND DCY.DCY_SUBLOT = '"+DCY->DCY_SUBLOT+"'"
					cQuery += " AND DCY.DCY_QTCONF = 0"
					cQuery += " AND DCY.D_E_L_E_T_ = ''"
					If __lWmsNew
						cQuery += " AND D11.D11_FILIAL = '"+xFilial("D11")+"'"
						cQuery += " AND D11.D11_PRDORI = DCY_PRDORI"
						cQuery += " AND D11.D11_PRDCMP = DCY_PROD"
						cQuery += " AND D11.D_E_L_E_T_ = ''"
					EndIf
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCY,.F.,.T.)
					If !(cAliasDCY)->( Eof() )
						While !(cAliasDCY)->( Eof() )
							nQuant := IIf(__lWmsNew,nQtConf * (cAliasDCY)->D11_QTMULT, nQtConf )

							RecLock('DCZ',.T.)
							DCZ->DCZ_FILIAL := xFilial('DCZ')
							DCZ->DCZ_EMBARQ := DCY->DCY_EMBARQ
							DCZ->DCZ_OPER   := __cUserID
							DCZ->DCZ_PRDORI := (cAliasDCY)->DCY_PRDORI
							DCZ->DCZ_PROD   := (cAliasDCY)->DCY_PROD
							DCZ->DCZ_LOTE   := DCY->DCY_LOTE
							DCZ->DCZ_SUBLOT := DCY->DCY_SUBLOT
							DCZ->DCZ_LOCAL  := DCY->DCY_LOCAL
							DCZ->DCZ_QTCONF := nQuant
							If lDtValid
								DCZ->DCZ_DTVAL  := DCY->DCY_DTVAL
							EndIf
							DCZ->(MsUnLock())

							(cAliasDCY)->(dbSkip())
						EndDo
					Else
						RecLock('DCZ',.T.)
						DCZ->DCZ_FILIAL := xFilial('DCZ')
						DCZ->DCZ_EMBARQ := DCY->DCY_EMBARQ
						DCZ->DCZ_OPER   := __cUserID
						DCZ->DCZ_PRDORI := DCY->DCY_PRDORI
						DCZ->DCZ_PROD   := DCY->DCY_PROD
						DCZ->DCZ_LOTE   := DCY->DCY_LOTE
						DCZ->DCZ_SUBLOT := DCY->DCY_SUBLOT
						DCZ->DCZ_QTCONF := nQtConf
						DCZ->DCZ_LOCAL  := DCY->DCY_LOCAL
						If lDtValid
							DCZ->DCZ_DTVAL  := DCY->DCY_DTVAL
						EndIf
						DCZ->(MsUnlock())
					EndIf
					(cAliasDCY)->( DBCloseArea() )
					// Atualiza informações embarque
					lRet := A320COFDCY(DCY->DCY_EMBARQ)
					If !lRet
						DisarmTransaction()
					EndIf
				End Transaction
				M->DCW_SITEMB := DCW->DCW_SITEMB
				oBrwDCW:Refresh() // Mantém no registro
				DCY->(dbSetOrder(2))
				oBrwDCY:Refresh(.T.)
				DCZ->(dbSetOrder(2))
				oBrwDCZ:Refresh(.T.)
			EndIf
		Else
			WmsMessage(STR0036+CRLF+STR0046,WMSA32023,1) // Liberação sem conferência permitida somente quando não existe nenhuma quantidade conferida para o produto!
		EndIf
	Else
		WmsMessage(STR0024+CRLF+STR0052,WMSA32024,1) // Recebimento conferido, operação não permitida! // Efetue a reabertura da conferência de recebimento para liberar o produto sem conferência.
	EndIf
Return lRet
//----------------------------------------------------------
// Embarques
/*/{Protheus.doc} StatusProd
Status conferência produto

@author  Alexsander Burigo Corrêa
@version P11 R7
@Since   01/07/12
@obs     Status conferência produto

/*/
//----------------------------------------------------------
Static Function StatusProd()
Local cRet
	If DCY->DCY_QTCONF == 0
		cRet := "BR_VERMELHO"
	ElseIf QtdComp(DCY->DCY_QTORIG) <> QtdComp(DCY->DCY_QTCONF) .AND. DCW->DCW_SITEMB = "5"
		cRet := "BR_AMARELO"
	ElseIf QtdComp(DCY->DCY_QTORIG) <> QtdComp(DCY->DCY_QTCONF) .AND. DCW->DCW_SITEMB > "5"
		cRet := "BR_AZUL"
	Else
		cRet := "BR_VERDE"
	EndIf
Return cRet

//-------------------------------------------------------------------
//Libera a tabela de ordem de serviço do WMS de acordo com o
//documento que está sendo excluído do processo de conferência
//-------------------------------------------------------------------
Static Function DocLibDCF(cDocto,cSerie,cFornec,cLoja)
Local cQuery    := ""
Local lRet      := .T.
Local cAliasDCF := ""
	cQuery := "SELECT DCF.R_E_C_N_O_ RECNODCF"
	cQuery +=  " FROM "+ RetSqlName('DCF')+" DCF"
	cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
	cQuery +=   " AND DCF.DCF_DOCTO  = '"+cDocto+"'"
	cQuery +=   " AND DCF.DCF_SERIE  = '"+cSerie+"'"
	cQuery +=   " AND DCF.DCF_CLIFOR = '"+cFornec+"'"
	cQuery +=   " AND DCF.DCF_LOJA   = '"+cLoja+"'"
	cQuery +=   " AND DCF.DCF_STSERV = '4'" //Somente ordens de serviço bloqueadas
	cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasDCF := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCF,.F.,.T.)
	Do While (cAliasDCF)->(!Eof())
		DCF->(dbGoTo((cAliasDCF)->RECNODCF))
		RecLock('DCF', .F.)
		DCF->DCF_STSERV = '1'
		DCF->( MsUnlock())
		(cAliasDCF)->(dbSkip())
	EndDo
	(cAliasDCF)->(dbCloseArea())
Return lRet

//----------------------------------------------------------
//Atualiza a situação das notas de entrada com base na conferência de recebimento
//----------------------------------------------------------
Function Wm320BqSF1(cEmbarque)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasSF1 := ""
	cQuery := "SELECT SF1.R_E_C_N_O_ RECNOSF1 "
	cQuery +=  " FROM "+RetSqlName("SF1")+" SF1"
	cQuery += " INNER JOIN "+RetSqlName("DCX")+" DCX"
	cQuery +=    " ON DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
	cQuery +=   " AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
	cQuery +=   " AND DCX.DCX_DOC = SF1.F1_DOC"
	cQuery +=   " AND DCX.DCX_SERIE = SF1.F1_SERIE"
	cQuery +=   " AND DCX.DCX_FORNEC = SF1.F1_FORNECE"
	cQuery +=   " AND DCX.DCX_LOJA = SF1.F1_LOJA"
	cQuery +=   " AND DCX.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SF1.F1_FILIAL = '"+xFilial('SF1')+"'"
	cQuery +=   " AND SF1.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSF1 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSF1,.F.,.T.)
	Do While (cAliasSF1)->(!Eof())
		SF1->(dbGoTo((cAliasSF1)->RECNOSF1))
		RecLock('SF1', .F.)
		SF1->F1_STATCON := '3' // Em conferencia
		SF1->( MsUnlock())
		(cAliasSF1)->(dbSkip())
	EndDo
	(cAliasSF1)->(dbCloseArea())
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} A320COFDCY
Registra uma quantidade nos itens conferidos

@author  Alexsander Burigo Corrêa
@version P11
@Since     16/05/12
@obs    Atualiza dados do embarque

/*/
//----------------------------------------------------------
Function A320COFDCY(cEmbarque,lFinalizar,lEstorno,cProduto)
Local aAreaAnt  := GetArea()
Local cAliasQry := ""
Local cAliasDCY := ""
Local cAliasConf:= ""
Local cQuery    := ""
Local nQtdCof   := 0
Local aTamSx3   := {}
Local lRet      := .T.
Local lDtValid  := DCY->(ColumnPos("DCY_DTVAL")) > 0
Local lWMA320DT := ExistBlock("WMA320DT")

Default lFinalizar := .T.
Default lEstorno   := .F.
Default cProduto   := ""

	// Inicializa a quantidade conferida dos produtos para recalcular com base nas conferencias
	cQuery := "SELECT DCY.R_E_C_N_O_ RECNODCY"
	cQuery +=  " FROM "+ RetSqlName('DCY')+" DCY"
	cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
	cQuery +=   " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
	If !lEstorno
		cQuery +=   " AND DCY.DCY_QTORIG > 0 "
	EndIf
	If !lEstorno .And. !Empty(cProduto)
		cQuery +=   " AND DCY.DCY_PROD = '" + cProduto + "'"
	EndIf
	cQuery +=   " AND DCY.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	Do While (cAliasQry)->(!Eof())
		DCY->(dbGoTo((cAliasQry)->RECNODCY))
		RecLock('DCY', .F.)
		DCY->DCY_QTCONF := 0
		DCY->( MsUnlock())
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	DCY->(DbSetOrder(1))
	//Sumariza as quantidades conferidas
	cAliasQry := GetNextAlias()
	cQuery := " SELECT SUM(DCZ.DCZ_QTCONF) DCZ_QTCONF,"
	cQuery +=        " DCZ.DCZ_PRDORI,"
	cQuery +=        " DCZ.DCZ_PROD,"
	cQuery +=        " DCZ.DCZ_LOTE,"
	cQuery +=        " DCZ.DCZ_SUBLOT,"
	cQuery +=        " DCZ.DCZ_LOCAL,"
	If lDtValid
		cQuery +=    " DCZ.DCZ_DTVAL,"
	EndIF
	cQuery +=        " CASE WHEN D11.D11_PRODUT IS NULL THEN 0 ELSE 1 END COMP"
	cQuery +=   " FROM "+RetSqlName("DCZ")+" DCZ"
	cQuery +=   " LEFT JOIN "+RetSqlName("D11")+" D11"
	cQuery +=     " ON D11.D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=    " AND D11.D11_PRDORI = DCZ.DCZ_PRDORI"
	cQuery +=    " AND D11.D11_PRDCMP = DCZ.DCZ_PROD"
	cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial("DCZ")+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
	If !lEstorno .And. !Empty(cProduto)
		cQuery +=   " AND DCZ.DCZ_PROD = '" + cProduto + "'"
	EndIf
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY DCZ.DCZ_LOCAL,"
	cQuery +=           " DCZ.DCZ_PRDORI,"
	cQuery +=           " DCZ.DCZ_LOTE,"
	cQuery +=           " DCZ.DCZ_SUBLOT,"
	cQuery +=           " DCZ.DCZ_PROD,"
	cQuery +=           " D11.D11_PRODUT"
	If lDtValid
		cQuery +=    " ,DCZ.DCZ_DTVAL"
	EndIF
	If __lWmsNew
		cQuery +=  " UNION ALL"
		cQuery += " SELECT MIN((CASE WHEN TRP.DCZ_QTCONF IS NULL THEN 0 ELSE TRP.DCZ_QTCONF END  )/  D11.D11_QTMULT) DCZ_QTCONF,"
		cQuery +=        " DCY.DCY_PRDORI,"
		cQuery +=        " D11.D11_PRDORI,"
		cQuery +=        " DCY.DCY_LOTE,"
		cQuery +=        " DCY.DCY_SUBLOT,"
		cQuery +=        " DCY.DCY_LOCAL,"
		If lDtValid
			cQuery +=    " DCY.DCY_DTVAL,"
		EndIF
		cQuery +=        " 1 COMP"
		cQuery +=   " FROM "+RetSqlName("DCY")+" DCY"
		cQuery +=   " LEFT JOIN ( SELECT SUM(DCZ.DCZ_QTCONF) DCZ_QTCONF,"
		cQuery +=                      " DCY.DCY_PRDORI,"
		cQuery +=                      " DCY.DCY_PROD,"
		cQuery +=                      " DCY.DCY_LOTE,"
		cQuery +=                      " DCY.DCY_SUBLOT,"
		cQuery +=                      " DCY.DCY_LOCAL"
		If lDtValid
			cQuery +=    " ,DCY.DCY_DTVAL"
		EndIF
		cQuery +=                 " FROM "+RetSqlName("DCY")+" DCY, "+RetSqlName("DCZ")+" DCZ, "+RetSqlName("D11")+" D11"
		cQuery +=                " WHERE DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
		cQuery +=                  " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=                  " AND DCY.DCY_PRDORI <> DCY.DCY_PROD"
		cQuery +=                  " AND DCY.DCY_LOTE = DCZ.DCZ_LOTE"
		cQuery +=                  " AND DCY.DCY_SUBLOT = DCZ.DCZ_SUBLOT"
		cQuery +=                  " AND DCY.DCY_LOCAL  = DCZ.DCZ_LOCAL"
		cQuery +=                  " AND DCY.DCY_QTORIG > 0 "
		cQuery +=                  " AND DCY.D_E_L_E_T_ = ' '"
		cQuery +=                  " AND DCZ.DCZ_FILIAL = '"+xFilial("DCZ")+"'"
		cQuery +=                  " AND DCZ.DCZ_EMBARQ = DCY.DCY_EMBARQ"
		cQuery +=                  " AND DCZ.DCZ_PROD = DCY.DCY_PROD"
		cQuery +=                  " AND DCZ.DCZ_PRDORI = DCY.DCY_PRDORI"
		cQuery +=                  " AND DCZ.DCZ_LOCAL  = DCY.DCY_LOCAL"
		cQuery +=                  " AND DCZ.D_E_L_E_T_ = ' '"
		cQuery +=                  " AND D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=                  " AND D11.D11_PRDORI = DCY.DCY_PRDORI"
		cQuery +=                  " AND D11.D11_PRDCMP = DCY.DCY_PROD"
		cQuery +=                  " AND D11.D_E_L_E_T_ = ' '
		cQuery +=                " GROUP BY DCY.DCY_LOCAL,
		cQuery +=                         " DCY.DCY_PRDORI,"
		cQuery +=                         " DCY.DCY_PROD,"
		cQuery +=                         " DCY.DCY_LOTE,"
		cQuery +=                         " DCY.DCY_SUBLOT
		If lDtValid
			cQuery +=    " ,DCY.DCY_DTVAL"
		EndIF
		cQuery += " ) TRP"
		cQuery +=     " ON DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
		cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCY.DCY_PRDORI = TRP.DCY_PRDORI"
		cQuery +=    " AND DCY.DCY_PROD = TRP.DCY_PROD"
		cQuery +=    " AND DCY.DCY_LOTE = TRP.DCY_LOTE"
		cQuery +=    " AND DCY.DCY_SUBLOT = TRP.DCY_SUBLOT"
		cQuery +=    " AND DCY.DCY_LOCAL = TRP.DCY_LOCAL"
		cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN "+RetSqlName("D11")+" D11"
		cQuery +=     " ON D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=    " AND D11.D11_PRDORI = DCY.DCY_PRDORI"
		cQuery +=    " AND D11.D11_PRDCMP = DCY.DCY_PROD"
		cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
		cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCY.DCY_PRDORI <> DCY.DCY_PROD"
		cQuery +=    " AND DCY.DCY_QTORIG > 0 "
		cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY DCY.DCY_LOCAL,"
		cQuery +=           " DCY.DCY_PRDORI,"
		cQuery +=           " D11.D11_PRDORI,"
		cQuery +=           " DCY.DCY_LOTE,"
		cQuery +=           " DCY.DCY_SUBLOT"
		If lDtValid
			cQuery +=    " ,DCY.DCY_DTVAL"
		EndIF
	EndIf
	cQuery +=  " ORDER BY DCZ_LOCAL,"
	cQuery +=           " DCZ_PRDORI,"
	cQuery +=           " DCZ_LOTE,"
	cQuery +=           " DCZ_SUBLOT,"
	cQuery +=           " DCZ_PROD"
	cQuery := ChangeQuery(cQuery)
	aTamSx3 := TamSX3('DCZ_QTCONF')
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!Eof() )
		cAliasConf := GetNextAlias()
		BeginSql Alias cAliasConf
			SELECT DCY.R_E_C_N_O_ RECNODCY
			  FROM %Table:DCY% DCY
			 WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
			   AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
			   AND DCY.DCY_PRDORI = %Exp:(cAliasQry)->DCZ_PRDORI%
			   AND DCY.DCY_PROD   = %Exp:(cAliasQry)->DCZ_PROD%
			   AND DCY.DCY_LOTE   = %Exp:(cAliasQry)->DCZ_LOTE%
			   AND DCY.DCY_SUBLOT = %Exp:(cAliasQry)->DCZ_SUBLOT%
			   AND DCY.DCY_LOCAL  = %Exp:(cAliasQry)->DCZ_LOCAL%
			   AND DCY.%NotDel%
		EndSql
		If (cAliasConf)->(!EoF())
			DCY->(DbGoTo((cAliasConf)->RECNODCY))
			RecLock('DCY',.F.)
			DCY->DCY_QTCONF := IIF((cAliasQry)->COMP == 1,Int((cAliasQry)->DCZ_QTCONF),(cAliasQry)->DCZ_QTCONF)
			DCY->(MsUnlock())
		Else
			RecLock('DCY',.T.)
			DCY->DCY_FILIAL := xFilial('DCY')
			DCY->DCY_EMBARQ := cEmbarque
			DCY->DCY_PRDORI := (cAliasQry)->DCZ_PRDORI
			DCY->DCY_PROD   := (cAliasQry)->DCZ_PROD
			DCY->DCY_LOTE   := (cAliasQry)->DCZ_LOTE
			DCY->DCY_SUBLOT := (cAliasQry)->DCZ_SUBLOT
			DCY->DCY_QTORIG := 0
			DCY->DCY_QTCONF := IIF((cAliasQry)->COMP == 1,Int((cAliasQry)->DCZ_QTCONF),(cAliasQry)->DCZ_QTCONF)
			DCY->DCY_LOCAL  := (cAliasQry)->DCZ_LOCAL			
			If lDtValid .And. !Empty((cAliasQry)->DCZ_DTVAL)
				DCY->DCY_DTVAL  := SToD((cAliasQry)->DCZ_DTVAL)
			EndIf
			DCY->(MsUnlock())
		EndIf
		If lWMA320DT
			ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
		EndIf
		
		(cAliasConf)->(DbCloseArea())
		// Libera para armazenagem
		If DCY->DCY_QTORIG > 0 .And. DCY->DCY_QTCONF >= DCY->DCY_QTORIG
			A320LibArm(1,cEmbarque,DCY->DCY_PROD,DCY->DCY_LOTE,DCY->DCY_SUBLOT,DCY->DCY_PRDORI)
		EndIf
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	//Ajusta quantidade origem dos produtos pai
	If lRet .And. __lWmsNew
		cQuery := " SELECT MIN((CASE WHEN TRP.DCY_QTORIG IS NULL THEN 0 ELSE TRP.DCY_QTORIG END) / D11.D11_QTMULT) DCY_QTORIG,"
		cQuery +=        " DCY.DCY_PRDORI,"
		cQuery +=        " DCY.DCY_LOTE,"
		cQuery +=        " DCY.DCY_SUBLOT,"
		cQuery +=        " DCY.DCY_LOCAL"
		cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
		cQuery +=   " LEFT JOIN ( SELECT SUM(DCY.DCY_QTORIG) DCY_QTORIG,"
		cQuery +=                      " DCY.DCY_PRDORI,"
		cQuery +=                      " DCY.DCY_PROD,"
		cQuery +=                      " DCY.DCY_LOTE,"
		cQuery +=                      " DCY.DCY_SUBLOT,"
		cQuery +=                      " DCY.DCY_LOCAL"
		cQuery +=                 " FROM "+RetSqlName('DCY')+" DCY,"
		cQuery +=                     "  "+RetSqlName('D11')+ " D11"
		cQuery +=                " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=                  " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=                  " AND DCY.DCY_PRDORI <> DCY.DCY_PROD"
		cQuery +=                  " AND DCY.D_E_L_E_T_ = ' '"
		cQuery +=                  " AND D11_FILIAL = '"+xFilial('D11')+"'"
		cQuery +=                  " AND D11.D11_PRDORI = DCY.DCY_PRDORI"
		cQuery +=                  " AND D11.D11_PRDCMP = DCY.DCY_PROD"
		cQuery +=                  " AND D11.D_E_L_E_T_ = ' '"
		cQuery +=                " GROUP BY DCY.DCY_LOCAL,"
		cQuery +=                         " DCY.DCY_PRDORI,"
		cQuery +=                         " DCY.DCY_PROD,"
		cQuery +=                         " DCY.DCY_LOTE,"
		cQuery +=                         " DCY.DCY_SUBLOT"
		cQuery +=                " ) TRP"
		cQuery +=     " ON DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCY.DCY_PRDORI = TRP.DCY_PRDORI"
		cQuery +=    " AND DCY.DCY_PROD = TRP.DCY_PROD"
		cQuery +=    " AND DCY.DCY_LOTE = TRP.DCY_LOTE"
		cQuery +=    " AND DCY.DCY_SUBLOT = TRP.DCY_SUBLOT"
		cQuery +=    " AND DCY.DCY_LOCAL  = TRP.DCY_LOCAL"
		cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT JOIN "+RetSqlName('D11')+" D11 "
		cQuery +=     " ON D11.D11_FILIAL = '"+xFilial('D11')+"'"
		cQuery +=    " AND D11.D11_PRDORI = DCY.DCY_PRDORI"
		cQuery +=    " AND D11.D11_PRDCMP = DCY.DCY_PROD"
		cQuery +=    " AND D11.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=    " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=    " AND DCY.DCY_PRDORI <> DCY.DCY_PROD"
		cQuery +=    " AND DCY.D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY DCY.DCY_LOCAL,"
		cQuery +=          " DCY.DCY_PRDORI,"
		cQuery +=          " D11.D11_PRDORI,"
		cQuery +=          " DCY.DCY_LOTE,"
		cQuery +=          " DCY.DCY_SUBLOT"
		cQuery := ChangeQuery(cQuery)
		cAliasDCY := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCY,.F.,.T.)
		While (cAliasDCY)->(!EoF())
			cAliasConf := GetNextAlias()
			BeginSql Alias cAliasConf
				SELECT DCY.R_E_C_N_O_ RECNODCY
				FROM %Table:DCY% DCY
				WHERE DCY.DCY_FILIAL = %xFilial:DCY% 
				AND DCY.DCY_EMBARQ = %Exp:cEmbarque%
				AND DCY.DCY_PRDORI = %Exp:(cAliasDCY)->DCY_PRDORI%
				AND DCY.DCY_PROD   = %Exp:(cAliasDCY)->DCY_PRDORI%
				AND DCY.DCY_LOTE   = %Exp:(cAliasDCY)->DCY_LOTE%
				AND DCY.DCY_SUBLOT = %Exp:(cAliasDCY)->DCY_SUBLOT%
				AND DCY.DCY_LOCAL  = %Exp:(cAliasDCY)->DCY_LOCAL%
				AND DCY.%NotDel%
			EndSql
			If (cAliasConf)->(!EoF())
				DCY->(DbGoTo((cAliasConf)->RECNODCY))
				RecLock('DCY',.F.)
				DCY->DCY_QTORIG := (cAliasDCY)->DCY_QTORIG
				DCY->(MsUnlock())

				If lWMA320DT
					ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
				EndIf
			EndIf
			(cAliasConf)->(DbCloseArea())
			(cAliasDCY)->(DbSkip())
		EndDo
		(cAliasDCY)->(DbCloseArea())
	EndIf
	// Remove os registros de itens do embarque (DCY)
	If lFinalizar
		cAliasQry := GetNextAlias()
		cQuery := "SELECT R_E_C_N_O_ RECNODCY"
		cQuery +=  " FROM " + RetSqlName('DCY')+" DCY"
		cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=   " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
		cQuery +=   " AND DCY.DCY_QTORIG <= 0"
		cQuery +=   " AND DCY.DCY_QTCONF <= 0"
		If __lWmsNew
			cQuery += " AND NOT EXISTS ( SELECT 1"
			cQuery +=                    " FROM "+RetSqlName('DCY')+" DCY1"
			cQuery +=                   " WHERE DCY1.DCY_FILIAL = DCY.DCY_FILIAL"
			cQuery +=                     " AND DCY1.DCY_EMBARQ = DCY.DCY_EMBARQ"
			cQuery +=                     " AND DCY1.DCY_PRDORI = DCY.DCY_PRDORI"
			cQuery +=                     " AND DCY1.DCY_LOTE = DCY.DCY_LOTE"
			cQuery +=                     " AND DCY1.DCY_SUBLOT = DCY.DCY_SUBLOT"
			cQuery +=                     " AND DCY1.DCY_LOCAL = DCY.DCY_LOCAL"
			cQuery +=                     " AND DCY1.DCY_QTORIG <= 0"
			cQuery +=                     " AND DCY1.DCY_QTCONF > 0"
			cQuery +=                     " AND DCY1.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery +=   " AND DCY.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof() )
			DCY->(DbGoTo((cAliasQry)->RECNODCY))
			RecLock('DCY',.F.)
			DCY->(dbDelete())
			DCY->(MsUnlock())
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	// Estorna as conferências Zeradas
	If lRet
		cAliasDCZ := GetNextAlias()
		cQuery := " SELECT DCZ.R_E_C_N_O_ RECNODCZ"
		cQuery +=  " FROM "+RetSqlName("DCZ")+" DCZ"
		cQuery += " WHERE DCZ.DCZ_FILIAL = '"+xFilial("DCZ")+"'"
		cQuery +=   " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
		cQuery +=   " AND DCZ.DCZ_QTCONF = '0'"
		cQuery +=   " AND DCZ.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCZ,.F.,.T.)
		If (cAliasDCZ)->(!Eof() )
			While (cAliasDCZ)->(!Eof() )
				DCZ->(DbGoTo((cAliasDCZ)->RECNODCZ))
				RecLock('DCZ', .F.)
				DCZ->(DbDelete())
				DCZ->(MsUnLock())
				(cAliasDCZ)->(DbSkip())
			EndDo
			(cAliasDCZ)->(dbCloseArea())
		EndIf
	EndIf

	If lRet
		// Deve pegar a quantidade conferida para o embarque
		cQuery := "SELECT SUM(DCZ.DCZ_QTCONF) DCZ_QTCONF"
		cQuery +=  " FROM "+RetSqlName('DCZ')+ " DCZ"
		cQuery += " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
		cQuery +=   " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
		cQuery +=   " AND DCZ.D_E_L_E_T_ = ' '"
		cAliasQry := GetNextAlias()
		aTamSx3 := TamSX3('DCZ_QTCONF')
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		TcSetField( cAliasQry,'DCZ_QTCONF','N',aTamSx3[1],aTamSx3[2])
		If (cAliasQry)->(!Eof())
			nQtdCof := (cAliasQry)->DCZ_QTCONF
		EndIf
		(cAliasQry)->(DbCloseArea())
		RecLock('DCW',.F.)
		If !__lWmsNew
			DCW->DCW_SITEMB := Iif(QtdComp(nQtdCof) > 0,"5","1")
		Else
			DCW->DCW_SITEMB := Iif(QtdComp(nQtdCof) > 0,"5",Iif(DCW->DCW_QTCONF > 0,Iif(QtdComp(DCW->DCW_QTVOLU) == QtdComp(DCW->DCW_QTCONF),"3","4"),"1"))
		EndIf
		DCW->(MsUnlock())
	EndIf
    IF lRet .AND. lEstorno
	   Atuqtdcy(cEmbarque,DCW->DCW_TPCONF)
	EndIf  
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} A320FINCOF
Finaliza a conferência de recebimento

@author  Guilherme A. Metzger
@version P11
@since   17/11/14
/*/
//----------------------------------------------------------
Function A320FINCOF(cEmbarque,cTpConf,lDiverge,lDiverLote)
Return Wm320FnCof(cEmbarque,cTpConf,lDiverge,lDiverLote)

//-------------------------------------------------------------------------
Function A320PrdPai(cEmbarque,cProduto,cLoteCtl,cNumLote)
//-------------------------------------------------------------------------
Local lProdPai  := .F.
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
	// Deve verificar se o produto é um produto "pai"
	cQuery := "SELECT DISTINCT 1 PRD_ISDAD"
	cQuery +=  " FROM "+RetSqlName("DCY")+" DCY"
	cQuery +=  " WHERE DCY.DCY_FILIAL = '"+xFilial("DCY")+"'"
	cQuery +=  " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
	cQuery +=  " AND DCY.DCY_PRDORI = '"+cProduto+"'"
	cQuery +=  " AND DCY.DCY_LOTE = '"+cLoteCtl+"'"
	cQuery +=  " AND DCY.DCY_SUBLOT = '"+cNumLote+"'"
	cQuery +=  " AND DCY.DCY_PROD  <> DCY.DCY_PRDORI"
	cQuery +=  " AND DCY.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	lProdPai := (cAliasQry)->(!Eof())
	(cAliasQry)->(DbCloseArea())
Return lProdPai

//------------------------------------------------------------------------------
Static Function ChkArm(nAcao)
//------------------------------------------------------------------------------
Local lRet   := .T.
Local lRetPE := .F.
	If nAcao == 1 .Or. nAcao == 5
		If !A320LibArm(nAcao,DCW->DCW_EMBARQ,DCY->DCY_PROD,DCY->DCY_LOTE,DCY->DCY_SUBLOT,DCY->DCY_PRDORI)
			lRet := .F.
		EndIf
	ElseIf nAcao == 2	.Or. nAcao == 3 .Or. nAcao == 4
		If nAcao == 4
			If ExistBlock("WMSA320R")
				lRetPE := ExecBlock("WMSA320R",.F.,.F.,{DCW->DCW_EMBARQ})
				lRet := (If(ValType(lRetPE)=='L',lRetPE,.F.))
			EndIf
		EndIf
		If lRet .And. !A320LibArm(nAcao,DCW->DCW_EMBARQ)
			lRet := .F.
		EndIf
	ElseIf nAcao == 6 .Or. nAcao == 7
		If !A320LibArm(nAcao,DCW->DCW_EMBARQ,DCZ->DCZ_PROD,DCZ->DCZ_LOTE,DCZ->DCZ_SUBLOT,DCZ->DCZ_PRDORI,DCZ->DCZ_OPER)
			lRet := .F.
		EndIf
	EndIf
Return lRet

// Libera para armazenagem ou no Estorno quando não executado a armazenagem, volta para status para bloqueado
/*
nAcao:
		1= Liberacao por item;
		2= Liberacao da Conferencia de todo recebimento
		*1 e 2= alteram o status da tarefa para 4=A Executar
		3= Estorno da Conferencia, somente das tarefas que estao 4=A Executar, e volta Status para 2=Com Problema
		4= Valida se pode reabrir conferencia
		5= Estorno da Conferencia do Produto, somente das tarefas que estao 4=A Executar, e volta Status para 2=Com Problema
		6= Estorno da Conferencia do Operador
		7= Estorno da Conferencia Item do Operador
*/
Static Function A320LibArm(nAcao,cEmbarque,cProduto,cLoteCtl,cNumLote,cPrdOri,cOperador)
Local lRet    := .T.
Local lExec   := .F.

Default cProduto  := ''
Default cLoteCtl  := ''
Default cNumLote  := ''
Default cPrdOri   := ''
Default cOperador := ''
	If __lWmsNew
		cQuery := "SELECT D12.R_E_C_N_O_ RECNOD12"
		cQuery += "  FROM "+RetSqlName('DCX')+" DCX,"+RetSqlName('DCF')+" DCF,"+RetSqlName('DCR')+" DCR,"+RetSqlName('D12')+" D12"
		If nAcao == 6 .Or. nAcao == 7
			cQuery += " ,"+RetSqlName('DCZ')+" DCZ"
		EndIf
		cQuery += " WHERE DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
		cQuery += "   AND DCF.DCF_FILIAL = '"+xFilial('DCF')+"'"
		cQuery += "   AND DCR.DCR_FILIAL = '"+xFilial('DCR')+"'"
		cQuery += "   AND D12.D12_FILIAL = '"+xFilial('D12')+"'"
		cQuery += "   AND DCX.DCX_EMBARQ = '"+cEmbarque+"'"
		cQuery += "   AND DCX.DCX_DOC = DCF.DCF_DOCTO"
		cQuery += "   AND DCX.DCX_SERIE = DCF.DCF_SERIE"
		cQuery += "   AND DCX.DCX_FORNEC = DCF.DCF_CLIFOR"
		cQuery += "   AND DCX.DCX_LOJA = DCF.DCF_LOJA"
		cQuery += "   AND DCF.DCF_ID = DCR.DCR_IDORI"
		cQuery += "   AND DCR.DCR_IDDCF = D12.D12_IDDCF"
		cQuery += "   AND DCR.DCR_IDMOV = D12.D12_IDMOV"
		cQuery += "   AND DCR.DCR_IDOPER = D12.D12_IDOPER"
		cQuery += "   AND DCR.DCR_SEQUEN = D12.D12_SEQUEN"
		If nAcao == 1 .Or. nAcao == 5 .Or. nAcao == 7
			cQuery += " AND D12.D12_PRODUT = '"+cProduto+"'"
			cQuery += " AND D12.D12_LOTECT = '"+cLoteCtl+"'"
			cQuery += " AND D12.D12_NUMLOT = '"+cNumLote+"'"
			cQuery += " AND DCF.DCF_CODPRO = '"+cPrdOri+"'"
			If nAcao == 1
				cQuery += " AND D12.D12_STATUS = '2'"
			ElseIf nAcao == 5
				cQuery += " AND D12.D12_STATUS = '4'"
			EndIf
		ElseIf nAcao == 2
			cQuery += "   AND D12.D12_STATUS = '2'"
		ElseIf nAcao == 3
			cQuery += "   AND D12.D12_STATUS = '4'"
		EndIf
		If nAcao == 6 .Or. nAcao == 7
			cQuery += " AND DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
			cQuery += " AND DCZ.DCZ_EMBARQ = DCX.DCX_EMBARQ"
			cQuery += " AND DCZ.DCZ_OPER = '"+cOperador+"'"
			cQuery += " AND D12.D12_STATUS = '4'"
			cQuery += " AND DCZ.D_E_L_E_T_ = ''"
		EndIf
		cQuery += "   AND DCX.D_E_L_E_T_ = ' '"
		cQuery += "   AND DCF.D_E_L_E_T_ = ' '"
		cQuery += "   AND DCR.D_E_L_E_T_ = ' '"
		cQuery += "   AND D12.D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		While (cAliasQry)->(!Eof())
			D12->(dbGoTo((cAliasQry)->RECNOD12))
			If nAcao == 1 .Or. nAcao == 2
				RecLock("D12",.F.)
				D12->D12_STATUS := "4"
				D12->(MsUnlock())
			ElseIf nAcao == 3 .Or. nAcao == 5 .Or. nAcao == 6 .Or. nAcao == 7
				RecLock("D12",.F.)
				D12->D12_STATUS := "2"
				D12->(MsUnlock())
			ElseIf nAcao == 4
				If D12->D12_STATUS == "1"
					lExec := .T.
				Else
					lExec := .F.
					Exit
				EndIf
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

		If nAcao == 4 .And. lExec
			WmsMessage(STR0054,WMSA32025,1) // Reabertura permitida somente para Armazenagem não executada!
			lRet := .F.
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------
Static Function Filtro()
//----------------------------------------------------------
Local cFiltro := ""
	cFiltro := " DCW_EMBARQ >= '"+MV_PAR01+"' AND DCW_EMBARQ <= '"+MV_PAR02+"'"
	cFiltro += " AND DCW_DATGER >= '"+DTOS(MV_PAR03)+"' AND DCW_DATGER <= '"+DTOS(MV_PAR04)+"'"
Return cFiltro

Static Function SelFiltro(lPergunte)
Local nPos := oBrwDCW:At()
Local lRefresh := .T.

	Pergunte('WMSA320',lPergunte)
	lRefresh := (MV_PAR05 < 4)

	If lPergunte
		oBrwDCW:SetFilterDefault("@"+Filtro())
		If !lRefresh
			oBrwDCW:Refresh()
		EndIf
	EndIf

	If lRefresh
		If MV_PAR05 == 1
			oBrwDCW:Refresh(.T.)
		ElseIf MV_PAR05 == 2
			oBrwDCW:Refresh(.F.)
			oBrwDCW:GoBottom()
		Else
			oBrwDCW:Refresh(.F.)
			oBrwDCW:GoTo(nPos)
		EndIf
	EndIf
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} GeraD0Q
Gera novamente D0Q quando está excluindo algum documento de entrada da conferência.
@author  Amanda Rosa Vieira
@version P12
@since   19/04/2017
/*/
//----------------------------------------------------------
Static Function GeraD0Q(cDocto,cSerie,cFornece,cLoja)
Local cQuery    := ""
Local cAliasSD1 := ""
Local oDmdUnit   := Nil
Local lRet      := .T.
	cQuery := " SELECT SD1.D1_NUMSEQ"
	cQuery +=   " FROM "+RetSqlName('SD1')+" SD1"
	cQuery +=  " INNER JOIN "+RetSqlName('NNR')+ " NNR"
	cQuery +=     " ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"'"
	cQuery +=    " AND NNR.NNR_CODIGO = SD1.D1_LOCAL"
	cQuery +=    " AND NNR.NNR_AMZUNI = '1'"
	cQuery +=    " AND NNR.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"'"
	cQuery +=    " AND SD1.D1_DOC    = '"+cDocto+"'"
	cQuery +=    " AND SD1.D1_SERIE  = '"+cSerie+"'"
	cQuery +=    " AND SD1.D1_FORNECE= '"+cFornece+"'"
	cQuery +=    " AND SD1.D1_LOJA   = '"+cLoja+"'"
	cQuery +=    " AND SD1.D1_TES    <> '"+Space(TamSX3("D1_TES")[1])+"'"
	cQuery +=    " AND SD1.D1_QUANT  > 0"
	cQuery +=    " AND SD1.D1_OP     = ' '"
	cQuery +=    " AND SD1.D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSD1 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
	oDmdUnit := WMSDTCDemandaUnitizacaoCreate():New()
	While (cAliasSD1)->(!EoF())
		oDmdUnit:SetNumSeq((cAliasSD1)->D1_NUMSEQ)
		oDmdUnit:SetOrigem('SD1')
		oDmdUnit:SetGeraSld(.F.)
		oDmdUnit:CreateD0Q()
		(cAliasSD1)->(dbSkip())
	EndDo
	(cAliasSD1)->(dbCloseArea())
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ValArmazem
Valida armazém informado
@author  Amanda Rosa Vieira
@version P12
@since   20/04/2017
/*/
//----------------------------------------------------------
Static Function ValArmazem(cArmazem,cEndereco,lUnitiza)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasDCY := ""
Local cAliasQry := ""
	lUnitiza := .F.
	lSolEnd  := .T.
	// Valida se o armazém existe e se é unitizado ou não
	NNR->(dbSetOrder(1))
	If NNR->(dbSeek(xFilial("NNR")+cArmazem))
		lUnitiza := WmsArmUnit(cArmazem)
	Else
		WmsMessage(STR0107,WMSA32085) // Armazem inválido!
		lRet := .F.
	EndIf
	// Verifica se o armazém informado faz parte do processo de conferência
	If lRet
		cQuery := " SELECT DCY_LOCAL"
		cQuery +=   " FROM "+RetSqlName('DCY')+" DCY"
		cQuery +=  " WHERE DCY_FILIAL = '"+xFilial('DCY')+"'"
		cQuery +=    " AND DCY_EMBARQ = '"+DCW->DCW_EMBARQ+"'"
		cQuery +=    " AND DCY_LOCAL  = '"+cArmazem+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasDCY := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCY,.F.,.T.)
		If (cAliasDCY)->(EoF())
			WmsMessage(WmsFmtMsg(STR0102,{{"[VAR01]",cArmazem}}),WMSA32091) // Não há conferência prevista para o armazém [VAR01].
			lRet := .F.
		EndIf
		(cAliasDCY)->(DbCloseArea())
	EndIf
	// Se o armazém informado for o de excesso e ele for unitizado
	If lRet .And. (cArmazem == __cWmsLcEx) .And. lUnitiza
		// Valida se o armazém é diferente do informado nos documentos
		cQuery := "SELECT 1"
		cQuery +=  " FROM "+RetSqlName("SD1")+" SD1,"
		cQuery +=          +RetSqlName("DCX")+" DCX"
		cQuery += " WHERE DCX.DCX_FILIAL = '"+xFilial("DCX")+"'"
		cQuery +=   " AND DCX.DCX_EMBARQ = '"+DCW->DCW_EMBARQ+"'"
		cQuery +=   " AND DCX.D_E_L_E_T_ = ' '"
		cQuery +=   " AND SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
		cQuery +=   " AND SD1.D1_DOC     = DCX.DCX_DOC"
		cQuery +=   " AND SD1.D1_SERIE   = DCX.DCX_SERIE"
		cQuery +=   " AND SD1.D1_FORNECE = DCX.DCX_FORNEC"
		cQuery +=   " AND SD1.D1_LOJA    = DCX.DCX_LOJA"
		cQuery +=   " AND SD1.D1_LOCAL   <> '"+cArmazem+"'"
		cQuery +=   " AND SD1.D_E_L_E_T_ = ''"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		If !(cAliasQry)->(Eof())
			cEndereco := __cWmsEnEx
			lSolEnd   := .F.
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf
	// Se o armazém informado não é unitizado, limpa os campos
	If lRet .And. !lUnitiza
		cEndereco:= Space(TamSX3("BE_LOCALIZ")[1])
		cIdUnit  := Space(TamSX3("D0R_IDUNIT")[1])
		cTipUni  := Space(TamSX3("D0R_CODUNI")[1])
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ValEnder
Valida endereço informado
@author  Amanda Rosa Vieira
@version P12
@since   20/04/2017
/*/
//----------------------------------------------------------
Static Function ValEnder(cArmazem,cEndereco)
Local lRet     := .T.
Local cQuery   := ""
Local cAliasSD1:= ""
	SBE->(DbSetOrder(1)) //BE_FILIAL+BE_LOCAL+BE_LOCALIZ
	If !SBE->(DbSeek(xFilial('SBE')+cArmazem+cEndereco))
		WmsMessage(STR0103,WMSA32086) // Endereço inválido!
		lRet := .F.
	Else
		If DLTipoEnd(SBE->BE_ESTFIS) != 5
			WmsMessage(STR0104,WMSA32093) // Somente endereços de estrutura do tipo box/doca podem ser informados!
			lRet := .F.
		EndIf
	EndIf
	If lRet
		cQuery := " SELECT SD1.D1_ENDER"
		cQuery +=   " FROM "+RetSqlName('DCX')+" DCX"
		cQuery +=  " INNER JOIN "+RetSqlName('SD1')+" SD1"
		cQuery +=     " ON SD1.D1_FILIAL = '"+xFilial('SD1')+"'"
		cQuery +=    " AND SD1.D1_DOC = DCX.DCX_DOC"
		cQuery +=    " AND SD1.D1_SERIE = DCX.DCX_SERIE"
		cQuery +=    " AND SD1.D1_FORNECE = DCX.DCX_FORNEC"
		cQuery +=    " AND SD1.D1_LOJA = DCX.DCX_LOJA"
		cQuery +=    " AND SD1.D1_LOCAL = '"+cArmazem+"'"
		cQuery +=    " AND (SD1.D1_ENDER = '"+cEndereco+"' OR"
		cQuery +=         " SD1.D1_ENDER = '"+Space(TamSX3("D1_ENDER")[1])+"')"
		cQuery +=    " AND SD1.D1_QUANT > 0"
		cQuery +=    " AND SD1.D1_OP = ' '"
		cQuery +=    " AND SD1.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCX.DCX_FILIAL = '"+xFilial('DCX')+"'"
		cQuery +=    " AND DCX.DCX_EMBARQ = '"+DCW->DCW_EMBARQ+"'"
		cQuery +=    " AND DCX.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSD1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD1,.F.,.T.)
		If (cAliasSD1)->(EoF())
			WmsMessage(WmsFmtMsg(STR0105,{{"[VAR01]",cArmazem},{"[VAR02]",cEndereco}}),WMSA32092) // Não existe conferência de recebimento prevista para o armazém [VAR01] e endereço [VAR02]!
			lRet := .F.
		EndIf
		(cAliasSD1)->(DbCloseArea())
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ValIdUnit
Valida ID do unitizador informado
@author  Amanda Rosa Vieira
@version P12
@since   20/04/2017
/*/
//----------------------------------------------------------
Static Function ValIdUnit(cIdUnit,cTipUni,cArmazem, cEndereco)
Local lRet        := .T.
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
	oMntUniItem:SetIdUnit(cIdUnit)
	oMntUniItem:oUnitiz:SetArmazem(cArmazem)
	oMntUniItem:oUnitiz:SetEnder(cEndereco)
	oMntUniItem:SetUsaD0Q(.F.)
	If !oMntUniItem:VldIdUnit(2,@cTipUni,.F.)
		If !Empty(oMntUniItem:GetErro())
			WmsMessage(oMntUniItem:GetErro(),WMSA32087)
		EndIf
		lRet := .F.
	EndIf
	If lRet .And. !WMSA320VUN(DCW->DCW_EMBARQ,cIdUnit)
		WmsMessage(WmsFmtMsg(STR0109,{{"[VAR01]",cIdUnit}}),WMSA32095)// O unitizador [VAR01] está sendo utilizado por outro processo.
		lRet := .F.
	EndIf
	oMntUniItem:Destroy()
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} ValidTpUni
Valida código do unitizador informado
@author  Amanda Rosa Vieira
@version P12
@since   20/04/2017
/*/
//----------------------------------------------------------
Static Function ValidTpUni(cTipUni)
Local lRet        := .T.
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
	oMntUniItem:oUnitiz:SetTipUni(cTipUni)
	oMntUniItem:SetUsaD0Q(.F.)
	If !oMntUniItem:VldTipUni()
		WmsMessage(oMntUniItem:GetErro(),WMSA32088)
		lRet := .F.
	EndIf
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} VldRegCof
Valid da tela de registro de conferência
@author  Guilherme A. Metzger
@version P12
@since   06/12/2017
/*/
//----------------------------------------------------------
Static Function VldRegCof(cEndereco,cTipUni,cIdUnit)
	// Ao acessar a tela de registro e informar apenas o armazém,
	// o sistema permite confirmar a inclusão, gerando inconsistências.
	// Por esse motivo é necessário realizar as seguintes validações.
	If lUnitiza
		If Empty(cEndereco)
			WmsMessage(STR0113) // "Informe o Endereço!"
			Return .F.
		EndIf
		If Empty(cTipUni)
			WmsMessage(STR0114) // "Informe o Código do Unitizador!"
			Return .F.
		EndIf
		If Empty(cIdUnit)
			WmsMessage(STR0115) // "Informe o ID do Unitizador!"
			Return .F.
		EndIf
	EndIf
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} WMSA320EST
Estorna unitizador montado na conferência
@author  Amanda Rosa Vieira
@version P12
@since   25/04/2017
/*/
//----------------------------------------------------------
Function WMSA320EST(cEmbarque,cPrdOri,cProd,cLoteCtl,cNumLote,cIdUnit,cOper,lTotal,nQuant)
Local oMntUniItem := WMSDTCMontagemUnitizadorItens():New()
Local aAreaD0S    := D0S->(GetArea())
Local lRet        := .T.
Local cQuery      := ""
Local cAliasDCZ   := ""
Local cAliasD0R   := ""
Default cLoteCtl  := Space(TamSX3("DCZ_LOTE")[1])
Default cNumLote  := Space(TamSX3("DCZ_SUBLOT")[1])
Default nQuant    := 0
Default lTotal    := .T.
	cQuery := " SELECT DCZ.DCZ_IDUNIT,"
	cQuery +=        " DCZ.DCZ_PROD,"
	cQuery +=        " DCZ.DCZ_PRDORI,"
	cQuery +=        " DCZ.DCZ_LOTE,"
	cQuery +=        " DCZ.DCZ_SUBLOT,"
	cQuery +=        " SUM(DCZ.DCZ_QTCONF) DCZ_QTCONF"
	cQuery +=   " FROM "+RetSqlName('DCZ')+" DCZ"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
	If !Empty(cOper)
		cQuery += " AND DCZ.DCZ_OPER = '"+cOper+"'"
	EndIf
	If !Empty(cPrdOri)
		cQuery += " AND DCZ.DCZ_PRDORI = '"+cPrdOri+"'"
	EndIf
	If cProd !=  cPrdOri
		cQuery += " AND DCZ.DCZ_PROD = '"+cProd+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND DCZ.DCZ_LOTE = '"+cLoteCtl+"'"
		If !Empty(cNumLote)
			cQuery += " AND DCZ.DCZ_SUBLOT = '"+cNumLote+"'"
		EndIf
	EndIf
	If !Empty(cIdUnit)
		cQuery +=    " AND DCZ.DCZ_IDUNIT = '"+cIdUnit+"'"
	Else
		cQuery +=    " AND DCZ.DCZ_IDUNIT <> '"+Space(TamSX3("DCZ_IDUNIT")[1])+"'"
	EndIf
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY DCZ.DCZ_IDUNIT,"
	cQuery +=          " DCZ.DCZ_PROD,"
	cQuery +=          " DCZ.DCZ_PRDORI,"
	cQuery +=          " DCZ.DCZ_LOTE,"
	cQuery +=          " DCZ.DCZ_SUBLOT"
	cQuery := ChangeQuery(cQuery)
	cAliasDCZ := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDCZ,.F.,.T.)
	While (cAliasDCZ)->(!EoF())
		oMntUniItem:SetIdUnit((cAliasDCZ)->DCZ_IDUNIT)
		oMntUniItem:SetProduto((cAliasDCZ)->DCZ_PROD)
		oMntUniItem:SetPrdOri((cAliasDCZ)->DCZ_PRDORI)
		oMntUniItem:SetLoteCtl((cAliasDCZ)->DCZ_LOTE)
		oMntUniItem:SetNumLote((cAliasDCZ)->DCZ_SUBLOT)
		oMntUniItem:SetQuant((cAliasDCZ)->DCZ_QTCONF - nQuant)
		//Ajusta quantidade unitizada
		If D0S->(dbSeek(xFilial("D0S")+oMntUniItem:GetIdUnit()+oMntUniItem:GetPrdOri()+oMntUniItem:GetProduto()+oMntUniItem:GetLoteCtl()+oMntUniItem:GetNumLote()))
			RecLock("D0S", .F.)
			D0S->D0S_QUANT -= IIF(lTotal,(cAliasDCZ)->DCZ_QTCONF,nQuant)
			D0S->(MsUnLock())
			If QtdComp(D0S->D0S_QUANT) == QtdComp(0)
				oMntUniItem:GoToD0S(D0S->(Recno()))
				oMntUniItem:ExcludeD0S()
			EndIf
		EndIf
		(cAliasDCZ)->(DbSkip())
	EndDo
	(cAliasDCZ)->(DbCloseArea())
	//Verifica por D0R que não possuam D0S, para excluir.
	cQuery := " SELECT DISTINCT D0R.R_E_C_N_O_ RECNOD0R"
	cQuery +=   " FROM "+RetSqlName('DCZ')+" DCZ"
	cQuery +=  " INNER JOIN "+RetSqlName('D0R')+" D0R"
	cQuery +=     " ON D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
	cQuery +=    " AND D0R.D0R_IDUNIT = DCZ.DCZ_IDUNIT"
	cQuery +=    " AND D0R.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ = '"+cEmbarque+"'"
	If !Empty(cOper)
		cQuery += " AND DCZ.DCZ_OPER = '"+cOper+"'"
	EndIf
	If !Empty(cPrdOri)
		cQuery += " AND DCZ.DCZ_PRDORI = '"+cPrdOri+"'"
	EndIf
	If cProd !=  cPrdOri
		cQuery += " AND DCZ.DCZ_PROD = '"+cProd+"'"
	EndIf
	If !Empty(cLoteCtl)
		cQuery += " AND DCZ.DCZ_LOTE = '"+cLoteCtl+"'"
		If !Empty(cNumLote)
			cQuery += " AND DCZ.DCZ_SUBLOT = '"+cNumLote+"'"
		EndIf
	EndIf
	If !Empty(cIdUnit)
		cQuery +=    " AND DCZ.DCZ_IDUNIT = '"+cIdUnit+"'"
	EndIf
	cQuery +=    " AND NOT EXISTS (SELECT D0S.D0S_IDUNIT"
	cQuery +=                      " FROM "+RetSqlName('D0S')+" D0S"
	cQuery +=                     " WHERE D0S.D0S_FILIAL = '"+xFilial('D0S')+"'"
	cQuery +=                       " AND D0S.D0S_IDUNIT = D0R.D0R_IDUNIT"
	cQuery +=                       " AND D0S.D_E_L_E_T_ = ' ')"
	cQuery +=    " AND DCZ.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasD0R := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasD0R,.F.,.T.)
	While (cAliasD0R)->(!EoF())
		oMntUniItem:oUnitiz:GoToD0R((cAliasD0R)->RECNOD0R)
		oMntUniItem:oUnitiz:ExcludeD0R()
		(cAliasD0R)->(DbSkip())
	EndDo
	(cAliasD0R)->(DbCloseArea())
RestArea(aAreaD0S)
Return lRet
//----------------------------------------------------------
/*/{Protheus.doc} WMSA320EST
Valida ID do unitizador informado. O ID não pode estar sendo utilizado por outro processo (demanda ou conferência).
@author  Amanda Rosa Vieira
@version P12
@since   08/05/2017
/*/
//----------------------------------------------------------
Function WMSA320VUN(cEmbarque,cIdUnit)
Local cQuery    := ""
Local cAliasQry := ""
Local lRet      := .T.
	cQuery := " SELECT DCZ_IDUNIT"
	cQuery +=   " FROM "+RetSqlName('DCZ')+" DCZ"
	cQuery +=  " WHERE DCZ.DCZ_FILIAL = '"+xFilial('DCZ')+"'"
	cQuery +=    " AND DCZ.DCZ_IDUNIT = '"+cIdUnit+"'"
	cQuery +=    " AND DCZ.DCZ_EMBARQ <> '"+cEmbarque+"'"
	cQuery +=    " AND DCZ.D_E_L_E_T_ = ' '"
	cQuery +=  " UNION ALL"
	cQuery += " SELECT D0R.D0R_IDUNIT"
	cQuery +=   " FROM "+RetSqlName('D0R')+" D0R"
	cQuery +=  " WHERE D0R.D0R_FILIAL = '"+xFilial('D0R')+"'"
	cQuery +=    " AND D0R.D0R_IDUNIT = '"+cIdUnit+"'"
	cQuery +=    " AND D0R.D0R_IDDCF <> '"+Space(TamSX3("D0R_IDDCF")[1])+"'"
	cQuery +=    " AND D0R.D_E_L_E_T_ = ' '"
	cQuery +=  " UNION ALL"
	cQuery += " SELECT D14.D14_IDUNIT"
	cQuery +=   " FROM "+RetSqlName('D14')+" D14"
	cQuery +=  " WHERE D14.D14_FILIAL = '"+xFilial('D14')+"'"
	cQuery +=    " AND D14.D14_IDUNIT = '"+cIdUnit+"'"
	cQuery +=    " AND D14.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!EoF())
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} ValCmpExc
Valida se existe algum produto PAI com falta e se dentre os filhos dele, 
existe algum deles que foi conferido como parte com uma quantidade maior 
que o multiplo necessário para compor o total do  PAI conferido.
@author  Jackson Patrick Werka
@version P12
@since   26/06/2018
/*/
//----------------------------------------------------------
Static Function ValCmpExc(cEmbarque)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""

	cQuery := "SELECT DCY.DCY_LOCAL,"
	cQuery +=       " DCY.DCY_PROD,"
	cQuery +=       " DCY.DCY_LOTE"
	cQuery +=  " FROM "+RetSqlName('DCY')+" DCY"
	cQuery += " WHERE DCY.DCY_FILIAL = '"+xFilial('DCY')+"'"
	cQuery +=   " AND DCY.DCY_EMBARQ = '"+cEmbarque+"'"
	cQuery +=   " AND DCY.DCY_PROD = DCY.DCY_PRDORI" // Deve ser o mesmo produto
	cQuery +=   " AND DCY.DCY_QTCONF < DCY.DCY_QTORIG" // Deve estar faltando quantidade a conferir
	cQuery +=   " AND DCY.D_E_L_E_T_ = ' '"
	cQuery +=   " AND EXISTS (SELECT 1" // Deve existir registro para os filhos
	cQuery +=                 " FROM "+RetSqlName('DCY')+" DCY2"
	cQuery +=                " INNER JOIN "+RetSqlName('D11')+" D11"
	cQuery +=                   " ON D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=                  " AND D11.D11_PRDCMP = DCY2.DCY_PROD"
	cQuery +=                  " AND D11.D11_PRDORI = DCY2.DCY_PRDORI"
	cQuery +=                  " AND D11.D_E_L_E_T_ = ' '"
	cQuery +=                " WHERE DCY2.DCY_FILIAL = '"+xFilial('DCY')+"'"
	cQuery +=                  " AND DCY2.DCY_EMBARQ = '"+cEmbarque+"'"
	cQuery +=                  " AND DCY2.DCY_PROD <> DCY2.DCY_PRDORI"
	cQuery +=                  " AND DCY2.DCY_PRDORI = DCY.DCY_PROD" // Com base no produto PAI
	cQuery +=                  " AND DCY2.DCY_LOTE   = DCY.DCY_LOTE" // Com base no produto PAI
	cQuery +=                  " AND DCY2.DCY_SUBLOT = DCY.DCY_SUBLOT" // Com base no produto PAI
	cQuery +=                  " AND (DCY2.DCY_QTCONF / D11.D11_QTMULT) > DCY.DCY_QTCONF"
	cQuery +=                  " AND DCY2.D_E_L_E_T_ = ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		WmsMessage(WmsFmtMsg(STR0119,{{"[VAR01]",(cAliasQry)->DCY_LOCAL},{"[VAR02]",(cAliasQry)->DCY_PROD},{"[VAR03]",(cAliasQry)->DCY_LOTE}}),WMSA32090,5,,,STR0120) // "Existem componentes conferidos em excesso no armazém [VAR01] em relação ao total conferido do produto PAI [VAR02] e lote [VAR03]." ## "Efetue a conferência das quantidades de componentes de forma que os múltiplos correspondam a um produto PAI completo, conferindo a parte excedente dos componentes como um produto avulso."
		lRet := .F.
	EndIf
	(cAliasQry)->(dbCloseArea())
Return lRet

//------------------------------------------------------------------------------
Function WMSA320D14(cEmbarque,lEstorno)
Return Wm320UnD14(cEmbarque,lEstorno)

//------------------------------------------------------------------------------
Function WMSA320DCF(cEmbarque)
Return Wm320UnDCF(cEmbarque)

//------------------------------------------------------------------------------
// Retorna se a rotina está sendo chamada via automação
//------------------------------------------------------------------------------
Static __lAutoma := 0
Function Wm320Autom(lAutoma)
	If lAutoma != Nil
		__lAutoma := lAutoma
	EndIf
Return __lAutoma

//----------------------------------------------------------
/*/{Protheus.doc} Atuqtdcy
Busca os registros que foram estornados 
e limpa o lote quando necessario na DCY
@author  Roselaine Adriano
@version P12
@since   21/05/2020
/*/
//----------------------------------------------------------
Static Function Atuqtdcy(cEmbarque,cTpConf)
Local cAliasCF1 := NIL
Local cAliasCF2 := NIL
Local cAliasCF3 := Nil
Local cSelect   := ""
Local nQtddif   := 0
Local lDtValid  := DCY->(ColumnPos("DCY_DTVAL")) > 0
Local dDtVazia  := cToD("")
Local lWMA320DT := ExistBlock("WMA320DT")

	cSelect := "%"
	If lDtValid
		cSelect += " ,DCY.DCY_DTVAL"
	EndIf
	cSelect += "%"
	IF cTpConf == '1' 
		cAliasCF1 := GetNextAlias()
		BeginSql Alias cAliasCF1
			SELECT DCY.R_E_C_N_O_ RECNODCY, 
				   DCY.DCY_LOCAL, 
				   DCY.DCY_PRDORI, 
				   DCY.DCY_PROD, 
				   DCY_LOTE,
			 	   DCY_SUBLOT,
			 	   DCY.DCY_QTORIG,
			 	   SD1AUX.QTDSD1
				   %Exp:cSelect%
			FROM %Table:DCY% DCY     
			LEFT JOIN (SELECT SD1.D1_COD,
		            		  SUM(SD1.D1_Quant) QTDSD1,
     						  SD1.D1_LOTECTL,
     						  SD1.D1_NUMLOTE
		 	        	 FROM  %Table:DCX% DCX
						INNER JOIN %Table:SD1% SD1
						   ON SD1.D1_FILIAL =  %xFilial:SD1% 
  						  AND SD1.D1_DOC   = DCX.DCX_DOC
						  AND SD1.D1_LOTECTL <> ' '
  						  AND SD1.%NotDel%
  						WHERE DCX.DCX_FILIAL =  %xFilial:DCX%
 						  AND DCX.DCX_EMBARQ =  %Exp:cEmbarque%
						  AND DCX.%NotDel%
						GROUP BY SD1.D1_COD,
     							 SD1.D1_LOTECTL,
     							 SD1.D1_NUMLOtE
					UNION
					SELECT D11_PRDCMP, 
						   SUM(SD1.D1_QUANT * D11_QTMULT) QTDSD1,
  						   SD1.D1_LOTECTL,
  						   SD1.D1_NUMLOTE 
  					  FROM %Table:DCX% DCX
    				 INNER JOIN %Table:SD1% SD1
  					    ON SD1.D1_FILIAL =  %xFilial:SD1%
  					   AND SD1.D1_DOC = DCX.DCX_DOC 
  					   AND SD1.D1_LOTECTL <> ' ' 
  					   AND SD1.%NotDel% 
  					  LEFT JOIN %Table:D11% D11
  					    ON D11.D11_FILIAL = %xFilial:D11%
  					   AND D11.D11_PRODUT = SD1.D1_COD
  					   AND D11.D11_PRDORI = SD1.D1_COD
  					 WHERE  DCX.DCX_FILIAL = %xFilial:D11%
  					   AND DCX.DCX_EMBARQ = %Exp:cEmbarque%
  					   AND DCX.%NotDel% 
 					 GROUP BY D11_PRDCMP,
         			          SD1.D1_LOTECTL, 
						      SD1.D1_NUMLOTE) SD1AUX
        	   ON SD1AUX.D1_COD  = DCY.DCY_PROD
        	  AND SD1AUX.D1_LOTECTL = DCY.DCY_LOTE
        	  AND SD1AUX.D1_NUMLOTE = DCY.DCY_SUBLOT
        	WHERE DCY.DCY_Filial  = %xFilial:DCY%
        	  AND DCY.DCY_EMBARQ  = %Exp:cEmbarque%
        	  AND DCY.DCY_Lote <> ' '
        	  AND DCY.DCY_QTORIG > 0 
        	  AND DCY.DCY_QTCONF = 0 
   	          AND DCY.%NotDel%
		ENDSQL
		Do While (cAliasCF1)->(!Eof())
			IF (cAliasCf1)->DCY_QTORIG > (cAliasCf1)->QtdSd1
                IF Empty((cAliasCf1)->QtdSd1) .OR. (cAliasCf1)->QtdSd1 <= 0 
					//Fazer um select na DCY buscando pelo lote em branco
					cAliasCF3  := GetNextAlias()
					BeginSql Alias cAliasCF3
						SELECT DCY.R_E_C_N_O_ RECNODCY
						FROM  %Table:DCY% DCY
						WHERE DCY.DCY_Filial  = %xFilial:DCY%
        				AND DCY.DCY_EMBARQ  = %Exp:cEmbarque%
				    	AND DCY.DCY_PROD    = %Exp:(cAliasCF1)->DCY_PROD%
						AND DCY.DCY_PRDORI  = %Exp:(cAliasCF1)->DCY_PRDORI%
						AND DCY.DCY_Lote = ' '
        				AND DCY.%NotDel%
					ENDSQL
					IF  (cAliasCF3)->(!Eof())
						DCY->(DbGoTo((cAliasCF3)->RECNODCY))
			 			RecLock('DCY',.F.)
						DCY->DCY_QTORIG  += (cAliasCF1)->DCY_QTORIG
			 			DCY->(MsUnlock())
							
						DCY->(DbGoTo((cAliasCF1)->RECNODCY))
			 			RecLock('DCY',.F.)
						DCY->(DbDelete())
			 			DCY->(MsUnlock())
					ELSE
					    //se nao existir registro sem lote limpa o lote
						DCY->(DbGoTo((cAliasCF1)->RECNODCY))
			 			RecLock('DCY',.F.)
						DCY->DCY_LOTE   := ' '
						DCY->DCY_SUBLOT := ' '
			 			DCY->(MsUnlock())
					ENDIF 
					(cAliasCF3)->(DbCloseArea())
				ELSE
					nQtddif = (cAliasCf1)->DCY_QTORIG - (cAliasCf1)->QtdSd1
				
					DCY->(DbGoTo((cAliasCF1)->RECNODCY))
				 	RecLock('DCY',.F.)
					DCY->DCY_QTORIG -= nQtddif	
					DCY->(MsUnlock())

					//Fazer um select na DCY buscando pelo lote em branco
					cAliasCF2  := GetNextAlias()
					BeginSql Alias cAliasCF2
						SELECT DCY.R_E_C_N_O_ RECNODCY
						FROM  %Table:DCY% DCY
						WHERE DCY.DCY_Filial  = %xFilial:DCY%
        				AND DCY.DCY_EMBARQ  = %Exp:cEmbarque%
					    AND DCY.DCY_PROD    = %Exp:(cAliasCF1)->DCY_PROD%
						AND DCY.DCY_PRDORI  = %Exp:(cAliasCF1)->DCY_PRDORI%
						AND DCY.DCY_Lote = ' '
        				AND DCY.%NotDel%
					ENDSQL
					IF  (cAliasCF2)->(!Eof())
					    DCY->(DbGoTo((cAliasCF2)->RECNODCY))
			 			RecLock('DCY',.F.)
						DCY->DCY_QTORIG += nQtddif	
						DCY->(MsUnlock())
					ELSE 
						RecLock('DCY',.T.)
						DCY->DCY_FILIAL := xFilial('DCY')
						DCY->DCY_EMBARQ := cEmbarque
						DCY->DCY_PRDORI := (cAliasCF1)->DCY_PROD
						DCY->DCY_PROD   := (cAliasCF1)->DCY_PROD
						DCY->DCY_LOTE   := ' '
						DCY->DCY_SUBLOT := ' '
						DCY->DCY_QTORIG := nQtddif
						DCY->DCY_QTCONF := 0
						DCY->DCY_LOCAL  := (cAliasCF1)->DCY_LOCAL
						If lDtValid
							DCY->DCY_DTVAL := dDtVazia
						EndIf
						DCY->(MsUnlock())
						
						If lWMA320DT
							ExecBlock("WMA320DT",.F.,.F.,{DCY->(Recno())})
						EndIf
					EndIF 
					(cAliasCF2)->(DbCloseArea())
				EndIF 
			EndIf 
			(cAliasCF1)->(DbSkip())
		EndDo
		(cAliasCF1)->(DbCloseArea())
	EndIF
Return 

//----------------------------------------------------------
/*/{Protheus.doc} WMA320CBox
Função criada para retornar o x3_cbox do campo DCW_SITEMB pelo fato do campo não ter espaço suficiente para 
todas as opções.
@author  Wander Horongoso
@version P12
@since   18/09/2020
/*/
//----------------------------------------------------------
Function WMA320CBox()
Return STR0122 //'1=Nao Iniciado;2=Vol.Andamento;3=Vol.Confer.;4=Vol.Confer.c/Diverg.;5=Prod.Andamento;6=Prod.Confer.;7=Prod.Confer.c/Diverg Qtd.;8=Prod.Confer.c/Diverg Lote'

