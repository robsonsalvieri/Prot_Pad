#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE NLOCKJOB2 03
#DEFINE NLOCKJOB4 07
#DEFINE NLOCKJOB5 11

#DEFINE NTRY2 04
#DEFINE NTRY4 08
#DEFINE NTRY5 12

#DEFINE NTHREAD_LOCK2 05
#DEFINE NTHREAD_LOCK4 09
#DEFINE NTHREAD_LOCK5 13

#DEFINE NEXEC_JOB2 06
#DEFINE NEXEC_JOB4 10
#DEFINE NEXEC_JOB5 14

#DEFINE NMAXTRY 15

Static __oQuery 	:= Nil 
Static __cBanco		:= Nil
Static __cLibVer	:= Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFSCHED2
Processo de Integração TAFST2 x TAF via Schedule Dinamico

@param aParam - Informações da API de Schedule
                [1] - Grupo
                [2] - Filial 
                [3] - Cadastro do Job
                [4] - ????

ATENÇÃO: caso seja necessário criar parâmetros para esta rotina, tomar
cuidado por que a API sempre passa os 4 parâmetros destacados acima
após o ultimo parametro declado pelo desenvolvedor.

@return Nil 

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFSCHED2(aParam)

    Local cGrpJob := ""

    //Tomar cuidado por que o  schedule passa as informacoes de empresa/filial/cadastro do job etc, a partir da ultima posicao de parametro 
    //informado pelo usuario .. hoje a rotina só tem 1 parametro, se for necessário criar novos parametros a posiçao do grupo de empresa
    //que hoje está no aParam[2] vai ser deslocada para frente...
    cGrpJob := aParam[1]
    TAFDinamicJOB(2,cGrpJob)

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFSCHED4
Processo de Transmissão para o TSS via Schedule Dinamico

@param aParam - Informações da API de Schedule
                [1] - Grupo
                [2] - Filial 
                [3] - Cadastro do Job
                [4] - ????

ATENÇÃO: caso seja necessário criar parâmetros para esta rotina, tomar
cuidado por que a API sempre passa os 4 parâmetros destacados acima
após o ultimo parametro declado pelo desenvolvedor.

@return Nil 

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFSCHED4(aParam)

    Local cGrpJob := ""
    Local cEventos := ""
    
    If Len(aParam) > 4 
        GetEventos(aParam[1],aParam[2],@cEventos) //GRUPO DE EMPRESA,CÓDIGO DO GRUPO DE EVENTOS
	EndIf
    //Tomar cuidado por que o  schedule passa as informacoes de empresa/filial/cadastro do job etc, a partir da ultima posicao de parametro 
    //informado pelo usuario .. hoje a rotina só tem 1 parametro, se for necessário criar novos parametros a posiçao do grupo de empresa
    //que hoje está no aParam[2] vai ser deslocada para frente...
    cGrpJob := aParam[1]

    TAFDinamicJOB(4,cGrpJob,cEventos)

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFSCHED5
Processo de Consulta para o TSS via Schedule Dinamico

@param aParam - Informações da API de Schedule
                [1] - Grupo
                [2] - Filial 
                [3] - Cadastro do Job
                [4] - ????

ATENÇÃO: caso seja necessário criar parâmetros para esta rotina, tomar
cuidado por que a API sempre passa os 4 parâmetros destacados acima
após o ultimo parametro declado pelo desenvolvedor.

@return Nil 

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFSCHED5(aParam)

    Local cGrpJob := ""

    //Tomar cuidado por que o  schedule passa as informacoes de empresa/filial/cadastro do job etc, a partir da ultima posicao de parametro 
    //informado pelo usuario .. hoje a rotina só tem 1 parametro, se for necessário criar novos parametros a posiçao do grupo de empresa
    //que hoje está no aParam[2] vai ser deslocada para frente...
    cGrpJob := aParam[1]
    TAFDinamicJOB(5,cGrpJob)

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFDinamicJOB

Esta rotina realizado os processo de Integração, Transmissão e Consulta de 
forma dinâmica (somente quando há dados para integrar, transmitir ou consultar).

@param nJob - Numero do Processo a ser executado 
@param cGrpJob - Codigo do Grupo de Empresas que o Schedule está executando.

