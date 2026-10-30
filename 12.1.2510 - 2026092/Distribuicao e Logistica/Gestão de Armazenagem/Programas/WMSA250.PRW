#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA250.CH"

#DEFINE WMSA25001 "WMSA25001"
#DEFINE WMSA25002 "WMSA25002"

/*
+---------+--------------------------------------------------------------------+
|Função   | WMSA250 - Cadastro de Produto x Zona                               |
+---------+--------------------------------------------------------------------+
|Autor    | Alex Egydio                                                        |
+---------+--------------------------------------------------------------------+
|Data     | 05/12/2000                 |Revisão  | 27/05/2015                  |
+---------+--------------------------------------------------------------------+
|Objetivo | Um produto pode estar em mais de uma zona. Esta amarracao          |
|         | Produto x Zona determina o fluxo de enderecamento, a medida que a  |
|         | capacidade da zona de armazenagem for esgotando.                   |
+---------+--------------------------------------------------------------------+
*/
Function WMSA250()
Local oBrowse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DCH")         // Alias da tabela utilizada
	oBrowse:SetMenuDef("WMSA250")   // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription(STR0001) // Descrição do browse "Produto x Zona"
	oBrowse:SetAmbiente(.F.)        // Desabilita opção Ambiente do menu Ações Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita opção WalkThru do menu Ações Relacionadas
	oBrowse:Activate()
Return Nil
//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0  // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.WMSA250" OPERATION 2 ACCESS 0  // Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.WMSA250" OPERATION 3 ACCESS 0  // Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.WMSA250" OPERATION 4 ACCESS 0  // Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.WMSA250" OPERATION 5 ACCESS 0  // Excluir
	// Ponto de entrada utilizado para inserir novas opcoes no array aRotina
	If ExistBlock("DLG250MNU")
		ExecBlock("DLG250MNU",.F.,.F.)
	EndIf
Return(aRotina)

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local aCposCab  := {"DCH_CODPRO","DCH_DESPRO"} // Campos que nao devem ser exibidos na Grid
Local oModel    := Nil
Local oStruCDCH := Nil
Local oStruIDCH := Nil

	oStruCDCH := FWFormStruct( 1, "DCH" , { |cCampo| AllTrim(cCampo) == "DCH_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) > 0 } )
	oStruIDCH := FWFormStruct( 1, "DCH" , { |cCampo| AllTrim(cCampo) == "DCH_FILIAL" .Or. AScan(aCposCab , AllTrim( cCampo ) ) == 0 } )

	oStruIDCH:SetProperty('DCH_DESZON', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,'WMS250GDes(A,B)'))
	oStruIDCH:SetProperty('DCH_CODZON', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID,'WMS250CodF()'))

	oModel:= MpFormModel():New("WMSA250",/*bPreValid*/,/*bPosValid*/{ |oModel| PosVldMdl(oModel) },/*bComValid*/,/*bCancel*/)
	oModel:SetDescription(STR0001) // Produto x Zona

	oModel:AddFields("MdFldDCH",Nil,oStruCDCH,/*prevalid*/,,/*bCarga*/)
	oModel:SetPrimaryKey({"DCH_FILIAL","DCH_CODPRO"})

	oModel:AddGrid("MdGrdDCH", "MdFldDCH" , oStruIDCH , /*bLinePre*/ { |oModel,nLinha,cAction,cField| PreVldLin(oModel,nLinha,cAction,cField) }, /*bLinePost*/ , /*bPre*/ , /*bPost*/,/*bLoad*/)
	oModel:SetRelation( "MdGrdDCH", { {"DCH_FILIAL","xFilial('DCH')"}, {"DCH_CODPRO","DCH_CODPRO"} }, DCH->( IndexKey( 2 ) ) )

	oModel:GetModel("MdGrdDCH"):SetUniqueLine({"DCH_CODZON"})
Return oModel
//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local aCposCab  := {"DCH_CODPRO","DCH_DESPRO"} // Campos que nao devem ser exibidos na Grid
Local oModel    := FWLoadModel("WMSA250")
Local oView     := FWFormView():New()
Local oStruCDCH := FWFormStruct( 2, "DCH" , { |cCampo| AScan(aCposCab , AllTrim( cCampo ) ) > 0 } )
Local oStruIDCH := FWFormStruct( 2, "DCH" , { |cCampo| AScan(aCposCab , AllTrim( cCampo ) ) == 0 } )

	oView:SetModel(oModel)

	oView:AddField('VwFldDCH', oStruCDCH , 'MdFldDCH')
	oView:AddGrid( 'VwGrdDCH', oStruIDCH , 'MdGrdDCH')

	oView:CreateHorizontalBox("SUPERIOR",35)
	oView:CreateHorizontalBox("INFERIOR",65)

	oView:EnableTitleView('VwFldDCH',STR0007) // Produto
	oView:EnableTitleView('VwGrdDCH',STR0008) // Zonas Armazenagem

	oView:AddIncrementField( 'VwGrdDCH', 'DCH_ORDEM' )

	oView:SetOwnerView("VwFldDCH","SUPERIOR")
	oView:SetOwnerView("VwGrdDCH","INFERIOR")
Return oView

//-------------------------------------------------------------------//
// Função para validação ao tentar excluir uma linha do GRID
//-------------------------------------------------------------------//
Static Function PreVldLin(oMdGrid,nLinha,cAction,cField)
Local lRet := .T.
Local cCodZona  := ""
	If cAction == "DELETE"
	   cCodZona := oMdGrid:GetValue("DCH_CODZON")
		If HasSldZona(M->DCH_CODPRO,cCodZona)
			oMdGrid:GetModel():SetErrorMessage('MdGrdDCH',,,,WMSA25001,WmsFmtMsg(STR0009,{{"[VAR01]",cCodZona}}),STR0010) // Exclusão da zona de armazenagem [VAR01] não permitida. // Existe saldo nos endereços da zona de armazenagem.
			lRet := .F.
		EndIf
	EndIf
