#INCLUDE "FWMVCDEF.CH"                 
#Include "PROTHEUS.ch"
#Include "TMSAE60.ch"

Static lRestRepom := SuperGetMV("MV_VSREPOM",,"1") == "2.2"	//-- aqui vercom o carlao como ficou pra descobrir a versao da repom

/*{Protheus.doc} TMSAE60B
    Cadastro das Operadoras de Frota
    @type Function
    @author Valdemar Roberto Mognon
    @since 26/07/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSAE60B()
    (examples)
    @see (links_or_references)
*/

Function TMSAE60B()

Private aOperac  := {}
Private aMovOper := {}
Private aRotina  := MenuDef()

oBrowse:= FwMBrowse():New()
oBrowse:SetAlias("DEG")
oBrowse:SetDescription(STR0001)	//-- "Gerenciadores de Frota (Operadores)"
oBrowse:Activate()

Return Nil

/*{Protheus.doc} Menudef
    Define as Opções de Menu
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 26/07/2023
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
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAE60B" OPERATION 2 ACCESS 0	//-- "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAE60B" OPERATION 3 ACCESS 0	//-- "Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAE60B" OPERATION 4 ACCESS 0	//-- "Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAE60B" OPERATION 5 ACCESS 0	//-- "Excluir"

Return aRotina

/*{Protheus.doc} Modeldef
    Define a Model
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 26/07/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ModelDef()
    (examples)
    @see (links_or_references)
*/

Static Function ModelDef()
Local oModel   := Nil
Local oStruDEG := FwFormStruct(1,"DEG")
Local oStruDEH := FwFormStruct(1,"DEH")
Local oStruDEI := FwFormStruct(1,"DEI")
Local oStruDEJ := FwFormStruct(1,"DEJ")
Local oStruDEM := FwFormStruct(1,"DEM")
Local oStruDNK := FwFormStruct(1,"DNK")

//-- Remove campos das Models
RemoveFld(oStruDEH,{"DEH_CODOPE","DEH_NOMOPE"})
RemoveFld(oStruDEI,{"DEI_CODOPE","DEI_NOMOPE"})
RemoveFld(oStruDEJ,{"DEJ_CODOPE","DEJ_NOMOPE"})
RemoveFld(oStruDEM,{"DEM_CODOPE","DEM_NOMOPE"})

//-- Fixa os Valids dos campos
FixValid(oStruDEG,"TMSE60BVld('DEG')","DEG")
FixValid(oStruDEI,"TMSE60BVld('DEI')","DEI")
FixValid(oStruDEJ,"TMSE60BVld('DEJ')","DEJ")
FixValid(oStruDEM,"TMSE60BVld('DEM')","DEM")

//-- Monta Gatilhos
MntTrigger(oStruDEJ,{{{"DEJ_SERTMS"},{"DEJ_DESSVT"}}})
MntTrigger(oStruDEJ,{{{"DEJ_TIPTRA"},{"DEJ_DESTPT"}}})
MntTrigger(oStruDEJ,{{{"DEJ_OPERAC"},{"DEJ_DESOPE"}}})

MntTrigger(oStruDEM,{{{"DEM_CODMOV"},{"DEM_DESMOV"}}})
MntTrigger(oStruDEM,{{{"DEM_SERTMS"},{"DEM_DESSVT"}}})
MntTrigger(oStruDEM,{{{"DEM_TIPTRA"},{"DEM_DESTPT"}}})
MntTrigger(oStruDEM,{{{"DEM_ACAO"}  ,{"DEM_DACAO"}}})

//-- Define a Model
oModel := MPFormModel():New("TMSAE60B",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)
oModel:SetDescription(STR0001)	//-- "Gerenciadores de Frota (Operadores)"

//-- Cabeçalho das Operadoras de Frota
oModel:AddFields("MdFieldDEG",/*cOwner*/,oStruDEG,/*bPre*/,/*bPost*/,/*bLoad*/)

//-- Operadoras de Frota x Produto
oModel:AddGrid("MdGridDEH","MdFieldDEG",oStruDEH,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDEH",{{"DEH_FILIAL","xFilial('DEH')"},;
								{"DEH_CODOPE","DEG_CODOPE"}},;
								DEH->(IndexKey(1)))
