#INCLUDE "ACJOURNEYLOG.CH"
#include "fwlibversion.ch"
#Include "Protheus.CH"

Class acJourneyLog

    data cIdParent     as character
    data cIdCV8        as character
    data cIdD3X        as character
    data cProcess      as character
    data cSubProc      as character
    data cIdChild      as character
    data nCondition    as numeric
    data oJsonParams   as Object
    data llimpaSub     as logical
    data lExD3X        as logical
    data cStatus       as character
    data cThreadID     as character


    data cD3YFilial    as character
    data dD3yDATAFN    as date
    data cD3yHORAFN    as character
    data dD3yDTFECH    as date
    data cIdParentCopy as character
    data cPosition     as character
    data cFinish       as character
    data cStruct       as character
    data cType         as character
    data cParams       as character
    data cIdChildCopy  as character
    data jBranches     as object

    Method New()
    Method idMovCV8()
    Method idMovD3X()
    Method LogProAtu()
    Method GravaD3X()
    Method logIni()
    Method idChild()
    Method envValid()
    Method Destroy()
    method updateD3YPositi()
    Method InsertD3y()
    Method UpdateD3y()
    Method GravaD3Y()
    Method deleteD3YTable()
    Method PatchD3Y()
    Method setThreadId()
    Method CopyInformationD3Y()

    method processHasStarted()
	method lockTable()
	method insertTable()
	method unlockTable()
    method attStatus()
    method deleteTable()
    method getInfraInfo()
    method getProcInfo()

    private method getInfoByCondition()
endClass

/*/{Protheus.doc} New()
    Metodo responsavel por instanciar e iniciar as variaveis da Class acJourneyLog
    @type  Metodo
    @author Pedro Missaglia
    @since  Outubro 02, 2020
    @version 12.1.27
/*/
Method New() Class acJourneyLog
    ::cIdParent   := SUBSTR(FWUUIDV1(), 0, 20)
    ::cIdChild    := SUBSTR(FWUUIDV1(), 0, 20)
    ::cProcess    := ""
    ::cIdCV8      := ""
    ::cIdD3X      := ""
    ::cSubProc    := ""
    ::cStatus     := ""
    ::nCondition  := 0
    ::cThreadID   := ""
    ::llimpaSub   := .F.

    ::oJsonParams := JsonObject():New()


return Self

/*/{Protheus.doc} New()
    Metodo responsavel por instanciar e iniciar as variaveis da Class acJourneyLog
    @type  Metodo
    @author Pedro Missaglia
    @since  Outubro 02, 2020
    @version 12.1.27
/*/
Method setThreadId(cThreadId) Class acJourneyLog
    ::cThreadID := cThreadId
return Self

/*/{Protheus.doc} idMovCV8
    Metodo responsavel por gerar o ID MOV para CV8
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/
Method idMovCV8() Class acJourneyLog

If !Empty(CV8->(IndexKey(5)))
    ::cIdCV8:= GetSXENum("CV8","CV8_IDMOV",,5)
    ConfirmSX8()
EndIf

return ::cIdCV8

/*/{Protheus.doc} idMovD3X
    Metodo responsavel por gerar o IDMOV para D3X
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/
Method idMovD3X() Class acJourneyLog

If !Empty(D3X->(IndexKey(5)))
    ::cIdD3X:= GetSXENum("D3X","D3X_IDMOV",,5)
    ConfirmSX8()
EndIf

return ::cIdD3X

/*/{Protheus.doc} idchild
    Metodo responsavel por gerar ID filho
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/

Method idchild() Class acJourneyLog

::cIdChild := SUBSTR(FWUUIDV1(), 0, 20)

return


/*/{Protheus.doc} logIni
    Metodo responsavel por definir se é subprocesso ou não
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/
Method logIni(lMata280,lReopen,lRepair) Class acJourneyLog

local cProcess := ProcName(1)
Default lMata280 := .F.
Default lReopen  := .F.

