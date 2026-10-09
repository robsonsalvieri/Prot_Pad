-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 21/03/2025
-- Description:	Geracao dos titulos Pagar Realizado
-- =============================================
CREATE PROCEDURE FIN009_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer,
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA2  Integer,
	@IN_TAMSEV  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_COMPANIA char('##COMPANIA'),
	@IN_COD_UNID char('##COD_UNID'),
	@IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId Char( 32 ),
	@IN_DTINI  char('F7I_EMIS1'),
	@IN_DTFIM  char('F7I_EMIS1'),
	@IN_FULL Char( 1 ),
	@IN_TRANSACTION Char( 1 ),
	@DecCONVBS Integer,
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@OUT_RESULTADO Char(1) OutPut
)
AS

DECLARE @maxStagingCounter 	Datetime
DECLARE @delTransactTime char(26)
DECLARE @cStamp char(26)

Begin

	Select @cStamp = ( SELECT MIN(F7J_STAMP) FROM F7J### F7J WHERE F7J.F7J_ALIAS = 'CPR' )
	Select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)		

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

	--NF 	
	exec FIN009A_## @IN_TAMEMP,	@IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED, @IN_TAMSX5, @IN_TAMSA2, 
					@IN_TAMSEV, @IN_GROUPEMPRESA, @IN_COMPANIA,	@IN_COD_UNID, @IN_COD_FIL, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM,
					@IN_FULL, @IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut
					
	--PA
	exec FIN009B_## @IN_TAMEMP,	@IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED, @IN_TAMSX5, @IN_TAMSA2, 
					@IN_TAMSEV, @IN_GROUPEMPRESA, @IN_COMPANIA,	@IN_COD_UNID, @IN_COD_FIL, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM,
					@IN_FULL, @IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut
		
	--BX LOTE			
	exec FIN009C_## @IN_TAMEMP,	@IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED, @IN_TAMSX5, @IN_TAMSA2, 
					@IN_TAMSEV, @IN_GROUPEMPRESA, @IN_COMPANIA,	@IN_COD_UNID, @IN_COD_FIL, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM,
					@IN_FULL, @IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut
	
	DELETE FROM
		F7J###
	WHERE F7J_ALIAS = 'CPR'
	AND F7J_STAMP < @delTransactTime
	AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM
				F7J###
			WHERE
				F7J_ALIAS = 'CPR'
		)	

	select @OUT_RESULTADO = '1'	
End