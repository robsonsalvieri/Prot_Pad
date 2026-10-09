#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} LOCA086SC
Processamento em schedule do reajuste de contratos
@type function
@version v1 
@author Frank Zwarg Fuga
@since 07/01/2026
/*/
Function LOCA086SC
Local aExecAuto := {}
Local aFil1 := {}
Local aAreaFP0
Local aAreaFPA  // Salva posicao do FPA antes de chamar LOCA086
Local cProjeto  := "" // Guarda codigo do projeto para evitar leitura de FP0 apos reposicionamento

Private LMSERROAUTO := .T.
        
    // SX1 correspondente para o schedule - LOCP078
    If MV_PAR01 == 1 // reajuste - atualização

        FP0->(dbSetOrder(1))
        FP0->(dbSeek(xFilial("FP0")))
        While !FP0->(Eof()) .and. FP0->FP0_FILIAL == xFilial("FP0")

            If FP0->FP0_PROJET >= MV_PAR02 .and. FP0->FP0_PROJET <= MV_PAR03
                
                aAreaFP0 := FP0->(GetArea())
                // Guarda o codigo do projeto ANTES de qualquer reposicionamento interno
                cProjeto := FP0->FP0_PROJET

                FPA->(dbSetOrder(1))
                FPA->(dbSeek(xFilial("FPA")+cProjeto))

                // Usa cProjeto (variavel local) pois FP0 pode ser reposicionado dentro de LOCA086
                While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == cProjeto

                    If FPA->FPA_OBRA >= MV_PAR15 .and. FPA->FPA_OBRA <= MV_PAR16

                        aExecAuto := {}
                        aFil1 := {}

                        aadd(aExecAuto,1) // Atualizacao
                        aadd(aExecAuto,cProjeto) // Projeto de
                        aadd(aExecAuto,cProjeto) // Projeto at
                        aadd(aExecAuto,MV_PAR04) // Data de
                        aadd(aExecAuto,MV_PAR05) // Data até
                        aadd(aExecAuto,MV_PAR06) // Bem de
                        aadd(aExecAuto,MV_PAR07) // Bem até
                        aadd(aExecAuto,MV_PAR08) // Indice de reajuste
                        aadd(aExecAuto,MV_PAR09) // Cliente de
                        aadd(aExecAuto,MV_PAR10) // Loja de
                        aadd(aExecAuto,MV_PAR11) // Cliente até
                        aadd(aExecAuto,MV_PAR12) // Loja até
                        aadd(aExecAuto,MV_PAR13) // Produto de
                        aadd(aExecAuto,MV_PAR14) // Produto até
                        aadd(aExecAuto,FPA->FPA_OBRA) // Localidade de
                        aadd(aExecAuto,FPA->FPA_OBRA) // Localidade até
                        aadd(aExecAuto,MV_PAR17) // aniversario de
                        aadd(aExecAuto,MV_PAR18) // aniversario até
                        aadd(aExecAuto,MV_PAR19) // atualiza aniversario
                        aadd(aExecAuto,MV_PAR20) // fator de reajuste
                        aadd(aExecAuto,MV_PAR21) // calcular automatico
                        aadd(aExecAuto,2) // reajusta medição

                        aadd(aFil1,FPA->FPA_SEQGRU) // identificacao da sequencia
                        aadd(aFil1,.F.)   // atualiza os titulos provisorios, não se esquecer do parametro "MV_LOCX278"
                        aadd(aFil1,"") // observacao
                        aadd(aFil1,FPA->FPA_DTENRE) // Dt.Fim.Locação
                        aadd(aFil1,FPA->FPA_NIVER) // Dt.Aniversario reajuste

                        // Salva e restaura posicao do FPA pois LOCA086 reposiciona o cursor internamente
                        aAreaFPA := FPA->(GetArea())
                        LOCA086(aExecAuto, aFil1)
                        FPA->(RestArea(aAreaFPA))

                    EndIf

                    FPA->(dbSkip())
                
                EndDo

            EndIf

            //FP0->(RestArea(aAreaFP0))
            FP0->(dbSkip())
        EndDo
    
    Endif

Return

/*/{Protheus.doc} SchedDef
Execucao da rotina via Schedule
@type function
@version v1
@author Frank Zwarg Fuga
@since 07/01/2026
@return variant, return_description
/*/
Static Function SchedDef()
Local aParam := {}

	aParam := 	{"P"	,;	//Tipo R para relatorio P para processo
				"LOCP078",;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		,;	//Titulo (para Relatorio)
				Nil		,;  //Nome   (para Relatorio)
				.F.     ,;  //indica se permite que o agendamento possa ser cadastrado como sempre ativo
				.T.}        //indica que o agendamento pode ser realizado por filiais
Return aParam
