-- Procedure creation  CTBVLDMOED_##
CREATE PROCEDURE CTBA105E_## (
    @IN_DATALANC Char( 8 ) ,
    @IN_cFilCTO  Char( 'CT1_FILIAL'  ) , 
    @IN_cFilCTP  Char( 'CT1_FILIAL'  ) ,
    @IN_cFilCTG  Char( 'CT1_FILIAL'  ) , 
    @IN_cFilCTE  Char( 'CT1_FILIAL'  ) , 
    @IN_nCT2_VALOR Float ,
    @IN_cMoeda Char( 2 ),
    @IN_cCT2_VLD03 Char( 2 ),
    @OUT_cCT2_VLD03 Char( 2 )  output ) AS

    DECLARE @nMoedaInUse Float
    DECLARE @nMoedDtUse Float
 
-- Declaration of variables
BEGIN
    SELECT @OUT_cCT2_VLD03 = @IN_cCT2_VLD03
    IF @OUT_cCT2_VLD03  = ' '  and @IN_nCT2_VALOR  != 0 
    BEGIN 
        SELECT @nMoedaInUse  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
            FROM CTO### 
            WHERE CTO_FILIAL  = @IN_cFilCTO and CTO_MOEDA  = @IN_cMoeda and CTO_BLOQ  = '2' and D_E_L_E_T_  = ' ' 
        IF @nMoedaInUse  = 0 
        BEGIN 
            SELECT @OUT_cCT2_VLD03  = '19' 
        END 
        IF @OUT_cCT2_VLD03  = ' '  
        BEGIN 
            SELECT @nMoedDtUse  = COALESCE ( COUNT ( R_E_C_N_O_ ), 0 )
                FROM CTP### 
                WHERE CTP_FILIAL  = @IN_cFilCTP and CTP_MOEDA  = @IN_cMoeda  and CTP_DATA  = @IN_DATALANC and CTP_BLOQ  = '1' and D_E_L_E_T_  = ' ' 
            IF  @nMoedDtUse  > 0 
            BEGIN 
                SELECT @OUT_cCT2_VLD03  = '19' 
            END 
        END
        IF @OUT_cCT2_VLD03  = ' '  
        BEGIN 
            SELECT @nMoedDtUse  = COALESCE ( COUNT ( CTE.R_E_C_N_O_ ), 0 )
                FROM CTE### CTE, CTG### CTG
                WHERE CTE_FILIAL  = CTG_FILIAL  and CTE_CALEND  = CTG_CALEND  and CTE_FILIAL  = @IN_cFilCTE  and CTE_MOEDA  = @IN_cMoeda 
                and CTG_FILIAL  = @IN_cFilCTG  and @IN_DATALANC  between CTG_DTINI and CTG_DTFIM  and CTG_STATUS  = '1'  and CTE.D_E_L_E_T_  = ' ' 
                and CTG.D_E_L_E_T_  = ' ' 
            IF  @nMoedDtUse  = 0 
            BEGIN 
                SELECT @OUT_cCT2_VLD03  = '19' 
            END 
        END
    END 
END