#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "FWMVCDEF.CH"

#define DIR_LOG_DIOPS "\logpls\"+DtoS(Date())+"\"

#define TAM_CTA_ANS  9  // tamanho da conta contabil plano ANS
#define DIOPS       "3" // tipo de obrigacao DIOPS
#define ATIVO       "1" // status da obrigacao ATIVO

/*/{Protheus.doc} PLSEXTAGI
Extrator DIOPS Financeiro
Atitvo Garantidor Imobiliario 
@type function
@author DXM Team
@since 02/10/2024
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function PLSEXTAGI(oProcess)
Local nRegua
Local nTotal   := 0 // Quantidade de registros incluidos 
Local aDados   := {}
Local aRet     := {}
Local nI
Local cLog
Local oModel     := FWLoadModel("PLSMVCAGI")

    // Atitvo Garantidor Imobiliario 
    dbSelectArea("B8C")
    B8C->(dbSetOrder(1) )   //B8C_FILIAL+B8C_CODOPE+B8C_CODOBR+B8C_ANOCMP+B8C_CDCOMP+B8C_CODRGI

    // Retorno dos dados 
    aDados := fRetDados()
    
    // Verifica se possui dados para processar no quadro 
    If Len(aDados)>0
        // Total de registros
        nRegua  := Len(aDados)
        oProcess:SetRegua2(nRegua)

        // Processa a inclusao dos registros 
        For nI := 1 to Len(aDados)
            oProcess:IncRegua2()

            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate(.T.)
            oModel:SetValue("B8CMASTER","B8C_FILIAL", xFilial("B8C"))
            oModel:SetValue("B8CMASTER","B8C_CODOPE", aDados[nI,1] )    // cod operadora
            oModel:SetValue("B8CMASTER","B8C_CODOBR", aDados[nI,2] )    // cod obrigacao  
            oModel:SetValue("B8CMASTER","B8C_ANOCMP", aDados[nI,3] )    // ano compromisso 
            oModel:SetValue("B8CMASTER","B8C_REFERE", aDados[nI,4] )    // referencia 
            oModel:SetValue("B8CMASTER","B8C_CDCOMP", aDados[nI,5] )    // cod compromisso 
            oModel:SetValue("B8CMASTER","B8C_CODRGI", aDados[nI,6] )    // Regra geral do imovel
            oModel:SetValue("B8CMASTER","B8C_REDPRO", aDados[nI,7] )    // Indica se o imovel e rede propria
            oModel:SetValue("B8CMASTER","B8C_ASSIST", aDados[nI,8] )    // Ativo assistencial
            oModel:SetValue("B8CMASTER","B8C_VLRCON", aDados[nI,9] )    // Valor contabil do imovel 
            oModel:SetValue("B8CMASTER","B8C_STATUS", "1" )                    

            If oModel:VldData()
                oModel:CommitData()
                 nTotal++ 
            Else
                cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
                cLog += cValToChar(oModel:GetErrorMessage()[6])     

                aAdd(aRet,"Falha na inclusão do registro codigo "+aDados[nI,6]+": "+cLog) 
            EndIf

            oModel:DeActivate()
        Next    
    EndIf     

	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

Return({nTotal,aRet})

/*/{Protheus.doc} fRetDados
Função para retornar os dados dos ativos garantidores imoveis cadastrados na SN1
@type static function
@author DXM Team
@since 15/10/2024
@version 1.0
/*/
Static Function fRetDados()
Local cAliasTrb := GetNextAlias()
Local cAlias    := "B8C"    // Ativos Garantidores Imobiliarios
Local cQuery    := ""
Local aContas   := {}
Local cFiltro   := ""
Local aRetAux   := {}
Local aRet      := {}
Local cCContabil
Local cCCusto
Local nI

    // Inicializa os parametros para retorno dos dados com a tabela B3D ja posicionada na chamada da rotina PLSEXTDIOPS 
    cTrimestre  := Substr(B3D->B3D_REFERE,1,1)
    cAno        := B3D->B3D_ANO
    dDataIni    := Ctod("01/"+IIf(cTrimestre=="1","01",IIf(cTrimestre=="2","04",IIf(cTrimestre=="3","07","10")))+"/"+cAno)
    dDataFim    := LastDay(Ctod("28/"+IIf(cTrimestre=="1","03",IIf(cTrimestre=="2","06",IIf(cTrimestre=="3","09","12")))+"/"+cAno))

    // Monta Query de consulta dos Ativos Imobilizados ATF
    cQuery := "SELECT N1_CODRGI, N1_REDE, N3_VORIG1, N3_VRDACM1 "
    cQuery += " FROM "+RetSqlName("SN3")+" SN3 "
    cQuery += " INNER JOIN "+RetSqlName("SN1")+" SN1 ON (N1_FILIAL=N3_FILIAL AND N1_CBASE=N3_CBASE AND N1_ITEM=N3_ITEM AND SN1.D_E_L_E_T_='') "
    cQuery += " WHERE N3_FILIAL = "+ValToSQL(xFilial("SN3"))
    cQuery += " AND N1_AQUISIC <= "+ValToSQL(Dtos(dDataFim))   // Data de aquisição anterior ao fim do periodo    
    cQuery += " AND N3_TPSALDO = '1' "    // Somente tipo de saldo real
    cQuery += " AND (N3_DTBAIXA = '' OR N3_DTBAIXA > "+ValToSQL(Dtos(dDataFim))+") "  // Somente não baixados ou baixados apos o fim do periodo 
    cQuery += " AND SN3.D_E_L_E_T_ <> '*' "

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Retorno da função: RetParDIOPS                     ³
    //³ [1] Codigo do Item 	                               ³
    //³ [2] Conta Contabil      		                   ³
    //³ [3] Centro de Custo     	                       ³
    //³ [4] Descricao do Identificador                 	   ³        
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
    aContas := RetParDIOPS(cAlias)

    // Montagem do filtro de contas contabeis na tabela de valores SN3
    If Len(aContas)>0
        cFiltro := ""
        For nI := 1 to Len(aContas)
            cCContabil := Alltrim(aContas[nI,2])  // Conta Contabil 
            cCCusto    := Alltrim(aContas[nI,3])  // Centro de Custo 

            If !Empty(cCCusto)
                cFiltro += " (N3_CCONTAB LIKE "+ValToSQL(cCContabil+"%")+" AND N3_CUSTBEM LIKE "+ValToSQL(cCCusto+"%")+") OR"
            Else
                cFiltro += " (N3_CCONTAB LIKE "+ValToSQL(cCContabil+"%")+") OR"
            EndIf 
        Next 

        If !Empty(cFiltro)
            cQuery += " AND ("+Substr(cFiltro,1,Len(cFiltro)-2)+") "
        Endif
    EndIf 

    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.F.,.T.)	
    (cAliasTrb)->(dbGotop())

    // Adiciona registros 
    While (cAliasTrb)->(!Eof())
        aAdd(aRet,{;
            B3D->B3D_CODOPE,;               // 01 codigo operadora
            B3D->B3D_CDOBRI,;               // 02 codigo na central de obrigacao 
            B3D->B3D_ANO,;                  // 03 ano do compromisso
            StrZero(Val(cTrimestre),2),;    // 04 periodo do compromisso
            B3D->B3D_CODIGO,;               // 05 codigo do compromisso 
            (cAliasTrb)->N1_CODRGI,;        // 06 codigo da obrigacao 
            (cAliasTrb)->N1_REDE,;          // 07 rede propria sim/nao 
            "0",;                           // 08 assistencial 
            (cAliasTrb)->N3_VORIG1,;        // 09 valor original do bem
            (cAliasTrb)->N3_VRDACM1;        // 10 valor deprec acummulada
        })

        // Ajusta campo Rede Propria (1=Sim;0=Nao)
        aRet[Len(aRet),7] := Iif(aRet[Len(aRet),7]=="S","1","0")

        // Com este Ponto de Entrada, o cliente pode informar quais são seus Ativos (N1_CODRGI) que são Assistenciais. 
        If ExistBlock( "PLATVASS" )
            aRetAux := aClone(aRet[Len(aRet)])
            aRetAux := ExecBlock( "PLATVASS", .F., .F., {aRetAux} )

            If !Empty(aRetAux)
                aRet[Len(aRet),8] := aRetAux[8]
            EndIf 
        EndIf        

        (cAliasTrb)->(dbSkip())
    EndDo

    (cAliasTrb)->(dbCloseArea())

    // Atualiza log
	MemoWrite(DIR_LOG_DIOPS+"Extrator_Diops_PLSEXTAGI.log",cQuery)        

Return(aRet)
