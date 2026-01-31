#INCLUDE "LOCA104B.CH"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "

STATIC cGrupoLib := ""

/*/{Protheus.doc} LOCA104B
Implementa a Inclusão de Itens no Romaneio de devolução
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function LOCA104B()
Local aParam := {}
Local oExecView
Local aButtons
Local lCanSave := .T.

Private  aRet   := {}
Private  bLoad  := {|oGrid| LOCA104BLd(oGrid)}

    if FQW->FQW_STATUS = '5' // Não podemos incluir novos itens em Romaneio Faturado
        Help(" ",1,"LOCA104B_02",, STR0036,1,0)  //"Operação invalida! O Romaneio já tem documento de devolução gerado."
    	Return .T.
    endif

// Array a ser passado para ParamBox?
	aadd(aParam, {1, STR0001, space(TamSx3("FPA_PRODUT")[1]) , "", "", "SB1", "", 115, .F.})  //"Produto de"
	aadd(aParam, {1, STR0002, Replicate("z",TamSx3("FPA_PRODUT")[1]) , "", "", "Sb1", "", 115, .F.})  //"Produto até"
	aadd(aParam, {1, STR0003, Criavar("FQ5_DATGER", .T.)    , ""  , "", ""   , "", 50, .F.}) //"Data de Geração de"
	aadd(aParam, {1, STR0004, CTod("31/12/2999")    , ""  , "", ""   , "", 50, .F.})  //"Data de Geração até"
	aadd(aParam, {1, STR0005, space(TamSx3("FQ5_GUINDA")[1]), "", "", "ST9", "", 80, .F.})  //"Bem de"
	aadd(aParam, {1, STR0006, Replicate("z",TamSx3("FQ5_GUINDA")[1]), "", "", "ST9", "", 80, .F.})  //"Bem até"
	// Caso confirme a tela de parametros processa a rotina de demanda
	If ParamBox(aParam,STR0007,@aRet, , , , , , , , lCanSave,)   //"Escolha de Itens para romaneio"
		aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.T.,NIL},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0008+" "+Alltrim(FQW->FQW_PROJET)+ STR0018+FQW->FQW_OBRA) //"A.S." //"Itens Enviados do Contrato" //" Obra "
		oExecView:setSource("LOCA104B")
		oExecView:setOK({|| LOCA104BOk(FQW->FQW_NUM)})
		oExecView:setModal(.F.)
		oExecView:SetButtons(aButtons)
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:openView(.T.)

	endif

return .T.

/*/{Protheus.doc} ModelDef
MODELO DE Manipulação de AS
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/

Static Function ModelDef()
local oModel    := FWLoadModel("LOCA104C")
//   local oStrCampo as object
local oStrGrid  as object

