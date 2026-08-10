#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PGCA020.CH" 

//-- Define variáveis estáticas
Static _nOperation := MODEL_OPERATION_INSERT //-- Define tipo de operação a ser realizada no modelo de dados
Static _oJsonCtr := JsonObject():New() //-- Define Json para geração de contratos, estrutura esperada: { "contractgenerationtype": "1", "contracts":  [  { "cn9_condpg": "001", "cn9_tpcto": "001" } ] }

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
    Definição do modelo de dados.

@author rd.santos
@since 08/04/2022
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Static Function ModelDef() as Object
    Local aRequests   as Array
    Local aTriggers   as Array
    Local aUniqSCE    as Array
    Local cEntity     as Character
    Local cVehicles   as Character
    Local lCotRatP    as Logical
    Local lIntGC      as Logical
    Local nX          as Numeric
    Local oModel      as Object //-- Modelo de dados
    Local oStruDHU    as Object //-- Estrutura do cabeçalho
    Local oStruDHV    as Object //-- Estrutura do grid de produtos
    Local oStruSC1    as Object //-- Estrutura do grid de solicitações de compra
    Local oStruSC8    as Object //-- Estrutura do grid de propostas de fornecimento
    Local oStruSBM    as Object //-- Estrutura do grid de grupo de produtos
    Local oStruSCE    as Object //-- Estrutura do grid de encerramento de cotações
    Local oStruTMP    as Object //-- Estrutura do grid temporário de solicitações de compra
    Local bLinPreDHV  as CodeBlock 
    Local bLinPreSC8  as CodeBlock 
    
    //-- Inicializar as variáveis
    aRequests := {}
    oModel    := MPFormModel():New("PGCA020", /*bPre*/, {|oModel|PosValid(oModel, aRequests)}/*bPos*/, {|oModel|CommitData(oModel, aRequests)}/*bCommit*/, {|o|CancelData(oModel)}/*bCancel*/)
    bLinPreDHV  := { |oModelGrid, nLine, cAction, cField, xValue, xOldValue| PreVldDHV(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }
    bLinPreSC8  := { |oModelGrid, nLine, cAction, cField, xValue, xOldValue| PreVldSC8(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }
    
    If _nOperation == MODEL_OPERATION_INSERT .Or. _nOperation == 12 //-- Operação de inclusão de uma cotação ou inclusão de novo participante amarrado por Produto x Fornecedor
        lCotRatP    := SuperGetMv("MV_COTRATP",.F.,.F.)
        lIntGC      := SuperGetMv("MV_VEICULO",.F.,"N") == "S"
        cEntity     := Iif(lCotRatP,"|C1_CC|C1_CONTA|C1_ITEMCTA|C1_CLVL","")
        cVehicles   := Iif(lIntGC,"|C1_CODGRP|C1_CODITE","")
        oStruDHU    := FWFormStruct(1, "DHU")
        oStruDHV    := FWFormStruct(1, "DHV")
        oStruSBM    := FWFormStruct(1, "SBM", {|cField| AllTrim(cField) $ "BM_GRUPO|BM_DESC|"})
        oStruSC1    := FWFormStruct(1, "SC1", {|cField| AllTrim(cField) $ "C1_PRODUTO|C1_DESCRI|C1_QUANT|C1_DATPRF|C1_OBS|C1_QTSEGUM" + cEntity + cVehicles})
        oStruSC8    := FWFormStruct(1, "SC8")
        oStruSCE    := FWFormStruct(1, "SCE")
        
        //-- Adicionar submodelo de edição por campo (FormField)
        oModel:AddFields("DHUMASTER" /*cId*/, /*cOwner*/, oStruDHU /*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        
        VirtFldSBM(oStruSBM) //-- Adiciona campos virtuais da tabela Grupo de produtos (SBM)
        VirtFldSC1(oStruSC1) //-- Adiciona campos virtuais da tabela Solicitações de compra (SC1)
        VirtFldSC8(oStruSC8) //-- Adiciona campos virtuais da tabela propostas de fornecimento (SC8)
        VirtFldDHV(oStruDHV)

        if lCotRatP
            oStruSC1:RemoveField('C1_ITEM')
        endif

        //-- Adicionar submodelos de edição por grid (FormGrid)
        oModel:AddGrid("DHVDETAIL" /*cId*/, "DHUMASTER" /*cOwner*/, oStruDHV /*oModelStruct*/, bLinPreDHV/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SBMDETAIL" /*cId*/, "DHUMASTER" /*cOwner*/, oStruSBM /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SC1DETAIL" /*cId*/, "SBMDETAIL" /*cOwner*/, oStruSC1 /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SC8DETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSC8 /*oModelStruct*/, bLinPreSC8/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SCEDETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSCE /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

        If _nOperation <> 12
            oStruTMP := StructTMP(1)
            oModel:AddGrid("TMPDETAIL" /*cId*/, "SC1DETAIL" /*cOwner*/, oStruTMP /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
            oModel:GetModel("TMPDETAIL"):SetOnlyQuery(.T.)
            oModel:GetModel("TMPDETAIL"):SetOptional(.T.)
        EndIf
        
        //-- Define que o submodelo não será gravado
        oModel:GetModel("SBMDETAIL"):SetOnlyQuery(.T.)
        oModel:GetModel("SC1DETAIL"):SetOnlyQuery(.T.)

        //-- Atribuir a chave primária da entidade Modelo
        oModel:SetPrimaryKey({"DHU_FILIAL", "DHU_NUM"})

        //-- Atribuir o critério de relacionamento entre os submodelos
        oModel:SetRelation("DHVDETAIL" , {{"DHV_FILIAL", "xFilial('DHV')"}, {"DHV_NUM", "DHU_NUM"}}, DHV->(IndexKey(1))) //-- DHV_FILIAL, DHV_NUM, DHV_ITEM, DHV_PRODUTO
        oModel:SetRelation("SC8DETAIL" , {{"C8_FILIAL", "xFilial('SC8')"}, {"C8_NUM", "DHV_NUM"}, {"C8_ITEM", "DHV_ITEM"}}, SC8->(IndexKey(11))) //-- C8_FILIAL+C8_NUM+C8_ITEM+C8_FORNECE+C8_LOJA+C8_NUMPRO
        oModel:SetRelation("SCEDETAIL" , {{"CE_FILIAL", "xFilial('SCE')"}, {"CE_NUMCOT", "DHV_NUM"}, {"CE_ITEMCOT", "DHV_ITEM"}, {"CE_PRODUTO", "DHV_CODPRO"}}, SCE->(IndexKey(2))) //-- CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_ITEMGRD+CE_FORNECE+CE_LOJA+CE_NUMPRO+CE_IDENT+CE_SEQ
        
        //-- Atribuir uma descrição ao modelo
        oModel:SetDescription(STR0001) //-- "Cotação"

        //-- Definir chave única dos grids
        oModel:GetModel("DHVDETAIL"):SetUniqueLine({"DHV_ITEM", "DHV_CODPRO"})
        oModel:GetModel("SC8DETAIL"):SetUniqueLine({"C8_NUM", "C8_PRODUTO", "C8_ITEM", "C8_ITEMGRD", "C8_FORNECE", "C8_LOJA", "C8_FORNOME", "C8_NUMPRO"})
        oModel:GetModel("SCEDETAIL"):SetUniqueLine({"CE_NUMCOT", "CE_PRODUTO","CE_FORNECE", "CE_LOJA", "CE_NUMPRO"})

        //-- Definir grid como opcional
        oModel:SetOptional("SBMDETAIL", .T.)
        oModel:SetOptional("SC1DETAIL", .T.)
        oModel:SetOptional("SC8DETAIL", .T.)
        oModel:SetOptional("SCEDETAIL", .T.)
        
        //-- Configurar modo de edição de campos

        //-- SBM - Grupo de Produto
        oModel:GetModel("SBMDETAIL"):GetStruct():SetProperty("BM_GRUPO", MODEL_FIELD_OBRIGAT, .F.)
        
        //-- SC8 - Propostas de Fornecimento
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("*"       , MODEL_FIELD_WHEN , {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_QUANT", MODEL_FIELD_VALID, {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_PRECO", MODEL_FIELD_VALID, {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_TOTAL", MODEL_FIELD_VALID, {|| .T.})
        
        PGCReqFlds(oModel, 'SC8DETAIL') //-- Remove obrigatoriedade dos campos da SC8
        
        //-- SCE - Encerramento
        oModel:GetModel("SCEDETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .T.})
    ElseIf _nOperation == MODEL_OPERATION_DELETE .Or. _nOperation == 8 .Or. _nOperation == 10 .or. _nOperation == 11//-- Operação de exclusão da cotação/item da cotação/proposta
        bLinPreSC8  := { |oModelGrid, nLine, cAction, cField, xValue, xOldValue| PreVldSC8(oModelGrid, nLine, cAction, cField, xValue, xOldValue) }
        oStruDHU    := FWFormStruct(1, "DHU")
        oStruDHV    := FWFormStruct(1, "DHV")
        oStruSC8    := FWFormStruct(1, "SC8")
        
        //-- Adicionar submodelo de edição por campo (FormField)
        oModel:AddFields("DHUMASTER" /*cId*/, /*cOwner*/, oStruDHU /*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        
        //-- Adicionar submodelos de edição por grid (FormGrid)
        oModel:AddGrid("DHVDETAIL" /*cId*/, "DHUMASTER" /*cOwner*/, oStruDHV /*oModelStruct*/, bLinPreDHV/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SC8DETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSC8 /*oModelStruct*/, bLinPreSC8/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        
        //-- Atribuir a chave primária da entidade Modelo
        oModel:SetPrimaryKey({"DHU_FILIAL", "DHU_NUM"})

        //-- Atribuir o critério de relacionamento entre os submodelos
        oModel:SetRelation("DHVDETAIL" , {{"DHV_FILIAL", "xFilial('DHV')"}, {"DHV_NUM", "DHU_NUM"}}, DHV->(IndexKey(1))) //-- DHV_FILIAL, DHV_NUM, DHV_ITEM, DHV_PRODUTO
        oModel:SetRelation("SC8DETAIL" , {{"C8_FILIAL", "xFilial('SC8')"}, {"C8_NUM", "DHV_NUM"}, {"C8_ITEM", "DHV_ITEM"}}, SC8->(IndexKey(11))) //-- C8_FILIAL+C8_NUM+C8_ITEM+C8_FORNECE+C8_LOJA+C8_NUMPRO
        
        //-- Definir chave única dos grids
        oModel:GetModel("DHVDETAIL"):SetUniqueLine({"DHV_ITEM", "DHV_CODPRO"})
        oModel:GetModel("SC8DETAIL"):SetUniqueLine({"C8_NUM", "C8_PRODUTO", "C8_ITEM", "C8_ITEMGRD", "C8_FORNECE", "C8_LOJA", "C8_FORNOME", "C8_NUMPRO"})

        //-- Configurar modo de edição de campos

        //-- SC8 - Propostas de Fornecimento
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN , {|| .T.})
    ElseIf _nOperation == 9 //-- Operação de análise de cotação
        oStruDHU    := FWFormStruct(1, "DHU")
        oStruDHV    := FWFormStruct(1, "DHV")
        oStruSC8    := FWFormStruct(1, "SC8")
        oStruSCE    := FWFormStruct(1, "SCE")
        
        //-- Adicionar submodelo de edição por campo (FormField)
        oModel:AddFields("DHUMASTER" /*cId*/, /*cOwner*/, oStruDHU /*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)

        //-- Adicionar submodelos de edição por grid (FormGrid)
        oModel:AddGrid("DHVDETAIL" /*cId*/, "DHUMASTER" /*cOwner*/, oStruDHV /*oModelStruct*/, bLinPreDHV/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SC8DETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSC8 /*oModelStruct*/, bLinPreSC8/*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
        oModel:AddGrid("SCEDETAIL" /*cId*/, "DHVDETAIL" /*cOwner*/, oStruSCE /*oModelStruct*/, /*bLinePre*/, {|oModelGrid| PosVldSCE(oModelGrid)}/*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

        //-- Atribuir a chave primária da entidade Modelo
        oModel:SetPrimaryKey({"DHU_FILIAL", "DHU_NUM"})

        //-- Atribuir o critério de relacionamento entre os submodelos
        oModel:SetRelation("DHVDETAIL" , {{"DHV_FILIAL", "xFilial('DHV')"}, {"DHV_NUM", "DHU_NUM"}}, DHV->(IndexKey(1))) //-- DHV_FILIAL, DHV_NUM, DHV_ITEM, DHV_PRODUTO
        oModel:SetRelation("SC8DETAIL" , {{"C8_FILIAL", "xFilial('SC8')"}, {"C8_NUM", "DHV_NUM"}, {"C8_ITEM", "DHV_ITEM"}}, SC8->(IndexKey(11))) //-- C8_FILIAL+C8_NUM+C8_ITEM+C8_FORNECE+C8_LOJA+C8_NUMPRO
        oModel:SetRelation("SCEDETAIL", {{"CE_FILIAL", "xFilial('SCE')"}, {"CE_NUMCOT", "DHV_NUM"}, {"CE_ITEMCOT", "DHV_ITEM"}, {"CE_PRODUTO", "DHV_CODPRO"}}, SCE->(IndexKey(2))) //-- CE_FILIAL+CE_NUMCOT+CE_ITEMCOT+CE_PRODUTO+CE_ITEMGRD+CE_FORNECE+CE_LOJA+CE_NUMPRO+CE_IDENT+CE_SEQ

        //-- Definir chave única dos grids
        oModel:GetModel("DHVDETAIL"):SetUniqueLine({"DHV_ITEM", "DHV_CODPRO"})
        oModel:GetModel("SC8DETAIL"):SetUniqueLine({"C8_NUM", "C8_PRODUTO", "C8_ITEM", "C8_ITEMGRD", "C8_FORNECE", "C8_LOJA", "C8_FORNOME", "C8_NUMPRO"})

        aUniqSCE := {"CE_NUMCOT", "CE_PRODUTO","CE_FORNECE", "CE_LOJA", "CE_NUMPRO", "CE_NUMPED", "CE_ITEMPED"}

        DbSelectArea('SCE')
        
        If FieldPos("CE_NUMCTR") > 0
            aAdd(aUniqSCE, "CE_NUMCTR")
        EndIf

        oModel:GetModel("SCEDETAIL"):SetUniqueLine(aUniqSCE)

        //oModel:SetOptional("SCEDETAIL", .T.)
        oModel:SetOptional("DHVDETAIL", .T.)
        oModel:SetOptional("SC8DETAIL", .T.)
        oModel:SetOptional("SCEDETAIL", .T.)
        oModel:GetModel("SCEDETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

        //-- Configurar modo de edição de campos

        //-- SC8 - Propostas de Fornecimento
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN , {|| .T.})
        oModel:GetModel('SC8DETAIL'):GetStruct():SetProperty("C8_TPDOC", MODEL_FIELD_VALUES, {'1', '2'})

        //-- SCE - Encerramento
        oModel:GetModel("SCEDETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .T.})
    Else //-- Operação de atualização dos itens da cotação
        oStruDHU := FWFormStruct(1, "DHU")
        oStruSC8 := FWFormStruct(1, "SC8")

        //-- Adicionar submodelo de edição por campo (FormField)
        oModel:AddFields("DHUMASTER" /*cId*/, /*cOwner*/, oStruDHU /*oModelStruct*/, /*bPre*/, /*bPost*/, /*bLoad*/)

        //-- Adicionar submodelos de edição por grid (FormGrid)
        oModel:AddGrid("SC8DETAIL" /*cId*/, "DHUMASTER" /*cOwner*/, oStruSC8 /*oModelStruct*/, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

        //-- Atribuir a chave primária da entidade Modelo
        oModel:SetPrimaryKey({"DHU_FILIAL", "DHU_NUM"})

        //-- Atribuir o critério de relacionamento entre os submodelos
        oModel:SetRelation("SC8DETAIL" , {{"C8_FILIAL", "xFilial('SC8')"}, {"C8_NUM", "DHU_NUM"}}, SC8->(IndexKey(1))) //-- C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

        //-- Definir chave única dos grids
        oModel:GetModel("SC8DETAIL"):SetUniqueLine({"C8_NUM", "C8_PRODUTO", "C8_ITEM", "C8_ITEMGRD", "C8_FORNECE", "C8_LOJA", "C8_FORNOME", "C8_NUMPRO"})

        //-- Desativa gatilhos gatilhos (Não deve utilizar gatilhos do banco de dados)
        aTriggers := oModel:GetModel('SC8DETAIL'):GetStruct():GetTriggers()
        
        For nX := 1 To Len(aTriggers)
            aTriggers[nX][3] := {|| .F.}
        Next nX

        //-- SC8 - Propostas de Fornecimento
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("*"        , MODEL_FIELD_WHEN , {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_QUANT" , MODEL_FIELD_VALID, {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_PRECO" , MODEL_FIELD_VALID, {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_DESC"  , MODEL_FIELD_VALID, {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_VLDESC", MODEL_FIELD_VALID, {|| .T.})
        oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty("C8_TOTAL" , MODEL_FIELD_VALID, {|| .T.})
    EndIf

    oModel:InstallEvent("EVDEF",, PGCA020EVDEF():New()) //-- Instala eventos
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} VirtFldSBM
    Adiciona campo virtual na estrutura de Grupo de Produtos (SBM).
@author juan.felipe
@since 23/05/2022
@version 1.0
@param oStruSBM, object, estrutura da SBM.
@return Nil, nulo.
/*/
//-------------------------------------------------------------------
Static Function VirtFldSBM(oStruSBM)
    oStruSBM:AddField( ;                                                  
                        AllTrim('') , ; 	  // [01] C Titulo do campo
                        AllTrim('') , ; 	  // [02] C ToolTip do campo
                        'LEGENDA' , ;         // [03] C identificador (ID) do Field
                        'C' , ;               // [04] C Tipo do campo
                        50 , ;                // [05] N Tamanho do campo
                        0 , ;                 // [06] N Decimal do campo
                        NIL , ;               // [07] B Code-block de validação do campo
                        NIL , ;               // [08] B Code-block de validação When do campo
                        NIL , ;               // [09] A Lista de valores permitido do campo
                        NIL , ;               // [10] L Indica se o campo tem preenchimento obrigatório
                        { || "BR_VERDE" } , ; // [11] B Code-block de inicializacao do campo
                        NIL , ;               // [12] L Indica se trata de um campo chave
                        NIL , ;               // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                 // [14] L Indica se o campo é virtual
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VirtFldSC1
    Adiciona campo virtual na estrutura de Solicitações de Compra (SC1).
@author juan.felipe
@since 23/05/2022
@version 1.0
@param oStruSC1, object, estrutura da SC1.
@return Nil, nulo.
/*/
//------------------------------------------------------------------
Static Function VirtFldSC1(oStruSC1)
    oStruSC1:AddField( ;                                                  
                        AllTrim('') , ; 	 // [01] C Titulo do campo
                        AllTrim('') , ; 	 // [02] C ToolTip do campo
                        'LEGENDA' , ;        // [03] C identificador (ID) do Field
                        'C' , ;              // [04] C Tipo do campo
                        50 , ;               // [05] N Tamanho do campo
                        0 , ;                // [06] N Decimal do campo
                        NIL , ;              // [07] B Code-block de validação do campo
                        NIL , ;              // [08] B Code-block de validação When do campo
                        NIL , ;              // [09] A Lista de valores permitido do campo
                        NIL , ;              // [10] L Indica se o campo tem preenchimento obrigatório
                        { || "BR_VERDE" } , ;// [11] B Code-block de inicializacao do campo
                        NIL , ;              // [12] L Indica se trata de um campo chave
                        NIL , ;              // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                // [14] L Indica se o campo é virtual

    oStruSC1:AddField( ;                                                  
                            AllTrim('ITEMSC') , ; // [01] C Titulo do campo
                            AllTrim('') , ; 	  // [02] C ToolTip do campo
                            'ITEMSC' , ;          // [03] C identificador (ID) do Field
                            'M' , ;               // [04] C Tipo do campo
                            80 , ;                // [05] N Tamanho do campo
                            0 , ;                 // [06] N Decimal do campo
                            NIL , ;               // [07] B Code-block de validação do campo
                            NIL , ;               // [08] B Code-block de validação When do campo
                            NIL , ;               // [09] A Lista de valores permitido do campo
                            NIL , ;               // [10] L Indica se o campo tem preenchimento obrigatório
                            NIL , ;  		      // [11] B Code-block de inicializacao do campo
                            NIL , ;               // [12] L Indica se trata de um campo chave
                            NIL , ;               // [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. )                 // [14] L Indica se o campo é virtual                        

    oStruSC1:AddField( ;                                                  
                            AllTrim('GRADE') , ; // [01] C Titulo do campo
                            AllTrim('') , ; 	 // [02] C ToolTip do campo
                            'GRADE' , ;          // [03] C identificador (ID) do Field
                            'L' , ;              // [04] C Tipo do campo
                            1, ;                 // [05] N Tamanho do campo
                            0 , ;                // [06] N Decimal do campo
                            NIL , ;              // [07] B Code-block de validação do campo
                            NIL , ;              // [08] B Code-block de validação When do campo
                            NIL , ;              // [09] A Lista de valores permitido do campo
                            NIL , ;              // [10] L Indica se o campo tem preenchimento obrigatório
                            {|| .F.} , ;  		 // [11] B Code-block de inicializacao do campo
                            NIL , ;              // [12] L Indica se trata de um campo chave
                            NIL , ;              // [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. )                // [14] L Indica se o campo é virtual
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VirtFldSC8
    Adiciona campo virtual na estrutura de Cotações (SC8).
@author juan.felipe
@since 23/05/2022
@version 1.0
@param oStruSC8, object, estrutura da SC8.
@return Nil, nulo.
/*/
//------------------------------------------------------------------
Static Function VirtFldSC8(oStruSC8)
    oStruSC8:AddField( ;                                                  
                        AllTrim(STR0006) , ; 	 // [01] C Titulo do campo
                        AllTrim('') , ; 			 // [02] C ToolTip do campo
                        'C8_CRITER' , ;              // [03] C identificador (ID) do Field
                        'C' , ;                      // [04] C Tipo do campo
                        40 , ;                       // [05] N Tamanho do campo
                        0 , ;                        // [06] N Decimal do campo
                        NIL , ;                      // [07] B Code-block de validação do campo
                        NIL , ;                      // [08] B Code-block de validação When do campo
                        NIL , ;                      // [09] A Lista de valores permitido do campo
                        NIL , ;                      // [10] L Indica se o campo tem preenchimento obrigatório
                        { || STR0007 } , ; // [11] B Code-block de inicializacao do campo
                        NIL , ;                      // [12] L Indica se trata de um campo chave
                        NIL , ;                      // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                        // [14] L Indica se o campo é virtual         
    oStruSC8:AddField( ;                                                  
                        AllTrim(STR0008) , ; // [01] C Titulo do campo
                        AllTrim('') , ; 	   // [02] C ToolTip do campo
                        'C8_ALIAS' , ;         // [03] C identificador (ID) do Field
                        'C' , ;                // [04] C Tipo do campo
                        10 , ;                 // [05] N Tamanho do campo
                        0 , ;                  // [06] N Decimal do campo
                        NIL , ;                // [07] B Code-block de validação do campo
                        NIL , ;                // [08] B Code-block de validação When do campo
                        NIL , ;                // [09] A Lista de valores permitido do campo
                        NIL , ;                // [10] L Indica se o campo tem preenchimento obrigatório
                        Nil, ;  			   // [11] B Code-block de inicializacao do campo
                        NIL , ;                // [12] L Indica se trata de um campo chave
                        NIL , ;                // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                  // [14] L Indica se o campo é virtual                        
    oStruSC8:AddField( ;                                                  
                            AllTrim('Recno') , ; // [01] C Titulo do campo
                            AllTrim('') , ; 	   // [02] C ToolTip do campo
                            'C8_RECNO' , ;         // [03] C identificador (ID) do Field
                            'N' , ;                // [04] C Tipo do campo
                            8, ;                   // [05] N Tamanho do campo
                            0 , ;                  // [06] N Decimal do campo
                            NIL , ;                // [07] B Code-block de validação do campo
                            NIL , ;                // [08] B Code-block de validação When do campo
                            NIL , ;                // [09] A Lista de valores permitido do campo
                            NIL , ;                // [10] L Indica se o campo tem preenchimento obrigatório
                            Nil, ;  			   // [11] B Code-block de inicializacao do campo
                            NIL , ;                // [12] L Indica se trata de um campo chave
                            NIL , ;                // [13] L Indica se o campo pode receber valor em uma operação de update.
                            .T. )                  // [14] L Indica se o campo é virtual  
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VirtFldDHV
    Adiciona campo virtual na estrutura de Saldos (DHV).
@author juan.felipe
@since 04/04/2024
@version 1.0
@param oStruSC8, object, estrutura da SC8.
@return Nil, nulo.
/*/
//------------------------------------------------------------------
Static Function VirtFldDHV(oStruDHV)
    oStruDHV:AddField( ;
							AllTrim('ITEMSC') , ; // [01] C Titulo do campo
							AllTrim('') , ; 	  // [02] C ToolTip do campo
							'ITEMSC' , ;          // [03] C identificador (ID) do Field
							'M' , ;               // [04] C Tipo do campo
							80 , ;                // [05] N Tamanho do campo
							0 , ;                 // [06] N Decimal do campo
							NIL , ;               // [07] B Code-block de validação do campo
							NIL , ;               // [08] B Code-block de validação When do campo
							NIL , ;               // [09] A Lista de valores permitido do campo
							NIL , ;               // [10] L Indica se o campo tem preenchimento obrigatório
							NIL , ;  		      // [11] B Code-block de inicializacao do campo
							NIL , ;               // [12] L Indica se trata de um campo chave
							NIL , ;               // [13] L Indica se o campo pode receber valor em uma operação de update.
							.T. )                 // [14] L Indica se o campo é virtual   
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PG020Num
    Inicializador padrão do campo DHU_NUM
@author juan.felipe
@since 04/05/2022
@version 1.0
@return cNum, character, número da cotação
/*/
//-------------------------------------------------------------------
Function PG020Num()
    Local aAreas := {SC8->(GetArea()), GetArea()}
    Local cNum  := GetSx8Num("SC8","C8_NUM")

    SC8->(dbSetOrder(1)) //-- C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD

    While SC8->(MsSeek(xFilial("SC8")+cNum))
        While __lSx8
            ConfirmSX8()
        EndDo
        cNum := GetSx8Num("SC8","C8_NUM")
    EndDo

    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
Return cNum

//-------------------------------------------------------------------
/*/{Protheus.doc} PreVldDHV
    Pré-valid do grid de Produtos (DHV).
@author juan.felipe
@since 09/05/2022
@version 1.0
@return lRet, logical, fornecedor válido.
/*/
//-------------------------------------------------------------------
Static Function PreVldDHV(oModelDHV, nLine, cAction, cField, xValue, xOldValue)
    Local lRet := .T.
    Local oModel := oModelDHV:GetModel()

    DO CASE
        CASE cAction == 'SETVALUE' .And. cField == "DHV_CODPRO" //-- Valida chave estrangeira e bloqueio do produto
            lRet := ExistCpo("SB1", xValue) .And. SB1->(MsSeek(xFilial("SB1")+xValue)) .And. RegistroOk("SB1")
		CASE cAction == 'DELETE' .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. (_nOperation == 8 .or. _nOperation == 11) //-- Valida se pode deletar os itens
            If oModelDHV:Length() == 1
                Help(" ",1,"PG020ONEITEM",,STR0010,1,0) //-- Há apenas um item nesta cotação, portanto não é possível remove-lo.
                lRet := .F.
            ElseIf _nOperation != 11 .and. !hasAttendItems(oModel, .T.) //-- Verifica se tem ao menos um item respondido e operação diferente de exclusão da edição cotação
                lRet := .F.
            EndIf
    END CASE
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PreVldSC8
    Pré-valid do grid Histórico da Cotação (SC8).
@author juan.felipe
@since 09/05/2022
@version 1.0
@return lRet, logical, fornecedor válido.
/*/
//-------------------------------------------------------------------
Static Function PreVldSC8(oModelSC8, nLine, cAction, cField, xValue, xOldValue)
    Local lRet := .T.
    Local cItem := ''
    Local cQuotation := ''
    Local cSupplier := ''
    Local cStore := ''
    Local cProposal := ''
    Local cSupName := ''
    Local oModel := oModelSC8:GetModel()

    DO CASE
        CASE cAction == 'SETVALUE' .And. cField == "C8_LOJA" //-- Valida chave estrangeira e bloqueio do fornecedor
            lRet := ExistCpo("SA2", oModelSC8:GetValue('C8_FORNECE') + xValue) .And. RegistroOk("SA2")
        CASE cAction == 'DELETE' .And. PG020GetOp() == 8 //-- Valida exclusão da proposta do fornecedor
            cQuotation := oModelSC8:GetValue('C8_NUM')
            cSupplier  := oModelSC8:GetValue('C8_FORNECE')
            cStore     := oModelSC8:GetValue('C8_LOJA')
            cProposal  := oModelSC8:GetValue('C8_NUMPRO')
            cSupName   := oModelSC8:GetValue('C8_FORNOME')

            If oModelSC8:GetValue('C8_TOTAL') > 0 .And. cProposal == PGCLastProp(cQuotation, cSupplier, cStore, cSupName) //-- Valida apenas a ultima proposta do fornecedor
                cItem := AllTrim(oModelSC8:GetValue('C8_PRODUTO')) + '-' + AllTrim(oModelSC8:GetValue('C8_ITEM'))
                oModel:SetErrorMessage(,,,, 'PG020NODELITEM', StrTran(STR0009, '{}', cItem)) //-- Não foi possível excluir o item XXXX pois ele foi respondido por um ou mais fornecedores.
                lRet := .F.
            EndIf
        CASE cAction == 'DELETE' .And. PG020GetOp() == 10 .And. oModelSC8:Length() == 1 //-- Valida se pode deletar a primeira proposta do fornecedor quando a cotação tiver apenas 1 item e 1 fornecedor.
            lRet := CanDelQuote(oModel)
    END CASE
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosVldSCE
    Pós-valid do grid Encerramento de Cotações (SCE).
@author juan.felipe
@since 16/06/2022
@version 1.0
@return lRet, logical, grid válido.
/*/
//-------------------------------------------------------------------
Static Function PosVldSCE(oModelSCE)
    Local lRet := .T.
    Local cSupplier := ''
    Local cProduct := ''
    Local oModel := oModelSCE:GetModel()
    Local oModelSC8 := oModel:GetModel('SC8DETAIL')

    If oModelSCE:GetValue('CE_QUANT') == 0
        cSupplier := AllTrim(oModelSC8:GetValue('C8_FORNECE')) + '-' +  AllTrim(oModelSC8:GetValue('C8_LOJA'))
        cProduct := AllTrim(oModelSC8:GetValue('C8_PRODUTO')) + '-' + AllTrim(oModelSC8:GetValue('C8_ITEM'))
        oModel:SetErrorMessage(,,,, 'PG020NOBALANCE', STR0015 + cSupplier + STR0016 + cProduct + '.')
        lRet := .F.
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid
    Pós validação do modelo.
@author juan.felipe
@since 16/05/2022
@version 1.0
@param oModel, object, modelo de dados.
@param aRequests, array, solicitações de compra.
@return lRet, logical, commita os dados.
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel, aRequests)
    Local lRet        := .T.
    Local lInsert     := .F.
    Local lDelete     := .F.
    Local oModelDHU   := Nil
    Local oModelDHV   := Nil
    Default oModel    := FwModelActive()
    Default aRequests := {}

    lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT
    lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE .Or. PG020GetOp() == 10

    oModelDHU := oModel:GetModel('DHUMASTER')
    oModelDHV := oModel:GetModel('DHVDETAIL')

    If lDelete //-- Validação da exclusão da cotação
        lRet := CanDelQuote(oModel)
    Else
        lRet := !lInsert .Or. a131Posvld(oModel, aRequests, oModelDHU:GetValue('DHU_NUM'))

        If lRet .And. _nOperation == 9 .And. oModelDHU:GetValue('DHU_TPDOC') == '2'
            lRet := ValidTpPla()
        EndIf
    EndIf
Return lRet
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CommitData
    Commita os dados.
@author juan.felipe
@since 16/05/2022
@version 1.0
@param oModel, object, modelo de dados.
@param aRequests, array, solicitações de compra.
@return lRet, logical, commita os dados.
/*/
//-------------------------------------------------------------------
Static Function CommitData(oModel, aRequests)
    Local lRet        := .T.
    Local lInsert     := .F.
    Local lUpdate     := .F.
    Local lDelete     := .F.
    Local nSaveSX8    := GetSX8Len()
    Local cQuotNum    := ""
    Default oModel    := FwModelActive()
    Default aRequests := {}

    cQuotNum := oModel:GetValue('DHUMASTER', 'DHU_NUM')
    lInsert := oModel:GetOperation() == MODEL_OPERATION_INSERT
    lUpdate := oModel:GetOperation() == MODEL_OPERATION_UPDATE
    lDelete := oModel:GetOperation() == MODEL_OPERATION_DELETE

    If lInsert
        lRet := a131GrvMVC(oModel, aRequests, cQuotNum, nSaveSX8)
    ElseIf lUpdate .Or. lDelete
        lRet := FwFormCommit(oModel) .And. !oModel:HasErrorMessage()
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CancelData
    Cancela a inclusão dos dados.
@author juan.felipe
@since 06/05/2022
@version 1.0
@param oModel, object, modelo de dados.
@return lRet, logical, cancelar dados.
/*/
//-------------------------------------------------------------------
Static Function CancelData(oModel)
    Local lRet := .T.
    Default oModel := FwModelActive()
    
    FwFormCancel(oModel)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PG020SetOp
    Seta operação a ser realizada no modelo.
@author juan.felipe
@since 16/11/2022
@version 1.0
@param nOperation, numeric, operação a ser realizada (segue modelo do método SetOperation do MVC).
@return Nil, nulo.
/*/
//-------------------------------------------------------------------
Function PG020SetOp(nOperation)
    Default nOperation := 0

    _nOperation := nOperation
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PG020GetOp
    Obtém operação a ser realizada no modelo.
@author juan.felipe
@since 09/01/2023
@version 1.0
@return _nOperation, numeric, número da operação.
/*/
//-------------------------------------------------------------------
Function PG020GetOp()
Return _nOperation

/*/{Protheus.doc} CanDelQuote
    Verifica se é possível excluir a cotação/item da cotação.
@author juan.felipe
@since 19/01/2023
@param oModel, object, modelo de dados.
@return lRet, logical, pode ser excluído.
/*/
Static Function CanDelQuote(oModel)
    Local lRet As Logical
    Local oModelDHU As Object
    Local oModelDHV As Object
    Local oModelSC8 As Object
    Local cQuotation As Character
    Local cSupplier As Character
    Local cStore As Character
    Local cCorporateName As Character
    Local nX As Numeric
    Local nY As Numeric
    Local nRecno As Numeric
    Default oModel := FwModelActive()

    lRet := .T.

    oModelDHU := oModel:GetModel('DHUMASTER')
    oModelDHV := oModel:GetModel('DHVDETAIL')
    oModelSC8 := oModel:GetModel('SC8DETAIL')

    cQuotation := oModelSC8:GetValue('C8_NUM')
    cSupplier  := oModelSC8:GetValue('C8_FORNECE')
    cStore     := oModelSC8:GetValue('C8_LOJA')
    cCorporateName := oModelSC8:GetValue('C8_FORNOME')

    If oModelDHU:GetValue('DHU_STATUS') == '3'
        Help(" ",1,"PG020ANALYSIS",,StrTran(STR0012, '{}', oModelDHU:GetValue('DHU_NUM')) ,1,4) //-- Não é possível excluir a cotação {} pois ela está em análise.
        lRet := .F.
    ElseIf oModelDHU:GetValue('DHU_STATUS') == '4'
        Help(" ",1,"PG020FINALIZED",,StrTran(STR0013, '{}', oModelDHU:GetValue('DHU_NUM')) ,1,4) //-- Não é possível excluir a cotação {} pois ela está finalizada.
        lRet := .F.
    ElseIf PG020GetOp() == 10 .And. PGCQtProp(cQuotation, cSupplier, cStore, cCorporateName) == 1
        Help(" ",1,"PG020NODELPROP",,STR0014,1,4) //-- Não é possível excluir a primeira proposta da cotação.
        lRet := .F.
    EndIf

    If lRet
        For nX := 1 To oModelDHV:Length()
            oModelDHV:GoLine(nX)

            For nY := 1 To oModelSC8:Length()
                oModelSC8:GoLine(nY)
                nRecno := oModelSC8:GetDataId()
                
                If !MaCanDelCot('SC8',,,, .T., nRecno) //-- Valida se pode excluir a cotação
                    lRet := .F.
                    Exit
                EndIf
            Next nY

            If !lRet
                Exit
            EndIf
        Next nX
    EndIf
Return lRet


/*/{Protheus.doc} hasAttendItems
	Verifica se a cotação tem algum item respondido.
@author juan.felipe
@since 31/01/2023
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Static Function hasAttendItems(oModel, lDelete)
    Local lRet As Logical
    Local oModelDHU As Object
    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Default oModel := FwModelActive()
    Default lDelete := .F.

    lRet := .T.
    oModelDHU := oModel:GetModel('DHUMASTER')

    cQuery := " SELECT DISTINCT SC8.C8_FILIAL,"
    cQuery += "     SC8.C8_NUM,"
    cQuery += "     SC8.C8_NUMPRO,"
    cQuery += "     COUNT(SC8.C8_ITEM) ITEMS"
    cQuery += " FROM "+ RetSQLName("SC8") +" SC8"
    cQuery += " WHERE SC8.C8_FILIAL = ?"
    cQuery += " AND SC8.C8_NUM = ?"
    cQuery += " AND SC8.D_E_L_E_T_ = ' '"
    cQuery += " AND SC8.C8_NUMPRO =" //-- Pega última proposta
    cQuery += "     (SELECT MAX(SC8_2.C8_NUMPRO)"
    cQuery += "     FROM "+ RetSQLName("SC8") +" SC8_2"
    cQuery += "     WHERE SC8_2.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "     AND SC8_2.C8_NUM = SC8.C8_NUM"
    cQuery += "     AND SC8_2.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "     AND SC8_2.C8_LOJA = SC8.C8_LOJA"
    cQuery += "     AND SC8_2.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "     AND SC8_2.D_E_L_E_T_ = ' ' )"
    cQuery += " AND SC8.C8_TOTAL > 0"
    cQuery += " GROUP BY C8_FILIAL,"
    cQuery += "         C8_NUM,"
    cQuery += "         C8_ITEM,"
    cQuery += "         C8_NUMPRO"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, oModelDHU:GetValue('DHU_NUM'))

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If (cAliasTemp)->(Eof())
        If lDelete
            Help(" ",1,"PG020NOTANSWERED",,STR0011,1,0) //-- Não é possível remover os itens desta cotação pois não há itens respondidos pelos fornecedores.
        EndIf
        lRet := .F.
    EndIf

    (cAliasTemp)->(dbCloseArea())

    oQuery:Destroy()
Return lRet

/*/{Protheus.doc} ValidTpPla
	Valida tipo de planilha.
@author juan.felipe
@since 08/08/2023
@return lRet, logical, planilha válida.
/*/
Static Function ValidTpPla()
    Local lRet As Logical
    Local cTpPla As Character
    Local lCallPGCA := FwIsInCallStack("PGCA010") 
    
    lRet := .T.
    cTpPla := SuperGetMV("MV_TPPLA", .T., "")
    CNL->(DbSetOrder(1)) //-- CNL_FILIAL+CNL_CODIGO

    If !lCallPGCA
        C300VldFixo(.T., .T.) //-- Seta .T. para indicar ao CNTA300 que é uma chamada do PGC, e deve validar o tipo fixo
    EndIf

    If Empty(cTpPla)
        Help("", 1, "MV_TPPLA",, STR0017, 4, 1)	//-- "Parâmetro não Preenchido. É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
        lRet	:= .F.
    ElseIf CNL->(!DbSeek(xFilial("CNL") + cTpPla))
        Help("", 1, "PG020VLDPLAN",, STR0018, 4, 1) //-- "É necessário preencher o parâmetro MV_TPPLA com um Tipo de Planilha válido para a geração dos contratos"
        lRet	:= .F.
    Else
        If !lCallPGCA
            lRet := CNVldPlFixa(cTpPla) //-- Validar o tipo de planilha (necessariamente precisa ser Fixa)
        EndIf
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PG020SetCtr
    Função para atribuir contratos para a variável estática _oJsonPGC para geração dos documentos.
@author juan.felipe
@since 08/08/2023
@param lPGC, logical, Indica se a chamada da rotina é realizada pelo PGC.
@param oJson, Object, Json de contratos, estrutura esperada: { "contractgenerationtype": "1", "contracts":  [  { "cn9_condpg": "001", "cn9_tpcto": "001" } ] }
@return Nil
/*/
//-------------------------------------------------------------------
Function PG020SetCtr(oJson)
    _oJsonCtr := oJson
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PG020GetCtr
    Obtém Json com os contratos para geração dos documentos.
@author juan.felipe
@since 08/08/2023
@version 1.0
@return _oJsonCtr, object, Json com os contratos
/*/
//-------------------------------------------------------------------
Function PG020GetCtr()
Return _oJsonCtr
