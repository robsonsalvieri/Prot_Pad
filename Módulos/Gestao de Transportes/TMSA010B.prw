#INCLUDE "FWMVCDEF.CH"                 
#Include "PROTHEUS.ch"
#Include "TMSA010.ch"

Static lContHis := SuperGetMV("MV_CONTHIS",,.T.)	//-- Controla Historico da Tabela de Frete
Static cCatTab  := ""
Static aLayout  := {}

/*{Protheus.doc} TMSA010B
    Cadastro da Tabela de Fretes
    @type Function
    @author Valdemar Roberto Mognon
    @since 20/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA010B()
    (examples)
    @see (links_or_references)
*/

Function TMSA010B(cCateg)

Private aRotina := MenuDef()

Default cCateg := "1"

cCatTab := cCateg

oBrowse:= FwMBrowse():New()
oBrowse:SetAlias("DT0")
oBrowse:SetDescription(OemToAnsi(STR0001))	//-- "Tabela de Frete"
oBrowse:Activate()

Return Nil

/*{Protheus.doc} Menudef
    Cadastro da Tabela de Fretes
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example Menudef()
    (examples)
    @see (links_or_references)
*/

Static Function MenuDef()

Private aRotina := {}
     
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0	//-- "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSA010B" OPERATION 2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "TMA010BInc"       OPERATION 3 ACCESS 0	//-- "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSA010B" OPERATION 4 ACCESS 0	//-- "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSA010B" OPERATION 5 ACCESS 0	//-- "Excluir"
ADD OPTION aRotina TITLE STR0070 ACTION "TMA010BPrc"       OPERATION 3 ACCESS 0	//-- "Compatibiliza Tabelas"

Return aRotina

/*{Protheus.doc} Modeldef
    Define a model
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example Modeldef()
    (examples)
    @see (links_or_references)
*/

Static Function ModelDef()
Local oModel   := Nil
Local oStruDT0 := FwFormStruct(1,"DT0")
Local oStruDNJ := FwFormStruct(1,"DNJ")
Local oStruDT1 := FwFormStruct(1,"DT1")
Local oStruDTK := FwFormStruct(1,"DTK")
Local oStruDW1 := FwFormStruct(1,"DW1")
Local oStruDY1 := FwFormStruct(1,"DY1")
Local oStruDVY := FwFormStruct(1,"DVY")
Local oStruDJS := FwFormStruct(1,"DJS")

Local bLinPreGrd := {|oModel,nLine,cAction,cIDField,xValue,xCurrentValue| TMA010BPre(oModel,nLine,cAction,cIDField,xValue,xCurrentValue,"DT1")}
Local bCommit    := {|oModel| TMA010BGrv(oModel)}

//-- Fixa os Valids dos campos
FixValid(oStruDT0,"TMA010BVld('DT0')","DT0")

//-- Fixa os Whens dos campos
FixWhen(oStruDT1,"TMA010BWhe('DT1')","DT1")
FixWhen(oStruDTK,"TMA010BWhe('DTK')","DTK")
FixWhen(oStruDW1,"TMA010BWhe('DW1')","DW1")
FixWhen(oStruDY1,"TMA010BWhe('DY1')","DY1")
FixWhen(oStruDVY,"TMA010BWhe('DVY')","DVY")
FixWhen(oStruDJS,"TMA010BWhe('DJS')","DJS")

//-- Monta Gatilhos
MntTrigger(oStruDT0,{{{"DT0_CDRORI","DT0_CDRDES","DT0_CODPRO"},{"DT0_CDRORI"}}})
MntTrigger(oStruDT0,{{{"DT0_TABTAR"},{"DT0_TABTAR"}}})

//-- Inicializa Valores Conforme Configuração Escolhida
If FwIsInCallStack("TMA010BInc")
	TMA010BIni(@oStruDT0)
EndIf

//-- Define a Model
oModel := MPFormModel():New("TMSA010B",/*bPre*/,/*bPos*/,bCommit,/*bCancel*/)
oModel:SetDescription(STR0001)	//-- "Tabela de Frete"

//-- Cabeçalho da Tabela de Frete
oModel:AddFields("MdFieldDT0",/*cOwner*/,oStruDT0,/*bPre*/,/*bPost*/,/*bLoad*/)

//-- Componentes da Tabela de Frete
oModel:AddGrid("MdGridDNJ","MdFieldDT0",oStruDNJ,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDNJ",{{"DNJ_FILIAL","xFilial('DNJ')"},;
								{"DNJ_TABFRE","DT0_TABFRE"},;
								{"DNJ_TIPTAB","DT0_TIPTAB"},;
								{"DNJ_CDRORI","DT0_CDRORI"},;
								{"DNJ_CDRDES","DT0_CDRDES"},;
								{"DNJ_CODPRO","DT0_CODPRO"}},;
								DNJ->(IndexKey(1)))
oModel:GetModel("MdGridDNJ"):SetDescription(STR0061)	//-- "Componentes de Frete"
oModel:GetModel("MdGridDNJ"):SetNoInsertLine(.T.)
oModel:GetModel("MdGridDNJ"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridDNJ"):SetNoUpdateLine(.T.)

//-- Faixas dos Componentes da Tabela de Frete
oModel:AddGrid("MdGridDT1","MdGridDNJ",oStruDT1,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDT1",{{"DT1_FILIAL","xFilial('DT1')"},;
								{"DT1_TABFRE","DT0_TABFRE"},;
								{"DT1_TIPTAB","DT0_TIPTAB"},;
								{"DT1_CDRORI","DT0_CDRORI"},;
								{"DT1_CDRDES","DT0_CDRDES"},;
								{"DT1_CODPRO","DT0_CODPRO"},;
								{"DT1_CODPAS","DNJ_CODPAS"}},;
								DT1->(IndexKey(1)))
oModel:GetModel("MdGridDT1"):SetDescription(STR0059)	//-- "Tabela de Frete - Itens para o Componente"
oModel:GetModel("MdGridDT1"):SetOptional(.T.)

//-- Complemento da Tabela de Frete
oModel:AddGrid("MdGridDTK","MdGridDNJ",oStruDTK,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDTK",{{"DTK_FILIAL","xFilial('DTK')"},;
								{"DTK_TABFRE","DT0_TABFRE"},;
								{"DTK_TIPTAB","DT0_TIPTAB"},;
								{"DTK_CDRORI","DT0_CDRORI"},;
								{"DTK_CDRDES","DT0_CDRDES"},;
								{"DTK_CODPRO","DT0_CODPRO"},;
								{"DTK_CODPAS","DNJ_CODPAS"}},;
								DTK->(IndexKey(1)))
oModel:GetModel("MdGridDTK"):SetDescription(STR0019)	//-- "Complemento Tabela de Frete"
oModel:GetModel("MdGridDTK"):SetOptional(.T.)
oModel:GetModel("MdGridDTK"):SetNoInsertLine(.T.)

