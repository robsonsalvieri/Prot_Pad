#Include "GTPA903C.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA903C
Estorno da apuração e envio para medição do contrato CNTA121
@type Function
@author 
@since 06/04/2021
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA903C()
Local cCorApura := ""
Local cMsgErro  := ''
Local lRet      := .T.

If ValidaDic(@cMsgErro)
    If GQR->GQR_STATUS == "2"
        IF !IsBlind()
            If MsgYesNo(STR0002,STR0001) //'Atenção!' //'Deseja estornar a medição da apuração'
                cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
                FwMsgRun(,{|| PreparaDados(cCorApura,@lRet) },,STR0003 ) //"Estornando medição..."
                AtualContr(cCorApura,lRet)
            EndIf
        Else
            cCorApura := GQR->GQR_CODIGO//Deixado assim para testes
            FwMsgRun(,{|| PreparaDados(cCorApura,@lRet) },,STR0003 ) //"Estornando medição..."
            AtualContr(cCorApura,lRet)
        EndIf
    Else
        FwAlertHelp(STR0005, STR0004,) //"Atenção" //"Status deve estar com apuração efetivada para estornar a medição"
    EndIf
Else
     FwAlertHelp(cMsgErro, STR0006,) //"Atualize o dicionário para utilizar esta rotina"
EndIf
Return lRet


/*/{Protheus.doc} AtualContr
(long_description)
@type  Static Function
@author user
@since 12/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AtualContr(cCorApura,lRet)
Local aArea := GetArea()

DbSelectArea("GQR")
DbSetOrder(1)
If G9W->(DbSeek(xFilial("GQR") + cCorApura))
    If lRet
        RecLock("GQR",.F.)
        GQR->GQR_STATUS := "1"
        GQR->(MsUnLock())
    EndIf
EndIf
RestArea(aArea)

Return 

/*/{Protheus.doc} PreparaDados
(long_description)
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PreparaDados(cCorApura,lRet)
    
    Local cAliasTmp := ""  
    Local cCodCTR   := "" 
    Local cRevisao  := ""
    Local cMedicao  := ""
    Local cApuracao := ""
    Local cOrcamento:= ""
    Local cMedErro  := ""
    Local lBreak    := ""
    
    Default cCorApura := ""
    Default lRet      := .T.

    cAliasTmp := QueryOrcamento(cCorApura)
    
    If (cAliasTmp)->(!Eof())
        
        lBreak := (cAliasTmp)->(G9W_CONTRA+G9W_REVISA+G54_CODCND) <>; 
                    cCodCTR+cRevisao+cMedicao
        
        Begin Transaction

            While (cAliasTmp)->(!Eof())
                
                If ( lBreak )
                    lRet := EstornaMedicao((cAliasTmp)->G9W_CONTRA,(cAliasTmp)->G54_CODCND,(cAliasTmp)->G9W_REVISA,@cMedErro)
                EndIf            

                cCodCTR     := (cAliasTmp)->G9W_CONTRA
                cRevisao    := (cAliasTmp)->G9W_REVISA    
                cMedicao    := (cAliasTmp)->G54_CODCND
                cApuracao   := (cAliasTmp)->G9W_CODGQR
                cOrcamento  := (cAliasTmp)->G9W_NUMGY0

                (cAliasTmp)->(DbSkip())

                lBreak := (cAliasTmp)->(G9W_CONTRA+G9W_REVISA+G54_CODCND) <>; 
                            cCodCTR+cRevisao+cMedicao

                If ( lRet .And. lBreak )
                    
                    lRet := ExcluiMedicao(cCodCTR, cRevisao, @cMedErro, cMedicao) .And.;
                                AtualizaContr(cApuracao,cOrcamento,cRevisao,cMedicao) 
                EndIf

                If ( !lRet )                    
                    Exit
                EndIf

            EndDo

            If ( !lRet )
                DisarmTransaction()                    
                Help(,,"GTPA903CApur",, cMedErro, 1,0)
                lRet := .F.
            EndIf
        End Transaction

    Else
        Help(,,"GTPA903CApur",, STR0007, 1,0) //"Não foram encontrados dados"
        lRet := .F.
    EndIf

    (cAliasTmp)->(DbCloseArea())

Return()

/*/{Protheus.doc} AtualizaContr
Atualiza a tabela 'Totais da Linha Apuração Orçam' limpando o campo G54_CODCND (Numero de medição)
@type  Static Function
@author user
@since 08/04/2021
@version 1.0
@param cCodGqr,  String, Cód.Apuração
@param cNumGy0,  String, Nº Orç.Contr
@param cRevisao, String, Revisão     
@param cMedicao, String, Numero de medição
@return lRet, boolean, .T. se a alteração foi feita com sucesso
/*/
Static Function AtualizaContr(cCodGqr,cNumGy0,cRevisao,cMedicao)
    
    Local aArea     := GetArea()
    Local aSeek     := {}
    Local aResult   := {}
    Local nI        := 0
    Local lRet      := .F.   
    
    aAdd(aSeek,{"G54_CODGQR",cCodGqr})
    aAdd(aSeek,{"G54_NUMGY0",cNumGy0})
    aAdd(aSeek,{"G54_REVISA",cRevisao})
    aAdd(aSeek,{"G54_CODCND",cMedicao})

    If ( GTPSeekTable("G54",aSeek,aResult) .And. Len(aResult) > 1 ) 
    
        For nI := 2 to Len(aResult)
            G54->(DbGoTo(aResult[nI][Len(aResult[nI])]))
            RecLock("G54",.F.)
                G54->G54_CODCND := ""
            G54->(MsUnLock())      
        Next nI

        lRet := .T.

    EndIf

    RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} EstornaMedicao
