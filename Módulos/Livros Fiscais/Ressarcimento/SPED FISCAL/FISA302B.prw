#include "protheus.ch"
#include "FWMBROWSE.ch"
#include "FWMVCDEF.ch"
#include "fisa302b.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA302B()
Carga de estoque períodico.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Function FISA302B()
    Local oBrowse := Nil

    //Verifico se as tabelas existem antes de prosseguir
    If AliasIndic("CIL")
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("CIL")
        oBrowse:SetDescription(STR0002) //Cadastro dos Saldos Iniciais - Ressarcimento ICMS-ST
        oBrowse:SetFilterDefault("CIL_FILIAL == " + ValToSql(xFilial("CIL")))
        oBrowse:Activate()
    Else
        Help("", 1, "Help", "Help", STR0001, 1, 0) //Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias.
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina Title STR0018 Action 'VIEWDEF.FISA302B' OPERATION 2 ACCESS 0 // 'Visualizar'
    ADD OPTION aRotina Title STR0019 Action 'VIEWDEF.FISA302B' OPERATION 3 ACCESS 0 // 'Incluir'
    ADD OPTION aRotina Title STR0020 Action 'VIEWDEF.FISA302B' OPERATION 4 ACCESS 0 // 'Alterar'
    ADD OPTION aRotina Title STR0014 Action 'F302BConEx()'     OPERATION 5 ACCESS 0 // 'Excluir'
    ADD OPTION aRotina Title STR0017 Action 'F302BExLot()'     OPERATION 5 ACCESS 0 // 'Excluir em Lote'
    ADD OPTION aRotina Title STR0008 Action 'F302BProc()'      OPERATION 3 ACCESS 0 // 'Carregar Saldos Períodicos'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Função que criará o modelo do cadastro de saldo períodico com a tabela CIL

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oModel := Nil
    Local oCabecalho := FWFormStruct(1, "CIL")

    //Instanciando o modelo
    oModel := MPFormModel():New('FISA302B', {|oModel| VldApur(oModel)}, {|oModel| Validacao(oModel) .And. VldApur(oModel)})

    //Atribuindo estruturas para o modelo
    oModel:AddFields("FISA302B",, oCabecalho)

    //Inicializa o campo CIL_TPREG com o conteúdo igual a 2 - Saldo Inicial - Manual.
    oCabecalho:SetProperty('CIL_TPREG', MODEL_FIELD_INIT, {||"2"})

    //Validação do campo CIL_PRODUT para garantir que o produto atende a regra de preenchimento.
    oCabecalho:SetProperty('CIL_PRODUT', MODEL_FIELD_VALID, {|| VldProd(oModel)})

    //Validação do campo CIL_PERIOD para garantir que seja uma informação válida.
    oCabecalho:SetProperty('CIL_PERIOD', MODEL_FIELD_VALID, {|| VldAnoMes(oModel)})

    //Habilita o campo CIL_PERIOD apenas na inclusão.
    oCabecalho:SetProperty('CIL_PERIOD', MODEL_FIELD_WHEN, {|| oModel:GetOperation() == 3})

    //Habilita o campo CIL_PRODUT apenas na inclusão.
    oCabecalho:SetProperty('CIL_PRODUT', MODEL_FIELD_WHEN, {|| oModel:GetOperation() == 3})

    oModel:SetPrimaryKey({"CIL_FILIAL", "CIL_PERIOD", "CIL_PRODUT"})

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0002) //Cadastro dos Saldos Períodicos - Ressarcimento ICMS-ST

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Funcao generica MVC da View

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel := FWLoadModel("FISA302B")
    Local oCabecalho := FWFormStruct(2, "CIL")
    Local oView      := Nil
    Local cVersao    := GetVersao(.F.)

    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Ajuste do Título do campo CIL_DESPRO.
    oCabecalho:SetProperty("CIL_DESPRO", MVC_VIEW_TITULO, STR0022)  //"Descrição do Produto"

            //Ajuste do Título do campo CIL_TICM.
    oCabecalho:SetProperty("CIL_TICM", MVC_VIEW_TITULO, STR0023)  //"Valor Total Inicial do ICMS Próprio"

    //Ajuste do Título do campo CIL_TFICM.
    oCabecalho:SetProperty("CIL_TFICM", MVC_VIEW_TITULO, STR0024)  //"Valor Total Final do ICMS Próprio"

    //Ajuste do Título do campo CIL_TUST.
    oCabecalho:SetProperty("CIL_TUST", MVC_VIEW_TITULO, STR0025)  //"Valor Total Inicial do ICMS ST"

    //Ajuste do Título do campo CIL_TFST.
    oCabecalho:SetProperty("CIL_TFST", MVC_VIEW_TITULO, STR0026)  //"Valor Total Final do ICMS ST"

    //Ajuste do Título do campo CIL_TIFC.
    oCabecalho:SetProperty("CIL_TIFC", MVC_VIEW_TITULO, STR0027)  //"Valor Total Inicial do FECP"

    //Ajuste do Título do campo CIL_TFFC.
    oCabecalho:SetProperty("CIL_TFFC", MVC_VIEW_TITULO, STR0028)  //"Valor Total Final do FECP"

    //Ajuste do Título do campo CIL_MICM.
    oCabecalho:SetProperty("CIL_MICM", MVC_VIEW_TITULO, STR0029)  //"Valor Unitário Inicial de ICMS Próprio"

    //Ajuste do Título do campo CIL_MFICM.
    oCabecalho:SetProperty("CIL_MFICM", MVC_VIEW_TITULO, STR0030)  //"Valor Unitário Final de ICMS Próprio"

    //Ajuste do Título do campo CIL_MUST.
    oCabecalho:SetProperty("CIL_MUST", MVC_VIEW_TITULO, STR0031)  //"Valor Unitário Inicial de ICMS ST"

    //Ajuste do Título do campo CIL_MFST.
    oCabecalho:SetProperty("CIL_MFST", MVC_VIEW_TITULO, STR0032)  //"Valor Unitário Final de ICMS ST"

    //Ajuste do Título do campo CIL_MIFC.
    oCabecalho:SetProperty("CIL_MIFC", MVC_VIEW_TITULO, STR0033)  //"Valor Unitário Inicial de FECP"

    //Ajuste do Título do campo CIL_MFFC.
    oCabecalho:SetProperty("CIL_MFFC", MVC_VIEW_TITULO, STR0034)  //"Valor Unitário Final de FECP"

    //Ajuste do Título do campo CIL_TPREG.
    oCabecalho:SetProperty("CIL_TPREG", MVC_VIEW_TITULO, STR0035)  //"Tipo de Registro"

    //Ajuste do Título do campo CIL_MUBCST.
    oCabecalho:SetProperty("CIL_MUBCST", MVC_VIEW_TITULO, STR0036)  //"Valor Unitário Inicial da BC ICMS ST"

    //Ajuste do Título do campo CIL_MFBCST.
    oCabecalho:SetProperty("CIL_MFBCST", MVC_VIEW_TITULO, STR0037)  //"Valor Unitário Final da BC ICMS ST"

    //Ajuste do Título do campo CIL_TIBCST.
    oCabecalho:SetProperty("CIL_TIBCST", MVC_VIEW_TITULO, STR0038)  //"Valor Total Inicial BC ICMS ST"

    //Ajuste do Título do campo CIL_MUBCST.
    oCabecalho:SetProperty("CIL_TFBCST", MVC_VIEW_TITULO, STR0039)  //"Valor Total Final da BC ICMS ST"

    //Remove campo de ID
    oCabecalho:RemoveField('CIL_IDAPUR') 
    
    //Remove campo SPED
    oCabecalho:RemoveField('CIL_SPED')    

    
    

    //Atribuindo formulários para interface
    oView:AddField('VIEW_CABECALHO', oCabecalho, 'FISA302B')

    //Criando um container com tela de 100%
    oView:CreateHorizontalBox('SUPERIOR', 100)

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView('VIEW_CABECALHO', 'SUPERIOR')

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_CABECALHO', STR0002) //Cadastro dos Saldos Perí­dodicos - Ressarcimento ICMS-ST.

    If cVersao == '12'
        oView:SetViewProperty("*", "ENABLENEWGRID")
        oView:SetViewProperty("*", "GRIDNOORDER")
    EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}Validacao
