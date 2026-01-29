#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPUJ001.CH"

/*/{Protheus.doc} GTPUJ001
Função responsavel pela criação do job para alocação de recursos do Urbano
@type function
@author João Pires
@since 13/05/2025
@version 1.0
@param aParam, array, (Descrição do parâmetro)
/*/
Function GTPUJ001(aParam)
    local lJob		 := Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
    Local nPosEmp    := 0
    Local nPosFil    := 0
    Local aProc      := {}

    Default aParam    := {}
    //---Inicio Ambiente

    If lJob // Schedule
        
        nPosEmp := IF(Len(aParam) == 5, 2, 1)

        nPosFil := IF(Len(aParam) == 5, 3, 2)

        RPCSetType(3)
        
        PREPARE ENVIRONMENT EMPRESA aParam[nPosEmp] FILIAL aParam[nPosFil] MODULO "FAT"
    EndIf   

    If Len(aParam) == 5 
        
        AADD(aProc,aParam[1]) //Quant. Dias	

    ElseIf !lJob .AND. Pergunte("GTPUJ001",.T.)
        
        AADD(aProc,MV_PAR01)

    EndIf

    If Len(aProc) > 0 .AND. ValType(aProc[1]) == "N"
        If !lJob
            FWMsgRun(, {|| AlocaRecursos(aProc, lJob), AjustaRecursos(aProc, lJob) },STR0001, STR0002) //"Aguarde" "Processando registros..."
	    
            FwAlertInfo(STR0003,STR0004) //"Processamento Concluído!" "Finalizado"
            
        Else            
            AlocaRecursos(aProc, lJob)            
            AjustaRecursos(aProc, lJob)            
        Endif
    Endif

    If lJob
        RpcClearEnv()
    EndIf 

Return


