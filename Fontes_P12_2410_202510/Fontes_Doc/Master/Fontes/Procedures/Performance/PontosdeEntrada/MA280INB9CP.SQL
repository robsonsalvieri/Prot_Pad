Create Procedure MA280INB9CP_##
(
 @IN_FILIALCOR  char('B1_FILIAL'),
 @IN_COD        char('B1_COD'),
 @IN_MV_CUSZERO char(01),
 @IN_RECNOSB9   integer,
 @IN_RECNOSB2   integer,
 @IN_NDIVISOR   float,
 @IN_B9_VINI1   float,
 @IN_B9_VINI2   float,
 @IN_B9_VINI3   float,
 @IN_B9_VINI4   float,
 @IN_B9_VINI5   float
)
as

/* ---------------------------------------------------------------------------------------------------------------------
    Programa    :   <s> MA280INB9CP </s>
    Assinatura  :   <a> 001 </a>
    Descricao   :   <d> Gravar os Valores finais no SB9 com o CUSTO EM PARTES. </d>
    Entrada     :  <ri> @IN_FILIALCOR  - Filial corrente 
                        @IN_COD        - Codigo do Produto
                        @IN_MV_CUSZERO - Se a quantidade final do Periodo for igual a Zero deverá Zerar custo.
                        @IN_RECNOSB9   - recno posicionado SB9
                        @IN_RECNOSB2   - recno posicionado SB2
                        @IN_NDIVISOR   - Saldo em quantidade no SB2 (B2_QFIM)
                        @IN_B9_VINI1   - Valor final a transferir (moeda 1)
                        @IN_B9_VINI2   - Valor final a transferir (moeda 2)
                        @IN_B9_VINI3   - Valor final a transferir (moeda 3)
                        @IN_B9_VINI4   - Valor final a transferir (moeda 4)
                        @IN_B9_VINI5   - Valor final a transferir (moeda 5)
    Versão      :   <v> Protheus P12 </v>
    Observações :   <o>   </o>
    Responsavel :   <r> Marcelo Pimentel </r>
    Data        :  <dt> 09/03/2005 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------------------------------
   Variaveis internas (Declare abaixo todas as variáveis utilizadas na procedure)
--------------------------------------------------------------------------------------------------------------------- */

declare @iRecnoTRT     integer
--<*> ----- Fim da Declaração de variáveis internas -------------------------------------------------------------- <*>--

begin
  select @iRecnoTRT = 0
end
