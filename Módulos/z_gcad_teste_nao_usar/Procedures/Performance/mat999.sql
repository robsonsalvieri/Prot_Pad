Create Procedure mat999_## (
   @IN_RONY   char(7),
   @OUT_RONY  char(1) OutPut
)
as
/* ---------------------------------------------------------------------------------------------------------------------
	ATENÇÃO     :  Esta procedure é usada apenas para validação dos pacotes do tipo TESTE
	               e para simular a adição de um novo .SQL em um processo já existente.

	Programa    :  <s> EMERSON.RONY </s>
	Descrição   :  <d> Procedure usada para geração de pacotes do tipo TESTE </d>
    Responsavel :  <r> Emerson Rony </r>
    Data        :  <dt> 19/11/2021 </dt>
--------------------------------------------------------------------------------------------------------------------- */
Declare @cPAR_IN char(7)
begin
   select @cPAR_IN = @IN_RONY
   select @OUT_RONY = '1'
end