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
                        // Encontrar a demanda na Qual a AS está ligada 
                        FQ5->(dbSetOrder(9))
                        if FQ5->(dbSeek(xFilial("FQ5")+ aFPZTransf[nx,nPosAS, 2]))
                            RecLock("FQ5")
                            FQ5->FQ5_STDEMA := '5'
                            msUnlock()
                            // Verificar se todas as AS da demanda foram faturadas

                            // Buscar a Demanda para indicar o Faturamento gerado
                            FQT->(dbSetOrder(1))
                            if FQT->(dbSeek(xFilial("FQT")+ FQ5->FQ5_DEMAND))
                                RecLock("FQT", .F.)
                                if LOCM006VD( FQ5->FQ5_DEMAND )
                                    FQT->FQT_FATURA := FQT->FQT_QTDPRO
                                    FQT->FQT_PENDEN := 0
                                else
                                    FQT->FQT_FATURA += FQV->FQV_QTD
                                    FQT->FQT_PENDEN -= FQV->FQV_QTD
                                endif
                                msUnlock()
                            EndIf
                        endif

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

/*/{Protheus.doc} LOCM006VD
Verifica se todos os itens da demanda tiveram a remessa gerada
@type function
@version  25.10
@author Alexandre Circenis
@since 20/04/2026
@param cDemanda, character, Demanda dos itens está tendo remessa gerada
@return variant, .T. se não há item da demanda sem remessa gerada
/*/
Static Function LOCM006VD(cDemanda)
Local lRet       := .T.
Local aArea      := GetArea()
Local cQuery     := ''
Local cAliasT    := GetNextAlias()
Local aBindParam := {}

cQuery := "SELECT Count(FQ5_DEMAND) ITEM"
cQuery += " FROM "+RetSqlName("FQ5")
cQUERY += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
cQuery += " and FQ5_DEMAND = ?"
cQuery += " and FQ5_STDEMA <> '5'"
cQuery += " and D_E_L_E_T_ = ' '"
Aadd(aBindParam, cDemanda)

cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
MPSysOpenQuery(cQuery,cAliasT,,,aBindParam)

lRet := (cAliasT)->ITEM = 0

RestArea(aArea)

Return lRet
