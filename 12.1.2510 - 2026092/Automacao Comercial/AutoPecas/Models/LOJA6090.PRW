#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA6090.ch'

/*/{Protheus.doc} LOJA6090
    Cadastro de Eixo x Modelo Veículo de Auto Peças
    @type    Function
    @author  eduardo.Flima
    @since   06/07/2026
    @version P12
/*/
Function LOJA6090()
    Local oBrowse := FWMBrowse():New() as Object

    oBrowse:SetAlias('MFS')
    oBrowse:SetDescription(STR0001) //"Cadastro de Eixo x Modelo Veículo"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do Model para o cadastro de Eixo x Modelo Veículo
    @type    Function
    @author  eduardo.Flima
    @since   06/07/2026
    @version P12
    @return  Object, Objeto de Model para o cadastro de Eixo x Modelo Veículo
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MFS')
    Local oModel  := MPFormModel():New('LOJA6090', /*Pre-Validacao*/, /*Pos-Validacao*/ { |oModel| Lj6090VlPs( oModel ) }, /*Commit*/, /*Cancel*/)

    oModel:SetDescription(STR0001) //"Cadastro de Eixo x Modelo Veículo"
    oModel:AddFields('MFSMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MFS_FILIAL', 'MFS_FILEIX', 'MFS_CODEIX', 'MFS_MECUID'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View para o cadastro de Eixo x Modelo Veículo
    @type    Function
    @author  eduardo.Flima
    @since   06/07/2026
    @version P12
    @return  Object, Objeto de View para o cadastro de Eixo x Modelo Veículo
/*/
Static Function ViewDef()
    Local oView   as Object
    Local oStruct as Object
    Local oModel  as Object

    oView   := FWFormView():New()
    oStruct := FWFormStruct(2, 'MFS')
    oModel  := ModelDef()
 
    // Remove campos da estrutura que nao serao apresentados na tela
    oStruct:RemoveField('MFS_FILEIX')
    // oStruct:RemoveField('MFS_FILMOD')

    oView:SetDescription(STR0001) //"Cadastro de Eixo x Modelo Veículo"
    oView:SetModel(oModel)
    oView:AddField('MFS', oStruct, 'MFSMASTER')

Return oView

/*/{Protheus.doc} MenuDef
    Definição do Menu para o cadastro de Eixo x Modelo Veículo
    @type    Function
    @author  eduardo.Flima
    @since   06/07/2026
    @version P12
    @return Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA6090"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA6090"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA6090"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA6090"  Operation 5 Access 0 //"Excluir"

Return aRet

/*/{Protheus.doc} Lj6090VlPs
    Validação do Model para o cadastro de Mod Veiculo Prod / Aplicação
    @type  Static Function
    @author eduardo.FLima
    @since 16/06/2026
    @version P12
    @param oModel, Object, Objeto de Model
    @return Logical, Resultado da validação
/*/
Static Function Lj6090VlPs(oModel)
    Local lRet      := .T. as Logical
    Local oModelMFS := oModel:GetModel('MFSMASTER') as Object
    Local nOper     := oModel:GetOperation() as Numeric
    Local cUidMod   := "" as Character
    Local cFilEix   := "" as Character
    Local cCodEix   := "" as Character
    Local aArea     := GetArea() as Array
    Local nRecno    := 0 as Numeric

    If nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_UPDATE
        cFilEix := oModelMFS:GetValue('MFS_FILEIX')
        cCodEix := oModelMFS:GetValue('MFS_CODEIX')
        cUidMod := oModelMFS:GetValue('MFS_MECUID')

        nRecno := MFS->(Recno())// Guarda o record number atual para permitir encontrar o proprio registro no caso de alteracao

        MFS->(DbSetOrder(1)) //MFS_FILIAL+MFS_FILEIX+MFS_CODEIX+MFS_MECUID                                                                                                                                                                                                                   
        
        If MFS->(DbSeek(xFilial("MFS") + cFilEix + cCodEix + cUidMod));
        .and. (nOper == MODEL_OPERATION_INSERT .or. MFS->(Recno()) != nRecno) // Se for alteracao, permite encontrar o proprio registro
            lRet := .F.
            Help(" ", 1, "Lj6090VlPs", , STR0006 , 1, 0; //"Já existe um registro Cadastro de Eixo x Modelo Veículo com essas informações" 
            ,,,,,,{STR0007}) //"Verifique os dados informados"
        EndIf
    EndIf
    RestArea(aArea)
Return lRet

