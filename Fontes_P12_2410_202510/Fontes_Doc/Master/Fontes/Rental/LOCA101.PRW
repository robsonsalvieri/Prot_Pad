//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOCA101.CH'
 
//Variáveis Estáticas
Static cTitulo := STR0001 // "Aprovação de Ordens de Serviço" 
 
/*/{Protheus.doc} LOCA089
Rotina que cadastra ITENS do check-list
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/
Function LOCA101()
Local oBrowse
Private aRotina := {}

    //Definicao do menu
    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("FH1")
    oBrowse:SetDescription(cTitulo)
    oBrowse:AddLegend( "FH1->FH1_STAPRO == '1'", "YELLOW", STR0002 ) //"Pendende de Aprovação"
    oBrowse:AddLegend( "FH1->FH1_STAPRO == '2'", "GREEN", STR0003 ) //"Aprovado"
    oBrowse:AddLegend( "FH1->FH1_STAPRO == '3'", "RED", STR0004 ) //"Reprovado"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function MenuDef()
Local aRotina := {}

    //Adicionando opcoes do menu
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.LOCA101' OPERATION 3 ACCESS 0 //"Incluir"
    //ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.LOCA101' OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0007 ACTION "LOCA101A(1)" OPERATION 4 ACCESS 0 //"Aprovar"
    ADD OPTION aRotina TITLE STR0008 ACTION "LOCA101A(2)" OPERATION 4 ACCESS 0 //"Rejeitar"
    ADD OPTION aRotina TITLE STR0009 ACTION 'MVC01Leg'     OPERATION 6  ACCESS 0 //"Legenda"
    ADD OPTION aRotina TITLE STR0010 ACTION 'LOCA101P'     OPERATION 4  ACCESS 0 //"Visualizar PC"
    ADD OPTION aRotina TITLE STR0011 ACTION 'LOCA101E'     OPERATION 4  ACCESS 0 //"Excluir PC"
    ADD OPTION aRotina TITLE STR0012 ACTION "VIEWDEF.LOCA101" OPERATION 1 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0013 ACTION "LOCA101B" OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Conhecimento"


Return aRotina    

/*/{Protheus.doc} ModelDef
Modelo de dados
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function ModelDef()

