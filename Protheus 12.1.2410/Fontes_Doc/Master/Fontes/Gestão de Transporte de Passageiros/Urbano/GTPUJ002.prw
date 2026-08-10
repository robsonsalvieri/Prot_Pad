#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "GTPUJ002.CH"

/*/{Protheus.doc} GTPUJ002
Função responsável pela criação do job para lançar as folgas automáticas dos colaboradores até o final do ano
@type function
@author Karyna Martins
@since 02/07/2025
@version 1.0
@param aParam, array, Parâmetros de empresa e filial (quando executado via job)
/*/
Function GTPUJ002(aParam)
    local lJob		 := Iif(Select("SX6")==0,.T.,.F.)  //Rotina automatica (schedule)
    Local nPosEmp    := 0
    Local nPosFil    := 0

    Default aParam    := {}
    //---Inicio Ambiente

    If lJob // Schedule
        
        nPosEmp := IF(Len(aParam) == 5, 2, 1)

        nPosFil := IF(Len(aParam) == 5, 3, 2)

        RPCSetType(3)
        
        PREPARE ENVIRONMENT EMPRESA aParam[nPosEmp] FILIAL aParam[nPosFil] MODULO "SIGAGTP"
    EndIf   

    // Sempre processa folgas automáticas até o final do ano
    If !lJob
        FWMsgRun(, {|| LancaExcecoes(lJob) },STR0001, STR0002) //"Aguarde" "Processando registros..."
	
        FwAlertInfo(STR0003,STR0004) //"Processamento Concluído!" "Finalizado"
        
    Else            

        LancaExcecoes(lJob)  

    Endif

    If lJob
        RpcClearEnv()
    EndIf 

Return


/*/{Protheus.doc} LancaExcecoes
Função responsável por lançar folgas automáticas para colaboradores até o final do ano
@type function
@author Karyna Martins
@since 02/07/2025
@version 1.0
@param lJob, logical, Indica se está sendo executado via job
/*/
Static Function LancaExcecoes(lJob)
    Local cErro       := ""

    // Processa folgas automáticas baseadas nas tabelas H82 e H83 até o final do ano
    ProcFolgas(lJob, @cErro)

    If !lJob .AND. !Empty(cErro)
        FWAlertError(STR0009) //"Ocorreram falhas durante o lançamento de exceções, verifique o Log"
    Endif
    
Return


