#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} PlAudCarSC
 Chamada do processo de consulta a Carol via Job
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLAUDCARSC()

    Local cCodOpe   := MV_PAR01
    Local oCarol    := PLAudCarol():New(cCodOpe)

    oCarol:impLog(Replicate('*',50),.F.)
    oCarol:impLog('Iniciando Job PLAUDCARSC')
    oCarol:impLog(Replicate('*',50),.F.)
    Conout("Iniciando Job PLAUDCARSC.")

    BA0->(DbSetOrder(1))
    if empty(cCodOpe)
        oCarol:impLog('Nao foi informada a Operadora nos parametros da rotina.')
        Conout( 'Nao foi informada a Operadora nos parametros da rotina' ,, .F. )     
        Return nil

    elseif !BA0->(DbSeek(xFilial('BA0')+cCodOpe))
        oCarol:impLog('A Operadora informada nao foi encontrada no sistema.')
        Conout( 'A Operadora informada nao foi encontrada no sistema.' ,, .F. )     
        Return nil
    endif

    // Trava para não executar o JOB se ja estiver em execucao
    if !MayIUseCode( 'PLAUDCARSC' + cCodOpe )
        oCarol:impLog('Job PLAUDCARSC' + cCodOpe + ' - Já está em execução, aguarde o termino do processamento.')
        Conout( 'Job PLAUDCARSC' + cCodOpe + ' - Já está em execução, aguarde o termino do processamento.' ,, .F. ) 
        Return nil
    endIf

    //Processa rotina
    oCarol:startInteg()

    //Logs de finalizacao
    oCarol:impLog(Replicate('*',50),.F.)
    oCarol:impLog('Finalizando Job PLAUDCARSC')
    oCarol:impLog(Replicate('*',50),.F.)
    oCarol:impLog('',.F.)
    Conout("Finalizando Job PLAUDCARSC.")

    //Libera semaforo
    FreeUsedCode()

Return(Nil)

//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
 Schedule para job
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return { "P","PLSATU",,{},""}