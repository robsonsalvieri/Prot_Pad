#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static Function ViewDef()

    Local oView     := FwLoadView("GTPA756")
    Local oStrH6K   := oView:GetViewStruct("VIEW_H6K")

    AdjustModel(oView)
    ViewStruct(@oStrH6K)
    
Return(oView)

Static Function ViewStruct(oStrH6K)
    
    oStrH6K:RemoveField("H6K_DOC")

    oStrH6K:RemoveField("H6K_CODGI2")
    oStrH6K:RemoveField("H6KDESGI2")
    oStrH6K:RemoveField("H6K_CODGID")
    oStrH6K:RemoveField("H6K_DTVIAG")
    oStrH6K:RemoveField("H6K_CODGIC")
    oStrH6K:RemoveField("H6K_TELEFO")
    oStrH6K:RemoveField("H6K_EMAIL")
    oStrH6K:RemoveField("H6K_RGPASS")
    oStrH6K:RemoveField("H6K_ENDPAS")
    oStrH6K:RemoveField("H6K_CPENPS")
    oStrH6K:RemoveField("H6K_CEPPAS")
    oStrH6K:RemoveField("H6K_DTOCOR")
    oStrH6K:RemoveField("H6K_DTSLA")
    oStrH6K:RemoveField("H6K_ORICON")
    oStrH6K:RemoveField("H6K_DOC")
    oStrH6K:RemoveField("H6K_SERIE")
    oStrH6K:RemoveField("H6K_FOREMP")
    oStrH6K:RemoveField("H6K_LJFOEM")
    oStrH6K:RemoveField("H6KDEMPFOR")
    oStrH6K:RemoveField("H6K_USUAR")
    oStrH6K:RemoveField("H6KUSRNOME")
    oStrH6K:RemoveField("H6K_DTENVI")
    oStrH6K:RemoveField("H6K_HRENVI")
    oStrH6K:RemoveField("H6K_USRENV")
    oStrH6K:RemoveField("H6KUSENVNM")
    oStrH6K:RemoveField("H6K_DTRECE")
    oStrH6K:RemoveField("H6K_HRRECE")
    oStrH6K:RemoveField("H6K_USRECE")
    oStrH6K:RemoveField("H6KUSRECNM")
    oStrH6K:RemoveField("H6K_DTRETI")
    oStrH6K:RemoveField("H6K_HRRETI")
    oStrH6K:RemoveField("H6K_USRETI")
    oStrH6K:RemoveField("H6KUSRETNM")
    oStrH6K:RemoveField("H6K_OBSERV")
    
    oStrH6K:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
    
    oStrH6K:SetProperty("H6K_DOCONS",MVC_VIEW_CANCHANGE,.t.)
    oStrH6K:SetProperty("H6K_FORPAS",MVC_VIEW_CANCHANGE,.t.)
    oStrH6K:SetProperty("H6K_LJFOPA",MVC_VIEW_CANCHANGE,.t.)
    oStrH6K:SetProperty("H6K_VLRDOC",MVC_VIEW_CANCHANGE,.t.)
    // oStrH6K:SetProperty("H6K_PREFIX",MVC_VIEW_CANCHANGE,.t.)
    // oStrH6K:SetProperty("H6K_PARCEL",MVC_VIEW_CANCHANGE,.f.)
    // oStrH6K:SetProperty("H6K_TIPO",MVC_VIEW_CANCHANGE,.t.)

Return()

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
    // Local oStruct   := oModel:GetModel("H6KMASTER"):GetStruct()
    
    Local bSetPost  := {|oModel| ValidAllOK(oModel) }
    Local bCommit   := {|oModel| GA756Commit(oModel,"GTPA756E") }

    // ModelStruct(@oStruct)

    oModel:SetCommit(bCommit)
    oModel:SetPost(bSetPost)
    
    oModel:GetModel('H6LDETAIL'):SetOnlyQuery(.T.)
    oModel:GetModel('H6LDETAIL'):SetNoInsertLine()
    oModel:GetModel('H6LDETAIL'):SetNoUpdateLine()
    oModel:GetModel('H6LDETAIL'):SetNoDeleteLine()

Return()

Static Function ValidAllOK(oModel)

    Local cMsgErro  := ""
    Local cMsgSolu  := ""
    Local cNaturez  := ""

    Local lRet  := .T.

    cNaturez    := GTPGetRules("NATCONSERT",,,"")

    If ( Empty(cNaturez) )
        
        lRet := .F.

        cMsgErro    := "A natureza financeira para gerar o título não foi preenchida. "
        
        cMsgSolu    := "Cadastre a natureza para este tipo de operação em: "
        cMsgSolu    += "Miscelanea > Parâmetros do Módulo (GTPA281) > Preenche Cont. "
        cMsgSolu    += "do parâmetro NATCONSERT (Natureza financeira do reembolso "
        cMsgSolu    += "de conserto para o título a pagar). "

    ElseIf ( Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_FORPAS")) .Or.;
         Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_LJFOPA")) )

        lRet := .F.
        
        cMsgErro    := "Os dados de fornecedor (cadastro do passageiro como tal) "
        cMsgErro    += "para o reembolso não foram preenchidos."
        
        cMsgSolu    := "Verifique se os campos '" 
        cMsgSolu     += Alltrim(FWX3Titulo("H6K_FORPAS")) + "' e '"
        cMsgSolu     += Alltrim(FWX3Titulo("H6K_LJFOPA")) + "' estão preenchidos "
        
                
    ElseIf ( Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_PREFIX")) )

        lRet := .F.
        
        cMsgErro    := "O prefixo para geração do título a pagar "
        cMsgErro    += "do reembolso de conserto não foi preenchido."
        
        cMsgSolu    := "Deve-se cadastrar o prefixo para a geração do título em: "
        cMsgSolu    += "Miscelanea > Parâmetros do Módulo (GTPA281) > Preenche Cont. "
        cMsgSolu    += "do parâmetro PRECONSERT (Prefixo do titulo a pagar para "
        cMsgSolu    += "reembolso de conserto). "

    ElseIf ( Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_TIPO")) )
       
        lRet := .F.
        
        cMsgErro    := "O tipo de título a pagar do reembolso de conserto, "
        cMsgErro    += "que será gerado, não foi preenchido."
        
        cMsgSolu    := "Deve-se cadastrar o prefixo para a geração do título em: "
        cMsgSolu    += "Miscelanea > Parâmetros do Módulo (GTPA281) > Preenche Cont. "
        cMsgSolu    += "do parâmetro TIPCONSERT (Tipo do titulo a pagar para "
        cMsgSolu    += "reembolso de conserto). "
    
    EndIf  

    If (!lRet)
        oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","ValidAllOK",cMsgErro,cMsgSolu)
    EndIf
    
Return(lRet)