(long_description)
@type  Static Function
@author user
@since 09/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function EstornaMedicao(cCodCTR,cMedicao,cRevisao,cMedErro)
   
    Local lRet      := .F.

    Local aAreaCND  := CND->(GetArea())

    Default cCodCTR     := ""
    Default cRevisao    := Posicione("CN9",7,xFilial("CN9")+cCodCTR+"05","CN9_REVISA")

    CND->(DbSetOrder(7))    //CND_FILIAL, CND_CONTRA, CND_REVISA, CND_NUMERO, CND_NUMMED
    
    If CND->(DbSeek(xFilial("CND") + PadR(cCodCTR,TamSx3("CND_CONTRA")[1]) + PadR(cRevisao,TamSx3("CND_REVISA")[1]) + cMedicao ))//Posicionar na CND para realizar o estorno
        CN121Estorn(.t.,/*lAprRev*/, @cMedErro)
        lRet := Empty(cMedErro) //Vazio caso nao ocorra nenhum erro
    EndIf 
    
    RestArea(aAreaCND)

Return lRet

/*/{Protheus.doc} ExcluiMedicao
Exclui a medição que já foi estornada
@type  Static Function
@author user
@since 13/04/2021
@version 2.0
@param cCodCTR - string - Código do contrato
@param cRevisa - string - Código revisão
@param cMedicao- string - Código medição 
@param cMedErro- string - Mensagem de erro, se houver
@return lRet - .T. Se a exclusão for executada corretamente
/*/
Static Function ExcluiMedicao(cCodCTR, cRevisa, cMedErro, cMedicao)

    Local oModel    := Nil
    Local aAreaCND  := CND->(GetArea())
    Local lRet      := .F.
    
    CND->(DbSetOrder(7))
    If CND->(DbSeek(xFilial("CND") + PadR(cCodCTR,TamSx3("CND_CONTRA")[1]) + PadR(cRevisa,TamSx3("CND_REVISA")[1]) + cMedicao ))//Posicionar na CND para realizar a exclusão
        oModel := FWLoadModel("CNTA121")

        oModel:SetOperation(MODEL_OPERATION_DELETE)
        If(oModel:CanActivate())          
            oModel:Activate()
            If (oModel:VldData()) /*Valida o modelo como um todo*/
                oModel:CommitData()
            EndIf
        EndIf
        
        lRet := !(oModel:HasErrorMessage())

        If(!lRet)
            cMedErro := Alltrim(oModel:GetErrorMessage()[6]) + ". " + Alltrim(oModel:GetErrorMessage()[7])
        EndIf

        If ( oModel:IsActive() )    
            oModel:DeActivate()
        EndIf
            
    EndIf 

    RestArea(aAreaCND)
Return lRet
/*/{Protheus.doc} QueryOrcamento
Query para retornar os dados da apuração e orçamento para a medição
@type  Static Function
@author user
@since 08/04/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function QueryOrcamento(cCorApura)

    Local cAliasAUX := ''

    Default cCorApura := ''

    cAliasAUX := GetNextAlias()

    BeginSQL alias cAliasAUX

        SELECT
            DISTINCT
            G9W.G9W_CONTRA,
            G9W.G9W_REVISA,
            G54.G54_CODCND,
            G9W.G9W_CODGQR, 
            G9W.G9W_NUMGY0            
        FROM
            %Table:GQR% GQR
        INNER JOIN
            %Table:G9W% G9W
        ON
            G9W.G9W_FILIAL     = GQR.GQR_FILIAL
            AND G9W.G9W_CODGQR = GQR.GQR_CODIGO
            AND G9W.%NotDel%
        INNER JOIN
             %Table:GYD% GYD
        ON
            GYD.%NotDel%
            AND GYD.GYD_FILIAL = G9W.G9W_FILIAL
            AND GYD.GYD_NUMERO = G9W.G9W_NUMGY0	
        INNER JOIN
             %Table:G54% G54
        ON
            G54.%NotDel%
            AND G54.G54_FILIAL = G9W.G9W_FILIAL 
            AND G54.G54_NUMGY0 = G9W.G9W_NUMGY0
            AND G54.G54_REVISA = G9W.G9W_REVISA
            AND G54.G54_CODGQR = GQR.GQR_CODIGO
            AND G54.G54_CODGI2  = GYD.GYD_CODGI2
        WHERE
            GQR.GQR_FILIAL     = %xFilial:GQR%
            AND GQR.GQR_CODIGO = %exp:cCorApura%
            AND GQR.%NotDel%
        ORDER BY
            G9W.G9W_CONTRA,
            G9W.G9W_REVISA,
            G54.G54_CODCND

    EndSql

Return cAliasAUX

/*/{Protheus.doc} ValidDic
//TODO Descrição auto-gerada.
@author flavio.martins
@since 31/03/2021
@version 1.0
@return ${return}, ${return_description}
@param
@type function
/*/
Static Function ValidaDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'GYD','GQR','G9W','G54'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'G9W_CONTRA','G54_PRODUT','G54_PRODNT',;
            'G54_QTDE','GYD_PRECON','GYD_VLRTOT',;
            'GYD_PREEXT','GYD_VLREXT'}

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

For nX := 1 To Len(aFields)
    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
        lRet := .F.
        cMsgErro := I18n(STR0008,{aFields[nX]}) //"Campo #1 não se encontra no dicionário"
        Exit
    Endif
Next

Return lRet
