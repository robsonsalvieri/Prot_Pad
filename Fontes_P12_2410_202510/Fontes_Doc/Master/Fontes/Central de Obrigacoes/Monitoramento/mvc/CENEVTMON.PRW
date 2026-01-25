#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#DEFINE GUIA_MONITORAMENTO    '1'
#DEFINE FORNECIMENTO_DIRETO   '2'
#DEFINE OUTRA_REMUNERACAO     '3'
#DEFINE VALOR_PREESTABELECIDO '4'                                           

Class CENEVTMON FROM FWModelEvent
         
    Method new()
    Method InTTS(oModel, cModelId)
    Method VldActivate(oModel, cModelId)
    Method Destroy()
End Class

Method new ()  Class CENEVTMON
Return
  
Method Destroy()  Class CENEVTMON       
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
    Valida se o lote que está sendo deletado possui arquivo gerado

    @type  Class
    @author vinicius.nicolau
    @since 03/08/2020
/*/
//------------------------------------------------------------------------------------------
Method VldActivate(oModel, cModelId) Class CENEVTMON
    Local lRet := .T.

	If cModelId == "CENMVCBKW" .And. oModel:GetOperation() == MODEL_OPERATION_DELETE
        lRet := BKW->BKW_STATUS != '2'
        Help(NIL, NIL, "Ajuda", NIL, "Não é possível deletar um Lote com o Arquivo Gerado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Delete lotes sem arquivo gerado."})
	EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
    Atualiza o status do lote após ele ser deletado na BKW verificando em qual tipo de remuneração.

    @type  Class
    @author vinicius.nicolau
    @since 03/08/2020
/*/
//------------------------------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class CENEVTMON

    Local cTipRem := oModel:getValue('BKWMASTER','BKW_FORREM')
    Local aAlias  := {}
    Local nX      := 0
    
    Do Case
        Case cTipRem == GUIA_MONITORAMENTO
            oColBKR := CenCltBKR():New()
            Aadd(aAlias,oColBKR)
            oColBKS := CenCltBKS():New()
            Aadd(aAlias,oColBKS)
            oColBKT := CenCltBKT():New()
            Aadd(aAlias,oColBKT)
            oColBN0 := CenCltBN0():New()
            Aadd(aAlias,oColBN0)
        
        Case cTipRem == FORNECIMENTO_DIRETO
            oColBVQ := CenCltBVQ():New()
            Aadd(aAlias,oColBVQ)
            oColBVT := CenCltBVT():New()
            Aadd(aAlias,oColBVT)

        Case cTipRem == OUTRA_REMUNERACAO
            oColBVZ := CenCltBVZ():New()
            Aadd(aAlias,oColBVZ)

        Case cTipRem == VALOR_PREESTABELECIDO
            oColB9T := CenCltB9T():New()
            Aadd(aAlias,oColB9T)    
    EndCase

    for nX := 1 to len(aAlias)
        aAlias[nX]:SetValue("referenceYear"    ,oModel:getValue('BKWMASTER','BKW_ANO'))
        aAlias[nX]:SetValue("commitmentCode"   ,oModel:getValue('BKWMASTER','BKW_CDCOMP')) 
        aAlias[nX]:SetValue("requirementCode"  ,oModel:getValue('BKWMASTER','BKW_CDOBRI'))
        aAlias[nX]:SetValue("operatorRecord"   ,oModel:getValue('BKWMASTER','BKW_CODOPE'))
        aAlias[nX]:SetValue("batchCode"        ,oModel:getValue('BKWMASTER','BKW_CODLOT'))
        aAlias[nX]:delLote()
        aAlias[nX]:destroy()
    next

Return

