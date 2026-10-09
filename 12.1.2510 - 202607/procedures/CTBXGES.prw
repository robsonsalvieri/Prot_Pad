#Include "PROTHEUS.CH"
#Include "PRTOPDEF.CH"
#Include "TOPCONN.CH"
#Include "CTBXGES.CH"

/*/{Protheus.doc} CTBXGES
    Rotina de JOB no schedule para chamada das procedures
    @type  Function
    @author Thiago Alves Bussolin
    @since 15/10/2025
    @version 1.0    
/*/
Static __cLockNm := "CTBXGES"

Function CTBXGES()

    Local aResult   := {} as Array
    Local cContaDe  := '' as Character
    Local cContaAte := '' as Character

    //trava para nenhuma execucao simultanea na mesma empresa
    If LockByName(__cLockNm + "_" + cEmpAnt, .T./*lEmpresa*/, .F./*lFilial*/ )

        If !CTBInstPRC('37')        
            FwLogMsg("ERROR",, "CTBXGES", "CTBXGES", "", "Procedure", "Stored Procedure CTBCT2GES"+ cEmpAnt+" not installed, please check." + ' ' + cEmpAnt ) //Procedures nao instaladas, favor verificar.)
            UnLockByName(__cLockNm + "_" + cEmpAnt, .T./*lEmpresa*/, .F./*lFilial*/ )
            Return
        Else
            cContaDe:= MV_PAR01
            cContaAte:= MV_PAR02

            aResult := TCSPExec( xProcedures("CTBCT2GES_37"), ; // nome da procedure
                            cContaDe ,;
                            cContaAte)
            If Empty(aResult) .Or. aResult[1] = "0"
                FwLogMsg("ERROR",, "CTBXGES", "CTBXGES", "", "Procedure", " Error in Stored Procedure exec CTBCT2GES"+ cEmpAnt+": "+tcsqlerror()) 
            EndIf
            
            //libera trava para nova execucao
            UnLockByName(__cLockNm + "_" + cEmpAnt, .T./*lEmpresa*/, .F./*lFilial*/ )
        EndIf
    EndIf
Return


/*/{Protheus.doc}  VerIDProc
	Identifica a sequencia de controle do fonte ADVPL com a	stored procedure, qualquer
	alteracao que envolva diretamente a stored procedure a variavel sera incrementada.
	Processo ?? - Integração Protheus x Gesplan
	@type  StaticFunction
	@author TOTVS
	@since 14/02/2025
    @return character, Retorna a assinatura da rotina
/*/      
Static Function VerIDProc()
Return '001'


/*/{Protheus.doc} SchedDef
	Função que permite ao frame fazer a preparação do
    ambiente de execução do schedule.
	  
    @author Thiago Alves Bussolin
    @since 15/10/2025
    @return aParam, vetor de 5 posições.
/*/
Static Function SchedDef()
	
    Local aParam As Array

	aParam := {"P", "CT2GES", Nil, Nil, Nil, Nil, .T., .T.}

Return aParam

/*/{Protheus.doc} EngSPS37Signature
    Processo 37 - Integracaoo Protheus x Gesplan
    Funcoes executadas durante a exibicapo de informacoes detalhadas 
    do processo na interface de gestao de procedures.
    Faz a execucao de funcoes STATIC proprietarias das rotinas donas 
    dos processos.
    @type  Function
    @return character, Assinatura
    @author  TOTVS
    @since   14/02/2025
    @version 12
/*/
Function EngSPS37Signature(cProcess as character)

    Local cAssinatura as character

    cAssinatura := VerIDProc()

Return cAssinatura

