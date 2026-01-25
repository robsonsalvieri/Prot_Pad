#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVldLicSrv
Rotina para validação do License Server durante processo executado pelo 
Atualizador - TAF

@author Diego Santos
@since 20/09/2019
/*/
//-------------------------------------------------------------------
Main Function TAFVldLicSrv()

    Local cStartPath    := GetSrvProfString("StartPath", "\system\")
    Local cLicSrvVer    := FwLsGetVersion()
    Local oError        := ErrorBlock({ |e| LicDisarm(e) })
    Local cMsg          := ""
    Local cJson         := ""

    BEGIN SEQUENCE

        If File(cStartPath + "TAFLicVerOk.json")
            fErase(cStartPath + "TAFLicVerOk.json")
        EndIf

        If File(cStartPath + "TAFLicVerError.json")
            fErase(cStartPath + "TAFLicVerError.json")
        EndIf

        If AllTrim(cLicSrvVer) < "3.0.0"
            cFileStatus := "TAFLicVerOk.json"
            cMsg += "Constatamos que a versao do LS( License Server ) TOTVS de seu ambiente é inferior a versao 3.0.0" + CRLF
            cMsg += "a partir da próxima versão do atualizador do TAF é altamente recomendável que o ambiente esteja utilizando a versão 3.0.0 ou superior" + CRLF
            cMsg += ""
            // cFileStatus := "TAFLicVerError.json"
            // cMsg += "Constatamos que a versao do LS( License Server ) TOTVS " + CRLF
            // cMsg += "que esta utilizando e inferior a versao 3.0.0, " + CRLF
            // cMsg += "durante esse processo de atualizacao/instalacao o produto TAF sera migrado automaticamente para a release 12.1.27 " + CRLF
            // cMsg += "e para isso e necessario que o LS seja atualizado para a versao 3.0.0 ou superior. " + CRLF
            // cMsg += "Apos realizar essa atualizacao execute novamente o atualizador/instalador do TAF, este processo sera abortado."
        Else
            cFileStatus := "TAFLicVerOk.json"
            cMsg += "Versao do License Server ( "+cLicSrvVer+" ) compativel com o release 12.1.27"
        EndIf

        cJson += ' { "LicenseVersion" : "' + cLicSrvVer + '", '
        cJson += ' "Message": "' + StrTran(cMsg, CRLF, '') + '" } '

        Conout(OemToAnsi(cMsg))

        // Gera um arquivo, indicando a conclusão do processo.
        MemoWrite(cStartPath + cFileStatus, cJson)

    END SEQUENCE

    ErrorBlock(oError)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LicDisarm
"Disarma" a conversão

@author Diego Santos
@since 02/10/2019
/*/
//-------------------------------------------------------------------
Static Function LicDisarm(oErr)

    Default oErr    := Nil

    ConOut("Erro na verificacao da versao do License Server.")

    If oErr <> Nil
        ConOut("Description Fatal error: " + AllTrim(oErr:Description) )
        ConOut("ErrorEnv Fatal error: " + AllTrim(oErr:ErrorEnv) )
    EndIf

Return
