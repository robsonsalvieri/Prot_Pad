#INCLUDE "LOCA102.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC nOldQtd   := 0 // Usada para devolver o valor antes da alteração
STATIC cItemLast := ""

/*/{Protheus.doc} LOCA102
Rotina para linkar os itens da Nota de Devolução baixada pelo Totvs Transmite ( Totvs Colaboração)
com os itens de contrato que ainda não foram devolvidos
Serão ligados pelo codigo do produto
@type function
@version 25.10
@author Alexandre Circenis
@since 8/8/2025

/*/
FUNCTION LOCA102()

Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

Private cCadastro := STR0001 //"Vincular XMl de Entrada"
PRIVATE aRotina	:= Menudef()

	if !lMvLocBac
        Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),;
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,;   //"Inconsistência nos dados."
		{STR0003})   //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
        Return .F.
	endif
	
	cItemLast := ""

    oBrowse:= FWmBrowse():New()

    oBrowse:SetDescription( cCadastro ) 
    oBrowse:SetAlias( 'SDS' )
    oBrowse:AddLegend( "SDS->DS_STATUS == 'P'"  , "RED"     , STR0004	)  //"Documento Gerado"
 	oBrowse:AddLegend( "SDS->DS_STATUS == 'E'"  , "BR_PRETO" , STR0005) //"Documento c/ Ocorrência"
	oBrowse:AddLegend( "SDS->DS_STATUS == 'B'"  , "BR_MARROM", STR0006) //"Docto. Pendente Rev. Cadastral"
	oBrowse:AddLegend( "SDS->DS_TIPO   == 'D'"  , "YELLOW"  , STR0007	)   //"Documento de Devolução"
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetWalkthru(.F.)
    oBrowse:OptionReport(.F.)

  	oBrowse:SetFilterDefault( "DS_TIPO = 'D' ") // Só trazer os tipos Devolução
  
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do menu preenchendo o array aRotina
@type function
@version 25.10 
@author Alexandre Circenis
@since 8/8/2025
/*/
static Function MenuDef()
PRIVATE aRotina	:= {}

ADD OPTION aRotina TITLE STR0008 ACTION 'COMCOLVIS'	OPERATION 2 ACCESS 0 //STR0008 //"Visualizar"
ADD OPTION aRotina TITLE STR0009 ACTION 'LOCA102VIEW'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0  //"Vincular XML"

Return aRotina

/*/{Protheus.doc} MODELDEF
Definição do modelo para LInkar SDT com FPA
@type function
@version 25.10
@author Alexandre Circenis
@since 8/8/2025
@return variant, Objeto Model para Linkar SDT com FPA
/*/
STATIC FUNCTION MODELDEF()

Local oStruSDS := FWFormStruct( 1, 'SDS', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruSDT := FWFormStruct( 1, 'SDT', /*bAvalCampo*/,.T. )
Local oModel
Local oStruFPA   := FWFormModelStruct():New()
Local bLinPreNEB	:= {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| fLinePreSep(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

Loca102STR(oStruSDT, "DT_LOCAL", '1', .F., '001')
Loca102STR(oStruSDT, "DT_PICM", '1', .F., '001')
Loca102STR(oStruSDT, "DT_CFOP", '1', .F., '001')
oStruSDT:AddField("Devolvida", ' ', 'DT_QTDDEV', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], ,{|| .F.} , {}, .F.)

oStruFPA:AddField(STR0010, ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.)  //"Devolvido"
Loca102STR(oStruFPA, "DT_ITEM", '1', .F., '001')
Loca102STR(oStruFPA, "D2_DOC", '1', .F., '001')
Loca102STR(oStruFPA, "D2_SERIE", '1', .F., '002')
Loca102STR(oStruFPA, "D2_ITEM", '1', .F., '003')
Loca102STR(oStruFPA, "D2_COD", '1', .F., '004')
Loca102STR(oStruFPA, "D2_UM", '1', .F., '004')
Loca102STR(oStruFPA, "D2_LOCAL", '1', .F., '004')
Loca102STR(oStruFPA, "D2_LOTECTL", '1', .F., '004')
Loca102STR(oStruFPA, "FPA_PROJET", '1', .F., '005')
Loca102STR(oStruFPA, "D2_IDENTB6", '1', .F., '005')
Loca102STR(oStruFPA, "FPA_OBRA", '1', .F., '006')
Loca102STR(oStruFPA, "FPA_PRODUT", '1', .F., '007')
Loca102STR(oStruFPA, "FPA_GRUA", '1', .F., '008')
Loca102STR(oStruFPA, "FPA_AS", '1', .F., '009')
Loca102STR(oStruFPA, "FPA_QUANT", '1', .F., '010')
Loca102STR(oStruFPA, "D2_PRCVEN", '1', .F., '010')

oStruFPA:AddField(STR0011, ' ', 'QTDSEL', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], ,{|| .F.} , {}, .F.) //"Já Selecionada"
oStruFPA:AddField(STR0012, ' ', 'QTDNEW', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2],{|| Loca102VDE()} , , {}, .F.)  //"Qtde Devolvida"