//-- Sub-Faixas da Tabela de Frete
oModel:AddGrid("MdGridDW1","MdGridDT1",oStruDW1,bLinPreGrd,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDW1",{{"DW1_FILIAL","xFilial('DW1')"},;
								{"DW1_TABFRE","DT0_TABFRE"},;
								{"DW1_TIPTAB","DT0_TIPTAB"},;
								{"DW1_CDRORI","DT0_CDRORI"},;
								{"DW1_CDRDES","DT0_CDRDES"},;
								{"DW1_CODPRO","DT0_CODPRO"},;
								{"DW1_CODPAS","DNJ_CODPAS"},;
								{"DW1_ITEDT1","DT1_ITEM"  }},;
								DW1->(IndexKey(1)))
oModel:GetModel("MdGridDW1"):SetDescription(STR0067)	//-- "Sub-Faixas da Tabela de Frete"
oModel:GetModel("MdGridDW1"):SetOptional(.T.)

//-- Complemento de Sub-Faixa
oModel:AddGrid("MdGridDY1","MdGridDT1",oStruDY1,bLinPreGrd,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDY1",{{"DY1_FILIAL","xFilial('DW1')"},;
								{"DY1_TABFRE","DT0_TABFRE"},;
								{"DY1_TIPTAB","DT0_TIPTAB"},;
								{"DY1_CDRORI","DT0_CDRORI"},;
								{"DY1_CDRDES","DT0_CDRDES"},;
								{"DY1_CODPRO","DT0_CODPRO"},;
								{"DY1_CODPAS","DNJ_CODPAS"},;
								{"DY1_ITEDT1","DT1_ITEM"  }},;
								DY1->(IndexKey(1)))
oModel:GetModel("MdGridDY1"):SetDescription(STR0051)	//-- "Complemento de Sub-Faixa"
oModel:GetModel("MdGridDY1"):SetOptional(.T.)

//-- Base de Taxa de Difícil Acesso
oModel:AddGrid("MdGridDVY","MdGridDNJ",oStruDVY,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDVY",{{"DVY_FILIAL","xFilial('DVY')"},;
								{"DVY_TABFRE","DT0_TABFRE"},;
								{"DVY_TIPTAB","DT0_TIPTAB"},;
								{"DVY_CDRORI","DT0_CDRORI"},;
								{"DVY_CDRDES","DT0_CDRDES"},;
								{"DVY_CODPRO","DT0_CODPRO"},;
								{"DVY_CODPAS","DNJ_CODPAS"}},;
								DVY->(IndexKey(1)))
oModel:GetModel("MdGridDVY"):SetDescription(STR0050)	//-- "Base Componente Taxa de Dificil Acesso"
oModel:GetModel("MdGridDVY"):SetOptional(.T.)
oModel:GetModel("MdGridDVY"):SetNoInsertLine(.T.)

//-- Base de Cálculo x Componente de Frete
oModel:AddGrid("MdGridDJS","MdGridDNJ",oStruDJS,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDJS",{{"DJS_FILIAL","xFilial('DJS')"},;
								{"DJS_TABFRE","DT0_TABFRE"},;
								{"DJS_TIPTAB","DT0_TIPTAB"},;
								{"DJS_CDRORI","DT0_CDRORI"},;
								{"DJS_CDRDES","DT0_CDRDES"},;
								{"DJS_CODPRO","DT0_CODPRO"},;
								{"DJS_CODTRT","DNJ_CODPAS"}},;
								DJS->(IndexKey(1)))
oModel:GetModel("MdGridDJS"):SetDescription(STR0066)	//-- "Base Percentual Total por Componente"
oModel:GetModel("MdGridDJS"):SetOptional(.T.)
oModel:GetModel("MdGridDJS"):SetNoDeleteLine(.T.)
oModel:GetModel("MdGridDJS"):SetNoInsertLine(.T.)

oModel:SetVldActivate({ |oModel| VldInicial(oModel)})

oModel:SetActivate({|oModel| TMA010BScr(oModel)})

Return oModel

/*{Protheus.doc} Viewdef
    Define a model
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example Viewdef()
    (examples)
    @see (links_or_references)
*/

Static Function ViewDef()
Local oModel   := FwLoadModel("TMSA010B")
Local oView    := Nil
Local oStruDT0 := FwFormStruct(2,"DT0")
Local oStruDNJ := FwFormStruct(2,"DNJ")
Local oStruDT1 := FwFormStruct(2,"DT1")
Local oStruDTK := FwFormStruct(2,"DTK")
Local oStruDW1 := FwFormStruct(2,"DW1")
Local oStruDY1 := FwFormStruct(2,"DY1")
Local oStruDVY := FwFormStruct(2,"DVY")
Local oStruDJS := FwFormStruct(2,"DJS")

//-- Altera descrição dos campos
oStruDT1:SetProperty("DT1_FATPES",3,STR0074)	//-- "Até Fator"
oStruDW1:SetProperty("DW1_FATPES",3,STR0074)	//-- "Até Fator"

//-- Retira Campos da Estrutura
RemoveFld(oStruDNJ,{"DNJ_TABFRE","DNJ_TIPTAB","DNJ_CDRORI","DNJ_CDRDES","DNJ_CODPRO"})

RemoveFld(oStruDT1,{"DT1_TABFRE","DT1_TIPTAB","DT1_CDRORI","DT1_CDRDES","DT1_CODPRO","DT1_CODPAS"})

RemoveFld(oStruDTK,{"DTK_TABFRE","DTK_TIPTAB","DTK_CDRORI","DTK_CDRDES","DTK_CODPRO","DTK_CALPAS","DTK_APLAJU"})

RemoveFld(oStruDW1,{"DW1_TABFRE","DW1_TIPTAB","DW1_CDRORI","DW1_CDRDES","DW1_CODPRO","DW1_CODPAS","DW1_ITEDT1"})

RemoveFld(oStruDY1,{"DY1_TABFRE","DY1_TIPTAB","DY1_CDRORI","DY1_CDRDES","DY1_CODPRO","DY1_CODPAS","DY1_ITEDT1"})

RemoveFld(oStruDVY,{"DVY_TABFRE","DVY_TIPTAB","DVY_CDRORI","DVY_CDRDES","DVY_CODPRO"})

RemoveFld(oStruDJS,{"DJS_TABFRE","DJS_TIPTAB","DJS_CDRORI","DJS_CDRDES","DJS_CODPRO","DJS_CODTRT"})

//-- Define a View
oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define tela tipo WEB
//oView:SetContinuousForm()

//-- Define a Tela Principal
oView:CreateHorizontalBox("Tela",100)

//-- Cria os Folders da Tela Principal
oView:CreateFolder("Folder1","Tela")

oView:AddSheet("Folder1","Sheet1_Folder1",STR0001)	//-- "Tabela de Frete"
oView:AddSheet("Folder1","Sheet2_Folder1",STR0073)	//-- "Faixa"
oView:AddSheet("Folder1","Sheet3_Folder1",STR0037)	//-- "Subfaixa"
oView:AddSheet("Folder1","Sheet4_Folder1",STR0068)	//-- "Outros"

//-- Dimensiona a Tela
oView:CreateHorizontalBox("Tabela"     ,040,,,"Folder1","Sheet1_Folder1")
oView:CreateHorizontalBox("Componentes",060,,,"Folder1","Sheet1_Folder1")

