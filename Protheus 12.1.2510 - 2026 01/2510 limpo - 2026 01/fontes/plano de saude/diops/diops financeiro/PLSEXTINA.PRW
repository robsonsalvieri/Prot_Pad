#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_PMPAUT 1
#define DAD_PERCAP 2

/*/{Protheus.doc} PLSEXTINA
Extrator DIOPS Financeiro
Inadimplencia (Administradora de benefficios)                                      
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTINA(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI

    // Inadimplencia (Administradora de benefficios)       
    dbSelectArea("B7W")
    B7W->(dbSetOrder(1) )   //B7W_FILIAL+B7W_CODOPE+B7W_CODOBR+B7W_ANOCMP+B7W_CDCOMP+B7W_REFERE

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
            If !B7W->(dbSeek(xFilial("B7W")+B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+StrZero(Val(Substr(B3D_REFERE,1,1)),2))))
                RecLock("B7W",.t.)
                B7W_FILIAL := xFilial("B37") 
                B7W_CODOPE := B3D->B3D_CODOPE         
                B7W_CODOBR := B3D->B3D_CDOBRI         
                B7W_ANOCMP := B3D->B3D_ANO         
                B7W_CDCOMP := B3D->B3D_CODIGO         
                B7W_REFERE := StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2)
                B7W_PMPAUT := aDados[nI, DAD_PMPAUT]
                B7W_PERCAP := aDados[nI, DAD_PERCAP]
                B7W_STATUS := "1"
                B7W->(MsUnLock())
                nTotal++
            EndIf     
        Next
    Endif

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
Local cAlias    := "B7W"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local nDiasAtr
Local nPerAtr
Local nValFat
Local nValAtr
Local cCodItem
Local nX
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
            cQuery += "       SITUACAO, "
            cQuery += "       Sum(VALOR) AS VALOR "
            cQuery += " FROM   (SELECT "
            cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                    " DATEDIFF(DAY, E1_VENCTO, CONVERT(DATE, "+ValToSQL(dDataFim)+", 103)) AS VENCIMENTO,",;
                    " TRUNC(TO_DATE("+ValToSQL(dDataFim)+", 'YYYY-MM-DD') - E1_VENCTO) AS VENCIMENTO,")          
            cQuery += "                     CASE WHEN E1_SALDO > 0 THEN 'PENDENTE' ELSE 'BAIXADO' END AS SITUACAO,  "        
            cQuery += "                         BM1_VALOR AS VALOR  "
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
            cQuery += "          AND E1_EMISSAO BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
            cQuery += " ) AS TRBQRY "
            cQuery += " GROUP  BY SITUACAO, VENCIMENTO "
            cQuery += " ORDER  BY SITUACAO, VENCIMENTO " 
            cQuery := ChangeQuery(cQuery)

            cQuery := ChangeQuery(cQuery)
            MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTINA_"+cCodItem+".log",cQuery)    

            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBINA",.F.,.T.)	
            TRBINA->(dbGotop())

            // Zerar valores
            nValFat := 0
            nValAtr := 0
            nPerAtr := 0

            While TRBINA->(!Eof())
                // Soma valores
                nDiasAtr := TRBINA->VENCIMENTO
                nValFat  += TRBINA->VALOR
                nValAtr  += IIf(nDiasAtr>60,TRBINA->VALOR,0)

                TRBINA->(dbSkip())
            EndDo 

            // Calcula o percentual de inadimplencia
            nPerAtr  := (nValAtr/nValFat)*100  

            // Adiciona item 
            aAdd(aRet,{cCodItem,nPerAtr})

            TRBINA->(dbCloseArea())
        EndIf 

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(dbCloseArea())

Return(aRet)
