#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define TAM_CTA_ANS  9   // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTPLA
Extrator DIOPS Financeiro
Rotina de execução para atualização do plano de contas ANS 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTPLA(oProcess)
Local cAliasTrb := GetNextAlias()
Local nRegua    := 0
Local nTotal    := 0 // Quantidade de registros incluidos 
Local aRet      := {}
Local cLog

Local oModel    := FWLoadModel("PLSMVCPLAC")

    // Plano de contas ANS
    dbSelectArea("B8B")
    B8B->(dbSetOrder(1))    //B8B_FILIAL+B8B_CODOPE+B8B_CONTA+DTOS(B8B_VIGINI)+DTOS(B8B_VIGFIN)

    // Plano de Contas CT1
    dbSelectArea("CT1")
    CT1->(dbSetOrder(1))    //CT1_FILIAL+CT1_CONTA

    // Quary para retorna plano de contas
    BeginSQL Alias cAliasTrb
        Select CT1_FILIAL, CT1_CONTA, CT1.R_E_C_N_O_ AS CT1REC
          From %Table:CT1% CT1
            Where CT1.%NotDel%
              And CT1_FILIAL = %xFilial:CT1%
        Order By CT1_FILIAL, CT1_CONTA  
    EndSQL 

    // Quantidade de registros para processar
    (cAliasTrb)->(dbGotop())
    (cAliasTrb)->(dbEval({||++nRegua}))
    (cAliasTrb)->(dbGotop())

    // Total de registros
    oProcess:SetRegua2(nRegua)

    While (cAliasTrb)->(!Eof())
        oProcess:IncRegua2()

        // Posiciona registro na CT1
        CT1->(dbGoto((cAliasTrb)->CT1REC))

        // Verifica o tamanho da conta no padrao do plano ANS
        If Len(AllTrim(CT1->CT1_CONTA))<=TAM_CTA_ANS

            // Verifica a existencia da conta no plano de contas ANS da Central de Obrigações 
            If !B8B->(dbSeek(xFilial("B8B")+B3D->B3D_CODOPE+CT1->(CT1_CONTA+DTOS(CT1_DTEXIS)+DTOS(CT1_DTEXSF))))
                oModel:SetOperation(MODEL_OPERATION_INSERT)
                oModel:Activate(.T.)
                oModel:SetValue("B8BMASTER","B8B_FILIAL",xFilial("B8B"))
                oModel:SetValue("B8BMASTER","B8B_CODOPE",B3D->B3D_CODOPE)
                oModel:SetValue("B8BMASTER","B8B_CONTA" ,CT1->CT1_CONTA)
                oModel:SetValue("B8BMASTER","B8B_DESCRI",Substr(CT1->CT1_DESC01,1,149))
                oModel:SetValue("B8BMASTER","B8B_VIGINI",CT1->CT1_DTEXIS)
                oModel:SetValue("B8BMASTER","B8B_VIGFIN",CT1->CT1_DTEXSF)

                //FWFldPut("B8B_CODOPE",aRetDIOPS[CODOPE],,,,.T.)
                //FWExecView( aQuadrosDIOPS[nQuadro,DESQUADRO], "PLSMVCPLAC", nOpc, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
            
                If oModel:VldData()
                    oModel:CommitData()
                    nTotal++ 
                Else
                    cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                    cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                    cLog += cValToChar(oModel:GetErrorMessage()[6])
                    
                    aAdd(aRet,"Falha na inclusão da conta contabil "+AllTrim(CT1->CT1_CONTA)+": "+cLog)    
                EndIf

                oModel:DeActivate()
            EndIf    
        EndIf 

        (cAliasTrb)->(dbSkip())
    EndDo 

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return({nTotal,aRet})