oModel:GetModel("MdGridDEH"):SetOptional(.T.)
oModel:GetModel("MdGridDEH"):SetDescription(STR0026)	//-- "Operadoras de Frota x Produto"
oModel:GetModel("MdGridDEH"):SetUniqueLine({"DEH_CODPRO"})

//-- "Operadoras de Frota x Município"
oModel:AddGrid("MdGridDEI","MdFieldDEG",oStruDEI,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDEI",{{"DEI_FILIAL","xFilial('DEI')"},;
								{"DEI_CODOPE","DEG_CODOPE"}},;
								DEI->(IndexKey(1)))
oModel:GetModel("MdGridDEI"):SetOptional(.T.)
oModel:GetModel("MdGridDEI"):SetDescription(STR0028)	//-- "Operadoras de Frota x Município"
oModel:GetModel("MdGridDEI"):SetUniqueLine({"DEI_CDRORI"})

//-- "Operações x Operadora de Frota"
oModel:AddGrid("MdGridDEJ","MdFieldDEG",oStruDEJ,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDEJ",{{"DEJ_FILIAL","xFilial('DEJ')"},;
								{"DEJ_CODOPE","DEG_CODOPE"}},;
								DEJ->(IndexKey(1)))
oModel:GetModel("MdGridDEJ"):SetOptional(.T.)
oModel:GetModel("MdGridDEJ"):SetDescription(STR0029)	//-- "Operações x Operadora de Frota"
oModel:GetModel("MdGridDEJ"):SetUniqueLine({"DEJ_SERTMS","DEJ_TIPTRA"})

//-- "Operadoras de Frota x Ações"
oModel:AddGrid("MdGridDEM","MdFieldDEG",oStruDEM,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDEM",{{"DEM_FILIAL","xFilial('DEM')"},;
								{"DEM_CODOPE","DEG_CODOPE"}},;
								DEM->(IndexKey(1)))
oModel:GetModel("MdGridDEM"):SetOptional(.T.)
oModel:GetModel("MdGridDEM"):SetDescription(STR0030)	//-- "Operadoras de Frota x Ações"
oModel:GetModel("MdGridDEM"):SetUniqueLine({"DEM_CODMOV","DEM_SERTMS","DEM_TIPTRA","DEM_ACAO"})

