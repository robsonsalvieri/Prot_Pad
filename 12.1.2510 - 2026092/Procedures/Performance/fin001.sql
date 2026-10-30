Create Procedure FIN001_##
 (
	  @IN_PREFIXO     Char('E1_PREFIXO'),
	  @IN_NUMERO      Char('E1_NUM'),
	  @IN_PARCELA     Char('E1_PARCELA'),
	  @IN_CCART       Char('E5_RECPAG'),
	  @IN_MOEDA       Float,
	  @IN_DDATA       Char(08),
	  @IN_CFORNCLI    Char('E2_FORNECE'),
	  @IN_LOJA        Char('E1_LOJA'),
	  @IN_FILIALCOR   Char('E1_FILIAL'),
	  @IN_DATABASE    Char(08),
	  @IN_TIPO        Char('E1_TIPO'),
	  @IN_BD          Char(01),
	  @IN_NOORDPAGO   Char(01),
	  @IN_IDPAI       Char('FK7_IDPAI'),
	  @OUT_TOTABAT    Float Output
 )

as
	/* ---------------------------------------------------------------------
		Procedure   -  <d> Recupera o somatório dos abatimentos </d>
		Fonte Siga  -  <s> SumAbat </s>
		Assinatura  - <a>  013 </a>
		Entrada     -  <ri> 
					   @IN_PREFIXO     - Prefixo do titulo
					   @IN_NUMERO      - Numero 
					   @IN_PARCELA     - Parcela
					   @IN_CCART       - Carteira
					   @IN_MOEDA       - Moeda
					   @IN_DDATA       - Data
					   @IN_CFORNCLI    - Cliente ou Fornecedor
					   @IN_LOJA        - Loja
					   @IN_DATABASE    - Database
					   @IN_FILIALCOR   - Filial corrente
					   </ri>

		Saida       -  <ro> @OUT_TOTABAT    - Total de Abatimentos </ro>

		Autor       :  <r> Vicente Sementilli </r>
		Criacao     :  <dt> 11/08/1998 </dt>


	   Estrutura de chamadas
	   ========= == ========

		0.FIN001 - Recupera a somatoria dos abatimentos
		  1.MAT021 - Converte valor da moeda origem para moeda destino com base na data
			2.MAT020 - Recupera taxa para moeda na data em questao

	 ---------------------------------------------------------------------- */
	/*
	Checada compatibilidade de versão 609 e 710 em 06/03/03 Marco.
	*/
	declare @E1_FILIAL      Char('E1_FILIAL')
	declare @E2_FILIAL      Char('E2_FILIAL')
	declare @ValorAbat      Float
	declare @MoedaAbat      Float
	declare @cAux           Varchar(3)
