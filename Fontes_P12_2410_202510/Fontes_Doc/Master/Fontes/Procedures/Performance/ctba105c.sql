-- Procedure creation  CtbPrcAmar
CREATE PROCEDURE CTBA105C_## (
    @IN_FILIAL Char( 'CT1_FILIAL' ) , 
    @IN_CONTA Char( 'CT1_CONTA' ) , 
    @IN_CUSTO Char( 'CTT_CUSTO' ) , 
    @IN_ITEM Char( 'CTD_ITEM' ) , 
    @IN_CLVL Char( 'CTH_CLVL' ) , 
    @OUT_RET Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @nContador Integer
DECLARE @cAlias Char( 03 )
DECLARE @nNivel Integer
DECLARE @cRegra Char( 'CT1_RGNV1' )
DECLARE @cContraRegra Char( 'CTT_CRGNV1' )
DECLARE @OUT_AMAR Char( 1 )
DECLARE @cFilCT1 Char( 'CT1_FILIAL' )
DECLARE @cFilCTT Char( 'CT1_FILIAL' )
DECLARE @cFilCTD Char( 'CT1_FILIAL' )
DECLARE @cFilCTH Char( 'CT1_FILIAL' )
DECLARE @cAux Char( 03 )
BEGIN
   SELECT @OUT_RET  = '1' 
   SELECT @OUT_AMAR  = '1' 
   SELECT @cAux  = 'CT1' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCT1 output 
   SELECT @cAux  = 'CTT' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTT output 
   SELECT @cAux  = 'CTD' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTD output 
   SELECT @cAux  = 'CTH' 
   EXEC XFILIAL_## @cAux , @IN_FILIAL , @cFilCTH output 
    
   -- Cursor declaration cCursor1
   DECLARE cCursor1 insensitive  CURSOR FOR 
   SELECT 'CT1'  ALIAS , 1  NIVEL , CT1_RGNV1  REGRA , CTT_CRGNV1  CONTRAREGRA 
     FROM CT1### CT101, CTT### CTT
     WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @IN_CONTA  and CT101.D_E_L_E_T_  = ' '  and CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @IN_CUSTO 
      and CTT.D_E_L_E_T_  = ' ' 
   UNION ALL
   SELECT 'CT1'  ALIAS , 2  NIVEL , CT1_RGNV2  REGRA , CTD_CRGNV1  CONTRAREGRA 
     FROM CT1### CT102, CTD### CTD
     WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @IN_CONTA  and CT102.D_E_L_E_T_  = ' '  and CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @IN_ITEM 
      and CTD.D_E_L_E_T_  = ' ' 
   UNION ALL
   SELECT 'CT1'  ALIAS , 3  NIVEL , CT1_RGNV3  REGRA , CTH_CRGNV1  CONTRAREGRA 
     FROM CT1### CT103, CTH### CTH
     WHERE CT1_FILIAL  = @cFilCT1  and CT1_CONTA  = @IN_CONTA  and CT103.D_E_L_E_T_  = ' '  and CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @IN_CLVL 
      and CTH.D_E_L_E_T_  = ' ' 
   UNION ALL
   SELECT 'CTT'  ALIAS , 2  NIVEL , CTT_RGNV2  REGRA , CTD_CRGNV2  CONTRAREGRA 
     FROM CTT### CTT01, CTD### CTD
     WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @IN_CUSTO  and CTT01.D_E_L_E_T_  = ' '  and CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @IN_ITEM 
      and CTD.D_E_L_E_T_  = ' ' 
   UNION ALL
   SELECT 'CTT'  ALIAS , 3  NIVEL , CTT_RGNV3  REGRA , CTH_CRGNV2  CONTRAREGRA 
     FROM CTT### CTT02, CTH### CTH
     WHERE CTT_FILIAL  = @cFilCTT  and CTT_CUSTO  = @IN_CUSTO  and CTT02.D_E_L_E_T_  = ' '  and CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @IN_CLVL 
      and CTH.D_E_L_E_T_  = ' ' 
   UNION ALL
   SELECT 'CTD'  ALIAS , 3  NIVEL , CTD_RGNV3  REGRA , CTH_CRGNV3  CONTRAREGRA 
     FROM CTD### CTD, CTH### CTH
     WHERE CTD_FILIAL  = @cFilCTD  and CTD_ITEM  = @IN_ITEM  and CTD.D_E_L_E_T_  = ' '  and CTH_FILIAL  = @cFilCTH  and CTH_CLVL  = @IN_CLVL 
      and CTH.D_E_L_E_T_  = ' ' 
   FOR READ ONLY 
    
   OPEN cCursor1
   FETCH cCursor1 
    INTO @cAlias , @nNivel , @cRegra , @cContraRegra 
   WHILE ( (@@FETCH_STATUS  = 0 ) )
   BEGIN
      IF @cRegra  != ' '  and @cContraRegra  != ' ' 
      BEGIN 
         IF @cAlias  = 'CT1'  and @nNivel  = 1  and @IN_CONTA  != ' ' 
         BEGIN 
            EXEC CTBA105D_## @IN_CUSTO , @cRegra , @cContraRegra , @OUT_AMAR output 
         END 
         IF @cAlias  = 'CT1'  and @nNivel  = 2  and @IN_CONTA  != ' ' 
         BEGIN 
            EXEC CTBA105D_## @IN_ITEM , @cRegra , @cContraRegra , @OUT_AMAR output 
         END 
         IF @cAlias  = 'CT1'  and @nNivel  = 3  and @IN_CONTA  != ' ' 
         BEGIN 
            EXEC CTBA105D_## @IN_CLVL , @cRegra , @cContraRegra , @OUT_AMAR output 
         END 
         IF @cAlias  = 'CTT'  and @nNivel  = 2  and @IN_CUSTO  != ' ' 
         BEGIN 
            EXEC CTBA105D_## @IN_ITEM , @cRegra , @cContraRegra , @OUT_AMAR output 
         END 
         IF @cAlias  = 'CTT'  and @nNivel  = 3  and @IN_CUSTO  != ' ' 
         BEGIN 
            EXEC CTBA105D_## @IN_CLVL , @cRegra , @cContraRegra , @OUT_AMAR output 
         END 
         IF @cAlias  = 'CTD'  and @nNivel  = 3  and @IN_ITEM  != ' ' 
         BEGIN 
            EXEC CTBA105D_## @IN_CLVL , @cRegra , @cContraRegra , @OUT_AMAR output 
         END 
         IF @OUT_AMAR  = '0' 
         BEGIN 
            break
         END 
      END 
      FETCH cCursor1 
       INTO @cAlias , @nNivel , @cRegra , @cContraRegra 
   END 
   CLOSE cCursor1
   DEALLOCATE cCursor1
   SELECT @OUT_RET  = @OUT_AMAR 
END 