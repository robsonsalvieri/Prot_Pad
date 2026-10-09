#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024DED.CH"

Static cTblBrowse   := "FKV"
Static __nOper      := 0
Static __lConfirmou := .F.
Static __lFirst		:= .T.
Static __oPrepFKP	:= Nil
Static __lAltAll    := .F.
Static __lTblF7R	As Logical

#DEFINE OPER_ATIVAR	  11
#DEFINE OPER_COPIAR	  12

//---------------------------------
/*/{Protheus.doc} FINA024DED
Regra de Cumulatividade

@author  Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function FINA024DED(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0
	
	DbSelectArea("FOV")
	DbSelectArea(cTblBrowse)

	(cTblBrowse)->(DbSetOrder(2))	
	
	If Len(aRotAut) > 0
		FWMVCRotAuto(FWLoadModel("FINA024DED"), cTblBrowse, nOpcAut, {{"FKVMASTER", aRotAut}}, , .T.)
	Else
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda)		//"Regra de Dedução"
	EndIf
Return
 
//---------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array
	
	//Inicializa variáveis
	aTitMenu := { {STR0002, "F24DEDCOP", OP_COPIA}}		//"Copiar"
	aActions := { {STR0003, "F24DEDVIS"}, {STR0004, "F24DEDINC"}, {STR0005, "F24DEDALT"}, {STR0006, "F24DEDEXC"}}		//"Visualizar"###"Incluir"###"Alterar"###"Excluir"
	aRotina := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de retenção
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel     As Object
	Local oCabeca    As Object
	Local oDetailFOV As Object
	Local oDetailF7R As Object
	Local aRelFKV    As Array
	Local aRelF7R    As Array
	Local lTableF7R  As Logical
	
	//Inicializa variáveis.
	aRelFKV := {}
	aRelF7R := {}
	lTableF7R := FTemF7R()
	
	oCabeca    := FxStruct(1, cTblBrowse, Nil, Nil, {}, Nil)		
	oDetailFOV := FxStruct(1, "FOV",      Nil, Nil, {}, Nil)
	If lTableF7R
		oDetailF7R := FxStruct(1, "F7R",      Nil, Nil, {}, Nil)
	EndIf
	
	//Instacia o objeto
	oModel := MPFormModel():New("FINA024DED", Nil, {||F24DEDOK()}, Nil, Nil)
	
	//Adiciona uma um submodel editável/fields
	oModel:AddFields("FKVMASTER", Nil, oCabeca, Nil, Nil, Nil)
	oModel:AddGrid("FOVDETAIL",  "FKVMASTER", oDetailFOV, Nil, Nil, Nil, Nil, Nil)
	If lTableF7R
		oModel:AddGrid("F7RDETAIL",  "FKVMASTER", oDetailF7R, Nil, Nil, Nil, Nil, Nil)
	EndIf

	//Define a chave primária do modelo
	oModel:SetPrimaryKey({"FKV_FILIAL", "FKV_IDRET"})
	oModel:SetDescription(STR0001)		//"Regra de Dedução"

	//Relacionamento do model tabelas FKV -> FOV
	Aadd(aRelFKV, {"FOV_FILIAL", "xFilial('FKV')"} )
	Aadd(aRelFKV, {"FOV_IDRET",  "FKV_IDRET"} )
	oModel:SetRelation("FOVDETAIL", aRelFKV, FOV->(IndexKey(1)))
	oModel:GetModel( "FOVDETAIL" ):SetUniqueLine({"FOV_CODIGO"})

	If lTableF7R	
		oModel:GetModel( 'FOVDETAIL' ):SetOptional( .T. )	

		//Relacionamento do model tabelas FKV -> F7R
		Aadd(aRelF7R, {"F7R_FILIAL", "xFilial('FKV')"} )
		Aadd(aRelF7R, {"F7R_IDRET",  "FKV_IDRET"} )
		oModel:SetRelation("F7RDETAIL", aRelF7R, F7R->(IndexKey(1)))
		oModel:GetModel( "F7RDETAIL" ):SetUniqueLine({"F7R_TIPDED"})
		oModel:GetModel( 'F7RDETAIL' ):SetOptional( .T. )
	EndIf

	//Inicializa os campo IDRET/VERSAO
	If (__nOper != MODEL_OPERATION_UPDATE .And. __nOper != MODEL_OPERATION_DELETE)
		oCabeca:SetProperty("FKV_IDRET",   MODEL_FIELD_INIT, {||F24DEDIDR(oModel)})
	EndIf
	
	oCabeca:SetProperty("FKV_CODIGO",   MODEL_FIELD_WHEN, {|| F24FKVCOD(oModel,"FKV_CODIGO")} )

	If __nOper == MODEL_OPERATION_UPDATE
		oCabeca:SetProperty("FKV_CODIGO", MODEL_FIELD_WHEN,  {||.F.})
		oCabeca:SetProperty("FKV_DESCR",  MODEL_FIELD_WHEN, {||.T.})
		oModel:GetModel("FOVDETAIL"):SetNoUpdateLine(!__lAltAll)	
	EndIf

	If lTableF7R
		//Define validações dos campos da grid F7R
		oDetailF7R:SetProperty("F7R_VALOR", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,'F24DEDVLR()'))
	EndIf
	
	//Ativa o modelo
	oModel:SetActivate()
Return oModel

//---------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Static Function ViewDef() As Object
	Local oModel     As Object
	Local oView      As Object
	Local oCabeca    As Object
	Local oDetailFOV As Object
	Local oDetailF7R As Object
	Local lTableF7R  As Logical
	
	//Inicializa variáveis
	oModel := FWLoadModel("FINA024DED")
	oView  := FWFormView():New()
	
	lTableF7R := FTemF7R()

	oCabeca    := FxStruct(2, cTblBrowse, Nil, Nil, {"FKV_IDRET"}, Nil)
	oDetailFOV := FxStruct(2, "FOV",      Nil, Nil, {"FOV_IDRET"}, Nil)
	If lTableF7R
		oDetailF7R := FxStruct(2, "F7R",      Nil, Nil, {"F7R_IDRET"}, Nil)
	EndIf
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)

	//Cria os boxes - Cabeçalho e área de pastas
	oView:createHorizontalBox("CABECA", 20, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
	oView:createHorizontalBox("DETAIL", 80, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/)
	
	//Cria as pastas (folders)
	oView:CreateFolder("FOLDER_DETAIL", "DETAIL")
	oView:AddSheet("FOLDER_DETAIL", "ABA_A", STR0029) // Pasta A - "Por Regra Financeira"  
	If lTableF7R	
		oView:AddSheet("FOLDER_DETAIL", "ABA_B", STR0030) // Pasta B - "Por Valores Fixos"
	EndIf

	//Cria os boxes dentro de cada pasta
	oView:createHorizontalBox("BOX_GRID_FOV", 100, /*cIdOwner*/, /*lFixPixel*/, "FOLDER_DETAIL", "ABA_A")
	If lTableF7R
		oView:createHorizontalBox("BOX_GRID_F7R", 100, /*cIdOwner*/, /*lFixPixel*/, "FOLDER_DETAIL", "ABA_B")
	EndIf

	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_CABECA",  oCabeca, "FKVMASTER")
	oView:AddGrid( "GRID_DETAIL_FOV", oDetailFOV, "FOVDETAIL")
	If lTableF7R
		oView:AddGrid( "GRID_DETAIL_F7R", oDetailF7R, "F7RDETAIL")
	EndIf
	
	//Define os owners de cada view
	oView:SetOwnerView("VIEW_CABECA",   "CABECA" )
	oView:SetOwnerView("GRID_DETAIL_FOV", "BOX_GRID_FOV" )
	If lTableF7R
		oView:SetOwnerView("GRID_DETAIL_F7R", "BOX_GRID_F7R" )
	EndIf

	oDetailFOV:SetProperty("FOV_CODIGO", MVC_VIEW_LOOKUP, {||F24DEDCF3("FOV_CODIGO")})
	oDetailFOV:SetProperty("FOV_CODIGO", MVC_VIEW_ORDEM, '01')

	oDetailFOV:SetProperty("FOV_DSCRFR", MVC_VIEW_TITULO, STR0027)	//"Descr. Regra Financeira"
	oDetailFOV:SetProperty("FOV_DSCRFR", MVC_VIEW_ORDEM, '02')
	
	oView:SetDescription(STR0001)		//"Regra de Dedução"
	
	//Faz o refresh da view
	If (__nOper == MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F24CUMREF(oView)})
	EndIf
