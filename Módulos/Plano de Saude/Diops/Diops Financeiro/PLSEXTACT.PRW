#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_TIPO  1
#define DAD_PLACE 2
#define DAD_PLACC 3
#define DAD_PLAEV 4
#define DAD_PCECE 5
#define DAD_PCECC 6
#define DAD_PCEEV 7

/*/{Protheus.doc} PLSEXTACT
Extrator DIOPS Financeiro
Agrupamento de Contratos                                               
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTACT(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCAGCN")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Agrupamento de Contratos
    dbSelectArea("B8K")
    B8K->(dbSetOrder(1) )   //BVS_FILIAL+BVS_CODOPE+BVS_CODOBR+BVS_ANOCMP+BVS_CDCOMP+BVS_CODIGO

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
            oModel:SetValue("B8KMASTER","B8K_FILIAL", xFilial("BVS") )
            oModel:SetValue("B8KMASTER","B8K_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("B8KMASTER","B8K_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("B8KMASTER","B8K_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("B8KMASTER","B8K_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("B8KMASTER","B8K_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )        
            oModel:SetValue("B8KMASTER","B8K_TIPO"  , aDados[nI,DAD_TIPO] )
            oModel:SetValue("B8KMASTER","B8K_PLACE" , aDados[nI,DAD_PLACE] )
            oModel:SetValue("B8KMASTER","B8K_PLACC" , aDados[nI,DAD_PLACC] )
            oModel:SetValue("B8KMASTER","B8K_PLAEV" , aDados[nI,DAD_PLAEV] )
            oModel:SetValue("B8KMASTER","B8K_PCECE" , aDados[nI,DAD_PCECE] )
            oModel:SetValue("B8KMASTER","B8K_PCECC" , aDados[nI,DAD_PCECC] )
            oModel:SetValue("B8KMASTER","B8K_PCEEV" , aDados[nI,DAD_PCEEV] )
            oModel:SetValue("B8KMASTER","B8K_STATUS", "1" )

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
Local cAlias    := "B8K"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local cCodItem
Local cRisco
Local cCContabil
Local cCCusto
Local nX
Local nPos
Local cFilQry
Local aRet      := {}

    // Cria array de retorno 
    aAdd(aRet,{"1",0,0,0,0,0,0})    // Contratos Agregados ao  Pool de Risco
    aAdd(aRet,{"2",0,0,0,0,0,0})    // Demais contratos

    // Query utilizada para retornar os itens do Quadro
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
        cCodItem := Alltrim((cAliasTrb)->B3Y_ITEM)

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Retorno da função: RetParDIOPS                     ³
        //³ [1] Codigo do Item 	                               ³
        //³ [2] Conta Contabil      		                   ³
        //³ [3] Centro de Custo     	                       ³
        //³ [4] Descricao do Identificador                 	   ³        
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
        aContas := RetParDIOPS(cAlias)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Só vai processar caso tenha amarracao de contas no configurador
        If lAchouCta            
            // Calcula periodo de datas do trimestre 
            aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
            dDataIni    := aPeriodo[1]
            dDataFim    := aPeriodo[2]    

            If cCodItem == "CTR" // Contraprestação Emitida
                cQuery := " SELECT "+ValToSQL(cCodItem)+" AS CODITEM, "
                cQuery += "     CONTRATO, "
                cQuery += "     RISCO, "
                cQuery += "     Sum(VALOR) AS VALOR "
                cQuery += " FROM   (SELECT BT5_TIPCON AS CONTRATO, "
                cQuery += "             BT5_AGR309 AS RISCO, "
                cQuery += "             BM1_VALOR  AS VALOR "
                cQuery += "         FROM   "+RetSQLName("BM1")+" BM1 "
                cQuery += "             INNER JOIN "+RetSQLName("BT5")+" BT5 "
                cQuery += "                     ON BT5_FILIAL = "+ValToSQL(xFIlial("BT5"))
                cQuery += "                         AND BT5_CODINT = BM1_CODINT "
                cQuery += "                         AND BT5_CODIGO = BM1_CODEMP "
                cQuery += "                         AND BT5_NUMCON = BM1_CONEMP "
                cQuery += "                         AND BT5_VERSAO = BM1_VERCON "
                cQuery += "                         AND BT5.D_E_L_E_T_ = ' ' "
                cQuery += "             INNER JOIN "+RetSQLName("SE1")+" SE1 "
                cQuery += "                     ON E1_FILIAL = "+ValToSQL(xFilial("SE1"))
                cQuery += "                         AND E1_PLNUCOB = BM1_PLNUCO "
                cQuery += "                         AND E1_PREFIXO = BM1_PREFIX "
                cQuery += "                         AND E1_NUM = BM1_NUMTIT "
                cQuery += "                         AND E1_PARCELA = BM1_PARCEL "
                cQuery += "                         AND E1_TIPO = BM1_TIPTIT "
                cQuery += "                         AND SE1.D_E_L_E_T_ = ' ' "

                If lAchouCta
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
                            cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCC LIKE "+ValToSQL(cCCusto+"%")+") OR"
                        Else
                            cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+") OR"
                        EndIf 
                    Next 

                    If !Empty(cFilQry)
                        cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
                    Endif   
                EndIf             

                cQuery += "         WHERE BM1_FILIAL = "+ValToSQL(xFilial("BM1"))
                cQuery += "             AND BT5_TIPCON IN ( '2', '3' ) "
                cQuery += "             AND E1_EMISSAO BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
                cQuery += "             AND BM1.D_E_L_E_T_ = ' ' ) AS TRBQRY "
                cQuery += " GROUP  BY CONTRATO, RISCO "
                cQuery += " ORDER  BY CODITEM, CONTRATO, RISCO "     
            Else
                cQuery := " SELECT "+ValToSQL(cCodItem)+" AS CODITEM, "
                cQuery += "     CONTRATO, "
                cQuery += "     RISCO, "
                cQuery += "     Sum(VALOR) AS VALOR "
                cQuery += " FROM   (SELECT BT5_TIPCON AS CONTRATO, "
                cQuery += "             BT5_AGR309 AS RISCO, "
                If cCodItem == "REC"            
                    cQuery += "             BD7_VLRTPF AS VALOR "   //Corresponsabilidade Cedida
                Else
                    cQuery += "             BD7_VLRPAG AS VALOR "   //Eventos/Sinistros Conhecidos
                EndIf 
                cQuery += "         FROM   "+RetSQLName("BD7")+" BD7 "
                cQuery += "             INNER JOIN "+RetSQLName("BT5")+" BT5 "
                cQuery += "                     ON BT5_FILIAL = "+ValToSQL(xFilial("BT5"))
                cQuery += "                         AND BT5_CODINT = BD7_CODOPE "
                cQuery += "                         AND BT5_CODIGO = BD7_CODEMP "
                cQuery += "                         AND BT5_NUMCON = BD7_CONEMP "
                cQuery += "                         AND BT5_VERSAO = BD7_VERCON "
                cQuery += "                         AND BT5.D_E_L_E_T_ = ' ' "

                If lAchouCta
                    // CV3
                    cQuery += "               INNER JOIN "+RetSQLName("CV3")+" CV3 "
                    cQuery += "                       ON CV3_FILIAL = "+ValToSQL(xFilial("CV3"))
                    cQuery += "                          AND CV3_TABORI = 'BD7' "
                    cQuery += "                          AND CV3_RECORI = BD7.R_E_C_N_O_ "
                    cQuery += "                          AND CV3.D_E_L_E_T_ = '' "  

                    // Montagem do filtro relacionado as contas contabeis cadastradas no configurador Diops Financeiro 
                    cFilQry := ""
                    For nX := 1 to Len(aContas)
                        cCContabil := Alltrim(aContas[nX,2])  // Conta Contabil 
                        cCCusto    := Alltrim(aContas[nX,3])  // Centro de Custo 

                        If cCodItem == "REC"
                            If !Empty(cCCusto)
                                cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCC LIKE "+ValToSQL(cCCusto+"%")+") OR"
                            Else
                                cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+") OR"
                            EndIf 
                        Else
                            If !Empty(cCCusto)
                                cFilQry += " (CV3_DEBITO LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCD LIKE "+ValToSQL(cCCusto+"%")+") OR"
                            Else
                                cFilQry += " (CV3_DEBITO LIKE "+ValToSQL(cCContabil+"%")+") OR"
                            EndIf 
                        EndIf 
                    Next 

                    If !Empty(cFilQry)
                        cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
                    Endif   
                EndIf              

                cQuery += "         WHERE  BD7_FILIAL = "+ValToSQL(xFilial("BD7"))
                cQuery += "             AND BD7_SITUAC = '1' "
                cQuery += "             AND BD7_FASE = '4' "
                cQuery += "             AND BD7_DTCTBF BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
                If cCodItem == "REC"
                    cQuery += "             AND BD7_VLRTPF > 0 "
                Else
                    cQuery += "             AND BD7_VLRPAG > 0 "
                EndIf 
                cQuery += "             AND BD7.D_E_L_E_T_ = ' ') AS TRBQRY "
                cQuery += " GROUP  BY CONTRATO, RISCO "
                cQuery += " ORDER  BY CODITEM, CONTRATO, RISCO " 
            EndIf 

            cQuery := ChangeQuery(cQuery)
            MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTACT_"+cCodItem+".log",cQuery)

            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBACT",.F.,.T.)	
            TRBACT->(dbGotop())   

            While TRBACT->(!Eof())
                // Tipo de Contrato
                cCodigo     := Alltrim(TRBACT->CODITEM)
                cRisco      := Iif(Alltrim(TRBACT->RISCO)<>"1","2","1") //  1=Contratos Agregados ao Pool de Risco  2=Demais Contratos
                cContrato   := Alltrim(TRBACT->CONTRATO)

                // Posiciona no item 
                nPos := aScan(aRet,{|x| x[DAD_TIPO]==cRisco})

                // Soma valores 
                aRet[nPos, DAD_PLACE] += Iif(cCodigo=="CTR" .And. cContrato=="2",TRBACT->VALOR,0)
                aRet[nPos, DAD_PLACC] += Iif(cCodigo=="REC" .And. cContrato=="2",TRBACT->VALOR,0)
                aRet[nPos, DAD_PLAEV] += Iif(cCodigo=="EVE" .And. cContrato=="2",TRBACT->VALOR,0)
                aRet[nPos, DAD_PCECE] += Iif(cCodigo=="CTR" .And. cContrato=="3",TRBACT->VALOR,0)
                aRet[nPos, DAD_PCECC] += Iif(cCodigo=="REC" .And. cContrato=="3",TRBACT->VALOR,0)
                aRet[nPos, DAD_PCEEV] += Iif(cCodigo=="EVE" .And. cContrato=="3",TRBACT->VALOR,0)

                TRBACT->(dbSkip())
            EndDo

            TRBACT->(dbCloseArea())
        EndIf 
        
        (cAliasTrb)->(dbSkip())
    EndDo     

    (cAliasTrb)->(dbCloseArea())

Return(aRet)
