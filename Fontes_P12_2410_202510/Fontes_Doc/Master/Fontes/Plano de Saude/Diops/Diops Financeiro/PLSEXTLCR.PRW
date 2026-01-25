#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTLCR
Extrator DIOPS Financeiro
Lucros e Prejuizos
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTLCR(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local cCodItem
Local nValorCtb
Local nI
Local cLog
Local oModel    := FWLoadModel("PLSMVCLCR")

Private INCLUI	:= .F.
Private ALTERA	:= .F.
Private EXCLUI	:= .F.
Private VISUAL	:= .F.

    // Lucros e Prejuizos
    dbSelectArea("B8E")
    B8E->(dbSetOrder(1) )   //B8H_FILIAL+B8H_CODOPE+B8H_CODOBR+B8H_ANOCMP+B8H_CDCOMP+B8H_CODIGO+B8H_MESCMP

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
            nValorCtb   := aDados[nI,2]

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("B8EMASTER","B8E_FILIAL", xFilial("B8E") )
            oModel:SetValue("B8EMASTER","B8E_CODOPE", B3D->B3D_CODOPE )
            oModel:SetValue("B8EMASTER","B8E_CODOBR", B3D->B3D_CDOBRI )
            oModel:SetValue("B8EMASTER","B8E_ANOCMP", B3D->B3D_ANO )
            oModel:SetValue("B8EMASTER","B8E_REFERE", StrZero(Val(Substr(B3D->B3D_REFERE,1,1)),2) )
            oModel:SetValue("B8EMASTER","B8E_CDCOMP", B3D->B3D_CODIGO )
            oModel:SetValue("B8EMASTER","B8E_DESCRI", cCodItem )
            oModel:SetValue("B8EMASTER","B8E_VLRCON", nValorCtb )
            oModel:SetValue("B8EMASTER","B8E_STATUS", "1" )                    

            If oModel:VldData()
                oModel:CommitData()
                nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão do Item "+cCodItem+": "+cLog) 
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
Local cAlias    := "B8E"
Local cQuery    := ""
Local nX
Local aPeriodo  := {}
Local aContas   := {}
Local lAchouCta := .F.
Local cFiltro   := ""
Local cCodItem
Local dDataIni
Local dDataFim
Local cMoeda    := "01"
Local cTpSald   := "1"
Local cCContabil
Local cCCusto
Local nValorCtb := 0
Local nTipoVlr 
Local aPositivos := {"3"}
Local aNegativos := {"1","2","5","7"}

Local aRet      := {}

    // Query utilizada para retornar os itens do Quadro
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
        cCodItem := Alltrim((cAliasTrb)->B3Y_ITEM)

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

        // Calcula periodo de datas do trimestre 
        aPeriodo    := RetPerDIOPS(B3D->B3D_REFERE,B3D->B3D_ANO)
        dDataIni    := aPeriodo[1]
        dDataFim    := aPeriodo[2]    

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
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBLCR",.F.,.T.)	
            TRBLCR->(dbGotop())

            While TRBLCR->(!Eof())
                //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                //³ Retorno:                                           ³
                //³ [1] Movimento Devedor 	                           ³
                //³ [2] Movimento Credor		                       ³
                //³ [3] Movimento do Mes		                       ³
                //³ [4] Saldo Final                                	   ³
                //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                Do Case
                    Case cCodItem == "2"    // Constituicao de Reserva
                        nTipoVlr := 2   // Credito
                    Case cCodItem == "3"    // Reversao de Reversa
                        nTipoVlr := 1   // Debito
                OtherWise    
                    nTipoVlr := 4   // Todos os demais pega o Saldo Final 
                EndCase 

                // Retorna valor contabil
                nValorCtb += MovConta(TRBLCR->CT1_CONTA,dDataIni,dDataFim,cMoeda,cTpSald,nTipoVlr /*Tipo de Retorno*/)

                TRBLCR->(dbSkip())
            EndDo 

            TRBLCR->(dbCloseArea())
        EndIf     

        // Valores com sinal positivo
        If AScan(aPositivos,cCodItem)>0
            nValorCtb := Abs(nValorCtb)
        EndIf 

        // Valores com sinal negativo
        If AScan(aNegativos,cCodItem)>0
            nValorCtb := Abs(nValorCtb)*-1
        EndIf 

        // Grava valor do item 
        aAdd(aRet,{cCodItem,nValorCtb})

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(DbCloseArea())

Return(aRet)

