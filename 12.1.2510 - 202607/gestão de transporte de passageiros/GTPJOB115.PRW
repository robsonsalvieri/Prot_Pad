#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPJOB115.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPJOB115(aParam)

Função utilizada para consumir o serviço através de um JOB - Integração com sistema RJINTEGRA
Integração dados de bilhetes

@type 		function
@sample 	GTPJOB115(aParam)
@param		aParam, array - lista de parâmetros 	 	
@return 	
@author 	jose.darocha
@since 		01/04/2025
@version 	1.0
/*/
//------------------------------------------------------------------------------------------
Function GTPJOB115(aParam)
    Local oRJIntegra  := Nil
    Local dDataRef    := Nil
    Local aFldDePara  := {}
    Local aDeParaXXF  := {}
    Local nDias       := 0
    Local nTotReg     := 0
    Local nX          := 0
    Local cResultAuto := ''
    Local cNumProtocol:= ''
    Local cAliasQry   := ''
    Local cDataHorVend:= ''
    Local cBilhete    := ''
    Local cCodEmpresa := ''
    Local cCodFilial  := ''
    Local cRefer1     := ''

    If aParam <> NIL

        cCodEmpresa := aParam[1]
        cCodFilial  := aParam[2]

        RpcSetType(3)
        RpcSetEnv(cCodEmpresa,cCodFilial,,,'GTP')

        nDias   := GTPGetRules("QTDDIASJOB",,,1)
        dDataRef:= dDataBase - nDias

        cAliasQry := GetNextAlias()

        BeginSql Alias cAliasQry
            Select GIC_BILHET, GIC_EMPRJI, GIC_DTVEND, GIC_HRVEND, R_E_C_N_O_ AS REGS
            From %table:GIC%
            Where GIC_FILIAL = %xFilial:GIC%
            and GIC_DTVEND >= %exp:Dtos(dDataRef)%
            and GIC_NUMPRO = '000000000000000'
            and GIC_STAPRO = '0'
            and (GIC_STABPE = -1 OR GIC_STABPE = -2)
            and %NotDel%
        EndSql 

        If (cAliasQry)->(!Eof())

            DbSelectArea("GIC")

            While (cAliasQry)->(!Eof())

                cDataHorVend := Alltrim( Left(FWTimeStamp(1, Stod((cAliasQry)->GIC_DTVEND)),8) +  STRTRAN((cAliasQry)->GIC_HRVEND,":","") )

                oRJIntegra:= GtpRjIntegra():New()
                oRJIntegra:SetPath("/bilhete/venda2")
                oRJIntegra:SetServico('Bilhete')
                oRJIntegra:SetParam('empresa'        , ALLTRIM((cAliasQry)->GIC_EMPRJI))
                oRJIntegra:SetParam('dataHoraInicial', cDataHorVend)
                oRJIntegra:SetParam('dataHoraFinal'	 , cDataHorVend)

                aFldDePara	:= aClone(oRJIntegra:GetFieldDePara())
                aDeParaXXF  := aClone(oRJIntegra:GetFldXXF())
                oRJIntegra:SetServico('Bilhete')

                If oRJIntegra:Get(cResultAuto)    

                    nTotReg := oRJIntegra:GetLenItens()
                
                    nTotReg := IIf( (GTPDummyRunning() .and. nTotReg > GTPDummyVal()), GTPDummyVal(), nTotReg)

                    If ( nTotReg >= 0 )

                        For nX:= 0 To nTotReg

                            cBilhete := oRJIntegra:GetJsonValue(nX, 'idTransacao', 'C')

                            If Alltrim(cBilhete) == Alltrim((cAliasQry)->GIC_BILHET)

                                cNumProtocol:= oRJIntegra:GetJsonValue(nX, 'numProtocolo', 'C')
                                cRefer1     := oRJIntegra:GetJsonValue(nX, 'numerobpe', 'C')

                                GtpGrvLgRj(	STR0001,; //"Contigência"
                                            oRJIntegra:cUrl,;
                                            oRJIntegra:cPath,;
                                            'GTPJOB115',;
                                            oRJIntegra:cParam,;
                                            STR0002+cBilhete,; //'Atualização número protocolo bilhete: '
                                            Nil,;
                                            cRefer1)   

                                GIC->(DbGoTo( (cAliasQry)->REGS ))  
                                RecLock("GIC",.F.)
                                    GIC->GIC_NUMPRO := cNumProtocol
                                GIC->(MsUnlock())    

                            EndIf 

                        Next nX 

                        FwFreeObj(oRJIntegra)

                    EndIf 

                EndIf 

                GTPDestroy(aFldDePara)
                GTPDestroy(aDeParaXXF)

                (cAliasQry)->(DbSkip())

            EndDo 

        EndIf 

        (cAliasQry)->(DbCloseArea())   

        RpcClearEnv() 

    EndIf 

Return 
