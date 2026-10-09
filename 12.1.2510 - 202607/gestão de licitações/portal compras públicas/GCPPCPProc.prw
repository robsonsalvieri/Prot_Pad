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

    //Realiza o processamento do edital, andamento do Processo até a etapa de homologação
    if lOk
        lOk := GCP200PERM(oDadosEdt)
    endif

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
local nEtpPosPub := 0
local lRet       := .T.
Local cEtapa     := CO1->CO1_ETAPA

aFluxo     := GCPEtpsEdt(CO1->CO1_REGRA, CO1->CO1_MODALI) //Fluxo de etapas conforme lei e modalidade
nPosIni    := aScan(aFluxo, cEtapa) //posição inicial - fluxo de etapas
nPosFim    := aScan(aFluxo, "HO")   // Posição final
nEtpPosPub := aScan(aFluxo, "PB") + 1  //Etapa posterior a publicação
cModel     := iif(CO1->CO1_AVAL == "1","GCPA200","GCPA201") //1=Por Item;2=Por Lote

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

    //Se for inexebilidade por lote cria a CP6 na etapa seguinte a publicação
    if (nI == nEtpPosPub) .And. CO1->CO1_MODALI == "IN"  .And. cModel == "GCPA201"
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
    ( Faz o cadastro de fornecedores e inclui os licitantes no Edital)
    @type  Function
    @author Thiago Rodrigues
    @since 02/04/2024
    @version version
    @see (links_or_references)