If cProcess $ 'EVENTRECALC|EVENTCONTAB|EVENTSTOCKCLOSING|EVENTVIRADADESALDO|EVENTSTARREOPEN'
    If cProcess == 'EVENTRECALC'
        cProcess := 'MATA330'
    Elseif cProcess == 'EVENTCONTAB'
        cProcess := 'MATA331'
    Elseif cProcess == 'EVENTSTOCKCLOSING'
        cProcess := 'MATA280'
    Elseif cProcess == 'EVENTVIRADADESALDO'
        cProcess := 'MATA350'
    Elseif cProcess == 'EVENTSTARREOPEN'
        cProcess := 'EST282'
    Endif
Endif

If lReopen
   cProcess := 'EST282'
EndIf

if lRepair
    cProcess := 'REPAIR'
EndIf

If Empty(::cProcess)
	::cProcess := cProcess
Else
	::cSubProc := ::getInfoByCondition(::llimpaSub, "", cProcess)
    ::llimpaSub:= .F.
EndIf
Return

/*/{Protheus.doc} LogProAtu
    Metodo responsavel por classificar os logs
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/

Method LogProAtu(cType, cMsg, cDetalhes, cFilProc, cStatus,dProc,cFilAtu, lJourney, lReopen) Class acJourneyLog

Local aParams       := {}
Local cParams       := ''
local nX            := 0
Local cId           := " "
Local aAreaAnt      := GetArea()
Local cFilOld       := cFilAnt
Local lproc350      := IsincallStack("MATA350")
Local lproc280      := IsincallStack("MATA280")
Local lC100Apaga    := IsincallStack("CA100APAGA")
Default cFilProc	:= cFilAnt
Default cDetalhes   := ""
Default cMsg		:= ""
Default cType		:= "INICIO"
Default cStatus     := ""
Default lJourney    := .F.
Default lReopen     := .F.

If cFilProc != cFilAnt
	cFilAnt := cFilProc
EndIf

Do Case
    Case cType == "INIJOB" // Inicio do job de (calculo de custo / contabilizacao / saldo atual para final / virada dos saldos)
        cType := "0"
        ::cStatus := '0'
    Case cType == "INICIO" // Inicio do Processamento
        cMsg := STR0001+cMsg    //"Processamento iniciado. "
        cType := "1"
        IF !lproc350 .And. !lReopen
            If lJourney
                If lproc280
                    For nX := 1 to Len(a280ParamZX)
                        aAdd( aParams,  JsonObject():New() )
                        aParams[nX]['parameter'] := 'mv_par'+StrZero(nX,2)
                        aParams[nX]['value']     := a280ParamZX[nX]
                    Next
                Else
                    For nX := 1 to Len(a330ParamZX)
                        aAdd( aParams,  JsonObject():New() )
                        aParams[nX]['parameter'] := 'mv_par'+StrZero(nX,2)
                        aParams[nX]['value']     := a330ParamZX[nX]
                    Next
                EndIf
            Else
                For nX := 1 to 30
                    If Type('mv_par'+StrZero(nX,2)) <> "U"
                        If !Empty(ToXlsFormat(&('mv_par'+StrZero(nX,2))))
                            aAdd( aParams,  JsonObject():New() )
                            aParams[nX]['parameter'] := 'mv_par'+StrZero(nX,2)
                            aParams[nX]['value']     := &('mv_par'+StrZero(nX,2))
                        EndIf
                    EndIf
                Next
            Endif
        EndIf

        If len(aParams) > 0
            ::oJsonParams[::cProcess] := aParams
            cParams:= ::oJsonParams:toJson()
        EndIf
        ::cStatus := '1'
    Case cType == "FIM" // Final do Processamento
        cMsg := STR0002+cMsg  //"Processamento encerrado. "
        cType := "2"
        ::cStatus := '8'
    Case cType == "ALERTA" // Alerta
        cMsg := STR0003+cMsg  //"Alerta! "
        cType := "3"
    Case cType == "ERRO" // Erro
        cMsg := STR0004 + " " + cMsg  //"Erro de Processamento. "
        cType := "4"
        ::cStatus := cStatus
    Case cType == "CANCEL" // Cancelado pelo usuario
        cMsg := STR0005+cMsg  //"Processamento cancelado pelo usuario. "
        cType := "5"
    Case cType == "MENSAGEM" // Mensagem
        cMsg := STR0006+cMsg  //"Mensagem : "
        cType := "6"
        ::cStatus := cStatus
    Case cType == "AMBIENTE"
        cMsg := STR0006+STR0009  //"Mensagem : Informacoes de ambiente"
        cType := "7"
        ::cStatus := " "
        cDetalhes := ::getInfraInfo()
EndCase

	cMsgSubProc	:= cMsg+STR0007+::cProcess 								//" Executado por :"
	cMsg		:= ::getInfoByCondition(!Empty(::cSubProc),STR0008+::cSubProc+" - ","")+cMsg	//"Sub-Processo : "

    IF !Empty(::cIdCV8)
        cId :=  ::cIdCV8
    elseIf  !Empty(::cIdD3X)
        cId := ::cIdD3X
    EndIf

    If ::nCondition == 1
        self:GravaD3X(cType, ::cProcess, cMsg, ::getInfoByCondition(!Empty(cParams),cParams,cDetalhes), ::cSubProc, cMsgSubProc,cId,::cIdChild,::getInfoByCondition(::nCondition== 2 ," ",::cIdParent), cFilProc,dProc,cFilAtu)
    else
	    GravaCV8(cType, ::cProcess, cMsg, ::getInfoByCondition(!Empty(cParams),cParams,cDetalhes), ::cSubProc, cMsgSubProc,.T., cId, cFilProc)
    EndIF

	If cType == "2" .And. !lC100Apaga // Final do Processamento
		::llimpaSub := .T.
        ::cSubProc  := ""
	EndIf
    cFilAnt := cFilOld
    RestArea(aAreaAnt)
return Self

/*/{Protheus.doc} GravaD3X
    Metodo responsavel por realizar a gravão de log na tabela D3X
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/
Method GravaD3X(cType,cProcess,cMsg,cDetalhes,cSubProc,cMsgSubProc,cId,cIdChild, cIdFather, cFilProc,dProc, cFilAtu) Class acJourneyLog
Default cId        := ""
Default cIdChild   := ""
Default cIdFather  := ""
Default cFilProc   := cFilAnt

