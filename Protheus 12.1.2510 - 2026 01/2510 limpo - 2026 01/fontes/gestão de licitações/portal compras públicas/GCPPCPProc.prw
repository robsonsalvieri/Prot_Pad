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

    if (Len(oDadosEdt["Encerramento"]) > 0) .Or. (CO1->CO1_MODALI == "IN" .and. !Empty(oDadosEdt["DATA_ADJUDICACAO"])) 

        //Inclui os fornecedores na SA2 caso não exista, e também no edital
        lOk := GcpPCPFor(oDadosEdt)

        //Realiza o processamento do edital, andamento do Processo até a etapa de homologação
        if lOk
            lOk := GCP200PERM(oDadosEdt)
        endif

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
                            
                            if oDadosEdt['lotes'][nLote]["Lances"][nLance]["Valido"] //lance é valido 
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
                                    
                                        if oDadosEdt['lotes'][nLote]['itens'][nProd]["Lances"][nLance]["Valido"]//lance valido
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
                                        endif

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
Static Function GcpAtuVenc(oModGCP200,oDadosEdt,cCo1_Aval,dDtHmlIn)
local oModCO3    := oModGCP200:GetModel("CO3DETAIL") //Licitantes
local oModCP3    := oModGCP200:GetModel("CP3DETAIL") // Lotes
local oModCO2    := oModGCP200:GetModel("CO2DETAIL") //Produtos
local oModCO1    := oModGCP200:GetModel("CO1MASTER") //Cabeçalho
local xFilSA2    := xFilial("SA2")
local nX         := 1 //Contator lote
local nY         := 1 //Contador lance
local nP         := 1 //Contador por item
local cCnpj      := ""
local nZ         := 1 //Vencedor
local cItemCo2   := ""
local cCodCo3    := ""
local cLojCo3    := ""
local nForCo3    := "" //Contador Licitante/fornecedor
local nTotalLic  := 0  //Valor total do Licitante
local nVlUltLanc := 0  //Valor do último lance
local nPropReaq  := 0  //Contador propostas readequadas
local nDesconto  := 0  //Desconto
local aSaveLines := {}
local dDataVazia := cToD("")

aSaveLines:= FWSaveRows()

If cCo1_Aval == "2" //Por lote
    if ValType(oDadosEdt['lotes']) == "A"
        //Verificação em cada lote
        For nX := 1 To Len(oDadosEdt['lotes']) 
            oModCP3:Goline(oDadosEdt['lotes'][nX]["NR_LOTE"]) //Posiciona no lote

            //Para cada licitante
            For nForCo3 := 1 To oModCO3:Length() 
                nTotalLic  := 0
                nVlUltLanc := 0
                nDesconto  := 0

                oModCO3:Goline(nForCo3)
            
                //Para cada item
                for nP := 1 to Len(oDadosEdt['lotes'][nX]['itens'])
                    nVlUltLanc := 0
                    nDesconto  := 0
                    dDtHmlIn   := dDataVazia

                    //Verificação em cada proposta do item
                    For nY := 1 To Len(oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"]) 
                        cCnpj  := GetAdvFVal("SA2", "A2_CGC", xFilSA2 + oModCO3:GetValue("CO3_CODIGO"), 1)

                        //Apenas propostas do fornecedor atual
                        If cCnpj == oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]["IdFornecedor"] .And. oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['Valido']
    
                            //Recebe o valor total da proposta
                            If Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]["ValorTotalArredondamento"]) == "N"
                                nVlUltLanc := oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorTotalArredondamento'] // Tag com valor arredondado em duas casas
                            else 
                                nVlUltLanc := oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorTotal']
                            endif
                            
                            //Valor do desconto, se o julgamento for maior desconto
                            if Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorDesconto']) == "N"
                                nDesconto := oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorDesconto']
                            endif
                        Endif
                    Next nY

                    //Se houver proposta readequada deve sobrepor
                    if Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"]) == "A"    
                        For nPropReaq := 1 To Len(oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"]) 
                            cCnpj  := GetAdvFVal("SA2", "A2_CGC", xFilSA2 + oModCO3:GetValue("CO3_CODIGO"), 1)

                            //Apenas propostas do fornecedor atual
                            If cCnpj == oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"][nPropReaq]["IdFornecedor"] .And. oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"][nPropReaq]['Valido']
        
                                //Recebe o valor total da Proposta
                                If Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"][nPropReaq]["ValorTotalArredondamento"]) == "N"
                                    nVlUltLanc := oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"][nPropReaq]['ValorTotalArredondamento'] // Tag com valor arredondado em duas casas
                                else 
                                    nVlUltLanc := oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"][nPropReaq]['ValorTotal']
                                endif

                                //Valor do desconto, se o julgamento for maior desconto
                                if oDadosEdt['lotes'][nX]['itens'][nP]["tipoJulgamento"] == "Maior Desconto"
                                    nDesconto := oDadosEdt['lotes'][nX]['itens'][nP]["PropostasReadequadas"][nPropReaq]['ValorDesconto']
                                endif
                            Endif
                        Next nPropReaq
                    endif

                    //Total do licitante recebe o a soma das propostas validas de cada item
                    nTotalLic += nVlUltLanc
    
                    //inexebilidade a data de homologação vem no item, no protheus é no cabeçalho, gravamos do último item homologado.
                    if oModCO1:GetValue("CO1_MODALI") == "IN" .And. !Empty(oDadosEdt['lotes'][nX]['itens'][nP]["DATA_HOMOLOGACAO"])
                        dDtHmlIn:= cTod(oDadosEdt['lotes'][nX]['itens'][nP]["DATA_HOMOLOGACAO"])
                    endif

                    If oDadosEdt['operacaoLote'] ==  2
                        If Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["Vencedores"]) == "A" 
                            for Nz := 1 To Len(oDadosEdt['lotes'][nX]['itens'][nP]["Vencedores"])
                                if oDadosEdt['lotes'][nX]['itens'][nP]["Vencedores"][Nz]["IdFornecedor"] == cCnpj .Or. oDadosEdt['lotes'][nX]["Vencedores"][Nz]["IdFornecedor"] == cCnpj
                                    oModCO3:LoadValue("CO3_STATUS","5")
                                endif
                            Next Nz
                        Endif    
                    Endif

                next nP

                //Atualiza o valores do licitante
                oModCO3:LoadValue("CO3_VLUNIT",nTotalLic)
                oModCO3:LoadValue("CO3_DESCON",nDesconto)
        
                //Atualiza o fornecedor vencedor do lote
                If oDadosEdt['operacaoLote'] ==  1
                    if Valtype(oDadosEdt['lotes'][nX]["Vencedores"]) == "A"
                        for Nz := 1 To Len(oDadosEdt['lotes'][nX]["Vencedores"])
                            if oDadosEdt['lotes'][nX]["Vencedores"][Nz]["IdFornecedor"] == cCnpj
                                oModCO3:LoadValue("CO3_STATUS","5")
                            endif
                        Next Nz
                    endif
                Endif

            next  nForCo3   
        Next nX
    Endif 