@return Nil 

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDinamicJOB(nJob,cGrpJob,cEventos)

    Local cUUID         := ''
    Local cKeyGroups    := ''
    Local cLockLicense  := ''
    Local cStsTransm    := ''
    Local aEmps         := {}
    Local nX            := 0 
    Local nPosFil       := 0
    Local nIndLock      := 0 //Indice do array que se deve realizar o lock
    Local nIndEmp       := 1
    Local nIndIdThread  := 0
    Local nIndExecCall  := 0
    Local lExecute      := .F.  
    Local cKeyGrp       := ""
    Local cKeyCallP2    := ""
    Local cKeyCallP4    := ""
    Local cKeyCallP5    := ""
    Local aFilsExec     := {}
    Default cEventos    := ""
    cUUID         := 'IDJOBINT'
    cKeyGroups    := 'keyEmps'
    cKeyCallP2    := 'keyJob2Call'
    cKeyCallP4    := 'keyJob4Call'
    cKeyCallP5    := 'keyJob5Call'

    If Substr(GetRpoRelease(),1,2) == '12'

        TafConOut('Preparando ambiente. Grupo: ' + cGrpJob + '. Processo ' + cValToChar(nJob))
        RpcSetType(3)
        RpcSetEnv(cGrpJob,,,,"TAF","TAFDINAMICJOB",,,,.T.,)
        TafConOut('Ambiente preparado. Grupo : ' + cGrpJob + '. Processo ' + cValToChar(nJob))

        IF !isTAFinCloud()
            cStsTransm := SuperGetMv('MV_TAFSTRS',.F.,"' ','0','1'") 
            If At('"',cStsTransm) > 0
                cStsTransm := StrTran(cStsTransm,'"',"'")
            EndIf 
        Else
            cStsTransm := "' ','0','1'"
        EndIf

        If VarSetUID(cUUID) 
            TafConOut("Criando Secao para cache de filiais ...")

            If VarBeginT(cUUID, cKeyGroups)
                //Sobe as filias na chave cKeyGroups
                loadBranches(cUUID,cKeyGroups,cKeyCallP2,cKeyCallP4,cKeyCallP5)
            EndIf
        EndIf 
        
        Do Case 
            Case nJob == 2

                cLockLicense    := 'lockJDin2'
                nIndLock        := NLOCKJOB2
                nIndTry         := NTRY2
                nIndIdThread    := NTHREAD_LOCK2
                nIndExecCall    := NEXEC_JOB2

                flagCallJob(cUUID,cKeyCallP2,cGrpJob) 
            Case nJob == 4 

                cLockLicense    := 'lockJDin4'
                nIndLock        := NLOCKJOB4
                nIndTry         := NTRY4
                nIndIdThread    := NTHREAD_LOCK4
                nIndExecCall    := NEXEC_JOB4

                flagCallJob(cUUID,cKeyCallP4,cGrpJob) 
            Case nJob == 5 

                cLockLicense    := 'lockJDin5'
                nIndLock        := NLOCKJOB5
                nIndTry         := NTRY5
                nIndIdThread    := NTHREAD_LOCK5
                nIndExecCall    := NEXEC_JOB5

                flagCallJob(cUUID,cKeyCallP5,cGrpJob) 
        EndCase

        cKeyGrp := cKeyGroups + "_" + cGrpJob

        VarGetAD(cUUID,cKeyGrp,@aEmps)

        If nJob == 2
            aFilsExec := getFil4Proc()
            nIndEmp := 1
        Else 
            If nJob == 4 .And. !Empty(cEventos)
                TafConOut('Processo de Transmissão - Grupo de Eventos Ativo. Eventos: ' + cEventos)
            EndIf 
            aFilsExec := getFil4RET(nJob,cStsTransm,aEmps,cGrpJob,cEventos)
            nIndEmp := 2
        EndIf 

        For nX := 1 To Len(aFilsExec)

            nPosFil := aScan(aEmps,{|cFil|AllTrim(cFil[nIndEmp]) == AllTrim(aFilsExec[nX])})

            If nPosFil > 0

                lExecute := lockFilial(cLockLicense,cUUID,cKeyGrp,nPosFil,nIndLock,nIndTry,nIndIdThread,nIndExecCall)

                If lExecute

                    cFilAnt := PADR(AllTrim(aEmps[nPosFil][2]),FWSizeFilial())
                    SM0->(MsSeek(FWGrpCompany()+cFilAnt))
                    executaProc(nJob,cUUID,cKeyGrp,nPosFil,nIndLock,nIndTry,nIndIdThread,nIndExecCall,cEventos)
                EndIf 
                
                lExecute := .F.
            EndIf 
        Next nX 

        showSummary(cUUID,cKeyCallP2,cKeyCallP4,cKeyCallP5,cGrpJob,cKeyGrp,aFilsExec,nJob)

        aSize(aFilsExec,0)
        RpcClearEnv()

    Else
        TafConOut("Essa Funcionalidade só está disponivel para a versão 12 do Protheus. ")
    EndIf 


Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} loadBranches

