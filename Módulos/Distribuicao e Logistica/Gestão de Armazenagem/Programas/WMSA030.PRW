#Include "PROTHEUS.CH" 
#Include "WMSA030.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE WMSA03001 "WMSA03001"
#DEFINE WMSA03002 "WMSA03002"
#DEFINE WMSA03003 "WMSA03003"
#DEFINE WMSA03004 "WMSA03004"
#DEFINE WMSA03005 "WMSA03005"
#DEFINE WMSA03006 "WMSA03006"
#DEFINE WMSA03007 "WMSA03007"
#DEFINE WMSA03008 "WMSA03008"
#DEFINE WMSA03009 "WMSA03009"
#DEFINE WMSA03010 "WMSA03010"
#DEFINE WMSA03011 "WMSA03011"
//------------------------------------------------------------------------------
/*/{Protheus.doc} WMSA030
Cadastro de Sequencia de Abastecimento
@author Jackson Patrick Werka
@since 21/08/2014
@version 1.0
@obs  Este programa tem por objetivo cadastrar as informações relativas
a sequencia de abastecimento dos produtos, ou seja, a forma como
os produtos são endereçados e expedidos.
/*/
//------------------------------------------------------------------------------
Function WMSA030()
Local aCol, aColAux := {}
Local oBrowse
Local nX 
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)

