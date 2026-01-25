#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTCTP
Extrator DIOPS Financeiro
Conta Tributo Passivo 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTCTP(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nSequen  := 0
Local cChave   := ""
Local cConta
Local dDataCmp
Local nSaldoAnt
Local nSaldoAtu
Local nValorDeb
Local nValorAtu
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCCTP")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Conta Tributo Passivo 
    dbSelectArea("BUY")
    BUY->(dbSetOrder(1) )   //BUY_FILIAL+BUY_CODOPE+BUY_CODOBR+BUY_ANOCMP+BUY_CDCOMP+BUY_CONTA+BUY_SEQUEN  

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

            // Controle do sequencial da conta
            If Alltrim(aDados[nI,1])<>cConta
                cChave  := Alltrim(aDados[nI,1])
                nSequen := 0               
            EndIf 

            // Campos do Quadro 
            cConta      := Alltrim(aDados[nI,1])
            dDataCmp    := aDados[nI,2]
            nSaldoAnt   := aDados[nI,3]
            nValorDeb   := aDados[nI,4]
            nValorAtu   := aDados[nI,5]             
            nSaldoAtu   := aDados[nI,6]

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("BUYMASTER","BUY_FILIAL", xFilial("BUY") )
            oModel:SetValue("BUYMASTER","BUY_CODOPE", B3D->B3D_CODOPE )
            oModel:SetValue("BUYMASTER","BUY_CODOBR", B3D->B3D_CDOBRI )
            oModel:SetValue("BUYMASTER","BUY_ANOCMP", B3D->B3D_ANO )
            oModel:SetValue("BUYMASTER","BUY_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )
            oModel:SetValue("BUYMASTER","BUY_CDCOMP", B3D->B3D_CODIGO )
            oModel:SetValue("BUYMASTER","BUY_CONTA" , cConta )
            oModel:SetValue("BUYMASTER","BUY_DTCOMP", dDataCmp )
            oModel:SetValue("BUYMASTER","BUY_VLRINI", nSaldoAnt )
            oModel:SetValue("BUYMASTER","BUY_VLRPAG", nValorDeb )
            oModel:SetValue("BUYMASTER","BUY_ATUMON", nValorAtu )
            oModel:SetValue("BUYMASTER","BUY_SLDFIN", nSaldoAtu )
            oModel:SetValue("BUYMASTER","BUY_STATUS", "1" )                    
            oModel:SetValue("BUYMASTER","BUY_SEQUEN", StrZero(++nSequen,6) )                  

            If oModel:VldData()
                oModel:CommitData()
                nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão da conta contábil "+cConta+": "+cLog) 
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
Local cAlias    := "BUY"
Local cQuery    := ""
Local aPeriodo  := {}
Local aContas   := {}
Local cFiltro   := ""
Local nI
Local dDataIni
Local dDataFim
Local cMoeda    := "01"
Local cTpSald   := "1"
Local cConta    := ""
Local bSldCTBAnt
Local bSldCTBAtu
Local nSaldoAnt := 0
Local nDebito   := 0
Local nCredito  := 0
Local nSaldoAtu := 0
Local cCContabil
Local cCCusto
Local aRet      := {}
Local cTipoBanco := Alltrim(Upper(TCGetDb()))

    // Monta query 
    cQuery := "SELECT DISTINCT CT1_CONTA, B8B_CONTA "
    cQuery += " FROM "+RetSQLName("CT1")+" CT1 "
    cQuery += " INNER JOIN "+RetSqlName("B8B")+" B8B "
    cQuery += "         ON B8B_FILIAL = "+ValToSQL(xFilial("B8B"))
    cQuery += "            AND LTRIM(RTRIM(B8B_CONTA)) = "+;
                                IIf(cTipoBanco $ "MSSQL/MSSQL7","SUBSTRING(CT1_CTASUP,1,9)","SUBSTR(CT1_CTASUP,1,9) ")
    cQuery += "            AND B8B.D_E_L_E_T_ = '' "
    cQuery += " WHERE CT1_FILIAL = "+ValToSQL(xFilial("CT1"))

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Retorno da função: RetParDIOPS                     ³
    //³ [1] Codigo do Item 	                               ³
    //³ [2] Conta Contabil      		                   ³
    //³ [3] Centro de Custo     	                       ³
    //³ [4] Descricao do Identificador                 	   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    aContas := RetParDIOPS(cAlias)

    // Montagem do filtro relacionado as contas contabeis cadastradas no configurador Diops Financeiro 
    If Len(aContas)>0
        cFiltro := ""
        For nI := 1 to Len(aContas)
            cCContabil := Alltrim(aContas[nI,2])  // Conta Contabil 
            cCCusto    := Alltrim(aContas[nI,3])  // Centro de Custo 
            cFiltro += "(CT1_CONTA LIKE "+ValToSQL(cCContabil+"%")+") OR" 
        Next 

        If !Empty(cFiltro)
            cQuery += " AND ("+Substr(cFiltro,1,Len(cFiltro)-2)+") "
        Endif
    Else 
        // Caso não tenha informado nenhuma conta no configurador de regras utiliza todo grupo 1319
        cQuery += " AND CT1_CONTA LIKE '1319%' "
    EndIf     

    cQuery += "   AND CT1_CLASSE='2' "  
    cQuery += "   AND CT1.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY B8B_CONTA, CT1_CONTA "

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.F.,.T.)	
    (cAliasTrb)->(dbGotop())

    // Calcula periodo de datas do trimestre 
    aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
    dDataIni    := aPeriodo[1]
    dDataFim    := aPeriodo[2]    

    // Bloco de retorno do Saldo inicial (relacionado ao ultimo dia do mes anterior )
    bSldCTBAnt	:= {||SaldoCT7((cAliasTrb)->CT1_CONTA,dDataIni,cMoeda,cTpSald)}

    // Bloco de retorno do Saldo atual final do trimestre Diops 
    bSldCTBAtu	:= {||SaldoCT7((cAliasTrb)->CT1_CONTA,dDataFim,cMoeda,cTpSald)}

    // Posiciona no inicio da tabela 
    (cAliasTrb)->(dbGotop())

    While (cAliasTrb)->(!Eof())
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
        aSaldosAnt := Eval(bSldCTBAnt)
        aSaldosAtu := Eval(bSldCTBAtu)

        // Valores calculados pela função SaldoCT7
        nSaldoAnt  := aSaldosAnt[1]*-1
        nDebito    := (aSaldosAtu[7]-aSaldosAnt[4])*-1
        nCredito   := aSaldosAtu[8]-aSaldosAnt[5]
        nSaldoAtu  := aSaldosAtu[1]*-1

       // Conta do Plano ANS
        cConta := Alltrim((cAliasTrb)->B8B_CONTA)

        // Array de retorno 
        aAdd(aRet,{cConta,dDataIni,nSaldoAnt,nDebito,nCredito,nSaldoAtu})

        (cAliasTrb)->(dbSkip())
    EndDo 

    (cAliasTrb)->(DbCloseArea())

    // Grava log
	MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTCTP.log",cQuery)    

Return(aRet)