oStruFPA:SetProperty("QTDNEW",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK') .or. FWFldGet('QTDNEW')>0 " ))
oStruFPA:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA102CHK()" ))

oModel := MPFormModel():New( 'LOCA102',/*bPreValidacao*/, , /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New( 'COMP012MODEL', /*bPreValidacao*/, { | oMdl | COMP012POS( oMdl ) } , /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SDS_MASTER', /*cOwner*/, oStruSDS, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'SDT_GRID',  'SDS_MASTER', oStruSDT, , , , ,)
oModel:AddGrid( 'FPA_GRID',  'SDT_GRID', oStruFPA, bLinPreNEB , , , ,)

oModel:SetRelation( 'SDT_GRID', { { 'DT_FILIAL', 'DS_FILIAL' } ,{"DT_FORNEC","DS_FORNEC"},{"DT_LOJA","DS_LOJA"},;
{"DT_DOC","DS_DOC"},{"DT_SERIE","DS_SERIE"} }, SDT->( IndexKey( 8 ) ) )

oModel:SetRelation( 'FPA_GRID', { { 'DT_ITEM', 'DT_ITEM' } } )

oModel:GetModel('FPA_GRID'):bLoad :=  {|oGrid, lCopy| Loca102LdG(oGrid, lCopy)}
// Adionar os campos de Resumo
oModel:AddCalc( 'RODAPE', 'SDS_MASTER', 'SDT_GRID', 'DT_QUANT', 'QTDPEN', 'FORMULA',{|| .T.} ,,STR0014, {|oModel| Loca102PVen()} ,10,2 )  //"Quantidade Pendente"
oModel:AddCalc( 'RODAPE', 'SDT_GRID', 'FPA_GRID', 'QTDNEW', 'QTDDEV', 'FORMULA',,,STR0013,{|oModel| Loca102PDev()},13,5 ) //"Quantidade Devolvida"
//oModel:AddCalc( 'RODAPE', 'SDT_GRID', 'FPA_GRID', 'QTDSEL', 'QTDSEL', 'SUM', ,,STR0015,,10,2 )  //"Quantidade Selecionada"

oModel:GetModel( 'SDT_GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'SDT_GRID' ):SetNoDeleteLine(.T.)

oModel:GetModel( 'SDT_GRID' ):SetOnlyView(.T.)

oModel:GetModel( 'FPA_GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'FPA_GRID' ):SetNoDeleteLine(.T.)
oModel:GetModel( 'FPA_GRID' ):SetDescription( STR0016 ) //'Itens Remessados ainda não devolvidos'

oModel:SetOnlyQuery('SDS_MASTER' ,.T.)
oModel:SetOnlyQuery('SDT_GRID' ,.T.)
oModel:SetOnlyQuery('FPA_GRID' ,.T.)

oModel:SetDescription(STR0050) //"Documento de Entrada"
oModel:SetVldActivate( {|oModel| Loca102LNK( oModel ) })

Return oModel

/*/{Protheus.doc} VIEWDEF
Definicao da view da rotina de Link entre SDT com FPA
@type function
@version  25.10
@author Alexandre Circenis
@since 8/8/2025
@return variant, Objeto view para linkar SDT com FPA
/*/
Static Function VIEWDEF
Local oView      := Nil
Local oModel     := FWLoadModel("LOCA102")
Local oStruSDS   := FWFormStruct(2, "SDS")
Local oStruSDT   := FWFormStruct(2, "SDT",,.T.)
Local oStruFPA   := FWFormViewStruct():New()
Local oCalc

oStruSDT:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

oStruFPA:AddField( 'MARK','001',' ',' ',, 'Check')
Loca102STR(oStruFPA, "D2_DOC", '2', .F., '002')
Loca102STR(oStruFPA, "D2_SERIE", '2', .F., '003')
Loca102STR(oStruFPA, "D2_ITEM", '2', .F., '004')
Loca102STR(oStruFPA, "D2_COD", '2', .F., '005')
Loca102STR(oStruFPA, "FPA_PROJET", '2', .F., '006')
Loca102STR(oStruFPA, "FPA_OBRA", '2', .F., '007')
Loca102STR(oStruFPA, "FPA_PRODUT", '2', .F., '008')
Loca102STR(oStruFPA, "FPA_AS", '2', .F., '009')
Loca102STR(oStruFPA, "FPA_GRUA", '2', .F., '010')
Loca102STR(oStruFPA, "FPA_QUANT", '2', .F., '011')
Loca102STR(oStruFPA, "D2_PRCVEN", '2', .F., '012')

oStruFPA:AddField( 'QTDSEL', '013', STR0017, STR0015,, "N",X3Picture("FQ5_QTD"))  //"Quantidade Selecionada" //"Qtde Selecionada"
oStruFPA:AddField( 'QTDNEW', '014', STR0012, STR0013,, "N",X3Picture("FQ5_QTD"))  //"Quantidade Devolvida" //"Qtde Devolvida"

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField("VIEW_SDS",oStruSDS,"SDS_MASTER")
    oView:AddGrid("VIEW_SDT",oStruSDT,"SDT_GRID")
    oView:AddGrid("VIEW_FPA",oStruFPA,"FPA_GRID")

  	oCalc  	:= FWCalcStruct(oModel:GetModel('RODAPE'))
	oView:AddField( 'VIEW_CALC', oCalc, 'RODAPE' )

    oView:CreateHorizontalBox( 'CABEC', 20)	
    oView:CreateHorizontalBox( 'BOX_1', 35)
    oView:CreateHorizontalBox( 'BOX_2', 35)
    oView:CreateHorizontalBox( 'BOX_3', 10)
     
    oView:SetOwnerView('VIEW_SDS','CABEC') 
    oView:SetOwnerView('VIEW_SDT','BOX_1')
    oView:SetOwnerView('VIEW_FPA','BOX_2')
	oView:SetOwnerView('VIEW_CALC','BOX_3')
    
	oView:SetCloseOnOk({|| .T.})

 	oView:AddUserButton(STR0018,"OK",{|oView| LOCA102GER(oView)},STR0018,,,.T.)// //STR0018 //"Confirmar o Link"
	oView:EnableControlBar(.T.)
	oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.})

Return oView

/*/{Protheus.doc} LOCA102VIEW
Rotina principal para Linkar SDT com FPA
@type function
@version  25.10
@author Alexandre Circenis
@since 8/8/2025
/*/
Function LOCA102VIEW()
Local oView
Local aButtons := {}

oView := FWLoadView("LOCA102")
aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			  {.F.,Nil},{.F.,NIL},{.T.,STR0019},{.F.,Nil},{.F.,Nil},; //STR0019 //"Cancelar"
			  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
oExecView := FWViewExec():New()
oExecView:setView(oView)
oExecView:setTitle(STR0051)  //"Vincular com itens do contrato"

//oExecView:setSource("LOCA229B")
oExecView:setModal(.F.)
oExecView:SetButtons(aButtons)
oExecView:setOperation(MODEL_OPERATION_UPDATE)
oExecView:openView(.T.)

return .T.

/*/{Protheus.doc} Loca102LdG
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 25.10
@author Alexandre Circenis
@since 8/8/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function Loca102LdG( oMdl, lCopy)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local aParam    := {}
	Local cProduto  := oMdl:GetModel():GetModel("SDT_GRID"):GetValue("DT_COD")
	
	if cItemLast <> oMdl:GetModel():GetModel("SDT_GRID"):GetValue("DT_ITEM")
		cItemLast := oMdl:GetModel():GetModel("SDT_GRID"):GetValue("DT_ITEM")

		cQuery += "SELECT  ? , SD2.*, SD2.R_E_C_N_O_ RECNO, FPA.*"
		
		cQuery += " FROM "+ RetSqlName("SD2") + " SD2"
		
		cQuery += " INNER JOIN " + RetSqlName("FP1") + " FP1 "
		cQuery += " ON FP1.FP1_FILIAL = '" + xFilial("FP1") + "' "
		cQuery += " AND FP1.FP1_CLIORI = SD2.D2_CLIENTE "
		cQuery += " AND FP1.FP1_LOJORI = SD2.D2_LOJA "
		cQuery += " AND FP1.D_E_L_E_T_ = ' ' "
		cQuery += " INNER JOIN " + RetSqlName("FPA") + " FPA " 
		cQuery += " ON FPA.FPA_FILIAL  = '" + xFilial("FPA") + "' "
		cQuery += " AND FPA.FPA_PROJET = FP1.FP1_PROJET"
		cQuery += " AND FPA.FPA_OBRA = FP1.FP1_OBRA"
		cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
		cQuery += " AND	FPA.FPA_NFREM = SD2.D2_DOC "
		cQuery += " AND FPA.FPA_SERREM = SD2.D2_SERIE "
		cQuery += " AND FPA.FPA_NFRET  = ' ' "
		cQuery += " AND FPA_PRODUT = SD2.D2_COD "
		cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "
		cQuery += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
		cQuery += " AND SD2.D2_CLIENTE = ?"
		cQuery += " AND SD2.D2_LOJA = ? "
		cQuery += " AND SD2.D2_COD = ? "
		cQuery += " AND SD2.D2_QTDEDEV < D2_QUANT "

		cQuery += " AND SD2.D_E_L_E_T_ = ' '"
			
		cQuery := ChangeQuery(cQuery)
		
		Aadd( aParam, cItemLast)
		
		Aadd( aParam, SDS->DS_FORNEC )
		Aadd( aParam, SDS->DS_LOJA )
		Aadd( aParam, cProduto )

	//-- Executa QUERY
		MPSysOpenQuery(cQuery,cAliasT,,,aParam)
	//-- Formata Campos Da Query
		aStruQry := (cAliasT)->(DbStruct())

		For nLinha := 1 To Len(aStruQry)
			If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
				TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
			Endif
		Next nLinha
	/*
	FWLoadByAlias
	Função que realiza a carga de um submodelo baseado em um alias existente

	@param oObj         Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
	@param cAlias       Alias para carga .
	@param cAliasReal   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
																se nao for informado usa a tabela definida na estrutura do objeto.
	@param cFieldRecno  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
																deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
																RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
	@param lCopy        Apenas para compatibilidade, Nao usar
	@param lQuery       Indica que o alias foi criado a partir de uma query.
	*/

	// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
		aDados := FWLoadByAlias( oMdl:GetModel():GetModel("FPA_GRID") , cAliasT , 'SD2' ,  , Nil , .t. )

	//-- Fecha Arquivo Temporário
		If Select(cAliasT) > 0
			(cAliasT)->(DbCloseArea())
		EndIf

		RestArea(aArea)
	endif
Return( aDados )

/*/{Protheus.doc} Loca102STR
Função que adiciona um campo em uma estrutura Model/View com base no dicionario
@type function
@version  25.10
@author Alexandre Circenis
@since 8/8/2025
@param oStr, object, Objseto do tipo estrutura onde o campo será adicionado
@param cField, character, Campo que será adicionado
@param cTipo, character, 1=Model;2=View
@param lUpdate, logical, Se .t. o campo poderá ser alterado em caso contrario usar .F.
@param cOrdem, character, Quando for o tipo view indica a posição do campo na tela
/*/
Function Loca102STR(oStr, cField, cTipo, lUpdate, cOrdem)

DEFAULT lUpdate := .F.

if cTipo = '1' // Model
	oStr:AddField(	GetSx3Cache( cField , "X3_TITULO") ,; //<cTitulo >,
					GetSx3Cache( cField , "X3_DESCRIC"),; //<cTooltip >
					cField,; // <cIdField >
					GetSx3Cache( cField , "X3_TIPO"),; //<cTipo >
					GetSx3Cache( cField , "X3_TAMANHO"),; // <nTamanho >
					GetSx3Cache( cField , "X3_DECIMAL"),; // [ nDecimal ]
					MontaBlock("{ || "+GetSx3Cache(cField,"X3_VALID")+" }"),; // [ bValid ]
					MontaBlock("{ || "+GetSx3Cache(cField,"X3_WHEN")+" }"),; // [ bWhen ]
					StrTokArr( allTrim( GetSx3Cache(cField, "X3_CBOX") ), ";" ),; // [ aValues ]
					.F.,; // [ lObrigat ]
					MontaBlock("{ || "+GetSx3Cache(cField,"X3_RELACAO")+" }"),; // [ bInit ]
					.F.,; //  <lKey >
					!lUpdate,; // [ lNoUpd ]
					.T.,; // [ lVirtual ]
					"") // [ cValid ])
elseif cTipo = '2'
	oStr:AddField( cField ,;//< cIdField >
	     			cOrdem ,; // <cOrdem >
					GetSx3Cache( cField , "X3_TITULO") ,; // <cTitulo >
					GetSx3Cache( cField , "X3_DESCRIC"),; // <cDescric >
					{},; // <aHelp >
					GetSx3Cache( cField , "X3_TIPO"),; // <cType >
					GetSx3Cache( cField , "X3_PICTURE"),; // <cPicture >
					MontaBlock("{ || "+GetSx3Cache(cField,"X3_PICTVAR")+" }"),; // <bPictVar > 
					GetSx3Cache(cField,"X3_F3"),; // <cLookUp >
					lUpdate,; // <lCanChange >
					GetSx3Cache(cField,"X3_FOLDER"),; // <cFolder >
					GetSx3Cache(cField,"X3_AGRUP"),; // <cGroup >
					StrTokArr( allTrim( GetSx3Cache(cField, "X3_CBOX") ), ";"),; // [ aComboValues ]
					,; // [ nMaxLenCombo ]
					,; // <cIniBrow >
					.T.,; // <lVirtual > 
					GetSx3Cache(cField,"X3_PICTVAR"),; // <cPictVar >
					.F.,;// [ lInsertLine ]
					)// [ nWidth ])
Endif

return

/*/{Protheus.doc} Loca102VDE
Valida a quantidade informada no campo de Quantidade Devolvida
@type function
@version 25.10 
@author Alexandre Circenis
@since 8/8/2025
@return variant, .T. se o valor for valido .F. caso contrario
/*/
FUNCTION Loca102VDE()
Local lRet := .T.
Local oModel := FwModelActive()
Local oSDTGrid := oModel:GetModel("SDT_GRID")
Local oFPAGrid := oModel:GetModel("FPA_GRID")
Local nQtdDev   := M->QTDNEW
Local nLineSDT
Local aSavRow
Local nX
Local cAS

// Quantidade devolvida não pode ultrapassar a quantidade da Nota
if nQtdDev- nOldQtd > oSDTGrid:GetValue("DT_QUANT") - oSDTGrid:GetValue("DT_QTDDEV")
	oModel:SetErrorMessage("","","","","LOCA102V_01",STR0020,)  //"A quantidade devolvida não pode ser maior que a quantidade do documento de devolução."
	lRet := .F.
Endif

if lRet .and. nQtdDev > (oFPAGrid:GetValue("FPA_QUANT") - oFPAGrid:GetValue("QTDSEL"))
	// Quantidade Devolvida não pode ultrapassar a quantidade ainda não devolvida do contrato 
	oModel:SetErrorMessage("","","","","LOCA102V_02",STR0021,)  //"A quantidade devolvida não pode ser maior que a quantidade em posse do cliente ou devolvida em outros itens do dcumento de devolução."
	lRet := .F.
Endif

if lRet // Está valida preencher a quantidade selecionada nas demais Grids para não selecionar novamente.
	aSavRow := FWSaveRows()
	nLineSDT := oSDTGrid:GetLine()
	cAS      := oFPAGrid:GetValue("FPA_AS")
	oSDTGrid:LoadValue("DT_QTDDEV", oSDTGrid:GetValue("DT_QTDDEV") - nOldQtd + nQtdDev)
	for nX := 1 to oSDTGrid:Length()
		if nX <> nLineSDT
			oSDTGrid:GoLine(nX)
			if oFPAGrid:SeekLine({{"FPA_AS", cAS}})
				oFPAGrid:LoadValue("QTDSEL", oFPAGrid:GetValue("QTDSEL")- nOldQtd + nQtdDev)
			endif
		endif
	next nX
	
	FWRestRows(aSavRow) 
endif

Return lRet

/*/{Protheus.doc} fLinePreSep
Usada na pre-validação da linha dos itens da FPA
@type function
@version  25.10
@author Alexandre Circenis
@since 8/8/2025
@param oGridModel, object, Objeto grid que será validado
@param nLine, numeric, NUmero da linha do grid posicionada
@param cAction, character, Ação que está sendo executada
@param cIDField, character, Campo que está sendo acessado
@param xValue, variant, Valor 
@param xCurrentValue, variant, Valor atual do campo 
@return variant, .T. se puder realizar a operação
/*/
Static Function fLinePreSep(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet 		:= .T.
	Local oModel	:= oGridModel:GetModel()
	Local nOperation	:= oModel:GetOperation()

	If cAction == "SETVALUE" // valida se pode alterar o campo

		If (cIDField $ "QTDNEW") .AND. nOperation == MODEL_OPERATION_UPDATE
			nOldQtd := xCurrentValue
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} LOCA102CHK
Realiza a validação se o item poderá ser selecionado
@type function
@version  25.10
@author Alexandre Circenis
@since 8/8/2025
@return variant, .T. se o item puder ser selecionado
/*/
FUNCTION LOCA102CHK()
	Local oModel := FwModelActive()
	Local oGrid     := oModel:GetModel("FPA_GRID")
	Local oGridSDT  := oModel:GetModel("SDT_GRID")
	Local oRodape   := oModel:GetModel("RODAPE")
	Local lRet := .T.

	if FwFldGet("MARK")

		// Verifica se o item pode ser selecionado por causa do valor
		if FwFldGet("D2_PRCVEN") <> oGridSDT:GetValue("DT_VUNIT") 
			oModel:SetErrorMessage("","","","","LOCA102_12",STR0023,STR0022,)  //"Selecionar outro item." //"O valor unitario do item na nota de remessa está diferente do valor do documento de retorno."
			lRet := .F.

		// Verificar se existe saldo para selecionar 
		elseif FwFldGet("FPA_QUANT") <= FwFldGet("QTDSEL")
			oModel:SetErrorMessage("","","","","LOCA102_10",STR0024,STR0022,)  //"Selecionar outro item." //"Esse item do Contrato já foi integralmente selecionado para devolução."
			lRet := .F.

		elseif oGridSDT:GetValue("DT_QUANT") - oGridSDT:GetValue("DT_QTDDEV") <= 0 
			oModel:SetErrorMessage("","","","","LOCA102_11",STR0026,STR0025,)  //"Verifica a lista de devolução para verificar se os itens foram selecionados corretamente." //"Esse item da nota se encontra integralmente devolvido."
			lRet := .F.

		Else
			// Gatilhar os campos calculados 
			if Empty(oGrid:GetValue("QTDNEW"))

				oGrid:SetValue( "QTDNEW", Min( FWFldGet("FPA_QUANT") - FWFldGet("QTDSEL") , oGridSDT:GetValue("DT_QUANT") - oGridSDT:GetValue("DT_QTDDEV")))
				
			endif
		endif
	else
		oGrid:LoadValue( "MARK", .T.)
		oGrid:SetValue( "QTDNEW", 0 )
		oGrid:LoadValue( "MARK", .F.)

	endif

Return lRet

/*/{Protheus.doc} Loca102Tok
Valida os dados antes de efetuar o processamento
@type function
@version 25.10
@author Alexandre Circenis
@since 8/8/2025
@param oModel, object, Objeto do Tipo model que será validado
@return variant, .T. se os dados estiverem consistentes
/*/
Function Loca102Tok(oModel)
Local lRet := .T.
Local oSDTGrid := oModel:GetModel("SDT_GRID")
Local oFPAGrid := oModel:GetModel("FPA_GRID")

Local nLineSDT
Local aSavRow
Local nX
Local cAS

if lRet 
	aSavRow := FWSaveRows()
	nLineSDT := oSDTGrid:GetLine()
	cAS      := oFPAGrid:GetValue("FPA_AS")
	for nX := 1 to oSDTGrid:Length()

		oSDTGrid:GoLine(nX)
		nQtdDev := oModel:GetModel("RODAPE"):GetValue("QTDDEV")
		if nQtddev <> oSDTGrid:GetValue("DT_QUANT")
			
			Help(NIL, NIL, "LOCA102_03",,STR0029+ oSDTGrid:GetValue("DT_ITEM") +STR0027, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0028}) //" do documento não está totalmente associado aos itens do contrato." //"Verificar a quantidade da Nota e a quantidade selecionada" //"A quantidade devolvida do item "
			lRet := .F.
			Exit
		endif

	next nX

	FWRestRows(aSavRow) 
endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSF1
Monta cabecalho para rotina automatica com os dados do SDS posicionado.
@type function
@author	Totvs
@since 05/06/12
/*/
//------------------------------------------------------------------- 

Static Function MontaSF1(lCteClass,nComCol1,lAtuImp)
Local aRet	 	 	:= {}
Local cTipoNF	 	:= ""
Local aAreaSDS		:= SDS->(GetArea())
Local cHoraRMT 		:= SuperGetMv("MV_HORARMT",.F.,"2")
Local lHoraNfe		:= SuperGetMv("MV_HORANFE",.F.,.F.)
Local aHorario 		:= {}
Local lDSPedagio	:= SDS->(FieldPos("DS_VALPEDG")) > 0
Local lDSNaturez	:= SDS->(FieldPos("DS_NATUREZ")) > 0
Local oObjImp   	:= ComTransmite():New()

Default lCteClass	:= .F.
Default nComCol1	:= 0
Default lAtuImp		:= .F.

cTipoNF := SDS->DS_TIPO

aAdd(aRet,{"F1_FILIAL",  SDS->DS_FILIAL,	Nil})
aAdd(aRet,{"F1_TIPO",  SDS->DS_TIPO,			Nil})
aAdd(aRet,{"F1_FORMUL",  SDS->DS_FORMUL,	Nil})
aAdd(aRet,{"F1_DOC",     SDS->DS_DOC,		Nil})
aAdd(aRet,{"F1_SERIE",   SDS->DS_SERIE,		Nil})
aAdd(aRet,{"F1_EMISSAO", SDS->DS_EMISSA,	Nil})
aAdd(aRet,{"F1_FORNECE", SDS->DS_FORNEC,	Nil})
aAdd(aRet,{"F1_LOJA",    SDS->DS_LOJA,		Nil})
aAdd(aRet,{"F1_ESPECIE", SDS->DS_ESPECI,	Nil})
aAdd(aRet,{"F1_DTDIGIT", dDataBase,			Nil})
aAdd(aRet,{"F1_EST",     SDS->DS_EST,		Nil})

If !lAtuImp
	aAdd(aRet,{"F1_CHVNFE",  SDS->DS_CHAVENF,	Nil})
Endif

If SDS->DS_TIPO <> "T"
	If !lAtuImp
		aAdd(aRet,{"F1_FRETE",   SDS->DS_FRETE,		Nil})
	Endif
EndIf

If !lAtuImp
	aAdd(aRet,{"F1_DESPESA", SDS->DS_DESPESA,	Nil})
	aAdd(aRet,{"F1_DESCONT", SDS->DS_DESCONT,	Nil})
	aAdd(aRet,{"F1_SEGURO",  SDS->DS_SEGURO,	Nil})
Endif

If !Empty(SDS->DS_TRANSP) .And. !lAtuImp
	aAdd(aRet,{"F1_TRANSP",SDS->DS_TRANSP,	Nil})
EndIf

If !lAtuImp
	aAdd(aRet,{"F1_PLACA",   SDS->DS_PLACA,		Nil})	
	aAdd(aRet,{"F1_PLIQUI",  SDS->DS_PLIQUI	,	Nil})
	aAdd(aRet,{"F1_PBRUTO",  SDS->DS_PBRUTO	,	Nil})
	aAdd(aRet,{"F1_ESPECI1", SDS->DS_ESPECI1,	Nil})		
	aAdd(aRet,{"F1_VOLUME1", SDS->DS_VOLUME1,	Nil})
	aAdd(aRet,{"F1_ESPECI2", SDS->DS_ESPECI2,	Nil})
	aAdd(aRet,{"F1_VOLUME2", SDS->DS_VOLUME2,	Nil})
	aAdd(aRet,{"F1_ESPECI3", SDS->DS_ESPECI3,	Nil})
	aAdd(aRet,{"F1_VOLUME3", SDS->DS_VOLUME3,	Nil})
	aAdd(aRet,{"F1_ESPECI4", SDS->DS_ESPECI4,	Nil})
	aAdd(aRet,{"F1_VOLUME4", SDS->DS_VOLUME4,	Nil})
	aAdd(aRet,{"F1_TPCTE"  , SDS->DS_TPCTE  ,	Nil})
	aAdd(aRet,{"F1_TPFRETE", SDS->DS_TPFRETE,	Nil})
Endif

If !lAtuImp
	aAdd(aRet,{"F1_CODNFE"	, SDS->DS_CODNFE	, Nil})
	aAdd(aRet,{"F1_NUMRPS"	, SDS->DS_NUMRPS	, Nil})
	If ValType(oObjImp:lCpoNewDoc) = NIL .or. !oObjImp:lCpoNewDoc
		aAdd(aRet,{"F1_NFELETR"	, SDS->DS_DOC		, Nil})
	Else
		aAdd(aRet,{"F1_NFELETR"	, SDS->DS_NFELETR	, Nil}) 
	Endif
	aAdd(aRet,{"F1_EMINFE"	, SDS->DS_EMISSA	, Nil})
	aAdd(aRet,{"F1_HORNFE"	, SDS->DS_HORNFE	, Nil})
	aAdd(aRet,{"F1_ORIGEM"	, "LOCA102"			, Nil})
Endif

If !lAtuImp .And. lHoraNfe
	//Parametro MV_HORARMT habilitado pega a hora do smartclient, caso contrario a hora do servidor
	If cHoraRMT == '1' //Horario do SmartClient
		aAdd(aRet,{"F1_HORA",GetRmtTime(), Nil}) 
	ElseIf cHoraRMT == '2' //Horario do servidor
		aAdd(aRet,{"F1_HORA",Time(), Nil})
	ElseIf cHoraRMT =='3' //Horario de acordo com o estado da filial corrente
		aHorario := A103HORA()
		If !Empty(aHorario[2])
			aAdd(aRet,{"F1_HORA",aHorario[2], Nil})
		EndIf
	Endif
Endif


If lDSPedagio .And. SDS->DS_VALPEDG > 0 
	aAdd(aRet,{"F1_VALPEDG",SDS->DS_VALPEDG, Nil })	// Valor Pedagio
Endif

If lDSNaturez .And. !Empty(SDS->DS_NATUREZ)
	aAdd(aRet,{"E2_NATUREZ",SDS->DS_NATUREZ, Nil })	// Natureza Financeira
Endif

RestArea(aAreaSDS)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSD1
Monta itens para rotina automatica com os dados do SDS posicionado
@type function
@author	Totvs
@since 05/06/12
/*/
//------------------------------------------------------------------- 

Static Function MontaSD1(lImposto,lCteClass,nComCol1,aItCSD,lDocAut)

Local aRet	    := {}
Local aAreaSDS	:= SDS->(GetArea())
Local cFilSA5	:= xFilial("SA5")
Local cFilSB1	:= xFilial("SB1")
Local cFilSF4	:= xFilial("SF4")
Local cOper		:= ""
Local lDTClasFis:= SDT->(FieldPos("DT_CLASFIS")) > 0
Local lICMSSTRet:= SDT->(FieldPos("DT_ICMNDES")) > 0 .And. SDT->(FieldPos("DT_BASNDES")) > 0 .And. SDT->(FieldPos("DT_ALQNDES")) > 0
Local aAuxCSD 	:= {}
Local aAux 		:= {}
Local nPosCSD   := {}
Local nX 		:= 1
Local lTES 		:= .F.
Local lCsdXML 		:= SuperGetMV( 'MV_CSDXML', .F., .F. ) .and. SDT->(FieldPos("DT_ITXML")) > 0 .and. SDT->(FieldPos("DT_UMXML")) > 0 .and. SDT->(FieldPos("DT_QTDXML")) > 0;
					.and. SDT->(FieldPos("DT_FATOR")) > 0 .and. FWSX3Util():GetFieldType( "D1_ITXML" ) == "C" .and. ChkFile("DKA");
					.and. ChkFile("DKB") .and. ChkFile("DKC") .and. ChkFile("D3Q")
Local nClasFis	:= SuperGetMV("MV_COLCLAS",.F.,0)
Local aCpoEntDT	:= {{"DT_CC","D1_CC"},{"DT_CONTA","D1_CONTA"},{"DT_ITEMCTA","D1_ITEMCTA"},{"DT_CLVL","D1_CLVL"}}
Local aEntSDT	:= {}
Local nQtdEnt 	:= CtbQtdEntd()
Local cLoopEnt	:= ""
Local cEntConDB	:= ""
Local cEntConCR	:= ""
Local cItem     := Criavar("D1_ITEM")

Local oModel := FWModelActive()
Local oSDSMaster := oModel:GetModel("SDS_MASTER") 
Local oSDTGrid := oModel:GetModel("SDT_GRID")
Local oFPAGrid := oModel:GetModel("FPA_GRID")
Local nSDT // Contador de Linha do Grid SDT
LOcal nFPA // Contador de linha do grid FPA
Local aTes // Array com o TES para o item em processamento

Default lImposto	:= .F.
Default lCteClass	:= .F.
Default nComCol1	:= 0
Default aItCSD		:= {}
Default lDocAut 	:= .F.

For nX := 1 To Len(aCpoEntDT)
	If SDT->(FieldPos(aCpoEntDT[nX,1])) > 0 .And. SD1->(FieldPos(aCpoEntDT[nX,2])) > 0
		aAdd(aEntSDT,{aCpoEntDT[nX,2],"SDT->"+aCpoEntDT[nX,1]}) 
	Endif
Next nX

For nX := 5 to nQtdEnt 
	cLoopEnt  := PADL(cValToChar(nX),2,"0")
	cEntConDB := "EC"+cLoopEnt+"DB"
	cEntConCR := "EC"+cLoopEnt+"CR"
	//Manter o filedpos pois as entidades contábeis são criadas pelo usuário.
	If SDT->(FieldPos("DT_"+cEntConDB)) > 0 .And. SDT->(FieldPos("DT_"+cEntConCR)) > 0 .And. ;
	   SD1->(FieldPos("D1_"+cEntConDB)) > 0 .And. SD1->(FieldPos("D1_"+cEntConCR)) > 0
		aAdd(aEntSDT,{"D1_"+cEntConDB,"SDT->DT_"+cEntConDB})
		aAdd(aEntSDT,{"D1_"+cEntConCR,"SDT->DT_"+cEntConCR})
	EndIf
Next nX

for nSDT := 1 to oSDTGrid:Length() // Percorrer os Itens do Documento XML

	oSDTGrid:GoLine(nSDT)
	SDT->(dbGoto(oSDTGrid:GetDataID()))

	for nFPA := 1 to oFPAGrid:Length()
		oFPAGrid:GoLine(nFPA)
		if oFPAGrid:GetValue("MARK")
			aAdd(aRet,{})
			cItem := Soma1(cItem)
			aAdd(aTail(aRet),{"D1_FILIAL", oSDTGrid:GetValue("DT_FILIAL"), 	 NIL})
			aAdd(aTail(aRet),{"D1_ITEM",   cItem, 	 NIL})
			aAdd(aTail(aRet),{"D1_COD",   oSDTGrid:GetValue("DT_COD"),	 NIL})
		
			//Local
			If !Empty(oFPAGrid:GetValue("D2_LOCAL"))
				aAdd(aTail(aRet),{"D1_LOCAL",  oFPAGrid:GetValue("D2_LOCAL"),	 NIL})
			Endif
			
			aAdd(aTail(aRet),{"D1_NFORI",  oFPAGrid:GetValue("D2_DOC"),	 NIL})
			aAdd(aTail(aRet),{"D1_SERIORI",oFPAGrid:GetValue("D2_SERIE"), NIL})
			aAdd(aTail(aRet),{"D1_ITEMORI",oFPAGrid:GetValue("D2_ITEM"), NIL})
			

			aAdd(aTail(aRet),{"D1_UM"		, 	oFPAGrid:GetValue("D2_UM"),  NIL})
			
			aAdd(aTail(aRet),{"D1_QUANT",  oFPAGrid:GetValue("QTDNEW"), 	 NIL})
			aAdd(aTail(aRet),{"D1_SLDEXP", oFPAGrid:GetValue("QTDNEW"), 	 NIL})
			aAdd(aTail(aRet),{"D1_VUNIT",  oSDTGrid:GetValue("DT_VUNIT"), 	 NIL})

			aAdd(aTail(aRet),{"D1_TOTAL", oSDTGrid:GetValue("DT_VUNIT") * oFPAGrid:GetValue("QTDNEW"),NIL})
			
			cOper := ColConDHJ(oSDTGrid:GetValue("DT_CODCFOP"))
		
			If !Empty(cOper)
				aAdd(aTail(aRet),{"D1_OPER", cOper, NIL})
			EndIf	
		
			aAdd(aTail(aRet),{"D1_VALFRE",	oSDTGrid:GetValue("DT_VALFRE"),	 NIL})
			aAdd(aTail(aRet),{"D1_SEGURO",	oSDTGrid:GetValue("DT_SEGURO"),	 NIL})
			aAdd(aTail(aRet),{"D1_DESPESA",	oSDTGrid:GetValue("DT_DESPESA"), NIL})
			aAdd(aTail(aRet),{"D1_VALDESC", oSDTGrid:GetValue("DT_VALDESC"), NIL})
			If !Empty(oSDTGrid:GetValue("DT_TES"))
				aAdd(aTail(aRet),{"D1_TES"    , oSDTGrid:GetValue("DT_TES"), NIL})
			endif
			If oSDTGrid:GetValue("DT_PICM") > 0
				aAdd(aTail(aRet),{"D1_PICM", oSDTGrid:GetValue("DT_PICM"), Nil })
			EndIf
		
			aAdd(aTail(aRet),{"D1_CFOP", oSDTGrid:GetValue("DT_CFOP"), Nil }) //-- "CFOP" Variável ao qual armazena o valor do campo DT_CFOP		

			aAdd(aTail(aRet),{"D1_LOTECTL", oFPAGrid:GetValue("D2_LOTECTL")   , Nil})
			aAdd(aTail(aRet),{"D1_IDENTB6" , oFPAGrid:GetValue("D2_IDENTB6")  ,  NIL})

			//-- Realiza validacoes pertinentes e preenche TES
			aTes := COMCOLTES(oSDSMASTER:GetValue("DS_TIPO"), nComCol1, lCteClass, cFilSA5, cFilSB1, cFilSF4, SDS->DS_FILIAL, lDocAut,, oModel)

			If Len(aTes) > 0  
				If !aTes[1]
					RecLock("SDS",.F.)
					Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG + CRLF+CRLF + aTes[2]
					Replace SDS->DS_STATUS With 'E'
					SDS->(MsUnlock())
					aRet := {}
					Exit
				Else
					If Len(aTes) > 2
						aAdd(aTail(aRet),{aTes[2],aTes[3], Nil })
						lTES := .T.
					Endif
				Endif  
			Endif
		
//			If lDTClasFis .And. !Empty(SDT->DT_CLASFIS) .And. nClasFis < 2 
//				aAdd(aTail(aRet),{"D1_CLASFIS", 	oSDTGrid:GetValue("DT_CLASFIS"),  NIL})
//			Endif

			If lICMSSTRet .And. oSDSMaster:GetValue("DS_TIPO") <> "T" 
				aAdd(aTail(aRet),{"D1_BASNDES", 	oSDTGrid:GetValue("DT_BASNDES"),  NIL})
				aAdd(aTail(aRet),{"D1_ICMNDES", 	oSDTGrid:GetValue("DT_ICMNDES"),  NIL})
				aAdd(aTail(aRet),{"D1_ALQNDES", 	oSDTGrid:GetValue("DT_ALQNDES"),  NIL})
			Endif 

			if lCsdXml .and. oSDSMaster:GetValue("DS_TIPO") $ "N|D" .and. lTES
				aAdd(aTail(aRet),{"D1_ITXML", 	oSDTGrid:GetValue("DT_ITXML"),  NIL})

				nPosCSD := aScan(aAuxCSD, {|x|AllTrim(x[1])== oSDTGrid:GetValue("DT_ITXML") })
				if nPosCSD == 0
					aAdd(aAuxCSD,{;
						oSDTGrid:GetValue("DT_ITXML"),;
						oSDTGrid:GetValue("DT_QUANT"),;
						oSDTGrid:GetValue("DT_FATOR"),;
						Alltrim(oSDTGrid:GetValue("DT_DESCFOR")),;
					})
				else
					aAuxCSD[nPosCSD][2] += oSDTGrid:GetValue("DT_QUANT") 
				endif
			
			endif

			//Envio do CFOP caso esteja preenchido, o mesmo deve ser enviado depois da TES para calculo do conf. tributos
			if SDT->(FieldPos("DT_CODCFEN")) > 0 .And. !Empty( oSDTGrid:GetValue("DT_CODCFEN") ) .AND. Val(SubStr(oSDTGrid:GetValue("DT_CODCFEN"),1,1)) < 5
				aAdd(aTail(aRet),{"D1_CF", oSDTGrid:GetValue("DT_CODCFEN"), Nil})
			endif	

			//Grava novos campos SDT
			For nX := 1 To Len(aEntSDT)
				If !Empty(&(aEntSDT[nX,2]))
					aAdd(aTail(aRet),{aEntSDT[nX,1], &(aEntSDT[nX,2]), Nil})
				Endif
			Next nX
		endif
	Next nFPA

next nSDT

if !empty(aAuxCSD)
	for nX := 1 to len(aAuxCSD)
		aAux := {}
		aadd(aAux,{"DKA_ITXML" 	 ,aAuxCSD[nX][1] ,NIL})
		aadd(aAux,{"DKA_QTDXML"  ,aAuxCSD[nX][2] ,NIL})
		aadd(aAux,{"DKA_FATOR"   ,aAuxCSD[nX][3] ,NIL})
		aadd(aAux,{"DKA_DESCFO"  ,aAuxCSD[nX][4] ,NIL})
		aAdd(aItCSD,aAux)
	next nX
endif 

RestArea(aAreaSDS)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COLNfeAut
Validacao das tabelas SE4/SF4 para geracao automatica dos documentos
@type function
@param	aCabec, array,		Cabecalho documento de entrada
@param	aItens, array,		Itens documento de entrada	

@author	Rodrigo Toledo
@since 04/10/12
/*/
//------------------------------------------------------------------- 

Static Function COLNfeAut(aCabec,aItens)

Local lRet     	:= .T.

Return lRet

/*/{Protheus.doc} LOCA102GER
Função que gera a Nota de entrada no PRotheus 
Usando execauto do MATA140 ou MATA103
@type function
@version  25.10
@author Alexandre Circenis
@since 8/8/2025
@param oView, object, View de amarração SDT x FPA
@return variant, .T. se gravou com scesso
/*/
Function LOCA102GER(oView)

Local nX 		:= 1
Local aDivFis	:= {}
Local nProcOpc	:= 2
Local lProcessa := .T.
Local lCAuto	:= .F.
Local cAliqICMS	:= GetMV("MV_ALIQICM")
Local aAliqICMS	:= StrTokArr(cAliqICMS, "/")
Local lVldICMS	:= .T.
Local oModel := FWModelActive()
LOcal oSDTGrid   := oModel:GetModel("SDT_GRID")

Private lPreNota := .T.

if !Loca102Tok(oModel )
	Return
endif

if lProcessa := MsgYesNo(STR0031,STR0030) //"Atenção" //"Confirma a geração do documento Fiscal ?"
		
	SDT->(DbSetOrder(1))
	For nX:=1 To oSDTGrid:Length()
	
		oSDTGrid:GoLine(nX)

		If 	Len(aDivFis) == 0 .And. (oSDTGrid:GetValue("DT_TESIPI") <> oSDTGrid:GetValue("DT_XMLIPI")	.Or.;
				oSDTGrid:GetValue("DT_TESICM") <> oSDTGrid:GetValue("DT_XMLICM")	.Or.;
				oSDTGrid:GetValue("DT_TESISS") <> oSDTGrid:GetValue("DT_XMLISS")	.Or.;
				oSDTGrid:GetValue("DT_TESPIS") <> oSDTGrid:GetValue("DT_XMLPIS")	.Or.;
				oSDTGrid:GetValue("DT_TESCOF") <> oSDTGrid:GetValue("DT_XMLCOF")	.Or.;
				oSDTGrid:GetValue("DT_TESICST") <> oSDTGrid:GetValue("DT_XMLICST")	.Or.;
				oSDTGrid:GetValue("DT_ALIQIPI") <> oSDTGrid:GetValue("DT_XALQIPI") .Or.;
				oSDTGrid:GetValue("DT_ALIQICM")	<> oSDTGrid:GetValue("DT_XALQICM") .Or.;
				oSDTGrid:GetValue("DT_ALIQISS")	<> oSDTGrid:GetValue("DT_XALQISS") .Or.;
				oSDTGrid:GetValue("DT_ALIQPIS")	<> oSDTGrid:GetValue("DT_XALQPIS") .Or.;
				oSDTGrid:GetValue("DT_ALIQCOF")	<> oSDTGrid:GetValue("DT_XALQCOF") .Or.;
				oSDTGrid:GetValue("DT_ALIICST") <> oSDTGrid:GetValue("DT_XALICST"))
			
				If oSDTGrid:GetValue("DT_ALIQICM") <> oSDTGrid:GetValue("DT_XALQICM")
					lVldICMS := (Ascan(aAliqICMS,cValToChar(oSDTGrid:GetValue("DT_XALQICM"))) > 0)
				EndIf

				aAdd(aDivFis,SDS->(Recno()))
			Endif
	
	Next nX

	If lProcessa .And. Len(aDivFis) > 0
		nProcOpc := Aviso(STR0036, STR0032 + CRLF + STR0033 + CRLF + STR0035 ,{STR0019, STR0034}, 2)  //"A alíquota informada no XML não condiz com as alíquotas configuradas no parâmetro MV_ALIQICM, qual opção deseja executar?" //"Cancelar - Para sair." //"Ignorar" //" Ignorar - Para importar mesmo com divergencia." //"Cancelar" //"Divergência Fiscal"
		If nProcOpc == 1
			lProcessa := .F. 
		ElseIf nProcOpc == 2
			lProcessa := .T.
			lCAuto	:= .T.
		Endif
	Endif 

Else

	lProcessa := .F.
	FWAlertWarning(STR0037) //"Processo de Linkagem cancelado"

Endif

If lProcessa
	Processa({|| lProcessa := LOCA102Docs(oModel, .T.),cCadastro +" - " +STR0038}) //"Geração de Documentos"
	if !lProcessa
		FWAlertWarning(STR0039) //"Documento de entrada não foi gerado. Verifique o erro no campo de Log ."
	endif	
Endif 

if lProcessa 
	if lPreNota
		FWAlertSuccess(STR0052) //"Pré documento gerado com sucesso!"
	else
		FWAlertSuccess(STR0040) //"Documento de entrada gerado com sucesso!"
	endif	
	lProcessa := .F.
endif

oView:ButtonCancelAction()

Return lProcessa

/*/{Protheus.doc} LOCA102Docs
Grava o documento de entrada
@type function
@version 25.10
@author Alexandre Circenis
@since 8/8/2025
@param oModel, object, objeto do tipo Model contendo os dados para linkar
@return variant, ,T. se q gravação ocorreu corretamente
/*/
Static Function LOCA102Docs(oModel, lcAuto)
Local aCabec 	:= {}
Local aItens 	:= {}
Local aErro  	:= {}
Local cErro  	:= ""
Local cFilBkp	:= cFilAnt
Local nX	 	:= 0
Local lRet		:= .T.
Local lProcessa	:= .T.
Local lImpXML	:= .T.	// Esta variavel fara com que a nota seja gerada com os valores de impostos do XML, quando a nota for gerada de forma automatica
Local lClass	:= .F.
Local nComCol1	:= SuperGetMV("MV_COMCOL1",.F.,0) //0=Não Gerar 1=A Classificar;2=Classificado.
Local lCteClass := SuperGetMV("MV_CTECLAS",.F.,.F.) // Deve Gerar nota já classificada
local aItensDHR := {}

Default lNFeAut := .F.
Default lCAuto	:= .F.	// Esta variavel determina se sera gerada Pre Nota (.F.) ou documento classificado (.T.)
Default lJob    := .F.

Private lMSErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.

	lProcessa := .T.
		
	If lProcessa
		//Verifica se NF ja foi importada/incluida manualmente.


		aCabec := MontaSF1(lCteClass,nComCol1)
		aItens := MontaSD1(lImpXML,lCteClass,nComCol1,,lNFeAut)
		
		BEGIN TRANSACTION
		
//		if lRet
			aItens := aSort(aItens,,,{|x,y| x[1,2] < y[1,2]})

			lClass := .F.
			lClass := ColVerTes(aItens)
			If (lRet := !(SDS->DS_STATUS $ "E|B"))
				If nComCol1 == 1 .And. !(SDS->DS_TIPO $ "OC") .And. !lCteClass .And. !lClass
					lRet := .T.
					ComTesCla(aItens)
					MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
				ElseIf (lClass .And. lCAuto)  
					If DHS->(DbSeek(xFilial("DHS") + SDS->(DS_FORNEC+DS_LOJA)))
						ComTesCla(@aItens)
						MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3) //Se houver suspenção grava Pré Nota
					else	
						aItensDHR := ComMontDHR()
						MSExecAuto({|x,y,z,a| MATA103(x,y,z,,,,,,,,,,a)},aCabec,aItens,3,aItensDHR)
						lPreNota := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			EndIf

		If lRet
		   	//-- Grava resultado do processamento na SDS
		   	RecLock("SDS",.F.)
		   	Replace SDS->DS_OK	With ''
		   	If !lMsErroAuto
		   		Replace SDS->DS_USERPRE	With cUserName
		   		Replace SDS->DS_DATAPRE	With dDataBase
		   		Replace SDS->DS_HORAPRE	With Time()
		   		Replace SDS->DS_STATUS	With 'P'
		   		Replace SDS->DS_DOCLOG	With ''

				if lPreNota // Foi emitida uma pre-nota gerar os dados no Rental
					Loca102Nf(3, 1)
				endif
			Else
				aErro := GetAutoGRLog()
				cErro := ""
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] +CRLF
				Next nX
				Replace SDS->DS_DOCLOG With cErro
				Replace SDS->DS_STATUS With 'E'
				lRet := .F.
			EndIf
			
			SDS->(MsUnLock()) 
		EndIf
		END TRANSACTION
		cFilAnt := cFilBkp
	
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} COLIMPMAN
Verifica se documento ja foi incluido de forma manual
@type Function
@author	Totvs
@since 05/06/12
/*/
//------------------------------------------------------------------- 

Static Function COLIMPMAN()

Local aArea	:= GetArea()
Local cFil	:= ""
Local cDoc	:= "" 
Local cSer	:= ""
Local cFor	:= ""
Local cLoj	:= ""
Local cTip	:= ""
Local cChv	:= ""
Local lRet	:= .F.

//Busca pela chave do documento
cFil		:= SDS->DS_FILIAL
cChv		:= SDS->DS_CHAVENF
	
DbSelectArea("SF1")
SF1->(DbSetOrder(8))
If SF1->(DbSeek(cFil+cChv))
	lRet := .T.
Endif

if !lRet //  Se não encontrar a chave buscar pelos dados do document0

	cFil		:= SDS->DS_FILIAL
	cDoc		:= SDS->DS_DOC 
	cSer		:= SDS->DS_SERIE
	cFor		:= SDS->DS_FORNEC
	cLoj		:= SDS->DS_LOJA
	cTip		:= SDS->DS_TIPO
	
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(cFil+cDoc+cSer+cFor+cLoj+cTip))
		lRet := .T.
	Endif
Endif

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} COMCOLTES
Busca pela TES para o documento
@type Function
@author	rodrigo.mpontes
@since 22/4/20
/*/
//------------------------------------------------------------------- 

