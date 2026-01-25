Create Procedure CTB250_##
(
    @IN_FILIAL Char('CT2_FILIAL'),
    @IN_CCUSTO Char('CT2_CCD'),   
    @IN_DATAI  Char( 08 ),   
    @IN_DATAF  Char( 08 ),   
    @IN_LGRUPO Char( 01 ),   
    @IN_GRUPO  Char( 'CT1_GRUPO'), 
    @IN_CTAINI Char( 'CT1_CONTA' ),
    @IN_CTAFIM Char( 'CT1_CONTA' ),
    @IN_MV_CUSEMP Char( 01 ),   
    @OUT_VAL01  Float OutPut,      
    @OUT_VAL02  Float OutPut,
    @OUT_VAL03  Float OutPut,
    @OUT_VAL04  Float OutPut,
    @OUT_VAL05  Float OutPut
)
as
/* ------------------------------------------------------------------------------------

    Versão          - <v>  Protheus P12 </v>
    Assinatura      - <a>  001 </a>
    Fonte Microsiga - <s>  MATA330MOD.PRX </s>
    Descricao       - <d>  Calculo da Mao de Obra  </d>
    Funcao do Siga  -      MA330SalCC()
    Entrada         - <ri>  @IN_FILIAL    - Filial a obter saldo
                            @IN_CCUSTO    - Código do CCusto - B1_CUSTO
                            @IN_DATAI     - Data ini - Data inicio do Processamento
                            @IN_DATAF     - Data fim - Data Final do Processamento
									 @IN_LGRUPO    - Se deve buscar pelo Grupo de Custo (B1_GCCUSTO)
                            @IN_GRUPO     - Código do grupo - B1_GCCUSTO
                            @IN_CTAINI    - Conta Inicial
                            @IN_CTAFIM    - Conta Final
    Saida           - <o>   @OUT_VAL01     - Saldo da Conta+CCusto MOEDA 1 
                            @OUT_VAL02     - Saldo da Conta+CCusto MOEDA 2 
                            @OUT_VAL03     - Saldo da Conta+CCusto MOEDA 3 
                            @OUT_VAL04     - Saldo da Conta+CCusto MOEDA 4 
                            @OUT_VAL05     - Saldo da Conta+CCusto MOEDA 5 </ro> 
    Responsavel :     <r>  Control	</r>
    Data        :     2023
    
    CTB250 - Saldo da Conta+CCusto
-------------------------------------------------------------------------------------- */
Declare @cAux        Char(03)
Declare @cFilial_CT2 Char('CT2_FILIAL')
Declare @cFilial_CT1 Char('CT1_FILIAL')
Declare @cCT2_FILIAL Char('CT2_FILIAL')
Declare @cCT2_DEBITO Char('CT2_DEBITO')
Declare @cCT2_CCD    Char('CT2_CCD')
Declare @cCT2_MOEDLC Char('CT2_MOEDLC')
Declare @nCT2_VALOR  float
Declare @cTIPO       Char(01)
Declare @nTot1       float
Declare @nTot2       float
Declare @nTot3       float
Declare @nTot4       float
Declare @nTot5       float
Declare @nValorD1    float
Declare @nValorC1    float
Declare @nValorD2    float
Declare @nValorC2    float
Declare @nValorD3    float
Declare @nValorC3    float
Declare @nValorD4    float
Declare @nValorC4    float
Declare @nValorD5    float
Declare @nValorC5    float
Declare @lFiltro     Char(01)
Declare @lGrupo      Char(01)
Declare @lSoma       Char(01)

