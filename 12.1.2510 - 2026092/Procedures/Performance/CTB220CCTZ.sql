-- Procedure creation 
CREATE PROCEDURE CTB220CCTZ_## (
    @IN_FILIALCOR Char( 'CTZ_FILIAL' ), 
    @IN_CAMPOS VARCHAR( 1 ), 
    @IN_CQUERY VARCHAR( 1 ), 
    @OUT_RESULTADO Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cSRC_EMP Char( 02 )
DECLARE @iRecno Integer
DECLARE @cFilial Char( 'CTZ_FILIAL' )

DECLARE @cDocAux Char( 006 )
DECLARE @iExistCTZ Integer
DECLARE @cExecSql VARCHAR( 1 )

##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cPostgres Char( 1 )
   DECLARE @nfim_CUR FLOAT 
##ENDIF_003

##IF_004({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
   DECLARE @cOracle Char( 1 )
##ENDIF_004

--ABAIXO SUBSITUIDO NO PONTO DE ENTRADA
declare flex char(1)


BEGIN
   SELECT @OUT_RESULTADO  = '0' 
   EXEC XFILIAL_## 'CTZ' , @IN_FILIALCOR , @cFilial output 
    
   
    ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
        -- Cursor declaration @cCUR_CTB220A
        SELECT @cExecSql = ' DECLARE cCUR_CTB220A insensitive  CURSOR FOR '
    ##ENDIF_001
    -- SELECT @cExecSql = @cExecSql ||' SELECT ' || @IN_CAMPOS || ' FROM ( ' 
    SELECT @cExecSql = @cExecSql ||' SELECT ' || @IN_CAMPOS || ' FROM  ' 
    SELECT @cExecSql = @cExecSql || @IN_CQUERY || ' ORDER BY SRC_EMP , CTZ_DOC , CTZ_LINHA '
    
    ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
        SELECT @cExecSql = @cExecSql || " FOR READ ONLY "
        exec sp_executesql @cExecSql
        OPEN cCUR_CTB220A
    ##ENDIF_001

    ##IF_002({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})      
        OPEN cCUR_CTB220A
    ##ENDIF_002
    
    ##IF_003({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
        OPEN cCUR_CTB220A --Não tirar de dentro do IF - será substituído no pos compile
    ##ENDIF_003

    FETCH cCUR_CTB220A
    INTO @cSRC_EMP 
    
    WHILE ( (@@fetch_status  = 0 ) )
    BEGIN
        SELECT @nCTZ_VLRDEB  = ROUND ( @nCTZ_VLRDEB , 2 )
        SELECT @nCTZ_VLRCRD  = ROUND ( @nCTZ_VLRCRD , 2 )
        SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) + 1 FROM CTZ### 
        IF @cDocAux is null 
        BEGIN 
            SELECT @cDocAux  = @cCTZ_DOC 
        END 
        ELSE 
        BEGIN 
            SELECT @cCTZ_DOC  = @cDocAux 
        END 

        SELECT @iExistCTZ  = 1 
            FROM CTZ### 
            WHERE CTZ_FILIAL  = @cFilial  and CTZ_DATA  = @cCTZ_DATA  and CTZ_LOTE  = @cCTZ_LOTE  and CTZ_SBLOTE  = @cCTZ_SBLOTE 
                and CTZ_DOC  = @cCTZ_DOC  and CTZ_LINHA  = @cCTZ_LINHA  and CTZ_EMPORI  = @cCTZ_EMPORI  and CTZ_FILORI  = @cCTZ_FILORI 
                and CTZ_MOEDLC  = @cCTZ_MOEDLC  and D_E_L_E_T_  = ' ' 

        IF  (@iExistCTZ is NOT null )
        BEGIN
            EXEC MSSOMA1 @cCTZ_DOC, '1', @cCTZ_DOC output
        END

        SELECT @cDocAux  = @cCTZ_DOC 
        SELECT @iExistCTZ  = NULL 

        INSERT INTO CTZ### (CTZ_FILIAL ) 
        VALUES ( @cFilial )
        FETCH cCUR_CTB220A
        INTO @cSRC_EMP 
    END 
    CLOSE cCUR_CTB220A
    DEALLOCATE cCUR_CTB220A
    SELECT @OUT_RESULTADO  = '1' 
END 