Static Function COMCOLTES(cTipoDoc,nComCol1,lCteClass,cFilSA5,cFilSB1,cFilSF4,cFilSDS,lGerDAut, cSDTTES, oModel)

Local aArea		:= GetArea()
Local aAreaSB1 	:= SB1->(GetArea())
Local aAreaSF4 	:= SF4->(GetArea())
Local aAreaSE4 	:= SE4->(GetArea())
Local aAreaSA5 	:= SA1->(GetArea())
Local cCodTes	:= ""
Local cCpo		:= ""
Local aRet		:= {}
Local lFindTes	:= .F.
Local lCpoGer	:= SuperGetMV("MV_COLTEG",.F.,.F.)
Local lRet		:= .T.
Local oSDTGRID := oModel:GetModel("SDT_GRID")
Local oFPAGRID := oModel:GetModel("FPA_GRID")
Local oSDSMASTER := oModel:GetModel("SDS_MASTER")

If nComCol1 == 2 .Or. lCteClass
	cCpo := "D1_TES"
Elseif nComCol1 == 1
	cCpo := "D1_TESACLA"
Else
	If lCpoGer //MV_COLTEG
		cCpo := "D1_TES"
	Else
		cCpo := "D1_TESACLA"
	Endif
Endif

if !(cTipoDoc $ "COT")
	If !Empty(oSDTGrid:GetValue("DT_TES"))  		 
		cCodTes := oSDTGrid:GetValue("DT_TES")
		cCpo := "D1_TES"
		
		If lGerDAut .And. nComCol1 == 1  
