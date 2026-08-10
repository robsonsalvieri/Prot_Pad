#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSA260.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MVC
Funcao para abrir a tela de cadastro
@author Totver
@since 26/07/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260MVC(lAutomato,lMostraFamilia,cOperation)
	local cFil260 := ""
	local aCores := {}
	local nX := 0
	local aReferencia := FWGetDialogSize( oMainWnd )
	local oDlg := nil

	local aColumns:={}

	private cCodFor:= ''
	private inclui  := .F.
	private lPrim260 := .F.
	private aCdCores:= {}
	private cFilBA1 := ""
	private aRotina := {}
	private cKeySubCon := BQC->BQC_CODIGO+BQC->BQC_NUMCON+BQC->BQC_VERCON+BQC->BQC_SUBCON+BQC->BQC_VERSUB
	private cAliasTemp := ''
	private cRetGrpFam := "" // Variavel de retorno da consulta padrão PLSGPF
	private cAlias := 'BA3'

	default lAutomato:= .F.
	default lMostraFamilia:= .F.
	Default cOperation := ""

	if !lAutomato
		Define MsDialog oDlg Title 'Grupo Familiar' From aReferencia[1], aReferencia[2] To aReferencia[3], aReferencia[4] Pixel

		oLayer := FWLayer():new()
		oLayer:init(oDlg)

		oLayer:addLine("Lin01", 060, .F. )
		oLayer:addLine("Lin02", 040, .F. )

		oLayer:addCollumn('Col01', 100, .F., "Lin01")
		oLayer:addCollumn('Col02', 100, .F., "Lin02")

		oLayer:addWindow("Col01", "Win01", "Grupos", 50, .T., .F., {||}, "Lin01",{||  }) //"Grupos"
		oLayer:addWindow("Col02", "Win01", "Grupos2", 50, .T., .F., {||}, "Lin02",{|| }) //"Grupos"

		oPnl1 := oLayer:GetColPanel( 'Col01',"Lin01" )
		oPnl2 := oLayer:GetColPanel( 'Col02',"Lin02" )
	endif

	// criando Alias temporário PARA EXIBIÇÃO DA FAMILIA
	cCriaAliasTemp(@cAliasTemp,@aColumns)

	oBrowseBA1 := FWmBrowse():New()
	if !lAutomato
		oBrowseBA1:SetOwner( oPnl2 )
	endif
	oBrowseBA1:SetDescription( "Família" )
	oBrowseBA1:SetDataTable( .T. )
	oBrowseBA1:SetAlias( cAliasTemp )
	oBrowseBA1:SetMenuDef('')
	If !ExistBlock('PL260COR')
		oBrowseBA1:AddLegend("PLLegBloq(@cAliasTemp)=='BR_VERMELHO'", "RED"	 , 'Beneficiario Bloqueado')//"Pendente com a Operadora"
		oBrowseBA1:AddLegend("PLLegBloq(@cAliasTemp)=='BR_VERDE'"   , "GREEN"	 , 'Beneficiario ativo')//"Pendente com a Operadora"
		oBrowseBA1:AddLegend("PLLegBloq(@cAliasTemp)=='BR_AMARELO'" , "YELLOW" , 'Beneficiario com bloqueio futuro')//"Pendente com a Operadora"
		oBrowseBA1:AddLegend("PLLegBloq(@cAliasTemp)=='BR_BRANCO'"  , "WHITE"	 , 'Inclusão futura')//"Pendente com a Operadora"
	else
		For nX:= 1 to Len(aCores)
			oBrowse:AddLegend(aCores[nx,1], aCores[nx,2]	, '')
		Next
	endif
	oBrowseBA1:SetColumns(aColumns)
	oBrowseBA1:DisableFilter()
	oBrowseBA1:DisableSeek()
	oBrowseBA1:SetUseFilter(.F.)
	oBrowseBA1:SetDoubleClick({|| ExecConsltaBenef(@cAliasTemp)})
	If(!lAutomato,oBrowseBA1:Activate(),)


	//Exibição dos beneficiarios relacionandos a empresa
	oBrowse := FWmBrowse():New()
	if !lAutomato
		oBrowse:SetOwner( oPnl1 )
	endif
	aRotina := MenuDef(cOperation)
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDetails(.F.)
	oBrowse:SetDescription( Fundesc() )
	oBrowse:setMainProc("PLSA260MVC")
	oBrowse:SetMenuDef( 'PLSA260MVC' )
	oBrowse:SetChange({|| AtuaBrwBA1(oBrowseBA1,@cAliasTemp)})
	oBrowse:SetDoubleClick({|| AtuaBrwBA1(oBrowseBA1,@cAliasTemp)})

	If lJuridico .and. !lAmbos

		cFil260 := "BA1_FILIAL = '" + xFilial("BA1") + "' AND BA1_CODINT = '"+Left(BQC->BQC_CODIGO,4)+"' AND BA1_CODEMP = '"+Substr(BQC->BQC_CODIGO,5,4)+"' "
		cFil260 += "AND BA1_CONEMP = '"+BQC->BQC_NUMCON+"' AND BA1_VERCON = '"+BQC->BQC_VERCON+"' "
		cFil260 += "AND BA1_CONEMP = '"+BQC->BQC_NUMCON+"' AND BA1_VERCON = '"+BQC->BQC_VERCON+"' "
		cFil260 += "AND BA1_SUBCON = '"+BQC->BQC_SUBCON+"' AND BA1_VERSUB = '"+BQC->BQC_VERSUB+"' "
		iF lMostraFamilia
			cFil260 += "AND BA1_MATRIC = '"+BA1->BA1_MATRIC+"' "
		endIf
		cFil260 += "AND D_E_L_E_T_ = ' '"

		oBrowse:SetDescription(Posicione("BG9",1,xFilial("BG9")+BQC->(BQC_CODIGO),"BG9_DESCRI"))

	Elseif !lJuridico .and. !lAmbos

		cFil260 := "BA1_CODINT = '"+BG9->BG9_CODINT + "' AND BA1_CODEMP = '"+BG9->BG9_CODIGO+"' "
		iF lMostraFamilia
			cFil260 += "AND BA1_MATRIC = '"+BA1->BA1_MATRIC+"' "
		endIf
		cFil260 += "AND D_E_L_E_T_ = ' '"

		oBrowse:SetDescription(BG9->BG9_DESCRI)

	Endif

	cFilBA1:="@"+cFil260


	BA1->(DbSetOrder(1))

	If lAmbos
		BA1->(MsSeek(xFilial("BA1")))
	Else
		oBrowse:SetFilterDefault(cFilBA1)
	EndIF

	Pl260Cores(@aCores,@aCdCores)

	If !ExistBlock('PL260COR')
		oBrowse:AddLegend("PLLegBloq()=='BR_VERMELHO'", "RED"	 , 'Beneficiario Bloqueado')//"Pendente com a Operadora"
		oBrowse:AddLegend("PLLegBloq()=='BR_VERDE'"   , "GREEN"	 , 'Beneficiario ativo')//"Pendente com a Operadora"
		oBrowse:AddLegend("PLLegBloq()=='BR_AMARELO'" , "YELLOW" , 'Beneficiario com bloqueio futuro')//"Pendente com a Operadora"
		oBrowse:AddLegend("PLLegBloq()=='BR_BRANCO'"  , "WHITE"	 , 'Inclusão futura')//"Pendente com a Operadora"
		If(!lAutomato,oBrowse:Activate(),)
	Else
		For nX:= 1 to Len(aCores)
			oBrowse:AddLegend(aCores[nx,1], aCores[nx,2]	, '')
		Next
		oBrowse:Activate()

	Endif


	if !lAutomato
		Activate MsDialog oDlg CENTERED
	endif
Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260MVC
@author  Totver
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function MenuDef(cOperation)
	Local aRotina  	:= {}

	Default cOperation := ""

	If cOperation == cValToChar(MODEL_OPERATION_VIEW)
		aBenefMenu := {{ 'Visualizar', "PLSACHKMENU(1)", 0, 2, 0, NIL }}
	Else
		aBenefMenu := {	{ 'Incluir Titular'	  	,"PLSA260VLMVC(3)"	, 0, 3, 0, NIL },;
		{ 'Incluir Dependente'	,"PLA260VLDEP(3)", 0, 3, 0, NIL },;
		{ 'Visualizar'			,"PLSACHKMENU(1)", 0, 2, 0, NIL },;
		{ 'Alterar'	  			,"PLSACHKMENU(4)", 0, 4, 0, NIL },;
		{ 'Excluir'	 		 	,"FwMsgRun(,{|| PLDelBenMVC()},,'Aguarde, excluindo os dados do beneficiário/família.')", 0, 5, 0, NIL }}
	EndIf

	//Abre BA1 em edição com campos especificos
	aBenefBA1 := {	{ OemtoAnsi('Dados Pessoais'),'PLSA260MENU(9,nil,'+cOperation+')',  0, 4 },;
		{ OemtoAnsi('Relativos ao Plano'),    'PLSA260MENU(10,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Dados da Cobrança'),     'PLSA260MENU(11,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Dados da ANS'),          'PLSA260MENU(12,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Outros Dados'),          'PLSA260MENU(13,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Regras de Parcelamento'),'PLSA260MENU(14,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Outras Informações'),    'PLSA260MENU(15,nil,'+cOperation+')', 0, 4 } }

	//Abre outroas tabelas relacionadas a BA1
	aBenefRel  := {	{ OemtoAnsi('Doenças Pré-Existentes')	   , 'PLSA260MENU(33,nil,'+cOperation+')' , 0 , 2 },;
		{ OemtoAnsi('Documentos Obrigatórios')        		   , 'PLSA260MENU(28,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Opcional do Beneficiario')                , 'PLSA260MENU(18,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Gratuidade do Beneficiario') 	           , 'PLSA260MENU(19,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Cobertura - Grupos Determinados')         , 'PLSA260MENU(24,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Cobertura - Procedimentos')               , 'PLSA260MENU(25,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Cobertura - Grupo de Quantidade')         , 'PLSA260MENU(26,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Cobertura - Classe de Carência')          , 'PLSA260MENU(27,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Faixa Etaria Especifica do Beneficiario') , 'PLSA260MENU(29,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Situações Adversas') 					   , 'PLSA260MENU(34,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Histórico Bloqueio do Usuário') 		   , 'PLSA260MENU(35,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Histórico de Transferência do Beneficiário'),'PLSA260MENU(41,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Cancelamento Reajuste') 				   ,  'PLSA260MENU(42,nil,'+cOperation+')', 0 , 4 }}

	If cOperation != cValToChar(MODEL_OPERATION_VIEW)
		aAdd(aBenefRel, { OemtoAnsi('(Des)Bloqu. &Usu'),'PLBlqUMenu',0,4 })  	 //(Des)Bloqu. &Usu
	EndIf
	
	aAdd(aBenefRel, { OemtoAnsi('Grupo de Rol de Procedimentos'), 'PLSA260MENU(37,nil,'+cOperation+')', 0 , 4 })
	aAdd(aBenefRel, { OemtoAnsi('Histórico dos Opcionais do Beneficiário'), 'PLSA260MENU(40, nil, '+cOperation+')', 0, MODEL_OPERATION_VIEW})

	//Abre BA3 em edição com campos especificos
	aFamBA3 := {	{ OemtoAnsi('Demais Dados Cadastrais'),'PLSA260MENU(8,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Dados do Plano da Familia'),   'PLSA260MENU(5,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Dados da Cobrança da Familia'),'PLSA260MENU(2,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Logs'),                        'PLSA260MENU(4,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Dados da ANS'),                'PLSA260MENU(6,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Dados Comerciais da Familia'), 'PLSA260MENU(3,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Outros Dados'),                'PLSA260MENU(7,nil,'+cOperation+')', 0, 4 }}

	// Abre o historico de parcelamento, Abatimento de Saldo, Transferência de Saldo
	aHistParc := {}

	If cOperation == cValToChar(MODEL_OPERATION_VIEW)
		aHistParc := {  { 'Histórico', 	'PLSA260MENU(36,nil,'+cOperation+')', 0, 4 }}
	Else
		aHistParc := {  { 'Histórico', 	'PLSA260MENU(36,nil,'+cOperation+')', 0, 4 },;
		{ 'Abatimento de Saldo', 	'PL260ABASMVC(.F.)'		, 0, 4 },;
		{ 'Transferência de Saldo', 'PL260SALDMVC(.F.)'		, 0, 4 }}
	EndIf

	//Abre outroas tabelas relacionadas a BA3
	aFamRel := {	{ OemtoAnsi('Forma de Cobrança da Familia') ,'PLSA260MENU(1,nil,'+cOperation+')', 0, 4 },;
		{ OemtoAnsi('Taxa de Adesão')                           ,'PLSA260MENU(16,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Gratuidade') 	         				    ,'PLSA260MENU(17,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Grupo de Cobertura - Cobertura')   	    ,'PLSA260MENU(20,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Grupo de Cobertura - Procedimentos')   	,'PLSA260MENU(21,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Grupo de Cobertura - Grupo de Quantidade')	,'PLSA260MENU(22,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Grupo de Cobertura - Classe de Carência') 	,'PLSA260MENU(23,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Valor de Cobrança') 						,'PLSA260VCB', 0 , 4 },;
		{ OemtoAnsi('Histórico Financeiro') 					,'PLSA260MENU(30,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Histórico Cobrança Carteirinha')			,'PLSA260MENU(31,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Histórico Bloqueio da Família') 			,'PLSA260MENU(32,nil,'+cOperation+')', 0 , 4 },;
		{ OemtoAnsi('Parcelamento') 							, aHistParc, 0 , 2, , .F. }} //(Des)Bloqu. &Fam
	
	If cOperation != cValToChar(MODEL_OPERATION_VIEW)
		aAdd(aFamRel, { OemtoAnsi('(Des)Bloqu. &Fam'),'PLBlqFMenu', 0 , 4  })
	EndIf

	If FindFunction("PLTermConsBenef")
		aAdd(aFamRel, {OemtoAnsi('Termo de Consentimento de Dados Pessoais'), 'PLTermoBenef', 0, 2})
	EndIf

	aAdd(aFamRel, {OemtoAnsi('Opcional da Família'), 'PLSA260MENU(38,nil,'+cOperation+')', 0 , 4 })
	aAdd(aFamRel, {OemtoAnsi('Histórico Opcional'), 'PLSA260MENU(39, nil, '+cOperation+')', 0, MODEL_OPERATION_VIEW})
	aAdd(aFamRel, {OemtoAnsi('Desconto x Parcela'), 'Pls660DES', 0, MODEL_OPERATION_UPDATE})

	aBenef :=	{}
	aBenef := {	{ 'Beneficiários'			, aBenefMenu	, 0, 2			},;
		{ 'Dados Cadastrais do Beneficiario', aBenefBA1 	, 0, 2, , .F.	},;
		{ 'Demais Dados do Beneficiario'    , aBenefRel 	, 0, 2, , .F.	}}

	aFam := {}
	aFam := {{'Dados Cadastrais da Família', aFamBA3, 0, 2,	, .F.},;
		{ 'Demais Dados da Família'    , aFamRel, 0, 2,	, .F.}}

	aBot := {}
	aBot := {	{ OemtoAnsi('Posicao Financeira') , 'PosFinBenef()', 0, 2 },;
		{OemtoAnsi("Interc Hab."), 'VIEWDEF.PLSA272', 0,2 }}  //Intercambio Habitual

	aadd(aRotina,{ 'Familia'    			 , aFam  		, 0 , 0, , .F.} )
	aadd(aRotina,{ 'Outros'					 , aBot 		, 0 , 1, , .F.} )
	aadd(aRotina,{ 'Beneficiario'			 , aBenef		, 0 , 2, , .F.} )

	If ExistBlock("PLS260INC") .And. cOperation != cValToChar(MODEL_OPERATION_VIEW)
		aadd(aRotina,{ OemtoAnsi("Reemissao")	, 'PLSA260REM' , 0 , 4    	}) //"Reemissao"
	Endif

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260MVC
@author  Totver
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Static oModel
	Local aCampBA3:={}
	Local aCampBA1:={}
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CamMenu('BA3',cCampo,'S',@aCampBA3) })
	Local oStruBA1 := FWFormStruct( 1, 'BA1'    , { |cCampo| PLS260CamMenu('BA1',cCampo,'S',@aCampBA1) })
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC","BA1_CONEMP","BA1_VERCON","BA1_SUBCON","BA1_VERSUB"} // Campos a serem adicionado na estrutura
	Local nNx
	Local oEvent   := PLSA260EVDEF():New()
	local oEventBA1 := PLGFBA1Event():new() as object

	//Proteção ao instanciar a classe, sem a variável private lJuridico
	lJuridico := iif( type("lJuridico") <> "L", .f.,  lJuridico)

	oModel := MPFormModel():New('PLSA260MVC')
	inclui := .F.

	oStruBA1:RemoveField( 'BA1_EQUIPE')
	oStruBA1:RemoveField( 'BA1_NOMEQ' )
	oStruBA1:RemoveField( 'BA1_CODVEN')
	oStruBA1:RemoveField( 'BA1_NOMVEN')
	oStruBA1:RemoveField( 'BA1_NOMVE2')
	oStruBA1:RemoveField( 'BA1_CODVE2')
	oStruBA3:RemoveField( 'BA3_NOMEQ' )

	oStruBA3:SetProperty('BA3_CODVEN', MODEL_FIELD_OBRIGAT, .F.)    
	oStruBA3:SetProperty('BA3_EQUIPE', MODEL_FIELD_OBRIGAT, .F.)
	oStruBA3:SetProperty('BA3_COBNIV', MODEL_FIELD_OBRIGAT, .F.)

	If lJuridico
		BG9->(DbSelectArea("BG9"))
		BG9->(DbSeek(xFilial("BG9")+ BQC->BQC_CODIGO))
	Endif

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCampos[nNx])
	Next

	//Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'BA3DETAIL',NIL, oStruBA3 )
	oModel:AddFields( 'BA1MASTER', 'BA3DETAIL', oStruBA1)

	oModel:SetPrimaryKey({})

	//Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( FunDesc() )

	//Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Beneficiario' )
	oModel:GetModel( 'BA3DETAIL' ):SetDescription( 'Familia' )

	/*Inicializadores Padrão*/
	oStruBA1:setProperty( 'BA1_TIPUSU', MODEL_FIELD_INIT, { || P260TipUsu()} )


	//-------------------------REVALIDAR CAMPOS AO SALVAR-----------------------------------------------------------------------------
	oStruBA1:setProperty( 'BA1_CODINT', MODEL_FIELD_INIT,  { || PLSINTPAD()} )
	oStruBA1:setProperty( 'BA1_CODEMP', MODEL_FIELD_INIT,  { || BG9->BG9_CODIGO })
	oStruBA3:setProperty( 'BA3_CODEMP', MODEL_FIELD_INIT,  { || BG9->BG9_CODIGO })
	oStruBA3:setProperty( 'BA3_CODINT', MODEL_FIELD_INIT,  { || PLSINTPAD()})
	oStruBA3:setProperty( 'BA3_VERSAO', MODEL_FIELD_INIT,  { || "001" })
	oStruBA3:setProperty( 'BA3_FORPAG', MODEL_FIELD_INIT,  { || "101" })

	oStruBA3:setProperty('BA3_CODPLA',MODEL_FIELD_VALID, { || PLSABA3MVC(oModel) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_VERSAO',MODEL_FIELD_VALID, { || EXISTCPO("BIL", RetFilPla(oModel),1) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_FORPAG',MODEL_FIELD_VALID, { || PLS260COFZ(.T.,oModel) .And. PLSA260GCMvc(oModel)})
	oStruBA3:setProperty('BA3_FORCTX',MODEL_FIELD_VALID, { || PL260VldAde(oModel:GetValue('BA3DETAIL','BA3_CODINT'),oModel:GetValue('BA3DETAIL','BA3_CODPLA'),oModel:GetValue('BA3DETAIL','BA3_VERSAO'),oModel:GetValue('BA3DETAIL','BA3_FORCTX'))})

	oStruBA1:setProperty( 'BA1_DTVLCR', MODEL_FIELD_INIT, { || PL260VLD()} )
	oStruBA1:setProperty( 'BA1_MATRIC', MODEL_FIELD_INIT, { || "AUTO" } )
	oStruBA1:setProperty( 'BA1_TIPUSU', MODEL_FIELD_INIT, { || GetNewPar("MV_PLCDTIT", "T")} )
	oStruBA1:setProperty( 'BA1_GRAUPA', MODEL_FIELD_INIT, { || GetNewPar("MV_PLCDTGP", "01")} )

	oStruBA1:setProperty( 'BA1_DATINC', MODEL_FIELD_INIT, { || Date()} )
	oStruBA1:setProperty( 'BA1_DATCAR', MODEL_FIELD_INIT, { || Date()} )
	oStruBA1:setProperty( 'BA1_CPFUSR', MODEL_FIELD_VALID, { || VldCpfUsrMVC(oModel)} )

	//Instala o evento padrão do programa.
	oModel:installEvent("PLGFBA1Event", /*cOwner*/, oEventBA1)
	oModel:installEvent("PLSA260EVDEF", /*cOwner*/, oEvent)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação
@author  Totver
@version P2
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local aCampBA1 := {}
	Local aCampBA3 := {}
	Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CamMenu('BA3',cCampo,'N',@aCampBA3) },.T./*lViewUsado*/)
	Local oStruBA1 := FWFormStruct( 2, 'BA1'    , { |cCampo| PLS260CamMenu('BA1',cCampo,'N',@aCampBA1) },.T./*lViewUsado*/)
	Local oModel   := FWLoadModel( 'PLSA260MVC' )
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oStruBA1:RemoveField('BA1_PTUCAD')
	oStruBA3:RemoveField('BA3_CODVEN')
	oStruBA3:RemoveField('BA3_EQUIPE')
	oStruBA3:RemoveField('BA3_COBNIV')

	oStruBA3:SetNoFolder(.T.)
	oStruBA1:SetNoFolder(.T.)

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next



	// Adiciona um painel com os campos para filtrar as informações do grid
	oStruBA3:SetProperty( "BA3_CODINT" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_CODEMP" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_MATRIC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_FORCTX" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_GRPFAM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )

	//Grupo 02
	oStruBA3:AddGroup( 'GrupoBA3_2', OemToAnsi('Campos Obrigatórios') , '1', 2 )
	oStruBA3:SetProperty( "BA3_TIPPGO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_CODPLA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_DESPLA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_VERSAO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_FORPAG" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_DESFOR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_DATBAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_VENCTO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )

	For nNx := 1 to Len(aCampBA3)
		oStruBA3:SetProperty( aCampBA3[nNx] ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	Next nNx



	//Grupo 01 BA1
	oStruBA1:AddGroup( 'GrupoBA1_1', OemToAnsi('Dados do Titular') , '1', 2 )
	oStruBA1:SetProperty( "BA1_CODEMP" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_INFANS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MATRIC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DTVLCR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CPFUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MATVID" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_NOMUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_NOMSOC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CODINT" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DRGUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CDMNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MUNNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_SEXO"   ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_PISPAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_ESTCIV" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_TIPREG" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DIGITO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_TIPUSU" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESUSU" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESCIV" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_GRAUPA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATINC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MAE"    ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATADM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATCAR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESGRA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_IDADE"  ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_OPEORI" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_OPEDES" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_RESFAM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )

	For nNx := 1 to Len(aCampBA1)
		oStruBA1:SetProperty( aCampBA1[nNx] ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	Next nNx


	oStruBA1:AddGroup( 'GrupoBA1_2', OemToAnsi('Endereço') , '1', 2 )
	oStruBA1:SetProperty( "BA1_CEPUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ENDERE" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_NR_END" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_COMEND" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_BAIRRO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_CODMUN" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_MUNICI" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ESTADO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_DDD"    ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_TELEFO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ORIEND" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )

	oView:AddField( 'VIEW_BA1', oStruBA1, 'BA1MASTER' )
	oView:AddField( 'VIEW_BA3', oStruBA3, 'BA3DETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )


	//oView:EnableTitleView('VIEW_BA1','Cadastro do Beneficiário Titular')

	oView:SetOwnerView( 'VIEW_BA3', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BA1', 'INFERIOR' )






	/*Não permito alteração nos campos*/
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Verifica se os dados podem ser inclusos/alterados
@author Totver
@since 13/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260VLMVC(nOperation,lAutomato)
	Local lRet := .T.
	Local aArea		 := GetArea()
	Local aAreaBA3   := BA3->(GetArea())
	Local nOrdBA1    := BA1->(IndexOrd())
	Local nRecBA1    := BA1->(Recno())
	Local nOrdBQC    := BQC->(IndexOrd())
	Local nRecBQC    := BQC->(Recno())
	Local bRest      := { || BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRecBA1)) }
	Local bRestBQC   := { || BQC->(dbSetorder(nOrdBQC)), BQC->(dbGoto(nRecBQC)) }
	Local lExcluiUsu :=.T.
	Local cTipTit 	 := SuperGetMv("MV_PLCDTIT")

	Default	lAutomato:= .F.

	If lJuridico

		If (!Empty(BQC->BQC_DATBLO) .and. !Empty(BQC->BQC_CODBLO)) .and. (nOperation <> MODEL_OPERATION_VIEW)
			If !lAutomato
				Aviso(OemtoAnsi(STR0011),OemtoAnsi(STR0012) ,;//"Este subcontrato encontra-se bloqueado. So sera permitido a visualizacao dos registros ja existentes!"
					{OemtoAnsi(STR0015)})
			Endif
			lRet := .F.
			DbSelectArea("BA1")

			Return

		ElseIf (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
			BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			If !Empty(BA3->BA3_MOTBLO)
				If !lAutomato
					Aviso(OemtoAnsi(STR0013),OemtoAnsi(STR0014) ,; //"Esta familia encontra-se bloqueada, o registro somente podera ser visualizado."
						{OemtoAnsi(STR0015)})
				Endif
				lRet := .F.
				DbSelectArea("BA1")
				Return
			Endif
		EndIF
	EndIF

	If nOperation == MODEL_OPERATION_DELETE
		If BA1->BA1_TIPUSU	== 'T'

			If(!lAutomato, lExcluiUsu:=MsgYesNo(OemtoAnsi(STR0054)),)	 //"Deseja realmente excluir o Usuario/Familia?"

			If lExcluiUsu
				If ! PLSA260Exc(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,If(lAutomato,.F.,.T.))
					Eval(bRest)
					Eval(bRestBQC)
					//Refaz o filtro...
					DbSelectArea("BA1")
					Return
				Endif
			Else
				Return(nil)
			Endif
		Else
			Help( ,, 'HELP',,'Para exclusão nessa rotina somente titular.', 1, 0)
			Return(nil)
		Endif

	Endif

	If lRet .and. (!lAmbos .or. (lAmbos .and. nOperation == MODEL_OPERATION_UPDATE))
		If lAutomato .or. FWExecView('','PLSA260MVC', nOperation,, { || .T. } ) == 0
			If nOperation = 3

				If lAutomato .or. MsgYesNo("Deseja incluir dependentes ?")
					If (!lAutomato,FWExecView('','PL260DEPMVC', nOperation,, { || .T. } ) <> 0 ,.T.)
					While .T.
						BA1->(dbSetOrder(1))
						BA1->(msSeek(xFilial("BA1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+cTipTit))
						If !lAutomato .And. MsgYesNo("Deseja incluir mais algum dependente ?")
							If (!lAutomato,FWExecView('','PL260DEPMVC', nOperation,, { || .T. } ) <> 0 ,.T.)
						Else
							Exit
						EndIf
					Enddo
				EndIf


				If lAutomato .or. MsgYesNo("Deseja configurar a cobrança na Familia ?")
					If(!lAutomato,FWExecView('Edição','PLSA260FD1COB', MODEL_OPERATION_UPDATE,, { || .T. } ),.T.)
				Endif


			Endif

		Endif
	ElseIf lRet .and. lAmbos .AND. nOperation == MODEL_OPERATION_INSERT
		If (!lAutomato,	MsgAlert('Não é possivel realizar inclusão ao selecionar a opção Pesquisar no Pergunte.','Aviso'),)
	EndIF

	RestArea(aAreaBA3)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Monta o Menu do PLSA260MVC
@author Totver
@since 14/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLS260CamMenu(cAlias,cCampo,cModel,aCampos)
	Local lRet := .F.

	Default  aCampos:= {}

	BI3->(DbSetOrder(1))
	cCampo := AllTrim(cCampo)

	If cAlias == "BA3"
		If cCampo $ "BA3_CODPLA,BA3_DESPLA,BA3_DATBAS,BA3_TIPPGO,BA3_VERSAO,BA3_FORPAG,BA3_DESFOR,BA3_CODINT,BA3_CODEMP,BA3_MATRIC,BA3_FORCTX,BA3_VENCTO,BA3_GRPFAM,BA3_REEWEB,BA3_CODVEN,BA3_EQUIPE, BA3_COBNIV" .OR.;
				(cModel == 'S' .AND. cCampo $ ("BA3_RATSAI,BA3_DESMEN,BA3_TIPOUS,BA3_CONEMP,BA3_SUBCON,BA3_VERCON,BA3_VERSUB,BA3_ROTINA,BA3_DEFOTX,BA3_MODPAG"))
			lRet := .T.
		EndIF
	ElseIf cAlias == "BA1"
		If cCampo $ "BA1_CPFUSR,BA1_PTUCAD,BA1_MATVID,BA1_NOMUSR,BA1_NOMSOC,BA1_DATNAS,BA1_DRGUSR,BA1_CDMNAS,BA1_MUNNAS,BA1_SEXO,BA1_PISPAS,BA1_ESTCIV,BA1_TIPREG,BA1_DIGITO,BA1_TIPUSU,BA1_DESUSU,BA1_RESFAM, BA1_EMAIL" .or.;
				cCampo $	"BA1_DESCIV,BA1_GRAUPA,BA1_DATINC,BA1_MAE,BA1_DATCAR,BA1_DESGRA,BA1_IDADE,BA1_OPEORI,BA1_OPEDES,BA1_CEPUSR,BA1_ENDERE,BA1_NR_END,BA1_COMEND,BA1_BAIRRO" .or.;
				cCampo $ "BA1_DATADM,BA1_CODMUN,BA1_MUNICI,BA1_ESTADO,BA1_DDD,BA1_TELEFO,BA1_ORIEND,BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_DTVLCR,BA1_INFANS" .OR.;
				(cModel == 'S' .AND. cCampo $ ("BA1_CODPLA,BA1_VERSAO,BA1_DATINC,BA1_CONEMP,BA1_SUBCON,BA1_VERCON,BA1_VERSUB,BA1_INTERD,BA1_OPERES,BA1_LOCANS,BA1_LOCATE,BA1_LOCEMI,BA1_REEWEB,BA1_10ANOS,BA1_INSALU,BA1_INFCOB,BA1_MUDFAI,BA1_LOCSIB"))


			lRet := .T.
		EndIF
	EndIF



	// Incluindo os campos customizados
	IF !lret .And. GetSx3Cache(cCampo, "X3_PROPRI") = "U"
		lRet := .T.
		AaDD(aCampos,cCampo)
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpfUsrMVC
Valida o CPF
@author Totver
@since 30/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function VldCpfUsrMVC(oModel)
	Local lRet:= .T.

	If Cgc(oModel:GetValue('BA1MASTER','BA1_CPFUSR'))
		If  !Empty(oModel:GetValue('BA1MASTER','BA1_CPFUSR'))
			lRet := PLS260VIDMVC('I',oModel)
		EndIF
	EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpfUsrMVC
Chama cadastro de vidas caso nao exista o CPF.
@author Totver
@since 30/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260VIDMVC(ctipo,oModel)

	Local cCpf 	  	:= oModel:GetValue('BA1MASTER','BA1_CPFUSR')
	Local lRet		:=.t.


	Default ctipo :="I"

	BTS->( dbSetorder(03) )
	oModel:LoadValue('BA1MASTER','BA1_MATVID', Space(TamSx3('BTS_MATVID')[1]))

	Do Case
		Case ctipo == "I"
			If !BTS->( MsSeek(xFilial("BTS")+cCpf) ) .Or. Empty(cCpf)
				If !IsBlind()
					FWExecView('Incluir','PLSA955', MODEL_OPERATION_INSERT,, { || .T. } )
				EndIf
			Else
				If PLSBA1VLDINC(oModel)
					oModel:LoadValue('BA1MASTER','BA1_MATVID', BTS->BTS_MATVID)
				Else
					Help(" ",1,"JAGRAVADO")
					lRet:=.F.
				EndIf
			Endif
	Endcase

	oModel:LoadValue('BA1MASTER','BA1_MATVID', BTS->BTS_MATVID)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpfUsrMVC
Valida se o CPF já foi utilizado na familia
@author Totver
@since 30/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBA1VLDINC(oModel)
	LOCAL lRet := .T.
	LOCAL aAreaBA1 := BA1->(GetArea())
	LOCAL cChaveBA1:= oModel:GetValue('BA3DETAIL','BA3_CODINT')+oModel:GetValue('BA3DETAIL','BA3_CODEMP')+oModel:GetValue('BA3DETAIL','BA3_MATRIC')

	BA1->( dbSetorder(04) )//BA1_FILIAL+BA1_CPFUSR
	If BA1->(MsSeek(xFilial('BA1')+oModel:GetValue('BA1MASTER','BA1_CPFUSR')))
		If BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cChaveBA1
			lRet := .F.
		EndIF
	EndIF

	RestArea(aAreaBA1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260VldAde
Valida se o o codigo de adesão esta configurada para o produto digitado
@author Totver
@since 29/09/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PL260VldAde(cCodInt,cCodPla,cVersao,cForcTx)

	Local lRet:= .F.

	Default cCodInt := ''
	Default cCodPla := ''
	Default cVersao := ''
	Default cForcTx := ''

	If BJ9->(DbSeek(xFiliAl("BJ9")+cCodInt+cCodPla+cVersao+cForcTx))
		lRet:= .T.
	Endif

	If !lRet
		MsgAlert("Taxa de adesão não configurada para esse produto!","Atenção")
	Endif

Return lRet

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLTermoBenef
Visualiza o Termo de Consentimento do Beneficiário selecionado

@author Vinicius Queiros Teixeira
@since 07/05/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLTermoBenef()

	Local cOperadora := BA1->BA1_CODINT
	Local cEmpresa := BA1->BA1_CODEMP
	Local cMatricula := BA1->BA1_MATRIC

	PLTermConsBenef(cOperadora, cEmpresa, cMatricula)

Return

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLMVCDesUsu
Inicializador padrão do campo BA1_TIPUSU da Rotina MVC

@author Giovanna Charlo
@since 30/12/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLMVCDesUsu()

	Local oModel := FWModelActive()
	Local cTipuUsuario := ""
	Local cDescUsuario := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		If IsInCallStack("PLSA260VLMVC")
			cTipuUsuario  := SuperGetMv("MV_PLCDTIT")
		Else
			cTipuUsuario  := SuperGetMv("MV_PLCDDEP", .F., "D")
		Endif

	Else
		cTipuUsuario  := BA1->BA1_TIPUSU
	EndIf

	If  !Empty(cTipuUsuario)
		cDescUsuario := Posicione("BIH", 1, xFilial("BIH") + cTipuUsuario, "BIH_DESCRI")
	EndIf

Return cDescUsuario

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLMVCDesGra
Inicializador padrão do campo BA1_GRAUPA da Rotina MVC

@author Giovanna Charlo
@since 30/12/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLMVCDesGra()

	Local oModel := FWModelActive()
	Local cGrauParentesco := ""
	Local cDescParentesco := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		If IsInCallStack("PLSA260VLMVC")
			cGrauParentesco := SuperGetMv("MV_PLCDTGP")
		Else
			cGrauParentesco := ""
		Endif

	Else
		cGrauParentesco := BA1->BA1_GRAUPA
	EndIf

	If !Empty(cGrauParentesco)
		cDescParentesco := Posicione("BRP", 1, xFilial("BRP")+cGrauParentesco, "BRP_DESCRI")
	EndIf

Return cDescParentesco

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLTipUsWhen
Valida se é Novo Grupo Familia e se o campo BA3_GRPFAM está preenchido
para desbloquear o campo BA1_TIPUSU
@author Guilherme Carreiro
@since 15/12/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLTipUsWhen()

	Local lWhen := .F.
	Local oModel := FWModelActive()
	Local cFamilia := IIF(!isInCallstack("PLA260VLDEP") .And. oModel:nOperation == MODEL_OPERATION_INSERT,oModel:GetValue("BA3DETAIL", "BA3_GRPFAM"), "")

	If FunName() == "PLSA124" .And. oModel:nOperation == MODEL_OPERATION_INSERT .And. !isInCallstack("PLA260VLDEP")
		If !Empty(cFamilia)
			lWhen := .T.
		Else
			lWhen := .F.
		EndIf
	ElseIf FunName() == "PLSA124" .And. oModel:nOperation == MODEL_OPERATION_INSERT .And. isInCallstack("PLA260VLDEP")
		lWhen := .T.
	Else
		lWhen := .F.
	EndIf

Return lWhen

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLSPESGPF
Pesquisa de Grupo Familiar
@author Guilherme Carreiro
@since 15/12/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
function PLSPESGPF()
	
	local cChave := space(100)
	local aBrowUsr := {} as array
	local aVetPad := {{"ENABLE", "", "", "", "", "", ""}} as array
	local cTipoPes := "" as character
	local lChkChk := .f. as logical
	local aButtons := {} as array
	local aTipoPes := {} as array
	local aOpcoes := {} as array
	local nOpca := 0 as numeric
	local nLin := 1 as numeric
	local bOK as codeblock
	local bRefresh as codeblock
	local bCancel as codeblock
	local oDlg as object
	local oBrowUsr as object
	local oTipoPes as object
	local oChkChk as object
	local oGetChave as object
	local oCenLGPD := CENFUNLGP():new() as object
	local aPDFields as array

	cRetGrpFam := ""

	bOK := { || iif(funName() == "TMKA271", (nLin := oBrowUsr:nAt, nOpca := 1, oDlg:end()), iif(!empty(cChave), (nLin := oBrowUsr:nAt, nOpca := 1, oDlg:end()), help("",1,"PLSMCON")))}
	bRefresh := { || iif(!empty(cChave), PLSAPUSRGF(alltrim(cChave), substr(cTipoPes, 1, 1), lChkChk, @aBrowUsr, aVetPad, @oBrowUsr, @aOpcoes), .t.)}
	bCancel := { || nOpca := 3, oDlg:End()}

	aBrowUsr := aClone(aVetPad)

	aTipoPes := {STR0298, STR0299, STR0300, STR0308} // 1-Nome do Usuario, 2-Matrícula, 3-CPF, 4-Nome Social

	aAdd(aOpcoes, {"BA1_NOMUSR"})
	aAdd(aOpcoes, {"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG"})
	aAdd(aOpcoes, {"BA1_CPFUSR"})
	aAdd(aOpcoes, {"BA1_NOMSOC"})

	DEFINE MSDIALOG oDlg TITLE STR0301 FROM 008.2,000 TO 026,100.3 OF GetWndDefault() // "Pesquisa de Beneficiarios"

		oGetChave := TGet():new(033,103,{|U| iif(PCOUNT() == 0,cChave,cChave := U)},oDlg,210,008,"@!S30",bRefresh,nil,nil,nil,nil,nil,.t.,nil,.f.,nil,.f.,nil,nil,.f.,nil,nil,cChave)

		oBrowUsr := TcBrowse():new(050,008,378,075,nil,nil,nil,oDlg,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.f.,nil,.t.,nil,.f.)

		oBrowUsr:addColumn(TcColumn():new("",{|| aBrowUsr[oBrowUsr:nAt][1]},nil,nil,nil,nil,015,.t.,.f.,nil,nil,nil,.t.,nil))
		oBrowUsr:addColumn(TcColumn():new(STR0302,{|| aBrowUsr[oBrowUsr:nAt][2]},nil,nil,nil,nil,055,.f.,.f.,nil,nil,nil,.f.,nil)) // "Matricula"
		oBrowUsr:addColumn(TcColumn():new(STR0303,{|| aBrowUsr[oBrowUsr:nAt][3]},nil,nil,nil,nil,055,.f.,.f.,nil,nil,nil,.f.,nil)) // "Nome"
		oBrowUsr:addColumn(TcColumn():new(STR0309,{|| aBrowUsr[oBrowUsr:nAt][4]},nil,nil,nil,nil,055,.f.,.f.,nil,nil,nil,.f.,nil)) // "Nome Social"
		oBrowUsr:addColumn(TcColumn():new(STR0304,{|| aBrowUsr[oBrowUsr:nAt][5]},nil,nil,nil,nil,120,.f.,.f.,nil,nil,nil,.f.,nil)) // "Contrato"
		oBrowUsr:addColumn(TcColumn():new(STR0305,{|| aBrowUsr[oBrowUsr:nAt][6]},nil,nil,nil,nil,120,.f.,.f.,nil,nil,nil,.f.,nil)) //" Sub-Contrato"
		oBrowUsr:addColumn(TcColumn():new(STR0306,{|| aBrowUsr[oBrowUsr:nAt][7]},nil,nil,nil,nil,055,.f.,.f.,nil,nil,nil,.f.,nil)) // "CPF"

		@ 033,008 COMBOBOX oTipoPes Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlg PIXEL COLOR CLR_HBLUE
		@ 033,319 CHECKBOX oChkChk Var lChkChk PROMPT STR0307 PIXEL SIZE 080, 010 OF oDlg // "Pesquisar Palavra Chave"

		oBrowUsr:setArray(aBrowUsr)
		oBrowUsr:BLDBLCLICK := bOK

		if oCenLGPD:isLGPDAt() 
			aPDFields := {.f., "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO", "BA1_NOMUSR", "BA1_NOMSOC", "BA1_CONEMP", "BA1_SUBCON", "BA1_CPFUSR"}
			oBrowUsr:aObfuscatedCols := oCenLGPD:getTcBrw(aPDFields) 
		endif

	ACTIVATE MSDIALOG oDlg ON INIT eval({ || enChoiceBar(oDlg, bOK, bCancel, .f., aButtons)})

	if nOpca == 1
		if len(aBrowUsr) > 0 .and. nLin > 0 .and. !empty(aBrowUsr[nLin][2])
			cRetGrpFam := aBrowUsr[nLin][2] // Variavel de retorno da consulta padrão PLSGPF
		endif
	endif

return (nOpca == 1)

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLSAPUSRGF
Pesquisa Usuários do mesmo Grupo Familiar
@author Guilherme Carreiro
@since 15/12/2022
@version Protheus 12
/*/
//--------------------------------------------------------------------
Static Function PLSAPUSRGF(cChave,cTipoPes,lChkChk,aBrowUsr,aVetPad,oBrowUsr,aOpcoes)

	local cQuery := "" as character
	local cAliasTemp := getNextAlias() as character
	local cHealthInsurerCode := PFldGetBA3("BA3_CODINT") as character
	local cCompanyCode := PFldGetBA3("BA3_CODEMP") as character
	local cMatricCode := PFldGetBA3("BA3_MATRIC") as character
	local cLegColor as character

	aBrowUsr := {}

	cQuery := " SELECT BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_TIPREG,BA1_DIGITO,BA1_CONEMP,BA1_NOMSOC,"
	cQuery += " 	   BA1_SUBCON,BA1_NOMUSR,BA1_CPFUSR,BA1_DATBLO,BA1_DATINC"
	cQuery += " FROM "+RetSqlName("BA1")+" BA1 "
	cQuery += " WHERE BA1.BA1_FILIAL = '"+xFilial("BA1")+"' "
	cQuery += " AND BA1.BA1_CODINT = '"+cHealthInsurerCode+"' "
	cQuery += " AND BA1.BA1_CODEMP = '"+cCompanyCode+"' "
	cQuery += " AND BA1.BA1_MATRIC <> '"+cMatricCode+"'"

	cQuery += PLFldWhQry(aOpcoes[val(cTipoPes)][1], cChave, lChkChk)

	cQuery += " AND BA1.BA1_TIPUSU = '"+getNewPar("MV_PLCDTIT", "T")+"' "
	cQuery += " AND (BA1.BA1_DATBLO = ' ' OR BA1.BA1_DATBLO > '"+dtos(dDataBase)+"')"
	cQuery += " AND BA1.D_E_L_E_T_ = ' ' "

	cAliasTemp := MPSysOpenQuery(cQuery)

	TcSetField(cAliasTemp, "BA1_DATBLO", "D")
	TcSetField(cAliasTemp, "BA1_DATINC", "D")

	while !(cAliasTemp)->(eof())
		cLegColor := PLLegBloq(cAliasTemp)

		(cAliasTemp)->(aAdd(aBrowUsr, {cLegColor, BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO,;
									   BA1_NOMUSR, BA1_NOMSOC, BA1_CONEMP, BA1_SUBCON, BA1_CPFUSR}))
		
		(cAliasTemp)->(dbSkip())
	enddo

	(cAliasTemp)->(dbCloseArea())

	if len(aBrowUsr) == 0
		aBrowUsr := aClone(aVetPad)
	endif

	oBrowUsr:nAt := 1
	oBrowUsr:setArray(aBrowUsr)
	oBrowUsr:refresh()
	oBrowUsr:setFocus()

return .t.


/*/{Protheus.doc} cCriaAliasTemp
Criação dos campos e colunas da oBrowseBA1 que contem os beneficiarios da familia

@author  Robson Nayland Benjamim
@version P12
@since   03/03/2023
/*/

static function cCriaAliasTemp(cAliasTemp,aColumns)
	local cFilFAM:=''
	local nContFlds :=0
	local aStructField:={}
	Local oStruBA1 := FWFormStruct(2, 'BA1')
	Local aFields := oStruBA1:GetFields()

 	cFilFAM := "SELECT * FROM "+ RetSqlName("BA1") + ' WHERE '
	cFilFAM += "BA1_FILIAL = '" + xFilial("BA1") + "' AND BA1_CODINT = '"+BA1->BA1_CODINT+"' AND BA1_CODEMP = '"+BA1->BA1_CODEMP+"' "
	cFilFAM += "AND BA1_CONEMP = '"+BA1->BA1_CONEMP+"' AND BA1_VERCON = '"+BA1->BA1_VERCON+"' "
	cFilFAM += "AND BA1_SUBCON = '"+BA1->BA1_SUBCON+"' AND BA1_VERSUB = '"+BA1->BA1_VERSUB+"' "
	cFilFAM += "AND BA1_MATRIC = '"+BA1->BA1_MATRIC+"' "
	cFilFAM += "AND D_E_L_E_T_ = ' '"

	cAliasTemp  := MpSysOpenQuery(cFilFAM)

	TcSetField(cAliasTemp,"BA1_DATINC","D",8,0)

	For nContFlds := 1 To Len( aFields )

		aStructField:= FWSX3Util():GetFieldStruct(aFields[nContFlds][1])

		//A posição 16 do Array é o campo X3_CONTEXTO onde F = Real e T = Virtual
		If aStructField[2] <> "M" .And. aFields[nContFlds][16] == .F.

			AAdd( aColumns, FWBrwColumn():New() )

			aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nContFlds][1] + " }") )
			aColumns[Len(aColumns)]:SetTitle( FWSX3Util():GetDescription(( aFields[nContFlds][1])) )
			aColumns[Len(aColumns)]:SetSize( astructField[3] )

			aColumns[Len(aColumns)]:SetPicture( AllTrim(GetSX3Cache(aFields[nContFlds][1], 'X3_PICTURE' )) )
			aColumns[Len(aColumns)]:SetID( aFields[nContFlds][1] )

		EndIf

	Next nContFlds

return


/*/{Protheus.doc} AtuaBrwBA1
Atualiza a oBrowseBA1 que contem os beneficiarios da familia

@author  Robson Nayland Benjamim
@version P12
@since   03/03/2023
/*/
static function AtuaBrwBA1(oBrowseBA1,cAliasTemp)

	(cAliasTemp)->(DbCloseArea())

	cFilFAM := "SELECT * FROM "+ RetSqlName("BA1") + ' WHERE '
	cFilFAM += "BA1_FILIAL = '" + xFilial("BA1") + "' AND BA1_CODINT = '"+BA1->BA1_CODINT+"' AND BA1_CODEMP = '"+BA1->BA1_CODEMP+"' "
	cFilFAM += "AND BA1_CONEMP = '"+BA1->BA1_CONEMP+"' AND BA1_VERCON = '"+BA1->BA1_VERCON+"' "
	cFilFAM += "AND BA1_SUBCON = '"+BA1->BA1_SUBCON+"' AND BA1_VERSUB = '"+BA1->BA1_VERSUB+"' "
	cFilFAM += "AND BA1_MATRIC = '"+BA1->BA1_MATRIC+"' "
	cFilFAM += "AND D_E_L_E_T_ = ' '"

	cAliasTemp  := MpSysOpenQuery(cFilFAM)
	TcSetField(cAliasTemp,"BA1_DATINC","D",8,0)
	oBrowseBA1:SetAlias( cAliasTemp )
	oBrowseBA1:Refresh(.f.)
	(cAliasTemp)->(DbGoTop())
return

/*/{Protheus.doc} ExecConsltaBenef
Chama a tela de visualização do beneficiario

@author  Robson Nayland Benjamim
@version P12
@since   03/03/2023
/*/
static function ExecConsltaBenef(cAliasTemp)
	local aAreaTMP:= (cAliasTemp)->(GetArea())
	local aAreaBA1:= BA1->(GetArea())

	BA1->(dbSetOrder(13))
	BA1->(DbSeek(xFilial("BA1")+(BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+ BA1_VERSUB+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))))

	lJuridico:=.F.
	if !empty(BA1->(BA1_CONEMP+BA1_VERCON+BA1_SUBCON+ BA1_VERSUB))
		lJuridico:=.T.
	endif
	lAmbos := .F.

	PLSACHKMENU(1)
	RestArea(aAreaBA1)
	RestArea(aAreaTMP)
	oBrowseBA1:Refresh()
	(cAliasTemp)->(DbGoTop())

return

/*/{Protheus.doc} PLFldWhQry
Retorna where da query de acordo com os campos informados e a chave de busca

@type function
@version Protheus 12.1.2310  
@author vinicius.queiros
@since 31/08/2023
@param cFieldList, character, lista de campos para montar query
@param cSearchKey, character, chave de busca para adicionar ao query
@param lKeyword, logical, indica se utiliza palavra chave
@return character, where com os campos informados
/*/ 
function PLFldWhQry(cFieldList, cSearchKey, lKeyword)

	local nCount := 0 as numeric
	local aWhereFields as array
	local nSizeField as numeric
	local cField as character
	local cValue as character
	local cWhere := "" as character

	aWhereFields := strTokArr(cFieldList, "+")

	for nCount := 1 to len(aWhereFields)
		if !empty(cSearchKey)
			cField := allTrim(aWhereFields[nCount])
			nSizeField := tamSx3(cField)[1]
			cValue := substr(cSearchKey, 1, nSizeField)
			cSearchKey := substr(cSearchKey, nSizeField+1, len(cSearchKey))

			if empty(cSearchKey) .and. len(cValue) != nSizeField
				cWhere += " AND "+cField+" LIKE "+iIf(lKeyword, "'%", "'")+cValue+"%' "
			else
				cWhere += " AND "+cField+" = '"+cValue+"' "
			endIf
		endif
	next nCount

return cWhere 