If AMiIn(39,42)                    // Somente autorizado para OMS e WMS
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DC3")         // Alias da tabela utilizada

	If !lWmsNew
		aCol := oBrowse:LoadColumns('DC3')
		aSize(aCol, Len(aCol)-1)
	
		For nX :=1 to Len(aCol)
			If AllTrim(aCol[nX,12]) <> 'DC3_UMMOV'
				Aadd(aColAux, aCol[nX,12])
			EndIf
		Next nX
	
		oBrowse:SetOnlyFields(aColAux)
	EndIf
	oBrowse:SetMenuDef("WMSA030")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse "Sequencia de Abastecimento"
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()
EndIf
Return Nil
//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0027 ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.WMSA030" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.WMSA030" OPERATION 3 ACCESS 0  // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.WMSA030" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.WMSA030" OPERATION 5 ACCESS 0  // Excluir
	ADD OPTION aRotina TITLE STR0013 ACTION "WMSA030PCP"      OPERATION 9 ACCESS 0  // Copiar

	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("DLG030MNU")
		ExecBlock("DLG030MNU",.F.,.F.)
	EndIf
Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local aCposCab  := {"DC3_CODPRO","DC3_DESPRO","DC3_LOCAL","DC3_REABAS","DC3_PRIEND"} // Campos que nao devem ser exibidos na Grid
Local oModel    := Nil
Local oStruCDC3 := Nil
Local oStruIDC3 := Nil
Local bValid := FWBuildFeature( STRUCT_FEATURE_VALID, "WMS030VFld(A,B,C)") 
Local bWhen := FWBuildFeature( STRUCT_FEATURE_WHEN, "WMS030WFld(A,B)")
Local bInit := FWBuildFeature( STRUCT_FEATURE_INIPAD, "WMS030GDes(A,B)")

	oStruCDC3 := FWFormStruct( 1, "DC3" , { |cCampo| AllTrim(cCampo) == "DC3_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) > 0 } )
	oStruIDC3 := FWFormStruct( 1, "DC3" , { |cCampo| AllTrim(cCampo) == "DC3_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) == 0 } )
	
	oStruCDC3:SetProperty('DC3_REABAS' ,MODEL_FIELD_VALID,bValid)
	oStruIDC3:SetProperty('DC3_TPESTR' ,MODEL_FIELD_VALID,bValid)
	oStruIDC3:SetProperty('DC3_UMMOV' ,MODEL_FIELD_VALID,bValid)
	
	oStruIDC3:SetProperty('DC3_TPESTR' ,MODEL_FIELD_WHEN,bWhen)
	oStruIDC3:SetProperty('DC3_TIPREP' ,MODEL_FIELD_WHEN,bWhen)
	oStruIDC3:SetProperty('DC3_PERREP' ,MODEL_FIELD_WHEN,bWhen)
	oStruIDC3:SetProperty('DC3_PERAPM' ,MODEL_FIELD_WHEN,bWhen)
	
	oStruIDC3:SetProperty('DC3_DESEST' ,MODEL_FIELD_INIT,bInit)
	oStruIDC3:SetProperty('DC3_DESNOR' ,MODEL_FIELD_INIT,bInit)
	
	oModel:= MpFormModel():New("WMSA030",/*bPreValid*/,/*bPosValid*/{ |oModel| PosVldMdl(oModel) },/*bComValid*/,/*bCancel*/)
	oModel:SetDescription(STR0001) // Sequencia de Abastecimento

	oModel:AddFields("MdFieldCDC3",Nil,oStruCDC3,/*prevalid*/,,/*bCarga*/)
	oModel:SetPrimaryKey({"DC3_FILIAL","DC3_LOCAL","DC3_CODPRO","DC3_ORDEM"})

	oModel:AddGrid("MdGridIDC3", "MdFieldCDC3" , oStruIDC3 , /*bLinePre*/ { |oModel,nLinha,cAction,cField| PreVldLin(oModel,nLinha,cAction,cField) }, /*bLinePost*/, /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGridIDC3", { {"DC3_FILIAL","xFilial('DC3')"}, {"DC3_CODPRO","DC3_CODPRO"}, {"DC3_LOCAL","DC3_LOCAL"}, {"DC3_REABAS","DC3_REABAS"}, {"DC3_PRIEND","DC3_PRIEND"} }, DC3->( IndexKey( 1 ) ) )

	oModel:GetModel("MdGridIDC3"):SetUniqueLine({"DC3_TPESTR"})

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local aCposCab  := {"DC3_CODPRO","DC3_DESPRO","DC3_LOCAL","DC3_REABAS","DC3_PRIEND"} // Campos que nao devem ser exibidos na Grid
Local oModel    := FWLoadModel("WMSA030")
Local oView     := FWFormView():New()
Local oStruCDC3 := FWFormStruct( 2, "DC3" , { |cCampo| AScan(aCposCab , AllTrim( cCampo ) ) > 0 } )
Local oStruIDC3 := FWFormStruct( 2, "DC3" , { |cCampo| AScan(aCposCab , AllTrim( cCampo ) ) == 0 } )
Local lWmsNew   := SuperGetMv("MV_WMSNEW",.F.,.F.)

	If !lWmsNew 
		oStruIDC3:RemoveField('DC3_UMMOV')
	EndIf
	
	oView:SetModel(oModel)

	oView:AddField('VwFieldCDC3', oStruCDC3 , 'MdFieldCDC3')
	oView:AddGrid( 'VwGridIDC3', oStruIDC3 , 'MdGridIDC3')

	oView:CreateHorizontalBox("SUPERIOR",35)
	oView:CreateHorizontalBox("INFERIOR",65)

	oView:EnableTitleView('VwFieldCDC3',STR0008) // Produto
	oView:EnableTitleView('VwGridIDC3',STR0009)  // Estruturas

	oView:AddIncrementField( 'VwGridIDC3', 'DC3_ORDEM' )

	oView:AddUserButton(STR0019,'',{|| TrocaOrdem("UP")},STR0020) // Sobe // Move para cima.
	oView:AddUserButton(STR0021,'',{|| TrocaOrdem("DOWN")},STR0022) // Desce // Move para baixo.

	oView:SetOwnerView("VwFieldCDC3","SUPERIOR")
	oView:SetOwnerView("VwGridIDC3","INFERIOR")

Return oView

//-------------------------------------------------------------------//
// Função para validação ao tentar excluir uma linha do GRID
//-------------------------------------------------------------------//
Static Function PreVldLin(oMdGrid,nLinha,cAction,cField)
Local lRet      := .T.
Local aSaveRows := FWSaveRows() // Salvando as linhas
Local oModel    := FWModelActive()
Local oMdField  := oModel:GetModel("MdFieldCDC3")
Local cArmazem  := oMdField:GetValue("DC3_LOCAL")
Local cProduto  := oMdField:GetValue("DC3_CODPRO")
Local cEstFis   := oMdGrid:GetValue("DC3_TPESTR")
Local nI        := 1
Local lValida   := .T.

	If cAction == "DELETE" .And. !Empty(cEstFis)
		// Verifica a estrutura já existe em alguma outra linha
		// Pode ser que na alteração da sequência de abastecimento o usuário
		// tenha inserido uma linha duplicada e esteja tentando excluí-la,
		// neste caso o sistema deve permitir
		For nI := 1 To oMdGrid:Length()
			oMdGrid:GoLine(nI)
			If !oMdGrid:IsDeleted(nI) .And. nLinha != nI .And. cEstFis == oMdGrid:GetValue("DC3_TPESTR")
				lValida := .F.
				Exit
			EndIf
		Next nI
		// Caso não tenha sido encontrada uma linha duplicada, executa a validação de saldo
		If lValida .And. !ValSldEst(cArmazem,cProduto,cEstFis)
			WmsMessage(WmsFmtMsg(STR0023,{{"[VAR01]",cEstFis}}),WMSA03006,5/*MSG_HELP*/) // Existe saldo em estoque na estrutura [VAR01].
			lRet := .F.
		EndIf
	EndIf
	FWRestRows(aSaveRows) // Restaurando as linhas
Return lRet

//----------------------------------------------------------------------------//
// Função para validação ao salvar o modelo
//----------------------------------------------------------------------------//
Static Function PosVldMdl(oModel)
Local lRet      := .T.
Local aSaveRows := FWSaveRows()    // Salvando as linhas
Local oMdField  := oModel:GetModel("MdFieldCDC3")
Local oMdGrid   := oModel:GetModel("MdGridIDC3")
Local nI        := 0
Local cArmazem  := ""
Local cProduto  := ""
Local cEstFis   := ""

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cArmazem  := oMdField:GetValue("DC3_LOCAL")
		cProduto  := oMdField:GetValue("DC3_CODPRO")
		For nI := 1 To oMdGrid:Length()
			oMdGrid:GoLine( nI )
			cEstFis   := oMdGrid:GetValue("DC3_TPESTR")
			If !ValSldEst(cArmazem,cProduto,cEstFis)
				WmsMessage(WmsFmtMsg(STR0023,{{"[VAR01]",cEstFis}}),WMSA03007,5/*MSG_HELP*/) // Existe saldo em estoque na estrutura [VAR01].
				lRet := .F.
				Exit
			EndIf
		Next nI
	EndIf
	FWRestRows( aSaveRows )   // Restaurando as linhas
Return lRet
//----------------------------------------------------------------------------//
// Retorna descrição da estrtura física para o Grid
//----------------------------------------------------------------------------//
Function WMS030GDes(oModel,cField)
Local nLinha := oModel:GetQtdLine()
Local cRet   := " "

	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha > 0
		cRet := ""
	Else
		If cField == "DC3_DESEST"
			cRet := Iif(Inclui," ",Posicione("DC8",1,xFilial("DC8")+DC3->DC3_TPESTR,"DC8_DESEST"))
		ElseIf cField == "DC3_DESNOR"
			cRet := Iif(Inclui," ",Posicione("DC2",1,xFilial("DC2")+DC3->DC3_CODNOR,"DC2_DESNOR"))
		EndIf
	EndIf
Return cRet
//----------------------------------------------------------------------------//
// Função responsável por validar a edição do campo
//----------------------------------------------------------------------------//
Function WMS030WFld(oModel,cField)
Local oModelForm := FWModelActive()
Local lRet       := .T.
Local cEstFis    := ""
	If cField == "DC3_TPESTR"
		If Empty(oModelForm:GetModel("MdFieldCDC3"):GetValue("DC3_LOCAL")) .Or. Empty(oModelForm:GetModel("MdFieldCDC3"):GetValue("DC3_CODPRO"))
			oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03008,STR0024,"",'','') // Informe os campo local e produto primeiro.
			lRet := .F.
		EndIf
		If !Empty(oModel:GetValue("DC3_TPESTR")) .And. !ValSldEst(oModelForm:GetModel("MdFieldCDC3"):GetValue("DC3_LOCAL"),oModelForm:GetModel("MdFieldCDC3"):GetValue("DC3_CODPRO"),oModel:GetValue("DC3_TPESTR"))
			oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03011,WmsFmtMsg(STR0023,{{"[VAR01]",cEstFis}}),"",'','') // Existe saldo em estoque na estrutura [VAR01].
			lRet := .F.
		EndIf
	ElseIf cField $ "DC3_TIPREP|DC3_PERREP|DC3_PERAPM"
		cEstFis := oModel:GetValue("DC3_TPESTR")
		If Empty(cEstFis)
			oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03004,STR0012,"",'','') // Digite a Estrutura Fisica primeiro.
			lRet := .F.
		Else
			DC8->(DbSetOrder(1))
			If DC8->(DbSeek(xFilial('DC8')+cEstFis, .F.)) .And. DC8->DC8_TPESTR != "2"
				oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03003,STR0011,"",'','') // Este campo so pode ser digitado para estruturas do tipo PICKING.
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return lRet
//----------------------------------------------------------------------------//
// Função responsável pela validação dos campos
//----------------------------------------------------------------------------//
Function WMS030VFld(oModel,cField,xValue)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cArmazem  := M->DC3_LOCAL
Local cProduto  := M->DC3_CODPRO

	If cField == "DC3_REABAS"
		If (lRet:=ExistCpo("DC5", xValue))
			DC5->(DbSetOrder(1))
			If DC5->(DbSeek(xFilial("DC5")+xValue, .F.))
				If DC5->DC5_TIPO != "3"
					oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03009,STR0025,STR0026,'','') // Preencher somente com Servicos de Reabastecimento. // Os Servicos de Reabastecimento devem ter  o campo "Tipo de Servico" preenchido com  "3-Internos".
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cField == "DC3_TPESTR"
		If (lRet:=ExistCpo("DC8", xValue))
			If lRet
				SBE->(DbSetOrder(6))
				If !SBE->(MsSeek(xFilial('SBE')+xValue+cArmazem,.F.))
					oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03001,WmsFmtMsg(STR0007,{{"[VAR01]",cProduto},{"[VAR02]",cArmazem},{"[VAR03]",xValue}}),"",'','') // Não existem endereços para o produto [VAR01] no armazém [VAR02] e estrutura [VAR03].
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cField == "DC3_UMMOV"
		//Valida se os cadastros estão configurados para tratar segunda unidade de medida.
		If M->DC3_UMMOV $ ("2|3")
			dbSelectArea('SB1')
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			SB1->(dbSeek(xFilial('SB1')+cProduto))
			If Empty(SB1->B1_SEGUM) .Or. SB1->B1_CONV == 0
				oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',WMSA03010,STR0028,"",'','') //"Para utilizar a segunda unidade de medida é necessário informar a unidade e fator de conversão no cadastro de produto."
				lRet := .F.
			EndIf
		EndIf
		
	EndIf
	RestArea(aAreaAnt)