Return oView

//---------------------------------
/*/{Protheus.doc} F24DEDVIS
Define a operação de VISUALIZAÇÃO
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
FIN024CVA()
/*/
//---------------------------------
Function F24DEDVIS()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	oModel  := Nil
	__nOper := MODEL_OPERATION_VIEW
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024DED")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	FWExecView( STR0003 , "FINA024DED", MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"

	__nOper := 0
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil


//---------------------------------
/*/{Protheus.doc} F24DEDINC
Define a operação de inclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
FIN024CVA()
/*/
//---------------------------------
Function F24DEDINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	oModel  := Nil
	__nOper := MODEL_OPERATION_INSERT
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024DED")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	FWExecView( STR0004 , "FINA024DED", MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"

	__nOper := 0
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil

//---------------------------------
/*/{Protheus.doc} F24DEDALT
Define a operação de alteração
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24DEDALT()
	Local aButtons As Array
	Local cCodigo  As Character
	Local cIdRet   As Character	
	
	__nOper := MODEL_OPERATION_UPDATE	
	//Carrega o modelo de dados
	oModel := FwLoadModel("FINA024DED")
	oModel:Activate()	
	
	//Inicializa variáveis
	cIdRet    := oModel:GetValue("FKVMASTER", "FKV_IDRET")
	cCodigo   := oModel:GetValue("FKVMASTER", "FKV_CODIGO")
	__lAltAll := FinVldExc("FKN", "FKV", cIdRet, cCodigo)
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} 
	
	FWExecView(STR0005, "FINA024DED", MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )//"Alterar"
		
	__nOper := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return Nil

//---------------------------------
/*/{Protheus.doc} F24DEDEXC
Define a operação de exclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24DEDEXC()
	Local oModel   As Object
	Local aButtons As Array
	Local lExclui  As Logical
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel   := FwLoadModel("FINA024DED")
	oModel:SetOperation(MODEL_OPERATION_DELETE)
	oModel:Activate()
	lExclui		:= F24FKVVFkn(oModel) 
	
	If lExclui
		FWExecView( STR0006 ,"FINA024DED", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )	//"Excluir"
	Else
		Help(" ", 1, "FA024EXC", Nil, STR0025, 2, 0,,,,,, {STR0026})	//"Exclusão não permitida."###"Verifique se esta regra de dedução não se encontra relacionada a uma regra de cálculo"
	Endif
	
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKV->(DbSetOrder(2))
Return Nil

