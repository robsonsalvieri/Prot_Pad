Create procedure F410SCFT_A2_##
( @IN_MVPAR02  Char( 01 ) , 
  @cFilial_A2  Char( 'A2_FILIAL' ) , 
  @IN_FORDE    Char( 'A2_COD' ), 
  @IN_FORATE   Char( 'A2_COD' ),
  @iprimeiro_recno Integer
) 
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    -  <s> F410SCFT_A2 (FINA410) Ponto de Entrada </s>
    Versão      -  <v> Protheus P12 </v>
    Assinatura  -  <a> 011 </a>
    Descricao   -  <d> permite ajustar os filtros de Fornecedores que devem ou não atualizarem os valores acumulados </d>
    Entrada     -  <ri>
				   @IN_MVPAR02	- Atualiza historico 
				   @cFilial_A1  - Compartilhamento da tabela do A2
				   @IN_FORDE	- Fornecedor inicial da consulta, 
				   @IN_FORATE   - Fornecedor Até da consulta ,
				   @iprimeiro_recno - Recno para controle 
                   </ri>
    Saida          <ro> N/A </ro>
    Responsavel :  <r> Fernando Navarro </r>
    Data        :  <dt> 28/10/2019 </dt>
--------------------------------------------------------------------------------------------------------------------- */
if  (@IN_MVPAR02  = '1' )  begin
	update SA2###
	set A2_SALDUP  = 0 , A2_SALDUPM  = 0 , A2_MCOMPRA  = 0 , A2_MNOTA  = 0 , A2_NROCOM  = 0 , A2_MSALDO  = 0 
	where A2_FILIAL  = @cFilial_A2  and A2_COD  between @IN_FORDE and @IN_FORATE  and R_E_C_N_O_  between @iprimeiro_recno and @iprimeiro_recno  + 1024 
	and D_E_L_E_T_  = ' ' 
	/* Adicionar o controle customizado para que o fornecedor não seja atualizado */
end 
else begin
	update SA2###
	set A2_SALDUP  = 0 , A2_SALDUPM  = 0 , A2_MCOMPRA  = 0 , A2_MNOTA  = 0 
	where A2_FILIAL  = @cFilial_A2  and A2_COD  between @IN_FORDE and @IN_FORATE  and R_E_C_N_O_  between @iprimeiro_recno and @iprimeiro_recno  + 1024 
	and D_E_L_E_T_  = ' ' 
	/* Adicionar o controle customizado para que o fornecedor não seja atualizado */
end
