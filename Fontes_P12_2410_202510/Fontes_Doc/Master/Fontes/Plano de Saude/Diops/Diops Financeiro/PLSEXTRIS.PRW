#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_CONTA   1
#define DAD_CTASUP  2
#define DAD_VALOR   3
#define DAD_SINAL   4
#define DAD_INDEX   5

/*/{Protheus.doc} PLSEXTRIS
Extrator DIOPS Financeiro
Quadro Auxiliar de Risco de Mercado
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTRIS(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI

    // Quadro Auxiliar de Risco de Mercado
    dbSelectArea("BVU")
    BVU->(dbSetOrder(1) )   //B8H_FILIAL+B8H_CODOPE+B8H_CODOBR+B8H_ANOCMP+B8H_CDCOMP+B8H_CODIGO+B8H_MESCMP

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

            RecLock("BVU",.t.)
            BVU->BVU_FILIAL := xFilial("BVU")
            BVU->BVU_CODOPE := B3D->B3D_CODOPE
            BVU->BVU_CODOBR := B3D->B3D_CDOBRI
            BVU->BVU_ANOCMP := B3D->B3D_ANO 
            BVU->BVU_REFERE := StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) 
            BVU->BVU_CDCOMP := B3D->B3D_CODIGO
            BVU->BVU_CONTA  := aDados[nI,DAD_CTASUP]
            BVU->BVU_VALOR  := aDados[nI,DAD_VALOR]
            BVU->BVU_ESCX   := aDados[nI,DAD_SINAL]
            BVU->BVU_MESES  := 3    // periodo de meses do Diops
            BVU->BVU_INDEXA := aDados[nI,DAD_INDEX]
            BVU->(MsUnLock())
            nTotal++
        Next    
    EndIf     

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
Local cAlias    := "BVU"
Local cQuery    := ""
Local nX
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local cFiltro   := ""
Local cCodItem
Local dDataIni
Local dDataFim
Local cMoeda    := "01"
Local cTpSald   := "1"
LOcal cSinal
Local cCContabil
Local cCCusto
Local aRet      := {}

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
        aContas  := RetParDIOPS(cAlias,cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]    

        If lAchouCta
            // Monta query 
            cQuery := "SELECT CT1_CONTA, CT1_CTASUP, CT1_CLASSE, "
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
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBRIS",.F.,.T.)	
            TRBRIS->(dbGotop())

            While TRBRIS->(!Eof())
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Retorno SaldoCT7:                                    ³
                //³ [1] Saldo Atual (com sinal)                          ³
                //³ [2] Debito na Data                                   ³
                //³ [3] Credito na Data                                  ³
                //³ [4] Saldo Atual Devedor                              ³
                //³ [5] Saldo Atual Credor                               ³
                //³ [6] Saldo Anterior (com sinal)                       ³
                //³ [7] Saldo Anterior Devedor                           ³
                //³ [8] Saldo Anterior Credor                            ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                aSaldosAtu := SaldoCT7(TRBRIS->CT1_CONTA,dDataFim,cMoeda,cTpSald)
                cSinal     := IIf(aSaldosAtu[1]<0,"1","0")

                If Abs(aSaldosAtu[1]) > 0 
                    // Posiciona item
                    nPos := aScan(aRet,{|x| x[DAD_CTASUP]==Alltrim(TRBRIS->CT1_CTASUP);
                                                .And. x[DAD_SINAL]==cSinal;
                                                .And. x[DAD_INDEX]==TRBRIS->CODITEM})

                    If nPos > 0
                        aRet[nPos,DAD_VALOR] += Abs(aSaldosAtu[1])
                    Else    
                        aAdd(aRet,{TRBRIS->CT1_CONTA,Alltrim(TRBRIS->CT1_CTASUP),Abs(aSaldosAtu[1]),cSinal,TRBRIS->CODITEM})
                    EndIf 
                EndIf 

                TRBRIS->(dbSkip())
            EndDo 

            TRBRIS->(dbCloseArea())
        EndIf     

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())

Return(aRet)