Function EngPre37Compile(cProcesso as character, cEmpresa as character, cError as character)
    Local lRet   as Logical
    Local aArea  as Array    
    Local lRowStamp   as Logical
    Local lRowInsdt   as Logical

    aArea := GetArea()
    lRet := ChkFile( "QLX" ) .And. ChkFile( "QLZ" )
    lRowStamp := .F.
    lRowInsdt := .F.
    
    SX2->(dbSetOrder(1))
    If SX2->(dbSeek('CT2'))  // Verifica se os campos existem na SX2, se tiver em uma tabela tem em todas.
        lRowStamp  := SX2->( FieldPos("X2_STAMP") ) > 0
        lRowInsdt  := SX2->( FieldPos("X2_INSDT") ) > 0
    EndIf

    If !SX2->X2_STAMP == '1' .And. !SX2->X2_INSDT == '1' 
        lRet := .F.
    EndIf
    
    If lRet .And. lRowStamp .And. lRowInsdt            
        dbSelectArea('CT2')

        TCCONfig("SETUSEROWSTAMP=ON") 
        TCCONfig("SETAUTOSTAMP=ON") 
        TCCONfig("SETUSEROWINSDT=ON") // Liga o USEROWINSDT para a conexao atual
        TCCONfig("SETAUTOINSDT=ON") // Liga o AUTOINSDT para  conexao atual
        dbSelectArea('CT2')
        TCConfig("SETUSEROWSTAMP=OFF") // Desliga o UseRowStamp para a conexao atual
        TCConfig("SETAUTOSTAMP=OFF")   // Desliga o AutoStamp para  conexao atual

        TCConfig("SETUSEROWINSDT=OFF")   // Desliga o I_N_S_D_T_ para  conexao atual
        TCConfig("SETAUTOINSDT=OFF")   // Desliga o AutoStamp para  conexao atual

        CT2->(DBCloseArea())    
    Else
        cError := STR0002+CRLF+STR0003 //"Instalação indisponível no momento!"####"O processo 37, referente à integração entre SIGACTB e GESPLAN, ainda está em desenvolvimento."
    EndIf

    RestArea(aArea)
    FwFreeArray( aArea )

Return lRet

Function EngOn37Compile(cProcesso as character, cEmpresa as character, cProcName as character, cBuffer as character, cError as character)
    Local nTamEmp  := 0 As Numeric
    Local nTamUnit := 0 As Numeric 
    Local nTamFil  := 0 As Numeric
    Local nTamCto  := 0 As Numeric

    
    ChkFile('CT2')
    // Calcula os tamanhos das unidades de negócio para a tabela atual
    nTamEmp  := Len(FWCompany('CT2'))
    nTamUnit := Len(FWUnitBusiness('CT2'))
    nTamFil  := Len(FWFilial('CT2'))

    // Verifica os modos de acesso e soma os tamanhos
    If FWModeAccess('CT2', 1) == "E"
        nTamCto += nTamEmp
    EndIf
    If FWModeAccess('CT2', 2) == "E"
        nTamCto += nTamUnit
    EndIf
    If FWModeAccess('CT2', 3) == "E"
        nTamCto += nTamFil
    EndIf
    cBuffer := StrTran( cBuffer, "@IN_TAMCTO", cValTochar(nTamCto) )
    cBuffer := StrTran( cBuffer, "@IN_TAMTOTAL", cValTochar(nTamEmp + nTamUnit + nTamFil) )

Return .T.

