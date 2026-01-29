#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static Function ViewDef()

    Local oView     := FwLoadView("GTPA756")
    Local oStrH6K   := oView:GetViewStruct("VIEW_H6K")

    AdjustModel(oView)    
    ViewStruct(@oStrH6K)    
    
Return(oView)

/*/{Protheus.doc} AdjustModel
    (long_description)
    @type  Static Function
    @author user
    @since 11/11/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function AdjustModel(oView)

    Local oModel    := oView:GetModel()

    Local bSetPost  := {|oModel| ValidAllOK(oModel) }
    Local bCommit   := {|oModel| GA756Commit(oModel,"GTPA756C") }

    oModel:SetCommit(bCommit)
    oModel:SetPost(bSetPost)
    oModel:GetModel('H6LDETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('H6LDETAIL'):SetNoInsertLine()
    oModel:GetModel('H6LDETAIL'):SetNoUpdateLine()
    oModel:GetModel('H6LDETAIL'):SetNoDeleteLine()

Return()

Static Function ViewStruct(oStrH6K)

    oStrH6K:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
    oStrH6K:SetProperty("H6K_FOREMP",MVC_VIEW_CANCHANGE,.T.)
    oStrH6K:SetProperty("H6K_LJFOEM",MVC_VIEW_CANCHANGE,.T.)
    oStrH6K:SetProperty("H6K_DOC",MVC_VIEW_CANCHANGE,   .T.)
    oStrH6K:SetProperty("H6K_SERIE",MVC_VIEW_CANCHANGE, .T.)
    oStrH6K:SetProperty("H6K_VLRDOC",MVC_VIEW_CANCHANGE,.T.)

    oStrH6K:RemoveField("H6K_CODGI2")
    oStrH6K:RemoveField("H6KDESGI2")
    oStrH6K:RemoveField("H6K_CODGID")
    oStrH6K:RemoveField("H6K_DTVIAG")
    oStrH6K:RemoveField("H6K_CODGIC")
    oStrH6K:RemoveField("H6K_DTSLA")
    oStrH6K:RemoveField("H6K_ORICON")
    oStrH6K:RemoveField("H6K_DOCONS")
    oStrH6K:RemoveField("H6K_FORPAS")
    oStrH6K:RemoveField("H6K_LJFOPA")
    oStrH6K:RemoveField("H6KDPASFOR")
    oStrH6K:RemoveField("H6K_OBSERV")
    oStrH6K:RemoveField("H6K_STATUS")
    oStrH6K:RemoveField("H6K_AGENCI")
    oStrH6K:RemoveField("H6KDESCAGE")
    oStrH6K:RemoveField("H6K_USUAR")
    oStrH6K:RemoveField("H6KUSRNOME")
    oStrH6K:RemoveField("H6K_DTRETI")
    oStrH6K:RemoveField("H6K_HRRETI")
    oStrH6K:RemoveField("H6K_USRETI")
    oStrH6K:RemoveField("H6KUSRETNM")
    oStrH6K:RemoveField("H6K_DTREEM")
    oStrH6K:RemoveField("H6K_HRREEM")
    oStrH6K:RemoveField("H6K_USREEM")
    oStrH6K:RemoveField("H6KUSREENM")
    oStrH6K:RemoveField("H6K_PREFIX")
    oStrH6K:RemoveField("H6K_NUM")
    oStrH6K:RemoveField("H6K_PARCEL")
    oStrH6K:RemoveField("H6K_TIPO")
    
Return()

Static Function ValidAllOK(oModel)

    Local cMsgErro  := ""
    Local cMsgSolu  := ""

    Local lRet  := .T.

    If ( Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_FOREMP")) .Or.;
         Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_LJFOEM")) ) 

        lRet := .F.
        cMsgErro    := "Os dados de fornecedor para o conserto não foram preenchidos."
        
        cMsgSolu    := "Verifique se os campos '" 
        cMsgSolu     += Alltrim(FWX3Titulo("H6K_FOREMP")) + "' e '"
        cMsgSolu     += Alltrim(FWX3Titulo("H6K_LJFOEM")) + "' estão preenchidos "
        
        oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","ValidAllOK",cMsgErro,cMsgSolu)

    EndIf        

Return(lRet)
