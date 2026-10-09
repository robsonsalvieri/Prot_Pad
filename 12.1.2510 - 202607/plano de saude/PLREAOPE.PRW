#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLREAOPE 
Cadastro de reajuste de planos a partir da operadora
/*/
//-------------------------------------------------------------------
Function PLREAOPE()
    AxCadastro("B0I", OemToAnsi("Parametrização de Reajuste de Planos"), "Exclusao()")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Exclusao 
Confirma a exclusao de um cadastro de reajuste
/*/
//-------------------------------------------------------------------
Function Exclusao()
    
    Local lRetExc := FWAlertYesNo( 'Confirma a exclusão?', 'Exclusão' )
    
    If lRetExc
        FWAlertSuccess("Registro excluido com sucesso", "Exclusão")
    Else
        FWAlertInfo("O registro não foi excluido", "Exclusão")
    EndIf
Return lRetExc

//-------------------------------------------------------------------
/*/{Protheus.doc} VldRegDupl 
Nao permite inserir mais de um registro com o mesmo mes e ano
/*/
//-------------------------------------------------------------------
Function VldRegDupl()

    Local lRetVld := .T.

    If !EMPTY(M->B0I_ANO) .AND. !EMPTY(M->B0I_MES)

        B0I->(DbSetOrder(1))
        If B0I->(MsSeek( xFilial("B0I") + M->(B0I_CODINT + B0I_ANO + B0I_MES)))
             FWAlertWarning("Já existe um cadastro com o mês e ano informados, o sistema não permite que exista mais de um cadastro com o mesmo ano e mês", "Atenção")
            lRetVld := .F.
        EndIf
    EndIf

Return lRetVld
