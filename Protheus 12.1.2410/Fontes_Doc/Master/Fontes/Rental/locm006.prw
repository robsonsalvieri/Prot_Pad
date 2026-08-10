#include "totvs.ch"
#include "PROTHEUS.ch"

/*/{Protheus.doc} LOCM006
Ponto de entrada ao final da gravação do pedido de vendas
@author Juliano Bobbio
@since 24/08/2020
@version undefined
Antigo ponto de entrada M410STTS
/*/

Function LOCM006()
Local _aArea :=	{FP0->(GetArea()),FQ2->(GetArea()),SC6->(GetArea()),FQ3->(GetArea()),GetArea()} 
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local nPosRoma := 0
Local nPosAux
Local nPosAS
Local nX

    If lMvLocBac

        // Tratamento para a geração das tabelas auxiliares de relacionamento entre o Rental x Faturamento
        If (INCLUI .And. IsInCallStack("LOCA010")) .or. IsInCallStack("LOCA048") .or. IsInCallStack("LOCA229I")
            // aFPYTransf e aFPZTransf são alimentadas no loca010
            If Type("aFPYTransf") == "A" .and. Type("aFPZTransf") == "A"
                nPosRoma := Ascan(aFPYTransf, {|x| x[1] = 'FPY_NFDEVO'})
                nPosAux := Ascan(aFPYTransf, {|x| x[1] = 'FPY_PEDVEN'})
                aFPYTransf[nPosAux, 2] := SC5->C5_NUM
                For nX := 1 to len(aFPZTransf)
                    nPosAux := Ascan(aFPZTransf[nX], {|x| x[1] = 'FPZ_PEDVEN'})
                    aFPZTransf[nx,nPosAux, 2] := SC5->C5_NUM
                Next
                // Grava as tabelas de auxiliares do pedido
                LOCA0822(aFPYTransf, aFPZTransf)
                if  IsInCallStack("LOCA229I") // Veio do Novo Romaneio atualizar os dados

                    FQV->(dbSetOrder(2))
                    For nX := 1 to len(aFPZTransf)
                        nPosAux := Ascan(aFPZTransf[nX], {|x| x[1] = 'FPZ_ITEM'})
                        nPosAS  := Ascan(aFPZTransf[nX], {|x| x[1] = 'FPZ_AS'})
                        FQV->(dbSeek(xFilial("FQV")+ aFPZTransf[nx,nPosAS, 2]))
                        RecLock("FQV", .F.)
                        FQV->FQV_PEDIDO := SC5->C5_NUM
                        FQV->FQV_ITEMPV := aFPZTransf[nx, nPosAux, 2]
                        FQV->FQV_STATUS := '5' // Pedido emitido
                        msUnlock()
                    next nx 
               
                endif
            EndIF
        EndIF

        If INCLUI .And. IsInCallStack("LOCA010") .and. nPosRoma > 0
            //Posiciono na cabeçalho do Romaneio
            FQ2->(DbSetOrder(1)) //Z0_FILIAL + Z0_ASF + Z0_NUM
            If FQ2->(DbSeek(xFilial('FQ2') + aFPYTransf[nPosRoma, 2]))
                Reclock('SC5',.F.)
                SC5->C5_TRANSP := FQ2->FQ2_XCODTR
                SC5->(MsUnlock())
            EndIf
        EndIf
    EndIf
    
    //Ponto de Entreda a ser executado após processo do RENTAL

    If Existblock("LOCM006A")
        Execblock("LOCM006A",.F.,.F.)
    EndIf

    AEval(_aArea, {|x,y| RestArea(x)} )
Return Nil