oView:CreateHorizontalBox("Faixas"     ,060,,,"Folder1","Sheet2_Folder1")
oView:CreateHorizontalBox("Complemento",040,,,"Folder1","Sheet2_Folder1")

oView:CreateHorizontalBox("SubFaixa"   ,060,,,"Folder1","Sheet3_Folder1")
oView:CreateHorizontalBox("ComplSub"   ,040,,,"Folder1","Sheet3_Folder1")

oView:CreateHorizontalBox("Dificil"    ,040,,,"Folder1","Sheet4_Folder1")
oView:CreateHorizontalBox("CompTRT"    ,060,,,"Folder1","Sheet4_Folder1")

//-- Cria o Cabeçalho
oView:AddField("VwFieldDT0",oStruDT0,"MdFieldDT0") 
oView:SetOwnerView("VwFieldDT0","Tabela")
oView:EnableTitleView("VwFieldDT0",STR0001)	//-- "Tabela de Frete"

//-- Cria o Grid de Componentes da Tabela de Frete
oView:AddGrid("VwGridDNJ",oStruDNJ,"MdGridDNJ")
oView:SetOwnerView("VwGridDNJ","Componentes")
oView:EnableTitleView("VwGridDNJ",STR0061)	//-- "Componentes de Frete"
//-- Define Propriedade de Pesquisa no Grid
oView:SetViewProperty("VwGridDNJ","GRIDSEEK",{.T.})

//-- Faixas dos Componentes da Tabela de Frete
oView:AddGrid("VwGridDT1",oStruDT1,"MdGridDT1")
oView:SetOwnerView("VwGridDT1","Faixas")
oView:EnableTitleView("VwGridDT1",STR0059)	//-- "Tabela de Frete - Itens para o Componente"
oView:AddIncrementField("VwGridDT1","DT1_ITEM")

//-- Complemento da Tabela de Frete
oView:AddGrid("VwGridDTK",oStruDTK,"MdGridDTK")
oView:SetOwnerView("VwGridDTK","Complemento")
oView:EnableTitleView("VwGridDTK",STR0019)	//-- "Complemento Tabela de Frete"

//-- Sub-Faixas da Tabela de Frete
oView:AddGrid("VwGridDW1",oStruDW1,"MdGridDW1")
oView:SetOwnerView("VwGridDW1","SubFaixa")
oView:EnableTitleView("VwGridDW1",STR0067)	//-- "Sub-Faixas da Tabela de Frete"
oView:AddIncrementField("VwGridDW1","DW1_ITEM")

//-- Complemento de Sub-Faixa
oView:AddGrid("VwGridDY1",oStruDY1,"MdGridDY1")
oView:SetOwnerView("VwGridDY1","ComplSub")
oView:EnableTitleView("VwGridDY1",STR0051)	//-- "Complemento de Sub-Faixa"
oView:AddIncrementField("VwGridDY1","DY1_ITEM")

//-- Base de Taxa de Difícil Acesso
oView:AddGrid("VwGridDVY",oStruDVY,"MdGridDVY")
oView:SetOwnerView("VwGridDVY","Dificil")
oView:EnableTitleView("VwGridDVY",STR0050)	//-- "Base Componente Taxa de Dificil Acesso"

//-- Base de Cálculo x Componente de Frete
oView:AddGrid("VwGridDJS",oStruDJS,"MdGridDJS")
oView:SetOwnerView("VwGridDJS","CompTRT")
oView:EnableTitleView("VwGridDJS",STR0066)	//-- "Base Percentual Total por Componente"

Return oView

/*{Protheus.doc} FixValid
    Altera validação dos campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 21/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example FixValid(oStruct,cFuncao)
    (examples)
    @see (links_or_references)
*/
Static Function FixValid(oStruct,cFuncao,cTabela)
Local nCntFor1  := 0
Local aCampos   := {}
Local lFixValid := .T.
Local bCodigo

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_VALID,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	If GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_PROPRI") <> "U"
		If cTabela $ "DT0"
			lFixValid := "TMSA010TAR()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
			If !lFixValid
				lFixValid := "TMSA010VLD()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
			EndIf
		EndIf

		If lFixValid
			oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_VALID,bCodigo)
		EndIf
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} TMA010BVld
    Executa validações
    @type Function
    @author Valdemar Roberto Mognon
    @since 21/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BVld()
    (examples)
    @see (links_or_references)
*/
Function TMA010BVld(cOrigem,cCampo)
Local lRet := .T.

Default cOrigem := ""
Default cCampo  := ReadVar()

If AllTrim(cOrigem) == "DT0"
	If AllTrim(cCampo) $ "M->DT0_TABTAR"
		lRet := .T.
	ElseIf AllTrim(cCampo) $ "M->DT0_CODPRO"
		lRet := .T.
	EndIf
EndIf

Return lRet

/*{Protheus.doc} TMA010BInc
    Carrega configurações da Tabela de Frete
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BInc()
    (examples)
    @see (links_or_references)
*/

Function TMA010BInc()

aLayout := TMSLayOutTab(cCatTab,.T.,,{"15"})
If TMSABrowse(aLayOut,STR0020,,,,.T.,{STR0001,STR0021,STR0058})	//-- "Escolha a Configuracao desta Tabela de Frete" ### "Tabela de Frete" ### "Tipo "###" Descricao"
	FWExecView("","TMSA010B",MODEL_OPERATION_INSERT,,,,,)
EndIf

Return

/*{Protheus.doc} RemoveFld
    Remove fieldes de uma View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 21/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example RemoveFld(oStruct,aFields)
    (examples)
    @see (links_or_references)
*/
Static Function RemoveFld(oStruct,aCampos)
Local nCntFor1 := 0

Default oStruct := Nil
Default aCampos := {}

For nCntFor1 := 1 To Len(aCampos)
	&("oStruct:RemoveField('" + aCampos[nCntFor1] + "')")
Next nCntFor1

Return

/*{Protheus.doc} TMA010BIni
    Inicializa Valores na Inclusão
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BIni()
    (examples)
    @see (links_or_references)
*/

Function TMA010BIni(oStruDT0)
Local aAreas := {DTL->(GetArea()),GetArea()}
Local nSeek  := 0

//-- Cabeçalho da Tabela de Frete
nSeek := Ascan(aLayout,{|x| x[1] == .T.})
oStruDT0:SetProperty("DT0_TABFRE",MODEL_FIELD_INIT,{|| PadL(aLayout[nSeek,2],Len(DT0->DT0_TABFRE))})
oStruDT0:SetProperty("DT0_TIPTAB",MODEL_FIELD_INIT,{|| Left(aLayout[nSeek,3],Len(DT0->DT0_TIPTAB))})
oStruDT0:SetProperty("DT0_DESTAB",MODEL_FIELD_INIT,{|| aLayout[nSeek,4]})
oStruDT0:SetProperty("DT0_MOEDA" ,MODEL_FIELD_INIT,{|| Posicione("DTL",1,xFilial("DTL") + PadL(aLayout[nSeek,2],Len(DT0->DT0_TABFRE)) + ;
																							Left(aLayout[nSeek,3],Len(DT0->DT0_TIPTAB)),"DTL_MOEDA")})

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} TMA010BScr
    Inicializa Valores nas Operações Diferentes de Inclusão
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 24/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BScr()
    (examples)
    @see (links_or_references)
