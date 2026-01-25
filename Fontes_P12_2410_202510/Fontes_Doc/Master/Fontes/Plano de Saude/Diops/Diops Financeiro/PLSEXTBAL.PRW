#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTBAL
Extrator DIOPS Financeiro
Função para atualizar o quadro Balancete
@type function
@author sergio.srodrigues
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTBAL(oProcess)
Local nRegua     := 0
Local nTotal     := 0   // Quantidade de registros incluidos
Local lEnd		 := .F.
Local cArqTmp	 := GetNextAlias()
Local aSetOfBook := {}
Local lImpAntLP	 := .F.
Local lVlrZerado := .T.
Local lImpSint	 := .T.
Local cFilUser	 := ".T."
Local lRecDesp0  := .F.
Local cRecDesp	 := ""
Local dDtZeraRD	 := CtoD("")
Local cMoedaDsc	 := ""
Local aSelFil	 := {}
Local dDataIni	 := CtoD("")
Local dDataFim	 := CtoD("")
Local aPeriodo   := {}
Local cMesCmp    := ""
Local cRefere    := ""
Local cConta     := ""
Local nSldAnt
Local nSldAtu
Local nMeses     := 0
Local nI
Local cPicture	 := "@E 99999999999999.99"
Local aRet       := {}
Local cLog
Local oText
Local oDlg
Local oMeter
Local oModel     := FWLoadModel("PLSMVCBLC")

    // Balancete trimestral
    dbSelectArea("B8A")
    B8A->(dbSetOrder(1) )   //B8A_FILIAL+B8A_CODOPE+B8A_CODOBR+B8A_ANOCMP+B8A_CDCOMP+B8A_CONTA    

    // Inicializa os parametros para execução da função de retorno dos saldos contabeis
    aSetOfBook  := CTBSetOf("")
 
    // Calcula periodo (datas inicial e final) do compromisso Diops Financeiro 
    aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
    dDataIni    := aPeriodo[1]
    dDataFim    := aPeriodo[2]

    // Calcula o numero de meses para geracao do balancete
    nMeses := DateComp(dDataIni, dDataFim, "MM")

    // Processa o balancete para a quantidade de meses calculada no compromisso Diops
    For nI := 0 to nMeses   /*inicia em 0 (zero) para considerar o mês atual*/

        // Recalcula datas inicio e fim para utilizar periodo mensal (DIOPS Simplificado)
        dDataIni := MsSomaMes(dDataIni, IIf(nI>0,1,0))
        dDataFim := LastDay(dDataIni)

        // Executa a função para criar o arquivo temporario de saldos contabeis
        MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
            CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
            dDataIni,dDataFim,"CT7","","", Repl("Z", TamSx3("CT1_CONTA")[1]),,,,,,,"01","1",aSetOfBook,"","","","",;
            .F.,.F.,2,,lImpAntLP,CtoD(''),1,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
            cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
            OemToAnsi("Gerando Balancete "+dtoc(dDataIni)+" a "+dtoc(dDataFim)),; 
            OemToAnsi("Aguarde..."))

        // Total de registros para processar
        nRegua := 0
        cArqTmp->(dbGotop())   
        cArqTmp->(dbEval({||++nRegua}))
        cArqTmp->(dbGotop())	

        // Total de registros
        oProcess:SetRegua2(nRegua)        

        // Processa a inclusao dos registros 
        While cArqTmp->(!Eof())            
            oProcess:IncRegua2()

            // Verifica o tamanho da conta no padrao do plano ANS
            If Len(AllTrim(cArqTmp->CONTA))<=TAM_CTA_ANS
                
                cConta  := PadR(cArqTmp->CONTA,TamSx3("B8A_CONTA")[1])
                cMesCmp := StrZero(Month(dDataIni),2)
                cRefere := StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2)

                // Verifica se já não foi incluida a conta no mes de competencia 
                If !B8A->(dbSeek(xFilial("B8A")+B3D->B3D_CODOPE+B3D->B3D_CDOBRI+B3D->B3D_ANO+B3D->B3D_CODIGO+cConta+cMesCmp))

                    // TRATAMENTO SINAL SALDO INICIAL E ATUAL
                    cSinalAnt := ValorCTB(cArqTmp->SALDOANT,,,17,2,.T.,cPicture,cArqTmp->NORMAL,,,,"D",,.T.,.F.)
                    cSinalAnt := Substr(cSinalAnt,Len(cSinalAnt),1)

                    cSinalAtu := ValorCTB(cArqTmp->SALDOATU,,,17,2,.T.,cPicture,cArqTmp->NORMAL,,,,"D",,.T.,.F.)
                    cSinalAtu := Substr(cSinalAtu,Len(cSinalAtu),1)

                    nSldAnt := Abs(cArqTmp->SALDOANT)
                    nSldAtu := Abs(cArqTmp->SALDOATU)

                    Do Case
                        Case Substr(cArqTmp->CONTA,1,1)=="1"
                            nSldAnt := IIf(cSinalAnt=="C",nSldAnt*(-1),nSldAnt)
                            nSldAtu := IIf(cSinalAtu=="C",nSldAtu*(-1),nSldAtu)              
                        Case Substr(cArqTmp->CONTA,1,1)=="2"
                            nSldAnt := IIf(cSinalAnt=="D",nSldAnt*(-1),nSldAnt)
                            nSldAtu := IIf(cSinalAtu=="D",nSldAtu*(-1),nSldAtu)    
                        Case Substr(cArqTmp->CONTA,1,1)=="3"
                            nSldAnt := IIf(cSinalAnt=="D",nSldAnt*(-1),nSldAnt)
                            nSldAtu := IIf(cSinalAtu=="D",nSldAtu*(-1),nSldAtu)           
                        Case Substr(cArqTmp->CONTA,1,1)=="4"
                            nSldAnt := IIf(cSinalAnt=="C",nSldAnt*(-1),nSldAnt)
                            nSldAtu := IIf(cSinalAtu=="C",nSldAtu*(-1),nSldAtu)   
                    EndCase

                    oModel:SetOperation(MODEL_OPERATION_INSERT)
                    oModel:Activate(.T.)
                    oModel:SetValue("B8AMASTER","B8A_FILIAL", xFilial("B8A")  )
                    oModel:SetValue("B8AMASTER","B8A_CODOPE", B3D->B3D_CODOPE )
                    oModel:SetValue("B8AMASTER","B8A_CODOBR", B3D->B3D_CDOBRI )
                    oModel:SetValue("B8AMASTER","B8A_ANOCMP", B3D->B3D_ANO )
                    oModel:SetValue("B8AMASTER","B8A_MESCMP", cMesCmp )
                    oModel:SetValue("B8AMASTER","B8A_REFERE", cRefere )
                    oModel:SetValue("B8AMASTER","B8A_CDCOMP", B3D->B3D_CODIGO )                        	
                    oModel:SetValue("B8AMASTER","B8A_CONTA"	, cArqTmp->CONTA )
                    oModel:SetValue("B8AMASTER","B8A_SALANT", nSldAnt )
                    oModel:SetValue("B8AMASTER","B8A_DEBITO", cArqTmp->SALDODEB )
                    oModel:SetValue("B8AMASTER","B8A_CREDIT", cArqTmp->SALDOCRD )
                    oModel:SetValue("B8AMASTER","B8A_SALFIN", nSldAtu )
                    oModel:SetValue("B8AMASTER","B8A_STATUS", "1" )

                    If oModel:VldData()
                        oModel:CommitData()
                        nTotal++
                    Else
                        cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                        cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                        cLog += cValToChar(oModel:GetErrorMessage()[6])
                        aAdd(aRet,"Falha na atualização da conta contabil "+AllTrim(cArqTmp->CONTA)+": "+cLog)    
                    EndIf

                    oModel:DeActivate()
                EndIf    
            EndIf 

            cArqTmp->(dbSkip())
        EndDo  

        cArqTmp->(dbCloseArea())  
    Next

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return({nTotal,aRet})