Return lRet
//----------------------------------------------------------------------------//
// Permite trocar a ordem dos itens no GRID
// cAtion -> UP - Sobe a ordem da estrutura e DOWN - Desce a ordem
//----------------------------------------------------------------------------//
Static Function TrocaOrdem(cAction)
Local oModel   := FWModelActive()
Local oMdGrid  := oModel:GetModel("MdGridIDC3")
Local nLine    := oMdGrid:GetLine()
Local nSoma    := 0
Local aFields  := oMdGrid:GetStruct():GetFields()
Local aData    := Nil
Local nI       := 0
Local aRowOrig := {}

	If oModel:GetOperation() != MODEL_OPERATION_INSERT .And.;
		oModel:GetOperation() != MODEL_OPERATION_UPDATE
		Return .F.
	EndIf

	If cAction == "UP"
		If nLine > 1
			nSoma := -1
		Else
			Return .F.
		EndIf
	Else
		If nLine < oMdGrid:Length()
			nSoma := 1
		Else
			Return .F.
		EndIf
	EndIf
	aData := oMdGrid:GetData() // Pega os dados do modelo
	aRowOrig := AClone(aData[nLine,1,1]) // Copia a linha a ser trocada
	For nI = 1 To Len(aFields)
		If aFields[nI][3] != "DC3_ORDEM"
			aData[nLine,1,1,nI] := aData[nLine+nSoma,1,1,nI] // Altera o valor
			aData[nLine,1,2,nI] := .T. // Indica que o campo foi alterado
			aData[nLine+nSoma,1,1,nI] := aRowOrig[nI] // Altera o valor
			aData[nLine+nSoma,1,2,nI] := .T. // Indica que o campo foi alterado
		EndIf
	Next
	aData[nLine,6] := .T. // Indica que a linha foi alterada
	aData[nLine+nSoma,6] := .T. // Indica que a linha foi alterada
	aData[nLine,8] := .T. // Indica que a linha foi alterada
	aData[nLine+nSoma,8] := .T. // Indica que a linha foi alterada
	oModel:lModify := .T. // Indica que o modelo foi alterado
