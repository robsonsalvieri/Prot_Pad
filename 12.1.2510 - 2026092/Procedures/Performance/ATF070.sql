CREATE PROCEDURE ATF070_## (
    @IN_cFilial         CHAR('N3_FILIAL'), 
    @IN_dDataBase       CHAR(8),    
    @IN_dMesAnt         CHAR(8),     
    @IN_lAtfctap        INTEGER,
    @IN_cN1TipoNeg      VARCHAR(50),
    @IN_cN3TipoNeg      VARCHAR(50),
    @IN_cContaCap       CHAR('N4_CONTA'),
    @IN_cCalcDep        CHAR(1),
    @IN_cTipDepr        CHAR(1),    
    @OUT_RESULT         CHAR(1) OUTPUT )
AS
DECLARE @dViradaAtivo  CHAR(8)
DECLARE @dPrimDiaMes   CHAR(8)
DECLARE @lTemVirada    INTEGER    
DECLARE @cFilialSN1    CHAR('N1_FILIAL')
DECLARE @cFilialSN3    CHAR('N1_FILIAL')
DECLARE @cFilialSN5    CHAR('N1_FILIAL')
DECLARE @cFilialFNE    CHAR('N1_FILIAL')
DECLARE @cFilialSN0    CHAR('N1_FILIAL')

