-- Procedure creation  CtbPRegra

CREATE PROCEDURE CTBA105D_## (
    @IN_CODENTID Char( 'CT1_CONTA' ) , 
    @IN_REGRA Char( 'CT1_RGNV1' ) , 
    @IN_CONTRAREGRA Char( 'CTT_CRGNV1' ) , 
    @OUT_RET Char( 01 )  output ) AS
 
-- Declaration of variables
DECLARE @cTem Char( 01 )
DECLARE @cCodigo VarChar( 'CTA_REGRA' )
DECLARE @nContador Integer
BEGIN
   SELECT @OUT_RET  = '1' 
   SELECT @cTem  = '0' 
   IF @IN_CODENTID  != ' ' 
   BEGIN 
      IF @IN_REGRA  != ' '  and @IN_CONTRAREGRA  != ' ' 
      BEGIN 
         SELECT @cTem  = '0' 
         SELECT @cCodigo  = '' 
         SELECT @nContador  = 1 
         WHILE (@nContador  <= LEN ( @IN_CONTRAREGRA ))
         BEGIN
            SELECT @cCodigo  = @cCodigo  + SUBSTRING ( @IN_CONTRAREGRA , @nContador , 1 )
            IF SUBSTRING ( @IN_CONTRAREGRA , @nContador , 1 ) = '/'  or SUBSTRING ( @IN_CONTRAREGRA , @nContador , 1 ) = ' ' 
              
            BEGIN 
               SELECT @cCodigo  = SUBSTRING ( @cCodigo , 1 , LEN ( @cCodigo ) - 1 )
               IF @cCodigo  = ' ' 
               BEGIN 
                  break
               END 
               IF CHARINDEX ( @cCodigo , @IN_REGRA ) > 0 
               BEGIN 
                  SELECT @cTem  = '1' 
               END 
            END 
            SELECT @nContador  = @nContador  + 1 
         END 
         IF @cCodigo  != ' '  and CHARINDEX ( @cCodigo , @IN_REGRA ) > 0 
         BEGIN 
            SELECT @cTem  = '1' 
         END 
         IF @cTem  = '1' 
         BEGIN 
            SELECT @OUT_RET  = '1' 
         END 
         ELSE 
         BEGIN 
            SELECT @OUT_RET  = '0' 
         END 
      END 
   END 
END 