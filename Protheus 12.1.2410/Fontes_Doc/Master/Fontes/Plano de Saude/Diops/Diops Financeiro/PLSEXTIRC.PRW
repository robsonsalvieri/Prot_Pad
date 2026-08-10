#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_VENCTO 1
#define DAD_INDPRE 2
#define DAD_INDPOS 3 
#define DAD_COLPRE 4 
#define DAD_COLPOS 5 
#define DAD_CREADM 6 
#define DAD_PARBEN 7 
#define DAD_OUCROP 8
#define DAD_CROPPO 9
#define DAD_OUCRPL 10 
#define DAD_OUTCRE 11

/*/{Protheus.doc} PLSEXTIRC
Extrator DIOPS Financeiro
Idade dos Saldos - A Receber                                          
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTIRC(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCIDSP")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Idade dos Saldos - A Receber  
    dbSelectArea("B8G")
    B8G->(dbSetOrder(1) )   //B8G_FILIAL+B8G_CODOPE+B8G_CODOBR+B8G_ANOCMP+B8G_CDCOMP+B8G_VENCTO

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
            oModel:SetValue("B8GMASTER","B8G_FILIAL", xFilial("B8G") )
            oModel:SetValue("B8GMASTER","B8G_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("B8GMASTER","B8G_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("B8GMASTER","B8G_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("B8GMASTER","B8G_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("B8GMASTER","B8G_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )     
            oModel:SetValue("B8GMASTER","B8G_VENCTO", aDados[nI,DAD_VENCTO] ) 
            oModel:SetValue("B8GMASTER","B8G_INDPRE", aDados[nI,DAD_INDPRE] ) 
            oModel:SetValue("B8GMASTER","B8G_INDPOS", aDados[nI,DAD_INDPOS] ) 
            oModel:SetValue("B8GMASTER","B8G_COLPRE", aDados[nI,DAD_COLPRE] ) 
            oModel:SetValue("B8GMASTER","B8G_COLPOS", aDados[nI,DAD_COLPOS] ) 
            oModel:SetValue("B8GMASTER","B8G_CREADM", aDados[nI,DAD_CREADM] ) 
            oModel:SetValue("B8GMASTER","B8G_PARBEN", aDados[nI,DAD_PARBEN] ) 
            oModel:SetValue("B8GMASTER","B8G_OUCROP", aDados[nI,DAD_OUCROP] ) 
            oModel:SetValue("B8GMASTER","B8G_CROPPO", aDados[nI,DAD_CROPPO] ) 
            oModel:SetValue("B8GMASTER","B8G_OUCRPL", aDados[nI,DAD_OUCRPL] )
            oModel:SetValue("B8GMASTER","B8G_OUTCRE", aDados[nI,DAD_OUTCRE] )  
            oModel:SetValue("B8GMASTER","B8G_STATUS", "1" )

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
Local cAlias    := "B8G"
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
    //³ Código	Distribuição dos Saldos de Contas a Receber          ³
    //³ 000	A Vencer                                                 ³
    //³ 030	Vencidos 1-30 dias                                       ³
    //³ 060	Vencidos 31-60 dias                                      ³
    //³ 090	Vencidos 61-90 dias                                      ³
    //³ 099	Vencidos +90                                             ³
    //³ 400	PPSC                                                     ³    
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
    aAdd(aRet,{"000",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"030",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"060",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"090",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"099",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"400",0,0,0,0,0,0,0,0,0,0})

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
                        " DATEDIFF(DAY, E1_VENCTO, CONVERT(DATE, "+ValToSQL(dDataFim)+", 103)) AS VENCIMENTO,",;
                        " TRUNC(TO_DATE("+ValToSQL(dDataFim)+", 'YYYY-MM-DD') - E1_VENCTO) AS VENCIMENTO,")             
                cQuery += "               BM1_VALOR AS VALOR  "
                cQuery += "        FROM   "+RetSQLName("BM1")+" BM1 " 
                cQuery += "               INNER JOIN "+RetSQLName("SE1")+" SE1 "
                cQuery += "                       ON E1_FILIAL = "+ValToSQL(xFilial("SE1"))
                cQuery += "                          AND E1_PLNUCOB = BM1_PLNUCO "
                cQuery += "                          AND E1_PREFIXO = BM1_PREFIX "
                cQuery += "                          AND E1_NUM = BM1_NUMTIT "
                cQuery += "                          AND E1_PARCELA = BM1_PARCEL "
                cQuery += "                          AND E1_TIPO = BM1_TIPTIT "
                cQuery += "                          AND SE1.D_E_L_E_T_ = '' "   

                // CV3
                cQuery += "               INNER JOIN "+RetSQLName("CV3")+" CV3 "
                cQuery += "                       ON CV3_FILIAL = "+ValToSQL(xFilial("CV3"))
                cQuery += "                          AND CV3_TABORI = 'BM1' "
                cQuery += "                          AND CV3_RECORI = BM1.R_E_C_N_O_ "
                cQuery += "                          AND CV3.D_E_L_E_T_ = '' "  

                // Montagem do filtro relacionado as contas contabeis cadastradas no configurador Diops Financeiro 
                cFilQry := ""
                For nX := 1 to Len(aContas)
                    cCContabil := Alltrim(aContas[nX,2])  // Conta Contabil 
                    cCCusto    := Alltrim(aContas[nX,3])  // Centro de Custo 

                    If !Empty(cCCusto)
                        cFilQry += " (CV3_DEBITO LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCD LIKE "+ValToSQL(cCCusto+"%")+") OR"
                    Else
                        cFilQry += " (CV3_DEBITO LIKE "+ValToSQL(cCContabil+"%")+") OR"
                    EndIf 
                Next 

                If !Empty(cFilQry)
                    cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
                Endif   

                cQuery += "        WHERE BM1.D_E_L_E_T_ = '' "
                cQuery += "          AND (E1_BAIXA = '' OR E1_BAIXA > "+ValToSQL(dDataFim)+") "
                cQuery += "          AND E1_EMISSAO <= "+ValToSQL(dDataFim)
                cQuery += " ) AS TRBQRY "
                cQuery += " GROUP  BY VENCIMENTO "
                cQuery += " ORDER  BY VENCIMENTO " 
                cQuery := ChangeQuery(cQuery)

                cQuery := ChangeQuery(cQuery)
                MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTIRC_"+cCodItem+".log",cQuery)    

                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBIRC",.F.,.T.)	
                TRBIRC->(dbGotop())

                While TRBIRC->(!Eof())
                    nDiasAtr := TRBIRC->VENCIMENTO
                    cCodVcto := ""

                    // Atribui o codigo do item de acordo com o prazo de vencimento 
                    If TRBIRC->CODITEM=="PPSC"
                        cCodVcto := "400"   
                    Else    
                        Do Case
                            Case nDiasAtr <= 0 
                                cCodVcto := "000"
                            Case nDiasAtr > 0 .And. nDiasAtr <= 30 
                                cCodVcto := "030"
                            Case nDiasAtr > 30 .And. nDiasAtr <= 60 
                                cCodVcto := "060"
                            Case nDiasAtr > 60 .And. nDiasAtr <= 90
                                cCodVcto := "090"
                            Case nDiasAtr > 90
                                cCodVcto := "099"
                        EndCase
                    EndIf 

                    // Posiciona no item  para soma dos valores 
                    nPos := aScan(aRet,{|x| x[DAD_VENCTO]==cCodVcto})

                    // Soma valor 
                    aRet[nPos,DAD_INDPRE] += IIf(TRBIRC->CODITEM=="IN1",TRBIRC->VALOR,0)    //Preço Pré-estabelecido   
                    aRet[nPos,DAD_INDPOS] += IIf(TRBIRC->CODITEM=="IN2",TRBIRC->VALOR,0)    //Individual pos estabelecido
                    aRet[nPos,DAD_COLPRE] += IIf(TRBIRC->CODITEM=="CO1",TRBIRC->VALOR,0)    //Coletivo pre estabelecido                                                                                                                                                                                                                           
                    aRet[nPos,DAD_COLPOS] += IIf(TRBIRC->CODITEM=="CO2",TRBIRC->VALOR,0)    //Coletivo pos estabelecido                                                                                                                                                                                                                            
                    aRet[nPos,DAD_CREADM] += IIf(TRBIRC->CODITEM=="COB",TRBIRC->VALOR,0)    //Credito operacao beneficiarios                                                                                                                                                                                                              
                    aRet[nPos,DAD_PARBEN] += IIf(TRBIRC->CODITEM=="PAR",TRBIRC->VALOR,0)    //Participacao de beneficiarios em eventos ou sinistros                                                                                                                                                                                                                
                    aRet[nPos,DAD_OUCROP] += IIf(TRBIRC->CODITEM=="CR1",TRBIRC->VALOR,0)    //Creditos de operadoras                                                                                                                                                                                                                  
                    aRet[nPos,DAD_CROPPO] += IIf(TRBIRC->CODITEM=="CR2",TRBIRC->VALOR,0)    //Credito de Operadoras em planos Pos Pagamento                                                                                                                                                                                                                           
                    aRet[nPos,DAD_OUCRPL] += IIf(TRBIRC->CODITEM=="OC1",TRBIRC->VALOR,0)    //Outros creditos com planos                                                                                                                                                                                                        
                    aRet[nPos,DAD_OUTCRE] += IIf(TRBIRC->CODITEM=="OC2",TRBIRC->VALOR,0)    //Outros creditos nao relacionados a planos
                                                                                                                                                                                                                                            
                    TRBIRC->(dbSkip())
                EndDo 
            
                TRBIRC->(dbCloseArea())
            EndIf 

            (cAliasTrb)->(dbSkip())
        EndDo

        (cAliasTrb)->(dbCloseArea())
    Else
        aRet := fRetSldIRC()
    EndIf     

Return(aRet)

/*/{Protheus.doc} fRetSldIRC()
Retorna valores da contabilidade
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetSldIRC()

