#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA335.CH"

#DEFINE WMSA33501 "WMSA33501"
#DEFINE WMSA33502 "WMSA33502"
#DEFINE WMSA33503 "WMSA33503"
#DEFINE WMSA33504 "WMSA33504"
#DEFINE WMSA33505 "WMSA33505"
#DEFINE WMSA33506 "WMSA33506"
#DEFINE WMSA33507 "WMSA33507"
#DEFINE WMSA33508 "WMSA33508"
#DEFINE WMSA33509 "WMSA33509"
#DEFINE WMSA33510 "WMSA33510"
#DEFINE WMSA33511 "WMSA33511"
#DEFINE WMSA33512 "WMSA33512"
#DEFINE WMSA33513 "WMSA33513"
#DEFINE WMSA33514 "WMSA33514"
#DEFINE WMSA33515 "WMSA33515"
#DEFINE WMSA33516 "WMSA33516"
#DEFINE WMSA33517 "WMSA33517"
#DEFINE WMSA33518 "WMSA33518"
#DEFINE WMSA33519 "WMSA33519"
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335
Estrutura de produtos WMS
@author Marlon Fernando Quandt
@since 16/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function WMSA335()
Local oTree
Local aCoors := FWGetDialogSize (oMainWnd )
Local oDlg := Nil

	If WMSA335VER()

		aNewButton := {}
		Aadd(aNewButton, {"addButton", {|| WMSA335MEN(STR0002, MODEL_OPERATION_INSERT, oTree)}, STR0002, STR0002}) // Detalhes // Detalhes // Incluir // Incluir // Incluir
		Aadd(aNewButton, {"addButton", {|| WMSA335MEN(STR0003, MODEL_OPERATION_UPDATE, oTree)}, STR0004, STR0004}) // Conferência // Conferência // Alterar // Editar // Editar
		Aadd(aNewButton, {"addButton", {|| WMSA335MEN(STR0005, MODEL_OPERATION_DELETE, oTree)}, STR0005, STR0005}) // Conferência // Conferência// Excluir // Excluir // Excluir

		While .T.
			DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] Pixel //

			// Cria a Tree
			oTree := DbTree():New(0,0,0,0,oDlg,,/*bRClick*/,.T.,/*lDisable*/,/*oFont*/,/*cHeaders*/)
			oTree:Align := CONTROL_ALIGN_ALLCLIENT

			// Cria os itens da Tree
			WMSA335TRE(oTree,SB5->B5_COD)

			// Activate MsDialog oDlg Center
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| .T.,oDlg:End() },{|| oDlg:End() },/*lMsgDel*/,aNewButton) CENTERED

			If VldRateio()
				Exit
			EndIf
		EndDo

	EndIf
Return Nil
//-------------------------------------------------------------------
// ModelDef
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := MPFormModel():New("WMSA335",/*bPreValidacao*/,{|oModel|WMSA335POS(oModel)},{|oModel|WMSA335CMT(oModel)},/*bCancel*/)
Local oStruD11 := FWFormStruct( 1, "D11")
Local bValid := {|oModel,cField,xValor,xValAnt| ValidField(oModel,cField,xValor,xValAnt)  }

	oStruD11:SetProperty('D11_QTMULT',MODEL_FIELD_VALID,bValid)

	oModel:AddFields("D11FIELDS", Nil, oStruD11)
	oModel:SetActivate({|oModel| WMSA335ST(oModel)})
	oModel:GetPrimaryKey()
