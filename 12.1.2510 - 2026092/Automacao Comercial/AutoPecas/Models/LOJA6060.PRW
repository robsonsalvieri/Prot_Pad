#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA6060.ch"

/*/{Protheus.doc} LOJA6060
    Cadastro de Mod Veiculo Prod / Aplicação       
    @type    function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
/*/
Function LOJA6060()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('MF0')
    oBrowse:SetDescription(STR0001) //"Mod. Veículo Prod. / Aplicação"

    // If hasSmartX() //Proteção para garantir que o ambiente atende os pré-requisitos de uso do SmartX
    //     oBrowse:setSmartX() //Define uso de SmartX 
    // EndIf
    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Mod Veiculo Prod / Aplicação       
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Array,  Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA6060" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA6060" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA6060" Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA6060" Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006 Action "VIEWDEF.LOJA6060" Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Mod Veiculo Prod / Aplicação       
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Object,  Objeto de Model
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MF0')
    Local oModel  := MPFormModel():New('LOJA6060', /*Pre-Validacao*/, /*Pos-Validacao*/ { |oModel| Lj6060VlPs( oModel ) }, /*Commit*/, /*Cancel*/)

    oModel:SetDescription(STR0001) //"Mod Veiculo Prod / Aplicação"
    oModel:AddFields('MF0MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MF0_FILIAL', 'MF0_UIDMOD', 'MF0_FILPRO', 'MF0_CODPRO', 'MF0_CNJSIS'})//MF0_FILIAL+MF0_UIDMOD+MF0_FILPRO+MF0_CODPRO+MF0_CNJSIS 

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Mod Veiculo Prod / Aplicação       
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Object,  Objeto de View
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MF0')
    Local oModel  := FWLoadModel('LOJA6060')

    oView:SetDescription(STR0001) //"Mod Veiculo Prod / Aplicação"
    oView:SetModel(oModel)
    oView:AddField('MF0', oStruct, 'MF0MASTER')
    oView:EnableTitleView('MF0', STR0001) //"Mod Veiculo Prod / Aplicação"

Return oView

/*/{Protheus.doc} VldModel
    Validação do Model para o cadastro de Mod Veiculo Prod / Aplicação
    @type  Static Function
    @author eduardo.FLima
    @since 16/06/2026
    @version P12
    @param oModel, Object, Objeto de Model
    @return Logical, Resultado da validação
/*/
Static Function Lj6060VlPs(oModel)
    Local lRet      := .T. as Logical
    Local oModelMF0 := oModel:GetModel('MF0MASTER') as Object
    Local nOper     := oModel:GetOperation() as Numeric
    Local cUidMod   := "" as Character
    Local cFilPro   := "" as Character
    Local cCodPro   := "" as Character
    Local cCnjSis   := "" as Character
    Local aArea     := GetArea() as Array
    Local nRecno    := 0 as Numeric

    If nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_UPDATE
        cUidMod := oModelMF0:GetValue('MF0_UIDMOD')
        cFilPro := oModelMF0:GetValue('MF0_FILPRO')
        cCodPro := oModelMF0:GetValue('MF0_CODPRO')
        cCnjSis := oModelMF0:GetValue('MF0_CNJSIS')

        nRecno := MF0->(Recno())// Guarda o record number atual para permitir encontrar o proprio registro no caso de alteracao

        MF0->(DbSetOrder(1)) //MF0_FILIAL+MF0_UIDMOD+MF0_FILPRO+MF0_CODPRO+MF0_CNJSIS                                                                                                          
        
        If MF0->(DbSeek(xFilial("MF0") + cUidMod + cFilPro + cCodPro + cCnjSis));
        .and. (nOper == MODEL_OPERATION_INSERT .or. MF0->(Recno()) != nRecno) // Se for alteracao, permite encontrar o proprio registro

            lRet := .F.
            Help(" ", 1, "Lj6060VlPs", , STR0007 , 1, 0; //"Já existe um registro para a aplicação com essas configurações de modelo de veículo, produto e conjunto de sistemas" 
            ,,,,,,{STR0008}) //"Verifique os dados informados"
        EndIf
    EndIf
    RestArea(aArea)
Return lRet


