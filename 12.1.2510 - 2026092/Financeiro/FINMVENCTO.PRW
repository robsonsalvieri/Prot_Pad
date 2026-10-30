#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA024VCT.CH'

/*/{Protheus.doc}FINMVENCTO
    Modelo de manutenção de vencimento de impostos
    
    @author Sivaldo Oliveira
    @since 07/08/2026
/*/
Function FINMVENCTO()
	Local aButoes As Array
    
    //Inicializa variáveis
	aButoes := {{.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.T., Nil}, {.T., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}, {.F., Nil}}
	FWExecView("" ,"FINMVENCTO", MODEL_OPERATION_UPDATE, Nil, Nil, Nil, Nil, aButoes)
Return Nil

/*/{Protheus.doc} ViewDef
    Criação do objeto de visualização
    
    @author Sivaldo Oliveira
    @since 07/08/2026
    
    @return oView, Object, Retorna um objeto de componente visual/tela
/*/
Static Function ViewDef() As Object
	Local oView      As Object
	Local oModeloDad As Object	
    Local oF7VField  As Object
	Local oF7VGrid   As Object
    
    //Inicializa variáveis
	oView      := Nil
    oModeloDad := FwLoadModel("FINMVENCTO")
	oF7VField  := FwFormViewStruct():New()
	oF7VGrid   := FwFormStruct(2, "F7V")
	
    oF7VField:AddField("FKP_FILIAL", "01", STR0029, STR0029, Nil, "C", X3Picture("FKP_FILIAL"), Nil,  Nil, .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
    oF7VField:AddField("FKP_CODIGO", "01", STR0018, STR0018, Nil, "C", X3Picture("FKP_CODIGO"), Nil,  Nil, .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
    oF7VField:AddField("FKP_DESCR",  "03", STR0030, STR0030, Nil, "C", X3Picture("FKP_DESCR"),  Nil,  Nil, .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
    oF7VField:AddField("FKP_IDRET",  "04", STR0031, STR0031, Nil, "C", X3Picture("FKP_IDRET"),  Nil,  Nil, .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
	
    oView := FwFormView():New()
	oView:SetModel(oModeloDad)
	oView:AddField("VIEW_CAB", oF7VField, "FORMMASTER")
	oView:AddGrid("VIEW_GRID", oF7VGrid,  "GRIDVENCF7V")
	
	oView:CreateHorizontalBox("BOXCABEC", 20)
	oView:CreateHorizontalBox("BOXGRID", 80)
	
    oView:SetOwnerView("VIEW_CAB",  "BOXCABEC")
	oView:SetOwnerView("VIEW_GRID", "BOXGRID")
	
    oView:EnableTitleView("VIEW_CAB",  STR0032)
	oView:EnableTitleView("VIEW_GRID", STR0033)
	oView:SetCloseOnOk({||.T.})
    
    oF7VGrid:SetProperty("F7V_CODIGO", MVC_VIEW_LOOKUP, "60")
    oF7VGrid:SetProperty("F7V_EST",    MVC_VIEW_LOOKUP, "12")
    oF7VGrid:SetProperty("F7V_CODMUN", MVC_VIEW_LOOKUP,  "CC2F7V")
    
    oF7VGrid:SetProperty("F7V_CODIGO", MVC_VIEW_TITULO, STR0034)
    oF7VGrid:SetProperty("F7V_EST",    MVC_VIEW_TITULO, STR0035)
    oF7VGrid:SetProperty("F7V_CODMUN", MVC_VIEW_TITULO, STR0036)
    oF7VGrid:SetProperty("F7V_DIAREC", MVC_VIEW_TITULO, STR0037)
    
    oF7VField:RemoveField("FKP_FILIAL")
    oF7VField:RemoveField("FKP_IDRET")
    oF7VGrid:RemoveField("F7V_IDRET")
    
    If AllTrim(FKP->FKP_TIPVCT) != "1"
        oView:SetOnlyView("VIEW_GRID", "BOXGRID")
    EndIf
Return oView

/*/{Protheus.doc}ModelDef
    Criação do modelo de dados.
    
    @author Sivaldo Oliveira
    @since 07/08/2026
    
    @return oModeloDad, Object, Retorna um objeto com modelo de dados da rotina
/*/
Static Function ModelDef() As Object
	Local aRelacao   As Array
    Local oModeloDad As Object
	Local oFKPField  As Object
	Local oF7VGrid   As Object
    
    //Inicializa variáveis
    aRelacao   := {}
    oModeloDad := Nil
    oFKPField  := FwFormModelStruct():New() 
    oF7VGrid   := FwFormStruct(1, "F7V")
    
    oFKPField:AddTable("FKP", {"FKP_CODIGO", "FKP_DESCR"}, "")	
	oFKPField:AddField(STR0029, STR0029, "FKP_FILIAL", "C", TamSX3("FKP_FILIAL")[1], 0, Nil, Nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, "FKP->FKP_FILIAL"), .F., .F.)
    oFKPField:AddField(STR0018, STR0018, "FKP_CODIGO", "C", TamSX3("FKP_CODIGO")[1], 0, Nil, Nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, "FKP->FKP_CODIGO"), .F., .F.)
    oFKPField:AddField(STR0030, STR0030, "FKP_DESCR",  "C", TamSX3("FKP_DESCR")[1],  0, Nil, Nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, "FKP->FKP_DESCR"),  .F., .F.)
    oFKPField:AddField(STR0031, STR0031, "FKP_IDRET",  "C", TamSX3("FKP_IDRET")[1],  0, Nil, Nil, {}, .F., FwBuildFeature(STRUCT_FEATURE_INIPAD, "FKP->FKP_IDRET"),  .F., .F.)
    
    oModeloDad := MPFormModel():New("FINA024VEN", Nil, {||VldGrvGrid(oModeloDad:GetModel("GRIDVENCF7V"))}, Nil)
	oModeloDad:AddFields("FORMMASTER", Nil, oFKPField)
	oModeloDad:AddGrid("GRIDVENCF7V", "FORMMASTER", oF7VGrid)
	
    AAdd(aRelacao, {"F7V_FILIAL", "xFilial('F7V')"})
    AAdd(aRelacao, {"F7V_FILIAL", "FKP_FILIAL"})
	AAdd(aRelacao, {"F7V_IDRET",  "FKP_IDRET"})
    
    oModeloDad:SetDescription(STR0038)
    oModeloDad:GetModel("FORMMASTER"):SetDescription(STR0032)    
    oModeloDad:SetRelation("GRIDVENCF7V", aRelacao, F7V->(IndexKey(1)))    
    oModeloDad:GetModel("GRIDVENCF7V"):SetUniqueLine({"F7V_FILIAL", "F7V_CODIGO", "F7V_EST", "F7V_CODMUN"})    
    oModeloDad:GetModel("GRIDVENCF7V"):SetOptional(.T.)
    
    If AllTrim(FKP->FKP_TIPVCT) != "1"
        oModeloDad:GetModel("GRIDVENCF7V"):SetNoInsertLine(.T.)
        oModeloDad:GetModel("GRIDVENCF7V"):SetNoDeleteLine(.T.)
    EndIf
    
    oModeloDad:SetPrimaryKey({"F7V_FILIAL", "F7V_CODIGO", "F7V_EST", "F7V_CODMUN"})    
    oF7VGrid:SetProperty("F7V_CODIGO", MODEL_FIELD_VALID, {||ValidDigit(oModeloDad:GetModel("GRIDVENCF7V"), "F7V_CODIGO")})
    oF7VGrid:SetProperty("F7V_EST", MODEL_FIELD_VALID,    {||ValidDigit(oModeloDad:GetModel("GRIDVENCF7V"), "F7V_EST")})
    oF7VGrid:SetProperty("F7V_CODMUN", MODEL_FIELD_VALID, {||ValidDigit(oModeloDad:GetModel("GRIDVENCF7V"), "F7V_CODMUN")})
    oModeloDad:SetActivate()
Return oModeloDad

/*/{Protheus.doc} ValidDigit
    Valida se as informações digitadas nos campos (F7V_CODIGO, F7V_EST, F7V_CODMUN)
    existem em suas respectivas tabelas de domínio CC2 e SX5
    
    @author Sivaldo Oliveira
    @since 07/08/2026
    
    @param oModelF7V,  Object,    Objeto modelo de dados da grid de múltiplos vencimentos
    @param cCampo,     Character, Nome do campo que sofreu digitação
	@return, lRetorno, Logical,   Retorna um tipo lógico verdadeiro ou falso       
/*/
Static Function ValidDigit(oModelF7V As Object, cCampo As Character) As Logical
    Local lRetorno  As Logical    
    Local cChaveCC2 As Character
    
    //Parâmetros de entrada
    Default oModelF7V := Nil
    Default cCampo    := "F7V_CODMUN"
    
    //Inicializa variáveis
    lRetorno  := .T.
    cChaveCC2 := ""
    
    If oModelF7V != Nil
        If cCampo $ "F7V_CODIGO|F7V_EST"
            If cCampo == "F7V_CODIGO" .And. !Empty(AllTrim(oModelF7V:GetValue("F7V_CODIGO")))
                lRetorno := ExistCpo("SX5", "60" + oModelF7V:GetValue("F7V_CODIGO"))
            ElseIf cCampo == "F7V_EST" .And. !Empty(AllTrim(oModelF7V:GetValue("F7V_EST")))
                lRetorno := ExistCpo("SX5","12" + oModelF7V:GetValue("F7V_EST"))
            EndIf
        ElseIf !oModelF7V:IsEmpty()
            CC2->(DbSetOrder(1))
            cChaveCC2 := FWxFilial("CC2") + (oModelF7V:GetValue("F7V_EST") + oModelF7V:GetValue("F7V_CODMUN")) 
            
            If !(lRetorno := CC2->(DbSeek(cChaveCC2)))
                Help(" ", 1, "CAD_MUNIC", Nil, STR0039, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0040})
            EndIf
        EndIf
    EndIf
