#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include 'FWMVCDEF.CH'
#Include 'GCPPCPProc.CH'


/*/{Protheus.doc} GCPAtEdPcp
    (atualiza o edital  conforme as etapas
    no portal de Compras Públicas)
    @type  Function
    @author Thiago Rodrigues
    @since 01/04/2024
    @Param Codigo do edital, numero do proceso, revisão, json/obter processo
    @see (links_or_references)
/*/
Function GCPPCPProc(cCodEdt,cNumpro,cRevisa,cRetObter)
local oDadosEdt  := Nil
local lOk        := .T.

If CO1->(DbSeek( xFilial("CO1") + cCodEdt + cNumpro + cRevisa ))

    oDadosEdt:= JsonObject():New() 
    oDadosEdt:FromJson(cRetObter)

    //Inclui os fornecedores na SA2 caso não exista, e também no edital
    lOk := GcpPCPFor(oDadosEdt)

    //Edital ja parado em "HO" aguardando homologacao parcial (CO1_STATUS = "C")
    if lOk .And. DKF->DKF_STATUS == "6" .And. CO1->CO1_STATUS == "C"
        lOk := GcpMrkParc(oDadosEdt, cCodEdt, cNumpro)
    elseif lOk .And. DKF->DKF_STATUS == "6" //Processamento do edital até a etapa de homologaço/ Adjudicação. Somente quando status é encerrado no portal de compras publicas.
        lOk := GCP200PERM(oDadosEdt)
    Endif 

    // Atualiza o edital com status: Fracassado / Deserto
    if DKF->DKF_STATUS == "4" .OR. (DKF->(DKF_STATUS == "2" .And. DKF_DSCSTS == "Processo Fracassado"))                                
        If CO1->(RecLock("CO1", .F.))
            CO1->CO1_STATUS := "5" 
            CO1->(MsUnlock())
        EndIf
    Endif

    FreeObj(oDadosEdt)
endif


Return lOk


/*/{Protheus.doc} GCP200PERM
    ( Realiza o Andamento das etapas no portal.
    o Sistema entende que é um andamento por que a função GCP200PERM 
    está no CallStack )
    @type  Function
    @author Thiago Rodrigues
    @since 01/04/2024
    @Param 
    @see (links_or_references)
/*/
static function GCP200PERM(oDadosEdt)
local oModGCP200 := Nil
local oModelCOW  := Nil
local oModCO1    := Nil
local nX         := 1
local nI         := 1
local aFluxo     := {}
local nPosIni    := 0
local nPosFim    := 0
local cPublJson  := ""
Local dDtVazia   := cTod("")
local dDtPubl    := dDtVazia
local dDtAdj     := dDtVazia
local cHrADJ     := ""
local dDtHML     := dDtVazia
local cHrHML     := ""
local dDtHmlIn   := dDtVazia
local lRet       := .T.
Local cEtapa     := CO1->CO1_ETAPA
local cModel     := ""

aFluxo     := GCPEtpsEdt(CO1->CO1_REGRA, CO1->CO1_MODALI) //Fluxo de etapas conforme lei e modalidade
nPosIni    := aScan(aFluxo, cEtapa) //posição inicial - fluxo de etapas
nPosFim    := aScan(aFluxo, "HO")   // posição final
cModel     := iif(CO1->CO1_AVAL == "1","GCPA200","GCPA201") //1=Por Item;2=Por Lote

//Habilita a Homologacao Parcial do Edital
HabHomParc(nPosIni,nPosFim,oDadosEdt,aFluxo)

For nI := nPosIni To nPosFim 

    cEtapa := CO1->CO1_ETAPA // Atualiza a variavel para etapa atual

    //Proteção para não tentar gerar o documento 
    //caso inicie o processamento com edital nesta etapa.
    if (cEtapa == "AD" .And. CO1->CO1_LEI != "5" ) .Or. (CO1->CO1_LEI == "5" .And. cEtapa == "HO")
        exit
    endif

    oModGCP200 := FWLoadModel(cModel)
    oModGCP200:SetOperation( MODEL_OPERATION_UPDATE )
    oModGCP200:Activate()

    oModelCOW := oModGCP200:GetModel("COWDETAIL")
    oModCO1   := oModGCP200:GetModel("CO1MASTER")

    //Atualiza a publicação 
    if nI == nPosIni
    
        //Publicação ou Republicação
        if ValType(oDadosEdt['Republicacao']) == 'A' .and. Len(oDadosEdt['Republicacao']) > 0
            cPublJson := "Republicacao"
        elseif ValType(oDadosEdt['Publicacao']) == 'A' .and. Len(oDadosEdt['Publicacao']) > 0
            cPublJson := "Publicacao"
        endif

        for Nx := 1 To Len(oDadosEdt[cPublJson])
            dDtPubl := cTod(oDadosEdt[cPublJson][Nx]["DATA"])
        Next Nx
        
        oModCO1:LoadValue("CO1_DTPUBL",dDtPubl)// Data de publicação
        oModCO1:LoadValue("CO1_CNPUBL",STR0001) //Portal de Compras Públicas
    Endif

    //Data de abertura dos envelopes
    if cEtapa $ "AE" 
        oModCO1:LoadValue("CO1_DTENV", dDataBase)
    endif

    //Se for Inexebilidade ou Dispensa por lote cria a CP6 , pois a composição só é criada automaticamente pela trigger: CO3TrigCP6 para modalidades que tem etapa de publicação.
    if nI == nPosIni .And. cModel == "GCPA201" .And. (CO1->CO1_MODALI $  "IN|DL")  
        CriaCP6(oModGCP200)
    endif
   
    if (cEtapa $ "JP|NE" .and. !CO1->CO1_MODALI == "RD") .Or. (CO1->CO1_MODALI == "RD" .And. cEtapa =="AE" )

        //Declarar os licitantes vencedores
        GcpAtuVenc(oModGCP200,oDadosEdt,CO1->CO1_AVAL,@dDtHmlIn)

        //Atualiza o valor da composição do lote
        if cModel == "GCPA201" 
            GcpVlrComp(oModGCP200,oDadosEdt)
        Endif

    endif

    //Atualiza homologação e ajdudicação
    if cEtapa $ "HO"

        if CO1->CO1_MODALI != "IN" 
            if Len(oDadosEdt["Notificacoes"]) > 0 
                for Nx := 1 To Len(oDadosEdt["Notificacoes"])

                    if oDadosEdt["Notificacoes"][Nx]["SIGLA_LICITACON"] == "ADH"
                        dDtHML := oDadosEdt["Notificacoes"][Nx]["DATA"]
                        cHrHML := oDadosEdt["Notificacoes"][Nx]["HORA"]
                    elseif oDadosEdt["Notificacoes"][Nx]["SIGLA_LICITACON"] == "ADJ"
                        dDtAdj := oDadosEdt["Notificacoes"][Nx]["DATA"]
                        cHrADJ := oDadosEdt["Notificacoes"][Nx]["HORA"]
                    endif

                Next Nx

                //Atualiza o Edital
                oModCO1:LoadValue("CO1_DTADJU",cTod(dDtAdj)) // Data adjudicação
                oModCO1:LoadValue("CO1_HRADJU",substr(cHrADJ,1,5)) // Hora adjuddiação

                oModCO1:LoadValue("CO1_DTHOMO",cTod(dDtHML)) // Data Homologação
                oModCO1:LoadValue("CO1_HRHOMO",substr(cHrHML,1,5)) // Hora Homologação
            endif
        else // Tratamento para inexebilidade
            oModCO1:LoadValue("CO1_DTADJU",cTod(oDadosEdt["DATA_ADJUDICACAO"]))
            oModCO1:LoadValue("CO1_DTHOMO",dDtHmlIn)
        endif    
    endif


    //-- COW - Edital x Checklist
    For nX := 1 To oModGCP200:GetModel('COWDETAIL'):Length()
        oModGCP200:GetModel('COWDETAIL'):GoLine(nX)
        If	!Empty( oModelCOW:GetValue("COW_ETAPA") )
            oModGCP200:SetValue('COWDETAIL','COW_CHKOK',.T.)
        EndIf
    Next

    // o LMODIFY Precisa ser .T. para o Model entender que houve modificação, para casos onde somente temos que avançar as etapas e nao tem checklist.
    if !oModGCP200:LMODIFY
        oModCO1:LoadValue('CO1_TIPO',CO1->CO1_TIPO)
    endif

    If lRet:= oModGCP200:VldData()
        lRet := oModGCP200:CommitData()
    else 
        LogPcpProc(STR0002 + Alltrim(CO1->CO1_CODEDT) +; //"Falha ao dar andamento no edital: "
         STR0003 + iiF(len(oModGCP200:GetErrorMessage())> 5, oModGCP200:GetErrorMessage()[6],"" ) ,.T.) //" erro:  "
         exit
    endif


    //- Desativa o modelo de dados
    oModGCP200:DeActivate()
    oModGCP200:=nil

Next nI



return lRet