//---------------------------------
/*/{Protheus.doc} F024CODFKV()
Pos Validacao de preenchimento do código do registro de retenção
@author Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function F024CODFKV() As Logical
	Local lRet    As Logical
	Local oModel  As Object
	Local oFKV    As Object
	Local cCodigo As Character
	Local lAchou  As Logical
	Local cCab    As Character
	Local cDes    As Character
	Local cSol    As Character
	Local aArea   As Array
	Local nOper   As Numeric
	
	//Inicializa variáveis
	oModel  := FWModelActive()
	oFKV    := oModel:GetModel("FKVMASTER")
	cCodigo := oFKV:GetValue("FKV_CODIGO")
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""
	lRet    := .F.
	lAchou  := .F.
	nOper   := oModel:GetOperation()

	If !Empty(cCodigo)
		aArea  := FKV->(GetArea())
		FKV->(DbSetOrder(2))	// FKS_FILIAL+FKS_CODIGO+FKS_VERSAO
		If FKV->(MSSeek(xFilial('FKV')+cCodigo))
			lAchou := .T.
		Endif
		FKV->(RestArea(aArea))
	EndIf
	
	If nOper != MODEL_OPERATION_INSERT .And. nOper != OPER_COPIAR
		cCab := STR0007 //"Código"
		cDes := STR0008	//"Operação não permitida"
		cSol := STR0009	//"Este campo não pode ser alterado"
	ElseIf !FreeForUse("FKV", "FKV_CODIGO" + xFilial("FKV") + cCodigo)
		cCab := STR0007	//"Código"
		cDes := STR0010	//"O código digitado se encontra em uso"
		cSol := STR0011	//"Código se encontra reservado"
	ElseIf lAchou
		cCab := STR0007 //"Código"
		cDes := STR0012	//"O código já se encontram cadastrados"
		cSol := STR0013	//"Código já cadastrado"
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24DEDCOP()
Define operacao de Cópia de 

@author  Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDCOP()
	Local aButtons As Array
	
	aButtons     := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	__nOper      := OPER_COPIAR
	__lConfirmou := .F.
	__lFirst	 := .T.
	
	FWExecView( STR0002 , "FINA024DED", OP_COPIA,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )

	__lConfirmou := .F.
	__nOper      := 0

	FKV->(DbSetOrder(2))
Return

/*/{Protheus.doc} F24DEDIDR()
Inicializador do campo FKV_IDRET
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDIDR(oModel As Object)
	Local cRet   As Character
	Local aArea  As Array
	Local cChave As Character
	
	//Inicializa variáveis
	cRet   := ""
	cChave := ""
	
	If (__nOper != MODEL_OPERATION_UPDATE .And. __nOper != MODEL_OPERATION_DELETE)
		aArea  := FKV->(GetArea())
		
		While .T.
			cRet := FWUUIDV4()
			FKV->(DbSetOrder(1))
			cChave := (xFilial("FKV") + cRet)  
			If !(FKV->(MsSeek(cChave))) .And. FreeForUse("FKV", cRet)
				FKV->(RestArea(aArea))
				Exit	
			Endif
		EndDo
		
		RestArea(aArea)
		
		If __nOper == OPER_COPIAR .And. __lFirst
			If oModel == Nil
				oModel  := FWModelActive()
			EndIf
			
			oModel:LoadValue("FKVMASTER", "FKV_CODIGO", " ")
			oModel:LoadValue("FKVMASTER", "FKV_DESCR",  " ")
			__lFirst := .F.
		EndIf	
	Else
		cRet := FKV->FKV_IDRET
	EndIf