dbSelectArea("D3X")
RecLock("D3X",.T.)
D3X->D3X_FILIAL    := xFilial("D3X", cFilProc)
D3X->D3X_DATA      := MsDate()
D3X->D3X_HORA      := SubStr(Time(),1,TamSx3("D3X_HORA")[1])
D3X->D3X_PROC      := cProcess
D3X->D3X_USER      := cUserName
D3X->D3X_INFO      := cType
D3X->D3X_MSG       := cMsg
D3X->D3X_DET       := cDetalhes
D3X->D3X_SBPROC    := cSubProc
D3X->D3X_IDMOV     := cId
D3X->D3X_FILLOG    := cFilAtu
D3X->D3X_IDPROS    := cIdChild
D3X->D3X_IDEXEC    := cIdFather
D3X->D3X_DATAPR    := dProc
D3X->D3X_STATUS    := ::getInfoByCondition(cType == '4', ::cStatus, ::getInfoByCondition(empty(::cSubProc),::cStatus,"S"+::cStatus))
D3X->D3X_THREAD    := ::cThreadID
MsUnlock()

Return

/*/{Protheus.doc} eventRecalc
    Metodo responsavel por abrir o startJob para processamento do recalculo
    @type  Metodo
    @author André Maximo
    @since  Novembro 26,2020
    @version 12.1.27
/*/

Method envValid(lOnbord) Class acJourneyLog
local lExD3X    := AliasInDic('D3X')
Default lOnbord := .F.

If  lExD3X .And. lOnbord
    ::nCondition:= 1  // Tem tabela e esta pelo on board
elseIf  lExD3X .And.!lOnbord
    ::nCondition:= 2  // Tem tabela D3X porem nao esta pelo onboard
elseIf !lExD3X .And.lOnbord
    ::nCondition:= 3   //não tem tabela e esta e esta pelo onboard
else
	::nCondition:= 4   // não tem tabela e não esta pelo onboard
EndIf

return ::nCondition

