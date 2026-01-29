#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA751
H6D   Tipos de extravio
H6E   Itens tipos de extravio
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
Function GTPA751()
    
    Local oBrowse    := FWMBrowse():New()

    If ( !FindFunction("GTPHASACCESS") .Or.; 
	    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
            
        oBrowse    := FWMBrowse():New()
        
        If ( VldDic() )

            oBrowse:SetAlias('H6D')
            oBrowse:SetDescription("Tipos de extravio")

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

    ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPA751' OPERATION OP_VISUALIZAR  ACCESS 0 
    ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.GTPA751' OPERATION OP_INCLUIR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.GTPA751' OPERATION OP_ALTERAR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.GTPA751' OPERATION OP_EXCLUIR	    ACCESS 0 

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

    Local oModel	:= nil
    Local oStrH6D	:= nil
    Local oStrH6E	:= nil
    Local bPreLine  := {|oModel,nLine,cAction,cField,uValue| VldPreLine(oModel,nLine,cAction,cField,uValue)}
    
    oStrH6D	:= FWFormStruct(1,'H6D')
    oStrH6E	:= FWFormStruct(1,'H6E')

    SetModelStruct(oStrH6D,oStrH6E)

    oModel := MPFormModel():New('GTPA751', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
    
    oModel:SetVldActivate({|| VldDic()})
    
    oModel:AddFields('H6DMASTER',/*cOwner*/,oStrH6D)
    oModel:AddGrid('H6EDETAIL','H6DMASTER',oStrH6E,bPreLine,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)

    oModel:SetRelation('H6EDETAIL',{{ 'H6E_FILIAL','xFilial("H6E")'},{'H6E_CODIGO','H6D_CODIGO' }},H6E->(IndexKey(1)))

    oModel:SetDescription("Tipos de extravio")

    oModel:SetPrimaryKey({'H6D_FILIAL','H6D_CODIGO'})

Return oModel

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 13/12/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function VldDic()
    
    Local aFieldsH6D := {'H6D_FILIAL','H6D_CODIGO','H6D_DESCRI','H6D_PERIOD','H6D_QTDPE','H6D_REEMBO'}
    Local aFieldsH6E := {'H6E_FILIAL','H6E_CODIGO','H6E_SEQ','H6E_CODH6C','H6E_VALH6C'}
    
    Local cMsgErro   := ""
    
    Local lRet      := .T.

    lRet :=  GTPxVldDic("H6D",aFieldsH6D,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6E",aFieldsH6E,.T.,.T.,@cMsgErro)
    
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
Static Function SetModelStruct(oStrH6D,oStrH6E)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

    oStrH6D:SetProperty('H6D_CODIGO', MODEL_FIELD_WHEN, {||.F.} )

    oStrH6D:SetProperty('H6D_DESCRI', MODEL_FIELD_OBRIGAT, .t. )
    oStrH6E:SetProperty('H6E_CODIGO', MODEL_FIELD_OBRIGAT, .F.)
    
    oStrH6E:SetProperty('H6E_CODIGO', MODEL_FIELD_INIT, bInit )
    oStrH6E:SetProperty('H6E_DESH6C', MODEL_FIELD_INIT, bInit )
    
    oStrH6E:AddTrigger('H6E_CODH6C', 'H6E_CODH6C',  { || .T. }, bTrig ) 
    oStrH6E:AddTrigger('H6E_VALH6C', 'H6E_VALH6C',  { || .T. }, bTrig ) 

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldInit

@type Function
@author henrique.toyada 
@since 02/08/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)

Local uRet      := nil
Local oModel	:= oMdl:GetModel()
Local lInsert	:= oModel:GetOperation() == MODEL_OPERATION_INSERT 
Local aArea     := GetArea()

Do Case 
    Case cField == "H6E_CODIGO"
		uRet := If(lInsert,M->H6D_CODIGO,H6D->H6D_CODIGO)
    Case cField == "H6E_DESH6C"
        uRet := If(!lInsert,Posicione("H6C",1,xFilial("H6C")+H6E->H6E_CODH6C,"H6C_DESCRI"),'')
EndCase 

RestArea(aArea)

Return uRet

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função que preenche trigger

@sample	GA850ATrig()

@author henrique.toyada
@since 02/08/2022
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

    Local oModel	:= oMdl:GetModel()
    Local oModelH6D := oModel:GetModel("H6DMASTER")
    Local oModelH6E := oModel:GetModel("H6EDETAIL")
    
    Local nValTot   := 0
    Local nI        := 0

	Do Case 
        Case cField == "H6E_CODH6C"
            SetFieldH6C(oMdl,uVal)
        Case cField == "H6E_VALH6C"
            
            For nI := 1 to oModelH6E:Length()

                If ( !(oModelH6E:IsDeleted()) )
                    nValTot +=  oModelH6E:GetValue("H6E_VALH6C",nI)
                EndIf

            Next nI

            oModelH6D:LoadValue("H6D_REEMBO", nValTot) 
	EndCase 

Return uVal

/*/{Protheus.doc} VldPreLine
(long_description)
@type function
@author henrique.toyada
@since 25/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldPreLine(oMdl,nLine,cAction,cField,uValue)
Local lRet		:= .T.
Local oModel    := oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local oModelH6D := oModel:GetModel("H6DMASTER")
Local nValTot   := oModelH6D:GetValue("H6D_REEMBO")

If cMdlId == "H6EDETAIL"

	IF (cAction == "DELETE")
        // Pega o valor do registro posicionado no delete 
        nValTot -= oMdl:GetValue("H6E_VALH6C", nLine)
        
        oModelH6D:LoadValue("H6D_REEMBO", nValTot)
        
    ELSEIF (cAction == "UNDELETE") 
        nValTot += oMdl:GetValue("H6E_VALH6C", nLine)
        
        oModelH6D:LoadValue("H6D_REEMBO", nValTot) 
    EndIf    

Endif

Return lRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetFieldH6C
Função responsavel pelo preenchimento dos campos do tipo de item
@type Static Function
@author henrique.toyada
@since 02/08/2022
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@param cCodH6C, character, (Descrição do parâmetro)
@return nil, retorna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetFieldH6C(oMdl,cCodH6C)

    Local aAreaH6C  := H6C->(GetArea())
    
    H6C->(DbSetOrder(1))//H6C_FILIAL+H6C_CODIGO

    If ( H6C->(DbSeek(xFilial('H6C')+cCodH6C)) )

        oMdl:SetValue('H6E_DESH6C',H6C->H6C_DESCRI)
        oMdl:SetValue('H6E_VALH6C',H6C->H6C_VALOR )
        
    Endif

    RestArea(aAreaH6C)
    GtpDestroy(aAreaH6C)

Return nil

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
Local oModel	:= FwLoadModel('GTPA751')
Local oStrH6D	:= FWFormStruct(2, 'H6D')
Local oStrH6E	:= FWFormStruct(2, 'H6E')

SetViewStruct(oStrH6D,oStrH6E)

oView:SetModel(oModel)

oView:AddField('VIEW_H6D'   ,oStrH6D,'H6DMASTER')
oView:AddGrid('VIEW_H6E'    ,oStrH6E,'H6EDETAIL')

oView:CreateHorizontalBox('UPPER'   , 30)
oView:CreateHorizontalBox('BOTTOM'  , 70)

oView:SetOwnerView('VIEW_H6D','UPPER')
oView:SetOwnerView('VIEW_H6E','BOTTOM')

oView:SetDescription("Tipos de extravio")

If H6E->(FIELDPOS("H6E_SEQ")) > 0
    oView:AddIncrementField('VIEW_H6E','H6E_SEQ')
EndIf

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Função responsavel pela estrutura de dados da view
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
Static Function SetViewStruct(oStrH6D,oStrH6E)

    oStrH6D:SetProperty("H6D_REEMBO", MVC_VIEW_CANCHANGE , .F.)
    oStrH6E:RemoveField('H6E_CODIGO')

Return