*/

Function TMA010BScr(oModel)
Local aAreas     := {DT3->(GetArea()),DTK->(GetArea()),DVY->(GetArea()),DJS->(GetArea()),GetArea()}
Local oMdGrdDNJ  := oModel:GetModel("MdGridDNJ")
Local oMdGrdDTK  := oModel:GetModel("MdGridDTK")
Local oMdGrdDVY  := oModel:GetModel("MdGridDVY")
Local oMdGrdDJS  := oModel:GetModel("MdGridDJS")
Local nOpcx      := oModel:GetOperation()
Local nCntFor1   := 0
Local cCodPas    := ""
Local cDesPas    := ""
Local cTipFai    := ""

If nOpcx == 4	//-- Alteração

	oMdGrdDVY:SetNoInsertLine(.F.)
	oMdGrdDJS:SetNoInsertLine(.F.)

	For nCntFor1 := 1 To oMdGrdDNJ:Length()
		oMdGrdDNJ:Goline(nCntFor1)
		cCodPas := oMdGrdDNJ:GetValue("DNJ_CODPAS",nCntFor1)
		cDesPas := Posicione("DT3",1,xFilial("DT3") + cCodPas,"DT3_DESCRI")
		cTipFai := DT3->DT3_TIPFAI
		DTK->(DbSetOrder(1))                      
		If !DTK->(DbSeek(xFilial("DTK") + DT0->(DT0_TABFRE + DT0_TIPTAB + DT0_CDRORI + DT0_CDRDES + DT0_CODPRO) + cCodPas))
			//-- Inclui Linha no Grid da DTK
			oMdGrdDTK:Goline(1)
			oMdGrdDTK:LoadValue("DTK_CODPAS",cCodPas)
			oMdGrdDTK:LoadValue("DTK_DESPAS",cDesPas)
			oMdGrdDTK:DeleteLine()
		EndIf
		
		DVY->(DbSetOrder(1))                      
		If !DVY->(DbSeek(xFilial("DVY") + DT0->(DT0_TABFRE + DT0_TIPTAB + DT0_CDRORI + DT0_CDRDES + DT0_CODPRO) + cCodPas))
			//-- Inclui Linha no Grid da DVY
			oMdGrdDVY:Goline(1)
		    oMdGrdDVY:LoadValue("DVY_CODPAS",cCodPas)
		    oMdGrdDVY:LoadValue("DVY_DESPAS",cDesPas)
			oMdGrdDVY:DeleteLine()
        EndIf
	Next nCntFor1

	oMdGrdDNJ:Goline(1)

	oMdGrdDVY:SetNoInsertLine(.T.)
	oMdGrdDJS:SetNoInsertLine(.T.)

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

/*{Protheus.doc} MntTrigger
    Monta a Estrutura da Trigger
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MntTrigger()
    (examples)
    @see (links_or_references)
*/
Static Function MntTrigger(oStruct,aTrigger)
Local cDominio  := ""
Local cContra   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nCntFor3  := 0
Local aAux      := {}

For nCntFor1 := 1 To Len(aTrigger)
	For nCntFor2 := 1 To Len(aTrigger[nCntFor1,1])
		cDominio := aTrigger[nCntFor1,1,nCntFor2]
		For nCntFor3 := 1 To Len(aTrigger[nCntFor1,2])
			cContra := aTrigger[nCntFor1,2,nCntFor3]

			aAux :=(FwStruTrigger(cDominio	,; // Campo de Dominio
								  cContra	,; // Campo de ContraDominio
								  "TMA010BGat('" + cDominio + "', '" + cContra + "')"	,; // Regra de Preenchimento
								  ,; // Se posicionara ou não antes da execução do gatilhos (Opcional)
								  ,; // Alias da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Ordem da tabela a ser posicionada (Obrigatorio se lSeek = .T.)
								  ,; // Chave de busca da tabela a ser posicionada (Obrigatorio se lSeek = .T)
								  )) // Condição para execução do gatilho (Opcional)

			oStruct:AddTrigger(aAux[1],;	//-- [01] Id do campo de origem
							   aAux[2],;	//-- [02] Id do campo de destino
							   aAux[3],;	//-- [03] Bloco de codigo de validação da execução do gatilho
							   aAux[4])		//-- [04] Bloco de codigo de execução do gatilho
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

FwFreeArray(aAux)

Return

/*{Protheus.doc} TMA010BGat
    Chama Funções de Gatilho
    @type Function
    @author Valdemar Roberto Mognon
    @since 22/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BGat()
    (examples)
    @see (links_or_references)
*/
Function TMA010BGat(cCampo,cDest)
Local xRet := Nil

Default cCampo := ReadVar()

If !Empty(cDest)
	If cCampo $ "M->DT0_CDRORI|M->DT0_CDRDES|M->DT0_CODPRO" 
		xRet := TMA010BGrd(cCampo,cDest,FwFldGet("DT0_CDRORI"),FwFldGet("DT0_CDRDES"),FwFldGet("DT0_CODPRO"))
	ElseIf cCampo $ "M->DT0_TABTAR" 
		xRet := TMA010BTar(cCampo,cDest,FwFldGet("DT0_TABTAR"),FwFldGet("DT0_CDRORI"),FwFldGet("DT0_CDRDES"),FwFldGet("DT0_CODPRO"))
	EndIf
EndIf

Return xRet

/*{Protheus.doc} TMA010BGrd
    Gatilha as Grids
    @type Function
    @author Valdemar Roberto Mognon
    @since 22/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BGrd()
    (examples)
    @see (links_or_references)
*/
Function TMA010BGrd(cCampo,cDest,cCdrOri,cCdrDes,cCodPro)
Local xRet       := Nil
Local aAreas     := {GetArea()}
Local aCompTab   := {}
Local nQtdDNJ    := 0
Local nQtdDJS    := 0
Local nCntFor1   := 0
Local cQuery     := ""
Local cAliasDVE  := ""
Local lTem14     := .F.
Local oModel     := FwModelActive()
Local oMdFldDT0  := oModel:GetModel("MdFieldDT0")
Local oMdGrdDNJ  := oModel:GetModel("MdGridDNJ")
Local oMdGrdDTK  := oModel:GetModel("MdGridDTK")
Local oMdGrdDVY  := oModel:GetModel("MdGridDVY")
Local oMdGrdDJS  := oModel:GetModel("MdGridDJS")

Default cCdrOri := ""
Default cCdrDes := ""

