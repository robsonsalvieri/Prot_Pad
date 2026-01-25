#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_CODITEM  1
#define DAD_TIPO     2
#define DAD_CODINT   3
#define DAD_CODEMP   4
#define DAD_VALOR    5
#define DAD_QTD      6

/*/{Protheus.doc} PLSEXTMPC
Extrator DIOPS Financeiro
Modelo Padrao de Capital 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTMPC(oProcess)
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aRet     := {}
Local cLog
Local oModel    := FWLoadModel("PLSMVCMPC")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Modelo Padrao de Capital 
    dbSelectArea("B82")
    B82->(dbSetOrder(1) )   //B82_FILIAL+B82_CODOPE+B82_CODOBR+B82_ANOCMP+B82_CDCOMP

    // Processa a inclusao dos registros 
    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate(.T.)
    oModel:SetValue("B82MASTER","B82_FILIAL", xFilial("B82") )
    oModel:SetValue("B82MASTER","B82_CODOPE", B3D->B3D_CODOPE )        
    oModel:SetValue("B82MASTER","B82_CODOBR", B3D->B3D_CDOBRI )        
    oModel:SetValue("B82MASTER","B82_ANOCMP", B3D->B3D_ANO )        
    oModel:SetValue("B82MASTER","B82_CDCOMP", B3D->B3D_CODIGO )        
    oModel:SetValue("B82MASTER","B82_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )        
    oModel:SetValue("B82MASTER","B82_STATUS", "1" )

    // Valida o modelo de dados
    If oModel:VldData()
        oModel:CommitData()
        // Calcula Valores apurados ao fim do trimestre
        Processa({||fGravaDados(oProcess)},"Aguarde","Gerando dados...",.t.)
        nTotal := 1   
    Else
        cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
        cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
        cLog += cValToChar(oModel:GetErrorMessage()[6])     

        aAdd(aRet,"Falha na inclusão do Quadro: "+cLog) 
    EndIf

    oModel:DeActivate()

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return({nTotal,aRet})

/*/{Protheus.doc} fGravaDados()
Grava valores apurados ao fim do trimestre
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fGravaDados(oProcess)
Local cAliasTrb := GetNextAlias()
Local cAlias    := "B82"
Local nRegua    := 0
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local nDias     := 365 // periodo em dias para retroceder/avancar a data de competencia
Local nX
Local cCodItem
LOcal cCContabil
Local cCCusto
Local cFilQry
Local aMovCtb   
Local cMoeda    := "01"
Local cTpSald   := "1"
Local nI
Local lPls		:= GetNewPar("MV_PLSATIV",.F.)

    // Query utilizada para retornar os itens do Quadro
    BeginSQL Alias cAliasTrb
        SELECT B3Y_ITEM, B3Y_DESCRI
          FROM %Table:B3Y% B3Y
          INNER JOIN %Table:B3I% B3I  ON B3I_FILIAL=B3Y_FILIAL AND B3I_CODIGO=B3Y_CODIGO AND B3I_ALIAS=%Exp:cAlias% AND B3I.%NotDel%
        WHERE B3Y_FILIAL=%xFilial:B3Y%
        AND B3Y.%NotDel%
        ORDER BY B3Y_ITEM
    EndSQL

    (cAliasTrb)->(dbEval({||++nRegua}))
    oProcess:SetRegua2(nRegua)

    (cAliasTrb)->(dbGotop())
    While (cAliasTrb)->(!Eof())
        oProcess:IncRegua2()
        cCodItem := Alltrim((cAliasTrb)->B3Y_ITEM)

        // Calcula periodo de datas dos últimos doze meses a partir do final do periodo Diops
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]    

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Retorno da função: RetParDIOPS                     ³
        //³ [1] Codigo do Item 	                               ³
        //³ [2] Conta Contabil      		                   ³
        //³ [3] Centro de Custo     	                       ³
        //³ [4] Descricao do Identificador                 	   ³        
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ        
        aContas  := RetParDIOPS(cAlias,cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0    

        // Só vai processar caso tenha amarracao de contas no configurador
        If lAchouCta                    
            If lPls
                If cCodItem $ "SMTP/SMVI"
                    // Soma das contraprestações dos últimos doze meses dos beneficiários da remissão, não remidos, 
                    // em contratos com remissão temporária ou vitalicia
                    cQuery := " SELECT  "+ValToSQL(cCodItem)+ " AS CODITEM,  "
                    cQuery += "         CODINT, "
                    cQuery += "         CODEMP, "
                    cQuery += "         MATRIC, "
                    cQuery += "         MATUSU, "
                    cQuery += "         REMIDO, "
                    cQuery += "         Sum(VALOR) AS VALOR "
                    cQuery += " FROM (SELECT  BM1_CODINT  AS CODINT, "
                    cQuery += "               BM1_CODEMP  AS CODEMP, "
                    cQuery += "               BM1_MATRIC  AS MATRIC, "
                    cQuery += "               BM1_MATUSU  AS MATUSU, "
                    cQuery += "               B.BA1_REMIDO  AS REMIDO, "
                    cQuery += "               BM1_VALOR   AS VALOR "
                    cQuery += "        FROM   "+RetSQLName("BA1")+" A " /*titular*/
                    cQuery += "               INNER JOIN "+RetSQLName("BM1")+" BM1 "
                    cQuery += "                       ON BM1_FILIAL = "+ValToSQL(xFilial("BM1"))
                    cQuery += "                          AND BM1_CODINT = A.BA1_CODINT "    
                    cQuery += "                          AND BM1_CODEMP = A.BA1_CODEMP "
                    cQuery += "                          AND BM1_MATRIC = A.BA1_MATRIC "
                    cQuery += "                          AND BM1_CONEMP = A.BA1_CONEMP "
                    cQuery += "                          AND BM1_VERCON = A.BA1_VERCON "
                    cQuery += "                          AND BM1_SUBCON = A.BA1_SUBCON "
                    cQuery += "                          AND BM1_VERSUB = A.BA1_VERSUB "
                    cQuery += "                          AND BM1_TIPREG <> A.BA1_TIPREG "
                    cQuery += "                          AND BM1.D_E_L_E_T_ = '' "
                    cQuery += "               INNER JOIN "+RetSQLName("BA1")+" B " /*dependentes*/
                    cQuery += "                       ON B.BA1_FILIAL = "+ValToSQL(xFilial("BA1"))
                    cQuery += "                          AND B.BA1_CODINT = BM1_CODINT "    
                    cQuery += "                          AND B.BA1_CODEMP = BM1_CODEMP "
                    cQuery += "                          AND B.BA1_MATRIC = BM1_MATRIC "
                    cQuery += "                          AND B.BA1_CONEMP = BM1_CONEMP "
                    cQuery += "                          AND B.BA1_VERCON = BM1_VERCON "
                    cQuery += "                          AND B.BA1_SUBCON = BM1_SUBCON "
                    cQuery += "                          AND B.BA1_VERSUB = BM1_VERSUB "
                    cQuery += "                          AND B.BA1_TIPREG = BM1_TIPREG "
                    cQuery += "                          AND B.D_E_L_E_T_ = '' "
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

                    cQuery += "        WHERE  A.D_E_L_E_T_ = '' "
                    cQuery += "               AND A.BA1_TIPUSU = 'T' "    /*titular do plano*/
                    cQuery += "               AND A.BA1_DATBLO >= "+ValToSQL((dDataIni-nDias))    /*cancelado*/
                    cQuery += "               AND B.BA1_REMIDO <> '1' "    /*somente dependente NÃO remido*/
                    cQuery += "               AND E1_EMISSAO BETWEEN "+ValToSQL((dDataIni-nDias))+" AND "+ValToSQL(dDataFim)
                Else
                    // Soma dos valores das expectativas de despesa de assistência à saúde de dos beneficiários remidos, 
                    // em contratos com remissão temporária ou vitalicia, nos doze meses subsequentes
                    cQuery := " SELECT  "+ValToSQL(cCodItem)+ " AS CODITEM,  "
                    cQuery += "         CODINT, "
                    cQuery += "         MATRIC, "
                    cQuery += "         MATUSU, "
                    cQuery += "         REMIDO, "
                    cQuery += "         Sum(VALOR) AS VALOR "
                    cQuery += " FROM (SELECT  BM1_CODINT  AS CODINT, "
                    cQuery += "               BM1_CODEMP  AS CODEMP, "
                    cQuery += "               BM1_MATRIC  AS MATRIC, "
                    cQuery += "               BM1_MATUSU  AS MATUSU, "
                    cQuery += "               B.BA1_REMIDO  AS REMIDO, "
                    cQuery += "               BM1_VALOR   AS VALOR "
                    cQuery += "        FROM   "+RetSQLName("BA1")+" A " /*titular*/
                    cQuery += "               INNER JOIN "+RetSQLName("BM1")+" BM1 "
                    cQuery += "                       ON BM1_FILIAL = "+ValToSQL(xFilial("BM1"))
                    cQuery += "                          AND BM1_CODINT = A.BA1_CODINT "    
                    cQuery += "                          AND BM1_CODEMP = A.BA1_CODEMP "
                    cQuery += "                          AND BM1_MATRIC = A.BA1_MATRIC "
                    cQuery += "                          AND BM1_CONEMP = A.BA1_CONEMP "
                    cQuery += "                          AND BM1_VERCON = A.BA1_VERCON "
                    cQuery += "                          AND BM1_SUBCON = A.BA1_SUBCON "
                    cQuery += "                          AND BM1_VERSUB = A.BA1_VERSUB "
                    cQuery += "                          AND BM1_TIPREG <> A.BA1_TIPREG "
                    cQuery += "                          AND BM1.D_E_L_E_T_ = '' "
                    cQuery += "               INNER JOIN "+RetSQLName("BA1")+" B " /*dependentes*/
                    cQuery += "                       ON B.BA1_FILIAL = "+ValToSQL(xFilial("BA1"))
                    cQuery += "                          AND B.BA1_CODINT = BM1_CODINT "    
                    cQuery += "                          AND B.BA1_CODEMP = BM1_CODEMP "
                    cQuery += "                          AND B.BA1_MATRIC = BM1_MATRIC "
                    cQuery += "                          AND B.BA1_CONEMP = BM1_CONEMP "
                    cQuery += "                          AND B.BA1_VERCON = BM1_VERCON "
                    cQuery += "                          AND B.BA1_SUBCON = BM1_SUBCON "
                    cQuery += "                          AND B.BA1_VERSUB = BM1_VERSUB "
                    cQuery += "                          AND B.BA1_TIPREG = BM1_TIPREG "
                    cQuery += "                          AND B.D_E_L_E_T_ = '' "
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

                    cQuery += "        WHERE  A.D_E_L_E_T_ = '' "
                    cQuery += "               AND A.BA1_TIPUSU = 'T' "    /*titular do plano*/
                    cQuery += "               AND A.BA1_DATBLO >= "+ValToSQL(dDataIni)    /*cancelado*/
                    cQuery += "               AND B.BA1_REMIDO = '1' "    /*somente dependente REMIDOS */
                    cQuery += "               AND E1_EMISSAO BETWEEN "+ValToSQL((dDataFim+1))+" AND "+ValToSQL((dDataFim+nDias))
                EndIf 

                cQuery += " ) AS TRBQRY "
                cQuery += " GROUP  BY CODINT, CODEMP, MATRIC, MATUSU, REMIDO "
                cQuery += " ORDER  BY CODITEM, CODINT, CODEMP, MATRIC, MATUSU " 
                cQuery := ChangeQuery(cQuery)

                // Atualiza log
                MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTMPC_"+cCodItem+".log",cQuery)

                dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBMPC",.F.,.T.)	
                TRBMPC->(dbGotop())   

                While TRBMPC->(!Eof())
                    RecLock("B82",.f.)
                    B82->B82_SMRMTP += IIf(TRBMPC->CODITEM=="SMTP" .And. TRBMPC->REMIDO<>"1",TRBMPC->VALOR,0)
                    B82->B82_SMRMVI += Iif(TRBMPC->CODITEM=="SMVI" .And. TRBMPC->REMIDO<>"1",TRBMPC->VALOR,0)
                    B82->B82_NMRMTP += Iif(TRBMPC->CODITEM=="SMTP" .And. TRBMPC->REMIDO<>"1",1,0)
                    B82->B82_NMRMVI += Iif(TRBMPC->CODITEM=="SMVI" .And. TRBMPC->REMIDO<>"1",1,0)
                    B82->B82_SMDETP += Iif(TRBMPC->CODITEM=="VLTP" .And. TRBMPC->REMIDO=="1",TRBMPC->VALOR,0)
                    B82->B82_SMDEVI += Iif(TRBMPC->CODITEM=="VLVI" .And. TRBMPC->REMIDO=="1",TRBMPC->VALOR,0)
                    B82->(msUnLock())
                    TRBMPC->(dbSkip())
                EndDo

                TRBMPC->(dbCloseArea())  
            Else
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Quando o cliente NÃO utiliza o módulo PLS (MV_PLSATIV = .F.)        ³
                //³ a apuracao dos valores sera feita atraves da contabilidade          ³
                //³ utilizando as funcoes que calculam a movimentacao contabil          ³
                //³ pelas Contas e Centro de Custo que foram amarradas no     	        ³
                //³ configurador Diops Financeiro                                       ³            
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

                nValorCtb   := 0
                aMovCtb     := {}

                For nX := 1 to Len(aContas)
                    cCContabil  := Alltrim(aContas[nX,2])  // Conta Contabil 
                    cCCusto     := Alltrim(aContas[nX,3])  // Centro de Custo 

                    // Monta query 
                    cQuery := "SELECT CT1_CONTA, CT1_CLASSE, "
                    cQuery += " '"+cCodItem+"' AS CODITEM "
                    cQuery += " FROM "+RetSQLName("CT1")+" CT1 "
                    cQuery += " WHERE CT1_FILIAL = "+ValToSQL(xFilial("CT1"))
                    cQuery += "   AND (CT1_CONTA LIKE "+ValToSQL(cCContabil+"%")+") "
                    cQuery += "   AND CT1_CLASSE='2' "  
                    cQuery += "   AND CT1.D_E_L_E_T_ = '' "
                    cQuery += " ORDER BY CT1_CONTA "

                    cQuery := ChangeQuery(cQuery)
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBMPC",.F.,.T.)	
                    TRBMPC->(dbGotop())

                    While TRBMPC->(!Eof())
                        aAdd(aMovCtb,{TRBMPC->CT1_CONTA,cCCusto})
                        TRBMPC->(dbSkip())
                    EndDo

                    If Len(aMovCtb)>0
                        For nI := 1 to Len(aMovCtb)
                            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³ Retorno:                                           ³
                            //³ [1] Movimento Devedor 	                           ³
                            //³ [2] Movimento Credor		                       ³
                            //³ [3] Movimento do Mes		                       ³
                            //³ [4] Saldo Final                                	   ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                        
                            If Empty(aMovCtb[nI,2]) 
                                nValorCtb += MovConta(aMovCtb[nI,1] /*Conta Contabil*/,(dDataFim-nDias)+1,dDataFim,cMoeda,cTpSald,3 /*Tipo de Retorno*/)
                            Else
                                nValorCtb += MovCusto(aMovCtb[nI,1] /*Conta Contabil*/,aMovCtb[nI,2] /*Centro Custo*/,(dDataFim-nDias)+1,dDataFim,cMoeda,cTpSald,3 /*Tipo de Retorno*/)
                            EndIf
                        Next

                        // Grava valores calculados 
                        RecLock("B82",.f.)
                        B82->B82_SMRMTP += IIf(cCodItem=="SMTP",nValorCtb,0)
                        B82->B82_SMRMVI += Iif(cCodItem=="SMVI",nValorCtb,0)
                        B82->B82_SMDETP += Iif(cCodItem=="VLTP",nValorCtb,0)
                        B82->B82_SMDEVI += Iif(cCodItem=="VLVI",nValorCtb,0)
                        B82->(msUnLock())
                    EndIf 

                    TRBMPC->(dbCloseArea())                     
                Next 
            EndIf     
        EndIf      

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())    

Return