BEGIN    
SELECT @OUT_RESULT = 'BEG'
    SELECT @OUT_RESULT = '0'

    EXEC XFILIAL_## 'SN1', @IN_cFilial, @cFilialSN1 output 
    EXEC XFILIAL_## 'SN3', @IN_cFilial, @cFilialSN3 output
    EXEC XFILIAL_## 'SN5', @IN_cFilial, @cFilialSN5 output
    EXEC XFILIAL_## 'FNE', @IN_cFilial, @cFilialFNE output
    EXEC XFILIAL_## 'SN0', @IN_cFilial, @cFilialSN0 output
    SELECT @dPrimDiaMes = SUBSTRING(@IN_dDataBase,1,6)||'01'
    
    -- Verificacao da virada anual
    SELECT @dViradaAtivo = RTRIM(N0_DESC01), @lTemVirada = 1
    FROM SN0###
    WHERE N0_FILIAL = @cFilialSN0 AND N0_TABELA = '13' AND N0_CHAVE = 'VIRADAATIVO' AND D_E_L_E_T_ = ' '

    -- ETAPA 1+2: Atualizar N3_VRCMES1 e N3_VRCDM1
    IF @lTemVirada = 1 AND @dViradaAtivo < @IN_dMesAnt
    BEGIN
        SELECT 'SN3_MERGE'
            SELECT T.SN3RECNO,
                   MAX(COALESCE(M07.N4_VLROC1, 0)) AS VRCMES1,
                   MAX(COALESCE(M08.N4_VLROC1, 0)) AS VRCDM1
            FROM TRX###_41_SP T
            LEFT JOIN SN4### M07
                ON  M07.N4_FILIAL = T.N4_FILIAL AND M07.N4_CBASE = T.N4_CBASE
                AND M07.N4_ITEM   = T.N4_ITEM   AND M07.N4_TIPO  = T.N4_TIPO
                AND M07.N4_DATA   = @IN_dMesAnt AND M07.N4_OCORR = '07'
                AND M07.N4_SEQ    = T.N4_SEQ    AND M07.D_E_L_E_T_ = ' '
            LEFT JOIN SN4### M08
                ON  M08.N4_FILIAL = T.N4_FILIAL AND M08.N4_CBASE = T.N4_CBASE
                AND M08.N4_ITEM   = T.N4_ITEM   AND M08.N4_TIPO  = T.N4_TIPO
                AND M08.N4_DATA   = @IN_dMesAnt AND M08.N4_OCORR = '08'
                AND M08.N4_SEQ    = T.N4_SEQ    AND M08.D_E_L_E_T_ = ' '
            WHERE T.N4_DATA = @IN_dDataBase AND T.D_E_L_E_T_ = ' '
            GROUP BY T.SN3RECNO
        
        SELECT 'ON_1'
        
    END

    -- ETAPA 3: Reverter N3_NOVO de '2' para '1'
    SELECT 'SN3_MERGE'
    SELECT T.SN3RECNO FROM TRX###_41_SP T WHERE T.N4_DATA = @IN_dDataBase AND T.D_E_L_E_T_ = ' ' GROUP BY T.SN3RECNO
    SELECT 'ON_2'    

    -- ETAPA 4.1: Atualizar N3_VRDMESx (despesa de depreciacao)
    IF @lTemVirada = 1 AND @dViradaAtivo < @IN_dMesAnt
    BEGIN
        SELECT 'SN3_MERGE'
            SELECT T.SN3RECNO,
                'SEL_3'
            FROM TRX###_41_SP T
            LEFT JOIN SN4### MA
                ON  MA.N4_FILIAL = T.N4_FILIAL AND MA.N4_CBASE = T.N4_CBASE
                AND MA.N4_ITEM   = T.N4_ITEM   AND MA.N4_TIPO  = T.N4_TIPO
                AND MA.N4_DATA   = @IN_dMesAnt AND MA.N4_OCORR = T.N4_OCORR
                AND MA.N4_SEQ    = T.N4_SEQ    AND MA.D_E_L_E_T_ = ' '
            WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20')
            AND T.N4_CONTA = T.N3_CDEPREC AND T.N4_TIPOCNT = '3' AND T.D_E_L_E_T_ = ' '
            GROUP BY T.SN3RECNO
        SELECT 'ON_3'
    END
    
    -- ETAPA 4.2: Subtrair de N3_VRDBALx e N3_VRDACMx            
    SELECT 'SN3_MERGE'
        SELECT T.SN3RECNO,
               'SEL_4'
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20')
          AND T.N4_CONTA = T.N3_CCDEPR AND T.N4_TIPOCNT = '4' AND T.D_E_L_E_T_ = ' '
        GROUP BY T.SN3RECNO
    SELECT 'ON_4'

    -- ETAPA 4.4: Valor Residual e limpeza de N3_FIMDEPR (Tarefa 1.4: multimoeda + saldo acelerado tipo 07)
    SELECT 'SN3_MERGE'
        SELECT MAIN.SN3RECNO
        FROM TRX###_41_SP MAIN
        WHERE MAIN.N4_DATA  = @IN_dDataBase
        AND MAIN.N4_OCORR IN ('06','10','11','12','20')
        AND MAIN.D_E_L_E_T_ = ' '
        AND EXISTS (
            SELECT 1
            FROM TRX###_41_SP T
            INNER JOIN SN3### SN3M
                ON  SN3M.R_E_C_N_O_ = T.SN3RECNO
                AND SN3M.D_E_L_E_T_  = ' '
            LEFT JOIN SN3### SACEL
                ON  SACEL.N3_FILIAL  = T.N3_FILIAL
                AND SACEL.N3_CBASE   = T.N3_CBASE
                AND SACEL.N3_ITEM    = T.N3_ITEM
                AND SACEL.N3_TIPO    = '07'
                AND SACEL.D_E_L_E_T_ = ' '
            WHERE T.N3_FILIAL = MAIN.N3_FILIAL
                AND T.N3_CBASE  = MAIN.N3_CBASE
                AND T.N3_ITEM   = MAIN.N3_ITEM
                AND T.N4_DATA   = @IN_dDataBase
                AND T.N4_OCORR  IN ('06','10','11','12','20')
                AND T.N3_TIPO   IN ('01','10','16','17')
                AND (
                    'SEL_5'
                )
                AND T.D_E_L_E_T_ = ' '
        )
        GROUP BY MAIN.SN3RECNO
    SELECT 'ON_5' 
   
    -- ETAPA 4.5: Zeragem de valores negativos
    IF COALESCE(RTRIM(@IN_cN1TipoNeg), '') = '' AND  COALESCE(RTRIM(@IN_cN3TipoNeg), '') = ''
    BEGIN
        SELECT 'SN3_MERGE'
            SELECT T.SN3RECNO
            FROM TRX###_41_SP T
            WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20') AND T.N3_TIPO <> '05' AND T.D_E_L_E_T_ = ' '
            GROUP BY T.SN3RECNO
        SELECT 'ON_6'    
    END ELSE BEGIN
        SELECT 'SN3_MERGE'
            SELECT T.SN3RECNO
            FROM TRX###_41_SP T
            WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20') AND T.N3_TIPO <> '05'
            AND @IN_cN1TipoNeg NOT LIKE '%' || T.N1_PATRIM || '%'
            AND @IN_cN3TipoNeg NOT LIKE '%' || T.N3_TIPO || '%'
            AND T.D_E_L_E_T_ = ' '
            GROUP BY T.SN3RECNO
        SELECT 'ON_6'
    END
        
    -- ETAPA 5: Correcao monetaria (Ocorrencia 07)                
    SELECT 'SN3_MERGE'
        SELECT T.SN3RECNO,
                MAX(T.N4_VLROC1) AS N4_VLROC1,
                MAX(COALESCE('MA07.N4_VLROC1', 0)) AS VRCMES1            
        FROM TRX###_41_SP T
        LEFT JOIN SN4### MA07
            ON  MA07.N4_FILIAL = T.N4_FILIAL AND MA07.N4_CBASE = T.N4_CBASE
            AND MA07.N4_ITEM   = T.N4_ITEM   AND MA07.N4_TIPO  = T.N4_TIPO
            AND MA07.N4_DATA   = @IN_dMesAnt AND MA07.N4_OCORR = '07'
            AND MA07.N4_SEQ    = T.N4_SEQ    AND MA07.D_E_L_E_T_ = ' '
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR = '07'
            AND T.N4_CONTA = T.N3_CCONTAB AND T.N4_TIPOCNT = '1'
            AND T.D_E_L_E_T_ = ' '
        GROUP BY T.SN3RECNO
    SELECT 'ON_7'
    
    -- ETAPA 6: Correcao da depreciacao (Ocorrencia 08) — multimoeda (Tarefa 1.3)       
    SELECT 'SN3_MERGE'
        SELECT T.SN3RECNO,
               MAX(T.N4_VLROC1) AS N4_VLROC1,
               MAX(COALESCE('MA08.N4_VLROC1', 0)) AS VRCDM1
        FROM TRX###_41_SP T
        LEFT JOIN SN4### MA08
            ON  MA08.N4_FILIAL = T.N4_FILIAL AND MA08.N4_CBASE = T.N4_CBASE
            AND MA08.N4_ITEM   = T.N4_ITEM   AND MA08.N4_TIPO  = T.N4_TIPO
            AND MA08.N4_DATA   = @IN_dMesAnt AND MA08.N4_OCORR = '08'
            AND MA08.N4_SEQ    = T.N4_SEQ    AND MA08.D_E_L_E_T_ = ' '
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR = '08' AND T.D_E_L_E_T_ = ' '
        GROUP BY T.SN3RECNO
    SELECT 'ON_8'
   
    
    -- ETAPA 9.1: SN5 - Conta N3_CDEPREC (ocorr 06,10,11,12,20)
    SELECT 'SN5_MERGE'       
        SELECT T.N3_CDEPREC AS CONTA, T.N4_DATA, T.N3_TIPO, T.N3_TPSALDO, 'T.N4_OCORR' AS TIPO,
            'SEL_4'               
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20') AND T.N4_CONTA = T.N3_CDEPREC AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N3_CDEPREC, T.N4_DATA, T.N3_TIPO, T.N3_TPSALDO, 'T.N4_OCORR'
               
    SELECT 'ON_9'
    
    -- ETAPA 9.2: SN5 - Conta N3_CCDEPR (ocorr 06,10,11,12,20)
    SELECT 'SN5_MERGE'        
        SELECT T.N3_CCDEPR AS CONTA, T.N4_DATA, T.N3_TIPO, T.N3_TPSALDO, 'T.N4_OCORR' AS TIPO,
             'SEL_4'               
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20') AND T.N4_CONTA = T.N3_CCDEPR AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N3_CCDEPR, T.N4_DATA, T.N3_TIPO, T.N3_TPSALDO, 'T.N4_OCORR'
    SELECT 'ON_9'
    
    -- ETAPA 9.3: SN5 - Correcao monetaria (ocorr 07)
    SELECT 'SN5_MERGE'   
        SELECT T.N4_CONTA AS CONTA, T.N4_DATA, 'T.N1_PATRIM_2' AS TIPO,
               'SEL_4'               
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR = '07'
          AND ((T.N4_CONTA = T.N3_CCONTAB AND T.N4_TIPOCNT = '1')
               OR (T.N4_CONTA = T.N3_CCORREC AND T.N4_TIPOCNT = '2'))
          AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N4_CONTA, T.N4_DATA, 'T.N1_PATRIM_2'                 
    SELECT 'ON_10'
    
    -- ETAPA 9.4: SN5 - Correcao da depreciacao (ocorr 08) - Conta N3_CDESP
    SELECT 'SN5_MERGE'       
        SELECT T.N3_CDESP AS CONTA, T.N4_DATA,
               'SEL_4'               
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR = '08' AND T.N4_CONTA = T.N3_CDESP AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N3_CDESP, T.N4_DATA
    SELECT 'ON_11'
    
    -- ETAPA 9.4b: SN5 - Correcao da depreciacao (ocorr 08) - Conta N3_CCDEPR
    SELECT 'SN5_MERGE'        
        SELECT T.N3_CCDEPR AS CONTA, T.N4_DATA,
               'SEL_4'               
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR = '08' AND T.N4_CONTA = T.N3_CCDEPR AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N3_CCDEPR, T.N4_DATA
    SELECT 'ON_11'
    
    -- ETAPA 9.6: SN5 - Correcao Capital Social (ocorr 07, N1_PATRIM = 'C')
    SELECT 'SN5_MERGE'        
        SELECT T.N4_CONTA AS CONTA, T.N4_DATA,
               'SEL_4'               
        FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR = '07'
          AND T.N4_CONTA = @IN_cContaCap AND T.N4_TIPOCNT = '6' AND T.N1_PATRIM = 'C' AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N4_CONTA, T.N4_DATA
    SELECT 'ON_12'
    
    -- ETAPA 9.7: SN5 - Exclusao fisica de registros zerados/negativos (Tarefa 1.7: inclui MV_N1TPNEG via SN1)

    If COALESCE(RTRIM(@IN_cN3TipoNeg), '') = ''
    BEGIN
        DELETE FROM SN5###
        WHERE N5_FILIAL = @cFilialSN5 AND D_E_L_E_T_ = ' '
        AND (('ROUND_SN5') = 0
            OR (('ROUND_SN5') <= 0
                AND N5_TPBEM <> '05'                
                AND NOT EXISTS (
                    SELECT 1 FROM SN1### SN1J
                    INNER JOIN TRX###_41_SP TJ
                        ON  TJ.N4_FILIAL = SN1J.N1_FILIAL
                        AND TJ.N4_CBASE  = SN1J.N1_CBASE
                        AND TJ.N4_ITEM   = SN1J.N1_ITEM
                        AND TJ.SN3RECNO  = SN5###.R_E_C_N_O_
                        AND SN1J.D_E_L_E_T_ = ' '
                    WHERE SN1J.N1_FILIAL = @cFilialSN1
                        AND @IN_cN1TipoNeg LIKE '%' || SN1J.N1_PATRIM || '%'
                        AND SN1J.D_E_L_E_T_ = ' '
                )
            ))
        AND EXISTS (
            SELECT 1 FROM TRX###_41_SP T
            WHERE T.N4_DATA = @IN_dDataBase AND SN5###.N5_DATA = T.N4_DATA
                AND (SN5###.N5_CONTA = T.N3_CDEPREC OR SN5###.N5_CONTA = T.N3_CCDEPR
                    OR SN5###.N5_CONTA = T.N4_CONTA OR SN5###.N5_CONTA = T.N3_CDESP)
                AND T.D_E_L_E_T_ = ' '
                )
                
    END ELSE BEGIN
        DELETE FROM SN5###
            WHERE N5_FILIAL = @cFilialSN5 AND D_E_L_E_T_ = ' '
            AND (('ROUND_SN5') = 0
                OR (('ROUND_SN5') <= 0
                    AND N5_TPBEM <> '05'
                    AND @IN_cN3TipoNeg NOT LIKE '%' || N5_TPBEM || '%'
                    AND NOT EXISTS (
                        SELECT 1 FROM SN1### SN1J
                        INNER JOIN TRX###_41_SP TJ
                            ON  TJ.N4_FILIAL = SN1J.N1_FILIAL
                            AND TJ.N4_CBASE  = SN1J.N1_CBASE
                            AND TJ.N4_ITEM   = SN1J.N1_ITEM
                            AND TJ.SN3RECNO  = SN5###.R_E_C_N_O_
                            AND TJ.D_E_L_E_T_ = ' '
                        WHERE SN1J.N1_FILIAL = @cFilialSN1
                            AND @IN_cN1TipoNeg LIKE '%' || SN1J.N1_PATRIM || '%'
                            AND SN1J.D_E_L_E_T_ = ' '
                    )
                ))
            AND EXISTS (
                SELECT 1 FROM TRX###_41_SP T
                WHERE T.N4_DATA = @IN_dDataBase AND SN5###.N5_DATA = T.N4_DATA
                    AND (SN5###.N5_CONTA = T.N3_CDEPREC OR SN5###.N5_CONTA = T.N3_CCDEPR
                        OR SN5###.N5_CONTA = T.N4_CONTA OR SN5###.N5_CONTA = T.N3_CDESP)
                    AND T.D_E_L_E_T_ = ' '
                    )
                    
    END
    
    -- ETAPA 10: Atualizacao de projetos (FNE) — Tarefa 1.6: agrupado por FNE_MOEDRF para evitar cruzamento de moedas
    SELECT 'FNE_MERGE'
        SELECT T.N1_PROJETO, T.N1_PROJREV, T.N1_PROJETP, T.N1_PROJITE, 'T.N4_TIPO' AS TPATF,
               T.N4_TPSALDO, FNE.FNE_MOEDRF,
               SUM('CASE_FNE') AS VLROC_FNE
        FROM TRX###_41_SP T
        INNER JOIN FNE### FNE
            ON  FNE.FNE_FILIAL  = @cFilialFNE
            AND FNE.FNE_CODPRJ  = T.N1_PROJETO
            AND FNE.FNE_REVIS   = T.N1_PROJREV
            AND FNE.FNE_ETAPA   = T.N1_PROJETP
            AND FNE.FNE_ITEM    = T.N1_PROJITE
            AND FNE.D_E_L_E_T_  = ' '
        WHERE T.N4_DATA = @IN_dDataBase AND T.N4_OCORR IN ('06','10','11','12','20')
            AND T.N4_CONTA = T.N3_CCDEPR AND T.N4_TIPOCNT = '4' AND T.N1_PROJETO <> ''
            AND T.D_E_L_E_T_ = ' '
        GROUP BY T.N1_PROJETO, T.N1_PROJREV, T.N1_PROJETP, T.N1_PROJITE,
                 'T.N4_TIPO', T.N4_TPSALDO, FNE.FNE_MOEDRF
    SELECT 'ON_13'
    
    -- ETAPA 11: Exclusao fisica dos registros SN4
    DELETE FROM SN4###
    WHERE R_E_C_N_O_ IN (
        SELECT T.SN4RECNO FROM TRX###_41_SP T
        WHERE T.N4_DATA = @IN_dDataBase
          AND (T.N4_OCORR IN ('06','07','08','10','11','12','17','18','20'))
          AND T.D_E_L_E_T_ = ' '
    )
    
   -- ETAPA 12: Atualiza N3_FIMDEPR nos registros SN3 de tipo '07' (acelerada)   
    SELECT 'SN3_MERGE'
        SELECT SN3_07.R_E_C_N_O_ AS SN3RECNO
        FROM SN3### SN3_07
        WHERE SN3_07.N3_FILIAL  = @cFilialSN3
          AND SN3_07.N3_TIPO    = '07'
          AND SN3_07.D_E_L_E_T_ = ' '
          AND EXISTS (
              SELECT 1
              FROM TRX###_41_SP T
              INNER JOIN SN3### SN3M          -- SN3 do tipo original (01/10/16/17)
                  ON  SN3M.R_E_C_N_O_ = T.SN3RECNO
                  AND SN3M.D_E_L_E_T_  = ' '
              WHERE T.N4_DATA    = @IN_dDataBase
                AND T.N4_OCORR  IN ('06','10','11','12','20')
                AND T.N4_CONTA   = T.N3_CCDEPR    -- garante TIPOCNT='4' (depr. acum.)
                AND T.N4_TIPOCNT = '4'            -- mesmo filtro do AdvPL: AF070VLRES
                AND T.N3_TIPO   IN ('01','10','16','17')
                AND T.N3_FILIAL  = SN3_07.N3_FILIAL
                AND T.N3_CBASE   = SN3_07.N3_CBASE
                AND T.N3_ITEM    = SN3_07.N3_ITEM
                AND (
                   'SEL_12'
                )
                AND T.D_E_L_E_T_ = ' '
          )
          GROUP BY SN3_07.R_E_C_N_O_
    SELECT 'ON_5'
    
    -- ETAPA 15: Atualizar registros que nao sao do processamento atual
    IF @lTemVirada = 1 AND @dViradaAtivo < @IN_dMesAnt
    BEGIN
        SELECT 'SN3_MERGE'           
            SELECT T.SN3RECNO,
                   'SEL_14'
            FROM TRX###_41_SP T
            LEFT JOIN SN4### MA2
                ON  MA2.N4_FILIAL = T.N4_FILIAL AND MA2.N4_CBASE = T.N4_CBASE
                AND MA2.N4_ITEM   = T.N4_ITEM   AND MA2.N4_TIPO  = T.N4_TIPO
                AND MA2.N4_DATA   = @IN_dMesAnt AND MA2.N4_OCORR = T.N4_OCORR
                AND MA2.N4_SEQ    = T.N4_SEQ    AND MA2.D_E_L_E_T_ = ' '
            WHERE T.N4_DATA <> @IN_dDataBase AND T.D_E_L_E_T_ = ' '
            GROUP BY T.SN3RECNO
        SELECT 'ON_14'
    END

    SELECT @OUT_RESULT = '1'
SELECT @OUT_RESULT = 'END'
END