Return Nil
/*-----------------------------------------------------------------------------
---WMSA030PCP
---Tela de processamento para abrir a cópia
---felipe.m 04/05/2016
-----------------------------------------------------------------------------*/
Function WMSA030PCP()
	Processa( {|| ProcRegua(0), WMSA030CPY() } , STR0029, STR0030 + '...', .F.) // "Copiar Sequencia de Abastecimento"/ "Buscando produtos"
Return
/*-----------------------------------------------------------------------------
---WMSA030CPY
---Copia a sequencia de abastecimento do produto origem para os
---produtos selecionados no listbox
---Alex Egydio 01/06/2005
-----------------------------------------------------------------------------*/
Function WMSA030CPY()
Local aAreaDC3 := DC3->(GetArea())
// Controle de dimensoes de objetos
Local aObjects   := {}
Local aInfo      := {}
Local aPosObj    := {}
Local aSize      := {}
// MsDialog
Local oDlgEsp
// Enchoice
Local nOpcA      := 0
Local oEnch
// ListBox
Local cLbx       := ''
Local oLbx
// Checkbox
Local oAllMark
Local lAllMark
//--
Local aProduto   := {}
Local aSeqAbast  := {}
Local aItemDC3   := {}
Local cAliasNew  := 'SB1'
Local cIndSB1     := ''
Local cQuery      := ''
Local cSeekDC3   := ''
Local lQuery     := .F.
Local nCntFor    := 0
Local n1Cnt      := 0
Local n2Cnt      := 0
Local nIndex     := 0
Local cPesq      := Space(TamSx3("B1_COD")[1])
// ListBox
Local oNoMarked  := LoadBitmap(GetResources(),'LBNO')
Local oMarked    := LoadBitmap(GetResources(),'LBOK')
Local lMVWMSNEW  := SuperGetMv("MV_WMSNEW",.F.,.F.)
	// Inicializa variaveis da enchoice
	M->&('DC3_LOCAL')  := DC3->(FieldGet(FieldPos('DC3_LOCAL')))
	M->&('DC3_CODPRO') := DC3->(FieldGet(FieldPos('DC3_CODPRO')))
	M->&('DC3_DESPRO') := CriaVar('DC3_DESPRO')
	// Obtem todos os produtos que controlam enderecamento
	cAliasNew := GetNextAlias()
	cQuery := "SELECT B1_FILIAL, B1_COD, B1_LOCPAD, B1_DESC, B5_CODZON"
	cQuery +=  " FROM "+RetSqlName('SB1')+" SB1"
	cQuery +=  " INNER JOIN "+RetSqlName('SB5')+" SB5 ON SB5.D_E_L_E_T_ = ' '""
	cQuery +=   " AND B5_FILIAL = '"+xFilial("SB5")+"' AND B5_COD = B1_COD"
	If !SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SB1"
		cQuery +=  " LEFT JOIN "+RetSqlName('SBZ')+" SBZ ON SBZ.D_E_L_E_T_ = ' '"
		cQuery +=   " AND BZ_FILIAL = '"+xFilial("SBZ")+"' AND BZ_COD = B1_COD"
	EndIf

	cQuery += " WHERE SB1.D_E_L_E_T_ = ' '"
	cQuery +=   " AND B1_FILIAL = '"+xFilial("SB1")+"'"
	If SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SB1"
		cQuery += IIf(lMVWMSNEW," AND B5_CTRWMS = '1'"," AND B1_LOCALIZ = 'S'")
	Else
		cQuery += IIf(lMVWMSNEW," AND CASE WHEN SBZ.BZ_CTRWMS IS NULL THEN SB5.B5_CTRWMS ELSE SBZ.BZ_CTRWMS END = '1'"," AND CASE WHEN SBZ.BZ_LOCALIZ IS NULL THEN SB1.B1_LOCALIZ ELSE SBZ.BZ_LOCALIZ END = 'S'")
	EndIf
	cQuery +=   " AND B1_COD NOT IN (SELECT DC3_CODPRO"
	cQuery +=                        " FROM "+RetSqlName('DC3')+" DC3"
	cQuery +=                       " WHERE DC3_FILIAL = '"+xFilial("DC3")+"'"
	cQuery +=                         " AND DC3_CODPRO = B1_COD"
	cQuery +=                         " AND DC3_LOCAL = '"+M->DC3_LOCAL+"'"
	cQuery +=                         " AND DC3.D_E_L_E_T_ = ' ')"
	cQuery += " ORDER BY B1_COD"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
	Do While (cAliasNew)->(!Eof())
		aAdd(aProduto,{.F.,(cAliasNew)->B1_LOCPAD,(cAliasNew)->B1_COD,(cAliasNew)->B1_DESC,(cAliasNew)->B5_CODZON})
		(cAliasNew)->(DbSkip())
	EndDo
	(cAliasNew)->(DbCloseArea())

	If Empty(aProduto)
		WmsMessage(STR0018,WMSA03005) // Todos os produtos que controlam endereçamento já estão com sequencia de abastecimento definida
	Else
		DC3->(DbSetOrder(1))
		DC3->(MsSeek(cSeekDC3:=xFilial('DC3')+M->DC3_CODPRO+M->DC3_LOCAL))
		Do While DC3->(!Eof() .And. DC3->DC3_FILIAL+DC3->DC3_CODPRO+DC3->DC3_LOCAL==cSeekDC3)
			aItemDC3:={}
			// Obtem a sequencia de abastecimento de origem
			For nCntFor:=1 To DC3->(FCount())
				aAdd(aItemDC3,DC3->(FieldGet(nCntFor)))
			Next
			aAdd(aSeqAbast,AClone(aItemDC3))
			DC3->(DbSkip())
		EndDo
		// Dimensoes padroes
		aSize := MsAdvSize()
		aAdd(aObjects,{100,10,.T.,.T.})
		aAdd(aObjects,{100,90,.T.,.T.})
		aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
		aPosObj:= MsObjSize( aInfo, aObjects,.T. )
		DEFINE MSDIALOG oDlgEsp TITLE STR0014 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL   // Copia da Sequencia de Abastecimento

		@ aPosObj[1,1],aPosObj[1,2] BITMAP oBmp RESNAME 'PMSTASK4' SIZE 16,16 NOBORDER PIXEL
		@ aPosObj[1,1],aPosObj[1,2]+10 SAY STR0015 SIZE 50,9 OF oDlgEsp PIXEL   // Origem
		aPosObj[1,1]+=10
		aPosObj[1,3]+=10
		// Monta a enchoice
		oEnch := MsMGet():New('DC3',DC3->(Recno()),2,,,,{'DC3_LOCAL','DC3_CODPRO','DC3_DESPRO','NOUSER'},aPosObj[1], , 3, , , , , ,.T. )

		aPosObj[2,1]+=10
		aPosObj[2,3]+=10
		@ aPosObj[2,1],aPosObj[2,2] BITMAP oBmp RESNAME 'PMSTASK4' SIZE 16,16 NOBORDER PIXEL
		@ aPosObj[2,1],aPosObj[2,2]+10 SAY STR0016 SIZE 50,9 OF oDlgEsp PIXEL   // Destino

		// Marca/desmarca documentos
		@ aPosObj[2,1],aPosObj[2,2]+40 CHECKBOX oAllMark VAR lAllMark PROMPT STR0017 SIZE 68, 09; // Marca/Desmarca todos
		ON CLICK( WmsA030Mrk('2',@oLbx,aProduto,lAllMark) ) OF oDlgEsp PIXEL

		@aPosObj[2,1],aPosObj[2,2]+250 SAY STR0002+" "+RetTitle("B1_COD") OF oDlgEsp PIXEL //"Pesquisar"
		@aPosObj[2,1]-2,aPosObj[2,2]+300 MsGet cPesq PICTURE PesqPict("SB1","B1_COD") F3 "SB1" VALID {||WmsA030Pesq(aProduto,@oLbx,cPesq)} OF oDlgEsp PIXEL

		aPosObj[2,1]+=10
		aPosObj[2,3]+=10
		// Monta listbox
		@ aPosObj[2,1], aPosObj[2,2] LISTBOX oLbx VAR cLbx FIELDS HEADER ;
		' ',OemToAnsi(Posicione('SX3',2,'B1_LOCPAD','X3Titulo()')),OemToAnsi(Posicione('SX3',2,'B1_COD','X3Titulo()')),OemToAnsi(Posicione('SX3',2,'B1_DESC','X3Titulo()')),OemToAnsi(Posicione('SX3',2,'B5_CODZON','X3Titulo()'));
		SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1]-10 OF oDlgEsp PIXEL ON DBLCLICK (WmsA030Mrk('1',@oLbx,aProduto))
		oLbx:SetArray(aProduto)
		oLbx:bLine:={||{Iif(aProduto[oLbx:nAT,01],oMarked,oNoMarked),aProduto[oLbx:nAT,02],aProduto[oLbx:nAT,03],aProduto[oLbx:nAT,04],aProduto[oLbx:nAT,05]}}
		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||nOpcA:=1,oDlgEsp:End()},{||nOpcA:=0,oDlgEsp:End()},,/*aButtons*/)
		If nOpcA == 1
			Begin Transaction
			For nCntFor := 1 To Len(aProduto)
				// Avalia todos os produtos de destino selecionados
				If aProduto[nCntFor,1]
					// Grava a sequencia de abastecimento do produto origem para o(s) produto(s) de destino
					For n1Cnt := 1 To Len(aSeqAbast)
						RecLock('DC3',.T.)
						For n2Cnt := 1 To Len(aSeqAbast[n1Cnt])
							FieldPut(n2Cnt,aSeqAbast[n1Cnt,n2Cnt])
						Next
						DC3->DC3_LOCAL := M->DC3_LOCAL // Armazem da Seq.Abast.Produto Origem
						DC3->DC3_CODPRO:=aProduto[nCntFor,3]
						MsUnlock()
					Next
				EndIf
			Next
			End Transaction
		EndIf
	EndIf
	RestArea(aAreaDC3)
