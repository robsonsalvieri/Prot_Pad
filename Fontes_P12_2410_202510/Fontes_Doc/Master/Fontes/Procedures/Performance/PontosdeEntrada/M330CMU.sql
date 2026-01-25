Create procedure M330CMU_##
(
   @IN_FILIALCOR    Char('B1_FILIAL'),
   @IN_CODORIMOD    Char('B2_COD'),
   @IN_DDATABASE    Char(08),
   @IN_TRB_CM1      float,
   @IN_TRB_CM2      float,
   @IN_TRB_CM3      float,
   @IN_TRB_CM4      float,
   @IN_TRB_CM5      float,
   @OUT_TRB_CM1     float OutPut,
   @OUT_TRB_CM2     float OutPut,
   @OUT_TRB_CM3     float OutPut,
   @OUT_TRB_CM4     float OutPut,
   @OUT_TRB_CM5     float OutPut,
   @OUT_RESULTADO   char(01) Output
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    -  <s> M330CMU (MATA330) Ponto de Entrada </s>
    Versão      -  <v> Protheus P12 </v>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Pega valores de custo do produto quando o mesmo é sucata ( resíduo ) </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_CODORIMOD    - Codigo do Produto a ser recuperado o Custo
                   @OUT_TRB_CM1     - Custo Moeda1
                   @OUT_TRB_CM2     - Custo Moeda2
                   @OUT_TRB_CM3     - Custo Moeda3
                   @OUT_TRB_CM4     - Custo Moeda4
                   @OUT_TRB_CM5     - Custo Moeda5
                   </ri>
    Saida          <ro> @OUT_RESULT      - Status da execucao do processo </ro>
    Responsavel :  <r> Marco Norbiato </r>
    Data        :  <dt> 13/03/2003 </dt>
--------------------------------------------------------------------------------------------------------------------- */
declare @OutResult varchar(01)
begin
   select @OUT_TRB_CM1   = @IN_TRB_CM1
   select @OUT_TRB_CM2   = @IN_TRB_CM2
   select @OUT_TRB_CM3   = @IN_TRB_CM3
   select @OUT_TRB_CM4   = @IN_TRB_CM4
   select @OUT_TRB_CM5   = @IN_TRB_CM5
   select @OUT_RESULTADO = '1'
end