/*/
Function GcpPCPFor(oDadosEdt)

local nFor        := 1
local oModelFor   := nil 
local oFindSA2    := nil
local cAliTmp     := GetNextAlias() 
local cQryStat    := nil
local cLoja       := ""
local cCod        := ""
local cTipo       := ""
local cCpfCgC     := ""
Local aArea       := FwGetArea()
local LOk         := .T.
local oModGCP200  := nil 
local oCO3        := nil 
local oCp3        := nil
local oCO1        := nil 
local oCo2        := nil
Local cItem 	  := ""
local cItemCo2    := ""
local nLote       := 1 //Contador lote
local nLance      := 1 //Contador do lance
local nProd       := 1 //Contador por item
local nPartic     := 1 //Contador participante
local nProp       := 1 //Contador propostas
local cCodCo3     := ""
local cLojCo3     := ""
local cNomeCo3    := ""
local cTipoCo3    := ""
local xFilSA2     := xFilial("SA2")
local aPartic     := {} //Array com os participantes
local cModel      := ""
Local lAtuEdit    := !IsInCallStack("GCPA600") //Verifica se atualiza edital
Local aProp       := {}

//Cria os fornecedores caso não existam.
if ValType(oDadosEdt['Participantes']) == 'A' .and. Len(oDadosEdt['Participantes']) > 0

    for nFor := 1 to Len(oDadosEdt['Participantes'])

        //Monta array com participantes do processo
        aAdd(aPartic,{oDadosEdt['Participantes'][nFor]["CNPJ"], Iif(oDadosEdt['Participantes'][nFor]["Licitante"], "2", "1")})

        cTipo   := iif(At("J", DecodeUTF8(oDadosEdt['Participantes'][nFor]["Tipo"])) > 0,"J","F")
        cCpfCgC := iif(cTipo=="J","CNPJ","CPF")

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
        MpSysOpenQuery(cQryStat,cAliTmp)

        //Senão achou o fornecedor, cria um novo cadastro.
        if (cAliTmp)->(Eof())

            //LOJA -  Se possuir inicializador padrão não precisa adicionar o campo A2_LOJA
            If Empty(GetAdvFVal("SX3","X3_RELACAO","A2_LOJA"))
                cLoja := "01"
            Endif
            
            //Busca o proximo codigo na SA2
            If Empty(GetAdvFVal("SX3","X3_RELACAO","A2_COD"))
                cCod := GetSxeNum("SA2","A2_COD") 

                While SA2->(MsSeek(xFilial("SA2")+cCod)) 
                    ConfirmSX8() 
                    cCod := GetSxeNum("SA2","A2_COD") 
                EndDo 
            Endif
        
            //Instancia o model 
            oModelFor := FWLoadModel("MATA020")
            oModelFor:SetOperation(MODEL_OPERATION_INSERT)
            oModelFor:Activate()

            if !Empty(cCod) 
                oModelFor:SetValue("SA2MASTER",	"A2_COD",		cCod) 		// Código
            endif

            if !Empty(cLoja)
                oModelFor:SetValue("SA2MASTER",	"A2_LOJA",		cLoja)		// Loja
            endif

            oModelFor:SetValue("SA2MASTER",	"A2_NOME",	 DecodeUTF8(oDadosEdt['Participantes'][nFor]["RazaoSocial"]))	// Razão Social
            oModelFor:SetValue("SA2MASTER",	"A2_NREDUZ", DecodeUTF8(oDadosEdt['Participantes'][nFor]["NomeFantasia"])) // N. Fantasia
            oModelFor:SetValue("SA2MASTER",	"A2_END",	 DecodeUTF8(oDadosEdt['Participantes'][nFor]["Endereco"])) // Endereço
            oModelFor:SetValue("SA2MASTER",	"A2_EST",	 oDadosEdt['Participantes'][nFor]["UF"])// Estado
            oModelFor:SetValue("SA2MASTER",	"A2_COD_MUN", substr(oDadosEdt['Participantes'][nFor]["CD_MUNICIPIO_IBGE"],3,7))	// Cod. Municipio
            oModelFor:SetValue("SA2MASTER",	"A2_BAIRRO", DecodeUTF8(oDadosEdt['Participantes'][nFor]["Bairro"]))	// Estado
            oModelFor:SetValue("SA2MASTER",	"A2_TIPO",	  cTipo)		// Tipo
            oModelFor:SetValue("SA2MASTER",	"A2_CGC",	  oDadosEdt['Participantes'][nFor][cCpfCgC])		// Tipo

            If Valtype(oDadosEdt['Participantes'][nFor]["INSCRICAO_ESTADUAL"]) == "C"
                oModelFor:SetValue("SA2MASTER",	"A2_INSCR",	  oDadosEdt['Participantes'][nFor]["INSCRICAO_ESTADUAL"])
            endif

            If Valtype(oDadosEdt['Participantes'][nFor]["INSCRICAO_MUNICIPAL"]) == "C"
                oModelFor:SetValue("SA2MASTER",	"A2_INSCRM",  oDadosEdt['Participantes'][nFor]["INSCRICAO_MUNICIPAL"])
            endif

            If LOk:= oModelFor:VldData()
                oModelFor:CommitData()
            else 
                if Len(oModelFor:GetErrorMessage()) > 5
                    LogPcpProc(STR0004 + oModelFor:GetErrorMessage()[6] ,.t.) //Falha na inclusão do fornecedor:
                endif
            endif


            oModelFor:DeActivate()
            oModelFor := Nil
            FreeObj(oModelFor) 
        endif     

    (cAliTmp)->(DbCloseArea())
    Next nFor

    FreeObj(oFindSA2)  
endif


//Inclui licitantes no edital 
if LOk  .And. lAtuEdit
       
    cModel := iif(CO1->CO1_AVAL == "1","GCPA200","GCPA201")

    //Instacia o model do GCP      
    oModGCP200 := FWLoadModel(cModel)
    oModGCP200:SetOperation( MODEL_OPERATION_UPDATE )
    oModGCP200:Activate()

    oCO1 := oModGCP200:GetModel("CO1MASTER")//Cabeçalho
    oCO3 := oModGCP200:GetModel("CO3DETAIL") //Licitantes
    oCp3 := oModGCP200:GetModel("CP3DETAIL") //Lotes
    oCo2 := oModGCP200:GetModel("CO2DETAIL") //Produtos

    oCO1:LoadValue("CO1_DATARP",cTod(oDadosEdt["dataAberturaPropostas"])) // data de recebimento das propostas
    oCO1:LoadValue("CO1_HORAAB",oDadosEdt["horaAberturaPropostas"]) //Hora da abertura das propostas

    
    aProp := GetPropMdl(oCO3)
    CNTA300BlMd(oCO3,.F.) //Desbloqueia o modelo caso seja necessário inclusão de novos participantes.


    If cModel == "GCPA201" //Por lote

        if oDadosEdt['operacaoLote'] ==  1 //(disputa por Lote Global).

            if Valtype(oDadosEdt['lotes']) == "A"
                //Verificação em cada lote
                For nLote := 1 To Len(oDadosEdt['lotes']) 
                            
                    oCp3:Goline(oDadosEdt['lotes'][nLote]["NR_LOTE"]) //Posiciona no lote  
                    cItem:= Replicate("0", TamSx3("CO3_ITEM")[1])
                    cTipoCo3 := "2"

                    //cada lance do lote
                    if Valtype(oDadosEdt['lotes'][nLote]["Lances"]) =="A"
                        For nLance := 1 To Len(oDadosEdt['lotes'][nLote]["Lances"]) 

                            cCodCo3  := GetAdvFVal("SA2","A2_COD",xFilSA2+oDadosEdt['lotes'][nLote]["Lances"][nLance]["IdFornecedor"],3)
                            cLojCo3  := GetAdvFVal("SA2","A2_LOJA",xFilSA2+cCodCo3,1)
                            cNomeCo3 := GetAdvFVal("SA2","A2_NOME",xFilSA2+cCodCo3+cLojCo3,1)
                            
                            If !oCO3:SeekLine({{"CO3_LOTE", oCp3:GetValue("CP3_LOTE")},;
                                {"CO3_CODIGO", cCodCo3},;
                                {"CO3_LOJA", cLojCo3}})

                                //Busca participante pelo IdFornecedor
                                If Len(aPartic)> 0 .And. (nPartic := aScan(aPartic, {|x| AllTrim(x[1]) = Alltrim(oDadosEdt['lotes'][nLote]["Lances"][nLance]["IdFornecedor"])})) > 0
                                    cTipoCo3 := aPartic[nPartic][2]
                                Else
                                    cTipoCo3 := "2"
                                EndIf

                                if !Empty(oCO3:GetValue("CO3_CODIGO"))
                                    oCO3:AddLine()  
                                endif

                                //Inclui o licitante no lote
                                cItem := Soma1(cItem)
                                oCO3:LoadValue("CO3_LOTE", oCp3:GetValue("CP3_LOTE"))
                                oCO3:LoadValue("CO3_CODIGO",cCodCo3)
                                oCO3:LoadValue("CO3_LOJA",cLojCo3)
                                oCO3:LoadValue("CO3_NOME",cNomeCo3)
                                oCO3:LoadValue("CO3_TIPO",cTipoCo3)
                                oCO3:LoadValue("CO3_ITEM", cItem)	
                            endif
                        Next nLance
                    endif    
                Next nLote
            endif
        elseif oDadosEdt['operacaoLote'] ==  2 //(disputa por Item). 
            
            if Valtype(oDadosEdt['lotes']) == "A"
                For nLote := 1 To Len(oDadosEdt['lotes']) //lotes
                    oCp3:Goline(oDadosEdt['lotes'][nLote]["NR_LOTE"]) //Posiciona no lote

                    //Produtos
                    if Valtype(oDadosEdt['lotes'][nLote]['itens']) == "A"

                        //Quando a operação é por item, os lances ficam dentro do item
                        for nProd := 1 to Len(oDadosEdt['lotes'][nLote]['itens'])

                            cItemCo2    := StrZero(Val(oDadosEdt['lotes'][nLote]['itens'][nProd]['_id']), TamSx3("CO2_ITEM")[1])
                            cItem       := Replicate("0", TamSx3("CO3_ITEM")[1])
                            cTipoCo3    := "2"

                            If oCO2:SeekLine({{"CO2_ITEM", cItemCo2}})  //Posiciona no item do lote  
                                if Valtype(oDadosEdt['lotes'][nLote]['itens'][nProd]["Lances"]) == "A"  //cada lance do lote
                                    For nLance := 1 To Len(oDadosEdt['lotes'][nLote]['itens'][nProd]["Lances"]) 
                                    
                                        cCodCo3  := GetAdvFVal("SA2", "A2_COD", xFilSA2+oDadosEdt['lotes'][nLote]['itens'][nProd]["Lances"][nLance]["IdFornecedor"], 3)
                                        cLojCo3  := GetAdvFVal("SA2", "A2_LOJA", xFilSA2+cCodCo3, 1)
                                        cNomeCo3 := GetAdvFVal("SA2", "A2_NOME", xFilSA2+cCodCo3+cLojCo3, 1)

                                        If !oCO3:SeekLine({{"CO3_LOTE", oCp3:GetValue("CP3_LOTE")},;
                                            {"CO3_CODIGO", cCodCo3},;
                                            {"CO3_LOJA", cLojCo3}})
                                            
                                            //Busca participante pelo IdFornecedor
                                            If Len(aPartic) > 0 .and. (nPartic := aScan(aPartic, {|x| AllTrim(x[1]) = Alltrim(oDadosEdt['lotes'][nLote]['itens'][nProd]["Lances"][nLance]["IdFornecedor"])})) > 0
                                                cTipoCo3 := aPartic[nPartic][2]
                                            Else
                                                cTipoCo3 := "2"
                                            EndIf

                                            if !Empty(oCO3:GetValue("CO3_CODIGO"))
                                                oCO3:AddLine()  
                                            endif

                                            //Inclui o licitante
                                            cItem := Soma1(cItem)
                                            oCO3:LoadValue("CO3_LOTE", oCp3:GetValue("CP3_LOTE"))
                                            oCO3:LoadValue("CO3_CODIGO",    cCodCo3)
                                            oCO3:LoadValue("CO3_LOJA",      cLojCo3)
                                            oCO3:LoadValue("CO3_NOME",      cNomeCo3)
                                            oCO3:LoadValue("CO3_TIPO",      cTipoCo3)
                                            oCO3:LoadValue("CO3_ITEM",      cItem)
                                        EndIf

                                    Next nLance
                                Endif    
                            EndIf
                        next nProd
                    endif    
                Next nLote
            endif
            
        endif
    else //Edital por item (Relacionamento do participante CO2 -> CO3)

        if Valtype(oDadosEdt['lotes']) == "A"

            //Mesmo sendo por item, sempre vai ter um lote
            For nLote := 1 To Len(oDadosEdt['lotes']) 

                if Valtype(oDadosEdt['lotes'][nLote]['itens']) == "A" //Produtos

                    for nProd := 1 to Len(oDadosEdt['lotes'][nLote]['itens'])

                        cItemCo2    := StrZero(Val(oDadosEdt['lotes'][nLote]['itens'][nProd]['_id']), TamSx3("CO2_ITEM")[1])
                        cItem       := Replicate("0", TamSx3("CO3_ITEM")[1])
                        cTipoCo3    := "2"

                        If oCO2:SeekLine({{"CO2_ITEM", cItemCo2}})
                        
                            if Valtype(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"]) == "A"
                                For nProp := 1 To Len(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"])   //Cada Proposta do lote
            
                                    if oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["Valido"]  // proposta valida
                                        cCodCo3  := GetAdvFVal("SA2", "A2_COD", xFilSA2+oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"], 3)
                                        cLojCo3  := GetAdvFVal("SA2", "A2_LOJA", xFilSA2+cCodCo3, 1)
                                        cNomeCo3 := GetAdvFVal("SA2", "A2_NOME", xFilSA2+cCodCo3+cLojCo3, 1)

                                        If !oCO3:SeekLine({{"CO3_CODPRO", oCO2:GetValue("CO2_CODPRO")}, {"CO3_CODIGO", cCodCo3}, {"CO3_LOJA", cLojCo3}})
                                            //Busca participante pelo IdFornecedor
                                            If Len(aPartic) > 0 .and. (nPartic := aScan(aPartic, {|x| AllTrim(x[1]) = Alltrim(oDadosEdt['lotes'][nLote]['itens'][nProd]["Propostas"][nProp]["IdFornecedor"])})) > 0
                                                cTipoCo3 := aPartic[nPartic][2]
                                            Else
                                                cTipoCo3 := "2"
                                            EndIf

                                            if !Empty(oCO3:GetValue("CO3_CODIGO"))
                                                oCO3:AddLine()  
                                            endif

                                            //Inclui o licitante com o produto
                                            cItem := Soma1(cItem)
                                            oCO3:LoadValue("CO3_CODPRO",    oCO2:GetValue("CO2_CODPRO"))
                                            oCO3:LoadValue("CO3_CODIGO",    cCodCo3)
                                            oCO3:LoadValue("CO3_LOJA",      cLojCo3)
                                            oCO3:LoadValue("CO3_NOME",      cNomeCo3)
                                            oCO3:LoadValue("CO3_TIPO",      cTipoCo3)
                                            oCO3:LoadValue("CO3_ITEM",      cItem)
                                        EndIf
                                    endif

                                Next nProp
                            Endif    

                        EndIf

                    next nProd

                endif    

            Next nLote

        endif    

    endif

    //-- Valida o formulário e realiza a gravação
    If oModGCP200:VldData()
        lOk := oModGCP200:CommitData()
    else 
        LogPcpProc(STR0005,.T.)//"Falha ao gravar os licitantes no edital."
    endif

    
    RstPropMdl(oCo3,aProp) //Restaura a propriedade do modelo

    //- Desativa o modelo de dados
    oModGCP200:DeActivate()
endif

FwRestArea(aArea)
FwFreeArray(aArea)
FwFreeArray(aProp)
 
Return lOk

/*/{Protheus.doc} GcpAtuVenc
    (Declara o fornecedor Campeão e atualiza os valores)
    @type  Static Function
    @author Thiago Rodrigues
    @since 04/04/2024
    @version version
    (examples)
    @see (links_or_references)
