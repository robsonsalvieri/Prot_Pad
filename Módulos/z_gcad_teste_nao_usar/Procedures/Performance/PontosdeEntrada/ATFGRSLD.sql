Create procedure ATFGRSLD_## (
   @IN_TIPOCNT Char( 01 ),
   @IN_SINAL   Char( 01 ),
   @IN_TABELA  Char( 03 ),
   @IN_RECNO   integer
 )
as
/* ---------------------------------------------------------------------------------------------------------------------
    Assinatura  :   <a> 001 </a>
--------------------------------------------------------------------------------------------------------------------- */
Declare @iRecno integer

begin
   Select @iRecno = @IN_RECNO
end
