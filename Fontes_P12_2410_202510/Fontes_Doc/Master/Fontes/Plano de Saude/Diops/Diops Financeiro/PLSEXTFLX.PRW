#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTFLX
Extrator DIOPS Financeiro
Fluxo de Caixa
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTFLX(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local cMesCmp
Local cCodItem
Local nValorCtb
Local aRet     := {}
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCFLCX")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Fluxo de Caixa
    dbSelectArea("B8H")
    B8H->(dbSetOrder(1) )   //B8H_FILIAL+B8H_CODOPE+B8H_CODOBR+B8H_ANOCMP+B8H_CDCOMP+B8H_CODIGO+B8H_MESCMP

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
            cMesCmp     := aDados[nI,1]
            cCodItem    := aDados[nI,2]            
            nValorCtb   := aDados[nI,3]

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("B8HMASTER","B8H_FILIAL", xFilial("B8H") )
            oModel:SetValue("B8HMASTER","B8H_CODOPE", B3D->B3D_CODOPE )
            oModel:SetValue("B8HMASTER","B8H_CODOBR", B3D->B3D_CDOBRI )
            oModel:SetValue("B8HMASTER","B8H_ANOCMP", B3D->B3D_ANO )
            oModel:SetValue("B8HMASTER","B8H_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )          
            oModel:SetValue("B8HMASTER","B8H_MESCMP", cMesCmp )  
            oModel:SetValue("B8HMASTER","B8H_CDCOMP", B3D->B3D_CODIGO )
            oModel:SetValue("B8HMASTER","B8H_CODIGO", cCodItem )
            oModel:SetValue("B8HMASTER","B8H_VLRCON", nValorCtb )
            oModel:SetValue("B8HMASTER","B8H_STATUS", "1" )     

            If oModel:VldData()
                oModel:CommitData()
                nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão do Item "+cCodItem+" no mês de competência "+cMesCmp+": "+cLog) 
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
Local cAlias    := "B8H"
Local cQuery    := ""
Local nI
Local nX
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local cFiltro   := ""
Local cCodItem
Local dDataIni
Local dDataFim
Local cMesCmp
Local cMoeda    := "01"
Local cTpSald   := "1"
Local nValorCtb := 0
Local aNegativo := {"105","106","107","108","109","110","111","112","113","114","115","206","207","208","209","210","305","306","307","308"}
Local cCContabil
Local cCCusto
Local nTipoVlr
Local aRet      := {}

    // Query utilizada para retornar os itens do quadro
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
        cCodItem   := Alltrim((cAliasTrb)->B3Y_ITEM)

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Retorno da função: RetParDIOPS                     ³
        //³ [1] Codigo do Item 	                               ³
        //³ [2] Conta Contabil      		                   ³
        //³ [3] Centro de Custo     	                       ³
        //³ [4] Descricao do Identificador                 	   ³        
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ           
        aContas := RetParDIOPS(cAlias,cCodItem)

        // Verifica se possui contas contabeis parametrizadas no configurador Diops Financeiro 
        lAchouCta := Len(aContas)>0

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]

        // Calcula o numero de meses para geracao do quadro
        nMeses := DateComp(dDataIni, dDataFim, "MM")

        // Processa o quadro para a quantidade de meses calculada no compromisso Diops
        For nI := 0 to nMeses   /*inicia em 0 (zero) para considerar o mês atual*/

            // Recalcula datas inicio e fim para utilizar periodo mensal (DIOPS Simplificado)
            dDataIni := MsSomaMes(dDataIni, IIf(nI>0,1,0))
            dDataFim := LastDay(dDataIni)

            // Mes da competência para gravar o campo Diops Mensal
            cMesCmp  := StrZero(Month(dDataIni),2)

            // Valor contabil movimento das contas 
            nValorCtb := 0

            If lAchouCta
                // Monta query 
                cQuery := "SELECT CT1_CONTA, CT1_CLASSE, "
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
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBFLX",.F.,.T.)	
                TRBFLX->(dbGotop())

                While TRBFLX->(!Eof())
                    // Natureza da conta 1=Ativo;2=Passivo;3=Receita;4=Despesa
                    If Substr(TRBFLX->CT1_CONTA,1,1) == "1" // Ativo 
                        nTipoVlr := 2   // Creditos no Mes
                    ElseIf Substr(TRBFLX->CT1_CONTA,1,1) == "2" // Passivo 
                        nTipoVlr := 1   // Debitos no Mes
                    Else
                        nTipoVlr := 3   // Movimento do Mes    
                    EndIf 

                    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                    //³ nTipoVlr:                                          ³
                    //³ [1] Movimento Devedor 	                           ³
                    //³ [2] Movimento Credor		                       ³
                    //³ [3] Movimento do Mes		                       ³
                    //³ [4] Saldo Final                                	   ³
                    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                    nValorCtb += MovConta(TRBFLX->CT1_CONTA,dDataIni,dDataFim,cMoeda,cTpSald,nTipoVlr /*Tipo de Retorno*/)

                    TRBFLX->(dbSkip())
                EndDo 

                TRBFLX->(dbCloseArea())
            EndIf     

            // Ajusta o valor para os itens que são informados com sinal negativo (-)
            If nValorCtb > 0 .And. AScan(aNegativo, cCodItem) > 0
                nValorCtb := (nValorCtb*-1)
            Else
                nValorCtb := Abs(nValorCtb)    
            EndIf 

            // Grava valor do item 
            aAdd(aRet,{cMesCmp,cCodItem,nValorCtb})
        Next    

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())

Return(aRet)
