CREATE PROCEDURE TAF613R_##(
    @IN_FILIAL CHAR('F6_FILIAL'),
    @IN_KEYREG VARCHAR(255),
    @IN_NEWID VARCHAR(255),
    @OUT_RESULT VARCHAR(1) OUTPUT
) AS 

/*---------------------------------------------------------------------------------------------------------------------
    Versao      -  <v> Protheus P12 </v>
    Programa    -  <s> TAF613R </s>
    Descricao   -  <d> Integracao entre ERP Livros Fiscais X TAF (SPED) - Guias de Recolhimentos </d>
    Entrada     -  <ri> @IN_FILIAL - Filial a ser executada a procedure
                        @IN_KEYREG - Chave de negocio do registro a ser pocisionado
                        @IN_NEWID - Novo a ID a ser usado na inclusao do registro </ri>
    Saida       -  <ro> @OUT_RESULT - Indica o termino da execuùùo da procedure: 0 - Falha; 1 - Sucesso </ro>
    Responsavel :  <r> Melkz Siqueira </r>
    Data        :  <dt> 13/10/2023</dt>

--------------------------------------------------------------------------------------------------------------------- */
DECLARE @RESULT         CHAR(1)
DECLARE @C1V            CHAR(3)          
DECLARE @C3E            CHAR(3)
DECLARE @C6T            CHAR(3)
DECLARE @C6U            CHAR(3)
DECLARE @C6S            CHAR(3)
DECLARE @C1G            CHAR(3)
DECLARE @C09            CHAR(3)
DECLARE @C0R            CHAR(3)
DECLARE @C6R            CHAR(3)
DECLARE @C1H            CHAR(3)
DECLARE @SF6            CHAR(3)
DECLARE @ID_C0R         CHAR('C0R_ID')         
DECLARE @UF_C0R         CHAR('C0R_UF')       
DECLARE @CODREC_C0R     CHAR('C0R_CODREC')        
DECLARE @DETREC_C0R     CHAR('C0R_DETREC')
DECLARE @CODPRD_C0R     CHAR('C0R_CODPRD')  
DECLARE @TIPDOC_C0R     CHAR('C0R_TIPDOC')    
DECLARE @CODBAN_C0R     CHAR('C0R_CODBAN')     
DECLARE @CODOBR_C0R     CHAR('C0R_CODOBR')      
DECLARE @NRPROC_C0R     CHAR('C0R_NRPROC')            
DECLARE @CDPART_C0R     CHAR('C0R_CDPART')
DECLARE @CODAGE_C0R     VARCHAR('C0R_CODAGE')        
DECLARE @FILIAL_C1V     VARCHAR('C1V_FILIAL')
DECLARE @FILIAL_C3E     VARCHAR('C3E_FILIAL') 
DECLARE @FILIAL_C6T     VARCHAR('C6T_FILIAL') 
DECLARE @FILIAL_C6U     VARCHAR('C6U_FILIAL')  
DECLARE @FILIAL_C6S     VARCHAR('C6S_FILIAL') 
DECLARE @FILIAL_C1G     VARCHAR('C1G_FILIAL')  
DECLARE @FILIAL_C6R     VARCHAR('C6R_FILIAL')  
DECLARE @FILIAL_C09     VARCHAR('C09_FILIAL') 
DECLARE @FILIAL_C0R     VARCHAR('C0R_FILIAL')        
DECLARE @FILIAL_C1H     VARCHAR('C1H_FILIAL') 
DECLARE @FILIAL_SF6     VARCHAR('F6_FILIAL')
DECLARE @NUMDA_C0R      VARCHAR('C0R_NUMDA')               
DECLARE @DESDOC_C0R     VARCHAR('C0R_DESDOC')  
DECLARE @CODDA_C0R      VARCHAR('C0R_CODDA')    
DECLARE @CODAUT_C0R     VARCHAR('C0R_CODAUT')
DECLARE @DTVCT_C0R      VARCHAR('C0R_DTVCT')  
DECLARE @DTPGT_C0R      VARCHAR('C0R_DTPGT')        
DECLARE @DOCORI_C0R     VARCHAR('C0R_DOCORI')      
DECLARE @CONVEN_C0R     VARCHAR('C0R_CONVEN')
DECLARE @TPIMPO_C0R     VARCHAR('C0R_TPIMPO')          
DECLARE @PERIOD_C0R     VARCHAR('C0R_PERIOD')
DECLARE @VLRPRC_C0R     FLOAT
DECLARE @ATUMON_C0R     FLOAT
DECLARE @JUROS_C0R      FLOAT  
DECLARE @MULTA_C0R      FLOAT   
DECLARE @VLDA_C0R       FLOAT