Carrega as informações das Empresas/Filiais considerando as informações
contidas no SM0 e na C1E 

@param cUUID - Secao das variavies globais
@param cKeyGroups - Chave utilizada para o carregamento das filiais 

*** Valores contidos na coluna A da chave cKeyGroups:

aEmpresas[n][1]         - Codigo do Grupo de Empresas
aEmpresas[n][2]         - Array com as Filiais pertencentes ao Grupo
aEmpresas[n][2][x][1]   - Codigo da Filial do ERP
aEmpresas[n][2][x][2]   - Codigo da Filial do TAF

aEmpresas[n][2][x][3]   - Semaforo de execução do Job2
aEmpresas[n][2][x][4]   - Numero de vezes que alguma thread tentou chamar a rotina Job 2 e a mesma estava em uso.
aEmpresas[n][2][x][5]   - Numero da Thread que está executando a rotina Job 2.
aEmpresas[n][2][x][6]   - Numero de execuções do Processo Job 2

aEmpresas[n][2][x][7]   - Semaforo de execução do Job4
aEmpresas[n][2][x][8]   - Numero da Thread que está executando a rotina Job 4.
aEmpresas[n][2][x][9]   - Numero de vezes que alguma thread tentou chamar a rotina Job 4 e a mesma estava em uso.
aEmpresas[n][2][x][10]  - Numero de execuções do Processo Job 4

aEmpresas[n][2][x][11]  - Semaforo de execução do Job5
aEmpresas[n][2][x][12]  - Numero da Thread que está executando a rotina Job 5.
aEmpresas[n][2][x][13]  - Numero de vezes que alguma thread tentou chamar a rotina Job 5 e a mesma estava em uso.
aEmpresas[n][2][x][14]  - Numero de execuções do Processo Job 5


@return Nil 
@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function loadBranches(cUUID,cKeyGroups,cKeyCallP2,cKeyCallP4,cKeyCallP5)

    Local aEmpresas := {}
    Local aAllEmps  := {}
    Local aAreaSM0  := {}
    Local nX := 0
    Local nY := 0
    Local cGrpJob := ""
    Local cFilJob := ""
    
    TAFGetDePara(cUUID,cKeyGroups,.T.,.T.)
    VarGetAD(cUUID,cKeyGroups,@aEmpresas)

    aAreaSM0 := SM0->(GetArea())
    
    For nX := 1 To Len(aEmpresas)

        cGrpJob := AllTrim(aEmpresas[nX][1])
        
        VarSetXD(cUUID,cKeyCallP2 + "_" + cGrpJob ,0)
        VarSetXD(cUUID,cKeyCallP4 + "_" + cGrpJob ,0) 
        VarSetXD(cUUID,cKeyCallP5 + "_" + cGrpJob ,0) 

        For nY := 1 To Len(aEmpresas[nX][2])

            cFilJob := AllTrim(aEmpresas[nX][2][nY][2])

            If SM0->(MsSeek(cGrpJob+cFilJob))

                aSize(aEmpresas[nX][2][nY],14)  

                aEmpresas[nX][2][nY][NLOCKJOB2]         := .F. //Processo 2
                aEmpresas[nX][2][nY][NTRY2]             := 0   //numero de verificacoes Job2
                aEmpresas[nX][2][nY][NTHREAD_LOCK2]     := 0   //Numero da thread que foi efetuado o lock
                aEmpresas[nX][2][nY][NEXEC_JOB2]        := 0   //Numero de execuções do Processo Job 2

                aEmpresas[nX][2][nY][NLOCKJOB4]         := .F. //Processo 4
                aEmpresas[nX][2][nY][NTRY4]             := 0   //numero de verificacoes Job4
                aEmpresas[nX][2][nY][NTHREAD_LOCK4]     := 0   //Numero da thread que foi efetuado o lock
                aEmpresas[nX][2][nY][NEXEC_JOB4]        := 0   //Numero de execuções do Processo Job 4

                aEmpresas[nX][2][nY][NLOCKJOB5]         := .F. //Processo 5
                aEmpresas[nX][2][nY][NTRY5]             := 0   //numero de verificacoes Job5
                aEmpresas[nX][2][nY][NTHREAD_LOCK5]     := 0   ////Numero da thread que foi efetuado o lock
                aEmpresas[nX][2][nY][NEXEC_JOB5]        := 0   //Numero de execuções do Processo Job 5

                aAdd(aAllEmps,aEmpresas[nX][2][nY])
            Else
                TafConout("Filial " + cFilJob + " cadastrada na tabela C1E e apagada no arquivo de empresas (SM0).")
            EndIf

        Next nY

        VarSetAD(cUUID,cKeyGroups + "_" + aEmpresas[nX][1],aClone(aAllEmps)) 
        aSize(aAllEmps,0)     

    Next nX

    If VarEndT(cUUID,cKeyGroups)
        VarDel(cUUID,cKeyGroups)
    EndIf 

    RestArea(aAreaSM0)

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} lockFilial