Function EngPos37Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)

    cBuffer := StrTran( cBuffer, "121", '127' )

	Do Case
        Case  cLocalDB == "MSSQL"
            cBuffer := StrTran(cBuffer, "FROM CT2### CT2 left join CT2###  ON CT2_FILIAL  = ' ' inner join CTO### CTO ON" , " INTO #DADOSCT2  FROM CT2### CT2 WITH (READCOMMITTED)  INNER JOIN CTO### CTO ON",1,1)
            cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '" , " WITH (READCOMMITTED) ")
            cBuffer := StrTran(cBuffer, "and RTRIM ( LTRIM ( QLZ.QLZ_STAMP )) = CONVERT( Char( 26 ) ,CT2.S_T_A_M_P_ ,127 )" , "AND CONVERT( datetime ,QLZ.QLZ_STAMP ,127 ) = CT2.S_T_A_M_P_")
            cBuffer := StrTran(cBuffer, "CT2.CT2_DC  STG_S_T_A_M_P_ ," , " CASE "+CRLF+" WHEN CHARINDEX('.', RTRIM(LTRIM(CONVERT(CHAR(26), CT2.S_T_A_M_P_, 127)))) = 0" +CRLF+"THEN RTRIM(LTRIM(CONVERT(CHAR(26), CT2.S_T_A_M_P_, 127))) + '.000'"+CRLF+" ELSE ISNULL(RTRIM(LTRIM(CONVERT(CHAR(26), CT2.S_T_A_M_P_, 127))) ,@delTransactTime)"+CRLF+" END STG_S_T_A_M_P_ ,")
        Case cLocalDB == "ORACLE"
            cBuffer := StrTran(cBuffer, "BEGIN" , " ",2,1)
            cBuffer := StrTran( cBuffer, "INSERT INTO QLX", 'BEGIN '+CRLF+'INSERT ALL INTO QLX' )
            cBuffer := StrTran( cBuffer, "INSERT INTO QLZ", 'INTO QLZ' )
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM QLZ### QLZ" , " INTO vcStamp FROM QLZ### QLZ ")
            cBuffer := StrTran(cBuffer, "WHERE QLZ.QLZ_ALIAS  := 'QLX' );" , "WHERE QLZ.QLZ_ALIAS  = 'QLX' ;")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_37_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD HH24:MI:SS.FF3');", "TO_CHAR( SYSTIMESTAMP AT TIME ZONE 'UTC' - INTERVAL '1' HOUR,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3');")
            cBuffer := StrTran(cBuffer, "MSDATEADD_37_## ('YEAR', -2 , SYSDATE ),'YYYYMMDD'", "ADD_MONTHS(SYSDATE, -24), 'YYYYMMDD'")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vdelTransactTime ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "TO_TIMESTAMP(vcStamp ,'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3')")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "AND QLZ.QLZ_RECNO = 1000" , " ) ")
            cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
            cBuffer := StrTran(cBuffer, "'STG_DELET' );", "STG_DELET ) ")
            cBuffer := StrTran(cBuffer, "'STG_S_T_A_M_P_' );", "STG_S_T_A_M_P_ ) ")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'", "'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.FF3'")
                
        Case cLocalDB == "POSTGRES"
            cBuffer := StrTran(cBuffer, "BEGIN" , " ",2,1)
            cBuffer := StrTran( cBuffer, "vcStamp  := '1' ;", ' BEGIN CREATE TEMP TABLE DADOSCT2 ON COMMIT DROP AS ' )
            cBuffer := StrTran(cBuffer, "vcStamp  := (" , " ")
            cBuffer := StrTran(cBuffer, "FROM QLZ### QLZ" , " INTO vcStamp FROM QLZ### QLZ ")
            cBuffer := StrTran(cBuffer, "WHERE QLZ.QLZ_ALIAS  := 'QLX' )" , "WHERE QLZ.QLZ_ALIAS  = 'QLX' ")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_37_## ('YEAR', -2 , NOW() ),'YYYYMMDD')", "TO_CHAR(CURRENT_DATE - INTERVAL '2 years', 'YYYYMMDD')")
            cBuffer := StrTran(cBuffer, "TO_DATE(vdelTransactTime ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vdelTransactTime::timestamp")
            cBuffer := StrTran(cBuffer, "TO_DATE(vcStamp ,'YYYY-MM-DD HH24:MI:SS.FF3')", "vcStamp::timestamp")
            cBuffer := StrTran(cBuffer, "vmaxStagingCounter DATE", "vmaxStagingCounter TIMESTAMP")
            cBuffer := StrTran(cBuffer, "'YYYY-MM-DD HH24:MI:SS.FF3'","'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS'")
            cBuffer := StrTran(cBuffer, "TO_CHAR(MSDATEADD_37_## (HOUR , -1 , GETUTCDATE ),'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')", "TO_CHAR((CURRENT_TIMESTAMP AT TIME ZONE 'UTC' - interval '1 hour'), 'YYYY-MM-DD"+'"T"'+"HH24:MI:SS.MS')")
            cBuffer := StrTran(cBuffer, "left join CT2###  ON CT2_FILIAL  = ' '", " ")
            cBuffer := StrTran(cBuffer, "DADOSCT2", "DADOSCT2"+cEmpAnt)
    EndCase

Return  .T.
