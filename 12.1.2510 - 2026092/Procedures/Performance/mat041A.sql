create procedure MAT041A_##
(
 @IN_FILIALCOR	  char('B1_FILIAL'),
 @IN_D2IDENTB6	  Char('D2_IDENTB6'),
 @IN_D2COD        char('D2_COD'),
 @IN_TRANSACTION  char(01),
 @OUT_RESULTADO char(01) output
)
as 

Declare @cFil_SB6   char('B6_FILIAL')
Declare @cFil_SD1   char('D1_FILIAL')
Declare @cFil_SD2   char('D2_FILIAL')
Declare @cFil_SF4   char('F4_FILIAL')

Declare @cD2_CLIENTE    char( 'D2_CLIENTE' )
declare @cD2_LOJA       char( 'D2_LOJA' )
declare @cD2_LOCAL      char( 'D2_LOCAL' )
declare @cD2_SEGUM      char( 'D2_SEGUM' )
declare @cD2_COD        char( 'D2_COD' )
declare @cD2_DOC        char( 'D2_DOC' )
declare @cD2_SERIE      char( 'D2_SERIE' )
declare @dD2_EMISSAO    char( 'D2_EMISSAO' )
declare @cD2_TIPO       char( 'D2_TIPO' )
Declare @cD2_NFORI      Char( 'D2_NFORI' )
Declare @cD2_SERIORI    Char( 'D2_SERIORI' )
Declare @cD2_ITEMORI    Char( 'D2_ITEMORI' )
Declare @cD2_TES        Char( 'D2_TES' )
Declare @cD2_UM         Char( 'D2_UM' )
Declare @cD2_NUMSEQ     Char( 'D2_NUMSEQ' )
Declare @cD2_IDENTB6    Char( 'D2_IDENTB6' )

Declare @cXB6_PODER3    Char( 'B6_PODER3' )
Declare @cXB6_UENT      Char( 'B6_UENT' )
Declare @cXB6_TPCF      Char( 'B6_TPCF' )
Declare @cXB6_TIPO      Char( 'B6_TIPO' )
Declare @cXB6_IDENT     Char( 'B6_IDENT' )
Declare @cIdentSB6      Char( 'B6_IDENT' )

declare @cF4_PODER3     char( 'F4_PODER3' )
declare @cF4_ESTOQUE	char( 'F4_ESTOQUE' )

declare @nD2_QUANT      decimal( 'D2_QUANT' )
declare @nD2_PRCVEN     decimal( 'D2_PRCVEN' )
declare @nD2_CUSTO1     decimal( 'D2_CUSTO1' )
declare @nD2_CUSTO2     decimal( 'D2_CUSTO2' )
declare @nD2_CUSTO3     decimal( 'D2_CUSTO3' )
declare @nD2_CUSTO4     decimal( 'D2_CUSTO4' )
declare @nD2_CUSTO5     decimal( 'D2_CUSTO5' )
declare @nD2_QTSEGUM    decimal( 'D2_QTSEGUM' )
declare @nD2_CUSFF1     decimal( 'D2_CUSFF1' )
declare @nD2_CUSFF2     decimal( 'D2_CUSFF2' )
declare @nD2_CUSFF3     decimal( 'D2_CUSFF3' )
declare @nD2_CUSFF4     decimal( 'D2_CUSFF4' )
declare @nD2_CUSFF5     decimal( 'D2_CUSFF5' )

declare @nB6_PRUNIT   decimal( 'B6_PRUNIT' )
Declare @nXB6_SALDO   Decimal( 'B6_SALDO' )
Declare @nXXB6_SALDO  Decimal( 'B6_SALDO' )

declare @nXB6_QUANT   decimal( 'B6_QUANT' )

declare @nXB6_CUSTO1  decimal( 'B6_CUSTO1' )
declare @nXB6_CUSTO2  decimal( 'B6_CUSTO2' )
declare @nXB6_CUSTO3  decimal( 'B6_CUSTO3' )
declare @nXB6_CUSTO4  decimal( 'B6_CUSTO4' )
declare @nXB6_CUSTO5  decimal( 'B6_CUSTO5' )

declare @nXB6_CUSFF1  decimal( 'B6_CUSFF1' )
declare @nXB6_CUSFF2  decimal( 'B6_CUSFF2' )
declare @nXB6_CUSFF3  decimal( 'B6_CUSFF3' )
declare @nXB6_CUSFF4  decimal( 'B6_CUSFF4' )
declare @nXB6_CUSFF5  decimal( 'B6_CUSFF5' )

