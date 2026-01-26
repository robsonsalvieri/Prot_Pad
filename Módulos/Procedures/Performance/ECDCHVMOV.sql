-- Procedure creation 
CREATE PROCEDURE ECDCHVMOV_## (
    @IN_CHAVE VarChar( 'CSA_NUMLOT' ) , 
    @OUT_CHAVE VarChar( 'CSA_NUMLOT' )  output ) AS
 
-- Declaration of variables
DECLARE @cChave Char( 'CSA_NUMLOT' )
BEGIN
   SELECT @cChave  = @IN_CHAVE 
   SELECT @OUT_CHAVE  = @cChave 
END 