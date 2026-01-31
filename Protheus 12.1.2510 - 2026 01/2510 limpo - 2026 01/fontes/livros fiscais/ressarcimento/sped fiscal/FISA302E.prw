#Include "fisa302e.ch"
#include "protheus.ch"
#include "fwbrowse.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc}FISA302E()
Cadastro de regras por CFOP e CST

@author pereira.weslley

@since 06/11/2019
@version P01*/
//-------------------------------------------------------------------
Function FISA302E()
    Local oBrowse := Nil

    //Verifico se as tabelas existem antes de prosseguir
    If AliasIndic("CIJ") .And. AliasIndic("CIK")
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("CIJ")
        oBrowse:SetDescription("") //Cadastro de Regras - Ressarcimento ICMS-ST
        oBrowse:SetFilterDefault("CIJ_FILIAL == " + ValToSql(xFilial("CIJ")))
        oBrowse:Activate()
    Else
        Help("", 1, "Help", "Help", STR0001, 1, 0) //Dicionário de dados desatualizado. Favor aplicar as atualizações necessárias."
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar o menu

@author pereira.weslley

@since 06/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu("FISA302E")

//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Função que criará o modelo do cadastro de regras por CFOP e CST com a tabela CIJ e CIK

@author pereira.weslley

@since 06/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function ModelDef()
    Local oCabecalho := FWFormStruct(1, "CIJ")
    Local cIdTab     := FWUUID("CIJ")
    Local oModel     := Nil
    Local oCST       := FWFormStruct(1, "CIK")

    //Instanciando o modelo
    oModel := MPFormModel():New('FISA302E') 

    //Atribuindo estruturas para o modelo
    oModel:AddFields("FISA302E",, oCabecalho)

    //Adicionando o grid de CST
    oModel:AddGrid('FIS302CCST', 'FISA302E', oCST)
    oModel:GetModel('FIS302CCST'):SetUseOldGrid()

    //Inicializa o campo CIJ_IDTAB com o ID.
    oCabecalho:SetProperty('CIJ_IDTAB', MODEL_FIELD_INIT, {|| cIdTab})

    //Inicializa o campo CIK_IDTAB com o ID.
    oCST:SetProperty('CIK_IDTAB', MODEL_FIELD_INIT, {|| cIdTab})

    //Relacionamento entre as tabelas CIJ Regras com CIK Detalhe da Regra
    oModel:SetRelation('FIS302CCST', {{'CIK_FILIAL', 'xFilial("CIK")'}, {'CIK_IDTAB', 'CIJ_IDTAB'}}, CIK->(IndexKey(1)))

    //Define para não repetir o código de produto
    oModel:GetModel('FIS302CCST'):SetUniqueLine({'CIK_CSTICM'})

    //Adicionando descrição ao modelo
    oModel:SetDescription(STR0002) //Cadastro de Regras - Ressarcimento ICMS-ST

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Funcao generica MVC da View

@author pereira.weslley

@since 06/11/2019
@version P01*/
//-------------------------------------------------------------------
Static Function ViewDef()
    Local oCabecalho := FWFormStruct(2, "CIJ")
    Local oCST       := FWFormStruct(2, "CIK")
    Local oView      := Nil
    Local cVersao    := GetVersao(.F.)
    Local oModel     := FWLoadModel("FISA302E")
    Local lCIJRessar := CIJ->(FieldPos("CIJ_RESSAR")) > 0

    oView := FWFormView():New()
    oView:SetModel(oModel)

    //Atribuindo formulários para interface
    oView:AddField('VIEW_CABECALHO', oCabecalho, 'FISA302E')
    oView:AddGrid('VIEW_CST'       , oCST      , 'FIS302CCST')

    //Retira os campos da View
    oCabecalho:RemoveField('CIJ_IDTAB')
    oCST:RemoveField('CIK_IDTAB')

    //Ajuste do Título do campo CIJ_FATGER.
    oCabecalho:SetProperty("CIJ_FATGER", MVC_VIEW_TITULO, STR0003) //Fato Gerador não Realizado
    If lCIJRessar
        oCabecalho:SetProperty("CIJ_RESSAR", MVC_VIEW_TITULO, STR0004) //Considera CFOP p/ Ressarcimento
    EndIf

    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox('SUPERIOR', 20)
    oView:CreateHorizontalBox('INFERIOR', 80)

    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView('VIEW_CABECALHO', 'SUPERIOR')
    oView:SetOwnerView('VIEW_CST'      , 'INFERIOR')

    //Colocando título do formulário
    oView:EnableTitleView('VIEW_CABECALHO', "CFOP")
    oView:EnableTitleView('VIEW_CST'      , "CST")

    If cVersao == '12'
        oView:SetViewProperty("*", "ENABLENEWGRID")
        oView:SetViewProperty("*", "GRIDNOORDER")
    EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}F302CCarga