Realiza o Lock do impedindo que seja executado a mesma rotina quando a filial
já estiver em processo.

@param cLockLicense - Semaforo para controle de acesso exclusivo ao array
de controle dos processos.
@param cUUID    - Secao das variavies globais
@param cKeyGrp  - Chave utilizada para o carregamento das filiais do grupo
@param nPosFil  - Posição da filial (dentro do array aEmpresas*)
@param nIndLock - Posição do array correspondente ao lock processo 
(dentro do array aEmpresas*)
@param nIndTry  - Posição do array correspondente ao numero de tentativas 
de processo (dentro do array aEmpresas*)
@param nIndIdThread - Posição do array correspondente ao numero da thread 
que foi realizado o bloquei em nIndLock (dentro do array aEmpresas*)

*(carregado através chave cKeyGrp)

@return lLock - Retorna se foi possivel realizar o lock no processo 

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function lockFilial(cLockLicense,cUUID,cKeyGrp,nPosFil,nIndLock,nIndTry,nIndIdThread,nIndExecCall)

    Local lLock     := .F.
    Local nTry      := 0
    Local cFil      := ''
    Local nIdThread := 0
    Local aEmpresas := {}

    
    //Fica rodando até que a thread que fez o lock primeiro libere o semaforo
    //Isso garante que 2 threads nao executem a mesma filial.
    While !LockByName(cLockLicense,.T.,.F.)
        nTry++
        TafConOut("Aguardando liberação do semaforo - Lock Filial. Tentativa: " + cValToChar(nTry))
        Sleep(500)
        //Se chegar em 50 tentivas, a rotina considera que o lock ficou preso no license
        If nTry == 50
            UnLockByName(cLockLicense ,.T.,.F.)
        EndIf 
    EndDo

    VarGetAD(cUUID,cKeyGrp,@aEmpresas)

    If aEmpresas[nPosFil][nIndLock] 

        TafConOut(aEmpresas[nPosFil][1] + " in process - Skip IndLock : " + cValToChar(nIndLock) )
        aEmpresas[nPosFil][nIndTry]++

        cFil := aEmpresas[nPosFil][2]
        nIdThread := aEmpresas[nPosFil][nIndIdThread]
        //Verifica se ha atividade de processamento na Filial
        //Se nao houver permito que a thread atual faça o lock
        
        If aEmpresas[nPosFil][nIndTry] == NMAXTRY
            If !checkActivity(nIdThread)
                TafConOut('Verificacao de Processamento. Filial ' + cFil + ' INATIVA, semaforo liberado por inativadade. ')
                lLock := .T.
            EndIf 
            aEmpresas[nPosFil][nIndTry] := 0
        EndIf 
        
    Else

        //Efetua o Lock
        aEmpresas[nPosFil][nIndLock]        := .T.
        aEmpresas[nPosFil][nIndTry]         := 0
        aEmpresas[nPosFil][nIndIdThread]    := ThreadID()
        aEmpresas[nPosFil][nIndExecCall]++
        lLock := .T.
    EndIf

    VarSetAD(cUUID,cKeyGrp,aEmpresas)
    UnLockByName(cLockLicense ,.T.,.F.)

Return lLock 

//--------------------------------------------------------------------
/*/{Protheus.doc} unLockFilial

Retira o lock da filial.


@param cUUID    - Secao das variavies globais
@param cKeyGrp  - Chave utilizada para o carregamento das filiais do grupo
@param nPosFil  - Posição da filial (dentro do array aEmpresas*)
@param nIndLock - Posição do array correspondente ao lock processo 
(dentro do array aEmpresas*)
@param nIndTry  - Posição do array correspondente ao numero de tentativas 
de processo (dentro do array aEmpresas*)
@param nIndIdThread - Posição do array correspondente ao numero da thread 
que foi realizado o bloquei em nIndLock (dentro do array aEmpresas*)

*(carregado através chave cKeyGrp)

@return Nil

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function unLockFilial(cUUID,cKeyGrp,nPosFil,nIndLock,nIndIdThread)

    Local aEmpresas := {}

    VarGetAD(cUUID,cKeyGrp,@aEmpresas)
    aEmpresas[nPosFil][nIndLock] := .F.
    aEmpresas[nPosFil][nIndIdThread] := 0
    VarSetAD(cUUID,cKeyGrp,aEmpresas)

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} getFil4Proc

Retorna as filiais que possuem registros a processar (job2).

@return aFiliais - Array com as filiais (Codigo do ERP)

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function getFil4Proc()

    Local aFiliais := {}
    Local cSql := ""


    cSql := " SELECT TAFFIL "
    cSql += " FROM TAFST2 TAFST2 "
    cSql += " WHERE TAFST2.D_E_L_E_T_ = ' ' "
    cSql += " AND TAFST2.TAFSTATUS = '1' "
    cSql += " AND TAFST2.TAFIDTHRD = ' ' "
    cSql += " GROUP BY TAFFIL "

    TCQuery cSql New Alias 'rsFiliais'

    rsFiliais->(dbEval(  {||aAdd(aFiliais,rsFiliais->TAFFIL)}, {||!Empty(rsFiliais->TAFFIL)}  ))
    rsFiliais->(dbCloseArea())

Return aFiliais

//--------------------------------------------------------------------
/*/{Protheus.doc} getFil4RET