Return
/*-----------------------------------------------------------------------------
---WmsA030Pesq
---Pesquisa Codigo/Descricao do Produto no ListBox da rotina de
---Copia a sequencia de abastecimento
---Flavio Luiz Vicco 30/03/2007
---aLista, Record, (Vetor dos itens do ListBox)
---oLbx, Objeto, (Objeto do LixtBox)
---cPesq, Character, (Campo de pesquisa)
-----------------------------------------------------------------------------*/
Static Function WmsA030Pesq(aLista,oLbx,cPesq)
Local nPos := aScan(aLista,{|x|x[3]>=cPesq})
	If nPos <> oLbx:nAt
		oLbx:nAt := nPos
		oLbx:Refresh()
	EndIf
Return nPos
/*-----------------------------------------------------------------------------
---WmsA030Mrk
---Marca/Desmarca itens do listbox
---Alex Egydio 01/06/2005
---cAcao, Character, (1 = Executado no listbox;2 = Executado no checkbox)
---oLbx, Objeto, (Objeto listbox)
---aProduto, Record, (Vetor contendo os itens do listbox)
---lAllMark, Logico, (Marcar/Desmarcar todos)
-----------------------------------------------------------------------------*/
Static Function WmsA030Mrk(cAcao,oLbx,aProduto,lAllMark)
Local nCntFor := 0
	If cAcao == '1'
		// Marca/Desmarca o item posicionado
		aProduto[ oLbx:nAT, 1 ] := !aProduto[ oLbx:nAT, 1 ]
	ElseIf cAcao == '2'
		// Marca/Desmarca todos
		For nCntFor := 1 To Len(aProduto)
			aProduto[ nCntFor, 1 ] := lAllMark
		Next
	EndIf
	oLbx:Refresh()
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} DLA030AWMS
Cadastro de sequência de abastecimento