//-- Versão por End Point
oModel:AddGrid("MdGridDNK","MdFieldDEG",oStruDNK,/*bPre*/,/*bPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:SetRelation("MdGridDNK",{{"DNK_FILIAL","xFilial('DNK')"},;
								{"DNK_CODOPE","DEG_CODOPE"}},;
								DNK->(IndexKey(1)))
oModel:GetModel("MdGridDNK"):SetOptional(.T.)
oModel:GetModel("MdGridDNK"):SetDescription(STR0027)	//-- "Versão por End Point"
oModel:GetModel("MdGridDNK"):SetUniqueLine({"DNK_METODO","DNK_ENDPNT"})

Return oModel

/*{Protheus.doc} ViewDef
    Define a View
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 26/07/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ViewDef()
    (examples)
    @see (links_or_references)
*/

Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAE60B")
Local oView    := Nil
Local oStruDEG := FwFormStruct(2,"DEG")
Local oStruDEH := FwFormStruct(2,"DEH")
Local oStruDEI := FwFormStruct(2,"DEI")
Local oStruDEJ := FwFormStruct(2,"DEJ")
Local oStruDEM := FwFormStruct(2,"DEM")
Local oStruDNK := FwFormStruct(2,"DNK")

//-- Remove campos das Views
RemoveFld(oStruDEH,{"DEH_CODOPE","DEH_NOMOPE"})
RemoveFld(oStruDEI,{"DEI_CODOPE","DEI_NOMOPE"})
RemoveFld(oStruDEJ,{"DEJ_CODOPE","DEJ_NOMOPE"})
RemoveFld(oStruDEM,{"DEM_CODOPE","DEM_NOMOPE"})
 
//-- Define a View
oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a Tela Principal
oView:CreateHorizontalBox("Tela",100)

//-- Cria os Folders da Tela Principal
oView:CreateFolder("Folder1","Tela")

oView:AddSheet("Folder1","Sheet1_Folder1",STR0001)	//-- "Gerenciadores de Frota (Operadores)"
oView:AddSheet("Folder1","Sheet2_Folder1",STR0026)	//-- "Operadoras de Frota x Produto"
oView:AddSheet("Folder1","Sheet3_Folder1",STR0028)	//-- "Operadoras de Frota x Município"
oView:AddSheet("Folder1","Sheet4_Folder1",STR0029)	//-- "Operações x Operadora de Frota"
oView:AddSheet("Folder1","Sheet5_Folder1",STR0030)	//-- "Operadoras de Frota x Ações"
oView:AddSheet("Folder1","Sheet6_Folder1",STR0027)	//-- "Versão por End Point"

//-- Dimensiona a Tela
oView:CreateHorizontalBox("Operadora",100,,,"Folder1","Sheet1_Folder1")
oView:CreateHorizontalBox("Produto"  ,100,,,"Folder1","Sheet2_Folder1")
oView:CreateHorizontalBox("Municipio",100,,,"Folder1","Sheet3_Folder1")
oView:CreateHorizontalBox("Operacao" ,100,,,"Folder1","Sheet4_Folder1")
oView:CreateHorizontalBox("Acao"     ,100,,,"Folder1","Sheet5_Folder1")
oView:CreateHorizontalBox("End_Point",100,,,"Folder1","Sheet6_Folder1")

//-- Cabeçalho das Operadoras de Frota
oView:AddField("VwFieldDEG",oStruDEG,"MdFieldDEG") 
oView:SetOwnerView("VwFieldDEG","Operadora")
oView:EnableTitleView("VwFieldDEG",STR0001)	//-- "Gerenciadores de Frota (Operadores)"

//-- Operadoras de Frota x Produto
oView:AddGrid("VwGridDEH",oStruDEH,"MdGridDEH")
oView:SetOwnerView("VwGridDEH","Produto")
oView:EnableTitleView("VwGridDEH",STR0026)	//-- "Operadoras de Frota x Produto"
oView:AddIncrementField("VwGridDEH","DEH_ITEM")

//-- "Operadoras de Frota x Município"
oView:AddGrid("VwGridDEI",oStruDEI,"MdGridDEI")
oView:SetOwnerView("VwGridDEI","Municipio")
oView:EnableTitleView("VwGridDEI",STR0028)	//-- "Operadoras de Frota x Município"
oView:AddIncrementField("VwGridDEI","DEI_ITEM")

//-- "Operações x Operadora de Frota"
oView:AddGrid("VwGridDEJ",oStruDEJ,"MdGridDEJ")
oView:SetOwnerView("VwGridDEJ","Operacao")
oView:EnableTitleView("VwGridDEJ",STR0029)	//-- "Operações x Operadora de Frota"
oView:AddIncrementField("VwGridDEJ","DEJ_ITEM")

//-- "Operadoras de Frota x Ações"
oView:AddGrid("VwGridDEM",oStruDEM,"MdGridDEM")
oView:SetOwnerView("VwGridDEM","Acao")
oView:EnableTitleView("VwGridDEM",STR0030)	//-- "Operadoras de Frota x Ações"
oView:AddIncrementField("VwGridDEM","DEM_ITEM")

//-- Versão por End Point
oView:AddGrid("VwGridDNK",oStruDNK,"MdGridDNK")
oView:SetOwnerView("VwGridDNK","End_Point")
oView:EnableTitleView("VwGridDNK",STR0027)	//-- "Versão por End Point"

Return oView

/*{Protheus.doc} TmsNewOper
    Verifica se esta sendo utilizada a nova operadora de frotas
    @type Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TmsNewOper()
    (examples)
    @see (links_or_references)
*/

Function TmsNewOper()
Local lRet   := .F. 
Local oModel := Nil

If Left(FunName(),7) == "TMSAE60B" .Or. IsInCallStack("TMSAE60B")
	lRet := .T. 
Else
	oModel := FwModelActive()
	If oModel != Nil .And. AllTrim(Upper(oModel:cID)) == "TMSAE60B" .And. oModel:IsActive()	//--- Nova operadora de frotas
		lRet := .T. 
	EndIf
EndIf

Return lRet 

/*{Protheus.doc} FixValid
    Altera o valid dos campos
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
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

		If cTabela $ "DEG:DEI:DEJ"
			lFixValid := "TMSAE60VLD()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
		ElseIf cTabela $ "DEM"
			lFixValid := "TMSAE65VLD()" $ UPPER(AllTrim(GetSX3Cache(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],"X3_VALID")))
		EndIf

		If lFixValid
			oStruct:SetProperty(aCampos[nCntFor1,MODEL_FIELD_IDFIELD],MODEL_FIELD_VALID,bCodigo)
		EndIf
	EndIf
Next nCntFor1

Return

/*{Protheus.doc} TMSE60BVld
    Chama a validação dos campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSE60BVld(cOrigem,cCampo)
    (examples)
    @see (links_or_references)
*/

Function TMSE60BVld(cOrigem,cCampo)
Local lRet   := .T.
Local oModel := FwModelActive()

Default cOrigem := ""
Default cCampo  := ReadVar()

If cOrigem == "DEG"
	lRet := ValidDEG(cCampo,oModel)
ElseIf cOrigem == "DEI"
	lRet := ValidDEI(cCampo,oModel)
ElseIf cOrigem == "DEJ"
	lRet := ValidDEJ(cCampo,oModel)
ElseIf cOrigem == "DEM"
	lRet := ValidDEM(cCampo,oModel)
EndIf

Return lRet

/*{Protheus.doc} ValidDEG
    Valida os campos da DEG
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ValidDEG(cCampo,oModel)
    (examples)
    @see (links_or_references)
*/

Static Function ValidDEG(cCampo,oModel)
Local lRet       := .T.
Local lRestRepom := .T.
Local oMdFldDEG

Default cCampo := ReadVar()
Default oModel := FwModelActive()

oMdFldDEG := oModel:GetModel("MdFieldDEG")

If AllTrim(cCampo) $ "M->DEG_FILCTR"
	lRet := ExistCpo("SM0",cEmpAnt + oMdFldDEG:GetValue("DEG_FILCTR"))
ElseIf AllTrim(cCampo) $ "M->DEG_TMPESP"
	If Empty(oMdFldDEG:GetValue("DEG_TMPESP"))
		If lRestRepom .And. oMdFldDEG:GetValue("DEG_CODOPE") == "01"
			Help("",1,"OBRIGAT2",,GetSX3Cache("DEG_TMPESP","X3_TITULO"),04,01)
			lRet:= .F.
		EndIf
	Else
		lRet:= IsNumeric(oMdFldDEG:GetValue("DEG_TMPESP"))
	EndIf
ElseIf AllTrim(cCampo) $ "M->DEG_GERCTC"
	If Empty(oMdFldDEG:GetValue("DEG_GERCTC"))
		If lRestRepom .And. oMdFldDEG:GetValue("DEG_CODOPE") == "01"
			Help("",1,"OBRIGAT2",,GetSX3Cache("DEG_GERCTC","X3_TITULO"),04,01)
			lRet:= .F.
		EndIf
	EndIf
ElseIf AllTrim(cCampo) $ "M->DEG_USAAGE"
	If !Pertence(" 12")
		Help("",1,"TMSAE6011")	//-- Somente serão aceitos branco, 1=Sim, 2=Não. ### Digite 1 ou 2, ou deixe em branco.
		lRet := .F.
	Else
		If oMdFldDEG:GetValue("DEG_USAAGE") == "1" .And. oMdFldDEG:GetValue("DEG_AUTPAG") == "1"
			Help("",1,"TMSAE6010")	//-- "Não é possível que o uso do agendamento e a autorização de pagamento estejam ativos ao mesmo tempo."
			lRet := .F.
		EndIf
	EndIf
ElseIf AllTrim(cCampo) $ "M->DEG_AUTPAG"
	If !Pertence(" 12")
		Help("",1,"TMSAE6011")	//-- Somente serão aceitos branco, 1=Sim, 2=Não. ### Digite 1 ou 2, ou deixe em branco.
		lRet := .F.
	Else
		If oMdFldDEG:GetValue("DEG_AUTPAG") == "1" .And. oMdFldDEG:GetValue("DEG_USAAGE") == "1"
			Help("",1,"TMSAE6010")	//-- "Não é possível que o uso do agendamento e a autorização de pagamento estejam ativos ao mesmo tempo."
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*{Protheus.doc} ValidDEI
    Valida os campos da DEI
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ValidDEI(cCampo,oModel)
    (examples)
    @see (links_or_references)
*/

Static Function ValidDEI(cCampo,oModel)
Local lRet      := .T.
Local nLinha    := 0
Local oMdGrdDEI

Default cCampo := ReadVar()
Default oModel := FwModelActive()

oMdGrdDEI := oModel:GetModel("MdGridDEI")
nLinha    := oMdGrdDEI:GetLine()

If AllTrim(cCampo) $ "M->DEI_MUN"
	lRet := .T. //TmsValField("M->DEI_CODOPE",.T.,"DEI_NOMOPE")
ElseIf AllTrim(cCampo) $ "M->DEI_CDRORI"
	lRet := ExistCpo("DUY",oMdGrdDEI:GetValue("DEI_CDRORI",nLinha),1) 
EndIf

Return lRet

/*{Protheus.doc} ValidDEJ
    Valida os campos da DEJ
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ValidDEJ(cCampo,oModel)
    (examples)
    @see (links_or_references)
*/

Static Function ValidDEJ(cCampo,oModel)
Local lRet      := .T.
Local nLinha    := 0
Local oMdGrdDEJ

Default cCampo := ReadVar()
Default oModel := FwModelActive()

oMdGrdDEJ := oModel:GetModel("MdGridDEJ")
nLinha    := oMdGrdDEJ:GetLine()

If AllTrim(cCampo) $ "M->DEJ_SERTMS"
	lRet := TmsValField("M->DEJ_SERTMS",.T.,"DEJ_DESSVT")
ElseIf AllTrim(cCampo) $ "M->DEJ_TIPTRA"
	lRet := TmsValField("M->DEJ_TIPTRA",.T.,"DEJ_DESTPT")
ElseIf AllTrim(cCampo) $ "M->DEJ_OPERAC"
	If Empty(aOperac) .And. !Empty(oMdGrdDEJ:GetValue("DEJ_OPERAC",nLinha))
		TMSOper(.F.,oMdGrdDEJ:GetValue("DEJ_OPERAC",nLinha))
	EndIf
	
	If !Empty(aOperac)
		If AScan(aOperac,{|x| AllTrim(x[1]) == AllTrim(oMdGrdDEJ:GetValue("DEJ_OPERAC",nLinha))}) == 0
			Help("",1,"TMSAE6003")	//-- "Operação Inválida!"
			lRet := .F.
		EndIf
	Else
		Help("",1,"TMSAE6004")	//-- "Problemas na Comunicação com a Operadora impedem a Validação do Campo!"
	EndIf
EndIf

Return lRet

/*{Protheus.doc} ValidDEM
    Valida os campos da DEM
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 28/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example ValidDEM(cCampo,oModel)
    (examples)
    @see (links_or_references)
*/

Static Function ValidDEM(cCampo,oModel)
Local lRet      := .T.
Local nLinha    := 0
Local oMdGrdDEM

Default cCampo := ReadVar()
Default oModel := FwModelActive()

oMdGrdDEM := oModel:GetModel("MdGridDEM")
nLinha    := oMdGrdDEM:GetLine()

If AllTrim(cCampo) $ "M->DEM_CODMOV"
	MsgRun(STR0007,STR0008,{|| CursorWait(),lRet := TMSE60BMov(.T.,oMdGrdDEM:GetValue("DEM_CODMOV",nLinha)),CursorArrow()})	//-- "Obtendo a lista de Movimentos X Operadora de Frotas" ### "Aguarde..."
ElseIf AllTrim(cCampo) $ "M->DEM_SERTMS"
	lRet := TMSValField("M->DEM_SERTMS",.T.,"DEM_DESSVT")
ElseIf AllTrim(cCampo) $ "M->DEM_TIPTRA"
	lRet := TMSValField("M->DEM_TIPTRA",.T.,"DEM_DESTPT")
ElseIf AllTrim(cCampo) $ "M->DEM_TIPMOV"
	If !Pertence("ER")
		Help("",1,"TMSAE6012")	//-- Somente são aceitos E=Envio, R=Recebimento. ### Digite E ou R.
		lRet := .F.
	EndIf
ElseIf AllTrim(cCampo) $ "M->DEM_ACAO"
	lRet := TmsValField("M->DEM_ACAO",.T.,"DEM_DACAO")
ElseIf AllTrim(cCampo) $ "M->DEM_FORMUL"
	lRet := A370VerForm()
EndIf

Return lRet

/*{Protheus.doc} RemoveFld
    Remove campos da estrutura
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example RemoveFld(oStruct,aCampos)
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

/*{Protheus.doc} TMSE60BMov
    Obtem a lista de movimentos atraves do webservice
    @type Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSE60BMov(lValida,cCodMov)
    (examples)
    @see (links_or_references)
    TMSE65Movtos do TMSAE65
*/

Function TMSE60BMov(lValida,cCodMov)
Local lRet       := .T.
Local lTMSXML    := GetMV("MV_TMSXML",,.F.)
Local cError     := ""
Local cWarning   := ""
Local aAreas     := {DEG->(GetArea()),GetArea()}
Local aMsgErr    := {}
Local aVisErr    := {}
Local oObj       := NIL
Local oModel     := FwModelActive()
Local oMdFldDEG  := oModel:GetModel("MdFieldDEG")
Local nAux       := 0
Local nPosCodMov := 0

Default lValida  := .F.
Default cCodMov  := ""

If Empty(aMovOper)
	If Empty(oMdFldDEG:GetValue("DEG_CODOPE"))
		Help("",1,"TMSAE6509")	// --"E necessario informar o Codigo da Operadora de Frotas para verificar os Movimentos disponiveis"
		lRet := .F.
	Else
		If oMdFldDEG:GetValue("DEG_CODOPE") == "01"	//-- REPOM Tecnologia
			If !lRestRepom
				//-- Aciona o WebService
				oObj := WSIntegracao():New()
				oObj:cStrCliente           := AllTrim(oMdFldDEG:GetValue("DEG_IDOPE"))
				oObj:cStrAssinaturaDigital := AllTrim(oMdFldDEG:GetValue("DEG_CODACE"))
				oObj:_URL                  := oMdFldDEG:GetValue("DEG_URLWS")	//-- Seta a URL conforme cadastro da Operadora

				If oObj:ConsultaMovimentos()
					If oObj:lConsultaMovimentosResult
						//-- Realiza tratamento no XML de retorno, removendo os acentos e caracteres incompativeis
						oObj:cStrXMLOut := TMSNoAcento(oObj:cStrXMLOut)
						
						//-- Gera XML em Disco
						If lTMSXML
							TMSLogXML(oObj:cStrXMLOut,"ConsultaMovimentosResult.XML")
						EndIf

						//-- Coverte em Objeto o XML de retorno enviado pela Operadora
						oXML := XMLParser(oObj:cStrXMLOut,"_",@cError,@cWarning)
			
						//-- Adiciona os Movimentos para montagem da Consulta Padrao
						If XMLChildCount(oXML:_Movimentos) > 0
							If ValType(oXML:_Movimentos:_Movimento) == "A"
								For nAux := 1 To Len(oXML:_Movimentos:_Movimento)
									AAdd(aMovOper,{oXML:_Movimentos:_Movimento[nAux]:_Movimento_Codigo:Text,;
												   oXML:_Movimentos:_Movimento[nAux]:_Movimento_Descricao:Text})
								Next
							Else
								AAdd(aMovOper,{oXML:_Movimentos:_Movimento:_Movimento_Codigo:Text,;
											   oXML:_Movimentos:_Movimento:_Movimento_Descricao:Text})
							EndIf
						EndIf
					Else
						aMsgErr := TMSErrOper(oMdFldDEG:GetValue("DEG_CODOPE"),oObj:cStrXMLErr,"1")
						lRet := .F.
					EndIf
				Else
					aMsgErr := TMSErrOper(oMdFldDEG:GetValue("DEG_CODOPE"),,"2")
					lRet := .F.
				EndIf
			Else
				aMovOper:= GetMov()
			EndIf
		EndIf
	EndIf
EndIf

If !lValida
	If !Empty(aMovOper)

		nItem := TmsF3Array({GetSX3Cache("DEM_CODMOV","X3_TITULO"),;
							 GetSX3Cache("DEM_DESMOV","X3_TITULO")},;
							 aMovOper,STR0001)	//-- Operadoras de Frota X Acoes
		If nItem > 0
			//-- VAR_IXB eh utilizada como retorno da consulta F3
			VAR_IXB := aMovOper[nItem,1]
		Else
			lRet    := .F.
		EndIF
	Else
		If lRet
			Help("",1,"TMSAE6511")	//-- "Nao foram encontrados movimentos para esta Operadora"
			lRet := .F.
		EndIf
	EndIf
Else
	If !Empty(aMovOper)
		nPosCodMov := AScan(aMovOper,{|x| AllTrim(x[1]) == AllTrim(cCodMov)})
		If nPosCodMov == 0
			Help("",1,"TMSAE6512")	//-- "O codigo do Movimento informado nao e valido!"
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
EndIf

If !lRet .And. !Empty(aMsgErr)
	//-- Carrega o Array com as mensagens de Erro
	AaddMsgErr(aMsgErr,aVisErr)
	If !Empty(aVisErr)
		TmsMsgErr(aVisErr)
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} GetMov
    Consulta o Método GET /Movement/GetMovement
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example GetMov()
    (examples)
    @see (links_or_references)
    TM65GetMov do TMSAE65
