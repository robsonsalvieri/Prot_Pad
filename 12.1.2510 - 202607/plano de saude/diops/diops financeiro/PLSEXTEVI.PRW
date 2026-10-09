#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_CODITEM 1
#define DAD_VLMES1  2
#define DAD_VLMES2  3
#define DAD_VLMES3  4

/*/{Protheus.doc} PLSEXTEVI
Extrator DIOPS Financeiro
Movimentação de Eventos Indenizáveis
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTEVI(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCEVIN")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Movimentação de Eventos Indenizáveis
    dbSelectArea("B8L")
    B8L->(dbSetOrder(1) )   //B8L_FILIAL+B8L_CODOPE+B8L_CODOBR+B8L_ANOCMP+B8L_CDCOMP+B8L_CODIGO

    // Retorno dos dados 
    Processa({||aDados := fRetDados()},"Aguarde","Gerando dados...",.t.)    
    
    // Verifica se possui dados para processar no quadro 
    If Len(aDados)>0
        // Total de registros
        nRegua  := Len(aDados)
        oProcess:SetRegua2(nRegua)

        // Processa a inclusao dos registros 
        For nI := 1 to Len(aDados)
            oProcess:IncRegua2()

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("B8LMASTER","B8L_FILIAL", xFilial("B8L") )
            oModel:SetValue("B8LMASTER","B8L_CODOPE", B3D->B3D_CODOPE )
            oModel:SetValue("B8LMASTER","B8L_CODOBR", B3D->B3D_CDOBRI )
            oModel:SetValue("B8LMASTER","B8L_ANOCMP", B3D->B3D_ANO )
            oModel:SetValue("B8LMASTER","B8L_CDCOMP", B3D->B3D_CODIGO )                
            oModel:SetValue("B8LMASTER","B8L_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )
            oModel:SetValue("B8LMASTER","B8L_CODIGO", aDados[nI,DAD_CODITEM] )
            oModel:SetValue("B8LMASTER","B8L_VLMES1", aDados[nI,DAD_VLMES1] )
            oModel:SetValue("B8LMASTER","B8L_VLMES2", aDados[nI,DAD_VLMES2] )
            oModel:SetValue("B8LMASTER","B8L_VLMES3", aDados[nI,DAD_VLMES3] )
            oModel:SetValue("B8LMASTER","B8L_STATUS", "1" )            

            If oModel:VldData()
                oModel:CommitData()
                nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão do Item "+aDados[nI,DAD_CODITEM]+": "+cLog) 
            EndIf

            oModel:DeActivate()
        Next    
    EndIf     

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return({nTotal,aRet})

/*/{Protheus.doc} fRetDados
Retorna dados 
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetDados()
Local cAliasTrb := GetNextAlias()
Local cAlias    := "B8L"
Local cQuery    := ""
Local nI
Local nX
Local nPos
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local cFiltro   := ""
Local cCodItem
Local dDataIni
Local dDataFim
Local nMeses
Local cMesCmp
Local cMoeda    := "01"
Local cTpSald   := "1"
Local nValorCtb := 0
Local aCodEVE := {"33","34","35","36","37","38","39","40","41","42","43","44","45","46"}    // Eventos
Local aCodGLO := {"47","48","49","50","51","52","53","54","55","56","57","58","59","60"}    // Glosas 
Local aCodREC := {"65","66","67","68","69","70","71","72","73","74","75","76","77","78"}    // Recuperacao/Copart
Local aCodPEO := {"79"} // PEONA
Local cCodEVI
Local cCContabil
Local cCCusto
Local aRet      := {}
Local cTipoBanco := Alltrim(Upper(TCGetDb()))

    // Query utilizada para retornar os itens do quadro
    BeginSQL Alias cAliasTrb
        SELECT B3Y_ITEM
          FROM %Table:B3Y% B3Y
          INNER JOIN %Table:B3I% B3I  ON B3I_FILIAL=B3Y_FILIAL AND B3I_CODIGO=B3Y_CODIGO AND B3I_ALIAS=%Exp:cAlias% AND B3I.%NotDel%
        WHERE B3Y_FILIAL=%xFilial:B3Y%
        AND B3Y.%NotDel%
        ORDER BY B3Y_ITEM
    EndSQL

    (cAliasTrb)->(dbGotop())
    While (cAliasTrb)->(!Eof())
        cCodItem   := Alltrim((cAliasTrb)->B3Y_ITEM)

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Retorno da função: RetParDIOPS                     ³
        //³ [1] Codigo do Item 	                               ³
        //³ [2] Conta Contabil      		                   ³
        //³ [3] Centro de Custo     	                       ³
        //³ [4] Descricao do Identificador                 	   ³        
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ          
        aContas := RetParDIOPS(cAlias,cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]    

        // Calcula o numero de meses para geracao do quadro
        nMeses := DateComp(dDataIni, dDataFim, "MM")

        If lAchouCta
            // Processa o quadro para a quantidade de meses calculada no compromisso Diops
            For nI := 0 to nMeses   /*inicia em 0 (zero) para considerar o mês atual*/

                // Recalcula datas inicio e fim para utilizar periodo mensal (DIOPS Simplificado)
                dDataIni := MsSomaMes(dDataIni, IIf(nI>0,1,0))
                dDataFim := LastDay(dDataIni)

                If cCodItem == "PEO"
                    // Calcula PEONA
                    cMesCmp := StrZero(nI+1,2)
                    cCodEVI := aCodPEO[1]
                    nValorCtb := 0

                    // Monta query 
                    cQuery := "SELECT CT1_CONTA, CT1_CLASSE, "
                    cQuery += " '"+cCodItem+"' AS CODITEM "
                    cQuery += " FROM "+RetSQLName("CT1")+" CT1 "
                    cQuery += " WHERE CT1_FILIAL = "+ValToSQL(xFilial("CT1"))

                    // Montagem do filtro relacionado as contas contabeis cadastradas no configurador Diops Financeiro 
                    cFiltro := ""
                    For nX := 1 to Len(aContas)
                        cCContabil := Alltrim(aContas[nX,2])  // Conta Contabil 
                        cCCusto    := Alltrim(aContas[nX,3])  // Centro de Custo 
                        cFiltro    += "(CT1_CONTA LIKE "+ValToSQL(cCContabil+"%")+") OR" 
                    Next 

                    If !Empty(cFiltro)
                        cQuery += " AND ("+Substr(cFiltro,1,Len(cFiltro)-2)+") "
                    Endif

                    cQuery += "   AND CT1_CLASSE='2' "  
                    cQuery += "   AND CT1.D_E_L_E_T_ = '' "
                    cQuery += " ORDER BY CODITEM, CT1_CONTA "

                    cQuery := ChangeQuery(cQuery)
                    MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTEVI_"+cCodItem+".log",cQuery)    
                    
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBEVI",.F.,.T.)	
                    TRBEVI->(dbGotop())

                    While TRBEVI->(!Eof())
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //³ Retorno:                                           ³
                        //³ [1] Movimento Devedor 	                           ³
                        //³ [2] Movimento Credor		                       ³
                        //³ [3] Movimento do Mes		                       ³
                        //³ [4] Saldo Final                                	   ³
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                        nValorCtb += MovConta(TRBEVI->CT1_CONTA,dDataIni,dDataFim,cMoeda,cTpSald,3 /*Tipo de Retorno*/)

                        TRBEVI->(dbSkip())
                    EndDo 

                    TRBEVI->(dbCloseArea())

                    nPos := aScan(aRet,{|x| x[DAD_CODITEM]==cCodEVI})

                    If nPos == 0 
                        aAdd(aRet,{cCodEVI,0,0,0})
                        nPos := Len(aRet)
                    EndIf                 

                    aRet[nPos, DAD_VLMES1] += Iif(cMesCmp=="01",nValorCtb,0)
                    aRet[nPos, DAD_VLMES2] += Iif(cMesCmp=="02",nValorCtb,0)
                    aRet[nPos, DAD_VLMES3] += Iif(cMesCmp=="03",nValorCtb,0)
                Else
                    // Calcula demais valores dos eventos (Pagamento, Glosa e Coparticipacao)
                    cQuery := " SELECT OCORRENCIA, "
                    cQuery += "       Sum(VALOR) AS VALOR "
                    cQuery += " FROM   (SELECT "
                    cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                            " DATEDIFF(MONTH, BD7_DATPRO, BD7_DTCTBF) AS OCORRENCIA,",;
                            " TO_NUMBER(TO_DATE(BD7_DATPRO,'YYYYMMDD')-TO_DATE(BD7_DTCTBF,'YYYYMMDD')) AS OCORRENCIA,")

                    If cCodItem == "EVE"
                        cQuery += " BD7_VLRPAG AS VALOR "
                    ElseIf cCodItem == "GLO"
                        cQuery += " BD7_VLRGLO AS VALOR "
                    Elseif cCodItem == "REC"
                        cQuery += " BD7_VLRTPF AS VALOR "
                    EndIf 

                    cQuery += " FROM   "+RetSQLName("BD7")+" BD7 "

                    //cv3
                    cQuery += " INNER JOIN "+RetSQLName("CV3")+" CV3 "
                    cQuery += "    ON CV3_FILIAL = "+ValToSQL(xFilial("CV3"))
                    cQuery += "    AND CV3_TABORI = 'BD7' "
                    cQuery += "    AND CV3_RECORI = BD7.R_E_C_N_O_ "
                    cQuery += "    AND CV3.D_E_L_E_T_ = '' "

                    // Montagem do filtro relacionado as contas contabeis cadastradas no configurador Diops Financeiro 
                    cFiltro := ""
                    For nX := 1 to Len(aContas)
                        cCContabil := Alltrim(aContas[nX,2])  // Conta Contabil 
                        cCCusto    := Alltrim(aContas[nX,3])  // Centro de Custo 

                        If !Empty(cCCusto)
                            cFiltro += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCC LIKE "+ValToSQL(cCCusto+"%")+") OR"
                        Else
                            cFiltro += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+") OR"
                        EndIf 
                    Next 

                    If !Empty(cFiltro)
                        cQuery += " AND ("+Substr(cFiltro,1,Len(cFiltro)-2)+") "
                    Endif

                    cQuery += " WHERE  BD7_FILIAL = "+ValToSQL(xFilial("BD7"))
                    cQuery += "        AND BD7_SITUAC = '1' "
                    cQuery += "        AND BD7_FASE = '4' "
                    cQuery += "        AND BD7_DTCTBF BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)+") AS TRBQRY "
                    cQuery += " WHERE  OCORRENCIA >= 0 "
                    cQuery += " GROUP  BY OCORRENCIA "
                    cQuery += " ORDER  BY OCORRENCIA "

                    cQuery := ChangeQuery(cQuery)
                    MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTEVI_"+cCodItem+".log",cQuery)    

                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBEVI",.F.,.T.)	
                    TRBEVI->(dbGotop())

                    While TRBEVI->(!Eof())
                        cMesCmp := StrZero(nI+1,2)
                        cCodEVI := ""

                        If     cCodItem == "EVE"
                            cCodEVI := aCodEVE[Iif(TRBEVI->OCORRENCIA<13,TRBEVI->OCORRENCIA+1,Len(aCodEVE))]
                        ElseIf cCodItem == "GLO"
                            cCodEVI := aCodGLO[Iif(TRBEVI->OCORRENCIA<13,TRBEVI->OCORRENCIA+1,Len(aCodGLO))]
                        ElseIf cCodItem == "REC"
                            cCodEVI := aCodREC[Iif(TRBEVI->OCORRENCIA<13,TRBEVI->OCORRENCIA+1,Len(aCodREC))]
                        EndIf 

                        If !Empty(cCodEVI)
                            nPos := aScan(aRet,{|x| x[DAD_CODITEM]==cCodEVI})

                            If nPos == 0 
                                aAdd(aRet,{cCodEVI,0,0,0})
                                nPos := Len(aRet)
                            EndIf 

                            aRet[nPos, DAD_VLMES1] += Iif(cMesCmp=="01",TRBEVI->VALOR,0)
                            aRet[nPos, DAD_VLMES2] += Iif(cMesCmp=="02",TRBEVI->VALOR,0)
                            aRet[nPos, DAD_VLMES3] += Iif(cMesCmp=="03",TRBEVI->VALOR,0)
                        EndIf 

                        TRBEVI->(dbSkip())
                    EndDo 

                    TRBEVI->(dbCloseArea())
                Endif
            Next    
        EndIf 

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())

Return(aRet)