/*/
Static Function GcpAtuVenc(oModGCP200,oDadosEdt,cAvaliacao,dDtHmlIn)
local oModCO3    := oModGCP200:GetModel("CO3DETAIL") //Licitantes
local oModCP3    := oModGCP200:GetModel("CP3DETAIL") //Lotes
local oModCO2    := oModGCP200:GetModel("CO2DETAIL") //Produtos
local oModCO1    := oModGCP200:GetModel("CO1MASTER") //Cabeçalho
Local oLote      := Nil
Local oItem      := Nil
local nX         := 1 
local nP         := 1 
local cItemCo2   := ""

local aSaveLines := {}
local dDataVazia := cToD("")
Local lIsLote    := .F.

Default cAvaliacao := "1" //1=Por Item;2=Por Lote
Default dDtHmlIn   := dDataVazia

aSaveLines := FWSaveRows()
lIsLote    := (cAvaliacao == "2")

If lIsLote
    if ValType(oDadosEdt['lotes']) == "A"
        //Verificação em cada lote
        For nX := 1 To Len(oDadosEdt['lotes']) 

            oLote := oDadosEdt['lotes'][nX]
            oModCP3:Goline(oLote["NR_LOTE"])
            
            //Prcessamento dos lances do lote.
            ProLanLote(oModCO3, oLote, oDadosEdt['operacaoLote'])

            //Regra de inexigibilidade
            If oModCO1:GetValue("CO1_MODALI") == "IN" .And. ValType(oLote['itens']) == "A"
                For nP := 1 To Len(oLote['itens'])
                    If !Empty(oLote['itens'][nP]["DATA_HOMOLOGACAO"])
                        dDtHmlIn := cTod(oLote['itens'][nP]["DATA_HOMOLOGACAO"])
                    EndIf
                Next nP
            EndIf
        Next nX
    Endif 
Else
    if ValType(oDadosEdt['lotes']) == "A"
        //Mesmo sendo por item, sempre vai ter um lote
        For nX := 1 To Len(oDadosEdt['lotes']) 
            oLote := oDadosEdt['lotes'][nX]
            //Produtos
            if Valtype(oLote['itens']) == "A"
                for nP := 1 to Len(oLote['itens'])

                    oItem := oLote['itens'][nP]

                    cItemCo2    := StrZero(Val(oItem['_id']), TamSx3("CO2_ITEM")[1])
                    dDtHmlIn  := dDataVazia

                    If oModCO2:SeekLine({{"CO2_ITEM", cItemCo2}})
                        ProLanItem(oModCO3,oLote, oItem, oLote['Vencedores'], oLote['Inabilitados'], oModCO2:GetValue("CO2_CODPRO"),oDadosEdt['operacaoLote'])
                    EndIf

                    //Regra de inexigibilidade
                    if oModCO1:GetValue("CO1_MODALI") == "IN" .And. !Empty(oDadosEdt['lotes'][nX]['itens'][nP]["DATA_HOMOLOGACAO"])
                        dDtHmlIn:= cTod(oItem["DATA_HOMOLOGACAO"])
                    endif

                next nP
            endif    
        Next nX
    Endif
EndIf

FWRestRows(aSaveLines)
FwFreeArray(aSaveLines)

Return

/*/{Protheus.doc} GcpVlrComp
    (Atualiza os valores da composição do lote baseando-se de onde vêm os lances: Lote ou Item)
    @type  Static Function
    @author Thiago Rodrigues
    @since 04/04/2024