*/

Static Function GetMov()
Local aRet     := {}
Local aRetOper := {}
Local nI       := 0
Local nPos     := 0
Local cIdent   := ""
Local cDesc    := ""
Local oRepom   := Nil

oRepom := TMSBCARepomFrete():New()

If oRepom:Auth()
    aRet := oRepom:GetMovement()
    For nI := 1 To Len(aRet)
		If nPos := aScan(aRet[nI],{|x| x[1] $ "IDENTIFIER"})
			cIdent := aRet[nI][nPos][2]
			cDesc  := ""

			If nPos:= aScan(aRet[nI],{|x| x[1] $ "DESCRIPTION"})
			   cDesc:= aRet[nI,nPos,2]
			EndIf
							
			If !Empty(cIdent)
				AAdd(aRetOper,{cIdent,AllTrim(Decodeutf8(cDesc))})
			EndIf
		EndIf
    Next nI
EndIf

oRepom:Destroy()

FwFreeObj(oRepom)
FwFreeArray(aRet)

Return aRetOper

/*{Protheus.doc} TMSE60BOpe
    Acessa o webservice para obter as operações da operadora
    @type Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSE60BOpe(cCodOpe,lRet)
    (examples)
    @see (links_or_references)
    F3TMSOper do TMSAE60
*/