/*/{Protheus.doc}
    Metodo responsavel por gravar informações na D3Y
    @type  Metodo
    @author Denise Nogueira
    @since  Janeiro 14,2021
    @version 12.1.27
/*/
Method InsertD3y(cIdParent, cPosition, cFinish, cError, cStruct, cType, cParams, cIdChild, jBranches,dDataFech, lHoraFn, lDataFn) class acJourneyLog
    Local dDataFin := CtoD("  /  /    ")
    Default dDataFech := CtoD("  /  /    ")
    RecLock("D3Y", .T.)
    D3Y->D3Y_FILIAL := xFilial("D3Y")
    D3Y->D3Y_DATAIN := MsDate()
    D3Y->D3Y_HORAIN := SubStr(Time(),1,TamSx3("D3X_HORA")[1])
    D3Y->D3Y_DTFECH := CtoD(dDataFech)
    D3Y->D3Y_IDEXEC := cIdParent
    D3Y->D3Y_POSITI := cPosition
    D3Y->D3Y_STATUS := ::getInfoByCondition(!Empty(cError),cError,cFinish)
    D3Y->D3Y_STRUCT := cStruct
    D3Y->D3Y_TYPE   := cType
    D3Y->D3Y_PARAMS := cParams
    D3Y->D3Y_IDPROS := cIdChild
    D3Y->D3Y_BRANCH := jBranches
    D3Y->D3Y_HORAFN := ::getInfoByCondition(!Empty(lHoraFn) .and. lHoraFn <> Nil , ::getInfoByCondition(lHoraFn, SubStr(Time(),1,TamSx3("D3X_HORA")[1]), ' ' ) , ' ')
    D3Y->D3Y_DATAFN := ::getInfoByCondition(!Empty(lDataFn) .and. lDataFn <> Nil, ::getInfoByCondition(lDataFn, MsDate(), dDataFin ) , dDataFin)
    D3Y->(MSUnlock())

return


/*/{Protheus.doc}
    Metodo responsavel por gravar informações na D3Y
    @type  Metodo
    @author Denise Nogueira
    @since  Janeiro 14,2021
    @version 12.1.27
/*/
Method UpdateD3y(cIdParent, cPosition, cFinish, cError, cStruct, cType, cParams, cIdChild, jBranches,dDataFech, dD3yDATAFN, cD3yHORAFN, dD3yDTFECH ) class acJourneyLog
    Default dDataFech := CtoD("  /  /    ")
    RecLock("D3Y", .F.)
    D3Y->D3Y_FILIAL := xFilial("D3Y")
    D3Y->D3Y_DATAFN := ::getInfoByCondition(!Empty(dD3yDATAFN),dD3yDATAFN,D3Y->D3Y_DATAFN)
    D3Y->D3Y_HORAFN := ::getInfoByCondition(!Empty(cD3yHORAFN),cD3yHORAFN,D3Y->D3Y_HORAFN)
    D3Y->D3Y_DTFECH := ::getInfoByCondition(!Empty(dD3yDTFECH),dD3yDTFECH,D3Y->D3Y_DTFECH)
    D3Y->D3Y_IDEXEC := cIdParent
    D3Y->D3Y_POSITI := cPosition
    D3Y->D3Y_STATUS := ::getInfoByCondition(!Empty(cError),cError,cFinish)
    D3Y->D3Y_STRUCT := cStruct
    D3Y->D3Y_TYPE   := cType
    D3Y->D3Y_PARAMS := cParams
    D3Y->D3Y_IDPROS := cIdChild
    D3Y->D3Y_BRANCH := jBranches
    D3Y->(MSUnlock())
return