/*/
Static Function GcpVlrComp(oModGCP200, oDadosEdt)
    Local oCp3       As Object
    Local oCP6       As Object
    Local oCo3       As Object
    Local oCo2       As Object
    Local nNroLote   As Numeric
    Local nForLic    As Numeric
    Local nForIT     As Numeric
    Local cCnpj      As Character
    Local cCodCo2    As Character
    Local cFilSA2    As Character
    Local lMD        As Logical
    Local oLote      As Object
    Local oItem      As Object
    Local aArea      As Array
    Local nVlUnit    As Numeric

    oCp3    := oModGCP200:GetModel("CP3DETAIL") // Lotes
    oCP6    := oModGCP200:GetModel("CP6DETAIL") // Composição do lote
    oCo3    := oModGCP200:GetModel("CO3DETAIL") // Licitantes
    oCo2    := oModGCP200:GetModel("CO2DETAIL") // Produtos
    cFilSA2 := xFilial("SA2")
    aArea   := FwGetArea()

    If ValType(oDadosEdt['lotes']) == "A"
        
        //Lotes
        For nNroLote := 1 To Len(oDadosEdt['lotes']) 
            oLote := oDadosEdt['lotes'][nNroLote]
            oCp3:Goline(oLote["NR_LOTE"]) // Posiciona no lote pai

            If ValType(oLote["itens"]) == "A"
                
                // Licitantes do Protheus
                For nForLic := 1 To oCo3:Length()
                    oCo3:Goline(nForLic) 
                    cCnpj := GetAdvFVal("SA2", "A2_CGC", cFilSA2 + oCo3:GetValue("CO3_CODIGO") + oCo3:GetValue("CO3_LOJA"), 1)
                    
                    // Itens do Lote no JSON
                    For nForIT := 1 To Len(oLote["itens"])
                        oItem := oLote["itens"][nForIT]
                        lMD   := oItem["tipoJulgamento"] == "Maior Desconto"

                        cCodCo2 := StrZero(Val(oItem['_id']), TamSx3("CO2_ITEM")[1])
                        
                        If oCo2:SeekLine({{"CO2_ITEM", cCodCo2}})
                            
                            If oCP6:SeekLine({{"CP6_CODPRO", oCo2:GetValue("CO2_CODPRO")}, {"CP6_CODIGO", oCo3:GetValue("CO3_CODIGO")}})

                                // Executa a busca do valor do lance 
                                nVlUnit := GetLancCmp(oLote, oItem, cCnpj, lMD, oCP6:GetValue("CP6_QUANT"), oDadosEdt['operacaoLote'])

                                // Se localizou o valor do lance, atualiza a composição
                                If nVlUnit > 0
                                    oCP6:LoadValue("CP6_PRCUN", nVlUnit)
                                EndIf
                            EndIf

                        EndIf
                    Next nForIT 
                Next nForLic  

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
Static Function ProLanItem(oModCO3, oLote, oItem, aVence, aInab, cCodPro, nOperLote)
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
                        If aLances[nZ]["IdFornecedor"] == cCnpj
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
                            If aLances[nZ]["IdFornecedor"] == cCnpj
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
                            If aLances[nZ]["IdFornecedor"] == cCnpj
                                If ValType(aLances[nZ]["ValorTotalArredondamento"]) == "N"
                                    nValItem := aLances[nZ]["ValorTotalArredondamento"]
                                EndIf
                            EndIf
                        Next nZ
                    EndIf

                EndIf

                // Se o fornecedor enviou proposta mas não deu nenhum lance no item (nOperLote = 2).
                // herda o valor unitário da proposta inicial dele.
                If nValItem == 0
                    nValItem := aProp[nY]["ValorUnitario"]
                EndIf

                If nValItem > 0
                    oModCO3:LoadValue("CO3_VLUNIT", nValItem)
                EndIf

                // Atualiza o status (Vencedor ou Inabilitado)
                If nOperLote == 1 // Lote Global: Chama as funções passando o lote todo, pois o fornecedor pode ser vencedor ou inabilitado por algum item do lote
                    If ChkVenItem(oLote["Vencedores"], cCnpj, oLote["idLote"])
                        oModCO3:LoadValue("CO3_STATUS", "5")
                    Else 
                        CheckInab(oModCO3, oLote["Inabilitados"], cCnpj)
                    EndIf
                Else
                    // Disputa por item Chama as funções originais passando o Item
                    If ChkVenItem(aVence, cCnpj, nIdItem)
                        oModCO3:LoadValue("CO3_STATUS", "5")
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
                If aVence[nI]["IdFornecedor"] == cCnpj .And. aVence[nI][cIdJson] == nId
                    lRet := .T.
                    Exit
                EndIf
            Next nI
        Endif 
    EndIf

Return lRet

/*/{Protheus.doc} CheckInab
    (Verifica se o fornecedor foi inabilitado para o item e atualiza o status na CO3, caso positivo)
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/06/2026
    @parameter oModCO3 (modelo de licitantes para atualizar o status)
    @parameter aInab (array de inabilitados do item)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
    @see (links_or_references)
