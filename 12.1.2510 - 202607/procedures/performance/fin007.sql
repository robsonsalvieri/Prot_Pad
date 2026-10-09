-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 24/02/2025
-- Description:	Geração dos titulos a Pagar previsto
-- =============================================
CREATE PROCEDURE FIN007_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA2  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_COMPANIA char('##COMPANIA'),
	@IN_COD_UNID char('##COD_UNID'),
	@IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
    @IN_FULL char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS Integer,
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@IN_DTCORTE char('F7I_EMIS1'),
	@OUT_RESULTADO Char(1) OutPut 
) AS

declare @param_DTINI char('F7I_EMIS1')
declare @param_DTFIM char('F7I_EMIS1')
declare @param_DTCORTE char('F7I_EMIS1')
declare @maxStagingCounter Datetime
declare @delTransactTime char('F7I_STAMP')
declare @cStamp char('F7I_STAMP')
declare @ExistRatio Integer
DECLARE @IS_COMRAT char(1)

Begin

	select @param_DTINI = @IN_DTINI
	select @param_DTFIM = @IN_DTFIM
	select @param_DTCORTE = @IN_DTCORTE
	
	Select @cStamp = (
						SELECT MIN(F7J_STAMP) 
							FROM F7J### F7J
							WHERE 
								F7J.F7J_ALIAS = 'CPP'
					)

	Select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)
	select @ExistRatio = 0
	select @IS_COMRAT = '1'

	If @cStamp is not null 
		Begin
			If @cStamp > @delTransactTime
				Begin
					Select @maxStagingCounter  = convert(datetime, @delTransactTime ,121 ) 
				End
			Else
				Begin
					Select @maxStagingCounter  = convert(datetime, @cStamp,121 ) 
				End
		End

	If @IN_FULL <> 'S'
		BEGIN
			Select @ExistRatio = (SELECT COUNT ( * ) FROM SE2### SE2 WHERE SE2.S_T_A_M_P_ > @maxStagingCounter and SE2.E2_MULTNAT = @IS_COMRAT)
		END

	--FIN007A - SEM RATEIO DE NATUREZA
	exec FIN007A_##	@IN_TAMEMP,	@IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED, @IN_TAMCT1,
		@IN_TAMSX5,	@IN_TAMSA2,	@IN_GROUPEMPRESA, @IN_COMPANIA,
		@IN_COD_UNID, @IN_COD_FIL, @IN_mdmTenantId, @param_DTINI, @param_DTFIM, @IN_FULL,
		@IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC, @param_DTCORTE,
		@OUT_RESULTADO OutPut 

	If @ExistRatio > 0 or @IN_FULL = 'S'
		Begin
			--FIN007B - COM RATEIO DE NATUREZA
			exec FIN007B_##	@IN_TAMEMP,	@IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED, @IN_TAMCT1,
				@IN_TAMSX5,	@IN_TAMSA2,	@IN_GROUPEMPRESA, @IN_COMPANIA,
				@IN_COD_UNID, @IN_COD_FIL, @IN_mdmTenantId, @param_DTINI, @param_DTFIM, @IN_FULL,
				@IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC, @param_DTCORTE,
				@OUT_RESULTADO OutPut 
		End

	DELETE FROM 
		F7J###
    WHERE F7J_STAMP < @delTransactTime 
		AND F7J_ALIAS = 'CPP'
		AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CPP'
		)

	select @OUT_RESULTADO = '1'
	
End