

CREATE PROCEDURE CTB220CCT2_## (
    @IN_FILIALCOR Char( 'CT2_FILIAL' ), 
    @IN_CQUERY VARCHAR( 1 ) , 
    @IN_ISJOBETRW INTEGER  , 
    @OUT_RESULTADO Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cSRC_EMP Char(02)
DECLARE @iRecno Integer
DECLARE @iRecnoCTF Integer
DECLARE @cFilial_CT2 Char( 'CT2_FILIAL' )
DECLARE @cFilial_CTF Char( 'CTF_FILIAL' )
DECLARE @cFilial_CQA Char( 'CQA_FILIAL' )
DECLARE @iAux Integer
DECLARE @cDataAnt Char( 08 )

DECLARE @cCT2_LOTES Char( 'CT2_LOTE' )
DECLARE @cLoteAnt Char( 'CT2_LOTE' )
DECLARE @cCT2_SBLOTES Char( 'CT2_SBLOTE' )
DECLARE @cSbLoteAnt Char( 'CT2_SBLOTE' )
DECLARE @cCT2_DOCS Char( 'CT2_DOC' )
DECLARE @cDocAnt Char( 'CT2_DOC' )
DECLARE @cLinhaAnt Char( 'CT2_LINHA' )
DECLARE @lPrim Char( 01 )
DECLARE @cCT2_HISTDEST Char( 'CT2_HIST' )
DECLARE @nCT2_VALORDEST Float
DECLARE @cDocAux Char( 'CT2_DOC' )
DECLARE @iExistCT2 Integer
DECLARE @cExecSql VARCHAR( 1 )

##IF_003({|| AllTrim(Upper(TcGetDB())) == "POSTGRES"})
   DECLARE @cPostgres Char( 1 )
   DECLARE @nfim_CUR FLOAT 
##ENDIF_003

##IF_004({|| AllTrim(Upper(TcGetDB())) == "ORACLE"})      
   DECLARE @cOracle Char( 1 )
##ENDIF_004

--VARIAVEIS DECLARE NO PONTO DE ENTRADA 2437 APAGAR

--ABAIXO SUBSITUIDO NO PONTO DE ENTRADA  
declare flex char(1)

