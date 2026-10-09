Create procedure F410SCFT_E2_##
( @cFilial_E2  Char( 'E2_FILIAL' ), 
  @cFilial_A2  Char( 'A2_FILIAL' ), 
  @IN_FORDE    Char( 'A2_COD' ), 
  @IN_FORATE   Char( 'A2_COD' ),
  @OUT_RESULTADO  char(1) OutPut
) 
as
/* ---------------------------------------------------------------------------------------------------------------------
    Programa    -  <s> F410SCFT_E2 (FINA410) Ponto de Entrada </s>
    Versão      -  <v> Protheus P12 </v>
    Assinatura  -  <a> 011 </a>
    Descricao   -  <d> Permite ajustar os filtros de Fornecedores que devem ou não atualizar os valores acumulados 
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
-- Cursor declaration curSE2
##IF_001({|| AllTrim(Upper(TcGetDB())) == "MSSQL" })
DECLARE curSE2  CURSOR FOR 
select E2_FORNECE , E2_LOJA , E2_SALDO , E2_MOEDA , E2_EMISSAO , E2_TIPO , E2_ORIGEM , E2_NUM , E2_PREFIXO , 
		E2_VALOR 
	from  SE2### SE2, SA2### SA2
	where SE2.E2_FILIAL  = @cFilial_E2  and SA2.A2_FILIAL  = @cFilial_A2  and SE2.E2_FORNECE  = SA2.A2_COD  and SE2.E2_LOJA  = SA2.A2_LOJA 
	and SA2.A2_COD  between @IN_FORDE and @IN_FORATE  and SE2.D_E_L_E_T_  = ' '  and SA2.D_E_L_E_T_  = ' '
	/* Adicionar o controle customizado para que o fornecedor não seja atualizado 
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