declare @nXB6_CCOMP1  decimal( 'B6_CUSTO1' )
declare @nXB6_CCOMP2  decimal( 'B6_CUSTO2' )
declare @nXB6_CCOMP3  decimal( 'B6_CUSTO3' )
declare @nXB6_CCOMP4  decimal( 'B6_CUSTO4' )
declare @nXB6_CCOMP5  decimal( 'B6_CUSTO5' )

declare @nXB6_CFFCOM1  decimal( 'B6_CUSFF1' )
declare @nXB6_CFFCOM2  decimal( 'B6_CUSFF2' )
declare @nXB6_CFFCOM3  decimal( 'B6_CUSFF3' )
declare @nXB6_CFFCOM4  decimal( 'B6_CUSFF4' )
declare @nXB6_CFFCOM5  decimal( 'B6_CUSFF5' )

declare @iSD2_RECNO  integer
Declare @iRecCount   Integer
Declare @iRecnoSB6   Integer
Declare @cAux        Varchar(3)
Declare @nAtend      Integer
Declare @nB6_C1TOT   decimal( 'B6_CUSTO1' )
Declare @nB6_C2TOT   decimal( 'B6_CUSTO2' )
Declare @nB6_C3TOT   decimal( 'B6_CUSTO3' )
Declare @nB6_C4TOT   decimal( 'B6_CUSTO4' )
Declare @nB6_C5TOT   decimal( 'B6_CUSTO5' )
Declare @nB6_CFF1TOT decimal( 'B6_CUSFF1' )
Declare @nB6_CFF2TOT decimal( 'B6_CUSFF2' )
Declare @nB6_CFF3TOT decimal( 'B6_CUSFF3' )
Declare @nB6_CFF4TOT decimal( 'B6_CUSFF4' )
Declare @nB6_CFF5TOT decimal( 'B6_CUSFF5' )
declare @cExecutou   char(01)