Return cRet

//---------------------------------------
/*/{Protheus.doc} F24DEDCF3()
Consulta Padrao F3

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDCF3(cCampo As Character)
	Local cRet As Character
	
	//Inicializa variáveis
	cRet := "FKK"
	
Return cRet 

//---------------------------------------
/*/{Protheus.doc} F024CODFOV()
Valida retorno da  

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F024CODFOV() As Logical 
	Local cCodigo As Character
	Local oModel  As Object
	Local oFOV    As Object
	Local lRet    As Logical
	Local aArea   As Array 
	
	Default cCodigo := ""
	
	//Inicializa variáveis
	lRet  := .T.
	
	oModel  := FWModelActive()
	oFOV    := oModel:GetModel("FOVDETAIL")
	cCodigo := oFOV:GetValue("FOV_CODIGO")	
	
	If !Empty(cCodigo)
		aArea := GetArea()
		FKK->(DbSetOrder(2))
		If !FKK->(DbSeek(xFilial("FKK") + cCodigo))
			Help(" ", 1, "F24REGRAFIN", Nil, STR0014 + cCodigo + STR0015,2,0,,,,,, {STR0016})	//"Regra Financeira de Retenção: "###" não cadastrada"###"Cadastre a Regra Financeira de Retenção"
			lRet := .F.
		EndIf
		RestArea(aArea)
	EndIf