Funcao generica de validação do cadastro

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function Validacao(oModel)
    Local nOperation := oModel:GetOperation()
    Local lRet       := .T.
    Local nQtde      := oModel:GetValue ('FISA302B', "CIL_QTDSLD")
    Local nValUni    := oModel:GetValue ('FISA302B', "CIL_MICM"  )
    Local nValTot    := oModel:GetValue ('FISA302B', "CIL_TICM"  )
    Local nValUST    := oModel:GetValue ('FISA302B', "CIL_MUST"  )
    Local nValTST    := oModel:GetValue ('FISA302B', "CIL_TUST"  )
    Local nValUFP    := oModel:GetValue ('FISA302B', "CIL_MIFC"  )
    Local nValTFP    := oModel:GetValue ('FISA302B', "CIL_TIFC"  )
    Local cMesAno    := oModel:GetValue ('FISA302B', "CIL_PERIOD")
    Local cProduto   := oModel:GetValue ('FISA302B', "CIL_PRODUT")
    Local cTpReg     := oModel:GetValue ('FISA302B', "CIL_TPREG" )

    If nOperation == MODEL_OPERATION_INSERT
        CIL->(dbSetOrder(1))
        If CIL->(dbSeek(xFilial("CIL")+cMesAno+cProduto))
            lRet := .F.
            Help(,, 'Help',, STR0003, 1, 0) //Ano/Mês e Produto já estão cadastrados.
        EndIf
    EndIf

    If cTpReg != '1'
        If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
            If Round(nQtde*nValUni,FWSX3Util():GetFieldStruct("CIL_TICM")[4]) != nValTot
                lRet := .F.
                Help(,, 'Help',, STR0004, 1, 0) //Valor informado do total do saldo de ICMS Próprio inválido.
            EndIf
            If Round(nQtde*nValUST,FWSX3Util():GetFieldStruct("CIL_TUST")[4]) != nValTST
                lRet := .F.
                Help(,, 'Help',, STR0040, 1, 0) //Valor informado do total do saldo de ICMS ST inválido.
            EndIf
            If Round(nQtde*nValUFP,FWSX3Util():GetFieldStruct("CIL_TIFC")[4]) != nValTFP
                lRet := .F.
                Help(,, 'Help',, STR0041, 1, 0) //Valor informado do total do saldo de FECP inválido.
            EndIf
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}VldProd
Funcao generica de validação do produto

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function VldProd(oModel)
    Local nOperation := oModel:GetOperation()
    Local lRet       := .T.
    Local cProduto   := oModel:GetValue ('FISA302B', "CIL_PRODUT")
    Local cTpReg     := oModel:GetValue ('FISA302B', "CIL_TPREG" )

    If cTpReg == '2'
        If nOperation == MODEL_OPERATION_INSERT
            lRet := ExistCpo("SB1", cProduto)

            If lRet
                SB1->(dbSetOrder(1))
                SB1->(dbSeek(xFilial("SB1")+cProduto, .F.))
                If SB1->B1_CRICMS != '1'
                    lRet := .F.
                    Help(,, 'Help',, STR0005, 1, 0) //Produto não pode ser utilizado devido ao campo Art. 271 estar diferente de Sim.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}VldAnoMes
