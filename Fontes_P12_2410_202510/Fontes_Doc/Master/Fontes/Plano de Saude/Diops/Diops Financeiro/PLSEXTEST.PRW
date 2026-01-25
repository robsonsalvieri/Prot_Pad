#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_CODOPE   1
#define DAD_QTDVID   2
#define DAD_VLRREP   3
#define DAD_TIPOCT   4

/*/{Protheus.doc} PLSEXTEST
Extrator DIOPS Financeiro
Contratos Estipulados                                               
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTEST(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCCOE")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Modelo Padrao de Capital 
    dbSelectArea("BUP")
    BUP->(dbSetOrder(1) )   //BUP_FILIAL+BUP_CODOPE+BUP_CODOBR+BUP_REFERE+BUP_ANOCMP+BUP_CDCOMP+BUP_OPECOE

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
            oModel:SetValue("BUPMASTER","BUP_FILIAL", xFilial("BUP") )
            oModel:SetValue("BUPMASTER","BUP_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("BUPMASTER","BUP_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("BUPMASTER","BUP_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("BUPMASTER","BUP_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("BUPMASTER","BUP_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )        
            oModel:SetValue("BUPMASTER","BUP_OPECOE", aDados[nI,DAD_CODOPE] )
            oModel:SetValue("BUPMASTER","BUP_QTDVIA", aDados[nI,DAD_QTDVID] )
            oModel:SetValue("BUPMASTER","BUP_CONREP", aDados[nI,DAD_VLRREP] )
            oModel:SetValue("BUPMASTER","BUP_CONESP", aDados[nI,DAD_TIPOCT] )
            oModel:SetValue("BUPMASTER","BUP_STATUS", "1" )

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
Retorna dados
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetDados()
Local cAliasTrb := GetNextAlias()
Local cAlias    := "BUP"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local cCodItem
Local nX
Local nPos
Local cFilQry
Local cCContabil 
Local cCCusto
Local aRet      := {}

    // Query utilizada para retornar os itens do Quadro
    BeginSQL Alias cAliasTrb
        SELECT B3Y_ITEM, B3Y_DESCRI
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
        aContas := RetParDIOPS(cAlias, cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]   

        If lAchouCta 
            // Monta Query 
            cQuery := " SELECT  "+ValToSQL(cCodItem)+ " AS CODITEM,  "
            cQuery += "         CODOPE, "
            cQuery += "         MATUSU, "        
            cQuery += "         Sum(VALOR) AS VALOR "
            cQuery += " FROM (SELECT  BA0_SUSEP   AS CODOPE, "
            cQuery += "               BM1_MATUSU  AS MATUSU, "       
            cQuery += "               BM1_VALOR   AS VALOR "
            cQuery += "        FROM   "+RetSQLName("BM1")+" BM1 "
            cQuery += "               INNER JOIN "+RetSQLName("BA0")+" BA0 "
            cQuery += "                       ON BA0_FILIAL = "+ValToSQL(xFilial("BA0"))
            cQuery += "                          AND BA0_CODIDE+BA0_CODINT = BM1_CODINT "
            cQuery += "                          AND BA0.D_E_L_E_T_ = '' "   
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
                    cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCC LIKE "+ValToSQL(cCCusto+"%")+") OR"
                Else
                    cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+") OR"
                EndIf 
            Next 

            If !Empty(cFilQry)
                cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
            Endif   

            cQuery += "        WHERE BM1.D_E_L_E_T_ = '' "
            cQuery += "          AND E1_EMISSAO BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
            cQuery += " ) AS TRBQRY "
            cQuery += " GROUP  BY CODOPE, MATUSU "
            cQuery += " ORDER  BY CODOPE, MATUSU " 
            cQuery := ChangeQuery(cQuery)

            // Atualiza log
            MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTEST_"+cCodItem+".log",cQuery)

            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBEST",.F.,.T.)	
            TRBEST->(dbGotop())   

            While TRBEST->(!Eof())
                nPos  := aScan(aRet,{|x| x[DAD_CODOPE]==TRBEST->CODOPE})

                If nPos == 0
                    cTipo := Iif(TRBEST->CODITEM=="CTE","1","2") // 1=Estipulado 2=Não Estipulado
                    aAdd(aRet,{TRBEST->CODOPE,0,0,cTipo})
                    nPOs := Len(aRet)
                EndIf 

                aRet[nPOs,DAD_QTDVID] += 1
                aRet[nPos,DAD_VLRREP] += TRBEST->VALOR

                TRBEST->(dbSkip())
            EndDo

            TRBEST->(dbCloseArea()) 
        EndIf 

        (cAliasTrb)->(dbSkip())
    EndDo    

    (cAliasTrb)->(DbCloseArea())

Return(aRet)