/*/
Static Function CheckInab(oModCO3, aInab, cCnpj)
    Local nI   As Numeric
    Local lRet As Logical
    Local nQtdInab As Numeric

    lRet := .F.
    nQtdInab := 0

    If ValType(aInab) == "A"
        nQtdInab := Len(aInab)
        if nQtdInab > 0
            For nI := 1 To nQtdInab
                If aInab[nI]["IdFornecedor"] == cCnpj 
                    oModCO3:LoadValue("CO3_STATUS", StatusInab(aInab[nI]["CodRejeicaoFornecedor"]))
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
    @type   Static Function
    @author Thiago Rodrigues
    @since  08/06/2026
    @parameter oModCO3 (modelo de licitantes para atualizar os valores e status)
    @parameter oLote (objeto do lote com os lances globais a serem processados)
    @see (links_or_references)
/*/
Static Function ProLanLote(oModCO3, oLote, nOperLote)
    Local nForCo3   As Numeric
    Local lFoundCO3 As Logical
    Local cCodCo3   As Character
    Local cLojCo3   As Character
    Local nIdLote   As Numeric
    Local oLances   As Array
    Local cFilSA2   As Character
    Local aVencs    As Array
    Local aInab     As Array
    Local lIsVenc   As Logical 

    lFoundCO3  := .F.
    cCodCo3    := ""
    cLojCo3    := ""
    nIdLote    := oLote["idLote"]
    oLances    := oLote["Lances"]
    cFilSA2    := xFilial("SA2")
    aVencs     := oLote["Vencedores"]
    aInab      := oLote["Inabilitados"]

    For nForCo3 := 1 To oModCO3:Length()
        oModCO3:GoLine(nForCo3)
        
        cCodCo3 := oModCO3:GetValue("CO3_CODIGO")
        cLojCo3 := oModCO3:GetValue("CO3_LOJA")
        cCnpj   := GetAdvFVal("SA2", "A2_CGC", cFilSA2 + cCodCo3 + cLojCo3, 1)
        
        nTotalLic := 0

        // --- Apura do valor conforme o modo de avaliação do lote
        If nOperLote == 1
            // Operação 1: Valor Global - Busca o último lance direto na raiz do lote
            nTotalLic := BusVlLnc(oLote, cCnpj)
        ElseIf nOperLote == 2
            // Operação 2: Por Item - Soma o último lance de cada item do lote para este fornecedor
            nTotalLic := SumLncIt(oLote["itens"], cCnpj)
        EndIf

        // Se o fornecedor participou da disputa deste lote, atualiza as informações
        If nTotalLic > 0
            oModCO3:LoadValue("CO3_VLUNIT", nTotalLic)
        Endif

        // Tratamento do status de Vencedor
        lIsVenc := ChcVenLtG(aVencs, cCnpj, nIdLote)

        If lIsVenc
            oModCO3:LoadValue("CO3_STATUS", "5")
        Else 
            CheckInaLT(oModCO3, aInab, cCnpj, nIdLote)
        EndIf
        
    Next nForCo3

    // Libera as arrays para o próximo processamento
    oLances := Nil
    aVencs  := Nil 
    aInab  := Nil