begin
	--Recupera filial para tabela SE1 e SE2
	select @cAux = 'SE1'
	exec XFILIAL_## @cAux, @IN_FILIALCOR, @E1_FILIAL Output
	select @cAux = 'SE2'
	exec XFILIAL_## @cAux, @IN_FILIALCOR, @E2_FILIAL Output
	select @OUT_TOTABAT = 0
	select @ValorAbat   = 0

	--Montagem de cursor - Receber ou Pagar
	if @IN_CCART = 'R' begin
		if @IN_IDPAI = '0' begin
			if @IN_BD = '1' begin
				--Query para SQL Server
				declare CUR_SUMABAT_A cursor for
				
				select E1_VALOR, E1_MOEDA
				from SE1###
				where 
					E1_FILIAL    = @E1_FILIAL
					and E1_PREFIXO   = @IN_PREFIXO
					and E1_NUM       = @IN_NUMERO
					and E1_PARCELA   = @IN_PARCELA
					and E1_TIPO      LIKE '%-'
					and (E1_CLIENTE  = @IN_CFORNCLI or E1_CLIENTE  = 'UNIAO ')
					and (E1_LOJA     = @IN_LOJA     or E1_CLIENTE  = 'UNIAO ')
					and E1_EMISSAO  <= @IN_DATABASE
					and (E1_TITPAI	= @IN_PREFIXO+@IN_NUMERO+@IN_PARCELA+@IN_TIPO+@IN_CFORNCLI+@IN_LOJA)
					and D_E_L_E_T_  <> '*'
                  
				for read only
				open  CUR_SUMABAT_A
				fetch CUR_SUMABAT_A into @ValorAbat, @MoedaAbat
				
				while (@@fetch_status = 0) begin
					--Converte o saldo do movimento para a moeda do titulo
					exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output
					
					select @OUT_TOTABAT =  @OUT_TOTABAT + @ValorAbat
					fetch CUR_SUMABAT_A into @ValorAbat, @MoedaAbat
				end
				
				close      CUR_SUMABAT_A
				deallocate CUR_SUMABAT_A      
			
			end else begin
				--Query para demais banco de dados 'ORACLE.POSTGRES.DB2.INFORMIX'
				declare CUR_SUMABAT_C cursor for
				
				select E1_VALOR, E1_MOEDA
				from SE1###
				where E1_FILIAL    = @E1_FILIAL
					and E1_PREFIXO   = @IN_PREFIXO
					and E1_NUM       = @IN_NUMERO
					and E1_PARCELA   = @IN_PARCELA
					and E1_TIPO      LIKE '%-'
					and (E1_CLIENTE  = @IN_CFORNCLI or E1_CLIENTE  = 'UNIAO ')
					and (E1_LOJA     = @IN_LOJA     or E1_CLIENTE  = 'UNIAO ')
					and E1_EMISSAO  <= @IN_DATABASE
					and (RTRIM(E1_TITPAI)	= RTRIM(@IN_PREFIXO||@IN_NUMERO||@IN_PARCELA||@IN_TIPO||@IN_CFORNCLI||@IN_LOJA))
					and D_E_L_E_T_  <> '*'
				
				for read only
				open  CUR_SUMABAT_C
				fetch CUR_SUMABAT_C into @ValorAbat, @MoedaAbat
				
				while (@@fetch_status = 0) 
				begin
					--Converte o saldo do movimento para a moeda do titulo
					exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output
					
					select @OUT_TOTABAT =  @OUT_TOTABAT + @ValorAbat
					fetch CUR_SUMABAT_C into @ValorAbat, @MoedaAbat
				end
				
				close      CUR_SUMABAT_C
				deallocate CUR_SUMABAT_C
			end
		
		end else begin
			declare CUR_SUMABAT_E cursor for
			
			select SE1.E1_VALOR, SE1.E1_MOEDA
			from FK7### FK7 inner join SE1### SE1 
			on
				FK7.FK7_ALIAS = 'SE1'
				and SE1.E1_FILIAL = FK7.FK7_FILTIT
				and SE1.E1_PREFIXO = FK7.FK7_PREFIX
				and SE1.E1_NUM = FK7.FK7_NUM
				and SE1.E1_PARCELA = FK7.FK7_PARCEL
				and SE1.E1_TIPO = FK7.FK7_TIPO
				and SE1.D_E_L_E_T_ = FK7.D_E_L_E_T_ 
			where FK7.FK7_IDPAI = @IN_IDPAI
				and FK7.FK7_TIPO     LIKE '%-'
				and SE1.E1_EMISSAO <= @IN_DATABASE
				and (SE1.E1_SALDO > 0 or @IN_NOORDPAGO = '1')
				and FK7.D_E_L_E_T_ = ' '
			
			for read only
			open  CUR_SUMABAT_E
			fetch CUR_SUMABAT_E into @ValorAbat, @MoedaAbat
			
			while (@@fetch_status = 0) 
			begin
				--Converte o saldo do movimento para a moeda do titulo
				exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output
				
				select @OUT_TOTABAT = @OUT_TOTABAT + @ValorAbat
				fetch CUR_SUMABAT_E into @ValorAbat, @MoedaAbat
			end
			
			close CUR_SUMABAT_E
			deallocate CUR_SUMABAT_E    
		
		end
	end
	
	else begin
		if @IN_IDPAI = '0' begin
			if @IN_BD = '1' begin
				--Query para SQL Server
				declare CUR_SUMABAT_B cursor for
				
				select E2_VALOR, E2_MOEDA
				from SE2###
				where
					E2_FILIAL   = @E2_FILIAL
					and E2_PREFIXO  = @IN_PREFIXO  
					and E2_NUM      = @IN_NUMERO
					and E2_PARCELA  = @IN_PARCELA
					and E2_TIPO     LIKE '%-'
					and E2_FORNECE  = @IN_CFORNCLI
					and E2_LOJA     = @IN_LOJA
					and E2_EMISSAO <= @IN_DATABASE
					and (E2_TITPAI	= @IN_PREFIXO+@IN_NUMERO+@IN_PARCELA+@IN_TIPO+@IN_CFORNCLI+@IN_LOJA)
					and (E2_SALDO > 0 or @IN_NOORDPAGO = '1')
					and D_E_L_E_T_ <> '*'
				
				for read only
				open  CUR_SUMABAT_B
				fetch CUR_SUMABAT_B into @ValorAbat, @MoedaAbat
				
				while (@@fetch_status = 0) 
				begin
					--Converte o saldo do movimento para a moeda do titulo
					exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output
					select @OUT_TOTABAT = @OUT_TOTABAT + @ValorAbat
					fetch CUR_SUMABAT_B into @ValorAbat, @MoedaAbat
				end
				
				close CUR_SUMABAT_B
				deallocate CUR_SUMABAT_B
			
			end else begin
				--Query para demais banco de dados 'ORACLE.POSTGRES.DB2.INFORMIX'
				declare CUR_SUMABAT_D cursor for
				
				select E2_VALOR, E2_MOEDA
				from SE2###
				where 
					E2_FILIAL   = @E2_FILIAL
					and E2_PREFIXO  = @IN_PREFIXO  
					and E2_NUM      = @IN_NUMERO
					and E2_PARCELA  = @IN_PARCELA
					and E2_TIPO     LIKE '%-'
					and E2_FORNECE  = @IN_CFORNCLI
					and E2_LOJA     = @IN_LOJA
					and E2_EMISSAO <= @IN_DATABASE
					and (RTRIM(E2_TITPAI)	= RTRIM(@IN_PREFIXO||@IN_NUMERO||@IN_PARCELA||@IN_TIPO||@IN_CFORNCLI||@IN_LOJA))
					and (E2_SALDO > 0 or @IN_NOORDPAGO = '1')
					and D_E_L_E_T_ <> '*'
				
				for read only
				open  CUR_SUMABAT_D
				fetch CUR_SUMABAT_D into @ValorAbat, @MoedaAbat
				
				while (@@fetch_status = 0) 
				begin
				   --Converte o saldo do movimento para a moeda do titulo
				  exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output
				  
				  select @OUT_TOTABAT = @OUT_TOTABAT + @ValorAbat
				  fetch CUR_SUMABAT_D into @ValorAbat, @MoedaAbat
				end
				
				close CUR_SUMABAT_D
				deallocate CUR_SUMABAT_D
			end
		
		end	else begin
			declare CUR_SUMABAT_F cursor for
				
			select SE2.E2_VALOR, SE2.E2_MOEDA
			from FK7### FK7 inner join SE2### SE2 
			on
				FK7.FK7_ALIAS = 'SE2'
				and SE2.E2_FILIAL = FK7.FK7_FILTIT
				and SE2.E2_PREFIXO = FK7.FK7_PREFIX
				and SE2.E2_NUM = FK7.FK7_NUM
				and SE2.E2_PARCELA = FK7.FK7_PARCEL
				and SE2.E2_TIPO = FK7.FK7_TIPO
				and SE2.E2_FORNECE = FK7.FK7_CLIFOR
				and SE2.E2_LOJA = FK7.FK7_LOJA
				and SE2.D_E_L_E_T_ = FK7.D_E_L_E_T_
			where 
				FK7.FK7_IDPAI = @IN_IDPAI
				and FK7.FK7_TIPO     LIKE '%-'
				and SE2.E2_EMISSAO <= @IN_DATABASE
				and (SE2.E2_SALDO > 0 or @IN_NOORDPAGO = '1')
				and FK7.D_E_L_E_T_ = ' '
				
			for read only
			open  CUR_SUMABAT_F
			fetch CUR_SUMABAT_F into @ValorAbat, @MoedaAbat
				
			while (@@fetch_status = 0) 
			begin
				--Converte o saldo do movimento para a moeda do titulo
				exec MAT021_## @ValorAbat, @IN_DDATA, @MoedaAbat, @IN_MOEDA, @ValorAbat Output
				
				select @OUT_TOTABAT = @OUT_TOTABAT + @ValorAbat
				fetch CUR_SUMABAT_F into @ValorAbat, @MoedaAbat
			end
				
			close CUR_SUMABAT_F
			deallocate CUR_SUMABAT_F
		end
	end

  if @OUT_TOTABAT is Null select @OUT_TOTABAT = 0
end
