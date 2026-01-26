#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"


//-----------------------------------------------------------------
/*/{Protheus.doc} PLProcSchd
 Schedule para atualizar status das guias pendentes na Mensageria do Pro. Contas
 
@author PLS Team
@since 20240619
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLProcSchd()
    
    Local cCodOpe := MV_PAR01
    Local oMensageria := PLMensCont():New()

    // Trava para não executar o JOB se ja estiver em execucao
    lOk := LockByName('PLProcSchd' + cCodOpe,.T.,.F.)

    if lOk
        LogCabec(oMensageria,"Iniciando Job PLProcSchd")
        oMensageria:procContSchd() //Processa rotina
        oMensageria:destroy() //Mata objeto do processo        
        UnLockByName('PLProcSchd' + cCodOpe) //Libera semaforo
        
        oMensageria:impLog("")
        oMensageria:impLog("***** Finalizando JobPLProcSchd*****")
        Conout("***** Finalizando JobPLProcSchd *****")
    else 
        LogCabec(oMensageria,'Job PLProcSchd' + cCodOpe + ' - Já está em execução, aguarde o termino do processamento.')
    endIf

Return nil


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
 Schedule para job
 
@author PLS Team
@since 20240619
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSATU",,{},""}


//-------------------------------------------------------------------
/*/{Protheus.doc} LogCabec
Monta o cabecalho padrao do log HAT

@author PLS Team
@since 20240619
/*/
//-------------------------------------------------------------------
Static Function LogCabec(oMensageria,cMsg)

    Default cMsg     := ""

    oMensageria:impLog(Replicate("*",50),.F.)
    oMensageria:impLog(cMsg)
    oMensageria:impLog(Replicate("*",50),.F.)
    Conout(cMsg)

Return
