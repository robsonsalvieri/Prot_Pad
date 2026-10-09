#include "totvs.ch"
#include "fwmvcdef.ch"
#include "loja690.ch"

/*/{Protheus.doc} LOJA690
    Cadastro de Similares
    @type    function
    @author  eduardo.FLima
    @since   27/05/2026
    @version P12
    @return  Nil
/*/
Function LOJA690()
    Local oBrowse   := FWMBrowse():New()
    Private aRotina := MenuDef()

    oBrowse:SetAlias('MFY')
    oBrowse:SetDescription(STR0001) //"Similares"

    oBrowse:Activate()

    oBrowse:Destroy()
Return Nil

/*/{Protheus.doc} MenuDef
    Definicao do Menu para o cadastro de Similares
    @type    function
    @author  eduardo.FLima
    @since   27/05/2026
    @version P12
    @return  Array com as opcoes do menu para o cadastro de Similares
/*/
Static Function MenuDef()
    Local aRet := {}

    ADD OPTION aRet Title STR0005    Action "VIEWDEF.LOJA690"  Operation 2 Access 0 //"Visualizar"
    ADD OPTION aRet Title STR0002    Action "VIEWDEF.LOJA690"  Operation 3 Access 0 //"Incluir"
    ADD OPTION aRet Title STR0003    Action "VIEWDEF.LOJA690"  Operation 4 Access 0 //"Alterar"
    ADD OPTION aRet Title STR0004    Action "VIEWDEF.LOJA690"  Operation 5 Access 0 //"Excluir"
    ADD OPTION aRet Title STR0006    Action "VIEWDEF.LOJA690"  Operation 9 Access 0 //"Copiar"
Return aRet

/*/{Protheus.doc} ModelDef
    Definicao do Model para o cadastro de Similares
    @type    function
    @author  eduardo.FLima
    @since   27/05/2026
    @version P12
    @return  Objeto de Model para o cadastro de Similares
/*/
Static Function ModelDef()
    Local oStruct := FWFormStruct(1, 'MFY')
    Local oModel  := MPFormModel():New('LOJA690', /*Pre-Validacao*/,{|oModel| VldModel(oModel)},/*Commit*/,/*Cancel*/)

    oModel:SetDescription(STR0001) //"Similares"
    oModel:AddFields('MFYMASTER', /*cOwner*/, oStruct)
    oModel:SetPrimaryKey({'MFY_FILIAL', 'MFY_CODGRP', 'MFY_FILPRO', 'MFY_CODPRO'})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View para o cadastro de Similares
    @type    function
    @author  eduardo.FLima
    @since   27/05/2026
    @version P12
    @return  Objeto de View para o cadastro de Similares
/*/
Static Function ViewDef()
    Local oView   := FWFormView():New()
    Local oStruct := FWFormStruct(2, 'MFY')
    Local oModel  := FWLoadModel('LOJA690')

    oView:SetDescription(STR0001) //"Similares"
    oView:SetModel(oModel)
    oView:AddField('MFY', oStruct, 'MFYMASTER')
    oView:EnableTitleView('MFY', STR0001) //"Similares"

Return oView

/*/{Protheus.doc} VldModel
    Validacao do Model para o cadastro de Similares.
    Impede inclusao de registro com chave primaria duplicada (MFY_FILIAL+MFY_CODGRP+MFY_FILPRO+MFY_CODPRO).
    @type    function
    @author  eduardo.FLima
    @since   27/05/2026
    @version P12
    @param   oModel , Object , Objeto do Model MVC
    @return  Logical, .T. se validacao OK, .F. se registro duplicado
/*/
Static Function VldModel(oModel)
    Local lRet      := .T. as Logical
    Local oModelMFY := oModel:GetModel('MFYMASTER') as Object
    Local nOper     := oModel:GetOperation() as Numeric
    Local cCodGrp   := "" as Character
    Local cFilPro   := "" as Character
    Local cCodPro   := "" as Character
    Local aArea     := GetArea() as Array
    Local nRecno    := 0 as Numeric

    // Valida duplicidade  na inclusao E NA ALTERAÇÃO 
    If nOper == MODEL_OPERATION_INSERT .or. nOper == MODEL_OPERATION_UPDATE
        cCodGrp := oModelMFY:GetValue("MFY_CODGRP")
        cFilPro := oModelMFY:GetValue("MFY_FILPRO")
        cCodPro := oModelMFY:GetValue("MFY_CODPRO")

        DbSelectArea("MFY")
        nRecno := MFY->(Recno())// Guarda o record number atual para permitir encontrar o proprio registro no caso de alteracao
        MFY->(DbSetOrder(1)) //MFY_FILIAL+MFY_CODGRP+MFY_FILPRO+MFY_CODPRO
        
        If MFY->(DbSeek(xFilial("MFY") + cCodGrp + cFilPro + cCodPro)) ;
        .and. (nOper == MODEL_OPERATION_INSERT .or. MFY->(Recno()) != nRecno) // Se for alteracao, permite encontrar o proprio registro
            lRet := .F.
            Help(" ", 1, "VLDMODEL", , STR0007 + AllTrim(cCodGrp) + STR0008 + AllTrim(cCodPro) + STR0009, 1, 0,) //"Ja existe um registro para o agrupamento " ### " e o produto " ### ". Nao e permitido incluir duplicados."
        EndIf
    EndIf

    RestArea(aArea)

Return lRet