begin

	select @OUT_RESULTADO = '0'
	select @cD2_COD = @IN_D2COD
	select @cD2_IDENTB6 = @IN_D2IDENTB6
	/* ------------------------------------------------------------------------------------------------------------------
		Recupera filiais
		------------------------------------------------------------------------------------------------------------------ */
	select @cAux = 'SB6'
	exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB6 OutPut
	select @cAux = 'SD2'
	exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD2 OutPut
	select @cAux = 'SF4'
	exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut
    select @cAux = 'SD1'
    exec XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD1 OutPut

	select @nXB6_CCOMP1 = 0
	select @nXB6_CCOMP2 = 0
	select @nXB6_CCOMP3 = 0
	select @nXB6_CCOMP4 = 0
	select @nXB6_CCOMP5 = 0
	select @nXB6_CFFCOM1 = 0
	select @nXB6_CFFCOM2 = 0
	select @nXB6_CFFCOM3 = 0
	select @nXB6_CFFCOM4 = 0
	select @nXB6_CFFCOM5 = 0
	   
	BEGIN
		SELECT @nXB6_CCOMP1 = Sum (SD1.D1_CUSTO), @nXB6_CCOMP2 = SUm (SD1.D1_CUSTO2) ,
		@nXB6_CCOMP3 = SUM (SD1.D1_CUSTO3), @nXB6_CCOMP4= SUM (SD1.D1_CUSTO4), @nXB6_CCOMP5 = SUM(SD1.D1_CUSTO5) ,
		@nXB6_CFFCOM1 = SUM (SD1.D1_CUSFF1), @nXB6_CFFCOM2 = SUM (SD1.D1_CUSFF2), @nXB6_CFFCOM3 = SUM(SD1.D1_CUSFF3) ,
		@nXB6_CFFCOM4 = SUM (SD1.D1_CUSFF4), @nXB6_CFFCOM5 = SUM (SD1.D1_CUSFF5)
		FROM SD1### SD1
		INNER JOIN SB6### SB6
		ON
			SB6.B6_FILIAL= @cFil_SB6 AND
			SB6.B6_IDENT = SD1.D1_IDENTB6 AND
			SB6.D_E_L_E_T_=' '
		INNER JOIN SB6### ORI
		ON
			ORI.B6_FILIAL= @cFil_SB6 AND
			ORI.B6_DOC = SD1.D1_NFORI AND
			ORI.B6_SERIE = SD1.D1_SERIORI AND
			ORI.B6_CLIFOR = SD1.D1_FORNECE AND
			ORI.B6_LOJA = SD1.D1_LOJA AND
			ORI.B6_PRODUTO = SD1.D1_COD AND
			ORI.B6_IDENT = @cD2_IDENTB6 AND
			ORI.B6_PRODUTO = @cD2_COD AND
			ORI.B6_PODER3 = 'R' AND
			ORI.D_E_L_E_T_=' '
		WHERE
			SD1.D1_FILIAL= @cFil_SD1 AND
			SD1.D1_TIPO <> '5' AND
			SD1.D_E_L_E_T_=' '
	END

	If @nXB6_CCOMP1 is null select @nXB6_CCOMP1 = 0
	If @nXB6_CCOMP2 is null select @nXB6_CCOMP2 = 0
	If @nXB6_CCOMP3 is null select @nXB6_CCOMP3 = 0
	If @nXB6_CCOMP4 is null select @nXB6_CCOMP4 = 0
	If @nXB6_CCOMP5 is null select @nXB6_CCOMP5 = 0
	If @nXB6_CFFCOM1 is null select @nXB6_CFFCOM1 = 0
	If @nXB6_CFFCOM2 is null select @nXB6_CFFCOM2 = 0
	If @nXB6_CFFCOM3 is null select @nXB6_CFFCOM3 = 0
	If @nXB6_CFFCOM4 is null select @nXB6_CFFCOM4 = 0
	If @nXB6_CFFCOM5 is null select @nXB6_CFFCOM5 = 0
	  
	declare CUR_SD2DE insensitive cursor for
	select D2_CLIENTE, D2_LOJA,	 D2_COD,    D2_LOCAL,  D2_SEGUM,  D2_DOC,    D2_SERIE,
			D2_EMISSAO, D2_QUANT,  D2_PRCVEN, D2_TES,    F4_PODER3, D2_UM,     D2_QTSEGUM,
			D2_IDENTB6, D2_NUMSEQ, D2_CUSTO1, D2_CUSTO2, D2_CUSTO3, D2_CUSTO4, D2_CUSTO5,
			D2_CUSFF1,  D2_CUSFF2, D2_CUSFF3, D2_CUSFF4, D2_CUSFF5, D2_TIPO,   F4_ESTOQUE,
			SD2.R_E_C_N_O_
		from SD2### SD2 (nolock), SF4### SF4 (nolock)
	where D2_FILIAL      = @cFil_SD2
		and SD2.D2_COD     = @cD2_COD
		and F4_FILIAL      = @cFil_SF4
		and F4_PODER3      = 'D'
		and F4_CODIGO      = D2_TES
		and SD2.D_E_L_E_T_ = ' '
		and SF4.D_E_L_E_T_ = ' '
		and SD2.D2_IDENTB6 = @cD2_IDENTB6
		   
	for read only
	/* ------------------------------------------------------------------------------------------------------------------
		Abrindo e movimentando-se pelo Cursor
		------------------------------------------------------------------------------------------------------------------ */
	open CUR_SD2DE

	fetch CUR_SD2DE into @cD2_CLIENTE, @cD2_LOJA, @cD2_COD,    @cD2_LOCAL,  @cD2_SEGUM,  @cD2_DOC,    @cD2_SERIE,
						@dD2_EMISSAO, @nD2_QUANT,  @nD2_PRCVEN, @cD2_TES,    @cF4_PODER3, @cD2_UM,     @nD2_QTSEGUM,
						@cD2_IDENTB6, @cD2_NUMSEQ, @nD2_CUSTO1, @nD2_CUSTO2, @nD2_CUSTO3, @nD2_CUSTO4, @nD2_CUSTO5,
						@nD2_CUSFF1,  @nD2_CUSFF2, @nD2_CUSFF3, @nD2_CUSFF4, @nD2_CUSFF5, @cD2_TIPO,   @cF4_ESTOQUE,
						@iSD2_RECNO

		while @@Fetch_Status = 0 begin
			select @cXB6_TPCF   = ''
			select @cXB6_TIPO   = ''
			select @cXB6_IDENT  = ''
			select @cXB6_PODER3 = ''
			select @cXB6_UENT   = ''
			select @cIdentSB6   = ''
			select @nXB6_SALDO  = 0
			select @nXXB6_SALDO = 0
			select @nXB6_QUANT  = 0
			select @nXB6_CUSTO1 = 0
			select @nXB6_CUSTO2 = 0
			select @nXB6_CUSTO3 = 0
			select @nXB6_CUSTO4 = 0
			select @nXB6_CUSTO5 = 0
			select @nXB6_CUSFF1 = 0
			select @nXB6_CUSFF2 = 0
			select @nXB6_CUSFF3 = 0
			select @nXB6_CUSFF4 = 0
			select @nXB6_CUSFF5 = 0

			/* ----------------------------------------------------------------------------------------------
				Verifica se existe no SB6
				---------------------------------------------------------------------------------------------- */
			select @iRecnoSB6  = null
			select @iRecnoSB6  = MIN(R_E_C_N_O_)
				from SB6###
				where B6_FILIAL  = @cFil_SB6
				and B6_IDENT   = @cD2_IDENTB6
				and B6_PRODUTO = @cD2_COD
				and D_E_L_E_T_ = ' '

			select @nAtend    = 0
			select @nB6_C1TOT = 0
			select @nB6_C2TOT = 0
			select @nB6_C3TOT = 0
			select @nB6_C4TOT = 0
			select @nB6_C5TOT = 0
			select @nB6_CFF1TOT = 0
			select @nB6_CFF2TOT = 0
			select @nB6_CFF3TOT = 0
			select @nB6_CFF4TOT = 0
			select @nB6_CFF5TOT = 0
			If @iRecnoSB6 is not null begin
				select @cXB6_IDENT = B6_IDENT, @cXB6_PODER3 = B6_PODER3,
						@nXB6_SALDO = B6_SALDO, @cXB6_UENT = B6_UENT,
						@nXB6_QUANT = B6_QUANT,
						@nXB6_CUSTO1 = B6_CUSTO1, @nXB6_CUSTO2 = B6_CUSTO2,
						@nXB6_CUSTO3 = B6_CUSTO3, @nXB6_CUSTO4 = B6_CUSTO4,
						@nXB6_CUSTO5 = B6_CUSTO5, @nXB6_CUSFF1 = B6_CUSFF1,
						@nXB6_CUSFF2 = B6_CUSFF2, @nXB6_CUSFF3 = B6_CUSFF3,
						@nXB6_CUSFF4 = B6_CUSFF4, @nXB6_CUSFF5 = B6_CUSFF5
				from SB6###
				where R_E_C_N_O_ = @iRecnoSB6

				/* ----------------------------------------------------------------------------------------------
				Tratamento p/ gravacao do B6_TIPO
				---------------------------------------------------------------------------------------------- */
				If @cF4_PODER3 = 'R' select @cXB6_TIPO = 'E'
				else select @cXB6_TIPO = 'D'
				/* ----------------------------------------------------------------------------------------------
				Tratamento p/ gravacao do B6_TPCF
				---------------------------------------------------------------------------------------------- */
				If @cD2_TIPO = 'B' select @cXB6_TPCF = 'F'
				else If @cD2_TIPO = 'N' select @cXB6_TPCF = 'C'
				/* ----------------------------------------------------------------------------------------------
				Gravacao do saldo - SB6
				---------------------------------------------------------------------------------------------- */
				select @cIdentSB6 = @cXB6_IDENT
				If @cXB6_PODER3 = 'R' begin
					##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
					UpDate SB6###
						Set B6_SALDO = ( @nXB6_SALDO - @nD2_QUANT)
						Where R_E_C_N_O_ = @iRecnoSB6
					##CHECK_TRANSACTION_COMMIT
					select @nAtend    = 0
					select @nB6_C1TOT = 0
					select @nB6_C2TOT = 0
					select @nB6_C3TOT = 0
					select @nB6_C4TOT = 0
					select @nB6_C5TOT = 0
					select @nB6_CFF1TOT = 0
					select @nB6_CFF2TOT = 0
					select @nB6_CFF3TOT = 0
					select @nB6_CFF4TOT = 0
					select @nB6_CFF5TOT = 0
					/* -------------------------------------------------------------------
						@nXXB6_SALDO - Auxiliar
					---------------------------------------------------------------------- */
					Select @nXXB6_SALDO = ( @nXB6_SALDO - @nD2_QUANT)
					If @nXXB6_SALDO <= 0 begin
						##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
						UpDate SB6###
							Set B6_ATEND = 'S'
							Where R_E_C_N_O_ = @iRecnoSB6
						##CHECK_TRANSACTION_COMMIT
						/*
						Tratamento para resgatar custo total já devolvido
						*/
						select @nAtend = 1
						Select @nB6_C1TOT = Sum(B6_CUSTO1), @nB6_C2TOT = Sum(B6_CUSTO2), 
								@nB6_C3TOT = Sum(B6_CUSTO3), @nB6_C4TOT = Sum(B6_CUSTO4), 
								@nB6_C5TOT = Sum(B6_CUSTO5), @nB6_CFF1TOT = Sum(B6_CUSFF1), 
								@nB6_CFF2TOT = Sum(B6_CUSFF2), @nB6_CFF3TOT = Sum(B6_CUSFF3), 
								@nB6_CFF4TOT = Sum(B6_CUSFF4), @nB6_CFF5TOT = Sum(B6_CUSFF5)
						From SB6###
						Where B6_FILIAL  = @cFil_SB6
						And B6_IDENT   = @cD2_IDENTB6
						And B6_PRODUTO = @cD2_COD
						And B6_PODER3  = 'D'
						And D_E_L_E_T_ = ' '
							  
						select @nB6_C1TOT = isnull(@nB6_C1TOT, 0)
						select @nB6_C2TOT = isnull(@nB6_C2TOT, 0)
						select @nB6_C3TOT = isnull(@nB6_C3TOT, 0)
						select @nB6_C4TOT = isnull(@nB6_C4TOT, 0)
						select @nB6_C5TOT = isnull(@nB6_C5TOT, 0)
						select @nB6_CFF1TOT = isnull(@nB6_CFF1TOT, 0)
						select @nB6_CFF2TOT = isnull(@nB6_CFF2TOT, 0)
						select @nB6_CFF3TOT = isnull(@nB6_CFF3TOT, 0)
						select @nB6_CFF4TOT = isnull(@nB6_CFF4TOT, 0)
						select @nB6_CFF5TOT = isnull(@nB6_CFF5TOT, 0)

					end
					If @cXB6_UENT < @dD2_EMISSAO begin
						##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
						UpDate SB6###
							Set B6_UENT = @dD2_EMISSAO
							Where R_E_C_N_O_ = @iRecnoSB6
						##CHECK_TRANSACTION_COMMIT
					end
				end
				/* ---------------------------------------------------------------------------------------------
					Insercao no SB6
					--------------------------------------------------------------------------------------------- */
				if @cIdentSB6 <> ' ' begin

					// Obtendo os custos para a movimentacao
					if @nXB6_SALDO < @nD2_QUANT begin
						select @nD2_QUANT = @nXB6_SALDO
					end
						   

					If @nAtend = 1
						Begin
						select @nD2_CUSTO1 = @nXB6_CUSTO1 + @nXB6_CCOMP1 - @nB6_C1TOT
						select @nD2_CUSTO2 = @nXB6_CUSTO2 + @nXB6_CCOMP2 - @nB6_C2TOT
						select @nD2_CUSTO3 = @nXB6_CUSTO3 + @nXB6_CCOMP3 - @nB6_C3TOT
						select @nD2_CUSTO4 = @nXB6_CUSTO4 + @nXB6_CCOMP4 - @nB6_C4TOT
						select @nD2_CUSTO5 = @nXB6_CUSTO5 + @nXB6_CCOMP5 - @nB6_C5TOT

						select @nD2_CUSFF1 = @nXB6_CUSFF1 + @nXB6_CFFCOM1 - @nB6_CFF1TOT
						select @nD2_CUSFF2 = @nXB6_CUSFF2 + @nXB6_CFFCOM2 - @nB6_CFF2TOT
						select @nD2_CUSFF3 = @nXB6_CUSFF3 + @nXB6_CFFCOM3 - @nB6_CFF3TOT
						select @nD2_CUSFF4 = @nXB6_CUSFF4 + @nXB6_CFFCOM4 - @nB6_CFF4TOT
						select @nD2_CUSFF5 = @nXB6_CUSFF5 + @nXB6_CFFCOM5 - @nB6_CFF5TOT
						End
					Else
						Begin
						select @nD2_CUSTO1 = (@nXB6_CUSTO1  + @nXB6_CCOMP1) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSTO2 = (@nXB6_CUSTO2  + @nXB6_CCOMP2) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSTO3 = (@nXB6_CUSTO3  + @nXB6_CCOMP3) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSTO4 = (@nXB6_CUSTO4  + @nXB6_CCOMP4) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSTO5 = (@nXB6_CUSTO5  + @nXB6_CCOMP5) * (@nD2_QUANT / @nXB6_QUANT)

						select @nD2_CUSFF1 = (@nXB6_CUSFF1  + @nXB6_CFFCOM1) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSFF2 = (@nXB6_CUSFF2  + @nXB6_CFFCOM2) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSFF3 = (@nXB6_CUSFF3  + @nXB6_CFFCOM3) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSFF4 = (@nXB6_CUSFF4  + @nXB6_CFFCOM4) * (@nD2_QUANT / @nXB6_QUANT)
						select @nD2_CUSFF5 = (@nXB6_CUSFF5  + @nXB6_CFFCOM5) * (@nD2_QUANT / @nXB6_QUANT)
						End

					select @iRecnoSB6 = NULL
						   
					select @iRecnoSB6 = Max(R_E_C_N_O_)
						from SB6###
						   
					if (@iRecnoSB6 is null or @iRecnoSB6 = 0) select  @iRecnoSB6 = 1
					else select @iRecnoSB6 = @iRecnoSB6 + 1

					IF @cF4_PODER3 = 'D'
					BEGIN
						select @nB6_PRUNIT  = @nD2_PRCVEN
					END
					ELSE
					BEGIN
						select @nB6_PRUNIT = B6_PRUNIT
						from SB6###
						where B6_FILIAL = @cFil_SB6
						and B6_IDENT = @cIdentSB6
						and B6_PRODUTO = @cD2_COD
						and B6_PODER3 = 'R'
						and D_E_L_E_T_= ' '
					END
					##TRATARECNO @iRecnoSB6\
					##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
					insert into SB6### ( B6_FILIAL,    B6_CLIFOR,    B6_LOJA,    B6_PRODUTO,  B6_LOCAL,  B6_SEGUM,
										B6_DOC,       B6_SERIE,     B6_EMISSAO, B6_QUANT,    B6_PRUNIT, B6_TES,
										B6_TIPO,      B6_DTDIGIT,   B6_UM,      B6_QTSEGUM,  B6_IDENT,  B6_CUSTO1,
										B6_CUSTO2,    B6_CUSTO3,    B6_CUSTO4,  B6_CUSTO5,   B6_CUSFF1, B6_CUSFF2,
										B6_CUSFF3,    B6_CUSFF4,    B6_CUSFF5,  B6_PODER3,   B6_UENT,   B6_TPCF,
										B6_ESTOQUE,   R_E_C_N_O_ )
								values ( @cFil_SB6,    @cD2_CLIENTE, @cD2_LOJA,    @cD2_COD,     @cD2_LOCAL,	@cD2_SEGUM,
										@cD2_DOC,     @cD2_SERIE,   @dD2_EMISSAO, @nD2_QUANT,   @nB6_PRUNIT, @cD2_TES,
										@cXB6_TIPO,   @dD2_EMISSAO, @cD2_UM,      @nD2_QTSEGUM, @cIdentSB6,  @nD2_CUSTO1,
										@nD2_CUSTO2,  @nD2_CUSTO3,  @nD2_CUSTO4,  @nD2_CUSTO5,  @nD2_CUSFF1, @nD2_CUSFF2,
										@nD2_CUSFF3,  @nD2_CUSFF4,  @nD2_CUSFF5,  'D',         '        ',   @cXB6_TPCF,
										@cF4_ESTOQUE , @iRecnoSB6 )
					##CHECK_TRANSACTION_COMMIT
					##FIMTRATARECNO

					exec M216SB6GRV_## @IN_FILIALCOR , @iRecnoSB6 , @cExecutou output

					end

				end

				fetch CUR_SD2DE into @cD2_CLIENTE, @cD2_LOJA,   @cD2_COD,    @cD2_LOCAL,  @cD2_SEGUM,  @cD2_DOC,    @cD2_SERIE,
									@dD2_EMISSAO, @nD2_QUANT,  @nD2_PRCVEN, @cD2_TES,    @cF4_PODER3, @cD2_UM,     @nD2_QTSEGUM,
									@cD2_IDENTB6, @cD2_NUMSEQ, @nD2_CUSTO1, @nD2_CUSTO2, @nD2_CUSTO3, @nD2_CUSTO4, @nD2_CUSTO5,
									@nD2_CUSFF1,  @nD2_CUSFF2, @nD2_CUSFF3, @nD2_CUSFF4, @nD2_CUSFF5, @cD2_TIPO,   @cF4_ESTOQUE,
									@iSD2_RECNO
		end

		close CUR_SD2DE
		deallocate CUR_SD2DE

	select @OUT_RESULTADO = '1'

end