Return oModel
//------------------------------------------------
// ViewDef
//------------------------------------------------
Static Function ViewDef()
Local oView    := FWFormView():New()
Local oModel   := FWLoadModel( "WMSA335" )
Local oStruD11 := FWFormStruct( 2, "D11" )

	oView:SetModel( oModel )
	oStruD11:RemoveField("D11_PRODUT")
	oStruD11:RemoveField("D11_SEQUEN")
	oStruD11:SetProperty("D11_PRDORI", MVC_VIEW_CANCHANGE , .F. )
	oView:AddField("VIEW_FIELDS",oStruD11,"D11FIELDS")
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335VER
Verificação do produto, se pode possuir estrutura.
@author felipe.m
@since 16/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WMSA335VER()
Local lRet      := .T.

	dbSelectArea("D11")
	D11->( dbSetOrder(2))
	If D11-> ( dbSeek(xFilial("D11")+SB5->B5_COD) )
		WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",D11->D11_PRODUT}}),WMSA33502,1,.T.) // Este produto pertence a estrutura do produto [VAR01].
		lRet := .F.
	EndIf

	//Validação para o item pai da estrutura
	If lRet .AND. !IntWMS(SB5->B5_COD)
	    WmsMessage(WmsFmtMsg(STR0021,{{"[VAR01]",SB5->B5_COD}}),WMSA33519,1,.T.) // "Produto não possui controle WMS: [VAR01]."
		lRet := .F.
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335TRE
Montagem da tree de produtos
@author felipe.m
@since 16/12/2014
@version 1.0
@param oTree, objeto, (Descrição do parâmetro)
@param cProdut, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function WMSA335TRE(oTree, cProdut)
Local cQuery    := ""
Local cPrompt   := ""
Local aAreaAnt  := GetArea()
Local cAliasD11 := GetNextAlias()
Local aAreaSB1  := SB1 -> (GetArea())

	cQuery := "SELECT D11.D11_PRODUT, D11.D11_PRDORI, D11.D11_PRDCMP, D11.D11_QTMULT"
	cQuery +=  " FROM "+RetSqlName("D11")+" D11"
	cQuery += " WHERE D11.D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=   " AND D11.D11_PRODUT = '"+cProdut+"'"
	cQuery +=   " AND D11.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY D11.D11_SEQUEN"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasD11,.F.,.T.)
	dbSelectArea(cAliasD11)

	cPrompt := AllTrim(cProdut)+" - "+Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_DESC")
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:AddItem(cPrompt+SPACE(50),cProdut,"FOLDER5","FOLDER6",/*cFile1*/,/*cFile2*/,1)
	While (cAliasD11)->(!EOF())
		// posiciona no pai para incluir o próximo item logo abaixo
		oTree:TreeSeek((cAliasD11)->D11_PRDORI)
		cPrompt := AllTrim((cAliasD11)->D11_PRDCMP)+" - "+AllTrim(Posicione("SB1",1,xFilial("SB1")+(cAliasD11)->D11_PRDCMP,"B1_DESC"))+" ("+Alltrim(Transform((cAliasD11)->D11_QTMULT, "@E 999,999,999,999.99"))+")"
		oTree:AddItem(cPrompt,(cAliasD11)->D11_PRDCMP,"FOLDER5","FOLDER6",/*cFile1*/,/*cFile2*/,2)
		// posiciona no item recem criado para manter a estrutura aberta
		oTree:TreeSeek((cAliasD11)->D11_PRDCMP)
		(cAliasD11)->(dbSkip())
	EndDo
	(cAliasD11)->(dbCloseArea())
	RestArea(aAreaAnt)
	RestArea(aAreaSB1)

	// posiciona no pai para nao ficar com o ultimo no criado posicionado
	oTree:TreeSeek(cProdut)

	// Indica o término da contrução da Tree
	oTree:EndUpdate()

	// Encerra criacao da tree
	oTree:EndTree()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335MEN
