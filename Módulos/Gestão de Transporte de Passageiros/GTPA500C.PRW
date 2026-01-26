#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} GTPA500C
    Programa em MVC da TOTAIS DE RECEITAS E DESPESAS
    @type  Function
    @author José Carlos
    @since 13/06/2025
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example    GTPA500C()
    @see (links_or_references)
/*/
Function GTPA500C(nAcao, cMensagem, aTit)

    Default aTit    := {}
    SetMsgStatus(nAcao, cMensagem, aTit)

Return Nil

/*/{Protheus.doc} ModelDef
    Definição do modelo de Dados

    @author	 José Carlos
    @since	 13/06/2025
    @version P12
/*/
Static Function ModelDef()
    Local oModel    := Nil 
    Local oStruGZG  := FWFormStruct(1,'GZG',{|cCampo| Alltrim(cCampo) $'GZG_STATIT|GZG_MOTERR|GZG_FILTIT|GZG_PRETIT|GZG_NUMTIT|GZG_PARTIT|GZG_TIPTIT'} )

    oModel := MPFormModel():New('GTPA500C',/*bPreValidMdl*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields('FIELDGZG',,oStruGZG,,,/*bLoad*/)
    oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} SetMsgStatus
    Função para atualizaçõo do status do titulo

    @author	 José Carlos
    @since	 13/06/2025
    @version P12
/*/
Static Function SetMsgStatus(nAcao, cMensagem, aTit)
    Local oMdl        := FwLoadModel( 'GTPA500C' )
    Local oMdlGZG     := oMdl:GetModel("FIELDGZG")
    Local lRet        := .T.
    Local cMsgAtu     := ""
    Default cMensagem := ''
    Default aTit      := {}

	oMdl:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl:Activate()

    If nAcao == 2
        oMdlGZG:SetValue("GZG_STATIT", '2')         //0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.
        cMsgAtu:= Alltrim(oMdlGZG:GetValue('GZG_MOTERR'))
        cMensagem:= Iif(!Empty(cMsgAtu),cMsgAtu+CRLF,'') + DToC(dDataBase) + ' ' + Time() + CRLF + cMensagem
        oMdlGZG:SetValue("GZG_MOTERR", cMensagem)
    ElseIf nAcao == 1
        oMdlGZG:SetValue("GZG_STATIT", '0')         //0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.        
        oMdlGZG:SetValue("GZG_FILTIT", ' ') 
        oMdlGZG:SetValue("GZG_PRETIT", ' ')
        oMdlGZG:SetValue("GZG_NUMTIT", ' ')
        oMdlGZG:SetValue("GZG_PARTIT", ' ')
        oMdlGZG:SetValue("GZG_TIPTIT", ' ')
        oMdlGZG:SetValue("GZG_MOTERR", ' ')
    ElseIf nAcao == 3 .And. Len(aTit) == 5
        oMdlGZG:SetValue("GZG_STATIT", '1')         //0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.                    
        oMdlGZG:SetValue("GZG_FILTIT", aTit[1]) 
        oMdlGZG:SetValue("GZG_PRETIT", aTit[2])
        oMdlGZG:SetValue("GZG_NUMTIT", aTit[3])
        oMdlGZG:SetValue("GZG_PARTIT", aTit[4])
        oMdlGZG:SetValue("GZG_TIPTIT", aTit[5])
    ElseIf nAcao == 4
        oMdlGZG:SetValue("GZG_STATIT", '3')         //0=Não processado;1=Título gerado;2=Erro na geração;3=Sem Vinc. Financ.        
        oMdlGZG:SetValue("GZG_FILTIT", ' ') 
        oMdlGZG:SetValue("GZG_PRETIT", ' ')
        oMdlGZG:SetValue("GZG_NUMTIT", ' ')
        oMdlGZG:SetValue("GZG_PARTIT", ' ')
        oMdlGZG:SetValue("GZG_TIPTIT", ' ')
        oMdlGZG:SetValue("GZG_MOTERR", ' ')
    EndIf 

    lRet := oMdl:VldData() .and. oMdl:CommitData()

    oMdl:DeActivate()
    oMdl:Destroy()

Return lRet  