Function TMSE60BOpe(cCodOpe,lRet)
Local cError     := ""
Local cWarning   := ""
Local nAux       := 0
Local aMsgErr    := {}
Local lTMSXML    := GetMV("MV_TMSXML",,.F.)
Local oModel     := FwModelActive()
Local oMdFldDEG  := oModel:GetModel("MdFieldDEG")
Local oObj
Local oXML

lRet := .T.

If cCodOpe == "01" .And. AllTrim(SuperGetMV("MV_VSREPOM",,"1")) != "2.2"
    //-- PREPARACAO PARA CONECTAR AO WS - REPOM
	oObj := WSIntegracao():New()
	oObj:cStrCliente           := AllTrim(oMdFldDEG:GetValue("DEG_IDOPE"))
	oObj:cstrAssinaturaDigital := AllTrim(oMdFldDEG:GetValue("DEG_CODACE"))
	oObj:_URL                  := oMdFldDEG:GetValue("DEG_URLWS")   //-- Seta a URL para acesso aos servicos da Operadora

	If oObj:ConsultaOperacoes()
		If oObj:lConsultaOperacoesResult

			//-- Remove acentos e caracteres especiais
			oObj:cStrXMLOut := TMSNoAcento(oObj:cStrXMLOut)

			//-- Gera XML em disco
			If lTMSXML
				TMSLogXML(oObj:cStrXMLOut,"ConsultaOperacoesResult.XML")
			EndIf

			//-- Gera o Objeto XML ref. ao script
			oXML := XmlParser(oObj:cStrXMLOut,"_",@cError,@cWarning)

			If XMLChildCount(oXML:_Operacoes) > 0
				If ValType(oXML:_Operacoes:_Operacao) == "A"
					For nAux := 1 To Len(oXML:_OPERACOES:_OPERACAO)
						AAdd(aOperac,{oXML:_OPERACOES:_OPERACAO[nAux]:_OPERACAO_CODIGO:Text,;
									  oXML:_OPERACOES:_OPERACAO[nAux]:_OPERACAO_DESCRICAO:Text})
					Next
					ASort(aOperac,,,{|x,y| Val(x[1]) < Val(y[1])})
				Else
					AAdd(aOperac,{oXML:_OPERACOES:_OPERACAO:_OPERACAO_CODIGO:Text,;
								  oXML:_OPERACOES:_OPERACAO:_OPERACAO_DESCRICAO:Text})
				EndIf
			EndIf
		Else
			aMsgErr := TMSErrOper(cCodOpe,oObj:cStrXMLErr,"1")
			lRet := .F.
		EndIf
	Else
		aMsgErr := TMSErrOper(cCodOpe,,"2")
		lRet := .F.
	EndIf
