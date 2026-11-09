#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLALTBENMODEL.CH"

#Define TAMCODINT TamSX3("BA3_CODINT")[1]
#Define TAMCODEMP TamSX3("BA3_CODEMP")[1]
#Define TAMMATRIC TamSX3("BA3_MATRIC")[1]

// API REST para realizara a alteração do beneficiário na rotina de Analise de Beneficiários (PLSA977AB)
PUBLISH MODEL REST NAME PLALTBENMODEL RESOURCE OBJECT PLAltRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados para a analise de beneficiários referente ao Layout 
de Alteração cadastral

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/03/2022
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local oModel := Nil
    Local oStruBBA := FWFormStruct(1, "BBA")
    Local oStruB7L := FWFormStruct(1, "B7L")
    Local oStruAnexo := Nil
    Local oEvent := PLAltBenEvent():New()
    Local lAnexos := FindFunction("PLNewTabAnexos") .And. FindFunction("PLLoadAnexos")

    oModel := MPFormModel():New("PLAltBenModel")

    If lAnexos
        oStruAnexo := FWFormModelStruct():New()
        oStruAnexo := PLNewTabAnexos(1, oStruAnexo)
    EndIf
   
    // Campos a serem prenchidos ao utilizar o modelo (Obrigatório)
    oStruBBA:SetProperty("BBA_MATRIC", MODEL_FIELD_OBRIGAT, .T.)
    
    // Campos com valor predefinido
    oStruBBA:SetProperty("BBA_TIPMAN", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'2'")) // 2 = Alteração
    oStruBBA:SetProperty("BBA_TIPSOL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'2'")) // 2 = Inclusão/Manutenção
    oStruBBA:SetProperty("BBA_STATUS", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'2'")) // 2 = Em Analise
    oStruBBA:SetProperty("BBA_DATSOL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "dDataBase"))
    oStruBBA:SetProperty("BBA_HORSOL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "Substr(Time(), 1, 5)"))

    oStruB7L:SetProperty("B7L_ALIAS", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'BA1'"))
    oStruB7L:SetProperty("B7L_ALIACH", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'BBA'"))
    oStruB7L:SetProperty("B7L_TIPO", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'2'")) // 2 = Alteração
    oStruB7L:SetProperty("B7L_DATA", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "dDataBase"))
    oStruB7L:SetProperty("B7L_HORA", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "Substr(Time(), 1, 5)"))

    // Campos que não permite edição
    oStruBBA := AddWhenFields(oStruBBA, ".F.", {"BBA_CODSEQ", "BBA_TIPSOL", "BBA_STATUS", "BBA_CODINT", "BBA_CODEMP",;
                                                "BBA_CONEMP", "BBA_VERCON", "BBA_SUBCON", "BBA_VERSUB", "BBA_CODPRO",;
                                                "BBA_VERSAO", "BBA_EMPBEN", "BBA_CPFTIT", "BBA_OBSERV", "BBA_TIPMAN",;
                                                "BBA_APROVA", "BBA_DATSOL", "BBA_HORSOL"})
    
    oStruB7L := AddWhenFields(oStruB7L, ".F.", {"B7L_ALIAS", "B7L_ALIACH", "B7L_TIPO", "B7L_DATA", "B7L_GRAVAD",;
                                                "B7L_HORA", "B7L_VLANT", "B7L_RECREG", "B7L_CHVREG"})
    // Validações dos campos
    oStruBBA:SetProperty("BBA_MATRIC", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('BBA_MATRIC')) .Or. ExistCpo('BA1', FWFldGet('BBA_MATRIC'), 2)"))
    oStruBBA:SetProperty("BBA_NROPRO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('BBA_NROPRO')) .Or. ExistChav('BBA', FWFldGet('BBA_NROPRO'), 4)"))
    
    // Gatilhos
    AddGatilhos(@oStruB7L, {"B7L_CAMPO", {"B7L_VLANT", "B7L_RECREG"}})
    AddGatilhos(@oStruBBA, {"BBA_MATRIC", {"BBA_CPFTIT", "BBA_CODEMP", "BBA_CONEMP", "BBA_VERCON", "BBA_SUBCON",;
                                           "BBA_VERSUB", "BBA_CODPRO", "BBA_VERSAO", "BBA_EMPBEN"}})

    oModel:addFields("MASTERBBA", Nil, oStruBBA)
    oModel:AddGrid("DETAILB7L", "MASTERBBA", oStruB7L)
    If lAnexos
        oModel:AddGrid("DETAILANEXO", "MASTERBBA", oStruAnexo, Nil, Nil, Nil, Nil, {|oMdl| PLLoadAnexos(oMdl)})
    EndIf

    oModel:SetRelation("DETAILB7L", {{"B7L_FILIAL", "xFilial('B7L')"},;
                                     {"B7L_CHAVE", "BBA_CODSEQ"}},;
                                     B7L->(IndexKey(3))) 
    If lAnexos
        oModel:SetRelation("DETAILANEXO", {{"CODSEQ", "BBA_CODSEQ"}},;
                                            "ANEXO")
    EndIf

    oModel:SetDescription(STR0001) // "Alteração Cadastral de Beneficiários"
    oModel:GetModel("MASTERBBA"):SetDescription(STR0002) // "Protocolo da Solicitação de Alteração Cadastral"
    oModel:GetModel("DETAILB7L"):SetDescription(STR0003) // "Campos da Solicitação de Alteração Cadastral"
    If lAnexos
        oModel:GetModel("DETAILANEXO"):SetDescription(STR0012) // "Anexos do Protocolo"
    EndIf

    oModel:GetModel("DETAILB7L"):SetUniqueLine({"B7L_CAMPO"})

    // Tabela temporaria não persiste os dados (Gravação)
    If lAnexos
        oModel:GetModel("DETAILANEXO"):SetOnlyQuery(.T.)
        oModel:GetModel("DETAILANEXO"):SetOptional(.T.)  
    EndIf

    oModel:InstallEvent("PLAltBenEvent", /*cOwner*/, oEvent)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} AddWhenFields
Define o modo de edição (WHEN) dos campos na estrutura

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Static Function AddWhenFields(oStruct, cWhen ,aCampos)

    Local nX := 0

    Default aCampos := {}

    If Len(aCampos) > 0
        For nX := 1 To Len(aCampos)

            oStruct:SetProperty(aCampos[nX], MODEL_FIELD_WHEN, FWBuildFeature(STRUCT_FEATURE_WHEN, cWhen))

        Next nX
    EndIf

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} PLGatAltBenef
Gatilho para retornar os dados referente ao beneficiário ao preencher
a matricula ou campo alterado

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/03/2022
/*/
//------------------------------------------------------------------- 
Function PLGatAltBenef(cCampoDestino)
    
    Local cRetorno := ""
    Local xValueCampo := Nil
    Local oModel := FWModelActive()
    Local cMatricula := oModel:GetValue("MASTERBBA", "BBA_MATRIC")
    Local cCampoAlterado := ""
    Local cFamilia := ""

    Default cCampoDestino := ""

    If !Empty(cMatricula) .And. Len(cMatricula) >= 14

        BA1->(DBSetOrder(2))
        If BA1->(MsSeek(xFilial("BA1")+cMatricula))

            cFamilia := SubsTr(cMatricula, 1, TAMCODINT + TAMCODEMP + TAMMATRIC)

            Do Case
                Case cCampoDestino == "BBA_CPFTIT"
                    If BA1->BA1_TIPUSU == SuperGetMv("MV_PLCDTIT", .F., "T")
                        cRetorno := Alltrim(BA1->BA1_CPFUSR)
                    Else
                        cRetorno := GetCPFTitular(cFamilia)
                    EndIf

                Case cCampoDestino == "BBA_EMPBEN"
                    cRetorno := Alltrim(BA1->BA1_NOMUSR)

                Case cCampoDestino == "B7L_VLANT"
                    cCampoAlterado := Alltrim(oModel:GetValue("DETAILB7L", "B7L_CAMPO"))

                    If &("BA1->(FieldPos('"+cCampoAlterado+"'))") > 0
                        xValueCampo := &("BA1->"+cCampoAlterado)

                        cRetorno := IIf(ValType(xValueCampo) == "N", cValToChar(xValueCampo), cRetorno)
                        cRetorno := IIf(ValType(xValueCampo) == "D", DToC(xValueCampo), cRetorno)
                        cRetorno := IIf(ValType(xValueCampo) == "C", xValueCampo, cRetorno)

                    EndIf

                Case cCampoDestino == "B7L_RECREG"
                    cRetorno := cValToChar(BA1->(Recno()))

                OtherWise
                    BA3->(DbSetOrder(1))
                    If BA3->(MsSeek(xFilial("BA3")+cFamilia))
                        Do Case
                            Case cCampoDestino == "BBA_CODEMP"
                                cRetorno := BA3->BA3_CODEMP
                            
                            Case cCampoDestino == "BBA_CONEMP"
                                cRetorno := BA3->BA3_CONEMP

                            Case cCampoDestino == "BBA_VERCON"
                                cRetorno := BA3->BA3_VERCON
                            
                            Case cCampoDestino == "BBA_SUBCON"
                                cRetorno := BA3->BA3_SUBCON

                            Case cCampoDestino == "BBA_VERSUB"
                                cRetorno := BA3->BA3_VERSUB

                            Case cCampoDestino == "BBA_CODPRO"
                                cRetorno := BA3->BA3_CODPLA

                            Case cCampoDestino == "BBA_VERSAO"
                                cRetorno := BA3->BA3_VERSAO
                        EndCase
                    EndIf
            EndCase
        EndIf
    EndIf 

    cRetorno := Alltrim(cRetorno)

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCPFTitular
Retorna o CPF do títular da familia informada

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/03/2022
/*/
//------------------------------------------------------------------- 
Static Function GetCPFTitular(cFamilia)

    Local cCPF := ""
    Local cOperadora := ""
    Local cEmpresa := ""
    Local cMatricula := ""
    Local cTipoTitular := SuperGetMv("MV_PLCDTIT", .F., "T")

    Default cFamilia := ""

    If !Empty(cFamilia) .And. Len(cFamilia) >= 14

        cOperadora := SubsTr(cFamilia, 1, TAMCODINT)
        cEmpresa := SubsTr(cFamilia, TAMCODINT + 1, TAMCODEMP)
        cMatricula := SubsTr(cFamilia, TAMCODINT + TAMCODEMP + 1, TAMMATRIC)

        BA1->(DBSetOrder(1))
        If BA1->(MsSeek(xFilial("BA1")+cOperadora+cEmpresa+cMatricula+cTipoTitular))
            cCPF := Alltrim(BA1->BA1_CPFUSR)
        EndIf
    EndIf

Return cCPF


//-------------------------------------------------------------------
/*/{Protheus.doc} AddGatilhos
Adiciona gatilhos na estrutura de um campo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 14/03/2022
/*/
//------------------------------------------------------------------- 
Static Function AddGatilhos(oStruct, aGatilhos)

    Local aGatilho := {}
    Local nX := 0
    Local cCampOrigem := ""
    Local aCampDestino := {}

    Default aGatilhos := {}

    If Len(aGatilhos) == 2   
        cCampOrigem := aGatilhos[1]
        aCampDestino := aGatilhos[2]

        For nX := 1 To Len(aCampDestino)

            aGatilho := FwStruTrigger(cCampOrigem, aCampDestino[nX], "PLGatAltBenef('"+aCampDestino[nX]+"')")
            oStruct:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

        Next nX

    EndIf

Return oStruct