Retorna as filiais que possuem registros a transmitir ou a consultar (RET)

@param nJob - numero do processo (4-transmissao, 5-Consulta)
@param cStsTransm - Status que seram utilizados para identificar os registros
que devem ser transmitidos.
@param aEmpresas - Array com os codigos das Filiais
@param cGrpJob - Codigo do Grupo de Empresas
@param cEventos - Eventos que devem ser considerados para a transmissão

@return aFiliais - Array com as filiais (Codigo do ERP)

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function getFil4RET(nJob as numeric, cStsTransm as character, aEmpresas as array, cGrpJob as character, cEventos as character)

    Local nX                 as numeric
    Local nEmp               as numeric
    Local nPosFil            as numeric
    Local cSql               as character
    Local cQryAlias          as character
    Local cAliasEvt          as character
    Local cFilEvt            as character
    Local cFilProc           as character
    Local cTipoEvt           as character
    Local cBranchField       as character
    Local cTableFullName     as character
    Local cLog               as character
    Local lUseFwExec         as logical
    Local lOracleDB          as logical
    Local aEvtEsocial        as array
    Local aFiliais           as array
    Local aAreaSM0           as array
    Local aFwExecFieldValues as array

    Default cEventos   := ""

    nX                 := 0
    nEmp               := 0
    nPosFil            := 0
    cBranchField       := ""
    cQryAlias          := "rsFiliais"
    cSql               := ""
    cAliasEvt          := ""
    cFilEvt            := ""
    cFilProc           := ""
    cTipoEvt           := ""
    cTableFullName     := ""
    cLog               := ""
    lUseFwExec         := .T.
    lOracleDB          := .F.
    aEvtEsocial        := {}
    aFiliais           := {}
    aAreaSM0           := {}
    aFwExecFieldValues := {}

    If __cLibVer == Nil
		__cLibVer := FwLibVersion()

        If FindFunction("TAFisBDLegacy") .And. TAFisBDLegacy()
            __cLibVer := "20020101" // Força o sistema a não executar a FwExecStatement.
        EndIf 
	EndIf  
    
    If __cBanco == Nil
        __cBanco := TCGetDB()
    EndIf

    If __cLibVer < "20211116" 
        lUseFwExec  := .F.
    EndIf    

    If __cBanco == "ORACLE"
        lOracleDB := .T.
    EndIf

    aEvtEsocial := TAFRotinas(,,.T.,2)
    cGrpJob     := AllTrim(cGrpJob)
    aAreaSM0    := SM0->(GetArea())

    TafConOut('Verificando registros pendentes de retorno (TSS). ThreadId: ' + cValToChar(ThreadID()))

    For nEmp := 1 To Len(aEmpresas)

        cFilProc := AllTrim(aEmpresas[nEmp][2])
        If SM0->(MsSeek(cGrpJob+cFilProc)) 

            cSql := ''

            For nX := 1 To Len(aEvtEsocial)

                If !Empty(cEventos)
                    If !(aEvtEsocial[nX][4] $ cEventos)
                        Loop
                    EndIf 
                EndIf 

                cAliasEvt := AllTrim(aEvtEsocial[nX][3])

                If cAliasEvt == "C1E"
                    cBranchField    := "C1E_FILTAF"
                    cFilEvt         := AllTrim(aEmpresas[nEmp][2])
                Else
                    cBranchField    := cAliasEvt + "_FILIAL"
                    cFilEvt         := xFilial(cAliasEvt,aEmpresas[nEmp][2])
                EndIf
                
                cTipoEvt  := AllTrim(aEvtEsocial[nX][12])

                If cTipoEvt != 'T' .And. TAFAlsInDic(cAliasEvt)     

                    If !Empty(cSql)
                        cSql += " UNION ALL "    
                    EndIf 

                    cSql += " SELECT "
                    cTableFullName  := RetSqlName(cAliasEvt)

                    If lOracleDB .And. !Empty(aEvtEsocial[nX][21])
                        cSql += " /*+ INDEX(" + cTableFullName + " " + cTableFullName + aEvtEsocial[nX][21] + ") */ "  
                    EndIf

                    cSql += " '"  + cFilEvt     + "' FILIAL "
                    cSql += " ,'" + cAliasEvt   + "' EVENTO "
                    cSql += " ,"  + cAliasEvt   + "_STATUS STATUS"
                    cSql += " , R_E_C_N_O_  RECNO "
                    cSql += " FROM  "   + cTableFullName  
                    cSql += " WHERE " 
                    cSql += " " + cBranchField + " = " + "'" + cFilEvt + "'"
                    cSql += " AND " + cAliasEvt + "_ATIVO = '1' " 

                    If cAliasEvt == "C9V"
                        cSql += " AND C9V_NOMEVE != 'TAUTO' "
                    EndIf

                    cSql += " AND "

                    If nJob == 5 
                        cSql += cAliasEvt + "_STATUS = '2' " 
                    Else
                        cSql += cAliasEvt + "_STATUS IN (" + cStsTransm + ")" 
                    EndIf 

                    cSql += " AND D_E_L_E_T_ = ' ' "

                EndIf 

            Next nX 

            If lUseFwExec
                cSql		:= ChangeQuery(cSql)
				__oQuery 	:= FwExecStatement():New(cSql)          

                cQryAlias   := __oQuery:OpenAlias()
            Else
                TCQuery cSql New Alias (cQryAlias)
            EndIf

            //O objetivo desta query é verificar se existe algum evento pendente de 
            //transmissão ou consulta para a filial em questão.
            If (cQryAlias)->(!Eof())

                If Len(aFiliais) > 0

                    nPosFil := aScan(aFiliais,{|xFil|AllTrim(xFil) == cFilProc})
                    If nPosFil == 0 
                        aAdd(aFiliais,cFilProc)
                    EndIf 
                Else

                    aAdd(aFiliais,cFilProc)
                EndIf 

                cLog := CRLF + "Processo " + cValToChar(nJob) + " - Filial: " + cFilProc  + " eventos encontrados: " + CRLF + CRLF
            EndIf 

            While (cQryAlias)->(!Eof())
            
                cLog += " Evento: " + (cQryAlias)->EVENTO + CRLF
                cLog += " Status: " + cValToChar((cQryAlias)->STATUS) + CRLF
                cLog += " RecNo:"   + cValToChar((cQryAlias)->RECNO) + CRLF + CRLF
                (cQryAlias)->(dbSkip())
            EndDo

            If !Empty(cLog)
                TafConOut(cLog)
            EndIf

            (cQryAlias)->(dbCloseArea())
        Else
            TafConOut('Filial ' + aEmpresas[nEmp][2] + ' nao posicionada.')
        EndIf
    Next nEmp

    RestArea(aAreaSM0)

    If Len(aFiliais) > 0
        TafConout('Localizados registros pendentes de Consulta em ' + cValToChar(Len(aFiliais)) + " - ThreadId: " + cValToChar(ThreadID()))    
    Else
        TafConOut('Nao ha registros pendentes de Consulta (TSS) ThreadId: ' + cValToChar(ThreadID()))
    EndIf 
    