Funcao generica de validação do produto

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function VldAnoMes(oModel)
    Local nOperation := oModel:GetOperation()
    Local cMesAno    := oModel:GetValue ('FISA302B', "CIL_PERIOD")
    Local lRet       := .T.    

    If nOperation == MODEL_OPERATION_INSERT

        If Empty(StoD(cMesAno+'01'))
            lRet := .F.
            Help(,, 'Help',, STR0006, 1, 0) //Informe um Ano/Mês válido.
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}VldApur
Função para validar se existe apuração para permitir alteração/gravar as informações de saldo de estoque e financeiro.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function VldApur(oModel)
    Local lRet       := .T.
    Local nOperation := oModel:GetOperation()
    Local cTpReg     := oModel:GetValue ('FISA302B', "CIL_TPREG")

    If nOperation == MODEL_OPERATION_UPDATE

        If cTpReg != "2"
            lRet := .F.
            Help(,, 'Help',, STR0007, 1, 0) //Apenas registro do tipo 2 - Saldo Períodico Manual pode sofrer alteração.
        EndIf

    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}F302BProc
Funcao generica para processamento do saldo inicial dos produtos

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Function F302BProc()
    Local dDtFecham := CtoD("")

    If Pergunte("FISA302B",.T.)
        dDtFecham := MV_PAR01        
        FwMsgRun(, {|oSay| SelSalIni(oSay, dDtFecham)}, STR0008, "") //Carregar Saldos Períodicos        
    EndIf

    MsgInfo(STR0009, STR0008) //Processamento concluído, Carregar Saldos Períodicos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}SelSalIni
