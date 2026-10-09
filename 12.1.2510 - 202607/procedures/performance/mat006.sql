Create procedure MAT006_##
(
 @IN_CCOD         Char('B1_COD'),
 @IN_CLOCAL       Char('B1_LOCPAD'),
 @IN_DDATA        Char(08),
 @IN_CFILAUX      VarChar('B1_FILIAL'),
 @IN_MV_LOCPROC   Char('B1_LOCPAD'),
 @IN_FILIALCOR    Char('B1_FILIAL'),
 @IN_MV_D3SERVI   Char(01),
 @IN_INTDL        Char(01),
 @IN_MV_CQ        Char('B1_LOCPAD'),
 @IN_MV_WMSNEW    Char('B1_LOCPAD'),
 @IN_CONSTESTERC  Char(01),
 @OUT_QSALDOATU   Float OutPut,
 @OUT_CUSTOATU    Float OutPut,
 @OUT_CUSTOATU2   Float OutPut,
 @OUT_CUSTOATU3   Float OutPut,
 @OUT_CUSTOATU4   Float OutPut,
 @OUT_CUSTOATU5   Float OutPut,
 @OUT_QTSEGUM     Float OutPut,
 @OUT_B9_CM1      Float OutPut,
 @OUT_B9_CM2      Float OutPut,
 @OUT_B9_CM3      Float OutPut,
 @OUT_B9_CM4      Float OutPut,
 @OUT_B9_CM5      Float OutPut,
 @OUT_B9_CMRP1    Float OutPut,
 @OUT_B9_CMRP2    Float OutPut,
 @OUT_B9_CMRP3    Float OutPut,
 @OUT_B9_CMRP4    Float OutPut,
 @OUT_B9_CMRP5    Float OutPut,
 @OUT_CUSTORP1    Float OutPut,
 @OUT_CUSTORP2    Float OutPut,
 @OUT_CUSTORP3    Float OutPut,
 @OUT_CUSTORP4    Float OutPut,
 @OUT_CUSTORP5    Float OutPut
 )

as

/* ---------------------------------------------------------------------------------------------------------------------
    Versão      -  <v> Protheus P12 </v>
    Programa    -  <s> CALCEST </s>
    Assinatura  -  <a> 001 </a>
    Descricao   -  <d> Retorna o Saldo do Produto/Local do arquivo SB9 - Saldos Iniciais </d>
    Entrada     -  <ri>
					@IN_CCOD         - Codigo do Produto
					@IN_CLOCAL       - Local de Processamento (Almoxarifado)
					@IN_DDATA        - Data para obter Saldo Inicial
					@IN_CFILAUX      - *** Em desuso *** Periodo inicial e final (Array aPeriodos)
					@IN_MV_LOCPROC   - Local de processo
					@IN_FILIALCOR    - Filial Corrente
					@IN_MV_D3SERVI   - Considera o parametro MV_D3SERVI
					@IN_INTDL        - Verifica a integracao com WMS
					@IN_MV_CQ        - Armazem de CQ
					@IN_MV_WMSNEW    - Novo Wms
					@IN_CONSTESTERC  - Considera Poder de Terceiros, somente utilizado no relatorio MATR460 
					                   através da funcao CalcEst. Para outras chamadas deve ser feito informando '0'. 
                   </ri>
    Saida       -  <ro>
                   @OUT_QSALDOATU   - Retorna o Saldo Atual do Produto
                   @OUT_CUSTOATU    - Retorno Custo 1
                   @OUT_CUSTOATU2   - Retorno Custo 2
                   @OUT_CUSTOATU3   - Retorno Custo 3
                   @OUT_CUSTOATU4   - Retorno Custo 4
                   @OUT_CUSTOATU5   - Retorno Custo 5
                   @OUT_QTSEGUM     - Retorno Quantidade na Segunda Unidade
                   </ro>

    Responsavel :  <r> Emerson Tobar </r>
    Data        :  <dt> 09.02.00 </dt>

    Estrutura de chamadas
    ========= == ========

    0.MAT006 - Retorna o Saldo do Produto/Local do arquivo SB9 - Saldos Iniciais

--------------------------------------------------------------------------------------------------------------------- */

Declare @vFilEmpty      Char('B1_FILIAL')
Declare @cFil_SD1       VarChar('D1_FILIAL')
Declare @cFil_SD2       VarChar('D2_FILIAL')
Declare @cFil_SD3       VarChar('D3_FILIAL')
Declare @cFil_SF4       VarChar('F4_FILIAL')
Declare @cFil_SB9       VarChar('B9_FILIAL')
Declare @cFil_SF5       VarChar('F5_FILIAL')

Declare @vB9_QINI       decimal( 'B9_QINI' )
Declare @vB9_VINI1      decimal( 'B9_VINI1' )
Declare @vB9_VINI2      decimal( 'B9_VINI2' )
Declare @vB9_VINI3      decimal( 'B9_VINI3' )
Declare @vB9_VINI4      decimal( 'B9_VINI4' )
Declare @vB9_VINI5      decimal( 'B9_VINI5' )
Declare @vB9_QTSEGUM    decimal( 'B9_QISEGUM' )

Declare @vB9_CM1        decimal( 'B2_CM1' )
Declare @vB9_CM2        decimal( 'B2_CM2' )
Declare @vB9_CM3        decimal( 'B2_CM3' )
Declare @vB9_CM4        decimal( 'B2_CM4' )
Declare @vB9_CM5        decimal( 'B2_CM5' )

Declare @vB9_CMRP1      decimal( 'B2_CM1' )
Declare @vB9_CMRP2      decimal( 'B2_CM2' )
Declare @vB9_CMRP3      decimal( 'B2_CM3' )
Declare @vB9_CMRP4      decimal( 'B2_CM4' )
Declare @vB9_CMRP5      decimal( 'B2_CM5' )

Declare @vB9_VINIRP1    decimal( 'B2_VFIM1' )
Declare @vB9_VINIRP2    decimal( 'B2_VFIM2' )
Declare @vB9_VINIRP3    decimal( 'B2_VFIM3' )
Declare @vB9_VINIRP4    decimal( 'B2_VFIM4' )
Declare @vB9_VINIRP5    decimal( 'B2_VFIM5' )