Return aFiliais 

//--------------------------------------------------------------------
/*/{Protheus.doc} executaProc

Realiza a chamada das rotinas de processamento.

@param nJob     - numero do processo (2-Integração, 4-transmissao, 5-Consulta)
@param cUUID    - Secao das variavies globais
@param cKeyGrp  - Chave utilizada para o carregamento das filiais do grupo
@param nPosFil  - Posição da filial (dentro do array aEmpresas*)
@param nIndLock - Posição do array correspondente ao lock processo 
(dentro do array aEmpresas*)
@param nIndTry  - Posição do array correspondente ao numero de tentativas 
de processo (dentro do array aEmpresas*)
@param nIndIdThread - Posição do array correspondente ao numero da thread 
que foi realizado o bloquei em nIndLock (dentro do array aEmpresas*)

*(carregado através chave cKeyGrp)

@return Nil

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function executaProc(nJob,cUUID,cKeyGrp,nPosFil,nIndLock,nIndTry,nIndIdThread,nIndExecCall,cEventos)

    Local aEmpresas     := {} 
    Local lExecute      := .F. 

    Default cEventos    := ""

    VarGetAD(cUUID,cKeyGrp,@aEmpresas)
    
    If nJob == 2
        //Integração TAFST2 x TAF
        TAFProc2S(cEventos)
        unLockFilial(cUUID,cKeyGrp,nPosFil,nIndLock,nIndIdThread)

        aEmpresas := {}
        VarGetAD(cUUID,cKeyGrp,@aEmpresas)
        
        lExecute := lockFilial('lockJDin4',cUUID,cKeyGrp,nPosFil,NLOCKJOB4,NTRY4,NTHREAD_LOCK4,NEXEC_JOB4)
        //Processo de Transmissão
        If lExecute
            TafProc4(,,,,cEventos)
            unLockFilial(cUUID,cKeyGrp,nPosFil,NLOCKJOB4,NTHREAD_LOCK4)
        EndIf 
        
    Else 
        
        If nJob == 4
            TafProc4(,,,,cEventos)
        ElseIf nJob == 5
            TafProc5()
        EndIf 
        unLockFilial(cUUID,cKeyGrp,nPosFil,nIndLock,nIndIdThread)
    EndIf 

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} checkActivity

Verifica se o processamento ainda está em execução ou se porventura
a thread "caiu".

@param nIdThread - Numero da thread a ser verificada

@return lActivity - Indica se a thread está ativa ou não.

@author	Evandro dos Santos Oliveira Teixeira

@since	30/12/2018
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function checkActivity(nIdThread)

	Local aMonitor      := GetUserInfoArray()
    Local nX            := 0
    Local nTryWait 	    := 0
    Local nPosIdThread  := 0
	Local nTimeOut 	    := 120
    Local lThreadActive := .F. 
    Local lActivity     := .F.
	Local lTimeOut	    := .F.

    Default nIdThread := 0
	
    For nX := 1 To Len(aMonitor)

        If aMonitor[nX][3] == nIdThread
            lThreadActive := .T. 
            nX := Len(aMonitor)+1
        EndIf 
    Next nX

    If lThreadActive

        While !lActivity .And. !lTimeOut

            aMonitor        := GetUserInfoArray()
            nPosIdThread    := aScan(aMonitor,{|x|x[10] > 0 .And. x[3] == nIdThread})
            lActivity       := nPosIdThread > 0

            If lActivity
                Exit
            EndIf 

            nTryWait++
            Sleep(1000)
            lTimeOut := nTryWait == nTimeOut
        EndDo
    EndIf 

Return lActivity 

//--------------------------------------------------------------------
/*/{Protheus.doc} flagCallJob

