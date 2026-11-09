Create procedure M216SB6GRV_##
(
   @IN_FILIALCOR    Char('B1_FILIAL'),
   @IN_RECNOSB6     Integer,
   @OUT_RESULTADO   char(01) Output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    -  <s> M216SB6GRV (MATA216) Ponto de Entrada similar ao SB6GRAVA </s>
    Versão      -  <v> Protheus P12 </v>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Permite atualizar algum campo customizado do SB6 no registro que acabou de ser gravado</d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_RECNOSB6     - Registro que acabou de ser gravado
                   </ri>
--------------------------------------------------------------------------------------------------------------------- */
declare @OutResult varchar(01)
begin
   select @OUT_RESULTADO = '1'
end
