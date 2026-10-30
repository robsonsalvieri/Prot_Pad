Create procedure M280SB9_##
(
   @IN_FILIALCOR      char( 'B1_FILIAL' ),
   @IN_PRODUTO        char( 'B1_COD' ),    
   @IN_LOCAL          char( 'B1_LOCPAD' )
)

as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    - <s> M280SB9 Ponto de Entrada </s>
    Versão      - <v> Protheus P12 </v>
    Assinatura  - <a> 001 </a>
    Descricao   - <d> Ponto de Entrada para atualizacao do SB9 </d>
    Entrada     -  <ri>
                   @IN_FILIALCOR    - Filial Corrente
                   @IN_PRODUTO      - Codigo do Produto
                   @IN_LOCAL        - Armazem
                   </ri>
    Data        :  <dt> 26/03/07 </dt>
--------------------------------------------------------------------------------------------------------------------- */

Declare @cRetirar char(01)

begin
 select @cRetirar = '1'
end
