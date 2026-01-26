#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_VENCTO 1
#define DAD_EVESUS 2
#define DAD_EVENTO 3 
#define DAD_COMERC 4 
#define DAD_DEBOPE 5 
#define DAD_OUDBOP 6 
#define DAD_TITSEN 7 
#define DAD_DEPBEN 8
#define DAD_SERASS 9
#define DAD_AQUCAR 10 
#define DAD_OUDBPG 11

/*/{Protheus.doc} PLSEXTIPG
Extrator DIOPS Financeiro
Idade dos Saldos - A Pagar                                           
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTIPG(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCIDSA")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Idade dos Saldos - A Pagar    
    dbSelectArea("B8F")
    B8F->(dbSetOrder(1) )   //B8F_FILIAL+B8F_CODOPE+B8F_CODOBR+B8F_ANOCMP+B8F_CDCOMP+B8F_VENCTO

    // Gera dados  
    Processa({||aDados := fRetDados()},"Aguarde","Gerando dados...",.t.)

    If Len(aDados)>0
        // Total de registros
        nRegua  := Len(aDados)
        oProcess:SetRegua2(nRegua)

        // Processa a inclusao dos registros 
        For nI := 1 to Len(aDados)
            oProcess:IncRegua2()    

            // Processa a inclusao dos registros 
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("B8FMASTER","B8F_FILIAL", xFilial("B8F") )
            oModel:SetValue("B8FMASTER","B8F_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("B8FMASTER","B8F_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("B8FMASTER","B8F_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("B8FMASTER","B8F_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("B8FMASTER","B8F_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )     
            oModel:SetValue("B8FMASTER","B8F_VENCTO", aDados[nI, DAD_VENCTO] ) 
            oModel:SetValue("B8FMASTER","B8F_EVESUS", aDados[nI, DAD_EVESUS] ) 
            oModel:SetValue("B8FMASTER","B8F_EVENTO", aDados[nI, DAD_EVENTO] ) 
            oModel:SetValue("B8FMASTER","B8F_COMERC", aDados[nI, DAD_COMERC] ) 
            oModel:SetValue("B8FMASTER","B8F_DEBOPE", aDados[nI, DAD_DEBOPE] ) 
            oModel:SetValue("B8FMASTER","B8F_OUDBOP", aDados[nI, DAD_OUDBOP] ) 
            oModel:SetValue("B8FMASTER","B8F_TITSEN", aDados[nI, DAD_TITSEN] ) 
            oModel:SetValue("B8FMASTER","B8F_DEPBEN", aDados[nI, DAD_DEPBEN] ) 
            oModel:SetValue("B8FMASTER","B8F_SERASS", aDados[nI, DAD_SERASS] ) 
            oModel:SetValue("B8FMASTER","B8F_AQUCAR", aDados[nI, DAD_AQUCAR] )
            oModel:SetValue("B8FMASTER","B8F_OUDBPG", aDados[nI, DAD_OUDBPG] )  
            oModel:SetValue("B8FMASTER","B8F_STATUS", "1" )

            // Valida o modelo de dados
            If oModel:VldData()
                oModel:CommitData()
                nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão do Quadro: "+cLog) 
            EndIf

            oModel:DeActivate()
        Next
    Endif

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return({nTotal,aRet})

/*/{Protheus.doc} fRetDados()
Grava valores apurados ao fim do trimestre
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetDados()
Local cAliasTrb := GetNextAlias()
Local cAlias    := "B8F"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local nDiasAtr
Local cCodItem
Local cCodVcto
Local nX
Local nPos
Local cFilQry
Local cCContabil
Local cCCusto
Local aRet      := {}
Local cTipoBanco := Alltrim(Upper(TCGetDb()))
Local lPlsAtv    := GetNewPar("MV_PLSATIV",.F.)

    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
    //³ Código	Distribuição dos Saldos de Contas a Pagar            ³
    //³ 000	A Vencer                                                 ³
    //³ 030	Vencidos 1-30 dias                                       ³
    //³ 060	Vencidos 31-60 dias                                      ³
    //³ 090	Vencidos 61-90 dias                                      ³
    //³ 120	Vencidos 91-120 dias                                     ³
    //³ 999	Vencidos +120 dias                                       ³    
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
    aAdd(aRet,{"000",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"030",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"060",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"090",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"120",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"999",0,0,0,0,0,0,0,0,0,0})

    If lPlsAtv
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
            aContas := RetParDIOPS(cAlias, cCodItem)

            // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
            lAchouCta := Len(aContas)>0

            // Só vai processar caso tenha amarracao de contas no configurador
            If lAchouCta        
                // Calcula periodo de datas do trimestre 
                aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
                dDataIni    := aPeriodo[1]
                dDataFim    := aPeriodo[2]    

                // Monta query 
                cQuery := " SELECT "+ValToSQL(cCodItem)+" AS CODITEM, " 
                cQuery += "       VENCIMENTO, "
                cQuery += "       Sum(VALOR) AS VALOR "
                cQuery += " FROM   (SELECT "
                cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                        " DATEDIFF(DAY, E2_VENCTO, CONVERT(DATE, "+ValToSQL(dDataFim)+", 103)) AS VENCIMENTO,",;
                        " TRUNC(TO_DATE("+ValToSQL(dDataFim)+", 'YYYY-MM-DD') - E2_VENCTO) AS VENCIMENTO,")           
                cQuery += "               BD7_VLRPAG AS VALOR  "
                cQuery += "        FROM   "+RetSQLName("BD7")+" BD7 " 
                cQuery += "               INNER JOIN "+RetSQLName("SE2")+" SE2 "
                cQuery += "                       ON E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|'
                cQuery += "                          + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|'
                cQuery += "                          + E2_LOJA = BD7_CHKSE2
                cQuery += "                          AND SE2.D_E_L_E_T_ = ''

                //CV3
                cQuery += " INNER JOIN "+RetSQLName("CV3")+" CV3 "
                cQuery += "    ON CV3_FILIAL = "+ValToSQL(xFilial("CV3"))
                cQuery += "    AND CV3_TABORI = 'BD7' "
                cQuery += "    AND CV3_RECORI = BD7.R_E_C_N_O_ "
                cQuery += "    AND CV3.D_E_L_E_T_ = '' "

                // Montagem do filtro relacionado as contas contabeis cadastradas no configurador Diops Financeiro 
                cFilQry := ""
                For nX := 1 to Len(aContas)
                    cCContabil := Alltrim(aContas[nX,2])  // Conta Contabil 
                    cCCusto    := Alltrim(aContas[nX,3])  // Centro de Custo 

                    If !Empty(cCCusto)
                        cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCC LIKE "+ValToSQL(cCCusto+"%")+") OR"
                    Else
                        cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+") OR"
                    EndIf 
                Next 

                If !Empty(cFilQry)
                    cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
                Endif

                cQuery += "        WHERE  BD7_FILIAL = "+ValToSQL(xFilial("BD7"))
                cQuery += "               AND BD7_VLRPAG > 0 "
                cQuery += "               AND ( E2_BAIXA = '' OR E2_BAIXA > "+ValToSQL(dDataFim)+") "
                cQuery += "               AND E2_EMISSAO < "+ValToSQL(dDataFim)+") AS TRBQRY"
                cQuery += " GROUP  BY VENCIMENTO "
                cQuery += " ORDER  BY VENCIMENTO "

                cQuery := ChangeQuery(cQuery)
                
                MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTIPG_"+cCodItem+".log",cQuery)    

                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBIPG",.F.,.T.)	
                TRBIPG->(dbGotop())

                While TRBIPG->(!Eof())
                    nDiasAtr := TRBIPG->VENCIMENTO
                    cCodVcto := ""

                    // Atribui o codigo do item de acordo com o prazo de vencimento 
                    Do Case
                        Case nDiasAtr <= 0 
                            cCodVcto := "000"
                        Case nDiasAtr > 0 .And. nDiasAtr <= 30 
                            cCodVcto := "030"
                        Case nDiasAtr > 30 .And. nDiasAtr <= 60 
                            cCodVcto := "060"
                        Case nDiasAtr > 60 .And. nDiasAtr <= 90
                            cCodVcto := "090"
                        Case nDiasAtr > 90 .And. nDiasAtr <= 120
                            cCodVcto := "120"
                        OtherWise    
                            cCodVcto := "999"
                    EndCase

                    // Posiciona no item  para soma dos valores 
                    nPos := aScan(aRet,{|x| x[DAD_VENCTO]==cCodVcto})

                    // Soma valor 
                    aRet[nPos,DAD_EVENTO] += IIf(TRBIPG->CODITEM=="EVE",TRBIPG->VALOR,0)    //Eventos/Sinistros a Liquidar    
                    aRet[nPos,DAD_EVESUS] += IIf(TRBIPG->CODITEM=="SUS",TRBIPG->VALOR,0)    //Eventos ou sinistros a liquidar referente ao ressarcimento SUS                                                                                                                                                                                            
                    aRet[nPos,DAD_COMERC] += IIf(TRBIPG->CODITEM=="CSO",TRBIPG->VALOR,0)    //Comercialização sobre Operações                                                                                                                                                                                                                           
                    aRet[nPos,DAD_DEBOPE] += IIf(TRBIPG->CODITEM=="DOP",TRBIPG->VALOR,0)    //Débitos com outras operadoras                                                                                                                                                                                                                             
                    aRet[nPos,DAD_OUDBOP] += IIf(TRBIPG->CODITEM=="ODO",TRBIPG->VALOR,0)    //Outros débitos com operadoras de saúde                                                                                                                                                                                                                    
                    aRet[nPos,DAD_TITSEN] += IIf(TRBIPG->CODITEM=="TOE",TRBIPG->VALOR,0)    //Títulos e outros encargos a recolher                                                                                                                                                                                                                      
                    aRet[nPos,DAD_DEPBEN] += IIf(TRBIPG->CODITEM=="DEP",TRBIPG->VALOR,0)    //Depósitos realizados por beneficiários                                                                                                                                                                                                                    
                    aRet[nPos,DAD_SERASS] += IIf(TRBIPG->CODITEM=="ASS",TRBIPG->VALOR,0)    //Serviços de assistência à saúde                                                                                                                                                                                                                           
                    aRet[nPos,DAD_AQUCAR] += IIf(TRBIPG->CODITEM=="AQC",TRBIPG->VALOR,0)    //Débitos com aquisição de carteira de beneficiários                                                                                                                                                                                                        
                    aRet[nPos,DAD_OUDBPG] += IIf(TRBIPG->CODITEM=="ODP",TRBIPG->VALOR,0)    //Outros Debitos a Pagar                                                                                                                                                                                                                                    

                    TRBIPG->(dbSkip())
                EndDo 

                TRBIPG->(dbCloseArea())
            EndIf

            (cAliasTrb)->(dbSkip())
        EndDo

        (cAliasTrb)->(dbCloseArea())
    Else
        aRet := fRetSldISP()
    Endif 