Declare @vQEntradas     Float
Declare @vD1_QUANT      decimal( 'D1_QUANT' )
Declare @vD1_CUSTO      decimal( 'D1_CUSTO' )
Declare @vD1_CUSTO2     decimal( 'D1_CUSTO2' )
Declare @vD1_CUSTO3     decimal( 'D1_CUSTO3' )
Declare @vD1_CUSTO4     decimal( 'D1_CUSTO4' )
Declare @vD1_CUSTO5     decimal( 'D1_CUSTO5' )
Declare @vD1_QTSEGUM    decimal( 'D1_QTSEGUM' )

Declare @vD1_CUSRP1     decimal( 'D1_CUSTO' )
Declare @vD1_CUSRP2     decimal( 'D1_CUSTO2' )
Declare @vD1_CUSRP3     decimal( 'D1_CUSTO3' )
Declare @vD1_CUSRP4     decimal( 'D1_CUSTO4' )
Declare @vD1_CUSRP5     decimal( 'D1_CUSTO5' )

Declare @vQSaidas       Float
Declare @vD2_QUANT      decimal( 'D2_QUANT' )
Declare @vD2_CUSTO      decimal( 'D2_CUSTO' )
Declare @vD2_CUSTO2     decimal( 'D2_CUSTO2' )
Declare @vD2_CUSTO3     decimal( 'D2_CUSTO3' )
Declare @vD2_CUSTO4     decimal( 'D2_CUSTO4' )
Declare @vD2_CUSTO5     decimal( 'D2_CUSTO5' )

Declare @vD2_CUSRP1     decimal( 'D2_CUSTO' )
Declare @vD2_CUSRP2     decimal( 'D2_CUSTO2' )
Declare @vD2_CUSRP3     decimal( 'D2_CUSTO3' )
Declare @vD2_CUSRP4     decimal( 'D2_CUSTO4' )
Declare @vD2_CUSRP5     decimal( 'D2_CUSTO5' )

Declare @vD2_QTSEGUM    decimal( 'D2_QTSEGUM' )
Declare @vQMovEntr      Float
Declare @vQMovSaid      Float
Declare @vQMovEntrP     Float
Declare @vQMovSaidP     Float

Declare @vD3E_QUANT     decimal( 'D3_QUANT' )
Declare @vD3E_CUSTO     decimal( 'D3_CUSTO' )
Declare @vD3E_CUSTO2    decimal( 'D3_CUSTO2' )
Declare @vD3E_CUSTO3    decimal( 'D3_CUSTO3' )
Declare @vD3E_CUSTO4    decimal( 'D3_CUSTO4' )
Declare @vD3E_CUSTO5    decimal( 'D3_CUSTO5' )
Declare @vD3E_QTSEGUM   decimal( 'D3_QTSEGUM' )

Declare @vD3E_CUSRP1    decimal( 'D3_CUSTO' )
Declare @vD3E_CUSRP2    decimal( 'D3_CUSTO2' )
Declare @vD3E_CUSRP3    decimal( 'D3_CUSTO3' )
Declare @vD3E_CUSRP4    decimal( 'D3_CUSTO4' )
Declare @vD3E_CUSRP5    decimal( 'D3_CUSTO5' )

Declare @vD3S_QUANT     decimal( 'D3_QUANT' )
Declare @vD3S_CUSTO     decimal( 'D3_CUSTO' )
Declare @vD3S_CUSTO2    decimal( 'D3_CUSTO2' )
Declare @vD3S_CUSTO3    decimal( 'D3_CUSTO3' )
Declare @vD3S_CUSTO4    decimal( 'D3_CUSTO4' )
Declare @vD3S_CUSTO5    decimal( 'D3_CUSTO5' )
Declare @vD3S_QTSEGUM   decimal( 'D3_QTSEGUM' )

Declare @vD3S_CUSRP1    decimal( 'D3_CUSTO' )
Declare @vD3S_CUSRP2    decimal( 'D3_CUSTO2' )
Declare @vD3S_CUSRP3    decimal( 'D3_CUSTO3' )
Declare @vD3S_CUSRP4    decimal( 'D3_CUSTO4' )
Declare @vD3S_CUSRP5    decimal( 'D3_CUSTO5' )

Declare @vD3EP_QUANT    decimal( 'D3_QUANT' )
Declare @vD3EP_CUSTO    decimal( 'D3_CUSTO' )
Declare @vD3EP_CUSTO2   decimal( 'D3_CUSTO2' )
Declare @vD3EP_CUSTO3   decimal( 'D3_CUSTO3' )
Declare @vD3EP_CUSTO4   decimal( 'D3_CUSTO4' )
Declare @vD3EP_CUSTO5   decimal( 'D3_CUSTO5' )
Declare @vD3EP_QTSEGUM  decimal( 'D3_QTSEGUM' )

Declare @vD3EP_CUSRP1   decimal( 'D3_CUSTO' )
Declare @vD3EP_CUSRP2   decimal( 'D3_CUSTO2' )
Declare @vD3EP_CUSRP3   decimal( 'D3_CUSTO3' )
Declare @vD3EP_CUSRP4   decimal( 'D3_CUSTO4' )
Declare @vD3EP_CUSRP5   decimal( 'D3_CUSTO5' )

Declare @vD3SP_QUANT    decimal( 'D3_QUANT' )
Declare @vD3SP_CUSTO    decimal( 'D3_CUSTO' )
Declare @vD3SP_CUSTO2   decimal( 'D3_CUSTO2' )
Declare @vD3SP_CUSTO3   decimal( 'D3_CUSTO3' )
Declare @vD3SP_CUSTO4   decimal( 'D3_CUSTO4' )
Declare @vD3SP_CUSTO5   decimal( 'D3_CUSTO5' )
Declare @vD3SP_QTSEGUM  decimal( 'D3_QTSEGUM' )

Declare @vD3SP_CUSRP1   decimal( 'D3_CUSTO' )
Declare @vD3SP_CUSRP2   decimal( 'D3_CUSTO2' )
Declare @vD3SP_CUSRP3   decimal( 'D3_CUSTO3' )
Declare @vD3SP_CUSRP4   decimal( 'D3_CUSTO4' )
Declare @vD3SP_CUSRP5   decimal( 'D3_CUSTO5' )

