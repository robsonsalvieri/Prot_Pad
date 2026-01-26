#Include "loca259b.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

STATIC cGrupoLib := ""
/*/{Protheus.doc} LOCA259B
Implementa a Movimentação de AS
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function LOCA259B()
	Local aParam := {}
	Local oExecView
	Local aButtons

	Private  aRet   := {}

// Array a ser passado para ParamBox?

	aadd(aParam, {1, STR0001, space(TamSx3("FQ5_SOT")[1])   , "@!", "", "FP0", "", 50, .F.}) //"Projeto de"
	aadd(aParam, {1, STR0002, space(TamSx3("FQ5_SOT")[1])   , "@!", "", "FP0", "", 50, .F.}) //"Projeto até"
	aadd(aParam, {1, STR0003, space(TamSx3("FQ5_OBRA")[1])  , "@!", "", "", "", 50, .F.}) //"Obra de"
	aadd(aParam, {1, STR0004, space(TamSx3("FQ5_OBRA")[1])  , "@!", "", "", "", 50, .F.}) //"Obra até"
	aadd(aParam, {1, STR0005, space(TamSx3("FQ5_XPROD")[1]) , "@!", "", "SB1", "", 115, .F.}) //"Produto de"
	aadd(aParam, {1, STR0006, space(TamSx3("FQ5_XPROD")[1]) , "@!", "", "Sb1", "", 115, .F.}) //"Produto até"
	aadd(aParam, {1, STR0007, Criavar("FQ5_DATGER", .T.)    , ""  , "", ""   , "", 50, .F.}) //"Data de Geração de"
	aadd(aParam, {1, STR0008, Criavar("FQ5_DATGER", .T.)    , ""  , "", ""   , "", 50, .F.}) //"Data de Geração até"
	aadd(aParam, {1, STR0009, Criavar("FQ5_DATINI", .T.)    , ""  , "", ""   , "", 50, .F.}) //"Data inicio de"
	aadd(aParam, {1, STR0010, Criavar("FQ5_DATINI", .T.)    , ""  , "", ""   , "", 50, .F.}) //"Data inicio até"
	aadd(aParam, {1, STR0011, space(TamSx3("FQ5_CODCLI")[1]), "@!", "", "SA1", "", 50, .F.}) //"Cliente de"
	aadd(aParam, {1, STR0012, space(TamSx3("FQ5_LOJA")[1])  , "@!", "", ""   , "", 50, .F.}) //"Loja de"
	aadd(aParam, {1, STR0013, space(TamSx3("FQ5_CODCLI")[1]), "@!", "", "SA1", "", 50, .F.}) //"Cliente até"
	aadd(aParam, {1, STR0014, space(TamSx3("FQ5_LOJA")[1])  , "@!", "", ""   , "", 50, .F.}) //"Loja até"
	aadd(aParam, {1, STR0015, space(TamSx3("FQ5_GUINDA")[1]), "@!", "", "ST9", "", 80, .F.}) //"Bem de"
	aadd(aParam, {1, STR0016, space(TamSx3("FQ5_GUINDA")[1]), "@!", "", "ST9", "", 80, .F.}) //"Bem até"
// Caso confirme a tela de parametros processa a rotina de demanda

	If ParamBox(aParam,STR0017,@aRet) //"Importar Classifica?o Ativo" //"Gestão de Demanda"
		aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			{.F.,Nil},{.F.,NIL},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
			{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		oExecView := FWViewExec():New()
		oExecView:setTitle("A.S.")
		oExecView:setSource("LOCA259B")
		//oExecView:setOK({|| bOK})
		oExecView:setModal(.F.)
		oExecView:SetButtons(aButtons)
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:openView(.T.)

	endif

return
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
MODELO DE Manipulação de AS
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
//-------------------------------------------------------------------/*/
Static Function ModelDef()
local oModel    := FWLoadModel("LOCA259C")
//   local oStrCampo as object
local oStrGrid  as object

// Estrutura Fake de Field
//   oStrCampo := FWFormModelStruct():New()

//Adiciona um campo a estrutura.
//  oStrCampo:AddField( 'X_ZMVC' , 'X_ZMVC' , 'X_ZMVC' , 'C' , 15 ) 

//Estrutura de Grid
oStrGrid := FWFormStruct( 1, "FQ5", Loca259BFl() )
oStrGrid:AddField('', ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.)
oStrGrid:AddField(STR0018, ' ', 'B1_DESC', 'C',TamSx3("B1_DESC")[1], 0, , , {}, .F.) //'Desc '
oStrGrid:AddField(STR0019, ' ', 'FPA_LOCAL', 'C',TamSx3("FPA_LOCAL")[1], 0, , , {}, .F.) //'Armazem'
oStrGrid:AddField(STR0020, ' ', 'FPA_DESGRU', 'C',TamSx3("FPA_DESGRU")[1],0, , , {}, .F.) //'Desc Equip'
oStrGrid:AddField(STR0063, ' ', 'QTDNEW', 'N', TamSx3("FQ5_XQTD")[1], TamSx3("FQ5_XQTD")[2], , , {}, .F.) //'Qtde Nova'
oStrGrid:AddField( ;
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'LEGEND' , ;               // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || if( FQ5->FQ5_STATUS == "1", 'BR_VERDE' ,; //  PENDENTE
				 			 if(!FQ5->FQ5_STATUS $ "1/6"  , 'BR_VERMELHO' ,; //  REJEITADO
						     if(FQ5->FQ5_STATUS == "6", 'BR_LARANJA' , 'BR_BRANCO')))} , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