//			cCpo := "D1_TESACLA"
		EndIf 
		
		aRet := {.T.,cCpo,cCodTes}
		lFindTes := .T. 
	Endif

	If !lFindTes .And. cTipoDoc == "D" 
		SD2->(DbSetOrder(3))	// D2_FILIAL + D2_DOC + D2_SERIE + D2_D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		If SD2->(MsSeek(xFilial("SD2")+oFPAGrid:GetValue("D2_DOC")+oFPAGrid:GetValue("D2_SERIE")+oSDSMaster:GetValue("DS_FORNEC")+oSDSMaster:GetValue("DS_LOJA")+oSDTGrid:GetValue("DT_COD")+oFPAGrid:GetValue("D2_ITEM")))
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))

			cCodTes := GetAdvFVal("SF4","F4_TESDV",xFilial("SF4")+SD2->D2_TES,1)
			If !Empty(cCodTes)
				aRet := {.T.,cCpo,cCodTes}
				lFindTes := .T.
			Endif 
		EndIf
	Endif 
	
	
	If !lFindTes
		cCodTes := MaTESInt(1,ColConDHJ(oSDTGrid:GetValue("DT_CODCFOP")),oSDSMaster:GetValue("DS_FORNEC"),oSDSMaster:GetValue("DS_LOJA"),If(cTipoDoc $ "DB","C","F"),oSDTGrid:GetValue("DT_COD"))
		If !Empty(cCodTes)
			aRet := {.T.,cCpo,cCodTes}
			lFindTes := .T.
		Endif
	Endif
	
	If !lFindTes
		cCodTes := GetAdvFVal("SB1","B1_TE",cFilSB1 +oSDTGrid:GetValue("DT_COD"),1)
		If !Empty(cCodTes)
			aRet := {.T.,cCpo,cCodTes}
			lFindTes := .T.
		Endif
	Endif
