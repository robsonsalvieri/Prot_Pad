create procedure MA280INC2CP_##
(
 @IN_RECNOSC2  INTEGER
)
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    :   <s> MA280INC2CP </s>
    Assinatura  :   <a> 001 </a>
    Descricao   :   <d> Atualiza partes do custo em partes no SC2 </d>
    Entrada     :  <ri> @IN_RECNOSC2  - Recno corrente SC2 </ri>
    Saida       :  <ro> </ro>
    Versão      :   <v> Protheus P12 </v>
    Observações :   <o>   </o>
    Responsavel :   <r> Marcelo Pimentel </r>
    Data        :  <dt> 15/03/2005 </dt>
    -----------------------------------------------------------------------------------------------------------------
    Obs.: Não remova os tags acima. Os tags são a base para a geração automática, de documentação, pelo Parse.
--------------------------------------------------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------------------------------------------------
   Variaveis internas (Declare abaixo todas as variáveis utilizadas na procedure)
--------------------------------------------------------------------------------------------------------------------- */
declare @nRec         integer
--<*> ----- Fim da Declaração de variáveis internas -------------------------------------------------------------- <*>--

begin
  select @nRec = 0
end