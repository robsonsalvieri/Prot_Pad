Create procedure CTBR400A_## 
(
  @IN_FILIAL       Char('CQ1_FILIAL'),
  @IN_CONTA        Char('CQ1_CONTA'),
  @IN_TPSALDO      Char('CQ1_TPSALD'),
  @IN_MOEDA        Char('CQ1_MOEDA'),
  @IN_DATATMP      Char('CQ1_DATA'),
  @IN_MULTIFIL     Char(1),
  @IN_IDSESSION    Char(32),
  @OUT_SLDATU      Float OutPut,
  @OUT_DEBDATA     Float OutPut,
  @OUT_CREDATA     Float OutPut,
  @OUT_SLDATUDEB   Float OutPut,
  @OUT_SLDATUCRE   Float OutPut,
  @OUT_SLDANT      Float OutPut,
  @OUT_SLDANTDEB   Float OutPut,
  @OUT_SLDANTCRE   Float OutPut
)
as
/* ------------------------------------------------------------------------------------

    Versao          - <v>  Protheus P.12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  CTBR400.PRW </s>
    Descricao       - <d>  Saldos base anterior a debito e credito </d>
    Funcao do Siga  -      ReportPrint() - CTBR400() 
    Entrada         - <> @IN_FILIAL       - Filial informada na chamada (cFilAnt)
                           @IN_CONTA        - Conta contabil (CQ1_CONTA)
                           @IN_TPSALDO      - Tipo de saldo (CQ1_TPSALD)
                           @IN_MOEDA        - Moeda (CQ1_MOEDA)
                           @IN_DATATMP      - Data de corte, formato AAAAMMDD (CQ1_DATA)
						   @IN_MULTIFIL		- Indica se a extração de dados é multifilial
						   @IN_IDSESSION	- Codigo FWUUIDV4() identificador da sessão

                           
    Saida           - <ro> @OUT_SLDATU      - [1] Saldo atual (credor - devedor)
                           @OUT_DEBDATA     - [2] Debito na data
                           @OUT_CREDATA     - [3] Credito na data
                           @OUT_SLDATUDEB   - [4] Saldo atual devedor (acumulado + debito na data)
                           @OUT_SLDATUCRE   - [5] Saldo atual credor (acumulado + credito na data)
                           @OUT_SLDANT      - [6] Saldo anterior (credor - devedor)
                           @OUT_SLDANTDEB   - [7] Saldo anterior devedor (acumulado antes da data)
                           @OUT_SLDANTCRE   - [8] Saldo anterior credor (acumulado antes da data) </ro>
    Responsavel :     <r>  Squad Controladoria </r>
    Data        :     06/08/2026
   -------------------------------------------------------------------------------------- */
declare @cConta     Char('CQ1_CONTA')
declare @nSldAtu    Float
declare @nAtuDeb    Float
declare @nAtuCrd    Float
declare @nDebito    Float
declare @nCredito   Float
declare @nSldAnt    Float
declare @nAntDeb    Float
declare @nAntCrd    Float

begin

	select @OUT_SLDATU     = 0
	select @OUT_DEBDATA    = 0
	select @OUT_CREDATA    = 0
	select @OUT_SLDATUDEB  = 0
	select @OUT_SLDATUCRE  = 0
	select @OUT_SLDANT     = 0
	select @OUT_SLDANTDEB  = 0
	select @OUT_SLDANTCRE  = 0
	select @nSldAtu   = 0
	select @nAtuDeb   = 0
	select @nAtuCrd   = 0
	select @nDebito   = 0
	select @nCredito  = 0
	select @nSldAnt   = 0
	select @nAntDeb   = 0
	select @nAntCrd   = 0
	select @cConta    = ' '

	/*--------------------------------------------------
		Movimento na data (@IN_DATATMP)
	---------------------------------------------------*/
	select @cConta = CQ1_CONTA, @nDebito = COALESCE(SUM(CQ1_DEBITO), 0), @nCredito = COALESCE(SUM(CQ1_CREDIT), 0)
	from CQ1### CQ1
	where ((@IN_MULTIFIL = '0' AND CQ1.CQ1_FILIAL = @IN_FILIAL) OR (CQ1.CQ1_FILIAL IN ( SELECT TRQ_FILIAL FROM TRQ###_SP WHERE TRQ_UUID = @IN_IDSESSION )))
	  and CQ1.CQ1_MOEDA  = @IN_MOEDA
	  and CQ1.CQ1_TPSALD = @IN_TPSALDO
	  and CQ1.CQ1_CONTA  = @IN_CONTA
	  and CQ1.D_E_L_E_T_ = ' '
	  and CQ1.CQ1_DATA   = @IN_DATATMP
	group by CQ1_CONTA

	/*--------------------------------------------------
		Acumulado anterior a data (@IN_DATATMP)
	---------------------------------------------------*/
	
	select @cConta = CQ1_CONTA, @nAntDeb = COALESCE(SUM(CQ1_DEBITO), 0), @nAntCrd = COALESCE(SUM(CQ1_CREDIT), 0)
	from CQ1### CQ1
	where ((@IN_MULTIFIL = '0' AND CQ1.CQ1_FILIAL = @IN_FILIAL) OR (CQ1.CQ1_FILIAL IN ( SELECT TRQ_FILIAL FROM TRQ###_SP WHERE TRQ_UUID = @IN_IDSESSION )))
	  and CQ1.CQ1_MOEDA  = @IN_MOEDA
	  and CQ1.CQ1_TPSALD = @IN_TPSALDO
	  and CQ1.CQ1_CONTA  = @IN_CONTA
	  and CQ1.D_E_L_E_T_ = ' '
	  and CQ1.CQ1_DATA   < @IN_DATATMP
	group by CQ1_CONTA

	select @nSldAnt = @nAntCrd - @nAntDeb
	select @nAtuCrd = @nAntCrd + @nCredito
	select @nAtuDeb = @nAntDeb + @nDebito
	select @nSldAtu = @nAtuCrd - @nAtuDeb

	select @OUT_SLDATU     = @nSldAtu
	select @OUT_DEBDATA    = @nDebito
	select @OUT_CREDATA    = @nCredito
	select @OUT_SLDATUDEB  = @nAtuDeb
	select @OUT_SLDATUCRE  = @nAtuCrd
	select @OUT_SLDANT     = @nSldAnt
	select @OUT_SLDANTDEB  = @nAntDeb
	select @OUT_SLDANTCRE  = @nAntCrd

end