Endif


if !(cTipoDoc $ "COT") .And. lFindTes
	lQtdZero := GetAdvFVal("SF4","F4_QTDZERO",cFilSF4+cCodTes,1) == "1"
	lVlrZero := GetAdvFVal("SF4","F4_VLRZERO",cFilSF4+cCodTes,1) == "1"
	
	if oSDTGrid:GetValue("DT_QUANT") > 0 .And. oSDTGrid:GetValue("DT_VUNIT") == 0 //TES precisa ser Vlr Zero
		lRet := lVlrZero
	endif
	
	If !lRet
		aRet := {.F.,STR0041 + AllTrim(SDT->DT_ITEM) + STR0042} //"Item: " //" não esta configurada com a TES correta. Verifique configuração da TES (Valor Zero e/ou Quantidade Zero)"
	Endif				
Endif

RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSE4)
RestArea(aAreaSA5)

Return aRet

/*/{Protheus.doc} Loca102LNK
Verifica se pode ocorrer o processo de ligar itens do doumento e do Transmite e assim gerar o dcumento de entrada
@type function
@version 25.10 
@author Alexandre Circenis
@since 8/8/2025
@param oModel, object, param_description
@return variant, return_description
/*/
Function Loca102LNK(oModel)
Local lRet := .T.
Local nComCol1	:= SuperGetMV("MV_COMCOL1",.F.,0) //0=Não Gerar 1=A Classificar;2=Classificado.