Return .T.


/*/{Protheus.doc} ChcVenLtG
    (Verifica se o fornecedor venceu a disputa do lote global)
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/06/2026
    @parameter aVencedores (array de vencedores do lote)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
    @parameter nIdLote (ID do lote a verificar)
/*/
Static Function ChcVenLtG(aVencedores, cCnpj, nIdLote)
    Local nI   As Numeric
    Local lRet As Logical  

    lRet := .F.

    If ValType(aVencedores) == "A"
        For nI := 1 To Len(aVencedores)
            If aVencedores[nI]["IdFornecedor"] == cCnpj .And. aVencedores[nI]["idLote"] == nIdLote
                lRet := .T.
                Exit
            EndIf
        Next nI
    EndIf

Return lRet

/*/{Protheus.doc} CheckInaLT
    (Verifica se o fornecedor foi inabilitado no escopo do lote)    
    @type  Static Function
    @author Thiago Rodrigues
    @since 08/06/2026
    @parameter oModCO3 (modelo de licitantes para atualizar o status)
    @parameter aInab (array de inabilitados do lote)
    @parameter cCnpj (CNPJ do fornecedor a verificar)
    @parameter nIdLote (ID do lote)
*/
Static Function CheckInaLT(oModCO3, aInab, cCnpj, nIdLote)
    Local nI   As Numeric
    Local lRet As Logical   

    nI   := 1
    lRet := .F.

    If ValType(aInab) == "A"
        For nI := 1 To Len(aInab)
            If aInab[nI]["IdFornecedor"] == cCnpj
                oModCO3:LoadValue("CO3_STATUS", StatusInab(aInab[nI]["CodRejeicaoFornecedor"]))
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
    Local nZ         As Numeric'

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
                If aLances[nY]["IdFornecedor"] == cCnpj
                    If ValType(aLances[nY]["ValorTotalArredondamento"]) == "N"
                        nVal := aLances[nY]["ValorTotalArredondamento"]
                    EndIf
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
    Local nSum     As Numeric
    Local nLastVal As Numeric
    Local aLncItm  As Array

    nSum := 0

    If ValType(aItens) == "A"
        For nP := 1 To Len(aItens)
            aLncItm  := aItens[nP]["Lances"]
            nLastVal := 0
            
            If ValType(aLncItm) == "A"
                For nY := 1 To Len(aLncItm)
                    If aLncItm[nY]["IdFornecedor"] == cCnpj
                        nLastVal := aLncItm[nY]["ValorTotalArredondamento"]
                    EndIf
                Next nY
                
                // Acumula na soma global do lote apenas o último lance encontrado deste item
                nSum += nLastVal
            EndIf
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

    nVal := 0

    //Disputa por Item (operacaoLote = 2)
    If nOperLote == 2 .And. ValType(oItem["Lances"]) == "A"
        aLances := oItem["Lances"]
        For nY := 1 To Len(aLances)
            If aLances[nY]["IdFornecedor"] == cCnpj
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
                If aLances[nY]["IdFornecedor"] == cCnpj
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
                If oLote["Lances"][nY]["IdFornecedor"] == cCnpj
                    if ValType(oLote["Lances"][nY]["ValorTotalArredondamento"]) == "N"
                       nVal := oLote["Lances"][nY]["ValorTotalArredondamento"]
                    Endif
                EndIf
            Next nY
            
            // Divisão proporcional pelo número de itens do lote
            If nVal > 0 .And. ValType(oLote["itens"]) == "A"
                nVal := nVal / Len(oLote["itens"])
            EndIf
        EndIf

        // Se não houver lances/readequações, pega a Proposta Original
        If nVal == 0 .And. ValType(oItem["Propostas"]) == "A"
            aNodes := oItem["Propostas"]
            For nY := 1 To Len(aNodes)
                If aNodes[nY]["IdFornecedor"] == cCnpj
                    If lMD
                        nVal := aNodes[nY]["ValorTotalArredondamento"] / nQuant
                    EndIf
                EndIf
            Next nY
        EndIf
    EndIf

    aLances := Nil
Return nVal