@author  Guilherme A. Metzger
@version P11
@since   26/01/15
@obs     Função utilizada no cadastro de produto via Assistente WMS
/*/
//----------------------------------------------------------
Function DLA030AWMS(cLocal,cProduto,cDesPro)
Local oView  := FWLoadView('WMSA030')
Local oModel := FWLoadModel('WMSA030')
Local aCoors := FWGetDialogSize(oMainWnd)
Local oFWMVCWindow
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)
	oView:SetOperation(MODEL_OPERATION_INSERT)
	oView:SetUseCursor(.F.)
	oView:SetCloseOnOk({|| .T.})
	oView:oModel:SetActivate({|oModel| (oModel:SetValue('MdFieldCDC3','DC3_LOCAL',cLocal),;
										oModel:SetValue('MdFieldCDC3','DC3_CODPRO',cProduto),;
										oModel:SetValue('MdFieldCDC3','DC3_DESPRO',cDesPro))})

	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar(.T.)
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered(.T.)
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
	oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
	oFWMVCWindow:SetTitle(X2Nome('DC3'))
	oFWMVCWindow:Activate()
Return

Static Function ValSldEst(cArmazem,cProduto,cEstFis)
Local lRet      := .T.
Local oEstEnder := ""
	If !SuperGetMv("MV_WMSNEW",.F.,.F.)
		nSaldoSBF := SaldoSBF(cArmazem, Nil, cProduto, NIL, NIL, NIL, .F., cEstFis)
		If nSaldoSBF > 0
			lRet := .F.
		EndIf
	Else
		oEstEnder := WMSDTCEstoqueEndereco():New()
		oEstEnder:oEndereco:SetArmazem(cArmazem)
		oEstEnder:oProdLote:SetProduto(cProduto)
		oEstEnder:oEndereco:SetEstFis(cEstFis)
		If oEstEnder:ConsultSld(.T.) > 0
			lRet := .F.
		EndIf
	EndIf
Return lRet
