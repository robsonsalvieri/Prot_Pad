#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA750
H6C   Tipos de itens extravio
@type  Function
@author user
@since 03/10/2022
@version version
@param , param_type, param_descr
@return , return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA750()

    Local oBrowse   := Nil

    If ( !FindFunction("GTPHASACCESS") .Or.; 
	    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        oBrowse    := FWMBrowse():New()
        If ( VldDic() )

            oBrowse:SetAlias('H6C')
            oBrowse:SetDescription("Tipos de itens extravio")

            If !isBlind()
                oBrowse:Activate()
            EndIf

            oBrowse:Destroy()

        EndIf

    EndIf

Return()


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author henrique.toyada
@since 03/10/2022
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPA750' OPERATION OP_VISUALIZAR  ACCESS 0 
    ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.GTPA750' OPERATION OP_INCLUIR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.GTPA750' OPERATION OP_ALTERAR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.GTPA750' OPERATION OP_EXCLUIR	    ACCESS 0 

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel	:= NIL
    Local oStrH6C	:= NIL

    oStrH6C	:= FWFormStruct(1,'H6C')
    SetModelStruct(oStrH6C)

    oModel := MPFormModel():New('GTPA750', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
    
    oModel:SetVldActivate({|| VldDic()})

    oModel:AddFields('H6CMASTER',/*cOwner*/,oStrH6C)

    oModel:SetDescription("Tipos de itens extravio")

    If H6C->(FIELDPOS("H6C_CODIGO")) > 0
        oModel:SetPrimaryKey({'H6C_FILIAL','H6C_CODIGO'})
    EndIf


Return oModel

Static Function VldDic()
    
    Local aFieldsH6C := {'H6C_FILIAL','H6C_CODIGO','H6C_DESCRI','H6C_VALOR'}
    
    Local cMsgErro   := ""
    
    Local lRet := .t.

    lRet :=  GTPxVldDic("H6C",aFieldsH6C,.T.,.T.,@cMsgErro)
    
    If ( !lRet )
        FwAlertWarning(cMsgErro)
    EndIf

Return(lRet)
//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Função responsavel pela estrutura de dados do modelo
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oStrH6A, object, (Descrição do parâmetro)
@param oStrH6B, object, (Descrição do parâmetro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrH6C)

If H6C->(FIELDPOS("H6C_CODIGO")) > 0
    oStrH6C:SetProperty('H6C_CODIGO', MODEL_FIELD_WHEN, {||.F.} )
EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA750')
Local oStrH6C	:= FWFormStruct(2, 'H6C')

//SetViewStruct(oStrH6C)

oView:SetModel(oModel)

oView:AddField('VIEW_H6C'   ,oStrH6C,'H6CMASTER')

oView:CreateHorizontalBox('UPPER'   , 100)

oView:SetOwnerView('VIEW_H6C','UPPER')

oView:SetDescription("Tipos de itens extravio")

Return oView