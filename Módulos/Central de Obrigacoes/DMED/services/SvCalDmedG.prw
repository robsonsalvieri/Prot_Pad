#INCLUDE "TOTVS.CH"
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

/*/{Protheus.doc}
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvCalDmedG()

Local oSvVldDmedG := SvCalDmedG():New()
oSvVldDmedG:run()
FreeObj(oSvVldDmedG)
oSvVldDmedG := nil

return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}


Function JbCalDmedG(cEmp, cFil, lJob, cCodOpe)
    Local aSvcVldr  := {}
    Local aSvcVliND := {}
    Default lJob    := .T.
    Default cCodOpe := ""
    Default cEmp    := cEmpANt
    Default cFil    := cFilAnt

    If lJob
        rpcSetType(3)
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    aSvcVldr  := {SvCalDmedG():New()}
    aSvcVlInd := {SvCalDmedI():New()}

    ExecVldDmed(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)

Return

Function ExecVldDmed(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)
    Local nLen      := 0
    Local nVldr     := 0
    Local cAno      :=""
    Local cCdComp   :=""
    Local cCdObri   :=""
    Local oColB2W	:= CenCltB2W():New()

    Default aSvcVldr  := {}
    Default aSvcVlInd := {}
    Default lJob      := .T.
    Default cCodOpe   := ""
    Default cEmp      := ""
    Default cFil      := ""

    oColB2W:setCriPro()

    nLen := Len(aSvcVldr)
    For nVldr := 1 to nLen
        aSvcVldr[nVldr]:setProcId(ThreadId())
        aSvcVldr[nVldr]:setCodOpe(cCodOpe)
        If aSvcVldr[nVldr]:beforeProc("4")
            aSvcVldr[nVldr]:logMsg("W","vai processar " + GetClassName(aSvcVldr[nVldr]),JOB_PROCES,.t.)
            aSvcVldr[nVldr]:runProc()
            aSvcVldr[nVldr]:logMsg("W","processou " + GetClassName(aSvcVldr[nVldr]),JOB_CONCLU,.t.)
        EndIf
        aSvcVldr[nVldr]:destroy()
        FreeObj(aSvcVldr[nVldr])
        aSvcVldr[nVldr] := nil
    Next nVldr

    nLen := Len(aSvcVlInd)
    For nVldr := 1 to nLen

        aSvcVlInd[nVldr]:logMsg("W","vai processar " + GetClassName(aSvcVlInd[nVldr]),JOB_PROCES,.t.)
        SvVldDmedIn(cEmp, cFil, .F., aSvcVlInd[nVldr])
        aSvcVlInd[nVldr]:logMsg("W","processou " + GetClassName(aSvcVlInd[nVldr]),JOB_CONCLU,.t.)
        If nVldr == 1 .And. !Empty(aSvcVlInd[nVldr]:CCODCOMP)
            cAno   :=aSvcVlInd[nVldr]:CANOCOMP
            cCdComp:=aSvcVlInd[nVldr]:CCODCOMP
            cCdObri:=aSvcVlInd[nVldr]:CCODOBRI
            cCodOpe:=aSvcVlInd[nVldr]:CCODOPE
        EndIf
        aSvcVlInd[nVldr]:destroy()
        FreeObj(aSvcVlInd[nVldr])
        aSvcVlInd[nVldr] := nil
    Next nVldr
    DelClassIntf()
    AjuCompro(cCodOpe,cAno,cCdComp,cCdObri)

Return

/*/{Protheus.doc}
    Serviço de validação em grupo das criticas DMED
    @type  Class
    @author lima.everton
    @since 10/09/2020
/*/
Class SvCalDmedG From Service

    Method New()
    Method runProc()

EndClass

Method New() Class SvCalDmedG
    _Super:New()
    self:cFila := "FILA_VLD_DEMED_GRP"
    self:cJob := "JbCalDmedG"
    self:cObs := "Valida em grupo a tabela B2W DMED"
    self:oFila := CenFilaBd():New(CenCltB2W():New())
    self:oProc := CenVldDB2W():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvCalDmedG
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return