If !Empty(cCdrOri) .And. !Empty(cCdrDes)
	//-- Componentes da Tabela de Frete
	cAliasDVE := GetNextAlias()
	cQuery := " SELECT DVE_CODPAS,DT3_DESCRI,DT3_TIPFAI "
	
	cQuery += "   FROM " + RetSQLName("DVE") + " DVE "
	
	cQuery += "   JOIN " + RetSQLName("DT3") + " DT3 "
	cQuery += "     ON DT3_FILIAL = '" + xFilial("DT3") + "' "
	cQuery += "    AND DT3_CODPAS = DVE_CODPAS "
	cQuery += "    AND DT3.D_E_L_E_T_ = ' ' "
	
	cQuery += "  WHERE DVE_FILIAL = '" + xFilial("DVE") + "' "
	cQuery += "    AND DVE_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' "
	cQuery += "    AND DVE_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' "
	cQuery += "    AND DVE.D_E_L_E_T_ = ' ' "
	cQuery += "  ORDER BY DVE_ITEM "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDVE,.F.,.T.)
	
	If (cAliasDVE)->(!Eof())
	
		oModel:GetModel("MdGridDNJ"):SetNoInsertLine(.F.)
		oModel:GetModel("MdGridDNJ"):SetNoUpdateLine(.F.)
		oModel:GetModel("MdGridDTK"):SetNoInsertLine(.F.)
		oModel:GetModel("MdGridDVY"):SetNoInsertLine(.F.)
		oModel:GetModel("MdGridDJS"):SetNoInsertLine(.F.)
		oModel:GetModel("MdGridDJS"):SetNoDeleteLine(.F.)

		If oMdGrdDNJ:IsEmpty()

			DVE->(DbSetOrder(1))
	
			aCompTab := {}			
			While (cAliasDVE)->(!Eof())
				//-- Inclui Linha no Grid da DNJ
				If nQtdDNJ == 0
					nQtdDNJ := 1
				Else
					nQtdDNJ ++
					oMdGrdDNJ:Addline()
				EndIf
				oMdGrdDNJ:Goline(nQtdDNJ)
						
			    oMdGrdDNJ:LoadValue("DNJ_CODPAS",(cAliasDVE)->DVE_CODPAS)
			    oMdGrdDNJ:LoadValue("DNJ_DESPAS",(cAliasDVE)->DT3_DESCRI)
		
				//-- Inclui Linha no Grid da DTK
				oMdGrdDTK:Goline(1)
						
			    oMdGrdDTK:LoadValue("DTK_CODPAS",(cAliasDVE)->DVE_CODPAS)
			    oMdGrdDTK:LoadValue("DTK_DESPAS",(cAliasDVE)->DT3_DESCRI)
				oMdGrdDTK:DeleteLine()
		
				//-- Inclui Linha no Grid da DVY
				oMdGrdDVY:Goline(1)
						
			    oMdGrdDVY:LoadValue("DVY_CODPAS",(cAliasDVE)->DVE_CODPAS)
			    oMdGrdDVY:LoadValue("DVY_DESPAS",(cAliasDVE)->DT3_DESCRI)
				oMdGrdDVY:DeleteLine()
	
				//-- Inclui Linha no Grid da DJS
				If (cAliasDVE)->DT3_TIPFAI != "14"
					Aadd(aCompTab,{(cAliasDVE)->DVE_CODPAS,(cAliasDVE)->DT3_DESCRI})
				Else
					lTem14 := .T.
				EndIf
					
				(cAliasDVE)->(DbSkip())
			EndDo

			If lTem14	
				nQtdDJS := 0
				For nCntFor1 := 1 To Len(aCompTab)
					//-- Inclui Linha no Grid da DJS
					If nQtdDJS == 0
						nQtdDJS := 1
					Else
						nQtdDJS ++
						oMdGrdDJS:Addline()
					EndIf
					oMdGrdDJS:Goline(nQtdDJS)
							
				    oMdGrdDJS:LoadValue("DJS_CODPAS",aCompTab[nCntFor1,1])
				    oMdGrdDJS:LoadValue("DJS_DESPAS",aCompTab[nCntFor1,2])
				    oMdGrdDJS:LoadValue("DJS_PERCEN",100)
				Next nCntFor1
			EndIf
			
		EndIf
	
		oModel:GetModel("MdGridDNJ"):SetNoInsertLine(.T.)
		oModel:GetModel("MdGridDNJ"):SetNoUpdateLine(.T.)
		oModel:GetModel("MdGridDTK"):SetNoInsertLine(.T.)
		oModel:GetModel("MdGridDVY"):SetNoInsertLine(.T.)
		oModel:GetModel("MdGridDJS"):SetNoInsertLine(.T.)
		oModel:GetModel("MdGridDJS"):SetNoDeleteLine(.T.)
	
	EndIf
	
	(cAliasDVE)->(DbCloseArea())
	
	//-- Posiciona na Primeira Linha dos Componentes
	oMdGrdDNJ:GoLine(1)
	oMdGrdDTK:GoLine(1)
	oMdGrdDVY:GoLine(1)
	oMdGrdDJS:GoLine(1)
EndIf

//-- Retorna a mesma variável de entrada por se tratar de gatilho. Esta rotina serve apenas pra garantir que as regiões estejam preenchidas.
xRet := cCdrOri

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return xRet

/*{Protheus.doc} TMA010BTar
    Gatilha a Tarifa
    @type Function
    @author Valdemar Roberto Mognon
    @since 27/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BTar()
    (examples)
    @see (links_or_references)
*/
Function TMA010BTar(cCampo,cDest,cCodTar,cCdrOri,cCdrDes,cCodPro)
Local xRet       := Nil
Local aAreas     := {DTG->(GetArea()),DW0->(GetArea()),DT3->(GetArea()),DT1->(GetArea()),DTK->(GetArea()),;
					 DW1->(GetArea()),DY1->(GetArea()),DVY->(GetArea()),DJS->(GetArea()),GetArea()}
Local aCompTab   := {}
Local nLinDT1    := 0
Local nLinDJS    := 0
Local nLinDW1    := 0
Local nLinDNJ    := 0
Local nCntFor1   := 0
Local oModel     := FwModelActive()
Local oMdFldDT0  := oModel:GetModel("MdFieldDT0")
Local oMdGrdDNJ  := oModel:GetModel("MdGridDNJ")
Local oMdGrdDT1  := oModel:GetModel("MdGridDT1")
Local oMdGrdDTK  := oModel:GetModel("MdGridDTK")
Local oMdGrdDW1  := oModel:GetModel("MdGridDW1")
Local oMdGrdDY1  := oModel:GetModel("MdGridDY1")
Local oMdGrdDVY  := oModel:GetModel("MdGridDVY")
Local oMdGrdDJS  := oModel:GetModel("MdGridDJS")
Local cSeekDTG   := ""
Local cSeekDW0   := ""
Local cCodPasAnt := ""
Local cIteDTGAnt := ""
Local cDesPas    := ""
Local cTipFai    := ""
Local lSubFai    := .T.

Default cCodTar := ""
Default cCdrOri := ""
Default cCdrDes := ""
Default cCodPro := ""