Funcao generica para selecionar e gravar o saldo inicial dos produtos

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function SelSalIni(oSay, dDtFecham)
    Local cAliasEst	 := ''
    Local cProduto   := ''
    Local nVUnitOP   := 0
    Local nVlrTot    := 0
    Local nBaseTot   := 0
    Local nStTot     := 0
    Local nFECPTot   := 0
    Local cMesAno    := ""
    Local aDadosSld  := {}
    Local oMovEnProt := Nil
    Local oModel     := FWLoadModel('FISA302B')
    Local cMVESTADO  := SuperGetMV('MV_ESTADO',.F.,'')
    Local nMVICMPAD  := SuperGetMV('MV_ICMPAD')
    Local nAliqInt   := 0
    Local nVUnitBSST := 0
    Local nVUnitST   := 0
    Local nVUnitFCP  := 0

    AtualizaMsg(oSay, STR0010) //Selecionando registros de saldos períodicos

    SPDBlocH(@cAliasEst, '', dDtFecham)

    If Empty(cAliasEst)
        Help(,, 'Help',, STR0011, 1, 0) //Nenhum registro foi encontrado com a data de fechamento informada. Verifique a data de fechamento.
        Return
    Endif

    cMesAno := SubStr(DtoS(LastDay(dDtFecham) + 1), 1, 6)

    dbSelectArea(cAliasEst)
    (cAliasEst)->(dbGoTop())

    While !(cAliasEst)->(Eof())

        cProduto := (cAliasEst)->COD_ITEM

        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")+cProduto))

        If SB1->B1_CRICMS != '1'
            (cAliasEst)->(dbSkip())
            Loop
        EndIf

        //---Define a alíquota interna do ICMS para o produto---//
        nAliqInt := Iif(SB1->B1_PICM>0, SB1->B1_PICM, nMVICMPAD)

        nQtde := (cAliasEst)->QTD

        aDadosSld := {}

        //Calcula o saldo financeiro dos movimentos de entrada de acordo com a quantidade de estoque na data do fechamento informado.
        //Exemplo, Se a quantidade em estoque do produto for de 10, irá buscar o saldo financeiro nos movimentos de entrada enquanto a
        // quantidade do movimento for menor que 10.
        oMovEnProt := FISA302MOVIMENTOENTPROTHEUS():New()
        oMovEnProt:cTipoRet := 'C'
        oMovEnProt:cUF      := cMVESTADO        
        oMovEnProt:cCodProd := cProduto
        oMovEnProt:nQtdade  := nQtde
        oMovEnProt:dDataMov := dDtFecham
        oMovEnProt:nAliqInt := nAliqInt
        oMovEnProt:DefICMSEnt()

        nVlrTot   := oMovEnProt:nVlrICMSOP
        aDadosSld := oMovEnProt:aSldVlrDet
        nBaseTot  := oMovEnProt:nVlrBSST
        nStTot    := oMovEnProt:nVlrICMSST
        nFECPTot  := oMovEnProt:nVlrFECP

        //Caso retorne zero significa que não possui quantidade suficiente para compor o saldo financeiro, sendo assim o produto é desconsiderado.
        If nVlrTot <= 0 .Or. nBaseTot <= 0 .Or. nStTot < 0
            (cAliasEst)->(dbSkip())
            Loop
        EndIf

        nVUnitOP   := Round(nVlrTot/nQtde, 6)
        nVUnitBSST := Round(nBaseTot/nQtde, 6)
        nVUnitST   := Round(nStTot/nQtde, 6)
        nVUnitFCP  := Round(nFECPTot/nQtde, 6)

        //Grava as informações nas tabelas CIL e CII.
        GrvSaldo(cMesAno, cProduto, nQtde, nVUnitOP,nVlrTot, nVUnitBSST,nBaseTot, nVUnitST, nStTot, nVUnitFCP,nFECPTot, aDadosSld, oModel)

        (cAliasEst)->(dbSkip())

    EndDo

    (cAliasEst)->(dbCloseArea())
    Ferase(cAliasEst+GetDBExtension())

    AtualizaMsg(oSay, STR0011) //Nenhum registro foi encontrado com a data de fechamento informada. Verifique a data de fechamento.

    oModel:Destroy()
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}GrvSaldo
Função para gravar as informações de saldo de estoque e financeiro.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function GrvSaldo(cMesAno, cProduto, nQtde, nVUnitOP,nVlrTot, nVUnitBSST,nBaseTot, nVUnitST, nStTot, nVUnitFCP,nFECPTot, aDadosSld, oModel)
    Local nPos   := 0
    Local aArea  := GetArea()
    Local cOrdem := "000000001"
    Local oSubCIL
    
    oModel:SetOperation(3) //Inclusão    

    oModel:Activate()

    oSubCIL := oModel:GetModel("FISA302B")

    oSubCIL:SetValue("CIL_PERIOD", cMesAno   )
    oSubCIL:SetValue("CIL_TPREG ", "1"       )
    oSubCIL:SetValue("CIL_PRODUT", cProduto  )
    oSubCIL:SetValue("CIL_QTDSLD", nQtde     )
    oSubCIL:SetValue("CIL_MICM"  , nVUnitOP  )
    oSubCIL:SetValue("CIL_TICM"  , nVlrTot   )
    oSubCIL:SetValue("CIL_MUBCST", nVUnitBSST)
    oSubCIL:SetValue("CIL_TIBCST", nBaseTot  )
    oSubCIL:SetValue("CIL_MUST"  , nVUnitST  )
    oSubCIL:SetValue("CIL_TUST"  , nStTot    )
    oSubCIL:SetValue("CIL_MIFC"  , nVUnitFCP )
    oSubCIL:SetValue("CIL_TIFC"  , nFECPTot  )
    oSubCIL:SetValue("CIL_MFICM" ,          0)
    oSubCIL:SetValue("CIL_MFST"  ,          0)
    oSubCIL:SetValue("CIL_MFFC"  ,          0)
    oSubCIL:SetValue("CIL_MFBCST",          0)
    oSubCIL:SetValue("CIL_QTDFIM",          0)    
    oSubCIL:SetValue("CIL_TFST"  ,          0)
    oSubCIL:SetValue("CIL_TFICM" ,          0)
    oSubCIL:SetValue("CIL_TFBCST",          0)
    oSubCIL:SetValue("CIL_TFFC"  ,          0)
    

    If oModel:VldData()

        Begin Transaction
        For nPos := 1 to Len(aDadosSld)
            
            RecLock("CII",.T.)
            
            CII->CII_FILIAL := xFilial("CII")
            CII->CII_PERIOD := cMesAno
            CII->CII_NFISCA := aDadosSld[nPos,  1]
            CII->CII_SERIE  := aDadosSld[nPos,  2]
            CII->CII_PARTIC := aDadosSld[nPos,  3]
            CII->CII_LOJA   := aDadosSld[nPos,  4]
            CII->CII_ITEM   := aDadosSld[nPos,  5]
            CII->CII_PRODUT := aDadosSld[nPos,  6]
            CII->CII_CFOP   := aDadosSld[nPos,  7]
            CII->CII_CST    := aDadosSld[nPos,  8]
            CII->CII_QTDMOV := aDadosSld[nPos,  9]
            CII->CII_VUNIT  := aDadosSld[nPos, 10]
            CII->CII_ICMEFE := aDadosSld[nPos, 11]
            CII->CII_BURET  := aDadosSld[nPos, 12]
            CII->CII_VURET  := aDadosSld[nPos, 13]
            CII->CII_VURFCP := aDadosSld[nPos, 14]
            CII->CII_QTDSLD := aDadosSld[nPos, 15]
            CII->CII_MUCRED := aDadosSld[nPos, 16]
            CII->CII_MUBST  := aDadosSld[nPos, 17]
            CII->CII_MUVSTF := aDadosSld[nPos, 18]
            CII->CII_MUVSF  := aDadosSld[nPos, 19]
            CII->CII_CODRES := aDadosSld[nPos, 20]
            CII->CII_TPREG  := "1"
            CII->CII_TPMOV  :=  aDadosSld[nPos, 21]
            CII->CII_ORDEM  := cOrdem
            MsUnLock()

            cOrdem := Soma1(cOrdem)

        Next nPos

        oModel:CommitData()
        End Transaction

    Endif

    oModel:DeActivate()

    RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}F302BConEx
