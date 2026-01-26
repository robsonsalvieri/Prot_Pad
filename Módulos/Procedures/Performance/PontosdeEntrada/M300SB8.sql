Create procedure M300SB8_##
(
   @IN_FILIALCOR      char( 'B1_FILIAL'),
   @IN_PRODUTO        char( 'B1_COD' ),    
   @IN_LOCAL          char( 'B1_LOCPAD' ),
   @IN_LOTECTL        char( 'D5_LOTECTL' ),
   @IN_NUMLOTE        char( 'D5_NUMLOTE' )
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    - <s> M300SB8 Ponto de Entrada </s>
    Versão      - <v> Protheus P12 </v>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Ponto de entrada para gravar campos especificos do SB8 </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_PRODUTO      - Codigo do Produto
                   @IN_LOCAL        - Armazem
                   @IN_LOTECTL      - Lote de Controle
                   @IN_NUMLOTE      - Cod. Sub-Lote
                   </ri>
    Data        :  <dt> 07/03/02 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Declare @cRetirar char(01)

begin
 select @cRetirar = '1'
end
