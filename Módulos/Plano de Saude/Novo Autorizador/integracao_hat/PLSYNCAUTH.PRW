#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "hatActions.ch"
#include "TBICONN.CH"

#define __NSLEEP 1000 * 50 //1000 um segundo x 10 = 10 segundo

/*/{Protheus.doc} PLSYNCAUTH
Main function responsavel pela integracao PLS x HAT - atendimentos
@author  pls
@version P12
@since    11/03/2021
/*/
main function PLSYNCAUTH()
    local cEnv      := getEnvServer()
    local cEmp      := allTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
    local cFil      := allTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
    local nH        := 0 
    local lContinua := .t.

    nModulo := 33 //SIGAPLS

    rpcSetType(3)
    rpcSetEnv(cEmp, cFil,,,'PLS','PLSYNCAUTH')

    nH := plsAbreSem("PLSYNCAUTH_" + cEmp + ".SMF")

    coNout("************** Iniciando Job PLSYNCAUTH **************")

    while ! killApp() .and. lContinua

        coNout('monitorando SYNC_AUTHORIZATIONS e SYNC_CANCELLATIONS ')

        if lContinua
            lContinua := PlsHatSync(SYNC_AUTHORIZATIONS)
        endIf

        if lContinua
            lContinua := PlsHatSync(SYNC_AUTHORIZATIONS + SYNC_CANCELLATIONS) 
        endIf

    sleep(__NSLEEP)
    endDo

    if ! lContinua 
        coNout("************** PLSYNCAUTH abortado com ERROS **************")
    endIf

    PLSFechaSem(nH, "PLSYNCAUTH_" + cEmp + ".SMF")
    RPCClearEnv()

return(nil)

/*/{Protheus.doc} PLSYNCLIAT
Main function responsavel pela integracao PLS x HAT - AnexosClinicos
@author  pls
@version P12
@since    11/03/2021
/*/
main function PLSYNCLIAT()
    local cEnv      := getEnvServer()
    local cEmp      := allTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
    local cFil      := allTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
    local nH        := 0 
    local lContinua := .t.

    nModulo := 33 //SIGAPLS

    rpcSetType(3)
    rpcSetEnv(cEmp, cFil,,,'PLS','PLSYNCLIAT')

    nH := plsAbreSem("PLSYNCLIAT_" + cEmp + ".SMF")

    coNout("************** Iniciando Job PLSYNCLIAT **************")

    while ! killApp() .and. lContinua

        coNout('monitorando SYNC_CLINICAL_ATTACHMENTS e SYNC_CANCELLATIONS ')

        if lContinua
            lContinua := PlsHatSync(SYNC_CLINICAL_ATTACHMENTS) //Sincroniza os anexos clinicos do HAT
        endIf

        if lContinua
            lContinua := PlsHatSync(SYNC_CLINICAL_ATTACHMENTS + SYNC_CANCELLATIONS) //Sincroniza os anexos clinicos do HAT
        endIf

    sleep(__NSLEEP)
    endDo

    if ! lContinua 
        coNout("************** PLSYNCLIAT abortado com ERROS **************")
    endIf

    PLSFechaSem(nH, "PLSYNCLIAT_" + cEmp + ".SMF")
    RPCClearEnv()

return(nil)

/*/{Protheus.doc} PLSYNCTREX
Main function responsavel pela integracao PLS x HAT - Prorrogacao
@author  pls
@version P12
@since    11/03/2021
/*/
main function PLSYNCTREX()
    local cEnv      := getEnvServer()
    local cEmp      := allTrim(GetPvProfString(cEnv,"JEMP","",GetADV97()))
    local cFil      := allTrim(GetPvProfString(cEnv,"JFIL","",GetADV97()))
    local nH        := 0 
    local lContinua := .t.

    nModulo := 33 //SIGAPLS

    rpcSetType(3)  
    rpcSetEnv(cEmp, cFil,,,'PLS','PLSYNCTREX')

    nH := plsAbreSem("PLSYNCTREX_" + cEmp + ".SMF")

    coNout("************** Iniciando Job PLSYNCTREX **************")

    while ! killApp() .and. lContinua
        
        coNout('monitorando SYNC_TREATMENT_EXTENSIONS e SYNC_CANCELLATIONS ')

        if lContinua
            lContinua := PlsHatSync(SYNC_TREATMENT_EXTENSIONS) //Sincroniza guias de prorrogacao de internacao do HAT
        endIf

        if lContinua
            lContinua := PlsHatSync(SYNC_TREATMENT_EXTENSIONS + SYNC_CANCELLATIONS) //Sincroniza guias de prorrogacao de internacao do HAT
        endIf

    sleep(__NSLEEP)
    endDo

    if ! lContinua 
        coNout("************** PLSYNCTREX abortado com ERROS **************")
    endIf

    PLSFechaSem(nH, "PLSYNCTREX_" + cEmp + ".SMF")
    RPCClearEnv()

return(nil) 