Função para exibir a tela e confirmar a exclusão do registro.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Function F302BConEx()
    Local lRet := Iif(CIL->CIL_TPREG == "3", VldExcl (CIL->CIL_PRODUT, CIL->CIL_FILIAL), .T.)

    If CIL->CIL_TPREG == "3" .And. !lRet
        Help(,, 'Help',, STR0013, 1, 0) //O tipo de registro 3 - Saldo da Apuraçãoo não pode ser excluído.
    Else
        FWExecView(STR0014, "FISA302B", MODEL_OPERATION_DELETE,,, {|| ExcTabApur()},,) //Excluir
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ExcTabApur
Função para deletar as informações de saldo de estoque e financeiro.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function ExcTabApur()
    Local cChave := xFilial("CII")+CIL->CIL_PERIOD + CIL->CIL_PRODUT
    Local lRet   := .T.

    Begin Transaction
    CII->(dbSetOrder(4))
    If CII->(dbSeek(cChave))
        While !CII->(EOF()) .And. CII->CII_FILIAL+CII->CII_PERIOD+CII->CII_PRODUT = cChave
            If CII->CII_TPREG == "1"
                RecLock("CII", .F.)
                CII->(dbDelete())
                MsUnLock()
            EndIf

            CII->(dbSkip())
        EndDo
    EndIf

    RecLock("CIL", .F.)
    CIL->(dbDelete())
    MsUnLock()
    End Transaction

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc}AtualizaMsg
Função que será chamada para atualizar descrição da barra de status

