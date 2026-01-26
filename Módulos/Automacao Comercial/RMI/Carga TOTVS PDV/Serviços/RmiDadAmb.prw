#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} RmiDadAmb
Função que faz a chaamda da rotina RmiDadAmbi
@type  Function
@author joao.marcos
@since 04/12/2024
@version v1.0
@param cPontoCarg, character, codigo do Ponto de Carga
        aConfig, array, dados de configuração do Assinante
/*/
Function RmiDadAmb(cPontoCarg, aConfig)

Default cPontoCarg  := MV_PAR01
Default aConfig     := RMICfgAss()

Pergunte("RMIDADAMB",.T.)

RmiDadAmbi(cEmpAnt, cFilAnt, cPontoCarg, aConfig)

Return

/*/{Protheus.doc} RMICfgAss
Resgata os dados de configuração do Assinante TOTVS PDV
@type  Static Function
@author joao.marcos
@since 04/12/2024
@version v1.0
@return aRet, array,  dados de configuraçao do Assinante
/*/
Function RMICfgAss()
Local aRet          := Array(6)
Local jConfig       := JsonObject():New()

MHO->(dbSetOrder(1)) // MHO_FILIAL+MHO_COD

If MHO->(dbSeek(xFilial("MHO") + PadR("TOTVS PDV",TamSx3("MHO_COD")[1]," "))) .AND. !Empty(MHO->MHO_CONFIG)

    jConfig:FromJson(MHO->MHO_CONFIG)
    aRet[1] := jConfig["access_token"]
    aRet[2] := jConfig["refresh_token"]
    aRet[3] := AllTrim(jConfig["usuario"])
    aRet[4] := AllTrim(Rc4Crypt(jConfig["senha"], "0123456789*!@#$%&", .F., .T.))
    aRet[5] := jConfig["endpoint"]
    aRet[6] := jConfig["dadosambiente"]

Else
    cMsgErro    := "Não foi realizado a configuração do Assiante TOTVS PDV, não sera possivel a execução da rotina!"
    LjGrvLog(cThread, "RmiDadAmbi - GetConfigAss ", cMsgErro )
EndIf

FwFreeObj(jConfig)
jConfig := Nil

Return aRet

/*/{Protheus.doc} SchedDef
Funçao obrigatoria para rotinas que serao executadas via Schedule
@type  Static Function
@author joao.marcos
@since 04/12/2024
@version v1.0
/*/
Static Function SchedDef()

Local aParam  := {}

aParam := { "P"                 ,;  //Tipo R para relatorio P para processo
            "RMIDADAMB"        ,;  //Pergunte do relatorio, caso nao use passar ParamDef
            /*Alias*/           ,;	
            /*Array de ordens*/ ,;
            /*Titulo*/          }

Return aParam