/*/{Protheus.doc}
    Metodo responsavel por gravar informações na D3Y
    @type  Metodo
    @author Denise Nogueira
    @since  Janeiro 14,2021
    @version 12.1.27
/*/
Method PatchD3Y(cIdParent, cPosition, cFinish, cError, cStruct, cType, cParams, cIdChild, jBranches,dDataFech, dD3yDATAFN, cD3yHORAFN, dD3yDTFECH ) class acJourneyLog
    Local lRet := .F.
    D3Y->(dbSetOrder(1))
    If D3Y->(DBSeek(xFilial("D3Y")+padR(cIdParent,TAMSX3("D3Y_IDEXEC")[1])+::getInfoByCondition(!Empty(cIdChild),cIdChild, '')))
        RecLock("D3Y", .F.)
        D3Y->D3Y_DATAFN := ::getInfoByCondition(!Empty(dD3yDATAFN),dD3yDATAFN,D3Y->D3Y_DATAFN)
        D3Y->D3Y_HORAFN := ::getInfoByCondition(!Empty(cD3yHORAFN),cD3yHORAFN,D3Y->D3Y_HORAFN)
        D3Y->D3Y_DTFECH := ::getInfoByCondition(!Empty(dD3yDTFECH),dD3yDTFECH,D3Y->D3Y_DTFECH)
        D3Y->D3Y_IDEXEC := ::getInfoByCondition(!Empty(cIdParent),cIdParent,D3Y->D3Y_IDEXEC)
        D3Y->D3Y_POSITI := ::getInfoByCondition(!Empty(cPosition),cPosition,D3Y->D3Y_POSITI)
        D3Y->D3Y_STATUS := ::getInfoByCondition(!Empty(cFinish),cFinish,D3Y->D3Y_STATUS)
        D3Y->D3Y_STRUCT := ::getInfoByCondition(!Empty(cStruct),cStruct,D3Y->D3Y_STRUCT)
        D3Y->D3Y_TYPE   := ::getInfoByCondition(!Empty(cType),cType,D3Y->D3Y_TYPE )
        D3Y->D3Y_PARAMS := ::getInfoByCondition(!Empty(cParams),cParams, D3Y->D3Y_PARAMS)
        D3Y->D3Y_IDPROS := ::getInfoByCondition(!Empty(cIdChild),cIdChild,D3Y->D3Y_IDPROS)
        D3Y->D3Y_BRANCH := ::getInfoByCondition(!Empty(jBranches),jBranches,D3Y->D3Y_BRANCH)
        D3Y->(MSUnlock())
        lRet := .T.
    EndIf
return lRet

/*/{Protheus.doc} New()
    Metodo responsavel por instanciar e iniciar as variaveis da Class acJourneyLog
    @type  Metodo
    @author Pedro Missaglia
    @since  Outubro 02, 2020
    @version 12.1.27
/*/

Method GravaD3Y() class acJourneyLog

D3Y->(dbSetOrder(1))
If D3Y->(DBSeek(xFilial("D3Y")+padR(cIdParent, TAMSX3("D3Y_IDEXEC")[1])))
    ::UpdateD3y(::cIdParent, cPosition, '', '', cStruct, 'ON', cParams, ::cIdChild, jBranches,dDataFech, dD3yDATAFN, cD3yHORAFN, dD3yDTFECH)
Else
    ::InsertD3y(::cIdParent, cPosition, '', '', cStruct, 'ON', cParams, ::cIdChild, jBranches,dDataFech)
Endif

return

/*/{Protheus.doc} New()
    Metodo responsavel por instanciar e iniciar as variaveis da Class acJourneyLog
    @type  Metodo
    @author Pedro Missaglia
    @since  Outubro 02, 2020
    @version 12.1.27
/*/

Method Destroy() Class acJourneyLog
    ::cIdParent   := ""
    ::cIdChild    := ""
    ::cProcess    := ""
    ::cSubProc    := ""
    ::nCondition  := ""
    ::llimpaSub   := .F.
    ::oJsonParams := JsonObject():Destroy()

return Self


method  updateD3YPositi(cRoutine,linitialReopen, lReopen, lfinal, lauto331) Class acJourneyLog
Local cPositi
Local cStatus          := 'P'
Local cSubs
Local cCusMed          := SuperGetMV("MV_CUSMED",.F.,"M")
Local lAchou           := .F.
Default linitialReopen := .F.
Default lReopen        := .F.
Default lfinal         := .F.
Default lauto331       := .F.

cRoutine := Upper(cRoutine)

If cRoutine == 'MATA330'
        cPositi := 'M3'
elseif cRoutine == 'MATA350'
        cPositi := 'O3'
elseif cRoutine == 'MATA331'
    If lauto331
        cPositi := ::getInfoByCondition(cCusMed == "O", "O5", "M5")
    Else
        cPositi := ::getInfoByCondition(cCusMed == "O", "O6", "M6")
    EndIf
elseif cRoutine == 'MATA280'
    cPositi := ::getInfoByCondition(cCusMed == "O", "O9", "M9")
elseif cRoutine == 'EST282' .and. linitialReopen
    cPositi := "RE1"
elseif cRoutine == 'EST282' .and. !linitialReopen
    cPositi := "RE2"
elseIf cRoutine == 'REPAIR' .And. !lfinal
    cPositi := ::getInfoByCondition(cCusMed == "O", "O8R", "M8R")