Return(aRet)


/*/{Protheus.doc} fRetSldISP()
Retorna valores da contabilidade
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetSldISP()

Local aRet  := {}
Local nDiavcto	:= 0
Local cAlias    := "B8F"
Local aContas   := {}
Local lAchouCta
Local nI
Local aPeriodo  := {}
Local cCodItem
Local cAliasTrb := GetNextAlias()
Local cSql
Local cCodVcto
Local nPos
Local cTipoBanco := Alltrim(Upper(TCGetDb()))

    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
    //³ Código	Distribuição dos Saldos de Contas a Pagar            ³
    //³ 000	A Vencer                                                 ³
    //³ 030	Vencidos 1-30 dias                                       ³
    //³ 060	Vencidos 31-60 dias                                      ³
    //³ 090	Vencidos 61-90 dias                                      ³
    //³ 120	Vencidos 91-120 dias                                     ³
    //³ 999	Vencidos +120 dias                                       ³    
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
    aAdd(aRet,{"000",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"030",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"060",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"090",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"120",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"999",0,0,0,0,0,0,0,0,0,0})

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
        aContas := RetParDIOPS(cAlias, cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Só vai processar caso tenha amarracao de contas no configurador
        If lAchouCta        
            // Calcula periodo de datas do trimestre 
            aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
            dDataIni    := aPeriodo[1]
            dDataFim    := aPeriodo[2]

            // QUERY PRINCIPAL
            cSql := ""
            cSql += " Select * From ("
            cSql += " Select CONTA, VENCTO, SUM(VALOR) SALDO From ("
            cSql += " Select CT2_DATA, CONTA, VALOR, RECCT2, FK2_DATa, FK2_DTDISP, COALESCE(SE2K.E2_VENCTO, SE2L.E2_VENCTO, CT2_DATA) VENCTO, COALESCE(SE2K.R_E_C_N_O_, SE2L.R_E_C_N_O_, 0) RECSE2  from ("
            cSql += " Select DISTINCT "
            cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_CREDIT CONTA, CT2_VALOR VALOR, CT2.R_E_C_N_O_ RECCT2 "
            cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, "
            
            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += "CONVERT(INT,CV3_RECORI) RECORI " 
            Else
                cSql += "COALESCE( "
                cSql += "       CASE "
                cSql += "           WHEN REGEXP_LIKE(CV3_RECORI,'^\d+$') "
                cSql += "           THEN TO_NUMBER(CV3_RECORI) "
                cSql += "           ELSE 0 " 
                cSql += "       END, 0 "
                cSql += "   ) RECORI "
            EndIf         

            cSql += " from " + retSqlName("CT2") + " CT2 "
            cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
            cSql += " On "
            cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += " CONVERT(INT, CV3_RECDES) = CT2.R_E_C_N_O_  "
            Else
                cSql += " CASE "
                cSql += "     WHEN REGEXP_LIKE(CV3_RECDES,'^\d+$') "
                cSql += "     THEN TO_NUMBER(CV3_RECDES) "
                cSql += "     ELSE -1 "
                cSql += " END = CT2.R_E_C_N_O_ "
            EndIf 

            cSql += " AND CV3.D_E_L_E_T_ = ' ' "
            csql += " Where "
            Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
            cSql += " CT2_DATA BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
            cSql += " AND ( "

            For nI := 1 to Len(aContas)
                cSql += " CT2_CREDIT LIKE '"+Alltrim(aContas[nI,2])+"%' OR"
            Next

            cSql := Substr(cSql,1,len(cSql)-3)

            cSql += " ) AND "
            cSql += " CT2.D_E_L_E_T_ = ' ' "
            cSql += " Union "
            cSql += " Select DISTINCT "
            cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO CONTA, CT2_VALOR * -1 VALOR, CT2.R_E_C_N_O_ RECCT2, "
            cSql += " COALESCE(CV3_TABORI, '   ') TABORI, "
            
            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += "CONVERT(INT,CV3_RECORI) RECORI " 
            Else
                cSql += "COALESCE( "
                cSql += "       CASE "
                cSql += "           WHEN REGEXP_LIKE(CV3_RECORI,'^\d+$') "
                cSql += "           THEN TO_NUMBER(CV3_RECORI) "
                cSql += "           ELSE 0 " 
                cSql += "       END, 0 "
                cSql += "   ) RECORI "                
            EndIf        

            cSql += " from " + retSqlName("CT2") + " CT2 "
            cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
            cSql += " On "
            cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += " CONVERT(INT, CV3_RECDES) = CT2.R_E_C_N_O_  "
            Else
                cSql += " CASE "
                cSql += "     WHEN REGEXP_LIKE(CV3_RECDES,'^\d+$') "
                cSql += "     THEN TO_NUMBER(CV3_RECDES) "
                cSql += "     ELSE -1 "
                cSql += " END = CT2.R_E_C_N_O_ "
            EndIf 
        
            cSql += " AND CV3.D_E_L_E_T_ = ' ' "
            csql += " Where "
            Csql += " CT2_FILIAL = '" + xfilial("CT2") + "' AND "
            cSql += " CT2_DATA BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
            cSql += " AND ( "

            For nI := 1 to Len(aContas)
                cSql += " CT2_DEBITO LIKE '"+Alltrim(aContas[nI,2])+"%' OR"
            Next

            cSql := Substr(cSql,1,len(cSql)-3)

            cSql += " ) AND "
            cSql += " CT2.D_E_L_E_T_ = ' ' "
            cSql += " ) Z"
            cSql += " LEFT join " + RetSqlName("FK2") + " FK2"
            cSql += " On"
            cSql += " Z.TABORI = 'FK2' AND "

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += " FK2.R_E_C_N_O_ = ISNULL(CONVERT(INT, Z.RECORI),0) "
            Else
                cSql += " FK2.R_E_C_N_O_ = NVL(TO_NUMBER(Z.RECORI),0)  "
            EndIf 

            cSql += " AND FK2.D_E_L_E_T_ = ' ' "
            cSql += " Left Join  " + RetSqlName("FK7") + "  FK7"
            cSql += " On"
            cSql += " FK7_FILIAL = '" + xFilial("FK7") + "' AND "
            cSql += " FK7_IDDOC = FK2.FK2_IDDOC AND"
            cSql += " FK7.D_E_L_E_T_ =  ' '"
            cSql += " Left Join  " + RetSqlName("SE2") + "  SE2K"
            cSql += " On"
            cSql += " FK7_CHAVE = SE2K.E2_FILIAL || '|' || SE2K.E2_PREFIXO || '|' || SE2K.E2_NUM || '|' || SE2K.E2_PARCELA || '|' || SE2K.E2_TIPO || '|' || SE2K.E2_FORNECE || '|' || SE2K.E2_LOJA AND"
            cSql += " SE2K.D_E_L_E_T_ = ' '"
            cSql += " Left Join  " + RetSqlName("FI8") + "  FI8"
            cSql += " On"
            cSql += " FK7_CHAVE = FI8.FI8_FILDES || '|' || FI8.FI8_PRFDES || '|' || FI8.FI8_NUMDES || '|' || FI8.FI8_PARDES || '|' || FI8.FI8_TIPDES || '|' || FI8.FI8_FORDES || '|' || FI8.FI8_LOJDES AND"
            cSql += " FI8.D_E_L_E_T_ = ' '"
            cSql += " left Join  " + RetSqlName("SE2") + "  SE2L"
            cSql += " On"
            cSql += " FI8.FI8_PRFORI = SE2L.E2_PREFIXO "
            cSql += "  AND FI8.FI8_NUMORI = SE2L.E2_NUM "
            cSql += "  AND FI8.FI8_PARORI = SE2L.E2_PARCELA "
            cSql += "  AND FI8.FI8_TIPORI = SE2L.E2_TIPO "
            cSql += "  AND FI8.FI8_FORORI = SE2L.E2_FORNECE"
            cSql += "  AND FI8.FI8_LOJORI = SE2L.E2_LOJA"
            cSql += " AND SE2L.D_E_L_E_T_ = ' '"
            cSql += " ) X " 
            cSql += " Group By CONTA, VENCTO "
            cSql += " ) J "
            cSql += " Where J.SALDO > 0 "
            cSql += " Order By CONTA "

            cSql := ChangeQuery(cSql)
            
            MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTIPG_"+cCodItem+".log",cSql)    

            dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(csql)),"TRBIPG",.f.,.t.)
            TRBIPG->(dbGotop())

            While TRBIPG->(!Eof())
                nDiavcto := dDataFim - StoD(TRBIPG->(VENCTO))
                cCodVcto := ""

                // Atribui o codigo do item de acordo com o prazo de vencimento 
                Do Case
                    Case nDiavcto <= 0 
                        cCodVcto := "000"
                    Case nDiavcto > 0 .And. nDiavcto <= 30 
                        cCodVcto := "030"
                    Case nDiavcto > 30 .And. nDiavcto <= 60 
                        cCodVcto := "060"
                    Case nDiavcto > 60 .And. nDiavcto <= 90
                        cCodVcto := "090"
                    Case nDiavcto > 90 .And. nDiavcto <= 120
                        cCodVcto := "120"
                    OtherWise    
                        nDiavcto := "999"
                EndCase

                // Posiciona no item  para soma dos valores 
                nPos := aScan(aRet,{|x| x[DAD_VENCTO]==cCodVcto})

                // Soma valor 
                aRet[nPos,DAD_EVENTO] += IIf(cCodItem=="EVE",TRBIPG->SALDO,0)    //Eventos/Sinistros a Liquidar    
                aRet[nPos,DAD_EVESUS] += IIf(cCodItem=="SUS",TRBIPG->SALDO,0)    //Eventos ou sinistros a liquidar referente ao ressarcimento SUS                                                                                                                                                                                            
                aRet[nPos,DAD_COMERC] += IIf(cCodItem=="CSO",TRBIPG->SALDO,0)    //Comercialização sobre Operações                                                                                                                                                                                                                           
                aRet[nPos,DAD_DEBOPE] += IIf(cCodItem=="DOP",TRBIPG->SALDO,0)    //Débitos com outras operadoras                                                                                                                                                                                                                             
                aRet[nPos,DAD_OUDBOP] += IIf(cCodItem=="ODO",TRBIPG->SALDO,0)    //Outros débitos com operadoras de saúde                                                                                                                                                                                                                    
                aRet[nPos,DAD_TITSEN] += IIf(cCodItem=="TOE",TRBIPG->SALDO,0)    //Títulos e outros encargos a recolher                                                                                                                                                                                                                      
                aRet[nPos,DAD_DEPBEN] += IIf(cCodItem=="DEP",TRBIPG->SALDO,0)    //Depósitos realizados por beneficiários                                                                                                                                                                                                                    
                aRet[nPos,DAD_SERASS] += IIf(cCodItem=="ASS",TRBIPG->SALDO,0)    //Serviços de assistência à saúde                                                                                                                                                                                                                           
                aRet[nPos,DAD_AQUCAR] += IIf(cCodItem=="AQC",TRBIPG->SALDO,0)    //Débitos com aquisição de carteira de beneficiários                                                                                                                                                                                                        
                aRet[nPos,DAD_OUDBPG] += IIf(cCodItem=="ODP",TRBIPG->SALDO,0)    //Outros Debitos a Pagar                                                                                                                                                                                                                                    

                TRBIPG->(dbSkip())
            EndDo 

            TRBIPG->(dbCloseArea())
        EndIf         

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(dbCloseArea())

Return(aRet)


/*/{Protheus.doc} fRetPosCta()
Retorna posicao da conta contabil no array do ISP
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static function fRetPosCta(cConta)

Local nRet := 0

    If Substr(cConta,1,8) $ '21111102/21111202/21112102/21112202'
        nRet := 1
    elseIf Substr(cConta,1,8) $ '21111103/21111203/21112103/21112203'
        nRet := 2
    elseIf Substr(cConta,1,4) == '2134'
        nRet := 3
    elseIf Substr(cConta,1,4) == '2135'
        nRet := 4
    elseIf Substr(cConta,1,4) $ '2131/2138'
        nRet := 5
    elseIf Substr(cConta,1,3) == '216'
        nRet := 6
    elseIf Substr(cConta,1,8) $ '2132/2185'
        nRet := 7
    elseIf Substr(cConta,1,3) == '214'
        nRet := 8
    elseIf Substr(cConta,1,4) == '2186'
        nRet := 9
    elseIf Substr(cConta,1,4) == '2188'
        nRet := 10
    Else
        nRet := 1    
    endIf

    If nRet > 0
        nRet++ 
    endIf

return nRet