if nComCol1 = 0
	oModel:SetErrorMessage("","","","","LOCA102_02",STR0043,STR0044,)  //"O parametro MV_COMCOL1 não está definido para gerar Documentos de Entrada." //" Preencher o parametro MV_COMCOL1 corretamente para poder usar a rotina de linkar com os itens do contrato."
	lRet := .F.
endif

If lRet .and. SDS->DS_STATUS = 'P'
	oModel:SetErrorMessage("","","","","LOCA102_03",STR0045," ") //"Documento de entrada já foi gerado, não há necessidade de linkar."
	lRet := .F.
endif

If lRet .and. SDS->DS_STATUS <> ' ' .and. SDS->DS_STATUS <> SDS->DS_TIPO
	oModel:SetErrorMessage("","","","","LOCA102_04",STR0046,STR0047) //"Há algum problema com os dados dessa Nota." //"Acesse o Totvs Colaboração para verificar o erro e corrigi-lo antes de tentar fazer o link novamente. "
	lRet := .F.
endif

if lRet .and. COLIMPMAN()
	oModel:SetErrorMessage("","","","","LOCA102_05",STR0048,STR0049) //"Nota de entrada já foi incluida no sistema e não poderá ser processada." //"Verifique a nota de entrada nas rotinas de documento de entrada. "
	lRet := .F.
endif

Return lRet


/*/{Protheus.doc} LOCMA102NF
Função chamada após a geração da nota para ajustar as informações do contrato
@type function
@version  25.10
@author Alexandre Circenis
@since 8/11/2025
@param nVar, numeric, param_description
@param nOpc, numeric, param_description
@return variant, return_description
/*/
Function LOCA102NF(nVar,nOpc)
Local aAreaOld := GetArea()
Local aAreaZAG := FPA->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaTQY := TQY->(GetArea())
Local aAreaST9 := ST9->(GetArea())
Local aAreaZLF := FPN->(GetArea())
Local cQuery   := ""
Local cSttCtr  := ""
Local nRet            // Frank 19/10/20
Local nRegX
Local cProjX
Local lMarcacao
Local lLOCX278 := getmv("MV_LOCX278",,.F.)
Local lLOCX022 := SuperGetMV("MV_LOCX022",,.F.)
//Local cQryPesq := ""
Local aAreaTmp
Local cProjx2
Local cProdx
Local cGruax
Local dDatax
Local lExiste := .F.

private CGRPAND	:= SUPERGETMV("MV_LOCX014",.F.,"" )  // FRANK 12/08/20
private _nOpc  := nVar // compatibilização para o funcionamento do locxitu21

