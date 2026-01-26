create procedure F410SCFT_A1_##
( @IN_MVPAR02  char( 01 ) , 
  @cFilial_A1  char( 'A1_FILIAL' ), 
  @IN_CLIDE    char( 'A1_COD' ), 
  @IN_CLIATE   char( 'A1_COD' ),
  @iprimeiro_recno integer
) 
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    -  <s> F410SCFT_A1 (FINA410) Ponto de Entrada </s>
    Versão      -  <v> Protheus P12 </v>
    Assinatura  -  <a> 011 </a>
    Descricao   -  <d> permite ajustar os filtros de Clientes que devem ou não atualizarem os valores acumulados </d>
    Entrada     -  <ri>
				   @IN_MVPAR02	- Atualiza historico 
				   @cFilial_A1  - Compartilhamento da tabela do A1
				   @IN_CLIDE	- Cliente inicial da consulta, 
				   @IN_CLIATE   - Cliente Até da consulta ,
				   @iprimeiro_recno - Recno para controle 
                   </ri>
    Saida          <ro> N/A </ro>
    Responsavel :  <r> Fernando Navarro </r>
    Data        :  <dt> 28/10/2019 </dt>
--------------------------------------------------------------------------------------------------------------------- */
if  (@IN_MVPAR02  = '1' ) begin
	update SA1### 
	set A1_SALDUP  = 0 , A1_SALDUPM  = 0 , A1_SALFIN  = 0 , A1_SALFINM  = 0 , A1_VACUM  = 0 , A1_MSALDO  = 0 
	, A1_METR  = 0 , A1_MATR  = 0 , A1_MAIDUPL  = 0 , A1_ATR  = 0 , A1_PAGATR  = 0 , A1_NROPAG  = 0 , 
		A1_ULTCOM  = ' ' , A1_MCOMPRA  = 0 , A1_NROCOM  = 0
	where A1_FILIAL  = @cFilial_A1  and A1_COD  between @IN_CLIDE and @IN_CLIATE  and R_E_C_N_O_  between @iprimeiro_recno and @iprimeiro_recno  + 1024 
	and D_E_L_E_T_  = ' ' 
	/* Adicionar o controle customizado para que o cliente não seja atualizado */
end 
else begin
	update SA1###
	set A1_SALDUP  = 0 , A1_SALDUPM  = 0 , A1_SALFIN  = 0 , A1_SALFINM  = 0 , A1_VACUM  = 0 
	where A1_FILIAL  = @cFilial_A1  and A1_COD  between @IN_CLIDE and @IN_CLIATE  and R_E_C_N_O_  between @iprimeiro_recno and @iprimeiro_recno  + 1024 
	and D_E_L_E_T_  = ' ' 
	/* Adicionar o controle customizado para que o cliente não seja atualizado */
end 

