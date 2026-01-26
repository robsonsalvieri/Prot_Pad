#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_TIPOES 1
#define DAD_UMMSUS 2
#define DAD_UMCARP 3
#define DAD_UMCOAS 4
#define DAD_DOMSUS 5 
#define DAD_DOCARP 6
#define DAD_DOCOAS 7
#define DAD_TRMSUS 8
#define DAD_TRCARP 9
#define DAD_TRCOAS 10

/*/{Protheus.doc} PLSEXTPEL
Extrator DIOPS Financeiro
Saldo da Provisão de Eventos/Sinistros a Liquidar
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTPEL(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCPESL")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Saldo da Provisão de Eventos/Sinistros a Liquidar
    dbSelectArea("B8J")
    B8J->(dbSetOrder(1) )   //B8J_FILIAL+B8J_CODOPE+B8J_CODOBR+B8J_ANOCMP+B8J_CDCOMP

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
            oModel:SetValue("B8JMASTER","B8J_FILIAL", xFilial("B8J") )
            oModel:SetValue("B8JMASTER","B8J_CODOPE", B3D->B3D_CODOPE )
            oModel:SetValue("B8JMASTER","B8J_CODOBR", B3D->B3D_CDOBRI )
            oModel:SetValue("B8JMASTER","B8J_ANOCMP", B3D->B3D_ANO )
            oModel:SetValue("B8JMASTER","B8J_CDCOMP", B3D->B3D_CODIGO )                
            oModel:SetValue("B8JMASTER","B8J_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )
            oModel:SetValue("B8JMASTER","B8J_UMMSUS", aDados[nI,DAD_UMMSUS] )
            oModel:SetValue("B8JMASTER","B8J_UMCARP", aDados[nI,DAD_UMCARP] )
            oModel:SetValue("B8JMASTER","B8J_UMCOAS", aDados[nI,DAD_UMCOAS] )
            oModel:SetValue("B8JMASTER","B8J_DOMSUS", aDados[nI,DAD_DOMSUS] )
            oModel:SetValue("B8JMASTER","B8J_DOCARP", aDados[nI,DAD_DOCARP] )
            oModel:SetValue("B8JMASTER","B8J_DOCOAS", aDados[nI,DAD_DOCOAS] )
            oModel:SetValue("B8JMASTER","B8J_TRMSUS", aDados[nI,DAD_TRMSUS] )
            oModel:SetValue("B8JMASTER","B8J_TRCARP", aDados[nI,DAD_TRCARP] )
            oModel:SetValue("B8JMASTER","B8J_TRCOAS", aDados[nI,DAD_TRCOAS] )
            oModel:SetValue("B8JMASTER","B8J_TIPOES", aDados[nI,DAD_TIPOES] )
            oModel:SetValue("B8JMASTER","B8J_STATUS", "1" )            

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
Local cAlias    := "B8J"
Local cQuery    := ""
Local nX
Local nPos
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local cFiltro   := ""
Local cCodItem
Local cContrato
Local dDataIni
Local dDataFim
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

        // Monta Query 
        cQuery := " SELECT "+ValToSQL(cCodItem)+" AS CODITEM, " 
        cQuery += "       OCORRENCIA, "
        cQuery += "       CONTRATO, "
        cQuery += "       Sum(VALOR) AS VALOR "
        cQuery += " FROM   (SELECT "
        cQuery += IIf(cTipoBanco $ "MSSQL/MSSQL7",;
                " DATEDIFF(DAY, BD7_DATPRO, BD7_DTCTBF) AS OCORRENCIA,",;
                " TO_NUMBER(TO_DATE(BD7_DATPRO,'YYYYMMDD')-TO_DATE(BD7_DTCTBF,'YYYYMMDD')) AS OCORRENCIA,")
        cQuery += "           BAU_TPPAG AS CONTRATO, BD7_VLRPAG AS VALOR "
        cQuery += " FROM   "+RetSQLName("BD7")+" BD7 "
        cQuery += "       INNER JOIN "+RetSqlName("BAU")+" BAU "
        cQuery += "               ON BAU_FILIAL = "+ValToSQL(xFilial("BAU"))
        cQuery += "                  AND BAU_CODIGO = BD7_CODRDA "
        cQuery += "                  AND BAU.D_E_L_E_T_ = '' "        
        cQuery += "       INNER JOIN "+RetSQLName("SE2")+" SE2 "
        cQuery += "                ON E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|'
        cQuery += "                 + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|'
        cQuery += "                 + E2_LOJA = BD7_CHKSE2
        cQuery += "                   AND SE2.D_E_L_E_T_ = ''        

        If lAchouCta
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
        EndIf             

        cQuery += " WHERE  BD7_FILIAL = "+ValToSQL(xFilial("BD7"))
        cQuery += "        AND BD7_SITUAC = '1' "
        cQuery += "        AND BD7_FASE = '4' "
        cQuery += "        AND BD7_VLRPAG > 0 "
        cQuery += "        AND ( E2_BAIXA = '' OR E2_BAIXA > "+ValToSQL(dDataFim)+") "
        cQuery += "        AND BD7_DTCTBF BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)+") AS TRBQRY "
        cQuery += " WHERE  OCORRENCIA >= 0 "
        cQuery += " GROUP  BY OCORRENCIA, CONTRATO "
        cQuery += " ORDER  BY OCORRENCIA, CONTRATO "

        cQuery := ChangeQuery(cQuery)
        MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTPEL_"+cCodItem+".log",cQuery)    

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBPEL",.F.,.T.)	
        TRBPEL->(dbGotop())

        // Zerar Valores

        While TRBPEL->(!Eof())
            cContrato := IIf(Alltrim(TRBPEL->CONTRATO)=="1","1","2") /*Captation*/
            nPos := aScan(aRet,{|x| x[DAD_TIPOES]==cContrato})

            If nPos == 0
                aAdd(aRet,{cContrato,0,0,0,0,0,0,0,0,0})
                nPos := Len(aRet)
            EndIf 

            Do Case
                Case TRBPEL->CODITEM == "SUS" //PESL-SUS
                    aRet[nPos,DAD_UMMSUS] += Iif(TRBPEL->OCORRENCIA>=0  .And. TRBPEL->OCORRENCIA<=30,TRBPEL->VALOR,0)
                    aRet[nPos,DAD_DOMSUS] += Iif(TRBPEL->OCORRENCIA>=31 .And. TRBPEL->OCORRENCIA<=60,TRBPEL->VALOR,0)
                    aRet[nPos,DAD_TRMSUS] += Iif(TRBPEL->OCORRENCIA>=61,TRBPEL->VALOR,0)
                Case TRBPEL->CODITEM == "CAP" //PESL-OUTROS Carteira Própria
                    aRet[nPos,DAD_UMCARP] += Iif(TRBPEL->OCORRENCIA>=0  .And. TRBPEL->OCORRENCIA<=30,TRBPEL->VALOR,0)
                    aRet[nPos,DAD_DOCARP] += Iif(TRBPEL->OCORRENCIA>=31 .And. TRBPEL->OCORRENCIA<=60,TRBPEL->VALOR,0)
                    aRet[nPos,DAD_TRCARP] += Iif(TRBPEL->OCORRENCIA>=61,TRBPEL->VALOR,0)                
                Case TRBPEL->CODITEM == "COA" //PESL-OUTROS Corresponsabilidade Assumida
                    aRet[nPos,DAD_UMCOAS] += Iif(TRBPEL->OCORRENCIA>=0  .And. TRBPEL->OCORRENCIA<=30,TRBPEL->VALOR,0)
                    aRet[nPos,DAD_DOCOAS] += Iif(TRBPEL->OCORRENCIA>=31 .And. TRBPEL->OCORRENCIA<=60,TRBPEL->VALOR,0)
                    aRet[nPos,DAD_TRCOAS] += Iif(TRBPEL->OCORRENCIA>=61,TRBPEL->VALOR,0)                
            EndCase 

            TRBPEL->(dbSkip())
        EndDo 

        TRBPEL->(dbCloseArea())

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())

Return(aRet)