@author pereira.weslley

@since 05/11/2019
@version P01*/
//------------------------------------------------------------------
Static Function AtualizaMsg(oSay, cMsg)

    oSay:cCaption := (cMsg)
    ProcessMessages()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}F302BExLot
Função para deletar as informações de saldo de estoque e financeiro.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Function F302BExLot()
    Local cMesAno := ""
    Local lManual := .F. //Indica se fará exclusão dos saldos cadastrados manualmente.

    If Pergunte("FISA302BE", .T.)
        cMesAno := MV_PAR01
        lManual := Iif(MV_PAR02 == 1, .T., .F.)

        FwMsgRun(, {|oSay| ExcTabLote(oSay, cMesAno, lManual)}, STR0015, "") //Exclusão em Lote
    Else
        Return
    EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc}ExcTabApur
Função para deletar as informações de saldo em lote.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function ExcTabLote(oSay, cMesAno, lManual)
    Local lAchou   := .F.
    Local lPermExc := .F.
    AtualizaMsg(oSay, STR0021) //Selecionando os registros para exclusão

    Begin Transaction
    CII->(dbSetOrder(4))
    CII->(dbSeek(xFilial("CII")+cMesAno))

    While !CII->(EOF()) .And. CII->CII_FILIAL+CII->CII_PERIOD = xFilial("CII")+cMesAno
        If CII->CII_TPREG == "1"
            RecLock("CII", .F.)
            CII->(dbDelete())
            MsUnLock()
        EndIf

        CII->(dbSkip())
    EndDo

    CIL->(dbSetOrder(1))
    CIL->(dbSeek(xFilial("CIL")+cMesAno))

    While !CIL->(EOF()) .And. CIL->CIL_FILIAL+CIL->CIL_PERIOD = xFilial("CIL")+cMesAno

        lPermExc := Iif(CIL->CIL_TPREG == "3", VldExcl(CIL->CIL_PRODUT, CIL->CIL_FILIAL), .F.) //Validação para permitir exclusão dos registros com saldo 0 criados na primeira apuração 

        If CIL->CIL_TPREG == "1" .Or. (lManual .And. CIL->CIL_TPREG == "2") .Or. (CIL->CIL_TPREG == "3" .And. lPermExc)
            lAchou := .T.

            RecLock("CIL", .F.)
            CIL->(dbDelete())
            MsUnLock()
        EndIf

        CIL->(dbSkip())
    EndDo
    End Transaction

    If lAchou
        MsgInfo(STR0009, STR0012) //Processamento Concluído, Exclusão em Lote
    Else
        MsgInfo(STR0016, STR0012) //Nenhum registro do Tipo 1 - Carga Automática foi encontrado para o Ano/Mês informado, Exclusão em Lote
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}VldExcl
Função para deletar as informações de saldo em lote.

@author pereira.weslley

@since 05/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function VldExcl(cProduto, cFilExcl)
    Local cAliasExc := GetNextAlias()
    Local lRet      := .F.

    BeginSql Alias cAliasExc
        SELECT COUNT(CIL.CIL_PRODUT) CNT
        FROM %Table:CIL% CIL
        WHERE CIL.CIL_FILIAL = %Exp:cFilExcl% AND
              CIL.CIL_PRODUT = %Exp:cProduto% AND
              CIL.%NotDel%
    EndSql

    DbSelectArea(cAliasExc)

    lRet := Iif((cAliasExc)->CNT > 1, .F., .T.)

Return lRet