oStrGrid:SetProperty("QTDNEW",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK') .and. Loca259BWH()" ))
oStrGrid:SetProperty("FQ5_QTD2",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK') .and. Loca259BWH()" ))
oStrGrid:SetProperty("FQ5_PESLIQ",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK').and. Loca259BWH()" ))
oStrGrid:SetProperty("FQ5_PESBRU",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK').and. Loca259BWH()" ))
oStrGrid:SetProperty("FQ5_M3",MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, "FWFldGet('MARK').and. Loca259BWH()" ))

oStrGrid:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BCHK()" ))
oStrGrid:SetProperty("QTDNEW",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BVQ('GRID')" ))
oStrGrid:SetProperty("FQ5_QTD2",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BV2('GRID')" ))
oStrGrid:SetProperty("FQ5_PESLIQ",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BVL('GRID')" ))
oStrGrid:SetProperty("FQ5_PESBRU",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BVB('GRID')" ))
oStrGrid:SetProperty("FQ5_M3",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BVM('GRID')" ))

//Atribuindo formulários para o modelo
// oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA259BCL(oSub) })
oModel:AddGrid( 'GRID', 'CABEC', oStrGrid, , , , ,{|oGrid| Loca259LdG(oGrid)})
//oModel:GetModel( 'GRID' ):SetLoadFilter( aFilter )
//Setando a chave primária da rotina
//oModel:SetRelation( 'GRID', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","'      '"},{"FQ5_TPAS","'L'"}}, FQ5->( IndexKey( 1 ) ) )
    
oModel:GetModel( 'GRID' ):SetNoInserLine(.T.)
oModel:GetModel( 'GRID' ):SetNoDeleteLine(.T.)
// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oFW | oModel:GetValue( 'GRID', 'MARK' ) }*/,,STR0021,{|oModel| Loca259BCO(oModel:GetModel("GRID"))},10 ) //'Quantidade de A.S.'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'QTDNEW', 'QTD', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0022,,10,2 ) //'Quantidade Itens'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_QTD2  ', 'QTD2U', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0070,,10,2 ) //'Qtd 2 Unid'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0023,,13,5 ) //'Peso Liquido'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,STR0024,,13,5 ) //'Peso Bruto'
oModel:AddCalc( 'RODAPE', 'CABEC', 'GRID', 'FQ5_M3', 'VOLUME', 'SUM', { | oFW | oModel:GetValue( 'GRID', 'MARK' ) },,'m3',,13,5 )

    
//Adicionando descrição ao modelo
oModel:SetDescription( STR0064 ) //"A.S. DIPONIVEL"
// Adiciona a descricao do Componente do Modelo de Dados
//  oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
oModel:GetModel( 'GRID' ):SetDescription( STR0030 ) //"A.S. Disponiveis"
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
	local oView    := FwLoadView("LOCA259C")
	local oModel   := FWLoadModel( 'LOCA259B' )
	local oStrGrid as object
	Local oCalc

// Instancia a Estrutura
//    oStrCabec := FWFormViewStruct():New()
//    oStrCabec:AddField( 'X_ZMVC' , '01' , 'X_ZMVC' , 'X_ZMVC',{},'@!'  )

// Instancia a Estrutura
	oStrGrid := FWFormStruct( 2, "FQ5",  Loca259BFl() )
	oStrGrid:AddField( 'MARK','01',' ',' ',, 'Check')
	oStrGrid:AddField( 'B1_DESC', '02', STR0065, STR0025, , "C" ) //"Descrição do Produto"
	oStrGrid:AddField( 'FPA_LOCAL', '03', STR0019,STR0026, , "C" ) //"Local de Armazenagem"
	oStrGrid:AddField( 'FPA_DESGRU', '04', STR0020, STR0027, , "C") //"Descrição do Equipamento"
	oStrGrid:AddField( 'QTDNEW', '05', STR0028, STR0029,, "N",X3Picture("FQ5_XQTD")) //"Qtde Nova"
	oStrGrid:AddField( ;            		// Ord. Tipo Desc.
	'LEGEND'                   	, ;   	// [01]  C   Nome do Campo
	"00"                         	, ;     // [02]  C   Ordem
	AllTrim( ''    )         , ;     // [03]  C   Titulo do campo
	AllTrim( '' )       , ;     // [04]  C   Descricao do campo
	{ STR0071 } 		, ;     // [05]  A   Array com Help //'Legenda'
	'C'                             , ;     // [06]  C   Tipo do campo
	'@BMP'                , ;     // [07]  C   Picture
	NIL                             , ;     // [08]  B   Bloco de Picture Var
	''                              , ;     // [09]  C   Consulta F3
	.T.                             , ;     // [10]  L   Indica se o campo é alteravel
	NIL                             , ;     // [11]  C   Pasta do campo
	NIL                             , ;     // [12]  C   Agrupamento do campo
	NIL				               	, ;     // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                             , ;     // [14]  N   Tamanho maximo da maior opção do combo
	NIL                             , ;     // [15]  C   Inicializador de Browse
	.T.                             , ;     // [16]  L   Indica se o campo é virtual
	NIL                             , ;     // [17]  C   Picture Variavel
	NIL                             )       // [18]  L   Indica pulo de linha após o campo


	oStrGrid:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	oStrGrid:SetProperty("MARK", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("QTDNEW", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_QTD2", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_PESLIQ", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_PESBRU", MVC_VIEW_CANCHANGE, .T.)
	oStrGrid:SetProperty("FQ5_M3", MVC_VIEW_CANCHANGE, .T.)

	oStrGrid:SetProperty("LEGEND"     , MVC_VIEW_ORDEM, '000')
	oStrGrid:SetProperty("MARK"     , MVC_VIEW_ORDEM, '001')
	oStrGrid:SetProperty("FQ5_FILORI" , MVC_VIEW_ORDEM, '002')
	oStrGrid:SetProperty("FQ5_SOT"    , MVC_VIEW_ORDEM, '003')
	oStrGrid:SetProperty("FQ5_OBRA"   , MVC_VIEW_ORDEM, '004')
	oStrGrid:SetProperty("FQ5_AS"     , MVC_VIEW_ORDEM, '005')
	oStrGrid:SetProperty("FQ5_VIAGEM" , MVC_VIEW_ORDEM, '006')
	oStrGrid:SetProperty("FQ5_DATGER" , MVC_VIEW_ORDEM, '008')
	oStrGrid:SetProperty("FQ5_HORGER" , MVC_VIEW_ORDEM, '009')
	oStrGrid:SetProperty("FQ5_XPROD"  , MVC_VIEW_ORDEM, '010')
	oStrGrid:SetProperty("B1_DESC"    , MVC_VIEW_ORDEM, '011')
	oStrGrid:SetProperty("FQ5_XQTD"   , MVC_VIEW_ORDEM, '012')
	oStrGrid:SetProperty("QTDNEW"     , MVC_VIEW_ORDEM, '013')
	oStrGrid:SetProperty("FQ5_QTD2"   , MVC_VIEW_ORDEM, '014')
	oStrGrid:SetProperty("FQ5_PESLIQ" , MVC_VIEW_ORDEM, "015")
	oStrGrid:SetProperty("FQ5_PESBRU" , MVC_VIEW_ORDEM, "016")
	oStrGrid:SetProperty("FQ5_M3" , MVC_VIEW_ORDEM, "017")
	oStrGrid:SetProperty("FPA_LOCAL"  , MVC_VIEW_ORDEM, '018')
	oStrGrid:SetProperty("FQ5_GUINDA" , MVC_VIEW_ORDEM, '019')
	oStrGrid:SetProperty("FPA_DESGRU" , MVC_VIEW_ORDEM, '020')
	oStrGrid:SetProperty("FQ5_DTINI"  , MVC_VIEW_ORDEM, '021')
	oStrGrid:SetProperty("FQ5_DTFIM"  , MVC_VIEW_ORDEM, '022')
	oStrGrid:RemoveField("FQ5_STATUS")

// Carrega o Modelo
//oModel  := FWLoadModel( "LOCA259B")
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
	oView:SetViewProperty("GRID","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| Loca259bLg(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})/////////////////////
	oView:CreateVerticalBox( 'TELA2', 100,'GRID' )
//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'CABEC', 0, "TELA2" )
	oView:CreateHorizontalBox( 'DADOS', 100, "TELA2" )

	oView:CreateFolder( 'FOLDER', 'DADOS')
	oView:AddSheet('FOLDER','SHEET1',STR0030) //'A.S. Disponiveis'
	oView:CreateHorizontalBox( 'GRID2', 70, , , 'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox( 'FOOT', 30 , , , 'FOLDER', 'SHEET1')

	oView:AddSheet('FOLDER','SHEET2',STR0031, {|| Loca259bRS()}) //'Resumo'
	oView:CreateHorizontalBox( 'RESUMO', 100, , , 'FOLDER', 'SHEET2')

	oView:SetOwnerView('VIEW_CAB' , 'CABEC' )
	oView:SetOwnerView('GRID', 'GRID2')
	oView:SetOwnerView('VIEW_CALC', 'FOOT')
	oView:SetOwnerView('VIEW_RESUMO', 'RESUMO')

	oView:SetDescription( STR0032 ) //"Itens Disponiveis"


//Adcionar os botões especificos
	oView:AddUserButton(STR0034,"OK",{|| LOCA259BPR() },STR0033,,,.T.)//
	oView:AddUserButton(STR0036,"ENVELOPE",{|| Loca259Rej(oView)},STR0035,,,.T.)//
	oView:AddUserButton(STR0038,"OK",{|| if( Loca259BVG(), LOCA259DNW(),) },STR0037,,,.T.)//
	oView:AddUserButton(STR0040,"OK",{|| if( Loca259BVG(FQT->FQT_PROJET, FQT->FQT_OBRA), LOCA259DAE(),) },STR0039,,,.T.)//
	oView:EnableControlBar(.T.)

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA259BCL()
                                   
Gera o dado fake para ter informação na FIELD pois não se pode ter uma grid em pai
@type function
@example 	LOCA259BCL(oView)
@param		object, Instância da Classe FwFormView
@return     Array, Comtem a carga inicial da tabela fake
@author     Alexandre Circenis
@since      01/02/2025
@version    12
//------------------------------------------------------------------------------
Static Function LOCA259BCL(oSubModel)

	Local aReg  := {}

//MASTER
	aReg := {{"FAKE"},0}

Return(aReg)
/*/
/*/{Protheus.doc} Loca259BFl
Define a lista de campos usado pelo MODEL e VIEW
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Bloco de codigo com os campos usado pelo model e view
/*/
Static Function Loca259BFl()
	bCampos := {|cCampo| cCampo $ "FQ5_FILORI FQ5_AS     FQ5_VIAGEM FQ5_DATGER FQ5_HORGER FQ5_XPROD   FQ5_XQTD  FQ5_GUINDA FQ5_DTINI  FQ5_DTFIM  FQ5_QTD2   FQ5_SOT    FQ5_OBRA   FQ5_STATUS FQ5_PESLIQ  FQ5_PESBRU  FQ5_M3      " }

Return bCampos

/*/{Protheus.doc} Loca259LdG
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function Loca259LdG( oMdl)

	Local aArea      := GetArea()
	Local cAliasT    := GetNextAlias()
	Local aDados     := {}
	Local aStruQry   := {}
	Local nLinha     := 0
	Local cQuery 	:= ''
	Local cTmp		:= ''
	Local aParam    := {}

	cTmp := GetNextAlias()
	
	cQuery += "SELECT FQ5.*,FPA.FPA_LOCAL, FPA.FPA_DESGRU, SB1.B1_DESC, 'F' MARK
	
	cQuery += " FROM " + RetSqlName("FQ5") + " FQ5 "  					//-- Cadastro de Viagem

	cQuery += " INNER JOIN  " +	RetSqlName("FPA") + " FPA "  					//-- AgendametosS Itens
	cQuery += " ON  FPA.FPA_FILIAL  =  '" + xFilial("FPA") + "' "
	cQuery += " AND	FPA.FPA_AS = FQ5.FQ5_AS"
	cQuery += " AND	FPA.FPA_TIPOSE = 'L'"
	cQuery += " AND	FPA.FPA_NFREM = ''"

	cQuery += " AND	FPA.D_E_L_E_T_  =  ' ' "

	cQuery += " INNER JOIN  " +	RetSqlName("SB1") + " SB1 "  					//-- AgendametosS Itens
	cQuery += " ON  SB1.B1_FILIAL  =  '" + xFilial("SB1") + "' "
	cQuery += " AND	SB1.B1_COD = FQ5_XPROD"
	cQuery += " AND	SB1.D_E_L_E_T_  =  ' ' "

	cQuery += " LEFT JOIN  " +	RetSqlName("ST9") + " ST9 "  					//-- Solicitantes
	cQuery += " ON  ST9.T9_FILIAL  =  '" + xFilial("ST9") + "' "
	cQuery += " AND ST9.T9_CODBEM  =  FQ5.FQ5_GUINDA "
	cQuery += " AND ST9.D_E_L_E_T_  =  ' ' "

	cQuery += " WHERE FQ5.FQ5_FILIAL = '" + xFilial("FQ5") + "' "

	cQuery += " AND  FQ5_DEMAND = '      '" // AS não ligada a uma demanda
	cQuery += " AND  FQ5_TPAS = 'L'" // AS do tipo Locação
	cQuery += " AND  FQ5_STATUS <> '9'" // AS Não Rejeitada

	cQuery += " AND  FQ5_SOT >= ? "
	cQuery += " AND  FQ5_SOT <= ? "
	aadd( aParam, aRet[01] )
	aadd( aParam, aRet[02] )
	cQuery += " AND  FQ5_OBRA >= ? "
	cQuery += " AND  FQ5_OBRA <= ? "
	aadd( aParam, aRet[03] )
	aadd( aParam, aRet[04] )
	cQuery += " AND  FQ5_XPROD >= ? "
	cQuery += " AND  FQ5_XPROD <= ? "
	aadd( aParam, aRet[05] )
	aadd( aParam, aRet[06] )
	cQuery += " AND  FQ5_DATGER >= ? "
	cQuery += " AND  FQ5_DATGER <= ? "
	aadd( aParam, Dtos(aRet[07]) )
	aadd( aParam, Dtos(aRet[08]) )
	cQuery += " AND  FQ5_DATINI >= ? "
	cQuery += " AND  FQ5_DATINI <= ? "
	aadd( aParam, Dtos(aRet[09]) )
	aadd( aParam, Dtos(aRet[10]) )
	cQuery += " AND  FQ5_CODCLI >= ? "
	cQuery += " AND  FQ5_CODCLI <= ? "
	aadd( aParam, aRet[11] )
	aadd( aParam, aRet[13] )
	cQuery += " AND  FQ5_LOJA >= ? "
	cQuery += " AND  FQ5_LOJA <= ? "
	aadd( aParam, aRet[12] )
	aadd( aParam, aRet[14] )
	cQuery += " AND  FQ5_GUINDA >= ? "
	cQuery += " AND  FQ5_GUINDA <= ? "
	aadd( aParam, aRet[15] )
	aadd( aParam, aRet[16] )
	cQuery += " AND  FQ5.D_E_L_E_T_  =  ' ' "

	cQuery += " AND NOT EXISTS ( " // AS Está num Romaneio
	cQuery += " SELECT  FQ3_AS "
	cQuery += " FROM " + RetSqlName("FQ3") +" FQ3 "
	cQuery += " WHERE FQ3_FILIAL = '"+xFilial("FQ3")+"'"
	cQuery += " AND FQ3_AS = FQ5.FQ5_AS "
	cQuery += " AND FQ3.D_E_L_E_T_ = ' ')"

	cQuery += " AND NOT EXISTS ( " // AS Está num Pedido
	cQuery += " SELECT  FPZ_AS "
	cQuery += " FROM " + RetSqlName("FPZ") +" FPZ "
	cQuery += " WHERE FPZ_FILIAL = '"+xFilial("FPZ") +"'"
	cQuery += " AND FPZ_AS = FQ5.FQ5_AS "
	cQuery += " AND FPZ.D_E_L_E_T_ = ' ')"
	cQuery += " ORDER BY FQ5_SOT, FQ5_OBRA, FQ5_AS"

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
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FQ5' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )

/*/{Protheus.doc} Loca259Rej
Realiza a rejeição das A.S. marcadas 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@param oView, object, VIEW de processamento
@return variant, return_description
/*/
Function Loca259Rej(oView)
Local aArea := GetArea()
Local AAREADTQ := FQ5->(GetArea())
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("GRID")
Local nI
Local nCount := 0

if MsgNoYes(STR0066) //"Confirma a rejeição das A.S. marcadas ?"

	FOR nI := 1 TO oGrid:Length()

		oGrid:GoLine(nI)

		IF FwFldGet("MARK") .and. FwFldGet("FQ5_STATUS") <> '6'
			// SELECIONADO e não Aceito
			FQ5->(DBGOTO( oGrid:GetDataId() ))					// RECNO
			if Loca259XCN()
				nCount++
			endif
		endif

	NEXT NI

endif

FQ5->(RESTAREA(AAREADTQ))
RestArea(aArea)
oModel:lModify := .F. // Indica que o model não foi alterado poderá ser fechado
//oView:ButtonCancelAction()

oModel:Deactivate()
oModel:Activate()

oview:Refresh()
oview:Refresh("VIEW_GRID")

IF nCount > 0
	AVISO(STR0069,STR0068+ALLTRIM(STR(NCOUNT))+STR0067,{"OK"})  //" A.S."
ENDIF

RETURN .F.

/*/{Protheus.doc} LOCA259BVQ
Valida a nova quantidade (QTDNEW)
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Retorna se a nova quantidade é valida ou não 
/*/
FUNCTION LOCA259BVQ(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	LOcal oGrid  := oModel:GetModel(cGrid)

	if M->QTDNEW > oGrid:GetValue("FQ5_XQTD")
		oModel:SetErrorMessage("","","","","LOCA2591_01",STR0044,) //"A nova quantidade não pode ser maior que a quantidade original."
		lRet := .F.
	elseif  M->QTDNEW <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02",STR0045,) //"A nova quantidade não pode ser menor que zero."
		lRet := .F.
	elseif POSICIONE("FQ5",1,XFILIAL("FQ5")+oGrid:GetValue("FQ5_VIAGEM"),"FQ5_STATUS") <> '1'
		oModel:SetErrorMessage("","","","","LOCA2591_03",STR0046,) //"Só AS não aceitas podem ser fracionadas."
		lRet := .F.
	endif

	if lRet
		// Ajustar os demais campos
		Loca259BGA(0, cGrid)
	endif
Return lRet

/*/{Protheus.doc} LOCA259BV2
Valida a quantidade na segunda unidade 
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Retorna se a quantidade na segunda unidade é valida ou não
/*/
FUNCTION LOCA259BV2(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	Local oGrid  := oModel:GetModel(cGrid)

	if ConvUm( oGrid:GetValue("FQ5_XPROD"), oGrid:GetValue("QTDNEW"),M->FQ5_QTD2, 1 ) > oGrid:GetValue("FQ5_XQTD")
		oModel:SetErrorMessage("","","","","LOCA2591_01",STR0044,) //"A nova quantidade não pode ser maior que a quantidade original."
		lRet := .F.
	elseif  M->FQ5_QTD2 <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02",STR0045,) //"A nova quantidade não pode ser menor que zero."
		lRet := .F.
	elseif !Loca259BAS(oModel, cGrid)
		lRet := .F.
	endif

	if lRet
		oGrid:SetValue("QTDNEW", ConvUm( oGrid:GetValue("FQ5_XPROD"), oGrid:GetValue("QTDNEW"),M->FQ5_QTD2, 1 ) )
		// Ajustar os demais campos
		Loca259BGA(1, cGrid)
	endif

Return lRet

/*/{Protheus.doc} LOCA259BVL
Valida o novo valor do Peso liquido
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Retorna o novo valor do peso liquido
/*/
FUNCTION LOCA259BVL(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	Local oGrid  := oModel:GetModel(cGrid)

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FQ5_XPROD")))
	
	if M->FQ5_PESLIQ > SB1->B1_PESO * oGrid:GetValue("FQ5_XQTD")
		oModel:SetErrorMessage("","","","","LOCA2591_01",STR0047,) //"O novo peso liquido não pode ser maior que o peso original."
		lRet := .F.
	elseif M->FQ5_PESLIQ <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02",STR0048,) //"O novo peso liquido não pode ser menor que zero."
		lRet := .F.
	elseif !Loca259BAS(oModel, cGrid)
		lRet := .F.
	endif

	if lRet
		oGrid:SetValue("QTDNEW", M->FQ5_PESLIQ / SB1->B1_PESO  )
		// Ajustar os demais campos
		Loca259BGA(2, cGrid)
	endif
	
Return lRet
/*/{Protheus.doc} LOCA259BVB
Valida o novo valor do Peso Bruto
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Valida se o novo valor do peso bruto for valido
/*/
FUNCTION LOCA259BVB(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	LOcal oGrid  :=  oModel:GetModel(cGrid)

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FQ5_XPROD")))
	
	if M->FQ5_PESBRU > SB1->B1_PESBRU  * oGrid:GetValue("FQ5_XQTD")
		oModel:SetErrorMessage("","","","","LOCA2591_01",STR0049,) //"O novo peso bruto não pode ser maior que o peso original."
		lRet := .F.
	elseif M->FQ5_PESBRU <= 0
		oModel:SetErrorMessage("","","","","LOCA2591_02",STR0050,) //"O novo peso bruto não pode ser menor que zero."
		lRet := .F.
	elseif !Loca259BAS(oModel, cGrid)
		lRet := .F.
	endif

	if lRet
		oGrid:SetValue("QTDNEW", M->FQ5_PESBRU / SB1->B1_PESBRU )
		// Ajustar os demais campos
		Loca259BGA(3,cGrid)
	endif
	
Return lRet
/*/{Protheus.doc} LOCA259BVM
Valida o novo valor do Metro cubico
@type function
@version 24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, Indica que o novo valor do Metro Cubico é valido
/*/
FUNCTION LOCA259BVM(cGrid)
	Local lRet := .T.
	Local oModel :=  FwModelActive()
	Local oGrid  := oModel:GetModel(cGrid)
	Local nM3 := 0

	SB5->(dbSetOrder(1))
	if SB5->(dbSeek(xFilial("SB1")+oGrid:GetValue("FQ5_XPROD")))
		nM3 := SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC 

		if M->FQ5_M3 > nM3  * oGrid:GetValue("FQ5_XQTD")
			oModel:SetErrorMessage("","","","","LOCA2591_01",STR0051,) //"O volume não pode ser maior que o volume original."
			lRet := .F.
		elseif M->FQ5_M3 <= 0
			oModel:SetErrorMessage("","","","","LOCA2591_02",STR0052,) //"O novo volume não pode ser menor que zero."
			lRet := .F.
		elseif !Loca259BAS(oModel, cGrid)
			lRet := .F.
		endif

		if lRet
			oGrid:SetValue("QTDNEW",  M->FQ5_M3 / (SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC) )
			// Ajustar os demais campos
			Loca259BGA(4, cGrid)
		endif
	endif


Return lRet
/*/{Protheus.doc} LOCA259BCHK
Processa a marcação de um item da Grid 
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@return variant, returna .T.
/*/
FUNCTION LOCA259BCHK()
	Local oModel := FwModelActive()
	Local oGrid  := oModel:GetModel("GRID")


	if FwFldGet("MARK")

		// Gatilhar os campos calculados 
		if Empty(FwFldGet("QTDNEW"))

			oGrid:LoadValue( "QTDNEW", FWFldGet("FQ5_XQTD"))
			Loca259BGA(0,"GRID") // Atualizar todos os campos ajustaveis

		endif

	ELSE

		oGrid:LoadValue( "QTDNEW", 0 )
		Loca259BGA(0, "GRID") // Atualizar todos os campos ajustaveis

	ENDIF

Return .T.

/*/{Protheus.doc} Loca259bLg
Apresenta a Legenda das A.S.
@type function
@version  24.10
@author Alexandre Circenis
@since 2/27/2025
@param oFormulario, object, Model
@param cFieldName, character, Noem do campo que foi dada o duplo clique
@param nLineGrid, numeric, Linha da Grid
@param nLineModel, numeric, Linha do Model
@param oView, object, O View
@return variant, return .T.
/*/
Function Loca259bLg(oFormulario,cFieldName,nLineGrid,nLineModel,oView)
	Local oLegend

	if cFieldName = "LEGEND"
		// Cria a legenda que identifica a estrutura
		oLegend := FWLegend():New()

		// Adiciona descrição para cada legenda
		oLegend:Add( { || }, 'BR_VERDE'   , STR0053 ) // 'Em Aberto'
		oLegend:Add( { || }, 'BR_VERMELHO' , STR0054 ) // 'Baixado'
		oLegend:Add( { || }, 'BR_LARANJA' , STR0055 ) // 'Baixado'

		// Ativa a Legenda
		oLegend:Activate()

		// Exibe a Tela de Legendas
		oLegend:View()
	endif

Return .T.
/*/{Protheus.doc} LOCA259BPR
Processa o Fracionamento das A.S. marcadas
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025

/*/
FUNCTION LOCA259BPR()
Local cTitulo := STR0056 //'Fracionamento de A.S.'
Local cMsg := STR0057 //'Fracionando as A.S.'
Local lAborta := .F.

Processa( {|| Loca259BGE()}, cTitulo, cMsg, lAborta )
Return

/*/{Protheus.doc} Loca259BGE
Processamento do Fracionamento
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function Loca259BGE()
	Local oModel := FwModelActive()
	Local oGrid  := oModel:GetModel("GRID")
	Local aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
	Local oView := FWViewActive()
	Local nX
	Local cMsg    := ""
	Local aASFrac := {}

	//Passa em todos os itens, verifica se foi alterado para um quantidade menor,
	//caso sim, diminui a quantidade e gera uma nova
	For nX := 1 To Len(aAlteradas)
		IncProc()
		oGrid:Goline(aAlteradas[nX])
		//No registro atual da FPA - reduz a quantidade atual, conforme a quantidade passada
		If FwFldGet("MARK") .and. FWFldGet("QTDNEW") > 0 .and. FWFldGet("QTDNEW") <> FWFldGet("FQ5_XQTD") 

			if IsInCallStack("Loca259BVG")
				Aadd( aASFrac, FWFldGet("FQ5_AS"))
			endif  
			FQ5->(dbGoTo(oGrid:GetDataID()))  //Posiciona no registro atual da FPA para diminuir a quantidade
			cMsg += Loca259BFR(FQ5->(Recno()), oGrid)+ CRLF

		EndIf
	Next

	oModel:lModify := .F.
	oModel:Deactivate()
	oModel:Activate()
	if !Empty(aASFrac) 
		oGrid  := oModel:GetModel("GRID")
		for nX := 1 to Len(aASFrac)
			oGrid:SeekLine({{"FQ5_AS", aASFrac[nX]}})
			oGrid:SetValue("MARK",  .T.)
		next
	endif
	oview:Refresh()

if !Empty(cMsg)
	Aviso(STR0060,cMsg,{"Ok"}) //"Novas AS geradas"
endif

Return

/*/{Protheus.doc} Loca259BFR
Faz o fracionamento da A.S.
@type function
@version  25.10
@author Alexandre Circenis
@since 4/22/2025
@param nRecFQ5, numeric, NUmro do registro da FQ5 que será fracionada
@param oGrid, object, Grid que está sendo processado
@param lRomaneio, Logic, Indca se a chamada veio da rotina de romaneio
@return variant, MEnsagems com o sucesso ou erro no fracionamento
/*/
Function Loca259BFR( nRecFQ5, oGrid, lRomaneio)
Local aFldFPA := FPA->(dbStruct())
Local aFldFQ5 := FQ5->(dbStruct())
Local _nGrava
Local cFldFPA := "FPA_NFREM/FPA_DNFREM/FPA_NFENT/FPA_DNFENT/FPA_PEDIDO/FPA_FILREM/FPA_SEREM/FPA_ITEREM" //SUPERGETMV("MV_LCNFP59",.F.,"FPA_NFREM/FPA_DNFREM/FPA_NFENT/FPA_DNFENT/FPA_PEDIDO/FPA_FILREM/FPA_SEREM/FPA_ITEREM") //Não replica os campos da tabela FPA
Local cFldFQ5 := ""
Local aNewFQ5 := {}
Local aNewFPA := {}
Local _cQuery := ""
Local cMsg := ""
Local aArea := GetArea()
 

DEFAULT lRomaneio := .F. 

FPA->(dbSetorder(3))
if FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_AS))
	If Empty(FQ5->FQ5_GUINDA)
		BEGIN TRANSACTION
			aNewFPA := {}

			//Verifica se a quantidade informada é diferente para gerar um novo registro na FPA
			// Só usada no momento da Remessa parcial no retorno será abatida da quantidade
			If ( FWFldGet("QTDNEW") != FPA->FPA_QUANT )
				aBindParam := {}
				_CQUERY := " SELECT MAX(FPA_SEQGRU) AS MAXFPA FROM "+RetSqlName("FPA")+ " WHERE D_E_L_E_T_ = ' ' "
				//Clona as informações para gravar novo registro da FPA
				For _nGrava := 1 To Len(aFldFPA)
					If ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_QUANT" )
						aadd(aNewFPA , {aFldFPA[_nGrava][01], nQtdFPA := FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))-FWFldGet("QTDNEW")})
					Else

						aadd(aNewFPA , {aFldFPA[_nGrava][01], FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))})
					If ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_PRCUNI" )
						nPrcFPA := aNewFPA[Len(aNewFPA)][02]
					ElseIf ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_PDESC" )
						nDesFPA := aNewFPA[Len(aNewFPA)][02]
					ElseIf ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_ACRESC" )
						nAcrFPA := aNewFPA[Len(aNewFPA)][02]
					ElseIf ( AllTrim(aFldFPA[_nGrava][01]) == "FPA_PACRES" )
						nPAcFPA := aNewFPA[Len(aNewFPA)][02]
					EndIf

					Do Case
						Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_FILIAL"
							cFilFPA := FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))
							_CQUERY += " AND FPA_FILIAL = ? "
							aadd(aBindParam, cFilFPA)
						Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_PROJET"
							cPrjFPA := FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))
							_CQUERY += " AND FPA_PROJET = ? "
							aadd(aBindParam, cPrjFPA)
						Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_OBRA"
							cObrFPA := FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))
							_CQUERY += " AND FPA_OBRA = ? "
							aadd(aBindParam, cObrFPA)
						Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_SEQGRU"
							cSeqFPA := FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))
						Case AllTrim(aFldFPA[_nGrava][01]) == "FPA_TIPOSE"
							cTipFPA := FPA->(FieldGet( FieldPos(aFldFPA[_nGrava][01])))
						EndCase
					EndIf
				Next
				_CQUERY := ChangeQuery(_CQUERY)

				MPSysOpenQuery(_CQUERY,"FPAMAX",,,aBindParam)

				If FPAMAX->(!Eof())
					cMaxFPA := FPAMAX->MAXFPA
				EndIf

				FPAMAX->(dbCloseArea())

				RecLock("FPA", .F.)
				FPA->FPA_QUANT := FWFldGet("QTDNEW")
				FPA->FPA_VLBRUT := FWFldGet("QTDNEW")*FPA->FPA_PRCUNI
				If FPA->(FieldPos("FPA_PACRES")) > 0
					FPA->FPA_ACRESC := FPA->FPA_VLBRUT * FPA->FPA_PACRES
				EndIf
				FPA->FPA_VRHOR := (((FPA->FPA_PRCUNI * FWFldGet("QTDNEW") -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
				FPA->(MsUnlock())

				// Se vier do Romaneio ataulizar a linha do romaneio 
				if lRomaneio
					FQV->(dbSetorder(2))
					if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
						RecLock("FQV", .F.)
						FQV->FQV_QTD:= FWFldGet("QTDNEW")
						FQV->(MsUnlock())
					endif
				endif	
				//Gerar novo número de AS
				Do Case
					
					Case cTipFPA $ "L;S" .or. nForca == 2
						cSegFPA := "30" // "04"
				EndCase

				//GERANUMAS("31", CPROJETO, FQ7->FQ7_OBRA, FQ7->FQ7_SEQGUI, FQ7->FQ7_FILIAL)
				cNasFPA := GERANUMAS( cSegFPA, cPrjFPA, cObrFPA, cSeqFPA, cFilFPA )

				//Substituir os totais
				_nGrava := aScan( aNewFPA, { |x| AllTrim(x[01]) == "FPA_VLBRUT" } )
				If (_nGrava > 0)
					//FPA_VLBRUT := M->FPA_QUANT*M->FPA_PRCUNI
					nBrtFPA := nQtdFPA*nPrcFPA
					aNewFPA[_nGrava][02] := nBrtFPA
				EndIf

				_nGrava := aScan( aNewFPA, { |x| AllTrim(x[01]) == "FPA_VRHOR" } )
				If (_nGrava > 0)
					//FPA_VRHOR := (((M->FPA_PRCUNI * M->FPA_QUANT -(M->FPA_VLBRUT*(M->FPA_PDESC/100))) + (M->FPA_ACRESC)))
					If nPAcFPA > 0
						nAcrFPA := (nBrtFPA * nPAcFPA)
						_nGrAcr := aScan( aNewFPA, { |x| AllTrim(x[01]) == "FPA_ACRESC" } )
						aNewFPA[_nGrAcr][02] := nAcrFPA
					EndIf
					nVrhFPA := (((nPrcFPA * nQtdFPA -(nBrtFPA*(nDesFPA/100))) + (nAcrFPA)))
					aNewFPA[_nGrava][02] := nVrhFPA
				EndIf

				//Gerar novo registro da FPA - com a quantidade atualizada
				RecLock("FPA", .T.)
				For _nGrava := 1 To Len(aNewFPA)
					If ( AllTrim(aNewFPA[_nGrava][01]) == "FPA_FILIAL" ) .or.;
							( AllTrim(aNewFPA[_nGrava][01]) == "FPA_PROJET" ) .or.;
							( AllTrim(aNewFPA[_nGrava][01]) == "FPA_OBRA" ) .or.;
							( AllTrim(aNewFPA[_nGrava][01]) == "FPA_TIPOSE" )
						FPA->(FieldPut( FieldPos(aNewFPA[_nGrava][01]), aNewFPA[_nGrava][02]))
					ElseIf ( AllTrim(aNewFPA[_nGrava][01]) == "FPA_SEQGRU" )
						FPA->FPA_SEQGRU := Soma1(cMaxFPA)
					ElseIf ( AllTrim(aNewFPA[_nGrava][01]) == "FPA_AS" )
						FPA->(FieldPut( FieldPos(aNewFPA[_nGrava][01]) , cNasFPA))
					Else
						If !( aNewFPA[_nGrava][01] $ cFldFPA )
							FPA->(FieldPut( FieldPos(aNewFPA[_nGrava][01]), aNewFPA[_nGrava][02]))
						EndIf
					EndIf
				Next
				FPA->(MsUnlock())

				nRecFPA := FPA->(Recno())

				//Gera o registro FQ5 - pendente de aprovação
				//Clona as informações para gravar novo registro da FQ5
				FQ5->(dbGoTo(nRecFQ5))

				//Atualiza a quantidade da FQ5 - FQ5 atual - envio de itens parciais
				RecLock("FQ5", .F.)
				FQ5->FQ5_XQTD := FWFldGet("QTDNEW")
				FQ5->FQ5_QTD2 := ConvUm( oGrid:GetValue("FQ5_XPROD"), oGrid:GetValue("QTDNEW"),0, 2 )
				FQ5->FQ5_PESLIQ := SB1->B1_PESO * oGrid:GetValue("QTDNEW")
				FQ5->FQ5_PESBRU := SB1->B1_PESBRU * oGrid:GetValue("QTDNEW")
				FQ5->FQ5_M3     := SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC * oGrid:GetValue("QTDNEW")
				FQ5->(MsUnlock())
				aNewFQ5 := {}
				
				For _nGrava := 1 To Len(aFldFQ5)
					If ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_FILIAL" ) .or.;
							( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_FILORI" ) .or.;
							( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_SOT" ) .or.;
							( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_GUIND" ) .or.;
							( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_XPROD" ) .or.;
							( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_OBRA" )
						aadd(aNewFQ5 , {aFldFQ5[_nGrava][01], FQ5->(FieldGet( FieldPos(aFldFQ5[_nGrava][01])))})
					ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_VIAGEM" )
						While .T.
							CVIAGEM := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
							CONFIRMSX8()
							FQ5->(dbSetOrder(1))
							If !FQ5->(dbSeek(xFilial("FQ5")+CVIAGEM))
								Exit
							EndIF
						enddo
						FQ5->(dbGoTo(nRecFQ5)) // Voltar ao registro base
						aadd(aNewFQ5 , {aFldFQ5[_nGrava][01], cViaFQ5 := cViagem})
					ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_STATUS" )
						aadd(aNewFQ5 , {aFldFQ5[_nGrava][01], '1' }) //pendente de aprovação
					ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_AS" )
						aadd(aNewFQ5 , {aFldFQ5[_nGrava][01], cNasFPA})
					ElseIf ( AllTrim(aFldFQ5[_nGrava][01]) == "FQ5_XQTD" ) //gera a FQ5 com os itens restantes
						aadd(aNewFQ5 , {aFldFQ5[_nGrava][01], nQtdFPA})
					Else
						If !( aFldFQ5[_nGrava][01] $ cFldFQ5 )
							aadd(aNewFQ5 , {aFldFQ5[_nGrava][01], FQ5->(FieldGet( FieldPos(aFldFQ5[_nGrava][01])))})
						EndIf
					EndIf
				Next

				//Gerar novo registro da FQ5 - nova viagem para o novo FPA
				RecLock("FQ5", .T.)
				For _nGrava := 1 To Len(aNewFQ5)
					FQ5->(FieldPut( FieldPos(aNewFQ5[_nGrava][01]), aNewFQ5[_nGrava][02]))
				Next

				// Gravar os Campos conforme as conversões cadastradas
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FQ5_XPROD")))

				SB5->(dbSetOrder(1))
				SB5->(dbSeek(xFilial("SB5")+oGrid:GetValue("FQ5_XPROD")))

				FQ5->FQ5_QTD2 := ConvUm( oGrid:GetValue("FQ5_XPROD"), nQtdFPA,0, 2 )
				FQ5->FQ5_PESLIQ := SB1->B1_PESO * nQtdFPA
				FQ5->FQ5_PESBRU := SB1->B1_PESBRU * nQtdFPA
				FQ5->FQ5_M3 := SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC * nQtdFPA

				FQ5->(MsUnlock())

				//Grava a viagem gerada no FPA
				FPA->(dbGoTo(nRecFPA))
				RecLock("FPA", .F.)
				FPA->FPA_AS := cNasFPA
				FPA->FPA_VIAGEM := cViaFQ5
				FPA->(MsUnlock())

				if lRomaneio
					
					RecLock("FQV", .T.)
					FQV->FQV_FILIAL := xFilial("FQV")
					FQV->FQV_NUM    := FQU->FQU_NUM
					FQV->FQV_ITEM   := Soma1(Loca229CMX(FQU->FQU_NUM))
					FQV->FQV_PROD   := FQ5->FQ5_XPROD
					FQV->FQV_QTD    := FQ5->FQ5_XQTD
					FQV->FQV_CODBEM := FQ5->FQ5_GUINDA
					FQV->FQV_FAMBEM := Posicione("ST9",1,xFilial("ST9")+FQ5->FQ5_GUINDA, "T9_CODFAMI")
					FQV->FQV_AS     := FQ5->FQ5_AS
					FQV->FQV_STATUS := FQ5->FQ5_STATUS
					FQV->(msUnlock())
				endif

				cMsg := STR0059+cNasFPA+STR0058+Alltrim(Str(nQtdFPA, 15,2))+CRLF //" com quantidade "
			EndIf
		END TRANSACTION
	EndIf
EndIf

RestArea(aArea)

return cMsg

/*/{Protheus.doc} Loca259BVG
Valida as A.S. selecionadas antes de serem incuidas numa demanda
@type function
@version  24.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, .T. se as A.S. puder ser incluida na demanda
/*/
Function Loca259BVG(cProj, cObra)
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("GRID")
Local aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
Local nI
Local cProjObra := "" 

if !Empty(cProj) .and. !Empty(cObra)
	cProjObra := cProj+cObra
endif

if !oGrid:SeekLine({{"MARK", .T.}}) // Nenhuma linha alterada ou não hpa linhas selecionadas
	Help(" ",1,"LOCA259B_01",,STR0061,1,0) //"Nenhuma AS selecionda para ser includa na demanda."
	Return .f.
endif



aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)
oGrid:Goline(aAlteradas[1])

for nI := 1 to Len(aAlteradas)
	oGrid:Goline(aAlteradas[nI])
	if FwFldGet("MARK") // LInha Selecionada
		if Empty(cProjObra)
			cProjObra := FwFldGet("FQ5_SOT")+FwFldGet("FQ5_OBRA")
		elseif cProjObra <> FwFldGet("FQ5_SOT")+FwFldGet("FQ5_OBRA")
			if !Empty(cProj) .and. !Empty(cObra)
				Help(" ",1,"LOCA259B_02",,STR0072+Alltrim(cProj)+STR0074+ Alltrim(cObra)+STR0073+FQT->FQT_DEMANDA+".",1,0)  //"Somente A.S. do projeto " //" podem ser incluidas na demanda " //" e obra "
			else
				Help(" ",1,"LOCA259B_02",,STR0062,1,0) //"Somente A.S. do mesmo projeto e obra podem ser incluidas na demanda."
			endif
			Return .f.
		endif
	endif	
Next

// Fazer o Fracionamento antes de vincular
For nI := 1 To Len(aAlteradas)
	oGrid:Goline(aAlteradas[nI])
	// Havendo A.S. com quantidade nova menor que a quantidade original vamos ter que gerar a separação
	If FwFldGet("MARK") .and. FWFldGet("QTDNEW") > 0 .and. FWFldGet("QTDNEW") <> FWFldGet("FQ5_XQTD") 
		LOCA259BPR()
		Exit
	endif
next

Return .T.

/*/{Protheus.doc} Loca259BWH
Libera a edição com campo quando o grupo do produto estiver contido no parametro de grupos ou 
nos grupos definidos pelo camo BM_XACESS
@type function
@version 25.10 
@author Alexandre Circenis
@since 2/27/2025
@return variant, O campo de quantidade pode ser modificado
/*/
Function Loca259BWH()
Local lRet := .T.
Local cGrupoProd := Posicione("SB1",1, xFilial("SB1")+FwFldGet("FQ5_XPROD"),"B1_GRUPO")

if cGrupoLib = NIL .or. Empty(cGrupoLib)

	cGrupoLib := LOCA00189() // Retorno os grupos de acessorios

endif

lRet := cGrupoProd $ alltrim(cGrupoLib)

Return lRet

/*/{Protheus.doc} Loca259BGA
Preenche campos da grid conforme a origem
@type function
@version  24.10
@author Alexandre Circenis
@since 2/27/2025
@param nTipo, numeric, Indica a origem 

/*/
Function Loca259BGA(nTipo, cGrid)
Local aArea := GetArea()
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel(cGrid)

if nTipo <> 1 // Não veio da QTD2 Ajustar
	oGrid:LoadValue( "FQ5_QTD2"  , ConvUm( oGrid:GetValue("FQ5_XPROD"), oGrid:GetValue("QTDNEW"),0, 2 ) )
endif

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1")+oGrid:GetValue("FQ5_XPROD")))
if nTipo <> 2 // Não veio do peso Liquido	
	oGrid:LoadValue( "FQ5_PESLIQ", SB1->B1_PESO * oGrid:GetValue("QTDNEW"))
endif
if nTipo <> 3 // Não veio do peso bruto
	oGrid:LoadValue("FQ5_PESBRU", SB1->B1_PESBRU * oGrid:GetValue("QTDNEW"))
endif
if nTipo <> 4 // Não veio do m3 (Volume)
	SB5->(dbSetOrder(1))
	if SB5->(dbSeek(xFilial("SB5")+oGrid:GetValue("FQ5_XPROD")))
		oGrid:LoadValue( "FQ5_M3"    ,SB5->B5_ALTURLC*SB5->B5_LARGLC*SB5->B5_COMPRLC * oGrid:GetValue("QTDNEW"))
	endif
endif
RestArea(aArea)
Return

/*/{Protheus.doc} Loca259BAS
Valida se uma A.S. pode ser fracionadas.
Só se pode fracionar A.S. ainda não aceitas
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@return variant, .T. se puder fracionar
/*/
Function Loca259BAS(oModel, cGrid)
Local lRet := .T.
Local oGrid := oModel:GetModel(cGrid)

if POSICIONE("FQ5",1,XFILIAL("FQ5")+oGrid:GetValue("FQ5_VIAGEM"),"FQ5_STATUS") <> '1'
	oModel:SetErrorMessage("","","","","LOCA2591_03",STR0046,) //"Só AS não aceitas podem ser fracionadas."
	lRet := .F.
endif

Return lRet

/*/{Protheus.doc} Loca259bRS
REcalcular o Resumo os itens selecionados
@type function
@version 24.10  
@author Alexandre Circenis
@since 2/27/2025
@return variant, return_description
/*/
Function Loca259bRS()
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

	lAchou := oResumo:SeekLine({{"PRODUTO",FWFldGet("FQ5_XPROD")},{"ARMAZEM",FWFldGet("FPA_LOCAL")}})

	if FwFldGet("MARK") // LInha Selecionada
		
		lAchou := oResumo:SeekLine({{"PRODUTO",FWFldGet("FQ5_XPROD")},{"ARMAZEM",FWFldGet("FPA_LOCAL")}})
		 
		if !lAchou
			if Empty(FWFldGet("PRODUTO",1)) // LInha 1 Vazia
				oResumo:GoLine(1)
			else
				oResumo:AddLine()
			endif
			FwFldPut( "PRODUTO", FWFldGet("FQ5_XPROD"))
			FwFldPut( "DESCPRO", FWFldGet("B1_DESC"))
			FwFldPut( "ARMAZEM", FwFldGet("FPA_LOCAL"))
		endif
		FwFldPut( "QTDE", FwFldGet("QTDE")+FwFldGet("QTDNEW"))
		FwFldPut( "QSEGUNID", FwFldGet("QSEGUNID")+FwFldGet("FQ5_QTD2"))
		if FwFldGet("FQ5_STATUS") = '6' // AS Aceita
			FwFldPut( "SEPARADO", FwFldGet("SEPARADO")+FwFldGet("QTDNEW"))
		else
			FwFldPut( "PENDENTE", FwFldGet("PENDENTE")+FwFldGet("QTDNEW"))
		endif
		FwFldPut( "PESLIQ", FwFldGet("PESLIQ")+FwFldGet("FQ5_PESLIQ"))
		FwFldPut( "PESBRU", FwFldGet("PESBRU")+FwFldGet("FQ5_PESBRU"))
		FwFldPut( "M3"    , FwFldGet("M3")+FwFldGet("FQ5_M3"))

	endif

Next

oResumo:GoLine(1)
oview:Refresh( 'VIEW_RESUMO' )

Return

/*/{Protheus.doc} Loca259BCO
Conta o numero de linhas marcadas
@type function
@version 24.10
@author Alexandre Circenis
@since 3/9/2025
@param oModel, object, Modelo de dados
@return variant, Numero de Linhas Marcadas
/*/
FUNCTION Loca259BCO(oGrid)
Local nContar  := 0
Local nLinhas

for nLinhas := 1 to oGrid:Length()

	if oGrid:GetValue("MARK", nLinhas)

		nContar++

	endif

next

return nContar
