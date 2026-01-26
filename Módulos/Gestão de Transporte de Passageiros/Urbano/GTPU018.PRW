#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU018.CH'

/*/{Protheus.doc} GTPU018
(long_description)
@type  Static Function
@author Karyna Martins
@since 02/07/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPU018()

    Local oBrowse   := Nil

    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('H82')
    oBrowse:SetDescription(STR0001) // "Grupo de colaborador"
    oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author Karyna Martins
@since 02/07/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()

    Local aRotina := {}
        
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.GTPU018' OPERATION 2 ACCESS 0	//'Visualizar'
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.GTPU018' OPERATION 3 ACCESS 0	//'Incluir'
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPU018' OPERATION 4 ACCESS 0	//'Alterar'
    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPU018' OPERATION 5 ACCESS 0	//'Excluir'
	    
Return aRotina

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author Karyna Martins
@since 02/07/2024
@version 1.0@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()

    Local oModel	 := Nil
    Local oStruH82	 := FwFormStruct(1,'H82')
    Local oStruH83	 := FwFormStruct(1,'H83')

    oModel := MPFormModel():New('GTPU018', , {|oModel| PosValid(oModel)}, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('H82MASTER',/*cOwner*/,oStruH82)
    oModel:AddGrid('H83DETAIL', 'H82MASTER', oStruH83, /*bPre*/, , /*bPre*/) 

    oModel:SetRelation('H83DETAIL', {{'H83_FILIAL', 'xFilial( "H83")'},{'H83_CODH82', 'H82_CODIGO'}}, H83->(IndexKey(1)))

    oModel:GetModel('H83DETAIL'):SetOptional(.T.)

    oModel:SetDescription(STR0001) // "Grupo de colaborador"
    oModel:GetModel('H82MASTER'):SetDescription(STR0001) // "Grupo de colaborador"
		
Return oModel

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author Karyna Martins
@since 02/07/2024
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()

    Local oModel	:= ModelDef()
    Local oView		:= FwFormView():New()
    Local oStruH82	:= FwFormStruct(2, 'H82')
    Local oStruH83	:= FwFormStruct(2, 'H83') 

    oView:SetModel(oModel)

    oView:SetDescription(STR0001) // "Grupo de colaborador"

    oView:AddField('VIEW_HEADER', oStruH82,'H82MASTER')
    oView:AddGrid('VIEW_GRID', oStruH83, 'H83DETAIL')

    oView:CreateHorizontalBox('VIEWHEADER', 70)
    oView:CreateHorizontalBox('VIEWGRID', 30)

    oView:SetOwnerView('VIEW_HEADER', 'VIEWHEADER')
    oView:SetOwnerView('VIEW_GRID', 'VIEWGRID')

    //oView:EnableTitleView("VIEW_HEADER", STR0008) 
    oView:EnableTitleView("VIEW_GRID", STR0003) // "Colaboradores"

    oStruH82:AddGroup('GRP001', STR0009,'', 2)
    oStruH82:AddGroup('GRP002', STR0010,'', 2)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid
 *Valida se o colaborador já está em outro grupo
 *author GTP
 *since 02/07/2025
 *version 1.0
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)
    Local lRet          := .T.
    Local oMdl          := oModel:GetModel()
    Local oModelH82     := oMdl:GetModel('H82MASTER')
    Local oModelH83     := oMdl:GetModel('H83DETAIL')
    Local nI            := 0
    Local cColab  := ""
    Local cGrupo        := ""
    Local cMsgErro      := ""
    Local cMsgSol       := ""
    Local cCodH82       := ""

    If oModel:GetOperation() <> MODEL_OPERATION_DELETE
     
        H83->( DBSetOrder(2) )
        // Verifica cada linha do grid H83
        For nI := 1 To oModelH83:GetQtdLine()
            
            oModelH83:GoLine(nI)
            cCodH82 := oModelH82:GetValue('H82_CODIGO')
            cColab  := oModelH83:GetValue('H83_CODGYG')
            cDesCo  := oModelH83:GetValue('H83_DESGYG')
                    
            If H83->( DBSeek(xFilial("H83") + cColab)) .And. cCodH82 <> H83->H83_CODH82

                H82->( DBSetOrder(1) )
                If H82->( DBSeek(xFilial("H82") + H83->H83_CODH82))
                    cGrupo := H82->H82_DESCRI
                EndIf
                lRet := .F.
                cMsgErro :=  STR0011 + AllTrim(cDesCo) + STR0012 + cGrupo // "O colaborador: "     " está cadastrado no grupo: "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
                cMsgSol  := STR0013 // "Informe outro colaborador"                
                exit
            EndIf
        Next

        If !lRet
            oModel:SetErrorMessage(oModel:GetId(), "", oModel:GetId(), "", "GU018PosVld", cMsgErro, cMsgSol) 
        EndIf
    
    EndIf

Return lRet
        