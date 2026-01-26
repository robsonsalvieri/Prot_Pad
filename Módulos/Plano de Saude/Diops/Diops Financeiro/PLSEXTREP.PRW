#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_VLMES1   1
#define DAD_VLMES2   2
#define DAD_VLMES3   3
#define DAD_CODITEM  4

/*/{Protheus.doc} PLSEXTREP
Extrator DIOPS Financeiro
Segregação do Montante de Contraprestações a Repassar                                                
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTREP(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCSMCR")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Modelo Padrao de Capital 
    dbSelectArea("BVS")
    BVS->(dbSetOrder(1) )   //BVS_FILIAL+BVS_CODOPE+BVS_CODOBR+BVS_ANOCMP+BVS_CDCOMP+BVS_CODIGO

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
            oModel:SetValue("BVSMASTER","BVS_FILIAL", xFilial("BVS") )
            oModel:SetValue("BVSMASTER","BVS_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("BVSMASTER","BVS_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("BVSMASTER","BVS_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("BVSMASTER","BVS_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("BVSMASTER","BVS_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )        
            oModel:SetValue("BVSMASTER","BVS_CODIGO", aDados[nI,DAD_CODITEM] )
            oModel:SetValue("BVSMASTER","BVS_VLMES3", aDados[nI,DAD_VLMES3] )
            oModel:SetValue("BVSMASTER","BVS_VLMES2", aDados[nI,DAD_VLMES2] )
            oModel:SetValue("BVSMASTER","BVS_VLMES1", aDados[nI,DAD_VLMES1] )
            oModel:SetValue("BVSMASTER","BVS_STATUS", "1" )

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
Local cAlias    := "BVS"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local nMeses
Local nDiasAtr
Local dVencto
Local cCodItem
Local cMesCmp
Local nI
Local nX
Local nPos
Local cFilQry
Local aRet      := {}

    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     
    //³ Código	Débitos de Operações de Administração de Benefícios  ³
    //³ 1	Vencidos até 30 dias                                     ³
    //³ 2	Vencidos há mais de 30 dias e até 60 dias                ³
    //³ 3	Vencidos há mais de 60 dias e até 90 dias                ³
    //³ 4	Vencidos há mais de 90 dias                              ³
    //³ 7	A Vencer                                                 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
    aAdd(aRet,{0,0,0,"1"})
    aAdd(aRet,{0,0,0,"2"})
    aAdd(aRet,{0,0,0,"3"})
    aAdd(aRet,{0,0,0,"4"})
    aAdd(aRet,{0,0,0,"7"})

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

    // Calcula periodo de datas do trimestre 
    aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
    dDataIni    := aPeriodo[1]
    dDataFim    := aPeriodo[2]    

    // Calcula o numero de meses para geracao do quadro
    nMeses := DateComp(dDataIni, dDataFim, "MM")

    // Processa o quadro para a quantidade de meses calculada no compromisso Diops
    For nI := 0 to nMeses   /*inicia em 0 (zero) para considerar o mês atual*/

        // Recalcula datas inicio e fim para utilizar periodo mensal 
        dDataIni := MsSomaMes(dDataIni, IIf(nI>0,1,0))
        dDataFim := LastDay(dDataIni)

        // Mes da competência para gravar o campo Diops Mensal
        cMesCmp  := StrZero(Month(dDataIni),2)

        // Monta Query 
        cQuery := " SELECT  "+ValToSQL(cMesCmp)+ " AS MESCMP,  "
        cQuery += "         VENCTO, "
        cQuery += "         Sum(VALOR) AS VALOR "
        cQuery += " FROM (SELECT  E1_VENCTO AS VENCTO, "
        cQuery += "               BM1_VALOR   AS VALOR "
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

        If lAchouCta
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

                cFilQry +=  " (CV3_CREDIT BETWEEN "+ValToSQL(aContas[nX,2])+" AND "+ValToSQL(aContas[nX,3])+" ) OR" 
            Next 

            If !Empty(cFilQry)
                cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
            Endif   
        Else
            // Caso não tenha informado nenhuma conta no configurador de regras utiliza todo grupo 2136
            cQuery += " AND CV3_CREDIT LIKE '2136%' "     
        EndIf 

        cQuery += "        WHERE BM1.D_E_L_E_T_ = '' "
        cQuery += "          AND (E1_BAIXA = '' OR E1_BAIXA > "+ValToSQL(dDataFim)+") "
        cQuery += "          AND E1_EMISSAO <= "+ValToSQL(dDataFim)
        cQuery += " ) AS TRBQRY "
        cQuery += " GROUP  BY VENCTO "
        cQuery += " ORDER  BY VENCTO " 
        cQuery := ChangeQuery(cQuery)

        // Atualiza log
        MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTREP_"+cMesCmp+".log",cQuery)

        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBREP",.F.,.T.)	
        TRBREP->(dbGotop())   

        While TRBREP->(!Eof())
            //Calcula dias do vencimento 
            dVencto  := StoD(TRBREP->VENCTO)
            nDiasAtr := IIf(dVencto<dDataFim,dDataFim-dVencto,0)

            // Atribui o codigo do item de acordo com o prazo de vencimento 
            Do Case
                Case nDiasAtr == 0
                    cCodItem := "1"
                Case nDiasAtr > 0 .And. nDiasAtr <= 30 
                    cCodItem := "2"
                Case nDiasAtr > 30 .And. nDiasAtr <= 60 
                    cCodItem := "3"
                Case nDiasAtr > 60 .And. nDiasAtr <= 90
                    cCodItem := "4"
                Case nDiasAtr > 90
                    cCodItem := "7"
            EndCase

            // Posiciona no item  para soma dos valores 
            nPos := aScan(aRet,{|x| x[DAD_CODITEM]==cCodItem})

            // Soma valor nos meses 
            aRet[nPos,DAD_VLMES1] += IIf(TRBREP->MESCMP=="01",TRBREP->VALOR,0)
            aRet[nPos,DAD_VLMES2] += IIf(TRBREP->MESCMP=="02",TRBREP->VALOR,0)
            aRet[nPos,DAD_VLMES3] += IIf(TRBREP->MESCMP=="03",TRBREP->VALOR,0)

            TRBREP->(dbSkip())
        EndDo

        TRBREP->(dbCloseArea()) 
    Next

Return(aRet)
