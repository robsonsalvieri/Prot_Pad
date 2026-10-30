#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA6100.CH'

/*/{Protheus.doc} LOJA6100
    Manutencao de Limite de Credito por Forma de Pagamento
    @type    Function
    @author  Bruno Almeida
    @since   23/07/2026
    @version P12
    @return  Nil, Nulo
/*/
Function LOJA6100()
    Local oBrowse := FWMBrowse():New() as Object

    oBrowse:SetAlias('MGD')
    oBrowse:SetDescription(STR0001) //"Limite de Credito por Forma de Pagamento"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definicao do Model para a manutencao de Limite de Credito por Forma de Pagamento
    @type    Static Function
    @author  Bruno Almeida
    @since   23/07/2026
    @version P12
    @return  Object, Objeto de Model para a manutencao de Limite de Credito por Forma de Pagamento
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MGD') as Object
    Local oModel  := MPFormModel():New('LOJA6100', /*Pre-Validacao*/, {|oModel| Lj6100VlPs(oModel)}, /*Commit*/, /*Cancel*/) as Object

    oModel:SetDescription(STR0001) //"Limite de Credito por Forma de Pagamento"
    oModel:AddFields('MGDMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MGD_FILIAL', 'MGD_FORMA'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para a manutencao de Limite de Credito por Forma de Pagamento
    @type    Static Function
    @author  Bruno Almeida
    @since   23/07/2026
    @version P12
    @return  Object, Objeto de View para a manutencao de Limite de Credito por Forma de Pagamento
/*/
Static Function ViewDef()
    Local oView   as Object
    Local oStruct as Object
    Local oModel  as Object

    oView   := FWFormView():New()
    oStruct := FWFormStruct(2, 'MGD')
    oModel  := ModelDef()

    oStruct:RemoveField('MGD_FILIAL')

    oView:SetDescription(STR0001) //"Limite de Credito por Forma de Pagamento"
    oView:SetModel(oModel)
    oView:AddField('MGD', oStruct, 'MGDMASTER')

Return oView

/*/{Protheus.doc} MenuDef
    Definicao do Menu para a manutencao de Limite de Credito por Forma de Pagamento
    @type    Static Function
    @author  Bruno Almeida
    @since   23/07/2026
    @version P12
    @return  Array, Array com as opções do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA6100"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA6100"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA6100"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA6100"  Operation 5 Access 0 //"Excluir"

Return aRet

/*/{Protheus.doc} Lj6100VlPs
    Validacao pos do Model para a manutencao de Limite de Credito por Forma de Pagamento.
    Impede a inclusao ou alteracao de registro com Forma de Pagamento ja configurada.
    @type    Static Function
    @author  Bruno Almeida
    @since   23/07/2026
    @version P12
    @param   oModel, Object, Objeto de Model
    @return  Logical, .T. se valido, .F. caso contrario
/*/
Static Function Lj6100VlPs(oModel)
    Local lRet      := .T. as Logical
    Local oModelMGD := oModel:GetModel('MGDMASTER') as Object
    Local nOper     := oModel:GetOperation() as Numeric
    Local cForma    := "" as Character
    Local aArea     := GetArea() as Array
    Local nRecno    := 0 as Numeric

    If nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE
        cForma := oModelMGD:GetValue('MGD_FORMA')
        nRecno := MGD->(Recno())

        MGD->(DbSetOrder(1)) //MGD_FILIAL+MGD_FORMA

        If MGD->(DbSeek(xFilial('MGD') + cForma)) ;
        .And. (nOper == MODEL_OPERATION_INSERT .Or. MGD->(Recno()) != nRecno)
            lRet := .F.
            Help(" ", 1, "Lj6100VlPs", , STR0006, 1, 0 ;
            ,,,,,,{STR0007}) //"Já existe uma configuração para esta Forma de Pagamento." # "Verifique os dados informados."
        EndIf
    EndIf

    RestArea(aArea)
Return lRet
