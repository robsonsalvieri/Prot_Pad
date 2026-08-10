#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTFCO
Extrator DIOPS Financeiro
Fundos Comuns de Despesas Assistenciais
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTFCO(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local cCodItem
Local cDesItem
Local nSaldoCrd
Local nSaldoDeb
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCFUCO")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Fundos Comuns de Despesas Assistenciais
    dbSelectArea("B6R")
    B6R->(dbSetOrder(1) )   //B8H_FILIAL+B8H_CODOPE+B8H_CODOBR+B8H_ANOCMP+B8H_CDCOMP+B8H_CODIGO+B8H_MESCMP

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

            // Campos do Quadro 
            cCodItem    := aDados[nI,1]  
            cCodPart    := aDados[nI,2]          
            cDesItem    := aDados[nI,3]
            nSaldoCrd   := aDados[nI,4]
            nSaldoDeb   := aDados[nI,5]

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("B6RMASTER","B6R_FILIAL", xFilial("BR6") )
            oModel:SetValue("B6RMASTER","B6R_CODOPE", B3D->B3D_CODOPE )
            oModel:SetValue("B6RMASTER","B6R_CODOBR", B3D->B3D_CDOBRI )
            oModel:SetValue("B6RMASTER","B6R_ANOCMP", B3D->B3D_ANO )
            oModel:SetValue("B6RMASTER","B6R_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )
            oModel:SetValue("B6RMASTER","B6R_CDCOMP", B3D->B3D_CODIGO )
            oModel:SetValue("B6RMASTER","B6R_TIPO"  , cCodItem )
            oModel:SetValue("B6RMASTER","B6R_NOME"  , cDesItem )
            oModel:SetValue("B6RMASTER","B6R_SLDCRD", nSaldoCrd )
            oModel:SetValue("B6RMASTER","B6R_SLDDEB", nSaldoDeb )
            oModel:SetValue("B6RMASTER","B6R_STATUS", "1" )      

            If AllTrim(cCodItem)=="FCA"
                oModel:SetValue("B6RMASTER","B6R_OPEPAR", cCodPart )                    
            Else
                oModel:SetValue("B6RMASTER","B6R_OPEADM", cCodPart )                    
            EndIf  

            If oModel:VldData()
                oModel:CommitData()
                nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão do Item "+cCodItem+" "+cDesItem+": "+cLog) 
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
Local cAlias    := "B6R"
Local cQuery    := ""
Local nX
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local cConta
Local cFiltro   := ""
Local cCodItem
Local cDesItem
Local cCodPart
Local nSaldoCrd
Local nSaldoDeb
Local dDataIni
Local dDataFim
Local cMoeda    := "01"
Local cTpSald   := "1"
Local aSaldosAtu
Local nValorCtb
Local aCtasFCO
Local cPicture	 := "@E 99999999999999.99"
Local nPos
LOcal cCContabil
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
        cDesItem := Upper(Alltrim((cAliasTrb)->B3Y_DESCRI))
        cCodPart := B3D->B3D_CODOPE /*assume o codigo da operadora como Default*/

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Retorno fRetCtasFCO:                                 ³
        //³ [1] Tipo FCA ou FCP                                  ³
        //³ [2] Conta Contabil                                   ³
        //³ [3] C=Credora ou D=Devedora                          ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ            
        aCtasFCO := fRetCtasFCO(cCodItem)        

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

        // Monta query 
        cQuery := "SELECT CT1_CONTA, CT1_NORMAL, "
        cQuery += " '"+cCodItem+"' AS CODITEM "
        cQuery += " FROM "+RetSQLName("CT1")+" CT1 "
        cQuery += " WHERE CT1_FILIAL = "+ValToSQL(xFilial("CT1"))

        If lAchouCta
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
        Else
            // Caso o usuário não tenha informado as contas contabeis no configurador Diops Financeiro 
            // Considera os grupos de contas definidos pelo manual do Diops ANS 
            // Montagem do filtro relacionado as contas especificas do Quadro 
            cFiltro := ""
            For nX := 1 to Len(aCtasFCO)
                If aCtasFCO[nX,1] == cCodItem
                    cFiltro += " (CT1_CONTA LIKE "+ValToSQL(aCtasFCO[nX,2]+"%")+") OR"
                EndIf     
            Next

            If !Empty(cFiltro)
                cQuery += " AND ("+Substr(cFiltro,1,Len(cFiltro)-2)+") "
            Endif            
        EndIf 

        cQuery += "   AND CT1_CLASSE='2' "  
        cQuery += "   AND CT1.D_E_L_E_T_ = '' "
        cQuery += " ORDER BY CODITEM, CT1_CONTA "

        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBFCO",.F.,.T.)	
        TRBFCO->(dbGotop())

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]    

        // Saldos contabeis
        nSaldoCrd := 0
        nSaldoDeb := 0

        While TRBFCO->(!Eof())
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
            aSaldosAtu := SaldoCT7(TRBFCO->CT1_CONTA,dDataFim,cMoeda,cTpSald)

            // Valida se a conta informada pertence ao grupo de contas do Quadro 
            cConta     := Substr(TRBFCO->CT1_CONTA,1,TAM_CTA_ANS)
            nPos := aScan(aCtasFCO,{|x| x[1]==cCodItem .And. x[2]==cConta})

            If nPos > 0
                If aCtasFCO[nPos,1]==cCodItem .And. aCtasFCO[nPos,2]==cConta
                    // Converte o valor contabil (com sinal )
                    nValorCtb  := Val(StrTran(ValorCTB(aSaldosAtu[1],,,17,2,.T.,cPicture,TRBFCO->CT1_NORMALNORMAL,,,,"S",,.T.,.F.),",","."))

                    // Soma Saldos Credor e Devedor 
                    nSaldoCrd += Iif(aCtasFCO[nPos,3]=="C",nValorCtb,0) // Saldo Credor
                    nSaldoDeb += Iif(aCtasFCO[nPos,3]=="D",nValorCtb,0) // Saldo Devedor
                EndIf 
            EndIf 

            TRBFCO->(dbSkip())
        EndDo 

        TRBFCO->(dbCloseArea())

        // Adicional o array de retorno 
        aAdd(aRet,{cCodItem,cCodPart,cDesItem,nSaldoCrd,nSaldoDeb})

        // Grava log
        MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTFCO_"+cCodItem+"_"+cCodPart+".log",cQuery)    

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())