//    if nOpc == 0 // Tela de Nota entrada cancelada
//        Return .T. // Se nOpc for igual a 1 tela aprovada
//    endif

    // DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            lLOCX278 := .T.
        Else
            lLOCX278 := .F.
        EndIf
    EndIf

    IF SBM->(FIELDPOS("BM_XACESS")) > 0
        CGRPAND := LOCA00189()
    ELSE
        CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
    ENDIF

    cQuery := "SELECT DISTINCT SD1.R_E_C_N_O_ SD1RECNO, "
    cQuery += "ZAG.R_E_C_N_O_ FPARECNO, "
    cQuery += "D1_FILIAL, D1_DOC, D1_SERIE, D1_EMISSAO, "
    cQuery += "D1_QUANT, D1_ITEM, D1_NFORI, D1_SERIORI, D1_ITEMORI "
    cQuery += "FROM " + RetSqlName("SD1") + " SD1 "
    cQuery += "INNER JOIN " + RetSqlName("SD2") + " SD2 "
    cQuery += "ON D2_FILIAL = D1_FILIAL "
    cQuery += "AND D2_DOC = D1_NFORI "
    cQuery += "AND D2_SERIE = D1_SERIORI "
    cQuery += "AND D2_ITEM = D1_ITEMORI "
    cQuery += "AND SD2.D_E_L_E_T_ = '' "
 
    cQuery += "INNER JOIN "+RETSQLNAME("FPZ")+" FPZ (NOLOCK) "
	cQuery += "ON FPZ.FPZ_FILIAL = D2_FILIAL "
    cQuery += "AND FPZ.FPZ_PEDVEN =  D2_PEDIDO "
    cQuery += "AND FPZ.FPZ_ITEM = D2_ITEMPV "
    cQuery += "AND FPZ.D_E_L_E_T_ = ' ' "
    cQuery += "INNER JOIN "+RETSQLNAME("FPY")+" FPY (NOLOCK) "
	cQuery += "ON FPY.FPY_FILIAL = FPZ.FPZ_FILIAL "
    cQuery += "AND FPY.FPY_PEDVEN = FPZ.FPZ_PEDVEN "
    cQuery += "AND FPY.FPY_TIPFAT = 'R' "
    cQuery += "AND FPY.D_E_L_E_T_ = ' ' AND FPY.FPY_STATUS <> '2' "

    cQuery += "INNER JOIN " + RetSqlName("FPA") + " ZAG "
    cQuery += "ON FPA_FILREM = D2_FILIAL "
    cQuery += "AND FPA_NFREM = D2_DOC "
    cQuery += "AND FPA_SERREM = D2_SERIE "

    cQuery += "AND FPA_AS     = FPZ_AS "

    cQuery += "AND FPA_DNFREM = D2_EMISSAO "
    cQuery += "AND ZAG.D_E_L_E_T_ = '' "
    cQuery += "INNER JOIN " + RetSqlName("FP0") + " ZA0 "
    cQuery += "ON  FP0_FILIAL = FPA_FILIAL "
    cQuery += "AND FP0_PROJET = FPA_PROJET "
    cQuery += "AND ZA0.D_E_L_E_T_ = '' "
    cQuery += "LEFT  JOIN " + RetSqlName("ST9") + " ST9 "
    cQuery += "ON T9_CODBEM = FPA_GRUA "
    cQuery += "AND ST9.D_E_L_E_T_ = '' "
    cQuery += "WHERE SD1.D1_FILIAL = ? "
    cQuery += "AND SD1.D1_DOC = ? "
    cQuery += "AND SD1.D1_SERIE = ? "
    cQuery += "AND SD1.D1_FORNECE = ? "
    cQuery += "AND SD1.D1_LOJA = ? "
    cQuery += "AND SD1.D1_EMISSAO = ? "
    cQuery += "AND SD1.D_E_L_E_T_ = '' "
    If Select("TRBFPA") > 0
        TRBFPA->(dbCloseArea())
    EndIf
    cQuery := CHANGEQUERY(cQuery)
    aBindParam := {SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, DtoS(SF1->F1_EMISSAO) }
	MPSysOpenQuery(cQuery,"TRBFPA",,,aBindParam)

    If TRBFPA->(!Eof())

        dbSelectArea("FPA")
        dbSelectArea("SD1")
        dbSelectArea("TQY")
        dbSelectArea("ST9")
        dbSelectArea("FPN")

        Do Case
        Case nVar == 3

            cProjX := ""

            While TRBFPA->(!Eof())
                FPA->(dbGoTo(TRBFPA->FPARECNO))
                SD1->(dbGoTo(TRBFPA->SD1RECNO))

                cProjX := FPA->FPA_PROJET

                lMarcacao := .F. // indica se temos que gerar a FQZ no campo pv com X para não processar na emissão do faturamento automatico
                                // isto tem influencia para nao calcular a pro-rata duas vezes.

                If FPA->(RecLock("FPA",.F.))

                    // Verificar a quantidade que foi enviado x a quantidade retornada.
                    // Só armazenar a nota se for a ultima entrada, ou seja, se as quantidades forem iguais.
                    // Frank 19/10/20
                    FP0->(dbSetOrder(1))
                    FP0->(dbSeek(FPA->FPA_FILIAL+FPA->FPA_PROJET))

                    // Tratamento dos titulos provisorios, deletar ao gerar a nota de devolução
                    // Frank em 26/20/2021
                    If lLOCX278 //getmv("MV_LOCX278",,.F.)

                        // Deleta os títulos provisórios
			            LOCA013DEL(2, FPA->FPA_PROJET, FPA->FPA_AS)

                    EndIF

                    If FP0->FP0_TIPOSE == "L" 

                        nRet := 0

                        If FPA->FPA_QUANT == 0 .or. FPA->FPA_QUANT - SD1->D1_QUANT == 0 
                            FPA->FPA_NFRET  := SD1->D1_DOC
                            FPA->FPA_SERRET := SD1->D1_SERIE
                            FPA->FPA_DNFRET := SD1->D1_EMISSAO
                            FPA->FPA_ITERET := SD1->D1_ITEM
                            If Empty(FPA->FPA_DTPRRT)
                                FPA->FPA_DTPRRT	:= SD1->D1_EMISSAO
                            EndIf
                            If Empty(FPA->FPA_DTSCRT)
                                FPA->FPA_DTSCRT	:= FPA->FPA_DTPRRT
                            EndIf

                            // Uso do campo FPA_CONFIG
                            // No momento do estorno se for a nota informada neste campo, não devemos
                            // levar em consideração a quantidade
                            FPA->FPA_CONFIG := SD1->D1_DOC+SD1->D1_SERIE
                            lMarcacao := .T. // indica se temos que gerar a FQZ no campo pv com X para não processar na emissão do faturamento automatico
                                              // isto tem influencia para nao calcular a pro-rata duas vezes.
                        EndIF

                        // para efeito da cobranca diminuir a quantidade
                        If FPA->FPA_QUANT - SD1->D1_QUANT > 0
                            FPA->FPA_QUANT  := FPA->FPA_QUANT - SD1->D1_QUANT
                            FPA->FPA_VLBRUT := FPA->FPA_PRCUNI * FPA->FPA_QUANT
                            If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
                                 FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES
                            EndIf
                            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
                        EndIF

                    Else
                        If FPA->FPA_QUANT == 0 .or. FPA->FPA_QUANT - SD1->D1_QUANT == 0
                            FPA->FPA_NFRET  := SD1->D1_DOC
                            FPA->FPA_SERRET := SD1->D1_SERIE
                            FPA->FPA_DNFRET := SD1->D1_EMISSAO
                            FPA->FPA_ITERET := SD1->D1_ITEM
                            If Empty(FPA->FPA_DTPRRT)
                                FPA->FPA_DTPRRT	:= SD1->D1_EMISSAO
                            EndIf
                            If Empty(FPA->FPA_DTSCRT)
                                FPA->FPA_DTSCRT	:= FPA->FPA_DTPRRT
                            EndIf

                            // Uso do campo FPA_CONFIG
                            // No momento do estorno se for a nota informada neste campo, não devemos
                            // levar em consideração a quantidade
                            FPA->FPA_CONFIG := SD1->D1_DOC+SD1->D1_SERIE
                            lMarcacao := .T. // indica se temos que gerar a FQZ no campo pv com X para não processar na emissão do faturamento automatico
                                            // isto tem influencia para nao calcular a pro-rata duas vezes.
                        EndIf
                        // para efeito da cobranca diminuir a quantidade
                        If FPA->FPA_QUANT - SD1->D1_QUANT > 0
                            FPA->FPA_QUANT  := FPA->FPA_QUANT - SD1->D1_QUANT
                            FPA->FPA_VLBRUT := FPA->FPA_PRCUNI * FPA->FPA_QUANT
                            If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
                                 FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES
                            EndIf
                            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
                        EndIF
                    EndIf
                    FPA->(MsUnLock())
                EndIf

                // Registrar o log das notas de entradas x orçamentos
                // Frank Zwarg Fuga em 08/09/2020
                // Este registro é importante para quando houver devolução parcial
                If lLOCX022 //SuperGetMV("MV_LOCX022",,.F.)
                    ITLOGFQZ(SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_EMISSAO, SD1->D1_COD, SD1->D1_QUANT, FPA->FPA_FILIAL, FPA->FPA_AS, nVar, FPA->FPA_PROJET, FPA->FPA_OBRA,lMarcacao)
                EndIf

                cSttCtr := "50" // Não tem romaneio

                If !Empty(FPA->FPA_GRUA) .and. RetStatus(cSttCtr)
                    ST9->(dbSetOrder(1))	// T9_FILIAL + T9_CODBEM
                    If ST9->(dbSeek( xFilial("ST9") + FPA->FPA_GRUA ))
                        If !empty(ST9->T9_STATUS)
                            // verifica se bem não está em outro contrato // Rossana - DSERLOCA 3414 - 08/07/24

                                // Frank 06/06/25
                                aAreaTmp := FPA->(GetArea())
                                cProjx2 := FPA->FPA_PROJET
                                cProdx := FPA->FPA_PRODUT
                                cGruax := FPA->FPA_GRUA
                                dDatax := FPA->FPA_DTINI
                                FPA->(dbSetOrder(5))
                                lExiste := .F.
                                If FPA->(dbSeek(xFilial("FPA")+cProjx2+cGruax))
                                    While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET+FPA_GRUA) == xFilial("FPA")+cProjx2+cGruax
                                        If FPA->FPA_PRODUT == cProdx .and. FPA->FPA_DTINI > dDatax .and. empty(FPA->FPA_NFRET)
                                            lExiste := .T.
                                            exit
                                        EndIf
                                        FPA->(dbSkip())
                                    EndDo
                                EndIf
                                FPA->(RestArea(aAreaTmp))
                               
                                If !lExiste
                                    LOCXITU21(ST9->T9_STATUS,FQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFRET,FPA->FPA_SERRET)
                                    If ST9->(RecLock("ST9",.F.))
                                        ST9->T9_STATUS := FQD->FQD_STATQY
                                        ST9->(MsUnLock())
                                    EndIf
                                Else
                                   If FQ4->(dbSeek( xFilial("FQ4") + FPA->FPA_GRUA ))
                                        While !FQ4->(Eof()) .and. FQ4->FQ4_FILIAL+FQ4->FQ4_CODBEM==xFilial("FQ4") + FPA->FPA_GRUA
                                            If FQ4->FQ4_STATUS == "L3" .and. FQ4->FQ4_PROJET==FPA->FPA_PROJET
                                               If !SF1->(dbSeek( xFilial("SF1") + FQ4->FQ4_DOCUME + FQ4->FQ4_SERIE ))
                                                  IF RECLOCK("FQ4",.F.)
                                                     FQ4->FQ4_DOCUME := FPA->FPA_NFRET
                                                     FQ4->FQ4_SERIE  := FPA->FPA_SERRET
                                                     FQ4->(MsUnLock())
                                                  EndIf
                                               EndIf
                                            EndIf
                                            FQ4->(DbSkip())
                                        End
                                   EndIf
                                EndIf
                        EndIF
                    EndIf
                EndIf

                TRBFPA->(dbSkip())
            EndDo

            // Tratamento dos titulos provisorios - voltar com os PR
            If lLOCX278 .and. !empty(cProjX)
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xFilial("FP0")+cProjX))
                nRegX := FPA->(Recno())
                loca01318() // criacao do titulo provisorio
                FPA->(dbGoto(nRegX))
            EndIF

        EndCase
    EndIf


    TRBFPA->(dbCloseArea())

    FPN->(RestArea( aAreaZLF ))
    ST9->(RestArea( aAreaST9 ))
    TQY->(RestArea( aAreaTQY ))
    SD1->(RestArea( aAreaSD1 ))
    FPA->(RestArea( aAreaZAG ))
    RestArea( aAreaOld )


Return Nil

/*/RetStatus
Retorna status do bem.
author Michel Taipina
since 08/03/2019
/*/
Static Function RetStatus(cAux,lEstorno)
Local aAreaOld := GetArea()
Local lRet     := .F.
Local cQuery   := ""
//Local nRecTqy  := 0
Local nRecFQD  := 0


Default lEstorno := .F.

        /*
        cAux
        */
        cQuery := "SELECT FQD_STATQY, FQD.R_E_C_N_O_ FQDRECNO "
        cQuery += " FROM " + RetSqlName("FQD") + " FQD "
        If lEstorno
            cQuery += " WHERE  FQD_STAREN  = ? "
        Else
            cQuery += " WHERE  FQD_STAREN  = ? "
        EndIf
        cQuery     += "   AND  FQD.D_E_L_E_T_ = '' "
        If lEstorno
            cQuery += " ORDER BY FQD_STAREN DESC "
        Else
            cQuery += " ORDER BY FQD_STAREN "
        EndIf
        If Select("TRBFQD") > 0
            TRBFQD->(dbCloseArea())
        EndIf
        cQuery := CHANGEQUERY(cQuery)
        aBindParam := {cAux}
		MPSysOpenQuery(cQuery,"TRBFQD",,,aBindParam)
        //TcQuery cQuery New Alias "TRBFQD"

        If TRBFQD->(!Eof())
            lRet    := .T.
            nRecFQD := TRBFQD->FQDRECNO
        EndIf

        TRBFQD->(dbCloseArea())

        RestArea( aAreaOld )

        If nRecFQD > 0
            FQD->(dbGoTo(nRecFQD))
        EndIf


Return lRet