Local aRet  := {}
Local nDiavcto	:= 0
Local cAlias    := "B8G"
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
    //³ Código	Distribuição dos Saldos de Contas a Receber          ³
    //³ 000	A Vencer                                                 ³
    //³ 030	Vencidos 1-30 dias                                       ³
    //³ 060	Vencidos 31-60 dias                                      ³
    //³ 090	Vencidos 61-90 dias                                      ³
    //³ 099	Vencidos +90                                             ³
    //³ 400	PPSC                                                     ³    
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
    aAdd(aRet,{"000",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"030",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"060",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"090",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"099",0,0,0,0,0,0,0,0,0,0})
    aAdd(aRet,{"400",0,0,0,0,0,0,0,0,0,0})

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
            cSql += " Select CT2_DATA, CONTA, VALOR, RECCT2, FK1_DATA, FK1_DTDISP, COALESCE(SE1K.E1_VENCTO, SE1L.E1_VENCTO, CT2_DATA) VENCTO, COALESCE(SE1K.R_E_C_N_O_, SE1L.R_E_C_N_O_, 0) RECSE1  from ("
            cSql += " Select DISTINCT "
            cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_CREDIT CONTA, CT2_VALOR VALOR, CT2.R_E_C_N_O_ RECCT2 "
            cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, "
            
            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += "CONVERT(INT,CV3_RECORI) RECORI " 
            Else
                cSql += "COALESCE(TO_NUMBER(CV3_RECORI), 0) RECORI " 
            EndIf         
            
            cSql += " from " + retSqlName("CT2") + " CT2 "
            cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
            cSql += " On "
            cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += " CONVERT(INT, CV3_RECDES) = CT2.R_E_C_N_O_ AND "
            Else
                cSql += " TO_NUMBER(CV3_RECDES) = CT2.R_E_C_N_O_ AND "
            EndIf 

            cSql += " CV3.D_E_L_E_T_ = ' ' "
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
            cSql += " CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DEBITO CONTA, CT2_VALOR * -1 VALOR, CT2.R_E_C_N_O_ RECCT2 "
            cSql += " , COALESCE(CV3_TABORI, '   ') TABORI, "  

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += "CONVERT(INT,CV3_RECORI) RECORI " 
            Else
                cSql += "COALESCE(TO_NUMBER(CV3_RECORI), 0) RECORI " 
            EndIf     

            cSql += " from " + retSqlName("CT2") + " CT2 "
            cSql += " LEFT Join " + retSqlName("CV3") + " CV3 "
            cSql += " On "
            cSql += " CV3_FILIAL = '" + xFilial("CV3") + "' AND "

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += " CONVERT(INT, CV3_RECDES) = CT2.R_E_C_N_O_ AND "
            Else
                cSql += " TO_NUMBER(CV3_RECDES) = CT2.R_E_C_N_O_ AND "
            EndIf 

            cSql += " CV3.D_E_L_E_T_ = ' ' "
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
            cSql += " LEFT join " + RetSqlName("FK1") + " FK1"
            cSql += " On"
            cSql += " Z.TABORI = 'FK1' AND "

            If cTipoBanco $ "MSSQL/MSSQL7"
                cSql += " FK1.R_E_C_N_O_ = ISNULL(CONVERT(INT, Z.RECORI),0) AND "
            Else
                cSql += " FK1.R_E_C_N_O_ = NVL(TO_NUMBER(Z.RECORI),0) AND "
            EndIf 

            cSql += " FK1.D_E_L_E_T_ = ' '"
            cSql += " Left Join  " + RetSqlName("FK7") + "  FK7"
            cSql += " On"
            cSql += " FK7_FILIAL = '" + xFilial("FK7") + "' AND "
            cSql += " FK7_IDDOC = FK1.FK1_IDDOC AND"
            cSql += " FK7.D_E_L_E_T_ =  ' '"
            cSql += " Left Join  " + RetSqlName("SE1") + "  SE1K"
            cSql += " On"
            cSql += " FK7_CHAVE = SE1K.E1_FILIAL || '|' || SE1K.E1_PREFIXO || '|' || SE1K.E1_NUM || '|' || SE1K.E1_PARCELA || '|' || SE1K.E1_TIPO || '|' || SE1K.E1_CLIENTE || '|' || SE1K.E1_LOJA AND"
            cSql += " SE1K.D_E_L_E_T_ = ' '"
            cSql += " Left Join  " + RetSqlName("FI7") + "  FI7"
            cSql += " On"
            cSql += " FK7_CHAVE = FI7.FI7_FILDES || '|' || FI7.FI7_PRFDES || '|' || FI7.FI7_NUMDES || '|' || FI7.FI7_PARDES || '|' || FI7.FI7_TIPDES || '|' || FI7.FI7_CLIDES || '|' || FI7.FI7_LOJDES AND"
            cSql += " FI7.D_E_L_E_T_ = ' '"
            cSql += " left Join  " + RetSqlName("SE1") + "  SE1L"
            cSql += " On"
            cSql += " FI7.FI7_PRFORI = SE1L.E1_PREFIXO "
            cSql += "  AND FI7.FI7_NUMORI = SE1L.E1_NUM "
            cSql += "  AND FI7.FI7_PARORI = SE1L.E1_PARCELA "
            cSql += "  AND FI7.FI7_TIPORI = SE1L.E1_TIPO "
            cSql += "  AND FI7.FI7_CLIORI = SE1L.E1_CLIENTE"
            cSql += "  AND FI7.FI7_LOJORI = SE1L.E1_LOJA"
            cSql += " AND SE1L.D_E_L_E_T_ = ' '"
            cSql += " ) X " 
            cSql += " Group By CONTA, VENCTO "
            cSql += " ) J "
            cSql += " Where J.SALDO > 0 "
            cSql += " Order By CONTA "

            cSql := ChangeQuery(cSql)
            
            MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTIRC_"+cCodItem+".log",cSql)    

            dbUseArea(.t.,"TOPCONN",tcGenQry(,,changequery(csql)),"TRBIRC",.f.,.t.)
            TRBIRC->(dbGotop())

            While TRBIRC->(!Eof())
                nDiavcto := dDataFim - StoD(TRBIRC->(VENCTO))
                cCodVcto := ""

                // Atribui o codigo do item de acordo com o prazo de vencimento 
                If cCodItem=="PPSC"
                    cCodVcto := "400"   
                Else    
                    Do Case
                        Case nDiavcto <= 0 
                            cCodVcto := "000"
                        Case nDiavcto > 0 .And. nDiavcto <= 30 
                            cCodVcto := "030"
                        Case nDiavcto > 30 .And. nDiavcto <= 60 
                            cCodVcto := "060"
                        Case nDiavcto > 60 .And. nDiavcto <= 90
                            cCodVcto := "090"
                        Case nDiavcto > 90
                            cCodVcto := "099"
                    EndCase
                EndIf 

                // Posiciona no item  para soma dos valores 
                nPos := aScan(aRet,{|x| x[DAD_VENCTO]==cCodVcto})

                // Soma valor 
                aRet[nPos,DAD_INDPRE] += IIf(cCodItem=="IN1",TRBIRC->SALDO,0)    //Preço Pré-estabelecido   
                aRet[nPos,DAD_INDPOS] += IIf(cCodItem=="IN2",TRBIRC->SALDO,0)    //Individual pos estabelecido
                aRet[nPos,DAD_COLPRE] += IIf(cCodItem=="CO1",TRBIRC->SALDO,0)    //Coletivo pre estabelecido                                                                                                                                                                                                                           
                aRet[nPos,DAD_COLPOS] += IIf(cCodItem=="CO2",TRBIRC->SALDO,0)    //Coletivo pos estabelecido                                                                                                                                                                                                                            
                aRet[nPos,DAD_CREADM] += IIf(cCodItem=="COB",TRBIRC->SALDO,0)    //Credito operacao beneficiarios                                                                                                                                                                                                              
                aRet[nPos,DAD_PARBEN] += IIf(cCodItem=="PAR",TRBIRC->SALDO,0)    //Participacao de beneficiarios em eventos ou sinistros                                                                                                                                                                                                                
                aRet[nPos,DAD_OUCROP] += IIf(cCodItem=="CR1",TRBIRC->SALDO,0)    //Creditos de operadoras                                                                                                                                                                                                                  
                aRet[nPos,DAD_CROPPO] += IIf(cCodItem=="CR2",TRBIRC->SALDO,0)    //Credito de Operadoras em planos Pos Pagamento                                                                                                                                                                                                                           
                aRet[nPos,DAD_OUCRPL] += IIf(cCodItem=="OC1",TRBIRC->SALDO,0)    //Outros creditos com planos                                                                                                                                                                                                        
                aRet[nPos,DAD_OUTCRE] += IIf(cCodItem=="OC2",TRBIRC->SALDO,0)    //Outros creditos nao relacionados a planos

                TRBIRC->(dbSkip())
            EndDo 

            TRBIRC->(dbCloseArea())
        EndIf         

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(dbCloseArea())

