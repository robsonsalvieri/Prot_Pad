#Include "loca229c.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "

/*/{Protheus.doc} LOCA229C
Implementa a Inclusão de Itens no Romaneio
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
/*/
Function LOCA229C()
Local aParam := {}
Local oExecView
Local aButtons
Local cDemIni := space(TamSx3("FQ5_DEMANDA")[1])
Local cDemFim := space(TamSx3("FQ5_DEMANDA")[1])
Local lCanSave := .T.

Private  aRet   := {}

If IsInCallStack("LOCA259") // Veio da Demanda
	cDemIni := FQT->FQT_DEMAND
	cDemFim := FQT->FQT_DEMAND
	lCanSave := .F.
elseif FQU->FQU_FCHEMB = '1'
	MsgAlert(STR0018, STR0019) //"Romaneio já teve o embarque fechado não é possivel incluir novos itens!" //"Embarque Fechado"
	REturn .t.
EndIf

// Array a ser passado para ParamBox?
	aadd(aParam, {1, STR0001, cDemIni , "@!", "", "FQTROM", "", 115, .F.})  //"Demanda de"
	aadd(aParam, {1, STR0002, cDemFim , "@!", "", "FQTROM", "", 115, .F.})  //"Demanda até"
	aadd(aParam, {1, STR0003, space(TamSx3("FQ5_XPROD")[1]) , "", "", "SB1", "", 115, .F.}) //STR0003 //"Produto de"
	aadd(aParam, {1, STR0004, Replicate("z",TamSx3("FQ5_XPROD")[1]) , "", "", "Sb1", "", 115, .F.}) //STR0004 //"Produto até"
	aadd(aParam, {1, STR0005, Criavar("FQ5_DATGER", .T.)    , ""  , "", ""   , "", 50, .F.}) //STR0005 //"Data de Geração de"
	aadd(aParam, {1, STR0006, CTod("31/12/2999")    , ""  , "", ""   , "", 50, .F.}) //STR0006 //"Data de Geração até"
	aadd(aParam, {1, STR0007, space(TamSx3("FQ5_GUINDA")[1]), "", "", "ST9", "", 80, .F.}) //STR0007 //"Bem de"
	aadd(aParam, {1, STR0008, Replicate("z",TamSx3("FQ5_GUINDA")[1]), "", "", "ST9", "", 80, .F.}) //STR0008 //"Bem até"
	aAdd(aParam, {2, STR0015,"3",{STR0014, STR0016,STR0017 },60,"",.T.}) //"1=Pendente" //"Status da A.S" //"2=Separadas" //"3=Ambos"
	// Caso confirme a tela de parametros processa a rotina de demanda
	If ParamBox(aParam,STR0009,@aRet, , , , , , , , lCanSave,)  //"Escolha de Itens para romaneio"
		aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.T.,NIL},{.T.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0010) //"A.S."
		oExecView:setSource("LOCA229C")
		oExecView:setOK({|| Loca229COk(FQU->FQU_NUM)})
		oExecView:setModal(.F.)
		oExecView:SetButtons(aButtons)
		oExecView:setOperation(MODEL_OPERATION_UPDATE)
		oExecView:openView(.T.)

	endif

return .T.
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
local oModel    := FWLoadModel("LOCA259B")
//   local oStrCampo as object

//Atribuindo formulários para o modelo
// oModel:AddFields('CABEC', , oStrCampo ,,,{|oSub| LOCA259BCL(oSub) })
oModel:GetModel('GRID'):SetLoad({|oModel| Loca229CLd( oModel )})
    
//Adicionando descrição ao modelo
oModel:SetDescription( 'A.S. em demandas' ) //"A.S. DIPONIVEL"
// Adiciona a descricao do Componente do Modelo de Dados
//  oModel:GetModel( 'CABEC' ):SetDescription( 'MODEL FAKE' )
oModel:GetModel( 'GRID' ):SetDescription( "A.S. em demandas") //"A.S. Disponiveis"
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
	local oModel   := FWLoadModel( 'LOCA229C' )
	local oStrGrid as object
	Local oCalc

// Instancia a Estrutura
//    oStrCabec := FWFormViewStruct():New()
//    oStrCabec:AddField( 'X_ZMVC' , '01' , 'X_ZMVC' , 'X_ZMVC',{},'@!'  )