Incrementa o numero de vezes que o procesos foi chamado pela API
do Schedule

@param cUUID    - Secao das variavies globais
@param cKeyCall - Chave utilizada para o armazenamento do numero de execuções
@param cKeyGrp  - Chave utilizada para o carregamento das filiais do grupo

@return Nil 

@author	Evandro dos Santos Oliveira Teixeira

@since	11/01/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function flagCallJob(cUUID,cKeyCall,cGrpJob)

    Local nQtd := 0
    
    cKeyCall := cKeyCall + "_" + cGrpJob

    VarGetXD(cUUID,cKeyCall,@nQtd)
    nQtd++
    VarSetXD(cUUID,cKeyCall,nQtd)
    
Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} showSummary

Exibe um resumo com o numero de chamadas que cada processo obteve da 
API do Schedule.

@param cUUID        - Secao das variavies globais
@param cKeyCallP2   - Chave utilizada para armazenar a qtd de chamadas do Proc2
@param cKeyCallP4   - Chave utilizada para armazenar a qtd de chamadas do Proc4
@param cKeyCallP5   - Chave utilizada para armazenar a qtd de chamadas do Proc5
@param cGrpJob      - Codigo do Grupo de Empresas que o Schedule está executando.
@param cKeyGrp      - Chave utilizada para o carregamento das filiais do grupo
@param aFilsExec    - Array com as Filiais que contem registros para execução do processo
@param nJob         - Numero do processo que está sendo executado pela thread atual

@return Nil 

@author	Evandro dos Santos Oliveira Teixeira