Return lRet 

//---------------------------------------
/*/{Protheus.doc} F24DEDINI()
Inicicia padrão campo virtual FOV_DSCRFR

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDINI()
	Local oModel  As Object
	Local oFOV    As Object
	Local cCodigo As Character
	Local cRet    As Character
	Local aArea   As Array
	
	//Inicializa variáveis
	cRet    := ""
	oModel  := FWModelActive()
	oFOV    := oModel:GetModel("FOVDETAIL")
	cCodigo := oFOV:GetValue("FOV_CODIGO")	

	If oFOV:NLINE != 0
		aArea	:= FKK->(GetArea())
		FKK->(DbSetOrder(2))
		FKK->(DbGoTop())
		While !(FKK->(Eof()))
		 	If cCodigo == FKK->FKK_CODIGO
				If dDatabase >= FKK->FKK_VIGINI .And. dDatabase <= FKK->FKK_VIGFIM 
					cRet	:= FKK->FKK_DESCR
					Exit
				EndIf
				FKK->(DbSkip())
			Else
				FKK->(DbSkip())
			EndIf
		EndDo
		RestArea(aArea)
	EndIf
	
	If __nOper != MODEL_OPERATION_INSERT .And. !Empty(cCodigo)
		cRet := Iif(Empty(cRet), STR0028, cRet)		//"Regra financeira não possui uma versão vigente"
	EndIf
Return cRet

//---------------------------------------
/*/{Protheus.doc} F24DEDVIR()
Preenche os campos virtuais da Grid
  
@author Rodrigo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDVIR()
	Local cRet   As Character
	Local oModel As Object
	Local oFOV   As Object
	Local aArea	 As Array
	Local cCodigo As Character
	
	//Inicializa variáveis
	cRet    := ""
	oModel  := FWModelActive()
	oFOV    := oModel:GetModel("FOVDETAIL")

	If __nOper != MODEL_OPERATION_INSERT
		cCodigo := FOV->FOV_CODIGO
		aArea	:= FKK->(GetArea())
		FKK->(DbSetOrder(2))
		FKK->(DbGoTop())
		While !(FKK->(Eof()))
		 	If cCodigo == FKK->FKK_CODIGO
				If dDatabase >= FKK->FKK_VIGINI .And. dDatabase <= FKK->FKK_VIGFIM 
					cRet	:= FKK->FKK_DESCR
					Exit
				EndIf
				FKK->(DbSkip())
			Else
				FKK->(DbSkip())
			EndIf
		EndDo
		RestArea(aArea)

		cRet := Iif(Empty(cRet) .And. !Empty(cCodigo), STR0028, cRet)		//"Regra financeira não possui uma versão vigente"
	EndIf

Return cRet 

//---------------------------------------
/*/{Protheus.doc} FIN024PDD()
Valida o percentual de dedução  

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function FIN024PDD()
	Local lRet     As Logical
	Local oModel   As Object
	Local oFOV     As Object
	Local nPercDed As Numeric
	Local cCod	   As Character
	
	oModel   := FWModelActive()
	oFOV     := oModel:GetModel("FOVDETAIL")
	nPercDed := oFOV:GetValue("FOV_PERDED")
	cCod	 := oFOV:GetValue("FOV_CODIGO")
	lRet     := POSITIVO(oFOV:GetValue("FOV_PERDED"))
	
	If !Empty(cCod) .And. (!lRet .Or. nPercDed > 100)
		If nPercDed > 100
			Help(" ", 1, "F24PERCDED", Nil, STR0017, 2, 0,,,,,, {STR0018})	//"O percentual para dedução não pode ser maior 100"###"Informe um percentual para dedução válido"
			lRet := .F.
		Else 
			Help(" ", 1, "F24PERCDED", Nil,STR0019, 2, 0,,,,,, {STR0020})	// "O percentual para dedução não pode ser negativo"###"Informe um percentual para dedução positivo"
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} F24DEDVLR
Validacao do campo F7R_VALOR

@author Fabio Casagrande Lima
@since 26/01/2026

@return Logico
/*/
//-------------------------------------------------------------------
Function F24DEDVLR() As Logical
	Local lRet As Logical
	Local oModel As Object

	oModel := FWModelActive()
	lRet := POSITIVO(oModel:GetValue('F7RDETAIL','F7R_VALOR'))
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24DEDREF()
Atualiza a visualização dos dados na view
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDREF(oView As Object)
	oView:Refresh()
