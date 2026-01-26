Create procedure MA330SEQ_##
(
   @IN_ORDEM      char(03),
   @IN_CALIAS     char(03),
   @IN_RECFILE    integer,
   @OUT_ORDEM     char(03) output,
   @OUT_ALIAS     char(03) output,
   @OUT_RESULTADO char(01) output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    - <s> MA330SEQ Ponto de Entrada </s>
    Vers„o      - <v> Protheus P12 </v>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Ponto de entrada para mudar a sequencia do calculo </d>
    Entrada     -  <ri>
                   @IN_ORDEM      - Alias do Arquivos onde serﬂ efetuado os selects (SD1, SD2, SD3)
                   @IN_CALIAS     - Ordem Calculo
                   </ri>
    Saida       - <ro> @OUT_ORDEM     - Alias do Arquivos onde serﬂ efetuado os selects (SD1, SD2, SD3)
                       @IN_CALIAS     - Ordem Calculo
                       @OUT_RESULTADO - Indica o termino OK da procedure </ro>
    Data        :  <dt> 07/03/02 </dt>
--------------------------------------------------------------------------------------------------------------------- */
begin
   select @OUT_ORDEM     = @IN_ORDEM
   select @OUT_ALIAS     = @IN_CALIAS
   select @OUT_RESULTADO = '1'
end