Menu de manipulação dos dados da tree
@author felipe.m
@since 16/12/2014
@version 1.0
@param cTitulo, character, (Título da opção do menu)
@param cOpcao, character, (Operação a ser executada)
@param oTree, objeto, (Objeto tree a ser manipulado)
/*/
//-------------------------------------------------------------------
Static Function WMSA335MEN(cTitulo, cOpcao, oTree)
Local aAreaSB5  := {}
Local cQuery    := ""
Local cAliasQry := ""
Local lContinua := .T.

	// Verifica se produto principal
	If (cOpcao == MODEL_OPERATION_INSERT .Or. cOpcao == MODEL_OPERATION_DELETE)
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("D12")+" D12"
		cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12.D12_PRDORI = '"+SB5->B5_COD+"'"
		cQuery +=    " AND D12.D12_STATUS > '1'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			WmsMessage(WmsFmtMsg(STR0018,{{"[VAR01]",SB5->B5_COD}}),WMSA33515,5/*MSG_HELP*/) // Operação inválida, produto [VAR01] possui movimentação WMS pendentes (D12)!
			lContinua := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
		If lContinua
			cQuery := "SELECT 1"
			cQuery +=  " FROM "+RetSqlName("D14")+" D14"
			cQuery += " WHERE D14.D14_FILIAL = '"+xFilial("D14")+"'"
			cQuery +=   " AND D14.D14_PRODUT = '"+SB5->B5_COD+"'"
			cQuery +=   " AND D14.D14_PRODUT <> D14.D14_PRDORI"
			cQuery +=   " AND D14.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				WmsMessage(WmsFmtMsg(STR0020,{{"[VAR01]",SB5->B5_COD}}),WMSA33516,5/*MSG_HELP*/) // Operação inválida, produto [VAR01] possui estoque por endereço (D14).
				lContinua := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
		If lContinua
			// Verifica se produto principal possui movimentação de estoque ativo
			// Existindo somente movimentação de estoque estornada deverá permitir a cpo
			cQuery := " SELECT 1"
			cQuery +=   " FROM "+RetSqlName("D13")+" D13"
			cQuery +=  " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
			cQuery +=    " AND D13.D13_PRDORI = '"+SB5->B5_COD+"'"
			cQuery +=    " AND D13.D13_USACAL = '1'"
			cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				WmsMessage(WmsFmtMsg(STR0014,{{"[VAR01]",SB5->B5_COD}}),WMSA33518,5/*MSG_HELP*/) // Operação inválida, produto [VAR01] possui movimentação de estoque realizada (D13).
				lContinua := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf

	If lContinua
		D11->( dbSetOrder(2))
		If D11->( dbSeek(xFilial("D11")+oTree:GetCargo()) ) .OR. cOpcao == MODEL_OPERATION_INSERT
			aAreaSB5 := SB5->(GetArea())
			FWExecView(cTitulo,"WMSA335",cOpcao,/*oDlg*/,{ || .T. },{ || .T. },50,/*aEnableButtons*/,{ || .T. },/*cOperatId*/,/*cToolBar*/,/*oModelAct*/ )
			RestArea(aAreaSB5)

			WMSA335TRE(oTree, SB5->B5_COD)
		EndIf
	EndIf
Return