Return lRet

//----------------------------------------------------------------------------//
// Função para validação ao salvar o modelo
//----------------------------------------------------------------------------//
Static Function PosVldMdl(oModel)
Local lRet      := .T.
Local aSaveRows := FWSaveRows()    //Salvando as linhas
Local oMdField  := oModel:GetModel("MdFldDCH")
Local oMdGrid   := oModel:GetModel("MdGrdDCH")
Local nI        := 0
Local cProduto  := ""
Local cCodZona  := ""

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cProduto  := oMdField:GetValue("DCH_CODPRO")
		For nI := 1 To oMdGrid:Length()
			oMdGrid:GoLine( nI )
			cCodZona  := oMdGrid:GetValue("DCH_CODZON")
			If HasSldZona(cProduto,cCodZona)
				oModel:SetErrorMessage('MdGrdDCH',,,,WMSA25002,WmsFmtMsg(STR0009,{{"[VAR01]",cCodZona}}),STR0010) // Exclusão da zona de armazenagem [VAR01] não permitida. // Existe saldo nos endereços da zona de armazenagem.
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
Function WMS250GDes(oModel,cField)
Local nLinha := oModel:GetQtdLine()
Local cRet   := ""
	
	// Impede que a descrição apareça na inclusão de itens durante a alteração
	If nLinha == 0 .And. !Inclui
		cRet := Posicione( "DC4", 1, xFilial("DC4")+DCH->DCH_CODZON, "DC4_DESZON" )                                            
	EndIf
Return cRet
//----------------------------------------------------------------------------//
// Valida se zona existe
//----------------------------------------------------------------------------//
Function WMS250CodF()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local oModelZon := oModel:GetModel("MdGrdDCH")
	
	DC4->(dbSetOrder(1))
	If DC4->(DbSeek(xFilial("DC4")+M->DCH_CODZON))
		oModelZon:SetValue( "DCH_DESZON" , Padr(DC4->DC4_DESZON,TamSx3("DCH_DESZON")[1] ) )
	Else
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf
	
Return lRet
//----------------------------------------------------------------------------//
// Função para validação se existe saldo na zona de armazenagem
//----------------------------------------------------------------------------//
Static Function HasSldZona(cProduto,cCodZona)
Local lRet      := .F.
Local aAreaAnt  := GetArea()
Local cQuery    := ''
Local cAliasSBE := ''

	cAliasSBE := GetNextAlias()
	cQuery := "SELECT SBE.R_E_C_N_O_ RECSBE"
	cQuery +=  " FROM "+RetSqlName('SBE')+" SBE"
	cQuery += " WHERE BE_FILIAL = '"+xFilial('SBE')+"'"
	cQuery +=   " AND BE_CODZON = '"+cCodZona+"'"
	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		// Saldos no enderecos
		cQuery += " AND (EXISTS"
		cQuery += "(SELECT 1 FROM "+RetSqlName('SBF')+" SBF"
		cQuery += " WHERE BF_FILIAL = '"+xFilial('SBF')+"'"
		cQuery += " AND SBF.BF_LOCAL = SBE.BE_LOCAL"
		cQuery += " AND SBF.BF_LOCALIZ = SBE.BE_LOCALIZ"
		cQuery += " AND SBF.BF_PRODUTO = '"+cProduto+"'"
		cQuery += " AND SBF.BF_QUANT > 0 "
		cQuery += " AND SBF.D_E_L_E_T_ = ' ')"
		// Saldos no RF
		If SuperGetMV('MV_RADIOF') == 'S'
			cQuery += " OR EXISTS"
			cQuery += "(SELECT 2 FROM "+RetSqlName('SDB')+" SDB"
			cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial('SDB')+"'"
			cQuery +=   " AND SDB.DB_ESTORNO = ' '"
			cQuery +=   " AND SDB.DB_ATUEST = 'N'"
			cQuery +=   " AND SDB.DB_PRODUTO = '"+cProduto+"'"
			cQuery +=   " AND SDB.DB_LOCAL = SBE.BE_LOCAL"
			cQuery +=   " AND SDB.DB_ENDDES = SBE.BE_LOCALIZ"
			cQuery +=   " AND SDB.DB_STATUS IN ('-','2','3','4')"
			cQuery +=   " AND SDB.D_E_L_E_T_ = ' ')"
		EndIf
		cQuery += ")"
	Else
		// Saldos no enderecos
		cQuery +=   " AND EXISTS"
		cQuery +=        " (SELECT 1 FROM "+RetSqlName('D14')+" D14"
		cQuery +=          " WHERE D14_FILIAL = '"+xFilial('D14')+"'"
		cQuery +=            " AND D14.D14_LOCAL = SBE.BE_LOCAL"
		cQuery +=            " AND D14.D14_ENDER = SBE.BE_LOCALIZ"
		cQuery +=            " AND D14.D14_PRODUT = '"+cProduto+"'"
		cQuery +=            " AND (D14.D14_QTDEST+D14.D14_QTDEPR) > 0"
		cQuery +=            " AND D14.D_E_L_E_T_ = ' ')"
	EndIf
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasSBE,.F.,.T.)
	If (cAliasSBE)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasSBE)->(DbCloseArea())
	RestArea(aAreaAnt)
Return lRet