Return(aRet)

/*/{Protheus.doc} fRetCtasFCO()
Retorna contas contabeis para validar o FCO  
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetCtasFCO(cCodItem)
Local aRet := {}

    Do Case
        Case cCodItem == "FCA"
            //Saldos de Programas ou Fundos Comuns de Despesas de Assistência Médico-Hospitalar Administrados pela Operadora
            //Saldo Credor (1241X9082)
            //Saldo Devedor (214889082)
            aAdd(aRet,{cCodItem,"124119082","C"})
            aAdd(aRet,{cCodItem,"124129082","C"})
            aAdd(aRet,{cCodItem,"214889082","D"})
        Case cCodItem == "FCP"
            // Participações em Programas ou Fundos Comuns de Despesas de Assistência Médico-Hospitalar
            // Saldo Credor (Conta 1239XX082)
            // Saldo Devedor (Conta 2138X9082)
            aAdd(aRet,{cCodItem,"123911082","C"})
            aAdd(aRet,{cCodItem,"123912082","C"})
            aAdd(aRet,{cCodItem,"123921082","C"})
            aAdd(aRet,{cCodItem,"123922082","C"})       
            aAdd(aRet,{cCodItem,"213819082","D"})
            aAdd(aRet,{cCodItem,"213829082","D"})
    EndCase

Return(aRet)