// Rotina para criar o log das notas de entradas x movimentos da ZAG
// Frank Zwarg Fuga - 08/09/2020
Static Function ITLOGFQZ(cDoc, cSerie, cItem, cForne, cLoja, dEmiss, cProd, nQtd, cFilFPA, cAs, nVar, cProjet, cObra, lMarcacao)
Local NDIASTRB
Local cQryPesq  := ""
Local cQuery := ""

    // Rotina valida somente para o tipo de serviço Locação.
    If FP0->FP0_TIPOSE == "L"
        FQZ->(dbSetOrder(1))
        If nVar == 3
            FPA->(dbSetOrder(6))
            FPA->(dbSeek(cFilFPA+cProjet+cAs))
            // Quando for inclusão da nota de entrada fazer o log do registro
            If !FQZ->(dbSeek(cFilFPA+cDoc+cSerie+cForne+cLoja+cItem+"2"))
                FQZ->(RecLock("FQZ",.T.))
                FQZ->FQZ_FILIAL	:= cFilFPA
                FQZ->FQZ_DOC	:= cDoc
                FQZ->FQZ_SERIE	:= cSerie
                FQZ->FQZ_ITEM	:= cItem
                FQZ->FQZ_FORNE	:= cForne
                FQZ->FQZ_LOJA	:= cLoja
                FQZ->FQZ_EMISS	:= dEmiss
                FQZ->FQZ_COD	:= cProd
                FQZ->FQZ_QTD	:= nQtd
                FQZ->FQZ_AS		:= cAs
                FQZ->FQZ_MSBLQL	:= "2"
                FQZ->FQZ_PROJET	:= cProjet
                FQZ->FQZ_OBRA   := cObra
                FQZ->FQZ_VLRUNI := FPA->FPA_PRCUNI
                FQZ->FQZ_ULTFAT := FPA->FPA_ULTFAT
                FQZ->FQZ_DTINI  := FPA->FPA_DTINI
                FQZ->FQZ_DTFIM  := FPA->FPA_DTFIM
                FQZ->FQZ_VLRTOT := nQtd * FPA->FPA_PRCUNI
                FQZ->FQZ_RETIRA := dEmiss //FPA->FPA_DNFRET			//FPA_DTFIM
                If !empty(FQZ->FQZ_ULTFAT)
                    FQZ->FQZ_PERPRO := (FQZ->FQZ_RETIRA - FQZ->FQZ_ULTFAT)
                Else
                    FQZ->FQZ_PERPRO := (FQZ->FQZ_RETIRA - FQZ->FQZ_DTINI) + 1
                EndIf

                FP1->(dbSetOrder(1))
                FP1->(dbSeek(FPA->FPA_FILIAL+FPA->FPA_PROJET+FPA->FPA_OBRA))

                // Alterado por Frank em 21/07/22
                IF FP1->FP1_TPMES <> "0" // não é mes fechado
                    FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / If(FPA->FPA_LOCDIA==0,1,FPA->FPA_LOCDIA)
                Else // se for mes fechado
                    NDIASTRB := 30
                    DO CASE
                        CASE FPA->FPA_TPBASE == "M"
                            NDIASTRB := 30
                        CASE FPA->FPA_TPBASE == "Q"
                            NDIASTRB := 15
                        CASE FPA->FPA_TPBASE == "S"
                            NDIASTRB :=  7
                        OTHERWISE
                            DO CASE
                            CASE FPA->( FIELDPOS("FPA_LOCDIA") ) > 0 .and. FPA->( FPA_LOCDIA) > 0
                                NDIASTRB := FPA->FPA_LOCDIA
                            CASE FPA->( FIELDPOS("FPA_PREDIA") ) > 0 .and. FPA->( FPA_PREDIA ) > 0
                                NDIASTRB := FPA->FPA_PREDIA
                            OTHERWISE
                                NDIASTRB := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1
                            ENDCASE
                    ENDCASE
                    FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / NDIASTRB
                EndIf

                //SIGALOC94-799 - 12/06/2023 - José Eulálio - O trecho abaixo estava comentado. Retornando para o PE, pois é importante para não gerar Faturamento automático na remessa total do item
                If lMarcacao
                    FQZ->FQZ_PV := "X"
                EndIF

                FQZ->(MsUnlock())

            EndIf
        EndIf

    		If ! Empty(FPA->FPA_GRUA) .And. ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
	    	
                    cQryPesq := " SELECT   FPA_PROJET"
	    			cQryPesq += " FROM " + RetSqlName("FPA") + " FPA "
		    		cQryPesq += " WHERE  FPA.D_E_L_E_T_ = '' "
                    cQryPesq += "   AND  FPA.FPA_PROJET <> ? "
                    cQryPesq += "   AND  FPA.FPA_PRODUT = ? "
                    cQryPesq += "   AND  FPA.FPA_GRUA = ? "
                    cQryPesq += "   AND  FPA.FPA_NFRET = '' "
                    cQryPesq := changequery(cQryPesq)
                    aBindParam := {FPA->FPA_PROJET,FPA->FPA_PRODUT, FPA->FPA_GRUA}
	                MPSysOpenQuery(cQryPesq,"TRBPSQ",,,aBindParam)
					TRBPSQ->(dbGotop()) 
		    		If TRBPSQ->(Eof()) // verifica se bem não está em outro contrato // Rossana - DSERLOCA 3414 - 08/07/24
    
    				    cQuery := " SELECT   FQD_STATQY"
	        			cQuery += " FROM " + RetSqlName("FQD") + " FQD "
	    	    		cQuery += " WHERE    FQD.FQD_STAREN < '50' "
        				cQuery += "   AND    FQD.D_E_L_E_T_ = '' "
	    	    		cQuery += " ORDER BY FQD_STAREN DESC "
		     	    	cQuery := changequery(cQuery)
						MPSysOpenQuery(cQuery,"TRBFQD",,,)
 
    			    	TRBFQD->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro

		    	    	If ! TRBFQD->(Eof())
		    	    		LOCXITU21(ST9->T9_STATUS,TRBFQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
		             		If RecLock("ST9",.F.)
		        				ST9->T9_STATUS := TRBFQD->FQD_STATQY
			          			ST9->(MsUnLock())
			    	    	EndIf
			    	    EndIf
			
	    			    TRBFQD->(dbCloseArea())
                    EndIf
    			    TRBPSQ->(dbCloseArea())
		    	Endif
		
        EndIf

Return .T.

/*/{Protheus.doc} ComTesCla
	(substitui o D1_TES, para tes de classificação D1_TESACLA)
	@type  Static Function
	@author Thiago Rodrigues
	@since 23/11/2023
_references)
/*/
Static Function ComTesCla(aItens)
local nX := 1 
local nPosTes := 0
Default aItens := {}

For nX := 1 To Len(aItens)
	nPosTes := aScan(aItens[nX],{|x| x[1] == "D1_TES"})
	If nPosTes > 0
		aItens[nX,nPosTes,1] := "D1_TESACLA"
	Endif
Next nX

Return

/*/{Protheus.doc} ComMontDHR
	(Retorna o Array DHR para enviar no execAuto)
	@type  Static Function
	@author Thiago Rodrigues
	@since 21/11/2023
	@see (links_or_references)
/*/
Static Function ComMontDHR()
local cAliasSDT := "" 
local aItensDHR := {}
local aItem     := {}
local oObjDHR   := nil
local cQry      := ""
local cQryStat  := ""

cAliasSDT := GetNextAlias() 
oObjDHR   := FWPreparedStatement():New()

cQry := " SELECT SDT.DT_ITEM ITEM, SDT.DT_NATREN NATREN " 
cQry += " FROM " + RetSqlName("SDT") + " SDT"
cQry += " WHERE SDT.DT_FILIAL = ? " 
cQry += " AND SDT.DT_FORNEC = ? " 
cQry += " AND SDT.DT_LOJA = ? " 
cQry += " AND SDT.DT_DOC = ? " 
cQry += " AND SDT.DT_SERIE = ? " 
cQry += " AND SDT.D_E_L_E_T_ = ' ' " 

cQry := ChangeQuery(cQry)

oObjDHR:SetQuery(cQry)

oObjDHR:SetString(1,fwxFilial("SDT"))
oObjDHR:SetString(2,SDS->DS_FORNEC)
oObjDHR:SetString(3,SDS->DS_LOJA)
oObjDHR:SetString(4,SDS->DS_DOC) 
oObjDHR:SetString(5,SDS->DS_SERIE) 

cQryStat := oObjDHR:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasSDT)

While !(cAliasSDT)->(eof())
	
	aItem := {}
	aAdd(aItensDHR, Array(2))
	aItensDHR[Len(aItensDHR)][1] := (cAliasSDT)->ITEM
	aItensDHR[Len(aItensDHR)][2] := {}

	aAdd(aItem, {"DHR_FILIAL"   , xFilial("DHR")       ,Nil})
	aAdd(aItem, {"DHR_ITEM"     , (cAliasSDT)->ITEM    ,Nil})
	aAdd(aItem, {"DHR_DOC"      , SDS->DS_DOC          ,Nil})
	aAdd(aItem, {"DHR_SERIE"    , SDS->DS_SERIE        ,Nil})
	aAdd(aItem, {"DHR_FORNECE"  , SDS->DS_FORNEC       ,Nil})
	aAdd(aItem, {"DHR_LOJA"     , SDS->DS_LOJA         ,Nil})
	aAdd(aItem, {"DHR_NATREN"   , (cAliasSDT)->NATREN  ,Nil})

	aAdd(aItensDHR[Len(aItensDHR)][2], aClone(aItem))

	(cAliasSDT)->(DbSkip())
end

(cAliasSDT)->(DbCloseArea())

Return aItensDHR

/*/{Protheus.doc} Loca102PVen
Retorna a quantidade total do retorno 
@type function
@version 25.10
@author Alexandre Circenis
@since 03/10/2025
@return variant, return_description
/*/
Function Loca102PVen()
Local nQtd := 0
Local oModel := FwModelActive()
Local oSDTGrid := oModel:GetModel("SDT_GRID")
Local nX
Local aLinhas := FWSaveRows()

For nX := 1 to oSDTGrid:Length()
	oSDTGrid:GoLine(nX)
	nQtd += oSDTGrid:GetValue("DT_QUANT")
Next

FWRestRows(aLinhas)
Return nQtd

/*/{Protheus.doc} Loca102PDev
Reorna a quantiade total com devolução informada
@type function
@version 25.10
@author Alexandre Circenis
@since 03/10/2025
@return variant, return_description
/*/
Function Loca102PDev()
Local nQtd := 0
Local oModel := FwModelActive()
Local oSDTGrid := oModel:GetModel("SDT_GRID")
Local oFPAGrid := oModel:GetModel("FPA_GRID")
Local nX
Local nY
Local aLinhas := FWSaveRows()

For nX := 1 to oSDTGrid:Length()
	oSDTGrid:GoLine(nX)

	for nY := 1 to oFPAGrid:Length()

		nQtd += oFPAGrid:GetValue("QTDNEW", nY)

	next nY	

Next

FWRestRows(aLinhas)

Return nQtd