EndIf

//-- Trata os erros ocorridos na comunicacao com a Operadora
If !lRet .And. !Empty(aMsgErr)
	TmsMsgErr(aMsgErr)
EndIf

Return aOperac

/*{Protheus.doc} TMSE60BGet
    Consulta operação na Repom - Versao 2.2  (GET /Operation)
    @type Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSE60BGet(cCodOpe,lRet)
    (examples)
    @see (links_or_references)
    F3GETOper do TMSAE60
*/

Function TMSE60BGet(cCodOpe,lRet)
Local aMsgErr := {}
Local aOperac := {}
Local aRet    := {}
Local nX      := 0

lRet := .T.

If cCodOpe == "01"
	aRet:= TM15GetOpe()  

	For nX:= 1 To Len(aRet)
		AAdd(aOperac,{aRet[nx,1],aRet[nx,2]})
	Next nX

	If Len(aOperac) == 0
		aMsgErr := TMSErrOper(cCodOpe,"","1")
		lRet := .F.
	EndIf
else
	lRet := .F.
EndIf

//-- Trata os erros ocorridos na comunicacao com a Operadora
If !lRet .And. !Empty(aMsgErr)
	TmsMsgErr(aMsgErr)
EndIf

FWFreeArray(aRet)

Return aOperac

/*{Protheus.doc} MntTrigger
    Monta a Estrutura da Trigger
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
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
								  "TMA060BGat('" + cDominio + "', '" + cContra + "')"	,; // Regra de Preenchimento
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

/*{Protheus.doc} TMA060BGat
    Chama Funções de Gatilho
    @type Function
    @author Valdemar Roberto Mognon
    @since 29/08/2023
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMA060BGat(cCampo,cDest)
    (examples)
    @see (links_or_references)
*/
Function TMA060BGat(cCampo,cDest)
Local xRet      := Nil
Local nLinha    := 0
Local oModel    := FwModelActive()
Local oMdGrdDEJ := oModel:GetModel("MdGridDEJ")
Local oMdGrdDEM := oModel:GetModel("MdGridDEM")

