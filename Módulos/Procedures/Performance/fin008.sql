-- =============================================
-- Author:		Luiz Gustavo Romeiro de Jesus
-- Create date: 21/03/2025
-- Description:	Geracao dos titulos Receber Realizado
-- =============================================
CREATE PROCEDURE FIN008_## (
	@IN_TAMEMP Integer,
	@IN_TAMUNIT Integer, 
	@IN_TAMFIL Integer,
	@IN_TAMSA6  Integer,
	@IN_TAMSED  Integer,
	@IN_TAMCT1  Integer,
	@IN_TAMCTT  Integer,
	@IN_TAMSX5  Integer,
	@IN_TAMSA1  Integer,
	@IN_TAMFRV  Integer,
	@IN_TAMSEV  Integer,
	@IN_GROUPEMPRESA char('##GROUPEMPRESA'),
    @IN_COMPANIA char('##COMPANIA'),
    @IN_COD_UNID char('##COD_UNID'),
    @IN_COD_FIL char('##COD_FIL'),
	@IN_mdmTenantId char(32),
	@IN_DTINI char('F7I_EMIS1'),
	@IN_DTFIM char('F7I_EMIS1'),
    @IN_DEL char(1),
	@IN_CARTEIRAD char(1),
	@IN_TRANSACTION  Char(1),
	@DecCONVBS integer,
	@IN_BXLOTE Char(1),
	@OUT_RESULTADO Char(1) OutPut )
AS

--Declaracao de variaveis
declare @N_TAMTOTAL Integer
DECLARE @F7I_ORIGIN Char('F7I_ORIGIN')
DECLARE @cF7I_STAMP	Char('F7I_STAMP')
DECLARE @F7I_STAMP  Char('F7I_STAMP')
DECLARE @F7I_EXTCDH Char('F7I_EXTCDH')
DECLARE @F7I_EXTCDD Char('F7I_EXTCDD')
DECLARE @F7I_GRPEMP Char('F7I_GRPEMP')
DECLARE @F7I_EMPR Char('F7I_EMPR')
DECLARE @F7I_UNID Char('F7I_UNID')
DECLARE @F7I_FILNEG Char('F7I_FILNEG')
DECLARE @F7I_ORGSYT Char('F7I_ORGSYT')
DECLARE @F7I_EMISSA Char('F7I_EMISSA')
DECLARE @F7I_EMIS1 Char('F7I_EMIS1')
DECLARE @F7I_HIST Char('F7I_HIST')
DECLARE @F7I_TIPO Char('F7I_TIPO')
DECLARE @F7I_TIPDSC Char('F7I_TIPDSC')
DECLARE @F7I_PREFIX Char('F7I_PREFIX')
DECLARE @F7I_NUM Char('F7I_NUM')
DECLARE @F7I_PARCEL Char('F7I_PARCEL')
DECLARE @F7I_MOEDA Float
DECLARE @F7I_DSCMDA Char('F7I_DSCMDA')
DECLARE @F7I_MOEDB Float
DECLARE @F7I_DSCMDB Char('F7I_DSCMDB')
DECLARE @F7I_VENCTO Char('F7I_VENCTO')
DECLARE @F7I_VENCRE Char('F7I_VENCRE')
DECLARE @F7I_DTPGTO Char('F7I_DTPGTO')
DECLARE @F7I_TPEVNT Char('F7I_TPEVNT')
DECLARE @F7I_BANCO Char('F7I_BANCO')
DECLARE @F7I_AGENCI Char('F7I_AGENCI')
DECLARE @F7I_CONTA Char('F7I_CONTA')
DECLARE @F7I_FLBENF Char('F7I_FLBENF')
DECLARE @F7I_CDBENF Char('F7I_CDBENF')
DECLARE @F7I_LJBENF Char('F7I_LJBENF')
DECLARE @F7I_NBENEF Char('A1_NOME')
DECLARE @F7I_TPBENF Char('F7I_TPBENF')
DECLARE @F7I_ORBENF Char('F7I_ORBENF')
DECLARE @F7I_MOVIM Char('F7I_MOVIM')
DECLARE @F7I_DSCMOV Char('F7I_DSCMOV')
DECLARE @F7I_IDMOV Char('F7I_IDMOV')
DECLARE @F7I_SALDO Float
DECLARE @F7I_VLPROP Float
DECLARE @F7I_VLCRUZ Float
DECLARE @F7I_CONVBS Float
DECLARE @F7I_FXRTBS Char('F7I_FXRTBS')
DECLARE @F7I_VLRCNT Float
DECLARE @F7I_CONVCT Float
DECLARE @F7I_FXRTCT Char('F7I_FXRTCT')
DECLARE @F7I_CNTCTB Char('F7I_CNTCTB')
DECLARE @F7I_DSCCTB Char('F7I_DSCCTB')
DECLARE @F7I_NATCTA Char('F7I_NATCTA')
DECLARE @F7I_CCUSTO Char('F7I_CCUSTO')
DECLARE @F7I_DSCCCT Char('F7I_DSCCCT')
DECLARE @F7I_INTEGR Char('F7I_INTEGR')
DECLARE @F7I_DTDISP Char('F7I_DTDISP')
DECLARE @F7I_NATURE Char('F7I_NATURE')
DECLARE @F7I_NATRAT Char('F7I_NATRAT')
DECLARE @F7I_CCDRAT Char('F7I_CCDRAT')
DECLARE @F7I_DEBITO Char('F7I_DEBITO')
DECLARE @F7I_CCD Char('F7I_CCD')
DECLARE @F7I_CCC Char('F7I_CCC')
DECLARE @F7I_ITEMCT Char('F7I_ITEMCT')
DECLARE @F7I_ITEMD Char('F7I_ITEMD')
DECLARE @F7I_ITEMC Char('F7I_ITEMC')
DECLARE @F7I_CLVL Char('F7I_CLVL')
DECLARE @F7I_CLVLDB Char('F7I_CLVLDB')
DECLARE @F7I_CLVLCR Char('F7I_CLVLCR')
DECLARE @F7I_NUMBOR Char('F7I_NUMBOR')
DECLARE @F7I_HISTOR Char('F7I_HISTOR')
DECLARE @F7I_CREDIT Char('F7I_CREDIT')
DECLARE @filialCTT Char('CTT_FILIAL')
declare @filialCT1 char('CT1_FILIAL')
DECLARE @DTINI char('F7I_EMIS1')
DECLARE @DTFIM char('F7I_EMIS1')
DECLARE @BXLOTE Char(1)
DECLARE @COMPANIA char('##COMPANIA')
DECLARE @COD_UNID char('##COD_UNID')
DECLARE @COD_FIL char('##COD_FIL')

-- Variaveis Cursor
DECLARE @EZ_MSUID Char('EZ_MSUID')
DECLARE @EV_MSUID Char('EV_MSUID')
DECLARE @E1_FILORIG Char('E1_FILORIG')
DECLARE @E1_BAIXA Char('E1_BAIXA')
DECLARE @E1_SALDO Float
DECLARE @E1_TIPO Char('E1_TIPO')
DECLARE @E1_VLCRUZ Float
DECLARE @E1_VALOR Float
DECLARE @CT1_CONTA Char('CT1_CONTA')
DECLARE @FK7_IDDOC Char('FK7_IDDOC')
DECLARE @FK1_TPDOC Char('FK1_TPDOC')
DECLARE @E1_LOTE Char('E1_LOTE')
DECLARE @FK1_IDFK1 Char('FK1_IDFK1')
DECLARE @FK5_RECPAG Char('FK5_RECPAG')
DECLARE @FK1_VALOR Float
DECLARE @E1_MOEDA Float
DECLARE @A6_MOEDA Float
DECLARE @FK5_VALOR Float
DECLARE @FK5_VLMOE1 Float
DECLARE @FK5_VLMOE2	Float
DECLARE @EZ_VALOR Float
DECLARE @EV_VALOR Float
DECLARE @FWI_VLRBOR Float
DECLARE @FWI_BCOANT char('FWI_BCOANT')
DECLARE @E1_CCUSTO Char('E1_CCUSTO')
DECLARE @ED_CCC Char('ED_CCC')
DECLARE @ED_DEBITO	Char('ED_DEBITO')
DECLARE @ED_CREDIT	Char('ED_CREDIT')

DECLARE @maxStagingCounter Datetime
DECLARE @fk5_S_T_A_M_P_ Datetime

DECLARE @cFk5_STAMP char(25)
DECLARE @fk5_Recno Integer
declare @delTransactTime char(25)
declare @cStamp char('F7J_STAMP')
declare flex char(1)