elseIf cRoutine == 'REPAIR' .and. lfinal
    cPositi := ::getInfoByCondition(cCusMed == "O", "O8F", "M8F")
Endif

D3Y->(DBSetOrder(1))
if !linitialReopen .And. lReopen
    If D3Y->(DBSeek(xFilial("D3Y")+padR(::cIdParent, TAMSX3("D3Y_IDEXEC")[1])+::cIdChild))
        lAchou := .T.
    EndIf
else
     If D3Y->(DBSeek(xFilial("D3Y")+padR(::cIdParent, TAMSX3("D3Y_IDEXEC")[1])))
        lAchou := .T.
    EndIf
EndIF
If lAchou
    cSubs := Substr(D3Y->D3Y_POSITI, 3, 1)
    RecLock("D3Y", .F.)
    If !Empty(cSubs)
        D3Y->D3Y_POSITI := cPositi+cSubs
    else
        D3Y->D3Y_POSITI := cPositi
    EndIf
    if upper(cRoutine) == 'EST282' .Or. lauto331
        D3Y->D3Y_STATUS := cStatus
        If linitialReopen .And. lReopen  .Or. lauto331 
            D3Y->D3Y_IDPROS := ::cIdChild
        EndIf
    EndIf
     if upper(cRoutine) == 'REPAIR' .And. !lfinal
        D3Y->D3Y_STATUS := cStatus
        //D3Y->D3Y_IDPROS := ::cIdChild
    EndIf
    D3Y->(MSUnlock())
EndIf

return

/*/{Protheus.doc} CopyInformationD3Y()
    Metodo responsavel por instanciar e iniciar as variaveis da Class acJourneyLog
    @type  Metodo
    @author Maximo
    @since  junho 21, 2021
    @version 12.1.27
/*/
method CopyInformationD3Y(cIdParent) Class acJourneyLog
D3Y->(dbSetOrder(1))
If D3Y->(DBSeek(xFilial("D3Y")+padR(cIdParent, TAMSX3("D3Y_IDEXEC")[1])))
    ::cD3YFilial    := D3Y->D3Y_FILIAL
    ::dD3yDATAFN    := D3Y->D3Y_DATAFN
    ::cD3yHORAFN    := D3Y->D3Y_HORAFN
    ::dD3yDTFECH    := D3Y->D3Y_DTFECH
    ::cIdParentCopy := D3Y->D3Y_IDEXEC
    ::cPosition     := D3Y->D3Y_POSITI
    ::cFinish       := D3Y->D3Y_STATUS
    ::cStruct       := D3Y->D3Y_STRUCT
    ::cType         := D3Y->D3Y_TYPE
    ::cParams       := D3Y->D3Y_PARAMS
    ::cIdChildCopy  := D3Y->D3Y_IDPROS
    ::jBranches     := D3Y->D3Y_BRANCH
EndIF


return

/*/{Protheus.doc} acTableTemporyRepository:deletedTableId()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method processHasStarted(cIdParent, cIdChild, cProcess, cFilStart) CLASS acJourneyLog

Local lRet := .F.

Default cFilStart := xFilial("D3W")

D3W->(DBSetOrder(1))
lRet := D3W->(DBSeek(cFilStart+padR(cIdParent, TAMSX3("D3W_IDEXEC")[1])+padR(cIdChild, TAMSX3("D3W_IDEXEC")[1])+cProcess))

Return lRet


/*/{Protheus.doc} acTableTemporyRepository:deletedTableId()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method attStatus(cStatus, lLock) CLASS acJourneyLog

	D3W->D3W_STATUS := cStatus
	D3W->(MSUnlock())

    If lLock
        ::lockTable()
    Else
        ::unlockTable()
    EndIf

Return

/*/{Protheus.doc} acTableTemporyRepository:deletedTableId()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method lockTable() CLASS acJourneyLog

Return D3W->(MsrLock())

/*/{Protheus.doc} acTableTemporyRepository:deletedTableId()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method unlockTable() CLASS acJourneyLog

    D3W->(MSRUNLOCK())

Return