/*/{Protheus.doc} AlocaRecursos
Realiza a alocação
@type function
@author João Pires
@since 14/05/2025
@version 1.0
@param aProc, array, (Descrição do parâmetro)
/*/
Static Function AlocaRecursos(aProc,lJob)
    Local oModel	  := FwLoadModel("GTPU011")
    Local oModelH7E   := oModel:GetModel('H7EMASTER')
    Local oModelH7F   := oModel:GetModel('H7FDETAIL')
    Local oModelH7G   := oModel:GetModel('H7GDETAIL')
    Local cAliasTmp1  := GetNextAlias()
    Local cAliasTmp2  := GetNextAlias()
    Local dDatafim    := DaySum(dDatabase,aProc[1])
    Local dDataAux    := dDataBase
    Local nX          := 1
    Local cEscala     := ""
    Local cDia        := ""
    Local cErro       := ""
    Local cMotor      := ""
    Local lRet        := .T.    

    DbSelectArea("H7E")

    For nX := 1 to aProc[1]
        lRet := .T.

        /*Escalas sem alocação*/
        BeginSql Alias cAliasTmp1

            SELECT  H71.H71_CODH6V,                    
                    H77.H77_CODH76 AS ESCALA,
                    H71.H71_CODIGO AS PROGRA,
                    H77.H77_CODIGO AS VIAGEM,  
                    H76.H76_CODMOT AS MOTORISTA,
                    H76.H76_MOTRES AS MOTORISTA_RESERVA,
                    H76.H76_VEICUL AS VEICULO,
                    H76.H76_CODCOB AS COBRADOR,
                    H73.H73_SEGUND AS SEG,
                    H73.H73_TERCA  AS TER,
                    H73.H73_QUARTA AS QUA,
                    H73.H73_QUINTA AS QUI,
                    H73.H73_SEXTA  AS SEX,
                    H73.H73_SABADO AS SAB,
                    H73.H73_DOMING AS DOM,
                    H77.H77_SENTID AS SENTID,
                    H77.H77_HRINIC AS HRINIC,
		            H77.H77_HRFINA AS HRFINA                  
            FROM   %Table:H71% H71
                INNER JOIN %Table:H77% H77
                        ON H77.H77_FILIAL = %xFilial:H77%
                            AND H77.H77_CODH71 = H71.H71_CODIGO
                            AND H77.%NotDel%                            
                INNER JOIN %Table:H73% H73
                        ON H73.H73_FILIAL = %xFilial:H73%
                        AND H73.H73_CODH71 = H71.H71_CODIGO
                        AND H73.H73_CODIGO = H77.H77_CODH73
                        AND H73.%NotDel%
                INNER JOIN %Table:H76% H76
                        ON H76.H76_FILIAL = %xFilial:H76%
                            AND H76.H76_CODIGO = H77.H77_CODH76
                            AND ( H76.H76_CODMOT <> '' OR H76.H76_VEICUL <> '' OR H76.H76_CODCOB <> '')
                            AND H76.%NotDel%
                LEFT JOIN %Table:H7F% H7F
                        ON H7F.H7F_FILIAL = %xFilial:H7F%
                            AND H76.H76_CODIGO = H7F.H7F_CODH76
                            AND H7F.%NotDel%
                            AND H7F.H7F_DATA = %Exp:DTOS(dDataAux)%
            WHERE  H71.H71_FILIAL = %xFilial:H71%
                AND H71.H71_DTINIC <= %Exp:DTOS(dDataBase)%
                AND H71.H71_DTFINA < %Exp:DTOS(dDatafim)%
                AND H71.H71_STATUS = '1'                
                AND H7F.H7F_CODH76 IS NULL 
                AND H71.%NotDel%
            ORDER BY 
                H71.H71_CODH6V,H77.H77_CODH76,H71.H71_CODIGO
        
        EndSql

        While lRet .AND. (cAliasTmp1)->(!Eof())

            cDia := UPPER(DiaSemana(dDataAux, 3, ))
            
            If (cDia == "DOM" .AND.  (cAliasTmp1)->DOM == 'F') .OR.;
               (cDia == "SEG" .AND.  (cAliasTmp1)->SEG == 'F') .OR.;
               (cDia == "TER" .AND.  (cAliasTmp1)->TER == 'F') .OR.; 
               (cDia == "QUA" .AND.  (cAliasTmp1)->QUA == 'F') .OR.;  
               (cDia == "QUI" .AND.  (cAliasTmp1)->QUI == 'F') .OR.; 
               (cDia == "SEX" .AND.  (cAliasTmp1)->SEX == 'F') .OR.;
               (cDia == "SAB" .AND.  (cAliasTmp1)->SAB == 'F')

                (cAliasTmp1)->(DBSkip())
                Loop
                
            Endif
            
            If cEscala <> (cAliasTmp1)->ESCALA + (cAliasTmp1)->PROGRA                

                BeginSql Alias cAliasTmp2

                    SELECT H7E.R_E_C_N_O_ AS RECNO
                    FROM   %Table:H7E% H7E
                    WHERE  H7E_FILIAL = %xFilial:H7E%
                        AND H7E.%NotDel%
                        AND H7E_CODH76 = %Exp:(cAliasTmp1)->ESCALA%
                        AND H7E_DTINIC <= %Exp:DTOS(dDataAux)%
                        AND H7E_DTFINA >= %Exp:DTOS(dDataAux)%
                
                EndSql

                If (cAliasTmp2)->(!Eof())
                    H7E->(DBGoTo((cAliasTmp2)->RECNO))
                    oModel:SetOperation(MODEL_OPERATION_UPDATE)                    
                Else
                    oModel:SetOperation(MODEL_OPERATION_INSERT)                
                Endif
                (cAliasTmp2)->(DBCloseArea())

                oModel:Activate()

                lRet := oModel:IsActive()
                cErro += IIF(lRet,"","Falha ao ativar o modelo |")

                If lRet .AND. oModel:GetOperation() == MODEL_OPERATION_INSERT
                    oModelH7E:SetValue("H7E_DTINIC",FirstDate(dDataAux))
                    oModelH7E:SetValue("H7E_DTFINA",LastDate(dDataAux))
                    oModelH7E:SetValue("H7E_CODH76",(cAliasTmp1)->ESCALA)
                Endif

                If lRet .AND. oModel:GetOperation() == MODEL_OPERATION_UPDATE
                    oModelH7F:AddLine(.T.)
                Endif

                If lRet
                    oModelH7F:SetValue("H7F_DATA",dDataAux)
                    oModelH7F:SetValue("H7F_CODH76",(cAliasTmp1)->ESCALA)
                Endif

            Endif

            cEscala := (cAliasTmp1)->ESCALA + (cAliasTmp1)->PROGRA

            While lRet .AND. (cAliasTmp1)->(!Eof()) .AND. cEscala == (cAliasTmp1)->ESCALA + (cAliasTmp1)->PROGRA                   

                If !Empty((cAliasTmp1)->VEICULO)                    
                    oModelH7G:SetValue("H7G_CODH70",(cAliasTmp1)->VEICULO)                    
                Endif                                

                If !Empty((cAliasTmp1)->MOTORISTA)
                    cMotor := ExcecaoMotorista((cAliasTmp1)->MOTORISTA,(cAliasTmp1)->MOTORISTA_RESERVA,dDataAux)
                    
                    If !Empty(cMotor)
                        oModelH7G:SetValue("H7G_CODGYG",cMotor)
                    Endif
                    
                Endif

                If !Empty((cAliasTmp1)->COBRADOR)
                    oModelH7G:SetValue("H7G_CODCOB",(cAliasTmp1)->COBRADOR)
                Endif

                oModelH7G:SetValue("H7G_CODH76",(cAliasTmp1)->ESCALA)
                oModelH7G:SetValue("H7G_CODH77",(cAliasTmp1)->VIAGEM)
                oModelH7G:SetValue("H7G_SENTID",(cAliasTmp1)->SENTID)
                oModelH7G:SetValue("H7G_HRINIC",(cAliasTmp1)->HRINIC)
                oModelH7G:SetValue("H7G_HRFINA",(cAliasTmp1)->HRFINA)
                oModelH7G:SetValue("H7G_TIPO",'7')
                oModelH7G:SetValue("H7G_JOB"   ,.T.)                

                (cAliasTmp1)->(DBSkip())

                If (cAliasTmp1)->(!Eof()) .AND. cEscala == (cAliasTmp1)->ESCALA + (cAliasTmp1)->PROGRA
                    oModelH7G:AddLine(.T.)
                Endif
                
            EndDo

            lRet := oModel:VldData() .And. oModel:CommitData()            

            IF !lRet				                    
               cErro += "Falha na validação ou gravação do modelo |"
               GrvLog(oModel, "",STR0005)   //"Nova Alocação"
			ENDIF	
            
            oModel:DeActivate()
            cEscala  := ""
        EndDo
        
        dDataAux := DaySum(dDataAux,1)
        (cAliasTmp1)->(DBCloseArea())
    Next nX

    If !lJob .AND. !Empty(cErro)
        FWAlertError(STR0006)//"Ocorreram falhas durante o processamento, verifique o Log"
    Endif

    H7E->(DBCloseArea())
    GTPDestroy(oModelH7G)
    GTPDestroy(oModelH7F)
    GTPDestroy(oModelH7E)
    GTPDestroy(oModel)
    
