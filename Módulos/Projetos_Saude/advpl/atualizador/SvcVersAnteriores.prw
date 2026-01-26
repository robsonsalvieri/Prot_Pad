#INCLUDE "TOTVS.CH"

Main Function SvcVersAnteriores(oPrjArtefato)
return PrjAtuVerAnt(oPrjArtefato)

Function PrjAtuVerAnt(oPrjArtefato)

    Local lSucesso  := .F.
    Local lBI8 := FWAliasInDic("BI8", .F.)
	Local lBI9 := FWAliasInDic("BI9", .F.)
	If lBI8 .AND. lBI9
        Default oPrjArtefato :=  PrjArtefato():New(BI9->BI9_CODIGO,allTrim(BI9->BI9_VERDIS))

        If oPrjArtefato:IniciaProcesso()
            
            If oPrjArtefato:downAndSave() .And. oPrjArtefato:verifAtivo()
                lSucesso := .T.
                If !Empty(oPrjArtefato:cRotina)
                    lSucesso := oPrjArtefato:lancaRotina()
                Endif
            Else
                lSucesso  := .F. 
            EndIf

            If !isBlind()
                If Empty(oPrjArtefato:getErro()) .And. lSucesso
                    oPrjArtefato:sucessoAtualizacao()
                    MsgInfo("Artefato: " + oPrjArtefato:cCodigo + " Versão: " + oPrjArtefato:cVersion + " atualizado com sucesso!")
                Else
                    oPrjArtefato:falhaAtualizacao()
                    MsgAlert(oPrjArtefato:getErro())
                EndIf
            EndIf

            oPrjArtefato:FinalizaProcesso()

        Else
        
            oPrjArtefato:falhaAtualizacao()
            If !isBlind()
                MsgAlert(oPrjArtefato:getErro())
            EndIf

        Endif

        oPrjArtefato:destroy()
        FreeObj(oPrjArtefato)
        oPrjArtefato := nil
    Else
        MsgAlert("As tabelas BI8 e BI9 não existem, atualize seu dicionário de dados.")
    EndIf

Return lSucesso

Function PrjAtuManual (oPrjArtefato,cOrigem)
    Default cOrigem := "BI8" 
    If cOrigem == "BI8" 
        Default oPrjArtefato := PrjArtefato():New(BI8->BI8_CODIGO,allTrim(BI8->BI8_ULTVER))
    Else
        Default oPrjArtefato := PrjArtefato():New(BI9->BI9_CODIGO,allTrim(BI9->BI9_VERDIS))
    Endif

    If oPrjArtefato:IniciaProcesso()
        If oPrjArtefato:SaveManual() .And. oPrjArtefato:verifAtivo()
            lSucesso := .T.
            If !Empty(oPrjArtefato:cRotina)
                lSucesso := oPrjArtefato:lancaRotina()
            Endif
        Else
			lSucesso  := .F. 
        EndIf

        If !isBlind()
            If Empty(oPrjArtefato:getErro()) .And. lSucesso
                oPrjArtefato:sucessoAtualizacao()
                MsgInfo("Artefato: " + oPrjArtefato:cCodigo + " Versão: " + oPrjArtefato:cVersion + " atualizado com sucesso!")
            Else
				oPrjArtefato:falhaAtualizacao()
                MsgAlert("Não foi possível realizar a importação manualmente." + Chr(13) + Chr(10) + "Houve a seguinte falha no processo: " + Chr(13) + Chr(10) + oPrjArtefato:getErro())
            EndIf
        EndIf

        oPrjArtefato:FinalizaProcesso()

    Else
		oPrjArtefato:falhaAtualizacao() 
        If !isBlind()                  
            MsgAlert(oPrjArtefato:getErro()) 
        EndIf
    Endif

    oPrjArtefato:destroy()
    FreeObj(oPrjArtefato)
    oPrjArtefato := nil 

Return