Static Function ValidField(oModel,cField,xValor,xValAnt)
Local aAreaAnt  := GetArea()
Local lRet      := .T.
Local cQuery    := ""
Local cAliasQry := ""
	If cField == "D11_QTMULT"
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. xValor != xValAnt
			//Verifica se produto principal possui movimentação de estoque
			cQuery := " SELECT 1"
			cQuery +=   " FROM "+RetSqlName("D13")
			cQuery +=  " WHERE D13_FILIAL = '"+xFilial("D13")+"'"
			cQuery +=    " AND D13_PRODUT = '"+oModel:GetValue('D11_PRDCMP')+"'"
			cQuery +=    " AND D13_PRDORI = '"+oModel:GetValue('D11_PRDORI')+"'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			If !(cAliasQry)->(Eof())
				WmsMessage(STR0015,WMSA33510,5/*MSG_HELP*/) // A quantidade múltipla não pode ser alterada, pois já existe movimentação de estoque para o produto.
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaAnt)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335POS
PosValid modelo de dados
@author felipe.m
@since 16/12/2014
@version 1.0
@param oModel, objeto, (Modelo de dados a ser validado)
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function WMSA335POS(oModel)
Local aAreaD11  := D11 -> (GetArea())
Local aAreaSB1  := SB1 -> (GetArea())
Local aAreaSB5  := SB5 -> (GetArea())
Local cAliasQry := ""
Local cOpcao    := oModel:getOperation()
Local lRet      := .T.
Local cQuery    := ""

	dbSelectArea("D11")
	D11->( dbSetOrder(2))
	D11->( dbSeek(xFilial("D11")+oModel:GetModel('D11FIELDS'):GetValue('D11_PRDCMP')) )

	If cOpcao ==  MODEL_OPERATION_INSERT
		cQuery := " SELECT D11_PRDORI, SUM(D11_RATEIO) RATEIO"
		cQuery +=   " FROM "+RetSqlName("D11")
		cQuery +=  " WHERE D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=    " AND D11_PRDORI = '"+D11->D11_PRDORI+"'"
		cQuery +=    " AND D11_PRDCMP <> '"+oModel:GetModel('D11FIELDS'):GetValue('D11_PRDCMP')+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY D11_PRDORI"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof()) .And. ((cAliasQry)->RATEIO + oModel:GetModel('D11FIELDS'):GetValue('D11_RATEIO')) > 100
			WmsMessage(STR0016,WMSA33511,5/*MSG_HELP*/) // Quantidade do rateio ultrapassa 100%.
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	If lRet .And. (cOpcao ==  MODEL_OPERATION_INSERT .Or. cOpcao == MODEL_OPERATION_DELETE)
		cQuery := " SELECT 1"
		cQuery +=   " FROM "+RetSqlName("D12")
		cQuery +=  " WHERE D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12_PRODUT = '"+oModel:GetModel('D11FIELDS'):GetValue('D11_PRDCMP')+"'"
		cQuery +=     "AND D12_PRDORI = '"+oModel:GetModel('D11FIELDS'):GetValue('D11_PRDORI')+"'"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		If (cAliasQry)->(!Eof())
			WmsMessage(STR0018,WMSA33513,5/*MSG_HELP*/) // Operação inválida, produto [VAR01] possui movimentação WMS!
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	If lRet .And. cOpcao == MODEL_OPERATION_INSERT
		If oModel:getModel('D11FIELDS'):getValue('D11_PRODUT') == oModel:getModel('D11FIELDS'):getValue('D11_PRDCMP')
			WmsMessage(STR0008,WMSA33504,5/*MSG_HELP*/) // Não é possível cadastrar o produto como componente de sua própria estrutura
			lRet := .F.
		EndIf

		If lRet
			dbSelectArea("D11")
			D11->( dbSetOrder(1))
			If D11->( dbSeek(xFilial("D11")+oModel:getModel('D11FIELDS'):getValue('D11_PRDCMP')) )
				WmsMessage(STR0009,WMSA33505,5/*MSG_HELP*/)// Este produto já possui estrutura cadastrada
				lRet := .F.
			EndIf
		EndIf

		If lRet
			dbSelectArea("D11")
			D11->( dbSetOrder(2))
			If D11->( dbSeek(xFilial("D11")+oModel:getModel('D11FIELDS'):getValue('D11_PRDCMP')) )
				WmsMessage(WmsFmtMsg(STR0010,{{"[VAR01]",D11->D11_PRODUT}}),WMSA33506,5/*MSG_HELP*/) // Este produto já pertence a estrutura do produto [VAR01].
				lRet := .F.
			EndIf
		EndIf

		If lRet
			SB5->(DbSeek(xFilial("SB5")+oModel:getModel('D11FIELDS'):getValue('D11_PRDCMP')))
			If RetFldProd(SB5->B5_COD,"B5_CTRWMS") <> "1"
				WmsMessage(STR0012,WMSA33507,5/*MSG_HELP*/) // Produto não controla WMS
				lRet := .F.
			EndIf
		EndIf

		If lRet
			If Posicione("SB1",1,xFilial("SB1")+oModel:getModel('D11FIELDS'):getValue('D11_PRDORI'),"B1_RASTRO") <> Posicione("SB1",1,xFilial("SB1")+oModel:getModel('D11FIELDS'):getValue('D11_PRDCMP'),"B1_RASTRO")
				WmsMessage(STR0011,WMSA33508,5/*MSG_HELP*/) // Produto componente deve possuir o mesmo controle de rastro do produto origem.
				lRet := .F.
			EndIf
		EndIf
	ElseIf cOpcao == MODEL_OPERATION_DELETE
		cQuery := "SELECT COUNT(1) QTDFIL"
		cQuery +=  " FROM "+RetSqlName("D11")+" D11"
		cQuery += " WHERE D11.D11_FILIAL = '"+xFilial("D11")+"'"
		cQuery +=   " AND D11.D11_PRODUT = '"+D11->D11_PRODUT+"'"
		cQuery +=   " AND D11.D11_PRDORI = '"+D11->D11_PRDCMP+"'"
		cQuery +=   " AND D11.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY D11.D11_FILIAL, D11.D11_PRODUT, D11.D11_PRDCMP"
		cQuery := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		dbSelectArea(cAliasQry)
		If (cAliasQry)->QTDFIL > 0
		    If WmsQuestion(STR0007,WMSA33503) // Este item possui outros filhos, deseja realmente excluir?
		    	DelFilhos(D11->D11_PRDCMP)
		    EndIf
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

	RestArea(aAreaD11)
	RestArea(aAreaSB1)
	RestArea(aAreaSB5)
Return lRet