If !Empty(cCodTar) .And. !Empty(cCdrOri) .And. !Empty(cCdrDes)
	DTG->(DbSetOrder(1))
	DW0->(DbSetOrder(1))
	If DTG->(DbSeek(cSeekDTG := xFilial("DTG") + oMdFldDT0:GetValue("DT0_TABFRE") + oMdFldDT0:GetValue("DT0_TIPTAB") + oMdFldDT0:GetValue("DT0_TABTAR")))

		//-- DTK
		oMdGrdDTK:SetNoInsertLine(.F.)
		//-- DVY
		oMdGrdDVY:SetNoInsertLine(.F.)
		//-- DJS
		oMdGrdDJS:SetNoInsertLine(.F.)
		//-- DY1
		oMdGrdDY1:SetNoInsertLine(.F.)

		While DTG->(!Eof()) .And. DTG->(DTG_FILIAL + DTG_TABFRE + DTG_TIPTAB + DTG_TABTAR) == cSeekDTG
			cCodPasAnt := DTG->DTG_CODPAS
			cDesPas    := Posicione("DT3",1,xFilial("DT3") + DTG->DTG_CODPAS,"DT3_DESCRI")
			cTipFai    := DT3->DT3_TIPFAI
			lSubFai    := !Empty(DT3->DT3_FAIXA2)

			While DTG->(!Eof()) .And. DTG->(DTG_FILIAL + DTG_TABFRE + DTG_TIPTAB + DTG_TABTAR + DTG_CODPAS) == cSeekDTG + cCodPasAnt
				//-- Localiza a linha do componente na DNJ
				If oMdGrdDNJ:SeekLine({{"DNJ_CODPAS",DTG->DTG_CODPAS}})
					nLinDNJ := oMdGrdDNJ:GetLine()
					oMdGrdDNJ:GoLine(nLinDNJ)

					//-- Inclui Linha no Grid do Complemento da Tabela de Frete (DTK)
					oMdGrdDTK:Goline(1)
							
				    oMdGrdDTK:LoadValue("DTK_CODPAS",DTG->DTG_CODPAS)
				    oMdGrdDTK:LoadValue("DTK_DESPAS",cDesPas)
					oMdGrdDTK:DeleteLine()
		
					//-- Inclui Linha no Grid da Base de Taxa de Difícil Acesso (DVY)
					oMdGrdDVY:Goline(1)
							
				    oMdGrdDVY:LoadValue("DVY_CODPAS",DTG->DTG_CODPAS)
				    oMdGrdDVY:LoadValue("DVY_DESPAS",cDesPas)
					oMdGrdDVY:DeleteLine()
	
					nLinDT1    := 0
					While DTG->(!Eof()) .And. DTG->(DTG_FILIAL + DTG_TABFRE + DTG_TIPTAB + DTG_TABTAR + DTG_CODPAS) == cSeekDTG + cCodPasAnt
						//-- Inclui Linha no Grid das Faixas dos Componentes da Tabela de Frete (DT1)
						If nLinDT1 == 0
							nLinDT1 := 1
						Else
							nLinDT1 ++
							oMdGrdDT1:Addline()
						EndIf
						oMdGrdDT1:Goline(nLinDT1)
	
					    oMdGrdDT1:LoadValue("DT1_ITEM"  ,DTG->DTG_ITEM)
						oMdGrdDT1:LoadValue("DT1_VALATE",DTG->DTG_VALATE)
					    oMdGrdDT1:LoadValue("DT1_FATPES",DTG->DTG_FATPES)
					    oMdGrdDT1:LoadValue("DT1_VALOR" ,DTG->DTG_VALOR)
					    oMdGrdDT1:LoadValue("DT1_INTERV",DTG->DTG_INTERV)
	
						//-- Inclui Linha no Grid da Base de Cálculo x Componente de Frete (DJS)
						If cTipFai != "14"
							Aadd(aCompTab,{DTG->DTG_CODPAS,cDesPas})
						Else
							For nCntFor1 := 1 To Len(aCompTab)
								//-- Localiza a linha do componente na DNJ
								If oMdGrdDJS:SeekLine({{"DJS_CODPAS",aCompTab[nCntFor1,1]}})
									nLinDJS := oMdGrdDJS:GetLine()
									oMdGrdDJS:GoLine(nLinDJS)
	
								    oMdGrdDJS:LoadValue("DJS_CODPAS",aCompTab[nCntFor1,1])
								    oMdGrdDJS:LoadValue("DJS_DESPAS",aCompTab[nCntFor1,2])
								    oMdGrdDJS:LoadValue("DJS_PERCEN",100)
								EndIf
							Next nCntFor1
						EndIf
	
						If lSubFai
							cIteDTGAnt := DTG->DTG_ITEM
							If DW0->(DbSeek(cSeekDW0 := xFilial("DW0") + oMdFldDT0:GetValue("DT0_TABFRE") + oMdFldDT0:GetValue("DT0_TIPTAB") + oMdFldDT0:GetValue("DT0_TABTAR") + cCodPasAnt + cIteDTGAnt))
	
								nLinDW1 := 0
								While DW0->(!Eof()) .And. DW0->(DW0_FILIAL + DW0_TABFRE + DW0_TIPTAB + DW0_TABTAR + DW0_CODPAS + DW0_ITEDTG) == cSeekDW0
									//-- Inclui Linha no Grid das Sub-Faixas da Tabela de Frete (DW1)
									If nLinDW1 == 0
										nLinDW1 := 1
									Else
										nLinDW1 ++
										oMdGrdDW1:Addline()
									EndIf
									oMdGrdDW1:Goline(nLinDW1)
											
									oMdGrdDW1:LoadValue("DW1_ITEM"  ,DW0->DW0_ITEM)
									oMdGrdDW1:LoadValue("DW1_VALATE",DW0->DW0_VALATE)
								    oMdGrdDW1:LoadValue("DW1_FATPES",DW0->DW0_FATPES)
								    oMdGrdDW1:LoadValue("DW1_VALOR" ,DW0->DW0_VALOR)
								    oMdGrdDW1:LoadValue("DW1_INTERV",DW0->DW0_INTERV)
	
									DW0->(DbSkip())
								EndDo
	
							EndIf
						EndIf
						
						DTG->(DbSkip())
					EndDo
				Else
					DTG->(DbSkip())
				EndIf
			EndDo
			
		EndDo

		//-- DTK
		oMdGrdDTK:SetNoInsertLine(.T.)
		//-- DVY
		oMdGrdDVY:SetNoInsertLine(.T.)
		//-- DJS
		oMdGrdDJS:SetNoInsertLine(.T.)
		//-- DY1
		oMdGrdDY1:SetNoInsertLine(.T.)

	EndIf
EndIf

//-- Retorna a mesma variável de entrada por se tratar de gatilho. Esta rotina serve apenas pra garantir que a tarifa esteja preenchida.
xRet := cCodTar

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return xRet

/*{Protheus.doc} TMA010BPre
    Pre-Valida as Grids
    @type Function
    @author Valdemar Roberto Mognon
    @since 22/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BPre()
    (examples)
    @see (links_or_references)
*/
Function TMA010BPre(oModelAtu,nLinha,cAcao,cCampo,nValor,nValAtu,cAlias)
Local lRet      := .T.
Local aAreas    := {DT3->(GetArea()),GetArea()}
Local oModel    := FwModelActive()
Local oMdGrdDW1 := oModel:GetModel("MdGridDW1")
Local oMdGrdDY1 := oModel:GetModel("MdGridDY1")
Local oMdGrdDJS := oModel:GetModel("MdGridDJS")