BEGIN
    SELECT @OUT_RESULTADO  = '0' 
    SELECT @iRecnoCTF  = 0 
    SELECT @iAux  = 5 
    EXEC XFILIAL_## 'CT2' , @IN_FILIALCOR , @cFilial_CT2 output 
    EXEC XFILIAL_## 'CTF' , @IN_FILIALCOR , @cFilial_CTF output 
    EXEC XFILIAL_## 'CQA' , @IN_FILIALCOR , @cFilial_CQA output 

    
    ##IF_001({|| AllTrim(Upper(TcGetDB())) $ "MSSQL/MSSQL7"})
        -- Cursor declaration cCUR_CTB220A
        SELECT @cExecSql = ' DECLARE cCUR_CTB220A insensitive  CURSOR FOR '
    ##ENDIF_001
    SELECT @cExecSql = @cExecSql ||' SELECT  @IN_CAMPOS  FROM ' 
    SELECT @cExecSql = @cExecSql || @IN_CQUERY || ' ORDER BY SRC_EMP , CT2_DOC , CT2_LINHA '
    -- VARIAVEL CQUERY JA NO FONTE NA LINHA 2419

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
        
        --Nao tem como saber se o pe foi editado via existblock
        --##IF_001({|| ExistBlock("CT220DOC" ) }) 
        SELECT @cCT2_LOTES  = ' ' 
        SELECT @cCT2_SBLOTES  = ' ' 
        SELECT @cCT2_DOCS  = ' ' 
        EXEC CT220DOC_## @cFilial_CT2 , @cCT2_DATA , @cCT2_LINHA , @cCT2_TPSALD , @cCT2_EMPORI , @cCT2_FILORI , @cCT2_MOEDLC , 
                @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LOTES output , @cCT2_SBLOTES output , @cCT2_DOCS output 
        SELECT @cCT2_LOTE  = @cCT2_LOTES 
        SELECT @cCT2_SBLOTE  = @cCT2_SBLOTES 
        SELECT @cCT2_DOC  = @cCT2_DOCS 
        --##ENDIF_001

        SELECT @nCT2_VALOR  = ROUND ( @nCT2_VALOR , 2 )
        IF @cDocAux is null 
        BEGIN 
            SELECT @cDocAux  = @cCT2_DOC 
        END 
        ELSE 
        BEGIN 
            SELECT @cCT2_DOC  = @cDocAux 
        END 
        SELECT @iExistCT2  = 1 
        FROM CT2### 
        WHERE CT2_FILIAL  = @cFilial_CT2  and CT2_DATA  = @cCT2_DATA  and CT2_LOTE  = @cCT2_LOTE  and CT2_SBLOTE  = @cCT2_SBLOTE 
            and CT2_DOC  = @cCT2_DOC  and CT2_LINHA  = @cCT2_LINHA  and CT2_EMPORI  = @cCT2_EMPORI  and CT2_FILORI  = @cCT2_FILORI 
            and CT2_MOEDLC  = @cCT2_MOEDLC  and D_E_L_E_T_  = ' ' 
        IF  (@iExistCT2 is NOT null ) 
        BEGIN 
            EXEC MSSOMA1 @cCT2_DOC , '1' , @cCT2_DOC output 
        END 
        SELECT @cDocAux  = @cCT2_DOC 
        SELECT @iExistCT2  = NULL 
        SELECT @iRecnoCTF  = MIN ( R_E_C_N_O_ )
        FROM CTF### 
        WHERE CTF_FILIAL  = @cFilial_CTF  and CTF_DATA  = @cCT2_DATA  and CTF_LOTE  = @cCT2_LOTE  and CTF_SBLOTE  = @cCT2_SBLOTE 
            and CTF_DOC  = @cCT2_DOC  and D_E_L_E_T_  = ' ' 
        IF @iRecnoCTF is null 
        BEGIN 
            SELECT @iRecnoCTF  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) + 1 FROM CTF### 

            INSERT INTO CTF### (CTF_FILIAL , CTF_DATA , CTF_LOTE , CTF_SBLOTE , CTF_DOC , CTF_LINHA , R_E_C_N_O_ ) 
            VALUES (@cFilial_CTF , @cCT2_DATA , @cCT2_LOTE , @cCT2_SBLOTE , @cCT2_DOC , @cCT2_LINHA , @iRecnoCTF )
        END 
        ELSE 
        BEGIN 
            UPDATE CTF###
            SET CTF_LINHA  = @cCT2_LINHA 
            WHERE R_E_C_N_O_  = @iRecnoCTF 
        END 
       
        SELECT @cCT2_HISTDEST  = ' ' 
        SELECT @nCT2_VALORDEST  = 0 

        EXEC CTB220ALT_## @cFilial_CT2, @cCT2_DATA , @cCT2_LINHA , @cCT2_TPSALD , @cCT2_EMPORI , @cCT2_FILORI , @cCT2_MOEDLC , @cCT2_LOTE , 
                @cCT2_SBLOTE , @cCT2_DOC , @cCT2_HIST , @nCT2_VALOR , @cCT2_HISTDEST output , @nCT2_VALORDEST output 
        
        -- Recebe o valor alterado pelo Ponto de Entrada para gravação 
        SELECT @cCT2_HIST  = @cCT2_HISTDEST 
        SELECT @nCT2_VALOR  = @nCT2_VALORDEST 

        SELECT @iRecno  = 0 
        SELECT @iRecno  = COALESCE ( MAX ( R_E_C_N_O_ ), 0 ) + 1 FROM CT2### 
      
        INSERT INTO CT2### (CT2_FILIAL ) 
        VALUES (@cFilial_CT2)

        IF @IN_ISJOBETRW = 1 
        BEGIN 
            SELECT @iRecno = COALESCE(MAX(R_E_C_N_O_),0) + 1 FROM CQA###
            INSERT INTO CQA### (CQA_FILIAL, CQA_FILCT2, CQA_DATA, CQA_LOTE, CQA_SBLOTE, CQA_DOC, CQA_LINHA, CQA_MOEDLC, CQA_EMPORI, CQA_FILORI, CQA_TPSALD, R_E_C_N_O_ )
                VALUES (@cFilial_CQA, @cFilial_CT2, @cCT2_DATA, @cCT2_LOTE, @cCT2_SBLOTE, @cCT2_DOC, @cCT2_LINHA, @cCT2_MOEDLC, @cCT2_EMPORI, @cCT2_FILORI, @cCT2_TPSALD, @iRecno)
        END
        FETCH cCUR_CTB220A
        INTO @cSRC_EMP 
    END 
    CLOSE cCUR_CTB220A
    DEALLOCATE cCUR_CTB220A
    SELECT @OUT_RESULTADO  = '1' 
END 