Begin

    select @N_TAMTOTAL = @IN_TAMEMP + @IN_TAMUNIT +	@IN_TAMFIL

    Select @cStamp = (
						SELECT MIN (F7J_STAMP )
							FROM F7J### F7J
							WHERE 
								F7J.F7J_ALIAS = 'CRR' 
					)

	Select @delTransactTime = CONVERT(CHAR(25), DATEADD(HOUR, -1, GETUTCDATE()), 121)

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
	
	select @DTINI = @IN_DTINI
	select @DTFIM = @IN_DTFIM

    If (@IN_DTINI = ' ' and @IN_DTFIM = ' ')
		Begin
			select @DTINI = Convert(CHAR(8),DateAdd(Year,-2,GetDate()),112)
			select @DTFIM = Convert(CHAR(8), GetDate(), 112)
		End
	
	If @IN_BXLOTE = ' '
		Begin
			select @BXLOTE = '1'
		End
	Else
		Begin
			select @BXLOTE = @IN_BXLOTE
		End

	select @F7I_ORGSYT = 'RR' 	
	select @F7I_TPEVNT = 'S'
	select @F7I_TPBENF = '1'
	select @F7I_ORBENF = 'CR'
	select @F7I_SALDO  = 0
	select @F7I_VLPROP = 0
	select @F7I_FXRTBS = 0
	select @F7I_VLRCNT = 0
	select @F7I_FXRTCT = 0	