Função responsável por realizar a carga inicial dos registros.

@author pereira.weslley

@since 06/11/2019
@version P01*/
//-------------------------------------------------------------------
Function F302CCarga()
    Local cCfop      := ""
    Local aCstTrib   := {"00", "10", "20", "60", "70"}
    Local aCst       := {"00", "10", "20", "30", "40", "41", "50", "51", "60", "70", "90"}
    Local aCstAux    := {}
    Local nX         := 1
    Local aArea      := GetArea()
    Local cAlias     := ""
    Local cIdTab     := ""
    Local cFatoNGer  := "5927"  
    Local cChave     := ""
    Local lCIJRessar := CIJ->(FieldPos("CIJ_RESSAR")) > 0

    cCfop := "1912/2912/1913/2913/1914/2914/1915/2915/1916/2916/5906/6906/5907/6907/5912/6912/5913/"
    cCfop += "6913/5914/6914/5915/6915/5916/6916/5414/6414/5415/6415/5904/6904"

    //Verifica se existe registro na tabela antes de realizar a carga inicial.
    CIJ->(dbSetOrder(1))
    If CIJ->(dbSeek(xFilial("CIJ")))
        Return
    EndIf

    cAlias := GetNextAlias()

    Begin Transaction

    BeginSql Alias cAlias
            
        SELECT  X5_CHAVE
        FROM 	%TABLE:SX5% SX5
        WHERE  SX5.X5_FILIAL=%XFILIAL:SX5%
        AND SX5.X5_TABELA = %EXP:"13"%
        AND SX5.%NOTDEL%
                
    EndSql

    While !(cAlias)->(EOF())
    
        cChave := AllTrim((cAlias)->X5_CHAVE)
        
        If Len(cChave) != 4
            (cAlias)->(dbSkip())
            Loop
        EndIf
        
        RecLock("CIJ",.T.)
        cIdTab := FWUUID("CIJ")

        CIJ->CIJ_FILIAL := xFilial("CIJ")
        CIJ->CIJ_IDTAB  := cIdTab
        CIJ->CIJ_CFOP   := cChave
        CIJ->CIJ_FATGER := "2"
        If lCIJRessar
            CIJ->CIJ_RESSAR := "1"
        EndIf
        MsUnLock()

        //Para os CFOP's contidos na variável cCfop será carregados apenas o código de CST com tributação de ICMS.
        If cChave $ cCfop
            aCstAux := aCstTrib
        Else
            aCstAux := aCst
        EndIf

        For nX := 1 To Len(aCstAux)

            RecLock("CIK",.T.)
            CIK->CIK_FILIAL := xFilial("CIK")
            CIK->CIK_CSTICM := aCstAux[nX]
            CIK->CIK_IDTAB  := cIdTab
            MsUnLock()
            
        Next

        (cAlias)->(dbSkip())
    EndDo

    //Por se tratar de apenas 1 código realiza o update no final do processamento.
    CIJ->(dbSetOrder(2))
    If CIJ->(dbSeek(xFilial("CIJ") + cFatoNGer))
        RecLock("CIJ",.F.)
        CIJ->CIJ_FATGER := "1"
        MsUnLock()
    EndIf

    End Transaction

    (cAlias)->(dbCloseArea())

    RestArea(aArea)

Return
