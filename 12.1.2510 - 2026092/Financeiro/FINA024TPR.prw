#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024TPR.CH"

#DEFINE OPER_ALTERAR		10
#DEFINE OPER_ATIVAR	        11
#DEFINE OPER_COPIAR			12
#DEFINE OPER_IMPORTAR       13
#DEFINE OPER_EXPORTAR       14

Static cTblBrowse   := "FKS"
Static __nOper      := 0		 // Operacao da rotina
Static __lConfirmou := .F.
Static __lVersao    := .F.
Static __lFirst		:= .F.
Static __oPrepFKS	:= NIL
Static __lTblF7S 	As Logical

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA024TPR
Regras de tabelas financeiras (Tabela Progressiva)

@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FINA024TPR(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0

	//Verifico se as tabelas existem antes de prosseguir
	IF AliasIndic("FKS")

		//Legenda
		If Len(aRotAut) > 0
			FWMVCRotAuto(FWLoadModel("FINA024TPR"), cTblBrowse, nOpcAut, {{"FKSMASTER", aRotAut}}, , .T.)
		Else
			FxBrowse(cTblBrowse, 2, STR0001 , aLegenda)		//"Tabelas Progressivas"
		EndIf

		If __oPrepFKS != NIL
			__oPrepFKS:Destroy()
			__oPrepFKS := NIL
		Endif
	Else
	    Help("",1,"Help","Help",STR0002 ,1,0)		//'Dicionário desatualizado, verifique as atualizações do motor tributário Financeiro'
	EndIf

Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array

	//Inicializa variáveis
	aTitMenu := { {STR0003, "F024FKSCOP", OP_COPIA} }		//"Copiar"
	aActions := { {STR0004, "F024FKSVIS"}, {STR0005, "F024FKSINC"}, {STR0006, "F024FKSALT"}, {STR0007, "F024FKSEXC"} }		//"Visualizar"###"Incluir"###"Alterar"###"Excluir"
	aRotina := FxMenuDef(.T., aTitMenu, aActions)

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de retenção
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oStruFKS As Object
	Local oStruFOS As Object
	Local oStruF7S As Object
	Local aRelFOS As Array
	Local aRelF7S As Array	
	Local bLinPosFOS As CodeBlock
	Local lTableF7S As Logical

	//Inicializa variáveis.
	oModel  := Nil
	aRelFOS := {}
	aRelF7S := {}
	lTableF7S := FTemF7S()

	oStruFKS := FxStruct(1, cTblBrowse, /*{ |x| AllTrim(x) $ cCampos } */)
	oStruFOS := FxStruct(1, "FOS")
	If lTableF7S
		oStruF7S := FxStruct(1, "F7S")
	EndIf

	bLinPosFOS	:= {||F024FOSPos()}

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("FINA024TPR", /*bPreValidacao*/, {||F024TPRTOK()} /*bPosValidacao*/, /*{|oModel|F024TPRGRV(oModel)}*//*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields( "FKSMASTER", /*cOwner*/, oStruFKS, /*bPreValidacao*/, /*bPosValidacao*/,  /*bLoad*/ )
	oModel:AddGrid( "FOSDETAIL", "FKSMASTER", oStruFOS, /*bLinePre*/, bLinPosFOS, /*bPre*/, /*bPos*/, /*bLoad*/)

	If lTableF7S
		oModel:AddGrid( "F7SDETAIL", "FKSMASTER", oStruF7S, /*bLinePre*/, /*bLinPosF7S*/, /*bPre*/, /*bPos*/, /*bLoad*/)
	EndIf

	//Define a chave primária do modelo
	oModel:SetPrimaryKey({"FKS_FILIAL", "FKS_IDRET"})

	// Campo obrigatorio
	oStruFOS:SetProperty("FOS_ITEM"		, MODEL_FIELD_OBRIGAT, .T.)
	oStruFOS:SetProperty("FOS_FAIXA"	, MODEL_FIELD_OBRIGAT, .T.)	
	oStruFOS:SetProperty("FOS_TIPDED"	, MODEL_FIELD_OBRIGAT, .T.)
	If lTableF7S
		oStruF7S:SetProperty("F7S_ITEM"		, MODEL_FIELD_OBRIGAT, .T.)
		oStruF7S:SetProperty("F7S_FAIXA"	, MODEL_FIELD_OBRIGAT, .T.)	
		oStruF7S:SetProperty("F7S_VLRRED"	, MODEL_FIELD_OBRIGAT, .T.)
	EndIf

	//Complementa as informações da estrutura do model
	oStruFKS:SetProperty('FKS_IDRET'  , MODEL_FIELD_INIT , {|| F024FKSRET(oModel) } )
	oStruFKS:SetProperty('FKS_CODIGO' , MODEL_FIELD_WHEN , {|| F024FKSWHE(oModel,'FKS_CODIGO') } )

	//Relacionamento do modelo de dados
	//Cria Relacionamentos FKS - Tabela Progressiva.
	aAdd(aRelFOS	,{ "FOS_FILIAL"	,"xFilial('FKS')"} )
	aAdd(aRelFOS	,{ "FOS_IDRET"	,"FKS_IDRET" 	} )
	oModel:SetRelation("FOSDETAIL"	, aRelFOS	, FOS->( IndexKey(1) ))

	If lTableF7S
		//Cria Relacionamentos FKS - Tabela Progressiva.
		aAdd(aRelF7S	,{ "F7S_FILIAL"	,"xFilial('FKS')"} )
		aAdd(aRelF7S	,{ "F7S_IDRET"	,"FKS_IDRET" 	} )
		oModel:SetRelation("F7SDETAIL"	, aRelF7S	, F7S->( IndexKey(1) ))
	EndIf

	// Adiciona UniqueLine por Item na Grid 1
	oModel:GetModel( "FOSDETAIL" ):SetUniqueLine( { "FOS_FAIXA" } )
	oModel:GetModel( "FOSDETAIL" ):SetDelAllLine( .F. )

	If lTableF7S
		// Adiciona UniqueLine por Item na Grid 2
		oModel:GetModel( "F7SDETAIL" ):SetUniqueLine({"F7S_FAIXA"})
		oModel:GetModel( 'F7SDETAIL' ):SetOptional( .T. )
	EndIf

	If __nOper == OPER_ALTERAR
		oStruFKS:SetProperty('FKS_CODIGO' , MODEL_FIELD_WHEN , {|| .F. } )
	EndIf

	If lTableF7S
		//Define validações dos campos da grid F7S
		oStruF7S:SetProperty("F7S_FAIXA",  MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,'FIN024VLS()'))
		oStruF7S:SetProperty("F7S_VLRRED", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,'FIN024VLR()'))
		oStruF7S:SetProperty("F7S_FATOR",  MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,'FIN024VLT()'))
	EndIf
	
	//Ativa o modelo
	oModel:SetActivate()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oView  As Object
	Local oStruFKS As Object
	Local oStruFOS As Object
	Local oStruF7S As Object
	Local lTableF7S As Logical

	//Inicializa as variáveis
	lTableF7S := FTemF7S()
	oModel := FWLoadModel("FINA024TPR")
	oView  := FWFormView():New()
	oStruFKS := FxStruct(2, cTblBrowse, Nil, Nil, , Nil)
	oStruFOS := FxStruct(2, 'FOS'     , Nil, Nil, , Nil)
	If lTableF7S
		oStruF7S := FxStruct(2, 'F7S'     , Nil, Nil, , Nil)
	EndIf

	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	// Cria box visual para separação dos elementos em tela.
	oView:createHorizontalBox( "FORM", 30, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:createHorizontalBox( "GRID", 70, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

	//Cria as pastas (folders)
	oView:CreateFolder("FOLDER_DETAIL", "GRID")
	oView:AddSheet("FOLDER_DETAIL", "ABA_A", STR0022)  // Pasta A - "Faixas da Tabela Progressiva"
	If lTableF7S
		oView:AddSheet("FOLDER_DETAIL", "ABA_B", STR0023) // Pasta B - "Faixas Especiais - Redutores"
	EndIf

	//Cria os boxes dentro de cada pasta
	oView:createHorizontalBox("BOX_GRID_FOS", 100, /*cIdOwner*/, /*lFixPixel*/, "FOLDER_DETAIL", "ABA_A")
	If lTableF7S
		oView:createHorizontalBox("BOX_GRID_F7S", 100, /*cIdOwner*/, /*lFixPixel*/, "FOLDER_DETAIL", "ABA_B")
	EndIf

	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEWFKS", oStruFKS, "FKSMASTER")
	oView:AddGrid("VIEWFOS", oStruFOS, "FOSDETAIL" )
	If lTableF7S
		oView:AddGrid("VIEWF7S", oStruF7S, "F7SDETAIL")
	EndIf

	oView:SetOwnerView( "VIEWFKS", "FORM" )
	oView:SetOwnerView( "VIEWFOS", "BOX_GRID_FOS" )
	If lTableF7S
		oView:SetOwnerView( "VIEWF7S", "BOX_GRID_F7S" )
	EndIf

	oStruFKS:RemoveField('FKS_IDRET')
	oStruFOS:RemoveField('FOS_IDRET')
	If lTableF7S
		oStruF7S:RemoveField('F7S_FILIAL')
		oStruF7S:RemoveField('F7S_IDRET')
	EndIf

	//Desabilita a edição dos campos
	oStruFOS:SetProperty("FOS_ITEM", MVC_VIEW_CANCHANGE, .F.)
	If lTableF7S
		oStruF7S:SetProperty("F7S_ITEM", MVC_VIEW_CANCHANGE, .F.)
	EndIf
	
	oView:EnableTitleView("VIEWFKS", STR0001 )	//"Tabelas Progressivas"
	oView:SetDescription(STR0001)	

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( "VIEWFOS", "FOS_ITEM" )
	If lTableF7S
		oView:AddIncrementField( "VIEWF7S", "F7S_ITEM" )
	EndIf

	If __nOper == OPER_ALTERAR .OR. __nOper == OPER_COPIAR
		oView:SetAfterViewActivate({|oView| F024FKSAft(oView)})
	EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSVIS
Define a operação de VISUALIZAÇÃO
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSVIS()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_VIEW
	__nOper  := nOpc

	aButtons := {}
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024TPR")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( STR0004 , "FINA024TPR", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	FKM->(DbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSINC
Define a operação de inclusão
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSINC()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_INSERT
	__nOper  := nOpc

	aButtons := {}
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024TPR")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( STR0005 , "FINA024TPR", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	FKM->(DbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSALT
Define a operação de alteração
@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSALT()
	Local nOpc     As Numeric
	Local aButtons As Array
	Local nRegAnt  As Numeric
	
	//Inicializa variáveis
	aButtons     := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	nOpc         := MODEL_OPERATION_UPDATE
	nRegAnt      := FKS->(Recno())
	__nOper      := OPER_ALTERAR
	

	//Somente versões ativas podem ser alteradas/versionadas
	FWExecView(STR0006, "FINA024TPR", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )
		
	__nOper      := 0

	FKM->(DbSetOrder(2))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSEXC()
Define operacao de exclusao

@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSEXC()

	Local oModel	As Object
	Local nOpc		As Numeric
	Local aEnableButtons	As Array
	Local lExclui		As Logical

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := MODEL_OPERATION_DELETE

	oModel := FwLoadModel("FINA024TPR")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	lExclui		:= F24FKSVExc(oModel) 

	If lExclui
		FWExecView( STR0007 ,"FINA024TPR", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Excluir'
	Else
		HELP(' ',1,"F024FKSXC" ,,STR0008,2,0,,,,,, {STR0009})	//"Exclusão não permitida."###"Por favor, verifique se esta regra de tabela progressiva não se encontra relacionado a um cadastro de Regras de Retenção Financeiras. Neste caso pode-se desativar este cadastro."
	Endif
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKS->(DBSETORDER(2))	//"FKS_FILIAL+FKS_CODIGO+FKS_VERSAO"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSCOP()
Define operacao de CÓPIA

@author  Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSCOP()

	Local nOpc		As Numeric
	Local aEnableButtons	As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := OP_COPIA 

	__nOper := OPER_COPIAR
	__lConfirmou := .F.
	__lFirst := .T.

	FWExecView( STR0003 , "FINA024TPR", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Copiar'

	__lFirst := .F.
	__lConfirmou := .F.
	__lVersao := .F.
	__nOper := 0

	FKS->(DBSETORDER(1))	//"FKS_FILIAL+FKS_CODIGO+FKS_VERSAO"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024TPRTOK()
Pós Validacao do model

@author Mauricio Pequim Jr
@since 18/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F024TPRTOK() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local aAreaFKS As Array

	lRet := .T.
	oModel := FWModelActive()
	nOper := oModel:GetOperation()
	aAreaFKS := FKS->(GetArea())
	lRet	:= .T.

	If nOper == MODEL_OPERATION_INSERT

		DBSelectArea("FKS")
		FKS->( DbSetOrder(1) )

		If FKS->( DbSeek( xFilial("FKS")+oModel:GetValue("FKSMASTER","FKS_IDRET") ) )
			HELP(" ",1,"FA024DUP",,STR0010,1,0)	//"Tabela Progressiva já cadastrada."
			lRet	:= .F.
		EndIf

	EndIf

	If lRet
		lRet := F024FOSPos()
	Endif

	__lConfirmou := lRet

	FKS->(RestArea(aAreaFKS))

Return lRet

//-------------------------------------------------------------------------------------------------------------------------------------------------------
// VALIDAÇÕES
//-------------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} F024CODFKS()
Pos Validacao de preenchimento do código do registro de retenção

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024CODFKS() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local lAchou As Logical
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character
	Local aArea As Array
	Local nOper As Numeric

	lRet 	:= .F.
	lAchou 	:= .F.
	oModel 	:= FWModelActive()
	cCodigo := oModel:GetValue('FKSMASTER','FKS_CODIGO')
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""
	nOper   := oModel:GetOperation()

	If !Empty(cCodigo)
		aArea  := FKS->(GetArea())
		FKS->(DbSetOrder(2))	// FKS_FILIAL+FKS_CODIGO+FKS_VERSAO
		If FKS->(MSSeek(xFilial('FKS')+cCodigo))
			lAchou := .T.
		Endif
		FKS->(RestArea(aArea))
	EndIf

	If nOper != MODEL_OPERATION_INSERT .and. nOper != OPER_COPIAR
		cCab := STR0011		//'Código'
		cDes := STR0012		//'Operação não permitida.'
		cSol := STR0013		//'Este campo não pode ser alterado.'
	ElseIf !FreeForUse('FKS','FKS_CODIGO'+xFilial('FKS')+cCodigo)
		cCab := STR0011		//'Código'
		cDes := STR0014		//'O código digitado se encontra em uso.'
		cSol := STR0015		//'Código se encontra reservado.'
	ElseIf lAchou
		cCab := STR0011		//'Código'
		cDes := STR0016		//'O código já se encontra cadastrado.'
		cSol := STR0017		//'Verifique o código informado.'
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24FKSVExc()
Valida permissão de Exclusão

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
STATIC Function F24FKSVExc(oModel As Object) As Logical

	Local lRet As Logical
	Local cIdRet As Character
	Local cQuery As Character

	DEFAULT oModel	:= 	FWModelActive()

	lRet := .T.
	cQuery := ''
	cIdRet := oModel:GetValue("FKSMASTER","FKS_IDRET")

	cQuery := ""

	If __oPrepFKS == NIL
		cQuery := "SELECT FKN_IDFKS IDRETFKS "
		cQuery += " FROM "+RetSqlName('FKN')+" FKN "
		cQuery += " WHERE "
		cQuery += " FKN.FKN_IDFKS = ? AND"
		cQuery += " FKN.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		__oPrepFKS:=FWPreparedStatement():New(cQuery)
	Endif
		
	__oPrepFKS:SetString(1,cIdRet)

	cQuery := __oPrepFKS:GetFixQuery()
			
	lRet := Empty(MpSysExecScalar(cQuery,"IDRETFKS"))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSRET()
Inicializador padrao do campo FKS_IDRET

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSRET(oModel As Object) As Character

	Local cRet As Character
	Local aAreaFKS As Array
	Local nOper	As Numeric

	DEFAULT oModel := NIL

	cRet	:= ""
	aAreaFKS := FKS->(GetArea())
	nOper := __nOper

	If oModel != NIL
		nOper	:= oModel:GetOperation()
	EndIf

	If nOper == MODEL_OPERATION_INSERT .OR. nOper == OPER_ALTERAR .OR. nOper == OPER_COPIAR	

		While .T.
			cRet := FWUUIDV4()
			FKS->(DbSetOrder(1))
			If !(FKS->(MsSeek(xFilial("FKS")+cRet))) .and. FreeForUse("FKS",cRet)
				FKS->(RestArea(aAreaFKS))
				Exit	
			Endif
		EndDo

		//Em caso de alteração ou cópia, ajusto a versão do imposto
		If nOper == OPER_ALTERAR .OR. nOper == OPER_COPIAR
			If oModel != NIL
				oModel:LoadValue("FKSMASTER","FKS_IDRET",cRet)
				F024FKSVER(oModel)	
				FKS->(RestArea(aAreaFKS))
			EndIf
		Endif
	Else
		cRet := FKS->FKS_IDRET
	Endif

Return cRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSVER()
Inicializador padrão do campo FKS_VERSAO

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSVER(oModel As Object) As Character

	Local cRet As Character

	DEFAULT oModel := NIL

	cRet	:= ""	

	If __nOper == OPER_COPIAR .and. __lFirst
		If oModel != NIL
			oModel:LoadValue("FKSMASTER","FKS_CODIGO","")
			oModel:LoadValue("FKSMASTER","FKS_DESCR" ,"")
		EndIf
	EndIF

Return cRet	

//-------------------------------------------------------------------
/*/ {Protheus.doc} F024FKSWhe
Permissão de edição de campos (When)

@param oModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico com permissão ou não de edição do campo
/*/
//-------------------------------------------------------------------
Function F024FKSWhe(oModel As Object, cCampo As Character)

Local lRet As Logical

DEFAULT oModel := NIL
DEFAULT cCampo := ""

lRet := .T.

If cCampo == "FKS_CODIGO" 
	If __nOper == OPER_ALTERAR
		lRet := .F.
	Endif

	If lRet .and. __nOper == OPER_COPIAR .and. __lFirst
		F024FKSVER(oModel)
		__lFirst := .F.
	EndIf

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKSAft()
Refresh da View utilizado para alteração

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKSAft(oView As Model) As Logical

	oView:Refresh()

Return .T. 

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FOSPOS()
Pos validacao de preenchimento da grid de faixas 
da tabela progressiva (tabela FOS).

@author  Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FOSPOS() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local oFOS As Object
	Local nOper As Numeric
	Local nTamGrid As Numeric
	Local nX As Numeric

	oModel		:= FWModelActive()
	nOper		:= oModel:GetOperation()
	oFOS		:= oModel:GetModel("FOSDETAIL")
	lRet		:= .T.
	nTamGrid	:= oFOS:Length()
	nX			:= 0

	If __nOper == OPER_ALTERAR .OR. __nOper == MODEL_OPERATION_INSERT .OR. __nOper == OPER_COPIAR

		For nX := 1 To nTamGrid
			oFOS:GoLine( nX )
			If !oFOS:IsDeleted() .and. Empty(oFOS:GetValue("FOS_FAIXA"))
				lRet := .F.
				HELP(' ',1, 'TAB PROGRESSIVA GRID' ,, STR0018 ,2,0,,,,,, {STR0019} )	//"Existem informações necessárias não preenchidas."###"É obrigatório o preenchimento do Valor Limite." 
				Exit			
			Endif	
		Next
	Endif

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024VLF
Implementar valid do campo FOS_FAIXA

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024VLF() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('FOSDETAIL','FOS_FAIXA'))
Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024VLS
Implementar valid do campo F7S_FAIXA

@author Fabio Casagrande Lima
@since 21/01/2026

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024VLS() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('F7SDETAIL','F7S_FAIXA'))
Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024VLR
Implementar valid do campo F7S_VLRRED

@author Fabio Casagrande Lima
@since 21/01/2026

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024VLR() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('F7SDETAIL','F7S_VLRRED'))
Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024VLT
Implementar valid do campo F7S_FATOR

@author Fabio Casagrande Lima
@since 21/01/2026

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024VLT() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('F7SDETAIL','F7S_FATOR'))
Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024ALQ
Implementar valid do campo FOS_PERC

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024ALQ()                                                                                                                     

	Local lRet As Logical
	Local oModel As Object
	Local nPerc As Numeric

	oModel := FWModelActive()
	nPerc := oModel:GetValue('FOSDETAIL','FOS_PERC')

	lRet :=  POSITIVO(nPerc) 

	If lRet .and. (nPerc > 100)
		HELP(' ',1, 'FOS_PERCENTUAL' ,, STR0020 ,2,0,,,,,, {STR0021} )	//"O valor informado é inválido."###"Informe um valor menor ou igual a 100"
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024VLD
Implementar valid do campo FOS_VLRDED

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024VLD() As Logical

	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('FOSDETAIL','FOS_VLRDED'))

Return lRet

//---------------------------------------
/*/{Protheus.doc} FTemF7S()
Verifica se a tabela F7R está disponível no ambiente
@author fabio.casagrande
@since	28/01/2026
@version 12
*/
//---------------------------------------
Static Function FTemF7S()
	If __lTblF7S == Nil
		__lTblF7S := AliasIndic("F7S")
	EndIf
Return __lTblF7S
