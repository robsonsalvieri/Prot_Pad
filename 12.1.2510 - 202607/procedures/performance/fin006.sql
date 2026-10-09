-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 05/02/2025
-- Description:	Geracao dos titulos a receber previsto
-- =============================================
CREATE PROCEDURE FIN006_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA1  Integer,
	@IN_TAMFRV  Integer,
	@IN_TAMSE1  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
    @IN_COMPANIA char('##COMPANIA'),
    @IN_COD_UNID char('##COD_UNID'),
    @IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
	@IN_FULL char(1),
	@IN_CARTEIRAD char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS integer,
	@IN_IDORIGEM char(32),
	@IN_LOTEPROC Char(6),
	@IN_DTCORTE char('F7I_EMIS1'),
	@OUT_RESULTADO Char(1) OutPut
) AS

DECLARE @maxStagingCounter	Datetime
DECLARE @delTransactTime	char(26)
DECLARE @cStamp				char('F7J_STAMP')
DECLARE @param_DTINI		char('F7I_EMIS1')
DECLARE @param_DTFIM		char('F7I_EMIS1')
DECLARE @param_DTCORTE		char('F7I_EMIS1')

Begin

	Select @cStamp = (SELECT MIN(F7J_STAMP) FROM F7J### F7J WHERE F7J.F7J_ALIAS = 'CRP')
	Select @delTransactTime = CONVERT(CHAR(26), DATEADD(HOUR, -1, GETUTCDATE()), 121)
	select @param_DTINI = @IN_DTINI
	Select @param_DTFIM = @IN_DTFIM
	select @param_DTCORTE = @IN_DTCORTE

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

	--SEM RATEIO FIN006A 
	exec FIN006A_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL, @IN_TAMSED,	
					@IN_TAMCT1, @IN_TAMSX5,	@IN_TAMSA1, @IN_TAMFRV,
					@IN_GROUPEMPRESA, @IN_COMPANIA,	@IN_COD_UNID, @IN_COD_FIL, 
					@IN_mdmTenantId, @param_DTINI, @param_DTFIM, @IN_FULL, @IN_CARTEIRAD,
					@IN_TRANSACTION, @DecCONVBS, @maxStagingCounter, @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC, @param_DTCORTE, @OUT_RESULTADO OutPut

	--COM RATEIO FIN006B 
	exec FIN006B_## @IN_TAMEMP, @IN_TAMUNIT, @IN_TAMFIL,	
					@IN_TAMSED,	@IN_TAMCT1, @IN_TAMSX5, @IN_TAMSA1,	@IN_TAMFRV,	@IN_TAMSE1,	
					@IN_GROUPEMPRESA, @IN_COMPANIA,	@IN_COD_UNID, @IN_COD_FIL, 
					@IN_mdmTenantId, @param_DTINI, @param_DTFIM, @IN_FULL, @IN_CARTEIRAD,
					@IN_TRANSACTION, @DecCONVBS, @maxStagingCounter,  @delTransactTime, @IN_IDORIGEM, @IN_LOTEPROC, @param_DTCORTE, @OUT_RESULTADO OutPut

	DELETE FROM F7J###
		WHERE F7J_ALIAS = 'CRP' AND F7J_STAMP < @delTransactTime AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CRP')

	select @OUT_RESULTADO = '1'		
End	