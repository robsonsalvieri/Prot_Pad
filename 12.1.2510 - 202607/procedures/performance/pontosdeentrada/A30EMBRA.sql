Create Procedure A30EMBRA_## (
   @IN_A30EMBRA  float,
   @OUT_TXMEDIA  float OutPut
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 001 </a>
--------------------------------------------------------------------------------------------------------------------- */
Declare @nTxMedia float
begin
   select @nTxMedia = @IN_A30EMBRA
   select @OUT_TXMEDIA = @nTxMedia
end