Default cCampo := ReadVar()

If !Empty(cDest)
	If cCampo $ "M->DEJ_SERTMS" 
		xRet := TMSValField("M->DEJ_SERTMS",.F.,"DEJ_DESSVT")
	ElseIf cCampo $ "M->DEJ_TIPTRA"
		xRet := TMSValField("M->DEJ_TIPTRA",.F.,"DEJ_DESTPT")
	ElseIf cCampo $ "M->DEJ_OPERAC"
		If (nLinha := Ascan(aOperac,{|x| AllTrim(x[1]) == AllTrim(oMdGrdDEJ:GetValue("DEJ_OPERAC"))})) > 0
			xRet := aOperac[nLinha,2]
		EndIf
	ElseIf cCampo $ "M->DEM_CODMOV"
		If (nLinha := Ascan(aMovOper,{|x| AllTrim(x[1]) == AllTrim(oMdGrdDEM:GetValue("DEM_CODMOV"))})) > 0
			xRet := aMovOper[nLinha,2]
		EndIf
	ElseIf cCampo $ "M->DEM_SERTMS" 
		xRet := TMSValField("M->DEM_SERTMS",.F.,"DEM_DESSVT")
	ElseIf cCampo $ "M->DEM_TIPTRA"
		xRet := TMSValField("M->DEM_TIPTRA",.F.,"DEM_DESTPT")
	ElseIf cCampo $ "M->DEM_ACAO"
		xRet := TMSValField("M->DEM_ACAO",.F.,"DEM_DACAO")
	EndIf
EndIf

Return xRet
