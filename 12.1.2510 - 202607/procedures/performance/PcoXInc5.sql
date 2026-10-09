-- Procedure creation 
CREATE PROCEDURE PCOXINC5_## (
    @IN_FILIAL Char( 'AKG_FILIAL' ) , 
    @IN_CTAB Char( 20 ) , 
    @OUT_RESULT Char( 'AK0_STATUS' )  output ) AS
 
-- Declaration of variables
DECLARE @cCodigo Char( 'CTD_ITEM' )
DECLARE @cCodAux Char( 'CTD_ITEM' )
DECLARE @cSup Char( 'CTD_ITEM' )
DECLARE @cSupAux Char( 'CTD_ITEM' )
DECLARE @iRecno Integer
DECLARE @iRecnoAux Integer
DECLARE @cExecSql  nvarchar(250)
DECLARE @cParcSql nvarchar( 250 )
BEGIN
   SELECT @cCodigo  = '' 
   SELECT @cSup  = '' 
   SELECT @cCodAux  = '' 
   SELECT @cSupAux  = '' 
   SELECT @iRecno  = 0 
    
   -- Cursor declaration CTDSup
   DECLARE CTDSup  CURSOR FOR 
   SELECT CTD_ITEM , CTD_ITSUP 
     FROM CTD### 
     WHERE CTD_FILIAL  = @IN_FILIAL  and CTD_CLASSE  = '2'  and D_E_L_E_T_  = ' ' 
     GROUP BY CTD_ITEM , CTD_ITSUP 
   FOR READ ONLY 
    
   OPEN CTDSup
   FETCH CTDSup 
    INTO @cCodigo , @cSup 
   WHILE (@@fetch_status  = 0 )
   BEGIN
      
      ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
         SELECT @cExecSql = " SELECT @iRecnoa  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
         SELECT @cParcSql = '@iRecnoa Integer OUTPUT'
         EXEC sp_executesql @cExecSql, @cParcSql, @iRecnoa=@iRecno OUTPUT    
      ##ENDIF_001
      ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
         SELECT @cExecSql = " SELECT COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
         SELECT @cExecSql = 'IMMEDIATES'
      ##ENDIF_002
      ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
         SELECT @cExecSql = " SELECT @iRecnoa  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
         EXECUTE @cExecSql
      ##ENDIF_003
      SELECT @iRecno  = @iRecno  + 1 
      IF @cSup  != ' ' 
      BEGIN 
      ##TRATARECNO @iRecno\
        ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES (''" || @cCodigo || "'',''" || @cSup || "'', " ||  CAST( @iRecno AS VARCHAR) || " ) "
            exec sp_executesql @cExecSql
        ##ENDIF_001
        ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES (''" || @cCodigo || "'',''" || @cSup || "'',  " || to_char( @iRecno ) || " ) "
            SELECT @cExecSql = 'IMMEDIATE'
        ##ENDIF_002
        ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
            SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES (''" || @cCodigo || "'',''" || @cSup || "'', " ||   CAST( @iRecno AS VARCHAR(16)) || " ) "
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
           FROM CTD### 
           WHERE CTD_FILIAL  = @IN_FILIAL  and CTD_ITEM  = @cSupAux  and D_E_L_E_T_  = ' ' 
         IF @iRecnoAux is NOT null 
         BEGIN 
            SELECT @cCodAux  = CTD_ITSUP 
              FROM CTD### 
              WHERE CTD_FILIAL  = @IN_FILIAL  and CTD_ITEM  = @cSupAux  and D_E_L_E_T_  = ' ' 
            IF @cCodAux  != ' ' 
            BEGIN 
               
               ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                  SELECT @cExecSql = " SELECT @iRecnoa  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
                  SELECT @cParcSql = '@iRecnoa Integer OUTPUT'
                  EXEC sp_executesql @cExecSql, @cParcSql, @iRecnoa=@iRecno OUTPUT      
               ##ENDIF_001
               ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                  SELECT @cExecSql = " SELECT COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
                  SELECT @cExecSql = 'IMMEDIATES'
               ##ENDIF_002
               ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                  SELECT @cExecSql = " SELECT @iRecnoa  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) FROM " || @IN_CTAB
                  EXECUTE @cExecSql
               ##ENDIF_003 
               SELECT @iRecno  = @iRecno  + 1 
               ##TRATARECNO @iRecno\
                  ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES (''" || @cCodigo || "'',''" || @cCodAux || "'', " ||  CAST( @iRecno AS VARCHAR) || " ) "
                     exec sp_executesql @cExecSql
                  ##ENDIF_001
                  ##IF_002({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES (''" || @cCodigo || "'',''" || @cCodAux || "'', " || to_char( @iRecno ) || " ) "
                     SELECT @cExecSql = 'IMMEDIATE'
                  ##ENDIF_002
                  ##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
                     SELECT @cExecSql = " INSERT INTO " || @IN_CTAB || "(ANALITICA , SUPERIOR , R_E_C_N_O_ )  VALUES (''" || @cCodigo || "'',''" || @cCodAux || "'', " ||   CAST( @iRecno AS VARCHAR(16)) || " ) "
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
      FETCH CTDSup 
       INTO @cCodigo , @cSup 
   END 
   CLOSE CTDSup
   DEALLOCATE CTDSup
   SELECT @OUT_RESULT  = '1' 
END 