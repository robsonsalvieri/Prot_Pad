#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLINCBENMODEL.CH"

#Define TAMCODINT TamSX3("BA3_CODINT")[1]
#Define TAMCODEMP TamSX3("BA3_CODEMP")[1]
#Define TAMMATRIC TamSX3("BA3_MATRIC")[1]

// API REST para realizara a inclusão dos beneficiários na rotina de Analise de Beneficiários (PLSA977AB)
PUBLISH MODEL REST NAME PLINCBENMODEL RESOURCE OBJECT PLIncRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados para a analise de beneficiários referente ao Layout 
de Inclusão cadastral

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 24/05/2022
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

    Local oModel        := Nil
    Local oStruBBA      := FWFormStruct(1, "BBA")
    Local oStruB2N      := FWFormStruct(1, "B2N")
    Local oStruAnexo    := FWFormModelStruct():New()
    Local oStruOpc      := NIL
    Local oStrPrpGen    := NIL
    Local oEvent        := PLIncBenEvent():New()
    Local aCmpNoEditar  := {}
    Local aCmpIniPadrao := {}
    Local aCmpValid     := {}

    oModel := MPFormModel():New("PLIncBenModel")

    oStruAnexo := PLNewTabAnexos(1, oStruAnexo)
   
    // Campos a serem prenchidos ao utilizar o modelo (Obrigatório)
    oStruBBA := AddObrigatFields(oStruBBA, {"BBA_CODINT", "BBA_CODEMP", "BBA_CPFTIT", "BBA_CODPRO", "BBA_VERSAO", "BBA_EMPBEN"})
    oStruB2N:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
        
    // Campos com valor predefinido
    oStruBBA:SetProperty("*", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, ""))
    oStruBBA:SetProperty("BBA_CODSEQ", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "GETSX8NUM('BBA', 'BBA_CODSEQ')")) 
    oStruBBA:SetProperty("BBA_TIPMAN", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'1'")) // 1 = Inclusão
    oStruBBA:SetProperty("BBA_TIPSOL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'2'")) // 2 = Inclusão/Manutenção
    oStruBBA:SetProperty("BBA_STATUS", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'1'")) // 1 = Pendente de Documentação
    oStruBBA:SetProperty("BBA_DATSOL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "dDataBase"))
    oStruBBA:SetProperty("BBA_HORSOL", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "Substr(Time(), 1, 5)")) // HH:MM

    oStruB2N:SetProperty("*", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, ""))
    oStruB2N:SetProperty("B2N_FLGCTR", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "'0'")) // 0 = Não
    oStruB2N:SetProperty("B2N_CODSEQ", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "GETSXENUM('B2N', 'B2N_CODSEQ')"))
    oStruB2N:SetProperty("B2N_CODEMP", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "FWFldGet('BBA_CODEMP')")) 
    oStruB2N:SetProperty("B2N_CONEMP", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "FWFldGet('BBA_CONEMP')")) 
    oStruB2N:SetProperty("B2N_SUBCON", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "FWFldGet('BBA_SUBCON')"))  

    aCmpIniPadrao := GetIniPadrao() // Campos como inicializadores padrões no Layout Generico
    If Len(aCmpIniPadrao) > 0
        oStruB2N := AddIniPadFields(oStruB2N, aCmpIniPadrao)
    EndIf

    // Campos que permite ou não edição
    oStruBBA := AddWhenFields(oStruBBA, ".F.", {"BBA_CODSEQ", "BBA_TIPSOL", "BBA_STATUS", "BBA_OBSERV",;
                                                "BBA_TIPMAN", "BBA_APROVA", "BBA_DATSOL", "BBA_HORSOL"}) 

    oStruBBA := AddWhenFields(oStruBBA, "PLChangeMatric()", {"BBA_CODINT", "BBA_CODEMP", "BBA_CONEMP", "BBA_VERCON", "BBA_SUBCON",;
                                                             "BBA_VERSUB", "BBA_CODPRO", "BBA_VERSAO", "BBA_EMPBEN", "BBA_CPFTIT"}) 

    oStruB2N := AddWhenFields(oStruB2N, ".F.", {"B2N_TIPUSU", "B2N_DESGRA", "B2N_DATOBI", "B2N_CODMOT", "B2N_FLGCTR",;
                                                "B2N_CODSEQ", "B2N_BA1REC", "B2N_TIPBLO", "B2N_DTBLOQ", "B2N_DESMOT",;
                                                "B2N_CODEMP", "B2N_CONEMP", "B2N_SUBCON"})      
    
    aCmpNoEditar := GetCmpNoEditar() // Campos definidos como não editavel no Layout Generico
    If Len(aCmpNoEditar) > 0
        oStruB2N := AddWhenFields(oStruB2N, ".F.", aCmpNoEditar)  
    EndIf
                                                                                                         
    // Validações dos campos
    oStruBBA:SetProperty("BBA_MATRIC", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('BBA_MATRIC')) .Or. ExistCpo('BA1', FWFldGet('BBA_MATRIC'), 2)"))
    oStruBBA:SetProperty("BBA_NROPRO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('BBA_NROPRO')) .Or. ExistChav('BBA', FWFldGet('BBA_NROPRO'), 4)"))
    oStruBBA:SetProperty("BBA_CPFTIT", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('BBA_CPFTIT')) .Or. CGC(FWFldGet('BBA_CPFTIT'))"))

    oStruB2N:SetProperty("*", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ""))
    oStruB2N:SetProperty("B2N_CPFUSR", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_CPFUSR')) .Or. CGC(FWFldGet('B2N_CPFUSR'))"))
    oStruB2N:SetProperty("B2N_RGEST", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_RGEST')) .Or. ExistCpo('SX5', '12'+FWFldGet('B2N_RGEST'), 1)"))
    oStruB2N:SetProperty("B2N_ESTADO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_ESTADO')) .Or. ExistCpo('SX5', '12'+FWFldGet('B2N_ESTADO'), 1)"))
    oStruB2N:SetProperty("B2N_GRAUPA", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_GRAUPA')) .Or. ExistCpo('BRP', FWFldGet('B2N_GRAUPA'), 1)"))
    oStruB2N:SetProperty("B2N_NRCRNA", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_NRCRNA')) .Or. HS_VldCns(FWFldGet('B2N_NRCRNA'))"))
    oStruB2N:SetProperty("B2N_ESTCIV", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_ESTCIV')) .Or. ExistCpo('SX5', '33'+FWFldGet('B2N_ESTCIV'), 1)"))
    oStruB2N:SetProperty("B2N_BANCO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_BANCO')) .Or. ExistCpo('SA6', FWFldGet('B2N_BANCO'), 1)"))
    oStruB2N:SetProperty("B2N_CEPUSR", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_CEPUSR')) .Or. ExistCpo('BC9', FWFldGet('B2N_CEPUSR'), 1)"))
    oStruB2N:SetProperty("B2N_CODMUN", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_CODMUN')) .Or. ExistCpo('BID', FWFldGet('B2N_CODMUN'), 1)"))
    oStruB2N:SetProperty("B2N_SEXO", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_SEXO')) .Or. FWFldGet('B2N_SEXO') $ '1/2'"))
    oStruB2N:SetProperty("B2N_UNIVER", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_UNIVER')) .Or. FWFldGet('B2N_UNIVER') $ '0/1'"))
    oStruB2N:SetProperty("B2N_INVALI", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_INVALI')) .Or. FWFldGet('B2N_INVALI') $ '0/1'"))
    oStruB2N:SetProperty("B2N_COMUNI", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Empty(FWFldGet('B2N_COMUNI')) .Or. FWFldGet('B2N_COMUNI') $ '0/1/2'"))

    aCmpValid := GetCmpValid() // Campos definidos com validação no Layout Generico
    If Len(aCmpValid) > 0
        oStruB2N := AddValidFields(oStruB2N, aCmpValid)  
    EndIf
    
    // Gatilhos
    oStruBBA := AddGatilhos(oStruBBA, "BBA", {"BBA_MATRIC", {"BBA_CODINT", "BBA_CODEMP", "BBA_CONEMP", "BBA_VERCON", "BBA_SUBCON",;
                                                             "BBA_VERSUB", "BBA_CODPRO", "BBA_VERSAO", "BBA_EMPBEN", "BBA_CPFTIT"}})
    
    oStruB2N := AddGatilhos(oStruB2N, "B2N", {"B2N_GRAUPA", {"B2N_TIPUSU", "B2N_DESGRA"}})
    oStruB2N := AddGatilhos(oStruB2N, "B2N", {"B2N_CEPUSR", {"B2N_ENDERE", "B2N_BAIRRO", "B2N_CODMUN", "B2N_MUNICI", "B2N_ESTADO"}})
    oStruB2N := AddGatilhos(oStruB2N, "B2N", {"B2N_CODMUN", {"B2N_MUNICI", "B2N_ESTADO"}})

    oModel:AddFields("MASTERBBA", Nil, oStruBBA)
    oModel:AddGrid("DETAILB2N", "MASTERBBA", oStruB2N)
    oModel:AddGrid("DETAILANEXO", "MASTERBBA", oStruAnexo, Nil, Nil, Nil, Nil, {|oMdl| PLLoadAnexos(oMdl)})

    oModel:SetRelation("DETAILB2N", {{"B2N_FILIAL", "xFilial('B2N')"},;
                                     {"B2N_PROTOC", "BBA_CODSEQ"}},;
                                      B2N->(IndexKey(1)))
    
    oModel:SetRelation("DETAILANEXO", {{"CODSEQ", "BBA_CODSEQ"}},;
                                        "ANEXO")

    oModel:SetDescription(STR0001) // "Inclusão Cadastral de Beneficiários"
    oModel:GetModel("MASTERBBA"):SetDescription(STR0002) // "Protocolo da Solicitação de Inclusão Cadastral" 
    oModel:GetModel("DETAILB2N"):SetDescription(STR0003) // "Beneficiários para Inclusão Cadastral" 
    oModel:GetModel("DETAILANEXO"):SetDescription(STR0022) // "Anexos do Protocolo" 

    oModel:GetModel("DETAILB2N"):SetUniqueLine({})
    oModel:GetModel("DETAILANEXO"):SetUniqueLine({})
    
    // Tabela temporaria não persiste os dados (Gravação)
    oModel:GetModel("DETAILANEXO"):SetOnlyQuery(.T.)
    oModel:GetModel("DETAILANEXO"):SetOptional(.T.)

    //utilizado para retornar o resultado do processo de gravacao dos opcionais
    oStruOpc   := PLMDOPC()

    If ValType(oStruOpc) == "O"
        oModel:AddGrid("DETAILOPC", "MASTERBBA", oStruOpc, Nil, Nil, Nil, Nil, )
        oModel:GetModel("DETAILOPC"):SetUniqueLine({})
        oModel:GetModel("DETAILOPC"):SetOptional(.T.)
    EndIf

    //a criacao desse modelo deve ser sempre o ultimo
    oStrPrpGen := PLPROPGEN()

    If ValType(oStrPrpGen) == "O"
        oModel:AddGrid("DETAILPRPGEN", "MASTERBBA", oStrPrpGen)
        oModel:GetModel("DETAILPRPGEN"):SetOptional(.T.)
        oModel:GetModel("DETAILPRPGEN"):SetOnlyQuery(.T.)
    EndIf

    oModel:InstallEvent("PLIncBenEvent", /*cOwner*/, oEvent)

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} AddObrigatFields
Define os campos como obrigatorio na estrutura

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Static Function AddObrigatFields(oStruct, aCampos)

    Local nX := 0

    Default aCampos := {}

    If Len(aCampos) > 0
        For nX := 1 To Len(aCampos)

            oStruct:SetProperty(aCampos[nX], MODEL_FIELD_OBRIGAT, .T.)

        Next nX
    EndIf

Return oStruct


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
/*/{Protheus.doc} AddIniPadFields
Define os inicializadores padrão dos campos na estrutura

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/05/2022
/*/
//------------------------------------------------------------------- 
Static Function AddIniPadFields(oStruct, aCampos)

    Local nX := 0

    Default aCampos := {}

    If Len(aCampos) > 0
        For nX := 1 To Len(aCampos)
            
            oStruct:SetProperty(aCampos[nX][1], MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, aCampos[nX][2])) 

        Next nX
    EndIf

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} AddValidFields
Define as validações dos campos na estrutura

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 30/05/2022
/*/
//------------------------------------------------------------------- 
Static Function AddValidFields(oStruct, aCampos)

    Local nX := 0

    Default aCampos := {}

    If Len(aCampos) > 0
        For nX := 1 To Len(aCampos)

            oStruct:SetProperty(aCampos[nX][1], MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, aCampos[nX][2]))

        Next nX
    EndIf

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} PLGatIncBenef
Gatilho para retornar os dados para inclusão do beneficiário

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Function PLGatIncBenef(cCampoDestino, cTabela, cCampoOrigem)
    
    Local cRetorno := ""
    Local oModel := FWModelActive()
    Local cMatricula := ""
    Local cGrauParen := ""
    Local cFamilia := ""
    Local cCEP := ""
    Local cGrauTititular := GetNewPar("MV_PLCDTGP", "01")
    Local cTipoTititular := GetNewPar("MV_PLCDTIT", "T")
    Local cTipoDependente := GetNewPar("MV_PLCDDEP", "D")

    Default cCampoDestino := ""
    Default cTabela := ""
    Default cCampoOrigem := ""

    Do Case
        Case cTabela == "BBA" // Cabeçalho Solic. Beneficiarios
            cMatricula := oModel:GetValue("MASTERBBA", "BBA_MATRIC")

            If !Empty(cMatricula) .And. Len(cMatricula) >= 14

                BA1->(DBSetOrder(2))
                If BA1->(MsSeek(xFilial("BA1")+cMatricula))
                    Do Case
                        Case cCampoDestino == "BBA_CPFTIT"
                            cRetorno := BA1->BA1_CPFUSR
        
                        Case cCampoDestino == "BBA_EMPBEN"
                            cRetorno := BA1->BA1_NOMUSR

                        OtherWise
                            cFamilia := SubsTr(cMatricula, 1, TAMCODINT + TAMCODEMP + TAMMATRIC)

                            BA3->(DbSetOrder(1))
                            If BA3->(MsSeek(xFilial("BA3")+cFamilia))
                                Do Case
                                    Case cCampoDestino == "BBA_CODINT"
                                        cRetorno := BA3->BA3_CODINT

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
        
        Case cTabela == "B2N" // Inclusão de Beneficiários
            Do Case 
                Case cCampoDestino == "B2N_TIPUSU"
                    cGrauParen := oModel:GetValue("DETAILB2N", "B2N_GRAUPA")
                    
                    If !Empty(cGrauParen)
                        If cGrauParen == cGrauTititular
                            cRetorno := cTipoTititular
                        Else
                            cRetorno := cTipoDependente
                        EndIf
                    EndIf
                
                Case cCampoOrigem == "B2N_CEPUSR"
                    cCEP := oModel:GetValue("DETAILB2N", "B2N_CEPUSR")

                    BC9->(DbSetOrder(1))
                    If BC9->(MsSeek(xFilial("BC9")+cCEP))
                        Do Case
                            Case cCampoDestino == "B2N_ENDERE"
                                cRetorno := BC9->BC9_END
                                   
                            Case cCampoDestino == "B2N_BAIRRO"
                                cRetorno := BC9->BC9_BAIRRO

                            Case cCampoDestino == "B2N_CODMUN"
                                cRetorno := BC9->BC9_CODMUN

                            Case cCampoDestino == "B2N_MUNICI"
                                cRetorno := BC9->BC9_MUN

                            Case cCampoDestino == "B2N_ESTADO"
                                cRetorno := BC9->BC9_EST
                        EndCase

                    EndIf

                Case cCampoDestino == "B2N_DESGRA"
                    cRetorno := Posicione("BRP", 1, xFilial("BRP")+oModel:GetValue("DETAILB2N", "B2N_GRAUPA"), "BRP_DESCRI")
                
                Case cCampoDestino == "B2N_MUNICI"
                    cRetorno := Posicione("BID", 1, xFilial("BID")+oModel:GetValue("DETAILB2N", "B2N_CODMUN"), "BID_DESCRI")

                Case cCampoDestino == "B2N_ESTADO"
                    cRetorno := Posicione("BID", 1, xFilial("BID")+oModel:GetValue("DETAILB2N", "B2N_CODMUN"), "BID_EST")

            EndCase   
    EndCase
     
    cRetorno := Alltrim(cRetorno)

Return cRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} AddGatilhos
Adiciona gatilhos na estrutura de um campo

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Static Function AddGatilhos(oStruct, cTabela, aGatilhos)

    Local aGatilho := {}
    Local nX := 0
    Local cCampOrigem := ""
    Local aCampDestino := {}

    Default aGatilhos := {}
    Default cTabela := ""

    If Len(aGatilhos) == 2   
        cCampOrigem := aGatilhos[1]
        aCampDestino := aGatilhos[2]

        For nX := 1 To Len(aCampDestino)

            aGatilho := FwStruTrigger(cCampOrigem, aCampDestino[nX], "PLGatIncBenef('"+aCampDestino[nX]+"', '"+cTabela+"', '"+cCampOrigem+"')")
            oStruct:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

        Next nX

    EndIf

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} PLChangeMatric
Função que permite a edição dos campos quando a matricula não for
informada.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Function PLChangeMatric()

    Local lChange := .T.
    Local oModel := FWModelActive()

    If Valtype(oModel) <> "U" .And. !Empty(oModel:GetValue("MASTERBBA", "BBA_MATRIC"))
        lChange := .F.
    EndIf

Return lChange


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCmpNoEditar
Retornar os campos que estão definidos como não editavel no layout
generico web de Inclusão de beneficiários.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Static Function GetCmpNoEditar()

    Local cLayoutWeb := GetNewPar("MV_PLLAYIN", "") // Parametro que define o Layout utilizado na API de inclusão cadastral dos beneficiários
    Local cAliasTemp := GetNextAlias()
    Local aCampos := {}

    BeginSQL Alias cAliasTemp

        SELECT B91_CAMPO FROM %Table:B91% B91
            INNER JOIN %Table:B7C% B7C
                ON B7C.B7C_FILIAL = %XFilial:B7C% 
               AND B7C.B7C_SEQB90 = B91.B91_SEQUEN
               AND B7C.B7C_ORDEM = B91.B91_GRUPO
               AND B7C_ALIAS = 'B2N'
               AND B7C.%notDel%

            INNER JOIN %Table:B90% B90
                ON B90.B90_FILIAL = %XFilial:B90% 
               AND B90.B90_SEQUEN = B91.B91_SEQUEN
               AND B90.B90_CHAVE = %exp:cLayoutWeb% 
               AND B90.%notDel%
               
            WHERE B91.B91_FILIAL = %XFilial:B91% 
              AND B91.B91_EDITAR = 'F'
              AND B91.%notDel%
              
    EndSQL

    While !(cAliasTemp)->(EoF())
        
        aAdd(aCampos, Alltrim((cAliasTemp)->B91_CAMPO))

        (cAliasTemp)->(DbSkip())
    EndDo

    (cAliasTemp)->(DbCloseArea())

Return aCampos


//-------------------------------------------------------------------
/*/{Protheus.doc} GetIniPadrao
Retornar os campos que possuem inicializar padrão no layout
generico web de Inclusão de beneficiários.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Static Function GetIniPadrao()

    Local cLayoutWeb := GetNewPar("MV_PLLAYIN", "") // Parametro que define o Layout utilizado na API de inclusão cadastral dos beneficiários
    Local cAliasTemp := GetNextAlias()
    Local aCampos := {}

    BeginSQL Alias cAliasTemp

        SELECT B91_CAMPO, B91_INIPAD FROM %Table:B91% B91
            INNER JOIN %Table:B7C% B7C
                ON B7C.B7C_FILIAL = %XFilial:B7C% 
               AND B7C.B7C_SEQB90 = B91.B91_SEQUEN
               AND B7C.B7C_ORDEM = B91.B91_GRUPO
               AND B7C_ALIAS = 'B2N'
               AND B7C.%notDel%

            INNER JOIN %Table:B90% B90
                ON B90.B90_FILIAL = %XFilial:B90% 
               AND B90.B90_SEQUEN = B91.B91_SEQUEN
               AND B90.B90_CHAVE = %exp:cLayoutWeb% 
               AND B90.%notDel%
               
            WHERE B91.B91_FILIAL = %XFilial:B91% 
              AND B91.B91_INIPAD <> ''
              AND B91.%notDel%
              
    EndSQL

    While !(cAliasTemp)->(EoF())
        
        aAdd(aCampos, {Alltrim((cAliasTemp)->B91_CAMPO), Alltrim((cAliasTemp)->B91_INIPAD)})

        (cAliasTemp)->(DbSkip())
    EndDo

    (cAliasTemp)->(DbCloseArea())

Return aCampos


//-------------------------------------------------------------------
/*/{Protheus.doc} GetCmpValid
Retornar os campos que possuem validações no layout
generico web de Inclusão de beneficiários.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 27/05/2022
/*/
//------------------------------------------------------------------- 
Static Function GetCmpValid()

    Local cLayoutWeb := GetNewPar("MV_PLLAYIN", "") // Parametro que define o Layout utilizado na API de inclusão cadastral dos beneficiários
    Local cAliasTemp := GetNextAlias()
    Local aCampos := {}

    BeginSQL Alias cAliasTemp

        SELECT B91_CAMPO, B91_VALID FROM %Table:B91% B91
            INNER JOIN %Table:B7C% B7C
                ON B7C.B7C_FILIAL = %XFilial:B7C% 
               AND B7C.B7C_SEQB90 = B91.B91_SEQUEN
               AND B7C.B7C_ORDEM = B91.B91_GRUPO
               AND B7C_ALIAS = 'B2N'
               AND B7C.%notDel%

            INNER JOIN %Table:B90% B90
                ON B90.B90_FILIAL = %XFilial:B90% 
               AND B90.B90_SEQUEN = B91.B91_SEQUEN
               AND B90.B90_CHAVE = %exp:cLayoutWeb% 
               AND B90.%notDel%
               
            WHERE B91.B91_FILIAL = %XFilial:B91% 
              AND B91.B91_VALID <> ''
              AND B91.%notDel%
              
    EndSQL

    While !(cAliasTemp)->(EoF())
        
        aAdd(aCampos, {Alltrim((cAliasTemp)->B91_CAMPO), Alltrim((cAliasTemp)->B91_VALID)})

        (cAliasTemp)->(DbSkip())
    EndDo

    (cAliasTemp)->(DbCloseArea())

Return aCampos


//-------------------------------------------------------------------
/*/{Protheus.doc} PLNewTabAnexos
Cria Tabela e campos dos Anexos (Temporária)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/06/2022
/*/
//------------------------------------------------------------------- 
Function PLNewTabAnexos(nTipo, oStruAnexo)

    If nTipo == 1 // 1 = ModelDef
        oStruAnexo:AddTable("ANEXO", {"DIRECTORY"}, STR0022) // "Anexos do Protocolo"

        oStruAnexo:AddField(STR0023,; // Titulo do campo (Caracter) // "Cod. Seq."
                            STR0023,; // ToolTip do campo (Caracter) // "Cod. Seq."
                            "CODSEQ",; // Id do Field (Caracter)
                            "C",; // Tipo do campo (Caracter)
                            6,; // Tamanho do campo (Numerico)
                            0,; // Decimal do campo (Numerico)
                            Nil,; // Code-block de validação do campo (Bloco de Codigo)
                            Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                            {},; // Lista de valores permitido do campo (Array)
                            .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                            FwBuildFeature(STRUCT_FEATURE_INIPAD, ""),; // Code-block de inicializacao do campo (Bloco de Codigo)
                            .F.,; // Indica se trata-se de um campo chave (Lógico)
                            .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                            .F.) // Indica se o campo é virtual (Lógico)
        
        oStruAnexo:AddField(STR0024,; // Titulo do campo (Caracter) // "Dir. Anexo"
                            STR0024,; // ToolTip do campo (Caracter) // "Dir. Anexo"
                            "DIRECTORY",; // Id do Field (Caracter)
                            "C",; // Tipo do campo (Caracter)
                            200,; // Tamanho do campo (Numerico)
                            0,; // Decimal do campo (Numerico)
                            Nil,; // Code-block de validação do campo (Bloco de Codigo)
                            Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                            {},; // Lista de valores permitido do campo (Array)
                            .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                            FwBuildFeature(STRUCT_FEATURE_INIPAD, ""),; // Code-block de inicializacao do campo (Bloco de Codigo)
                            .F.,; // Indica se trata-se de um campo chave (Lógico)
                            .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                            .F.) // Indica se o campo é virtual (Lógico)
        
        oStruAnexo:AddField(STR0025,; // Titulo do campo (Caracter) // "Nome Arquivo"
                            STR0025,; // ToolTip do campo (Caracter) // "Nome Arquivo"
                            "FILENAME",; // Id do Field (Caracter)
                            "C",; // Tipo do campo (Caracter)
                            60,; // Tamanho do campo (Numerico)
                            0,; // Decimal do campo (Numerico)
                            Nil,; // Code-block de validação do campo (Bloco de Codigo)
                            Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                            {},; // Lista de valores permitido do campo (Array)
                            .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                            FwBuildFeature(STRUCT_FEATURE_INIPAD, ""),; // Code-block de inicializacao do campo (Bloco de Codigo)
                            .F.,; // Indica se trata-se de um campo chave (Lógico)
                            .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                            .F.) // Indica se o campo é virtual (Lógico)

        oStruAnexo:AddField(STR0035,; // Titulo do campo (Caracter) // "Base 64"
                            STR0035,; // ToolTip do campo (Caracter) // "Base 64"
                            "BASE64",; // Id do Field (Caracter)
                            "M",; // Tipo do campo (Caracter)
                            10,; // Tamanho do campo (Numerico)
                            0,; // Decimal do campo (Numerico)
                            Nil,; // Code-block de validação do campo (Bloco de Codigo)
                            Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                            {},; // Lista de valores permitido do campo (Array)
                            .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                            FwBuildFeature(STRUCT_FEATURE_INIPAD, ""),; // Code-block de inicializacao do campo (Bloco de Codigo)
                            .F.,; // Indica se trata-se de um campo chave (Lógico)
                            .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                            .F.) // Indica se o campo é virtual (Lógico)
    Else // ViewDef
        oStruAnexo:AddField("DIRECTORY",; // Nome do Campo (Caracter)
                            "01",; // Ordem (Caracter)
                            STR0024,; // Titulo do campo (Caracter) // "Dir. Anexo"
                            STR0024,; // Descricao do campo (Caracter) // "Dir. Anexo"
                            Nil,; // Array com Help (Array)
                            "C",; // Tipo do campo (Caracter)
                            "",; // Picture (Caracter)
                            Nil,; // Bloco de PictTre Var (Bloco de Codigo)
                            Nil,; // Consulta F3 (Caracter)
                            .T.,; // Indica se o campo é alteravel (Lógico)
                            Nil,; // Pasta do campo (Caracter)
                            Nil,; // Agrupamento do campo (Caracter)
                            Nil,; // Lista de valores permitido do campo (Array)
                            Nil,; // Tamanho maximo da maior opção do combo (Numerico)
                            Nil,; // Inicializador de Browse (Caracter)
                            Nil,; // Indica se o campo é virtual (Lógico)
                            Nil,; // Picture Variavel (Caracter)
                            Nil) // Indica pulo de linha após o campo (Lógico)
        
        oStruAnexo:AddField("FILENAME",; // Nome do Campo (Caracter)
                            "02",; // Ordem (Caracter)
                            STR0025,; // Titulo do campo (Caracter) // "Nome Arquivo"
                            STR0025,; // Descricao do campo (Caracter) // "Nome Arquivo"
                            Nil,; // Array com Help (Array)
                            "C",; // Tipo do campo (Caracter)
                            "",; // Picture (Caracter)
                            Nil,; // Bloco de PictTre Var (Bloco de Codigo)
                            Nil,; // Consulta F3 (Caracter)
                            .T.,; // Indica se o campo é alteravel (Lógico)
                            Nil,; // Pasta do campo (Caracter)
                            Nil,; // Agrupamento do campo (Caracter)
                            Nil,; // Lista de valores permitido do campo (Array)
                            Nil,; // Tamanho maximo da maior opção do combo (Numerico)
                            Nil,; // Inicializador de Browse (Caracter)
                            Nil,; // Indica se o campo é virtual (Lógico)
                            Nil,; // Picture Variavel (Caracter)
                            Nil) // Indica pulo de linha após o campo (Lógico)
    EndIf

Return oStruAnexo


//-------------------------------------------------------------------
/*/{Protheus.doc} PLLoadAnexos
Carrega os dados dos anexos do protocolo quando for realizado uma
visualização, alteração e exclusão dos dados.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 01/06/2022
/*/
//------------------------------------------------------------------- 
Function PLLoadAnexos(oGrid)

    Local aLoad := {}
    Local cCodSeqProtocolo := oGrid:GetModel():GetValue("MASTERBBA", "BBA_CODSEQ")
    Local cAliasTemp := GetNextAlias()
    Local cChaveBBA := xFilial("BBA")+cCodSeqProtocolo

    BeginSql Alias cAliasTemp	

        SELECT ACB_OBJETO, ACB_DESCRI FROM %table:ACB% ACB
            INNER JOIN %table:AC9% AC9
                 ON AC9_FILIAL = %xFilial:AC9%
                AND AC9.AC9_CODOBJ = ACB.ACB_CODOBJ

            WHERE ACB.ACB_FILIAL = %xFilial:ACB%        
              AND AC9_ENTIDA = 'BBA'
              AND AC9_FILENT = %xFilial:BBA%
              AND AC9_CODENT = %Exp:cChaveBBA%
              AND AC9.%NotDel% 
              AND ACB.%NotDel%

    EndSql

    If !(cAliasTemp)->(Eof())
        While !(cAliasTemp)->(EOF())

            aAdd(aLoad, {0, {cCodSeqProtocolo, (cAliasTemp)->ACB_OBJETO, (cAliasTemp)->ACB_DESCRI, ""}})    
            (cAliasTemp)->(DbSkip())
            
        EndDo
    Else
        aAdd(aLoad, {0, {cCodSeqProtocolo, "", "", ""}})
    EndIf

    (cAliasTemp)->(DbCloseArea())
	
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} PLMDOPC
cria o modelo e a tabela temporária que será utilizada no fonte PlIncRestModel
referente ao retorno da gravação dos opcionais

@since 01/10/2025
/*/
//------------------------------------------------------------------- 
Static Function PLMDOPC()

    Local oStrOpc    :=  FWFormModelStruct():New()
    Local oTempTable := FWTemporaryTable():New("INCOP")
    Local aFields    := {}
    
     ////////////////////////////////////////////////////////////
    //tabela temporaria
    aAdd(aFields, {"MATRICULA",   "C",  17,0})
    aAdd(aFields, {"RESULT", "C",  1000, 0})
    
    oTempTable:SetFields( aFields )
    oTempTable:AddIndex("01", {"MATRICULA"} )

    If Select("INCOP") > 0 
        INCOP->(DbCloseArea())
    EndIf
    
    oTempTable:Create()
    //FIM
    ////////////////////////////////////////////////////////////

    //campos especificos para retornar o status da incusao dos opcionais
    oStrOpc:AddTable("INCOP", {"MATRICULA"}, 'STR0022') // "Inclusao dos opcionais"

    oStrOpc:AddField('Matricula',; // Titulo do campo (Caracter) // "Cod. Seq."
                        '',; // ToolTip do campo (Caracter) // "Cod. Seq."
                        "MATRICULA",; // Id do Field (Caracter)
                        "C",; // Tipo do campo (Caracter)
                        17,; // Tamanho do campo (Numerico)
                        0,; // Decimal do campo (Numerico)
                        Nil,; // Code-block de validação do campo (Bloco de Codigo)
                        Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                        {},; // Lista de valores permitido do campo (Array)
                        .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                        ,; // Code-block de inicializacao do campo (Bloco de Codigo)
                        .F.,; // Indica se trata-se de um campo chave (Lógico)
                        .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                        .F.) // Indica se o campo é virtual (Lógico)

    oStrOpc:AddField("Resultado",; // Titulo do campo (Caracter) // "Cod. Seq."
                        '',; // ToolTip do campo (Caracter) // "Cod. Seq."
                        "RESULT",; // Id do Field (Caracter)
                        "C",; // Tipo do campo (Caracter)
                        1000,; // Tamanho do campo (Numerico)
                        0,; // Decimal do campo (Numerico)
                        Nil,; // Code-block de validação do campo (Bloco de Codigo)
                        Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                        {},; // Lista de valores permitido do campo (Array)
                        .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                        ,; // Code-block de inicializacao do campo (Bloco de Codigo)
                        .F.,; // Indica se trata-se de um campo chave (Lógico)
                        .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                        .F.) // Indica se o campo é virtual (Lógico)

Return  oStrOpc

//-------------------------------------------------------------------
/*/{Protheus.doc} PLPROPGEN
Cria Tabela e campos das propriedades genéricas

@since 01/10/2025
/*/
//------------------------------------------------------------------- 
Function PLPROPGEN()

    Local oStrGen    := NIL 
    Local nGen       := 0
    Local nLnGen     := 0
    Local oJCmpsGen  := NIL
    Local lFieldName := .F.
    Local lFieldType := .F.
    Local lFieldSize := .F.
    Local oTmpGen    := NIL 
    Local aFields    := {}
    Local cMsgRet   := ""
    Local lFdProp   := .T.
     
    If ExistBlock("PLMDGEN")

        ////////////////////////////////////////////////////////////
        //tabela temporaria
        oTmpGen := FWTemporaryTable():New("PROGEN")
        
        aAdd(aFields, {"SUCESSO" , "C",  15 , 0})         
        aAdd(aFields, {"DESCPROP", "C",  30 , 0})
        aAdd(aFields, {"RETORNO" , "C",  400, 0})
        
        oTmpGen:SetFields( aFields )
        
        If Select("PROGEN") > 0 
            PROGEN->(DbCloseArea())
        EndIf
        
        oTmpGen:Create()
        //FIM
        ////////////////////////////////////////////////////////////
		
        If ExistBlock("PLMDGEN")
        
            oJCmpsGen := ExecBlock("PLMDGEN",.F.,.F.)
            nLnGen := Len(oJCmpsGen)

            If  nLnGen > 0

                oStrGen    := FWFormModelStruct():New()
                oStrGen:AddTable("PROPGEN", {"JSONGEN"}, 'STR0022') 

                For nGen := 1 To nLnGen
                    
                    cMsgRet := ""
                    
                    ////////////////////////////////////////////////////////////////////////////////////////////////
                    //verifica a existencias das propriedades obrigatorias no json vindo do ponto de entrada
                    lFdProp := oJCmpsGen[nGen]:HasProperty("fieldName") .AND. oJCmpsGen[nGen]:HasProperty("fieldType") .AND. oJCmpsGen[nGen]:HasProperty("fieldSize")
                    
                    If !lFdProp
                        cMsgRet += "As propriedades fieldSize, fieldType e fieldSize são obrigatórios no objeto json utilizado para a criação dos campos "
                        cMsgRet += "do modelo de dados pelo PE PLMDGEN e nem todos os atributos foram encontrados."
                    EndIf
                    //FIM
                    ////////////////////////////////////////////////////////////////////////////////////////////////

                    //se encontrou todas as propriedades no campo que esta sendo processado, segue com o fluxo
                    If lFdProp

                        lFieldName := !Empty(oJCmpsGen[nGen]["fieldName"])
                        lSizeName  := Len(oJCmpsGen[nGen]["fieldName"]) <= 30
                        lFieldType := !Empty(oJCmpsGen[nGen]["fieldType"])
                        lFieldSize := !Empty(oJCmpsGen[nGen]["fieldSize"])

                        If lFieldName .AND. lSizeName .AND. lFieldType .AND. lFieldSize
                            
                            oStrGen:AddField(Upper(oJCmpsGen[nGen]["fieldName"]),; // Titulo do campo (Caracter) // "Cod. Seq."
                                            '',; // ToolTip do campo (Caracter) // "Cod. Seq."
                                            oJCmpsGen[nGen]["fieldName"],; // Id do Field (Caracter)
                                            oJCmpsGen[nGen]["fieldType"],; // Tipo do campo (Caracter)
                                            oJCmpsGen[nGen]["fieldSize"],; // Tamanho do campo (Numerico)
                                            oJCmpsGen[nGen]["decimal"],; // Decimal do campo (Numerico)
                                            Nil,; // Code-block de validação do campo (Bloco de Codigo)
                                            Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                                            {},; // Lista de valores permitido do campo (Array)
                                            .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                                            NIL,; // Code-block de inicializacao do campo (Bloco de Codigo)
                                            .F.,; // Indica se trata-se de um campo chave (Lógico)
                                            .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                                            .F.) // Indica se o campo é virtual (Lógico)

                        Else
                            If !lFieldName
                                cMsgRet := "A propriedade fieldName não foi preenchida no PE PLMDGEN" + CRLF
                            EndIf

                            If !lSizeName
                                cMsgRet += "A descrição na propriedade fieldSize não pode ser maior que 30 posições, o ajuste deve ser feito no PE PLMDGEN " + CRLF
                            EndIf
                            
                            If !lFieldType
                                cMsgRet += "O tipo de dado na propriedade fieldType não foi preenchida (C,N,L) no PE PLMDGEN " + CRLF
                            EndIf

                            If !lFieldSize
                                cMsgRet += "O tamanho não foi definido na propriedade fieldSize PE PLMDGEN"
                            EndIf
                        EndIf
                    EndIf

                    //popula a tabela utilizada no response com as informacoes referente a criacao dos campos no modelo
                    PROGEN->(RecLock("PROGEN",.T.)) 
                    PROGEN->SUCESSO  := If(!Empty(cMsgRet), "0" /*falso*/, "1" /*verdadeiro*/)
                    PROGEN->DESCPROP := AllTrim(oJCmpsGen[nGen]["fieldName"])
                    PROGEN->RETORNO  := If(!Empty(AllTrim(cMsgRet)), AllTrim(cMsgRet), "OK")
                    PROGEN->(MsUnLock()) 
                Next
                
                //campos especificos para retornar o status de criacao de cada campo no modelo de dados
                oStrGen:AddField("SUCESSO",; // Titulo do campo (Caracter) // "Cod. Seq."
                                '',; // ToolTip do campo (Caracter) // "Cod. Seq."
                                "SUCESSO",; // Id do Field (Caracter)
                                "C",; // Tipo do campo (Caracter)
                                15,; // Tamanho do campo (Numerico)
                                0,; // Decimal do campo (Numerico)
                                Nil,; // Code-block de validação do campo (Bloco de Codigo)
                                Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                                {},; // Lista de valores permitido do campo (Array)
                                .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                                {||"CAMPO RESERVADO"},; // Code-block de inicializacao do campo (Bloco de Codigo)
                                .F.,; // Indica se trata-se de um campo chave (Lógico)
                                .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                                .F.) // Indica se o campo é virtual (Lógico)
                              
                oStrGen:AddField("DESCPROP",; // Titulo do campo (Caracter) // "Cod. Seq."
                                '',; // ToolTip do campo (Caracter) // "Cod. Seq."
                                "DESCPROP",; // Id do Field (Caracter)
                                "C",; // Tipo do campo (Caracter)
                                30,; // Tamanho do campo (Numerico)
                                0,; // Decimal do campo (Numerico)
                                Nil,; // Code-block de validação do campo (Bloco de Codigo)
                                Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                                {},; // Lista de valores permitido do campo (Array)
                                .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                                {||"CAMPO RESERVADO"},; // Code-block de inicializacao do campo (Bloco de Codigo)
                                .F.,; // Indica se trata-se de um campo chave (Lógico)
                                .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                                .F.) // Indica se o campo é virtual (Lógico)
                
                oStrGen:AddField("RETORNO",; // Titulo do campo (Caracter) // "Cod. Seq."
                                '',; // ToolTip do campo (Caracter) // "Cod. Seq."
                                "RETORNO",; // Id do Field (Caracter)
                                "C",; // Tipo do campo (Caracter)
                                400,; // Tamanho do campo (Numerico)
                                0,; // Decimal do campo (Numerico)
                                Nil,; // Code-block de validação do campo (Bloco de Codigo)
                                Nil,; // Code-block de validação When do campo (Bloco de Codigo)
                                {},; // Lista de valores permitido do campo (Array)
                                .F.,; // Indica se o campo tem preenchimento obrigatário (Lógico)
                                {||"CAMPO RESERVADO"},; // Code-block de inicializacao do campo (Bloco de Codigo)
                                .F.,; // Indica se trata-se de um campo chave (Lógico)
                                .F.,; // Indica se o campo pode receber valor em uma operação de update (Lógico)
                                .F.) // Indica se o campo é virtual (Lógico)
            EndIf
        EndIf
	EndIf

Return oStrGen
