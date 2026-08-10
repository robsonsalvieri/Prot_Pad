-- Procedure creation 
CREATE PROCEDURE PCOXINC3_## (
    @IN_FILIAL Char( 'AKG_FILIAL' ) , 
    @IN_CTAB Char( 'ABS_CEP' ) , 
    @OUT_RESULT Char( 'AK0_STATUS' )  output ) AS
 
-- Declaration of variables
DECLARE @cCodigo Char( 'AK5_CODIGO' )
DECLARE @cCodAux Char( 'AK5_CODIGO' )
DECLARE @cSup Char( 'AK5_CODIGO' )
DECLARE @cSupAux Char( 'AK5_CODIGO' )
DECLARE @iRecno Integer
DECLARE @iRecnoAux Integer
DECLARE @cExecSql  nvarchar(250)
BEGIN
   SELECT @OUT_RESULT  = '0' 
   SELECT @cCodigo  = '' 
   SELECT @cSup  = '' 
   SELECT @cCodAux  = '' 
   SELECT @cSupAux  = '' 
   SELECT @iRecno  = 0 
    
   -- Cursor declaration AK5Sup
   DECLARE AK5Sup  CURSOR FOR 
   SELECT AK5_CODIGO , AK5_COSUP 
     FROM AK5###
     WHERE AK5_FILIAL  = @IN_FILIAL  and AK5_TIPO  = '2'  and D_E_L_E_T_  = ' ' 
     GROUP BY AK5_CODIGO , AK5_COSUP 
   FOR READ ONLY 
    
   OPEN AK5Sup
   FETCH AK5Sup 
    INTO @cCodigo , @cSup 
   WHILE (@@fetch_status  = 0 )
   BEGIN
      SELECT @cExecSql = " SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
      ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         exec sp_executesql @cExecSql      
      ##ENDIF_001
      ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
         SELECT @cExecSql = 'IMMEDIATE'
      ##ENDIF_002
      ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
         EXECUTE @cExecSql
      ##ENDIF_003
      SELECT @iRecno  = @iRecno  + 1 
      IF @cSup  != ' ' 
      BEGIN 
      ##TRATARECNO @iRecno\
         ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "'," ||  CAST( @iRecno AS VARCHAR) || " ) "
            exec sp_executesql @cExecSql
         ##ENDIF_001
         ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " || to_char( @iRecno ) || " ) "
            SELECT @cExecSql = 'IMMEDIATE'
         ##ENDIF_002
         ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "'," ||   CAST( @iRecno AS VARCHAR(16)) || " ) "
            EXECUTE @cExecSql
         ##ENDIF_003
      ##FIMTRATARECNO 
      END 
      SELECT @cCodAux  = @cSup 
      SELECT @cSupAux  = @cSup 
      WHILE (@cCodAux  != ' ' )
      BEGIN
         SELECT @iRecnoAux  = null 
         SELECT @iRecnoAux  = R_E_C_N_O_ 
           FROM AK5###
           WHERE AK5_FILIAL  = @IN_FILIAL  and AK5_CODIGO  = @cSupAux  and D_E_L_E_T_  = ' ' 
         IF @iRecnoAux is NOT null 
         BEGIN 
            SELECT @cCodAux  = AK5_COSUP 
              FROM AK5###
              WHERE AK5_FILIAL  = @IN_FILIAL  and AK5_CODIGO  = @cSupAux  and D_E_L_E_T_  = ' ' 
            IF @cCodAux  != ' ' 
            BEGIN 
               SELECT @cExecSql = " SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
               ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                  exec sp_executesql @cExecSql      
               ##ENDIF_001
               ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                  SELECT @cExecSql = 'IMMEDIATE'
               ##ENDIF_002
               ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                  EXECUTE @cExecSql
               ##ENDIF_003
               SELECT @iRecno  = @iRecno  + 1 
               BEGIN 
               ##TRATARECNO @iRecno\
                  ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "'," ||  CAST( @iRecno AS VARCHAR) || " ) "
                     exec sp_executesql @cExecSql
                  ##ENDIF_001
                  ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " || to_char( @iRecno ) || " ) "
                     SELECT @cExecSql = 'IMMEDIATE'
                  ##ENDIF_002
                  ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "',  " ||   CAST( @iRecno AS VARCHAR(16)) || " ) "
                     EXECUTE @cExecSql
                  ##ENDIF_003
               ##FIMTRATARECNO 
               END 
            END 
            SELECT @cSupAux  = @cCodAux 
         END 
         ELSE 
         BEGIN 
            SELECT @cCodAux  = ' ' 
         END 
      END 
      FETCH AK5Sup 
       INTO @cCodigo , @cSup 
   END 
   CLOSE AK5Sup
   DEALLOCATE AK5Sup
   SELECT @OUT_RESULT  = '1' 
END 