#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

#define DAD_PLANO  1
#define DAD_ORIGEM 2
#define DAD_CONSUL 3 
#define DAD_EXAMES 4 
#define DAD_TERAPI 5 
#define DAD_INTERN 6 
#define DAD_OUTROS 7 
#define DAD_DEMAIS 8

#define REEMBOLSO   "04"

/*/{Protheus.doc} PLSEXTCBA
Extrator DIOPS Financeiro
Cobertura Assistencial                                      
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTCBA(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCCOAS")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Cobertura Assistencial 
    dbSelectArea("B8I")
    B8I->(dbSetOrder(1) )   //B8I_FILIAL+B8I_CODOPE+B8I_CODOBR+B8I_ANOCMP+B8I_CDCOMP+B8I_PLANO+B8I_ORIGEM

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
            oModel:SetValue("B8IMASTER","B8I_FILIAL", xFilial("B8I") )
            oModel:SetValue("B8IMASTER","B8I_CODOPE", B3D->B3D_CODOPE )        
            oModel:SetValue("B8IMASTER","B8I_CODOBR", B3D->B3D_CDOBRI )        
            oModel:SetValue("B8IMASTER","B8I_ANOCMP", B3D->B3D_ANO )        
            oModel:SetValue("B8IMASTER","B8I_CDCOMP", B3D->B3D_CODIGO )        
            oModel:SetValue("B8IMASTER","B8I_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )     
            oModel:SetValue("B8IMASTER","B8I_PLANO" , aDados[nI,DAD_PLANO] ) 
            oModel:SetValue("B8IMASTER","B8I_ORIGEM", aDados[nI,DAD_ORIGEM] ) 
            oModel:SetValue("B8IMASTER","B8I_CONSUL", aDados[nI,DAD_CONSUL] ) 
            oModel:SetValue("B8IMASTER","B8I_EXAMES", aDados[nI,DAD_EXAMES] ) 
            oModel:SetValue("B8IMASTER","B8I_TERAPI", aDados[nI,DAD_TERAPI] ) 
            oModel:SetValue("B8IMASTER","B8I_INTERN", aDados[nI,DAD_INTERN] ) 
            oModel:SetValue("B8IMASTER","B8I_OUTROS", aDados[nI,DAD_OUTROS] ) 
            oModel:SetValue("B8IMASTER","B8I_DEMAIS", aDados[nI,DAD_DEMAIS] ) 
            oModel:SetValue("B8IMASTER","B8I_STATUS", "1" )

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
Local cAlias    := "B8I"
Local cQuery 
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local dDataIni
Local dDataFim
Local nX
Local nPos
Local cFilQry
Local cNatJur
Local cPlano
Local cEvento
Local cOrigem
Local cCorrCed  := GETNEWPAR("MV_PLSTPIN","OPE")
Local cCContabil
Local cCCusto
Local aRet      := {}

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

    If lAchouCta 
        // Monta Query 
        cQuery := " SELECT Sum(BD7_VLRPAG) AS VALOR, "
        cQuery += "       BI3_APOSRG, "
        cQuery += "       BI3_NATJCO, "
        cQuery += "       BD7_TIPGUI, "
        cQuery += "       BD7_OPEUSR, "
        cQuery += "       BT5_INTERC, "
        cQuery += "       BAU_RECPRO, "
        cQuery += "       BD7_TPEVCT, "
        cQuery += "       BAU_TIPPRE, "
        cQuery += "       BD6_OPEORI "
        cQuery += "FROM   "+RetSqlName("BD7")+" BD7 "
        cQuery += "       INNER JOIN "+RetSqlName("BD6")+" BD6 "
        cQuery += "               ON BD6_FILIAL = "+ValToSQL(xFilial("BD6"))
        cQuery += "                  AND BD6_CODOPE = BD7_OPEUSR "
        cQuery += "                  AND BD6_CODEMP = BD7_CODEMP "
        cQuery += "                  AND BD6_CONEMP = BD7_CONEMP "
        cQuery += "                  AND BD6_VERCON = BD7_VERCON "
        cQuery += "                  AND BD6_CODLDP = BD7_CODLDP "
        cQuery += "                  AND BD6_CODPEG = BD7_CODPEG "
        cQuery += "                  AND BD6_NUMERO = BD7_NUMERO "
        cQuery += "                  AND BD6_CODPAD = BD7_CODPAD "
        cQuery += "                  AND BD6_CODPRO = BD7_CODPRO "
        cQuery += "                  AND BD6.D_E_L_E_T_ = '' "
        cQuery += "       INNER JOIN "+RetSqlName("BI3")+" BI3 "
        cQuery += "               ON BI3_FILIAL = "+ValToSQL(xFilial("BI3"))
        cQuery += "                  AND BI3_CODIGO = BD7_CODPLA "
        cQuery += "                  AND BI3.D_E_L_E_T_ = '' "
        cQuery += "       INNER JOIN "+RetSqlName("BAU")+" BAU "
        cQuery += "               ON BAU_FILIAL = "+ValToSQL(xFilial("BAU"))
        cQuery += "                  AND BAU_CODIGO = BD7_CODRDA "
        cQuery += "                  AND BAU.D_E_L_E_T_ = '' "
        cQuery += "       INNER JOIN "+RetSqlName("BT5")+" BT5 "
        cQuery += "               ON BT5_FILIAL = "+ValToSQL(xFilial("BT5"))
        cQuery += "                  AND BT5_CODINT = BD7_OPEUSR "
        cQuery += "                  AND BT5_CODIGO = BD7.BD7_CODEMP "
        cQuery += "                  AND BT5_NUMCON = BD7.BD7_CONEMP "
        cQuery += "                  AND BT5_VERSAO = BD7.BD7_VERCON "
        cQuery += "                  AND BT5.D_E_L_E_T_ = '' "

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

            If !Empty(cCCusto)
                cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+" AND CV3_CCC LIKE "+ValToSQL(cCCusto+"%")+") OR"
            Else
                cFilQry += " (CV3_CREDIT LIKE "+ValToSQL(cCContabil+"%")+") OR"
            EndIf 
        Next 

        If !Empty(cFilQry)
            cQuery += " AND ("+Substr(cFilQry,1,Len(cFilQry)-2)+") "
        Endif   

        cQuery += " WHERE  BD7_FILIAL = "+ValToSQL(xFilial("BD7"))
        cQuery += "       AND BD7_DTCTBF BETWEEN "+ValToSQL(dDataIni)+" AND "+ValToSQL(dDataFim)
        cQuery += "       AND BD7_SITUAC = '1' "
        cQuery += "       AND BD7_FASE = '4' "
        cQuery += "       AND BD7.D_E_L_E_T_ = ' ' "
        cQuery += " GROUP  BY BI3_APOSRG,BI3_NATJCO,BD7_TIPGUI,BD7_OPEUSR,BT5_INTERC,BAU_RECPRO,BD7_TPEVCT,BAU_TIPPRE,BD6_OPEORI "
        cQuery += " ORDER  BY BI3_APOSRG,BI3_NATJCO,BD7_TIPGUI,BD7_OPEUSR,BT5_INTERC,BAU_RECPRO,BD7_TPEVCT "
        cQuery := ChangeQuery(cQuery)

        cQuery := ChangeQuery(cQuery)
        MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTCBA.log",cQuery)    

        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBCBA",.F.,.T.)	
        TRBCBA->(dbGotop())

        While TRBCBA->(!Eof())
            /*
            BD7_CODPLA -> BI3_APOSRG (0-ANTES LEI/1-APOS LEI/2-ADAPTADO) BI3_NATJCO (2=Fisica;3=Empresarial;4=Adesao;5=Beneficente)
            IFAL = Carteira de Planos Individuais/Familiares antes da Lei
            IFPL = Carteira de Planos Individuais/Familiares pós Lei
            PLAL = Planos Coletivos por Adesão antes da Lei
            PLAP = Planos Coletivos por Adesão Pós Lei
            PCEA = Planos Coletivos Empresariais antes da Lei
            PCEL = Planos Coletivos Empresariais pós Lei
            CRAS = Cobertura Assistencial com Preço Pré Estabelecido - Corresponsabilidade Assumida (quando minha Operadora atende beneficiário de outra Operadora)
            */
            cNatJur := Alltrim(TRBCBA->BI3_NATJCO) 
            cPlano  := ""

            If TRBCBA->BD6_OPEORI <> PlsIntPad() .And. Alltrim(cCorrCed) == Alltrim(TRBCBA->BAU_TIPPRE)
                cPlano	:= "CRAS"
            Else
                If TRBCBA->BI3_APOSRG == "0"    // planos nao regulamentados
                    Do Case
                        Case cNatJur == "2"     // planos individual e familiar
                            cPlano  := "IFAL"
                        Case cNatJur == "3"     // planos coletivo empresarial
                            cPlano  := "PCEA"
                        Case cNatJur == "4"     // planos coletivo por adesao
                            cPlano  := "PLAL" 
                    EndCase
                Else
                    Do Case
                        Case cNatJur == "2"     // planos individual e familiar
                            cPlano  := "IFPL"
                        Case cNatJur == "3"     // planos coletivo empresarial
                            cPlano  := "PCEL"
                        Case cNatJur == "4"     // planos coletivo por adesao
                            cPlano  := "PLAP" 
                    EndCase
                EndIf
            EndIf     

            /*
            Tipo de Evento
            BD7_TPEVCT
            0 = Consulta			=> 01 - Consultas
            1 = Exames				=> 02/03 - Exames
            2 = Terapias			=> 04/05 - Terapias
            3 = Internações			=> 06-11 - Internações
            4 = Outros Atendimentos	=> 12 - Outros Atendimento
            5 = Demais Despesas		=> 13 - Demais Despesas
            13						=> 14 - Odonto
            */
            cEvento := TRBCBA->BD7_TPEVCT

            Do Case
                Case cEvento == "01"    // Consulta
                    nValPos := DAD_CONSUL 
                Case cEvento $ "02/03"  // Exame
                    nValPos := DAD_EXAMES
                Case cEvento $ "04/05"  // Terapias
                    nValPos := DAD_TERAPI
                Case cEvento $ "06/07/08/09/10/11" // Internações
                    nValPos := DAD_INTERN
                Case cEvento == "12"    // Outros Atendimentos
                    nValPos := DAD_OUTROS
                OtherWise   // Demais Despesas
                    nValPos := DAD_DEMAIS   
            EndCase

            /*
            Tipo de Prestador
            5 = Atendimentos em Corresponsabilidade	=> BD7_OPEUSR <> PlsIntPad() => Somente a partir de 2018
            2 = Reembolso				=> BD7->BD7_TIPGUI == REEMBOLSO
            3 = Intercâmbio Eventual	=> BT5->BT5_INTERC == '1'
            0 = Rede Própria			=> BAU_RECPRO = '1'
            1 = Rede Contratada			=> BAU_RECPRO = '0'
            4 = Outras Formas Pagamento	=> ELSE?
            6 = Corresponsabilidade Cedida
            */
            cOrigem := ""

            If Alltrim(cCorrCed) == Alltrim(TRBCBA->BAU_TIPPRE) .And. TRBCBA->BD6_OPEORI == PlsIntPad()
                cOrigem := "6"  // Corresponsabilidade Cedida - Quando outra Operadora atende meu beneficiário.
            Else    
                If TRBCBA->BD7_TIPGUI == REEMBOLSO
                    cOrigem := "1"  // Reembolso
                ElseIf TRBCBA->BT5_INTERC == "1"
                    cOrigem := "3"  // Intercâmbio
                ElseIf TRBCBA->BAU_RECPRO == "1"
                    cOrigem := "0"  // Rede Própria
                ElseIf TRBCBA->BAU_RECPRO == "0"
                    cOrigem := "1"  // Rede Contratada
                EndIf               
            EndIf     

            If !Empty(cPlano) .And. !Empty(cOrigem)       
                // Posiciona no item  para adicionar valores
                nPos := aScan(aRet,{|x| x[DAD_PLANO]==cPlano .And. x[DAD_ORIGEM]==cOrigem})

                If nPos == 0
                    aAdd(aRet,{cPlano,cOrigem,0,0,0,0,0,0})
                    nPos := Len(aRet)
                Endif 

                // Soma valores 
                aRet[nPos,nValPos] += TRBCBA->VALOR
            EndIf 

            TRBCBA->(dbSkip())
        EndDo 
    EndIf

    TRBCBA->(dbCloseArea())

Return(aRet)