Default cAlias := ""

If cAlias == "DT1"
	DT3->(DbSetOrder(1))
	If DT3->(DbSeek(xFilial("DT3") + FwFldGet("DNJ_CODPAS")))
		//-- Sub-Faixa
		If !Empty(DT3->DT3_FAIXA2)
			oMdGrdDW1:SetNoDeleteLine(.F.)
			oMdGrdDY1:SetNoDeleteLine(.F.)
		Else
			oMdGrdDW1:SetNoDeleteLine(.T.)
			oMdGrdDY1:SetNoDeleteLine(.T.)
		EndIf
		//-- TRT
		If DT3->DT3_TIPFAI == "14"
			oMdGrdDJS:SetNoUpdateLine(.F.)
		Else
			oMdGrdDJS:SetNoUpdateLine(.T.)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} FixWhen
    Altera When na Estrutura dos Campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 07/07/2020
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example FixWhen(oStruct,cFuncao)
    (examples)
    @see (links_or_references)
*/
Static Function FixWhen(oStruct,cFuncao,cTabela)
Local nCntFor1 := 0
Local aCampos  := {}
Local bCodigo
Local lFixWhen := .T.

Default oStruct := Nil
Default cFuncao := ""
Default cTabela := ""

aCampos := oStruct:GetFields()
bCodigo := FWBuildFeature(STRUCT_FEATURE_WHEN,cFuncao)

For nCntFor1 := 1 To Len(aCampos)
	If GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_PROPRI") <> "U"
		lFixWhen:= Empty(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_WHEN"))

		If lFixWhen
			oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_WHEN,bCodigo)
		EndIf
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} TMA010BWhe
    Altera When na Estrutura dos Campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 23/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BPre(Origem)
    (examples)
    @see (links_or_references)
*/
Function TMA010BWhe(cOrigem)
Local lRet      := .T.
Local lSubFaixa := .F.
Local lTRT      := .F.
Local cCampo    := ReadVar()
Local cCampos   := ""
Local aAreas    := {DT3->(GetArea()),GetArea()}

Default cOrigem := ""

If !Empty(cOrigem)
	DT3->(DbSetOrder(1))
	If DT3->(DbSeek(xFilial("DT3") + FwFldGet("DNJ_CODPAS")))
		lSubFaixa := !Empty(DT3->DT3_FAIXA2)
		lTRT      := DT3->DT3_TIPFAI == "14"
	EndIf

	//-- Sub-Faixa
	If lSubFaixa
		If cOrigem == "DT1"
			cCampos := "M->DT1_VALATE"
			If DT3->DT3_FAIXA == StrZero(1,Len(DT3->DT3_FAIXA2))
				cCampos += ":M->DT1_FATPES"
			EndIf
			lRet := AllTrim(cCampo) $ cCampos
		ElseIf cOrigem == "DTK"
			lRet := !AllTrim(cCampo) $ "M->DTK_EXCMIN:M->DTK_VALMIN:M->DTK_VALOR:M->DTK_INTERV:M->DTK_VALMAX"
		ElseIf cOrigem == "DW1"
			cCampos := "M->DW1_VALATE:M->DW1_VALOR:M->DW1_INTERV"
			If DT3->DT3_FAIXA2 == StrZero(1,Len(DT3->DT3_FAIXA2))
				cCampos += ":M->DW1_FATPES"
			EndIf
			lRet := AllTrim(cCampo) $ cCampos
		ElseIf cOrigem == "DY1"
			lRet := AllTrim(cCampo) $ "M->DY1_EXCMIN:M->DY1_VALMIN:M->DY1_VALMAX:M->DY1_VALOR:M->DY1_INTERV"
		EndIf
	Else
		If cOrigem == "DT1"
			cCampos := "M->DT1_VALATE:M->DT1_VALOR:M->DT1_INTERV"
			If DT3->DT3_FAIXA == StrZero(1,Len(DT3->DT3_FAIXA))
				cCampos += ":M->DT1_FATPES"
			EndIf
			lRet := AllTrim(cCampo) $ cCampos
		ElseIf cOrigem == "DW1"
			lRet := !AllTrim(cCampo) $ "M->DW1_VALATE:M->DW1_FATPES:M->DW1_VALOR:M->DW1_INTERV"
		ElseIf cOrigem == "DY1"
			lRet := !AllTrim(cCampo) $ "M->DY1_EXCMIN:M->DY1_VALMIN:M->DY1_VALMAX:M->DY1_VALOR:M->DY1_INTERV"
		EndIf
	EndIf

	//-- DTK
	If cOrigem == "DTK"
		lRet := !AllTrim(cCampo) $ "M->DTK_CODPAS:M->DTK_DESPAS"
	EndIf

	//-- DVY
	If cOrigem == "DVY"
		lRet := AllTrim(cCampo) $ "M->DVY_VLBASE"
	EndIf

	//-- TRT
	If cOrigem == "DJS"
		If lTRT
			lRet := AllTrim(cCampo) $ "M->DJS_PERCEN"
		Else
			lRet := .F.
		EndIf
	EndIf

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} VldInicial
    Executa a Pré Validação do Modelo Antes das Operações
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 27/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example VldInicial()
    (examples)
    @see (links_or_references)
*/
Static Function VldInicial(oModel)
Local lRet      := .T.
Local nOpcx     := oModel:GetOperation()
Local aAreas    := {DNJ->(GetArea()),GetArea()}

If nOpcx == 4 .Or. nOpcx == 5	//-- Alteração ou Exclusão
	//-- Controla o Histórico de Tabela de Frete
	If lContHis
		//-- Verifica se a Tabela de Frete Está em Uso por um CTRC, AWB ou Cotacao de Frete não Cancelada
		If TmsTabUso(DT0->DT0_TABFRE,DT0->DT0_TIPTAB,DT0->DT0_CDRORI,DT0->DT0_CDRDES,.T.,DT0->DT0_CATTAB)
			lRet := .F.
		EndIf
	EndIf
EndIf	

If nOpcx == 3	//-- Inclusão
	//-- Cria Semaforo com o Nome TABMAN. Se Algum Usuário Estiver Incluindo Tabelas de Frete, a Rotina de Gera Tabela de Frete não Podera ser Executada
	LockByName("TABMAN",.T.,.F.)

	//-- Se a Rotina de Gera Tabela de Frete Estiver Sendo Executada, não Será Permitida a Inclusao Manual de Tabela de Frete                                             Â³
	If !LockByName("GERTAB",.T.,.F.)
		Help("",1,"TMSA01020")	//-- A Inclusao de Tabelas não Poderá ser Efetuada, pois Existe Outro Usuário Gerando Tabelas de Frete
		UnLockByName("TABMAN",.T.,.F.)	//-- Libera Lock
		lRet := .F.
	EndIf
	UnLockByName("GERTAB",.T.,.F.)	//-- Libera Lock
