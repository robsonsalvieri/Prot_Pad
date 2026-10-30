#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include 'LOJA6120.ch'
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} LOJA6120
    Cadastro de Sucata (Auto Peças)
    @type    Function
    @author  Alberto Deviciente
    @since   14/08/2026
    @version P12
    @return  Nil, Nulo
/*/
Function LOJA6120()
    Local oBrowse := FWMBrowse():New() as Object

    oBrowse:SetAlias('MGA')
    oBrowse:SetDescription(STR0001) //"Cadastro de Sucata"
    If hasSmartX()
        oBrowse:SetSmartX()
    EndIf
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do Model para o cadastro de Sucata
    @type    Function
    @author  Alberto Deviciente
    @since   14/08/2026
    @version P12
    @return  oModel, Object, Objeto de Model para o cadastro de Sucata
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MGA')
    Local oModel  := MPFormModel():New('LOJA6120', /*Pre-Validacao*/,/* Valid Model */,/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Cadastro de Sucata"
    oModel:AddFields('MGAMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MGA_FILIAL', 'MGA_COD'})

    // Validação na ativação do modelo para verificar se o registro pode sofrer manutenção/deleção
    oModel:SetVldActivate( {|oModel| Lj6120VAct(oModel)} )

Return oModel

/*/{Protheus.doc} ViewDef
    Definição da View para o cadastro de Sucata
    @type    Function
    @author  Alberto Deviciente
    @since   14/08/2026
    @version P12
    @return  oView, Object, Objeto de View para o cadastro de Sucata
/*/
Static Function ViewDef()
    Local oView   as Object
    Local oStruct as Object
    Local oModel  as Object

    oView   := FWFormView():New()
    oStruct := FWFormStruct(2, 'MGA')
    oModel  := FWLoadModel('LOJA6120')

    oView:SetDescription(STR0001) //"Cadastro de Sucata"
    oView:SetModel(oModel)
    oView:AddField('MGA', oStruct, 'MGAMASTER')
    oView:EnableTitleView('MGA', STR0001) //"Cadastro de Sucata"
    oView:CreateHorizontalBox('BOXMGA', 100)
    oView:SetOwnerView('MGA', 'BOXMGA')

Return oView 

/*/{Protheus.doc} MenuDef
    Definição do Menu para o cadastro de Sucata
    @type    Function
    @author  Alberto Deviciente
    @since   14/08/2026
    @version P12
    @return  aRet, Array, Array com as opcoes do menu
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0002  Action "VIEWDEF.LOJA6120"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0003  Action "VIEWDEF.LOJA6120"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0004  Action "VIEWDEF.LOJA6120"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0005  Action "VIEWDEF.LOJA6120"  Operation 5 Access 0 //"Excluir"

Return aRet

//-------------------------------------------------------------------------------
/*/{Protheus.doc} Lj6120VAct
Validação na ativação do modelo p/ verificar se pode efetuar manutenção/deleção no registro.

@type    Static Function
@author  Alberto Deviciente
@since   01/09/2026
@version 12
@param   oModel, Object, Objeto de Model do movimento de Entrada de Sucata
@return  lRet, Logical, .T. se permite a ativação/edição, .F. caso contrário
/*/
//-------------------------------------------------------------------------------
Static Function Lj6120VAct(oModel)
    Local lRet       As Logical
    Local nOperation As Numeric

    lRet       := .T.
    nOperation := oModel:GetOperation()
    
    If nOperation == MODEL_OPERATION_DELETE
        DbSelectArea("MFX")
        MFX->(DbSetOrder(2)) //MFX_FILIAL+MFX_TIPSUC
        If MFX->(DbSeek(xFilial("MFX") + MGA->MGA_COD))
            //Caso exista movimento de entrada de sucata para esta sucata, então não permite excluir
            Help(" ", 1, "HELP", Nil, STR0006, 1, 0,,,,,,) //"Não é permitido excluir, pois existe movimentação de entrada de sucata para este registro."
            lRet := .F.
        EndIf
    EndIf

Return lRet