-- Cursor declaration curReceberR
   declare curReceberR insensitive cursor for   

   --NF
   select 
		'##CTE_FILIAL ##MAP_MOEDA'																		as F7I_ORIGIN,
		fk5_S_T_A_M_P_																					as fk5_S_T_A_M_P_,
		fk5_Recno                                                                                       as fk5_Recno,
		EZ_MSUID																					    as EZ_MSUID,
		EV_MSUID																					    as EV_MSUID,
		E1_FILORIG																						as E1_FILORIG,	
		E1_EMISSAO																						as F7I_EMISSA,
		E1_EMIS1																						as F7I_EMIS1,	
		COALESCE(E1_HIST,' ')																			as F7I_HIST,
		E1_TIPO			          																		as F7I_TIPO,	
		X5_DESCRI																				        as F7I_TIPDSC,
		E1_PREFIXO																						as F7I_PREFIX,
		E1_NUM																							as F7I_NUM,
		E1_PARCELA																						as F7I_PARCEL,
		E1_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA)																				as F7I_DSCMDA,
		A6_MOEDA																						as F7I_MOEDB,
		E1_VENCTO																						as F7I_VENCTO,
		E1_VENCREA																						as F7I_VENCRE,
		FK5_DATA																						as F7I_DTPGTO,
		FK5_BANCO  																						as F7I_BANCO,
		FK5_AGENCI 																						as F7I_AGENCI,
		FK5_CONTA  																						as F7I_CONTA,
		A1_FILIAL																						as F7I_FLBENF,
		A1_COD																							as F7I_CDBENF,
		A1_LOJA																							as F7I_LJBENF,
		A1_NOME																							as F7I_NBENEF,
		FK5_IDMOV 																						as F7I_IDMOV,
		E1_BAIXA																						as E1_BAIXA,
		E1_SALDO * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_SALDO,
		E1_TIPO																							as E1_TIPO,	
		E1_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as F7I_VLCRUZ,
		E1_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_VLCRUZ,
		E1_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_VALOR,
		FK5_DTDISP																						as F7I_DTDISP,
		E1_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,
		FK7_IDDOC																						as FK7_IDDOC,
		E1_DEBITO																						as F7I_DEBITO,
		E1_CCD																							as F7I_CCD,
		E1_CCC																							as F7I_CCC,
		E1_ITEMCTA																						as F7I_ITEMCT,
		E1_ITEMD																						as F7I_ITEMD,
		E1_ITEMC																						as F7I_ITEMC,
		E1_CLVL																							as F7I_CLVL,
		E1_CLVLDB																						as F7I_CLVLDB,
		E1_CLVLCR																						as F7I_CLVLCR,
		E1_NUMBOR																						as F7I_NUMBOR,
		FK5_HISTOR																						as F7I_HISTOR,
		FK1_TPDOC																						as FK1_TPDOC,
		E1_LOTE																							as E1_LOTE,
		FK1_IDFK1																						as FK1_IDFK1,
		FK5_RECPAG																						as FK5_RECPAG,
		FK1_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK1_VALOR,
		E1_MOEDA																						as E1_MOEDA,
		A6_MOEDA																						as A6_MOEDA,
		FK5_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK5_VALOR,
		FK5_VLMOE2 * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)											as FK5_VLMOE2,
		FK5_TXMOED 																						as F7I_CONVBS,
		FK5_TXMOED 																						as F7I_CONVCT,
		EV_VALOR																						as EV_VALOR,
		EZ_VALOR																						as EZ_VALOR,
		0																								as FWI_VLRBOR,
		' '																								as FWI_BCOANT,
		ED_CCC																							as ED_CCC,
		ED_DEBITO																						as ED_DEBITO,
		ED_CREDIT																						as ED_CREDIT,
		E1_CCUSTO																						as E1_CCUSTO,
		TRIM(E1_SITUACA)               																    as F7I_MOVIM,
		Isnull(FRV_DESCRI,' ' )               													        as F7I_DSCMOV,
		E1_CREDIT 																						as F7I_CREDIT
		,'#selectcursorflex' as cursorflex
   from    
   (
		SELECT 'NF' as Origem,
		'##ROW_NUMBER' as fka_rownum,
		fk5.FK5_RECPAG,
        fk5.FK5_DATA,
        fk5.FK5_IDMOV,
        fk5.FK5_VALOR,
        fk5.FK5_BANCO,
        fk5.FK5_AGENCI,
        fk5.FK5_CONTA,
        fk5.FK5_VLMOE2,
        fk5.FK5_TXMOED,
        fk5.FK5_DTDISP,
        fk5.FK5_HISTOR,
		fk5.S_T_A_M_P_ as fk5_S_T_A_M_P_,
        fk5.R_E_C_N_O_ as fk5_Recno,

		fk1.FK1_TPDOC,
        fk1.FK1_IDFK1,
        fk1.FK1_VALOR,
		
		fk7.FK7_IDDOC,

		stg_se1.E1_FILIAL,
        stg_se1.E1_PREFIXO,
        stg_se1.E1_NUM,
        stg_se1.E1_PARCELA,
        stg_se1.E1_LOJA,
        stg_se1.E1_TIPO,
        stg_se1.E1_CCUSTO,
        stg_se1.E1_MOEDA,
        stg_se1.E1_FILORIG,
        stg_se1.E1_NATUREZ,
        stg_se1.E1_SITUACA,
        stg_se1.E1_LOTE,
        stg_se1.E1_EMISSAO,
        stg_se1.E1_HIST,
        stg_se1.E1_VENCTO,
        stg_se1.E1_VENCREA,
        stg_se1.E1_VLCRUZ,
        stg_se1.E1_EMIS1,
        stg_se1.E1_BAIXA,
        stg_se1.E1_SALDO,
        stg_se1.E1_VALOR,
        stg_se1.E1_CCD,
        stg_se1.E1_CCC,
        stg_se1.E1_ITEMCTA,
        stg_se1.E1_ITEMD,
        stg_se1.E1_ITEMC,
        stg_se1.E1_CLVL,
        stg_se1.E1_CLVLDB,
        stg_se1.E1_CLVLCR,
        stg_se1.E1_NUMBOR,
        stg_se1.E1_DEBITO,
        stg_se1.E1_CREDIT,

		sa6.A6_MOEDA,

		sed.ED_DEBITO,
        sed.ED_CREDIT,
        sed.ED_CCC,

		sx5_consolidate.X5_DESCRI,

		sa1.A1_FILIAL,
        sa1.A1_COD,
        sa1.A1_LOJA,
        sa1.A1_NOME,

		frv.FRV_DESCRI,

		currency.DESC_MOEDA,

		sev.EV_NATUREZ,
        sev.EV_MSUID,
        sev.EV_VALOR,
        sev.EV_PERC,

		sez.EZ_CCUSTO,
        sez.EZ_NATUREZ,
        sez.EZ_MSUID,
        sez.EZ_VALOR,
        sez.EZ_PERC
		
		,'#campoflex' as campoflex
		
 FROM FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
     inner join MAP_FILIAL mf
         ON mf.MAP_FILORIG = fk5.FK5_FILORI
		 
     inner join FKA### fka LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON fka.FKA_FILIAL = fk5.FK5_FILIAL
			and FKA_IDORIG = FK5_IDMOV
            and fka.FKA_TABORI = 'FK5'
			--and fka.D_E_L_E_T_ In (@del1,@del2)
	 
	 inner join FKA### fka_fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON fka_fk1.FKA_FILIAL = fk5.FK5_FILIAL
			And fka_fk1.FKA_IDPROC = fka.FKA_IDPROC
            and fka_fk1.FKA_TABORI = 'FK1'
			--and fka_fk1.D_E_L_E_T_ In (@del1,@del2)
	
     inner join FK1### fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON fk1.FK1_FILIAL = fk5.FK5_FILIAL
            and fk1.FK1_IDFK1 = fka_fk1.FKA_IDORIG			
            and FK1_MOTBX NOT In ( 'LIQ', 'CEC', 'CMP' )
            and fk1.D_E_L_E_T_ = ' '
	
     inner join FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON fk7.FK7_FILIAL = fk5.FK5_FILIAL
            and fk7.FK7_IDDOC = fk1.FK1_IDDOC
            and fk7.FK7_ALIAS = 'SE1'
			--and fk7.D_E_L_E_T_ In (@del1,@del2)
	
     inner join SE1### stg_se1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON stg_se1.E1_FILIAL = fk7.FK7_FILTIT
            and stg_se1.E1_PREFIXO = fk7.FK7_PREFIX
            and stg_se1.E1_NUM = fk7.FK7_NUM
            and stg_se1.E1_PARCELA = fk7.FK7_PARCEL
            and stg_se1.E1_TIPO = fk7.FK7_TIPO
            and stg_se1.E1_CLIENTE = fk7.FK7_CLIFOR
            and stg_se1.E1_LOJA = fk7.FK7_LOJA			
			and RIGHT(stg_se1.E1_TIPO, 1) <> '-'
			and stg_se1.E1_TIPO NOT in ( 'PR ', 'RA ' )
            and stg_se1.D_E_L_E_T_ = fk7.D_E_L_E_T_

	 left join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON sev.EV_FILIAL = mf.SEV_FILIAL
            and sev.EV_PREFIXO = stg_se1.E1_PREFIXO
            and sev.EV_NUM = stg_se1.E1_NUM
            and sev.EV_PARCELA = stg_se1.E1_PARCELA
            and sev.EV_TIPO = stg_se1.E1_TIPO
            and sev.EV_CLIFOR = stg_se1.E1_CLIENTE
            and sev.EV_LOJA = stg_se1.E1_LOJA
            and fk5.FK5_SEQ = sev.EV_SEQ
            and sev.EV_IDENT = '2'
            and fk5.FK5_RECPAG is NOT null
            and (
                    (
                        fk5.FK5_RECPAG = 'P'
                        and sev.EV_SITUACA = 'E'
                    )
                    or (
                           fk5.FK5_RECPAG = 'R'
                           and sev.EV_SITUACA IN ( 'X', ' ' )
                       )
                )
			--and sev.D_E_L_E_T_ In (@del1,@del2)

     left join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON sev.EV_FILIAL = sez.EZ_FILIAL
            and sev.EV_PREFIXO = sez.EZ_PREFIXO
            and sev.EV_NUM = sez.EZ_NUM
            and sev.EV_PARCELA = sez.EZ_PARCELA
            and sev.EV_TIPO = sez.EZ_TIPO
            and sev.EV_CLIFOR = sez.EZ_CLIFOR
            and sev.EV_LOJA = sez.EZ_LOJA
            and sev.EV_NATUREZ = sez.EZ_NATUREZ
            and sev.EV_SEQ = sez.EZ_SEQ
            and sev.EV_SITUACA = sez.EZ_SITUACA
            and sez.EZ_IDENT = '2'
			--And sez.D_E_L_E_T_ In (@del1,@del2)
	
     left join SA6### sa6
         ON sa6.A6_FILIAL = mf.SA6_FILIAL
            and sa6.A6_COD = fk5.FK5_BANCO
            and sa6.A6_AGENCIA = fk5.FK5_AGENCI
            and sa6.A6_NUMCON = fk5.FK5_CONTA
            and sa6.D_E_L_E_T_ = ' '
	
     inner join SED### sed
         ON sed.ED_FILIAL = mf.SED_FILIAL
            and sed.ED_CODIGO = stg_se1.E1_NATUREZ
            and sed.D_E_L_E_T_ = ' '
	
     inner join SX5### sx5_consolidate
         ON sx5_consolidate.X5_FILIAL = mf.SX5_FILIAL
            and sx5_consolidate.X5_TABELA = '05'
            and sx5_consolidate.X5_CHAVE = stg_se1.E1_TIPO
            and sx5_consolidate.D_E_L_E_T_ = ' '
	
     left join SA1### sa1
         ON sa1.A1_FILIAL = mf.SA1_FILIAL
            and sa1.A1_COD = stg_se1.E1_CLIENTE
            and sa1.A1_LOJA = stg_se1.E1_LOJA
            and sa1.D_E_L_E_T_ = ' '
	
     left join FRV### frv LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
         ON frv.FRV_FILIAL = mf.FRV_FILIAL
            and frv.FRV_CODIGO = stg_se1.E1_SITUACA
            and frv.D_E_L_E_T_ = ' '
			
	 Inner join MAP_MOEDA currency ON currency.SX6_MOEDA = stg_se1.E1_MOEDA	
			
     left join F7J### f7j
         ON f7j.F7J_ALIAS = 'CRR'            
			AND trim(f7j.F7J_STAMP) = CONVERT(CHAR(25), fk5.S_T_A_M_P_ , 121)
            and f7j.F7J_RECNO = fk5.R_E_C_N_O_
 WHERE 
	   (
              (
                   @maxStagingCounter is null
                   and (
						   (
							   fk5.FK5_DATA >= @DTINI
							   and fk5.FK5_DATA <= @DTFIM
						   )
						)
               )
               or
			   (fk5.S_T_A_M_P_ > @maxStagingCounter and @DTINI = ' ' and @DTFIM = ' ' and @IN_DEL = ' ')
			   or ( fk5.FK5_DATA >= @DTINI and fk5.FK5_DATA <= @DTFIM and @IN_DEL = 'S' )
       )  
       and f7j.F7J_RECNO is null
	   and ( (fk5.D_E_L_E_T_ = ' ' AND @maxStagingCounter is null) OR (@maxStagingCounter is not null) )
	) NF
		Where 
			fka_rownum = 1
	
	Union all
	--SemFka
   select 	
		Origem																							as F7I_ORIGIN,
		fk5_S_T_A_M_P_																					as fk5_S_T_A_M_P_,
		fk5_Recno                                                                                       as fk5_Recno,
		EZ_MSUID																					    as EZ_MSUID,
		EV_MSUID																					    as EV_MSUID,
		E1_FILORIG																						as E1_FILORIG,	
		E1_EMISSAO																						as F7I_EMISSA,
		E1_EMIS1																						as F7I_EMIS1,	
		COALESCE(E1_HIST,' ')																			as F7I_HIST,
		E1_TIPO			          																		as F7I_TIPO,	
		X5_DESCRI																				        as F7I_TIPDSC,
		E1_PREFIXO																						as F7I_PREFIX,
		E1_NUM																							as F7I_NUM,
		E1_PARCELA																						as F7I_PARCEL,
		E1_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA)																				as F7I_DSCMDA,
		A6_MOEDA																						as F7I_MOEDB,	
		E1_VENCTO																						as F7I_VENCTO,
		E1_VENCREA																						as F7I_VENCRE,
		FK5_DATA																						as F7I_DTPGTO,
		FK5_BANCO  																						as F7I_BANCO,
		FK5_AGENCI 																						as F7I_AGENCI,
		FK5_CONTA  																						as F7I_CONTA,
		A1_FILIAL																						as F7I_FLBENF,
		A1_COD																							as F7I_CDBENF,
		A1_LOJA																							as F7I_LJBENF,
		A1_NOME																							as F7I_NBENEF,
		FK5_IDMOV 																						as F7I_IDMOV,
		E1_BAIXA																						as E1_BAIXA,
		E1_SALDO * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_SALDO,
		E1_TIPO																							as E1_TIPO,	
		E1_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as F7I_VLCRUZ,
		E1_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_VLCRUZ,
		E1_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_VALOR,
		FK5_DTDISP																						as F7I_DTDISP,
		E1_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,
		FK7_IDDOC																						as FK7_IDDOC,
		E1_DEBITO																						as F7I_DEBITO,
		E1_CCD																							as F7I_CCD,
		E1_CCC																							as F7I_CCC,
		E1_ITEMCTA																						as F7I_ITEMCT,
		E1_ITEMD																						as F7I_ITEMD,
		E1_ITEMC																						as F7I_ITEMC,
		E1_CLVL																							as F7I_CLVL,
		E1_CLVLDB																						as F7I_CLVLDB,
		E1_CLVLCR																						as F7I_CLVLCR,
		E1_NUMBOR																						as F7I_NUMBOR,
		FK5_HISTOR																						as F7I_HISTOR,
		FK1_TPDOC																						as FK1_TPDOC,
		E1_LOTE																							as E1_LOTE,
		FK1_IDFK1																						as FK1_IDFK1,
		FK5_RECPAG																						as FK5_RECPAG,
		FK1_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK1_VALOR,
		E1_MOEDA																						as E1_MOEDA,
		A6_MOEDA																						as A6_MOEDA,
		FK5_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK5_VALOR,
		FK5_VLMOE2 * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)											as FK5_VLMOE2,
		FK5_TXMOED 																						as F7I_CONVBS,
		FK5_TXMOED 																						as F7I_CONVCT,
		EV_VALOR																						as EV_VALOR,
		EZ_VALOR																						as EZ_VALOR,
		0																								as FWI_VLRBOR,
		' '																								as FWI_BCOANT,
		ED_CCC																							as ED_CCC,
		ED_DEBITO																						as ED_DEBITO,
		ED_CREDIT																						as ED_CREDIT,
		E1_CCUSTO																						as E1_CCUSTO,
		TRIM(E1_SITUACA)               																    as F7I_MOVIM,
		Isnull(FRV_DESCRI,' ' )               													        as F7I_DSCMOV,
		E1_CREDIT 																						as F7I_CREDIT
		,'#selectcursorflex' as cursorflex
   from    
   (
		Select 
			'SemFka' as Origem,
			'##ROW_NUMBER_FKA' as fka_rownum,
			fk5.FK5_RECPAG,
			fk5.FK5_DATA,
			fk5.FK5_IDMOV,
			fk5.FK5_VALOR,
			fk5.FK5_BANCO,
			fk5.FK5_AGENCI,
			fk5.FK5_CONTA,
			fk5.FK5_VLMOE2,
			fk5.FK5_TXMOED,
			fk5.FK5_DTDISP,
			fk5.FK5_HISTOR,
			fk5.S_T_A_M_P_ 		as fk5_S_T_A_M_P_,
			fk5.R_E_C_N_O_		as fk5_Recno,
			
			fk1.FK1_TPDOC,			
			fk1.FK1_IDFK1,
			fk1.FK1_VALOR,

			fk7.FK7_IDDOC,

			stg_se1.E1_PREFIXO,
			stg_se1.E1_NUM,
			stg_se1.E1_PARCELA,			
			stg_se1.E1_TIPO,
			stg_se1.E1_CCUSTO,
			stg_se1.E1_MOEDA,
			stg_se1.E1_FILORIG,
			stg_se1.E1_NATUREZ,			
			stg_se1.E1_SITUACA,
			stg_se1.E1_LOTE,
			stg_se1.E1_EMISSAO,
			stg_se1.E1_HIST,
			stg_se1.E1_VENCTO,
			stg_se1.E1_VENCREA,
			stg_se1.E1_VLCRUZ,
			stg_se1.E1_EMIS1,
			stg_se1.E1_BAIXA,
			stg_se1.E1_SALDO,
			stg_se1.E1_VALOR,
			stg_se1.E1_CCD,
			stg_se1.E1_CCC,
			stg_se1.E1_ITEMCTA,
			stg_se1.E1_ITEMD,
			stg_se1.E1_ITEMC,
			stg_se1.E1_CLVL,
			stg_se1.E1_CLVLDB,
			stg_se1.E1_CLVLCR,
			stg_se1.E1_NUMBOR,
			stg_se1.E1_DEBITO,
			stg_se1.E1_CREDIT,

			sev.EV_NATUREZ,
			sev.EV_MSUID,
			sev.EV_VALOR,
			sev.EV_PERC,

			sez.EZ_CCUSTO,			
			sez.EZ_MSUID,
			sez.EZ_VALOR,
			sez.EZ_PERC,
			
			sa6.A6_MOEDA,			
			
			sed.ED_DEBITO,
			sed.ED_CREDIT,
			sed.ED_CCC,

			sx5_consolidate.X5_DESCRI,

			sa1.A1_FILIAL,
			sa1.A1_COD,
			sa1.A1_LOJA,
			sa1.A1_NOME,
			
			currency.DESC_MOEDA,
			
			frv.FRV_DESCRI	
			,'#campoflex' as campoflex		
		From 
			FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			
			Inner join FKA### fka_fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on         
				fka_fk5.FKA_FILIAL = fk5.FK5_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				and fka_fk5.FKA_IDORIG = FK5_IDMOV
            	and fka_fk5.FKA_TABORI = 'FK5'

			Left join FKA### fka_fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fka_fk1.FKA_FILIAL = fk5.FK5_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk1.FKA_IDPROC = fka_fk5.FKA_IDPROC
                And fka_fk1.FKA_TABORI = 'FK1'

			Left join FK1### fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fk1.FK1_FILIAL = fk5.FK5_FILIAL -- amarrado com FILORI em ambas (nao tratar)
				and fk1.FK1_LOTE = fk5.FK5_LOTE				
				and FK1_MOTBX Not In ('LIQ','CEC','CMP')				
				Or ( fk1.FK1_FILIAL = fk5.FK5_FILIAL and @BXLOTE = '1' And fk1.FK1_LOTE = fk5.FK5_LOTE And fk1.FK1_LOTE <> ' ' and fk1.D_E_L_E_T_ = ' ' )
			
			Inner join FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			ON
				fk7.FK7_FILIAL = fk5.FK5_FILIAL
				and fk7.FK7_IDDOC = fk1.FK1_IDDOC
				And fk7.FK7_ALIAS = 'SE1'
			
			Inner join SE1### stg_se1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			ON
				stg_se1.E1_FILIAL  = fk7.FK7_FILTIT --FILTIT GRAVADO COM A FILIAL DA E1/E2 (NAO TRATAR)
				And stg_se1.E1_PREFIXO = fk7.FK7_PREFIX
				And stg_se1.E1_NUM = fk7.FK7_NUM
				And stg_se1.E1_PARCELA = fk7.FK7_PARCEL
				And stg_se1.E1_TIPO = fk7.FK7_TIPO
				And stg_se1.E1_CLIENTE = fk7.FK7_CLIFOR
				And stg_se1.E1_LOJA = fk7.FK7_LOJA
				And RIGHT(stg_se1.E1_TIPO, 1) <> '-' 
				And stg_se1.E1_TIPO not in ('PR ','RA ') 
				And stg_se1.D_E_L_E_T_ = fk7.D_E_L_E_T_
			
			Inner join MAP_FILIAL mf ON mf.MAP_FILORIG = stg_se1.E1_FILORIG

			Left Join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = mf.SEV_FILIAL
				And sev.EV_PREFIXO = stg_se1.E1_PREFIXO
				And sev.EV_NUM = stg_se1.E1_NUM
				And sev.EV_PARCELA = stg_se1.E1_PARCELA	
				And sev.EV_TIPO = stg_se1.E1_TIPO
				And sev.EV_CLIFOR = stg_se1.E1_CLIENTE
				And sev.EV_LOJA = stg_se1.E1_LOJA 
				And sev.EV_SEQ = fk5.FK5_SEQ
				And sev.EV_IDENT = '2' -- Baixa
				And fk5.FK5_RECPAG is not null
				And (
					(
						fk5.FK5_RECPAG = 'P'
						And sev.EV_SITUACA = 'E'
					) Or (
						fk5.FK5_RECPAG = 'R'
						And sev.EV_SITUACA IN ( 'X' , ' ')
					) 
				)

			Left Join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = sez.EZ_FILIAL -- EV E EZ MESMO COMPARTILHAMENTO NAO TRATAR
				And sev.EV_PREFIXO = sez.EZ_PREFIXO
				And sev.EV_NUM = sez.EZ_NUM
				And sev.EV_PARCELA = sez.EZ_PARCELA	
				And sev.EV_TIPO = sez.EZ_TIPO
				And sev.EV_CLIFOR = sez.EZ_CLIFOR
				And sev.EV_LOJA = sez.EZ_LOJA 
				And sev.EV_NATUREZ = sez.EZ_NATUREZ 
				And sev.EV_SEQ = sez.EZ_SEQ
				And sev.EV_SITUACA = sez.EZ_SITUACA 
				And sez.EZ_IDENT = '2' -- Baixa

			Left Join SA6### sa6
			On
				sa6.A6_FILIAL = mf.SA6_FILIAL
				And sa6.A6_COD = fk5.FK5_BANCO
				And sa6.A6_AGENCIA = fk5.FK5_AGENCI                
				And sa6.A6_NUMCON = fk5.FK5_CONTA
				And sa6.D_E_L_E_T_  = ' '
			  
			Inner join SED### sed
			On   
				sed.ED_FILIAL = mf.SED_FILIAL
				And sed.ED_CODIGO = stg_se1.E1_NATUREZ
				And sed.D_E_L_E_T_ = ' '

			inner join SX5### sx5_consolidate 
			On 
				sx5_consolidate.X5_FILIAL = mf.SX5_FILIAL
				And sx5_consolidate.X5_TABELA = '05' 
				And sx5_consolidate.X5_CHAVE  = stg_se1.E1_TIPO
				And sx5_consolidate.D_E_L_E_T_  = ' '
			 
			Left join SA1### sa1
			On
				sa1.A1_FILIAL = mf.SA1_FILIAL
				And sa1.A1_COD = stg_se1.E1_CLIENTE
				And sa1.A1_LOJA = stg_se1.E1_LOJA
				And sa1.D_E_L_E_T_  = ' '

			Left join FRV### frv LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			On			  
				frv.FRV_FILIAL = mf.FRV_FILIAL
				and frv.FRV_CODIGO = stg_se1.E1_SITUACA		
				And frv.D_E_L_E_T_  = ' '

			Inner join MAP_MOEDA currency ON currency.SX6_MOEDA = stg_se1.E1_MOEDA
			
			Left join F7J### f7j
			On 
				f7j.F7J_ALIAS = 'CRR' 
				AND trim(f7j.F7J_STAMP) = CONVERT(CHAR(25), fk5.S_T_A_M_P_ , 121)
				AND f7j.F7J_RECNO = fk5.R_E_C_N_O_

		Where 
			(
              (
                   @maxStagingCounter is null
                   and (
						   (
							   fk5.FK5_DATA >= @DTINI
							   and fk5.FK5_DATA <= @DTFIM
						   )
						)
               )
               or
			   (fk5.S_T_A_M_P_ > @maxStagingCounter and @DTINI = ' ' and @DTFIM = ' ' and @IN_DEL = ' ')
			   or ( fk5.FK5_DATA >= @DTINI and fk5.FK5_DATA <= @DTFIM and @IN_DEL = 'S' )
       	   )         		
		   And(
				(
					-- Bx em lote
					fk5.FK5_RECPAG = 'R' 
					And fk5.FK5_LOTE <> ' ' 				  	
				) Or (
					-- Estorno de Bx em lote
				  	fk5.FK5_RECPAG = 'P' 
					And fk5.FK5_LOTE <> ' '
				)			  
		   )			
		   AND f7j.F7J_RECNO is null
   ) SemFka
   Where
	fka_rownum = 1
   
   Union All
   --RA
   select 	
		Origem																							as F7I_ORIGIN,
		fk5_S_T_A_M_P_																					as fk5_S_T_A_M_P_,
		fk5_Recno                                                                                       as fk5_Recno,
		EZ_MSUID																					    as EZ_MSUID,
		EV_MSUID																					    as EV_MSUID,
		E1_FILORIG																						as E1_FILORIG,	
		E1_EMISSAO																						as F7I_EMISSA,
		E1_EMIS1																						as F7I_EMIS1,	
		COALESCE(E1_HIST,' ')																			as F7I_HIST,
		E1_TIPO			          																		as F7I_TIPO,	
		X5_DESCRI																				        as F7I_TIPDSC,
		E1_PREFIXO																						as F7I_PREFIX,
		E1_NUM																							as F7I_NUM,
		E1_PARCELA																						as F7I_PARCEL,
		E1_MOEDA																						as F7I_MOEDA,
		trim(DESC_MOEDA)																				as F7I_DSCMDA,
		A6_MOEDA																						as F7I_MOEDB,	
		E1_VENCTO																						as F7I_VENCTO,
		E1_VENCREA																						as F7I_VENCRE,
		FK5_DATA																						as F7I_DTPGTO,
		FK5_BANCO  																						as F7I_BANCO,
		FK5_AGENCI 																						as F7I_AGENCI,
		FK5_CONTA  																						as F7I_CONTA,
		A1_FILIAL																						as F7I_FLBENF,
		A1_COD																							as F7I_CDBENF,
		A1_LOJA																							as F7I_LJBENF,
		A1_NOME																							as F7I_NBENEF,
		FK5_IDMOV 																						as F7I_IDMOV,
		E1_BAIXA																						as E1_BAIXA,
		E1_SALDO * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_SALDO,
		E1_TIPO																							as E1_TIPO,	
		E1_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as F7I_VLCRUZ,
		E1_VLCRUZ * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_VLCRUZ,
		E1_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as E1_VALOR,
		FK5_DTDISP																						as F7I_DTDISP,
		E1_NATUREZ																						as F7I_NATURE,      
		COALESCE(EV_NATUREZ,' ')																		as F7I_NATRAT,
		COALESCE(EZ_CCUSTO,' ')																			as F7I_CCDRAT,
		FK7_IDDOC																						as FK7_IDDOC,
		E1_DEBITO																						as F7I_DEBITO,
		E1_CCD																							as F7I_CCD,
		E1_CCC																							as F7I_CCC,
		E1_ITEMCTA																						as F7I_ITEMCT,
		E1_ITEMD																						as F7I_ITEMD,
		E1_ITEMC																						as F7I_ITEMC,
		E1_CLVL																							as F7I_CLVL,
		E1_CLVLDB																						as F7I_CLVLDB,
		E1_CLVLCR																						as F7I_CLVLCR,
		E1_NUMBOR																						as F7I_NUMBOR,
		FK5_HISTOR																						as F7I_HISTOR,
		FK1_TPDOC																						as FK1_TPDOC,
		E1_LOTE																							as E1_LOTE,
		FK1_IDFK1																						as FK1_IDFK1,
		FK5_RECPAG																						as FK5_RECPAG,
		FK1_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK1_VALOR,
		E1_MOEDA																						as E1_MOEDA,
		A6_MOEDA																						as A6_MOEDA,
		FK5_VALOR * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)												as FK5_VALOR,
		FK5_VLMOE2 * IsNull(EZ_PERC, 1) * IsNull(EV_PERC, 1)											as FK5_VLMOE2,
		FK5_TXMOED 																						as F7I_CONVBS,
		FK5_TXMOED 																						as F7I_CONVCT,
		EV_VALOR																						as EV_VALOR,
		EZ_VALOR																						as EZ_VALOR, 
		0																								as FWI_VLRBOR,
		' '																								as FWI_BCOANT,
		ED_CCC																							as ED_CCC,
		ED_DEBITO																						as ED_DEBITO,
		ED_CREDIT																						as ED_CREDIT,
		E1_CCUSTO																						as E1_CCUSTO,
		TRIM(E1_SITUACA)               																    as F7I_MOVIM,
		Isnull(FRV_DESCRI,' ' )               													        as F7I_DSCMOV,
		E1_CREDIT 																						as F7I_CREDIT
		,'#selectcursorflex' as cursorflex
   from    
   (
		Select 
			'RA' as Origem,
			'##ROW_NUMBER' as fka_rownum,
			stg_se1.E1_FILIAL,
			stg_se1.E1_PREFIXO,
			stg_se1.E1_NUM,
			stg_se1.E1_PARCELA,
			stg_se1.E1_CLIENTE,
			stg_se1.E1_LOJA,
			stg_se1.E1_TIPO,
			stg_se1.E1_CCUSTO,
			stg_se1.E1_MOEDA,
			stg_se1.E1_FILORIG,
			stg_se1.E1_NATUREZ,
			stg_se1.D_E_L_E_T_,
			stg_se1.E1_SITUACA,
			stg_se1.E1_LOTE,
			stg_se1.E1_EMISSAO,
			stg_se1.E1_HIST,
			stg_se1.E1_VENCTO,
			stg_se1.E1_VENCREA,
			stg_se1.E1_VLCRUZ,
			stg_se1.E1_EMIS1,
			stg_se1.E1_BAIXA,
			stg_se1.E1_SALDO,
			stg_se1.E1_VALOR,
			stg_se1.E1_CCD,
			stg_se1.E1_CCC,
			stg_se1.E1_ITEMCTA,
			stg_se1.E1_ITEMD,
			stg_se1.E1_ITEMC,
			stg_se1.E1_CLVL,
			stg_se1.E1_CLVLDB,
			stg_se1.E1_CLVLCR,
			stg_se1.E1_NUMBOR,
			stg_se1.E1_DEBITO,
			stg_se1.E1_CREDIT,
			
			fk7.FK7_IDDOC,
			fk7.FK7_FILTIT,

			fk1.FK1_TPDOC,
			fk1.FK1_FILIAL,
			fk1.FK1_LOTE,
			fk1.FK1_IDFK1,
			fk1.FK1_VALOR,
			fk1.FK1_DATA,


			fka_fk1.FKA_IDPROC,
			fka_fk1.FKA_IDORIG,
			fka_fk1.FKA_TABORI as FKA_TABORI2,
			fka_fk5.FKA_TABORI,
			fka_fk5.FKA_IDFKA,

			fk5.FK5_IDDOC,
			fk5.FK5_RECPAG,
			fk5.FK5_DATA,
			fk5.FK5_IDMOV,
			fk5.FK5_VALOR,
			fk5.FK5_BANCO,
			fk5.FK5_AGENCI,
			fk5.FK5_CONTA,
			fk5.FK5_SEQ,
			fk5.FK5_VLMOE2,
			fk5.FK5_TXMOED,
			fk5.FK5_DTDISP,
			fk5.FK5_HISTOR,

			sed.ED_DEBITO,
			sed.ED_CREDIT,
			sed.ED_CCC,
			
			sx5_consolidate.X5_DESCRI,

			sa1.A1_FILIAL,
			sa1.A1_COD,
			sa1.A1_LOJA,
			sa1.A1_NOME,

			frv.FRV_DESCRI,

			sa6.A6_MOEDA,

			fk5.S_T_A_M_P_ 		as fk5_S_T_A_M_P_,
			fk5.R_E_C_N_O_ as fk5_Recno,

			DESC_MOEDA,

			EV_NATUREZ,
			EV_MSUID,
			EV_VALOR,
			EV_PERC,

			EZ_CCUSTO,
			EZ_NATUREZ,
			EZ_MSUID,
			EZ_VALOR,
			EZ_PERC	
			,'#campoflex' as campoflex			
		From 
			SE1### stg_se1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			Inner join MAP_MOEDA currency ON currency.SX6_MOEDA = stg_se1.E1_MOEDA
			INNER JOIN MAP_FILIAL mf ON mf.MAP_FILORIG = stg_se1.E1_FILORIG
			Inner join FK7### fk7 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			ON
				fk7.FK7_FILTIT = stg_se1.E1_FILIAL --FILTIT GRAVADO COM A FILIAL DA E1/E2 (NAO TRATAR)
				And fk7.FK7_PREFIX = stg_se1.E1_PREFIXO 
				And fk7.FK7_NUM = stg_se1.E1_NUM 
				And fk7.FK7_PARCEL = stg_se1.E1_PARCELA 
				And fk7.FK7_TIPO = stg_se1.E1_TIPO
				And fk7.FK7_CLIFOR = stg_se1.E1_CLIENTE
				And fk7.FK7_LOJA = stg_se1.E1_LOJA
				And fk7.D_E_L_E_T_ = stg_se1.D_E_L_E_T_ 
				And fk7.FK7_ALIAS = 'SE1'

			Left join FK1### fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fk1.FK1_FILIAL = fk7.FK7_FILIAL 
				and fk1.FK1_IDDOC = fk7.FK7_IDDOC 
				and fk1.FK1_FILORI = stg_se1.E1_FILORIG -- amarrado com FILORI em ambas (nao tratar)
				and FK1_MOTBX Not In ('LIQ','CEC','CMP')
				and fk1.D_E_L_E_T_ = ' '

			Left join FKA### fka_fk1 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on
				fka_fk1.FKA_FILIAL = fk1.FK1_FILIAL -- mesmo nivel de compartilhamento (nao tratar)
				and fka_fk1.FKA_IDORIG = fk1.FK1_IDFK1

			Left join FKA### fka_fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on         
				
				fka_fk5.FKA_FILIAL = fk1.FK1_FILIAL  -- mesmo nivel de compartilhamento (nao tratar)
				And fka_fk1.FKA_IDPROC = fka_fk5.FKA_IDPROC
				And fka_fk5.FKA_TABORI = 'FK5'
			  
			Inner join FK5### fk5 LEFT JOIN CT2### ON CT2_FILIAL = ' ' --ct2 removido sempre pelo parser
			on  
				(
					(
						fk5.FK5_FILORI = stg_se1.E1_FILORIG -- amarrado com FILORI em ambas (nao tratar) E MESMO NIVEL FKA FK5
						And fk5.FK5_IDDOC = fk7.FK7_IDDOC
					) or (
						fka_fk5.FKA_FILIAL = fk5.FK5_FILIAL
						And fk5.FK5_IDMOV = fka_fk5.FKA_IDORIG
					) 
				)
			
			Left Join SEV### sev LEFT JOIN CT2### ON CT2_FILIAL = ' '  --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = mf.SEV_FILIAL
				And sev.EV_PREFIXO = stg_se1.E1_PREFIXO
				And sev.EV_NUM = stg_se1.E1_NUM
				And sev.EV_PARCELA = stg_se1.E1_PARCELA	
				And sev.EV_TIPO = stg_se1.E1_TIPO
				And sev.EV_CLIFOR = stg_se1.E1_CLIENTE
				And sev.EV_LOJA = stg_se1.E1_LOJA 
				And sev.EV_SEQ = fk5.FK5_SEQ
				And sev.EV_IDENT = '2' -- Baixa
				And fk5.FK5_RECPAG is not null
				And (
					(
						fk5.FK5_RECPAG = 'P'
						And sev.EV_SITUACA = 'E'
					) Or (
						fk5.FK5_RECPAG = 'R'
						And sev.EV_SITUACA IN ( 'X' , ' ')
					) 
				)

			Left Join SEZ### sez LEFT JOIN CT2### ON CT2_FILIAL = ' '  --ct2 removido sempre pelo parser
			On
				sev.EV_FILIAL = sez.EZ_FILIAL -- EV E EZ MESMO COMPARTILHAMENTO NAO TRATAR
				And sev.EV_PREFIXO = sez.EZ_PREFIXO
				And sev.EV_NUM = sez.EZ_NUM
				And sev.EV_PARCELA = sez.EZ_PARCELA	
				And sev.EV_TIPO = sez.EZ_TIPO
				And sev.EV_CLIFOR = sez.EZ_CLIFOR
				And sev.EV_LOJA = sez.EZ_LOJA 
				And sev.EV_NATUREZ = sez.EZ_NATUREZ 
				And sev.EV_SEQ = sez.EZ_SEQ
				And sev.EV_SITUACA = sez.EZ_SITUACA 
				And sez.EZ_IDENT = '2' -- Baixa

			Left Join SA6### sa6
			On
				sa6.A6_FILIAL = mf.SA6_FILIAL
				And sa6.A6_COD = fk5.FK5_BANCO
				And sa6.A6_AGENCIA = fk5.FK5_AGENCI                
				And sa6.A6_NUMCON = fk5.FK5_CONTA
				And sa6.D_E_L_E_T_  = ' '
			  
			Inner join SED### sed
			on   
				sed.ED_FILIAL = mf.SED_FILIAL
				And sed.ED_CODIGO = stg_se1.E1_NATUREZ
				And sed.D_E_L_E_T_ = ' '

			inner join SX5### sx5_consolidate 
				ON 
				sx5_consolidate.X5_FILIAL = mf.SX5_FILIAL
				And sx5_consolidate.X5_TABELA = '05' 
				And sx5_consolidate.X5_CHAVE  = stg_se1.E1_TIPO
				And sx5_consolidate.D_E_L_E_T_  = ' '
			 
			Left join SA1### sa1
			On
				sa1.A1_FILIAL = mf.SA1_FILIAL
				And sa1.A1_COD = stg_se1.E1_CLIENTE
				And sa1.A1_LOJA = stg_se1.E1_LOJA
				And sa1.D_E_L_E_T_  = ' '

			Left join FRV### frv LEFT JOIN CT2### ON CT2_FILIAL = ' '  --ct2 removido sempre pelo parser
			on			  
				frv.FRV_FILIAL = mf.FRV_FILIAL
				and frv.FRV_CODIGO = stg_se1.E1_SITUACA		
				And frv.D_E_L_E_T_  = ' '

			LEFT JOIN F7J### f7j
			ON 
				f7j.F7J_ALIAS = 'CRR' 				
				AND trim(f7j.F7J_STAMP) = CONVERT(CHAR(25), fk5.S_T_A_M_P_ , 121)
				AND f7j.F7J_RECNO = fk5.R_E_C_N_O_

		Where 
			((@maxStagingCounter is null and ((stg_se1.E1_BAIXA >= @DTINI And stg_se1.E1_BAIXA <= @DTFIM) or (stg_se1.E1_EMIS1 >= @DTINI and stg_se1.E1_EMIS1 <= @DTFIM)))
				or stg_se1.S_T_A_M_P_ > @maxStagingCounter)
			And stg_se1.E1_TIPO = 'RA '
			And (			
					(@maxStagingCounter is null)
					Or (fk5.S_T_A_M_P_ > @maxStagingCounter And @maxStagingCounter is not null)
					Or ( @DTINI <> ' ' and @DTFIM <> ' ' and  @IN_DEL  = 'S' )
				)
			AND f7j.F7J_RECNO is null
   ) RA
	Where
		fka_rownum = 1	
	
	for read only
	
	open curReceberR
		fetch next from curReceberR
			into @F7I_ORIGIN,
				 @fk5_S_T_A_M_P_,
				 @fk5_Recno,
				 @EZ_MSUID,
				 @EV_MSUID,				 
				 @E1_FILORIG,				 
				 @F7I_EMISSA,
				 @F7I_EMIS1,
				 @F7I_HIST,
				 @F7I_TIPO,
				 @F7I_TIPDSC,				 
				 @F7I_PREFIX,
				 @F7I_NUM,
				 @F7I_PARCEL,
				 @F7I_MOEDA,
				 @F7I_DSCMDA,
				 @F7I_MOEDB,
				 @F7I_VENCTO,
				 @F7I_VENCRE,
				 @F7I_DTPGTO,
				 @F7I_BANCO,
				 @F7I_AGENCI,
				 @F7I_CONTA,
				 @F7I_FLBENF,
				 @F7I_CDBENF,
				 @F7I_LJBENF,
				 @F7I_NBENEF,
				 @F7I_IDMOV,				 
				 @E1_BAIXA,
				 @E1_SALDO,				 				 
				 @E1_TIPO,				 				 
				 @F7I_VLCRUZ,				 
				 @E1_VLCRUZ,
				 @E1_VALOR,
				 @F7I_DTDISP,
				 @F7I_NATURE,
				 @F7I_NATRAT,
				 @F7I_CCDRAT,				 
				 @FK7_IDDOC,
				 @F7I_DEBITO,
				 @F7I_CCD,
				 @F7I_CCC,
				 @F7I_ITEMCT,
				 @F7I_ITEMD,
				 @F7I_ITEMC,
				 @F7I_CLVL,
				 @F7I_CLVLDB,
				 @F7I_CLVLCR,
				 @F7I_NUMBOR,
				 @F7I_HISTOR,				 
				 @FK1_TPDOC,
				 @E1_LOTE,
				 @FK1_IDFK1,
				 @FK5_RECPAG,
				 @FK1_VALOR,
				 @E1_MOEDA,
				 @A6_MOEDA,
				 @FK5_VALOR,
				 @FK5_VLMOE2,
				 @F7I_CONVBS,
				 @F7I_CONVCT,
				 @EV_VALOR,
				 @EZ_VALOR,
				 @FWI_VLRBOR,
				 @FWI_BCOANT,
				 @ED_CCC,
				 @ED_DEBITO,
				 @ED_CREDIT,
				 @E1_CCUSTO,
				 @F7I_MOVIM,
				 @F7I_DSCMOV,
				 @F7I_CREDIT
				 --#cursorflex
	
	While ( (@@fetch_Status  = 0 ) )
	Begin

	   ---------------------------------------------
	   --Tratamento CT1
	   ---------------------------------------------
	   
	   If ( @FK5_RECPAG = 'P' AND @ED_CREDIT <> ' ' )
			Begin 
				exec XFILIAL_## 'CT1', @E1_FILORIG, @filialCT1 OutPut
				Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_CREDIT AND D_E_L_E_T_ = ' '
			End
		Else
			Begin 			
				If ( @FK5_RECPAG = 'R' AND @ED_DEBITO <> ' ')
					Begin
						exec XFILIAL_## 'CT1', @E1_FILORIG, @filialCT1 OutPut
						Select @F7I_CNTCTB = CT1_CONTA , @F7I_DSCCTB = SUBSTRING(CT1_DESC01,1,40) , @F7I_NATCTA = CT1_NATCTA FROM CT1### Where CT1_FILIAL = @filialCT1 AND CT1_CONTA = @ED_DEBITO AND D_E_L_E_T_ = ' '
					End
			End
		If ( @F7I_CNTCTB = ' ' or @F7I_CNTCTB is null )
			Begin
				select @F7I_CNTCTB = '0'
			End

	   ---------------------------------------------
	   --FIM Tratamento CT1
	   ---------------------------------------------

		select @F7I_VLPROP = 0
		---------------------------------------------
		--Tratamento Campo @F7I_EXTCDH
		---------------------------------------------
		If( (Trim(@FK1_TPDOC) = 'BA' And @E1_LOTE <> ' ') Or @F7I_ORIGIN = 'fwi' )
			Begin 
				select @F7I_EXTCDH = @FK1_IDFK1
			End
		Else
			Begin
				select @F7I_EXTCDH = @F7I_IDMOV
			End
			
		---------------------------------------------
		--Tratamento Campo @F7I_EXTCDD
		---------------------------------------------
		If (  @EZ_MSUID is not null )
			Begin 
				select @F7I_EXTCDD = @EZ_MSUID			
			End
			Else
				Begin 			
					If ( @EV_MSUID is not null )
						Begin 
							select @F7I_EXTCDD = @EV_MSUID
						End
					Else
						Begin
							If( (Trim(@FK1_TPDOC) = 'BA' And @E1_LOTE <> ' ') Or @F7I_ORIGIN = 'fwi' )
								Begin 
									select @F7I_EXTCDD = @FK1_IDFK1	
								End
							Else
								Begin
									select @F7I_EXTCDD = @F7I_IDMOV
								End
						End
				End

		---------------------------------------------
		--Tratamento Campo @F7I_HIST
		---------------------------------------------	
		If (@F7I_HIST = ' ')
			Begin
				select @F7I_HIST = 'SEM DESCRICAO'
			End
		---------------------------------------------
		--Tratamento Campo @F7I_TPEVNT
		---------------------------------------------
		If(  Trim(@FK5_RECPAG) = 'R' )
			Begin 
				select @F7I_TPEVNT = 'E'
			End
		Else
			Begin
				select @F7I_TPEVNT = 'S'
			End
			
		If ( @F7I_ORIGIN = 'fwi' )
			Begin
				If ( @FWI_BCOANT = ' ' )
					Begin
						select @F7I_TPEVNT = 'E'
					End
				Else
					Begin 
						select @F7I_TPEVNT = 'S'
					End
			End
			
		---------------------------------------------
		--Tratamento Campo @F7I_SALDO
		---------------------------------------------
		If( Trim(@FK1_TPDOC) = 'BA' And @E1_LOTE <> ' ' )
			Begin 
				select @F7I_SALDO = @FK1_VALOR
			End
		Else
			Begin				
				If( @E1_MOEDA = @A6_MOEDA )
					Begin
						select @F7I_SALDO = @FK5_VALOR	
					End
				Else
					If ( @FK5_VLMOE2 = 0 )
						Begin 
							select @F7I_SALDO = @FK5_VALOR
						End
					Else
						Begin
							select @F7I_SALDO = @FK5_VLMOE2
						End
				If ( @F7I_NUMBOR <> ' ' And @F7I_ORIGIN = 'fwi' )
					Begin 
						select @F7I_SALDO = @FWI_VLRBOR	
					End
			End
			
		------------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT @F7I_VLPROP = @F7I_SALDO
		------------------------------------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------
		--Tratamento Campo @F7I_FXRTBS,@F7I_FXRTCT
		---------------------------------------------
		select @F7I_CONVBS = ROUND(@F7I_CONVBS,@DecCONVBS)
		select @F7I_CONVCT = @F7I_CONVBS

		If ( @F7I_CONVBS = 0 )
			Begin
				select @F7I_FXRTBS = '0'
				select @F7I_FXRTCT = '0'
			End
		Else			
			Begin
				select @F7I_FXRTBS = '1'
				select @F7I_FXRTCT = '1'
			End	

		---------------------------------------------
		--Tratamento Campo @F7I_VLRCNT 
		---------------------------------------------
		If ( @F7I_ORIGIN = 'RA' )
			Begin
				select @F7I_VLRCNT = 0				
			End
		Else
			Begin
				If ( @F7I_NUMBOR <> ' ' And @F7I_ORIGIN = 'fwi' )
					Begin 
						select @F7I_VLRCNT = @FWI_VLRBOR	
						select @F7I_VLCRUZ = @FWI_VLRBOR
					End
				Else
					Begin
						If  (@F7I_ORIGIN  = 'fwi' OR (@F7I_ORIGIN = 'SemFka' AND @F7I_NUMBOR  <> ' ') ) 
							Begin 
								select @F7I_VLRCNT = @FK1_VALOR
								select @F7I_VLCRUZ = @FK1_VALOR
							End
						Else
							Begin 
								select @F7I_VLRCNT = @FK5_VALOR
							End
					End
			End

		/**********************************************************************************************************************************************************/
		-- Inicio do tratamento DESCRICAO DA MEDA A6
		/**********************************************************************************************************************************************************/
		If ( @F7I_MOEDA = @F7I_MOEDB)
			Begin
				Select @F7I_DSCMDB = @F7I_DSCMDA
			End 
		Else
			Begin
				If (@F7I_MOEDB > 0)
					Begin
						Select @F7I_DSCMDB = (
												SELECT
													SX6.X6_CONTEUD
													FROM SX6### SX6
														WHERE RTRIM(SX6.X6_VAR) = 'MV_MOEDA' || RTRIM(CAST(@F7I_MOEDB AS CHAR(2)))
															AND SX6.D_E_L_E_T_ = ' '
											)
					End
				Else
					Begin
						Select @F7I_DSCMDB =' '
					End
			End
		/**********************************************************************************************************************************************************/
		-- Fim do tratamento DESCRICAO DA MEDA A6
		/**********************************************************************************************************************************************************/	

		/**********************************************************************************************************************************************************/
		-- Inicio do tratamento stamp transacao
		/**********************************************************************************************************************************************************/
		If ( @fk5_S_T_A_M_P_ is null )
						Begin 
							Select @cFk5_STAMP = @delTransactTime
						End	
					Else 
						Begin
							Select @cFk5_STAMP = CONVERT(CHAR(25), @fk5_S_T_A_M_P_, 121)
						End 	
			
		/**********************************************************************************************************************************************************/
		-- Fim do tratamento stamp transacao
		/**********************************************************************************************************************************************************/
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Inicio Tratamento Descricao Custo
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT @F7I_DSCCCT = ' '
		SELECT @F7I_CCUSTO = @ED_CCC
		IF @ED_CCC <> ' '
			Begin
				exec XFILIAL_## 'CTT', @E1_FILORIG, @filialCTT OutPut
				SELECT @F7I_DSCCCT = (SELECT SUBSTRING(CTT_DESC01,1,40) FROM CTT### WHERE CTT_FILIAL = @filialCTT AND CTT_CUSTO = @ED_CCC AND D_E_L_E_T_ = ' ')
			End
		------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Fim Tratamento Descricao Custo
		------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		---------------------------------------------
		--Tratamento Campo @cF7I_STAMP
		---------------------------------------------		
		select @F7I_STAMP = @cFk5_STAMP
		select @cF7I_STAMP = FORMAT(CONVERT( datetime ,@cFk5_STAMP ,121 ), 'yyyy-MM-ddTHH:mm:ss.fff')
		/**********************************************************************************************************************************************************/
		-- Fim do tratamento dos campos para serem gravados na tabela F7I
		/**********************************************************************************************************************************************************/
		
		--correcao para arredondamento de conversao ocorre apenas em mssql
		##IF_001({|| Trim(TcGetDb()) == "MSSQL" })
			IF  @cFk5_STAMP  NOT LIKE '%.%'
				BEGIN 
					SELECT @cFk5_STAMP = TRIM(@cFk5_STAMP)  + '.000' 
				END
			IF  @cF7I_STAMP NOT LIKE '%.%'
				BEGIN 
					SELECT @cF7I_STAMP = TRIM(@cF7I_STAMP) + '.000' 
				END
		##ENDIF_001


		SELECT @COMPANIA = SUBSTRING(@E1_FILORIG,1, @IN_TAMEMP )
		SELECT @COD_UNID = SUBSTRING(@E1_FILORIG,@IN_TAMEMP+1, @IN_TAMUNIT)
		SELECT @COD_FIL  = SUBSTRING(@E1_FILORIG,@IN_TAMEMP+1 + @IN_TAMUNIT , @IN_TAMEMP + @IN_TAMUNIT + @IN_TAMFIL)

		/**********************************************************************************************************************************************************/
		-- Inclusao dos registros
		/**********************************************************************************************************************************************************/
		##CHECK_TRANSACTION_BEGIN @IN_TRANSACTION\
		insert into F7I### (
			F7I_ORIGIN,    
			F7I_EXTCDH,	 
			F7I_EXTCDD,	 
			F7I_EMISSA,	 
			F7I_EMIS1,
			F7I_HIST,	
			F7I_TIPO,	
			F7I_TIPDSC,     	 
			F7I_PREFIX,	 
			F7I_NUM,
			F7I_PARCEL,	 
			F7I_MOEDA,
			F7I_DSCMDA,	 
			F7I_MOEDB,   
			F7I_DSCMDB,    
			F7I_VENCTO,	 
			F7I_VENCRE,	 
			F7I_DTPGTO,   
			F7I_BANCO,   
			F7I_AGENCI,    
			F7I_CONTA,   
			F7I_FLBENF,	 
			F7I_CDBENF,	 
			F7I_LJBENF,	 
			F7I_NBENEF,	 
			F7I_MOVIM,   
			F7I_DSCMOV,    
			F7I_IDMOV,   	  				 
			F7I_VLCRUZ,	 	 
			F7I_CNTCTB,	 
			F7I_DSCCTB,	
			F7I_NATCTA,	
			F7I_DSCCCT,	 
			F7I_DTDISP,   
			F7I_NATURE,	 
			F7I_NATRAT,	
			F7I_CCDRAT,		 
			F7I_DEBITO,	 
			F7I_CCD,
			F7I_CCC,
			F7I_ITEMCT,	 
			F7I_ITEMD,
			F7I_ITEMC,	
			F7I_CLVL,	
			F7I_CLVLDB,
			F7I_CLVLCR,	 
			F7I_NUMBOR,	 
			F7I_HISTOR,	 
			F7I_CONVBS,   
			F7I_CONVCT,   
			F7I_VLPROP,
			F7I_ORGSYT,					
			F7I_GRPEMP, 
			F7I_EMPR, 
			F7I_UNID, 
			F7I_FILNEG,
			F7I_STAMP,
			F7I_SALDO,
			F7I_TPEVNT,
			F7I_TPBENF,
			F7I_ORBENF,
			F7I_FXRTCT,
			F7I_FXRTBS,
			F7I_CCUSTO,
			F7I_CREDIT,
			F7I_VLRCNT
			--#insertflex
		) Values (
			@F7I_ORIGIN,    
			@F7I_EXTCDH, 
			@F7I_EXTCDD,	 
			@F7I_EMISSA, 
			@F7I_EMIS1,
			@F7I_HIST,
			@F7I_TIPO,	
			IsNull(@F7I_TIPDSC, ' '),			
			@F7I_PREFIX, 
			@F7I_NUM,
			@F7I_PARCEL,
			@F7I_MOEDA,
			SUBSTRING(IsNull(@F7I_DSCMDA, ' '),1,10),
			IsNull(@F7I_MOEDB, 0), -- Alguns cadastros de banco podem posssui moeda nao cadastrada  
			SUBSTRING(IsNull(@F7I_DSCMDB, ' '),1,10), 
			@F7I_VENCTO, 
			@F7I_VENCRE, 
			@F7I_DTPGTO,   
			@F7I_BANCO,   
			@F7I_AGENCI,    
			@F7I_CONTA,   
			IsNull(@F7I_FLBENF, ' '),	 
			IsNull(@F7I_CDBENF, ' '), 
			IsNull(@F7I_LJBENF, ' '),			
			SUBSTRING(IsNull(@F7I_NBENEF, ' '),1,50),
			@F7I_MOVIM,
			IsNull(@F7I_DSCMOV, ' '),    
			@F7I_IDMOV,   	 
			@F7I_VLCRUZ,	 	 
			@F7I_CNTCTB, 
			IsNull(SUBSTRING(@F7I_DSCCTB,1,40),' '),
			IsNull(@F7I_NATCTA, ' '),
			IsNull(SUBSTRING(@F7I_DSCCCT,1,40),' '),
			@F7I_DTDISP,   
			@F7I_NATURE, 
			IsNull(@F7I_NATRAT, ' '),
			IsNull(@F7I_CCDRAT, ' '),
			@F7I_DEBITO, 
			@F7I_CCD,
			@F7I_CCC,	
			@F7I_ITEMCT,
			@F7I_ITEMD,
			@F7I_ITEMC,	
			@F7I_CLVL,
			@F7I_CLVLDB,	 
			@F7I_CLVLCR, 
			@F7I_NUMBOR, 
			@F7I_HISTOR, 
			@F7I_CONVBS,   
			@F7I_CONVCT,   
			@F7I_VLPROP,
			@F7I_ORGSYT,					
			IsNull(@IN_GROUPEMPRESA,' '), 
			IsNull(@COMPANIA,' '), 
			IsNull(@COD_UNID,' '), 
			IsNull(@COD_FIL,' '),
			@cF7I_STAMP,
			@F7I_SALDO,
			@F7I_TPEVNT,
			@F7I_TPBENF,
			@F7I_ORBENF,
			@F7I_FXRTCT,
			@F7I_FXRTBS,
			@F7I_CCUSTO,
			@F7I_CREDIT,
			@F7I_VLRCNT
			--#variaveisflex
		)
		##CHECK_TRANSACTION_COMMIT

		/**********************************************************************************************************************************************************/
		-- Inclusao dos registros tabela de transacao
		/**********************************************************************************************************************************************************/
		INSERT INTO F7J###  (
				F7J_FILIAL,
				F7J_ALIAS,
				F7J_RECNO,
				F7J_STAMP
			) VALUES(
				' ',
				'CRR',
				@fk5_Recno , 
				@cFk5_STAMP 
			)
		
		/**********************************************************************************************************************************************************/
		-- Posiciona para o proximo registro do cursor
		/**********************************************************************************************************************************************************/
		fetch next from curReceberR
			into @F7I_ORIGIN,
				 @fk5_S_T_A_M_P_,
				 @fk5_Recno,
				 @EZ_MSUID,
				 @EV_MSUID,				 
				 @E1_FILORIG,				 
				 @F7I_EMISSA,
				 @F7I_EMIS1,
				 @F7I_HIST,
				 @F7I_TIPO,
				 @F7I_TIPDSC,				 
				 @F7I_PREFIX,
				 @F7I_NUM,
				 @F7I_PARCEL,
				 @F7I_MOEDA,
				 @F7I_DSCMDA,
				 @F7I_MOEDB,
				 @F7I_VENCTO,
				 @F7I_VENCRE,
				 @F7I_DTPGTO,
				 @F7I_BANCO,
				 @F7I_AGENCI,
				 @F7I_CONTA,
				 @F7I_FLBENF,
				 @F7I_CDBENF,
				 @F7I_LJBENF,
				 @F7I_NBENEF,
				 @F7I_IDMOV,				 
				 @E1_BAIXA,
				 @E1_SALDO,				 				 
				 @E1_TIPO,				 				 
				 @F7I_VLCRUZ,				 
				 @E1_VLCRUZ,
				 @E1_VALOR,
				 @F7I_DTDISP,
				 @F7I_NATURE,
				 @F7I_NATRAT,
				 @F7I_CCDRAT,				 
				 @FK7_IDDOC,
				 @F7I_DEBITO,
				 @F7I_CCD,
				 @F7I_CCC,
				 @F7I_ITEMCT,
				 @F7I_ITEMD,
				 @F7I_ITEMC,
				 @F7I_CLVL,
				 @F7I_CLVLDB,
				 @F7I_CLVLCR,
				 @F7I_NUMBOR,
				 @F7I_HISTOR,				 
				 @FK1_TPDOC,
				 @E1_LOTE,
				 @FK1_IDFK1,
				 @FK5_RECPAG,
				 @FK1_VALOR,
				 @E1_MOEDA,
				 @A6_MOEDA,
				 @FK5_VALOR,
				 @FK5_VLMOE2,
				 @F7I_CONVBS,
				 @F7I_CONVCT,
				 @EV_VALOR,
				 @EZ_VALOR,
				 @FWI_VLRBOR,
				 @FWI_BCOANT,
				 @ED_CCC,
				 @ED_DEBITO,
				 @ED_CREDIT,
				 @E1_CCUSTO,
				 @F7I_MOVIM,
				 @F7I_DSCMOV,
				 @F7I_CREDIT
				 --#cursorflex
	End
	DELETE FROM 
		F7J###
    WHERE F7J_ALIAS = 'CRR' 
      AND F7J_STAMP < @delTransactTime 
	  AND F7J_STAMP < (
			SELECT MAX(F7J_STAMP ) FROM 
				F7J### 
			WHERE 
				F7J_ALIAS = 'CRR'
		)
	close curReceberR
	deallocate curReceberR
	select @OUT_RESULTADO = '1'
End