// Instancia a Estrutura
	oStrGrid := FWFormStruct( 2, "FQ5",  Loca229CFl() )
	oStrGrid:AddField( 'MARK','01',' ',' ',, 'Check')
	oStrGrid:AddField( 'B1_DESC', '02', "Desc", "Descrição do Produto", , "C" ) //"Descrição do Produto"
	oStrGrid:AddField( 'FPA_LOCAL', '03',"Armazem","Local de Armazenagem", , "C" ) //"Local de Armazenagem"
	oStrGrid:AddField( 'FPA_DESGRU', '04', "Desc Equip","Descrição do Equipamento", , "C") //"Descrição do Equipamento"
	oStrGrid:AddField( 'QTDNEW', '05', "Qtde Nova", "Nova Quantidade A.S.",, "N",X3Picture("FQ5_QTD")) //"Qtde Nova"
	oStrGrid:AddField( ;            		// Ord. Tipo Desc.
	'LEGEND'                   	, ;   	// [01]  C   Nome do Campo
	"00"                         	, ;     // [02]  C   Ordem
	AllTrim( ''    )         , ;     // [03]  C   Titulo do campo
	AllTrim( '' )       , ;     // [04]  C   Descricao do campo
	{ 'Legenda' } 		, ;     // [05]  A   Array com Help //'Legenda'
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
	oStrGrid:SetProperty("MARK"       , MVC_VIEW_ORDEM, '001')
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
	oStrGrid:SetProperty("FQ5_M3"     , MVC_VIEW_ORDEM, "017")
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
	oView:AddSheet('FOLDER','SHEET1', "A.S. Disponivieis") //'A.S. Disponiveis'
	oView:CreateHorizontalBox( 'GRID2', 80, , , 'FOLDER', 'SHEET1')
	oView:CreateHorizontalBox( 'FOOT', 20 , , , 'FOLDER', 'SHEET1')
	oView:CreateVerticalBox( 'RODAPE', 80, 'FOOT',, 'FOLDER', 'SHEET1')
	oView:CreateVerticalBox( 'BOTAO', 20, 'FOOT',, 'FOLDER', 'SHEET1')

	oView:AddOtherObject("btnMarcaDesm1", {|oPanel,oView| LOCA259EBT(oPanel, "GRID")})

	oView:AddSheet('FOLDER','SHEET2',"Resumo", {|| Loca259bRS()}) //'Resumo'
	oView:CreateHorizontalBox( 'RESUMO', 100, , , 'FOLDER', 'SHEET2')

	oView:SetOwnerView('VIEW_CAB' , 'CABEC' )
	oView:SetOwnerView('GRID', 'GRID2')
	oView:SetOwnerView('VIEW_CALC', 'RODAPE')
	oView:SetOwnerView('VIEW_RESUMO', 'RESUMO')
	oView:SetOwnerView("btnMarcaDesm1", 'BOTAO')

	oView:SetViewProperty( "VIEW_CALC", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 85} )
	
	oView:SetDescription("Itens das Demandas" ) 


Return oView

Static Function LOCA229CFl()
	bCampos := {|cCampo| cCampo $ "FQ5_FILORI FQ5_AS     FQ5_VIAGEM FQ5_DATGER FQ5_HORGER FQ5_XPROD   FQ5_XQTD  FQ5_GUINDA FQ5_DTINI  FQ5_DTFIM  FQ5_QTD2   FQ5_SOT    FQ5_OBRA   FQ5_STATUS FQ5_PESLIQ  FQ5_PESBRU  FQ5_M3      " }

Return bCampos

/*/{Protheus.doc} LOCA229CLD
Função para gerar a carga do model conforme os parametros de entrada na rotina
@type function
@version 24.10
@author Alexandre Circenis
@since 2/27/2025
@param oMdl, object, model a ser preenchido
@return variant, array com os dados no formato do model
/*/
Static Function Loca229CLd( oMdl)

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

	cQuery += " AND  FQ5_DEMAND >= ?" 
	cQuery += " AND  FQ5_DEMAND <= ?" 
	aadd( aParam, aRet[01] )
	aadd( aParam, aRet[02] )
	cQuery += " AND  FQ5_DEMAND <> ' '" // Demanda deve estar preenchida
	cQuery += " AND  FQ5_TPAS = 'L'" // AS do tipo Locação
	cQuery += " AND  FQ5_SOT = ? "
	aadd( aParam, FQU->FQU_PROJET )
	cQuery += " AND  FQ5_OBRA = ? "
	aadd( aParam, FQU->FQU_OBRA )
	cQuery += " AND  FQ5_XPROD >= ? "
	cQuery += " AND  FQ5_XPROD <= ? "
	aadd( aParam, aRet[03] )
	aadd( aParam, aRet[04] )
	cQuery += " AND  FQ5_DATGER >= ? "
	cQuery += " AND  FQ5_DATGER <= ? "
	aadd( aParam, Dtos(aRet[05]) )
	aadd( aParam, Dtos(aRet[06]) )
	cQuery += " AND  FQ5_GUINDA >= ? "
	cQuery += " AND  FQ5_GUINDA <= ? "
	aadd( aParam, aRet[07] )
	aadd( aParam, aRet[08] )
	cQuery += " AND  FQ5.FQ5_XROMAN =  ' ' "
	if aRet[9] = "1"
		cQuery += " AND  FQ5.FQ5_STATUS =  '1' "
	elseif aRet[9] = "2"
		cQuery += " AND  FQ5.FQ5_STATUS =  '6' "
	endif
	cQuery += " AND  FQ5.D_E_L_E_T_ =  ' ' "

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
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FQ5' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )

/*/{Protheus.doc} Loca229COk
Processa o botão Ok da tela de inclusão de itens no romaneio
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/28/2025
@return variant, Sem retorno
/*/
Function Loca229COk(cRomaneio)
Local oModel:= FWModelActive()
Local oGrid := oModel:GetModel("GRID")
Local aAlteradas := {}
Local nX
Local nIncluidas := 0
Local cTitulo := STR0011 //"A.S. Incluidas Romaneio"
Local cItem   := Loca229CMX(cRomaneio)
Local cStatus := if(FQ5->FQ5_STATUS = '1', '3', FQ5->FQ5_STATUS)

BEGIN TRANSACTION
// Fracionar e/ou incluir itens no romaneio posicionado
aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGrid:Goline(aAlteradas[ nX])

	if oGrid:GetValue('MARK') // Marcado realizar a inclusão no romaneio
	
		FQ5->(dbGoTo(oGrid:GetDataID()))
	
		// Se quantidade separa for diferente da quantidade origem realizar o fracionamento	
		if !Empty(oGrid:GetValue('QTDNEW')) .and. oGrid:GetValue('QTDNEW') <> oGrid:GetValue('FQ5_XQTD')
			// Realizar p Fracionamento da A.S.
			Loca259BFR(FQ5->(Recno()), oGrid)
			// Incrementar o itens da demanda o item
			FQT->(dbSetOrder(1))
			FQT->(dbSeek(xFilial("FQT")+FQ5->FQ5_DEMAND))
			RecLock("FQT", .F.)
			FQT->FQT_ITENS := FQT->FQT_ITENS + 1
			msUnlock()

		endif
		// Volta para a FQ5 marcada
		FQ5->(dbGoTo(oGrid:GetDataID()))
	
		// Incluir o item marcado no Romaneio
		cItem := Soma1(cItem)
		RecLock("FQV", .T.)
		FQV->FQV_FILIAL := xFilial("FQV")
		FQV->FQV_NUM    := cRomaneio
		FQV->FQV_ITEM   := cItem
		FQV->FQV_PROD   := FQ5->FQ5_XPROD
		FQV->FQV_QTD    := FQ5->FQ5_XQTD
		FQV->FQV_CODBEM := FQ5->FQ5_GUINDA
		FQV->FQV_FAMBEM := Posicione("ST9",1,xFilial("ST9")+FQ5->FQ5_GUINDA, "T9_CODFAMI")
		FQV->FQV_AS     := FQ5->FQ5_AS
		FQV->FQV_STATUS := FQ5->FQ5_STATUS
		msUnLock()

		nIncluidas++

		RecLock("FQ5", .F.)
		FQ5->FQ5_XROMAN := cRomaneio
		msUnlock()
	
		if FQ5->FQ5_STATUS 	<> '6' // Não está separado
			cStatus := '2'
		endif
	endif
next

if nIncluidas > 0
	RecLock("FQU", .F.)
	FQU->FQU_STATUS := cStatus
	MsUnlock()
	
	if !IsInCallStack("Loca229AEV") // Não Veio da alteração de Romaneio 
		LOCA229AC() // Analise de capacidade
	endif

endif

END TRANSACTION

if nIncluidas > 0
	Aviso(cTitulo, STR0012+Alltrim(Transform( nIncluidas, "@E 9,999,999"))+;  //"Foram incluidas "
	 STR0013+cRomaneio , {"Ok"})  //" A.S. no romaneio "
endif

RETURN .T.

/*/{Protheus.doc} Loca229CMX
Retorna o maior valor do campo item do romaneio, levando em consideração os deletados, caso não tenha nenhum item
retorna branco para iniciar a numeração
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/28/2025
@param cRomaneio, character, Codigo do Romaneio
@return variant, Maior codigo do item
/*/
Function Loca229CMX(cRomaneio)
Local cMax 
Local cQuery := ""
Local aArea  := GetArea()
Local aBindParam := {}
Local cAliasT    := GetNextAlias()

cQuery := "SELECT Max(FQV_ITEM) ITEM"
cQuery += " FROM "+RetSqlName("FQV")
cQUERY += " WHERE FQV_FILIAL = '"+xFilial("FQV")+"'"
cQuery += " and FQV_NUM = ?"
Aadd(aBindParam, cRomaneio)

cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aBindParam)

cMax := (cAliasT)->ITEM

RestARea(aArea)

RETurn cMax