Return(aRet)

/*/{Protheus.doc} fRetPosCta()
Retorna posicao da conta contabil no array do ISR
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static function fRetPosCta(cConta)

Local nRet := 0

    If Substr(cConta,1,9) $ '123111011/123121011'       
        nRet := 1   //A
    elseIf Substr(cConta,1,9) $ '123112011/123122011'
        nRet := 2   //B
    elseIf Substr(cConta,1,9) $ '123111012/123111013/123121012/123121013'
        nRet := 3   //C
    elseIf Substr(cConta,1,9) $ '123112012/123112013/123112015/123122012/123122013/123122015'
        nRet := 4   //D
    elseIf Substr(cConta,1,9) $ '123219011/123219012/123219021/123219022/123229011/123229012/123229021/123229022'
        nRet := 5   //E
    elseIf Substr(cConta,1,9) $ '123311011/123312011/123321011/123322011'
        nRet := 6   //F
    elseIf Substr(cConta,1,9) $ '123411091/123412091/123421091/123422091'
        nRet := 7   //G
    elseIf Substr(cConta,1,9) $ '123911019/123911029/123911089/123912089/123921019/123921029/123921089/123922089'
        nRet := 8   //H 
    elseIf Substr(cConta,1,9) $ '124119011/124119021/124119022/124119082/124119088/124129011/124129021/124129022/124129082/124129088'
        nRet := 9   //I
    Else
        nRet := 10    
    endIf

    If nRet > 0
        nRet++ 
    endIf

return nRet