Else
    if ValType(oDadosEdt['lotes']) == "A"
        //Mesmo sendo por item, sempre vai ter um lote
        For nX := 1 To Len(oDadosEdt['lotes']) 
            //Produtos
            if Valtype(oDadosEdt['lotes'][nX]['itens']) == "A"
                for nP := 1 to Len(oDadosEdt['lotes'][nX]['itens'])
                    cItemCo2    := StrZero(Val(oDadosEdt['lotes'][nX]['itens'][nP]['_id']), TamSx3("CO2_ITEM")[1])
                    dDtHmlIn  := dDataVazia

                    If oModCO2:SeekLine({{"CO2_ITEM", cItemCo2}})
                        //Verificação em cada proposta do lote
                        For nY := 1 To Len(oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"]) 
                            cCodCo3 := GetAdvFVal("SA2", "A2_COD", xFilSA2 + oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]["IdFornecedor"], 3)
                            cLojCo3 := GetAdvFVal("SA2", "A2_LOJA", xFilSA2 + cCodCo3, 1)
                            cCnpj   := oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]["IdFornecedor"]

                            //Busca fornecedor e produto na CO3
                            If oModCO3:SeekLine({{"CO3_CODIGO", cCodCo3}, {"CO3_LOJA", cLojCo3}, {"CO3_CODPRO", oModCO2:GetValue("CO2_CODPRO")}})
                                                            
                                //Atualiza o valor do Licitante e status do vencedor.
                                if oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['Valido']
                                
                                    oModCO3:LoadValue("CO3_VLUNIT",oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorUnitario'])
                                    if Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorDesconto']) == "N"
                                        oModCO3:LoadValue("CO3_DESCON",oDadosEdt['lotes'][nX]['itens'][nP]["Propostas"][nY]['ValorDesconto'])
                                    endif

                                    //Verifica se o fornecedor é o vencedor.  (Pode ser vencedor do item ou do lote)
                                    if Valtype(oDadosEdt['lotes'][nX]['itens'][nP]["Vencedores"]) == "A" 
                                        for Nz := 1 To Len(oDadosEdt['lotes'][nX]['itens'][nP]["Vencedores"])
                                            if oDadosEdt['lotes'][nX]['itens'][nP]["Vencedores"][Nz]["IdFornecedor"] == cCnpj .Or. oDadosEdt['lotes'][nX]["Vencedores"][Nz]["IdFornecedor"] == cCnpj
                                                oModCO3:LoadValue("CO3_STATUS","5")
                                            endif
                                        Next Nz
                                    elseif Valtype(oDadosEdt['lotes'][nX]["Vencedores"]) == "A"
                                        for Nz := 1 To Len(oDadosEdt['lotes'][nX]["Vencedores"])
                                            if oDadosEdt['lotes'][nX]["Vencedores"][Nz]["IdFornecedor"] == cCnpj
                                                oModCO3:LoadValue("CO3_STATUS","5")
                                            endif
                                        Next Nz
                                    endif
                                endif
                            EndIf
                        Next nY
                    EndIf

                    //inexebilidade a data de homologação vem no item, no protheus é no cabeçalho, gravamos do último item homologado.
                    if oModCO1:GetValue("CO1_MODALI") == "IN" .And. !Empty(oDadosEdt['lotes'][nX]['itens'][nP]["DATA_HOMOLOGACAO"])
                        dDtHmlIn:= cTod(oDadosEdt['lotes'][nX]['itens'][nP]["DATA_HOMOLOGACAO"])
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
    (Atualiza os valores da composição do lote)
    @type  Static Function
    @author Thiago Rodrigues
    @since 04/04/2024
    @version version
    (examples)
    @see (links_or_references)
/*/
Static Function GcpVlrComp(oModGCP200,oDadosEdt)
local oCp3      := oModGCP200:GetModel("CP3DETAIL") //Lotes
local oCP6      := oModGCP200:GetModel("CP6DETAIL") //Composição do lote
Local oCo3      := oModGCP200:GetModel("CO3DETAIL") //Licitantes
local oCo2      := oModGCP200:GetModel("CO2DETAIL") //Produtos
Local nNroLote  := 1 //Contador lote
local nForIT    := 1 //Contador item do lote
Local nForLic   := 1 //Contador licitantes
local nForProp  := 1 //Contador propostas
local nForProRe := 1 //Contador propostas readequadas
local cCnpj     := ""
local nVlUnit   := 0 
Local aArea     := FwGetArea()
local nValEstIt := 0 //Valor estimado do item
local lMD       := .F.

if ValType(oDadosEdt['lotes']) == "A"
    //Verificação em cada lote
    For nNroLote := 1 To Len(oDadosEdt['lotes']) 
        //Posiciona no lote
        oCp3:Goline(oDadosEdt['lotes'][nNroLote]["NR_LOTE"])

        if ValType(oDadosEdt['lotes'][nNroLote]["itens"]) == "A"
            //Licitante
            For nForLic := 1 to oCo3:Length()
                oCo3:Goline(nForLic) 
                cCnpj := GetAdvFVal("SA2","A2_CGC",xFilial("SA2")+oCo3:GetValue("CO3_CODIGO")+oCo3:GetValue("CO3_LOJA"),1)
                //Percorre os itens
                For nForIT := 1 to Len(oDadosEdt['lotes'][nNroLote]["itens"])

                    nValEstIt :=oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["VL_UNITARIO_ESTIMADO"]//Valor estimado
                    lMD := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["tipoJulgamento"] == "Maior Desconto"

                    //Posciona no item correspondente na CO2
                    oCo2:Goline(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["NR_ITEM"])

                    //Posiciona no item da composição
                    if oCP6:SeekLine({{"CP6_CODPRO", oCo2:GetValue("CO2_CODPRO")}, {"CP6_CODIGO", oCo3:GetValue("CO3_CODIGO")}})
                    
                        //Propostas
                        if ValType(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"]) == "A"
                            For nForProp := 1 to Len(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"])
                                //Verifica se a proposta foi do fornecedor e se a mesma é valida e atualiza o valor
                                if cCnpj == oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"][nForProp]["IdFornecedor"] .and.; 
                                    oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"][nForProp]["Valido"]

                                    if lMD
                                        If Valtype(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"][nForProp]["ValorTotalArredondamento"]) == "N"
                                            nVlUnit := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"][nForProp]["ValorTotalArredondamento"]/oCP6:GetValue("CP6_QUANT")
                                        else 
                                            nVlUnit := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"][nForProp]["ValorTotal"]/oCP6:GetValue("CP6_QUANT")
                                        endif
                                    else 
                                        nVlUnit := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["Propostas"][nForProp]["ValorUnitario"]
                                    endif
                                    
                                    oCP6:loadValue("CP6_PRCUN", nVlUnit) //Se o tipo for Maior desconto, no valor únitario recebemos o valor de desconto no item

                                endif
                            Next nForProp
                        endif    

                        //Propostas readequadas (Se houver, deve sobrepor a última proposta )
                        if Valtype(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"]) == "A"
                            For nForProRe := 1 to Len(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"])
                                //Verifica se a proposta foi do fornecedor e atualiza o valor
                                if cCnpj == oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"][nForProRe]["IdFornecedor"] .And.;
                                    oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"][nForProRe]["Valido"]

                                    if lMD
                                        if Valtype(oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"][nForProRe]["ValorTotalArredondamento"]) == "N"
                                            nVlUnit := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"][nForProRe]["ValorTotalArredondamento"] / oCP6:GetValue("CP6_QUANT")
                                        else
                                            nVlUnit := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"][nForProRe]["ValorUnitario"]
                                        endif
                                    else 
                                        nVlUnit := oDadosEdt['lotes'][nNroLote]["itens"][nForIT]["PropostasReadequadas"][nForProRe]["ValorUnitario"]
                                    endif

                                    oCP6:loadValue("CP6_PRCUN", nVlUnit)
                                endif
                            Next nForProRe

                        endif    

                    endif
                Next nForIT 
            Next nForLic  
        endif
    Next nNroLote
endif

FwRestArea(aArea)
FwFreeArray(aArea)
Return


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
