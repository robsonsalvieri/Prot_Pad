create procedure MA280CON_##
( @IN_CODIGO     char('B1_COD'),
  @IN_LFATCONV   char(01),
  @OUT_RESULTADO char(01) output
 )
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    - <s> MA280CON Ponto de Entrada </s>
    Versão      - <v> Protheus P12 </v>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Ponto de entrada para verificar se irah utilizar o fator de conversao ou nao </d>
    Entrada     -  <ri>
                   @IN_CODIGO      - Codigo do Produto
                   @IN_LFATCONV    - Fator de conversao
                   </ri>
    Saida       - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
    Data        - <dt> 18/01/02 </dt>
--------------------------------------------------------------------------------------------------------------------- */
begin
   select @OUT_RESULTADO = @IN_LFATCONV
end