/*/{Protheus.doc} ProcFolgas
Função responsável por processar folgas automáticas baseadas nas tabelas H82 e H83
@type function
@author Karyna Martins
@since 02/07/2025
@version 1.0
@param lJob, logical, Indica se está sendo executado via job
@param cErro, character, String com erros encontrados
/*/
Static Function ProcFolgas(lJob, cErro)
    Local oModel      := FwLoadModel("GTPU011A")
    Local oModelH7R   := oModel:GetModel('H7RMASTER')
    Local cAliasH82   := GetNextAlias()
    Local cAliasH83   := GetNextAlias()
    Local dDataBase   := dDataBase
    Local dDataInicio := dDataBase
    Local dDataFim    := GetDataFimAno(dDataBase) // Processa até o final do ano
    Local dDataAux    := dDataBase
    Local nDiaSemana  := 0
    Local lFolga      := .F.
    Local cErroLocal  := ""

    H7R->(DBSetOrder(1)) // H7R_FILIAL+H7R_COLAB+DTOS(H7R_DATA)
    
    // Busca grupos de colaboradores com folgas automáticas (H82_TPFOLG = '1' ou '2')
    BeginSql Alias cAliasH82
        SELECT DISTINCT
            H82.H82_CODIGO AS CODGRUPO,
            H82.H82_TPFOLG AS TPFOLGA,
            H82.H82_SEGUND AS SEGUNDA,
            H82.H82_TERCA  AS TERCA,
            H82.H82_QUARTA AS QUARTA,
            H82.H82_QUINTA AS QUINTA,
            H82.H82_SEXTA  AS SEXTA,
            H82.H82_SABADO AS SABADO,
            H82.H82_DOMING AS DOMINGO
        FROM %Table:H82% H82
        WHERE H82.H82_FILIAL = %xFilial:H82%
            AND H82.%NotDel%
    EndSql

    While (cAliasH82)->(!Eof())
        
        // Busca colaboradores do grupo
        BeginSql Alias cAliasH83
            SELECT DISTINCT
                H83.H83_CODGYG AS COLABORADOR,
                H83.H83_DTINIC AS DATAINICIO
            FROM %Table:H83% H83
            WHERE H83.H83_FILIAL = %xFilial:H83%
                AND H83.H83_CODH82 = %Exp:(cAliasH82)->CODGRUPO%
                AND H83.%NotDel%
        EndSql

        While (cAliasH83)->(!Eof())
            
            // Define data de início baseada no campo H83_DTINIC
            dDataInicio := Iif(!Empty((cAliasH83)->DATAINICIO), STOD((cAliasH83)->DATAINICIO), dDataBase)
            
            // Define o período de processamento sempre até o final do ano atual
            dDataFim := GetDataFimAno(dDataBase)
            
            // Processa cada dia no período (sempre começa da data atual)
            dDataAux := dDataBase
            While dDataAux <= dDataFim
                
                // Só processa datas futuras ou iguais à data atual E maiores ou iguais à data de início de vigência
                If dDataAux < dDataBase .OR. dDataAux < dDataInicio
                    dDataAux := DaySum(dDataAux, 1)
                    Loop
                EndIf
                
                // Verifica se é dia de folga para este colaborador
                nDiaSemana := Dow(dDataAux)
                lFolga := .F.
                
                // Verifica se o dia da semana está marcado para folga
                If (cAliasH82)->DOMINGO == 'T' .OR. (cAliasH82)->SEGUNDA == 'T' .OR. (cAliasH82)->TERCA == 'T' .OR. ;
                   (cAliasH82)->QUARTA == 'T' .OR. (cAliasH82)->QUINTA == 'T' .OR. (cAliasH82)->SEXTA == 'T' .OR. ;
                   (cAliasH82)->SABADO == 'T'
                    
                    // Verifica se é dia de folga específico
                    Do Case
                        Case nDiaSemana == 1 .AND. (cAliasH82)->DOMINGO == 'T'  // Domingo
                            lFolga := .T.
                        Case nDiaSemana == 2 .AND. (cAliasH82)->SEGUNDA == 'T'  // Segunda
                            lFolga := .T.
                        Case nDiaSemana == 3 .AND. (cAliasH82)->TERCA == 'T'    // Terça
                            lFolga := .T.
                        Case nDiaSemana == 4 .AND. (cAliasH82)->QUARTA == 'T'  // Quarta
                            lFolga := .T.
                        Case nDiaSemana == 5 .AND. (cAliasH82)->QUINTA == 'T'  // Quinta
                            lFolga := .T.
                        Case nDiaSemana == 6 .AND. (cAliasH82)->SEXTA == 'T'   // Sexta
                            lFolga := .T.
                        Case nDiaSemana == 7 .AND. (cAliasH82)->SABADO == 'T'  // Sábado
                            lFolga := .T.
                    EndCase
                    
                    // Se for dia de folga, verifica a regra de alternância para H82_TPFOLG = '2'
                    If lFolga .AND. (cAliasH82)->TPFOLGA == '2'
                        // Calcula se é semana de folga ou não (uma semana sim, outra não)
                        lFolga := SemanaFolga(dDataAux, dDataInicio)
                    EndIf
                    
                EndIf
                
                // Se for dia de folga, verifica se já não existe registro na H7R
                If lFolga

                    If !H7R->(DBSeek(xFilial("H7R") + (cAliasH83)->COLABORADOR + DTOS(dDataAux)))                       
                            
                        oModel:SetOperation(MODEL_OPERATION_INSERT)
                        oModel:Activate()

                        If oModel:IsActive()
                            oModelH7R:SetValue("H7R_COLAB", (cAliasH83)->COLABORADOR)
                            oModelH7R:SetValue("H7R_DATA", dDataAux)
                            oModelH7R:SetValue("H7R_TIPO", "4")

                            If oModel:VldData()         
                                oModel:CommitData() 
                            Else                  
                                cErroLocal += "Falha ao criar folga automática para colaborador: " + (cAliasH83)->COLABORADOR + " na data " + DTOC(dDataAux) + "|"
                                GrvLog(oModel, "Criação de Folga Automática", cErroLocal)
                            Endif     

                            oModel:DeActivate()
                        
                        EndIf                       
                    EndIf
                EndIf
                
                dDataAux := DaySum(dDataAux, 1)
            EndDo
            
            (cAliasH83)->(DBSkip())
        EndDo
        
        (cAliasH83)->(DBCloseArea())
        (cAliasH82)->(DBSkip())
    EndDo
    
    (cAliasH82)->(DBCloseArea())
    
    // Concatena erros locais com erros globais
    If !Empty(cErroLocal)
        cErro += cErroLocal
    EndIf
    
    GTPDestroy(oModel)
    
Return

/*/{Protheus.doc} SemanaFolga
Função responsável por determinar se é uma semana de folga para H82_TPFOLG = '2'
@type function
@author Karyna Martins
@since 02/07/2025
@version 1.0
@param dData, date, Data para verificar se é semana de folga
@param dDataInicio, date, Data de início de vigência para calcular a referência
@return logical, .T. se é semana de folga, .F. se não é
/*/
Static Function SemanaFolga(dData, dDataInicio)
    Local lSemanaFolga := .F.
    Local dDataRef      := dDataInicio
    Local nSemanas      := 0
    
    // Calcula quantas semanas se passaram desde a data de referência
    nSemanas := Int((dData - dDataRef) / 7)
    
    // Se o número de semanas for par (0, 2, 4, 6...), é semana de folga
    // Se for ímpar (1, 3, 5, 7...), não é semana de folga
    lSemanaFolga := (nSemanas % 2) == 0
    
Return lSemanaFolga

/*/{Protheus.doc} GetDataFimAno
Função responsável por calcular a data do final do ano
@type function
@author Karyna Martins
@since 02/07/2025
@version 1.0
@param dData, date, Data de referência para calcular o final do ano
@return date, Data do final do ano (31/12/YYYY)
/*/
Static Function GetDataFimAno(dData)
    Local dDataFim := dData
    Local nAno     := Year(dData)
    
    // Define a data como 31 de dezembro do ano informado
    dDataFim := CToD("31/12/" + Str(nAno))
    
Return dDataFim

/*/{Protheus.doc} GrvLog
    Grava log
    @type  Static Function
    @author João Pires
    @since 14/05/2025
    @version 1.0
    @param oModel, Objejct, Modelo de dados    
/*/
Static Function GrvLog(oModel,cErroCompl,cProcesso)
    Local aErro := {}
    Local cErro := ""

    aErro := oModel:GetErrorMessage()

    cErro := cErroCompl + CRLF +;
            aErro[3] + CRLF +;
            aErro[4] + CRLF +;
            aErro[6] + CRLF +; 
            aErro[7]
                    
    GtpGrvLgRj(	"URBANO"+'|'+"ALOC. RECURSO",; //"URBANO|ALOC. RECURSO"
				"",;
				cProcesso,;
				"GTPUJ002",;
				"",;
				cErro)

Return .F.