/*/{Protheus.doc} acTableTemporyRepository:insertTable()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method insertTable(cIdParent, cIdChild, cProcess,cStatus, cUserName) CLASS acJourneyLog

   RecLock("D3W", .T.)
   D3W->D3W_FILIAL := xFilial("D3W")
   D3W->D3W_IDEXEC := cIdParent
   D3W->D3W_IDPROS := cIdChild
   D3W->D3W_PROC   := cProcess
   D3W->D3W_STATUS := cStatus
   D3W->D3W_USER   := cUserName

   D3W->(MSUnlock())

   ::lockTable()

Return


/*/{Protheus.doc} acTableTemporyRepository:deletedTableId()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method deleteTable(cIdParent) CLASS acJourneyLog

    local cQuery := ''
    Local lRet := .T.
    local cAlias := "D3W"
    Local nRet   := 0
    cQuery := "DELETE FROM " +RetSQLName(cAlias) +" WHERE D_E_L_E_T_ = ' ' AND "
    cQuery += "D3W_FILIAL = '" +xFilial(cAlias) +"' AND "
    cQuery += "D3W_IDEXEC = '" +cIdParent+"'"
    nRet := TCSQLExec(cQuery)

    If nRet < 0
        lRet := .F.
    Endif

Return lRet

/*/{Protheus.doc} methodName
    (long_description)
    @author user
    @since 07/04/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method getInfraInfo() CLASS acJourneyLog

Local oJson        := JsonObject():New()
Local oAux         := JsonObject():New()
Local oApo         := JsonObject():New()
Local cAux         := ''
Local cLibVersion  := FWLibVersion()
Local nX           := 0
Local nY           := 0
Local aAux         := {}
Local aAuxReop     := {}
Local aDbAcType    := {'dbaccessType'                     , 'TCSrvType'}
Local aEnv         := {'environment'                      , 'GetEnvServer'}
Local aApiInfo     := {'apoVersion'                       , 'GetApoInfo'}
Local aDicInDb     := {'dictionaryInDb'                   , 'MpDicInDb'}
Local aDbABuild    := {'dbaccessBuild'                    , 'TCVersion'}
Local aLibVersion  := {'versionLib'                       , 'FwLibVersion'}
Local aDbType      := {'dbType'                           , 'TCGetDB'}
Local aDbApiBuild  := {'apiBuild'                         , 'TCAPIBuild'}
Local aSrvrBuild   := {'serverBuild'                      , 'GetBuild'}
Local aSvrType     := {'serverType'                       , 'GetSrvType'}
Local aRelease     := {'rpoRelease'                       , 'GetRpoRelease'}
Local aReopen      := {'acReopeningOfStockController.tlpp', 'acReopeningOfStockRepository.tlpp', 'acReopeningOfStockService.tlpp'}
Local aSrvrVersion := {'serverVersion'                    , 'GetSrvVersion'}

Local aFunc        := { aDbAcType, aEnv, aApiInfo, aDicInDb, aDbABuild, aLibVersion,;
                        aDbType, aDbApiBuild,;
                        aSrvrVersion, aSrvrBuild, aSvrType, aRelease }

For nX := 1 to Len(aFunc)
    If aFunc[nX][2] == 'FwLibVersion'
        oAux[aFunc[nX][1]] := cLibVersion
    EndIf
    If FindFunction(aFunc[nX][2])
        If aFunc[nX][2] == 'GetApoInfo'
            If Alltrim(::cProcess) == 'EST282'
                For nY := 1 to Len(aReopen)
                    cAux := aFunc[nX][2] + "('" + aReopen[nY] + "')"
                    aAux := &(cAux)

                    If Len(aAux) > 0
                        aAdd( aAuxReop,  JsonObject():New() )
                        aAuxReop[nY]["routine"] := aAux[1]
                        aAuxReop[nY]["date"] := aAux[5]
                        aAuxReop[nY]["hour"] :=  dtoS(aAux[4])
                    Endif

                Next nY
                oAux["apoVersion"] := aAuxReop
            Else
                cAux := aFunc[nX][2] + "('" + ::cProcess + ".PRX')"
                aAux := &(cAux)
                If Len(aAux) > 0
                    oApo["routine"]     := aAux[1]
                    oApo["date"]        := dtoS(aAux[4])
                    oApo["hour"]        := aAux[5]
                    oAux["apoVersion"]  := oApo
                Endif
            Endif
        Else
            oAux[aFunc[nX][1]] := &(aFunc[nX][2] + '()')
        Endif
    Endif

Next nX

::getProcInfo(@oAux)

oJson["environment"] := oAux

ASIZE( aAux         , 0 )
ASIZE( aDbAcType    , 0 )
ASIZE( aEnv         , 0 )
ASIZE( aApiInfo     , 0 )
ASIZE( aDicInDb     , 0 )
ASIZE( aDbABuild    , 0 )
ASIZE( aLibVersion  , 0 )
ASIZE( aDbType      , 0 )
ASIZE( aDbApiBuild  , 0 )
ASIZE( aSrvrBuild   , 0 )
ASIZE( aSvrType     , 0 )
ASIZE( aRelease     , 0 )
ASIZE( aReopen      , 0 )
ASIZE( aFunc        , 0 )

Return oJson:toJson()


/*/{Protheus.doc} ACVERVLD
    VALIDA EXISTENCIA DA FUNÇÃO