/*/{Protheus.doc} GcpPCPFor
(Faz o cadastro de fornecedores e inclui os licitantes no Edital)
@type Function
@author Thiago Rodrigues
@since 02/04/2024
/*/
Function GcpPCPFor(oDadosEdt)

    Local nFor       := 1
    Local oModelFor  := Nil 
    Local oFindSA2   := Nil
    Local cAliTmp    := GetNextAlias() 
    Local cQryStat   := Nil
    Local cLoja      := ""
    Local cCod       := ""
    Local cTipo      := ""
    Local cCpfCgC    := ""
    Local aArea      := FwGetArea()
    Local lOk        := .T.
    Local oModGCP200 := Nil 
    Local oCO3       := Nil 
    Local oCp3       := Nil
    Local oCO1       := Nil 
    Local oCo2       := Nil
    Local cItem      := ""
    Local cItemCo2   := ""
    Local nLote      := 1
    Local nProd      := 1
    Local nPartic    := 1
    Local nProp      := 1
    Local cCodCo3    := ""
    Local cLojCo3    := ""
    Local cNomeCo3   := ""
    Local cTipoCo3   := ""
    Local xFilSA2    := xFilial("SA2")
    Local aPartic    := {}
    Local cModel     := ""
    Local lAtuEdit   := !IsInCallStack("GCPA600")
    Local aProp      := {}
    Local cNomeLote  := ""
    Local nTamCP3LT  := TamSx3("CP3_LOTE")[1]
    Local nTamCO3IT  := TamSx3("CO3_ITEM")[1]
    Local nTamCO2IT  := TamSx3("CO2_ITEM")[1]

    // 1. Cadastro de Fornecedores na SA2
    If ValType(oDadosEdt['Participantes']) == 'A' .And. Len(oDadosEdt['Participantes']) > 0

        For nFor := 1 To Len(oDadosEdt['Participantes'])

            AAdd(aPartic, {oDadosEdt['Participantes'][nFor]["CNPJ"], Iif(oDadosEdt['Participantes'][nFor]["Licitante"], "2", "1")})

            cTipo   := Iif(At("J", DecodeUTF8(oDadosEdt['Participantes'][nFor]["Tipo"])) > 0, "J", "F")
            cCpfCgC := Iif(cTipo == "J", "CNPJ", "CPF")

            oFindSA2 := FWPreparedStatement():New()

            cQuery := " SELECT SA2.A2_COD COD, SA2.A2_LOJA LOJA, SA2.A2_NOME NOME "
            cQuery += " FROM " + RetSqlName('SA2') + " SA2"
            cQuery += " WHERE SA2.A2_FILIAL = ? AND"
            cQuery += " SA2.A2_CGC = ? AND"
            cQuery += " SA2.D_E_L_E_T_ = ? "
            cQuery := ChangeQuery(cQuery)

            oFindSA2:SetQuery(cQuery)
            oFindSA2:SetString(1, FWxFilial("SA2"))
            oFindSA2:SetString(2, oDadosEdt['Participantes'][nFor][cCpfCgC])
            oFindSA2:SetString(3, Space(1))

            cQryStat := oFindSA2:GetFixQuery()
            MpSysOpenQuery(cQryStat, cAliTmp)

            If (cAliTmp)->(Eof())

                If Empty(GetAdvFVal("SX3", "X3_RELACAO", "A2_LOJA"))
                    cLoja := "01"
                EndIf
                
                If Empty(GetAdvFVal("SX3", "X3_RELACAO", "A2_COD"))
                    cCod := GetSxeNum("SA2", "A2_COD") 

                    While SA2->(MsSeek(xFilial("SA2") + cCod)) 
                        ConfirmSX8() 
                        cCod := GetSxeNum("SA2", "A2_COD") 
                    EndDo 
                EndIf
                
                oModelFor := FWLoadModel("MATA020")
                oModelFor:SetOperation(MODEL_OPERATION_INSERT)
                oModelFor:Activate()

                If !Empty(cCod) 
                    oModelFor:SetValue("SA2MASTER", "A2_COD", cCod)
                EndIf

                If !Empty(cLoja)
                    oModelFor:SetValue("SA2MASTER", "A2_LOJA", cLoja)
                EndIf

                oModelFor:SetValue("SA2MASTER", "A2_NOME", DecodeUTF8(oDadosEdt['Participantes'][nFor]["RazaoSocial"]))
                oModelFor:SetValue("SA2MASTER", "A2_NREDUZ", DecodeUTF8(oDadosEdt['Participantes'][nFor]["NomeFantasia"]))
                oModelFor:SetValue("SA2MASTER", "A2_END", DecodeUTF8(oDadosEdt['Participantes'][nFor]["Endereco"]))
                oModelFor:SetValue("SA2MASTER", "A2_EST", oDadosEdt['Participantes'][nFor]["UF"])
                oModelFor:SetValue("SA2MASTER", "A2_COD_MUN", SubStr(oDadosEdt['Participantes'][nFor]["CD_MUNICIPIO_IBGE"], 3, 7))
                oModelFor:SetValue("SA2MASTER", "A2_BAIRRO", DecodeUTF8(oDadosEdt['Participantes'][nFor]["Bairro"]))
                oModelFor:SetValue("SA2MASTER", "A2_TIPO", cTipo)
                oModelFor:SetValue("SA2MASTER", "A2_CGC", oDadosEdt['Participantes'][nFor][cCpfCgC])

                If ValType(oDadosEdt['Participantes'][nFor]["INSCRICAO_ESTADUAL"]) == "C"
                    oModelFor:SetValue("SA2MASTER", "A2_INSCR", oDadosEdt['Participantes'][nFor]["INSCRICAO_ESTADUAL"])
                EndIf

                If ValType(oDadosEdt['Participantes'][nFor]["INSCRICAO_MUNICIPAL"]) == "C"
                    oModelFor:SetValue("SA2MASTER", "A2_INSCRM", oDadosEdt['Participantes'][nFor]["INSCRICAO_MUNICIPAL"])
                EndIf

                If lOk := oModelFor:VldData()
                    oModelFor:CommitData()
                Else 
                    If Len(oModelFor:GetErrorMessage()) > 5
                        LogPcpProc(STR0004 + oModelFor:GetErrorMessage()[6], .T.)
                    EndIf
                EndIf

                oModelFor:DeActivate()
                oModelFor := Nil
                FreeObj(oModelFor) 
            EndIf 

            (cAliTmp)->(DbCloseArea())
        Next nFor

        FreeObj(oFindSA2) 
    EndIf

    // 2. Inclusão dos Licitantes na Tabela CO3 do Edital
    If lOk .And. lAtuEdit
        
        cModel := Iif(CO1->CO1_AVAL == "1", "GCPA200", "GCPA201")

        oModGCP200 := FWLoadModel(cModel)
        oModGCP200:SetOperation(MODEL_OPERATION_UPDATE)
        oModGCP200:Activate()

        oCO1 := oModGCP200:GetModel("CO1MASTER")
        oCO3 := oModGCP200:GetModel("CO3DETAIL")
        oCp3 := oModGCP200:GetModel("CP3DETAIL")
        oCo2 := oModGCP200:GetModel("CO2DETAIL")

        oCO1:LoadValue("CO1_DATARP", cToD(oDadosEdt["dataAberturaPropostas"]))
        oCO1:LoadValue("CO1_HORAAB", oDadosEdt["horaAberturaPropostas"])

        aProp := GetPropMdl(oCO3)
        CNTA300BlMd(oCO3, .F.)

        If cModel == "GCPA201" // Edital por Lote

            If oDadosEdt['operacaoLote'] == 1 // Disputa por Lote Global

                If ValType(oDadosEdt['lotes']) == "A"
                    For nLote := 1 To Len(oDadosEdt['lotes']) 

                        cNomeLote := PadR(AllTrim(DecodeUTF8(oDadosEdt['lotes'][nLote]["DS_LOTE"])), nTamCP3LT)

                        // Busca estrutural nominal do Lote ao invés de usar GoLine(NR_LOTE)
                        If oCp3:SeekLine({{"CP3_LOTE", cNomeLote}})
                            cItem    := Replicate("0", nTamCO3IT)
                            cTipoCo3 := "2"

                            // Itera sobre o nó "Propostas" válidas dos itens do lote
                            If ValType(oDadosEdt['lotes'][nLote]['itens']) == "A"
                                For nProd := 1 To Len(oDadosEdt['lotes'][nLote]['itens'])
                                    If ValType(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"]) == "A"
                                        For nProp := 1 To Len(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"]) 
                                
                                            If oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["Valido"]
                                
                                                cCodCo3  := GetAdvFVal("SA2", "A2_COD", xFilSA2 + oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"], 3)
                                                cLojCo3  := GetAdvFVal("SA2", "A2_LOJA", xFilSA2 + cCodCo3, 1)
                                                cNomeCo3 := GetAdvFVal("SA2", "A2_NOME", xFilSA2 + cCodCo3 + cLojCo3, 1)
                                
                                                If !oCO3:SeekLine({{"CO3_LOTE", oCp3:GetValue("CP3_LOTE")}, ;
                                                                   {"CO3_CODIGO", cCodCo3}, ;
                                                                   {"CO3_LOJA", cLojCo3}})

                                                    If Len(aPartic) > 0 .And. (nPartic := aScan(aPartic, {|x| AllTrim(x[1]) == AllTrim(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"])})) > 0
                                                        cTipoCo3 := aPartic[nPartic][2]
                                                    Else
                                                        cTipoCo3 := "2"
                                                    EndIf

                                                    If !Empty(oCO3:GetValue("CO3_CODIGO"))
                                                        oCO3:AddLine() 
                                                    EndIf

                                                    cItem := Soma1(cItem)
                                                    oCO3:LoadValue("CO3_LOTE", oCp3:GetValue("CP3_LOTE"))
                                                    oCO3:LoadValue("CO3_CODIGO", cCodCo3)
                                                    oCO3:LoadValue("CO3_LOJA", cLojCo3)
                                                    oCO3:LoadValue("CO3_NOME", cNomeCo3)
                                                    oCO3:LoadValue("CO3_TIPO", cTipoCo3)
                                                    oCO3:LoadValue("CO3_ITEM", cItem) 
                                                EndIf
                                            EndIf
                                        Next nProp
                                    EndIf
                                Next nProd
                            EndIf 
                        EndIf
                    Next nLote
                EndIf

            ElseIf oDadosEdt['operacaoLote'] == 2 // Disputa por Item dentro do Lote

                If ValType(oDadosEdt['lotes']) == "A"
                    For nLote := 1 To Len(oDadosEdt['lotes'])
                        
                        cNomeLote := PadR(AllTrim(DecodeUTF8(oDadosEdt['lotes'][nLote]["DS_LOTE"])), nTamCP3LT)

                        If oCp3:SeekLine({{"CP3_LOTE", cNomeLote}})

                            If ValType(oDadosEdt['lotes'][nLote]['itens']) == "A"
                                For nProd := 1 To Len(oDadosEdt['lotes'][nLote]['itens'])

                                    cItemCo2 := StrZero(Val(oDadosEdt['lotes'][nLote]['itens'][nProd]['_id']), nTamCO2IT)
                                    cItem    := Replicate("0", nTamCO3IT)
                                    cTipoCo3 := "2"

                                    If oCO2:SeekLine({{"CO2_ITEM", cItemCo2}})
                                        If ValType(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"]) == "A"
                                            For nProp := 1 To Len(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"]) 
                                
                                                If oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["Valido"]
                                                    cCodCo3  := GetAdvFVal("SA2", "A2_COD", xFilSA2 + oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"], 3)
                                                    cLojCo3  := GetAdvFVal("SA2", "A2_LOJA", xFilSA2 + cCodCo3, 1)
                                                    cNomeCo3 := GetAdvFVal("SA2", "A2_NOME", xFilSA2 + cCodCo3 + cLojCo3, 1)

                                                    If !oCO3:SeekLine({{"CO3_LOTE", oCp3:GetValue("CP3_LOTE")}, ;
                                                                       {"CO3_CODIGO", cCodCo3}, ;
                                                                       {"CO3_LOJA", cLojCo3}})
                                
                                                        If Len(aPartic) > 0 .And. (nPartic := aScan(aPartic, {|x| AllTrim(x[1]) == AllTrim(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"])})) > 0
                                                            cTipoCo3 := aPartic[nPartic][2]
                                                        Else
                                                            cTipoCo3 := "2"
                                                        EndIf

                                                        If !Empty(oCO3:GetValue("CO3_CODIGO"))
                                                            oCO3:AddLine() 
                                                        EndIf

                                                        cItem := Soma1(cItem)
                                                        oCO3:LoadValue("CO3_LOTE", oCp3:GetValue("CP3_LOTE"))
                                                        oCO3:LoadValue("CO3_CODIGO", cCodCo3)
                                                        oCO3:LoadValue("CO3_LOJA", cLojCo3)
                                                        oCO3:LoadValue("CO3_NOME", cNomeCo3)
                                                        oCO3:LoadValue("CO3_TIPO", cTipoCo3)
                                                        oCO3:LoadValue("CO3_ITEM", cItem)
                                                    EndIf
                                                EndIf
                                            Next nProp
                                        EndIf 
                                    EndIf
                                Next nProd
                            EndIf 
                        EndIf
                    Next nLote
                EndIf
            
            EndIf

        Else // Edital por Item (GCPA200)

            If ValType(oDadosEdt['lotes']) == "A"
                For nLote := 1 To Len(oDadosEdt['lotes']) 
                    If ValType(oDadosEdt['lotes'][nLote]['itens']) == "A"
                        For nProd := 1 To Len(oDadosEdt['lotes'][nLote]['itens'])

                            cItemCo2 := StrZero(Val(oDadosEdt['lotes'][nLote]['itens'][nProd]['_id']), nTamCO2IT)
                            cItem    := Replicate("0", nTamCO3IT)
                            cTipoCo3 := "2"

                            If oCO2:SeekLine({{"CO2_ITEM", cItemCo2}})
                                If ValType(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"]) == "A"
                                    For nProp := 1 To Len(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"])
                                        
                                        If oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["Valido"]
                                            cCodCo3  := GetAdvFVal("SA2", "A2_COD", xFilSA2 + oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"], 3)
                                            cLojCo3  := GetAdvFVal("SA2", "A2_LOJA", xFilSA2 + cCodCo3, 1)
                                            cNomeCo3 := GetAdvFVal("SA2", "A2_NOME", xFilSA2 + cCodCo3 + cLojCo3, 1)

                                            If !oCO3:SeekLine({{"CO3_CODPRO", oCO2:GetValue("CO2_CODPRO")}, {"CO3_CODIGO", cCodCo3}, {"CO3_LOJA", cLojCo3}})
                                                If Len(aPartic) > 0 .And. (nPartic := aScan(aPartic, {|x| AllTrim(x[1]) == AllTrim(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"])})) > 0
                                                    cTipoCo3 := aPartic[nPartic][2]
                                                Else
                                                    cTipoCo3 := "2"
                                                EndIf

                                                If !Empty(oCO3:GetValue("CO3_CODIGO"))
                                                    oCO3:AddLine() 
                                                EndIf

                                                cItem := Soma1(cItem)
                                                oCO3:LoadValue("CO3_CODPRO", oCO2:GetValue("CO2_CODPRO"))
                                                oCO3:LoadValue("CO3_CODIGO", cCodCo3)
                                                oCO3:LoadValue("CO3_LOJA", cLojCo3)
                                                oCO3:LoadValue("CO3_NOME", cNomeCo3)
                                                oCO3:LoadValue("CO3_TIPO", cTipoCo3)
                                                oCO3:LoadValue("CO3_ITEM", cItem)
                                            EndIf
                                        EndIf
                                    Next nProp
                                EndIf 
                            EndIf
                        Next nProd
                    EndIf 
                Next nLote
            EndIf 

        EndIf

        If oModGCP200:VldData()
            lOk := oModGCP200:CommitData()
        else 
            LogPcpProc(STR0005,.T.)//"Falha ao gravar os licitantes no edital."
		endif

        RstPropMdl(oCO3, aProp)
        oModGCP200:DeActivate()
    EndIf

    FwRestArea(aArea)
    FwFreeArray(aArea)
    FwFreeArray(aProp)
 
Return lOk

/*/{Protheus.doc} GcpAtuVenc
(Declara o fornecedor Campeão e atualiza os valores)
@type  Static Function
@author Thiago Rodrigues
@since 04/04/2024
/*/
Static Function GcpAtuVenc(oModGCP200, oDadosEdt, cAvaliacao, dDtHmlIn)

    Local oModCO3   := oModGCP200:GetModel("CO3DETAIL")
    Local oModCP3   := oModGCP200:GetModel("CP3DETAIL")
    Local oModCO2   := oModGCP200:GetModel("CO2DETAIL")
    Local oModCO1   := oModGCP200:GetModel("CO1MASTER")
    Local oLote     := Nil
    Local oItem     := Nil
    Local nX        := 1 
    Local nP        := 1 
    Local cItemCo2  := ""
    Local cNomeLote := ""

    Local aSaveLines := {}
    Local dDataVazia := cToD("")
    Local lIsLote    := .F.
    Local lHmParcial := oModCO1:GetValue("CO1_HMPARC")
    Local nTamCP3LT  := TamSx3("CP3_LOTE")[1]
    Local nTamCO2IT  := TamSx3("CO2_ITEM")[1]

    Default cAvaliacao := "1"
    Default dDtHmlIn   := dDataVazia

    aSaveLines := FWSaveRows()
    lIsLote    := (cAvaliacao == "2")

    If lIsLote
        If ValType(oDadosEdt['lotes']) == "A"
            For nX := 1 To Len(oDadosEdt['lotes'])

                oLote     := oDadosEdt['lotes'][nX]
                cNomeLote := PadR(AllTrim(DecodeUTF8(oLote["DS_LOTE"])), nTamCP3LT)
                
                // Busca nominal do Lote via DS_LOTE ao invés do GoLine(NR_LOTE)
                If oModCP3:SeekLine({{"CP3_LOTE", cNomeLote}})
                    
                    // Repassa o cNomeLote e lHmParcial para realizar o filtro/guarda
                    // de status dentro da ProLanLote (CO3_STATUS "5" so' quando o
                    // lote ja' foi efetivamente homologado - ver ProLanLote)
                    ProLanLote(oModCO3, oLote, oDadosEdt['operacaoLote'], cNomeLote, lHmParcial)

                    If lHmParcial .And. GcpLoteHom(oLote)
                        oModCP3:SetNoUpdateLine(.F.)
                        oModCP3:LoadValue("CP3_HOMOLO", .T.)
                        oModCP3:SetNoUpdateLine(.T.)

                        // Sincroniza CO2_HOMOLO dos itens do lote agora homologado -
                        // garante consistencia relacional entre CP3 (lote) e CO2
                        // (produtos), sem depender do SQL direto de GCP200Grv (que so
                        // roda depois do commit, na etapa "HO")
                        MrkCO2Lote(oModCO2, cNomeLote)
                    EndIf

                    If oModCO1:GetValue("CO1_MODALI") == "IN" .And. ValType(oLote['itens']) == "A"
                        For nP := 1 To Len(oLote['itens'])
                            If !Empty(oLote['itens'][nP]["DATA_HOMOLOGACAO"])
                                dDtHmlIn := cToD(oLote['itens'][nP]["DATA_HOMOLOGACAO"])
                            EndIf
                        Next nP
                    EndIf
                EndIf
            Next nX
        EndIf 
    Else
        If ValType(oDadosEdt['lotes']) == "A"
            For nX := 1 To Len(oDadosEdt['lotes']) 
                oLote := oDadosEdt['lotes'][nX]
                If ValType(oLote['itens']) == "A"
                    For nP := 1 To Len(oLote['itens'])

                        oItem    := oLote['itens'][nP]
                        cItemCo2 := StrZero(Val(oItem['_id']), nTamCO2IT)
                        dDtHmlIn := dDataVazia

                        If oModCO2:SeekLine({{"CO2_ITEM", cItemCo2}})
                            ProLanItem(oModCO3, oLote, oItem, oLote['Vencedores'], oLote['Inabilitados'], oModCO2:GetValue("CO2_CODPRO"), oDadosEdt['operacaoLote'], lHmParcial)

                            If lHmParcial .And. !Empty(oItem["DATA_HOMOLOGACAO"])
                                oModCO2:SetNoUpdateLine(.F.)
                                oModCO2:LoadValue("CO2_HOMOLO", .T.)
                                oModCO2:SetNoUpdateLine(.T.)
                            EndIf
                        EndIf

                        If oModCO1:GetValue("CO1_MODALI") == "IN" .And. !Empty(oDadosEdt['lotes'][nX]['itens'][nP]["DATA_HOMOLOGACAO"])
                            dDtHmlIn := cToD(oItem["DATA_HOMOLOGACAO"])
                        EndIf

                    Next nP
                EndIf 
            Next nX
        EndIf
    EndIf

    FWRestRows(aSaveLines)
    FwFreeArray(aSaveLines)

Return

/*/{Protheus.doc} GcpVlrComp
(Atualiza os valores da composição do lote baseando-se de onde vêm os lances: Lote ou Item)
@type Static Function
@author Thiago Rodrigues
@since 04/04/2024
/*/
Static Function GcpVlrComp(oModGCP200, oDadosEdt)

    Local oCp3      As Object
    Local oCP6      As Object
    Local oCo3      As Object
    Local oCo2      As Object
    Local nNroLote  As Numeric
    Local nForLic   As Numeric
    Local nForIT    As Numeric
    Local cCnpj     As Character
    Local cCodCo2   As Character
    Local cFilSA2   As Character
    Local lMD       As Logical
    Local oLote     As Object
    Local oItem     As Object
    Local aArea     As Array
    Local nVlUnit   As Numeric
    Local cNomeLote As Character
    Local nTamCP3LT As Numeric
    Local nTamCO2IT As Numeric

    oCp3      := oModGCP200:GetModel("CP3DETAIL")
    oCP6      := oModGCP200:GetModel("CP6DETAIL")
    oCo3      := oModGCP200:GetModel("CO3DETAIL")
    oCo2      := oModGCP200:GetModel("CO2DETAIL")
    cFilSA2   := xFilial("SA2")
    aArea     := FwGetArea()
    nTamCP3LT := TamSx3("CP3_LOTE")[1]
    nTamCO2IT := TamSx3("CO2_ITEM")[1]

    If ValType(oDadosEdt['lotes']) == "A"
 
        For nNroLote := 1 To Len(oDadosEdt['lotes']) 
            oLote     := oDadosEdt['lotes'][nNroLote]
            cNomeLote := PadR(AllTrim(DecodeUTF8(oLote["DS_LOTE"])), nTamCP3LT)

            If oCp3:SeekLine({{"CP3_LOTE", cNomeLote}})

                If ValType(oLote["itens"]) == "A"
 
                    For nForLic := 1 To oCo3:Length()
                        oCo3:GoLine(nForLic) 

                        cCnpj := GetAdvFVal("SA2", "A2_CGC", cFilSA2 + oCo3:GetValue("CO3_CODIGO") + oCo3:GetValue("CO3_LOJA"), 1)
 
                        For nForIT := 1 To Len(oLote["itens"])
                            oItem := oLote["itens"][nForIT]
                            lMD   := oItem["tipoJulgamento"] == "Maior Desconto"

                            cCodCo2 := StrZero(Val(oItem['_id']), nTamCO2IT)
 
                            If oCo2:SeekLine({{"CO2_ITEM", cCodCo2}, {"CO2_LOTE", cNomeLote}})
 
                                If oCP6:SeekLine({{"CP6_LOTE", cNomeLote}, {"CP6_CODPRO", oCo2:GetValue("CO2_CODPRO")}, {"CP6_CODIGO", oCo3:GetValue("CO3_CODIGO")}})

                                    nVlUnit := GetLancCmp(oLote, oItem, cCnpj, lMD, oCP6:GetValue("CP6_QUANT"), oDadosEdt['operacaoLote'])

                                    If nVlUnit > 0
                                        oCP6:LoadValue("CP6_PRCUN", nVlUnit)
                                    EndIf
                                EndIf

                            EndIf
                        Next nForIT 
                    Next nForLic 

                EndIf
            EndIf
        Next nNroLote
    EndIf

    FwRestArea(aArea)
    FwFreeArray(aArea)

Return .T.

/*/{Protheus.doc} LogPcpProc()
    (Registra uma mensagem de log com as informações do sistema)
    @type  Static Function
    @author Thiago Rodrigues
    @since 23/04/2024
    @see (links_or_references)
/*/
Static Function LogPcpProc(cMessage,lError)
local cSeverity  := ""
Default lError   := .F.

cSeverity := iif(lError,"ERROR","INFO")
FWLogMsg(cSeverity,, 'GCPPcpProc', FunName(), '', '01', CRLF + 'GCPApiPCP:MSG: ' + cMessage, 0, 0, {})

Return Nil



/*/{Protheus.doc} CriaCP6
    (Cria a composição, tratamento pontual somente para Inexigibilidade.)
    @type  Static Function
    @author Thiago Rodrigues
    @since 24/04/2024
    @version version
    @see (links_or_references)
/*/
Static Function CriaCP6(oModel)
Local aSaveLines:= {}
Local oCp3	:=  nil
Local oCo3	:=  nil
Local oCo2	:=  nil
Local oCp6	:=  nil
Local nZ 	:= 0
Local nX 	:= 0
Local nY 	:= 0
Local aProp	:= {}

oCp3 :=  oModel:GetModel('CP3DETAIL')//Lotes
oCo3 :=  oModel:GetModel('CO3DETAIL')//Licitantes
oCo2 :=  oModel:GetModel('CO2DETAIL')//Produtos
oCp6 :=  oModel:GetModel('CP6DETAIL')//Composicao do Lote

aSaveLines := FWSaveRows()
aProp 	   := GetPropMdl(oCp6)
CNTA300BlMd(oCp6,.F.)//Desbloqueia caso seja necessário inserir novos registros

if (oCp6:Length() == 1 .And. Empty(oCp6:GetValue("CP6_CODPRO"))) .Or. ;
   (oCp6:Length() != oCo2:Length())

    for nX := 1 to oCp3:Length() //Percorre os Lotes
        oCp3:GoLine(nX)
        If !oCp3:IsDeleted()

            for nY := 1 to oCo3:Length()//Percorre os licitantes
                oCo3:GoLine(nY)
                If !oCo3:IsDeleted()

                    For nZ := 1 to oCo2:Length() //Percorre os Produtos
                        oCo2:GoLine(nZ)
                        If !oCo2:IsDeleted()
                            If !oCp6:SeekLine({{"CP6_CODPRO", oCo2:GetValue("CO2_CODPRO")}})
                                If !Empty(oCp6:GetValue("CP6_CODPRO"))
                                    oCp6:AddLine()
                                EndIf
                                oCp6:SetValue("CP6_CODPRO",  oCo2:GetValue("CO2_CODPRO"))
                                oCp6:LoadValue("CP6_LOTE",   oCp3:GetValue("CP3_LOTE"))
                                oCp6:LoadValue("CP6_CODIGO", oCo3:GetValue("CO3_CODIGO"))
                            EndIf

                            oCp6:LoadValue("CP6_QUANT", oCo2:GetValue("CO2_QUANT"))
                        EndIf
                    Next nZ

                EndIf
                
            next nY
            
        EndIf
    next nX
endif

RstPropMdl(oCp6,aProp)
FwFreeArray(aProp)

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)

Return Nil


/*/{Protheus.doc} ProLanItem
    ( Processa os lances do item para atualizar os valores e status na CO3, verificando se o fornecedor foi vencedor ou inabilitado para o item)
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/06/2026
    @parameter oModCO3 (modelo de licitantes para atualizar os valores e status)
    @parameter oLote (lote com os lances a serem processados)
    @parameter oItem (item com os lances a serem processados)
    @parameter aVence (array de vencedores do item)
    @parameter aInab (array de inabilitados do item)
    @parameter cCodPro (Código do produto a verificar)
    @parameter nOperLote (Operação do lote: 1 = Lote Global, 2 = Disputa por Item)
    @see (links_or_references)
/*/
Static Function ProLanItem(oModCO3, oLote, oItem, aVence, aInab, cCodPro, nOperLote,lHmParcial)
    Local nY         As Numeric
    Local nZ         As Numeric
    Local cCodCo3    As Character
    Local cLojCo3    As Character
    Local cCnpj      As Character
    Local nIdItem    As Numeric
    Local cFilSA2    As Character
    Local nValItem   As Numeric
    Local aProp      As Array
    Local aLances    As Array

    Default lHmParcial := .F.

    nIdItem := oItem["IdItem"]
    cFilSA2 := xFilial("SA2")
    
    If ValType(nOperLote) != "N"
        nOperLote := 2
    EndIf

    If ValType(oItem["Propostas"]) == "A"
        aProp := oItem["Propostas"]

        For nY := 1 To Len(aProp)
            cCnpj := aProp[nY]["IdFornecedor"]

            cCodCo3 := GetAdvFVal("SA2", "A2_COD", cFilSA2 + cCnpj, 3)
            cLojCo3 := GetAdvFVal("SA2", "A2_LOJA", cFilSA2 + cCodCo3, 1)

            If oModCO3:SeekLine({{"CO3_CODIGO", cCodCo3}, {"CO3_LOJA", cLojCo3}, {"CO3_CODPRO", cCodPro}})
                
                nValItem := 0

                // Disputa por Item (nOperLote = 2) - Busca nos Lances do Item
                If nOperLote == 2 .And. ValType(oItem["Lances"]) == "A"
                    aLances := oItem["Lances"]
                    For nZ := 1 To Len(aLances)
                        If aLances[nZ]["IdFornecedor"] == cCnpj .And. aLances[nZ]["Valido"] .And. !aLances[nZ]["Cancelado"]
                            nValItem := aLances[nZ]["ValorUnitario"]
                        EndIf
                    Next nZ
                EndIf

                // Lote Global (nOperLote = 1)
                If nOperLote == 1
                    
                    // Caso do Vencedor - Captura direto do nó de Vencedores do Lote PAI
                    If ValType(oLote["Vencedores"]) == "A"
                        aLances := oLote["Vencedores"]
                        For nZ := 1 To Len(aLances)
                            If aLances[nZ]["IdFornecedor"] == cCnpj .And. !aLances[nZ]["Cancelado"]
                                If ValType(aLances[nZ]["ValorTotalArredondamento"]) == "N"
                                    nValItem := aLances[nZ]["ValorTotalArredondamento"]
                                EndIf
                            EndIf
                        Next nZ
                    EndIf

                    // Caso dos Perdedores/Inabilitados - Captura do nó de Lances do Lote PAI (Valor total do lance)
                    If nValItem == 0 .And. ValType(oLote["Lances"]) == "A"
                        aLances := oLote["Lances"]
                        For nZ := 1 To Len(aLances)
                            If aLances[nZ]["IdFornecedor"] == cCnpj .And. aLances[nZ]["Valido"] .And. !aLances[nZ]["Cancelado"]
                                If ValType(aLances[nZ]["ValorTotalArredondamento"]) == "N"
                                    nValItem := aLances[nZ]["ValorTotalArredondamento"]
                                EndIf
                            EndIf
                        Next nZ
                    EndIf

                EndIf

                // Se o fornecedor enviou proposta mas não deu nenhum lance no item válido.
                // herda o valor unitário da proposta inicial dele.
                If nValItem == 0
                    nValItem := aProp[nY]["ValorUnitario"]
                EndIf

                If nValItem > 0
                    oModCO3:LoadValue("CO3_VLUNIT", nValItem)
                EndIf

                // Atualiza o status (Vencedor ou Inabilitado)
                If nOperLote == 1 
                    If ChkVenItem(oLote["Vencedores"], cCnpj, oLote["idLote"])
                        If !lHmParcial .Or. !Empty(oItem["DATA_HOMOLOGACAO"])
                            oModCO3:LoadValue("CO3_STATUS", "5")
                        Else
                            oModCO3:LoadValue("CO3_STATUS", "1")
                        EndIf
                    Else 
                        CheckInab(oModCO3, oLote["Inabilitados"], cCnpj)
                    EndIf
                Else
                    If ChkVenItem(aVence, cCnpj, nIdItem)
                        // A TRAVA PRECISA ESTAR AQUI TAMBÉM!
                        If !lHmParcial .Or. !Empty(oItem["DATA_HOMOLOGACAO"])
                            oModCO3:LoadValue("CO3_STATUS", "5")
                        Else
                            oModCO3:LoadValue("CO3_STATUS", "1")
                        EndIf
                    Else 
                        CheckInab(oModCO3, aInab, cCnpj)
                    EndIf
                EndIf

            EndIf
        Next nY
    EndIf

    aProp   := Nil
    aLances := Nil

Return .T.

/*/{Protheus.doc} ChkVenItem
    (Verifica se o fornecedor foi o vencedor para o item e atualiza o status na CO3, caso positivo)
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/06/2026
    @parameter aVence (array de vencedores do item)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
    @parameter nIdItem (Id do item a verificar)
    @see (links_or_references)
/*/
Static Function ChkVenItem(aVence, cCnpj, nId)
    Local nI       As Numeric
    Local lRet     As Logical   
    Local cIdJson  As Character
    Local nQtdVenc As Numeric

    lRet     := .F.
    cIdJson  := ""
    nQtdVenc := 0

    If ValType(aVence) == "A" 
        nQtdVenc := Len(aVence)
        If nQtdVenc > 0 
            cIdJson := iif(ValType(aVence[1]["IdItem"]) != "U", "IdItem", "idLote")
            For nI := 1 To nQtdVenc
                If !aVence[nI]["Cancelado"] .And. aVence[nI]["IdFornecedor"] == cCnpj .And. aVence[nI][cIdJson] == nId
                    lRet := .T.
                    Exit
                EndIf
            Next nI
        Endif 
    EndIf

Return lRet

/*/{Protheus.doc} CheckInab
 (Verifica se o fornecedor foi inabilitado para o item e atualiza a CO3_OBS)
 @type Static Function
 @author [Seu Nome/Thiago Rodrigues]
 @since 08/06/2026
/*/
Static Function CheckInab(oModCO3, aInab, cCnpj)
    Local nI        As Numeric
    Local lRet      As Logical
    Local nQtdInab  As Numeric

    lRet     := .F.
    nQtdInab := 0

    If ValType(aInab) == "A"
        nQtdInab := Len(aInab)
        if nQtdInab > 0
            For nI := 1 To nQtdInab
                If aInab[nI]["IdFornecedor"] == cCnpj 
                    oModCO3:LoadValue("CO3_STATUS", StatusInab(aInab[nI]["CodRejeicaoFornecedor"]))
                    
                    // Tratamento da Justificativa com DecodeUTF8 para CP-1252
                    If ValType(aInab[nI]["Justificativa"]) == "C" .And. !Empty(aInab[nI]["Justificativa"])
                        oModCO3:LoadValue("CO3_OBS", DecodeUTF8(aInab[nI]["Justificativa"]))
                    EndIf
                    
                    lRet := .T.
                    Exit
                EndIf
            Next nI
        Endif
    EndIf
Return lRet

/*/{Protheus.doc} StatusInab
    (Realiza o tratamento para status de inabilitado)
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/06/2026
    @parameter cCodRejFor (Código de rejeição do fornecedor para mapear o status)
    @see (links_or_references)
/*/
Static Function StatusInab(cCodRejFor)
Local cRet As character

cRet := "1" //Por padrão do sistema, caso haja algum código de rejeição não mapeado, o status será habilitado

Do Case
    Case cCodRejFor == 1 // Inabilitado
        cRet := "6"  
    Case cCodRejFor == 2 // Desclassificado
        cRet := "8" 
    Case cCodRejFor == 3 // Rejeitado
        cRet := "3"        
EndCase

Return cRet 

/*/{Protheus.doc} ProLanLote
(Processa os lances globais do lote para atualizar os valores e status na CO3)
@type Static Function
@author Thiago Rodrigues
@since 08/06/2026
@parameter oModCO3 (modelo de licitantes para atualizar os valores e status)
@parameter oLote (objeto do lote com os lances globais a serem processados)
@parameter nOperLote (1=Global, 2=Por Item)
@parameter cLoteCP3 (nome do lote atual para filtro na CO3)
@parameter lHmParcial (Edital com Homologacao Parcial ativa - CO1_HMPARC)
/*/
Static Function ProLanLote(oModCO3, oLote, nOperLote, cLoteCP3, lHmParcial)

    Local nForCo3   As Numeric
    Local cCodCo3   As Character
    Local cLojCo3   As Character
    Local nIdLote   As Numeric
    Local oLances   As Array
    Local cFilSA2   As Character
    Local aVencs    As Array
    Local aInab     As Array
    Local lIsVenc   As Logical 
    Local cCnpj     As Character
    Local nTotalLic As Numeric

    Default lHmParcial := .F.

    cCodCo3   := ""
    cLojCo3   := ""
    nIdLote   := oLote["idLote"]
    oLances   := oLote["Lances"]
    cFilSA2   := xFilial("SA2")
    aVencs    := oLote["Vencedores"]
    aInab     := oLote["Inabilitados"]

    For nForCo3 := 1 To oModCO3:Length()
        oModCO3:GoLine(nForCo3)
        
        cCodCo3 := oModCO3:GetValue("CO3_CODIGO")
        cLojCo3 := oModCO3:GetValue("CO3_LOJA")
        cCnpj   := GetAdvFVal("SA2", "A2_CGC", cFilSA2 + cCodCo3 + cLojCo3, 1)
        
        nTotalLic := 0

        If nOperLote == 1
            nTotalLic := BusVlLnc(oLote, cCnpj)
        ElseIf nOperLote == 2
            nTotalLic := SumLncIt(oLote["itens"], cCnpj)
        EndIf

        If nTotalLic > 0
            oModCO3:LoadValue("CO3_VLUNIT", nTotalLic)
        EndIf

        lIsVenc := ChcVenLtG(aVencs, cCnpj, nIdLote)

        If lIsVenc
            // O node "Vencedores" e' preenchido pelo PCP assim que a disputa do lote
            // encerra (arrematante definido), ANTES da efetiva homologacao do lote -
            // confirmado no JSON LOTEDISPPORIT01 (lote pendente com Vencedores
            // preenchido e DATA_HOMOLOGACAO vazia). Quando o Edital tem Homologacao
            // Parcial ativa, so promove o fornecedor a Campeao (status "5") se o lote
            // ja foi efetivamente homologado (GcpLoteHom) - caso contrario, mantem
            // Habilitado ("1"), impedindo que o gerador de documentos (GCPA201/
            // GCP200Ctrs) inclua o lote pendente na minuta do contrato.
            If !lHmParcial .Or. GcpLoteHom(oLote)
                oModCO3:LoadValue("CO3_STATUS", "5")
            Else
                oModCO3:LoadValue("CO3_STATUS", "1")
            EndIf
        Else 
            CheckInaLT(oModCO3, aInab, cCnpj, nIdLote)
        EndIf
        
    Next nForCo3

    oLances := Nil
    aVencs  := Nil 
    aInab   := Nil

Return .T.


/*/{Protheus.doc} ChcVenLtG
 (Verifica se o fornecedor venceu a disputa do lote global e nao esta cancelado)
 @type Static Function
 @author Thiago Rodrigues
 @since 08/06/2026
 @param aVencedores, Array, Array de vencedores do lote
 @param cCnpj, Caracter, CNPJ do fornecedor a verificar
 @param nIdLote, Numerico, ID do lote a verificar
 @return lRet, Logico, Retorna .T. se o fornecedor e vencedor valido (nao cancelado)
/*/
Static Function ChcVenLtG(aVencedores, cCnpj, nIdLote)
 Local nI As Numeric
 Local lRet As Logical 

 lRet := .F.

 If ValType(aVencedores) == "A"
    For nI := 1 To Len(aVencedores)
        If !aVencedores[nI]["Cancelado"] .And. aVencedores[nI]["IdFornecedor"] == cCnpj .And. aVencedores[nI]["idLote"] == nIdLote
            lRet := .T.
            Exit
        EndIf
    Next nI
 EndIf

Return lRet

/*/{Protheus.doc} CheckInaLT
 (Verifica se o fornecedor foi inabilitado no escopo do lote e atualiza CO3_OBS) 
 @type Static Function
 @author [Seu Nome/Thiago Rodrigues]
 @since 08/06/2026
/*/
Static Function CheckInaLT(oModCO3, aInab, cCnpj, nIdLote)
    Local nI        As Numeric
    Local lRet      As Logical 

    nI   := 1
    lRet := .F.

    If ValType(aInab) == "A"
        For nI := 1 To Len(aInab)
            If aInab[nI]["IdFornecedor"] == cCnpj
                oModCO3:LoadValue("CO3_STATUS", StatusInab(aInab[nI]["CodRejeicaoFornecedor"]))
                
                // Tratamento da Justificativa com DecodeUTF8 para CP-1252
                If ValType(aInab[nI]["Justificativa"]) == "C" .And. !Empty(aInab[nI]["Justificativa"])
                    oModCO3:LoadValue("CO3_OBS", DecodeUTF8(aInab[nI]["Justificativa"]))
                EndIf

                lRet := .T.
                Exit
            EndIf
        Next nI
    EndIf

Return lRet


/*/{Protheus.doc} BusVlLnc
    (Busca o valor do último lance válido do fornecedor na raiz do Lote)
     @type  Static Function
    @author Thiago Rodrigues
    @since 09/06/2026
    @parameter aLances (array de lances do lote)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
/*/
Static Function BusVlLnc(oLote, cCnpj)
    Local nY         As Numeric
    Local nVal       As Numeric
    Local lIsMD      As Logical
    Local aLances    As Array
    Local aItens     As Array
    Local aVencs     As Array
    Local aProp      As Array
    Local oItem      As Object
    Local nZ         As Numeric

    nVal    := 0
    lIsMD   := .F.
    aLances := oLote["Lances"]
    aItens  := oLote["itens"]
    aVencs  := oLote["Vencedores"]

    // Maior Desconto
    If ValType(aItens) == "A" .And. Len(aItens) > 0
        If aItens[1]["tipoJulgamento"] == "Maior Desconto"
            lIsMD := .T.
        EndIf
    EndIf

    If lIsMD
        // Verifica se o fornecedor atual é o VENCEDOR do lote
        If ValType(aVencs) == "A"
            For nY := 1 To Len(aVencs)
                If aVencs[nY]["IdFornecedor"] == cCnpj
                    // No MD, o nó de Vencedores traz o valor real em dinheiro
                    If ValType(aVencs[nY]["ValorTotalArredondamento"]) == "N"
                        nVal := aVencs[nY]["ValorTotalArredondamento"]
                    EndIf
                EndIf
            Next nY
        EndIf

        // Se NÃO for o vencedor (Perdedor/Inabilitado), calcula a soma das Propostas Originais
        If nVal == 0 .And. ValType(aItens) == "A"
            For nY := 1 To Len(aItens)
                oItem := aItens[nY]
                
                If ValType(oItem["Propostas"]) == "A"
                    aProp := oItem["Propostas"]
                    For nZ := 1 To Len(aProp)
                        If aProp[nZ]["IdFornecedor"] == cCnpj
                            If ValType(aProp[nZ]["ValorTotalArredondamento"]) == "N"
                                nVal += aProp[nZ]["ValorTotalArredondamento"]
                            EndIf
                        EndIf
                    Next nZ
                EndIf
            Next nY
        EndIf
    // Critério Normal (Menor Preço) 
    Else
        If ValType(aLances) == "A"
            For nY := 1 To Len(aLances)
                If aLances[nY]["IdFornecedor"] == cCnpj .And. aLances[nY]["Valido"] .And. !aLances[nY]["Cancelado"]
                    If ValType(aLances[nY]["ValorTotalArredondamento"]) == "N"
                        nVal := aLances[nY]["ValorTotalArredondamento"]
                    EndIf
                EndIf
            Next nY
        EndIf

        If nVal == 0 .And. ValType(aItens) == "A"
            For nY := 1 To Len(aItens)
                oItem := aItens[nY]
                If ValType(oItem["Propostas"]) == "A"
                    aProp := oItem["Propostas"]
                    For nZ := 1 To Len(aProp)
                        If aProp[nZ]["IdFornecedor"] == cCnpj .And. aProp[nZ]["Valido"]
                            If ValType(aProp[nZ]["ValorTotalArredondamento"]) == "N"
                                nVal += aProp[nZ]["ValorTotalArredondamento"]
                            EndIf
                        EndIf
                    Next nZ
                EndIf
            Next nY
        EndIf
    EndIf

    //não utilizado FwFreeArray ou FreeObj pois destroem os objetos pai que estão sendo utilizados para outras verificações, então apenas seto como Nil para liberar a referência
    aLances := Nil
    aItens  := Nil
    aVencs  := Nil
    aProp   := Nil
    oItem   := Nil

Return nVal


/*/{Protheus.doc} SumLncIt
    (Soma o último lance válido de cada item do lote para o fornecedor atual)
    @type  Static Function
    @author Thiago Rodrigues
    @since 09/06/2026
    @parameter aItens (array de itens do lote)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
/*/
Static Function SumLncIt(aItens, cCnpj)
    Local nP       As Numeric
    Local nY       As Numeric
    Local nZ       As Numeric
    Local nSum     As Numeric
    Local nLastVal As Numeric
    Local aLncItm  As Array
    Local aProp    As Array

    nSum := 0

    If ValType(aItens) == "A"
        For nP := 1 To Len(aItens)
            aLncItm  := aItens[nP]["Lances"]
            nLastVal := 0
            
            If ValType(aLncItm) == "A"
                For nY := 1 To Len(aLncItm)
                    If aLncItm[nY]["IdFornecedor"] == cCnpj .And. aLncItm[nY]["Valido"] .And. !aLncItm[nY]["Cancelado"]
                        nLastVal := aLncItm[nY]["ValorTotalArredondamento"]
                    EndIf
                Next nY
            EndIf

            If nLastVal == 0 .And. ValType(aItens[nP]["Propostas"]) == "A"
                aProp := aItens[nP]["Propostas"]
                For nZ := 1 To Len(aProp)
                    If aProp[nZ]["IdFornecedor"] == cCnpj .And. aProp[nZ]["Valido"]
                        If ValType(aProp[nZ]["ValorTotalArredondamento"]) == "N"
                            nLastVal := aProp[nZ]["ValorTotalArredondamento"]
                        EndIf
                    EndIf
                Next nZ
            EndIf
            
            nSum += nLastVal
        Next nP
    EndIf

    aLncItm := Nil
Return nSum

/*/{Protheus.doc} GetLancCmp
    (Apura o valor unitário da composição)
    @type   Static Function
    @author Thiago Rodrigues
    @parameter oLote (objeto do lote para buscar os lances globais)
    @parameter oItem (objeto do item para buscar os lances por item)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
    @parameter lMD (indica se deve considerar o valor total arredondado)
    @parameter nQuant (quantidade de itens para divisão proporcional)
    @parameter nOperLote (tipo de operação do lote)
    @since  09/06/2026
/*/
Static Function GetLancCmp(oLote, oItem, cCnpj, lMD, nQuant, nOperLote)
    Local nY       As Numeric
    Local nVal     As Numeric
    Local aLances  As Array
    Local aNodes   As Array

    nVal := 0

    //Disputa por Item (operacaoLote = 2)
    If nOperLote == 2 .And. ValType(oItem["Lances"]) == "A"
        aLances := oItem["Lances"]
        For nY := 1 To Len(aLances)
            If aLances[nY]["IdFornecedor"] == cCnpj .And. aLances[nY]["Valido"] .And. !aLances[nY]["Cancelado"]
                nVal := aLances[nY]["ValorUnitario"]
            EndIf
        Next nY
    EndIf

    //Lote Global (operacaoLote = 1)
    If nOperLote == 1
        
        // Caso do Vencedor - Pega a Readequação de Preço do Item
        If ValType(oItem["PropostasReadequadas"]) == "A"
            aLances := oItem["PropostasReadequadas"]
            For nY := 1 To Len(aLances)
                If aLances[nY]["IdFornecedor"] == cCnpj .And. aLances[nY]["Valido"] .And. !aLances[nY]["Cancelado"]
                    If lMD
                        nVal := aLances[nY]["ValorTotalArredondamento"] / nQuant
                    Else
                        nVal := aLances[nY]["ValorUnitario"]
                    EndIf
                EndIf
            Next nY
        EndIf

        //Qualquer participante com lance mas sem Readequação (Perdedores/Inabilitados)
        //Garante que a divisão dos itens na CP6 seja um espelho exato do total da CO3
        If nVal == 0 .And. ValType(oLote["Lances"]) == "A"
            For nY := 1 To Len(oLote["Lances"])
                If oLote["Lances"][nY]["IdFornecedor"] == cCnpj .And. oLote["Lances"][nY]["Valido"] .And. !oLote["Lances"][nY]["Cancelado"]
                    if ValType(oLote["Lances"][nY]["ValorTotalArredondamento"]) == "N"
                       nVal := oLote["Lances"][nY]["ValorTotalArredondamento"]
                    Endif
                EndIf
            Next nY
            
            // Divisão proporcional pelo número de itens do lote e quantidade da CO2/CP6
            If nVal > 0 .And. ValType(oLote["itens"]) == "A"
                nVal := ( nVal / Len(oLote["itens"])) / nQuant
            EndIf
        EndIf

        // Se não houver lances/readequações, pega a Proposta Original
        If nVal == 0 .And. ValType(oItem["Propostas"]) == "A"
            aNodes := oItem["Propostas"]
            For nY := 1 To Len(aNodes)
                If aNodes[nY]["IdFornecedor"] == cCnpj .And. aNodes[nY]["Valido"]
                    If lMD
                        nVal := aNodes[nY]["ValorTotalArredondamento"] / nQuant
                    Else
                        nVal := aNodes[nY]["ValorUnitario"]
                    EndIf
                EndIf
            Next nY
        EndIf
    EndIf

    aLances := Nil
Return nVal


/*/{Protheus.doc} GcpHomPrc
    (Verifica se o retorno do PCP indica homologacao/adjudicacao PARCIAL:
    pelo menos um item/lote com DATA_HOMOLOGACAO preenchida e pelo menos
    um item/lote ainda pendente - usada para auto-habilitar CO1_HMPARC)
    @type  Static Function
    @author Thiago Rodrigues da Silva
    @since 04/09/2026
    @param oDadosEdt (objeto JSON do processo retornado pelo GetObterProcesso)
    @param cAvaliacao (character) - "1"=Por Item, "2"=Por Lote (CO1_AVAL)
    @return lRet (logical) - .T. quando ha mistura de homologado/pendente
/*/
Static Function GcpHomPrc(oDadosEdt As Json, cAvaliacao As Character)
    Local lRet     := .F. As Logical
    Local lTemHm   := .F. As Logical
    Local lTemPnd  := .F. As Logical
    Local nX       :=  1  As Numeric
    Local nP       :=  1  As Numeric 
    Local oLote    := Nil As Object

    Default cAvaliacao := "1"

    If ValType(oDadosEdt['lotes']) == "A"
        For nX := 1 To Len(oDadosEdt['lotes'])
            oLote := oDadosEdt['lotes'][nX]

            If cAvaliacao == "2"
                If ValType(oLote['itens']) == "A" .And. Len(oLote['itens']) > 0
                    If GcpLoteHom(oLote)
                        lTemHm := .T.
                    Else
                        lTemPnd := .T.
                    EndIf
                EndIf
            Else
                If ValType(oLote['itens']) == "A"
                    For nP := 1 To Len(oLote['itens'])
                        If !Empty(oLote['itens'][nP]["DATA_HOMOLOGACAO"])
                            lTemHm := .T.
                        Else
                            lTemPnd := .T.
                        EndIf
                    Next nP
                EndIf
            EndIf
        Next nX
    EndIf

    lRet := lTemHm .And. lTemPnd

Return lRet

/*/{Protheus.doc} MrkCO2Lote
    (Sincroniza CO2_HOMOLO = .T. para todos os itens (CO2) de um lote (CP3) que
    acabou de ser marcado como homologado, garantindo consistencia relacional
    entre CP3_HOMOLO e CO2_HOMOLO no momento em que a integracao processa o
    retorno do PCP - sem depender do SQL direto de GCP200Grv, que so' roda
    depois do commit, na etapa "HO")
    @type  Static Function
    @author Thiago Rodrigues da Silva
    @since 10/09/2026
    @param oModCO2 (model da grid CO2DETAIL)
    @param cNomeLote (nome/descricao do lote, ja' padronizado ao tamanho de CO3_LOTE/CP3_LOTE)
    @return Nil
/*/
Static Function MrkCO2Lote(oModCO2, cNomeLote)
    Local nForCo2 As Numeric

    For nForCo2 := 1 To oModCO2:Length()
        oModCO2:GoLine(nForCo2)

        If oModCO2:GetValue("CO2_LOTE") == cNomeLote
            oModCO2:SetNoUpdateLine(.F.)
            oModCO2:LoadValue("CO2_HOMOLO", .T.)
            oModCO2:SetNoUpdateLine(.T.)
        EndIf
    Next nForCo2

Return Nil

/*/{Protheus.doc} GcpLoteHom
    (Verifica se todos os itens de um lote ja foram homologados no PCP,
    a partir do campo DATA_HOMOLOGACAO de cada item do JSON)
    @type  Static Function
    @author Thiago Rodrigues da Silva
    @since 04/09/2026
    @param oLote (objeto do lote recebido do PCP)
    @return lRet (logical) - .T. quando todos os itens do lote possuem DATA_HOMOLOGACAO preenchida
/*/
Static Function GcpLoteHom(oLote As json)
    Local lRet := .T. As Logical
    Local nP   := 1   As Numeric

    If ValType(oLote['itens']) == "A" .And. Len(oLote['itens']) > 0
        For nP := 1 To Len(oLote['itens'])
            If Empty(oLote['itens'][nP]["DATA_HOMOLOGACAO"])
                lRet := .F.
                Exit
            EndIf
        Next nP
    EndIf

Return lRet

/*/{Protheus.doc} HabHomParc
    (Habilita homologacao Parcial no edital)
    @type  Static Function
    @author Thiago Rodrigues da Silva
    @since 04/09/2026
    @param nEtapaIni (numeric) - posicao inicial do fluxo de etapas
    @param nEtapaFim (numeric) - posicao final do fluxo de etapas (etapa "HO")
    @param oDadosEdt (json) - objeto do processo retornado pelo GetObterProcesso
    @param aFluxoEtp (array) - fluxo de etapas conforme lei/modalidade
    @return Nil
/*/
Static Function HabHomParc(nEtapaIni As Numeric, nEtapaFim As Numeric,; 
                           oDadosEdt As Json, aFluxoEtp As Array) 

    Local Nz         := 0   As Numeric
    Local lVencFluxo := .F. As Logical

    Default nEtapaIni  := 0
    Default nEtapaFim  := 0
    Default oDadosEdt  := Nil 
    Default aFluxoEtp  := {}

    //Verifica se a etapa que declara os vencedores (GcpAtuVenc) esta dentro do
    //intervalo de etapas que esta chamada vai efetivamente processar,
    //proteção caso numa execução anterior o edital já tenha avançado até "HO" ou "AD"
    //ma nova chamada começaria direto em HO, sem passar por JP/NE
    If nEtapaIni > 0 .And. nEtapaFim > 0
        For nZ := nEtapaIni To nEtapaFim
            If (aFluxoEtp[nZ] $ "JP|NE" .And. CO1->CO1_MODALI != "RD") .Or.;
               (CO1->CO1_MODALI == "RD" .And. aFluxoEtp[nZ] == "AE")
                lVencFluxo := .T.
                Exit
            EndIf
        Next nZ
    EndIf

    //Habilita a Homologacao Parcial do Edital, deve ser feito antes do primeiro commit de Andamento.
    If !CO1->CO1_HMPARC .And. lVencFluxo .And. GcpHomPrc(oDadosEdt, CO1->CO1_AVAL)
        If CO1->(RecLock("CO1", .F.))
            CO1->CO1_HMPARC := .T.
            CO1->(MsUnlock())
        EndIf
    EndIf

return nil

/*/{Protheus.doc} GcpMrkParc
    (Marca CO2_HOMOLO/CP3_HOMOLO/CO3_STATUS quando o Edital ja esta parado em "HO" com
    CO1_STATUS = "C" (homologacao parcial pendente). Usada para reprocessar
    um novo retorno do PCP com item(ns)/lote(s) recem-homologados. Nesta versao,
    tambem sincroniza CO3_STATUS para o vencedor/inabilitado do lote homologado)
    @type   Static Function
    @author Thiago Rodrigues da Silva
    @since 08/09/2026
    @param oDadosEdt (objeto JSON do processo retornado pelo GetObterProcesso)
    @param cCodEdt   (character) - Codigo do Edital
    @param cNumPro   (character) - Numero do Processo do Edital
    @return lRet (logical) - .T. quando processado sem erro
/*/
Static Function GcpMrkParc(oDadosEdt As Json, cCodEdt As Character, cNumPro As Character)
    Local lRet      := .T.  As Logical
    Local lIsLote   := CO1->CO1_AVAL == "2" As Logical
    Local oLote     := Nil  As Object
    Local oItem     := Nil  As Object
    Local nX        := 1    As Numeric
    Local nP        := 1    As Numeric
    Local cItemCo2  := ""   As Character
    Local cLoteCP3  := ""   As Character
    Local cCnpj     := ""   As Character
    Local nIn       := 1    As Numeric
    Local aAreaCO2  := {}   As Array
    Local aAreaCP3  := {}   As Array
    Local aAreaCO3  := {}   As Array
    Local nTamItem  := TamSx3("CO2_ITEM")[1] As Numeric
    Local nTamLote  := TamSx3("CP3_LOTE")[1] As Numeric
    Local cFilCP3   := FWxFilial("CP3") As Character
    Local cFilCO2   := FWxFilial("CO2") As Character
    Local cFilCO3   := FWxFilial("CO3") As Character
    Local cFilSA2   := FWxFilial("SA2") As Character

    aAreaCO2 := CO2->(GetArea())
    aAreaCP3 := CP3->(GetArea())
    aAreaCO3 := CO3->(GetArea())

    If ValType(oDadosEdt['lotes']) == "A"

        For nX := 1 To Len(oDadosEdt['lotes'])
            oLote := oDadosEdt['lotes'][nX]

            If lIsLote

                // Marca o lote (CP3) como homologado quando todos os itens do lote ja foram homologados no PCP
                If GcpLoteHom(oLote)
                    cLoteCP3 := PadR(AllTrim(oLote["DS_LOTE"]), nTamLote)

                    CP3->(DbSetOrder(1)) // CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO+CP3_LOTE
                    If CP3->(dbSeek(cFilCP3 + cCodEdt + cNumPro + cLoteCP3))
                        If !CP3->CP3_HOMOLO
                            RecLock("CP3", .F.)
                            CP3->CP3_HOMOLO := .T.
                            CP3->(MsUnlock())
                        EndIf
                    EndIf

                    // Sincroniza CO2_HOMOLO dos itens do lote agora homologado
                    CO2->(DbSetOrder(3)) // CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_LOTE
                    If CO2->(dbSeek(cFilCO2 + cCodEdt + cNumPro + cLoteCP3))
                        While CO2->(!Eof()) .And. CO2->(CO2_FILIAL + CO2_CODEDT + CO2_NUMPRO + CO2_LOTE) == cFilCO2 + cCodEdt + cNumPro + cLoteCP3
                            If !CO2->CO2_HOMOLO
                                RecLock("CO2", .F.)
                                CO2->CO2_HOMOLO := .T.
                                CO2->(MsUnlock())
                            EndIf
                            CO2->(DbSkip())
                        EndDo
                    EndIf

                    // Sincroniza CO3_STATUS = "5" (Campeao) para o vencedor do lote homologado
                    // no reprocessamento, e "6"/"8"/"3" (Inabilitado/Desclassificado/Rejeitado)
                    // para licitantes inabilitados apos o Edital ja ter entrado em "HO" - mesma
                    // regra de desfecho por licitante ja aplicada em ProLanLote (vencedor via
                    // ChcVenLtG, inabilitado via CheckInaLT/StatusInab)
                    CO3->(DbSetOrder(2)) // CO3_FILIAL+CO3_CODEDT+CO3_NUMPRO+CO3_LOTE
                    If CO3->(dbSeek(cFilCO3 + cCodEdt + cNumPro + cLoteCP3))
                        While CO3->(!Eof()) .And. CO3->(CO3_FILIAL + CO3_CODEDT + CO3_NUMPRO + CO3_LOTE) == cFilCO3 + cCodEdt + cNumPro + cLoteCP3
                            cCnpj := GetAdvFVal("SA2", "A2_CGC", cFilSA2 + CO3->CO3_CODIGO + CO3->CO3_LOJA, 1)
                            If ChcVenLtG(oLote["Vencedores"], cCnpj, oLote["idLote"])
                                If CO3->CO3_STATUS != "5"
                                    RecLock("CO3", .F.)
                                    CO3->CO3_STATUS := "5"
                                    CO3->(MsUnlock())
                                EndIf
                            ElseIf ValType(oLote["Inabilitados"]) == "A"
                                For nIn := 1 To Len(oLote["Inabilitados"])
                                    If oLote["Inabilitados"][nIn]["IdFornecedor"] == cCnpj
                                        RecLock("CO3", .F.)
                                        CO3->CO3_STATUS := StatusInab(oLote["Inabilitados"][nIn]["CodRejeicaoFornecedor"])
                                        CO3->(MsUnlock())
                                        Exit
                                    EndIf
                                Next nIn
                            EndIf
                            CO3->(DbSkip())
                        EndDo
                    EndIf
                EndIf

            Else

                If ValType(oLote['itens']) == "A"
                    For nP := 1 To Len(oLote['itens'])
                        oItem := oLote['itens'][nP]

                        If !Empty(oItem["DATA_HOMOLOGACAO"])
                            cItemCo2 := StrZero(Val(oItem['_id']), nTamItem)

                            CO2->(DbSetOrder(2)) // CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_ITEM
                            If CO2->(dbSeek(cFilCO2 + cCodEdt + cNumPro + cItemCo2))
                                If !CO2->CO2_HOMOLO .And. !CO2->CO2_DOCOK
                                    RecLock("CO2", .F.)
                                    CO2->CO2_HOMOLO := .T.
                                    CO2->(MsUnlock())
                                EndIf
                            EndIf
                        EndIf
                    Next nP
                EndIf

            EndIf
        Next nX
    EndIf

    RestArea(aAreaCO2)
    RestArea(aAreaCP3)
    RestArea(aAreaCO3)
    
    FwFreeArray(aAreaCO2)
    FwFreeArray(aAreaCP3)
    FwFreeArray(aAreaCO3)

Return lRet