Begin
    select @nTot1     = 0
    select @nTot2     = 0
    select @nTot3     = 0
    select @nTot4     = 0
    select @nTot5     = 0
    Select @OUT_VAL01 = 0
    Select @OUT_VAL02 = 0
    Select @OUT_VAL03 = 0
    Select @OUT_VAL04 = 0
    Select @OUT_VAL05 = 0
	
    select @lGrupo = '0'
    If @IN_LGRUPO = '1' begin
        if @IN_GRUPO != ' ' select @lGrupo = '1' 
    end
    
    select @cAux = 'CT2'
    exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT2 OutPut
    
    select @cAux = 'CT1'
    exec XFILIAL_## @cAux, @IN_FILIAL, @cFilial_CT1 OutPut
    
	 Declare CUR_CT2 insensitive cursor for
        Select CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC, IsNull(Sum(CT2_VALOR), 0), '1'
          From CT2###
			  Where ((@IN_MV_CUSEMP = '0' and CT2_FILIAL = @cFilial_CT2) or (@IN_MV_CUSEMP = '1'))
           and (CT2_DC    = '1' or CT2_DC = '3')
           and (CT2_CCD   = @IN_CCUSTO and CT2_CCD != ' ')
           and CT2_TPSALD = '1'
           and (CT2_DATA between @IN_DATAI and @IN_DATAF)
           and CT2_DEBITO IN ( SELECT CT1_CONTA FROM CT1### 
                                WHERE CT1_FILIAL = @cFilial_CT1
                                AND D_E_L_E_T_= ' '  
                                AND ((@lGrupo = '1' AND CT1_GRUPO  = @IN_GRUPO) or (@lGrupo = '0')  )  AND D_E_L_E_T_  = ' ' )
           and D_E_L_E_T_= ' '
       Group By CT2_FILIAL, CT2_DEBITO, CT2_CCD, CT2_MOEDLC
        Union
       Select CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC, IsNull(Sum(CT2_VALOR), 0), '2'
         From CT2###
		  Where ((@IN_MV_CUSEMP = '0' and CT2_FILIAL = @cFilial_CT2) or (@IN_MV_CUSEMP = '1'))
          and (CT2_DC    = '2' or CT2_DC = '3')
          and (CT2_CCC   = @IN_CCUSTO and CT2_CCC != ' ')
          and CT2_TPSALD = '1'
          and (CT2_DATA between @IN_DATAI and @IN_DATAF)
          and CT2_CREDIT IN ( SELECT CT1_CONTA FROM CT1### 
                                WHERE CT1_FILIAL = @cFilial_CT1
                                AND D_E_L_E_T_= ' '  
                                AND ((@lGrupo = '1' AND CT1_GRUPO  = @IN_GRUPO) or (@lGrupo = '0')  )  AND D_E_L_E_T_  = ' ' )
          and D_E_L_E_T_ = ' '
       Group By CT2_FILIAL, CT2_CREDIT, CT2_CCC, CT2_MOEDLC
       Order by 1, 2, 3, 4, 6
    For read only 
    Open CUR_CT2
    Fetch CUR_CT2 Into @cCT2_FILIAL, @cCT2_DEBITO, @cCT2_CCD, @cCT2_MOEDLC, @nCT2_VALOR, @cTIPO

    While (@@fetch_status = 0 ) begin
	
		select @lSoma = '0'
		If @IN_CTAINI = ' ' and @IN_CTAFIM != ' ' Begin
			If @cCT2_DEBITO > @IN_CTAFIM select @lSoma = '1'
		End 
		Else If @IN_CTAINI != ' ' and @IN_CTAFIM = ' ' Begin
		    If @cCT2_DEBITO < @IN_CTAINI select @lSoma = '1'
		end
		else begin
			If @cCT2_DEBITO < @IN_CTAINI OR @cCT2_DEBITO > @IN_CTAFIM select @lSoma = '1'
		End
		If @lSoma = '1' begin
			/* -----------------------
					Moeda 01
				----------------------- */
			If @cCT2_MOEDLC = '01'  begin
				If @cTIPO = '1'  begin
					select @nValorC1 = 0
					select @nValorD1 = @nCT2_VALOR 
					select @nTot1 = @nTot1 + @nValorD1
				End
				If @cTIPO = '2'  begin
					select @nValorD1 = 0
					select @nValorC1 = @nCT2_VALOR
					select @nTot1 = @nTot1 - @nValorC1
				End
			End
				
			/* -----------------------
					Moeda 02 
				----------------------- */
			If @cCT2_MOEDLC = '02'  begin
				If @cTIPO = '1'  begin
					select @nValorC2 = 0
					select @nValorD2 = @nCT2_VALOR 
					select @nTot2 =  @nTot2 + @nValorD2
				End
				If @cTIPO = '2'  begin
					select @nValorD2 = 0
					select @nValorC2 = @nCT2_VALOR
					select @nTot2 =  @nTot2 - @nValorC2 
				End
			End
				
			/* -----------------------
						Moeda 03
				----------------------- */
			If @cCT2_MOEDLC = '03'  begin
				If @cTIPO = '1'  begin
					select @nValorC3 = 0
					select @nValorD3 = @nCT2_VALOR 
					select @nTot3 = @nTot3 + @nValorD3
				End
				If @cTIPO = '2'  begin
					select @nValorD3 = 0
					select @nValorC3 = @nCT2_VALOR
					select @nTot3 = @nTot3 - @nValorC3
				End
			End
				
			/* -----------------------
					Moeda 04 
				----------------------- */
			If @cCT2_MOEDLC = '04'  begin
				If @cTIPO = '1'  begin
					select @nValorC4 = 0
					select @nValorD4 = @nCT2_VALOR 
					select @nTot4 = @nTot4 + @nValorD4
				End
				If @cTIPO = '2'  begin
					select @nValorD4 = 0
					select @nValorC4 = @nCT2_VALOR
					select @nTot4 = @nTot4 - @nValorC4 
				End
			End
				
			/* -----------------------
					Moeda 05 
				----------------------- */
			If @cCT2_MOEDLC = '05'  begin
				If @cTIPO = '1'  begin
					select @nValorC5 = 0
					select @nValorD5 = @nCT2_VALOR 
					select @nTot5 =  @nTot5 + @nValorD5
				End
				If @cTIPO = '2'  begin
					select @nValorD5 = 0
					select @nValorC5 = @nCT2_VALOR
					select @nTot5 = @nTot5 - @nValorC5 
				End
			End
		End
        SELECT @fim_CUR = 0 
        Fetch CUR_CT2 into @cCT2_FILIAL, @cCT2_DEBITO, @cCT2_CCD, @cCT2_MOEDLC, @nCT2_VALOR, @cTIPO
    end
    close CUR_CT2
    deallocate CUR_CT2

    Select @OUT_VAL01 = @nTot1
    Select @OUT_VAL02 = @nTot2
    Select @OUT_VAL03 = @nTot3
    Select @OUT_VAL04 = @nTot4
    Select @OUT_VAL05 = @nTot5

End