//Estrutura de Grid
oStrGrid := FWFormStruct( 1, "FPA", LOCA104BFl() )
oStrGrid:AddField('', ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.)
oStrGrid:AddField(STR0020, ' ', 'QTDNEW' , 'N', TamSx3("FPA_QUANT")[1], TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Qtde Nova' //"Qtd Devolvida"
oStrGrid:AddField(STR0021, ' ', 'QTDNEW2', 'N', TamSx3("FPA_QUANT")[1], TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Qtde Nova' //"Qtd Devolvida 2"
Loca102STR(oStrGrid, "B1_DESC", '1', .F., '001')
Loca102STR(oStrGrid, "B1_UM", '1', .F., '001')
Loca102STR(oStrGrid, "B1_SEGUM", '1', .F., '001')
Loca102STR(oStrGrid, "FQ5_M3", '1', .F., '001')
Loca102STR(oStrGrid, "FPA_PROJET", '1', .F., '001')
Loca102STR(oStrGrid, "FPA_FILREM", '1', .F., '001')
Loca102STR(oStrGrid, "FQ5_PESLIQ", '1', .F., '001')
Loca102STR(oStrGrid, "FQ5_PESBRU", '1', .F., '001')
Loca102STR(oStrGrid, "FQ5_M3", '1', .F., '001')


oStrGrid:SetProperty("QTDNEW", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK') .and. LOCA104BWH()" ))
oStrGrid:SetProperty("QTDNEW2", MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK') .and. LOCA104BWH()" ))
//oStrGrid:SetProperty("FQ5_PESLIQ",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK').and. LOCA104BWH()" ))
//oStrGrid:SetProperty("FQ5_PESBRU",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK').and. LOCA104BWH()" ))
//oStrGrid:SetProperty("FQ5_M3",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK').and. LOCA104BWH()" ))

oStrGrid:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104BCHK()" ))
oStrGrid:SetProperty("QTDNEW",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104BVQ('GRID')" ))
oStrGrid:SetProperty("QTDNEW2",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104BV2('GRID')" ))
//oStrGrid:SetProperty("FQ5_PESLIQ",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104BVL('GRID')" ))
//oStrGrid:SetProperty("FQ5_PESBRU",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104BVB('GRID')" ))
//oStrGrid:SetProperty("FQ5_M3",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA104BVM('GRID')" ))

//Atribuindo formulários para o modelo
// oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA104BCL(oSub) })
oModel:AddGrid( 'GRID', 'CABEC', oStrGrid, , , , ,)
//oModel:GetModel( 'GRID' ):SetLoadFilter( aFilter )
//Setando a chave primária da rotina
//oModel:SetRelation( 'GRID', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","'      '"},{"FQ5_TPAS","'L'"}}, FQ5->( IndexKey( 1 ) ) )

oModel:GetModel( 'GRID' ):bLoad := bLoad

oModel:GetModel( 'GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRID' ):SetNoDeleteLine(.T.)
// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oFW | oModel:GetValue( 'GRID', 'MARK' ) }*/,,STR0022,{|oModel| LOCA104BCO(oModel:GetModel("GRID"))},10 )   //'Quantidade de A.S.'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'QTDNEW', 'QTD', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0023,,10,2 )   //'Quantidade Itens'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'QTDNEW2', 'QTD2U', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0024,,10,2 )  //'Qtd 2 Unid'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0025,,13,5 )   //'Peso Liquido'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0026,,13,5 )   //'Peso Bruto'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_M3', 'VOLUME', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,'m3',,13,5 )

    
//Adicionando descrição ao modelo
oModel:SetDescription( STR0027 ) //"A.S. DIPONIVEL" //"A.S. "
// Adiciona a descricao do Componente do Modelo de Dados
//  oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
oModel:GetModel( 'GRID' ):SetDescription( STR0028)  //"A.S. Enviadas"
//  oModel:SetPrimaryKey( { 'X_ZMVC' } )
  
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função estática do ViewDef
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/12/2025
@return variant, retorna o objeto view
/*///-------------------------------------------------------------------/*/
Static Function ViewDef()
	local oView    := FwLoadView("LOCA104C")
	local oModel   := FWLoadModel( 'LOCA104B' )
	local oStrGrid as object
	Local oCalc

// Instancia a Estrutura
//    oStrCabec := FWFormViewStruct():New()
//    oStrCabec:AddField( 'X_ZMVC' , '01' , 'X_ZMVC' , 'X_ZMVC',{},'@!'  )

// Instancia a Estrutura
	oStrGrid := FWFormStruct( 2, "FPA",  LOCA104BFl() )
	oStrGrid:AddField( 'MARK','01',' ',' ',, 'Check')
	oStrGrid:AddField( 'QTDNEW' , '05', STR0030, STR0029,, "N",X3Picture("FPA_QUANT")) //"Qtde Nova" //"Quantidade Devolvida" //"Qtde Devolvida"
	oStrGrid:AddField( 'QTDNEW2', '05', STR0031, STR0032,, "N",X3Picture("FPA_QUANT")) //"Qtde Nova" //"Qtde Seg Unid" //"Qtde Dev. Seg Unidade"
	Loca102STR(oStrGrid, "B1_DESC", '2', .F., '001')
	Loca102STR(oStrGrid, "B1_UM", '2', .F., '001')
	Loca102STR(oStrGrid, "B1_SEGUM", '2', .F., '001')
	Loca102STR(oStrGrid, "FPA_PROJET", '2', .F., '001')
	Loca102STR(oStrGrid, "FPA_FILREM", '2', .F., '001')
	Loca102STR(oStrGrid, "FQ5_PESLIQ", '2', .F., '001')
	Loca102STR(oStrGrid, "FQ5_PESBRU", '2', .F., '001')
	Loca102STR(oStrGrid, "FQ5_M3", '2', .F., '001')

	oStrGrid:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	oStrGrid:SetProperty("MARK", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("QTDNEW", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("QTDNEW2", MVC_VIEW_CANCHANGE, .T.)
	
	//oStrGrid:SetProperty("LEGEND"     , MVC_VIEW_ORDEM, '000')
	oStrGrid:SetProperty("MARK"       , MVC_VIEW_ORDEM, '001')
	oStrGrid:SetProperty("FPA_FILREM" , MVC_VIEW_ORDEM, '002')
	oStrGrid:SetProperty("FPA_PROJET"    , MVC_VIEW_ORDEM, '003')
	oStrGrid:SetProperty("FPA_OBRA"   , MVC_VIEW_ORDEM, '004')
	oStrGrid:SetProperty("FPA_AS"     , MVC_VIEW_ORDEM, '005')
	//oStrGrid:SetProperty("FQ5_VIAGEM" , MVC_VIEW_ORDEM, '006')
	//oStrGrid:SetProperty("FQ5_DATGER" , MVC_VIEW_ORDEM, '008')
	//oStrGrid:SetProperty("FQ5_HORGER" , MVC_VIEW_ORDEM, '009')
	oStrGrid:SetProperty("FPA_PRODUT"  , MVC_VIEW_ORDEM, '010')
	oStrGrid:SetProperty("B1_DESC"    , MVC_VIEW_ORDEM, '011')
	oStrGrid:SetProperty("FPA_QUANT"   , MVC_VIEW_ORDEM, '012')
	
	
	oStrGrid:SetProperty("QTDNEW"     , MVC_VIEW_ORDEM, '013')
	oStrGrid:SetProperty("B1_UM"   , MVC_VIEW_ORDEM, '014')
	oStrGrid:SetProperty("QTDNEW2"   , MVC_VIEW_ORDEM, '015')
	oStrGrid:SetProperty("B1_SEGUM"   , MVC_VIEW_ORDEM, '016')
	oStrGrid:SetProperty("FQ5_PESLIQ" , MVC_VIEW_ORDEM, "017")
	oStrGrid:SetProperty("FQ5_PESBRU" , MVC_VIEW_ORDEM, "018")
	oStrGrid:SetProperty("FQ5_M3"     , MVC_VIEW_ORDEM, "019")
	//oStrGrid:SetProperty("FPA_LOCAL"  , MVC_VIEW_ORDEM, '018')
	oStrGrid:SetProperty("FPA_GRUA" , MVC_VIEW_ORDEM, '020')
	oStrGrid:SetProperty("FPA_DESGRU" , MVC_VIEW_ORDEM, '021')
	//oStrGrid:SetProperty("FQ5_DTINI"  , MVC_VIEW_ORDEM, '021')
	//oStrGrid:SetProperty("FQ5_DTFIM"  , MVC_VIEW_ORDEM, '022')

// Carrega o Modelo
//oModel  := FWLoadModel( "LOCA104B")
	oCalc  	:= FWCalcStruct(oModel:GetModel('RODAPE'))

// Seta o Modelo da View
	oView:SetModel( oModel )

// Estrutura visual dos campos
//  oView:AddField('CAB', oStrCabec, 'CABEC')

// Estrutura visual das grids
	oView:AddGrid('VIEW_GRID', oStrGrid, 'GRID')

	oView:AddField( 'VIEW_CALC', oCalc, 'RODAPE' )
	oView:SetViewProperty("GRID", "GRIDSEEK",    {.T.})
	oView:SetViewProperty("GRID", "GRIDFILTER", {.T.})
	oView:CreateVerticalBox( 'TELA2', 100,'GRID' )
//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'CABEC', 0, "TELA2" )
	oView:CreateHorizontalBox( 'DADOS', 100, "TELA2" )

	oView:CreateFolder( 'FOLDER', 'DADOS')
	oView:AddSheet('FOLDER','SHEET1', STR0033) //'A.S. Disponiveis' //"A.S. Disponivieis"
	oView:CreateHorizontalBox( 'Leitura', 40, ,.T. , 'FOLDER', 'SHEET1')	
	oView:CreateHorizontalBox( 'GRID2', 90, , , 'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox( 'FOOT', 80 , ,.T. , 'FOLDER', 'SHEET1')

	oView:CreateVerticalBox( 'RODAPE', 80, 'FOOT',, 'FOLDER', 'SHEET1')
	oView:CreateVerticalBox( 'BOTAO', 20, 'FOOT',, 'FOLDER', 'SHEET1')

	oView:AddOtherObject("btnMarcaDesm1", {|oPanel,oView| LOCA259EBT(oPanel, "GRID")})
	//oView:AddOtherObject("LeituraCB", {|oPanel,oView| LOCA104BCB(oPanel, "GRID")})

	oView:AddSheet('FOLDER','SHEET2',STR0034, {|| LOCA104BRS()}) //'Resumo' //"Resumo"
	oView:CreateHorizontalBox( 'RESUMO', 100, , , 'FOLDER', 'SHEET2')

	oView:SetOwnerView('VIEW_CAB' , 'CABEC' )
	oView:SetOwnerView('GRID', 'GRID2')
	oView:SetOwnerView('VIEW_CALC', 'RODAPE')
	oView:SetOwnerView('VIEW_RESUMO', 'RESUMO')
	oView:SetOwnerView("btnMarcaDesm1", 'BOTAO')
	//oView:SetOwnerView("LeituraCB", 'Leitura')

	oView:SetViewProperty( "VIEW_CALC", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 85} )
	
	oView:SetDescription(STR0035 )  //"Gestão de Devolução"


Return oView
/*/{Protheus.doc} LOCA104BFl
Retorna se o bloco de codigo com os campos irão fazer parte do Model ou da View
@type function
@version 25.10
@author Alexandre Circenis
@since 21/10/2025
@return variant, Bloco de Codigo conforme descrição
/*/
Static Function LOCA104BFl()
	bCampos := {|cCampo| cCampo $ "FPA_PROJET FPA_OBRA   FPA_AS    FPA_PRODUT FPA_GRUA   FPA_DESGRU FPA_QUANT   " }

Return bCampos

/*/{Protheus.doc} LOCA104BLD
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function LOCA104BLd( oMdl)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local cTmp		:= ''
	Local aParam    := {}

	cTmp := GetNextAlias()
	
	cQuery += "SELECT FPA.*, SB1.B1_DESC,B1_UM, B1_SEGUM,'F' MARK"
	
	cQuery += " FROM " + RetSqlName("FPA") + " FPA "  				// Trazer os itens do Contrato ainda não devolvidos	
	
	cQuery += " INNER JOIN  " +	RetSqlName("SB1") + " SB1 "  				
	cQuery += " ON  SB1.B1_FILIAL  =  '" + xFilial("SB1") + "' "
	cQuery += " AND	SB1.B1_COD = FPA_PRODUT"
	cQuery += " AND	SB1.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN " +	RetSqlName("FQ5") + " FQ5 "  
	cQuery += " ON  FQ5.FQ5_FILIAL  =  '" + xFilial("FQ5") + "' "
	cQuery += " AND	FQ5.FQ5_AS = FPA.FPA_AS"
	cQuery += " AND FQ5.FQ5_DATGER >= ? "
	cQuery += " AND FQ5.FQ5_DATGER <= ? "
	aadd( aParam, Dtos(aRet[03]) )
	aadd( aParam, Dtos(aRet[04]) )
	cQuery += " AND	FQ5.D_E_L_E_T_  =  ' ' "
 
	cQuery += " LEFT JOIN  " +	RetSqlName("ST9") + " ST9 "  					
	cQuery += " ON  ST9.T9_FILIAL  =  '" + xFilial("ST9") + "' "
	cQuery += " AND ST9.T9_CODBEM  =  FPA.FPA_GRUA "
	cQuery += " AND ST9.D_E_L_E_T_  =  ' ' "

	cQuery += " WHERE FPA.FPA_FILIAL  =  '" + xFilial("FPA") + "' "
	cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
	cQuery += " AND	FPA.FPA_NFRET = ' '"
	cQuery += " AND	FPA.FPA_NFREM <> ' '"
	cQuery += " AND FPA.FPA_PROJET = ? "
	aadd( aParam, FQW->FQW_PROJET )
	cQuery += " AND FPA_OBRA = ? "
	aadd( aParam, FQW->FQW_OBRA )
	cQuery += " AND  FPA_PRODUT >= ? "
	cQuery += " AND  FPA_PRODUT <= ? "
	aadd( aParam, aRet[01] )
	aadd( aParam, aRet[02] )
	
	cQuery += " AND  FPA_GRUA >= ? "
	cQuery += " AND  FPA_GRUA <= ? "
	aadd( aParam, aRet[05] )
	aadd( aParam, aRet[06] )
	If !Empty(FQW->FQW_FILREM)
		cQuery += " AND  FPA_FILREM = ? "
		aadd( aParam, FQW->FQW_FILREM )
	endif
	cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "


	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio antigo
	cQuery += " SELECT  FQ3_AS "
	cQuery += " FROM " + RetSqlName("FQ3") +" FQ3 "
	cQuery += " WHERE FQ3_FILIAL = '"+xFilial("FQ3")+"'"
	cQuery += " AND FQ3_AS = FPA.FPA_AS "
	cQuery += " AND FQ3_NFREM = ' ' "
	cQuery += " AND FQ3_NFRET = ' ' "
	cQuery += " AND FQ3.D_E_L_E_T_ = ' ')"

	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio novo e não foi faturado
	cQuery += " SELECT  FQX_AS "
	cQuery += " FROM " + RetSqlName("FQX") +" FQX "
	cQuery += " WHERE FQX_FILIAL = '"+xFilial("FQX")+"'"
	cQuery += " AND FQX_AS = FPA.FPA_AS "
	cQuery += " AND FQX_NFRET = ' ' "
	cQuery += " AND FQX.D_E_L_E_T_ = ' ')"

	cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
	MPSysOpenQuery(cQuery,cAliasT,,,aParam)

//-- Formata Campos Da Query
	aStruQry := (cAliasT)->(DbStruct())

	For nLinha := 1 To Len(aStruQry)
		If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
			TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
		Endif
	Next nLinha
	TCSetField( cAliasT , "MARK", "L")
/*
FWLoadByAlias
Função que realiza a carga de um submodelo baseado em um alias existente

@param oObj, character,         Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
@param cAlias, character,       Alias para carga .
@param cAliasReal, character,   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                                                           se nao for informado usa a tabela definida na estrutura do objeto.
@param cFieldRecno, character,  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                                                           deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                                                           RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
@param lCopy, logical,        Apenas para compatibilidade, Nao usar
@param lQuery, Logical,       Indica que o alias foi criado a partir de uma query.
*/

// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FPA' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )

/*/{Protheus.doc} LOCA104BOk
Processa o botão Ok da tela de inclusão de itens no romaneio
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/28/2025
@return variant, Sem retorno
/*/
Function LOCA104BOk(cRomaneio)
Local oModel:= FWModelActive()
Local oGrid := oModel:GetModel("GRID")
Local aAlteradas := {}
Local nX
Local nIncluidas := 0
Local cTitulo := STR0009 //"A.S. Incluidas Romaneio"
Local cItem   := LOCA104BMX(cRomaneio)
Local cFilRem := ''

BEGIN TRANSACTION
// incluir itens no romaneio posicionado
aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGrid:Goline(aAlteradas[ nX])

	if oGrid:GetValue('MARK') // Marcado realizar a inclusão no romaneio
	
		// Volta para FPA marcada
		FPA->(dbGoTo(oGrid:GetDataID()))
	
		// Incluir o item marcado no Romaneio
		cItem := Soma1(cItem)
		RecLock("FQX", .T.)
		FQX->FQX_FILIAL := xFilial("FQX")
		FQX->FQX_NUM    := cRomaneio
		FQX->FQX_ITEM   := cItem
		FQX->FQX_PROD   := FPA->FPA_PRODUT
		FQX->FQX_UNID   := oGrid:GetValue("B1_UM")
		FQX->FQX_QTD    := oGrid:GetValue('QTDNEW')
		FQX->FQX_UNID2  := oGrid:GetValue("B1_SEGUM")
		FQX->FQX_QTD2   := oGrid:GetValue('QTDNEW2')
		FQX->FQX_CODBEM := FPA->FPA_GRUA
		FQX->FQX_AS     := FPA->FPA_AS
		FQX->FQX_CONTRA := FPA->FPA_PROJET
		FQX->FQX_OBRA   := FPA->FPA_OBRA
		FQX->FQX_STATUS := '2' // Primeira Contagem
		cFilRem         := oGrid:GetValue('FPA_FILREM')
		msUnLock()

		nIncluidas++

	endif
next

if nIncluidas > 0
	
	if !IsInCallStack("Loca104AEV") // Não Veio da alteração de Romaneio 
		LOCA104AC() // Analise de capacidade
	endif

	RecLock("FQW", .F.)
	FQW->FQW_STATUS := '2' // Primeira contagem realizada
	FQW->FQW_FILREM := cFilRem
	msUnLock()

endif

END TRANSACTION

if nIncluidas > 0
	Aviso(cTitulo,STR0010+Alltrim(Transform( nIncluidas, "@E 9,999,999"))+;  //"Foram incluidas "
	STR0011+cRomaneio , {"Ok"})  //" A.S. no romaneio "
endif

RETURN .T.

/*/{Protheus.doc} LOCA104BMX
Retorna o maior valor do campo item do romaneio, levando em consideração os deletados, caso não tenha nenhum item
retorna branco para iniciar a numeração
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/28/2025
@param cRomaneio, character, Codigo do Romaneio
@return variant, Maior codigo do item
/*/
Function LOCA104BMX(cRomaneio)
Local cMax 
Local cQuery := ""
Local aArea  := GetArea()
Local aBindParam := {}
Local cAliasT    := GetNextAlias()

cQuery := "SELECT Max(FQX_ITEM) ITEM"
cQuery += " FROM "+RetSqlName("FQX")
cQUERY += " WHERE FQX_FILIAL = '"+xFilial("FQX")+"'"
cQuery += " and FQX_NUM = ?"
Aadd(aBindParam, cRomaneio)

cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aBindParam)

cMax := (cAliasT)->ITEM

RestARea(aArea)

RETurn cMax

/*/{Protheus.doc} LOCA104BVQ
Valida a nova quantidade (QTDNEW)
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Retorna se a nova quantidade é valida ou não 
/*/
FUNCTION LOCA104BVQ(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	LOcal oGrid  := oModel:GetModel(cGrid)

	if M->QTDNEW > oGrid:GetValue("FPA_QUANT")
		oModel:SetErrorMessage("","","","","LOCA2591_01",STR0012,) // //"A nova quantidade não pode ser maior que a quantidade original."
		lRet := .F.
	elseif  M->QTDNEW <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02",STR0013,) // //"A nova quantidade não pode ser menor que zero."
		lRet := .F.
	endif

	if lRet
		// Ajustar os demais campos
		LOCA104BGA(0, cGrid)
	endif
Return lRet

/*/{Protheus.doc} LOCA104BV2
Valida a quantidade na segunda unidade 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Retorna se a quantidade na segunda unidade é valida ou não
/*/
FUNCTION LOCA104BV2(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	Local oGrid  := oModel:GetModel(cGrid)

	if ConvUm( oGrid:GetValue("FPA_PRODUT"), oGrid:GetValue("QTDNEW"),M->QTDNEW2, 1 ) > oGrid:GetValue("FPA_QUANT")
		oModel:SetErrorMessage("","","","","LOCA2591_01",STR0012,) // //"A nova quantidade não pode ser maior que a quantidade original."
		lRet := .F.
	elseif  M->QTDNEW2 <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02",STR0013,) // //"A nova quantidade não pode ser menor que zero."
		lRet := .F.
	endif

	if lRet
		oGrid:SetValue("QTDNEW", ConvUm( oGrid:GetValue("FPA_PRODUT"), oGrid:GetValue("QTDNEW"),M->QTDNEW2, 1 ) )
		// Ajustar os demais campos
		LOCA104BGA(1, cGrid)
	endif

Return lRet

/*/{Protheus.doc} LOCA104BVL
Valida o novo valor do Peso liquido
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Retorna o novo valor do peso liquido
/*/
/* Não há peso
FUNCTION LOCA104BVL(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	Local oGrid  := oModel:GetModel(cGrid)

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FPA_PRODUT")))
	
	if M->FQ5_PESLIQ > SB1->B1_PESO * oGrid:GetValue("FPA_QUANT")
		oModel:SetErrorMessage("","","","","LOCA2591_01","O novo peso liquido não pode ser maior que o peso original.",) //
		lRet := .F.
	elseif M->FQ5_PESLIQ <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02","O novo peso liquido não pode ser menor que zero.",) //
		lRet := .F.
	elseif !LOCA104BAS(oModel, cGrid)
		lRet := .F.
	endif

	if lRet
		oGrid:SetValue("QTDNEW", M->FQ5_PESLIQ / SB1->B1_PESO  )
		// Ajustar os demais campos
		LOCA104BGA(2, cGrid)
	endif
	
Return lRet
/*/
/*/{Protheus.doc} LOCA104BVB
Valida o novo valor do Peso Bruto
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Valida se o novo valor do peso bruto for valido
/*/
/*/
FUNCTION LOCA104BVB(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	LOcal oGrid  :=  oModel:GetModel(cGrid)

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FPA_PRODUT")))
	
	if M->FQ5_PESBRU > SB1->B1_PESBRU  * oGrid:GetValue("FPA_QUANT")
		oModel:SetErrorMessage("","","","","LOCA2591_01","O novo peso bruto não pode ser maior que o peso original.",) //
		lRet := .F.
	elseif M->FQ5_PESBRU <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02","O novo peso bruto não pode ser menor que zero.",) //
		lRet := .F.
	elseif !LOCA104BAS(oModel, cGrid)
		lRet := .F.
	endif

	if lRet
		oGrid:SetValue("QTDNEW", M->FQ5_PESBRU / SB1->B1_PESBRU )
		// Ajustar os demais campos
		LOCA104BGA(3,cGrid)
	endif
	
Return lRet
/*/

/*/{Protheus.doc} LOCA104BVM
Valida o novo valor do Metro cubico
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Indica que o novo valor do Metro Cubico é valido
/*/
/*/
FUNCTION LOCA104BVM(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	Local oGrid  := oModel:GetModel(cGrid)
	Local nM3 := 0

	SB5->(dbSetOrder(1))
	if SB5->(dbSeek(xFilial("SB1")+oGrid:GetValue("FPA_PRODUT")))
		nM3 := SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC 

		if M->FQ5_M3 > nM3  * oGrid:GetValue("FPA_QUANT")
			oModel:SetErrorMessage("","","","","LOCA2591_01","O volume não pode ser maior que o volume original.",) //
			lRet := .F.
		elseif M->FQ5_M3 <= 0
			oModel:SetErrorMessage("","","","","LOCA2591_02","O novo volume não pode ser menor que zero.",) //
			lRet := .F.
		elseif !LOCA104BAS(oModel, cGrid)
			lRet := .F.
		endif

		if lRet
			oGrid:SetValue("QTDNEW",  M->FQ5_M3 / (SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC) )
			// Ajustar os demais campos
			LOCA104BGA(4, cGrid)
		endif
	endif


Return lRet
/*/

/*/{Protheus.doc} LOCA104BCHK
Processa a marcação de um item da Grid 
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@return variant, returna .T.
/*/
FUNCTION LOCA104BCHK()
	Local oModel := FwModelActive()
	Local oGrid  := oModel:GetModel("GRID")
	Local nX

	if FwFldGet("MARK")
		// Verificar se está na mesma filial dos demais marcados
		for nX := 1 to oGrid:Length()
			if nX <> oGrid:GetLine() .and. oGrid:GetValue("MARK", nX)
				if fwFldGet("FPA_FILREM") <> oGrid:GetValue("FPA_FILREM", nX)
					oModel:SetErrorMessage("","","","","LOCA104B_CHK",STR0019,)  //"Só itens da mesma filial de remessa podem ser selecinados."
					REturn .F.
				endif
			endif
		next	
		// Gatilhar os campos calculados 
		if Empty(FwFldGet("QTDNEW"))

			oGrid:LoadValue( "QTDNEW", FWFldGet("FPA_QUANT"))
			LOCA104BGA(0,"GRID") // Atualizar todos os campos ajustaveis

		endif

	ELSE

		oGrid:LoadValue( "QTDNEW", 0 )
		LOCA104BGA(0, "GRID") // Atualizar todos os campos ajustaveis

	ENDIF

Return .T.

/*/{Protheus.doc} LOCA104BWH
Libera a edição com campo quando o grupo do produto estiver contido no parametro de grupos ou 
nos grupos definidos pelo camo BM_XACESS
@type function
@version 25.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, O campo de quantidade pode ser modificado
/*/
Function LOCA104BWH()
Local lRet := .T.
Local cGrupoProd := Posicione("SB1",1, xFilial("SB1")+FwFldGet("FPA_PRODUT"),"B1_GRUPO")

if cGrupoLib = NIL .or. Empty(cGrupoLib)

	cGrupoLib := LOCA00189() // Retorno os grupos de acessorios

endif

lRet := cGrupoProd $ alltrim(cGrupoLib)

Return lRet

/*/{Protheus.doc} LOCA104BGA
Preenche campos da grid conforme a origem
@type function
@version  24.10
@author Alexandre Circenis
@since 2/27/2025
@param nTipo, numeric, Indica a origem 

/*/
Function LOCA104BGA(nTipo, cGrid)
Local aArea := GetArea()
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel(cGrid)

if nTipo <> 1 // Não veio da QTD2 Ajustar
	oGrid:LoadValue( "QTDNEW2"  , ConvUm( oGrid:GetValue("FPA_PRODUT"), oGrid:GetValue("QTDNEW"),0, 2 ) )
endif

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FPA_PRODUT")))

if nTipo <> 2 // Não veio do peso Liquido	
	oGrid:LoadValue( "FQ5_PESLIQ", SB1->B1_PESO * oGrid:GetValue("QTDNEW"))
endif
if nTipo <> 3 // Não veio do peso bruto
	oGrid:LoadValue("FQ5_PESBRU", SB1->B1_PESBRU * oGrid:GetValue("QTDNEW"))
endif
if nTipo <> 4 // Não veio do m3 (Volume)
	SB5->(dbSetOrder(1))
	if SB5->(dbSeek(xFilial("SB5")+oGrid:GetValue("FPA_PRODUT")))
		oGrid:LoadValue( "FQ5_M3"    ,SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC * oGrid:GetValue("QTDNEW"))
	endif
endif

RestArea(aArea)

Return

/*/{Protheus.doc} LOCA104BRS
REcalcular o Resumo os itens selecionados
@type function
@version 24.10  
@author Alexandre Circenis
@since 2/27/2025
@return variant, return_description
/*/
Function LOCA104BRS()
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("GRID")
Local oResumo := oModel:GetModel("RESUMO")
Local oView := FWViewActive()
Local aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
Local nI
Local lAchou  := .F.

oResumo:ClearData()

for nI := 1 to Len(aAlteradas)

	oGrid:Goline(aAlteradas[nI])

	lAchou := oResumo:SeekLine({{"PRODUTO",FWFldGet("FPA_PRODUT")}})

	if FwFldGet("MARK") // LInha Selecionada
		
		lAchou := oResumo:SeekLine({{"PRODUTO",FWFldGet("FPA_PRODUT")}})
		 
		if !lAchou
			if Empty(FWFldGet("PRODUTO",1)) // LInha 1 Vazia
				oResumo:GoLine(1)
			else
				oResumo:AddLine()
			endif
			FwFldPut( "PRODUTO", FWFldGet("FPA_PRODUT"))
			FwFldPut( "DESCPRO", FWFldGet("B1_DESC"))

		endif
		FwFldPut( "QTDE", FwFldGet("QTDE")+FwFldGet("QTDNEW"))
		FwFldPut( "QSEGUNID", FwFldGet("QSEGUNID")+FwFldGet("QTDNEW2"))
		FwFldPut( "PESLIQ",  FwFldGet("PESLIQ") + (FwFldGet("QTDNEW") * FwFldGet("FQ5_PESLIQ")))
		FwFldPut( "PESBRU",  FwFldGet("PESBRU") + (FwFldGet("QTDNEW") * FwFldGet("FQ5_PESBRU")))
		FwFldPut( "M3"    ,  FwFldGet("M3") + (FwFldGet("QTDNEW") * FwFldGet("FQ5_M3")))

	endif

Next

oResumo:GoLine(1)
oview:Refresh( 'VIEW_RESUMO' )

Return

/*/{Protheus.doc} LOCA104BCO
Conta o numero de linhas marcadas
@type function
@version 24.10
@author Alexandre Circenis
@since 3/9/2025
@param oModel, object, Modelo de dados
@return variant, Numero de Linhas Marcadas
/*/
FUNCTION LOCA104BCO(oGrid)
Local nContar  := 0
Local nLinhas

for nLinhas := 1 to oGrid:Length()

	if oGrid:GetValue("MARK", nLinhas)

		nContar++

	endif

next

return nContar

/*/{Protheus.doc} LOCA104BCB
Botões de marcar e desmarcar todos
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/

//Function LOCA104BCB(oPanel, cGrid)
//Local oModel as object
//Local oView  as object
//Local oSayCodBar		:= Nil													//objeto say codigo de barras
//Local oGetCodBar		:= Nil													//objeto get codigo de barras
//Local cGetCodBar		:= Space(Max(TamSx3("T9_CODBEM")[1],TamSx3("B1_CODBAR")[1] ))
//Inicializa variáveis
//oModel   	:= FWModelActive()
//oView    	:= FwViewActive()	

//Say Codigo de Barras
//oSayCodBar := tSay():New( 07, 15, {|| STR0014}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10) //"Código de Barras:"
//Get Codigo de Barras
//oGetCodBar := TGet():New( 05, 70, {|u| If(PCount() > 0, cGetCodBar := u, cGetCodBar)}, oPanel,;								
//								100, 10, "@!", { || .T. } ,,,,,,.T.,,, {|| },,,, .F.,,,)				

//Perda de foco do campo Codigo de Barras
//oGetCodBar:bLostFocus := {|| IIF(LOCA104BPC(@cGetCodBar, oGetCodBar, cGrid),; 
//										 .T.,.F.)}
	
//Return()

/*/{Protheus.doc} LOCA104BPC
Busca o codigo informado no campo Codigo de Barra
Primeiro busca pelo codigo do Bem na grid
Se não encontrar busca pelo Codigo de Barra cadastrado no Campo B1_CODBAR 
@type function
@version 25.10
@author Alexandre Circenis
@since 13/11/2025
@param cCodSearch, character, Codigo Contido na campo Codigo de BArra
@param oGetCodBar, object, Objeto do Get do codigo de barra usado para retornar o foco e permitir informar novos codigo
@param cGrid, character, Nome do Grid onde será realizada a busca.
@return variant, return_description
/*/
//Function LOCA104BPC(cCodSearch, oGetCodBar, cGrid)
//Local oModel := FWModelActive()
//Local oGrid  := oModel:GetModel(cGrid)
//Local oView := FWViewActive() 
//Local aSaveLines := FWSaveRows()

//if Empty(cCodSearch)
//	Return
//endif

// Buscar o bem na grid
//if oGrid:SeekLine({{"FPA_GRUA", Alltrim(cCodSearch)}})

//	if oGrid:GetValue("MARK") // Marcado
//		FwAlertErro(STR0016,STR0015) //"Atenção" //"Item já marcado!"
//		Return		/
//	endif

//	oGrid:SetValue("MARK", .T.)

//elseif oGrid:SeekLine({{"FPA_PRODUT", Posicione("SB1", 5, xFilial("SB1")+Alltrim(cCodSearch), "B1_COD")}, {"MARK", .F.}})

//	oGrid:SetValue("MARK", .T.)

//else
//	FwAlertErro(STR0017,STR0015) //"Atenção" //"Produto ou equipamento não encontrado na lista de devolução ou todos itens já foram marcados."
//endif

//FWRestRows( aSaveLines )
//oView:Refresh()
//Atualiza objetos de tela
//cCodSearch := Space(Max(TamSx3("T9_CODBEM")[1],TamSx3("B1_CODBAR")[1] ))
//oGetCodBar:Refresh()
//oGetCodBar:SetFocus()

//Return