Local oModel      := NIL
Local oStruCab     := FWFormStruct(1, 'FH1', {|cCampo| AllTRim(cCampo) $ "FH1_ORDEM;"})
Local oStruGrid := fModStruct()
Local cProjeto := ""

    oModel := MPFormModel():New('LOCA101M', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*{|oModel| fValidGrid(oModel)}*/, /*bCancel*/ )

    oStruGrid:AddTrigger( "FH1_VLRUNI"   , "FH1_VLRTOT"   , {|| .T. }  , {|| fCalcGrid(oModel)} )
    oStruGrid:AddTrigger( "FH1_QUANTI"   , "FH1_VLRTOT"   , {|| .T. }  , {|| fCalcGrid(oModel)} )

    oModel:AddFields('MdFieldFH1', NIL, oStruCab)

    oModel:AddGrid('MdGridFH1', 'MdFieldFH1', oStruGrid, , )
  
    oModel:SetRelation('MdGridFH1', {;
            {'FH1_FILIAL', 'xFilial("FH1")'},;
            {"FH1_ORDEM",  "FH1_ORDEM"};
        }, FH1->(IndexKey(1)))

    oModel:GetModel('MdGridFH1'):SetUniqueLine({"FH1_CODIGO"})        
    cProjeto := Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_AS')
    oModel:GetModel("MdGridFH1"):SetMaxLine(9999)
    oModel:SetDescription("Cadastro Insumos " +cProjeto)
    oModel:SetPrimaryKey({"FH1_FILIAL", "FH1_ORDEM"})

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados
@author Dennis Calabrez
@since 04/09/2024
@version 1.0
/*/

Static Function ViewDef()
Local oView        := NIL
Local oModel    := FWLoadModel('LOCA101')
Local oStruCab  := FWFormStruct(2, "FH1", {|cCampo| AllTRim(cCampo) $ "FH1_ORDEM;"})
Local oStruGRID := fViewStruct()

    oStruCab:SetNoFolder()
  
    oView:= FWFormView():New() 
    oView:SetModel(oModel)              
  
    oView:AddField('VIEW_FH1', oStruCab, 'MdFieldFH1')
    oView:AddGrid ('GRID_FH1', oStruGRID, 'MdGridFH1' )
  
    oView:CreateHorizontalBox("MAIN", 25)
    oView:CreateHorizontalBox("GRID", 75)
  
    oView:SetOwnerView('VIEW_FH1', 'MAIN')
    oView:SetOwnerView('GRID_FH1', 'GRID')
    oView:EnableControlBar(.T.)
  
   //Ativando o campo de pesquisar e ativando o botão de Filtrar
    oView:SetViewProperty("GRID_FH1", "GRIDSEEK",    {.T.})
    oView:SetViewProperty("GRID_FH1", "GRIDFILTER",  {.T.})

    oView:AddIncrementField('GRID_FH1', 'FH1_SEQTAR')

Return oView

Static Function fModStruct()
Local oStruct
    oStruct := FWFormStruct(1, 'FH1')
Return oStruct
  
Static Function fViewStruct()
Local cCampoCom := "FH1_FILIAL;FH1_ORDEM;FH1_PLANO;FH1_TAREFA;FH1_SEQREL;FH1_STAPRO;FH1_CODAPR;FH1_DTAPRO;FH1_HRAPRO;FH1_DTENC;FH1_HRENC;FH1_CODFIN;FH1_DESFIN;FH1_CUSEX;FH1_OBSREJ"
Local oStruct
    oStruct := FWFormStruct(2, "FH1", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})
Return oStruct  


/*/{Protheus.doc} MVC01Leg
Função para mostrar a legenda das rotinas MVC com grupo de produtos
@author Dennis Calabrez
@since 16/06/2025
@version 1.0
/*/

Function MVC01Leg()
Local aLegenda := {}
	
	AADD(aLegenda,{"BR_VERDE", STR0003  }) //"Aprovado"
	AADD(aLegenda,{"BR_VERMELHO", STR0004}) //"Reprovado"
    AADD(aLegenda,{"BR_AMARELO", STR0002}) //"Pendende de Aprovação"
	
	BrwLegenda(STR0017, STR0018, aLegenda) //"Oderns de Serviço"###"Aprovação/Rejeição"
Return

/*/{Protheus.doc} LOCA101P
Função para Visualizar o Prdido de Compras
@author Dennis Calabrez
@since 16/06/2025
@version 1.0
/*/
Function LOCA101P()

    If FH1->FH1_STAPRO == '1' .OR. FH1->FH1_STAPRO == '3'
        FWAlertInfo(STR0019) //"Favor selecionar somente registros com status de Aprovado"
    EndIf     

    SC7->(DbSetOrder(1)) //Filial + Código + Loja
      
    If SC7->(DbSeek(FWxFilial('SC7') + FH1->FH1_PEDCOM))
        MATA121(,,2,,,,)
    EndIf

Return()

/*/{Protheus.doc} LOCA101E
Função para Exclui pedido de compras e retornar OS para aprovação
@author Dennis Calabrez
@since 30/06/2025
@version 1.0
/*/
Function LOCA101E()
Local lPrim    := .T.
Local aCabec   := {}
Local aLinha   := {}
Local aItens   := {}
Local cOS      := FH1->FH1_ORDEM
Local aAreaFH1 := FH1->(GetArea())
Local cPed     := ""

    FH1->(dbSetOrder(1))
    FH1->(dbSeek(xFilial("FH1")+cOS))
    While !FH1->(Eof()) .and. FH1->(FH1_FILIAL+FH1_ORDEM) == xFilial("FH1")+cOS
        If !empty(FH1->FH1_PEDCOM)
            cPed := FH1->FH1_PEDCOM
            Exit
        EndIF
        FH1->(dbSkip())
    EndDo
    If empty(cPed)
        Help( ,, "LOCA101",, STR0023, 1, 0,,,,,,{STR0030}) //"Inconsistênca nos dados."###"Não há pedido de compras para esta OS."
        FH1->(RestArea(aAreaFH1))
        Return .F.
    EndIf

    FH1->(RestArea(aAreaFH1))
    SC7->(DbSetOrder(1)) 
    SC7->(DbSeek(FWxFilial('SC7') + cPed))

    If MSGYESNO(STR0020+cPed+"?", STR0021) //"Deseja mesmo excluir o pedido de compras: "###"Exclusão de pedido de compras"
        While ! SC7->(EoF()) .and. SC7->(C7_FILIAL+C7_NUM) == FWxFilial('SC7') + cPed
            If lPrim
                aadd(aCabec,{"C7_NUM" ,SC7->C7_NUM})
                aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
                aadd(aCabec,{"C7_FORNECE" ,SC7->C7_FORNECE})
                aadd(aCabec,{"C7_LOJA" ,SC7->C7_LOJA})
                SA2->(DbSetOrder(1))
                SA2->(DbSeek(xFilial("SA2")+FH1->FH1_CODFOR+FH1->FH1_LOJFOR))//BUSCA A CONDIÇÃO DE PAGTO DO FORNECEDOR            
                aadd(aCabec,{"C7_COND" ,SA2->A2_COND})
                aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
                aadd(aCabec,{"C7_FILENT" ,cFilAnt})
                lPrim := .F.
            EndIf 
            aLinha := {}
            aadd(aLinha,{"C7_ITEM" ,SC7->C7_ITEM ,Nil})
            aadd(aLinha,{"C7_PRODUTO" ,SC7->C7_PRODUTO,Nil})
            aadd(aLinha,{"C7_QUANT" ,SC7->C7_QUANT ,Nil})
            aadd(aLinha,{"C7_PRECO" ,SC7->C7_PRECO ,Nil})
            aadd(aLinha,{"C7_TOTAL" ,SC7->C7_TOTAL ,Nil})
            aadd(aItens,aLinha)    

            SC7->(DbSkip())    

        EndDo
        MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCabec,aItens,5,.F.)

        SC7->(DbSetOrder(1)) 
        If SC7->(DbSeek(FWxFilial('SC7') + cPed))
            Help( ,, "LOCA101",, STR0023, 1, 0,,,,,,{STR0031}) //"Inconsistênca nos dados."###"Não foi possível excluir o pedido de compras"
            FH1->(RestArea(aAreaFH1))
            Return .F.
        EndIf

        FH1->(dbSetOrder(1))
        FH1->(dbSeek(xFilial("FH1")+cOS))

        While !FH1->(Eof()) .and. FH1->(FH1_FILIAL+FH1_ORDEM) == xFilial("FH1")+cOS
            RecLock("FH1", .F.)
            FH1->FH1_STAPRO := "1"
            FH1->FH1_DTAPRO := CTOD("")
            FH1->FH1_HRAPRO := ""
            FH1->FH1_VLRAUN := 0
            FH1->FH1_VLRATO := 0
            FH1->FH1_NOMAPR := ""
            FH1->FH1_CODAPR := ""
            FH1->FH1_PEDCOM := ""
            FH1->(MsUnlock())   
            FH1->(DbSkip()) 
        EndDo
        FWAlertSuccess(STR0016+cPed +STR0015, STR0014) //"Pedido de Compra "###" excluído com sucesso"###"Exclusão de Pedido"
    EndIf 

    FH1->(RestArea(aAreaFH1))
Return

Function LOCA101B()
    MpDocument("FH1",FH1->(RecNo()), 2)     
return (NIL)

Static Function fValidGrid(oModel)
Local lRet     := .T.
Local nLinAtual :=0
Local oModelGRID := oModel:GetModel('MdGridFH1')
Local oModelcab := oModel:GetModel('MdFieldFH1')
Local nPonteiro
Local cFornec
Local cLojFor
Local nX
Local nI
Local lErro := .F.
Local cErro := STR0022 //"Não pode haver fornecedores diferentes."
Local cOrdem
Local cPlano
Local cTarefa
Local cTipoReg
Local cCodigo
Local cSeqRela
Local cSeqTare

    nPonteiro := oModelGRID:GetLine()
    For nI := 1 to oModelGRID:Length()
        oModelGRID:GoLine(nI)
        If !oModelGRID:IsDeleted()
            cFornec := oModelGRID:GetValue("FH1_CODFOR")
            cLojFor := oModelGRID:GetValue("FH1_LOJFOR")
            For nX := 1 to oModelGRID:Length()
                If nX <> nI
                    oModelGRID:GoLine(nX)
                    If oModelGRID:GetValue("FH1_CODFOR") <> cFornec .or. oModelGRID:GetValue("FH1_LOJFOR") <> cLojFor
                        lErro := .T.
                    EndIF
                EndIf
            Next
        EndIf
    Next
    oModelGRID:GoLine(nPonteiro)
    If lErro
        Help( ,, "LOCA101",, STR0023, 1, 0,,,,,,{cErro}) //"Inconsistênca nos dados."
        Return .F.
    EndIf

    // Chave unica da STL
    //TL_FILIAL+TL_ORDEM+TL_PLANO+TL_TAREFA+TL_TIPOREG+TL_CODIGO+TL_SEQRELA+TL_SEQTARE
    nPonteiro := oModelGRID:GetLine()
    For nI := 1 to oModelGRID:Length()
        oModelGRID:GoLine(nI)
        If !oModelGRID:IsDeleted()
            cOrdem := oModelcab:GetValue("FH1_ORDEM")
            cPlano := "000000"
            cTarefa := "0     "
            cTipoReg := oModelGRID:GetValue("FH1_TIPORE")
            cCodigo := oModelGRID:GetValue("FH1_CODIGO")
            cSeqRela := "0  "
            cSeqTare := oModelGRID:GetValue("FH1_SEQTAR")
            STL->(dbSetOrder(1))
            If STL->(dbSeek(xFilial("STL")+cOrdem+cPlano+cTarefa+cTipoReg+cCodigo+cSeqRela+cSeqTare))
                lErro := .T.
                cErro := STR0024+alltrim(str(nI)) //"Registro já existente, linha: "
                Exit
            EndIf
        EndIF
    Next
    oModelGRID:GoLine(nPonteiro)

    If lErro
        Help( ,, "LOCA101",, STR0023, 1, 0,,,,,,{cErro}) //"Inconsistênca nos dados."
        Return .F.
    EndIf

    oModelGRID:GoLine(nLinAtual) 
          
    if oModel:GetOperation() == 3 
        If MSGYESNO(STR0025, STR0026) //"Deseja criar insumos na OS informada?"###"Insumos da ordem de serviço"
            For nLinAtual := 1 To oModelGRID:Length() 
                oModelGRID:GoLine(nLinAtual)
                STL->(RecLock("STL",.T.))
                STL->TL_FILIAL  := xFilial("STL")
                STL->TL_ORDEM   := oModelcab:GetValue("FH1_ORDEM")
                STL->TL_PLANO   := "000000"
                STL->TL_SEQRELA := "0"
                STL->TL_TAREFA  := "0"
                STL->TL_TIPOREG := oModelGRID:GetValue("FH1_TIPORE")//"P"
                STL->TL_CODIGO  := oModelGRID:GetValue("FH1_CODIGO")
                STL->TL_USACALE := "N"
                STL->TL_QUANTID :=  oModelGRID:GetValue("FH1_QUANTI")
                STL->TL_UNIDADE := Posicione("SB1",1,xFilial("SB1")+oModelGRID:GetValue("FH1_CODIGO"),"B1_UM")
                STL->TL_LOCAL := Posicione("SB1",1,xFilial("SB1")+oModelGRID:GetValue("FH1_CODIGO"),"B1_LOCPAD")
                STL->TL_CUSTO   := oModelGRID:GetValue("FH1_VLRUNI")
                STL->TL_DESTINO := "A"
                STL->TL_DTINICI := dDataBase
                STL->TL_HOINICI := Time()
                STL->TL_DTFIM   := dDataBase
                STL->TL_HOFIM   := Time()
                STL->TL_LOCAL   := "01"
                STL->TL_SEQTARE := oModelGRID:GetValue("FH1_SEQTAR")
                STL->(MsUnLocK())  
            Next nLinAtual      
        EndIf            
    EndIf
  
Return lRet

Static Function fCalcGrid(oModel)
Local oModelGRID := oModel:GetModel('MdGridFH1')
Local nTot := 0

    nTot := oModelGRID:GetValue("FH1_VLRUNI") * oModelGRID:GetValue("FH1_QUANTI")

Return(nTot)

Function LOCA101V(cOS)
Local lRet := .T.

    FH1->(DbSetOrder(1))
    If FH1->(DbSeek(xFilial("FH1")+cOS))
        FWAlertWarning(STR0027) //"Já existe cadastro para a Ordem de Serviço informada, utilizar outra O.S para nova inclusão"
        lRet := .F.
    EndIf

Return(lRet)

/*/{Protheus.doc} LOCA101X
Validação do campo loca do fornecedor
@type function
@author Frank Zwarg Fuga
@since 20/08/2025
/*/
Function LOCA101X
Local lRet := .T.
Local oModel := FWModelActive()
Local oStruGrid := oModel:GetModel("MdGridFH1")
Local cFornec := oStruGrid:GetValue("FH1_CODFOR")
Local cLoja := &(ReadVar())
Local aAreaSA2 := SA2->(GetArea())
Local nPonteiro
Local nI

    SA2->(dbSetOrder(1))
    If !SA2->(dbSeek(xFilial("SA2")+cFornec+cLoja))
        lRet := .F.
        cErro := STR0028 //"Fornecedor não localizado"
    EndIf

    If lRet
        nPonteiro := oStruGrid:GetLine()
        For nI := 1 to oStruGrid:Length()
            oStruGrid:GoLine(nI)
            If !oStruGrid:IsDeleted()
                If nI <> nPonteiro
                    If oStruGrid:GetValue("FH1_CODFOR") <> cFornec .or. oStruGrid:GetValue("FH1_LOJFOR") <> cLoja
                        lRet := .F.
                        cErro := STR0029 //"Não pode registrar fornecedores diferentes."
                        Exit
                    EndIF
                EndIF
            EndIF
        Next
        oStruGrid:GoLine(nPonteiro)
    EndIf

    If !lRet
        Help( ,, "LOCA101X",, STR0023, 1, 0,,,,,,{cErro}) //"Inconsistênca nos dados."
    EndIF

    SA2->(RestArea(aAreaSA2))
Return lRet
