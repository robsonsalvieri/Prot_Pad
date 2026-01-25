#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlMGGrp()
    
    Local oSvcVlMGGrp := SvcVlMGGrp():New()
    oSvcVlMGGrp:run()
    FreeObj(oSvcVlMGGrp)
    oSvcVlMGGrp := nil

return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Job que processa as guias que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlMGGrp(cEmp, cFil, lJob, cCodOpe)
    Local aSvcVldr  := {}
    Local aSvcVlInd := {}
    Default lJob    := .T.
    Default cCodOpe := ""

	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    aSvcVldr := {;
                    SvcVlMGGrp():New(),;   // Guia Monitoramento  - Serviço de validação em grupo
                    SvcVlGrItG():New(),;   // Guia Monitoramento  - Serviço de validação em grupo dos itens
                    SvcVlGrPcG():New(),;   // Guia Monitoramento  - Serviço de validação em grupo dos pacotes
                    SvcVlGrFDi():New(),;   // Fornecimento Direto - Serviço de validação em grupo das guias  
                    SvcVlGrItF():New(),;   // Fornecimento Direto - Serviço de validação em grupo dos itens 
                    SvcVlGrVPr():New(),;   // Preestabelecido     - Serviço de validação em grupo das guias 
                    SvcVlGrORe():New();    // Outras Remunerações - Serviço de validação em grupo das guias 
                    }

    aSvcVlInd := {;
                    SVCVLINGMO():New(),;   // Guia Monitoramento  - Servico que valida individualmente do cabeçalho das guias
                    SvcVlInItG():New(),;   // Guia Monitoramento  - Servico que valida individualmente os itens das guias 
                    SvcVlInPcG():New(),;   // Guia Monitoramento  - Servico que valida individualmente os pacotes das guias 
                    SVCVLINFDI():New(),;   // Fornecimento Direto - Servico que valida individualmente os itens das guias 
                    SvcVlItFDi():New(),;   // Fornecimento Direto - Servico que valida individualmente os itens das guias 
                    SVCVLINVPR():New(),;   // Preestabelecido     - Servico que valida individualmente as guias de valor 
                    SVCVLINORE():New();    // Outras Remunerações - Servico que valida as guias de outras remunerações
                    }
 
    ExecVldMon(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)

Return

Function ExecVldMon(cCodOpe,aSvcVldr,aSvcVlInd,cEmp, cFil)
    Local nLen      := 0
    Local nVldr     := 0
    Local cAno      :=""
    Local cCdComp   :=""
    Local cCdObri   :=""

    Default aSvcVldr  := {}
    Default aSvcVlInd := {}
    Default lJob      := .T.
    Default cCodOpe   := ""
    Default cEmp      := ""
    Default cFil      := ""

    nLen := Len(aSvcVldr)
    For nVldr := 1 to nLen
       aSvcVldr[nVldr]:setProcId(ThreadId())
        aSvcVldr[nVldr]:setCodOpe(cCodOpe)
        If aSvcVldr[nVldr]:beforeProc()
            aSvcVldr[nVldr]:logMsg("W","vai processar " + GetClassName(aSvcVldr[nVldr]))
            aSvcVldr[nVldr]:runProc()
            aSvcVldr[nVldr]:logMsg("W","processou " + GetClassName(aSvcVldr[nVldr]))
        EndIf
        aSvcVldr[nVldr]:destroy()
        FreeObj(aSvcVldr[nVldr])
        aSvcVldr[nVldr] := nil
    Next nVldr

    nLen := Len(aSvcVlInd)
    For nVldr := 1 to nLen
 
        aSvcVlInd[nVldr]:logMsg("W","vai processar " + GetClassName(aSvcVlInd[nVldr]))
        JobVldInMon(cEmp, cFil, .F., aSvcVlInd[nVldr])
        aSvcVlInd[nVldr]:logMsg("W","processou " + GetClassName(aSvcVlInd[nVldr]))
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
    Ajusta compromisso que foi criticado.
    @type  Class
    @author jose.paulo
    @since 10/09/2020
/*/
Function AjuCompro(cCodOpe,cAnoComp,cCodComp,cCodObri)
    Local   cSQL      := ""
    Local   lFound    := .F.
    Default cCodOpe   := ""
    Default cAnoComp  := ""
    Default cCodComp  := ""
    Default cCodObri  := ""

    If !Empty(cCodOpe) .Or. !Empty(cAnoComp) .Or. !Empty(cCodComp) .Or. !Empty(cCodObri)
        cQuery := " SELECT R_E_C_N_O_ AS RECNO "
        cQuery += " FROM " + RetSqlName('B3F') + " "
        cQuery += " WHERE B3F_FILIAL = '" + xFilial("B3F") + "' "
        cQuery += " AND B3F_CODOPE =  '"+cCodOpe+"' "
        cQuery += " AND B3F_CDOBRI =  '"+cCodObri+"' "
        cQuery += " AND B3F_ANO    =  '"+cAnoComp+"' "
        cQuery += " AND B3F_CDCOMP =  '"+cCodComp+"' "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"B3FTRB",.F.,.T.)

        If !B3FTRB->(Eof())
            lFound:=.T.
        EndIf
        B3FTRB->(dbCloseArea())

        If lFound
            B3D->(dbSetOrder(1))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
            If B3D->(MsSeek(xFilial('B3D')+cCodOpe+cCodObri+cAnoComp+cCodComp))
                If B3D->B3D_STATUS != '6' .And. B3D->B3D_STATUS <> '2'  //evito de dar reclock caso compromisso ja esteja criticado.
                    Reclock("B3D",.F.)
                        B3D->B3D_STATUS := '2' //compromisso criticado.
                    MsUnlock()
                EndIf
            EndIf 
        Else 
            B3D->(dbSetOrder(1))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS+B3F_TIPO
            If B3D->(MsSeek(xFilial('B3D')+cCodOpe+cCodObri+cAnoComp+cCodComp))
                If B3D->B3D_STATUS == '2' .And. B3D->B3D_STATUS <> '1' //evito de dar recllock caso o compromisso não esteja criticado
                    Reclock("B3D",.F.)
                        B3D->B3D_STATUS := '1' //compromisso não criticado.
                    MsUnlock()
                EndIf
            EndIf 
        EndIf
    EndIf

return lFound


/*/{Protheus.doc} 
    Serviço de validação em grupo das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlMGGrp From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcVlMGGrp
    _Super:New()
    self:cFila := "FILA_VLD_GUI_MON_GRP"
    self:cJob := "JobVlMGGrp"
    self:cObs := "Valida em grupo todas as formas de remuneracao"
    self:oFila := CenFilaBd():New(CenCltBKR():New())
    self:oProc := CenVldMGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlMGGrp
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return