Return .T.

//---------------------------------------
/*/{Protheus.doc} F24DEDOK()
Pós Validação do model 

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24DEDOK()
	Local lRet As Logical
	Local oModel As Object
	Local oFOV As Object
	
	//Inicializa variáveis
	lRet := .T.
	
	oModel   := FWModelActive()
	oFOV     := oModel:GetModel("FOVDETAIL")
	
	If lRet
		lRet := FIN024PDD()
	EndIf
	
	If lRet .And. !Empty(oFOV:GetValue("FOV_CODIGO")) .And. Empty(oFOV:GetValue("FOV_PERDED"))
		Help(" ", 1, "F24PERCDED", Nil, STR0021, 2, 0,,,,,, {STR0022})	//"O percentual para dedução não foi informado"###"Informe um percentual para dedução"
		lRet := .F.
	EndIf 
	
	If lRet .And. !Empty(oFOV:GetValue("FOV_CODIGO")) .And. Empty(oFOV:GetValue("FOV_TIPDED"))
		Help(" ", 1, "F24PERCDED", Nil, STR0023, 2, 0,,,,,, {STR0024})		//"O tipo de dedução não foi informado"###"Informe um tipo de dedução"
		lRet := .F.
	EndIf 	
	
	__lConfirmou := lRet
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24FKVVFkn()
Valida permissão de Exclusão

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
STATIC Function F24FKVVFkn(oModel As Object) As Logical
	Local lRet As Logical
	Local cIdRet As Character
	Local cQuery As Character

	DEFAULT oModel	:= 	FWModelActive()

	lRet := .T.
	cQuery := ''
	cIdRet := oModel:GetValue("FKVMASTER","FKV_IDRET")

	cQuery := ""

	If __oPrepFKP == NIL
		cQuery := "SELECT FKN_IDFKV IDRETFKV

		cQuery += " FROM "+RetSqlName('FKN')+" FKN "
		cQuery += " WHERE "
		cQuery += " FKN.FKN_IDFKV = ? AND"
		cQuery += " FKN.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		__oPrepFKP:=FWPreparedStatement():New(cQuery)
	Endif
		
	__oPrepFKP:SetString(1,cIdRet)
	cQuery := __oPrepFKP:GetFixQuery()
			
	lRet := Empty(MpSysExecScalar(cQuery,"IDRETFKV"))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F24FKVCOD()
Valida permissão de Exclusão

@author Rodrigo Oliveira
@since	03/10/2018
@version 12
/*/
//-------------------------------------------------------------------
STATIC Function F24FKVCOD(oModel As Object, cCampo As Character) As Logical
	Local lRet As Logical
	Local nOper As Numeric
	
	DEFAULT oModel := NIL
	DEFAULT cCampo := ""
	
	If oModel == Nil
		oModel   := FWModelActive()
	EndIf

	nOper := oModel:GetOperation()
	lRet := .T.
	
	If __lFirst .And. nOper == OPER_COPIAR .And. cCampo == "FKV_CODIGO"
		oModel:LoadValue("FKVMASTER", "FKV_CODIGO", "")
		oModel:LoadValue("FKVMASTER", "FKV_DESCR", "")
		__lFirst	:= .F.
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} FTemF7R()
Verifica se a tabela F7R está disponível no ambiente
@author fabio.casagrande
@since	28/01/2026
@version 12
/*/
//---------------------------------------
Static Function FTemF7R()
	If __lTblF7R == Nil
		__lTblF7R := AliasIndic("F7R")
	EndIf
Return __lTblF7R
