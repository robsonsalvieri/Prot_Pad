-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 21/03/2025
-- Description:	Geracao dos titulos Receber Realizado
-- =============================================
CREATE PROCEDURE FIN008_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED Integer,
	@IN_TAMSX5 Integer,
	@IN_TAMSA1 Integer,
	@IN_TAMSEV Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
	@IN_mdmTenantId char(32),
	@IN_DTINI 		char('F7I_EMIS1'),
	@IN_DTFIM 		char('F7I_EMIS1'),
    @IN_FULL char(1),
	@IN_TRANSACTION Char(1),
	@DecCONVBS integer,
	@IN_BXLOTE Char(1),
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@OUT_RESULTADO Char(1) OutPut)
AS

DECLARE @maxStagingCounter 	Datetime
DECLARE @delTransactTime 	char(26)
DECLARE @cStamp 			char('F7J_STAMP')
DECLARE @BXLOTE 			Char(1)

Begin

	Select @BXLOTE = @IN_BXLOTE

	select @cStamp = (
						SELECT MIN (F7J_STAMP )
							FROM F7J### F7J
							WHERE 
								F7J.F7J_ALIAS = 'CRR' 
					)

	select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)

	If @cStamp is not null 
		Begin
			If @cStamp > @delTransactTime	
				Begin
					select @maxStagingCounter  = convert(datetime, @delTransactTime ,121 ) 
				End
			Else
				Begin
					select @maxStagingCounter  = convert(datetime, @cStamp,121 ) 
				End
		End

	--NF FIN008A
	exec FIN008A_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL,	@IN_TAMSED,	
					@IN_TAMSX5,	@IN_TAMSA1,	@IN_TAMSEV,	
					@IN_GROUPEMPRESA, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM, @IN_FULL, 
					@IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut

	--RA FIN008B	
	exec FIN008B_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL,	
					@IN_TAMSED,	@IN_TAMSA1,	@IN_TAMSEV,	
					@IN_GROUPEMPRESA, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM, @IN_FULL, @IN_TRANSACTION, @DecCONVBS, 
					@maxStagingCounter,  @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut
		
	--SEM FKA FIN008C
	If @BXLOTE = '1'
		Begin
			exec FIN008C_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL, 
					@IN_TAMSED, @IN_TAMSX5,	@IN_TAMSA1,	@IN_TAMSEV,	
					@IN_GROUPEMPRESA, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM,	@IN_FULL, @IN_TRANSACTION, 
					@DecCONVBS, @maxStagingCounter,  @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut
		End			
	
	--FWI FIN008D
	exec FIN008D_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED,	
					@IN_TAMSX5,	@IN_TAMSA1,	@IN_TAMSEV,	
					@IN_GROUPEMPRESA, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM, @IN_FULL, @IN_TRANSACTION, 
					@DecCONVBS, @maxStagingCounter,  @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut
					
	--LJ FIN008E
	exec FIN008E_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED,	
					@IN_TAMSX5,	@IN_TAMSA1,	@IN_TAMSEV,	
					@IN_GROUPEMPRESA, @IN_mdmTenantId, @IN_DTINI, @IN_DTFIM, @IN_FULL, @IN_TRANSACTION, 
					@DecCONVBS, @maxStagingCounter,  @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC,
					@OUT_RESULTADO OutPut

	DELETE FROM F7J###
		WHERE F7J_ALIAS = 'CRR' AND F7J_STAMP < @delTransactTime AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CRR')

	select @OUT_RESULTADO = '1'		
End	