BEGIN
    SELECT @OUT_RESULT  = '0'
    SELECT @RESULT      = '0'
    SELECT @C1V         = 'C1V'
    SELECT @C3E         = 'C3E'
    SELECT @C6T         = 'C6T'
    SELECT @C6U         = 'C6U'
    SELECT @C6S         = 'C6S'
    SELECT @C1G         = 'C1G'
    SELECT @C6R         = 'C6R'
    SELECT @C09         = 'C09'
    SELECT @C0R         = 'C0R' 
    SELECT @C1H         = 'C1H'
    SELECT @SF6         = 'SF6'

    EXEC XFILIAL_## @C1V, @IN_FILIAL, @FILIAL_C1V OUTPUT
    EXEC XFILIAL_## @C3E, @IN_FILIAL, @FILIAL_C3E OUTPUT
    EXEC XFILIAL_## @C6T, @IN_FILIAL, @FILIAL_C6T OUTPUT
    EXEC XFILIAL_## @C6U, @IN_FILIAL, @FILIAL_C6U OUTPUT
    EXEC XFILIAL_## @C6S, @IN_FILIAL, @FILIAL_C6S OUTPUT
    EXEC XFILIAL_## @C1G, @IN_FILIAL, @FILIAL_C1G OUTPUT
    EXEC XFILIAL_## @C6R, @IN_FILIAL, @FILIAL_C6R OUTPUT
    EXEC XFILIAL_## @C09, @IN_FILIAL, @FILIAL_C09 OUTPUT
    EXEC XFILIAL_## @C0R, @IN_FILIAL, @FILIAL_C0R OUTPUT
    EXEC XFILIAL_## @C1H, @IN_FILIAL, @FILIAL_C1H OUTPUT
    EXEC XFILIAL_## @SF6, @IN_FILIAL, @FILIAL_SF6 OUTPUT

    DECLARE GRECOREF_UPDATE INSENSITIVE CURSOR FOR
        SELECT 
            COALESCE(C0R.C0R_ID, ' ') ID_C0R,
            SF6.F6_NUMERO NUMDA_C0R,    
            COALESCE(C09.C09_ID, ' ') UF_C0R,  
            SF6.F6_TIPOIMP TPIMPO_C0R,      
            SF6.F6_VALOR VLRPRC_C0R,                   
            SF6.F6_DTVENC DTVCT_C0R, 
            SF6.F6_NUMCONV CONVEN_C0R,            
            COALESCE(C1V.C1V_ID, ' ') CODBAN_C0R,            
            SF6.F6_AGENCIA CODAGE_C0R,            
            COALESCE(C6R.C6R_ID, ' ') CODREC_C0R,              
            COALESCE(C1H.C1H_ID, ' ') CDPART_C0R,              
            COALESCE(C6T.C6T_ID, ' ') TIPDOC_C0R,        
            SF6.F6_DTPAGTO DTPGT_C0R,
            SF6.F6_DOCOR DOCORI_C0R,
            SF6.F6_ATMON ATUMON_C0R,    
            SF6.F6_JUROS JUROS_C0R,     
            SF6.F6_MULTA MULTA_C0R,     
            COALESCE(C6U.C6U_ID, ' ') CODPRD_C0R,    
            SF6.F6_AUTENT CODAUT_C0R,  
            COALESCE(C1G.C1G_ID, ' ') NRPROC_C0R,
            COALESCE(C6S.C6S_ID, ' ') DETREC_C0R,      
            COALESCE(C3E.C3E_ID, ' ') CODOBR_C0R,
            SF6.F6_VALOR + SF6.F6_ATMON + SF6.F6_JUROS + SF6.F6_MULTA VLDA_C0R, /* O operador "+" estù sendo usado aqui para somar os valores dos campos, nùo para concatenar-los */

            ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                SF6.F6_EST + ' / ' + SF6.F6_NUMERO DESDOC_C0R,
            ##ENDIF_001

            ##IF_002({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                SF6.F6_EST || ' / ' || SF6.F6_NUMERO DESDOC_C0R,
            ##ENDIF_002

            ##IF_003({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                SF6.F6_MESREF + CONVERT(VARCHAR('F6_ANOREF'), SF6.F6_ANOREF) PERIOD_C0R
            ##ENDIF_003

            ##IF_004({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                SF6.F6_MESREF || TO_CHAR(SF6.F6_ANOREF, '9999') PERIOD_C0R
            ##ENDIF_004

            FROM SF6### SF6
            LEFT JOIN C1V### C1V
                ON C1V.D_E_L_E_T_ = ' ' 
                    AND C1V.C1V_FILIAL = @FILIAL_C1V
                    AND C1V.C1V_CODIGO = SF6.F6_BANCO
            LEFT JOIN C3E### C3E
                ON C3E.D_E_L_E_T_ = ' ' 
                    AND C3E.C3E_FILIAL = @FILIAL_C3E
                    AND C3E.C3E_CODIGO = SF6.F6_COBREC
            LEFT JOIN C6T### C6T
                ON C6T.D_E_L_E_T_ = ' ' 
                    AND C6T.C6T_FILIAL = @FILIAL_C6T
                    AND C6T.C6T_CODIGO = SF6.F6_TIPODOC
            LEFT JOIN C6U### C6U
                ON C6U.D_E_L_E_T_ = ' ' 
                    AND C6U.C6U_FILIAL = @FILIAL_C6U

            ##IF_005({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                AND C6U.C6U_CODIGO = CONVERT(VARCHAR('F6_CODPROD'), SF6.F6_CODPROD)
            ##ENDIF_005

            ##IF_006({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                AND C6U.C6U_CODIGO = TO_CHAR(SF6.F6_CODPROD, '999')
            ##ENDIF_006

            LEFT JOIN C6S### C6S
                ON C6S.D_E_L_E_T_ = ' ' 
                    AND C6S.C6S_FILIAL = @FILIAL_C6S
                    AND C6S.C6S_CODIGO = SF6.F6_DETRECE
            LEFT JOIN C1G### C1G
                ON C1G.D_E_L_E_T_ = ' ' 
                    AND C1G.C1G_FILIAL = @FILIAL_C1G
                    AND C1G.C1G_NUMPRO = SF6.F6_NUMPROC
                    AND C1G.C1G_INDPRO = SF6.F6_INDPROC
            LEFT JOIN C6R### C6R
                ON C6R.D_E_L_E_T_ = ' ' 
                    AND C6R.C6R_FILIAL = @FILIAL_C6R
                    AND C6R.C6R_CODIGO = SF6.F6_CODREC
            LEFT JOIN C09### C09
                ON C09.D_E_L_E_T_ = ' ' 
                    AND C09.C09_FILIAL = @FILIAL_C09
                    AND C09.C09_UF = SF6.F6_EST
            LEFT JOIN C0R### C0R
                ON C0R.D_E_L_E_T_ = ' ' 
                    AND C0R.C0R_FILIAL = @FILIAL_C0R
                    AND C0R.C0R_NUMDA = SF6.F6_NUMERO
            LEFT JOIN C1H### C1H
                ON C1H.D_E_L_E_T_ = ' ' 
                    AND C1H.C1H_FILIAL = @FILIAL_C1H

            ##IF_007({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                AND C1H.C1H_CODPAR = SF6.F6_CLIFOR + SF6.F6_LOJA
            ##ENDIF_007

            ##IF_008({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                AND C1H.C1H_CODPAR = SF6.F6_CLIFOR || SF6.F6_LOJA
            ##ENDIF_008

            WHERE SF6.D_E_L_E_T_ = ' '
                AND SF6.F6_FILIAL = @FILIAL_SF6  
                AND SF6.R_E_C_N_O_ = convert(integer, @IN_KEYREG)
                
    FOR READ ONLY
    OPEN GRECOREF_UPDATE

    FETCH GRECOREF_UPDATE
        INTO
            @ID_C0R,
            @NUMDA_C0R,             
            @UF_C0R,               
            @TPIMPO_C0R,
            @VLRPRC_C0R, 
            @DTVCT_C0R,      
            @CONVEN_C0R,    
            @CODBAN_C0R,         
            @CODAGE_C0R,            
            @CODREC_C0R,            
            @CDPART_C0R,     
            @TIPDOC_C0R,        
            @DTPGT_C0R,            
            @DOCORI_C0R,          
            @ATUMON_C0R,     
            @JUROS_C0R,      
            @MULTA_C0R,       
            @CODPRD_C0R,      
            @CODAUT_C0R,    
            @NRPROC_C0R,     
            @DETREC_C0R,    
            @CODOBR_C0R,
            @VLDA_C0R,
            @DESDOC_C0R,
            @PERIOD_C0R

    BEGIN TRANSACTION

    IF @@FETCH_STATUS = 0 
        BEGIN
            IF @TPIMPO_C0R = '0'
                BEGIN
                    SELECT @CODDA_C0R = '0'
                END
            ELSE
                BEGIN
                    SELECT @CODDA_C0R = '1'
                END

            If @CODOBR_C0R = ' '
                BEGIN
                    SELECT @CODOBR_C0R = '000'
                END

            IF LEN(LTRIM(RTRIM(@PERIOD_C0R))) = 5
                BEGIN
                    ##IF_009({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                        SELECT @PERIOD_C0R = '0' + @PERIOD_C0R
                    ##ENDIF_009

                    ##IF_010({|| AllTrim(Upper(TcGetDB())) $ "ORACLE/POSTGRES"})
                        SELECT @PERIOD_C0R = '0' || @PERIOD_C0R
                    ##ENDIF_010
                END

            IF @ID_C0R = ' '
                BEGIN
                    INSERT INTO C0R### (
                        C0R_FILIAL,
                        C0R_ID,
                        C0R_NUMDA,             
                        C0R_UF,               
                        C0R_TPIMPO,
                        C0R_VLRPRC, 
                        C0R_DTVCT,      
                        C0R_CONVEN,    
                        C0R_CODBAN,         
                        C0R_CODAGE,            
                        C0R_CODREC,            
                        C0R_CDPART,     
                        C0R_TIPDOC,        
                        C0R_DTPGT,            
                        C0R_DOCORI,          
                        C0R_ATUMON,     
                        C0R_JUROS,      
                        C0R_MULTA,       
                        C0R_CODPRD,      
                        C0R_CODAUT,    
                        C0R_NRPROC,     
                        C0R_DETREC,    
                        C0R_CODOBR,
                        C0R_VLDA,
                        C0R_DESDOC,
                        C0R_PERIOD,
                        C0R_CODDA
                    ) VALUES (
                        @FILIAL_C0R,   
                        @IN_NEWID,
                        @NUMDA_C0R,             
                        @UF_C0R,               
                        @TPIMPO_C0R,
                        @VLRPRC_C0R, 
                        @DTVCT_C0R,      
                        @CONVEN_C0R,    
                        @CODBAN_C0R,         
                        @CODAGE_C0R,            
                        @CODREC_C0R,            
                        @CDPART_C0R,     
                        @TIPDOC_C0R,        
                        @DTPGT_C0R,            
                        @DOCORI_C0R,          
                        @ATUMON_C0R,     
                        @JUROS_C0R,      
                        @MULTA_C0R,       
                        @CODPRD_C0R,      
                        @CODAUT_C0R,    
                        @NRPROC_C0R,     
                        @DETREC_C0R,    
                        @CODOBR_C0R,
                        @VLDA_C0R,
                        @DESDOC_C0R,
                        @PERIOD_C0R,
                        @CODDA_C0R
                    )
                END
            ELSE
                BEGIN
                    UPDATE C0R###
                        SET 
                            C0R_NUMDA = @NUMDA_C0R,             
                            C0R_UF = @UF_C0R,               
                            C0R_TPIMPO = @TPIMPO_C0R,
                            C0R_VLRPRC = @VLRPRC_C0R, 
                            C0R_DTVCT = @DTVCT_C0R,      
                            C0R_CONVEN = @CONVEN_C0R,    
                            C0R_CODBAN = @CODBAN_C0R,         
                            C0R_CODAGE = @CODAGE_C0R,            
                            C0R_CODREC = @CODREC_C0R,            
                            C0R_CDPART = @CDPART_C0R,     
                            C0R_TIPDOC = @TIPDOC_C0R,        
                            C0R_DTPGT = @DTPGT_C0R,            
                            C0R_DOCORI = @DOCORI_C0R,          
                            C0R_ATUMON = @ATUMON_C0R,     
                            C0R_JUROS = @JUROS_C0R,      
                            C0R_MULTA = @MULTA_C0R,       
                            C0R_CODPRD = @CODPRD_C0R,      
                            C0R_CODAUT = @CODAUT_C0R,    
                            C0R_NRPROC = @NRPROC_C0R,     
                            C0R_DETREC = @DETREC_C0R,    
                            C0R_CODOBR = @CODOBR_C0R,
                            C0R_VLDA = @VLDA_C0R,
                            C0R_DESDOC = @DESDOC_C0R,
                            C0R_PERIOD = @PERIOD_C0R,
                            C0R_CODDA = @CODDA_C0R
                        WHERE D_E_L_E_T_ = ' ' 
                            AND C0R_FILIAL = @FILIAL_C0R
                            AND C0R_ID = @ID_C0R
                END

            SELECT @RESULT = '1'
        END

    COMMIT TRANSACTION

    CLOSE GRECOREF_UPDATE
    DEALLOCATE GRECOREF_UPDATE

    SELECT @OUT_RESULT = @RESULT
END