Return


/*/{Protheus.doc} AjustaRecursos
Realiza o ajuste de recursos alterados
@type function
@author João Pires
@since 14/05/2025
@version 1.0
@param aProc, array, (Descrição do parâmetro)
/*/
Static Function AjustaRecursos(aProc,lJob)
    Local oModel	  := FwLoadModel("GTPU011")    
    Local oModelH7F   := oModel:GetModel('H7FDETAIL')
    Local oModelH7G   := oModel:GetModel('H7GDETAIL')
    Local cAliasTmpA  := GetNextAlias()        
    Local dDataAux    := dDataBase    
    Local cDiaAloc    := ""
    Local nRecno      := 0
    Local cErro       := ""
    Local lRet        := .T.    
    Local cMotor      := ""

    DbSelectArea("H7E")

    dDataAux := DaySum(dDataAux,aProc[1])

    /*Escalas com alocação porém com recurso diferente do padrão*/
    BeginSql Alias cAliasTmpA

       SELECT DISTINCT 
           H7E.R_E_C_N_O_ AS RECH7E,
           H7F.H7F_CODIGO AS DIAALOCADO,
           H7G.H7G_CODIGO AS ALOCACAO,
           H76.H76_VEICUL AS VEICPAD,
           H7G.H7G_CODH70 AS VEICALO,           
           H76.H76_CODMOT AS MOTPAD,
           H76.H76_MOTRES AS MOTRES,
           H7G.H7G_CODGYG AS MOTALO,
           H76.H76_CODCOB AS COBPAD,
           H7G.H7G_CODCOB AS COBALO
       FROM  %Table:H7F% H7F
           INNER JOIN %Table:H7E% H7E
                   ON H7E.H7E_FILIAL = H7F.H7F_FILIAL
                       AND H7E.H7E_CODIGO = H7F.H7F_CODH7E
                       AND H7E.%NotDel%
           INNER JOIN %Table:H76% H76
                   ON H76.H76_FILIAL = %xFilial:H76%
                       AND H76.H76_CODIGO = H7F.H7F_CODH76
                       AND H76.%NotDel%
           INNER JOIN %Table:H7G% H7G
                   ON H7F.H7F_FILIAL = H7G.H7G_FILIAL 
                       AND H7F.H7F_CODH7E = H7G.H7G_CODH7E
                       AND H7F.H7F_CODIGO = H7G.H7G_CODH7F
       WHERE  H7F.%NotDel%
           AND H7F.H7F_FILIAL =  %xFilial:H7F%
           AND H7F.H7F_DATA BETWEEN %Exp:DTOS(dDataBase)% AND %Exp:DTOS(dDataAux)%
           AND H7G.H7G_JOB = 'T'
           AND ( ( H76.H76_CODMOT <> ''
                   AND H7G.H7G_CODGYG <> H76.H76_CODMOT )
                   OR ( H76.H76_VEICUL <> ''
                       AND H7G.H7G_CODH70 <> H76.H76_VEICUL )
                   OR ( H76.H76_CODCOB <> ''
                       AND H7G.H7G_CODCOB <> H76.H76_CODCOB ) )
       ORDER BY H7E.R_E_C_N_O_,
               H7F.H7F_CODIGO,
               H7G_CODIGO         
    EndSql


    While lRet .AND. (cAliasTmpA)->(!Eof())

        H7E->(DBGoTo((cAliasTmpA)->RECH7E))

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        lRet := oModel:IsActive()
        cErro += IIF(lRet,"","Falha na ativação do modelo |")

        nRecno := (cAliasTmpA)->RECH7E

        While (cAliasTmpA)->(!Eof()) .AND. nRecno == (cAliasTmpA)->RECH7E .AND. oModelH7F:SeekLine({{'H7F_CODIGO',(cAliasTmpA)->DIAALOCADO}}) 

            cDiaAloc := (cAliasTmpA)->DIAALOCADO

            While (cAliasTmpA)->(!Eof()) .AND. cDiaAloc == (cAliasTmpA)->DIAALOCADO
                
                If oModelH7G:SeekLine({{'H7G_CODIGO',(cAliasTmpA)->ALOCACAO}}) 
                    
                    If oModelH7G:GetValue('H7G_CODH70') <> (cAliasTmpA)->VEICPAD
                        oModelH7G:SetValue('H7G_CODH70',(cAliasTmpA)->VEICPAD)
                    Endif

                    If oModelH7G:GetValue('H7G_CODGYG') <> (cAliasTmpA)->MOTPAD
                        cMotor := ExcecaoMotorista((cAliasTmpA)->MOTPAD,(cAliasTmpA)->MOTRES,oModelH7F:GetValue('H7F_DATA'))
                        If !Empty(cMotor)
                            oModelH7G:SetValue('H7G_CODGYG',cMotor)
                        Endif
                    Endif

                    If oModelH7G:GetValue('H7G_CODCOB') <> (cAliasTmpA)->COBPAD
                        oModelH7G:SetValue('H7G_CODCOB',(cAliasTmpA)->COBPAD)
                    Endif

                Endif

                (cAliasTmpA)->(DBSkip())
            Enddo

        Enddo

        lRet := oModel:VldData() .And. oModel:CommitData()   
        IF !lRet
		    cErro += "Falha na validação ou gravação do modelo |"
            GrvLog(oModel,"",STR0007) //"Alteração da alocação"               
		ENDIF	
            
        oModel:DeActivate()

    Enddo

    If !lJob .AND. !Empty(cErro)
        FWAlertError(STR0006) //"Ocorreram falhas durante o processamento, verifique o Log"
    Endif

    (cAliasTmpA)->(DBCloseArea())
    H7E->(DBCloseArea())
    
    GTPDestroy(oModelH7G)
    GTPDestroy(oModelH7F)
    GTPDestroy(oModel)
