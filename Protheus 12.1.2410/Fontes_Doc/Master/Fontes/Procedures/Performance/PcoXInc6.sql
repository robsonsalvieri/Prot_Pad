-- Procedure creation 
CREATE PROCEDURE PCOXINC6_## (
    @IN_FILIAL Char( 'AKG_FILIAL' ) , 
    @IN_CTAB Char( 'ABS_CEP' ) , 
    @OUT_RESULT Char( 'AK0_STATUS' )  output ) AS
 
-- Declaration of variables
DECLARE @cCodigo Char( 'CTH_CLVL' )
DECLARE @cCodAux Char( 'CTH_CLVL' )
DECLARE @cSup Char( 'CTH_CLVL' )
DECLARE @cSupAux Char( 'CTH_CLVL' )
DECLARE @iRecno Integer
DECLARE @iRecnoAux Integer
DECLARE @cExecSql  nvarchar(250)
BEGIN
   SELECT @cCodigo  = '' 
   SELECT @cSup  = '' 
   SELECT @cCodAux  = '' 
   SELECT @cSupAux  = '' 
   SELECT @iRecno  = 0 
    
   -- Cursor declaration CTHSup
   DECLARE CTHSup  CURSOR FOR 
   SELECT CTH_CLVL , CTH_CLSUP 
     FROM CTH### 
     WHERE CTH_FILIAL  = @IN_FILIAL  and CTH_CLASSE  = '2'  and D_E_L_E_T_  = ' ' 
     GROUP BY CTH_CLVL , CTH_CLSUP 
   FOR READ ONLY 
    
   OPEN CTHSup
   FETCH CTHSup 
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
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " ||  CAST( @iRecno AS VARCHAR) || " ) "
            exec sp_executesql @cExecSql
        ##ENDIF_001
        ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " || to_char( @iRecno ) || " ) "
            SELECT @cExecSql = 'IMMEDIATE'
        ##ENDIF_002
        ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " ||   CAST( @iRecno AS VARCHAR(16)) || " ) "
            EXECUTE @cExecSql
        ##ENDIF_003
      ##FIMTRATARECNO 
      END 
      SELECT @cCodAux  = @cSup 
      SELECT @cSupAux  = @cSup 
      WHILE (@cCodAux  != ' ' )
      BEGIN
         SELECT @iRecnoAux  = NULL 
         SELECT @iRecnoAux  = R_E_C_N_O_ 
           FROM CTH### 
           WHERE CTH_FILIAL  = @IN_FILIAL  and CTH_CLVL  = @cSupAux  and D_E_L_E_T_  = ' ' 
         IF @iRecnoAux is NOT null 
         BEGIN 
            SELECT @cCodAux  = CTH_CLSUP 
              FROM CTH### 
              WHERE CTH_FILIAL  = @IN_FILIAL  and CTH_CLVL  = @cSupAux  and D_E_L_E_T_  = ' ' 
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
               ##TRATARECNO @iRecno\
                  ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " ||  CAST( @iRecno AS VARCHAR) || " ) "
                     exec sp_executesql @cExecSql
                  ##ENDIF_001
                  ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " || to_char( @iRecno ) || " ) "
                     SELECT @cExecSql = 'IMMEDIATE'
                  ##ENDIF_002
                  ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES ('" || @cCodigo || "','" || @cSup || "', " ||   CAST( @iRecno AS VARCHAR(16)) || " ) "
                     EXECUTE @cExecSql
                  ##ENDIF_003
               ##FIMTRATARECNO 
            END 
            SELECT @cSupAux  = @cCodAux 
         END 
         ELSE 
         BEGIN 
            SELECT @cCodAux  = ' ' 
         END 
      END 
      FETCH CTHSup 
       INTO @cCodigo , @cSup 
   END 
   CLOSE CTHSup
   DEALLOCATE CTHSup
   SELECT @OUT_RESULT  = '1' 
END 