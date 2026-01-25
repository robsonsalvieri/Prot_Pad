Create Procedure AF050FPR_## (
   @IN_FILIAL   Char( 'N3_FILIAL' ),
   @IN_CBASE    Char( 'N3_CBASE' ),
   @IN_ITEM     Char( 'N3_ITEM' ),
   @IN_TIPO     Char( 'N3_TIPO' ),
   @IN_SEQ      Char( 'N3_SEQ' ),
   @IN_DATA     Char( 08 ),
   @OUT_RESULT  Char( 01 ) OutPut
)

as
/* ------------------------------------------------------------------------------------
    Versão          - <v>  Protheus 9.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  ATFA050.PRW </s>
    Descricao       - <d>  Calculo de Depreciação </d>
    Funcao do Siga  -      Ponto de entrada AF050FPR
    Entrada         - <ri> @IN_FILIAL  - Filial De
                           @IN_CBASE   - Código base do Ativo
                           @IN_ITEM    - Item base do Ativo
                           @IN_TIPO    - Tipo do Ativo
                           @IN_SEQ     - Sequencia de inclusao do Ativo
                           @IN_DATA    - Data de depreciacao </ri>
    Saida           - <o>  @OUT_RESULT - se retornar '1' calcula a depreciacao, se '0' não calcula </ro>
    Responsavel :     <r>  Alice Yamamoto	</r>
    Data        :     15/04/2008
   ----------------------------------------------------------------------------------------------*/
Declare @cRet Char( 01 )

begin
   Select @cRet = '1'
   
   Select @OUT_RESULT = @cRet
end
