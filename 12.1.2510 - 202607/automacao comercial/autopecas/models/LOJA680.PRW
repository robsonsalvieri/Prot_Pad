#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "LOJA680.ch"

/*/{Protheus.doc} LOJA680
    Cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  Nil
/*/
Function LOJA680()
    Local oBrowse As Object

    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('MG1')
    oBrowse:SetDescription(STR0001) //"Produto x Fabricante"
    oBrowse:SetMenuDef('LOJA680')   // Vincula ao MenuDef da rotina

    oBrowse:Activate()

    FreeObj(oBrowse) // Libera o objeto da memoria
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  aRet, Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet As Array
    aRet := {}

    ADD OPTION aRet Title STR0002 Action "VIEWDEF.LOJA680" Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003 Action "VIEWDEF.LOJA680" Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004 Action "VIEWDEF.LOJA680" Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005 Action "VIEWDEF.LOJA680" Operation 5 Access 0 //"Excluir"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  oModel, Object, Objeto de Model para o cadastro de Produto x Fabricante
/*/
Static Function ModelDef()
    Local oStruct As Object
    Local oModel  As Object

    oStruct := FWFormStruct(1, 'MG1')
    oModel  := MPFormModel():New('LOJA680', /*bPre*/, /*bPost*/ { |oModel| Lj680VldPos( oModel ) },/*bCommit*/,/*bCancel*/)

    oModel:SetDescription(STR0001) //"Produto x Fabricante"
    oModel:AddFields('MG1MASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MG1_FILIAL', 'MG1_FILFAB', 'MG1_CODFAB', 'MG1_LOJFAB', 'MG1_FILPRD', 'MG1_CODPRD'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @return  oView, Object, Objeto de View para o cadastro de Produto x Fabricante
/*/
Static Function ViewDef()
    Local oModel  := FWLoadModel('LOJA680')
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MG1')

    // Remove campos da estrutura que nao serao apresentados na tela
    oStruct:RemoveField('MG1_FILPRD')
    oStruct:RemoveField('MG1_FILFAB')

    oView:SetDescription(STR0001) //"Produto x Fabricante"
    oView:SetModel(oModel)
    oView:AddField('MG1', oStruct, 'MG1MASTER')
    oView:EnableTitleView('MG1', STR0001) //"Produto x Fabricante"

Return oView

/*/{Protheus.doc} Lj680VldPos
    Bloco de Validacao do cadastro de Produto x Fabricante
    @type    function
    @author  Alberto Deviciente
    @since   24/05/2026
    @version P12
    @param   oModel, Object, Objeto de Model do cadastro de Produto x Fabricante
    @return  lRet, Logical, Resultado da validacao do cadastro de Produto x Fabricante
/*/
Static Function Lj680VldPos( oModel )
Local nOperation As Numeric
Local lRet       As Logical
Local cChave     As Character
Local aAreaMG1   As Array
Local nRecnoMG1  As Numeric

nOperation  := oModel:GetOperation()
lRet        := .T.

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
    cChave := oModel:GetValue('MG1MASTER', 'MG1_FILFAB')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_CODFAB')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_LOJFAB')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_FILPRD')
    cChave += oModel:GetValue('MG1MASTER', 'MG1_CODPRD')

    aAreaMG1    := MG1->(GetArea())
    nRecnoMG1   := MG1->(Recno())

    DbSelectArea("MG1")
    MG1->(DbSetOrder(1)) //MG1_FILIAL+MG1_FILFAB+MG1_CODFAB+MG1_LOJFAB+MG1_FILPRD+MG1_CODPRD

    //Valida se ja existe registro cadastrado com a mesma chave
    If MG1->(DbSeek(xFilial("MG1") + cChave))
        If nOperation == MODEL_OPERATION_INSERT .Or. (nOperation == MODEL_OPERATION_UPDATE .And. nRecnoMG1 != MG1->(Recno()))
            lRet := .F.
            // Exibe mensagem ao usuario informando chave duplicada
            //Help( " ",1,"JAGRAVADO" )
            oModel:SetErrorMessage(oModel:GetId(),,,,, STR0006, STR0007) //"Já existe registro cadastrado para este Produto x Fabricante." ### "Informe uma combinação de Fabricante e Produto diferente."
        EndIf
    EndIf

    RestArea(aAreaMG1)
EndIf

Return lRet



