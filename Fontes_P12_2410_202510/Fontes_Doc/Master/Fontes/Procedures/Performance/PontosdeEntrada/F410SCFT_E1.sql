Create procedure F410SCFT_E1_##
( @cFilial_E1  Char( 'E1_FILIAL' ) , 
  @cFilial_A1  Char( 'A1_FILIAL') , 
  @IN_CLIDE    Char( 'A1_COD'  ), 
  @IN_CLIATE   Char( 'A1_COD' ), 
  @OUT_RESULTADO  char(1) OutPut
) 
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    -  <s> F410SCFT_E1 (FINA410) Ponto de Entrada </s>
    Versão      -  <v> Protheus P12 </v>
    Assinatura  -  <a> 011 </a>
    Descricao   -  <d> Permite ajustar os filtros de Clientes que devem ou não atualizar os valores acumulados
					   Permite ajustar os filtros de títulos que devem ou não compor os valores acumulados </d>
    Entrada     -  <ri>
				   @cFilial_E2	- Compartilhamento da tabela do E2
				   @cFilial_A2  - Compartilhamento da tabela do A2
				   @IN_FORDE	- Fornecedor inicial da consulta, 
				   @IN_FORATE   - Fornecedor Até da consulta 
                   </ri>
    Saida          <ro> N/A </ro>
    Responsavel :  <r> Fernando Navarro </r>
    Data        :  <dt> 28/10/2019 </dt>
--------------------------------------------------------------------------------------------------------------------- */
-- Cursor declaration curSE1
##IF_001({|| AllTrim(Upper(TcGetDB())) == "MSSQL" })
DECLARE curSE1  CURSOR FOR 
select E1_VALOR , E1_SALDO , E1_VALLIQ , E1_VLCRUZ , E1_CLIENTE , E1_LOJA , E1_MOEDA , E1_EMISSAO , E1_TIPO , 
	E1_VENCTO , E1_VENCREA , E1_BAIXA , E1_PREFIXO , E1_NUM , E1_PARCELA , E1_ORIGEM , E1_FATURA , E1_MSFIL , 
	E1_PEDIDO , E1_SERIE 
from SE1### SE1, SA1### SA1
where SE1.E1_FILIAL  = @cFilial_E1  and SA1.A1_FILIAL  = @cFilial_A1  and SA1.A1_COD  between @IN_CLIDE and @IN_CLIATE 
and SA1.A1_COD  = SE1.E1_CLIENTE  and SA1.A1_LOJA  = SE1.E1_LOJA  and SE1.D_E_L_E_T_  = ' '  and SA1.D_E_L_E_T_  = ' ' 

	/* Adicionar o controle customizado para que o cliente não seja atualizado 
	   Adicionar o controle customizado para não considerar algum título em especifico
	*/
begin
   select @OUT_RESULTADO = '1'
end
##ELSE_001
begin
   select @OUT_RESULTADO = '1'
end
##ENDIF_001