Static Function VldRateio()
Local lRet := .T.
Local cAliasD11 := ""

	cQuery := " SELECT D11_PRDORI, SUM(D11_RATEIO) RATEIO"
	cQuery +=   " FROM "+RetSqlName("D11")
	cQuery +=  " WHERE D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=    " AND D11_PRODUT = '"+SB5->B5_COD+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D11_PRDORI"
	cQuery := ChangeQuery(cQuery)
	cAliasD11 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasD11,.F.,.T.)
	While (cAliasD11)->(!Eof())
		If (cAliasD11)->RATEIO != 100
			WmsMessage(WmsFmtMsg(STR0017,{{"[VAR01]",(cAliasD11)->D11_PRDORI}}),WMSA33512,5/*MSG_HELP*/) // Quantidade de rateio dos componentes do produto [VAR01] não somam 100%.
			lRet := .F.
		EndIf
		(cAliasD11)->(dbSkip())
	EndDo
	(cAliasD11)->(dbCloseArea())

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DelFilhos
Função recursiva de exclusão dos filhos ralacionados ao pai
@author felipe.m
@since 16/12/2014
@version 1.0
@param cCod, character, (Código do produto pai)
/*/
//-------------------------------------------------------------------
Static Function DelFilhos(cCod)
Local aAreaD11 := Nil

	dbSelectArea("D11")
	D11->( dbSetOrder(3))
	D11->( dbSeek(xFilial("D11")+cCod) )
	While D11->(!EOF()) .And. D11->D11_FILIAL == xFilial("D11") .And. D11->D11_PRDORI == cCod
		aAreaD11 := D11 -> (GetArea())
		DelFilhos(D11->D11_PRDCMP)
		RestArea(aAreaD11)
		RecLock("D11", .F.)
		D11->( DbDelete() )
		D11->( MsUnLock() )

		D11->(dbSkip())
	EndDo

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335ST
Inicialização da tree
@author felipe.m
@since 16/12/2014
@version 1.0
@param oModel, objeto, (Modelo da dados a ser manipulado)
/*/
//-------------------------------------------------------------------
Static Function WMSA335ST(oModel)
	If oModel:getOperation() == MODEL_OPERATION_INSERT
		If Empty(D11->D11_PRODUT)
			oModel:GetModel("D11FIELDS"):SetValue("D11_PRODUT", SB5->B5_COD)
			oModel:GetModel("D11FIELDS"):SetValue("D11_PRDORI", SB5->B5_COD)
			oModel:getModel('D11FIELDS'):SetValue('D11_MNTPRD',"2")
		Else
			oModel:GetModel("D11FIELDS"):SetValue("D11_PRODUT", D11->D11_PRODUT)
			oModel:GetModel("D11FIELDS"):SetValue("D11_PRDORI", D11->D11_PRDCMP)
		EndIf
	EndIf
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} WMSA335CMT
Função de commit do modelo de dados
@author Amanda.Vieira
@since 18/05/2016
@version 1.0
@param oModel, objeto, (Modelo de dados)
/*/
//-------------------------------------------------------------------
Static Function WMSA335CMT(oModel)
Local aAreaD11  := D11->(GetArea())
Local cQuery    := ""
Local cAliasD11 := Nil

	cQuery := " SELECT 1"
	cQuery +=   " FROM "+RetSqlName("D11")
	cQuery +=  " WHERE D11_FILIAL = '"+xFilial("D11")+"'"
	cQuery +=    " AND D11_PRODUT = '"+SB5->B5_COD+"'"
	cQuery +=    " AND D11_MNTPRD <> '"+oModel:getModel('D11FIELDS'):getValue('D11_MNTPRD')+"'"
	cQuery +=    " AND D11_PRDCMP <> '"+oModel:GetModel('D11FIELDS'):GetValue('D11_PRDCMP')+"'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	cQuery +=  " GROUP BY D11_PRDORI"
	cQuery := ChangeQuery(cQuery)
	cAliasD11 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasD11,.F.,.T.)
	If (cAliasD11)->(!Eof())
		dbSelectArea("D11")
		D11->( dbSetOrder(1))//D11_FILIAL+D11_PRODUT
		D11->( dbSeek(xFilial("D11")+oModel:getModel('D11FIELDS'):getValue('D11_PRODUT')) )

		If oModel:getModel('D11FIELDS'):getValue('D11_MNTPRD') <> D11->D11_MNTPRD
			While D11->(!EOF()) .And. D11->D11_FILIAL == xFilial("D11") .And. D11->D11_PRODUT == oModel:getModel('D11FIELDS'):getValue('D11_PRODUT')
				RecLock("D11", .F.)
				D11->D11_MNTPRD := oModel:getModel('D11FIELDS'):getValue('D11_MNTPRD')
				D11->( MsUnLock() )
				D11->(dbSkip())
			EndDo
			WmsMessage(STR0019,WMSA33514,5/*MSG_HELP*/) //O valor do campo 'Monta Produto' foi alterado para todos os produtos.
		EndIf
	EndIf
	FWFormCommit(oModel)
	RestArea(aAreaD11)
Return .T.