/*/
Function ACVERVLD()

Return 100

/*/{Protheus.doc} acTableTemporyRepository:deletedTableId()
    Metodo responsavel pela exclusão da tabela do banco
    @type  Metodo
    @author Pedro
    @since  Março 12, 2021
    @version 12.1.27
/*/
Method deleteD3YTable(cIdTest) CLASS acJourneyLog

    local cQuery := ''
    Local lRet   := .F.
    local cAlias := "D3Y"

    cQuery := "DELETE FROM " +RetSQLName(cAlias) +" WHERE D_E_L_E_T_ = ' ' AND "
    cQuery += "D3Y_FILIAL = '" +xFilial(cAlias) +"' AND "
    cQuery += "D3Y_IDEXEC = '" +cIdTest+ "' AND D3Y_POSITI = 'RE1' AND D3Y_STATUS = 'ER' "

    If (TCSQLExec(cQuery) == 0)
        lRet := .T.
    Endif

Return lRet

/*/{Protheus.doc} getProcInfo
    Retorna um Json com as informacoes da procedure instalada
    Disponivel apenas para novo processo de instalacao de procedures
    @author Adriano Vieira
    @since 14/09/2022
    @version 1.0
    @return
/*/
Method getProcInfo(oAux) CLASS acJourneyLog

Local cCompany  :=  cEmpAnt             as character
Local cNameProc :=  ""                  as character
Local aProcess  :=  {"19","17","01"}    as Array
Local aAuxProc  :=  {}                  as Array
Local lMigrated :=  SPSMigrated()       as Logical
Local nX        :=  0                   as numeric
Local oProcInfo                         as object

If lMigrated

    For nX := 1 to Len(aProcess)

        oProcInfo := EngSPSStatus(aProcess[nX]/*processo*/,cCompany/*empresa*/)

        aAdd( aAuxProc,  JsonObject():New() )
        aAuxProc[nX]["status"]      :=  ::getInfoByCondition(oProcInfo["status"] == "0", STR0010, STR0011)
        aAuxProc[nX]["version"]     :=  oProcInfo["version"]
        aAuxProc[nX]["generation"]  :=  oProcInfo["generation"]
        aAuxProc[nX]["signature"]   :=  oProcInfo["signature"]
        aAuxProc[nX]["processCod"]  :=  oProcInfo["process"]

        If oProcInfo["process"] == "19"
            aAuxProc[nX]["processName"] :=  STR0012 //Custo Medio

        ElseIf oProcInfo["process"] == "17"
            aAuxProc[nX]["processName"] :=  STR0013 //Virada de Saldos

        Else
            aAuxProc[nX]["processName"] :=  STR0014 //Contabil
        EndIf

        cNameProc := "process" + oProcInfo["process"]
        oAux[cNameProc] := aAuxProc[nX]

    Next nX

EndIf

Return

/*/{Protheus.doc} getInfoByCondition
    Metodo auxiliar para retornar informaçoes via condicao
    @author pedro.missaglia
    @since 16/11/2022
    @version 1.0
    @return
/*/
Method getInfoByCondition(lCondition, xCmd1, xCmd2) CLASS acJourneyLog

Local xRet

If lCondition
    xRet := xCmd1
else
    xRet := xCmd2
Endif

Return xRet