Declare @vDtVai         VarChar(08)
Declare @vDtAux         VarChar(08)
Declare @cAux           Varchar(03)

Declare @vcEstoque     Varchar( 'F4_ESTOQUE' ) 
Declare @vcPoder1      Varchar( 'F4_PODER3' ) 
Declare @vcPoder2      Varchar( 'F4_PODER3' ) 
Declare @vcOrigLan     Varchar( 'D1_ORIGLAN' ) 
Declare @vcTPDCENV1    Varchar( 'D2_TPDCENV' ) 
Declare @vcTpDCENV2    Varchar( 'D2_TPDCENV' ) 
Declare @vcRemito      Varchar( 'D1_REMITO' )
Declare @vcTMEntrada   Varchar( 'D3_TM' )
Declare @vcTMEntAut    Varchar( 'D3_TM' )
Declare @vcTMSaiAut    Varchar( 'D3_TM' )
Declare @vcSemCodServ  Varchar( 'D3_SERVIC' )
Declare @vcReqArmProc  Varchar( 'D3_CF' )
Declare @vcDevArmProc  Varchar( 'D3_CF' )

Declare @IS_SPACE      CHAR( 01 )
Declare @IS_ACTIVE     CHAR( 01 )

begin
	select @cAux = 'SD1'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD1 OutPut
	select @cAux = 'SD2'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD2 OutPut
	select @cAux = 'SD3'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SD3 OutPut
	select @cAux = 'SF4'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF4 OutPut
	select @cAux = 'SB9'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SB9 OutPut
	select @cAux = 'SF5'
	EXEC XFILIAL_## @cAux, @IN_FILIALCOR, @cFil_SF5 OutPut

	select @vFilEmpty     = '  '
	select @vQMovEntrP    = 0
	select @vQMovSaidP    = 0
	select @vD3EP_QUANT   = 0
	select @vD3EP_QTSEGUM = 0
	select @vD3SP_QUANT   = 0
	select @vD3SP_QTSEGUM = 0

	select @vB9_CM1       = 0
	select @vB9_CM2       = 0
	select @vB9_CM3       = 0
	select @vB9_CM4       = 0
	select @vB9_CM5       = 0

	select @vB9_CMRP1     = 0
	select @vB9_CMRP2     = 0
	select @vB9_CMRP3     = 0
	select @vB9_CMRP4     = 0
	select @vB9_CMRP5     = 0

	select @vB9_VINIRP1   = 0
	select @vB9_VINIRP2   = 0
	select @vB9_VINIRP3   = 0
	select @vB9_VINIRP4   = 0
	select @vB9_VINIRP5   = 0

	select @vD1_CUSRP1    = 0
	select @vD1_CUSRP2    = 0
	select @vD1_CUSRP3    = 0
	select @vD1_CUSRP4    = 0
	select @vD1_CUSRP5    = 0

	select @vD2_CUSRP1    = 0
	select @vD2_CUSRP2    = 0
	select @vD2_CUSRP3    = 0
	select @vD2_CUSRP4    = 0
	select @vD2_CUSRP5    = 0

	select @vD3E_CUSRP1   = 0
	select @vD3E_CUSRP2   = 0
	select @vD3E_CUSRP3   = 0
	select @vD3E_CUSRP4   = 0
	select @vD3E_CUSRP5   = 0

	select @vD3S_CUSRP1   = 0
	select @vD3S_CUSRP2   = 0
	select @vD3S_CUSRP3   = 0
	select @vD3S_CUSRP4   = 0
	select @vD3S_CUSRP5   = 0

	select @vD3EP_CUSRP1  = 0
	select @vD3EP_CUSRP2  = 0
	select @vD3EP_CUSRP3  = 0
	select @vD3EP_CUSRP4  = 0
	select @vD3EP_CUSRP5  = 0

	select @vD3SP_CUSRP1  = 0
	select @vD3SP_CUSRP2  = 0
	select @vD3SP_CUSRP3  = 0
	select @vD3SP_CUSRP4  = 0
	select @vD3SP_CUSRP5  = 0

	select @vD3EP_CUSTO   = 0
	select @vD3EP_CUSTO2  = 0
	select @vD3EP_CUSTO3  = 0
	select @vD3EP_CUSTO4  = 0
	select @vD3EP_CUSTO5  = 0

	select @vD3SP_CUSTO   = 0
	select @vD3SP_CUSTO2  = 0
	select @vD3SP_CUSTO3  = 0
	select @vD3SP_CUSTO4  = 0
	select @vD3SP_CUSTO5  = 0

	select @vB9_QINI      = 0
	select @vB9_VINI1     = 0
	select @vB9_VINI2     = 0
	select @vB9_VINI3     = 0
	select @vB9_VINI4     = 0
	select @vB9_VINI5     = 0

	select @vcEstoque     = 'S'
	select @vcPoder1      = 'R' 
	select @vcPoder2      = 'D'
	select @vcOrigLan     = 'LF' 
	select @vcTPDCENV1    = '1'
	select @vcTpDCENV2    = 'A'
	select @vcRemito      = ##TAMSX3DIC_001('D1_REMITO')##ENDTAMSX3DIC_001
	select @vcTMEntrada   = '500'
	select @vcTMEntAut    = '499'
   select @vcTMSaiAut    = '999'
   select @vcSemCodServ  = ##TAMSX3DIC_002('D3_SERVIC')##ENDTAMSX3DIC_002
   select @vcReqArmProc  ='RE3'
   select @vcDevArmProc  ='DE3'

	select @IS_SPACE  = ' '
	select @IS_ACTIVE = '1'

	/*------------------------------------------------------------------------------
	Recupera Data para compor o Saldo Atualiza Valores Iniciais
	------------------------------------------------------------------------------ */
	select @vB9_QINI    = B9_QINI
			,@vB9_VINI1   = B9_VINI1
			,@vB9_VINI2   = B9_VINI2
			,@vB9_VINI3   = B9_VINI3
			,@vB9_VINI4   = B9_VINI4
			,@vB9_VINI5   = B9_VINI5
			,@vB9_QTSEGUM = B9_QISEGUM
			,@vDtVai      = B9_DATA
			,@vB9_CM1     = B9_CM1
			,@vB9_CM2     = B9_CM2
			,@vB9_CM3     = B9_CM3
			,@vB9_CM4     = B9_CM4
			,@vB9_CM5     = B9_CM5
			,@vB9_CMRP1   = B9_CMRP1
			,@vB9_CMRP2   = B9_CMRP2
			,@vB9_CMRP3   = B9_CMRP3
			,@vB9_CMRP4   = B9_CMRP4
			,@vB9_CMRP5   = B9_CMRP5
			,@vB9_VINIRP1 = B9_VINIRP1
			,@vB9_VINIRP2 = B9_VINIRP2
			,@vB9_VINIRP3 = B9_VINIRP3
			,@vB9_VINIRP4 = B9_VINIRP4
			,@vB9_VINIRP5 = B9_VINIRP5
	from SB9###
	where B9_FILIAL = @cFil_SB9
			and B9_COD     =  @IN_CCOD
			and B9_LOCAL   =  @IN_CLOCAL
			and B9_DATA    = (	select max(B9_DATA)
										from SB9###
										where B9_FILIAL      = @cFil_SB9
												and B9_COD     = @IN_CCOD
												and B9_LOCAL   = @IN_CLOCAL
												and B9_DATA    < @IN_DDATA
												and D_E_L_E_T_ = @IS_SPACE)
			and D_E_L_E_T_ =  @IS_SPACE

	/* ----------------------------------------------------------------------------------
	Tratamento para o OpenEdge
	--------------------------------------------------------------------------------- */
	##IF_003({|| AllTrim(Upper(TcGetDB())) == "OPENEDGE" })

		Select @vDtAux = @vDtVai

		EXEC MSDATEADD 'DAY', 1, @vDtAux, @vDtVai OutPut

	##ELSE_003

		Select @vDtVai = Convert(Char(08), dateadd( day, 1, @vDtVai), 112)

	##ENDIF_003

	if @vB9_QINI    is null select @vB9_QINI    = 0
	if @vB9_VINI1   is null select @vB9_VINI1   = 0
	if @vB9_VINI2   is null select @vB9_VINI2   = 0
	if @vB9_VINI3   is null select @vB9_VINI3   = 0
	if @vB9_VINI4   is null select @vB9_VINI4   = 0
	if @vB9_VINI5   is null select @vB9_VINI5   = 0
	if @vB9_QTSEGUM is null select @vB9_QTSEGUM = 0
	if @vB9_CM1     is null select @vB9_CM1     = 0
	if @vB9_CM2     is null select @vB9_CM2     = 0
	if @vB9_CM3     is null select @vB9_CM3     = 0
	if @vB9_CM4     is null select @vB9_CM4     = 0
	if @vB9_CM5     is null select @vB9_CM5     = 0
	if @vB9_CMRP1   is null select @vB9_CMRP1   = 0
	if @vB9_CMRP2   is null select @vB9_CMRP2   = 0
	if @vB9_CMRP3   is null select @vB9_CMRP3   = 0
	if @vB9_CMRP4   is null select @vB9_CMRP4   = 0
	if @vB9_CMRP5   is null select @vB9_CMRP5   = 0
	if @vB9_VINIRP1 is null select @vB9_VINIRP1 = 0
	if @vB9_VINIRP2 is null select @vB9_VINIRP2 = 0
	if @vB9_VINIRP3 is null select @vB9_VINIRP3 = 0
	if @vB9_VINIRP4 is null select @vB9_VINIRP4 = 0
	if @vB9_VINIRP5 is null select @vB9_VINIRP5 = 0
	if @vDtVai      is null select @vDtVai      = '19800101'
	if @vDtVai      = ' '   select @vDtVai      = '19800101'

	/* ------------------------------------------------------------------------------
	Acumula Valores das Notas Fiscais de Entrada (SD1)
	------------------------------------------------------------------------------ */
	select @vQEntradas  = Sum(SD1.D1_QUANT)
			,@vD1_CUSTO   = Sum(SD1.D1_CUSTO)
			,@vD1_CUSTO2  = Sum(SD1.D1_CUSTO2)
			,@vD1_CUSTO3  = Sum(SD1.D1_CUSTO3)
			,@vD1_CUSTO4  = Sum(SD1.D1_CUSTO4)
			,@vD1_CUSTO5  = Sum(SD1.D1_CUSTO5)
			,@vD1_QTSEGUM = Sum(SD1.D1_QTSEGUM)
			,@vD1_CUSRP1  = Sum(SD1.D1_CUSRP1)
			,@vD1_CUSRP2  = Sum(SD1.D1_CUSRP2)
			,@vD1_CUSRP3  = Sum(SD1.D1_CUSRP3)
			,@vD1_CUSRP4  = Sum(SD1.D1_CUSRP4)
			,@vD1_CUSRP5  = Sum(SD1.D1_CUSRP5)
	from SD1### SD1
	inner join SF4### SF4
	on SF4.F4_FILIAL       = @cFil_SF4
		and SF4.F4_CODIGO   = SD1.D1_TES
		and (SF4.F4_ESTOQUE = @vcEstoque or (@IN_CONSTESTERC = @IS_ACTIVE and (SF4.F4_PODER3 in (@vcPoder1, @vcPoder2)) ))
		and SF4.D_E_L_E_T_  = @IS_SPACE
	where SD1.D1_FILIAL       = @cFil_SD1
			and SD1.D1_COD      = @IN_CCOD
			and SD1.D1_LOCAL    = @IN_CLOCAL
			and SD1.D1_DTDIGIT >= @vDtVai
			and SD1.D1_DTDIGIT  < @IN_DDATA
			and SD1.D1_ORIGLAN <> @vcOrigLan
			##IF_004({|| cPaisLoc <> 'BRA' })
				and SD1.D1_REMITO  = @vcRemito
			##ENDIF_004
			and SD1.D_E_L_E_T_  = @IS_SPACE

	if @vQEntradas  is null select @vQEntradas  = 0
	if @vD1_CUSTO   is null select @vD1_CUSTO   = 0
	if @vD1_CUSTO2  is null select @vD1_CUSTO2  = 0
	if @vD1_CUSTO3  is null select @vD1_CUSTO3  = 0
	if @vD1_CUSTO4  is null select @vD1_CUSTO4  = 0
	if @vD1_CUSTO5  is null select @vD1_CUSTO5  = 0
	if @vD1_CUSRP1  is null select @vD1_CUSRP1  = 0
	if @vD1_CUSRP2  is null select @vD1_CUSRP2  = 0
	if @vD1_CUSRP3  is null select @vD1_CUSRP3  = 0
	if @vD1_CUSRP4  is null select @vD1_CUSRP4  = 0
	if @vD1_CUSRP5  is null select @vD1_CUSRP5  = 0
	if @vD1_QTSEGUM is null select @vD1_QTSEGUM = 0

	/* ------------------------------------------------------------------------------
	Acumula Valores das Movimentacoes de Entrada
	------------------------------------------------------------------------------ */
	select @vQMovEntr   = Sum(D3_QUANT)
			,@vD3E_CUSTO  = Sum(D3_CUSTO1)
			,@vD3E_CUSTO2 = Sum(D3_CUSTO2)
			,@vD3E_CUSTO3 = Sum(D3_CUSTO3)
			,@vD3E_CUSTO4 = Sum(D3_CUSTO4)
			,@vD3E_CUSTO5 = Sum(D3_CUSTO5)
			,@vD3E_QTSEGUM= Sum(D3_QTSEGUM)
			,@vD3E_CUSRP1 = Sum(SD3.D3_CUSRP1)
			,@vD3E_CUSRP2 = Sum(SD3.D3_CUSRP2)
			,@vD3E_CUSRP3 = Sum(SD3.D3_CUSRP3)
			,@vD3E_CUSRP4 = Sum(SD3.D3_CUSRP4)
			,@vD3E_CUSRP5 = Sum(SD3.D3_CUSRP5)
	from SD3### SD3
	where SD3.D3_FILIAL       = @cFil_SD3
			and SD3.D3_COD      = @IN_CCOD
			and SD3.D3_LOCAL    = @IN_CLOCAL
			and SD3.D3_EMISSAO >= @vDtVai
			and SD3.D3_EMISSAO  < @IN_DDATA
			and SD3.D3_ESTORNO  = @IS_SPACE
			and SD3.D3_TM      <= @vcTMEntrada
			and SD3.D_E_L_E_T_  = @IS_SPACE
			and ( SD3.D3_TM     = @vcTMEntAut
					or 0 < (	select count(*)
								from SF5### SF5 (nolock)
								where F5_FILIAL          = @cFil_SF5
										and F5_CODIGO      = SD3.D3_TM
										and SF5.D_E_L_E_T_ = @IS_SPACE ))

	if @vQMovEntr    is null select @vQMovEntr    = 0
	if @vD3E_CUSTO   is null select @vD3E_CUSTO   = 0
	if @vD3E_CUSTO2  is null select @vD3E_CUSTO2  = 0
	if @vD3E_CUSTO3  is null select @vD3E_CUSTO3  = 0
	if @vD3E_CUSTO4  is null select @vD3E_CUSTO4  = 0
	if @vD3E_CUSTO5  is null select @vD3E_CUSTO5  = 0
	if @vD3E_CUSRP1  is null select @vD3E_CUSRP1  = 0
	if @vD3E_CUSRP2  is null select @vD3E_CUSRP2  = 0
	if @vD3E_CUSRP3  is null select @vD3E_CUSRP3  = 0
	if @vD3E_CUSRP4  is null select @vD3E_CUSRP4  = 0
	if @vD3E_CUSRP5  is null select @vD3E_CUSRP5  = 0
	if @vD3E_QTSEGUM is null select @vD3E_QTSEGUM = 0

	/* ------------------------------------------------------------------------------
	Acumula Valores das Notas Fiscais de Entrada (SD2)
	------------------------------------------------------------------------------ */
	select @vQSaidas   = Sum(SD2.D2_QUANT)
			,@vD2_CUSTO  = Sum(SD2.D2_CUSTO1)
			,@vD2_CUSTO2 = Sum(SD2.D2_CUSTO2)
			,@vD2_CUSTO3 = Sum(SD2.D2_CUSTO3)
			,@vD2_CUSTO4 = Sum(SD2.D2_CUSTO4)
			,@vD2_CUSTO5 = Sum(SD2.D2_CUSTO5)
			,@vD2_QTSEGUM= Sum(SD2.D2_QTSEGUM)
			,@vD2_CUSRP1 = Sum(SD2.D2_CUSRP1)
			,@vD2_CUSRP2 = Sum(SD2.D2_CUSRP2)
			,@vD2_CUSRP3 = Sum(SD2.D2_CUSRP3)
			,@vD2_CUSRP4 = Sum(SD2.D2_CUSRP4)
			,@vD2_CUSRP5 = Sum(SD2.D2_CUSRP5)
	from SD2### SD2
	inner join SF4### SF4
	on SF4.F4_FILIAL       = @cFil_SF4
		and SF4.F4_CODIGO   = SD2.D2_TES
		and (SF4.F4_ESTOQUE = @vcEstoque or (@IN_CONSTESTERC = @IS_ACTIVE and (SF4.F4_PODER3 in (@vcPoder1, @vcPoder2)) ))
		and SF4.D_E_L_E_T_  = @IS_SPACE
	where SD2.D2_FILIAL       = @cFil_SD2
			and SD2.D2_COD      = @IN_CCOD
			and SD2.D2_LOCAL    = @IN_CLOCAL
			##IF_006({|| SuperGetMV('MV_A330GRV',.F.,.T.) .and. cPaisloc $ 'ARG|PER|MEX'})
				and SD2.D2_DTDIGIT >= @vDtVai
				and SD2.D2_DTDIGIT < @IN_DDATA
			##ELSE_006
				and SD2.D2_EMISSAO >= @vDtVai
				and SD2.D2_EMISSAO  < @IN_DDATA
			##ENDIF_006
			and SD2.D2_ORIGLAN <> @vcOrigLan
			##IF_005({|| cPaisLoc <> 'BRA' })
				and (SD2.D2_REMITO   = @vcRemito or (SD2.D2_REMITO  <> @vcRemito and SD2.D2_TPDCENV in ( @vcTPDCENV1, @vcTpDCENV2)))
			##ELSE_005
				and SD2.D2_REMITO   =  @vcRemito
				and SD2.D2_TPDCENV  not in (@vcTPDCENV1, @vcTpDCENV2)
			##ENDIF_005
			and SD2.D_E_L_E_T_  = @IS_SPACE

	if @vQSaidas    is null select @vQSaidas    = 0
	if @vD2_CUSTO   is null select @vD2_CUSTO   = 0
	if @vD2_CUSTO2  is null select @vD2_CUSTO2  = 0
	if @vD2_CUSTO3  is null select @vD2_CUSTO3  = 0
	if @vD2_CUSTO4  is null select @vD2_CUSTO4  = 0
	if @vD2_CUSTO5  is null select @vD2_CUSTO5  = 0
	if @vD2_CUSRP1  is null select @vD2_CUSRP1  = 0
	if @vD2_CUSRP2  is null select @vD2_CUSRP2  = 0
	if @vD2_CUSRP3  is null select @vD2_CUSRP3  = 0
	if @vD2_CUSRP4  is null select @vD2_CUSRP4  = 0
	if @vD2_CUSRP5  is null select @vD2_CUSRP5  = 0
	if @vD2_QTSEGUM is null select @vD2_QTSEGUM = 0

	/* ------------------------------------------------------------------------------
	Acumula Valores das Movimentacoes de Saida
	------------------------------------------------------------------------------ */
	If @IN_INTDL = '1' and @IN_MV_D3SERVI = '0' begin
		select @vQMovSaid   = Sum(D3_QUANT)
				,@vD3S_CUSTO  = Sum(D3_CUSTO1)
				,@vD3S_CUSTO2 = Sum(D3_CUSTO2)
				,@vD3S_CUSTO3 = Sum(D3_CUSTO3)
				,@vD3S_CUSTO4 = Sum(D3_CUSTO4)
				,@vD3S_CUSTO5 = Sum(D3_CUSTO5)
				,@vD3S_QTSEGUM= Sum(D3_QTSEGUM)
				,@vD3S_CUSRP1 = Sum(SD3.D3_CUSRP1)
				,@vD3S_CUSRP2 = Sum(SD3.D3_CUSRP2)
				,@vD3S_CUSRP3 = Sum(SD3.D3_CUSRP3)
				,@vD3S_CUSRP4 = Sum(SD3.D3_CUSRP4)
				,@vD3S_CUSRP5 = Sum(SD3.D3_CUSRP5)
		from SD3### SD3
		where SD3.D3_FILIAL       = @cFil_SD3
				and SD3.D3_COD      = @IN_CCOD
				and SD3.D3_LOCAL    = @IN_CLOCAL
				and SD3.D3_EMISSAO >= @vDtVai
				and SD3.D3_EMISSAO  < @IN_DDATA
				and SD3.D3_ESTORNO  = @IS_SPACE
				and SD3.D3_TM       > @vcTMEntrada
				and SD3.D_E_L_E_T_  = @IS_SPACE
				and (SD3.D3_SERVIC  = @vcSemCodServ or ( SD3.D3_SERVIC <> @vcSemCodServ and SD3.D3_LOCAL = @IN_MV_CQ ) or (@IN_MV_WMSNEW = @IS_ACTIVE and  SD3.D3_SERVIC <> @vcSemCodServ))
				and ( SD3.D3_TM     = @vcTMSaiAut
						or 0 < (	select count(*)
									from SF5### SF5 (nolock)
									where F5_FILIAL          = @cFil_SF5
											and F5_CODIGO      = SD3.D3_TM
											and SF5.D_E_L_E_T_ = @IS_SPACE ))
	end else begin
		select @vQMovSaid   = Sum(D3_QUANT)
				,@vD3S_CUSTO  = Sum(D3_CUSTO1)
				,@vD3S_CUSTO2 = Sum(D3_CUSTO2)
				,@vD3S_CUSTO3 = Sum(D3_CUSTO3)
				,@vD3S_CUSTO4 = Sum(D3_CUSTO4)
				,@vD3S_CUSTO5 = Sum(D3_CUSTO5)
				,@vD3S_QTSEGUM= Sum(D3_QTSEGUM)
				,@vD3S_CUSRP1 = Sum(SD3.D3_CUSRP1)
				,@vD3S_CUSRP2 = Sum(SD3.D3_CUSRP2)
				,@vD3S_CUSRP3 = Sum(SD3.D3_CUSRP3)
				,@vD3S_CUSRP4 = Sum(SD3.D3_CUSRP4)
				,@vD3S_CUSRP5 = Sum(SD3.D3_CUSRP5)
		from SD3### SD3
		where SD3.D3_FILIAL       = @cFil_SD3
				and SD3.D3_COD      = @IN_CCOD
				and SD3.D3_LOCAL    = @IN_CLOCAL
				and SD3.D3_EMISSAO >= @vDtVai
				and SD3.D3_EMISSAO  < @IN_DDATA
				and SD3.D3_ESTORNO  = @IS_SPACE
				and SD3.D3_TM       > @vcTMEntrada
				and SD3.D_E_L_E_T_  = @IS_SPACE
				and ( SD3.D3_TM     = @vcTMSaiAut
						or 0 < (	select count(*)
									from SF5### SF5 (nolock)
									where F5_FILIAL        = @cFil_SF5
										and F5_CODIGO       = SD3.D3_TM
										and SF5.D_E_L_E_T_  = @IS_SPACE ))
	end
	if @vQMovSaid    is null select @vQMovSaid    = 0
	if @vD3S_CUSTO   is null select @vD3S_CUSTO   = 0
	if @vD3S_CUSTO2  is null select @vD3S_CUSTO2  = 0
	if @vD3S_CUSTO3  is null select @vD3S_CUSTO3  = 0
	if @vD3S_CUSTO4  is null select @vD3S_CUSTO4  = 0
	if @vD3S_CUSTO5  is null select @vD3S_CUSTO5  = 0
	if @vD3S_CUSRP1  is null select @vD3S_CUSRP1  = 0
	if @vD3S_CUSRP2  is null select @vD3S_CUSRP2  = 0
	if @vD3S_CUSRP3  is null select @vD3S_CUSRP3  = 0
	if @vD3S_CUSRP4  is null select @vD3S_CUSRP4  = 0
	if @vD3S_CUSRP5  is null select @vD3S_CUSRP5  = 0
	if @vD3S_QTSEGUM is null select @vD3S_QTSEGUM = 0

	/* ------------------------------------------------------------------------------
	Calcula Movimentacoes em Processo
	------------------------------------------------------------------------------ */
	if @IN_CLOCAL = @IN_MV_LOCPROC begin
		/* ------------------------------------------------------------------------------
		Acumula Valores das Movimentacoes de Entrada
		------------------------------------------------------------------------------ */
		If @IN_INTDL = '1' and @IN_MV_D3SERVI = '0' begin
			select @vQMovEntrP    = Sum(D3_QUANT)
					,@vD3EP_CUSTO   = Sum(D3_CUSTO1)
					,@vD3EP_CUSTO2  = Sum(D3_CUSTO2)
					,@vD3EP_CUSTO3  = Sum(D3_CUSTO3)
					,@vD3EP_CUSTO4  = Sum(D3_CUSTO4)
					,@vD3EP_CUSTO5  = Sum(D3_CUSTO5)
					,@vD3EP_QTSEGUM = Sum(D3_QTSEGUM)
					,@vD3EP_CUSRP1  = Sum(SD3.D3_CUSRP1)
					,@vD3EP_CUSRP2  = Sum(SD3.D3_CUSRP2)
					,@vD3EP_CUSRP3  = Sum(SD3.D3_CUSRP3)
					,@vD3EP_CUSRP4  = Sum(SD3.D3_CUSRP4)
					,@vD3EP_CUSRP5  = Sum(SD3.D3_CUSRP5)
			from SD3### SD3
			where SD3.D3_FILIAL       = @cFil_SD3
					and SD3.D3_COD      = @IN_CCOD
					and SD3.D3_LOCAL   <> @IN_CLOCAL
					and SD3.D3_EMISSAO >= @vDtVai
					and SD3.D3_EMISSAO  < @IN_DDATA
					and SD3.D3_ESTORNO  = @IS_SPACE
					and SD3.D3_TM       > @vcTMEntrada
					and SD3.D3_CF       = @vcReqArmProc
					and (SD3.D3_SERVIC  = @vcSemCodServ or ( SD3.D3_SERVIC <> @vcSemCodServ and SD3.D3_LOCAL = @IN_MV_CQ ) or (@IN_MV_WMSNEW = @IS_ACTIVE and  SD3.D3_SERVIC <> @vcSemCodServ))
					and SD3.D_E_L_E_T_  = @IS_SPACE
		end else begin
			select @vQMovEntrP    = Sum(D3_QUANT)
					,@vD3EP_CUSTO   = Sum(D3_CUSTO1)
					,@vD3EP_CUSTO2  = Sum(D3_CUSTO2)
					,@vD3EP_CUSTO3  = Sum(D3_CUSTO3)
					,@vD3EP_CUSTO4  = Sum(D3_CUSTO4)
					,@vD3EP_CUSTO5  = Sum(D3_CUSTO5)
					,@vD3EP_QTSEGUM = Sum(D3_QTSEGUM)
					,@vD3EP_CUSRP1  = Sum(SD3.D3_CUSRP1)
					,@vD3EP_CUSRP2  = Sum(SD3.D3_CUSRP2)
					,@vD3EP_CUSRP3  = Sum(SD3.D3_CUSRP3)
					,@vD3EP_CUSRP4  = Sum(SD3.D3_CUSRP4)
					,@vD3EP_CUSRP5  = Sum(SD3.D3_CUSRP5)
			from SD3### SD3
			where SD3.D3_FILIAL       = @cFil_SD3
					and SD3.D3_COD      = @IN_CCOD
					and SD3.D3_LOCAL   <> @IN_CLOCAL
					and SD3.D3_EMISSAO >= @vDtVai
					and SD3.D3_EMISSAO  < @IN_DDATA
					and SD3.D3_ESTORNO  = @IS_SPACE
					and SD3.D3_TM       > @vcTMEntrada
					and SD3.D3_CF       = @vcReqArmProc
					and SD3.D_E_L_E_T_  = @IS_SPACE
		end

		if @vQMovEntrP    is null select @vQMovEntrP    = 0
		if @vD3EP_CUSTO   is null select @vD3EP_CUSTO   = 0
		if @vD3EP_CUSTO2  is null select @vD3EP_CUSTO2  = 0
		if @vD3EP_CUSTO3  is null select @vD3EP_CUSTO3  = 0
		if @vD3EP_CUSTO4  is null select @vD3EP_CUSTO4  = 0
		if @vD3EP_CUSTO5  is null select @vD3EP_CUSTO5  = 0
		if @vD3EP_CUSRP1  is null select @vD3EP_CUSRP1  = 0
		if @vD3EP_CUSRP2  is null select @vD3EP_CUSRP2  = 0
		if @vD3EP_CUSRP3  is null select @vD3EP_CUSRP3  = 0
		if @vD3EP_CUSRP4  is null select @vD3EP_CUSRP4  = 0
		if @vD3EP_CUSRP5  is null select @vD3EP_CUSRP5  = 0
		if @vD3EP_QTSEGUM is null select @vD3EP_QTSEGUM = 0

		/* ------------------------------------------------------------------------------
		Acumula Valores das Movimentacoes de Saida
		------------------------------------------------------------------------------ */
		select @vQMovSaidP    = Sum(D3_QUANT)
				,@vD3SP_CUSTO   = Sum(D3_CUSTO1)
				,@vD3SP_CUSTO2  = Sum(D3_CUSTO2)
				,@vD3SP_CUSTO3  = Sum(D3_CUSTO3)
				,@vD3SP_CUSTO4  = Sum(D3_CUSTO4)
				,@vD3SP_CUSTO5  = Sum(D3_CUSTO5)
				,@vD3SP_QTSEGUM = Sum(D3_QTSEGUM)
				,@vD3SP_CUSRP1  = Sum(SD3.D3_CUSRP1)
				,@vD3SP_CUSRP2  = Sum(SD3.D3_CUSRP2)
				,@vD3SP_CUSRP3  = Sum(SD3.D3_CUSRP3)
				,@vD3SP_CUSRP4  = Sum(SD3.D3_CUSRP4)
				,@vD3SP_CUSRP5  = Sum(SD3.D3_CUSRP5)
			from SD3### SD3
			where SD3.D3_FILIAL       = @cFil_SD3
					and SD3.D3_COD      = @IN_CCOD
					and SD3.D3_LOCAL   <> @IN_CLOCAL
					and SD3.D3_EMISSAO >= @vDtVai
					and SD3.D3_EMISSAO  < @IN_DDATA
					and SD3.D3_ESTORNO  = @IS_SPACE
					and SD3.D3_TM      <= @vcTMEntrada
					and SD3.D3_CF       = @vcDevArmProc
					and SD3.D_E_L_E_T_  = @IS_SPACE

			if @vQMovSaidP    is null select @vQMovSaidP    = 0
			if @vD3SP_CUSTO   is null select @vD3SP_CUSTO   = 0
			if @vD3SP_CUSTO2  is null select @vD3SP_CUSTO2  = 0
			if @vD3SP_CUSTO3  is null select @vD3SP_CUSTO3  = 0
			if @vD3SP_CUSTO4  is null select @vD3SP_CUSTO4  = 0
			if @vD3SP_CUSTO5  is null select @vD3SP_CUSTO5  = 0
			if @vD3SP_CUSRP1  is null select @vD3SP_CUSRP1  = 0
			if @vD3SP_CUSRP2  is null select @vD3SP_CUSRP2  = 0
			if @vD3SP_CUSRP3  is null select @vD3SP_CUSRP3  = 0
			if @vD3SP_CUSRP4  is null select @vD3SP_CUSRP4  = 0
			if @vD3SP_CUSRP5  is null select @vD3SP_CUSRP5  = 0
			if @vD3SP_QTSEGUM is null select @vD3SP_QTSEGUM = 0
		end

		select @OUT_QSALDOATU = (@vB9_QINI    + @vQEntradas  + @vQMovEntr    + @vQMovEntrP)    - (@vQSaidas    + @vQMovSaid    + @vQMovSaidP   )
		select @OUT_CUSTOATU  = (@vB9_VINI1   + @vD1_CUSTO   + @vD3E_CUSTO   + @vD3EP_CUSTO )  - (@vD2_CUSTO   + @vD3S_CUSTO   + @vD3SP_CUSTO  )
		select @OUT_CUSTOATU2 = (@vB9_VINI2   + @vD1_CUSTO2  + @vD3E_CUSTO2  + @vD3EP_CUSTO2)  - (@vD2_CUSTO2  + @vD3S_CUSTO2  + @vD3SP_CUSTO2 )
		select @OUT_CUSTOATU3 = (@vB9_VINI3   + @vD1_CUSTO3  + @vD3E_CUSTO3  + @vD3EP_CUSTO3)  - (@vD2_CUSTO3  + @vD3S_CUSTO3  + @vD3SP_CUSTO3 )
		select @OUT_CUSTOATU4 = (@vB9_VINI4   + @vD1_CUSTO4  + @vD3E_CUSTO4  + @vD3EP_CUSTO4)  - (@vD2_CUSTO4  + @vD3S_CUSTO4  + @vD3SP_CUSTO4 )
		select @OUT_CUSTOATU5 = (@vB9_VINI5   + @vD1_CUSTO5  + @vD3E_CUSTO5  + @vD3EP_CUSTO5)  - (@vD2_CUSTO5  + @vD3S_CUSTO5  + @vD3SP_CUSTO5 )
		select @OUT_QTSEGUM   = (@vB9_QTSEGUM + @vD1_QTSEGUM + @vD3E_QTSEGUM + @vD3EP_QTSEGUM) - (@vD2_QTSEGUM + @vD3S_QTSEGUM + @vD3SP_QTSEGUM)
		select @OUT_B9_CM1    = ( @vB9_CM1 )
		select @OUT_B9_CM2    = ( @vB9_CM2 )
		select @OUT_B9_CM3    = ( @vB9_CM3 )
		select @OUT_B9_CM4    = ( @vB9_CM4 )
		select @OUT_B9_CM5    = ( @vB9_CM5 )
		select @OUT_B9_CMRP1  = ( @vB9_CMRP1 )
		select @OUT_B9_CMRP2  = ( @vB9_CMRP2 )
		select @OUT_B9_CMRP3  = ( @vB9_CMRP3 )
		select @OUT_B9_CMRP4  = ( @vB9_CMRP4 )
		select @OUT_B9_CMRP5  = ( @vB9_CMRP5 )
		select @OUT_CUSTORP1  = (@vB9_VINIRP1   + @vD1_CUSRP1   + @vD3E_CUSRP1  + @vD3EP_CUSRP1 )  - (@vD2_CUSRP1 + @vD3S_CUSRP1 + @vD3SP_CUSRP1)
		select @OUT_CUSTORP2  = (@vB9_VINIRP2   + @vD1_CUSRP2   + @vD3E_CUSRP2  + @vD3EP_CUSRP2 )  - (@vD2_CUSRP2 + @vD3S_CUSRP2 + @vD3SP_CUSRP2)
		select @OUT_CUSTORP3  = (@vB9_VINIRP3   + @vD1_CUSRP3   + @vD3E_CUSRP3  + @vD3EP_CUSRP3 )  - (@vD2_CUSRP3 + @vD3S_CUSRP3 + @vD3SP_CUSRP3)
		select @OUT_CUSTORP4  = (@vB9_VINIRP4   + @vD1_CUSRP4   + @vD3E_CUSRP4  + @vD3EP_CUSRP4 )  - (@vD2_CUSRP4 + @vD3S_CUSRP4 + @vD3SP_CUSRP4)
		select @OUT_CUSTORP5  = (@vB9_VINIRP5   + @vD1_CUSRP5   + @vD3E_CUSRP5  + @vD3EP_CUSRP5 )  - (@vD2_CUSRP5 + @vD3S_CUSRP5 + @vD3SP_CUSRP5)
end
