#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico de atualização de configuração de artefatos
    @type  Function
    @author everton.mateus
    @since 29/07/2020
/*/
Main Function SvcAtuCfgArt(lJob)
    Default lJob := isBlind()
    If lJob
        StartJob("JobAtuCfgArt", GetEnvServer(), .F., cEmpAnt, cFilAnt, lJob)
    Else
        JobAtuCfgArt(cEmpAnt, cFilAnt,.F.)
    EndIf
return

Function JobAtuCfgArt(cEmp,cFil,lJob)
    Local oPrjCfgArt  := nil
    Local lBI8 := .F.
    Local lBI9 := .F.
    Local cOwnConf := MV_PAR01
    Default cEmp := "99"
    Default cFil := "01"
    Default lJob := isBlind()
    Default cOwnConf := ""

	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
    lBI8 := FWAliasInDic("BI8", .F.)
	lBI9 := FWAliasInDic("BI9", .F.)
	If lBI8 .AND. lBI9
        oPrjCfgArt := PrjCfgArt():New(cOwnConf)
        oPrjCfgArt:atualizaTabelas(oPrjCfgArt:getConfig())
        oPrjCfgArt:destroy()
        FreeObj(oPrjCfgArt)
        oPrjCfgArt := nil
        DelClassIntf()
    Else
        Conout("As tabelas BI8 e BI9 não existem, atualize seu dicionário de dados.")
    Endif
    
return

Static Function SchedDef()
Return { "P","",,{},""}