Return lRetorno

/*/{Protheus.doc} VldGrvGrid
    Valida se todas os campos do modelo da grid foram preenchidas, 
    e se os valores preenchidos estão de acordo com o esperado
    para cada campo
    
    @author Sivaldo Oliveira
    @since 07/08/2026
	
    @param oModelF7V, Object, Objeto modelo de dados da grid de múltiplos vencimentos
	@return, lRetorno, Logical, Retorna um tipo lógico verdadeiro ou falso
/*/
Static Function VldGrvGrid(oModelF7V As Object) As Logical
    Local lRetorno   As Logical
	Local nLinha     As Numeric
	Local nQtdLinha  As Numeric    
    Local nDiaVencto As Numeric
    Local cChaveF7V  As Character
    
    //Parâmetros de entrada
    Default oModelF7V := Nil
    
    //Inicializa variáveis
    lRetorno   := .T.
	nLinha     := 0
	nQtdLinha  := 0    
	nDiaVencto := 0
    cChaveF7V  := ""
    
    If oModelF7V != Nil .And. !oModelF7V:IsEmpty() .And. (nQtdLinha := oModelF7V:Length()) > 0
        FKP->(DbSetOrder(1))
        F7V->(DbSetOrder(1))
        
        For nLinha := 1 To nQtdLinha
            oModelF7V:GoLine(nLinha)
            
            If !oModelF7V:IsDeleted()
                nDiaVencto := oModelF7V:GetValue("F7V_DIAREC")            
                lRetorno   := POSITIVO(nDiaVencto)
                
                If lRetorno .And. (Empty(nDiaVencto) .Or. Empty(oModelF7V:GetValue("F7V_CODIGO")) .Or. Empty(oModelF7V:GetValue("F7V_CODMUN")) .Or. Empty(oModelF7V:GetValue("F7V_EST")))
                    lRetorno := .F.
                    Help(" ", 1, "CAMPOVAZIO", Nil, STR0041 + ": " + cValToChar(nLinha) + " " + STR0042, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0043})
                EndIf
                
                If lRetorno .And. nDiaVencto > 31 
                    lRetorno := .F.
                    Help(" ", 1, "DIA_VENCTO", Nil, STR0015, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0016+"31."})
                EndIf
                
                If lRetorno
                    cChaveF7V := FWxFilial("F7V")+oModelF7V:GetValue("F7V_CODIGO")+oModelF7V:GetValue("F7V_EST")+oModelF7V:GetValue("F7V_CODMUN")
                    
                    If F7V->(DbSeek(cChaveF7V)) .And. AllTrim(F7V->F7V_IDRET) != AllTrim(oModelF7V:GetValue("F7V_IDRET"))
                        lRetorno := .F.
                        FKP->(DbSeek(FWxFilial("FKP")+F7V->F7V_IDRET))
                        Help(" ", 1, "SERVMUNIC", Nil, STR0044 + AllTrim(oModelF7V:GetValue("F7V_CODIGO")) + " " + STR0045 + AllTrim(oModelF7V:GetValue("F7V_CODMUN")) + " " + STR0046 + FKP->FKP_CODIGO, 2, 0, Nil, Nil, Nil, Nil, Nil, {STR0047})
                    EndIf
                EndIf
                
                If !lRetorno
                    Exit
                EndIf
            EndIf
        Next nLinha
	EndIf
Return lRetorno