Return

/*/{Protheus.doc} GrvLog
    Grava log
    @type  Static Function
    @author João Pires
    @since 14/05/2025
    @version 1.0
    @param oModel, Objejct, Modelo de dados    
/*/
Static Function GrvLog(oModel,cErroCompl,cProcesso)
    Local aErro := {}
    Local cErro := ""

    aErro := oModel:GetErrorMessage()

    cErro := cErroCompl + CRLF +;
            aErro[3] + CRLF +;
            aErro[4] + CRLF +;
            aErro[6] + CRLF +; 
            aErro[7]
                    
    GtpGrvLgRj(	"URBANO"+'|'+"ALOC. RECURSO",; //"URBANO|ALOC. RECURSO"
				"",;
				cProcesso,;
				"GTPUJ001",;
				"",;
				cErro)

    aSize(aErro,0)
    aErro := Nil

Return .F.

/*/{Protheus.doc} ExcecaoMotorista
    Consulta se o motorista possui restrição na alocação
    @type  Static Function
    @author user
    @since 16/05/2025
    @version version
    @param cMot, Caractere, Código do motorista
    @return cMotor, Caractere, Motorista a ser alocado    
/*/
Static Function ExcecaoMotorista(cMot, cMotRes, dData)
    Local cMotor := ""

    DBSelectArea("H7R")
    H7R->(DBSetOrder(1)) //H7R_FILIAL+H7R_COLAB+DTOS(H7R_DATA)

    If H7R->(DBSeek(xFilial("H7R") + cMot + DTOS(dData)))
        If !Empty(cMotres)
            H7R->(DBSetOrder(1))
            H7R->(DBGoTop())
            If !H7R->(DBSeek(xFilial("H7R") + cMotRes + DTOS(dData)))
                cMotor := cMotRes
            Endif
        Endif
    Else
        cMotor := cMot
    Endif

    H7R->(DBCloseArea())

Return cMotor
