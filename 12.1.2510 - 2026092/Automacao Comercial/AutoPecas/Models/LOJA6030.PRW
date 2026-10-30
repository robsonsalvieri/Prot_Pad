#include "Totvs.ch"
#include "FWMVCDef.ch"
#include "LOJA6030.ch"

/*/{Protheus.doc} LOJA6030
    Cadastro de Relacionados/Sugestao de Vendas       
    @type    function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
/*/
Function LOJA6030()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('MFZ')
    oBrowse:SetDescription(STR0001) //"Relacionados/Sugestao de Vendas"

    If hasSmartX() //Proteção para garantir que o ambiente atende os pré-requisitos de uso do SmartX
        oBrowse:setSmartX() //Define uso de SmartX 
    EndIf
    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Relacionados/Sugestao de Vendas       
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Array,  Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA6030" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA6030" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA6030" Operation 4 Access 0 //"Modificar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA6030" Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006 Action "VIEWDEF.LOJA6030" Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Relacionados/Sugestao de Vendas       
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Object,  Objeto de Model
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MFZ')
    Local oModel  := MPFormModel():New('LOJA6030', /*Pre-Validacao*/, /*Pos-Validacao*/ { |oModel| Lj6030VlPs( oModel ) }, /*Commit*/, /*Cancel*/)

    oModel:SetDescription(STR0001) //"Relacionados/Sugestao de Vendas"
    oModel:AddFields('MFZMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MFZ_FILIAL', 'MFZ_FILPRO', 'MFZ_CODPAI', 'MFZ_CODPRO'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Relacionados/Sugestao de Vendas       
    @type  Static Function
    @author  eduardo.FLima
    @since   09/06/2026
    @version P12
    @return  Object,  Objeto de View
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MFZ')
    Local oModel  := FWLoadModel('LOJA6030')

    oView:SetDescription(STR0001) //"Relacionados/Sugestao de Vendas"
    oView:SetModel(oModel)
    oView:AddField('MFZ', oStruct, 'MFZMASTER')
    oView:EnableTitleView('MFZ', STR0001) //"Relacionados/Sugestao de Vendas"

Return oView

/*/{Protheus.doc} VldModel
    Validação do Model para o cadastro de Relacionados/Sugestao de Vendas
    @type  Static Function
    @author eduardo.FLima
    @since 16/06/2026
    @version P12
    @param oModel, Object, Objeto de Model
    @return Logical, Resultado da validação
/*/
Static Function Lj6030VlPs(oModel)
    Local lRet      := .T. as Logical
    Local oModelMFZ := oModel:GetModel('MFZMASTER') as Object
    Local nOper     := oModel:GetOperation() as Numeric
    Local cFilPro   := "" as Character
    Local cCodPro   := "" as Character
    Local cCodPai   := "" as Character
    Local aArea     := GetArea() as Array
    Local aB1Area   :=SB1->(GetArea())
    If nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_UPDATE
        cFilPro := oModelMFZ:GetValue('MFZ_FILPRO')
        cCodPro := oModelMFZ:GetValue('MFZ_CODPRO')
        cCodPai := oModelMFZ:GetValue('MFZ_CODPAI')
        SB1->(DbSetOrder(1))
        lRet := SB1->(MsSeek( cFilPro + cCodPro ))
        IF !lRet
            Help(" ", 1, "Lj6030VlPs", , STR0007 + cCodPro + STR0008 + cFilPro, 1, 0; //"Produto " ### " não encontrado na filial "###
            ,,,,,,{STR0009}) //"Verifique os dados informados"
        Endif 
        if lRet
            lRet := SB1->(MsSeek( cFilPro + cCodPai ))
            IF !lRet
                Help(" ", 1, "Lj6030VlPs", , STR0007 + cCodPai + STR0008 + cFilPro, 1, 0; //"Produto " ### " não encontrado na filial "###
                ,,,,,,{STR0009}) //"Verifique os dados informados
            Endif
        Endif 
    Endif 
    RestArea(aB1Area)
    RestArea(aArea)
Return lRet


/*/{Protheus.doc} Lj6030VlPr
    Valida se o produto existe na filal informada no campo MFZ_FILPRO
    @type  Function
    @author eduardo.FLima
    @since 16/06/2026
    @version P12
    @return Logical, Resultado da validação
/*/
Function Lj6030VlPr()
    Local lReturn := .T. as Logical
    Local aArea     := GetArea() as Array
    Local aB1Area   :=SB1->(GetArea())
    Local cValue    := "" as Character
    cValue := &(ReadVar())
    cFilPro := M->MFZ_FILPRO
    SB1->(DbSetOrder(1))
    lReturn :=  SB1->(MsSeek( cFilPro + cValue ))
    IF !lReturn
        Help(" ", 1, "Lj6030VlPr", , STR0007 + cValue + STR0008 + cFilPro, 1, 0; //"Produto " ### " não encontrado na filial "###
        ,,,,,,{STR0009}) //"Verifique os dados informados"
    Endif
    RestArea(aB1Area)
    RestArea(aArea)
Return lReturn