@since	11/01/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function showSummary(cUUID,cKeyCallP2,cKeyCallP4,cKeyCallP5,cGrpJob,cKeyGrp,aFilsExec,nJob)

    Local cMsgFim := ""
    Local cMsgFil2 := ""
    Local cMsgFil4 := ""
    Local cMsgFil5 := ""
    Local nX := 0
    Local aEmpresas := {}

    VarGetAD(cUUID,cKeyGrp,@aEmpresas)

    For nX := 1 To Len(aFilsExec)

        nPos := aScan(aEmpresas,{|x|x[2] == aFilsExec[nX] })
        If nPos > 0

            If nJob == 2
                cMsgFil2 += CRLF
                cMsgFil2 += '   * Filial: ' + aFilsExec[nX] + CRLF
                cMsgFil2 += '   Numero de processamentos: ' + cValToChar(aEmpresas[nPos][NEXEC_JOB2]) + CRLF
                cMsgFil2 += '   Lock: ' + IIf(aEmpresas[nPos][NLOCKJOB2],"Sim","Nao") + CRLF
                If aEmpresas[nPos][NLOCKJOB2]
                    cMsgFil2 += '   Thread em Processo: ' + cValToChar(aEmpresas[nPos][NTHREAD_LOCK2]) + CRLF
                EndIf 
            EndIf 

            If nJob == 2 .Or. nJob == 4
                cMsgFil4 += CRLF
                cMsgFil4 += '   * Filial: ' + aFilsExec[nX] + CRLF
                cMsgFil4 += '   Numero de processamentos: ' + cValToChar(aEmpresas[nPos][NEXEC_JOB4]) + CRLF
                cMsgFil4 += '   Lock: ' + IIf(aEmpresas[nPos][NLOCKJOB4],"Sim","Nao") + CRLF
                If aEmpresas[nPos][NLOCKJOB4]
                    cMsgFil4 += '   Thread em Processo: ' + cValToChar(aEmpresas[nPos][NTHREAD_LOCK4]) + CRLF
                EndIf 
            EndIf 

            If nJob == 5
                cMsgFil5 += CRLF
                cMsgFil5 += '   * Filial: ' + aFilsExec[nX] + CRLF
                cMsgFil5 += '   Numero de processamentos: ' + cValToChar(aEmpresas[nPos][NEXEC_JOB5]) + CRLF
                cMsgFil5 += '   Lock: ' + IIf(aEmpresas[nPos][NLOCKJOB5],"Sim","Nao") + CRLF
                If aEmpresas[nPos][NLOCKJOB5]
                    cMsgFil5 += '   Thread em Processo: ' + cValToChar(aEmpresas[nPos][NTHREAD_LOCK5]) + CRLF
                EndIf 
            EndIf

        EndIf 
    Next nX


    cMsgFim := CRLF + CRLF
    cMsgFim += " [SUMMARY PROCESS - TAFDINAMICJOB]" + CRLF + CRLF
    cMsgFim += " ThreadId " + cValToChar(ThreadID()) + " - Grupo de Empresas: "  + cGrpJob + CRLF 

    cMsgFim += getMsgSummary(nJob,2,cMsgFil2,cGrpJob,cKeyCallP2,cUUID)
    cMsgFim += getMsgSummary(nJob,4,cMsgFil4,cGrpJob,cKeyCallP4,cUUID)
    cMsgFim += getMsgSummary(nJob,5,cMsgFil5,cGrpJob,cKeyCallP5,cUUID)

    TafConOut(cMsgFim)    

Return Nil 

//--------------------------------------------------------------------
/*/{Protheus.doc} getMsgSummary

Funçao auxiliar para exibiçao do Sumario 

@param nJob         - Numero do processo que está sendo executado pela thread atual
@param nJob         - Numero do processo para retorno do resumo.
@parm  cMsgFil      - Mensagem com o resumo do processamento nas filiais
@param cGrpJob      - Codigo do Grupo de Empresas que o Schedule está executando.
@param cKeyCall     - Chave utilizada para armazenar a qtd de chamadas do Processo
@param cUUID        - Secao das variavies globais

@return cMsgFim     - Mensagem com o resumo dos processos 

@author	Evandro dos Santos Oliveira Teixeira

@since	11/01/2019
@version 1.0
/*/
//---------------------------------------------------------------------
Static Function getMsgSummary(nJob,nJobMsg,cMsgFil,cGrpJob,cKeyCall,cUUID)

    Local cMsgFim := ""
    Local nNumExecSch := 0

    cMsgFim += " Processo " + cValTochar(nJobMsg) + CRLF
    VarGetXD(cUUID,cKeyCall + "_" + cGrpJob,@nNumExecSch)
    cMsgFim += ' Numero de Chamadas realizadas pela API do Schedule: '
    cMsgFim += cValToChar(nNumExecSch) + CRLF
    cMsgFim += " Processo executado nesta thread: " + IIf(nJob == nJobMsg,"Sim",IIf(nJob == 2 .And. nJobMsg == 4,"Sim","Nao")) + CRLF

    cMsgFim += cMsgFil + CRLF + CRLF 

Return cMsgFim 
