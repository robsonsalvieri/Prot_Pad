Create procedure CTB196_##
(
@IN_RECMIN       Integer ,
@IN_RECMAX       Integer ,
@IN_TRANSACTION  Char(01),
@OUT_RESULTADO   Char(01) OutPut
)
as

/* ------------------------------------------------------------------------------------
Versão          - <v> Protheus P12 </v>
Assinatura      - <a>  001 </a>
Procedure       -     Reprocessamento SigaCTB
	Descricao       - <d> Zera a fila </d>
	Funcao do Siga  -     CtbZeraTod()
	Fonte Microsiga - <s> CTBA193.PRW </s>
	Entrada         - <ri> @IN_RECMIN       - Recno Inicial da CQA
	@IN_RECMAX       - Recno Final da CQA
	</ri>
	Saida           - <ro> @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
	Responsavel :     <r> Alvaro Camillo Neto	</r>
	Data        :     19/09/2003
	-------------------------------------------------------------------------------------- */
	declare @iMinRecno    integer
	declare @iMaxRecno    integer
	declare @iMaxAux 	  Integer
    declare @cAux         char(03)

	begin
		select @cAux = 'CQA'      
		/* -------------------------------------------------------------------------
		Zera as tabelas de fila CQA
		-------------------------------------------------------------------------*/
		select @iMinRecno = @IN_RECMIN
		select @iMaxRecno = @IN_RECMAX
		select @iMaxAux = 1024
			
		if @iMinRecno != 0 begin
			While ( @iMinRecno <= @iMaxRecno ) begin
				/* Exclui em blocos para evitar deadlock no begin transaction*/
				if @iMinRecno + @iMaxAux >= @iMaxRecno  begin
					select @iMaxAux = (@iMaxRecno - @iMinRecno) + 1
				end
				
				##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
					/* Exclui fisicamente */
					Delete From CQA###			      
					where R_E_C_N_O_ between @iMinRecno and @iMinRecno + @iMaxAux -1 and D_E_L_E_T_ = ' '
				##CHECK_TRANSACTION_COMMIT

				select @iMinRecno = @iMinRecno + @iMaxAux
			end
		end
		select @OUT_RESULTADO = '1'
    end

	


