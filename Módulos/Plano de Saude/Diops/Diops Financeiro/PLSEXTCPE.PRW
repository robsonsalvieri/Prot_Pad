#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_PERCOB 1
#define DAD_PLANO  2
#define DAD_EMITID 3 
#define DAD_RECEBI 4 
#define DAD_VENCID 5 
#define DAD_AVENCE 6 

/*/{Protheus.doc} PLSEXTCPE
Extrator DIOPS Financeiro
Contraprestacoes Pecuniarias                                        
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTCPE(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("CENMCONTPE")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Contraprestacoes Pecuniarias     
    dbSelectArea("B37")
    B37->(dbSetOrder(1) )   //B37_FILIAL+B37_CODOPE+B37_CODOBR+B37_ANOCMP+B37_CDCOMP+B37_PERCOB+B37_PLANO

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
            oModel:SetValue("B37MASTER","B37_FILIAL", xFilial("B37") )
            oModel:SetValue("B37MASTER","B37_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("B37MASTER","B37_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("B37MASTER","B37_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("B37MASTER","B37_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("B37MASTER","B37_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )     
            oModel:SetValue("B37MASTER","B37_PERCOB", aDados[nI,DAD_PERCOB] ) 
            oModel:SetValue("B37MASTER","B37_PLANO" , aDados[nI,DAD_PLANO] ) 
            oModel:SetValue("B37MASTER","B37_EMITID", aDados[nI,DAD_EMITID] ) 
            oModel:SetValue("B37MASTER","B37_RECEBI", aDados[nI,DAD_RECEBI] ) 
            oModel:SetValue("B37MASTER","B37_VENCID", aDados[nI,DAD_VENCID] ) 
            oModel:SetValue("B37MASTER","B37_AVENCE", aDados[nI,DAD_AVENCE] ) 
            oModel:SetValue("B37MASTER","B37_STATUS", "1" )

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
Local cAlias    := "B37"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local nDiasAtr
Local cCodItem
Local cPerCob
Local nX
Local nPos
Local cFilQry
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
        aContas := RetParDIOPS(cAlias, cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]    

        If lAchouCta 
            // Monta query 
            cQuery := " SELECT "+ValToSQL(cCodItem)+" AS CODITEM, " 
            cQuery += "       VENCIMENTO, "
            cQuery += "       COBERTURA, "
            cQuery += "       SITUACAO, "
            cQuery += "       Sum(VALOR) AS VALOR "
            cQuery += " FROM   (SELECT "
            cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                    " DATEDIFF(DAY, E1_VENCTO, CONVERT(DATE, "+ValToSQL(dDataFim)+", 103)) AS VENCIMENTO,",;
                    " TRUNC(TO_DATE("+ValToSQL(dDataFim)+", 'YYYY-MM-DD') - E1_VENCTO) AS VENCIMENTO,")        
            cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                    " DATEDIFF(DAY, BA1_DATINC, CONVERT(DATE, "+ValToSQL(dDataFim)+", 103)) AS COBERTURA,",;
                    " TRUNC(TO_DATE("+ValToSQL(dDataFim)+", 'YYYY-MM-DD') - BA1_DATINC) AS COBERTURA,")           
            cQuery += "                     CASE WHEN E1_SALDO > 0 THEN 'PENDENTE' ELSE 'BAIXADO' END AS SITUACAO,  "        
            cQuery += "                         BM1_VALOR AS VALOR  "
            cQuery += "        FROM   "+RetSQLName("BM1")+" BM1 " 
            cQuery += "               INNER JOIN "+RetSQLName("BA1")+" BA1 "
            cQuery += "                       ON BA1_FILIAL = "+ValToSQL(xFilial("BA1"))
            cQuery += "                          AND BA1_CODINT = BM1_CODINT "    
            cQuery += "                          AND BA1_CODEMP = BM1_CODEMP "
            cQuery += "                          AND BA1_MATRIC = BM1_MATRIC "
            cQuery += "                          AND BA1_CONEMP = BM1_CONEMP "
            cQuery += "                          AND BA1_VERCON = BM1_VERCON "
            cQuery += "                          AND BA1_SUBCON = BM1_SUBCON "
            cQuery += "                          AND BA1_VERSUB = BM1_VERSUB "
            cQuery += "                          AND BA1_TIPREG = BM1_TIPREG "
            cQuery += "                          AND BA1.D_E_L_E_T_ = '' "        
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
            cQuery += "          AND E1_EMISSAO BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
            cQuery += " ) AS TRBQRY "
            cQuery += " GROUP  BY SITUACAO, COBERTURA, VENCIMENTO "
            cQuery += " ORDER  BY SITUACAO, COBERTURA, VENCIMENTO " 
            cQuery := ChangeQuery(cQuery)

            cQuery := ChangeQuery(cQuery)
            MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTCPE_"+cCodItem+".log",cQuery)    

            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCPE",.F.,.T.)	
            TRBCPE->(dbGotop())

            While TRBCPE->(!Eof())
                nDiasAtr := TRBCPE->VENCIMENTO
                nDiasCob := TRBCPE->COBERTURA
                cSituacao:= TRBCPE->SITUACAO
                cPerCob := ""

                Do Case
                    Case nDiasCob <= 0 
                        cPerCob := "084"
                    Case nDiasCob == 1
                        cPerCob := "085"
                    Case nDiasCob == 2
                        cPerCob := "086"
                    Case nDiasCob == 3
                        cPerCob := "087"
                    Case nDiasCob == 4
                        cPerCob := "088"
                    Case nDiasCob == 5
                        cPerCob := "089"
                    Case nDiasCob == 6
                        cPerCob := "090"
                    Case nDiasCob == 7
                        cPerCob := "091"
                    Case nDiasCob == 8
                        cPerCob := "092"
                    Case nDiasCob == 9
                        cPerCob := "093"
                    Case nDiasCob == 10
                        cPerCob := "094"
                    Case nDiasCob == 11
                        cPerCob := "095"
                    Case nDiasCob == 12
                        cPerCob := "096"
                    Case nDiasCob == 13
                        cPerCob := "097"
                    Case nDiasCob == 14
                        cPerCob := "098"
                    Case nDiasCob == 15
                        cPerCob := "099"
                    Case nDiasCob == 16
                        cPerCob := "100"
                    Case nDiasCob == 17
                        cPerCob := "101"
                    Case nDiasCob == 18
                        cPerCob := "102"
                    Case nDiasCob == 19
                        cPerCob := "103"
                    Case nDiasCob == 20
                        cPerCob := "104"
                    Case nDiasCob == 21
                        cPerCob := "105"
                    Case nDiasCob == 22
                        cPerCob := "106"
                    Case nDiasCob == 23
                        cPerCob := "107"
                    Case nDiasCob == 24
                        cPerCob := "108"
                    Case nDiasCob == 25
                        cPerCob := "109"
                    Case nDiasCob == 26
                        cPerCob := "110"
                    Case nDiasCob == 27
                        cPerCob := "111"
                    Case nDiasCob == 28
                        cPerCob := "112"
                    Case nDiasCob == 29
                        cPerCob := "113"
                    Case nDiasCob == 30
                        cPerCob := "114"
                    Case nDiasCob == 31
                        cPerCob := "115"
                    OtherWise
                        cPerCob := "116"
                EndCase

                // Posiciona no item  para soma dos valores 
                nPos := aScan(aRet,{|x| x[DAD_PERCOB]==cPerCob .And. x[DAD_PLANO]==TRBCPE->CODITEM})

                If nPos == 0 
                    aAdd(aRet,{cPerCob,TRBCPE->CODITEM,0,0,0,0})
                    nPos := Len(aRet)
                EndIf 

                // Soma valor 
                aRet[nPos,DAD_EMITID] += TRBCPE->VALOR    //Valor emitidos   
                aRet[nPos,DAD_RECEBI] += IIf(cSituacao=="BAIXADO",TRBCPE->VALOR,0)    //Valor Recebidos
                aRet[nPos,DAD_VENCID] += IIf(cSituacao=="PENDENTE" .And. nDiasAtr>0 ,TRBCPE->VALOR,0)    //Valor Vencidos
                aRet[nPos,DAD_AVENCE] += IIf(cSituacao=="PENDENTE" .And. nDiasAtr<=0,TRBCPE->VALOR,0)    //Valor A Vencer
                                                                                                                                                                                                                                        
                TRBCPE->(dbSkip())
            EndDo 

            TRBCPE->(dbCloseArea())
        EndIf 
        
        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(dbCloseArea())

Return(aRet)