Else	//-- Demais operações
	DNJ->(DbSetOrder(1))
	If !DNJ->(DbSeek(xFilial("DNJ") + DT0->(DT0_TABFRE + DT0_TIPTAB)))
		Help("",1,"TMSA01027")	//-- Tabela não foi gerada por este programa. Manutenções devem ser efetuadas no programa antigo, 
								//-- ou se desejar compatibilize as tabelas de frete por meio do botão de Outras Ações.
		lRet := .F.
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMA010BGrv
    Executa a Gravação, Exclusão e Alteração do Modelo
    @type Function
    @author Valdemar Roberto Mognon
    @since 27/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BGrv(oModel)
    (examples)
    @see (links_or_references)
*/
Function TMA010BGrv(oModel)
Local lRet      := .T.
Local nOpcx     := oModel:GetOperation()
Local oMdFldDT0 := oModel:GetModel("MdFieldDT0")
Local aAreas    := {DTL->(GetArea()),GetArea()}
Local cQuery    := ""

Begin Transaction

	lRet:= FwFormCommit(oModel)

	If lRet
		If nOpcx == 5	//-- Exclusão
			//-- Exclusão dos Ajustes
			If !lContHis
				//-- Tabela de Ajustes
				cQuery := "UPDATE " + RetSqlName("DVC")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DVC_FILIAL = '" + xFilial("DVC") + "' "
				cQuery += "   AND DVC_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DVC_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DVC_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DVC_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DVC_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)

				//-- Itens da Tabela de Ajustes
				cQuery := "UPDATE " + RetSqlName("DVD")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DVD_FILIAL = '" + xFilial("DVD") + "' "
				cQuery += "   AND DVD_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DVD_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DVD_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DVD_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DVD_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)

				//-- Complemento de Ajustes
				cQuery := "UPDATE " + RetSqlName("DVO")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DVO_FILIAL = '" + xFilial("DVO") + "' "
				cQuery += "   AND DVO_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DVO_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DVO_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DVO_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DVO_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)

				//-- Sub-Faixa da Tabela de Ajustes
				cQuery := "UPDATE " + RetSqlName("DW2")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DW2_FILIAL = '" + xFilial("DW2") + "' "
				cQuery += "   AND DW2_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DW2_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DW2_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DW2_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DW2_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)

				//-- Excedente de Sub-Faixa da Tabela de Ajustes
				cQuery := "UPDATE " + RetSqlName("DY2")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DY2_FILIAL = '" + xFilial("DY2") + "' "
				cQuery += "   AND DY2_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DY2_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DY2_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DY2_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DY2_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)

				//-- Base de TDA nos Ajustes
				cQuery := "UPDATE " + RetSqlName("DWZ")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DWZ_FILIAL = '" + xFilial("DWZ") + "' "
				cQuery += "   AND DWZ_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DWZ_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DWZ_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DWZ_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DWZ_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)

				//-- Base de Cálculo x % Componentes de Frete nos Ajustes
				cQuery := "UPDATE " + RetSqlName("DJT")
				cQuery += "   SET D_E_L_E_T_ = '*' "
				cQuery += " WHERE DJT_FILIAL = '" + xFilial("DJT") + "' "
				cQuery += "   AND DJT_TABFRE = '" + oMdFldDT0:GetValue("DT0_TABFRE") + "' " 
				cQuery += "   AND DJT_TIPTAB = '" + oMdFldDT0:GetValue("DT0_TIPTAB") + "' " 
				cQuery += "   AND DJT_CDR0RI = '" + oMdFldDT0:GetValue("DT0_CDRORI") + "' " 
				cQuery += "   AND DJT_CDRDES = '" + oMdFldDT0:GetValue("DT0_CDRDES") + "' " 
				cQuery += "   AND DJT_CODPRO = '" + oMdFldDT0:GetValue("DT0_CODPRO") + "' " 
				cQuery += "   AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cQuery)
			EndIf
		Else
			DTL->(DbSetOrder(1))
			If DTL->(DbSeek(xFilial("DTL") + DT0->(DT0_TABFRE + DT0_TIPTAB)))
				RecLock("DT0",.F.)
				DT0->DT0_CATTAB := DTL->DTL_CATTAB
				DT0->(MsUnlock())
			EndIf
		EndIf
	EndIf
			
	If !lRet	
		DisarmTransaction()
		Break
	EndIf

End Transaction

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMA010BPrc
    Processa Rotinas
    @type Function
    @author Valdemar Roberto Mognon
    @since 29/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BPrc()
    (examples)
    @see (links_or_references)
*/
Function TMA010BPrc()

FWMsgRun(,{|| TMA010BCmp()},STR0071,STR0072)	//-- "Processando" # "Aguarde Compatibilização das Tabelas"

Return

/*{Protheus.doc} TMA010BCmp
    Executa a Compatibilização das Tabelas de Frete
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 29/06/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA010BCmp()
    (examples)
    @see (links_or_references)
*/
Static Function TMA010BCmp()
Local cQuery    := ""
Local cAliasDT0 := ""
Local aAreas    := {DNJ->(GetArea()),GetArea()}

If MsgYesNo(STR0069)	//-- "Confirma compatibilização das tabelas de frete?"
	cAliasDT0 := GetNextAlias()
	cQuery := " SELECT DT0_CDRORI,DT0_CDRDES,DT0_CODPRO,DVE_CODPAS "
	
	cQuery += "   FROM " + RetSQLName("DT0") + " DT0 "
	
	cQuery += "   JOIN " + RetSQLName("DVE") + " DVE "
	cQuery += "     ON DVE_FILIAL = '" + xFilial("DVE") + "' "
	cQuery += "    AND DVE_TABFRE = DT0_TABFRE "
	cQuery += "    AND DVE_TIPTAB = DT0_TIPTAB "
	cQuery += "    AND DVE.D_E_L_E_T_ = ' ' "
	
	cQuery += "  WHERE DT0_FILIAL = '" + xFilial("DT0") + "' "
	cQuery += "    AND DT0_TABFRE = '" + DT0->DT0_TABFRE + "' "
	cQuery += "    AND DT0_TIPTAB = '" + DT0->DT0_TIPTAB + "' "
	cQuery += "    AND DT0.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDT0,.F.,.T.)

	DNJ->(DbSetOrder(1))
	
	While (cAliasDT0)->(!Eof())
		If !DNJ->(DbSeek(xFilial("DNJ") + DT0->(DT0_TABFRE + DT0_TIPTAB) + (cAliasDT0)->(DT0_CDRORI + DT0_CDRDES + DT0_CODPRO + DVE_CODPAS)))
			RecLock("DNJ",.T.)
			DNJ->DNJ_FILIAL := xFilial("DNJ")
			DNJ->DNJ_TABFRE := DT0->DT0_TABFRE
			DNJ->DNJ_TIPTAB := DT0->DT0_TIPTAB
			DNJ->DNJ_CDRORI := (cAliasDT0)->DT0_CDRORI
			DNJ->DNJ_CDRDES := (cAliasDT0)->DT0_CDRDES
			DNJ->DNJ_CODPRO := (cAliasDT0)->DT0_CODPRO
			DNJ->DNJ_CODPAS := (cAliasDT0)->DVE_CODPAS
			DNJ->(MsUnlock())
		EndIf
		(cAliasDT0)->(DbSkip())
	EndDo

	(cAliasDT0)->(DbCloseArea())
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return
